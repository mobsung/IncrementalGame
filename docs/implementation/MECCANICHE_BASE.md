# Meccaniche base prima dei nuovi personaggi

Implementazione del 30 settembre 2026. L'utente ha chiesto di completare i sistemi di base prima di introdurre nuove specie e ha autorizzato una prima versione configurabile delle parti aperte del Chrono shop e dell'offline.

## Cosa cambia nel gioco disponibile

- Chrono shop: 23 acquisti permanenti. Alle sei voci esistenti si aggiungono Magic Attack, Magic Resistance, Ability Power additiva e moltiplicativa, Attack Speed, Range, AoE, Haste, i sei parametri critici, Multi Hit, Multi Cast e un posto alleato. Multi Hit/Cast hanno un solo grado: un massimo di due ripetizioni per il contenuto attuale. Il posto aggiuntivo alza il limite da tre a quattro copie, utilizzabili nei nove slot già esistenti.
- Priorità delle attive per copia nella scheda dell'unità: valori 0–100, più alto prima. Il Golem conserva il default Surge 30, Guard 20, Sweep 10; le regole specifiche del suo kit restano, comprese le azioni già iniziate che si completano. Le priorità possono cambiare in battaglia ma incidono sulla decisione successiva.
- Offline esatto, massimo iniziale 900 secondi: procede solo da un tentativo salvato in combattimento, usa squadra, RNG e impostazioni salvate, conserva ricompense provvisorie e applica esiti reali. Rispetta pause prenotate, non avvia preparazione/pausa, si ferma alla prima sconfitta anche se la preferenza online è diversa. Nessun acquisto, evocazione gacha, cambio squadra o Chrono break automatico.
- Calcolo offline distribuito fra frame, budget iniziale 6 ms/frame, interrompibile. Il riepilogo distingue ricompense concluse da quelle del tentativo ancora in corso. Fermarlo conserva il lavoro già calcolato; il tempo offline restante viene scartato. Il timestamp scritto dopo il calcolo impedisce di riassegnare lo stesso intervallo alla riapertura. Un errore di scrittura resta visibile. Nessun progresso retroattivo dalla v8: il clock offline parte dal primo salvataggio v9.

I prezzi sono una configurazione iniziale da bilanciare, non risultati di un playtest economico:

| Nuova voce | Shards iniziali | Incremento | Gradi |
| --- | ---: | --- | ---: |
| Magic Attack | 2 | +5 | 20 |
| Magic Resistance | 2 | +3 | 20 |
| Ability Power | 2 | +5 | 20 |
| Ability Power multiplier | 3 | +10% nel pool Chrono | 20 |
| Attack Speed | 3 | +5% nel pool Chrono | 20 |
| Range | 3 | +5 | 10 |
| Area | 3 | +10% superficie | 10 |
| Haste | 3 | +5 | 20 |
| Critical Chance | 3 | +2 punti percentuali | 20 |
| Critical Damage | 3 | +0,1 al fattore | 10 |
| Super Critical Chance / Damage | 10 ciascuno | +2 punti / +0,1 | 10 |
| Ultra Critical Chance / Damage | 25 ciascuno | +1 punto / +0,1 | 10 |
| Multi Hit / Multi Cast | 25 ciascuno | +1 ripetizione compatibile | 1 |
| Allied slot | 50 | +1 copia schierabile | 1 |

Crescita prezzi delle nuove statistiche: 1,6, oppure 1,8 per i critici. Gli acquisti singoli hanno crescita 2,0, irrilevante dopo il cap. `required_record` è configurabile e inizialmente zero. Le sei voci Chrono precedenti conservano i propri dati. Risorse in `resources/shops/chrono_*.tres`, configurazione offline in `BattleConfig`.

## Sistemi pronti per il contenuto futuro

Non sono nuove abilità assegnate al Golem e non aggiungono specie al gacha. I test usano definizioni sintetiche isolate.

- `AbilityDefinition` e `AbilityEffectDefinition`: più attive, priorità per copia, selezione condizionata di bersagli, esecuzione esclusiva, cooldown individuali fissati all'avvio e consumati anche se il bersaglio scompare. L'attiva generale interrompe un attacco normale; un'attiva già iniziata si completa. Bersaglio verificato all'acquisizione, un tentativo di sostituzione se invalidato prima dell'effetto. Le attive senza bersaglio esterno usano `self`.
- Effetti ordinati: danno fisico/magico, cure flat/percentuali/AP, resurrezione (default 10%), status ed evocazioni. AoE circolare segue il bersaglio all'effetto; i bonus aumentano la superficie. Multi Cast deve essere dichiarato: la prima implementazione generale ripete gli effetti in ordine sullo stesso bersaglio/area, nello stesso tempo di lancio e con un solo cooldown. Altri comportamenti richiedono una dichiarazione specifica di contenuto e un'estensione dedicata.
- Cure automatiche: alleato vivo con percentuale HP più bassa, inclusa la fonte e senza bersagli a vita piena; parità casuale. Evocati esclusi salvo `include_summons`. Le cure ordinarie non salvano da danno letale simultaneo e non resuscitano.
- `StatusDefinition`/`StatusSystem`: modificatori additivi e percentuali di statistiche di combattimento e ricompense Gold/XP/Souls. Stack limitati per coppia effetto/fonte, refresh configurabile. Ricostruzione senza accumulo artificiale; nuovi status impegnati dopo gli effetti simultanei. Un ordine interno mark-then-hit usa una copia locale delle difese, senza influenzare altri colpi dello stesso istante. I timer continuano anche sulla copia morta; `ends_on_death` abilita eccezioni esplicite. Le ricompense leggono i marchi già attivi all'uccisione, comprese le frazioni.
- Danno differito/proiettili: packet indipendente dalla fonte, potenza fissata alla generazione, difese lette all'impatto. Continua se la fonte muore; se il bersaglio non esiste più si perde. Pausa e salvataggio conservano il tempo residuo; Chrono, sconfitta e cambio ruolo cancellano gli effetti previsti. È il supporto logico del volo, non un asset animato di proiettile.
- Evocazioni: proprietario stabile, quantità/cap/durata/ricompense configurabili, spawn vicino alla fonte. Alleati con statistiche del template; nemici con crescita dell'ondata alla comparsa, conservata passando a ondate successive. Evocati e supporti non tengono aperta l'ondata naturale; evocati alleati non impediscono la sconfitta della squadra. Scadenza senza ricompense. Persistono dopo vittoria, scompaiono a sconfitta/Chrono/cambio ruolo.
- Supporti nemici: ruolo esplicito dichiarato dalla specie, fermo e non bersagliabile. Un posto iniziale in tre posizioni fisiche configurabili; selezione/spostamento dei ruoli compatibili fuori dal combattimento e composizione in preparazione. Supporti partecipano ai contributi economici e ricevono l'intero XP eleggibile. Il Golem non dichiara questo ruolo.
- Evoluzioni ramificate: `EvolutionDefinition` con ID, soglia livello, descrizione e forma completa; scelta permanente per copia, alternative nella UI, rimborso dei punti e conservazione di XP/Gold. La derivazione delle statistiche usa la base della specie, così il cambio forma non aggiunge statistiche base. Il percorso lineare esistente del Golem resta compatibile. Non sono stati inventati suoi rami.
- La classe è un'etichetta configurabile tra le sei classi di design, senza pacchetti obbligatori di statistiche.

Le forme future devono dichiarare il kit completo e le attive ereditate. Questa tappa non crea un linguaggio universale di abilità: controllo del movimento, zone persistenti, canalizzazioni, forme AoE alternative e ripetizioni con retarget richiedono le regole della specie che le introduce. Audio, ulteriori illustrazioni e bestiario non fanno parte di queste meccaniche.

## Persistenza e verifiche

Formato v9: aggiunte additive per priorità, ruoli, percorso evolutivo, cooldown, status, proprietari/durate degli evocati e packet in volo. La migrazione v8 conserva copie, evoluzioni, investimenti, valute, RNG e tentativo. Il reset pre-v8 già autorizzato resta la migrazione storica; il backup indipendente `first_demo.before_spaghetti_v8.save` non viene toccato.

Suite corrente: `run_spaghetti_tests.gd` integra `base_mechanics_tests.gd`. I test usano profili isolati e file temporanei `demo_test_*.save`; nessuna lettura/scrittura del profilo reale. Il numero finale e le verifiche grafiche sono riportati in PROJECT_CONTEXT.md e tests/README.md. La CLI sandbox segnala l'accesso al certificate store di Windows: è un limite dell'ambiente, distinto dagli esiti dei test di gameplay. Graphify non avviabile nell'ambiente corrente (`Accesso negato` dell'interprete isolato); dipendenze verificate nei file e via Godot AI.

Preview ripetibile: `res://tests/base_mechanics_preview.tscn`, istanza della main con persistenza disabilitata.
