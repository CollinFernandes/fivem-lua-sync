---@class Sync
---@return table
local function Sync()
    local self = {}
    self.bones = {
        12844,
        31086,
    }

    function self.bone()
        if (Config.EnableSync) then
            AddEventHandler('gameEventTriggered', function(event, args)
                if (event == 'CEventNetworkEntityDamage') then
                    local ped = PlayerPedId()
                    if (args[1] == ped) then
                        local attacker = args[2]
                        local weaponHash = args[7]
                        local _found, bone = GetPedLastDamageBone(ped)
                        local victimCoords = GetEntityCoords(ped)
                        local attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
                        local killerClientId = GetPlayerServerId(PlayerId())

                        if (not IsPedArmed(attacker, 7) or not IsPedArmed(attacker, 4)) and not attackerId ~= 0 then
                            return;
                        end
                        if (weaponHash == GetHashKey("WEAPON_STUNGUN") or weaponHash == GetHashKey("WEAPON_UNARMED")) then
                            return
                        end
                        for k, v in next, self.bones do
                            if (bone == v) then
                                local killerCoords = GetEntityCoords(GetPlayerPed(attacker))
                                local distance = #(victimCoords - killerCoords)

                                local data = {
                                    victimCoords = { x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1) },
                                    killerCoords = { x = ESX.Math.Round(killerCoords.x, 1), y = ESX.Math.Round(killerCoords.y, 1), z = ESX.Math.Round(killerCoords.z, 1) },

                                    killedByPlayer = true,
                                    deathCause = "bullet",
                                    distance = ESX.Math.Round(distance, 1),

                                    killerServerId = attackerId,
                                    killerClientId = killerClientId,
                                }

                                TriggerServerEvent("esx:onPlayerDeath", data)
                                ApplyDamageToPed(ped, 200, true)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end

    function self.headshotDamage()
        if (Config.DisableVanillaHeadshotDamage) then
            SetPedSuffersCriticalHits(PlayerPedId(), false)
        end
    end

    function self.setup()
        self.bone()
        self.headshotDamage()
    end

    return self
end

CreateThread(function()
    local sync = Sync()
    sync.setup()
end)
