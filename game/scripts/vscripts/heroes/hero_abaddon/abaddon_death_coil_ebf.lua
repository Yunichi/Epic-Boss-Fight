abaddon_death_coil_ebf = class({})

function abaddon_death_coil_ebf:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		return UF_FAIL_CUSTOM
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, target:GetTeamNumber())
	end
end

function abaddon_death_coil_ebf:GetCustomCastErrorTarget(target)
	return "Cannot target caster"
end

function abaddon_death_coil_ebf:OnSpellStart()
	-- Variables
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local projectile_speed = self:GetTalentSpecialValueFor( "projectile_speed" )
	local particle_name = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")

	local heal_pct = self:GetTalentSpecialValueFor( "heal_pct" ) / 100
	local self_heal = self:GetTalentSpecialValueFor( "self_heal" )
	caster:HealEvent(self_heal + caster:GetMaxHealth()*heal_pct, self, caster)

	local projectile = {
		Target = target,
		Source = caster,
		Ability = self,
		EffectName = particle_name,
		bDodgable = false,
		bProvidesVision = false,
		iMoveSpeed = 6000,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	}
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function abaddon_death_coil_ebf:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	if target then
		target:EmitSound("Hero_Abaddon.DeathCoil.Target")
		
		local damage = self:GetTalentSpecialValueFor( "target_damage")
		local heal = self:GetTalentSpecialValueFor( "heal_amount" )
		local heal_pct = self:GetTalentSpecialValueFor( "heal_pct" ) / 100

		-- If the target and caster are on a different team, do Damage. Heal otherwise
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
		else
			target:HealEvent(heal + target:GetMaxHealth()*heal_pct, self, caster)
		end
	end
end