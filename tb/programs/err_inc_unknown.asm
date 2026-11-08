; err_inc_unknown: INC on an unknown A (INC reads only A; B is never needed).

; expect: error

        INC
        HALT
