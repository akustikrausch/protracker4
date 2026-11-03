pt_EnterSampler:
	JSR	pt_WaitMouseRelease
	JSR	pt_ClearDataRegs
	TST.W	dat_SamplerActive
	BNE.S	pt_BtnSmpExit
	MOVE.W	#$0001,dat_SamplerActive
	CLR.B	dat_14BC
	MOVE.L	(dat_SongDataPtr,PC),dat_1366
	CLR.L	dat_SongDataPtr
	MOVEQ	#0,D0
	MOVE.W	#$010e,D1
	MOVEQ	#14,D2
	MOVEA.L	dat_SpriteBufAddr,A0
	BSR.W	pt_DrawSprite
	JSR	pt_0064
	MOVE.W	chip_Palette3,chip_PaletteWork
	BSR.W	pt_10D7
	BNE.S	pt_10D5
	BSR.W	pt_10DA
	JSR	pt_ScrollDisplay
	BSR.W	pt_10DC
	JSR	pt_InitTimeDisplay
	BSR.W	dat_ScreenDispData1
	BSR.W	dat_ScreenDispData2
	BRA.W	pt_RecordModeHandler
pt_BtnSmpExit:
	JSR	pt_WaitMouseRelease
	BSR.W	pt_10DA
	CLR.W	dat_SamplerActive
	BSR.S	pt_10D7
pt_10D5:
	JSR	pt_SetupBorderDisplay
	CLR.B	dat_KeyCode
	MOVE.B	#$da,dat_SprScrollbar
	MOVEQ	#-1,D0
	MOVE.L	D0,dat_DiskOpBufAddr
	MOVE.L	(dat_1366,PC),dat_SongDataPtr
pt_UpdateDisplayMain:
	JSR	pt_UpdatePaletteCopper
	JSR	pt_CheckDiskOpBusy
	JSR	pt_PatViewSetRow
	JSR	pt_ScrollDisplay
	BSR.W	pt_10DC
	JSR	pt_ReturnFromPlay
	JSR	pt_SetTempo
	MOVE.W	#$0001,dat_KeyRepeatDelay
	JSR	pt_AudioChannelUpdate
	BRA.W	pt_PatViewDrawAll
pt_10D7:
	TST.W	dat_SamplerActive
	BEQ.S	pt_10D8
	LEA	dat_1461,A0
	JSR	pt_CheckModuleTypeWrap
	RTS
pt_10D8:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_10D9
	MOVEA.L	#dat_IMPFormatData2,A0
	JSR	pt_CheckModuleTypeWrap
	RTS
pt_10D9:
	MOVEA.L	#dat_IMPFormatData3,A0
	JSR	pt_CheckModuleTypeWrap
	RTS
pt_10DA:
	LEA	chip_CopperWaitLine,A0
	LEA	dat_14B0,A1
pt_10DB:
	MOVE.W	(A0),D0
	MOVE.W	(A1),(A0)+
	MOVE.W	D0,(A1)+
	CMPA.L	#dat_14B2,A1
	BMI.S	pt_10DB
	MOVEQ	#-1,D0
	RTS
pt_10DC:
	MOVE.W	#$0923,D0
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(11120,A0),A0
	MOVE.L	A0,dat_AudioPlayBufPtr
	MOVEQ	#0,D1
pt_10DD:
	MOVE.L	D1,(A0)+
	DBF	D0,pt_10DD
	RTS
pt_10DE:
	MOVE.W	#$04ff,D0
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(11120,A0),A0
	MOVE.L	A0,dat_AudioPlayBufPtr
	MOVEQ	#0,D1
pt_10DF:
	MOVE.L	D1,(A0)+
	DBF	D0,pt_10DF
	RTS
pt_10E0:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#$0280,D2
	MOVEQ	#64,D3
	MOVEQ	#0,D5
	BRA.W	pt_0FA0
pt_InputSampler:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1430,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BEQ.W	pt_10E3
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnSmpExit
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnSmpWaveArea
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnSmpRangeBar
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnSmpWaveform
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnSmpShowRange
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnSmpZoomOut
	CMP.W	#$0007,D2
	BEQ.W	pt_10E3
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnSmpStop
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnSmpDisplay
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnSmpShowAll
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnSmpRangeAll
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnSmpLoop
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnSmpRange
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnSmpBeg
	CMP.W	#$0012,D2
	BEQ.W	pt_BtnSmpEnd
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnSmpSwapBuf
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnSmpSampleNext
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnSmpNoteLeft
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnSmpCut
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnSmpCopy
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnSmpPaste
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnSmpVolume
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnSmpTuneTone
	CMP.W	#$001c,D2
	BEQ.W	pt_BtnSmpResample
	CMP.W	#$001d,D2
	BEQ.W	pt_BtnSmpNoteRight
	MOVEA.L	dat_ModulePtr,A5
	LEA	(-10,A5),A5
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_10E2
	MOVE.W	dat_SamplePlayInit,D0
pt_10E2:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A5
	CMP.W	#$0022,D2
	BEQ.W	pt_BtnSmpInvert
	CMP.W	#$0023,D2
	BEQ.W	pt_BtnSmpMaximize
	CMP.W	#$0024,D2
	BEQ.W	pt_BtnSmpNormalize
	CMP.W	#$0025,D2
	BEQ.W	pt_BtnSmpNormalDc
	CMP.W	#$0026,D2
	BEQ.W	pt_BtnSmpBackwards
	CMP.W	#$0027,D2
	BEQ.W	pt_BtnSmpBoost
	CMP.W	#$0028,D2
	BEQ.W	pt_BtnSmpFilter
	CMP.W	#$0029,D2
	BEQ.W	pt_BtnSmpUpsample
	CMP.W	#$002a,D2
	BEQ.W	pt_BtnSmpDownsample
pt_10E3:
	RTS
pt_BtnSmpWaveform:
	JSR	pt_EdPlayStart
	JMP	pt_WaitMouseRelease
pt_BtnSmpDisplay:
	LEA	dat_EffectData0,A0
	MOVE.L	(dat_DiskBufAddr,PC),dat_SampleOffset
	MOVE.L	(dat_DiskBufLen,PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	CLR.W	(4,A0)
	MOVE.W	#$0001,(6,A0)
	MOVE.W	dat_SamplePlayMode,-(A7)
	CLR.W	dat_SamplePlayMode
	JSR	pt_EdPlayStart
	MOVE.W	(A7)+,dat_SamplePlayMode
	BSR.W	pt_DrawSampleHex
	JMP	pt_WaitMouseRelease
pt_BtnSmpRange:
	MOVE.L	(dat_DiskOpBufAddr,PC),D1
	BMI.W	pt_DisplayModeMsg
	MOVE.L	(dat_DiskOpBufSize,PC),D0
	CMP.L	D0,D1
	BEQ.W	pt_DisplayModeError
	LEA	dat_EffectData0,A0
	MOVE.L	D1,dat_SampleOffset
	SUB.L	D1,D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	CLR.W	(4,A0)
	MOVE.W	#$0001,(6,A0)
	MOVE.W	dat_SamplePlayMode,-(A7)
	CLR.W	dat_SamplePlayMode
	JSR	pt_EdPlayStart
	MOVE.W	(A7)+,dat_SamplePlayMode
	BSR.W	pt_DrawSampleHex
	JMP	pt_WaitMouseRelease
pt_BtnSmpStop:
	JMP	pt_StopAllAudio
dat_SampleOffset:
	DS.L	1
pt_BtnSmpShowRange:
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.W	pt_DisplayModeMsg
	MOVE.L	(dat_DiskOpBufSize,PC),D1
	CMP.L	D1,D0
	BEQ.W	pt_DisplayModeError
	SUB.L	D0,D1
	BNE.S	pt_10EA
	MOVEQ	#1,D1
pt_10EA:
	MOVE.L	D1,dat_DiskBufLen
	MOVE.L	D0,dat_DiskBufAddr
	MOVEQ	#-1,D0
	MOVE.L	D0,dat_DiskOpBufAddr
	CLR.W	dat_RecordBufAddr
	BSR.W	pt_RecordCheckInput
	JMP	pt_WaitMouseRelease
pt_BtnSmpZoomOut:
	MOVE.L	(dat_DiskBufLen,PC),D0
	MOVE.L	(dat_DiskOpFileSize,PC),D1
	MOVE.L	(dat_DiskBufAddr,PC),D2
	MOVE.L	D0,D3
	LSL.L	#1,D3
	CMP.L	D1,D3
	BHI.S	pt_BtnSmpShowAll
	LSR.L	#1,D0
	CMP.L	D2,D0
	BCS.S	pt_10EC
	MOVEQ	#0,D0
pt_10EC:
	SUB.L	D0,D2
	MOVE.L	D2,D0
	ADD.L	D3,D0
	CMP.L	D1,D0
	BLS.S	pt_10ED
	SUB.L	D3,D1
	MOVE.L	D1,D2
pt_10ED:
	MOVE.L	D2,dat_DiskBufAddr
	MOVE.L	D3,dat_DiskBufLen
	BSR.W	pt_CheckDiskBufState
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	CMP.L	(dat_DiskOpBufSize,PC),D0
	BNE.S	pt_10EE
	MOVEQ	#-1,D0
	MOVE.L	D0,dat_DiskOpBufAddr
pt_10EE:
	BSR.W	pt_RecordCheckInput
	JMP	pt_WaitMouseRelease
pt_BtnSmpShowAll:
	CLR.L	dat_DiskBufAddr
	MOVE.L	(dat_DiskOpFileSize,PC),dat_DiskBufLen
	BSR.W	pt_CheckDiskBufState
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	CMP.L	(dat_DiskOpBufSize,PC),D0
	BNE.S	pt_10F0
	MOVEQ	#-1,D0
	MOVE.L	D0,dat_DiskOpBufAddr
	CLR.W	dat_RecordBufAddr
pt_10F0:
	BSR.W	pt_RecordCheckInput
	JMP	pt_WaitMouseRelease
pt_BtnSmpRangeAll:
	BSR.W	pt_ProcessDiskRecord
	MOVE.W	#$0003,dat_RecordBufAddr
	MOVE.W	#$027c,dat_DiskOpListLen
	BSR.W	pt_GetDiskBufLen
pt_10F2:
	BSR.W	pt_ProcessDiskRecord
	JMP	pt_WaitMouseRelease
pt_BtnSmpBeg:
	BSR.W	pt_ProcessDiskRecord
	MOVEQ	#3,D0
	MOVE.W	D0,dat_RecordBufAddr
	MOVE.W	D0,dat_DiskOpListLen
	MOVE.L	(dat_DiskBufAddr,PC),D0
	MOVE.L	D0,dat_DiskOpBufAddr
	MOVE.L	D0,dat_DiskOpBufSize
	BRA.S	pt_10F2
pt_BtnSmpEnd:
	BSR.W	pt_ProcessDiskRecord
	MOVE.W	#$027c,D0
	MOVE.W	D0,dat_RecordBufAddr
	MOVE.W	D0,dat_DiskOpListLen
	MOVE.L	(dat_DiskBufAddr,PC),D0
	ADD.L	(dat_DiskBufLen,PC),D0
	MOVE.L	D0,dat_DiskOpBufAddr
	MOVE.L	D0,dat_DiskOpBufSize
	BRA.S	pt_10F2
pt_BtnSmpSwapBuf:
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.W	pt_SelectDiskMsg
	LSL.W	#2,D1
	LEA	dat_ModulePtr,A0
	LEA	(0,A0,D1.W),A0
	MOVE.L	(dat_FileLockPtr,PC),D0
	MOVE.L	(A0),dat_FileLockPtr
	MOVE.L	D0,(A0)
	MOVEA.L	D0,A1
	CLR.W	(A1)
	MOVE.L	(dat_DiskOpBufState,PC),D0
	MOVE.L	(124,A0),dat_DiskOpBufState
	MOVE.L	D0,(124,A0)
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	MULU	#s_SIZEOF,D1
	LEA	(12,A0,D1.W),A0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	MOVE.L	(dat_10FE,PC),D0
	MOVE.L	(4,A0),dat_10FE
	MOVE.L	D0,(4,A0)
	MOVE.W	(dat_10FF,PC),D0
	MOVE.W	(2,A0),dat_10FF
	TST.B	D0
	BNE.S	pt_10F6
	MOVE.B	#$40,D0
pt_10F6:
	MOVE.W	D0,(2,A0)
	JSR	pt_StopAllAudio
	JSR	pt_SampleLengthValidate
	BSR.W	pt_DrawSampleHex
	JSR	pt_InitChannelPlay
	BSR.W	pt_RecordModeHandler
	JMP	pt_WaitMouseRelease
pt_DisplayModeMsg:
	LEA	(dat_1100,PC),A0
pt_ShowPalEdMsg:
	BSR.W	pt_ShowStatusMsg
	JMP	pt_SetPaletteEdit
pt_DisplayModeError:
	LEA	(dat_1101,PC),A0
	BRA.S	pt_ShowPalEdMsg
pt_10FA:
	LEA	(dat_1102,PC),A0
	BRA.S	pt_ShowPalEdMsg
pt_10FB:
	LEA	(dat_1103,PC),A0
	BRA.S	pt_ShowPalEdMsg
pt_XpkLibErrorMsg:
	LEA	(dat_1104,PC),A0
	BRA.S	pt_ShowPalEdMsg
pt_SelectDiskMsg:
	LEA	(dat_1105,PC),A0
	BRA.S	pt_ShowPalEdMsg
dat_10FE:
	DC.L	$00000001
dat_10FF:
	DC.W	$0040
dat_1100:
	DC.B	"NO RANGE SELECTED",0
dat_1101:
	DC.B	"SET LARGER RANGE",0
dat_1102:
	DC.B	"SET CURSOR POS",0
dat_1103:
	DC.B	"BUFFER IS EMPTY",0
dat_1104:
	DC.B	"SAMPLE IS EMPTY",0
dat_1105:
	DC.B	"THIS IS NOT SAMPLE 0!",0
pt_BtnSmpLoop:
	JSR	pt_WaitMouseRelease
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.S	pt_SelectDiskMsg
	MOVEA.L	(dat_ModulePtr,PC),A0
	MULU	#s_SIZEOF,D1
	LEA	(12,A0,D1.W),A0
	TST.W	dat_DiskDisplayCtrl
	BEQ.S	pt_1108
	MOVE.L	(4,A0),dat_AudioCtrlVar
	MOVEQ	#1,D0
	MOVE.L	D0,(4,A0)
	JSR	pt_SampleLengthValidate
	JSR	pt_StopAllAudio
pt_1107:
	BSR.W	pt_DrawSampleHex
	JSR	pt_InitChannelPlay
	BRA.W	pt_RecordCheckInput
pt_1108:
	JSR	pt_StopAllAudio
	MOVE.L	(dat_AudioCtrlVar,PC),D0
	BNE.S	pt_1109
	MOVE.W	(A0),D0
pt_1109:
	MOVE.L	D0,(4,A0)
	JSR	pt_SampleLengthValidate
	BRA.S	pt_1107
pt_110A:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_DisplayOffText,A0
	TST.W	dat_DiskDisplayCtrl
	BEQ.S	pt_110B
	LEA	dat_DisplayOnText,A0
pt_110B:
	MOVEQ	#3,D0
	MOVE.W	#$46ce,D1
	BSR.W	pt_DrawTextAt
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_DiskDisplayCtrl:
	DS.W	1
dat_AudioCtrlVar:
	DS.L	1
pt_BtnSmpNoteLeft:
	BSR.W	dat_ScreenDispData2
	MOVE.W	#$4a3e,dat_TextBytePos
	MOVE.W	#$0003,dat_TextCharCount
	MOVE.L	#dat_DashSeparator,dat_TextStringPtr
	BSR.W	pt_DrawTextRender
	MOVE.W	#$0001,dat_ScreenSizeVar
	MOVE.L	#dat_BorderSizeH,dat_TempBufPtr
	JMP	pt_WaitMouseRelease
pt_BtnSmpNoteRight:
	BSR.W	dat_ScreenDispData1
	MOVE.W	#$4dae,dat_TextBytePos
	MOVE.W	#$0003,dat_TextCharCount
	MOVE.L	#dat_DashSeparator,dat_TextStringPtr
	BSR.W	pt_DrawTextRender
	MOVE.W	#$0002,dat_ScreenSizeVar
	MOVE.L	#dat_BorderSizeV,dat_TempBufPtr
	JMP	pt_WaitMouseRelease
dat_1110:
	DC.B	10,10
	DC.B	"     RESAMPLE?",0
dat_1111:
	DC.B	"RESAMPLING...",0,0
pt_BtnSmpResample:
	LEA	(dat_1110,PC),A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_1113
	RTS
pt_1113:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	(dat_1111,PC),A0
	BSR.W	pt_ShowStatusMsg
	LEA	dat_ModulePtr,A0
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.W	pt_SelectDiskMsg
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVE.L	(A0),D0
	BEQ.W	pt_RestorePaletteJmp
	MOVEA.L	D0,A2
	MOVE.L	(124,A0),D6
	CMP.L	#$00000002,D6
	BLS.W	pt_RestorePaletteJmp
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	MULU	#s_SIZEOF,D1
	MOVEQ	#0,D0
	MOVE.B	(14,A0,D1.W),D0
	AND.B	#$0f,D0
	MULU	#$004a,D0
	LEA	(dat_PeriodTable,PC),A0
	ADDA.L	D0,A0
	MOVEQ	#0,D1
	MOVE.W	(dat_BorderSizeV,PC),D1
	LSL.W	#1,D1
	MOVE.W	(0,A0,D1.W),D1
	BEQ.W	pt_RestorePaletteJmp
	LEA	dat_PeriodTable,A0
	MOVEQ	#0,D5
	MOVE.W	dat_DisplayLineCount,D5
	LSL.W	#1,D5
	MOVE.W	(0,A0,D5.W),D5
	BEQ.W	pt_RestorePaletteJmp
	MOVE.L	D5,D0
	LSL.L	#8,D0
	LSL.L	#4,D0
	DIVU	D1,D0
	MOVEQ	#0,D4
	MOVE.W	D0,D4
	LSL.L	#4,D4
	MOVE.W	D6,D7
	LSR.W	#1,D7
	MULU	D1,D7
	DIVU	D5,D7
	AND.L	#$00007fff,D7
	CMP.L	#$00000002,D7
	BCS.W	pt_RestorePaletteJmp
	CMP.L	#$00007fff,D7
	BCS.S	pt_1114
	MOVE.L	#$00007fff,D7
pt_1114:
	ADD.L	D7,D7
	MOVE.L	D7,D0
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	TST.L	D0
	BEQ.W	pt_SampleMixStart
	MOVEA.L	D0,A1
	MOVEA.L	D0,A3
	JSR	pt_StopAllAudio
	MOVEA.L	A2,A0
	MOVE.L	#$00007fff,D1
	MOVEQ	#0,D3
	MOVEQ	#0,D5
pt_1115:
	MOVE.B	(1,A0),D0
	EXT.W	D0
	MULS	D1,D0
	MOVE.B	(A0),D2
	EXT.W	D2
	MULS	D3,D2
	ADD.L	D2,D0
	ASR.L	#8,D0
	ASR.L	#7,D0
	MOVE.B	D0,(A1)+
	ADD.L	D4,D5
	SWAP	D5
	MOVEA.L	A2,A0
	MOVEQ	#0,D0
	MOVE.W	D5,D0
	ADDA.L	D0,A0
	SWAP	D5
	MOVE.W	D5,D1
	LSR.W	#1,D1
	MOVE.L	#$00007fff,D3
	SUB.W	D1,D3
	MOVEA.L	A1,A4
	SUBA.L	A3,A4
	CMPA.L	D7,A4
	BCC.S	pt_1116
	MOVEA.L	A0,A4
	SUBA.L	A2,A4
	CMPA.L	D6,A4
	BCS.S	pt_1115
pt_1116:
	MOVEA.L	A2,A1
	MOVE.L	D6,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	MOVE.W	(dat_CurrentSample,PC),D1
	LSL.W	#2,D1
	LEA	dat_ModulePtr,A0
	LEA	(0,A0,D1.W),A0
	MOVE.L	A3,(A0)
	MOVE.L	D7,(124,A0)
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	MULU	#s_SIZEOF,D1
	LEA	(12,A0,D1.W),A0
	LSR.L	#1,D7
	MOVE.W	D7,(A0)
	CLR.B	(2,A0)
	CLR.W	(4,A0)
	MOVE.W	#$0001,(6,A0)
	JSR	pt_RestorePalette
	BSR.W	pt_SampleClearLoop
	BSR.W	pt_DrawSampleHex
	BSR.W	pt_ClearStatusMsg
	BRA.W	pt_RecordModeHandler
pt_RestorePaletteJmp:
	JMP	pt_RestorePaletteInit
pt_BtnSmpCut:
	CLR.B	dat_KeyCode
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.W	pt_DisplayModeMsg
	CMP.L	(dat_DiskOpBufSize,PC),D0
	BEQ.W	pt_DisplayModeError
	BTST	#5,dat_InputReadyFlag
	BEQ.S	pt_1119
	BSR.W	pt_BtnSmpCopy
pt_1119:
	JSR	pt_StopAllAudio
	LEA	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.W	pt_SelectDiskMsg
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVE.L	(A0),D0
	BEQ.W	pt_XpkLibErrorMsg
	MOVE.L	(124,A0),D2
	CMP.L	#$00000002,D2
	BCS.W	pt_XpkLibErrorMsg
	MOVEA.L	D0,A1
	MOVEA.L	D0,A2
	MOVEA.L	D0,A3
	MOVEA.L	D0,A4
	MOVEA.L	D0,A5
	ADDA.L	(dat_DiskOpBufAddr,PC),A3
	MOVE.L	(dat_DiskOpBufSize,PC),D0
	SUB.L	(dat_DiskOpBufAddr,PC),D0
	CMP.L	D2,D0
	BCC.W	pt_SavePalAndSample
	MOVE.L	(dat_DiskOpBufSize,PC),D0
	CMP.L	D2,D0
	BCS.S	pt_111A
	MOVE.L	D2,D0
	SUBQ.L	#1,D0
pt_111A:
	ADDA.L	D0,A4
	ADDA.L	D2,A5
	MOVE.L	A3,D0
	SUB.L	A2,D0
	ADD.L	A5,D0
	SUB.L	A4,D0
	BNE.S	pt_111B
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	BRA.S	pt_1120
pt_111B:
	MOVE.L	D0,D3
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,D4
	BEQ.W	pt_SetupPaletteMode
	MOVEA.L	D0,A0
	MOVEA.L	A2,A1
	MOVE.L	A3,D0
	SUB.L	A2,D0
	BRA.S	pt_111D
pt_111C:
	MOVE.B	(A2)+,(A0)+
pt_111D:
	DBF	D0,pt_111C
	MOVE.L	A5,D0
	SUB.L	A4,D0
	BRA.S	pt_111F
pt_111E:
	MOVE.B	(A4)+,(A0)+
pt_111F:
	DBF	D0,pt_111E
pt_1120:
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	D2,D0
	BEQ.S	pt_1121
	JSR	(-210,A6)
pt_1121:
	MOVE.W	(dat_CurrentSample,PC),D1
	LSL.W	#2,D1
	LEA	(dat_ModulePtr,PC),A0
	LEA	(0,A0,D1.W),A0
	MOVE.L	D4,(A0)
	MOVE.L	D3,(124,A0)
	MOVE.L	D4,dat_DiskOpFilesPtr
	MOVE.L	D3,dat_DiskOpFileSize
	MOVE.L	(dat_DiskBufAddr,PC),D4
	ADD.L	(dat_DiskBufLen,PC),D4
	CMP.L	D3,D4
	BCS.S	pt_1124
	MOVE.L	(dat_DiskBufLen,PC),D4
	CMP.L	D3,D4
	BCS.S	pt_1123
pt_1122:
	CLR.L	dat_DiskBufAddr
	MOVE.L	D3,dat_DiskBufLen
	BRA.S	pt_1124
pt_1123:
	MOVE.L	D3,D4
	SUB.L	(dat_DiskBufLen,PC),D4
	BMI.S	pt_1122
	MOVE.L	D4,dat_DiskBufAddr
pt_1124:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	MULU	#s_SIZEOF,D1
	LEA	(12,A0,D1.W),A0
	LSR.L	#1,D3
	MOVE.W	D3,(A0)
	MOVE.W	(4,A0),D0
	CMP.W	D3,D0
	BLS.S	pt_1125
	MOVEQ	#1,D0
	MOVE.L	D0,(4,A0)
	BRA.S	pt_1126
pt_1125:
	ADD.W	(6,A0),D0
	CMP.W	D3,D0
	BLS.S	pt_1126
	SUB.W	(4,A0),D3
	MOVE.W	D3,(6,A0)
pt_1126:
	MOVE.L	(dat_DiskOpBufAddr,PC),dat_DiskOpBufSize
	BSR.W	pt_SampleClearLoop
	JSR	pt_SampleLengthValidate
	BSR.W	pt_DrawSampleHex
	BRA.W	pt_RecordCheckInput
pt_BtnSmpCopy:
	CLR.B	dat_KeyCode
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.W	pt_DisplayModeMsg
	CMP.L	(dat_DiskOpBufSize,PC),D0
	BEQ.W	pt_DisplayModeError
	LEA	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.W	pt_SelectDiskMsg
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVE.L	(A0),D0
	BEQ.W	pt_XpkLibErrorMsg
	MOVE.L	(124,A0),D2
	BEQ.W	pt_XpkLibErrorMsg
	MOVEA.L	D0,A3
	MOVEA.L	D0,A4
	ADDA.L	(dat_DiskOpBufAddr,PC),A3
	MOVE.L	(dat_DiskOpBufSize,PC),D0
	CMP.L	D2,D0
	BCS.S	pt_1128
	MOVE.L	D2,D0
	SUBQ.L	#1,D0
pt_1128:
	ADDA.L	D0,A4
	BSR.S	pt_CheckFileLock
	MOVE.L	A4,D0
	SUB.L	A3,D0
	ADDQ.L	#1,D0
	MOVE.L	D0,dat_DiskOpBufState
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_FileLockPtr
	BEQ.W	pt_SetupPaletteMode
	MOVEA.L	D0,A5
pt_1129:
	MOVE.B	(A3)+,(A5)+
	CMPA.L	A4,A3
	BLS.S	pt_1129
	BSR.W	pt_ProcessDiskRecord
	BSR.W	pt_ProcessDiskRecord
	JMP	pt_WaitMouseRelease
pt_CheckFileLock:
	MOVE.L	(dat_FileLockPtr,PC),D0
	BNE.S	pt_112B
	RTS
pt_112B:
	MOVEA.L	D0,A1
	MOVE.L	(dat_DiskOpBufState,PC),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_FileLockPtr
	RTS
dat_FileLockPtr:
	DS.L	1
dat_DiskOpBufState:
	DS.L	1
pt_BtnSmpPaste:
	CLR.B	dat_KeyCode
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.W	pt_10FA
	LEA	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.W	pt_SelectDiskMsg
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVEQ	#0,D2
	MOVE.L	(A0),D0
	BEQ.S	pt_112F
	MOVE.L	(124,A0),D2
pt_112F:
	MOVEA.L	D0,A2
	MOVE.L	(dat_FileLockPtr,PC),D3
	BEQ.W	pt_10FB
	MOVEA.L	D3,A3
	MOVE.L	(dat_DiskOpBufState,PC),D3
	BEQ.W	pt_10FB
	MOVE.L	D3,D4
	ADD.L	D2,D4
	CMP.L	#$0000fffe,D4
	BCS.S	pt_1130
	MOVE.L	#$0000fffe,D4
pt_1130:
	MOVE.L	D4,D0
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	TST.L	D0
	BEQ.W	pt_SetupPaletteMode
	MOVEA.L	D0,A4
	MOVEQ	#0,D0
	TST.L	D2
	BEQ.S	pt_1131
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
pt_1131:
	MOVE.L	D0,dat_DiskOpBufAddr
	MOVEA.L	A2,A1
	MOVE.L	D2,D1
	MOVEA.L	A4,A5
	MOVEA.L	A4,A0
	ADDA.L	D4,A0
	BRA.S	pt_1133
pt_1132:
	MOVE.B	(A2)+,(A4)+
	CMPA.L	A0,A4
	BCC.S	pt_AllocateSampleMem
	SUBQ.L	#1,D2
pt_1133:
	DBF	D0,pt_1132
	BRA.S	pt_1135
pt_1134:
	MOVE.B	(A3)+,(A4)+
	CMPA.L	A0,A4
	BCC.S	pt_AllocateSampleMem
pt_1135:
	DBF	D3,pt_1134
	TST.L	D2
	BEQ.S	pt_AllocateSampleMem
	BMI.S	pt_AllocateSampleMem
pt_1136:
	MOVE.B	(A2)+,(A4)+
	CMPA.L	A0,A4
	BCC.S	pt_AllocateSampleMem
	SUBQ.L	#1,D2
	BNE.S	pt_1136
pt_AllocateSampleMem:
	MOVE.L	D1,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	MOVE.W	(dat_CurrentSample,PC),D1
	LSL.W	#2,D1
	LEA	(dat_ModulePtr,PC),A0
	LEA	(0,A0,D1.W),A0
	MOVE.L	A5,(A0)
	MOVE.L	D4,(124,A0)
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	MULU	#s_SIZEOF,D1
	LEA	(12,A0,D1.W),A0
	LSR.L	#1,D4
	MOVE.W	D4,(A0)
	MOVE.L	(dat_DiskOpBufAddr,PC),dat_DiskOpBufSize
	BSR.W	pt_CheckDiskBufState
	BSR.W	pt_SampleClearLoop
	BSR.W	pt_DrawSampleHex
	BRA.W	pt_RecordModeHandler
pt_BtnSmpVolume:
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	LEA	(12409,A0),A0
	MOVEQ	#32,D3
pt_1139:
	MOVEQ	#16,D2
pt_113A:
	CLR.B	(A0)+
	DBF	D2,pt_113A
	LEA	(63,A0),A0
	DBF	D3,pt_1139
	LEA	dat_148E,A0
	LEA	dat_1468,A1
	MOVEQ	#1,D4
pt_113B:
	MOVEQ	#32,D3
pt_113C:
	MOVEQ	#16,D2
pt_113D:
	MOVE.B	(A1)+,(A0)+
	DBF	D2,pt_113D
	ADDQ.L	#1,A1
	LEA	(63,A0),A0
	DBF	D3,pt_113C
	LEA	(17840,A0),A0
	DBF	D4,pt_113B
	BSR.W	pt_AudioBufOffset
	JSR	pt_WaitMouseRelease
pt_DiskWaitLoop:
	JSR	pt_ScreenDragUpdate
	RMB
	BEQ.S	pt_DiskFormatMenu
	JSR	pt_GetKeypress
	MOVE.B	(dat_KeyCode,PC),D2
	CMP.B	#$44,D2
	BEQ.S	pt_DiskFormatMenu
	LMB
	BNE.S	pt_DiskWaitLoop
	MOVEM.W	dat_EditDigitValue,D0-D1
	CMP.W	#$0048,D0
	BCS.S	pt_DiskWaitLoop
	CMP.W	#$00d0,D0
	BCC.S	pt_DiskWaitLoop
	CMP.W	#$009b,D1
	BCS.S	pt_DiskWaitLoop
	CMP.W	#$00a6,D1
	BCS.S	pt_1143
	CMP.W	#$00b1,D1
	BCS.W	pt_114A
	CMP.W	#$00bc,D1
	BCS.W	pt_114D
	BRA.S	pt_DiskWaitLoop
pt_DiskFormatMenu:
	LEA	dat_148E,A0
	MOVEQ	#1,D2
pt_1140:
	MOVEQ	#32,D1
pt_1141:
	MOVEQ	#16,D0
pt_1142:
	CLR.B	(A0)+
	DBF	D0,pt_1142
	LEA	(63,A0),A0
	DBF	D1,pt_1141
	LEA	(17840,A0),A0
	DBF	D2,pt_1140
	BRA.W	pt_RecordCheckInput
pt_1143:
	CMP.W	#$00a7,D0
	BHI.S	pt_1148
	LEA	(dat_DiskOpStepSize,PC),A4
	MOVEQ	#0,D7
pt_WaitCIARelease:
	LMB
	BNE.W	pt_DiskWaitLoop
	MOVE.W	(dat_EditDigitValue,PC),D0
	CMP.W	D7,D0
	BEQ.S	pt_WaitCIARelease
	MOVE.W	D0,D7
	SUB.W	#$006b,D0
	BPL.S	pt_1145
	MOVEQ	#0,D0
pt_1145:
	CMP.W	#$003c,D0
	BLS.S	pt_1146
	MOVEQ	#60,D0
pt_1146:
	MULU	#$00c8,D0
	DIVU	#$003c,D0
	MOVE.W	D0,(A4)
pt_DiskStepCalc:
	BSR.W	pt_AudioBufOffset
	BRA.S	pt_WaitCIARelease
pt_1148:
	MOVE.W	#$00b4,dat_PlayCounter
	MOVE.W	#$00a4,dat_PatternDelay
	MOVE.W	#$3176,dat_TextBytePos
	JSR	pt_MarkPaletteDirty
	TSTPC.W	dat_PaletteDirtyFlag
	BNE.S	pt_DiskStepCalc
	CMP.W	#$00c8,D0
	BLS.S	pt_1149
	MOVE.W	#$00c8,D0
pt_1149:
	MOVE.W	D0,dat_DiskOpStepSize
	BRA.S	pt_DiskStepCalc
pt_114A:
	CMP.W	#$00a7,D0
	BHI.S	pt_114B
	LEA	(dat_DiskOpStepDelay,PC),A4
	MOVEQ	#0,D7
	BRA.S	pt_WaitCIARelease
pt_114B:
	MOVE.W	#$00b4,dat_PlayCounter
	MOVE.W	#$00af,dat_PatternDelay
	MOVE.W	#$34e6,dat_TextBytePos
	JSR	pt_MarkPaletteDirty
	TSTPC.W	dat_PaletteDirtyFlag
	BNE.S	pt_DiskStepCalc
	CMP.W	#$00c8,D0
	BLS.S	pt_114C
	MOVE.W	#$00c8,D0
pt_114C:
	MOVE.W	D0,dat_DiskOpStepDelay
	BRA.W	pt_DiskStepCalc
pt_114D:
	CMP.W	#$0064,D0
	BCS.W	pt_1157
	CMP.W	#$0090,D0
	BCS.W	pt_115E
	CMP.W	#$009a,D0
	BCS.S	pt_114E
	CMP.W	#$00a4,D0
	BCS.S	pt_114F
	CMP.W	#$00ae,D0
	BCS.S	pt_SetDiskStepSize
	BRA.W	pt_DiskFormatMenu
pt_114E:
	MOVE.W	#$0064,dat_DiskOpStepSize
	CLR.W	dat_DiskOpStepDelay
	BRA.S	pt_DiskInitSequence
pt_114F:
	CLR.W	dat_DiskOpStepSize
	MOVE.W	#$0064,dat_DiskOpStepDelay
	BRA.S	pt_DiskInitSequence
pt_SetDiskStepSize:
	MOVE.W	#$0064,dat_DiskOpStepSize
	MOVE.W	#$0064,dat_DiskOpStepDelay
pt_DiskInitSequence:
	BSR.S	pt_AudioBufOffset
	JSR	pt_WaitMouseRelease
	BRA.W	pt_DiskWaitLoop
pt_AudioBufOffset:
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	LEA	(12409,A0),A0
	MOVEQ	#21,D3
pt_1153:
	MOVEQ	#12,D2
pt_1154:
	CLR.B	(A0)+
	DBF	D2,pt_1154
	LEA	(67,A0),A0
	DBF	D3,pt_1153
	MOVEQ	#0,D4
	MOVE.W	(dat_DiskOpStepSize,PC),D4
	MOVEQ	#20,D5
	BSR.S	pt_1155
	MOVEQ	#0,D4
	MOVE.W	(dat_DiskOpStepDelay,PC),D4
	MOVEQ	#31,D5
	BSR.S	pt_1155
	MOVE.W	(dat_DiskOpStepSize,PC),dat_DisplayParam
	MOVE.W	#$3176,dat_TextBytePos
	BSR.W	pt_DrawTempoStr
	MOVE.W	(dat_DiskOpStepDelay,PC),dat_DisplayParam
	MOVE.W	#$34e6,dat_TextBytePos
	BRA.W	pt_DrawTempoStr
pt_1155:
	MOVE.W	D4,D6
	ADD.W	D4,D4
	ADD.W	D6,D4
	DIVU	#$000a,D4
	ADD.W	#$0069,D4
	MOVEQ	#2,D6
pt_1156:
	MOVE.W	D4,D0
	MOVE.W	D4,D2
	ADDQ.W	#5,D2
	MOVE.W	D5,D1
	MOVE.W	D5,D3
	BSR.W	pt_SaveRegsAndCalc
	ADDQ.W	#1,D5
	DBF	D6,pt_1156
	RTS
pt_1157:
	CLR.B	dat_KeyCode
	LEA	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.S	pt_115C
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVEQ	#0,D2
	MOVE.L	(A0),D0
	BEQ.S	pt_SelectDiskEject
	MOVEA.L	D0,A2
	MOVE.L	(124,A0),D2
	BEQ.S	pt_SelectDiskEject
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.S	pt_1158
	MOVE.L	(dat_DiskOpBufSize,PC),D1
	SUB.L	D0,D1
	BEQ.S	pt_1158
	ADDA.L	D0,A2
	MOVE.L	D1,D2
	ADDQ.L	#1,D2
pt_1158:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	D2,D5
	MOVEQ	#0,D3
pt_1159:
	MOVE.W	D3,D1
	MULU	(dat_DiskOpStepDelay,PC),D1
	DIVU	D2,D1
	MOVE.W	D2,D4
	SUB.W	D3,D4
	MULU	(dat_DiskOpStepSize,PC),D4
	DIVU	D2,D4
	ADD.W	D4,D1
	ADDQ.W	#1,D3
	MOVE.B	(A2),D0
	EXT.W	D0
	MULS	D1,D0
	DIVS	#$0064,D0
	CMP.W	#$007f,D0
	BLT.S	pt_115A
	MOVEQ	#127,D0
pt_115A:
	CMP.W	#$ff80,D0
	BGT.S	pt_115B
	MOVEQ	#-128,D0
pt_115B:
	MOVE.B	D0,(A2)+
	SUBQ.L	#1,D5
	BNE.S	pt_1159
	JSR	pt_RestorePalette
	BRA.W	pt_DiskFormatMenu
pt_115C:
	BSR.W	pt_SelectDiskMsg
	BRA.W	pt_DiskWaitLoop
pt_SelectDiskEject:
	BSR.W	pt_XpkLibErrorMsg
	BRA.W	pt_DiskWaitLoop
pt_115E:
	CLR.B	dat_KeyCode
	LEA	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.S	pt_115C
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVEQ	#0,D2
	MOVE.L	(A0),D0
	BEQ.S	pt_SelectDiskEject
	MOVEA.L	D0,A2
	MOVE.L	(124,A0),D2
	BEQ.S	pt_SelectDiskEject
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.S	pt_115F
	MOVE.L	(dat_DiskOpBufSize,PC),D1
	SUB.L	D0,D1
	BEQ.S	pt_115F
	ADDA.L	D0,A2
	MOVE.L	D1,D2
	ADDQ.L	#1,D2
pt_115F:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D0
pt_1160:
	MOVE.B	(A2)+,D1
	EXT.W	D1
	BPL.S	pt_1161
	NEG.W	D1
pt_1161:
	CMP.W	D0,D1
	BCS.S	pt_1162
	MOVE.W	D1,D0
pt_1162:
	SUBQ.L	#1,D2
	BNE.S	pt_1160
	JSR	pt_RestorePalette
	TST.W	D0
	BEQ.W	pt_SetDiskStepSize
	CMP.W	#$007f,D0
	BHI.W	pt_SetDiskStepSize
	CMP.W	#$0040,D0
	BCS.S	pt_1163
	MOVE.L	#$0000319c,D1
	DIVU	D0,D1
	MOVE.W	D1,dat_DiskOpStepSize
	MOVE.W	D1,dat_DiskOpStepDelay
	BRA.W	pt_DiskInitSequence
pt_1163:
	MOVE.W	#$00c8,dat_DiskOpStepSize
	MOVE.W	#$00c8,dat_DiskOpStepDelay
	BRA.W	pt_DiskInitSequence
dat_DiskOpStepSize:
	DC.W	$0064
dat_DiskOpStepDelay:
	DC.W	$0064
pt_BtnSmpTuneTone:
	JSR	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	TST.W	dat_DiskFormatVar
	BNE.W	pt_1168
	MOVE.W	#$0001,dat_DiskFormatVar
	MOVE.W	dat_CursorColumn,D2
	DIVU	#$0006,D2
	ADDQ.W	#1,D2
	AND.W	#$0003,D2
	MOVEQ	#1,D0
	LSL.W	D2,D0
	MOVE.W	D0,dat_116A
	LEA	AUD0LCH,A0
	LSL.W	#4,D2
	LEA	(0,A0,D2.W),A0
	LEA	(dat_PeriodTable,PC),A1
	MOVE.W	dat_DisplayLineCount,D1
	LSL.W	#1,D1
	MOVE.W	(0,A1,D1.W),D1
	MOVE.W	D0,D2
	LSL.W	#7,D2
	MOVE.W	D2,INTENA
	MOVE.W	D2,INTREQ
	MOVE.W	D0,DMACON
	MOVE.W	#$0001,(6,A0)
	CLR.W	(10,A0)
	MOVE.L	#dat_147B,(A0)
	MOVE.W	#$0010,(4,A0)
	MOVE.W	D1,(6,A0)
	MOVE.W	dat_PalEdEntryIdx,D1
	MULU	(dat_RpMasterVol,PC),D1
	ADD.L	#$00000020,D1
	LSR.L	#6,D1
	MOVE.W	D1,(8,A0)
pt_1167:
	MOVE.W	INTREQR,D1
	AND.W	D2,D1
	BEQ.S	pt_1167
	OR.W	#$8000,D0
	MOVE.W	D0,DMACON
	RTS
pt_1168:
	CLR.W	dat_DiskFormatVar
	MOVE.W	(dat_116A,PC),D0
	MOVE.W	D0,D2
	LSL.W	#7,D2
	MOVE.W	D2,INTENA
	MOVE.W	D0,DMACON
	RTS
dat_DiskFormatVar:
	DS.W	1
dat_116A:
	DS.W	1
pt_BtnSmpWaveArea:
	CMP.W	#$0090,D1
	BCC.S	pt_CheckDriveType
	MOVE.W	(dat_SpriteCtrlVar2,PC),D2
	BEQ.S	pt_116C
	SUBQ.W	#6,D2
	CMP.W	D2,D0
	BLT.S	pt_116C
	ADDQ.W	#8,D2
	CMP.W	D2,D0
	BCS.W	pt_1181
pt_116C:
	MOVE.W	(dat_SpriteCtrlVar3,PC),D2
	BEQ.S	pt_CheckDriveType
	SUBQ.W	#6,D2
	CMP.W	D2,D0
	BLT.S	pt_CheckDriveType
	ADDQ.W	#8,D2
	CMP.W	D2,D0
	BCS.W	pt_1189
pt_CheckDriveType:
	CMP.W	#$0003,D0
	BCC.S	pt_116E
	RTS
pt_116E:
	CMP.W	#$027d,D0
	BCS.S	pt_116F
	RTS
pt_116F:
	MOVE.W	D0,dat_RecordBufState
	BSR.W	pt_ProcessDiskRecord
	MOVE.W	(dat_RecordBufState,PC),D0
	MOVE.W	D0,dat_RecordBufAddr
	MOVE.W	D0,dat_DiskOpListLen
	MOVE.W	D0,dat_SpriteRenderFlag
	BSR.W	pt_CheckSpriteRender
	BSR.W	pt_GetDiskBufLen
	MOVE.L	(dat_DiskOpBufSize,PC),dat_SampleEditOffset
	BSR.W	pt_CheckEditModeType
	JSR	pt_ClearSpriteRender
	MOVE.L	#$0000ffff,dat_SpriteRenderPtr
pt_1170:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_1174
	MOVE.W	(dat_EditDigitValue,PC),D0
	CMP.W	#$0003,D0
	BCS.S	pt_1172
	CMP.W	#$027d,D0
	BCC.S	pt_1171
	BRA.S	pt_1173
pt_1171:
	MOVE.W	#$027c,D0
	BRA.S	pt_1173
pt_1172:
	MOVEQ	#3,D0
pt_1173:
	CMP.W	(dat_RecordBufState,PC),D0
	BEQ.S	pt_1170
	MOVE.W	D0,dat_RecordBufState
	BSR.S	pt_CheckSpriteRender
	MOVE.W	(dat_RecordBufState,PC),dat_DiskOpListLen
	BSR.S	pt_CheckSpriteRender
	BSR.W	pt_GetDiskBufLen
	MOVE.L	(dat_DiskOpBufSize,PC),dat_SampleEditOffset
	BSR.W	pt_CheckEditModeType
	BRA.S	pt_1170
pt_1174:
	MOVE.W	(dat_RecordBufAddr,PC),D0
	MOVE.W	(dat_DiskOpListLen,PC),D1
	CMP.W	D0,D1
	BCC.W	pt_GetDiskBufLen
	MOVE.W	D0,dat_DiskOpListLen
	MOVE.W	D1,dat_RecordBufAddr
	BRA.W	pt_GetDiskBufLen
pt_ProcessDiskRecord:
	TST.L	dat_SpriteRenderPtr
	BNE.S	pt_ClearSpriteRender
	MOVE.W	(dat_RecordBufAddr,PC),D0
	BNE.S	pt_1176
	RTS
pt_1176:
	MOVE.W	(dat_DiskOpListLen,PC),D2
	MOVEQ	#0,D1
	MOVEQ	#64,D3
	CMP.W	D0,D2
	BPL.S	pt_1177
	EXG	D0,D2
pt_1177:
	BRA.W	pt_SaveRegsDisplay
pt_CheckSpriteRender:
	TST.L	dat_SpriteRenderPtr
	BEQ.S	pt_1179
	BSR.S	pt_ClearSpriteRender
pt_1179:
	MOVE.W	(dat_RecordBufAddr,PC),D4
	BNE.S	pt_117A
	RTS
pt_117A:
	MOVE.W	(dat_SpriteRenderFlag,PC),D0
	MOVE.W	(dat_DiskOpListLen,PC),D2
	MOVE.W	D2,dat_SpriteRenderFlag
	MOVEQ	#0,D1
	MOVEQ	#64,D3
	CMP.W	D0,D2
	BPL.S	pt_117B
	EXG	D0,D2
pt_117B:
	BRA.W	pt_SaveRegsDisplay
pt_ClearSpriteRender:
	CLR.L	dat_SpriteRenderPtr
	MOVEQ	#0,D1
	MOVEQ	#64,D3
	MOVE.W	(dat_RecordBufAddr,PC),D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D2
	BRA.W	pt_SaveRegsDisplay
dat_SpriteRenderFlag:
	DS.W	1
dat_SpriteRenderPtr:
	DS.L	1
dat_SpriteCtrlVar2:
	DS.W	1
dat_SpriteCtrlVar3:
	DS.W	1
pt_1181:
	CLR.W	dat_SpriteCtrlVar
pt_1182:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D0
	BNE.S	pt_1183
	RTS
pt_1183:
	MULU	#s_SIZEOF,D0
	LEA	(12,A0,D0.W),A0
	MOVE.W	(dat_EditDigitValue,PC),D0
pt_1184:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_1188
	MOVE.W	(dat_EditDigitValue,PC),D1
	CMP.W	D0,D1
	BEQ.S	pt_1184
	SUB.W	dat_SpriteCtrlVar,D1
	BPL.S	pt_1185
	MOVEQ	#0,D1
pt_1185:
	CMP.W	#$027a,D1
	BCS.S	pt_1186
	MOVE.W	#$027a,D1
pt_1186:
	MOVE.L	(dat_DiskBufLen,PC),D0
	MULU	D0,D1
	DIVU	#$027a,D1
	AND.L	#$0000ffff,D1
	MOVE.L	(dat_DiskBufAddr,PC),D0
	ADD.W	D1,D0
	BCLR	#0,D0
	MOVEQ	#0,D1
	MOVE.W	(4,A0),D1
	ADD.W	D1,D1
	TST.W	dat_SpriteCtrlVar
	BNE.S	pt_118A
	MOVE.W	D1,D3
	SUB.W	D1,D0
	ADD.W	D0,D1
	MOVE.W	(6,A0),D2
	ADD.W	D2,D2
	ADD.W	D2,D3
	SUBQ.W	#2,D3
	SUB.W	D0,D2
	CMP.W	D3,D1
	BLS.S	pt_CalcSpritePos
	MOVE.W	D3,D1
	MOVEQ	#2,D2
pt_CalcSpritePos:
	LSR.W	#1,D1
	MOVE.W	D1,(4,A0)
	LSR.W	#1,D2
	MOVE.W	D2,(6,A0)
	BSR.S	pt_1188
	BRA.W	pt_1182
pt_1188:
	BSR.W	pt_DrawSampleHex
	JSR	pt_InitChannelPlay
	BSR.W	dat_11EC
	RTS
pt_1189:
	MOVE.W	#$0003,dat_SpriteCtrlVar
	BRA.W	pt_1182
pt_118A:
	MOVE.L	D0,D2
	SUB.L	D1,D2
	CMP.L	#$00000002,D2
	BGT.S	pt_118B
	MOVEQ	#2,D2
	BRA.S	pt_CalcSpritePos
pt_118B:
	MOVE.W	D1,D0
	ADD.W	D2,D0
	MOVE.W	(A0),D3
	ADD.W	D3,D3
	CMP.W	D3,D0
	BLS.S	pt_CalcSpritePos
	SUB.W	D1,D3
	MOVE.W	D3,D2
	BRA.S	pt_CalcSpritePos
dat_SpriteCtrlVar:
	DS.W	1
pt_BtnSmpRangeBar:
	CMP.W	(dat_DiskOpCountVar,PC),D0
	BCS.S	pt_1192
	CMP.W	(dat_11D2,PC),D0
	BHI.W	pt_1197
	MOVE.W	(dat_EditDigitValue,PC),D0
	MOVE.W	D0,D1
	SUB.W	(dat_DiskOpCountVar,PC),D1
	MOVE.W	D1,dat_1198
pt_118E:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.W	dat_11AB
	MOVE.W	(dat_EditDigitValue,PC),D1
	CMP.W	D0,D1
	BEQ.S	pt_118E
	SUB.W	(dat_1198,PC),D0
	SUBQ.W	#4,D0
	BPL.S	pt_118F
	MOVEQ	#0,D0
pt_118F:
	MOVE.L	(dat_DiskOpFileSize,PC),D1
	BNE.S	pt_1190
	RTS
pt_1190:
	MULU	D1,D0
	DIVU	#$0277,D0
	AND.L	#$0000ffff,D0
	BSR.S	pt_1191
	MOVE.W	(dat_EditDigitValue,PC),D0
	BRA.S	pt_118E
pt_1191:
	MOVE.L	D0,D1
	ADD.L	(dat_DiskBufLen,PC),D1
	CMP.L	(dat_DiskOpFileSize,PC),D1
	BLS.S	pt_1193
	MOVE.L	(dat_DiskOpFileSize,PC),D0
	SUB.L	(dat_DiskBufLen,PC),D0
	BRA.S	pt_1193
pt_1192:
	MOVE.L	(dat_DiskBufAddr,PC),D0
	SUB.L	(dat_DiskBufLen,PC),D0
	BPL.S	pt_CheckDiskBufAddr
	MOVEQ	#0,D0
pt_1193:
	CMP.L	(dat_DiskBufAddr,PC),D0
	BNE.S	pt_1194
	RTS
pt_1194:
	MOVE.L	D0,dat_DiskBufAddr
	BRA.W	dat_11BD
pt_CheckDiskBufAddr:
	CMP.L	(dat_DiskBufAddr,PC),D0
	BNE.S	pt_1196
	RTS
pt_1196:
	MOVE.L	D0,dat_DiskBufAddr
	BRA.W	pt_RecordCheckInput
pt_1197:
	MOVE.L	(dat_DiskBufAddr,PC),D0
	ADD.L	(dat_DiskBufLen,PC),D0
	MOVE.L	D0,D1
	ADD.L	(dat_DiskBufLen,PC),D1
	CMP.L	(dat_DiskOpFileSize,PC),D1
	BLS.S	pt_CheckDiskBufAddr
	MOVE.L	(dat_DiskOpFileSize,PC),D0
	SUB.L	(dat_DiskBufLen,PC),D0
	BRA.S	pt_CheckDiskBufAddr
dat_1198:
	DS.W	1
pt_GetDiskBufLen:
	MOVE.L	(dat_DiskBufLen,PC),D0
	MOVEQ	#0,D1
	MOVE.W	(dat_RecordBufAddr,PC),D1
	BNE.S	pt_119A
	RTS
pt_119A:
	SUBQ.W	#3,D1
	MULU	D0,D1
	DIVU	#$027a,D1
	AND.L	#$0000ffff,D1
	ADD.L	(dat_DiskBufAddr,PC),D1
	MOVE.L	D1,dat_DiskOpBufAddr
	MOVE.W	(dat_DiskOpListLen,PC),D1
	CMP.W	#$027c,D1
	BCS.S	pt_119B
	MOVE.L	(dat_DiskBufAddr,PC),D1
	ADD.L	D0,D1
	BRA.S	pt_119C
pt_119B:
	SUBQ.W	#3,D1
	MULU	D0,D1
	DIVU	#$027a,D1
	AND.L	#$0000ffff,D1
	ADD.L	(dat_DiskBufAddr,PC),D1
pt_119C:
	MOVE.L	D1,dat_DiskOpBufSize
	RTS
pt_CheckDiskBufState:
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.S	pt_ClearRecordBuf
	MOVE.W	#$0003,dat_RecordBufAddr
	SUB.L	(dat_DiskBufAddr,PC),D0
	BMI.S	pt_119E
	MULU	#$027a,D0
	MOVE.L	(dat_DiskBufLen,PC),D1
	BEQ.S	pt_119E
	DIVU	D1,D0
	CMP.W	#$027a,D0
	BHI.S	pt_ClearRecordBuf
	ADD.W	D0,dat_RecordBufAddr
pt_119E:
	MOVE.W	#$0003,dat_DiskOpListLen
	MOVE.L	(dat_DiskOpBufSize,PC),D0
	SUB.L	(dat_DiskBufAddr,PC),D0
	BMI.S	pt_ClearRecordBuf
	MULU	#$027a,D0
	MOVE.L	(dat_DiskBufLen,PC),D1
	BNE.S	pt_119F
	RTS
pt_119F:
	DIVU	D1,D0
	CMP.W	#$0279,D0
	BLS.S	pt_11A0
	MOVE.W	#$0279,D0
pt_11A0:
	ADD.W	D0,dat_DiskOpListLen
	RTS
pt_ClearRecordBuf:
	CLR.W	dat_RecordBufAddr
	RTS
dat_SamplerActive:
	DS.L	2
	DS.W	1
dat_RecordBufState:
	DS.W	1
dat_RecordBufAddr:
	DS.W	1
dat_DiskOpListLen:
	DS.W	1
dat_DiskOpBufAddr:
	DS.L	1
dat_DiskOpBufSize:
	DS.L	1
pt_RecordCheckInput:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_RecordProcessKey
	RTS
pt_RecordProcessKey:
	BSR.W	pt_11B3
	TSTPC.L	dat_DiskOpBufAddr
	BPL.S	pt_11AA
	RTS
pt_11AA:
	BSR.W	pt_CheckDiskBufState
	BRA.W	pt_ProcessDiskRecord
dat_11AB:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_11AC
	RTS
pt_11AC:
	BSR.W	pt_ProcessDiskRecord
	BSR.S	pt_11AE
	TSTPC.L	dat_DiskOpBufAddr
	BPL.S	pt_11AD
	RTS
pt_11AD:
	BSR.W	pt_CheckDiskBufState
	BRA.W	pt_ProcessDiskRecord
pt_11AE:
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	BRA.W	pt_11B4
pt_RecordModeHandler:
	TST.W	dat_RecordMode
	BNE.S	dat_11B0
	CLR.B	dat_KeyCode
dat_11B0:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_11B1
	RTS
pt_11B1:
	MOVEQ	#-1,D0
	MOVE.L	D0,dat_DiskOpBufAddr
	CLR.W	dat_RecordBufAddr
	MOVE.W	(dat_CurrentSample,PC),D0
	BEQ.S	pt_InitScopeDisplay
	LEA	(dat_RpSampleStarts,PC),A1
	SUBQ.W	#1,D0
	LSL.W	#2,D0
	MOVE.L	(0,A1,D0.W),dat_DiskOpFilesPtr
	BEQ.S	pt_InitScopeDisplay
	MOVE.L	(124,A1,D0.W),D1
	BEQ.S	pt_InitScopeDisplay
	MOVE.L	D1,dat_DiskOpFileSize
	CLR.L	dat_DiskBufAddr
	MOVE.L	D1,dat_DiskBufLen
	BRA.S	pt_11B3
pt_InitScopeDisplay:
	LEA	dat_ScopeDisplayBuf,A0
	MOVE.L	A0,dat_DiskOpFilesPtr
	MOVE.L	#$0000027a,dat_DiskOpFileSize
	CLR.L	dat_DiskBufAddr
	MOVE.L	#$0000027a,dat_DiskBufLen
pt_11B3:
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	BSR.W	pt_10DE
pt_11B4:
	MOVEA.L	(dat_DiskOpFilesPtr,PC),A0
	MOVEQ	#0,D4
	MOVEA.L	#$ffffffff,A2
	MOVE.L	(dat_DiskBufAddr,PC),D5
	MOVE.L	(dat_DiskBufLen,PC),D6
	LEA	(0,A0,D5.L),A0
	MOVE.L	A0,D0
	MOVE.L	D0,dat_ScopeDisplay1
	ADD.L	D6,D0
	MOVE.L	D0,dat_ScopeDisplay2
	MOVEQ	#3,D0
	MOVEQ	#127,D1
	SUB.B	(A0),D1
	LSR.W	#2,D1
	MOVE.W	D0,dat_SpriteCoordX
	MOVE.W	D1,dat_SpriteCoordY
	CMP.L	#$0000027a,D6
	BLT.S	pt_11B7
	DIVU	#$027a,D6
	MOVE.L	D6,D5
	SWAP	D5
	MOVE.W	#$013d,D7
	MOVEQ	#0,D4
pt_11B5:
	MOVE.W	D4,D0
	ADDQ.W	#3,D0
	MOVEQ	#127,D1
	SUB.B	(A0),D1
	LSR.W	#2,D1
	BSR.W	pt_LoadSpriteCoords
	ADDQ.W	#1,D4
	LEA	(0,A0,D6.W),A0
	SUB.W	D5,D7
	BGE.S	pt_11B6
	ADD.W	#$027a,D7
	ADDQ.L	#1,A0
pt_11B6:
	CMP.W	#$027a,D4
	BCS.S	pt_11B5
	BRA.S	pt_11BA
pt_11B7:
	MOVE.L	#$0000027a,D7
	DIVU	D6,D7
	MOVE.L	D7,D5
	SWAP	D5
	MOVE.W	D6,dat_11CC
	LSR.W	#1,D6
	MOVEQ	#0,D4
pt_11B8:
	MOVE.W	D4,D0
	ADDQ.W	#3,D0
	MOVEQ	#127,D1
	SUB.B	(A0),D1
	LSR.W	#2,D1
	BSR.W	pt_LoadSpriteCoords
	ADD.W	D7,D4
	LEA	(1,A0),A0
	SUB.W	D5,D6
	BGE.S	pt_11B9
	ADD.W	(dat_11CC,PC),D6
	ADDQ.W	#1,D4
pt_11B9:
	CMP.W	#$027a,D4
	BCS.S	pt_11B8
	MOVE.W	#$027c,D0
	MOVEQ	#127,D1
	SUB.B	(-1,A0),D1
	LSR.W	#2,D1
	BSR.W	pt_LoadSpriteCoords
pt_11BA:
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-462,A6)
	BSR.W	pt_11CD
	BSR.S	pt_11BB
	BSR.W	pt_CheckEditModeType
	BRA.W	pt_11EB
pt_11BB:
	MOVE.L	(dat_DiskBufLen,PC),D2
	LEA	dat_ScopeDisplayBuf,A0
	CMPA.L	dat_DiskOpFilesPtr,A0
	BNE.S	pt_11BC
	MOVEQ	#0,D2
pt_11BC:
	MOVE.W	#$01a8,D0
	MOVE.W	#$00d7,D1
	MOVEQ	#7,D3
	BRA.W	pt_BlitPatternSetup
dat_11BD:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_11BE
	RTS
pt_11BE:
	BSR.S	pt_11C0
	TSTPC.L	dat_DiskOpBufAddr
	BPL.S	pt_11BF
	RTS
pt_11BF:
	BSR.W	pt_CheckDiskBufState
	BRA.W	pt_ProcessDiskRecord
pt_11C0:
	BSR.W	pt_10E0
	MOVEA.L	(dat_DiskOpFilesPtr,PC),A0
	MOVEQ	#0,D4
	MOVEQ	#-1,D2
	MOVE.L	(dat_DiskBufAddr,PC),D5
	MOVE.L	(dat_DiskBufLen,PC),D6
	LEA	(0,A0,D5.L),A0
	MOVE.L	A0,D0
	MOVE.L	D0,dat_ScopeDisplay1
	ADD.L	D6,D0
	MOVE.L	D0,dat_ScopeDisplay2
	CMP.L	#$0000027a,D6
	BLT.S	pt_11C3
	DIVU	#$027a,D6
	MOVE.L	D6,D5
	SWAP	D5
	MOVE.W	#$013d,D7
	MOVEQ	#0,D4
pt_11C1:
	MOVE.W	D4,D0
	ADDQ.W	#3,D0
	MOVEQ	#127,D1
	SUB.B	(A0),D1
	LSR.W	#2,D1
	MOVEA.L	(dat_AudioPlayBufPtr,PC),A1
	MOVE.W	D1,D2
	LSL.W	#4,D2
	LSL.W	#6,D1
	ADD.W	D2,D1
	LEA	(0,A1,D1.W),A1
	MOVE.W	D0,D1
	ASR.W	#3,D1
	EORI.B	#$07,D0
	BSET	D0,(0,A1,D1.W)
	ADDQ.W	#1,D4
	LEA	(0,A0,D6.W),A0
	SUB.W	D5,D7
	BGE.S	pt_11C2
	ADD.W	#$027a,D7
	ADDQ.L	#1,A0
pt_11C2:
	CMP.W	#$027a,D4
	BCS.S	pt_11C1
	BRA.S	pt_11C6
pt_11C3:
	MOVE.L	#$0000027a,D7
	DIVU	D6,D7
	MOVE.L	D7,D5
	SWAP	D5
	MOVE.W	D6,dat_11CB
	LSR.W	#1,D6
	MOVEQ	#0,D4
pt_11C4:
	MOVE.W	D4,D0
	ADDQ.W	#3,D0
	MOVEQ	#127,D1
	SUB.B	(A0),D1
	LSR.W	#2,D1
	MOVEA.L	(dat_AudioPlayBufPtr,PC),A1
	MOVE.W	D1,D2
	LSL.W	#4,D2
	LSL.W	#6,D1
	ADD.W	D2,D1
	LEA	(0,A1,D1.L),A1
	MOVE.W	D0,D1
	ASR.W	#3,D1
	EORI.B	#$07,D0
	BSET	D0,(0,A1,D1.W)
	ADD.W	D7,D4
	LEA	(1,A0),A0
	SUB.W	D5,D6
	BGE.S	pt_11C5
	ADD.W	(dat_11CB,PC),D6
	ADDQ.W	#1,D4
pt_11C5:
	CMP.W	#$027a,D4
	BCS.S	pt_11C4
pt_11C6:
	BSR.S	pt_11CD
	BSR.W	pt_11BB
	BSR.W	pt_CheckEditModeType
	BRA.W	pt_11EB
dat_DiskOpFilesPtr:
	DS.L	1
dat_DiskOpFileSize:
	DS.L	1
dat_DiskBufAddr:
	DS.L	1
dat_DiskBufLen:
	DS.L	1
	DS.W	1
dat_11CB:
	DS.W	1
dat_11CC:
	DS.W	1
pt_11CD:
	MOVE.W	#$004f,D0
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(16560,A0),A0
	MOVEQ	#0,D1
pt_11CE:
	MOVE.L	D1,(A0)+
	DBF	D0,pt_11CE
	MOVE.L	(dat_DiskOpFileSize,PC),D0
	BNE.S	pt_11CF
	RTS
pt_11CF:
	MOVE.L	(dat_DiskBufAddr,PC),D4
	MOVE.L	(dat_DiskBufLen,PC),D5
	CMP.L	D0,D5
	BNE.S	pt_11D0
	RTS
pt_11D0:
	ADD.L	D4,D5
	MULU	#$0277,D4
	DIVU	D0,D4
	ADDQ.W	#4,D4
	MOVE.W	D4,dat_DiskOpCountVar
	MULU	#$0277,D5
	DIVU	D0,D5
	ADDQ.W	#5,D5
	MOVE.W	D5,dat_11D2
	MOVE.W	D4,D0
	MOVE.W	D5,D2
	MOVEQ	#68,D1
	MOVEQ	#72,D3
	MOVEQ	#1,D5
	BRA.W	pt_0FA0
dat_DiskOpCountVar:
	DS.W	1
dat_11D2:
	DS.W	1
pt_11D3:
	MOVEM.L	D0-D1/A0,-(A7)
	LEA	SECSTRT_2,A0
	MULU	#$0050,D1
	LEA	(0,A0,D1.L),A0
	MOVE.W	D0,D1
	EORI.B	#$07,D0
	LSR.W	#3,D1
	LEA	(0,A0,D1.W),A0
	MOVEQ	#0,D1
pt_11D4:
	BTST	D1,D5
	BNE.S	pt_11D5
	BCLR	D0,(A0)
	BRA.S	pt_11D6
pt_11D5:
	BSET	D0,(A0)
pt_11D6:
	LEA	(20480,A0),A0
	ADDQ.W	#1,D1
	CMP.W	#$0002,D1
	BCS.S	pt_11D4
	MOVEM.L	(A7)+,D0-D1/A0
	RTS
pt_11D7:
	MOVE.L	(dat_AudioPlayBufPtr,PC),-(A7)
	MOVE.L	#SECSTRT_2,dat_AudioPlayBufPtr
	MOVEQ	#0,D4
pt_11D8:
	MOVE.B	#$ca,dat_CursorColorVal
	BTST	D4,D5
	BNE.S	pt_11D9
	MOVE.B	#$0a,dat_CursorColorVal
pt_11D9:
	BSR.S	pt_SaveRegsAndCalc
	ADDI.L	#$00005000,dat_AudioPlayBufPtr
	ADDQ.W	#1,D4
	CMP.W	#$0002,D4
	BCS.S	pt_11D8
	MOVE.B	#$c8,dat_CursorColorVal
	MOVE.L	(A7)+,dat_AudioPlayBufPtr
	RTS
pt_LoadSpriteCoords:
	MOVE.W	(dat_SpriteCoordX,PC),D2
	MOVE.W	(dat_SpriteCoordY,PC),D3
	MOVE.W	D0,dat_SpriteCoordX
	MOVE.W	D1,dat_SpriteCoordY
	CMP.W	D0,D2
	BNE.S	pt_SaveRegsAndCalc
	CMP.W	D1,D3
	BEQ.W	pt_11E4
pt_SaveRegsAndCalc:
	MOVEM.L	D4-D7/A0,-(A7)
	MOVEQ	#0,D4
	SUB.W	D1,D3
	BGE.S	pt_11DC
	NEG.W	D3
	BRA.S	pt_11DD
pt_11DC:
	BSET	#0,D4
pt_11DD:
	SUB.W	D0,D2
	BGE.S	pt_11DE
	NEG.W	D2
	BRA.S	pt_11DF
pt_11DE:
	BSET	#1,D4
pt_11DF:
	MOVE.W	D2,D5
	SUB.W	D3,D5
	BGE.S	pt_11E0
	EXG	D2,D3
	BRA.S	pt_11E1
pt_11E0:
	BSET	#2,D4
pt_11E1:
	MOVEQ	#0,D5
	ROR.W	#4,D0
	OR.W	#$0b00,D0
	MOVE.B	D0,D5
	MOVE.B	(dat_CursorColorVal,PC),D0
	LSL.W	#1,D5
	MULS	#$0050,D1
	ADD.W	D5,D1
	ADD.L	(dat_AudioPlayBufPtr,PC),D1
pt_11E2:
	BTST	#6,DMACONR
	BNE.S	pt_11E2
	MOVE.W	#$4000,INTENA
	MOVE.B	(dat_11E5,PC,D4.W),D4
	ADD.L	D3,D3
	MOVE.W	D3,BLTBMOD
	SUB.W	D2,D3
	BGE.S	pt_11E3
	OR.B	#$40,D4
pt_11E3:
	MOVE.L	D3,BLTAPTH
	SUB.W	D2,D3
	MOVE.W	D3,BLTAMOD
	MOVE.W	D4,BLTCON1
	MOVE.W	D0,BLTCON0
	MOVE.L	D1,BLTCPTH
	MOVE.L	D1,BLTDPTH
	MOVE.W	#$0050,BLTCMOD
	MOVE.W	#$0050,BLTDMOD
	MOVE.W	#$8000,BLTADAT
	MOVE.W	#$ffff,BLTAFWM
	MOVE.W	(dat_11E6,PC),BLTBDAT
	ASL.W	#6,D2
	ADDQ.W	#2,D2
	MOVE.W	D2,BLTSIZE
	MOVE.W	#$c000,INTENA
	MOVEM.L	(A7)+,D4-D7/A0
pt_11E4:
	RTS
dat_11E5:
	DC.L	$0d090501,$1d151911
dat_11E6:
	DC.W	$ffff
dat_CursorColorVal:
	DC.W	$c800
dat_SpriteCoordX:
	DS.W	1
dat_SpriteCoordY:
	DS.W	1
dat_AudioPlayBufPtr:
	DS.L	1
pt_11EB:
	MOVEQ	#-1,D6
	MOVEQ	#-1,D7
	MOVE.W	(dat_CurrentSample,PC),D0
	BEQ.S	pt_DrawCursorSprite
	MULU	#s_SIZEOF,D0
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(12,A0,D0.W),A0
dat_11EC:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_11ED
	RTS
pt_11ED:
	CLR.W	dat_DiskDisplayCtrl
	MOVEQ	#-1,D6
	MOVEQ	#-1,D7
	MOVEQ	#0,D0
	MOVE.W	(4,A0),D0
	ADD.L	D0,D0
	MOVEQ	#0,D1
	MOVE.W	(6,A0),D1
	ADD.L	D1,D1
	MOVE.L	D0,D5
	ADD.L	D1,D5
	CMP.W	#$0002,D5
	BLS.S	pt_DrawCursorSprite
	MOVE.W	#$0001,dat_DiskDisplayCtrl
	MOVE.L	(dat_DiskBufAddr,PC),D2
	MOVE.L	(dat_DiskBufLen,PC),D3
	MOVE.L	D2,D4
	ADD.L	D3,D4
	CMP.L	D2,D0
	BCS.S	pt_11EE
	CMP.L	D4,D0
	BHI.S	pt_11EE
	SUB.L	D2,D0
	MULU	#$027a,D0
	DIVU	D3,D0
	ADDQ.W	#3,D0
	MOVE.W	D0,D6
pt_11EE:
	CMP.L	D2,D5
	BCS.S	pt_DrawCursorSprite
	CMP.L	D4,D5
	BHI.S	pt_DrawCursorSprite
	SUB.L	D2,D5
	MULU	#$027a,D5
	DIVU	D3,D5
	ADDQ.W	#6,D5
	MOVE.W	D5,D7
pt_DrawCursorSprite:
	MOVE.W	#$008b,D1
	MOVE.W	D6,D0
	BPL.S	pt_11F0
	MOVEQ	#0,D0
	MOVE.W	#$010e,D1
pt_11F0:
	MOVEQ	#64,D2
	LEA	chip_BorderLeft,A0
	MOVE.W	D0,dat_SpriteCtrlVar2
	LSR.W	#1,D0
	BSR.W	pt_DrawSprite
	MOVE.W	#$008b,D1
	MOVE.W	D7,D0
	BPL.S	pt_11F1
	MOVEQ	#0,D0
	MOVE.W	#$010e,D1
pt_11F1:
	MOVEQ	#64,D2
	LEA	chip_BorderCenter,A0
	MOVE.W	D0,dat_SpriteCtrlVar3
	LSR.W	#1,D0
	BSR.W	pt_DrawSprite
	BRA.W	pt_110A
pt_DrawBorderLeft:
	LEA	chip_BorderLeft,A0
	MOVE.W	(dat_SpriteCtrlVar2,PC),D0
	LSR.W	#1,D0
	ADDQ.W	#1,D0
	TSTPC.W	dat_DiskDisplayCtrl
	BNE.S	pt_11F3
	MOVEQ	#-32,D0
pt_11F3:
	MOVE.W	#$008b,D1
	MOVEQ	#64,D2
	BSR.W	pt_DrawSprite
	LEA	chip_BorderCenter,A0
	MOVE.W	(dat_SpriteCtrlVar3,PC),D0
	LSR.W	#1,D0
	ADDQ.W	#1,D0
	TSTPC.W	dat_DiskDisplayCtrl
	BNE.S	pt_11F4
	MOVEQ	#-32,D0
pt_11F4:
	MOVE.W	#$008b,D1
	MOVEQ	#64,D2
	BSR.W	pt_DrawSprite
	RTS
dat_SpriteYCoord1:
	DS.L	1
dat_CursorRenderPtr:
	DS.L	1
dat_BorderSizeH:
	DC.W	$0018
dat_BorderSizeV:
	DC.W	$0018
dat_BorderConfig1:
	DC.W	$0018
dat_11FA:
	DS.W	1
dat_11FB:
	DS.W	1
pt_11FC:
	LEA	dat_1533,A0
	MOVE.W	#$017b,D0
	MOVEQ	#0,D1
pt_11FD:
	MOVE.W	D1,(A0)+
	DBF	D0,pt_11FD
	RTS
pt_BtnSmpSampleNext:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_11FF
	RTS
pt_11FF:
	CLR.B	dat_KeyCode
	MOVE.W	(dat_DiskDisplayCtrl,PC),-(A7)
	CLR.W	dat_DiskDisplayCtrl
	BSR.W	pt_DrawBorderLeft
	JSR	pt_BtnMainStop
	JSR	pt_EditModeDispatcher
	JSR	pt_WaitMouseRelease
	JSR	pt_SetPaletteSong
	BSR.W	pt_120B
	JSR	pt_RefreshDisplay
	BSR.S	pt_11FC
	BSR.W	pt_120D
	MOVE.W	INTENAR,dat_11FA
	MOVE.W	#$7fff,INTENA
	JSR	pt_StopAllAudio
	MOVE.W	(dat_BorderSizeH,PC),D0
	ASL.W	#1,D0
	LEA	dat_PeriodTable,A0
	MOVE.W	(0,A0,D0.W),D0
	LSR.W	#1,D0
	LEA	HARDBASE,A0
	LEA	(170,A0),A5
	LEA	(186,A0),A6
	MOVE.W	D0,(166,A0)
	MOVE.W	D0,(182,A0)
	MOVEQ	#32,D0
	MULU	(dat_RpMasterVol,PC),D0
	ADD.L	#$00000020,D0
	LSR.L	#6,D0
	MOVE.W	D0,(168,A0)
	MOVE.W	D0,(184,A0)
	MOVEQ	#0,D0
	MOVE.W	D0,(A5)
	MOVE.W	D0,(A6)
	MOVE.B	#$06,CIAB_DDRA
	MOVEQ	#2,D0
	MOVE.B	D0,CIAB_PRA
	CLR.B	CIAA_DDRB
	LEA	(dat_1219,PC),A0
	LEA	dat_1533,A1
	MOVEA.L	dat_ScreenBuf2Ptr,A2
	LEA	(12830,A2),A2
	LEA	CIAA_PRB,A3
	LEA	INTREQR,A4
	MOVE.W	#$0180,D7
	MOVEQ	#6,D6
	MOVEQ	#10,D3
pt_1200:
	MOVEQ	#22,D5
pt_1201:
	MOVEQ	#7,D4
pt_1202:
	BTST	D7,(A4)
	BEQ.S	pt_1202
	MOVE.W	D7,(126,A4)
	MOVEQ	#0,D0
	MOVE.B	(A3),D0
	MOVE.W	D0,D1
	SUB.B	D7,D0
	MOVE.B	D0,(A5)
	MOVE.B	D0,(A6)
	LSR.W	#3,D1
	ADD.W	D1,D1
	MOVE.W	(0,A0,D1.W),D0
	MOVE.W	(A1),D1
	MOVE.W	D0,(A1)+
	BCLR	D4,(0,A2,D1.W)
	BSET	D4,(0,A2,D0.W)
	DBF	D4,pt_1202
	ADDQ.L	#1,A2
	DBF	D5,pt_1201
	SUBA.W	#$0017,A2
	SUBA.W	#$0170,A1
	JSR	pt_SmpMonExit41
	NOP
	BTST	D3,(-8,A4)
	BNE.S	pt_1200
	MOVE.W	(dat_CurrentSample,PC),D1
	BEQ.W	pt_ResetIntFlag
	LSL.W	#2,D1
	LEA	dat_ModulePtr,A0
	MOVE.L	(0,A0,D1.W),D0
	BEQ.S	pt_1203
	CLR.L	(0,A0,D1.W)
	MOVEA.L	D0,A1
	MOVE.L	(124,A0,D1.W),D0
	BEQ.S	pt_1203
	CLR.L	(124,A0,D1.W)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_1203:
	MOVE.L	#$0000fffe,D6
pt_1204:
	MOVE.L	D6,D0
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	TST.L	D0
	BNE.S	pt_1205
	SUB.L	#$00000800,D6
	BPL.S	pt_1204
	BSR.W	pt_SetupPaletteMode
	BRA.W	pt_ResetIntFlag
pt_1205:
	MOVE.W	(dat_CurrentSample,PC),D1
	LSL.W	#2,D1
	LEA	(dat_ModulePtr,PC),A0
	MOVE.L	D0,(0,A0,D1.W)
	MOVE.L	D6,(124,A0,D1.W)
	MOVE.W	DMACONR,dat_11FB
	MOVE.W	#$03ff,DMACON
	BSR.W	pt_120A
	MOVE.L	(dat_CursorRenderPtr,PC),D4
	CLR.W	BPLCON0
	MOVE.W	#$0555,COLOR00
	MOVEA.L	(dat_SpriteYCoord1,PC),A1
	LEA	INTREQ,A2
	LEA	CIAA_PRB,A3
	LEA	INTREQR,A4
	LEA	AUD1DAT,A6
	MOVE.W	#$0180,D7
	MOVEQ	#6,D6
	MOVEQ	#0,D5
pt_1206:
	BTST	D7,(A4)
	BEQ.S	pt_1206
	MOVE.W	D7,(A2)
	MOVE.B	(A3),D0
	SUB.B	D7,D0
	MOVE.B	D0,(A5)
	MOVE.B	D0,(A6)
	MOVE.B	D0,(A1)+
	ADDQ.W	#1,D5
	CMP.W	D4,D5
	BEQ.S	pt_1207
	BTST	D6,(-256,A3)
	BNE.S	pt_1206
pt_1207:
	MOVE.W	(dat_11FB,PC),D0
	OR.W	#$8000,D0
	MOVE.W	D0,DMACON
	MOVE.L	A1,D0
	SUB.L	(dat_SpriteYCoord1,PC),D0
	MOVE.L	D0,dat_CursorRenderPtr
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D1
	MULU	#s_SIZEOF,D1
	LEA	(12,A0,D1.W),A0
	MOVE.L	(dat_CursorRenderPtr,PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)+
	MOVE.W	#$0040,(A0)+
	CLR.W	(A0)+
	MOVE.W	#$0001,(A0)
	MOVE.L	(dat_CursorRenderPtr,PC),D1
	NEG.L	D1
	AND.L	#$fffffff8,D1
	NEG.L	D1
	MOVE.W	(dat_CurrentSample,PC),D0
	ASL.W	#2,D0
	LEA	dat_ModulePtr,A0
	CMP.L	(124,A0,D0.W),D1
	BGE.S	pt_ResetIntFlag
	MOVE.L	(124,A0,D0.W),D2
	MOVE.L	D1,(124,A0,D0.W)
	SUB.L	D1,D2
	MOVEA.L	(0,A0,D0.W),A1
	MOVE.L	(124,A0,D0.W),D0
	ADDA.L	D0,A1
	MOVE.L	D2,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_ResetIntFlag:
	MOVE.W	(dat_11FA,PC),D0
	BSET	#15,D0
	MOVE.W	D0,INTENA
	JSR	pt_StopAllAudio
	JSR	pt_InitEditState
	BSR.W	pt_120C
	BSR.W	pt_SampleClearLoop
	CLR.W	dat_KeyBufCount
	CLR.B	dat_KeyCode
	CLR.W	dat_KeyQual1
	MOVE.W	(A7)+,dat_DiskDisplayCtrl
	BSR.W	pt_DrawBorderLeft
	BSR.W	pt_DrawSampleHex
	BSR.W	pt_RecordModeHandler
	JSR	pt_WaitMouseRelease
	JMP	pt_RefreshDisplay
pt_1209:
	CLR.L	dat_SpriteYCoord1
	CLR.L	dat_CursorRenderPtr
	MOVEQ	#-1,D0
	RTS
pt_120A:
	MOVE.W	(dat_CurrentSample,PC),D0
	BEQ.S	pt_1209
	LSL.W	#2,D0
	LEA	(dat_ModulePtr,PC),A0
	MOVE.L	(0,A0,D0.W),dat_SpriteYCoord1
	MOVE.L	(124,A0,D0.W),dat_CursorRenderPtr
	MOVEQ	#0,D0
	RTS
pt_120B:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$00e8,D0
	MOVE.W	#$0090,D1
	LEA	str_SampleMonitor,A0
	JSR	pt_SetDrawOffset
	MOVE.W	#$00e8,D0
	MOVE.W	#$0090,D1
	MOVE.W	#$01b0,D2
	MOVE.W	#$00c7,D3
	MOVEQ	#0,D5
	BSR.W	pt_SetupAudioDisplay
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_120C:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$00e8,D0
	MOVE.W	#$0090,D1
	LEA	dat_144B,A0
	JSR	pt_SetDrawOffset
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_120D:
	JSR	pt_SavePaletteState
	MOVEA.L	ABSEXECBASE.W,A6
	SUBA.L	A1,A1
	JSR	(-294,A6)
	MOVE.L	D0,dat_14F8
	LEA	dat_WorkBuf2,A1
	JSR	(-354,A6)
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dat_WorkBuf1,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	LEA	dat_1321,A0
	JSR	(-444,A6)
	LEA	(dat_1215,PC),A0
	LEA	dat_WorkBuf1,A1
	MOVEA.L	(20,A1),A2
	MOVE.L	A2,dat_1214
	LEA	(36,A2),A2
	MOVEQ	#3,D1
pt_120E:
	MOVE.L	(A2)+,(A0)+
	DBF	D1,pt_120E
	MOVEQ	#0,D0
	LEA	(dat_1215,PC),A4
	MOVEA.L	(A4)+,A0
	MOVEA.L	(A4)+,A1
	MOVEA.L	(A4)+,A2
	MOVEA.L	(A4)+,A3
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_SetPaletteDim
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_120F:
	CMPA.L	#$00000000,A0
	BEQ.S	pt_1210
	MOVE.B	(34,A0),D0
pt_1210:
	CMPA.L	#$00000000,A1
	BEQ.S	pt_1211
	OR.B	(34,A1),D0
pt_1211:
	CMPA.L	#$00000000,A2
	BEQ.S	pt_1212
	OR.B	(34,A2),D0
pt_1212:
	CMPA.L	#$00000000,A3
	BEQ.S	pt_1213
	OR.B	(34,A3),D0
pt_1213:
	TST.B	D0
	BNE.S	pt_120F
	LEA	dat_WorkBuf1,A1
	JSR	(-450,A6)
	LEA	dat_WorkBuf2,A1
	JSR	(-360,A6)
	JSR	pt_RestorePalette
	RTS
dat_1214:
	DS.L	1
dat_1215:
	DS.L	4
pt_SampleClearLoop:
	LEA	dat_RpSampleStarts,A0
	MOVEQ	#30,D0
pt_1217:
	MOVE.L	(A0)+,D1
	BEQ.S	pt_1218
	MOVEA.L	D1,A1
	CLR.W	(A1)
pt_1218:
	DBF	D0,pt_1217
	RTS
dat_1219:
	DC.L	$09b00960,$091008c0,$08700820,$07d00780
	DC.L	$073006e0,$06900640,$05f005a0,$05500500
	DC.L	$04b00460,$041003c0,$03700320,$02d00280
	DC.L	$023001e0,$01900140,$00f000a0,$00500000
dat_ScreenSizeVar:
	DS.W	1
dat_ScreenDispData1:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_121C
	RTS
pt_121C:
	MOVEA.L	dat_NoteNamesPtr,A4
	MOVE.W	#$4a3e,dat_TextBytePos
	MOVE.W	(dat_BorderSizeH,PC),D0
	LSL.W	#2,D0
	LEA	(0,A4,D0.W),A0
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$0004,dat_TextCharCount
	BRA.W	pt_DrawTextRender
dat_ScreenDispData2:
	TSTPC.W	dat_SamplerActive
	BNE.S	pt_121E
	RTS
pt_121E:
	MOVEA.L	dat_NoteNamesPtr,A4
	MOVE.W	#$4dae,dat_TextBytePos
	MOVE.W	(dat_BorderSizeV,PC),D0
	LSL.W	#2,D0
	LEA	(0,A4,D0.W),A0
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$0004,dat_TextCharCount
	BRA.W	pt_DrawTextRender
dat_ChannelPtrTable:
	DC.L	dat_Channel1
	DC.L	dat_Channel2
	DC.L	dat_Channel3
	DC.L	dat_Channel4
	SHIFTPAD	4
