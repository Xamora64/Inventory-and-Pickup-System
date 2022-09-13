MsgC(Color(50, 0, 180), "~[Loading Inventory]~\n")

if SERVER then
    AddCSLuaFile("autorun/sh_config.lua")
    include("autorun/sh_config.lua")
elseif CLIENT then
    include("autorun/sh_config.lua")
end

inventory = inventory or {}
inventory.Items = {}
inventory.UseTypes = {
    weapon = function(itemData, ply)
        if ply:HasWeapon(itemData.classname) then ply:InvLog("You already have the weapon") return false end
        ply.give_menu = true
        ply:Give(itemData.classname)
        return true
    end,
    model = function(itemData, ply)
        ply:SetModel(itemData.model)
        return false
    end,
    entity = function(itemData, ply)
        local ent = ents.Create(itemData.classname)
        ent:SetPos(ply:GetPos() + Vector(0, 0, 20))
        ent:SetAngles(Angle(0, 0, 0))
        ent:Spawn()
        ply.give_menu = true
        return true
    end,
}