local lassoHash = `WEAPON_LASSO`
local lassoReinforcedHash = `WEAPON_LASSO_REINFORCED`
local lassoModel = `p_cs_melee_lasso01`
local attachedLasso = nil
local isResourceStopping = false

local offset = {
    x = 0.0, 
    y = 0.0,
    z = -0.11,
    pitch = -83.0,
    roll = 0.0,
    yaw = 80.0,
}

local function IsPedMale(ped)
    return Citizen.InvokeNative(0x95B8E397B8F4360F, ped)
end

local function GetCorrectBone(ped)
    if IsPedMale(ped) then
        return "SKEL_L_Thigh" 
    else
        return "skel_l_thigh" 
    end
end

local function GetBoneIndex(ped)
    return GetEntityBoneIndexByName(ped, GetCorrectBone(ped))
end

local function RemoveLassoFromBelt()
    if attachedLasso then
        DeleteObject(attachedLasso)
        attachedLasso = nil
    end
end

local function AttachLassoToBelt()
    if attachedLasso or isResourceStopping then 
        RemoveLassoFromBelt()
    end
    
    local playerPed = PlayerPedId()
    if not HasModelLoaded(lassoModel) then
        RequestModel(lassoModel)
        while not HasModelLoaded(lassoModel) and not isResourceStopping do
            Wait(10)
        end
    end
    
    if not isResourceStopping then
        attachedLasso = CreateObject(lassoModel, 0.0, 0.0, 0.0, true, true, true)
        AttachEntityToEntity(
            attachedLasso, 
            playerPed, 
            GetBoneIndex(playerPed),
            offset.x, offset.y, offset.z,
            offset.pitch, offset.roll, offset.yaw,
            true, true, false, true, 1, true
        )
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    isResourceStopping = true
    RemoveLassoFromBelt()
end)

CreateThread(function()
    while not isResourceStopping do
        local playerPed = PlayerPedId()
        local _, currentWeapon = GetCurrentPedWeapon(playerPed, true)
        
        if currentWeapon == lassoHash or currentWeapon == lassoReinforcedHash then
            RemoveLassoFromBelt()
        elseif HasPedGotWeapon(playerPed, lassoHash, false) or HasPedGotWeapon(playerPed, lassoReinforcedHash, false) then
            AttachLassoToBelt()
        else
            RemoveLassoFromBelt()
        end
        
        Wait(100)
    end
end)