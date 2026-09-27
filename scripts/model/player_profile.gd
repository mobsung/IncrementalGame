class_name PlayerProfile
extends RefCounted

## Permanent ownership and balances; independent from attempt rollback.
var copies: Array[UnitProgress] = []
var gold: float = 0.0
var dust: int = 0
var shards: float = 0.0
var global_ranks: Dictionary = {}
var chrono_ranks: Dictionary = {}
var next_copy_serial: int = 2

func shop_ranks(shop: StringName) -> Dictionary:
	return global_ranks if shop == &"global" else chrono_ranks

func copy_by_id(copy_id: String) -> UnitProgress:
	for copy: UnitProgress in copies:
		if copy.id == copy_id:
			return copy
	return null

func deployed_copies() -> Array[UnitProgress]:
	var result: Array[UnitProgress] = []
	for copy: UnitProgress in copies:
		if copy.deployed:
			result.append(copy)
	return result

func create_copy(species_id: StringName) -> UnitProgress:
	var copy: UnitProgress = UnitProgress.new()
	copy.species_id = species_id
	copy.id = "copy_%08d" % next_copy_serial
	while copy_by_id(copy.id) != null:
		next_copy_serial += 1
		copy.id = "copy_%08d" % next_copy_serial
	next_copy_serial += 1
	copies.append(copy)
	return copy

func _init() -> void:
	var starter: UnitProgress = UnitProgress.new()
	starter.id = "starter_john_0001"
	starter.deployed = true
	copies.append(starter)

func to_data() -> Dictionary:
	var units: Array[Dictionary] = []
	for copy: UnitProgress in copies:
		units.append(copy.to_data())
	return {"copies": units, "gold": gold, "dust": dust, "shards": shards,
		"next_copy_serial": next_copy_serial,
		"global_ranks": global_ranks.duplicate(), "chrono_ranks": chrono_ranks.duplicate()}

static func from_data(data: Dictionary) -> PlayerProfile:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.copies.clear()
	for copy_data: Dictionary in data.copies:
		profile.copies.append(UnitProgress.from_data(copy_data))
	profile.gold = data.gold
	profile.dust = data.dust
	profile.shards = data.shards
	profile.next_copy_serial = data.next_copy_serial
	profile.global_ranks = data.global_ranks.duplicate()
	profile.chrono_ranks = data.chrono_ranks.duplicate()
	return profile
