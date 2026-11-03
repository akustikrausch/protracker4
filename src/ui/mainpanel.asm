pt_BtnMainPosInsert:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	ADDA.W	#$007e,A0
	MOVEQ	#127,D0
	MOVE.L	dat_BplUpdateReq,D1
	AND.L	#$0000007f,D1
pt_087D:
	MOVE.B	(A0),(1,A0)
	SUBQ.L	#1,A0
	SUBQ.L	#1,D0
	CMP.L	D1,D0
	BHI.S	pt_087D
	CLR.B	(1,A0)
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_087E
	JSR	pt_DrawPosPatNumbers
	CLR.W	dat_ButtonActive
	BSR.W	pt_BtnMainLengthArrows
	JMP	pt_WaitMouseRelease
pt_087E:
	CLR.W	dat_ButtonActive
	BSR.W	pt_BtnMainLengthArrows
	JSR	pt_WaitMouseRelease
	JMP	pt_EditModeHandler
pt_BtnMainPosDelete:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	MOVE.L	dat_BplUpdateReq,D0
	AND.L	#$0000007f,D0
	ADDA.L	D0,A0
pt_0880:
	MOVE.B	(1,A0),(A0)
	ADDQ.L	#1,A0
	ADDQ.L	#1,D0
	CMP.L	#$0000007f,D0
	BLS.S	pt_0880
	CLR.B	(-1,A0)
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_0881
	JSR	pt_DrawPosPatNumbers
	MOVE.W	#$ffff,dat_ButtonActive
	BSR.W	pt_BtnMainLengthArrows
	JMP	pt_WaitMouseRelease
pt_0881:
	MOVE.W	#$ffff,dat_ButtonActive
	BSR.W	pt_BtnMainLengthArrows
	JSR	pt_WaitMouseRelease
	JMP	pt_EditModeHandler
pt_BtnMainPosValue:
	MOVE.W	#$004c,dat_PlayCounter
	MOVE.W	#$0034,dat_PatternDelay
	MOVE.W	#$0eb9,dat_TextBytePos
	BSR.W	pt_MarkPaletteDirty
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_MainEditLoop
	CMP.W	#$007f,D0
	BLS.S	pt_0883
	MOVEQ	#127,D0
pt_0883:
	MOVE.L	D0,dat_BplUpdateReq
	BRA.W	pt_MainEditLoop
pt_BtnMainPatternValue:
	MOVE.W	#$0054,dat_PlayCounter
	MOVE.W	#$003f,dat_PatternDelay
	MOVE.W	#$122a,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_MainEditLoop
	CMP.B	(dat_SampleVolume,PC),D0
	BLS.S	pt_0885
	MOVE.L	(dat_SampleEditState,PC),D0
pt_0885:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	ADDA.L	dat_BplUpdateReq,A0
	MOVE.B	D0,(A0)
	BRA.W	pt_MainEditLoop
pt_BtnMainLengthValue:
	MOVE.W	#$004c,dat_PlayCounter
	MOVE.W	#$004a,dat_PatternDelay
	MOVE.W	#$1599,dat_TextBytePos
	BSR.S	pt_MarkPaletteDirty
	TST.W	dat_PaletteDirtyFlag
	BNE.S	pt_0888
	JSR	pt_SongLenClamp41
	NOP
	NOP
pt_0887:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_songlen,A0),A0
	MOVE.B	D0,(A0)
pt_0888:
	JMP	pt_DrawPanelByMode
pt_MarkPaletteDirty:
	MOVE.W	#$0001,dat_PaletteDirtyFlag
	BSR.W	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	BSR.W	pt_DrawPlayCounter
pt_088A:
	BSR.W	pt_UIRefreshLoop
	CMP.W	#$0044,D1
	BEQ.S	pt_ResetPlayState
	CMP.W	#$0002,D1
	BHI.S	pt_088A
	MOVE.W	D1,D0
	MULU	#$0064,D0
	MOVE.W	D0,dat_EditSampleSlot
	BSR.W	pt_ConvertDecChar
	ADDQ.W	#8,dat_PlayCounter
	BSR.W	pt_DrawPlayCounter
	BSR.W	pt_UIRefreshLoop
	CMP.B	#$44,D1
	BEQ.S	pt_ResetPlayState
	MOVE.W	D1,D0
	MULU	#$000a,D0
	ADD.W	D0,dat_EditSampleSlot
	BSR.W	pt_ConvertDecChar
	ADDQ.W	#8,dat_PlayCounter
	BSR.W	pt_DrawPlayCounter
	BSR.W	pt_UIRefreshLoop
	CMP.B	#$44,D1
	BEQ.S	pt_ResetPlayState
	ADD.W	D1,dat_EditSampleSlot
	CLR.W	dat_PaletteDirtyFlag
pt_ResetPlayState:
	CLR.W	dat_PlayCounter
	MOVE.W	#$010e,dat_PatternDelay
	BSR.W	pt_DrawPlayCounter
	JSR	pt_RestorePalette
	MOVEQ	#0,D0
	MOVE.W	(dat_EditSampleSlot,PC),D0
	RTS
dat_EditSampleSlot:
	DS.W	1
pt_BtnMainPosArrows:
	TST.W	dat_ButtonActive
	BMI.S	pt_DecrBplUpdate
pt_088E:
	ADDQ.L	#1,dat_BplUpdateReq
	RMB
	BNE.S	pt_088F
	ADDI.L	#$00000009,dat_BplUpdateReq
pt_088F:
	CMPI.L	#$0000007f,dat_BplUpdateReq
	BLS.S	pt_MainEditLoop
	MOVE.L	#$0000007f,dat_BplUpdateReq
pt_MainEditLoop:
	MOVE.L	dat_BplUpdateReq,dat_RpSongPos
	JSR	pt_DrawPosPatNumbers
	CMPI.W	#$0009,dat_UIMode
	BNE.S	pt_0891
	JSR	pt_DrawSampleInfo
pt_0891:
	CLR.B	dat_KeyCode
	BSR.W	pt_RefreshDisplay
	JSR	pt_PatternRestart
	BSR.W	pt_ScreenDragUpdate
	CLR.B	dat_KeyCode
	BRA.W	pt_RefreshDisplay
pt_DecrBplUpdate:
	SUBQ.L	#1,dat_BplUpdateReq
	RMB
	BNE.S	pt_CheckBplUpdate
	SUBI.L	#$00000009,dat_BplUpdateReq
pt_CheckBplUpdate:
	TST.L	dat_BplUpdateReq
	BPL.S	pt_MainEditLoop
	CLR.L	dat_BplUpdateReq
	BRA.S	pt_MainEditLoop
pt_BtnMainPatternArrows:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	TST.W	dat_ButtonActive
	BMI.S	pt_0896
	ADDA.L	dat_BplUpdateReq,A0
	ADDQ.B	#1,(A0)
	RMB
	BNE.S	pt_0895
	ADDI.B	#$09,(A0)
pt_0895:
	MOVE.B	(A0),D0
	CMP.B	(dat_SampleVolume,PC),D0
	BLS.W	pt_MainEditLoop
	MOVE.B	(dat_SampleVolume,PC),(A0)
	BRA.W	pt_MainEditLoop
pt_0896:
	ADDA.L	dat_BplUpdateReq,A0
	SUBQ.B	#1,(A0)
	RMB
	BNE.S	pt_0897
	SUBI.B	#$09,(A0)
pt_0897:
	TST.B	(A0)
	BPL.W	pt_MainEditLoop
	CLR.B	(A0)
	BRA.W	pt_MainEditLoop
pt_BtnMainLengthArrows:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_songlen,A0),A0
	TST.W	dat_ButtonActive
	BMI.S	pt_089C
	ADDQ.B	#1,(A0)
	RMB
	BNE.S	pt_0899
	ADDI.B	#$09,(A0)
pt_0899:
	CMPI.B	#$7f,(A0)
	BMI.S	pt_CheckEditMode9
	MOVE.B	#$7f,(A0)
pt_CheckEditMode9:
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_089B
	JSR	pt_DrawPanelByMode
pt_089B:
	BSR.W	pt_RefreshDisplay
	BSR.W	pt_RefreshDisplay
	BRA.W	pt_RefreshDisplay
pt_089C:
	SUBQ.B	#1,(A0)
	RMB
	BNE.S	pt_089D
	SUBI.B	#$09,(A0)
pt_089D:
	CMPI.B	#$01,(A0)
	BGE.S	pt_CheckEditMode9
	MOVE.B	#$01,(A0)
	BRA.S	pt_CheckEditMode9
pt_BtnMainSampleArrows:
	RMB
	BNE.S	pt_08A0
	TST.W	dat_CurrentSample
	BEQ.S	pt_089F
	MOVE.W	dat_CurrentSample,dat_SamplePlayInit
	CLR.W	dat_CurrentSample
pt_089F:
	JMP	pt_DrawSampleHex
pt_08A0:
	TST.W	dat_ButtonActive
	BMI.S	pt_08A3
pt_08A1:
	ADDQ.W	#1,dat_CurrentSample
	CMPI.W	#$001f,dat_CurrentSample
	BMI.S	pt_RefreshAfterEdit
	MOVE.W	#$001f,dat_CurrentSample
pt_RefreshAfterEdit:
	JSR	pt_036E
	BSR.W	pt_RefreshDisplay
	BRA.W	pt_RefreshDisplay
pt_08A3:
	TST.W	dat_CurrentSample
	BEQ.S	pt_DrawSampleRefresh
	SUBQ.W	#1,dat_CurrentSample
	CMPI.W	#$0001,dat_CurrentSample
	BGE.S	pt_RefreshAfterEdit
	MOVE.W	#$0001,dat_CurrentSample
	BRA.S	pt_RefreshAfterEdit
pt_BtnMainFinetuneArrows:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_08A5
	RTS
pt_08A5:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	RMB
	BNE.S	pt_CheckButtonActive
	ANDI.B	#$f0,(2,A0)
	BRA.S	pt_DrawSampleRefresh
pt_CheckButtonActive:
	TST.W	dat_ButtonActive
	BMI.S	pt_08A8
	ANDI.B	#$0f,(2,A0)
	CMPI.B	#$07,(2,A0)
	BEQ.S	pt_DrawSampleRefresh
	ADDQ.B	#1,(2,A0)
	ANDI.B	#$0f,(2,A0)
pt_DrawSampleRefresh:
	JSR	pt_DrawSampleHex
	BSR.W	pt_RefreshDisplay
	BRA.W	pt_RefreshDisplay
pt_08A8:
	ANDI.B	#$0f,(2,A0)
	CMPI.B	#$08,(2,A0)
	BEQ.S	pt_DrawSampleRefresh
	SUBQ.B	#1,(2,A0)
	ANDI.B	#$0f,(2,A0)
	BRA.S	pt_DrawSampleRefresh
pt_BtnMainSampleVolArrows:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_08AA
	RTS
pt_08AA:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	TST.W	dat_ButtonActive
	BMI.S	pt_08AE
	CMPI.B	#$40,(3,A0)
	BEQ.S	pt_08AD
	ADDQ.B	#1,(3,A0)
	RMB
	BNE.S	pt_08AB
	ADDI.B	#$0f,(3,A0)
pt_08AB:
	CMPI.B	#$40,(3,A0)
	BLS.S	pt_08AC
	MOVE.B	#$40,(3,A0)
pt_08AC:
	BSR.S	pt_08B1
	JSR	pt_InitChannelPtrs
pt_08AD:
	BRA.S	pt_DrawSampleRefresh
pt_08AE:
	SUBQ.B	#1,(3,A0)
	RMB
	BNE.S	pt_08AF
	SUBI.B	#$0f,(3,A0)
pt_08AF:
	TST.B	(3,A0)
	BPL.S	pt_08B0
	CLR.B	(3,A0)
pt_08B0:
	BSR.S	pt_08B1
	JSR	pt_InitChannelPtrs
	BRA.W	pt_DrawSampleRefresh
pt_08B1:
	LEA	dat_Channel1,A1
	BSR.S	pt_CheckCurSample
	LEA	dat_Channel2,A1
	BSR.S	pt_CheckCurSample
	LEA	dat_Channel3,A1
	BSR.S	pt_CheckCurSample
	LEA	dat_Channel4,A1
	BSR.S	pt_CheckCurSample
	RTS
pt_CheckCurSample:
	MOVE.W	dat_CurrentSample,D0
	CMP.B	(n_pt4_samplenum,A1),D0
	BEQ.S	pt_08B3
	RTS
pt_08B3:
	MOVE.B	(3,A0),(n_volume,A1)
	RTS
pt_BtnMainSampleLenValue:
	MOVE.W	#$0001,dat_PatEdDirty
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_08B5
	JMP	pt_DrawSampleHex
pt_08B5:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEQ	#0,D2
	MOVE.W	(A0),D2
	ADD.L	D2,D2
	MOVEQ	#6,D3
	MOVE.W	#$00a9,D0
	MOVEQ	#91,D1
	BSR.W	pt_DiskOpPrepare
	MOVEM.L	(A7)+,D1-D7/A0-A6
	CMP.L	#$0000fffe,D0
	BMI.S	pt_08B6
	MOVE.L	#$0000fffe,D0
pt_08B6:
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
	BSR.W	pt_LoadSamplePtrTbl
	BRA.W	pt_DrawSampleHexUI
pt_BtnMainSampleLenArrows:
	MOVE.W	#$0001,dat_PatEdDirty
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_08B8
	JMP	pt_DrawHexValue
pt_08B8:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	TST.W	dat_ButtonActive
	BMI.S	pt_08BB
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	ADDQ.L	#1,D0
	RMB
	BNE.S	pt_08B9
	CMP.L	#$0000ffe0,D0
	BCC.S	pt_08B9
	ADDQ.L	#7,D0
pt_08B9:
	CMP.L	#$00007fff,D0
	BCS.S	pt_08BA
	MOVE.L	#$00007fff,D0
pt_08BA:
	MOVE.W	D0,(A0)
	JMP	pt_DrawHexValue
pt_08BB:
	MOVEQ	#0,D0
	MOVE.W	(4,A0),D0
	ADD.W	(6,A0),D0
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	SUBQ.L	#1,D1
	RMB
	BNE.S	pt_08BC
	SUBQ.L	#7,D1
pt_08BC:
	BMI.S	pt_08BD
	CMP.L	D1,D0
	BLS.S	pt_StoreAndDrawHex
	MOVE.L	D0,D1
	BRA.S	pt_StoreAndDrawHex
pt_08BD:
	MOVEQ	#0,D1
pt_StoreAndDrawHex:
	MOVE.W	D1,(A0)
	JMP	pt_DrawHexValue
dat_PatEdDirty:
	DS.W	1
pt_SampleLenChanged:
	TSTPC.W	dat_PatEdDirty
	BNE.S	pt_SampleLenChanged2
	RTS
pt_SampleLenChanged2:
	CLR.W	dat_PatEdDirty
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_SampleLenCheck
	RTS
pt_SampleLenCheck:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVE.L	D0,D1
	LSL.W	#2,D1
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	LEA	dat_ModulePtr,A1
	LEA	(0,A1,D1.W),A1
	MOVE.L	A0,dat_SampleDataVar
	MOVE.L	A1,dat_EffectDataPtr
	MOVE.L	(124,A1),D0
	LSR.L	#1,D0
	MOVE.W	(A0),D1
	CMP.W	D0,D1
	BHI.S	pt_SampleLenAskWorkspace
	RTS
pt_SampleLenAskWorkspace:
	LEA	(dat_08C8,PC),A0
	JSR	pt_ShowYesNoDialog
	BNE.S	pt_08C6
	BSR.W	pt_StopAllAudio
	MOVEA.L	dat_SampleDataVar,A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	LSL.L	#1,D0
	MOVE.L	D0,dat_08CC
	MOVE.L	(dat_DiskOpViewMode,PC),D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_08CB
	BEQ.S	pt_08C6
	MOVEA.L	D0,A1
	MOVEA.L	dat_EffectDataPtr,A0
	MOVE.L	(A0),D0
	BEQ.S	pt_08C5
	MOVEA.L	D0,A2
	MOVE.L	(124,A0),D1
	BEQ.S	pt_08C5
pt_08C4:
	MOVE.B	(A2)+,(A1)+
	SUBQ.L	#1,D1
	BPL.S	pt_08C4
	MOVEA.L	(A0),A1
	MOVE.L	(124,A0),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_08C5:
	MOVEA.L	dat_EffectDataPtr,A0
	MOVE.L	dat_08CB,(A0)
	MOVE.L	dat_08CC,(124,A0)
	JSR	pt_DrawSampleHex
	JSR	pt_RecordModeHandler
	JMP	pt_WaitMouseRelease
pt_08C6:
	MOVEA.L	dat_SampleDataVar,A0
	MOVEA.L	dat_EffectDataPtr,A1
	MOVE.L	(124,A1),D0
	LSR.L	#1,D0
	MOVE.W	D0,(A0)
pt_08C7:
	JMP	pt_DrawSampleHex
dat_08C8:
	DC.B	10,10
	DC.B	"  add workspace ?",0
dat_SampleDataVar:
	DS.L	1
dat_EffectDataPtr:
	DS.L	1
dat_08CB:
	DS.L	1
dat_08CC:
	DS.L	1
pt_BtnMainRepeatValue:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	BEQ.S	pt_08C7
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEQ	#0,D2
	MOVE.W	(4,A0),D2
	ADD.L	D2,D2
	MOVEQ	#6,D3
	MOVE.W	#$00a9,D0
	MOVEQ	#102,D1
	BSR.W	pt_DiskOpPrepare
	MOVEM.L	(A7)+,D1-D7/A0-A6
	LSR.L	#1,D0
	MOVE.W	D0,(4,A0)
	BSR.W	pt_LoadSamplePtrTbl
	BRA.S	pt_DrawSampleHexUI
pt_BtnMainRepeatArrows:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	TST.W	dat_ButtonActive
	BMI.S	pt_08D1
	ADDQ.W	#4,(4,A0)
	RMB
	BNE.S	pt_08CF
	ADDQ.W	#7,(4,A0)
pt_08CF:
	MOVE.W	(A0),D0
	BEQ.S	pt_DrawSampleHexUI
	SUB.W	(6,A0),D0
	CMP.W	(4,A0),D0
	BHI.S	pt_DrawSampleHexUI
	MOVE.W	D0,(4,A0)
pt_DrawSampleHexUI:
	JSR	pt_DrawSampleHex
	BSR.W	pt_InitChannelPlay
	JSR	dat_11EC
	RTS
pt_08D1:
	SUBQ.W	#4,(4,A0)
	RMB
	BNE.S	pt_08D2
	SUBQ.W	#7,(4,A0)
pt_08D2:
	TST.W	(4,A0)
	BPL.S	pt_DrawSampleHexUI
	CLR.W	(4,A0)
	BRA.S	pt_DrawSampleHexUI
pt_BtnMainReplenValue:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_08D4
	JMP	pt_DrawSampleHex
pt_08D4:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEQ	#0,D2
	MOVE.W	(6,A0),D2
	ADD.L	D2,D2
	MOVEQ	#6,D3
	MOVE.W	#$00a9,D0
	MOVEQ	#113,D1
	BSR.W	pt_DiskOpPrepare
	MOVEM.L	(A7)+,D1-D7/A0-A6
	LSR.L	#1,D0
	MOVE.W	D0,(6,A0)
	BSR.W	pt_LoadSamplePtrTbl
	BRA.S	pt_DrawSampleHexUI
pt_BtnMainReplenArrows:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	TST.W	dat_ButtonActive
	BMI.S	pt_GetSampleOffset
	ADDQ.W	#4,(6,A0)
	RMB
	BNE.S	pt_08D6
	ADDQ.W	#7,(6,A0)
pt_08D6:
	MOVE.W	(A0),D0
	BEQ.W	pt_DrawSampleHexUI
	SUB.W	(4,A0),D0
	CMP.W	(6,A0),D0
	BHI.W	pt_DrawSampleHexUI
	BRA.S	pt_08D8
pt_GetSampleOffset:
	MOVEQ	#0,D0
	MOVE.W	(6,A0),D0
	SUBQ.L	#4,D0
	RMB
	BNE.S	pt_08D8
	SUBQ.L	#7,D0
	SUBQ.L	#7,D0
pt_08D8:
	CMP.L	#$00000001,D0
	BGE.S	pt_08D9
	MOVEQ	#1,D0
pt_08D9:
	MOVE.W	D0,(6,A0)
	BRA.W	pt_DrawSampleHexUI
pt_RefreshDisplay:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#2,D1
	JSR	(-198,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_LoadSamplePtrTbl:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_08DC
	JMP	pt_DrawSampleHex
pt_08DC:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	(A0),D0
	MOVE.W	(4,A0),D1
	MOVE.W	(6,A0),D2
	CMP.L	D1,D0
	BPL.S	pt_08DD
	MOVE.L	D0,D1
pt_08DD:
	MOVE.L	D1,D3
	ADD.L	D2,D3
	CMP.L	D3,D0
	BPL.S	pt_08DE
	MOVE.L	D0,D2
	SUB.L	D1,D2
pt_08DE:
	TST.L	D2
	BNE.S	pt_SetSampleParams
	MOVEQ	#1,D2
pt_SetSampleParams:
	MOVE.W	D1,(4,A0)
	MOVE.W	D2,(6,A0)
	MOVEQ	#0,D0
	MOVE.B	(3,A0),D0
	CMP.W	#$0040,D0
	BMI.S	pt_08E0
	MOVEQ	#64,D0
pt_08E0:
	MOVE.B	D0,(3,A0)
	RTS
pt_InitChannelPlay:
	LEA	dat_Channel1,A1
	LEA	AUD0LCH,A2
	LEA	dat_ScopeChanPos,A3
	BSR.S	pt_GetCurSampleIdx
	LEA	dat_Channel2,A1
	LEA	AUD1LCH,A2
	LEA	dat_1523,A3
	BSR.S	pt_GetCurSampleIdx
	LEA	dat_Channel3,A1
	LEA	AUD2LCH,A2
	LEA	dat_1524,A3
	BSR.S	pt_GetCurSampleIdx
	LEA	dat_Channel4,A1
	LEA	AUD3LCH,A2
	LEA	dat_1525,A3
pt_GetCurSampleIdx:
	MOVE.W	dat_CurrentSample,D0
	CMP.B	(n_pt4_samplenum,A1),D0
	BEQ.S	pt_08E3
	RTS
pt_08E3:
	MOVEA.L	(n_start,A1),A1
	MOVEQ	#0,D0
	MOVE.W	(4,A0),D0
	ADDA.L	D0,A1
	ADDA.L	D0,A1
	MOVE.L	A1,(A2)
	MOVE.W	(6,A0),D0
	MOVE.W	D0,(4,A2)
	MOVE.L	A1,(8,A3)
	ADDA.L	D0,A1
	ADDA.L	D0,A1
	MOVE.L	A1,(12,A3)
	RTS
pt_PatViewSetRowReplayer:
	MOVE.L	dat_RpPatternPos,D0
	LSR.L	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatViewSetRow2
	LSR.L	#1,D0
	BRA.S	pt_PatViewSetRow2
pt_PatViewSetRow:
	MOVE.W	dat_PatternPosition,D0
pt_PatViewSetRow2:
	TST.W	dat_SamplerActive
	BNE.S	pt_PatViewHideScrollbar
	MOVE.W	D0,-(A7)
	MOVE.W	D0,dat_PatViewRow
	MULU	#$0280,D0
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	LEA	(11680,A0),A0
	ADD.L	A0,D0
	MOVEA.L	dat_CopPatBplPtr,A1
	MOVE.W	D0,(6,A1)
	SWAP	D0
	MOVE.W	D0,(2,A1)
	SWAP	D0
	MOVE.W	#$013d,D0
	MOVE.W	(A7)+,D1
	MULU	#$004f,D1
	LSR.L	#6,D1
	ADD.W	#$0097,D1
	MOVE.W	#$0018,D2
	LEA	dat_SprScrollbar,A0
	JMP	pt_DrawSprite
pt_PatViewHideScrollbar:
	MOVEQ	#-32,D0
	MOVE.W	#$0097,D1
	MOVEQ	#24,D2
	LEA	dat_SprScrollbar,A0
	JMP	pt_DrawSprite
dat_PatViewRow:
	DS.W	1
dat_SampleEditVar2:
	DS.W	1
pt_InputPatternArea:
	TST.W	dat_SamplerActive
	BEQ.S	pt_08EB
	JMP	pt_InputSampler
pt_08EB:
	SF	dat_CopyControlData
	MOVEM.W	dat_EditDigitValue,D0-D1
	CMP.W	#$007b,D1
	BCC.S	pt_08EC
	RTS
pt_08EC:
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_08ED
	LEA	dat_1432,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_08EE
	RTS
pt_08ED:
	LEA	dat_1433,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_08EE
	RTS
pt_08EE:
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_08F0
	CMP.W	#$0005,D2
	BNE.S	pt_08EF
	JMP	pt_IncTempo
pt_08EF:
	CMP.W	#$0006,D2
	BNE.S	pt_08F0
	JMP	pt_DecTempo
pt_08F0:
	CMP.W	#$0029,D2
	BNE.S	pt_08F1
	JMP	pt_03A4
pt_08F1:
	CMP.W	#$002a,D2
	BNE.S	pt_08F2
	JMP	pt_03A7
pt_08F2:
	CMP.W	#$002b,D2
	BNE.S	pt_08F3
	JMP	pt_03AA
pt_08F3:
	CMP.W	#$002c,D2
	BNE.S	pt_08F4
	JMP	pt_03AD
pt_08F4:
	CMP.W	#$002d,D2
	BNE.W	pt_08F5
	JMP	pt_03B0
pt_08F5:
	CMP.W	#$002e,D2
	BNE.W	pt_CheckSlashKey
	JMP	pt_03B1
pt_CheckSlashKey:
	CMP.W	#$002f,D2
	BNE.W	pt_08F7
	JMP	pt_03B2
pt_08F7:
	CMP.W	#$0030,D2
	BNE.W	pt_08F8
	JMP	pt_03B3
pt_08F8:
	CMP.W	#$0031,D2
	BEQ.W	pt_BtnTrack1Head
	CMP.W	#$0032,D2
	BEQ.W	pt_BtnTrack1OnOff
	CMP.W	#$0033,D2
	BEQ.W	pt_BtnTrack2Head
	CMP.W	#$0034,D2
	BEQ.W	pt_BtnTrack2OnOff
	CMP.W	#$0035,D2
	BEQ.W	pt_BtnTrack3Head
	CMP.W	#$0036,D2
	BEQ.W	pt_BtnTrack3OnOff
	CMP.W	#$0037,D2
	BEQ.W	pt_BtnTrack4Head
	CMP.W	#$0038,D2
	BEQ.W	pt_BtnTrack4OnOff
	CMPI.L	#$70617470,dat_RpPlayMode
	BNE.S	pt_08F9
	RTS
pt_08F9:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnPatPosField
	CMP.W	#$0007,D2
	BEQ.W	pt_092B
	CMP.W	#$0008,D2
	BEQ.W	pt_AdvancePatTable
	MOVEM.L	D2,-(A7)
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVEM.L	(A7)+,D2
	TST.L	dat_RpPlayMode
	BEQ.S	pt_08FA
	RTS
pt_08FA:
	CMP.W	#$0004,D2
	BEQ.W	pt_CalcPatternOfs
	RTS
pt_08FB:
	ST	dat_CopyControlData
	MOVEM.W	dat_EditDigitValue,D0-D1
	CMP.W	#$007b,D1
	BCC.S	pt_08FC
	RTS
pt_08FC:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_08FD
	LEA	dat_1435,A0
	BRA.S	pt_08FE
pt_08FD:
	LEA	dat_1434,A0
pt_08FE:
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_08FF
	RTS
pt_08FF:
	CMP.W	#$0029,D2
	BNE.S	pt_CheckStarKey
	JMP	pt_03A4
pt_CheckStarKey:
	CMP.W	#$002a,D2
	BNE.S	pt_0901
	JMP	pt_03A7
pt_0901:
	CMP.W	#$002b,D2
	BNE.S	pt_0902
	JMP	pt_03AA
pt_0902:
	CMP.W	#$002c,D2
	BNE.S	pt_0903
	JMP	pt_03AD
pt_0903:
	CMP.W	#$002d,D2
	BNE.W	pt_0904
	JMP	pt_03B0
pt_0904:
	CMP.W	#$002e,D2
	BNE.W	pt_0905
	JMP	pt_03B1
pt_0905:
	CMP.W	#$002f,D2
	BNE.W	pt_CheckDigitZero
	JMP	pt_03B2
pt_CheckDigitZero:
	CMP.W	#$0030,D2
	BNE.S	pt_0907
	JMP	pt_03B3
pt_0907:
	RTS
pt_BtnTrack1Head:
	RMB
	BEQ.S	pt_0909
	JMP	pt_ScopeCh1Toggle
pt_0909:
	NOT.B	dat_Channel1+n_pt4_chanoff
	BRA.W	pt_AudioChannelUpdate
pt_BtnTrack1OnOff:
	RMB
	BEQ.S	pt_090B
	JMP	pt_ScopeCh2Toggle
pt_090B:
	NOT.B	dat_Channel2+n_pt4_chanoff
	BRA.W	pt_AudioChannelUpdate
pt_BtnTrack2Head:
	RMB
	BEQ.S	pt_090D
	JMP	pt_ScopeCh3Toggle
pt_090D:
	NOT.B	dat_Channel3+n_pt4_chanoff
	BRA.W	pt_AudioChannelUpdate
pt_BtnTrack2OnOff:
	RMB
	BEQ.S	pt_090F
	JMP	pt_ScopeCh4Toggle
pt_090F:
	NOT.B	dat_Channel4+n_pt4_chanoff
	BRA.S	pt_AudioChannelUpdate
pt_BtnTrack3Head:
	RMB
	BEQ.S	pt_0911
	JMP	pt_012F
pt_0911:
	NOT.B	dat_Channel5+n_pt4_chanoff
	BRA.S	pt_AudioChannelUpdate
pt_BtnTrack3OnOff:
	RMB
	BEQ.S	pt_0913
	JMP	pt_0130
pt_0913:
	NOT.B	dat_Channel6+n_pt4_chanoff
	BRA.S	pt_AudioChannelUpdate
pt_BtnTrack4Head:
	RMB
	BEQ.S	pt_0915
	JMP	pt_0131
pt_0915:
	NOT.B	dat_Channel7+n_pt4_chanoff
	BRA.S	pt_AudioChannelUpdate
pt_BtnTrack4OnOff:
	RMB
	BEQ.S	pt_ToggleAudioFlag
	JMP	pt_0132
pt_ToggleAudioFlag:
	NOT.B	dat_Channel8+n_pt4_chanoff
	BRA.S	pt_AudioChannelUpdate
pt_UpdateChannelState:
	LEA	dat_Channel1,A0
	MOVEQ	#3,D1
pt_0919:
	MOVE.B	(n_pt4_chanoff,A0),D0
	NOT.B	D0
	MOVE.B	D0,(n_pt4_chanon,A0)
	ADDA.W	#n_SIZEOF,A0
	DBF	D1,pt_0919
pt_AudioChannelUpdate:
	TST.W	dat_SamplerActive
	BNE.S	pt_091C
	LEA	dat_Channel1,A5
	MOVEQ	#0,D0
	MOVEQ	#3,D7
	BTST	#5,dat_ModeFlags
	BNE.S	pt_091B
	MOVEQ	#7,D7
pt_091B:
	BSR.S	pt_SaveRegsProcess
	ADDQ.W	#1,D0
	ADDA.W	#n_SIZEOF,A5
	DBF	D7,pt_091B
	CLR.W	dat_KeyRepeatDelay
pt_091C:
	RTS
pt_SaveRegsProcess:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.B	(n_pt4_chanoff,A5),D1
	TST.W	dat_KeyRepeatDelay
	BNE.S	pt_091E
	CMP.B	(n_pt4_chanon,A5),D1
	BEQ.W	pt_0924
pt_091E:
	MOVE.B	D1,(n_pt4_chanon,A5)
	MOVE.W	D0,D6
	MULU	#$0048,D0
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_091F
	LSL.L	#1,D0
	ADD.W	#$0020,D0
pt_091F:
	ADD.W	#$0030,D0
	MOVE.W	D0,D2
	ADD.W	#$0060,D2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0920
	SUB.W	#$0020,D2
pt_0920:
	MOVE.W	#$008d,D1
	MOVE.W	#$0093,D3
	MOVEQ	#2,D5
	JSR	pt_WaitAndRedrawUI
	LEA	(dat_0925,PC),A0
	MOVEA.L	A0,A1
	MOVEA.L	A0,A2
	MOVEQ	#8,D3
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_0921
	ADDA.W	#$000a,A0
	ADDA.W	#$000d,A1
	ADDA.W	#$000e,A2
	ADDQ.L	#4,D3
pt_0921:
	ADDQ.L	#4,A1
	ADDQ.L	#4,A2
	MOVEQ	#0,D2
	MOVE.W	dat_RpDmaChanMask,D2
	BTST	D6,D2
	BNE.S	pt_0922
	MOVE.L	#$204f4646,(A2)
	BRA.S	pt_0923
pt_0922:
	MOVE.L	#$204f4e20,(A2)
pt_0923:
	ADD.B	#$31,D6
	MOVE.B	D6,(A1)
	ADDQ.W	#1,D0
	ADDQ.W	#1,D1
	MOVEQ	#3,D2
	JSR	pt_SaveAllRegsProc
	TST.B	(44,A5)
	BNE.S	pt_0924
	SUBQ.W	#1,D0
	SUBQ.W	#1,D1
	MOVEQ	#1,D2
	JSR	pt_SaveAllRegsProc
pt_0924:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_0925:
	DC.B	"TRK#x   ",0,0
	DC.B	"TRACK #x    ",0,0
dat_KeyRepeatDelay:
	DS.W	1
pt_CheckPatpMagic:
	CMPI.L	#$70617470,dat_RpPlayMode
	BNE.S	pt_AdvancePatTable
	RTS
pt_AdvancePatTable:
	ADDQ.L	#1,dat_PatTableIdx
	MOVE.L	dat_PatTableIdx,D0
	CMP.L	(dat_SampleEditState,PC),D0
	BLE.S	pt_0929
	CLR.L	dat_PatTableIdx
pt_0929:
	BRA.S	pt_GetPatTableIdx
pt_092A:
	CMPI.L	#$70617470,dat_RpPlayMode
	BNE.S	pt_092B
	RTS
pt_092B:
	SUBQ.L	#1,dat_PatTableIdx
	TST.L	dat_PatTableIdx
	BPL.S	pt_GetPatTableIdx
	MOVE.L	(dat_SampleEditState,PC),dat_PatTableIdx
	BRA.S	pt_GetPatTableIdx
pt_BtnPatPosField:
	MOVE.W	#$0156,dat_PlayCounter
	MOVE.W	#$0085,dat_PatternDelay
	MOVE.W	#$0152,D4
	MOVE.W	#$0080,D5
	BSR.W	pt_0CAE
	TST.W	dat_PaletteDirtyFlag
	BNE.S	pt_092E
	MOVE.B	D0,dat_1370
pt_GetPatTableIdx:
	MOVE.L	dat_PatTableIdx,D0
	CMP.L	(dat_SampleEditState,PC),D0
	BLS.S	pt_092E
	MOVE.L	(dat_SampleEditState,PC),dat_PatTableIdx
pt_092E:
	JMP	pt_PatViewDrawAll
pt_UIRefreshLoop:
	BSR.W	pt_ScreenDragUpdate
	RMB
	BEQ.S	pt_SetLineCount68
	MOVEQ	#0,D0
	JSR	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	BEQ.S	pt_UIRefreshLoop
	CMP.B	#$44,D0
	BEQ.S	pt_SetLineCount68
	CMP.B	#$45,D0
	BEQ.S	pt_SetLineCount68
	CMP.B	#$0a,D0
	BEQ.S	pt_0930
	BHI.S	pt_UIRefreshLoop
	CMP.B	#$01,D0
	BCS.S	pt_UIRefreshLoop
	MOVE.L	D0,D1
	JSR	pt_ClearKeyState
	RTS
pt_0930:
	MOVEQ	#0,D1
	JSR	pt_ClearKeyState
	RTS
pt_SetLineCount68:
	MOVEQ	#68,D1
	JSR	pt_ClearKeyState
	RTS
pt_ConvertDecChar:
	ADD.B	#$30,D1
	MOVE.B	D1,dat_DecimalDigitBuf
	CLR.W	D1
	SWAP	D1
	MOVE.W	#$0001,dat_TextCharCount
	MOVE.L	#dat_DecimalDigitBuf,dat_TextStringPtr
	JSR	pt_DrawTextRender
	CLR.L	dat_DecimalDigitBuf
	CLR.W	dat_DisplayParam
	RTS
pt_0933:
	ADD.B	#$30,D3
	MOVE.B	D3,dat_DecimalDigitBuf
	CLR.W	D3
	SWAP	D3
	MOVEQ	#1,D3
	MOVEA.L	#dat_DecimalDigitBuf,A0
	MOVE.W	#$0203,D2
	JSR	pt_SaveRegsAudioProc
	CLR.L	dat_DecimalDigitBuf
	CLR.W	dat_DisplayParam
	RTS
pt_CalcPatternOfs:
	MOVE.W	dat_PatternPosition,D0
	MULU	#$004f,D0
	LSR.L	#6,D0
	ADD.W	#$0097,D0
	SUB.W	D0,D1
	BMI.S	pt_0939
	CMP.W	#$0018,D1
	BPL.W	pt_093B
	BSR.W	pt_093E
	MOVE.W	D1,D2
	MOVE.W	dat_PalEdSelectPos,D1
pt_0935:
	BSR.W	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_CallAndReturn
	MOVE.W	D1,D3
	MOVE.W	dat_PalEdSelectPos,D1
	CMP.W	D3,D1
	BEQ.S	pt_0935
	SUB.W	D2,D1
	SUB.W	#$0097,D1
	MULS	#$0040,D1
	DIVS	#$004f,D1
	TST.W	D1
	BPL.S	pt_0936
	MOVEQ	#0,D1
pt_0936:
	CMP.W	#$003f,D1
	BMI.S	pt_0937
	MOVEQ	#63,D1
pt_0937:
	MOVE.W	D1,dat_PatternPosition
	MOVE.W	D2,-(A7)
	BSR.W	pt_PatViewSetRow
	MOVE.W	(A7)+,D2
	LMB
	BEQ.S	pt_0935
pt_CallAndReturn:
	BSR.S	pt_093D
	RTS
pt_0939:
	SUBI.W	#$0013,dat_PatternPosition
	BPL.S	pt_093A
	CLR.W	dat_PatternPosition
pt_093A:
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#1,D1
	JSR	(-198,A6)
	BRA.W	pt_PatViewSetRow
pt_093B:
	ADDI.W	#$0013,dat_PatternPosition
	CMPI.W	#$003f,dat_PatternPosition
	BMI.S	pt_093C
	MOVE.W	#$003f,dat_PatternPosition
pt_093C:
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#1,D1
	JSR	(-198,A6)
	BRA.W	pt_PatViewSetRow
pt_093D:
	MOVE.L	#$f800f000,D4
	MOVE.L	#$f0008800,D5
	MOVE.L	#$80007800,D6
	BRA.S	pt_093F
pt_093E:
	MOVE.L	#$0800f000,D4
	MOVE.L	#$78008800,D5
	MOVE.L	#$f8007800,D6
pt_093F:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_14BD-1,A0
	MOVEQ	#21,D0
	MOVE.L	D4,(A0)+
pt_0940:
	MOVE.L	D5,(A0)+
	DBF	D0,pt_0940
	MOVE.L	D6,(A0)+
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_StoreFxParameter:
	MOVE.W	D0,dat_EffectCmdVar
	MOVE.W	D1,dat_NoteParamVar
	MOVE.W	#$ffff,dat_NoteTableIdx
	SUBA.W	A4,A4
	BRA.S	pt_0943
pt_UpdateKeyState:
	MOVE.B	dat_KeyUpDown,dat_KeyModifiers
	ST	dat_KeyUpDown
	CLR.W	dat_NoteTableIdx
pt_0943:
	MOVEQ	#0,D0
	MOVE.W	A4,D0
	DIVU	#$0050,D0
	ADDQ.W	#5,D0
	MOVE.W	D0,dat_PatternDelay
	SWAP	D0
	LSL.W	#3,D0
	ADDQ.W	#4,D0
	MOVE.W	D0,dat_PlayCounter
	TST.W	dat_NoteTableIdx
	BEQ.S	pt_DrawPlayRender
	MOVE.W	(dat_EffectCmdVar,PC),D0
	ADDQ.W	#4,D0
	MOVE.W	D0,dat_PlayCounter
	MOVE.W	(dat_NoteParamVar,PC),D0
	ADDQ.W	#5,D0
	MOVE.W	D0,dat_PatternDelay
pt_DrawPlayRender:
	BSR.W	pt_DrawPlayCounter
	MOVE.L	dat_TextStringPtr,dat_TextRenderPtr
	CLR.L	dat_TextRenderOffset
	CLR.L	dat_TextBufAddr
	MOVE.W	#$0001,dat_TimingMode
	MOVEA.L	A4,A5
	MOVE.W	dat_PlayCounter,D5
	CLR.B	dat_KeyCode
	BSR.W	pt_TextRenderConditional
pt_ProcessKeyInput:
	CLR.B	dat_KeyCode
	MOVE.B	dat_KeyCode,dat_LastKeyStored
	TST.B	dat_KeyModifiers
	BSR.W	pt_ScreenDragUpdate
	RMB
	BEQ.W	pt_0966
	LMB
	BEQ.W	pt_0951
	JSR	pt_GetKeypress
	JSR	pt_HandleSampleKeys
	MOVEQ	#0,D1
	MOVE.B	dat_KeyCode,D1
	BEQ.S	pt_ProcessKeyInput
	CMP.B	#$4e,D1
	BEQ.W	pt_095E
	CMP.B	#$4f,D1
	BEQ.W	pt_095F
	CMPI.B	#$02,dat_PlayMode
	BEQ.S	pt_0946
	CMP.B	#$46,D1
	BEQ.W	pt_095C
	CMP.B	#$41,D1
	BEQ.W	pt_0959
pt_0946:
	CMP.B	#$44,D1
	BEQ.W	pt_KeyboardHandler
	CMP.B	#$45,D1
	BEQ.W	pt_0961
	BTST	#7,D1
	BNE.W	pt_ProcessKeyInput
	CMPI.B	#$01,dat_PatternBufSize
	BNE.S	pt_0947
	LEA	dat_132E,A4
	BRA.S	pt_0949
pt_0947:
	TST.B	dat_PatternBufSize
	BEQ.S	pt_0948
	TST.W	dat_KeymapBufPtr
	BEQ.S	pt_0948
	MOVEA.L	dat_KeymapBufPtr,A4
	BRA.S	pt_0949
pt_0948:
	LEA	dat_1330,A4
pt_0949:
	MOVE.B	dat_KeyQual1,D0
	AND.B	#$03,D0
	TST.W	dat_KeyQual1
	BEQ.S	pt_MaskLow7Bits
	CMPI.B	#$01,dat_PatternBufSize
	BNE.S	pt_094A
	LEA	dat_132F,A4
	BRA.S	pt_MaskLow7Bits
pt_094A:
	TST.B	dat_PatternBufSize
	BEQ.S	pt_InitNoteTable
	TST.W	dat_KeymapBufPtr
	BEQ.S	pt_InitNoteTable
	MOVEA.L	dat_KeymapBufPtr,A4
	ADDA.W	#$0065,A4
	BRA.S	pt_MaskLow7Bits
pt_InitNoteTable:
	LEA	dat_1331,A4
pt_MaskLow7Bits:
	AND.W	#$007f,D1
	CMP.B	#$40,D1
	BHI.W	pt_ProcessKeyInput
	MOVE.B	(0,A4,D1.W),D1
	BEQ.W	pt_ProcessKeyInput
	TST.B	dat_PlayMode
	BEQ.S	pt_094E
	CMP.B	#$30,D1
	BCS.W	pt_ProcessKeyInput
	CMP.B	#$66,D1
	BHI.W	pt_ProcessKeyInput
	CMPI.B	#$02,dat_PlayMode
	BEQ.S	pt_094D
	CMP.B	#$61,D1
	BCC.S	pt_094E
pt_094D:
	CMP.B	#$39,D1
	BHI.W	pt_ProcessKeyInput
pt_094E:
	CMPA.L	dat_SongDataAddr,A6
	BEQ.W	pt_ProcessKeyInput
	CMPI.B	#$02,dat_PlayMode
	BEQ.S	pt_0950
	MOVEA.L	dat_SongDataAddr,A4
pt_094F:
	MOVE.B	-(A4),(1,A4)
	CMPA.L	A4,A6
	BNE.S	pt_094F
pt_0950:
	MOVEA.L	dat_SongDataAddr,A4
	CLR.B	(A4)
	MOVE.B	D1,(A6)+
	BSR.S	pt_GetTextBufAddr
	BSR.W	pt_TextRenderConditional
	CLR.B	dat_KeyCode
	BRA.W	pt_ProcessKeyInput
pt_0951:
	MOVE.W	dat_PalEdSelectPos,D1
	SUB.W	dat_PatternDelay,D1
	CMP.W	#$0002,D1
	BGT.W	pt_KeyboardHandler
	CMP.W	#$fff8,D1
	BLT.W	pt_KeyboardHandler
	MOVE.W	dat_EditDigitValue,D1
	SUB.W	dat_PlayCounter,D1
	ADDQ.W	#4,D1
	ASR.W	#3,D1
	BEQ.W	pt_ProcessKeyInput
	BPL.S	pt_0953
	CMPA.L	(dat_TextRenderPtr,PC),A6
	BEQ.W	pt_ProcessKeyInput
	SUBQ.L	#1,A6
	BSR.S	pt_CheckTextBufAddr
pt_0952:
	BSR.W	pt_TextRenderConditional
	BRA.W	pt_ProcessKeyInput
pt_0953:
	CMPA.L	dat_SongDataAddr,A6
	BEQ.W	pt_ProcessKeyInput
	TST.B	(A6)
	BEQ.W	pt_ProcessKeyInput
	ADDQ.L	#1,A6
	BSR.S	pt_GetTextBufAddr
	BRA.S	pt_0952
pt_GetTextBufAddr:
	MOVE.L	dat_TextBufAddr,D0
	MOVEQ	#0,D1
	MOVE.W	dat_TextCharCount,D1
	TST.B	dat_PlayMode
	BNE.S	pt_CompareBranch
	SUBQ.W	#1,D1
pt_CompareBranch:
	CMP.L	D1,D0
	BCS.S	pt_0956
	ADDQ.L	#1,dat_TextRenderOffset
	BRA.W	pt_DrawPlayCounter
pt_0956:
	ADDQ.L	#1,dat_TextBufAddr
	ADDQ.W	#8,dat_PlayCounter
	BRA.W	pt_DrawPlayCounter
pt_CheckTextBufAddr:
	TST.L	dat_TextBufAddr
	BNE.S	pt_0958
	SUBQ.L	#1,dat_TextRenderOffset
	BRA.W	pt_DrawPlayCounter
pt_0958:
	SUBQ.L	#1,dat_TextBufAddr
	SUBQ.W	#8,dat_PlayCounter
	BRA.W	pt_DrawPlayCounter
pt_0959:
	CMPA.L	(dat_TextRenderPtr,PC),A6
	BEQ.W	pt_ProcessKeyInput
	SUBQ.L	#1,A6
	MOVEA.L	A6,A4
pt_095A:
	MOVE.B	(1,A4),(A4)+
	CMPA.L	dat_SongDataAddr,A4
	BNE.S	pt_095A
	BSR.S	pt_CheckTextBufAddr
pt_RenderTextCond:
	BSR.W	pt_TextRenderConditional
	BRA.W	pt_ProcessKeyInput
pt_095C:
	MOVEA.L	A6,A4
pt_095D:
	MOVE.B	(1,A4),(A4)+
	CMPA.L	dat_SongDataAddr,A4
	BCS.S	pt_095D
	BRA.S	pt_RenderTextCond
pt_095E:
	CMPA.L	dat_SongDataAddr,A6
	BEQ.W	pt_ProcessKeyInput
	TST.B	(A6)
	BEQ.W	pt_ProcessKeyInput
	ADDQ.L	#1,A6
	BSR.W	pt_GetTextBufAddr
	BRA.S	pt_RenderTextCond
pt_095F:
	CMPA.L	(dat_TextRenderPtr,PC),A6
	BEQ.W	pt_ProcessKeyInput
	SUBQ.L	#1,A6
	BSR.S	pt_CheckTextBufAddr
	BRA.S	pt_RenderTextCond
pt_KeyboardHandler:
	MOVE.B	dat_KeyModifiers,dat_KeyUpDown
	MOVE.W	#$ffff,dat_NoteValueVar
	BRA.S	pt_0962
pt_0961:
	CLR.W	dat_NoteValueVar
pt_0962:
	JSR	pt_ClearKeyState
	MOVEA.L	dat_TextRenderPtr,A6
	MOVEA.L	A6,A4
pt_0963:
	TST.B	(A4)+
	BNE.S	pt_0963
	SUBQ.L	#1,A4
pt_0964:
	CMPA.L	dat_SongDataAddr,A4
	BCC.S	pt_0965
	CLR.B	(A4)+
	BRA.S	pt_0964
pt_0965:
	CLR.W	dat_PlayCounter
	MOVE.W	#$010e,dat_PatternDelay
	BSR.W	pt_DrawPlayCounter
	CLR.W	dat_TimingMode
	MOVE.B	dat_KeyCode,dat_LastKeyStored
	JSR	pt_ClearKeyState
	CLR.L	dat_TextRenderOffset
	BSR.S	pt_TextRenderConditional
	JSR	pt_WaitMouseRelease
	TST.W	dat_NoteValueVar
	RTS
pt_0966:
	MOVEA.L	dat_TextRenderPtr,A6
	MOVEA.L	A6,A4
pt_0967:
	CLR.B	(A4)+
	CMPA.L	dat_SongDataAddr,A4
	BNE.S	pt_0967
	BSR.S	pt_TextRenderConditional
	BRA.W	pt_KeyboardHandler
pt_TextRenderConditional:
	TST.W	dat_NoteTableIdx
	BEQ.S	pt_0969
	MOVEM.L	D0-D1/D3,-(A7)
	MOVE.W	(dat_EffectCmdVar,PC),D0
	MOVE.W	(dat_NoteParamVar,PC),D1
	MOVEA.L	dat_TextRenderPtr,A0
	ADDA.L	dat_TextRenderOffset,A0
	MOVE.W	dat_TextCharCount,D3
	JSR	pt_BlitPatternFull
	MOVEM.L	(A7)+,D0-D1/D3
	RTS
pt_0969:
	MOVE.W	A5,dat_TextBytePos
	MOVEA.L	dat_TextRenderPtr,A0
	ADDA.L	dat_TextRenderOffset,A0
	JMP	pt_DrawTextSetup
pt_DiskOpPrepare:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEM.L	D0-D3,-(A7)
	MOVE.L	D2,D0
	MOVE.L	D3,D1
	LEA	(dat_096B,PC),A0
	JSR	pt_0F89
	CLR.B	(0,A0,D3.W)
	MOVE.L	A0,dat_TextStringPtr
	MOVE.L	A0,dat_SongDataAddr
	ADD.L	D3,dat_SongDataAddr
	MOVE.W	D3,dat_TextCharCount
	MOVEM.L	(A7)+,D0-D3
	MOVE.B	#$02,dat_PlayMode
	MOVE.B	dat_FillChar,D4
	MOVEM.L	D4,-(A7)
	MOVE.B	#$20,dat_FillChar
	MOVEA.L	dat_TextStringPtr,A6
	BSR.W	pt_StoreFxParameter
	MOVEM.L	(A7)+,D4
	MOVE.B	D4,dat_FillChar
	CLR.B	dat_PlayMode
	LEA	(dat_096B,PC),A0
	MOVE.W	dat_TextCharCount,D0
	JSR	pt_0F92
	JSR	pt_RestorePalette
	MOVEM.L	(A7)+,D1-D7/A0-A6
	TST.L	D0
	RTS
dat_096B:
	DS.L	8
dat_NoteValueVar:
	DS.W	1
dat_TextRenderPtr:
	DS.L	1
dat_TextBufAddr:
	DS.L	1
dat_EffectCmdVar:
	DS.W	1
dat_NoteParamVar:
	DS.W	1
dat_NoteTableIdx:
	DS.W	1
dat_TextRenderOffset:
	DS.L	1
pt_BtnMainSongName:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEA.L	dat_ModulePtr,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$00000013,dat_SongDataAddr
	MOVE.W	#$0014,dat_TextCharCount
	MOVEA.W	#$07d8,A4
	BSR.W	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JMP	pt_RestorePalette
pt_BtnMainFileName:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEA.L	dat_ModulePtr,A6
	LEA	(-10,A6),A6
	MOVE.W	dat_CurrentSample,D7
	BNE.S	pt_0975
	MOVE.W	dat_SamplePlayInit,D7
pt_0975:
	MULU	#s_SIZEOF,D7
	ADDA.L	D7,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$00000015,dat_SongDataAddr
	MOVE.W	#$0016,dat_TextCharCount
	MOVEA.W	#$1906,A4
	BSR.W	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JMP	pt_RestorePalette
	MOVEQ	#-1,D2
	BRA.S	pt_r0ee9e
pt_0976:
	MOVEQ	#0,D2
pt_r0ee9e:
	MOVEQ	#0,D1
	CMPI.L	#$464f524d,(A0)
	BNE.S	pt_097A
	CMPI.L	#$38535658,(8,A0)
	BNE.S	pt_097A
	MOVEA.L	A0,A2
	MOVE.L	A1,D0
	ADDA.L	A0,A1
	TST.L	D2
	BEQ.S	pt_0977
	BSR.S	pt_097B
pt_0977:
	CMPI.L	#$424f4459,(A0)
	BEQ.S	pt_0978
	ADDQ.L	#2,A0
	CMPA.L	A1,A0
	BLS.S	pt_0977
	RTS
pt_0978:
	ADDQ.L	#8,A0
	ADD.L	A2,D0
	SUB.L	A0,D0
pt_0979:
	MOVE.B	(A0)+,(A2)+
	CMPA.L	A1,A0
	BLS.S	pt_0979
	MOVEA.L	(dat_EffectCmdPtr,PC),A3
	LSR.L	#1,D0
	MOVE.W	(22,A3),D1
	SUB.W	D0,D1
	MOVE.W	D0,(22,A3)
pt_097A:
	LEA	(dat_EffectParamVar,PC),A3
	MOVE.W	dat_CurrentSample,D0
	LSL.W	#1,D0
	MOVE.W	D1,(0,A3,D0.W)
	RTS
pt_097B:
	BTST	#6,dat_UIStateFlag
	BNE.S	pt_097C
	RTS
pt_097C:
	MOVEM.L	D0/A0,-(A7)
pt_097D:
	CMPI.L	#$56484452,(A0)
	BEQ.S	pt_097F
	ADDQ.L	#2,A0
	CMPA.L	A1,A0
	BLS.S	pt_097D
pt_097E:
	MOVEM.L	(A7)+,D0/A0
	RTS
pt_097F:
	MOVEA.L	(dat_EffectCmdPtr,PC),A3
	MOVE.L	(12,A0),D0
	BEQ.S	pt_097E
	LSR.L	#1,D0
	MOVE.W	D0,(28,A3)
	MOVE.L	(8,A0),D0
	BNE.S	pt_0980
	MOVEQ	#2,D0
pt_0980:
	LSR.L	#1,D0
	MOVE.W	D0,(26,A3)
	BRA.S	pt_097E
dat_EffectCmdPtr:
	DS.L	1
dat_EffectParamVar:
	DS.W	1
dat_0983:
	DS.L	34
pt_DiskOpSetup:
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.L	A0,-(A7)
	JSR	pt_CopyPatternBlock
	MOVEA.L	(A7)+,A0
	LEA	dat_1470,A1
	LEA	dat_1452,A2
	MOVE.L	#$00000460,D0
	JSR	pt_BlitCopyBlock
	LEA	dat_1342,A0
	MOVE.W	#$0112,D0
	MOVEQ	#62,D1
	JSR	pt_DrawBoxedText
pt_UpdateAndContinue:
	BSR.W	pt_ScreenDragUpdate
	JSR	pt_GetKeypress
	JSR	pt_HandleSampleKeys
	LMB
	BNE.S	pt_UpdateAndContinue
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_ScreenConfigData,A0
	JSR	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_UpdateAndContinue
	CMP.W	#$0002,D2
	BEQ.S	pt_0986
	BRA.S	pt_UpdateAndContinue
pt_0986:
	JSR	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	RTS
