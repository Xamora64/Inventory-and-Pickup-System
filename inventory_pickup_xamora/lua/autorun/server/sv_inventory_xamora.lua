local nets = {
    "inv_init",
    "inv_give",
    "inv_use",
    "inv_drop",
    "inv_remove",
    "inv_refresh",
    "inv_max",
    "inv_number_item",
    "inv_sync",
    "inv_take",
    "key_new",
    "key_sync",
    "key_open",
}

for k,v in ipairs(nets) do
    util.AddNetworkString(v) 
end

local list_inv = list_inv or {}

function getInv(ply)
    local inv = list_inv[ply:SteamID64()]
    if(inv == nil) then list_inv[ply:SteamID64()] = {} end
    return list_inv[ply:SteamID64()]
end

function InvLog(ply, msg)
    if not config.message then return end

    ply:ChatPrint(msg)
end

function InvSave(ply)
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    if not file.Exists("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64(), "DATA") then file.CreateDir("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64()) end
    file.Write("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64() .. "/inventory.txt", util.TableToJSON(getInv(ply)))
end

function InvLoad(ply)
    local data_inventory = file.Read("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64() .. "/inventory.txt")
    if not data_inventory then return false end

    list_inv[ply:SteamID64()] = util.JSONToTable(data_inventory)
    return true
end

local list_key = list_key or {}

function getKey(ply)
    local key = list_key[ply:SteamID64()]
    if(key == nil) then list_key[ply:SteamID64()] = {key_open = config.key_open, key_take = config.key_take} end
    return list_key[ply:SteamID64()]
end

function KeySave(ply)
    if not file.Exists("inventory_xamora", "DATA") then file.CreateDir("inventory_xamora") end
    if not file.Exists("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64(), "DATA") then file.CreateDir("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64()) end
    file.Write("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64() .. "/key.txt", util.TableToJSON(getKey(ply)))
end

function KeyLoad(ply)
    local data_key = file.Read("inventory_xamora/" .. ply:GetName() .. "_" .. ply:SteamID64() .. "/key.txt")
    if not data_key then return false end

    list_key[ply:SteamID64()] = util.JSONToTable(data_key)
    return true
end

function KeySync(ply)
    net.Start("key_sync")
    net.WriteTable(getKey(ply))
    net.Send(ply)
end

function KeySet(ply, str, key)
    getKey(ply)[str] = key
    KeySave(ply)
    KeySync(ply)
end

function InvSync(ply)
    net.Start("inv_sync")
    net.WriteTable(getInv(ply))
    net.Send(ply)
end

net.Receive("inv_sync", function(len, ply)
    if not ply:IsSuperAdmin() then return end

    InvSync(ply)
end)

function InvInit(ply)
    local count = 0
    InvLoad(ply)
    getInv(ply)

    for i in pairs(getInv(ply)) do count = count + 1 end
    ply.number_item = 0
    AddNumberItem(ply, count)
    InvSync(ply)
    InvSave(ply)

    KeyLoad(ply)
    getKey(ply)
    KeySync(ply)
    KeySave(ply)
end

function split (str, sep)
    local new_table = {}
    for v in string.gmatch(str, "([^"..sep.."]+)") do
            table.insert(new_table, v)
    end
    return new_table
end

net.Receive("key_new", function(len, ply)
    local v = split(net.ReadString(), ",")
    KeySet(ply, v[1], tonumber(v[2]))
end)


hook.Add("PlayerInitialSpawn", "init_inv_first_spawn", function (ply)
    InvInit(ply)
end)

net.Receive("inv_init", function(len, ply)
    if not ply:IsSuperAdmin() then return end

    InvInit(ply)
end)

function InvPreTake(ply)
    local distance = ply:GetEyeTrace().Fraction * 100
    local entity_looked = ply:GetEyeTrace().Entity
    if not IsValid(entity_looked) or distance > config.distance then return end
    timer.Create("timer_Take", config.timer_take, 1, function()
        local entity_looked_after_wait = ply:GetEyeTrace().Entity
        if(entity_looked != entity_looked_after_wait) then return end
        if entity_looked:IsWeapon() and config.can_take_weapon then
            InvTakeWeapon(ply, entity_looked)
        elseif config.can_take_entity then
            InvTakeEntity(ply, entity_looked)
        end
    end)
end

function AddNumberItem(ply, nbr)
    ply.number_item = ply.number_item + nbr
    net.Start("inv_number_item")
    net.WriteInt(ply.number_item, 32)
    net.Send(ply)
end

function InvTake(ply, ent, new_item)

    if config.max >= 0 then
        if(ply.number_item >= config.max) then InvLog(ply, "You have too many item(s)") return end
        AddNumberItem(ply, 1)
    end

    ent:Remove()
    table.insert(getInv(ply), new_item)
    net.Start("inv_give")
    net.WriteTable(new_item)
    net.Send(ply)
    InvRefresh(ply)
    InvSave(ply)

    InvLog(ply, "Succesfully picked up item " .. new_item.classname)
end

function InvTakeWeapon(ply, weapon)
    
    for i,v in pairs(config.blacklist_weapon) do
        if(weapon:GetClass() == v) then
            return
        end
    end

    local new_item = {
        name = weapon:GetPrintName(),
        classname = weapon:GetClass(),
        model = weapon:GetModel(),
        type = "weapon",
    }

    InvTake(ply, weapon, new_item)
end

function InvTakeEntity(ply, entity)

    for i in pairs(config.blacklist_entity) do
        if(entity:GetClass() == i) then
            return
        end
    end

    if entity["OnDieFunctions"] == nil then return end

    local typeEntity = entity["OnDieFunctions"]["GetCountUpdate"]["Args"][2]

    if typeEntity != "sents"  then return end


    local new_item = {
        name = entity:GetName(),
        classname = entity:GetClass(),
        model = entity:GetModel(),
        type = "entity",
    }

    InvTake(ply, entity, new_item)
end

function InvPrint(ply)
    print(getInv(ply))
    PrintTable(getInv(ply))
end

function InvHasItem(ply, id)
    return getInv(ply)[id]
end

function InvRemoveItem(ply, id)
    getInv(ply)[id] = nil

    if config.max >= 0 then
        AddNumberItem(ply, -1)
    end

    net.Start("inv_remove")
    net.WriteInt(id, 32)
    net.Send(ply)
    InvRefresh(ply)
end

function InvRefresh(ply)
    net.Start("inv_refresh")
    net.Send(ply)
end

net.Receive("inv_use", function(len, ply)
    local id = net.ReadInt(32)
    if InvHasItem(ply, id) then
        local itemData = getInv(ply)[id]
        local shouldRemove = inventory.UseTypes[itemData.type](itemData, ply)
        if shouldRemove then
            InvRemoveItem(ply, id)
            InvSave(ply)
        end
    end
end)

net.Receive("inv_drop", function(len, ply)
    local id = net.ReadInt(32)
    if InvHasItem(ply, id) then
        local itemData = getInv(ply)[id]
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
            filter = ply,
        })
        local itemEnt = ents.Create(itemData.classname)
        itemEnt:SetPos(tr.HitPos)
        itemEnt:SetAngles(Angle(0, 0, 0))
        itemEnt:Spawn()
        InvRemoveItem(ply, id)
        InvSave(ply)
    end
end)

hook.Add( "PlayerButtonDown", "key_press_open_take", function( ply, key )
    if (key == getKey(ply)["key_open"]) then
        net.Start("key_open")
        net.Send(ply)
    elseif (key == getKey(ply)["key_take"]) then
        InvPreTake(ply)
    end
end )