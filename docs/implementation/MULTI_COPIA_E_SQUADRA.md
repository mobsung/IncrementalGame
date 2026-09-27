# Fondazione multi-copia e risultati di squadra

Tappa completata il 27 settembre 2026. Regole di riferimento: [Unità](../design/01_UNITA.md), [Campo e schieramento](../design/03_CAMPO_E_SCHIERAMENTO.md), [Combattimento](../design/05_COMBATTIMENTO_E_ABILITA.md), [Ondate ed esiti](../design/06_ONDATE_ED_ESITI.md) ed [Economia](../design/07_ECONOMIA_E_POTENZIAMENTI.md).

La successiva tappa [Gacha e collezione](GACHA_E_COLLEZIONE.md) ha aggiunto l'acquisizione e la selezione UI delle copie e ha portato il salvataggio a v6. Le sezioni sotto descrivono lo stato verificato di questa tappa v5.

## Ambito completato

- Il profilo distingue copie possedute e copie schierate. La copia iniziale di John resta schierata per compatibilità; una nuova `UnitProgress` nasce non schierata.
- La formazione alleata ammette da una a tre copie e rifiuta slot duplicati. La composizione può cambiare durante la preparazione; durante le pause si possono spostare copie già schierate. La battaglia blocca entrambe le operazioni.
- Ogni combattente alleato conserva il `copy_id` stabile. Postura, priorità, statistiche e acquisti vengono risolti sulla copia associata, senza usare `copies[0]` nel combattimento.
- La sconfitta scatta quando non resta alcun alleato vivo. I caduti rimangono nella formazione fino all'esito; la vittoria dipende dall'assenza di nemici vivi.
- Lo snapshot del tentativo contiene tutti gli alleati. Una sconfitta ripristina salute, timer e stato temporaneo di ogni copia, quindi riapplica i progressi permanenti correnti.
- Ogni copia schierata riceve l'intero XP idoneo, anche se è morta durante una vittoria. I contributi individuali Gold, XP e Souls di tutte le copie schierate vengono sommati prima dei modificatori condivisi.
- Chrono break ricrea e cura tutte le copie schierate. Gli acquisti condivisi ricostruiscono tutti gli attori alleati; quelli individuali possono essere indirizzati tramite ID di copia.

## Architettura

`PlayerProfile` espone ricerca per ID e lista delle copie schierate. `BattleSimulation` crea un attore per copia, mantiene compatibili `unit()` e `hero()` per la UI attuale e offre API specifiche per schieramento, slot, postura, priorità e acquisti.

`CombatSystem.step` riceve la mappa delle copie e risolve le preferenze per ogni attore. `UnitStats` usa la definizione indicata da `species_id`, preparando il calcolo per specie future senza aggiungere contenuti o regole non approvati.

La presentazione segna tutti gli slot occupati e conta i nemici senza assumere un solo alleato. L'interfaccia di roster resta intenzionalmente limitata al John posseduto dal profilo reale: gacha, collezione e selezione di altre copie sono tappe successive.

## Salvataggi v5

Il formato v5 aggiunge `deployed` a ogni copia, `copy_id` agli attori e converte `attempt_snapshot` da dizionario singolo a lista. La validazione richiede:

- ID di copia univoci;
- da una a tre copie schierate;
- slot schierati univoci e validi;
- corrispondenza uno-a-uno fra copie schierate, attori alleati e snapshot;
- assenza di `copy_id` sugli attuali nemici naturali.

La migrazione v4 assegna la copia esistente all'attore alleato e al vecchio snapshot. Le migrazioni v1, v2 e v3 proseguono in sequenza fino a v5. Il ripristino usa un'assegnazione tipizzata esplicita per non perdere gli snapshot provenienti da array Variant migrati.

## Verifiche

- **455 controlli, zero fallimenti** su Godot **4.7.stable.official.5b4e0cb0f**.
- Copertura nuova: limite e unicità della formazione, almeno un alleato, blocco in battaglia, mapping stabile, sconfitta solo dell'intera squadra, ripristino di più snapshot, XP ai caduti, contributi cumulativi, rinascita al Chrono, validazione e roundtrip multi-copia.
- Migrazioni reali simulate da layout v1, v2, v3 e v4; continuità deterministica dopo il caricamento.
- Suite eseguita tramite la scena isolata `res://tests/runtime_test_runner.tscn` avviata da Godot AI. La scena principale è stata avviata separatamente e il suo albero runtime letto senza errori correnti.

## Limiti rimasti

- Nessuna seconda copia viene aggiunta al profilo reale: le prove usano copie sintetiche isolate.
- Roster, collection, gacha e controlli UI sono stati completati nella tappa successiva; restano aperti i contenuti oltre John e gli sblocchi delle rarità.
- Gli slot e i ruoli sul lato nemico non sono implementati. Servono unità e regole confermate; Fortuna non viene dedotta dal concept.
- Mancano il sistema generico di abilità/effetti, multi hit/cast, buff/status, evocazioni ed evoluzioni.
