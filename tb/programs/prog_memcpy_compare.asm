; prog_memcpy_compare: memset of 32 bytes, a memcpy of a 32-byte pattern block from M[C0..DF] to
; M[E0..FF] (up to the last address), and memcmp of the two blocks with an
; early exit at the first difference (none expected, then one planted).

.equ src, 0
.equ dst, 1
.equ n, 2
.equ res, 3
        ; memset M[C0..DF] = pattern: M[C0 + k] = k * 7 + 3
        IMF A, 0xC0
        SST A, src
        IMF A, 3
        SST A, 4
set_l:  SLD A, src
        SLD B, 4
        ST B, A
        SWAP                ; A = value
        IMF B, 7
        ADD
        SST A, 4
        SLD A, src
        INC
        SST A, src
        IMF B, 0xE0
        JNEQ set_l
        CALL copy
        CALL cmp
        IMF A, 0x55
        ST A, 0xF3          ; plant a difference
        CALL cmp
        HALT
copy:   IMF A, 0xC0
        SST A, src
        IMF A, 0xE0
        SST A, dst
cp_l:   SLD A, src
        LD B, A
        SLD A, dst
        ST B, A
        INC                 ; after FF: wraps to 00, F = 1 ends the copy
        SST A, dst
        JF cp_e
        SLD A, src
        INC
        SST A, src
        JMP cp_l
cp_e:   RET
cmp:    IMF A, 0
        SST A, res
        IMF A, 0
        SST A, n
cm_l:   SLD A, n
        IMF B, 0xC0
        ADD
        LD B, A
        SLD A, n
        SST B, 5
        IMF B, 0xE0
        ADD
        LD A, A
        SLD B, 5
        JNEQ cm_diff
        SLD A, n
        INC
        SST A, n
        IMF B, 32
        JNEQ cm_l
        RET
cm_diff: SLD A, n
        INC
        SST A, res          ; index + 1 of the first difference
        RET
