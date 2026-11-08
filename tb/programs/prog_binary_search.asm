; prog_binary_search: binary search in a sorted 16-entry table at M[60..6F] for keys that are
; present (first, last, middle) and absent (0, a gap): lo/hi/mid in short memory,
; mid = (lo + hi) >> 1 with SHR. The found index (or FF) goes to M[10..].

.equ lo, 0
.equ hi, 1
.equ mid, 2
.equ key, 3
.equ out, 4
        IMF A, 0x04
        ST A, 0x60
        IMF A, 0x11
        ST A, 0x61
        IMF A, 0x22
        ST A, 0x62
        IMF A, 0x3D
        ST A, 0x63
        IMF A, 0x5F
        ST A, 0x64
        IMF A, 0x7A
        ST A, 0x65
        IMF A, 0x8C
        ST A, 0x66
        IMF A, 0x95
        ST A, 0x67
        IMF A, 0x98
        ST A, 0x68
        IMF A, 0x9B
        ST A, 0x69
        IMF A, 0x9C
        ST A, 0x6A
        IMF A, 0xA1
        ST A, 0x6B
        IMF A, 0xD7
        ST A, 0x6C
        IMF A, 0xE9
        ST A, 0x6D
        IMF A, 0xEB
        ST A, 0x6E
        IMF A, 0xFF
        ST A, 0x6F
        IMF A, 0x10
        SST A, out
        IMF A, 0x04
        CALL find
        IMF A, 0xFF
        CALL find
        IMF A, 0x95
        CALL find
        IMF A, 0x60
        CALL find
        IMF A, 0x00
        CALL find
        IMF A, 0xA1
        CALL find
        HALT
find:   SST A, key
        IMF A, 0x60
        SST A, lo
        IMF A, 0x6F
        SST A, hi
f_loop: SLD A, lo
        SLD B, hi
        JGT f_miss
        ADD
        IMF B, 1
        SHR
        SST A, mid
        LD A, A
        SLD B, key
        JEQ f_hit
        JLT f_right
        SLD A, mid          ; key < M[mid]: hi = mid - 1
        IMF B, 0xFF
        ADD
        SST A, hi
        JMP f_loop
f_right: SLD A, mid
        INC
        SST A, lo
        JMP f_loop
f_hit:  SLD A, mid
        JMP f_out
f_miss: IMF A, 0xFF
f_out:  SLD B, out
        SWAP
        ST B, A
        INC
        SST A, out
        RET
