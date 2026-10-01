extends Node
## Explicitly authorized content grant. No battle/offline simulation or currency changes.
func _ready() -> void:
	var store: SaveStore = SaveStore.new()
	var data: Dictionary = store.load_state()
	if data.is_empty():
		push_error("Wizard grant refused: existing profile unavailable. " + store.last_error)
		return
	var before: Dictionary = data.duplicate(true)
	var timestamp: float = store.loaded_saved_at
	var profile: PlayerProfile = PlayerProfile.from_data(data.profile)
	if not profile.content_grants.get("wizard_first_copy", false):
		profile.create_copy(&"would_be_wizard")
		profile.content_grants["wizard_first_copy"] = true
		data.profile = profile.to_data()
		if store.write_state(data, timestamp) != OK:
			push_error("Wizard grant write failed: " + store.last_error)
			return
	var verified: Dictionary = store.load_state()
	var wizard_count: int = 0
	for copy: Dictionary in verified.get("profile", {}).get("copies", []):
		if copy.species_id == &"would_be_wizard": wizard_count += 1
	var same: bool = not verified.is_empty()
	for field: String in ["gold", "dust", "shards", "global_ranks", "chrono_ranks"]:
		same = same and verified.profile[field] == before.profile[field]
	for field: String in before:
		if field != "profile": same = same and verified[field] == before[field]
	set_meta("result", {"wizard_copies": wizard_count, "progress_preserved": same,
		"timestamp_preserved": store.loaded_saved_at == timestamp, "path": ProjectSettings.globalize_path(store.path)})
	print("WIZARD GRANT: ", get_meta("result"))
