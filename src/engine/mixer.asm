; software mixer for 8ch: voices n and n+4 share paula ch n
; mixed pair: sum into ring paula loops; direct pairs stay on dma
	INCLUDE	"src/sys/x20.i"		; 020 area
; hooks: pt_MixMusicEntry/LoopInit/NextVoice/TickExit/ExitHook
; mixer runs as softint (Cause) after the tick, not in cia irq
; 020 insns only in pt_MixTickSoft and below (mix_Enabled)

PAULA_CLOCK	EQU	3546895		; PAL
ECLOCK		EQU	709379

; hooks (68000)
; replaces move.l/beq.w at pt_RpMusic start (8 b)
; -> d0=dat_RpPlayMode, 0 -> straight to pt_RpExit
pt_MixMusicEntry:
	TST.B	mix_Offline		; offline render in task
	BEQ.S	.live
	MOVE.L	A0,-(A7)		; caller by stack: task stack = renderer, else irq/softint
	MOVEA.L	ABSEXECBASE.W,A0	; (a flag is not enough: cia irq can hit mid render call)
	MOVEA.L	(276,A0),A0		; ThisTask
	CMPA.L	(58,A0),A7		; tc_SPLower
	BLS.S	.irq
	CMPA.L	(62,A0),A7		; tc_SPUpper
	BHI.S	.irq
	MOVEA.L	(A7)+,A0
	MOVE.L	dat_RpPlayMode,D0	; renderer: skip mixer start/stop
	RTS
.irq:	MOVEA.L	(A7)+,A0
	MOVE.L	#pt_MixTickExit,(A7)	; irq call: do nothing (restore regs, ret)
	RTS
.live:	TST.B	mix_Enabled
	BEQ.S	.mode
	TST.B	mix_Active
	BEQ.S	.inactive
	BSR.W	pt_MixWanted		; left 8ch and no ahi -> mixer off
	BNE.S	.mode
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_MixStop
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.S	.mode
.inactive:
	BSR.W	pt_MixWanted		; 8ch or ahi -> mixer on (also on stop: kbd notes)
	BEQ.S	.mode
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_MixStart
	MOVEM.L	(A7)+,D0-D7/A0-A6
.mode:	MOVE.L	dat_RpPlayMode,D0
	CMP.L	efx8_PlayPrev,D0	; clear 8xy state at play start
	BEQ.S	.samepm
	MOVE.L	D0,efx8_PlayPrev
	TST.L	D0
	BEQ.S	.samepm
	JSR	pt_Efx8Reset
	IFD	DEBUGFX
	CLR.L	dbg_MixPos		; dbg: dump from play start
	ENDC
.samepm:
	TST.L	D0
	BNE.S	.ret
	MOVE.L	#pt_RpExit,(A7)		; as orig: stop -> pt_RpExit
.ret:	RTS

; replaces moveq #3,d7 / lea AUD0LCH,a5 / lea dat_Channel1,a6 (14 b)
pt_MixLoopInit:
	TST.B	mix_Init
	BNE.S	.ok
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_MixInitOnce
	MOVEM.L	(A7)+,D0-D7/A0-A6
.ok:	MOVE.W	dat_RpNumChannels,D7
	SUBQ.W	#1,D7
	LEA	dat_Channel1,A6
	; volscale voices 5-8 (pt4 sets n_pt4_volscale for ch1-4 only):
	; master vol, ch off (bit n-1 in dat_RpDmaChanMask) -> 0
	MOVEM.L	D0-D1/A0,-(A7)
	MOVE.W	dat_RpMasterVol,D7
	MOVE.W	dat_RpDmaChanMask,D0
	LEA	dat_Channel5,A0
	MOVEQ	#4,D1
.vs:	BTST	D1,D0
	BNE.S	.von
	CLR.W	(n_pt4_volscale,A0)
	BRA.S	.vnext
.von:	MOVE.W	D7,(n_pt4_volscale,A0)
.vnext:	LEA	(n_SIZEOF,A0),A0
	ADDQ.W	#1,D1
	CMP.W	#8,D1
	BNE.S	.vs
	MOVEM.L	(A7)+,D0-D1/A0
	BSR.W	pt_Mix68VolScale	; 68000: v1/2 to a third
	MOVE.W	dat_RpNumChannels,D7
	SUBQ.W	#1,D7
	MOVE.L	#mix_AudPtrTable,mix_AudPtrCur
	MOVEA.L	mix_AudPtrTable,A5
	RTS

; replaces lea (aud_SIZEOF,a5),a5 / lea (n_SIZEOF,a6),a6 (8 b)
pt_MixNextVoice:
	LEA	(n_SIZEOF,A6),A6
	MOVE.L	A0,-(A7)
	MOVEA.L	mix_AudPtrCur,A0
	ADDQ.L	#4,A0
	MOVE.L	A0,mix_AudPtrCur
	MOVEA.L	(A0),A5
	MOVEA.L	(A7)+,A0
	RTS

; in pt_RpExit: replaces movem.l (a7)+,d0-d7/a0-a6 / rts (6 b)
pt_MixTickExit:
	IFD	DEBUGAUTO
	TST.B	mix_OffCall		; task render call: no driver tick, no watchdog
	BNE.S	.nowd
	ADDQ.W	#1,dbg_TickCnt		; dbg: tick cnt
	BSR.W	dbg_Watchdog		; dbg: watchdog
.nowd:
	ENDC
	TST.B	mix_Active
	BEQ.S	.out
	BSR.W	pt_MixGuardRing		; guard ring ch each tick (vol 64, no audio irq, masks 0)
	ADDQ.W	#1,mix_TicksDue
	MOVE.L	$DFF004,D0		; tick line (pt_MixRingRestart compensates softint delay)
	LSR.L	#8,D0
	AND.W	#$1ff,D0
	MOVE.W	D0,mix_TickLine

	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixCauseCnt
	ENDC
	IFD	DEBUGFX
	MOVE.L	$DFF004,D0		; trigger line (softint delay)
	LSR.L	#8,D0
	AND.L	#$1ff,D0
	MOVE.W	D0,dbg68_CauseLine
	ENDC
	LEA	mix_SoftInt,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-180,A6)		; Cause
.out:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; program end (pt_CleanupAll): free ring/dump, reset pr_WindowPtr
; not in dev close routine (1c468): runs on diskop open too
pt_MixExitHook:
	JSR	pt_CheckFileLock		; orig
	JSR	pt_AhiClose		; ahi close
	JSR	pt_RtgClose		; end rtg task
	JSR	pt_FltFree41		; free filter editor try-it backup
	MOVE.L	x20_Base,D0		; free 020 area (after rtg task, which uses it)
	BEQ.S	.nox20
	MOVEA.L	D0,A1
	MOVE.L	#X20_SIZE,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	CLR.L	x20_Base
.nox20:
	JSR	pt_DiskLongFree		; free long name pool
	JSR	pt_DosRestoreRequesters	; restore pr_WindowPtr
	IFD	DEBUGFX
	MOVE.L	dbg_MixBuf,D0
	BEQ.S	.nodump
	MOVEA.L	D0,A1
	MOVE.L	#4*DBG_MIXCH,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dbg_MixBuf
.nodump:
	ENDC
	JSR	pt_Mix68Free		; 68000 ring/tab (clears mix_Ring)
	MOVE.L	mix_Ring,D0
	BEQ.S	.nomem
	MOVEA.L	D0,A1
	MOVE.L	#4*MIX_RING,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	CLR.L	mix_Ring
.nomem:	RTS

; init (68000)
; task ctx, replaces pt_InitAudioChannels: tabs, ring (no alloc in irq)
pt_MixInitTask:
	JSR	pt_InitAudioChannels
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_CpuBench		; measure cpu
	BSR.W	pt_MixInitOnce
	JSR	pt_CpuAboutFill		; about box line
	JSR	pt_MemAboutFill		; mem line once, later pt_MemAboutHook
	JSR	pt_DosNoRequesters	; pr_WindowPtr = -1: no requesters, lock/open fail silently
	TST.B	mix_Enabled
	BEQ.W	.r
	TST.B	mix_Is68k		; 68000: ring/tab only in 8ch (pt_Mix68Mem)
	BNE.W	.r
	MOVE.L	#4*MIX_RING,D0
	MOVE.L	#$10002,D1		; MEMF_CHIP|MEMF_CLEAR
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,mix_Ring		; 0 -> no chip ram, mixer stays off
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; main loop (task ctx, every pass): alloc ring if missing
pt_MixTaskPoll:
	IFD	DEBUGFX
	ADDQ.L	#1,dbg68_Polls		; dbg: main loop passes
	ENDC
	IFD	DEBUGAUTO
	BSR.W	dbg_StopWatch		; dbg: end of play
	MOVE.L	A0,-(A7)		; dbg: exec state per main loop pass
	MOVEA.L	ABSEXECBASE.W,A0
	MOVE.L	$118(A0),dbg80_Idle	; IdleCount
	MOVE.L	$11c(A0),dbg80_Disp	; DispCount
	MOVE.B	$126(A0),dbg80_IDN	; IDNestCnt
	MOVE.B	$127(A0),dbg80_TDN	; TDNestCnt
	MOVEA.L	(A7)+,A0
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)	; dbg: pr_WindowPtr now
	MOVEA.L	ABSEXECBASE.W,A6
	SUBA.L	A1,A1
	JSR	(-294,A6)
	MOVE.L	D0,dbg_ProcNow
	MOVEA.L	D0,A0
	MOVE.L	(184,A0),dbg_WinPtrNow
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	ENDC
	; renew pr_WindowPtr = -1 each pass (pt resets it to 0 on diskop open)
	MOVE.L	disk_ProcPtr,D0
	BEQ.S	.nowin
	MOVEA.L	D0,A0
	MOVE.L	#-1,(184,A0)
.nowin:
	BSR.W	pt_AhiPoll		; ahi output: open, collect requests, send block
	JSR	pt_RtgPoll		; rtg mirror start once
	JSR	pt_SetPoll		; setup page status lines
	IFD	DEBUGAUTO
	CMPI.B	#2,dbg_WdDone		; wd line pending -> show here
	BNE.S	.nowd
	MOVE.B	#1,dbg_WdDone
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dbg_WdText,A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.nowd:
	ENDC
	TST.B	mix_Init
	BEQ.W	.r
	TST.B	mix_Active		; set smp mem class continuously (pt_BtnSetupUndynMod writes chip back)
	BEQ.S	.nofast
	TST.B	mix_Is68k		; 68000: v1/2 on dma -> smp stay in chip
	BNE.S	.nofast
	MOVE.L	#$00010001,dat_DiskOpViewMode
.nofast:
	BSR.W	pt_MixRatePoll		; rmb on CHANNELS (setup) picks mix rate
	TST.B	smp_MsgPending		; wav/aiff loaded -> report format
	BEQ.S	.nosmp
	SF	smp_MsgPending
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	smp_MsgText,A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.nosmp:
	TST.B	efx8_SavePending	; mod saved with 8xy -> report once
	BEQ.S	.nosave
	SF	efx8_SavePending
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	efx8_SaveText,A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.nosave:
	TST.B	fmt_ExtPending		; mod loaded with ft octaves -> report once
	BEQ.S	.noext
	SF	fmt_ExtPending
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	fmt_ExtText(PC),A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.noext:	TST.B	fmt_TruncPending	; file shorter than header says -> report once
	BEQ.S	.notrunc
	SF	fmt_TruncPending
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	fmt_TruncText(PC),A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.notrunc:
	; 68000 w/o mixer: hint once on switch to 8ch
	MOVE.W	dat_RpNumChannels,D0
	CMP.W	mix_HintChans,D0
	BEQ.S	.nohint
	MOVE.W	D0,mix_HintChans
	CMP.W	#8,D0
	BNE.S	.nohint
	TST.B	mix_Enabled
	BNE.S	.nohint
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	mix_Hint68kText(PC),A0
	CMP.L	#MIX68_SLOWBENCH,dat_CpuBench	; a500 speed ok with fast ram
	BCS.S	.hcpu
	LEA	mix_Hint68kRam(PC),A0
.hcpu:	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
.nohint:
	TST.B	mix_Enabled
	BEQ.W	.r
	IFD	DEBUGFX
	TST.L	dbg_MixBuf
	BNE.S	.havedump
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	#4*DBG_MIXCH,D0
	MOVE.L	#$10005,D1		; fast only: 1 mb chip a500+ lacks 90 kb for 8ch switch/load
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dbg_MixBuf
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
.havedump:
	ENDC
	TST.B	mix_Is68k		; 68000: mem only in 8ch
	BEQ.S	.r20
	BSR.W	pt_Mix68Mem
	BRA.W	.r
.r20:	TST.L	mix_Ring
	BNE.W	.r
	TST.B	mix_RingFail
	BNE.W	.r
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	#4*MIX_RING,D0
	MOVE.L	#$10002,D1		; MEMF_CHIP|MEMF_CLEAR
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,mix_Ring
	BNE.S	.ok
	ST	mix_RingFail		; no chip ram: mixer stays off
.ok:	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
.r:	RTS
mix_Hint68kText:	DC.B	"8CHN: CH5-8 NEED A FASTER CPU",0
mix_Hint68kRam:	DC.B	"8CHN: CH5-8 NEED FAST RAM",0
fmt_ExtText:	DC.B	"NOTES OUTSIDE PT OCTAVES!",0
	EVEN

pt_MixInitOnce:
	ST	mix_Init
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixInitCnt
	ENDC
	; 020 area only on 020 (any mem), 68000 keeps 0
	MOVEA.L	ABSEXECBASE.W,A6
	BTST	#1,(297,A6)		; AFB_68020
	BEQ.S	.novol
	TST.L	x20_Base
	BNE.S	.have
	MOVE.L	#X20_SIZE,D0
	MOVE.L	#$10001,D1		; MEMF_PUBLIC|MEMF_CLEAR
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,x20_Base
	BEQ.S	.novol			; no mem: mixer and rtg stay off
.have:	; vol tab 65x256: (s_signed*v)>>7
	X20LEA	X20_VOLTAB,A0
	MOVEQ	#0,D0
.vl:	MOVEQ	#0,D1
.sl:	MOVE.B	D1,D2
	EXT.W	D2
	MULS	D0,D2
	ASR.W	#7,D2
	MOVE.B	D2,(A0)+
	ADDQ.W	#1,D1
	CMP.W	#256,D1
	BNE.S	.sl
	ADDQ.W	#1,D0
	CMP.W	#65,D0
	BNE.S	.vl
.novol:	; a5 tab: voices 1-4 paula, 5-8 shadow
	LEA	mix_AudPtrTable,A0
	LEA	AUD0LCH,A1
	LEA	mix_Shadow+4*aud_SIZEOF,A2
	MOVEQ	#3,D0
.tab:	MOVE.L	A1,(A0)
	MOVE.L	A2,16(A0)
	LEA	aud_SIZEOF(A1),A1
	LEA	aud_SIZEOF(A2),A2
	ADDQ.L	#4,A0
	DBF	D0,.tab
	; voices 5-8: chanbit 4-7, no hw masks, own chunk list bufs
	LEA	dat_Channel5,A0
	LEA	mix_ChunkLists,A1
	MOVEQ	#4,D0
.ch:	MOVE.W	D0,(n_pt4_chanbit,A0)
	CLR.W	(n_pt4_dmacon,A0)
	CLR.W	(n_pt4_dmaset,A0)
	CLR.W	(n_pt4_intmask,A0)
	CLR.W	(n_pt4_intena,A0)
	MOVE.L	A1,(n_pt4_chunklist,A0)
	LEA	800(A1),A1
	LEA	n_SIZEOF(A0),A0
	ADDQ.W	#1,D0
	CMP.W	#8,D0
	BNE.S	.ch
	; softint struct
	LEA	mix_SoftInt,A0
	CLR.L	(A0)
	CLR.L	4(A0)
	MOVE.B	#2,8(A0)		; NT_INTERRUPT
	MOVE.B	#0,9(A0)
	MOVE.L	#.name,10(A0)
	CLR.L	14(A0)
	MOVE.L	#pt_MixTickSoft,18(A0)
	; cpu from AttnFlags (dat_CPUType set later): 020 -> 22 khz,
	; 030+ -> 28.6 khz
	SF	mix_Enabled
	MOVE.W	#22050,mix_Rate
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.W	(296,A6),D0		; AttnFlags
	BTST	#1,D0			; AFB_68020
	BEQ.S	.rate
	TST.L	x20_Base		; no 020 area -> no mixer
	BEQ.S	.rate
	ST	mix_Enabled
	BSR.W	pt_MixApplyRate
.rate:	TST.B	mix_Enabled		; no 020 -> 68000 mixer (mix68k.asm)
	BNE.S	.r20
	BSR.W	pt_Mix68Init
.r20:	CLR.B	mix_PairMask
	SF	mix_Active
	RTS
.name:	DC.B	"PT4.1 Mixer",0
	EVEN

; rate from mix_RateSel (setup) or bench (a500+ 640, a1200 3264,
; a4000/040 12096): auto >= 8000 -> 28.6 khz, else 22 khz
pt_MixApplyRate:
	TST.B	mix_Is68k		; 68000: own rates
	BNE.W	pt_Mix68ApplyRate
	MOVEM.L	D0-D1/A0,-(A7)
	MOVEQ	#0,D0
	MOVE.B	mix_RateSel,D0
	CMP.B	#3,D0
	BLS.S	.selok
	MOVEQ	#0,D0
	MOVE.B	D0,mix_RateSel
.selok:	ADD.W	D0,D0
	LEA	mix_RateTab(PC),A0
	MOVE.W	(A0,D0.W),D1
	BNE.S	.set
	MOVE.W	#22050,D1		; auto
	CMP.L	#8000,dat_CpuBench
	BCS.S	.set
	MOVE.W	#28604,D1
.set:	BSR.W	pt_MixSetRate
	MOVEM.L	(A7)+,D0-D1/A0
	RTS

; d1.w = rate -> mix_Period = round(PAULA_CLOCK/rate), mix_Rate = actual
; must be actual rate, else ring runs off the replayer (drift)
pt_MixSetRate:
	MOVEM.L	D0-D2,-(A7)
	MOVEQ	#0,D2
	MOVE.W	D1,D2
	MOVE.L	#PAULA_CLOCK,D0
	MOVE.L	D2,D1
	LSR.L	#1,D1
	ADD.L	D1,D0			; + rate/2: round
	MOVE.L	D2,D1
	BSR.W	pt_MixDiv32
	MOVE.W	D0,mix_Period
	MOVE.L	D0,D2
	MOVE.L	#PAULA_CLOCK,D0
	MOVE.L	D2,D1
	LSR.L	#1,D1
	ADD.L	D1,D0
	MOVE.L	D2,D1
	BSR.W	pt_MixDiv32
	MOVE.W	D0,mix_Rate
	MOVEM.L	(A7)+,D0-D2
	RTS
mix_RateTab:	DC.W	0,14000,22050,28604

; pick mix rate: rmb on setup field CHANNELS in 8ch (task ctx)
pt_MixRatePoll:
	JSR	pt_SetIsP1		; setup page visible?
	BNE.W	.release
	RMB
	BNE.W	.release		; rmb not pressed (bit set = released)
	TST.B	mix_RateLock
	BNE.W	.r
	MOVE.W	dat_EditDigitValue,D0	; mouse x
	CMP.W	#420,D0
	BCS.W	.r
	MOVE.W	dat_PalEdSelectPos,D0	; mouse y
	CMP.W	#33,D0
	BCS.W	.r
	CMP.W	#43,D0
	BHI.W	.r
	ST	mix_RateLock
	BTST	#5,dat_ModeFlags
	BNE.S	.r			; 4ch: nothing
	TST.B	mix_Enabled
	BEQ.S	.r
	MOVEM.L	D0-D7/A0-A6,-(A7)
	ADDQ.B	#1,mix_RateSel
	CMPI.B	#3,mix_RateSel
	BLS.S	.ok
	CLR.B	mix_RateSel
.ok:	BSR.W	pt_MixApplyRate
	TST.B	mix_Active		; running: restart (next tick)
	BEQ.S	.draw
	BSR.W	pt_MixStop
.draw:	JSR	pt_0641			; redraw CHANNELS
	MOVEQ	#0,D0
	MOVE.B	mix_RateSel,D0
	MULU	#16,D0
	LEA	mix_RateMsg(PC),A0
	TST.B	mix_Is68k
	BEQ.S	.msg
	LEA	mix68_RateMsg,A0
.msg:	ADDA.W	D0,A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
.release:
	SF	mix_RateLock
.r:	RTS
mix_RateMsg:	DC.B	"8CH MIX: AUTO  ",0	; 16 b each
	DC.B	"8CH MIX: 14 KHZ",0
	DC.B	"8CH MIX: 22 KHZ",0
	DC.B	"8CH MIX: 28 KHZ",0
	EVEN

; setup CHANNELS text (replaces LEA dat_0693,A0 / MOVEQ #0,D0 in pt_0641)
pt_MixSetupText:
	LEA	dat_0693,A0		; "4CHN8CHN", orig picks with d0 = 0/4
	MOVEQ	#0,D0
	BTST	#5,dat_ModeFlags
	BNE.S	.r			; 4ch
	MOVEQ	#4,D0			; "8CHN" (caller: lea (0,a0,d0.w))
	TST.B	mix_Enabled
	BEQ.S	.r
	TST.B	mix_Is68k		; 68000 shows "8CHN" (rate in MIX RATE)
	BNE.S	.r
	MOVEQ	#0,D1
	MOVE.B	mix_RateSel,D1
	BEQ.S	.r			; auto -> "8CHN"
	LEA	mix_RateText-4(PC),A0	; caller adds d0 = 4 in 8ch
	SUBQ.W	#1,D1
	LSL.W	#2,D1
	ADDA.W	D1,A0
	MOVEQ	#4,D0
.r:	RTS
mix_RateText:	DC.B	"8-148-228-28"
	EVEN

; u32/u32 (68000): d0/d1 -> d0 quot, d1 rem
pt_MixDiv32:
	MOVEM.L	D2-D3,-(A7)
	MOVE.L	D1,D2
	MOVEQ	#0,D1
	MOVEQ	#31,D3
.l:	ADD.L	D0,D0
	ADDX.L	D1,D1
	CMP.L	D2,D1
	BCS.S	.n
	SUB.L	D2,D1
	ADDQ.L	#1,D0
.n:	DBF	D3,.l
	MOVEM.L	(A7)+,D2-D3
	RTS

; start/stop (68000)
; pairs: mixed if voice n+5 has a note anywhere in the module,
; masks/a5 tab, ring, start paula ch of pairs
pt_MixStart:
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixStartCnt
	ENDC
	BSR.W	pt_MixApplyRate		; setup choice or auto
	CLR.B	mix_PairMask
	BSR.W	pt_MixWanted		; 8ch or ahi (ahi: 4ch via mixer too)
	BEQ.W	.nopairs
	MOVE.B	#$0f,mix_PairMask	; 8ch: all 4 pairs, silent pairs cost nothing
	TST.B	mix_Is68k		; 68000 mixes paula 2/3 only, v1/2 direct
	BEQ.S	.p4
	MOVE.B	#$0c,mix_PairMask
.p4:
	; ring must exist (pt_MixInitTask), else no mixing
	TST.L	mix_Ring
	BEQ.W	.nopairs
	; clear ring
	JSR	pt_MixRingClear		; 68000: rings of ch 2/3 only
	BSR.W	pt_MixCalcSpt
	; lead
	BSR.W	pt_MixLeadSpt		; lead (2 ticks, a500 mode 6)
	SWAP	D0
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	MOVE.L	D1,mix_WriteInt
	IFD	DEBUGFX
	JSR	dbg75_Start		; dbg: ring time base
	ENDC
	CLR.W	mix_WriteFrac
	CLR.W	mix_TicksDue
	; clear fx state voices 5-8 (pt4 pt_0617 does 1-4 only)
	LEA	dat_Channel5,A0
	MOVEQ	#3,D0
.fl:	CLR.B	(n_wavecontrol,A0)
	CLR.B	(n_glissfunk,A0)
	CLR.B	(n_loopcount,A0)
	CLR.B	(n_funkoffset,A0)
	CLR.B	(n_vibratopos,A0)
	CLR.B	(n_tremolopos,A0)
	LEA	n_SIZEOF(A0),A0
	DBF	D0,.fl
	JSR	pt_Mix68ExpReset	; invalidate loop bufs
	; clear voice state
	LEA	mix_Voices,A0
	MOVEQ	#8*mv_SIZEOF/4-1,D0
.vclr:	CLR.L	(A0)+
	DBF	D0,.vclr
	; per pair: masks + a5 tab
	MOVE.B	mix_PairMask,D3
	MOVEQ	#0,D2
	LEA	dat_Channel1,A0
	LEA	mix_AudPtrTable,A1
	LEA	mix_Shadow,A2
	LEA	AUD0LCH,A3
	MOVEQ	#0,D4			; dmacon bits of mixed ch
.pair:	BTST	D2,D3
	BEQ.S	.direct
	CLR.W	(n_pt4_dmacon,A0)
	CLR.W	(n_pt4_dmaset,A0)
	CLR.W	(n_pt4_intmask,A0)
	CLR.W	(n_pt4_intena,A0)
	MOVE.L	A2,(A1)
	BSET	D2,D4
	; paula ch -> ring (not if ahi outputs and paula isn't pt's)
	TST.B	ahi_NoPaula
	BNE.S	.pnext
	MOVE.L	mix_Ring,D0
	MOVE.W	D2,D1
	MULU	#MIX_RING,D1
	ADD.L	D1,D0
	MOVE.L	D0,(A3)
	MOVE.W	#MIX_RING/2,(aud_LEN,A3)
	MOVE.W	mix_Period,(aud_PER,A3)
	JSR	pt_SndPaulaVol		; setup page VOLUME (was 64)
	MOVE.W	D0,(aud_VOL,A3)
	BRA.S	.pnext
.direct:
	MOVEQ	#1,D0
	LSL.W	D2,D0
	MOVE.W	D0,(n_pt4_dmacon,A0)
	OR.W	#$8000,D0
	MOVE.W	D0,(n_pt4_dmaset,A0)
	MOVE.W	#$0080,D0
	LSL.W	D2,D0
	MOVE.W	D0,(n_pt4_intmask,A0)
	OR.W	#$8000,D0
	MOVE.W	D0,(n_pt4_intena,A0)
	MOVE.L	A3,(A1)
.pnext:	LEA	n_SIZEOF(A0),A0
	ADDQ.L	#4,A1
	LEA	aud_SIZEOF(A2),A2
	LEA	aud_SIZEOF(A3),A3
	ADDQ.W	#1,D2
	CMP.W	#4,D2
	BNE.W	.pair
	TST.B	mix_Is68k		; v1/2 output delayed (in step with ring)
	BEQ.S	.nod
	JSR	pt_Mix68DirectInit
.nod:	ST	mix_Active
	TST.B	mix_Is68k		; 68000: v1/2 on dma, smp stay in chip
	BNE.S	.chipsmp
	MOVE.L	#$00010001,dat_DiskOpViewMode	; all mixed: smp may go fast (MEMF_PUBLIC|MEMF_CLEAR)
.chipsmp:
	; mixed ch audio irq off + ack: stale INTENA would call pt_RpAudInt
	; with masks 0 -> no ack -> irq storm
	TST.B	ahi_NoPaula		; ahi owns paula -> hands off
	BNE.S	.nohw
	MOVE.W	D4,D0
	LSL.W	#7,D0			; bit n -> INTB_AUD0+n
	MOVE.W	D0,INTENA
	MOVE.W	D0,INTREQ
	TST.B	ahi_Active		; ahi plays ring -> no paula dma, vol 0
	BEQ.S	.dma
	MOVE.L	mix_WriteInt,ahi_ReadPos
	BSR.W	pt_AhiPaulaMute
	RTS
.dma:	OR.W	#$8000,D4
	MOVE.W	D4,DMACON
	RTS
.nohw:	MOVE.L	mix_WriteInt,ahi_ReadPos
	RTS
.nopairs:
	; all direct: masks + tab as orig
	MOVE.L	#$00010002,dat_DiskOpViewMode	; paula direct: smp in chip
	BSR.S	pt_MixRestoreDirect
	RTS

; voices 1-4 back to paula direct (masks, a5 tab)
pt_MixRestoreDirect:
	LEA	dat_Channel1,A0
	LEA	mix_AudPtrTable,A1
	LEA	AUD0LCH,A3
	MOVEQ	#0,D2
.r:	MOVEQ	#1,D0
	LSL.W	D2,D0
	MOVE.W	D0,(n_pt4_dmacon,A0)
	OR.W	#$8000,D0
	MOVE.W	D0,(n_pt4_dmaset,A0)
	MOVE.W	#$0080,D0
	LSL.W	D2,D0
	MOVE.W	D0,(n_pt4_intmask,A0)
	OR.W	#$8000,D0
	MOVE.W	D0,(n_pt4_intena,A0)
	MOVE.L	A3,(A1)
	LEA	n_SIZEOF(A0),A0
	ADDQ.L	#4,A1
	LEA	aud_SIZEOF(A3),A3
	ADDQ.W	#1,D2
	CMP.W	#4,D2
	BNE.S	.r
	RTS

	IFD	DEBUGAUTO
; dbg: capture play end once per play: cnt, driver line (32 b), keycode,
; song/pat pos, tick
dbg_StopWatch:
	MOVEM.L	D0/A0-A1,-(A7)
	MOVE.L	dat_RpPlayMode,D0
	BNE.S	.on
	TST.B	dbg_StopWas
	BEQ.S	.r
	SF	dbg_StopWas
	ADDQ.W	#1,dbg_StopCnt
	LEA	dbg_StopInfo,A1
	MOVE.L	dbg_AutoLine,D0
	BEQ.S	.nl
	MOVEA.L	D0,A0
	MOVEQ	#31,D0
.cp:	MOVE.B	(A0)+,(A1)+
	DBF	D0,.cp
	BRA.S	.k
.nl:	LEA	32(A1),A1
.k:	MOVE.B	dat_KeyCode,(A1)+
	CLR.B	(A1)+
	MOVE.L	dat_RpSongPos,(A1)+
	MOVE.L	dat_RpPatternPos,(A1)+
	MOVE.W	dbg_TickCnt,(A1)+
	BRA.S	.r
.on:	ST	dbg_StopWas
.r:	MOVEM.L	(A7)+,D0/A0-A1
	RTS
	ENDC

	IFD	DEBUGAUTO
; dbg: who ends play? F00 (ch a6, pat pos) or pt_StopPlayback (ret addrs)
dbg_F00Stop:
	TST.L	dat_RpPlayMode
	BEQ.S	.r
	ADDQ.W	#1,dbg_F00Cnt
	MOVE.L	D0,-(A7)
	MOVE.L	A6,D0			; ch idx 0..7 (distance to dat_Channel1 / n_SIZEOF)
	SUB.L	#dat_Channel1,D0
	DIVU	#n_SIZEOF,D0
	AND.L	#$ffff,D0
	MOVE.L	D0,dbg_F00Chan
	MOVE.L	(A7)+,D0
	MOVE.L	dat_RpPatternPos,dbg_F00Pat
	MOVE.L	dat_RpSongPos,dbg_F00Song
	MOVE.L	(n_note,A6),dbg_F00Note	; note/cmd of ch
.r:	CLR.L	dat_RpPlayMode
	RTS
dbg_StopPb:
	TST.L	dat_RpPlayMode
	BEQ.S	.r
	ADDQ.W	#1,dbg_StopPbCnt
	MOVE.L	4(A7),dbg_StopPbRet	; ret from pt_StopPlayback (caller)
	MOVE.L	8(A7),dbg_StopPbRet2
	MOVE.L	dat_RpPatternPos,dbg_StopPbPat
.r:	CLR.L	dat_RpPlayMode
	RTS
	ENDC

; d0 = lead in smp (16.16) = mix_Spt * ticks (2, a500 mode 6)
; v1/2 follow via pt_Mix68DirectTick
pt_MixLeadSpt:
	MOVE.L	mix_Spt,D0
	ADD.L	D0,D0
	TST.B	mix68_Slow
	BEQ.S	.r
	MOVE.L	D0,-(A7)
	ADD.L	D0,D0
	ADD.L	(A7)+,D0
.r:	RTS

pt_MixStop:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	SF	mix_Active		; first, else softint could restart the ring between dma off and end
	SF	mix68_DOn		; restart via pt_MixRingRestart (task call, e.g. rate change)
	TST.B	ahi_NoPaula		; ahi owns paula -> reset state only
	BNE.W	.ahistop
	MOVE.L	#$00010002,dat_DiskOpViewMode	; back: smp in chip
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixStopCnt
	ENDC
	MOVEQ	#0,D0
	MOVE.B	mix_PairMask,D0
	MOVE.W	D0,DMACON		; dma of mixed ch off
	LEA	AUD0VOL,A0
	MOVEQ	#0,D2
.v:	BTST	D2,D0
	BEQ.S	.vn
	CLR.W	(A0)
.vn:	LEA	aud_SIZEOF(A0),A0
	ADDQ.W	#1,D2
	CMP.W	#4,D2
	BNE.S	.v
	BSR.W	pt_MixRestoreDirect
.ahistop:
	MOVE.L	#$00010002,dat_DiskOpViewMode	; smp in chip again (paula may come back)
	SF	mix68_DOn		; v1/2 direct again
	SF	mix_Active
	CLR.B	mix_PairMask
	CLR.W	mix_TicksDue
	BSR.W	pt_Mix68VolScale	; v1/2 full vol again
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; silence trick, hook in pt_StopAllAudio (replaces CLR.B dat_KeyCode):
; after dma off + vol 0 ch point to null smp (1 word), dma runs 4 lines
; so the output latch is 0 (no click at next note),
; mix mode: ring is silent itself, untouched
pt_StopSilence:
	CLR.B	dat_KeyCode
	CLR.B	dat_Channel5+n_volume
	CLR.B	dat_Channel5+1*n_SIZEOF+n_volume
	CLR.B	dat_Channel5+2*n_SIZEOF+n_volume
	CLR.B	dat_Channel5+3*n_SIZEOF+n_volume
	BSR.W	pt_Mix68DirectFlush	; v1/2 silent after stop
	BSR.W	pt_MixVoicesOff		; else looped smp keep ringing in the mix
	TST.B	mix_Active
	BNE.S	.r
	TST.B	ahi_NoPaula		; ahi owns paula
	BNE.S	.r
	MOVEM.L	D0-D1/A0-A1,-(A7)
	LEA	chip_SilentSample,A0
	LEA	AUD0LCH,A1
	MOVEQ	#3,D1
.set:	MOVE.L	A0,(A1)
	MOVE.W	#1,4(A1)		; len 1 word
	MOVE.W	#124,6(A1)		; short per
	LEA	aud_SIZEOF(A1),A1
	DBF	D1,.set
	MOVE.W	#$800f,DMACON
	MOVEQ	#3,D1
.w:	MOVE.B	$DFF006,D0
.w2:	CMP.B	$DFF006,D0
	BEQ.S	.w2
	DBF	D1,.w
	MOVE.W	#$000f,DMACON
	MOVEM.L	(A7)+,D0-D1/A0-A1
.r:	RTS

; all mixer voices off, shadow vols 0 (next note retriggers)
pt_MixVoicesOff:
	MOVEM.L	D0/A0,-(A7)
	LEA	mix_Voices,A0
	MOVEQ	#7,D0
.v:	SF	(mv_active,A0)
	CLR.W	(mv_vol,A0)
	LEA	mv_SIZEOF(A0),A0
	DBF	D0,.v
	LEA	mix_Shadow,A0
	MOVEQ	#7,D0
.s:	CLR.W	(aud_VOL,A0)
	LEA	aud_SIZEOF(A0),A0
	DBF	D0,.s
	MOVEM.L	(A7)+,D0/A0
	RTS

; mixer wanted? z=0 yes (8ch or ahi), z=1 no
pt_MixWanted:
	TST.B	ahi_Active
	BNE.S	.y
	CMPI.W	#8,dat_RpNumChannels
	BEQ.S	.y
	ORI	#4,CCR
	RTS
.y:	ANDI	#$fb,CCR
	RTS

; smp per tick (16.16): cia mode rate*(base/bpm)/ECLOCK, vblank rate/50
pt_MixCalcSpt:
	MOVEM.L	D0-D4,-(A7)
	MOVE.W	dat_CurrentTempo,mix_SptBpm
	MOVEQ	#0,D4
	BTST	#0,dat_ModeFlags
	BEQ.S	.vbl
	MOVEQ	#1,D4
	MOVE.L	dat_CIATimingBase,D0
	MOVEQ	#0,D1
	MOVE.W	dat_CurrentTempo,D1
	BNE.S	.bpmok
	MOVEQ	#125,D1
.bpmok:	BSR.W	pt_MixDiv32		; d0 = cia timer value
	MOVEQ	#0,D1
	MOVE.W	mix_Rate,D1
	BSR.W	pt_MixMul32		; d0 = rate*timer (< 2^31)
	MOVE.L	#ECLOCK,D1
	BSR.W	pt_MixDiv32		; d0 = int smp, d1 = rest
	MOVE.L	D0,D2
	SWAP	D2
	CLR.W	D2			; d2 = int<<16
	MOVE.L	D1,D0
	LSL.L	#8,D0
	MOVE.L	#ECLOCK,D1
	BSR.W	pt_MixDiv32		; d0 = frac hi (0..255), d1 rest
	LSL.W	#8,D0
	OR.W	D0,D2
	MOVE.L	D1,D0
	LSL.L	#8,D0
	MOVE.L	#ECLOCK,D1
	BSR.W	pt_MixDiv32
	OR.B	D0,D2
	MOVE.L	D2,mix_Spt
	BRA.S	.done
.vbl:	MOVEQ	#0,D0
	MOVE.W	mix_Rate,D0
	SWAP	D0			; rate<<16
	MOVEQ	#50,D1
	BSR.W	pt_MixDiv32
	MOVE.L	D0,mix_Spt
.done:	MOVE.W	D4,mix_SptMode
	MOVEM.L	(A7)+,D0-D4
	RTS

; d0 = d0*d1 (32x32 -> low 32, 68000)
pt_MixMul32:
	MOVEM.L	D2-D3,-(A7)
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	SWAP	D2
	SWAP	D3
	MULU	D1,D2			; hi(d0)*lo(d1)
	MULU	D0,D3			; lo(d0)*hi(d1)
	MULU	D1,D0			; lo*lo
	ADD.W	D3,D2
	SWAP	D2
	CLR.W	D2
	ADD.L	D2,D0
	MOVEM.L	(A7)+,D2-D3
	RTS

; softint (020+)
; mixes all due ticks, softint ctx (after hw irqs, before tasks)
	MC68020				; 020 insns from here (only reachable with mix_Enabled)
pt_MixTickSoft:
	MOVEM.L	D2-D7/A2-A6,-(A7)
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixSoftCnt
	IFND	NOBAR
	MOVE.W	#$0f00,COLOR00		; raster bar: mix time (red)
	ENDC
	MOVE.L	$DFF004,D0		; line at start (vhposr bits 8..0)
	LSR.L	#8,D0
	AND.L	#$1ff,D0
	MOVE.W	D0,dbg_MixLineStart
	ENDC
.again:	TST.W	mix_TicksDue
	BEQ.S	.done
	SUBQ.W	#1,mix_TicksDue
	TST.B	mix_Active
	BEQ.S	.done
	BSR.S	pt_MixOneTick
	TST.W	mix_TicksDue
	BEQ.S	.done
	ADDQ.W	#1,mix_Overrun
	BRA.S	.again
.done:	IFD	DEBUGFX
	IFND	NOBAR
	MOVE.W	#$0000,COLOR00
	ENDC
	MOVE.L	$DFF004,D0		; line at end -> lines per softint (mod 313), keep max
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

pt_MixOneTick:
	IFD	DEBUGFX
	; dump restarts at play start (mixer runs in 8ch also on stop)
	MOVE.L	dat_RpPlayMode,D0
	CMP.L	dbg_MixPlayPrev,D0
	BEQ.S	.samepm
	MOVE.L	D0,dbg_MixPlayPrev
	TST.L	D0
	BEQ.S	.samepm
	CLR.L	dbg_MixPos
.samepm:
	ENDC
	; ring dma off (pt_StopAllAudio)? -> restart all rings, not with ahi
	TST.B	ahi_Active
	BNE.S	.dmaok
	MOVE.W	DMACONR,D0
	MOVEQ	#0,D1
	MOVE.B	mix_PairMask,D1
	AND.W	D1,D0
	CMP.W	D1,D0
	BEQ.S	.dmaok
	BSR.W	pt_MixRingRestart
.dmaok:	; tempo changed?
	MOVE.W	dat_CurrentTempo,D0
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
.sptok:	; smp this tick
	MOVEQ	#0,D0
	MOVE.W	mix_WriteFrac,D0
	ADD.L	mix_Spt,D0
	MOVE.W	D0,mix_WriteFrac
	CLR.W	D0
	SWAP	D0			; d0 = smp cnt
	CMP.L	#MIX_TICKMAX,D0
	BLS.S	.nok
	MOVE.L	#MIX_TICKMAX,D0
.nok:	MOVE.L	D0,D7			; d7 = smp per ch (kept)
	MOVEQ	#0,D6			; d6 = pair idx
.pair:	BTST	D6,mix_PairMask
	BEQ.W	.pnext
	; update voices
	LEA	dat_Channel1,A6
	MOVE.W	D6,D0
	MULU	#n_SIZEOF,D0
	ADDA.L	D0,A6			; ch struct voice n
	LEA	mix_Voices,A5
	MOVE.W	D6,D0
	MULU	#mv_SIZEOF,D0
	ADDA.L	D0,A5			; mixer voice n
	LEA	mix_Shadow,A4
	MOVE.W	D6,D0
	LSL.W	#4,D0
	ADDA.L	D0,A4			; shadow n
	BSR.W	pt_MixUpdateVoice
	LEA	4*n_SIZEOF(A6),A6
	LEA	4*mv_SIZEOF(A5),A5
	LEA	4*aud_SIZEOF(A4),A4
	BSR.W	pt_MixUpdateVoice
	; mix: voice n (a5-4*mv) and n+4 (a5) -> mix_TickBuf
	LEA	-4*mv_SIZEOF(A5),A5
	LEA	4*mv_SIZEOF(A5),A6	; a6 = voice n+4 (mixer struct)
	LEA	mix_TickBuf,A0
	MOVE.L	D7,D0
	TST.B	(mv_active,A5)		; both silent -> zeros only
	BNE.S	.mix
	TST.B	(mv_active,A6)
	BNE.S	.mix
	MOVE.L	D0,D1
.zero:	CLR.B	(A0)+
	SUBQ.L	#1,D1
	BNE.S	.zero
	BRA.S	.mixed
.mix:	BSR.W	pt_MixPair
.mixed:
	IFD	DEBUGFX
	BSR.W	dbg_MixDump		; dbg: append tick buf of ch d6
	ENDC
	; copy to ring (wrapping)
	MOVEA.L	mix_Ring,A1
	MOVE.W	D6,D0
	MULU	#MIX_RING,D0
	ADDA.L	D0,A1			; ring of ch
	MOVE.L	mix_WriteInt,D1
	LEA	mix_TickBuf,A0
	MOVE.L	D7,D0
.cp:	MOVE.B	(A0)+,(A1,D1.L)
	ADDQ.L	#1,D1
	AND.L	#MIX_RING-1,D1
	SUBQ.L	#1,D0
	BNE.S	.cp
.pnext:	ADDQ.W	#1,D6
	CMP.W	#4,D6
	BNE.W	.pair
	; advance write pos
	MOVE.L	mix_WriteInt,D0
	ADD.L	D7,D0
	AND.L	#MIX_RING-1,D0
	MOVE.L	D0,mix_WriteInt
	IFD	DEBUGFX
	MOVE.L	dbg_MixPos,D0
	ADD.L	D7,D0
	CMP.L	#DBG_MIXCH,D0
	BHI.S	.dumpfull
	MOVE.L	D0,dbg_MixPos
.dumpfull:
	ENDC
	RTS

	IFD	DEBUGFX
; dbg dump: d7 smp mix_TickBuf -> dbg_MixBuf+d6*DBG_MIXCH+dbg_MixPos
dbg_MixDump:
	MOVEM.L	D0-D2/A0-A1,-(A7)
	MOVE.L	dbg_MixPos,D1
	MOVE.L	D1,D0
	ADD.L	D7,D0
	CMP.L	#DBG_MIXCH,D0
	BHI.S	.full
	MOVEA.L	dbg_MixBuf,A1
	MOVE.L	A1,D0
	BEQ.S	.full
	MOVE.W	D6,D0
	MULU	#DBG_MIXCH,D0
	ADDA.L	D0,A1
	ADDA.L	D1,A1
	LEA	mix_TickBuf,A0
	TST.B	mix_Is68k		; 68000: tick stored with ring pos parity
	BEQ.S	.np
	BTST	#0,mix_WriteInt+3
	BEQ.S	.np
	ADDQ.L	#1,A0
.np:	MOVE.L	D7,D0
.cp:	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D0
	BNE.S	.cp
.r:	MOVEM.L	(A7)+,D0-D2/A0-A1
	RTS
.full:	MOVEM.L	(A7)+,D0-D2/A0-A1
	RTS

; from dbg_FxFlush (task ctx): PT:mixdump.raw = 4 x dbg_MixPos b
dbg_MixFlush:
	MOVEM.L	D0-D4/A0-A1/A6,-(A7)
	MOVE.L	#dbg_MixStatName,D1
	MOVE.L	#1006,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,D4
	BEQ.W	.nostat
	MOVE.L	D4,D1
	MOVE.L	#dbg_MixSoftCnt,D2
	MOVEQ	#16,D3
	JSR	(-48,A6)		; SoftCnt, CauseCnt, StartCnt, StopCnt
	MOVE.L	D4,D1
	MOVE.L	#mix_Overrun,D2
	MOVEQ	#2,D3
	JSR	(-48,A6)
	MOVE.L	D4,D1
	MOVE.L	#dbg_MixPos,D2
	MOVEQ	#4,D3
	JSR	(-48,A6)
	MOVE.L	D4,D1
	MOVE.L	#dbg_MixInitCnt,D2
	MOVEQ	#4,D3
	JSR	(-48,A6)
	MOVE.L	D4,D1
	MOVE.L	#mix_Ring,D2
	MOVEQ	#4,D3
	JSR	(-48,A6)
	MOVE.L	D4,D1
	MOVE.L	#mix_PairMask,D2
	MOVEQ	#4,D3
	JSR	(-48,A6)		; PairMask, Active, Enabled, Init
	MOVE.L	D4,D1
	MOVE.L	#mix_Shadow+4*aud_SIZEOF,D2
	MOVEQ	#16,D3
	JSR	(-48,A6)		; shadow voice 5
	MOVE.L	D4,D1
	MOVE.L	#dat_Channel5,D2
	MOVEQ	#88,D3
	JSR	(-48,A6)		; ch struct voice 5
	MOVE.L	D4,D1
	MOVE.L	#mix_Voices+4*mv_SIZEOF,D2
	MOVEQ	#mv_SIZEOF,D3
	JSR	(-48,A6)		; mixer voice 5
	MOVE.L	D4,D1
	MOVE.L	#dat_RpDmaChanMask,D2
	MOVEQ	#2,D3
	JSR	(-48,A6)
	MOVE.L	D4,D1
	MOVE.L	#dat_CpuBench,D2
	MOVEQ	#4,D3
	JSR	(-48,A6)
	MOVE.L	D4,D1
	JSR	(-36,A6)
.nostat:
	MOVE.L	dbg_MixPos,D0
	BEQ.S	.r
	TST.L	dbg_MixBuf
	BEQ.S	.r
	MOVE.L	#dbg_MixName,D1
	MOVE.L	#1006,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,D4
	BEQ.S	.r
	MOVEA.L	dbg_MixBuf,A0
	MOVEQ	#3,D2
.ch:	MOVE.L	D4,D1
	MOVE.L	A0,D2
	MOVE.L	dbg_MixPos,D3
	MOVE.L	A0,-(A7)
	JSR	(-48,A6)
	MOVEA.L	(A7)+,A0
	ADDA.L	#DBG_MIXCH,A0		; 68000 safe (lea with dist > 32767 = 020 form)
	SUBQ.W	#1,dbg_MixChCnt
	BNE.S	.ch
	MOVE.W	#4,dbg_MixChCnt
	MOVE.L	D4,D1
	JSR	(-36,A6)
	CLR.L	dbg_MixPos
.r:	MOVEM.L	(A7)+,D0-D4/A0-A1/A6
	RTS
dbg_MixName:	DC.B	"PT:mixdump.raw",0
dbg_MixStatName:	DC.B	"PT:mixstat.bin",0
	EVEN
dbg_MixChCnt:	DC.W	4
	ENDC

; guard ring ch (per tick, pt_MixTickExit): pt code outside replayer
; write AUDxVOL from ch struct and may reset masks/INTENA of ch1-4
; mixed pairs: paula vol 64 (mixer scales), audio INTENA off, masks 0
pt_MixGuardRing:
	TST.B	ahi_NoPaula		; ahi owns paula
	BEQ.S	.own
	RTS
.own:	MOVEM.L	D0-D2/A0-A1,-(A7)
	MOVEQ	#0,D2
	MOVE.B	mix_PairMask,D2
	BEQ.S	.r
	MOVE.W	D2,D0
	LSL.W	#7,D0
	MOVE.W	D0,INTENA		; ring ch audio irq off (bit n -> INTB_AUD0+n)
	LEA	AUD0VOL,A1
	LEA	dat_Channel1,A0
	MOVEQ	#0,D1
.ch:	BTST	D1,D2
	BEQ.S	.n
	MOVE.W	#64,D0
	TST.B	ahi_Active		; ahi output: paula mute
	BEQ.S	.gv
	MOVEQ	#0,D0
.gv:	MOVE.W	D0,(A1)
	CLR.W	(n_pt4_dmacon,A0)
	CLR.W	(n_pt4_dmaset,A0)
	CLR.W	(n_pt4_intmask,A0)
	CLR.W	(n_pt4_intena,A0)
.n:	LEA	aud_SIZEOF(A1),A1
	LEA	n_SIZEOF(A0),A0
	ADDQ.W	#1,D1
	CMP.W	#4,D1
	BNE.S	.ch
.r:	MOVEM.L	(A7)+,D0-D2/A0-A1
	RTS

; restart rings (after pt_StopAllAudio): clear, paula ch -> ring,
; lead, dma on; softint ctx, no os calls
pt_MixRingRestart:
	TST.B	ahi_NoPaula		; ahi owns paula: never program it (window while switching back)
	BNE.W	.nopaula
	MOVEM.L	D0-D4/A0-A3,-(A7)
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_MixRestartCnt
	ENDC
	JSR	pt_MixRingClear		; 68000: rings of ch 2/3 only
	BSR.W	pt_MixLeadSpt		; lead (2 ticks, a500 mode 6)
	SWAP	D0
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	; restart runs in softint = late by softint delay after replayer tick;
	; paula reads ring from now -> cut lead by elapsed time (lines since
	; newest tick + open ticks), else mixed voices stay late
	MOVE.L	$DFF004,D0
	LSR.L	#8,D0
	AND.W	#$1ff,D0
	SUB.W	mix_TickLine,D0
	BPL.S	.lpos
	ADD.W	#313,D0
.lpos:	MULU	mix_Rate,D0
	DIVU	#15625,D0		; lines -> smp (pal: 15625 lines/s)
	AND.L	#$ffff,D0
	MOVE.L	mix_Spt,D2
	SWAP	D2
	AND.L	#$ffff,D2		; smp per tick
	MOVE.W	mix_TicksDue,D3
	BRA.S	.tde
.td:	ADD.L	D2,D0
.tde:	DBF	D3,.td
	SUB.L	D0,D1
	CMP.L	D2,D1			; at least one tick lead
	BGE.S	.lok
	MOVE.L	D2,D1
.lok:	MOVE.L	D1,mix_WriteInt
	IFD	DEBUGFX
	JSR	dbg75_Start		; dbg: ring time base
	ENDC
	CLR.W	mix_WriteFrac
	MOVE.B	mix_PairMask,D3
	MOVEQ	#0,D2
	LEA	AUD0LCH,A3
	MOVEQ	#0,D4
.pair:	BTST	D2,D3
	BEQ.S	.next
	MOVE.L	mix_Ring,D0
	MOVE.W	D2,D1
	MULU	#MIX_RING,D1
	ADD.L	D1,D0
	MOVE.L	D0,(A3)
	MOVE.W	#MIX_RING/2,(aud_LEN,A3)
	MOVE.W	mix_Period,(aud_PER,A3)
	MOVE.W	#64,(aud_VOL,A3)
	BSET	D2,D4
.next:	LEA	aud_SIZEOF(A3),A3
	ADDQ.W	#1,D2
	CMP.W	#4,D2
	BNE.S	.pair
	MOVE.W	D4,D0
	LSL.W	#7,D0
	MOVE.W	D0,INTENA
	MOVE.W	D0,INTREQ
	OR.W	#$8000,D4
	MOVE.W	D4,DMACON
	MOVEM.L	(A7)+,D0-D4/A0-A3
.nopaula:
	RTS

; editor play (replaces moveq/lea/lea in pt_EdPlayStart):
; track from dat_CursorColumn (6 col each, note col only); a4=ch struct
; a5=paula/shadow (mix_AudPtrTable) d7=col d0=0 -> orig loop ends
pt_MixEdPlayInit:
	; d1.b = chunk flag of caller (SNE) untouched, only d0/d7/a4/a5 change
	MOVEM.L	D2-D3,-(A7)
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVE.W	dat_CursorColumn,D2
	MOVE.W	D2,D7
	DIVU	#6,D2			; d2.w = track, high word = rest
	MOVE.L	D2,D3
	SWAP	D3
	TST.W	D3			; rest <> 0: not note col -> no hit
	BEQ.S	.col
	MOVEQ	#-6,D7
.col:	AND.W	#7,D2			; track 0-7
	TST.B	mix_Init
	BNE.S	.tab
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_MixInitOnce
	MOVEM.L	(A7)+,D0-D7/A0-A6
.tab:	LEA	dat_Channel1,A4
	MOVE.W	D2,D3
	MULU	#n_SIZEOF,D3
	ADDA.L	D3,A4
	CMP.W	#4,D2
	BLO.S	.vol
	MOVE.W	dat_RpMasterVol,(n_pt4_volscale,A4)	; trk 5-8: scale also on stop (pt_MixLoopInit not running)
	BTST	D2,dat_RpDmaChanMask+1	; ch off (TRK#nOFF)? -> mute
	BNE.S	.vol
	CLR.W	(n_pt4_volscale,A4)
.vol:	LEA	mix_AudPtrTable,A5
	ADD.W	D2,D2
	ADD.W	D2,D2
	MOVEA.L	(A5,D2.W),A5
	MOVEM.L	(A7)+,D2-D3
	RTS

; take voice (a5=mv a6=ch struct a4=shadow) from replayer state
; note start: pt_RpStartDma/Chunked set shadow AUDxPER = 1, n_pt4_dmawait;
; direct path: audio irq then sets per/vol, here the mixer does
pt_MixUpdateVoice:
	MOVEQ	#0,D2			; d2 = trigger
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
	MOVE.L	#PAULA_CLOCK,D0
	DIVU.L	D1,D0			; voice rate (020+)
	LSL.L	#8,D0
	LSL.L	#8,D0
	MOVEQ	#0,D1
	MOVE.W	mix_Rate,D1
	DIVU.L	D1,D0
	MOVE.L	D0,(mv_step,A5)
.ret:	RTS

; two voices (a5, a6 = mv) -> d0 smp to (a0), 020+
pt_MixPair:
	MOVEM.L	D0-D7/A1-A6,-(A7)
	MOVE.L	D0,D7			; rest
.seg:	MOVE.L	D7,D6
	MOVEA.L	A5,A1
	BSR.W	pt_MixVoiceAvail
	CMP.L	D0,D6
	BLS.S	.a
	MOVE.L	D0,D6
.a:	MOVEA.L	A6,A1
	BSR.W	pt_MixVoiceAvail
	CMP.L	D0,D6
	BLS.S	.b
	MOVE.L	D0,D6
.b:	TST.L	D6
	BLE.W	.wrap
	; prepare window/tabs
	MOVEA.L	A5,A1
	BSR.W	pt_MixVoiceWindow	; a2 = base+32768, d0 = pos16 (bit 31 flipped), d1 = step, a3 = tab
	MOVEA.L	A2,A1
	MOVE.L	D0,D2
	MOVE.L	D1,D3
	MOVEA.L	A3,A4
	MOVE.L	A1,-(A7)
	MOVE.L	D2,-(A7)
	MOVEA.L	A6,A1
	BSR.W	pt_MixVoiceWindow
	MOVE.L	D1,D5			; step B
	MOVE.L	D0,D4			; pos B
	MOVEA.L	A2,A1			; base B
	MOVE.L	(A7)+,D2		; pos A
	MOVEA.L	(A7)+,A2		; base A
	; regs: a2/d2/d3 voice A (base, pos, step), a1/d4/d5 B, a4 tab A, a3 tab B
	EXG	A1,A2			; a1 = base A, a2 = base B
	MOVE.L	D6,D0
	SUBQ.L	#1,D0
	SUB.L	D6,D7
	MOVEM.L	D6-D7,-(A7)
	MOVEQ	#0,D6
	MOVEQ	#0,D7
.inner:	SWAP	D2
	MOVE.B	(A1,D2.W),D6
	SWAP	D2
	MOVE.B	(A4,D6.W),D7
	SWAP	D4
	MOVE.B	(A2,D4.W),D6
	SWAP	D4
	ADD.B	(A3,D6.W),D7
	MOVE.B	D7,(A0)+
	ADD.L	D3,D2
	ADD.L	D5,D4
	DBF	D0,.inner
	MOVEM.L	(A7)+,D6-D7
	; write back pos
	MOVEA.L	A5,A1
	MOVE.L	D2,D0
	BSR.W	pt_MixVoiceStore
	MOVEA.L	A6,A1
	MOVE.L	D4,D0
	BSR.W	pt_MixVoiceStore
.wrap:	MOVEA.L	A5,A1
	BSR.W	pt_MixVoiceWrap
	MOVEA.L	A6,A1
	BSR.W	pt_MixVoiceWrap
	TST.L	D7
	BGT.W	.seg
	MOVEM.L	(A7)+,D0-D7/A1-A6
	RTS

; d0 = smp voice (a1) delivers w/o phase/window change (huge if silent)
pt_MixVoiceAvail:
	TST.B	(mv_active,A1)
	BEQ.S	.inf
	MOVE.L	(mv_step,A1),D1
	BEQ.S	.inf
	TST.B	(mv_back,A1)
	BNE.S	.back
	MOVE.L	(mv_end,A1),D0
	SUB.L	(mv_pos,A1),D0		; bytes to phase end
	BLE.S	.one
	MOVE.L	(mv_pos,A1),D2
	AND.L	#$7fff,D2
	NEG.L	D2
	ADD.L	#$8000,D2		; bytes to window end
	CMP.L	D2,D0
	BLS.S	.lim
	MOVE.L	D2,D0
.lim:	; smp = ceil((d0<<16 - frac) / step)
	SWAP	D0
	CLR.W	D0
	MOVEQ	#0,D2
	MOVE.W	(mv_frac,A1),D2
	SUB.L	D2,D0
	BLS.S	.one
	ADD.L	D1,D0
	SUBQ.L	#1,D0
	DIVU.L	D1,D0
	BNE.S	.r
.one:	MOVEQ	#1,D0
.r:	RTS
.inf:	MOVE.L	#$7fffffff,D0
	RTS
.back:	; backwards: bytes to phase start (mv_loopstart) and window start
	MOVE.L	(mv_pos,A1),D0
	SUB.L	(mv_loopstart,A1),D0
	BLE.S	.one
	MOVE.L	(mv_pos,A1),D2
	SUBQ.L	#1,D2
	AND.L	#$7fff,D2
	ADDQ.L	#1,D2			; bytes to window start (backwards: (pos-1) & ~$7fff, 1..32768)
	CMP.L	D2,D0
	BLS.S	.blim
	MOVE.L	D2,D0
.blim:	; smp = ceil((d0<<16 + frac) / step), pos falls by step per smp
	SWAP	D0
	CLR.W	D0
	MOVEQ	#0,D2
	MOVE.W	(mv_frac,A1),D2
	ADD.L	D2,D0
	ADD.L	D1,D0
	SUBQ.L	#1,D0
	DIVU.L	D1,D0
	BNE.S	.r
	BRA.S	.one

; inner loop window: a2 = (pos & ~$7fff)+32768, d1 = step, a3 = vol tab,
; d0 = ((pos & $7fff)<<16 | frac) ^ $80000000; silent -> step 0
pt_MixVoiceWindow:
	TST.B	(mv_active,A1)
	BEQ.S	.sil
	MOVE.L	(mv_pos,A1),D0
	MOVE.L	D0,D1
	AND.L	#$ffff8000,D1
	ADD.L	#32768,D1
	MOVEA.L	D1,A2
	AND.L	#$7fff,D0
	SWAP	D0
	MOVE.W	(mv_frac,A1),D0
	BCHG	#31,D0
	MOVE.L	(mv_step,A1),D1
	TST.B	(mv_back,A1)
	BEQ.S	.tab
	NEG.L	D1			; backwards: negative step
	; pos at window top: base = (pos-1) & ~$7fff, ofs 1..32768
	MOVE.L	(mv_pos,A1),D0
	SUBQ.L	#1,D0
	MOVE.L	D0,D2
	AND.L	#$ffff8000,D2
	ADD.L	#32768,D2
	MOVEA.L	D2,A2
	AND.L	#$7fff,D0
	ADDQ.L	#1,D0
	SWAP	D0
	MOVE.W	(mv_frac,A1),D0
	BCHG	#31,D0
	BRA.S	.tab
.sil:	LEA	mix_Silence+32768,A2
	MOVE.L	#$80000000,D0
	MOVEQ	#0,D1
.tab:	X20LEA	X20_VOLTAB,A3
	MOVE.W	(mv_vol,A1),D2
	LSL.W	#8,D2
	ADDA.W	D2,A3
	RTS

; write back pos from d0 (window form) to voice (a1)
pt_MixVoiceStore:
	TST.B	(mv_active,A1)
	BEQ.S	.r
	BCHG	#31,D0
	MOVE.W	D0,(mv_frac,A1)
	CLR.W	D0
	SWAP	D0			; ofs in window (may reach $8000)
	MOVE.L	(mv_pos,A1),D1
	AND.L	#$ffff8000,D1
	ADD.L	D1,D0
	MOVE.L	D0,(mv_pos,A1)
.r:	RTS

; phase end: loop or stop
pt_MixVoiceWrap:
	TST.B	(mv_active,A1)
	BEQ.S	.r
	TST.B	(mv_back,A1)
	BNE.S	.back
	MOVE.L	(mv_pos,A1),D0
	CMP.L	(mv_end,A1),D0
	BCS.S	.r
	MOVE.L	(mv_looplen,A1),D1
	BEQ.S	.stop
	SUB.L	(mv_end,A1),D0		; overshoot
	CMP.L	D1,D0
	BCS.S	.ov
	MOVEQ	#0,D0
.ov:	ADD.L	(mv_loopstart,A1),D0
	MOVE.L	D0,(mv_pos,A1)
	MOVE.L	(mv_loopstart,A1),D0
	ADD.L	D1,D0
	MOVE.L	D0,(mv_end,A1)
	RTS
.stop:	SF	(mv_active,A1)
.r:	RTS
.back:	; backwards: below phase start? loop -> to phase end, else voice off
	MOVE.L	(mv_pos,A1),D0
	CMP.L	(mv_loopstart,A1),D0
	BCC.S	.r
	MOVE.L	(mv_looplen,A1),D1
	BEQ.S	.stop
	MOVE.L	(mv_loopstart,A1),D2
	SUB.L	D0,D2			; undershoot
	CMP.L	D1,D2
	BCS.S	.bov
	MOVEQ	#0,D2
.bov:	MOVE.L	(mv_loopstart,A1),D0
	ADD.L	D1,D0
	MOVE.L	D0,(mv_end,A1)
	SUB.L	D2,D0
	SUBQ.L	#1,D0
	MOVE.L	D0,(mv_pos,A1)
	RTS
	MC68000				; end of 020 part

	IFD	DEBUGAUTO
; watchdog (dbg)
; cia ticks since last driver cmd (reset in dispatcher), 500 -> queue
; line, shown by pt_MixTaskPoll in task
dbg_Watchdog:
	TST.B	dbg_AutoDone		; script done -> no watchdog
	BNE.W	.r
	IFD	NOBAR
	BRA.W	.r			; photo build: no watchdog line
	ENDC
	CMPI.B	#2,dbg_WdDone		; queued, task hung -> draw from irq after 250 more ticks
	BNE.S	.count
	ADDQ.W	#1,dbg_WdTicks
	CMPI.W	#750,dbg_WdTicks
	BNE.W	.r
	MOVE.B	#1,dbg_WdDone
	LEA	dbg_WdText,A0
	JSR	pt_ShowStatusMsg	; emergency only: pt_ShowStatusMsg not reentrant, task stalled anyway
	BRA.W	.r
.count:	TST.B	dbg_WdDone
	BNE.W	.r
	ADDQ.W	#1,dbg_WdTicks
	CMPI.W	#500,dbg_WdTicks
	BNE.W	.r
	MOVE.L	#pt_Hunk0Start,D5	; hunk 0 load addr
	LEA	dbg_WdText,A0
	MOVE.B	#"W",(A0)+
	MOVE.B	#"D",(A0)+
	MOVE.B	#" ",(A0)+
	MOVE.B	#"U",(A0)+		; ret addrs (hunk 0 ofs) on user stack: where the task sits
	MOVE	USP,A1
	MOVEQ	#3,D6
	BSR.W	dbg_WdScan
	MOVE.B	#"E",(A0)+
	JSR	dbg_ReadEClockLo
	MOVE.L	D0,D2
	BSR.W	dbg_WdHex8
	MOVE.B	#" ",(A0)+
	MOVE.B	#"T",(A0)+
	MOVE.L	dbg_AutoEclkTarget,D2
	BSR.W	dbg_WdHex8
	MOVE.B	#" ",(A0)+
	MOVE.B	#"I",(A0)+
	MOVEQ	#0,D2
	MOVE.W	INTENAR,D2
	SWAP	D2
	MOVEQ	#3,D4
	BSR.S	dbg_WdHexN
	CLR.B	(A0)
	MOVE.B	#2,dbg_WdDone		; show in task, not irq (pt_ShowStatusMsg not reentrant)
.r:	RTS
; a1 = stack, d6 = hits; scan 128 longs, hit -> hunk 0 ofs (6 hex)
dbg_WdScan:
	MOVE.W	#127,D3
.l:	MOVE.L	(A1)+,D2
	SUB.L	D5,D2
	CMP.L	#$40000,D2
	BCC.S	.n
	ROL.L	#8,D2			; skip top byte (0)
	MOVEQ	#5,D4
	BSR.S	dbg_WdHexN
	MOVE.B	#" ",(A0)+
	SUBQ.W	#1,D6
	BEQ.S	.x
.n:	DBF	D3,.l
.x:	RTS
dbg_WdHex8:
	MOVEQ	#7,D4
dbg_WdHexN:				; d4+1 hex digits of d2 (from left) -> (a0)+
.h:	ROL.L	#4,D2
	MOVE.B	D2,D0
	AND.B	#$0f,D0
	ADD.B	#"0",D0
	CMP.B	#"9",D0
	BLS.S	.d
	ADDQ.B	#7,D0
.d:	MOVE.B	D0,(A0)+
	DBF	D4,.h
	RTS
	ENDC

; clear rings: 020 all four, 68000 only ch 2/3 (only those exist)
pt_MixRingClear:
	MOVEM.L	D0/A0,-(A7)
	MOVEA.L	mix_Ring,A0
	MOVE.W	#4*MIX_RING/4-1,D0
	TST.B	mix_Is68k
	BEQ.S	.c
	LEA	2*MIX_RING(A0),A0
	MOVE.W	#2*MIX_RING/4-1,D0
.c:	CLR.L	(A0)+
	DBF	D0,.c
	MOVEM.L	(A7)+,D0/A0
	RTS
