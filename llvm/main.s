	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 12, 0	sdk_version 12, 1
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64                     ; =64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48                    ; =48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	str	wzr, [sp, #20]
	adrp	x9, l___const.main.my_test_variable@PAGE
	add	x9, x9, l___const.main.my_test_variable@PAGEOFF
	ldr	x10, [x9]
	add	x8, sp, #24                     ; =24
	str	x10, [sp, #24]
	ldr	w9, [x9, #8]
	str	w9, [sp, #32]
	adrp	x0, l_.str@PAGE
	add	x0, x0, l_.str@PAGEOFF
	mov	x9, sp
	str	x8, [x9]
	bl	_printf
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	ldur	x9, [x29, #-8]
	subs	x8, x8, x9
	b.ne	LBB0_2
; %bb.1:
	mov	w0, #0
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
LBB0_2:
	bl	___stack_chk_fail
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l___const.main.my_test_variable:        ; @__const.main.my_test_variable
	.asciz	"Hello world"

l_.str:                                 ; @.str
	.asciz	"%s"

.subsections_via_symbols
