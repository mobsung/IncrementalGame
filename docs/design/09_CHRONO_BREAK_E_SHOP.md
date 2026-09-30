# Chrono break e shop

[Indice e stato del design](00_INDICE.md). Documento operativo; originale conservato intatto.

## Movimento — azioni, geometria e transizioni

- **Chrono break:** la postura individuale resta memorizzata; le copie iniziano la nuova run dagli slot scelti, senza bersagli, destinazioni o timer di movimento precedenti.

## Chrono break

La meccanica precedentemente chiamata prestigio prende il nome di **Chrono break** e la sua valuta si chiama **Chrono Shards**.

La ricompensa usa un pool base crescente con `W`, la **più alta ondata completata nella run**. Un'ondata ancora in corso non conta; ripetere ondate già superate non aumenta `W`. Al pool base si sommano gli altri contributi additivi applicabili, poi si applicano i moltiplicatori: `Chrono Shards ottenuti = (base(W) + somma dei bonus additivi) × prodotto dei moltiplicatori dei pool`. Come per le altre ricompense, i bonus percentuali all'interno dello stesso pool si sommano e i pool distinti si moltiplicano. Le fonti dei bonus restano da definire; anche i Chrono Shards conservano le frazioni nel totale assegnato e nel saldo, senza arrotondamenti che alterino la progressione.

**Curva iniziale concordata:** `base(W) = (W / 10)^2`. Produce 1 Chrono Shard base alla 10, 4 alla 20, 9 alla 30, 25 alla 50 e 100 alla 100. Come gli altri valori di bilanciamento, la curva potrà essere rivista in futuro se necessario. La formula conserva i valori frazionari durante il calcolo e non introduce da sola una soglia minima di ondata. Il confronto tra ricompensa e durata effettiva delle run dovrà verificare il vantaggio di avanzare rispetto a ripetere Chrono break brevi.

Il Chrono break resetta le ondate e riapre la possibilità di ottenere XP affrontandole nuovamente. **Non resetta** valuta globale, livelli, XP, stadio evolutivo, statistiche permanenti o potenziamenti delle unità; le unità e i loro investimenti rimangono. È sempre attivabile, anche durante un'ondata e con zero Chrono Shards ottenibili, senza attendere una pausa; riporta in vita e cura completamente le unità schierate. È il momento ordinario in cui si può cambiare quali unità occupano gli slot; fra Chrono break è consentito riposizionare quelle già in campo. Il Chrono break interrompe subito le azioni in corso e cancella proiettili, zone ed effetti temporanei positivi o negativi, oltre a tutti i nemici naturali ed evocati e agli evocati alleati. Dopo l'interruzione si apre una fase di preparazione senza combattimento, distinta dalla pausa fra ondate: il giocatore può scegliere nuovamente le copie schierate e collocarle in qualsiasi posizione compatibile, rispettando i limiti e mantenendo almeno un'unità sul lato alleato. Il tempo della simulazione non avanza. L'ondata scelta viene riportata alla 1. Le impostazioni persistenti di avanzamento automatico e pausa alla sconfitta mantengono il proprio valore, mentre una richiesta manuale di pausa ancora prenotata viene cancellata. L'ondata 1 della nuova run inizia solo alla conferma della squadra; le copie schierate sono vive e a vita piena, con abilità pronte e nessuna azione parzialmente eseguita. Progressione e potenziamenti permanenti restano. I Chrono Shards base dipendono dalla **più alta ondata completata nella run**; iniziare un'ondata senza completarla non aumenta il premio. Se il Chrono break viene attivato durante un'ondata, il combattimento termina immediatamente: il Gold e l'XP generati in quell'ondata vengono scartati anche per i nemici già uccisi, mentre i nemici ancora vivi scompaiono senza concedere ricompense. Le ricompense delle ondate e dei tentativi conclusi in precedenza restano possedute. La curva iniziale dei Chrono Shards base è concordata; gli utilizzi generali sono definiti nel Chrono shop; costi e requisiti specifici restano da sviluppare.

Questo crea una scelta ricorrente: continuare a ottenere valuta senza XP per tentare di superare una soglia, oppure resettare le ondate e usare una nuova progressione per allenare la squadra e le copie aggiuntive.

## Chrono shop — prima demo

**Configurazione iniziale autorizzata il 30 settembre 2026:** catalogo implementato di 23 voci, prezzi e incrementi nelle Resource; Multi Hit e Multi Cast costano inizialmente 25 Shards ciascuno, un solo grado (+1 ripetizione compatibile). Un posto alleato a 50 Shards porta il limite da tre a quattro senza cambiare i nove slot fisici. I requisiti di record sono configurabili e inizialmente zero. [Tabella completa e limiti della verifica](../implementation/MECCANICHE_BASE.md). Questi dati sostituiscono i rinvii al catalogo/prezzi ancora da definire della fotografia storica qui sotto; il bilanciamento definitivo resta da verificare.

Il primo utilizzo dei **Chrono Shards** è il **Chrono shop**. Tutti i suoi potenziamenti sono **globali e permanenti**: si applicano alle unità e alle abilità pertinenti, comprese quelle ottenute successivamente, e rimangono acquistati e attivi attraverso i Chrono break. Lo shop offre potenziamenti generici delle statistiche. Offre sia bonus **additivi**, che entrano nella fase additiva del calcolo della statistica pertinente, sia bonus **moltiplicativi** che introducono un **pool dedicato al Chrono shop**, distinto dagli altri pool della stessa statistica. I bonus percentuali applicabili alla stessa statistica all'interno di questo pool si sommano; il moltiplicatore risultante si moltiplica con quelli degli altri pool secondo la regola generale.

Lo shop deve inoltre offrire, a **costi elevati**:

- Lo sblocco di un nuovo slot per le unità alleate, aumentando il limite di unità schierabili contemporaneamente.
- Potenziamenti di **multi hit** e **multi cast**, mantenendone il carattere raro e limitato e la compatibilità dichiarata dalle singole abilità.
- Potenziamenti di **super crit chance**, **super crit damage**, **ultra crit chance** e **ultra crit damage**. Restano validi il limite del 100% per ciascuna chance e la dipendenza di ogni stadio critico dal precedente.

Il catalogo preciso delle statistiche generiche, i prezzi, la crescita dei costi, gli incrementi, i limiti di acquisto ed eventuali requisiti restano da definire. Lo sblocco concordato per la demo riguarda un nuovo posto alleato; ulteriori slot e quelli sul lato nemico restano da progettare.

## Collegamenti

Ricompense: [Economia](07_ECONOMIA_E_POTENZIAMENTI.md). Posizioni: [Campo](03_CAMPO_E_SCHIERAMENTO.md). Evoluzioni: [Unità](01_UNITA.md). Significato delle statistiche: [Combattimento](05_COMBATTIMENTO_E_ABILITA.md).

## Questioni aperte — 19

Curva base e utilizzi generali dello shop sono concordati. Restano catalogo preciso delle statistiche generiche, prezzi, crescita dei costi, incrementi, limiti, requisiti e ulteriori slot oltre quello alleato della demo. Valutare ritmo dei reset e vantaggio delle run lunghe con [Bilanciamento](11_BILANCIAMENTO_E_OFFLINE.md).

## Proposte non confermate

Nessuna nuova proposta introdotta dalla migrazione.
