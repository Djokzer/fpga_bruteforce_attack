# Journal - Projet Bachelor

# Semaine 1 - (13.05.2024 - 17.05.2024)

Le but de cette semaine est de mesurer les performances actuelles du bcrypt cracker sur les différents cartes FPGA.

## Nexys Video

La Nexys Video semble marcher seulement à 100 MHz.

J'ai réussi à instancier jusqu'à 22 Quadcores, c'est à dire 88 Bcrypt Core.

Il n'est pas possible d'instancier plus, non pas à cause d'un manque de ressources mais à cause des contraintes de timing.

## Kintex Ultrascale+

| Freq (MHz) 	| WNS (1 Quadcore) 	| Quadcores Max. 	| Utilisations (%)       	| WNS   	|
|------------	|------------------	|----------------	|------------------------	|-------	|
| 100        	| 5.698            	| 35             	| BRAM : 94.79, LUT : 54 	| 1.367 	|
| 200        	| 1.237            	| 35             	| BRAM : 94.79, LUT : 54 	| 0.273 	|
| 250        	| 0.43             	| -              	| -                      	| -     	|
| 275        	| 0.294            	| -              	| -                      	| -     	|
| 300        	| 0.082            	| ? < 30         	| ?                      	| ?     	|
| 325        	| -0.153           	| 0              	| 0                      	| X     	|

## Notes perso

La mise en place d'une pipeline pour la partie Blowfish devrait non seulement permettre de monter encore plus la fréquence du système mais devrait aussi permettre d'instancier plus de Bcrypt core.