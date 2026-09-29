# Danno comune, Ability Power e catena critica

Tappa completata il 27 settembre 2026. Regole di riferimento: [Combattimento](../design/05_COMBATTIMENTO_E_ABILITA.md), [Economia](../design/07_ECONOMIA_E_POTENZIAMENTI.md), [Nemici](../design/02_NEMICI.md) e [John](../../content/units/warriors/spaghetti_golem/design/JOHN_IMPLEMENTED.md).

## Sistemi disponibili

- Danno fisico, magico e misto. Le componenti usano rispettivamente Armor e Magic Resistance, si mitigano separatamente e poi si sommano. Difese negative, valori frazionari e assenza di un danno minimo seguono la formula comune.
- Ability Power con compatibilità esplicita per azione. Spaghetti Sweep usa `1 + AP / 100`; Meatball Punch e Hearty Rhythm non scalano con AP.
- Critico normale, supercritico e ultracritico: uno stadio si verifica solo se quello precedente riesce. Ogni chance effettiva viene limitata al 100%; i moltiplicatori degli stadi raggiunti si moltiplicano.
- Un evento misto usa una sola catena per entrambe le componenti. Una componente può essere esclusa esplicitamente dai critici. Ogni bersaglio di Sweep verifica una catena indipendente.
- Vita/difese del bersaglio sono lette all'impatto; la potenza della fonte viene fissata quando nasce l'effetto. Gli acquisti durante un lancio incidono sulla potenza alla generazione, preservando il cooldown già catturato.
- I nemici applicano la crescita per ondata a entrambe le statistiche d'attacco. Le difese non crescono automaticamente. Gli attuali nemici restano fisici; nessuna nuova specie o abilità introdotta.

## Architettura

`DamageDefinition` è una Resource con coefficienti fisico/magico, rapporto AP e compatibilità critica. `CombatantDefinition.basic_damage` definisce l'attacco normale; `SweepDefinition` estende gli stessi dati con geometria e tempi. La Resource condivisa `physical_basic.tres` mantiene gli attacchi esistenti. Le definizioni non vengono mutate durante la simulazione.

`CombatMath.create_damage` produce i valori dell'effetto e lo stadio critico; `damage_amount` applica le difese. `CombatSystem` usa lo stesso percorso per attacchi e Sweep e conserva la risoluzione simultanea già esistente. Gli eventi per la presentazione includono componenti prima della difesa e stadio critico. Non sono stati implementati proiettili, buff o animazioni nuovi.

`UnitStats` ricostruisce le statistiche dagli acquisti individuali e dai pool condivisi, con le stesse formule usate dagli altri potenziamenti. I gradi restano in `UnitProgress`/`PlayerProfile`; `CombatantState` conserva i valori del combattente, inclusi quelli nemici al momento della comparsa.

## Cataloghi Gold completati

Aggiunte nove voci individuali e nove globali. Entrambi i cataloghi hanno ora **19 acquisti**, coprendo le voci Gold previste da Economia. Il Chrono shop resta al sottoinsieme precedente di sei voci.

| Statistica | Incremento per grado | Primo costo individuale | Primo costo globale |
| --- | --- | ---: | ---: |
| Magic Attack | +3 | 20 | Non previsto |
| Magic Resistance | +2 | 15 | 60 |
| Ability Power | +5 punti | 35 | 105 |
| Critical Chance | +1 punto percentuale | 40 | 120 |
| Critical Damage | +0,05 al moltiplicatore | 40 | 120 |
| Super Critical Chance | +1 punto percentuale | 80 | 240 |
| Super Critical Damage | +0,05 al moltiplicatore | 80 | 240 |
| Ultra Critical Chance | +1 punto percentuale | 120 | 360 |
| Ultra Critical Damage | +0,05 al moltiplicatore | 120 | 360 |
| Ability Power Mastery | +5% nel pool globale AP | Non previsto | 150 |

Massimo 50 gradi ciascuno. Crescita del prezzo 1,20, salvo Ability Power Mastery 1,25; arrotondamento per eccesso. Parametri iniziali Resource sotto la delega del design economico, non bilanciamento definitivo. Le descrizioni chiariscono le compatibilità: Magic Attack non modifica gli attacchi fisici attuali di John; il moltiplicatore AP necessita di punti AP.

La scheda mostra attacco/resistenza magica, AP effettiva, chance e moltiplicatore dei tre stadi. Gli acquisti non curano e non riavviano azioni o timer.

## Salvataggi v4

Il formato **v4** aggiunge nove valori numerici a combattenti e snapshot: attacco/resistenza magica, AP e sei statistiche critiche. La migrazione v3 inserisce i valori base mancanti delle definizioni note, preservando ogni campo esistente, progressi, ricompense provvisorie, salute, timer e RNG. Il contenuto pre-v4 aveva attacco magico/AP zero e nessun acquisto critico avanzato. Le migrazioni v1 e v2 proseguono fino a v4.

I valori della copia vengono ricostruiti dagli acquisti al caricamento e al ripristino dopo sconfitta. Statistiche nemiche serializzate restano quelle del combattente già comparso. La validazione rifiuta valori non finiti, chance fuori intervallo e moltiplicatori critici sotto uno. I salvataggi di versioni future continuano a essere rifiutati senza ripiegare su backup più vecchi.

## Verifiche

- Baseline: **351 controlli, zero fallimenti**. Suite finale: **435 controlli, zero fallimenti**, su Godot **4.7.stable.official.5b4e0cb0f**, con `--headless --path . --script res://tests/run_tests.gd`.
- Danno misto, resistenze positive/negative, frazioni, esclusione di componenti, tutti gli stadi critici, consumo RNG condizionato, frequenze con seme fisso, catena per bersaglio di Sweep, AP compatibile e passiva invariata.
- Acquisti individuali/globali, limite chance, gradi massimi, stato durante un lancio, danno magico effettivo di un nemico sintetico, crescita nemica, indipendenza delle Resource, continuità deterministica e transizioni.
- Migrazione di un layout v3 privo dei nuovi campi durante una battaglia, migrazioni concatenate v1/v2, roundtrip v4, snapshot malformati e valori invalidi. Corretto durante lo sviluppo il fixture che tentava di inserire `null` in un Array tipizzato Dictionary; suite finale pulita.
- Graphify usato per individuare le dipendenze fra calcolo, combattenti e persistenza; confermate nel codice. Gli indici restano locali e ignorati.
- Scansione e avvio tramite Godot AI riusciti. Durante le modifiche erano comparsi errori di caricamento transitori della nuova classe nell'editor; dopo la scansione, nessun errore del nuovo avvio o dei log successivi (cursore editor 24).
- Acquisti dai pulsanti e statistiche verificati in una scena temporanea `persist_progress=false`; scheda ispezionata tramite cattura del viewport. Scena temporanea rimossa dopo la verifica.
- Profilo reale migrato, salvato e riletto in v4: **pausa**, Gold **451,525000000006**, HP **1152**, nessun acquisto di prova. John e gli asset di Fortuna preservati.

## Prossimi sistemi

Il mapping di più copie alleate, lo schieramento e gli esiti di squadra sono stati completati nella tappa successiva, documentata in [MULTI_COPIA_E_SQUADRA.md](MULTI_COPIA_E_SQUADRA.md). Restano multi hit/cast e relativi acquisti Chrono, collezione e gli altri contenuti concordati. Il sistema abilità gestisce ancora il tipo Sweep e una sola abilità attiva per combattente; non è un motore generico completo per effetti, evocazioni o buff. Proiettili, animazioni e bilanciamento prolungato restano da realizzare. Fortuna, evocazioni ed evoluzioni richiedono le rispettive schede confermate.
