
.ORIG x3000

; --- PROGRAMME PRINCIPAL DE TEST ---
MAIN
    ; Initialisation de la pile (Stack Pointer)
    LD  R6, STACK_START

    ; Test 1 : Pas de débordement (Ex: 10 * 10)
    ; 10 = b1010 (CLZ=12). Somme CLZ = 24. 24 >= 16 -> Pas de débordement.
    AND R1, R1, #0
    ADD R1, R1, #10
    AND R2, R2, #0
    ADD R2, R2, #10
    JSR PREDICT_OVF     ; Résultat attendu dans R0 : < 0
    ST  R0, RES_TEST1

    ; Test 2 : Débordement sûr (Ex: 2^10 * 2^10 = 2^20)
    ; 2^10 = 1024 (CLZ=5). Somme CLZ = 10. 10 <= 14 -> Débordement.
    LD  R1, VAL_BIG
    LD  R2, VAL_BIG
    JSR PREDICT_OVF     ; Résultat attendu dans R0 : > 0
    ST  R0, RES_TEST2

    HALT

; Données de test
STACK_START .FILL xFD00
VAL_BIG     .FILL x0400 ; 1024
RES_TEST1   .BLKW 1
RES_TEST2   .BLKW 1


; Description : Prédit si R1 * R2 va déborder en utilisant CLZ.
; Entrées : R1, R2 (Opérandes non signés)
; Sortie  : R0 
;           < 0 : Pas de débordement (Somme des zéros >= 16)
;             0 : Risque (Somme des zéros == 15)
;           > 0 : Débordement sûr (Somme des zéros <= 14)

PREDICT_OVF
    ; Sauvegarde des registres (Convention Callee-Save)
    ADD R6, R6, #-1
    STR R7, R6, #0      ; Sauvegarder R7 (Adresse de retour)
    ADD R6, R6, #-1
    STR R1, R6, #0      ; Sauvegarder R1
    ADD R6, R6, #-1
    STR R2, R6, #0      ; Sauvegarder R2
    ADD R6, R6, #-1
    STR R3, R6, #0      ; Sauvegarder R3 (Accumulateur)

    ; 1. Calculer CLZ(R1)
    JSR CLZ             ; R0 = clz(R1)
    ADD R3, R0, #0      ; R3 = clz(R1)

    ; 2. Calculer CLZ(R2)
    LD  R1, SAVE_R2_TMP ; Recharger la valeur originale de R2 dans R1 pour l'appel
    JSR CLZ             ; R0 = clz(R2)
    ADD R3, R3, R0      ; R3 = clz(R1) + clz(R2) = Z_total

    ; 3. Analyser Z_total
    ; Seuil critique : 15.
    ; Si Z_total - 15 < 0 (<= 14) -> Débordement sûr
    ; Si Z_total - 15 = 0 (== 15) -> Risque
    ; Si Z_total - 15 > 0 (>= 16) -> Pas de débordement
    
    ADD R3, R3, #-15    ; R3 = Z_total - 15

    BRn P_OVF_YES       ; Négatif -> Z <= 14
    BRz P_OVF_RISK      ; Zéro    -> Z == 15
    BRp P_OVF_NO        ; Positif -> Z >= 16

P_OVF_YES
    AND R0, R0, #0
    ADD R0, R0, #1      ; R0 = 1 (>0)
    BR  PRED_DONE

P_OVF_RISK
    AND R0, R0, #0      ; R0 = 0
    BR  PRED_DONE

P_OVF_NO
    AND R0, R0, #0
    ADD R0, R0, #-1     ; R0 = -1 (<0)
    BR  PRED_DONE

PRED_DONE
    ; Restauration des registres
    LDR R3, R6, #0
    ADD R6, R6, #1
    LDR R2, R6, #0
    ST  R2, SAVE_R2_TMP ; Astuce : on garde R2 en mémoire temporaire pour l'étape 2 ci-dessus
    ADD R6, R6, #1
    LDR R1, R6, #0
    ADD R6, R6, #1
    LDR R7, R6, #0
    ADD R6, R6, #1
    RET

SAVE_R2_TMP .BLKW 1


; SOUS-ROUTINE : CLZ 
; Entrée : R1
; Sortie : R0
; Méthode : clz(x) = ctz(reverse(x))

CLZ
    ADD R6, R6, #-1
    STR R7, R6, #0      ; Sauve R7
    ADD R6, R6, #-1
    STR R1, R6, #0      ; Sauve R1

    JSR REVERSE         ; R0 = reverse(R1)
    
    ADD R1, R0, #0      ; On passe le résultat renversé comme entrée à CTZ
    JSR CTZ             ; R0 = ctz(reverse(x)) = clz(x)

    LDR R1, R6, #0
    ADD R6, R6, #1
    LDR R7, R6, #0
    ADD R6, R6, #1
    RET


; Entrée : R1
; Sortie : R0
; Méthode : ctz(x) = POPCNT(x XOR (x-1)) - 1

CTZ
    ADD R6, R6, #-1
    STR R2, R6, #0      ; Sauve R2
    ADD R6, R6, #-1
    STR R3, R6, #0      ; Sauve R3

    ; R2 = x - 1
    ADD R2, R1, #-1

    ; R3 = x XOR (x-1)
    ; Utilisation de l'instruction étendue XOR
    XOR R3, R1, R2

    ; R0 = POPCNT(R3)
    ; Utilisation de l'instruction étendue POPCNT
    POPCNT R0, R3

    ; Résultat = POPCNT - 1
    ADD R0, R0, #-1

    LDR R3, R6, #0
    ADD R6, R6, #1
    LDR R2, R6, #0
    ADD R6, R6, #1
    RET


REVERSE
    ADD R6, R6, #-1
    STR R1, R6, #0
    ADD R6, R6, #-1
    STR R2, R6, #0
    
    AND R0, R0, #0      ; Résultat = 0
    AND R2, R2, #0
    ADD R2, R2, #15     
    ADD R2, R2, #1      ; Compteur R2 = 16

REV_LOOP
    ADD R0, R0, R0      ; R0 << 1
    
    ADD R1, R1, #0      ; Test MSB de R1 (sign bit)
    BRzp REV_SKIP_INC   ; Si positif, le bit était 0, rien à faire
    ADD R0, R0, #1      ; Si négatif, le bit était 1, on ajoute 1 à R0
REV_SKIP_INC
    
    ADD R1, R1, R1      ; R1 << 1 (Décale R1 pour le prochain tour)
    ADD R2, R2, #-1     ; Décrémenter compteur
    BRp REV_LOOP

    LDR R2, R6, #0
    ADD R6, R6, #1
    LDR R1, R6, #0
    ADD R6, R6, #1
    RET

.END
