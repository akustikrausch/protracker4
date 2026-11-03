pt_WriteHashChar:
	MOVE.B	#$23,(A0)
pt_0B96:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	LEA	(dat_0BD9,PC),A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	(dat_0BB3,PC),A0
	LEA	(dat_0BCA,PC),A6
	MOVE.L	A0,(6,A6)
	MOVEQ	#0,D0
	MOVE.W	(10,A6),D0
	MOVE.W	(dat_SampleRepeatLen,PC),D7
	SUBQ.W	#2,D7
	BMI.S	pt_0B98
	LEA	(dat_0BA7,PC),A5
pt_0B97:
	MOVEA.L	(A5)+,A6
	BSR.S	pt_0B9A
	DBF	D7,pt_0B97
pt_0B98:
	MOVEA.L	(dat_PatternBufVar,PC),A5
	MOVE.L	(dat_PatBufEndPtr,PC),D7
	MOVEA.L	A0,A4
	ADDA.L	D7,A4
	SUBQ.L	#2,D7
	MOVE.L	A4,D6
	CMPI.W	#$0001,dat_SampleSlotVar
	BLE.S	pt_0B99
	MOVEQ	#0,D6
	MOVE.W	(dat_0BB6,PC),D6
	ADD.L	D6,D6
	ADD.L	A0,D6
	MOVEQ	#0,D0
	MOVE.W	(dat_SampleSlotVar,PC),D0
	ADD.L	D0,D0
	ADD.L	D6,D0
	MOVEA.L	D0,A4
pt_0B99:
	CLR.W	dat_SampleBufCount
	CLR.W	dat_SampleBufIdx
	MOVEQ	#0,D0
	MOVE.B	D0,(A5)+
	MOVE.B	D0,(A5)+
	BSR.S	pt_0B9B
	MOVE.W	(dat_SelectedSample,PC),dat_CurrentSample
	BSR.W	pt_ClearStatusMsg
	JSR	pt_RestorePalette
	BSR.W	pt_DrawSampleHex
	JMP	pt_RecordModeHandler
pt_0B9A:
	MOVE.L	D0,D1
	MOVE.W	(10,A6),D2
	DIVU	D2,D1
	MOVE.L	D1,(A6)
	LSR.W	#1,D2
	MOVE.W	D2,(4,A6)
	MOVE.L	A0,(6,A6)
	RTS
pt_0B9B:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.L	D0,-(A7)
	TST.W	D0
	BPL.S	pt_0B9C
	NEG.W	D0
pt_0B9C:
	CMP.W	dat_SampleBufCount,D0
	BMI.S	pt_0B9D
	MOVE.W	D0,dat_SampleBufCount
pt_0B9D:
	MOVE.L	(A7)+,D0
	LEA	(dat_0BA6,PC),A3
	MOVE.W	(dat_SampleRepeatLen,PC),D3
	SUBQ.W	#1,D3
pt_0B9E:
	MOVEA.L	(A3)+,A6
	BSR.S	pt_0BA3
	DBF	D3,pt_0B9E
	EXT.L	D0
	DIVS	(dat_SampleRepeatLen,PC),D0
	CMP.W	#$ff80,D0
	BPL.S	pt_0B9F
	MOVE.W	#$ff80,D0
pt_0B9F:
	CMP.W	#$007f,D0
	BMI.S	pt_0BA0
	MOVE.W	#$007f,D0
pt_0BA0:
	MOVE.B	D0,(A5)+
	EXT.W	D0
	TST.W	D0
	BPL.S	pt_0BA1
	NEG.W	D0
pt_0BA1:
	CMP.W	dat_SampleBufIdx,D0
	BMI.S	pt_0BA2
	MOVE.W	D0,dat_SampleBufIdx
pt_0BA2:
	SUBQ.L	#1,D7
	BNE.S	pt_0B9B
	TSTPC.W	dat_DisplayIndexVar
	BEQ.S	pt_0BA8
	RTS
pt_0BA3:
	MOVE.W	(2,A6),D4
	MOVE.W	(A6),D5
	SUB.W	D5,(4,A6)
	BCC.S	pt_0BA4
	MOVE.W	(10,A6),D5
	ADD.W	D5,(4,A6)
	ADDQ.W	#1,D4
pt_0BA4:
	MOVEA.L	(6,A6),A1
	ADDA.W	D4,A1
	CMPA.L	A4,A1
	BLT.S	pt_0BA5
	MOVEA.L	D6,A1
pt_0BA5:
	MOVE.L	A1,(6,A6)
	MOVE.B	(A1),D1
	EXT.W	D1
	ADD.W	D1,D0
	RTS
dat_0BA6:
	DC.L	dat_0BCA
dat_0BA7:
	DC.L	dat_0BCC
	DC.L	dat_0BCE
	DC.L	dat_0BD0
	DC.L	dat_0BD2
	DC.L	dat_0BD4
	DC.L	dat_0BD6
pt_0BA8:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	dat_SampleBufCount,D0
	MOVE.W	dat_SampleBufIdx,D1
	MULU	#$0064,D0
	TST.W	D1
	BNE.S	pt_0BA9
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_0BA9:
	DIVU	D1,D0
	MOVEA.L	dat_PatternBufVar,A1
	MOVE.L	dat_PatBufEndPtr,D3
	SUBQ.L	#1,D3
pt_0BAA:
	MOVE.B	(A1),D1
	EXT.W	D1
	MULS	D0,D1
	DIVS	#$0064,D1
	CMP.W	#$007f,D1
	BLE.S	pt_0BAB
	MOVEQ	#127,D1
pt_0BAB:
	CMP.W	#$ff80,D1
	BGE.S	pt_0BAC
	MOVEQ	#-128,D1
pt_0BAC:
	MOVE.B	D1,(A1)+
	DBF	D3,pt_0BAA
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_DosLibBase:
	DS.L	1
dat_IntuiLibBase:
	DS.L	1
dat_GfxLibBase:
	DS.L	1
dat_XpkLibBase:
	DS.L	1
dat_SampleBufCount:
	DS.W	1
dat_SampleBufIdx:
	DS.W	1
dat_0BB3:
	DS.L	1
dat_PatternBufVar:
	DS.L	1
dat_PatBufEndPtr:
	DS.L	1
dat_0BB6:
	DS.W	1
dat_SampleSlotVar:
	DS.W	1
dat_SampleSlotIdx:
	DC.W	$0001
dat_SelectedSample:
	DC.W	$0002
dat_SampleChunkSize:
	DC.W	$0003
dat_SampleRepeatLen:
	DS.W	1
dat_SampleRepeatOfs:
	DS.W	1
dat_0BBD:
	DS.W	1
dat_0BBE:
	DS.W	1
dat_0BBF:
	DS.W	1
dat_0BC0:
	DS.W	1
dat_0BC1:
	DS.W	1
dat_SampleEditSlot:
	DS.W	1
dat_0BC3:
	DS.W	1
dat_0BC4:
	DS.W	1
dat_0BC5:
	DS.W	1
dat_0BC6:
	DS.W	1
dat_0BC7:
	DS.W	1
dat_0BC8:
	DS.W	1
dat_0BC9:
	DS.W	1
dat_0BCA:
	DS.L	2
	DS.W	1
dat_0BCB:
	DS.W	1
dat_0BCC:
	DS.L	2
	DS.W	1
dat_0BCD:
	DS.W	1
dat_0BCE:
	DS.L	2
	DS.W	1
dat_0BCF:
	DS.W	1
dat_0BD0:
	DS.L	2
	DS.W	1
dat_0BD1:
	DS.W	1
dat_0BD2:
	DS.L	2
	DS.W	1
dat_0BD3:
	DS.W	1
dat_0BD4:
	DS.L	2
	DS.W	1
dat_0BD5:
	DS.W	1
dat_0BD6:
	DS.L	2
	DS.W	1
dat_0BD7:
	DS.W	1
dat_0BD8:
	DC.B	10,10
	DC.B	" Overwrite the sample?",0
dat_0BD9:
	DC.B	"PLEASE WAIT, COMPUTING...",0
	DC.B	"ADJUSTING RESULT...",0,0
pt_GetPatternAddr:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D2
	LSL.L	#8,D2
	LSL.L	#2,D2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0BDB
	LSL.L	#1,D2
pt_0BDB:
	ADDA.L	D2,A0
	MOVEQ	#0,D2
	MOVE.W	D0,D2
	DIVU	#$0006,D2
	LSL.W	#2,D2
	ADDA.W	D2,A0
pt_0BDC:
	RTS
pt_BtnPatTrack:
	ADDQ.W	#1,dat_PatEditScope
	CMPI.W	#$0004,dat_PatEditScope
	BMI.S	pt_ScreenMode7Check
	CLR.W	dat_PatEditScope
pt_ScreenMode7Check:
	CMPI.W	#$0007,dat_OptPage
	BNE.S	pt_0BDC
	CMPI.W	#$0001,dat_UIMode
	BNE.S	pt_0BDC
	MOVE.W	(dat_PatEditScope,PC),D0
	LSL.W	#2,D0
	MOVEA.L	(dat_0BDF,PC,D0.W),A0
	MOVEQ	#8,D3
	MOVE.W	#$0189,D0
	MOVE.W	#$003a,D1
	JMP	pt_BlitPatternRow
dat_0BDF:
	DC.L	dat_0BE0
	DC.L	dat_0BE1
	DC.L	dat_0BE2
	DC.L	dat_0BE3
dat_0BE0:
	DC.B	"Track   "
dat_0BE1:
	DC.B	"Pattern "
dat_0BE2:
	DC.B	"Commands"
dat_0BE3:
	DC.B	"Block   "
dat_PatEditScope:
	DS.W	1
pt_BtnOpt1SampleMode:
	JSR	pt_WaitMouseRelease
	MOVE.B	dat_PlaybackState,D0
	NOT.B	D0
	MOVE.B	D0,dat_PlaybackState
pt_0BE6:
	MOVEQ	#6,D3
	MOVE.W	#$0246,D0
	MOVEQ	#58,D1
	LEA	(dat_0BE9,PC),A0
	TST.B	dat_PlaybackState
	BNE.S	pt_0BE7
	LEA	(dat_0BE8,PC),A0
pt_0BE7:
	JMP	pt_BlitPatternRow
dat_0BE8:
	DC.B	"Single"
dat_0BE9:
	DC.B	"All   "
pt_BtnPatRotUp:
	ST	dat_TrackScrollRotate
	BRA.S	pt_0BEC
pt_BtnPatScrUp:
	SF	dat_TrackScrollRotate
pt_0BEC:
	SF	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	MOVE.W	dat_CursorColumn,D0
	BSR.W	pt_GetPatternAddr
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_0BEE
	CMPI.W	#$0002,dat_PatEditScope
	BEQ.S	pt_0BEF
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.W	pt_0BF0
	CMPI.W	#$0001,dat_PatEditScope
	BEQ.S	pt_0BED
	RTS
pt_0BED:
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollUp
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollUp
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollUp
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollUp
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0BEE
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollUp
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TrackScrollUp
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TrackScrollUp
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_0BEE:
	BSR.S	pt_TrackScrollUp
	JSR	pt_LoadDrawParams
	JSR	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_0BEF:
	MOVE.W	dat_CursorColumn,dat_EditCursorCol
	CLR.W	dat_EditCursorRow
	MOVE.W	#$003e,dat_DisplayFieldSize
	ST	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	BRA.S	pt_0BF1
pt_0BF0:
	JSR	pt_MenuDownCmd
	BEQ.S	pt_0BF1
	RTS
pt_0BF1:
	MOVE.W	(dat_EditCursorCol,PC),D0
	BSR.W	pt_GetPatternAddr
	MOVE.W	(dat_EditCursorRow,PC),D0
	LSL.W	#4,D0
	ADDA.W	D0,A0
	MOVE.W	(dat_DisplayFieldSize,PC),D0
	SUBQ.W	#1,D0
	BSR.S	pt_TrackScrollUpN
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_TrackScrollUp:
	MOVEQ	#63,D0
pt_TrackScrollUpN:
	SUBQ.L	#1,D0
	BMI.W	pt_0BFB
	MOVE.W	(A0),D1
	MOVE.W	(2,A0),D2
	TST.B	dat_TrackScrollRotate
	BNE.S	pt_0BF4
	MOVEQ	#0,D1
	MOVEQ	#0,D2
pt_0BF4:
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0BF6
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0BF5
	MOVE.W	(32,A0),(A0)
	MOVE.W	(34,A0),D3
	AND.W	#$f000,D3
	ANDI.W	#$0fff,(2,A0)
	OR.W	D3,(2,A0)
	BRA.S	pt_0BF6
pt_0BF5:
	MOVE.W	(16,A0),(A0)
	MOVE.W	(18,A0),D3
	AND.W	#$f000,D3
	ANDI.W	#$0fff,(2,A0)
	OR.W	D3,(2,A0)
pt_0BF6:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0BF8
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0BF7
	MOVE.W	(34,A0),D3
	AND.W	#$0fff,D3
	ANDI.W	#$f000,(2,A0)
	OR.W	D3,(2,A0)
	BRA.S	pt_0BF8
pt_0BF7:
	MOVE.W	(18,A0),D3
	AND.W	#$0fff,D3
	ANDI.W	#$f000,(2,A0)
	OR.W	D3,(2,A0)
pt_0BF8:
	LEA	(16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0BF9
	LEA	(16,A0),A0
pt_0BF9:
	DBF	D0,pt_0BF4
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0BFA
	MOVE.W	D1,(A0)
	ANDI.W	#$0fff,(2,A0)
	MOVE.W	D2,D3
	AND.W	#$f000,D3
	OR.W	D3,(2,A0)
pt_0BFA:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0BFB
	MOVE.W	D2,D3
	AND.W	#$0fff,D3
	ANDI.W	#$f000,(2,A0)
	OR.W	D2,(2,A0)
pt_0BFB:
	RTS
pt_BtnPatRotDown:
	ST	dat_TrackScrollRotate
	BRA.S	pt_0BFE
pt_BtnPatScrDown:
	SF	dat_TrackScrollRotate
pt_0BFE:
	SF	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	MOVE.W	dat_CursorColumn,D0
	BSR.W	pt_GetPatternAddr
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_0C00
	CMPI.W	#$0002,dat_PatEditScope
	BEQ.S	pt_0C01
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.W	pt_0C02
	CMPI.W	#$0001,dat_PatEditScope
	BEQ.S	pt_0BFF
	RTS
pt_0BFF:
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollDown
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollDown
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollDown
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollDown
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C00
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_TrackScrollDown
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TrackScrollDown
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TrackScrollDown
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_0C00:
	BSR.S	pt_TrackScrollDown
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_0C01:
	MOVE.W	dat_CursorColumn,dat_EditCursorCol
	CLR.W	dat_EditCursorRow
	MOVE.W	#$0040,dat_DisplayFieldSize
	ST	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	BRA.S	pt_0C03
pt_0C02:
	JSR	pt_MenuDownCmd
	BEQ.S	pt_0C03
	RTS
pt_0C03:
	MOVE.W	(dat_EditCursorCol,PC),D0
	BSR.W	pt_GetPatternAddr
	MOVE.W	(dat_EditCursorRow,PC),D0
	LSL.W	#4,D0
	ADDA.W	D0,A0
	MOVE.W	(dat_DisplayFieldSize,PC),D0
	SUBQ.W	#1,D0
	BSR.S	pt_TrackScrollDownN
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_TrackScrollDown:
	MOVEQ	#63,D0
pt_TrackScrollDownN:
	SUBQ.L	#1,D0
	BMI.W	pt_0C11
	MOVE.L	D0,D3
	LSL.L	#4,D3
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C06
	LSL.L	#1,D3
pt_0C06:
	ADDA.L	D3,A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C07
	MOVE.W	(32,A0),D1
	MOVE.W	(34,A0),D2
pt_0C07:
	MOVE.W	(16,A0),D1
	MOVE.W	(18,A0),D2
	TST.B	dat_TrackScrollRotate
	BNE.S	pt_0C08
	MOVEQ	#0,D1
	MOVEQ	#0,D2
pt_0C08:
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0C0A
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C09
	MOVE.W	(A0),(32,A0)
	MOVE.W	(2,A0),D3
	AND.W	#$f000,D3
	ANDI.W	#$0fff,(34,A0)
	OR.W	D3,(34,A0)
	BRA.S	pt_0C0A
pt_0C09:
	MOVE.W	(A0),(16,A0)
	MOVE.W	(2,A0),D3
	AND.W	#$f000,D3
	ANDI.W	#$0fff,(18,A0)
	OR.W	D3,(18,A0)
pt_0C0A:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0C0C
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C0B
	MOVE.W	(2,A0),D3
	AND.W	#$0fff,D3
	ANDI.W	#$f000,(34,A0)
	OR.W	D3,(34,A0)
	BRA.S	pt_0C0C
pt_0C0B:
	MOVE.W	(2,A0),D3
	AND.W	#$0fff,D3
	ANDI.W	#$f000,(18,A0)
	OR.W	D3,(18,A0)
pt_0C0C:
	LEA	(-16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C0D
	LEA	(-16,A0),A0
pt_0C0D:
	DBF	D0,pt_0C08
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0C0F
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C0E
	MOVE.W	D1,(32,A0)
	ANDI.W	#$0fff,(34,A0)
	MOVE.W	D2,D3
	AND.W	#$f000,D3
	OR.W	D3,(34,A0)
	BRA.S	pt_0C0F
pt_0C0E:
	MOVE.W	D1,(16,A0)
	ANDI.W	#$0fff,(18,A0)
	MOVE.W	D2,D3
	AND.W	#$f000,D3
	OR.W	D3,(18,A0)
pt_0C0F:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0C11
	MOVE.W	D2,D3
	AND.W	#$0fff,D3
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C10
	ANDI.W	#$f000,(34,A0)
	OR.W	D2,(34,A0)
	RTS
pt_0C10:
	ANDI.W	#$f000,(18,A0)
	OR.W	D2,(18,A0)
pt_0C11:
	RTS
pt_BtnPatFlip:
	SF	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	MOVE.W	dat_CursorColumn,D0
	BSR.W	pt_GetPatternAddr
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_0C14
	CMPI.W	#$0002,dat_PatEditScope
	BEQ.S	pt_0C15
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.W	pt_0C16
	CMPI.W	#$0001,dat_PatEditScope
	BEQ.S	pt_0C13
	RTS
pt_0C13:
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame1
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame1
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame1
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C14
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame1
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_AnimPatternFrame1
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_AnimPatternFrame1
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_0C14:
	BSR.S	pt_AnimPatternFrame1
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_0C15:
	MOVE.W	dat_CursorColumn,dat_EditCursorCol
	CLR.W	dat_EditCursorRow
	MOVE.W	#$0040,dat_DisplayFieldSize
	ST	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	BRA.S	pt_0C17
pt_0C16:
	JSR	pt_MenuDownCmd
	BEQ.S	pt_0C17
	RTS
pt_0C17:
	MOVE.W	(dat_EditCursorCol,PC),D0
	BSR.W	pt_GetPatternAddr
	MOVE.W	(dat_EditCursorRow,PC),D0
	LSL.W	#4,D0
	ADDA.W	D0,A0
	MOVE.W	(dat_DisplayFieldSize,PC),D0
	SUBQ.W	#1,D0
	BSR.S	pt_0C19
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_AnimPatternFrame1:
	MOVEQ	#63,D0
pt_0C19:
	LEA	dat_14F4,A1
	MOVEA.L	A0,A2
	MOVEA.L	A1,A3
	MOVE.L	D0,D1
pt_0C1A:
	MOVE.L	(A2),(A3)+
	LEA	(16,A2),A2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C1B
	LEA	(16,A2),A2
pt_0C1B:
	DBF	D1,pt_0C1A
	MOVE.L	D0,D1
	LSL.L	#2,D1
	ADDA.L	D1,A1
pt_0C1C:
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0C1D
	MOVE.W	(A1),(A0)
	MOVE.W	(2,A1),D3
	AND.W	#$f000,D3
	ANDI.W	#$0fff,(2,A0)
	OR.W	D3,(2,A0)
pt_0C1D:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0C1E
	MOVE.W	(2,A1),D3
	AND.W	#$0fff,D3
	ANDI.W	#$f000,(2,A0)
	OR.W	D3,(2,A0)
pt_0C1E:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C1F
	LEA	(16,A0),A0
pt_0C1F:
	LEA	(16,A0),A0
	LEA	(-4,A1),A1
	DBF	D0,pt_0C1C
	RTS
pt_BtnPatClear:
	SF	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	MOVE.W	dat_CursorColumn,D0
	BSR.W	pt_GetPatternAddr
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_0C22
	CMPI.W	#$0002,dat_PatEditScope
	BEQ.S	pt_0C23
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.W	pt_0C24
	CMPI.W	#$0001,dat_PatEditScope
	BEQ.S	pt_0C21
	RTS
pt_0C21:
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame2
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame2
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame2
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C22
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.W	pt_AnimPatternFrame2
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_AnimPatternFrame2
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_AnimPatternFrame2
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_0C22:
	BSR.S	pt_AnimPatternFrame2
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JMP	pt_LoadDrawParams
pt_0C23:
	MOVE.W	dat_CursorColumn,dat_EditCursorCol
	CLR.W	dat_EditCursorRow
	MOVE.W	#$0040,dat_DisplayFieldSize
	ST	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	BRA.S	pt_0C25
pt_0C24:
	JSR	pt_MenuDownCmd
	BEQ.S	pt_0C25
	RTS
pt_0C25:
	MOVE.W	(dat_EditCursorCol,PC),D0
	BSR.W	pt_GetPatternAddr
	MOVE.W	(dat_EditCursorRow,PC),D0
	LSL.W	#4,D0
	ADDA.W	D0,A0
	MOVE.W	(dat_DisplayFieldSize,PC),D0
	SUBQ.W	#1,D0
	BSR.S	pt_0C27
	BRA.W	pt_PatViewDrawAll
pt_AnimPatternFrame2:
	MOVEQ	#63,D0
pt_0C27:
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0C28
	CLR.W	(A0)
	ANDI.W	#$0fff,(2,A0)
pt_0C28:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0C29
	ANDI.W	#$f000,(2,A0)
pt_0C29:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C2A
	LEA	(16,A0),A0
pt_0C2A:
	LEA	(16,A0),A0
	DBF	D0,pt_0C27
	RTS
pt_BtnPatCut:
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.S	pt_0C2C
	RTS
pt_0C2C:
	BSR.S	pt_BtnPatCopy
	BSR.W	pt_BtnPatClear
	RTS
pt_BtnPatCopy:
	SF	dat_TrackScrollKeepNote
	SF	dat_TrackScrollKeepFx
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.S	pt_0C2E
	RTS
pt_0C2E:
	JSR	pt_MenuDownCmd
	BEQ.S	pt_0C2F
	RTS
pt_0C2F:
	MOVE.W	(dat_EditCursorCol,PC),D0
	BSR.W	pt_GetPatternAddr
	MOVE.W	(dat_EditCursorRow,PC),D0
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C30
	LSL.W	#1,D0
pt_0C30:
	ADDA.W	D0,A0
	MOVE.W	(dat_DisplayFieldSize,PC),D0
	SUBQ.W	#1,D0
	BSR.S	pt_0C31
	ST	dat_0C48
	MOVE.B	(dat_TrackScrollKeepNote,PC),dat_0C49
	MOVE.B	(dat_TrackScrollKeepFx,PC),dat_0C4A
	MOVE.W	(dat_DisplayFieldSize,PC),dat_0C44
	RTS
pt_0C31:
	LEA	dat_14F1,A1
pt_0C32:
	TST.B	dat_TrackScrollKeepNote
	BNE.S	pt_0C33
	MOVE.W	(A0),(A1)
	MOVE.W	(2,A0),D1
	AND.W	#$f000,D1
	MOVE.W	D1,(2,A1)
pt_0C33:
	TST.B	dat_TrackScrollKeepFx
	BNE.S	pt_0C34
	MOVE.W	(2,A0),D1
	AND.W	#$0fff,D1
	ANDI.W	#$f000,(2,A1)
	OR.W	D1,(2,A1)
pt_0C34:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C35
	LEA	(16,A0),A0
pt_0C35:
	LEA	(16,A0),A0
	LEA	(4,A1),A1
	DBF	D0,pt_0C32
	RTS
pt_BtnPatPaste:
	CMPI.W	#$0003,dat_PatEditScope
	BEQ.S	pt_0C37
	RTS
pt_0C37:
	TST.B	dat_0C48
	BNE.S	pt_0C38
	RTS
pt_0C38:
	MOVE.W	dat_CursorColumn,D0
	BSR.W	pt_GetPatternAddr
	MOVE.W	dat_PatternPosition,D0
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C39
	LSL.W	#1,D0
pt_0C39:
	ADDA.W	D0,A0
	MOVE.W	(dat_0C44,PC),D0
	MOVE.W	D0,D1
	ADD.W	dat_PatternPosition,D1
	CMP.W	#$0040,D1
	BMI.S	pt_0C3A
	SUB.W	#$0040,D1
	SUB.W	D1,D0
pt_0C3A:
	SUBQ.W	#1,D0
	BMI.S	pt_0C3B
	BSR.S	pt_0C3C
	JSR	pt_LoadDrawParams
	BSR.W	pt_PreKeyCheck
	JSR	pt_LoadDrawParams
pt_0C3B:
	RTS
pt_0C3C:
	LEA	dat_14F1,A1
pt_0C3D:
	TST.B	dat_0C49
	BNE.S	pt_0C3E
	MOVE.W	(A1),(A0)
	MOVE.W	(2,A1),D1
	AND.W	#$f000,D1
	MOVE.W	D1,(2,A0)
pt_0C3E:
	TST.B	dat_0C4A
	BNE.S	pt_0C3F
	MOVE.W	(2,A1),D1
	AND.W	#$0fff,D1
	ANDI.W	#$f000,(2,A0)
	OR.W	D1,(2,A0)
pt_0C3F:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C40
	LEA	(16,A0),A0
pt_0C40:
	LEA	(16,A0),A0
	LEA	(4,A1),A1
	DBF	D0,pt_0C3D
	RTS
dat_EditCursorCol:
	DS.W	1
dat_EditCursorRow:
	DS.W	1
dat_DisplayFieldSize:
	DS.W	1
dat_0C44:
	DS.W	1
dat_TrackScrollRotate:
	DS.B	1
dat_TrackScrollKeepNote:
	DS.B	1
dat_TrackScrollKeepFx:
	DS.B	1
dat_0C48:
	DS.B	1
dat_0C49:
	DS.B	1
dat_0C4A:
	DS.B	1
	DS.W	1
pt_BtnPatOctUp:
	CMPI.W	#$0001,dat_PatEditScope
	BLS.S	pt_0C4C
	RTS
pt_0C4C:
	MOVEQ	#0,D0
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_TransposeOctUp2
	MOVE.W	#$012c,D0
pt_TransposeOctUp2:
	MOVE.W	#$0018,dat_TransposeStep
	BRA.S	pt_TransposeUp
pt_BtnPatNoteUp:
	CMPI.W	#$0001,dat_PatEditScope
	BLS.S	pt_0C4F
	RTS
pt_0C4F:
	MOVEQ	#0,D0
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_TransposeNoteUp2
	MOVE.W	#$012c,D0
pt_TransposeNoteUp2:
	MOVE.W	#$0002,dat_TransposeStep
pt_TransposeUp:
	JSR	pt_ConvertKeyToNote
	CMP.W	#$00d6,D0
	BLS.S	pt_TransposeUpLast
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	BTST	#5,dat_ModeFlags
	BNE.S	pt_TransposeUpLast
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeUpTrack
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_TransposeUpLast:
	BSR.S	pt_TransposeUpTrack
	BRA.W	pt_PatViewDrawAll
pt_TransposeUpTrack:
	MOVEQ	#63,D6
	MOVEA.L	A0,A3
	MOVE.W	dat_CurrentSample,D3
	TST.B	dat_PlaybackState
	BEQ.S	pt_0C54
	MOVEQ	#0,D3
pt_0C54:
	MOVE.L	D6,D0
	MOVEA.L	A3,A0
pt_0C55:
	TST.B	dat_PlaybackState
	BNE.S	pt_0C56
	MOVE.B	(2,A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$f0,D2
	OR.B	D2,D1
	CMP.B	D3,D1
	BNE.S	pt_TransposeUpNextRow
pt_0C56:
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	AND.W	#$f000,D2
	AND.W	#$0fff,D1
	BEQ.S	pt_TransposeUpNextRow
	BSR.W	pt_FindPeriodIndex
	BNE.S	pt_TransposeUpNextRow
	ADD.W	(dat_TransposeStep,PC),D5
	CMP.W	#$0048,D5
	BCS.S	pt_0C57
	BTST	#1,dat_InputReadyFlag
	BEQ.S	pt_TransposeUpNextRow
	ANDI.L	#$00000fff,(A0)
	BRA.S	pt_TransposeUpNextRow
pt_0C57:
	MOVE.W	(0,A2,D5.W),D1
	OR.W	D2,D1
	MOVE.W	D1,(A0)
pt_TransposeUpNextRow:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C59
	LEA	(32,A0),A0
	DBF	D0,pt_0C55
	RTS
pt_0C59:
	LEA	(16,A0),A0
	DBF	D0,pt_0C55
	RTS
pt_BtnPatOctDown:
	CMPI.W	#$0001,dat_PatEditScope
	BLS.S	pt_0C5B
	RTS
pt_0C5B:
	MOVEQ	#0,D0
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_TransposeOctDown2
	MOVE.W	#$012c,D0
pt_TransposeOctDown2:
	MOVE.W	#$0018,dat_TransposeStep
	BRA.S	pt_TransposeDown
pt_BtnPatNoteDown:
	CMPI.W	#$0001,dat_PatEditScope
	BLS.S	pt_0C5E
	RTS
pt_0C5E:
	MOVEQ	#0,D0
	TSTPC.W	dat_PatEditScope
	BEQ.S	pt_TransposeNoteDown2
	MOVE.W	#$012c,D0
pt_TransposeNoteDown2:
	MOVE.W	#$0002,dat_TransposeStep
pt_TransposeDown:
	JSR	pt_ConvertKeyToNote
	CMP.W	#$00d6,D0
	BLS.S	pt_TransposeDownLast
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	BTST	#5,dat_ModeFlags
	BNE.S	pt_TransposeDownLast
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_TransposeDownTrack
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_TransposeDownLast:
	BSR.S	pt_TransposeDownTrack
	BRA.W	pt_PatViewDrawAll
pt_TransposeDownTrack:
	MOVEQ	#63,D6
	MOVEA.L	A0,A3
	MOVE.W	dat_CurrentSample,D3
	TST.B	dat_PlaybackState
	BEQ.S	pt_0C63
	MOVEQ	#0,D3
pt_0C63:
	MOVE.W	D6,D0
	MOVEA.L	A3,A0
pt_0C64:
	TST.B	dat_PlaybackState
	BNE.S	pt_0C65
	MOVE.B	(2,A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$f0,D2
	OR.B	D2,D1
	CMP.B	D1,D3
	BNE.S	pt_TransposeDownNextRow
pt_0C65:
	MOVE.W	(A0),D1
	MOVE.W	D1,D2
	AND.W	#$f000,D2
	AND.W	#$0fff,D1
	BEQ.S	pt_TransposeDownNextRow
	BSR.S	pt_FindPeriodIndex
	BNE.S	pt_TransposeDownNextRow
	SUB.W	(dat_TransposeStep,PC),D5
	BPL.S	pt_0C66
	BTST	#1,dat_InputReadyFlag
	BEQ.S	pt_TransposeDownNextRow
	ANDI.L	#$00000fff,(A0)
	BRA.S	pt_TransposeDownNextRow
pt_0C66:
	MOVE.W	(0,A2,D5.W),D1
	OR.W	D2,D1
	MOVE.W	D1,(A0)
pt_TransposeDownNextRow:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C68
	LEA	(32,A0),A0
	DBF	D0,pt_0C64
	RTS
pt_0C68:
	LEA	(16,A0),A0
	DBF	D0,pt_0C64
	RTS
pt_FindPeriodIndex:
	LEA	dat_PeriodTable,A2
	MOVEQ	#-2,D5
pt_0C6A:
	ADDQ.L	#2,D5
	MOVE.W	(0,A2,D5.W),D4
	BEQ.S	pt_0C6C
	CMP.W	D4,D1
	BEQ.S	pt_0C6B
	BRA.S	pt_0C6A
pt_0C6B:
	MOVEQ	#0,D4
	RTS
pt_0C6C:
	MOVEQ	#-1,D4
	RTS
dat_TransposeStep:
	DS.W	1
pt_BtnOpt2Track:
	JSR	pt_WaitMouseRelease
	ADDQ.B	#1,dat_PalCyclePhase
	CMPI.B	#$03,dat_PalCyclePhase
	BCS.S	pt_0C6F
	CLR.B	dat_PalCyclePhase
pt_0C6F:
	MOVE.W	#$016c,D0
	MOVEQ	#58,D1
	MOVEQ	#7,D3
	TST.B	dat_PalCyclePhase
	BNE.S	pt_0C70
	LEA	(dat_0C72,PC),A0
	JMP	pt_BlitPatternRow
pt_0C70:
	CMPI.B	#$01,dat_PalCyclePhase
	BNE.S	pt_0C71
	LEA	(dat_0C73,PC),A0
	JMP	pt_BlitPatternRow
pt_0C71:
	LEA	(dat_0C74,PC),A0
	JMP	pt_BlitPatternRow
dat_0C72:
	DC.B	" Track ",0
dat_0C73:
	DC.B	"Pattern",0
dat_0C74:
	DC.B	" Sample",0
pt_0C75:
	JSR	pt_ConvertKeyToNote
	MOVE.W	dat_CursorColumn,D0
	BSR.W	pt_GetPatternAddr
	BRA.S	pt_ExtractAndRedraw
pt_BtnOpt2Delete:
	JSR	pt_ConvertKeyToNote
	TST.B	dat_PalCyclePhase
	BEQ.S	pt_ExtractAndRedraw
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	BTST	#5,dat_ModeFlags
	BNE.S	pt_ExtractAndRedraw
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ExtractPatternNibbles
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_ExtractAndRedraw:
	BSR.S	pt_ExtractPatternNibbles
	BRA.W	pt_PatViewDrawAll
pt_ExtractPatternNibbles:
	MOVEQ	#63,D0
	MOVE.W	dat_CurrentSample,D3
	BEQ.W	pt_SelectDiskMsg
pt_0C79:
	MOVE.B	(2,A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$f0,D2
	OR.B	D2,D1
	CMP.B	D1,D3
	BNE.S	pt_0C7A
	CLR.L	(A0)
pt_0C7A:
	LEA	(16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C7B
	LEA	(16,A0),A0
pt_0C7B:
	DBF	D0,pt_0C79
	RTS
pt_ConfirmYesNoDialog:
	LEA	dat_12EC,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_SavePalAndSample
	RTS
pt_SavePalAndSample:
	JSR	pt_SavePaletteState
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_0C7E
	JMP	pt_RestorePaletteInit
pt_0C7E:
	BSR.W	pt_StopAllAudio
	BSR.W	pt_GetSamplePtrEntry
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0),A0
	ADDA.L	D0,A0
	MOVEA.L	A0,A1
	MOVEQ	#29,D0
pt_0C7F:
	CLR.B	(A0)+
	DBF	D0,pt_0C7F
	MOVE.W	#$0001,(s_replen,A1)
	BSR.W	pt_DrawSampleHex
	JSR	pt_RecordModeHandler
	JMP	pt_RestorePalette
pt_BtnOpt2Exchange:
	CMPI.B	#$02,dat_PalCyclePhase
	BEQ.W	pt_0C89
	MOVEQ	#0,D4
	BRA.S	pt_0C82
pt_BtnOpt2Copy:
	CMPI.B	#$02,dat_PalCyclePhase
	BEQ.W	pt_0C8D
pt_0C82:
	TST.B	dat_PalCyclePhase
	BEQ.S	pt_0C83
	MOVEQ	#0,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	MOVEQ	#6,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	MOVEQ	#12,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	MOVEQ	#18,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C83
	MOVEQ	#24,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	MOVEQ	#30,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	MOVEQ	#36,D0
	BSR.W	pt_GetPatternAddr
	BSR.S	pt_ComparePatternSelect
	MOVEQ	#42,D0
	BSR.W	pt_GetPatternAddr
pt_0C83:
	BSR.S	pt_ComparePatternSelect
	BRA.W	pt_PatViewDrawAll
pt_ComparePatternSelect:
	MOVEQ	#63,D0
pt_0C85:
	MOVE.B	(2,A0),D1
	LSR.B	#4,D1
	MOVE.B	(A0),D2
	AND.B	#$f0,D2
	OR.B	D2,D1
	CMP.B	(dat_UISelectIdx,PC),D1
	BNE.S	pt_0C86
	ANDI.L	#$0fff0fff,(A0)
	MOVE.B	(dat_UISelectMax,PC),D2
	MOVE.B	D2,D3
	AND.B	#$f0,D2
	OR.B	D2,(A0)
	LSL.B	#4,D3
	OR.B	D3,(2,A0)
	BRA.S	pt_AdvanceSamplePtr
pt_0C86:
	TST.B	D4
	BNE.S	pt_AdvanceSamplePtr
	CMP.B	(dat_UISelectMax,PC),D1
	BNE.S	pt_AdvanceSamplePtr
	ANDI.L	#$0fff0fff,(A0)
	MOVE.B	(dat_UISelectIdx,PC),D2
	MOVE.B	D2,D3
	AND.B	#$f0,D2
	OR.B	D2,(A0)
	LSL.B	#4,D3
	OR.B	D3,(2,A0)
pt_AdvanceSamplePtr:
	LEA	(16,A0),A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0C88
	LEA	(16,A0),A0
pt_0C88:
	DBF	D0,pt_0C85
	RTS
pt_0C89:
	JSR	pt_SavePaletteState
	MOVEQ	#0,D0
	MOVE.B	(dat_UISelectIdx,PC),D0
	BNE.S	pt_0C8A
	JMP	pt_RestorePaletteInit
pt_0C8A:
	MOVEQ	#0,D1
	MOVE.B	(dat_UISelectMax,PC),D1
	BNE.S	pt_0C8B
	JMP	pt_RestorePaletteInit
pt_0C8B:
	MOVE.W	D0,D2
	MOVE.W	D1,D3
	LEA	(dat_0983,PC),A2
	LSL.W	#1,D2
	LSL.W	#1,D3
	LEA	(0,A2,D2.W),A0
	LEA	(0,A2,D3.W),A1
	MOVE.W	(A0),D4
	MOVE.W	(A1),(A0)
	MOVE.W	D4,(A1)
	LEA	dat_ModulePtr,A2
	LSL.W	#1,D2
	LSL.W	#1,D3
	LEA	(0,A2,D2.W),A0
	LEA	(0,A2,D3.W),A1
	MOVE.L	(A0),D4
	MOVE.L	(A1),(A0)
	MOVE.L	D4,(A1)
	MOVE.L	(124,A0),D4
	MOVE.L	(124,A1),(124,A0)
	MOVE.L	D4,(124,A1)
	SUBQ.W	#1,D0
	SUBQ.W	#1,D1
	MULU	#s_SIZEOF,D0
	MULU	#s_SIZEOF,D1
	MOVEA.L	dat_ModulePtr,A2
	LEA	(20,A2),A2
	LEA	(0,A2,D0.W),A0
	LEA	(0,A2,D1.W),A1
	MOVEQ	#29,D0
pt_0C8C:
	MOVE.B	(A0),D1
	MOVE.B	(A1),(A0)+
	MOVE.B	D1,(A1)+
	DBF	D0,pt_0C8C
	BSR.W	pt_DrawSampleHex
	JSR	pt_RecordModeHandler
	JMP	pt_RestorePalette
pt_0C8D:
	JSR	pt_SavePaletteState
	MOVEQ	#0,D0
	MOVE.B	(dat_UISelectIdx,PC),D0
	BNE.S	pt_0C8E
	JMP	pt_RestorePaletteInit
pt_0C8E:
	MOVEQ	#0,D1
	MOVE.B	(dat_UISelectMax,PC),D1
	BNE.S	pt_0C8F
	JMP	pt_RestorePaletteInit
pt_0C8F:
	LEA	dat_ModulePtr,A2
	LSL.W	#2,D0
	LSL.W	#2,D1
	LEA	(0,A2,D0.W),A3
	LEA	(0,A2,D1.W),A4
	MOVE.L	(A3),D0
	BNE.S	pt_0C90
	JMP	pt_RestorePaletteInit
pt_0C90:
	MOVE.L	(124,A3),D0
	MOVE.L	dat_DiskOpViewMode,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	TST.L	D0
	BEQ.W	pt_SetupPaletteMode
	MOVEA.L	D0,A5
	MOVEQ	#0,D0
	MOVE.B	(dat_UISelectMax,PC),D0
	MOVE.W	D0,dat_CurrentSample
	BSR.W	pt_SavePalAndSample
	MOVE.L	A5,(A4)
	MOVE.L	(124,A3),D0
	MOVE.L	D0,(124,A4)
	MOVEA.L	(A3),A0
pt_0C91:
	MOVE.B	(A0)+,(A5)+
	SUBQ.L	#1,D0
	BNE.S	pt_0C91
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	(dat_UISelectIdx,PC),D0
	MOVE.B	(dat_UISelectMax,PC),D1
	MOVE.W	D1,dat_CurrentSample
	MULU	#s_SIZEOF,D0
	MULU	#s_SIZEOF,D1
	MOVEA.L	dat_ModulePtr,A2
	LEA	(-10,A2),A2
	LEA	(0,A2,D0.W),A0
	LEA	(0,A2,D1.W),A1
	MOVEQ	#29,D0
pt_0C92:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0C92
	BSR.W	pt_DrawSampleHex
	JSR	pt_RecordModeHandler
	JMP	pt_RestorePalette
