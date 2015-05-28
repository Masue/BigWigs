------------------------------
--      Are you local?      --
------------------------------

local kri = AceLibrary("Babble-Boss-2.2")["Lord Kri"]
local yauj = AceLibrary("Babble-Boss-2.2")["Princess Yauj"]
local vem = AceLibrary("Babble-Boss-2.2")["Vem"]
local boss = AceLibrary("Babble-Boss-2.2")["The Bug Family"]

local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local deaths = 0
local fearstatus

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "BugFamily",
	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for Fear",

	AoE_cmd = "AoE",
	AoE_name = "Toxic Volley",
	AoE_desc = "Warn for Toxic Volley",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for Heal",

	healtrigger = "Princess Yauj begins to cast Great Heal.",
	healbar = "Great Heal",
	healwarn = "Casting heal!",

	feartrigger = "is afflicted by Panic.",
	fearbar = "AoE Fear",
	fearwarn = "AoE Fear in 5 Seconds!",

	AoEtrigger = "Lord Kri's Toxic Volley hits",
	AoEbar = "Toxic Volley",
	AoEwarn = "Toxic Volley in 3 Seconds!",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBugFamily = BigWigs:NewModule(boss)
BigWigsBugFamily.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsBugFamily.enabletrigger = {kri, yauj, vem}
BigWigsBugFamily.toggleoptions = {"fear", "AoE", "heal", "bosskill"}
BigWigsBugFamily.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsBugFamily:OnEnable()
	deaths = 0
	fearstatus = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "DeathCount")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "FearEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "FearEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "FearEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "FearEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "FearEvent")
	self:RegisterEvent("BigWigs_Message")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "KriBolt", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBugFamily:FearEvent(msg)
	if not fearstatus and string.find(msg, L["feartrigger"]) and self.db.profile.fear then
		fearstatus = true
		self:TriggerEvent("BigWigs_StartBar", self, L["fearbar"], 20, "Interface\\Icons\\Spell_Shadow_Possession")
		self:ScheduleEvent("BigWigs_Message", 15, L["fearwarn"], "Urgent", true, "Alarm")
	elseif string.find(msg, L["AoEtrigger"]) and self.db.profile.AoE then
		self:TriggerEvent("BigWigs_SendSync", "KriBolt")
	end
end

function BigWigsBugFamily:BigWigs_RecvSync(sync, rest, nick)
	if sync == "KriBolt" then
		self:TriggerEvent("BigWigs_StartBar", self, L["AoEbar"], 10, "Interface\\Icons\\Spell_Nature_Corrosivebreath")
		self:ScheduleEvent("BigWigs_Message", 7, L["AoEwarn"], "Urgent")
	end
end

function BigWigsBugFamily:BigWigs_Message(txt)
	if fearstatus and txt == L["fearwarn"] then fearstatus = nil end
end

function BigWigsBugFamily:DeathCount(msg)
	if (msg == string.format(UNITDIESOTHER, kri) or msg == string.format(UNITDIESOTHER, yauj) or msg == string.format(UNITDIESOTHER, vem)) then
		deaths = deaths + 1
		if (deaths == 3) then
			if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], boss), "Bosskill", nil, "Victory") end
			self.core:ToggleModuleActive(self, false)
		end
	end
end

function BigWigsBugFamily:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if msg == L["healtrigger"] and self.db.profile.heal then
		self:TriggerEvent("BigWigs_StartBar", self, L["healbar"], 2, "Interface\\Icons\\Spell_Holy_Heal")
		self:TriggerEvent("BigWigs_Message", L["healwarn"], "Urgent")
	end
end

