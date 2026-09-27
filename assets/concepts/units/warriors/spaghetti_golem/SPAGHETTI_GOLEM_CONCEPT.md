# Spaghetti Golem — concept completo dell’unità

**Progetto:** IncrementalGame · **Tipo:** unità alleata · **Classe proposta:** Warrior · **Rarità proposta:** Rare · **Stato:** proposta di game design, non specifica già approvata o implementata.

Questo documento riunisce il concept in solo testo. I nomi, le descrizioni e le frasi rivolte al giocatore sono in inglese; le note progettuali sono in italiano. Le soglie, i valori e i limiti specifici dell’unità sono **provvisori** e vanno confrontati con le regole generali e il resto del roster. Il massimo di un attacco base, tre attive e due passive è un limite proposto dal brief, ancora da confermare.

## 1. Sintesi e ruolo

> **“A heart of sauce. A body of noodles. An unstoppable appetite for battle.”**

Spaghetti Golem è un guerriero da prima linea costruito con spaghetti intrecciati, pugni di polpetta coperti di sugo, gambe minuscole di legno e armatura trasparente che lascia vedere un cuore rosso. Colpisce in mischia, genera **Sauce** con le azioni offensive, migliora attacco, armatura e rigenerazione mentre la risorsa cresce e, se rischia di morire, ne consuma una parte per curarsi e potenziarsi.

| Campo | Proposta |
|---|---|
| Specie/concept | Golem di spaghetti con cuore di sugo visibile nel vetro |
| Classe e danno | Warrior; danno fisico |
| Portata e posizione | Mischia; prima linea |
| Ruolo principale | Combattente resistente negli scontri prolungati |
| Ruolo secondario | Autosostentamento e danno ad area moderato |
| Rarità | Rare: kit distintivo ma con condizioni automatiche leggibili |
| Complessità | Media |
| Meccanica distintiva | Sauce personale: accumulo, bonus per stack e consumo d’emergenza |

La scelta di squadra è schierare una fonte di pressione fisica che si sostiene da sola dopo avere raggiunto i nemici. Parte con meno potere a ogni ondata, soffre gli scoppi di danno prima di generare Sauce e non sostituisce un Tank che protegge gli alleati.

## 2. Identità visiva

La forma finale riprende il riferimento allegato: massa di spaghetti chiari annodati in braccia e torso, grossi pugni di polpetta sotto uno strato di marinara rossa che gocciola, piccole gambe rigide di legno, corazza blu grigia con bordi metallici e torace di vetro. Dentro il torace è visibile un cuore rosso luminoso; il volto è suggerito dalla sagoma della corazza. La silhouette deve restare riconoscibile nella vista laterale del campo 2D: cuore e pugni sono le due priorità di lettura, poi la differenza cromatica tra pasta, sugo, armatura e legno. Il concept di riferimento presenta viste frontale, laterale e posteriore, oltre a dettagli di materiali e posa idle.

| Forma | Silhouette e materiali | Segno narrativo |
|---|---|---|
| **Noodle Squire** | Piccolo e goffo, pochi fasci di spaghetti, polpette ridotte, piedi di legno, nessuna armatura | Macchia di sugo sul petto; cuore non ancora visibile |
| **Saucebound Knight** | Torso e pugni più pieni, spallacci e protezioni di metallo, gambe rinforzate | Piccola finestra di vetro con sagoma incompleta del cuore |
| **Spaghetti Golem** | Silhouette ampia, grandi pugni grondanti sugo, corazza completa di metallo e vetro | Cuore rosso luminoso immediatamente leggibile |

Segnali di stato: una patina rossa lucida identifica **Sauce Guard**; il cuore che si accende e impulsi rossi che attraversano i noodles identificano **Glassheart Surge**; piccoli movimenti del sugo accompagnano i tick di **Slow Simmer**. La UI dovrebbe mostrare gli stack di Sauce da 0 a 5, il buff attivo e i cooldown delle abilità sbloccate.

### Prompt testuali per nuovi concept

Questi prompt sono testo facoltativo per creare asset futuri; nessuna immagine è inclusa in questo file.

**Noodle Squire:** “Full-body stylized fantasy game character concept art of a small living spaghetti warrior, loosely intertwined pasta body, two small meatball fists covered in dripping marinara sauce, tiny wooden peg legs, small red tomato sauce core on its chest, no armor, determined but slightly clumsy personality, warm pasta colors, readable silhouette, three-quarter front view, dark neutral background, hand-painted game character design. First evolutionary stage of a spaghetti golem.”

**Saucebound Knight:** “Full-body stylized fantasy game character concept art of an evolving spaghetti golem knight, dense intertwined noodle body, medium-sized meatball fists covered in thick marinara sauce, reinforced wooden peg legs, partial medieval steel and brass armor, small transparent glass breastplate revealing a developing glowing red heart, noodle strands emerging from the armor joints, heroic but slightly comical proportions, three-quarter front view, dark neutral background, matching a final evolution with full glass armor and a prominent tomato-red heart, hand-painted game character design.”

**Spaghetti Golem:** “Full-body side-view-ready fantasy game character concept of a spaghetti golem, dense ivory noodle body and arms, enormous meatball fists dripping crimson tomato sauce, tiny wooden peg legs, blue-gray metal and transparent glass breastplate framing a vivid glowing red heart, sauce and noodles visible through the armor, heavy but slightly comic silhouette, clear shapes at small sprite size, hand-painted material detail, neutral dark background. Preserve the meatball hands, glass armor, visible heart and tiny wooden legs of the supplied reference.”

## 3. Statistiche iniziali e risorsa

Valori proposti per **Noodle Squire al livello 1, senza acquisti**. L’evoluzione non aumenta direttamente queste statistiche base; ciascuna copia mantiene livelli, XP, punti e acquisti propri.

| Statistica | Valore | Uso nel kit |
|---|---:|---|
| Maximum Health | 320 HP | Sopravvivenza e cure percentuali |
| Physical Attack | 20 | Attacco base, Sweep e bonus temporanei |
| Magic Attack | 0 | Nessuno diretto |
| Armor / Magic Resistance | 12 / 12 | Difese; Armor riceve bonus personali |
| Attack Speed | 1,0 attacchi/s | Ritmo dell’attacco base |
| Attack Range | 1,3 unità | Portata del pugno |
| Movement Speed | 2,2 unità/s | Avvicinamento |
| Engagement Radius | 3,5 unità | Zona di movimento in postura Mobile |
| Ability Power (AP) | 20 | Componente fissa delle cure |
| Ability Haste / Bonus Area | 0 / 0% | Eventuali miglioramenti comuni |
| Critical Chance / Multiplier | 5% / 150% | Attacchi offensivi |
| Super Critical Chance / Multiplier | 0% / 200% | Solo se previsto dalle regole comuni |
| Ultra Critical Chance / Multiplier | 0% / 250% | Solo se previsto dalle regole comuni |
| Multi Hit / Multi Cast | 0% / 0% | Ripetizioni offensive secondo regole del gioco |
| Bonus individuale Gold / XP / Souls | 0% / 0% / 0% | Nessun bonus economico nel kit |

### Sauce

La risorsa appare con la seconda forma, quando si sblocca **Sauce Reserve**.

| Regola | Proposta |
|---|---|
| Valore iniziale e massimo | 0 / 5 stack |
| Meatball Jab | +1 se l’azione originale colpisce almeno un nemico |
| Meatball Sweep | +1 se l’attivazione originale colpisce almeno un nemico |
| Sauce Guard | Richiede almeno 2 stack; non ne consuma |
| Glassheart Surge | Richiede e consuma 4 stack all’effetto |
| Decadimento durante la stessa ondata | Nessuno |
| Nuova ondata, morte, sconfitta, Chrono break | Riporta Sauce a 0; il comportamento degli altri sistemi segue le regole comuni |
| Copie multiple | Contatori indipendenti |

Si conta **una generazione per azione originale riuscita**, non una per colpo o per bersaglio: Multi Hit, bersagli multipli e Multi Cast offensivo non aumentano la generazione della stessa attivazione. Il colpo mancato non genera Sauce. La risorsa resta personale e non viene trasferita ai compagni.

## 4. Attacco base — Meatball Jab

> **“Punches an enemy with a massive meatball fist, dealing Physical Damage.”**

Disponibile in tutte le forme. Colpisce un nemico scelto con la priorità di bersaglio impostata dal giocatore; proposta iniziale: il più vicino. Danno normale prima delle difese: **100% Physical Attack**. Portata 1,3 unità, ciclo iniziale 1,0 s, impatto 0,25 s dall’avvio. Il braccio di spaghetti si allunga e il pugno di polpetta arriva direttamente al bersaglio; l’unità si ferma durante il colpo. Può infliggere critici e beneficiare di Multi Hit secondo le regole generali.

La validità del bersaglio e la portata sono ricontrollate all’impatto. Se il bersaglio muore, scompare o esce dalla portata prima di quel momento, l’azione termina senza danno né Sauce. Dalla seconda forma in poi, un attacco originale riuscito genera uno stack; eventuali colpi ripetuti non ne generano altri. Una nuova decisione è presa solo alla fine dell’azione.

## 5. Abilità attive

### Active 1 — Meatball Sweep

> **“Swings both meatball fists in a wide arc, dealing Physical Damage to nearby enemies.”**

Si sblocca nella prima forma. È l’attacco ad area che permette al golem di contribuire contro gruppi e, dalla seconda forma, di costruire Sauce.

| Parametro | Forma I e II | Forma III |
|---|---:|---:|
| Danno per bersaglio prima delle difese | 130% Physical Attack | 150% Physical Attack |
| Raggio | 1,6 unità | 1,8 unità |
| Geometria | Arco frontale di 180° | Arco frontale di 180° |
| Bersagli massimi | 3 | 3 |
| Cooldown | 8 s | 8 s |
| Esecuzione / impatto | 0,6 s / 0,4 s | 0,6 s / 0,4 s |
| Sauce | Nessuno in I; +1 in II se almeno un bersaglio colpito | +1 se almeno un bersaglio colpito |

Attivazione automatica se il cooldown è pronto e almeno un nemico è nell’area prevista. All’inizio dell’azione si orienta verso il bersaglio selezionato; all’impatto si verificano i nemici ancora presenti nell’arco. Il danno e i critici si calcolano separatamente per bersaglio. Un Multi Cast offensivo può ripetere il danno secondo le regole comuni, ma non genera altro Sauce per la medesima attivazione. Bonus Area può modificare il raggio solo secondo le regole condivise e va verificato contro la geometria dell’arco. L’unità resta ferma nell’esecuzione.

### Active 2 — Sauce Guard

> **“Coats its armor in protective sauce, restoring Health and increasing its combat strength.”**

Si sblocca con **Saucebound Knight**. Si attiva automaticamente con **HP ≤70%**, **Sauce ≥2**, cooldown pronto e buff non già attivo. Bersaglio: solo sé. Esecuzione 0,35 s; all’effetto cura istantaneamente **3% Maximum Health + 25% AP**, poi per **6 s** dà **+12% Armor**, **+10% Physical Attack** e moltiplica per **2** la quantità curata dai tick di Slow Simmer, senza aumentarne la frequenza. Cooldown iniziale proposto: pronto; cooldown successivo: **12 s** dall’effetto. Sauce non viene consumata. Non è soggetta a critici, Multi Hit o Multi Cast.

Il buff non si accumula con se stesso: non può essere rilanciato mentre è attivo. Gli stack ottenuti durante la durata continuano a migliorare le passive. L’effetto visivo è uno strato lucido di sugo sulla corazza; il feedback della cura è distinto da quello della rigenerazione periodica.

### Active 3 — Glassheart Surge

> **“Unleashes the power of its molten heart, consuming Sauce to restore Health and empower itself.”**

Si sblocca con **Spaghetti Golem**. Si attiva automaticamente con **HP ≤35%**, **Sauce ≥4** e cooldown pronto. Ha priorità su Sauce Guard quando entrambe sono disponibili al momento della decisione. Bersaglio: solo sé. Esecuzione 0,5 s; all’effetto consuma **4 Sauce**, cura **8% Maximum Health + 50% AP** e per **5 s** concede **+20% Physical Attack** e **+15% Armor**. Cooldown iniziale proposto: pronto; cooldown successivo: **24 s** dall’effetto. Non è soggetta a critici, Multi Hit o Multi Cast.

Il buff non si accumula con se stesso. Può coesistere con Sauce Guard. Il cuore si illumina, poi un impulso rosso attraversa noodles e pugni. La cura non rende invulnerabili: un’unità già morta non può lanciare l’abilità. Dopo il consumo i bonus conferiti dagli stack rimasti vengono ricalcolati subito.

### Regole comuni per le attive

- Le condizioni si valutano quando l’unità può scegliere una nuova azione. Un’azione già iniziata si completa; la comparsa di una condizione d’emergenza non la interrompe automaticamente.
- Prima dell’effetto, un’interruzione causata da morte o da una regola generale di controllo annulla l’effetto senza avviare il cooldown. Dopo l’effetto, costo e cooldown restano applicati. Nessuna abilità cura dopo la morte.
- Le abilità personali controllano di nuovo i requisiti all’effetto. Per Glassheart Surge, se Sauce è scesa sotto 4, non avviene consumo né effetto; il comportamento preciso di un’interruzione esterna segue le regole comuni del motore.
- Bonus percentuali personali a Physical Attack e Armor di Sauce Reserve, Sauce Guard e Glassheart Surge si sommano sulla statistica pertinente della copia, con limiti iniziali proposti di **+35% Physical Attack** e **+40% Armor**. Gli incrementi dei potenziamenti sono inclusi in questi limiti. Le regole di arrotondamento e degli altri buff sono ancora da definire a livello di gioco.
- Per ridurre uptime eccessivo con Ability Haste, cooldown minimi proposti: Sweep **4 s**, Guard **8 s**, Surge **16 s**. Il calcolo del cooldown con Haste resta quello comune.

## 6. Abilità passive

### Passive 1 — Slow Simmer

> **“The warmth of its sauce slowly restores Health over time.”**

Disponibile dalla prima forma. Cura solo la copia viva **una volta ogni 4 s**, senza bersaglio esterno e senza generare Sauce. Ogni tick usa gli HP massimi, AP e stack correnti; Sauce Guard raddoppia la cura del tick, non la frequenza. La cura è limitata dalla salute mancante. A HP pieni il tick non produce cura effettiva; a morte non avviene. Non attiva se stessa né altre passive e non interagisce con critici, Multi Hit o Multi Cast.

| Forma | Cura per tick, prima del limite degli HP massimi |
|---|---|
| Noodle Squire | 1,5% Max HP + 0,10 AP |
| Saucebound Knight | (1,5% + 0,25% × Sauce) Max HP + 0,10 AP |
| Spaghetti Golem | (2% + 0,25% × Sauce) Max HP + 0,10 AP |

Proposta di temporizzazione: il contatore del tick parte all’inizio di ciascuna ondata, viene azzerato alla morte e riparte secondo la regola comune di un’eventuale resurrezione. Il buff di Guard moltiplica un tick solo se è attivo quando questo si risolve. Ogni copia possiede il proprio timer.

### Passive 2 — Sauce Reserve

> **“Successful attacks build Sauce, increasing Physical Attack, Armor, and Health regeneration.”**

Si sblocca con Saucebound Knight. Conta il successo dell’**azione originale** di Meatball Jab o Meatball Sweep: +1 Sauce, massimo 5. Ogni stack conferisce **+1% Physical Attack** e **+1% Armor**, mentre la componente **+0,25% Max HP per tick** è applicata tramite la formula di Slow Simmer, senza una seconda cura separata. A cinque stack il bonus alle due statistiche è +5%. I colpi aggiuntivi, i bersagli multipli, le uccisioni, i danni periodici e le attivazioni di passive non producono ulteriori stack. Non esiste cooldown interno oltre al limite di una generazione per azione originale. Risorsa, buff e timer sono individuali per copia; la morte azzera Sauce.

## 7. Ciclo e comportamento automatico

**Ciclo di combattimento:** Jab e Sweep colpiscono → Sauce Reserve accumula fino a 5 → aumentano attacco, armatura e cure di Slow Simmer → con HP bassi Sauce Guard cura e rafforza la copia senza spendere Sauce → in emergenza Glassheart Surge ne consuma 4 → si torna a colpire per ricostruire la risorsa.

| Priorità | Azione | Condizione aggiuntiva |
|---:|---|---|
| 1 | Glassheart Surge | Forma III; HP ≤35%; Sauce ≥4; cooldown pronto |
| 2 | Sauce Guard | Forma II o III; HP ≤70%; Sauce ≥2; buff assente; cooldown pronto |
| 3 | Meatball Sweep | Almeno un nemico nell’arco; cooldown pronto |
| 4 | Meatball Jab | Bersaglio valido entro 1,3 unità |
| 5 | Movimento | Avvicinarsi a un nemico valido, se la postura lo consente |
| 6 | Attesa/rientro | Nessuna azione disponibile |

Schieramento consigliato: **frontline**, priorità del bersaglio **Nearest Enemy**, postura **Mobile**. In Mobile, si muove entro la zona di ingaggio circolare di raggio 3,5 unità centrata sul suo slot; in **Hold Slot**, mantiene lo slot e attende l’ingresso del nemico nella portata. Raggio d’ingaggio, portata dell’attacco e raggio dello Sweep restano parametri distinti. Il bersaglio scelto segue la priorità impostata dal giocatore; il cambio di bersaglio avviene alle nuove decisioni o quando quello corrente non è più valido. Se non trova bersagli raggiungibili, applica le regole comuni di attesa e rientro allo slot.

## 8. Potenziamenti individuali e Gold

Ogni livello assegna un punto spendibile secondo le regole del gioco. I quattro acquisti qui proposti costano **1 punto livello per grado** e modificano la singola copia. Un’evoluzione amplia il massimo acquistabile, senza assegnare automaticamente i nuovi gradi o incrementare le statistiche base. Gradi già acquistati restano validi; i successivi usano lo stesso incremento. Le soglie di livello degli acquisti non hanno ulteriori requisiti oltre all’evoluzione e ai punti disponibili.

| Potenziamento | Effetto di ogni grado | Massimo I / II / III |
|---|---|---|
| **Sauce Infusion** | +0,25 punti percentuali di Max HP alla componente base di ogni tick Slow Simmer | 1 / 2 / 3 |
| **Meatball Training** | +8 punti percentuali al coefficiente Physical Attack di Sweep | 1 / 2 / 3 |
| **Thickened Glaze** | +2 punti percentuali al bonus Armor di Sauce Guard | Bloccato / 2 / 3 |
| **Core Tempering** | +1 punto percentuale di Max HP alla cura istantanea di Glassheart Surge | Bloccato / bloccato / 2 |

Ordine proposto: aggiungere i gradi al coefficiente o al bonus dell’abilità, calcolare usando le statistiche correnti della copia e applicare gli eventuali limiti di buff e di salute. Per esempio, forma III con Meatball Training grado 3: Sweep passa da 150% a **174% Physical Attack**; con Sauce Infusion grado 3: Slow Simmer guadagna **+0,75% Max HP per tick**; con Thickened Glaze grado 3: Guard concede **+18% Armor**, soggetto al limite totale; con Core Tempering grado 2: Surge cura **10% Max HP + 50% AP**. Un acquisto di Gold a metà buff deve essere ricalcolato secondo la regola comune, da definire.

Le statistiche del catalogo comune più utili sono Maximum Health, Physical Attack, Armor, Ability Power, Attack Speed e, entro i limiti, Ability Haste e Bonus Area. Magic Attack e i bonus Gold/XP/Souls non modificano direttamente il kit. Critici e ripetizioni offensive migliorano il danno nei limiti delle regole comuni, senza moltiplicare Sauce o le cure. Il Chrono break conserva soltanto ciò che la progressione generale del gioco prevede; non introduce eccezioni specifiche per l’unità.

Due esempi di investimento nella stessa evoluzione finale: una copia difensiva può scegliere Sauce Infusion 3 e Thickened Glaze 3; una copia che privilegia l’attacco ad area può scegliere Meatball Training 3 e usare Core Tempering 2 come recupero d’emergenza. Le copie mantengono progressione, Sauce, cure, buff e cooldown separati.

## 9. Evoluzioni facoltative

| Forma | Soglia proposta | Kit disponibile | Modifiche principali |
|---|---:|---|---|
| **Noodle Squire** | Inizio | Jab; Sweep; Slow Simmer | Primo guerriero di pasta, cura base senza Sauce |
| **Saucebound Knight** | Livello 10 | Jab; Sweep; Guard; Slow Simmer; Sauce Reserve | Introduce Sauce, difesa condizionale, miglioramento della passiva |
| **Spaghetti Golem** | Livello 25 | Jab; Sweep; Guard; Surge; Slow Simmer; Sauce Reserve | Completa cuore e corazza; migliora Sweep e Slow Simmer; aggiunge Surge |

Le soglie 10 e 25 sono indicative e le evoluzioni sono facoltative. Nessun ramo alternativo è proposto. La forma finale resta entro **1 attacco base, 3 attive, 2 passive**. I miglioramenti di Sweep e Slow Simmer sostituiscono le rispettive versioni precedenti e non occupano nuovi slot. L’evoluzione sblocca abilità e massimi dei potenziamenti individuali; non aggiunge statistiche base.

## 10. Esempi numerici e bilanciamento

**Ipotesi:** forma finale con le statistiche iniziali 320 Max HP, 20 Physical Attack e 20 AP, senza acquisti, senza difese avversarie, critici o buff se non specificati. Questi risultati sono **calcoli aritmetici**, non una simulazione. Gli esempi a Sauce 5 indicano uno stato già raggiunto in combattimento.

| Situazione | Calcolo | Risultato |
|---|---:|---:|
| Jab senza bonus | 100% × 20 | 20 danni a un bersaglio |
| Sweep finale senza bonus | 150% × 20 | 30 per bersaglio, fino a 90 su tre |
| Jab con Sauce 5 | 100% × (20 × 1,05) | 21 |
| Sweep finale con Sauce 5 | 150% × (20 × 1,05) | 31,5 per bersaglio |
| Slow Simmer finale con Sauce 5 | 3,25% × 320 + 10% × 20 | 12,4 HP ogni 4 s |
| Lo stesso tick durante Guard | 12,4 × 2 | 24,8 HP |
| Cura istantanea di Guard | 3% × 320 + 25% × 20 | 14,6 HP |
| Cura istantanea di Surge | 8% × 320 + 50% × 20 | 35,6 HP |

Con Sauce 5, Guard e Surge attivi, la somma **potenziale** dei bonus personali di Physical Attack è 5% + 10% + 20% = **35%**; per Armor è 5% + 12% + 15% = **32%** prima dei potenziamenti. **Surge consuma prima quattro stack:** se parte da 5, subito dopo l’attivazione Sauce è 1 e i bonus effettivi delle tre fonti sono **31% Physical Attack** e **28% Armor**. Si può tornare al 35% solo ricostruendo Sauce fino a 5 mentre entrambi i buff sono ancora attivi. Il limite iniziale Armor del 40% governa anche Thickened Glaze.

Al ritmo base di Jab, partendo da Sauce 0, cinque attacchi originali riusciti richiedono circa cinque cicli d’attacco, con il primo impatto a 0,25 s; uno Sweep pronto che colpisce può aggiungere uno stack. Movimento, interruzioni, cooldown e bersagli possono allungare il tempo. La frequenza effettiva di Slow Simmer dipende dal calendario dei tick e dalla durata dei buff: Guard dura 6 s, quindi può coprire uno o due tick a seconda dell’istante di attivazione, non garantisce due tick.

| Rischio | Controllo proposto |
|---|---|
| Attack Speed elevata | Massimo 5 Sauce; un solo stack per azione originale |
| Multi Hit e Multi Cast elevati | Nessuna generazione extra; niente Multi Cast per le due attive difensive |
| Ability Haste elevata | Cooldown minimi proposti 4 / 8 / 16 s |
| Buff e cure in combattimenti lunghi | Limiti ai bonus personali; cure limitate agli HP massimi; nessuna cura da morti |
| Diverse copie in prima linea | Risorse, buff, cure e cooldown indipendenti |
| Esplosioni di danno iniziali | Debolezza prevista: Sauce riparte da zero a ogni ondata |

Punti di forza: combattimenti lunghi, gruppi ravvicinati, autonomia parziale dagli Healer, pressione fisica che cresce con gli attacchi. Debolezze: deve raggiungere e colpire i nemici, non controlla né protegge direttamente gli alleati, soffre danni concentrati e reset di Sauce tra ondate. Funziona accanto a un Tank che assorbe i primi colpi, ad altri Warrior che mantengono la pressione o a un Healer che copre l’apertura. Più copie aumentano il sustain della frontline senza condividere la risorsa.

## 11. Animazioni, asset e sistemi tecnici

| Animazione/stato | Direzione visiva |
|---|---|
| Idle | Spaghetti che oscillano lentamente, sugo che gocciola |
| Movimento | Piccoli passi rigidi di legno; noodles trascinati dal moto |
| Jab | Braccio elastico e impatto della polpetta |
| Sweep | Due pugni in un arco frontale leggibile |
| Slow Simmer | Brevi bolle o pulsazioni di sugo sul corpo |
| Sauce Guard | Patina rossa sull’armatura e segnale di cura |
| Glassheart Surge | Cuore brillante, impulso rosso lungo gli spaghetti |
| Danno / morte | Corpo che si comprime; poi luce che si spegne e noodles che collassano |

Asset necessari per una realizzazione: sprite da campo per le tre forme e stati principali, illustrazione della scheda, icone di Sauce e delle abilità, effetti di impatto/cura/buff/cuore, suoni distinti di colpo e abilità, UI per cinque stack, buff e cooldown. Il riferimento allegato guida la forma finale; le forme precedenti sono proposte da produrre e verificare per leggibilità in vista laterale.

Secondo il brief, al **27 settembre 2026** il progetto Godot 4.7 gestiva già attacco base, Sweep e passiva curativa; lo stato attuale va verificato prima di pianificare il lavoro. Per questo concept potrebbero servire un contatore Sauce per copia, eventi di attacco originale riuscito, buff temporanei, trigger automatici a soglia HP, modificatore della cura periodica, sblocco e sostituzione di abilità alle evoluzioni, limiti di potenziamento per copia e indicatori UI. Queste sono necessità di implementazione, non funzionalità già presenti.

Verifiche prioritarie: bersaglio perso fra inizio e impatto, assenza di bersagli, più bersagli colpiti, Multi Hit e Multi Cast, morte e cura nello stesso istante, Guard e Surge pronti insieme, riattivazione durante un buff, acquisti durante un’azione, pausa/sconfitta/salvataggio/caricamento, cambio di ondata e Chrono break, sovrapposizione dei buff e limiti dei bonus. Le regole generali del gioco governano persistenza dei cooldown, XP, Gold e acquisti fra ondate e durante Chrono break.

## 12. Decisioni ancora da confermare

1. Limite globale del kit di 1 attacco base, 3 attive e 2 passive; rarità Rare e soglie evolutive 10/25.
2. Valori proposti di statistiche, coefficienti, cooldown, soglie HP, durata, cooldown minimi e limiti dei bonus dopo confronto con il roster.
3. Ordine globale di calcolo di buff, bonus comuni, acquisti, difese, critici e arrotondamenti; comportamento degli acquisti effettuati durante un buff.
4. Regole comuni di linea di vista, ripuntamento e ripetizioni Multi Cast offensive, interruzione, resurrezione e riavvio dei timer.
5. Persistenza dei cooldown e dei progressi attraverso ondate, sconfitta, caricamento e Chrono break secondo il sistema generale.

**In breve:** la prima forma possiede già Sweep e cura periodica; la seconda costruisce potere tramite Sauce e sblocca Guard; la terza rende il cuore il centro visivo e meccanico del personaggio con Surge. Il risultato proposto è un Warrior autosufficiente che trasforma la pressione offensiva in resistenza e spende parte del potere accumulato per tentare un recupero d’emergenza.
