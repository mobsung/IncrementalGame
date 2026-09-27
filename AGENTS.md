# Godot development assistant

## Session continuity

At the beginning of each development session:
1. Read this file and `PROJECT_CONTEXT.md`.
2. Inspect relevant implementation files and project documentation.
3. Select the smallest relevant set of installed Godot skills.
4. Use the existing Godot AI MCP for editor, scene, node, API, or validation needs.
5. Use Graphify when dependency analysis would materially improve the task.
6. Follow the actual installed Godot version and existing architecture.

After significant development, update `PROJECT_CONTEXT.md` with implemented systems, important architectural decisions, progress, and unresolved issues. Correct stale information. Preserve useful existing context; never invent completed work or testing.

## Version and setup boundaries

- Verified engine: **Godot 4.7.stable.official.5b4e0cb0f** (2026-09-26). Recheck the executable or MCP editor state if the environment changes; `project.godot` alone does not prove the installed version.
- Never upgrade Godot or change project settings merely to satisfy a skill. The installed engine takes precedence over skill examples. Verify uncertain APIs using the engine's class API through MCP or version-appropriate official documentation.
- Preserve the existing Godot AI MCP configuration and `addons/godot_ai`. Do not replace, reinstall, or add a competing Godot server for assistant setup.
- Do not change gameplay scripts, scenes, resources, or settings solely to install tooling.

## Project and design authority

- Inspect existing systems before editing; extend them instead of duplicating functionality.
- Follow existing naming, directories, and architecture. Prefer practical typing, clear names, supported APIs, reusable scenes/resources/components, and appropriate signals and autoloads. Avoid premature abstraction.
- Prefer composition and signal-based upward communication. Use direct child references appropriately. Follow existing style unless there is a concrete reason to change it; generic skill style rules do not justify unrelated renaming or refactoring.
- `docs/design/00_INDICE.md` is the current design entry point. Read relevant linked topics and dependencies. `CORE_DESIGN.md` is historical and should not be synchronized with the newer documents.
- The old gameplay implementation was reset at the user's request on 2026-09-26. The user subsequently authorized staged development; the first combat milestone now exists. Read PROJECT_CONTEXT.md and docs/implementation/PRIMA_TAPPA.md for implemented scope and limitations. Distinguish implementation, agreed design, proposals, and open questions.
- Preserve the documented design workflow: summarize relevant decisions before proposing changes and obtain the user's confirmation before changing gameplay rules. Implementation of the agreed first milestone is authorized; unfinished design topics remain open.
- Player-facing text, character names, and ability names are English; working design documents may be Italian.

## Skills: route first, load selectively

- Godot Game Dev Studio is installed as `godot-game-dev-studio@personal` (188 distinct skills). For broad work use `studio-router`; consult `C:/Users/marce/plugins/godot-game-dev-studio/SKILL_CATALOG.md` or `skills_index.json`, then read only selected `skills/<name>/SKILL.md` and necessary references.
- For narrow tasks select the specialist directly: architecture, GDScript, combat, inventory, quests/dialogue, AI/navigation, physics/animation, game feel, performance, debugging/testing, scenes/resources, or save/load.
- Navigation uses `godot-navigation-pathfinding`. Treat upstream `godot-ai-navigation` references as an alias: its overlapping content was retained outside skill discovery to avoid duplicate registration.
- Focused `godot` skill: `C:/Users/marce/.agents/skills/godot/SKILL.md`. Use for detailed GDScript style, syntax, and architecture references when useful.
- Existing `.agents/skills/godot-4-expert/SKILL.md` remains intact. Avoid repeatedly loading overlapping general guidance. The focused skill adds reference material; Studio supplies domain depth.
- Skills provide guidance, not proof of API correctness. Project instructions and explicit user requirements take precedence, including response format, practical typing, and preservation of existing style.
- Manual requests may name `$godot`, `$godot-4-expert`, `$studio-router`, or a Studio specialist. If duplicate names appear, select the Studio plugin's qualified entry. A missing live catalog entry can be read at its documented local path.

## Tool responsibilities and workflow

For substantial development: read context, select skills, inspect implementation, use Graphify if useful, inspect relevant scenes/nodes with MCP, plan, implement, validate with Godot, investigate errors/warnings, and update documentation. Simple edits do not require every integration.

- **Godot AI MCP:** editor/scene/node/script inspection, project operations, scene creation/editing, installed API inspection, logs, and available validation/testing. Discover actual tool schemas; do not invent tool names. Check `session_manage(op="list")` and `editor_state` before targeting an editor; target this project's session when multiple editors exist.
- **Skills:** GDScript conventions, architecture, mechanics/design, signals/resources, physics, animation, optimization, and debugging strategy.
- **Graphify:** static dependency exploration, impact analysis, and navigation. Its graph is a navigation aid, not an authoritative Godot scene/runtime model.
- Validate modified scripts/scenes with the installed Godot and available MCP tools. Investigate warnings/errors, distinguish pre-existing issues, and report precisely what ran. Never claim tests or playtests that did not occur.
- Prioritize responsive gameplay, consistent game feel, reliable mechanics and save/load, maintainable reusable systems, performance, and avoiding regressions.

## Graphify CLI integration

Installed Godot fork: `C:/Users/marce/.local/share/graphify-godot`, version `0.5.0+godot1`. Use its isolated interpreter, not a generic `graphify` or PyPI fallback:

```powershell
$graphifyPython = 'C:\Users\marce\.local\share\graphify-godot\.venv\Scripts\python.exe'
& $graphifyPython -m graphify update .
& $graphifyPython -m graphify query '<existing system or file>' --budget 1500
& $graphifyPython -m graphify explain <existing_scene.tscn>
& $graphifyPython -m graphify path <existing_scene.tscn> <existing_script.gd>
```

The old graph was removed during the implementation reset. New gameplay files now exist; create a fresh index when dependency analysis is useful. Replace command placeholders with actual files. Run from the project root. Refresh before relying on a graph after relevant source changes. Outputs are local `graphify-out/graph.json`, `GRAPH_REPORT.md`, and `graph.html`; caches/indexes are ignored by Git. `.graphifyignore` excludes addons, editor caches, tooling, and assets while retaining project scripts/scenes/resources. Do not commit indexes or add an MCP server/hook just for Graphify. No Graphify skill is required for this CLI workflow.

Limitations: `.tscn`/`.tres` use regex extraction; dynamic resource loads, UID-only references, runtime-generated nodes, detailed subresource ownership, and cross-file signal wiring are incomplete. Cross-file calls are inferred by labels and can point to the wrong same-named function. Shaders are unsupported. Confirm graph findings in code and the editor. The CLI indexes code, not semantic design documents; read design documents directly.
