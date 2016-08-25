if select(3, UnitClass("player")) == 2 then -- Change specID to ID of spec. IE: https://github.com/MrTheSoulz/NerdPack/wiki/Class-&-Spec-IDs
    local rotationName = "Gabbz" -- Appears in the dropdown of the rotation selector in the Profile Options window

---------------
--- Toggles ---
---------------
    local function createToggles()
    -- Rotation Button
        RotationModes = {
            [1] = { mode = "Auto", value = 1 , overlay = "Automatic Rotation", tip = "Swaps between Single and Multiple based on number of targets in range.", highlight = 1, icon = bb.player.spell.divineStorm },
            [2] = { mode = "Mult", value = 2 , overlay = "Multiple Target Rotation", tip = "Multiple target rotation used.", highlight = 0, icon = bb.player.spell.divineStorm },
            [3] = { mode = "Sing", value = 3 , overlay = "Single Target Rotation", tip = "Single target rotation used.", highlight = 0, icon = bb.player.spell.crusaderStrike },
            [4] = { mode = "Off", value = 4 , overlay = "DPS Rotation Disabled", tip = "Disable DPS Rotation", highlight = 0, icon = bb.player.spell.flashOfLight }
        }
        CreateButton("Rotation",1,0)
    -- Cooldown Button
        CooldownModes = {
            [1] = { mode = "Auto", value = 1 , overlay = "Cooldowns Automated", tip = "Automatic Cooldowns - Boss Detection.", highlight = 1, icon = bb.player.spell.avengingWrath },
            [2] = { mode = "On", value = 1 , overlay = "Cooldowns Enabled", tip = "Cooldowns used regardless of target.", highlight = 0, icon = bb.player.spell.avengingWrath },
            [3] = { mode = "Off", value = 3 , overlay = "Cooldowns Disabled", tip = "No Cooldowns will be used.", highlight = 0, icon = bb.player.spell.avengingWrath }
        };
        CreateButton("Cooldown",2,0)
    -- Defensive Button
        DefensiveModes = {
            [1] = { mode = "On", value = 1 , overlay = "Defensive Enabled", tip = "Includes Defensive Cooldowns.", highlight = 1, icon = bb.player.spell.flashOfLight },
            [2] = { mode = "Off", value = 2 , overlay = "Defensive Disabled", tip = "No Defensives will be used.", highlight = 0, icon = bb.player.spell.flashOfLight }
        };
        CreateButton("Defensive",3,0)
    -- Interrupt Button
        InterruptModes = {
            [1] = { mode = "On", value = 1 , overlay = "Interrupts Enabled", tip = "Includes Basic Interrupts.", highlight = 1, icon = bb.player.spell.hammerOfJustice },
            [2] = { mode = "Off", value = 2 , overlay = "Interrupts Disabled", tip = "No Interrupts will be used.", highlight = 0, icon = bb.player.spell.hammerOfJustice }
        };
        CreateButton("Interrupt",4,0)
    end
---------------
--- OPTIONS ---
---------------
    local function createOptions()
        local optionTable

        local function rotationOptions()
            -----------------------
            --- GENERAL OPTIONS ---
            -----------------------
            section = bb.ui:createSection(bb.ui.window.profile,  "General")
            	-- Dummy DPS Test
                bb.ui:createSpinner(section, "DPS Testing",  5,  5,  60,  5,  "|cffFFFFFFSet to desired time for test in minuts. Min: 5 / Max: 60 / Interval: 5")            	
            bb.ui:checkSectionState(section)
            ------------------------
            --- COOLDOWN OPTIONS ---
            ------------------------
            section = bb.ui:createSection(bb.ui.window.profile,  "Cooldowns")
                
            bb.ui:checkSectionState(section)
            -------------------------
            --- DEFENSIVE OPTIONS ---
            -------------------------
            section = bb.ui:createSection(bb.ui.window.profile, "Defensive")
            	-- Flash of Light
	            bb.ui:createSpinner(section, "Flash of Light",  50,  0,  100,  5,  "|cffFFBB00Health Percentage to use at.")            	
            bb.ui:checkSectionState(section)
            -------------------------
            --- INTERRUPT OPTIONS ---
            -------------------------
            section = bb.ui:createSection(bb.ui.window.profile, "Interrupts")
            	-- Hammer of Justice
            	bb.ui:createCheckbox(section, "Hammer of Justice")
            	-- Interrupt Percentage
	            bb.ui:createSpinner(section,  "Interrupt At",  0,  0,  95,  5,  "|cffFFBB00Cast Percentage to use at.") 	    
            bb.ui:checkSectionState(section)
            ----------------------
            --- TOGGLE OPTIONS ---
            ----------------------
            section = bb.ui:createSection(bb.ui.window.profile,  "Toggle Keys")
            	-- Single/Multi Toggle
	            bb.ui:createDropdown(section,  "Rotation Mode", bb.dropOptions.Toggle,  4)
	            --Cooldown Key Toggle
	            bb.ui:createDropdown(section,  "Cooldown Mode", bb.dropOptions.Toggle,  3)
	            --Defensive Key Toggle
	            bb.ui:createDropdown(section,  "Defensive Mode", bb.dropOptions.Toggle,  6)
	            -- Interrupts Key Toggle
	            bb.ui:createDropdown(section,  "Interrupt Mode", bb.dropOptions.Toggle,  6)
	            -- Pause Toggle
	            bb.ui:createDropdown(section,  "Pause Mode", bb.dropOptions.Toggle,  6)              	   
            bb.ui:checkSectionState(section)
        end
        optionTable = {{
            [1] = "Rotation Options",
            [2] = rotationOptions,
        }}
        return optionTable
    end

----------------
--- ROTATION ---
----------------
    local function runRotation()
        if bb.timer:useTimer("debugRetribution", math.random(0.15,0.3)) then -- Change debugSpec tp name of Spec IE: debugFeral or debugWindwalker
            --print("Running: "..rotationName)

    ---------------
    --- Toggles ---
    ---------------
            UpdateToggle("Rotation",0.25)
            UpdateToggle("Cooldown",0.25)
            UpdateToggle("Defensive",0.25)
            UpdateToggle("Interrupt",0.25)

    --- FELL FREE TO EDIT ANYTHING BELOW THIS AREA THIS IS JUST HOW I LIKE TO SETUP MY ROTATIONS ---

	--------------
	--- Locals ---
	--------------
			local cast 		= bb.player.cast
			local enemies 	= bb.player.enemies
			local hastar 	= ObjectExists("target")
			local inCombat 	= bb.player.inCombat
			local mode 		= bb.player.mode
			local php 		= bb.player.health			

			if profileStop == nil then profileStop = false end
	--------------------
	--- Action Lists ---
	--------------------
		-- Action List - Extras
			local function actionList_Extras()
				-- Abilities not part of the standard "optimal rotation" here IE: Fire cat on Feral			
			end -- End Action List - Extras
		-- Action List - Defensives
			local function actionList_Defensive()
				if useDefensive() then
			-- Flash of Light
					if isChecked("Flash of Light") then
						if php <= getOptionValue("Flash of Light") then
							if cast.flashOfLight() then return end
						end
					end				
	            end
			end -- End Action List - Defensive
		-- Action List - Interrupts
			local function actionList_Interrupts()
				if useInterrupts() then
					for i = 1, #enemies.yards10 do
						local thisUnit = enemies.yards10[i]
						local distance = getDistance(thisUnit)
						if canInterrupt(thisUnit,getOptionValue("Interrupt At")) then
			-- Hammer of Justice
							if isChecked("Hammer of Justice") and distance < 10 then
								if cast.hammerOfJustice(thisUnit) then return end
							end
						end
					end
				end
			end -- End Action List - Interrupts
		-- Action List - Cooldowns
			local function actionList_Cooldowns()
				if useCDs() then
					-- Cooldown abilities listed here
				end -- End Cooldown Usage Check
			end -- End Action List - Cooldowns
		-- Action List - PreCombat
			local function actionList_PreCombat()
				-- PreCombat abilities listed here
			end -- End Action List - PreCombat
		-- Action List - Opener
			local function actionList_Opener()
				if (not inCombat and UnitExists("target") and UnitCanAttack("target","player") and not UnitIsDeadOrGhost("target")) or (inCombat and hasThreat("target")) then
			-- Judgment
					if cast.judgment("target") then return end
			-- Start Attack
					if getDistance("target") < 5 then StartAttack() end
	            end
			end -- End Action List - Opener
		-- Action List - Multiple
			local function actionList_Multiple()
				-- AoE Rotation listed here
			end -- End Action List - Multiple
		-- Action List - Generators
			local function actionList_Single()
				-- Single Target Rotation listed here
			end -- End Action List - Single
	---------------------
	--- Begin Profile ---
	---------------------
		--Profile Stop | Pause
			if not inCombat and not hastar and profileStop == true then
				profileStop = false
			elseif (inCombat and profileStop == true) or pause() or mode.rotation == 4 then
				return true
			else
	-----------------------
	--- Extras Rotation ---
	-----------------------
				if actionList_Extras() then return end
	--------------------------
	--- Defensive Rotation ---
	--------------------------
				if actionList_Defensive() then return end
	------------------------------
	--- Out of Combat Rotation ---
	------------------------------
				if actionList_PreCombat() then return end
	----------------------------
	--- Out of Combat Opener ---
	----------------------------
				if actionList_Opener() then return end
	--------------------------
	--- In Combat Rotation ---
	--------------------------
				if inCombat and profileStop==false then
	------------------------------
	--- In Combat - Interrupts ---
	------------------------------
					if actionList_Interrupts() then return end
	-----------------------------
	--- In Combat - Cooldowns ---
	-----------------------------
					if actionList_Cooldowns() then return end
	----------------------------------
	--- In Combat - Begin Rotation ---
	----------------------------------
			-- Judgment
					if cast.judgment() then return end
			-- Templar's Verdict
					if cast.templarsVerdict() then return end
			-- Crusader Strike
					if cast.crusaderStrike() then return end
			-- AoE
					if actionList_Multiple() then return end
			-- Single Target
					if actionList_Single() then return end
				end -- End In Combat
			end -- End Profile
	    end -- Timer
	end -- runRotation
	tinsert(cRetribution.rotations, {
        name = rotationName,
        toggles = createToggles,
        options = createOptions,
        run = runRotation,
    })
end -- End Class Check