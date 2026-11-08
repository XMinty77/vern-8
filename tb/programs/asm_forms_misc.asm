; asm_forms_misc: the remaining assembler forms and syntax: compare-and-jump, JF, JMP
; and CALL to numeric addresses and .equ constants, LD/ST with constant addresses,
; .org with a constant, labels on a .org line and on the line before one, tabs,
; blank and comment-only lines, lowercase physical mnemonics.

.equ target, 0x40
.equ fn, 0x64
.equ slot, 14
	imf a, 0x10		; tabs
	imf b, 0x10

	jeq target		// taken: numeric target through a constant
	halt
; comment-only line
#another
.org target
	ssta slot
	sldb slot
	jneq 0x50		; not taken: A == B
	jgte 0x50		; taken
	halt
before:
.org 0x50			; "before" names 0x50
	call fn
	call 0x64
	imf a, fn
	call a
	stf
	jf after
	halt
func:	.org fn		; "func" names 0x64
	inc
	ret
after:	.org 0x70
	st a, slot		; ALO, AHI, STA to M[0x0E]
	st b, target		; data address 0x40, unrelated to the code there
	ld a, target
	ld b, slot
	imf ar, func
	call ar
	clf
	jf before		; not taken
	imf a, done
	jmp a
	halt
done:	inc
	halt
