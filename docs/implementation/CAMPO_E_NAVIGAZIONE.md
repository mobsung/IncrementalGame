# Campo illustrato e navigazione

Tappa completata e verificata il 27 settembre 2026, dopo la richiesta del giocatore di una vista laterale con personaggi sul terreno e pulsanti inferiori per le meccaniche.

## Uso

- Il campo occupa la schermata. I pulsanti superiori avviano/riprendono il tentativo e prenotano una pausa al suo termine.
- **Battle** apre auto avanzamento, pausa alla sconfitta, scelta dell'ondata e **Arrange formation**. Quest'ultimo mostra gli slot sul terreno fra tentativi: cliccare un indicatore sposta John secondo le regole esistenti.
- **Units** mostra le copie schierate, attualmente John. Selezionarlo apre due schede: **Stats & formation** e **Upgrades**. Anche il clic sul personaggio nel campo apre la sua scheda.
- **Chrono** mostra il premio e il pulsante Chrono break con conferma. La tappa successiva ha aggiunto sei acquisti permanenti in Shards.
- **Global shop** contiene sette acquisti condivisi in Gold e il collegamento alle unità. Cataloghi e verifiche della tappa successiva: [shop condivisi](SHOP_CONDIVISI.md).
- Close, Escape o un secondo clic sul pulsante della sezione chiudono il pannello. Aprire i pannelli non sospende il combattimento.

## Presentazione e coordinate

Il fondale è una copia del fieldconcept.jpeg fornito dal giocatore. John e i nemici sono immagini a figura intera con trasparenza; le dimensioni configurabili seguono i riferimenti 220/160/110/300 per John, bilanciato, offensivo e speciale. Il nemico speciale riusa provvisoriamente la figura del golem di pietra.

La simulazione mantiene le proprie coordinate e distanze. FieldProjection comprime visivamente la profondità sul piano del terreno; portate, zone di ingaggio, settore dell'abilità, slot e selezione usano la stessa proiezione. La posizione dei piedi determina l'ordine di disegno. Una piccola separazione grafica fra nemici sovrapposti non modifica bersagli o danni.

CombatantVisual è una Resource per texture, altezza, orientamento e tinta. ArenaView gestisce disegno e selezione; NavigationPanels gestisce la pagina aperta; DemoController collega i pannelli alle transazioni esistenti. UpgradePanel continua a usare i cataloghi Resource. Nessuna modifica alle formule di combattimento o allo schema di salvataggio.

## Verifiche e limiti

242 controlli automatici superati con Godot 4.7, inclusi navigazione, schede, assenza di modifiche alla simulazione quando si naviga, conversione delle coordinate, clic sugli slot e sul personaggio, Escape e presenza del canale alpha.

Avvio tramite Godot AI senza errori correnti. Verifiche visive a 1920×1080 e 1280×800, comprese una battaglia con nemici e la scheda acquisti. La battaglia di prova usava una scena temporanea con persistenza disabilitata: nessun acquisto o avanzamento sul profilo reale.

Gli sprite sono una prima realizzazione statica, con una lieve oscillazione idle. Restano animazioni di movimento/attacco, arte dedicata dello speciale, effetti più rifiniti e verifica di leggibilità con squadre ed evocazioni numerose. Questa tappa rende rappresentativa la composizione visiva, senza dichiarare conclusa tutta l'arte del gioco.

Asset e prompt: [ART_NOTES](../../assets/battle/ART_NOTES.md). Per meccaniche e acquisti: [prima tappa](PRIMA_TAPPA.md) e [potenziamenti](POTENZIAMENTI_INDIVIDUALI.md).
