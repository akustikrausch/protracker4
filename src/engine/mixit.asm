; mix it: offline render for 8ch mode / without mod2smp

MIXIT_MAX	EQU	131070		; max smp len in bytes

; hook in pt_BtnM2sMixIt: replaces btst/beq (12 b)
; render needs 68020, else msg + return before saving
pt_MixItCheck:
	MOVEM.L	D0-D3/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	BTST	#1,(297,A6)		; AFB_68020
	BNE.S	.ok
	BTST	#5,dat_ModeFlags
	BEQ.S	.no			; 8ch on 68000
	MOVE.L	#mixit_LibName,D1
	MOVEQ	#-2,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-84,A6)		; Lock
	TST.L	D0
	BEQ.S	.no
	MOVE.L	D0,D1
	JSR	(-90,A6)		; UnLock
.ok:	MOVEM.L	(A7)+,D0-D3/A0-A1/A6
	RTS
.no:	LEA	mixit_Msg020(PC),A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#75,D1
	JSR	(-198,A6)		; Delay 1.5s, pt overwrites status line after the button
	MOVEM.L	(A7)+,D0-D3/A0-A1/A6
	ADDQ.L	#4,A7			; abort mixit
	RTS

; hook: replaces Execute call (10 b), d1=cmdline d2=nil:
pt_MixItExec:
	BTST	#5,dat_ModeFlags	; bit5 = 4ch
	BEQ.S	.own			; 8ch: render
	MOVEM.L	D1-D3,-(A7)
	MOVE.L	#mixit_LibName,D1
	MOVEQ	#-2,D2			; ACCESS_READ
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-84,A6)		; Lock
	MOVEM.L	(A7)+,D1-D3
	TST.L	D0
	BEQ.S	.own			; no mod2smp -> render
	MOVEM.L	D1-D3,-(A7)
	MOVE.L	D0,D1
	JSR	(-90,A6)		; UnLock
	MOVEM.L	(A7)+,D1-D3
	JMP	(-222,A6)		; Execute as orig
.own:	BSR.W	pt_MixItRender
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#-1,D0
	RTS

; hook in pt_UpdateSampleDisp: dat_0AC6 is odd -> byte writes only
pt_MixItFixArg:
	MOVE.B	#$20,dat_0AC6
	MOVE.B	#$2d,dat_0AC6+1
	RTS

	MC68020				; 020 insns only after attn check
pt_MixItRender:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	BTST	#1,(297,A6)		; AttnFlags low byte
	BEQ.W	.no020
	MOVE.L	#MIXIT_MAX*2,D0
	MOVE.L	#$10001,D1		; MEMF_PUBLIC|MEMF_CLEAR
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,mixit_Buf
	BEQ.W	.nomem
	; save state
	MOVE.W	mix_Rate,mixit_SaveRate
	MOVE.W	dat_CurrentTempo,mixit_SaveTempo
	MOVE.L	dat_RpSpeed,mixit_SaveSpeed
	MOVE.L	dat_PatTableIdx,mixit_SavePat
	MOVE.L	dat_RpPatternPos,mixit_SavePos
	MOVE.L	dat_RpSongPos,mixit_SaveSong
	; stop irq replayer + mixer
	ST	mix_Offline
	CLR.L	dat_RpPlayMode
	TST.B	mix_Active
	BEQ.S	.na
	JSR	pt_MixStop
.na:	MOVE.W	#$000f,DMACON		; paula off, render in mem only
	LEA	AUD0VOL,A0
	MOVEQ	#3,D0
.av:	CLR.W	(A0)
	LEA	aud_SIZEOF(A0),A0
	DBF	D0,.av
	MOVE.W	#$0780,INTENA		; audio irq off + ack, else irq storm
	MOVE.W	#$0780,INTREQ
	; 8 voices -> shadow regs, paula masks ch1-4 off
	LEA	dat_Channel1,A0
	LEA	mix_AudPtrTable,A1
	LEA	mix_Shadow,A2
	MOVEQ	#3,D0
.rt:	CLR.W	(n_pt4_dmacon,A0)
	CLR.W	(n_pt4_dmaset,A0)
	CLR.W	(n_pt4_intmask,A0)
	CLR.W	(n_pt4_intena,A0)
	CLR.B	(n_pt4_chunked,A0)	; no chunked play offline
	MOVE.L	A2,(A1)+
	LEA	n_SIZEOF(A0),A0
	LEA	aud_SIZEOF(A2),A2
	DBF	D0,.rt
	LEA	mix_Shadow,A0
	MOVEQ	#8*aud_SIZEOF/4-1,D0
.cs:	CLR.L	(A0)+
	DBF	D0,.cs
	LEA	mix_Voices,A0
	MOVEQ	#8*mv_SIZEOF/4-1,D0
.cv:	CLR.L	(A0)+
	DBF	D0,.cv
	MOVEQ	#0,D0
	MOVE.W	dat_BorderConfig1,D0
	CMP.W	#35,D0
	BLS.S	.nok
	MOVEQ	#24,D0			; c-3
.nok:	ADD.W	D0,D0
	LEA	dat_PeriodTable,A0
	MOVEQ	#0,D1
	MOVE.W	(A0,D0.W),D1
	MOVE.L	#PAULA_CLOCK,D0
	DIVU.L	D1,D0
	MOVE.W	D0,mix_Rate
	MOVE.L	D0,mixit_Rate
	; play pat from start row
	MOVE.W	dat_SampleDispTempo,dat_CurrentTempo
	MOVEQ	#0,D0
	MOVE.B	dat_ScreenModeFlag2,D0
	MOVE.L	D0,dat_PatTableIdx
	MOVE.W	dat_RpNumChannels,D1
	LSL.W	#2,D1			; bytes per row
	MOVE.W	D1,mixit_RowSize
	MOVEQ	#0,D0
	MOVE.W	dat_SampleNumCur,D0
	MULU	D1,D0
	MOVE.L	D0,dat_RpPatternPos
	CLR.B	dat_PattDelayCount
	CLR.B	dat_PattDelayTime
	CLR.B	dat_PosJumpFlag
	CLR.B	dat_RpPBreakFlag
	CLR.B	dat_RpBreakRow
	CLR.W	dat_StopRequest
	MOVE.L	dat_RpSpeed,D0
	SUBQ.L	#1,D0			; first call starts start row
	MOVE.L	D0,dat_RpCounter
	MOVE.L	#$70617474,dat_RpPlayMode	; 'patt'
	MOVEA.L	mixit_Buf,A3		; word sums
	MOVEQ	#0,D6			; smp cnt
	MOVEQ	#0,D5			; tick remainder
	MOVEQ	#-1,D4			; last started row
.tick:	; row start? check end row, jump back -> done
	MOVE.L	dat_RpCounter,D0
	ADDQ.L	#1,D0
	CMP.L	dat_RpSpeed,D0
	BCS.S	.norow
	TST.B	dat_PattDelayCount
	BNE.S	.norow			; pattern delay repeats row
	MOVE.L	dat_RpPatternPos,D0
	DIVU	mixit_RowSize,D0
	AND.L	#$ffff,D0
	CMP.W	dat_SampleNumMax,D0
	BHI.W	.done
	CMP.W	D4,D0
	BLT.W	.done			; wrap/jump back (d4=-1 at start)
	MOVE.W	D0,D4
.norow:	ST	mix_OffCall
	JSR	pt_RpMusic
	SF	mix_OffCall
	TST.L	dat_RpPlayMode
	BEQ.W	.done			; F00
	; smp per tick: rate*2.5/bpm in cia mode, else rate/50
	MOVE.L	mixit_Rate,D0
	MOVEQ	#50,D2
	BTST	#0,dat_ModeFlags
	BEQ.S	.vbl
	MULU.L	#5,D0
	MOVEQ	#0,D2
	MOVE.W	dat_CurrentTempo,D2
	BNE.S	.bpm
	MOVEQ	#125,D2
.bpm:	ADD.L	D2,D2
.vbl:	ADD.L	D5,D0
	DIVUL.L	D2,D5:D0		; d0=smp d5=rest
	MOVE.L	#MIXIT_MAX,D1
	SUB.L	D6,D1
	CMP.L	D1,D0
	BLS.S	.room
	MOVE.L	D1,D0
.room:	CMP.L	#MIX_TICKMAX,D0
	BLS.S	.tmax
	MOVE.L	#MIX_TICKMAX,D0
.tmax:	TST.L	D0
	BEQ.W	.done
	MOVE.L	D0,D7
	BSR.W	pt_MixItTick		; d7 smp -> (a3)
	ADD.L	D7,D6
	LEA	(A3,D7.L*2),A3
	CMP.L	#MIXIT_MAX,D6
	BCS.W	.tick
.done:	CLR.L	dat_RpPlayMode
	SF	mix_OffCall
	; normalize: peak -> 127, words -> bytes (fwd, dst never past src)
	BCLR	#0,D6			; even len
	MOVEA.L	mixit_Buf,A0
	MOVE.L	D6,D0
	MOVEQ	#1,D1			; peak, min 1
	BRA.S	.pk2
.pk:	MOVE.W	(A0)+,D2
	BPL.S	.pp
	NEG.W	D2
.pp:	CMP.W	D1,D2
	BLS.S	.pk2
	MOVE.W	D2,D1
.pk2:	SUBQ.L	#1,D0
	BPL.S	.pk
	MOVE.L	#127<<16,D3
	DIVU.L	D1,D3			; factor 16.16
	MOVEA.L	mixit_Buf,A0
	MOVEA.L	A0,A1
	MOVE.L	D6,D0
	BRA.S	.cv2
.cvt:	MOVE.W	(A0)+,D2
	EXT.L	D2
	MULS.L	D3,D2
	SWAP	D2
	MOVE.B	D2,(A1)+
.cv2:	SUBQ.L	#1,D0
	BPL.S	.cvt
	IFD	DEBUGAUTO
	MOVE.L	#mixit_DbgName,D1
	BSR.W	pt_MixItWrite
	ENDC
	MOVE.L	#str_TempSampleFile,D1	; "T:tsample"
	BSR.W	pt_MixItWrite
	; restore state
	JSR	pt_MixRestoreDirect
	LEA	mix_Voices,A0
	MOVEQ	#8*mv_SIZEOF/4-1,D0
.cv3:	CLR.L	(A0)+
	DBF	D0,.cv3
	MOVE.W	mixit_SaveRate,mix_Rate
	MOVE.W	mixit_SaveTempo,dat_CurrentTempo
	MOVE.L	mixit_SaveSpeed,dat_RpSpeed
	MOVE.L	mixit_SavePat,dat_PatTableIdx
	MOVE.L	mixit_SavePos,dat_RpPatternPos
	MOVE.L	mixit_SaveSong,dat_RpSongPos
	CLR.L	dat_RpCounter
	SF	mix_Offline
	JSR	pt_SetTempo		; cia timer back to song tempo, fxx may have changed it
	MOVEA.L	mixit_Buf,A1
	MOVE.L	#MIXIT_MAX*2,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	CLR.L	mixit_Buf
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
.no020:	LEA	mixit_Msg020(PC),A0
	BRA.S	.msg
.nomem:	LEA	mixit_MsgMem(PC),A0
.msg:	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; d7=smp: pairs n/n+4 mix (2x half vol), add to (a3)
pt_MixItTick:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEQ	#0,D6			; pair
.pair:	LEA	dat_Channel1,A6
	MOVE.W	D6,D0
	MULU	#n_SIZEOF,D0
	ADDA.L	D0,A6
	LEA	mix_Voices,A5
	MOVE.W	D6,D0
	MULU	#mv_SIZEOF,D0
	ADDA.L	D0,A5
	LEA	mix_Shadow,A4
	MOVE.W	D6,D0
	LSL.W	#4,D0
	ADDA.L	D0,A4
	MOVEM.L	D6-D7/A3,-(A7)
	JSR	pt_MixUpdateVoice
	LEA	4*n_SIZEOF(A6),A6
	LEA	4*mv_SIZEOF(A5),A5
	LEA	4*aud_SIZEOF(A4),A4
	JSR	pt_MixUpdateVoice
	MOVEM.L	(A7)+,D6-D7/A3
	LEA	-4*mv_SIZEOF(A5),A5
	LEA	4*mv_SIZEOF(A5),A6
	TST.B	(mv_active,A5)
	BNE.S	.mix
	TST.B	(mv_active,A6)
	BEQ.S	.next
.mix:	LEA	mix_TickBuf,A0
	MOVE.L	D7,D0
	JSR	pt_MixPair
	LEA	mix_TickBuf,A0
	MOVEA.L	A3,A1
	MOVE.L	D7,D0
	BRA.S	.a2
.add:	MOVE.B	(A0)+,D1
	EXT.W	D1
	ADD.W	D1,(A1)+
.a2:	SUBQ.L	#1,D0
	BPL.S	.add
.next:	ADDQ.W	#1,D6
	CMP.W	#4,D6
	BNE.W	.pair
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

	MC68000				; end of 020 part

; write mixit_Buf (d6 b) to file d1
pt_MixItWrite:
	MOVEM.L	D0-D4/A0-A1/A6,-(A7)
	MOVE.L	#1006,D2		; MODE_NEWFILE
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)		; Open
	MOVE.L	D0,D4
	BEQ.S	.r
	MOVE.L	D4,D1
	MOVE.L	mixit_Buf,D2
	MOVE.L	D6,D3
	JSR	(-48,A6)		; Write
	MOVE.L	D4,D1
	JSR	(-36,A6)		; Close
.r:	MOVEM.L	(A7)+,D0-D4/A0-A1/A6
	RTS

mixit_Msg020:	DC.B	"MIX IT: 68020 NEEDED",0
mixit_MsgMem:	DC.B	"MIX IT: OUT OF MEMORY",0
mixit_LibName:	DC.B	"LIBS:mod2smp.library",0
	IFD	DEBUGAUTO
mixit_DbgName:	DC.B	"PT:S/mixit.raw",0
	ENDC
	EVEN
