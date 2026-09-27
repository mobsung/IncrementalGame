class_name CombatMath
extends RefCounted

static func mitigate(damage: float, defense: float) -> float:
	var factor: float = 100.0 / (100.0 + defense) if defense >= 0.0 else 2.0 - 100.0 / (100.0 - defense)
	return maxf(damage, 0.0) * factor

static func critical_chain(source: CombatantState, rng: RandomNumberGenerator) -> Dictionary:
	var multiplier: float = 1.0
	var stage: int = 0
	var chances: Array[float] = [source.critical_chance, source.super_critical_chance, source.ultra_critical_chance]
	var factors: Array[float] = [source.critical_multiplier, source.super_critical_multiplier, source.ultra_critical_multiplier]
	for index: int in range(3):
		var chance: float = clampf(chances[index], 0.0, 1.0)
		# Preserve the original normal-critical RNG draw; unavailable later stages draw nothing.
		if index > 0 and chance <= 0.0:
			break
		var roll: float = rng.randf()
		if chance < 1.0 and roll >= chance:
			break
		stage += 1
		multiplier *= factors[index]
	return {"stage": stage, "multiplier": multiplier}

## Capture the source at effect creation. Defenses remain an impact-time decision.
static func create_damage(source: CombatantState, definition: DamageDefinition,
		physical_bonus: float, rng: RandomNumberGenerator) -> Dictionary:
	var power: float = maxf(0.0, 1.0 + source.ability_power * definition.ability_power_ratio)
	var physical: float = maxf(0.0, source.attack * (definition.damage_coefficient + physical_bonus)) * power
	var magic: float = maxf(0.0, source.magic_attack * definition.magic_coefficient) * power
	var critical: Dictionary = {"stage": 0, "multiplier": 1.0}
	if definition.can_crit and (definition.physical_can_crit or definition.magic_can_crit):
		critical = critical_chain(source, rng)
	if definition.physical_can_crit:
		physical *= critical.multiplier
	if definition.magic_can_crit:
		magic *= critical.multiplier
	return {"physical": physical, "magic": magic, "critical_stage": critical.stage}

static func damage_amount(packet: Dictionary, target: CombatantState) -> float:
	return mitigate(packet.physical, target.armor) + mitigate(packet.magic, target.magic_resistance)

static func in_sector(origin: Vector2, facing: Vector2, point: Vector2, radius: float,
		angle_degrees: float) -> bool:
	var offset: Vector2 = point - origin
	if offset.length_squared() > radius * radius + 0.0001:
		return false
	return offset.is_zero_approx() or facing.normalized().dot(offset.normalized()) >= cos(deg_to_rad(angle_degrees * 0.5)) - 0.0001

static func resolve(actors: Array[CombatantState], damage: Dictionary, healing: Dictionary) -> Array[int]:
	# All effects for the tick are collected before health changes. Lethal damage wins.
	var deaths: Array[int] = []
	for actor: CombatantState in actors:
		if not actor.alive():
			continue
		var incoming: float = damage.get(actor.id, 0.0)
		if incoming >= actor.health:
			actor.health = 0.0
			actor.passive_count = 0
			deaths.append(actor.id)
		else:
			actor.health = minf(actor.max_health, actor.health - incoming + float(healing.get(actor.id, 0.0)))
	return deaths
