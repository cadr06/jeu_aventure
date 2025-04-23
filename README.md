# Jeu d’Aventure Textuel en Swift

Bienvenue dans ce projet de **jeu d’aventure en ligne de commande**, développé en **Swift**. Le joueur explore un monde virtuel, interagit avec des personnages, collecte des objets, résout des énigmes et peut sauvegarder sa progression.

---

## 🎮 Présentation du jeu

Ce jeu permet au joueur de :
- Se déplacer entre différentes **salles**
- Découvrir et ramasser des **objets**
- Parler à des **personnages**
- Résoudre des **énigmes**
- Gérer un **inventaire**
- Sauvegarder et recharger sa partie

L’univers du jeu est défini dans un fichier JSON (`game.json`) que le moteur lit au lancement.

### 🕹️ Commandes disponibles

- Se déplacer : `go [direction]`
- Observer la salle : `look`
- Prendre un objet : `take [objet]`
- Voir l’inventaire : `inventory`
- Utiliser un objet : `use [objet]`
- Voir votre position sur la carte : `showmap`
- Afficher l’aide : `help`
- Quitter le jeu : `quit`

---

## ▶️ Comment lancer le jeu

### 1. Pré-requis

- macOS ou Linux
- Swift installé (`swift --version` pour vérifier)

### 2. Commandes

```bash
cd chemin/vers/jeu-aventure
swift run
