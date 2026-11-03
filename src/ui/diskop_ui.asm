pt_InputDiskOpChecks:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_142F,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_01B5
	RTS
pt_01B5:
	CMP.W	#$0001,D2
	BEQ.W	pt_01DE
	CMP.W	#$000a,D2
	BEQ.S	pt_01B6
	CMP.W	#$000b,D2
	BEQ.S	pt_01B7
	CMP.W	#$000c,D2
	BEQ.S	pt_01B8
	CMP.W	#$000d,D2
	BEQ.S	pt_01B9
	CMP.W	#$000e,D2
	BEQ.S	pt_01BA
	CMP.W	#$000f,D2
	BEQ.S	pt_01BB
	RTS
pt_01B6:
	MOVEQ	#1,D0
	LEA	(pt_SampleEditorMode0,PC),A0
	BRA.S	pt_SampEdModeDispatch
pt_01B7:
	MOVEQ	#2,D0
	LEA	(pt_SampleEditorEntry,PC),A0
	BRA.S	pt_SampEdModeDispatch
pt_01B8:
	MOVEQ	#3,D0
	LEA	(pt_SampleEditorMode2,PC),A0
	BRA.S	pt_SampEdModeDispatch
pt_01B9:
	MOVEQ	#4,D0
	LEA	(pt_SampleEditorMode3,PC),A0
	BRA.S	pt_SampEdModeDispatch
pt_01BA:
	MOVEQ	#5,D0
	LEA	(pt_SampleEditorSetup,PC),A0
	BRA.S	pt_SampEdModeDispatch
pt_01BB:
	MOVEQ	#6,D0
	LEA	(pt_SampleEditorMode5,PC),A0
pt_SampEdModeDispatch:
	SUBQ.W	#1,D0
	CMP.W	#$0005,D0
	BLS.S	pt_01BD
	RTS
pt_01BD:
	MULU	#$0020,D0
	LEA	dat_DisplayWorkBuf3,A1
	LEA	dat_PatternLineBuf2,A2
	LEA	(0,A1,D0.L),A1
	LEA	(0,A2,D0.L),A2
	MOVEQ	#81,D0
pt_01BE:
	MOVE.B	(A2)+,(A1)+
	DBF	D0,pt_01BE
	JSR	(A0)
	BTST	#3,dat_UIStateFlag
	BNE.W	pt_01AF
	RTS
pt_BtnDiskRenameFile:
	MOVE.W	dat_SampleEditorX,dat_SampleEditorY
	MOVE.W	#$000a,dat_SampleEditorX
	LEA	dat_12D0,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_BtnDiskMakeDir:
	LEA	(dat_01C4,PC),A0
	LEA	(str_ModulesPath,PC),A1
	MOVEQ	#32,D0
	LEA	chip_CopperSpriteBuf,A2
	JSR	pt_SetupDisplayMode
	BEQ.S	pt_01C1
	RTS
pt_01C1:
	LEA	(dat_01C5,PC),A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	(str_ModulesPath,PC),A0
	MOVEQ	#23,D0
pt_01C2:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_01C2
	MOVE.L	#dat_FileNameBuf,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-120,A6)
	BSR.W	pt_RestorePalette
	JSR	pt_ClearStatusMsg
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_01C3
	RTS
pt_01C3:
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
dat_01C4:
	DC.B	10,10
	DC.B	"   MAKE DIRECTORY:",0
dat_01C5:
	DC.B	"CREATING DIRECTORY...",0,0
str_ModulesPath:
	DC.L	$6d6f6475,$6c657300
	DS.L	6
	DS.W	1
pt_BtnDiskDeleteFile:
	MOVE.W	dat_SampleEditorX,dat_SampleEditorY
	MOVE.W	#$0009,dat_SampleEditorX
	LEA	dat_12D1,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_034F
pt_BtnDiskPacking:
	BCHG	#1,dat_UIStateFlag
pt_01C9:
	LEA	(dat_DisplayOffText,PC),A0
	BTST	#1,dat_UIStateFlag
	BEQ.S	pt_01CA
	LEA	(dat_062D,PC),A0
pt_01CA:
	MOVEQ	#3,D0
	MOVE.W	#$0469,D1
	JSR	pt_DrawTextAt
	BRA.W	pt_WaitMouseRelease
pt_BtnDiskSampForm:
	EORI.B	#$01,dat_CopperListFlag
pt_01CC:
	LEA	(dat_01CE,PC),A0
	TST.B	dat_CopperListFlag
	BEQ.S	pt_01CD
	LEA	(dat_01CF,PC),A0
pt_01CD:
	MOVEQ	#3,D0
	MOVE.W	#$07d9,D1
	JSR	pt_DrawTextAt
	BRA.W	pt_WaitMouseRelease
dat_01CE:
	DC.L	$52415700
dat_01CF:
	DC.L	$49464600
pt_BtnDiskMainMenu:
	CLR.W	dat_ButtonScanIdx
	MOVE.W	#$0053,dat_ButtonScanMax
	MOVE.B	#$f8,dat_SongModifiedFlag3
	MOVE.L	#$ffffffff,dat_PrevTimeDays
	MOVE.L	#$ffffffff,dat_PrevTimeMins
	MOVE.L	#$ffffffff,dat_PrevTimeTicks
	CMPI.W	#$ffff,dat_VBLSyncWord
	BEQ.S	pt_01D1
	MOVEM.L	D0-D3/A0,-(A7)
	BSR.W	pt_CalcVBLTick
	MOVEM.L	(A7)+,D0-D3/A0
	MOVE.W	#$ffff,dat_VBLSyncWord
	MOVE.W	#$ffff,dat_DiskOpFlag
pt_01D1:
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_CallStoreModule
	BSR.W	pt_InitAudioDisplay
pt_LeaveToMain:
	MOVE.W	#$0001,dat_UIMode
	BSR.W	pt_InitEditState
	JSR	pt_DrawPanelByMode
	JSR	pt_DrawSampleHex
	JSR	pt_DrawSampleTableInfo
	JSR	pt_LoadSpaceCharCode
	TST.W	dat_RecordMode
	BNE.S	pt_ProcessEditExit
	BSR.W	pt_DrawStatusBar
	BNE.S	pt_ProcessEditExit
	JSR	pt_ClearStatusMsg
pt_ProcessEditExit:
	JMP	pt_DrawPosPatNumbers
	JMP	pt_EnterPlst
	JMP	pt_EnterComment
	JMP	pt_EnterPosEdit
	BRA.W	pt_01AD
pt_01D4:
	JSR	pt_120D
	BSR.W	pt_01E9
	BEQ.S	pt_CheckTextEditLen
	RTS
pt_CheckTextEditLen:
	TST.W	dat_TextEditLength
	BNE.S	pt_01D6
	RTS
pt_01D6:
	MOVE.B	dat_FillChar,D0
	MOVE.B	D0,dat_DrawOffsetVar
	MOVE.B	#$20,dat_FillChar
	MOVE.L	(dat_TextEditBufPtr,PC),D0
	BNE.S	pt_01D7
	MOVE.B	(dat_DrawOffsetVar,PC),D0
	MOVE.B	D0,dat_FillChar
	RTS
pt_01D7:
	MOVEA.L	D0,A0
	MOVE.W	(dat_TextEditCurPos,PC),D0
	MULU	#$0020,D0
	ADDA.L	D0,A0
	MOVE.W	#$00ca,D0
	MOVE.W	#$000e,D1
	MOVEQ	#8,D3
	MOVE.W	(dat_TextEditLength,PC),D7
	SUB.W	(dat_TextEditCurPos,PC),D7
	CMP.W	#$0010,D7
	BMI.S	pt_01D8
	MOVEQ	#16,D7
pt_01D8:
	SUBQ.W	#1,D7
	BMI.S	pt_SetFillChar
pt_FindCharLoop:
	TST.L	(A0)
	BNE.S	pt_01DA
	MOVE.B	(dat_DrawOffsetVar,PC),D0
	MOVE.B	D0,dat_FillChar
	RTS
pt_01DA:
	JSR	pt_BlitPatternRow
	LEA	(32,A0),A0
	CMP.W	#$00ca,D0
	BNE.S	pt_01DB
	MOVE.W	#$0106,D0
	DBF	D7,pt_FindCharLoop
	BRA.S	pt_SetFillChar
pt_01DB:
	MOVE.W	#$00ca,D0
	ADD.W	#$000b,D1
	DBF	D7,pt_FindCharLoop
pt_SetFillChar:
	MOVE.B	(dat_DrawOffsetVar,PC),D0
	MOVE.B	D0,dat_FillChar
	RTS
dat_DrawOffsetVar:
	DS.W	1
pt_01DE:
	BSR.W	pt_WaitMouseRelease
	CMPI.W	#$0010,dat_TextEditLength
	BPL.S	pt_01DF
	RTS
pt_01DF:
	MOVE.W	(dat_TextEditCurPos,PC),D0
	ADD.W	#$0010,D0
	CMP.W	(dat_TextEditLength,PC),D0
	BLT.S	pt_01E0
	MOVEQ	#0,D0
pt_01E0:
	MOVE.W	D0,dat_TextEditCurPos
	BSR.S	pt_01E1
	BRA.W	pt_CheckTextEditLen
pt_01E1:
	MOVEQ	#15,D7
	MOVE.W	#$00ca,D0
	MOVE.W	#$000e,D1
	MOVEQ	#8,D3
pt_BlitPatternEntry:
	LEA	(dat_01E5,PC),A0
	JSR	pt_BlitPatternRow
	CMP.W	#$00ca,D0
	BNE.S	pt_01E3
	MOVE.W	#$0106,D0
	DBF	D7,pt_BlitPatternEntry
	BRA.S	pt_01E4
pt_01E3:
	MOVE.W	#$00ca,D0
	ADD.W	#$000b,D1
	DBF	D7,pt_BlitPatternEntry
pt_01E4:
	RTS
dat_01E5:
	DC.B	"                    ",0,0
pt_01E6:
	SUB.W	#$0064,D2
	ADD.W	(dat_TextEditCurPos,PC),D2
	CMP.W	(dat_TextEditLength,PC),D2
	BLT.S	pt_01E7
	RTS
pt_01E7:
	MULU	#$0020,D2
	MOVEA.L	(dat_TextEditBufPtr,PC),A1
	LEA	(0,A1,D2.L),A1
	MOVE.W	dat_TextInputIdx,D0
	SUBQ.W	#1,D0
	MULU	#$0052,D0
	LEA	dat_DisplayWorkBuf3,A0
	LEA	(0,A0,D0.L),A0
	MOVEQ	#81,D1
pt_01E8:
	MOVE.B	(A1)+,(A0)+
	DBF	D1,pt_01E8
	BSR.W	pt_DrawSampleEdText
	BRA.W	pt_SampleEdMainLoop
pt_01E9:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_DosListLock
	NOP
	MOVEA.L	dat_DosLibBase,A1
	MOVEA.L	(34,A1),A1
	MOVEA.L	(24,A1),A1
	MOVE.L	A1,D0
	LSL.L	#2,D0
	MOVEA.L	D0,A1
	MOVE.L	(4,A1),D0
	LSL.L	#2,D0
	MOVEA.L	D0,A1
	MOVE.L	A1,dat_NodeListPtr
	BSR.W	pt_01EE
	ADDQ.W	#6,D0
	MOVE.W	D0,dat_TextEditLength
	MULU	#$0052,D0
	CMP.L	(dat_TextEditBufSize,PC),D0
	BEQ.S	pt_01EA
	MOVE.L	D0,-(A7)
	BSR.W	pt_FreeEditBuf
	MOVE.L	(A7)+,D0
	CLR.W	dat_TextEditCurPos
	MOVE.L	D0,dat_TextEditBufSize
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_TextEditBufPtr
	BEQ.S	pt_01ED
pt_01EA:
	MOVEA.L	(dat_TextEditBufPtr,PC),A0
	MOVE.L	(dat_TextEditBufSize,PC),D0
	SUBQ.L	#1,D0
	BMI.S	pt_01EC
pt_01EB:
	CLR.B	(A0)+
	SUBQ.L	#1,D0
	BPL.S	pt_01EB
pt_01EC:
	CLR.L	dat_ScreenBufPtrs
	CLR.L	dat_NodeTraversePtr
	BSR.S	pt_TraverseNodeList
	MOVE.L	#$00000002,dat_NodeTraversePtr
	BSR.S	pt_TraverseNodeList
	MOVE.L	#$00000001,dat_NodeTraversePtr
	BSR.S	pt_TraverseNodeList
	BSR.W	pt_01F7
	JSR	pt_DosListUnlock
	NOP
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D0
	RTS
pt_01ED:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	CLR.W	dat_TextEditLength
	CLR.W	dat_TextEditCurPos
	JSR	pt_DosListUnlock
	NOP
	JSR	pt_SetupPaletteMode
	MOVEQ	#0,D0
	RTS
pt_01EE:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEA.L	(dat_NodeListPtr,PC),A1
	MOVEQ	#0,D0
pt_LoadTableLoop:
	MOVE.L	(A1),D1
	BEQ.S	pt_01F0
	LSL.L	#2,D1
	MOVEA.L	D1,A1
	TST.L	(8,A1)
	BEQ.S	pt_LoadTableLoop
	ADDQ.L	#1,D0
	BRA.S	pt_LoadTableLoop
pt_01F0:
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
pt_TraverseNodeList:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_NodeListPtr,PC),A1
pt_TraverseNodeNext:
	MOVE.L	(A1),D0
	BEQ.S	pt_01F3
	LSL.L	#2,D0
	MOVEA.L	D0,A1
	TST.L	(8,A1)
	BEQ.S	pt_TraverseNodeNext
	MOVE.L	(dat_NodeTraversePtr,PC),D0
	CMP.L	(4,A1),D0
	BEQ.S	pt_01F4
	BRA.S	pt_TraverseNodeNext
pt_01F3:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_01F4:
	MOVE.L	(40,A1),D0
	LSL.L	#2,D0
	MOVEA.L	D0,A2
	MOVEQ	#0,D5
	MOVEA.L	(dat_TextEditBufPtr,PC),A3
	MOVE.L	(dat_ScreenBufPtrs,PC),D5
	LEA	(0,A3,D5.L),A3
	MOVEQ	#30,D7
	LEA	(1,A2),A2
pt_01F5:
	TST.B	(A2)
	BEQ.S	pt_01F6
	MOVE.B	(A2)+,(A3)+
	DBF	D7,pt_01F5
pt_01F6:
	MOVE.B	#$3a,(A3)
	ADDI.L	#$00000020,dat_ScreenBufPtrs
	BRA.S	pt_TraverseNodeNext
pt_01F7:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_PatternLineBuf2,A2
	MOVEA.L	(dat_TextEditBufPtr,PC),A3
	MOVE.L	(dat_ScreenBufPtrs,PC),D5
	LEA	(0,A3,D5.L),A3
	MOVE.W	#$00bf,D7
pt_01F8:
	MOVE.B	(A2)+,(A3)+
	DBF	D7,pt_01F8
	ADDI.L	#$000000c0,dat_ScreenBufPtrs
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_ScreenBufPtrs:
	DS.L	1
dat_NodeTraversePtr:
	DS.L	1
dat_NodeListPtr:
	DS.L	1
pt_01FC:
	BSR.S	pt_FreeEditBuf
	CLR.W	dat_TextEditLength
	CLR.W	dat_TextEditCurPos
	CLR.L	dat_TextEditBufSize
	RTS
pt_FreeEditBuf:
	MOVE.L	(dat_TextEditBufPtr,PC),D1
	BEQ.S	pt_01FE
	MOVEA.L	D1,A1
	MOVE.L	(dat_TextEditBufSize,PC),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_TextEditBufPtr
pt_01FE:
	RTS
dat_TextEditBufPtr:
	DS.L	1
dat_TextEditBufSize:
	DS.L	1
dat_TextEditCurPos:
	DS.W	1
dat_TextEditLength:
	DS.W	1
pt_BtnDiskFileType:
	MOVE.W	(dat_TextInputIdx,PC),D0
	CMP.W	#$0006,D0
	BLT.S	pt_0204
	MOVEQ	#0,D0
pt_0204:
	LSL.W	#2,D0
	MOVEA.L	(dat_0206,PC,D0.W),A0
	JSR	(A0)
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_0205
	RTS
pt_0205:
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
dat_0206:
	DC.L	pt_SampleEditorMode0
	DC.L	pt_SampleEditorEntry
	DC.L	pt_SampleEditorMode2
	DC.L	pt_SampleEditorMode3
	DC.L	pt_SampleEditorSetup
	DC.L	pt_SampleEditorMode5
pt_BtnDiskResetPaths:
	LEA	(dat_020D,PC),A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0208
	RTS
pt_0208:
	MOVE.L	dat_FileIOVar3,D0
	BEQ.S	pt_020C
	ADD.L	#$0000000e,D0
	MOVEA.L	D0,A0
	LEA	dat_DisplayWorkBuf3,A1
	LEA	dat_PatternLineBuf2,A2
	MOVEQ	#5,D0
pt_0209:
	MOVEQ	#81,D1
pt_020A:
	MOVE.B	(A0),(A1)+
	MOVE.B	(A0)+,(A2)+
	DBF	D1,pt_020A
	LEA	(76,A0),A0
	DBF	D0,pt_0209
	LEA	dat_PatternDataBuf3,A1
	MOVE.W	#$00bf,D0
pt_020B:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_020B
	BSR.W	pt_TextInputMainLoop
pt_020C:
	BRA.W	pt_DrawSampleEdText
dat_020D:
	DC.B	10,10
	DC.B	"   Are you sure you want",10
	DC.B	"    to reset all paths?",0,0
pt_SampleEditorMode0:
	MOVE.W	#$0002,dat_SampleEditorX
	MOVEQ	#1,D0
	LEA	dat_12CB,A0
	LEA	(dat_ButtonHitbox0,PC),A1
	BRA.S	pt_ShowStatusMsgUI
pt_SampleEditorEntry:
	MOVE.W	#$0003,dat_SampleEditorX
	MOVEQ	#2,D0
	LEA	dat_12CC,A0
	LEA	(dat_ButtonHitbox1,PC),A1
	BRA.S	pt_ShowStatusMsgUI
pt_SampleEditorMode2:
	MOVE.W	#$0001,dat_SampleEditorX
	MOVEQ	#3,D0
	LEA	dat_12CA,A0
	LEA	(dat_ButtonHitbox2,PC),A1
	BRA.S	pt_ShowStatusMsgUI
pt_SampleEditorMode3:
	MOVE.W	#$0004,dat_SampleEditorX
	MOVEQ	#4,D0
	LEA	dat_12CF,A0
	LEA	(dat_ButtonHitbox3,PC),A1
	BRA.S	pt_ShowStatusMsgUI
pt_SampleEditorSetup:
	MOVE.W	#$0005,dat_SampleEditorX
	MOVEQ	#5,D0
	LEA	dat_12CD,A0
	LEA	(dat_ButtonHitbox4,PC),A1
	BRA.S	pt_ShowStatusMsgUI
pt_SampleEditorMode5:
	MOVE.W	#$0006,dat_SampleEditorX
	MOVEQ	#6,D0
	LEA	dat_12CE,A0
	LEA	(dat_ButtonHitbox5,PC),A1
pt_ShowStatusMsgUI:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BTST	#2,dat_UIBitFlags
	BNE.S	pt_0215
	LEA	(dat_ButtonHitbox1,PC),A1
pt_0215:
	MOVE.L	A1,dat_ButtonHitboxes
	BSR.W	pt_021E
	MOVE.W	D0,dat_TextInputIdx
	SUBQ.W	#1,D0
	MULU	#$0052,D0
	LEA	dat_DisplayWorkBuf3,A3
	LEA	(0,A3,D0.L),A3
	MOVE.L	A3,dat_SampleEditorPtr
	LEA	(dat_SampleEdBufPtr,PC),A0
	MOVE.B	#$60,dat_SampleEdBufPtr
	MOVE.W	(dat_TextInputIdx,PC),D1
	MULU	#$000b,D1
	ADD.W	#$0018,D1
	MOVEQ	#101,D0
	MOVEQ	#1,D3
	JSR	pt_BlitPatternRow
	MOVE.W	(dat_TextInputIdx,PC),D0
	SUBQ.W	#1,D0
	MULU	#$000a,D0
	LEA	(dat_0219,PC,D0.L),A0
	MOVE.W	#$00ea,D0
	MOVEQ	#113,D1
	MOVEQ	#10,D3
	JSR	pt_BlitPatternRow
	BSR.W	pt_ShowFileSelector
	BSR.W	pt_TextInputMainLoop
	BSR.W	pt_DrawSampleEdText
	BSR.W	pt_SetPaletteBright
	BTST	#2,dat_UIBitFlags
	BEQ.S	pt_0217
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	CMPI.W	#$0013,(22,A5)
	BPL.S	pt_0216
	BSR.W	pt_AudioBufferInit
pt_0216:
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	BSR.W	pt_ProcessHitbox
pt_0217:
	BRA.W	pt_WaitMouseRelease
dat_0218:
	DC.B	"OLD IFF ",0
dat_0219:
	DC.B	"Executable  Module     Song      Track    Sample    Pattern ",0
dat_TextInputIdx:
	DC.W	$0002
dat_SampleEdBufPtr:
	DS.L	1
pt_BtnDiskModForm:
	ADDQ.B	#1,dat_SampleNameBuf
	CMPI.B	#$02,dat_SampleNameBuf
	BMI.S	pt_SampleNameRotate
	CLR.B	dat_SampleNameBuf
pt_SampleNameRotate:
	LEA	(dat_0218,PC),A0
	MOVEQ	#0,D0
	MOVE.B	dat_SampleNameBuf,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	#$0049,D0
	MOVE.W	#$0024,D1
	MOVEQ	#4,D3
	JSR	pt_BlitPatternFull
	RTS
pt_021E:
	MOVEM.L	D0-D3/A0,-(A7)
	LEA	(dat_SampleEdBufPtr,PC),A0
	MOVE.B	#$20,dat_SampleEdBufPtr
	MOVE.W	(dat_TextInputIdx,PC),D1
	MULU	#$000b,D1
	ADD.W	#$0018,D1
	MOVE.W	#$0065,D0
	MOVEQ	#1,D3
	JSR	pt_BlitPatternRow
	MOVEM.L	(A7)+,D0-D3/A0
	RTS
pt_BtnDiskReadDir:
	MOVE.W	(dat_TextInputIdx,PC),D0
	CMP.W	#$0001,D0
	BEQ.W	pt_SampleEdMode0Alt
	CMP.W	#$0002,D0
	BEQ.W	pt_EnterSampleEditMode
	CMP.W	#$0003,D0
	BEQ.S	pt_SampleEdMode2
	CMP.W	#$0004,D0
	BEQ.S	pt_SampleEdMode3
	CMP.W	#$0005,D0
	BEQ.W	pt_SampleEdMode6
	CMP.W	#$0006,D0
	BEQ.W	pt_SampleEdMode5
	RTS
pt_SampleEdMode2:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SampleEditorMode2
	BSR.W	pt_AudioBufferInit
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	BSR.W	pt_ClearButtonHitbox
	BSR.W	pt_FileBrowserRefresh
	BNE.W	pt_RestorePalette
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	#$0001,dat_SampleEditorX
	LEA	dat_12CA,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_SampleEdMode3:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SampleEditorMode3
	BSR.W	pt_AudioBufferInit
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	BSR.W	pt_ClearButtonHitbox
	BSR.W	pt_FileBrowserRefresh
	BNE.W	pt_RestorePalette
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	#$0004,dat_SampleEditorX
	LEA	dat_12CF,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_BtnDiskSaveTrack:
	BSR.W	pt_SampleEditorMode3
	LEA	dat_12D8,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0223
	RTS
pt_0223:
	JSR	pt_CursorColCalc
	BSR.W	pt_SamplePlayInit
	JSR	pt_0224
	MOVE.W	#$0004,dat_SampleEditorX
	JSR	pt_ClearStatusMsg
	BTST	#3,dat_UIStateFlag
	BNE.W	pt_RedrawSampleEd
	RTS
pt_0224:
	BSR.W	pt_SavePaletteState
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.L	A1,-(A7)
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#19,D0
pt_0225:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0225
	MOVEA.L	(A7),A1
	SUBQ.L	#1,A1
pt_0226:
	ADDQ.L	#1,A1
	TST.B	(A1)
	BNE.S	pt_0226
	MOVE.B	#$2e,(A1)+
	MOVE.B	#$54,(A1)+
	MOVE.B	#$52,(A1)+
	MOVE.B	#$4b,(A1)+
	CLR.B	(A1)+
	MOVEA.L	(A7)+,A1
	MOVE.L	#dat_DisplayBufPool,dat_FileWriteAddr
	BSR.W	pt_SetPaletteDim
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	MOVE.L	dat_ScreenBufPtr,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BNE.S	pt_0227
	BRA.W	pt_RestorePaletteInit
pt_0227:
	LEA	dat_12C2,A0
	JSR	pt_ShowStatusMsg
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_0228,D2
	MOVEQ	#16,D3
	JSR	(-48,A6)
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileWriteAddr,D2
	MOVE.L	#$00000100,D3
	JSR	(-48,A6)
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
	MOVE.W	#$0004,dat_SampleEditorX
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	BTST	#3,dat_UIStateFlag
	BNE.W	pt_RedrawExit
	RTS
dat_0228:
	DC.L	$464f524d,$00000100,$50544346,$5452434b
pt_SampleEdMode0Alt:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SampleEditorMode0
	BSR.W	pt_AudioBufferInit
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	BSR.W	pt_ClearButtonHitbox
	BSR.W	pt_FileBrowserRefresh
	BNE.W	pt_RestorePalette
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	#$0002,dat_SampleEditorX
	LEA	dat_12CB,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_BtnDiskSaveExe:
	BTST	#5,dat_ModeFlags
	NOP
	BSR.W	pt_SampleEditorMode0
	LEA	dat_12D9,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_022B
	RTS
pt_022B:
	JSR	pt_0EB9
	MOVE.W	#$0002,dat_SampleEditorX
	JSR	pt_ClearStatusMsg
	BTST	#3,dat_UIStateFlag
	BNE.W	pt_RedrawSampleEd
	RTS
pt_022C:
	LEA	dat_12E3,A0
	BSR.W	pt_ShowYesNoDialog
	RTS
pt_SampleEdMode5:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SampleEditorMode5
	BSR.W	pt_AudioBufferInit
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	BSR.W	pt_ClearButtonHitbox
	BSR.W	pt_FileBrowserRefresh
	BNE.W	pt_RestorePalette
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	#$0006,dat_SampleEditorX
	LEA	dat_12CE,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_BtnDiskSavePatt:
	BSR.W	pt_SampleEditorMode5
	LEA	dat_12D7,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_022F
	RTS
pt_022F:
	JSR	pt_CursorColCalc
	BSR.W	pt_ReqErrorDisplay
	BSR.W	pt_SavePaletteState
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.L	A1,-(A7)
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#19,D0
pt_0230:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0230
	MOVEA.L	(A7),A1
	SUBQ.L	#1,A1
pt_0231:
	ADDQ.L	#1,A1
	TST.B	(A1)
	BNE.S	pt_0231
	MOVE.B	#$2e,(A1)+
	MOVE.B	#$50,(A1)+
	MOVE.B	#$41,(A1)+
	MOVE.B	#$54,(A1)+
	CLR.B	(A1)+
	MOVEA.L	(A7)+,A1
	MOVE.L	dat_PatternDataBuf5,dat_FileWriteAddr
	BSR.W	pt_SetPaletteDim
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	MOVE.L	dat_ScreenBufPtr,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BNE.S	pt_0232
	BRA.W	pt_RestorePaletteInit
pt_0232:
	LEA	dat_12C1,A0
	JSR	pt_ShowStatusMsg
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_0235,D2
	MOVEQ	#16,D3
	JSR	(-48,A6)
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_PatternDataBuf5,D2
	MOVE.L	#$00000400,D3
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0233
	MOVE.L	#$00000800,D3
pt_0233:
	JSR	(-48,A6)
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
	MOVE.W	#$0006,dat_SampleEditorX
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_RedrawExit
	RTS
pt_RedrawExit:
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
dat_0235:
	DC.L	$464f524d,$00000400,$50544346,$50415454
	DS.W	1
pt_BtnDiskSaveSong:
	BSR.W	pt_SampleEditorMode2
	LEA	dat_12D6,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0237
	RTS
pt_0237:
	BSR.W	pt_RestorePalette
	JSR	pt_0DB9
	MOVE.W	#$0001,dat_SampleEditorX
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_0238
	RTS
pt_0238:
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
pt_EnterSampleEditMode:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SampleEditorEntry
	BSR.W	pt_AudioBufferInit
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	BSR.W	pt_ClearButtonHitbox
	BSR.W	pt_FileBrowserRefresh
	BNE.W	pt_RestorePalette
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	#$0003,dat_SampleEditorX
	LEA	dat_12CC,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_BtnDiskSaveModule:
	BSR.W	pt_SampleEditorEntry
	LEA	dat_12DB,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_023B
	RTS
pt_023B:
	JSR	pt_LoadModule
	MOVE.W	#$0003,dat_SampleEditorX
	JSR	pt_ClearStatusMsg
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_RedrawSampleEd
	RTS
pt_RedrawSampleEd:
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
pt_SampleEdMode6:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_WaitMouseRelease
	BSR.W	pt_SampleEditorSetup
	BSR.W	pt_AudioBufferInit
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	BSR.W	pt_ClearButtonHitbox
	BSR.W	pt_FileBrowserRefresh
	BEQ.S	pt_023E
	BRA.W	pt_RestorePalette
pt_023E:
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	#$0005,dat_SampleEditorX
	LEA	dat_12CD,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_RestorePalette
pt_SampleEditorBranch:
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_0240
	BSR.W	pt_SampleEditorSetup
	CLR.B	dat_KeyCode
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_0241
	JMP	pt_SelectDiskMsg
pt_0240:
	BSR.W	pt_BtnMainDiskOp
	BRA.S	pt_SampleEditorBranch
pt_0241:
	BSR.W	pt_SavePaletteState
	JSR	pt_09C2
	MOVEQ	#0,D1
	MOVE.W	dat_CurrentSample,D1
	LSL.L	#2,D1
	LEA	dat_ModulePtr,A0
	MOVE.L	(0,A0,D1.W),dat_FileWriteAddr
	BSR.W	pt_SetPaletteDim
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_ScreenBufPtr,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BNE.S	pt_0242
	BRA.W	pt_RestorePaletteInit
pt_0242:
	LEA	dat_12BF,A0
	JSR	pt_ShowStatusMsg
	TST.B	dat_CopperListFlag
	BEQ.S	pt_0243
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_0245,D2
	MOVEQ	#104,D3
	JSR	(-48,A6)
pt_0243:
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileWriteAddr,D2
	MOVE.L	dat_FileWriteSize,D3
	JSR	(-48,A6)
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
	MOVE.W	#$0005,dat_SampleEditorX
	JSR	pt_ClearStatusMsg
	BSR.W	pt_RestorePalette
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_0244
	RTS
pt_0244:
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
dat_0245:
	DC.L	$464f524d
dat_0246:
	DS.L	1
	DC.L	$38535658,$56484452,$00000014
dat_0247:
	DS.L	1
dat_0248:
	DS.L	1
	DC.L	$00000020,$41560100,$00010000,$4e414d45
	DC.L	$00000018
dat_0249:
	DS.L	6
	DC.L	$414e4e4f,$00000010,$50524f54,$5241434b
	DC.L	$45520042,$4f445900
dat_024A:
	DS.L	1
pt_ShowFileSelector:
	BSR.W	pt_024F
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$2355,dat_TextBytePos
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_FileSelectorEntry
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_FileSelectorEntry
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_FileSelectorEntry
	BRA.S	pt_024D
pt_FileSelectorEntry:
	MOVE.W	#$190a,dat_TextBytePos
pt_024D:
	MOVE.W	#$0014,dat_TextCharCount
	JSR	pt_DrawTextRender
	RTS
pt_BtnDiskFile:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	MOVEA.L	dat_ModulePtr,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$00000013,dat_SongDataAddr
	MOVE.W	#$0014,dat_TextCharCount
	MOVEA.W	#$2355,A4
	JSR	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	BRA.W	pt_RestorePalette
pt_024F:
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	(dat_TextInputIdx,PC),D0
	CMP.W	#$0001,D0
	BNE.S	pt_0250
	MOVEA.L	dat_ModulePtr,A0
pt_0250:
	CMP.W	#$0002,D0
	BNE.S	pt_0251
	MOVEA.L	dat_ModulePtr,A0
pt_0251:
	CMP.W	#$0003,D0
	BNE.S	pt_0252
	MOVEA.L	dat_ModulePtr,A0
pt_0252:
	CMP.W	#$0004,D0
	BNE.S	pt_0253
	LEA	dat_0257,A0
pt_0253:
	CMP.W	#$0005,D0
	BNE.S	pt_0255
	MOVEA.L	dat_ModulePtr,A0
	LEA	(-10,A0),A0
	MOVE.W	dat_CurrentSample,D7
	BNE.S	pt_0254
	MOVE.W	dat_SamplePlayInit,D7
pt_0254:
	MULU	#s_SIZEOF,D7
	ADDA.L	D7,A0
pt_0255:
	CMP.W	#$0006,D0
	BNE.S	pt_0256
	LEA	dat_0258,A0
pt_0256:
	RTS
dat_0257:
	DS.L	5
	DS.W	1
dat_0258:
	DS.L	6
pt_TextInputMainLoop:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_TextInputIdx,PC),D0
	SUBQ.W	#1,D0
	MULU	#$0020,D0
	LEA	dat_PatternDataBuf3,A6
	LEA	(0,A6,D0.L),A6
	MOVE.L	A6,dat_TextStringPtr
	MOVE.L	A6,dat_TextEditWorkPtr
	MOVEA.L	A6,A0
	MOVEQ	#41,D0
	MOVEQ	#91,D1
	MOVEQ	#7,D3
	JSR	pt_BlitPatternFull
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BtnDiskMask:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	MOVE.W	(dat_TextInputIdx,PC),D0
	CMP.W	#$0006,D0
	BLS.S	pt_025B
	RTS
pt_025B:
	SUBQ.W	#1,D0
	MULU	#$0020,D0
	LEA	dat_PatternDataBuf3,A6
	LEA	(0,A6,D0.L),A6
	MOVE.L	A6,dat_TextEditWorkPtr
	MOVE.L	A6,dat_TextStringPtr
	MOVE.L	A6,dat_SongDataAddr
	ADDI.L	#$0000001f,dat_SongDataAddr
	MOVE.W	#$0007,dat_TextCharCount
	MOVEQ	#41,D0
	MOVEQ	#91,D1
	JSR	pt_StoreFxParameter
	BSR.W	pt_RestorePalette
	MOVEA.L	dat_TextEditWorkPtr,A1
	BSR.W	pt_ConvertToUpper
	MOVE.B	#$ff,dat_RedrawFlag
	RTS
pt_FilePathCopy:
	MOVEM.L	D0-D1/A0-A3,-(A7)
	EXG	A0,A1
	TST.B	(A1)
	BEQ.S	pt_RestoreRegsReturn
pt_025D:
	MOVE.B	(A1)+,D0
	CMP.B	#$23,D0
	BNE.S	pt_PathCharLoop
	CMPI.B	#$3f,(A1)
	BNE.S	pt_PathCharLoop
	ADDQ.L	#1,A1
	BRA.S	pt_ProcessTextChars
pt_PathCharLoop:
	MOVE.B	(A0)+,D1
	BNE.S	pt_025F
	TST.B	D0
	BEQ.S	pt_RestoreRegsReturn
	BRA.S	pt_ReturnError
pt_025F:
	CMP.B	D0,D1
	BEQ.S	pt_025D
	BRA.S	pt_ReturnError
pt_ProcessTextChars:
	MOVEA.L	A0,A3
	MOVEA.L	A1,A2
	ADDQ.L	#1,A0
pt_0261:
	MOVE.B	(A2)+,D0
	CMP.B	#$23,D0
	BNE.S	pt_PathWildLoop
	CMPI.B	#$3f,(A2)
	BNE.S	pt_PathWildLoop
	ADDQ.L	#1,A2
	MOVEA.L	A2,A1
	MOVEA.L	A3,A0
	BRA.S	pt_ProcessTextChars
pt_PathWildLoop:
	MOVE.B	(A3)+,D1
	BNE.S	pt_0263
	TST.B	D0
	BEQ.S	pt_RestoreRegsReturn
	CMPI.B	#$23,(A2)
	BNE.S	pt_ReturnError
	CMPI.B	#$3f,(1,A2)
	BNE.S	pt_ReturnError
	TST.B	(2,A2)
	BNE.S	pt_ReturnError
	BRA.S	pt_RestoreRegsReturn
pt_0263:
	TST.B	D0
	BEQ.S	pt_0264
	CMP.B	D0,D1
	BEQ.S	pt_0261
pt_0264:
	BRA.S	pt_ProcessTextChars
pt_RestoreRegsReturn:
	MOVEM.L	(A7)+,D0-D1/A0-A3
	MOVEQ	#0,D0
	RTS
pt_ReturnError:
	MOVEM.L	(A7)+,D0-D1/A0-A3
	MOVEQ	#-1,D0
	RTS
dat_0267:
	DC.B	"#?.INFO",0
dat_RedrawFlag:
	DS.W	1
dat_TextEditWorkPtr:
	DS.L	1
pt_ConvertToUpper:
	MOVEM.L	D0/A1,-(A7)
pt_ReadTextChar:
	MOVE.B	(A1)+,D0
	TST.B	D0
	BEQ.S	pt_026D
	CMP.B	#$61,D0
	BEQ.S	pt_UppercaseChar
	BMI.S	pt_ReadTextChar
	CMP.B	#$7a,D0
	BEQ.S	pt_UppercaseChar
	BPL.S	pt_ReadTextChar
pt_UppercaseChar:
	SUB.B	#$20,D0
	MOVE.B	D0,(-1,A1)
	BRA.S	pt_ReadTextChar
pt_026D:
	MOVEM.L	(A7)+,D0/A1
	RTS
pt_BtnDiskHideInfo:
	BSR.W	pt_WaitMouseRelease
	BCHG	#0,dat_UIBitFlags
	MOVE.B	#$ff,dat_RedrawFlag
pt_026F:
	LEA	(dat_0271,PC),A0
	BTST	#0,dat_UIBitFlags
	BEQ.S	pt_0270
	ADDA.W	#$0009,A0
pt_0270:
	MOVEQ	#17,D0
	MOVEQ	#47,D1
	MOVEQ	#9,D3
	JMP	pt_BlitPatternRow
dat_0271:
	DC.B	"Hide InfoShow Info",0,0
pt_BtnDiskPath:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	MOVEA.L	dat_SampleEditorPtr,A6
	MOVE.L	A6,dat_TextStringPtr
	MOVE.L	A6,dat_SongDataAddr
	ADDI.L	#$00000051,dat_SongDataAddr
	MOVE.W	#$0014,dat_TextCharCount
	MOVEA.W	#$1fe5,A4
	JSR	pt_UpdateKeyState
	BSR.W	pt_RestorePalette
	BSR.W	pt_WaitMouseRelease
	MOVE.B	#$ff,dat_RedrawFlag
	BRA.W	pt_BtnDiskReadDir
	DC.W	$4e75
pt_CopyFilename:
	JSR	pt_DiskCopyFilename
	TST.B	(A0)
	BNE.S	pt_CopyFilenameLoop
	RTS
pt_CopyFilenameLoop:
	MOVE.B	(A0)+,(A1)+
	BNE.S	pt_CopyFilenameLoop
	CMPI.B	#$3a,(-2,A1)
	BEQ.S	pt_PathSlashEnd
	CMPI.B	#$2f,(-2,A1)
	BEQ.S	pt_PathSlashEnd
	MOVE.B	#$2f,(-1,A1)
	RTS
pt_PathSlashEnd:
	SUBQ.L	#1,A1
	RTS
pt_DrawSampleEdText:
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_0277
	RTS
pt_0277:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_SampleEditorPtr,A0
	MOVEQ	#20,D0
	MOVE.W	#$1fe5,D1
	JSR	pt_DrawTextAt
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_SampleEdDrawMode:
	TST.W	dat_SampleEditorX
	BNE.S	pt_0279
	RTS
pt_0279:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVE.W	(24,A5),D0
	BNE.S	pt_027A
	RTS
pt_027A:
	SUBQ.W	#1,D0
	MOVE.W	D0,(24,A5)
	BSR.S	pt_ScanButtonHitbox
	RMB
	BNE.W	pt_DrawSampleEdAndUpdate
	SUBQ.W	#3,D0
	BPL.W	pt_DrawSampleEdAndUpdate
	MOVEQ	#0,D0
	BRA.W	pt_DrawSampleEdAndUpdate
pt_SampleEdDrawXPos:
	TST.W	dat_SampleEditorX
	BNE.S	pt_027C
	RTS
pt_027C:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVE.W	(24,A5),D0
	ADDQ.W	#1,D0
	RMB
	BNE.S	pt_027D
	ADDQ.W	#3,D0
pt_027D:
	MOVE.W	(22,A5),D1
	SUB.W	#$0013,D1
	BPL.S	pt_027E
	RTS
pt_027E:
	MOVE.W	D0,(24,A5)
	BSR.S	pt_ScanButtonHitbox
	CMP.W	D1,D0
	BLS.W	pt_DrawSampleEdAndUpdate
	MOVE.W	D1,D0
	BRA.W	pt_DrawSampleEdAndUpdate
pt_ScanButtonHitbox:
	MOVEM.L	D0-D3,-(A7)
	MOVEQ	#0,D3
	MOVE.W	#$0053,dat_ButtonScanMax
	CLR.W	dat_ButtonScanIdx
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVEQ	#83,D0
	CLR.W	D1
	CMPI.W	#$0013,(22,A5)
	BMI.S	pt_ButtonScanSetup
	BEQ.S	pt_ButtonScanSetup
	MOVE.W	#$0629,D0
	MOVE.W	(22,A5),D1
	EXT.L	D0
	DIVU	D1,D0
	MOVE.W	D0,dat_ButtonScanMax
	MOVE.W	(24,A5),D1
	MOVE.W	(22,A5),D2
	MOVE.W	#$0053,D3
	SUB.W	D0,D3
	MULU	D1,D3
	SUB.W	#$0013,D2
	DIVU	D2,D3
	MOVE.W	D3,dat_ButtonScanIdx
pt_ButtonScanSetup:
	MOVE.W	(dat_ButtonScanIdx,PC),D3
	ADD.W	(dat_ButtonScanMax,PC),D3
	CMP.W	#$0053,D3
	BMI.S	pt_0281
	MOVEQ	#83,D3
pt_0281:
	SUB.W	(dat_ButtonScanMax,PC),D3
	MOVE.W	D3,dat_ButtonScanIdx
	BSR.W	pt_DrawButtonSprite
	MOVEM.L	(A7)+,D0-D3
	RTS
dat_ButtonScanIdx:
	DS.W	1
dat_ButtonScanMax:
	DS.W	1
pt_BtnDiskListScroll:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	CMPI.W	#$0013,(22,A5)
	BHI.S	pt_0285
	RTS
pt_0285:
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.W	dat_PalEdSelectPos,D1
	MOVE.W	(dat_ButtonScanIdx,PC),D0
	ADD.W	#$0018,D0
	SUB.W	D0,D1
	BMI.W	pt_028A
	CMP.W	(dat_ButtonScanMax,PC),D1
	BPL.W	pt_028C
	MOVE.W	D1,D2
	MOVE.W	#$0053,D4
	SUB.W	(dat_ButtonScanMax,PC),D4
	BSR.W	pt_0290
	MOVE.W	dat_PalEdSelectPos,D1
pt_UpdatePalEdDisplay:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_0289
	MOVE.W	D1,D3
	MOVE.W	dat_PalEdSelectPos,D1
	CMP.W	D1,D3
	BEQ.S	pt_UpdatePalEdDisplay
	SUB.W	D2,D1
	SUB.W	#$0018,D1
	BPL.S	pt_0287
	MOVEQ	#0,D1
pt_0287:
	CMP.W	D4,D1
	BMI.S	pt_0288
	MOVE.W	D4,D1
pt_0288:
	MOVE.W	D1,dat_ButtonScanIdx
	BSR.W	pt_028E
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVE.W	(22,A5),D0
	SUB.W	#$0013,D0
	MULU	(dat_ButtonScanIdx,PC),D0
	MOVE.W	#$0053,D1
	SUB.W	(dat_ButtonScanMax,PC),D1
	DIVU	D1,D0
	MOVE.W	D0,(24,A5)
	BSR.W	pt_DrawSampleEdAndUpdate
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LMB
	BEQ.S	pt_UpdatePalEdDisplay
pt_0289:
	BSR.S	pt_DrawButtonSprite
	CLR.W	dat_DiskOpFlag
	RTS
pt_028A:
	SUBI.W	#$0013,(24,A5)
	BPL.S	pt_028B
	CLR.W	(24,A5)
pt_028B:
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	CLR.W	dat_DiskOpFlag
	RTS
pt_028C:
	ADDI.W	#$0013,(24,A5)
	MOVE.W	(22,A5),D0
	SUB.W	#$0013,D0
	CMP.W	(24,A5),D0
	BPL.S	pt_028D
	MOVE.W	D0,(24,A5)
pt_028D:
	BSR.W	pt_ScanButtonHitbox
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	CLR.W	dat_DiskOpFlag
	RTS
pt_028E:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_ButtonScanIdx,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_ButtonScanMax,PC),D2
	LEA	dat_SongModifiedFlag2,A0
	JSR	pt_DrawSprite
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_DrawButtonSprite:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_ButtonScanIdx,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_ButtonScanMax,PC),D2
	JSR	pt_PalColorShadeTab
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0290:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_ButtonScanIdx,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_ButtonScanMax,PC),D2
	JSR	pt_InitHwPalette
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BtnDiskFileList:
	TSTPC.W	dat_VBLSyncWord
	BPL.S	pt_0292
	RTS
pt_0292:
	MOVE.W	(dat_VBLSyncWord,PC),D1
	MOVE.W	#$0001,dat_TimeDisplayInit
	TST.W	dat_SampleEditorX
	BNE.S	pt_0293
	RTS
pt_0293:
	AND.L	#$0000ffff,D1
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVE.W	(24,A5),D0
	ADD.W	D1,D0
	CMP.W	(22,A5),D0
	BCS.S	pt_0294
	RTS
pt_0294:
	MULU	#$0024,D0
	ADD.L	(A5),D0
	MOVEA.L	D0,A0
	MOVE.W	dat_SampleEditorX,D6
	CMP.W	#$0009,D6
	BEQ.S	pt_ScopeBufCopy
	CMP.W	#$000a,D6
	BEQ.S	pt_ScopeBufCopy
	TST.L	(32,A0)
	BMI.S	pt_029F
pt_ScopeBufCopy:
	JSR	pt_DiskUseName
	NOP
pt_0296:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0296
	CMP.W	#$0001,D6
	BNE.S	pt_0297
	JMP	pt_09F0
pt_0297:
	CMP.W	#$0002,D6
	BNE.S	pt_0298
	JMP	pt_0EAE
pt_0298:
	CMP.W	#$0003,D6
	BNE.S	pt_0299
	JMP	pt_0E04
pt_0299:
	CMP.W	#$0004,D6
	BNE.S	pt_029A
	JMP	pt_0EA9
pt_029A:
	CMP.W	#$0005,D6
	BNE.S	pt_029B
	JMP	pt_09A8
pt_029B:
	CMP.W	#$0006,D6
	BNE.S	pt_029C
	JMP	pt_0EA0
pt_029C:
	CMP.W	#$0009,D6
	BNE.S	pt_029D
	JMP	pt_09E3
pt_029D:
	CMP.W	#$000a,D6
	BNE.S	pt_029E
	JMP	pt_09E7
pt_029E:
	RTS
pt_029F:
	JSR	pt_DiskDirName
	NOP
	NOP
	NOP
	NOP
pt_02A0:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_02A0
	LEA	dat_FileNameBuf,A0
	MOVEA.L	dat_SampleEditorPtr,A1
	MOVEQ	#81,D0
pt_02A1:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_02A1
pt_SampleEdMainLoop:
	BSR.W	pt_DrawSampleEdText
	MOVE.W	dat_SampleEditorX,D6
	CMP.W	#$0001,D6
	BEQ.W	pt_SampleEdMode2
	CMP.W	#$0002,D6
	BEQ.W	pt_SampleEdMode0Alt
	CMP.W	#$0003,D6
	BEQ.W	pt_EnterSampleEditMode
	CMP.W	#$0004,D6
	BEQ.W	pt_SampleEdMode3
	CMP.W	#$0005,D6
	BEQ.W	pt_SampleEdMode6
	CMP.W	#$0006,D6
	BEQ.W	pt_SampleEdMode5
	RTS
pt_BtnDiskParent:
	BSR.W	pt_WaitMouseRelease
	MOVEA.L	dat_SampleEditorPtr,A0
	MOVEA.L	A0,A1
pt_02A4:
	TST.B	(A1)+
	BNE.S	pt_02A4
	SUBQ.L	#1,A1
	CMPA.L	A0,A1
	BHI.S	pt_02A5
	RTS
pt_02A5:
	SUBQ.L	#1,A1
	CMPI.B	#$2f,(A1)
	BNE.S	pt_PathDriveCheck
	CLR.B	(A1)
pt_PathDriveCheck:
	CMPI.B	#$3a,(A1)
	BEQ.S	pt_SampleEdMainLoop
	CMPI.B	#$2f,(A1)
	BEQ.S	pt_02A7
	CLR.B	(A1)
	CMPA.L	A0,A1
	BLS.S	pt_SampleEdMainLoop
	SUBQ.L	#1,A1
	BRA.S	pt_PathDriveCheck
pt_02A7:
	CLR.B	(A1)
	BRA.S	pt_SampleEdMainLoop
dat_ButtonHitboxes:
	DC.L	dat_ButtonHitbox0
dat_ButtonHitbox0:
	DS.L	20
dat_ButtonHitbox1:
	DS.L	20
dat_ButtonHitbox2:
	DS.L	20
dat_ButtonHitbox3:
	DS.L	20
dat_ButtonHitbox4:
	DS.L	20
dat_ButtonHitbox5:
	DS.L	20
pt_BtnDiskFree:
	BSR.W	pt_WaitMouseRelease
	BSR.S	pt_LoadSampleEditor
	BSR.W	pt_LoadPatternIndex
	JMP	pt_ClearStatusMsg
pt_LoadSampleEditor:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteDim
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_SampleEditorPtr,D1
	MOVEQ	#-2,D2
	JSR	(-84,A6)
	MOVE.L	D0,dat_PatternIndexBuf
	LEA	dat_12D2,A0
	JSR	pt_ShowStatusMsg
	MOVE.L	dat_PatternIndexBuf,D1
	MOVE.L	#dat_14ED,D2
	JSR	(-114,A6)
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_14ED,A0
	MOVE.L	(12,A0),D0
	MOVE.L	(16,A0),D1
	MOVE.L	(20,A0),D2
	SUB.L	D1,D0
	JSR	pt_DiskFreeCalc
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEA.L	dat_SampleEditorPtr,A4
	CMPI.L	#$52616d20,(A4)
	BEQ.S	pt_CheckRAMPath
	CMPI.L	#$72616d3a,(A4)
	BEQ.S	pt_CheckRAMPath
	CMPI.L	#$52414d3a,(A4)
	BNE.S	pt_ProcessHitbox
pt_CheckRAMPath:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEQ	#4,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-216,A6)
	MOVE.L	D0,(26,A5)
	MOVEQ	#2,D1
	JSR	(-216,A6)
	ADD.L	D0,(26,A5)
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_ProcessHitbox:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	JSR	pt_DiskFreeShow
	NOP
	NOP
	NOP
	JSR	pt_FormatNumToDecimal
pt_ProcessHitboxEnd:
	MOVEQ	#0,D0
	RTS
pt_FormatMemSize:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	ADDI.W	#$0032,(8,A5)
	MOVE.W	(8,A5),D0
	MULU	#$0024,D0
	MOVE.L	(4,A5),D6
	MOVE.L	D0,(4,A5)
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,D7
	BEQ.W	pt_02BB
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVE.L	(A5),D1
	MOVE.L	D7,(A5)
	TST.L	D1
	BNE.S	pt_02B4
	RTS
pt_02B4:
	TST.L	D6
	BNE.S	pt_02B5
	RTS
pt_02B5:
	MOVEA.L	D1,A0
	MOVEA.L	D7,A1
	MOVE.L	D6,D0
pt_02B6:
	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D6
	BNE.S	pt_02B6
	MOVEA.L	D1,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	RTS
pt_02B7:
	LEA	(dat_ButtonHitbox0,PC),A5
	BSR.S	pt_ClipboardCopy
	LEA	(dat_ButtonHitbox1,PC),A5
	BSR.S	pt_ClipboardCopy
	LEA	(dat_ButtonHitbox2,PC),A5
	BSR.S	pt_ClipboardCopy
	LEA	(dat_ButtonHitbox3,PC),A5
	BSR.S	pt_ClipboardCopy
	LEA	(dat_ButtonHitbox4,PC),A5
	BSR.S	pt_ClipboardCopy
	LEA	(dat_ButtonHitbox5,PC),A5
	BSR.S	pt_ClipboardCopy
	RTS
pt_02B8:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
pt_ClipboardCopy:
	MOVE.L	(A5),D1
	BNE.S	pt_02BA
	RTS
pt_02BA:
	MOVEA.L	D1,A1
	MOVE.L	(4,A5),D0
	CLR.L	(A5)
	CLR.W	(4,A5)
	CLR.W	(8,A5)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	RTS
pt_02BB:
	JSR	pt_SetupPaletteMode
	MOVEQ	#-1,D0
	RTS
pt_FileBrowserRefresh:
	CLR.B	dat_RedrawFlag
	BSR.S	pt_02B8
	BSR.W	pt_FormatMemSize
	BSR.W	pt_LoadSampleEditor
	BEQ.S	pt_02BD
	RTS
pt_02BD:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	CLR.W	(24,A5)
	MOVE.L	dat_PatternIndexBuf,D1
	MOVE.L	#dat_AudioDMAState,D2
	JSR	(-102,A6)
	TST.L	D0
	BEQ.S	pt_02C1
pt_02BE:
	MOVE.L	dat_PatternIndexBuf,D1
	MOVE.L	#dat_AudioDMAState,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-108,A6)
	TST.L	D0
	BEQ.S	pt_LoadPatternIndex
	RMB
	BEQ.S	pt_02BF
	BSR.W	pt_02C6
	BRA.S	pt_02BE
pt_02BF:
	CLR.L	(10,A5)
	LEA	(dat_02C5,PC),A0
	JSR	pt_ShowStatusMsg
	BSR.S	pt_LoadPatternIndex
	BSR.W	pt_UpdatePaletteAll
	JSR	pt_ClearStatusMsg
	MOVEQ	#0,D0
	RTS
pt_LoadPatternIndex:
	MOVE.L	dat_PatternIndexBuf,D1
	JSR	(-90,A6)
	BSR.W	pt_RestorePalette
	MOVEQ	#0,D0
	RTS
	DC.L	$33fcffff
	DC.L	dat_DiskOpFlag
pt_02C1:
	TST.L	dat_PatternIndexBuf
	BEQ.S	pt_02C2
	MOVE.L	dat_PatternIndexBuf,D1
	JSR	(-90,A6)
pt_02C2:
	BSR.W	pt_RestorePalette
	LEA	dat_02C4,A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_SetPaletteEdit
	MOVEQ	#-1,D0
	RTS
pt_ClearButtonHitbox:
	CLR.W	(22,A5)
	RTS
dat_02C4:
	DC.B	"CAN'T FIND DIR!",0
dat_02C5:
	DC.B	"DIR ARBORTED!",0
pt_02C6:
	LEA	dat_FileBrowserState,A0
	BTST	#2,dat_UIStateFlag
	BNE.S	pt_FileBrowserMain
	TST.L	dat_AudioDMACtrl
	BMI.S	pt_FileBrowserMain
	RTS
pt_FileBrowserMain:
	TST.L	dat_AudioDMACtrl
	BPL.S	pt_02CB
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEQ	#0,D0
	MOVEA.L	#dat_FileBrowserState,A1
	BSR.W	pt_ConvertToUpper
	BTST	#0,dat_UIBitFlags
	BNE.S	pt_02C8
	LEA	(dat_0267,PC),A0
	BSR.W	pt_FilePathCopy
	TST.L	D0
	BEQ.S	pt_02C9
pt_02C8:
	MOVEA.L	(dat_TextEditWorkPtr,PC),A0
	BSR.W	pt_FilePathCopy
	TST.L	D0
	BEQ.S	pt_02CA
pt_02C9:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_02CA:
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_02CB:
	MOVE.W	(22,A5),D0
	CMP.W	(8,A5),D0
	BCS.S	pt_02CC
	MOVE.L	A0,-(A7)
	BSR.W	pt_FormatMemSize
	MOVEA.L	(A7)+,A0
pt_02CC:
	MOVE.W	(22,A5),D6
	BEQ.S	pt_02D5
	SUBQ.W	#1,D6
	MOVEA.L	(A5),A1
pt_02CD:
	MOVEQ	#0,D2
	MOVE.L	dat_AudioDMACtrl,D0
	MOVE.L	(32,A1),D1
	TST.L	D0
	BPL.S	pt_02CE
	TST.L	D1
	BMI.S	pt_PatternTableLoop
	BRA.S	pt_02CF
pt_02CE:
	TST.L	D1
	BPL.S	pt_PatternDataSetup
pt_02CF:
	MOVE.B	(0,A0,D2.W),D0
	BEQ.S	pt_PatternDataSetup
	CMP.B	#$60,D0
	BCS.S	pt_02D0
	SUB.B	#$20,D0
pt_02D0:
	MOVE.B	(0,A1,D2.W),D1
	BEQ.S	pt_PatternTableLoop
	CMP.B	#$60,D1
	BCS.S	pt_02D1
	SUB.B	#$20,D1
pt_02D1:
	CMP.B	D0,D1
	BHI.S	pt_PatternDataSetup
	BNE.S	pt_PatternTableLoop
	ADDQ.W	#1,D2
	BRA.S	pt_02CF
pt_PatternTableLoop:
	LEA	(36,A1),A1
	DBF	D6,pt_02CD
	MOVEA.L	(A5),A1
	MOVE.W	(22,A5),D0
	MULU	#$0024,D0
	ADDA.L	D0,A1
	BRA.S	pt_02D6
pt_PatternDataSetup:
	MOVEA.L	(A5),A2
	MOVE.W	(22,A5),D0
	MULU	#$0024,D0
	ADDA.L	D0,A2
	MOVEA.L	A2,A3
	LEA	(36,A3),A3
pt_02D4:
	MOVE.W	-(A2),-(A3)
	CMPA.L	A2,A1
	BNE.S	pt_02D4
	BRA.S	pt_02D6
pt_02D5:
	MOVEA.L	(A5),A1
pt_02D6:
	LEA	dat_FileBrowserState,A0
	MOVEA.L	A1,A3
	MOVEQ	#35,D0
pt_02D7:
	CLR.B	(A3)+
	DBF	D0,pt_02D7
	MOVE.W	dat_14EC,(30,A1)
	MOVEQ	#-1,D0
	TST.L	dat_AudioDMACtrl
	BPL.S	pt_02D8
	MOVE.L	dat_PatternEditBuf,D0
pt_02D8:
	MOVE.L	D0,(32,A1)
	JSR	pt_DiskStoreName
	NOP
	NOP
	NOP
	NOP
pt_02DA:
	ADDQ.W	#1,(22,A5)
	JSR	pt_DiskEntryRedraw
	NOP
	NOP
	NOP
	NOP
	NOP
	RTS
pt_DrawSampleEdAndUpdate:
	MOVE.W	D0,-(A7)
	BSR.W	pt_DrawSampleEdText
	MOVE.W	(A7)+,D0
pt_02DC:
	MOVE.W	D0,(24,A5)
	TST.W	(22,A5)
	BNE.S	pt_02DD
	RTS
pt_02DD:
	MOVEA.W	#$0169,A6
	MOVE.W	A6,dat_TextBytePos
	MOVE.L	(A5),D6
	MULU	#$0024,D0
	ADD.L	D0,D6
	AND.L	#$fffffffe,D6
	MOVE.W	(22,A5),D0
	SUB.W	(24,A5),D0
	CMP.W	#$0013,D0
	BCC.S	pt_02DE
	SUBQ.W	#1,D0
	MOVE.W	D0,D7
	BRA.S	pt_02DF
pt_02DE:
	MOVEQ	#18,D7
pt_02DF:
	MOVE.W	A6,dat_TextBytePos
	MOVEA.L	D6,A0
	MOVEQ	#0,D0
	MOVE.W	(30,A0),D0
	CMPI.B	#$01,dat_VBLCounterLo
	BEQ.S	pt_02E0
	BSR.W	pt_02EC
	MOVE.W	(dat_DirListVar2,PC),dat_DisplayParam
	JSR	pt_Format2DigitHex
	MOVE.W	(dat_DirListVar1,PC),dat_DisplayParam
	JSR	pt_Format2DigitHex
	MOVE.W	(dat_DisplayParamVar,PC),dat_DisplayParam
	JSR	pt_Format2DigitHex
	ADDQ.W	#1,dat_TextBytePos
pt_02E0:
	MOVE.L	D6,dat_TextStringPtr
	MOVE.W	#$0018,dat_TextCharCount
	CMPI.B	#$01,dat_VBLCounterHi
	BNE.W	pt_02E5
	MOVE.L	D4,-(A7)
	MOVEA.L	D6,A0
	MOVEQ	#0,D3
	JSR	pt_PeekLong
	CMP.L	#$6d6f642e,D4
	BEQ.S	pt_SkipPTSMarker
	CMP.L	#$4d4f442e,D4
	BEQ.S	pt_SkipPTSMarker
	CMP.L	#$70746d2e,D4
	BEQ.S	pt_SkipPTSMarker
	CMP.L	#$50544d2e,D4
	BEQ.S	pt_SkipPTSMarker
	CMP.L	#$7074732e,D4
	BEQ.S	pt_SkipPTSMarker
	CMP.L	#$5054532e,D4
	BNE.S	pt_02E2
pt_SkipPTSMarker:
	ADDQ.L	#4,dat_TextStringPtr
pt_02E2:
	MOVEQ	#24,D3
pt_02E3:
	JSR	pt_PeekLong
	CMP.L	#$2e6d6f64,D4
	BEQ.S	dat_TextLineCount
	CMP.L	#$2e4d4f44,D4
	BEQ.S	dat_TextLineCount
	CMP.L	#$2e70746d,D4
	BEQ.S	dat_TextLineCount
	CMP.L	#$2e50544d,D4
	BEQ.S	dat_TextLineCount
	CMP.L	#$2e707473,D4
	BEQ.S	dat_TextLineCount
	CMP.L	#$2e505453,D4
	BEQ.S	dat_TextLineCount
	DBF	D3,pt_02E3
	BRA.S	pt_02E4pop
dat_TextLineCount:
	MOVE.W	D3,dat_TextCharCount
	MOVE.W	D3,dat_DirStringBuf
pt_02E4pop:
	MOVE.L	(A7)+,D4
pt_02E5:
	BTST	#1,dat_FontMode
	BEQ.S	pt_02E6
	BSET	#1,dat_FileStatus
	BCLR	#1,dat_FontMode
pt_02E6:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	TST.W	dat_DirStringBuf
	BEQ.S	pt_02E7
	MOVE.W	#$000e,dat_TextCharCount
	MOVE.L	#pt_SampleEdEntry,dat_TextStringPtr
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	CLR.W	dat_DirStringBuf
pt_02E7:
	BTST	#1,dat_FileStatus
	BEQ.S	pt_02E8
	BSET	#1,dat_FontMode
pt_02E8:
	LEA	(32,A6),A6
	MOVE.W	A6,dat_TextBytePos
	MOVEA.L	D6,A0
	MOVE.L	(32,A0),D1
	BMI.S	pt_02EB
	BTST	#7,dat_ModeFlags
	BNE.S	pt_02EA
	SWAP	D1
	AND.W	#$000f,D1
	JSR	pt_ConvertDecChar
	MOVEA.L	D6,A0
	MOVE.W	(34,A0),dat_DisplayParam
	JSR	pt_DrawDecValue2
pt_02E9:
	ADD.L	#$00000024,D6
	LEA	(448,A6),A6
	DBF	D7,pt_02DF
	RTS
pt_02EA:
	MOVE.L	D1,D0
	SUBQ.W	#1,dat_TextBytePos
	JSR	pt_FormatNumToDecimal
	BRA.S	pt_02E9
pt_02EB:
	MOVE.L	#dat_02F7,dat_TextStringPtr
	SUBQ.W	#1,dat_TextBytePos
	MOVE.W	#$0006,dat_TextCharCount
	JSR	pt_DrawTextRender
	BRA.S	pt_02E9
pt_02EC:
	DIVU	#$05b5,D0
	LSL.W	#2,D0
	MOVE.W	D0,dat_DisplayParamVar
	CLR.W	D0
	SWAP	D0
	CMP.W	#$0315,D0
	BEQ.S	pt_02F2
	BCS.S	pt_02ED
	SUBQ.W	#1,D0
pt_02ED:
	DIVU	#$016d,D0
	MOVE.L	D0,D1
	SWAP	D1
	CMP.W	#$0004,D0
	BCS.S	pt_02EE
	SUBQ.W	#1,D0
pt_02EE:
	ADD.W	D0,dat_DisplayParamVar
	LEA	(dat_02F6,PC),A1
	MOVEQ	#24,D0
pt_02EF:
	SUBQ.W	#2,D0
	MOVE.W	(0,A1,D0.W),D2
	CMP.W	D2,D1
	BCC.S	pt_02F0
	TST.W	D0
	BNE.S	pt_02EF
pt_02F0:
	LSR.W	#1,D0
	ADDQ.W	#1,D0
	MOVE.W	D0,dat_DirListVar1
	SUB.W	D2,D1
	ADDQ.W	#1,D1
	MOVE.W	D1,dat_DirListVar2
pt_02F1:
	MOVEQ	#0,D0
	MOVE.W	(dat_DisplayParamVar,PC),D0
	ADD.W	#$004e,D0
	DIVU	#$0064,D0
	SWAP	D0
	MOVE.W	D0,dat_DisplayParamVar
	RTS
pt_02F2:
	ADDQ.W	#2,dat_DisplayParamVar
	MOVE.W	#$0002,dat_DirListVar1
	MOVE.W	#$001d,dat_DirListVar2
	BRA.S	pt_02F1
