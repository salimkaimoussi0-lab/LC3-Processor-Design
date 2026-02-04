# Conception et Extension d'Architecture Processeur (LC-3)
## 📖 Présentation

Ce projet porte sur la **conception micro-architecturale** et la programmation bas niveau d'un processeur 16-bits basé sur l'architecture LC-3.

L'objectif était de modifier le chemin de données (Datapath) et l'unité de contrôle pour implémenter de nouvelles instructions natives, tout en optimisant des algorithmes complexes en Assembleur pur.

---

## 🛠️ Modifications Architecturales (Hardware)

Le processeur a été simulé au niveau porte logique sous **Logisim**. Les extensions suivantes ont été intégrées au jeu d'instructions (ISA) :

* **Instruction `XOR` (Ou Exclusif) :** Modification de l'ALU pour supporter l'opération bit-à-bit native.
* **Instruction `POPCNT` (Population Count) :** Ajout d'un circuit combinatoire (Arbre de Wallace ou approche itérative) pour calculer le poids de Hamming (nombre de bits à 1) en un seul cycle d'instruction.
* **Gestion des aléas :** Optimisation du cycle de fetch/decode.

---

## 💻 Algorithmique Assembleur

Développement d'une bibliothèque de routines optimisées pour cette architecture contrainte :

* **Arithmétique Saturée :** Implémentation de la multiplication 16-bits avec gestion de la saturation (clamping) en cas de débordement (Overflow), au lieu du comportement cyclique standard.
* **Manipulation de Chaînes (`strcpy`, `strncpy`) :** Gestion manuelle des pointeurs mémoire et des boucles de copie avec détection de fin de chaîne (Null-terminated).
* **Détection de Débordement (`Clz/Ctz`) :** Algorithmes de comptage de zéros (Leading/Trailing Zeros) pour la prédiction de débordement avant opérations arithmétiques.
* **Recherche (`index`) :** Algorithme de recherche de caractère optimisé en nombre de cycles.

---

## 📂 Structure du Projet

```bash
LC3-Processor-Design/
├── 📂 Hardware/         # Circuits de simulation (.circ - Logisim)
│   ├── LC-3-v1.circ     # Version standard
│   └── LC-3-v2.circ     # Version étendue (XOR, POPCNT...)
├── 📂 Assembly_Src/     # Code source Assembleur (.asm)
│   ├── débordement.asm  # Prédiction d'overflow
│   ├── strcpy.asm       # Manipulation mémoire
│   └── ...
└── 📂 Documentation/    # Rapport technique d'architecture
