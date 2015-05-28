
------------------------------
--      Event Handlers      --
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Razorgore the Untamed"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Razorgore",

	start_message = "Razorgore engaged! Enrage in 15min!",
        enragebartext = "Enrage",

        spawnbartext = "Wyrmkin Spawn",
        spawninc = "Wyrmkin spawn soon!",

        razcast_trigger = "ed begins to cast Fireball Volley",
        wyrmcast_trigger = "in begins to cast Fireball Volley",

        razcast_allert = "Razorgore's Fireball Volley inc!",
        wyrmcast_allert = "Fireball Volley inc!",
        razvolley_cast = "Raz's Fireball Volley",
        razvolley_castnext = "Fireball Volley",
        wyrmvolley_cast = "Fireball Volley cast",
	GFPPtrigger	= "Fire Protection",

	warn1 = "Enrage in 5 minutes",
	warn2 = "Enrage in 3 minutes",
	warn3 = "Enrage in 90 seconds",
	warn4 = "Enrage in 60 seconds",
	warn5 = "Enrage in 30 seconds",
	warn6 = "Enrage in 10 seconds",

	enrage_cmd = "enrage",
	enrage_name = "Enrage timer",
	enrage_desc = "Warn for Razorgore's enrage",

	egg_trigger = "Dragon Egg",
	egg_message = "%d/5 eggs destroyed!",

	eggs_cmd = "eggs",
	eggs_name = "Сount eggs",
	eggs_desc = "Сount down the remaining eggs.",

	casts_cmd = "casts",
	casts_name = "Casts",
	casts_desc = "Alert on Raz/Wyrmkins casts",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRazorgore = BigWigs:NewModule(boss)
BigWigsRazorgore.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsRazorgore.enabletrigger = boss
BigWigsRazorgore.wipemobs = { L["egg_trigger"] }
BigWigsRazorgore.toggleoptions = { "enrage", "casts", "eggs", "bosskill" }
BigWigsRazorgore.revision = tonumber(string.sub("$Revision: 17555 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsRazorgore:OnEnable()
	started = nil
	self.eggdead = 0

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "RazorEggDead", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "RazorAoE", 7)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsRazorgore:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, L["egg_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "RazorEggDead "..tostring(self.eggdead + 1) )
	else
		self:GenericBossDeath(msg)
	end
end

function BigWigsRazorgore:PLAYER_REGEN_DISABLED()
	if UnitAffectingCombat("player") and UnitName("target") == "Razorgore the Untamed" then
		self:Emerge()
end
	end

function BigWigsRazorgore:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if string.find(msg, L["GFPPtrigger"]) then
            BigWigsThaddiusArrows:GFPPstop()
	end
end

function BigWigsRazorgore:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if string.find(msg, L["GFPPtrigger"]) then
	        BigWigsThaddiusArrows:Direction("GFPP")
	end
end

function BigWigsRazorgore:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		self:Emerge()
	elseif sync == "RazorAoE" then
		self:RazAoE()
	elseif sync == "RazorEggDead" and rest then
		rest = tonumber(rest)
		if not rest then return end
		if rest == (self.eggdead + 1) then
			self.eggdead = self.eggdead + 1
			if self.db.profile.eggs then
				self:TriggerEvent("BigWigs_Message", string.format(L["egg_message"], self.eggdead), "Urgent")
			end
			if self.eggdead == 5 then
				self.eggdead = 0 -- reset counter
			end
		end
	end
end

function BigWigsRazorgore:EmergeCheck()
	if UnitExists("target") and UnitName("target") == "Razorgore the Untamed" and UnitExists("targettarget") then
		self:Emerge()
		return
	end
	local num = GetNumRaidMembers()
	for i = 1, num do
		local raidUnit = string.format("raid%starget", i)
		if UnitExists(raidUnit) and UnitName(raidUnit) == "Razorgore the Untamed" and UnitExists(raidUnit.."target") then
			self:Emerge()
			return
		end
	end
end

function BigWigsRazorgore:Emerge()
	if self.db.profile.enrage then
	                self:ScheduleEvent("bwrazorgorespawn", self.Spawn, 36.5, self)
		        self:TriggerEvent("BigWigs_StartBar", self, L["enragebartext"], 900, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		        self:TriggerEvent("BigWigs_StartBar", self, L["spawnbartext"], 36.5, "Interface\\Icons\\Spell_Nature_MassTeleport")
		        self:ScheduleEvent("BigWigs_Message", 28, L["spawninc"], "Urgent")
			self:TriggerEvent("BigWigs_Message", L["start_message"], "Urgent")
			self:ScheduleEvent("BigWigs_StartBar", 35, self, L["spawnbartext"], 45.5, "Interface\\Icons\\Spell_Nature_MassTeleport")
                        self:ScheduleEvent("BigWigs_Message", 600, L["warn1"], "Attention")
		        self:ScheduleEvent("BigWigs_Message", 720, L["warn2"], "Attention")
		        self:ScheduleEvent("BigWigs_Message", 810, L["warn3"], "Urgent")
		        self:ScheduleEvent("BigWigs_Message", 840, L["warn4"], "Urgent")
		        self:ScheduleEvent("BigWigs_Message", 870, L["warn5"], "Important")
		        self:ScheduleEvent("BigWigs_Message", 890, L["warn6"], "Important")
	end
end

function BigWigsRazorgore:Spawn()
	       self:ScheduleRepeatingEvent("bwrazorgorespawnbar", self.Spawnbar, 45.5, self)
end

function BigWigsRazorgore:Spawnbar()
		        self:TriggerEvent("BigWigs_StartBar", self, L["spawnbartext"], 45.5, "Interface\\Icons\\Spell_Nature_MassTeleport")
		        self:ScheduleEvent("BigWigs_Message", 38, L["spawninc"], "Urgent")
end

function BigWigsRazorgore:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["razcast_trigger"]) then
        self:TriggerEvent("BigWigs_SendSync", "RazorAoE")
	elseif string.find(msg, L["wyrmcast_trigger"]) and self.db.profile.casts then
			self:TriggerEvent("BigWigs_Message", L["wyrmcast_allert"], "Important", true, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, L["wyrmvolley_cast"], 2, "Interface\\Icons\\Spell_Fire_FlameBolt")
	end
end

function BigWigsRazorgore:RazAoE()
	if self.db.profile.casts and UnitName("target") == "Razorgore the Untamed" then
                        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 12)
		        self:ScheduleEvent("BigWigs_Message", 14, L["razcast_allert"], "Important", true, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["razvolley_cast"], 2, "Interface\\Icons\\Spell_Fire_FlameBolt")
			self:TriggerEvent("BigWigs_StartBar", self, L["razvolley_castnext"], 16, "Interface\\Icons\\Spell_Fire_FlameBolt")
end
end