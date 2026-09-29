# Project context

Ultimo aggiornamento: 2026-09-29, animazioni sprite-sheet dello Spaghetti Golem.

## Sprite sheet Spaghetti Golem — 2026-09-29 (sostituisce il pass procedurale sotto)

- Richiesta esplicita dell'utente: animazioni dettagliate a sprite sheet per movimento, attacchi e abilità. Nove PNG trasparenti 1254×1254, 144 pose sorgente, in content/units/warriors/spaghetti_golem/visuals/spritesheets/. Generati con il tool immagini integrato dalle tre illustrazioni esistenti; prompt completi in spritesheets/ART_NOTES.md.
- Tre risorse *_sheet.tres collegate ai visual delle forme. sprite_sheet_motion.gd costruisce SpriteFrames/AtlasTexture condivisi; sprite_sheet_player.gd seleziona fotogrammi per copia, senza deformazioni. Per forma: idle 4, camminata 8, Jab 8, Sweep 8, morte 4; hit riusa una posa. Simmer 16/8/4, Guard 8/4 nelle forme abilitate, Surge 8 nella finale. Ritratti originali invariati. Vecchi golem_motion*.gd non più referenziati dai visual, conservati come codice storico.
- Separazioni delle celle adattate alle pose estese/gutter irregolari; canvas virtuali uniformi e coordinate arrotondate ai pixel. Tempi impatto/cast guidati dalla simulazione, pausa e identità per copia preservate. Simmer attende un intervallo visivo libero; azioni e movimento hanno precedenza e possono interrompere la coda degli effetti. Nessuna modifica a gameplay, inventario, RNG o salvataggi.
- Godot AI su 4.7.stable.official.5b4e0cb0f, sessione incrementalgame@3d07ce54918ca992: runtime_test_runner.tscn, **434 controlli, zero fallimenti**, log gioco/editor correnti senza errori/warning. Verificate bounds/alpha atlas, canvas, pause, Jab/Sweep e Guard, stato indipendente, integrazione UI. Ispezionati screenshot preview (camminata, Jab, Surge) e breve smoke test di battaglia con persist_progress=false. Nessun caricamento/scrittura del profilo reale. git diff --check senza errori di whitespace (solo avviso CRLF preesistente su first_arena.tres).
- Preview isolata visuals/animations/preview.tscn: F6, Space pausa, frecce stato. Limiti: variazioni residue di volume/appoggio tra fotogrammi generati, nessuna pulizia manuale pixel-perfect, audio o benchmark esteso. Mappatura e dettagli in animations/README.md.

## Storico animazioni procedurali Spaghetti Golem — 2026-09-28

- Tre forme animate con soft mesh degli sprite esistenti: idle/gocce, camminata, Jab, Sweep, Simmer, Guard, Surge, danno e collasso. Configurazione e player in content/units/warriors/spaghetti_golem/visuals/animations/, collegati dalle tre risorse visuali. Si tratta di animazione procedurale, non nuovi fotogrammi disegnati né rig con arti separati.
- ArenaView gestisce un player visivo indipendente per copia, pulizia/cambio forma e pausa; la simulazione conserva autorità su tempi/danni. Eventi hit/heal arricchiti con target ID e tipo di cura; evento death solo visivo. Nessuna regola, RNG o schema di salvataggio modificato. Breve eco di morte completa il collasso anche dopo rollback immediato.
- Preview isolata in visuals/animations/preview.tscn: F6, Space pausa, frecce cambiano stato. Non carica né salva il profilo reale. Dettagli/limiti nel README della stessa cartella.
- Verificato tramite Godot AI su 4.7.stable.official.5b4e0cb0f (sessione incrementalgame@3e6a8fda3f7b6551): **246 controlli, zero fallimenti**, log correnti gioco/editor senza errori. Include rig delle tre forme, geometria finita, pausa, timing Jab e acquisti a metà ciclo, isolamento del modello/RNG, routing eventi, riuso ID e completamento/pulizia eco di morte. Preview delle forme eseguita e ispezionata. Nessun accesso al salvataggio reale in questa tappa; nessun benchmark esteso.

## Stato corrente Spaghetti Golem (prevale sulle note storiche John/v7 sotto)

- John è sostituito da Spaghetti Golem, Rare Warrior: Noodle Squire base, Saucebound Knight livello 10, Spaghetti Golem livello 25. Evoluzioni manuali con conferma, nessun aumento delle statistiche base; rimborso/reset dei punti livello, conservazione livello/XP/Gold individuale come da regola generale concordata.
- Kit completo: Meatball Jab/Sweep, Slow Simmer, Sauce Reserve, Sauce Guard, Glassheart Surge. Quattro potenziamenti con cap per stadio, bonus personali limitati, effetti/timer indipendenti per copia e persistenti. Dettagli: docs/implementation/SPAGHETTI_GOLEM.md.
- Risorse specifiche in content/units/warriors/spaghetti_golem/{forms,abilities,upgrades,visuals,gacha,concepts,design}. Nemici e Dice Summoner organizzati per entità. Tre nuovi sprite trasparenti dalle schede dell'utente; provenance in visuals/ART_NOTES.md. Vecchie risorse John storiche, non collegate al gameplay.
- Pool gacha attivo: solo Rare Spaghetti Golem, evocato base livello 1, costo 5 Dust. Pesi sulle rarità presenti rinormalizzati. Restano fino a tre alleati schierati, acquisti condivisi e Multi Hit/Cast.
- Salvataggio v8. Reset pre-v8 autorizzato: una base, rimozione copie e progressi individuali/tentativo provvisorio; conservazione valute, acquisti globali/Chrono e record. Verificato profilo reale: una copia starter_spaghetti_0001, livello 1, XP 0, evoluzione 0; Gold 3040.025, Dust 45, Shards 0.630000000000003 invariati. Preparazione, nessun combattimento automatico. Salvataggio v8 scritto e verificato.
- Backup indipendente precedente: user://first_demo.before_spaghetti_v8.save. Non sovrascriverlo. I successivi salvataggi v8 non ripetono il reset.
- Godot AI, sessione incrementalgame@eefae985ebbe52a5: suite corrente tests/run_spaghetti_tests.gd tramite runtime_test_runner.tscn, **194 controlli, zero fallimenti**. Copre azioni, cure letali simultanee, buff/cooldown minimi, evoluzioni, snapshot indipendenti, caricamento deterministico, migrazione v7, gacha e UI. Vecchia suite archiviata in tests/legacy/john_v7.gd.txt: non eseguirla come suite corrente. Avvio main senza errori correnti, screenshot controllato del profilo base. Non è un benchmark o test di bilanciamento esteso.
- Restano aperti evoluzioni ramificate, sistema status generico, supporti nemici, ulteriori specie, rifinitura artistica delle animazioni/audio e offline.

## Current state and authority

- Project: incrementalGame. Installed engine **Godot 4.7.stable.official.5b4e0cb0f**, verified with the console executable and Godot AI editor.
- The user requested a complete reset on 2026-09-26, then authorized staged implementation. New gameplay now exists. Do not restore the old prototype.
- Main scene: res://scenes/main.tscn. F5 starts the playable demo.
- Current design: docs/design/00_INDICE.md. CORE_DESIGN.md is historical. Implementation details are in docs/implementation/, including GACHA_E_COLLEZIONE.md for the latest stage.
- Confirm changes to gameplay rules with the user. Configurable initial Gold costs/increments/limits are authorized by 07_ECONOMIA_E_POTENZIAMENTI.md. Player-facing text is English; working documents may be Italian.

## Historical baseline before the Spaghetti Golem replacement

- One owned John the Meatball (Common Warrior) nel profilo reale; il gacha può aggiungere copie indipendenti e il modello supporta fino a tre copie alleate schierate in nove slot univoci. Il campo usa fieldconcept.jpeg, personaggi illustrati interi in vista laterale e proiezione compressa della profondità.
- Bottom navigation: Battle controls, Collection & squad, Chrono, Global shop. Il roster mostra ogni copia e apre Stats & formation / Upgrades per quella selezionata. Global and Chrono shops support real purchases. Close, repeated navigation click and Escape dismiss panels.
- Meatball Punch, Spaghetti Sweep e Hearty Rhythm; catena critica normale/super/ultra. Movimento, zona d'ingaggio, priorità, posture e rientri esistenti preservati.
- Balanced, offensive and special enemies with configurable initial stats. Twelve ordinary appearances, six of each type, no four identical consecutive types; offensive appearances spawn three enemies. Special every tenth wave at 11 seconds.
- Fixed-step combat, simultaneous damage/healing, defeat priority on simultaneous last deaths, attempt snapshots, XP blocking, provisional rewards, wave access floor, pause/auto controls, soul thresholds producing Dust, Chrono break.
- Cataloghi Gold individuale e globale completi nelle voci previste: **19 acquisti ciascuno**. Ultime aggiunte: Magic Attack individuale, Magic Resistance, Ability Power e sei statistiche critiche; AP globale ha bonus additivo e moltiplicativo. Sei potenziamenti di John a punti livello e sei acquisti Chrono precedenti. Parametri configurabili, bilanciamento iniziale. Dettagli: docs/implementation/DANNO_E_CRITICI.md.
- Danno fisico/magico/misto, mitigazione separata, AP compatibile per azione, chance critiche condizionate e limitate al 100%. John e i nemici attuali restano fisici; danno magico verificato con contenuto sintetico isolato.
- Risultati di squadra: la sconfitta avviene solo quando tutte le copie schierate sono morte; ogni copia schierata riceve l'intero XP idoneo anche se caduta; i contributi Gold/XP/Souls si sommano. Snapshot, ripristino dopo sconfitta e Chrono coprono l'intera formazione.
- Gacha Resource-driven: costo iniziale 5 Dust, pesi rarità 55/30/12/3, pool attuale limitato a Common John. Le nuove copie partono al livello base in riserva e possono essere schierate dalla collezione. RNG separato dal combattimento.
- Multi Hit e Multi Cast runtime: compatibilità dichiarata per azione, retarget fra colpi, critici indipendenti, passiva una volta per ciclo e applicazioni ordinate della Sweep con geometria/cooldown condivisi. L'acquisto Chrono resta in attesa dei costi di design.
- Salvataggio **v7**, backup e migrazioni dalle versioni 1, 2, 3, 4, 5 e 6. Offline predisposto ma inattivo.

## Shared architecture (historical John-specific details superseded above)

- Shared typed Resource definitions in scripts/data/ and resources/ are immutable during gameplay.
- UnitProgress holds independent copy identity, XP/level/points, purchase ranks, deployment and formation preferences. PlayerProfile owns copies, permanent balances, global_ranks and chrono_ranks and resolves stable copy IDs. StatUpgradeDefinition supplies shared stat/cost data; GoldUpgradeDefinition inherits it for existing individual resources. ShopModifiers applies additions before separate global/Chrono percentage pools. SharedShopPanel renders both catalogs and requests model transactions.
- CombatantState holds transient combat state and `copy_id` for owned actors. UnitStats rebuilds each copy from its species definition and owned ranks without accumulating bonuses or mutating definitions.
- DamageDefinition dichiara coefficienti fisico/magico, rapporto AP, idoneità critica e compatibilità Multi Hit; SweepDefinition la estende con tempi/geometria e compatibilità Multi Cast. CombatMath cattura la potenza alla creazione e applica le difese all'impatto. La simulazione continua a supportare una sola abilità Sweep per combattente; il sistema generico di effetti resta da sviluppare.
- BattleSimulation coordinates summon, deployment, copy-specific transactions, attempts, team outcomes and serialization. CombatSystem resolves posture and targeting preferences through the actor's copy mapping; Targeting and CombatMath remain independent of scenes.
- DemoController connects model, persistence and UI. ArenaView draws/selects; reusable UpgradePanel displays Resource catalogs and requests model transactions. No gameplay Autoload.
- FieldProjection provides an invertible logical-to-ground mapping. ArenaView draws depth-sorted sprites, ground shadows, projected ranges/sectors and formation markers, with matching click coordinates. CombatantVisual Resources configure texture, height and facing independently from combat stats. NavigationPanels controls page visibility; opening a panel does not pause simulation.
- Main scene can disable persistence with persist_progress=false for isolated UI tests. Default gameplay preserves normal saving. The UI tests neither load nor overwrite the player's save.
- Fixed step 1/60 second; seed/state di combattimento e gacha salvati separatamente. Determinism tested with the same engine/content. advance(seconds) and the save timestamp prepare for future offline processing; policy and efficient calculation remain open.
- La collezione supporta tutte le copie possedute e fino a tre copie alleate schierate. Il pool attuale contiene solo John; il lato supporto nemico non è incluso finché non esistono contenuti autorizzati per quel ruolo.

## Persistence history

- File user://first_demo.save, separate from old prototype saves. Save after model changes, every 10 seconds and normal window close.
- Formato v7 Variant senza oggetti, SHA-256, file temporaneo e backup. Validazione di struttura/tipi/intervalli, ripetizioni, ID di copia/attore, seriale di collezione, limite e unicità degli slot. La migrazione v6 aggiunge Multi Hit/Multi Cast; la v5 aggiunge seriale e RNG del gacha; la v4 aggiunge schieramento, identità copia-attore e snapshot multiplo. La migrazione v3 aggiunge i nove valori di danno/difesa/critici. Versioni future bloccate; file invalidi preservati.
- Migration v2 initializes empty shared shop rank dictionaries, preserving balances, individual purchases and the attempt. Reward purchases affect subsequent kills; pending rewards are never repriced. All fractions remain intact.
- Migration v1 inserts missing upgrade_ranks and gold_ranks dictionaries while preserving the full attempt. Intermediate existing rank dictionaries are retained and validated.
- Corrected the interrupted upgrade changes: invalid typed Resource array, load/purchase healing or resetting John, missing Wide Sweep effect, amplifiers affecting base stats, and hidden metadata losing effects.
- Health increases preserve current absolute health; reductions clamp it; never resurrect through purchases. Defeat restores snapshot health/timers and reapplies current permanent upgrades.
- Quick Stir preserves cooldown captured by a running cast. Reinforced Glass/Strong Noodles amplify only individual Gold increments, retroactively and for future purchases.
- Haste è ricostruita dai gradi. Quick Stir precede il fattore 100/(100+Haste); cooldown catturati preservati. Attack Speed vale dal ciclo successivo; Range non amplia l'ingaggio e Area aumenta la superficie tramite radice quadrata. Questa tappa manteneva v3; il danno comune successivo ha introdotto v4.

## Validation

- Riorganizzazione per specie: runner tests/runtime_test_runner.tscn avviato tramite Godot AI dopo scansione filesystem: **487 controlli, zero fallimenti**, log editor senza errori. Il runner usa profili isolati. Verifica dei nuovi percorsi delle risorse effettuata; nessuna evoluzione testata o implementata in questa tappa.

- Multi Hit e Multi Cast: **487 controlli, zero fallimenti** su Godot 4.7.stable.official.5b4e0cb0f. Verificati retarget, colpi persi, passiva per ciclo, critici indipendenti, applicazioni Sweep ordinate, compatibilità esplicita, simultaneità globale, ricostruzione, UI, roundtrip v7 e migrazione v6. Suite Godot AI isolata. La scena reale trovata aperta era già in preparation; è stata fermata prima dei test senza azioni o acquisti.

- Gacha e collezione: **474 controlli, zero fallimenti** su Godot 4.7.stable.official.5b4e0cb0f. Verificati pool con il solo Common John, costo 5 Dust, rifiuto atomico, ID stabili, copie indipendenti, riserva e schieramento UI, isolamento RNG, roundtrip v6 e migrazione v5. Suite e scena UI eseguite tramite Godot AI su profili isolati; log successivi puliti. Il profilo reale non è stato caricato né scritto.

- Fondazione multi-copia: **455 controlli, zero fallimenti** su Godot 4.7.stable.official.5b4e0cb0f. Verificati limite di tre alleati, slot univoci, almeno una copia, blocco della composizione durante la battaglia, identità copia-attore, sconfitta collettiva, snapshot/ripristino multiplo, XP intero ai caduti, contributi cumulativi, Chrono, roundtrip v5, migrazioni v1-v4 e ripresa deterministica.
- La suite completa può essere avviata anche tramite `res://tests/runtime_test_runner.tscn` usando Godot AI; serve quando l'eseguibile console separato presenta il crash nativo osservato nell'ambiente corrente prima del caricamento anche con un progetto minimo. Avvio scena principale e albero runtime verificati senza errori della nuova esecuzione.
- Il profilo reale è stato soltanto ispezionato: una copia posseduta/schierata e un attore alleato, formato runtime v5. Nessun acquisto di prova. Il processo di gioco è stato arrestato; la scrittura forzata di una pausa sul salvataggio reale non è stata eseguita.

- Ultima tappa danno: **435 controlli, zero fallimenti** su Godot 4.7.stable.official.5b4e0cb0f; baseline 351/0. Danno misto, difese negative, AP, critici condizionati e per bersaglio, acquisti, cap, migrazioni v1/v2/v3, snapshot e ripresa deterministica verificati. Dettagli in docs/implementation/DANNO_E_CRITICI.md.
- Avvio MCP dopo scansione senza errori correnti; log editor successivi al cursore 24 puliti. Errori transitori della nuova classe durante scritture parziali risolti. Scheda ispezionata a schermo e pulsanti provati su scena isolata senza persistenza, poi rimossa. Profilo reale migrato e riletto in v4: pausa, Gold 451,525000000006, HP 1152, nessuna spesa di prova.

- Ultima tappa economica: **351 controlli, zero fallimenti** su Godot 4.7.stable.official.5b4e0cb0f; baseline 304/0. Contributi individuali combinati con shop condivisi, acquisti a metà ondata, morte simultanea, blocco XP, Dust frazionario, isolamento copie, salvataggio v3 e ripresa deterministica verificati. Nessuna modifica allo schema: i gradi restano in UnitProgress; UnitStats deriva i contributi e BattleSimulation usa ShopModifiers per i pool.
- Avvio tramite Godot AI e log correnti senza nuovi errori. Pulsanti dei tre acquisti e statistiche verificati in scena temporanea con persistenza disabilitata; nessuna spesa sul profilo reale. La battaglia reale caricata è arrivata alla pausa prenotata: ondata 5, record 4, Gold 451,525000000006, HP 1152. Salvataggio su disco verificato in pausa con lo stesso Gold. I valori sotto documentano verifiche precedenti.

- Latest combat-stat stage: **304 checks, 0 failures** on installed Godot 4.7. New coverage includes individual/shared stat stacking, unchanged health/actions, next-cycle speed, actual range and Sweep area, Quick Stir/Haste ordering, mid-cast purchases, reconstructed stats and Chrono persistence. Main scene launched through Godot AI without current-run errors; updated stats panel visually checked at 1920×1080.
- After the blackout the correct editor reconnected as incrementalgame@7c604b992a63482c. The user's newer save loaded successfully and resumed an active battle (Gold 117, Shards 0.81 at observation); it was allowed to reach an attempt boundary with pause queued. No test purchases were made against that profile. Earlier paused-profile figures below refer to earlier verification stages.

- Latest shop stage: **282 checks, 0 failures** on installed Godot 4.7. Includes independent currencies, rejection/caps/prices, bonus pools, fractional rewards through actual kills, no healing/timer resets, persistence across defeat/Chrono, deterministic resume, v2 migration, v3 roundtrip, invalid ranks and instantiated shop button transactions. Test profiles have persistence disabled.
- Godot AI main launch and current game log were clean. Both shop panels visually inspected at 1920×1080. Existing profile loaded paused at wave 7, record 9, Gold 155, HP 309.591452257017/630, without test purchases. These checks do not establish final balance.

- 2026-09-27: **242 checks, 0 failures**, installed Godot console: --headless --path . --script res://tests/run_tests.gd. Includes the previous 225 checks plus projection roundtrips, panel navigation/tabs, no simulation mutation through navigation, projected slot/sprite clicks, Escape and sprite alpha.
- Covers sequence generation, damage/sector/timing/passive/targeting, outcomes/XP/souls/Chrono, snapshot independence, deterministic resume, file corruption/backup, migration/future version rejection, purchase costs/gates/caps, all six effects, retroactive amplification, no healing/timer resets, independent copies, and instantiated UI buttons with an isolated test profile.
- Main scene launched via Godot AI without current-run errors. Battle and upgrade panel visually inspected. Normal close/reopen preserved paused HP 43.4687469685548 and Gold 463 exactly.
- The real saved attempt resumed during runtime verification; it was then paused at an attempt boundary. No test purchases were charged to the real profile.
- Earlier base-John smoke test reached record wave 9 and failed wave 10. These are smoke tests, not complete balancing or performance benchmarks.
- Headless runs need normal Godot user-directory access; sandbox-only execution previously failed on environment access. Logs in tests/*.log are ignored.
- New field and upgrade tabs visually checked at 1920×1080 and 1280×800. Combat preview used an isolated temporary main-scene instance with persistence disabled; the real profile remained paused with its 155 Gold unchanged. Do not confuse those preview enemies with saved gameplay.
- Godot AI launch returned no current-run errors. Its screenshot endpoint produced transport failures, so screenshots were captured through the running viewport's Image.save_png and inspected locally. Captures in tests/*_preview.png are ignored.

## Pending

- Richiesta Spaghetti Golem completata; vedere lo stato corrente sopra. Conservata la regola generale di rimborso/reset punti all'evoluzione, prevalente sulla frase divergente del concept.

- Completare il catalogo Chrono, collegando gli acquisti Multi Hit/Multi Cast ora supportati dal runtime e gli slot aggiuntivi quando prezzi e requisiti saranno definiti. Cataloghi Gold individuale e globale completi nelle voci; bilanciamento da verificare.
- Aggiungere specie al gacha soltanto dopo schede approvate; restano aperte soglie di sblocco rarità e distribuzione fra specie della stessa rarità. Pesi 55/30/12/3, costo, collezione e composizione della squadra sono implementati. Fortuna resta esclusa.
- Evoluzioni ramificate, buff/status generici, supporti nemici/evocazioni, animazioni/audio. Evoluzioni lineari del Golem, buff personali, Multi Hit/Cast, danno magico e super/ultracritici sono implementati.
- Offline progress policies, limits and efficient computation; final platforms and representative performance budgets. Desktop is the current test target.

## Preserved tooling and repository state

- Contenuti specifici raccolti in content/units/<classe>/<specie>/ (forms, abilities, upgrades, visuals, concepts, design, gacha) e content/enemies/<tipo>/. Sistemi e cataloghi condivisi restano in scripts/, resources/ e scenes/. Vedere content/README.md. Spostamenti con metadati .import preservati e riferimenti aggiornati; nessuna nuova meccanica introdotta dalla riorganizzazione.

- Preserve addons/godot_ai/, enabled plugin and _mcp_game_helper autoload. MCP 4.2.3 works; latest verified session incrementalgame@10d96b9eee0fb838 is the correct project. Rediscover sessions after editor restarts; do not replace/add servers.
- Preserve AGENTS.md, .agents/skills/, design and docs/tooling/. Studio exposes 188 skills; load relevant specialists only.
- Graphify fork: C:/Users/marce/.local/share/graphify-godot. Indice locale ricostruito e consultato prima della tappa danno per dipendenze combattimento/salvataggi. Aggiornarlo prima di riutilizzarlo dopo nuove modifiche; non commettere gli output ignorati.
- Git history intact. Many old tracked files were deleted by the authorized reset and replaced by the staged implementation described above.
- Authoritative John design: user-supplied C:/Users/marce/Downloads/noodlegolem.jpeg, reaffirmed after the user rejected john_idle_v1 as too generic. Current battlefield and unit-card texture: content/units/warriors/spaghetti_golem/visuals/john_idle_v2.png, a faithful transparent adaptation of that sheet. Preserve the elongated glass torso/helmet and visible heart, spaghetti structure, dangling meatball fists and tiny wooden legs. Do not use the earlier portrait or v1 sprite to redesign him. Animation studies under docs/design/unita/references/ remain concepts.
- Current field assets: assets/battle/field_concept_v1.jpeg copied from the user's reference; john_idle_v2.png, stone_idle_v1.png, ember_idle_v1.png generated/edited with the built-in image tool. Prompts/provenance in assets/battle/ART_NOTES.md. Stone Warden currently reuses the stone sprite at a larger size. These are static sprites with slight idle bobbing, not final walk/attack animation. Implementation details in docs/implementation/CAMPO_E_NAVIGAZIONE.md.
