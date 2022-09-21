local time_to_wait = 0.1
local time_to_wait_inventory = 1.2

local _P = FindMetaTable("Player")

hook.Add("PlayerInitialSpawn", "InitInv", function (ply)
    ply.time_respawn = 0
    ply.pressed = false
    ply.time_press = 0
    ply.entity_looked = nil
    ply.carrying = false
    ply.give_menu = false
end)

hook.Add("PlayerSpawn", "PlayerSpawn", function(ply)
    ply.time_respawn = CurTime()
end)

hook.Add("KeyPress", "KeyPress", function(ply, key)
    ply.entity_looked = ply:GetEyeTrace().Entity
	if key == IN_USE and IsValid(ply.entity_looked) then
        ply.time_press = CurTime()
		ply.pressed = true
	end
end)

hook.Add( "KeyRelease", "KeyRelease", function( ply, key )
    if key == IN_USE then
        ply.pressed = false
    end
end )

hook.Add("PlayerCanPickupWeapon", "CanPickup", function(ply, weapon)
    if not config.pickup then return end
    
    if ply.time_respawn == CurTime() then 
        return true 
    end

    if (ply.give_menu) then
        ply.give_menu = false
        return true  
    end

    if ply.entity_looked != weapon or not IsValid(weapon) or not ply.carrying then
        return false
    end

    if not ply.pressed and CurTime() - ply.time_press < time_to_wait then
        if (config.can_take_same_weapon or (not config.can_take_same_weapon and not ply:HasWeapon(weapon:GetClass()))) then
            ply.time_press = 0
            return true 
        end
        return false
    end

    if ply.pressed and CurTime() - ply.time_press > time_to_wait_inventory and config.long_time_use then
        ply.time_press = CurTime()
        InvTakeWeapon(ply, weapon)
    end
    return false
end)

hook.Add( "AllowPlayerPickup", "AllowPickUp", function( ply, ent )
    ply.carrying = IsValid(ply:GetEyeTrace().Entity)
    return ply.carrying
end)

hook.Add( "OnPlayerPhysicsDrop", "OnEntityDrop", function( ply, ent, thrown )
    ply.carrying = false
end)

hook.Add( "PlayerGiveSWEP", "giveWeapon", function( ply, weapon, swep )
    print("aaaaaa")
    if not ply:HasWeapon(weapon) then ply.give_menu = true end
end)

hook.Add("PlayerCanPickupItem", "CanPickup", function(ply, ent)
    if config.pickup then
        if (ply.give_menu) then
            ply.give_menu = false
            return true 
        end

        if not IsValid(ent) or ply.entity_looked != ent then 
            return false 
        end

        if not ply.carrying then
            return false
        end

        if not ply.pressed and CurTime() - ply.time_press < time_to_wait then
            ply.time_press = 0
            return true 
        end

        if ply.pressed and CurTime() - ply.time_press > time_to_wait_inventory then
            ply.time_press = CurTime()
            InvTakeEntity(ply, ent)
        end

        return false
    end
end)