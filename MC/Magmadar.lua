------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Magmadar"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	-- Chat message triggers
	trigger1 = "gains Frenzy",
	trigger2 = "by Panic.",
	frenzyfade_trigger = "Frenzy fades from Magmadar",

	frenzy_bar = "Frenzy",

	-- Warnings and bar texts
	["Frenzy alert!"] = true,
	["5 seconds until AoE Fear!"] = true,
	["AoE Fear - 30 seconds until next!"] = true,
	["AoE Fear"] = true,

	-- AceConsole strings
	cmd = "Magmadar",
	
	fear_cmd = "fear",
	fear_name = "Warn for Fear",
	fear_desc = "Warn when Magmadar casts AoE Fear",
	
	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when Magmadar goes into a frenzy",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMagmadar = BigWigs:NewModule(boss)
BigWigsMagmadar.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsMagmadar.enabletrigger = boss
BigWigsMagmadar.toggleoptions = {"fear", "frenzy", "bosskill"}
BigWigsMagmadar.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMagmadar:OnEnable()
	self.prior = nil
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "MagmadarFear", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsMagmadar:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(arg1, L["trigger1"]) and self.db.profile.frenzy then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["Frenzy alert!"], "Important", nil, true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 8, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsMagmadar:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsMagmadar:BigWigs_RecvSync( sync ) 
	if sync ~= "MagmadarFear" then return end
	if self.db.profile.fear then
		self:TriggerEvent("BigWigs_StartBar", self, L["AoE Fear"], 31, "Interface\\Icons\\Spell_Shadow_PsychicScream")
		self:TriggerEvent("BigWigs_Message", L["AoE Fear - 30 seconds until next!"], "Important")
		self:ScheduleEvent("BigWigs_Message", 25, L["5 seconds until AoE Fear!"], "Urgent", true, "Alert")
	end
end

function BigWigsMagmadar:Fear(msg)
	if not self.prior and string.find(msg, L["trigger2"]) then
		self:TriggerEvent("BigWigs_SendSync", "MagmadarFear")
		self.prior = true
	end
end

function BigWigsMagmadar:BigWigs_Message(text)
	if text == L["5 seconds until AoE Fear!"] then self.prior = nil end
end

function BigWigsMagmadar:Tranq()
            if (UnitClass("player") == "Hunter") then
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsMagmadar:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end

