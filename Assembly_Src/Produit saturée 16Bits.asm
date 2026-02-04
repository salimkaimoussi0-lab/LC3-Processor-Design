.ORIG x3000

;; =============================================================
;; Rôle : Faire R1 * R2. Si ça dépasse 65535, on renvoie 65535.
;; Entrées : R1, R2
;; Sortie  : R0
;; =============================================================

MUL_SAT
    ;; 1. Sauvegarde des registres
    ST  R1, SAVE_R1
    ST  R2, SAVE_R2
    ST  R3, SAVE_R3
    ST  R4, SAVE_R4

    AND R0, R0, #0      ; R0 = 0 (Notre résultat final)
    LD  R3, COMPTEUR    ; R3 = 16 (On va faire 16 tours de boucle)

BOUCLE
    ;; --- ETAPE A : Décalage du résultat (x2) ---
    ;; Avant de faire x2, on vérifie si on est déjà trop grand.
    ;; Si le bit de gauche (MSB) de R0 est 1, alors R0 * 2 va déborder.
    ADD R0, R0, #0
    BRn SATURATION      ; Si R0 est "négatif" (bit fort à 1), on sature direct.

    ADD R0, R0, R0      ; Décalage : R0 = R0 + R0 (équivalent à x2)

    ;; --- ETAPE B : Faut-il ajouter R2 ? ---
    ;; On regarde le bit de gauche de R1.
    ADD R1, R1, #0
    BRzp PAS_AJOUT      ; Si le bit est 0 (nombre positif), on n'ajoute rien.

    ;; --- ETAPE C : Vérification de la place avant d'ajouter ---
    ;; On veut faire : R0 + R2.
    ;; On a la place seulement si : R2 <= (Place Restante).
    ;; La "Place Restante", c'est l'inverse de R0 (NOT R0).
    
    NOT R4, R0          ; R4 = Place restante
    
    ;; Test simple : Est-ce que R2 est plus grand que la place restante ?
    ;; On calcule : TEST = R2 - PlaceRestante
    NOT R4, R4          ; On remet R4 à l'endroit pour faire la soustraction...
    NOT R4, R4          ; Astuce : Pour soustraire, on fait R2 + (-Place)
    
    NOT R4, R4          ; R4 = NOT(PlaceRestante) ... c'est compliqué ?
    ;; SIMPLIFICATION POUR LA SOUTENANCE :
    ;; On compare R2 et (NOT R0). Si R2 est plus grand, ça casse.
    ;; Comparaison : R2 - (NOT R0) > 0 ?
    
    NOT R4, R0          ; R4 = NOT(R0) (Place restante)
    NOT R4, R4          ; Préparation soustraction (Inverse)
    ADD R4, R4, #1      ; R4 = -PlaceRestante
    ADD R4, R2, R4      ; R4 = R2 - PlaceRestante
    
    BRp SATURATION      ; Si R2 > PlaceRestante, ça déborde -> Saturation !

    ADD R0, R0, R2      ; Sinon, on ajoute sans danger.

PAS_AJOUT
    ;; --- ETAPE D : On passe au bit suivant ---
    ADD R1, R1, R1      ; On décale R1 vers la gauche
    ADD R3, R3, #-1     ; On décrémente le compteur
    BRp BOUCLE          ; On continue tant qu'il reste des tours

    BRnzp FIN           ; C'est fini, on sort.

SATURATION
    LD  R0, MAX_VAL     ; On charge xFFFF (le max possible)

FIN
    LD  R1, SAVE_R1     ; Restauration des registres
    LD  R2, SAVE_R2
    LD  R3, SAVE_R3
    LD  R4, SAVE_R4
    RET

;; Variables
SAVE_R1 .BLKW 1
SAVE_R2 .BLKW 1
SAVE_R3 .BLKW 1
SAVE_R4 .BLKW 1
COMPTEUR .FILL #16
MAX_VAL  .FILL xFFFF

.END