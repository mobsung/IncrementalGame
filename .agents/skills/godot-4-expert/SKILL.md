---
name: godot-4-expert
description: Authoritative guide for Godot 4.x game development. Enforces modern GDScript 2.0 syntax, strict static typing, component-based scene architecture, signal idioms, and CLI validation tools. Trigger whenever writing, refactoring, or reviewing Godot code, scenes, or project structure.
---

# Godot 4.x Architecture & GDScript Standard

You are an expert systems programmer specialized in Godot 4 (4.2+). Always write modular, performant, and type-safe GDScript. Never use deprecated Godot 3.x patterns.

---

## 1. Golden Architecture Rules

### "Call Down, Signal Up"
- **Downwards:** A parent node holds direct references to its children and calls their methods or updates their properties directly.
- **Upwards:** A child node must **never** call `get_parent()` or reach directly into ancestor state. Instead, define and emit a signal. The parent (or coordinating controller) connects to the signal.
- **Siblings:** Siblings must **never** talk directly to one another. Communication flows through their common parent via signals and method calls, or via a shared event-bus autoload.

### Component-Based Design
- Favor node composition over deep inheritance hierarchies.
- Implement reusable mechanics as isolated child nodes:
  - Examples: `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `VelocityComponent`.
- Keep top-level character controllers thin: delegate calculations and health handling to their respective component nodes.

### Scene Organization & Paths
- Do not hardcode deep node paths like `get_node("UI/Margin/HBox/Button")`.
- Use `%UniqueNodeName` for vital internal elements within the scene boundary, or cache direct references using `@onready var button: Button = $Margin/Button`.
- Keep scene responsibilities bounded: if a scene exceeds ~300 lines of script or handles UI, combat, and movement simultaneously, split it into sub-scenes or specialized components.

---

## 2. GDScript 2.0 Syntax Standards

### Strict Static Typing
Every variable, constant, export, and function signature **must** have an explicit type annotation.

```gdscript
# Correct
var health: int = 100
var move_direction: Vector2 = Vector2.ZERO
const MAX_SPEED: float = 450.0

func apply_damage(amount: int, source: Node2D) -> bool:
    if amount <= 0:
        return false
    health = maxi(0, health - amount)
    return health == 0