.ORIG x3000
    ; --- Initialisation ---
    LEA R1, SOURCE      ; R1 pointe sur "Bonjour"
    LD  R2, CHAR        ; R2 contient 'j' (x006A)

    ; --- Programme ---
    AND R0, R0, #0      ; R0 = 0 par défaut
    NOT R4, R2
    ADD R4, R4, #1      ; R4 = -R2 (pour comparer)

LOOP
    LDR R3, R1, #0      ; Charger caractère actuel
    BRz FIN             ; Si 0 (fin de chaine), on quitte
    
    ADD R5, R3, R4      ; Comparer (R3 - R2)
    BRz TROUVE          ; Si 0, on a trouvé !

    ADD R1, R1, #1      ; Caractère suivant
    BRnzp LOOP

TROUVE
    ADD R0, R1, #0      ; R0 prend l'adresse du caractère trouvé

FIN
    HALT

    ; --- Données ---
SOURCE  .STRINGZ "Bonjour"
CHAR    .FILL x006A         ; 'j' en hexadécimal
.END