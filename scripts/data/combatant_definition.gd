class_name CombatantDefinition
extends Resource
## Shared authored content. Runtime health, positions and cooldowns live elsewhere.

@export var id: StringName
@export var display_name: String
@export_enum("mage", "healer", "tank", "warrior", "summoner", "ranged") var unit_class: String = "warrior"
@export var max_health: float = 30.0
@export var physical_attack: float = 3.0
@export var magic_attack: float = 0.0
@export var magic_resistance: float = 0.0
@export var ability_power: float = 0.0
@export var basic_damage: DamageDefinition = preload("res://resources/attacks/physical_basic.tres")
@export var armor: float = 0.0
@export var attack_speed: float = 1.0
@export var attack_range: float = 60.0
@export var multi_hit: int = 1
@export var multi_cast: int = 1
@export var movement_speed: float = 80.0
@export var engagement_radius: float = 0.0
@export var critical_chance: float = 0.0
@export var critical_multiplier: float = 1.5
@export var super_critical_chance: float = 0.0
@export var super_critical_multiplier: float = 2.0
@export var ultra_critical_chance: float = 0.0
@export var ultra_critical_multiplier: float = 2.0
@export var gold: float = 1.0
@export var experience: float = 1.0
@export var souls: float = 1.0
@export var visual_color: Color = Color.WHITE
@export var visual_radius: float = 18.0
@export var ability: SweepDefinition
@export var heal_every_attacks: int = 0
@export var heal_fraction: float = 0.0
@export var forms: Array[Resource] = []
@export var evolution_level: int = 1
@export var kit: Resource
@export var visual: CombatantVisual
@export var active_abilities: Array[AbilityDefinition] = []
@export var enemy_support_role: bool = false
@export var evolution_options: Array[EvolutionDefinition] = []
@export var wizard_role: String = ""
@export var basic_name: String = "Basic attack"
@export var basic_projectile_speed: float = 0.0
@export var passive_names: PackedStringArray = []
@export var knockback_immune: bool = false
@export var basic_icon: Texture2D
@export var passive_icons: Array[Texture2D] = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if id.is_empty() or display_name.is_empty():
		errors.append("Combatant requires an ID and a display name.")
	if max_health <= 0.0 or attack_speed <= 0.0 or movement_speed <= 0.0:
		errors.append("Health, attack speed and movement speed must be positive: %s" % id)
	if attack_range < 0.0 or critical_chance < 0.0 or critical_chance > 1.0:
		errors.append("Invalid range or critical chance: %s" % id)
	if multi_hit < 1 or multi_cast < 1:
		errors.append("Multi Hit and Multi Cast must be at least one: %s" % id)
	for value: float in [physical_attack, magic_attack, ability_power]:
		if not is_finite(value) or value < 0.0:
			errors.append("Invalid attack or Ability Power: %s" % id)
	for value: float in [armor, magic_resistance]:
		if not is_finite(value):
			errors.append("Invalid defense: %s" % id)
	for value: float in [critical_chance, super_critical_chance, ultra_critical_chance]:
		if not is_finite(value) or value < 0.0 or value > 1.0:
			errors.append("Critical chance must be in [0, 1]: %s" % id)
	for value: float in [critical_multiplier, super_critical_multiplier, ultra_critical_multiplier]:
		if not is_finite(value) or value < 1.0:
			errors.append("Critical multiplier must be at least one: %s" % id)
	if basic_damage == null:
		errors.append("Missing basic damage definition: %s" % id)
	else:
		errors.append_array(basic_damage.validation_errors())
	if ability != null:
		errors.append_array(ability.validation_errors())
	var ability_ids: Array[StringName] = []
	var branch_ids: Array[StringName] = []
	for option: EvolutionDefinition in evolution_options:
		if option == null or not option.valid() or option.id in branch_ids:
			errors.append("Invalid or duplicate evolution option.")
		else:
			branch_ids.append(option.id)
	for active: AbilityDefinition in active_abilities:
		if active == null:
			errors.append("Missing active ability.")
			continue
		errors.append_array(active.validation_errors())
		if active.id in ability_ids:
			errors.append("Duplicate active ability: %s" % active.id)
		ability_ids.append(active.id)
	return errors
