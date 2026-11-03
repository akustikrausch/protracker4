pt_CheckRightButton:
	RMB
	BEQ.S	pt_0A1D
	RTS
pt_0A1D:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	dat_12ED,A0
	JSR	pt_ShowYesNoDialog
	BNE.S	pt_0A1E
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D7
	RTS
pt_0A1E:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#-1,D7
	RTS
pt_BtnMainStop:
	BSR.S	pt_StopPlayback
pt_StopAllAudio:
	MOVEM.L	D0/A0-A1,-(A7)
	JSR	pt_AhiStopHw
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	JSR	pt_StopSilence
	LEA	dat_Channel1,A0
	MOVEQ	#3,D0
pt_0A21:
	CLR.B	(n_volume,A0)
	CLR.L	(n_pt4_chunkptr,A0)
	CLR.B	(n_pt4_chunked,A0)
	CLR.B	(n_pt4_b55,A0)
	LEA	(n_SIZEOF,A0),A0
	DBF	D0,pt_0A21
	LEA	dat_ScopeChanPos,A0
	LEA	dat_ScopeDisplayBuf,A1
	MOVE.L	A1,(A0)
	MOVE.L	A1,(20,A0)
	MOVE.L	A1,(40,A0)
	MOVE.L	A1,(60,A0)
	MOVEM.L	(A7)+,D0/A0-A1
	RTS
pt_StopPlayback:
	JSR	pt_SetPaletteBright
	CLR.L	dat_SongDataPtr
	IFD	DEBUGAUTO
	JSR	dbg_StopPb
	ELSE
	CLR.L	dat_RpPlayMode
	ENDC
	CLR.B	dat_PattDelayTime
	CLR.B	dat_PattDelayCount
	BRA.W	pt_0617
pt_0A23:
	JSR	pt_SavePaletteState
	TST.L	dat_EditBufPtr
	BEQ.S	pt_0A26
	TST.W	dat_CurrentSample
	BEQ.S	pt_0A26
	CLR.B	dat_KeyCode
	MOVE.W	dat_12AE,D0
	SUBQ.W	#1,D0
	MULU	#s_SIZEOF,D0
	MOVEA.L	dat_EditBufPtr,A0
	ADDA.L	D0,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	MOVEA.L	dat_ModulePtr,A1
	LEA	(-10,A1,D0.W),A1
	MOVEA.L	A1,A2
	MOVEQ	#29,D0
pt_0A24:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0A24
	MOVE.L	(A2),D0
	AND.L	#$dfdfffff,D0
	CMP.L	#$53540000,D0
	BNE.S	pt_0A25
	CLR.W	(A2)
	CLR.L	(22,A2)
	MOVE.L	#$00000001,(26,A2)
pt_0A25:
	BSR.W	pt_09D7
pt_0A26:
	BSR.W	pt_DrawSampleHex
	JSR	pt_RenderPaletteEdit
	JMP	pt_RestorePalette
pt_OptPageRefresh:
	MOVE.W	(dat_OptPage,PC),D0
	CMP.W	#$0001,D0
	BEQ.W	pt_BtnMainOptPage1
	CMP.W	#$0002,D0
	BEQ.W	pt_BtnMainOptPage2
	CMP.W	#$0003,D0
	BEQ.W	pt_BtnMainOptPage3
	CMP.W	#$0004,D0
	BEQ.W	pt_BtnMainOptPage4
	CMP.W	#$0005,D0
	BEQ.W	pt_BtnMainOptPage5
	CMP.W	#$0006,D0
	BEQ.W	pt_BtnMainOptPage6
	CMP.W	#$0007,D0
	BEQ.W	pt_BtnMainOptPage7
	CMP.W	#$0008,D0
	BEQ.W	pt_BtnSongComment
	RTS
pt_BtnMainEditOptions:
	MOVE.W	(dat_OptPage,PC),D0
	CMP.W	#$0001,D0
	BEQ.S	pt_0A2A
	CMP.W	#$0002,D0
	BEQ.W	pt_0A3B
	CMP.W	#$0003,D0
	BEQ.W	pt_0A3F
	CMP.W	#$0004,D0
	BEQ.W	pt_0A42
	CMP.W	#$0005,D0
	BEQ.W	pt_0AF1
	CMP.W	#$0006,D0
	BEQ.W	pt_0A61
	CMP.W	#$0007,D0
	BEQ.W	pt_0A48
	CMP.W	#$0008,D0
	BEQ.W	pt_0AE7
	RTS
pt_BtnMainOptPage1:
	MOVEQ	#1,D0
	MOVE.W	#$0001,dat_OptPage
	LEA	dat_1457,A0
	BSR.W	pt_OptPageShowBlock
	BSR.W	pt_0CA0
	BSR.W	pt_0CB6
	BSR.W	pt_0CBD
	BSR.W	pt_0CC2
	BSR.W	pt_0CCA
	BSR.W	pt_ShowDisplayField
	BSR.W	pt_0A35
	BSR.W	pt_0BE6
	BSR.W	pt_0A2D
	BSR.W	pt_0680
	RTS
pt_0A2A:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_143C,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0A2B
	RTS
pt_0A2B:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnOpt1Quantize
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnOpt1QuantizeUp
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnOpt1QuantizeDown
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnOpt1Metronome
	CMP.W	#$0008,D2
	BEQ.S	pt_BtnOpt1Multi
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnOpt1RecHold
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnOpt1SampleMode
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnOpt1RecordMode
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnOpt1PlayNote
	CMP.W	#$000e,D2
	BEQ.S	pt_BtnOpt1EditDir
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnOpt1Insert
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnOpt1Split
	RTS
pt_BtnOpt1EditDir:
	MOVE.B	dat_EditStepMode,D0
	NOT.B	D0
	MOVE.B	D0,dat_EditStepMode
pt_0A2D:
	MOVEQ	#5,D3
	MOVE.W	#$0246,D0
	MOVEQ	#91,D1
	LEA	(dat_0A38,PC),A0
	TST.B	dat_EditStepMode
	BNE.S	pt_0A2E
	LEA	(dat_0A37,PC),A0
pt_0A2E:
	JMP	pt_BlitPatternRow
pt_BtnOpt1Multi:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.W	#$0001,dat_TimingMode
	MOVE.W	dat_SavedEditDigit,D0
	SUB.W	#$0198,D0
	BPL.S	pt_0A30
	MOVEQ	#0,D0
pt_0A30:
	LSR.W	#4,D0
	CMP.W	#$0004,D0
	BMI.S	pt_0A31
	MOVE.W	dat_RpNumChannels,D0
	SUBQ.W	#1,D0
pt_0A31:
	MOVE.B	D0,dat_AudioMixParam
pt_0A32:
	MOVEQ	#0,D1
	MOVE.B	dat_AudioMixParam,D1
	LSL.W	#4,D1
	MOVE.W	#$01a0,dat_PlayCounter
	MOVE.W	#$0060,dat_PatternDelay
	ADD.W	D1,dat_PlayCounter
	BSR.W	pt_DrawPlayCounter
	JSR	pt_UpdateDisplayInput
	TST.B	D1
	BEQ.S	pt_0A33
	CMP.B	#$04,D1
	BHI.S	pt_0A34
	MOVE.B	dat_AudioMixParam,D0
	AND.W	#$0003,D0
	LEA	dat_DiskIOReady,A1
	MOVE.B	D1,(0,A1,D0.W)
	BSR.S	pt_0A35
	MOVEQ	#1,D0
pt_0A33:
	TST.B	D0
	BEQ.S	pt_0A34
	ADD.B	D0,dat_AudioMixParam
	ANDI.B	#$03,dat_AudioMixParam
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_0A32
pt_0A34:
	JSR	pt_RestorePalette
	CLR.W	dat_TimingMode
	MOVE.W	#$fff0,dat_PlayCounter
	CLR.W	dat_PatternDelay
	BRA.W	pt_DrawPlayCounter
pt_0A35:
	MOVE.W	#$019c,D0
	MOVEQ	#91,D1
	MOVE.B	dat_DiskIOReady,D3
	JSR	pt_DrawNumberHex
	ADD.W	#$0010,D0
	MOVE.B	dat_1513,D3
	JSR	pt_DrawNumberHex
	ADD.W	#$0010,D0
	MOVE.B	dat_1514,D3
	JSR	pt_DrawNumberHex
	ADD.W	#$0010,D0
	MOVE.B	dat_1515,D3
	JMP	pt_DrawNumberHex
dat_AudioMixParam:
	DS.W	1
dat_0A37:
	DC.B	"Down ",0
dat_0A38:
	DC.B	"Right",0
dat_EditStepMode:
	DS.W	1
pt_BtnMainOptPage2:
	MOVEQ	#2,D0
	MOVE.W	#$0002,dat_OptPage
	LEA	dat_1458,A0
	BSR.W	pt_OptPageShowBlock
	BSR.W	pt_0C97
	BSR.W	pt_0C9C
	BSR.W	pt_0D16
	BSR.W	pt_CheckEditModeType
	BSR.W	pt_0CF1
	BSR.W	pt_0CDA
	BSR.W	pt_0C6F
	RTS
pt_0A3B:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_143D,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0A3C
	RTS
pt_0A3C:
	MOVEM.L	D2,-(A7)
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVEA.L	dat_ModulePtr,A5
	LEA	(-10,A5),A5
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_0A3D
	MOVE.W	dat_SamplePlayInit,D0
pt_0A3D:
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A5
	MOVEM.L	(A7)+,D2
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnOpt2Delete
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnOpt2Exchange
	CMP.W	#$0005,D2
	BEQ.W	pt_ConfirmYesNoDialog
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnOpt2Copy
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnOpt2Mix
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnSmpBoost
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnOpt2XFade
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnSmpUpsample
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnOpt2Echo
	CMP.W	#$0012,D2
	BEQ.W	pt_BtnSmpFilter
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnSmpBackwards
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnSmpDownsample
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnOpt2From
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnOpt2From
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnOpt2FromUp
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnOpt2FromDown
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnOpt2To
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnOpt2To
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnOpt2ToUp
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnOpt2ToDown
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnOpt2Pos
	CMP.W	#$0016,D2
	BEQ.W	pt_BtnOpt2Pos
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnOpt2PosUp
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnOpt2PosDown
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnOpt2Mod
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnOpt2ModValue
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnOpt2ModUp
	CMP.W	#$001c,D2
	BEQ.W	pt_BtnOpt2ModDown
	CMP.W	#$0020,D2
	BEQ.W	pt_BtnOpt2Vol
	CMP.W	#$0021,D2
	BEQ.W	pt_BtnOpt2VolPercent
	CMP.W	#$0022,D2
	BEQ.W	pt_BtnOpt2VolUp
	CMP.W	#$0023,D2
	BEQ.W	pt_BtnOpt2VolDown
	CMP.W	#$001d,D2
	BEQ.W	pt_BtnOpt2CutBeg
	CMP.W	#$001e,D2
	BEQ.W	pt_BtnOpt2FadeDown
	CMP.W	#$001f,D2
	BEQ.W	pt_BtnOpt2FadeUp
	CMP.W	#$0024,D2
	BEQ.W	pt_BtnOpt2Clip
	CMP.W	#$0025,D2
	BEQ.W	pt_BtnOpt2Track
	RTS
pt_BtnMainOptPage3:
	MOVEQ	#3,D0
	MOVE.W	#$0003,dat_OptPage
	LEA	dat_1459,A0
	BSR.W	pt_OptPageShowBlock
	BSR.W	pt_ShowSampleSlot
	BSR.W	pt_ShowSelectedSample
	BSR.W	pt_BtnChordNotes
	BSR.W	pt_PatternBufInit
	BSR.W	pt_0B51
	RTS
pt_0A3F:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_143E,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0A40
	RTS
pt_0A40:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnChordFromSample
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnChordFromUp
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnChordFromDown
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnChordToSample
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnChordToUp
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnChordToDown
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnChordNotes
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnChordNotesUp
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnChordNotesDown
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnChordMake
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnChordAdjust
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnChordNote1
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnChordNote2
	CMP.W	#$0016,D2
	BEQ.W	pt_BtnChordNote3
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnChordNote4
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnChordNote5
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnChordNote6
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnChordNote7
	RTS
pt_BtnMainOptPage4:
	MOVEQ	#4,D0
	MOVE.W	#$0004,dat_OptPage
	LEA	dat_145A,A0
	BSR.W	pt_OptPageShowBlock
	BSR.W	pt_0B16
	BSR.W	pt_0B39
	RTS
pt_0A42:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_143F,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0A43
	RTS
pt_0A43:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnFilterDisplay
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnFilterType
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnFilterWave
	JMP	pt_FltIds41
	NOP
pt_FilterGadgetsRest:
	MOVEA.L	(dat_OscillatorData0,PC),A0
	TST.L	(A0)
	BEQ.S	pt_0A44
	LEA	(4,A0),A0
	MOVE.W	#$01ab,D0
	MOVEQ	#102,D1
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnFilterValue
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnFilterValueUp
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnFilterValueDown
pt_0A44:
	MOVEA.L	(dat_OscillatorData0,PC),A0
	TST.L	(16,A0)
	BEQ.S	pt_0A45
	LEA	(20,A0),A0
	MOVE.W	#$01ab,D0
	MOVEQ	#113,D1
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnFilterValue
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnFilterValueUp
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnFilterValueDown
pt_0A45:
	MOVEA.L	(dat_OscillatorData0,PC),A0
	TST.L	(32,A0)
	BEQ.S	pt_0A46
	LEA	(36,A0),A0
	MOVE.W	#$0237,D0
	MOVEQ	#102,D1
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnFilterValue
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnFilterValueUp
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnFilterValueDown
pt_0A46:
	RTS
pt_BtnMainOptPage7:
	MOVEQ	#7,D0
	MOVE.W	#$0007,dat_OptPage
	LEA	dat_145D,A0
	BSR.W	pt_OptPageShowBlock
	BSR.W	pt_ScreenMode7Check
	RTS
pt_0A48:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1442,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0A49
	RTS
pt_0A49:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnPatTrack
	CMPI.L	#$70617470,dat_RpPlayMode
	BNE.S	pt_0A4A
	RTS
pt_0A4A:
	MOVEM.L	D2,-(A7)
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVEM.L	(A7)+,D2
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnPatClear
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnPatFlip
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnPatOctUp
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnPatNoteUp
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnPatScrUp
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnPatRotUp
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnPatOctDown
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnPatNoteDown
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnPatScrDown
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnPatRotDown
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0A4B
	LSL.L	#1,D0
pt_0A4B:
	ADDA.L	D0,A0
	CMPI.W	#$0001,dat_PatEditScope
	BNE.S	pt_0A4C
	CMP.W	#$0002,D2
	BEQ.W	pt_0A51
	CMP.W	#$0003,D2
	BEQ.W	pt_0A52
	CMP.W	#$0004,D2
	BEQ.W	pt_0A53
	CMP.W	#$0006,D2
	BEQ.W	pt_0A54
	CMP.W	#$0007,D2
	BEQ.W	pt_0A55
pt_0A4C:
	MOVEQ	#0,D0
	MOVE.W	dat_CursorColumn,D0
	DIVU	#$0006,D0
	AND.L	#$00000007,D0
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_0A4D
	AND.L	#$00000003,D0
pt_0A4D:
	LSL.L	#2,D0
	ADDA.L	D0,A0
	TST.W	dat_PatEditScope
	BNE.S	pt_0A4E
	CMP.W	#$0002,D2
	BEQ.W	pt_0A56
	CMP.W	#$0003,D2
	BEQ.W	pt_0A57
	CMP.W	#$0004,D2
	BEQ.W	pt_0A58
	CMP.W	#$0006,D2
	BEQ.W	pt_0A59
	CMP.W	#$0007,D2
	BEQ.W	pt_0A5A
pt_0A4E:
	CMPI.W	#$0002,dat_PatEditScope
	BNE.S	pt_0A4F
	CMP.W	#$0002,D2
	BEQ.S	pt_0A5B
	CMP.W	#$0003,D2
	BEQ.S	pt_0A5C
	CMP.W	#$0004,D2
	BEQ.S	pt_0A5D
	CMP.W	#$0006,D2
	BEQ.S	pt_BtnPatInsert
	CMP.W	#$0007,D2
	BEQ.S	pt_BtnPatDelete
pt_0A4F:
	CMPI.W	#$0003,dat_PatEditScope
	BNE.S	pt_0A50
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnPatCut
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnPatCopy
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnPatPaste
pt_0A50:
	RTS
pt_0A51:
	JMP	pt_0447
pt_0A52:
	JMP	pt_ReqErrorDisplay
pt_0A53:
	JMP	pt_ConvertKeyWithRedraw
pt_0A54:
	JMP	pt_0456
pt_0A55:
	JMP	pt_0462
pt_0A56:
	JMP	pt_044D
pt_0A57:
	JMP	pt_SamplePlayInit
pt_0A58:
	JMP	pt_ConvertKeyNote
pt_0A59:
	JMP	pt_0457
pt_0A5A:
	JMP	pt_0463
pt_0A5B:
	JMP	pt_046D
pt_0A5C:
	JMP	pt_0470
pt_0A5D:
	JMP	pt_0473
pt_BtnPatInsert:
	JMP	pt_045D
pt_BtnPatDelete:
	JMP	pt_0468
	JMP	pt_BtnMainAbout
	JMP	pt_BtnMainDiskOp
pt_BtnMainOptPage6:
	MOVEQ	#6,D0
	MOVE.W	#$0006,dat_OptPage
	LEA	dat_145C,A0
	BSR.W	pt_OptPageShowBlock
	BSR.W	pt_UpdateSampleDisp
	RTS
pt_0A61:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1441,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0A62
	RTS
pt_0A62:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnM2sPattern
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnM2sStartPos
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnM2sEndPos
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnM2sSample
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnM2sNote
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnM2sSpeed
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnSmpBoost
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnSmpFilter
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnM2sGrabAll
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnM2sGrab14
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnM2sGrab15
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnM2sGrab9
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnM2sGrab6
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnM2sGrab5
	CMP.W	#$0010,D2
	BEQ.W	pt_0A89
	CMP.W	#$0011,D2
	BEQ.W	pt_0A8B
	CMP.W	#$0012,D2
	BEQ.W	pt_0A8D
	CMP.W	#$0013,D2
	BEQ.W	pt_0A93
	CMP.W	#$0014,D2
	BEQ.W	pt_0A96
	CMP.W	#$0015,D2
	BEQ.W	pt_0A98
	CMP.W	#$0016,D2
	BEQ.W	pt_0A9A
	CMP.W	#$0017,D2
	BEQ.W	pt_0A9C
	CMP.W	#$0018,D2
	BEQ.W	pt_0A9E
	CMP.W	#$0019,D2
	BEQ.W	pt_0AA0
	CMP.W	#$001a,D2
	BEQ.W	pt_0AA2
	CMP.W	#$001b,D2
	BEQ.W	pt_0AA3
	CMP.W	#$001c,D2
	BEQ.W	pt_BtnM2sMixIt
	RTS
dat_SampleFineTune:
	DS.B	1
dat_ScreenModeFlag2:
	DS.B	1
dat_SampleNumCur:
	DS.B	1
dat_0A66:
	DS.B	1
dat_SampleNumMax:
	DS.B	1
dat_0A68:
	DC.B	$3f
dat_SampleDisplayNum:
	DS.B	1
dat_0A6A:
	DC.B	$1f
dat_SampleDispTempo:
	DC.W	$007d
pt_BtnM2sGrab14:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	ADDA.L	dat_BplUpdateReq,A0
	CLR.B	dat_SampleFineTune
	MOVE.B	(A0),dat_ScreenModeFlag2
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sGrab15:
	MOVE.W	dat_PatternPosition,D0
	MOVE.W	(dat_SampleNumMax,PC),D1
	CMP.W	#$003f,D0
	BLT.S	pt_0A6E
	MOVE.W	#$003e,D0
pt_0A6E:
	CMP.W	D1,D0
	BLT.S	pt_0A6F
	MOVE.W	D0,D1
	ADDQ.W	#1,D1
pt_0A6F:
	MOVE.W	D0,dat_SampleNumCur
	MOVE.W	D1,dat_SampleNumMax
	BRA.S	pt_UpdateSampleDisp
pt_BtnM2sGrab9:
	MOVE.W	dat_PatternPosition,D0
	MOVE.W	(dat_SampleNumCur,PC),D1
	TST.W	D0
	BGT.S	pt_0A71
	MOVE.W	#$0001,D0
pt_0A71:
	CMP.W	D0,D1
	BLT.S	pt_0A72
	MOVE.W	D0,D1
	SUBQ.W	#1,D1
pt_0A72:
	MOVE.W	D0,dat_SampleNumMax
	MOVE.W	D1,dat_SampleNumCur
	BRA.S	pt_UpdateSampleDisp
pt_BtnM2sGrab6:
	MOVE.W	dat_CurrentSample,dat_SampleDisplayNum
	BRA.S	pt_UpdateSampleDisp
pt_BtnM2sGrab5:
	MOVE.W	dat_CurrentTempo,dat_SampleDispTempo
	BRA.S	pt_UpdateSampleDisp
pt_BtnM2sGrabAll:
	MOVE.W	dat_CurrentSample,dat_SampleDisplayNum
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	ADDA.L	dat_BplUpdateReq,A0
	CLR.B	dat_SampleFineTune
	MOVE.B	(A0),dat_ScreenModeFlag2
	MOVE.W	dat_CurrentTempo,dat_SampleDispTempo
pt_UpdateSampleDisp:
	MOVE.W	(dat_SampleNumMax,PC),D0
	MOVE.W	(dat_SampleNumCur,PC),D1
	CMP.W	D0,D1
	BLS.S	dat_0A77
	MOVE.W	(dat_SampleNumMax,PC),D0
	SUBQ.W	#1,D0
	MOVE.W	D0,dat_SampleNumCur
dat_0A77:
	TSTPC.W	dat_SampleNumMax
	BNE.S	pt_0A78
	ADDQ.W	#1,dat_SampleNumMax
pt_0A78:
	BSR.W	pt_LoadEffectTbl
	MOVE.W	#$15c6,dat_TextBytePos
	MOVE.W	(dat_SampleFineTune,PC),dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$1936,dat_TextBytePos
	MOVE.W	(dat_SampleNumCur,PC),dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$1ca6,dat_TextBytePos
	MOVE.W	(dat_SampleNumMax,PC),dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$2016,dat_TextBytePos
	MOVE.W	(dat_SampleDisplayNum,PC),D0
	TST.W	D0
	BNE.S	pt_0A79
	MOVE.W	#$0001,dat_SampleDisplayNum
pt_0A79:
	MOVE.W	(dat_SampleDisplayNum,PC),dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$2386,dat_TextBytePos
	MOVE.W	#$0003,dat_TextCharCount
	BSR.S	pt_0A7A
	JSR	pt_MixItFixArg
	NOP
	LEA	dat_0AC5,A0
	MOVE.L	A0,dat_TextStringPtr
	JMP	pt_DrawTextRender
pt_0A7A:
	MOVEQ	#0,D0
	CMPI.W	#$0020,dat_SampleDispTempo
	BGE.S	pt_0A7B
	MOVE.W	#$0020,dat_SampleDispTempo
pt_0A7B:
	CMPI.W	#$00ff,dat_SampleDispTempo
	BLE.S	pt_0A7C
	MOVE.W	#$00ff,dat_SampleDispTempo
pt_0A7C:
	MOVE.W	(dat_SampleDispTempo,PC),D0
	MOVEQ	#2,D1
	MOVEQ	#10,D2
	LEA	dat_0AC5,A0
	BSR.S	pt_0A7D
	RTS
pt_0A7D:
	MOVEM.L	D3-D4/A1,-(A7)
	SUBQ.L	#2,D2
	CMP.L	#$0000000e,D2
	BLS.S	pt_0A7E
	MOVEQ	#-1,D0
	MOVEM.L	D3-D4/A1,-(A7)
	RTS
pt_0A7E:
	ADDQ.L	#2,D2
	LEA	(dat_0A87,PC),A1
	ADD.L	D1,D1
	ADD.L	D1,D1
	MOVE.L	(0,A1,D1.W),D3
	AND.L	D3,D0
	NOT.L	D3
	LEA	(dat_0A88,PC),A1
	MOVEQ	#0,D1
	BSR.S	pt_0A7F
	MOVEQ	#0,D0
	MOVEM.L	(A7)+,D3-D4/A1
	RTS
pt_0A7F:
	MOVEM.L	D1/D4-D5,-(A7)
	TST.L	D1
	BNE.S	pt_0A80
	MOVEQ	#1,D1
	BRA.S	pt_0A82
pt_0A80:
	MOVE.L	D2,D4
	SUBQ.W	#2,D4
	MOVE.L	D1,D5
pt_0A81:
	ADD.L	D5,D1
	DBCS	D4,pt_0A81
	BCS.S	pt_0A86
	MOVE.L	D1,D4
	AND.L	D3,D4
	BNE.S	pt_0A86
pt_0A82:
	BSR.S	pt_0A7F
	MOVEQ	#0,D5
	MOVE.L	D1,D4
	BRA.S	pt_0A84
pt_0A83:
	ADDQ.W	#1,D5
	ADD.L	D1,D4
	BCS.S	pt_0A85
pt_0A84:
	CMP.L	D0,D4
	BLS.S	pt_0A83
pt_0A85:
	SUB.L	D1,D4
	SUB.L	D4,D0
	MOVE.B	(0,A1,D5.W),(A0)+
pt_0A86:
	MOVEM.L	(A7)+,D1/D4-D5
	RTS
dat_0A87:
	DC.L	$ffffffff,$0000ffff,$000000ff
dat_0A88:
	DC.B	"0123456789ABCDEF",0,0
pt_0A89:
	CMPI.W	#$0023,dat_BorderConfig1
	BEQ.S	pt_0A8A
	ADDQ.W	#1,dat_BorderConfig1
	BRA.W	pt_UpdateSampleDisp
pt_0A8A:
	JMP	pt_WaitMouseRelease
pt_0A8B:
	TST.W	dat_BorderConfig1
	BEQ.S	pt_0A8C
	SUBQ.W	#1,dat_BorderConfig1
	BRA.W	pt_UpdateSampleDisp
pt_0A8C:
	JMP	pt_WaitMouseRelease
pt_0A8D:
	ADDQ.W	#1,dat_SampleFineTune
	RMB
	BNE.S	pt_0A8E
	ADDI.W	#$0009,dat_SampleFineTune
pt_0A8E:
	TST.B	dat_PatternBufFlag
	BNE.S	pt_0A8F
	CMPI.W	#$003f,dat_SampleFineTune
	BGE.S	pt_0A91
	BRA.S	pt_0A90
pt_0A8F:
	CMPI.W	#$0063,dat_SampleFineTune
	BGE.S	pt_0A91
pt_0A90:
	BRA.W	pt_UpdateSampleDisp
pt_0A91:
	TST.B	dat_PatternBufFlag
	BNE.S	pt_0A92
	MOVE.W	#$003f,dat_SampleFineTune
	BRA.W	pt_UpdateSampleDisp
pt_0A92:
	MOVE.W	#$0063,dat_SampleFineTune
	BRA.W	pt_UpdateSampleDisp
pt_0A93:
	SUBQ.W	#1,dat_SampleFineTune
	RMB
	BNE.S	pt_0A94
	SUBI.W	#$0009,dat_SampleFineTune
pt_0A94:
	TST.W	dat_SampleFineTune
	BLE.S	pt_0A95
	BRA.W	pt_UpdateSampleDisp
pt_0A95:
	CLR.W	dat_SampleFineTune
	BRA.W	pt_UpdateSampleDisp
pt_0A96:
	MOVE.W	(dat_SampleNumMax,PC),D0
	SUBQ.W	#1,D0
	CMP.W	(dat_SampleNumCur,PC),D0
	BLE.S	pt_0A97
	ADDQ.W	#1,dat_SampleNumCur
	BRA.W	pt_UpdateSampleDisp
pt_0A97:
	JMP	pt_WaitMouseRelease
pt_0A98:
	TST.W	dat_SampleNumCur
	BEQ.S	pt_0A99
	SUBQ.W	#1,dat_SampleNumCur
	BRA.W	pt_UpdateSampleDisp
pt_0A99:
	JMP	pt_WaitMouseRelease
pt_0A9A:
	CMPI.W	#$003f,dat_SampleNumMax
	BEQ.S	pt_0A9B
	ADDQ.W	#1,dat_SampleNumMax
	BRA.W	pt_UpdateSampleDisp
pt_0A9B:
	JMP	pt_WaitMouseRelease
pt_0A9C:
	MOVE.W	(dat_SampleNumCur,PC),D0
	ADDQ.W	#1,D0
	CMP.W	(dat_SampleNumMax,PC),D0
	BGE.S	pt_0A9D
	SUBQ.W	#1,dat_SampleNumMax
	BRA.W	pt_UpdateSampleDisp
pt_0A9D:
	JMP	pt_WaitMouseRelease
pt_0A9E:
	CMPI.W	#$001f,dat_SampleDisplayNum
	BEQ.S	pt_0A9F
	ADDQ.W	#1,dat_SampleDisplayNum
	BRA.W	pt_UpdateSampleDisp
pt_0A9F:
	JMP	pt_WaitMouseRelease
pt_0AA0:
	CMPI.W	#$0001,dat_SampleDisplayNum
	BEQ.S	pt_0AA1
	SUBQ.W	#1,dat_SampleDisplayNum
	BRA.W	pt_UpdateSampleDisp
pt_0AA1:
	JMP	pt_WaitMouseRelease
pt_0AA2:
	ADDQ.W	#1,dat_SampleDispTempo
	RMB
	BNE.W	pt_UpdateSampleDisp
	ADDI.W	#$0009,dat_SampleDispTempo
	BRA.W	pt_UpdateSampleDisp
pt_0AA3:
	SUBQ.W	#1,dat_SampleDispTempo
	RMB
	BNE.W	pt_UpdateSampleDisp
	SUBI.W	#$0009,dat_SampleDispTempo
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sSpeed:
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$0077,dat_PatternDelay
	MOVE.W	#$2386,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_UpdateSampleDisp
	CMP.W	#$001a,D0
	BGE.S	pt_0AA5
	MULU	#$000a,D0
pt_0AA5:
	MOVE.W	D0,dat_SampleDispTempo
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sNote:
	BSR.S	pt_LoadEffectTbl
	MOVE.W	#$1256,dat_TextBytePos
	MOVE.W	#$0003,dat_TextCharCount
	MOVE.L	#dat_DashSeparator,dat_TextStringPtr
	BSR.W	pt_DrawTextRender
	MOVE.W	#$0004,dat_ScreenSizeVar
	MOVE.L	#dat_BorderConfig1,dat_TempBufPtr
	JMP	pt_WaitMouseRelease
pt_LoadEffectTbl:
	LEA	dat_0AC4,A6
	LEA	pt_PatternRenderEntry,A5
	MOVE.W	dat_BorderConfig1,D0
	LSL.W	#2,D0
	LEA	(0,A5,D0.W),A0
	MOVE.L	(A0),(A6)
	MOVE.W	#$1256,dat_TextBytePos
	MOVE.W	#$0003,dat_TextCharCount
	LEA	dat_0AC4,A0
	MOVE.L	A0,dat_TextStringPtr
	JSR	pt_DrawTextRender
	RTS
pt_BtnM2sPattern:
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$004a,dat_PatternDelay
	MOVE.W	#$15c6,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_UpdateSampleDisp
	CMP.B	(dat_SampleVolume,PC),D0
	BLS.S	pt_0AA9
	MOVE.L	(dat_SampleEditState,PC),D0
pt_0AA9:
	MOVE.B	D0,dat_ScreenModeFlag2
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sStartPos:
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$0055,dat_PatternDelay
	MOVE.W	#$1936,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_UpdateSampleDisp
	CMP.B	#$3e,D0
	BLS.S	pt_0AAB
	MOVEQ	#62,D0
pt_0AAB:
	MOVE.B	D0,dat_0A66
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sEndPos:
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$0060,dat_PatternDelay
	MOVE.W	#$1ca6,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_UpdateSampleDisp
	CMP.B	#$3f,D0
	BLS.S	pt_0AAD
	MOVEQ	#63,D0
pt_0AAD:
	MOVE.B	D0,dat_0A68
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sSample:
	MOVE.W	#$01b4,dat_PlayCounter
	MOVE.W	#$006b,dat_PatternDelay
	MOVE.W	#$2016,dat_TextBytePos
	BSR.W	pt_UpdateSampleListUI
	TST.W	dat_PaletteDirtyFlag
	BNE.W	pt_UpdateSampleDisp
	CMP.B	#$1f,D0
	BLS.S	pt_0AAF
	MOVEQ	#31,D0
pt_0AAF:
	MOVE.B	D0,dat_0A6A
	BRA.W	pt_UpdateSampleDisp
pt_BtnM2sMixIt:
	JSR	pt_MixItCheck
	NOP
	NOP
	NOP
	MOVE.B	dat_SampleNameBuf,dat_1506
	CLR.B	dat_SampleNameBuf
	BSR.W	pt_GetSamplePtrAbs
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	dat_NumSamples
pt_0AB1:
	MOVE.B	(0,A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#$0080,D0
	BHI.S	pt_0AB2
	MOVE.W	dat_NumSamples,D2
	CMP.W	D2,D1
	BLS.S	pt_0AB1
	MOVE.W	D1,dat_NumSamples
	BRA.S	pt_0AB1
pt_0AB2:
	LEA	dat_0ABC,A0
	JSR	pt_CopyFilename
	MOVE.B	#$6d,(A1)+
	MOVE.B	#$6f,(A1)+
	MOVE.B	#$64,(A1)+
	MOVE.B	#$2e,(A1)+
	LEA	dat_0ABD,A0
	MOVEQ	#19,D0
pt_0AB3:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0AB3
	CLR.W	dat_FileSizeMode
	MOVEA.L	dat_ModulePtr,A0
	MOVE.L	A0,dat_FileWriteAddr
	MOVE.L	#$0000043c,dat_FileWriteSize
	MOVEQ	#0,D0
	MOVE.W	dat_NumSamples,D0
	ADDQ.L	#1,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0AB4
	LSL.L	#1,D0
pt_0AB4:
	ADD.L	D0,dat_FileWriteSize
	MOVE.B	#$7f,(951,A0)
	CLR.L	(mod_id,A0)
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0AB5
	MOVE.L	#$3843484e,(mod_id,A0)
	BRA.S	pt_0AB6
pt_0AB5:
	CMPI.W	#$0040,dat_NumSamples
	BCS.S	pt_0AB6
	MOVE.L	#$4d214b21,(mod_id,A0)
pt_0AB6:
	BSR.W	pt_CheckSampleName
	MOVE.B	dat_1506,dat_SampleNameBuf
	LEA	(dat_05A0,PC),A0
	BSR.W	pt_ShowStatusMsg
	MOVE.W	(dat_SampleFineTune,PC),D0
	BSR.W	pt_CompareWith60
	MOVE.W	D1,dat_0AC1
	MOVE.W	(dat_SampleNumCur,PC),D0
	BSR.W	pt_CompareWith60
	MOVE.W	D1,dat_0AC2
	MOVE.W	(dat_SampleNumMax,PC),D0
	BSR.W	pt_CompareWith60
	MOVE.W	D1,dat_0AC3
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	TST.L	dat_RpPlayMode
	BNE.S	pt_0AB7
	BSR.W	pt_BtnMainStop
pt_0AB7:
	MOVE.L	#dat_0AC7,D1
	MOVE.L	#$000003ee,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-30,A6)
	MOVE.L	D0,dat_DiskCachePtr
	BEQ.S	pt_0AB9
	LEA	dat_0AC0,A0
	MOVE.L	A0,D1
	MOVE.L	dat_DiskCachePtr,D2
	MOVEQ	#0,D3
	JSR	pt_MixItExec
	NOP
	NOP
	MOVE.L	dat_DiskCachePtr,D1
	BNE.S	pt_0AB8
	RTS
pt_0AB8:
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	CLR.L	dat_DiskCachePtr
	BRA.S	pt_0ABA
pt_0AB9:
	LEA	str_ErrorOpenWindow,A0
	JSR	pt_ShowStatusMsg
	JMP	pt_SetPaletteEdit
pt_0ABA:
	JSR	pt_RestorePalette
	BSR.W	pt_ClearStatusMsg
	MOVEA.L	dat_DosLibBase,A6
	LEA	dat_0ABE,A0
	MOVE.L	A0,D1
	JSR	(-72,A6)
	MOVE.W	(dat_SampleDisplayNum,PC),dat_CurrentSample
	TST.W	dat_CurrentSample
	BEQ.W	pt_JmpSelectDiskMsg
	MOVE.L	str_TempSampleFile,dat_ScopeBuf1
	LEA	dat_ScopeBuf1,A0
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0),A0
	ADDA.L	D0,A0
	MOVE.L	#str_TempSampleFile,D1
	BSR.W	pt_099E
	MOVE.L	dat_PatternEditBuf,D0
	BSR.W	pt_09A2
	MOVE.L	#str_TempSampleFile,D1
	BSR.W	pt_09AC
	MOVEA.L	dat_DosLibBase,A6
	LEA	str_TempSampleFile,A0
	MOVE.L	A0,D1
	JSR	(-72,A6)
	CLR.B	dat_KeyCode
	BRA.W	pt_RefreshDisplay
pt_0ABB:
	LEA	dat_12E3,A0
	JSR	pt_ShowYesNoDialog
	RTS
dat_0ABC:
	DC.L	$543a0000
dat_0ABD:
	DC.B	"temp",0,0
dat_0ABE:
	DC.B	"T:mod.temp",0,0
str_TempSampleFile:
	DC.B	"T:tsample",0
dat_0AC0:
	DC.B	"LIBS:mod2smp.library T:mod.temp T:tsample "
dat_0AC1:
	DC.L	$31202020
dat_0AC2:
	DC.L	$30202020
dat_0AC3:
	DC.B	"63  85  "
dat_0AC4:
	DC.B	"C-3 -c"
dat_0AC5:
	DC.W	$3132
	DC.B	$35
dat_0AC6:
	DC.B	" -r0",0
dat_0AC7:
	DC.L	$4e494c3a
	DS.L	1
	DS.W	1
dat_DiskCachePtr:
	DS.L	1
dat_0AC9:
	DC.B	"0000010203040506070809"
dat_0ACA:
	DC.B	"10111213141516171819"
dat_0ACB:
	DC.B	"20212223242526272829"
dat_0ACC:
	DC.B	"30313233343536373839"
dat_0ACD:
	DC.B	"40414243444546474849"
dat_0ACE:
	DC.B	"50515253545556575859"
dat_0ACF:
	DC.B	"60616263646566676869"
pt_CompareWith60:
	CMP.W	#$003c,D0
	BMI.S	pt_0AD1
	MOVE.L	(dat_0ACF,PC),D1
	SUB.W	#$003d,D0
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_0AD1:
	CMP.W	#$0032,D0
	BMI.S	pt_0AD2
	MOVE.L	(dat_0ACE,PC),D1
	SUB.W	#$0033,D0
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_0AD2:
	CMP.W	#$0028,D0
	BMI.S	pt_0AD3
	MOVE.L	(dat_0ACD,PC),D1
	SUB.W	#$0029,D0
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_0AD3:
	CMP.W	#$001e,D0
	BMI.S	pt_0AD4
	MOVE.L	(dat_0ACC,PC),D1
	SUB.W	#$001f,D0
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_0AD4:
	CMP.W	#$0014,D0
	BMI.S	pt_0AD5
	MOVE.L	(dat_0ACB,PC),D1
	SUB.W	#$0015,D0
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_0AD5:
	CMP.W	#$000a,D0
	BMI.S	pt_0AD6
	MOVE.L	(dat_0ACA,PC),D1
	SUB.W	#$000b,D0
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_0AD6:
	MOVE.L	(dat_0AC9,PC),D1
	ADD.W	D0,D1
	MOVEA.L	D1,A0
	LEA	(A0),A2
	MOVE.W	A2,D1
	RTS
pt_BtnSongComment:
	MOVEQ	#8,D0
	MOVE.W	#$0008,dat_OptPage
	LEA	dat_145E,A0
	BSR.W	pt_OptPageShowBlock
pt_0AD8:
	MOVEQ	#8,D6
	MOVE.W	#$1248,dat_TextBytePos
	MOVEQ	#0,D3
pt_0AD9:
	MOVEA.L	#dat_SampleHeaderBuf,A0
	ADDA.L	D3,A0
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$0028,dat_TextCharCount
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	ADDI.W	#$01b8,dat_TextBytePos
	ADD.W	#$0028,D3
	DBF	D6,pt_0AD9
	RTS
pt_0ADA:
	CLR.W	D6
	CLR.W	D5
	BRA.S	pt_SetupSongPalette
pt_0ADB:
	MOVE.W	#$0028,D6
	MOVE.W	#$01e0,D5
	BRA.S	pt_SetupSongPalette
pt_0ADC:
	MOVE.W	#$0050,D6
	MOVE.W	#$03c0,D5
	BRA.S	pt_SetupSongPalette
pt_0ADD:
	MOVE.W	#$0078,D6
	MOVE.W	#$05a0,D5
	BRA.S	pt_SetupSongPalette
pt_0ADE:
	MOVE.W	#$00a0,D6
	MOVE.W	#$0780,D5
	BRA.S	pt_SetupSongPalette
pt_0ADF:
	MOVE.W	#$00c8,D6
	MOVE.W	#$0960,D5
	BRA.S	pt_SetupSongPalette
pt_0AE0:
	MOVE.W	#$00f0,D6
	MOVE.W	#$0b40,D5
	BRA.S	pt_SetupSongPalette
pt_0AE1:
	MOVE.W	#$0118,D6
	MOVE.W	#$0d20,D5
	BRA.S	pt_SetupSongPalette
pt_0AE2:
	MOVE.W	#$0140,D6
	MOVE.W	#$0f00,D5
pt_SetupSongPalette:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEA.L	#dat_SampleHeaderBuf,A6
	ADDA.L	D6,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$00000027,dat_SongDataAddr
	MOVE.W	#$0028,dat_TextCharCount
	MOVE.W	#$1248,D7
	ADD.W	D5,D7
	MOVEA.W	D7,A4
	BSR.W	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JSR	pt_RestorePalette
	BRA.W	pt_0AD8
pt_0AE4:
	BSR.S	pt_ClearBufferLoop
	BRA.W	pt_0AD8
pt_ClearBufferLoop:
	MOVE.W	#$0168,D7
	LEA	dat_SampleHeaderBuf,A0
pt_0AE6:
	CLR.B	(0,A0,D7.W)
	DBF	D7,pt_0AE6
	RTS
pt_0AE7:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1443,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0AE8
	RTS
pt_0AE8:
	CMP.W	#$0001,D2
	BEQ.S	pt_BtnMainOptPage5
	CMP.W	#$0002,D2
	BEQ.W	pt_0ADA
	CMP.W	#$0003,D2
	BEQ.W	pt_0ADB
	CMP.W	#$0004,D2
	BEQ.W	pt_0ADC
	CMP.W	#$0005,D2
	BEQ.W	pt_0ADD
	CMP.W	#$0006,D2
	BEQ.W	pt_0ADE
	CMP.W	#$0007,D2
	BEQ.W	pt_0ADF
	CMP.W	#$0008,D2
	BEQ.W	pt_0AE0
	CMP.W	#$0009,D2
	BEQ.W	pt_0AE1
	CMP.W	#$000a,D2
	BEQ.W	pt_0AE2
	CMP.W	#$000b,D2
	BEQ.W	pt_0AE4
	RTS
pt_BtnMainOptPage5:
	MOVEQ	#5,D0
	MOVE.W	#$0005,dat_OptPage
	LEA	dat_145B,A0
	BSR.W	pt_OptPageShowBlock
pt_0AEA:
	TST.W	dat_DSPControl
	BEQ.W	pt_0AEF
	LEA	str_InfoFileName,A0
	MOVE.W	#$1ca5,D1
	MOVEQ	#6,D0
	BSR.W	pt_DrawTextAt
	LEA	str_UnnamedSong,A0
	MOVE.W	#$1255,D1
	MOVEQ	#26,D0
	BSR.W	pt_DrawTextAt
	LEA	str_UnnamedAuthor,A0
	MOVE.W	#$15c5,D1
	MOVEQ	#26,D0
	BSR.W	pt_DrawTextAt
	MOVE.W	#$1935,dat_TextBytePos
	MOVE.W	dat_DSPControl,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#1,dat_TextBytePos
	LEA	dat_MonthAbbrevTable,A0
	MOVE.W	dat_SongConfigA,D0
	SUBQ.W	#1,D0
	MULU	#$0005,D0
	ADDA.W	D0,A0
	MOVE.W	#$1937,D1
	MOVE.W	#$0005,D0
	JSR	pt_DrawTextAt
	MOVE.W	#$193c,dat_TextBytePos
	MOVE.W	dat_SongConfigB,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#4,dat_TextBytePos
	MOVE.W	dat_SongConfigC,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#1,dat_TextBytePos
	MOVE.W	dat_SongConfigD,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#1,dat_TextBytePos
	ADDQ.W	#1,dat_TextBytePos
	MOVE.W	dat_DiskConfigA,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#1,dat_TextBytePos
	MOVE.W	dat_DiskConfigB,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$2018,dat_TextBytePos
	MOVE.W	dat_SongConfigVar,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDI.W	#$036e,dat_TextBytePos
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_0AEB
	MOVE.W	#$0004,dat_DisplayParam
	BRA.S	pt_0AEC
pt_0AEB:
	MOVE.W	#$0008,dat_DisplayParam
pt_0AEC:
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$2393,dat_TextBytePos
	MOVE.W	dat_CurrentTempo,dat_DisplayParam
	BSR.W	pt_FormatDecimal
pt_0AED:
	MOVE.W	dat_FileInfoAddr,dat_DisplayParam
	MOVE.W	#$1cb9,dat_TextBytePos
	JSR	pt_FormatDecimal
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_0AEE
	MOVE.W	#$2022,D1
	MOVEQ	#4,D0
	LEA	(dat_07AA,PC),A0
	BRA.W	pt_DrawTextAt
pt_0AEE:
	MOVE.W	#$2022,D1
	MOVEQ	#4,D0
	LEA	(dat_07A9,PC),A0
	BRA.W	pt_DrawTextAt
pt_0AEF:
	MOVE.W	#$15c6,D1
	MOVEQ	#23,D0
	LEA	dat_0AF0,A0
	BRA.W	pt_DrawTextAt
dat_0AF0:
	DC.B	"-=* NO IFF FORM MOD *=-",0
pt_0AF1:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1440,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_0AF2
	RTS
pt_0AF2:
	CMP.W	#$0001,D2
	BEQ.S	pt_BtnSongCreate
	TST.W	dat_DSPControl
	BEQ.S	pt_0AF3
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnSongField2
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnSongIffText
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnSongField4
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnSongComment
pt_0AF3:
	RTS
pt_BtnSongCreate:
	MOVE.W	dat_SampleConfigA,dat_DSPControl
	MOVE.W	dat_SampleConfigB,dat_SongConfigA
	MOVE.W	dat_SampleConfigC,dat_SongConfigB
	MOVE.W	dat_SampleConfigD,dat_SongConfigC
	MOVE.W	dat_SampleConfigE,dat_SongConfigD
	MOVE.W	dat_SampleConfigF,dat_SongConfigE
	MOVE.W	#$0017,dat_TextCharCount
	MOVE.W	#$1936,dat_TextBytePos
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
	LEA	str_UnnamedSong,A0
	CMPI.L	#$554e4e41,(A0)
	BNE.S	pt_0AF6
	MOVEA.L	dat_ModulePtr,A0
	LEA	str_UnnamedSong,A1
	MOVEQ	#19,D0
pt_0AF5:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0AF5
pt_0AF6:
	MOVE.W	#$0020,dat_SongNameBufEnd
	MOVE.W	#$0040,dat_SongNameEnd
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	dat_NumSamples
pt_0AF7:
	MOVE.B	(0,A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#$0080,D0
	BHI.S	pt_0AF8
	MOVE.W	dat_NumSamples,D2
	CMP.W	D2,D1
	BLS.S	pt_0AF7
	MOVE.W	D1,dat_NumSamples
	BRA.S	pt_0AF7
pt_0AF8:
	MOVE.W	dat_NumSamples,dat_SongConfigVar
	MOVE.W	dat_SampleConfigA,dat_DSPControl
	MOVE.W	dat_SampleConfigB,dat_SongConfigA
	MOVE.W	dat_SampleConfigC,dat_SongConfigB
	MOVE.W	dat_SampleConfigD,dat_SongConfigC
	MOVE.W	dat_SampleConfigE,dat_SongConfigD
	MOVE.W	dat_SampleConfigF,dat_SongConfigE
	MOVE.L	#pt_SampleEdEntry,dat_TextStringPtr
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.W	pt_0AEA
pt_BtnSongField4:
	MOVE.W	#$0254,dat_PlayCounter
	MOVE.W	#$0060,dat_PatternDelay
	MOVE.W	#$1cba,dat_TextBytePos
	BSR.W	pt_MarkPaletteDirty
	TST.W	dat_PaletteDirtyFlag
	BNE.S	pt_0AFA
	MOVE.L	(dat_EditSampleSlot,PC),dat_FileInfoAddr
pt_0AFA:
	BRA.W	pt_0AED
pt_BtnSongField2:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	str_UnnamedSong,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$0000001f,dat_SongDataAddr
	MOVE.W	#$001a,dat_TextCharCount
	MOVEA.W	#$1255,A4
	BSR.W	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JMP	pt_RestorePalette
pt_BtnSongIffText:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	str_UnnamedAuthor,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$0000001f,dat_SongDataAddr
	MOVE.W	#$001a,dat_TextCharCount
	MOVEA.W	#$15c5,A4
	BSR.W	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JMP	pt_RestorePalette
dat_OptPage:
	DC.W	$0001
dat_ScreenSubMode:
	DS.W	1
pt_BtnFilterDoIt:
	BSR.W	pt_DiskOpSetup
	MOVE.W	#$0f0f,COLOR00
	RTS
pt_OptPageShowBlock:
	CMP.W	(dat_ScreenSubMode,PC),D0
	BEQ.W	pt_0B04
	MOVE.W	D0,dat_ScreenSubMode
	CMPA.L	#$00000000,A0
	BEQ.W	pt_0B04
	BSR.W	pt_0827
	LEA	dat_148A,A0
	MOVEQ	#1,D2
pt_0B01:
	MOVE.W	#$004c,D0
pt_0B02:
	MOVEQ	#9,D1
pt_0B03:
	MOVE.L	(A1)+,(A0)+
	DBF	D1,pt_0B03
	LEA	(40,A0),A0
	DBF	D0,pt_0B02
	LEA	(14320,A0),A0
	DBF	D2,pt_0B01
	MOVE.W	#$0140,D0
	MOVE.W	#$002d,D1
	MOVE.W	#$027f,D2
	MOVE.W	#$0079,D3
	MOVEQ	#0,D5
	JSR	pt_SetupAudioDisplay
	MOVEQ	#0,D0
	MOVE.L	dat_UndoHeader,D0
	BSR.W	pt_0817
pt_0B04:
	RTS
pt_0B05:
	MOVEA.L	(dat_OscillatorData0,PC),A1
	LEA	(dat_0B0B,PC),A2
	MOVEQ	#2,D7
pt_0B06:
	MOVE.L	(A1)+,D0
	MOVEA.L	D0,A0
	BNE.S	pt_0B07
	LEA	(dat_0B0C,PC),A0
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	MOVEQ	#8,D3
	JSR	pt_BlitPatternRow
	ADD.W	#$003e,D0
	MOVEQ	#6,D3
	BSR.W	pt_BlitPatternFull
	ADDA.W	#$000c,A1
	BRA.S	pt_0B0A
pt_0B07:
	MOVE.L	(A1),D2
	CMP.L	(4,A1),D2
	BPL.S	pt_0B08
	MOVE.L	(4,A1),D2
pt_0B08:
	CMP.L	(8,A1),D2
	BMI.S	pt_0B09
	MOVE.L	(8,A1),D2
pt_0B09:
	MOVE.L	D2,(A1)+
	ADDQ.L	#8,A1
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	MOVEQ	#8,D3
	JSR	pt_BlitPatternRow
	ADD.W	#$003e,D0
	MOVEQ	#6,D3
	BSR.W	pt_BlitPatternSetup
pt_0B0A:
	DBF	D7,pt_0B06
	RTS
dat_0B0B:
	DC.L	$016d0066,$016d0071,$01f90066,$01f90071
dat_0B0C:
	DC.B	"        "
pt_BtnFilterValue:
	MOVE.L	(A0),D2
	MOVEM.L	D0-D1,-(A7)
	MOVEQ	#6,D3
	BSR.W	pt_DiskOpPrepare
	MOVE.L	D0,(A0)
	MOVEM.L	(A7)+,D0-D1
	BRA.S	pt_ReadLongBuf
pt_BtnFilterValueUp:
	MOVEQ	#1,D3
	RMB
	BNE.S	pt_0B0F
	MOVEQ	#10,D3
pt_0B0F:
	ADD.L	D3,(A0)
	BRA.S	pt_ReadLongBuf
pt_BtnFilterValueDown:
	MOVEQ	#1,D3
	RMB
	BNE.S	pt_0B11
	MOVEQ	#10,D3
pt_0B11:
	SUB.L	D3,(A0)
	BPL.S	pt_ReadLongBuf
	CLR.L	(A0)
pt_ReadLongBuf:
	MOVE.L	(A0),D2
	CMP.L	(4,A0),D2
	BPL.S	pt_0B13
	MOVE.L	(4,A0),D2
pt_0B13:
	CMP.L	(8,A0),D2
	BMI.S	pt_0B14
	MOVE.L	(8,A0),D2
pt_0B14:
	MOVE.L	D2,(A0)
	MOVEQ	#6,D3
	BRA.W	pt_BlitPatternSetup
pt_BtnFilterType:
	ADDQ.W	#1,dat_OscillatorSlot
pt_0B16:
	MOVE.W	(dat_OscillatorSlot,PC),D0
	CMP.W	#$000a,D0
	BMI.S	pt_0B17
	MOVEQ	#0,D0
	MOVE.W	D0,dat_OscillatorSlot
pt_0B17:
	MOVE.W	D0,D1
	LSL.W	#2,D1
	LSL.L	#4,D0
	MOVE.L	(dat_0B18,PC,D1.W),dat_OscillatorData0
	LEA	(dat_0B19,PC,D0.L),A0
	MOVE.W	#$0182,D0
	MOVEQ	#91,D1
	MOVEQ	#16,D3
	JSR	pt_BlitPatternRow
	BSR.W	pt_0B05
	BRA.W	pt_0B39
dat_0B18:
	DC.L	dat_0B1E
	DC.L	dat_0B20
	DC.L	dat_0B22
	DC.L	dat_0B25
	DC.L	dat_0B28
	DC.L	dat_0B2B
	DC.L	dat_0B2E
	DC.L	dat_0B31
	DC.L	dat_0B35
	DC.L	dat_0B37
dat_0B19:
	DC.B	"Lowpass 1 pole  Highpass 1 pole Bandpass 2 polesShelving low "
	DC.B	"   Shelving high   Loop Comb       Loop Allpass    Delay Feed"
	DC.B	"back  MultiTapDelay   Waveshaping     "
dat_OscillatorBufPtr:
	DS.L	1
dat_OscillatorData0:
	DS.L	1
dat_OscillatorSlot:
	DS.W	1
dat_OscillatorIndex:
	DS.W	1
dat_0B1E:
	DC.L	dat_0B1F
	DS.L	1
	DC.L	$0000006e,$00000370
	DS.L	8
	DC.L	dat_PatternWorkBuf
dat_0B1F:
	DC.B	"Freeqcy."
dat_0B20:
	DC.L	dat_0B21
	DS.L	1
	DC.L	$0000006e,$00000370
	DS.L	8
	DC.L	dat_PatternWorkBuf
dat_0B21:
	DC.B	"Freeqcy."
dat_0B22:
	DC.L	dat_0B23
	DS.L	1
	DC.L	$0000006e,$00000370
	DC.L	dat_0B24
	DS.L	1
	DC.L	1,20
	DS.L	5
dat_0B23:
	DC.B	"Freeqcy."
dat_0B24:
	DC.B	"Quality "
dat_0B25:
	DC.L	dat_0B26
	DS.L	1
	DC.L	$0000006e,$00000370
	DC.L	dat_0B27
	DS.L	1
	DC.L	-100,100
	DS.L	4
	DC.L	dat_PatternWorkBuf
dat_0B26:
	DC.B	"Freeqcy."
dat_0B27:
	DC.B	"Gain    "
dat_0B28:
	DC.L	dat_0B29
	DS.L	1
	DC.L	$0000006e,$00000370
	DC.L	dat_0B2A
	DS.L	1
	DC.L	-100,100
	DS.L	4
	DC.L	dat_PatternWorkBuf
dat_0B29:
	DC.B	"Freeqcy."
dat_0B2A:
	DC.B	"Gain    "
dat_0B2B:
	DC.L	dat_0B2C
	DS.L	2
	DC.L	$00000064
	DC.L	dat_0B2D
	DS.L	2
	DC.L	$00001000
	DS.L	4
	DC.L	dat_PatternWorkBuf
dat_0B2C:
	DC.B	"Looptime"
dat_0B2D:
	DC.B	"Feedback"
dat_0B2E:
	DC.L	dat_0B2F
	DS.L	2
	DC.L	$00000064
	DC.L	dat_0B30
	DS.L	2
	DC.L	$00001000
	DS.L	4
	DC.L	dat_PatternWorkBuf
dat_0B2F:
	DC.B	"Looptime"
dat_0B30:
	DC.B	"Feedback"
dat_0B31:
	DC.L	dat_0B32
	DS.L	2
	DC.L	$00001000
	DC.L	dat_0B33
	DS.L	2
	DC.L	$00001000
	DC.L	dat_0B34
	DS.L	2
	DC.L	$00001000
	DS.L	4
	DC.L	dat_PatternWorkBuf
dat_0B32:
	DC.B	"Delay   "
dat_0B33:
	DC.B	"Feedback"
dat_0B34:
	DC.B	"Output  "
dat_0B35:
	DC.L	dat_0B36
	DS.L	2
	DC.L	$00001000
	DS.L	8
	DC.L	dat_PatternWorkBuf
dat_0B36:
	DC.B	"Output  "
dat_0B37:
	DS.L	12
	DC.L	dat_PatternWorkBuf
pt_BtnFilterWave:
	ADDQ.W	#1,dat_OscillatorIndex
pt_0B39:
	MOVE.W	(dat_OscillatorIndex,PC),D0
	CMP.W	#$0005,D0
	BMI.S	pt_0B3A
	MOVEQ	#0,D0
	MOVE.W	D0,dat_OscillatorIndex
pt_0B3A:
	LSL.L	#3,D0
	LEA	(dat_0B3B,PC,D0.L),A0
	MOVE.W	#$020e,D0
	MOVEQ	#91,D1
	MOVEQ	#8,D3
	JSR	pt_BlitPatternRow
	BRA.S	pt_0B3C
dat_0B3B:
	DC.B	"None    FreehandSinus   Max->MinMin->Max"
pt_0B3C:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$016d,D0
	MOVE.W	#$0038,D1
	MOVE.W	#$027b,D2
	MOVE.W	#$0057,D3
	MOVEQ	#0,D5
	BSR.W	pt_SetupAudioDisplay
	MOVEA.L	(dat_OscillatorData0,PC),A0
	MOVE.L	(48,A0),D0
	BEQ.W	pt_0B44
	TSTPC.W	dat_OscillatorIndex
	BEQ.W	pt_0B44
	CMPI.W	#$0002,dat_OscillatorIndex
	BNE.S	pt_0B3E
	JSR	pt_FltSinus41
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
pt_0B3E:
	CMPI.W	#$0003,dat_OscillatorIndex
	BNE.S	pt_0B40
	LEA	dat_WorkBuf3,A0
	MOVE.L	A0,D0
	MOVEQ	#0,D1
	MOVE.W	#$010d,D2
pt_0B3F:
	MOVE.L	D1,D3
	DIVU	#$0009,D3
	MOVE.B	D3,(A0)+
	ADDQ.L	#1,D1
	DBF	D2,pt_0B3F
pt_0B40:
	CMPI.W	#$0004,dat_OscillatorIndex
	BNE.S	pt_0B42
	LEA	dat_WorkBuf3,A0
	MOVE.L	A0,D0
	MOVE.W	#$010e,D1
	MOVE.W	#$010d,D2
pt_0B41:
	MOVE.L	D1,D3
	DIVU	#$0009,D3
	MOVE.B	D3,(A0)+
	SUBQ.L	#1,D1
	DBF	D2,pt_0B41
pt_0B42:
	MOVE.L	D0,dat_OscillatorBufPtr
	MOVEA.L	D0,A0
	MOVEQ	#0,D4
pt_0B43:
	MOVEQ	#0,D5
	MOVE.B	(A0)+,D5
	BSR.W	pt_OscillatorRender
	ADDQ.W	#1,D4
	CMP.W	#$010e,D4
	BMI.S	pt_0B43
pt_0B44:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BtnFilterDisplay:
	CMPI.W	#$0001,dat_OscillatorIndex
	BNE.W	pt_0B4E
	MOVE.L	(dat_OscillatorBufPtr,PC),D0
	BEQ.W	pt_0B4E
	MOVEQ	#-1,D0
pt_0B46:
	MOVEM.W	dat_EditDigitValue,D2-D3
	CMP.W	#$016d,D2
	BPL.S	pt_0B47
	MOVE.W	#$016d,D2
pt_0B47:
	CMP.W	#$0038,D3
	BPL.S	pt_0B48
	MOVEQ	#56,D3
pt_0B48:
	CMP.W	#$027a,D2
	BMI.S	pt_0B49
	MOVE.W	#$027a,D2
pt_0B49:
	CMP.W	#$0056,D3
	BMI.S	pt_0B4A
	MOVEQ	#86,D3
pt_0B4A:
	SUB.W	#$016d,D2
	SUB.W	#$0038,D3
	MOVEM.W	D2-D3,-(A7)
	TST.W	D0
	BMI.S	pt_0B4D
	CMP.W	D0,D2
	BEQ.S	pt_0B4D
	BGT.S	pt_0B4B
	EXG	D0,D2
	EXG	D1,D3
pt_0B4B:
	SUB.W	D0,D2
	MOVE.W	D0,D4
	SUB.W	D1,D3
	MOVE.W	D2,D0
	MOVE.W	D2,D7
	SUBQ.W	#1,D7
	MOVEQ	#0,D2
pt_0B4C:
	MOVE.W	D2,D5
	MULS	D3,D5
	DIVS	D0,D5
	ADD.W	D1,D5
	BSR.S	pt_OscillatorRender
	ADDQ.W	#1,D2
	ADDQ.W	#1,D4
	DBF	D7,pt_0B4C
pt_0B4D:
	MOVEM.W	(A7)+,D0-D1
	MOVE.W	D0,D4
	MOVE.W	D1,D5
	BSR.S	pt_OscillatorRender
	BSR.W	pt_ScreenDragUpdate
	LMB
	BEQ.S	pt_0B46
pt_0B4E:
	RTS
pt_OscillatorRender:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_OscillatorBufPtr,PC),A1
	MOVEQ	#0,D1
	MOVE.B	(0,A1,D4.W),D1
	MOVE.B	D5,(0,A1,D4.W)
	ADD.W	#$0038,D1
	ADD.W	#$0038,D5
	ADD.W	#$016d,D4
	MULS	#$0050,D1
	MULS	#$0050,D5
	MOVE.W	D4,D3
	ASR.W	#3,D4
	ADD.W	D4,D1
	ADD.W	D4,D5
	NOT.B	D3
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	BCLR	D3,(0,A0,D1.W)
	BSET	D3,(0,A0,D5.W)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BtnChordAdjust:
	MOVE.W	dat_DisplayIndexVar,D0
	NOT.W	D0
	MOVE.W	D0,dat_DisplayIndexVar
pt_0B51:
	LEA	(dat_0B53,PC),A0
	TST.W	dat_DisplayIndexVar
	BEQ.S	pt_0B52
	LEA	(dat_0B54,PC),A0
pt_0B52:
	MOVE.W	#$01cb,D0
	MOVE.W	#$0050,D1
	MOVEQ	#8,D3
	JMP	pt_BlitPatternRow
dat_0B53:
	DC.B	" Adjust "
dat_0B54:
	DC.B	"NoAdjust"
dat_DisplayIndexVar:
	DS.W	1
pt_BtnChordFromUp:
	ADDQ.W	#1,dat_SampleSlotIdx
	CMPI.W	#$001f,dat_SampleSlotIdx
	BMI.S	pt_0B57
	MOVE.W	#$001f,dat_SampleSlotIdx
pt_0B57:
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_ShowSampleSlot
pt_BtnChordFromDown:
	SUBQ.W	#1,dat_SampleSlotIdx
	BPL.S	pt_0B59
	CLR.W	dat_SampleSlotIdx
pt_0B59:
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_ShowSampleSlot
pt_BtnChordFromSample:
	MOVE.W	dat_CurrentSample,dat_SampleSlotIdx
pt_ShowSampleSlot:
	MOVE.W	(dat_SampleSlotIdx,PC),dat_DisplayParam
	MOVE.W	#$15c0,dat_TextBytePos
	BRA.W	pt_DrawDecValue2
pt_BtnChordToUp:
	ADDQ.W	#1,dat_SelectedSample
	CMPI.W	#$001f,dat_SelectedSample
	BMI.S	pt_0B5D
	MOVE.W	#$001f,dat_SelectedSample
pt_0B5D:
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_ShowSelectedSample
pt_BtnChordToDown:
	SUBQ.W	#1,dat_SelectedSample
	BPL.S	pt_0B5F
	CLR.W	dat_SelectedSample
pt_0B5F:
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_ShowSelectedSample
pt_BtnChordToSample:
	MOVE.W	(dat_SampleSlotIdx,PC),D0
	ADDQ.W	#1,D0
	AND.W	#$001f,D0
	MOVE.W	D0,dat_SelectedSample
pt_ShowSelectedSample:
	MOVE.W	(dat_SelectedSample,PC),dat_DisplayParam
	MOVE.W	#$1ca0,dat_TextBytePos
	BRA.W	pt_DrawDecValue2
pt_BtnChordNotesUp:
	ADDQ.W	#1,dat_SampleChunkSize
	CMPI.W	#$0007,dat_SampleChunkSize
	BMI.S	pt_0B63
	MOVE.W	#$0007,dat_SampleChunkSize
pt_0B63:
	BSR.W	pt_RefreshDisplay
	BRA.S	pt_BtnChordNotes
pt_BtnChordNotesDown:
	SUBQ.W	#1,dat_SampleChunkSize
	CMPI.W	#$0002,dat_SampleChunkSize
	BPL.S	pt_0B65
	MOVE.W	#$0002,dat_SampleChunkSize
pt_0B65:
	BSR.W	pt_RefreshDisplay
pt_BtnChordNotes:
	MOVE.W	#$15cd,dat_TextBytePos
	MOVE.W	(dat_SampleChunkSize,PC),D0
	BSR.W	pt_DrawNumberDec
	BRA.W	pt_PatternBufInit
pt_BtnChordNote1:
	MOVEQ	#1,D7
	MOVE.W	#$0174,dat_PlayCounter
	LEA	(dat_SampleRepeatOfs,PC),A6
	BRA.W	pt_ChainPlayHandler
pt_BtnChordNote2:
	MOVEQ	#2,D7
	MOVE.W	#$019c,dat_PlayCounter
	LEA	(dat_0BBD,PC),A6
	BRA.S	pt_ChainPlayHandler
pt_BtnChordNote3:
	MOVEQ	#3,D7
	CMP.W	(dat_SampleChunkSize,PC),D7
	BLE.S	pt_0B6A
	RTS
pt_0B6A:
	MOVE.W	#$01c4,dat_PlayCounter
	LEA	(dat_0BBE,PC),A6
	BRA.S	pt_ChainPlayHandler
pt_BtnChordNote4:
	MOVEQ	#4,D7
	CMP.W	(dat_SampleChunkSize,PC),D7
	BLE.S	pt_0B6C
	RTS
pt_0B6C:
	MOVE.W	#$01ec,dat_PlayCounter
	LEA	(dat_0BBF,PC),A6
	BRA.S	pt_ChainPlayHandler
pt_BtnChordNote5:
	MOVEQ	#5,D7
	CMP.W	(dat_SampleChunkSize,PC),D7
	BLE.S	pt_0B6E
	RTS
pt_0B6E:
	MOVE.W	#$0214,dat_PlayCounter
	LEA	(dat_0BC0,PC),A6
	BRA.S	pt_ChainPlayHandler
pt_BtnChordNote6:
	MOVEQ	#6,D7
	CMP.W	(dat_SampleChunkSize,PC),D7
	BLE.S	pt_0B70
	RTS
pt_0B70:
	MOVE.W	#$023c,dat_PlayCounter
	LEA	(dat_0BC1,PC),A6
	BRA.S	pt_ChainPlayHandler
pt_BtnChordNote7:
	MOVEQ	#7,D7
	CMP.W	(dat_SampleChunkSize,PC),D7
	BLE.S	pt_0B72
	RTS
pt_0B72:
	MOVE.W	#$0264,dat_PlayCounter
	LEA	(dat_SampleEditSlot,PC),A6
pt_ChainPlayHandler:
	BSR.W	pt_0B7A
	BMI.S	pt_0B74
	MOVE.W	D0,(A6)
	BSR.S	pt_PatternBufInit
	ADDI.W	#$0028,dat_PlayCounter
	LEA	(2,A6),A6
	ADDQ.W	#1,D7
	CMP.W	(dat_SampleChunkSize,PC),D7
	BLE.S	pt_ChainPlayHandler
	BRA.W	pt_BtnChordNote1
pt_0B74:
	MOVE.W	#$fff0,dat_PlayCounter
	CLR.W	dat_PatternDelay
	JSR	pt_DrawPlayCounter
	RTS
pt_PatternBufInit:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_NoteNamesPtr,A1
	MOVE.W	#$0171,D0
	MOVE.W	#$0071,D1
	LEA	(dat_SampleRepeatOfs,PC),A6
	MOVE.W	(dat_SampleChunkSize,PC),D7
	SUBQ.W	#1,D7
pt_0B76:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(A6),D2
	LSL.W	#2,D2
	LEA	(0,A1,D2.W),A0
	MOVEQ	#3,D3
	JSR	pt_BlitPatternFull
	MOVEM.L	(A7)+,D0-D7/A0-A6
	ADD.W	#$0028,D0
	LEA	(2,A6),A6
	DBF	D7,pt_0B76
pt_0B77:
	CMPA.L	#dat_SampleEditSlot,A6
	BGT.S	pt_0B78
	LEA	(dat_0B79,PC),A0
	MOVEQ	#3,D3
	JSR	pt_BlitPatternFull
	ADD.W	#$0028,D0
	LEA	(2,A6),A6
	BRA.S	pt_0B77
pt_0B78:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_0B79:
	DC.L	$20202020
pt_0B7A:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	JSR	pt_WaitMouseRelease
	MOVE.W	#$0076,dat_PatternDelay
	JSR	pt_DrawPlayCounter
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
pt_0B7B:
	BSR.W	pt_ScreenDragUpdate
	LMB
	BEQ.S	pt_RestoreAndContinue
	RMB
	BEQ.S	pt_RestoreAndContinue
	JSR	pt_GetKeypress
	MOVEQ	#0,D1
	MOVE.B	dat_KeyCode,D1
	BEQ.S	pt_0B7B
	CMP.B	#$44,D1
	BEQ.S	pt_RestoreAndContinue
	CMP.B	#$45,D1
	BEQ.S	pt_RestoreAndContinue
	JSR	pt_HandlePlayKeys
	MOVE.B	dat_KeyCode,D1
	LEA	dat_1326,A0
	MOVEQ	#38,D0
pt_0B7C:
	CMP.B	(0,A0,D0.W),D1
	BEQ.S	pt_0B7E
	DBF	D0,pt_0B7C
	BRA.S	pt_0B7B
pt_RestoreAndContinue:
	JSR	pt_RestorePalette
	MOVEM.L	(A7)+,D1-D7/A0-A6
	MOVEQ	#-1,D0
	RTS
pt_0B7E:
	MOVEA.L	dat_PlayModePtr,A0
	MOVE.B	(0,A0,D0.W),D0
	AND.L	#$000000ff,D0
	MOVE.L	D0,-(A7)
	MOVE.L	dat_SongDataPtr,-(A7)
	CLR.L	dat_SongDataPtr
	JSR	pt_KeyToPlayCmd
	MOVE.L	(A7)+,dat_SongDataPtr
	MOVE.L	(A7)+,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	TST.L	D0
	RTS
pt_BtnChordMake:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVE.W	(dat_SampleSlotIdx,PC),D5
	MULU	#s_SIZEOF,D5
	MOVE.W	(4,A0,D5.L),dat_0BB6
	MOVE.W	(6,A0,D5.L),dat_SampleSlotVar
	MOVEQ	#0,D6
	MOVE.B	(2,A0,D5.L),D6
	AND.B	#$0f,D6
	MULU	#$004a,D6
	LEA	dat_PeriodTable,A0
	ADDA.L	D6,A0
	MOVEQ	#36,D2
	MOVE.L	D2,D3
	MOVE.L	D2,D4
	MOVE.L	D2,D5
	MOVE.L	D2,D6
	MOVE.W	(dat_SampleRepeatOfs,PC),D0
	MOVE.W	(dat_0BBD,PC),D1
	CMPI.W	#$0003,dat_SampleChunkSize
	BLT.S	pt_SampleDataAlign
	MOVE.W	(dat_0BBE,PC),D2
	CMPI.W	#$0004,dat_SampleChunkSize
	BLT.S	pt_SampleDataAlign
	MOVE.W	(dat_0BBF,PC),D3
	CMPI.W	#$0005,dat_SampleChunkSize
	BLT.S	pt_SampleDataAlign
	MOVE.W	(dat_0BC0,PC),D4
	CMPI.W	#$0006,dat_SampleChunkSize
	BLT.S	pt_SampleDataAlign
	MOVE.W	(dat_0BC1,PC),D5
	CMPI.W	#$0007,dat_SampleChunkSize
	BLT.S	pt_SampleDataAlign
	MOVE.W	(dat_SampleEditSlot,PC),D6
pt_SampleDataAlign:
	MOVEQ	#6,D7
pt_0B81:
	CMP.W	D0,D1
	BPL.S	pt_0B82
	EXG	D0,D1
pt_0B82:
	CMP.W	D1,D2
	BPL.S	pt_0B83
	EXG	D1,D2
pt_0B83:
	CMP.W	D2,D3
	BPL.S	pt_0B84
	EXG	D2,D3
pt_0B84:
	CMP.W	D3,D4
	BPL.S	pt_0B85
	EXG	D3,D4
pt_0B85:
	CMP.W	D4,D5
	BPL.S	pt_0B86
	EXG	D4,D5
pt_0B86:
	CMP.W	D5,D6
	BPL.S	pt_0B87
	EXG	D5,D6
pt_0B87:
	DBF	D7,pt_0B81
	MOVE.W	D0,dat_0BC3
	MOVE.W	D1,dat_0BC4
	MOVE.W	D2,dat_0BC5
	MOVE.W	D3,dat_0BC6
	MOVE.W	D4,dat_0BC7
	MOVE.W	D5,dat_0BC8
	MOVE.W	D6,dat_0BC9
	ADD.W	D0,D0
	ADD.W	D1,D1
	ADD.W	D2,D2
	ADD.W	D3,D3
	ADD.W	D4,D4
	ADD.W	D5,D5
	ADD.W	D6,D6
	MOVE.W	(0,A0,D0.W),D0
	MOVE.W	(0,A0,D1.W),D1
	MOVE.W	(0,A0,D2.W),D2
	MOVE.W	(0,A0,D3.W),D3
	MOVE.W	(0,A0,D4.W),D4
	MOVE.W	(0,A0,D5.W),D5
	MOVE.W	(0,A0,D6.W),D6
	MOVE.W	D0,dat_0BCB
	BNE.S	pt_0B88
	JMP	pt_SetPaletteEdit
pt_0B88:
	MOVE.W	D1,dat_0BCD
	BNE.S	pt_0B89
	JMP	pt_SetPaletteEdit
pt_0B89:
	MOVEQ	#2,D7
	MOVE.W	D2,dat_0BCF
	BEQ.S	pt_SetSampleRepeatLen
	ADDQ.W	#1,D7
	MOVE.W	D3,dat_0BD1
	BEQ.S	pt_SetSampleRepeatLen
	ADDQ.W	#1,D7
	MOVE.W	D4,dat_0BD3
	BEQ.S	pt_SetSampleRepeatLen
	ADDQ.W	#1,D7
	MOVE.W	D5,dat_0BD5
	BEQ.S	pt_SetSampleRepeatLen
	ADDQ.W	#1,D7
	MOVE.W	D6,dat_0BD7
	BEQ.S	pt_SetSampleRepeatLen
	ADDQ.W	#1,D7
pt_SetSampleRepeatLen:
	MOVE.W	D7,dat_SampleRepeatLen
	MOVE.W	(dat_SampleSlotIdx,PC),D5
	CMP.W	(dat_SelectedSample,PC),D5
	BNE.S	pt_0B8B
	JMP	pt_SetPaletteEdit
pt_0B8B:
	LSL.W	#2,D5
	LEA	dat_ModulePtr,A0
	ADDA.W	D5,A0
	MOVE.L	(124,A0),D4
	BNE.S	pt_0B8C
	JMP	pt_SetPaletteEdit
pt_0B8C:
	MOVE.L	D4,dat_PatBufEndPtr
	MOVE.L	(A0),D0
	BNE.S	pt_0B8D
	JMP	pt_SetPaletteEdit
pt_0B8D:
	MOVE.L	D0,dat_0BB3
	MOVE.W	(dat_SelectedSample,PC),D5
	BNE.S	pt_0B8E
	JMP	pt_SetPaletteEdit
pt_0B8E:
	LSL.W	#2,D5
	LEA	dat_ModulePtr,A5
	ADDA.W	D5,A5
	MOVE.L	(A5),D0
	BEQ.S	pt_0B8F
	LEA	(dat_0BD8,PC),A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_0B8F
	RTS
pt_0B8F:
	MOVE.W	(dat_SelectedSample,PC),dat_CurrentSample
	BSR.W	pt_GetSamplePtrEntry
	MOVE.L	(dat_PatBufEndPtr,PC),D0
	LEA	dat_ModulePtr,A4
	MOVE.W	dat_CurrentSample,D1
	LSL.W	#2,D1
	ADDA.W	D1,A4
	MOVE.L	D0,(124,A4)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	(dat_DiskOpViewMode,PC),D1
	JSR	(-198,A6)
	MOVE.L	D0,(A4)
	BEQ.W	pt_SetupPaletteMode
	MOVE.L	D0,dat_PatternBufVar
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_SampleSlotIdx,D0
	MULU	#s_SIZEOF,D0
	MOVE.W	dat_SelectedSample,D1
	MULU	#s_SIZEOF,D1
	LEA	(-10,A0),A0
	LEA	(0,A0,D1.L),A1
	LEA	(0,A0,D0.L),A0
	MOVEA.L	A1,A2
	MOVEQ	#29,D0
pt_0B90:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0B90
	MOVEA.L	A2,A0
	MOVEQ	#19,D0
	TST.B	(A0)
	BEQ.S	pt_WriteHashChar
pt_0B91:
	TST.B	(A0)+
	BEQ.S	pt_0B92
	DBF	D0,pt_0B91
	BRA.S	pt_0B96
pt_0B92:
	SUBQ.L	#1,A0
	ADDQ.W	#1,D0
	MOVE.W	(dat_SampleRepeatLen,PC),D1
	SUBQ.W	#2,D1
	BMI.S	pt_WriteHashChar
	CMP.W	D1,D0
	BLT.S	pt_WriteHashChar
	LEA	(dat_0BC3,PC),A1
	MOVE.W	(A1)+,D2
pt_0B93:
	MOVE.W	(A1)+,D0
	SUB.W	D2,D0
	ADD.B	#$30,D0
	CMP.B	#$39,D0
	BLS.S	pt_0B94
	ADDQ.B	#8,D0
pt_0B94:
	MOVE.B	D0,(A0)+
	DBF	D1,pt_0B93
	BRA.S	pt_0B96
