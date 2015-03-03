if select(3, UnitClass("player")) == 5 then
	function PriestShadow()

		if currentConfig ~= "Shadow ragnar" then
			ShadowConfig()
			ShadowToggles()
			currentConfig = "Shadow ragnar"
		end
		-- Head End


		-- Locals / Globals--
		--GCD = 1.5/(1+UnitSpellHaste("player")/100)
		--hasTarget = UnitExists("target")
		--hasMouse = UnitExists("mouseover")
		--php = getHP("player")
		-- thp = getHP("target")


		--MBCD = getSpellCD(MB)
		--SWDCD = getSpellCD(SWD)

		if lastDP==nil then	lastDP=99 end
		if lastVT==nil then lastVT=99 end

		--DPTICK = DPTIME/6
		-- SWP (18sec)
		--SWPTICK = 18.0/(1+UnitSpellHaste("player")/100)/6
		-- VT (15sec)
		--VTTICK = 16.0/(1+UnitSpellHaste("player")/100)/5
		--VTCASTTIME = 1.5/(1+UnitSpellHaste("player")/100)



		-- Set Enemies Table
		--makeEnemiesTable(40)

		-- Sort enemiesTable by absolute HP
		if isChecked("sortByHPabs") then
			if enemiesTable then
				if enemiesTableTimer <= GetTime() - 0.5 then
					table.sort(enemiesTable, function(x,y)
						return x.hpabs and y.hpabs and x.hpabs > y.hpabs or false
					end)
				end
			end
		end



		local options = {
			-- Player values
			player = {
				GCD = 		1.5/(1+UnitSpellHaste("player")/100),
				php =		getHP("player"),
				ORBS = 		UnitPower("player", SPELL_POWER_SHADOW_ORBS),
				DPTIME = 	6.0/(1+UnitSpellHaste("player")/100),
				lastVT,
				lastDP,
				MBCD = 		getSpellCD(MB),
				SWDCD = 	getSpellCD(SWD),
				Bubble = 	isChecked("Bubble"),
				},
			-- Buttons
			buttons = {
				Defensive =	BadBoy_data['Defensive'],
				Halo =		BadBoy_data['Halo'],
				DoT =		BadBoy_data['DoT'],
				--Single =	BadBoy_data['Single'],
				Rotation =	BadBoy_data['Rotation'],
				--Rotation =	1,
				Cooldowns =	BadBoy_data['Cooldowns'],
				Feather =	BadBoy_data['Feather'],
			},
			-- isChecked
			isChecked = {
				-- Offensive
				isBoss = 			isChecked("isBoss"),
				Berserking = 		isChecked("Berserking"),
				Mindbender = 		isChecked("Mindbender"),
				Shadowfiend	= 		isChecked("Shadowfiend"),
				Trinket1 = 			isChecked("Trinket 1"),
				Trinket2 =	 		isChecked("Trinket 2"),
				SWDglyphed =		isChecked("SWD glyphed"),
				ScanOrbs = 			isChecked("Scan for Orbs"),
				ScanToF =			isChecked("Scan for ToF"),
				ThrowDP =			isChecked("ThrowDP"),
				-- Defensive
				Shield = 			isChecked("PW: Shield"),
				Healthstone	= 		isChecked("Healthstone"),
				DesperatePrayer = 	isChecked("Desperate Prayer"),
				FadeGlyph =			isChecked("Fade Glyph"),
				Dispersion =		isChecked("Dispersion"),
				Fade =				isChecked("Fade Aggro"),
				-- DoT Weave
				DoTWeave =			isChecked("DoTWeave"),
				SWP =				isChecked("SWP"),
				VT =				isChecked("VT"),
				-- Multitarget
				VTonTarget =		isChecked("VT on Target"),
				-- MultiSWP =			isChecked("Multi SWP"),
				-- MultiVT =			isChecked("Multi VT"),
				-- BossSWP =			isChecked("Boss SWP"),
				-- BossVT =			isChecked("Boss VT"),
				MindSear =			isChecked("MS Targets"),
				-- Encounter Specific
				TwinStyle = 		isChecked("Ogron Focus Style"),  -- DP on Focus, DPonFocus
				-- Utilities
				PWF = 				isChecked("PW: Fortitude"),
				Shadowform =		isChecked("Shadowform Outfight"),
				Feather =			isChecked("Angelic Feather"),
				BodyAndSoul = 		isChecked("Body And Soul"),
				},
			-- Values
			values = {
				PWShield = 			getValue("PW: Shield"),
				Healthstone =		getValue("Healthstone"),
				Dispersion	=		getValue("Dispersion"),
				Glyph = 			getValue("Fade Glyph"),
				MinHealth =			getValue("Min Health")*1000000,
				MaxTargets = 		getValue("Max Targets"),
				RefreshTime = 		getValue("Refresh Time"),
				VTRefresh =			4.5+1.5/(1+UnitSpellHaste("player")/100),
				SWPRefresh = 		5.4,
				MindSear = 			getValue("MS Targets"),
			},
			ASInsanity = {
				VTAll =				false,
			},
		}

		-- correct twin ogrons options for SoD talent automatically
		--if getTalent(3,1) then options.isChecked.TwinOgrons=true end

		-- set if not set
		if options.player.lastVT==nil then options.player.lastVT=0 end
		if options.player.lastDP==nil then options.player.lastDP=99 end

		-------------
		-- TOGGLES --
		-------------

		-- Pause toggle
		if isChecked("Pause Toggle") and SpecificToggle("Pause Toggle") == true then
			ChatOverlay("|cffFF0000BadBoy Paused", 0); return;
		end

		-- -- Focus Toggle
		-- if isChecked("Focus Toggle") and SpecificToggle("Focus Toggle") == 1 then
		-- 	RunMacroText("/focus mouseover");
		-- end

		-- -- Auto Resurrection
		-- if isChecked("Auto Rez") then
		-- 	if not isInCombat("player") and UnitIsDeadOrGhost("mouseover") and UnitIsFriend("player","mouseover") then
		-- 		if castSpell("mouseover",Rez,true,true) then return; end
		-- 	end
		-- end

		------------
		-- CHECKS --
		------------

			-- Ko'ragh Mind Controll Check
			if UnitDebuffID("player",163472) then
				return false
			end

			-- Food/Invis Check
			if canRun() ~= true then return false; end

			-- Mounted Check (except nagrand outpost mounts)
			if IsMounted("player") and not (UnitBuffID("player",164222) or UnitBuffID("player",165803)) then return false; end

		-------------------
		-- OUT OF COMBAT --
		-------------------

			-- Power Word: Fortitude
			if not isInCombat("player") then
				if options.isChecked.PWF then Raidbuff_Priest() end
			end

			-- if not isInCombat("player") then
			-- 	if options.isChecked.PWF and (lastPWF == nil or lastPWF <= GetTime() - 5) then
			-- 		for i = 1, #nNova do
			-- 			if isPlayer(nNova[i].unit) == true 
			-- 				and not isBuffed(nNova[i].unit,{21562,109773,469,90364}) 
			-- 				and (UnitInRange(nNova[i].unit) 
			-- 					or UnitIsUnit(nNova[i].unit,"player")) then
			-- 				if castSpell("player",PWF,true) then lastPWF = GetTime(); return; end
			-- 			end
			-- 		end
			-- 	end
			-- end

		---------------------------------------
		-- Shadowform and AutoSpeed Selfbuff --
		---------------------------------------

			-- Shadowform outfight
			if not UnitBuffID("player",Shadowform) and options.isChecked.Shadowform then
				if castSpell("player",Shadowform,true,false) then return; end
			end

			-- Angelic Feather
			if isKnown(AngelicFeather) and options.buttons.Feather==2 then
				if getGround("player") and IsMovingTime(0.2) and not UnitBuffID("player",AngelicFeatherBuff) then
					--if options.isChecked.Feather and getGround("player") and IsMovingTime(0.2) and not UnitBuffID("player",AngelicFeatherBuff) then
					--if useFeather==true and IsMovingTime(0.2) and not UnitBuffID("player",AngelicFeatherBuff) then
					if castGround("player",AngelicFeather,30) then
						SpellStopTargeting();
						return;
					end
				end
			end

			-- Body and Soul
			if isKnown(BodyAndSoul) then
				if options.isChecked.BodyAndSoul then
					if getGround("player") and IsMovingTime(0.75) and not UnitBuffID("player",PWS) and not UnitDebuffID("player",PWSDebuff) then
						if castSpell("player",PWS,true,false) then return; end
					end
				end
			end

		---------------
		-- IN COMBAT --
		---------------
		-- AffectingCombat, Pause, Target, Dead/Ghost Check
		if UnitAffectingCombat("player") or UnitAffectingCombat("target") then

			-- Shadowform
			if not UnitBuffID("player",Shadowform) then
				if castSpell("player",Shadowform,true,false) then return; end
			end

			-- Bubble infight
			if options.player.Bubble then
				if PlayerHasToy(114227)==1 then
					if getBuffRemain("player",168657)<=0 then
						UseToyByName(tostring(select(1,GetItemInfo(114227))))
					end
				end
			end

			-------------------
			-- Dummy Testing --
			-------------------
			if isChecked("DPS Testing") then
				if UnitExists("target") then
					if getCombatTime() >= (tonumber(getValue("DPS Testing"))*60) and isDummy() then
						StopAttack()
						ClearTarget()
						print("____ " .. tonumber(getValue("DPS Testing")) .." Minute Dummy Test Concluded - Profile Stopped ____")
					end
				end
			end


			--[[-----------------------------------------------------------------------------------------------------------------------------------------------]]
			----------------
			-- Defensives --
			----------------
			ShadowDefensive(options)


			----------------
			-- Offensives --
			----------------
			if options.isChecked.isBoss and isBoss() then ShadowCooldowns(options) end
			if not options.isChecked.isBoss then ShadowCooldowns(options) end

			-------------------
			-- Single target --
			-------------------
			-- if isCastingSpell(129197) and getSpellCD(MB)==0 then
			-- 	if castSpell("target",MB,false,false) then return; end
			-- end



			if UnitCastingInfo("player") ~= nil
				--or UnitChannelInfo("player") ~= nil
				or (GetSpellCooldown(61304) ~= nil and GetSpellCooldown(61304) > 0.001) then
				return false
			end

			-- if castingUnit() then return false; end

			-- Do not Interrupt "player" while GCD (61304)
			if getSpellCD(61304) > 0 then return false;	end

			-- Execute
			-- CoP
			if getTalent(7,1) then ExecuteCoP(options) end
			if getTalent(7,3) then ExecuteAS(options) end




			--Execute(options)
			LFOrbs(options)
			LFToF(options)

			-- if getHP("target")>20 then
			-- 	if options.buttons.DoT>=2 then DotEmAll(options) end
			-- 	if options.buttons.Rotation==1 and getTalent(7,1) then IcySingleWeave(options) end
			-- 	if options.buttons.Rotation==2 then IcyMultiTarget(options) end
			-- end

			-- Cop
			if getTalent(7,1) then
				-- Insanity
				if getTalent(3,3) then CoPInsanity(options) end
				-- SoD
				if getTalent(3,1) then CoPSoD(options) end
			end

			-- AS
			if getTalent(7,3) then
				-- Insanity
				if getTalent(3,3) then ASInsanity(options) end
				-- SoD
				if getTalent(3,1) then ASSoD(options) end
			end

			--[[-----------------------------------------------------------------------------------------------------------------------------------------------]]

		end -- AffectingCombat, Pause, Target, Dead/Ghost Check
	end
end