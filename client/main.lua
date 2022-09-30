local PlayerData = {}
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
    end
end)  

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

-- Variables
local handcuff = false
local drag = false
local dragUser = nil
local CinematicCamBool = false
local w = 0
local CinematicCamMaxHeight = 0.4

-- Key

RegisterKeyMapping("menuInteracciones", "Menu de Interacciones", "keyboard", "F10")
RegisterCommand("menuInteracciones", function()
    menuInteracciones()
end)


-- Menu interacciones

function menuInteracciones()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'menu_personal',
    {
      title    = 'Menu de interacciones',
      align    = 'bottom-right',
      elements = {
        {label = "General", value = 'docs'},
        {label = "Interacciones", value = 'int'},
        {label = "Estetica", value = 'est'},
        {label = "Otras interacciones", value = 'otrint'},
    }
  },
    function(data, menu)

        local player, distance = ESX.Game.GetClosestPlayer()

        if data.current.value == 'docs' then
            menuDocs()
        elseif data.current.value == 'int' then
            menuInt()
        elseif data.current.value == 'est' then
            menuEst()
        elseif data.current.value == 'otrint' then
            menuOtros()
        end
    end,
    function(data, menu)
      menu.close()
    end)
end


-- Menu de documentos

function menuDocs()

    local dJob = ESX.GetPlayerData()
    local id = GetPlayerServerId(PlayerId())
    local job = dJob.job.label
    local jobgrade = dJob.job.grade_label
    local name = GetPlayerName(PlayerId())

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_doc', {
        title = 'General', 
        align = 'bottom-right',
        elements = {
            {label = "Trabajo: " .. job .. " - " .. jobgrade, value = 'job'},
            {label = 'Ver DNI', value = 'revid'},
            {label = 'Enseñar DNI', value = 'enid'},
            {label = 'Ver Licencia de Conducir', value = 'revcon'},
            {label = 'Enseñar Licencia de Conducir', value = 'encon'},
            {label = 'Ver Licencia de Armas', value = 'revarma'},
            {label = 'Enseñar Licencia de Armas', value = 'enarma'},
        }
    
    }, function(data, menu)
        if data.current.value == 'revid' then
            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId())) 
        elseif data.current.value == 'enid' then
            local player, distance = ESX.Game.GetClosestPlayer()
  
            if distance ~= -1 and distance <= 3.0 then
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
            else
                ESX.ShowNotification('No hay nadie cerca')
            end
  
        elseif data.current.value == 'revcon' then
            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
        elseif data.current.value == 'encon' then
            local player, distance = ESX.Game.GetClosestPlayer()
  
            if distance ~= -1 and distance <= 3.0 then
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'driver')
            else
                ESX.ShowNotification('No hay nadie cerca')
            end
        elseif data.current.value == 'revarma' then
            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
        elseif data.current.value == 'enarma' then
            local player, distance = ESX.Game.GetClosestPlayer()
  
            if distance ~= -1 and distance <= 3.0 then
                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'weapon')
            else
                ESX.ShowNotification('No hay nadie cerca')
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Menu de Interacciones

function menuInt()
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'menu_int',
      {
        title    = 'Otras interacciones',
        align    = 'bottom-right',
        elements = {
          {label = "Interacciones Ilicitas", value = 'ili'},
          {label = "Posicionamiento de arma", value = 'holster'},
      }
    },
      function(data, menu)
            local player, distance = ESX.Game.GetClosestPlayer()
    
            if data.current.value == 'ili' then
                menuIlegal()
            elseif data.current.value == 'holster' then
                OpenHolsterMenu()
            end
        end,
        function(data, menu)
            menu.close()
    end)
end

-- Estetica

function menuEst()
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'menu_nit',
      {
        title    = 'Estetica',
        align    = 'bottom-right',
        elements = {
          {label = "Modo cine", value = 'cine'},
          {label = "Rockstar Editor", value = 'rockstar'},
      }
    },
      function(data, menu)
            local player, distance = ESX.Game.GetClosestPlayer()
    
            if data.current.value == 'cine' then
                CinematicCamBool = not CinematicCamBool
                CinematicCamDisplay(CinematicCamBool)
            elseif data.current.value == 'rockstar' then
                menuRockstar()
            end
        end,
        function(data, menu)
            menu.close()
    end)
end


Citizen.CreateThread(function()

    minimap = RequestScaleformMovie("minimap")

    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do 
            Wait(1)
        end
    end

    while true do
        Citizen.Wait(1)
        if w > 0 then
            DrawRects()
        end
        if CinematicCamBool then
            DESTROYHudComponents()
        end
    end
end)

function DESTROYHudComponents() -- [[Get rid of all active hud components.]]
    for i = 0, 22, 1 do
        if IsHudComponentActive(i) then
            HideHudComponentThisFrame(i)
        end
    end
end

function DrawRects() -- [[Draw the Black Rects]]
    DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
end

function DisplayHealthArmour(int) -- [[Thanks to GlitchDetector for this function.]]
    BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(int)
    EndScaleformMovieMethod()
end

function CinematicCamDisplay(bool) -- [[Handles Displaying Radar, Body Armour and the rects themselves.]]
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    if bool then
        DisplayRadar(false)
        DisplayHealthArmour(3)
        for i = 0, CinematicCamMaxHeight, 0.01 do 
            Wait(10)
            w = i
        end
    else
        DisplayRadar(true)
        DisplayHealthArmour(0)
        for i = CinematicCamMaxHeight, 0, -0.01 do
            Wait(10)
            w = i
        end 
    end
end    


-- Holster

function OpenHolsterMenu()


	local elements = {}
	table.insert(elements, {label = "Posición de Pistolas", menu = 'pistolas'})
	table.insert(elements, {label = "Posición de Rifles y SMG", menu = 'rifles'})

	ESX.UI.Menu.Open('default',GetCurrentResourceName(),"holster",
	{ 
		title = "Menú de Personalización de Armas", 
		align = "bottom-right", 
		elements = elements 
	}, function(data_interact, menu_interact)
		local item = data_interact.current.menu
		if data_interact.current.menu == "pistolas" then
			OpenPistolsMenu()
		elseif data_interact.current.menu == "rifles" then
			OpenRiflesMenu()
		end
	end, function(data_interact, menu_interact) 
		menu_interact.close() 
	end)
end

function OpenPistolsMenu()
	local elements = {}
	table.insert(elements, {label = "Pistola delante", command = 'boxers'})
	table.insert(elements, {label = "Pistola detrás", command = 'backhandgun'})
	table.insert(elements, {label = "Cartuchera cintura", command = 'waisthandgun'})
	table.insert(elements, {label = "Cartuchera normal", command = 'handguns'})
	table.insert(elements, {label = "Cartuchera pecho", command = 'chesthandgun'})
	table.insert(elements, {label = "Cartuchera muslo", command = 'hiphandgun'})
	table.insert(elements, {label = "Cartuchera pierna", command = 'leghandgun'})
	table.insert(elements, {label = "Cartuchera pierna separada", command = 'handguns2'})
	

		ESX.UI.Menu.Open('default',GetCurrentResourceName(),"pistols",
		{ 
			title = "Menú de Posición para Pistolas", 
			align = "bottom-right", 
			elements = elements 
		}, function(data_interact, menu_interact)
			if data_interact.current.command ~= nil then
				ExecuteCommand("holster " .. data_interact.current.command)
			end
		end, function(data_interact, menu_interact)
		OpenHolsterMenu()
		menu_interact.close() 
	end)
end

function OpenRiflesMenu()
	local elements = {}
	table.insert(elements, {label = "Rifle pecho", command = 'tacticalrifle'})
	table.insert(elements, {label = "Rifle espalda", command = 'assault'})

		ESX.UI.Menu.Open('default',GetCurrentResourceName(),"rifles",
		{ 
			title = "Menú de Posición para Rifles", 
			align = "bottom-right", 
			elements = elements 
		}, function(data_interact, menu_interact)
			if data_interact.current.command ~= nil then
				ExecuteCommand("holster " .. data_interact.current.command)
			end
		end, function(data_interact, menu_interact)
		OpenHolsterMenu()
		menu_interact.close() 
	end)
end

-- Menu otros

function menuOtros()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'menu_otros',
      {
        title    = 'Menu de interacciones',
        align    = 'bottom-right',
        elements = {
          {label = "Reiniciar Voz", value = 'rvoz'},
          {label = "Reiniciar PJ", value = 'fixpj'},
          {label = "Entornos", value = 'entornos'},
      }
    },
      function(data, menu)
            local player, distance = ESX.Game.GetClosestPlayer()
    
            if data.current.value == 'rvoz' then
                NetworkClearVoiceChannel()
                NetworkSessionVoiceLeave()
                Wait(50)
                NetworkSetVoiceActive(false)
                MumbleClearVoiceTarget(2)
                Wait(1000)
                MumbleSetVoiceTarget(2)
                NetworkSetVoiceActive(true)
                ESX.ShowNotification('~g~Chat de voz reiniciado.')
            elseif data.current.value == 'fixpj' then
                local hp = GetEntityHealth(GetPlayerPed(-1))
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                    local isMale = skin.sex == 0
                    TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                            TriggerEvent('skinchanger:loadSkin', skin)
                            TriggerEvent('dpc:ApplyClothing')
                            SetEntityHealth(GetPlayerPed(-1), hp)
                        end)
                    end)
                end)
            elseif data.current.value == 'entornos' then
                --
            end
        end,
        function(data, menu)
            menu.close()
      end)
end

-- Rockstar Editor

function menuRockstar()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'menu_rockstar',
      {
        title    = 'Otras interacciones',
        align    = 'bottom-right',
        elements = {
          {label = "Iniciar grabación", value = 'iniciar'},
          {label = "Guardar grabación", value = 'parar'},
          {label = "Eliminar grabación", value = 'eliminar'},
          {label = "Entrar al Rockstar Editor", value = 'entrarrk'},
      }
    },
      function(data, menu)
            local player, distance = ESX.Game.GetClosestPlayer()
    
            if data.current.value == 'iniciar' then
                StartRecording(1)
                notify("Has comenzado a grabar")
            elseif data.current.value == 'parar' then
                StartRecording(0) 
                StopRecordingAndSaveClip() 
                notify("Has guardado el clip")
            elseif data.current.value == 'eliminar' then
                StopRecordingAndDiscardClip() 
                notify("Clip eliminado")
            elseif data.current.value == 'entrarrk' then
                notify("Entrando al editor de rockstar...")
                NetworkSessionLeaveSinglePlayer() 
                ActivateRockstarEditor()
            end
        end,
        function(data, menu)
            menu.close()
      end)
end

-- Menu ilegales

function menuIlegal()

    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()


    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_ilegales', {
        title = 'Menu de Interacciones Ilicitas', 
        align = 'bottom-right',
        elements = {
            {label = 'Cachear', value = 'cachear'},
            {label = 'Esposar', value = 'esposar'},
            {label = 'Desesposar', value = 'desesposar'},
            {label = 'Meter al coche', value = 'mcoche'},
            {label = 'Sacar del coche', value = 'scoche'},
            {label = 'Escoltar', value = 'escoltar'},
        }
    
    }, function(data, menu)
        if data.current.value == 'cachear' then
            local player, distance = ESX.Game.GetClosestPlayer()
            if distance < 3 and distance ~= -1 and player then
                Cachear(player)
            else
                ESX.ShowNotification("No hay nadie cerca")
            end
        elseif data.current.value == 'esposar' then
            local target, distance = ESX.Game.GetClosestPlayer()
            playerheading = GetEntityHeading(GetPlayerPed(-1))
            playerlocation = GetEntityForwardVector(PlayerPedId())
            playerCoords = GetEntityCoords(GetPlayerPed(-1))
            local target_id = GetPlayerServerId(target)
            if distance <= 2.0 then
                TriggerServerEvent('gn-pmenu:intentararrestar', target_id, playerheading, playerCoords, playerlocation)
            else
                ESX.ShowNotification('No hay nadie cerca.')
            end
        elseif data.current.value == 'desesposar' then
            local target, distance = ESX.Game.GetClosestPlayer()
            playerheading = GetEntityHeading(GetPlayerPed(-1))
            playerlocation = GetEntityForwardVector(PlayerPedId())
            playerCoords = GetEntityCoords(GetPlayerPed(-1))
            local target_id = GetPlayerServerId(target)
            if distance <= 2.0 then
                TriggerServerEvent('gn-pmenu:intentardesesposar', target_id, playerheading, playerCoords, playerlocation)
            else
                ESX.ShowNotification('No hay nadie cerca.')
            end	
        elseif data.current.value == 'mcoche' then
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('gn-pmenu:meterencoche', GetPlayerServerId(closestPlayer))
        elseif data.current.value == 'scoche' then     
            local player, distance = ESX.Game.GetClosestPlayer()
            ClearPedTasks(PlayerPedId())
            TriggerServerEvent('gn-pmenu:sacardekcoche', GetPlayerServerId(closestPlayer))          
        elseif data.current.value == 'escoltar' then  
            local player, distance = ESX.Game.GetClosestPlayer()
                if distance < 3 and distance ~= -1  and player then
                    TriggerServerEvent('gn-pmenu:escoltar', GetPlayerServerId(player))
                    if not isDragging then
                        ESX.Streaming.RequestAnimDict('switch@trevor@escorted_out', function()
                            TaskPlayAnim(PlayerPedId(), 'switch@trevor@escorted_out', '001215_02_trvs_12_escorted_out_idle_guard2', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                        end)
                        isDragging = true
                    else
                        Wait(500)
                        ClearPedTasks(PlayerPedId())
                        isDragging = false
                    end
                end  
        end
    end, function(data, menu)
        menu.close()
    end)
end


RegisterNetEvent('gn-pmenu:arrestar')
AddEventHandler('gn-pmenu:arrestar', function(playerheading, playercoords, playerlocation)
	playerPed = GetPlayerPed(-1)
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Citizen.Wait(250)
	loadanimdict('mp_arrest_paired')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0)
	Citizen.Wait(3760)
	handcuff = true
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
end)

RegisterNetEvent('gn-pmenu:haceraninarres')
AddEventHandler('gn-pmenu:haceraninarres', function()
	Citizen.Wait(250)
	loadanimdict('mp_arrest_paired')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
	Citizen.Wait(3000)
end) 

RegisterNetEvent('gn-pmenu:desesposar')
AddEventHandler('gn-pmenu:desesposar', function(playerheading, playercoords, playerlocation)
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z)
	SetEntityHeading(GetPlayerPed(-1), playerheading)
	Citizen.Wait(250)
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Citizen.Wait(5500)
	handcuff = false
	ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('gn-pmenu:haceranindespo')
AddEventHandler('gn-pmenu:haceranindespo', function()
	Citizen.Wait(250)
	loadanimdict('mp_arresting')
	TaskPlayAnim(GetPlayerPed(-1), 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
	Citizen.Wait(5500)
	ClearPedTasks(GetPlayerPed(-1))
end)

function Cachear(player)
    ESX.TriggerServerCallback('gn-pmenu:getData', function(data)
        local elements = {}

        for i=1, #data.accounts, 1 do
            if data.accounts[i].name == 'money' and data.accounts[i].money > 0 then
                table.insert(elements, {
                    label    = "Robar: "..'<strong><span style="color:green;">' ..ESX.Math.GroupDigits(ESX.Math.Round(data.accounts[i].money)).."$</span></strong>",
                    value    = 'money',
                    itemType = 'item_account',
                    amount   = data.accounts[i].money
                })
            end
            if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
                table.insert(elements, {
                    label    = "Robar" ..'<strong><span style="color:red;">' ..ESX.Math.GroupDigits(ESX.Math.Round(data.accounts[i].money)).."$</span></strong>",
                    value    = 'black_money',
                    itemType = 'item_account',
                    amount   = data.accounts[i].money
                })
            end
        end

        table.insert(elements, {label = '<--> Armas <-->'})

        for i=1, #data.weapons, 1 do
            table.insert(elements, {
                label    = "Robar: " ..ESX.GetWeaponLabel(data.weapons[i].name).. " - " ..data.weapons[i].ammo .." bala(s)",
                value    = data.weapons[i].name,
                itemType = 'item_weapon',
                amount   = data.weapons[i].ammo
            })
        end

        table.insert(elements, {label = ('<--> Inventario <-->')})

        for i=1, #data.inventory, 1 do
            if data.inventory[i].count > 0 then
                table.insert(elements, {
                    label    = "Robar: " .. data.inventory[i].label ..' x'..data.inventory[i].count,
                    value    = data.inventory[i].name,
                    itemType = 'item_standard',
                    amount   = data.inventory[i].count
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
            title    = "Cacheo",
            align    = 'bottom-right',
            elements = elements
        }, function(data, menu)
            if data.current.value then
                TriggerServerEvent('gn-pmenu:confiscarItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
                Cachear(player)
            end
        end, function(data, menu)
            menu.close()
        end)
    end, GetPlayerServerId(player))
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')
    while not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@') do Wait(0) end
        TaskPlayAnim(PlayerPedId(), 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 1.0, 3000, 49, 0, 0, 0, 0)

    Wait(3000)
	
end

RegisterNetEvent('gn-pmenu:meterencoche_c')
AddEventHandler('gn-pmenu:meterencoche_c', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
			end
		end
	end
end)


RegisterNetEvent('gn-pmenu:sacardekcoche_c')
AddEventHandler('gn-pmenu:sacardekcoche_c', function()
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 16)
        Citizen.Wait(1000)
        loadanimdict('mp_arresting')
        TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
	end
end)

RegisterNetEvent('gn-pmenu:escoltar_c')
AddEventHandler('gn-pmenu:escoltar_c', function(playerWhoDrag)
	if handcuff then
        drag = not drag
        dragUser = playerWhoDrag
	end
end)

Citizen.CreateThread(function()
	local wasDragged

	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if handcuff and drag then
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragUser))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.10, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					wasDragged = true
				else
					Citizen.Wait(1000)
				end
			else
				wasDragged = false
				drag = false
				DetachEntity(playerPed, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(playerPed, true, false)
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if handcuff == true then
			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 21, true)
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			--DisableControlAction(0, 32, true) -- W
			--DisableControlAction(0, 34, true) -- A
			--DisableControlAction(0, 31, true) -- S
			--DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			--DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(1500)
		end
	end
end)

function loadanimdict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end


function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(100)
	end
end

function CheckWeapon(ped, newWeap)
	if IsEntityDead(ped) then
		blocked = false
			return false
		else
			for i = 1, #realWeapons do
				if GetHashKey(realWeapons[i].name) == GetSelectedPedWeapon(ped) then
					return true
				end
			end
		return false
	end
end
