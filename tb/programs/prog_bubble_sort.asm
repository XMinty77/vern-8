; prog_bubble_sort: bubble sort, ascending, of 16 bytes at M[20..2F] (duplicates, 00, FF, 7F/80),
; with a swapped flag in data memory and pointer arithmetic through TAR.

.equ j, 0
.equ x, 2
.equ swapped, 4
.equ last, 0x2F
        IMF A, 0x5A
        ST A, 0x20
        IMF A, 0x03
        ST A, 0x21
        IMF A, 0xFF
        ST A, 0x22
        IMF A, 0x80
        ST A, 0x23
        IMF A, 0x00
        ST A, 0x24
        IMF A, 0x7F
        ST A, 0x25
        IMF A, 0x41
        ST A, 0x26
        IMF A, 0x41
        ST A, 0x27
        IMF A, 0xC8
        ST A, 0x28
        IMF A, 0x12
        ST A, 0x29
        IMF A, 0x99
        ST A, 0x2A
        IMF A, 0x01
        ST A, 0x2B
        IMF A, 0xFE
        ST A, 0x2C
        IMF A, 0x64
        ST A, 0x2D
        IMF A, 0x23
        ST A, 0x2E
        IMF A, 0xB7
        ST A, 0x2F
outer:  IMF A, 0
        SST A, swapped
        IMF A, 0x20
        SST A, j
inner:  SLD A, j
        LD B, A             ; B = M[j]
        INC
        LD A, A             ; A = M[j+1]
        JGTE noswap         ; already in order
        SST A, x
        SLD A, j
        TAR
        SLD A, x
        ST A, AR            ; M[j] = old M[j+1]
        SLD A, j
        INC
        TAR
        ST B, AR            ; M[j+1] = old M[j]
        IMF A, 1
        SST A, swapped
noswap: SLD A, j
        INC
        SST A, j
        IMF B, last
        JNEQ inner
        SLD A, swapped
        IMF B, 0
        JNEQ outer
        HALT
