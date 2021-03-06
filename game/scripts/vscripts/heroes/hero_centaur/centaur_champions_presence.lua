centaur_champions_presence = class({})

function centaur_champions_presence:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn( "Hero_Centaur.Gore", caster )
	caster:AddNewModifier(caster, self, "modifier_centaur_champions_presence_buff", {duration = self:GetTalentSpecialValueFor("duration")})
	ParticleManager:FireParticle( "particles/units/heroes/hero_centaur/centaur_champions_presence_start.vpcf", PATTACH_POINT_FOLLOW, caster )
end

modifier_centaur_champions_presence_buff = class({})
LinkLuaModifier("modifier_centaur_champions_presence_buff", "heroes/hero_centaur/centaur_champions_presence", LUA_MODIFIER_MOTION_NONE)

function modifier_centaur_champions_presence_buff:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.cdr = self:GetTalentSpecialValueFor("cdr_per_unit")
	self.amp = self:GetTalentSpecialValueFor("amp_per_unit")	
	self.max_stacks = self:GetTalentSpecialValueFor("max_amp") / self:GetTalentSpecialValueFor("amp_per_unit")
	
	self:SetStackCount(0)
	
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
		self:StartIntervalThink(0.5) 
	end
end

function modifier_centaur_champions_presence_buff:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.cdr = self:GetTalentSpecialValueFor("cdr_per_unit")
	self.amp = self:GetTalentSpecialValueFor("amp_per_unit")
	self.max_stacks = self:GetTalentSpecialValueFor("max_amp") / self:GetTalentSpecialValueFor("amp_per_unit")
end

function modifier_centaur_champions_presence_buff:OnIntervalThink()
	local caster = self:GetCaster()
	local targets = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
	
	local count = 0
	for _, target in ipairs( targets ) do
		if target:HasModifier("modifier_centaur_champions_presence_taunt") then count = count + 1 end
	end
	count = math.min(count, self.max_stacks)
	self:SetStackCount(count)
end

function modifier_centaur_champions_presence_buff:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_centaur_champions_presence_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_centaur_champions_presence_buff:GetModifierPercentageCooldownStacking()
	return self.cdr * self:GetStackCount()
end

function modifier_centaur_champions_presence_buff:GetModifierSpellAmplify_Percentage()
	return self.amp * self:GetStackCount()
end

function modifier_centaur_champions_presence_buff:GetEffectName()
	return "particles/econ/events/ti6/radiance_owner_ti6.vpcf"
end

function modifier_centaur_champions_presence_buff:IsAura()
	return true
end

function modifier_centaur_champions_presence_buff:GetModifierAura()
	return "modifier_centaur_champions_presence_taunt"
end

function modifier_centaur_champions_presence_buff:GetAuraRadius()
	return self.radius
end

function modifier_centaur_champions_presence_buff:GetAuraDuration()
	return 0.5
end

function modifier_centaur_champions_presence_buff:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_centaur_champions_presence_buff:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_centaur_champions_presence_taunt = class({})
LinkLuaModifier("modifier_centaur_champions_presence_taunt", "heroes/hero_centaur/centaur_champions_presence", LUA_MODIFIER_MOTION_NONE	)

function modifier_centaur_champions_presence_taunt:GetTauntTarget()
	return self:GetCaster()
end

function modifier_centaur_champions_presence_taunt:GetEffectName()
	return "particles/brd_taunt/brd_taunt_mark_base.vpcf"
end

function modifier_centaur_champions_presence_taunt:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_centaur_champions_presence_taunt:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_centaur_champions_presence_taunt:StatusEffectPriority()
	return 10
end

function modifier_centaur_champions_presence_taunt:IsPurgable()
	return false
end

function modifier_centaur_champions_presence_taunt:IsDebuff()
	return true
end