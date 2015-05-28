--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Ouro"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local berserkannounced
local started 

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Ouro",

	sweep_cmd = "sweep",
	sweep_name = "Sweep Alert",
	sweep_desc = "Warn for Sweeps",

	sandblast_cmd = "sandblast",
	sandblast_name = "Sandblast Alert",
	sandblast_desc = "Warn for Sandblasts",

	emerge_cmd = "emerge",
	emerge_name = "Emerge Alert",
	emerge_desc = "Warn for Emerge",

	submerge_cmd = "submerge",
	submerge_name = "Submerge Alert",
	submerge_desc = "Warn for Submerge",

	scarab_cmd = "scarab",
	scarab_name = "Scarab Despawn Alert",
	scarab_desc = "Warn for Scarab Despawn",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for when Ouro goes berserk",

	sweeptrigger = "Ouro begins to cast Sweep",
	sweepannounce = "Sweep!",
	sweepwarn = "3 seconds until Sweep!",
	sweepcastbartext = "Sweep casting!",
	sweepbartext = "Sweep",

	sandblasttrigger = "Ouro begins to cast Sand Blast",
	sandblastannounce = "Incoming Sand Blast!",
	sandblastwarn = "5 seconds until Sand Blast!",
	sandblastcastbartext = "Sand Blast!",
	sandblastbartext = "Sand Blast",


	lolbar = "lolbar",

	engage_message = "Ouro engaged! Possible Submerge in 90sec!",
	possible_submerge_bar = "Possible submerge",

	emergetrigger = "Birth.",
	emergeannounce = "Ouro has emerged!",
	emergewarn = "15 sec to possible submerge!",
	emergewarn2 = "15 sec to Ouro sumberge!",
	emergebartext = "Ouro submerge",

	scarabdespawn = "Scarabs despawn in 10 Seconds",
	scarabbar = "Scarabs despawn",

	submergetrigger = "Ouro casts Summon Ouro Mounds.",
	submergeannounce = "Ouro has submerged!",
	submergewarn = "5 seconds until Ouro Emerges!",
	submergebartext = "Ouro Emerge",

	berserktrigger = "%s goes into a berserker rage!",
	berserkannounce = "Berserk!",
	berserksoonwarn = "Berserk Soon - Get Ready!",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsOuro = BigWigs:NewModule(boss)
BigWigsOuro.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsOuro.enabletrigger = boss
BigWigsOuro.toggleoptions = {"sweep", "sandblast", "scarab", -1, "emerge", "submerge", -1, "berserk", "bosskill"}
BigWigsOuro.revision = tonumber(string.sub("$Revision: 17592 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsOuro:OnEnable()
	berserkannounced = nil
	started = nil

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("UNIT_HEALTH")

	self:RegisterEvent("BigWigs_RecvSync")

	self:TriggerEvent("BigWigs_ThrottleSync", "OuroSweep", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "OuroSandblast", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "OuroEmerge", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "OuroSubmerge", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "OuroBerserk", 10)
end

function BigWigsOuro:UNIT_HEALTH( msg )
	if UnitName(msg) == boss then
		local health = UnitHealth(msg)
		if health > 20 and health <= 23 and not berserkannounced then
			if self.db.profile.berserk then
				self:TriggerEvent("BigWigs_Message", L["berserksoonwarn"], "Important")
			end
			berserkannounced = true
		elseif health > 30 and berserkannounced then
			berserkannounced = nil
		end
	end
end

function BigWigsOuro:BigWigs_RecvSync( sync, rest, nick )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		if self.db.profile.emerge then
			self:TriggerEvent("BigWigs_Message", L["engage_message"], "Attention")
			self:PossibleSubmerge()
		end
	elseif sync == "OuroSweep" then
		self:Sweep()
	elseif sync == "OuroSandblast" then
		self:Sandblast()
	elseif sync == "OuroEmerge" then
		self:Emerge()
	elseif sync == "OuroSubmerge" then
		self:Submerge()
	elseif sync == "OuroBerserk" then
		self:Berserk()
	end
end

function BigWigsOuro:PossibleSubmerge()
	if self.db.profile.emerge then
		self:ScheduleEvent("bwouroemergewarn", "BigWigs_Message", 75, L["emergewarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["possible_submerge_bar"], 90, "Interface\\Icons\\Spell_Nature_Earthquake")
		self:ScheduleEvent("bwouroemergewarn2", "BigWigs_Message", 165, L["emergewarn2"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["emergebartext"], 180, "Interface\\Icons\\Spell_Nature_Earthquake")
	end
end

function BigWigsOuro:CHAT_MSG_YELL( msg )
	if string.find(msg, L["lolbar"]) then
		self:TriggerEvent("BigWigs_StartBar", self, L["lolbar"], 600, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	end
end

function BigWigsOuro:Berserk()
	self:CancelScheduledEvent("bwouroemergewarn")
	self:CancelScheduledEvent("bwouroemergewarn2")
	self:TriggerEvent("BigWigs_StopBar", self, L["emergebartext"])
	self:TriggerEvent("BigWigs_StopBar", self, L["possible_submerge_bar"])

	if self.db.profile.berserk then
		self:TriggerEvent("BigWigs_Message", L["berserkannounce"], "Important")
	end
end

function BigWigsOuro:Sweep()
	if self.db.profile.sweep then
		self:ScheduleEvent("bwourosweepwarn", "BigWigs_Message", 15, L["sweepwarn"], "Urgent", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["sweepcastbartext"], 1.5, "Interface\\Icons\\Spell_Nature_Thorns")
		self:TriggerEvent("BigWigs_StartBar", self, L["sweepbartext"], 17, "Interface\\Icons\\Spell_Nature_Thorns")
	end
end

function BigWigsOuro:Sandblast()
	if self.db.profile.sandblast then
		self:TriggerEvent("BigWigs_StartBar", self, L["sandblastcastbartext"], 2, "Interface\\Icons\\Spell_Nature_Cyclone")
		self:ScheduleEvent("bwouroblastwarn", "BigWigs_Message", 15, L["sandblastwarn"], "Urgent", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["sandblastbartext"], 17, "Interface\\Icons\\Spell_Nature_Cyclone")
	end
end

function BigWigsOuro:Emerge()
	if self.db.profile.emerge then
		self:TriggerEvent("BigWigs_Message", L["emergeannounce"], "Important")
		self:PossibleSubmerge()
	end

	if self.db.profile.sweep then
		self:ScheduleEvent("bwourosweepwarn", "BigWigs_Message", 16, L["sweepwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["sweepbartext"], 21, "Interface\\Icons\\Spell_Nature_Thorns")
	end	

	if self.db.profile.sandblast then
		self:ScheduleEvent("bwouroblastwarn", "BigWigs_Message", 17, L["sandblastwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["sandblastbartext"], 22, "Interface\\Icons\\Spell_Nature_Cyclone")
	end

	if self.db.profile.scarab then
		self:ScheduleEvent("bwscarabdespawn", "BigWigs_Message", 50, L["scarabdespawn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["scarabbar"], 60, "Interface\\Icons\\INV_Scarab_Clay")
	end
end

function BigWigsOuro:Submerge()
	self:CancelScheduledEvent("bwourosweepwarn")
	self:CancelScheduledEvent("bwouroblastwarn")
	self:CancelScheduledEvent("bwouroemergewarn")
	self:CancelScheduledEvent("bwouroemergewarn2")

	self:TriggerEvent("BigWigs_StopBar", self, L["sweepbartext"])
	self:TriggerEvent("BigWigs_StopBar", self, L["sandblastbartext"])
	self:TriggerEvent("BigWigs_StopBar", self, L["emergebartext"])
	self:TriggerEvent("BigWigs_StopBar", self, L["possible_submerge_bar"])

	if self.db.profile.submerge then
		self:TriggerEvent("BigWigs_Message", L["submergeannounce"], "Important")
		self:ScheduleEvent("bwsubmergewarn", "BigWigs_Message", 40, L["submergewarn"], "Important" )
		self:TriggerEvent("BigWigs_StartBar", self, L["submergebartext"], 45, "Interface\\Icons\\Spell_Nature_Earthquake")
	end
end

function BigWigsOuro:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if string.find(msg, L["emergetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OuroEmerge")
	elseif string.find(msg, L["submergetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OuroSubmerge")
	end
end

function BigWigsOuro:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	if string.find(msg, L["sweeptrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OuroSweep")
	elseif string.find(msg, L["sandblasttrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OuroSandblast")
	elseif string.find(msg, L["submergetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OuroSubmerge")
	end
end

function BigWigsOuro:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["berserktrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "OuroBerserk")
	end
end
