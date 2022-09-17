config = config or {}

// Max place in inventory ( -1 = no limit )
config.max = -1

// default button to open the inventory
config.key_open = KEY_I

// default button to take a weapon or entity
config.key_take = KEY_T

if CLIENT then
    // size of one case
    config.size = 125

    // number case inventory by line
    config.number_case_by_line = 0

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
    config.pickup = true

    // press for a long time to Use Button placed on the inventory
    config.long_time_use = true

    // timer to wait when he press to the button for take
    config.timer_take = 0

    // distance to take (default = 0.25)
    config.distance = 0.25

    // Allow message send to the player
    config.message = true

    // if player can take entity
    config.can_take_entity = true 

    // if player can take weapon
    config.can_take_weapon = true 

    // if play can take two same weapon in hot bar weapon
    config.can_take_same_weapon = true 

    // Blacklist weapon in inventory by classname
    // ex: config.blacklist_weapon = {"weapon_357", "weapon_crossbow"}
    config.blacklist_weapon = {""}

    // Blacklist entity in inventory by classname
    config.blacklist_entity = {""}

end
