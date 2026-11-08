; prog_add32: 32-bit addition and subtraction over little-endian numbers in data memory
; (M[30..33] + M[34..37] -> M[38..3B], then minus): the carry/borrow chain is
; kept in short memory and folded in with INC (add) or an extra SUB of 1 (sub).

.equ i, 0
.equ c, 1
.equ t, 2
.equ op, 3
        IMF A, 0xFF
        ST A, 0x30
        IMF A, 0xFF
        ST A, 0x31
        IMF A, 0x7F
        ST A, 0x32
        IMF A, 0x80
        ST A, 0x33
        IMF A, 0x01
        ST A, 0x34
        IMF A, 0x00
        ST A, 0x35
        IMF A, 0x80
        ST A, 0x36
        IMF A, 0x7F
        ST A, 0x37
        IMF A, 0
        SST A, op           ; 0 = add
        CALL run
        IMF A, 1
        SST A, op           ; 1 = subtract
        CALL run
        ; second operand pair: 00000000 - 00000001 (borrow all the way), then plus
        IMF A, 0x00
        ST A, 0x30
        IMF A, 0x00
        ST A, 0x31
        IMF A, 0x00
        ST A, 0x32
        IMF A, 0x00
        ST A, 0x33
        IMF A, 0x01
        ST A, 0x34
        IMF A, 0x00
        ST A, 0x35
        IMF A, 0x00
        ST A, 0x36
        IMF A, 0x00
        ST A, 0x37
        CALL run
        IMF A, 0
        SST A, op
        CALL run
        HALT
run:    IMF A, 0
        SST A, i
        SST A, c
r_loop: SLD A, i
        IMF B, 0x34
        ADD
        LD B, A             ; B = y[i]
        SLD A, i
        IMF AR, 0x30
        SWAP
        SST A, t            ; t = y[i]
        SWAP
        IMF B, 0x30
        ADD
        LD A, A             ; A = x[i]
        SLD B, t
        SST A, t            ; t = x[i] now, B = y[i]
        SLD A, op
        SWAP                ; A = y[i], B = op
        SST A, 5
        IMF A, 0
        EQ                  ; F = (op == 0)
        SLD A, t
        SLD B, 5
        JF do_add
        SUB                 ; F = borrow
        SST A, t
        IMF A, 0
        JF bor1
        SST A, 6            ; borrow1 = 0
        JMP bor2
bor1:   IMF A, 1
        SST A, 6
bor2:   SLD A, t
        SLD B, c
        SUB                 ; minus the old borrow
        SST A, t
        JF bor3
        SLD A, 6
        SST A, c
        JMP store
bor3:   IMF A, 1
        SST A, c
        JMP store
do_add: ADD                 ; F = carry
        SST A, t
        IMF A, 0
        JF car1
        SST A, 6
        JMP car2
car1:   IMF A, 1
        SST A, 6
car2:   SLD A, t
        SLD B, c
        ADD
        SST A, t
        JF car3
        SLD A, 6
        SST A, c
        JMP store
car3:   IMF A, 1
        SST A, c
store:  SLD A, i
        IMF B, 0x38
        ADD
        SLD B, t
        ST B, A
        SLD A, i
        INC
        SST A, i
        IMF B, 4
        JNEQ r_loop
        RET
