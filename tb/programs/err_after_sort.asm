; err_after_sort: a valid insertion sort of 8 bytes runs for a while, then the program reads
; the unwritten element just past the array.

; expect: error

.equ i, 0
.equ j, 1
.equ key, 2
        IMF A, 0x37
        ST A, 0x80
        IMF A, 0x05
        ST A, 0x81
        IMF A, 0xC2
        ST A, 0x82
        IMF A, 0x05
        ST A, 0x83
        IMF A, 0xFF
        ST A, 0x84
        IMF A, 0x00
        ST A, 0x85
        IMF A, 0x80
        ST A, 0x86
        IMF A, 0x7F
        ST A, 0x87
        IMF A, 0x81
        SST A, i
outer:  SLD A, i
        LD B, A
        SST B, key
        SST A, j
inner:  SLD A, j            ; j > 0x80 and M[j-1] > key: shift
        IMF B, 0x80
        JEQ place
        IMF B, 0xFF
        ADD
        LD A, A             ; M[j-1]
        SLD B, key
        JLTE place
        SLD A, j
        IMF B, 0xFF
        ADD                 ; A = j - 1
        LD B, A             ; B = M[j-1]
        INC                 ; A = j
        ST B, A             ; M[j] = M[j-1]
        IMF B, 0xFF
        ADD                 ; A = j - 1
        SST A, j
        JMP inner
place:  SLD A, j
        SLD B, key
        ST B, A
        SLD A, i
        INC
        SST A, i
        IMF B, 0x89         ; one past the end: off-by-one bug on purpose
        JNEQ outer
        HALT
