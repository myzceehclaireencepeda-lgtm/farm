-- Animal Farming (Server) — QBX + ox_lib + ox_inventory + MySQL

-- NOTE: If your core export name is different, adjust here.
-- Some servers use 'qbx-core' / 'qb-core' as the resource name.
local CORE = 'qbx_core'

-- Helpers
local function getPlayer(src)
    local ok, player = pcall(function() return exports[CORE]:GetPlayer(src) end)
    if not ok or not player then return nil end
    return player
end

local function debugPrint(...)
    if Config and Config.Debug then
        print('[animal_farming]', ...)
    end
end

-- Quick JSON helpers
local function encode(v)
    return json.encode(v)
end

local function decode(v)
    return json.decode(v)
end

-- Cache config lookups for speed
local DB = {
    farmlots = "animal_farmlots",
    livestock = "animal_livestock",
    water = "animal_water_troughs",
    transactions = "animal_transactions",
    production_log = "animal_production_log",
    death_log = "animal_death_log"
}

-- Wait for Config to load
CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    -- Update DB table names from config if available
    if Config.Database then
        for k, v in pairs(Config.Database) do
            DB[k] = v
        end
    end
    
    debugPrint('Database tables configured:', json.encode(DB))
end)

-- ============================
--         OX_LIB CALLBACKS
-- ============================

-- Get player lots
lib.registerCallback('animal_farming:server:getFarmlots', function(source)
    local player = getPlayer(source)
    if not player then 
        return false, 'player not found' 
    end

    local citizenid = player.PlayerData.citizenid
    local rows = MySQL.query.await(string.format([[ 
        SELECT * FROM %s WHERE citizenid = ? ORDER BY id ASC 
    ]], DB.farmlots), { citizenid }) or {}

    return true, rows
end)

-- Purchase farmlot
lib.registerCallback('animal_farming:server:buyFarmlot', function(source, data)
    local player = getPlayer(source)
    if not player then 
        return false, 'player not found' 
    end

    local citizenid = player.PlayerData.citizenid

    -- Lot type validation
    local lotType = (data and data.lotType) and tostring(data.lotType) or ''
    if lotType ~= 'cow' and lotType ~= 'pig' and lotType ~= 'chicken' then
        return false, 'invalid lot type'
    end

    -- Enforce max lots per player
    if Config and Config.MaxFarmlotsPerPlayer and type(Config.MaxFarmlotsPerPlayer) == 'number' then
        local count = MySQL.scalar.await(string.format([[ 
            SELECT COUNT(*) FROM %s WHERE citizenid = ? 
        ]], DB.farmlots), { citizenid }) or 0

        if count >= Config.MaxFarmlotsPerPlayer then
            return false, ('max lots reached (%d)'):format(Config.MaxFarmlotsPerPlayer)
        end
    end

    -- Price
    local price = (data and data.price) and tonumber(data.price) or 0
    if price < 0 then price = 0 end

    if price > 0 then
        if not player.Functions.RemoveMoney('cash', price, 'buy_farmlot') then
            return false, 'not enough cash'
        end
    end

    -- Data setup
    local coords = (data and data.coords) and data.coords or {x = 0, y = 0, z = 0, w = 0}
    local bounds = (data and data.bounds) and data.bounds or nil
    local label  = (data and data.label)  and data.label  or (lotType .. ' Farmlot')

    -- Insert lot into DB
    local insertId = MySQL.insert.await(string.format([[ 
        INSERT INTO %s (citizenid, lot_type, label, coords, bounds, price) 
        VALUES (?, ?, ?, ?, ?, ?) 
    ]], DB.farmlots), {
        citizenid, lotType, label, encode(coords), bounds and encode(bounds) or nil, price
    })

    if not insertId then
        -- Refund on DB failure
        if price > 0 then
            player.Functions.AddMoney('cash', price, 'buy_farmlot_refund')
        end
        return false, 'db insert failed'
    end

    -- Log transaction
    MySQL.insert(string.format([[ 
        INSERT INTO %s (citizenid, `type`, ref_id, animal_type, amount, meta) 
        VALUES (?, 'buy_lot', ?, ?, ?, ?) 
    ]], DB.transactions), {
        citizenid, insertId, lotType, price, encode({ label = label })
    })

    debugPrint(('Player %s bought %s lot #%d'):format(citizenid, lotType, insertId))

    return true, {
        id       = insertId,
        lotType  = lotType,
        label    = label,
        coords   = coords,
        bounds   = bounds,
        price    = price
    }
end)

-- List animals owned by player
lib.registerCallback('animal_farming:server:getAnimals', function(source, filter)
    local player = getPlayer(source)
    if not player then return false, 'player not found' end
    local citizenid = player.PlayerData.citizenid

    local lotId = 0
    if filter and filter.lot_id then
        lotId = tonumber(filter.lot_id) or 0
    end

    local query, params
    if lotId and lotId > 0 then
        query = string.format([[ SELECT * FROM %s WHERE owner_cid = ? AND lot_id = ? ORDER BY id ASC ]], DB.livestock)
        params = { citizenid, lotId }
    else
        query = string.format([[ SELECT * FROM %s WHERE owner_cid = ? ORDER BY id ASC ]], DB.livestock)
        params = { citizenid }
    end
    local rows = MySQL.query.await(query, params)
    return true, rows or {}
end)

-- Buy animal for a specific lot
lib.registerCallback('animal_farming:server:buyAnimal', function(source, data)
    local player = getPlayer(source)
    if not player then return false, 'player not found' end
    local citizenid = player.PlayerData.citizenid
    
    local lotId = 0
    if data and data.lot_id then
        lotId = tonumber(data.lot_id) or 0
    end
    
    local atype = ''
    if data and data.animal_type then
        atype = tostring(data.animal_type)
    end

    local cfg = Config and Config.Animals and Config.Animals[atype]
    if not cfg then return false, 'invalid animal type' end

    -- Validate owned lot & type restriction
    local lot = MySQL.query.await(string.format([[
        SELECT * FROM %s WHERE id = ? AND citizenid = ?
    ]], DB.farmlots), { lotId, citizenid })

    if not lot or not lot[1] then
        return false, 'invalid lot or not owner'
    end
    lot = lot[1]
    if lot.lot_type ~= atype and (cfg.lotRestricted ~= false) then
        return false, 'lot type mismatch'
    end

    -- Optional: limit per lot
    if Config and Config.MaxAnimalsPerLot and type(Config.MaxAnimalsPerLot) == 'number' then
        local cnt = MySQL.scalar.await(string.format([[
            SELECT COUNT(*) FROM %s WHERE lot_id = ?
        ]], DB.livestock), { lotId }) or 0
        if cnt >= Config.MaxAnimalsPerLot then
            return false, 'lot animal limit reached'
        end
    end

    -- Money
    local price = tonumber(cfg.price or 0) or 0
    if price > 0 then
        if not player.Functions.RemoveMoney('cash', price, 'buy_animal') then
            return false, 'not enough cash'
        end
    end

    -- Gender roll
    local femaleChance = tonumber(cfg.femaleChance or 20) or 20
    local gender = (math.random(1,100) <= femaleChance) and 'female' or 'male'

    -- Base stats
    local stats = cfg.stats or {health=100,hunger=100,thirst=100}

    -- Insert animal
    local animalId = MySQL.insert.await(string.format([[
        INSERT INTO %s (owner_cid, lot_id, animal_type, gender, health, hunger, thirst, spawned, coords)
        VALUES (?, ?, ?, ?, ?, ?, ?, 0, NULL)
    ]], DB.livestock), {
        citizenid, lotId, atype, gender,
        tonumber(stats.health or 100), tonumber(stats.hunger or 100), tonumber(stats.thirst or 100)
    })

    if not animalId then
        if price > 0 then player.Functions.AddMoney('cash', price, 'buy_animal_refund') end
        return false, 'db insert failed'
    end

    MySQL.insert(string.format([[
        INSERT INTO %s (citizenid, `type`, ref_id, animal_type, amount)
        VALUES (?, 'buy_animal', ?, ?, ?)
    ]], DB.transactions), { citizenid, animalId, atype, price })

    debugPrint(('Player %s bought %s animal #%d on lot %d'):format(citizenid, atype, animalId, lotId))
    return true, { id = animalId, gender = gender, stats = stats }
end)

-- Feed animal
lib.registerCallback('animal_farming:server:feedAnimal', function(source, animalId)
    local src = source
    local player = getPlayer(src)
    if not player then return false, 'player not found' end
    animalId = tonumber(animalId or 0) or 0
    if animalId <= 0 then return false, 'invalid animal id' end

    local citizenid = player.PlayerData.citizenid

    -- Verify ownership & alive
    local rows = MySQL.query.await(string.format([[
        SELECT id, owner_cid, is_dead, health, hunger, thirst, animal_type FROM %s WHERE id = ?
    ]], DB.livestock), { animalId })
    if not rows or not rows[1] then return false, 'animal not found' end
    local a = rows[1]
    if a.owner_cid ~= citizenid then return false, 'not owner' end
    if a.is_dead == 1 then return false, 'animal is dead' end

    -- Check if animal is already at max hunger
    if (tonumber(a.hunger or 0) >= 95) then
        return false, 'animal is already full'
    end

    -- Remove feed item
    local feedItem = (Config and Config.FeedItem) and Config.FeedItem or 'animal_feed'
    local removed = exports.ox_inventory:RemoveItem(src, feedItem, 1)
    if not removed then
        return false, 'missing animal feed'
    end

    -- Progressive feeding benefits based on animal type
    local cfg = Config and Config.Animals and Config.Animals[a.animal_type] or {}
    local feedingCfg = Config and Config.Feeding or {}
    
    local baseHungerBoost = feedingCfg.hungerBoost or 40
    local baseHealthBoost = feedingCfg.healthBoost or 10
    
    -- Type-specific bonuses
    local typeBonus = cfg.feedingBonus or 1.0
    local hungerBoost = math.floor(baseHungerBoost * typeBonus)
    local healthBoost = math.floor(baseHealthBoost * typeBonus)

    local newHunger = math.min(100.0, (tonumber(a.hunger or 0) + hungerBoost))
    local newHealth = math.min(100.0, (tonumber(a.health or 0) + healthBoost))

    MySQL.update.await(string.format([[
        UPDATE %s SET hunger = ?, health = ?, last_fed = NOW() WHERE id = ?
    ]], DB.livestock), { newHunger, newHealth, animalId })

    return true, { hunger = newHunger, health = newHealth }
end)

-- Get animal status
lib.registerCallback('animal_farming:server:getAnimalStatus', function(source, animalId)
    local player = getPlayer(source)
    if not player then return false, 'player not found' end
    animalId = tonumber(animalId or 0) or 0
    if animalId <= 0 then return false, 'invalid animal id' end

    local citizenid = player.PlayerData.citizenid

    local rows = MySQL.query.await(string.format([[
        SELECT * FROM %s WHERE id = ? AND owner_cid = ?
    ]], DB.livestock), { animalId, citizenid })
    
    if not rows or not rows[1] then return false, 'not found or not owner' end
    local animal = rows[1]

    -- Calculate status indicators
    local status = 'healthy'
    local health, hunger, thirst = tonumber(animal.health or 0), tonumber(animal.hunger or 0), tonumber(animal.thirst or 0)
    
    if health < 30 then status = 'critical'
    elseif health < 60 then status = 'sick'
    elseif hunger < 30 or thirst < 30 then status = 'neglected'
    end

    return true, {
        status = status,
        health = health,
        hunger = hunger,
        thirst = thirst,
        gender = animal.gender,
        isDead = tonumber(animal.is_dead or 0) == 1
    }
end)

-- Placeholder callbacks for features not fully implemented yet
lib.registerCallback('animal_farming:server:getTroughs', function(source, lotId)
    return true, {} -- Return empty troughs for now
end)

lib.registerCallback('animal_farming:server:placeTrough', function(source, lotId, coords)
    return false, 'Feature not implemented yet'
end)

lib.registerCallback('animal_farming:server:adminGetAllAnimals', function(source)
    return false, 'Admin feature not implemented yet'
end)

-- ============================
--        EVENT HANDLERS
-- ============================

-- SERVER EVENTS (using RegisterNetEvent)
RegisterNetEvent('animal_farming:server:buyFarmlot', function(data)
    local src = source
    lib.triggerCallback('animal_farming:server:buyFarmlot', src, function(success, result)
        if success then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'Farmlot purchased successfully!'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = result or 'Failed to purchase farmlot'
            })
        end
    end, data)
end)

RegisterNetEvent('animal_farming:server:buyAnimal', function(data)
    local src = source
    lib.triggerCallback('animal_farming:server:buyAnimal', src, function(success, result)
        if success then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'Animal purchased successfully!'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = result or 'Failed to purchase animal'
            })
        end
    end, data)
end)

RegisterNetEvent('animal_farming:server:feedAnimal', function(animalId)
    local src = source
    lib.triggerCallback('animal_farming:server:feedAnimal', src, function(success, result)
        if success then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = 'Animal fed successfully!'
            })
            TriggerClientEvent('animal_farming:client:updateStats', src, animalId, result)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = result or 'Failed to feed animal'
            })
        end
    end, animalId)
end)

RegisterNetEvent('animal_farming:server:requestFarmlots', function()
    local src = source
    lib.triggerCallback('animal_farming:server:getFarmlots', src, function(success, lots)
        if success then
            TriggerClientEvent('animal_farming:client:updateFarmlots', src, lots)
        end
    end)
end)

-- ============================
--   STATS DECAY SYSTEM
-- ============================

-- Simplified stat decay system
CreateThread(function()
    while true do
        Wait(60 * 1000) -- Run every minute

        -- Only run if Config is loaded
        if Config and Config.StatDecay then
            local hdec = tonumber(Config.StatDecay.hunger or 1) or 1
            local tdec = tonumber(Config.StatDecay.thirst or 1) or 1
            local hldec = tonumber(Config.StatDecay.health or 0.5) or 0.5

            -- Hunger/thirst drop
            MySQL.update(string.format([[
                UPDATE %s
                SET hunger = GREATEST(hunger - ?, 0),
                    thirst = GREATEST(thirst - ?, 0)
                WHERE is_dead = 0
            ]], DB.livestock), { hdec, tdec })

            -- Health decay where needed
            MySQL.update(string.format([[
                UPDATE %s
                SET health = GREATEST(health - ?, 0)
                WHERE is_dead = 0 AND (hunger <= 0 OR thirst <= 0)
            ]], DB.livestock), { hldec })

            -- Mark animals dead (health <= 0)
            MySQL.update(string.format([[
                UPDATE %s SET is_dead = 1 WHERE is_dead = 0 AND health <= 0
            ]], DB.livestock))
        end
    end
end)

-- ============================
--   INITIALIZATION
-- ============================

CreateThread(function()
    Wait(2000) -- Wait for resources to load
    
    print('[animal_farming] Animal Farming system loaded successfully')
    
    -- Test database connection after a delay
    Wait(3000)
    
    local success, result = pcall(function()
        return MySQL.scalar.await('SELECT 1 as test')
    end)
    
    if success and result == 1 then
        print('[animal_farming] Database connection: OK')
    else
        print('[animal_farming] WARNING: Database connection failed - please check your database setup')
    end
end)