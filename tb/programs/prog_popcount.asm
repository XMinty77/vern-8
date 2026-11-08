; prog_popcount: population count of every value 00 to FF two ways: Kernighan (v & (v - 1))
; and a shift-and-mask loop, compared; counts stored at M[a] for each value a.

.equ v, 0
.equ n1, 1
.equ n2, 2
.equ w, 3
.equ bad, 4
.equ i, 5
        IMF A, 0
        SST A, bad
        SST A, v
top:    ; Kernighan
        SLD A, v
        SST A, w
        IMF A, 0
        SST A, n1
k_loop: SLD A, w
        IMF B, 0
        JEQ k_end
        IMF B, 0xFF
        ADD                 ; w - 1
        SLD B, w
        AND
        SST A, w
        SLD A, n1
        INC
        SST A, n1
        JMP k_loop
k_end:  ; shift and mask, 8 rounds
        SLD A, v
        SST A, w
        IMF A, 0
        SST A, n2
        IMF A, 8
        SST A, i
s_loop: SLD A, w
        IMF B, 1
        AND
        SLD B, n2
        ADD
        SST A, n2
        SLD A, w
        IMF B, 1
        SHR
        SST A, w
        SLD A, i
        IMF B, 0xFF
        ADD
        SST A, i
        IMF B, 0
        JNEQ s_loop
        SLD A, n1
        SLD B, n2
        JEQ same
        SST A, bad
same:   SLD A, v
        IMF B, 0x11
        ADD                 ; step 0x11: 16 values, 00 to FF
        SST A, v
        JF done
        JMP top
done:   HALT
