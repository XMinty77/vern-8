; prog_crc8: CRC-8 (polynomial 07, initial 00, no reflection) over 8 bytes in data memory:
; the doubling ADD gives the shifted-out top bit in F, and JF picks the XOR.

.equ crc, 0
.equ k, 1
.equ ptr, 2
        IMF A, 0x31
        ST A, 0x50
        IMF A, 0x32
        ST A, 0x51
        IMF A, 0x33
        ST A, 0x52
        IMF A, 0x34
        ST A, 0x53
        IMF A, 0x35
        ST A, 0x54
        IMF A, 0x36
        ST A, 0x55
        IMF A, 0x37
        ST A, 0x56
        IMF A, 0x38
        ST A, 0x57
        IMF A, 0
        SST A, crc
        IMF A, 0x50
        SST A, ptr
nextb:  SLD A, ptr
        LD B, A
        SLD A, crc
        XOR
        SST A, crc
        IMF A, 8
        SST A, k
bit:    SLD A, crc
        SLD B, crc
        ADD                 ; crc << 1, F = old top bit
        JF poly
        JMP keep
poly:   IMF B, 0x07
        XOR
keep:   SST A, crc
        SLD A, k
        IMF B, 0xFF
        ADD
        SST A, k
        IMF B, 0
        JNEQ bit
        SLD A, ptr
        INC
        SST A, ptr
        IMF B, 0x58
        JNEQ nextb
        SLD A, crc          ; C7 for "12345678"
        HALT
