ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('gn-pmenu:intentararrestar')
AddEventHandler('gn-pmenu:intentararrestar', function(targetid, playerheading, playerCoords,  playerlocation)
    _source = source
    TriggerClientEvent('gn-pmenu:arrestar', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('gn-pmenu:haceraninarres', _source)
end)

RegisterServerEvent('gn-pmenu:intentardesesposar')
AddEventHandler('gn-pmenu:intentardesesposar', function(targetid, playerheading, playerCoords,  playerlocation)
    _source = source
    TriggerClientEvent('gn-pmenu:desesposar', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('gn-pmenu:haceranindespo', _source)
end)


ESX.RegisterServerCallback('gn-pmenu:getData', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		local data = {
			name = xPlayer.getName(),
			job = xPlayer.job.label,
			grade = xPlayer.job.grade_label,
			inventory = xPlayer.getInventory(),
			accounts = xPlayer.getAccounts(),
            identifier   = xPlayer.identifier,
			weapons = xPlayer.getLoadout()
		}
        data.dob = xPlayer.get('dateofbirth')
        data.height = xPlayer.get('height')

        if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end

		TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
			if status then
				data.drunk = ESX.Math.Round(status.percent)
			end

        TriggerEvent('esx_license:getLicenses', target, function(licenses)
                data.licenses = licenses
                
            end)
		end)
        cb(data)
	end
end)

RegisterNetEvent('gn-pmenu:confiscarItem')
AddEventHandler('gn-pmenu:confiscarItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		if targetItem.count > 0 and targetItem.count <= amount then
			if sourceXPlayer.canCarryItem(itemName, sourceItem.count) then
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem(itemName, amount)
				sourceXPlayer.showNotification("Has robado x" ..amount.. " de " ..sourceItem.label .. " - " ..sourceXPlayer.name)
				targetXPlayer.showNotification("Te han robado x" ..amount.. " de " ..sourceItem.label .. " - " ..sourceXPlayer.name)
			else
				sourceXPlayer.showNotification("No puedes llevar más unidades de este item")
			end
		else
			sourceXPlayer.showNotification("Cantidad invalida")
		end

	elseif itemType == 'item_account' then
		targetXPlayer.removeAccountMoney(itemName, amount)
		sourceXPlayer.addAccountMoney(itemName, amount)

		sourceXPlayer.showNotification("Has robado " .. amount .. " de " .. itemName .. " para " ..targetXPlayer.name)
		targetXPlayer.showNotification("Te han robado " .. amount .. " de " .. itemName .. " para " ..targetXPlayer.name)

	elseif itemType == 'item_weapon' then
		if amount == nil then amount = 0 end
		targetXPlayer.removeWeapon(itemName, amount)
		sourceXPlayer.addWeapon(itemName, amount)

		sourceXPlayer.showNotification("Has robado el arma " .. ESX.GetWeaponLabel(itemName) .. " - " .. targetXPlayer.name.. " bala(s) x" ..amount)
		targetXPlayer.showNotification("Te han robado el arma " .. ESX.GetWeaponLabel(itemName) .. " - " .. targetXPlayer.name.. " bala(s) x" ..amount)
	end
end)


RegisterServerEvent('gn-pmenu:meterencoche')
AddEventHandler('gn-pmenu:meterencoche', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	print(target)
	TriggerClientEvent('gn-pmenu:meterencoche_c', target)
end)

RegisterServerEvent('gn-pmenu:sacardekcoche')
AddEventHandler('gn-pmenu:sacardekcoche', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if target == 0 then
        xPlayer.showNotification('Not players near')
    else
        TriggerClientEvent('gn-pmenu:sacardekcoche_c', target)
    end
end)

RegisterServerEvent('gn-pmenu:escoltar')
AddEventHandler('gn-pmenu:escoltar', function(target)
    TriggerClientEvent('gn-pmenu:escoltar_c', target, source)
end)

