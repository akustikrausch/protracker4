; filter editor: types 0-9, do it / try it
; ty0 lp1 y+=a*(x-y), a=w/(1+w)   ty1 hp1 x-lp
; ty2 bp2 chamberlin svf, q 1..20   ty3/4 shelf x+g*lp / x+g*hp
; ty5 comb y=x+fb*y[n-D]
; ty6 allpass v=x+g*v[n-D], y=v[n-D]-g*v
; ty7 delay w=x+fb*w[n-D], y=x+out*w[n-D]
; ty8 multitap y=x+out*(x[-t1]/2+..+x[-t4]/16), t=60/120/180/240ms
; ty9 waveshape y=x*(3-x*x)/2
; ty6-8 need a 4096 word ring buf, alloc only while filtering
; fs=8287; curve (270 x 0..30, 0=top) scales par1 min..set

FLT_SEGS	EQU	270			; curve width
FLT_HIST	EQU	4096			; hist ring (words, pow2)

SAT16	MACRO				; \1=Dn long, clamp +-32767
	CMP.L	#32767,\1
	BLE.S	.lo\@
	MOVE.L	#32767,\1
.lo\@:	CMP.L	#-32767,\1
	BGE.S	.ok\@
	MOVE.L	#-32767,\1
.ok\@:
	ENDM

;--- gad dispatch (hook for CMP.W #4,D2 in pt_0A43)
pt_FltIds41:
	CMP.W	#$0004,D2
	BEQ.S	pt_FltDoIt41
	CMP.W	#$0005,D2
	BEQ.W	pt_FltTryIt41
	JMP	pt_FilterGadgetsRest	; value fields as before

; do it: after try it keep result, else filter
pt_FltDoIt41:
	TST.L	flt_TryPtr
	BEQ.S	.apply
	BSR.W	pt_FltFree41
	LEA	flt_MsgKept(PC),A0
	JMP	pt_ShowStatusMsg
.apply:	BSR.W	pt_FltRange41
	BEQ.S	.r
	BSR.W	pt_FltProcess41
.r:	RTS

; try it: backup + filter; 2nd try it = restore
pt_FltTryIt41:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.L	flt_TryPtr
	BNE.S	.restore
	BSR.W	pt_FltRange41
	BEQ.W	.done
	MOVE.L	A1,flt_TrySrc
	MOVE.L	D3,flt_TryLen
	MOVE.L	D3,D0
	MOVEQ	#0,D1			; MEMF_ANY
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)		; AllocMem
	TST.L	D0
	BEQ.S	.nomem
	MOVE.L	D0,flt_TryPtr
	MOVEA.L	D0,A0
	MOVEA.L	flt_TrySrc,A1
	MOVE.L	flt_TryLen,D3
	BSR.W	pt_FltCopy41		; smp -> backup
	MOVEA.L	flt_TrySrc,A1
	MOVE.L	flt_TryLen,D3
	BSR.W	pt_FltProcess41
	LEA	flt_MsgTry(PC),A0
	JSR	pt_ShowStatusMsg
	BRA.S	.done
.nomem:	JSR	pt_SetupPaletteMode
	BRA.S	.done
.restore:
	BSR.W	pt_FltRange41		; restore only if smp and range unchanged
	BEQ.S	.drop
	CMPA.L	flt_TrySrc,A1
	BNE.S	.drop
	CMP.L	flt_TryLen,D3
	BNE.S	.drop
	MOVEA.L	flt_TryPtr,A1		; backup -> smp
	MOVEA.L	flt_TrySrc,A0
	BSR.W	pt_FltCopy41
	BSR.W	pt_FltFree41
	LEA	flt_MsgUndo(PC),A0
	JSR	pt_ShowStatusMsg
	JSR	pt_RecordCheckInput	; redraw sampler
	BRA.S	.done
.drop:	BSR.W	pt_FltFree41
.done:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; a1 -> a0, d3=len
pt_FltCopy41:
	SUBQ.L	#1,D3
	BMI.S	.r
.l:	MOVE.B	(A1)+,(A0)+
	SUBQ.L	#1,D3
	BPL.S	.l
.r:	RTS

; free backup (also at exit)
pt_FltFree41:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	flt_TryPtr,D0
	BEQ.S	.r
	MOVEA.L	D0,A1
	MOVE.L	flt_TryLen,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	CLR.L	flt_TryPtr
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

; a1=start d3=len, Z=no smp (as BOOST)
pt_FltRange41:
	MOVEQ	#0,D3
	MOVE.W	dat_EffectData0,D3
	BEQ.S	.none
	ADD.L	D3,D3
	MOVE.L	dat_EffectBuf,D0
	BEQ.S	.none
	MOVEA.L	D0,A1
	MOVE.L	dat_DiskOpBufAddr,D0
	BMI.S	.whole
	MOVE.L	dat_DiskOpBufSize,D1
	SUB.L	D0,D1
	BLE.S	.whole
	MOVE.L	D1,D3
	MOVEA.L	dat_DiskOpFilesPtr,A1
	ADDA.L	D0,A1
.whole:	TST.L	D3
	RTS
.none:	MOVEQ	#0,D3
	RTS

;--- core: a1=data d3=len
pt_FltProcess41:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	A1,flt_Start
	MOVE.L	D3,flt_Count
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	flt_MsgBusy(PC),A0
	JSR	pt_ShowStatusMsg
	JSR	pt_WaitMouseRelease
	CLR.L	flt_Low
	CLR.L	flt_Band
	MOVEA.L	dat_OscillatorData0,A2
	MOVE.L	A2,D0
	BEQ.W	.end
; par2: q (ty2), gain (3/4), fb (5)
	MOVE.L	(20,A2),D0
	MOVE.W	dat_OscillatorSlot,D1
	CMP.W	#2,D1
	BNE.S	.p2g
	CMP.L	#1,D0			; q -> damping 1/q (15 bit)
	BGE.S	.q1
	MOVEQ	#1,D0
.q1:	CMP.L	#20,D0
	BLE.S	.q2
	MOVEQ	#20,D0
.q2:	MOVE.L	#32767,D1
	DIVU	D0,D1
	MOVE.W	D1,flt_Q
	BRA.S	.p2d
.p2g:	CMP.L	#-100,D0		; gain % -> 15 bit
	BGE.S	.g1
	MOVEQ	#-100,D0
.g1:	CMP.L	#100,D0
	BLE.S	.g2
	MOVEQ	#100,D0
.g2:	MULS	#327,D0
	MOVE.W	D0,flt_G
	MOVE.L	(20,A2),D0		; fb 0..4096
	BPL.S	.f1
	MOVEQ	#0,D0
.f1:	CMP.L	#4096,D0
	BLE.S	.f2
	MOVE.L	#4096,D0
.f2:	MOVE.W	D0,flt_Fb
	MOVE.L	(36,A2),D0		; par3 = out (ty7)
	BPL.S	.o1
	MOVEQ	#0,D0
.o1:	CMP.L	#4096,D0
	BLE.S	.o2
	MOVE.L	#4096,D0
.o2:	MOVE.W	D0,flt_Out
.p2d:
	CLR.L	flt_Hist		; hist buf for ty6-8
	MOVE.W	dat_OscillatorSlot,D0
	CMP.W	#6,D0
	BCS.S	.nohist
	CMP.W	#8,D0
	BHI.S	.nohist
	MOVE.L	#FLT_HIST*2,D0
	MOVE.L	#$10000,D1		; MEMF_CLEAR
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,flt_Hist
	BNE.S	.nohist
	JSR	pt_SetupPaletteMode	; "NOT ENOUGH MEMORY!"
	BRA.W	.end
.nohist:
; segs: 1 without curve, else 270
	MOVEQ	#1,D0
	TST.W	dat_OscillatorIndex
	BEQ.S	.one
	CMP.W	#7,dat_OscillatorSlot	; ty7/9 have no curve
	BEQ.S	.one
	CMP.W	#9,dat_OscillatorSlot
	BEQ.S	.one
	TST.L	dat_OscillatorBufPtr
	BEQ.S	.one
	MOVE.W	#FLT_SEGS,D0
.one:	MOVE.W	D0,flt_Segs
	MOVE.L	flt_Count,D0
	MOVEQ	#0,D1
	MOVE.W	flt_Segs,D1
	CMP.W	#1,D1
	BEQ.S	.whole
	DIVU	D1,D0			; cnt <= 131070 -> quot <= 485
	MOVE.W	D0,flt_SegQ
	SWAP	D0
	MOVE.W	D0,flt_SegR
.whole:	CLR.W	flt_Seg
	MOVEA.L	flt_Start,A3
	CLR.L	flt_Pos
.seg:
; par1 of this seg
	MOVE.L	(4,A2),D0		; set value
	CMP.W	#1,flt_Segs
	BEQ.S	.pv
	MOVEA.L	dat_OscillatorBufPtr,A0
	MOVEQ	#0,D1
	MOVE.W	flt_Seg,D2
	MOVE.B	(A0,D2.W),D1
	CMP.W	#30,D1
	BLS.S	.m1
	MOVEQ	#30,D1
.m1:	NEG.W	D1
	ADD.W	#30,D1			; 30 - curve
	MOVE.L	(8,A2),D2		; min
	SUB.L	D2,D0			; value - min
	BPL.S	.m2
	MOVEQ	#0,D0
.m2:	MULU	D1,D0			; <= 65535*30
	DIVU	#30,D0
	AND.L	#$ffff,D0
	ADD.L	D2,D0
.pv:	TST.L	D0
	BGT.S	.pv1
	MOVEQ	#1,D0
.pv1:	MOVE.L	D0,-(A7)		; coef41 converts d0 to smp
	BSR.W	pt_FltCoef41
	MOVE.L	(A7)+,D0
	BSR.W	pt_FltCoefNew41		; par1 of ty7/8
; seg end
	MOVE.L	flt_Count,D1
	CMP.W	#1,flt_Segs
	BEQ.S	.se
	MOVEQ	#0,D1
	MOVE.W	flt_Seg,D1
	ADDQ.W	#1,D1
	MOVE.L	D1,D2
	MULU	flt_SegQ,D1		; (k+1)*q
	MULU	flt_SegR,D2		; (k+1)*r <= 270*269
	DIVU	#FLT_SEGS,D2
	AND.L	#$ffff,D2
	ADD.L	D2,D1
.se:	MOVE.L	D1,D7
	SUB.L	flt_Pos,D7		; cnt in this seg
	MOVE.L	D1,flt_Pos
	TST.L	D7
	BLE.S	.next
	BSR.W	pt_FltRun41
.next:	ADDQ.W	#1,flt_Seg
	MOVE.W	flt_Seg,D0
	CMP.W	flt_Segs,D0
	BCS.W	.seg
	MOVEA.L	dat_EffectBuf,A1	; first word 0 as BOOST
	CLR.W	(A1)
.end:	MOVE.L	flt_Hist,D0		; free hist
	BEQ.S	.nh
	MOVEA.L	D0,A1
	MOVE.L	#FLT_HIST*2,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	CLR.L	flt_Hist
.nh:	JSR	pt_ClearStatusMsg
	JSR	pt_RestorePalette
	JSR	pt_RecordCheckInput
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; d0=par1 -> flt_A (lp, 15 bit), flt_F (svf), flt_D (smp)
pt_FltCoef41:
	MOVE.L	D0,D1
	CMP.L	#1300,D1
	BLS.S	.c1
	MOVE.L	#1300,D1
.c1:	MULU	#50,D1			; w*65536
	MOVE.L	D1,D2
	LSR.W	#1,D2
	MOVE.W	D2,flt_F		; svf f ~ w
	MOVE.L	D1,D2
	ADD.L	#65536,D2
	LSR.L	#8,D2			; (65536+w)/256
	LSL.L	#7,D1			; w*128
	DIVU	D2,D1			; a=w/(1+w) 15 bit
	MOVE.W	D1,flt_A
	CMP.L	#100,D0			; ms -> smp
	BLS.S	.c2
	MOVEQ	#100,D0
.c2:	MULU	#8287,D0
	DIVU	#1000,D0
	AND.L	#$ffff,D0
	BNE.S	.c3
	MOVEQ	#1,D0
.c3:	MOVE.L	D0,flt_D
	RTS

; d7=cnt a3=ptr (advances)
pt_FltRun41:
	MOVE.W	dat_OscillatorSlot,D6
	CMP.W	#2,D6
	BEQ.W	.svf
	CMP.W	#5,D6
	BEQ.W	.comb
	CMP.W	#6,D6
	BCC.W	pt_FltRunNew41
; ty0/1/3/4: lp state flt_Low (x128)
	MOVE.L	flt_Low,D4
	MOVE.W	flt_A,D5
.lp:	MOVE.B	(A3),D0
	EXT.W	D0
	ASL.W	#7,D0			; x (x128)
	MOVE.W	D0,D1
	SUB.W	D4,D1
	MULS	D5,D1
	ADD.L	D1,D1
	SWAP	D1			; a*(x-y) >> 15
	ADD.W	D1,D4			; y
	EXT.L	D0
	MOVE.W	D4,D1
	EXT.L	D1
	TST.W	D6
	BEQ.S	.o0
	SUB.L	D1,D0			; hp = x-y
	CMP.W	#1,D6
	BEQ.S	.o1
	CMP.W	#4,D6
	BEQ.S	.sh
	ADD.L	D1,D0			; ty3: x back, part = lp
	BRA.S	.sg
.sh:	MOVE.L	D0,D1			; ty4: part = hp
	MOVE.B	(A3),D0
	EXT.W	D0
	ASL.W	#7,D0
	EXT.L	D0
.sg:	MULS	flt_G,D1
	ADD.L	D1,D1
	SWAP	D1
	EXT.L	D1
	ADD.L	D1,D0			; x+g*part
	BRA.S	.o1
.o0:	MOVE.L	D1,D0
.o1:	BSR.W	pt_FltStore41
	SUBQ.L	#1,D7
	BNE.S	.lp
	MOVE.L	D4,flt_Low
	RTS
.svf:	MOVE.L	flt_Low,D4		; lp state
	MOVE.L	flt_Band,D5		; bp state
.sv:	MOVE.W	flt_F,D1		; low += f*band
	MULS	D5,D1
	ADD.L	D1,D1
	SWAP	D1
	EXT.L	D1
	ADD.L	D1,D4
	SAT16	D4
	MOVE.B	(A3),D0			; high = x - low - q*band
	EXT.W	D0
	ASL.W	#7,D0
	EXT.L	D0
	SUB.L	D4,D0
	MOVE.W	flt_Q,D1
	MULS	D5,D1
	ADD.L	D1,D1
	SWAP	D1
	EXT.L	D1
	SUB.L	D1,D0
	SAT16	D0
	MULS	flt_F,D0		; band += f*high
	ADD.L	D0,D0
	SWAP	D0
	EXT.L	D0
	ADD.L	D0,D5
	SAT16	D5
	MOVE.L	D5,D0
	BSR.W	pt_FltStore41
	SUBQ.L	#1,D7
	BNE.W	.sv
	MOVE.L	D4,flt_Low
	MOVE.L	D5,flt_Band
	RTS
.comb:	MOVE.W	flt_Fb,D5
.cb:	MOVE.B	(A3),D0
	EXT.W	D0
	EXT.L	D0
	MOVE.L	A3,D1
	SUB.L	flt_Start,D1
	CMP.L	flt_D,D1
	BCS.S	.c0			; no history yet
	MOVEA.L	A3,A0
	SUBA.L	flt_D,A0
	MOVE.B	(A0),D1			; y[n-D] already done
	EXT.W	D1
	MULS	D5,D1
	ASR.L	#8,D1
	ASR.L	#4,D1			; fb*y >> 12
	ADD.L	D1,D0
.c0:	ASL.L	#7,D0
	BSR.W	pt_FltStore41
	SUBQ.L	#1,D7
	BNE.S	.cb
	RTS

;--- types 6-9
; d0=par1 -> ty7 delay (smp), ty8 out; ty6 uses flt_D
pt_FltCoefNew41:
	CMP.W	#7,dat_OscillatorSlot
	BNE.S	.t8
	CMP.L	#FLT_HIST-1,D0
	BLS.S	.d1
	MOVE.L	#FLT_HIST-1,D0
.d1:	MOVE.L	D0,flt_D
	RTS
.t8:	CMP.W	#8,dat_OscillatorSlot
	BNE.S	.r
	CMP.L	#4096,D0
	BLS.S	.o1
	MOVE.L	#4096,D0
.o1:	MOVE.W	D0,flt_Out
.r:	RTS

; d7=cnt a3=ptr, d6=type; ring idx = pos & (FLT_HIST-1)
pt_FltRunNew41:
	CMP.W	#9,D6
	BEQ.W	.shape
	MOVEA.L	flt_Hist,A4
.n:	MOVE.L	A3,D3
	SUB.L	flt_Start,D3		; pos n
	MOVE.B	(A3),D0
	EXT.W	D0
	ASL.W	#7,D0
	EXT.L	D0			; x (x128)
	CMP.W	#7,D6
	BEQ.S	.dly
	BHI.W	.tap
	; Typ 6 Allpass: v = x + g*v[n-D]; y = v[n-D] - g*v
	MOVE.L	D3,D1
	SUB.L	flt_D,D1
	BSR.W	.hget			; D2 = v[n-D]
	MOVE.L	D2,D1
	MULS	flt_Fb,D1
	ASR.L	#8,D1
	ASR.L	#4,D1			; g*v[n-D]
	ADD.L	D1,D0			; v
	SAT16	D0
	MOVE.L	D3,D1
	BSR.W	.hput			; store v[n]
	MOVE.W	flt_Fb,D1
	MULS	D0,D1
	ASR.L	#8,D1
	ASR.L	#4,D1			; g*v
	MOVE.L	D2,D0
	SUB.L	D1,D0			; y
	BRA.W	.st
; ty7: w = x + fb*w[n-D]; y = x + out*w[n-D]
.dly:	MOVE.L	D3,D1
	SUB.L	flt_D,D1
	BSR.W	.hget			; D2 = w[n-D]
	MOVE.L	D2,D1
	MULS	flt_Fb,D1
	ASR.L	#8,D1
	ASR.L	#4,D1
	ADD.L	D0,D1			; w
	SAT16	D1
	MOVE.L	D0,D4			; x
	MOVE.L	D1,D0
	MOVE.L	D3,D1
	BSR.W	.hput
	MOVE.L	D2,D1
	MULS	flt_Out,D1
	ASR.L	#8,D1
	ASR.L	#4,D1
	MOVE.L	D4,D0
	ADD.L	D1,D0			; y
	BRA.W	.st
; ty8: x stored, 4 taps 1/2..1/16
.tap:	MOVE.L	D3,D1
	BSR.W	.hput
	MOVE.L	D0,D4			; x
	MOVEQ	#0,D5			; sum
	LEA	flt_Taps(PC),A0
	MOVEQ	#1,D2			; Shift 1..4
.tl:	MOVE.L	D3,D1
	MOVEQ	#0,D0
	MOVE.W	(A0)+,D0
	SUB.L	D0,D1
	MOVE.L	D2,-(A7)
	BSR.S	.hget
	MOVE.L	D2,D1
	MOVE.L	(A7)+,D2
	ASR.L	D2,D1
	ADD.L	D1,D5
	ADDQ.W	#1,D2
	CMP.W	#4,D2
	BLS.S	.tl
	SAT16	D5
	MULS	flt_Out,D5
	ASR.L	#8,D5
	ASR.L	#4,D5
	MOVE.L	D4,D0
	ADD.L	D5,D0
.st:	BSR.W	pt_FltStore41
	SUBQ.L	#1,D7
	BNE.W	.n
	RTS
; hist read: d1=pos (<0 -> 0) -> d2
.hget:	MOVEQ	#0,D2
	TST.L	D1
	BMI.S	.hg0
	AND.W	#FLT_HIST-1,D1
	ADD.W	D1,D1
	MOVE.W	(A4,D1.W),D2
	EXT.L	D2
.hg0:	RTS
; hist write: d1=pos d0=val
.hput:	AND.W	#FLT_HIST-1,D1
	ADD.W	D1,D1
	MOVE.W	D0,(A4,D1.W)
	RTS
; ty9: y = 192*s - s^3/256
.shape:	MOVE.B	(A3),D0
	EXT.W	D0
	MOVE.W	D0,D1
	MULS	D1,D1			; s*s <= 16384
	MULS	D0,D1			; s^3, |s^3| <= 2097152
	ASR.L	#8,D1
	MULS	#192,D0
	SUB.L	D1,D0
	BSR.W	pt_FltStore41
	SUBQ.L	#1,D7
	BNE.S	.shape
	RTS

; taps in smp @8287: 60/120/180/240 ms
flt_Taps:	DC.W	497,994,1492,1989

; d0 (x128) round, clamp -128..127 -> (a3)+
pt_FltStore41:
	ADD.L	#64,D0
	ASR.L	#7,D0
	CMP.L	#127,D0
	BLE.S	.s1
	MOVEQ	#127,D0
.s1:	CMP.L	#-128,D0
	BGE.S	.s2
	MOVEQ	#-128,D0
.s2:	MOVE.B	D0,(A3)+
	RTS

; curve "sine": vibrato table stretched to 270 x 0..30 -> d0=buf
pt_FltSinus41:
	MOVEM.L	D1-D3/A0-A1,-(A7)
	LEA	dat_RpVibratoTable,A1
	LEA	dat_WorkBuf3,A0
	MOVEQ	#0,D1			; x
.l:	MOVE.W	D1,D2
	LSL.W	#5,D2			; x * 32
	EXT.L	D2
	DIVU	#FLT_SEGS,D2		; tab idx 0..31
	MOVEQ	#0,D3
	MOVE.B	(A1,D2.W),D3
	MULU	#30,D3
	DIVU	#255,D3
	MOVE.B	D3,(A0)+
	ADDQ.W	#1,D1
	CMP.W	#FLT_SEGS,D1
	BCS.S	.l
	LEA	dat_WorkBuf3,A0
	MOVE.L	A0,D0
	MOVEM.L	(A7)+,D1-D3/A0-A1
	RTS

flt_MsgBusy:	DC.B	"FILTERING",0
flt_MsgTry:	DC.B	"TRY IT AGAIN = UNDO",0
flt_MsgUndo:	DC.B	"ORIGINAL RESTORED",0
flt_MsgKept:	DC.B	"FILTER APPLIED",0
	EVEN
flt_TryPtr:	DS.L	1		; backup (0=none)
flt_TrySrc:	DS.L	1
flt_TryLen:	DS.L	1
flt_Start:	DS.L	1
flt_Count:	DS.L	1
flt_Pos:	DS.L	1
flt_Low:	DS.L	1
flt_Band:	DS.L	1
flt_D:		DS.L	1
flt_A:		DS.W	1
flt_F:		DS.W	1
flt_Q:		DS.W	1
flt_G:		DS.W	1
flt_Fb:		DS.W	1
flt_Out:	DS.W	1		; out level 0..4096
flt_Hist:	DS.L	1		; hist buf (during filtering)
flt_Segs:	DS.W	1
flt_Seg:	DS.W	1
flt_SegQ:	DS.W	1
flt_SegR:	DS.W	1
	EVEN
