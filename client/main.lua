ESX              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterCommand('_databaseinsert:veh', function(source, args)
	local owner = args[1]

	if args[1] == nil then
		ESX.ShowNotification('~r~[ERROR]~w~ You must input a player server ID for the new owner!')
	else
		InsertVehicle(owner)
	end
end)

RegisterCommand('_storetrailer', function()
	StoreTrailer()
end)

function StoreTrailer()
	local closestVehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
	local closestVehicleCoords = GetEntityCoords(closestVehicle)
	

	if #(GetEntityCoords(PlayerPedId()) - closestVehicleCoords) <= Config.VehicleDistance then
		local closestVehiclePlate = GetVehicleNumberPlateText(closestVehicle)
		local closestVehicleProperties = ESX.Game.GetVehicleProperties(closestVehicle)
		local closestVehicleHash = ESX.Game.GetVehicleProperties(closestVehicle).model
		local closestVehicleName = GetDisplayNameFromVehicleModel(closestVehicleHash)
		local fuelLevel = GetVehicleFuelLevel(closestVehicle)
		ESX.TriggerServerCallback('esx_DatabaseInsert:DoesPlayerOwnVehicle', function(ownVehicle)
			if ownVehicle then
				TriggerServerEvent('esx_DatabaseInsert:StoreVehicle', closestVehiclePlate, closestVehicleProperties, closestVehicleHash, closestVehicleName, fuelLevel, closestVehicle)
			else
				ESX.ShowNotification('~r~[ERROR]~w~ You do not own that vehicle!')
			end
		end, closestVehiclePlate)
	else
		ESX.ShowHelpNotification('~r~[ERROR]~w~ No nearby vehicle')
	end
end

function InsertVehicle(ownerID)
	local closestVehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(PlayerPedId()))
	local closestVehicleCoords = GetEntityCoords(closestVehicle)

	if #(GetEntityCoords(PlayerPedId()) - closestVehicleCoords) <= Config.VehicleDistance then
		local closestVehiclePlate = GetVehicleNumberPlateText(closestVehicle)
		local closestVehicleProperties = ESX.Game.GetVehicleProperties(closestVehicle)
		local closestVehicleHash = ESX.Game.GetVehicleProperties(closestVehicle).model
		local closestVehicleName = GetDisplayNameFromVehicleModel(closestVehicleHash)

		TriggerServerEvent('esx_DatabaseInsert:InsertVehicle', ownerID, closestVehiclePlate, closestVehicleProperties, closestVehicleHash, closestVehicleName)
	else
		ESX.ShowHelpNotification('~r~[ERROR]~w~ No nearby vehicle')
	end
end

RegisterNetEvent('esx_DatabaseInsert:DeleteVehicle')
AddEventHandler('esx_DatabaseInsert:DeleteVehicle', function(vehicle)
	DeleteVehicle(vehicle)
end)