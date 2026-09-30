class_name EvolutionDefinition
extends Resource
## One optional, permanent edge in a species' authored evolution tree.
@export var id: StringName
@export var required_level: int = 10
@export_multiline var description: String
@export var form: CombatantDefinition

func valid() -> bool:
	return not id.is_empty() and id != &"linear" and not String(id).begins_with("__linear_") and required_level >= 1 and form != null
