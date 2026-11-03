; dyn envelopes: undyn mod, keep iff envelope
; dyn = vol envelope: w nseg, w pad, per seg: w len(words), w vol 0-64
; table SECSTRT_4: ptr,len per smp; bit in dat_RpChunkedSamples
; mod: bit 7 of smp finetune byte, 8svx: chunk "DYN "
; undyn = bake envelope into smp data (byte * vol / 64)

; hook: loader, read envelope; undyn mod on -> bake in and free
pt_DynModRead:
	MOVE.L	dat_FileHandle,D1
	JSR	pt_CheckModHeader
	BTST	#4,dat_UIBitFlags	; UNDYN MOD
	BEQ.S	.r
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	dat_CurrentSample,D7
	LEA	SECSTRT_4,A3
	MOVE.W	D7,D1
	LSL.W	#3,D1
	ADDA.W	D1,A3			; a3 = entry (ptr, len)
	MOVE.W	D7,D1
	LSL.W	#2,D1
	LEA	dat_ModulePtr,A0
	MOVE.L	(124,A0,D1.W),D2	; smp len in bytes
	MOVEA.L	(0,A0,D1.W),A0		; Sampledaten
	MOVEA.L	(A3),A1			; Huellkurve
	BSR.S	pt_DynApply		; trashes d0-d2/d7/a0-a2
	MOVE.W	dat_CurrentSample,D7
	MOVEA.L	(A3),A1			; free envelope, clear bit
	MOVE.L	(4,A3),D0
	CLR.L	(A3)
	CLR.L	(4,A3)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	MOVE.L	dat_RpChunkedSamples,D1
	BCLR	D7,D1
	MOVE.L	D1,dat_RpChunkedSamples
	MOVEA.L	dat_ModulePtr,A0	; clear envelope-follows bit 7
	MULU	#s_SIZEOF,D7
	ANDI.B	#$7f,(14,A0,D7.W)
	LEA	dyn_MsgUndyn(PC),A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.r:	RTS

; a1=envelope a0=smp d2=len
pt_DynApply:
	MOVEA.L	A0,A2
	ADDA.L	D2,A2			; end
	MOVE.W	(A1)+,D1		; nseg
	BLE.S	.r
	ADDQ.W	#2,A1
.seg:	MOVEQ	#0,D7
	MOVE.W	(A1)+,D7		; len in words
	ADD.L	D7,D7
	MOVE.W	(A1)+,D2		; vol
.b:	CMPA.L	A2,A0
	BGE.S	.r
	TST.L	D7
	BLE.S	.next
	MOVE.B	(A0),D0
	EXT.W	D0
	MULS	D2,D0
	DIVS	#64,D0
	MOVE.B	D0,(A0)+
	SUBQ.L	#1,D7
	BRA.S	.b
.next:	SUBQ.W	#1,D1
	BGT.S	.seg
.r:	RTS

; hook: iff loader, undyn iff off -> keep envelope = set chunk bit
pt_DynIffKeep:
	MOVE.L	D1,-(A7)
	MOVE.W	dat_CurrentSample,D0
	MOVE.L	dat_RpChunkedSamples,D1
	BSET	D0,D1
	MOVE.L	D1,dat_RpChunkedSamples
	MOVE.L	(A7)+,D1
	RTS

dyn_MsgUndyn:	DC.B	"UNDYNNING...",0
	EVEN
