import matplotlib.pyplot as plt
import numpy as np

# Données pour la consommation horaire (Wh)
heures = np.arange(0, 25)  # De 0 à 24 heures
consommation = {
    'CPU': 25,   # Max 25W
    'GPU': 125,  # Max 125W
    'FPGA UART': 3.2,  # Max 3.2W
    'FPGA PCIe': 11.7  # Max 11.7W
}

# Calcul de la consommation cumulée en Wh pour chaque architecture
consommation_cumulee = {arch: [puissance * h for h in heures] for arch, puissance in consommation.items()}

# Création du graphique
fig, ax = plt.subplots(figsize=(12, 8))

# Tracer la consommation énergétique cumulée
for label, data in consommation_cumulee.items():
    ax.plot(heures, data, label=f'{label} Consommation', linestyle='-', marker='o')

# Configuration du graphique
ax.set_xlabel('Temps (heures)')
ax.set_ylabel('Consommation énergétique (Wh)')
ax.set_title('Évolution de la consommation énergétique sur une période de 24 heures')
ax.grid(True)
ax.legend(loc='upper left')

# Ajuster la mise en page pour éviter le chevauchement
fig.tight_layout()

# Sauvegarde de l'image
plt.savefig('consommation_evolution_24_heures.png')
plt.show()
