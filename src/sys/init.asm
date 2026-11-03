	SECTION S_0,CODE
pt_Hunk0Start:

SECSTRT_0:
	MOVEM.L	D0/A0,-(A7)
	CLR.L	str_VersionTag
	SUBA.L	A1,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-294,A6)
	MOVEA.L	D0,A4
	TST.L	(172,A4)
	BEQ.S	pt_0000
	MOVEM.L	(A7)+,D0/A0
	BRA.S	pt_0001
pt_0000:
	LEA	(92,A4),A0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-384,A6)
	LEA	(92,A4),A0
	JSR	(-372,A6)
	MOVE.L	D0,str_VersionTag
	NOP
	MOVEM.L	(A7)+,D0/A0
pt_0001:
	IFD	DEBUGTRAP
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	(276,A6),A0
	MOVE.L	#dbg_TrapHandler,(50,A0)
	JSR	dbg_TrapVectors
	ENDC
	BSR.S	pt_Init
	MOVE.L	D0,-(A7)
	TST.L	str_VersionTag
	BEQ.S	pt_0002
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-132,A6)
	MOVEA.L	(str_VersionTag,PC),A1
	JSR	(-378,A6)
pt_0002:
	MOVE.L	(A7)+,D0
	RTS
pt_Init:
	MOVE.L	A7,dat_StackPointer
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	(str_PTProcessName,PC),A1
	JSR	(-294,A6)
	MOVE.L	D0,dat_DosBase
	SUBA.L	A1,A1
	JSR	(-294,A6)
	MOVE.L	D0,dat_ThisTask
	MOVEA.L	D0,A0
	LEA	(dat_WBStartupMsg,PC),A1
	MOVE.L	(10,A0),(A1)
	LEA	(str_PTProcessName,PC),A1
	MOVE.L	A1,(10,A0)
	BSR.W	pt_InitScreenData
	BSR.W	pt_OpenLibraries
	BSR.W	pt_CheckCLI
	BNE.W	pt_Cleanup
	BSR.W	pt_OpenAudioDev
	BNE.W	pt_Cleanup
	BSR.W	pt_InitHardware
	BSR.W	pt_SetupVBlank
	BNE.W	pt_CleanupAll
	BSR.W	pt_AddAudioInts
	JSR	pt_MixInitTask
	BSR.W	pt_DetectChipset
	BSR.W	pt_CreateMsgPort
	BSR.W	pt_SetVectorAud0
	BSR.W	pt_OpenScreen
	BSR.W	pt_AddPorts
	JSR	pt_PatViewSetRowReplayer
	BSR.W	pt_SetPaletteBright
	BSR.W	pt_SavePaletteState
	JSR	pt_DrawStatusBar
	BSR.W	pt_LoadKeymap
	BSR.W	pt_InitPalettes
	BSR.W	pt_UpdateScopeDisplay
	BSR.W	pt_InitTimeDisplay
	JSR	pt_UpdateChannelState
	BSR.W	pt_SetTempo
	BSR.W	pt_SetupCopper
	MOVE.W	#$0001,dat_InitFlag
	BSR.W	pt_InitEditState
	LEA	(str_PTVersion,PC),A0
	JSR	pt_ShowStatusMsg
	JSR	pt_0652
	MOVE.W	#$0001,dat_DiskOpState
	JSR	pt_ChanDefault41
	JSR	pt_0378
pt_MainLoop:
	IFD	DEBUGAUTO
	MOVE.L	A7,dbg_AutoMainSP
	ENDC
	IFD	DEBUGFX
	JSR	dbg_FxFlush
	ENDC
	BSR.W	pt_GetKeypress
	BSR.W	pt_HandleSampleKeys
	BSR.W	pt_MainKeyDispatch
	BSR.W	pt_HandleNoteEntry
	JSR	pt_HandleCursorEdit
	BSR.W	pt_HandlePlayKeys
	BSR.W	pt_HandleEditFKeys
	BSR.W	pt_HandleF6Key
	BSR.W	pt_HandleJoystick
	BSR.W	pt_HandleHelpKey
	JSR	pt_MainYield41
	JSR	pt_HandleCursorKeys
	BSR.W	pt_DrawVolumeInd
	BSR.W	pt_HandlePlayTimer
	BSR.W	pt_UpdateTimeDisplay
	BSR.W	pt_CheckPatPosChange
	JSR	pt_SampleLenChanged
	BSR.W	pt_CheckTempoUpdate
	RMB
	BNE.S	pt_CheckLMB
	JSR	pt_HandleMouseClick
pt_CheckLMB:
	LMB
	BNE.S	pt_MainLoop
	TST.W	dat_UIMode
	BNE.S	pt_InitDone
	MOVE.W	#$0001,dat_InitFlag
	BSR.W	pt_InitEditState
	JSR	pt_ClearStatusMsg
	BSR.W	pt_WaitMouseRelease
pt_InitDone:
	JSR	pt_PlaybackKeyHandler
	JMP	pt_ExitProgram
dat_InitFlag:
	DS.W	1
dat_ThisTask:
	DS.L	1
dat_WBStartupMsg:
	DS.L	1
str_PTProcessName:
	DC.B	"ORS_PTProcess",0
str_PTVersion:
	DC.B	"Protracker V4.1.1",0,0,0,0,0,0,0
str_VersionTag:
	DS.L	1
	DC.B	"$VER: Protracker V4.1.1 (03.11.26)",0,0,0,0,0,0
	DS.L	1
pt_CheckTempoUpdate:
	TST.B	dat_TempoChanged
	BEQ.S	pt_CheckPatternMode
	CLR.B	dat_TempoChanged
	BSR.W	pt_SetTempo
pt_CheckPatternMode:
	CMPI.L	#$70617470,dat_RpPlayMode
	BEQ.S	pt_HandlePatternMode
	RTS
pt_HandlePatternMode:
	JSR	pt_DrawPosPatNumbers
	MOVE.W	dat_LastSampleNum,D0
	CMP.W	dat_CurrentPattern,D0
	BEQ.S	pt_CheckPatActive
	JSR	pt_DrawSampleInfo
	JSR	pt_RefreshSampleInfo
	MOVE.W	dat_CurrentPattern,dat_LastSampleNum
	MOVE.L	dat_PatRestartPos,dat_PatTableIdx
	JMP	pt_PatViewDrawAll
pt_CheckPatActive:
	TST.B	dat_PatJumpFlag
	BNE.S	pt_PatternRestart
	RTS
pt_PatternRestart:
	MOVE.L	dat_PatRestartPos,dat_PatTableIdx
	JMP	pt_PatViewDrawAll
pt_LoadKeymap:
	MOVE.L	#$00000080,D0
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	BEQ.S	pt_KeymapCleanup
	MOVE.L	D0,dat_KeymapBufPtr
	LEA	dat_DrivePrefix,A0
	JSR	pt_CopyFilename
	LEA	(str_KeymapFile,PC),A0
	MOVEQ	#9,D0
pt_CopyKeymapName:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_CopyKeymapName
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,D7
	BEQ.S	pt_KeymapLoadFail
	MOVE.L	(dat_KeymapBufPtr,PC),D2
	BEQ.S	pt_KeymapLoadFail
	MOVE.L	D7,D1
	MOVE.L	#$00000080,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-42,A6)
	MOVE.L	D7,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	RTS
pt_KeymapLoadFail:
	TST.L	dat_KeymapBufPtr
	BEQ.S	pt_KeymapCleanup
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	dat_KeymapBufPtr,A1
	MOVE.L	#$00000080,D0
	JSR	(-210,A6)
pt_KeymapCleanup:
	CLR.L	dat_KeymapBufPtr
	RTS
dat_KeymapBufPtr:
	DS.L	1
str_KeymapFile:
	DC.B	"pt.keymap",0
pt_DrawVolumeInd:
	MOVE.L	dat_SampleEditState,D0
	CMP.L	#$0000003f,D0
	BHI.S	pt_DrawVolLow
	MOVE.B	#$60,D0
	BRA.S	pt_DrawVolStore
pt_DrawVolLow:
	MOVE.B	#$21,D0
pt_DrawVolStore:
	MOVE.B	D0,dat_0694
	LEA	dat_0694,A0
	MOVEQ	#1,D0
	MOVE.W	#$2804,D1
	JMP	pt_DrawTextAt
pt_SaveConfirmDialog:
	LEA	dat_12DF,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_001C
	MOVEQ	#1,D0
	RTS
pt_001C:
	MOVEQ	#2,D0
	RTS
pt_CheckSongChanged:
	CMPI.L	#$43484721,dat_SongChangedMagic
	BNE.S	pt_001E
	BSR.S	pt_SaveConfirmDialog
	CMP.W	#$0002,D0
	BEQ.S	pt_SyncAndStop
	RTS
pt_001E:
	LEA	dat_12DE,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_SyncAndStop
	RTS
pt_SyncAndStop:
	JSR	pt_BtnMainStop
	JSR	pt_StopAllAudio
	BCLR	#1,CIAA_PRA
	BSET	#1,dat_ModeFlags
	MOVE.B	dat_SavedCIAPRA,D0
	AND.B	#$02,D0
	OR.B	D0,CIAA_PRA
	BSR.W	pt_ClearInputState
	BSR.W	pt_ClearInputState
	BSR.W	pt_KeymapLoadFail
	JSR	pt_ClearSpeedState
	BSR.W	pt_RemovePorts
	BSR.W	pt_FreeCIAResource
	BSR.W	pt_RemoveAudioInts
	BSR.W	pt_DeleteMsgPort
	BSR.W	pt_RestoreCopper
	BSR.W	pt_RestoreIntVecs
	MOVEA.L	EXT_0000.W,A0
	BSR.W	pt_CloseScreen
pt_CleanupAll:
	BSR.W	pt_CloseAudioDev
	JSR	pt_MixExitHook
	BSR.W	pt_01FC
	BSR.W	pt_02B7
	JSR	pt_061A
pt_Cleanup:
	MOVEA.L	(dat_ThisTask,PC),A0
	CMPA.L	#$00000000,A0
	BEQ.S	pt_CloseLibraries
	MOVE.L	(dat_WBStartupMsg,PC),(10,A0)
pt_CloseLibraries:
	JSR	pt_ClosePPLib
	JSR	pt_CloseXpkLib
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	dat_GfxLibBase,A1
	JSR	(-414,A6)
	MOVEA.L	dat_IntuiLibBase,A1
	JSR	(-414,A6)
	MOVEA.L	dat_DosLibBase,A1
	JSR	(-414,A6)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_CleanupMemDone
	MOVEA.L	D1,A1
	MOVE.L	dat_SampleEditCfg,D0
	JSR	(-210,A6)
pt_CleanupMemDone:
	MOVEA.L	dat_StackPointer,A7
	MOVEQ	#0,D0
	RTS
pt_OpenLibraries:
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	(str_DosLib,PC),A1
	MOVEQ	#0,D0
	JSR	(-552,A6)
	MOVE.L	D0,dat_DosLibBase
	BEQ.S	pt_OpenLibsFailed
	LEA	(str_GfxLib,PC),A1
	MOVEQ	#0,D0
	JSR	(-552,A6)
	MOVE.L	D0,dat_GfxLibBase
	BEQ.S	pt_OpenLibsFailed
	LEA	(str_IntuiLib,PC),A1
	MOVEQ	#0,D0
	JSR	(-552,A6)
	MOVE.L	D0,dat_IntuiLibBase
	BEQ.S	pt_OpenLibsFailed
	MOVEQ	#0,D0
	RTS
pt_OpenLibsFailed:
	MOVEQ	#-1,D0
	RTS
pt_OpenXpkLib:
	TST.L	dat_XpkLibBase
	BNE.S	pt_XpkAlreadyOpen
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	str_XpkLib,A1
	MOVEQ	#0,D0
	JSR	(-552,A6)
	MOVE.L	D0,dat_XpkLibBase
pt_XpkAlreadyOpen:
	MOVE.L	dat_XpkLibBase,D0
	BEQ.S	pt_XpkOpenFailed
	RTS
pt_XpkOpenFailed:
	MOVEQ	#-1,D0
	RTS
pt_CloseXpkLib:
	MOVE.L	dat_XpkLibBase,D0
	BEQ.S	pt_CloseXpkDone
	MOVEA.L	D0,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-414,A6)
	CLR.L	dat_XpkLibBase
pt_CloseXpkDone:
	RTS
pt_OpenPPLib:
	TST.L	dat_PPLibBase
	BNE.S	pt_PPAlreadyOpen
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	str_PPLib,A1
	MOVEQ	#35,D0
	JSR	(-552,A6)
	MOVE.L	D0,dat_PPLibBase
pt_PPAlreadyOpen:
	MOVE.L	dat_PPLibBase,D0
	RTS
pt_ClosePPLib:
	MOVE.L	dat_PPLibBase,D0
	BEQ.S	pt_ClosePPDone
	MOVEA.L	D0,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-414,A6)
	CLR.L	dat_PPLibBase
pt_ClosePPDone:
	RTS
pt_InitHardware:
	MOVE.B	CIAA_PRA,dat_SavedCIAPRA
	BSET	#1,CIAA_PRA
	BCLR	#1,dat_ModeFlags
	BCLR	#2,dat_ModeFlags
	BCLR	#4,dat_ModeFlags
	BCLR	#6,dat_ModeFlags
	BCLR	#7,dat_ModeFlags
	MOVE.W	#$0004,dat_RpNumChannels
	MOVE.W	#$0100,D0
	MULU	dat_RpNumChannels,D0
	MOVE.W	D0,dat_RowDataVar
	JSR	pt_StopAllAudio
	CLR.L	dat_ActiveCopperPtr
	MOVE.L	#chip_ScreenBitplanes2,D0
	MOVE.L	D0,dat_ScreenBuf2Ptr
	MOVE.L	dat_SampleEditCfg,D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BEQ.W	pt_CleanupAll
	MOVE.L	D0,dat_ModulePtr
	MOVEA.L	D0,A0
	LEA	(33,A0),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#30,D3
pt_0030:
	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BLE.S	pt_0031
	MOVE.L	D1,D2
pt_0031:
	DBF	D0,pt_0030
	ADDQ.W	#1,D2
	ASL.L	#8,D2
	ASL.L	#2,D2
	LEA	(4,A1,D2.L),A2
	LEA	dat_RpSampleStarts,A1
	ADDA.W	#$002a,A0
	MOVEQ	#30,D0
pt_0032:
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ASL.L	#1,D1
	ADDA.L	D1,A2
	DBF	D0,pt_0032
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	#$017f,(mod_songlen,A0)
	TST.B	dat_SampleNameBuf
	BNE.S	pt_0033
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
pt_0033:
	MOVEQ	#6,D0
	MOVE.L	D0,dat_RpSpeed
	MOVE.W	#$0001,dat_EditBufY
	MOVE.L	#dat_DisplayWorkBuf3,dat_SampleEditorPtr
	MOVE.L	#chip_CopperlistMain,dat_ActiveCopperPtr
	MOVE.L	#chip_CopperBplPtrs,dat_005C
	MOVE.L	#chip_Palette1,dat_PalettePtr
	MOVE.L	#dat_14A6,dat_CopPatBplPtr
	MOVE.L	#dat_PlayPatAddr,dat_PlayModePtr
	MOVE.L	#pt_PatternRenderEntry,dat_NoteNamesPtr
	MOVE.L	#dat_PaletteEditBuf,dat_PalEdDataPtr
	JSR	pt_PatViewSetRow
	BSR.W	pt_SetupBorderDisplay
	MOVE.W	#$ffe0,D0
	MOVE.W	#$0019,D1
	MOVE.W	#$0053,D2
	JSR	pt_PalColorShadeTab
	JSR	pt_0716
	JSR	pt_06E1
	JSR	pt_10C8
	JSR	pt_0803
	JSR	pt_DrawStatusArea
	JSR	pt_PatViewDrawAll
	JSR	pt_DrawPosPatNumbers
	JSR	pt_DrawPanelByMode
	MOVE.W	#$0001,dat_CurrentSample
	MOVE.W	#$0001,dat_UIMode
	JSR	pt_DrawSampleHex
	BSR.W	pt_DetectCPU
pt_CheckDiskOpBusy:
	TST.W	dat_SamplerActive
	BEQ.S	pt_CheckDiskOpCont
	RTS
pt_CheckDiskOpCont:
	LEA	dat_14AB,A0
	MOVE.W	#$00c3,D5
	ADD.W	dat_MouseY,D5
	SUB.W	dat_ScrollOffset,D5
	LSL.W	#8,D5
	OR.B	#$07,D5
	LEA	dat_PaletteEditBuf,A5
	MOVEQ	#47,D7
pt_0036:
	MOVE.W	D5,(A0)+
	MOVE.W	#$fffe,(A0)+
	LEA	(dat_0059,PC),A1
	MOVEQ	#1,D6
pt_0037:
	MOVE.W	(A5),D4
	MOVE.W	(A1)+,(A0)+
	MOVE.W	#$0003,dat_PalBrightAdj
	MOVE.W	D4,D0
	JSR	pt_AdjustColorBright
	MOVE.W	D0,(A0)+
	MOVE.W	(A1)+,(A0)+
	MOVE.W	D4,(A0)+
	MOVE.W	(A1)+,(A0)+
	MOVE.W	#$fffd,dat_PalBrightAdj
	MOVE.W	D4,D0
	JSR	pt_AdjustColorBright
	MOVE.W	D0,(A0)+
	DBF	D6,pt_0037
	ADDQ.W	#2,A5
	ADD.W	#$0100,D5
	DBF	D7,pt_0036
	JSR	pt_Vu8CopHook41
	RTS
pt_CheckCLI:
	TST.L	dat_DosBase
	BNE.S	pt_0039
	MOVEQ	#0,D0
	RTS
pt_0039:
	LEA	(dat_ReqTaskIntErr,PC),A1
	BSR.W	pt_ShowErrorReq
	MOVEQ	#-1,D0
	RTS
pt_OpenAudioDev:
	JSR	pt_AhiAudioDevOpen
	MOVE.L	(dat_ThisTask,PC),D0
	MOVE.L	D0,(16,A1)
	LEA	dat_AudioMsgPort,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-354,A6)
	LEA	dat_AudioIOReq,A1
	MOVE.B	#$7f,(9,A1)
	MOVE.L	#dat_AudioMsgPort,(14,A1)
	MOVE.L	#dat_PaletteEntry,(34,A1)
	MOVE.L	#$00000001,(38,A1)
	MOVE.L	#dat_0057,(24,A1)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	LEA	(str_AudioDev,PC),A0
	JSR	(-444,A6)
	TST.L	D0
	BNE.S	pt_AudioDevError
	LEA	dat_AudioIOReq,A1
	MOVE.B	(31,A1),D0
	BNE.S	pt_AudioDevError
	MOVE.L	(20,A1),dat_TempWorkBuf
	TST.L	dat_TempWorkBuf
	BEQ.S	pt_AudioDevError
	MOVE.W	(32,A1),dat_PaletteWord1
	MOVEQ	#0,D0
	RTS
pt_CloseAudioDev:
	JSR	pt_AhiAudioDevClose
	MOVE.L	(dat_TempWorkBuf,PC),(20,A1)
	MOVE.L	#dat_PaletteEntry,(24,A1)
	MOVE.W	(dat_PaletteWord1,PC),(32,A1)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-450,A6)
	LEA	dat_AudioIOReq,A1
	MOVE.B	(31,A1),D0
	TST.B	D0
	BNE.S	pt_AudioDevError
pt_003C:
	LEA	dat_AudioMsgPort,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-360,A6)
	MOVEQ	#-1,D0
	RTS
pt_AudioDevError:
	CMP.L	#$fffffff5,D0
	BNE.S	pt_003E
	LEA	(dat_ReqAllocErr,PC),A1
	BRA.S	pt_003F
pt_003E:
	LEA	(dat_ReqAudioDevErr,PC),A1
pt_003F:
	BSR.S	pt_ShowErrorReq
	BRA.S	pt_003C
pt_ShowErrorReq:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEA.L	dat_IntuiLibBase,A6
	MOVEA.L	(52,A6),A0
	MOVEM.L	A0-A1,-(A7)
	MOVEA.L	(56,A6),A0
	MOVEQ	#0,D0
	MOVEA.L	(40,A0),A1
	MOVE.W	(4,A1),D0
	ADDQ.W	#1,D0
	ADD.B	(35,A0),D0
	MOVE.L	D0,dat_ReqAudioChErr
	MOVE.L	D0,dat_ReqRunningErr
	MOVE.L	D0,dat_ReqTerminate
	MOVEM.L	(A7)+,A0-A1
	SUBA.L	A2,A2
	LEA	(dat_ReqResume,PC),A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	JSR	(-348,A6)
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
dat_DosBase:
	DS.L	1
dat_ReqAllocErr:
	DS.L	3
	DC.L	str_ErrorAllocate
	DC.L	dat_ReqAllocBtn
dat_ReqAllocBtn:
	DS.L	1
dat_ReqAudioChErr:
	DS.L	2
	DC.L	str_ErrorAudioChannels
	DS.L	2
str_ErrorAllocate:
	DC.B	"Couldn't allocate",0
str_ErrorAudioChannels:
	DC.B	"the audiochannels!",0,0
dat_ReqAudioDevErr:
	DS.L	3
	DC.L	str_ErrorAudioDevice
	DS.L	2
str_ErrorAudioDevice:
	DC.B	"General audiodevice error!",0,0
dat_ReqResume:
	DS.L	3
	DC.L	str_ResumeBtn
	DS.L	1
str_ResumeBtn:
	DC.B	"Resume",0
	DC.B	"tProtracker request!",0
dat_ReqTaskIntErr:
	DS.L	3
	DC.L	str_ErrorTaskInterference
	DC.L	dat_ReqTaskIntBtn
dat_ReqTaskIntBtn:
	DS.L	1
dat_ReqRunningErr:
	DS.L	2
	DC.L	str_ErrorAlreadyRunning
	DS.L	2
str_ErrorTaskInterference:
	DC.B	"        TASK INTERFERANCE!",0
str_ErrorAlreadyRunning:
	DC.B	"ProTracker is already running. ",0,0
dat_ReqCIAErr:
	DS.L	3
	DC.L	str_ErrorCIATimer
	DC.L	dat_ReqCIABtn
dat_ReqCIABtn:
	DS.L	1
dat_ReqTerminate:
	DS.L	2
	DC.L	str_ErrorTerminateTasks
	DS.L	2
str_ErrorCIATimer:
	DC.B	"     Unable to get CIA timer",0
	DC.B	"m"
str_ErrorTerminateTasks:
	DC.B	"Terminate other tasks and try again.",0
	DC.B	"'"
dat_TempWorkBuf:
	DS.L	1
dat_PaletteWord1:
	DS.W	1
dat_0057:
	DS.L	1
dat_PaletteEntry:
	DC.W	$0fb4
dat_0059:
	DC.L	$01b201b4,$01b601ba,$01bc01be
dat_CopPatBplPtr:
	DS.L	1
dat_ActiveCopperPtr:
	DS.L	1
dat_005C:
	DS.L	1
dat_PalettePtr:
	DS.L	1
str_DosLib:
	DC.B	"dos.library",0
str_IntuiLib:
	DC.B	"intuition.library",0
str_GfxLib:
	DC.B	"graphics.library",0
str_XpkLib:
	DC.B	"xpkmaster.library",0
str_PPLib:
	DC.B	"powerpacker.library",0
str_AudioDev:
	DC.B	"audio.device",0,0,0
pt_0064:
	MOVE.L	#chip_BorderLeft,dat_BplPtr1
	MOVE.L	#chip_BorderCenter,dat_BplPtr2
	MOVE.L	#chip_BorderRight,dat_BplPtr3
	MOVE.L	#chip_IconData2,dat_BplPtr4
	BRA.S	pt_0066
pt_SetupBorderDisplay:
	MOVE.L	#chip_PanelBitplane1,dat_BplPtr1
	MOVE.L	#chip_PanelBitplane2,dat_BplPtr2
	MOVE.L	#chip_PanelBitplane3,dat_BplPtr3
	MOVE.L	#chip_PanelBitplane4,dat_BplPtr4
pt_0066:
	MOVE.L	#dat_SongModifiedFlag2,dat_135F
	MOVE.L	#chip_IconData,dat_SpriteDataPtr
	MOVE.L	#chip_SpritePlayCtr,dat_135D
	MOVE.L	#chip_SpriteStatusBar,dat_135E
	MOVE.L	dat_SpriteDataPtr,dat_135C
	LEA	dat_135C,A0
	LEA	chip_CopperlistMain,A1
	MOVEQ	#15,D2
pt_CopySpriteLoop:
	MOVE.W	(A0)+,(2,A1)
	ADDQ.L	#4,A1
	DBF	D2,pt_CopySpriteLoop
	RTS
dat_SpriteDataPtr:
	DS.L	1
pt_SetVectorAud0:
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-132,A6)
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	#dat_IntHandler0,D0
	MOVEA.L	#$fffffea4,A0
	JSR	(-420,A6)
	MOVE.L	D0,dat_OldIntVec0
	CMPI.W	#$0024,dat_KickstartVer
	BMI.S	pt_IntVecsSet
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	#dat_IntHandler1,D0
	MOVEA.L	#$fffffdb4,A0
	JSR	(-420,A6)
	MOVE.L	D0,dat_OldIntVec1
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	#dat_IntHandler3,D0
	MOVEA.L	#$fffffe8c,A0
	JSR	(-420,A6)
	MOVE.L	D0,dat_OldIntVec3
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	#dat_IntHandler2,D0
	MOVEA.L	#$fffffe98,A0
	JSR	(-420,A6)
	MOVE.L	D0,dat_OldIntVec2
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	#dat_IntHandler4,D0
	MOVEA.L	#$fffffe92,A0
	JSR	(-420,A6)
	MOVE.L	D0,dat_OldIntVec4
pt_IntVecsSet:
	JSR	(-138,A6)
	RTS
pt_RestoreIntVecs:
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-132,A6)
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	(dat_OldIntVec0,PC),D0
	MOVEA.L	#$fffffea4,A0
	JSR	(-420,A6)
	CMPI.W	#$0024,dat_KickstartVer
	BMI.S	pt_IntVecsCleared
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	(dat_OldIntVec1,PC),D0
	MOVEA.L	#$fffffdb4,A0
	JSR	(-420,A6)
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	(dat_OldIntVec3,PC),D0
	MOVEA.L	#$fffffe8c,A0
	JSR	(-420,A6)
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	(dat_OldIntVec2,PC),D0
	MOVEA.L	#$fffffe98,A0
	JSR	(-420,A6)
	MOVEA.L	dat_IntuiLibBase,A1
	MOVE.L	(dat_OldIntVec4,PC),D0
	MOVEA.L	#$fffffe92,A0
	JSR	(-420,A6)
pt_IntVecsCleared:
	JSR	(-138,A6)
	RTS
dat_IntHandler0:
	TST.W	dat_PlaybackActive
	BEQ.S	pt_r00cb0
	JMP	dat_ReturnZeroStub
pt_r00cb0:
	TST.B	dat_VBlankCounter
	BNE.S	pt_r00cd0
	ADDQ.B	#1,dat_VBlankCounter
	MOVE.L	A0,-(A7)
	BSR.W	pt_RestoreCopper
	MOVEA.L	(A7)+,A0
	PEA	(dat_IntHandler4+10,PC)
	MOVE.L	(dat_OldIntVec0,PC),-(A7)
	RTS
pt_r00cd0:
	ADDQ.B	#1,dat_VBlankCounter
	PEA	(dat_IntHandler4+10,PC)
	MOVE.L	(dat_OldIntVec0,PC),-(A7)
	RTS
dat_IntHandler1:
	TST.W	dat_PlaybackActive
	BEQ.S	pt_r00cee
	JMP	dat_ReturnZeroStub
pt_r00cee:
	TST.B	dat_VBlankCounter
	BNE.S	pt_r00d0e
	ADDQ.B	#1,dat_VBlankCounter
	MOVE.L	A0,-(A7)
	BSR.W	pt_RestoreCopper
	MOVEA.L	(A7)+,A0
	PEA	(dat_IntHandler4+10,PC)
	MOVE.L	(dat_OldIntVec1,PC),-(A7)
	RTS
pt_r00d0e:
	ADDQ.B	#1,dat_VBlankCounter
	PEA	(dat_IntHandler4+10,PC)
	MOVE.L	(dat_OldIntVec1,PC),-(A7)
	RTS
dat_IntHandler2:
	TST.W	dat_PlaybackActive
	BEQ.S	pt_r00d2c
	JMP	dat_ReturnZeroStub
pt_r00d2c:
	TST.B	dat_VBlankCounter
	BNE.S	pt_r00d48
	ADDQ.B	#1,dat_VBlankCounter
	MOVE.L	A0,-(A7)
	BSR.W	pt_RestoreCopper
	MOVEA.L	(A7)+,A0
	MOVE.L	(dat_OldIntVec2,PC),-(A7)
	RTS
pt_r00d48:
	ADDQ.B	#1,dat_VBlankCounter
	MOVE.L	(dat_OldIntVec2,PC),-(A7)
	RTS
dat_IntHandler3:
	PEA	(dat_IntHandler4+10,PC)
	MOVE.L	(dat_OldIntVec3,PC),-(A7)
	RTS
dat_IntHandler4:
	NOP
	NOP
	MOVE.L	(dat_OldIntVec4,PC),-(A7)
	RTS
	JMP	pt_ReqDec41
	NOP
	NOP
	NOP
	NOP
dat_OldIntVec0:
	DS.L	1
dat_OldIntVec1:
	DS.L	1
dat_OldIntVec2:
	DS.L	1
dat_OldIntVec3:
	DS.L	1
dat_OldIntVec4:
	DS.L	1
pt_DetectChipset:
	MOVE.W	#$0021,dat_KickstartVer
	MOVEQ	#34,D0
	BSR.S	pt_CheckKickVer
	BEQ.S	pt_ChipsetDetDone
	MOVE.W	#$0022,dat_KickstartVer
	MOVEQ	#36,D0
	BSR.S	pt_CheckKickVer
	BEQ.S	pt_ChipsetDetDone
	MOVE.W	#$0024,dat_KickstartVer
	MOVEQ	#39,D0
	BSR.S	pt_CheckKickVer
	BEQ.S	pt_ChipsetDetDone
	MOVE.W	#$0027,dat_KickstartVer
	MOVEQ	#40,D0
	BSR.S	pt_CheckKickVer
	BEQ.S	pt_ChipsetDetDone
	MOVE.W	#$0028,dat_KickstartVer
pt_ChipsetDetDone:
	RTS
dat_KickstartVer:
	DS.W	1
pt_CheckKickVer:
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	(str_IntuiLib,PC),A1
	JSR	(-552,A6)
	TST.L	D0
	BEQ.S	pt_KickVerFail
	MOVEA.L	D0,A1
	JSR	(-414,A6)
	MOVEQ	#-1,D0
	RTS
pt_KickVerFail:
	MOVEQ	#0,D0
	RTS
pt_DetectCPU:
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.W	(296,A6),D0
	BTST	#0,D0
	BEQ.S	pt_CPUCheck010
	MOVE.B	#$01,dat_CPUType
pt_CPUCheck010:
	BTST	#1,D0
	BEQ.S	pt_CPUCheck020
	MOVE.B	#$02,dat_CPUType
pt_CPUCheck020:
	BTST	#2,D0
	BEQ.S	pt_CPUCheck030
	MOVE.B	#$03,dat_CPUType
pt_CPUCheck030:
	BTST	#3,D0
	BEQ.S	pt_CPUCheck040
	MOVE.B	#$04,dat_CPUType
pt_CPUCheck040:
	BTST	#4,D0
	BEQ.S	pt_CheckDeniseID
	MOVE.B	#$05,dat_CPUType
pt_CheckDeniseID:
	MOVE.W	DENISEID,D0
	BEQ.S	pt_DeniseOCS
	CMP.W	#$00fc,D0
	BEQ.S	pt_DeniseECS
	CMP.W	#$00ec,D0
	BEQ.S	pt_DeniseECS
	CMP.W	#$00f8,D0
	BEQ.S	pt_DeniseAGA
	ST	D0
	RTS
pt_DeniseAGA:
	MOVEQ	#0,D0
	MOVE.B	#$03,dat_DeniseType
	RTS
pt_DeniseOCS:
	MOVEQ	#1,D0
	CLR.B	dat_DeniseType
	RTS
pt_DeniseECS:
	MOVEQ	#2,D0
	MOVE.B	#$01,dat_DeniseType
	RTS
	DC.L	$700313fc
	DC.W	$0002
	DC.L	dat_DeniseType
	DC.W	$4e75
dat_CPUType:
	DS.W	1
dat_DeniseType:
	DS.W	1
pt_InitScreenData:
	LEA	dat_MainScreen41,A0
	JSR	pt_LoadIFFGraphic
	BNE.S	pt_CopyDataReady
	RTS
pt_CopyDataReady:
	LEA	SECSTRT_2,A0
	MOVEQ	#0,D3
	MOVEQ	#1,D2
pt_CopyChipOuter:
	MOVE.L	#$00000ac7,D0
pt_CopyChipInner:
	MOVE.L	(A1)+,(A0)+
	DBF	D0,pt_CopyChipInner
	LEA	chip_ScreenBitplanes,A0
	DBF	D2,pt_CopyChipOuter
	MOVEQ	#0,D0
	JMP	pt_FreeUndoBuf
pt_OpenScreen:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_IntuiLibBase,A6
	LEA	(dat_NewScreenStruct,PC),A0
	JSR	(-198,A6)
	MOVE.L	D0,dat_ScreenPtr
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CloseScreen:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_IntuiLibBase,A6
	MOVEA.L	dat_ScreenPtr,A0
	CMPA.L	#$00000000,A0
	BEQ.S	pt_ScreenClosed
	JSR	(-66,A6)
pt_ScreenClosed:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_WaitScreenFree:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.L	dat_ScreenPtr
	BEQ.S	pt_ScreenFree
pt_WaitScreenLoop:
	JSR	pt_ScrBackPoll41
	MOVEQ	#10,D1
	JSR	(-198,A6)
	MOVEA.L	dat_IntuiLibBase,A6
	MOVE.L	(60,A6),D0
	CMP.L	(dat_ScreenPtr,PC),D0
	BNE.S	pt_WaitScreenLoop
pt_ScreenFree:
	MOVEQ	#1,D0
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_NewScreenStruct:
	DS.L	1
	DC.L	$0280000c,$00020001,$8000100f
	DS.L	1
	DC.L	str_ScreenTitle
	DS.L	2
	DC.L	dat_ScreenTags
dat_ScreenTags:
	DC.L	$80000032,$00029000
	DS.L	1
dat_ScreenPtr:
	DS.L	1
str_ScreenTitle:
	DC.B	"Protracker Screen",0
pt_SetupCopper:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_GfxLibBase,A6
	SUBA.L	A1,A1
	JSR	(-222,A6)
	JSR	(-270,A6)
	JSR	(-270,A6)
	JSR	pt_InitCopperColors
	MOVE.L	#chip_CopperlistMain,dat_ActiveCopperPtr
	MOVE.L	#chip_CopperlistMain,COP1LCH
	CLR.W	COPJMP1
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_RestoreCopper:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_GfxLibBase,A6
	MOVEA.L	dat_IntuiLibBase,A1
	LEA	(34,A1),A1
	JSR	(-222,A6)
	JSR	(-270,A6)
	JSR	(-270,A6)
	MOVEA.L	dat_GfxLibBase,A0
	MOVE.L	(38,A0),dat_ActiveCopperPtr
	MOVE.L	(38,A0),COP1LCH
	CLR.W	COPJMP1
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_AddPorts:
	MOVEQ	#5,D0
	LEA	dat_VBLIntExecStruct,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-168,A6)
	MOVEQ	#4,D0
	LEA	dat_VBLIntTable,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-168,A6)
	MOVE.W	#$ffff,dat_VBLTickTable
	RTS
pt_RemovePorts:
	TST.W	dat_VBLTickTable
	BNE.S	pt_0099
	RTS
pt_0099:
	CLR.W	dat_VBLTickTable
	MOVEQ	#5,D0
	LEA	dat_VBLIntExecStruct,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-174,A6)
	MOVEQ	#4,D0
	LEA	dat_VBLIntTable,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-174,A6)
	RTS
pt_r01054:
	MOVEM.L	D0-D3/A0,-(A7)
	TST.W	dat_DiskOpFlag
	BNE.S	pt_r010c8
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_142E,A0
	MOVE.B	#$ff,dat_RenderMode
	MOVE.B	#$ff,dat_XORPlotFlag
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_r02c0e
	CLR.W	dat_DiskOpFlag
	CLR.B	dat_RenderMode
	BSR.S	pt_r010d0
	CMP.W	#$0026,D2
	BNE.S	pt_r010c0
	SUBQ.W	#3,D1
	EXT.L	D1
	DIVU.W	#$0006,D1
	CMP.W	#$0013,D1
	BEQ.S	pt_r010c0
	MOVE.W	dat_VBLSyncWord,D2
	CMP.W	D1,D2
	BEQ.S	pt_r010c8
	MOVE.W	D1,dat_VBLSyncWord
	BSR.S	pt_CalcVBLTick
	BRA.S	pt_r010c8
pt_r010c0:
	MOVE.W	#$ffff,dat_VBLSyncWord
pt_r010c8:
	MOVEM.L	(A7)+,D0-D3/A0
	RTS
dat_DiskOpFlag:
	DC.W	$ffff
pt_r010d0:
	MOVEM.W	D0-D7,-(A7)
	CMPI.W	#$ffff,dat_VBLSyncWord
	BEQ.S	pt_r010f6
	CMP.W	#$0026,D2
	BNE.S	pt_r010f4
	SUBQ.W	#3,D1
	DIVU.W	#$0006,D1
	MOVE.W	dat_VBLSyncWord,D2
	CMP.W	D1,D2
	BEQ.S	pt_r010f6
pt_r010f4:
	BSR.S	pt_CalcVBLTick
pt_r010f6:
	MOVEM.W	(A7)+,D0-D7
	RTS
pt_CheckEditMode3:
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_009C
	RTS
pt_009C:
	CMPI.W	#$ffff,dat_VBLSyncWord
	BEQ.S	pt_009D
	MOVEM.W	D0-D7/A0,-(A7)
	BSR.S	pt_CalcVBLTick
	MOVEM.W	(A7)+,D0-D7/A0
pt_009D:
	RTS
pt_CalcVBLTick:
	MOVE.W	dat_VBLSyncWord,D1
	MULU	#$0006,D1
	ADDQ.W	#3,D1
	LEA	dat_1489,A0
	MULU	#$0050,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	#$0006,D2
pt_009F:
	MOVE.W	#$0024,D3
	MOVE.B	(A0),D0
	EORI.B	#$3f,D0
	MOVE.B	D0,(A0)+
pt_00A0:
	EORI.B	#$ff,(A0)+
	DBF	D3,pt_00A0
	LEA	(42,A0),A0
	DBF	D2,pt_009F
	RTS
dat_VBLSyncWord:
	DC.W	$ffff
dat_00A2:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_UpdateMousePos
	BSR.W	pt_r027fc
	TSTPC.L	dat_ActiveCopperPtr
	BEQ.S	pt_r01176
	MOVE.L	(dat_ActiveCopperPtr,PC),COP1LCH
pt_r01176:
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_r0118c
	CMPI.W	#$0006,dat_UIMode
	BEQ.S	pt_r0118c
	BRA.S	pt_r01190
pt_r0118c:
	BSR.W	pt_r01054
pt_r01190:
	JSR	pt_PlaybackKeyHandler
	BSR.W	pt_r01c76
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_00A3:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	pt_r011ac
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_r011ac:
	BTST	#3,dat_ModeFlags
	BEQ.W	pt_ScopeTrackPos
	LEA	dat_00AE,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-180,A6)
	RTS
dat_00A4:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_ScopeTrackPos
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_VBLIntExecStruct:
	DS.L	2
	DC.W	$0200
	DC.L	dat_00A6
	DS.L	1
	DC.L	dat_00A2
dat_00A6:
	DC.B	"PT4.1 VBInt",0,0,0
dat_VBLTickTable:
	DS.W	1
dat_VBLIntTable:
	DS.L	2
	DC.W	$0200
	DC.L	str_VBLIntName
	DS.L	1
	DC.L	dat_00A3
str_VBLIntName:
	DC.L	$5054342e,$3120436f,$70496e74,$00000000
	DS.L	1
	DC.L	$000002e0
	DC.L	dat_00AA
	DS.L	1
	DC.L	dat_00AB
dat_00AA:
	DC.B	"PT4.1 Pattern SoftInt",0,0,0,0,0
dat_00AB:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	CMPI.L	#$70617470,dat_RpPlayMode
	BNE.S	pt_r01290
	TST.W	dat_SamplerActive
	BNE.S	pt_r01290
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	ADDA.L	dat_BplUpdateReq,A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	CMP.L	dat_PatTableIdx,D0
	BEQ.S	pt_r01290
	MOVE.L	D0,dat_PatTableIdx
	JSR	pt_PatViewDrawAll2
pt_r01290:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_RpSoftInt:
	DS.L	2
	DC.W	$0220
	DC.L	dat_00AD
	DS.L	1
	DC.L	pt_RpMusic
dat_00AD:
	DC.B	"PT4.1 Music SoftInt",0,0,0
dat_00AE:
	DS.L	2
	DC.W	$02e0
	DC.L	dat_00AF
	DS.L	1
	DC.L	dat_00A4
dat_00AF:
	DC.B	"PT4.1 Scope SoftInt",0,0,0
dat_00B0:
	DS.L	2
	DC.W	$0200
	DC.L	dat_00B1
	DC.L	dat_Channel1
	DC.L	pt_RpAudInt0
dat_00B1:
	DC.B	"PT4.1 Aud0Int",0,0,0
dat_00B2:
	DS.L	2
	DC.W	$0200
	DC.L	dat_00B3
	DC.L	dat_Channel2
	DC.L	pt_RpAudInt1
dat_00B3:
	DC.B	"PT4.1 Aud1Int",0,0,0
dat_00B4:
	DS.L	2
	DC.W	$0200
	DC.L	dat_00B5
	DC.L	dat_Channel3
	DC.L	pt_RpAudInt2
dat_00B5:
	DC.B	"PT4.1 Aud2Int",0,0,0
dat_00B6:
	DS.L	2
	DC.W	$0200
	DC.L	dat_00B7
	DC.L	dat_Channel4
	DC.L	pt_RpAudInt3
dat_00B7:
	DC.B	"PT4.1 Aud3Int",0,0,0,0,0
pt_AddAudioInts:
	JSR	pt_AhiAudIntsAdd
	NOP
	MOVEQ	#7,D0
	MOVEA.L	#dat_00B0,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVE.L	D0,dat_RpOldAudInt0
	MOVEQ	#8,D0
	MOVEA.L	#dat_00B2,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVE.L	D0,dat_RpOldAudInt1
	MOVEQ	#9,D0
	MOVEA.L	#dat_00B4,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVE.L	D0,dat_RpOldAudInt2
	MOVEQ	#10,D0
	MOVEA.L	#dat_00B6,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVE.L	D0,dat_RpOldAudInt3
	RTS
pt_RemoveAudioInts:
	JSR	pt_AhiAudIntsRemove
	NOP
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVEQ	#8,D0
	MOVEA.L	dat_RpOldAudInt1,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVEQ	#9,D0
	MOVEA.L	dat_RpOldAudInt2,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	MOVEQ	#10,D0
	MOVEA.L	dat_RpOldAudInt3,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-162,A6)
	RTS
pt_RpAudInt0:
	LEA	(160,A0),A6
	BRA.S	pt_RpAudInt
pt_RpAudInt1:
	LEA	(176,A0),A6
	BRA.S	pt_RpAudInt
pt_RpAudInt2:
	LEA	(192,A0),A6
	BRA.S	pt_RpAudInt
pt_RpAudInt3:
	LEA	(208,A0),A6
pt_RpAudInt:
	MOVEA.L	A0,A5
	MOVE.W	#$4000,(154,A5)
	TST.B	(n_pt4_dmawait,A1)
	BNE.W	pt_RpAudIntStart
	TST.B	(n_pt4_chunked,A1)
	BEQ.W	pt_RpAudIntStop
	MOVE.W	(n_pt4_dmacount,A1),D0
	BNE.S	pt_RpAudIntChunkNext
	BTST	#3,dat_UIBitFlags
	BEQ.S	pt_RpAudIntChunkFirst
	MOVEQ	#80,D1
	JSR	pt_WaitDMASync
pt_RpAudIntChunkFirst:
	MOVE.L	(n_pt4_chunkptr,A1),D1
	BEQ.W	pt_RpAudIntStop
	MOVEA.L	D1,A0
	TST.L	(A0)
	BLE.W	pt_RpAudIntStop
	MOVE.W	(6,A0),D1
	ADDQ.L	#8,(n_pt4_chunkptr,A1)
	MOVE.W	D1,(n_pt4_chunkvol,A1)
	MOVE.W	D1,(n_pt4_volmul,A1)
	BSR.S	pt_RpAudIntScaleVol
	MOVE.W	D1,(aud_VOL,A6)
	MOVE.W	(n_period,A1),(aud_PER,A6)
	MOVE.W	(n_pt4_dmaset,A1),(150,A5)
	MOVE.W	(n_pt4_intmask,A1),(156,A5)
	BRA.W	pt_RpAudIntExit
pt_RpAudIntScaleVol:
	MOVE.W	(n_pt4_irqvol,A1),D0
	BNE.S	pt_RpAudIntScaleVol2
	MOVEQ	#0,D1
	BRA.S	pt_RpAudIntScaleVolDone
pt_RpAudIntScaleVol2:
	TST.W	D1
	BEQ.S	pt_RpAudIntScaleVolDone
	MULU.W	D0,D1
	ADD.W	#$0020,D1
	LSR.W	#6,D1
	BNE.S	pt_RpAudIntScaleVolDone
	MOVEQ	#1,D1
pt_RpAudIntScaleVolDone:
	RTS
pt_RpAudIntChunkNext:
	MOVE.W	(n_pt4_intmask,A1),(156,A5)
	MOVE.W	(n_pt4_chunkvol,A1),D1
	MOVE.W	D1,(n_pt4_volmul,A1)
	BSR.S	pt_RpAudIntScaleVol
	MOVE.W	D1,(aud_VOL,A6)
	MOVE.L	(n_pt4_chunkptr,A1),D1
	BEQ.S	pt_RpAudIntChunkDone
	MOVEA.L	D1,A0
pt_RpAudIntChunkLoop:
	MOVE.L	(A0)+,D1
	BGT.S	pt_RpAudIntChunkSet
	BEQ.S	pt_RpAudIntChunkEnd
	ADDA.L	D1,A0
	BRA.S	pt_RpAudIntChunkLoop
pt_RpAudIntChunkSet:
	MOVE.L	D1,(A6)
	MOVE.W	(A0)+,(aud_LEN,A6)
	MOVE.W	(A0)+,(n_pt4_chunkvol,A1)
	MOVE.L	A0,(n_pt4_chunkptr,A1)
	BRA.W	pt_RpAudIntExit
pt_RpAudIntChunkEnd:
	MOVE.L	#chip_ScratchBuffer,(A6)
	MOVE.W	#$0010,(aud_LEN,A6)
	MOVE.W	D1,(n_pt4_chunkvol,A1)
	MOVE.L	D1,(n_pt4_chunkptr,A1)
	BRA.W	pt_RpAudIntExit
pt_RpAudIntChunkDone:
	MOVE.W	(n_pt4_intmask,A1),(154,A5)
	MOVE.W	(n_pt4_dmacon,A1),(150,A5)
	SF	(n_pt4_chunked,A1)
	CLR.W	(n_pt4_chunkvol,A1)
	CLR.W	(n_pt4_volmul,A1)
	MOVE.W	D1,(aud_VOL,A6)
	MOVE.W	#$0001,(aud_PER,A6)
	BRA.S	pt_RpAudIntExit
pt_RpAudIntStart:
	TST.W	(n_pt4_dmacount,A1)
	BEQ.S	pt_RpAudIntStartVol
	CMPI.W	#$0001,(n_pt4_dmacount,A1)
	BEQ.S	pt_RpAudIntStartLoop
	BRA.S	pt_RpAudIntStop
pt_RpAudIntStartVol:
	BTST	#3,dat_UIBitFlags
	BEQ.S	pt_RpAudIntStartVol2
	MOVEQ	#80,D1
	JSR	pt_WaitDMASync
pt_RpAudIntStartVol2:
	MOVEQ	#0,D0
	MOVE.B	(n_volume,A1),D0
	MULU.W	(n_pt4_volscale,A1),D0
	ADD.W	#$0020,D0
	LSR.W	#6,D0
	MOVE.W	D0,(aud_VOL,A6)
	MOVE.W	(n_pt4_dmaset,A1),(150,A5)
	MOVE.W	(n_pt4_intmask,A1),(156,A5)
	MOVE.W	(n_period,A1),(aud_PER,A6)
	BRA.S	pt_RpAudIntExit
pt_RpAudIntStartLoop:
	MOVE.W	(n_pt4_intmask,A1),(156,A5)
	MOVE.W	(n_pt4_intmask,A1),(154,A5)
	CLR.B	(n_pt4_dmawait,A1)
	MOVE.L	(n_loopstart,A1),(A6)
	MOVE.W	(n_replen,A1),(aud_LEN,A6)
pt_RpAudIntExit:
	ADDQ.W	#1,(n_pt4_dmacount,A1)
	MOVE.W	#$c000,(154,A5)
	RTS
pt_RpAudIntStop:
	MOVE.W	#$ffff,D0
pt_RpAudIntStopLoop:
	MOVE.W	D0,D1
	AND.W	#$0f00,D1
	DBF	D0,pt_RpAudIntStopLoop
	MOVE.W	(n_pt4_intmask,A1),(154,A5)
	CLR.B	(n_pt4_dmawait,A1)
	CLR.B	(n_pt4_chunked,A1)
	BRA.S	pt_RpAudIntExit
pt_SetupVBlank:
	BSET	#0,dat_ModeFlags
	BSR.S	pt_AllocCIATimer
	BNE.S	pt_VBlankFailed
	MOVEQ	#0,D0
	RTS
pt_VBlankFailed:
	MOVEQ	#-1,D0
	RTS
pt_FreeCIAResource:
	MOVE.L	dat_CIAResourceBase,D0
	BNE.W	pt_RemoveCIATimer
	RTS
dat_CIAIntServer:
	DS.L	2
	DC.W	$0210
	DC.L	str_CIAMusicInt
	DS.L	1
	DC.L	pt_RpInterrupt
str_CIAMusicInt:
	DC.B	"Protracker CIA MusicInt",0,0,0
pt_AllocCIATimer:
	LEA	CIAB_PRA,A5
	MOVE.B	#$62,dat_CIAResChar
	BSR.S	pt_OpenCIAResource
	BNE.S	pt_TryCIAA
	BSR.W	pt_AddCIAVectorB
	BEQ.S	pt_CIAAllocFail
	BSR.W	pt_AddCIAVector
	BEQ.S	pt_CIAAllocFail
pt_TryCIAA:
	MOVE.B	#$61,dat_CIAResChar
	LEA	CIAA_PRA,A5
	BSR.S	pt_OpenCIAResource
	BNE.S	pt_CIAAllocSuccess
	BSR.W	pt_AddCIAVectorB
	BEQ.S	pt_CIAAllocFail
	BSR.S	pt_AddCIAVector
	BEQ.S	pt_CIAAllocFail
pt_CIAAllocSuccess:
	CLR.L	dat_CIAResourceBase
	TSTPC.L	dat_ActiveCopperPtr
	BNE.S	pt_CIAAllocDone
	LEA	(dat_ReqCIAErr,PC),A1
	BSR.W	pt_ShowErrorReq
pt_CIAAllocDone:
	MOVEQ	#-1,D0
	RTS
pt_CIAAllocFail:
	MOVEQ	#0,D0
	RTS
pt_OpenCIAResource:
	MOVEQ	#0,D0
	LEA	(str_CIAResource,PC),A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-498,A6)
	MOVE.L	D0,dat_CIAResourceBase
	BEQ.W	pt_CIAOpFailed
	MOVEA.L	D0,A6
	MOVEA.L	dat_GfxLibBase,A0
	MOVE.W	(206,A0),D0
	BTST	#2,D0
	BEQ.S	pt_SetPALTiming
	MOVE.L	#$001b0f87,D7
	BRA.S	pt_StoreTimingConst
pt_SetPALTiming:
	MOVE.L	#$001b4f4d,D7
pt_StoreTimingConst:
	MOVE.L	D7,dat_CIATimingBase
	DIVU	#$007d,D7
	MOVEQ	#0,D0
	RTS
pt_AddCIAVector:
	LEA	(dat_CIAIntServer,PC),A1
	MOVEQ	#1,D0
	JSR	(-6,A6)
	MOVE.L	#$00000001,dat_CIATimerSelect
	TST.L	D0
	BNE.S	pt_CIAOpFailed
	MOVE.L	A5,dat_CIABaseAddr
	BCLR	#0,(3840,A5)
	MOVE.B	D7,(1536,A5)
	LSR.W	#8,D7
	MOVE.B	D7,(1792,A5)
	MOVEQ	#0,D0
	RTS
pt_AddCIAVectorB:
	LEA	(dat_CIAIntServer,PC),A1
	MOVEQ	#0,D0
	JSR	(-6,A6)
	CLR.L	dat_CIATimerSelect
	TST.L	D0
	BNE.S	pt_CIAOpFailed
	MOVE.L	A5,dat_CIABaseAddr
	BCLR	#0,(3584,A5)
	MOVE.B	D7,(1024,A5)
	LSR.W	#8,D7
	MOVE.B	D7,(1280,A5)
	MOVEQ	#0,D0
	RTS
pt_CIAOpFailed:
	MOVEQ	#-1,D0
	RTS
pt_RemoveCIATimer:
	CLR.L	dat_CIAResourceBase
	MOVEA.L	D0,A6
	MOVEA.L	(dat_CIABaseAddr,PC),A5
	TST.L	dat_CIATimerSelect
	BEQ.S	pt_RemCIATimerB
	BCLR	#0,(3840,A5)
	MOVEQ	#1,D0
	BRA.S	pt_RemCIAVector
pt_RemCIATimerB:
	BCLR	#0,(3584,A5)
	MOVEQ	#0,D0
pt_RemCIAVector:
	LEA	(dat_CIAIntServer,PC),A1
	MOVEQ	#0,D0
	JSR	(-12,A6)
	RTS
str_CIAResource:
	DC.W	$6369
	DC.B	$61
dat_CIAResChar:
	DC.B	"a.resource",0
dat_CIAResourceBase:
	DS.L	1
dat_CIATimerSelect:
	DS.L	1
dat_CIATimingBase:
	DS.L	1
	CMP.W	#$005e,D0
	BCC.S	pt_DecTempo
	CMP.W	#$0050,D0
	BCC.S	pt_IncTempo
	RTS
pt_IncTempo:
	MOVE.W	dat_SavedTempo,D0
	ADDQ.W	#1,D0
	RMB
	BNE.S	pt_IncTempoCheck
	ADDQ.W	#8,D0
	ADDQ.W	#1,D0
pt_IncTempoCheck:
	CMP.W	#$00ff,D0
	BLS.S	pt_StoreTempo
	MOVE.W	#$00ff,D0
pt_StoreTempo:
	MOVE.W	D0,dat_SavedTempo
	MOVE.W	D0,dat_CurrentTempo
	BSR.S	pt_UpdateTempoDisp
	BSR.S	pt_SetTempo
	JMP	pt_RefreshDisplay
pt_DecTempo:
	MOVE.W	dat_SavedTempo,D0
	SUBQ.W	#1,D0
	RMB
	BNE.S	pt_DecTempoCheck
	SUBQ.W	#8,D0
	SUBQ.W	#1,D0
pt_DecTempoCheck:
	CMP.W	#$0020,D0
	BCC.S	pt_StoreTempo
	MOVE.W	#$0020,D0
	BRA.S	pt_StoreTempo
pt_UpdateTempoDisp:
	JSR	pt_SetIsP1
	NOP
	BEQ.S	pt_DrawTempoValue
	RTS
pt_DrawTempoValue:
	MOVE.W	#$0103,dat_TextBytePos
	MOVE.W	dat_SavedTempo,dat_DisplayParam
	JMP	pt_DrawTempoStr
pt_SetTempo:
	MOVEQ	#125,D0
	MOVE.L	(dat_CIAResourceBase,PC),D1
	BEQ.S	pt_TempoCheckDisplay
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_TempoClampMin
	MOVE.W	(dat_CurrentTempo,PC),D0
pt_TempoClampMin:
	CMP.W	#$0020,D0
	BCC.S	pt_TempoSaveVBlank
	MOVEQ	#32,D0
pt_TempoSaveVBlank:
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_TempoCheckDisplay
	MOVE.W	D0,dat_CurrentTempo
pt_TempoCheckDisplay:
	TST.W	dat_SamplerActive
	BNE.S	pt_TempoApplyCIA
	MOVE.W	D0,dat_DisplayParam
	MOVE.W	#$016c,dat_PaletteVarA
	MOVE.W	#$0080,dat_PaletteVarB
	JSR	pt_DrawBPMValue
pt_TempoApplyCIA:
	MOVE.L	(dat_CIAResourceBase,PC),D0
	BNE.S	pt_TempoHasCIA
	RTS
pt_TempoHasCIA:
	MOVEQ	#125,D0
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_TempoCalcTimer
	MOVE.W	(dat_CurrentTempo,PC),D0
pt_TempoCalcTimer:
	MOVE.L	(dat_CIATimingBase,PC),D1
	DIVU	D0,D1
	MOVEA.L	(dat_CIABaseAddr,PC),A5
	MOVE.L	(dat_CIATimerSelect,PC),D0
	BEQ.S	pt_TempoWriteTimerB
	ANDI.B	#$f7,(3840,A5)
	ORI.B	#$01,(3840,A5)
	MOVE.B	D1,(1536,A5)
	LSR.W	#8,D1
	MOVE.B	D1,(1792,A5)
	RTS
pt_TempoWriteTimerB:
	ANDI.B	#$f7,(3584,A5)
	ORI.B	#$01,(3584,A5)
	MOVE.B	D1,(1024,A5)
	LSR.W	#8,D1
	MOVE.B	D1,(1280,A5)
	RTS
dat_CurrentTempo:
	DC.W	$007d
dat_CIABaseAddr:
	DS.L	1
pt_CreateMsgPort:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dat_ScopeWorkBuf1,A1
	MOVE.L	A1,-(A7)
	MOVEQ	#-1,D0
	JSR	(-330,A6)
	MOVE.L	D0,D2
	SUBA.L	A1,A1
	JSR	(-294,A6)
	MOVEA.L	(A7)+,A1
	CLR.B	(9,A1)
	MOVE.L	#str_InputHandler,(10,A1)
	MOVE.B	#$04,(8,A1)
	MOVE.B	D2,(15,A1)
	MOVE.L	D0,(16,A1)
	JSR	(-354,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dat_1322,A0
	MOVEQ	#0,D0
	LEA	dat_DisplayWorkBuf2,A1
	MOVEQ	#0,D1
	MOVE.L	#dat_ScopeWorkBuf1,(14,A1)
	JSR	(-444,A6)
	TST.L	D0
	BNE.S	pt_InputErrJump
	LEA	dat_DisplayWorkBuf2,A1
	MOVE.W	#$0009,(28,A1)
	MOVE.L	#dat_InputIntStruct,(40,A1)
	JSR	(-456,A6)
	RTS
pt_InputErrJump:
	JMP	EXT_002e
