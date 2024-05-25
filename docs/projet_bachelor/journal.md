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
| 100        	| 5.698            	| 36             	| BRAM : 97.50, LUT : 68   	| 0.988 	| 22'180 H/s          	|
| 200        	| 1.237            	| 36             	| BRAM : 97.50, LUT : 68   	| 0.388 	| 44'369 H/s          	|
| 250        	| 0.43             	| 36            	| BRAM : 97.50, LUT : 68    | 0.115    	| 55'450 H/s          	|
| 275        	| 0.294            	| -              	| -                        	| -     	| -                   	|
| 300        	| 0.082            	| 5              	| BRAM : 13.54, LUT : 7.87 	| 0.007 	| 9241 H/s            	|
| 325        	| -0.153           	| 0              	| 0                        	| X     	| -                   	|

On peut voir déjà que à la même fréquence que la Nexys Video, on est plus vraiment limité par les contraintes de timings mais par les ressources. On arrive donc à instancier **14** Quadcores en plus.

Le résultat le plus surprenant, c'est à quelle point le système semble marcher à 200 MHz.

## Notes perso

La mise en place d'une pipeline pour la partie Blowfish devrait non seulement permettre de monter encore plus la fréquence du système mais devrait aussi permettre d'instancier plus de Bcrypt core.

# Semaine 2 - (21.05.2024 - 24.05.2024)

Cette semaine je vais devoir mesurer les performances du Bcrypt sur un CPU et si possible de mesurer sur GPU aussi, afin des références pour les futurs optimisations.

## Programme C - Single Threaded

J'ai fait un premier programme C, juste pour tester la fonction bcrypt provenant de la libraire crypt (Librairie POSIX).

Dans ce programme j'ai lancé la fonction de hash avec un cost de 5, 10'000 fois, afin d'avoir une moyenne du temps pris par le CPU.

Résultat :
```Bash
Salt: $2b$05$dnQY/8g/fqXHs8qIjyBD2.
Time measured: 18.707516 seconds.
Hash time : 0.001871 seconds.
Hash per second: 534.544511
```

## RDV

Liste des sujets :
- Chercher la fréquence la plus élévée avec le plus de quadcore ([voir tableau](#kintex-ultrascale))

- Faire des recherches sur l'utilisation des macros pour le routage (pour définir des blocs)
- Vérifier que le design ne soit pas optimisé dû au hash qui a été hardcodé
- Faire des mesures pour le code C
- Mettre en place une communication UART pour initialiser les quadcores
- Mettre en place un protocole de communication avec de la synchronisation et gestion d'erreur pour l'UART

## Programme C - Multi Threaded

J'ai ensuite fait un programme avec des threads afin de utiliser un maximum les différents coeurs de mon processeur.

Dans mon cas, j'ai un **AMD Ryzen 7 4800U** avec **8 Cores** et **2 Threads par core**.

J'ai ainsi fait des mesures ou j'ai executé mon programme qui fait le hash 10'000 fois pour différents nombres de threads.

![](assets/stats.png)

Dans ce graphique, on peut voir les différents hashrate déduit de mon programme par rapport au nombre de threads instanciés. Le Hashrate le plus élevé est celui avec 16 threads, cela coincide avec les spécifications de mon processeur.

## Verification optimisation design

Afin de vérifier que le design n'est pas optimisé, j'ai décidé de remplacer le hash en constante par une entrée.

J'ai lancé une synthèse avec 36 Quadcores, qui est le maximum possible sur la Kyntex est le nombre de LUT utilisés a augmenté de 15%.

Maintenant que je sais que une optimisation a bien lieu, je dois refaire l'implémentation afin de vérifier que les résultats précedents sont toujours valables.

Pour ce faire, j'ai changé de méthode pour pouvoir faire l'implémentation. J'ai trouvé un exemple qui utilise les attributs afin d'empecher l'optimisation sur les signaux.

## Communication UART

Afin de pouvoir interfacer les différents quadcores, je dois mettre en place pour l'instant une communication UART.

L'idée serait de faire un système de paquets, le paquet contiendra de quoi régler un quadcore.

![](assets/communication_protocol_packet_format.png)

Afin d'avoir une communication solide, il me faut un protocole simple m'assurant que le paquet recu soit bien synchronisé.
Pour ce faire, j'ai décidé d'encoder mes paquets avec l'algorithme COBS.

Il faudrait mettre en place dans le payload un CRC afin de pouvoir vérifier l'intégrité du paquet à la reception.

![](assets/communication_protocol.png)

A la reception, on aura deux buffer. 
Le premier va accumuler les données jusqu'à reception d'un 0 qui sigifiera la fin du paquet.
Puis, pendant que le decodage aura lieu, on va récuperer le prochain paquet dans le deuxième buffer.

Après décodage, le router va s'occuper d'initialiser le bon quadcore à l'aide des informations récupérés dans le paquet.

L'idée serait de bien séparé la couche communication UART du reste, afin de pouvoir plus tard remplacé l'UART par le PCIe. 