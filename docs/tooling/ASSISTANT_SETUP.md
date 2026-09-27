# Godot assistant setup report

Verified 2026-09-26 during setup. Historical report: the user subsequently requested a complete gameplay reset. The indexed prototype files and graph described below were removed; see PROJECT_CONTEXT.md for the current empty implementation. Tool installations remain in place.

## Environment and preservation

- Godot executable: `C:/Users/marce/OneDrive/Desktop/Godot/Godot_v4.7-stable_win64.exe`; `--version` returned `4.7.stable.official.5b4e0cb0f`. Live editor independently reported 4.7-stable (official).
- Windows, PowerShell, Codex desktop package `26.924.2738.0`; bundled CLI `0.158.0-alpha.2.1`. Project is the existing IncrementalGame checkout.
- No pre-existing root/ancestor AGENTS.md or root PROJECT_CONTEXT.md was found. Existing project skill and design documentation were preserved. `docs/` was already untracked before setup; no existing design files were changed.
- Existing Godot AI plugin/server `4.2.3`, configured with Python 3.13 / uvx attach, HTTP 8000 and WebSocket 9500, remains installed and configured.
- Codex's installer added only the Studio plugin enable stanza to `C:/Users/marce/.codex/config.toml`. Removing that exact new stanza from the current bytes reproduces the original SHA-256 `4DE44EBDC680457EDD0E71FCE4DC121262C47230B1F6BA91FE54A28831A7F151`. Thus all prior configuration, including MCP, was preserved byte-for-byte.
- No engine upgrade, new Godot MCP server, Graphify MCP server, hooks, gameplay changes, scene/resource changes, or project settings changes were made.

## Skills and locations

| Component | Installed location and status |
| --- | --- |
| Studio plugin source | `C:/Users/marce/plugins/godot-game-dev-studio` |
| Personal marketplace | `C:/Users/marce/.agents/plugins/marketplace.json` |
| Active Studio cache | `C:/Users/marce/.codex/plugins/cache/personal/godot-game-dev-studio/0.2.0+codex.20260926154320` |
| Focused Godot skill | `C:/Users/marce/.agents/skills/godot/SKILL.md` with four reference documents |
| Existing project expert | `.agents/skills/godot-4-expert/SKILL.md`, unchanged |
| System skills | `C:/Users/marce/.codex/skills/.system` |
| Existing plugin skills | `C:/Users/marce/.codex/plugins/cache/{openai-bundled,openai-curated-remote,openai-primary-runtime}/.../skills` |

The complete pre-existing filesystem skill inventory is in [SKILL_INVENTORY.md](SKILL_INVENTORY.md). Available chat skills and cached files are distinct; some cached template skills were not exposed in this session.

### Studio

Source: https://github.com/bgrenat/godot-game-dev-studio, commit `9e2b2beaf0bc7ba2e27a40326d058ff2c7a619a9`, upstream 0.2.0. Repository README and compatibility guidance target Godot 4.7+, matching the actual engine. Last repository push observed: 2026-07-29; not archived.

Installed through the documented `codex plugin add godot-game-dev-studio@personal` method using the standard personal-marketplace helper. Plugin validation passed, and CLI listing confirmed installed/enabled status. All headers were checked; the final installation has **188 distinct discoverable skills** from the upstream collection of 189 folders.

Upstream `godot-ai-navigation` and `godot-navigation-pathfinding` declared the same name. The latter includes expanded navigation architectures. Retained it as canonical; moved the overlapping shorter copy to `reference-only/godot-ai-navigation/REFERENCE.md` in the plugin source, preserving supporting material and attribution. Router/catalog/index use the canonical name. Other upstream references to the older folder name should be interpreted as this alias. A local version suffix ensures the corrected cache is loaded.

No skill was excluded for engine-version incompatibility. The collection supplies architecture/GDScript, game design, combat, inventory, quests/dialogue, AI/navigation, physics/animation, game feel, optimization, testing/debugging, and reusable scene/resource systems. Examples were not exhaustively compiled; installed engine APIs and project instructions remain authoritative.

### Focused Godot skill

Source: https://github.com/shihabshahrier/Godot-Skill, inspected commit `c8bc20f876a8da241274d48461444fab86182d83`. README and skill target Godot 4.3+, compatible with 4.7. Last push observed: 2026-09-09; not archived. Installed using Codex's GitHub skill installer into the repository's documented Codex user-skill directory.

The upstream `when_to_use` frontmatter field was moved under `metadata` because Codex's skill validator rejects it at top level. Guidance and references are unchanged; validation then passed. No repository hooks or configuration were copied.

There is conceptual overlap with the existing expert and Studio. The focused skill adds four dedicated style/syntax/architecture/common-system references; it has a unique `godot` name and installation path. Keep existing expert instructions, load overlapping general guidance selectively, and prefer domain specialists for complex systems. No existing skill was overwritten.

## Graphify

Source: https://github.com/hidalgob/graphify-godot, commit `cd3d27cc5b201e1135dbc8d62db0704e4040b66b`, package `graphifyy==0.5.0+godot1`.

- Repository accessible, not archived, last push observed 2026-04-24, one open issue. It is a personal fork with limited recent maintenance, not a guarantee of ongoing support. README mentions an older upstream base; installed package version above comes from pyproject metadata.
- README documents Python 3.10–3.13 and prior testing with Godot 4.6. It does not declare a strict minimum engine version. Actual extraction on this 4.7 project was verified.
- Real `.gd` tree-sitter extractor and `.tscn`/`.tres` regex extractors inspected. Native CLI, Codex skill installation, optional hooks, and optional MCP are available.
- Installed at `C:/Users/marce/.local/share/graphify-godot`, using the documented editable installation in an isolated Python 3.13.1 virtual environment: `uv pip install --python <venv>/Scripts/python.exe -e <fork>`. Windows system certificate trust was required for package download. No global Graphify replacement or upstream substitute was installed.
- Selected **CLI integration**. Did not install its generic Codex skill because that workflow includes a standard-PyPI fallback and assumptions unnecessary here. Did not invoke its AGENTS/hook installer or add MCP. Instructions in the project point explicitly to the tested fork interpreter.
- Environment includes tree-sitter 0.26.0, tree-sitter-language-pack 1.20.0, and networkx 3.7. PyYAML 6.0.3 was added only for skill/plugin validation.

### Verification results

`python -m graphify update .` indexed **71 files: 14 .gd, 9 .tscn, 48 .tres**. Direct per-file extraction also reported zero errors. `CounterModel` alone yielded 39 nodes and 88 edges. Final graph: **241 nodes, 479 edges**:

| Relationship | Count |
| --- | ---: |
| imports_from | 74 |
| instances | 3 |
| calls | 185 |
| aliases | 11 |
| inherits | 14 |
| contains | 153 |
| emits | 39 |

Verified queries:

- `explain game.tscn`: imports game.gd and floating_text_manager.gd; instances CurrencyLabel, prestige_modal, and evolution_modal scenes.
- `explain mana_wisp.tres`: imports creature_definition.gd.
- `query "counter_model.gd evolution upgrade" --budget 1200`: located production/model, upgrade controls/definition, evolution modal, and related methods.
- `path game.tscn evolution_modal.gd`: two extracted hops through evolution_modal.tscn.

Generated graph JSON, HTML, Markdown report, and extraction caches stay in ignored `graphify-out/`. `.graphifyignore` filters addons, editor/tool caches, and art. Git ignore behavior was checked. No LLM service was used for indexing.

### Limitations

- Dynamic `load(path)` in GlobalData is not resolved; resource registry/evolution ID relationships require direct inspection.
- Cross-file signal connections and runtime scene changes are incomplete. There were no `connected_to` edges despite actual signal wiring in the project.
- Regex scenes/resources do not model all node ownership, subresources, UID-only paths, or engine semantics; shaders are unsupported.
- Inferred cross-file calls can choose the wrong same-named function. Example: buyUpgrade's get_upgrade_cost may be associated with CurrencyManager instead of CounterModel. Verify in source.
- The report showed 8 communities while CLI output reported 9, so community counts are not treated as verified architecture facts. Dependency queries and file/edge counts above were checked independently.
- CLI update handles code extraction, not semantic analysis of design documents. Read those documents directly. Refresh after relevant code changes; no background watcher was installed.

## MCP verification

Authenticated read-only requests through the existing endpoint successfully initialized Godot AI 4.2.3, listed tools/sessions, read `editor_state`, read `scene_get_hierarchy`, and read the editor log. Session matched this project; editor was ready/stopped; CounterComponent hierarchy returned six nodes at depth two; editor log had no entries.

Initial generic HTTP probes failed because the endpoint requires the existing capability authentication and handles empty notification responses specially. Using the installed client's capability loader and correct HTTP handling succeeded without changing server configuration or credentials. No credentials were printed or copied into project files.

Native Godot tools were not available in this chat's tool catalog. Backend/editor functionality is verified; pickup in a fresh Codex chat remains to be checked there. No gameplay run, scene save, or full game validation was performed because this setup changed no gameplay.

## Continuity and usage

`AGENTS.md` establishes version precedence, selective skill routing, tool roles, project/design authority, validation honesty, and context upkeep. `PROJECT_CONTEXT.md` maps actual systems and separates current implementation from the newer agreed design.

Open a **new Codex chat in this same project** to load the new plugin skills and root instructions. A full app restart is not normally needed; if the catalog remains stale, restart Codex. Standalone focused skills are available on the next turn; a fresh chat is the reliable boundary for the plugin refresh.

Suggested opening prompt: “Read AGENTS.md and PROJECT_CONTEXT.md, then use the relevant installed Godot skills and existing MCP for this task: …”

Manual skill requests: `$godot`, `$godot-4-expert`, `$studio-router`, or a named specialist. Automatic selection uses skill descriptions plus the project routing instructions; only selected skill bodies/references should be loaded. For Graphify say “Use Graphify to inspect dependencies of …”, or run the PowerShell commands in AGENTS.md.

Attention: user-scoped installations live on this machine; project docs alone do not install them on another computer. Reapply the documented local compatibility adaptations after an upstream skill update. The current setup does not establish gameplay correctness or save/load durability.
