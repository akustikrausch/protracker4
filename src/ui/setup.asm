pt_BtnMainSetup:
	CMPI.W	#$0005,dat_UIMode
	BEQ.W	pt_BtnSetupMainMenu
	BSR.W	pt_EditModeDispatcher
	BSR.W	pt_WaitMouseRelease
	MOVE.W	#$0005,dat_UIMode
	BSR.W	pt_InitAudioDisplay
	BSR.S	pt_0621
pt_UIUpdatePaletteMode:
	BSR.W	pt_UpdatePaletteCopper
	BSR.W	pt_ScrollDisplay
	JSR	pt_SetRedrawSel
	NOP
	BEQ.S	pt_0620
	RTS
pt_0620:
	BSR.W	pt_BackupPalette
	BSR.W	pt_PatClickSetup
	BSR.W	pt_PalEdDrawCursor
	BSR.W	pt_PalEdClearRefresh
	BSR.W	pt_0629
	BSR.W	pt_PatternDisplaySetup
	BSR.W	pt_0785
	BSR.W	pt_0702
	BSR.W	pt_07A7
	JSR	pt_UpdateTempoDisp
	BSR.W	pt_07AD
	BSR.W	pt_GetCursorDigit
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_PalEdDisplay
	BRA.W	pt_06D2
pt_0621:
	JMP	pt_SetLoadPage
	NOP
	NOP
	NOP
pt_InputSetup:
	TST.L	dat_TempBufPtr
	BEQ.S	pt_InputSetupGadgets
	CLR.L	dat_TempBufPtr
	BSR.W	pt_PatternDisplaySetup
pt_InputSetupGadgets:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	JSR	pt_SetGadTab
	BSR.W	pt_HandleUIButton
	JMP	pt_SetDispatch
pt_0624:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnSetupMainMenu
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnSetupLoadConfig
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnSetupSaveConfig
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnSetupCfgSlot
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnSetupResetAll
	CMP.W	#$0007,D2
	BNE.S	pt_0625
	JMP	pt_IncTempo
pt_0625:
	CMP.W	#$0008,D2
	BNE.S	pt_0626
	JMP	pt_DecTempo
pt_0626:
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnSetupSpeedUp
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnSetupSpeedDown
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnSetupTiming
	CMP.W	#$000e,D2
	BEQ.W	pt_069C
	CMP.W	#$000f,D2
	BEQ.W	pt_069A
	CMP.W	#$0010,D2
	BEQ.W	pt_0697
	CMP.W	#$0011,D2
	BEQ.W	pt_0695
	CMP.W	#$0012,D2
	BEQ.W	pt_06A3
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnSetupDef1
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnSetupDef3
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnSetupDef5
	CMP.W	#$0016,D2
	BEQ.W	pt_BtnSetupDef2
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnSetupDef4
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnSetupDef6
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnSetupClear
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnSetupTuneTable
	CMP.W	#$002b,D2
	BEQ.W	pt_BtnSetupAccidental
	CMP.W	#$002c,D2
	BEQ.W	pt_BtnSetupPrintSong
	CMP.W	#$002d,D2
	BEQ.W	pt_BtnSetupPrtField
	CMP.W	#$002e,D2
	BEQ.W	pt_BtnSetupPpEff
	CMP.W	#$002f,D2
	BEQ.W	pt_BtnSetupVuMeter
	CMP.W	#$004c,D2
	BEQ.W	pt_BtnScreenDrag
	CMP.W	#$0051,D2
	BEQ.W	pt_BtnSetupTuneNote
	CMP.W	#$0052,D2
	BEQ.W	pt_BtnSetupTuneVol
	CMP.W	#$0053,D2
	BEQ.W	pt_BtnSetupTuneVolUp
	CMP.W	#$0054,D2
	BEQ.W	pt_BtnSetupTuneVolDown
	CMP.W	#$0063,D2
	BEQ.W	pt_ScreenStateHandler
	CMP.W	#$0064,D2
	BEQ.W	pt_BtnSetupSplit
	CMP.W	#$0065,D2
	BEQ.W	pt_BtnSetupTransDel
	CMP.W	#$0066,D2
	BEQ.W	pt_BtnSetupScope
	CMP.W	#$0067,D2
	BEQ.W	pt_BtnSetupBlankZero
	CMP.W	#$0068,D2
	BEQ.W	pt_BtnSetupShowDec
	CMP.W	#$0069,D2
	BEQ.W	pt_BtnSetupFilter
	CMP.W	#$006a,D2
	BEQ.W	pt_BtnSetupNtsc
	CMP.W	#$006b,D2
	BEQ.W	pt_BtnSetupLaced
	CMP.W	#$006c,D2
	BEQ.W	pt_BtnSetupUndynIff
	CMP.W	#$006d,D2
	BEQ.W	pt_BtnSetupUndynMod
	CMP.W	#$006e,D2
	BEQ.W	pt_BtnSetupOverride
	CMP.W	#$006f,D2
	BEQ.W	pt_BtnSetupNoSamples
	CMP.W	#$0070,D2
	BEQ.W	pt_BtnSetupShowDirs
	CMP.W	#$0071,D2
	BEQ.W	pt_BtnSetupLoadLoop
	CMP.W	#$0072,D2
	BEQ.W	pt_BtnSetupAutoDir
	CMP.W	#$0073,D2
	BEQ.W	pt_BtnSetupAutoExit
	CMP.W	#$0074,D2
	BEQ.W	pt_BtnSetupMultiCache
	CMP.W	#$0075,D2
	BEQ.W	pt_BtnSetupCutToBuff
	CMP.W	#$0047,D2
	BEQ.W	pt_BtnSetupPalSwatch
	CMP.W	#$0048,D2
	BEQ.W	pt_BtnSetupPalBar
	CMP.W	#$0076,D2
	BEQ.W	pt_0633
	CMP.W	#$0086,D2
	BEQ.W	pt_0634
	CMP.W	#$0077,D2
	BEQ.W	pt_BtnSetupXpk
	CMP.W	#$0078,D2
	BEQ.W	pt_BtnSetupPack
	CMP.W	#$0080,D2
	BEQ.W	pt_BtnSetupKeyb
	CMP.W	#$0081,D2
	BEQ.W	pt_BtnSetupNoMod
	CMP.W	#$0082,D2
	BEQ.W	pt_BtnSetupNoDate
	CMP.W	#$0083,D2
	BEQ.W	pt_BtnSetupPatternMax
	CMP.W	#$0084,D2
	BEQ.W	pt_BtnSetupSoftInt
	CMP.W	#$0087,D2
	BEQ.W	pt_BtnSetupChannels
	CMP.W	#$0088,D2
	BEQ.W	pt_BtnSetupRepair
	CMP.W	#$0089,D2
	BEQ.W	pt_BtnSetupLChars
	CMP.W	#$008a,D2
	BEQ.W	pt_BtnSetupFont
	TST.W	dat_PalEdActive
	BNE.S	pt_0627
	CMP.W	#$0040,D2
	BEQ.W	pt_SetCopySource
	CMP.W	#$0042,D2
	BEQ.W	pt_SetSwapSource
	CMP.W	#$0043,D2
	BEQ.W	pt_BtnSetupPalCancel
	CMP.W	#$0044,D2
	BEQ.W	pt_BtnSetupPalDef
	CMP.W	#$0040,D2
	BEQ.W	pt_SetCopySource
	CMP.W	#$0049,D2
	BEQ.W	pt_BtnSetupPalSlider1
	CMP.W	#$004a,D2
	BEQ.W	pt_BtnSetupPalSlider2
	CMP.W	#$004b,D2
	BEQ.W	pt_BtnSetupPalSlider3
	RTS
pt_0627:
	CMP.W	#$0040,D2
	BEQ.W	pt_PalEdMarkCopy
	CMP.W	#$0041,D2
	BEQ.W	pt_PalEdMarkGradient
	CMP.W	#$0042,D2
	BEQ.W	pt_PalEdMarkSwap
	CMP.W	#$0043,D2
	BEQ.W	pt_PalEdCopyToAlt
	CMP.W	#$0044,D2
	BEQ.W	pt_PalEdCopyFromMod
	CMP.W	#$0045,D2
	BEQ.W	pt_PalEdRotateLeft
	CMP.W	#$0046,D2
	BEQ.W	pt_PalEdRotateRight
	CMP.W	#$0049,D2
	BEQ.W	pt_PalEdEditRed
	CMP.W	#$004a,D2
	BEQ.W	pt_PalEdEditGreen
	CMP.W	#$004b,D2
	BEQ.W	pt_PalEdEditBlue
	RTS
pt_BtnSetupMainMenu:
	MOVE.L	#$ffffffff,dat_PrevTimeDays
	MOVE.L	#$ffffffff,dat_PrevTimeMins
	MOVE.L	#$ffffffff,dat_PrevTimeTicks
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_0621
	BSR.W	pt_PalEdCopperClear
	CLR.L	dat_TempBufPtr
	JSR	pt_CheckDiskOpBusy
	BSR.W	pt_InitAudioDisplay
	BRA.W	pt_LeaveToMain
pt_0629:
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_062A
	RTS
pt_062A:
	BSR.W	pt_0631
	BSR.W	pt_065C
	BSR.W	pt_CheckSongModified
	BSR.W	pt_0664
	BSR.W	pt_0666
	BSR.W	pt_0668
	BSR.W	pt_066A
	BSR.W	pt_066C
	BSR.W	pt_066E
	BSR.W	pt_0670
	BSR.W	pt_0672
	BSR.W	pt_0674
	BSR.W	pt_0676
	BSR.W	pt_067C
	BSR.W	pt_0686
	BSR.W	pt_0687
	BSR.W	pt_0682
	BSR.W	pt_0678
	BSR.W	pt_0689
	BSR.W	pt_06A2
	BSR.W	pt_06A4
	BSR.W	pt_068C
	BSR.W	pt_06A0
	BSR.W	pt_06BF
	BSR.W	pt_06BD
	BSR.W	pt_06AD
	BSR.W	pt_06AF
	BSR.W	pt_06B1
	BSR.W	pt_06B8
	BSR.W	pt_0699
	BSR.W	pt_069E
	BSR.W	pt_0687
	BSR.W	pt_0641
	BSR.W	pt_DrawTempoDisplay
	BSR.W	pt_0651
	RTS
pt_ShowDisplayText:
	JSR	pt_SetGuardText
	LEA	(dat_DisplayOffText,PC),A0
	TST.B	D0
	BEQ.S	pt_ShowDisplayOff
	LEA	(dat_DisplayOnText,PC),A0
pt_ShowDisplayOff:
	MOVE.W	#$0003,dat_TextCharCount
	JMP	pt_DrawTextSetup
dat_062D:
	DC.B	$20
dat_DisplayOnText:
	DC.B	$4f
	DC.W	$4e20
dat_DisplayOffText:
	DC.L	$4f464620
pt_BtnSetupSplit:
	CLR.B	dat_KeyCode
	BCHG	#4,dat_InputReadyFlag
pt_0631:
	JSR	pt_LoadSpaceCharCode
	BSR.W	pt_0316
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_0632
	RTS
pt_0632:
	BTST	#4,dat_InputReadyFlag
	SNE	D0
	MOVE.W	#SV_SPLIT_POS,D6
	BSR.S	pt_ShowDisplayText
	JMP	pt_LoadSpaceCharCode
pt_0633:
	CMPI.B	#$64,dat_TempoCounter
	BGE.S	pt_DrawTempoDisplay
	ADDQ.B	#1,dat_TempoCounter
	BRA.S	pt_DrawTempoDisplay
pt_0634:
	TST.B	dat_TempoCounter
	BEQ.S	pt_DrawTempoDisplay
	SUBQ.B	#1,dat_TempoCounter
	BRA.W	pt_DrawTempoDisplay
pt_DrawTempoDisplay:
	MOVEQ	#0,D0
	MOVE.B	dat_TempoCounter,D0
	MOVE.W	D0,dat_DisplayParam
	MOVE.W	#$2371,dat_TextBytePos
	JSR	pt_SetTempoP1
	RTS
dat_TempoCounter:
	DS.W	1
pt_BtnSetupChannels:
	BSR.W	pt_WaitMouseRelease
	LEA	dat_12E1,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0638
	RTS
pt_0638:
	BCHG	#5,dat_ModeFlags
	MOVE.W	#$0001,dat_DiskOpState
	BSR.S	pt_ClearScreenBuf2
	BSR.W	pt_0641
	RTS
pt_ClearScreenBuf2:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	chip_ScreenBitplanes2,A0
	LEA	(15376,A0),A0
	MOVE.L	#$00002c0c,D0
pt_063A:
	CLR.L	(A0)+
	DBF	D0,pt_063A
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BTST	#5,dat_ModeFlags
	BEQ.W	pt_063E
	BRA.S	pt_063B
	BCLR	#5,dat_ModeFlags
	BSR.S	pt_ClearScreenBuf2
	BRA.W	pt_063E
	BSET	#5,dat_ModeFlags
	BSR.S	pt_ClearScreenBuf2
pt_063B:
	MOVE.W	#$0004,dat_RpNumChannels
	MOVE.W	#$0100,D0
	MULU	dat_RpNumChannels,D0
	MOVE.W	D0,dat_RowDataVar
	LEA	dat_ScopeCh1,A0
	MOVE.W	#$003a,(2,A0)
	LEA	dat_ScopeCh2,A0
	MOVE.W	#$0082,(2,A0)
	LEA	dat_ScopeCh3,A0
	MOVE.W	#$00ca,(2,A0)
	LEA	dat_ScopeCh4,A0
	MOVE.W	#$0112,(2,A0)
	TST.W	dat_SamplerActive
	BEQ.S	pt_063C
	JSR	pt_BtnSmpExit
pt_063C:
	TST.W	dat_DiskOpState
	BEQ.S	pt_063D
	JSR	pt_InitModulePart
pt_063D:
	MOVEA.L	#dat_IMPFormatData3,A0
	BSR.W	pt_CheckModuleTypeWrap
	JSR	pt_UpdateDisplayMain
	CLR.W	dat_CursorColumn
	BRA.W	pt_ReturnFromPlay
pt_063E:
	MOVE.W	#$0008,dat_RpNumChannels
	MOVE.W	#$0100,D0
	MULU	dat_RpNumChannels,D0
	MOVE.W	D0,dat_RowDataVar
	LEA	dat_ScopeCh1,A0
	MOVE.W	#$0026,(2,A0)
	LEA	dat_ScopeCh2,A0
	MOVE.W	#$004a,(2,A0)
	LEA	dat_ScopeCh3,A0
	MOVE.W	#$006e,(2,A0)
	LEA	dat_ScopeCh4,A0
	MOVE.W	#$0092,(2,A0)
	TST.W	dat_SamplerActive
	BEQ.S	pt_063F
	JSR	pt_BtnSmpExit
pt_063F:
	TST.W	dat_DiskOpState
	BEQ.S	pt_0640
	JSR	pt_InitModulePart
pt_0640:
	MOVEA.L	#dat_IMPFormatData2,A0
	BSR.W	pt_CheckModuleTypeWrap
	JSR	pt_UpdateDisplayMain
	CLR.W	dat_CursorColumn
	BRA.W	pt_ReturnFromPlay
pt_0641:
	JSR	pt_MixSetupText
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0642
	MOVEQ	#4,D0
pt_0642:
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_CHANNELS_X,D0
	MOVE.W	#SV_CHANNELS_Y,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP1
pt_InitModulePart:
	CLR.W	dat_DiskOpState
	BSR.W	pt_InitNewModule
	BSR.W	pt_SetupSampleView
	BSR.W	pt_SetPaletteBright
	BSR.W	pt_ClearBufferLoop
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_0644
	MOVEA.L	D1,A1
	MOVE.L	dat_SampleEditCfg,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_0644:
	TST.B	dat_PatternBufFlag
	BEQ.W	pt_0646
	MOVE.B	#$01,dat_PatternBufFlag
	MOVE.L	#$0001943c,dat_SampleEditCfg
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0645
	MOVE.L	#$0003243c,dat_SampleEditCfg
pt_0645:
	MOVE.L	#$00000063,dat_SampleEditState
	MOVE.L	dat_SampleEditCfg,D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_0648
	JSR	pt_MemOnly64
pt_0646:
	CLR.B	dat_PatternBufFlag
	MOVE.L	#$0001043c,dat_SampleEditCfg
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0647
	MOVE.L	#$0002043c,dat_SampleEditCfg
pt_0647:
	MOVE.L	#$0000003f,dat_SampleEditState
	MOVE.L	dat_SampleEditCfg,D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_0648
	JSR	pt_SetupPaletteMode
pt_0648:
	JSR	pt_DrawSampleHex
	RTS
dat_DiskOpState:
	DS.W	1
pt_BtnSetupUndynMod:
	BCHG	#4,dat_UIBitFlags
	BRA.W	pt_0687
	NOP
	BEQ.S	pt_064B
	MOVE.L	#$00010002,dat_DiskOpViewMode
	BRA.S	pt_ClearUICheckBit
pt_064B:
	MOVE.L	#$00010002,dat_DiskOpViewMode
	BRA.W	pt_ClearUICheckBit
pt_ClearUICheckBit:
	BCLR	#3,dat_UICheckFlag
	BTST	#3,dat_UICheckFlag
	SNE	D0
	MOVE.W	#SV_UNDYNMOD_POS,D6
	BRA.W	pt_ShowDisplayText
dat_DiskOpViewMode:
	DC.L	$00010002
pt_BtnSetupFont:
	BSR.S	pt_064F
	BSR.S	pt_0651
	BRA.W	pt_ClearScreenBuf2
pt_064F:
	ADDQ.B	#1,dat_WaveformPhase
	CMPI.B	#$03,dat_WaveformPhase
	BLT.S	pt_0650
	CLR.B	dat_WaveformPhase
pt_0650:
	RTS
pt_0651:
	BSR.S	pt_0652
	LSL.L	#3,D0
	LEA	dat_0653,A0
	ADDA.L	D0,A0
	MOVE.W	#$0008,dat_TextCharCount
	MOVE.W	#SV_FONT_POS&$7fff,dat_TextBytePos
	MOVE.L	A0,dat_TextStringPtr
	JMP	pt_SetTextP2
pt_0652:
	MOVEQ	#0,D0
	MOVE.B	dat_WaveformPhase,D0
	MOVE.L	D0,D1
	LSL.L	#8,D1
	LSL.L	#3,D1
	MOVE.L	D1,dat_TrackFontOffset
	RTS
dat_0653:
	DC.B	"TOPAZ   POTNOODLBOLD    "
pt_BtnSetupScope:
	BSR.S	pt_0659
	BRA.S	pt_065C
dat_ScopeMode:
	DS.W	1
dat_WaveformPhase:
	DS.W	1
dat_TrackFontOffset:
	DS.L	1
dat_0658:
	DC.W	$ffff
pt_0659:
	ADDQ.B	#1,dat_ScopeMode
	CMPI.B	#$06,dat_ScopeMode
	BLT.S	pt_065A
	CLR.B	dat_ScopeMode
pt_065A:
	RTS
pt_BtnMainCredits:
	BSR.S	pt_0659
	JSR	pt_0114
	BRA.W	pt_WaitMouseRelease
pt_065C:
	CLR.B	dat_KeyCode
	JSR	pt_LoadSpaceCharCode
	JSR	pt_SetIsP1
	NOP
	BEQ.S	pt_065D
	RTS
pt_065D:
	MOVE.W	#SV_SCOPEVAL_POS,dat_TextBytePos
	MOVE.W	#$0008,dat_TextCharCount
	LEA	dat_065F,A0
	MOVEQ	#0,D0
	CMPI.B	#$06,dat_ScopeMode
	BLT.S	pt_065E
	CLR.B	dat_ScopeMode
pt_065E:
	MOVE.B	(dat_ScopeMode,PC),D0
	LSL.L	#3,D0
	ADDA.L	D0,A0
	MOVE.L	A0,dat_TextStringPtr
	JMP	pt_DrawTextRender
dat_065F:
	DC.B	"    NONESTANDARD   SOLID   LINES    2WAY  2WAY-S"
pt_BtnSetupFilter:
	CLR.B	dat_KeyCode
	BCHG	#1,dat_ModeFlags
pt_CheckSongModified:
	BTST	#1,dat_ModeFlags
	SNE	D0
	MOVE.B	D0,D1
	NOT.B	D1
	AND.B	#$01,D1
	LSL.B	#1,D1
	BCLR	#1,CIAA_PRA
	OR.B	D1,CIAA_PRA
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_0662
	RTS
pt_0662:
	MOVE.W	#SV_FILTER_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupTransDel:
	BCHG	#1,dat_InputReadyFlag
pt_0664:
	BTST	#1,dat_InputReadyFlag
	SNE	D0
	MOVE.W	#SV_TRANSDEL_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupShowDec:
	BCHG	#7,dat_ModeFlags
	MOVE.W	#$0001,dat_TimeDisplayInit
pt_0666:
	BTST	#7,dat_ModeFlags
	SNE	D0
	MOVE.W	#SV_SHOWDEC_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupAutoDir:
	BCHG	#3,dat_UIStateFlag
pt_0668:
	BTST	#3,dat_UIStateFlag
	SNE	D0
	MOVE.W	#SV_AUTODIR_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupAutoExit:
	BCHG	#4,dat_UIStateFlag
pt_066A:
	BTST	#4,dat_UIStateFlag
	SNE	D0
	MOVE.W	#SV_AUTOEXIT_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupOverride:
	BCHG	#7,dat_UIStateFlag
pt_066C:
	BTST	#7,dat_UIStateFlag
	SNE	D0
	MOVE.W	#SV_OVERRIDE_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupNoSamples:
	BCHG	#5,dat_UIStateFlag
pt_066E:
	BTST	#5,dat_UIStateFlag
	SNE	D0
	MOVE.W	#SV_NOSAMPLES_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupBlankZero:
	BCHG	#3,dat_InputReadyFlag
	PEA	pt_PatViewDrawAll
pt_0670:
	BTST	#3,dat_InputReadyFlag
	SNE	D0
	MOVE.W	#SV_BLANKZERO_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupShowDirs:
	BCHG	#2,dat_UIStateFlag
pt_0672:
	BTST	#2,dat_UIStateFlag
	SNE	D0
	MOVE.W	#SV_SHOWDIRS_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupCutToBuff:
	BCHG	#5,dat_InputReadyFlag
pt_0674:
	BTST	#5,dat_InputReadyFlag
	SNE	D0
	MOVE.W	#SV_CUTTOBUFF_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupLoadLoop:
	BCHG	#6,dat_UIStateFlag
pt_0676:
	BTST	#6,dat_UIStateFlag
	SNE	D0
	MOVE.W	#SV_LOADLOOP_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupNtsc:
	BCHG	#0,dat_UICheckFlag
pt_0678:
	BTST	#0,dat_UICheckFlag
	SNE	D0
	MOVE.W	#SV_NTSC_POS,D6
	BSR.W	pt_ShowDisplayText
	CLR.W	dat_ScrollDelta
	CLR.W	dat_ScrollOffset
	BTST	#0,dat_UICheckFlag
	BEQ.S	pt_0679
	MOVEA.L	dat_GfxLibBase,A6
	CLR.W	BEAMCON0
	BRA.S	pt_067A
pt_0679:
	MOVE.W	#$0020,BEAMCON0
pt_067A:
	BSR.W	pt_ScrollDisplay
	RTS
pt_BtnSetupLaced:
	BCHG	#1,dat_UICheckFlag
pt_067C:
	BTST	#1,dat_UICheckFlag
	SNE	D0
	MOVE.B	D0,D1
	AND.W	#$0004,D1
	MOVEQ	#-5,D2
	AND.W	D2,chip_SpriteCtrlWord2
	OR.W	D1,chip_SpriteCtrlWord2
	TST.W	dat_SamplerActive
	BNE.S	pt_067D
	AND.W	D2,chip_CopperColor4
	OR.W	D1,chip_CopperColor4
	AND.W	D2,chip_CopperColor7Pal
	OR.W	D1,chip_CopperColor7Pal
	AND.W	D2,chip_CopperPalette4
	OR.W	D1,chip_CopperPalette4
pt_067D:
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_067E
	RTS
pt_067E:
	MOVE.W	#SV_LACED_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnOpt1RecHold:
	BCHG	#0,dat_InputReadyFlag
pt_0680:
	BTST	#0,dat_InputReadyFlag
	SNE	D0
	MOVE.W	#$2017,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupSoftInt:
	BCHG	#3,dat_ModeFlags
pt_0682:
	BTST	#3,dat_ModeFlags
	SNE	D0
	TST.B	D0
	BNE.S	pt_0683
	MOVEQ	#0,D0
	CLR.B	D0
	BRA.S	pt_0684
pt_0683:
	MOVEQ	#0,D0
	MOVE.B	#$01,D0
pt_0684:
	LEA	(str_XPKFormat,PC),A0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_SOFTINT_X,D0
	MOVE.W	#SV_SOFTINT_Y,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP1
pt_BtnSetupUndynIff:
	BCHG	#3,dat_UIBitFlags
pt_0686:
	BTST	#3,dat_UIBitFlags
	SNE	D0
	MOVE.W	#SV_UNDYNIFF_POS,D6
	BRA.W	pt_ShowDisplayText
pt_0687:
	BTST	#4,dat_UIBitFlags
	SNE	D0
	MOVE.W	#SV_UNDYNMOD_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupMultiCache:
	BCHG	#2,dat_UIBitFlags
pt_0689:
	BTST	#2,dat_UIBitFlags
	SNE	D0
	MOVE.W	#SV_MULTICACHE_POS,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupVuMeter:
	ADDQ.B	#1,dat_CursorPhase
	CMPI.B	#$03,dat_CursorPhase
	BMI.S	pt_068B
	CLR.B	dat_CursorPhase
pt_068B:
	JSR	pt_InitPalettes
pt_068C:
	LEA	(dat_068D,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_CursorPhase,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_VUMETER_X,D0
	MOVE.W	#SV_VUMETER_Y,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP1
dat_068D:
	DC.B	"NoneFakeReal",0
dat_068E:
	DC.B	"BLZWCBR0CRM2CRMSDMCBDUKEFASTFEALFRLEGZIPHFMNHUFFILHLBLZRIMPLL"
	DC.B	"HLBLZCBMASHNUKEPASTPPMQPWPKRAKERDCNRLENSHRISQSHSMPL",0
dat_068F:
	DC.B	"PP20XPK ",0,0
str_XPKFormat:
	DC.B	"OFF ON  ",0,0
dat_0691:
	DC.B	"USA GER EXT ",0
dat_0692:
	DC.B	"64  100 ",0
dat_0693:
	DC.B	"4CHN8CHN",0
dat_0694:
	DS.B	1
pt_0695:
	MOVE.W	dat_CurrentSpeed,D0
	ADD.W	#$000a,D0
	CMP.W	#$270f,D0
	BLS.S	pt_SetCurrentSpeed
	MOVE.W	#$270f,D0
pt_SetCurrentSpeed:
	MOVE.W	D0,dat_CurrentSpeed
	BRA.S	pt_0699
pt_0697:
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSpeed,D0
	ADDQ.W	#1,D0
	DIVU	#$000a,D0
	SUBQ.W	#1,D0
	BPL.S	pt_0698
	MOVEQ	#0,D0
	BRA.S	pt_SetCurrentSpeed
pt_0698:
	MULU	#$000a,D0
	BRA.S	pt_SetCurrentSpeed
pt_0699:
	MOVE.W	dat_CurrentSpeed,dat_DisplayParam
	MOVE.W	#$0b60,dat_TextBytePos
	JMP	pt_SetDecP1
pt_069A:
	MOVE.W	dat_RpDmaWaitCount,D0
	ADD.W	#$000a,D0
	CMP.W	#$270f,D0
	BLS.S	pt_SetPlaybackRow
	MOVE.W	#$270f,D0
pt_SetPlaybackRow:
	MOVE.W	D0,dat_RpDmaWaitCount
	BRA.S	pt_069E
pt_069C:
	MOVEQ	#0,D0
	MOVE.W	dat_RpDmaWaitCount,D0
	ADDQ.W	#1,D0
	DIVU	#$000a,D0
	SUBQ.W	#1,D0
	BPL.S	pt_069D
	MOVEQ	#0,D0
	BRA.S	pt_SetPlaybackRow
pt_069D:
	MULU	#$000a,D0
	BRA.S	pt_SetPlaybackRow
pt_069E:
	MOVE.W	dat_RpDmaWaitCount,dat_DisplayParam
	MOVE.W	#$0b54,dat_TextBytePos
	JMP	pt_SetDecP1
pt_BtnSetupXpk:
	ADDQ.B	#1,dat_TimerCountHi
	CMPI.B	#$1c,dat_TimerCountHi
	BMI.S	pt_06A0
	CLR.B	dat_TimerCountHi
pt_06A0:
	LEA	(dat_068E,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_TimerCountHi,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_XPK_X,D0
	MOVE.W	#SV_XPK_Y&$7fff,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP2
pt_BtnSetupLChars:
	BCHG	#1,dat_FontMode
pt_06A2:
	BTST	#1,dat_FontMode
	SNE	D0
	MOVE.W	#$1ff8,D6
	BRA.W	pt_ShowDisplayText
pt_06A3:
	BCHG	#1,dat_TimerCountLo
pt_06A4:
	BTST	#1,dat_TimerCountLo
	SNE	D0
	MOVE.W	#$1c88,D6
	BRA.W	pt_ShowDisplayText
pt_BtnSetupRepair:
	LEA	dat_12E2,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_06A6
	RTS
pt_06A6:
	BSR.W	pt_BtnSetupMainMenu
pt_06A7:
	BSR.W	pt_BtnMainStop
	MOVE.W	dat_CurrentSample,dat_06AB
	CLR.W	dat_CurrentSample
	JSR	pt_SampleClearLoop
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
pt_06A8:
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	TST.W	(6,A0)
	BNE.S	pt_06A9
	ADDQ.W	#1,(6,A0)
pt_06A9:
	ADDQ.W	#1,dat_CurrentSample
	CMPI.W	#$001f,dat_CurrentSample
	BEQ.S	pt_06AA
	ADDQ.W	#1,dat_CurrentSample
	BSR.W	pt_RefreshDisplay
	JSR	pt_DrawSampleHex
	MOVE.W	dat_CurrentSample,dat_PrevSampleNum
	JSR	pt_InitTimeDisplay
	BRA.S	pt_06A8
pt_06AA:
	MOVE.W	dat_06AB,dat_CurrentSample
	JSR	pt_DrawSampleHex
	MOVE.W	dat_CurrentSample,dat_PrevSampleNum
	JSR	pt_InitTimeDisplay
	RTS
dat_06AB:
	DS.W	1
pt_BtnSetupKeyb:
	ADDQ.B	#1,dat_PatternBufSize
	CMPI.B	#$03,dat_PatternBufSize
	BMI.S	pt_06AD
	CLR.B	dat_PatternBufSize
pt_06AD:
	LEA	(dat_0691,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_PatternBufSize,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#$011a,D0
	MOVE.W	#SV_KEYB_Y,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP1
pt_BtnSetupNoMod:
	ADDQ.B	#1,dat_VBLCounterHi
	CMPI.B	#$02,dat_VBLCounterHi
	BMI.S	pt_06AF
	CLR.B	dat_VBLCounterHi
pt_06AF:
	LEA	(str_XPKFormat,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_VBLCounterHi,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_NOMOD_X,D0
	MOVE.W	#SV_NOMOD_Y&$7fff,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP2
pt_BtnSetupNoDate:
	ADDQ.B	#1,dat_VBLCounterLo
	CMPI.B	#$02,dat_VBLCounterLo
	BMI.S	pt_06B1
	CLR.B	dat_VBLCounterLo
pt_06B1:
	LEA	(str_XPKFormat,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_VBLCounterLo,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_NODATE_X,D0
	MOVE.W	#SV_NODATE_Y&$7fff,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP2
pt_BtnSetupPatternMax:
	BSR.W	pt_WaitMouseRelease
	LEA	dat_12E0,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_06B3
	RTS
pt_06B3:
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_06B4
	MOVEA.L	D1,A1
	MOVE.L	dat_SampleEditCfg,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_06B4:
	BSR.W	pt_SetupSampleView
	EORI.B	#$01,dat_PatternBufFlag
	MOVE.L	#$0001043c,dat_SampleEditCfg
	MOVE.L	#$0000003f,dat_SampleEditState
	BTST	#5,dat_ModeFlags
	BNE.S	pt_06B5
	MOVE.L	#$0002043c,dat_SampleEditCfg
	MOVE.L	#$0000003f,dat_SampleEditState
	BRA.S	pt_LoadSampleEditCfg
pt_06B5:
	TST.B	dat_PatternBufFlag
	BEQ.S	pt_LoadSampleEditCfg
	MOVE.L	#$0001943c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
	BTST	#5,dat_ModeFlags
	BNE.S	pt_LoadSampleEditCfg
	MOVE.L	#$0003243c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
pt_LoadSampleEditCfg:
	MOVE.L	dat_SampleEditCfg,D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_06B7
	JSR	pt_SetupPaletteMode
	BRA.W	pt_06B3
pt_06B7:
	BSR.W	pt_InitNewModule
	BSR.W	pt_SetupSampleView
	JSR	pt_DrawSampleHex
pt_06B8:
	LEA	(dat_0692,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_PatternBufFlag,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#$011a,D0
	MOVE.W	#SV_PATTERN_Y,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP1
dat_SampleEditCfg:
	DC.L	$0001043c
dat_SampleEditState:
	DS.L	1
dat_SampleVolume:
	DC.W	$3f00
pt_BtnSetupPack:
	ADDQ.B	#1,dat_PatternBufIdx
	CMPI.B	#$02,dat_PatternBufIdx
	BMI.S	pt_06BD
	CLR.B	dat_PatternBufIdx
pt_06BD:
	LEA	(dat_068F,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_PatternBufIdx,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_PACK_X,D0
	MOVE.W	#SV_PACK_Y&$7fff,D1
	MOVEQ	#4,D3
	JMP	pt_SetBlitP2
pt_BtnSetupPpEff:
	ADDQ.B	#1,dat_CursorAnimState
	CMPI.B	#$05,dat_CursorAnimState
	BMI.S	pt_06BF
	CLR.B	dat_CursorAnimState
pt_06BF:
	LEA	(dat_06C0,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_CursorAnimState,D0
	MULU	#$0006,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#SV_PPEFF_X,D0
	MOVEQ	#SV_PPEFF_Y&$7fff,D1
	MOVEQ	#6,D3
	JMP	pt_SetBlitP2
dat_06C0:
	DC.B	"  FASTMEDIUM  GOODBETTER  BEST",0,0
pt_BtnSetupClear:
	BSR.W	pt_WaitMouseRelease
	LEA	dat_12E7,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_06C2
	RTS
pt_06C2:
	LEA	dat_AudioBufWork,A0
	MOVEQ	#15,D0
pt_06C3:
	CLR.B	(A0)+
	DBF	D0,pt_06C3
pt_PatternDisplaySetup:
	BSR.S	pt_06C6
	LEA	dat_AudioBufWork,A3
	MOVEA.L	dat_NoteNamesPtr,A4
	MOVEQ	#0,D5
	MOVE.W	#$0488,D6
	CLR.W	dat_DisplayParam
pt_06C5:
	MOVE.W	D6,dat_TextBytePos
	MOVE.B	(0,A3,D5.W),dat_ButtonStateFlag
	JSR	pt_DrawDecValue3
	ADDQ.W	#4,D6
	MOVE.W	D6,D1
	MOVEQ	#0,D0
	MOVE.B	(1,A3,D5.W),D0
	LSL.W	#2,D0
	LEA	(0,A4,D0.W),A0
	MOVEQ	#4,D0
	JSR	pt_DrawTextAt
	ADDQ.L	#5,D6
	MOVE.W	D6,D1
	MOVEQ	#0,D0
	MOVE.B	(2,A3,D5.W),D0
	LSL.W	#2,D0
	LEA	(0,A4,D0.W),A0
	MOVEQ	#4,D0
	JSR	pt_DrawTextAt
	ADD.W	#$0367,D6
	ADDQ.W	#4,D5
	CMP.W	#$0010,D5
	BNE.S	pt_06C5
	RTS
pt_06C6:
	LEA	dat_152A,A0
	LEA	dat_152B,A1
	LEA	dat_AudioBufWork,A2
	MOVEQ	#0,D0
pt_06C7:
	MOVE.B	D0,(0,A0,D0.W)
	CLR.B	(0,A1,D0.W)
	ADDQ.W	#1,D0
	CMP.W	#$0025,D0
	BLS.S	pt_06C7
	MOVE.B	(1,A2),-(A7)
	MOVE.B	(5,A2),-(A7)
	MOVE.B	(9,A2),-(A7)
	MOVE.B	(13,A2),-(A7)
	MOVEQ	#3,D4
pt_06C8:
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
pt_06C9:
	CMP.B	(1,A2,D1.W),D0
	BLS.S	pt_06CA
	MOVE.L	D1,D2
	MOVE.B	(1,A2,D1.W),D0
pt_06CA:
	ADDQ.W	#4,D1
	CMP.W	#$0010,D1
	BNE.S	pt_06C9
	MOVEQ	#0,D0
	MOVE.B	(1,A2,D2.W),D0
	MOVE.B	#$7f,(1,A2,D2.W)
	MOVE.B	(2,A2,D2.W),D1
pt_06CB:
	MOVE.B	D1,(0,A0,D0.W)
	MOVE.B	(0,A2,D2.W),(0,A1,D0.W)
	ADDQ.W	#1,D1
	CMP.W	#$0024,D1
	BCS.S	pt_06CC
	MOVEQ	#35,D1
pt_06CC:
	ADDQ.W	#1,D0
	CMP.W	#$0024,D0
	BCS.S	pt_06CB
	DBF	D4,pt_06C8
	MOVE.B	(A7)+,(13,A2)
	MOVE.B	(A7)+,(9,A2)
	MOVE.B	(A7)+,(5,A2)
	MOVE.B	(A7)+,(1,A2)
	RTS
pt_BtnSetupTuneTable:
	LEA	dat_AudioBufWork,A2
	SUBQ.W	#1,D1
	DIVU	#$000b,D1
	SUBQ.W	#1,D1
	MOVE.W	D1,D7
	LSL.W	#2,D7
	MULU	#$0370,D1
	ADD.W	#$0460,D1
	CMP.W	#$0182,D0
	BCC.S	pt_06D0
	CMP.W	#$015a,D0
	BCC.S	pt_06CF
	ADD.W	#$0028,D1
	MOVE.W	D1,dat_TextBytePos
	BSR.W	pt_ClearPatternKey
	CMP.B	#$1f,D0
	BLS.S	pt_06CE
	MOVE.B	#$1f,D0
pt_06CE:
	MOVE.B	D0,(0,A2,D7.W)
	BRA.W	pt_PatternDisplaySetup
pt_06CF:
	MOVE.L	D1,-(A7)
	BSR.W	pt_PatternDisplaySetup
	MOVE.L	(A7)+,D1
	ADD.W	#$002c,D1
	MOVEQ	#3,D0
	LEA	dat_DashSeparator,A0
	JSR	pt_DrawTextAt
	LEA	(1,A2,D7.W),A0
	MOVE.L	A0,dat_TempBufPtr
	BRA.W	pt_WaitMouseRelease
pt_06D0:
	MOVE.L	D1,-(A7)
	BSR.W	pt_PatternDisplaySetup
	MOVE.L	(A7)+,D1
	ADD.W	#$0031,D1
	MOVEQ	#3,D0
	LEA	dat_DashSeparator,A0
	JSR	pt_DrawTextAt
	LEA	(2,A2,D7.W),A0
	MOVE.L	A0,dat_TempBufPtr
	BRA.W	pt_WaitMouseRelease
pt_BtnSetupAccidental:
	MOVE.L	#pt_PatternRenderEntry,dat_NoteNamesPtr
	BCHG	#2,dat_InputReadyFlag
	BNE.S	pt_06D2
	MOVE.L	#dat_132B,dat_NoteNamesPtr
pt_06D2:
	LEA	(dat_06D4,PC),A0
	BTST	#2,dat_InputReadyFlag
	BEQ.S	pt_06D3
	LEA	(dat_06D5,PC),A0
pt_06D3:
	MOVE.W	#SV_ACCIDENTAL_X,D0
	MOVEQ	#SV_ACCIDENTAL_Y,D1
	MOVEQ	#1,D3
	JSR	pt_SetBlitP1
	JMP	pt_PatViewDrawAll
dat_06D4:
	DC.W	$2300
dat_06D5:
	DC.W	$4200
pt_BtnSetupDef1:
	MOVE.L	#dat_1475,dat_ClipboardBufPtr
	BSR.S	pt_ClipboardPtrSetup
	BSR.W	pt_ClipboardOpsEntry
	BSR.W	pt_ShowStatusPalette
	BRA.W	pt_UIUpdatePaletteMode
pt_BtnSetupDef3:
	MOVE.L	#dat_1477,dat_ClipboardBufPtr
	BSR.S	pt_ClipboardPtrSetup
	BSR.W	pt_ClipboardOpsEntry
	BSR.S	pt_ShowStatusPalette
	BRA.W	pt_UIUpdatePaletteMode
pt_BtnSetupDef5:
	MOVE.L	#dat_1479,dat_ClipboardBufPtr
	BSR.S	pt_ClipboardPtrSetup
	BSR.W	pt_ClipboardOpsEntry
	BSR.S	pt_ShowStatusPalette
	BRA.W	pt_UIUpdatePaletteMode
pt_BtnSetupDef2:
	MOVE.L	#dat_1476,dat_ClipboardBufPtr
	BSR.S	pt_ClipboardPtrSetup
	BSR.W	pt_ClipboardOpsEntry
	BSR.S	pt_ShowStatusPalette
	BRA.W	pt_UIUpdatePaletteMode
pt_BtnSetupDef4:
	MOVE.L	#dat_1478,dat_ClipboardBufPtr
	BSR.S	pt_ClipboardPtrSetup
	BSR.W	pt_ClipboardOpsEntry
	BSR.S	pt_ShowStatusPalette
	BRA.W	pt_UIUpdatePaletteMode
pt_BtnSetupDef6:
	MOVE.L	#dat_147A,dat_ClipboardBufPtr
	BSR.S	pt_ClipboardPtrSetup
	BSR.W	pt_ClipboardOpsEntry
	BSR.S	pt_ShowStatusPalette
	BRA.W	pt_UIUpdatePaletteMode
pt_ClipboardPtrSetup:
	MOVEA.L	(dat_ClipboardBufPtr,PC),A0
	LEA	(16,A0),A0
	NOP
	NOP
	NOP
	NOP
	MOVE.L	A0,dat_FileIOVar1
	LEA	(16,A0),A0
	MOVE.L	A0,dat_FileIOVar2
	RTS
pt_ShowStatusPalette:
	LEA	dat_06DE,A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_UpdatePaletteAll
	JMP	pt_ClearStatusMsg
dat_06DE:
	DC.B	"USE QUICKSET-COLORS",0
pt_BtnSetupLoadConfig:
	LEA	dat_12EE,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_06E0
	RTS
pt_06E0:
	BSR.W	pt_WaitMouseRelease
	LEA	(dat_070B,PC),A0
	JSR	pt_ShowStatusMsg
pt_06E1:
	JSR	pt_CfgPrepare
	NOP
	LEA	dat_FilePathBuf2,A1
	MOVE.W	#$533a,(A1)+
	LEA	(dat_0708,PC),A0
	MOVEQ	#12,D0
pt_06E2:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_06E2
	JSR	pt_OpenConfigRead
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_06F1
	BSR.W	pt_SetPaletteDim
	BSR.W	pt_ReadFileHeader
	BEQ.W	pt_ShowErrorStatus
	CMPI.L	#$464f524d,(A0)
	BNE.W	pt_06F2
	CMPI.L	#$50544346,(8,A0)
	BNE.W	pt_06F2
pt_LoadNextChunk:
	BSR.W	pt_ReadFileChunk
	BMI.W	pt_ShowErrorStatus
	BEQ.S	pt_FileLoadComplete
	MOVE.L	D0,dat_FileLoadBuf
	CMPI.L	#$4d495343,(A0)
	BEQ.W	pt_06ED
	CMPI.L	#$5343524e,(A0)
	BEQ.W	pt_06EE
	CMPI.L	#$45444954,(A0)
	BEQ.W	pt_06EF
	CMPI.L	#$4449534b,(A0)
	BEQ.W	pt_06F0
	BSR.W	pt_SeekInFile
	BNE.W	pt_ShowErrorStatus
	BRA.S	pt_LoadNextChunk
pt_FileLoadComplete:
	CLR.L	dat_FileWriteSize
	MOVE.L	dat_FileHandle,D1
	BEQ.S	pt_06E5
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
pt_06E5:
	CLR.W	dat_FileLoadSuccess
	BTST	#5,dat_ModeFlags
	BNE.S	pt_06E6
	MOVE.W	#$0001,dat_FileLoadSuccess
pt_06E6:
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	BSR.W	pt_0719
	BRA.S	pt_06E7
	CLR.W	dat_FileLoadSuccess
	BTST	#5,dat_ModeFlags
	BNE.S	pt_06E7
	MOVE.W	#$0001,dat_FileLoadSuccess
pt_06E7:
	BSR.W	pt_CheckSongModified
	JSR	pt_CheckDiskOpBusy
	BTST	#5,dat_ModeFlags
	BNE.S	pt_06E8
	CMPI.W	#$0001,dat_FileLoadSuccess
	BEQ.S	pt_PaletteAfterAudio
	MOVE.W	#$0001,dat_DiskOpState
	BSR.W	pt_ClearScreenBuf2
	BRA.S	pt_PaletteAfterAudio
pt_06E8:
	TST.W	dat_FileLoadSuccess
	BEQ.S	pt_PaletteAfterAudio
	MOVE.W	#$0001,dat_DiskOpState
	BSR.W	pt_ClearScreenBuf2
pt_PaletteAfterAudio:
	BSR.W	pt_UIUpdatePaletteMode
	BTST	#2,dat_InputReadyFlag
	BEQ.S	pt_06EA
	MOVE.L	#dat_132B,dat_NoteNamesPtr
pt_06EA:
	RTS
dat_FileLoadSuccess:
	DS.W	1
dat_FileLoadBuf:
	DS.L	1
pt_06ED:
	MOVE.L	(dat_FileIOVar5,PC),D2
	BEQ.W	pt_LoadNextChunk
	MOVEA.L	D2,A0
	MOVE.L	(dat_FileLoadBuf,PC),D0
	BSR.W	pt_ReadAtPosition
	BEQ.W	pt_FileLoadComplete
	BMI.S	pt_ShowErrorStatus
	BRA.W	pt_LoadNextChunk
pt_06EE:
	MOVE.L	(dat_ClipboardBufPtr,PC),D2
	BEQ.W	pt_LoadNextChunk
	MOVEA.L	D2,A0
	MOVE.L	(dat_FileLoadBuf,PC),D0
	BSR.W	pt_ReadAtPosition
	BEQ.W	pt_FileLoadComplete
	BMI.S	pt_ShowErrorStatus
	BRA.W	pt_LoadNextChunk
pt_06EF:
	MOVE.L	(dat_FileIOVar4,PC),D2
	BEQ.W	pt_LoadNextChunk
	MOVEA.L	D2,A0
	MOVE.L	(dat_FileLoadBuf,PC),D0
	BSR.W	pt_ReadAtPosition
	BEQ.W	pt_FileLoadComplete
	BMI.S	pt_ShowErrorStatus
	BRA.W	pt_LoadNextChunk
pt_06F0:
	MOVE.L	(dat_FileIOVar3,PC),D2
	BEQ.W	pt_LoadNextChunk
	MOVEA.L	D2,A0
	MOVE.L	(dat_FileLoadBuf,PC),D0
	BSR.W	pt_ReadAtPosition
	BEQ.W	pt_FileLoadComplete
	BMI.S	pt_ShowErrorStatus
	BRA.W	pt_LoadNextChunk
pt_06F1:
	LEA	(dat_0704,PC),A0
	BRA.S	pt_06F4
pt_06F2:
	LEA	(dat_0705,PC),A0
	BRA.S	pt_06F4
pt_ShowErrorStatus:
	LEA	(dat_0707,PC),A0
pt_06F4:
	JSR	pt_ShowStatusMsg
	TST.L	dat_ActiveCopperPtr
	BNE.S	pt_06F5
	RTS
pt_06F5:
	BRA.W	pt_FileLoadComplete
dat_FileIOVar5:
	DS.L	1
dat_ClipboardBufPtr:
	DS.L	1
dat_FileIOVar4:
	DS.L	1
dat_FileIOVar3:
	DS.L	1
dat_FileIOVar1:
	DS.L	1
dat_FileIOVar2:
	DS.L	1
pt_BtnSetupSaveConfig:
	LEA	dat_12EF,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_06FD
	RTS
pt_06FD:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteDim
	BSR.W	pt_0703
	LEA	(dat_070C,PC),A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_072C
	MOVEA.L	dat_DosLibBase,A6
	LEA	dat_FilePathBuf2,A1
	MOVE.W	#$533a,(A1)+
	LEA	(dat_0708,PC),A0
	MOVEQ	#12,D0
pt_06FE:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_06FE
	JSR	pt_OpenConfigWrite
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.L	D0,D7
	BEQ.S	pt_06FF
	MOVE.L	D0,D1
	LEA	dat_FileIOBufAlt,A0
	MOVE.L	A0,D2
	MOVE.L	(4,A0),D3
	ADDQ.L	#8,D3
	JSR	(-48,A6)
	MOVE.L	D7,D1
	JSR	(-36,A6)
	JSR	pt_PrefsSave41
	BRA.W	pt_RestorePalette
pt_06FF:
	LEA	(dat_0706,PC),A0
	JSR	pt_ShowStatusMsg
	TST.L	dat_ActiveCopperPtr
	BNE.S	pt_0700
	RTS
pt_0700:
	MOVE.W	#$0032,dat_AnimPhaseCounter
	BRA.W	pt_RestorePaletteInit
pt_BtnSetupCfgSlot:
	MOVE.W	#$07db,dat_TextBytePos
	BSR.W	pt_ClearPatternKey
	MOVE.W	D0,dat_DiskOpVar1
pt_0702:
	MOVE.W	#$07db,dat_TextBytePos
	MOVE.W	(dat_DiskOpVar1,PC),dat_DisplayParam
	JMP	pt_DrawDecValue3
pt_0703:
	MOVE.W	(dat_DiskOpVar1,PC),D0
	LEA	(dat_0709,PC),A0
	JMP	pt_1095
dat_0704:
	DC.B	"CONFIG NOT FOUND!",0
dat_0705:
	DC.B	"NOT A CONFIG FILE",0
dat_0706:
	DC.B	"CAN'T CREATE FILE",0,0
dat_0707:
	DC.B	"ERROR WHILE READING CONFIG",0
dat_0708:
	DC.B	"PT.config-00"
dat_0709:
	DS.W	1
dat_DiskOpVar1:
	DS.W	1
dat_070B:
	DC.B	"LOADING CONFIG",0
dat_070C:
	DC.B	"SAVING CONFIG",0,0
	DC.B	"S:"
pt_070D:
	LEA	str_IFFFormID2,A0
	LEA	dat_FileIOBufAlt,A1
	MOVE.W	dat_142C,D0
	SUBQ.W	#1,D0
pt_070E:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_070E
	LEA	dat_153B,A0
	MOVE.L	(A0)+,D1
	BEQ.S	pt_ClipboardCalcOfs
	BTST	#0,D1
	BNE.S	pt_ClipboardCalcOfs
	LEA	(0,A0,D1.L),A1
	LEA	(4,A0),A0
pt_070F:
	MOVE.L	(A0),D1
	CMP.L	#$4d495343,D1
	BNE.S	pt_0710
	MOVE.L	A0,dat_FileIOVar5
pt_0710:
	CMP.L	#$5343524e,D1
	BNE.S	pt_0711
	MOVE.L	A0,dat_ClipboardBufPtr
pt_0711:
	CMP.L	#$45444954,D1
	BNE.S	pt_0712
	MOVE.L	A0,dat_FileIOVar4
pt_0712:
	CMP.L	#$4449534b,D1
	BNE.S	pt_0713
	MOVE.L	A0,dat_FileIOVar3
pt_0713:
	ADDQ.L	#4,A0
	MOVE.L	(A0)+,D1
	BLE.S	pt_ClipboardCalcOfs
	BTST	#0,D1
	BNE.S	pt_ClipboardCalcOfs
	ADDA.L	D1,A0
	CMPA.L	A1,A0
	BLE.S	pt_070F
pt_ClipboardCalcOfs:
	MOVEA.L	(dat_ClipboardBufPtr,PC),A0
	SUBA.L	#dat_FileIOBufAlt,A0
	ADDA.L	#str_VersionTag2,A0
	MOVE.L	A0,dat_FileIOVar1
	LEA	(16,A0),A0
	MOVE.L	A0,dat_FileIOVar2
	BSR.S	pt_0719
	BSR.W	pt_CheckSongModified
	RTS
pt_BtnSetupResetAll:
	LEA	dat_12E8,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0716
	RTS
pt_0716:
	BSR.W	pt_070D
	JSR	pt_PrefsReset41
	MOVE.W	(206,A0),D0
	BTST	#2,D0
	BEQ.S	pt_0717
	BCLR	#0,dat_UICheckFlag
	BRA.S	pt_0718
pt_0717:
	BSET	#0,dat_UICheckFlag
pt_0718:
	BRA.W	pt_UIUpdatePaletteMode
pt_0719:
	BSR.S	pt_071A
	BSR.W	pt_ClipboardOpsEntry
	BSR.W	pt_0723
	BSR.W	pt_0727
	RTS
pt_071A:
	MOVE.L	(dat_FileIOVar5,PC),D0
	BEQ.W	pt_071C
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.L	(A0)+,dat_1507
	MOVE.W	(A0)+,dat_DisplayLineCount
	MOVE.W	(A0)+,dat_PalEdEntryIdx
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,dat_SavedTempo
	MOVE.W	dat_SavedTempo,dat_CurrentTempo
	MOVE.W	(A0)+,dat_PaletteIdxCounter
	LEA	dat_NotifyHookVec,A1
	MOVEQ	#31,D0
pt_071B:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_071B
	MOVE.W	(A0)+,dat_OptPage
	MOVE.W	(A0)+,dat_PlaybackModeFlag
	MOVE.B	(A0)+,dat_TimerCountHi
	MOVE.B	(A0)+,dat_SampleNameBuf
	MOVE.B	(A0)+,dat_TempoCounter
	MOVE.B	(A0)+,dat_PatternBufIdx
	MOVE.W	(A0)+,dat_VBLCounterHi
	MOVE.B	(A0)+,dat_VBLCounterLo
	MOVE.B	(A0)+,dat_FontMode
	MOVE.B	(A0)+,dat_PatternBufFlag
	MOVE.B	(A0)+,dat_PatternBufSize
	MOVE.W	(A0)+,dat_1516
	MOVE.W	(A0)+,dat_1517
	MOVE.W	(A0)+,dat_PalEdScrollPos
	MOVE.W	(A0)+,dat_CurrentSpeed
	MOVE.W	(A0)+,dat_ScopeMode
	MOVE.W	(A0)+,dat_OscillatorIndex
	MOVE.B	(A0)+,dat_PlaybackRunning
	MOVE.B	(A0)+,dat_PlaybackState
	MOVE.B	(A0)+,dat_PatSyncStep
	MOVE.B	(A0)+,dat_RpMetroInterval
	MOVE.B	(A0)+,dat_RpMetroChannel
	MOVE.B	(A0)+,dat_InputSplitMode
	MOVE.B	(A0)+,dat_InputReadyFlag
	MOVE.B	(A0)+,dat_TimerCountLo
	MOVE.W	(A0)+,dat_RpDmaWaitCount
	MOVE.B	(A0)+,dat_SampleKeyState
	MOVE.B	(A0)+,dat_PalCyclePhase
	MOVE.B	(A0)+,dat_SampleEditFlag
	MOVE.B	(A0)+,mix_RateSel
	CMPI.B	#$64,dat_TempoCounter
	BLT.S	pt_071C
	MOVE.B	#$64,dat_TempoCounter
pt_071C:
	CMPI.B	#$03,dat_WaveformPhase
	BLT.S	pt_071D
	CLR.B	dat_WaveformPhase
pt_071D:
	CMPI.W	#$0006,dat_ScopeMode
	BHI.S	pt_071E
	CLR.W	dat_ScopeMode
pt_071E:
	RTS
pt_ClipboardOpsEntry:
	MOVE.L	(dat_ClipboardBufPtr,PC),D0
	BEQ.S	pt_0722
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.L	(A0)+,dat_1509
	MOVE.W	(A0)+,dat_MouseX
	MOVE.W	(A0)+,dat_MouseY
	LEA	dat_ScopeWorkBuf,A1
	MOVEQ	#7,D0
pt_0720:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_0720
	LEA	dat_PaletteEditBuf,A1
	MOVEQ	#47,D0
pt_0721:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_0721
	MOVE.B	(A0)+,dat_CursorPhase
pt_0722:
	RTS
pt_0723:
	MOVE.L	(dat_FileIOVar4,PC),D0
	BEQ.S	pt_0726
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.L	(A0)+,dat_150B
	MOVE.L	(A0)+,dat_DiskIOReady
	LEA	dat_AudioBufWork,A1
	MOVEQ	#15,D0
pt_0724:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0724
	LEA	dat_DisplayWorkBuf,A1
	MOVEQ	#9,D0
pt_0725:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_0725
pt_0726:
	RTS
pt_0727:
	MOVE.L	(dat_FileIOVar3,PC),D0
	BEQ.S	pt_072B
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.W	(A0)+,dat_150D
	MOVE.B	(A0)+,dat_UIBitFlags
	MOVE.B	(A0)+,dat_UIStateFlag
	MOVE.B	(A0)+,dat_CopperListFlag
	MOVE.B	(A0)+,dat_CursorAnimState
	LEA	dat_DisplayWorkBuf3,A1
	LEA	dat_PatternLineBuf2,A2
	MOVEQ	#5,D0
pt_0728:
	MOVEQ	#81,D1
pt_0729:
	MOVE.B	(A0),(A1)+
	MOVE.B	(A0)+,(A2)+
	DBF	D1,pt_0729
	LEA	(76,A0),A0
	DBF	D0,pt_0728
	LEA	dat_PatternDataBuf3,A1
	MOVE.W	#$00bf,D0
pt_072A:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_072A
pt_072B:
	RTS
pt_072C:
	BSR.S	pt_072D
	BSR.W	pt_0730
	BSR.W	pt_0734
	BSR.W	pt_0738
	RTS
pt_072D:
	MOVE.L	(dat_FileIOVar5,PC),D0
	BEQ.W	pt_072F
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.L	dat_1507,(A0)+
	MOVE.W	dat_DisplayLineCount,(A0)+
	MOVE.W	dat_PalEdEntryIdx,(A0)+
	MOVE.W	#$001f,(A0)+
	MOVE.W	dat_SavedTempo,(A0)+
	MOVE.W	dat_PaletteIdxCounter,(A0)+
	LEA	dat_NotifyHookVec,A1
	MOVEQ	#31,D0
pt_072E:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_072E
	MOVE.W	dat_OptPage,(A0)+
	MOVE.W	dat_PlaybackModeFlag,(A0)+
	MOVE.B	dat_TimerCountHi,(A0)+
	MOVE.B	dat_SampleNameBuf,(A0)+
	MOVE.B	(dat_TempoCounter,PC),(A0)+
	MOVE.B	dat_PatternBufIdx,(A0)+
	MOVE.W	dat_VBLCounterHi,(A0)+
	MOVE.B	dat_VBLCounterLo,(A0)+
	MOVE.B	dat_FontMode,(A0)+
	MOVE.B	dat_PatternBufFlag,(A0)+
	MOVE.B	dat_PatternBufSize,(A0)+
	MOVE.W	dat_1516,(A0)+
	MOVE.W	dat_1517,(A0)+
	MOVE.W	dat_PalEdScrollPos,(A0)+
	MOVE.W	dat_CurrentSpeed,(A0)+
	MOVE.W	(dat_ScopeMode,PC),(A0)+
	MOVE.W	dat_OscillatorIndex,(A0)+
	MOVE.B	dat_PlaybackRunning,(A0)+
	MOVE.B	dat_PlaybackState,(A0)+
	MOVE.B	dat_PatSyncStep,(A0)+
	MOVE.B	dat_RpMetroInterval,(A0)+
	MOVE.B	dat_RpMetroChannel,(A0)+
	MOVE.B	dat_InputSplitMode,(A0)+
	MOVE.B	dat_InputReadyFlag,(A0)+
	MOVE.B	dat_TimerCountLo,(A0)+
	MOVE.W	dat_RpDmaWaitCount,(A0)+
	MOVE.B	(dat_SampleKeyState,PC),(A0)+
	MOVE.B	dat_PalCyclePhase,(A0)+
	MOVE.B	dat_SampleEditFlag,(A0)+
	MOVE.B	mix_RateSel,(A0)+
pt_072F:
	RTS
pt_0730:
	MOVE.L	(dat_ClipboardBufPtr,PC),D0
	BEQ.S	pt_0733
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.L	dat_1509,(A0)+
	MOVE.W	dat_MouseX,(A0)+
	MOVE.W	dat_MouseY,(A0)+
	LEA	dat_ScopeWorkBuf,A1
	MOVEQ	#7,D0
pt_0731:
	MOVE.W	(A1)+,(A0)+
	DBF	D0,pt_0731
	LEA	dat_PaletteEditBuf,A1
	MOVEQ	#47,D0
pt_0732:
	MOVE.W	(A1)+,(A0)+
	DBF	D0,pt_0732
	MOVE.B	dat_CursorPhase,(A0)+
pt_0733:
	RTS
pt_0734:
	MOVE.L	(dat_FileIOVar4,PC),D0
	BEQ.S	pt_0737
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.L	dat_150B,(A0)+
	MOVE.L	dat_DiskIOReady,(A0)+
	LEA	dat_AudioBufWork,A1
	MOVEQ	#15,D0
pt_0735:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_0735
	LEA	dat_DisplayWorkBuf,A1
	MOVEQ	#9,D0
pt_0736:
	MOVE.W	(A1)+,(A0)+
	DBF	D0,pt_0736
pt_0737:
	RTS
pt_0738:
	MOVE.L	(dat_FileIOVar3,PC),D0
	BEQ.S	pt_073C
	ADDQ.L	#8,D0
	MOVEA.L	D0,A0
	MOVE.W	dat_150D,(A0)+
	MOVE.B	dat_UIBitFlags,(A0)+
	MOVE.B	dat_UIStateFlag,(A0)+
	MOVE.B	dat_CopperListFlag,(A0)+
	MOVE.B	dat_CursorAnimState,(A0)+
	LEA	dat_DisplayWorkBuf3,A1
	MOVEQ	#5,D0
pt_0739:
	MOVEQ	#81,D1
pt_073A:
	MOVE.B	(A1)+,(A0)+
	DBF	D1,pt_073A
	LEA	(76,A0),A0
	DBF	D0,pt_0739
	LEA	dat_PatternDataBuf3,A1
	MOVE.W	#$00bf,D0
pt_073B:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_073B
pt_073C:
	RTS
pt_ReadFileHeader:
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileIOBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#12,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-42,A6)
	CMP.L	#$0000000c,D3
	BNE.S	pt_ReadHeaderFail
	LEA	dat_FileIOBuf,A0
	MOVE.L	(4,A0),D0
	SUBQ.L	#4,D0
	MOVE.L	D0,dat_FileRemaining
	RTS
pt_ReadHeaderFail:
	MOVEQ	#0,D0
	RTS
pt_ReadFileChunk:
	TST.L	dat_FileRemaining
	BEQ.S	pt_ReadChunkNoFile
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileIOBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#8,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-42,A6)
	CMP.L	#$00000008,D0
	BNE.S	pt_ReadChunkError
	SUB.L	D0,dat_FileRemaining
	BMI.S	pt_ReadChunkError
	LEA	dat_FileIOBuf,A0
	MOVE.L	(4,A0),D0
	RTS
pt_ReadChunkNoFile:
	MOVEQ	#0,D0
	RTS
pt_ReadChunkError:
	MOVEQ	#-1,D0
	RTS
pt_SeekInFile:
	SUB.L	D0,dat_FileRemaining
	BMI.S	pt_SeekFileFail
	MOVE.L	dat_FileHandle,D1
	MOVE.L	D0,D2
	MOVEQ	#0,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-66,A6)
	MOVEQ	#0,D0
	RTS
pt_SeekFileFail:
	MOVEQ	#-1,D0
	RTS
pt_ReadFileData:
	MOVE.L	dat_FileHandle,D1
	MOVE.L	A0,D2
	MOVE.L	D0,D3
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	D3,-(A7)
	JSR	(-42,A6)
	MOVE.L	(A7)+,D3
	CMP.L	D0,D3
	BNE.S	pt_ReadDataFail
	SUB.L	D0,dat_FileRemaining
	BMI.S	pt_ReadDataFail
	MOVE.L	(dat_FileRemaining,PC),D0
	RTS
pt_ReadDataFail:
	MOVEQ	#-1,D0
	RTS
pt_ReadAtPosition:
	MOVE.L	(4,A0),D1
	MOVE.L	D0,D2
	SUB.L	D1,D2
	BPL.S	pt_ReadAtPosCalc
	MOVEQ	#0,D2
	EXG	D0,D1
pt_ReadAtPosCalc:
	MOVE.L	D1,D0
	LEA	(8,A0),A0
	MOVE.L	D2,D7
	BSR.S	pt_ReadFileData
	BMI.S	pt_ReadAtPosError
	BEQ.S	pt_ReadAtPosEOF
	MOVE.L	D7,D0
	BEQ.S	pt_ReadAtPosOK
	BSR.S	pt_SeekInFile
	BNE.S	pt_ReadAtPosError
pt_ReadAtPosOK:
	MOVEQ	#1,D0
	RTS
pt_ReadAtPosEOF:
	MOVEQ	#0,D0
	RTS
pt_ReadAtPosError:
	MOVEQ	#-1,D0
	RTS
dat_FileRemaining:
	DS.L	1
pt_BtnSetupPalSlider1:
	BSR.S	pt_GetCursorDigit
	AND.W	#$0f00,D2
	LSR.W	#8,D2
	CMP.B	D2,D0
	BEQ.S	pt_EditEffectHiLoop
	AND.W	#$00ff,D1
	LSL.W	#8,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_UpdatePaletteCopper
pt_EditEffectHiLoop:
	LMB
	BEQ.S	pt_BtnSetupPalSlider1
	RTS
pt_BtnSetupPalSlider2:
	BSR.S	pt_GetCursorDigit
	AND.W	#$00f0,D2
	LSR.W	#4,D2
	CMP.B	D2,D0
	BEQ.S	pt_EditEffectMidLoop
	AND.W	#$0f0f,D1
	LSL.W	#4,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_UpdatePaletteCopper
pt_EditEffectMidLoop:
	LMB
	BEQ.S	pt_BtnSetupPalSlider2
	RTS
pt_BtnSetupPalSlider3:
	BSR.S	pt_GetCursorDigit
	AND.W	#$000f,D2
	CMP.B	D2,D0
	BEQ.S	pt_EditEffectLoLoop
	AND.W	#$0ff0,D1
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.S	pt_DrawEffectDigits
	BSR.W	pt_UpdatePaletteCopper
pt_EditEffectLoLoop:
	LMB
	BEQ.S	pt_BtnSetupPalSlider3
	RTS
pt_GetCursorDigit:
	MOVEQ	#0,D0
	MOVE.W	dat_EditDigitValue,D0
	CMP.W	#$001a,D0
	BCC.S	pt_CalcCursorDigit
	MOVEQ	#0,D0
	BRA.S	pt_ReadPatternCursor
pt_CalcCursorDigit:
	SUB.W	#$001a,D0
	DIVU	#$0003,D0
	AND.L	#$000000ff,D0
	CMP.W	#$000f,D0
	BLS.S	pt_ReadPatternCursor
	MOVEQ	#15,D0
pt_ReadPatternCursor:
	TST.W	dat_PalEdActive
	BNE.W	pt_PalEdGetColor
	LEA	dat_ScopeWorkBuf,A0
	MOVE.W	dat_PatCursorIndex,D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	RTS
