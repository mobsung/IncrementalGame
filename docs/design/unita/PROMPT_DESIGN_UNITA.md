# Prompt — Progettazione di un’unità

Template riutilizzabile per progettare un personaggio del progetto IncrementalGame.

**Stato:** il limite di **3 abilità attive e 2 passive, oltre a 1 attacco base**, è una proposta da confermare. Questo template non modifica le regole concordate del gioco. I campi da compilare e le possibilità elencate non costituiscono contenuti già approvati o implementati.

---

Agisci come game designer specializzato in giochi incrementali, combattimento automatico e progettazione di personaggi. Progetta un’unità per il gioco descritto sotto, producendo una scheda completa e coerente.

Distingui chiaramente **vincoli confermati, proposte e aspetti ancora da definire**. Se mancano informazioni indispensabili, raccogli le domande in un unico gruppo. Puoi proporre valori iniziali di bilanciamento, ma devi indicarli come provvisori.

## 1. Tipo di gioco e contesto

Il gioco è un **incrementale/idle 2D con combattimento automatico a ondate, collezione di unità e costruzione della squadra**.

Il giocatore:

- ottiene copie di personaggi tramite evocazioni;
- sceglie quali schierare e in quali posizioni;
- imposta postura e priorità dei bersagli;
- osserva il combattimento automatico;
- investe Gold e punti livello;
- cerca combinazioni capaci di superare ondate sempre più difficili;
- usa il **Chrono break** per ricominciare dalle prime ondate conservando la progressione permanente.

La profondità deve derivare da **composizione della squadra, posizionamento, potenziamenti e sinergie**. Le abilità si attivano automaticamente secondo condizioni esplicite.

### Regole da rispettare

- Ogni copia ha livelli, XP, punti e acquisti individuali indipendenti.
- Ogni livello assegna un punto spendibile; eventuale crescita automatica delle statistiche deve essere dichiarata e concordata.
- Le classi suggeriscono un ruolo senza imporre un pacchetto obbligatorio di statistiche o abilità.
- Classi disponibili nel design: **Warrior, Tank, Mage, Healer, Summoner, Ranged**.
- Portata delle azioni, area d’effetto e zona d’ingaggio sono parametri distinti.
- Gli alleati possono mantenere lo slot oppure muoversi entro una zona circolare centrata sullo slot.
- Le priorità generali sono: più vicino, più lontano, maggiore vita massima, minore vita massima.
- Le evoluzioni sono facoltative e possono modificare abilità, passive e limiti dei potenziamenti; non aumentano direttamente le statistiche base.
- I nomi e i testi destinati al giocatore devono essere **in inglese**. Le spiegazioni progettuali possono essere in italiano.
- Nuove meccaniche devono contribuire a combattimento, crescita o avanzamento e avere regole verificabili.

### Limiti del kit proposti

- **1 attacco base**.
- **Massimo 3 abilità attive**.
- **Massimo 2 passive**.
- Non riempire obbligatoriamente tutti gli spazi.
- Distingui il kit iniziale da quello eventualmente ottenibile con livelli o evoluzioni.
- Chiarisci se un’evoluzione modifica un’abilità esistente o aggiunge una nuova abilità, rispettando il limite concordato.

### Contesto tecnico attuale

Il progetto usa **Godot 4.7**, con campo 2D illustrato e personaggi a figura intera in vista laterale.

Al 27 settembre 2026, l’implementazione gestisce un attacco base, un’abilità attiva del tipo Sweep e una passiva curativa. Un personaggio con più attive, evocazioni, buff o altri effetti può richiedere nuovi sistemi. **Separa il design desiderato dal lavoro tecnico necessario per realizzarlo.** Verifica lo stato aggiornato del progetto prima di pianificare l’implementazione.

## 2. Indicazioni per questa unità

Usa questi dati come punto di partenza:

- **Idea o tema:** [compilare]
- **Fantasia del personaggio:** [che cosa deve far immaginare al giocatore]
- **Ruolo desiderato:** [compilare oppure proporre]
- **Riferimenti visivi:** [immagini o descrizioni]
- **Elementi obbligatori:** [compilare]
- **Elementi da evitare:** [compilare]
- **Complessità desiderata:** [bassa / media / alta]
- **Fase di introduzione:** [inizio gioco / progressione intermedia / avanzata]
- **Vincoli aggiuntivi:** [compilare]

## 3. Identità e funzione nella squadra

Definisci:

| Campo | Contenuto richiesto |
|---|---|
| Nome inglese | Nome leggibile e riconoscibile |
| Specie/concept | Che creatura o personaggio è |
| Descrizione breve | Una frase utilizzabile nella collezione |
| Classe consigliata | Una delle classi previste |
| Ruolo primario | Il contributo principale alla squadra |
| Ruolo secondario | Eventuale contributo complementare |
| Rarità | Proposta con motivazione |
| Lato di schieramento | Alleato o eventuale supporto sul lato nemico |
| Meccanica distintiva | Il comportamento che rende interessante l’unità |
| Punti di forza | Situazioni in cui eccelle |
| Debolezze | Limiti concreti e riconoscibili |
| Sinergie | Tipi di unità o effetti con cui funziona bene |
| Conflitti | Combinazioni poco efficaci o con compromessi |
| Utilità di più copie | Come interagiscono copie della stessa specie |

Spiega **quale scelta aggiunge alla composizione della squadra** e perché il giocatore dovrebbe preferirla in alcune situazioni.

## 4. Direzione visiva

Definisci:

- silhouette e proporzioni;
- dimensione relativa sul campo;
- materiali, palette e punti di contrasto;
- volto o elemento espressivo;
- armi, arti o strumenti usati per combattere;
- elemento distintivo riconoscibile a piccole dimensioni;
- orientamento e vista laterale/tre quarti;
- rapporto visivo fra aspetto e meccaniche;
- segnali visivi delle abilità e degli stati;
- differenze leggibili fra idle, movimento, attacco, lancio, danno e morte.

Elenca gli asset necessari:

- illustrazione di riferimento;
- sprite da campo;
- immagine per la scheda;
- icone delle abilità;
- animazioni;
- effetti visivi;
- suoni.

Concludi questa sezione con un **prompt visivo autonomo**, utilizzabile per creare il concept del personaggio. Se esiste un riferimento approvato, indica quali caratteristiche devono essere preservate.

## 5. Statistiche base

Proponi valori al **livello 1, senza acquisti**, con unità di misura e motivazione.

| Gruppo | Campi da definire |
|---|---|
| Sopravvivenza | Maximum Health, Armor, Magic Resistance |
| Offesa | Physical Attack, Magic Attack |
| Ritmo | Attack Speed |
| Posizionamento | Attack Range, Movement Speed, Engagement Radius |
| Abilità | Ability Power, Ability Haste, bonus area |
| Critici | Chance e moltiplicatore normale, super e ultra |
| Ripetizioni | Multi Hit, Multi Cast |
| Economia | Contributi individuali Gold, XP e Souls |
| Meccaniche proprie | Eventuali risorse, cariche o contatori |

Specifica quali statistiche sono effettivamente utilizzate dal kit. Evita statistiche presenti soltanto per riempire la scheda.

Per una risorsa speciale definisci: valore iniziale, massimo, generazione, consumo, decadimento e comportamento fra ondate, morte e Chrono break.

## 6. Attacco base

Definisci:

- nome inglese;
- descrizione breve in inglese;
- tipo di bersaglio e criterio di selezione;
- portata e necessità di linea di vista, se prevista;
- danno fisico, magico o misto;
- coefficienti e formula;
- durata del ciclo e momento dell’impatto;
- comportamento durante il movimento;
- attacco diretto, proiettile o altra modalità;
- comportamento se il bersaglio muore, scompare o esce dalla portata;
- compatibilità con critici e Multi Hit;
- eventuali effetti aggiuntivi;
- eventi che può attivare, come contatori o passive.

## 7. Abilità attive — massimo 3

Per **ogni abilità** compila tutti i campi seguenti.

### Identità e sblocco

- Nome inglese.
- Descrizione breve in inglese.
- Funzione nel kit.
- Disponibile dall’inizio o requisito di sblocco.

### Attivazione automatica

- Condizioni necessarie.
- Priorità rispetto alle altre abilità e all’attacco base.
- Comportamento se più abilità sono pronte insieme.
- Casi in cui deve attendere senza consumare il cooldown.
- Possibilità o divieto di interrompere un’altra azione.

### Bersagli e geometria

- Categorie valide: sé, alleati, nemici, evocati, cadaveri o terreno.
- Criterio di selezione e risoluzione delle parità.
- Portata di acquisizione.
- Numero massimo di bersagli.
- Forma, dimensioni e orientamento dell’area.
- Momento in cui vengono fissati bersaglio e geometria.
- Comportamento in caso di perdita del bersaglio.

### Effetti e formule

- Danno, cura, scudo, buff, debuff, controllo, evocazione o altro.
- Valori base e coefficienti.
- Statistiche da cui scala.
- Durata, frequenza degli impulsi ed eventuali limiti.
- Regole di accumulo, rinnovo e sostituzione.
- Interazione con difese, immunità e morte.

### Tempi e compatibilità

- Tempo di esecuzione.
- Momento dell’effetto.
- Cooldown e momento da cui decorre.
- Cooldown iniziale.
- Movimento durante l’esecuzione.
- Condizioni di interruzione e loro conseguenze.
- Compatibilità con AP, Haste, area, critici, Multi Hit e Multi Cast.
- Per Multi Cast: ripetizione dei bersagli, nuovo puntamento, ordine e tempi.

### Presentazione

- Segnale di preparazione.
- Animazione.
- Effetto visivo e suono.
- Indicatori necessari nell’interfaccia.

## 8. Passive — massimo 2

Per ogni passiva definisci:

- nome e descrizione breve in inglese;
- funzione nel kit;
- condizione di attivazione;
- evento esatto che viene contato;
- effetto e formula;
- bersagli;
- frequenza massima o cooldown interno;
- contatori, cariche, durata e limiti;
- interazione con Multi Hit, Multi Cast e danni periodici;
- comportamento con più copie della stessa unità;
- possibilità di attivare altre passive e protezione da cicli infiniti;
- comportamento a vita piena, alla morte e dopo resurrezione;
- persistenza fra ondate e ripristino dopo sconfitta;
- reset al Chrono break;
- indicatore visivo o UI.

Distingui esplicitamente **“per attacco”, “per colpo”, “per bersaglio” e “per uccisione”**.

## 9. Movimento e comportamento automatico

Descrivi:

- posizione consigliata in formazione;
- comportamento con postura Mobile e Hold slot;
- utilizzo della zona d’ingaggio;
- priorità iniziale consigliata;
- mantenimento e cambio del bersaglio;
- condizioni di avvicinamento;
- comportamento durante lancio e attacco;
- rientro allo slot;
- eventuali eccezioni motivate alle regole comuni.

Presenta anche una breve **sequenza decisionale**, per esempio: verifica azione in corso → valuta abilità disponibili → attacca → avvicinati → attendi/rientra.

## 10. Crescita e potenziamenti

### Punti livello

Per ogni potenziamento specifico indica:

- nome inglese;
- effetto per grado;
- numero massimo di gradi;
- costo di ogni grado;
- livelli richiesti;
- prerequisiti o esclusioni;
- ordine di applicazione rispetto agli altri bonus;
- effetto sugli acquisti precedenti e futuri.

I potenziamenti devono offrire scelte comprensibili fra aspetti del kit.

### Gold e bonus condivisi

Specifica:

- statistiche del catalogo comune utili all’unità;
- statistiche senza effetto sul kit;
- interazioni particolari con shop globale e Chrono;
- eventuali limiti necessari per evitare combinazioni incontrollate.

### Evoluzioni facoltative

Se proponi evoluzioni, indica:

- motivazione;
- soglia di livello;
- eventuali rami;
- cambiamento visivo;
- modifiche ad attive e passive;
- nuovi limiti dei potenziamenti;
- rispetto del massimo di abilità.

Se non servono, scrivi esplicitamente **“Nessuna evoluzione proposta”**.

## 11. Evocazioni e altre meccaniche speciali

Compila questa sezione soltanto se pertinente.

Per ogni entità evocata definisci:

- lato, posizione di comparsa e bersagliabilità;
- statistiche e fonte dello scaling;
- durata e limite di entità presenti;
- comportamento, movimento e azioni;
- interazione con morte dell’evocatore;
- ricompense eventualmente generate;
- interazione con buff, cure e altre evocazioni;
- pulizia a fine tentativo e Chrono break.

Per resurrezioni, marchi, trasformazioni o bonus alle ricompense, specifica condizioni, limiti, durata e protezioni contro accumuli o cicli infiniti.

## 12. Bilanciamento e verifiche

Fornisci esempi numerici iniziali di:

- danno contro un singolo bersaglio;
- danno contro un gruppo;
- cure o protezione in un intervallo dichiarato;
- tempo necessario per attivare la meccanica distintiva;
- effetto dei principali potenziamenti;
- comportamento con due o tre copie;
- interazioni con valori elevati di velocità, Haste e ripetizioni.

Dichiara tutte le ipotesi. Se non hai eseguito una simulazione, presenta i risultati come **stime aritmetiche**.

Elenca i test necessari, includendo:

- bersaglio perso durante l’azione;
- assenza di bersagli;
- morte e cura simultanee;
- attivazioni multiple nello stesso istante;
- acquisti durante un’azione;
- pause, sconfitta, salvataggio e caricamento;
- Chrono break;
- combinazioni potenzialmente infinite o dominanti.

## 13. Formato della risposta

Organizza il risultato in questo ordine:

1. **Sintesi del personaggio**.
2. **Identità visiva e prompt per il concept**.
3. **Statistiche base**.
4. **Attacco base**.
5. **Abilità attive**.
6. **Passive**.
7. **Comportamento automatico**.
8. **Potenziamenti e progressione**.
9. **Eventuali evoluzioni**.
10. **Sinergie, debolezze e rischi di bilanciamento**.
11. **Asset e sistemi tecnici necessari**.
12. **Decisioni ancora da confermare**.

Evita abilità ridondanti. Ogni elemento del kit deve avere uno scopo riconoscibile e regole abbastanza precise da poter essere implementato e verificato.
