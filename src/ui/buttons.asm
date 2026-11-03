pt_InputMain:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1436,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_DispatchButton1
	RTS
pt_DispatchButton1:
	CMP.W	#$0048,D2
	BEQ.W	pt_BtnMainAbout
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnMainQuit
	CMP.W	#$0002,D2
	BEQ.W	pt_ScreenStateHandler
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnMainSongName
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnMainVolumeUp
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnMainVolumeDown
	CMP.W	#$0006,D2
	BNE.S	pt_DispatchButton2
	BRA.W	pt_BtnMainTitleSide
pt_DispatchButton2:
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnMainPosInsert
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnMainPosDelete
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnMainPosValue
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnMainPatternValue
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnMainLengthValue
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnMainPlst
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnMainPosEdit
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnMainPlay
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnMainStop
	CMP.W	#$0016,D2
	BEQ.W	pt_BtnMainContinue
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnMainPattern
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnMainRecord
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnMainEdit
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnMainClear
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnMainSetup
	CMP.W	#$001c,D2
	BEQ.W	pt_BtnMainDiskOp
	CMP.W	#$001d,D2
	BEQ.W	pt_BtnMainFileName
	CMP.W	#$0031,D2
	BEQ.W	pt_BtnMainKillSample
	CMP.W	#$0032,D2
	BEQ.W	pt_BtnMainSampler
	MOVE.W	#$0001,dat_TimeDisplayInit
	CMP.W	#$002d,D2
	BEQ.W	pt_BtnMainSampleLenValue
	CMP.W	#$002e,D2
	BEQ.W	pt_BtnMainRepeatValue
	CMP.W	#$002f,D2
	BEQ.W	pt_BtnMainReplenValue
	MOVE.W	#$ffff,dat_ButtonActive
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnMainPosArrows
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnMainPatternArrows
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnMainLengthArrows
	CMP.W	#$001f,D2
	BEQ.W	pt_BtnMainSampleArrows
	CMP.W	#$0021,D2
	BEQ.W	pt_BtnMainSampleVolArrows
	CMP.W	#$0023,D2
	BEQ.W	pt_BtnMainFinetuneArrows
	CMP.W	#$0025,D2
	BEQ.W	pt_BtnMainSampleLenArrows
	CMP.W	#$0027,D2
	BEQ.W	pt_BtnMainRepeatArrows
	CMP.W	#$0029,D2
	BEQ.W	pt_BtnMainReplenArrows
	CLR.W	dat_ButtonActive
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnMainPosArrows
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnMainPatternArrows
	CMP.W	#$0012,D2
	BEQ.W	pt_BtnMainLengthArrows
	CMP.W	#$001e,D2
	BEQ.W	pt_BtnMainSampleArrows
	CMP.W	#$0020,D2
	BEQ.W	pt_BtnMainSampleVolArrows
	CMP.W	#$0022,D2
	BEQ.W	pt_BtnMainFinetuneArrows
	CMP.W	#$0024,D2
	BEQ.W	pt_BtnMainSampleLenArrows
	CMP.W	#$0026,D2
	BEQ.W	pt_BtnMainRepeatArrows
	CMP.W	#$0028,D2
	BEQ.W	pt_BtnMainReplenArrows
	CMPI.W	#$0001,dat_UIMode
	BNE.S	pt_DispatchButton3
	CMP.W	#$0044,D2
	BEQ.W	pt_BtnMainRepair
	CMP.W	#$0045,D2
	BEQ.W	pt_BtnMainInfo
	CMP.W	#$0049,D2
	BEQ.W	pt_BtnMainPosEdit
	CMP.W	#$004c,D2
	BEQ.W	pt_BtnMainIconLines
	CMP.W	#$004d,D2
	BEQ.W	pt_BtnMainIconF
pt_DispatchButton3:
	CMPI.W	#$0008,dat_OptPage
	BEQ.S	pt_DispatchSample
	CMP.W	#$003c,D2
	BEQ.W	pt_BtnMainEditOptions
	CMP.W	#$003d,D2
	BEQ.W	pt_BtnMainOptPage1
	CMP.W	#$003e,D2
	BEQ.W	pt_BtnMainOptPage2
	CMP.W	#$003f,D2
	BEQ.W	pt_BtnMainOptPage3
	CMP.W	#$0040,D2
	BEQ.W	pt_BtnMainOptPage4
	CMP.W	#$0041,D2
	BNE.S	pt_DispatchButton4
	JMP	pt_BtnMainOptPage5
pt_DispatchButton4:
	CMP.W	#$0042,D2
	BEQ.W	pt_BtnMainOptPage6
	CMP.W	#$0043,D2
	BEQ.W	pt_BtnMainOptPage7
	CMP.W	#$0046,D2
	BEQ.S	pt_BtnMainPrint
	CMP.W	#$0047,D2
	BEQ.W	pt_BtnScreenDrag
	CMP.W	#$004f,D2
	BEQ.S	pt_BtnMainHelp
	CMP.W	#$004e,D2
	BEQ.S	pt_BtnMainQuit
	CMP.W	#$0056,D2
	JMP	pt_MainDispatchMore
pt_DispatchSample:
	JMP	pt_0AE7
pt_BtnMainKillSample:
	JMP	pt_ConfirmYesNoDialog
pt_BtnMainSampler:
	JMP	pt_EnterSampler
pt_BtnMainPlst:
	JMP	pt_EnterPlst
pt_BtnMainHelp:
	BRA.W	pt_040C
pt_BtnMainInfo:
	JMP	pt_EnterComment
pt_BtnMainPosEdit:
	JMP	pt_EnterPosEdit
pt_BtnMainQuit:
	JMP	pt_CheckSongChanged
pt_BtnMainPrint:
	JMP	pt_BtnSetupPrintSong
pt_BtnMainRepair:
	LEA	dat_12E2,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0583
	RTS
pt_0583:
	JMP	pt_06A7
pt_BtnMainIconLines:
	ADDQ.B	#1,dat_CursorPhase
	CMPI.B	#$03,dat_CursorPhase
	BMI.S	pt_0585
	CLR.B	dat_CursorPhase
pt_0585:
	BSR.W	pt_InitPalettes
	RTS
pt_BtnMainIconF:
	BCHG	#1,dat_ModeFlags
	BTST	#1,dat_ModeFlags
	SNE	D0
	MOVE.B	D0,D1
	NOT.B	D1
	AND.B	#$01,D1
	LSL.B	#1,D1
	BCLR	#1,CIAA_PRA
	OR.B	D1,CIAA_PRA
pt_HandleMouseClick:
	MOVE.W	dat_EditDigitValue,dat_SavedEditDigit
	MOVE.W	dat_PalEdSelectPos,dat_SavedPalSelect
	MOVE.W	dat_SavedEditDigit,D0
	MOVE.W	dat_SavedPalSelect,D1
	CMP.W	#$0079,D1
	BCS.S	pt_0588
	TST.W	dat_SamplerActive
	BNE.S	pt_0588
	BSR.W	pt_08FB
pt_0588:
	CMPI.W	#$0003,dat_UIMode
	BEQ.W	pt_InputDiskOpChecks
	RTS
pt_BtnDiskRelabel:
	LEA	(dat_DiskFormatBuf,PC),A0
	MOVEA.L	dat_SampleEditorPtr,A1
	MOVEQ	#31,D1
pt_058A:
	MOVE.B	(A1)+,(A0)+
	DBF	D1,pt_058A
	LEA	(dat_DiskFormatBuf,PC),A0
	MOVEQ	#31,D1
pt_058B:
	CMPI.B	#$3a,(A0)
	BEQ.S	pt_058C
	ADDQ.L	#1,A0
	DBF	D1,pt_058B
	BRA.S	pt_ShowStatusInfo
pt_058C:
	CLR.B	(A0)+
	DBF	D1,pt_058C
	LEA	(dat_DiskFormatBuf,PC),A0
	TST.B	(A0)
	BEQ.S	pt_ShowStatusInfo
	MOVEQ	#30,D0
pt_058D:
	TST.B	(A0)+
	BEQ.S	pt_058E
	DBF	D0,pt_058D
	BRA.S	pt_ShowStatusInfo
pt_058E:
	MOVE.B	#$3a,(-1,A0)
	LEA	(dat_0593,PC),A0
	LEA	(dat_0598,PC),A1
	MOVEQ	#32,D0
	LEA	dat_146C,A2
	BSR.W	pt_SetupDisplayMode
	BEQ.S	pt_058F
	RTS
pt_058F:
	LEA	(dat_0594,PC),A0
	JSR	pt_ShowStatusMsg
	LEA	(dat_0597,PC),A0
	LEA	(1,A0),A1
	MOVEQ	#0,D0
pt_0590:
	TST.B	(A1)+
	BEQ.S	pt_0591
	ADDQ.W	#1,D0
	CMP.W	#$0020,D0
	BNE.S	pt_0590
	CLR.B	(A1)
pt_0591:
	MOVE.B	D0,(A0)
	LEA	(dat_DiskFormatBuf,PC),A0
	LEA	(dat_0597,PC),A1
	BSR.W	pt_0403
	JSR	pt_ClearStatusMsg
	RTS
pt_ShowStatusInfo:
	LEA	(dat_0595,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
dat_0593:
	DC.B	10,10
	DC.B	"   Relabel disk as:",0
dat_0594:
	DC.B	"Relabling disk...",0
dat_0595:
	DC.B	"No diskname to relabel",0
	DC.B	"Diskname to long...",0,0,0,0
dat_DiskFormatBuf:
	DS.L	8
	DC.L	$0000542d
dat_0597:
	DC.B	$05
dat_0598:
	DC.B	$53
	DC.L	$542d3030
	DS.L	4
dat_0599:
	DC.B	10,10
	DC.B	"      W A R N I N G !",10,10
	DC.B	"  All data will be lost.",0
dat_059A:
	DC.B	"FORMATTING...",0
dat_059B:
	DC.B	"INITIALIZING...",0
dat_059C:
	DC.B	"FORMATTING ABORTED",0
dat_059D:
	DC.B	"HARD ERROR ON DISK",0
dat_059E:
	DC.B	"CANT OPEN TRACKDISKDEVICE",0
dat_059F:
	DC.B	"NO DISK IN DRIVE",0
dat_05A0:
	DC.B	"CALCULATING SAMPLE ...",0
dat_05A1:
	DC.B	"DF0DF1DF2DF3"
dat_05A2:
	DC.B	"OFSFFSINT"
dat_05A3:
	DC.B	$60
	DC.W	$2074
str_EmptyString:
	DC.L	$656d7074,$79000000
	DS.L	7
dat_DiskResourceIndex:
	DS.W	1
dat_DiskTrackFlag:
	DS.B	1
dat_05A7:
	DS.B	1
dat_05A8:
	DC.W	$0001
dat_05A9:
	DS.W	1
dat_05AA:
	DC.W	$0001
dat_05AB:
	DS.B	1
dat_05AC:
	DS.B	1
dat_05AD:
	DC.B	"disk.resource",0
pt_BtnDiskFormat:
	JSR	pt_05B1
	BPL.S	pt_05AF
	RTS
pt_05AF:
	LEA	(dat_0599,PC),A0
	BSR.W	pt_0322
	BEQ.S	pt_05B0
	RTS
pt_05B0:
	BRA.W	pt_05C9
pt_05B1:
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_05C8
	BSR.W	pt_CopyPatternBlock
	SUBA.L	A0,A0
	LEA	dat_146C,A1
	LEA	dat_144C,A2
	MOVE.L	#$00000140,D0
	BSR.W	pt_BlitCopyBlock
	BSR.W	pt_05B9
	BSR.W	pt_05BC
	BSR.W	pt_DrawTuningCurve
	BSR.W	pt_05C3
	BSR.W	pt_05C6
pt_DisplayUpdateWait:
	JSR	pt_FmtKeys41
	NOP
	NOP
	NOP
	BNE.S	pt_DisplayUpdateWait
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_1449,A0
	BSR.W	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_DisplayUpdateWait
	CMP.W	#$0001,D2
	BEQ.S	pt_05B4
	CMP.W	#$0002,D2
	BEQ.S	pt_05B5
	CMP.W	#$0003,D2
	BEQ.S	pt_05B6
	PEA	(pt_DisplayUpdateWait,PC)
	CMP.W	#$000a,D2
	BNE.S	pt_05B3
	BSR.W	pt_ScreenStateHandler
pt_05B3:
	CMP.W	#$0004,D2
	BEQ.W	pt_05C2
	CMP.W	#$0005,D2
	BEQ.W	pt_05C5
	CMP.W	#$0006,D2
	BEQ.S	pt_05BA
	CMP.W	#$0007,D2
	BEQ.W	pt_05BE
	CMP.W	#$0008,D2
	BEQ.S	pt_05B8
	RTS
pt_05B4:
	MOVEQ	#0,D0
	BRA.S	pt_05B7
pt_05B5:
	MOVEQ	#1,D0
	BRA.S	pt_05B7
pt_05B6:
	MOVEQ	#-1,D0
pt_05B7:
	BSR.W	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	MOVE.W	D0,dat_05AA
	RTS
pt_05B8:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	LEA	(str_EmptyString,PC),A6
	MOVE.L	A6,dat_TextStringPtr
	MOVE.L	A6,dat_SongDataAddr
	ADDI.L	#$00000020,dat_SongDataAddr
	MOVE.W	#$0015,dat_TextCharCount
	MOVE.W	#$010d,D0
	MOVEQ	#86,D1
	BSR.W	pt_StoreFxParameter
	BSR.W	pt_RestorePalette
pt_05B9:
	LEA	(str_EmptyString,PC),A0
	MOVE.W	#$010d,D0
	MOVEQ	#86,D1
	MOVEQ	#21,D3
	JMP	pt_BlitPatternFull
pt_05BA:
	BSR.W	pt_WaitMouseRelease
pt_05BB:
	ADDQ.W	#1,dat_DiskResourceIndex
	CMPI.W	#$0004,dat_DiskResourceIndex
	BMI.S	pt_05BC
	CLR.W	dat_DiskResourceIndex
pt_05BC:
	MOVE.W	(dat_DiskResourceIndex,PC),D0
	MOVE.W	(dat_05AB,PC),D1
	AND.W	#$000f,D1
	BEQ.S	pt_05BD
	BTST	D0,D1
	BEQ.S	pt_05BB
pt_05BD:
	LEA	(dat_05A1,PC),A0
	MULU	#$0003,D0
	ADDA.L	D0,A0
	MOVE.W	#$019f,D0
	MOVEQ	#58,D1
	MOVEQ	#3,D3
	JMP	pt_BlitPatternRow
pt_05BE:
	BSR.W	pt_WaitMouseRelease
	ADDQ.W	#1,dat_DiskTrackFlag
	CMPI.W	#$0022,dat_KickstartVer
	BPL.S	pt_05BF
	CLR.W	dat_DiskTrackFlag
	BRA.S	pt_DrawTuningCurve
pt_05BF:
	CMPI.W	#$0024,dat_KickstartVer
	BPL.S	pt_05C0
	CMPI.W	#$0002,dat_DiskTrackFlag
	BMI.S	pt_DrawTuningCurve
	CLR.W	dat_DiskTrackFlag
	BRA.S	pt_DrawTuningCurve
pt_05C0:
	CMPI.W	#$0003,dat_DiskTrackFlag
	BMI.S	pt_DrawTuningCurve
	CLR.W	dat_DiskTrackFlag
pt_DrawTuningCurve:
	LEA	(dat_05A2,PC),A0
	MOVE.W	(dat_DiskTrackFlag,PC),D0
	MULU	#$0003,D0
	ADDA.L	D0,A0
	MOVE.W	#$019f,D0
	MOVEQ	#71,D1
	MOVEQ	#3,D3
	JMP	pt_BlitPatternRow
pt_05C2:
	BSR.W	pt_WaitMouseRelease
	EORI.W	#$0001,dat_05A8
pt_05C3:
	LEA	(dat_05A3,PC),A0
	TSTPC.W	dat_05A8
	BNE.S	pt_05C4
	ADDQ.L	#1,A0
pt_05C4:
	MOVE.W	#$0143,D0
	MOVEQ	#58,D1
	MOVEQ	#1,D3
	JMP	pt_BlitPatternRow
pt_05C5:
	BSR.W	pt_WaitMouseRelease
	EORI.W	#$0001,dat_05A9
pt_05C6:
	LEA	(dat_05A3,PC),A0
	TSTPC.W	dat_05A9
	BNE.S	pt_05C7
	ADDQ.L	#1,A0
pt_05C7:
	MOVE.W	#$0143,D0
	MOVEQ	#71,D1
	MOVEQ	#1,D3
	JMP	pt_BlitPatternRow
pt_05C8:
	LEA	(dat_05AD,PC),A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-498,A6)
	MOVEA.L	D0,A0
	MOVEQ	#0,D0
	MOVE.B	(38,A0),dat_05AC
	RTS
pt_05C9:
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_CopyPatternBlock
	SUBA.L	A0,A0
	SUBA.L	A1,A1
	LEA	dat_144D,A2
	BSR.W	pt_BlitCopyBlock
	LEA	(dat_059A,PC),A0
	MOVE.W	#$0112,D0
	MOVEQ	#62,D1
	JSR	pt_DrawBoxedText
	JSR	pt_ShowStatusMsg
	MOVE.W	(dat_DiskResourceIndex,PC),D0
	AND.B	#$03,D0
	ADD.B	#$30,D0
	MOVE.B	D0,dat_05F8
	LEA	chip_BlitterBuffer,A0
	LEA	(dat_05F6,PC),A1
	MOVE.L	(A1),D0
	MOVE.B	(dat_05A7,PC),D0
	MOVE.L	D0,(A0)
	BSR.W	pt_05F0
	BNE.W	pt_05CF
	BSR.W	pt_05F2
	BNE.W	pt_05D0
	BSR.W	pt_05EF
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteDim
	CMPI.W	#$0001,dat_05AA
	BEQ.S	pt_05CA
	BSR.W	pt_05D1
	BMI.S	pt_05CE
	BNE.S	pt_05CD
pt_05CA:
	LEA	(dat_059B,PC),A0
	MOVE.W	#$010b,D0
	MOVEQ	#62,D1
	JSR	pt_DrawBoxedText
	JSR	pt_ShowStatusMsg
	BSR.W	pt_05DD
	BNE.S	pt_05CE
	JSR	pt_ClearStatusMsg
pt_InitFileOperation:
	BSR.W	pt_05EE
	CLR.L	dat_FileOpResult
	BSR.W	pt_05EF
	MOVE.L	#$ffffffff,dat_FileOpResult
	BSR.W	pt_05F4
	BSR.W	pt_RestorePalette
pt_05CC:
	BSR.W	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	BSR.W	pt_ClearKeyState
	MOVEQ	#0,D0
	RTS
pt_05CD:
	BSR.S	pt_InitFileOperation
	LEA	(dat_059C,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
pt_05CE:
	BSR.W	pt_05ED
	BSR.S	pt_InitFileOperation
	LEA	(dat_059D,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
pt_05CF:
	BSR.S	pt_05CC
	LEA	(dat_059E,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
pt_05D0:
	BSR.S	pt_InitFileOperation
	LEA	(dat_059F,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
pt_05D1:
	LEA	(dat_05F5,PC),A0
	LEA	SECSTRT_3,A1
	MOVE.L	#$0000057f,D0
pt_05D2:
	MOVE.L	(A0),(A1)+
	DBF	D0,pt_05D2
	MOVE.W	#$0001,dat_SampleEdVar1
	MOVEQ	#0,D5
	MOVE.L	#$0000009f,D7
pt_05D3:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_SampleEdVar1,PC),D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D2
	MOVE.W	D2,dat_SampleEdVar1
	LSR.W	#1,D0
	LSR.W	#1,D2
	MULU	#$00ec,D0
	DIVU	#$0050,D0
	MULU	#$00ec,D2
	DIVU	#$0050,D2
	ADD.W	#$00ca,D0
	ADD.W	#$00ca,D2
	MOVEQ	#77,D1
	MOVE.W	#$0056,D3
	MOVEQ	#1,D5
	JSR	pt_SetupAudioDisplay
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BSR.S	pt_05D8
	BNE.S	pt_05D5
	ADD.L	#$00001600,D5
	MOVEM.L	D0-D7/A0-A6,-(A7)
	CMPI.W	#$0002,dat_SampleEdVar1
	BNE.S	pt_05D4
	BSR.W	pt_05ED
pt_05D4:
	IFD	DEBUGAUTO
	JSR	dbg_AutoStep
	ENDC
	BSR.W	pt_GetKeypress
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$45,D0
	BEQ.S	pt_05D6
	DBF	D7,pt_05D3
	MOVEQ	#0,D0
	RTS
pt_05D5:
	MOVEQ	#-1,D0
	RTS
pt_05D6:
	MOVEQ	#1,D0
	RTS
	DC.W	$43f9
dat_SampleEdVar1:
	DS.W	1
pt_05D8:
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.L	#SECSTRT_3,(40,A1)
	MOVE.L	D5,(44,A1)
	MOVE.L	#$00001600,(36,A1)
	MOVE.W	#$000b,(28,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-456,A6)
	TST.L	D0
	BNE.S	pt_ReturnFail
	TST.B	(31,A1)
	BNE.S	pt_ReturnFail
	TSTPC.W	dat_05A8
	BEQ.S	pt_05D9
	LEA	SECSTRT_3,A0
	BSR.S	pt_05DB
	MOVE.L	D0,dat_05F9
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.L	#chip_ScreenBuffer1,(40,A1)
	MOVE.L	D5,(44,A1)
	MOVE.L	#$00001600,(36,A1)
	MOVE.W	#$0002,(28,A1)
	JSR	(-456,A6)
	TST.L	D0
	BNE.S	pt_ReturnFail
	TST.B	(31,A1)
	BNE.S	pt_ReturnFail
	LEA	chip_ScreenBuffer1,A0
	BSR.S	pt_05DB
	CMP.L	(dat_05F9,PC),D0
	BNE.S	pt_ReturnFail
pt_05D9:
	MOVEQ	#0,D0
	RTS
pt_ReturnFail:
	MOVEQ	#-1,D0
	RTS
pt_05DB:
	MOVE.L	A0,-(A7)
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.W	#$0004,(28,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-456,A6)
	MOVEA.L	(A7)+,A0
	MOVE.L	#$0000057f,D1
	MOVEQ	#0,D0
pt_05DC:
	SUB.L	(A0)+,D0
	DBF	D1,pt_05DC
	MOVE.L	D0,dat_05FA
	RTS
pt_05DD:
	LEA	chip_CopperWorkBuffer,A1
	MOVE.L	A1,D1
	ADD.L	#$000001e4,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-192,A6)
	LEA	chip_CopperWorkBuffer,A0
	MOVE.L	#$ffffffff,(312,A0)
	MOVE.L	#$00000371,(316,A0)
	LEA	(432,A0),A0
	LEA	(1,A0),A2
	LEA	(str_EmptyString,PC),A1
	MOVEQ	#0,D1
	MOVEQ	#31,D0
pt_05DE:
	MOVE.B	(A1)+,D2
	BEQ.S	pt_05DF
	MOVE.B	D2,(A2)+
	ADDQ.B	#1,D1
	DBF	D0,pt_05DE
pt_05DF:
	MOVE.B	D1,(A0)
	LEA	chip_CopperWorkBuffer,A0
	MOVE.L	#$00000002,(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	MOVE.L	#$00000048,(A0)+
	CLR.L	(A0)+
	LEA	chip_CopperWorkBuffer,A0
	LEA	(508,A0),A0
	MOVE.L	#$00000001,(A0)
	BSR.S	pt_05E4
	LEA	chip_CopperWorkBuffer,A0
	MOVE.L	D0,(20,A0)
	MOVE.L	#$0006e000,D5
	BSR.W	pt_05E8
	BNE.S	pt_ReturnMinusOne
	LEA	chip_CopperWorkBuffer,A0
	MOVEQ	#27,D0
pt_05E0:
	MOVE.L	#$ffffffff,(A0)+
	DBF	D0,pt_05E0
	MOVE.L	#$ffff3fff,(A0)+
	MOVEQ	#26,D0
pt_05E1:
	MOVE.L	#$ffffffff,(A0)+
	DBF	D0,pt_05E1
	MOVEQ	#72,D0
pt_05E2:
	CLR.L	(A0)+
	DBF	D0,pt_05E2
	BSR.S	pt_05E6
	LEA	chip_CopperWorkBuffer,A0
	MOVE.L	D0,(A0)
	MOVE.L	#$0006e200,D5
	BSR.S	pt_05E8
	BNE.S	pt_ReturnMinusOne
	BSR.S	pt_05EA
	BNE.S	pt_ReturnMinusOne
	MOVEQ	#0,D0
	RTS
pt_ReturnMinusOne:
	MOVEQ	#-1,D0
	RTS
pt_05E4:
	LEA	chip_CopperWorkBuffer,A0
	LEA	(20,A0),A1
	MOVEQ	#127,D1
	MOVEQ	#0,D0
	MOVE.L	D0,(A1)
pt_05E5:
	SUB.L	(A0)+,D0
	DBF	D1,pt_05E5
	MOVE.L	D0,(A1)
	RTS
pt_05E6:
	LEA	chip_CopperWorkBuffer,A0
	LEA	(A0),A1
	MOVEQ	#127,D1
	MOVEQ	#0,D0
	MOVE.L	D0,(A1)
pt_05E7:
	SUB.L	(A0)+,D0
	DBF	D1,pt_05E7
	MOVE.L	D0,(A1)
	RTS
pt_05E8:
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.L	#chip_CopperWorkBuffer,(40,A1)
	MOVE.L	D5,(44,A1)
	MOVE.L	#$00000200,(36,A1)
	MOVE.W	#$0003,(28,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-456,A6)
	TST.B	(31,A1)
	BNE.S	pt_05E9
	BSR.S	pt_05EC
	MOVEQ	#0,D0
	RTS
pt_05E9:
	MOVEQ	#-1,D0
	RTS
pt_05EA:
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.L	#chip_BlitterBuffer,(40,A1)
	CLR.L	(44,A1)
	MOVE.L	#$00000400,(36,A1)
	MOVE.W	#$0003,(28,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-456,A6)
	TST.B	(31,A1)
	BNE.S	pt_05EB
	BSR.S	pt_05EC
	MOVEQ	#0,D0
	RTS
pt_05EB:
	MOVEQ	#-1,D0
	RTS
pt_05EC:
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.W	#$0004,(28,A1)
	JSR	(-456,A6)
	RTS
pt_05ED:
	MOVE.L	chip_BlitterBuffer,-(A7)
	MOVE.L	#$42414421,chip_BlitterBuffer
	BSR.S	pt_05EA
	MOVE.L	(A7)+,chip_BlitterBuffer
	RTS
pt_05EE:
	LEA	dat_WorkBuf1,A1
	MOVE.L	#dat_WorkBuf2,(14,A1)
	MOVE.W	#$0009,(28,A1)
	CLR.L	(36,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-456,A6)
	RTS
pt_05EF:
	LEA	dat_CursorAnimBuf,A5
	LEA	(20,A5),A4
	MOVE.L	A4,(10,A5)
	LEA	(A5),A0
	MOVE.L	A0,(A4)
	MOVEA.L	dat_ThisTask,A0
	LEA	(92,A0),A0
	MOVE.L	A0,(4,A4)
	MOVE.L	#$0000001f,(8,A4)
	MOVE.L	(dat_FileOpResult,PC),(20,A4)
	LEA	(dat_05F7,PC),A0
	MOVE.L	A0,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-174,A6)
	MOVEA.L	D0,A0
	LEA	dat_CursorAnimBuf,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-366,A6)
	MOVEA.L	dat_ThisTask,A0
	LEA	(92,A0),A0
	JSR	(-384,A6)
	MOVEA.L	dat_ThisTask,A0
	LEA	(92,A0),A0
	JSR	(-372,A6)
	RTS
pt_05F0:
	MOVE.L	dat_ThisTask,D0
	MOVE.L	D0,dat_14F8
	LEA	dat_WorkBuf2,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-354,A6)
	LEA	dat_WorkBuf1,A1
	MOVEQ	#0,D0
	MOVE.W	(dat_DiskResourceIndex,PC),D0
	MOVEQ	#0,D1
	LEA	dat_1321,A0
	JSR	(-444,A6)
	BNE.S	pt_05F1
	MOVEQ	#0,D0
	RTS
pt_05F1:
	MOVEQ	#-1,D0
	RTS
pt_05F2:
	LEA	dat_WorkBuf1,A1
	MOVE.B	#$01,(30,A1)
	MOVE.W	#$000e,(28,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-456,A6)
	TST.L	(32,A1)
	BNE.S	pt_05F3
	MOVEQ	#0,D0
	RTS
pt_05F3:
	MOVEQ	#-1,D0
	RTS
pt_05F4:
	LEA	dat_WorkBuf1,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-450,A6)
	LEA	dat_WorkBuf2,A1
	JSR	(-360,A6)
	RTS
dat_05F5:
	DC.B	"DOS0",0,0
dat_05F6:
	DC.L	$444f5300
dat_05F7:
	DC.W	$4446
dat_05F8:
	DC.L	$303a0000
	DS.W	1
dat_05F9:
	DS.L	1
dat_05FA:
	DS.L	1
dat_FileOpResult:
	DC.L	$ffffffff
pt_05FC:
	CMPI.L	#$43484721,dat_SongChangedMagic
	BNE.S	pt_05FD
	JSR	pt_SaveConfirmDialog
	CMP.W	#$0002,D0
	BEQ.S	pt_05FD
	RTS
pt_05FD:
	LEA	(dat_0605,PC),A0
	MOVE.L	A0,-(A7)
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	BSR.W	pt_RefreshDisplay
	BSR.W	pt_CopyPatternBlock
	MOVEA.L	(A7)+,A0
	LEA	dat_CopperBufReserve,A1
	LEA	dat_1455,A2
	MOVE.L	#$00000460,D0
	BSR.W	pt_BlitCopyBlock
pt_WaitKeyUpdate:
	BSR.W	pt_ScreenDragUpdate
	JSR	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$21,D0
	BEQ.S	pt_0602
	CMP.B	#$18,D0
	BEQ.S	pt_0601
	CMP.B	#$20,D0
	BEQ.S	pt_0603
	CMP.B	#$33,D0
	BEQ.S	pt_0600
	CMP.B	#$45,D0
	BEQ.S	pt_0600
	LMB
	BNE.S	pt_WaitKeyUpdate
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_1447,A0
	BSR.W	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_WaitKeyUpdate
	CMP.W	#$000a,D2
	BNE.S	pt_05FF
	BSR.W	pt_ScreenStateHandler
	BRA.S	pt_WaitKeyUpdate
pt_05FF:
	CMP.W	#$0001,D2
	BEQ.S	pt_0601
	CMP.W	#$0002,D2
	BEQ.S	pt_0602
	CMP.W	#$0003,D2
	BEQ.S	pt_0603
pt_0600:
	BSR.S	pt_CopyScreenInit
	MOVEQ	#-1,D0
	RTS
pt_0601:
	BSR.S	pt_CopyScreenInit
	MOVEQ	#1,D0
	RTS
pt_0602:
	BSR.S	pt_CopyScreenInit
	MOVEQ	#2,D0
	RTS
pt_0603:
	BSR.S	pt_CopyScreenInit
	MOVEQ	#3,D0
	RTS
pt_CopyScreenInit:
	BSR.W	pt_CopyScreenBufs
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	BSR.W	pt_RefreshDisplay
	BSR.W	pt_WaitMouseRelease
	CLR.W	dat_DiskOpFlag
	RTS
dat_0605:
	DC.B	10,10
	DC.B	"  Select what data you",10
	DC.B	"     wish to clear.",0,0
pt_BtnMainClear:
	ADDQ.L	#1,dat_MagicNumber
	BSR.W	pt_05FC
	BMI.S	pt_0607
	CMP.W	#$0001,D0
	BEQ.S	pt_060A
	CMP.W	#$0002,D0
	BEQ.S	pt_0609
	CMP.W	#$0003,D0
	BEQ.S	pt_0608
pt_0607:
	BRA.W	pt_SetPaletteEdit
pt_0608:
	BSR.S	pt_InitNewModule
	BSR.S	pt_SetupSampleView
	BSR.W	pt_SetPaletteBright
	BSR.W	pt_ClearBufferLoop
	BRA.W	pt_LeaveToMain
pt_0609:
	BSR.W	pt_BtnMainStop
	BSR.S	pt_SetupSampleView
	BSR.W	pt_SetPaletteBright
	MOVE.W	#$0001,dat_CurrentSample
	BRA.W	pt_LeaveToMain
pt_060A:
	BSR.S	pt_InitNewModule
	BSR.W	pt_ClearBufferLoop
	BSR.W	pt_SetPaletteBright
	BRA.W	pt_LeaveToMain
pt_SetupSampleView:
	BSR.W	pt_061A
	MOVEA.L	dat_ModulePtr,A0
	LEA	(20,A0),A0
	MOVE.W	#$03a1,D0
pt_060C:
	CLR.B	(A0)+
	DBF	D0,pt_060C
	MOVEA.L	dat_ModulePtr,A1
	LEA	(20,A1),A1
	MOVEQ	#30,D0
pt_060D:
	MOVE.W	#$0001,(28,A1)
	LEA	(30,A1),A1
	DBF	D0,pt_060D
	LEA	(dat_EffectParamVar,PC),A3
	MOVEQ	#31,D0
pt_060E:
	CLR.W	(A3)+
	DBF	D0,pt_060E
	JMP	pt_RecordModeHandler
pt_InitNewModule:
	BSR.W	pt_BtnMainStop
	CLR.B	dat_KeyCode
	MOVEA.L	dat_ModulePtr,A0
	MOVEA.L	A0,A1
	MOVEQ	#19,D0
pt_0610:
	CLR.B	(A0)+
	DBF	D0,pt_0610
	MOVEA.L	A1,A2
	ADDA.L	dat_SampleEditCfg,A2
	ADDA.W	#$03b6,A1
	MOVEQ	#0,D0
pt_0611:
	MOVE.W	D0,(A1)+
	CMPA.L	A1,A2
	BNE.S	pt_0611
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	#$017f,(mod_songlen,A0)
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
	CLR.L	dat_BplUpdateReq
	CLR.L	dat_RpSongPos
	CLR.L	dat_RpPatternPos
	CLR.L	dat_PatBaseAddr
	CLR.L	dat_MonthNames
	CLR.W	dat_EditCursorPos
	CLR.B	dat_RpMetroChannel
	MOVE.W	#$0001,dat_EditStepSize
	MOVEQ	#0,D0
	MOVE.W	dat_PaletteIdxCounter,D0
	MOVE.L	D0,dat_RpSpeed
	MOVE.W	dat_SavedTempo,dat_CurrentTempo
	JSR	pt_SetTempo
	BSR.W	pt_0617
	BSR.W	pt_0619
	BSR.W	pt_0616
	MOVE.W	#$0001,dat_CurrentSample
	MOVE.L	#$00000006,dat_RpSpeed
	CLR.L	dat_PatTableIdx
	CLR.W	dat_PatternPosition
	BSR.W	pt_PatViewSetRow
	BSR.S	pt_0612
	CLR.L	dat_SongChangedMagic
	JMP	pt_PatViewDrawAll
pt_0612:
	MOVE.L	(dat_TimeAuxVal,PC),D0
	ADD.L	dat_ModeConfigVal,D0
	MOVE.L	D0,dat_FileInfoPtr2
	LEA	str_UnnamedSong2,A0
	LEA	str_UnnamedSong,A1
	MOVEQ	#32,D0
pt_0613:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0613
	LEA	str_UnnamedAuthor2,A0
	LEA	str_UnnamedAuthor,A1
	MOVEQ	#32,D0
pt_0614:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0614
	CLR.W	dat_SongNameBufEnd
	CLR.W	dat_SongNameEnd
	CLR.W	dat_SongConfigVar
	MOVE.W	#$007d,dat_DefaultTempo
	MOVE.B	dat_ModeFlags,dat_SongModified
	MOVE.B	dat_ModeFlags+1,dat_SongModified+1
	CLR.W	dat_DSPControl
	CLR.W	dat_SongConfigA
	CLR.W	dat_SongConfigB
	CLR.W	dat_SongConfigC
	CLR.W	dat_SongConfigD
	CLR.W	dat_SongConfigE
	CLR.W	dat_TempoVar2
	CLR.W	dat_DiskConfigA
	CLR.W	dat_DiskConfigB
	CLR.W	dat_SongCommentData
	CLR.L	dat_FileInfoAddr
	LEA	str_VBLIntName,A0
	LEA	str_InfoFileName,A1
	MOVEQ	#5,D0
pt_0615:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0615
	RTS
pt_0616:
	CLR.B	dat_KeyCode
	MOVE.W	#$0001,dat_ScopeCh1
	MOVE.W	#$0001,dat_ScopeCh2
	MOVE.W	#$0001,dat_ScopeCh3
	MOVE.W	#$0001,dat_ScopeCh4
	MOVE.W	#$0001,dat_ChannelTableA
	MOVE.W	#$0001,dat_ChannelTableB
	MOVE.W	#$0001,dat_ChannelTableC
	MOVE.W	#$0001,dat_ChannelTableD
	MOVE.W	#$00ff,dat_RpDmaChanMask
	MOVE.W	#$0001,dat_KeyRepeatDelay
	BRA.W	pt_0134
pt_r0a286:
	CLR.B	dat_KeyCode
	TST.W	dat_KeyQual1
	BEQ.S	pt_r0a2c4
	CLR.W	dat_ScopeCh1
	CLR.W	dat_ScopeCh2
	CLR.W	dat_ScopeCh3
	CLR.W	dat_ScopeCh4
	CLR.W	dat_ChannelTableA
	CLR.W	dat_ChannelTableB
	CLR.W	dat_ChannelTableC
	CLR.W	dat_ChannelTableD
pt_r0a2c4:
	MOVEQ	#0,D0
	MOVE.W	dat_CursorColumn,D0
	DIVU.W	#$0006,D0
	MULU.W	#$000b,D0
	ADDQ.W	#4,D0
	BRA.W	pt_r02670
pt_r0a2da:
	CLR.B	dat_KeyCode
	MOVEQ	#0,D0
	MOVE.W	dat_PaletteIdxCounter,D0
	MOVE.L	D0,dat_RpSpeed
	MOVE.W	dat_SavedTempo,dat_CurrentTempo
	JSR	pt_SetTempo
	BSR.S	pt_0617
	CLR.B	dat_KeyCode
	LEA	(pt_0619+40,PC),A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_UpdatePaletteAll
	JMP	pt_ClearStatusMsg
pt_0617:
	LEA	dat_Channel1,A0
	BSR.S	pt_ClearChannelFlags
	LEA	dat_Channel2,A0
	BSR.S	pt_ClearChannelFlags
	LEA	dat_Channel3,A0
	BSR.S	pt_ClearChannelFlags
	LEA	dat_Channel4,A0
pt_ClearChannelFlags:
	CLR.B	(n_wavecontrol,A0)
	CLR.B	(n_glissfunk,A0)
	CLR.B	(n_finetune,A0)
	CLR.B	(n_loopcount,A0)
	RTS
pt_r0a34a:
	CLR.B	dat_KeyCode
	LEA	(pt_0619+58,PC),A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_UpdatePaletteAll
	JSR	pt_ClearStatusMsg
pt_0619:
	CLR.W	dat_SavedPatPos
	MOVE.W	#$0010,dat_ScreenModeTab1
	MOVE.W	#$0020,dat_ScreenModeTab2
	MOVE.W	#$0030,dat_ScreenModeTab3
	MOVE.W	#$003f,dat_KeyDispatchTab
	RTS
	DC.B	"EFFECTS RESTORED!",0
	DC.B	"POSITION RESTORED!",0,0
pt_061A:
	CLR.L	dat_RpChunkedSamples
	MOVEQ	#1,D7
	MOVEA.L	ABSEXECBASE.W,A6
pt_061B:
	MOVE.W	D7,D2
	LSL.W	#2,D2
	LEA	dat_ModulePtr,A0
	MOVE.L	(0,A0,D2.W),D1
	BEQ.S	pt_061C
	MOVE.L	(124,A0,D2.W),D0
	CLR.L	(0,A0,D2.W)
	CLR.L	(124,A0,D2.W)
	MOVEA.L	D1,A1
	JSR	(-210,A6)
pt_061C:
	MOVE.W	D7,D2
	LSL.W	#3,D2
	LEA	SECSTRT_4,A0
	ADDA.W	D2,A0
	MOVE.L	(A0),D1
	BEQ.S	pt_061D
	MOVE.L	(4,A0),D0
	CLR.L	(A0)
	CLR.L	(4,A0)
	MOVEA.L	D1,A1
	JSR	(-210,A6)
pt_061D:
	ADDQ.W	#1,D7
	CMP.W	#$0020,D7
	BNE.S	pt_061B
	MOVE.W	#$0001,dat_TimeDisplayInit
	JMP	pt_CheckFileLock
