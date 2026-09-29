# Contributi individuali Gold, XP e Souls

Tappa completata il 27 settembre 2026 dopo velocità, portata, area e Haste. Attua il catalogo e le formule già concordati in [Economia](../design/07_ECONOMIA_E_POTENZIAMENTI.md), con contributi base zero definiti nella [scheda di John](../../content/units/warriors/spaghetti_golem/design/JOHN_IMPLEMENTED.md).

## Acquisti e interfaccia

In **Units → John → Upgrades** sono disponibili tre nuovi acquisti. La scheda statistiche mostra il contributo della copia per nemico sconfitto, prima dei bonus condivisi.

| Voce | ID stabile | Incremento per grado | Primo costo |
| --- | --- | ---: | ---: |
| Gold Contribution | `gold` | +0,25 Gold | 40 Gold |
| XP Contribution | `xp` | +0,10 XP | 50 Gold |
| Soul Contribution | `souls` | +0,10 Souls | 50 Gold |

Ogni voce ha 50 gradi, crescita prezzo 1,20 e costo arrotondato per eccesso. Sono valori iniziali configurabili nelle Resource, sotto la delega del design economico, da verificare nel bilanciamento. Nessun requisito di livello. Il catalogo individuale arriva a dieci voci.

## Calcolo e persistenza

- `UnitStats.individual_gold_bonuses` centralizza gli incrementi acquistati; `reward_contribution` ricava il contributo della singola copia dai dati base e dai suoi gradi. I campi Gold/XP/Souls della Resource di John sono esplicitamente zero, come da scheda.
- `BattleSimulation.reward_value` aggiunge il contributo della copia schierata alla ricompensa base nemica, poi usa `ShopModifiers` per additivi condivisi e pool moltiplicativi esistenti. Lo stesso calcolo serve tutte le uccisioni; la UI non replica la formula.
- Sono considerate le copie schierate, anche se muoiono nello stesso passo dell'uccisione. L'attuale simulazione schiera soltanto la prima copia: possedere un'altra copia non concede contributi. Lo schieramento multiplo resta da implementare.
- L'acquisto incide sulle uccisioni successive. Non ricalcola i valori provvisori precedenti e non modifica vita, azioni, timer, snapshot o RNG. Gli amplificatori specifici di John restano limitati alle statistiche previste.
- Le frazioni restano nei totali. XP richiede una vittoria idonea; Gold e Souls spettano anche alla sconfitta. Souls può attraversare la soglia Dust conservando l'eccedenza. Il Chrono break scarta le ricompense provvisorie e conserva gli acquisti.
- I gradi usano i dizionari individuali esistenti. Formato **v3 invariato**, migrazioni v1/v2 preservate; nessun nuovo campo temporaneo o migrazione necessaria.

## Verifiche eseguite

- Baseline: **304 controlli, zero fallimenti**. Suite finale: **351 controlli, zero fallimenti**, eseguibile Godot **4.7.stable.official.5b4e0cb0f**, `--headless --path . --script res://tests/run_tests.gd`.
- Copertura nuova: transazioni e limiti, isolamento delle copie, acquisti a metà tentativo, uccisioni effettive, combinazione con entrambi i pool condivisi, morte simultanea, XP bloccata/ripetizioni, Dust frazionario, sconfitta e Chrono, salvataggio v3, gradi invalidi e ripresa deterministica. Pulsanti istanziati e testo delle statistiche controllati su profili isolati.
- Il primo avvio CLI nel sandbox è terminato con crash nativo prima dei test. La suite con accesso alle normali cartelle utente è passata, come nelle verifiche precedenti.
- Progetto avviato tramite Godot AI; nessun errore corrente di avvio né nuovo errore nei log editor/game. Tre acquisti tramite pulsanti in una scena temporanea con `persist_progress=false`: saldo di prova 140 → 0, tre gradi acquistati, profilo reale invariato durante la prova.
- Il profilo reale era in battaglia al caricamento. Prenotata e raggiunta la pausa ordinaria: ondata 5, record 4, Gold 451,525000000006, HP 1152. Verificato il salvataggio su disco in pausa con lo stesso Gold. Nessun acquisto di prova sul profilo reale.

## Limiti e prossime tappe

Non è un bilanciamento prolungato. Restano Ability Power, catena critica avanzata, danni/difese magiche, multi hit/cast, schieramento multiplo e gli altri sistemi documentati. Fortuna, evocazioni ed evoluzioni non sono state implementate; asset di John e configurazione MCP preservati.
