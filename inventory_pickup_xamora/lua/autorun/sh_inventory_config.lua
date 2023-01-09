config = config or {}

// Max place in inventory ( -1 = no limit )
config.max = -1

// default button to open the inventory
config.key_open = KEY_I

// default button to take a weapon or entity
config.key_take = KEY_T

if CLIENT then
    // if size of case is relative (same size for all screen)
    config.relative_item = true 
    // if relative_item is "true", what size you want ? (default = 1.2)
    config.relative_size = 1.2

    // size of one case if relative_item is false
    config.size = 125

    // start x case
    config.x_item = 0

    // start y case
    config.y_item = 0

    // gap between each case in x
    config.gap_x = 10

    // gap between each case in y
    config.gap_y = 20

elseif SERVER then
    // System pickup allow
    config.pickup = false

    // press for a long time to Use Button placed on the inventory
    config.long_time_use = true
 
    // timer to wait when he press to the button for take
    config.timer_take = 0

    // distance to take (default = 0.25)
    config.distance = 0.25

    // distance to drop (default = 65)
    config.distance_drop = 65

    // Allow message send to the player
    config.message = true

    // if player die his inventory is drop
    config.keep_inventory = true
    // if keep_inventory is false, drop the inventory
    config.drop_inventory = true
    config.model_inventory = "models/props_c17/suitcase001a.mdl"
    // if you change the model you maybe need to increase or reduce this
    config.height_spawn = 10

    // if player can take entity
    config.can_take_entity = true 

    // if player can take weapon
    config.can_take_weapon = true 

    // if play can take two same weapon in hot bar weapon
    config.can_take_same_weapon = true 

    // Blacklist weapon in inventory by classname
    // ex: config.blacklist_weapon = {"weapon_357", "weapon_crossbow"}
    config.blacklist_weapon = {"weapon_physgun", "gmod_tool", "weapon_fists", "gmod_camera"}

    // Blacklist entity in inventory by classname
    config.blacklist_entity = {""}

end