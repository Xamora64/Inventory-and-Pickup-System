AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

list_looked_death = list_looked_death or {}
list_looked_death_ent = list_looked_death_ent or {}

function get_looked_death(ply)
    return list_looked_death[ply:SteamID64()]
end

function init_looked_death(ply)
    list_looked_death = {}
end

function set_looked_death(ply, inv)
    list_looked_death[ply:SteamID64()] = inv
end

function get_looked_death_ent(ply)
    return list_looked_death_ent[ply:SteamID64()]
end

function init_looked_death_ent(ply)
    list_looked_death_ent = {}
end

function set_looked_death_ent(ply, ent)
    list_looked_death_ent[ply:SteamID64()] = ent
end

hook.Add("PlayerSpawn", "PlayerSpawnSetLookedDeath", function(ply)
    init_looked_death(ply)
end)


local nets = {
    "ent_open",
    "ent_take",
    "ent_close",
}

for k,v in ipairs(nets) do
    util.AddNetworkString(v) 
end

function ENT:Initialize()
    self:SetModel(config.model_inventory)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)

    self:GetPhysicsObject():Wake()

end

function ENT:GravGunPickupAllowed(ply)
    return false
end

function ENT:GravGunPickupAllowed(ply)
    return false 
end

function ENT:GravGunPunt(ply)
    return false
end

hook.Add( "PhysgunPickup", "PhysgunPickupCancel", function( ply, ent )
    if ent:GetTable().PrintName == "Death Inventory" then
        return false
    end
end )

function open_looked_death(ply, inv)
    net.Start("ent_open")
    net.WriteTable(inv)
    net.Send(ply)
end

function close_looked_death(ply)
    net.Start("ent_close")
    net.Send(ply)
end

function send_message_looked_death(ply, message)
    if not config.message then return end
    ply:ChatPrint(message)
end

function len_table(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function ENT:Use(activator, caller, use_type, value)
    if len_table(self.inv) <= 0 then self:Remove() send_message_looked_death(activator, "There is no longer any item") return end

    set_looked_death(activator, self.inv)
    set_looked_death_ent(activator, self)

    open_looked_death(activator, self.inv)
end

net.Receive("ent_take", function(len, ply)
    local inv = get_looked_death(ply)
    if inv == nil then return end
    local id = net.ReadInt(32)
    local item = inv[id]
    if not item then return end

    InvTakeOnDeath(ply, item)
    inv[id] = nil

    if len_table(inv) <= 0 then 
        get_looked_death_ent(ply):Remove() 
        send_message_looked_death(ply, "There is no longer any item")
        close_looked_death(ply)
        return
    end

    open_looked_death(ply, inv)
end)