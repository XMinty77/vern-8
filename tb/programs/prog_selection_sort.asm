; prog_selection_sort: selection sort, descending, of 12 bytes at M[40..4B]: find the maximum of
; the unsorted tail with JGT, swap it to the front. Pointers live in short memory.

.equ i, 0
.equ j, 1
.equ best, 2
.equ bval, 3
.equ tmp, 4
.equ endp, 0x4C
        IMF A, 0x10
        ST A, 0x40
        IMF A, 0xF0
        ST A, 0x41
        IMF A, 0x33
        ST A, 0x42
        IMF A, 0x00
        ST A, 0x43
        IMF A, 0xFF
        ST A, 0x44
        IMF A, 0x7F
        ST A, 0x45
        IMF A, 0x80
        ST A, 0x46
        IMF A, 0x33
        ST A, 0x47
        IMF A, 0x01
        ST A, 0x48
        IMF A, 0xAA
        ST A, 0x49
        IMF A, 0x55
        ST A, 0x4A
        IMF A, 0xFE
        ST A, 0x4B
        IMF A, 0x40
        SST A, i
outer:  SLD A, i
        SST A, best
        LD B, A
        SST B, bval
        INC
        SST A, j
scan:   SLD A, j
        IMF B, endp
        JEQ do_swap
        LD A, A             ; A = M[j]
        SLD B, bval
        JLTE next
        SST A, bval
        SLD A, j
        SST A, best
next:   SLD A, j
        INC
        SST A, j
        JMP scan
do_swap: SLD A, i
        LD B, A             ; B = M[i]
        SLD A, best
        ST B, A             ; M[best] = M[i]
        SLD B, bval
        SLD A, i
        ST B, A             ; M[i] = max
        INC
        SST A, i
        IMF B, 0x4B
        JNEQ outer
        HALT
