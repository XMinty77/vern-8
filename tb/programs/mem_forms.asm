; mem_forms: assembler memory forms for both registers: LD r, x / LD r, AR / LD r, A /
; LD r, B and the same for ST, with numbers and constants. The B forms go through
; SWAP, TAR, SWAP and must leave A and B as they were.

.equ slot, 0x42
.equ top, 0xFF
        IMF A, 0x5A
        ST A, 0x40          ; ALO, AHI, STA
        IMF B, 0xA5
        ST B, slot          ; constant address
        ST B, top
        ST A, 0
        LD B, 0x40          ; B = 5A
        LD A, slot          ; A = A5
        LD A, top
        LD B, 0x00
        ; register-addressed forms
        IMF AR, 0x41
        IMF A, 0x77
        ST A, AR            ; STA
        LD B, AR            ; LDB
        IMF B, 0x88
        ST B, AR            ; STB
        LD A, AR            ; LDA
        IMF A, 0x43         ; A holds the address
        IMF B, 0x99
        ST B, A             ; TAR, STB: M[0x43] = 99
        LD B, A             ; TAR, LDB
        ST A, A             ; M[0x43] = 43
        LD A, A             ; A = M[0x43] = 43
        IMF B, 0x44         ; B holds the address
        IMF A, 0x12
        ST A, B             ; SWAP, TAR, SWAP, STA: M[0x44] = 12, A and B kept
        LD A, B             ; A = M[0x44]
        ST B, B             ; M[0x44] = 44
        IMF A, 0
        LD A, B             ; A = 44
        LD B, B             ; B = M[0x44] = 44
        IMF A, 0x40
        LD B, A
        IMF B, 0x41
        LD A, B
        IMF AR, slot
        LD A, AR
        IMF A, 0xE0
        IMF B, 0xF0
        ST A, 0xFE
        ST B, 0x01
        LD A, 0x01
        LD B, 0xFE
        HALT
