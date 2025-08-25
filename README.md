# Animal Farming System for FiveM

A comprehensive and advanced animal farming system for FiveM servers using QBX Core, ox_lib, ox_inventory, and ox_target.

## Features

### 🏡 Farm Management
- **Farmlot System**: Purchase and manage different types of farm lots
- **Multiple Animal Types**: Cows, Chickens, and Pigs with unique behaviors
- **Water Trough System**: Automated hydration for animals
- **Lot Restrictions**: Animal-specific lot requirements

### 🐄 Animal Care
- **Realistic Stats**: Health, Hunger, and Thirst systems
- **Feeding System**: Progressive feeding with quality bonuses
- **Stat Decay**: Time-based stat degradation
- **Animal Behavior**: Dynamic behavior based on animal condition
- **Death System**: Animals can die from neglect

### 📦 Production System
- **Quality-Based Production**: Animal condition affects product quality
- **Cooldown System**: Realistic production timers
- **Gender-Specific Production**: Some products require specific genders
- **Skill-Based Butchering**: Better skills yield more resources

### 💼 Economic Features
- **Transaction Logging**: Complete financial tracking
- **Product Quality**: Higher quality animals produce better items
- **Market Integration**: Works with ox_inventory
- **Bulk Operations**: Feed multiple animals at once

### 🎮 User Interface
- **Intuitive Menus**: ox_lib integration for clean UIs
- **Real-Time Stats**: Live animal status displays
- **Interactive NPCs**: Purchase lots and animals from vendors
- **Target System**: ox_target integration for interactions

## Installation

### Prerequisites
- QBX Core (or QB-Core compatible)
- ox_lib
- ox_inventory
- ox_target
- oxmysql

### Setup Steps

1. **Download and Install**
   ```bash
   cd resources
   git clone [repository-url] animal_farming
   ```

2. **Database Setup**
   - Import the `database.sql` file into your MySQL database
   - Ensure the items are added to your ox_inventory items table

3. **Configuration**
   - Edit `config.lua` to match your server settings
   - Update NPC coordinates and prices
   - Adjust animal stats and production rates

4. **Add to server.cfg**
   ```
   ensure animal_farming
   ```

5. **Restart Server**

## Configuration

### Animal Types
```lua
Config.Animals = {
    cow = {
        label = 'Cow',
        model = `a_c_cow`,
        price = 5000,
        femaleChance = 50,
        -- ... more settings
    }
}
```

### NPC Locations
```lua
Config.FarmlotSellers = {
    {
        model = `a_m_m_farmer_01`,
        coords = vector4(x, y, z, heading),
        lotType = 'cow',
        price = 25000
    }
}
```

### Database Tables
- `animal_farmlots` - Farm lot ownership
- `animal_livestock` - Animal data and stats
- `animal_water_troughs` - Water trough locations
- `animal_transactions` - Financial logging
- `animal_production_log` - Production history
- `animal_death_log` - Death tracking

## Usage

### For Players

1. **Purchase a Farmlot**
   - Find a farmlot seller NPC
   - Choose the type of lot you want
   - Pay the required amount

2. **Buy Animals**
   - Visit an animal vendor
   - Select the animal type
   - Choose which lot to place it on

3. **Care for Animals**
   - Feed animals regularly with animal feed
   - Ensure they have access to water
   - Monitor their health, hunger, and thirst

4. **Collect Products**
   - Interact with healthy animals to collect products
   - Quality depends on animal condition
   - Products have cooldown periods

5. **Butcher Animals**
   - Dead animals can be butchered for meat
   - Skill-based yield system
   - Requires a knife

### Commands

- `/af_list` - List your animals
- `/af_stats` - Check animal statistics (WIP)

## API

### Client Events
```lua
-- Spawn an animal
TriggerClientEvent('animal_farming:client:spawnAnimal', source, data)

-- Update animal stats
TriggerClientEvent('animal_farming:client:updateStats', source, animalId, stats)

-- Despawn an animal
TriggerClientEvent('animal_farming:client:despawnAnimal', source, animalId)
```

### Server Callbacks
```lua
-- Get player's farmlots
lib.callback.await('animal_farming:server:getFarmlots', source)

-- Get player's animals
lib.callback.await('animal_farming:server:getAnimals', source, filter)

-- Feed an animal
lib.callback.await('animal_farming:server:feedAnimal', source, animalId)
```

## Items Required

### Tools & Feed
- `animal_feed` - Basic animal food
- `knife` - Required for butchering
- `bucket` - For water management

### Products
- `milk` - From female cows
- `eggs` - From chickens
- `raw_pork` - From pigs
- `raw_beef` - From butchered cows
- `raw_chicken` - From butchered chickens

## Troubleshooting

### Common Issues

1. **Animals not spawning**
   - Check that the animal models exist
   - Verify database connection
   - Check console for errors

2. **Database errors**
   - Ensure all tables are created properly
   - Check MySQL user permissions
   - Verify oxmysql is working

3. **Inventory issues**
   - Confirm ox_inventory is running
   - Check that items exist in the database
   - Verify item weights and metadata

### Debug Mode
Enable debug mode in `config.lua`:
```lua
Config.Debug = true
```

This will provide detailed console output for troubleshooting.

## Performance

### Optimization Features
- Efficient database queries with proper indexing
- Minimal client-server communication
- Optimized stat decay system
- Automatic cleanup procedures

### Recommended Settings
- Max 10 animals per lot
- Max 5 lots per player
- 60-second stat decay intervals

## Development

### Adding New Animals
1. Add to `Config.Animals` table
2. Define model, stats, and products
3. Add production logic if needed
4. Update database yields for butchering

### Custom Events
The system fires various events that can be hooked:
- Animal spawning/despawning
- Stat updates
- Production events
- Death events

## Support

### Requirements
- FiveM Server
- MySQL/MariaDB Database
- Required dependencies (listed above)

### Known Limitations
- Animal pathfinding is basic GTA AI
- Limited to 3 animal types currently
- Requires ox_inventory for items

## License

This resource is provided as-is for educational and server use. Please respect the licensing terms of all dependencies.

## Credits

- Built for QBX/QB-Core frameworks
- Uses ox_lib, ox_inventory, ox_target
- Inspired by various farming systems

---

For support, please check the documentation or create an issue on the repository.