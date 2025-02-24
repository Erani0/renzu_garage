RegisterNUICallback("receive_garagekeys", function(data, cb)
    SetNuiFocus(false,false)
    garagekeysdata = data
end)

RegisterCommand(Config.GarageKeysCommand, function(source, args, rawCommand)
    ESX.TriggerServerCallback("renzu_garage:getgaragekeys",function(sharedkeys,players)
        if Config.GarageKeys and PlayerData.job ~= nil then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local vehicle = GetNearestVehicleinPool(coords, 5)
            local mykeys = {}
            table.insert(mykeys,{identifier = 'own', name = Message[48]})
            if sharedkeys then
                for k,v in pairs(sharedkeys) do
                    table.insert(mykeys,v)
                end
            end
            SendNUIMessage(
                {
                    data = {garages = garagecoord, mykeys = mykeys, action = args[1], players = players},
                    type = "garagekeys"
                }
            )
            SetNuiFocus(true, true)
            while garagekeysdata == nil do Wait(100) end
            if garagekeysdata.action == 'give' then
                TriggerServerEvent('renzu_garage:updategaragekeys',garagekeysdata.action,garagekeysdata.data)
                TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[49])
            end
            if garagekeysdata.action == 'del' then
                TriggerServerEvent('renzu_garage:updategaragekeys',garagekeysdata.action,garagekeysdata.data.mygaragekeys)
                LocalPlayer.state:set('garagekey', false, true)
                TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[50])
            end
            if garagekeysdata.action == 'use' then
                LocalPlayer.state:set('garagekey', garagekeysdata.data.mygaragekeys ~= 'own' and garagekeysdata.data.mygaragekeys or false, true)
                TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[51])
            end
            garagekeysdata = nil
        end
    end)
end, false)

function isVehicleUnlocked()
    local p = PlayerPedId()
    local mycoords = GetEntityCoords(p)
    local veh = nil
    if IsPedInAnyVehicle(p) then
        local v = GetVehiclePedIsIn(p)
        local plate = GetVehicleNumberPlateText(v)
        plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
        local r = GetIsVehicleEngineRunning(v)
        TaskLeaveVehicle(p,v,0)
        Wait(1000)
        if r then
            SetVehicleEngineOn(v,true,true,false)
        end
        local props = GetVehicleProperties(v)
        local Visual = {}
        for k,v in pairs(props) do
            if k == 'tankHealth' or  k == 'dirtLevel' or  k == 'bodyHealth' or  k == 'engineHealth' or k == 'wheel_tires' or k == 'vehicle_window' or k == 'vehicle_doors' then
                Visual[k] = v
            end
        end
        TriggerServerEvent('renzu_garage:SetPropState',{props = Visual, plate = plate})
        return
    end
    if not IsPedInAnyVehicle(p) and IsAnyVehicleNearPoint(mycoords.x,mycoords.y,mycoords.z,10.0) then
        --print("ENTERING")
        veh = GetVehiclePedIsEntering(p)
        local c = 0
        while not veh or veh == 0 do
            veh = GetVehiclePedIsTryingToEnter(p)
            if c > 2000 then
                break
            end
            c = c + 10
            Wait(0)
        end
    end
    if not DoesEntityExist(veh) or entering or GetIsVehicleEngineRunning(veh) then return end
    entering = true
    CreateThread(function()
        while Config.EnableKeySystem do
            local sleep = 0
            if veh then
                EnsureEntityStateBag(veh)
                plate = GetVehicleNumberPlateText(veh)
                plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')
                local ent = Entity(veh).state
                --ent.havekeys = GlobalState.GVehicles[plate] ~= nil and GlobalState.GVehicles[plate].owner == PlayerData.identifier or false
                if not ent.havekeys then
                    ent.havekeys = GlobalState.GVehicles[plate] ~= nil and GlobalState.GVehicles[plate].owner == PlayerData.identifier or ent.share ~= nil and ent.share[PlayerData.identifier] or false
                    if ent.hotwired and ent.havekeys then
                        ent.hotwired = false
                        ent:set('hotwired', false, true)
                        TriggerServerEvent('statebugupdate','hotwired',false, VehToNet(veh))
                        ent:set('havekeys', false, true)
                        TriggerServerEvent('statebugupdate','havekeys',false, VehToNet(veh))
                        Wait(200)
                        ent.havekeys = true
                        SetVehicleEngineOn(veh,false,true,false)
                        SetVehicleNeedsToBeHotwired(veh,false)
                        Wait(100)
                    end
                elseif GlobalState.GVehicles[plate] ~= nil and GlobalState.GVehicles[plate].owner == PlayerData.identifier or ent.share ~= nil and ent.share[PlayerData.identifier] then
                    SetVehicleEngineOn(veh,false,true,false)
                    SetVehicleNeedsToBeHotwired(veh,false)
                    if ent.hotwired then
                        ent.hotwired = false
                        ent:set('hotwired', false, true)
                        TriggerServerEvent('statebugupdate','hotwired',false, VehToNet(veh))
                        ent:set('havekeys', false, true)
                        TriggerServerEvent('statebugupdate','havekeys',false, VehToNet(veh))
                        Wait(200)
                        ent.havekeys = true
                        SetVehicleEngineOn(veh,false,true,false)
                        SetVehicleNeedsToBeHotwired(veh,false)
                        Wait(100)
                    end
                end
                if not ent.unlock and Config.LockAllLocalVehicle 
                or not ent.unlock and GetEntityPopulationType(veh) == 7 and not Config.LockAllLocalVehicle then 
                    SetVehicleDoorsLocked(veh, 2)
                else
                    if not Config.LockAllLocalVehicle and GetEntityPopulationType(veh) ~= 7 then
                        local driver = GetPedInVehicleSeat(veh, -1)
                        if not DoesEntityExist(driver) and Config.LockParkedLocalVehiclesOnly and GetLastPedInVehicleSeat(veh,-1) ~= PlayerPedId() then
                            SetVehicleDoorsLocked(veh, 2)
                        else
                            ent.unlock = true
                            SetVehicleEngineOn(veh,false,true,true)
                            SetVehicleNeedsToBeHotwired(veh,false)
                            SetVehicleDoorsLocked(veh, 7)
                            while GetIsVehicleEngineRunning(veh) do Wait(100) SetVehicleEngineOn(veh,false,true,true) end
                        end
                    else
                        SetVehicleDoorsLocked(veh, 1)
                    end
                end
                sleep = 1
                if not ent.havekeys then
                    SetVehicleEngineOn(veh,false,true,true)
                end
                if ent.unlock and not ent.havekeys then
                    local c = 0
                    while not GetPedInVehicleSeat(veh,-1) == PlayerPedId() or c < 70 do SetVehicleEngineOn(veh,false,true,true) if GetPedInVehicleSeat(veh,-1) == PlayerPedId() then break end Wait(100) c = c + 1 end
                end
                Wait(100)
                if Config.EnableHotwire and ent.unlock and not ent.havekeys and GetPedInVehicleSeat(veh,-1) == PlayerPedId() and not GetIsVehicleEngineRunning(veh) then
                    SetVehicleEngineOn(veh,false,true,true)
                    while GetPedInVehicleSeat(veh,-1) == PlayerPedId() and not GetIsVehicleEngineRunning(veh) do
                        ShowFloatingHelpNotification('[H] '..Message[52]..' <br> [F] to '..Message[53], GetEntityCoords(veh), true, 'hotwire')
                        if IsControlJustPressed(0,74) then
                            HotWireVehicle(veh)
                            Wait(1000)
                        end
                        Wait(0)
                    end
                    SetVehicleNeedsToBeHotwired(veh,true)
                end
                if ent.unlock and ent.havekeys and ent.hotwired and GetSeatPedIsTryingToEnter(PlayerPedId()) == -1 then
                    SetVehicleEngineOn(veh,false,true,false)
                    SetVehicleNeedsToBeHotwired(veh,true)
                end
                if ent.unlock and not ent.havekeys and not ent.hotwired then
                    SetVehicleEngineOn(veh,false,true,true)
                    SetVehicleNeedsToBeHotwired(veh,false)
                end
                if not Config.EnableHotwire then
                    SetVehicleEngineOn(veh,false,true,false)
                    SetVehicleNeedsToBeHotwired(veh,false)
                end
                break
            end
            Wait(sleep)
        end
        entering = false
    end)
end

RegisterCommand('entervehicleg', function()
	isVehicleUnlocked()
end, false)

CreateThread(function()
	RegisterKeyMapping('entervehicleg', Message[54], 'keyboard', 'F')
	return
end)

function SetVehicleBobo(vehicle)
    local netid = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdExistsOnAllMachines(netid,true)
end

function getveh()
    local ped = PlayerPedId()
	local v = GetVehiclePedIsIn(PlayerPedId(), false)
	lastveh = GetVehiclePedIsIn(PlayerPedId(), true)
	local dis = -1
	if v == 0 then
		if #(GetEntityCoords(ped) - GetEntityCoords(lastveh)) < 5 then
			v = lastveh
		end
		dis = #(GetEntityCoords(ped) - GetEntityCoords(lastveh))
	end
	if dis > 3 then
		v = 0
	end
	if v == 0 then
		local count = 5
		v = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 8.000, 0, 70)
		while #(GetEntityCoords(ped) - GetEntityCoords(v)) > 10 and count >= 0 do
			v = GetClosestVehicle(GetEntityCoords(PlayerPedId()),8.000, 0, 70)
			count = count - 1
			Wait(1)
		end
        if v == 0 then
            local temp = {}
            for k,v in pairs(GetGamePool('CVehicle')) do
                local dist = #(GetEntityCoords(ped) - GetEntityCoords(v))
                temp[k] = {}
                temp[k].dist = dist
                temp[k].entity = v
            end
            local dist = -1
            local nearestveh = nil
            for k,v in pairs(temp) do
                if dist == -1 or dist > v.dist then
                    dist = v.dist
                    nearestveh = v.entity
                end
            end
            v = nearestveh
        end
	end
	return tonumber(v)
end

function playanimation(animDict,name)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do 
		Wait(1)
		RequestAnimDict(animDict)
	end
	TaskPlayAnim(PlayerPedId(), animDict, name, 2.0, 2.0, -1, 47, 0, 0, 0, 0)
end

function Keyless()
    local plate = nil
    local vehiclesinarea = {}
    -- ITERATE AND RETURN NEAREST OWNED VEHICLE
    local mycoords = GetEntityCoords(PlayerPedId())
    for k,v in pairs(GetGamePool('CVehicle')) do
        local p = GetVehicleNumberPlateText(v)
        plate = string.gsub(p, '^%s*(.-)%s*$', '%1')
        vehiclesinarea[plate] = {}
        vehiclesinarea[plate].entity = v
        vehiclesinarea[plate].plate = plate
        vehiclesinarea[plate].distance = #(mycoords - GetEntityCoords(v, false))
        vehiclesinarea[plate].owner = GlobalState.GVehicles[plate] ~= nil and GlobalState.GVehicles[plate].owner or false
    end
    local near = -1
    local nearestveh = nil
    local nearestplate = nil
    for k,v in pairs(vehiclesinarea) do
        local ent = Entity(v.entity).state
        if v.owner == PlayerData.identifier and near == -1  -- iterate 1st time checks if owned
        or near == -1 and ent.share ~= nil and ent.share[PlayerData.identifier] and ent.share[PlayerData.identifier] -- iterate 1st time check if shared
        or near > v.distance and ent.share ~= nil and ent.share[PlayerData.identifier] and ent.share[PlayerData.identifier] -- iterate distance checks and checked if shared
        or near == -1 and GlobalState.Gshare and GlobalState.Gshare[v.plate] and GlobalState.Gshare[v.plate][PlayerData.identifier] and GlobalState.Gshare[v.plate][PlayerData.identifier] -- check if identifier included in global keys
        or near > v.distance and GlobalState.Gshare and GlobalState.Gshare[v.plate] and GlobalState.Gshare[v.plate][PlayerData.identifier] and GlobalState.Gshare[v.plate][PlayerData.identifier] -- check if identifier included in global keys
        or near > v.distance and v.owner == PlayerData.identifier then -- iterate distance checks and checked if owned
            if v.owner and near > v.distance or v.owner and near == -1 then
                near = v.distance
                nearestveh = v.entity
                nearestplate = v.plate
                nearestowner = v.owner
            end
        end
    end
    if not nearestveh then return end
    EnsureEntityStateBag(nearestveh)
    -- check nearest owned vehicle
    local ent = Entity(nearestveh).state
    if GlobalState.GVehicles[nearestplate] and GlobalState.GVehicles[nearestplate].owner == PlayerData.identifier -- player owned
    or GlobalState.GVehicles[nearestplate] and ent.share ~= nil and ent.share[PlayerData.identifier] and ent.share[PlayerData.identifier] -- shared vehicle entity state
    or GlobalState.Gshare and GlobalState.Gshare[nearestplate] and GlobalState.Gshare[nearestplate][PlayerData.identifier] and GlobalState.Gshare[nearestplate][PlayerData.identifier] then -- shared vehicle from global state
        ent.unlock = not ent.unlock
        PlaySoundFromEntity(-1, "Remote_Control_Fob", PlayerPedId(), "PI_Menu_Sounds", 1, 0)
        if not IsPedInAnyVehicle(PlayerPedId(), false) then 
            if ent.unlock then 
                local attempt = 1000
                while not NetworkHasControlOfEntity(nearestveh) and attempt < 100 and DoesEntityExist(nearestveh) do
                    NetworkRequestControlOfEntity(nearestveh)
                    Citizen.Wait(1)
                    attempt = attempt + 1
                end
                SetEntityAsMissionEntity(nearestveh,true,true)
                SetVehicleEngineOn(nearestveh,false,true,false) 
            end
            playanimation('anim@mp_player_intmenu@key_fob@','fob_click')
            SetVehicleLights(nearestveh, 2);Citizen.Wait(100);SetVehicleLights(nearestveh, 0);Citizen.Wait(200);SetVehicleLights(nearestveh, 2)
        end
		Citizen.Wait(100)
		SetVehicleLights(nearestveh, 0)	
        ent:set('hotwired', false, true)
        TriggerServerEvent('statebugupdate','hotwired',false, VehToNet(nearestveh))
        --ent:set('unlock', ent.havekeys, true)
        SetVehicleDoorsLocked(nearestveh, 1)
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            SetVehicleEngineOn(nearestveh,false,true,false)
        end
        if ent.unlock then
            ent.havekeys = true
            ent:set('unlock', true, true)
            SetVehicleDoorsLocked(nearestveh,1)
            TriggerServerEvent('statebugupdate','unlock',true, VehToNet(nearestveh))
            --local payload = msgpack_pack(v)
            --SetStateBagValue(es, s, payload, payload:len(), r)
            PlaySoundFromEntity(-1, "Door_Open", nearestveh, "Lowrider_Super_Mod_Garage_Sounds", 0, 0)
            TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[55])
            --StartVehicleHorn(nearestveh,2)
            StartVehicleHorn(nearestveh, 11, "HELDDOWN", false)
            Wait(200)
            StartVehicleHorn(nearestveh, 0, "HELDDOWN", false)
        else
            ent.havekeys = false
            ent:set('unlock', false, true)
            SetVehicleDoorsLocked(nearestveh,2)
            TriggerServerEvent('statebugupdate','unlock',false, VehToNet(nearestveh))
            TriggerServerEvent('statebugupdate','havekeys',false, VehToNet(nearestveh))
            StartVehicleHorn(nearestveh, 11, "HELDDOWN", false)
            Wait(200)
            StartVehicleHorn(nearestveh, 0, "HELDDOWN", false)
            TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[56])
        end
        Wait(500)
        ClearPedTasks(PlayerPedId())
        return
    end
    TriggerEvent('renzu_notify:Notify', 'info',Message[2], Message[57])
end

RegisterCommand('keyless'..Config.CarlockKey, function()
	Keyless()
end, false)

CreateThread(function()
	RegisterKeyMapping('keyless'..Config.CarlockKey, Message[58], 'keyboard', Config.CarlockKey)
	return
end)

-- LOCKPICK
CreateThread(function()
    if Config.EnableLockpickCommand then
        RegisterCommand(Config.LockpickCommand, function()
            LockPick()
        end, false)
    end
    return
end)

RegisterNetEvent('renzu_garage:lockpick')
AddEventHandler('renzu_garage:lockpick', function()
    LockPick()
end)

function HotWireVehicle(veh)
    SetVehicleNeedsToBeHotwired(veh,false)
    SetVehicleDoorsLocked(veh, 1)
    local ent = Entity(veh).state
    while not ent.havekeys do
        Wait(20)
        SetVehicleEngineOn(veh,false,true,true)
        TaskEnterVehicle(PlayerPedId(), veh, 10.0, -1, 2.0, 0)
        while not IsPedInAnyVehicle(PlayerPedId()) do Wait(100) SetVehicleDoorsLocked(veh, 1) end
        local o = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            name = "machinic_loop_mechandplayer",
            flag = 49,
        }
        local ret = exports.renzu_lockgame:CreateGame(Config.HotwireLevel,o,true)
        if ret then
            SetVehicleEngineOn(veh,false,true,false)
            SetVehicleNeedsToBeHotwired(veh,true)
            ent.havekeys = true
            ent:set('havekeys', true, true)
            ent:set('hotwired', true, true)
            TriggerServerEvent('statebugupdate','havekeys',true, VehToNet(veh))
            TriggerServerEvent('statebugupdate','hotwired',true, VehToNet(veh))
            break
        elseif Config.EnableAlert then
            Config.FailAlert()
        end
    end
end

function LockPick()
    if not Config.EnableLockpick then return end
    local veh = getveh()
    if veh ~= 0 then
        local ent = Entity(veh).state
        if not ent.unlock then
            local ret = exports.renzu_lockgame:CreateGame(Config.LockpickLevel)
            if ret then
                ent.unlock = not ent.unlock
                ent:set('unlock', ent.unlock, true)
                TriggerServerEvent('statebugupdate','unlock',ent.unlock, VehToNet(veh))
                SetVehicleDoorsLocked(veh, 1)
                HotWireVehicle(veh)
            else
                if Config.EnableAlert then
                    Config.FailAlert()
                end
                SetVehicleAlarmTimeLeft(veh,20)
                SetVehicleAlarm(veh,true)
                StartVehicleAlarm(veh)
            end
        end
    end
end

-- Vehicle Keys

RegisterNUICallback("receive_vehiclekeys", function(data, cb)
    SetNuiFocus(false,false)
    vehiclekeysdata = data
end)

RegisterCommand(Config.VehicleKeysCommand, function(source, args, rawCommand)
    ESX.TriggerServerCallback("renzu_garage:getgaragekeys",function(sharedkeys,players)
        if Config.GarageKeys and PlayerData.job ~= nil then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local vehicles = {}
            for k,v in pairs(GlobalState.GVehicles) do
                if v.owner == PlayerData.identifier then
                    vehicles[k] = {}
                    vehicles[k].plate = v.plate
                    vehicles[k].name = v.name
                end
            end
            local p = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId()))
            local plate = 'NULL'
            if p then
                plate = string.gsub(p, '^%s*(.-)%s*$', '%1')
            end
            SendNUIMessage(
                {
                    data = {vehicles = vehicles, players = players, current = Config.EnableDuplicateKeys and IsPedInAnyVehicle(PlayerPedId()) and vehicles[plate] or false},
                    type = "vehiclekeys"
                }
            )
            SetNuiFocus(true, true)
            while vehiclekeysdata == nil do Wait(100) end
            if vehiclekeysdata.action == 'give' then
                local owned = false
                local vehicle = GetVehiclePedIsIn(PlayerPedId())
                for k,v in pairs(GlobalState.GVehicles) do
                    if vehiclekeysdata.data and string.gsub(v.plate, '^%s*(.-)%s*$', '%1') == string.gsub(vehiclekeysdata.data.vehiclelist, '^%s*(.-)%s*$', '%1') and v.owner == PlayerData.identifier then
                        owned = true
                        plate = string.gsub(vehiclekeysdata.data.vehiclelist, '^%s*(.-)%s*$', '%1')
                        break
                    end
                end
                if owned then
                    TriggerServerEvent('renzu_garage:transfercar',plate,vehiclekeysdata.data.playerslist)
                    TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[59])
                end
            end
            if vehiclekeysdata.action == 'dupe' and p then
                local owned = false
                local vehicle = GetVehiclePedIsIn(PlayerPedId())
                for k,v in pairs(GlobalState.GVehicles) do
                    if string.gsub(v.plate, '^%s*(.-)%s*$', '%1') == string.gsub(p, '^%s*(.-)%s*$', '%1') and v.owner == PlayerData.identifier then
                        owned = true
                        break
                    end
                end
                if owned and vehiclekeysdata.data ~= nil and string.gsub(vehiclekeysdata.data.vehiclelist, '^%s*(.-)%s*$', '%1') == plate then
                    local ent = Entity(vehicle).state
                    local share = ent.share or {}
                    share[vehiclekeysdata.data.playerslist] = PlayerData.identifier
                    ent:set('share', share, true)
                    TriggerServerEvent('statebugupdate','share',share, VehToNet(vehicle))
                    TriggerEvent('renzu_notify:Notify', 'success',Message[2], Message[60])
                else
                    TriggerEvent('renzu_notify:Notify', 'warning',Message[2], Message[61])
                end
            end
            vehiclekeysdata = nil
        end
    end)
end, false)