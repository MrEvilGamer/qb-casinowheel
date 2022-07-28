QBCore = exports['qb-core']:GetCoreObject()
local _wheel = nil
local _lambo = nil
local _wheelPos = Config.WheelPos
local _baseWheelPos = Config.BaseWheelPos
local _isRolling = false

CreateThread(function()
    local model = GetHashKey('vw_prop_vw_luckywheel_02a')
    local baseWheelModel = GetHashKey('vw_prop_vw_luckywheel_01a')
    local carmodel = GetHashKey(Config.CarModel)

    CreateThread(function()
        -- Base wheel
        RequestModel(baseWheelModel)
        while not HasModelLoaded(baseWheelModel) do
            Wait(0)
        end
        _basewheel = CreateObject(baseWheelModel, _baseWheelPos.x, _baseWheelPos.y, _baseWheelPos.z, false, false, true)
        SetEntityHeading(_basewheel, 328.0)
        SetModelAsNoLongerNeeded(baseWheelModel)

        -- Wheel
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
        _wheel = CreateObject(model, 990.28, 42.84, 70.50, false, false, true)
        SetEntityHeading(_wheel, 328.0)
        SetModelAsNoLongerNeeded(model)
        
        -- Car
        RequestModel(carmodel)
        while not HasModelLoaded(carmodel) do
            Wait(0)
        end
        local vehicle = CreateVehicle(carmodel, 975.69, 40.21, 71.71, 360.07, false, false)
        SetModelAsNoLongerNeeded(carmodel)
        FreezeEntityPosition(vehicle, true)
        local _curPos = GetEntityCoords(vehicle)
        SetEntityCoords(vehicle, _curPos.x, _curPos.y, _curPos.z + 1, false, false, true, true)
        _lambo = vehicle
        
    end)
end)

CreateThread(function() 
    while true do
        if _lambo ~= nil then
            local _heading = GetEntityHeading(_lambo)
            local _z = _heading - 0.3
            SetEntityHeading(_lambo, _z)
        end
        Wait(5)
    end
end)

RegisterNetEvent("qb-casinowheel:doRoll", function(_priceIndex) 
    _isRolling = true
    SetEntityHeading(_wheel, 328.0)
    SetEntityRotation(_wheel, 0.0, 0.0, 0.0, 1, true)
    CreateThread(function()
        local speedIntCnt = 1
        local rollspeed = 1.0
        local _winAngle = (_priceIndex - 1) * 18
        local _rollAngle = _winAngle + (360 * 8)
        local _midLength = (_rollAngle / 2)
        local intCnt = 0
        while speedIntCnt > 0 do
            local retval = GetEntityRotation(_wheel, 1)
            if _rollAngle > _midLength then
                speedIntCnt = speedIntCnt + 1
            else
                speedIntCnt = speedIntCnt - 1
                if speedIntCnt < 0 then
                    speedIntCnt = 0
                end
            end
            intCnt = intCnt + 1
            rollspeed = speedIntCnt / 10
            local _y = retval.y - rollspeed
            _rollAngle = _rollAngle - rollspeed
            SetEntityRotation(_wheel, 0.0, _y, -30.9754, 2, true)
            Wait(0)
        end
    end)
end)

RegisterNetEvent("qb-casinowheel:rollFinished", function() 
    _isRolling = false
end)

function doRoll()
    if not _isRolling then
        _isRolling = true
        local playerPed = PlayerPedId()
        local _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@female'
        if IsPedMale(playerPed) then
            _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@male'
        end
        local lib, anim = _lib, 'enter_right_to_baseidle'
        while (not HasAnimDictLoaded(lib)) do
            RequestAnimDict(lib)
            Wait(100)
        end
        local _movePos = vector3(948.32, 45.14, 71.64)
        TaskGoStraightToCoord(playerPed,  _movePos.x,  _movePos.y,  _movePos.z,  1.0,  -1,  312.2,  0.0)
        local _isMoved = false
        while not _isMoved do
            local coords = GetEntityCoords(PlayerPedId())
            if coords.x >= (_movePos.x - 0.01) and coords.x <= (_movePos.x + 0.01) and coords.y >= (_movePos.y - 0.01) and coords.y <= (_movePos.y + 0.01) then
                _isMoved = true
            end
            Wait(0)
        end
        TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
        while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                Wait(0)
                DisableAllControlActions(0)
        end
        TaskPlayAnim(playerPed, lib, 'enter_to_armraisedidle', 8.0, -8.0, -1, 0, 0, false, false, false)
        while IsEntityPlayingAnim(playerPed, lib, 'enter_to_armraisedidle', 3) do
            Wait(0)
            DisableAllControlActions(0)
        end
        TriggerServerEvent("qb-casinowheel:getLucky")
        TaskPlayAnim(playerPed, lib, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)

    end
end

-- Menu Controls
CreateThread(function()
	while true do
        Wait(1)
        local coords = GetEntityCoords(PlayerPedId())
        if #(coords - vector3(_wheelPos.x, _wheelPos.y, _wheelPos.z)) < 1.5 and not _isRolling then
            QBCore.Functions.DrawText3D( _wheelPos.x, _wheelPos.y, _wheelPos.z, 'Press ~g~[E] To Try Your Luck On The Wheel')
            if IsControlJustReleased(0, 38) then
                doRoll()
            end
        end		
	end
end)
