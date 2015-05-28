------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Vaelastrasz the Corrupt"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local playerName = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Vaelastrasz",

	trigger1 = "^([^%s]+) gains Burning",
	trigger2 = "^You gain Burning",

	warn1 = "You are burning!",
	warn2 = "%s is burning!",

	youburning_cmd = "youburning",
	youburning_name = "You are burning alert",
	youburning_desc = "Warn when you are burning",

	elseburning_cmd = "elseburning",
	elseburning_name = "Someone else is burning alert",
	elseburning_desc = "Warn when others are burning",

	burningbar_cmd = "burningbar",
	burningbar_name = "Burning Adrenaline bar",
	burningbar_desc = "Shows a timer bar for Burning Adrenaline",

} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsVaelastrasz = BigWigs:NewModule(boss)
BigWigsVaelastrasz.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsVaelastrasz.enabletrigger = boss
BigWigsVaelastrasz.toggleoptions = {"youburning", "elseburning", "burningbar", "bosskill"}
BigWigsVaelastrasz.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsVaelastrasz:OnEnable()
	playerName = UnitName("player")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsVaelastrasz:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS(msg)
	if string.find(msg, L["trigger2"]) and self.db.profile.youburning then
			self:TriggerEvent("BigWigs_SetRaidIcon", playerName)
		        self:TriggerEvent("BigWigs_Message", L["warn1"], "Personal", true, "Alarm")
		        self:TriggerEvent("BigWigs_Message", playerName .. L["warn2"], "Attention", nil, nil, true)
	if self.db.profile.burningbar then
		self:TriggerEvent("BigWigs_StartBar", self, L["warn1"], 20, "Interface\\Icons\\INV_Gauntlets_03")
		end
	end
end

function BigWigsVaelastrasz:CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS(msg)
	local _,_, n = string.find(msg, L["trigger1"])
	if n then
		if self.db.profile.elseburning then
			self:TriggerEvent("BigWigs_SetRaidIcon", n)
			self:TriggerEvent("BigWigs_Message", string.format(L["warn2"], n), "Attention")
			self:TriggerEvent("BigWigs_SendTell", n, L["warn1"])
	if self.db.profile.burningbar then
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["warn2"], n), 20, "Interface\\Icons\\INV_Gauntlets_03")
		end
		end
	end
end

function BigWigsVaelastrasz:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS(msg)
	local _,_, n = string.find(msg, L["trigger1"])
	if n then
		if self.db.profile.elseburning then
			self:TriggerEvent("BigWigs_SetRaidIcon", n)
			self:TriggerEvent("BigWigs_Message", string.format(L["warn2"], n), "Attention")
			self:TriggerEvent("BigWigs_SendTell", n, L["warn1"])
	if self.db.profile.burningbar then
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["warn2"], n), 20, "Interface\\Icons\\INV_Gauntlets_03")
		end
		end
	end
end



