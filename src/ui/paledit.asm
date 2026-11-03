pt_DrawEffectDigits:
	LEA	(dat_DigitGlyphTable,PC),A2
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	ADDA.W	#$15e2,A1
	BSR.S	pt_ReadPatternCursor
	AND.W	#$000f,D1
	BSR.S	pt_DrawDigitGlyph
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	ADDA.W	#$1272,A1
	BSR.S	pt_ReadPatternCursor
	AND.W	#$00f0,D1
	LSR.W	#4,D1
	BSR.S	pt_DrawDigitGlyph
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	ADDA.W	#$0f02,A1
	BSR.S	pt_ReadPatternCursor
	AND.W	#$0f00,D1
	LSR.W	#8,D1
pt_DrawDigitGlyph:
	CLR.L	(A1)
	CLR.L	(4,A1)
	CLR.L	(80,A1)
	CLR.L	(84,A1)
	CLR.L	(160,A1)
	CLR.L	(164,A1)
	MOVE.W	D1,D3
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVE.W	(2,A2,D3.W),D4
	MOVE.B	(0,A2,D3.W),(0,A1,D4.W)
	MOVE.B	(1,A2,D3.W),(1,A1,D4.W)
	MOVE.B	(0,A2,D3.W),(80,A1,D4.W)
	MOVE.B	(1,A2,D3.W),(81,A1,D4.W)
	MOVE.L	A1,-(A7)
	ADDA.W	#$00a0,A1
	MOVE.B	(0,A2,D3.W),(0,A1,D4.W)
	MOVE.B	(1,A2,D3.W),(1,A1,D4.W)
	MOVEA.L	(A7)+,A1
	RTS
dat_DigitGlyphTable:
	DC.L	$007c0000,$0f800001,$01f00001,$003e0001
	DC.L	$07c00002,$00f80002,$001f0002,$03e00003
	DC.L	$007c0003,$0f800004,$01f00004,$003e0004
	DC.L	$07c00005,$00f80005,$001f0005,$03e00006
pt_BtnSetupPalSwatch:
	TST.W	dat_PalEdActive
	BEQ.S	pt_PatClickInit
	MOVEM.W	D0-D1,-(A7)
	BSR.W	pt_PalEdRefresh
	MOVEM.W	(A7)+,D0-D1
pt_PatClickInit:
	CLR.W	dat_PalEdActive
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(3850,A0),A0
	MOVEQ	#24,D2
pt_075A:
	CLR.L	(A0)
	LEA	(80,A0),A0
	DBF	D2,pt_075A
	SUB.W	#$0052,D0
	DIVU	#$000d,D0
	SUB.W	#$0031,D1
	DIVU	#$0006,D1
	MOVE.W	D0,D2
	LSL.W	#2,D2
	ADD.W	D1,D2
	MOVE.W	D2,dat_PatCursorIndex
pt_PatClickSetup:
	BSR.W	pt_ReadPatternCursor
	MOVE.L	A0,dat_SavedCursorAddr
	MOVE.W	D1,dat_SavedCursorVal
	BSR.W	pt_DrawEffectDigits
	BSR.S	pt_ClearCursorArea
	MOVE.W	dat_PatCursorIndex,D0
	MOVE.W	D0,D1
	AND.W	#$0003,D1
	MULU	#$01e0,D1
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	ADDA.L	D1,A0
	LEA	(3850,A0),A0
	BTST	#2,D0
	BNE.S	pt_DrawCursor8Ch
	MOVE.W	#$3ff0,(A0)
	MOVE.W	#$3ff0,(480,A0)
	MOVEQ	#4,D0
pt_DrawCursor4Ch:
	LEA	(80,A0),A0
	MOVE.W	#$2010,(A0)
	DBF	D0,pt_DrawCursor4Ch
	BSR.S	pt_CheckCopyPending
	BSR.W	pt_CheckSwapPending
	BRA.W	pt_WaitMouseRelease
pt_DrawCursor8Ch:
	MOVE.L	#$0001ff80,(A0)
	MOVE.L	#$0001ff80,(480,A0)
	MOVEQ	#4,D0
pt_DrawCursor8Loop:
	LEA	(80,A0),A0
	MOVE.L	#$0001ff80,(A0)
	DBF	D0,pt_DrawCursor8Loop
	BSR.S	pt_CheckCopyPending
	BSR.S	pt_CheckSwapPending
	BRA.W	pt_WaitMouseRelease
pt_ClearCursorArea:
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(3932,A0),A0
	MOVEQ	#3,D1
pt_ClearCursorOuter:
	MOVEQ	#4,D0
pt_ClearCursorInner:
	MOVE.B	#$ff,(A0)
	ADDA.W	#$0050,A0
	DBF	D0,pt_ClearCursorInner
	ADDA.W	#$0050,A0
	DBF	D1,pt_ClearCursorOuter
	RTS
pt_CheckCopyPending:
	TST.W	dat_CopyPending
	BNE.S	pt_DoCopyNote
	RTS
pt_DoCopyNote:
	CLR.W	dat_CopyPending
	LEA	dat_ScopeWorkBuf,A0
	MOVE.W	(dat_CopySourcePos,PC),D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	(A0),D2
	LEA	dat_ScopeWorkBuf,A0
	MOVE.W	(dat_PatCursorIndex,PC),D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	D2,(A0)
	BSR.W	pt_UpdatePaletteCopper
	RTS
pt_CheckSwapPending:
	TST.W	dat_SwapPending
	BNE.S	pt_DoSwapNote
	RTS
pt_DoSwapNote:
	CLR.W	dat_SwapPending
	LEA	dat_ScopeWorkBuf,A0
	MOVEA.L	A0,A1
	MOVE.W	(dat_SwapSourcePos,PC),D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	(dat_PatCursorIndex,PC),D1
	ADD.W	D1,D1
	LEA	(0,A1,D1.W),A1
	MOVE.W	(A0),D2
	MOVE.W	(A1),(A0)
	MOVE.W	D2,(A1)
	BSR.W	pt_UpdatePaletteCopper
	RTS
pt_SetCopySource:
	MOVE.W	dat_PatCursorIndex,dat_CopySourcePos
	MOVE.W	#$0001,dat_CopyPending
	CLR.W	dat_SwapPending
	RTS
pt_SetSwapSource:
	MOVE.W	dat_PatCursorIndex,dat_SwapSourcePos
	MOVE.W	#$0001,dat_SwapPending
	CLR.W	dat_CopyPending
	RTS
dat_CopySourcePos:
	DS.W	1
dat_CopyPending:
	DS.W	1
dat_SwapSourcePos:
	DS.W	1
dat_SwapPending:
	DC.W	$0000
	DC.W	$2079
	DC.L	dat_SavedCursorAddr
	DC.W	$3039
	DC.L	dat_SavedCursorVal
	DC.W	$33d0
	DC.L	dat_SavedCursorVal
	DC.L	$30806100,$fd6e6000
	DC.W	$00c6
pt_ClearPatternArea:
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(3850,A0),A0
	MOVEQ	#3,D0
pt_ClearPatColLoop:
	CLR.L	(A0)
	MOVE.L	#$0000ff00,(80,A0)
	MOVE.L	#$0000ff00,(160,A0)
	MOVE.L	#$0000ff00,(240,A0)
	MOVE.L	#$0000ff00,(320,A0)
	MOVE.L	#$0000ff00,(400,A0)
	CLR.L	(480,A0)
	LEA	(480,A0),A0
	DBF	D0,pt_ClearPatColLoop
	CLR.W	dat_CopyPending
	CLR.W	dat_SwapPending
	RTS
pt_BtnSetupPalCancel:
	LEA	(dat_PaletteBackup,PC),A0
	LEA	dat_ScopeWorkBuf,A1
	MOVEQ	#7,D0
pt_LoadDefPalLoop:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_LoadDefPalLoop
	BSR.W	pt_DrawEffectDigits
	BRA.S	pt_UpdatePaletteCopper
pt_BackupPalette:
	LEA	dat_ScopeWorkBuf,A0
	LEA	(dat_PaletteBackup,PC),A1
	MOVEQ	#7,D0
pt_BackupPalLoop:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_BackupPalLoop
	LEA	dat_PaletteEditBuf,A0
	LEA	dat_1534,A1
	MOVEQ	#87,D0
pt_BackupPatDataLoop:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_BackupPatDataLoop
	RTS
dat_SavedCursorVal:
	DS.W	1
dat_SavedCursorAddr:
	DS.L	1
dat_PaletteBackup:
	DS.L	4
pt_BtnSetupPalDef:
	JSR	pt_SchDefCol
	NOP
	NOP
	MOVEQ	#7,D0
pt_RestoreModPalLoop:
	MOVE.W	(A0)+,(A1)+
	DBF	D0,pt_RestoreModPalLoop
	BSR.W	pt_DrawEffectDigits
pt_UpdatePaletteCopper:
	LEA	dat_ScopeWorkBuf,A0
	LEA	chip_Palette2,A1
	MOVE.W	(A0),(A1)
	MOVE.W	(2,A0),(4,A1)
	MOVE.W	(4,A0),(8,A1)
	MOVE.W	(6,A0),(12,A1)
	MOVE.W	(8,A0),(16,A1)
	MOVE.W	(10,A0),(20,A1)
	MOVE.W	(12,A0),(24,A1)
	MOVE.W	(14,A0),(28,A1)
	MOVE.W	(14,A0),D0
	TST.W	dat_SamplerActive
	BEQ.S	pt_PaletteNormal
	MOVE.W	(8,A0),chip_CopperColor4
	BRA.S	pt_PaletteDiskOp
pt_PaletteNormal:
	MOVE.W	D0,chip_CopperColor6
	MOVE.W	(10,A0),chip_CopperColor7
pt_PaletteDiskOp:
	MOVE.W	(10,A0),D0
	MOVE.W	D0,D4
	MOVE.W	#$0005,dat_PalBrightAdj
	BSR.S	pt_AdjustColorBright
	MOVE.W	D0,(32,A1)
	MOVE.W	D4,(36,A1)
	MOVE.W	D4,D0
	MOVE.W	#$fffc,dat_PalBrightAdj
	BSR.S	pt_AdjustColorBright
	MOVE.W	D0,(40,A1)
	RTS
pt_AdjustColorBright:
	MOVE.W	D0,D1
	MOVE.W	D0,D2
	MOVE.W	D0,D3
	LSR.W	#8,D1
	ADD.W	(dat_PalBrightAdj,PC),D1
	BPL.S	pt_ClampRed
	MOVEQ	#0,D1
pt_ClampRed:
	CMP.W	#$000f,D1
	BLS.S	pt_ClampRedMax
	MOVEQ	#15,D1
pt_ClampRedMax:
	AND.W	#$00f0,D2
	LSR.W	#4,D2
	ADD.W	(dat_PalBrightAdj,PC),D2
	BPL.S	pt_ClampGreen
	MOVEQ	#0,D2
pt_ClampGreen:
	CMP.W	#$000f,D2
	BLS.S	pt_ClampGreenMax
	MOVEQ	#15,D2
pt_ClampGreenMax:
	AND.W	#$000f,D3
	ADD.W	(dat_PalBrightAdj,PC),D3
	BPL.S	pt_ClampBlue
	MOVEQ	#0,D3
pt_ClampBlue:
	CMP.W	#$000f,D3
	BLS.S	pt_ClampBlueMax
	MOVEQ	#15,D3
pt_ClampBlueMax:
	MOVE.W	D3,D0
	LSL.W	#4,D2
	OR.W	D2,D0
	LSL.W	#8,D1
	OR.W	D1,D0
	RTS
dat_PatCursorIndex:
	DS.W	1
dat_PalBrightAdj:
	DC.W	$fffd
pt_BtnSetupPrtField:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	LEA	dat_NotifyHookVec,A6
	MOVE.L	A6,dat_TextStringPtr
	MOVE.L	A6,dat_SongDataAddr
	ADDI.L	#$0000001e,dat_SongDataAddr
	MOVE.W	#$000c,dat_TextCharCount
	MOVEA.W	#SV_PRTFIELD_POS&$7fff,A4
	BSR.W	pt_UpdateKeyState
	BRA.W	pt_RestorePalette
pt_0785:
	LEA	dat_NotifyHookVec,A0
	MOVE.W	#SV_PRTFIELD_POS,D1
	MOVEQ	#12,D0
	JMP	pt_SetTextAtP2
pt_BtnSetupPrintSong:
	LEA	dat_12DD,A0
	BSR.W	pt_ShowYesNoDialog
	BEQ.S	pt_0787
	RTS
pt_0787:
	BSR.W	pt_SavePaletteState
	MOVE.L	#dat_NotifyHookVec,D1
	MOVE.L	#$000003ee,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BNE.S	pt_0788
	JMP	pt_DrawWaveform
pt_0788:
	BSR.W	pt_SetPaletteDim
	LEA	dat_12D4,A0
	JSR	pt_ShowStatusMsg
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1303,D2
	MOVEQ	#68,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-48,A6)
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_ModulePtr,D2
	MOVEQ	#20,D3
	JSR	(-48,A6)
	BSR.W	pt_LoadDosLib
	BSR.W	pt_LoadDosLib
	BSR.S	pt_078D
	BSR.W	pt_LoadDosLib
	BSR.W	pt_0795
	BSR.W	pt_079C
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#0,D0
	MOVE.B	(mod_songlen,A0),D0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D7
pt_0789:
	CMP.B	(0,A0,D0.W),D7
	BGT.S	pt_078A
	MOVE.B	(0,A0,D0.W),D7
pt_078A:
	SUBQ.W	#1,D0
	BPL.S	pt_0789
	MOVEQ	#0,D1
pt_078B:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	BSR.W	pt_079D
	MOVEM.L	(A7)+,D1-D7/A0-A6
	TST.L	D0
	BNE.S	pt_078C
	MOVEM.L	D1/D7,-(A7)
	BSR.W	pt_079C
	MOVEM.L	(A7)+,D1/D7
	ADDQ.W	#1,D1
	CMP.W	D7,D1
	BCS.S	pt_078B
pt_078C:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
	JSR	pt_ClearStatusMsg
	BRA.W	pt_RestorePalette
pt_078D:
	MOVEQ	#1,D7
pt_078E:
	MOVE.L	D7,D0
	LSR.B	#4,D0
	CMP.B	#$09,D0
	BLS.S	pt_078F
	ADDQ.B	#7,D0
pt_078F:
	ADD.B	#$30,D0
	MOVE.B	D0,dat_130A
	MOVE.B	D7,D0
	AND.B	#$0f,D0
	CMP.B	#$09,D0
	BLS.S	pt_0790
	ADDQ.B	#7,D0
pt_0790:
	ADD.B	#$30,D0
	MOVE.B	D0,dat_130B
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	D7,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0,D0.W),A0
	LEA	dat_130C,A1
	MOVEQ	#21,D0
pt_0791:
	MOVE.B	#$20,(A1)+
	DBF	D0,pt_0791
	LEA	dat_130C,A1
	MOVE.L	A0,dat_SamplePtrBuf
pt_0792:
	MOVE.B	(A0)+,D0
	BEQ.S	pt_0794
	MOVE.B	D0,(A1)+
	BRA.S	pt_0792
dat_SamplePtrBuf:
	DS.L	1
pt_0794:
	MOVE.L	D7,-(A7)
	MOVEA.L	(dat_SamplePtrBuf,PC),A0
	MOVE.W	(22,A0),D0
	ADD.W	D0,D0
	LEA	dat_130D,A0
	JSR	pt_HexDigitFormat
	MOVEA.L	(dat_SamplePtrBuf,PC),A0
	MOVE.W	(26,A0),D0
	ADD.W	D0,D0
	LEA	dat_130E,A0
	JSR	pt_HexDigitFormat
	MOVEA.L	(dat_SamplePtrBuf,PC),A0
	MOVE.W	(28,A0),D0
	ADD.W	D0,D0
	LEA	dat_130F,A0
	JSR	pt_HexDigitFormat
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1309,D2
	MOVEQ	#52,D3
	JSR	(-48,A6)
	MOVE.L	(A7)+,D7
	ADDQ.W	#1,D7
	CMP.W	#$0020,D7
	BNE.W	pt_078E
	RTS
pt_0795:
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#0,D7
	MOVE.B	(mod_songlen,A0),D7
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D5
pt_0796:
	MOVEQ	#0,D6
pt_0797:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.W	D0,D1
	LSR.W	#4,D1
	ADD.B	#$30,D1
	CMP.B	#$39,D1
	BLS.S	pt_0798
	ADDQ.B	#7,D1
pt_0798:
	AND.B	#$0f,D0
	ADD.B	#$30,D0
	CMP.B	#$39,D0
	BLS.S	pt_0799
	ADDQ.B	#7,D0
pt_0799:
	LEA	dat_1312,A1
	MOVE.B	D1,(A1)+
	MOVE.B	D0,(A1)
	MOVEM.L	D5-D7/A0,-(A7)
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1312,D2
	MOVEQ	#4,D3
	JSR	(-48,A6)
	MOVEM.L	(A7)+,D5-D7/A0
	ADDQ.W	#1,D5
	CMP.W	D5,D7
	BNE.S	pt_079A
	RTS
pt_079A:
	ADDQ.W	#1,D6
	CMP.W	#$0010,D6
	BNE.S	pt_0797
	MOVEM.L	D5-D7/A0,-(A7)
	BSR.S	pt_LoadDosLib
	MOVEM.L	(A7)+,D5-D7/A0
	BRA.S	pt_0796
pt_LoadDosLib:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1304,D2
	MOVEQ	#2,D3
	JSR	(-48,A6)
	RTS
pt_079C:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1305,D2
	MOVEQ	#1,D3
	JSR	(-48,A6)
	RTS
pt_079D:
	MOVE.L	D1,D6
	DIVU	#$000a,D6
	ADD.B	#$30,D6
	MOVE.B	D6,dat_1307
	SWAP	D6
	ADD.B	#$30,D6
	MOVE.B	D6,dat_1308
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1306,D2
	MOVEQ	#18,D3
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-48,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.L	D1,D6
	MOVEA.L	dat_ModulePtr,A6
	LEA	(mod_patterns,A6),A6
	LSL.L	#8,D6
	LSL.L	#2,D6
	BTST	#5,dat_ModeFlags
	BNE.S	pt_079E
	LSL.L	#1,D6
pt_079E:
	ADDA.L	D6,A6
	CLR.L	dat_RowCounter
	MOVEQ	#0,D6
pt_079F:
	MOVEQ	#0,D7
	MOVE.W	#$0002,dat_TextCharCount
	MOVE.L	dat_RowCounter,D1
	LEA	dat_1311,A5
	DIVU	#$000a,D1
	ADD.B	#$30,D1
	MOVE.B	D1,(A5)+
	CLR.W	D1
	SWAP	D1
	ADD.B	#$30,D1
	MOVE.B	D1,(A5)+
	ADDQ.L	#5,A5
pt_07A0:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#$0003,dat_TextCharCount
	MOVE.W	(A6),D1
	AND.W	#$0fff,D1
	LEA	dat_PeriodTable,A0
pt_07A1:
	CMP.W	(0,A0,D0.L),D1
	BEQ.S	pt_07A2
	ADDQ.L	#2,D0
	BRA.S	pt_07A1
pt_07A2:
	ADD.L	D0,D0
	ADD.L	dat_NoteNamesPtr,D0
	MOVEA.L	D0,A0
	MOVE.L	(A0),(A5)+
	CMPI.B	#$a1,(-3,A5)
	BNE.S	pt_07A3
	MOVE.B	#$62,(-3,A5)
pt_07A3:
	ADDQ.L	#1,A5
	MOVEQ	#0,D0
	MOVE.W	(A6),D0
	AND.W	#$f000,D0
	LSR.W	#8,D0
	LSL.L	#1,D0
	LEA	dat_HexPairTable,A0
	ADDA.L	D0,A0
	MOVE.B	(A0),(A5)+
	MOVEQ	#0,D0
	MOVE.B	(2,A6),D0
	LSL.L	#1,D0
	LEA	dat_HexPairTable,A0
	ADDA.L	D0,A0
	MOVE.W	(A0),(A5)+
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	LSL.L	#1,D0
	LEA	dat_HexPairTable,A0
	ADDA.L	D0,A0
	MOVE.W	(A0),(A5)+
	ADDQ.L	#4,A5
	ADDQ.L	#4,A6
	ADDQ.L	#1,D7
	CMP.L	#$00000004,D7
	BNE.W	pt_07A0
	ADDQ.L	#1,dat_RowCounter
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_1310,D2
	MOVEQ	#68,D3
	JSR	(-48,A6)
	BSR.W	pt_LoadDosLib
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RMB
	BEQ.S	pt_07A4
	ADDQ.L	#1,D6
	CMP.L	#$00000040,D6
	BNE.W	pt_079F
	MOVEQ	#0,D0
	RTS
pt_07A4:
	MOVEQ	#-1,D0
	RTS
dat_ReturnZeroStub:
	DC.L	$70004e75
pt_BtnSetupTiming:
	BCHG	#0,dat_ModeFlags
	JSR	pt_SetTempo
pt_07A7:
	LEA	(dat_07A9,PC),A0
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_07A8
	LEA	(dat_07AA,PC),A0
pt_07A8:
	MOVEQ	#6,D0
	MOVE.W	#$07e4,D1
	JMP	pt_DrawTextAt
dat_07A9:
	DC.B	"VBLANK"
dat_07AA:
	DC.B	" CIA  "
pt_BtnSetupSpeedUp:
	MOVE.W	dat_PaletteIdxCounter,D1
	ADDQ.B	#1,D1
	CMP.B	#$ff,D1
	BLS.S	pt_InitPaletteState
	MOVE.W	#$00ff,D1
pt_InitPaletteState:
	MOVE.W	D1,dat_PaletteIdxCounter
	MOVE.L	D1,dat_RpSpeed
	BSR.S	pt_07AD
	BSR.W	pt_RefreshDisplay
	BRA.W	pt_RefreshDisplay
pt_07AD:
	MOVE.W	#$0474,dat_TextBytePos
	MOVE.W	dat_PaletteIdxCounter,dat_DisplayParam
	JMP	pt_DrawDecValue3
pt_BtnSetupSpeedDown:
	MOVE.W	dat_PaletteIdxCounter,D1
	SUBQ.B	#1,D1
	CMP.B	#$01,D1
	BCC.S	pt_InitPaletteState
	MOVEQ	#1,D1
	BRA.S	pt_InitPaletteState
pt_BtnSetupTuneNote:
	LEA	dat_DashSeparator,A0
	MOVE.W	#$011c,D0
	MOVEQ	#14,D1
	MOVEQ	#3,D3
	JSR	pt_BlitPatternFull
	MOVE.W	#$0003,dat_ScreenSizeVar
	MOVE.L	#dat_DisplayLineCount,dat_TempBufPtr
	BRA.W	pt_WaitMouseRelease
pt_PalEdDisplay:
	MOVEA.L	dat_NoteNamesPtr,A4
	MOVE.W	dat_DisplayLineCount,D0
	LSL.W	#2,D0
	LEA	(0,A4,D0.W),A0
	MOVE.W	#$011c,D0
	MOVEQ	#14,D1
	MOVEQ	#4,D3
	JSR	pt_BlitPatternFull
	MOVE.W	dat_PalEdEntryIdx,dat_DisplayParam
	MOVE.W	#$0116,D0
	MOVEQ	#25,D1
	JMP	pt_0F9E
pt_BtnSetupTuneVolUp:
	BSR.W	pt_WaitMouseRelease
	ADDQ.W	#1,dat_PalEdEntryIdx
	CMPI.W	#$0040,dat_PalEdEntryIdx
	BMI.S	pt_PalEdAdvClamp
	MOVE.W	#$0040,dat_PalEdEntryIdx
pt_PalEdAdvClamp:
	BRA.S	pt_PalEdDisplay
pt_BtnSetupTuneVolDown:
	BSR.W	pt_WaitMouseRelease
	SUBQ.W	#1,dat_PalEdEntryIdx
	BPL.S	pt_PalEdDecClamp
	CLR.W	dat_PalEdEntryIdx
pt_PalEdDecClamp:
	BRA.S	pt_PalEdDisplay
pt_BtnSetupTuneVol:
	MOVE.W	#$0116,D0
	MOVEQ	#26,D1
	BSR.W	pt_04A4
	MOVE.W	D0,dat_PalEdEntryIdx
	BRA.S	pt_PalEdDisplay
pt_PalEdRotateLeft:
	CLR.W	dat_PalEdGradPending
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVE.W	(A0),D0
	MOVEQ	#48,D1
	SUBQ.W	#2,D1
pt_PalEdRotLeftLoop:
	MOVE.W	(2,A0),(A0)+
	DBF	D1,pt_PalEdRotLeftLoop
	MOVE.W	D0,(A0)
pt_PalEdRedraw:
	BSR.W	pt_GetCursorDigit
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_PalEdDrawCursor
	JMP	pt_CheckDiskOpBusy
pt_PalEdRotateRight:
	CLR.W	dat_PalEdGradPending
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVEQ	#48,D1
	ADDA.W	D1,A0
	ADDA.W	D1,A0
	MOVE.W	-(A0),D0
	SUBQ.W	#2,D1
pt_PalEdRotRightLoop:
	MOVE.W	(-2,A0),(A0)
	SUBQ.L	#2,A0
	DBF	D1,pt_PalEdRotRightLoop
	MOVE.W	D0,(A0)
	BRA.S	pt_PalEdRedraw
pt_PalEdMarkGradient:
	MOVE.W	dat_PalEdCursorPos,dat_PalEdGradStart
	MOVE.W	#$0001,dat_PalEdGradPending
	CLR.W	dat_PalEdCopyPending
	CLR.W	dat_PalEdSwapPending
	RTS
pt_PalEdMarkCopy:
	MOVE.W	dat_PalEdCursorPos,dat_PalEdCopySrc
	MOVE.W	#$0001,dat_PalEdCopyPending
	CLR.W	dat_PalEdSwapPending
	CLR.W	dat_PalEdGradPending
	RTS
pt_PalEdMarkSwap:
	MOVE.W	dat_PalEdCursorPos,dat_PalEdSwapSrc
	MOVE.W	#$0001,dat_PalEdSwapPending
	CLR.W	dat_PalEdCopyPending
	CLR.W	dat_PalEdGradPending
	RTS
dat_PalEdGradStart:
	DS.W	1
dat_PalEdGradPending:
	DS.W	1
dat_PalEdCopySrc:
	DS.W	1
dat_PalEdCopyPending:
	DS.W	1
dat_PalEdSwapSrc:
	DS.W	1
dat_PalEdSwapPending:
	DC.W	$0000
	MOVEA.L	dat_SavedCursorAddr,A0
	MOVE.W	dat_SavedCursorVal,D1
	MOVE.W	(A0),dat_SavedCursorVal
	MOVE.W	D1,(A0)
	BRA.W	pt_PalEdRedraw
pt_PalEdCopyFromMod:
	JSR	pt_SchDefVu
	NOP
pt_PalEdCopyLoop:
	MOVEQ	#48,D0
	BRA.S	pt_PalEdCopyDBF
pt_PalEdCopyWord:
	MOVE.W	(A1)+,(A0)+
pt_PalEdCopyDBF:
	DBF	D0,pt_PalEdCopyWord
	BRA.W	pt_PalEdRedraw
pt_PalEdCopyToAlt:
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVEA.L	A0,A1
	SUBA.L	#dat_PaletteEditBuf,A1
	ADDA.L	#dat_1534,A1
	BRA.S	pt_PalEdCopyLoop
pt_PalEdGetColor:
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVE.W	dat_PalEdCursorPos,D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	RTS
pt_PalEdEditRed:
	BSR.W	pt_GetCursorDigit
	AND.W	#$0f00,D2
	LSR.W	#8,D2
	CMP.B	D2,D0
	BEQ.S	pt_PalEdRedLoop
	AND.W	#$00ff,D1
	LSL.W	#8,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_PalEdDrawCursor
	JSR	pt_CheckDiskOpBusy
pt_PalEdRedLoop:
	LMB
	BEQ.S	pt_PalEdEditRed
	RTS
pt_PalEdEditGreen:
	BSR.W	pt_GetCursorDigit
	AND.W	#$00f0,D2
	LSR.W	#4,D2
	CMP.B	D2,D0
	BEQ.S	pt_PalEdGreenLoop
	AND.W	#$0f0f,D1
	LSL.W	#4,D0
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_PalEdDrawCursor
	JSR	pt_CheckDiskOpBusy
pt_PalEdGreenLoop:
	LMB
	BEQ.S	pt_PalEdEditGreen
	RTS
pt_PalEdEditBlue:
	BSR.W	pt_ScreenDragUpdate
	BSR.W	pt_GetCursorDigit
	AND.W	#$000f,D2
	CMP.B	D2,D0
	BEQ.S	pt_PalEdBlueLoop
	AND.W	#$0ff0,D1
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	BSR.W	pt_DrawEffectDigits
	BSR.W	pt_PalEdDrawCursor
	JSR	pt_CheckDiskOpBusy
pt_PalEdBlueLoop:
	LMB
	BEQ.S	pt_PalEdEditBlue
	RTS
pt_BtnSetupPalBar:
	TST.W	dat_PalEdActive
	BNE.S	pt_PalEdSetActive
	BSR.W	pt_ClearPatternArea
pt_PalEdSetActive:
	MOVE.W	#$ffff,dat_PalEdActive
	MOVEQ	#0,D7
pt_PalEdMainLoop:
	BSR.W	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_PalEdMouseUp
	MOVEQ	#48,D0
	MOVE.W	dat_PalEdSelectPos,D1
	CMP.W	D7,D1
	BEQ.S	pt_PalEdMainLoop
	MOVE.W	D1,D7
	CMP.W	#$0030,D1
	BCC.S	pt_PalEdClampPos
	MOVEQ	#48,D1
pt_PalEdClampPos:
	SUB.W	#$0030,D1
	CMP.W	D0,D1
	BLT.S	pt_PalEdStorePos
	MOVE.W	D0,D1
	SUBQ.W	#1,D1
pt_PalEdStorePos:
	MOVE.W	D1,dat_PalEdCursorPos
	BSR.W	pt_PalEdDrawCursor
	BSR.W	pt_GetCursorDigit
	MOVE.L	A0,dat_SavedCursorAddr
	MOVE.W	D1,dat_SavedCursorVal
	BSR.W	pt_DrawEffectDigits
	BRA.S	pt_PalEdMainLoop
pt_PalEdMouseUp:
	TSTPC.W	dat_PalEdGradPending
	BEQ.W	pt_PalEdCheckCopy
	CLR.W	dat_PalEdGradPending
	BSR.W	pt_GetCursorDigit
	MOVE.W	(dat_PalEdGradStart,PC),D0
	MOVE.W	dat_PalEdCursorPos,D1
	CMP.W	D1,D0
	BCS.S	pt_PalEdCalcRange
	EXG	D0,D1
pt_PalEdCalcRange:
	MOVE.W	D1,D4
	SUB.W	D0,D4
	CMP.W	#$0001,D4
	BHI.S	pt_PalEdGradient
	RTS
pt_PalEdGradient:
	MOVEA.L	D4,A2
	ADD.W	D4,D4
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVEA.L	A0,A1
	ADD.W	D0,D0
	ADD.W	D1,D1
	LEA	(0,A0,D0.W),A0
	MOVE.W	(A0),D2
	LEA	(0,A1,D1.W),A1
	MOVE.W	(A1),D3
	MOVEQ	#0,D5
pt_PalEdGradLoop:
	MOVE.W	D2,D0
	LSR.W	#8,D0
	MOVE.W	D3,D1
	LSR.W	#8,D1
	BSR.S	pt_PalEdInterpolate
	LSL.W	#8,D0
	MOVE.W	D0,D7
	MOVE.W	D2,D0
	LSR.W	#4,D0
	AND.W	#$000f,D0
	MOVE.W	D3,D1
	LSR.W	#4,D1
	AND.W	#$000f,D1
	BSR.S	pt_PalEdInterpolate
	LSL.W	#4,D0
	OR.W	D0,D7
	MOVE.W	D2,D0
	AND.W	#$000f,D0
	MOVE.W	D3,D1
	AND.W	#$000f,D1
	BSR.S	pt_PalEdInterpolate
	OR.W	D0,D7
	ADDQ.W	#2,D5
	MOVE.W	D7,(A0)+
	CMPA.L	A1,A0
	BCS.S	pt_PalEdGradLoop
	BRA.W	pt_PalEdRedraw
pt_PalEdInterpolate:
	MOVE.W	D4,D6
	SUB.W	D5,D6
	MULU	D6,D0
	ADD.L	A2,D0
	MULU	D5,D1
	ADD.W	D1,D0
	DIVU	D4,D0
	CMP.W	#$000f,D0
	BHI.S	pt_PalEdInterpClamp
	RTS
pt_PalEdInterpClamp:
	MOVEQ	#15,D0
	RTS
pt_PalEdCheckCopy:
	TSTPC.W	dat_PalEdCopyPending
	BEQ.S	pt_PalEdCheckSwap
	CLR.W	dat_PalEdCopyPending
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVE.W	(dat_PalEdCopySrc,PC),D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	(A0),D2
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVE.W	(dat_PalEdCursorPos,PC),D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	D2,(A0)
	BRA.W	pt_PalEdRedraw
pt_PalEdCheckSwap:
	TSTPC.W	dat_PalEdSwapPending
	BNE.S	pt_PalEdDoSwap
	RTS
pt_PalEdDoSwap:
	CLR.W	dat_PalEdSwapPending
	MOVEA.L	(dat_PalEdDataPtr,PC),A0
	MOVEA.L	A0,A1
	MOVE.W	(dat_PalEdSwapSrc,PC),D1
	ADD.W	D1,D1
	LEA	(0,A0,D1.W),A0
	MOVE.W	(dat_PalEdCursorPos,PC),D1
	ADD.W	D1,D1
	LEA	(0,A1,D1.W),A1
	MOVE.W	(A0),D2
	MOVE.W	(A1),(A0)
	MOVE.W	D2,(A1)
	BRA.W	pt_PalEdRedraw
pt_PalEdClearRefresh:
	TST.W	dat_PalEdActive
	BNE.W	pt_ClearPatternArea
pt_PalEdRefresh:
	MOVE.W	(dat_PalEdCursorPos,PC),-(A7)
	MOVE.W	#$ffff,dat_PalEdCursorPos
	BSR.S	pt_PalEdDrawCursor
	MOVE.W	(A7)+,dat_PalEdCursorPos
	CLR.W	dat_PalEdGradPending
	CLR.W	dat_PalEdCopyPending
	CLR.W	dat_PalEdSwapPending
	RTS
pt_PalEdDrawCursor:
	JSR	pt_DrawStatusArea
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(3773,A0),A0
	MOVEQ	#0,D1
	MOVE.L	#$0007ff00,D2
	MOVE.W	dat_PalEdCursorPos,D3
pt_PalEdDrawLoop:
	MOVE.L	D2,D0
	CMP.W	D3,D1
	BNE.S	pt_PalEdDrawNormal
	MOVE.L	#$00f7ff78,D0
pt_PalEdDrawNormal:
	MOVE.L	D0,dat_PalEdHighlight0
	MOVE.B	(dat_PalEdHighlight0,PC),(A0)
	MOVE.B	(dat_PalEdHighlight1,PC),(1,A0)
	MOVE.B	(dat_PalEdHighlight2,PC),(2,A0)
	MOVE.B	(dat_PalEdHighlight3,PC),(3,A0)
	LEA	(80,A0),A0
	ADDQ.W	#1,D1
	CMP.W	#$0030,D1
	BCS.S	pt_PalEdDrawLoop
pt_PalEdCopperUpdate:
	LEA	chip_CopperPalEdit,A0
	MOVEA.L	(dat_PalEdDataPtr,PC),A1
	MOVE.W	#$005b,D0
	ADD.W	dat_MouseY,D0
	SUB.W	dat_ScrollOffset,D0
	LSL.W	#8,D0
	OR.B	#$07,D0
	MOVEQ	#47,D1
	MOVEQ	#0,D2
pt_PalEdCopperLoop:
	MOVE.W	D0,(A0)+
	MOVE.W	#$fffe,(A0)+
	MOVE.W	#$01aa,(A0)+
	CMP.W	#$0030,D2
	BCS.S	pt_PalEdCopperColor
	CLR.W	(A0)+
	BRA.S	pt_PalEdCopperNext
pt_PalEdCopperColor:
	MOVE.W	(A1)+,(A0)+
pt_PalEdCopperNext:
	ADD.W	#$0100,D0
	ADDQ.W	#1,D2
	DBF	D1,pt_PalEdCopperLoop
	MOVEQ	#63,D0
pt_07E6:
	MOVE.L	#$01a80000,(A0)+
	DBF	D0,pt_07E6
	RTS
pt_PalEdCopperClear:
	MOVE.B	#$f8,chip_SpritePalEdCtrl
	LEA	chip_CopperPalEdit,A0
	MOVE.W	#$005b,D0
	ADD.W	dat_MouseY,D0
	SUB.W	dat_ScrollOffset,D0
	LSL.W	#8,D0
	OR.B	#$07,D0
	MOVEQ	#47,D1
	MOVEQ	#0,D2
pt_PalEdClearCopLoop:
	MOVE.W	D0,(A0)+
	MOVE.W	#$fffe,(A0)+
	MOVE.W	#$01a8,(A0)+
	CMP.W	#$0030,D2
	BCS.S	pt_PalEdClearCopEntry
	CLR.W	(A0)+
	BRA.S	pt_PalEdClearCopAdv
pt_PalEdClearCopEntry:
	CLR.W	(A0)+
pt_PalEdClearCopAdv:
	ADD.W	#$0100,D0
	ADDQ.W	#1,D2
	DBF	D1,pt_PalEdClearCopLoop
	MOVEQ	#63,D0
pt_PalEdCopperTerm:
	MOVE.L	#$01a80000,(A0)+
	DBF	D0,pt_PalEdCopperTerm
	RTS
dat_PalEdActive:
	DS.W	1
dat_PalEdHighlight0:
	DS.B	1
dat_PalEdHighlight1:
	DS.B	1
dat_PalEdHighlight2:
	DS.B	1
dat_PalEdHighlight3:
	DS.B	1
dat_PalEdCursorPos:
	DS.W	1
dat_PalEdDataPtr:
	DS.L	1
pt_BtnScreenDrag:
	MOVE.W	#$ffff,dat_MouseState
	CLR.L	dat_MouseDelta
pt_PalEdDragLoop:
	LMB
	BNE.S	pt_PalEdDragEnd
	TST.L	dat_MouseDelta
	BEQ.S	pt_PalEdDragLoop
	MOVEM.W	dat_MouseDelta,D0-D1
	CLR.L	dat_MouseDelta
	ADD.W	D0,dat_MouseX
	ADD.W	D1,dat_MouseY
	BSR.S	pt_ScrollDisplay
	BRA.S	pt_PalEdDragLoop
pt_PalEdDragEnd:
	CLR.L	dat_MouseDelta
	CLR.W	dat_MouseState
	RTS
pt_ScrollDisplay:
	MOVE.W	(dat_MouseX,PC),D0
	CMP.W	#$fff0,D0
	BPL.S	pt_ScrollClampXMin
	MOVEQ	#-16,D0
pt_ScrollClampXMin:
	CMP.W	#$000f,D0
	BMI.S	pt_ScrollClampXMax
	MOVEQ	#15,D0
pt_ScrollClampXMax:
	MOVE.W	(dat_MouseY,PC),D1
	CMP.W	#$fff3,D1
	BPL.S	pt_ScrollClampYMin
	MOVEQ	#-13,D1
pt_ScrollClampYMin:
	CMP.W	#$000d,D1
	BMI.S	pt_ScrollClampYMax
	MOVEQ	#13,D1
pt_ScrollClampYMax:
	MOVE.W	D0,dat_MouseX
	MOVE.W	D1,dat_MouseY
	BSR.W	pt_CalcScrollBitplane
	MOVE.W	(dat_MouseX,PC),D0
	MOVE.W	D0,D1
	ADD.W	#$0081,D1
	MOVE.B	D1,chip_SpriteXPos0
	ADD.W	#$0040,D1
	MOVE.B	D1,chip_SpriteXPos1
	MOVE.W	D0,D1
	AND.W	#$000f,D1
	MOVE.W	D1,D2
	LSL.W	#4,D2
	OR.W	D2,D1
	MOVE.W	D1,chip_SpriteColor0
	MOVE.W	D0,D1
	AND.W	#$fff8,D1
	LSR.W	#1,D1
	ADD.W	#$003c,D1
	MOVE.W	D1,chip_SpriteBplPtr0
	ADD.W	#$0098,D1
	MOVE.W	D1,chip_SpriteBplPtr1
	MOVE.W	(dat_MouseY,PC),D1
	MOVEQ	#44,D2
	ADD.W	D1,D2
	MOVE.W	D2,D3
	MOVE.B	D2,chip_SpriteYPos0
	MOVE.B	D2,chip_SpriteYPos2
	BTST	#0,dat_UICheckFlag
	BEQ.S	pt_ScrollApplyYOfs
	SUB.W	#$0032,D2
pt_ScrollApplyYOfs:
	MOVE.B	D2,chip_SpriteYPos1
	SUB.W	(dat_ScrollOffset,PC),D1
	SUB.W	(dat_ScrollOffset,PC),D3
	MOVE.W	D3,dat_0FDA
	MOVEQ	#88,D2
	ADD.W	D1,D2
	MOVE.B	D2,chip_SpriteYPos3
	MOVEQ	#125,D2
	ADD.W	D0,D2
	MOVE.W	D2,dat_0FDB
	JSR	pt_UpdateMousePos
	BSR.W	pt_067C
	TST.W	dat_SamplerActive
	BNE.S	pt_07FD
	MOVE.W	(dat_MouseY,PC),D1
	SUB.W	(dat_ScrollOffset,PC),D1
	MOVE.W	#$00bb,D2
	ADD.W	D1,D2
	MOVE.B	D2,chip_CopperWaitLine
	MOVE.W	#$00c2,D2
	ADD.W	D1,D2
	MOVE.B	D2,dat_14A8
	MOVE.W	#$00f0,D2
	ADD.W	D1,D2
	MOVE.B	D2,dat_14AC
	MOVE.W	#$0129,D2
	ADD.W	D1,D2
	MOVE.B	D2,dat_14AE
	MOVE.W	#$01fe,D0
	CMP.W	#$0100,D2
	BMI.S	pt_07FC
	MOVE.W	#$ffdf,D0
pt_07FC:
	MOVE.W	D0,dat_14AD
pt_07FD:
	JSR	pt_SetIsP1
	NOP
	BNE.S	pt_07FE
	BSR.W	pt_PalEdCopperUpdate
	JSR	pt_DrawStatusArea
	BRA.S	pt_07FF
pt_07FE:
	BSR.W	pt_PalEdCopperClear
pt_07FF:
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_0800
	JSR	pt_ScanButtonHitbox
pt_0800:
	BSR.S	pt_0803
	TST.W	dat_SamplerActive
	BNE.S	pt_0801
	MOVE.W	(dat_MouseY,PC),D1
	SUB.W	(dat_ScrollOffset,PC),D1
	JSR	pt_CheckDiskOpBusy
	BRA.S	pt_0802
pt_0801:
	MOVE.W	(dat_MouseY,PC),D1
	SUB.W	(dat_ScrollOffset,PC),D1
	MOVE.W	#$00b6,D2
	ADD.W	D1,D2
	MOVE.B	D2,chip_CopperWaitLine
	JSR	pt_DrawBorderLeft
pt_0802:
	BSR.W	pt_DrawPlayCounter
	BSR.S	pt_InitCopperColors
	RTS
pt_0803:
	JSR	pt_InitPalettes
	BSR.W	pt_ReturnFromPlay
	JSR	pt_PatViewSetRow
	RTS
pt_DrawStatusArea:
	LEA	chip_SpriteStatusBar,A0
	MOVEQ	#59,D0
	JSR	pt_SetIsP1
	NOP
	BEQ.S	pt_0805
	MOVEQ	#-32,D0
pt_0805:
	MOVEQ	#47,D1
	MOVEQ	#48,D2
	JSR	pt_DrawSprite
	RTS
pt_InitCopperColors:
	MOVEA.L	dat_GfxLibBase,A6
	MOVE.W	(164,A6),D1
	MOVE.W	#$f014,D2
	AND.W	D2,chip_SpriteCtrlWord2
	OR.W	D1,chip_SpriteCtrlWord2
	TST.W	dat_SamplerActive
	BNE.S	pt_0807
	AND.W	D2,chip_CopperColor4
	OR.W	D1,chip_CopperColor4
	AND.W	D2,chip_CopperColor7Pal
	OR.W	D1,chip_CopperColor7Pal
	AND.W	D2,chip_CopperPalette4
	OR.W	D1,chip_CopperPalette4
pt_0807:
	RTS
pt_CalcScrollBitplane:
	MOVE.W	(dat_ScrollOffset,PC),D1
	MULU	#$0050,D1
	MOVE.L	#SECSTRT_2,D0
	ADD.L	D1,D0
	LEA	chip_CopperBplPtrs,A1
	MOVE.W	D0,(6,A1)
	SWAP	D0
	MOVE.W	D0,(2,A1)
	SWAP	D0
	ADD.L	#$00005000,D0
	MOVE.W	D0,(14,A1)
	SWAP	D0
	MOVE.W	D0,(10,A1)
	MOVE.L	#chip_ScreenBitplanes2,D0
	ADD.L	D1,D0
	MOVE.W	D0,dat_1495
	SWAP	D0
	MOVE.W	D0,dat_1494
	RTS
pt_ScreenDragUpdate:
	JSR	pt_MixTaskPoll
	IFD	DEBUGAUTO
	JSR	dbg_AutoStep
	ENDC
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.W	dat_ScrollDelta
	BEQ.S	pt_DisplayDone
	BTST	#0,dat_UICheckFlag
	BEQ.S	pt_ScrollClear
	MOVE.W	(dat_ScrollDelta,PC),D0
	CLR.W	dat_ScrollDelta
	ADD.W	D0,dat_ScrollOffset
	BPL.S	pt_ScrollClampMin
	CLR.W	dat_ScrollOffset
pt_ScrollClampMin:
	CMPI.W	#$0032,dat_ScrollOffset
	BMI.S	pt_ScrollClampMax
	MOVE.W	#$0032,dat_ScrollOffset
pt_ScrollClampMax:
	BSR.W	pt_ScrollDisplay
	BRA.S	pt_DisplayDone
pt_ScrollClear:
	CLR.W	dat_ScrollDelta
	CLR.W	dat_ScrollOffset
pt_DisplayDone:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_MouseState:
	DS.W	1
dat_MouseX:
	DS.W	1
dat_MouseY:
	DS.W	1
dat_ScrollOffset:
	DS.W	1
dat_ScrollDelta:
	DS.W	1
pt_FreeOldSample:
	MOVE.L	dat_OldSamplePtr,D0
	BNE.S	pt_DoFreeSample
	RTS
pt_DoFreeSample:
	MOVEA.L	D0,A1
	MOVE.L	dat_OldSampleSize,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_OldSamplePtr
	RTS
pt_FreeUndoBuf:
	MOVE.L	dat_UndoBufPtr,D0
	BNE.S	pt_DoFreeUndo
	RTS
pt_DoFreeUndo:
	MOVEA.L	D0,A1
	MOVE.L	dat_UndoBufSize,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_UndoBufPtr
	RTS
pt_0817:
	MOVE.L	dat_UndoHeader,D0
	BNE.S	pt_0818
	RTS
pt_0818:
	MOVEA.L	D0,A1
	MOVE.L	dat_12A2,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_UndoHeader
	RTS
pt_StoreModulePtr:
	MOVE.L	A0,dat_081E
	MOVE.L	dat_OldSamplePtr,D0
	BEQ.S	pt_081A
	MOVEA.L	D0,A1
	BSR.S	pt_081B
	BRA.S	pt_FreeOldSample
pt_081A:
	MOVEA.L	dat_081E,A0
	BSR.W	pt_0824
	BNE.S	pt_081B
	RTS
pt_081B:
	LEA	SECSTRT_2,A0
	MOVEQ	#1,D2
	MOVEQ	#0,D3
pt_081C:
	MOVE.W	#$0973,D0
pt_081D:
	MOVE.L	(A0),D1
	MOVE.L	(A1),(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,pt_081D
	LEA	(10800,A0),A0
	DBF	D2,pt_081C
	MOVEQ	#0,D0
	RTS
dat_081E:
	DS.L	1
pt_CheckModuleTypeWrap:
	BSR.W	pt_LoadIFFGraphic
	BNE.S	pt_0820
	RTS
pt_0820:
	LEA	dat_148D,A0
	MOVEQ	#1,D2
	MOVEQ	#0,D3
	MOVEQ	#1,D2
pt_0821:
	MOVE.W	#$0937,D0
pt_0822:
	MOVE.L	(A1)+,(A0)+
	DBF	D0,pt_0822
	LEA	(11040,A0),A0
	DBF	D2,pt_0821
	MOVEQ	#0,D0
	BSR.W	pt_FreeUndoBuf
	TST.L	dat_AllocBufPtr
	BEQ.S	pt_0823
	JMP	pt_LoadAllocBuf
pt_0823:
	RTS
pt_0824:
	CMPI.L	#$494d5021,(A0)
	BNE.S	pt_0825
	BSR.W	pt_CheckAllocBuf
pt_0825:
	MOVE.L	A0,dat_FileIOBufPtr
	BSR.W	pt_FileIOBufAccess
	MOVE.W	(dat_FileIOStatus,PC),D0
	MULU	(dat_ModuleTimeout,PC),D0
	MULU	(dat_IFFParsePtr,PC),D0
	MOVE.L	D0,dat_OldSampleSize
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_OldSamplePtr
	BEQ.W	pt_SampleMixStart
	MOVE.L	D0,dat_MemAllocSize
	BSR.W	pt_FileHeaderRead
	BSR.W	pt_FileParseLoop
	TST.L	dat_AllocBufPtr
	BEQ.S	pt_0826
	BSR.W	pt_LoadAllocBuf
pt_0826:
	MOVEA.L	dat_OldSamplePtr,A1
	MOVEQ	#-1,D0
	RTS
pt_0827:
	CMPI.L	#$494d5021,(A0)
	BNE.S	pt_0828
	BSR.W	pt_CheckAllocBuf
pt_0828:
	MOVE.L	dat_FileIOBufPtr,dat_FileHeaderPtr
	MOVE.L	A0,dat_FileIOBufPtr
	BSR.W	pt_FileIOBufAccess
	MOVE.W	(dat_FileIOStatus,PC),D0
	MULU	(dat_ModuleTimeout,PC),D0
	MULU	(dat_IFFParsePtr,PC),D0
	MOVE.L	D0,dat_12A2
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_UndoHeader
	BEQ.W	pt_SampleMixStart
	MOVE.L	D0,dat_MemAllocSize
	BSR.W	pt_FileHeaderRead
	BSR.W	pt_FileParseLoop
	TST.L	dat_AllocBufPtr
	BEQ.S	pt_0829
	BSR.W	pt_LoadAllocBuf
pt_0829:
	MOVEA.L	dat_UndoHeader,A1
	MOVE.L	dat_FileHeaderPtr,dat_FileIOBufPtr
	MOVEQ	#-1,D0
	RTS
	SHIFTPAD	2
pt_LoadIFFGraphic:
	CMPI.L	#$494d5021,(A0)
	BNE.S	pt_082B
	BSR.W	pt_CheckAllocBuf
pt_082B:
	MOVE.L	dat_FileIOBufPtr,dat_FileHeaderPtr
	MOVE.L	A0,dat_FileIOBufPtr
	BSR.W	pt_FileIOBufAccess
	MOVE.W	(dat_FileIOStatus,PC),D0
	MULU	(dat_ModuleTimeout,PC),D0
	MULU	(dat_IFFParsePtr,PC),D0
	MOVE.L	D0,dat_UndoBufSize
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_UndoBufPtr
	BEQ.W	pt_SampleMixStart
	MOVE.L	D0,dat_MemAllocSize
	BSR.W	pt_FileHeaderRead
	BSR.W	pt_FileParseLoop
	TST.L	dat_AllocBufPtr
	BEQ.S	pt_082C
	BSR.W	pt_LoadAllocBuf
pt_082C:
	MOVEA.L	dat_UndoBufPtr,A1
	MOVE.L	dat_FileHeaderPtr,dat_FileIOBufPtr
	MOVEQ	#-1,D0
	RTS
	BSR.W	pt_FileIOBufAccess
	BSR.W	pt_FileHeaderRead
	BSR.W	pt_FileParseLoop
	RTS
dat_082D:
	DC.W	$0140
dat_ModuleTimeout:
	DC.W	$00c8
dat_082F:
	DC.L	$12345678
dat_0830:
	DS.L	6
dat_MemAllocSize:
	DC.L	$00040000
dat_0832:
	DS.L	32
pt_FileIOBufAccess:
	MOVEA.L	(dat_FileIOBufPtr,PC),A0
	ADDA.W	#$000c,A0
	MOVE.L	A0,dat_FileInfoPtr
	MOVE.L	(4,A0),D0
	ADDA.L	D0,A0
	ADDQ.L	#8,A0
	MOVE.L	A0,dat_0849
pt_0834:
	MOVE.L	(4,A0),D0
	ADDA.L	D0,A0
	ADDQ.L	#8,A0
	MOVE.L	#$424f4459,D1
	CMP.L	(A0),D1
	BNE.S	pt_0834
	MOVE.L	A0,dat_084A
	MOVEA.L	(dat_FileInfoPtr,PC),A2
	MOVEA.L	A2,A1
	ADDA.W	#$0010,A1
	MOVEQ	#0,D0
	MOVE.B	(A1),D0
	CMP.W	#$0006,D0
	BLT.S	pt_0835
	MOVEQ	#6,D0
pt_0835:
	MOVE.W	D0,dat_IFFParsePtr
	MOVEA.L	A2,A1
	ADDA.W	#$0012,A1
	MOVE.B	(A1),dat_084C
	MOVEA.L	A2,A1
	ADDQ.L	#8,A1
	MOVEQ	#0,D0
	MOVE.W	(A1)+,D0
	MOVE.W	D0,dat_082D
	MOVEQ	#0,D3
	CMP.W	#$0280,D0
	BLT.S	pt_0836
	OR.W	#$8000,D3
pt_0836:
	MOVE.W	D0,D1
	AND.W	#$0007,D1
	BEQ.S	pt_0837
	OR.W	#$0008,D0
pt_0837:
	LSR.W	#3,D0
	MOVE.W	D0,dat_FileIOStatus
	MOVEQ	#0,D0
	MOVE.W	(A1),D0
	MOVE.W	D0,dat_ModuleTimeout
	CMP.W	#$0190,D0
	BLT.S	pt_0838
	OR.W	#$0004,D3
pt_0838:
	MOVE.W	D3,dat_082F
	RTS
