class_name ShopModifiers
extends RefCounted
## Additive contributions precede distinct Gold-global and Chrono multiplier pools.

static func value(base: float, stat: String, profile: PlayerProfile, config: BattleConfig) -> float:
	var additive: float = 0.0
	var multiplier: float = 1.0
	for shop: StringName in [&"global", &"chrono"]:
		var pool: float = 0.0
		var ranks: Dictionary = profile.shop_ranks(shop)
		for upgrade: StatUpgradeDefinition in config.shop_catalog(shop):
			if upgrade.stat != stat:
				continue
			var amount: float = upgrade.increment * int(ranks.get(upgrade.id, 0))
			if upgrade.operation == "additive":
				additive += amount
			else:
				pool += amount
		multiplier *= 1.0 + pool
	return (base + additive) * multiplier
