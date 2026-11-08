; mem_fill_all: every data memory address 00 to FF written and read back: M[a] = ~a
; ascending with A as the pointer (INC carry ends the loop), checked by reading
; back; then M[a] = a descending (ADD 0xFF as decrement, no carry ends it),
; and a final read-back pass with LDB and LDA through TAR.

        IMF A, 0
fill:   TAR
        INV A
        STA                 ; M[a] = ~a
        INV A
        INC                 ; F = 1 after FF -> 00
        JF check
        JMP fill
check:  TAR                 ; A = 0 here
        LDB
        INV B               ; B = a if memory held ~a
        JNEQ bad
        INC
        JF down
        JMP check
down:   IMF A, 0xFF
        IMF B, 0xFF
dloop:  TAR
        STA                 ; M[a] = a
        ADD                 ; A = a - 1, F = 0 only when a was 0
        JF dloop
        IMF A, 0
again:  TAR
        LDB
        LDA
        JNEQ bad
        INC
        JF done
        JMP again
done:   HALT
bad:    IMF B, 0xBD
        HALT
