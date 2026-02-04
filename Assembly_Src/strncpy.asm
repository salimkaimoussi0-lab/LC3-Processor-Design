.ORIG x3000
    ; --- Initialisation ---
    LEA R1, SOURCE      ; R1 pointe sur "Architecture"
    LEA R2, DEST        ; R2 pointe sur la destination vide
    LD  R0, COUNT       ; R0 = 5 (nombre de caractères à copier)

    ; --- Boucle strncpy ---
LOOP
    ADD R0, R0, #0      ; Vérifier si le compteur R0 est à 0
    BRnz FIN            ; Si R0 <= 0, on a fini de copier le nombre demandé

    LDR R3, R1, #0      ; Charger le caractère depuis la Source
    STR R3, R2, #0      ; Copier vers la Destination
    
    BRz FIN             ; Si c'est le caractère nul (fin de chaine), on arrête
                        ; (même si le compteur n'est pas fini)

    ADD R1, R1, #1      ; Avancer pointeur Source
    ADD R2, R2, #1      ; Avancer pointeur Destination
    ADD R0, R0, #-1     ; Décrémenter le compteur (il reste un caractère de moins à copier)
    BRnzp LOOP          ; Boucler

FIN
    HALT

    ; --- Données ---
SOURCE  .STRINGZ "Architecture"
COUNT   .FILL #5                ; On veut copier seulement les 5 premiers lettres
DEST    .BLKW #20               ; Zone vide de 20 mots
.END