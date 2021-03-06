boss_evil_core_passive = class({})

function boss_evil_core_passive:GetIntrinsicModifierName()
	return "modifier_boss_evil_core_passive"
end

modifier_boss_evil_core_passive = class({})
LinkLuaModifier("modifier_boss_evil_core_passive", "bosses/boss_evil_core/boss_evil_core_passive", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	POSSIBLE_BOSSES = {	"npc_dota_boss31", 
						"npc_dota_boss32_trueform", 
						"npc_dota_boss33_a", 
						"npc_dota_boss33_b", 
						"npc_dota_boss34", 
						"npc_dota_boss35" }

	function modifier_boss_evil_core_passive:OnCreated()
		self.manaCharge = self:GetParent():GetMaxMana()
		self.manaChargeRegen = ( self.manaCharge / self:GetTalentSpecialValueFor("recharge_time") ) * 0.3
		self.damageTaken = self:GetTalentSpecialValueFor("damage_per_hit")
		
		
		self:StartIntervalThink(0.3)
	end
	
	function modifier_boss_evil_core_passive:OnDestroy()
		self:DestroyShield()
	end
	
	function modifier_boss_evil_core_passive:OnIntervalThink()
		local parent = self:GetParent()
		if not self.asuraSpawn then
			parent:SetMana(self.manaCharge)
			if not self.shield then
				if self.manaCharge < parent:GetMaxMana() then
					self.manaCharge = math.min(parent:GetMaxMana(), self.manaCharge + self.manaChargeRegen)
				elseif self:GetAbility():IsCooldownReady() then -- guarantee a minimum of time between casts
					self:ActivateShield()
				end
			else
				self.manaCharge = math.min(parent:GetMaxMana(), self.manaCharge + self.manaChargeRegen)
				if self.manaCharge >= parent:GetMaxMana() then
					self:DestroyShield()
				end
			end
		end
	end
	
	function modifier_boss_evil_core_passive:ActivateShield(bInit)
		local parent = self:GetParent()
		self.shield = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_POINT_FOLLOW, parent)
		ParticleManager:SetParticleControl(self.shield, 1, Vector(200,200,0))
		local count = (2 + math.floor((100 - parent:GetHealthPercent()) / 25))
		
		self:GetAbility():SetCooldown()
		self.manaCharge = 0
		parent:SetMana(self.manaCharge)
		for i = 1, count do
			self:SpawnRandomUnit( parent:GetAbsOrigin() + ActualRandomVector(800, 450) )
		end
	end
	
	function modifier_boss_evil_core_passive:DestroyShield()
		ParticleManager:ClearParticle(self.shield)
		self.shield = nil
	end
	
	function modifier_boss_evil_core_passive:SpawnAsura(position)
		local caster = self:GetCaster()
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
			if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and unit:GetUnitName() ~= "npc_dota_boss36" and unit:GetUnitName() ~= "npc_dota_boss36_guardian" then
				unit:ForceKill(true)
			end
		end
		local asura = CreateUnitByName( "npc_dota_boss36_guardian" , position, true, nil, nil, caster:GetTeam() )
		asura:AddNewModifier(caster, self:GetAbility(), "modifier_spawn_immunity", {duration = 3})
		caster:ForceKill(false)
		GameRules.holdOut:_RefreshPlayers()
		return true
	end
	
	function modifier_boss_evil_core_passive:SpawnRandomUnit(position)
		local spawnedUnit = CreateUnitByName( POSSIBLE_BOSSES[RandomInt(1, #POSSIBLE_BOSSES)] , position, true, nil, nil, self:GetCaster():GetTeam() )
		spawnedUnit:SetBaseMaxHealth(1666666)
		spawnedUnit:SetMaxHealth(1666666)
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnedUnit:SetAverageBaseDamage(spawnedUnit:GetAverageBaseDamage() / 3, 20)
		
		spawnedUnit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_spawn_immunity", {duration = 3})
	end
end

function modifier_boss_evil_core_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_boss_evil_core_passive:GetModifierIncomingDamage_Percentage( params )
	local parent = self:GetParent()
	
	local damage = self.damageTaken * ((GameRules.BasePlayers - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)) + 1)
	if self.shield then damage = 1 end
	if parent:GetHealth() > damage then
		parent:SetHealth( math.max(1, parent:GetHealth() - damage) )
	elseif not self.asuraSpawn then
		self.asuraSpawn = self:SpawnAsura(self:GetParent():GetAbsOrigin())
	end
	return -999
end