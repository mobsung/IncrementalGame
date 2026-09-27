# Ondate ed esiti

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

## Scelta dell'ondata, sconfitta e ripristino

Il giocatore sceglie manualmente l'ondata da ripetere. L'opzione **avanzamento automatico** è disattivata per impostazione iniziale: dopo una vittoria la squadra affronta di nuovo l'ondata scelta. Se l'opzione è attiva, ogni vittoria porta all'ondata successiva e ogni sconfitta riporta all'ondata scelta manualmente; poi il ciclo riprende da lì. L'avanzamento oltre l'ondata scelta dipende quindi da questa opzione.

La squadra conserva vita residua e morti dopo una vittoria. All'inizio di **ogni tentativo** si registra lo stato delle unità schierate; in caso di sconfitta si ripristina lo stato registrato all'inizio dell'ultimo tentativo rilevante, non quello della prima volta in cui l'ondata era stata raggiunta. Per le ripetizioni dell'ondata scelta, un nuovo tentativo dopo una vittoria parte dallo stato lasciato dalla vittoria precedente e registra un nuovo punto di ripristino. A ogni esito si risolve prima il combattimento e si assegnano le ricompense spettanti; in caso di sconfitta si ripristina lo stato previsto, poi si entra nell'eventuale pausa. Dopo la pausa e le scelte del giocatore, oppure subito se non c'è pausa, si registra lo stato iniziale del tentativo successivo immediatamente prima della sua comparsa naturale a `t = 0`. Il punto di ripristino include, per tutte le copie schierate su entrambi i lati, vita, stato vivo/morto, cooldown residui ed effetti temporanei con le rispettive durate residue registrati all'inizio dell'ultimo tentativo. Alla sconfitta le copie schierate tornano ai rispettivi slot e si azzerano bersagli, destinazioni e timer del movimento; questi valori di vita, stato vivo/morto, cooldown ed effetti tornano allo stato registrato; acquisti, livelli e altri progressi permanenti non vengono riavvolti. Gli evocati alleati e nemici scompaiono comunque, anche se erano presenti all'inizio del tentativo. Alla sconfitta attacchi e abilità incompleti vengono cancellati, così come i proiettili ancora in volo; il progresso di tali azioni non viene ripristinato. Nel nuovo tentativo le copie iniziano un ciclo d'attacco nuovo e possono usare le abilità secondo i cooldown ripristinati.

Il giocatore può ritirarsi volontariamente verso un'ondata precedente già sbloccata, senza riattivare l'XP. Il limite inferiore del ritiro è l'ondata **subito dopo l'ultimo multiplo di 10 superato**: dopo aver completato la 10 si può tornare al massimo alla 11; dopo aver completato la 20, alla 21, e così via. Prima del completamento della 10 il limite è la 1. Il Chrono break resetta la progressione delle ondate e quindi anche questo limite.

Se la squadra non riesce più a ottenere uccisioni o ad avanzare in nessuna ondata accessibile, il giocatore deve effettuare un Chrono break. Non è prevista una meccanica di riposo fuori dal combattimento come via d'uscita. Il Chrono break è sempre attivabile, anche quando assegna zero Chrono Shards, e cura e riporta in vita tutte le unità schierate.

## Pausa tra i tentativi

Il gioco può entrare in pausa **solo al termine di un tentativo**, per vittoria o sconfitta; non si arresta nel mezzo di un'ondata. Durante il combattimento il giocatore può **prenotare manualmente** una pausa: la richiesta viene consumata al prossimo esito. Può inoltre attivare **pausa alla sconfitta**, un interruttore persistente e inizialmente spento: ogni sconfitta futura mette il gioco in pausa finché il giocatore non lo disattiva. In pausa può spostare le copie già schierate tra slot disponibili, anche da un campo all'altro se hanno entrambi i ruoli, e dopo una sconfitta può selezionare un'ondata precedente entro il limite consentito.

Durante il combattimento cooldown ed effetti temporanei continuano a scorrere anche per una copia schierata morta, che non avvia nuove azioni; se viene resuscitata, può usare le abilità già tornate pronte e beneficiare degli effetti non ancora scaduti. La singola abilità può dichiarare effetti che terminano alla morte. Durante la pausa tutto il combattimento è fermo: il tempo, i cooldown e gli effetti non avanzano e non si attivano cure. La pausa si colloca dopo l'applicazione dell'esito e prima dell'avvio del tentativo seguente. Durante la pausa l'intera simulazione è ferma: non avanzano tempo, cooldown o effetti e non si attivano cure. Quando il giocatore la disattiva, il gioco riprende e non rientra in pausa per il medesimo esito. Prenotazione manuale e pausa alla sconfitta non si accumulano: un esito produce al massimo una pausa. Il Chrono break è indipendente da questa meccanica e può essere attivato in qualsiasi momento, anche durante un'ondata.

## Posizioni e movimento agli esiti

- **Vittoria e pausa:** fra ondate vinte si conservano posizione, bersaglio ancora valido, movimento e tempo residuo dell'attesa. La pausa congela questi stati; la vittoria non riporta automaticamente agli slot.

- **Sconfitta:** tutte le copie schierate tornano immediatamente ai rispettivi slot, indipendentemente dalle posizioni iniziali del tentativo. Si cancellano bersagli, destinazioni e timer del movimento e si rivaluta l'ingaggio alla ripresa. Vita, stato vivo/morto, cooldown ed effetti temporanei seguono lo snapshot già concordato: il ricollocamento non cura né resuscita. Le azioni incomplete restano cancellate.

## Struttura iniziale delle ondate

Ogni ondata prevede **12 comparizioni naturali nell'arco di 10 secondi, a intervalli costanti**: sei del tipo bilanciato e sei del tipo offensivo. L'ordine è variabile e viene generata una nuova sequenza a ogni avvio di ondata, compresi i tentativi ripetuti dello stesso numero. Non può contenere più di tre comparizioni consecutive dello stesso tipo. La prima comparizione avviene a `t = 0` e la dodicesima a `t = 10 s`: gli undici intervalli tra esse durano ciascuno `10/11 s`. La sequenza contiene:

1. **Bilanciato:** statistiche equilibrate; compare un solo nemico.
2. **Offensivo:** più attacco e meno vita del bilanciato; compaiono **tre nemici insieme**, che contano come **un'unica comparizione** delle 12. **Ognuno dei tre nemici sconfitti concede la propria ricompensa** in valuta ed esperienza.

Ogni decima ondata (10, 20, 30, ecc.) prevede anche una **tredicesima comparizione**, successiva alla finestra delle dodici comparizioni ordinarie: il nemico speciale compare **dopo i 10 secondi**. È più potente, con statistiche superiori, e concede **cinque volte l'esperienza e cinque volte la valuta** rispetto alla ricompensa di riferimento. Questo terzo tipo è generato naturalmente e deve essere sconfitto per terminare l'ondata.

Senza bonus o potenziamenti, le 12 comparizioni ordinarie contengono 24 nemici e forniscono quindi 24 XP base se l'ondata viene vinta e l'XP è disponibile. La comparizione speciale ogni dieci ondate aggiunge 5 XP base grazie al suo moltiplicatore ×5, per un totale di 29 XP base in quell'ondata. Le ricompense di riferimento per il Gold e i valori base delle statistiche saranno definiti durante il design e l'aggiunta dei singoli nemici. La pool iniziale dei tre tipi di nemici appartiene alla prima demo; potrà cambiare quando verranno aggiunti nuovi tipi.

## Regola di schieramento o esito

- La squadra perde quando muoiono tutte le unità schierate negli slot alleati. I combattenti alleati evocati sono normalmente bersagli validi per i nemici e possono attirarne gli attacchi, salvo eccezioni dichiarate dalla specifica abilità evocatrice; non impediscono però la sconfitta quando muoiono tutte le unità schierate. Se nell'ultimo gruppo di effetti simultanei muoiono sia l'ultimo nemico naturale sia l'ultima unità alleata schierata, prevale la sconfitta: l'ondata non è completata, non concede XP né aumenta il record della run, ma Gold e punti anima delle uccisioni restano acquisibili come nelle altre sconfitte.

## Regola di schieramento o esito

- Superare un'ondata non resuscita le unità morte. La vita residua delle unità sopravvissute passa all'ondata successiva. Dopo una vittoria proseguono senza reset anche cooldown, effetti temporanei e zone, proiettili già generati, evocati e abilità ancora in esecuzione, rispettando le rispettive durate. Un proiettile già lanciato può arrivare dopo il cambio d'ondata anche se chi lo ha creato è morto. Se il giocatore ha prenotato una pausa, tutta la simulazione si congela al confine prima che inizi l'ondata seguente. La resurrezione può avvenire tramite abilità o con il Chrono break; dopo una sconfitta si ripristina lo stato registrato per il tentativo, che può ancora contenere unità morte.

## Regola di schieramento o esito

- Un'unità schierata che muore durante un'ondata vinta dalle compagne riceve comunque l'esperienza spettante per quell'ondata, quando l'XP è disponibile.

## Regola di schieramento o esito

- L'ondata termina dopo che tutte le comparizioni naturali previste sono avvenute e sono morti tutti i nemici generati naturalmente. I nemici evocati dalle copie schierate sul lato nemico non ne prolungano la durata.

## Collegamenti

Crescita delle statistiche nemiche in [Nemici](02_NEMICI.md), calcolo delle ricompense in [Economia](07_ECONOMIA_E_POTENZIAMENTI.md), composizione e spostamenti fra slot in [Campo](03_CAMPO_E_SCHIERAMENTO.md), reset della run in [Chrono break](09_CHRONO_BREAK_E_SHOP.md). I comportamenti dell'unità durante il combattimento sono in [Movimento](04_MOVIMENTO_ALLEATO.md).

## Questioni aperte — 20 e 26.9

La finestra ordinaria è di 10 secondi e lo speciale compare dopo tale finestra; il preciso ritardo dello speciale e i valori concreti degli spawn restano da definire nel contenuto della demo. Le regole di esito e ripristino sono concordate. Il funzionamento a gioco chiuso resta aperto in [Offline](11_BILANCIAMENTO_E_OFFLINE.md).

## Proposte non confermate

Nessuna proposta nuova introdotta dalla suddivisione. Le possibilità future citate nel testo restano tali e non diventano contenuti obbligatori della demo.
