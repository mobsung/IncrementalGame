extends Resource
## Presentation-only soft rig. The simulation is the sole authority for impacts.

@export var weight: float = 1.0
@export var heart: Vector2 = Vector2(0.63, 0.47)
@export var near_fist: Vector2 = Vector2(0.25, 0.56)
@export var far_fist: Vector2 = Vector2(0.84, 0.65)

const Player = preload("res://content/units/warriors/spaghetti_golem/visuals/animations/golem_motion_player.gd")

func create_player() -> RefCounted:
	return Player.new(self)
