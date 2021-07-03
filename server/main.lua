ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_DatabaseInsert:InsertVehicle')
AddEventHandler('esx_DatabaseInsert:InsertVehicle', function(ownerID, closestVehiclePlate, closestVehicleProperties, closestVehicleHash, closestVehicleName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerIdentifier = xPlayer.getIdentifier()

    if source == ownerID then
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
            ['@owner']   = xPlayer.identifier,
            ['@plate']   = closestVehiclePlate,
            ['@vehicle'] = json.encode(closestVehicleProperties)
        }, function(rowsChanged)
            xPlayer.showNotification('The plate ~b~' .. closestVehiclePlate .. ' ~w~ now belongs to you!')
        end)
    else
        local yPlayer = ESX.GetPlayerFromId(ownerID)
        local yPlayerIdentifier = yPlayer.getIdentifier()
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
            ['@owner']   = yPlayer.identifier,
            ['@plate']   = closestVehiclePlate,
            ['@vehicle'] = json.encode(closestVehicleProperties)
        }, function(rowsChanged)
            yPlayer.showNotification('The plate ~b~' .. closestVehiclePlate .. ' ~w~ now belongs to you!')
        end)
    end
end)

RegisterServerEvent('esx_DatabaseInsert:StoreVehicle')
AddEventHandler('esx_DatabaseInsert:StoreVehicle', function(closestVehiclePlate, closestVehicleProperties, closestVehicleHash, closestVehicleName, fuelLevel, closestVehicle)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Print to server log
    if Config.EnableDebug then
    print('Attempting to store plate with the following conditions')
    print('Vehicle: ' .. json.encode(closestVehicleProperties))
    print('Identifier: ' .. xPlayer.identifier)
    print('Plate: ' .. closestVehiclePlate)
    print('Garage: Housing Garage')
    print('State: 1')
    end

    -- Show the player a notification
    xPlayer.showNotification('Vehicle: ~y~' .. closestVehicleName .. ' ~w~has been stored!')

    -- Update the database
    MySQL.Sync.execute('UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, fuel = @fuel, state = @state WHERE owner = @identifier AND plate = @plate', {
        ['@vehicle'] = json.encode(closestVehicleProperties),
        ['@identifier'] = xPlayer.identifier,
        ['@plate'] = closestVehiclePlate,
        ['@garage'] = "Housing Garage",
        ['@state'] = 1
    }, function(afterinsert)
        
    end)

    -- Trigger Event to delete vehicle
    TriggerClientEvent('esx_DatabaseInsert:DeleteVehicle', -1, closestVehicle)
end)

ESX.RegisterServerCallback('esx_DatabaseInsert:DoesPlayerOwnVehicle', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
            if result[1].owner == xPlayer.identifier then
                cb(true)
            else
                cb(false)
            end
	end)
end)