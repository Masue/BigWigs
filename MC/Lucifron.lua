------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Lucifron"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local prior1
local prior2

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	trigger1 = "afflicted by Lucifron",
	trigger2 = "afflicted by Impending Doom",

	warn1 = "5 seconds until Lucifron's Curse!",
	warn2 = "Lucifron's Curse - 15 seconds until next!",
	warn3 = "5 seconds until Impending Doom!",
	warn4 = "Impending Doom - 20 seconds until next!",

	bar1text = "Lucifron's Curse",
	bar2text = "Impending Doom",

	cmd = "Lucifron",
	
	curse_cmd = "curse",
	curse_name = "Lucifron's Curse alert",
	curse_desc = "Warn for Lucifron's Curse",
	
	doom_cmd = "dmg",
	doom_name = "Impending Doom alert",
	doom_desc = "Warn for Impending Doom",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsLucifron = BigWigs:NewModule(boss)
BigWigsLucifron.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsLucifron.enabletrigger = boss
BigWigsLucifron.toggleoptions = {"curse", "doom", "bosskill"}
BigWigsLucifron.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsLucifron:OnEnable()
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	prior1 = nil
	prior2 = nil
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsLucifron:Event(msg)
	if (not prior1 and string.find(msg, L["trigger1"]) and self.db.profile.curse) then
		self:TriggerEvent("BigWigs_Message", L["warn2"], "Important")
		self:ScheduleEvent("BigWigs_Message", 15, L["warn1"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 20, "Interface\\Icons\\Spell_Shadow_BlackPlague")
		prior1 = true
	elseif (not prior2 and string.find(msg, L["trigger2"]) and self.db.profile.doom) then
		self:TriggerEvent("BigWigs_Message", L["warn4"], "Important")
		self:ScheduleEvent("BigWigs_Message", 15, L["warn3"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bar2text"], 20, "Interface\\Icons\\Spell_Shadow_NightOfTheDead")
		prior2 = true
	end
end

function BigWigsLucifron:BigWigs_Message(msg)
	if (msg == L["warn1"]) then prior1 = nil
	elseif (msg == L["warn3"]) then prior2 = nil end
end

