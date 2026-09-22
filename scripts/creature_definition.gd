class_name CreatureDefinition
extends Resource

enum ElementType {
	NEUTRAL,
	FIRE,
	WATER,
	EARTH,
	LIGHTNING,
	ICE,
	DARKNESS
}

@export var id: String = "mana_wisp"
@export var display_name: String = "Mana Wisp"
@export var element_type: ElementType = ElementType.NEUTRAL
@export var primary_element: String = "Neutral"
@export var secondary_element: String = ""
@export var tertiary_element: String = ""
@export var element_color: Color = Color(0.35, 0.75, 1.0, 1.0)
@export var secondary_color: Color = Color(0.2, 0.5, 0.9, 1.0)
@export var is_pure: bool = true
@export var tier_rank: int = 0 # 0=Base, 1=Stage 1, 2=Stage 2, 3=Stage 3 Apex
@export var portrait: Texture2D = null
@export_multiline var description: String = "A pure sphere of primordial arcane energy."

@export_group("Base Stats")
@export var base_yield: float = 5.0
@export var base_conversion: float = 100.0
@export var channel_interval: float = 1.0
@export var crit_chance: float = 0.05
@export var crit_power: float = 2.0
@export var super_crit_chance: float = 0.0
@export var super_crit_power: float = 2.0

@export_group("Elemental Specialization & Caps")
@export var yield_multiplier: float = 1.0 # Fire boost
@export var speed_cap: float = 0.15 # Ice lowers down to 0.05s
@export var flow_cap: float = 10.0 # Water lowers down to 1.0
@export var crit_cap: float = 0.50 # Lightning raises to 1.0
@export var super_crit_cap: float = 0.0 # Darkness raises to 0.75

@export_group("Elemental Burst Proc")
@export var proc_name: String = ""
@export var proc_cycle_interval: int = 10
@export var proc_description: String = ""
@export var proc_color: Color = Color.WHITE

@export_group("Evolution")
@export var evolution_level_req: int = 10
@export var evolution_options: Array[Resource] = []
@export var evolution_option_ids: Array[String] = []

@export_group("Upgrades")
@export var available_upgrades: Array[UpgradeDefinition] = []

func get_element_display() -> String:
	var tags: Array[String] = [primary_element]
	if not secondary_element.is_empty():
		tags.append(secondary_element)
	if not tertiary_element.is_empty():
		tags.append(tertiary_element)
	return " / ".join(tags).to_upper()

func get_evolution_choices() -> Array:
	if not evolution_options.is_empty():
		return evolution_options
	var choices: Array = []
	for opt_id in evolution_option_ids:
		var res_path: String = "res://resources/creatures/%s.tres" % opt_id
		if ResourceLoader.exists(res_path):
			var res = load(res_path)
			if res != null:
				choices.append(res)
	return choices


