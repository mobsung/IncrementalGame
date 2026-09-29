# Fondazione Multi Hit e Multi Cast

Tappa completata il 27 settembre 2026. Regole di riferimento: [Combattimento e abilità](../design/05_COMBATTIMENTO_E_ABILITA.md), [John the Meatball](../../content/units/warriors/spaghetti_golem/design/JOHN_IMPLEMENTED.md) e [Chrono break e shop](../design/09_CHRONO_BREAK_E_SHOP.md).

## Ambito completato

- `Multi Hit` e `Multi Cast` sono statistiche effettive dei combattenti, con valore base configurabile nella definizione della specie e minimo uno.
- Ogni attacco dichiara se supporta Multi Hit. Meatball Punch è compatibile; ogni colpo genera un evento di danno separato e verifica indipendentemente la catena critica.
- I colpi di un singolo ciclo si risolvono in ordine. Se un colpo uccide il bersaglio, il successivo cerca un altro nemico vivo e in range usando la priorità della copia. I colpi senza nuovo bersaglio si perdono.
- Hearty Rhythm avanza una sola volta per ciclo completato, anche quando il ciclo contiene due colpi o più uccisioni.
- Ogni abilità dichiara se supporta Multi Cast. Spaghetti Sweep è compatibile; le applicazioni usano la stessa geometria e lo stesso puntamento, non aggiungono tempo e condividono un solo cooldown.
- Le applicazioni della Sweep si risolvono in ordine. Un nemico ucciso da una applicazione viene escluso dalle successive; ogni bersaglio e applicazione usa una catena critica indipendente.
- La risoluzione locale della sequenza non altera la regola globale degli effetti simultanei: i pacchetti prodotti da combattenti diversi nello stesso tick vengono ancora raccolti prima della modifica della vita.
- La scheda della copia mostra i valori correnti di Multi Hit e Multi Cast.

## Dati e architettura

`CombatantDefinition` espone i valori base. `DamageDefinition.supports_multi_hit` e `SweepDefinition.supports_multi_cast` rendono esplicita la compatibilità dell'azione senza controlli sul nome dell'abilità.

`UnitStats` ricostruisce i valori effettivi da specie e modificatori condivisi. `StatUpgradeDefinition` riconosce entrambe le statistiche, così il futuro collegamento al Chrono shop potrà usare lo stesso catalogo Resource-driven. Nessuna Resource di acquisto è stata aggiunta: costi e crescita sono ancora aperti nel design.

`CombatSystem` usa una vita virtuale limitata alla singola sequenza per decidere retarget e applicazioni successive. La vita reale cambia soltanto in `CombatMath.resolve`, preservando gli scambi letali simultanei e l'ordine deterministico già esistente.

## Salvataggi v7

Il formato v7 aggiunge `multi_hit` e `multi_cast` allo stato serializzato dei combattenti e agli snapshot. La migrazione v6 assegna i valori base definiti per la specie corrente. I valori effettivi vengono comunque ricostruiti dai progressi permanenti al caricamento, come le altre statistiche.

## Verifiche

- **487 controlli, zero fallimenti** su Godot **4.7.stable.official.5b4e0cb0f**.
- Copertura nuova: retarget dopo colpo letale, perdita dei colpi senza bersaglio, passiva una volta per ciclo, critici indipendenti, due applicazioni Sweep ordinate, esclusione dei morti, un solo cooldown, incompatibilità esplicita, ricostruzione delle statistiche, migrazione v6 e validazione dei salvataggi.
- Suite eseguita tramite Godot AI con `res://tests/runtime_test_runner.tscn` e profilo isolato. Nessun acquisto è stato effettuato sul profilo reale.

## Limiti rimasti

- Il Chrono shop non offre ancora gli acquisti Multi Hit e Multi Cast perché costo, crescita e requisiti restano da definire.
- Il limite iniziale di due è la regola della futura offerta comune, non un limite rigido del motore: contenuti futuri potranno dichiarare limiti diversi dopo approvazione.
- Future abilità Multi Cast dovranno dichiarare puntamento, simultaneità e geometria specifici. Questa tappa implementa il comportamento confermato di Spaghetti Sweep.
