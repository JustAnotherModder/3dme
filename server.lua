JAM_Garage = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)	

function JAM_Garage:GetPlayerVehicles(identifier)	
	local playerVehicles = {}
	local data = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles WHERE owner=@identifier",{['@identifier'] = identifier})	
	for key,val in pairs(data) do
		local playerVehicle = json.decode(val.vehicle)
		table.insert(playerVehicles, {owner = val.owner, veh = val.vehicle, vehicle = playerVehicle, plate = val.plate, state = val.state})
	end
	return playerVehicles
end

ESX.RegisterServerCallback('JAM_Garage:StoreVehicle', function(source, cb, vehicleProps)
	local isFound = false
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then return; end

	local playerVehicles = JAM_Garage:GetPlayerVehicles(xPlayer.getIdentifier())
	local plate = vehicleProps.plate

	for key,val in pairs(playerVehicles) do
		if(plate == val.plate) then
			local vehProps = json.encode(vehicleProps)
			MySQL.Sync.execute("UPDATE owned_vehicles SET vehicle=@vehProps WHERE plate=@plate",{['@vehProps'] = vehProps, ['@plate'] = val.plate})
			isFound = true
			break
		end
	end
	cb(isFound)
end)

ESX.RegisterServerCallback('JAM_Garage:GetVehicles', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then return; end

	local vehicles = JAM_Garage:GetPlayerVehicles(xPlayer.getIdentifier())

	cb(vehicles)
end)

RegisterNetEvent('JAM_Garage:ChangeState')
AddEventHandler('JAM_Garage:ChangeState', function(plate, state)
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then return; end

	local vehicles = JAM_Garage:GetPlayerVehicles(xPlayer.getIdentifier())
	for key,val in pairs(vehicles) do
		if(plate == val.plate) then
			MySQL.Sync.execute("UPDATE owned_vehicles SET state =@state WHERE plate=@plate",{['@state'] = state , ['@plate'] = plate})
			break
		end		
	end
end)

-- Console = dofile("Console.lua")
function JAM_Garage.Startup()
	
	-- print( Console:Start() )

	local data = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles")
	for key,val in pairs(data) do
	  	if not val.state
	  	then
	   		MySQL.Sync.fetchAll("ALTER TABLE `owned_vehicles` ADD `state` int(11) NOT NULL;")
	  	end
	  	return
	end
end

-- function Console:Start()
--   if not self then return Console:Start(); end;
--   if self.started then return true, "Already started..."; end;
--   self.started = true
--   if    not Citizen or not Citizen.CreateThread then return false, "not Citizen or not Citizen.CreateThread"; end;
--   Citizen.CreateThread(Console.ThreadUpdate)
--   return true
-- end

RegisterNetEvent('JAM_Garage:Startup')
AddEventHandler('JAM_Garage:Startup', JAM_Garage.Startup)
