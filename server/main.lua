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
AddEventHandler('esx_DatabaseInsert:StoreVehicle', function(closestVehiclePlate, closestVehicleProperties, closestVehicleHash, closestVehicleName, fuelLevel)
    local xPlayer = ESX.GetPlayerFromId(source)

    local plate = closestVehiclePlate
    local fuel = fuelLevel
    local vehicle = json.encode(closestVehicleProperties)

    xPlayer.showNotification('Vehicle stored')

    MySQL.Sync.execute("UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, fuel = @fuel, state = @state WHERE owner = @identifier AND plate = @plate", {
        ['@vehicle'] = vehicle,
        ['@identifier'] = xPlayer.getIdentifier(),
        ['@plate'] = plate,
        ['@garage'] = 'Housing Garage',
        ['@state'] = 1
    }, function(result2)
        
    end)
end)

--[[
ESX.RegisterServerCallback('esx_DatabaseInsert:StoreVehicle', function(source, cb, closestVehiclePlate, closestVehicleProperties, closestVehicleHash, closestVehicleName, fuelLevel)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerIdentifier = xPlayer.getIdentifier()

    local plate = closestVehiclePlate
    local fuel = fuelLevel
    local vehicle = json.encode(closestVehicleProperties)

    MySQL.Sync.execute("UPDATE owned_vehicles SET vehicle = @vehicle, garage = @garage, fuel = @fuel, state = @state WHERE owner = @identifier AND plate = @plate", {
        ['@vehicle'] = vehicle,
        ['@identifier'] = xPlayer.getIdentifier(),
        ['@plate'] = plate,
        ['@garage'] = 'Housing Garage',
        ['@fuel'] = fuel,
        ['@state'] = 1
    }, function(result2)
        xPlayer.showNotification('Vehicle stored')
    end)
end)
]]

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