# Spaghetti Golem e inventario — 2026-09-27

Aggiornamento 2026-09-29: il pass procedurale del 28 settembre è sostituito da nove sprite sheet, 144 pose sorgente per le tre forme. Movimento, Jab/Sweep e abilità usano veri fotogrammi raster. Risorse, mappatura e preview F6 in `content/units/warriors/spaghetti_golem/visuals/animations/`; PNG e prompt in `visuals/spritesheets/`. Nessuna modifica a gameplay o salvataggi. Suite aggiornata: 434 controlli, zero fallimenti; preview e breve battaglia senza persistenza verificate. Rimangono variazioni artistiche tra pose generate; non è una pulizia manuale pixel-perfect.

Sostituzione di John autorizzata dall'utente: eliminare le copie possedute e assegnare una sola copia base, non convertire livelli o acquisti individuali.

## Contenuto

Tutta la specie si trova in `content/units/warriors/spaghetti_golem/`, suddivisa in forme, abilità, potenziamenti, grafica, gacha e concept. I sistemi generici rimangono in `scripts/`; configurazioni condivise in `resources/`. Anche nemici e concept del Dice Summoner sono raggruppati per entità.

Tre forme Rare: Noodle Squire, Saucebound Knight, Spaghetti Golem. Evoluzioni manuali con conferma ai livelli 10 e 25; nessun aumento automatico delle statistiche base e nessuna cura gratuita. Mantengono XP/livello/acquisti Gold individuali, rimborsano i punti livello spesi e azzerano i relativi gradi, come da regola generale già concordata (questa prevale sulla frase divergente del concept). Unità schierate evolvono solo tra tentativi, quelle in riserva anche durante la battaglia.

HP 320, attacco 20, armor/MR 12, AP 20. Distanze del concept convertite in 100 coordinate logiche per unità: range 130, movimento 220, ingaggio 350. Jab colpisce al 25% del ciclo e recupera fino al termine; Sweep colpisce a 0,4 s e termina a 0,6 s, cono frontale bloccato all'avvio, massimo tre bersagli per applicazione. Coefficiente 130%/130%/150%, raggio 160/160/180, cooldown 8 s minimo 4. Multi Hit/Multi Cast non moltiplicano la generazione di Sauce.

Slow Simmer ogni 4 s: 1,5%/1,5%/2% HP massimi +10% AP. Dalla seconda forma Sauce Reserve arriva a 5 accumuli: ciascuno +1% attacco/armor e +0,25% HP per tick. Un accumulo per azione offensiva originale riuscita. Guard richiede HP <=70% e 2 Sauce, senza consumarli: cast 0,35 s, cura 3% HP +25% AP, buff 6 s (+10% attacco/+12% armor, raddoppia Simmer), cooldown 12 s minimo 8. Surge nella forma finale ha priorità: HP <=35%, 4 Sauce consumati all'effetto, cast 0,5 s, cura 8% HP +50% AP, buff 5 s (+20% attacco/+15% armor), cooldown 24 s minimo 16. Requisiti ricontrollati all'effetto; niente critici o ripetizioni per queste cure.

Bonus personali sommati e limitati a +35% attacco/+40% armor, applicati dopo gli acquisti permanenti/condivisi. Timers fissi di battaglia salvati; pause non li avanzano. Simmer valuta il buff presente al tick, prima degli effetti delle nuove azioni nello stesso tick. Danno letale prevale sulle cure simultanee. Sauce e avanzamento del tick si azzerano a nuova ondata, sconfitta, morte e Chrono; morte azzera anche buff attivi. Acquisti e caricamenti ricostruiscono gli attributi senza comporre ripetutamente i bonus.

Quattro potenziamenti da un punto/rango: Sauce Infusion (+0,25% HP Simmer, cap 1/2/3), Meatball Training (+8 punti percentuali Sweep, cap 1/2/3), Thickened Glaze (+2 punti percentuali armor Guard, cap 0/2/3), Core Tempering (+1 punto percentuale cura Surge, cap 0/0/2).

## Salvataggio v8

Le versioni precedenti sono sostituite da una formazione iniziale con un Noodle Squire livello 1. Rimangono valute, acquisti globali/Chrono, record di ondata e progressi Souls/Dust. Copie, XP/livelli, acquisti individuali e tentativo provvisorio vengono rimossi. Si riparte in preparazione, senza combattimento automatico. I salvataggi v8 mantengono normalmente tutte le copie/evoluzioni future: il reset non si ripete.

Prima dell'operazione sul profilo reale è stata creata una copia indipendente `user://first_demo.before_spaghetti_v8.save`; i normali backup `.bak` continuano a funzionare.

## Verifica e limiti

Suite corrente `tests/run_spaghetti_tests.gd`, avviata tramite Godot AI in `tests/runtime_test_runner.tscn`. La vecchia suite numerica John/v7 è archiviata come testo in `tests/legacy/`. Le tre texture singole restano ritratti; l'arena usa le nuove tavole animate. Nessuna verifica di bilanciamento a lungo termine o audio.
