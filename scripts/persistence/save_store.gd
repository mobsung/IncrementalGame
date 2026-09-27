class_name SaveStore
extends RefCounted
## Versioned binary snapshots preserve Vector2 and 64-bit RNG state without objects.

const VERSION: int = 7
const V4_STATS: Array[StringName] = [&"magic_attack", &"magic_resistance", &"ability_power",
	&"critical_chance", &"critical_multiplier", &"super_critical_chance", &"super_critical_multiplier",
	&"ultra_critical_chance", &"ultra_critical_multiplier"]
const MAX_BYTES: int = 4 * 1024 * 1024
var path: String = "user://first_demo.save"
var last_error: String = ""
var recovered: bool = false

func _init(save_path: String = "user://first_demo.save") -> void:
	path = save_path

func load_state() -> Dictionary:
	last_error = ""
	recovered = false
	for candidate: String in [path, path + ".tmp", path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var data: Dictionary = _read(candidate)
		if not data.is_empty():
			recovered = candidate != path
			last_error = ""
			return data
		# A newer version is not corruption: don't silently roll back its progress.
		if last_error.begins_with("Unsupported"):
			return {}
	return {}

func write_state(data: Dictionary) -> Error:
	last_error = ""
	if not validate(data):
		last_error = "Invalid battle snapshot."
		return ERR_INVALID_DATA
	var bytes: PackedByteArray = var_to_bytes(data)
	var envelope: Dictionary = {"version": VERSION, "saved_at": Time.get_unix_time_from_system(),
		"payload": bytes, "checksum": _hash(bytes)}
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = "Cannot open save: " + error_string(FileAccess.get_open_error())
		return FileAccess.get_open_error()
	file.store_var(envelope, false)
	file.flush()
	var result: Error = file.get_error()
	file.close()
	if result != OK:
		last_error = "Cannot write save: " + error_string(result)
		return result
	# Never replace a good backup with a corrupt primary.
	if FileAccess.file_exists(path) and not _read(path).is_empty():
		result = DirAccess.copy_absolute(path, path + ".bak")
		if result != OK:
			last_error = "Cannot create backup: " + error_string(result)
			return result
	result = DirAccess.rename_absolute(path + ".tmp", path)
	last_error = "" if result == OK else "Cannot replace save: " + error_string(result)
	return result

func _read(candidate: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(candidate, FileAccess.READ)
	if file == null:
		last_error = "Cannot read save."
		return {}
	if file.get_length() > MAX_BYTES or file.get_length() < 4:
		last_error = "Invalid save size."
		file.close()
		return {}
	var encoded_length: int = file.get_32()
	if encoded_length <= 0 or encoded_length != file.get_length() - 4:
		last_error = "Truncated save payload."
		file.close()
		return {}
	file.seek(0)
	var envelope: Variant = file.get_var(false)
	file.close()
	if not envelope is Dictionary or not envelope.has_all(["version", "payload", "checksum"]):
		last_error = "Invalid save header."
		return {}
	if not envelope.version is int or envelope.version < 1 or envelope.version > VERSION:
		last_error = "Unsupported save version: %s" % str(envelope.version)
		return {}
	if not envelope.payload is PackedByteArray or not envelope.checksum is String:
		last_error = "Invalid save payload."
		return {}
	if _hash(envelope.payload) != envelope.checksum:
		last_error = "Save checksum mismatch."
		return {}
	var data: Variant = bytes_to_var(envelope.payload)
	if data is Dictionary and envelope.version == 1:
		data = _migrate_v1(data)
	if data is Dictionary and envelope.version <= 2:
		data = _migrate_v2(data)
	if data is Dictionary and envelope.version <= 3:
		data = _migrate_v3(data)
	if data is Dictionary and envelope.version <= 4:
		data = _migrate_v4(data)
	if data is Dictionary and envelope.version <= 5:
		data = _migrate_v5(data)
	if data is Dictionary and envelope.version <= 6:
		data = _migrate_v6(data)
	if not data is Dictionary or not validate(data):
		last_error = "Invalid battle snapshot."
		return {}
	return data

static func _migrate_v1(data: Dictionary) -> Dictionary:
	# Only additive schema changes. Preserve all battle state and owned progress.
	data = data.duplicate(true)
	if not data.get("profile") is Dictionary or not data.profile.get("copies") is Array:
		return {}
	for copy: Variant in data.profile.copies:
		if not copy is Dictionary:
			return {}
		if not copy.has(&"upgrade_ranks"):
			copy[&"upgrade_ranks"] = {}
		if not copy.has(&"gold_ranks"):
			copy[&"gold_ranks"] = {}
	return data

static func _hash(bytes: PackedByteArray) -> String:
	var hashing: HashingContext = HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()

static func _migrate_v2(data: Dictionary) -> Dictionary:
	data = data.duplicate(true)
	if not data.get("profile") is Dictionary:
		return {}
	data.profile["global_ranks"] = {}
	data.profile["chrono_ranks"] = {}
	return data

static func _migrate_v3(data: Dictionary) -> Dictionary:
	data = data.duplicate(true)
	if not data.get("actors") is Array or not data.get("attempt_snapshot") is Dictionary:
		return {}
	var definitions: Dictionary = BattleSimulation.CONFIG.definitions()
	var states: Array = data.actors.duplicate()
	if not data.attempt_snapshot.is_empty():
		states.append(data.attempt_snapshot)
	for actor: Variant in states:
		if not actor is Dictionary or not definitions.has(actor.get("definition_id")):
			return {}
		var definition: CombatantDefinition = definitions[actor.definition_id]
		for stat: StringName in V4_STATS:
			if not actor.has(stat):
				# All pre-v4 content had zero magic attack/AP and no advanced critical purchases.
				actor[stat] = float(definition.get(stat))
	return data

static func _migrate_v4(data: Dictionary) -> Dictionary:
	data = data.duplicate(true)
	if not data.get("profile") is Dictionary or not data.profile.get("copies") is Array:
		return {}
	if data.profile.copies.is_empty() or not data.get("actors") is Array:
		return {}
	var primary_id: String = str(data.profile.copies[0].get("id", ""))
	if primary_id.is_empty():
		return {}
	for index: int in range(data.profile.copies.size()):
		var copy: Variant = data.profile.copies[index]
		if not copy is Dictionary:
			return {}
		copy[&"deployed"] = index == 0
	for actor: Variant in data.actors:
		if not actor is Dictionary:
			return {}
		actor[&"copy_id"] = primary_id if actor.get("allied", false) else ""
	var old_snapshot: Variant = data.get("attempt_snapshot")
	if not old_snapshot is Dictionary:
		return {}
	data[&"attempt_snapshot"] = []
	if not old_snapshot.is_empty():
		old_snapshot[&"copy_id"] = primary_id
		data.attempt_snapshot.append(old_snapshot)
	return data

static func _migrate_v5(data: Dictionary) -> Dictionary:
	data = data.duplicate(true)
	if not data.get("profile") is Dictionary or not data.profile.get("copies") is Array:
		return {}
	data.profile[&"next_copy_serial"] = data.profile.copies.size() + 1
	var summon_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	summon_rng.seed = int(data.get("rng_seed", 1)) ^ 0x5A17C9E3
	data[&"summon_rng_seed"] = summon_rng.seed
	data[&"summon_rng_state"] = summon_rng.state
	return data

static func _migrate_v6(data: Dictionary) -> Dictionary:
	data = data.duplicate(true)
	if not data.get("actors") is Array or not data.get("attempt_snapshot") is Array:
		return {}
	var definitions: Dictionary = BattleSimulation.CONFIG.definitions()
	var states: Array = data.actors.duplicate()
	states.append_array(data.attempt_snapshot)
	for actor: Variant in states:
		if not actor is Dictionary or not definitions.has(actor.get("definition_id")):
			return {}
		var definition: CombatantDefinition = definitions[actor.definition_id]
		actor[&"multi_hit"] = definition.multi_hit
		actor[&"multi_cast"] = definition.multi_cast
	return data

static func _fields_match(data: Dictionary, template: Dictionary) -> bool:
	for key: Variant in template:
		if not data.has(key) or typeof(data[key]) != typeof(template[key]):
			return false
		if data[key] is float and not is_finite(data[key]):
			return false
		if data[key] is Vector2 and not data[key].is_finite():
			return false
	return true

static func _actor_valid(data: Dictionary, definitions: Dictionary) -> bool:
	if not _fields_match(data, CombatantState.new().to_data()):
		return false
	for stat: StringName in [&"critical_chance", &"super_critical_chance", &"ultra_critical_chance"]:
		if data[stat] < 0.0 or data[stat] > 1.0:
			return false
	for stat: StringName in [&"critical_multiplier", &"super_critical_multiplier", &"ultra_critical_multiplier"]:
		if data[stat] < 1.0:
			return false
	if data.magic_attack < 0.0 or data.ability_power < 0.0:
		return false
	if data.multi_hit < 1 or data.multi_cast < 1:
		return false
	return definitions.has(data.definition_id) and data.id > 0 and data.max_health > 0.0 and (
		data.health >= 0.0 and data.health <= data.max_health and data.speed > 0.0 and
		data.attack_speed > 0.0 and data.attack_range >= 0.0 and data.action_left >= -0.1 and
		data.cooldown >= 0.0 and data.pending_cooldown >= 0.0 and data.passive_count >= 0 and
		data.action in [&"", &"basic", &"sweep"])

static func _copy_valid(copy_data: Dictionary, template: BattleSimulation) -> bool:
	if not _fields_match(copy_data, UnitProgress.new().to_data()):
		return false
	if copy_data.id.is_empty() or not template.config.definitions().has(copy_data.species_id) or copy_data.level < 1:
		return false
	if copy_data.experience < 0.0 or copy_data.level_points < 0 or copy_data.movement_speed <= 0.0:
		return false
	if copy_data.slot < 0 or copy_data.slot >= template.config.slots.size() or copy_data.priority not in [0, 1, 2, 3]:
		return false
	for id: Variant in copy_data.upgrade_ranks:
		if not id is StringName and not id is String:
			return false
		var upgrade: LevelUpgradeDefinition = template.config.upgrade_by_id(id)
		var rank: Variant = copy_data.upgrade_ranks[id]
		if upgrade == null or not rank is int or rank < 0 or rank > upgrade.max_ranks:
			return false
		if rank > 0 and not upgrade.unlocked_for(rank - 1, copy_data.level):
			return false
	for id: Variant in copy_data.gold_ranks:
		if not id is StringName and not id is String:
			return false
		var upgrade: GoldUpgradeDefinition = template.config.gold_upgrade_by_id(id)
		var rank: Variant = copy_data.gold_ranks[id]
		if upgrade == null or not rank is int or rank < 0 or rank > upgrade.max_ranks:
			return false
	return true

static func validate(data: Dictionary) -> bool:
	var template: BattleSimulation = BattleSimulation.new()
	if not _fields_match(data, template.to_data()):
		return false
	if data.phase not in [&"preparation", &"battle", &"paused"] or data.wave < 1 or data.record_wave < 0:
		return false
	if data.selected_wave < 1 or data.spawn_index < 0 or data.spawn_index > 12 or data.next_id < 2:
		return false
	if data.accumulator < 0.0 or data.attempt_time < 0.0 or data.tick < 0:
		return false
	for key: String in ["souls", "pending_gold", "pending_xp", "pending_souls"]:
		if data[key] < 0.0:
			return false
	if not _fields_match(data.profile, PlayerProfile.new().to_data()) or data.profile.copies.is_empty():
		return false
	if data.profile.gold < 0.0 or data.profile.dust < 0 or data.profile.shards < 0.0 or data.dust_earned < 0 or data.profile.next_copy_serial < 2:
		return false
	for shop: StringName in [&"global", &"chrono"]:
		var ranks: Dictionary = data.profile.global_ranks if shop == &"global" else data.profile.chrono_ranks
		for id: Variant in ranks:
			if not id is StringName and not id is String:
				return false
			var upgrade: StatUpgradeDefinition = template.config.shop_upgrade(shop, id)
			var rank: Variant = ranks[id]
			if upgrade == null or not rank is int or rank < 0 or rank > upgrade.max_ranks:
				return false
	var copies_by_id: Dictionary = {}
	var deployed_ids: Array[String] = []
	var deployed_slots: Array[int] = []
	for copy_data: Variant in data.profile.copies:
		if not copy_data is Dictionary or not _copy_valid(copy_data, template):
			return false
		if copies_by_id.has(copy_data.id):
			return false
		copies_by_id[copy_data.id] = copy_data
		if copy_data.deployed:
			if copy_data.slot in deployed_slots:
				return false
			deployed_ids.append(copy_data.id)
			deployed_slots.append(copy_data.slot)
	if deployed_ids.is_empty() or deployed_ids.size() > BattleSimulation.MAX_DEPLOYED_ALLIES:
		return false
	if data.actors.is_empty() or data.actors.size() > 1000:
		return false
	var ids: Array[int] = []
	var actor_copy_ids: Array[String] = []
	for actor_data: Variant in data.actors:
		if not actor_data is Dictionary or not _actor_valid(actor_data, template.config.definitions()):
			return false
		if actor_data.id in ids or actor_data.id >= data.next_id:
			return false
		ids.append(actor_data.id)
		if actor_data.allied:
			if not copies_by_id.has(actor_data.copy_id) or actor_data.copy_id not in deployed_ids or actor_data.copy_id in actor_copy_ids:
				return false
			if actor_data.definition_id != copies_by_id[actor_data.copy_id].species_id:
				return false
			actor_copy_ids.append(actor_data.copy_id)
		elif not actor_data.copy_id.is_empty():
			return false
	if actor_copy_ids.size() != deployed_ids.size():
		return false
	if data.phase != &"preparation":
		if data.attempt_snapshot.size() != deployed_ids.size():
			return false
		var snapshot_ids: Array[String] = []
		for snapshot: Variant in data.attempt_snapshot:
			if not snapshot is Dictionary or not _actor_valid(snapshot, template.config.definitions()):
				return false
			if not snapshot.allied or snapshot.copy_id not in deployed_ids or snapshot.copy_id in snapshot_ids:
				return false
			snapshot_ids.append(snapshot.copy_id)
		var sequence: Array[int] = []
		for value: Variant in data.sequence:
			if not value is int:
				return false
			sequence.append(value)
		if not WaveSequence.valid(sequence):
			return false
	return true
