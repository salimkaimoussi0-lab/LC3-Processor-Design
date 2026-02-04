.ORIG x3000
    ; --- Initialisation des pointeurs ---
    LEA R1, SOURCE      ; R1 pointe sur le début de "CopieMoi"
    LEA R2, DEST        ; R2 pointe sur l'espace vide

    ; --- Boucle de copie (strcpy) ---
LOOP
    LDR R3, R1, #0      ; Charger le caractère depuis la Source (R1)
    STR R3, R2, #0      ; Copier le caractère vers la Destination (R2)
    
    BRz FIN             ; Si le caractère est 0 (fin de chaîne), on arrête

    ADD R1, R1, #1      ; Avancer le pointeur Source
    ADD R2, R2, #1      ; Avancer le pointeur Destination
    BRnzp LOOP          ; Recommencer

FIN
    HALT

    ; --- Données ---
SOURCE  .STRINGZ "CopieMoi" ; La chaîne à copier
DEST    .BLKW #20           ; CORRECTION ICI : Ajout du # devant 20
.END