# Journal - Projet Bachelor

# Semaine 1 - (13.05.2024 - 17.05.2024)

Le but de cette semaine est de mesurer les performances actuelles du bcrypt cracker sur les différents cartes FPGA.

## Simulation

Pour un cost de **5**, un Bcrypt core prend **649'225** coups d'horloge.

## Nexys Video

La Nexys Video semble marcher seulement à **100 MHz**.

J'ai réussi à instancier jusqu'à **22** Quadcores, c'est à dire **88** Bcrypt Core.
Donc, on a un hashrate de 13'554 Hash/s.

Il n'est pas possible d'instancier plus, non pas à cause d'un manque de ressources mais à cause des contraintes de timing.

## Kintex Ultrascale+

| Freq (MHz) 	| WNS (1 Quadcore) 	| Quadcores Max. 	| Utilisations (%)         	| WNS   	| Hashrate (cost : 5) 	|
|------------	|------------------	|----------------	|--------------------------	|-------	|---------------------	|
| 100        	| 5.698            	| 36             	| BRAM : 97.50, LUT : 54   	| 0.988 	| 22'180 H/s          	|
| 200        	| 1.237            	| 36             	| BRAM : 97.50, LUT : 54   	| 0.388 	| 44'360 H/s          	|
| 250        	| 0.43             	| -              	| -                        	| -     	| -                   	|
| 275        	| 0.294            	| -              	| -                        	| -     	| -                   	|
| 300        	| 0.082            	| 5              	| BRAM : 13.54, LUT : 7.87 	| 0.007 	| 9241 H/s            	|
| 325        	| -0.153           	| 0              	| 0                        	| X     	| -                   	|

On peut voir déjà que à la même fréquence que la Nexys Video, on est plus vraiment limité par les contraintes de timings mais par les ressources. On arrive donc à instancier **13** Quadcores en plus.

Le résultat le plus surprenant, c'est à quelle point le système semble marcher à 200 MHz.

## Notes perso

La mise en place d'une pipeline pour la partie Blowfish devrait non seulement permettre de monter encore plus la fréquence du système mais devrait aussi permettre d'instancier plus de Bcrypt core.

# Semaine 2 - (21.05.2024 - 24.05.2024)

Cette semaine je vais devoir mesurer les performances du Bcrypt sur un CPU et si possible de mesurer sur GPU aussi, afin des références pour les futurs optimisations.

## Programme C - Single Threaded

J'ai fait un premier programme C, juste pour tester la fonction bcrypt provenant de la libraire crypt (Librairie POSIX).

Pour ce programme, le hash a pris 2.595 ms. J'ai donc un hashrate de 385 !