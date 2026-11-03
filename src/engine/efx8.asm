; 8xy sub-effects: 81-84, 86, 87
; state/ch: +0 slide, +1 tremor y, +2 tremor cnt, +3 retrig ival

; hook in pt_RpCheckEfx: a6=ch a5=paula/shadow
pt_Efx8Tick:
	MOVEM.L	D1-D2/A0,-(A7)
	BSR.W	pt_Efx8Ptr		; a0=state
	MOVE.B	(A0),D1
	BEQ.S	.noslide
	EXT.W	D1
	MOVEQ	#0,D2
	MOVE.B	(n_volume,A6),D2
	ADD.W	D1,D2
	BPL.S	.ge0
	MOVEQ	#0,D2
.ge0:	CMP.W	#64,D2
	BLS.S	.le64
	MOVEQ	#64,D2
.le64:	MOVE.B	D2,(n_volume,A6)
.noslide:
	MOVEQ	#0,D1
	MOVE.B	3(A0),D1
	BEQ.S	.noretrig
	MOVE.L	dat_RpCounter,D2
	DIVU	D1,D2
	SWAP	D2
	TST.W	D2
	BNE.S	.noretrig
	MOVEQ	#0,D2
	MOVE.B	(n_volume,A6),D2
	SUBQ.W	#4,D2
	BPL.S	.rv
	MOVEQ	#0,D2
.rv:	MOVE.B	D2,(n_volume,A6)
	; pt_RpDoRetrig falls through to pt_RpRetrigExit (move.l (a7)+,d1 / rts)
	; stack must be [d1][ret] -> push ret, d1, then jmp
	PEA	.back(PC)
	MOVE.L	D1,-(A7)
	MOVE.W	(n_pt4_chanbit,A6),D1
	JMP	pt_RpDoRetrig
.back:
.noretrig:
	MOVE.B	1(A0),D1
	BEQ.S	.notrem
	ADDQ.B	#1,2(A0)
	MOVE.B	D1,D2
	ADD.B	D2,D2
	CMP.B	2(A0),D2
	BHI.S	.notrem
	CLR.B	2(A0)
.notrem:
	MOVEM.L	(A7)+,D1-D2/A0
	MOVE.W	(n_cmd,A6),D0		; orig insns, flags for bne
	AND.W	#$0fff,D0
	RTS

; a0=state+chanbit*4 (d1 trashed)
pt_Efx8Ptr:
	MOVE.W	(n_pt4_chanbit,A6),D1
	AND.W	#7,D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	LEA	efx8_State,A0
	ADDA.W	D1,A0
	RTS

; hook at pt_RpEfx8Color start
pt_Efx8Set:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	BNE.S	.sub
	MOVE.B	(n_cmdlo,A6),D0		; y=0: orig color path
	AND.B	#$f0,D0
	RTS
.sub:	ADDQ.L	#4,A7			; skip color path, ret to caller of pt_RpCheckEfx
	MOVEM.L	D1-D2/A0,-(A7)
	BSR.S	pt_Efx8Ptr
	MOVE.B	(n_cmdlo,A6),D1
	LSR.B	#4,D1
	CMP.B	#15,D0
	BNE.S	.on
	MOVEQ	#0,D0			; y=f -> off
.on:	CMP.B	#1,D1
	BNE.S	.n1
	BSR.W	pt_Efx8Backwards	; 81y: y<>f rev, f fwd (mixed voices only)
	BRA.S	.done
.n1:	CMP.B	#2,D1
	BNE.S	.n2
	MOVE.B	D0,(A0)
	BRA.S	.done
.n2:	CMP.B	#3,D1
	BNE.S	.n3
	NEG.B	D0
	MOVE.B	D0,(A0)
	BRA.S	.done
.n3:	CMP.B	#4,D1
	BNE.S	.n4
	BSR.W	pt_Efx8Blend		; 84y: voice n (15-y)/15, n+4 y/15 (mixer only)
	BRA.S	.done
.n4:	CMP.B	#6,D1
	BNE.S	.n6
	MOVE.B	D0,3(A0)
	BRA.S	.done
.n6:	CMP.B	#7,D1
	BNE.S	.done
	CMP.B	1(A0),D0
	BEQ.S	.done
	MOVE.B	D0,1(A0)
	CLR.B	2(A0)
.done:	MOVEM.L	(A7)+,D1-D2/A0
	RTS

; hook: write vol + tremor gate
pt_Efx8SetVolume:
	JSR	pt_RpSetVolume
	MOVEM.L	D1/A0,-(A7)
	BSR.W	pt_Efx8Ptr
	MOVE.B	1(A0),D1
	BEQ.S	.r
	CMP.B	2(A0),D1		; cnt>=y -> off phase
	BHI.S	.r
	TST.B	(n_pt4_chunked,A6)
	BNE.S	.r
	CLR.W	(aud_VOL,A5)
.r:	MOVEM.L	(A7)+,D1/A0
	RTS

pt_Efx8Reset:
	MOVEM.L	D0/A0,-(A7)
	LEA	efx8_State,A0
	MOVEQ	#7,D0
.c:	CLR.L	(A0)+
	DBF	D0,.c
	CLR.L	efx8_Blend		; 84y off
	MOVEM.L	(A7)+,D0/A0
	RTS

; hook at end of pt_0EDA: scan pats for 8xy y<>0 -> warn
pt_Efx8SaveNote:
	JSR	pt_0EB7
	JSR	pt_RestorePalette
	MOVEM.L	D0-D2/A0-A1,-(A7)
	MOVEA.L	dat_ModulePtr,A0
	LEA	mod_positions(A0),A1
	MOVEQ	#0,D0
	MOVEQ	#127,D1
.pm:	MOVE.B	(A1)+,D2
	CMP.B	D0,D2
	BLS.S	.pm2
	MOVE.B	D2,D0
.pm2:	DBF	D1,.pm
	ADDQ.W	#1,D0
	MULU	#64,D0
	MULU	dat_RpNumChannels,D0
	LEA	mod_patterns(A0),A1
.cell:	MOVE.B	2(A1),D1
	AND.B	#$0f,D1
	CMP.B	#8,D1
	BNE.S	.next
	MOVE.B	3(A1),D1
	AND.B	#$0f,D1
	BNE.S	.found
.next:	ADDQ.L	#4,A1
	SUBQ.L	#1,D0
	BNE.S	.cell
	MOVEM.L	(A7)+,D0-D2/A0-A1
	RTS
.found:	MOVEM.L	(A7)+,D0-D2/A0-A1
	ST	efx8_SavePending		; shown from task poll after diskop redraw
	RTS
efx8_SaveText:	DC.B	"8XY EFFECTS: PT 4.1 ONLY",0
	EVEN

; 81y: d0=y (0=fwd) -> mixer voice backwards, no effect on paula path
; no loop: phase start = smp start
pt_Efx8Backwards:
	MOVEM.L	D1/A1,-(A7)
	TST.B	mix_Active
	BEQ.S	.r
	MOVE.W	(n_pt4_chanbit,A6),D1
	AND.W	#7,D1
	MULU	#mv_SIZEOF,D1
	LEA	mix_Voices,A1
	ADDA.W	D1,A1
	TST.B	(mv_active,A1)
	BEQ.S	.r
	TST.B	D0
	BEQ.S	.fwd
	ST	(mv_back,A1)
	TST.L	(mv_looplen,A1)
	BNE.S	.r
	MOVE.L	(n_start,A6),(mv_loopstart,A1)	; no loop: to smp start
	BRA.S	.r
.fwd:	SF	(mv_back,A1)
.r:	MOVEM.L	(A7)+,D1/A1
	RTS

; 84y: d0=y (0=off), pair n/n+4 crossfade, mixer only
; called from pt_Efx8Set (d1/a0 saved there)
pt_Efx8Blend:
	MOVE.W	(n_pt4_chanbit,A6),D1
	AND.W	#3,D1
	LEA	efx8_Blend,A0
	MOVE.B	D0,(A0,D1.W)
	RTS
