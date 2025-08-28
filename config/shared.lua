-- Shared Configuration

return {
    locations = {
        npc = {
            talk   = "Talk to rental manager",
            name   = "Vehicle Rental Manager",
            model  = "s_m_m_trucker_01",
            coords = vec4(130.3860, -3220.2898, 5.8576, 358.0981),
            heading= 0.0,
            icon   = 'fa-solid fa-user-tie',
            debug  = false
        },

        main = {
            label              = 'Truck Shed',
            coords             = vec3(153.0, -3211.68, 5.91),
            size               = vec3(3.0, 3.0, 5.0),
            markerType         = 2,
            markerRadius       = 10.0,
            interactionsRadius = 5.0,
            rotation           = 274.5,
            icon               = 'fa-solid fa-truck',
            debug              = false
        },

        vehicle = {
            label              = 'Truck Storage',
            coords             = vec4(132.4503, -3210.7129, 5.8576, 271.6176),
            size               = vec3(3.0, 3.0, 5.0),
            markerType         = 2,
            markerRadius       = 10.0,
            interactionsRadius = 5.0,
            rotation           = 267.5,
            icon               = 'fa-solid fa-warehouse',
            debug              = false
        }
    },

    deliveries = {
        stores = {
            [1]  = { label='LTD Gasoline (Grove St)', coords=vec3(-41.07, -1747.91, 28.40), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=90.0 },
            [2]  = { label='24/7 Supermarket (Strawberry)', coords=vec3(31.6354, -1315.9624, 28.5229), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=180.0 },
            [3]  = { label='24/7 Supermarket (Clinton Ave)', coords=vec3(383.2124, 327.7420, 102.5664), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=270.0 },
            [4]  = { label='24/7 Supermarket (Innocence Blvd)', coords=vec3(2557.458, 382.282, 107.622), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=45.0 },
            [5]  = { label='24/7 Supermarket (Barbareno Rd)', coords=vec3(-3241.927, 1001.462, 11.830), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=135.0 },
            [6]  = { label='24/7 Supermarket (Route 68)', coords=vec3(549.131, 2671.294, 41.156), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=225.0 },
            [7]  = { label='24/7 Supermarket (Grapeseed)', coords=vec3(1702.6796, 4918.2876, 41.0636), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=315.0 },
            [8]  = { label='24/7 Supermarket (Paleto Bay)', coords=vec3(1738.5829, 6414.3950, 34.0372), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=90.0 },
            [9]  = { label='Rob\'s Liquor (El Rancho)', coords=vec3(1135.808, -982.281, 45.415), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=180.0 },
            [10] = { label='Rob\'s Liquor (San Andreas Ave)', coords=vec3(-1227.2878, -906.3984, 11.3264), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=270.0 },
            [11] = { label='Rob\'s Liquor (Prosperity St)', coords=vec3(-1487.553, -379.107, 39.163), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=45.0 },
            [12] = { label='Rob\'s Liquor (Great Ocean Hwy)', coords=vec3(-2968.243, 390.910, 14.043), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=135.0 },
            [13] = { label='Rob\'s Liquor (Route 68)', coords=vec3(539.7084, 2666.0496, 41.1565), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=225.0 },
            [14] = { label='LTD Gasoline (Mirror Park)', coords=vec3(1163.373, -323.801, 69.205), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=315.0 },
            [15] = { label='LTD Gasoline (Little Seoul)', coords=vec3(-707.501, -914.260, 19.213), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=90.0 },
            [16] = { label='24/7 Supermarket (Banham Canyon)', coords=vec3(-3040.540, 585.954, 7.909), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=180.0 },
            [17] = { label='24/7 Supermarket (Grand Senora Desert)', coords=vec3(1729.216, 6414.131, 35.037), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=270.0 },
            [18] = { label='Liquor Ace (Downtown)', coords=vec3(-1222.915, -906.983, 12.326), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=45.0 },
            [19] = { label='24/7 Supermarket (Harmony)', coords=vec3(547.431, 2671.710, 42.156), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=135.0 },
            [20] = { label='LTD Gasoline (Davis)', coords=vec3(-48.519, -1757.514, 29.421), size=vec3(40,40,5), icon='fa-solid fa-store', debug=false, npcModel='s_m_m_shopkeep_01', rotation=225.0 }
        },

        houses = {
            [1]  = { label='Mansion - Vinewood Hills', coords=vec3(-831.2563, -865.6202, 19.7080), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_fatlatin_01', rotation=45.0 },
            [2]  = { label='House - Rockford Hills', coords=vec3(-1477.1259, -674.4476, 28.0416), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_m_fatwhite_01', rotation=135.0 },
            [3]  = { label='House - West Vinewood', coords=vec3(-933.0837, -383.2635, 37.9613), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_skater_01', rotation=225.0 },
            [4]  = { label='House - Vinewood', coords=vec3(-902.0938, 191.7701, 68.6052), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_hipster_02', rotation=315.0 },
            [5]  = { label='House - Richman', coords=vec3(331.6364, 465.3325, 150.2530), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_eastsa_02', rotation=90.0 },
            [6]  = { label='House - Morningwood', coords=vec3(-230.4044, 487.8981, 127.7681), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_m_eastsa_01', rotation=180.0 },
            [7]  = { label='House - Hollywood Hills', coords=vec3(-112.9455, 985.9448, 234.7543), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_latino_01', rotation=270.0 },
            [8]  = { label='House - West Vinewood', coords=vec3(-765.6406, 650.3317, 144.6974), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_business_02', rotation=0.0 },
            [9]  = { label='House - Vinewood Hills', coords=vec3(-714.6807, 697.2386, 157.2076), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_business_01', rotation=45.0 },
            [10] = { label='House - Strawberry', coords=vec3(427.2119, -1842.1766, 27.4635), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_fitness_01', rotation=135.0 },
            [11] = { label='House - Chamberlandia Hills', coords=vec3(427.1853, -1842.1492, 27.4635), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_fitness_01', rotation=225.0 },
            [12] = { label='House - Burton', coords=vec3(500.5060, -1813.1780, 27.8912), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_m_bevhills_01', rotation=315.0 },
            [13] = { label='House - Burton', coords=vec3(512.5681, -1790.7244, 28.9195), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_bevhills_02', rotation=90.0 },
            [14] = { label='House - El Burro Heights', coords=vec3(1241.4265, -566.4406, 68.6574), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_yoga_01', rotation=180.0 },
            [15] = { label='House - El Burro Heights', coords=vec3(1250.9578, -620.9065, 68.5721), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_yoga_01', rotation=270.0 },
            [16] = { label='House - El Burro Heights', coords=vec3(1265.5613, -648.6990, 67.1214), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_runner_01', rotation=0.0 },
            [17] = { label='House - El Burro Heights', coords=vec3(1271.1799, -683.5729, 65.0316), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_runner_01', rotation=45.0 },
            [18] = { label='House - El Burro Heights', coords=vec3(1264.7527, -702.8154, 63.9090), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_tennis_01', rotation=135.0 },
            [19] = { label='House - El Burro Heights', coords=vec3(1229.6952, -725.3804, 60.9567), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_tennis_01', rotation=225.0 },
            [20] = { label='House - Grove Street', coords=vec3(-831.2563, -865.6202, 19.7080), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_m_fatcult_01', rotation=315.0 },
            [21] = { label='House - Davis', coords=vec3(56.487, -1922.071, 21.910), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_afriamer_01', rotation=90.0 },
            [22] = { label='House - Rancho', coords=vec3(385.808, -1881.065, 26.031), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_m_tramp_01', rotation=180.0 },
            [23] = { label='House - Banning', coords=vec3(918.919, -570.435, 58.366), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_methhead_01', rotation=270.0 },
            [24] = { label='House - Mirror Park', coords=vec3(1051.209, -497.786, 64.081), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_hippie_01', rotation=0.0 },
            [25] = { label='House - East Vinewood', coords=vec3(1138.326, -982.234, 46.415), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_hippy_01', rotation=45.0 },
            [26] = { label='House - Textile City', coords=vec3(422.919, -1625.463, 29.291), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_business_01', rotation=135.0 },
            [27] = { label='House - Little Seoul', coords=vec3(-635.284, -1127.894, 22.165), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_korean_01', rotation=225.0 },
            [28] = { label='House - Del Perro', coords=vec3(-1450.842, -525.466, 35.084), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_beach_01', rotation=315.0 },
            [29] = { label='House - Vespucci', coords=vec3(-1012.525, -1218.778, 5.633), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_beach_01', rotation=90.0 },
            [30] = { label='House - Pacific Bluffs', coords=vec3(-3086.428, 339.252, 6.371), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_runner_01', rotation=180.0 },
            [31] = { label='House - Chumash', coords=vec3(-3192.713, 1063.617, 20.863), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_surfer_01', rotation=270.0 },
            [32] = { label='House - Paleto Bay', coords=vec3(-360.890, 6207.386, 31.840), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_m_hillbilly_01', rotation=0.0 },
            [33] = { label='House - Grapeseed', coords=vec3(1662.174, 4776.927, 42.008), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_m_hillbilly_01', rotation=45.0 },
            [34] = { label='House - Sandy Shores', coords=vec3(1971.282, 3815.584, 33.436), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_m_y_mexthug_01', rotation=135.0 },
            [35] = { label='House - Harmony', coords=vec3(1207.727, 2666.040, 37.899), size=vec3(25,25,5), icon='fa-solid fa-house', debug=false, npcModel='a_f_y_soucent_01', rotation=225.0 }
        }
    },

    vehicles = {
        [GetHashKey('rumpo')] = 'Dumbo Delivery Van',
        [GetHashKey('pony')] = 'Pony Van',
        [GetHashKey('mule')] = 'Mule Truck'
    },

    job = {
        name  = 'trucker',
        label = 'Trucker'
    },

    payment = {
        base        = 250,   -- base pay per drop
        bonusPerBox = 30,   -- bonus per extra box
        maxBoxes    = 10,    -- max boxes delivered per stop
        deposit     = 100,  -- deposit for vehicle rental
        multipliers = {
            store = 2.0,     -- normal rate
            house = .9       -- houses pay 10% less
        }
    },

    truckDoors = {
        [GetHashKey('mule')]      = {2,3,5},
        [GetHashKey('mule2')]     = {2,3,5},
        [GetHashKey('mule3')]     = {2,3,5},
        [GetHashKey('benson')]    = {2,3,5},
        [GetHashKey('pounder')]   = {2,3,5},
        [GetHashKey('pounder2')]  = {2,3,5},
        [GetHashKey('boxville')]  = {2,3,5},
        [GetHashKey('boxville2')] = {2,3,5},
        [GetHashKey('boxville3')] = {2,3,5},
        [GetHashKey('boxville4')] = {2,3,5},
        [GetHashKey('rumpo')]     = {2,3,5},
        [GetHashKey('pony')]      = {2,3,5}
    },

    boxGrab = {
        maxDistance  = 3.0,
        grabTime     = 20000,   -- ms
        deliveryTime = 30000,   -- ms
        timeout      = 300000  -- ms (5 minutes)
    },

    useTarget = true,
    debug     = true,

    animations = {
        grabBox    = { dict = 'anim@gangops@facility@servers@', clip = 'hotwire' },
        deliverBox = { dict = 'anim@gangops@facility@servers@', clip = 'hotwire' },
        boxEmote   = 'box',
        npcPickupBox = { dict = 'anim@heists@box_carry@', clip = 'idle' }
    }
}