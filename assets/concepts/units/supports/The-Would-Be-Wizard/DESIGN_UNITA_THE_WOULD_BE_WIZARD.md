# Unit Design — The Would-Be Wizard

Scheda di progettazione per **IncrementalGame**, consolidata dalla conversazione e dai cinque riferimenti visivi forniti.

**Versione:** 1.1 — 1 ottobre 2026.  
**Struttura:** segue le dodici sezioni richieste in «13. Formato della risposta» del file `PROMPT_DESIGN_UNITA(1)(1).md`, includendo i campi pertinenti delle altre sezioni del template.

## Stato del documento

- **Direzione consolidata:** percorso narrativo, cinque forme, identità dei due rami e concept dei kit riportati nell'ultima revisione della conversazione. I nomi sono quelli di lavoro usati nella revisione, non nomi definitivi di produzione.
- **Requisito esplicito:** ignorare i limiti dell'implementazione attuale; entrambe le forme finali hanno **1 attacco base, 3 attive e 2 passive** e devono offrire una power fantasy molto forte, coerente con il ramo.
- **Regola confermata di schieramento:** non possono esserci due unità dello stesso tipo contemporaneamente in campo. Le copie possono avere progressione indipendente nella collezione, ma questa non autorizza duplicati in formazione. Per questo personaggio il vincolo si applica anche alle sue diverse forme e ai due rami evolutivi.
- **Risorsa finale B confermata:** Setup evolve in **Misdirection**; basic e nemici ingannati alimentano una sola risorsa per potenziare il prossimo gadget. **Encore** resta la ricompensa separata per tre active differenti.
- **Provvisorio:** tutti i numeri usati nella conversazione come esempi, inclusi soglie, percentuali, durate, capacità delle risorse e cooldown interni. Non sono valori approvati di bilanciamento.
- **Da definire:** campi non risolti nella conversazione. Sono indicati esplicitamente, senza trasformare suggerimenti in decisioni già prese.
- **Proposta di formalizzazione:** regole aggiuntive suggerite qui per rendere verificabili le interazioni; richiedono conferma e non modificano retroattivamente le decisioni.

Le evoluzioni cambiano il kit e possono cambiare i limiti dei potenziamenti; **non aumentano direttamente le statistiche base**. La difficoltà di ottenere le forme finali non stabilisce automaticamente la rarità dell'unità nelle evocazioni.

---

## 1. Sintesi del personaggio

### 1.1 Contesto di gioco

Incrementale/idle 2D con combattimento automatico a ondate, collezione di unità e costruzione della squadra. Il giocatore sceglie copie, posizioni, posture, priorità offensive e investimenti in Gold e punti livello. Ogni copia possiede progressione e acquisti indipendenti. Il **Chrono break** riavvia le ondate conservando la progressione permanente secondo le regole generali del gioco.

**Una sola unità per tipo può essere schierata alla volta.** Possedere più copie consente alternative nella collezione, non lo schieramento simultaneo dello stesso personaggio. Grimoire Archsage e False Archmage sono alternative di evoluzione dello stesso tipo e non si schierano insieme.

Le abilità si attivano automaticamente. Il design aggiunge scelte di composizione, posizionamento e sinergia; non presuppone comandi manuali durante la battaglia.

### 1.2 Idea e fantasia

Un aspirante mago parte senza alcuna capacità magica e combatte con bastone, corpo a corpo e ostinazione. Il suo sviluppo si divide in due risposte allo stesso fallimento:

- **Ramo A:** impara davvero la magia curativa. Studio e annotazioni diventano capacità di correggere ferite, distribuire il rischio e recuperare danni recenti.
- **Ramo B:** non impara mai la magia. Costruisce marchingegni per simularla e ingannare gli altri; diventa un maestro di preparazione, diversivi e controllo del campo.

Il ramo B è una crescita autentica di competenza tecnica. Tutti i suoi effetti apparentemente soprannaturali devono avere una spiegazione fisica visibile nell'animazione.

### 1.3 Albero e budget del kit

| Stadio | Nome inglese di lavoro | Classe consigliata | Contributo principale | Basic / Active / Passive |
|---|---|---|---|---|
| 0 | **Reckless Apprentice** | Warrior | Pressione fisica corpo a corpo | 1 / 1 / 1 |
| 1A | **Grimoire Acolyte** | Healer | Cura singola e prima correzione futura | 1 / 1 / 1 |
| 2A | **Grimoire Archsage** | Healer | Gestione delle ferite e recupero di crisi | **1 / 3 / 2** |
| 1B | **Makeshift Wizard** | Ranged, da verificare con il basic melee | Gadget fisici su piccoli gruppi | 1 / 1 / 1 |
| 2B | **False Archmage** | Ranged | Diversivi e controllo del targeting | **1 / 3 / 2** |

Percorsi: **0 → 1A → 2A** oppure **0 → 1B → 2B**. La ramificazione avviene alla prima evoluzione; ogni ramo ha poi una propria evoluzione finale.

### 1.4 Identità di collezione

| Campo | Contenuto |
|---|---|
| Specie/concept | Personaggio umano, dal giovane apprendista all'anziano specialista |
| Lato di schieramento | Alleato; una versione nemica non è stata progettata |
| Rarità | Da definire; le forme finali devono essere difficili da raggiungere |
| Complessità | Bassa nello stadio 0, media nei primi rami, alta nelle forme finali |
| Introduzione | Stadio 0 pensato per l'early game; finali per progressione avanzata, senza soglie confermate |
| Meccanica distintiva A | Attaccare genera scrittura; la scrittura alimenta cura e correzioni future |
| Meccanica distintiva B | Preparare trucchi e sfruttare le reazioni nemiche genera nuovi vantaggi |
| Utilità di più copie | Progressioni indipendenti nella collezione; una sola copia del tipo in campo. Se l'evoluzione sarà per copia, copie in rami diversi offriranno alternative di formazione, non una sinergia simultanea |

**Descrizioni brevi proposte per la collezione, in inglese:**

| Forma | Descrizione |
|---|---|
| Reckless Apprentice | “An aspiring wizard who solves failed spells with a solid staff strike.” |
| Grimoire Acolyte | “A novice healer whose notes become tomorrow's remedies.” |
| Grimoire Archsage | “A master of living script who rewrites the party's wounds.” |
| Makeshift Wizard | “A resourceful impostor who turns handmade gadgets into convincing spells.” |
| False Archmage | “A master charlatan who turns the battlefield into an elaborate performance.” |

### 1.5 Scelta nella squadra

Lo stadio iniziale occupa uno slot da combattente fisico. Il ramo A converte quello slot in **sustain reattivo**, utile per Tank e alleati esposti a danni continui. Il ramo B lo converte in **protezione indiretta e disruption**, utile per squadre fragili che hanno bisogno di più tempo per attaccare.

Il picco del ramo A è “riscrivo la battaglia”. Quello del ramo B è “controllo ciò che credi stia accadendo”. Non attribuire al ramo A trappole o hard CC; non attribuire al ramo B cure o buff curativi classici.

---

## 2. Identità visiva e prompt per il concept

### 2.1 Uso dei riferimenti

Le immagini definiscono aspetto, età, materiali, equipaggiamento e direzione narrativa. **Gli esempi di spell presenti nelle immagini sono esclusi dal design**, come richiesto.

La corrispondenza seguente si basa sul contenuto effettivo delle immagini: i suffissi dei file non coincidono con le lettere assegnate ai rami nella scheda.

| Forma di design | Riferimento fornito | Contenuto visivo |
|---|---|---|
| 0 — Reckless Apprentice | `sregone_v0_stadio_0.png` | Apprendista irruento, giovane, bastone e libro chiuso |
| 1A — Grimoire Acolyte | `sregone_v0_stadio_1b.png` | Adepto del grimorio, libro aperto e vera magia |
| 2A — Grimoire Archsage | `sregone_v0_stadio_2b.png` | Mago anziano del grimorio, barba bianca e scrittura luminosa |
| 1B — Makeshift Wizard | `sregone_v0_stadio_1a.png` | Mago arrangiatore, attrezzi e primi trucchi |
| 2B — False Archmage | `sregone_v0_stadio_2a.png` | Anziano “Failed Wizard”, equipaggiamento tecnico sovraccarico |

### 2.2 Elementi comuni da preservare

- Grande cappello blu piegato e consumato, con richiami metallici e ornamenti pendenti.
- Palette blu e crema, cuoio marrone, dettagli rossi riconoscibili soprattutto nelle forme giovani.
- Tessuti vissuti, bordi sfrangiati, cinghie, stivali e bastone nodoso come genealogia dell'equipaggiamento.
- Silhouette triangolare del mantello e continuità del volto attraverso l'età.
- Personaggio a figura intera, leggibile in vista laterale/tre quarti e a piccole dimensioni sul campo 2D.

Dimensione relativa sul campo, scala in pixel e volumi degli effetti: **da definire**. Le forme finali devono aumentare l'impatto attraverso strumenti, postura e VFX senza dipendere da un aumento arbitrario della scala del corpo.

### 2.3 Differenze fra forme

| Forma | Silhouette e strumenti | Espressione e gestualità | Legame con il kit |
|---|---|---|---|
| 0 | Abiti troppo grandi, libro portato con ostinazione, bastone dominante | Giovane impulsivo, postura bassa e aggressiva | Colpisce fisicamente perché non sa fare magia |
| 1A | Libro aperto, prime pagine reattive, minore centralità del bastone | Attento ma ancora inesperto | Annotazioni preparano cure future |
| 2A | Figura più verticale e composta, barba bianca, grimorio sospeso, pagine orbitanti | Movimenti controllati; quasi immobile nei grandi lanci | Testo luminoso attraversa e collega la squadra |
| 1B | Tasche, tubi, contenitori, meccanismi nascosti e rune dipinte | Furbo, operativo, piccoli gesti di prestidigitazione | Un dettaglio rivela il trucco fisico dietro ogni “spell” |
| 2B | Silhouette più larga e caotica, riparazioni, leve, fili, gadget e zaino | Eccentrico; gestisce molti dispositivi contemporaneamente | Apparente caos con concatenazione intenzionale dei trucchi |

Nel ramo A aumentano ordine e scrittura luminosa; nel ramo B aumenta la densità di equipaggiamento. Entrambi mantengono abiti vissuti e continuità con l'apprendista.

### 2.4 Segnali visivi e stati

- **Notes / Completed Page:** annotazioni sul libro e pagina completa chiaramente riconoscibile.
- **Annotation / Written Recovery:** testo associato all'alleato; attivazione distinguibile dalla cura iniziale.
- **Shared Margins:** collegamenti leggibili fra i membri del gruppo.
- **Final Revision:** pagine degli ultimi istanti, sagome evocative delle posizioni passate e riscrittura del testo. Le sagome sono un segnale visivo: non è stato deciso un riavvolgimento delle posizioni.
- **The Story Continues:** una frase viene corretta prima della morte; evento distinto da una resurrezione.
- **Setup / Misdirection / Encore:** Setup rappresenta la preparazione nello stadio 1B; nella forma finale viene sostituito da Misdirection, alimentata da basic e inganni. Encore ha un segnale separato per la sequenza di tre active. Grafica UI ancora da definire; nella forma finale non ci sono due barre Setup e Misdirection.
- **Rigged Sigil:** disco fisico che si apre in un falso cerchio runico.
- **Clockwork Familiar:** creatura apparentemente mistica, con ruote o giunti meccanici riconoscibili.
- **Grand Illusion:** fumo, specchi, false sagome e detonazioni; il personaggio si sottrae alla scena mentre i nemici la osservano.

**Direzione delle animazioni:** idle irrequieto nello stadio 0, lettura nel ramo A, manutenzione nel ramo B; movimento coerente con peso e strumenti; basic facilmente distinguibile dal lancio; reazione al danno visibile anche durante i VFX. Animazioni esatte di morte e interruzione restano da definire.

### 2.5 Prompt visivo autonomo

> Fantasy 2D game character evolution sheet showing the same human would-be wizard across five full-body forms in a branching progression. Stage 0: a young reckless apprentice with no magical ability, fighting in melee with a crooked wooden staff, an oversized floppy blue wizard hat, worn blue-and-cream robes, red scarf, leather boots, brown leather straps and a closed battered spellbook. Branch A first evolution: a genuine novice healing grimoire mage, open book, subtle luminous handwritten annotations, attentive posture. Branch A final evolution: an elderly grimoire archsage with a long white beard, composed vertical silhouette, refined but weathered robes, a floating open book, orbiting pages and powerful lines of golden living script connecting allies; restrained physical gestures and overwhelming written magic. Branch B first evolution: a resourceful wizard impostor who still cannot use magic, adding handmade gadgets, pouches, tubes, hidden staff mechanisms and painted fake runes. Branch B final evolution: an elderly eccentric false archmage who has never learned magic, with a wider silhouette crowded with patched clothing, straps, springs, wires, mirrors, smoke devices and mechanical decoys; every apparent magical effect must reveal a physical mechanism. Preserve the same hat ancestry, staff ancestry, blue-and-cream palette, brown leather and recognizable cloak silhouette through all forms. Hand-painted fantasy game concept art, readable at small game scale, full body, side and three-quarter views, dark neutral background. Use the supplied character references for appearance only; do not reproduce their example spell kits.

---

## 3. Statistiche base

### 3.1 Stato dei valori

Non sono stati concordati valori al livello 1 senza acquisti. Non esiste una scala numerica di riferimento sufficiente per assegnare HP, difese e attacco in modo significativo. I numeri presenti nelle sezioni successive sono **esempi isolati**, non una tabella di statistiche base.

| Gruppo / parametro | Unità o rappresentazione | Uso nel kit | Stato |
|---|---|---|---|
| Maximum Health | HP | Sopravvivenza di tutte le forme | Valore da definire |
| Armor / Magic Resistance | Sistema comune del gioco | Difese personali; mitigazione del danno distribuito da chiarire | Valori da definire |
| Physical Attack | Punti di attacco | Basic dello stadio 0 e ramo B; possibile scaling dei gadget | Valore e coefficienti da definire |
| Magic Attack | Punti di attacco | Basic del ramo A | Valore da definire; ramo B senza capacità magica reale |
| Attack Speed | Attacchi/s | Ritmo dei basic e generazione delle risorse | Valore da definire |
| Attack Range | Unità di campo | Melee nello stadio 0 e 1B; distanza nel ramo A e in 2B | Valori da definire |
| Movement Speed | Unità di campo/s | Avvicinamento, rientro, Escape Route | Valore da definire |
| Engagement Radius | Unità di campo | Zona di movimento centrata sullo slot | Valore da definire; distinto da portata e AoE |
| Ability Power | Punti di potenza | Candidato per le cure; possibile potenza tecnica dei gadget | Scelta dello scaling da confermare |
| Ability Haste | Unità del sistema comune | Cooldown delle attive | Formula e limiti da definire |
| Bonus area | Moltiplicatore o % | Colpo ampio, gadget e aree pertinenti | Applicabilità da confermare |
| Critici normali / super / ultra | Probabilità e moltiplicatori | Eventuale danno dei basic/gadget | Compatibilità da definire; critici curativi non decisi |
| Multi Hit | Ripetizioni del basic | Interazione con danno e contatori | Regole da definire |
| Multi Cast | Ripetizioni delle attive | Eventuale ripetizione di cure o gadget | Regole da definire |
| Gold / XP / Souls | Contributo individuale | Nessuna meccanica economica specifica progettata | Usare catalogo comune; valori da definire |

“Zero magia” nel ramo B è un vincolo narrativo. È stata proposta anche l'assenza di Magic Attack utile; l'eventuale uso di Ability Power come **potenza tecnica** non trasformerebbe i gadget in vera magia, ma resta una scelta aperta.

Nessuna crescita automatica delle statistiche per livello è stata concordata. Ogni livello assegna un punto secondo il template.

### 3.2 Risorse e contatori

| Risorsa | Forma | Generazione consolidata | Consumo / impiego | Valori ancora aperti |
|---|---|---|---|---|
| Contatore Hard Lessons | 0 | Basic attack | Ogni N basic potenzia il prossimo Headlong Swing | N, bonus e reset |
| Notes | 1A | 1 Note per attacco nel concept | First Remedy consuma fino a un limite per migliorare la cura | Cap, limite consumabile, bonus, momento della generazione |
| Notes | 2A | Basic; cure; attivazioni di Written Recovery | Pagina completa potenzia la prossima active; salvataggio estremo consuma tutte le Notes | Quantità per fonte, soglia di salvataggio; cap 10 provvisorio |
| Contatore Living Script | 2A | Sequenza di basic | Ogni terzo attacco genera una Note aggiuntiva | Ripristino del contatore e rapporto con Multi Hit |
| Setup | 1B | Ogni N basic; uso di gadget tramite Sleight of Hand | A una soglia rende più rapido il prossimo gadget | N, soglia, quantità, consumo, bonus alla velocità |
| Misdirection, evoluzione di Setup | 2B | Loaded Staff e nemici che reagiscono ai trucchi; extra del basic contro nemici coinvolti nei trucchi | They Bought It potenzia il prossimo gadget | Cap 10 provvisorio; quantità per fonte, consumo e bonus specifici |
| Sequenza / Encore | 2B | Tre active differenti entro una finestra | Variante speciale della prossima active | Finestra, durata, consumo, sovrapposizione con They Bought It |

**Tutte le risorse:** valore iniziale, decadimento, persistenza fra ondate, comportamento alla morte e alla resurrezione, reset dopo sconfitta e Chrono break sono ancora da definire.

**Proposta di formalizzazione:** risorse di battaglia inizialmente a zero, senza persistenza permanente; reset al nuovo tentativo e Chrono break. La persistenza fra ondate va scelta in base al ritmo desiderato. Nello stadio 2B esiste soltanto Misdirection come risorsa accumulabile del ramo: Setup non mantiene una barra o un costo separato. Encore resta uno stato di ricompensa distinto.

---

## 4. Attacco base

### 4.1 Basic per forma

| Forma / nome | Descrizione breve in inglese | Modalità e danno | Effetti aggiuntivi consolidati |
|---|---|---|---|
| 0 — **Training Staff** | “Strike a nearby enemy with a training staff.” | Colpo fisico corpo a corpo | Alimenta Hard Lessons |
| 1A — **Ink Spark** | “Fire a small spark of written magic.” | Proiettile magico a distanza medio-corta, danno modesto | Genera 1 Note per attacco nel concept |
| 2A — **Living Script** | “Strike an enemy with a living written symbol.” | Simbolo/proiettile magico, danno moderato | Genera Notes; ogni terzo attacco aggiunge una Note |
| 1B — **Weighted Staff** | “Strike with a staff reinforced for practical results.” | Colpo fisico melee, portata leggermente maggiore dello stadio 0 | Ogni N attacchi genera Setup |
| 2B — **Loaded Staff** | “Fire a concealed projectile from a mechanical staff.” | Proiettile fisico a media distanza | Genera Misdirection; extra contro un nemico coinvolto in un trucco. Il precedente esempio di 1 per colpo resta provvisorio |

### 4.2 Campi comuni da finalizzare

- **Bersaglio:** nemico vivo valido; priorità iniziale suggerita Nearest, modificabile dalle priorità generali del gioco. Spareggi non definiti.
- **Portata:** relativa come sopra; valori e linea di vista da definire.
- **Formule indicative:** danno fisico `k × Physical Attack`, danno magico `k × Magic Attack`. I coefficienti `k`, le mitigazioni e l'eventuale contributo AP non sono stati decisi.
- **Ciclo e impatto:** durata, frame di impatto, velocità dei proiettili e possibilità di movimento durante l'attacco da definire.
- **Perdita del bersaglio:** retargeting del proiettile, annullamento del colpo e validità della generazione risorse da definire.
- **Critici e Multi Hit:** compatibilità da definire; non assumere che ogni ripetizione generi automaticamente una risorsa.

**Proposta di formalizzazione dei contatori:** distinguere l'azione di attacco dai colpi prodotti. Per Notes e Hard Lessons usare l'azione primaria riuscita; per Loaded Staff mantenere la generazione “per colpo” del concept, stabilendo un limite per azione in presenza di Multi Hit. Non sono equivalenti: il conteggio finale deve essere scelto esplicitamente.

---

## 5. Abilità attive

### 5.1 Regole condivise e campi aperti

Ogni active è disponibile nella forma che la contiene; non sono stati definiti ulteriori livelli di sblocco interni alla forma.

**Proposte comuni di formalizzazione:**

- Un'active senza bersaglio o condizione valida attende senza consumare cooldown o risorse.
- All'inizio dell'esecuzione vengono fissati bersaglio e variante potenziata; risorse e cooldown si impegnano al rilascio riuscito dell'effetto. Interruzioni prima del rilascio non producono l'effetto. Eventuali cooldown sulle interruzioni restano da confermare.
- Non interrompere altre azioni, salvo una priorità d'emergenza esplicitamente scelta. La passiva contro il danno letale è un evento separato dai lanci attivi.
- Se il bersaglio singolo diventa invalido prima del rilascio, acquisirne uno nuovo valido oppure annullare. Gli effetti già piazzati sul terreno seguono regole proprie.

Queste sono proposte, non regole già approvate.

**Campi numerici non ancora definiti per tutte le attive:** portata di acquisizione, geometria precisa, coefficienti e scaling, tempo di esecuzione, frame dell'effetto, cooldown, cooldown iniziale, movimento e interruzioni. Per ciascuna active rimangono aperte le compatibilità con AP, Haste, bonus area, critici, Multi Hit e Multi Cast. Ordine, ritardo e nuovo puntamento delle ripetizioni non sono stati concordati.

### 5.2 Stage 0 — Headlong Swing

**English text:** “Lunge toward a nearby enemy and deliver a wide physical swing.”

- **Funzione:** pressione fisica contro piccoli gruppi; evoluzione dell'ostinazione da combattente.
- **Attivazione:** automaticamente contro un nemico vicino; condizioni esatte, priorità e necessità di un gruppo da definire.
- **Bersagli/geometria:** nemico vicino come riferimento, ampio colpo fisico; arco, raggio e limite di bersagli non decisi. La zona d'ingaggio continua a essere distinta dalla portata del colpo.
- **Effetto:** movimento di slancio e colpo fisico; Hard Lessons potenzia il prossimo utilizzo ogni N basic. Tipo e ampiezza del potenziamento da definire.
- **Tempi:** non definiti; chiarire se lo slancio può superare i limiti di Mobile/Hold slot.
- **Presentazione:** caricamento con il bastone e ampio swing. Non è un finto incantesimo: la scoperta dei trucchi appartiene al ramo B.

### 5.3 Stage 1A — First Remedy

**English text:** “Heal the ally most in need, using notes to strengthen the remedy.”

- **Funzione:** cura singola e introduzione del ciclo `attacca → scrive → cura → correzione futura`.
- **Attivazione:** presenza di un alleato ferito valido; soglia minima di HP mancanti e priorità da definire.
- **Bersaglio:** alleato con la percentuale di HP più bassa. Questa selezione è specifica del supporto, distinta dalle priorità offensive generali. Inclusione di sé e unità evocate da confermare.
- **Effetto:** cura immediata; consuma fino a una quantità massima di Notes per aumentarne il valore.
- **Sinergia:** se consuma almeno una Note, Margin Notes lascia un'annotation sul bersaglio.
- **Formula:** forma possibile `cura base + coefficiente × AP + bonus delle Notes`; tutti i termini sono aperti.
- **Presentazione:** annotazione del grimorio che si trasferisce all'alleato; distinguerla dalla successiva attivazione dell'annotation.

### 5.4 Stage 2A — Rewrite Wounds

**English text:** “Correct the wounds of the ally most in need.”

- **Funzione:** sostituisce First Remedy, combinando grande cura immediata e correzione di danni futuri.
- **Bersaglio:** alleato con la percentuale di HP più bassa.
- **Attivazione:** alleato ferito o sotto pressione; criteri precisi da definire per evitare sprechi o attesa eccessiva.
- **Effetto:** cura immediata e applicazione di **Written Recovery**. Per una durata limitata, una percentuale del danno subito viene recuperata dopo l'evento di danno, entro un budget.
- **Esempio provvisorio:** 500 cura iniziale; recupero del 40% dei successivi 1.000 danni ricevuti; durata massima 6 s. Il recupero massimo dell'esempio è 400 HP. Il budget è espresso come danno eleggibile, non come 1.000 HP di cura.
- **Variante potenziata — Perfect Revision:** maggiore cura iniziale e maggiore capacità della correzione futura. Quantità e incremento da definire.
- **Accumulo/rinnovo:** comportamento di due Written Recovery sullo stesso alleato non definito.
- **Morte:** una cura dopo il danno non salva automaticamente da un colpo letale; quel compito appartiene a The Story Continues. Written Recovery non va descritto come assorbimento prima del danno finché non si decide di cambiarne la semantica.
- **Presentazione:** testo già scritto che si illumina quando si verifica la ferita prevista; UI con durata e budget residuo da progettare.

### 5.5 Stage 2A — Shared Margins

**English text:** “Bind several lives into the same passage.”

- **Funzione:** condividere una parte del rischio e delle cure.
- **Bersagli:** automaticamente i **3 alleati con la percentuale di HP più bassa**. Comportamento con meno di tre candidati, inclusione di sé, portata e spareggi da definire.
- **Attivazione:** criteri non definiti; proposta di valutare almeno due alleati validi e una situazione di danno o cura utile.
- **Effetti:** parte delle cure ricevute da un membro viene replicata sugli altri; parte dei colpi elevati contro un singolo membro viene distribuita fra i collegati. La distribuzione non è totale.
- **Esempio provvisorio:** un colpo da 1.000 produce 800 danni sul Tank e 100 su ciascuno degli altri due. Conserva 1.000 danni prima delle eventuali regole di mitigazione da scegliere.
- **Cure:** una cura da 500 sul Tank produce un'eco sugli altri due; percentuale dell'eco non decisa.
- **Durata/geometria:** collegamento temporaneo; durata, distanza massima e rottura del collegamento da definire.
- **Variante potenziata — Shared Chapter:** proposta di un alleato aggiuntivo e maggiore eco curativa, senza valori definitivi.
- **Regole critiche aperte:** soglia di “colpo elevato”; danno lordo o già mitigato; nuova mitigazione sui destinatari; danni letali sui collegati; rinnovo del gruppo e interazione con effetti di altre unità di tipo diverso.
- **Presentazione:** scrittura luminosa continua fra i membri del gruppo e indicatore del collegamento.

### 5.6 Stage 2A — Final Revision

**English text:** “Rewrite the last moments of the entire party.”

- **Funzione:** grande recupero durante una crisi; abilità distintiva della forma finale.
- **Attivazione proposta nella conversazione:** almeno **2 alleati sotto il 40% HP**, oppure **1 alleato sotto il 15% HP**. Soglie provvisorie; non si lancia automaticamente solo perché il cooldown è terminato.
- **Bersagli:** la squadra alleata; inclusione di sé e delle entità evocate da confermare. Non è stata progettata come resurrezione dei morti.
- **Effetto:** per ogni alleato recupera una percentuale degli HP persi in una finestra recente.
- **Esempio provvisorio:** recupero del **50%** degli HP persi negli ultimi **4 s**.
- **Variante potenziata — Last Chapter:** estende la finestra da 4 a **6 s**, valori provvisori.
- **Formula concettuale:** `cura = percentuale × perdita HP eleggibile nella finestra`, limitata agli HP mancanti. La definizione della perdita eleggibile non è ancora stata decisa: danno effettivo cumulato o differenza netta di salute non sono la stessa cosa.
- **Limiti aperti:** cap per bersaglio, interazioni con cure già ricevute, danno distribuito, danno autoinflitto e precedenti Final Revision.
- **Presentazione:** grimorio completamente aperto, pagine degli ultimi istanti che vengono strappate e riscritte. Nessun ripristino di cooldown, posizione o risorse è stato deciso.

### 5.7 Stage 1B — Prototype Trick

**English text:** “Deploy a handmade device disguised as a spell.”

- **Funzione:** primo gadget artigianale e introduzione di Setup.
- **Attivazione:** automaticamente contro un bersaglio/gruppo valido; soglie e priorità da definire.
- **Bersagli/geometria:** nemici, con piccolo effetto su gruppo; centro, raggio e massimo bersagli aperti.
- **Effetto:** piccola esplosione o dispositivo meccanico/lanciato. Danno fisico e nessuna magia reale.
- **Risorse:** il lancio genera Setup tramite Sleight of Hand; a una soglia il prossimo gadget viene eseguito più rapidamente.
- **Formula:** scaling con Physical Attack oppure AP tecnico ancora aperto.
- **Presentazione:** effetto apparentemente arcano, con una breve rivelazione del meccanismo.

Il nome dell'ultima revisione è **Prototype Trick**; il precedente Stagecraft Charge non è una seconda active aggiuntiva.

### 5.8 Stage 2B — Rigged Sigil

**English text:** “Place a perfectly convincing magical trap.”

- **Funzione:** preparazione fisica del terreno.
- **Bersaglio:** punto del terreno; il posizionamento automatico lungo percorsi o presso gruppi nemici resta da definire.
- **Geometria:** disco pieghevole che apre un falso cerchio runico. Raggio, portata di lancio e limite di trappole non definiti.
- **Attivazione della trappola:** ingresso del primo nemico/gruppo nella zona; evento esatto di ingresso da formalizzare.
- **Effetto:** danno fisico AoE e knockback. Distanza, direzione e comportamento contro immunità al respingimento da definire.
- **Persistenza:** rimane fino all'attivazione, alla scadenza o alla sostituzione. Durata e regola di sostituzione aperte.
- **Sinergia:** l'attivazione alimenta Perfect Misdirection.
- **Encore:** variante proposta con **due sigilli**; duplicazione simultanea o posizionamenti distinti da definire.
- **They Bought It:** potenziamento previsto, ma variante specifica non ancora descritta.
- **Presentazione:** preparazione meccanica, falsa runa, scatto ed esplosione. UI per proprietà, area e durata della trappola.

### 5.9 Stage 2B — Clockwork Familiar

**English text:** “Deploy a suspiciously mechanical magical familiar.”

- **Funzione:** alterare attenzione, movimento e formazione dei nemici.
- **Bersaglio di schieramento:** zona davanti alla squadra; criterio e distanza da definire.
- **Entità:** falso famiglio meccanico bersagliabile, con ruote o giunti riconoscibili.
- **Effetto:** alta priorità di bersaglio che induce nemici validi a cambiar bersaglio e inseguirlo. Non è stato deciso un taunt assoluto.
- **Planned Failure:** alla distruzione esplode oppure rilascia una sorpresa. La scelta definitiva dell'effetto non è stata fatta.
- **Sinergia:** gli attacchi contro il famiglio alimentano Perfect Misdirection.
- **Encore:** variante proposta che alla distruzione si divide in **due piccoli decoy**.
- **They Bought It:** variante specifica da definire.
- **Statistiche/durata:** HP, difese, velocità, priorità, cap di entità e scaling non definiti. Vedere anche §11.3.
- **Presentazione:** estrazione dallo zaino, carica meccanica e invio sul campo; segnale distinto di Planned Failure.

### 5.10 Stage 2B — Grand Illusion

**English text:** “Convince everyone that the impossible just happened.”

- **Funzione:** intero spettacolo di controllo e detonazione; ultimate del ramo tecnico.
- **Attivazione:** condizione automatica non ancora definita. Proposta di valutarla su un gruppo numeroso o una minaccia alla squadra, per non ridurla a un lancio indiscriminato a cooldown.
- **Bersagli/geometria:** nemici coinvolti nella zona scenica; durata, area, massimo bersagli e criterio di gruppo da definire.
- **Smoke:** i nemici coinvolti perdono il bersaglio attuale e rivalutano il targeting. Non sono stati decisi cancellazione dei proiettili già partiti o interruzione dei colpi già impegnati.
- **Mirrors:** crea brevemente false sagome bersagliabili, su cui i nemici possono sprecare attacchi. Numero, HP e priorità aperti.
- **Hidden Charges:** dopo un ritardo, detonazione fisica nel gruppo di nemici più numeroso. Metodo di raggruppamento, momento di acquisizione e danno da definire.
- **Escape Route:** il False Archmage arretra verso la propria posizione/slot. Distanza e compatibilità con Hold slot da formalizzare; nessun teletrasporto reale.
- **Sinergia:** cambi di bersaglio e colpi contro sagome alimentano Misdirection; contribuisce alla sequenza di tre active differenti per Encore.
- **Encore:** proposta di sagome più durature e seconda detonazione.
- **They Bought It:** potenziamento specifico aperto.
- **Presentazione:** concatenazione rapida di fumo, lampi, specchi, sagome, cariche, fili e falsi simboli; rumori meccanici rivelano il trucco dietro l'apparente magia.

---

## 6. Passive

### 6.1 Stage 0 — Hard Lessons

**English text:** “Every hard-earned lesson strengthens the next wide swing.”

- **Evento:** ogni N basic attack potenzia il successivo Headlong Swing.
- **Funzione:** semplice ritmo di apprendimento e collegamento fra basic e active.
- **Conteggio:** concepito per attacco, non per uccisione o bersaglio; trattamento dei Multi Hit da confermare.
- **Effetto:** potenziamento dello swing; bonus, soglia, cariche massime e consumo non definiti.
- **UI:** contatore e segnale di swing pronto.

### 6.2 Stage 1A — Margin Notes

**English text:** “A note spent on healing leaves a correction for the next wound.”

- **Evento:** una cura consuma almeno una Note.
- **Effetto:** lascia una piccola **annotation** sul bersaglio; la prossima volta che quell'alleato subisce danno, lo cura nuovamente.
- **Funzione:** prepara la logica di Written Recovery.
- **Conteggio:** applicazione per cura che consuma Notes; attivazione sul successivo evento di danno. Non una cura per ogni Note consumata, salvo futura decisione.
- **Aperti:** cura, durata massima, accumulo/rinnovo e comportamento con danno letale. Più Acolyte dello stesso tipo in campo sono esclusi dalla regola di schieramento.
- **UI:** simbolo sul bersaglio e conferma visiva dell'attivazione.

### 6.3 Stage 2A — Living Grimoire

**English text:** “Gather living notes and complete a page to empower the next spell.”

- **Funzione:** motore comune delle tre active.
- **Fonti:** basic, cure e attivazioni di Written Recovery. Salvataggi estremi erano una possibile fonte, non una scelta confermata.
- **Conteggio:** quantità e frequenza per fonte ancora aperte; distinguere lancio della cura, bersaglio curato, impulso e cura effettiva.
- **Cap provvisorio:** **10 Notes**.
- **Completed Page:** raggiungere la soglia prepara la prossima active potenziata, che consuma tutte le Notes.
- **Varianti:** Rewrite Wounds → Perfect Revision; Shared Margins → Shared Chapter; Final Revision → Last Chapter. Sono varianti delle tre active, non nuovi slot.
- **Rischio:** cure, recuperi ed eco possono alimentarsi a vicenda. La prevenzione di questo ciclo deve essere formalizzata.
- **UI:** Notes, stato di pagina completa e indicazione della variante disponibile.

La generazione extra ogni terzo attacco resta un effetto di Living Script: non occupa una terza passiva.

### 6.4 Stage 2A — The Story Continues

**English text:** “A chapter does not end simply because someone falls.”

- **Funzione:** salvataggio estremo contro un esito letale.
- **Evento:** un alleato dovrebbe morire, l'Archsage possiede almeno una soglia di Notes e il cooldown interno è disponibile.
- **Effetto:** consuma tutte le Notes, impedisce quella morte, lascia il bersaglio a **1 HP** e applica immediatamente Written Recovery.
- **Cooldown interno provvisorio:** **25–35 s**. Soglia di Notes da definire.
- **Bersagli:** alleati; inclusione di sé e delle evocazioni da confermare.
- **Limite:** non è una resurrezione e non implica invulnerabilità o una cura iniziale aggiuntiva. A 1 HP il bersaglio rimane vulnerabile; chiarire quando scatta il primo recupero.
- **Aperti:** priorità fra eventi letali simultanei su alleati diversi, portata, consumo di Completed Page e interazione con salvataggi di altre unità di tipo diverso.
- **UI:** disponibilità del salvataggio, cooldown interno e forte segnale di correzione della morte.

### 6.5 Stage 1B — Sleight of Hand

**English text:** “Each gadget prepares a faster trick.”

- **Evento:** utilizzo di un gadget; genera Setup.
- **Effetto:** a una soglia di stack il prossimo gadget è eseguito molto più rapidamente.
- **Funzione:** loop `preparo → gadget → preparo ancora`.
- **Aperti:** quantità per lancio, cap, soglia, consumo, riduzione del tempo, durata della preparazione.
- **Conteggio:** per uso del gadget, non automaticamente per nemico colpito; Multi Cast ancora da definire.
- **UI:** preparazione accumulata e gadget rapido pronto.

### 6.6 Stage 2B — Perfect Misdirection

**English text:** “Every enemy fooled brings the next trick closer to perfection.”

- **Eventi:** basic Loaded Staff; nemico che attiva Rigged Sigil, attacca Clockwork Familiar, cambia bersaglio a causa di Grand Illusion o colpisce una falsa sagoma. Il basic può generare Misdirection aggiuntiva contro un nemico coinvolto nei trucchi, come già previsto per Setup.
- **Effetto confermato:** accumula **Misdirection**, evoluzione di Setup e unica risorsa finale alimentata da basic e inganni; prepara il prossimo gadget potenziato. Non è previsto un effetto separato di riduzione dei cooldown per ogni stack nel kit consolidato.
- **Cap/soglia provvisoria:** **10 stack**.
- **They Bought It:** alla soglia, prossimo gadget potenziato. Regola di consumo e potenziamenti per ciascun gadget da definire.
- **Conteggio:** distinguere ingresso nella trappola, azione d'attacco contro un'esca, colpo effettivo e cambio di bersaglio causato dal trucco. Non sono eventi intercambiabili.
- **Limiti aperti:** quantità per fonte, massimo eventi per secondo, contributo di Multi Hit propri e nemici, danni periodici e prevenzione di conteggi duplicati.
- **UI:** stack e stato di prossimo gadget potenziato.

### 6.7 Stage 2B — Nothing Up My Sleeve

**English text:** “Chain three different tricks to prepare an encore.”

- **Evento:** utilizzo di **tre active differenti** entro una finestra temporale.
- **Effetto:** ottiene **Encore**; la prossima active produce una variante speciale/seconda versione dell'effetto.
- **Varianti proposte:** due Rigged Sigil; Familiar che genera due decoy alla distruzione; Grand Illusion con sagome più durature e seconda detonazione.
- **Scelta consolidata:** privilegiare una nuova versione dell'effetto, senza richiedere un azzeramento completo del cooldown.
- **Aperti:** durata della finestra, momento di registrazione del lancio, durata di Encore, consumo, rinnovo e convivenza con They Bought It.
- **Conteggio:** tre nomi di active distinti, non tre bersagli, colpi o copie della stessa abilità.
- **UI:** sequenza dei tre gadget e Encore pronto.

### 6.8 Regole comuni ancora aperte e protezioni proposte

Per tutte le passive devono essere confermati: cooldown interni ove mancanti, reset dei contatori, stato a vita piena, morte e resurrezione, persistenza fra ondate, sconfitta, salvataggio/caricamento e Chrono break.

**Proposte di formalizzazione contro cicli infiniti:**

1. Le eco curative di Shared Margins non producono altre eco. Il danno distribuito non viene redistribuito da un altro collegamento.
2. Living Grimoire conta fonti primarie identificate; le cure derivate non devono rigenerare senza limite le risorse che le hanno prodotte.
3. Le repliche generate da Encore non contano come nuovi lanci per ottenere Encore. Multi Cast non sostituisce l'obbligo di tre active differenti.
4. Ogni evento di trucco genera Misdirection una sola volta secondo la sua provenienza. Il limite di schieramento esclude più False Archmage dello stesso tipo.
5. Un evento letale può essere risolto da un solo salvataggio; ordine e interazione con salvataggi di altre unità di tipo diverso restano da scegliere.
6. Un effetto privo di risultato utile, come una cura a vita piena, non deve generare risorse illimitate.

---

## 7. Comportamento automatico

### 7.1 Formazione e movimento

| Forma | Posizione consigliata | Priorità offensiva suggerita | Comportamento desiderato |
|---|---|---|---|
| 0 | Front / mid-front | Nearest | Avvicinamento entro la zona d'ingaggio e pressione melee |
| 1A | Mid / backline | Nearest | Alterna basic a cura dell'alleato con HP% più bassa |
| 2A | Backline | Nearest | Mantiene accesso alla squadra; privilegia recupero e stabilizzazione |
| 1B | Midline | Nearest | Combatte con bastone e prepara gadget; portata limitata |
| 2B | Mid / backline | Nearest | Attacca a media distanza, piazza dispositivi e sfrutta le deviazioni nemiche |

- **Mobile:** movimento entro la zona circolare centrata sullo slot, con avvicinamento quando serve e rientro quando cessa l'ingaggio.
- **Hold slot:** mantiene lo slot; la perdita di accesso a un bersaglio può far attendere l'azione. Slancio di Headlong Swing ed Escape Route richiedono eccezioni esplicite o varianti compatibili.
- **Targeting:** priorità generali del gioco per l'offesa; criteri specifici di HP% per le cure; selezione del terreno e dei gruppi da progettare per i gadget.
- **Mantenimento:** cambio bersaglio quando diventa invalido o quando una priorità lo impone, secondo regole comuni ancora da precisare.

### 7.2 Sequenza decisionale proposta

1. Verifica morte, controllo e azione in corso; risolvi separatamente eventuali eventi letali.
2. Valuta active pronte con condizioni e bersagli validi.
3. Se più active sono valide, applica una priorità deterministica.
4. Se nessuna active viene scelta, attacca un nemico valido in portata.
5. In Mobile, avvicinati entro la zona d'ingaggio se necessario; altrimenti attendi o rientra allo slot.

**Priorità proposte, non ancora approvate:**

- Archsage: Final Revision in emergenza → Rewrite Wounds → Shared Margins → basic. Definire le soglie per evitare che una cura singola interferisca con la grande revisione.
- False Archmage: Grand Illusion in situazione utile → Clockwork Familiar se serve una deviazione e il limite entità lo permette → Rigged Sigil su terreno valido → basic. La sequenza deve consentire Encore senza far sprecare gadget solo per completarla.

### 7.3 Loop delle forme finali

**Grimoire Archsage:** Living Script genera Notes → Rewrite Wounds stabilizza un alleato → Written Recovery corregge danni successivi → Shared Margins condivide rischio e cure → Completed Page prepara un'active potenziata → Final Revision recupera una crisi → The Story Continues impedisce un esito letale se risorsa e cooldown lo consentono.

**False Archmage:** Loaded Staff genera Misdirection → Rigged Sigil prepara il terreno → reazioni nemiche aggiungono Misdirection → Clockwork Familiar altera il bersagliamento → la soglia prepara They Bought It per il prossimo gadget potenziato → Grand Illusion amplia la deviazione → tre active differenti preparano Encore → prossimo gadget in variante speciale. **Setup evolve in Misdirection**, quindi il loop finale usa una sola risorsa accumulabile. Encore resta separato; la combinazione con They Bought It è ancora da formalizzare.

---

## 8. Potenziamenti e progressione

### 8.1 Punti livello

Il template assegna un punto spendibile per livello. Nella conversazione non sono stati progettati potenziamenti con nomi, effetti per grado, costi, cap o livelli richiesti. Questi campi rimangono aperti; non sono inclusi aumenti automatici impliciti.

**Direzioni possibili, proposte da sviluppare:**

| Forma / ramo | Scelta di investimento | Compromesso desiderato |
|---|---|---|
| 0 | Frequenza di Hard Lessons / efficacia di Headlong Swing | Picco più frequente o più incisivo |
| A | Cura immediata / budget della correzione futura | Recupero rapido o stabilità nel tempo |
| A finale | Gestione delle Notes / condivisione / revisione recente | Ritmo delle pagine o ampiezza del sostegno |
| B iniziale | Danno del gadget / rapidità di preparazione | Picco fisico o frequenza operativa |
| B finale | Trappole / durata delle esche / qualità dello spettacolo | Controllo del terreno o deviazione prolungata |

Per ogni potenziamento futuro vanno definiti: nome inglese, effetto per grado, massimo gradi, costo, requisito di livello, prerequisiti/esclusioni, ordine dei bonus e conversione degli acquisti precedenti dopo l'evoluzione.

### 8.2 Gold e bonus condivisi

- Stadio 0 e ramo B: Physical Attack e Attack Speed sono candidati naturali; difese e movimento restano utili alla sopravvivenza.
- Ramo A: Magic Attack per il basic; AP candidato per le cure; Haste e Attack Speed influenzano il ritmo di supporto e delle Notes.
- Bonus area pertinenti solo alle geometrie effettive; un collegamento o una cura singola non ricevono automaticamente bersagli aggiuntivi.
- Magic Attack non offre un beneficio al ramo B nel concept attuale. Non sono state definite altre statistiche completamente inutili.
- Nessun bonus economico specifico progettato. Shop globale, progressione Chrono e conservazione degli acquisti seguono il sistema comune, con conversioni del kit da definire.
- Critici, Multi Hit, Multi Cast e valori elevati di Haste richiedono limiti ed eventi di conteggio espliciti prima di stabilire l'utilità degli acquisti.

---

## 9. Eventuali evoluzioni

### 9.1 Percorso consolidato

| Transizione | Motivazione narrativa | Modifiche al kit | Modifica visiva |
|---|---|---|---|
| 0 → 1A | Scopre che la sua magia risponde alle ferite degli alleati | Training Staff → Ink Spark; Headlong Swing → First Remedy; Hard Lessons → Margin Notes | Libro aperto, prime annotazioni reali |
| 1A → 2A | Diventa maestro della cura scritta e delle correzioni | Ink Spark → Living Script; First Remedy → Rewrite Wounds; aggiunge Shared Margins e Final Revision; Margin Notes diventa Living Grimoire; aggiunge The Story Continues | Anziano composto, grimorio sospeso e pagine orbitanti |
| 0 → 1B | Trasforma il fallimento magico in trucchi tecnici | Training Staff → Weighted Staff; Headlong Swing → Prototype Trick; Hard Lessons → Sleight of Hand | Prime tasche tecniche e meccanismi nascosti |
| 1B → 2B | Padroneggia l'intero spettacolo e le reazioni nemiche | Weighted Staff → Loaded Staff; Setup → Misdirection, generata da basic e inganni; Prototype Trick lascia posto a Rigged Sigil, Clockwork Familiar e Grand Illusion; Sleight of Hand lascia posto a Perfect Misdirection e Nothing Up My Sleeve | Anziano sovraccarico di gadget, silhouette più larga |

Le capacità iniziali non restano automaticamente come slot extra. L'identità viene ereditata attraverso i nuovi effetti e il loop.

### 9.2 Regole di progressione aperte

- Livello della prima evoluzione e livello della seconda: **da definire**.
- Costi, materiali, condizioni speciali e ruolo del Chrono nella difficoltà: **da definire**.
- Scelta manuale irrevocabile o respec: **da definire**.
- Evoluzione per singola copia: proposta coerente con la progressione indipendente del template, **da confermare**.
- Nuovi limiti dei potenziamenti e conversione/rimborso degli investimenti melee dopo il cambio di ruolo: **da definire**.
- Nessun bonus diretto alle statistiche base dovuto all'evoluzione.

### 9.3 Nomenclatura consolidata

Usare **Grimoire Archsage** per la forma finale A: sostituisce il precedente nome Grimoire Sage. Usare **False Archmage** come nome di lavoro finale B; **Failed Wizard** resta l'alternativa dal tono più ironico e il titolo presente nel riferimento visivo.

Il kit aggiornato usa **Shared Margins**, non la precedente proposta Linked Margins. La precedente Completed Chapter non è una passiva aggiuntiva: la revisione finale adotta Living Grimoire e The Story Continues.

---

## 10. Sinergie, debolezze e rischi di bilanciamento

### 10.1 Sinergie e limiti

| Forma | Sinergie | Debolezze / conflitti |
|---|---|---|
| 0 | Pressione fisica iniziale e piccoli gruppi vicini | Deve esporsi, non cura e non controlla il targeting |
| 1A | Tank o singolo alleato sotto pressione; combattimenti che consentono di generare Notes | Danno basso, sostegno limitato a un bersaglio per lancio |
| 2A | Squadre che subiscono danni continui; Tank e combattimenti lunghi | Dipende da risorse e cooldown; burst letale quando il salvataggio non è disponibile; danno personale limitato |
| 1B | Composizioni fisiche e nemici raggruppati | Basic ancora melee, nessuna cura, gadget meno sofisticati |
| 2B | DPS fragili, Ranged e squadre che guadagnano valore da tempo e spaziatura | Danno diretto inferiore a un DPS dedicato; nemici immuni al controllo o resistenti ai diversivi; dipendenza dalla collocazione dei dispositivi |

Shared Margins può esporre alleati fragili a danni che non avrebbero ricevuto. Il respingimento del ramo B può spostare nemici fuori dalle AoE alleate: sono compromessi di composizione da verificare.

### 10.2 Confronto finale

| Aspetto | Grimoire Archsage | False Archmage |
|---|---|---|
| Filosofia | Corregge le conseguenze del danno | Manipola ciò che i nemici fanno |
| Risorse | Notes / Completed Page | Misdirection, evoluzione di Setup; Encore separato |
| Protezione | Cura, correzione futura, rischio condiviso | Trappole, esche, perdita e rivalutazione del bersaglio |
| Picco | Final Revision / Last Chapter | Grand Illusion / Encore |
| Salvataggio estremo | The Story Continues | Deviazione dei colpi attraverso i trucchi |
| Posizione | Backline | Mid / backline |
| Tipo di supporto | Prevalentemente reattivo | Prevalentemente proattivo |

### 10.3 Esempi numerici della conversazione

**Sono stime aritmetiche illustrative, senza simulazione, senza mitigazioni e senza una scala base approvata.**

**Rewrite Wounds:** con 500 cura iniziale, recupero del 40% di un budget di 1.000 danni e tutti gli eventi non letali entro 6 s, il recupero potenziale totale è `500 + 0,40 × 1.000 = 900 HP`. La cura effettiva diminuisce per overheal, scadenza, mancato consumo del budget o morte.

**Shared Margins:** un colpo da 1.000 nell'esempio diventa `800 + 100 + 100`. Il totale resta 1.000; il vantaggio è ridurre la concentrazione sul primo bersaglio. Non si può calcolare l'eco di una cura da 500 perché la sua percentuale non è stata scelta.

**Final Revision:** nell'ipotesi di recupero del 50%, con perdite eleggibili negli ultimi 4 s e HP mancanti sufficienti:

| Alleato | HP persi nella finestra | Recupero teorico |
|---|---:|---:|
| Tank | 4.000 | 2.000 |
| Warrior | 1.600 | 800 |
| Mage | 600 | 300 |
| **Totale** | **6.200** | **3.100** |

**Tempo per una pagina:** ipotizzando 1 attacco/s, tutti validi, 1 Note per basic, +1 ogni terzo attacco, nessuna altra fonte, zero Notes iniziali e nessun consumo, servono **8 attacchi** per arrivare a 10 Notes: `8 + floor(8/3) = 10`. Con primo impatto a 1 s, circa 8 s. È una stima; il kit reale può accelerarla tramite cure e Written Recovery.

**Tempo per They Bought It:** con soglia provvisoria 10 e ipotetico guadagno di 1 per evento valido, servono 10 eventi. Il tempo non è calcolabile senza numero nemici, frequenze e limiti di conteggio.

**Danno single target e AoE:** non quantificabile senza attacchi, coefficienti, velocità e cooldown. **Effetto dei potenziamenti:** non quantificabile perché gradi e bonus non sono stati progettati.

### 10.4 Vincolo di schieramento e valori elevati

- **Una sola unità del tipo in campo:** non sono validi gli scenari con due/tre Archsage, due/tre False Archmage o le due evoluzioni dello stesso personaggio insieme.
- **Copie nella collezione:** mantengono progressione indipendente; se sarà confermata l'evoluzione per copia, potranno offrire la scelta del ramo da schierare prima della battaglia.
- **Entità tecniche:** trappole, Familiar e sagome richiedono comunque limiti propri. La loro presenza non autorizza una seconda copia del personaggio.
- **Attack Speed elevata:** accelera risorse e contatori; definire tetti o frequenze per eventi utili.
- **Haste elevata:** può rendere permanentemente disponibili collegamenti o spettacoli; verificare durata/cooldown e rendimenti.
- **Multi Hit / Multi Cast elevati:** possono moltiplicare generatori, entità e repliche; decidere la distinzione fra azione primaria ed effetti derivati.

### 10.5 Verifiche necessarie

Non sono stati eseguiti test di gioco o simulazioni. Il piano di verifica deve includere:

- Bersaglio che muore, scompare o esce dalla portata durante una cura, un basic o il lancio di un gadget.
- Nessun nemico, nessun alleato ferito, meno di tre candidati a Shared Margins e nessun punto valido per una trappola.
- Danno letale, cura e attivazione di Written Recovery nello stesso istante; salvataggio a 1 HP seguito da altro danno.
- Più active disponibili, pagina completa e salvataggio letale simultanei; più alleati in pericolo nello stesso istante e salvataggi concorrenti di unità di tipo diverso.
- Eco che non producono altre eco, danno condiviso che non si redistribuisce e risorse che non si rigenerano in un ciclo infinito.
- Snapshot e contabilità degli HP per Final Revision con cure intermedie, overheal, danno distribuito, resurrezioni e revisioni consecutive.
- Boss immuni al knockback, nemici con targeting speciale e attacchi già impegnati durante Smoke.
- Acquisti durante un'azione: momento di campionamento delle statistiche e aggiornamento di coefficienti, durata, cooldown e cap.
- Pausa, sconfitta, salvataggio/caricamento e Chrono break: risorse, entità, collegamenti, cooldown e registro danni.
- Validazione della formazione: rifiutare duplicati dello stesso tipo anche in forme o rami diversi.
- Stress con velocità e Haste elevate, molti bersagli, entità tecniche e ripetizioni; generazione di Misdirection da basic e inganni senza una barra Setup separata.

---

## 11. Asset e sistemi tecnici necessari

### 11.1 Asset

- Cinque concept di riferimento, già forniti, e relative schede/ritratti per la collezione.
- Cinque sprite da campo a figura intera, laterali/tre quarti.
- Icone per **5 basic, 9 active e 7 passive**; le varianti potenziate possono avere badge o icone secondarie senza essere slot aggiuntivi.
- Animazioni per idle, movimento, basic, lanci, danno, morte e interruzioni; animazioni specifiche di slancio, lettura, manutenzione e schieramento.
- VFX per proiettili scritti, Notes, pagina completa, annotation, Written Recovery, collegamenti, revisione temporale e salvataggio.
- VFX/props per disco-sigillo, esplosioni, knockback, fumo, specchi, cariche, fili, sagome e percorso di ritirata.
- Sprite/animazioni per Clockwork Familiar e possibili decoy minori.
- SFX: colpi di legno, pagine e scrittura, accenti delle cure, correzione della morte, molle, ruote, leve, detonazioni e finale dello spettacolo.
- UI per risorse, cooldown, stati sul bersaglio, durata/budget di recupero, proprietà delle trappole e sequenza di Encore.

### 11.2 Sistemi richiesti dal design desiderato

Il template descrive un progetto Godot 4.7 e uno stato tecnico datato 27 settembre 2026; questo documento **non verifica l'implementazione attuale**. I limiti di quell'implementazione non riducono il design richiesto.

- Scheduler di tre active con condizioni, priorità deterministiche e varianti potenziate.
- Eventi distinti per azione, colpo, bersaglio, lancio, cura effettiva, danno, cambio target e morte imminente.
- Risorse/contatori della copia schierata, consumo atomico, stato Completed Page, They Bought It ed Encore; sostituzione di Setup con Misdirection all'evoluzione finale B.
- Validazione di una sola unità per tipo in formazione, con identità di origine comune alle forme evolute.
- Cura attivata da danni futuri con budget e durata.
- Collegamenti fra alleati, distribuzione del danno ed eco curative con provenienza degli eventi.
- Registro della perdita HP recente per singolo alleato e interrogazione della finestra temporale.
- Intercettazione del danno letale prima della risoluzione della morte.
- Entità e trappole persistenti, collisioni/ingressi, cap, durata e proprietà.
- Bersagliamento delle esche, invalidazione controllata del target, resistenze e immunità.
- AoE, knockback, detonazioni ritardate, schieramenti multipli e ritirata fisica.
- Serializzazione e pulizia di stato coerenti con pause, caricamento, sconfitta e Chrono break.

### 11.3 Entità e meccaniche speciali

| Entità / effetto | Regole già delineate | Campi da definire |
|---|---|---|
| Rigged Sigil | Oggetto tecnico sul terreno; scatta all'ingresso e poi termina | Bersagliabilità, HP se presenti, cap, durata, sostituzione, persistenza alla morte del proprietario |
| Clockwork Familiar | Alleato/esca meccanica bersagliabile davanti alla squadra; attira attenzione; Planned Failure alla distruzione | HP/difese/scaling, velocità, durata, cap, movimento, priorità, buff/cure e morte del proprietario |
| Decoy di Encore | Due piccole esche alla distruzione del Familiar nella variante proposta | Statistiche, durata, priorità, eventuali ulteriori effetti alla morte |
| False sagome | Bersagli temporanei di Grand Illusion | Numero, HP, posizione, durata, regole di targeting e compatibilità con danni AoE |
| Annotation / Written Recovery | Cura futura legata a un evento di danno | Accumulo, scadenza, budget, ordine degli eventi e più fonti |
| Shared Margins | Collegamento temporaneo di vite | Sovrapposizioni, distanza, morte di un membro e prevenzione della ricorsione |
| The Story Continues | Previene una morte a risorsa/cooldown disponibili | Priorità, simultaneità, inclusione di sé, reset e convivenza con altri effetti |

Ricompense generate dalle esche, effetti alla scadenza invece che alla distruzione, pulizia a fine ondata/tentativo e Chrono break: **non definiti**. Nessuna resurrezione, bonus ricompense o magia autentica del ramo B è stata aggiunta.

---

## 12. Decisioni ancora da confermare

### 12.1 Identità e progressione

1. Nomi definitivi, soprattutto False Archmage versus Failed Wizard, e rarità di evocazione.
2. Classe di Makeshift Wizard: il ruolo propone Ranged ma il basic resta corpo a corpo; le classi nel template sono descrittive.
3. Soglie, costi e condizioni delle evoluzioni; scelta per copia, irrevocabilità o respec.
4. Potenziamenti completi per punti livello e conversione degli investimenti dopo il cambio di ruolo.

### 12.2 Numeri e comportamento comune

5. Statistiche al livello 1 e scala del combattimento; nessun valore base è stato concordato.
6. Formule di danno/cura, coefficienti, scaling dei gadget, portate, geometrie, durate, cooldown e tempi di esecuzione.
7. Priorità fra active, interruzioni, perdita dei bersagli, inclusione di sé/evocati e risoluzione delle parità.
8. Compatibilità con critici normali/super/ultra, Multi Hit, Multi Cast, AP, Haste e bonus area.
9. Stato iniziale, consumo, decadimento e reset delle risorse fra ondate, morte, resurrezione, sconfitta, caricamento e Chrono break.

### 12.3 Ramo A

10. Cap e consumo delle Notes in 1A; quantità per fonte in 2A, soglia di salvataggio e priorità rispetto a Completed Page.
11. Annotation e Written Recovery: valori, durata, accumulo, budget e ordine rispetto al danno letale.
12. Shared Margins: soglia dei colpi condivisi, percentuali, mitigazione, eco, membri insufficienti e rinnovo dei collegamenti.
13. Final Revision: significato esatto di “HP persi”, percentuale, finestra, cap e trattamento del danno già curato.
14. The Story Continues: cooldown definitivo, portata, eventi letali simultanei su alleati diversi, altri effetti di salvataggio e protezione del bersaglio a 1 HP.
15. Conferma delle protezioni contro ricorsione delle cure e generazione infinita delle Notes.

### 12.4 Ramo B

16. Transizione Setup → Misdirection: funzione e fusione sono confermate; resta da decidere come trattare eventuali stack già accumulati se l'evoluzione avviene durante il combattimento.
17. Misdirection: evento preciso, quantità da basic e inganni, frequenza massima, soglia, consumo e variante They Bought It per ogni gadget.
18. Encore: finestra delle tre active, durata, consumo, repliche e combinazione con They Bought It.
19. Rigged Sigil: collocazione automatica, durata, limite, sostituzione, geometria e knockback.
20. Clockwork Familiar: statistiche, durata, comportamento, priorità di target e scelta di Planned Failure.
21. Grand Illusion: condizione di lancio, area, sagome, scelta del gruppo, ritardi, controlli, boss e Escape Route.
22. Cap e lifecycle delle entità tecniche, buff/cure sulle esche, ricompense e rapporto con morte del proprietario.

### 12.5 Direzione già fissata da preservare

- Cinque forme: stadio 0, due prime evoluzioni e due finali.
- Stadio 0 senza vera magia, attacco fisico melee e nessun gadget da finto incantesimo.
- Ramo A centrato su vera magia curativa, scrittura e manipolazione delle ferite.
- Ramo B senza magia anche alla fine, basato su strumenti, inganno e controllo del campo.
- Forme finali difficili da raggiungere, di grande impatto, con **3 active e 2 passive ciascuna**.
- Una sola unità dello stesso tipo contemporaneamente in campo; le forme e i rami di questo personaggio non aggirano il vincolo.
- Nella forma finale B, **Setup evolve in Misdirection**: basic e nemici ingannati alimentano una sola risorsa per il prossimo gadget potenziato. **Encore** resta separato.
- Evoluzioni attraverso nuove funzioni del kit e limiti di progressione; nessun aumento diretto delle statistiche base.
- Nomi e testi di gioco in inglese; spiegazioni progettuali in italiano.
- Riferimenti visivi preservati nell'aspetto; esempi di spell delle immagini ignorati.
