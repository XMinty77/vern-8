; mem_short_all: SLDA, SLDB, SSTA, SSTB (and the SLD r, n / SST r, n forms) at all 16
; short addresses 0 to F: store from A, read into B, overwrite from B, read into
; A, then back-to-back store/load on the same address.

        ; A to all 16 short addresses (physical SSTA for 0-7, form SST A for 8-15)
        IMF A, 0xA5
        SSTA 0x0
        IMF A, 0xB4
        SSTA 0x1
        IMF A, 0x87
        SSTA 0x2
        IMF A, 0x96
        SSTA 0x3
        IMF A, 0xE1
        SSTA 0x4
        IMF A, 0xF0
        SSTA 0x5
        IMF A, 0xC3
        SSTA 0x6
        IMF A, 0xD2
        SSTA 0x7
        IMF A, 0x2D
        SST A, 8
        IMF A, 0x3C
        SST A, 9
        IMF A, 0x0F
        SST A, 10
        IMF A, 0x1E
        SST A, 11
        IMF A, 0x69
        SST A, 12
        IMF A, 0x78
        SST A, 13
        IMF A, 0x4B
        SST A, 14
        IMF A, 0x5A
        SST A, 15
        ; read every address back into B (SLDB / SLD B)
        SLD B, 0
        SLDB 0x1
        SLD B, 2
        SLDB 0x3
        SLD B, 4
        SLDB 0x5
        SLD B, 6
        SLDB 0x7
        SLD B, 8
        SLDB 0x9
        SLD B, 10
        SLDB 0xB
        SLD B, 12
        SLDB 0xD
        SLD B, 14
        SLDB 0xF
        ; overwrite all 16 from B (SSTB / SST B), in reverse order
        IMF B, 0xA5
        SSTB 0xF
        IMF B, 0xB4
        SST B, 14
        IMF B, 0x87
        SSTB 0xD
        IMF B, 0x96
        SST B, 12
        IMF B, 0xE1
        SSTB 0xB
        IMF B, 0xF0
        SST B, 10
        IMF B, 0xC3
        SSTB 0x9
        IMF B, 0xD2
        SST B, 8
        IMF B, 0x2D
        SSTB 0x7
        IMF B, 0x3C
        SST B, 6
        IMF B, 0x0F
        SSTB 0x5
        IMF B, 0x1E
        SST B, 4
        IMF B, 0x69
        SSTB 0x3
        IMF B, 0x78
        SST B, 2
        IMF B, 0x4B
        SSTB 0x1
        IMF B, 0x5A
        SST B, 0
        ; read back into A (SLDA / SLD A)
        SLD A, 0
        SLDA 0x1
        SLD A, 2
        SLDA 0x3
        SLD A, 4
        SLDA 0x5
        SLD A, 6
        SLDA 0x7
        SLD A, 8
        SLDA 0x9
        SLD A, 10
        SLDA 0xB
        SLD A, 12
        SLDA 0xD
        SLD A, 14
        SLDA 0xF
        ; load and store the same address back to back, and a store of a just-loaded value
        SLD A, 3
        SST A, 12
        SLD B, 12
        SST B, 0
        SLD A, 0
        SST A, 15
        SST B, 15
        SLD A, 15
        HALT
