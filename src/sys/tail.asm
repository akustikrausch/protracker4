; hunk 0 tail: debug drivers, helpers
dat_RpDmaWaitCount:	; pt_RpDmaWait loop count
	DS.W	1
dat_RpNumChannels:	; 4/6/8, row = 4*n bytes
	DS.W	1
dat_RowDataVar:
	DS.W	1

; d4 = long at (a0,d3.w), read bytewise (odd addr)
pt_PeekLong:
	MOVE.L	A1,-(A7)
	LEA	(0,A0,D3.W),A1
	MOVE.B	(A1)+,D4
	LSL.L	#8,D4
	MOVE.B	(A1)+,D4
	LSL.L	#8,D4
	MOVE.B	(A1)+,D4
	LSL.L	#8,D4
	MOVE.B	(A1),D4
	MOVEA.L	(A7)+,A1
	RTS

; d0 = d0 / 100000 (unsigned 32 bit), restoring div for 68000
pt_DivU32_100000:
	MOVEM.L	D1-D3,-(A7)
	MOVEQ	#0,D1			; rem
	MOVE.L	#100000,D2
	MOVEQ	#31,D3
pt_DivU32_Loop:
	ADD.L	D0,D0			; shift dividend left, msb -> x
	ADDX.L	D1,D1			; rem = rem*2 + bit
	CMP.L	D2,D1
	BCS.S	pt_DivU32_Skip
	SUB.L	D2,D1
	ADDQ.L	#1,D0			; quotient bit
pt_DivU32_Skip:
	DBF	D3,pt_DivU32_Loop
	MOVEM.L	(A7)+,D1-D3
	RTS

	IFD	DEBUGAUTO
;--- script driver (-DDEBUGAUTO): one cmd per main loop pass
;  MOUSE x y | CLICK x y [R] | PRESS [R] | RELEASE [R]
;  KEY n [q] | KEYN n code | TYPE text      q: 1 shift 2 alt 4 ctrl 8 amiga
;  WAITFRAMES n | WAIT n | WAITSTOP | SHOT name | DUMP h off len name
;  POKE h off val | HW | INEV class code qual x y | NOHOST | LOG text
;  END | QUIT
; each line logged as OK/ERR
dbg_LMB:
	TST.B	dbg_AutoLmb
	BNE.S	dbg_BtnHold
	BTST	#6,CIAA_PRA
	RTS
dbg_RMB:
	TST.B	dbg_AutoRmb
	BNE.S	dbg_BtnHold
	BTST	#2,POTGOR
	RTS
dbg_BtnHold:				; CLICK: hold dbg_AutoHold cia ticks, 0 = PRESS (until RELEASE)
	TST.W	dbg_AutoHold
	BEQ.S	dbg_BtnPressed
	MOVE.L	D0,-(A7)
	MOVE.W	dbg_TickCnt,D0
	TST.W	dbg_AutoBtnEnd
	BNE.S	dbg_BtnHoldChk
	ADD.W	dbg_AutoHold,D0
	BNE.S	dbg_BtnHoldSet
	ADDQ.W	#1,D0
dbg_BtnHoldSet:
	MOVE.W	D0,dbg_AutoBtnEnd
	BRA.S	dbg_BtnHoldOut
dbg_BtnHoldChk:
	SUB.W	dbg_AutoBtnEnd,D0
	BMI.S	dbg_BtnHoldOut
	CLR.W	dbg_AutoHold
	CLR.W	dbg_AutoBtnEnd
	CLR.B	dbg_AutoLmb
	CLR.B	dbg_AutoRmb
dbg_BtnHoldOut:
	MOVE.L	(A7)+,D0
dbg_BtnPressed:
	TST.B	dbg_Zero		; Z=1 like pressed, no regs touched
	RTS
dbg_Zero:
	DC.B	0,0

dbg_AutoStep:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.B	dbg_AutoDone
	BNE.W	dbg_AutoExit
	MOVE.L	dbg_AutoMainSP,D0	; task context only
	BEQ.W	dbg_AutoExit
	SUB.L	A7,D0
	BPL.S	dbg_AutoSpOk
	NEG.L	D0
dbg_AutoSpOk:
	CMP.L	#2048,D0
	BHI.W	dbg_AutoExit
	TST.B	dbg_AutoLoaded
	BNE.S	dbg_AutoRun
	ST	dbg_AutoLoaded
	BSR.W	dbg_AutoLoad
	BEQ.S	dbg_AutoLoadOk
	ST	dbg_AutoDone
	BRA.W	dbg_AutoExit
dbg_AutoLoadOk:
	MOVEA.L	dbg_AutoBuf,A0
	MOVE.L	A0,dbg_AutoPos
	BSR.W	dbg_LogOpen
	BRA.S	dbg_AutoRun2
dbg_AutoRun:
	TST.L	dbg_AutoPos
	BEQ.W	dbg_AutoFinish
dbg_AutoRun2:
	TST.B	dbg_AutoPtrSet
	BEQ.S	dbg_AutoNoPtr
	MOVE.W	dbg_AutoX,dat_EditDigitValue
	MOVE.W	dbg_AutoY,dat_PalEdSelectPos
dbg_AutoNoPtr:
	TST.W	dbg_AutoWait
	BEQ.S	dbg_AutoNoWait
	SUBQ.W	#1,dbg_AutoWait
	BRA.W	dbg_AutoExit
dbg_AutoNoWait:
	TST.B	dbg_AutoWaitStop
	BEQ.S	dbg_AutoNoWaitStop
	TST.L	dat_RpPlayMode
	BNE.W	dbg_AutoExit
	CLR.B	dbg_AutoWaitStop
dbg_AutoNoWaitStop:
	TST.W	dbg_AutoHold		; only CLICK waits for release
	BEQ.S	dbg_AutoNoBtnWait
	; release after hold time or 100 steps w/o poll
	ADDQ.W	#1,dbg_AutoBtnSteps
	MOVE.W	dbg_AutoBtnEnd,D0
	BEQ.S	dbg_AutoBtnNoEnd
	MOVE.W	dbg_TickCnt,D1
	SUB.W	D0,D1
	BPL.S	dbg_AutoBtnFree
	BRA.S	dbg_AutoBtnChk
dbg_AutoBtnNoEnd:
	CMPI.W	#100,dbg_AutoBtnSteps
	BCS.S	dbg_AutoBtnChk
dbg_AutoBtnFree:
	CLR.W	dbg_AutoHold
	CLR.W	dbg_AutoBtnEnd
	CLR.B	dbg_AutoLmb
	CLR.B	dbg_AutoRmb
dbg_AutoBtnChk:
	TST.B	dbg_AutoLmb
	BNE.W	dbg_AutoExit
	TST.B	dbg_AutoRmb
	BNE.W	dbg_AutoExit
dbg_AutoNoBtnWait:
	TST.B	dbg_AutoKeyRel		; rawcode | $80
	BEQ.S	dbg_AutoNoKey
	MOVE.B	dbg_AutoKeyRel,D0
	CLR.B	dbg_AutoKeyRel
	BSR.W	dbg_AutoPutKey
	TST.B	dbg_AutoKeyQual
	BEQ.S	dbg_AutoKeyRelDone
	CLR.B	dbg_AutoKeyQual
	CLR.W	dat_KeyQual1
	CLR.W	dat_KeyQual2
	CLR.W	dat_KeyQual3
	CLR.W	dat_KeyQual4
dbg_AutoKeyRelDone:
	MOVE.W	#2,dbg_AutoWait
	BRA.W	dbg_AutoExit
dbg_AutoNoKey:
	TST.B	dbg_AutoWaitTod
	BEQ.S	dbg_AutoNoTod
	BSR.W	dbg_ReadEClockLo
	SUB.L	dbg_AutoEclkTarget,D0
	BMI.W	dbg_AutoExit
	CLR.B	dbg_AutoWaitTod
dbg_AutoNoTod:
	TST.W	dbg_AutoKeyN
	BEQ.S	dbg_AutoNoKeyN
	SUBQ.W	#1,dbg_AutoKeyN
	MOVE.B	dbg_AutoKeyNCode,D0
	MOVEQ	#0,D3
	BSR.W	dbg_AutoKeyDown
	BRA.W	dbg_AutoExit
dbg_AutoNoKeyN:
	TST.L	dbg_AutoTypePtr
	BEQ.S	dbg_AutoNoType
	BSR.W	dbg_AutoTypeStep
	BNE.W	dbg_AutoExit
dbg_AutoNoType:
	BSR.W	dbg_AutoNextLine	; a0=line d7=len -> Z=1 at end
	BEQ.W	dbg_AutoFinish
	CLR.W	dbg_WdTicks
	MOVE.L	A0,dbg_AutoLine
	MOVE.W	D7,dbg_AutoLineLen
	MOVE.L	A0,A1
	LEA	dbg_CmdTab,A2
dbg_AutoCmdLoop:
	MOVE.L	(A2)+,D0
	BEQ.W	dbg_AutoErr
	MOVEA.L	(A2)+,A3
	MOVEA.L	A1,A4
dbg_AutoCmpLoop:
	MOVE.B	(A3)+,D1
	BEQ.S	dbg_AutoCmdHit
	CMP.B	(A4)+,D1
	BEQ.S	dbg_AutoCmpLoop
	BRA.S	dbg_AutoCmdLoop
dbg_AutoCmdHit:
	MOVE.B	(A4),D1
	BEQ.S	dbg_AutoCmdOk
	CMP.B	#" ",D1
	BNE.S	dbg_AutoCmdLoop
dbg_AutoCmdOk:
	MOVEA.L	A4,A1		; a1=args
	MOVEA.L	D0,A3
	JSR	(A3)
	BNE.S	dbg_AutoErr
	LEA	dbg_StrOk,A0
	BSR.W	dbg_LogLine
	BRA.S	dbg_AutoExit
dbg_AutoErr:
	LEA	dbg_StrErr,A0
	BSR.W	dbg_LogLine
dbg_AutoExit:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dbg_AutoFinish:
	ST	dbg_AutoDone
	BSR.W	dbg_TimerClose
	BSR.W	dbg_LogClose
	LEA	dbg_NameDone,A0
	BSR.W	dbg_FileCreate
	BSR.W	dbg_FileClose
	BRA.S	dbg_AutoExit

;--- commands: a1=args (line is 0-terminated) -> Z=1 ok
dbg_CmdMouse:
	BSR.W	dbg_ParseNum
	MOVE.W	D0,dbg_AutoX
	BSR.W	dbg_ParseNum
	MOVE.W	D0,dbg_AutoY
	ST	dbg_AutoPtrSet
	MOVE.W	dbg_AutoX,dat_EditDigitValue
	MOVE.W	dbg_AutoY,dat_PalEdSelectPos
	MOVEQ	#0,D0
	RTS
dbg_CmdClick:
	BSR.S	dbg_CmdMouse
	BSR.W	dbg_SkipSpace
	CMP.B	#"R",(A1)
	BEQ.S	dbg_CmdClickR
	ST	dbg_AutoLmb
	BRA.S	dbg_CmdClickHold
dbg_CmdClickR:
	ST	dbg_AutoRmb
dbg_CmdClickHold:
	MOVE.W	#4,dbg_AutoHold		; 4 cia ticks
	CLR.W	dbg_AutoBtnSteps
	MOVE.W	#4,dbg_AutoWait
	MOVEQ	#0,D0
	RTS
dbg_CmdPress:
	BSR.W	dbg_SkipSpace
	CLR.W	dbg_AutoHold
	CMP.B	#"R",(A1)
	BEQ.S	dbg_CmdPressR
	ST	dbg_AutoLmb
	MOVEQ	#0,D0
	RTS
dbg_CmdPressR:
	ST	dbg_AutoRmb
	MOVEQ	#0,D0
	RTS
dbg_CmdRelease:
	BSR.W	dbg_SkipSpace
	CMP.B	#"R",(A1)
	BEQ.S	dbg_CmdRelR
	CLR.B	dbg_AutoLmb
	MOVEQ	#0,D0
	RTS
dbg_CmdRelR:
	CLR.B	dbg_AutoRmb
	MOVEQ	#0,D0
	RTS
dbg_CmdKey:
	BSR.W	dbg_ParseNum
	MOVE.W	D0,D2
	BSR.W	dbg_ParseNum
	MOVE.B	D0,D3
	MOVE.W	D2,D0
	BSR.W	dbg_AutoKeyDown
	MOVEQ	#0,D0
	RTS
dbg_AutoKeyDown:			; d0.b=rawcode d3.b=qual: press, queue release
	MOVE.B	D3,dbg_AutoKeyQual
	BTST	#0,D3
	BEQ.S	dbg_AutoKdNoShift
	MOVE.W	#1,dat_KeyQual1
dbg_AutoKdNoShift:
	BTST	#1,D3
	BEQ.S	dbg_AutoKdNoAlt
	MOVE.W	#1,dat_KeyQual2
dbg_AutoKdNoAlt:
	BTST	#2,D3
	BEQ.S	dbg_AutoKdNoCtrl
	MOVE.W	#1,dat_KeyQual3
dbg_AutoKdNoCtrl:
	BTST	#3,D3
	BEQ.S	dbg_AutoKdNoAmiga
	MOVE.W	#1,dat_KeyQual4
dbg_AutoKdNoAmiga:
	MOVE.B	D0,D1
	OR.B	#$80,D1
	MOVE.B	D1,dbg_AutoKeyRel
	BSR.W	dbg_AutoPutKey
	MOVE.W	#2,dbg_AutoWait
	RTS
dbg_CmdKeyN:				; KEYN n code
	BSR.W	dbg_ParseNum
	MOVE.W	D0,dbg_AutoKeyN
	BSR.W	dbg_ParseNum
	MOVE.B	D0,dbg_AutoKeyNCode
	MOVEQ	#0,D0
	RTS
dbg_CmdType:				; TYPE text
	BSR.W	dbg_SkipSpace
	MOVE.L	A1,dbg_AutoTypePtr
	MOVEQ	#0,D0
	RTS
dbg_CmdWaitFrames:
	BSR.W	dbg_ParseNum
	MOVE.L	dbg_EPerFrame,D1
	JSR	pt_MixMul32			; d0 = frames * eclocks per frame
	MOVE.L	D0,D2
	BSR.W	dbg_ReadEClockLo
	ADD.L	D2,D0
	MOVE.L	D0,dbg_AutoEclkTarget
	ST	dbg_AutoWaitTod
	MOVEQ	#0,D0
	RTS
dbg_ReadTod:				; d0.w = cia-a tod mid:lo, 50 hz
	MOVEQ	#0,D0
	MOVE.B	$BFE901,D0
	LSL.W	#8,D0
	MOVE.B	$BFE801,D0
	RTS
dbg_AutoTypeStep:			; Z=1 at end of text
	MOVEA.L	dbg_AutoTypePtr,A1
	MOVE.B	(A1)+,D0
	BEQ.S	dbg_AutoTypeEnd
	MOVE.L	A1,dbg_AutoTypePtr
	CMP.B	#"a",D0
	BCS.S	dbg_AutoTypeMap
	CMP.B	#"z",D0
	BHI.S	dbg_AutoTypeMap
	SUB.B	#$20,D0		; lower -> upper, no shift
	AND.W	#$7f,D0
	LEA	dbg_AsciiRaw,A0
	MOVE.B	(0,A0,D0.W),D1
	AND.B	#$7f,D1
	MOVE.B	D1,D0
	MOVEQ	#0,D3
	BSR.W	dbg_AutoKeyDown
	MOVEQ	#1,D0
	RTS
dbg_AutoTypeMap:
	AND.W	#$7f,D0
	LEA	dbg_AsciiRaw,A0
	MOVE.B	(0,A0,D0.W),D1
	MOVEQ	#0,D3
	BPL.S	dbg_AutoTypeNoShift
	MOVEQ	#1,D3			; bit 7 = shift
dbg_AutoTypeNoShift:
	AND.B	#$7f,D1
	MOVE.B	D1,D0
	BSR.W	dbg_AutoKeyDown
	MOVEQ	#1,D0
	RTS
dbg_AutoTypeEnd:
	CLR.L	dbg_AutoTypePtr
	MOVEQ	#0,D0
	RTS
dbg_CmdWait:
	BSR.W	dbg_ParseNum
	MOVE.W	D0,dbg_AutoWait
	MOVEQ	#0,D0
	RTS
; NOHOST: wrap input handler, rawkey -> null (blocks host keyboard)
dbg_CmdNoHost:
	TST.L	dbg_InOrig
	BNE.S	.r
	MOVE.L	dat_InputIntStruct+18,dbg_InOrig
	MOVE.L	#dbg_InWrap,dat_InputIntStruct+18
.r:	MOVEQ	#0,D0
	RTS
dbg_InWrap:				; a0=event chain a1=is_Data
	MOVE.L	A0,-(A7)
.l:	MOVE.L	A0,D0
	BEQ.S	.go
	CMPI.B	#1,4(A0)		; ie_Class = IECLASS_RAWKEY
	BNE.S	.n
	CLR.B	4(A0)			; -> IECLASS_NULL
.n:	MOVEA.L	(A0),A0
	BRA.S	.l
.go:	MOVEA.L	(A7)+,A0
	MOVE.L	dbg_InOrig,-(A7)
	RTS
dbg_CmdWaitStop:
	ST	dbg_AutoWaitStop
	MOVEQ	#0,D0
	RTS
dbg_CmdLog:
	BSR.W	dbg_SkipSpace
	MOVEA.L	A1,A0
	CLR.L	dbg_AutoLine
	BSR.W	dbg_LogLine
	MOVEQ	#0,D0
	RTS
dbg_CmdEnd:
	CLR.L	dbg_AutoPos
	MOVEQ	#0,D0
	RTS
dbg_CmdQuit:				; ctrl-c to pt: quits at the next main pass
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	276(A6),A1		; ThisTask
	MOVE.L	#$1000,D0
	JSR	(-324,A6)		; Signal
	CLR.L	dbg_AutoPos
	MOVEQ	#0,D0
	RTS
dbg_AutoQuit:				; pt quits: log closed, done file for the host
	TST.B	dbg_AutoLoaded
	BEQ.S	.r
	BSR.W	dbg_TimerClose
	BSR.W	dbg_LogClose
	LEA	dbg_NameDone,A0
	BSR.W	dbg_FileCreate
	BSR.W	dbg_FileClose
.r:	RTS
dbg_CmdShot:				; SHOT name
	BSR.W	dbg_SkipSpace
	LEA	dbg_PfxShot,A2
	BSR.W	dbg_BuildName
	LEA	dbg_AutoName,A0
	BSR.W	dbg_FileCreate
	BEQ.W	dbg_CmdFail
	LEA	SECSTRT_2,A0
	MOVE.L	#$5000,D3
	BSR.W	dbg_FileWrite
	LEA	chip_ScreenBitplanes,A0
	MOVE.L	#$5000,D3
	BSR.W	dbg_FileWrite
	LEA	chip_ScreenBitplanes2,A0
	MOVE.L	#$5000,D3
	BSR.W	dbg_FileWrite
	LEA	chip_Palette1,A0
	MOVE.L	#128,D3
	BSR.W	dbg_FileWrite
	BSR.W	dbg_FileClose
	MOVEQ	#0,D0
	RTS
dbg_CmdDump:				; DUMP h off len name
	BSR.W	dbg_ParseNum
	CMP.W	#4,D0
	BHI.S	dbg_CmdFail
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	dbg_HunkTab,A0
	MOVEA.L	(0,A0,D0.W),A4
	BSR.W	dbg_ParseNum
	ADDA.L	D0,A4
	BSR.W	dbg_ParseNum
	MOVE.L	D0,D5
	BSR.W	dbg_SkipSpace
	LEA	dbg_PfxDump,A2
	BSR.W	dbg_BuildName
	LEA	dbg_AutoName,A0
	BSR.W	dbg_FileCreate
	BEQ.S	dbg_CmdFail
	MOVEA.L	A4,A0
	MOVE.L	D5,D3
	BSR.W	dbg_FileWrite
	BSR.W	dbg_FileClose
	MOVEQ	#0,D0
	RTS
dbg_CmdPoke:				; POKE h off val (byte)
	BSR.W	dbg_ParseNum
	CMP.W	#4,D0
	BHI.S	dbg_CmdFail
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	dbg_HunkTab,A0
	MOVEA.L	(0,A0,D0.W),A4
	BSR.W	dbg_ParseNum
	ADDA.L	D0,A4
	BSR.W	dbg_ParseNum
	MOVE.B	D0,(A4)
	MOVEQ	#0,D0
	RTS
dbg_CmdFail:
	MOVEQ	#1,D0
	RTS
dbg_CmdHw:				; HW: snapshot of paula-relevant read regs -> dbg_HwSnap
	LEA	dbg_HwSnap,A0
	MOVE.W	DMACONR,(A0)+
	MOVE.W	INTENAR,(A0)+
	MOVE.W	INTREQR,(A0)+
	MOVE.W	$DFF010,(A0)+
	MOVEQ	#0,D0
	RTS
dbg_CmdInEv:				; INEV class code qual x y (x/y > 32767 = neg)
	LEA	dbg_InEvent,A4		; via input.device IND_WRITEEVENT
	CLR.L	(A4)
	BSR.W	dbg_ParseNum
	MOVE.B	D0,4(A4)		; ie_Class
	CLR.B	5(A4)
	BSR.W	dbg_ParseNum
	MOVE.W	D0,6(A4)		; ie_Code
	BSR.W	dbg_ParseNum
	MOVE.W	D0,8(A4)		; ie_Qualifier
	BSR.W	dbg_ParseNum
	MOVE.W	D0,10(A4)		; ie_X
	BSR.W	dbg_ParseNum
	MOVE.W	D0,12(A4)		; ie_Y
	CLR.L	14(A4)
	CLR.L	18(A4)
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dat_DisplayWorkBuf2,A1	; handler iorequest
	MOVE.W	#11,28(A1)		; IND_WRITEEVENT
	MOVE.L	A4,40(A1)		; io_Data
	MOVE.L	#22,36(A1)		; io_Length
	JSR	(-456,A6)		; DoIO
	MOVEQ	#0,D0
	RTS

;--- helpers
dbg_AutoLoad:				; read script -> Z=1 ok
	MOVE.L	#dbg_NameScript,D1
	MOVE.L	#1005,D2		; MODE_OLDFILE
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,D4
	BEQ.W	dbg_AutoLoadFail
	MOVE.L	D4,D1			; size: seek end, back to start
	MOVEQ	#0,D2
	MOVEQ	#1,D3
	JSR	(-66,A6)
	MOVE.L	D4,D1
	MOVEQ	#0,D2
	MOVEQ	#-1,D3
	JSR	(-66,A6)
	MOVE.L	D0,D5
	BMI.S	.fail
	ADDQ.L	#2,D0
	MOVEQ	#1,D1			; MEMF_PUBLIC, never freed (dbg)
	MOVE.L	A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)		; AllocMem
	MOVEA.L	(A7)+,A6
	MOVE.L	D0,dbg_AutoBuf
	BEQ.S	.fail
	MOVE.L	D4,D1
	MOVE.L	D0,D2
	MOVE.L	D5,D3
	JSR	(-42,A6)		; Read
	MOVE.L	D0,D5
.fail:	MOVE.L	D4,D1
	JSR	(-36,A6)		; Close
	TST.L	dbg_AutoBuf
	BEQ.W	dbg_AutoLoadFail
	TST.L	D5
	BMI.W	dbg_AutoLoadFail
	MOVEA.L	dbg_AutoBuf,A0
	CLR.B	(0,A0,D5.L)
	BSR.S	dbg_TimerOpen
	MOVEQ	#0,D0
	RTS
dbg_TimerOpen:				; timer.device UNIT_ECLOCK for ReadEClock
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	LEA	dbg_TimerName,A0
	MOVEQ	#3,D0			; UNIT_ECLOCK
	LEA	dbg_TimerReq,A1
	MOVEQ	#0,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-444,A6)		; OpenDevice
	TST.L	D0
	BNE.S	dbg_TimerOpenDone
	MOVE.L	dbg_TimerReq+20,dbg_TimerBase
	LEA	dbg_EClock,A0
	MOVEA.L	dbg_TimerBase,A6
	JSR	(-60,A6)		; ReadEClock
	MOVEQ	#50,D1
	JSR	pt_MixDiv32
	MOVE.L	D0,dbg_EPerFrame
dbg_TimerOpenDone:
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS
dbg_TimerClose:
	MOVE.L	dbg_TimerBase,D0
	BEQ.S	dbg_TimerCloseDone
	LEA	dbg_TimerReq,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-450,A6)		; CloseDevice
	CLR.L	dbg_TimerBase
dbg_TimerCloseDone:
	RTS
dbg_ReadEClockLo:			; d0 = low 32 bit of eclock, 0 w/o timer
	MOVE.L	dbg_TimerBase,D0
	BEQ.S	dbg_ReadEClockNone
	MOVEM.L	A0/A6,-(A7)
	LEA	dbg_EClock,A0
	MOVEA.L	dbg_TimerBase,A6
	JSR	(-60,A6)
	MOVE.L	dbg_EClock+4,D0
	MOVEM.L	(A7)+,A0/A6
dbg_ReadEClockNone:
	RTS
dbg_TimerName:	DC.B	"timer.device",0
	EVEN
dbg_AutoLoadFail:
	MOVEQ	#1,D0
	RTS
dbg_AutoNextLine:			; next nonblank line from dbg_AutoPos: a0=start Z=1 at end
	MOVEA.L	dbg_AutoPos,A0
dbg_AutoNlSkip:
	MOVE.B	(A0),D0
	BEQ.S	dbg_AutoNlEnd
	CMP.B	#" ",D0
	BLS.S	dbg_AutoNlNext
	CMP.B	#";",D0
	BNE.S	dbg_AutoNlStart
dbg_AutoNlComment:
	MOVE.B	(A0)+,D0
	BEQ.S	dbg_AutoNlEnd
	CMP.B	#10,D0
	BNE.S	dbg_AutoNlComment
	BRA.S	dbg_AutoNlSkip
dbg_AutoNlNext:
	ADDQ.L	#1,A0
	BRA.S	dbg_AutoNlSkip
dbg_AutoNlStart:
	MOVEA.L	A0,A1
	MOVEQ	#0,D7
dbg_AutoNlLen:
	MOVE.B	(A1),D0
	BEQ.S	dbg_AutoNlTerm
	CMP.B	#10,D0
	BEQ.S	dbg_AutoNlTerm
	CMP.B	#13,D0
	BEQ.S	dbg_AutoNlTerm
	ADDQ.L	#1,A1
	ADDQ.W	#1,D7
	BRA.S	dbg_AutoNlLen
dbg_AutoNlTerm:
	TST.B	(A1)
	BEQ.S	dbg_AutoNlLast
	CLR.B	(A1)+
	MOVE.L	A1,dbg_AutoPos
	MOVEQ	#1,D0			; Z=0 line found
	RTS
dbg_AutoNlLast:
	MOVE.L	A1,dbg_AutoPos
	MOVEQ	#1,D0
	RTS
dbg_AutoNlEnd:
	CLR.L	dbg_AutoPos
	MOVEQ	#0,D0			; Z=1: Ende
	RTS
dbg_SkipSpace:
	CMP.B	#" ",(A1)
	BNE.S	dbg_SkipSpaceEnd
	ADDQ.L	#1,A1
	BRA.S	dbg_SkipSpace
dbg_SkipSpaceEnd:
	RTS
dbg_ParseNum:				; decimal at a1 -> d0.l, a1 behind
	BSR.S	dbg_SkipSpace
	MOVEQ	#0,D0
dbg_ParseNumLoop:
	MOVE.B	(A1),D1
	SUB.B	#"0",D1
	BCS.S	dbg_ParseNumEnd
	CMP.B	#9,D1
	BHI.S	dbg_ParseNumEnd
	AND.L	#$0000000f,D1	; long: d1 high word must be clear
	ADD.L	D0,D0			; d0*10 = d0*2 + d0*8
	MOVE.L	D0,-(A7)
	LSL.L	#2,D0
	ADD.L	(A7)+,D0
	ADD.L	D1,D0
	ADDQ.L	#1,A1
	BRA.S	dbg_ParseNumLoop
dbg_ParseNumEnd:
	RTS
dbg_AutoPutKey:				; d0.b=rawcode -> pt key buffer
	LEA	dat_KeyBuffer,A0
	MOVE.W	dat_KeyBufCount,D1
	CMP.W	#16,D1
	BCC.S	dbg_AutoPutKeyEnd
	MOVE.B	D0,(0,A0,D1.W)
	ADDQ.W	#1,dat_KeyBufCount
dbg_AutoPutKeyEnd:
	RTS
dbg_BuildName:				; a2=prefix a1=name -> dbg_AutoName + ".bin"
	LEA	dbg_AutoName,A0
dbg_BuildName1:
	MOVE.B	(A2)+,(A0)+
	BNE.S	dbg_BuildName1
	SUBQ.L	#1,A0
	MOVEQ	#31,D0
dbg_BuildName2:
	MOVE.B	(A1),D1
	CMP.B	#" ",D1
	BLS.S	dbg_BuildName3
	MOVE.B	D1,(A0)+
	ADDQ.L	#1,A1
	DBF	D0,dbg_BuildName2
dbg_BuildName3:
	LEA	dbg_SfxBin,A2
dbg_BuildName4:
	MOVE.B	(A2)+,(A0)+
	BNE.S	dbg_BuildName4
	RTS
dbg_FileCreate:				; a0=name -> dbg_AutoFh Z=0 ok
	MOVE.L	A0,D1
	MOVE.L	#1006,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,dbg_AutoFh
	RTS
dbg_FileWrite:				; a0=data d3=len
	MOVE.L	dbg_AutoFh,D1
	BEQ.S	dbg_FileWriteEnd
	MOVE.L	A0,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-48,A6)
dbg_FileWriteEnd:
	RTS
dbg_FileClose:
	MOVE.L	dbg_AutoFh,D1
	BEQ.S	dbg_FileCloseEnd
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	CLR.L	dbg_AutoFh
dbg_FileCloseEnd:
	RTS
dbg_LogOpen:
	MOVE.L	#dbg_NameLog,D1
	MOVE.L	#1006,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,dbg_AutoLog
	RTS
dbg_LogClose:
	MOVE.L	dbg_AutoLog,D1
	BEQ.S	dbg_LogCloseEnd
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	CLR.L	dbg_AutoLog
dbg_LogCloseEnd:
	RTS
dbg_LogLine:				; a0=prefix, then cur script line
	MOVE.L	dbg_AutoLog,D1
	BEQ.S	dbg_LogLineEnd
	MOVEA.L	A0,A2
	MOVEQ	#0,D3
dbg_LogLen1:
	TST.B	(A2)+
	BEQ.S	dbg_LogLen1End
	ADDQ.L	#1,D3
	BRA.S	dbg_LogLen1
dbg_LogLen1End:
	MOVE.L	A0,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-48,A6)
	MOVE.L	dbg_AutoLine,D2
	BEQ.S	dbg_LogNl
	MOVEQ	#0,D3
	MOVE.W	dbg_AutoLineLen,D3
	MOVE.L	dbg_AutoLog,D1
	JSR	(-48,A6)
dbg_LogNl:
	MOVE.L	dbg_AutoLog,D1
	MOVE.L	#dbg_StrNl,D2
	MOVEQ	#1,D3
	JSR	(-48,A6)
dbg_LogLineEnd:
	RTS

dbg_CmdTab:
	DC.L	dbg_CmdMouse,dbg_StrMouse
	DC.L	dbg_CmdClick,dbg_StrClick
	DC.L	dbg_CmdPress,dbg_StrPress
	DC.L	dbg_CmdRelease,dbg_StrRelease
	DC.L	dbg_CmdKeyN,dbg_StrKeyN
	DC.L	dbg_CmdKey,dbg_StrKey
	DC.L	dbg_CmdType,dbg_StrType
	DC.L	dbg_CmdWaitFrames,dbg_StrWaitFrames
	DC.L	dbg_CmdWaitStop,dbg_StrWaitStop
	DC.L	dbg_CmdWait,dbg_StrWait
	DC.L	dbg_CmdShot,dbg_StrShot
	DC.L	dbg_CmdDump,dbg_StrDump
	DC.L	dbg_CmdPoke,dbg_StrPoke
	DC.L	dbg_CmdInEv,dbg_StrInEv
	DC.L	dbg_CmdNoHost,dbg_StrNoHost
	DC.L	dbg_CmdLog,dbg_StrLog
	DC.L	dbg_CmdHw,dbg_StrHw
	DC.L	dbg_CmdEnd,dbg_StrEnd
	DC.L	dbg_CmdQuit,dbg_StrQuit
	DC.L	0
dbg_HunkTab:
	DC.L	SECSTRT_0,SECSTRT_1,SECSTRT_2,SECSTRT_3,SECSTRT_4
dbg_StrPoke:	DC.B	"POKE",0
dbg_StrInEv:	DC.B	"INEV",0
dbg_StrNoHost:	DC.B	"NOHOST",0
dbg_StrMouse:	DC.B	"MOUSE",0
dbg_StrClick:	DC.B	"CLICK",0
dbg_StrPress:	DC.B	"PRESS",0
dbg_StrRelease:	DC.B	"RELEASE",0
dbg_StrKeyN:	DC.B	"KEYN",0
dbg_StrKey:	DC.B	"KEY",0
dbg_StrType:	DC.B	"TYPE",0
dbg_StrWaitFrames: DC.B	"WAITFRAMES",0
dbg_StrWaitStop: DC.B	"WAITSTOP",0
dbg_StrWait:	DC.B	"WAIT",0
dbg_StrShot:	DC.B	"SHOT",0
dbg_StrDump:	DC.B	"DUMP",0
dbg_StrLog:	DC.B	"LOG",0
dbg_StrHw:	DC.B	"HW",0
dbg_StrEnd:	DC.B	"END",0
dbg_StrQuit:	DC.B	"QUIT",0
dbg_AsciiRaw:			; ascii -> us rawcode, $7f = none, bit 7 = shift
	DC.B	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$41,$42,$44,$7f,$7f,$44,$7f,$7f
	DC.B	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	DC.B	$40,$81,$aa,$83,$7f,$7f,$7f,$2a,$89,$8a,$88,$8c,$38,$0b,$39,$3a
	DC.B	$0a,$01,$02,$03,$04,$05,$06,$07,$08,$09,$a9,$29,$7f,$0c,$7f,$ba
	DC.B	$7f,$20,$35,$33,$22,$12,$23,$24,$25,$17,$26,$27,$28,$37,$36,$18
	DC.B	$19,$10,$13,$21,$14,$16,$34,$11,$32,$15,$31,$1a,$0d,$1b,$7f,$8b
	DC.B	$00,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	DC.B	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
dbg_StrOk:	DC.B	"OK ",0
dbg_StrErr:	DC.B	"ERR ",0
dbg_StrNl:	DC.B	10,0
dbg_NameScript:	DC.B	"PT:autotest.txt",0
dbg_NameLog:	DC.B	"PT:S/autotest.log",0
dbg_NameDone:	DC.B	"PT:S/autotest.done",0
dbg_PfxShot:	DC.B	"PT:S/shot_",0
dbg_PfxDump:	DC.B	"PT:S/dump_",0
dbg_SfxBin:	DC.B	".bin",0
	EVEN
	ENDC

	IFD	DEBUGFX
;--- tick trace (-DDEBUGFX): 16 bytes ch1 per tick -> dbg_FxBuf
;  0 patpos.w 2 tick.b 3 songpos.b 4 period.w 6 vol.b 7 trigger.b
;  8 aud0per shadow.w 10 aud0vol shadow.w 12 start.l
dbg_FxTick:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	TST.L	dat_RpPlayMode		; only while playing
	BEQ.W	dbg_FxFull
	LEA	dbg_FxHdr,A1
	MOVE.L	(8,A1),D0
	BNE.S	dbg_FxTickGo
	MOVE.L	#dat_Channel1,dbg_FxChan	; first tick: ch1
	CMPI.W	#8,dat_RpNumChannels
	BNE.S	dbg_FxTickGo
	MOVEA.L	dat_ModulePtr,A0
	LEA	mod_patterns(A0),A0
	TST.L	(A0)			; trk1 row 0 empty?
	BNE.S	dbg_FxTickGo
	TST.L	16(A0)			; trk5 row 0 used? -> ch5
	BEQ.S	dbg_FxTickGo
	MOVE.L	#dat_Channel5,dbg_FxChan
dbg_FxTickGo:
	CMP.L	#DBG_FXTICKS,D0
	BCC.S	dbg_FxFull
	MOVEA.L	(12,A1),A0
	LSL.L	#4,D0
	ADDA.L	D0,A0
	MOVE.L	dat_RpPatternPos,D1
	MOVE.W	D1,(A0)+
	MOVE.B	dat_RpCounter+3,(A0)+
	MOVE.B	dat_RpSongPos+3,(A0)+
	MOVEA.L	dbg_FxChan,A1
	MOVE.W	(n_period,A1),(A0)+
	MOVE.B	(n_volume,A1),(A0)+
	MOVE.B	(n_pt4_trigger,A1),(A0)+	; scope counter clears it in vbl, not here
	MOVE.L	(n_start,A1),D1
	LEA	dbg_FxHdr,A1
	MOVE.W	(16,A1),(A0)+
	MOVE.W	(18,A1),(A0)+
	MOVE.L	D1,(A0)+
	MOVE.L	#$ffffffff,(16,A1)
	ADDQ.L	#1,(8,A1)
dbg_FxFull:
	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS
dbg_FxPer2:				; replaces MOVE.W D2,(aud_PER,A5) (arpeggio)
	MOVE.W	D2,(aud_PER,A5)
	CMPA.L	dbg_FxChan,A6
	BNE.S	dbg_FxRts
	MOVE.W	D2,dbg_FxHdr+16
	RTS
dbg_FxPer0:				; replaces MOVE.W D0,(aud_PER,A5) (vibrato)
	MOVE.W	D0,(aud_PER,A5)
	CMPA.L	dbg_FxChan,A6
	BNE.S	dbg_FxRts
	MOVE.W	D0,dbg_FxHdr+16
	RTS
dbg_FxVol0:				; replaces MOVE.W D0,(aud_VOL,A5) (tremolo)
	MOVE.W	D0,(aud_VOL,A5)
	CMPA.L	dbg_FxChan,A6
	BNE.S	dbg_FxRts
	MOVE.W	D0,dbg_FxHdr+18
dbg_FxRts:
	RTS
dbg_FxFlush:				; main loop: after stop write header + buf once
	MOVEM.L	D0-D4/A0-A1/A6,-(A7)
	LEA	dbg_FxHdr,A1
	TST.W	(20,A1)
	BNE.S	dbg_FxFlushDone
	TST.L	(8,A1)
	BEQ.S	dbg_FxFlushDone
	TST.L	dat_RpPlayMode
	BNE.S	dbg_FxFlushDone
	MOVE.W	#1,(20,A1)
	MOVE.L	#dbg_FxName,D1
	MOVE.L	#1006,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)		; Open(name, MODE_NEWFILE)
	MOVE.L	D0,D4
	BEQ.S	dbg_FxFlushDone
	MOVE.L	D4,D1
	MOVE.L	#dbg_FxHdr,D2
	MOVEQ	#24,D3
	JSR	(-48,A6)		; Write(fh, hdr, 24)
	MOVE.L	D4,D1
	MOVE.L	dbg_FxHdr+12,D2
	MOVE.L	dbg_FxHdr+8,D3
	LSL.L	#4,D3
	JSR	(-48,A6)		; Write(fh, buf, cnt*16)
	MOVE.L	D4,D1
	JSR	(-36,A6)		; Close(fh)
	LEA	dbg_FxMsg,A0
	JSR	pt_ShowStatusMsg
	JSR	dbg_MixFlush
dbg_FxFlushDone:
	MOVEM.L	(A7)+,D0-D4/A0-A1/A6
	RTS
dbg_FxName:
	DC.B	"PT:fxtrace.bin",0,0
dbg_FxMsg:
	DC.B	"FX TRACE WRITTEN",0,0
	EVEN
	ENDC

	IFD	DEBUGTRAP
;--- trap handler (-DDEBUGTRAP): pc as hunk 0 ofs in alert $8000oooo
; vec 3 on 68000: pc at +10, else pc at +2
; vec 3/4 -> handler, also irq/softint, 68010+ (vbr)
dbg_TrapVectors:
	MOVEM.L	D0-D1/A0-A1/A5-A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.W	(296,A6),D0
	BTST	#0,D0			; AFB_68010
	BEQ.S	.r
	LEA	.sup(PC),A5
	JSR	(-30,A6)		; Supervisor(A5)
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1/A5-A6
	RTS
.sup:	MC68020
	MOVEC	VBR,A0
	MC68000
	MOVE.L	#dbg_Vec3,(3*4,A0)
	MOVE.L	#dbg_Vec4,(4*4,A0)
	RTE
dbg_Vec3:	MOVE.L	#3,-(A7)
	BRA.W	dbg_TrapHandler
dbg_Vec4:	MOVE.L	#4,-(A7)
	BRA.W	dbg_TrapHandler
dbg_TrapHandler:
	MOVE.L	(A7)+,D0		; Trap-Nummer
	LEA	(dbg_TrapHandler,PC),A0
	MOVE.L	A0,D1
	SUB.L	#dbg_TrapHandler-pt_Hunk0Start,D1	; d1 = hunk 0 load addr
	MOVEQ	#0,D6
	MOVEA.L	ABSEXECBASE.W,A1
	BTST	#1,(297,A1)		; 68020+: pc at +2, fault addr at +16
	BEQ.S	dbg_F68k
	MOVE.L	(2,A7),D7
	CMP.L	#3,D0
	BNE.S	dbg_Scan
	MOVE.L	(16,A7),D6
	BRA.S	dbg_Scan
dbg_F68k:
	CMP.L	#3,D0
	BNE.S	dbg_Normal
	MOVE.L	(2,A7),D6		; fault addr (68000 frame)
	MOVE.L	(10,A7),D7		; PC
	BRA.S	dbg_Scan
dbg_Normal:
	MOVE.L	(2,A7),D7
dbg_Scan:				; pc in hunk 0 -> offset, else raw; AD = fault addr
	MOVE.L	D7,D2
	SUB.L	D1,D2
	CMP.L	#$40000,D2
	BCC.S	dbg_Show
	MOVE.L	D2,D7
dbg_Show:
	LEA	dbg_Text,A0
	MOVE.B	#"T",(A0)+
	MOVE.B	D0,D2
	BSR.S	dbg_Hex1
	MOVE.B	#" ",(A0)+
	MOVE.B	#"P",(A0)+
	MOVE.B	#"C",(A0)+
	MOVE.L	D7,D2
	BSR.S	dbg_Hex8
	MOVE.B	#" ",(A0)+
	MOVE.B	#"A",(A0)+
	MOVE.B	#"D",(A0)+
	MOVE.L	D6,D2
	BSR.S	dbg_Hex8
	CLR.B	(A0)
	LEA	dbg_Text,A0
	JSR	pt_ShowStatusMsg
dbg_Halt:
	BRA.S	dbg_Halt
dbg_Hex8:				; d2 as 8 hex digits -> (a0)+
	MOVEQ	#7,D3
dbg_HexLoop:
	ROL.L	#4,D2
	BSR.S	dbg_Hex1
	DBF	D3,dbg_HexLoop
	RTS
dbg_Hex1:				; low nibble of d2 as digit
	MOVE.B	D2,D4
	AND.B	#$0f,D4
	ADD.B	#"0",D4
	CMP.B	#"9",D4
	BLS.S	dbg_Hex1a
	ADDQ.B	#7,D4
dbg_Hex1a:
	MOVE.B	D4,(A0)+
	RTS
	ENDC
