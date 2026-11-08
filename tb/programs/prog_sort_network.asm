; prog_sort_network: an unrolled 8-input sorting network (19 compare-exchanges, Batcher odd-even
; merge) on short memory M[0..7] using only SLD/SST: every comparator is
; SLD, SLD, JLTE, SST, SST. Inputs include equal values and both extremes.

        IMF A, 0xC3
        SST A, 0
        IMF A, 0x07
        SST A, 1
        IMF A, 0xFF
        SST A, 2
        IMF A, 0x07
        SST A, 3
        IMF A, 0x00
        SST A, 4
        IMF A, 0x80
        SST A, 5
        IMF A, 0x7F
        SST A, 6
        IMF A, 0x42
        SST A, 7
        SLD A, 0
        SLD B, 1
        JLTE ce0
        SST A, 1
        SST B, 0
ce0:
        SLD A, 2
        SLD B, 3
        JLTE ce1
        SST A, 3
        SST B, 2
ce1:
        SLD A, 4
        SLD B, 5
        JLTE ce2
        SST A, 5
        SST B, 4
ce2:
        SLD A, 6
        SLD B, 7
        JLTE ce3
        SST A, 7
        SST B, 6
ce3:
        SLD A, 0
        SLD B, 2
        JLTE ce4
        SST A, 2
        SST B, 0
ce4:
        SLD A, 1
        SLD B, 3
        JLTE ce5
        SST A, 3
        SST B, 1
ce5:
        SLD A, 4
        SLD B, 6
        JLTE ce6
        SST A, 6
        SST B, 4
ce6:
        SLD A, 5
        SLD B, 7
        JLTE ce7
        SST A, 7
        SST B, 5
ce7:
        SLD A, 1
        SLD B, 2
        JLTE ce8
        SST A, 2
        SST B, 1
ce8:
        SLD A, 5
        SLD B, 6
        JLTE ce9
        SST A, 6
        SST B, 5
ce9:
        SLD A, 0
        SLD B, 4
        JLTE ce10
        SST A, 4
        SST B, 0
ce10:
        SLD A, 1
        SLD B, 5
        JLTE ce11
        SST A, 5
        SST B, 1
ce11:
        SLD A, 2
        SLD B, 6
        JLTE ce12
        SST A, 6
        SST B, 2
ce12:
        SLD A, 3
        SLD B, 7
        JLTE ce13
        SST A, 7
        SST B, 3
ce13:
        SLD A, 2
        SLD B, 4
        JLTE ce14
        SST A, 4
        SST B, 2
ce14:
        SLD A, 3
        SLD B, 5
        JLTE ce15
        SST A, 5
        SST B, 3
ce15:
        SLD A, 1
        SLD B, 2
        JLTE ce16
        SST A, 2
        SST B, 1
ce16:
        SLD A, 3
        SLD B, 4
        JLTE ce17
        SST A, 4
        SST B, 3
ce17:
        SLD A, 5
        SLD B, 6
        JLTE ce18
        SST A, 6
        SST B, 5
ce18:
        HALT
