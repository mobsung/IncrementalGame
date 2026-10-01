extends "res://scripts/app/demo_controller.gd"
## Isolated preview only. Run with -- capture for disposable screenshots.

func _ready() -> void:
	persist_progress = false
	super._ready()
	set_physics_process(false)
	simulation.profile.shards = 1000.0
	for id: StringName in [&"chrono_allied_slot", &"chrono_multi_hit", &"chrono_multi_cast"]:
		simulation.purchase_shop_upgrade(&"chrono", id)
	simulation.unit().level = 25
	simulation.evolve_copy(simulation.unit().id)
	simulation.evolve_copy(simulation.unit().id)
	for index: int in range(3):
		var definition: CombatantDefinition = simulation.config.ally.duplicate(true)
		definition.id = StringName("preview_species_%d" % index)
		simulation.config.extra_definitions.append(definition)
		var copy: UnitProgress = simulation.profile.create_copy(definition.id)
		simulation.set_copy_deployed(copy.id, true)
	panels.show_section(&"units")
	_open_copy(simulation.unit().id)
	save_status.text = "Isolated preview · player save untouched"
	if "capture" not in OS.get_cmdline_user_args():
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/base_mechanics_unit_preview.png")
	%PanelScroll.scroll_vertical = 10000
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/base_mechanics_priorities_preview.png")
	panels.show_section(&"chrono")
	await get_tree().process_frame
	%PanelScroll.scroll_vertical = 10000
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/base_mechanics_chrono_preview.png")
	simulation.start()
	await _catch_up_offline(2.0)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tests/base_mechanics_offline_preview.png")
	print("PREVIEW: four copies, priorities, Chrono catalog and offline summary captured; persistence=false")
	get_tree().quit()
