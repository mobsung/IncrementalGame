# Velocità, portata, area e Haste

Tappa completata il 27 settembre 2026, ripresa dopo il blackout. Applica le regole già concordate in Combattimento, Economia e nella scheda di John.

## Acquisti aggiunti

| Acquisto | Incremento per grado | Primo costo individuale | Primo costo globale |
| --- | --- | ---: | ---: |
| Attack Speed | +0,05 attacchi/s | 25 Gold | 75 Gold |
| Attack Range | +5 coordinate logiche | 20 Gold | Non previsto |
| Sweep Area | +5% superficie | 30 Gold | 90 Gold |
| Ability Haste | +5 punti | 35 Gold | 105 Gold |

Ogni voce ha 50 gradi e costo `ceil(C₀ × 1,20^n)`. Valori iniziali configurabili nelle Resource, da bilanciare. Il catalogo individuale sale a sette acquisti, quello globale a dieci; il Chrono shop conserva le sei voci precedenti.

## Comportamento

- I bonus individuali e globali si sommano, senza modificare le Resource delle specie.
- Un attacco già iniziato conserva il suo tempo residuo. La nuova velocità vale dal ciclo successivo.
- La portata amplia il range di azione, senza ampliare la zona d'ingaggio o la superficie della spazzata.
- Il bonus area si somma a Wide Sweep: raggio effettivo = raggio base × radice di (1 + bonus area). La forma del settore rimane invariata.
- Quick Stir sottrae secondi al cooldown base; Haste applica poi il fattore 100/(100+Haste). Un lancio conserva il cooldown calcolato al suo avvio.
- Acquisti non curano e non azzerano timer. Gli indicatori usano le statistiche effettive. La scheda mostra velocità, portata, Haste, bonus area e cooldown del prossimo lancio.

UnitStats ricostruisce le statistiche dagli acquisti; CombatantState espone il calcolo del cooldown, usato sia dal combattimento sia dall'interfaccia. Haste e area sono dati derivati: nessuna nuova migrazione necessaria, formato v3 invariato.

## Verifiche

304 controlli automatici superati con Godot 4.7: acquisti, combinazione dei bonus, tempi in corso e successivi, portata, spazzata reale oltre il raggio iniziale, Quick Stir prima di Haste, acquisto durante il lancio, ricostruzione da snapshot e persistenza al Chrono break.

Avvio e log tramite Godot AI senza errori correnti. Scheda statistiche ispezionata a 1920×1080. Il salvataggio più recente dell'utente è stato caricato dopo il blackout; nessun acquisto di test è stato addebitato. La battaglia salvata era attiva ed è stata prenotata la pausa al termine del tentativo.

Aggiornamento successivo: completate le [statistiche economiche individuali](CONTRIBUTI_INDIVIDUALI.md). Restano potenza abilità, critici avanzati, danni/difese magiche e gli altri sistemi della demo.
