-- begin Just Another Mod
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function ReturnCharacterHandler(sourceID)
	local playername = ''
	local data = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE identifier=@identifier",{['@identifier'] = sourceID})
	for key,val in pairs(data) do
		playername = val.firstname .. " " .. val.lastname
		return playername
	end
end

ESX.RegisterServerCallback('ReturnCharacterName', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local str = ReturnCharacterHandler(xPlayer.getIdentifier())
	cb(str)
end)	
--- end JAM

local logEnabled = true

RegisterServerEvent('3dme:shareDisplay')
AddEventHandler('3dme:shareDisplay', function(text)
	TriggerClientEvent('3dme:triggerDisplay', -1, text, source)
	if logEnabled then
		setLog(text, source)
	end
end)

function setLog(text, source)
	local time = os.date("%d/%m/%Y %X")
	local name = GetPlayerName(source)
	local identifier = GetPlayerIdentifiers(source)
	local data = time .. ' : ' .. name .. ' - ' .. identifier[1] .. ' : ' .. text

	local content = LoadResourceFile(GetCurrentResourceName(), "log.txt")
	local newContent = content .. '\r\n' .. data
	SaveResourceFile(GetCurrentResourceName(), "log.txt", newContent, -1)
end

