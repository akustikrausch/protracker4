dat_DisplayParamVar:
	DS.W	1
dat_DirListVar1:
	DS.W	1
dat_DirListVar2:
	DS.W	1
dat_02F6:
	DC.L	$0000001f,$003b005a,$00780097,$00b500d4
	DC.L	$00f30111,$0130014e
dat_02F7:
	DC.B	" (DIR)",0,0
dat_DirStringBuf:
	DS.W	1
pt_BtnMainContinue:
	TST.L	dat_RpPlayMode
	BEQ.S	pt_02FA
	RTS
pt_02FA:
	CLR.W	dat_RpCounter
	TST.W	dat_SampleEditVar2
	BNE.W	pt_0304
	BRA.S	pt_02FD
pt_02FB:
	MOVEQ	#0,D0
pt_02FC:
	CLR.W	dat_SampleEditVar2
	JSR	pt_BtnMainStop
	BSR.W	pt_ClearKeyState
	RMB
	BNE.S	pt_02FE
pt_02FD:
	MOVE.W	dat_PatViewRow,D0
pt_02FE:
	MOVE.W	D0,dat_PatternPosition
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_02FF
	LSL.W	#1,D0
pt_02FF:
	AND.L	#$0000ffff,D0
	MOVE.L	D0,dat_RpPatternPos
	BSR.W	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	CLR.B	dat_LastRawKey
	BSR.W	pt_SetPalettePlay
	CLR.W	dat_TimerDuration
	CLR.L	dat_MonthNames
	MOVE.L	#$70617470,dat_RpPlayMode
	CLR.W	dat_PatternSync
	MOVE.L	#$ffffffff,dat_ChannelMute
	JSR	pt_PatViewSetRow
pt_0300:
	MOVE.L	dat_BplUpdateReq,D0
	MOVEA.L	dat_ModulePtr,A0
	CMP.B	(mod_songlen,A0),D0
	BCC.S	pt_0301
	MOVE.L	dat_BplUpdateReq,dat_RpSongPos
	RTS
pt_0301:
	CLR.L	dat_RpSongPos
	CLR.L	dat_BplUpdateReq
	RTS
pt_0302:
	MOVEQ	#0,D0
pt_0303:
	MOVE.W	#$ffff,dat_SampleEditVar2
	JSR	pt_BtnMainStop
	BSR.W	pt_ClearKeyState
	RMB
	BNE.S	pt_SetPatternPosition
pt_0304:
	MOVE.W	dat_PatViewRow,D0
pt_SetPatternPosition:
	MOVE.W	D0,dat_PatternPosition
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0306
	LSL.W	#1,D0
pt_0306:
	AND.L	#$00000fff,D0
	MOVE.L	D0,dat_RpPatternPos
	BSR.W	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	CLR.B	dat_LastRawKey
	MOVE.L	#$70617474,dat_RpPlayMode
	BSR.W	pt_SetPalettePlay
pt_PatternModeSetup:
	MOVE.L	dat_PatTableIdx,dat_RpSongPos
	CLR.B	dat_KeyCode
	RTS
	MOVEA.L	dat_ModulePtr,A1
	LEA	(mod_positions,A1),A1
	MOVE.L	dat_BplUpdateBuf,D0
	MOVE.B	(0,A1,D0.W),dat_1371
	JSR	pt_PatViewDrawAll
	BRA.W	pt_0302
pt_0308:
	BTST	#0,dat_InputReadyFlag
	BEQ.W	pt_PatternEditReturn
	CLR.B	dat_KeyCode
	BSR.W	pt_WaitMouseRelease
pt_0309:
	JSR	pt_ScreenDragUpdate
	LMB
	BEQ.W	pt_PatternEditReturn
	RMB
	BEQ.W	pt_PatternEditReturn
	BSR.W	pt_GetKeypress
	TST.B	dat_KeyCode
	BEQ.S	pt_0309
	MOVE.B	dat_KeyCode,D0
	MOVE.B	D0,dat_LastRawKey
	MOVEQ	#0,D0
	TST.W	dat_SamplerActive
	BEQ.S	pt_030A
	RTS
pt_030A:
	JSR	pt_BtnMainStop
	RMB
	BEQ.S	pt_030B
	MOVE.W	dat_PatViewRow,D0
pt_030B:
	MOVE.W	D0,dat_PatternPosition
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_030C
	LSL.W	#1,D0
pt_030C:
	AND.L	#$00000fff,D0
	MOVE.L	D0,dat_RpPatternPos
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SetPaletteRec
	MOVE.B	D1,dat_KeyCode
	CLR.B	dat_KeyCode
	CLR.B	dat_LastRawKey
	BSR.W	pt_ConvertKeyToNote
	MOVE.L	#$65646974,dat_SongDataPtr
	MOVE.L	#$70617474,dat_RpPlayMode
	JSR	pt_HandleCursorEdit
	TST.B	dat_PlaybackModeFlag
	BEQ.W	pt_PatternModeSetup
	MOVE.L	#$70617470,dat_RpPlayMode
	BRA.W	pt_0300
pt_PatternEditReturn:
	MOVEQ	#0,D0
pt_030E:
	TST.W	dat_SamplerActive
	BEQ.S	pt_030F
	RTS
pt_030F:
	JSR	pt_BtnMainStop
	RMB
	BEQ.S	pt_0310
	MOVE.W	dat_PatViewRow,D0
pt_0310:
	MOVE.W	D0,dat_PatternPosition
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0311
	LSL.W	#1,D0
pt_0311:
	AND.L	#$00000fff,D0
	MOVE.L	D0,dat_RpPatternPos
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SetPaletteRec
	CLR.B	dat_KeyCode
	CLR.B	dat_LastRawKey
	BSR.W	pt_ConvertKeyToNote
	MOVE.L	#$65646974,dat_SongDataPtr
	MOVE.L	#$70617474,dat_RpPlayMode
	TST.B	dat_PlaybackModeFlag
	BEQ.W	pt_PatternModeSetup
	MOVE.L	#$70617470,dat_RpPlayMode
	BRA.W	pt_0300
pt_InitEditState:
	CLR.B	dat_KeyCode
	CLR.W	dat_EditCursorPos
	MOVE.W	#$0001,dat_UIMode
	SF	dat_EditInputLock
	TST.W	dat_RecordMode
	BNE.S	pt_EditUpdateScope
	BSR.W	pt_SetPaletteBright
	TST.W	dat_RpPlayMode
	BEQ.S	pt_EditCheckRecord
	BSR.W	pt_SetPalettePlay
pt_EditCheckRecord:
	TST.L	dat_SongDataPtr
	BEQ.S	pt_EditSavePalette
	BSR.W	pt_SetPaletteRec
pt_EditSavePalette:
	BSR.W	pt_SavePaletteState
pt_EditUpdateScope:
	BSR.W	pt_UpdateScopeDisplay
	CMPI.W	#$0008,dat_OptPage
	JSR	pt_OptPageRefresh
	ST	dat_ScopeBufferRef
	BSR.W	pt_DrawStatusBar
pt_0316:
	MOVE.W	#$2835,dat_TextBytePos
	MOVE.W	dat_EditStepSize,D0
	JSR	pt_DrawNumberDec
	RTS
pt_AudioBufferInit:
	BSR.W	pt_CheckEditMode3
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	LEA	(280,A1),A1
	MOVE.W	#$0473,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D3
pt_0318:
	MOVE.L	D1,(A1)+
	ADDQ.L	#4,D3
	CMP.L	#$00000028,D3
	BNE.S	pt_0319
	MOVEQ	#0,D3
	LEA	(40,A1),A1
pt_0319:
	DBF	D0,pt_0318
	CLR.W	dat_ButtonScanIdx
	MOVE.W	#$0053,dat_ButtonScanMax
	BRA.W	pt_ScanButtonHitbox
pt_InitAudioDisplay:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$0001,D0
	MOVEQ	#1,D1
	MOVE.W	#$027f,D2
	MOVEQ	#119,D3
	MOVEQ	#0,D5
	JSR	pt_SetupAudioDisplay
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_WaitMouseRelease:
	BSR.W	pt_ScreenDragUpdate
	LMB
	BEQ.S	pt_WaitMouseRelease
	RMB
	BEQ.S	pt_WaitMouseRelease
	BSR.S	pt_031C
	LMB
	BEQ.S	pt_WaitMouseRelease
	RMB
	BEQ.S	pt_WaitMouseRelease
	RTS
pt_031C:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#2,D1
	JSR	(-198,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_ShowYesNoDialog:
	CMPI.W	#$0009,dat_UIMode
	BNE.S	pt_031E
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_LeavePosEdit
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_031E:
	MOVE.L	A0,-(A7)
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	JSR	pt_RefreshDisplay
	BSR.W	pt_CopyPatternBlock
	MOVEA.L	(A7)+,A0
	LEA	dat_CopperBufReserve,A1
	LEA	dat_144E,A2
	MOVE.L	#$00000460,D0
	BSR.W	pt_BlitCopyBlock
	CLR.B	dat_KeyCode
pt_MainInputLoop:
	BSR.W	pt_ScreenDragUpdate
	BSR.W	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$15,D0
	BEQ.S	pt_ScreenRefresh
	CMP.B	#$31,D0
	BEQ.S	pt_ScreenRefresh
	CMP.B	#$44,D0
	BEQ.S	pt_ScreenRefresh
	CMP.B	#$36,D0
	BEQ.S	pt_UpdateMainUI
	CMP.B	#$45,D0
	BEQ.S	pt_UpdateMainUI
	LMB
	BNE.S	pt_MainInputLoop
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_1444,A0
	BSR.W	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_MainInputLoop
	CMP.W	#$0001,D2
	BEQ.S	pt_ScreenRefresh
	CMP.W	#$0003,D2
	BEQ.S	pt_UpdateMainUI
	CMP.W	#$000a,D2
	BNE.S	pt_MainInputLoop
	BSR.W	pt_ScreenStateHandler
	BRA.S	pt_MainInputLoop
pt_UpdateMainUI:
	BSR.W	pt_CopyScreenBufs
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePaletteInit
	JSR	pt_RefreshDisplay
	BSR.W	pt_WaitMouseRelease
	CLR.W	dat_DiskOpFlag
	CLR.B	dat_KeyCode
	MOVEQ	#-1,D0
	RTS
pt_ScreenRefresh:
	BSR.W	pt_CopyScreenBufs
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	JSR	pt_RefreshDisplay
	BSR.W	pt_WaitMouseRelease
	CLR.W	dat_DiskOpFlag
	CLR.B	dat_KeyCode
	MOVEQ	#0,D0
	RTS
pt_0322:
	MOVE.L	A0,-(A7)
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	JSR	pt_RefreshDisplay
	BSR.W	pt_CopyPatternBlock
	MOVEA.L	(A7)+,A0
	LEA	dat_CopperBufReserve,A1
	LEA	dat_144F,A2
	MOVE.L	#$00000460,D0
	BSR.W	pt_BlitCopyBlock
pt_UpdateDisplayScreen:
	JSR	pt_ScreenDragUpdate
	BSR.W	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$13,D0
	BEQ.S	pt_MainUIExit
	CMP.B	#$44,D0
	BEQ.S	pt_MainUIExit
	CMP.B	#$33,D0
	BEQ.S	pt_MainUIBranch
	CMP.B	#$45,D0
	BEQ.S	pt_MainUIBranch
	LMB
	BNE.S	pt_UpdateDisplayScreen
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_1444,A0
	BSR.W	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_UpdateDisplayScreen
	CMP.W	#$0001,D2
	BEQ.S	pt_MainUIExit
	CMP.W	#$0003,D2
	BEQ.S	pt_MainUIBranch
	BRA.S	pt_UpdateDisplayScreen
pt_MainUIBranch:
	BSR.W	pt_CopyScreenBufs
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePaletteInit
	JSR	pt_RefreshDisplay
	BSR.W	pt_WaitMouseRelease
	CLR.W	dat_DiskOpFlag
	MOVEQ	#-1,D0
	RTS
pt_MainUIExit:
	BSR.W	pt_CopyScreenBufs
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	JSR	pt_RefreshDisplay
	BSR.W	pt_WaitMouseRelease
	CLR.W	dat_DiskOpFlag
	MOVEQ	#0,D0
	RTS
pt_SetupEditScreen:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVE.L	A0,-(A7)
	BSR.W	pt_CheckEditMode3
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.W	pt_CopyPatternBlock
	MOVEA.L	(A7)+,A0
	LEA	dat_146B,A1
	LEA	dat_1451,A2
	MOVE.L	#$00000460,D0
	BSR.W	pt_BlitCopyBlock
pt_DisplayUpdateLoop:
	BSR.W	pt_ScreenDragUpdate
	BSR.W	pt_GetKeypress
	CMPI.W	#$0044,dat_KeyCode
	BEQ.S	pt_ClearDiskOps
	CMPI.W	#$0045,dat_KeyCode
	BEQ.S	pt_ClearDiskOps
	LMB
	BNE.S	pt_DisplayUpdateLoop
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_ScreenConfigData,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BEQ.S	pt_DisplayUpdateLoop
	CMP.W	#$0002,D2
	BEQ.S	pt_ClearDiskOps
	BRA.S	pt_DisplayUpdateLoop
pt_ClearDiskOps:
	BSR.W	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
pt_SetupDisplayMode:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVE.L	A2,-(A7)
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.L	A1,dat_PatternEditPtr
	MOVE.L	D0,dat_PatternEditIdx
	BSR.W	pt_CopyPatternBlock
	MOVEA.L	(A7)+,A1
	LEA	dat_1454,A2
	MOVE.L	#$00000460,D0
	BSR.W	pt_BlitCopyBlock
	BSR.W	pt_0330
pt_GetKeyInputLoop:
	JSR	pt_DlgKeys41
	NOP
	LMB
	BNE.S	pt_GetKeyInputLoop
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_1448,A0
	BSR.W	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_GetKeyInputLoop
	CMP.W	#$0001,D2
	BEQ.S	pt_032B
	CMP.W	#$0003,D2
	BEQ.S	pt_032C
	CMP.W	#$0004,D2
	BEQ.S	pt_032E
	CMP.W	#$000a,D2
	BNE.S	pt_GetKeyInputLoop
	BSR.W	pt_ScreenStateHandler
	BRA.S	pt_GetKeyInputLoop
pt_032B:
	MOVEQ	#0,D0
	BRA.S	pt_032D
pt_032C:
	MOVEQ	#-1,D0
pt_032D:
	BSR.W	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	MOVEM.L	(A7)+,D1-D7/A0-A6
	TST.L	D0
	RTS
pt_032E:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	MOVEA.L	(dat_PatternEditPtr,PC),A6
	MOVE.L	A6,dat_TextStringPtr
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	(dat_PatternEditIdx,PC),D0
	ADD.L	D0,dat_SongDataAddr
	CMP.W	#$0015,D0
	BMI.S	pt_032F
	MOVEQ	#21,D0
pt_032F:
	MOVE.W	D0,dat_TextCharCount
	MOVE.W	#$010d,D0
	MOVEQ	#79,D1
	JSR	pt_StoreFxParameter
	BSR.W	pt_RestorePalette
	BSR.S	pt_0330
	BRA.W	pt_GetKeyInputLoop
pt_0330:
	MOVEA.L	(dat_PatternEditPtr,PC),A0
	MOVE.L	(dat_PatternEditIdx,PC),D3
	CMP.L	#$00000015,D3
	BMI.S	pt_0331
	MOVEQ	#21,D3
pt_0331:
	MOVE.W	#$010d,D0
	MOVEQ	#79,D1
	JMP	pt_BlitPatternFull
dat_PatternEditPtr:
	DS.L	1
dat_PatternEditIdx:
	DS.L	1
pt_BlitCopyBlock:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	A0,-(A7)
	MOVE.L	A1,-(A7)
	MOVE.L	D0,-(A7)
	CMPA.L	#$00000000,A2
	BEQ.S	pt_0335
	MOVEA.L	A2,A0
	MOVE.W	#$00c0,D0
	MOVEQ	#50,D1
	BSR.W	pt_SetDrawOffset
	MOVE.W	#$00c0,D0
	MOVEQ	#50,D1
	MOVE.W	#$01c0,D2
	MOVEQ	#114,D3
	MOVEQ	#0,D5
	JSR	pt_SetupAudioDisplay
pt_0335:
	LEA	dat_148C,A0
	MOVE.L	(A7)+,D3
	MOVE.L	(A7)+,D0
	BEQ.S	pt_0339
	MOVEA.L	D0,A1
	ADDA.L	D3,A0
	MOVEQ	#1,D1
pt_0336:
	MOVEQ	#31,D0
pt_0337:
	MOVE.B	(A1)+,(A0)
	MOVE.B	(A1)+,(1,A0)
	MOVE.B	(A1)+,(2,A0)
	MOVE.B	(A1)+,(3,A0)
	MOVE.B	(A1)+,(4,A0)
	MOVE.B	(A1)+,(5,A0)
	LEA	(80,A0),A0
	DBF	D0,pt_0337
	LEA	(17920,A0),A0
	DBF	D1,pt_0336
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	ADDA.W	#$0fb9,A0
	ADDA.L	D3,A0
	MOVEQ	#31,D0
pt_0338:
	MOVE.B	(A1)+,(A0)
	MOVE.B	(A1)+,(1,A0)
	MOVE.B	(A1)+,(2,A0)
	MOVE.B	(A1)+,(3,A0)
	MOVE.B	(A1)+,(4,A0)
	MOVE.B	(A1)+,(5,A0)
	LEA	(80,A0),A0
	DBF	D0,pt_0338
pt_0339:
	MOVE.L	(A7)+,D0
	BEQ.S	pt_033A
	MOVEA.L	D0,A0
	MOVE.W	#$00f8,D0
	MOVEQ	#55,D1
	JSR	pt_DrawBoxedText
pt_033A:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CopyPatternBlock:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_GfxBitplaneBuf,A0
	LEA	dat_148B,A1
	MOVEQ	#1,D2
pt_033C:
	MOVEQ	#63,D1
pt_033D:
	MOVEQ	#31,D0
pt_033E:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_033E
	LEA	(48,A1),A1
	DBF	D1,pt_033D
	LEA	(15360,A1),A1
	DBF	D2,pt_033C
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	ADDA.W	#$0fb8,A1
	MOVEQ	#63,D1
pt_033F:
	MOVEQ	#31,D0
pt_0340:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_0340
	LEA	(48,A1),A1
	DBF	D1,pt_033F
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CopyScreenBufs:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_GfxBitplaneBuf,A0
	LEA	dat_148B,A1
	MOVEQ	#1,D2
pt_0342:
	MOVEQ	#63,D1
pt_0343:
	MOVEQ	#31,D0
pt_0344:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0344
	LEA	(48,A1),A1
	DBF	D1,pt_0343
	LEA	(15360,A1),A1
	DBF	D2,pt_0342
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	ADDA.W	#$0fb8,A1
	MOVEQ	#63,D1
pt_0345:
	MOVEQ	#31,D0
pt_0346:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0346
	LEA	(48,A1),A1
	DBF	D1,pt_0345
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0347:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_GfxBitplaneBuf,A0
	LEA	SECSTRT_2,A1
	MOVEQ	#1,D1
pt_0348:
	MOVE.W	#$25cf,D0
pt_0349:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_0349
	LEA	(10800,A1),A1
	DBF	D1,pt_0348
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	MOVE.W	#$25cf,D0
pt_034A:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_034A
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_034B:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_GfxBitplaneBuf,A0
	LEA	SECSTRT_2,A1
	MOVEQ	#1,D1
pt_034C:
	MOVE.W	#$25cf,D0
pt_034D:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_034D
	LEA	(10800,A1),A1
	DBF	D1,pt_034C
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	MOVE.W	#$25cf,D0
pt_034E:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_034E
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_034F:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	#$0077,(2,A6)
	MOVE.W	#$0044,(6,A6)
	MOVE.W	#$00aa,(10,A6)
	MOVEA.L	(A7)+,A6
	RTS
pt_SetPaletteBright:
	JSR	pt_SchPtrNormal
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RTS
pt_SetPaletteDim:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	#$0070,(2,A6)
	MOVE.W	#$0040,(6,A6)
	MOVE.W	#$00a0,(10,A6)
	MOVEA.L	(A7)+,A6
	RTS
pt_SetPalettePlay:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	#$0770,(2,A6)
	MOVE.W	#$0440,(6,A6)
	MOVE.W	#$0aa0,(10,A6)
	MOVEA.L	(A7)+,A6
	RTS
pt_SetPaletteRec:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	#$0049,(2,A6)
	MOVE.W	#$0006,(6,A6)
	MOVE.W	#$005b,(10,A6)
	MOVEA.L	(A7)+,A6
	RTS
pt_SetPaletteSong:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	#$0727,(2,A6)
	MOVE.W	#$0404,(6,A6)
	MOVE.W	#$0a5a,(10,A6)
	MOVEA.L	(A7)+,A6
	RTS
pt_SetPaletteEdit:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	#$0900,(2,A6)
	MOVE.W	#$0700,(6,A6)
	MOVE.W	#$0c00,(10,A6)
	MOVEA.L	(A7)+,A6
	MOVE.W	#$0001,dat_TimeDisplayInit
	BSR.S	pt_UpdatePaletteAll
	JSR	pt_ClearStatusMsg
	BSR.W	pt_SetPaletteBright
	MOVEQ	#0,D0
	RTS
pt_SavePaletteState:
	MOVE.L	A6,-(A7)
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	(2,A6),dat_PaletteSave0
	MOVE.W	(6,A6),dat_PaletteSave1
	MOVE.W	(10,A6),dat_PaletteSave2
	MOVEA.L	(A7)+,A6
	RTS
pt_RestorePaletteInit:
	BSR.S	pt_SetPaletteEdit
pt_RestorePalette:
	MOVE.L	A6,-(A7)
	MOVE.W	#$0001,dat_TimeDisplayInit
	MOVEA.L	(dat_PalettePtr,PC),A6
	MOVE.W	dat_PaletteSave0,(2,A6)
	MOVE.W	dat_PaletteSave1,(6,A6)
	MOVE.W	dat_PaletteSave2,(10,A6)
	MOVEA.L	(A7)+,A6
	RTS
pt_UpdatePaletteAll:
	MOVE.W	(dat_AnimPhaseCounter,PC),D1
pt_035A:
	JSR	pt_RefreshDisplay
	DBF	D1,pt_035A
	MOVE.W	#$000f,dat_AnimPhaseCounter
	RTS
dat_AnimPhaseCounter:
	DC.W	$000f
pt_HandleJoystick:
	MOVE.W	JOY1DAT,D0
	BTST	#1,D0
	BNE.S	pt_BtnMainPlay
	BTST	#9,D0
	BNE.S	pt_035E
	BTST	#7,CIAA_PRA
	BEQ.S	pt_BtnMainPlay
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$65,D0
	BEQ.S	pt_BtnMainPlay
	CMP.B	#$67,D0
	BEQ.S	pt_BtnMainPattern
	CMP.B	#$40,D0
	BNE.W	pt_0367
	CMPI.W	#$0008,dat_UIMode
	BEQ.S	pt_035F
	TST.L	dat_RpPlayMode
	BEQ.S	pt_035D
	BSR.S	pt_0360
	JMP	pt_BtnMainStop
pt_035D:
	BSR.S	pt_0361
	TST.L	dat_SongDataPtr
	BEQ.S	pt_BtnMainEdit
pt_035E:
	BSR.S	pt_0360
	JMP	pt_BtnMainStop
pt_035F:
	JMP	pt_BtnInfoSwitch
pt_0360:
	LEA	(dat_0483,PC),A0
	JSR	pt_ShowStatusMsg
	RTS
pt_0361:
	TST.W	dat_SamplerActive
	BNE.S	pt_0362
	LEA	(dat_0484,PC),A0
	JSR	pt_ShowStatusMsg
pt_0362:
	RTS
pt_BtnMainPlay:
	LEA	(dat_0480,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_02FB
pt_BtnMainPattern:
	LEA	(dat_0481,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_0302
pt_BtnMainRecord:
	LEA	(dat_0482,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_0308
pt_BtnMainEdit:
	JSR	pt_BtnMainStop
	CLR.B	dat_KeyCode
	BSR.W	pt_SetPaletteRec
	JSR	pt_PatViewSetRow
	MOVE.L	#$65646974,dat_SongDataPtr
	BRA.W	pt_WaitMouseRelease
pt_0367:
	CMP.B	#$61,D0
	BEQ.S	pt_BtnMainRecord
	CMP.B	#$45,D0
	BEQ.W	pt_ClearInputState
	CMP.B	#$42,D0
	BEQ.W	pt_03EF
	CMP.B	#$30,D0
	BNE.S	pt_0368
	JMP	pt_StopAllAudio
pt_0368:
	CMP.B	#$3c,D0
	BNE.S	pt_0369
	JMP	pt_ConfirmYesNoDialog
pt_0369:
	CMP.B	#$0d,D0
	BEQ.W	pt_0376
	CMP.B	#$43,D0
	BEQ.W	pt_ToggleEditCursor
	LEA	(dat_0372,PC),A0
	MOVEQ	#0,D2
pt_036A:
	CMP.B	(0,A0,D2.W),D0
	BEQ.S	dat_036B
	ADDQ.W	#1,D2
	CMP.W	#$0010,D2
	BCS.S	pt_036A
	RTS
dat_036B:
	TSTPC.W	dat_CursorToggle
	BEQ.S	pt_036C
	ADD.W	#$0010,D2
pt_036C:
	MOVE.W	D2,D1
	BEQ.S	pt_0370
	BRA.S	pt_0373
pt_036D:
	MOVE.W	D1,dat_CurrentSample
pt_036E:
	CLR.B	dat_KeyCode
	CLR.L	dat_AudioCtrlVar
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_036F
	BSR.W	pt_SampleEditorSetup
pt_036F:
	JSR	pt_DrawSampleHex
	JMP	pt_RecordModeHandler
pt_0370:
	TST.W	dat_CurrentSample
	BEQ.S	pt_0371
	MOVE.W	dat_CurrentSample,dat_SamplePlayInit
	CLR.W	dat_CurrentSample
	MOVEQ	#0,D1
	BRA.S	pt_0373
pt_0371:
	JMP	pt_DrawSampleHex
dat_0372:
	DC.L	$0f5a5b5c,$5d3d3e3f,$4a2d2e2f,$5e1d1e1f
pt_0373:
	TST.B	dat_SampleKeyState
	BEQ.S	pt_036D
	CLR.B	dat_KeyCode
	MOVE.W	D1,dat_CurrentSample
	JSR	pt_DrawSampleHex
	MOVE.W	dat_CurrentSample,D0
	ADD.W	D0,D0
	MOVE.W	(dat_0374,PC,D0.W),D0
	MOVEQ	#-1,D2
	BSR.W	pt_0508
	BSR.W	pt_ClearKeyState
	JMP	pt_RecordModeHandler
dat_0374:
	DC.L	$00180018,$00180018,$00180018,$00180018
	DC.L	$00180018,$00180018,$00180018,$00180018
	DC.L	$00180018,$00180018,$00180018,$00180018
	DC.L	$00180018,$00180018,$00180018,$00180018
pt_HandleFunctionKey:
	ADD.W	D1,D1
	LEA	(dat_0374,PC,D1.W),A0
	MOVE.L	A0,dat_TempBufPtr
	MOVE.W	#$0004,dat_ScreenSizeVar
	LEA	(dat_047B,PC),A0
	JMP	pt_ShowStatusMsg
pt_0376:
	BSR.W	pt_ClearKeyState
	MOVEQ	#0,D0
	MOVE.B	dat_SampleKeyState,D0
	ADDQ.B	#1,D0
	CMP.B	#$03,D0
	BCS.S	pt_0377
	MOVEQ	#0,D0
pt_0377:
	MOVE.B	D0,dat_SampleKeyState
pt_0378:
	MOVEQ	#2,D0
	CMPI.B	#$01,dat_SampleKeyState
	BEQ.S	pt_0379
	CMPI.B	#$02,dat_SampleKeyState
	BEQ.S	pt_037A
	MOVE.W	#$4e4f,dat_SampleKeyCode
	BRA.S	pt_037B
pt_0379:
	MOVE.W	#$504c,dat_SampleKeyCode
	BRA.S	pt_037B
pt_037A:
	MOVE.W	#$4544,dat_SampleKeyCode
pt_037B:
	LEA	dat_SampleKeyCode,A0
	MOVE.W	#$2836,D1
	JSR	pt_DrawTextAt
	JMP	pt_RefreshDisplay
dat_SampleKeyCode:
	DS.W	1
dat_SampleKeyState:
	DS.W	1
pt_HandleSampleKeys:
	TSTPC.W	dat_KeyQual4
	BNE.S	pt_037F
	RTS
pt_037F:
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVE.B	dat_KeyCode,D1
	CMP.B	#$37,D1
	BNE.S	pt_0380
	BRA.S	pt_0381
pt_0380:
	CMP.B	#$36,D1
	BNE.S	pt_0382
pt_0381:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_ScreenStateHandler
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0382:
	MOVE.B	dat_PlaybackState,dat_ScreenInitData
	BSR.S	pt_0383
	MOVE.B	(dat_ScreenInitData,PC),dat_PlaybackState
	RTS
pt_0383:
	MOVEQ	#0,D0
	CLR.B	dat_PlaybackState
	CMP.B	#$01,D1
	BNE.S	pt_0384
	JMP	pt_TransposeNoteUp2
pt_0384:
	CMP.B	#$10,D1
	BNE.S	pt_0385
	JMP	pt_TransposeNoteDown2
pt_0385:
	CMP.B	#$20,D1
	BNE.S	pt_0386
	JMP	pt_TransposeOctUp2
pt_0386:
	CMP.B	#$31,D1
	BNE.S	pt_0387
	JMP	pt_TransposeOctDown2
pt_0387:
	MOVE.W	#$012c,D0
	CMP.B	#$02,D1
	BNE.S	pt_0388
	JMP	pt_TransposeNoteUp2
pt_0388:
	CMP.B	#$11,D1
	BNE.S	pt_0389
	JMP	pt_TransposeNoteDown2
pt_0389:
	CMP.B	#$21,D1
	BNE.S	pt_038A
	JMP	pt_TransposeOctUp2
pt_038A:
	CMP.B	#$32,D1
	BNE.S	pt_038B
	JMP	pt_TransposeOctDown2
pt_038B:
	MOVEQ	#0,D0
	MOVE.B	#$01,dat_PlaybackState
	CMP.B	#$03,D1
	BNE.S	pt_038C
	JMP	pt_TransposeNoteUp2
pt_038C:
	CMP.B	#$12,D1
	BNE.S	pt_038D
	JMP	pt_TransposeNoteDown2
pt_038D:
	CMP.B	#$22,D1
	BNE.S	pt_038E
	JMP	pt_TransposeOctUp2
pt_038E:
	CMP.B	#$33,D1
	BNE.S	pt_038F
	JMP	pt_TransposeOctDown2
pt_038F:
	MOVE.W	#$012c,D0
	CMP.B	#$04,D1
	BNE.S	pt_0390
	JMP	pt_TransposeNoteUp2
pt_0390:
	CMP.B	#$13,D1
	BNE.S	pt_0391
	JMP	pt_TransposeNoteDown2
pt_0391:
	CMP.B	#$23,D1
	BNE.S	pt_0392
	JMP	pt_TransposeOctUp2
pt_0392:
	CMP.B	#$34,D1
	BNE.S	pt_0393
	JMP	pt_TransposeOctDown2
pt_0393:
	RTS
	SHIFTPAD	0
pt_MainKeyDispatch:
	TSTPC.W	dat_KeyQual3
	BNE.S	pt_r05f5a
	RTS
pt_r05f5a:
	TSTPC.W	dat_KeyQual1
	BNE.W	pt_r08534
	BSR.W	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$23,D0
	BEQ.W	pt_BtnSetupFilter
	CMP.B	#$21,D0
	BNE.S	pt_r05f80
	JMP	pt_BtnOpt1Split
pt_r05f80:
	CMP.B	#$37,D0
	BNE.S	pt_r05f8c
	JMP	pt_BtnOpt1PlayNote
pt_r05f8c:
	CMP.B	#$10,D0
	BEQ.W	pt_0616
	CMP.B	#$20,D0
	BEQ.W	pt_r0a286
	CMP.B	#$31,D0
	BEQ.W	pt_r0a2da
	CMP.B	#$13,D0
	BEQ.W	pt_r0a34a
	CMP.B	#$14,D0
	BEQ.W	pt_r073ec
	CMP.B	#$35,D0
	BEQ.W	pt_r075ec
	CMP.B	#$33,D0
	BEQ.W	pt_r076b8
	CMP.B	#$32,D0
	BEQ.W	pt_r0769c
	CMP.B	#$22,D0
	BEQ.W	pt_r07850
	CMP.B	#$19,D0
	BEQ.W	pt_r07716
	CMP.B	#$17,D0
	BEQ.W	pt_r07812
	CMP.B	#$26,D0
	BEQ.W	pt_r07800
	CMP.B	#$36,D0
	BEQ.W	pt_r07646
	CMP.B	#$15,D0
	BEQ.W	pt_r07908
	CMP.B	#$11,D0
	BEQ.W	pt_r077f2
	CMP.B	#$12,D0
	BEQ.W	pt_r07a24
	CMP.B	#$18,D0
	BEQ.W	pt_r07a78
	CMP.B	#$25,D0
	BEQ.W	pt_r0796a
	CMP.B	#$28,D0
	BEQ.W	pt_r07978
	CMP.B	#$27,D0
	BEQ.W	pt_r07ace
	CMP.B	#$16,D0
	BEQ.W	pt_r07b1e
	CMP.B	#$44,D0
	BEQ.W	pt_045D
	CMP.B	#$41,D0
	BEQ.W	pt_0468
	CMP.B	#$24,D0
	BEQ.W	pt_r07b68
	CMP.B	#$34,D0
	BEQ.W	pt_r07bb8
	CMP.B	#$01,D0
	BCC.S	pt_r0605c
	RTS
pt_r0605c:
	CMP.B	#$0a,D0
	BLS.S	pt_r06064
	RTS
pt_r06064:
	BNE.S	pt_r06068
	MOVEQ	#0,D0
pt_r06068:
	MOVE.W	D0,dat_EditStepSize
	CLR.B	dat_KeyCode
	ADD.B	#$30,D0
	LEA	(pt_MainKeyDispatch+330,PC),A0
	MOVE.B	D0,(11,A0)
	JSR	pt_ShowStatusMsg
	MOVE.W	#$000a,dat_AnimPhaseCounter
	BSR.W	pt_UpdatePaletteAll
	JSR	pt_ClearStatusMsg
	BRA.W	pt_0316
	DC.W	$4544
	DC.W	$4954
	DC.W	$534b
	DC.W	$4950
	DC.W	$203d
	DC.W	$2030
	DS.W	1
pt_HandleNoteEntry:
	TSTPC.W	dat_KeyQual2
	BNE.S	pt_0396
	RTS
pt_0396:
	BSR.W	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$31,D0
	BEQ.W	pt_ScopeCh1Toggle
	CMP.B	#$32,D0
	BEQ.W	pt_ScopeCh2Toggle
	CMP.B	#$33,D0
	BEQ.W	pt_ScopeCh3Toggle
	CMP.B	#$34,D0
	BEQ.W	pt_ScopeCh4Toggle
	CMP.B	#$35,D0
	BNE.S	pt_0397
	JMP	pt_BtnSmpBoost
pt_0397:
	CMP.B	#$23,D0
	BNE.S	pt_0398
	JMP	pt_BtnSmpFilter
pt_0398:
	CMP.B	#$14,D0
	BNE.S	pt_0399
	JMP	pt_BtnSmpTuneTone
pt_0399:
	CMP.B	#$21,D0
	BNE.S	pt_039A
	JMP	pt_EnterSampler
pt_039A:
	CMP.B	#$13,D0
	BNE.S	pt_039B
	JMP	pt_BtnSmpResample
pt_039B:
	CMP.B	#$17,D0
	BNE.S	pt_039C
	JMP	pt_BtnOpt1Insert
pt_039C:
	CMP.B	#$2b,D0
	BNE.S	pt_039D
	JMP	pt_EnterComment
pt_039D:
	CMP.B	#$22,D0
	BEQ.W	pt_01AD
	CMP.B	#$2a,D0
	BEQ.W	pt_StereoModeJump
	CMP.B	#$29,D0
	BEQ.W	pt_StereoModeJump
	CMP.B	#$3a,D0
	BEQ.W	pt_03A0
	CMP.B	#$39,D0
	BEQ.W	pt_DecrementPalScroll
	CMP.B	#$38,D0
	BEQ.W	pt_IncrementPalScroll
	CMP.B	#$27,D0
	BNE.S	pt_039E
	JMP	pt_0C75
pt_039E:
	CMP.B	#$20,D0
	BNE.S	pt_039F
	JMP	pt_BtnSmpSampleNext
pt_039F:
	CMP.B	#$15,D0
	BEQ.W	pt_03A2
	CMP.B	#$1b,D0
	BEQ.W	pt_03A1
	CMP.B	#$10,D0
	BEQ.W	pt_CheckSongChanged
	CMP.B	#$3d,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$3e,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$3f,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$2d,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$2e,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$2f,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$1d,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$1e,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$1f,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$43,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$0f,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$4a,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$5e,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$5a,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$5b,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$5c,D0
	BEQ.W	pt_HandleFunctionKey
	CMP.B	#$5d,D0
	BEQ.W	pt_HandleFunctionKey
	RTS
pt_03A0:
	JMP	pt_BtnMainSetup
pt_03A1:
	JMP	pt_EnterPosEdit
pt_03A2:
	LEA	dat_12E4,A0
	BSR.W	pt_ShowYesNoDialog
	BNE.W	pt_SetPaletteEdit
	MOVE.W	dat_CurrentSample,dat_PatternKeyVar
	MOVE.W	#$0001,dat_CurrentSample
pt_03A3:
	JSR	pt_DrawSampleHex
	BSR.W	pt_SampleEditorBranch
	ADDQ.W	#1,dat_CurrentSample
	CMPI.W	#$0020,dat_CurrentSample
	BCS.S	pt_03A3
	MOVE.W	dat_PatternKeyVar,dat_CurrentSample
	JMP	pt_DrawSampleHex
pt_03A4:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03A5
	MOVEQ	#43,D2
	BRA.S	pt_03A6
pt_03A5:
	MOVEQ	#54,D2
pt_03A6:
	MOVEQ	#0,D3
	BRA.W	pt_CursorPhaseCheck
pt_03A7:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03A8
	MOVE.W	#$0073,D2
	BRA.S	pt_03A9
pt_03A8:
	MOVE.W	#$00c7,D2
pt_03A9:
	MOVEQ	#6,D3
	BRA.W	pt_CursorPhaseCheck
pt_03AA:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03AB
	MOVE.W	#$00bb,D2
	BRA.S	pt_03AC
pt_03AB:
	MOVE.W	#$0157,D2
pt_03AC:
	MOVEQ	#12,D3
	BRA.S	pt_CursorPhaseCheck
pt_03AD:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03AE
	MOVE.W	#$0103,D2
	BRA.S	pt_03AF
pt_03AE:
	MOVE.W	#$01e7,D2
pt_03AF:
	MOVEQ	#18,D3
	BRA.S	pt_CursorPhaseCheck
pt_03B0:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	MOVE.W	#$014a,D2
	MOVEQ	#24,D3
	BRA.S	pt_CursorPhaseCheck
pt_03B1:
	MOVE.W	#$0193,D2
	MOVEQ	#30,D3
	BRA.S	pt_CursorPhaseCheck
pt_03B2:
	MOVE.W	#$01db,D2
	MOVEQ	#36,D3
	BRA.S	pt_CursorPhaseCheck
pt_03B3:
	MOVE.W	#$0223,D2
	MOVEQ	#42,D3
pt_CursorPhaseCheck:
	SUB.W	D2,D0
	TST.B	dat_CopyControlData
	BEQ.S	pt_03B5
	BSR.W	pt_03BC
	BEQ.S	pt_03B5
	RTS
pt_03B5:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03B6
	MULU	#$0002,D0
pt_03B6:
	BSR.W	pt_WaitMouseRelease
	MOVEQ	#0,D4
	CMP.W	#$0030,D0
	BMI.S	pt_MouseColumnUpdate
	ADDQ.W	#1,D4
	CMP.W	#$0040,D0
	BMI.S	pt_MouseColumnUpdate
	ADDQ.W	#1,D4
	CMP.W	#$0050,D0
	BMI.S	pt_MouseColumnUpdate
	ADDQ.W	#1,D4
	CMP.W	#$0060,D0
	BMI.S	pt_MouseColumnUpdate
	ADDQ.W	#1,D4
	CMP.W	#$0070,D0
	BMI.S	pt_MouseColumnUpdate
	ADDQ.W	#1,D4
	CMP.W	#$0080,D0
	BMI.S	pt_MouseColumnUpdate
	ADDQ.W	#1,D4
pt_MouseColumnUpdate:
	ADD.W	D3,D4
	MOVE.W	D4,dat_CursorColumn
	TST.W	dat_RpPlayMode
	BNE.S	pt_03BA
	SUB.W	#$0096,D1
	ASR.W	#3,D1
	SUBQ.W	#6,D1
	ADD.W	D1,dat_PatternPosition
	BPL.S	pt_03B8
	CLR.W	dat_PatternPosition
pt_03B8:
	CMPI.W	#$003f,dat_PatternPosition
	BMI.S	pt_03B9
	MOVE.W	#$003f,dat_PatternPosition
pt_03B9:
	JSR	pt_PatViewSetRow
pt_03BA:
	BSR.W	pt_ReturnFromPlay
	TST.L	dat_RpPlayMode
	BEQ.S	pt_03BB
	RTS
pt_03BB:
	CLR.W	dat_PatEditScope
	JMP	pt_ScreenMode7Check
pt_03BC:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.L	dat_RpPlayMode
	BNE.W	pt_03D0
	MOVE.W	D2,dat_BlitControlPtr
	MOVE.W	D3,dat_03EA
	BSR.W	pt_ClearDataRegs
	MOVE.L	#$ffffffff,dat_DrawParamBlock
	MOVEM.W	dat_EditDigitValue,D0-D1
	SUB.W	(dat_BlitControlPtr,PC),D0
	BMI.W	pt_03D2
	CMP.W	#$00fe,D1
	BPL.W	pt_MenuUpCmd
	SUB.W	#$0096,D1
	BMI.W	pt_MenuUpCmd
	EXT.L	D0
	DIVS	#$000c,D0
	ASR.W	#3,D1
	ADD.W	dat_PatternPosition,D1
	CMP.W	#$0006,D1
	BMI.W	pt_MenuUpCmd
	CMP.W	#$0046,D1
	BPL.W	pt_MenuUpCmd
	MOVE.W	D1,D2
	SWAP	D2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03BD
	CMP.W	#$0004,D0
	BPL.S	pt_03BE
	MOVEQ	#0,D0
	BRA.S	pt_BitplaneCopy
pt_03BD:
	CMP.W	#$0007,D0
	BPL.S	pt_03BF
	MOVEQ	#0,D0
	BRA.S	pt_BitplaneCopy
pt_03BE:
	MOVEQ	#4,D0
	BRA.S	pt_BitplaneCopy
pt_03BF:
	MOVEQ	#7,D0
pt_BitplaneCopy:
	MOVE.W	D0,D2
	MOVE.L	D2,dat_CopyWidth
	MOVE.W	(dat_03E4,PC),dat_BlitControlVar
pt_03C1:
	BSR.W	pt_ScreenDragUpdate
	RMB
	BNE.W	pt_MenuUpCmd
	MOVE.W	(dat_03E4,PC),D7
	MOVEM.W	dat_EditDigitValue,D2-D3
	CMP.W	#$00fd,D3
	BMI.S	pt_03C3
	ADDQ.W	#1,dat_PatternPosition
	CMPI.W	#$003f,dat_PatternPosition
	BMI.S	pt_03C2
	MOVE.W	#$003f,dat_PatternPosition
pt_03C2:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_PatViewSetRow
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#0,D1
	MOVE.W	(dat_BlitControlVar,PC),D1
	JSR	(-198,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.W	#$00fc,D3
	MOVE.W	(dat_03E5,PC),D7
pt_03C3:
	SUB.W	#$0096,D3
	BPL.S	pt_03C5
	SUBQ.W	#1,dat_PatternPosition
	BPL.S	pt_03C4
	CLR.W	dat_PatternPosition
pt_03C4:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_PatViewSetRow
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#0,D1
	MOVE.W	(dat_BlitControlVar,PC),D1
	JSR	(-198,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D3
	MOVE.W	(dat_03E5,PC),D7
pt_03C5:
	MOVE.W	D7,dat_BlitControlVar
	SUB.W	(dat_BlitControlPtr,PC),D2
	BPL.S	pt_03C6
	MOVEQ	#0,D2
pt_03C6:
	EXT.L	D2
	DIVS	#$000c,D2
	CMP.W	#$000b,D2
	BMI.S	pt_03C7
	MOVEQ	#11,D2
pt_03C7:
	ASR.W	#3,D3
	CMP.W	#$000d,D3
	BMI.W	pt_03C8
	MOVE.W	#$000d,D3
pt_03C8:
	ADD.W	dat_PatternPosition,D3
	CMP.W	#$0007,D3
	BPL.S	pt_03C9
	MOVEQ	#7,D3
pt_03C9:
	CMP.W	#$0045,D3
	BMI.S	pt_03CA
	MOVE.W	#$0045,D3
pt_03CA:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03CB
	CMP.W	#$0004,D2
	BPL.S	pt_03CC
	MOVEQ	#0,D2
	BRA.S	pt_CopyLineIteration
pt_03CB:
	CMP.W	#$0007,D2
	BPL.S	pt_03CD
	MOVEQ	#0,D2
	BRA.S	pt_CopyLineIteration
pt_03CC:
	MOVEQ	#4,D2
	BRA.S	pt_CopyLineIteration
pt_03CD:
	MOVEQ	#7,D2
pt_CopyLineIteration:
	MOVE.W	D3,D4
	SWAP	D4
	MOVE.W	D2,D4
	CMP.L	(dat_CopyWidth,PC),D4
	BEQ.W	pt_03C1
	MOVE.L	D4,dat_CopyWidth
	MOVE.W	(dat_BlitControlPtr,PC),D4
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_03D7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.W	pt_03C1
pt_03CF:
	CLR.L	dat_DrawParamBlock
pt_03D0:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D4
	RTS
pt_MenuUpCmd:
	TST.L	dat_DrawParamBlock
	BMI.S	pt_03CF
pt_03D2:
	MOVE.W	#$0003,dat_PatEditScope
	JSR	pt_ScreenMode7Check
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#-1,D4
	RTS
pt_MenuDownCmd:
	TST.L	dat_DrawParamBlock
	BEQ.S	pt_03D4
	MOVE.W	(dat_03E7,PC),D0
	MOVE.W	(dat_03E9,PC),D1
	ADDQ.W	#1,D1
	SUB.W	D0,D1
	SUBQ.W	#6,D0
	MOVE.W	D1,dat_DisplayFieldSize
	MOVE.W	D0,dat_EditCursorRow
	MOVE.W	(dat_03EA,PC),dat_EditCursorCol
	TST.W	dat_03E6
	SNE	dat_TrackScrollKeepNote
	TST.W	dat_03E8
	SEQ	dat_TrackScrollKeepFx
	MOVEQ	#0,D0
	RTS
pt_03D4:
	MOVEQ	#-1,D0
	RTS
pt_LoadDrawParams:
	MOVEM.W	(dat_DrawParamBlock,PC),D0-D3
	BRA.W	pt_CopyTerminate
pt_ClearDataRegs:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEM.W	D0-D3,dat_DrawParamBlock
pt_03D7:
	MOVEM.W	D0-D4,-(A7)
	MOVEM.W	(dat_03EC,PC),D0-D3
	BSR.W	pt_CopyTerminate
	MOVEM.W	(A7)+,D0-D4
	CMP.W	D0,D2
	BPL.S	pt_03D8
	EXG	D0,D2
pt_03D8:
	CMP.W	D1,D3
	BPL.S	pt_03D9
	EXG	D1,D3
pt_03D9:
	MOVEM.W	D0-D3,dat_03ED
	TST.W	D2
	BNE.S	pt_03DC
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03DA
	MOVEQ	#4,D2
	BRA.S	pt_03DB
pt_03DA:
	MOVEQ	#7,D2
pt_03DB:
	BRA.S	pt_03DD
pt_03DC:
	MOVEQ	#11,D2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_03DD
	MOVE.W	#$0006,D2
pt_03DD:
	MULS	#$000c,D0
	MULS	#$000c,D2
	ASL.W	#3,D1
	ASL.W	#3,D3
	ADD.W	D4,D0
	ADD.W	D4,D2
	ADD.W	#$0092,D1
	ADD.W	#$0092,D3
	ADDQ.W	#8,D3
	MOVEM.W	D0-D3,dat_03EC
	TST.W	D4
	BNE.S	pt_03DE
	RTS
pt_03DE:
	MOVEM.W	D0-D3,dat_DrawParamBlock
	BSR.S	pt_CopyTerminate
	MOVEM.W	(dat_03ED,PC),D0-D3
	MOVEM.W	D0-D3,dat_03E6
	RTS
pt_CopyTerminate:
	TST.W	D0
	BNE.S	pt_03E0
	RTS
pt_03E0:
	JMP	pt_0FA5
dat_BlitControlPtr:
	DS.L	1
dat_BlitControlVar:
	DS.W	1
dat_CopyWidth:
	DS.L	1
dat_03E4:
	DC.W	$0014
dat_03E5:
	DC.W	$0002
dat_03E6:
	DS.W	1
dat_03E7:
	DS.W	1
dat_03E8:
	DS.W	1
dat_03E9:
	DS.W	1
dat_03EA:
	DS.W	1
dat_DrawParamBlock:
	DS.L	2
dat_03EC:
	DS.L	2
dat_03ED:
	DS.L	2
dat_CopyControlData:
	DS.W	1
pt_03EF:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BNE.S	pt_03F1
	MOVE.W	dat_CursorColumn,D0
	DIVU	#$0006,D0
	ADDQ.W	#1,D0
	CMP.W	dat_RpNumChannels,D0
	BNE.S	pt_CalculateCursor
	MOVEQ	#0,D0
pt_CalculateCursor:
	MULU	#$0006,D0
	MOVE.W	D0,dat_CursorColumn
	BRA.W	pt_ReturnFromPlay
pt_03F1:
	MOVE.W	dat_CursorColumn,D0
	ADDQ.W	#5,D0
	DIVU	#$0006,D0
	SUBQ.W	#1,D0
	BPL.S	pt_CalculateCursor
	MOVE.W	dat_RpNumChannels,D0
	SUBQ.W	#1,D0
	BRA.S	pt_CalculateCursor
pt_ClearInputState:
	CLR.B	dat_KeyCode
	CLR.B	dat_LastRawKey
	MOVE.W	dat_UIMode,D0
	CMP.W	#$0002,D0
	BCS.S	pt_03F5
pt_EditModeDispatcher:
	MOVE.W	dat_UIMode,D0
	CMP.W	#$0002,D0
	BEQ.W	pt_InitEditMode
	CMP.W	#$0003,D0
	BEQ.W	pt_BtnDiskMainMenu
	CMP.W	#$0005,D0
	BEQ.W	pt_BtnSetupMainMenu
	CMP.W	#$0006,D0
	BEQ.S	pt_03F7
	CMP.W	#$0008,D0
	BEQ.S	pt_03F8
	CMP.W	#$0009,D0
	BNE.S	pt_03F4
	JMP	pt_LeavePosEdit
pt_03F4:
	RTS
pt_03F5:
	TST.W	dat_SamplerActive
	BNE.S	pt_03F6
	TST.W	dat_EditCursorPos
	BNE.W	pt_0495
	RTS
pt_03F6:
	JMP	pt_BtnSmpExit
pt_03F7:
	JMP	pt_BtnPlstExit
pt_03F8:
	JMP	pt_BtnInfoExit
pt_ScreenStateHandler:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	dat_03FB
	BNE.S	pt_03FA
	BSR.W	pt_WaitScreenFree
	BSR.S	pt_OpenScreenInit
pt_03FA:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_03FB:
	JSR	pt_ScrBack41
	BEQ.S	pt_03FE
	TST.L	dat_RpPlayMode
	BNE.S	pt_03FC
	JSR	pt_BtnMainStop
pt_03FC:
	BSR.W	pt_RemovePorts
	BSR.W	pt_DeleteMsgPort
	BSR.W	pt_RestoreIntVecs
	BSR.W	pt_RestoreCopper
	MOVEA.L	(dat_ScreenPtr,PC),A0
	MOVEA.L	dat_IntuiLibBase,A6
	CMPA.L	(60,A6),A0
	BNE.S	pt_03FD
	JSR	(-246,A6)
pt_03FD:
	MOVEQ	#0,D0
	RTS
pt_03FE:
	MOVEQ	#-1,D0
	RTS
	SHIFTPAD	1
pt_OpenScreenInit:
	JSR	pt_ScrBackDone41
	JSR	(-252,A6)
	BSR.W	pt_AddPorts
	BSR.W	pt_CreateMsgPort
	BSR.W	pt_SetVectorAud0
	BSR.W	pt_ClearKeyState
	BRA.W	pt_SetupCopper
pt_BtnMainAbout:
	MOVE.W	#$ffff,dat_DiskOpFlag
	SF	dat_ScopeBufferRef
	BSR.W	pt_0347
	LEA	dat_1450,A0
	MOVEQ	#64,D0
	MOVEQ	#11,D1
	BSR.W	pt_SetDrawOffset
	MOVE.W	#$0040,D0
	MOVEQ	#11,D1
	MOVE.W	#$0240,D2
	MOVEQ	#114,D3
	MOVEQ	#0,D5
	JSR	pt_SetupAudioDisplay
	JSR	pt_MemAboutHook
	MOVE.W	#$0050,D0
	MOVEQ	#16,D1
	JSR	pt_DrawBoxedText
	SUBA.L	A0,A0
	LEA	dat_1470,A1
	SUBA.L	A2,A2
	MOVE.L	#$fffff551,D0
	BSR.W	pt_BlitCopyBlock
pt_0401:
	BSR.W	pt_ScreenDragUpdate
	BSR.W	pt_GetKeypress
	BSR.W	pt_HandleSampleKeys
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$40,D0
	BEQ.S	pt_ScopeUpdate
	CMP.B	#$44,D0
	BEQ.S	pt_ScopeUpdate
	CMP.B	#$45,D0
	BEQ.S	pt_ScopeUpdate
	LMB
	BNE.S	pt_0401
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_ScreenConfigData,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BEQ.S	pt_0401
pt_ScopeUpdate:
	BSR.W	pt_034B
	ST	dat_ScopeBufferRef
	CLR.W	dat_DiskOpFlag
	CLR.B	dat_KeyCode
	RTS
pt_0403:
	MOVEA.L	A0,A2
	MOVEA.L	A1,A3
	LEA	dat_CursorAnimBuf,A5
	LEA	(20,A5),A4
	MOVE.L	A4,(10,A5)
	LEA	(A5),A0
	MOVE.L	A0,(A4)
	MOVEA.L	(dat_ThisTask,PC),A0
	LEA	(92,A0),A0
	MOVE.L	A0,(4,A4)
	MOVE.L	#$00000009,(8,A4)
	MOVE.L	A3,D1
	LSR.L	#2,D1
	MOVE.L	D1,(20,A4)
	MOVEA.L	A2,A0
	MOVE.L	A0,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-174,A6)
	MOVEA.L	D0,A0
	LEA	dat_CursorAnimBuf,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-366,A6)
	MOVEA.L	(dat_ThisTask,PC),A0
	LEA	(92,A0),A0
	MOVE.L	A0,-(A7)
	JSR	(-384,A6)
	MOVEA.L	(A7)+,A0
	JSR	(-372,A6)
	MOVEA.L	D0,A1
	TST.L	D0
	BEQ.S	pt_0404
	JSR	(-378,A6)
pt_0404:
	RTS
pt_HandleHelpKey:
	CMPI.B	#$5f,dat_KeyCode
	BEQ.S	pt_0406
	RTS
pt_0406:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BNE.S	pt_0408
	TSTPC.W	dat_KeyQual3
	BNE.S	pt_0407
	BRA.S	pt_040B
pt_0407:
	CLR.B	dat_StereoMode
	LEA	dat_047C,A0
	BRA.S	pt_0409
pt_0408:
	MOVE.B	#$01,dat_StereoMode
	LEA	dat_047D,A0
pt_0409:
	JSR	pt_ShowStatusMsg
	BSR.W	pt_UpdatePaletteAll
	JMP	pt_ClearStatusMsg
pt_StereoModeJump:
	JMP	pt_EnterPlst
pt_040B:
	CMPI.B	#$01,dat_StereoMode
	BEQ.S	pt_StereoModeJump
pt_040C:
	CMPI.W	#$0002,dat_UIMode
	BEQ.W	pt_InitEditMode
	BSR.W	pt_EditModeDispatcher
	BSR.W	pt_WaitMouseRelease
	SF	dat_ScopeBufferRef
	ST	dat_EditInputLock
	BSR.W	pt_0412
	BEQ.W	pt_0411
	BSR.W	pt_SaveEditState
	TST.L	dat_153D
	BNE.S	pt_040D
	BSR.W	pt_0422
pt_040D:
	JSR	pt_OpenHelpFile
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.L	D0,dat_FileHandle
	BNE.W	pt_EnterHelp
	LEA	str_HelpFilePath,A0
	BSR.W	pt_CopyFilename
	LEA	str_HelpFilePath,A0
	MOVEQ	#7,D0
pt_040E:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_040E
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_EnterHelp2
	BRA.W	pt_EnterHelp
pt_InitEditMode:
	MOVE.B	#$f8,dat_SongModifiedFlag3
	MOVE.L	#$ffffffff,dat_PrevTimeDays
	MOVE.L	#$ffffffff,dat_PrevTimeMins
	MOVE.L	#$ffffffff,dat_PrevTimeTicks
	CMPI.W	#$ffff,dat_VBLSyncWord
	MOVE.L	dat_FileHandle,D1
	BEQ.S	pt_0410
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
pt_0410:
	BSR.W	pt_WaitMouseRelease
	BSR.S	pt_SaveEditState
	BSR.S	pt_0412
pt_0411:
	BSR.W	pt_InitAudioDisplay
	BRA.W	pt_LeaveToMain
pt_0412:
	LEA	dat_HelpScreen41,A0
	BSR.W	pt_StoreModulePtr
	MOVEQ	#-1,D0
	RTS
pt_SaveEditState:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$0002,D0
	MOVEQ	#12,D1
	MOVE.W	#$027e,D2
	MOVEQ	#118,D3
	MOVEQ	#0,D5
	JSR	pt_SetupAudioDisplay
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_InputHelp:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1439,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BEQ.S	pt_0415
	CMP.W	#$0001,D2
	BEQ.W	pt_InitEditMode
	CMP.W	#$0002,D2
	BEQ.W	pt_ScreenStateHandler
	CMP.W	#$0003,D2
	BEQ.W	pt_041E
	CMP.W	#$0004,D2
	BEQ.W	pt_041C
	CMP.W	#$0005,D2
	BEQ.W	pt_041D
	CMP.W	#$0006,D2
	BEQ.W	pt_041F
pt_0415:
	RTS
	LEA	SECSTRT_2,A0
	MOVEQ	#1,D2
	MOVEQ	#0,D3
pt_r06afc:
	MOVE.W	#$04b9,D0
pt_r06b00:
	MOVE.L	(A0),D1
	MOVE.L	(A1),(A0)+
	MOVE.L	D1,(A1)+
	ADDQ.L	#4,D3
	CMP.L	#$00000028,D3
	BNE.S	pt_r06b16
	MOVEQ	#0,D3
	ADDA.W	#$0028,A0
pt_r06b16:
	DBF	D0,pt_r06b00
	LEA	(10720,A0),A0
	DBF	D2,pt_r06afc
	MOVEQ	#-1,D0
	RTS
pt_EnterHelp:
	MOVE.W	#$0002,dat_UIMode
	MOVE.W	dat_0485,D0
	AND.W	#$00ff,D0
	LSL.W	#2,D0
	LEA	dat_WorkBufEnd,A0
	MOVE.L	dat_FileHandle,D1
	BNE.S	pt_0417
	RTS
pt_0417:
	MOVE.L	(0,A0,D0.W),D2
	ADD.L	#$00000400,D2
	MOVEQ	#-1,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-66,A6)
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_153E,D2
	MOVE.L	#$00000520,D3
	JSR	(-42,A6)
	BSR.W	pt_SaveEditState
	LEA	dat_1543,A6
	JSR	pt_HelpPage41
pt_0418:
	MOVEQ	#0,D0
	MOVEA.L	A6,A1
pt_0419:
	CMPI.B	#$0a,(A1)+
	BEQ.S	pt_041A
	TST.B	(-1,A1)
	BEQ.S	pt_041A
	ADDQ.W	#1,D0
	BRA.S	pt_0419
pt_041A:
	MOVE.L	A6,dat_TextStringPtr
	MOVEA.L	A1,A6
	MOVE.W	D6,dat_TextBytePos
	MOVE.W	D0,dat_TextCharCount
	BEQ.S	pt_041B
	JSR	pt_DrawTextRender
pt_041B:
	ADD.W	#$01e0,D6
	DBF	D7,pt_0418
	BRA.W	pt_RefreshDisplay
pt_041C:
	LEA	dat_1540,A0
	BRA.S	pt_ResetKeyboardState
pt_041D:
	LEA	dat_1541,A0
	BRA.S	pt_ResetKeyboardState
pt_041E:
	LEA	dat_153F,A0
	BRA.S	pt_ResetKeyboardState
pt_041F:
	LEA	dat_1542,A0
pt_ResetKeyboardState:
	CLR.B	dat_KeyCode
	MOVEQ	#0,D0
	JSR	pt_BuildHexWord
	TST.W	D0
	BNE.S	pt_0421
	RTS
pt_0421:
	AND.W	#$00ff,D0
	MOVE.W	D0,dat_0485
	BSR.W	pt_EnterHelp
	BSR.W	pt_ClearKeyState
	BSR.W	pt_RefreshDisplay
	BRA.W	pt_RefreshDisplay
pt_0422:
	MOVE.L	dat_MagicNumber,D0
	CMP.L	dat_WorkBufEnd,D0
	BNE.S	pt_0423
	RTS
pt_0423:
	JSR	pt_OpenHelpFile
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVE.L	D0,dat_FileHandle
	BNE.S	pt_0425
	LEA	str_HelpFilePath,A0
	BSR.W	pt_CopyFilename
	LEA	str_HelpFilePath,A0
	MOVEQ	#7,D0
pt_0424:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0424
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.S	pt_EnterHelp2
pt_0425:
	MOVE.L	D0,D1
	MOVE.L	#dat_WorkBufEnd,D2
	MOVE.L	#$00000400,D3
	JSR	(-42,A6)
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	MOVE.L	dat_WorkBufEnd,dat_MagicNumber
	RTS
pt_EnterHelp2:
	MOVE.W	#$0002,dat_UIMode
	LEA	(dat_047E,PC),A0
	MOVE.W	#$0eb7,D1
	MOVEQ	#24,D0
	JMP	pt_ShowStatusMsg
pt_HandleF6Key:
	CMPI.B	#$55,dat_KeyCode
	BNE.S	pt_042D
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_042A
	MOVE.W	dat_PatternPosition,dat_SavedPatPos
pt_ShowDiskError:
	LEA	dat_12D3,A0
	JSR	pt_ShowStatusMsg
	MOVEQ	#8,D2
pt_0429:
	BSR.W	pt_RefreshDisplay
	DBF	D2,pt_0429
	JMP	pt_ClearStatusMsg
pt_042A:
	MOVE.W	dat_SavedPatPos,D0
dat_UIDispatchTab:
	TSTPC.W	dat_KeyQual2
	BNE.W	pt_0303
	TSTPC.W	dat_KeyQual3
	BNE.W	pt_030E
	TSTPC.W	dat_KeyQual4
	BNE.W	pt_02FC
	TST.W	dat_RpPlayMode
	BEQ.S	pt_042C
	RTS
pt_042C:
	MOVE.W	D0,dat_PatternPosition
	BRA.W	pt_PatViewSetRow
pt_042D:
	CMPI.B	#$56,dat_KeyCode
	BNE.S	pt_042F
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_042E
	MOVE.W	dat_PatternPosition,dat_ScreenModeTab1
	BRA.S	pt_ShowDiskError
pt_042E:
	MOVE.W	dat_ScreenModeTab1,D0
	BRA.S	dat_UIDispatchTab
pt_042F:
	CMPI.B	#$57,dat_KeyCode
	BNE.S	pt_0431
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_0430
	MOVE.W	dat_PatternPosition,dat_ScreenModeTab2
	BRA.W	pt_ShowDiskError
pt_0430:
	MOVE.W	dat_ScreenModeTab2,D0
	BRA.W	dat_UIDispatchTab
pt_0431:
	CMPI.B	#$58,dat_KeyCode
	BNE.S	pt_0433
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_0432
	MOVE.W	dat_PatternPosition,dat_ScreenModeTab3
	BRA.W	pt_ShowDiskError
pt_0432:
	MOVE.W	dat_ScreenModeTab3,D0
	BRA.W	dat_UIDispatchTab
pt_0433:
	CMPI.B	#$59,dat_KeyCode
	BEQ.S	pt_0434
	RTS
pt_0434:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_0435
	MOVE.W	dat_PatternPosition,dat_KeyDispatchTab
	BRA.W	pt_ShowDiskError
pt_0435:
	MOVE.W	dat_KeyDispatchTab,D0
	BRA.W	dat_UIDispatchTab
pt_HandleEditFKeys:
	MOVEQ	#0,D0
	MOVEA.L	D0,A0
	TSTPC.W	dat_KeyQual1
	BNE.W	pt_0441
	TSTPC.W	dat_KeyQual3
	BNE.W	pt_0441
	TSTPC.W	dat_KeyQual2
	BNE.W	pt_0443
	CMPI.B	#$44,dat_KeyCode
	BEQ.S	pt_043C
	CMPI.B	#$41,dat_KeyCode
	BEQ.S	pt_043E
	TST.W	dat_SamplerActive
	BNE.S	pt_0437
	RTS
pt_0437:
	CMPI.B	#$52,dat_KeyCode
	BEQ.S	pt_0438
	CMPI.B	#$53,dat_KeyCode
	BEQ.S	pt_0439
	CMPI.B	#$54,dat_KeyCode
	BEQ.S	pt_043A
	RTS
pt_0438:
	JMP	pt_BtnSmpCut
pt_0439:
	JMP	pt_BtnSmpCopy
pt_043A:
	JMP	pt_BtnSmpPaste
pt_043B:
	BRA.W	pt_BtnDiskFileList
pt_043C:
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_043B
	MOVE.W	#$0001,dat_StopRequest
	JSR	pt_StopPlayback
	MOVE.W	dat_PatternPosition,D0
	BSR.W	pt_SetPatternPosition
pt_043D:
	BSR.W	pt_RefreshDisplay
	TST.W	dat_StopRequest
	BNE.S	pt_043D
	BSR.W	pt_ClearKeyState
	BRA.W	pt_PatViewSetRow
pt_043E:
	MOVE.W	#$0001,dat_StopRequest
	JSR	pt_StopPlayback
	MOVE.W	dat_PatternPosition,D0
	BSR.W	pt_SetPatternPosition
pt_043F:
	BSR.W	pt_RefreshDisplay
	TST.W	dat_StopRequest
	BNE.S	pt_043F
	MOVE.W	dat_PatternPosition,D0
	SUBQ.W	#2,D0
	AND.W	#$003f,D0
	MOVE.W	D0,dat_PatternPosition
	BSR.W	pt_ClearKeyState
	BRA.W	pt_PatViewSetRow
dat_StopRequest:
	DS.W	1
pt_0441:
	MOVEQ	#0,D0
	MOVE.W	dat_CursorColumn,D0
	DIVU	#$0006,D0
	AND.L	#$00000007,D0
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_0442
	AND.L	#$00000003,D0
pt_0442:
	LSL.L	#2,D0
	MOVEA.L	D0,A0
pt_0443:
	ADDA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0444
	LSL.L	#1,D0
pt_0444:
	ADDA.L	D0,A0
	TSTPC.W	dat_KeyQual2
	BNE.S	pt_0445
	TSTPC.W	dat_KeyQual3
	BNE.S	pt_0446
	CMPI.B	#$52,dat_KeyCode
	BEQ.W	pt_044D
	CMPI.B	#$53,dat_KeyCode
	BEQ.W	pt_SamplePlayInit
	CMPI.B	#$54,dat_KeyCode
	BEQ.W	pt_ConvertKeyNote
	CMPI.B	#$44,dat_KeyCode
	BEQ.W	pt_0457
	CMPI.B	#$41,dat_KeyCode
	BEQ.W	pt_0463
	RTS
pt_0445:
	CMPI.B	#$52,dat_KeyCode
	BEQ.S	pt_0447
	CMPI.B	#$53,dat_KeyCode
	BEQ.S	pt_ReqErrorDisplay
	CMPI.B	#$54,dat_KeyCode
	BEQ.W	pt_ConvertKeyWithRedraw
	CMPI.B	#$44,dat_KeyCode
	BEQ.W	pt_0456
	CMPI.B	#$41,dat_KeyCode
	BEQ.W	pt_0462
	RTS
pt_0446:
	CMPI.B	#$52,dat_KeyCode
	BEQ.W	pt_046D
	CMPI.B	#$53,dat_KeyCode
	BEQ.W	pt_0470
	CMPI.B	#$54,dat_KeyCode
	BEQ.W	pt_0473
	RTS
pt_0447:
	BSR.W	pt_ConvertKeyToNote
	LEA	dat_PatternDataBuf5,A1
	MOVE.W	#$00ff,D0
	MOVEQ	#0,D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0448
	MOVE.W	#$01ff,D0
pt_0448:
	MOVE.L	(A0),(A1)+
	MOVE.L	D1,(A0)+
	DBF	D0,pt_0448
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_ReqErrorDisplay:
	LEA	dat_PatternDataBuf5,A1
	MOVE.W	#$00ff,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_044A
	MOVE.W	#$01ff,D0
pt_044A:
	MOVE.L	(A0)+,(A1)+
	DBF	D0,pt_044A
	RTS
pt_ConvertKeyWithRedraw:
	BSR.W	pt_ConvertKeyToNote
	LEA	dat_PatternDataBuf5,A1
	MOVE.W	#$00ff,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_044C
	MOVE.W	#$01ff,D0
pt_044C:
	MOVE.L	(A1)+,(A0)+
	DBF	D0,pt_044C
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_044D:
	BSR.W	pt_ConvertKeyToNote
	LEA	dat_DisplayBufPool,A1
	MOVEQ	#63,D0
	MOVEQ	#0,D1
pt_044E:
	MOVE.L	(A0),(A1)+
	MOVE.L	D1,(A0)
	LEA	(16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_044F
	LEA	(16,A0),A0
pt_044F:
	DBF	D0,pt_044E
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_SamplePlayInit:
	LEA	dat_DisplayBufPool,A1
	MOVEQ	#63,D0
pt_0451:
	MOVE.L	(A0),(A1)+
	LEA	(16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0452
	LEA	(16,A0),A0
pt_0452:
	DBF	D0,pt_0451
	RTS
pt_ConvertKeyNote:
	BSR.W	pt_ConvertKeyToNote
	LEA	dat_DisplayBufPool,A1
	MOVEQ	#63,D0
pt_0454:
	MOVE.L	(A1)+,(A0)
	LEA	(16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0455
	LEA	(16,A0),A0
pt_0455:
	DBF	D0,pt_0454
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_0456:
	BSR.W	pt_ConvertKeyToNote
	MOVEQ	#0,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	MOVEQ	#6,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	MOVEQ	#12,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	MOVEQ	#18,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatternInputProcess
	MOVEQ	#24,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	MOVEQ	#30,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	MOVEQ	#36,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	MOVEQ	#42,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_MovePatternRow
	BRA.S	pt_PatternInputProcess
pt_0457:
	BSR.W	pt_ConvertKeyToNote
	BSR.S	pt_MovePatternRow
pt_PatternInputProcess:
	CLR.B	dat_KeyCode
	ADD.W	D2,dat_PatternPosition
	ANDI.W	#$003f,dat_PatternPosition
	BSR.W	pt_PatViewSetRow
	JMP	pt_PatViewDrawAll
pt_MovePatternRow:
	MOVE.W	dat_PatternPosition,D1
	LSL.W	#4,D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_045A
	CMP.W	#$07e0,D1
	BEQ.S	pt_045C
	MOVE.W	#$07c0,D0
	BRA.S	pt_045B
pt_045A:
	CMP.W	#$03f0,D1
	BEQ.S	pt_045C
	MOVE.W	#$03e0,D0
pt_045B:
	MOVE.L	(0,A0,D0.W),(16,A0,D0.W)
	SUB.W	#$0010,D0
	CMP.W	D1,D0
	BGE.S	pt_045B
pt_045C:
	MOVEQ	#1,D2
	CLR.L	(0,A0,D1.W)
	RTS
pt_045D:
	CLR.B	dat_KeyCode
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_045E
	BRA.S	pt_PatternInputProcess
pt_045E:
	MOVE.W	dat_PatternPosition,D1
	LSL.W	#4,D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_045F
	CMP.W	#$07e0,D1
	BEQ.S	pt_0461
	MOVE.W	#$07c0,D0
	BRA.S	pt_0460
pt_045F:
	CMP.W	#$03f0,D1
	BEQ.S	pt_0461
	MOVE.W	#$03e0,D0
pt_0460:
	MOVE.W	(2,A0,D0.W),D2
	AND.W	#$0fff,D2
	ANDI.W	#$f000,(18,A0,D0.W)
	OR.W	D2,(18,A0,D0.W)
	SUB.W	#$0010,D0
	CMP.W	D1,D0
	BGE.S	pt_0460
pt_0461:
	MOVEQ	#1,D2
	ANDI.W	#$f000,(2,A0,D1.W)
	RTS
pt_0462:
	BSR.W	pt_ConvertKeyToNote
	MOVEQ	#0,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	MOVEQ	#6,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	MOVEQ	#12,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	MOVEQ	#18,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	BTST	#5,dat_ModeFlags
	BNE.W	pt_PatternInputProcess
	MOVEQ	#24,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	MOVEQ	#30,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	MOVEQ	#36,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	MOVEQ	#42,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_DeletePatternRow
	BRA.W	pt_PatternInputProcess
pt_0463:
	BSR.W	pt_ConvertKeyToNote
	BSR.S	pt_DeletePatternRow
	BRA.W	pt_PatternInputProcess
