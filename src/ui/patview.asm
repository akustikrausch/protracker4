pt_PatViewDrawAll:
	TST.W	dat_RecordMode
	BNE.S	pt_PatViewDrawAll0
	CLR.B	dat_KeyCode
pt_PatViewDrawAll0:
	TST.W	dat_SamplerActive
	BEQ.S	pt_PatViewDrawAll1
	RTS
pt_PatViewDrawAll1:
	JSR	pt_ClearDataRegs
pt_PatViewDrawAll2:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.B	dat_PatViewBusy
	BNE.W	pt_PatViewDrawDone
	ST	dat_PatViewBusy
	SF	dat_PatJumpFlag
	MOVE.W	#$0143,dat_PaletteVarA
	MOVE.W	#$0080,dat_PaletteVarB
	MOVE.W	dat_136F,dat_DisplayParam
	BSR.W	pt_0F6F
	MOVEA.L	(dat_ModulePtr,PC),A6
	LEA	(mod_patterns,A6),A6
	MOVE.L	dat_PatTableIdx,D6
	LSL.L	#8,D6
	LSL.L	#2,D6
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatViewDrawPattern
	LSL.L	#1,D6
pt_PatViewDrawPattern:
	ADDA.L	D6,A6
	MOVE.W	#$3ca2,dat_TextBytePos
	CLR.L	dat_RowCounter
	LEA	(dat_PeriodTable,PC),A2
	LEA	(dat_NoteCellText,PC),A3
	LEA	(dat_HexPairTable,PC),A4
	MOVEQ	#48,D4
	BTST	#3,dat_InputReadyFlag
	SNE	D5
	MOVEQ	#63,D6
pt_PatViewRowLoop:
	MOVE.W	dat_RpNumChannels,D7
	SUBQ.W	#1,D7
	MOVE.W	dat_1365,dat_DisplayParam
	MOVEQ	#1,D1
	BSR.W	pt_DrawTrackDecimal
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatViewRowStart
	ADDQ.W	#2,dat_TextBytePos
pt_PatViewRowStart:
	SUBQ.W	#1,dat_TextBytePos
	ADDQ.L	#1,dat_RowCounter
pt_PatViewCellLoop:
	BSR.S	pt_FormatNoteCell
	DBF	D7,pt_PatViewCellLoop
	ADDI.W	#$0233,dat_TextBytePos
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatViewRowNext
	ADDQ.W	#1,dat_TextBytePos
pt_PatViewRowNext:
	DBF	D6,pt_PatViewRowLoop
pt_PatViewDrawDone:
	SF	dat_PatViewBusy
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_PatViewDrawCell:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	A0,A6
	LEA	(dat_PeriodTable,PC),A2
	LEA	(dat_NoteCellText,PC),A3
	LEA	(dat_HexPairTable,PC),A4
	MOVEQ	#48,D4
	BTST	#3,dat_InputReadyFlag
	SNE	D5
	BSR.S	pt_FormatNoteCell
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_NoteBlank:
	DC.L	$202d2020
dat_NoteDots:
	DC.L	$20202e20
pt_FormatNoteCell:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	(A6),D1
	AND.W	#$0fff,D1
	BNE.S	pt_FormatNoteSearch
	MOVE.L	(dat_NoteBlank,PC),(A3)
	BRA.S	pt_FormatNoteSampleFx
pt_FormatNoteSearch:
	MOVEQ	#36,D2
pt_FormatNoteLoop:
	CMP.W	(0,A2,D0.W),D1
	BEQ.S	pt_FormatNoteName
	ADDQ.L	#2,D0
	DBF	D2,pt_FormatNoteLoop
	MOVE.L	#$3f3f3f20,(A3)
	BRA.S	pt_FormatNoteSampleFx
pt_FormatNoteName:
	LSL.L	#1,D0
	ADD.L	(dat_NoteNamesPtr,PC),D0
	MOVEA.L	D0,A0
	MOVE.L	(A0),(A3)
	MOVEQ	#-1,D2
pt_FormatNoteSampleFx:
	MOVEQ	#0,D0
	MOVE.B	(A6),D0
	ADD.W	D0,D0
	MOVE.B	(0,A4,D0.W),(3,A3)
	MOVEQ	#0,D0
	MOVE.B	(2,A6),D0
	ADD.W	D0,D0
	MOVE.B	(0,A4,D0.W),(4,A3)
	MOVE.B	(1,A4,D0.W),(5,A3)
	MOVEQ	#0,D0
	MOVE.B	(3,A6),D0
	ADD.W	D0,D0
	MOVE.B	(0,A4,D0.W),(6,A3)
	MOVE.B	(1,A4,D0.W),(7,A3)
	LEA	(4,A6),A6
	TST.B	D5
	BEQ.S	pt_FormatNoteDraw
	CMP.B	(3,A3),D4
	BNE.S	pt_FormatNoteBlankFx
	MOVE.B	#$20,(3,A3)
	CMP.B	(4,A3),D4
	BNE.S	pt_FormatNoteBlankFx
	MOVE.B	#$2d,(4,A3)
pt_FormatNoteBlankFx:
	MOVE.B	(5,A3),D1
	OR.B	(6,A3),D1
	OR.B	(7,A3),D1
	CMP.B	D4,D1
	BNE.S	pt_FormatNoteDraw
	LEA	(dat_NoteDots,PC),A0
	MOVE.B	(A0)+,(5,A3)
	MOVE.B	(A0)+,(5,A3)
	MOVE.B	(A0)+,(6,A3)
	MOVE.B	(A0)+,(7,A3)
pt_FormatNoteDraw:
	MOVE.W	#$0008,dat_TextCharCount
	MOVE.L	A3,dat_TextStringPtr
	MOVEQ	#0,D1
	BSR.S	pt_DrawTrackText
	ADDQ.W	#2,dat_TextBytePos
	BTST	#5,dat_ModeFlags
	BNE.S	pt_FormatNoteDone
	SUBQ.W	#1,dat_TextBytePos
pt_FormatNoteDone:
	RTS
dat_NoteCellText:
	DC.B	"---00000",0,0
pt_DrawTrackDecimal:
	MOVEM.L	D1,-(A7)
	MOVE.W	#$0003,dat_TextCharCount
	MOVEQ	#0,D1
	MOVE.W	(dat_DisplayParam,PC),D1
	LEA	(dat_DecimalDigitBuf,PC),A0
	DIVU	#$000a,D1
	BSR.W	pt_WriteDecimalDigit
	BSR.W	pt_WriteDecimalDigit
	LEA	(dat_DecimalDigitBuf,PC),A0
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$2020,(2,A0)
	MOVEM.L	(A7)+,D1
pt_DrawTrackText:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEQ	#0,D0
	MOVE.W	dat_TextCharCount,D0
	MOVEA.L	dat_TextStringPtr,A0
	LEA	chip_ScreenBitplanes2,A1
	MOVEQ	#0,D2
	MOVE.W	dat_TextBytePos,D2
	ADDA.L	D2,A1
	LEA	dat_146F,A2
	ADDA.L	dat_TrackFontOffset,A2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_DrawTrackText2
	LEA	(1024,A2),A2
pt_DrawTrackText2:
	MOVE.L	D0,D7
	MOVE.L	D1,D6
	AND.L	#$00000001,D6
	SUBQ.L	#1,D7
	BMI.W	pt_RestoreAllRegs
pt_DrawTrackTextChar:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ.W	pt_RestoreAllRegs
	SUB.B	#$20,D0
	ADD.L	D0,D0
	LEA	(0,A2,D0.L),A3
	MOVE.B	(A3),(A1)
	MOVE.B	(1,A3),(1,A1)
	MOVE.B	(128,A3),(80,A1)
	MOVE.B	(256,A3),(160,A1)
	MOVE.B	(384,A3),(240,A1)
	MOVE.B	(512,A3),(320,A1)
	MOVE.B	(640,A3),(400,A1)
	MOVE.B	(768,A3),(480,A1)
	MOVE.B	(896,A3),(560,A1)
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_DrawTrackTextNarrow
	MOVE.B	(129,A3),(81,A1)
	MOVE.B	(257,A3),(161,A1)
	MOVE.B	(385,A3),(241,A1)
	MOVE.B	(513,A3),(321,A1)
	MOVE.B	(641,A3),(401,A1)
	MOVE.B	(769,A3),(481,A1)
	MOVE.B	(897,A3),(561,A1)
	ADDQ.L	#2,A1
	ADDQ.W	#2,dat_TextBytePos
	DBF	D7,pt_DrawTrackTextChar
pt_RestoreAllRegs:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_DrawTrackTextNarrow:
	ADDQ.L	#1,A1
	ADDQ.W	#1,dat_TextBytePos
	DBF	D7,pt_DrawTrackTextChar
	BRA.S	pt_RestoreAllRegs
pt_DrawPosPatNumbers:
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_positions,A0),A0
	ADDA.L	dat_BplUpdateReq,A0
	CLR.B	dat_DisplayParam
	MOVE.B	(A0),dat_ButtonStateFlag
	MOVE.B	(A0),dat_PatSyncFlag
	MOVEQ	#0,D1
	MOVE.B	(A0),D1
	CMP.B	dat_ChannelSolo,D1
	BEQ.S	pt_0F5C
	ST	dat_PatJumpFlag
pt_0F5C:
	MOVE.W	#$1228,dat_TextBytePos
	MOVE.B	(A0),dat_ChannelSolo
	TST.W	dat_UIMode
	BEQ.S	pt_0F5D
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_0F5D
	RTS
pt_0F5D:
	BSR.W	pt_FormatDecimal
	MOVE.W	dat_CurrentPattern,dat_DisplayParam
	MOVE.W	#$0eb8,dat_TextBytePos
	BRA.W	pt_FormatDecimal
pt_DrawPanelByMode:
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_DrawSampleTableInfo
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_DrawSampleTableInfo
	CMPI.W	#$0005,dat_UIMode
	BEQ.S	pt_DrawSampleTableInfo
	CMPI.W	#$0006,dat_UIMode
	BEQ.S	pt_DrawSampleTableInfo
	CMPI.W	#$0008,dat_UIMode
	BEQ.S	pt_DrawSampleTableInfo
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_DrawSampleTableInfo
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_songlen,A0),A0
	MOVE.L	A0,dat_ModuleChanged
	CLR.W	dat_DisplayParam
	MOVE.B	(A0),dat_ButtonStateFlag
	MOVE.W	#$1598,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	MOVEA.L	dat_ModuleChanged,A0
pt_DrawSampleTableInfo:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	#$07d8,D1
	MOVEQ	#20,D0
	BRA.W	pt_DrawTextAt
pt_DrawSampleHex:
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_DrawHexValue
	RTS
pt_DrawHexValue:
	MOVEQ	#0,D0
	MOVE.W	(dat_CurrentSample,PC),D0
	MOVE.W	D0,dat_SamplePlayMode
	BNE.S	pt_0F62
	MOVE.W	(dat_SamplePlayInit,PC),D0
pt_0F62:
	MOVE.W	D0,D1
	LSL.L	#2,D0
	LEA	(dat_ModulePtr,PC),A0
	MOVE.L	(0,A0,D0.W),dat_EffectBuf
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(-10,A0),A0
	MOVE.W	D1,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVE.L	A0,dat_ModuleChanged
	MOVE.L	(22,A0),dat_EffectData0
	MOVE.L	(26,A0),dat_EffectState0
	TST.B	dat_EditInputLock
	BNE.W	pt_0F67
	MOVE.L	A0,-(A7)
	MOVE.B	#$20,dat_DisplayWordVal
	MOVE.B	(24,A0),D0
	BEQ.S	pt_0F63
	AND.B	#$0f,D0
	MOVE.B	#$2b,dat_DisplayWordVal
	BTST	#3,D0
	BEQ.S	pt_0F63
	MOVE.B	#$2d,dat_DisplayWordVal
	MOVEQ	#16,D1
	SUB.B	D0,D1
	MOVE.B	D1,D0
pt_0F63:
	MOVE.W	#$235b,dat_TextBytePos
	BSR.W	pt_DrawNumberDec
	LEA	(dat_DisplayWordVal,PC),A0
	MOVE.W	#$235a,D1
	MOVEQ	#1,D0
	BSR.W	pt_DrawTextAt
	MOVEA.L	(A7)+,A0
	CLR.W	dat_DisplayParam
	MOVE.B	(25,A0),dat_ButtonStateFlag
	MOVE.W	dat_DisplayParam,dat_DisplayWordVar2
	ORI.W	#$0c00,dat_DisplayWordVar2
	MOVE.W	#$1fea,dat_TextBytePos
	BTST	#7,dat_ModeFlags
	BNE.S	pt_0F64
	BSR.W	pt_DrawDecValue3
	BRA.S	pt_0F65
pt_0F64:
	BSR.W	pt_Format2DigitHex
pt_0F65:
	MOVEQ	#0,D2
	MOVE.W	(dat_EffectData0,PC),D2
	ADD.L	D2,D2
	MOVE.L	(dat_SampleEditOffset,PC),D3
	CMP.L	D2,D3
	BLS.S	pt_0F66
	MOVE.L	D2,dat_SampleEditOffset
	BSR.W	pt_CheckEditModeType
	MOVEQ	#0,D2
	MOVE.W	(dat_EffectData0,PC),D2
	ADD.L	D2,D2
pt_0F66:
	MOVE.W	#$00a9,D0
	MOVEQ	#91,D1
	MOVEQ	#6,D3
	BSR.W	pt_BlitPatternSetup
	MOVE.W	#$00a9,D0
	MOVEQ	#102,D1
	MOVEQ	#0,D2
	MOVE.W	dat_EffectState0,D2
	ADD.L	D2,D2
	MOVEQ	#6,D3
	BSR.W	pt_BlitPatternSetup
	MOVE.W	#$00a9,D0
	MOVEQ	#113,D1
	MOVEQ	#0,D2
	MOVE.W	dat_EffectState1,D2
	ADD.L	D2,D2
	MOVEQ	#6,D3
	BSR.W	pt_BlitPatternSetup
	BSR.S	pt_0F69
pt_0F67:
	TST.B	dat_EditInputLock
	BEQ.S	pt_0F68
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_0F68
	RTS
pt_0F68:
	MOVEA.L	dat_ModuleChanged,A0
	MOVE.W	#$1906,D1
	MOVEQ	#22,D0
	BSR.W	pt_DrawTextAt
	RTS
pt_0F69:
	TST.B	dat_EditInputLock
	BEQ.S	pt_0F6A
	RTS
pt_0F6A:
	MOVE.W	(dat_CurrentSample,PC),dat_DisplayParam
	MOVE.W	#$1c7a,dat_TextBytePos
	BTST	#7,dat_ModeFlags
	BNE.S	pt_0F6B
	BRA.W	pt_DrawDecValue3
pt_0F6B:
	BRA.S	pt_Format2DigitHex
dat_DisplayWordVal:
	DC.W	$2000
dat_DisplayWordVar2:
	DS.W	1
pt_Format2DigitHex:
	MOVE.W	#$0002,dat_TextCharCount
	MOVEQ	#0,D1
	MOVE.W	(dat_DisplayParam,PC),D1
	LEA	(dat_DecimalDigitBuf,PC),A0
	BRA.S	pt_0F74
pt_0F6F:
	MOVE.W	#$0002,dat_TextCharCount
	MOVEQ	#3,D1
	MOVE.W	(dat_DisplayParam,PC),D1
	LEA	(dat_DecimalDigitBuf,PC),A0
	BRA.S	pt_0F76
pt_DrawTempoStr:
	MOVE.W	#$0003,dat_TextCharCount
	MOVEQ	#0,D1
	MOVE.W	(dat_DisplayParam,PC),D1
	LEA	(dat_DecimalDigitBuf,PC),A0
	BRA.S	pt_0F73
pt_DrawBPMValue:
	MOVE.W	#$0003,dat_TextCharCount
	MOVEQ	#0,D1
	MOVE.W	(dat_DisplayParam,PC),D1
	LEA	(dat_DecimalDigitBuf,PC),A0
	BRA.S	pt_0F75
pt_FormatDecimal:
	MOVE.W	#$0004,dat_TextCharCount
	MOVEQ	#0,D1
	MOVE.W	(dat_DisplayParam,PC),D1
	LEA	(dat_DecimalDigitBuf,PC),A0
	DIVU	#$03e8,D1
	BSR.S	pt_WriteDecimalDigit
pt_0F73:
	DIVU	#$0064,D1
	BSR.S	pt_WriteDecimalDigit
pt_0F74:
	DIVU	#$000a,D1
	BSR.S	pt_WriteDecimalDigit
	BSR.S	pt_WriteDecimalDigit
	MOVEA.L	#dat_DecimalDigitBuf,A0
	BRA.W	pt_DrawTextSetup
pt_0F75:
	DIVU	#$0064,D1
	BSR.S	pt_WriteDecimalDigit
pt_0F76:
	DIVU	#$000a,D1
	BSR.S	pt_WriteDecimalDigit
	BSR.S	pt_WriteDecimalDigit
	MOVEA.L	#dat_DecimalDigitBuf,A0
	MOVE.W	dat_PaletteVarA,D0
	MOVE.W	dat_PaletteVarB,D1
	MOVE.W	dat_TextCharCount,D3
	MOVE.W	#$0203,D2
	BRA.W	pt_SaveRegsAudioProc
pt_WriteDecimalDigit:
	ADD.B	#$30,D1
	MOVE.B	D1,(A0)+
	CLR.W	D1
	SWAP	D1
	RTS
pt_FormatNumToDecimal:
	LEA	dat_DecimalDigitBuf,A0
	MOVE.L	D0,D1
	CMP.L	#$05f5e100,D1
	BCC.W	pt_0F82
	CMP.L	#$00989680,D1
	BCC.W	pt_0F81
	CMP.L	#$000f4240,D1
	BCC.W	pt_0F7F
	SWAP	D1
	CLR.W	D1
	SWAP	D1
	DIVU	#$000a,D1
	SWAP	D1
	ADD.B	#$30,D1
	MOVE.B	D1,(5,A0)
	CMP.L	#$0000000a,D0
	BCS.S	pt_0F79
	DIVU	#$0064,D0
	MOVE.L	D0,D1
	CLR.W	D0
	SWAP	D0
	DIVU	#$000a,D0
	ADD.B	#$30,D0
	MOVE.B	D0,(4,A0)
	AND.L	#$0000ffff,D1
	BEQ.S	pt_0F7A
	DIVU	#$000a,D1
	SWAP	D1
	ADD.B	#$30,D1
	MOVE.B	D1,(3,A0)
	CLR.W	D1
	SWAP	D1
	TST.W	D1
	BEQ.S	pt_0F7B
	DIVU	#$000a,D1
	SWAP	D1
	ADD.B	#$30,D1
	MOVE.B	D1,(2,A0)
	CLR.W	D1
	SWAP	D1
	TST.W	D1
	BEQ.S	pt_0F7C
	DIVU	#$000a,D1
	SWAP	D1
	ADD.B	#$30,D1
	MOVE.B	D1,(1,A0)
	CLR.W	D1
	SWAP	D1
	TST.W	D1
	BEQ.S	pt_0F7D
	DIVU	#$000a,D1
	SWAP	D1
	ADD.B	#$30,D1
	MOVE.B	D1,(A0)
	BRA.S	pt_0F7E
pt_0F79:
	MOVE.B	#$20,(4,A0)
pt_0F7A:
	MOVE.B	#$20,(3,A0)
pt_0F7B:
	MOVE.B	#$20,(2,A0)
pt_0F7C:
	MOVE.B	#$20,(1,A0)
pt_0F7D:
	MOVE.B	#$20,(A0)
pt_0F7E:
	MOVE.W	#$0006,dat_TextCharCount
	BRA.W	pt_DrawTextSetup
pt_0F7F:
	MOVE.B	#$20,D0
	BSR.S	pt_DisplayDigitFormat
	DIVU	#$03e8,D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_FormatDecimal
	MOVE.B	#$4b,D0
pt_DisplayDigitFormat:
	LEA	(dat_DecimalDigitBuf,PC),A0
	MOVE.B	D0,(A0)
	MOVE.W	#$0001,dat_TextCharCount
	BRA.W	pt_DrawTextSetup
pt_0F81:
	DIVU	#$2710,D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_FormatDecimal
	MOVE.B	#$30,D0
	BSR.S	pt_DisplayDigitFormat
	MOVE.B	#$4b,D0
	BRA.S	pt_DisplayDigitFormat
pt_0F82:
	CMPI.B	#$02,dat_CPUType
	BCS.S	pt_0F82_68000
	DC.W	$4c7c,$0000,$0001,$86a0
	BRA.S	pt_0F82_join
pt_0F82_68000:
	JSR	pt_DivU32_100000
pt_0F82_join:
	LSR.L	#2,D0
	MOVE.W	D0,dat_DisplayParam
pt_0F83:
	DIVU	#$2710,D0
	LSR.L	#2,D0
	MOVE.W	D0,dat_ButtonActive
	BSR.W	pt_FormatDecimal
	SUBQ.W	#1,dat_TextBytePos
	MOVE.B	#$20,D0
	BSR.S	pt_DisplayDigitFormat
	MOVE.B	#$4d,D0
	BSR.S	pt_DisplayDigitFormat
	MOVE.B	#$42,D0
	BRA.S	pt_DisplayDigitFormat
dat_PaletteVarA:
	DS.W	1
dat_PaletteVarB:
	DS.W	1
dat_DecimalDigitBuf:
	DS.L	1
	DS.W	1
pt_BlitPatternSetup:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(dat_0F88,PC),A0
	MOVEM.W	D0-D1,-(A7)
	MOVE.L	D2,D0
	MOVE.W	D3,D1
	BSR.S	pt_0F89
	MOVEM.W	(A7)+,D0-D1
	BSR.W	pt_BlitPatternFull
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_0F88:
	DS.L	3
pt_0F89:
	MOVEM.L	D0-D4/A0-A1,-(A7)
	MOVEQ	#10,D2
	SUB.W	D1,D2
	BMI.S	pt_0F90
	LSL.W	#2,D2
	LEA	(dat_0F91,PC,D2.W),A1
	MOVEQ	#0,D4
pt_0F8A:
	MOVE.L	(A1)+,D3
	BEQ.S	pt_0F8F
	MOVEQ	#48,D2
pt_0F8B:
	CMP.L	D3,D0
	BCS.S	pt_0F8C
	SUB.L	D3,D0
	ADDQ.B	#1,D2
	BRA.S	pt_0F8B
pt_0F8C:
	CMP.B	#$30,D2
	BNE.S	pt_0F8D
	TST.W	D4
	BNE.S	pt_0F8D
	MOVEQ	#32,D2
	BRA.S	pt_0F8E
pt_0F8D:
	MOVEQ	#-1,D4
pt_0F8E:
	MOVE.B	D2,(A0)+
	BRA.S	pt_0F8A
pt_0F8F:
	CMPI.B	#$20,(-1,A0)
	BNE.S	pt_0F90
	MOVE.B	#$30,(-1,A0)
pt_0F90:
	MOVEM.L	(A7)+,D0-D4/A0-A1
	RTS
dat_0F91:
	DC.L	$3b9aca00,$05f5e100,$00989680,$000f4240
	DC.L	$000186a0,$00002710,$000003e8,$00000064
	DC.L	$0000000a,$00000001
	DS.L	1
pt_0F92:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	LEA	(0,A0,D0.W),A1
	LEA	(dat_0F99,PC),A2
	MOVEQ	#0,D3
pt_0F93:
	MOVE.B	(-1,A1),D1
	CMP.B	#$30,D1
	BCS.S	pt_0F94
	CMP.B	#$39,D1
	BCS.S	pt_0F95
pt_0F94:
	SUBQ.L	#1,A1
	SUBQ.W	#1,D0
	BNE.S	pt_0F93
	BRA.S	pt_ExitWithResult
pt_0F95:
	MOVE.B	-(A1),D1
	CMP.B	#$30,D1
	BCS.S	pt_ExitWithResult
	CMP.B	#$39,D1
	BHI.S	pt_ExitWithResult
	SUB.B	#$30,D1
	AND.W	#$000f,D1
	MOVE.L	(A2)+,D2
	BEQ.S	pt_ExitWithResult
pt_0F96:
	TST.W	D1
	BEQ.S	pt_0F97
	ADD.L	D2,D3
	SUBQ.W	#1,D1
	BPL.S	pt_0F96
pt_0F97:
	SUBQ.W	#1,D0
	BNE.S	pt_0F93
pt_ExitWithResult:
	MOVE.L	D3,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
dat_0F99:
	DC.L	$00000001,$0000000a,$00000064,$000003e8
	DC.L	$00002710,$000186a0,$000f4240,$00989680
	DC.L	$05f5e100,$3b9aca00
	DS.L	1
pt_DrawNumberDec:
	AND.L	#$0000000f,D0
	ADD.L	D0,D0
	LEA	(str_NoteNames,PC),A0
	ADDA.L	D0,A0
	MOVE.W	#$0001,dat_TextCharCount
	BRA.W	pt_DrawTextSetup
pt_DrawNumberHex:
	AND.L	#$0000000f,D3
	ADD.L	D3,D3
	LEA	(str_NoteNames,PC),A0
	ADDA.L	D3,A0
	MOVE.W	#$0001,D3
	BRA.W	pt_BlitPatternFull
pt_DrawDecValue2:
	LEA	(dat_DisplayParam,PC),A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	LSL.L	#1,D0
	LEA	(dat_HexPairTable,PC),A0
	ADDA.L	D0,A0
	MOVE.W	#$0002,dat_TextCharCount
	BSR.W	pt_DrawTextSetup
pt_DrawDecValue3:
	LEA	(dat_DisplayParam,PC),A0
	MOVEQ	#0,D0
	MOVE.B	(1,A0),D0
	LSL.L	#1,D0
	MOVEA.L	#dat_HexPairTable,A0
	ADDA.L	D0,A0
	MOVE.W	#$0002,dat_TextCharCount
	BSR.W	pt_DrawTextSetup
	CLR.W	dat_DisplayParam
	RTS
pt_0F9E:
	LEA	(dat_DisplayParam,PC),A0
	MOVEQ	#0,D3
	MOVE.B	(1,A0),D3
	LSL.L	#1,D3
	MOVEA.L	#dat_HexPairTable,A0
	ADDA.L	D3,A0
	MOVE.W	#$0002,D3
	BSR.W	pt_BlitPatternFull
	CLR.W	dat_DisplayParam
	RTS
pt_WaitAndRedrawUI:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	SECSTRT_2,A4
	MOVEQ	#0,D6
	MOVE.W	#$0002,dat_TextBlitLineCount
	BSR.W	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0FA0:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	MOVEA.L	dat_AudioPlayBufPtr,A4
	MOVEQ	#0,D6
	MOVE.W	#$0001,dat_TextBlitLineCount
	BSR.W	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_SetupAudioDisplay:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A4
	MOVEQ	#0,D6
	MOVE.W	#$0001,dat_TextBlitLineCount
	BSR.W	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0FA2:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	SECSTRT_2,A4
	MOVE.W	#$035a,D6
	MOVE.W	#$0002,dat_TextBlitLineCount
	BSR.W	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CloseGfxLib:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	SECSTRT_2,A4
	ADDA.W	#$5000,A4
	MOVE.W	#$035a,D6
	MOVE.W	#$0001,dat_TextBlitLineCount
	BSR.S	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_SaveRegsDisplay:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	MOVEA.L	dat_AudioPlayBufPtr,A4
	MOVE.W	#$035a,D6
	MOVE.W	#$0001,dat_TextBlitLineCount
	BSR.S	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0FA5:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	MOVEA.L	dat_ScreenBuf2Ptr,A4
	MOVE.W	#$035a,D6
	MOVE.W	#$0001,dat_TextBlitLineCount
	BSR.S	pt_BlitTextRow
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BlitTextRow:
	LEA	HARDBASE,A6
	CMP.W	#$027f,D0
	BHI.W	pt_0FA9
	MOVEQ	#0,D7
pt_0FA7:
	BTST	#6,(2,A6)
	BNE.S	pt_0FA7
	CMP.W	#$035a,D6
	BEQ.S	pt_0FA8
	MOVE.W	#$030a,D6
	BTST	D7,D5
	BEQ.S	pt_0FA8
	MOVE.W	#$03fa,D6
pt_0FA8:
	MOVEM.W	D0-D5,-(A7)
	MOVEA.L	A4,A5
	ADD.W	#$0010,D2
	MOVE.W	D6,(64,A6)
	CLR.W	(66,A6)
	MOVE.W	D2,D4
	AND.W	#$000f,D4
	MOVE.W	#$ffff,D5
	LSR.W	D4,D5
	EORI.W	#$ffff,D5
	MOVE.W	D5,(70,A6)
	MOVE.W	D0,D4
	AND.W	#$000f,D4
	MOVE.W	#$ffff,D5
	LSR.W	D4,D5
	MOVE.W	D5,(68,A6)
	SUB.W	D1,D3
	MULU	#$0050,D1
	ADDA.L	D1,A5
	ADD.W	D4,D2
	SUB.W	D0,D2
	LSR.W	#3,D0
	AND.W	#$fffe,D0
	EXT.L	D0
	ADDA.L	D0,A5
	LSR.W	#3,D2
	AND.W	#$fffe,D2
	MOVE.W	#$0050,D4
	NEG.W	D2
	ADD.W	D2,D4
	MOVE.W	D4,(96,A6)
	MOVE.W	D2,(100,A6)
	MOVE.W	D4,(102,A6)
	NEG.W	D2
	MOVE.L	A5,(72,A6)
	MOVE.W	#$ffff,(116,A6)
	MOVE.L	A5,(84,A6)
	LSL.W	#6,D3
	LSR.W	#1,D2
	ADD.W	D2,D3
	MOVE.W	D3,(88,A6)
	MOVEM.W	(A7)+,D0-D5
	ADDA.W	#$5000,A4
	ADDQ.W	#1,D7
	CMP.W	(dat_TextBlitLineCount,PC),D7
	BMI.W	pt_0FA7
pt_0FA9:
	BTST	#6,(2,A6)
	BNE.S	pt_0FA9
	RTS
dat_TextBlitLineCount:
	DC.W	$0001
	SHIFTPAD	3
pt_DrawTextAt:
	MOVE.W	D0,dat_TextCharCount
	MOVE.W	D1,dat_TextBytePos
pt_DrawTextSetup:
	MOVE.L	A0,dat_TextStringPtr
pt_DrawTextRender:
	BTST	#1,dat_FontMode
	BEQ.S	pt_DrawTextLarge
	MOVEM.L	A2-A4,-(A7)
	LEA	(dat_FontMapSmall,PC),A3
	LEA	chip_FontSmall,A4
	MOVE.W	(dat_TextCharCount,PC),D0
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A1
	MOVEQ	#0,D1
	MOVE.W	(dat_TextBytePos,PC),D1
	SUB.W	#$0050,D1
	LEA	(0,A1,D1.W),A1
	ADD.W	D0,dat_TextBytePos
	MOVEA.L	(dat_TextStringPtr,PC),A0
	BRA.S	pt_DrawCharNext
pt_DrawCharLoop:
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	BNE.S	pt_DrawCharLookup
	MOVE.B	(dat_FillChar,PC),D1
pt_DrawCharLookup:
	MOVE.B	(0,A3,D1.W),D1
	LSL.W	#3,D1
	MOVEA.L	A4,A2
	ADDA.L	D1,A2
	SUBQ.L	#1,A2
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(79,A1)
	MOVE.B	(A2)+,(159,A1)
	MOVE.B	(A2)+,(239,A1)
	MOVE.B	(A2)+,(319,A1)
	MOVE.B	(A2)+,(399,A1)
	MOVE.B	(A2),(479,A1)
pt_DrawCharNext:
	DBF	D0,pt_DrawCharLoop
	MOVEM.L	(A7)+,A2-A4
	RTS
pt_DrawTextLarge:
	MOVEM.L	A2-A4,-(A7)
	LEA	(dat_FontMapLarge,PC),A3
	LEA	chip_FontLarge,A4
	MOVE.W	(dat_TextCharCount,PC),D0
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A1
	MOVEQ	#0,D1
	MOVE.W	(dat_TextBytePos,PC),D1
	LEA	(0,A1,D1.W),A1
	ADD.W	D0,dat_TextBytePos
	MOVEA.L	(dat_TextStringPtr,PC),A0
	BRA.S	pt_0FB4
pt_0FB2:
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	BNE.S	pt_0FB3
	MOVE.B	(dat_FillChar,PC),D1
pt_0FB3:
	MOVE.B	(0,A3,D1.W),D1
	LSL.W	#3,D1
	MOVEA.L	A4,A2
	ADDA.L	D1,A2
	MOVE.B	(A2)+,(A1)+
	MOVE.B	(A2)+,(79,A1)
	MOVE.B	(A2)+,(159,A1)
	MOVE.B	(A2)+,(239,A1)
	MOVE.B	(A2),(319,A1)
pt_0FB4:
	DBF	D0,pt_0FB2
	MOVEM.L	(A7)+,A2-A4
	RTS
pt_DrawTextWithFill:
	MOVE.B	(dat_FillChar,PC),-(A7)
	MOVE.B	#$20,dat_FillChar
	BSR.W	pt_DrawTextRender
	MOVE.B	(A7)+,dat_FillChar
	RTS
pt_SaveRegsAudioProc:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	(dat_0FC6,PC),A1
	LEA	SECSTRT_2,A4
	MOVEQ	#1,D7
	BSR.W	pt_InitHardwareBase
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_SaveAllRegsProc:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	(dat_0FC7,PC),A1
	LEA	SECSTRT_2,A4
	MOVEQ	#1,D7
	BSR.W	pt_InitHardwareBase
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BlitPatternFull:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	(dat_0FC6,PC),A1
	MOVEA.L	dat_ScreenBuf2Ptr,A4
	MOVEQ	#1,D2
	MOVEQ	#0,D7
	BSR.S	pt_InitHardwareBase
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_BlitPatternRow:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-456,A6)
	JSR	(-228,A6)
	LEA	SECSTRT_2,A4
	MOVEQ	#1,D7
	BSR.W	pt_0FC8
	MOVEA.L	(dat_GfxLibBase,PC),A6
	JSR	(-462,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_DrawBoxedText:
	MOVEM.L	D0-D7/A0-A1,-(A7)
	MOVEA.L	A0,A1
	MOVEQ	#-1,D3
pt_0FBB:
	ADDQ.L	#1,D3
	TST.B	(A0)+
	BNE.S	pt_0FBB
	MOVEA.L	A1,A0
	BSR.S	pt_BlitPatternRow
	MOVEA.L	D5,A0
	MOVEM.L	(A7)+,D0-D7/A0-A1
	RTS
pt_InitHardwareBase:
	LEA	HARDBASE,A6
	LEA	(dat_0FD4,PC),A5
	MOVE.W	D2,dat_0FC4
	MULU	#$0050,D1
	LEA	(0,A4,D1.L),A4
	MOVE.W	D3,D6
	SUBQ.W	#1,D6
	BMI.W	pt_0FC3
	MOVE.W	#$fffc,(98,A6)
	MOVE.W	#$005c,(100,A6)
	MOVE.W	#$004c,(96,A6)
	MOVE.W	#$004c,(102,A6)
	MOVE.L	#chip_AudioDMAEndMark,(76,A6)
pt_0FBD:
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	BNE.S	pt_0FBE
	MOVE.B	(dat_FillChar,PC),D2
pt_0FBE:
	MOVE.W	D0,D5
	ADDQ.W	#8,D0
	MOVEA.L	A4,A3
	MOVE.B	(0,A5,D2.W),D2
	CMP.W	#$00a0,D2
	BCS.S	pt_0FBF
	SUB.W	#$0020,D2
pt_0FBF:
	LEA	chip_FontNormal,A2
	LEA	(0,A2,D2.W),A2
	MOVE.L	#$ff000000,D4
	AND.W	#$0001,D2
	BEQ.S	pt_0FC0
	SUBQ.W	#8,D5
	LSR.L	#8,D4
pt_0FC0:
	MOVE.W	D5,D1
	AND.W	#$000f,D1
	ROR.W	#4,D1
	ASR.W	#3,D5
	LEA	(0,A3,D5.W),A3
	MOVE.B	(dat_0FC4,PC),D2
	MOVE.B	(dat_0FC5,PC),D3
pt_0FC1:
	BTST	#6,(2,A6)
	BNE.S	pt_0FC1
	MOVE.L	D4,chip_AudioDMAEndMark
	MOVE.L	D4,(68,A6)
	MOVE.W	D1,(66,A6)
	OR.W	#$0f00,D1
	MOVE.W	D7,D4
pt_0FC2:
	BTST	#6,(2,A6)
	BNE.S	pt_0FC2
	MOVEQ	#0,D5
	ROXR.B	#1,D2
	ROXL.B	#1,D5
	ROXR.B	#1,D3
	ROXL.B	#1,D5
	MOVE.B	(0,A1,D5.W),D1
	MOVE.W	D1,(64,A6)
	MOVE.L	A3,(72,A6)
	MOVE.L	A2,(80,A6)
	MOVE.L	A3,(84,A6)
	MOVE.W	#$0142,(88,A6)
	LEA	(20480,A3),A3
	DBF	D4,pt_0FC2
	DBF	D6,pt_0FBD
pt_0FC3:
	BTST	#6,(2,A6)
	BNE.S	pt_0FC3
	RTS
dat_0FC4:
	DS.B	1
dat_0FC5:
	DS.B	1
dat_0FC6:
	DC.L	$02c20ece
dat_0FC7:
	DC.L	$0aca0aca
pt_0FC8:
	LEA	HARDBASE,A6
	LEA	(dat_0FD4,PC),A5
	MOVE.W	D0,dat_0FD1
	MULU	#$0050,D1
	LEA	(0,A4,D1.L),A4
	MOVE.W	D3,D6
	SUBQ.W	#1,D6
	BMI.W	pt_CheckCIABit6
	MOVE.W	#$fffc,(98,A6)
	MOVE.W	#$005c,(100,A6)
	MOVE.W	#$004c,(96,A6)
	MOVE.W	#$004c,(102,A6)
	MOVE.L	#chip_AudioDMAEndMark,(76,A6)
pt_0FC9:
	MOVEQ	#0,D2
	MOVE.B	(A0)+,D2
	BNE.S	pt_0FCA
	MOVE.B	(dat_FillChar,PC),D2
pt_0FCA:
	CMP.W	#$000a,D2
	BNE.S	pt_0FCB
	MOVE.W	(dat_0FD1,PC),D0
	LEA	(560,A4),A4
	DBF	D6,pt_0FC9
	BRA.W	pt_CheckCIABit6
pt_0FCB:
	MOVE.W	D0,D5
	MOVEA.L	A4,A3
	CMP.W	#$00a0,D2
	BCS.S	pt_0FCC
	SUB.W	#$0020,D2
pt_0FCC:
	MOVE.B	(0,A5,D2.W),D2
	ADDQ.W	#7,D0
	LEA	chip_FontBold,A2
	LEA	(0,A2,D2.W),A2
	MOVE.L	#$fe000000,D4
	AND.W	#$0001,D2
	BEQ.S	pt_0FCD
	SUBQ.W	#8,D5
	LSR.L	#8,D4
pt_0FCD:
	MOVE.W	D5,D1
	AND.W	#$000f,D1
	ROR.W	#4,D1
	ASR.W	#3,D5
	LEA	(0,A3,D5.W),A3
pt_0FCE:
	BTST	#6,(2,A6)
	BNE.S	pt_0FCE
	MOVE.L	D4,chip_AudioDMAEndMark
	MOVE.L	D4,(68,A6)
	MOVE.W	D1,(66,A6)
	OR.W	#$0fc2,D1
	MOVE.W	D1,(64,A6)
	MOVE.W	D7,D4
pt_0FCF:
	BTST	#6,(2,A6)
	BNE.S	pt_0FCF
	MOVE.L	A3,(72,A6)
	MOVE.L	A2,(80,A6)
	MOVE.L	A3,(84,A6)
	MOVE.W	#$0182,(88,A6)
	LEA	(576,A2),A2
	LEA	(20480,A3),A3
	DBF	D4,pt_0FCF
	DBF	D6,pt_0FC9
pt_CheckCIABit6:
	BTST	#6,(2,A6)
	BNE.S	pt_CheckCIABit6
	RTS
dat_0FD1:
	DS.W	1
dat_FillChar:
	DC.W	$5f00
dat_FontMapSmall:
	DS.L	8
	DC.L	$00010203,$04050607,$08090a0b,$0c0d0e0f
	DC.L	$10111213,$14151617,$18191a1b,$1c1d1e1f
	DC.L	$20212223,$24252627,$28292a2b,$2c2d2e2f
	DC.L	$30313233,$34353637,$38393a3b,$3c3d3e3f
	DC.L	$45474849,$4a4b4c4d,$4e4f5051,$52535455
	DC.L	$56575859,$5a5b5c5d,$5e5f6041,$4243443f
	DC.L	$45000000
	DS.L	7
	DC.L	$00400000
	DS.L	12
	DC.L	$00006500
	DS.L	1
	DC.L	$67000064
	DS.L	1
	DC.L	$62000000
	DS.L	3
	DC.L	$00006100
	DS.L	1
	DC.L	$63000000
dat_0FD4:
	DS.L	8
	DC.L	$00010203,$04050607,$08090a0b,$0c0d0e0f
	DC.L	$10111213,$14151617,$18191a1b,$1c1d1e1f
	DC.L	$20212223,$24252627,$28292a2b,$2c2d2e2f
	DC.L	$30313233,$34353637,$38393a3b,$3c3d3e3f
	DC.L	$40212223,$24252627,$28292a2b,$2c2d2e2f
	DC.L	$30313233,$34353637,$38393a41,$4243443f
	DC.L	$45460000
	DS.L	7
	DC.L	$00400000
	DS.L	23
dat_FontMapLarge:
	DS.L	8
	DC.L	$00010203,$04050607,$08090a0b,$0c0d0e0f
	DC.L	$10111213,$14151617,$18191a1b,$1c1d1e1f
	DC.L	$20212223,$24252627,$28292a2b,$2c2d2e2f
	DC.L	$30313233,$34353637,$38393a3b,$3c3d3e3f
	DC.L	$45212223,$24252627,$28292a2b,$2c2d2e2f
	DC.L	$30313233,$34353637,$38393a41,$4243443f
	DC.L	$45460000
	DS.L	7
	DC.L	$00400000
	DS.L	23
pt_DrawSprite:
	ADD.W	(dat_0FDA,PC),D1
	ADD.W	D1,D2
	ROL.W	#7,D2
	ASL.W	#1,D2
	BCC.S	pt_0FD7
	OR.W	#$0002,D2
pt_0FD7:
	ROL.W	#7,D1
	ASL.W	#1,D1
	BCC.S	pt_0FD8
	OR.W	#$0004,D2
pt_0FD8:
	ADD.W	(dat_0FDB,PC),D0
	ASR.W	#1,D0
	BCC.S	pt_0FD9
	OR.W	#$0001,D2
pt_0FD9:
	OR.W	D0,D1
	MOVE.W	D1,(A0)
	MOVE.W	D2,(2,A0)
	RTS
dat_0FDA:
	DC.W	$002c
dat_0FDB:
	DC.W	$007d
pt_InitHwPalette:
	MOVE.L	#$0800f000,D4
	MOVE.L	#$78008800,D5
	MOVE.L	#$f8007800,D6
	BRA.S	pt_0FDE
