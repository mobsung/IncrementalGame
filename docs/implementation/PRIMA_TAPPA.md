# Prima tappa giocabile

Stato: implementata il 26 settembre 2026 su richiesta esplicita del giocatore. Questa pagina descrive l'implementazione; le regole di gameplay restano nei documenti di design.

Aggiornamento 27 settembre: completata anche la [tappa dei potenziamenti individuali](POTENZIAMENTI_INDIVIDUALI.md). I paragrafi seguenti includono il perimetro aggiornato.

Aggiornamento successivo: completata la [vista del campo e navigazione inferiore](CAMPO_E_NAVIGAZIONE.md). I controlli si aprono ora da Battle, Units, Chrono e Global shop; i potenziamenti sono in Units → John → Upgrades. Campo e pedine geometriche descritti nella prima tappa sono stati sostituiti da fondale e sprite illustrati. La suite complessiva conta ora 242 controlli superati; i 225 riportati sotto documentano la tappa precedente.

## Avvio e comandi

Stato successivo: [danno comune e critici](DANNO_E_CRITICI.md), cataloghi Gold completi nelle voci, salvataggio v4 e 435 controlli superati. I conteggi e i limiti nelle sezioni storiche sotto descrivono la prima tappa.

Aprire il progetto con Godot 4.7 stable e premere F6 sulla scena principale o F5. Scena: `res://scenes/main.tscn`.

- **Begin run** conferma la preparazione e avvia l'ondata.
- **Auto advance** avanza dopo una vittoria; spento di default, ripete l'ondata scelta.
- **Pause after attempt** prenota una pausa al prossimo esito, senza arrestare il combattimento in corso.
- **Pause on defeat** prenota automaticamente la pausa a ogni sconfitta.
- In preparazione o pausa: cliccare uno dei nove slot per spostare John; scegliere Mobile posture o Hold slot.
- **Repeat wave** sceglie un'ondata accessibile durante preparazione/pausa.
- La priorità modifica la prossima acquisizione, senza sostituire un bersaglio ancora valido.
- **Chrono break** richiede conferma, assegna Shards dal record raggiunto e apre la preparazione. Il combattimento continua mentre il dialogo è aperto; il premio si calcola alla conferma.
- Selezionare un combattente per vedere il range; per John compare anche la zona d'ingaggio tratteggiata.

## Perimetro effettivo

Implementati:

- Una copia iniziale di John, Meatball Punch, Spaghetti Sweep e Hearty Rhythm ai valori iniziali della scheda.
- Nemici bilanciato, offensivo e speciale; crescita per ondata. Lo speciale è incluso per mantenere corretta la decima ondata.
- Movimento diretto senza collisioni; zona alleata e priorità; rientro ordinario e rientro alla postura ferma.
- Dodici comparizioni naturali, sei per tipo, senza quattro consecutive uguali; 24 nemici ordinari. Speciale a 11 s ogni decima ondata.
- Esiti, pausa, snapshot di vita/cooldown/contatore passivo, riposizionamento alla sconfitta, blocco XP e limite di ritiro.
- Accumulo provvisorio di Gold/XP/anime, assegnazione all'esito, livelli/punti, Dust e reset tramite Chrono break.
- Tre acquisti Gold individuali e sei potenziamenti a punti livello per John; pulsante Upgrades e catalogo nel pannello destro.
- Salvataggio completo del tentativo e recupero da backup.
- UI inglese e ritratto approvato; campo e combattenti sono rappresentazioni funzionali nuove.

Rinviati alle tappe successive: completamento catalogo Gold, shop globale e Chrono shop, gacha e rosa aggiuntiva, evoluzioni, più copie contemporaneamente schierate, supporti nemici, evocazioni, effetti generici/buff, danno magico, super/ultracritici, multi hit/multi cast, animazioni definitive, audio, progressione offline.

I parametri non usati dai contenuti di questa tappa non vengono presentati come implementati. La scheda di John definisce compatibilità future; questa tappa esegue un singolo colpo/lancio e il critico normale iniziale.

## Architettura

| Area | Responsabilità |
| --- | --- |
| `scripts/data/`, `resources/` | Resource condivise: definizioni di combattenti, spazzata, geometria e bilanciamento. Non vengono mutate durante il combattimento. |
| `UnitProgress` | Identità e progressi indipendenti di una copia, postura, velocità, priorità e slot. |
| `PlayerProfile` | Copie possedute e saldi permanenti. |
| `CombatantState` | Posizione, vita, attacco effettivo, azione, cooldown, bersaglio e contatore passivo durante la battaglia. |
| `BattleSimulation` | Ciclo della run, sequenza delle ondate, esiti, ricompense e serializzazione dello stato. |
| `CombatSystem`, `Targeting`, `CombatMath` | Movimento, acquisizione, esecuzione e risoluzione simultanea dei danni e delle cure. |
| `SaveStore` | Formato versione 2, migrazione v1, validazione, checksum, scrittura temporanea, backup e caricamento. |
| `UnitStats`, `UpgradePanel` | Calcolo dei modificatori da dati base e acquisti; presentazione cataloghi e richieste di transazione. |
| `DemoController` | Collega modello, persistenza e scene UI; nessun Autoload gameplay. |
| `ArenaView` | Disegno in coordinate logiche, selezione, separazione visiva ed effetti. Non applica danni. |

La simulazione usa RefCounted e non dipende da SceneTree, input, animazioni o tempo di sistema. Avanza a passi fissi di 1/60 s; gli eventi dello stesso passo sono simultanei. I tempi di azione sono quantizzati al passo. Il seme e lo stato del generatore casuale vengono conservati. La riproducibilità è verificata sulla stessa versione del motore e con le stesse definizioni.

Il coordinatore di questa tappa schiera una sola copia: collezione e schieramento multiplo richiederanno di estendere il mapping copie/combattenti, l'esito di squadra e lo schema di salvataggio. Non è ancora implementata una squadra completa.

## Valori iniziali di prova

Geometria configurabile in `first_arena.tres`: campo logico 1280×640, superficie percorribile (30,50)–(1250,590), griglia di nove slot, spawn (1120,240), dispersione verticale del gruppo 26, rientro dopo 0,75 s senza bersagli. La finestra non cambia le distanze della simulazione.

Nemici: vedere le tre schede in `docs/design/nemici/`. I valori sono stati scelti sotto la delega del giocatore e rimangono da bilanciare con acquisti e altre specie.

La prima UI mira al desktop, con riferimento 1440×900 e finestra iniziale 1280×800. Il pannello destro scorre nelle finestre più piccole. Piattaforme definitive e budget di carico della demo completa restano da stabilire.

## Persistenza

File dedicato `user://first_demo.save`, distinto da eventuali salvataggi del vecchio prototipo. Serializzazione Variant senza oggetti: conserva Vector2 e interi a 64 bit del generatore casuale. Il payload ha checksum SHA-256 e versione del formato.

Vengono conservati profilo, run, entità, azioni, tempi residui, sequenza/comparizioni, ricompense provvisorie e snapshot d'inizio tentativo. I dati sono copie profonde, senza riferimenti mutabili condivisi tra snapshot.

Salvataggi dopo transizioni e scelte, ogni 10 s e alla chiusura regolare. Scrittura su file temporaneo, copia del precedente salvataggio valido in `.bak`, sostituzione tramite rename. In caso di chiusura forzata si riparte dall'ultimo salvataggio completato.

Il caricamento verifica struttura, tipi, intervalli e riferimenti ai contenuti. Prova file principale, temporaneo e backup. Migra v1 a v2 aggiungendo i progressi degli acquisti mancanti; un formato futuro sconosciuto viene rifiutato. Se nessun file esistente è valido, la UI blocca il gioco e preserva i file invece di iniziare e sovrascrivere i progressi.

L'offline è previsto e non ancora attivo: alla riapertura il tempo trascorso a gioco chiuso non produce progressi. Il timestamp è già nell'involucro del salvataggio. La simulazione senza grafica e gli snapshot costituiscono la base per l'implementazione futura; politiche e accelerazione del calcolo restano da progettare.

## Verifica

Comando ripetibile, usando l'eseguibile console di Godot 4.7:

```powershell
& 'C:/Users/marce/OneDrive/Desktop/Godot/Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tests/run_tests.gd
```

225 controlli superati: i 153 della prima tappa (sequenze su 100 generazioni, formule, settore, tempi d'attacco/cast, passiva, priorità, morte simultanea, ripristino, XP, pool anime, Chrono break, snapshot indipendenti, prosecuzione riproducibile dopo restore, file e recupero da backup corrotto), più i controlli su acquisti, effetti, migrazione e UI descritti nella seconda tappa.

Avvio e combattimento verificati anche attraverso Godot AI; la prova ha raggiunto il record 9 con John ai valori base. Verificato un salvataggio completo durante l'ondata 10 tramite confronto tra stato caricato e stato corrente. Questo è uno smoke test, non un bilanciamento completo o un benchmark delle prestazioni.

La prima esecuzione CLI nel sandbox non aveva accesso alle cartelle utente di Godot. Dopo esecuzione con accesso alle normali cartelle, i test sono terminati senza errori. I log locali in `tests/*.log` sono esclusi da Git.

## Prossima tappa

1. Provare manualmente questa base e correggere eventuali problemi di leggibilità/ritmo.
2. Estendere il catalogo Gold e aggiungere shop globale/Chrono, collegando ciascuna statistica al suo effetto reale.
3. Estendere collezione e contenuti nell'ordine concordato, senza duplicare formule nei pannelli UI.
