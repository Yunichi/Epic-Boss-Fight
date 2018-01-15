brd_cleave_strike = class({})
LinkLuaModifier( "modifier_cleave_strike", "heroes/hero_brd/brd_cleave_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function brd_cleave_strike:PiercesDisableResistance()
    return true
end

function brd_cleave_strike:GetIntrinsicModifierName()
	return "modifier_cleave_strike"
end

modifier_cleave_strike = class({})

function modifier_cleave_strike:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_cleave_strike:OnTakeDamage(params)
	if IsServer() then
		if (params.unit == self:GetCaster() or ( params.attacker == self:GetCaster() and self:GetCaster():HasTalent("special_bonus_unique_brd_cleave_strike_2") ) ) 
		and self:GetAbility():IsCooldownReady() 
		and RollPercentage(self:GetTalentSpecialValueFor("chance")) then
			self:Spin(params)
		end
	end
end

function modifier_cleave_strike:Spin(params)
	EmitSoundOn("Hero_Axe.CounterHelix_Blood_Chaser", self:GetCaster())
	local armorDamage = self:GetCaster():GetPhysicalArmorValue() * self:GetTalentSpecialValueFor("armor_to_damage")/100
	local nfx = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt( nfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	ParticleManager:ReleaseParticleIndex(nfx)

	self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_3)

	params.attacker:Taunt(self:GetAbility(), self:GetCaster(), self:GetTalentSpecialValueFor("duration"))


	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetCaster():GetAttackDamage() + armorDamage, {}, 0)
	end

	self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()))
end

function modifier_cleave_strike:IsHidden()
	return true
end