; 8ch on 68000: 6 voices mixed, v1/2 direct
; p0=v1 (l) p1=v2 (r) direct, p2=v3+6+7 (r) p3=v4+5+8 (l) mixed
; third vol tab (3x42 fits byte), v1/2 get 1/3 via n_pt4_volscale
; 16.16 step via add/addx, frame (ring, shadow, hooks) = mixer.asm

	IFND	MIX68_MINBENCH
MIX68_MINBENCH	EQU	1600			; min pt_CpuBench (a500+ = 640)
	ENDC
	IFND	MIX68_RATE
MIX68_RATE	EQU	6928			; period 512
	ENDC
; a500 mode: fast ram, 5 khz, no scopes, lead 6 (pt_MixLeadSpt)
MIX68_SLOWBENCH	EQU	560			; min bench for a500 mode
MIX68_SLOWFAST	EQU	131072			; min fast ram
MIX68_SLOWRATE	EQU	5000

; one out smp from one voice (regs: pt_Mix68Voice)
MIX68ONE1	MACRO
	MOVE.B	(A2,D2.W),D7
	ADD.W	D5,D3
	ADDX.W	D4,D2
	MOVE.B	(A3,D7.W),D0
	ADD.B	D0,(A0)+
	ENDM

; one out smp from two voices (regs: pt_Mix68Pair)
MIX68PAIR1	MACRO
	MOVE.B	(A1,D0.W),D6
	ADD.W	A4,D1
	ADDX.W	D4,D0
	MOVE.B	(A2,D2.W),D7
	ADD.W	A5,D3
	ADDX.W	D5,D2
	MOVE.B	(A3,D6.W),D6
	MOVE.B	(A3,D7.W),D7
	ADD.B	D7,D6
	ADD.B	D6,(A0)+
	ENDM
MIX68_EXP	EQU	512			; loops < 512 b repeated to >= 512 b
MIX68_EXPBUF	EQU	1024			; buf per voice (multiple of loop len < 1024)
MIX68_TABSZ	EQU	65*256+(856-113+1)*4+8*MIX68_EXPBUF	; vol tab, step tab, loop bufs

; from pt_MixInitOnce w/o 020: free mixer (mem only in 8ch, pt_Mix68Mem)
pt_Mix68Init:
	CMP.L	#MIX68_MINBENCH,dat_CpuBench	; too slow or unmeasured: 4ch
	BCC.S	.go
	CMP.L	#MIX68_SLOWBENCH,dat_CpuBench	; a500 mode: 7 mhz + fast ram
	BCS.S	.r
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#4,D1			; MEMF_FAST
	JSR	(-216,A6)		; AvailMem
	CMP.L	#MIX68_SLOWFAST,D0
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	BCS.S	.r
	ST	mix68_Slow
.go:	ST	mix_Is68k
	ST	mix_Enabled
	MOVE.L	#pt_Mix68TickSoft,mix_SoftInt+18	; is_Code
	BRA.W	pt_MixApplyRate
.r:	RTS

; task ctx: 8ch -> alloc tab + rings ch2/3 (chip), else free
pt_Mix68Mem:
	MOVEM.L	D0-D3/A0-A1/A6,-(A7)
	CMPI.W	#8,dat_RpNumChannels
	BNE.W	.free
	TST.L	mix_Ring
	BEQ.S	.alloc
	MOVE.W	mix_Rate,D0		; mix rate changed -> rebuild step tab
	CMP.W	mix68_StepRate,D0
	BEQ.W	.r
	BSR.W	pt_Mix68StepTab
	BRA.W	.r
.alloc:
	TST.B	mix68_MemFail
	BNE.W	.r
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	#MIX68_TABSZ,D0
	MOVE.L	#$10001,D1		; MEMF_PUBLIC|MEMF_CLEAR (fast if any)
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,mix68_VolTab
	BEQ.S	.fail
	MOVEA.L	D0,A0			; tab: smp*vol/192 = third
	MOVEQ	#0,D2
.v:	MOVEQ	#0,D3
.s:	MOVE.B	D3,D0
	EXT.W	D0
	MULS	D2,D0
	DIVS	#192,D0
	MOVE.B	D0,(A0)+
	ADDQ.W	#1,D3
	CMP.W	#256,D3
	BNE.S	.s
	ADDQ.W	#1,D2
	CMP.W	#65,D2
	BNE.S	.v
	BSR.W	pt_Mix68StepTab
	MOVE.L	#2*MIX_RING,D0
	MOVE.L	#$10002,D1		; MEMF_CHIP|MEMF_CLEAR
	JSR	(-198,A6)
	MOVE.L	D0,mix68_RingBlock
	BEQ.S	.failt
	SUB.L	#2*MIX_RING,D0		; ring ch n = mix_Ring+n*MIX_RING, ch2/3 in block
	MOVE.L	D0,mix_Ring
	TST.B	mix68_Slow
	BEQ.S	.r
	LEA	mix68_SlowText(PC),A0	; announce a500 mode
	JSR	pt_ShowStatusMsg
	BRA.S	.r
.failt:	MOVEA.L	mix68_VolTab,A1
	MOVE.L	#MIX68_TABSZ,D0
	JSR	(-210,A6)		; FreeMem
	CLR.L	mix68_VolTab
.fail:	ST	mix68_MemFail		; report once until 4ch again
	LEA	mix68_MemText(PC),A0
	JSR	pt_ShowStatusMsg
	BRA.S	.r
.free:	SF	mix68_MemFail
	TST.B	mix_Active		; still running (stop next tick)
	BNE.S	.r
	BSR.W	pt_Mix68Free
.r:	MOVEM.L	(A7)+,D0-D3/A0-A1/A6
	RTS
mix68_MemText:	DC.B	"8CHN: CH5-8 NEED MORE MEMORY",0
mix68_SlowText:	DC.B	"8CHN A500: 5 KHZ, NO SCOPES",0
	EVEN

; step tab (task ctx): per 113..856 -> (PAULA_CLOCK/per<<16)/rate
; valid while mix68_StepRate = mix_Rate, else pt_Mix68UpdateVoice computes
pt_Mix68StepTab:
	MOVEM.L	D0-D3/A0,-(A7)
	MOVE.L	mix68_VolTab,D0
	BEQ.S	.r
	MOVEA.L	D0,A0
	LEA	65*256(A0),A0
	CLR.W	mix68_StepRate		; invalid while computing
	MOVE.W	#113,D2
.p:	MOVE.L	#PAULA_CLOCK,D0
	MOVEQ	#0,D1
	MOVE.W	D2,D1
	BSR.W	pt_MixDiv32
	LSL.L	#8,D0
	LSL.L	#8,D0
	MOVEQ	#0,D1
	MOVE.W	mix_Rate,D1
	BSR.W	pt_MixDiv32
	MOVE.L	D0,(A0)+
	ADDQ.W	#1,D2
	CMP.W	#857,D2
	BNE.S	.p
	MOVE.W	mix_Rate,mix68_StepRate
.r:	MOVEM.L	(A7)+,D0-D3/A0
	RTS

; free rings + tab (task ctx, also at exit)
pt_Mix68Free:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	mix68_RingBlock,D0
	BEQ.S	.t
	CLR.L	mix_Ring
	CLR.L	mix68_RingBlock
	MOVEA.L	D0,A1
	MOVE.L	#2*MIX_RING,D0
	JSR	(-210,A6)
.t:	MOVE.L	mix68_VolTab,D0
	BEQ.S	.r
	CLR.L	mix68_VolTab
	CLR.W	mix68_StepRate
	MOVEA.L	D0,A1
	MOVE.L	#MIX68_TABSZ,D0
	JSR	(-210,A6)
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

; mix rate: AUTO 8287 else setup choice
pt_Mix68ApplyRate:
	MOVEM.L	D0-D1/A0,-(A7)
	MOVEQ	#0,D0
	MOVE.B	mix_RateSel,D0
	AND.W	#3,D0
	ADD.W	D0,D0
	LEA	mix68_RateTab(PC),A0
	MOVE.W	(A0,D0.W),D1
	TST.B	mix68_Slow		; a500 mode: always 5 khz
	BEQ.S	.nslow
	MOVE.W	#MIX68_SLOWRATE,D1
	BRA.S	.set
.nslow:	TST.W	D1
	BNE.S	.set
	MOVE.L	dat_CpuBench,D0		; AUTO by bench: <4x a500 6.9k, <8x 11k, <16x 14k, else 22k
	MOVE.W	#MIX68_RATE,D1
	CMP.L	#2560,D0
	BCS.S	.set
	MOVE.W	#11025,D1
	CMP.L	#5120,D0
	BCS.S	.set
	MOVE.W	#14000,D1
	CMP.L	#10240,D0
	BCS.S	.set
	MOVE.W	#22050,D1
.set:
	BSR.W	pt_MixSetRate		; per rounded, mix_Rate = actual
	MOVEM.L	(A7)+,D0-D1/A0
	RTS
mix68_RateTab:	DC.W	0,8287,11025,22050	; AUTO, 8.3/11/22 khz
mix68_RateMsg:	DC.B	"8CH MIX: AUTO  ",0
	DC.B	"8CH MIX: 8.3KHZ",0
	DC.B	"8CH MIX: 11 KHZ",0
	DC.B	"8CH MIX: 22 KHZ",0
	EVEN

; v1/2 paula vol: active = master/3, else full (ch off = 0)
; from pt_MixLoopInit (per tick), pt_MixStop
pt_Mix68VolScale:
	MOVEM.L	D0-D2/A0,-(A7)
	TST.B	mix_Is68k
	BEQ.S	.r
	MOVE.W	dat_RpMasterVol,D1
	TST.B	mix_Active
	BEQ.S	.full
	MULU	#21,D1
	LSR.W	#6,D1			; ~1/3
.full:	LEA	dat_Channel1,A0
	MOVEQ	#0,D2
.ch:	MOVE.W	D1,D0
	BTST	D2,dat_RpDmaChanMask+1	; trk off -> 0
	BNE.S	.on
	MOVEQ	#0,D0
.on:	MOVE.W	D0,(n_pt4_volscale,A0)
	LEA	n_SIZEOF(A0),A0
	ADDQ.W	#1,D2
	CMP.W	#2,D2
	BNE.S	.ch
.r:	MOVEM.L	(A7)+,D0-D2/A0
	RTS

; softint
pt_Mix68TickSoft:
	MOVEM.L	D2-D7/A2-A6,-(A7)
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixSoftCnt
	MOVE.L	$DFF004,D0
	LSR.L	#8,D0
	AND.L	#$1ff,D0
	MOVE.W	D0,dbg_MixLineStart
	SUB.W	dbg68_CauseLine,D0	; trigger -> softint delay (lines)
	BPL.S	.lp
	ADD.W	#313,D0
.lp:	CMP.W	dbg68_LatMax,D0
	BLS.S	.lm
	MOVE.W	D0,dbg68_LatMax
.lm:	EXT.L	D0
	ADD.L	D0,dbg68_LatSum
	ENDC
	MOVEQ	#1,D7			; max 2 ticks per call, 68000 must never run behind
	TST.B	mix68_Slow		; a500 mode: more catch-up
	BEQ.S	.again
	MOVEQ	#5,D7
.again:	TST.W	mix_TicksDue		; else loop never ends, tasks starve
	BEQ.S	.done
	SUBQ.W	#1,mix_TicksDue
	TST.B	mix_Active
	BEQ.S	.done
	MOVE.W	D7,-(A7)
	BSR.W	pt_Mix68OneTick
	MOVE.W	(A7)+,D7
	TST.W	mix_TicksDue
	BEQ.S	.done
	ADDQ.W	#1,mix_Overrun
	DBF	D7,.again
	TST.W	mix_TicksDue		; drop rest, gap instead of hang
	BEQ.S	.done
	ADDQ.W	#1,mix68_Drops
	CLR.W	mix_TicksDue
.done:	IFD	DEBUGFX
	MOVE.L	$DFF004,D0
	LSR.L	#8,D0
	AND.L	#$1ff,D0
	SUB.W	dbg_MixLineStart,D0
	BPL.S	.lpos
	ADD.W	#313,D0
.lpos:	CMP.W	dbg_MixLinesMax,D0
	BLS.S	.lok
	MOVE.W	D0,dbg_MixLinesMax
.lok:	ADD.L	D0,dbg_MixLinesSum
	ENDC
	MOVEM.L	(A7)+,D2-D7/A2-A6
	MOVEQ	#0,D0
	RTS

pt_Mix68OneTick:
	IFD	DEBUGFX
	MOVE.L	dat_RpPlayMode,D0
	CMP.L	dbg_MixPlayPrev,D0
	BEQ.S	.samepm
	MOVE.L	D0,dbg_MixPlayPrev
	TST.L	D0
	BEQ.S	.samepm
	CLR.L	dbg_MixPos
	CLR.W	dbg_MixLinesMax		; dbg: max lines
	CLR.L	dbg_MixLinesSum
	CLR.L	dbg_MixSoftCnt
	CLR.W	mix_Overrun
	CLR.W	mix68_Drops
	CLR.W	dbg68_LatMax
	CLR.L	dbg68_LatSum
	CLR.L	dbg68_Polls
.samepm:
	ENDC
	MOVE.W	DMACONR,D0		; ring dma still on? (pt_StopAllAudio clears)
	MOVEQ	#0,D1
	MOVE.B	mix_PairMask,D1
	AND.W	D1,D0
	CMP.W	D1,D0
	BEQ.S	.dmaok
	BSR.W	pt_MixRingRestart
.dmaok:	MOVE.W	dat_CurrentTempo,D0
	CMP.W	mix_SptBpm,D0
	BNE.S	.recalc
	MOVEQ	#0,D0
	BTST	#0,dat_ModeFlags
	BEQ.S	.m
	MOVEQ	#1,D0
.m:	CMP.W	mix_SptMode,D0
	BEQ.S	.sptok
.recalc:
	BSR.W	pt_MixCalcSpt
.sptok:	MOVEQ	#0,D0
	MOVE.W	mix_WriteFrac,D0
	ADD.L	mix_Spt,D0
	MOVE.W	D0,mix_WriteFrac
	CLR.W	D0
	SWAP	D0
	CMP.L	#MIX_TICKMAX-2,D0	; room for parity ofs in tick buf
	BLS.S	.nok
	MOVE.L	#MIX_TICKMAX-2,D0
.nok:	MOVE.L	D0,D7			; smp this tick
	BSR.W	pt_Mix68DirectTick	; v1/2 delayed MIX_LEAD ticks -> paula 0/1
	MOVEQ	#2,D6			; paula ch 2, then 3
.ch:	LEA	mix68_Groups(PC),A3
	MOVE.W	D6,D0
	SUBQ.W	#2,D0
	MULU	#3,D0
	ADDA.W	D0,A3			; 3 voice idx of this ch
	LEA	mix68_GroupMv,A2
	MOVEQ	#2,D5
.v:	MOVEQ	#0,D0
	MOVE.B	(A3)+,D0		; voice 0..7: take state from replayer (once per tick)
	LEA	dat_Channel1,A6
	MOVE.W	D0,D1
	MULU	#n_SIZEOF,D1
	ADDA.L	D1,A6
	LEA	mix_Voices,A5
	MOVE.W	D0,D1
	MULU	#mv_SIZEOF,D1
	ADDA.L	D1,A5
	LEA	mix_Shadow,A4
	MOVE.W	D0,D1
	LSL.W	#4,D1
	ADDA.L	D1,A4
	MOVE.L	A5,(A2)+
	MOVEM.L	D0/D5-D7/A2-A3,-(A7)
	BSR.W	pt_Mix68UpdateVoice
	MOVEM.L	(A7)+,D0/D5-D7/A2-A3
	BSR.W	pt_Mix68LoopExp		; short loops via voice loop buf
	DBF	D5,.v
	; mix in tick buf (fast ram if any: no hires wait states), copy to ring
	BSR.W	pt_Mix68TickBufA0	; tick buf with ring pos parity
	MOVE.L	D7,D3
	BSR.W	pt_Mix68Seg
	IFD	DEBUGFX
	BSR.W	dbg_MixDump
	ENDC
	MOVEA.L	mix_Ring,A1
	MOVE.W	D6,D0
	MULU	#MIX_RING,D0
	ADDA.L	D0,A1			; ring of ch
	MOVE.L	mix_WriteInt,D1
	BSR.W	pt_Mix68TickBufA0
	MOVE.L	#MIX_RING,D2
	SUB.L	D1,D2			; room to ring end
	CMP.L	D7,D2
	BLS.S	.s1
	MOVE.L	D7,D2
.s1:	LEA	(A1,D1.L),A2
	MOVE.L	D2,D0
	BSR.W	pt_Mix68Copy
	MOVE.L	D7,D0
	SUB.L	D2,D0			; rest from ring start
	BEQ.S	.s2
	MOVEA.L	A1,A2
	BSR.W	pt_Mix68Copy
.s2:
	ADDQ.W	#1,D6
	BSR.W	pt_Mix68DirectPhase	; v1/2: dma on (after ch2) / set loop (after ch3)
	CMP.W	#4,D6
	BNE.W	.ch
	MOVE.L	mix_WriteInt,D0
	ADD.L	D7,D0
	AND.L	#MIX_RING-1,D0
	MOVE.L	D0,mix_WriteInt
	IFD	DEBUGFX
	ADD.L	D7,dbg75_WAbs		; write pos w/o wrap
	ENDC
	IFD	DEBUGFX
	MOVE.L	dbg_MixPos,D0
	ADD.L	D7,D0
	CMP.L	#DBG_MIXCH,D0
	BHI.S	.dumpfull
	MOVE.L	D0,dbg_MixPos
.dumpfull:
	ENDC
	RTS
; a0 = mix_TickBuf+(ringpos&1): same parity -> long copy, else bytes
pt_Mix68TickBufA0:
	LEA	mix_TickBuf,A0
	BTST	#0,mix_WriteInt+3
	BEQ.S	.r
	ADDQ.L	#1,A0
.r:	RTS
; paula2: v3,6,7 (r) paula3: v4,5,8 (l), idx 0..7
mix68_Groups:	DC.B	2,5,6, 3,4,7
	EVEN

; short loops (a5, idx d0) < MIX68_EXP: k copies in buf, ptrs -> buf
; runs per tick after pt_Mix68UpdateVoice (resets loop ptrs)
pt_Mix68LoopExp:
	MOVEM.L	D0-D4/A0-A2,-(A7)
	TST.B	(mv_active,A5)
	BEQ.W	.r
	TST.B	(mv_back,A5)		; backwards (81y): untouched
	BNE.W	.r
	MOVE.L	(mv_looplen,A5),D1
	BEQ.W	.r
	CMP.L	#MIX68_EXP,D1
	BCC.W	.r
	MOVEA.L	mix68_VolTab,A0		; voice buf
	ADDA.L	#65*256+(856-113+1)*4,A0
	MOVE.W	D0,D2
	MULU	#MIX68_EXPBUF,D2
	ADDA.L	D2,A0
	LEA	mix68_ExpSrc,A1		; built for (loopstart,len) already?
	MOVE.W	D0,D2
	LSL.W	#3,D2
	ADDA.W	D2,A1
	MOVE.L	(mv_loopstart,A5),D3
	CMP.L	(A1),D3
	BNE.S	.build
	CMP.L	4(A1),D1
	BEQ.S	.map
.build:	MOVE.L	D3,(A1)
	MOVE.L	D1,4(A1)
	MOVEA.L	D3,A2			; copy loop k times
	MOVE.L	#MIX68_EXP,D2
	ADD.L	D1,D2
	SUBQ.L	#1,D2
	DIVU	D1,D2			; k = ceil(EXP/len)
	MULU	D1,D2			; k*len < MIX68_EXPBUF
	MOVE.L	D2,8*8(A1)		; keep buf len (mix68_ExpLen)
	MOVEA.L	A0,A1
	MOVEQ	#0,D4
.cp:	MOVE.B	(A2,D4.L),(A1)+
	ADDQ.L	#1,D4
	CMP.L	D1,D4
	BCS.S	.cn
	MOVEQ	#0,D4
.cn:	SUBQ.L	#1,D2
	BNE.S	.cp
	LEA	mix68_ExpSrc,A1
	MOVE.W	D0,D2
	LSL.W	#3,D2
	ADDA.W	D2,A1
.map:	MOVE.L	8*8(A1),D2		; buf len
	; pos in orig loop -> into buf
	MOVE.L	(mv_pos,A5),D4
	SUB.L	D3,D4			; pos - loopstart
	BCS.S	.set			; before loop (attack): at wrap
	CMP.L	D1,D4
	BCC.S	.set
	MOVE.L	D3,D0
	ADD.L	D1,D0
	CMP.L	(mv_end,A5),D0		; in orig loop phase?
	BNE.S	.set
	ADD.L	A0,D4
	MOVE.L	D4,(mv_pos,A5)
	MOVE.L	A0,D0
	ADD.L	D2,D0
	MOVE.L	D0,(mv_end,A5)
.set:	MOVE.L	A0,(mv_loopstart,A5)	; wrap plays in buf from now
	MOVE.L	D2,(mv_looplen,A5)
.r:	MOVEM.L	(A7)+,D0-D4/A0-A2
	RTS

; clear loop buf marks (mixer start)
pt_Mix68ExpReset:
	MOVEM.L	D0/A0,-(A7)
	LEA	mix68_ExpSrc,A0
	MOVEQ	#15,D0
.c:	CLR.L	(A0)+
	DBF	D0,.c
	MOVEM.L	(A7)+,D0/A0
	RTS

; copy d0 b (a0)+ -> (a2)+ (ring in chip, longs if both even)
pt_Mix68Copy:
	TST.L	D0
	BEQ.S	.r
	MOVE.L	A2,-(A7)
	MOVE.L	A0,D1
	EOR.L	D1,(A7)
	BTST	#0,3(A7)		; diff parity -> bytes
	ADDQ.L	#4,A7
	BNE.S	.b
	BTST	#0,D1			; both odd: 1 byte first
	BEQ.S	.al
	MOVE.B	(A0)+,(A2)+
	SUBQ.L	#1,D0
	BEQ.S	.r
.al:	MOVE.L	D0,D1
	LSR.L	#2,D1
	BRA.S	.le
.l:	MOVE.L	(A0)+,(A2)+
.le:	DBF	D1,.l
	AND.W	#3,D0
	BRA.S	.be
.b:	SUBQ.W	#1,D0
.bl:	MOVE.B	(A0)+,(A2)+
	DBF	D0,.bl
.r:	RTS
.bb:	MOVE.B	(A0)+,(A2)+
.be:	DBF	D0,.bb
	RTS

; ring section a0, d3 smp: clear, add the 3 voices (mix68_GroupMv)
pt_Mix68Seg:
	MOVEM.L	D0-D7/A0-A3,-(A7)
	MOVEA.L	A0,A3
	MOVE.L	D3,D0			; clear: bytes to even, longs, rest
.c1:	TST.L	D0
	BEQ.S	.cdone
	MOVE.L	A0,D1
	BTST	#0,D1
	BEQ.S	.c2
	CLR.B	(A0)+
	SUBQ.L	#1,D0
	BRA.S	.c1
.c2:	MOVE.L	D0,D1
	LSR.L	#2,D1
	BRA.S	.c3e
.c3:	CLR.L	(A0)+
.c3e:	DBF	D1,.c3
	AND.W	#3,D0
	BRA.S	.c4e
.c4:	CLR.B	(A0)+
.c4e:	DBF	D0,.c4
.cdone:	; collect active voices, pairs via pt_Mix68Pair, single via pt_Mix68Voice
	LEA	mix68_GroupMv,A2
	LEA	mix68_Act,A1
	MOVEQ	#0,D4			; active cnt
	MOVEQ	#2,D5
.a:	MOVEA.L	(A2)+,A0
	TST.B	(mv_active,A0)
	BEQ.S	.an
	TST.L	(mv_step,A0)
	BEQ.S	.an
	MOVE.L	A0,(A1)+
	ADDQ.W	#1,D4
.an:	DBF	D5,.a
	LEA	mix68_Act,A2
	CMP.W	#2,D4
	BCS.S	.single
	MOVEA.L	(A2)+,A1
	MOVEA.L	(A2)+,A4
	MOVEA.L	A3,A0
	MOVE.L	D3,D7
	BSR.W	pt_Mix68Pair
	SUBQ.W	#2,D4
.single:
	TST.W	D4
	BEQ.S	.done
	MOVEA.L	(A2)+,A1
	MOVEA.L	A3,A0
	MOVE.L	D3,D7
	BSR.W	pt_Mix68Voice
.done:	MOVEM.L	(A7)+,D0-D7/A0-A3
	RTS

; add 2 voices (a1,a4=mv), d7 smp to (a0), one pass (~52 vs 62 cyc/smp)
; to next phase/window end of either, then wrap; one drops -> single
; loop regs A: a1 base d0 pos d1 frac d4 step a4 step frac d6 vol<<8
; B: a2 base d2 pos d3 frac d5 step a5 step frac d7 vol<<8
; a0 dst a3 tab a6 dst end
pt_Mix68Pair:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	A1,mix68_PA
	MOVE.L	A4,mix68_PB
	MOVE.L	A0,mix68_PDst
	MOVE.L	D7,mix68_PRest
.seg:	MOVE.L	mix68_PRest,D6
	BLE.W	.done
	MOVEA.L	mix68_PA,A1
	MOVEA.L	mix68_PB,A4
	TST.B	(mv_active,A1)
	BEQ.W	.onlyB
	TST.B	(mv_active,A4)
	BEQ.W	.onlyA
	BSR.W	pt_Mix68Avail
	MOVE.L	D0,D5
	MOVEA.L	A4,A1
	BSR.W	pt_Mix68Avail
	CMP.L	D5,D0
	BLS.S	.m1
	MOVE.L	D5,D0
.m1:	CMP.L	D6,D0
	BLS.S	.m2
	MOVE.L	D6,D0
.m2:	SUB.L	D0,D6
	MOVE.L	D6,mix68_PRest
	MOVE.L	D0,mix68_PCnt
	MOVEA.L	mix68_PB,A1		; keep window B
	BSR.W	pt_Mix68Window
	MOVE.L	A2,mix68_TBBase
	MOVE.L	mix68_WinBase,mix68_TBWin
	MOVE.W	D2,mix68_TBPos
	MOVE.W	D3,mix68_TBFrac
	MOVE.W	D4,mix68_TBIstep
	MOVE.W	D5,mix68_TBFstep
	MOVE.W	D7,mix68_TBVol
	MOVEA.L	mix68_PA,A1		; window A -> loop regs
	BSR.W	pt_Mix68Window
	MOVEA.L	A2,A1
	MOVE.W	D2,D0
	MOVE.W	D3,D1
	MOVEA.W	D5,A4
	MOVE.W	D7,D6
	MOVEA.L	mix68_TBBase,A2
	MOVE.W	mix68_TBPos,D2
	MOVE.W	mix68_TBFrac,D3
	MOVE.W	mix68_TBIstep,D5
	MOVEA.W	mix68_TBFstep,A5
	MOVE.W	mix68_TBVol,D7
	MOVEA.L	mix68_PDst,A0
	MOVEA.L	A0,A6
	ADDA.L	mix68_PCnt,A6
	BTST	#0,mix68_PCnt+3	; odd cnt: 1 smp first, then pairs (loop 2x unrolled)
	BEQ.S	.l
	MIX68PAIR1
	CMPA.L	A6,A0
	BEQ.S	.ldone
.l:	MIX68PAIR1
	MIX68PAIR1
	CMPA.L	A6,A0
	BNE.S	.l
.ldone:
	MOVE.L	A0,mix68_PDst
	MOVE.W	D2,mix68_TBPos		; write back pos
	MOVE.W	D3,mix68_TBFrac
	MOVE.W	D0,D2
	MOVE.W	D1,D3
	MOVEA.L	mix68_PA,A1
	BSR.W	pt_Mix68Store		; window base A still in mix68_WinBase
	MOVE.L	mix68_TBWin,mix68_WinBase
	MOVE.W	mix68_TBPos,D2
	MOVE.W	mix68_TBFrac,D3
	MOVEA.L	mix68_PB,A1
	BSR.W	pt_Mix68Store
	MOVEA.L	mix68_PA,A1
	BSR.W	pt_MixVoiceWrap
	MOVEA.L	mix68_PB,A1
	BSR.W	pt_MixVoiceWrap
	BRA.W	.seg
.onlyA:	MOVEA.L	mix68_PA,A1
	BRA.S	.one
.onlyB:	MOVEA.L	mix68_PB,A1
	TST.B	(mv_active,A1)
	BEQ.S	.done
.one:	MOVEA.L	mix68_PDst,A0
	MOVE.L	mix68_PRest,D7
	BSR.W	pt_Mix68Voice
.done:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

	IFD	DEBUGFX
; dump: d7 smp from ring -> mix_TickBuf, append as 020 mixer
pt_Mix68DumpTick:
	MOVEM.L	D0-D2/A0-A1,-(A7)
	MOVEA.L	mix_Ring,A1
	MOVE.W	D6,D0
	MULU	#MIX_RING,D0
	ADDA.L	D0,A1
	MOVE.L	mix_WriteInt,D1
	LEA	mix_TickBuf,A0
	MOVE.L	D7,D0
.cp:	MOVE.B	(A1,D1.L),(A0)+
	ADDQ.L	#1,D1
	AND.L	#MIX_RING-1,D1
	SUBQ.L	#1,D0
	BNE.S	.cp
	MOVEM.L	(A7)+,D0-D2/A0-A1
	BRA.W	dbg_MixDump
	ENDC

; voice mix
; voice a1 (mv): add d7 smp to (a0)
pt_Mix68Voice:
	MOVEM.L	D0-D7/A0-A4,-(A7)
	MOVE.L	D7,D6			; rest
.seg:	TST.B	(mv_active,A1)
	BEQ.W	.done
	TST.L	(mv_step,A1)
	BEQ.W	.done
	BSR.W	pt_Mix68Avail		; d0=smp to phase/window end
	CMP.L	D6,D0
	BLS.S	.n
	MOVE.L	D6,D0
.n:	SUB.L	D0,D6
	MOVE.L	D0,-(A7)		; save cnt (d0 = scratch)
	BSR.W	pt_Mix68Window		; a2 base+32768 d2 win pos d3 frac d4/d5 step d7 vol<<8 a3 tab
	MOVE.L	(A7),D1
	SUBQ.W	#1,D1
	LSR.W	#1,D1			; 2x unrolled: d1=cnt-1, bit0 set -> even cnt
	BCS.S	.l2
	MIX68ONE1			; odd cnt: one first
	BRA.S	.le
.l2:	MIX68ONE1
	MIX68ONE1
.le:	DBF	D1,.l2
	ADDQ.L	#4,A7
	BSR.W	pt_Mix68Store
	BSR.W	pt_MixVoiceWrap		; loop or end (68000-clean, from 020 mixer)
	TST.L	D6
	BGT.S	.seg
.done:	MOVEM.L	(A7)+,D0-D7/A0-A4
	RTS

; d0 = smp to phase/window end (min 1), 68000 pt_MixVoiceAvail
pt_Mix68Avail:
	MOVEM.L	D1-D3,-(A7)
	MOVE.L	(mv_step,A1),D3
	TST.B	(mv_back,A1)
	BNE.S	.back
	MOVE.L	(mv_end,A1),D0
	SUB.L	(mv_pos,A1),D0		; bytes to phase end
	BLE.W	.one
	MOVE.L	(mv_pos,A1),D2
	AND.L	#$7fff,D2
	NEG.L	D2
	ADD.L	#$8000,D2		; bytes to window end
	CMP.L	D2,D0
	BLS.S	.lim
	MOVE.L	D2,D0
.lim:	SWAP	D0
	CLR.W	D0
	MOVEQ	#0,D2
	MOVE.W	(mv_frac,A1),D2
	SUB.L	D2,D0
	BLS.W	.one
	BRA.S	.div
.back:	MOVE.L	(mv_pos,A1),D0
	SUB.L	(mv_loopstart,A1),D0
	BLE.W	.one
	MOVE.L	(mv_pos,A1),D2
	SUBQ.L	#1,D2
	AND.L	#$7fff,D2
	ADDQ.L	#1,D2
	CMP.L	D2,D0
	BLS.S	.blim
	MOVE.L	D2,D0
.blim:	SWAP	D0
	CLR.W	D0
	MOVEQ	#0,D2
	MOVE.W	(mv_frac,A1),D2
	ADD.L	D2,D0
.div:	; smp ~ (bytes<<16-frac)/step: both >>8, step rounded up, no overshoot
	; divu.w instead of 32 bit soft div, overflow = very many smp
	LSR.L	#8,D0
	MOVE.L	D3,D1
	LSR.L	#8,D1
	ADDQ.L	#1,D1
	CMP.L	#$ffff,D1
	BHI.S	.slow
	DIVU	D1,D0
	BVS.S	.big
	AND.L	#$ffff,D0
	BNE.S	.r
	BRA.S	.one
.big:	MOVE.L	#$ffff,D0
	BRA.S	.r
.slow:	MOVE.L	D3,D1			; huge step (per < 13): exact
	BSR.W	pt_MixDiv32
	TST.L	D0
	BNE.S	.r
.one:	MOVEQ	#1,D0
.r:	MOVEM.L	(A7)+,D1-D3
	RTS

; loop regs: a2 win base+32768, d2.w ofs^$8000, d3.w frac, d4/d5.w step
; int/frac (neg if back), d7 vol<<8, a3 tab, win base kept
pt_Mix68Window:
	MOVE.L	(mv_pos,A1),D0
	TST.B	(mv_back,A1)
	BEQ.S	.fwd
	SUBQ.L	#1,D0			; backwards: pos at window top (ofs 1..32768)
	MOVE.L	D0,D1
	AND.L	#$ffff8000,D1
	MOVE.L	D1,mix68_WinBase
	AND.L	#$7fff,D0
	ADDQ.L	#1,D0
	BRA.S	.set
.fwd:	MOVE.L	D0,D1
	AND.L	#$ffff8000,D1
	MOVE.L	D1,mix68_WinBase
	AND.L	#$7fff,D0
.set:	ADD.L	#32768,D1
	MOVEA.L	D1,A2
	MOVE.W	D0,D2
	EOR.W	#$8000,D2
	MOVE.W	(mv_frac,A1),D3
	MOVE.L	(mv_step,A1),D0
	TST.B	(mv_back,A1)
	BEQ.S	.st
	NEG.L	D0
.st:	MOVE.W	D0,D5			; frac
	SWAP	D0
	MOVE.W	D0,D4			; int
	MOVEA.L	mix68_VolTab,A3
	MOVE.W	(mv_vol,A1),D7
	LSL.W	#8,D7
	RTS

; write back pos (win base from pt_Mix68Window)
pt_Mix68Store:
	MOVEQ	#0,D0
	MOVE.W	D2,D0
	EOR.W	#$8000,D0		; ofs 0..32768
	ADD.L	mix68_WinBase,D0
	MOVE.L	D0,(mv_pos,A1)
	MOVE.W	D3,(mv_frac,A1)
	RTS

pt_Mix68UpdateVoice:
	MOVEQ	#0,D2			; trigger
	TST.B	(n_pt4_dmawait,A6)
	BEQ.S	.chkper
	SF	(n_pt4_dmawait,A6)
	CLR.W	(n_pt4_dmacount,A6)
	MOVEQ	#1,D2
.chkper:
	CMPI.W	#1,(aud_PER,A4)
	BNE.S	.notrig
	MOVEQ	#1,D2
	MOVE.W	(n_period,A6),(aud_PER,A4)	; as audio irq in direct path
.notrig:
	TST.W	D2
	BEQ.S	.loop
	IFD	DEBUGFX
	BSR.W	dbg75_MixNote		; dbg
	ENDC
	MOVE.L	(n_start,A6),D0
	BEQ.S	.silent
	MOVEQ	#0,D1
	MOVE.W	(n_length,A6),D1
	CMP.W	#2,D1
	BLS.S	.silent
	MOVE.L	D0,(mv_pos,A5)
	CLR.W	(mv_frac,A5)
	ADD.L	D1,D1
	ADD.L	D0,D1
	MOVE.L	D1,(mv_end,A5)
	ST	(mv_active,A5)
	SF	(mv_back,A5)		; new note plays fwd
	CLR.W	(mv_period,A5)		; recalc step
	MOVEQ	#0,D0			; vol as audio irq in direct path
	MOVE.B	(n_volume,A6),D0
	MULU.W	(n_pt4_volscale,A6),D0
	ADD.W	#32,D0
	LSR.W	#6,D0
	MOVE.W	D0,(aud_VOL,A4)
	BRA.S	.loop
.silent:
	SF	(mv_active,A5)
.loop:	; take loop info every time (instr w/o note sets it later)
	MOVE.L	(n_loopstart,A6),(mv_loopstart,A5)
	MOVEQ	#0,D1
	MOVE.W	(n_replen,A6),D1
	CMP.W	#1,D1
	BHI.S	.hasloop
	MOVEQ	#0,D1
	BRA.S	.setloop
.hasloop:
	ADD.L	D1,D1
.setloop:
	MOVE.L	D1,(mv_looplen,A5)
	; vol: shadow AUDxVOL, chunk path n_pt4_irqvol, ch off -> 0
	MOVE.W	(aud_VOL,A4),D0
	TST.B	(n_pt4_chunked,A6)
	BEQ.S	.volsrc
	MOVE.W	(n_pt4_irqvol,A6),D0
.volsrc:
	TST.B	(n_pt4_chanoff,A6)
	BEQ.S	.volok
	MOVEQ	#0,D0
.volok:	CMP.W	#64,D0
	BLS.S	.vol2
	MOVEQ	#64,D0
.vol2:	MOVE.W	(n_pt4_chanbit,A6),D1	; 84y blend: pair = trk&3
	AND.W	#7,D1
	MOVE.W	D1,D2
	AND.W	#3,D2
	MOVE.L	A0,-(A7)
	LEA	efx8_Blend,A0
	MOVE.B	(A0,D2.W),D2
	MOVEA.L	(A7)+,A0
	BEQ.S	.vol3			; no blend
	AND.W	#$ff,D2
	CMP.W	#4,D1
	BLO.S	.blo
	MULU.W	D2,D0			; voice n+4: y/15
	BRA.S	.bdiv
.blo:	NEG.W	D2
	ADD.W	#15,D2
	MULU.W	D2,D0			; voice n: (15-y)/15
.bdiv:	DIVU.W	#15,D0
	AND.L	#$ffff,D0
.vol3:	MOVE.W	D0,(mv_vol,A5)
	; per: shadow AUDxPER (vibrato/arp write there), else n_period
	MOVE.W	(aud_PER,A4),D0
	CMP.W	#2,D0
	BCC.S	.perok
	MOVE.W	(n_period,A6),D0
	CMP.W	#2,D0
	BCS.S	.ret
.perok:	CMP.W	(mv_period,A5),D0
	BEQ.S	.ret
	MOVE.W	D0,(mv_period,A5)
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	; step from tab (per 113..856, built per mix rate in pt_Mix68StepTab)
	MOVE.W	mix_Rate,D0
	CMP.W	mix68_StepRate,D0
	BNE.S	.calc
	CMP.W	#113,D1
	BCS.S	.calc
	CMP.W	#856,D1
	BHI.S	.calc
	MOVEA.L	mix68_VolTab,A0		; tab behind vol tab
	LEA	65*256(A0),A0
	SUB.W	#113,D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	(A0,D1.W),(mv_step,A5)
	RTS
.calc:	MOVE.L	#PAULA_CLOCK,D0
	BSR.W	pt_MixDiv32		; voice rate (68000: soft div)
	LSL.L	#8,D0
	LSL.L	#8,D0
	MOVEQ	#0,D1
	MOVE.W	mix_Rate,D1
	BSR.W	pt_MixDiv32
	MOVE.L	D0,(mv_step,A5)
.ret:	RTS

	EVEN

; from pt_ScopeBase: a500 mode + mixer -> skip scopes (z=0), clear marks
; like pt_ScopeTrackPos (a0=first)
pt_Mix68ScopeOff:
	TST.B	mix68_Slow
	BEQ.S	.r
	TST.B	mix_Active
	BEQ.S	.r
	MOVEM.L	D0/A0,-(A7)
	MOVEQ	#3,D0
	BTST	#5,dat_ModeFlags
	BNE.S	.c
	LEA	dat_Channel1,A0
	MOVEQ	#7,D0
.c:	SF	(n_pt4_trigger,A0)
	LEA	(n_SIZEOF,A0),A0
	DBF	D0,.c
	MOVEM.L	(A7)+,D0/A0
	ANDI	#$fb,CCR
	RTS
.r:	ORI	#4,CCR
	RTS

; voices 1/2
; paula 0/1 play v1/2 direct, v3-8 lead MIX_LEAD ticks -> delay v1/2:
; v1/2 to shadow regs, per tick one entry (trig, smp, loop, per, vol),
; entry from MIX_LEAD ticks ago goes to paula
; trig as replayer: dma off, regs, (wait) dma on, (wait) loop ptr
M68D_TRIG	EQU	0		; 0 none, 1 trig, 2 voice off
M68D_START	EQU	2
M68D_LEN	EQU	6		; words
M68D_LOOP	EQU	8
M68D_REPLEN	EQU	12		; words
M68D_PER	EQU	14
M68D_VOL	EQU	16
M68D_SIZE	EQU	20
M68D_SLOTS	EQU	8		; pow2 > lead

; from pt_MixStart (68000): v1/2 -> shadow regs, paula 0/1 off, clear buf
pt_Mix68DirectInit:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	LEA	dat_Channel1,A0
	LEA	mix_AudPtrTable,A1
	MOVE.L	#mix_Shadow,(A1)+
	MOVE.L	#mix_Shadow+aud_SIZEOF,(A1)
	MOVEQ	#1,D0
.v:	CLR.W	(n_pt4_dmacon,A0)
	CLR.W	(n_pt4_dmaset,A0)
	CLR.W	(n_pt4_intmask,A0)
	CLR.W	(n_pt4_intena,A0)
	LEA	n_SIZEOF(A0),A0
	DBF	D0,.v
	LEA	mix_Shadow,A0
	MOVEQ	#2*aud_SIZEOF/4-1,D0
.cs:	CLR.L	(A0)+
	DBF	D0,.cs
	LEA	mix68_DFifo,A0
	MOVE.W	#2*M68D_SLOTS*M68D_SIZE/2-1,D0
.cf:	CLR.W	(A0)+
	DBF	D0,.cf
	CLR.W	mix68_DTick
	CLR.W	mix68_DPend
	MOVE.W	#MIX_LEAD,mix68_DLead	; lead as pt_MixLeadSpt
	TST.B	mix68_Slow
	BEQ.S	.ld
	MOVE.W	#3*MIX_LEAD,mix68_DLead
.ld:
	ST	mix68_DOn
	TST.B	ahi_NoPaula
	BNE.S	.r
	MOVE.W	#$0003,DMACON		; paula 0/1 dma + audio irq off (no direct path)
	MOVE.W	#$0180,INTENA
	MOVE.W	#$0180,INTREQ
	CLR.W	AUD0VOL
	CLR.W	AUD1VOL
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS

; stop (pt_StopSilence): drop pending trigs/vols, else pt_Mix68DirectTick
; restarts dma of looping v1/2 after stop
pt_Mix68DirectFlush:
	TST.B	mix68_DOn
	BEQ.S	.r
	MOVEM.L	D0/A0,-(A7)
	LEA	mix68_DFifo,A0
	MOVEQ	#2*M68D_SLOTS-1,D0
.c:	CLR.W	(M68D_TRIG,A0)
	CLR.W	(M68D_VOL,A0)
	LEA	M68D_SIZE(A0),A0
	DBF	D0,.c
	CLR.W	mix68_DPend
	MOVEM.L	(A7)+,D0/A0
.r:	RTS

; per tick (pt_Mix68OneTick): store entry, output old one (part 1)
pt_Mix68DirectTick:
	TST.B	mix68_DOn
	BEQ.W	.r
	MOVEM.L	D0-D5/A0-A6,-(A7)
	MOVE.W	mix68_DTick,D5
	ADDQ.W	#1,mix68_DTick
	MOVEQ	#0,D4			; voice 0, 1
	CLR.W	mix68_DPend
.v:	; store entry
	MOVE.W	D5,D0
	AND.W	#M68D_SLOTS-1,D0
	BSR.W	.slot			; a0=entry (slot d0, voice d4)
	LEA	dat_Channel1,A6
	MOVE.W	D4,D1
	MULU	#n_SIZEOF,D1
	ADDA.L	D1,A6
	LEA	mix_Shadow,A4
	MOVE.W	D4,D1
	LSL.W	#4,D1
	ADDA.W	D1,A4
	BSR.W	pt_Mix68DirectGet
	; output entry from MIX_LEAD ticks ago
	MOVE.W	D5,D0			; no sign test: d5 wraps after 32768 ticks, zeroed entries at start,
	SUB.W	mix68_DLead,D0		; slot idx via and stays wrap-safe
	AND.W	#M68D_SLOTS-1,D0
	BSR.W	.slot
	TST.B	ahi_NoPaula
	BNE.S	.nx
	LEA	AUD0LCH,A1
	MOVE.W	D4,D1
	LSL.W	#4,D1
	ADDA.W	D1,A1			; paula ch of voice
	MOVEQ	#1,D3
	LSL.W	D4,D3			; dma bit
	MOVE.W	(M68D_TRIG,A0),D0
	BEQ.S	.pv
	MOVE.W	D3,DMACON		; trig or end: dma off
	CMP.W	#1,D0
	BNE.S	.nx
	MOVE.L	(M68D_START,A0),(A1)
	MOVE.W	(M68D_LEN,A0),(aud_LEN,A1)
	OR.W	D3,mix68_DPend
	IFD	DEBUGFX
	ADDQ.W	#1,dbg68_DTrig		; dbg: trigs v1/2
	ENDC
.pv:	MOVE.W	(M68D_PER,A0),D0
	CMP.W	#2,D0
	BCS.S	.vol
	MOVE.W	D0,(aud_PER,A1)
.vol:	MOVE.W	(M68D_VOL,A0),(aud_VOL,A1)
.nx:	ADDQ.W	#1,D4
	CMP.W	#2,D4
	BNE.W	.v
	BSR.W	pt_Mix68DMark
	IFD	DEBUGFX
	MOVE.W	DMACONR,D0		; dbg: dma state (bit 0/1 = v1/2 running)
	MOVE.W	D0,dbg68_DDma
	OR.W	D0,dbg68_DDmaOr
	ENDC
	MOVEM.L	(A7)+,D0-D5/A0-A6
.r:	RTS
.slot:	LEA	mix68_DFifo,A0		; a0=entry slot d0 voice d4
	MULU	#2*M68D_SIZE,D0
	ADDA.L	D0,A0
	TST.W	D4
	BEQ.S	.s0
	LEA	M68D_SIZE(A0),A0
.s0:	RTS

; part 2/3 after paula 2 (d6=3: dma on) / paula 3 (d6=4: loop ptr),
; >= 3 raster lines after previous step (paula must see dma off/start)
pt_Mix68DirectPhase:
	TST.W	mix68_DPend
	BEQ.W	.r
	TST.B	ahi_NoPaula
	BNE.W	.r
	MOVEM.L	D0-D4/A0-A1,-(A7)
	BSR.W	pt_Mix68DWait
	CMP.W	#3,D6
	BNE.S	.loop
	MOVE.W	mix68_DPend,D0
	OR.W	#$8000,D0
	MOVE.W	D0,DMACON
	IFD	DEBUGFX
	BSR.W	dbg75_DirNote		; dbg: real dma start v1
	ENDC
	BSR.W	pt_Mix68DMark
	BRA.S	.x
.loop:	MOVEQ	#0,D4
.lv:	BTST	D4,mix68_DPend+1
	BEQ.S	.ln
	MOVE.W	mix68_DTick,D0		; entry just output: tick-1-MIX_LEAD
	SUBQ.W	#1,D0
	SUB.W	mix68_DLead,D0
	AND.W	#M68D_SLOTS-1,D0
	LEA	mix68_DFifo,A0
	MULU	#2*M68D_SIZE,D0
	ADDA.L	D0,A0
	TST.W	D4
	BEQ.S	.l0
	LEA	M68D_SIZE(A0),A0
.l0:	LEA	AUD0LCH,A1
	MOVE.W	D4,D1
	LSL.W	#4,D1
	ADDA.W	D1,A1
	MOVE.L	(M68D_LOOP,A0),(A1)
	MOVE.W	(M68D_REPLEN,A0),D0
	BNE.S	.lw
	MOVEQ	#1,D0
.lw:	MOVE.W	D0,(aud_LEN,A1)
.ln:	ADDQ.W	#1,D4
	CMP.W	#2,D4
	BNE.S	.lv
	CLR.W	mix68_DPend
.x:	MOVEM.L	(A7)+,D0-D4/A0-A1
.r:	RTS

pt_Mix68DMark:
	MOVE.L	D0,-(A7)
	MOVE.L	$DFF004,D0
	LSR.L	#8,D0
	AND.W	#$1ff,D0
	MOVE.W	D0,mix68_DLine
	MOVE.L	(A7)+,D0
	RTS
pt_Mix68DWait:				; until >= 3 lines after mix68_DLine
	MOVE.L	D0,-(A7)
.w:	MOVE.L	$DFF004,D0
	LSR.L	#8,D0
	AND.W	#$1ff,D0
	SUB.W	mix68_DLine,D0
	BPL.S	.p
	ADD.W	#313,D0
.p:	CMP.W	#3,D0
	BCS.S	.w
	MOVE.L	(A7)+,D0
	RTS

; fill entry a0 from ch a6 / shadow a4 (detect as pt_Mix68UpdateVoice)
pt_Mix68DirectGet:
	CLR.W	(M68D_TRIG,A0)
	MOVEQ	#0,D2
	TST.B	(n_pt4_dmawait,A6)
	BEQ.S	.chk
	SF	(n_pt4_dmawait,A6)
	CLR.W	(n_pt4_dmacount,A6)
	MOVEQ	#1,D2
.chk:	CMPI.W	#1,(aud_PER,A4)
	BNE.S	.nt
	MOVEQ	#1,D2
	MOVE.W	(n_period,A6),(aud_PER,A4)
.nt:	TST.W	D2
	BEQ.S	.lp
	MOVE.W	#2,(M68D_TRIG,A0)	; no smp: voice off
	MOVE.L	(n_start,A6),D0
	BEQ.S	.lp
	MOVE.W	(n_length,A6),D1
	CMP.W	#2,D1
	BLS.S	.lp
	MOVE.W	#1,(M68D_TRIG,A0)
	MOVE.L	D0,(M68D_START,A0)
	MOVE.W	D1,(M68D_LEN,A0)
	MOVEQ	#0,D0			; vol as audio irq in direct path
	MOVE.B	(n_volume,A6),D0
	MULU.W	(n_pt4_volscale,A6),D0
	ADD.W	#32,D0
	LSR.W	#6,D0
	MOVE.W	D0,(aud_VOL,A4)
.lp:	MOVE.L	(n_loopstart,A6),(M68D_LOOP,A0)
	MOVE.W	(n_replen,A6),(M68D_REPLEN,A0)
	MOVE.W	(aud_VOL,A4),D0
	TST.B	(n_pt4_chunked,A6)
	BEQ.S	.vs
	MOVE.W	(n_pt4_irqvol,A6),D0
.vs:	TST.B	(n_pt4_chanoff,A6)
	BEQ.S	.vk
	MOVEQ	#0,D0
.vk:	CMP.W	#64,D0
	BLS.S	.vb
	MOVEQ	#64,D0
.vb:	MOVE.W	(n_pt4_chanbit,A6),D1	; 84y blend as mixed voices (voice n: (15-y)/15)
	AND.W	#3,D1
	MOVE.L	A1,-(A7)
	LEA	efx8_Blend,A1
	MOVE.B	(A1,D1.W),D1
	MOVEA.L	(A7)+,A1
	AND.W	#$ff,D1
	BEQ.S	.vset
	NEG.W	D1
	ADD.W	#15,D1
	MULU.W	D1,D0
	DIVU.W	#15,D0
.vset:	MOVE.W	D0,(M68D_VOL,A0)
	MOVE.W	(aud_PER,A4),D0
	CMP.W	#2,D0
	BCC.S	.ps
	MOVE.W	(n_period,A6),D0
.ps:	MOVE.W	D0,(M68D_PER,A0)
	RTS

	IFD	DEBUGFX
; timing dbg: time base e-clock (timer.device ReadEClock)
dbg75_Now:				; d0 = e-clock low 32 b (709379 Hz)
	MOVEM.L	D1/A0-A1/A6,-(A7)
	MOVEQ	#0,D0
	MOVE.L	dbg_TimerBase,D1
	BEQ.S	.x
	LEA	dbg75_EC,A0
	MOVEA.L	D1,A6
	JSR	(-60,A6)
	MOVE.L	dbg75_EC+4,D0
.x:	MOVEM.L	(A7)+,D1/A0-A1/A6
	RTS
dbg75_Start:				; d1 = write pos at ring start
	MOVE.L	D0,-(A7)
	BSR.S	dbg75_Now
	MOVE.L	D0,dbg75_T0
	MOVE.L	D1,dbg75_WAbs
	ADDQ.W	#1,dbg75_Starts
	MOVE.L	(A7)+,D0
	RTS
dbg75_MixNote:				; a6=ch
	CMPA.L	#dat_Channel3,A6
	BNE.S	.r
	MOVEM.L	D0-D2/A0,-(A7)
	MOVE.W	dbg75_NM,D0
	CMP.W	#16,D0
	BCC.S	.x
	ADDQ.W	#1,dbg75_NM
	LSL.W	#2,D0
	LEA	dbg75_Mix,A0
	ADDA.W	D0,A0
	MOVE.L	dbg75_WAbs,D0		; e-clocks = WAbs*709379/rate: q = WAbs/rate, r = rest
	MOVEQ	#0,D1
	MOVE.W	mix_Rate,D1
	DIVU	D1,D0			; d0 = r:q
	MOVE.L	D0,D2
	SWAP	D2
	AND.L	#$ffff,D2		; r
	MULU	#7094,D2		; r*7094/rate*100 (err < 100 e-clocks)
	DIVU	D1,D2
	AND.L	#$ffff,D2
	MULU	#100,D2
	AND.L	#$ffff,D0		; q*709379 = q*$A<<16 + q*$D303
	MOVE.L	D0,D1
	MULU	#$000a,D1
	SWAP	D1
	CLR.W	D1
	MULU	#$d303,D0
	ADD.L	D1,D0
	ADD.L	D2,D0
	ADD.L	dbg75_T0,D0
	MOVE.L	D0,(A0)
.x:	MOVEM.L	(A7)+,D0-D2/A0
.r:	RTS
dbg75_DirNote:
	BTST	#0,mix68_DPend+1
	BEQ.S	.r
	MOVEM.L	D0/A0,-(A7)
	MOVE.W	dbg75_ND,D0
	CMP.W	#16,D0
	BCC.S	.x
	ADDQ.W	#1,dbg75_ND
	LSL.W	#2,D0
	LEA	dbg75_Dir,A0
	ADDA.W	D0,A0
	MOVE.L	D0,-(A7)
	BSR.W	dbg75_Now
	MOVE.L	D0,(A0)
	ADDQ.L	#4,A7
.x:	MOVEM.L	(A7)+,D0/A0
.r:	RTS
	ENDC
