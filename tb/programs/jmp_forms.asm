; jmp_forms: JMP in every form: bare JMP (AR as set), JMP label, JMP AR, JMP A,
; JMP B (A and B kept), forward and backward jumps, a jump to the next word,
; and a jump whose target was computed with ADD. Skipped words change
; registers, so a wrong jump shows in the state.

        IMF AR, t1
        JMP                 ; bare: PC = AR
        INV A
t1:     JMP t2              ; ALO, AHI, JMP
        INV B
back:   IMF A, 0x11
        JMP t5
t2:     IMF A, t3
        IMF B, 0x5B
        JMP A               ; TAR, JMP
        INV B
t3:     IMF B, t4
        IMF A, 0x5A
        JMP B               ; SWAP, TAR, SWAP, JMP: A = 5A and B = t4 afterwards
        INV A
        INV B
t4:     IMF AR, back
        JMP AR              ; plain JMP, backward
t5:     IMF AR, t6
        JMP                 ; target is the very next word
t6:     IMF A, base
        IMF B, 4
        ADD                 ; A = base + 4 = t7
        JMP A
base:   INV A
        INV A
        INV B
        INV B
t7:     IMF B, 0x77
        HALT
