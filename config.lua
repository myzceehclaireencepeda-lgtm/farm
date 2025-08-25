Config = {}

-- ============================
--        GENERAL SETTINGS
-- ============================
Config.Debug = true
Config.ShowAnimalStatus = true
Config.FeedItem = 'animal_feed'

-- ============================
--        FARM LIMITS
-- ============================
Config.MaxFarmlotsPerPlayer = 5
Config.MaxAnimalsPerLot = 10
Config.MaxTroughsPerLot = 3

-- ============================
--        ANIMALS CONFIG
-- ============================
Config.Animals = {
    cow = {
        label = 'Cow',
        model = `a_c_cow`,
        price = 5000,
        femaleChance = 50, -- 50% chance to be female
        wanderDistance = 15.0,
        blip = 141,
        lotRestricted = true, -- Must be placed on cow lots only
        feedingBonus = 1.2, -- 20% bonus to feeding effects
        stats = {
            health = 100,
            hunger = 100,
            thirst = 100
        },
        products = {
            female = {
                milk = {
                    item = 'milk',
                    minYield = 1,
                    maxYield = 3,
                    cooldown = 3 * 24 * 60 * 60 -- 3 days in seconds
                }
            }
        }
    },
    chicken = {
        label = 'Chicken',
        model = `a_c_hen`,
        price = 500,
        femaleChance = 70, -- 70% chance to be female
        wanderDistance = 8.0,
        blip = 141,
        lotRestricted = true,
        feedingBonus = 1.0,
        stats = {
            health = 80,
            hunger = 90,
            thirst = 90
        },
        products = {
            eggs = {
                item = 'eggs',
                minYield = 1,
                maxYield = 2,
                cooldown = 30 * 60 -- 30 minutes
            }
        }
    },
    pig = {
        label = 'Pig',
        model = `a_c_pig`,
        price = 2000,
        femaleChance = 40, -- 40% chance to be female
        wanderDistance = 12.0,
        blip = 141,
        lotRestricted = true,
        feedingBonus = 1.1,
        stats = {
            health = 100,
            hunger = 100,
            thirst = 100
        },
        products = {
            meat = {
                item = 'raw_pork',
                minYield = 1,
                maxYield = 2,
                cooldown = 2 * 60 * 60 -- 2 hours
            }
        }
    }
}

-- ============================
--        NPC LOCATIONS
-- ============================
Config.FarmlotSellers = {
    {
        model = `a_m_m_farmer_01`,
        coords = vector4(0.0, 0.0, 0.0, 0.0), -- Replace with actual coordinates
        lotType = 'cow',
        price = 25000
    },
    {
        model = `a_m_m_farmer_01`,
        coords = vector4(0.0, 0.0, 0.0, 0.0), -- Replace with actual coordinates
        lotType = 'chicken',
        price = 15000
    },
    {
        model = `a_m_m_farmer_01`,
        coords = vector4(0.0, 0.0, 0.0, 0.0), -- Replace with actual coordinates
        lotType = 'pig',
        price = 20000
    }
}

Config.AnimalVendors = {
    {
        model = `a_m_m_farmer_01`,
        coords = vector4(0.0, 0.0, 0.0, 0.0), -- Replace with actual coordinates
    }
}

-- ============================
--        FEEDING SYSTEM
-- ============================
Config.Feeding = {
    hungerBoost = 40, -- Base hunger increase
    healthBoost = 10, -- Base health increase
    animationTime = 5000 -- Animation duration in ms
}

-- ============================
--        REQUIREMENTS
-- ============================
Config.Requirements = {
    minHealth = 50, -- Minimum health for production
    minHunger = 40, -- Minimum hunger for production
    minThirst = 40  -- Minimum thirst for production
}

-- ============================
--        STAT DECAY
-- ============================
Config.StatDecay = {
    hunger = 1,     -- Hunger decrease per minute
    thirst = 1,     -- Thirst decrease per minute
    health = 0.5    -- Health decrease per minute (when hungry/thirsty)
}

-- ============================
--        WATER TROUGH SYSTEM
-- ============================
Config.WaterTrough = {
    enabled = true,
    hydrationBoost = 5,    -- Thirst increase per tick
    tickInterval = 60,     -- Tick every 60 seconds
    maxWaterLevel = 100,   -- Maximum water level
    decayRate = 1          -- Water level decrease per tick
}

-- ============================
--        BUTCHERING SYSTEM
-- ============================
Config.Butchering = {
    requiredItem = 'knife',
    yields = {
        cow = {
            item = 'raw_beef',
            min = 3,
            max = 8
        },
        chicken = {
            item = 'raw_chicken',
            min = 1,
            max = 3
        },
        pig = {
            item = 'raw_pork',
            min = 2,
            max = 5
        }
    }
}

-- ============================
--        DATABASE CONFIG
-- ============================
Config.Database = {
    farmlots = "animal_farmlots",
    livestock = "animal_livestock",
    water = "animal_water_troughs",
    transactions = "animal_transactions",
    production_log = "animal_production_log",
    death_log = "animal_death_log"
}

-- ============================
--        UI SETTINGS
-- ============================
Config.UI = {
    showAnimalBlips = true,
    showFarmlotBlips = true,
    statusUpdateInterval = 30000, -- 30 seconds
    maxInteractionDistance = 3.0
}