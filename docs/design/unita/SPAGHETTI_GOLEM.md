# John the Meatball

[Unità, copie e crescita](../01_UNITA.md)

## Stato e autorità della scheda

Design iniziale per la prova. Il giocatore ha delegato la scelta di statistiche, dettagli delle azioni e primi potenziamenti: i valori sotto sono la configurazione iniziale scelta su tale mandato, tutti modificabili dopo i test.

Aggiornamento del 27 settembre 2026: attacco base, spazzata, passiva, sei potenziamenti a punti livello, catalogo Gold individuale, Ability Power, super/ultracritici, Multi Hit e Multi Cast sono implementati e verificati. Gli acquisti Chrono delle due ripetizioni attendono ancora i costi di design. Il bilanciamento è iniziale; vedere [danno comune](../../implementation/DANNO_E_CRITICI.md), [Multi Hit e Multi Cast](../../implementation/MULTI_HIT_E_MULTI_CAST.md) e [prima tappa](../../implementation/PRIMA_TAPPA.md).

## Decisioni confermate dal giocatore

- Nome provvisorio: **John the Meatball**, concept Spaghetti Golem; specie dell'unità iniziale.
- Classe **Warrior**, mischia con equilibrio fra danno e resistenza; obiettivo: affrontare da solo le prime ondate.
- Rarità **COMMON**, mostrata come **Common**.
- **Meatball Punch**: attacco normale fisico su un bersaglio.
- **Spaghetti Sweep**: abilità fisica ad area davanti a sé.
- Passiva per il test: si cura del **10% ogni 5 attacchi base**. L'interpretazione operativa sotto usa la vita massima.
- **Nessuna evoluzione nella prima tappa.** L'aspetto attuale potrà essere uno stadio successivo in futuro; questo non introduce ora uno stadio precedente o un percorso evolutivo.
- Ritratto v1 approvato. Testi e nomi mostrati nel gioco in inglese.

## Identità visiva e contenuti

Corpo di spaghetti, pugni a polpetta, armatura di vetro e metallo, cuore visibile, gambe corte di legno. Resa 2D materica e sagoma leggibile; altezza indicativa 220 px nella composizione di riferimento, indipendente dalle statistiche.
- [Direzione visiva](../10_DIREZIONE_VISIVA_E_UI.md).
- [Ritratto v1](../../../assets/portraits/john_the_meatball_portrait_v1.png), condiviso dai pannelli del bestiario e delle unità possedute; [prompt](references/john_portrait_v1.md).
- [Studio delle pose](references/john_key_poses_v2.png): concept, non sprite sheet validata. Corsa, continuità degli arti e animazioni complete restano da produrre/verificare.

## Statistiche iniziali — livello 1, senza acquisti

| Statistica | Valore |
| --- | ---: |
| Maximum Health | 300 HP |
| Physical Attack | 30 |
| Magic Attack | 0 |
| Armor | 20 |
| Magic Resistance | 10 |
| Attack Speed | 1 attacco/s |
| Range | 140 unità logiche |
| Movement Speed | 120 unità logiche/s |
| Engagement Radius | 260 unità logiche |
| Ability Haste | 0 |
| Ability Power | 0 punti bonus |
| Area bonus | 0% |
| Critical Chance / Damage | 5% / ×1,5 |
| Super Critical Chance / Damage | 0% / ×2 |
| Ultra Critical Chance / Damage | 0% / ×2 |
| Multi Hit / Multi Cast | 1 / 1 |
| Contributi individuali Gold / XP / Soul Points | 0 / 0 / 0 |

Bonus additivi non elencati: 0; moltiplicatori aggiuntivi: ×1. Nessuna rigenerazione ordinaria. Un livello concede il punto previsto dalle regole comuni, senza crescita automatica aggiuntiva delle statistiche in questa configurazione.

Movement Speed è il valore iniziale assegnato a ciascuna copia, modificabile individualmente; il raggio è per specie. Le distanze sono coordinate logiche del campo, da tarare sulla geometria dell'arena; non pixel dello sprite o della finestra. Postura iniziale mobile e priorità iniziale nemico più vicino, secondo [Movimento](../04_MOVIMENTO_ALLEATO.md). John è schierabile sul lato alleato; nessun ruolo sul lato nemico in questa tappa.

## Basic Attack — Meatball Punch

- Disponibile dal livello 1. Bersaglio: un nemico combattente attaccabile entro il Range attuale, secondo la priorità della copia.
- Danno per colpo prima di critici e difese: **100% del Physical Attack attuale**, quindi **30** iniziali. Nessuna componente magica.
- Ciclo: **1 / Attack Speed** secondi; inizialmente **1 s**, primo impatto al termine del ciclo completo. Nessun proiettile.
- Attacco da fermo. Perdita di validità del bersaglio o precedenza di un'abilità interrompono il ciclo secondo le regole comuni.
- Supporta critico, supercritico, ultracritico e multi hit. Verifica critica indipendente per ogni colpo; le ripetizioni seguono le regole comuni e non aggiungono tempo.
- Ability Power, AoE e multi cast non modificano l'attacco normale.
- Il precedente riferimento grafico di 0,67 s non è il tempo di gameplay: adattare l'animazione al ciclo e collocare l'impatto alla fine. Il ritorno visivo non deve aggiungere un ritardo obbligatorio fra cicli.

## Active Ability — Spaghetti Sweep

Disponibile e sbloccata dal livello 1; pronta all'inizio della run.

| Parametro | Valore iniziale |
| --- | --- |
| Danno fisico per bersaglio | 150% del Physical Attack = 45 |
| Portata di acquisizione | Range attuale di John, inizialmente 140 |
| Forma | Settore circolare frontale di 120° |
| Raggio dell'area | 180 unità logiche |
| Esecuzione | 0,6 s |
| Momento dell'effetto | Fine esecuzione |
| Cooldown base | 8 s, a partire da fine esecuzione |
| Bersagli colpiti | Tutti i nemici combattenti nel settore, ciascuno una volta per applicazione |

**Geometria specifica:** vertice del settore nella posizione attuale di John. All'inizio sceglie un nemico con la priorità della copia; alla fine orienta il settore verso la posizione attuale di quel bersaglio. Se bersaglio e John coincidono, usa l'ultimo orientamento valido. Questa geometria sostituisce per questa abilità l'area circolare centrata sul bersaglio predefinita. I centri dei nemici determinano l'inclusione, bordi compresi.

Il range si verifica all'avvio. Un bersaglio che si allontana non cancella il lancio, ma viene colpito solo se si trova effettivamente nel settore all'applicazione: non si estende l'area per inseguirlo. Se muore o scompare, una sola ricerca sostitutiva secondo le regole comuni; senza sostituto il lancio termina senza effetto e consuma il cooldown.

**Scaling:**
- Danno prima di critici/difese = Physical Attack × coefficiente della spazzata × (1 + Ability Power / 100). Qui ogni punto di Ability Power vale +1% al danno della spazzata; non alla passiva o all'attacco normale.
- I bonus di superficie dell'area si sommano nel rispettivo pool. Il raggio diventa 180 × sqrt(1 + bonus_area), mantenendo 120°. Range e area restano indipendenti.
- Cooldown effettivo = cooldown base / (1 + Ability Haste / 100). Haste non accorcia l'esecuzione.
- Può crittare a tutti e tre gli stadi. Una catena critica per bersaglio per applicazione; ogni applicazione ha verifiche indipendenti.
- Compatibile con multi cast: al termine della stessa esecuzione applica il settore tante volte quanto il valore Multi Cast, inizialmente una, massimo due con il potenziamento comune della demo. Stessa geometria fissata, nessun nuovo puntamento. Applicazioni nello stesso istante, risolte in ordine sui nemici ancora vivi, un solo cooldown e nessun tempo extra. Nessun contributo al contatore della passiva.
- Multi hit non modifica questa abilità. Nessuno stordimento, rallentamento o respingimento nella prima tappa.

## Passive — Hearty Rhythm

Disponibile dal livello 1. Testo base: **"Every 5 completed basic attacks, restore 10% of your maximum Health."**

Interpretazione operativa iniziale:
- Contatore individuale 0–4. Un ciclo di attacco normale con almeno un colpo risolto su un bersaglio valido aggiunge **1**, anche se il bersaglio muore per quel colpo. Un attacco interrotto non conta.
- Multi hit conta una sola volta per ciclo, indipendentemente dal numero di colpi o uccisioni. Spaghetti Sweep e multi cast non contano.
- Al quinto attacco cura John del **10% della sua vita massima attuale** (30 HP iniziali), poi azzera il contatore. Nessuna animazione bloccante o tempo di esecuzione; breve pulsazione del cuore.
- Il contatore si consuma anche a vita piena; la cura eccedente si perde. Nessuno scudo, overheal, critico o resurrezione. Ability Power e Haste non la modificano.
- Cure e danni simultanei rispettano la regola comune: un danno letale nello stesso istante non viene annullato dalla cura.
- Il contatore resta fra ondate vinte, cambi di bersaglio, spostamenti e pause; non avanza senza attacchi. Si azzera alla morte e al Chrono break. Dopo resurrezione riparte da zero.
- È stato temporaneo della copia incluso nello snapshot d'inizio tentativo: alla sconfitta si ripristina il valore registrato, insieme allo stato previsto dalle regole comuni.

## Primi potenziamenti con punti livello

Configurazione iniziale scelta su delega del giocatore. Per grado r (partendo da 1), costo = C0 + incremento × (r − 1). Le soglie indicate si applicano ai rispettivi gradi. Non esistono esclusioni fra acquisti.

| Nome | Effetto per grado | Gradi | C0 / incremento | Livelli richiesti |
| --- | --- | ---: | --- | --- |
| Heavy Meatballs | +10 punti percentuali al coefficiente di Meatball Punch (100% → 130%) | 3 | 1 / 1 | 2, 5, 8 |
| Wide Sweep | +15% superficie base della spazzata, nello stesso pool additivo dei bonus AoE | 3 | 1 / 1 | 3, 6, 9 |
| Crushing Sweep | +15 punti percentuali al coefficiente della spazzata (150% → 195%) | 3 | 1 / 1 | 3, 6, 9 |
| Quick Stir | −0,5 s al cooldown base della spazzata, prima di Haste (8 → 6,5 s) | 3 | 2 / 1 | 5, 8, 11 |
| Reinforced Glass | +20% agli incrementi di vita e armatura acquistati con Gold per questa copia | 5 | 1 / 1 | 2, 4, 6, 8, 10 |
| Strong Noodles | +20% agli incrementi di attacco fisico acquistati con Gold per questa copia | 5 | 1 / 1 | 2, 4, 6, 8, 10 |

Per gli ultimi due acquisti il contributo degli acquisti Gold individuali viene moltiplicato per (1 + 0,20 × gradi), retroattivamente e anche per acquisti futuri. Non amplificano statistiche base, shop globale o Chrono shop. Un aumento della vita massima non cura. Heavy Meatballs e Crushing Sweep modificano il coefficiente dell'azione, non Physical Attack.

La passiva resta fissa a 10% ogni 5 attacchi per isolarne la prova. Nessun acquisto di frequenza o percentuale di cura in questa tappa. Prezzi e incrementi del catalogo Gold condiviso e del Chrono shop restano nella progettazione economica comune: questa scheda definisce i primi acquisti con punti livello richiesti per John.

Senza evoluzioni non è previsto un reset dei punti in gioco; modificare i dati di test non introduce una funzione di redistribuzione per il giocatore.

## Controlli numerici e test ancora necessari

Controlli aritmetici di riferimento, senza simulazione:
- Punch non critico contro Armor 0: 30; contro Armor 20: 25.
- Sweep base contro Armor 0: 45 per bersaglio, quindi 135 su tre bersagli.
- Passiva: 30 HP ogni cinque cicli completati. Cinque secondi è il minimo iniziale con attacchi continui, senza abilità, movimento o interruzioni.
- Armor 20 riduce il danno fisico di circa 16,67%; Magic Resistance 10 riduce quello magico di circa 9,09%.
- Wide Sweep al grado 3: superficie ×1,45, raggio circa 216,75; non 261.
- Eseguita una prima prova di combattimento con nemici e geometria provvisori; non costituisce un bilanciamento completo. Verifiche aggiornate nelle pagine di implementazione.

Verificare in implementazione: cinque attacchi e cura, multi hit senza doppi incrementi, interruzioni, cura a vita piena, morte simultanea, snapshot del contatore, settore e bersaglio fuori area, multi cast, scaling e sincronizzazione delle animazioni.

## Dipendenze e questioni aperte

Regole comuni: [Movimento](../04_MOVIMENTO_ALLEATO.md), [Combattimento](../05_COMBATTIMENTO_E_ABILITA.md), [Economia](../07_ECONOMIA_E_POTENZIAMENTI.md), [Ondate](../06_ONDATE_ED_ESITI.md).

La prima configurazione della specie è definita per avviare una prova; restano bilanciamento con i nemici, produzione delle animazioni e implementazione. L'eventuale precedente stadio evolutivo è un'idea futura, non contenuto confermato. Le altre cinque specie restano da progettare.
