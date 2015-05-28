------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Battleguard Sartura"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Sartura",
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alerts",
	enrage_desc = "Warn for Enrage",

	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind Alert",
	whirlwind_desc = "Warn for Whirlwind",

	starttrigger = "defiling these sacred grounds",
	startwarn = "Sartura engaged - 10 minutes until Enrage",
	enragetrigger = "becomes enraged",
	enragewarn = "Enrage - Enrage - Enrage",
	bartext = "Enrage",
	warn1 = "Enrage in 8 minutes",
	warn2 = "Enrage in 5 minutes",
	warn3 = "Enrage in 3 minutes",
	warn4 = "Enrage in 90 seconds",
	warn5 = "Enrage in 60 seconds",
	warn6 = "Enrage in 30 seconds",
	warn7 = "Enrage in 10 seconds",
	whirlwindon = "Battleguard Sartura gains Whirlwind.",
	whirlwindoff = "Whirlwind fades from Battleguard Sartura.",
	whirlwindonwarn = "Whirlwind - Battleguard Sartura - Whirlwind",
	whirlwindoffwarn = "Whirlwind faded!",
	whirlwindbartext = "Whirlwind",
	whirlwindnextbartext = "Next Whirlwind",
	whirlwindinctext = "Whirlwind inc",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSartura = BigWigs:NewModule(boss)
BigWigsSartura.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsSartura.enabletrigger = boss
BigWigsSartura.toggleoptions = {"enrage", "whirlwind", "bosskill"}
BigWigsSartura.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsSartura:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "SarturaWhirlwind", 3)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsSartura:BigWigs_RecvSync(sync)
	if sync == "SarturaWhirlwind" and self.db.profile.whirlwind then
		self:TriggerEvent("BigWigs_Message", L["whirlwindonwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["whirlwindbartext"], 15, "Interface\\Icons\\Ability_Whirlwind")
		self:ScheduleEvent("BigWigs_Message", 25, L["whirlwindinctext"], "Attention", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["whirlwindnextbartext"], 28, "Interface\\Icons\\Ability_UpgradeMoonGlaive")
	end
end

function BigWigsSartura:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if msg == L["whirlwindon"] then
		self:TriggerEvent("BigWigs_SendSync", "SarturaWhirlwind")
	end
end

function BigWigsSartura:CHAT_MSG_MONSTER_YELL(msg)
	if self.db.profile.enrage and string.find(msg, L["starttrigger"]) then
		self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 600, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		self:ScheduleEvent("BigWigs_Message", 120, L["warn1"], "Attention")
		self:ScheduleEvent("BigWigs_Message", 300, L["warn2"], "Attention")
		self:ScheduleEvent("BigWigs_Message", 420, L["warn3"], "Attention")
		self:ScheduleEvent("BigWigs_Message", 510, L["warn4"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 540, L["warn5"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 570, L["warn6"], "Important")
		self:ScheduleEvent("BigWigs_Message", 590, L["warn7"], "Important")
	end
end

function BigWigsSartura:CHAT_MSG_MONSTER_EMOTE(msg)
	if self.db.profile.enrage and string.find(msg, L["enragetrigger"]) then
		self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Attention")
	end
end

function BigWigsSartura:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["whirlwindoff"]) and self.db.profile.whirlwind then
	        self:TriggerEvent("BigWigs_StopBar", self, L["whirlwindbartext"])
		self:TriggerEvent("BigWigs_Message", L["whirlwindoffwarn"], "Attention")
	end
end
