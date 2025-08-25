-- ============================
--      SERVER UTILITIES
-- ============================

-- Enhanced player validation
local function validatePlayer(source)
    local player = getPlayer(source)
    if not player then
        debugPrint('Invalid player for source:', source)
        return nil
    end
    
    if not player.PlayerData or not player.PlayerData.citizenid then
        debugPrint('Player missing citizenid:', source)
        return nil
    end
    
    return player
end

-- Database connection test
local function testDatabaseConnection()
    local success = pcall(function()
        local result = oxmysql:scalarSync('SELECT 1 as test')
        return result == 1
    end)
    
    if success then
        debugPrint('Database connection: OK')
        return true
    else
        print('[animal_farming] ERROR: Database connection failed!')
        return false
    end
end

-- Animal validation helpers
local function validateAnimalOwnership(animalId, citizenid)
    local rows = oxmysql:executeSync(string.format([[
        SELECT owner_cid FROM %s WHERE id = ?
    ]], DB.livestock), { animalId })
    
    if not rows or not rows[1] then
        return false, 'Animal not found'
    end
    
    if rows[1].owner_cid ~= citizenid then
        return false, 'Not the owner'
    end
    
    return true
end

local function getAnimalData(animalId)
    local rows = oxmysql:executeSync(string.format([[
        SELECT * FROM %s WHERE id = ?
    ]], DB.livestock), { animalId })
    
    return rows and rows[1] or nil
end

-- Lot validation helpers
local function validateLotOwnership(lotId, citizenid)
    local rows = oxmysql:executeSync(string.format([[
        SELECT citizenid FROM %s WHERE id = ?
    ]], DB.farmlots), { lotId })
    
    if not rows or not rows[1] then
        return false, 'Lot not found'
    end
    
    if rows[1].citizenid ~= citizenid then
        return false, 'Not the lot owner'
    end
    
    return true
end

-- Item management helpers
local function giveItemWithMetadata(source, item, amount, metadata)
    local success = exports.ox_inventory:AddItem(source, item, amount, metadata or {})
    if not success then
        debugPrint('Failed to give item:', item, 'to player:', source)
    end
    return success
end

local function removeItemFromPlayer(source, item, amount)
    local success = exports.ox_inventory:RemoveItem(source, item, amount)
    if not success then
        debugPrint('Failed to remove item:', item, 'from player:', source)
    end
    return success
end

local function checkPlayerHasItem(source, item, amount)
    local count = exports.ox_inventory:GetItem(source, item, false, true) or 0
    return count >= (amount or 1)
end

-- Stats calculation helpers
local function calculateProductionQuality(health, hunger, thirst)
    local baseQuality = (health * 0.6 + hunger * 0.2 + thirst * 0.2) / 100
    return math.min(1.0, math.max(0.1, baseQuality))
end

local function calculateSkillMultiplier(skillLevel)
    local level = tonumber(skillLevel or 0) or 0
    return math.min(2.0, 1.0 + (level * 0.1))
end

local function getAnimalCondition(health, hunger, thirst)
    if health <= 0 then return 'dead' end
    if health < 30 then return 'critical' end
    if health < 60 then return 'sick' end
    if hunger < 30 or thirst < 30 then return 'neglected' end
    if health >= 80 and hunger >= 70 and thirst >= 70 then return 'excellent' end
    return 'healthy'
end

-- Economic helpers
local function logTransaction(citizenid, transactionType, refId, animalType, amount, metadata)
    oxmysql:insert(string.format([[
        INSERT INTO %s (citizenid, `type`, ref_id, animal_type, amount, meta)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], DB.transactions), {
        citizenid, transactionType, refId, animalType, amount, encode(metadata or {})
    })
end

local function processPayment(player, amount, reason)
    if amount <= 0 then return true end
    
    local success = player.Functions.RemoveMoney('cash', amount, reason)
    if not success then
        success = player.Functions.RemoveMoney('bank', amount, reason)
    end
    
    return success
end

local function givePayment(player, amount, reason)
    if amount <= 0 then return true end
    
    return player.Functions.AddMoney('cash', amount, reason)
end

-- Cooldown management
local function checkCooldown(lastAction, cooldownSeconds)
    if not lastAction then return true end
    
    local secondsSince = oxmysql:scalarSync('SELECT TIMESTAMPDIFF(SECOND, ?, NOW())', { lastAction }) or 0
    return secondsSince >= cooldownSeconds
end

local function getRemainingCooldown(lastAction, cooldownSeconds)
    if not lastAction then return 0 end
    
    local secondsSince = oxmysql:scalarSync('SELECT TIMESTAMPDIFF(SECOND, ?, NOW())', { lastAction }) or 0
    return math.max(0, cooldownSeconds - secondsSince)
end

-- Data validation
local function validateCoords(coords)
    if not coords then return false end
    if type(coords) ~= 'table' then return false end
    if not coords.x or not coords.y or not coords.z then return false end
    return true
end

local function sanitizeString(str, maxLength)
    if not str or type(str) ~= 'string' then return '' end
    str = string.gsub(str, '[<>"\']', '') -- Remove potentially harmful characters
    if maxLength then
        str = string.sub(str, 1, maxLength)
    end
    return str
end

-- Batch operations
local function batchUpdateAnimalStats(animalIds, statUpdates)
    if not animalIds or #animalIds == 0 then return 0 end
    
    local query = string.format([[
        UPDATE %s SET %s WHERE id IN (%s)
    ]], DB.livestock, 
    table.concat(statUpdates, ', '),
    table.concat(animalIds, ','))
    
    return oxmysql:update(query)
end

-- Admin utilities
local function isPlayerAdmin(source)
    -- This should be replaced with your actual admin check
    -- return IsPlayerAceAllowed(source, 'animal_farming.admin')
    return true -- Temporary - replace with actual admin check
end

local function getServerStatistics()
    local stats = {}
    
    -- Total animals
    stats.totalAnimals = oxmysql:scalarSync(string.format('SELECT COUNT(*) FROM %s', DB.livestock)) or 0
    
    -- Animals by type
    local animalTypes = oxmysql:executeSync(string.format([[
        SELECT animal_type, COUNT(*) as count 
        FROM %s 
        GROUP BY animal_type
    ]], DB.livestock)) or {}
    
    stats.animalsByType = {}
    for _, row in ipairs(animalTypes) do
        stats.animalsByType[row.animal_type] = row.count
    end
    
    -- Active players
    stats.activePlayers = oxmysql:scalarSync(string.format([[
        SELECT COUNT(DISTINCT owner_cid) FROM %s WHERE is_dead = 0
    ]], DB.livestock)) or 0
    
    -- Production in last 24h
    stats.productionLast24h = oxmysql:scalarSync(string.format([[
        SELECT COUNT(*) FROM %s WHERE produced_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    ]], DB.production_log)) or 0
    
    return stats
end

-- Performance monitoring
local performanceMetrics = {
    dbQueries = 0,
    avgQueryTime = 0,
    lastReset = os.time()
}

local function trackQuery(startTime)
    local endTime = os.clock()
    local queryTime = endTime - startTime
    
    performanceMetrics.dbQueries = performanceMetrics.dbQueries + 1
    performanceMetrics.avgQueryTime = (performanceMetrics.avgQueryTime + queryTime) / 2
    
    if Config.Debug then
        debugPrint(('Query completed in %.2fms'):format(queryTime * 1000))
    end
end

local function resetMetrics()
    performanceMetrics.dbQueries = 0
    performanceMetrics.avgQueryTime = 0
    performanceMetrics.lastReset = os.time()
end

-- Export utilities for use in other files
_G.AnimalFarmingUtils = {
    validatePlayer = validatePlayer,
    testDatabaseConnection = testDatabaseConnection,
    validateAnimalOwnership = validateAnimalOwnership,
    getAnimalData = getAnimalData,
    validateLotOwnership = validateLotOwnership,
    giveItemWithMetadata = giveItemWithMetadata,
    removeItemFromPlayer = removeItemFromPlayer,
    checkPlayerHasItem = checkPlayerHasItem,
    calculateProductionQuality = calculateProductionQuality,
    calculateSkillMultiplier = calculateSkillMultiplier,
    getAnimalCondition = getAnimalCondition,
    logTransaction = logTransaction,
    processPayment = processPayment,
    givePayment = givePayment,
    checkCooldown = checkCooldown,
    getRemainingCooldown = getRemainingCooldown,
    validateCoords = validateCoords,
    sanitizeString = sanitizeString,
    batchUpdateAnimalStats = batchUpdateAnimalStats,
    isPlayerAdmin = isPlayerAdmin,
    getServerStatistics = getServerStatistics,
    trackQuery = trackQuery,
    resetMetrics = resetMetrics
}

-- Initialize utilities
CreateThread(function()
    Wait(1000)
    
    if testDatabaseConnection() then
        debugPrint('Animal Farming utilities initialized successfully')
    else
        print('[animal_farming] ERROR: Failed to initialize utilities - database connection failed')
    end
    
    -- Reset performance metrics every hour
    while true do
        Wait(60 * 60 * 1000) -- 1 hour
        resetMetrics()
        debugPrint('Performance metrics reset')
    end
end)