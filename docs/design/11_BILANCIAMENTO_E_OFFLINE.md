# Bilanciamento e progressione offline

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

## Quadro economico da bilanciare per la demo

Le regole delle risorse sono già distinte dai valori numerici da bilanciare. Ogni nemico ucciso fornisce inizialmente 1 XP base e 1 punto anima base; la ricompensa Gold base dipende dal tipo di nemico. Un'ondata ordinaria completa contiene 24 nemici naturali e quindi produce 24 XP e 24 punti anima base prima dei bonus, se le rispettive ricompense sono eleggibili. Il nemico speciale ogni dieci ondate fornisce 5 volte Gold e XP rispetto alla ricompensa di riferimento. Gold, XP e punti anima base non crescono automaticamente con il numero dell'ondata nella prima demo: Gold dipende dal tipo di nemico; XP e punti anima partono da 1 per nemico e possono cambiare per abilità e potenziamenti. Il nemico speciale applica il proprio bonus ×5 a Gold e XP, non automaticamente ai punti anima. Vita e attacco dei nemici, invece, crescono a ogni ondata.

Ripetere un'ondata già completata può produrre Gold e punti anima dalle nuove uccisioni, ma non XP né una nuova ondata massima per il calcolo dei Chrono Shards. Vincere un'ondata nuova può produrre tutte e tre le ricompense ed estendere il record della run. In caso di sconfitta restano il Gold e i punti anima dei nemici già uccisi, mentre l'XP del tentativo è annullata. Durante un'ondata i punti anima e gli eventuali Dust che produrrebbero restano provvisori: alla vittoria o alla sconfitta entrano nel pool e assegnano Dust; se il giocatore effettua un Chrono break a metà ondata vengono scartati. Il Chrono break azzera anche tutti i punti anima già presenti nel pool, ma lascia il Dust assegnato nei tentativi conclusi.

La curva XP della prima demo è fissata a `arrotonda_per_eccesso(30 × 1,30^(L-1))`. La soglia iniziale del pool di punti anima nella prima demo è `S = 20`; il costo di 5 Dust per evocazione è provvisorio. Il Gold base viene definito **per tipo di nemico** quando lo si progetta; prezzi, incrementi e limiti vengono definiti **per singolo potenziamento**. I punti anima base dei nemici partono tutti da 1, ma sono aumentabili con le meccaniche del gioco. Non occorre fissare un unico valore universale per queste voci.

Per confrontare le scelte numeriche vanno stabiliti obiettivi di ritmo: ondate o tempo necessari al primo livello, al primo acquisto utile, alla prima evocazione e al primo Chrono break significativo. Con soglia iniziale `S`, ottenere cinque Dust consecutivi nella stessa run richiede `S × (1 + 2 + 3 + 4 + 5) = 15S` punti anima complessivi; con il valore iniziale concordato `S = 20` sono 300 punti anima. Poiché il pool si resetta al Chrono break mentre il Dust resta, il ritmo delle run brevi rispetto a quelle lunghe va verificato nel bilanciamento.

## Configurabilità del bilanciamento

Quando inizierà l'implementazione, **ogni tipo di potenziamento in qualsiasi meccanica dovrà essere completamente configurabile** per facilitare il bilanciamento. Devono poter essere modificati senza riscrivere la logica almeno: effetto e statistiche influenzate, valore base, incremento per grado, costo iniziale, crescita del costo, limite di acquisti, eventuali soglie o requisiti e pool o stadio di applicazione dei bonus. Il principio vale per gli shop Gold, i potenziamenti con punti livello, il Chrono shop e le meccaniche aggiunte in futuro. La soluzione tecnica sarà definita nella fase di implementazione; per ora si continua con il design.

## Questioni aperte — bilanciamento, punto 21

Misurare tempo al primo livello, acquisto utile, evocazione e Chrono break significativo; confrontare run brevi e lunghe. I valori appartengono alle rispettive meccaniche: statistiche delle specie in Unità/Nemici, acquisti in Economia/Chrono shop, probabilità in Collezione. Non duplicare qui i cataloghi. Tutti i tipi di potenziamento e i parametri concordati devono restare configurabili.

## Progressione offline — punto 28, prevista; regole di calcolo aperte

**Prima politica autorizzata e implementata il 30 settembre 2026:** simulazione esatta della squadra e del tentativo salvati, massimo iniziale 15 minuti, limite configurabile. Parte solo da combattimento; preparazione e pause restano ferme, la pausa prenotata viene rispettata, la prima sconfitta interrompe l'offline senza cambiare la preferenza online. Non effettua acquisti, gacha o Chrono break automatici. Usa i normali esiti/ricompense, lasciando provvisori i guadagni del tentativo in corso. Elaborazione distribuita tra frame, interrompibile con conservazione dei progressi già calcolati e scarto del tempo rimanente; riepilogo alla riapertura. Il tempo viene consumato dal timestamp scritto dopo il calcolo. Nessuna assegnazione retroattiva dal formato v8; un orologio retrocesso concede zero tempo. [Implementazione, configurazione e verifiche](../implementation/MECCANICHE_BASE.md). Le note seguenti descrivono il precedente rinvio; restano aperti bilanciamento del limite, accelerazione per intervalli lunghi e budget delle piattaforme finali.

Il giocatore ha confermato il 26 settembre 2026 che la progressione offline sarà prevista, rimandandone l'implementazione a quando il gioco sarà funzionante. Restano da decidere come proseguono combattimento, ricompense, sconfitte, pause e Chrono break a gioco chiuso, eventuali limiti e il metodo di calcolo. Dipendenze: [Ondate](06_ONDATE_ED_ESITI.md), [Economia](07_ECONOMIA_E_POTENZIAMENTI.md) e [Chrono break](09_CHRONO_BREAK_E_SHOP.md).

È concordato salvare lo stato completo del tentativo e riprenderlo alla riapertura. La prima tappa implementa questa ripresa senza avanzare il tempo trascorso a gioco chiuso; simulazione separata dalla grafica e timestamp preparano il lavoro successivo. Dettagli tecnici in [Prima tappa](../implementation/PRIMA_TAPPA.md).

## Proposte non confermate

Nessuna proposta nuova introdotta dalla suddivisione. Le possibilità future citate nel testo restano tali e non diventano contenuti obbligatori della demo.
