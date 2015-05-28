------------------------------
--      Are you local??     --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Bloodlord Mandokir"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Mandokir",

	you_cmd = "you",
	you_name = "You're being watched alert",
	you_desc = "Warn when you're being watched",

	other_cmd = "other",
	other_name = "Others being watched alert",
	other_desc = "Warn when others are being watched",

	icon_cmd = "icon",
	icon_name = "Raid icon on watched",
	icon_desc = "Puts a raid icon on the watched person",

	watch_trigger = "([^%s]+)! I'm watching you!$",
	enrage_trigger = "goes into a rage after seeing his raptor fall in battle!$",

	watched_warning_self = "You are being watched!",
	watched_warning_other = "%s is being watched!",
	enraged_message = "Ohgan down! Mandokir enraged!",	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMandokir = BigWigs:NewModule(boss)
BigWigsMandokir.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsMandokir.enabletrigger = boss
BigWigsMandokir.toggleoptions = {"you", "other", "icon", "bosskill"}
BigWigsMandokir.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMandokir:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsMandokir:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["enrage_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["enraged_message"], "Urgent")
	end
end

function BigWigsMandokir:CHAT_MSG_MONSTER_YELL(msg)
	local _,_, n = string.find(msg, L["watch_trigger"])
	if n then
		if n == UnitName("player") and self.db.profile.you then
	                BigWigsThaddiusArrows:Direction("Ragna")
			self:TriggerEvent("BigWigs_Message", L["watched_warning_self"], "Personal", true, "Alarm")
			self:TriggerEvent("BigWigs_Message", string.format(L["watched_warning_other"], UnitName("player")), "Attention", nil, nil, true)
		elseif self.db.profile.other then
			self:TriggerEvent("BigWigs_Message", string.format(L["watched_warning_other"], n), "Attention")
			self:TriggerEvent("BigWigs_SendTell", n, L["watched_warning_self"])
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", n)
		end
	end
end


