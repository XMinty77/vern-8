; imm_register_forms: assembler register forms IML r, n / IMH r, n / IMF r, x for A, B and AR,
; INV A / INV B; numbers in decimal, hex and binary; .equ constants (one defined
; after its use); IMF with labels; mixed-case mnemonics and registers; all four
; comment styles. IMF always writes both nibbles, even when one already matches.

.equ seven, 7
.equ big, 0xC3
        IML A, 9            ; A = x9
        IMH A, 0b1010       # A = A9
        IML B, seven        // B = x7
        imh b, 0xd          % B = D7
        IML AR, 0           ; AR = x0
        IMH AR, 15          ; AR = F0
        IMF A, 255
        IMF B, 0b10000001
        IMF AR, big
        Imf a, 0
        IMF b, 0x7f
        imf ar, 128
        IMF A, late         ; constant defined at the end of the file
        IMF B, 0x9F         ; low nibble differs, high nibble already 9
        IMF B, 0x9F         ; same value again: still two words
        IMF AR, there       ; label: an instruction address
        IMF A, there
        INV A
        INV b
        inv A
        iml ar, 0xa
        IMH Ar, 0x5
        IML A, 0
        IMH A, 0
        IMF B, 0x00
        IMF A, 0x10
        IMF AR, 0x01
        IMF A, there
        JMP A
        INV A               ; skipped
there:  IMF B, there
        IMF A, 0xFF
        IMF AR, 0xFF
        IML B, 0xF
        IMH B, 0xF
        IMF AR, 0
        IMF A, seven
        IMF B, big
        HALT
.equ late, 0x96
