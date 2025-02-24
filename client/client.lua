-- Renzu Garage
Citizen.CreateThread(function()
    Wait(1000)
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    coordcache = garagecoord
    for k,v in pairs(garagecoord) do -- create job garage
        if v.job ~= nil and jobgarages[v.garage] == nil then
            jobgarages[v.garage] = {}
            jobgarages[v.garage].coord = vector3(v.garage_x,v.garage_y,v.garage_z)
            jobgarages[v.garage].garageid = v.garage
            jobgarages[v.garage].job = v.job
            jobgarages[v.garage].garage_type = v.garage_type ~= nil and v.garage_type or Message[1]
        end
    end
	while ESX == nil do
		Citizen.Wait(100)
	end

	while PlayerData.job == nil do
		PlayerData = ESX.GetPlayerData()
		Citizen.Wait(111)
	end

	PlayerData = ESX.GetPlayerData()
    Wait(2000)
    if Config.Realistic_Parking then
        TriggerServerEvent('renzu_garage:GetParkedVehicles')
    end
    for k, v in pairs (garagecoord) do
        if v.job ~= nil and v.job == PlayerData.job.name or v.job == nil then
            local blip = AddBlipForCoord(v.garage_x, v.garage_y, v.garage_z)
            SetBlipSprite (blip, v.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, v.Blip.scale)
            SetBlipColour (blip, v.Blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            if Config.BlipNamesStatic then
                AddTextComponentSubstringPlayerName(Message[2])
            else
                AddTextComponentSubstringPlayerName(Message[2]..": "..v.garage.."")
            end
            EndTextCommandSetBlipName(blip)
        end
    end
    if Config.EnableImpound then
        for k, v in pairs (impoundcoord) do
            if PlayerData.job ~= nil and JobImpounder[PlayerData.job.name] ~= nil then
                local blip = AddBlipForCoord(v.garage_x, v.garage_y, v.garage_z)
                SetBlipSprite (blip, v.Blip.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale  (blip, v.Blip.scale)
                SetBlipColour (blip, v.Blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                if Config.BlipNamesStatic then
                    AddTextComponentSubstringPlayerName(Message[3])
                else
                    AddTextComponentSubstringPlayerName(Message[2]..": "..v.garage.."")
                end
                EndTextCommandSetBlipName(blip)
            end
        end
    end
    for k, v in pairs (private_garage) do
        local blip = AddBlipForCoord(v.buycoords.x, v.buycoords.y, v.buycoords.z)
        SetBlipSprite (blip, v.Blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, v.Blip.scale)
        SetBlipColour (blip, v.Blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        if Config.BlipNamesStatic then
            AddTextComponentSubstringPlayerName(Message[4])
        else
            AddTextComponentSubstringPlayerName(Message[2]..": "..v.name.."")
        end
        EndTextCommandSetBlipName(blip)
    end
    if Config.EnablePropertyCoordGarageCoord and Config.HousingBlips then
        for k,v in pairs(HousingGarages) do
            local vec = vector3(v.garage.x,v.garage.y,v.garage.z)
            local name = Message[5]..' #'..k
            local blip = AddBlipForCoord(v.garage.x,v.garage.y,v.garage.z)
            SetBlipSprite (blip, 524)
            SetBlipDisplay(blip, 5)
            SetBlipScale  (blip, 0.4)
            SetBlipColour (blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(""..name.."")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerloaded = true
    Wait(1000)
    LocalPlayer.state:set( 'loaded', true, true)
    LocalPlayer.state.loaded = true
    if Config.EnableHeliGarage and PlayerData.job ~= nil and helispawn[PlayerData.job.name] ~= nil then
        for k, v in pairs (helispawn[PlayerData.job.name]) do
            local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite (blip, v.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, v.Blip.scale)
            SetBlipColour (blip, v.Blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(""..v.garage.."")
            EndTextCommandSetBlipName(blip)
        end
    end
    if Config.Realistic_Parking then
        TriggerServerEvent('renzu_garage:GetParkedVehicles')
    end
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	playerjob = PlayerData.job.name
    if Config.EnableHeliGarage and PlayerData.job ~= nil and helispawn[PlayerData.job.name] ~= nil then
        for k, v in pairs (helispawn[PlayerData.job.name]) do
            local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite (blip, v.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, v.Blip.scale)
            SetBlipColour (blip, v.Blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Message[2]..": "..v.garage.."")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    while PlayerData.job == nil do Wait(100) end
    Wait(500)
    if not Config.UsePopUI and Config.floatingtext then
        while true do
            local mycoord = GetEntityCoords(PlayerPedId())
            local inveh = IsPedInAnyVehicle(PlayerPedId())
            for k,v in pairs(garagecoord) do
                local vec = vector3(v.garage_x,v.garage_y,v.garage_z)
                local req_dis = v.Dist
                if inveh and v.store_x ~= nil then
                    vec = vector3(v.store_x,v.store_y,v.store_z)
                    req_dis = v.Store_dist
                end
                local dist = #(vec - mycoord)
                if Config.UseMarker and dist < Config.MarkerDistance then
                    Config.UseMarker = false
                    DrawZuckerburg(v.garage,vec,Config.MarkerDistance)
                end
                if dist < req_dis then
                    tid = k
                    garageid = v.garage
                    neargarage = true
                    --PopUI(v.garage,vec,req_dis)
                    if IsPedInAnyVehicle(PlayerPedId()) then
                        msg = Message[7]..' [E] '..Message[6]
                    else
                        msg = Message[7]..' [E] 🏚️ '..Message[2]..' '..v.garage
                    end
                    DrawInteraction(v.garage,vec,{req_dis,req_dis*3},msg,'opengarage',false,false,false)
                end
            end
            if Config.EnableImpound then
                for k,v in pairs(impoundcoord) do
                    local vec = vector3(v.garage_x,v.garage_y,v.garage_z)
                    local dist = #(vec - mycoord)
                    if dist < v.Dist then
                        tid = k
                        garageid = v.garage
                        neargarage = true
                        --PopUI(v.garage,vec)
                        if IsPedInAnyVehicle(PlayerPedId()) then
                            msg = Message[7]..' [E] '..Message[6]
                        else
                            msg = Message[7]..' [E] ⛍ '..Message[2]..' '..v.garage
                        end
                        DrawInteraction(v.garage,vec,{v.Dist,v.Dist*3},msg,'opengarage',false,false,false)
                    end
                end
            end
            if Config.EnableHeliGarage and PlayerData.job ~= nil and helispawn[PlayerData.job.name] ~= nil then
                for k,v in pairs(helispawn[PlayerData.job.name]) do
                    local vec = vector3(v.coords.x,v.coords.y,v.coords.z)
                    local dist = #(vec - mycoord)
                    if dist < 5 then
                        tid = k
                        garageid = v.garage
                        neargarage = true
                        if IsPedInAnyVehicle(PlayerPedId()) then
                            msg = Message[7]..' [E] '..Message[8]
                        else
                            msg = Message[7]..' [E] 🛸 '..Message[2]..' '..v.garage
                        end
                        DrawInteraction(v.garage,vec,{10,15},msg,'opengarage',false,false,false)
                        --PopUI(v.garage,vec)
                    end
                end
            end
            if Config.EnablePropertyCoordGarageCoord then
                for k,v in pairs(HousingGarages) do
                    local vec = vector3(v.garage.x,v.garage.y,v.garage.z)
                    local req_dis = 3
                    local dist = #(vec - mycoord)
                    if dist < 3 then
                        tid = k
                        garageid = 'garage_'..k
                        neargarage = true
                        if GlobalState.HousingGarages[garageid] ~= nil and GlobalState.HousingGarages[garageid] == PlayerData.identifier then
                            if IsPedInAnyVehicle(PlayerPedId()) then
                                print("in vehicle")
                                msg = Message[7]..' [E] '..Message[6]
                                DrawInteraction(garageid,vec,{3,5},msg,'renzu_garage:storeprivatehouse',false,garageid,false)
                            else
                                msg = Message[7]..' [E] '..Message[5]..' #'..k
                                DrawInteraction(garageid,vec,{3,5},msg,'renzu_garage:gotohousegarage',true,{v.shell, {},false,garageid,vector4(v.garage.x,v.garage.y,v.garage.z,v.garage.w)},false)
                            end
                        else
                            msg = Message[7]..' [E] '..Message[9]..' #'..k
                            DrawInteraction(garageid,vec,{3,5},msg,'renzu_garage:buygarage',true,garageid,false)
                        end
                        --PopUI(v.garage,vec)
                    end
                end
            end
            Wait(1000)
        end
    end
    if Config.UsePopUI and not Config.floatingtext then
        while true do
            local mycoord = GetEntityCoords(PlayerPedId())
            local inveh = IsPedInAnyVehicle(PlayerPedId())
            for k,v in pairs(garagecoord) do
                local vec = vector3(v.garage_x,v.garage_y,v.garage_z)
                local req_dis = v.Dist
                if inveh and v.store_x ~= nil then
                    vec = vector3(v.store_x,v.store_y,v.store_z)
                    req_dis = v.Store_dist
                end
                local dist = #(vec - mycoord)
                if Config.UseMarker and dist < Config.MarkerDistance then
                    Config.UseMarker = false
                    DrawZuckerburg(v.garage,vec,Config.MarkerDistance)
                end
                if dist < req_dis then
                    tid = k
                    garageid = v.garage
                    neargarage = true
                    PopUI(v.garage,vec,req_dis)
                end
            end
            if Config.EnableImpound then
                for k,v in pairs(impoundcoord) do
                    local vec = vector3(v.garage_x,v.garage_y,v.garage_z)
                    local dist = #(vec - mycoord)
                    if dist < v.Dist then
                        tid = k
                        garageid = v.garage
                        neargarage = true
                        PopUI(v.garage,vec)
                    end
                end
            end
            if Config.EnableHeliGarage and PlayerData.job ~= nil and helispawn[PlayerData.job.name] ~= nil then
                for k,v in pairs(helispawn[PlayerData.job.name]) do
                    local vec = vector3(v.coords.x,v.coords.y,v.coords.z)
                    local dist = #(vec - mycoord)
                    if dist < 10 then
                        tid = k
                        garageid = v.garage
                        neargarage = true
                        PopUI(v.garage,vec)
                    end
                end
            end
            Wait(1000)
        end
    end
end)

RegisterNetEvent('opengarage')
AddEventHandler('opengarage', function()
    local sleep = 2000
    local ped = PlayerPedId()
    local vehiclenow = GetVehiclePedIsIn(PlayerPedId(), false)
    jobgarage = false
    garagejob = nil
    for k,v in pairs(garagecoord) do
        if not v.property then
            local actualShop = v
            local dist = #(vector3(v.garage_x,v.garage_y,v.garage_z) - GetEntityCoords(ped))
            jobgarage = false
            if v.job ~= nil then
                if string.find(v.garage, "impound") then
                    jobgarage = false
                else
                    jobgarage = true
                end
            end
            if DoesEntityExist(vehiclenow) then
                local req_dist = v.Store_dist or v.Dist
                if dist <= req_dist and not jobgarage and not string.find(v.garage, "impound") or dist <= 7.0 and PlayerData.job ~= nil and PlayerData.job.name == v.job and jobgarage and not string.find(v.garage, "impound") then
                    garageid = v.garage
                    Storevehicle(vehiclenow,false,false,v.garage_type == 'public' or false)
                    break
                end
            elseif not DoesEntityExist(vehiclenow) then
                if dist <= v.Dist and not jobgarage and not string.find(v.garage, "impound") or dist <= 7.0 and PlayerData.job ~= nil and PlayerData.job.name == v.job and jobgarage and not string.find(v.garage, "impound") then
                    garageid = v.garage
                    tid = k
                    TriggerEvent('renzu_notify:Notify', 'info',Message[2], Message[36])
                    TriggerServerEvent("renzu_garage:GetVehiclesTable",garageid,v.garage_type == 'public' or false)
                    fetchdone = false
                    garage_public = v.garage_type == 'public' or false
                    while not fetchdone do
                        Wait(0)
                    end
                    vtype = v.Type
                    if jobgarage then
                        garagejob = v.job
                    end
                    propertygarage = false
                    OpenGarage(v.garage,v.Type,garagejob or false,v.default_vehicle or {})
                    break
                end
            end
            if dist > 11 or ingarage then
                indist = false
            end
        end
    end


    --IMPOUND

    if Config.EnableImpound then
        for k,v in pairs(impoundcoord) do
            local actualShop = v
            local dist = #(vector3(v.garage_x,v.garage_y,v.garage_z) - GetEntityCoords(ped))
            if v.job ~= nil then
                jobgarage = true
                ispolice = PlayerData.job.name == v.job
            end
            if DoesEntityExist(vehiclenow) then
                if dist <= v.Dist and not jobgarage or dist <= 3.0 and PlayerData.job ~= nil and PlayerData.job.name == v.job and jobgarage then
                    garageid = v.garage
                    Storevehicle(vehiclenow)
                    break
                end
            elseif not DoesEntityExist(vehiclenow) then
                if dist <= v.Dist and Impoundforall or not Impoundforall and dist <= 3.0 and PlayerData.job ~= nil and PlayerData.job.name == v.job and jobgarage then
                    garageid = v.garage
                    TriggerEvent('renzu_notify:Notify', 'info',Message[2], "Opening Impound...Please wait..")
                    TriggerServerEvent("renzu_garage:GetVehiclesTableImpound")
                    fetchdone = false
                    while not fetchdone do
                        Wait(0)
                    end
                    OpenImpound(v.garage)
                    break
                end
            end
            if dist > 11 or ingarage then
                indist = false
            end
        end
    end


    if Config.EnableHeliGarage and PlayerData.job ~= nil and helispawn[PlayerData.job.name] ~= nil then
        for k,v in pairs(helispawn[PlayerData.job.name]) do
            local coord = v.coords
            local v = v.coords
            local dist = #(vector3(coord.x,coord.y,coord.z) - GetEntityCoords(ped))
            if DoesEntityExist(vehiclenow) then
                if dist <= 7.0 then
                    helidel(vehiclenow)
                    break
                end
            elseif not DoesEntityExist(vehiclenow) then
                if dist <= 10.0 then
                    TriggerEvent("renzu_garage:getchopper",PlayerData.job.name,heli[PlayerData.job.name])
                    Citizen.Wait(1111)
                    OpenHeli(PlayerData.job.name)
                    break
                end
            end
            if dist > 11 or ingarage then
                indist = false
            end
        end
    end
end)

RegisterNetEvent('renzu_garage:notify')
AddEventHandler('renzu_garage:notify', function(type, message)    
    SendNUIMessage(
        {
            type = "notify",
            typenotify = type,
            message = message,
        }
    ) 
end)

RegisterNetEvent('renzu_garage:receive_vehicles')
AddEventHandler('renzu_garage:receive_vehicles', function(tb, vehdata)
    fetchdone = false
    OwnedVehicles = nil
    Wait(100)
    OwnedVehicles = {}
    tableVehicles = nil
    tableVehicles = tb
    local vehdata = vehdata
    vehiclesdb = vehdata
    if vehdata == nil then
        vehdata = {}
    end
    local vehicle_data = {}
    for _,value in pairs(vehdata) do
        vehicle_data[value.model] = value.name
    end

    OwnedVehicles['garage'] = {}
    local gstate = GlobalState and GlobalState.VehicleImages or {}
    for _,value in pairs(tableVehicles) do
        local props = json.decode(value.vehicle)
        if IsModelInCdimage(props.model) then
            local vehicleModel = tonumber(props.model)  
            local label = nil
            if label == nil then
                label = 'Unknown'
            end

            local vehname = nil
            for _,value in pairs(vehdata) do -- fetch vehicle names from vehicles sql table
                if tonumber(props.model) == GetHashKey(value.model) then
                    vehname = value.name
                    break
                end
            end

            --local vehname = vehicle_data[GetDisplayNameFromVehicleModel(tonumber(props.model))]

            if vehname == nil then
                vehname = GetLabelText(GetDisplayNameFromVehicleModel(tonumber(props.model)):lower())
            end
            if props ~= nil and props.engineHealth ~= nil and props.engineHealth < 100 then
                props.engineHealth = 200
            end
            local pmult, tmult, handling, brake = 1000,800,GetPerformanceStats(vehicleModel).handling,GetPerformanceStats(vehicleModel).brakes
            if value.type == 'boat' or value.type == 'air' then
                pmult,tmult,handling, brake = 10,8,GetPerformanceStats(vehicleModel).handling * 0.1, GetPerformanceStats(vehicleModel).brakes * 0.1
            end
            if value.job == '' then
                value.job = nil
            end
            local havejob = false
            for k,v in pairs(jobgarages) do
                if value.job ~= nil and v.job == value.job then
                    havejob = true
                end
            end
            if value.job ~= nil and not havejob then -- fix incompatibility with vehicles with job column as a default from sql eg. civ fck!
                value.job = nil
            end
            if value.garage_id ~= nil then -- fix blank job column, seperate the car to other non job garages
                for k,v in pairs(jobgarages) do 
                    if v.job ~= nil and value.job ~= nil and v.job == value.job and v.garageid == value.garage_id and #(v.coord - GetEntityCoords(PlayerPedId())) < 20 then
                        value.job = v.job
                    end
                    if v.garage_type and v.garage_type == 'public' and #(v.coord - GetEntityCoords(PlayerPedId())) < 20 then
                        value.garage_type = 'public'
                        value.job = v.job
                    end
                end
                --value.garage_id = jobgarages[value.job].garageid
            end
            local default_thumb = string.lower(GetDisplayNameFromVehicleModel(tonumber(props.model)))
            local img = 'https://cfx-nui-renzu_garage/imgs/uploads/'..default_thumb..'.jpg'
            if Config.use_renzu_vehthumb and gstate[tostring(props.model)] then
                img = gstate[tostring(props.model)]
            end
            local VTable = 
            {
                brand = GetVehicleClassnamemodel(tonumber(props.model)),
                name = vehname:upper(),
                brake = brake,
                handling = handling,
                topspeed = math.ceil(GetVehicleModelEstimatedMaxSpeed(vehicleModel)*4.605936),
                power = math.ceil(GetVehicleModelAcceleration(vehicleModel)*pmult),
                torque = math.ceil(GetVehicleModelAcceleration(vehicleModel)*tmult),
                model = string.lower(GetDisplayNameFromVehicleModel(tonumber(props.model))),
                model2 = tonumber(props.model),
                plate = value.plate,
                img = img,
                props = value.vehicle,
                fuel = props.fuelLevel or 100,
                bodyhealth = props.bodyHealth or 1000,
                enginehealth = props.engineHealth or 1000,
                garage_id = value.garage_id,
                impound = value.impound,
                stored = value.stored,
                identifier = value.owner,
                type = value.type,
                garage_type = value.garage_type ~= nil and value.garage_type or 'personal',
                job = value.job ~= nil,
            }
            table.insert(OwnedVehicles['garage'], VTable)
        end
    end
    fetchdone = true
end)

RegisterNetEvent('renzu_garage:getchopper')
AddEventHandler('renzu_garage:getchopper', function(job, available)
    OwnedVehicles = {}
    Wait(100)
    tableVehicles = {}
    tableVehicles = tb
    local vehdata = vehdata
    local vehicle_data = {}
    for _,value in pairs(available) do
        vehicle_data[job] = value.model
    end

    for _,value in pairs(available) do
        OwnedVehicles[job] = {}
    end

    local gstate = GlobalState and GlobalState.VehicleImages or {}
    for _,value in pairs(available) do
        local default_thumb = string.lower(GetDisplayNameFromVehicleModel(value.model))
        local img = 'https://cfx-nui-renzu_garage/imgs/uploads/'..default_thumb..'.jpg'
        if Config.use_renzu_vehthumb and gstate[tostring(GetHashKey(value.model))] then
            img = gstate[tostring(GetHashKey(value.model))]
        end
        local vehicleModel = tonumber(value.model)  
        local label = nil
        if label == nil then
            label = 'Unknow'
        end

        local vehname = value.model

        if vehname == nil then
            vehname = GetDisplayNameFromVehicleModel(tonumber(value.model))
        end
        local VTable = 
        {
            brand = GetVehicleClassnamemodel(tonumber(value.model)),
            name = vehname:upper(),
            brake = GetPerformanceStats(vehicleModel).brakes,
            handling = GetPerformanceStats(vehicleModel).handling,
            topspeed = math.ceil(GetVehicleModelEstimatedMaxSpeed(vehicleModel)*4.605936),
            power = math.ceil(GetVehicleModelAcceleration(vehicleModel)*1000),
            torque = math.ceil(GetVehicleModelAcceleration(vehicleModel)*800),
            model = value.model,
            model2 = value.model,
            plate = value.plate,
            img = img,
            props = value.vehicle,
            fuel = 100,
            bodyhealth = 1000,
            enginehealth = 1000,
            garage_id = job,
            impound = 0,
            stored = 1
        }
        table.insert(OwnedVehicles[job], VTable)
    end
    fetchdone = true
end)

RegisterNUICallback(
    "choosecat",
    function(data, cb)
        cat = data.cat or 'all'
    end
)

RegisterNetEvent('renzu_garage:return')
AddEventHandler('renzu_garage:return', function(v,vehicle,property,actualShop,vp,gid)
    local vp = vp
    local v = v
    FreezeEntityPosition(PlayerPedId(),true)
    ESX.TriggerServerCallback("renzu_garage:returnpayment",function(canreturn)
        if canreturn then
            DoScreenFadeOut(0)
            for k,v in pairs(spawnedgarage) do
                ReqAndDelete(v)
            end
            CheckWanderingVehicle(vp.plate)
            DeleteGarage()
            Citizen.Wait(333)
            SetEntityCoords(PlayerPedId(), v.spawn_x*1.0,v.spawn_y*1.0,v.spawn_z*1.0, false, false, false, true)
            --TaskLeaveVehicle(PlayerPedId(),GetVehiclePedIsIn(PlayerPedId()),1)
            Citizen.Wait(1000)
            local hash = tonumber(vp.model)
            local count = 0
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Citizen.Wait(10)
                RequestModel(hash)
            end
            Wait(100)
            local vehicle = CreateVehicle(tonumber(vp.model), tonumber(v.spawn_x)*1.0,tonumber(v.spawn_y)*1.0,tonumber(v.spawn_z)*1.0, tonumber(v.heading), 1, 1)
            while not DoesEntityExist(vehicle) do Wait(1) print(vp.model,'loading model') end
            SetVehicleBobo(vehicle)
            Wait(100)
            SetVehicleProp(vehicle, vp)
            SetEntityCoords(GetEntityCoords(vehicle))
            if not property then
                Spawn_Vehicle_Forward(vehicle, vector3(v.spawn_x*1.0,v.spawn_y*1.0,v.spawn_z*1.0))
            end
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            veh = vehicle
            ESX.TriggerServerCallback("renzu_garage:changestate",function(ret,garage_public)
                if ret and garage_public then
                    local ent = Entity(veh).state
                    while ent.share == nil do Wait(100) end
                    ent.haskeys = false
                    ent.hotwired = false
                    ent.unlock = true
                    local share = ent.share or {}
                    local add = true
                    for k,v in pairs(share) do
                        if k == v.PlayerData.identifier then
                            add = false
                        end
                    end
                    if add then
                        share[PlayerData.identifier] = PlayerData.identifier
                    end
                    ent.share = share
                    ent:set('share', share, true)
                    TriggerServerEvent('statebugupdate','share',share, VehToNet(veh))
                end
            end,vp.plate, 0, gid, vp.model, vp, false, garage_public)
            spawnedgarage = {}
            TriggerEvent('renzu_popui:closeui')
            if property then
                garagecoord[gid] = nil
            end
            ingarage = false
            neargarage = false
            --DeleteGarage()
            DoScreenFadeIn(333)
            i = 0
            min = 0
            max = 10
            plus = 0
            FreezeEntityPosition(PlayerPedId(),false)
        else
            TriggerEvent('renzu_notify:Notify', 'error',Message[2], Message[40])
            LastVehicleFromGarage = nil
            Wait(111)
            SetEntityCoords(PlayerPedId(), garagecoord[tid].garage_x,garagecoord[tid].garage_y,garagecoord[tid].garage_z, false, false, false, true)
            CloseNui()
            i = 0
            min = 0
            max = 10
            plus = 0
            drawtext = false
            indist = false
            SendNUIMessage({
                type = "cleanup"
            })
        end
    end)
end)

DoScreenFadeIn(333)
RegisterNetEvent('renzu_garage:ingaragepublic')
AddEventHandler('renzu_garage:ingaragepublic', function(coords, distance, vehicle, property, propertycoord, gid)
    local dist2 = 2
    if property and gid then
        spawn = propertycoord
        found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(spawn.x + math.random(1, 2), spawn.y + math.random(1, 2), spawn.z, 0, 3, 0)
        --table.insert(garagecoord, {spawn_x = spawnPos.x, spawn_y = spawnPos.y, spawn_z = spawnPos.z, garage = gid, property = true})
        tid = gid
        garagecoord[gid] = {garage_x = myoldcoords.x, garage_y = myoldcoords.y, garage_z = myoldcoords.z, spawn_x = spawnPos.x, spawn_y = spawnPos.y, spawn_z = spawnPos.z, garage = gid, property = true, Dist = 4, heading = spawnHeading}
        dist2 = #(vector3(spawnPos.x,spawnPos.y,spawnPos.z) - GetEntityCoords(PlayerPedId()))
    else
        dist2 = #(vector3(garagecoord[tid].spawn_x,garagecoord[tid].spawn_y,garagecoord[tid].spawn_z) - GetEntityCoords(PlayerPedId()))
    end
    dist = #(GetEntityCoords(PlayerPedId())-GetEntityCoords(vehicle))
    --for k,v in pairs(garagecoord) do
        local actualShop = v
        --if dist2 <= 80.0 then
            vp = GetVehicleProperties(vehicle)
            plate = vp.plate
            model = GetEntityModel(vehicle)
            ESX.TriggerServerCallback("renzu_garage:isvehicleingarage",function(stored,impound,garage,fee,sharedvehicle)
                if stored and impound == 0 or not Config.EnableReturnVehicle or string.find(garageid, "impound") then
                    local tempcoord = garagecoord
                    if string.find(garageid, "impound") then tempcoord = impoundcoord end
                    DoScreenFadeOut(0)
                    Citizen.Wait(333)
                    if not property then
                        SetEntityCoords(PlayerPedId(), tempcoord[tid].garage_x,tempcoord[tid].garage_y,tempcoord[tid].garage_z, false, false, false, true)
                    end
                    Citizen.Wait(1000)
                    local hash = tonumber(model)
                    local count = 0
                    if not HasModelLoaded(hash) then
                        RequestModel(hash)
                        while not HasModelLoaded(hash) do
                            RequestModel(hash)
                            Citizen.Wait(10)
                        end
                    end
                    v = CreateVehicle(model, tempcoord[tid].spawn_x,tempcoord[tid].spawn_y,tempcoord[tid].spawn_z, tempcoord[tid].heading, 1, 1)
                    SetVehicleBobo(v)
                    CheckWanderingVehicle(vp.plate)
                    vp.health = GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId()))
                    SetVehicleProp(v, vp)
                    Spawn_Vehicle_Forward(v, vector3(tempcoord[tid].spawn_x,tempcoord[tid].spawn_y,tempcoord[tid].spawn_z))
                    TaskWarpPedIntoVehicle(PlayerPedId(), v, -1)
                    veh = v
                    DoScreenFadeIn(333)
                    ESX.TriggerServerCallback("renzu_garage:changestate",function(ret,garage_public)
                        if ret and garage_public then
                            local ent = Entity(veh).state
                            while ent.share == nil do Wait(100) end
                            ent.haskeys = false
                            ent.hotwired = false
                            ent.unlock = true
                            local share = ent.share or {}
                            local add = true
                            for k,v in pairs(share) do
                                if k == v.PlayerData.identifier then
                                    add = false
                                end
                            end
                            if add then
                                share[PlayerData.identifier] = PlayerData.identifier
                            end
                            ent.share = share
                            ent:set('share', share, true)
                            TriggerServerEvent('statebugupdate','share',share, VehToNet(veh))
                        end
                    end,vp.plate, 0, garageid, vp.model, vp,false,garage_public)
                    garage_public = false
                    if sharedvehicle then
                        local ent = Entity(v).state
                        while ent.share == nil do Wait(100) end
                        ent.haskeys = false
                        ent.hotwired = false
                        ent.unlock = true
                        local share = ent.share or {}
                        local add = true
                        for k,v in pairs(share) do
                            if k == v.PlayerData.identifier then
                                add = false
                            end
                        end
                        if add then
                            share[PlayerData.identifier] = PlayerData.identifier
                        end
                        ent.share = share
                        ent:set('share', share, true)
                        TriggerServerEvent('statebugupdate','share',share, VehToNet(v))
                    end
                    for k,v in pairs(spawnedgarage) do
                        ReqAndDelete(v)
                    end
                    spawnedgarage = {}
                    ingarage = false
                    DeleteGarage()
                    if property then
                        garagecoord[gid] = nil
                    end
                    shell = nil
                    i = 0
                    min = 0
                    max = 10
                    plus = 0
                elseif impound == 1 then
                    drawtext = true
                    SetEntityAlpha(vehicle, 51, false)
                    Wait(1000)
                    local t = {
                        ['event'] = 'impounded',
                        ['title'] = Message[41],
                        ['server_event'] = false,
                        ['unpack_arg'] = false,
                        ['invehicle_title'] = Message[41],
                        ['confirm'] = '[ENTER]',
                        ['reject'] = '[CLOSE]',
                        ['custom_arg'] = {}, -- example: {1,2,3,4}
                        ['use_cursor'] = false, -- USE MOUSE CURSOR INSTEAD OF INPUT (ENTER)
                    }
                    TriggerEvent('renzu_popui:showui',t)
                    Citizen.Wait(3000)
                    TriggerEvent('renzu_popui:closeui')
                    drawtext = false
                else
                    drawtext = true
                    SetEntityAlpha(vehicle, 51, false)
                    Wait(1000)
                    local t = {
                        ['event'] = 'renzu_garage:return',
                        ['title'] = Message[42],
                        ['server_event'] = false,
                        ['unpack_arg'] = true,
                        ['invehicle_title'] = Message[42],
                        ['confirm'] = '[E] '..Message[43],
                        ['reject'] = '[CLOSE]',
                        ['custom_arg'] = {garagecoord[tid],vehicle,property or false,garagecoord[tid],GetVehicleProperties(vehicle),tid}, -- example: {1,2,3,4}
                        ['use_cursor'] = false, -- USE MOUSE CURSOR INSTEAD OF INPUT (ENTER)
                    }
                    TriggerEvent('renzu_popui:showui',t)
                    if property then
                        garagecoord[tid] = nil
                    end
                    local paying = 0
                    while dist < 3 and ingarage do
                        coords = GetEntityCoords(PlayerPedId())
                        vehcoords = GetEntityCoords(vehicle)
                        dist = #(coords-vehcoords)
                        paying = paying + 1
                        Citizen.Wait(500)
                    end
                    TriggerEvent('renzu_popui:closeui')
                    drawtext = false
                end
            end,plate,garageid,false,patrolcars[plate] or false)
        --end
    --end
end)

RegisterNetEvent('renzu_garage:store')
AddEventHandler('renzu_garage:store', function(i)
    local vehicleProps = GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), 0))
    garageid = i
    if garageid == nil then
    garageid = 'A'
    end
    ESX.TriggerServerCallback("renzu_garage:changestate",function(ret)
        if ret then
            DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), 0))
        end
    end,vehicleProps.plate, 1, garageid, vehicleProps.model, vehicleProps)
end)

RegisterNUICallback(
    "gotogarage",
    function(data, cb)
        if propertyspawn.x ~= nil then return end
        DeleteEntity(LastVehicleFromGarage)
        LastVehicleFromGarage = nil
        DoScreenFadeOut(0)
        local job = garagejob
        CloseNui()
        if string.find(garageid, "impound") and not ispolice then
            DoScreenFadeIn(0)
            SetEntityCoords(PlayerPedId(), impoundcoord[tid].garage_x,impoundcoord[tid].garage_y,impoundcoord[tid].garage_z, false, false, false, true)
            TriggerEvent('renzu_notify:Notify', 'error',Message[2], Message[44])
            return
        end
        GotoGarage(data.garageid or garageid,false,false,job)
    end
)

RegisterNUICallback("ownerinfo",function(data, cb)
    ESX.TriggerServerCallback("renzu_garage:getowner",function(a,data)
        if a ~= nil then
        SendNUIMessage(
            {
                type = "ownerinfo",
                info = a,
                job = JobImpounder[PlayerData.job.name] or false,
                impound_data = data or {}
            }
        )
        end
    end,data.identifier, data.plate, garageid)
end)

RegisterNUICallback("SpawnVehicle",function(data, cb)
    if not Config.Quickpick and vtype == 'car' or propertyspawn.x ~= nil and not Config.PropertyQuickPick then
        local props = nil
        for k,v in pairs(OwnedVehicles['garage']) do
            if v.plate == data.plate then
                props = json.decode(v.props)
            end
        end
        SpawnVehicleLocal(data.modelcar, props)
    end
end)

RegisterNUICallback("SpawnChopper",function(data, cb)
    if not Config.Quickpick then
        local props = nil
        for k,v in pairs(OwnedVehicles['garage']) do
            if v.plate == data.plate then
                props = json.decode(v.props)
            end
        end
        SpawnChopperLocal(data.modelcar, props)
    end
end)

RegisterNUICallback(
    "GetVehicleFromGarage",
    function(data, cb)
        local ped = PlayerPedId()
        local props = nil
        if props == nil then
            for k,v in pairs(OwnedVehicles['garage']) do
                if v.plate == data.plate then
                    props = json.decode(v.props)
                end
            end
        end
        local veh = nil
    ESX.TriggerServerCallback("renzu_garage:isvehicleingarage",function(stored,impound,garage,fee,sharedvehicle)
        if stored and impound == 0 or ispolice and string.find(garageid, "impound") or not Config.EnableReturnVehicle and impound ~= 1 or impound == 1 and not Config.EnableImpound then
            local tempcoord = {}
            if propertygarage then
                spawn = GetEntityCoords(PlayerPedId())
                found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(spawn.x + math.random(1, 2), spawn.y + math.random(1, 2), spawn.z, 0, 3, 0)
                --table.insert(garagecoord, {spawn_x = spawnPos.x, spawn_y = spawnPos.y, spawn_z = spawnPos.z, garage = gid, property = true})
                tid = propertygarage
                garageid = propertygarage
                if propertyspawn.x ~= nil then
                    spawnPos = vector3(propertyspawn.x,propertyspawn.y,propertyspawn.z)
                    spawnHeading = propertyspawn.w
                end
                tempcoord[tid] = {garage_x = myoldcoords.x, garage_y = myoldcoords.y, garage_z = myoldcoords.z, spawn_x = spawnPos.x*1.0, spawn_y = spawnPos.y*1.0, spawn_z = spawnPos.z*1.0, garage = propertygarage, property = true, Dist = 4, heading = spawnHeading*1.0}
                dist2 = #(vector3(spawnPos.x,spawnPos.y,spawnPos.z) - GetEntityCoords(PlayerPedId()))
            elseif string.find(garageid, "impound") then
                tempcoord[tid] = impoundcoord[tid]
            else
                tempcoord[tid] = garagecoord[tid]
            end
            --for k,v in pairs(garagecoord) do
                local actualShop = tempcoord[tid]
                local dist = #(vector3(tempcoord[tid].spawn_x,tempcoord[tid].spawn_y,tempcoord[tid].spawn_z) - GetEntityCoords(PlayerPedId()))
                if garageid == tempcoord[tid].garage or string.find(garageid, "impound") then
                    DoScreenFadeOut(333)
                    Citizen.Wait(333)
                    CheckWanderingVehicle(props.plate)
                    DeleteEntity(LastVehicleFromGarage)
                    Citizen.Wait(1000)
                    CheckWanderingVehicle(props.plate)
                    Citizen.Wait(333)
                    SetEntityCoords(PlayerPedId(), tempcoord[tid].garage_x,tempcoord[tid].garage_y,tempcoord[tid].garage_z, false, false, false, true)
                    local hash = tonumber(props.model)
                    local count = 0
                    if not HasModelLoaded(hash) then
                        RequestModel(hash)
                        while not HasModelLoaded(hash) do
                            count = count + 10
                            Citizen.Wait(1)
                        end
                    end
                    local vehicle = CreateVehicle(tonumber(props.model), actualShop.spawn_x,actualShop.spawn_y,actualShop.spawn_z, actualShop.heading, 1, 1)
                    SetVehicleProp(vehicle, props)
                    SetVehicleBobo(vehicle)
                    if not propertygarage then
                        Spawn_Vehicle_Forward(vehicle, vector3(actualShop.spawn_x,actualShop.spawn_y,actualShop.spawn_z))
                    end
                    veh = vehicle
                    DoScreenFadeIn(111)
                    while veh == nil do
                        Citizen.Wait(101)
                    end
                    NetworkFadeInEntity(vehicle,1)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    veh = vehicle
                end
            --end

            while veh == nil do
                Citizen.Wait(10)
            end
            ESX.TriggerServerCallback("renzu_garage:changestate",function(ret, garage_public)
                if ret and garage_public then
                    local ent = Entity(veh).state
                    while ent.share == nil do Wait(100) end
                    ent.haskeys = false
                    ent.hotwired = false
                    ent.unlock = true
                    local share = ent.share or {}
                    local add = true
                    for k,v in pairs(share) do
                        if k == v.PlayerData.identifier then
                            add = false
                        end
                    end
                    if add then
                        share[PlayerData.identifier] = PlayerData.identifier
                    end
                    ent.share = share
                    ent:set('share', share, true)
                    TriggerServerEvent('statebugupdate','share',share, VehToNet(veh))
                    print("SHARED VEHICLE")
                end
            end,props.plate, 0, garageid, props.model, props,false,garage_public)
            LastVehicleFromGarage = nil
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            CloseNui()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            SetVehicleEngineHealth(veh,props.engineHealth or 1000.0)
            if sharedvehicle then
                local ent = Entity(veh).state
                while ent.share == nil do Wait(100) end
                ent.haskeys = false
                ent.hotwired = false
                ent.unlock = true
                local share = ent.share or {}
                local add = true
                for k,v in pairs(share) do
                    if k == v.PlayerData.identifier then
                        add = false
                    end
                end
                if add then
                    share[PlayerData.identifier] = PlayerData.identifier
                end
                ent.share = share
                ent:set('share', share, true)
                TriggerServerEvent('statebugupdate','share',share, VehToNet(veh))
            end
            Wait(100)
            i = 0
            min = 0
            max = 10
            plus = 0
            drawtext = false
            indist = false
            if propertygarage or string.find(garageid, "impound") then
                tempcoord[tid] = nil
            end
            SendNUIMessage(
            {
            type = "cleanup"
            })
        elseif impound == 1 then
            SendNUIMessage(
            {
                type = "notify",
                typenotify = "display",
                message = Message[41],
            })
            Citizen.Wait(1000)
            SendNUIMessage(
            {
                type = "onimpound",
                garage = garage,
                fee = fee,
            })
        else
            SendNUIMessage(
            {
                type = "notify",
                typenotify = "display",
                message = Message[42],
            })
            Citizen.Wait(1000)
            SendNUIMessage(
            {
                type = "returnveh"
            }) 
        end
    end, props.plate,garageid,ispolice,patrolcars[props.plate] or false)
    end
)


RegisterNUICallback(
    "flychopper",
    function(data, cb)
        local ped = PlayerPedId()
        local veh = nil

        for k,v in pairs(helispawn[PlayerData.job.name]) do
            local v = v.coords
            local actualShop = v
            local dist = #(vector3(v.x,v.y,v.z) - GetEntityCoords(PlayerPedId()))
            if dist <= 10.0 then
                DoScreenFadeOut(333)
                Citizen.Wait(333)
                DeleteEntity(LastVehicleFromGarage)
                Citizen.Wait(1000)
                Citizen.Wait(333)
                SetEntityCoords(PlayerPedId(), v.x,v.y,v.z, false, false, false, true)
                local hash = GetHashKey(data.modelcar)
                local count = 0
                if not HasModelLoaded(hash) then
                    RequestModel(hash)
                    while not HasModelLoaded(hash) do
                        Citizen.Wait(1)
                    end
                end
                v = CreateVehicle(hash, actualShop.x,actualShop.y,actualShop.z, 256.0, 1, 1)
                SetVehicleBobo(vehicle)
                Spawn_Vehicle_Forward(v, vector3(actualShop.x,actualShop.y,actualShop.z))
                veh = v
                DoScreenFadeIn(333)
                while veh == nil do
                    Citizen.Wait(101)
                end
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                veh = v
            end
        end

        while veh == nil do
            Citizen.Wait(10)
        end
        LastVehicleFromGarage = nil
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        CloseNui()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        i = 0
        min = 0
        max = 10
        plus = 0
        drawtext = false
        indist = false
    end)

RegisterNUICallback(
    "ReturnVehicle",
    function(data, cb)
        DeleteEntity(LastVehicleFromGarage)
        local ped = PlayerPedId()
        local props = nil
        local veh = nil
        local bool = false
        for k,v in pairs(OwnedVehicles['garage']) do
            if v.plate == data.plate then
                props = json.decode(v.props)
            end
        end
        ESX.TriggerServerCallback("renzu_garage:returnpayment",function(canreturn)
            if canreturn then
                if propertygarage then
                    spawn = GetEntityCoords(PlayerPedId())
                    found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(spawn.x + math.random(1, 2), spawn.y + math.random(1, 2), spawn.z, 0, 3, 0)
                    --table.insert(garagecoord, {spawn_x = spawnPos.x, spawn_y = spawnPos.y, spawn_z = spawnPos.z, garage = gid, property = true})
                    tid = propertygarage
                    garageid = propertygarage
                    if propertyspawn.x ~= nil then
                        spawnPos = vector3(propertyspawn.x,propertyspawn.y,propertyspawn.z)
                        spawnHeading = propertyspawn.w
                    end
                    garagecoord[tid] = {garage_x = myoldcoords.x, garage_y = myoldcoords.y, garage_z = myoldcoords.z, spawn_x = spawnPos.x*1.0, spawn_y = spawnPos.y*1.0, spawn_z = spawnPos.z*1.0, garage = propertygarage, property = true, Dist = 4, heading = spawnHeading*1.0}
                    dist2 = #(vector3(spawnPos.x,spawnPos.y,spawnPos.z) - GetEntityCoords(PlayerPedId()))
                end
                --for k,v in pairs(garagecoord) do
                    local actualShop = garagecoord[tid]
                    local dist = #(vector3(garagecoord[tid].spawn_x,garagecoord[tid].spawn_y,garagecoord[tid].spawn_z) - GetEntityCoords(ped))
                    if garageid == garagecoord[tid].garage then
                        DoScreenFadeOut(333)
                        Citizen.Wait(111)
                        CheckWanderingVehicle(props.plate)
                        Citizen.Wait(555)
                        SetEntityCoords(PlayerPedId(), garagecoord[tid].garage_x,garagecoord[tid].garage_y,garagecoord[tid].garage_z, false, false, false, true)
                        Citizen.Wait(555)
                        local hash = tonumber(data.modelcar)
                        local count = 0
                        if not HasModelLoaded(hash) then
                            RequestModel(hash)
                            while not HasModelLoaded(hash) do
                                RequestModel(hash)
                                Citizen.Wait(1)
                            end
                        end
                        vehicle = CreateVehicle(tonumber(data.modelcar), actualShop.spawn_x,actualShop.spawn_y,actualShop.spawn_z, actualShop.heading, 1, 1)
                        SetVehicleBobo(vehicle)
                        SetVehicleProp(vehicle, props)
                        if not propertygarage then
                            Spawn_Vehicle_Forward(vehicle, vector3(actualShop.spawn_x,actualShop.spawn_y,actualShop.spawn_z))
                        end
                        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                        veh = vehicle
                        SetVehicleEngineHealth(v,props.engineHealth)
                        Wait(100)
                        DoScreenFadeIn(333)
                    end
                --end
                bool = true
                while veh == nil do
                    Citizen.Wait(1)
                end
                ESX.TriggerServerCallback("renzu_garage:changestate",function(ret,garage_public)
                    if ret and garage_public then
                        local ent = Entity(veh).state
                        while ent.share == nil do Wait(100) end
                        ent.haskeys = false
                        ent.hotwired = false
                        ent.unlock = true
                        local share = ent.share or {}
                        local add = true
                        for k,v in pairs(share) do
                            if k == v.PlayerData.identifier then
                                add = false
                            end
                        end
                        if add then
                            share[PlayerData.identifier] = PlayerData.identifier
                        end
                        ent.share = share
                        ent:set('share', share, true)
                        TriggerServerEvent('statebugupdate','share',share, VehToNet(veh))
                    end
                end,props.plate, 0, garageid, props.model, props,false,garage_public)
                LastVehicleFromGarage = nil
                Wait(111)
                CloseNui()
                i = 0
                min = 0
                max = 10
                plus = 0
                drawtext = false
                indist = false
                if propertygarage then
                    garagecoord[tid] = nil
                end
                SendNUIMessage({
                    type = "cleanup"
                })
            else
                TriggerEvent('renzu_notify:Notify', 'error',Message[2], Message[40])
                LastVehicleFromGarage = nil
                Wait(111)
                SetEntityCoords(PlayerPedId(), garagecoord[tid].garage_x,garagecoord[tid].garage_y,garagecoord[tid].garage_z, false, false, false, true)
                CloseNui()
                i = 0
                min = 0
                max = 10
                plus = 0
                drawtext = false
                indist = false
                SendNUIMessage({
                    type = "cleanup"
                })
            end
        end)
end)


RegisterNUICallback("Close",function(data, cb)
    DoScreenFadeOut(111)
    local ped = PlayerPedId()
    CloseNui()
    if string.find(garageid, "impound") then
        for k,v in pairs(impoundcoord) do
            local actualShop = v
            if v.garage_x ~= nil then
                local dist = #(vector3(v.garage_x,v.garage_y,v.garage_z) - GetEntityCoords(ped))
                if dist <= 40.0 and garageid == v.garage then
                    SetEntityCoords(ped, v.garage_x,v.garage_y,v.garage_z, 0, 0, 0, false)  
                end
            end
        end
    else
        for k,v in pairs(garagecoord) do
            local actualShop = v
            if v.garage_x ~= nil then
                local dist = #(vector3(v.garage_x,v.garage_y,v.garage_z) - GetEntityCoords(ped))
                if dist <= 40.0 and garageid == v.garage then
                    SetEntityCoords(ped, v.garage_x,v.garage_y,v.garage_z, 0, 0, 0, false)  
                end
            end
        end
    end
    DoScreenFadeIn(1000)
    DeleteGarage()
end)

AddEventHandler("onResourceStop",function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CloseNui()
    end
end)