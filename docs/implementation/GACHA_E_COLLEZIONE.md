# Gacha iniziale e collezione multi-copia

Tappa completata il 27 settembre 2026. Regole di riferimento: [Unità](../design/01_UNITA.md), [Economia e potenziamenti](../design/07_ECONOMIA_E_POTENZIAMENTI.md) e [Collezione e gacha](../design/08_COLLEZIONE_E_GACHA.md).

## Ambito completato

- Il primo summon costa **5 Dust**, valore configurato nella Resource del gacha.
- Il pool iniziale contiene soltanto **John the Meatball, Common**, come richiesto. Ogni risultato crea una copia a livello base, non schierata e con progressi individuali vuoti.
- Le copie ricevono un ID permanente univoco. Il profilo salva il prossimo seriale e non dipende dall'ordine degli attori di combattimento.
- La selezione usa due livelli di peso configurabili: rarità e voce del pool. Le rarità senza contenuti disponibili vengono escluse e i pesi rimasti vengono normalizzati. Con il solo John disponibile il risultato è deterministico.
- L'RNG delle evocazioni è separato dall'RNG del combattimento. Evocare non cambia sequenze di ondata, bersagli casuali o critici.
- La pagina Units è ora una collezione: mostra tutte le copie, apre statistiche e potenziamenti della copia scelta, e permette di schierarla o spostarla in riserva durante la preparazione.
- La formazione usa la copia selezionata. Fino a tre John possono essere schierati contemporaneamente in slot distinti; ogni copia conserva livello, XP, punti, postura, priorità e acquisti propri.

## Dati e responsabilità

`GachaDefinition` contiene costo, pesi delle rarità e voci disponibili. `SummonEntryDefinition` collega una specie autorizzata alla rarità e al peso nel proprio gruppo. Il pool iniziale si trova in `resources/gacha/` e riusa la definizione condivisa di John senza duplicarne le statistiche.

`BattleSimulation.summon()` valida il saldo, estrae la voce, addebita il costo una sola volta e chiede a `PlayerProfile` di creare la copia. La UI non modifica direttamente Dust o collezione. Una copia in riserva non possiede stato temporaneo di combattimento; `preview_actor()` ricostruisce soltanto le statistiche necessarie alla scheda.

Il sistema può ospitare altre voci quando esisteranno schede di design approvate. Non sono stati aggiunti Fortuna, evocazioni di supporto, evoluzioni, soglie di sblocco o distribuzioni implicite fra specie.

## Salvataggi v6

Il formato v6 aggiunge:

- `next_copy_serial` al profilo;
- seed e stato dell'RNG dedicato al gacha.

La migrazione v5 calcola il seriale dalla collezione esistente e inizializza il nuovo RNG in modo deterministico dal vecchio seed, senza modificare valute, copie o stato del tentativo. Le migrazioni v1-v4 continuano in catena. La validazione ammette soltanto specie presenti nelle definizioni configurate e rifiuta seriali non validi.

## Verifiche

- **474 controlli, zero fallimenti** su Godot **4.7.stable.official.5b4e0cb0f**.
- Copertura nuova: costo e pool Resource, rifiuto senza Dust, addebito esatto, due evocazioni consecutive, ID stabili, indipendenza dei progressi, riserva iniziale, schieramento di tre copie, isolamento dell'RNG di combattimento, roundtrip v6 e migrazione reale simulata da v5.
- La scena UI isolata con `persist_progress=false` ha evocato e schierato una seconda copia, aggiornato il roster e selezionato la scheda corretta.
- Suite avviata tramite Godot AI con `res://tests/runtime_test_runner.tscn`; log successivi alla registrazione delle nuove Resource privi di nuovi errori. Il profilo reale non è stato caricato né scritto.

## Limiti rimasti

- Soglie di sblocco delle rarità e distribuzione fra più specie della stessa rarità richiedono ancora decisioni di design. I pesi confermati 55/30/12/3 sono già configurati.
- Il pool contiene soltanto John. Fortuna resta concept e non partecipa al gacha.
- Mancano presentazione finale dell'estrazione, animazioni, audio, storico, pity, protezione duplicati e compensazioni. Questi ultimi tre elementi sono esclusi dalla prima demo dal design corrente.
