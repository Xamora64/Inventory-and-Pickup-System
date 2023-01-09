local time_to_wait = 0.1
local time_to_wait_inventory = 1.2

local _P = FindMetaTable("Player")

function _P:Give(classname)
	local ent = ents.Create(classname)
	if not IsValid(ent) then return end
    timer.Simple(0.01, function()
        ent:SetPos(self:GetPos())
        ent.GiveTo = self
        ent:Spawn()
        timer.Simple(0.01, function() self:SelectWeapon(classname) end)
    end)
end


hook.Add("PlayerInitialSpawn", "InitInv", function (ply)
    ply.time_respawn = 0
    ply.pressed = false
    ply.time_press = 0
    ply.entity_looked = nil
    ply.carrying = false
end)

hook.Add("PlayerSpawn", "player_spawn", function(ply)
    ply.time_respawn = CurTime()
end)

hook.Add("KeyPress", "key_press", function(ply, key)
	if key == IN_USE then
        ply.time_press = CurTime()
		ply.pressed = true
	end
end)

hook.Add( "KeyRelease", "key_release", function( ply, key )
    if key == IN_USE then
        ply.pressed = false
    end
end )

hook.Add("PlayerCanPickupWeapon", "can_pickup", function(ply, weapon)
    if not config.pickup then return end
    
    if ply.time_respawn == CurTime() then 
        return true 
    end

    if (IsValid(weapon.GiveTo)) then
        if (weapon.GiveTo == ply) then
            return true
        end
    end

    if ply:GetEyeTrace().Entity != weapon or not IsValid(weapon) or not ply.carrying then
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

hook.Add( "AllowPlayerPickup", "allow_pickUp", function( ply, ent )
    ply.carrying = IsValid(ply:GetEyeTrace().Entity)
    return ply.carrying
end)

hook.Add( "OnPlayerPhysicsDrop", "on_entity_drop", function( ply, ent, thrown )
    ply.carrying = false
end)

hook.Add("PlayerCanPickupItem", "CanPickup", function(ply, ent)
    if not config.pickup then end

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

end)