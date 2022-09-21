MsgC(Color(50, 0, 180), "~[Loading Inventory]~\n")

if SERVER then

elseif CLIENT then

end

inventory = inventory or {}
inventory.Items = {}
inventory.UseTypes = {
    weapon = function(itemData, ply)
        if ply:HasWeapon(itemData.classname) then InvLog(ply, "You already have the weapon") return false end
        ply.give_menu = true
        ply:Give(itemData.classname, true)
        if(ply:HasWeapon(itemData.classname)) then
            ply:GetWeapon(itemData.classname):SetClip1(itemData.clip1)
            ply:GetWeapon(itemData.classname):SetClip2(itemData.clip2)
        end
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