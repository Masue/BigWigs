------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Anub'Rekhan"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Anubrekhan",

	locust_cmd = "locust",
	locust_name = "Locust Swarm Alert",
	locust_desc = "Warn for Locust Swarm",

	buff_cmd = "buff",
	buff_name = "Buff Alert",
	buff_desc = "Notify on Buffs Fading",
	
	starttrigger1 = "Just a little taste...",
	starttrigger2 = "Yes, Run! It makes the blood pump faster!",
	starttrigger3 = "There is no way out.",
	engagewarn = "Anub'Rekhan engaged. First Locust Swarm in ~60 sec",
	GNPPtrigger	= "Nature Protection",

	gaintrigger = "Anub'Rekhan gains Locust Swarm.",
	gainendwarn = "Locust Swarm ended!",
	gainnextwarn = "Next Locust Swarm in ~50 sec",
	gainwarn10sec = "~10 Seconds until Locust Swarm",
	gainincbar = "Next Locust Swarm",
	gainbar = "Locust Swarm",

	casttrigger = "Anub'Rekhan begins to cast Locust Swarm.",
	castwarn = "Incoming Locust Swarm!",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsAnubrekhan = BigWigs:NewModule(boss)
BigWigsAnubrekhan.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsAnubrekhan.enabletrigger = boss
BigWigsAnubrekhan.toggleoptions = {"locust", "buff", "bosskill"}
BigWigsAnubrekhan.revision = tonumber(string.sub("$Revision: 15496 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsAnubrekhan:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "LocustCast")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "LocustCast")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "AnubLocustInc", 35)
	self:TriggerEvent("BigWigs_ThrottleSync", "AnubLocustSwarm", 35)
end

function BigWigsAnubrekhan:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if self.db.profile.buff then
		if string.find(msg, L["GNPPtrigger"]) then
				BigWigsThaddiusArrows:GNPPstop()
		end
	end
end

function BigWigsAnubrekhan:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if self.db.profile.buff then
		if string.find(msg, L["GNPPtrigger"]) then
				BigWigsThaddiusArrows:Direction("GNPP")
		end
	end
end

function BigWigsAnubrekhan:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.locust and msg == L["starttrigger1"] or msg == L["starttrigger2"] or msg == L["starttrigger3"] then
		self:TriggerEvent("BigWigs_Message", L["engagewarn"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 60, L["gainwarn10sec"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["gainincbar"], 70, "Interface\\Icons\\Spell_Nature_InsectSwarm")
	end
end

function BigWigsAnubrekhan:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if msg == L["gaintrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "AnubLocustSwarm")
	end
end

function BigWigsAnubrekhan:LocustCast( msg )
	if msg == L["casttrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "AnubLocustInc")
	end
end

function BigWigsAnubrekhan:BigWigs_RecvSync( sync )
	if sync == "AnubLocustInc" then
	        BigWigsThaddiusArrows:Direction("Run")
		self:ScheduleEvent("bwanublocustinc", self.TriggerEvent, 3.25, self, "BigWigs_SendSync", "AnubLocustSwarm")
		if self.db.profile.locust then
			self:TriggerEvent("BigWigs_Message", L["castwarn"], "Orange", true, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["castwarn"], 3, "Interface\\Icons\\Spell_Nature_InsectSwarm" )
		end
	elseif sync == "AnubLocustSwarm" then
		self:CancelScheduledEvent("bwanublocustinc")
		if self.db.profile.locust then
			self:ScheduleEvent("BigWigs_Message", 21, L["gainendwarn"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["gainbar"], 21, "Interface\\Icons\\Spell_Nature_InsectSwarm")
			self:TriggerEvent("BigWigs_Message", L["gainnextwarn"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 50, L["gainwarn10sec"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["gainincbar"], 60, "Interface\\Icons\\Spell_Nature_InsectSwarm")
		end
	end
end

