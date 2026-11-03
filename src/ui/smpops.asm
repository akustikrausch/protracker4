pt_BtnOpt2From:
	MOVE.W	dat_CurrentSample,D2
	BRA.S	pt_SetUISelectIdx
pt_BtnOpt2FromDown:
	MOVE.B	(dat_UISelectIdx,PC),D2
	SUBQ.B	#1,D2
	BPL.S	pt_SetUISelectIdx
	MOVEQ	#0,D2
pt_SetUISelectIdx:
	MOVE.B	D2,dat_UISelectIdx
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_0C97
pt_BtnOpt2FromUp:
	MOVE.B	(dat_UISelectIdx,PC),D2
	ADDQ.B	#1,D2
	CMP.B	#$1f,D2
	BLS.S	pt_SetUISelectIdx
	MOVE.B	#$1f,dat_UISelectIdx
pt_0C97:
	MOVE.W	#$1ca3,dat_TextBytePos
	CLR.W	dat_DisplayParam
	MOVE.B	(dat_UISelectIdx,PC),dat_ButtonStateFlag
	BRA.W	pt_DrawDecValue3
pt_BtnOpt2To:
	MOVE.W	dat_CurrentSample,D2
	BRA.S	pt_SetUISelectMax
pt_BtnOpt2ToDown:
	MOVE.B	(dat_UISelectMax,PC),D2
	SUBQ.B	#1,D2
	BPL.S	pt_SetUISelectMax
	MOVEQ	#0,D2
pt_SetUISelectMax:
	MOVE.B	D2,dat_UISelectMax
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_0C9C
pt_BtnOpt2ToUp:
	MOVE.B	(dat_UISelectMax,PC),D2
	ADDQ.B	#1,D2
	CMP.B	#$1f,D2
	BLS.S	pt_SetUISelectMax
	MOVE.B	#$1f,dat_UISelectMax
pt_0C9C:
	MOVE.W	#$2013,dat_TextBytePos
	CLR.W	dat_DisplayParam
	MOVE.B	(dat_UISelectMax,PC),dat_ButtonStateFlag
	BRA.W	pt_DrawDecValue3
dat_UISelectIdx:
	DS.B	1
dat_UISelectMax:
	DS.B	1
pt_BtnOpt1RecordMode:
	JSR	pt_WaitMouseRelease
	EORI.B	#$01,dat_PlaybackModeFlag
pt_0CA0:
	MOVE.W	#$0246,D0
	MOVEQ	#69,D1
	MOVEQ	#7,D3
	LEA	(dat_0CA2,PC),A0
	TST.B	dat_PlaybackModeFlag
	BEQ.S	pt_0CA1
	LEA	(dat_0CA3,PC),A0
pt_0CA1:
	JMP	pt_BlitPatternRow
dat_0CA2:
	DC.B	"Pattern"
dat_0CA3:
	DC.B	"Song   "
dat_PlaybackModeFlag:
	DS.B	1
dat_PatSyncStep:
	DC.B	$01
dat_RpMetroInterval:
	DC.B	$04
dat_RpMetroChannel:
	DS.B	1
dat_PlaybackRunning:
	DS.B	1
dat_PlaybackState:
	DC.B	$ff
dat_PalCyclePhase:
	DS.W	1
dat_PaletteDirtyFlag:
	DS.W	1
pt_UpdateSampleListUI:
	MOVE.W	#$0001,dat_PaletteDirtyFlag
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	JSR	pt_DrawPlayCounter
	BSR.W	pt_UIRefreshLoop
	CMP.B	#$44,D1
	BEQ.S	pt_0CAD
	MOVE.B	D1,D0
	MULU	#$000a,D0
	MOVE.B	D0,dat_SampleEditValue
	BSR.W	pt_ConvertDecChar
	ADDQ.W	#8,dat_PlayCounter
	JSR	pt_DrawPlayCounter
	BSR.W	pt_UIRefreshLoop
	CMP.B	#$44,D1
	BEQ.S	pt_0CAD
	ADD.B	D1,dat_SampleEditValue
	CLR.W	dat_PaletteDirtyFlag
pt_0CAD:
	MOVE.W	#$fff0,dat_PlayCounter
	CLR.W	dat_PatternDelay
	JSR	pt_DrawPlayCounter
	JSR	pt_RestorePalette
	MOVEQ	#0,D0
	MOVE.B	dat_SampleEditValue,D0
	RTS
pt_0CAE:
	MOVE.W	#$0001,dat_PaletteDirtyFlag
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	JSR	pt_DrawPlayCounter
	BSR.W	pt_UIRefreshLoop
	CMP.B	#$44,D1
	BEQ.S	pt_0CAF
	MOVE.B	D1,D0
	MULU	#$000a,D0
	MOVE.B	D0,dat_SampleEditValue
	MOVE.L	D1,D3
	MOVE.W	D4,D0
	MOVE.W	D5,D1
	BSR.W	pt_0933
	MOVE.L	D3,D1
	ADDQ.W	#8,dat_PlayCounter
	JSR	pt_DrawPlayCounter
	BSR.W	pt_UIRefreshLoop
	CMP.B	#$44,D1
	BEQ.S	pt_0CAF
	ADD.B	D1,dat_SampleEditValue
	CLR.W	dat_PaletteDirtyFlag
pt_0CAF:
	MOVE.W	#$fff0,dat_PlayCounter
	CLR.W	dat_PatternDelay
	JSR	pt_DrawPlayCounter
	JSR	pt_RestorePalette
	MOVE.B	dat_SampleEditValue,D0
	RTS
pt_BtnOpt1QuantizeUp:
	BSR.W	pt_RefreshDisplay
	MOVEQ	#0,D0
	MOVE.B	(dat_PatSyncStep,PC),D0
	ADDQ.W	#1,D0
	BRA.S	pt_0CB4
pt_BtnOpt1QuantizeDown:
	BSR.W	pt_RefreshDisplay
	MOVEQ	#0,D0
	MOVE.B	(dat_PatSyncStep,PC),D0
	SUBQ.W	#1,D0
	BPL.S	pt_0CB2
	MOVEQ	#0,D0
pt_0CB2:
	BRA.S	pt_0CB4
pt_BtnOpt1Quantize:
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$003f,dat_PatternDelay
	MOVE.W	#$1256,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TSTPC.W	dat_PaletteDirtyFlag
	BNE.S	pt_0CB6
pt_0CB4:
	CMP.B	#$3f,D0
	BLS.S	pt_0CB5
	MOVEQ	#63,D0
pt_0CB5:
	MOVE.B	D0,dat_PatSyncStep
pt_0CB6:
	MOVE.W	#$1256,dat_TextBytePos
	CLR.W	dat_DisplayParam
	MOVE.B	(dat_PatSyncStep,PC),dat_ButtonStateFlag
	BRA.W	pt_Format2DigitHex
pt_BtnOpt1Metronome:
	CMP.W	#$01c2,D0
	BCC.S	pt_0CB9
	MOVE.W	#$1936,dat_TextBytePos
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$0055,dat_PatternDelay
	BSR.W	pt_UpdateSampleListUI
	TSTPC.W	dat_PaletteDirtyFlag
	BNE.S	pt_ShowDisplayField
	CMP.B	#$40,D0
	BLS.S	pt_0CB8
	MOVEQ	#64,D0
pt_0CB8:
	MOVE.B	D0,dat_RpMetroInterval
	BRA.S	pt_ShowDisplayField
pt_0CB9:
	MOVE.W	#$1939,dat_TextBytePos
	JSR	pt_ClearPatternKey
	CMP.W	#$0004,D0
	BLS.S	pt_0CBA
	MOVEQ	#4,D0
pt_0CBA:
	MOVE.B	D0,dat_RpMetroChannel
pt_ShowDisplayField:
	MOVE.W	#$1936,dat_TextBytePos
	CLR.W	dat_DisplayParam
	MOVE.B	(dat_RpMetroInterval,PC),dat_ButtonStateFlag
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$1939,dat_TextBytePos
	CLR.W	dat_DisplayParam
	MOVE.B	(dat_RpMetroChannel,PC),dat_ButtonStateFlag
	BRA.W	pt_Format2DigitHex
pt_BtnOpt1PlayNote:
	JSR	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	EORI.B	#$01,dat_PlaybackRunning
pt_0CBD:
	BSR.W	pt_LoadSpaceCharCode
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_0CC0
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_0CC0
	CMPI.W	#$0001,dat_OptPage
	BEQ.S	pt_0CBE
	RTS
pt_0CBE:
	MOVE.W	#$0246,D0
	MOVEQ	#80,D1
	MOVEQ	#6,D3
	LEA	(dat_0CCF,PC),A0
	TSTPC.B	dat_PlaybackRunning
	BEQ.S	pt_0CBF
	LEA	(dat_0CCE,PC),A0
pt_0CBF:
	BSR.W	pt_BlitPatternRow
pt_0CC0:
	JMP	pt_0316
pt_BtnOpt1Insert:
	JSR	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	EORI.B	#$01,dat_InputSplitMode
pt_0CC2:
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_DrawInputSplit
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_DrawInputSplit
	CMPI.W	#$0001,dat_OptPage
	BEQ.S	pt_0CC3
	BRA.S	pt_DrawInputSplit
pt_0CC3:
	MOVE.W	#$0246,D0
	MOVEQ	#102,D1
	MOVEQ	#6,D3
	LEA	(dat_0CD0,PC),A0
	TST.B	dat_InputSplitMode
	BEQ.S	pt_0CC4
	LEA	(dat_0CD1,PC),A0
pt_0CC4:
	BSR.W	pt_BlitPatternRow
pt_DrawInputSplit:
	MOVE.B	#$20,D0
	TST.B	dat_InputSplitMode
	BEQ.S	pt_0CC6
	MOVE.B	#$49,D0
pt_0CC6:
	MOVE.B	D0,dat_0CC7
	MOVE.W	#$2803,D1
	MOVEQ	#1,D0
	LEA	(dat_0CC7,PC),A0
	BRA.W	pt_DrawTextAt
dat_0CC7:
	DS.B	1
dat_InputSplitMode:
	DS.B	1
pt_BtnOpt1Split:
	JSR	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	BCHG	#4,dat_InputReadyFlag
pt_0CCA:
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_0CCD
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_0CCD
	CMPI.W	#$0001,dat_OptPage
	BEQ.S	pt_0CCB
	JMP	pt_LoadSpaceCharCode
pt_0CCB:
	MOVE.W	#$0246,D0
	MOVEQ	#113,D1
	MOVEQ	#7,D3
	LEA	(dat_0CD3,PC),A0
	BTST	#4,dat_InputReadyFlag
	BEQ.S	pt_0CCC
	LEA	(dat_0CD2,PC),A0
pt_0CCC:
	BSR.W	pt_BlitPatternRow
pt_0CCD:
	JMP	pt_LoadSpaceCharCode
dat_0CCE:
	DC.B	"MULTI ",0
dat_0CCF:
	DC.B	"SINGLE",0
dat_0CD0:
	DC.B	"NOINS.",0
dat_0CD1:
	DC.B	"INSERT",0
dat_0CD2:
	DC.B	"SPLIT  ",0,0
dat_0CD3:
	DC.B	"NOSPLIT",0,0
pt_LoadSpaceCharCode:
	MOVE.B	#$20,D0
	TSTPC.B	dat_PlaybackRunning
	BEQ.S	pt_0CD5
	MOVE.B	#$4d,D0
pt_0CD5:
	MOVE.B	#$20,D1
	BTST	#4,dat_InputReadyFlag
	BEQ.S	pt_0CD6
	MOVE.B	#$53,D1
pt_0CD6:
	MOVE.B	D0,dat_0CD7
	MOVE.B	D1,dat_0CD8
	MOVE.W	#$2801,D1
	MOVEQ	#2,D0
	LEA	(dat_0CD7,PC),A0
	BSR.W	pt_DrawTextAt
	BRA.W	pt_DrawInputSplit
dat_0CD7:
	DC.B	$5f
dat_0CD8:
	DC.B	$5f
pt_BtnOpt2Clip:
	JSR	pt_WaitMouseRelease
	EORI.B	#$01,dat_SampleEditFlag
pt_0CDA:
	MOVE.W	#$0251,D0
	MOVEQ	#58,D1
	MOVEQ	#6,D3
	TST.B	dat_SampleEditFlag
	BEQ.S	pt_0CDB
	LEA	(dat_0CDC,PC),A0
	JMP	pt_BlitPatternRow
pt_0CDB:
	LEA	(dat_0CDD,PC),A0
	JMP	pt_BlitPatternRow
dat_0CDC:
	DC.B	" Half "
dat_0CDD:
	DC.B	" Clip "
pt_BtnOpt2Pos:
	MOVE.L	(dat_SampleEditOffset,PC),D2
	BRA.S	pt_SetSampleEditOfs
pt_BtnOpt2PosDown:
	MOVE.L	(dat_SampleEditOffset,PC),D2
	SUBQ.L	#1,D2
	RMB
	BNE.S	pt_0CE0
	SUB.L	#$0000000f,D2
pt_0CE0:
	BPL.S	pt_SetSampleEditOfs
	MOVEQ	#0,D2
pt_SetSampleEditOfs:
	MOVE.L	D2,dat_SampleEditOffset
	BRA.S	pt_CheckEditModeType
pt_BtnOpt2PosUp:
	MOVE.L	(dat_SampleEditOffset,PC),D2
	ADDQ.L	#1,D2
	RMB
	BNE.S	pt_0CE3
	ADD.L	#$0000000f,D2
pt_0CE3:
	MOVEQ	#0,D3
	MOVE.W	(s_length,A5),D3
	LSL.L	#1,D3
	CMP.L	D3,D2
	BLS.S	pt_SetSampleEditOfs
	MOVE.L	D3,dat_SampleEditOffset
pt_CheckEditModeType:
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_SetDisplayMode2
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_SetDisplayMode2
	CMPI.W	#$0006,dat_UIMode
	BEQ.S	pt_SetDisplayMode2
	CMPI.W	#$0008,dat_UIMode
	BEQ.S	pt_SetDisplayMode2
	BRA.S	pt_0CE7
pt_SetDisplayMode2:
	CMPI.W	#$0002,dat_OptPage
	BNE.S	pt_0CE7
	MOVE.W	#$15d9,dat_TextBytePos
	MOVE.W	(dat_0DB0,PC),dat_DisplayParam
	LEA	dat_ScopeDisplayBuf,A0
	CMPA.L	dat_DiskOpFilesPtr,A0
	BNE.S	pt_0CE6
	CLR.W	dat_DisplayParam
pt_0CE6:
	BSR.W	pt_DrawDecValue2
pt_0CE7:
	TST.W	dat_SamplerActive
	BEQ.S	pt_0CEC
	MOVE.L	(dat_SampleEditOffset,PC),D2
	LEA	dat_ScopeDisplayBuf,A0
	CMPA.L	dat_DiskOpFilesPtr,A0
	BNE.S	pt_0CE8
	MOVEQ	#0,D2
pt_0CE8:
	MOVE.W	#$01a8,D0
	MOVE.W	#$00e2,D1
	MOVEQ	#7,D3
	BSR.W	pt_BlitPatternSetup
	MOVE.L	(dat_DiskOpBufSize,PC),D2
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BPL.S	pt_0CE9
	MOVEQ	#0,D0
	MOVEQ	#0,D2
pt_0CE9:
	SUB.L	D0,D2
	BPL.S	pt_0CEA
	NEG.L	D2
pt_0CEA:
	LEA	dat_ScopeDisplayBuf,A0
	CMPA.L	dat_DiskOpFilesPtr,A0
	BNE.S	pt_0CEB
	MOVEQ	#0,D2
pt_0CEB:
	MOVE.W	#$01a8,D0
	MOVE.W	#$00ed,D1
	MOVEQ	#7,D3
	BSR.W	pt_BlitPatternSetup
pt_0CEC:
	RTS
pt_BtnOpt2ModValue:
	MOVEQ	#0,D2
	RMB
	BEQ.S	pt_SetSampleEdMode
	MOVE.B	dat_SampleEditorMode,D2
	BRA.S	pt_SetSampleEdMode
pt_BtnOpt2ModDown:
	MOVE.B	dat_SampleEditorMode,D2
	SUBQ.B	#1,D2
	CMP.B	#$7f,D2
	BNE.S	pt_SetSampleEdMode
	MOVE.B	#$80,D2
	BRA.S	pt_SetSampleEdMode
pt_BtnOpt2ModUp:
	MOVE.B	dat_SampleEditorMode,D2
	ADDQ.B	#1,D2
	CMP.B	#$80,D2
	BNE.S	pt_SetSampleEdMode
	MOVEQ	#127,D2
pt_SetSampleEdMode:
	MOVE.B	D2,dat_SampleEditorMode
	BSR.W	pt_RefreshDisplay
pt_0CF1:
	LEA	(dat_0CF3,PC),A0
	MOVEQ	#0,D6
	MOVE.B	dat_SampleEditorMode,D6
	BPL.S	pt_0CF2
	NEG.B	D6
	ADDQ.L	#1,A0
pt_0CF2:
	MOVEQ	#1,D0
	MOVE.W	#$1949,D1
	BSR.W	pt_DrawTextAt
	MOVE.W	D6,dat_DisplayParam
	BRA.W	pt_DrawTempoStr
dat_0CF3:
	DC.W	$202d
pt_BtnOpt2Mod:
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D2
	MOVE.W	dat_EffectData0,D2
	BNE.S	pt_0CF5
	JMP	pt_RestorePaletteInit
pt_0CF5:
	ADD.L	D2,D2
	SUBQ.L	#1,D2
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0CF6
	JMP	pt_RestorePaletteInit
pt_0CF6:
	BSR.W	pt_0D56
	MOVEA.L	D0,A2
	MOVEA.L	D0,A3
	MOVEA.L	A1,A4
	ADDA.L	D2,A3
	CLR.L	dat_SampleBufOffset1
	CLR.L	dat_SampleBufOffset0
pt_0CF7:
	CMPA.L	A3,A2
	BCC.S	pt_0CF8
	MOVE.B	(A1),(A2)+
	BSR.S	pt_CheckSampEdMode
	BRA.S	pt_0CF7
pt_0CF8:
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
	BSR.W	pt_0D58
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_CheckSampEdMode:
	MOVE.B	(dat_SampleEditorMode,PC),D0
	BEQ.S	pt_0CFE
	EXT.W	D0
	EXT.L	D0
	MOVE.L	(dat_SampleBufOffset0,PC),D1
	ADD.L	D0,D1
	MOVE.L	D1,dat_SampleBufOffset0
	ASR.L	#8,D1
	ASR.L	#4,D1
	MOVE.L	D1,D3
	AND.W	#$001f,D1
	LEA	dat_RpVibratoTable,A0
	MOVEQ	#0,D0
	MOVE.B	(0,A0,D1.W),D0
	LSR.B	#2,D0
	MOVE.L	(dat_SampleBufOffset1,PC),D1
	BTST	#5,D3
	BEQ.S	pt_0CFA
	SUB.L	D0,D1
	BRA.S	pt_0CFB
pt_0CFA:
	ADD.L	D0,D1
pt_0CFB:
	ADD.L	#$00000800,D1
	MOVE.L	D1,dat_SampleBufOffset1
	ASR.L	#8,D1
	ASR.L	#3,D1
	BPL.S	pt_0CFC
	MOVEQ	#0,D1
pt_0CFC:
	CMP.L	D2,D1
	BCS.S	pt_0CFD
	MOVE.L	D2,D1
pt_0CFD:
	MOVEA.L	A4,A1
	ADDA.L	D1,A1
	RTS
pt_0CFE:
	ADDQ.L	#1,A1
	RTS
pt_BtnOpt2CutBeg:
	CMP.W	#$011b,D0
	BHI.W	pt_BtnOpt2FadeDown
	CMP.W	#$0103,D0
	BHI.S	pt_BtnOpt2FadeUp
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D3
	MOVE.W	dat_EffectData0,D3
	BNE.S	pt_0D00
	JMP	pt_RestorePaletteInit
pt_0D00:
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D01
	JMP	pt_RestorePaletteInit
pt_0D01:
	MOVEA.L	D0,A1
	MOVEA.L	D0,A2
	MOVEA.L	D0,A3
	ADDA.L	(dat_SampleEditOffset,PC),A2
	ADDA.L	D3,A3
pt_0D02:
	CMPA.L	A3,A2
	BCC.S	pt_0D03
	MOVE.B	(A2),D0
	CLR.B	(A2)+
	MOVE.B	D0,(A1)+
	BRA.S	pt_0D02
pt_0D03:
	MOVEA.L	dat_EffectBuf,A2
	CLR.W	(A2)
	SUBA.L	A2,A1
	MOVE.L	A1,D0
	LSR.L	#1,D0
	ADDQ.L	#1,D0
	AND.L	#$00007fff,D0
	MOVE.W	D0,(22,A5)
	BSR.W	pt_DrawSampleHex
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnOpt2FadeUp:
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D3
	MOVE.W	dat_EffectData0,D3
	BNE.S	pt_0D05
	JMP	pt_RestorePaletteInit
pt_0D05:
	MOVEQ	#0,D1
	MOVE.L	(dat_SampleEditOffset,PC),D2
	BNE.S	pt_0D06
	JMP	pt_RestorePaletteInit
pt_0D06:
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D07
	JMP	pt_RestorePaletteInit
pt_0D07:
	MOVEA.L	D0,A0
	LSR.L	#1,D2
	BNE.S	pt_0D08
	JMP	pt_RestorePaletteInit
pt_0D08:
	MOVEQ	#0,D4
pt_0D09:
	MOVE.B	(A0),D0
	EXT.W	D0
	MULS	D1,D0
	DIVS	D2,D0
	MOVE.B	D0,(A0)+
	ADDQ.W	#1,D4
	MOVE.W	D4,D1
	LSR.W	#1,D1
	CMP.W	D2,D1
	BCS.S	pt_0D09
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnOpt2FadeDown:
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D3
	MOVE.W	dat_EffectData0,D3
	BNE.S	pt_0D0B
	JMP	pt_RestorePaletteInit
pt_0D0B:
	LSL.L	#1,D3
	SUBQ.L	#1,D3
	MOVE.L	(dat_SampleEditOffset,PC),D2
	CMP.L	D3,D2
	BCS.S	pt_0D0C
	JMP	pt_RestorePaletteInit
pt_0D0C:
	MOVE.L	D3,D4
	SUB.L	D2,D3
	MOVE.L	D3,D2
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D0D
	JMP	pt_RestorePaletteInit
pt_0D0D:
	MOVEA.L	D0,A0
	LEA	(0,A0,D4.L),A0
	LSR.L	#1,D2
	BNE.S	pt_0D0E
	JMP	pt_RestorePaletteInit
pt_0D0E:
	MOVEQ	#0,D1
	MOVEQ	#0,D4
pt_0D0F:
	MOVE.B	(A0),D0
	EXT.W	D0
	MULS	D1,D0
	DIVS	D2,D0
	MOVE.B	D0,(A0)
	SUBQ.L	#1,A0
	ADDQ.W	#1,D4
	MOVE.W	D4,D1
	LSR.W	#1,D1
	CMP.W	D2,D1
	BCS.S	pt_0D0F
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnOpt2VolPercent:
	MOVE.W	(dat_SampleScaleFactor,PC),D2
	BRA.S	pt_SetScaleFactor
pt_BtnOpt2VolDown:
	MOVE.W	(dat_SampleScaleFactor,PC),D2
	SUBQ.W	#1,D2
	RMB
	BNE.S	pt_0D12
	SUB.W	#$0009,D2
pt_0D12:
	BPL.S	pt_SetScaleFactor
	MOVEQ	#0,D2
pt_SetScaleFactor:
	MOVE.W	D2,dat_SampleScaleFactor
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_0D16
pt_BtnOpt2VolUp:
	MOVE.W	(dat_SampleScaleFactor,PC),D2
	ADDQ.L	#1,D2
	RMB
	BNE.S	pt_0D15
	ADD.W	#$0009,D2
pt_0D15:
	CMP.W	#$03e7,D2
	BLS.S	pt_SetScaleFactor
	MOVE.W	#$03e7,dat_SampleScaleFactor
	BSR.W	pt_RefreshDisplay
pt_0D16:
	MOVE.W	#$2029,dat_TextBytePos
	MOVE.W	(dat_SampleScaleFactor,PC),dat_DisplayParam
	BSR.W	pt_DrawTempoStr
	LEA	(dat_0D17,PC),A0
	MOVE.W	#$0001,dat_TextCharCount
	BRA.W	pt_DrawTextSetup
dat_0D17:
	DC.W	$2500
pt_BtnOpt2Vol:
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D3
	MOVE.W	dat_EffectData0,D3
	BNE.S	pt_0D19
	JMP	pt_RestorePaletteInit
pt_0D19:
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D1A
	JMP	pt_RestorePaletteInit
pt_0D1A:
	MOVEA.L	D0,A1
	MOVE.W	(dat_SampleScaleFactor,PC),D0
pt_0D1B:
	MOVE.B	(A1),D1
	EXT.W	D1
	MULS	D0,D1
	DIVS	#$0064,D1
	CMP.W	#$007f,D1
	BLE.S	pt_0D1C
	MOVEQ	#127,D1
pt_0D1C:
	CMP.W	#$ff80,D1
	BGE.S	pt_0D1D
	MOVEQ	#-128,D1
pt_0D1D:
	MOVE.B	D1,(A1)+
	DBF	D3,pt_0D1B
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnOpt2Mix:
	RMB
	BEQ.W	pt_0D4A
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.W	#$0001,dat_TimingMode
	MOVE.W	#$0004,dat_MouseSampleIndex
pt_0D1F:
	BSR.W	pt_0D29
	JSR	pt_UpdateDisplayInput
	TST.B	D0
	BNE.S	pt_0D25
	CMPI.B	#$44,dat_LastKeyStored
	BEQ.W	pt_0D39
	CMPI.B	#$45,dat_LastKeyStored
	BEQ.W	pt_StartRecordInit
	RMB
	BEQ.W	pt_StartRecordInit
	LEA	(dat_0D2A,PC),A0
	LEA	str_NoteNames,A1
	LSL.W	#1,D1
	MOVE.W	(dat_MouseSampleIndex,PC),D0
	MOVE.B	(0,A1,D1.W),(0,A0,D0.W)
pt_0D20:
	MOVE.W	dat_MouseSampleIndex,D0
	ADDQ.W	#1,D0
	CMP.W	#$0006,D0
	BEQ.S	pt_0D22
	CMP.W	#$0009,D0
	BEQ.S	pt_0D23
	CMP.W	#$000f,D0
	BCC.S	pt_0D24
pt_StoreAndContinue:
	MOVE.W	D0,dat_MouseSampleIndex
	BRA.S	pt_0D1F
pt_0D22:
	MOVEQ	#7,D0
	BRA.S	pt_StoreAndContinue
pt_0D23:
	MOVEQ	#13,D0
	BRA.S	pt_StoreAndContinue
pt_0D24:
	MOVEQ	#14,D0
	BRA.S	pt_StoreAndContinue
pt_0D25:
	CMP.B	#$01,D0
	BEQ.S	pt_0D20
	MOVE.W	dat_MouseSampleIndex,D0
	SUBQ.W	#1,D0
	CMP.W	#$0004,D0
	BCS.S	pt_0D26
	CMP.W	#$0006,D0
	BEQ.S	pt_0D27
	CMP.W	#$000c,D0
	BEQ.S	pt_0D28
	BRA.S	pt_StoreAndContinue
pt_0D26:
	MOVEQ	#4,D0
	BRA.S	pt_StoreAndContinue
pt_0D27:
	MOVEQ	#5,D0
	BRA.S	pt_StoreAndContinue
pt_0D28:
	MOVEQ	#8,D0
	BRA.S	pt_StoreAndContinue
pt_0D29:
	MOVE.W	#$0040,dat_PatternDelay
	MOVE.W	dat_MouseSampleIndex,D0
	LSL.W	#3,D0
	ADD.W	#$01bc,D0
	MOVE.W	D0,dat_PlayCounter
	JSR	pt_DrawPlayCounter
	LEA	(dat_0D2A,PC),A0
	MOVE.W	#$12a7,D1
	MOVEQ	#22,D0
	BSR.W	pt_DrawTextAt
	BRA.W	pt_RefreshDisplay
dat_0D2A:
	DC.L	$6d697820
dat_0D2B:
	DC.W	$3031
	DC.B	$2b
dat_0D2C:
	DC.B	"02 to "
dat_0D2D:
	DC.B	"03       "
dat_0D2E:
	DC.B	"                 ",0
dat_LastKeyStored:
	DS.W	1
dat_MouseSampleIndex:
	DS.W	1
dat_RecordVar1:
	DS.W	1
dat_RecordVar2:
	DS.L	1
dat_RecordVar3:
	DS.L	1
dat_0D34:
	DS.L	1
dat_RecordVar4:
	DS.L	1
dat_RecordBufPtr:
	DS.L	1
pt_StartRecordInit:
	BSR.S	pt_0D38
	LEA	(dat_0D2E,PC),A0
	MOVE.W	#$12a7,D1
	MOVEQ	#17,D0
	BSR.W	pt_DrawTextAt
	JMP	pt_RestorePalette
pt_0D38:
	CLR.W	dat_TimingMode
	MOVE.W	#$fff0,dat_PlayCounter
	CLR.W	dat_PatternDelay
	JSR	pt_DrawPlayCounter
	BRA.W	pt_BtnMainOptPage2
pt_0D39:
	BSR.S	pt_0D38
	BSR.W	pt_StopAllAudio
	LEA	dat_ModulePtr,A2
	MOVEQ	#0,D0
	LEA	(dat_0D2B,PC),A0
	BSR.W	pt_BuildHexWord
	TST.W	D0
	BEQ.W	pt_SampleMixError
	CMP.W	#$001f,D0
	BHI.W	pt_SampleMixError
	LSL.W	#2,D0
	LEA	(0,A2,D0.W),A3
	MOVE.L	A3,dat_RecordVar2
	MOVEQ	#0,D0
	LEA	(dat_0D2C,PC),A0
	BSR.W	pt_BuildHexWord
	TST.W	D0
	BEQ.W	pt_SampleMixError
	CMP.W	#$001f,D0
	BHI.W	pt_SampleMixError
	LSL.W	#2,D0
	LEA	(0,A2,D0.W),A3
	MOVE.L	A3,dat_RecordVar3
	MOVEQ	#0,D0
	LEA	(dat_0D2D,PC),A0
	BSR.W	pt_BuildHexWord
	MOVE.W	D0,dat_RecordVar1
	BEQ.W	pt_SampleMixError
	CMP.W	#$001f,D0
	BHI.W	pt_SampleMixError
	LSL.W	#2,D0
	LEA	(0,A2,D0.W),A3
	MOVE.L	A3,dat_0D34
	MOVEA.L	(dat_RecordVar2,PC),A1
	MOVEA.L	(dat_RecordVar3,PC),A2
	MOVE.L	(124,A1),D1
	MOVE.L	(124,A2),D2
	CMP.L	D1,D2
	BCS.S	pt_0D3A
	EXG	D1,D2
pt_0D3A:
	TST.L	D1
	BEQ.W	pt_0D43
	MOVE.L	D1,D0
	AND.L	#$00007fff,D0
	MOVE.L	D0,dat_RecordBufPtr
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_RecordVar4
	BEQ.W	pt_SampleMixStart
	LEA	(dat_0D49,PC),A0
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	(dat_RecordVar2,PC),A1
	MOVE.L	(124,A1),D1
	MOVEA.L	(A1),A1
	MOVEA.L	(dat_RecordVar3,PC),A2
	MOVE.L	(124,A2),D2
	MOVEA.L	(A2),A2
	MOVEA.L	(dat_RecordVar4,PC),A3
	MOVE.L	(dat_RecordBufPtr,PC),D3
	TST.W	D1
	BEQ.S	pt_0D3B
	SUBQ.W	#1,D1
pt_0D3B:
	TST.W	D2
	BEQ.S	pt_0D3C
	SUBQ.L	#1,D2
pt_0D3C:
	MOVE.B	(A1),D4
	EXT.W	D4
	MOVE.B	(A2),D0
	EXT.W	D0
	ADD.W	D4,D0
	TST.B	dat_SampleEditFlag
	BEQ.S	pt_0D3E
	CMP.W	#$007f,D0
	BLE.S	pt_0D3D
	MOVEQ	#127,D0
pt_0D3D:
	CMP.W	#$ff80,D0
	BGE.S	pt_0D3F
	MOVEQ	#-128,D0
	BRA.S	pt_0D3F
pt_0D3E:
	ASR.W	#1,D0
pt_0D3F:
	MOVE.B	D0,(A3)+
	TST.W	D1
	BEQ.S	pt_0D40
	ADDQ.L	#1,A1
	SUBQ.W	#1,D1
	BNE.S	pt_0D40
	SUBA.L	A1,A1
pt_0D40:
	TST.W	D2
	BEQ.S	pt_0D41
	ADDQ.L	#1,A2
	SUBQ.W	#1,D2
	BNE.S	pt_0D41
	SUBA.L	A2,A2
pt_0D41:
	SUBQ.L	#1,D3
	BGE.S	pt_0D3C
	MOVE.W	(dat_RecordVar1,PC),dat_CurrentSample
	BSR.W	pt_GetSamplePtrEntry
	MOVEA.L	(dat_0D34,PC),A0
	MOVEA.L	(dat_RecordVar4,PC),A1
	CLR.W	(A1)
	MOVE.L	A1,(A0)
	MOVE.L	(dat_RecordBufPtr,PC),(124,A0)
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	(dat_RecordVar1,PC),D0
	SUBQ.W	#1,D0
	MULU	#s_SIZEOF,D0
	LEA	(20,A0,D0.W),A0
	MOVE.L	(dat_RecordBufPtr,PC),D0
	LSR.L	#1,D0
	MOVE.W	D0,(22,A0)
	MOVE.W	#$0040,(24,A0)
	CLR.W	(26,A0)
	MOVE.W	#$0001,(28,A0)
	JSR	pt_RestorePalette
	BSR.W	pt_ClearStatusMsg
	BSR.W	pt_DrawSampleHex
	BRA.W	pt_RecordCheckInput
pt_SampleMixError:
	LEA	(dat_0D46,PC),A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_RestorePaletteInit
	BRA.W	pt_StartRecordInit
pt_0D43:
	LEA	(dat_0D47,PC),A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_RestorePaletteInit
	BRA.W	pt_StartRecordInit
pt_SampleMixStart:
	LEA	(dat_PaletteEditCfg,PC),A0
	JSR	pt_SetupEditScreen
	JSR	pt_RestorePaletteInit
	BRA.W	pt_StartRecordInit
pt_SetupPaletteMode:
	LEA	(dat_PaletteEditCfg,PC),A0
	JSR	pt_SetupEditScreen
	JSR	pt_SetPaletteEdit
	MOVEQ	#0,D0
	RTS
dat_0D46:
	DC.B	"SAMPLE NOT IN RANGE 01-1F!",0
dat_0D47:
	DC.B	"THESE ARE NO EMPTY SAMPLES!!",0
dat_PaletteEditCfg:
	DC.B	10,10,10
	DC.B	"   NOT ENOUGH MEMORY!",0
dat_0D49:
	DC.B	"MIXING CHOSEN SAMPLES...",0
pt_0D4A:
	MOVE.L	(dat_SampleEditOffset,PC),dat_SampleEditLen
pt_0D4B:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D2
	MOVE.W	dat_EffectData0,D2
	BNE.S	pt_0D4C
	RTS
pt_0D4C:
	ADD.L	D2,D2
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D4D
	JMP	pt_RestorePaletteInit
pt_0D4D:
	BSR.W	pt_0D56
	MOVEA.L	D0,A2
	MOVEA.L	D0,A3
	MOVEA.L	A1,A4
	ADDA.L	D2,A3
	ADDA.L	(dat_SampleEditLen,PC),A2
	CLR.L	dat_SampleBufOffset1
	CLR.L	dat_SampleBufOffset0
	MOVEQ	#-1,D7
pt_0D4E:
	ADDQ.L	#1,D7
	CMPA.L	A3,A2
	BCC.S	pt_0D54
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.S	pt_0D4F
	MOVE.L	(dat_DiskOpBufSize,PC),D1
	CMP.L	D0,D1
	BEQ.S	pt_0D4F
	CMP.L	D0,D7
	BCS.S	pt_0D53
	CMP.L	D1,D7
	BHI.S	pt_0D53
pt_0D4F:
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVE.B	(A1),D1
	EXT.W	D1
	ADD.W	D1,D0
	TST.B	dat_SampleEditFlag
	BEQ.S	pt_0D51
	CMP.W	#$007f,D0
	BLE.S	pt_0D50
	MOVEQ	#127,D0
pt_0D50:
	CMP.W	#$ff80,D0
	BGE.S	pt_0D52
	MOVEQ	#-128,D0
	BRA.S	pt_0D52
pt_0D51:
	ASR.W	#1,D0
pt_0D52:
	MOVE.B	D0,(A2)+
	BSR.W	pt_CheckSampEdMode
	BRA.S	pt_0D4E
pt_0D53:
	ADDQ.L	#1,A2
	BSR.W	pt_CheckSampEdMode
	BRA.S	pt_0D4E
pt_0D54:
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
	BSR.S	pt_0D58
	JSR	pt_RestorePalette
	JSR	pt_WaitMouseRelease
	TST.W	dat_DiskOpVar2
	BEQ.W	pt_RecordCheckInput
	CLR.W	dat_DiskOpVar2
	BRA.W	pt_RecordModeHandler
dat_DiskOpVar2:
	DS.W	1
pt_0D56:
	MOVE.L	D0,D7
	MOVE.L	D2,D0
	MOVE.L	D2,dat_RecordBufOffset1
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_RecordBufOffset0
	BEQ.W	pt_SetupPaletteMode
	MOVEA.L	D7,A0
	MOVEA.L	D0,A1
	MOVE.L	(dat_RecordBufOffset1,PC),D0
	SUBQ.L	#1,D0
pt_0D57:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0D57
	MOVEA.L	(dat_RecordBufOffset0,PC),A1
	MOVE.L	D7,D0
	RTS
pt_0D58:
	MOVE.L	(dat_RecordBufOffset0,PC),D0
	BNE.S	pt_0D59
	RTS
pt_0D59:
	MOVEA.L	D0,A1
	MOVE.L	(dat_RecordBufOffset1,PC),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_RecordBufOffset0
	RTS
pt_BtnOpt2Echo:
	MOVE.L	(dat_SampleEditOffset,PC),dat_SampleEditLen
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D2
	MOVE.W	dat_EffectData0,D2
	BNE.S	pt_0D5B
	JMP	pt_RestorePaletteInit
pt_0D5B:
	ADD.L	D2,D2
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D5C
	JMP	pt_RestorePaletteInit
pt_0D5C:
	MOVEA.L	D0,A1
	MOVEA.L	D0,A2
	MOVEA.L	D0,A3
	MOVEA.L	D0,A4
	ADDA.L	D2,A3
	ADDA.L	(dat_SampleEditLen,PC),A2
	CLR.L	dat_SampleBufOffset1
	CLR.L	dat_SampleBufOffset0
pt_0D5D:
	CMPA.L	A3,A2
	BCC.S	pt_0D5E
	MOVE.B	(A2),D0
	EXT.W	D0
	MOVE.B	(A1),D1
	EXT.W	D1
	ADD.W	D1,D0
	ASR.W	#1,D0
	MOVE.B	D0,(A2)+
	BSR.W	pt_CheckSampEdMode
	BRA.S	pt_0D5D
pt_0D5E:
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
	JSR	pt_RestorePalette
	TST.B	dat_SampleEditFlag
	BEQ.W	pt_RecordCheckInput
	MOVE.W	dat_SampleScaleFactor,-(A7)
	MOVE.W	#$00c8,dat_SampleScaleFactor
	BSR.W	pt_BtnOpt2Vol
	MOVE.W	(A7)+,dat_SampleScaleFactor
	BRA.W	pt_RecordCheckInput
dat_0D5F:
	BSR.S	pt_r14852
	BRA.W	pt_RecordCheckInput
pt_r14852:
	MOVE.W	#$0001,dat_DiskOpVar2
pt_BtnSmpFilter:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	dat_0D61,A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_WaitMouseRelease
	MOVE.L	#$00000001,dat_SampleEditLen
	MOVE.B	(dat_SampleEditorMode,PC),-(A7)
	MOVE.B	dat_SampleEditFlag,-(A7)
	CLR.B	dat_SampleEditorMode
	CLR.B	dat_SampleEditFlag
	BSR.W	pt_0D4B
	MOVE.B	(A7)+,dat_SampleEditFlag
	MOVE.B	(A7)+,dat_SampleEditorMode
	BSR.W	pt_ClearStatusMsg
	JSR	pt_RestorePalette
	JMP	pt_SetPaletteBright
dat_0D61:
	DC.B	"FILTERING",0
pt_BtnSmpBoost:
	BSR.S	pt_0D63
	BRA.W	pt_RecordCheckInput
pt_0D63:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	dat_0D6B,A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_WaitMouseRelease
	MOVEQ	#0,D3
	MOVE.W	dat_EffectData0,D3
	BEQ.S	pt_0D6A
	ADD.L	D3,D3
	SUBQ.L	#1,D3
	MOVE.L	dat_EffectBuf,D0
	BEQ.S	pt_0D6A
	MOVEA.L	D0,A1
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.S	pt_0D64
	MOVE.L	(dat_DiskOpBufSize,PC),D1
	SUB.L	D0,D1
	BEQ.S	pt_0D64
	MOVE.L	D1,D3
	MOVEA.L	(dat_DiskOpFilesPtr,PC),A1
	ADDA.L	D0,A1
pt_0D64:
	MOVEQ	#0,D0
pt_0D65:
	MOVE.B	(A1),D1
	EXT.W	D1
	MOVE.W	D1,D2
	SUB.W	D0,D1
	MOVE.W	D2,D0
	TST.W	D1
	BMI.S	pt_0D66
	ASR.W	#2,D1
	ADD.W	D1,D2
	BRA.S	pt_0D67
pt_0D66:
	NEG.W	D1
	ASR.W	#2,D1
	SUB.W	D1,D2
pt_0D67:
	CMP.W	#$007f,D2
	BLE.S	pt_0D68
	MOVEQ	#127,D2
pt_0D68:
	CMP.W	#$ff80,D2
	BGE.S	pt_0D69
	MOVEQ	#-128,D2
pt_0D69:
	MOVE.B	D2,(A1)+
	DBF	D3,pt_0D65
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
pt_0D6A:
	BSR.W	pt_ClearStatusMsg
	JMP	pt_RestorePalette
dat_0D6B:
	DC.B	"BOOSTING",0,0
dat_0D6C:
	DC.B	10,10
	DC.B	"   BOOST ALL SAMPLES  ?",0
dat_0D6D:
	DC.B	10,10
	DC.B	"   FILTER ALL SAMPLES ?",0
pt_BtnOpt2XFade:
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D2
	MOVE.W	dat_EffectData0,D2
	BNE.S	pt_0D6F
	JMP	pt_RestorePaletteInit
pt_0D6F:
	ADD.L	D2,D2
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D70
	JMP	pt_RestorePaletteInit
pt_0D70:
	MOVEA.L	D0,A1
	MOVEA.L	D0,A2
	ADDA.L	D2,A2
pt_0D71:
	MOVE.B	(A1),D0
	EXT.W	D0
	MOVE.B	-(A2),D1
	EXT.W	D1
	ADD.W	D1,D0
	TST.B	dat_SampleEditFlag
	BEQ.S	pt_0D73
	CMP.W	#$007f,D0
	BLE.S	pt_0D72
	MOVEQ	#127,D0
pt_0D72:
	CMP.W	#$ff80,D0
	BGE.S	pt_0D74
	MOVEQ	#-128,D0
	BRA.S	pt_0D74
pt_0D73:
	ASR.W	#1,D0
pt_0D74:
	MOVE.B	D0,(A1)+
	MOVE.B	D0,(A2)
	CMPA.L	A2,A1
	BCS.S	pt_0D71
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnSmpBackwards:
	JSR	pt_WaitMouseRelease
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEQ	#0,D2
	MOVE.W	(22,A5),D2
	BNE.S	pt_0D76
	JMP	pt_RestorePaletteInit
pt_0D76:
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D77
	JMP	pt_RestorePaletteInit
pt_0D77:
	MOVEA.L	D0,A1
	MOVEA.L	D0,A2
	ADD.L	D2,D2
	ADDA.L	D2,A2
	MOVE.L	(dat_DiskOpBufAddr,PC),D0
	BMI.S	pt_CopySampleBytes
	MOVE.L	(dat_DiskOpBufSize,PC),D1
	SUB.L	D0,D1
	BEQ.S	pt_CopySampleBytes
	MOVEA.L	(dat_DiskOpFilesPtr,PC),A1
	ADDA.L	D0,A1
	MOVEA.L	A1,A2
	ADDA.L	D1,A2
pt_CopySampleBytes:
	MOVE.B	(A1),D0
	MOVE.B	-(A2),(A1)+
	MOVE.B	D0,(A2)
	CMPA.L	A2,A1
	BCS.S	pt_CopySampleBytes
	MOVEA.L	dat_EffectBuf,A1
	CLR.W	(A1)
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnSmpUpsample:
	JSR	pt_WaitMouseRelease
	LEA	dat_12E5,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_0D7A
	RTS
pt_0D7A:
	BSR.W	pt_StopAllAudio
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.W	dat_CurrentSample,D0
	LSL.W	#2,D0
	LEA	dat_ModulePtr,A0
	LEA	(0,A0,D0.W),A0
	MOVE.L	(124,A0),D3
	CMP.L	#$00000002,D3
	BHI.S	pt_0D7B
	JMP	pt_RestorePaletteInit
pt_0D7B:
	MOVE.L	(A0),D0
	BNE.S	pt_0D7C
	JMP	pt_RestorePaletteInit
pt_0D7C:
	MOVEA.L	D0,A2
	MOVEA.L	D0,A4
	MOVE.L	D3,D4
	LSR.L	#1,D3
	BCLR	#0,D3
	MOVE.L	D3,D0
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	TST.L	D0
	BEQ.S	pt_0D7F
	MOVEA.L	D0,A3
	MOVE.L	D0,D2
	MOVE.L	D3,D5
pt_0D7D:
	MOVE.B	(A2)+,(A3)+
	ADDQ.L	#1,A2
	SUBQ.L	#1,D3
	BGE.S	pt_0D7D
	MOVEA.L	A4,A1
	MOVE.L	D4,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	MOVE.W	dat_CurrentSample,D0
	LSL.W	#2,D0
	LEA	dat_ModulePtr,A0
	LEA	(0,A0,D0.W),A0
	MOVE.L	D2,(A0)
	MOVE.L	D5,(124,A0)
	MOVEA.L	D2,A0
	CLR.W	(A0)
	MOVE.W	(22,A5),D0
	LSR.W	#1,D0
	MOVE.W	D0,(22,A5)
	MOVE.W	(26,A5),D0
	LSR.W	#1,D0
	MOVE.W	D0,(26,A5)
	MOVE.W	(28,A5),D0
	LSR.W	#1,D0
	BNE.S	pt_0D7E
	MOVEQ	#1,D0
pt_0D7E:
	MOVE.W	D0,(28,A5)
	BSR.W	pt_DrawSampleHex
	JSR	pt_WaitMouseRelease
	JSR	pt_RestorePalette
	BRA.W	pt_RecordModeHandler
pt_0D7F:
	JSR	pt_RestorePalette
	BRA.W	pt_SetupPaletteMode
pt_BtnSmpDownsample:
	JSR	pt_WaitMouseRelease
	TST.W	dat_CurrentSample
	BEQ.W	pt_SelectDiskMsg
	LEA	dat_12E6,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_0D81
	RTS
pt_0D81:
	BSR.W	pt_StopAllAudio
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D82
	JMP	pt_RestorePaletteInit
pt_0D82:
	MOVEQ	#0,D0
	MOVE.W	dat_EffectData0,D0
	BNE.S	pt_0D83
	JMP	pt_RestorePaletteInit
pt_0D83:
	LSL.L	#1,D0
	CMP.L	#$0000fffe,D0
	BLS.S	pt_0D84
	JMP	pt_RestorePaletteInit
pt_0D84:
	LSL.L	#1,D0
	CMP.L	#$0000fffe,D0
	BLS.S	pt_0D85
	MOVE.L	#$0000fffe,D0
pt_0D85:
	MOVE.L	D0,dat_RecordBufOffset1
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_RecordBufOffset0
	BEQ.W	pt_SampleMixStart
	MOVEA.L	dat_EffectBuf,A1
	MOVEA.L	D0,A2
	MOVE.L	dat_RecordBufOffset1,D3
	LSR.L	#1,D3
	SUBQ.L	#1,D3
pt_0D86:
	MOVE.B	(A1)+,D0
	MOVE.B	D0,(A2)+
	MOVE.B	D0,(A2)+
	DBF	D3,pt_0D86
	BSR.W	pt_GetSamplePtrEntry
	LEA	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	LSL.W	#2,D0
	MOVE.L	dat_RecordBufOffset0,(0,A0,D0.W)
	MOVE.L	dat_RecordBufOffset1,(124,A0,D0.W)
	MOVEQ	#0,D0
	MOVE.W	(22,A5),D0
	LSL.L	#1,D0
	CMP.L	#$00007fff,D0
	BLS.S	pt_0D87
	MOVE.L	#$00007fff,D0
pt_0D87:
	MOVE.W	D0,(22,A5)
	MOVEQ	#0,D0
	MOVE.W	(26,A5),D0
	LSL.L	#1,D0
	CMP.L	#$00007fff,D0
	BLS.S	pt_0D88
	MOVE.L	#$00007fff,D0
pt_0D88:
	MOVE.W	D0,(26,A5)
	MOVEQ	#0,D0
	MOVE.W	(28,A5),D0
	CMP.L	#$00000001,D0
	BEQ.S	pt_0D89
	LSL.L	#1,D0
	CMP.L	#$00007fff,D0
	BLS.S	pt_0D89
	MOVE.L	#$00007fff,D0
pt_0D89:
	MOVE.W	D0,(28,A5)
	BSR.W	pt_DrawSampleHex
	JSR	pt_WaitMouseRelease
	JSR	pt_RestorePalette
	BRA.W	pt_RecordModeHandler
pt_BtnSmpInvert:
	BSR.W	pt_StopAllAudio
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D8B
	JMP	pt_RestorePaletteInit
pt_0D8B:
	MOVEQ	#0,D0
	MOVE.W	dat_EffectData0,D0
	BNE.S	pt_0D8C
	JMP	pt_RestorePaletteInit
pt_0D8C:
	BSR.W	pt_0DAC
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnSmpNormalDc:
	BSR.W	pt_StopAllAudio
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D8E
	JMP	pt_RestorePaletteInit
pt_0D8E:
	MOVEQ	#0,D0
	MOVE.W	dat_EffectData0,D0
	BNE.S	pt_0D8F
	JMP	pt_RestorePaletteInit
pt_0D8F:
	BSR.W	pt_0DA1
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnSmpNormalize:
	BSR.W	pt_StopAllAudio
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D91
	JMP	pt_RestorePaletteInit
pt_0D91:
	MOVEQ	#0,D0
	MOVE.W	dat_EffectData0,D0
	BNE.S	pt_0D92
	JMP	pt_RestorePaletteInit
pt_0D92:
	BSR.W	pt_0D9A
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_BtnSmpMaximize:
	BSR.W	pt_StopAllAudio
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	dat_EffectBuf,D0
	BNE.S	pt_0D94
	JMP	pt_RestorePaletteInit
pt_0D94:
	MOVEQ	#0,D0
	MOVE.W	dat_EffectData0,D0
	BNE.S	pt_0D95
	JMP	pt_RestorePaletteInit
pt_0D95:
	BSR.W	pt_0DA6
	JSR	pt_RestorePalette
	BRA.W	pt_RecordCheckInput
pt_CheckDiskOpBuf:
	MOVEQ	#1,D0
	MOVE.L	(dat_DiskOpBufAddr,PC),D1
	BMI.S	pt_0D97
	CMP.L	(dat_DiskOpBufSize,PC),D1
	BEQ.S	pt_0D97
	MOVEQ	#2,D0
pt_0D97:
	LEA	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D1
	LSL.W	#2,D1
	MOVEA.L	(0,A0,D1.W),A1
	MOVE.L	(124,A0,D1.W),D1
	CMP.W	#$0001,D0
	BEQ.S	pt_0D98
	CMP.W	#$0002,D0
	BEQ.S	pt_0D99
	RTS
pt_0D98:
	ADDA.L	dat_DiskBufAddr,A1
	MOVE.L	dat_DiskBufLen,D1
	RTS
pt_0D99:
	MOVE.L	dat_DiskOpBufAddr,D0
	ADDA.L	D0,A1
	MOVE.L	dat_DiskOpBufSize,D1
	SUB.L	D0,D1
	RTS
pt_0D9A:
	MOVEM.L	D2-D4,-(A7)
	BSR.S	pt_CheckDiskOpBuf
	MOVEA.L	A1,A0
	MOVE.L	D1,D0
	MOVEQ	#0,D2
pt_0D9B:
	MOVE.B	(A0)+,D3
	EXT.W	D3
	BPL.S	pt_0D9C
	NEG.W	D3
pt_0D9C:
	CMP.W	D2,D3
	BCS.S	pt_0D9D
	MOVE.W	D3,D2
pt_0D9D:
	SUBQ.L	#1,D1
	BNE.S	pt_0D9B
	TST.W	D2
	BEQ.S	pt_0DA0
	MOVE.L	#$00004000,D3
	DIVU	D2,D3
	MOVEQ	#7,D2
	MOVEQ	#64,D4
pt_0D9E:
	MOVE.B	(A1),D1
	EXT.W	D1
	MULS	D3,D1
	ADD.L	D4,D1
	ASR.L	D2,D1
	CMP.W	#$007f,D1
	BLE.S	pt_0D9F
	MOVEQ	#127,D1
pt_0D9F:
	MOVE.B	D1,(A1)+
	SUBQ.L	#1,D0
	BNE.S	pt_0D9E
pt_0DA0:
	MOVEM.L	(A7)+,D2-D4
	RTS
pt_0DA1:
	MOVEM.L	D2-D3,-(A7)
	BSR.W	pt_CheckDiskOpBuf
	MOVEA.L	A1,A0
	MOVE.L	D1,D3
	MOVEQ	#0,D2
pt_0DA2:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	EXT.L	D0
	ADD.L	D0,D2
	SUBQ.L	#1,D1
	BNE.S	pt_0DA2
	MOVE.L	D2,D0
	MOVE.L	D3,D1
	BSR.W	pt_0DAE
pt_0DA3:
	MOVE.B	(A1),D1
	EXT.W	D1
	SUB.W	D0,D1
	CMP.W	#$007f,D1
	BLE.S	pt_0DA4
	MOVEQ	#127,D1
	BRA.S	pt_0DA5
pt_0DA4:
	CMP.W	#$ff80,D1
	BGE.S	pt_0DA5
	MOVEQ	#-128,D1
pt_0DA5:
	MOVE.B	D1,(A1)+
	SUBQ.L	#1,D3
	BNE.S	pt_0DA3
	MOVEM.L	(A7)+,D2-D3
	RTS
pt_0DA6:
	MOVEM.L	D2-D3,-(A7)
	BSR.W	pt_CheckDiskOpBuf
	MOVEA.L	A1,A0
	MOVE.L	D1,D3
	MOVEQ	#-128,D2
	MOVEQ	#127,D4
pt_0DA7:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	CMP.W	D0,D2
	BPL.S	pt_0DA8
	MOVE.W	D0,D2
pt_0DA8:
	CMP.W	D0,D4
	BMI.S	pt_0DA9
	MOVE.W	D0,D4
pt_0DA9:
	SUBQ.L	#1,D1
	BNE.S	pt_0DA7
	MOVE.W	D2,D0
	SUB.W	D4,D0
	BEQ.S	pt_0DAB
	MOVE.W	D2,D6
	SUB.W	#$007f,D6
	MOVE.W	D4,D5
	SUB.W	#$ff80,D5
	ADD.W	D6,D5
	ASR.W	#1,D5
pt_0DAA:
	MOVE.B	(A1),D1
	EXT.W	D1
	SUB.W	D5,D1
	MULS	#$00ff,D1
	DIVS	D0,D1
	MOVE.B	D1,(A1)+
	SUBQ.L	#1,D3
	BNE.S	pt_0DAA
pt_0DAB:
	MOVEM.L	(A7)+,D2-D3
	RTS
pt_0DAC:
	BSR.W	pt_CheckDiskOpBuf
	MOVEQ	#-1,D0
pt_0DAD:
	EOR.B	D0,(A1)+
	SUBQ.L	#1,D1
	BNE.S	pt_0DAD
	RTS
pt_0DAE:
	DIVS	D1,D0
	RTS
dat_SampleEditOffset:
	DS.W	1
dat_0DB0:
	DS.W	1
dat_SampleScaleFactor:
	DC.W	$0064
dat_SampleEditLen:
	DS.L	1
dat_SampleEditorMode:
	DS.B	1
dat_SampleEditFlag:
	DS.B	1
dat_SampleBufOffset0:
	DS.L	1
dat_SampleBufOffset1:
	DS.L	1
dat_RecordBufOffset0:
	DS.L	1
dat_RecordBufOffset1:
	DS.L	1
pt_0DB9:
	BSR.W	pt_BtnMainStop
	CLR.B	dat_KeyCode
	MOVEA.L	dat_ModulePtr,A0
	LEA	(dat_EffectParamVar,PC),A1
	MOVEQ	#0,D0
	MOVEQ	#2,D1
pt_0DBA:
	MOVE.W	(0,A1,D1.W),D2
	ADD.W	D2,(42,A0,D0.W)
	ADD.W	#$001e,D0
	ADDQ.W	#2,D1
	CMP.W	#$003e,D1
	BNE.S	pt_0DBA
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	dat_NumSamples
pt_0DBB:
	MOVE.B	(0,A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#$0080,D0
	BHI.S	pt_0DBC
	MOVE.W	dat_NumSamples,D2
	CMP.W	D2,D1
	BLS.S	pt_0DBB
	MOVE.W	D1,dat_NumSamples
	BRA.S	pt_0DBB
pt_0DBC:
	TST.B	dat_SampleNameBuf
	BEQ.S	pt_0DBE
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.B	#$70,(A1)+
	MOVE.B	#$74,(A1)+
	MOVE.B	#$73,(A1)+
	MOVE.B	#$2e,(A1)+
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#13,D0
pt_0DBD:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0DBD
	BRA.S	pt_0DC0
pt_0DBE:
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.B	#$73,(A1)+
	MOVE.B	#$74,(A1)+
	MOVE.B	#$2e,(A1)+
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#19,D0
pt_0DBF:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0DBF
pt_0DC0:
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	MOVEA.L	dat_ModulePtr,A0
	MOVE.L	A0,dat_FileWriteAddr
	CLR.L	dat_FileWriteSize
	TST.B	dat_SampleNameBuf
	BEQ.W	pt_0DC6
	BSET	#2,dat_ModeFlags
	MOVE.L	dat_TimeAuxVal,D0
	ADD.L	dat_ModeConfigVal,D0
	MOVE.L	D0,dat_FileInfoPtr2
	LEA	str_UnnamedSong,A0
	CMPI.L	#$554e4e41,(A0)
	BNE.S	pt_0DC2
	MOVEA.L	dat_ModulePtr,A0
	LEA	str_UnnamedSong,A1
	MOVEQ	#19,D0
pt_0DC1:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0DC1
pt_0DC2:
	MOVE.W	#$0020,dat_SongNameBufEnd
	MOVE.W	#$0040,dat_SongNameEnd
	MOVE.W	dat_NumSamples,dat_SongConfigVar
	MOVE.W	dat_RpMasterVol,dat_SongConfigVar2
	MOVE.W	dat_CurrentTempo,dat_DefaultTempo
	MOVE.B	dat_ModeFlags,dat_SongModified
	MOVE.B	dat_ModeFlags+1,dat_SongModified+1
	BCHG	#5,dat_SongModified
	JSR	pt_InitFileBuffers
	LEA	dat_FileWorkBuf,A0
	MOVE.L	(A0),D0
	MOVE.W	D0,dat_TempoVar2
	MOVE.L	(4,A0),D0
	MOVE.W	D0,dat_DiskConfigA
	MOVE.L	(8,A0),D0
	MOVE.W	D0,dat_DiskConfigB
	MOVE.L	(12,A0),D0
	MOVE.W	D0,dat_SongCommentData
	MOVE.W	dat_SampleConfigA,dat_DSPControl
	MOVE.W	dat_SampleConfigB,dat_SongConfigA
	MOVE.W	dat_SampleConfigC,dat_SongConfigB
	MOVE.W	dat_SampleConfigD,dat_SongConfigC
	MOVE.W	dat_SampleConfigE,dat_SongConfigD
	MOVE.W	dat_SampleConfigF,dat_SongConfigE
	MOVEA.L	dat_ModulePtr,A0
	LEA	(42,A0),A0
	MOVE.W	dat_PrevSampleNum,D7
	SUBQ.W	#1,D7
	MOVE.W	#$001f,dat_PrevSampleNum
	MOVEQ	#0,D0
pt_0DC3:
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ASL.W	#1,D1
	ADD.L	D1,D0
	ADDA.W	#$001e,A0
	DBF	D7,pt_0DC3
	ADD.L	#$0000043c,D0
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#127,D7
	ADDA.W	#$03b8,A0
	MOVEQ	#0,D6
pt_0DC4:
	MOVE.B	(A0)+,D5
	CMP.B	D5,D6
	BHI.S	pt_0DC5
	MOVE.B	D5,D6
pt_0DC5:
	DBF	D7,pt_0DC4
	ADDQ.W	#1,D6
	ASL.L	#8,D6
	ASL.L	#2,D6
	ADD.L	D6,D0
	MOVE.L	D0,dat_1420
	LEA	str_IFFFormID,A0
	MOVE.L	A0,dat_FileWriteAddr
	MOVE.L	#$00000212,D0
	MOVE.L	D0,dat_FileWriteSize
	BSR.W	pt_FileOpenCheck
	BNE.W	pt_DrawWaveform
	BSR.W	pt_WriteFileData
	BNE.W	pt_CheckCloseAndBranch
pt_0DC6:
	MOVEA.L	dat_ModulePtr,A0
	MOVE.L	dat_ModulePtr,dat_FileWriteAddr
	MOVE.L	#$0000043c,dat_FileWriteSize
	MOVEQ	#0,D0
	MOVE.W	dat_NumSamples,D0
	ADDQ.L	#1,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0DC7
	LSL.L	#1,D0
pt_0DC7:
	ADD.L	D0,dat_FileWriteSize
	MOVE.B	#$7f,(951,A0)
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
	CMPI.W	#$0040,dat_NumSamples
	BCS.S	pt_0DC8
	MOVE.L	#$4d214b21,(mod_id,A0)
pt_0DC8:
	BTST	#1,dat_UIStateFlag
	BEQ.S	pt_0DC9
	LEA	dat_12C8,A0
	BSR.W	pt_ShowStatusMsg
	BSR.W	pt_0DD2
pt_0DC9:
	TST.B	dat_SampleNameBuf
	BNE.S	pt_0DCA
	BSR.W	pt_FileOpenCheck
	BNE.W	pt_DrawWaveform
pt_0DCA:
	BSR.W	pt_WriteFileData
	BNE.W	pt_CheckCloseAndBranch
	BSR.W	pt_CheckCanClose
	BTST	#1,dat_UIStateFlag
	BEQ.S	pt_0DCB
	LEA	dat_12C7,A0
	BSR.W	pt_ShowStatusMsg
	BSR.W	pt_0DEE
pt_0DCB:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(dat_EffectParamVar,PC),A1
	MOVEQ	#0,D0
	MOVEQ	#2,D1
pt_0DCC:
	MOVE.W	(0,A1,D1.W),D2
	SUB.W	D2,(42,A0,D0.W)
	ADD.W	#$001e,D0
	ADDQ.W	#2,D1
	CMP.W	#$003e,D1
	BNE.S	pt_0DCC
	BSR.W	pt_ClearStatusMsg
	JMP	pt_SetPaletteBright
dat_0DCD:
	DS.L	1
dat_0DCE:
	DS.W	1
dat_0DCF:
	DC.L	$01000200,$04001000,$00080009,$000a0008
	DS.L	1
	DC.L	$00000008,$00020003,$00030003,$00010004
	DC.L	$00050006
	DS.L	2
dat_0DD0:
	DS.W	1
dat_0DD1:
	DS.W	1
pt_0DD2:
	JSR	pt_SetPaletteBright
	MOVEA.L	dat_ModulePtr,A0
	MOVEA.L	A0,A1
	LEA	(12,A1),A1
	MOVE.L	A1,dat_PaletteVar2
	MOVEA.L	A0,A1
	ADDA.L	dat_SampleEditCfg,A1
	MOVE.L	A1,dat_0F28
	MOVEA.L	A0,A1
	ADDA.L	dat_SampleEditCfg,A1
	SUBA.L	dat_FileWriteSize,A1
	MOVE.L	A1,dat_PaletteVar1
	MOVE.L	dat_FileWriteSize,dat_PaletteDataPtr
	MOVEA.L	dat_ModulePtr,A0
	ADDA.L	dat_FileWriteSize,A0
	MOVEA.L	dat_ModulePtr,A1
	ADDA.L	dat_SampleEditCfg,A1
	MOVE.L	dat_FileWriteSize,D0
pt_0DD3:
	MOVE.B	-(A0),-(A1)
	SUBQ.L	#1,D0
	BNE.S	pt_0DD3
	BSR.S	pt_0DD5
	SUBA.L	(dat_PaletteVar2,PC),A2
	MOVE.L	A2,D0
	MOVE.L	D0,dat_PaletteVar3
	MOVE.L	D0,D1
	ADD.L	(dat_PaletteVar2,PC),D1
	MOVE.L	D1,dat_0F2B
	MOVEA.L	dat_ModulePtr,A0
	MOVE.L	#$5041434b,(A0)
	CMPI.W	#$0040,dat_NumSamples
	BCS.S	pt_0DD4
	MOVE.L	#$50414b4b,(A0)
pt_0DD4:
	MOVE.L	dat_PaletteVar3,(4,A0)
	MOVE.L	(dat_PaletteDataPtr,PC),(8,A0)
	MOVE.L	dat_ModulePtr,dat_FileWriteAddr
	MOVE.L	(dat_PaletteVar3,PC),D0
	ADD.L	#$0000000c,D0
	MOVE.L	D0,dat_FileWriteSize
	RTS
pt_0DD5:
	MOVEA.L	(dat_PaletteVar1,PC),A0
	MOVEA.L	(dat_0F28,PC),A1
	MOVEA.L	(dat_PaletteVar2,PC),A2
	MOVEQ	#1,D2
	CLR.W	D1
pt_0DD6:
	BSR.S	pt_0DD8
	TST.B	D0
	BEQ.S	pt_0DD7
	ADDQ.W	#1,D1
	CMP.W	#$0108,D1
	BNE.S	pt_0DD7
	BSR.W	pt_CheckNonZero
pt_0DD7:
	CMPA.L	A0,A1
	BGT.S	pt_0DD6
	BSR.W	pt_CheckNonZero
	BRA.W	pt_0DEC
pt_0DD8:
	MOVEA.L	A0,A3
	LEA	(127,A3),A3
	CMPA.L	A1,A3
	BLE.S	pt_0DD9
	MOVEA.L	A1,A3
pt_0DD9:
	MOVEQ	#1,D5
	MOVEA.L	A0,A5
	ADDQ.L	#1,A5
pt_0DDA:
	MOVE.B	(A0),D3
	MOVE.B	(1,A0),D4
	MOVE.W	D3,COLOR17
pt_0DDB:
	CMP.B	(A5)+,D3
	BNE.S	pt_0DDC
	CMP.B	(A5),D4
	BEQ.S	pt_0DDD
pt_0DDC:
	CMPA.L	A5,A3
	BGT.S	pt_0DDB
	BRA.S	pt_0DE4
pt_0DDD:
	SUBQ.L	#1,A5
	MOVEA.L	A0,A4
pt_0DDE:
	MOVE.B	(A4)+,D3
	CMP.B	(A5)+,D3
	BNE.S	pt_0DDF
	CMPA.L	A5,A3
	BGT.S	pt_0DDE
pt_0DDF:
	MOVE.L	A4,D3
	SUB.L	A0,D3
	SUBQ.L	#1,D3
	CMP.L	D3,D5
	BGE.S	pt_0DE3
	MOVE.L	A5,D4
	SUB.L	A0,D4
	SUB.L	D3,D4
	SUBQ.L	#1,D4
	CMP.L	#$00000004,D3
	BLE.S	pt_0DE1
	MOVEQ	#6,D6
	CMP.L	#$00000101,D3
	BLT.S	pt_0DE0
	MOVE.W	#$0100,D3
pt_0DE0:
	BRA.S	pt_0DE2
pt_0DE1:
	MOVE.W	D3,D6
	SUBQ.W	#2,D6
	LSL.W	#1,D6
pt_0DE2:
	LEA	(dat_0DCF,PC),A6
	CMP.W	(0,A6,D6.W),D4
	BGE.S	pt_0DE3
	MOVE.L	D3,D5
	MOVE.L	D4,dat_0DCD
	MOVE.B	D6,dat_0DCE
pt_0DE3:
	CMPA.L	A5,A3
	BGT.S	pt_0DDA
pt_0DE4:
	CMP.L	#$00000001,D5
	BEQ.S	pt_0DE6
	BSR.S	pt_CheckNonZero
	MOVE.B	(dat_0DCE,PC),D6
	MOVE.L	(dat_0DCD,PC),D3
	MOVE.W	(8,A6,D6.W),D0
	BSR.S	pt_BitRotateLoop
	MOVE.W	(16,A6,D6.W),D0
	BEQ.S	pt_0DE5
	MOVE.L	D5,D3
	SUBQ.W	#1,D3
	BSR.S	pt_BitRotateLoop
pt_0DE5:
	MOVE.W	(24,A6,D6.W),D0
	MOVE.W	(32,A6,D6.W),D3
	BSR.S	pt_BitRotateLoop
	ADDQ.W	#1,(40,A6,D6.W)
	ADDA.L	D5,A0
	CLR.B	D0
	RTS
pt_0DE6:
	MOVE.B	(A0)+,D3
	MOVEQ	#8,D0
	BSR.S	pt_BitRotateLoop
	MOVEQ	#1,D0
	RTS
