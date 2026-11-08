; sweep_inc_all: INC through all 256 values of A from 00, with F set by STF before every
; INC: INC must clear F for 00..FE and set it at FF -> 00, which ends the loop.

        IMF A, 0
loop:   STF
        INC
        JF done
        JMP loop
done:   CLF
        INC                 ; 00 -> 01, F stays 0
        HALT
