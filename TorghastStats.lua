--[[

TorghastStats Addon.
@author Ben Antonellis
@ign Jimlee-Borean Tundra
@version 1.0
@date November 26th, 2020
@license MIT -  See CurseForge / Github

]]--

local addonName = "TorghastStats"
local PHANTASMA_ID_NUMBER = 1728
local debug = false
local initiated = false
local mawratCombat = false

function eventTrigger(self, event, ...)

	local mapID = C_Map.GetBestMapForUnit("player")
	local zone = C_Map.GetMapInfo(mapID).name

	-- Check for inital login or UI reload
	if event == "PLAYER_ENTERING_WORLD" then
		initialLogin, reloadedUI = ...
		if initialLogin then
			login()
		end
	end

	-- Check for new anima orb
	if (event == "PLAYER_CHOICE_UPDATE") and (zone == "Torghast") then
		newAnimaOrb()
	end

	-- Check for new mawrat
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subevent, _, _, _, _, _, _, destName, _, _ = CombatLogGetCurrentEventInfo()
		if (subevent == "UNIT_DIED") and (destName == "Mawrat") then
			newMawrat()
		end
	end

	-- Check for new jar broken
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subevent, _, _, _, _, _, _, destName, _, _ = CombatLogGetCurrentEventInfo()
		if (subevent == "SPELL_AURA_REMOVED") and (destName == "Ashen Phylactery") then
			newJarBroken()
		end
	end

	-- Check for new floor completed


	-- Check for new death
	if (event == "PLAYER_DEAD") and (zone == "Torghast") then
		newDeath()
	end

	-- Check for addon load
	if event == "ADDON_LOADED" then
		if (zone == "Torghast") and (not initiated) then
			print("|cFFC7BF50<|cFF50C79F" .. addonName .. " Loaded!|cFFC7BF50>|r")
			initiated = true
		else
			logout()
		end
		PhantasmaData = _G['PhantasmaData']
	end

	-- Check for player logout to save variables
	if event == "PLAYER_LOGOUT" then
		logout()
	end

	-- Check for new phantasma updates, looted or spent
	if event == "CURRENCY_DISPLAY_UPDATE" then
		currencyType, quantity, quantityChange, quantityGainSource, quantityLostSource = ...
		newPhantasma(currencyType, quantity, quantityChange, quantityGainSource, quantityLostSource)
	end

end

function login()

	if not PhantasmaData then

		PhantasmaData = {
			Phantasma = 0,
			TotalPhantasma = 0,
			Mawrats = 0,
			AnimaOrbs = 0,
			JarsBroken = 0,
			FloorsCompleted = 0,
			Deaths = 0
		}

	end

end

function logout()

	PhantasmaData.TotalPhantasma = PhantasmaData.TotalPhantasma + PhantasmaData.Phantasma
	PhantasmaData.Phantasma = 0

	_G['PhantasmaData'] = PhantasmaData

end

function newPhantasma(currencyType, quantity, quantityChange, quantityGainSource, quantityLostSource)

	if debug then

		print("Currency Type: " .. currencyType)
		print("Quantity: " .. quantity)
		print("Quantity Change: " .. quantityChange)
		print("Quantity Gain Source: " .. quantityGainSource)
		print("Quantity Lost Source: " .. quantityLostSource)

		print("|cFFC7BF50Current Phantasma: " .. Phantasma .. "!|r")

	end

	if currencyType == PHANTASMA_ID_NUMBER then

		if quantity < PhantasmaData.Phantasma then
			PhantasmaData.Phantasma = quantity
		else
			PhantasmaData.Phantasma = PhantasmaData.Phantasma + quantityChange
		end

	end

	_G['PhantasmaData'] = PhantasmaData

end

function newAnimaOrb()

	PhantasmaData.AnimaOrbs = PhantasmaData.AnimaOrbs + 1
	--PhantasmaData.AnimaOrbs = math.ceil(PhantasmaData.AnimaOrbs / 2) -- Solves the problem of duplicate anima orb entries

	_G['PhantasmaData'] = PhantasmaData

end

function newMawrat()

	PhantasmaData.Mawrats = PhantasmaData.Mawrats + 1

	_G['PhantasmaData'] = PhantasmaData

end

function newJarBroken() -- Parameters may be added

	-- Might add some code to deal with parameters

	PhantasmaData.JarsBroken = PhantasmaData.JarsBroken + 1

	_G['PhantasmaData'] = PhantasmaData

end

function newFloorCompleted() -- Parameters may be added

	-- Might add some code to deal with parameters

	PhantasmaData.FloorsCompleted = PhantasmaData.FloorsCompleted + 1

	_G['PhantasmaData'] = PhantasmaData

end

function newDeath()

	PhantasmaData.Deaths = PhantasmaData.Deaths + 1

	_G['PhantasmaData'] = PhantasmaData

end

local function torghastCommands(msg, editbox)

	if msg == "stats" then
		PhantasmaStats = _G['PhantasmaData']
		print("|cFFC7BF50Total Phantasma Earned: " .. PhantasmaStats.TotalPhantasma)
		print("|cFFC7BF50Mawrats Killed: " .. PhantasmaStats.Mawrats)
		--print("|cFFC7BF50Anima Orbs Collected: " .. PhantasmaStats.AnimaOrbs)
		--print("|cFFC7BF50Jars Broken: " .. PhantasmaStats.JarsBroken)
		print("|cFFC7BF50Floors Completed: " .. PhantasmaStats.FloorsCompleted)
		print("|cFFC7BF50Deaths: " .. PhantasmaStats.Deaths)
		print("|cFFFF0000If the stats are not accurate for any reason, /reload.")
	end

	if msg == "reset" then
		_G['PhantasmaData'] = {
			Phantasma = 0,
			TotalPhantasma = 0,
			Mawrats = 0,
			AnimaOrbs = 0,
			JarsBroken = 0,
			FloorsCompleted = 0,
			Deaths = 0
		}
		print("|cFFFF0000Data Reset!")
	end

end

SLASH_TORGHASTSTATS1 = '/tgs'
SlashCmdList['TORGHASTSTATS'] = torghastCommands

local f = CreateFrame('Frame')
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE") -- Determining phantasma gain/loss
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_CHOICE_UPDATE") -- Determining anima orb
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("PLAYER_REGEN_ENABLED") -- Determining combat
f:RegisterEvent("UNIT_COMBAT")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", eventTrigger)