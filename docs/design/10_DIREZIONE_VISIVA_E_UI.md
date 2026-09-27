# Direzione visiva e interfaccia

[Indice e stato del design](00_INDICE.md). Documento operativo derivato dal CORE_DESIGN originale, conservato intatto.

## Decisioni concordate e specifiche

Aggiornamento del 27 settembre 2026: il giocatore ha confermato il campo illustrato con personaggi visti lateralmente e profondità sul terreno, usando il fieldconcept.jpeg nuovamente allegato. Barra inferiore con accesso a unità schierate e loro potenziamenti, Chrono break/Chrono shop e shop globale. La nuova presentazione è implementata nella [tappa campo e navigazione](../implementation/CAMPO_E_NAVIGAZIONE.md). Questo supera il campo geometrico provvisorio e i riferimenti storici all'uso di campo.png. Animazioni definitive e shop completi restano da realizzare.

## Indicatori del movimento

- **Indicatori:** selezionare la copia mostra distintamente portata attuale, zona centrata sullo slot, postura e collegamento allo slot. Tratteggi o simboli distinguono gli indicatori anche senza affidarsi soltanto al colore.

## Direzione visiva — riferimenti per il punto 27.1

**Aggiornamento del 26 settembre 2026:** dopo il reset degli asset richiesto dal giocatore, la prima tappa usa un campo e segnaposto geometrici nuovi. L'uso diretto di `campo.png` citato sotto è storico; i riferimenti estetici continuano a guidare l'arte futura. Il nuovo ritratto approvato di John compare nell'interfaccia.

I riferimenti forniti dal giocatore sono `fieldconcept.png` per il campo e `noodlegolem.png` per il design di una unità. Il primo propone un'arena fantasy illustrata e ricca di dettagli, con rovine, vegetazione e luce naturale sul lato alleato e un lato nemico più cupo, arido e illuminato da accenti rossi. La fascia inferiore integra l'interfaccia nell'estetica del mondo con pietra scura e ornamenti. La differenza visiva fra i due lati aiuta a leggere la direzione dello scontro, senza cambiare le regole degli slot o introdurre una condizione di sconfitta territoriale.

Il secondo riferimento mostra una unità volutamente insolita e riconoscibile: un golem di spaghetti con massa di pasta, pugni a polpetta, armatura di vetro, cuore visibile e gambe sottili di legno. La scheda distingue vista frontale, laterale e posteriore, dettagli materiali e un'idea di animazione idle. Le unità future non hanno alcun vincolo tematico comune: la rosa deve poter comprendere qualunque tema, da uno spadaccino classico a un golem fatto di spaghetti. Il riferimento indica la cura per sagoma, materiali e dettagli narrativi della singola unità, senza imporre ingredienti, specie, epoche o lore condivise.

La coerenza visiva della rosa deriva dalla resa, non da un tema narrativo obbligatorio: illustrazione 2D materica, illuminazione coerente con il campo, scala compatibile fra sprite e sagome riconoscibili. Ritratti e schede possono essere ricchi di dettagli, mentre le versioni usate sul campo conservano soprattutto forma, colori ed elementi distintivi leggibili anche a dimensioni ridotte. Materiali, forme e origini delle singole unità sono liberi. Marker degli slot, barre di vita, effetti e numeri dovranno restare leggibili sopra un fondale elaborato. Le categorie in battaglia si distinguono con indicatori associati ai personaggi, senza ricolorare la loro illustrazione: le copie schierate del giocatore hanno un segno alla base riconoscibile su entrambi i lati; gli evocati alleati usano una variante distinta perché non impediscono la sconfitta; i nemici combattenti hanno una barra e un segno ostile. Una copia del giocatore schierata sul lato nemico conserva il segno di proprietà e indica il ruolo di supporto non attaccabile. Gli effetti delle abilità conservano l'estetica della singola unità ma usano segnali funzionali coerenti, riconoscibili anche dalla forma o dall'icona oltre che dal colore, per danno, cura, protezione, marchi, evocazioni e tre stadi critici. Gli effetti ordinari sono brevi e discreti nelle ondate affollate, mentre quelli decisivi ricevono maggiore risalto. Colori e forme esatte appartengono al design dell'interfaccia. La rarità viene mostrata soprattutto nella scheda della copia, nel roster e nell'evocazione tramite cornice e simbolo; non impone colore, materiale o dimensione alla sua illustrazione. Sul campo può comparire quando la copia viene selezionata, senza aggiungere un indicatore permanente durante il combattimento. Per la prima demo resta valido l'uso già deciso di `campo.png` come sfondo provvisorio; `fieldconcept.png` guida la direzione estetica successiva, salvo nuova decisione.

## Riferimenti di scala sul campo

Le immagini `camporef1.png` e `camporef2.png` mostrano lo Spaghetti Golem sovrapposto a un campo nello stile di `fieldconcept.png`. La prima illustra una presenza media di circa **220 px** di altezza; la seconda confronta circa **300 px** (grande), **220 px** (media), **160 px** (piccola/standard) e **110 px** (minima). Nella prima demo questi numeri guidano le taglie iniziali: circa 220 px per una unità imponente come lo Spaghetti Golem, 160 px per il nemico bilanciato, 110 px per ciascun nemico offensivo che compare in un gruppo di tre e per evocati piccoli, 300 px per il nemico speciale ogni dieci ondate. Sono riferimenti alla risoluzione e alla composizione mostrate, non statistiche di gameplay né limiti universali per specie, rarità o lato del campo. La scala concreta rimane adattabile alla singola unità e deve restare leggibile con tre copie alleate schierate, gruppi di tre nemici e altri evocati.

## Identità visiva delle evoluzioni

Visivamente, ogni evoluzione conserva almeno un tratto distintivo della specie ma modifica chiaramente sagoma e animazione in relazione alle abilità e passive che acquisisce o cambia. Rami alternativi devono essere distinguibili anche sul campo, non soltanto da una ricolorazione. L'evoluzione non comporta per regola una semplice crescita di dimensioni, dato che non aumenta direttamente le statistiche base.

## Riferimenti forniti nuovamente

Il 25 settembre 2026 sono state mostrate in chat le immagini fieldconcept.jpeg, noodlegolem.jpeg, grandezze.jpeg e unitaincampo.jpeg, presenti allora nella cartella Downloads del giocatore. Le ultime due mostrano rispettivamente il confronto 300/220/160/110 px e la presenza del golem da circa 220 px. Corrispondono per contenuto ai riferimenti di scala descritti nel documento originale; non si assume che siano gli stessi file dei vecchi nomi camporef1.png/camporef2.png. Non sono state copiate nella cartella di design. campo.png e area.png restano riferimenti distinti e non sono stati forniti in quel gruppo di immagini.

## Questioni aperte — 27.1 e 27.5

L'identità visiva generale è concordata. Restano realizzazione finale del campo, layout UI, segnali precisi, animazioni, presentazione di numeri ed effetti e verifica della leggibilità in scene affollate. Le dimensioni illustrative non determinano distanze o statistiche; le regole della mappa sono in [Campo](03_CAMPO_E_SCHIERAMENTO.md).

## Proposte non confermate

Nessuna proposta nuova introdotta dalla suddivisione. Le possibilità future citate nel testo restano tali e non diventano contenuti obbligatori della demo.
