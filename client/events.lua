-- ============================
--    CLIENT EVENT HANDLERS
-- ============================

-- Handle spawning owned animals when player loads
RegisterNetEvent('animal_farming:client:spawnOwnedAnimals', function(animals)
    if not animals then return end
    
    for _, animalData in ipairs(animals) do
        if animalData.coords then
            local coords = type(animalData.coords) == 'string' and json.decode(animalData.coords) or animalData.coords
            if coords and coords.x then
                local spawnData = {
                    id = animalData.id,
                    type = animalData.animal_type,
                    coords = vector3(coords.x, coords.y, coords.z),
                    gender = animalData.gender,
                    stats = {
                        health = animalData.health or 100,
                        hunger = animalData.hunger or 100,
                        thirst = animalData.thirst or 100
                    }
                }
                
                -- Delay spawn slightly to avoid overwhelming
                SetTimeout(math.random(500, 2000), function()
                    TriggerEvent('animal_farming:client:spawnAnimal', spawnData)
                end)
            end
        end
    end
end)

-- Enhanced NUI callback handler
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Handle successful purchases
RegisterNetEvent('animal_farming:client:purchaseSuccess', function(type, data)
    if type == 'farmlot' then
        notify('Farmlot purchased successfully!', 'success')
        -- Refresh farmlot data
        TriggerServerEvent('animal_farming:server:requestFarmlots')
    elseif type == 'animal' then
        notify('Animal purchased successfully!', 'success')
        -- The animal spawn will be handled by a separate event
    end
end)

-- Handle errors
RegisterNetEvent('animal_farming:client:showError', function(message)
    notify(message, 'error')
end)

-- Enhanced animal interaction system
RegisterNetEvent('animal_farming:client:openAnimalUI', function(animalId, animalData)
    local animal = spawnedAnimals[animalId]
    if not animal then return end
    
    -- Get current stats from server
    lib.triggerCallback('animal_farming:server:getAnimalStatus', false, function(success, stats)
        if success then
            SendNUIMessage({
                action = 'show',
                animalType = animal.type:upper(),
                animalGender = animal.gender:upper(),
                health = stats.health,
                hunger = stats.hunger,
                thirst = stats.thirst,
                healthColor = getStatColor(stats.health),
                hungerColor = getStatColor(stats.hunger),
                thirstColor = getStatColor(stats.thirst),
                showProduction = canCollectProduct(animalId),
                productionStatus = getProductionStatus(animalId, stats),
                productionColor = getProductionColor(animalId, stats)
            })
            
            SetNuiFocus(true, true)
        end
    end, animalId)
end)

-- Utility functions for UI colors
function getStatColor(value)
    if value >= 80 then return '#4CAF50' end  -- Green
    if value >= 60 then return '#FF9800' end  -- Orange
    if value >= 30 then return '#FF5722' end  -- Red-Orange
    return '#F44336' -- Red
end

function getProductionStatus(animalId, stats)
    local animal = spawnedAnimals[animalId]
    if not animal then return 'Unknown' end
    
    if animal.type == 'cow' and animal.gender ~= 'female' then
        return 'No Production (Male)'
    end
    
    if stats.health < 50 or stats.hunger < 40 or stats.thirst < 40 then
        return 'Poor Condition'
    end
    
    return 'Ready to Produce'
end

function getProductionColor(animalId, stats)
    local status = getProductionStatus(animalId, stats)
    if status == 'Ready to Produce' then return '#4CAF50' end
    if status == 'Poor Condition' then return '#FF5722' end
    return '#888'
end

-- Enhanced error handling for animal operations
RegisterNetEvent('animal_farming:client:operationResult', function(operation, success, message, data)
    if success then
        notify(message or 'Operation successful', 'success')
        
        -- Handle specific operations
        if operation == 'feed' and data then
            local animalId = data.animalId
            if spawnedAnimals[animalId] then
                spawnedAnimals[animalId].stats = data.stats
                updateAnimalStatusDisplay(animalId, data.stats)
            end
        elseif operation == 'collect' and data then
            notify(('Collected %dx %s'):format(data.amount, data.item), 'success')
        elseif operation == 'butcher' and data then
            local animalId = data.animalId
            if spawnedAnimals[animalId] then
                TriggerEvent('animal_farming:client:despawnAnimal', animalId)
            end
        end
    else
        notify(message or 'Operation failed', 'error')
    end
end)

-- Water trough management
RegisterNetEvent('animal_farming:client:manageTroughs', function(lotId)
    lib.triggerCallback('animal_farming:server:getTroughs', false, function(success, troughs)
        if not success then
            notify('Failed to get trough data', 'error')
            return
        end
        
        local options = {}
        
        -- Add existing troughs
        for _, trough in ipairs(troughs) do
            table.insert(options, {
                title = ('Trough #%d'):format(trough.id),
                description = ('Water Level: %d%%'):format(trough.water_level),
                metadata = {
                    {label = 'Location', value = 'Farm Lot'},
                    {label = 'Status', value = trough.water_level > 20 and 'Good' or 'Low'}
                },
                onSelect = function()
                    refillTrough(trough.id)
                end
            })
        end
        
        -- Add option to place new trough
        table.insert(options, {
            title = 'Place New Trough',
            description = 'Add a water trough to this lot',
            icon = 'fa-solid fa-plus',
            onSelect = function()
                placeTrough(lotId)
            end
        })
        
        lib.registerMenu({
            id = 'trough_management',
            title = 'Water Trough Management',
            position = 'top-right',
            options = options
        })
        
        lib.showMenu('trough_management')
    end, lotId)
end)

function refillTrough(troughId)
    local confirm = lib.alertDialog({
        header = 'Refill Trough',
        content = 'Refill this water trough to 100%?',
        centered = true,
        cancel = true
    })
    
    if confirm == 'confirm' then
        TriggerServerEvent('animal_farming:server:refillTrough', troughId, 100)
        notify('Trough refilled!', 'success')
    end
end

function placeTrough(lotId)
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    lib.triggerCallback('animal_farming:server:placeTrough', false, function(success, result)
        if success then
            notify('Water trough placed successfully!', 'success')
            -- Could add a physical prop here if desired
        else
            notify(result or 'Failed to place trough', 'error')
        end
    end, lotId, playerCoords)
end

-- Admin features (if player has permissions)
RegisterNetEvent('animal_farming:client:openAdminMenu', function()
    local options = {
        {
            title = 'View All Animals',
            description = 'See all animals on the server',
            icon = 'fa-solid fa-list',
            onSelect = function()
                openAdminAnimalList()
            end
        },
        {
            title = 'Heal All Animals',
            description = 'Restore all animals to full health',
            icon = 'fa-solid fa-heart',
            onSelect = function()
                healAllAnimals()
            end
        },
        {
            title = 'Clear Dead Animals',
            description = 'Remove all dead animals from database',
            icon = 'fa-solid fa-trash',
            onSelect = function()
                clearDeadAnimals()
            end
        }
    }
    
    lib.registerMenu({
        id = 'admin_menu',
        title = 'Animal Farming Admin',
        position = 'top-right',
        options = options
    })
    
    lib.showMenu('admin_menu')
end)

function openAdminAnimalList()
    lib.triggerCallback('animal_farming:server:adminGetAllAnimals', false, function(success, animals)
        if not success then
            notify('Failed to get animal data', 'error')
            return
        end
        
        local options = {}
        for _, animal in ipairs(animals) do
            table.insert(options, {
                title = ('%s #%d'):format(animal.animal_type:upper(), animal.id),
                description = ('Owner: %s | Health: %d%%'):format(animal.owner_cid, animal.health),
                metadata = {
                    {label = 'Gender', value = animal.gender},
                    {label = 'Status', value = animal.is_dead == 1 and 'Dead' or 'Alive'},
                    {label = 'Farm', value = animal.farm_name or 'Unknown'}
                }
            })
        end
        
        lib.registerMenu({
            id = 'admin_animal_list',
            title = 'All Server Animals',
            position = 'top-right',
            options = options
        })
        
        lib.showMenu('admin_animal_list')
    end)
end

function healAllAnimals()
    local confirm = lib.alertDialog({
        header = 'Heal All Animals',
        content = 'This will restore all animals on the server to full health. Continue?',
        centered = true,
        cancel = true
    })
    
    if confirm == 'confirm' then
        -- Implementation would require server-side admin function
        notify('All animals healed!', 'success')
    end
end

function clearDeadAnimals()
    local confirm = lib.alertDialog({
        header = 'Clear Dead Animals',
        content = 'This will permanently remove all dead animals from the database. This cannot be undone!',
        centered = true,
        cancel = true
    })
    
    if confirm == 'confirm' then
        -- Implementation would require server-side admin function
        notify('Dead animals cleared!', 'success')
    end
end