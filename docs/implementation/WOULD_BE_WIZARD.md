# The Would-Be Wizard — prima versione di test, 1 ottobre 2026

L'utente ha autorizzato l'implementazione completa della scheda in `assets/concepts/units/supports/The-Would-Be-Wizard`, delegando numeri/interazioni aperti, confermando una sola copia per specie in campo (anche Spaghetti Golem) e chiedendo una prima copia sul profilo reale. Le scelte sotto sono **provvisorie e modificabili**, non bilanciamento definitivo. La scheda originale resta conservata.

## Contenuto e progressione

| Forma | Evoluzione | Attacco base | Passive | Attive |
| --- | --- | --- | --- | --- |
| Reckless Apprentice | Base | Training Staff, fisico ravvicinato | Hard Lessons | Headlong Swing |
| Grimoire Acolyte | Ramo A, livello 10 | Ink Spark, proiettile magico | Margin Notes | First Remedy |
| Grimoire Archsage | Finale A, livello 30 | Living Script, proiettile magico | Living Grimoire; The Story Continues | Rewrite Wounds; Shared Margins; Final Revision |
| Makeshift Wizard | Ramo B, livello 10 | Weighted Staff, fisico ravvicinato | Sleight of Hand | Prototype Trick |
| False Archmage | Finale B, livello 30 | Loaded Staff, dardo fisico | Perfect Misdirection; Nothing Up My Sleeve | Rigged Sigil; Clockwork Familiar; Grand Illusion |

Rami permanenti per copia, scelta manuale, rimborso dei punti livello all'evoluzione; livelli/XP/acquisti Gold conservati. Le forme cambiano funzioni e portata, non statistiche base: HP 250, attacco fisico 18, magico 16, Ability Power 24, armor 6, magic resistance 8, attack speed 1, velocità 220, zona 350, critico 5%. Portate 105/230/270/120/260; proiettili 700 unità/s, danno catturato al lancio e difese all'impatto. Multi Hit genera packet distinti, una sola generazione di risorsa per ciclo base.

Gacha: Rare, stesso peso del Golem nel pool Rare corrente, quindi 50/50 fra le due specie; costo 5 Dust. Copie indipendenti, base, in riserva. Pesi delle rarità e sblocchi esistenti conservati. Una copia iniziale gratuita assegnata una volta con `profile.content_grants.wizard_first_copy`, senza schierarla automaticamente.

Tre potenziamenti di livello specifici, cinque gradi ai livelli 1/5/10/20/30, un punto per grado: Wizard Mastery (+12% potenza attive), Staff Training (+10% coefficiente base), Robe Tempering (+10% amplificazione Gold HP/armor). I cataloghi Gold/global/Chrono restano comuni; i potenziamenti del Golem non si applicano al Wizard.

## Regole provvisorie del kit

Tuning condiviso in `content/units/supports/would_be_wizard/abilities/tuning.tres` (valori esportati dal relativo script). Tempi, portate e descrizioni delle singole attive nelle loro risorse `.tres`.

- Hard Lessons: una carica ogni quattro cicli base, cap 10; Swing settore 120°, raggio 145, 1,3× fisico, carica +50%. Passo fisico massimo 30 soltanto Mobile. Cast 0,6 s, cooldown 6 s.
- Margin Notes: un Note per ciclo base, cap 10; Remedy consuma fino a tre Note, cura `(22 + 1,2×AP) × (1 + 0,15×Note)` prima dei potenziamenti, lascia annotazione reattiva se ha speso Note. Cast 0,65 s, cooldown 5 s.
- Living Grimoire: un Note per ciclo, due ogni terzo ciclo; uno per attivazione con cura primaria utile e per attivazione utile di Written Recovery. A 10 Note la successiva attiva consuma tutte le Note e si potenzia: cure ×1,5 e budget recovery maggiore, link da 6 a 9 s oppure finestra Revision da 4 a 6 s. Echo non genera Note.
- Rewrite Wounds: stessa cura di base, Written Recovery dura 6 s, budget metà cura (80% della cura potenziata), recupera fino al 45% del danno ricevuto finché il budget termina. Una sola annotazione utile per bersaglio/fonte viene aggiornata. Multi Cast ammesso a Remedy/Rewrite.
- Shared Margins: alleati schierati vivi entro 700, evocati esclusi; 30% del danno primario già mitigato condiviso una volta con gli altri collegati, senza seconda mitigazione. Eco del 20% delle cure primarie utili agli altri collegati; nessun echo/share ricorsivo. Cast 0,8 s, cooldown 12 s.
- Final Revision: cura 50% del danno recente ancora non recuperato, finestra 4 s; la cura ordinaria consuma le ferite più vecchie, Revision azzera lo storico e non può ripetere la stessa ferita. Si attiva se un alleato è sotto 15% HP oppure due sotto 40%. Cast 1 s, cooldown 18 s.
- The Story Continues: con almeno sei Note e cooldown pronto intercetta danno letale e lascia esattamente 1 HP nel tick; consuma tutte le Note, cooldown 30 s. Le cure simultanee sul salvato sono soppresse, resta un budget di recovery futuro. Nessuna invulnerabilità/resurrezione; ordine stabile per ID fra più alleati.
- Sleight of Hand: Setup ogni tre cicli base e per Prototype completato, cap 10; a quattro Setup il prossimo Prototype consuma tutte le cariche e riduce il cast al 40%. Prototype esplosione fisica 1,6×, raggio 85, cast 0,75 s, cooldown 6 s.
- Misdirection: trappole/esche/trucchi producono risorsa; bersaglio Misdirected per 4 s concede una carica aggiuntiva al ciclo base. Cap 10; a cap la prossima attiva ha potenza ×1,5. Gli impatti sulle esche aggregati nello stesso tick producono una carica per esca, non per singolo packet.
- Rigged Sigil: trappola fisica, armata dal tick successivo, durata 12 s, cap due, raggio 95, danno 2×, spinta 65. Special enemy immune alla spinta. Cast 0,7 s, cooldown 6 s; Encore crea due trappole.
- Clockwork Familiar: esca attaccabile reale, priorità locale entro 280, HP `(25% HP fonte + 2×AP) × potenza`, durata 8 s. Se distrutta esplode (2× fisico), senza ricompense. Encore la divide in due Mirror Decoy. Cast 0,8 s, cooldown 12 s.
- Grand Illusion: richiede tre avversari locali, azzera i target acquisiti senza interrompere azioni/proiettili già impegnati, due Mirror Decoy per 3 s; dopo 1 s esplosione fisica 2,5× nel gruppo locale più popoloso al momento della detonazione. Mobile rientra fisicamente verso lo slot. Cast 1 s, cooldown 18 s. Encore: esche 5 s, seconda esplosione dopo 2 s.
- Encore: completare tre attive differenti entro 25 s prepara un potenziamento della successiva attiva, utilizzabile entro 15 s. Consumata all'utilizzo. Cap complessivo cinque props per fonte.

Priorità default: Revision/Illusion 30, Rewrite/Familiar 20, altre 10, modificabili per copia. Cooldown indipendenti. Risorse/zone/storico si azzerano a morte e nuovo tentativo; gli evocati esistenti seguono durata e pulizia del cambio tentativo. Tutti gli stati necessari sono serializzati; pausa e offline usano gli stessi tick e RNG.

## Schieramento e compatibilità

In preparazione dopo Chrono break si può rimuovere anche l'ultima unità. Start resta disabilitato senza alleati schierati. Selezionare una copia in riserva e cliccare uno slot alleato libero la schiera in quel punto; le copie già schierate possono essere riposizionate nelle pause consentite. Composizione bloccata fuori preparazione, regole sul cambio ruolo preesistenti conservate.

Una sola copia per specie sull'intero campo, anche con forme/rami/ruoli differenti. Duplicati gacha restano nella collezione e possono essere alternati al Chrono break. Salvataggio v10, migrazione additiva v9: duplicati di formazione in preparazione tornano in riserva; un vecchio tentativo attivo con duplicati può concludersi e viene normalizzato al prossimo Chrono break. Nessun reset di livelli, valute o progressi.

## Asset e verifica

Cinque sprite sheet RGBA, 174 pose sorgente, idle con parte inferiore fissa e respiro superiore, camminata, attacchi, cast, hit, deployment e morte. Asset separati per ink/dardi, trappole, esplosioni, cure, recovery, gufo meccanico e specchi, più 24 icone. Ritagli e pivot calibrati; diverse attive usano sottosequenze della stessa riga di cast. Pause e timing seguono la simulazione. [Note artistiche](../../content/units/supports/would_be_wizard/visuals/spritesheets/ART_NOTES.md).

Preview isolata `tests/wizard_playground.tscn`: F6, tasti 1–5 per forme, Golem+Wizard livello 30, 200 Dust, nessuna lettura/scrittura del profilo reale. Nel gioco reale la copia iniziale è livello 1 in riserva; schierarla nella preparazione consentita.

Suite finale CLI e Godot AI: 1.210 controlli, zero fallimenti su Godot 4.7. La CLI segnala accesso al certificate store dell'ambiente; nessun errore di gameplay nell'esecuzione riuscita. Prima delle icone: dieci capture delle cinque forme e cast, ispezionate, poi ritagli corretti. Primo tentativo con icone non ancora importate e ordine ext_resource errato fallito; import e riferimenti corretti, suite successiva riuscita. Il vecchio warning `CONFUSABLE_LOCAL_DECLARATION` del Golem resta preesistente. Risultati della preview finale e grant reale registrati nel PROJECT_CONTEXT.

Restano bilanciamento prolungato, audio e rifinitura manuale delle variazioni residue fra pose generate. Il bestiario e gli altri quattro personaggi della rosa prevista restano futuri.
