pt_DeletePatternRow:
	MOVE.W	dat_PatternPosition,D0
	BNE.S	pt_0465
	RTS
pt_0465:
	SUBQ.W	#1,D0
	LSL.W	#4,D0
pt_0466:
	MOVE.L	(16,A0,D0.W),(0,A0,D0.W)
	ADD.W	#$0010,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0467
	ADD.W	#$0010,D0
	CMP.W	#$0800,D0
	BCS.S	pt_0466
	MOVE.W	#$07e0,D1
	MOVEQ	#-1,D2
	CLR.L	(0,A0,D1.W)
	RTS
pt_0467:
	CMP.W	#$0400,D0
	BCS.S	pt_0466
	MOVE.W	#$03f0,D1
	MOVEQ	#-1,D2
	CLR.L	(0,A0,D1.W)
	RTS
pt_0468:
	CLR.B	dat_KeyCode
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	BSR.S	pt_0469
	BRA.W	pt_PatternInputProcess
pt_0469:
	MOVE.W	dat_PatternPosition,D0
	BNE.S	pt_046A
	RTS
pt_046A:
	SUBQ.W	#1,D0
	LSL.W	#4,D0
pt_046B:
	MOVE.W	(18,A0,D0.W),D2
	AND.W	#$0fff,D2
	ANDI.W	#$f000,(2,A0,D0.W)
	OR.W	D2,(2,A0,D0.W)
	ADD.W	#$0010,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_046C
	ADD.W	#$0010,D0
	CMP.W	#$0800,D0
	BCS.S	pt_046B
	MOVE.W	#$07e0,D1
	MOVEQ	#-1,D2
	ANDI.W	#$f000,(2,A0,D1.W)
	RTS
pt_046C:
	CMP.W	#$0400,D0
	BCS.S	pt_046B
	MOVE.W	#$03f0,D1
	MOVEQ	#-1,D2
	ANDI.W	#$f000,(2,A0,D1.W)
	RTS
pt_046D:
	BSR.W	pt_ConvertKeyToNote
	LEA	dat_DisplayBufPool2,A1
	MOVEQ	#0,D0
pt_046E:
	MOVE.L	(0,A0,D0.W),(A1)+
	ANDI.L	#$fffff000,(0,A0,D0.W)
	ADD.W	#$0010,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_046F
	ADD.W	#$0010,D0
	CMP.W	#$0800,D0
	BNE.S	pt_046E
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_046F:
	CMP.W	#$0400,D0
	BNE.S	pt_046E
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_0470:
	LEA	dat_DisplayBufPool2,A1
	CLR.W	D0
pt_0471:
	MOVE.L	(0,A0,D0.W),(A1)+
	ADD.W	#$0010,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0472
	ADD.W	#$0010,D0
	CMP.W	#$0800,D0
	BNE.S	pt_0471
	CLR.B	dat_KeyCode
	RTS
pt_0472:
	CMP.W	#$0400,D0
	BNE.S	pt_0471
	CLR.B	dat_KeyCode
	RTS
pt_0473:
	BSR.W	pt_ConvertKeyToNote
	LEA	dat_DisplayBufPool2,A1
	MOVEQ	#0,D0
pt_0474:
	MOVE.L	(0,A0,D0.W),D1
	AND.L	#$fffff000,D1
	MOVE.L	(A1)+,D2
	AND.L	#$00000fff,D2
	OR.L	D2,D1
	MOVE.L	D1,(0,A0,D0.W)
	ADD.W	#$0010,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0475
	ADD.W	#$0010,D0
	CMP.W	#$0800,D0
	BNE.S	pt_0474
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_0475:
	CMP.W	#$0400,D0
	BNE.S	pt_0474
	CLR.B	dat_KeyCode
	JMP	pt_PatViewDrawAll
pt_r073ec:
	CLR.B	dat_KeyCode
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	LEA	dat_0476,A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_r07410
	LEA	dat_0477,A0
pt_r07410:
	JSR	pt_ShowStatusMsg
pt_r07416:
	BSR.W	pt_UpdateDisplayInput
	TST.B	D1
	BEQ.W	pt_r074b4
	BTST	#5,dat_ModeFlags
	BNE.S	pt_r07432
	CMP.B	#$08,D1
	BHI.S	pt_r07416
	BRA.S	pt_r07438
pt_r07432:
	CMP.B	#$04,D1
	BHI.S	pt_r07416
pt_r07438:
	BSR.W	pt_ConvertKeyToNote
	SUBQ.L	#1,D1
	LSL.L	#2,D1
	MOVE.L	D1,D0
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D1
	LSL.L	#8,D1
	LSL.L	#2,D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_r07462
	LSL.L	#1,D1
pt_r07462:
	ADDA.L	D1,A0
	MOVEA.L	A0,A1
	ADDA.L	D0,A0
	MOVE.W	dat_CursorColumn,D0
	DIVU.W	#$0006,D0
	AND.L	#$0000000f,D0
	LSL.L	#2,D0
	ADDA.L	D0,A1
	MOVEQ	#63,D1
pt_r0747e:
	MOVE.L	(A0),D0
	MOVE.L	(A1),(A0)
	MOVE.L	D0,(A1)
	BTST	#5,dat_ModeFlags
	BNE.S	pt_r074a2
	LEA	(32,A0),A0
	LEA	(32,A1),A1
	DBF	D1,pt_r0747e
	JSR	pt_PatViewDrawAll
	BRA.S	pt_r074b4
pt_r074a2:
	LEA	(16,A0),A0
	LEA	(16,A1),A1
	DBF	D1,pt_r0747e
	JSR	pt_PatViewDrawAll
pt_r074b4:
	JSR	pt_ClearStatusMsg
	BRA.W	pt_RestorePalette
dat_0476:
	DC.B	"SWAP TRACK (1/2/3/4)",0,0
dat_0477:
	DC.B	"SWAP (1/2/3/4/5/6/7/8)",0,0
dat_0478:
	DC.B	"MARK BLOCK 0"
dat_0479:
	DC.W	$302d
	DC.B	$30
dat_047A:
	DC.B	"0",0,0
	DC.B	"MARK ANY BLOCK!",0
	DC.B	"THE BUFFER IS EMPTY!",0
	DC.B	"COMMAND STORED!",0
dat_047B:
	DC.B	"SELECT NOTE",0
dat_047C:
	DC.B	"* HELP SELECTED *",0
dat_047D:
	DC.B	"* PLST SELECTED *",0
dat_047E:
	DC.B	"CANT OPEN HELPFILE",0
str_HelpFilePath:
	DC.B	"s:PT.help",0
dat_0480:
	DC.B	"PLAY MODULE....",0
dat_0481:
	DC.B	"PLAY PATTERN...",0
dat_0482:
	DC.B	"NORMAL RECORD..",0
dat_0483:
	DC.B	"STOPPED...",0
dat_0484:
	DC.B	"RECORD READY ...",0
dat_0485:
	DC.W	$0001
dat_StereoMode:
	DS.W	1
dat_PatternKeyVar:
	DS.W	1
dat_0488:
	DS.W	1
dat_LastPatPos:
	DS.W	1
dat_EditCursorPos:
	DS.W	1
dat_048B:
	DS.W	1
dat_048C:
	DS.W	1
dat_048D:
	DS.W	1
dat_048E:
	DS.W	1
dat_048F:
	DS.W	1
dat_SavedPatPos:
	DS.W	1
dat_ScreenModeTab1:
	DC.W	$0010
dat_ScreenModeTab2:
	DC.W	$0020
dat_ScreenModeTab3:
	DC.W	$0030
dat_KeyDispatchTab:
	DC.W	$003f
pt_r075ec:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.S	pt_r07604
pt_0495:
	CLR.W	dat_EditCursorPos
	JMP	pt_ClearStatusMsg
pt_r07604:
	DC.L	$33fc0001
	DC.L	dat_EditCursorPos
	DC.W	$33f9
	DC.L	dat_PatternPosition
	DC.L	dat_0488
	DC.W	$33f9
	DC.L	dat_PatternPosition
	DC.L	dat_LastPatPos
pt_DrawPatPosition:
	MOVE.W	(dat_0488,PC),D0
	MOVE.W	(dat_LastPatPos,PC),D1
	CMP.W	D0,D1
	BCC.S	pt_0497
	EXG	D0,D1
pt_0497:
	LEA	(dat_0479,PC),A0
	BSR.S	pt_NumToDecASCII
	LEA	(dat_047A,PC),A0
	MOVE.W	D1,D0
	BSR.S	pt_NumToDecASCII
	LEA	(dat_0478,PC),A0
	JMP	pt_ShowStatusMsg
pt_r07646:
	CLR.B	dat_KeyCode
	MOVE.W	#$0001,dat_EditCursorPos
	MOVE.W	(dat_LastPatPos,PC),dat_PatternPosition
	BSR.W	pt_PatViewSetRow
	BRA.S	pt_DrawPatPosition
pt_CheckPatPosChange:
	TSTPC.W	dat_EditCursorPos
	BNE.S	pt_PatPosChanged
	RTS
pt_PatPosChanged:
	MOVE.W	dat_PatternPosition,D0
	CMP.W	(dat_LastPatPos,PC),D0
	BNE.S	pt_PatPosStore
	RTS
pt_PatPosStore:
	MOVE.W	D0,dat_LastPatPos
	BRA.S	pt_DrawPatPosition
pt_NumToDecASCII:
	AND.L	#$000000ff,D0
	DIVU	#$000a,D0
	ADD.B	#$30,D0
	MOVE.B	D0,(-1,A0)
	SWAP	D0
	ADD.B	#$30,D0
	MOVE.B	D0,(A0)
	RTS
pt_r0769c:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.W	pt_r07a08
	BSR.S	pt_r076c6
	MOVE.W	#$0001,dat_EditCursorPos
	BRA.W	pt_r078b6
pt_r076b8:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.W	pt_r07a08
pt_r076c6:
	CLR.W	dat_EditCursorPos
	MOVE.W	#$0001,dat_048B
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	LEA	dat_14F0,A1
	MOVEQ	#63,D0
pt_r076e8:
	MOVE.L	(A0),(A1)
	LEA	(16,A0),A0
	LEA	(16,A1),A1
	DBF	D0,pt_r076e8
	MOVE.W	(dat_0488,PC),D0
	MOVE.W	(dat_LastPatPos,PC),D1
	CMP.W	D0,D1
	BCC.S	pt_r07704
	EXG	D0,D1
pt_r07704:
	MOVE.W	D0,dat_048E
	MOVE.W	D1,dat_048F
	JMP	pt_ClearStatusMsg
pt_r07716:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_048B
	BEQ.W	pt_r07a16
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	LEA	dat_14F0,A1
	MOVE.W	(dat_048E,PC),D0
	MOVE.W	(dat_048F,PC),D1
	MOVE.W	dat_PatternPosition,D2
	LSL.W	#4,D0
	LSL.W	#4,D1
	LSL.W	#4,D2
pt_r0774e:
	MOVE.L	(0,A1,D0.W),D3
	TSTPC.W	dat_048C
	BEQ.S	pt_r07774
	MOVE.L	D3,D4
	AND.L	#$fffff000,D4
	BNE.S	pt_r07774
	MOVE.L	(0,A0,D2.W),D4
	AND.L	#$fffff000,D4
	AND.L	#$00000fff,D3
	OR.L	D4,D3
pt_r07774:
	MOVE.L	D3,(0,A0,D2.W)
	CMP.W	D0,D1
	BEQ.S	pt_r077b0
	CMP.W	#$03f0,D0
	BEQ.S	pt_r077b0
	CMP.W	#$03f0,D2
	BEQ.S	pt_r077b0
	ADD.W	#$0010,D0
	ADD.W	#$0010,D2
	TSTPC.W	dat_048D
	BEQ.S	pt_r0774e
	MOVEM.L	D0-D2/A1,-(A7)
	BSR.W	pt_ProcessPlayback
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVEM.L	(A7)+,D0-D2/A1
	BRA.S	pt_r0774e
pt_r077b0:
	CLR.W	dat_048C
	CLR.W	dat_048D
	JSR	pt_ClearStatusMsg
	JSR	pt_PatViewDrawAll
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_r077d0
	RTS
pt_r077d0:
	MOVE.W	(dat_048F,PC),D0
	SUB.W	(dat_048E,PC),D0
	ADDQ.W	#1,D0
	ADD.W	dat_PatternPosition,D0
	CMP.W	#$003f,D0
	BLS.S	pt_r077e8
	MOVEQ	#0,D0
pt_r077e8:
	MOVE.W	D0,dat_PatternPosition
	BRA.W	pt_PatViewSetRow
pt_r077f2:
	CLR.B	dat_KeyCode
	MOVE.W	#$0001,dat_048D
pt_r07800:
	CLR.B	dat_KeyCode
	MOVE.W	#$0001,dat_048C
	BRA.W	pt_r07716
pt_r07812:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_048B
	BEQ.W	pt_r07a16
	CMPI.W	#$003f,dat_PatternPosition
	BEQ.W	pt_r07716
	MOVE.W	(dat_048F,PC),D0
	SUB.W	(dat_048E,PC),D0
pt_r07834:
	MOVE.L	D0,-(A7)
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	BSR.W	pt_MovePatternRow
	MOVE.L	(A7)+,D0
	DBF	D0,pt_r07834
	BRA.W	pt_r07716
pt_r07850:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.W	pt_r07a08
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	(dat_0488,PC),D0
	MOVE.W	(dat_LastPatPos,PC),D1
	CMP.W	D0,D1
	BCC.S	pt_r07870
	EXG	D0,D1
pt_r07870:
	CMP.W	#$003f,D1
	BEQ.S	pt_r078b6
	CLR.W	dat_EditCursorPos
	MOVE.W	D0,dat_PatternPosition
	ADDQ.W	#1,dat_PatternPosition
	SUB.W	D0,D1
	MOVE.W	D1,D0
pt_r0788c:
	MOVE.L	D0,-(A7)
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	BSR.W	pt_DeletePatternRow
	MOVE.L	(A7)+,D0
	DBF	D0,pt_r0788c
	SUBQ.W	#1,dat_PatternPosition
	JSR	pt_ClearStatusMsg
	JMP	pt_PatViewDrawAll
pt_r078b6:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.W	pt_r07a08
	BSR.W	pt_ConvertKeyToNote
	CLR.W	dat_EditCursorPos
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVE.W	(dat_0488,PC),D0
	MOVE.W	(dat_LastPatPos,PC),D1
	CMP.W	D0,D1
	BCC.S	pt_r078e8
	EXG	D0,D1
pt_r078e8:
	LSL.W	#4,D0
	LSL.W	#4,D1
	MOVEQ	#0,D2
pt_r078ee:
	MOVE.L	D2,(0,A0,D0.W)
	CMP.W	D0,D1
	BEQ.S	pt_r078fc
	ADD.W	#$0010,D0
	BRA.S	pt_r078ee
pt_r078fc:
	JSR	pt_ClearStatusMsg
	JMP	pt_PatViewDrawAll
pt_r07908:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.W	pt_r07a08
	BSR.W	pt_ConvertKeyToNote
	CLR.W	dat_EditCursorPos
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVE.W	(dat_0488,PC),D0
	MOVE.W	(dat_LastPatPos,PC),D1
	CMP.W	D0,D1
	BCC.S	pt_r0793a
	EXG	D0,D1
pt_r0793a:
	LSL.W	#4,D0
	LSL.W	#4,D1
pt_r0793e:
	MOVE.L	(0,A0,D0.W),D2
	MOVE.L	(0,A0,D1.W),(0,A0,D0.W)
	MOVE.L	D2,(0,A0,D1.W)
	CMP.W	D1,D0
	BCC.S	pt_r0795e
	ADD.W	#$0010,D0
	SUB.W	#$0010,D1
	CMP.W	D1,D0
	BCC.S	pt_r0795e
	BRA.S	pt_r0793e
pt_r0795e:
	JSR	pt_ClearStatusMsg
	JMP	pt_PatViewDrawAll
pt_r0796a:
	CLR.B	dat_KeyCode
	SF	dat_RedrawUIState
	BRA.S	pt_r0797e
pt_r07978:
	ST	dat_RedrawUIState
pt_r0797e:
	CLR.B	dat_KeyCode
	TSTPC.W	dat_EditCursorPos
	BEQ.W	pt_r07a08
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	#$0002,dat_TransposeStep
	MOVE.W	(dat_0488,PC),D0
	MOVE.W	(dat_LastPatPos,PC),D1
	CMP.W	D0,D1
	BCC.S	pt_r079a6
	EXG	D0,D1
pt_r079a6:
	MOVE.W	D0,D5
	LSL.W	#4,D5
	SUB.W	D0,D1
	MOVE.W	D1,D6
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	LEA	(0,A0,D5.W),A3
	MOVEQ	#0,D3
	MOVE.B	dat_PlaybackState,dat_ScreenInitData
	ST	dat_PlaybackState
	TST.B	dat_RedrawUIState
	BEQ.S	pt_r079ee
	JSR	pt_0C63
	MOVE.B	dat_ScreenInitData,dat_PlaybackState
	JMP	pt_PatViewDrawAll
pt_r079ee:
	JSR	pt_0C54
	MOVE.B	dat_ScreenInitData,dat_PlaybackState
	JMP	pt_PatViewDrawAll
dat_RedrawUIState:
	DS.W	1
dat_ScreenInitData:
	DC.W	$0000
pt_r07a08:
	LEA	(dat_047A+3,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
pt_r07a16:
	LEA	(dat_047A+19,PC),A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetPaletteEdit
pt_r07a24:
	CLR.B	dat_KeyCode
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	dat_PatternPosition,dat_KeyActionTable
	ADDQ.W	#1,dat_PatternPosition
	CMPI.W	#$0040,dat_PatternPosition
	BCC.S	pt_r07a68
pt_r07a48:
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	BSR.W	pt_MovePatternRow
	ADDQ.W	#2,dat_PatternPosition
	CMPI.W	#$0040,dat_PatternPosition
	BCS.S	pt_r07a48
pt_r07a68:
	MOVE.W	dat_KeyActionTable,dat_PatternPosition
	JMP	pt_PatViewDrawAll
pt_r07a78:
	CLR.B	dat_KeyCode
	BSR.W	pt_ConvertKeyToNote
	MOVE.W	dat_PatternPosition,dat_KeyActionTable
	ADDQ.W	#1,dat_PatternPosition
	CMPI.W	#$0040,dat_PatternPosition
	BCC.S	pt_r07abc
pt_r07a9c:
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	BSR.W	pt_DeletePatternRow
	ADDQ.W	#1,dat_PatternPosition
	CMPI.W	#$0040,dat_PatternPosition
	BCS.S	pt_r07a9c
pt_r07abc:
	MOVE.W	dat_KeyActionTable,dat_PatternPosition
	JMP	pt_PatViewDrawAll
dat_KeyActionTable:
	DC.W	$0000
pt_r07ace:
	CLR.B	dat_KeyCode
	BSR.S	pt_ConvertKeyToNote
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVE.W	dat_PatternPosition,D0
	MOVE.W	D0,D1
	LSL.L	#4,D1
	LEA	(0,A0,D1.W),A0
	TSTPC.W	dat_KeyQual1
	BNE.S	pt_r07b0a
pt_r07af6:
	CLR.L	(A0)
	LEA	(16,A0),A0
	ADDQ.W	#1,D0
	CMP.W	#$0040,D0
	BCS.S	pt_r07af6
	JMP	pt_PatViewDrawAll
pt_r07b0a:
	CLR.L	(A0)
	LEA	(-16,A0),A0
	TST.W	D0
	BNE.S	pt_r07b1a
	JMP	pt_PatViewDrawAll
pt_r07b1a:
	SUBQ.W	#1,D0
	BRA.S	pt_r07b0a
pt_r07b1e:
	CLR.B	dat_KeyCode
	MOVEQ	#0,D0
	JSR	pt_GetPatternAddr
	LEA	dat_14F3,A1
	MOVE.W	#$00ff,D0
pt_r07b36:
	MOVE.L	(A1),D1
	MOVE.L	(A0),(A1)+
	MOVE.L	D1,(A0)+
	DBF	D0,pt_r07b36
	JMP	pt_PatViewDrawAll
pt_ConvertKeyToNote:
	MOVEM.L	D0/A0-A1,-(A7)
	MOVEQ	#0,D0
	JSR	pt_GetPatternAddr
	LEA	dat_14F3,A1
	MOVE.W	#$00ff,D0
pt_04A0:
	MOVE.L	(A0)+,(A1)+
	DBF	D0,pt_04A0
	MOVEM.L	(A7)+,D0/A0-A1
	RTS
pt_r07b68:
	CLR.B	dat_KeyCode
	LEA	dat_0D6C,A0
	BSR.W	pt_ShowYesNoDialog
	BNE.W	pt_SetPaletteEdit
	MOVE.W	dat_CurrentSample,dat_PatternKeyVar
	MOVE.W	#$0001,dat_CurrentSample
pt_r07b8e:
	JSR	pt_DrawSampleHex
	JSR	pt_BtnSmpBoost
	ADDQ.W	#1,dat_CurrentSample
	CMPI.W	#$0020,dat_CurrentSample
	BCS.S	pt_r07b8e
	MOVE.W	(dat_PatternKeyVar,PC),dat_CurrentSample
	JMP	pt_DrawSampleHex
pt_r07bb8:
	LEA	dat_0D6D,A0
	BSR.W	pt_ShowYesNoDialog
	BNE.W	pt_SetPaletteEdit
	MOVE.W	dat_CurrentSample,dat_PatternKeyVar
	MOVE.W	#$0001,dat_CurrentSample
pt_r07bd8:
	JSR	pt_DrawSampleHex
	JSR	dat_0D5F
	ADDQ.W	#1,dat_CurrentSample
	CMPI.W	#$0020,dat_CurrentSample
	BCS.S	pt_r07bd8
	MOVE.W	(dat_PatternKeyVar,PC),dat_CurrentSample
	JMP	pt_DrawSampleHex
pt_HandlePlayKeys:
	CMPI.B	#$50,dat_KeyCode
	BEQ.S	pt_PlaySong
	CMPI.B	#$51,dat_KeyCode
	BEQ.S	pt_PlayPattern
	RTS
pt_PlaySong:
	MOVE.L	#dat_PlaySongAddr,dat_PlayModePtr
	CLR.B	dat_KeyCode
	RTS
pt_PlayPattern:
	MOVE.L	#dat_PlayPatAddr,dat_PlayModePtr
	CLR.B	dat_KeyCode
	RTS
pt_04A4:
	MOVE.W	#$ffff,dat_PatKeyModeFlag
	MOVE.W	D0,dat_04B5
	MOVE.W	D1,dat_PatternKeyState
	BRA.S	pt_04A6
pt_ClearPatternKey:
	CLR.W	dat_PatKeyModeFlag
pt_04A6:
	BSR.W	pt_SavePaletteState
	BSR.W	pt_SetPaletteSong
	MOVEQ	#0,D0
	MOVE.W	dat_TextBytePos,D0
	DIVU	#$0050,D0
	ADDQ.W	#5,D0
	MOVE.W	D0,dat_PatternDelay
	SWAP	D0
	LSL.W	#3,D0
	ADDQ.W	#4,D0
	MOVE.W	D0,dat_PlayCounter
	TST.W	dat_PatKeyModeFlag
	BEQ.S	pt_04A7
	MOVE.W	(dat_04B5,PC),D0
	ADDQ.W	#4,D0
	MOVE.W	D0,dat_PlayCounter
	MOVE.W	(dat_PatternKeyState,PC),D0
	ADDQ.W	#5,D0
	MOVE.W	D0,dat_PatternDelay
pt_04A7:
	BSR.W	pt_DrawPlayCounter
	BSR.S	pt_UpdateDisplayInput
	MOVE.L	D1,D0
	MOVE.B	D1,D6
	LSL.B	#4,D6
	TST.W	dat_PatKeyModeFlag
	BEQ.S	pt_04A8
	BSR.S	pt_04AC
	BRA.S	pt_04A9
pt_04A8:
	JSR	pt_DrawNumberDec
pt_04A9:
	ADDQ.W	#8,dat_PlayCounter
	BSR.W	pt_DrawPlayCounter
	BSR.S	pt_UpdateDisplayInput
	MOVE.L	D1,D0
	OR.B	D1,D6
	TST.W	dat_PatKeyModeFlag
	BEQ.S	pt_04AA
	BSR.S	pt_04AC
	BRA.S	pt_04AB
pt_04AA:
	JSR	pt_DrawNumberDec
pt_04AB:
	MOVE.W	#$fff0,dat_PlayCounter
	CLR.W	dat_PatternDelay
	BSR.W	pt_DrawPlayCounter
	BSR.W	pt_RestorePalette
	MOVEQ	#0,D0
	MOVE.B	D6,D0
	RTS
pt_04AC:
	MOVEM.W	D0-D1/D3,-(A7)
	MOVE.W	D0,D3
	MOVE.W	dat_PlayCounter,D0
	SUBQ.W	#4,D0
	MOVE.W	(dat_PatternKeyState,PC),D1
	JSR	pt_DrawNumberHex
	MOVEM.W	(A7)+,D0-D1/D3
	RTS
pt_UpdateDisplayInput:
	BSR.W	pt_ScreenDragUpdate
	CLR.B	dat_LastKeyStored
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	RMB
	BEQ.S	pt_ReturnZero
	BSR.W	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	MOVE.B	D0,dat_LastKeyStored
	BEQ.S	pt_UpdateDisplayInput
	CMP.B	#$44,D0
	BEQ.S	pt_ReturnZero
	CMP.B	#$45,D0
	BEQ.S	pt_ReturnZero
	CMP.B	#$4f,D0
	BEQ.S	pt_04AF
	CMP.B	#$4e,D0
	BEQ.S	pt_04B0
	BSR.S	pt_04B1
	CMP.B	#$10,D1
	BEQ.S	pt_UpdateDisplayInput
	CLR.B	dat_KeyCode
pt_ReturnZero:
	MOVEQ	#0,D0
	RTS
pt_04AF:
	MOVEQ	#-1,D0
	RTS
pt_04B0:
	MOVEQ	#1,D0
	RTS
pt_04B1:
	LEA	dat_1325,A0
	MOVEQ	#0,D1
pt_04B2:
	CMP.B	(A0)+,D0
	BNE.S	pt_04B3
	RTS
pt_04B3:
	ADDQ.B	#1,D1
	CMP.B	#$10,D1
	BNE.S	pt_04B2
	RTS
dat_PatKeyModeFlag:
	DS.W	1
dat_04B5:
	DS.W	1
dat_PatternKeyState:
	DS.W	1
pt_04B7:
	TST.L	dat_SongDataPtr
	BNE.S	pt_04B8
	RTS
pt_04B8:
	MOVE.L	#$43484721,dat_SongChangedMagic
	MOVEQ	#0,D0
	MOVE.B	dat_KeyCode,D0
	BSR.S	pt_04B1
	CMP.B	#$10,D1
	BNE.S	pt_04B9
	RTS
pt_04B9:
	CMPI.W	#$0001,dat_CursorColumn
	BNE.S	pt_04BB
	CMP.W	#$0001,D1
	BLS.S	pt_04BA
	RTS
pt_04BA:
	MOVE.L	#$00000fff,D2
	CLR.W	dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04BB:
	CMPI.W	#$0002,dat_CursorColumn
	BNE.S	pt_04BC
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0002,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04BC:
	CMPI.W	#$0003,dat_CursorColumn
	BNE.S	pt_04BD
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$0002,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04BD:
	CMPI.W	#$0004,dat_CursorColumn
	BNE.S	pt_04BE
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$0002,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04BE:
	CMPI.W	#$0005,dat_CursorColumn
	BNE.S	pt_04BF
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$0002,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04BF:
	CMPI.W	#$0007,dat_CursorColumn
	BNE.S	pt_04C1
	CMP.W	#$0001,D1
	BLS.S	pt_04C0
	RTS
pt_04C0:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0004,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04C1:
	CMPI.W	#$0008,dat_CursorColumn
	BNE.S	pt_04C2
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0006,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04C2:
	CMPI.W	#$0009,dat_CursorColumn
	BNE.S	pt_04C3
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$0006,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04C3:
	CMPI.W	#$000a,dat_CursorColumn
	BNE.S	pt_04C4
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$0006,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04C4:
	CMPI.W	#$000b,dat_CursorColumn
	BNE.S	pt_04C5
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$0006,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04C5:
	CMPI.W	#$000d,dat_CursorColumn
	BNE.S	pt_04C7
	CMP.W	#$0001,D1
	BLS.S	pt_04C6
	RTS
pt_04C6:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0008,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04C7:
	CMPI.W	#$000e,dat_CursorColumn
	BNE.S	pt_04C8
	MOVE.L	#$00000fff,D2
	MOVE.W	#$000a,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04C8:
	CMPI.W	#$000f,dat_CursorColumn
	BNE.S	pt_04C9
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$000a,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04C9:
	CMPI.W	#$0010,dat_CursorColumn
	BNE.S	pt_04CA
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$000a,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04CA:
	CMPI.W	#$0011,dat_CursorColumn
	BNE.S	pt_04CB
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$000a,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04CB:
	CMPI.W	#$0013,dat_CursorColumn
	BNE.S	pt_04CD
	CMP.W	#$0001,D1
	BLS.S	pt_04CC
	RTS
pt_04CC:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$000c,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04CD:
	CMPI.W	#$0014,dat_CursorColumn
	BNE.S	pt_04CE
	MOVE.L	#$00000fff,D2
	MOVE.W	#$000e,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04CE:
	CMPI.W	#$0015,dat_CursorColumn
	BNE.S	pt_04CF
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$000e,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04CF:
	CMPI.W	#$0016,dat_CursorColumn
	BNE.S	pt_04D0
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$000e,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04D0:
	CMPI.W	#$0017,dat_CursorColumn
	BNE.S	pt_04D1
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$000e,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04D1:
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_04D2
	RTS
pt_04D2:
	CMPI.W	#$0019,dat_CursorColumn
	BNE.S	pt_04D4
	CMP.W	#$0001,D1
	BLS.S	pt_04D3
	RTS
pt_04D3:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0010,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04D4:
	CMPI.W	#$001a,dat_CursorColumn
	BNE.S	pt_04D5
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0012,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04D5:
	CMPI.W	#$001b,dat_CursorColumn
	BNE.S	pt_04D6
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$0012,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04D6:
	CMPI.W	#$001c,dat_CursorColumn
	BNE.S	pt_04D7
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$0012,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04D7:
	CMPI.W	#$001d,dat_CursorColumn
	BNE.S	pt_04D8
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$0012,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04D8:
	CMPI.W	#$001f,dat_CursorColumn
	BNE.S	pt_04DA
	CMP.W	#$0001,D1
	BLS.S	pt_04D9
	RTS
pt_04D9:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0014,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04DA:
	CMPI.W	#$0020,dat_CursorColumn
	BNE.S	pt_04DB
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0016,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04DB:
	CMPI.W	#$0021,dat_CursorColumn
	BNE.S	pt_04DC
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$0016,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04DC:
	CMPI.W	#$0022,dat_CursorColumn
	BNE.S	pt_04DD
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$0016,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04DD:
	CMPI.W	#$0023,dat_CursorColumn
	BNE.S	pt_04DE
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$0016,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04DE:
	CMPI.W	#$0025,dat_CursorColumn
	BNE.S	pt_04E0
	CMP.W	#$0001,D1
	BLS.S	pt_04DF
	RTS
pt_04DF:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$0018,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04E0:
	CMPI.W	#$0026,dat_CursorColumn
	BNE.S	pt_04E1
	MOVE.L	#$00000fff,D2
	MOVE.W	#$001a,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04E1:
	CMPI.W	#$0027,dat_CursorColumn
	BNE.S	pt_04E2
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$001a,dat_SongSpeed
	LSL.W	#8,D1
	BRA.W	pt_WritePatternData
pt_04E2:
	CMPI.W	#$0028,dat_CursorColumn
	BNE.S	pt_04E3
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$001a,dat_SongSpeed
	LSL.W	#4,D1
	BRA.W	pt_WritePatternData
pt_04E3:
	CMPI.W	#$0029,dat_CursorColumn
	BNE.S	pt_04E4
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$001a,dat_SongSpeed
	BRA.W	pt_WritePatternData
pt_04E4:
	CMPI.W	#$002b,dat_CursorColumn
	BNE.S	pt_04E6
	CMP.W	#$0001,D1
	BLS.S	pt_04E5
	RTS
pt_04E5:
	MOVE.L	#$00000fff,D2
	MOVE.W	#$001c,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.S	pt_WritePatternData
pt_04E6:
	CMPI.W	#$002c,dat_CursorColumn
	BNE.S	pt_04E7
	MOVE.L	#$00000fff,D2
	MOVE.W	#$001e,dat_SongSpeed
	LSL.W	#4,D1
	LSL.W	#8,D1
	BRA.S	pt_WritePatternData
pt_04E7:
	CMPI.W	#$002d,dat_CursorColumn
	BNE.S	pt_04E8
	MOVE.L	#$0000f0ff,D2
	MOVE.W	#$001e,dat_SongSpeed
	LSL.W	#8,D1
	BRA.S	pt_WritePatternData
pt_04E8:
	CMPI.W	#$002e,dat_CursorColumn
	BNE.S	pt_04E9
	MOVE.L	#$0000ff0f,D2
	MOVE.W	#$001e,dat_SongSpeed
	LSL.W	#4,D1
	BRA.S	pt_WritePatternData
pt_04E9:
	CMPI.W	#$002f,dat_CursorColumn
	BNE.S	pt_04EA
	MOVE.L	#$0000fff0,D2
	MOVE.W	#$001e,dat_SongSpeed
	BRA.S	pt_WritePatternData
pt_04EA:
	RTS
pt_WritePatternData:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_ClearDataRegs
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_CalcPatAddress
	LSL.L	#1,D0
pt_CalcPatAddress:
	ADDA.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	dat_PatternPosition,D0
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatAddr8ChAdj
	LSL.W	#1,D0
pt_PatAddr8ChAdj:
	EXT.L	D0
	ADDA.L	D0,A0
	MOVEA.L	A0,A1
	MOVEQ	#0,D0
	MOVE.W	dat_SongSpeed,D0
	ADDA.L	D0,A0
	AND.L	#$fffffffc,D0
	ADDA.L	D0,A1
	AND.W	D2,(A0)
	ADD.W	D1,(A0)
	MOVEQ	#0,D0
	MOVE.W	dat_PatternPosition,D0
	MULU	#$0280,D0
	MOVE.W	dat_CursorColumn,D1
	DIVU	#$0006,D1
	MULU	#$0009,D1
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_04EE
	MULU	#$0002,D1
pt_04EE:
	ADD.L	D1,D0
	ADD.W	#$3ca7,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_04EF
	SUBQ.W	#1,D0
pt_04EF:
	MOVE.W	D0,dat_TextBytePos
	MOVEA.L	A1,A0
	JSR	pt_PatViewDrawCell
	BSR.W	pt_AutoStepAdvance
	CLR.B	dat_KeyCode
	RTS
pt_r08370:
	MOVEQ	#0,D0
	MOVE.B	dat_KeyCode,D0
	BNE.S	pt_r0837c
	RTS
pt_r0837c:
	CMP.B	#$46,D0
	BEQ.W	pt_04FC
	CMP.B	#$0a,D0
	BLS.S	pt_r0838c
	RTS
pt_r0838c:
	SUBQ.B	#1,D0
	ADD.B	D0,D0
	MOVE.L	D0,D7
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVE.W	dat_PatternPosition,D0
	LSL.W	#4,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	(2,A0),D0
	AND.W	#$0fff,D0
	LEA	dat_DisplayWorkBuf,A0
	MOVE.W	D0,(0,A0,D7.W)
	LEA	(dat_047A+40,PC),A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_UpdatePaletteAll
	JMP	pt_ClearStatusMsg
pt_04F0:
	CLR.W	dat_CursorEditValue
	MOVEQ	#0,D0
	MOVE.B	dat_KeyCode,D0
	BNE.S	pt_04F1
	RTS
pt_04F1:
	CMP.B	#$46,D0
	BEQ.W	pt_04FC
	CMP.B	#$0b,D0
	BEQ.W	pt_04F8
	CMP.B	#$0c,D0
	BEQ.S	pt_04F6
	CMP.B	#$0d,D0
	BEQ.S	pt_04F5
	CMP.B	#$0a,D0
	BLS.S	pt_04F2
	RTS
pt_04F2:
	SUBQ.B	#1,D0
	ADD.B	D0,D0
	LEA	dat_DisplayWorkBuf,A0
	MOVE.W	(0,A0,D0.W),dat_CursorEditValue
pt_KeyCodeF:
	MOVE.B	#$46,dat_KeyCode
	BRA.W	pt_KeyToPlayCmd
pt_CursorPatternEdit:
	MOVE.W	dat_CursorColumn,D0
	JSR	pt_GetPatternAddr
	MOVE.W	dat_PatternPosition,D0
	SUBQ.W	#1,D0
	AND.W	#$003f,D0
	LSL.W	#4,D0
	LEA	(0,A0,D0.W),A0
	MOVE.W	(2,A0),D0
	AND.W	#$0fff,D0
	RTS
pt_04F5:
	BSR.S	pt_CursorPatternEdit
	MOVE.W	D0,dat_CursorEditValue
	BRA.S	pt_KeyCodeF
pt_04F6:
	BSR.S	pt_CursorPatternEdit
	MOVE.W	D0,D1
	AND.W	#$0f00,D1
	CMP.W	#$0e00,D1
	BEQ.S	pt_04F7
	ADDQ.B	#1,D0
	MOVE.W	D0,dat_CursorEditValue
	BRA.S	pt_KeyCodeF
pt_04F7:
	MOVE.W	D0,D1
	ADDQ.B	#1,D1
	AND.B	#$0f,D1
	AND.W	#$0ff0,D0
	OR.B	D1,D0
	MOVE.W	D0,dat_CursorEditValue
	BRA.S	pt_KeyCodeF
pt_04F8:
	BSR.S	pt_CursorPatternEdit
	MOVE.W	D0,D1
	AND.W	#$0f00,D1
	CMP.W	#$0e00,D1
	BEQ.S	pt_04F9
	SUBQ.B	#1,D0
	MOVE.W	D0,dat_CursorEditValue
	BRA.W	pt_KeyCodeF
pt_04F9:
	MOVE.W	D0,D1
	SUBQ.B	#1,D1
	AND.B	#$0f,D1
	AND.W	#$0ff0,D0
	OR.B	D1,D0
	MOVE.W	D0,dat_CursorEditValue
	BRA.W	pt_KeyCodeF
dat_CursorEditValue:
	DS.W	1
pt_HandleCursorEdit:
	TST.B	dat_KeyCode
	BEQ.S	pt_PatternEditDone
	TSTPC.W	dat_KeyQual4
	BNE.S	pt_PatternEditDone
	TSTPC.W	dat_KeyQual3
	BNE.S	pt_PatternEditDone
	TSTPC.W	dat_KeyQual1
	BNE.W	pt_r08370
	TSTPC.W	dat_KeyQual2
	BNE.W	pt_04F0
pt_04FC:
	MOVE.W	dat_CursorColumn,D0
	BEQ.W	pt_KeyToPlayCmd
	CMP.W	#$0006,D0
	BEQ.W	pt_KeyToPlayCmd
	CMP.W	#$000c,D0
	BEQ.W	pt_KeyToPlayCmd
	CMP.W	#$0012,D0
	BEQ.W	pt_KeyToPlayCmd
	BTST	#5,dat_ModeFlags
	BNE.S	pt_04FD
	CMP.W	#$0018,D0
	BEQ.W	pt_KeyToPlayCmd
	CMP.W	#$001e,D0
	BEQ.W	pt_KeyToPlayCmd
	CMP.W	#$0024,D0
	BEQ.W	pt_KeyToPlayCmd
	CMP.W	#$002a,D0
	BEQ.W	pt_KeyToPlayCmd
pt_04FD:
	TST.L	dat_SongDataPtr
	BNE.W	pt_04B7
pt_PatternEditDone:
	RTS
pt_r08534:
	MOVE.B	dat_KeyCode,D0
	BEQ.S	pt_r085ba
	CMP.B	#$07,D0
	BHI.S	pt_r085ba
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_r08562
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_r08562
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_r08562
	RTS
pt_r08562:
	BSR.W	pt_ClearKeyState
	CMP.B	#$01,D0
	BNE.S	pt_r08572
	JMP	pt_BtnMainOptPage1
pt_r08572:
	CMP.B	#$02,D0
	BNE.S	pt_r0857e
	JMP	pt_BtnMainOptPage2
pt_r0857e:
	CMP.B	#$03,D0
	BNE.S	pt_r0858a
	JMP	pt_BtnMainOptPage3
pt_r0858a:
	CMP.B	#$04,D0
	BNE.S	pt_r08596
	JMP	pt_BtnMainOptPage4
pt_r08596:
	CMP.B	#$05,D0
	BNE.S	pt_r085a2
	JMP	pt_BtnMainOptPage5
pt_r085a2:
	CMP.B	#$06,D0
	BNE.S	pt_r085ae
	JMP	pt_BtnMainOptPage6
pt_r085ae:
	CMP.B	#$07,D0
	BNE.S	pt_r085ba
	JMP	pt_BtnMainOptPage7
pt_r085ba:
	RTS
pt_KeyToPlayCmd:
	LEA	dat_1326,A0
	MOVE.B	dat_KeyCode,D1
	MOVEQ	#38,D0
pt_0500:
	CMP.B	(0,A0,D0.W),D1
	BEQ.S	pt_0501
	DBF	D0,pt_0500
	RTS
pt_0501:
	CLR.B	dat_KeyCode
	MOVEA.L	dat_PlayModePtr,A1
	MOVE.B	(0,A1,D0.W),D0
	CMP.W	#$0024,D0
	BCC.S	pt_0505
	MOVE.L	dat_TempBufPtr,D1
	BEQ.S	pt_0505
	CLR.L	dat_TempBufPtr
	MOVEA.L	D1,A0
	MOVE.B	D0,(A0)
	MOVE.W	dat_ScreenSizeVar,D1
	BEQ.W	pt_PatternDisplaySetup
	CLR.W	dat_ScreenSizeVar
	AND.W	#$00ff,D0
	MOVE.W	D0,(A0)
	CMP.W	#$0001,D1
	BNE.S	pt_0502
	JMP	dat_ScreenDispData1
pt_0502:
	CMP.W	#$0002,D1
	BNE.S	pt_0503
	JMP	dat_ScreenDispData2
pt_0503:
	CMP.W	#$0003,D1
	BEQ.W	pt_PalEdDisplay
	CMP.W	#$0004,D1
	BNE.S	pt_0504
	JMP	pt_LoadEffectTbl
pt_0504:
	JMP	pt_ClearStatusMsg
pt_0505:
	MOVE.W	dat_CurrentSample,dat_SamplePlayMode
	BTST	#4,dat_InputReadyFlag
	BEQ.S	pt_0507
	LEA	dat_152B,A1
	MOVE.B	(0,A1,D0.W),D1
	BEQ.S	pt_0506
	MOVE.B	D1,dat_127D
pt_0506:
	LEA	dat_152A,A1
	MOVE.B	(0,A1,D0.W),D0
pt_0507:
	MOVEQ	#0,D2
pt_0508:
	LEA	dat_PeriodTable,A1
	MOVE.L	D0,D4
	LSL.W	#1,D0
	MOVEQ	#0,D3
	MOVE.W	(0,A1,D0.W),D3
	MOVEA.L	dat_ModulePtr,A0
	LEA	(14,A0),A0
	MOVE.W	dat_CurrentSample,D1
	BNE.S	pt_CheckPatternPlay
	MOVE.W	dat_SamplePlayInit,D1
pt_CheckPatternPlay:
	MULU	#s_SIZEOF,D1
	ADDA.L	D1,A0
	MOVEQ	#0,D1
	MOVE.B	(A0),D1
	AND.B	#$0f,D1
	MULU	#$004a,D1
	ADDA.L	D1,A1
	MOVE.W	(0,A1,D0.W),dat_PlaybackEnable
	TST.L	D2
	BEQ.S	pt_050A
	CMPI.B	#$02,dat_SampleKeyState
	BNE.W	pt_CheckPatSync
pt_050A:
	TST.L	dat_SongDataPtr
	BEQ.W	pt_CheckPatSync
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_ClearDataRegs
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.L	#$43484721,dat_SongChangedMagic
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_050B
	LSL.L	#1,D0
pt_050B:
	ADDA.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	dat_PatternPosition,D0
	BSR.W	pt_CalcPatSyncStep
	LSL.W	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_050C
	LSL.W	#1,D0
pt_050C:
	EXT.L	D0
	ADDA.L	D0,A0
	MOVE.W	dat_CursorColumn,D0
	DIVU	#$0006,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_050D
	DIVU	#$0002,D0
pt_050D:
	LSL.W	#2,D0
	EXT.L	D0
	ADDA.L	D0,A0
	TSTPC.W	dat_KeyQual2
	BEQ.S	pt_r08760
	ANDI.L	#$fffff000,(A0)
	MOVE.W	(dat_CursorEditValue,PC),D0
	OR.W	D0,(2,A0)
	BRA.S	pt_050E
pt_r08760:
	TSTPC.W	dat_KeyQual1
	BEQ.S	pt_r08768
	CLR.L	(A0)
pt_r08768:
	MOVE.W	D3,(A0)
	BEQ.S	pt_r0879a
	TST.B	dat_InputSplitMode
	BEQ.S	pt_r0877c
	MOVE.W	dat_DisplayWordVar2,(2,A0)
pt_r0877c:
	MOVEQ	#0,D0
	MOVE.W	dat_SamplePlayMode,D0
	LSL.W	#4,D0
	ANDI.B	#$0f,(2,A0)
	ADD.B	D0,(2,A0)
	LSL.W	#4,D0
	AND.W	#$f000,D0
	OR.W	D0,(A0)
	BRA.S	pt_050E
pt_r0879a:
	ANDI.W	#$0fff,(2,A0)
pt_050E:
	MOVE.W	(2,A0),dat_ModuleChanged
	MOVEQ	#0,D0
	MOVE.W	dat_PatternPosition,D0
	BSR.W	pt_CalcPatSyncStep
	MULU	#$0280,D0
	MOVEQ	#0,D1
	MOVE.W	dat_CursorColumn,D1
	DIVU	#$0006,D1
	MULU	#$0009,D1
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_PatAddrChanAdj
	MULU	#$0002,D1
pt_PatAddrChanAdj:
	ADD.L	D1,D0
	ADD.W	#$3ca7,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_PatAddrReady
	SUBQ.W	#1,D0
pt_PatAddrReady:
	MOVE.W	D0,dat_TextBytePos
	JSR	pt_PatViewDrawCell
	BSR.W	pt_AutoStepAdvance
pt_CheckPatSync:
	TST.W	dat_PatternSync
	BNE.S	pt_MainPlaybackLoop
	TST.W	dat_PlaybackEnable
	BNE.W	pt_EdPlayStart
pt_MainPlaybackLoop:
	TST.B	dat_PlaybackRunning
	BNE.S	pt_ProcessPlayback
	RTS
pt_ProcessPlayback:
	MOVEQ	#0,D0
	MOVE.W	dat_CursorColumn,D0
	DIVU	#$0006,D0
	LEA	dat_DiskIOReady,A0
	MOVE.B	(0,A0,D0.W),D0
	SUBQ.W	#1,D0
	AND.W	#$0003,D0
	MULU	#$0006,D0
	MOVE.W	D0,dat_CursorColumn
	BRA.W	pt_ReturnFromPlay
pt_CalcPatSyncStep:
	TST.L	dat_RpPlayMode
	BEQ.S	pt_PatSyncClear
	MOVEQ	#0,D1
	MOVE.B	dat_PatSyncStep,D1
	BEQ.S	pt_PatSyncClear
	CMP.W	#$0001,D1
	BEQ.S	pt_PatSyncHalf
	MOVE.W	#$0001,dat_PatternSync
	MOVE.L	D1,D2
	LSR.W	#1,D2
	ADD.W	D0,D2
	AND.W	#$003f,D2
	DIVU	D1,D2
	MULU	D1,D2
	CMP.W	D0,D2
	BHI.S	pt_PatSyncCalc
	CLR.W	dat_PatternSync
pt_PatSyncCalc:
	MOVE.W	D2,D0
	RTS
pt_PatSyncHalf:
	MOVE.L	dat_RpSpeed,D1
	LSR.L	#1,D1
	CMP.L	dat_RpCounter,D1
	BLS.S	pt_PatSyncAdvance
pt_PatSyncClear:
	CLR.W	dat_PatternSync
	RTS
pt_PatSyncAdvance:
	ADDQ.W	#1,D0
	AND.W	#$003f,D0
	MOVE.W	#$0001,dat_PatternSync
	RTS
pt_EdPlayStart:
	MOVE.W	dat_SamplePlayMode,D0
	BNE.S	pt_CheckChanMask
	MOVE.W	dat_CurrentSample,D0
	BEQ.S	pt_EdPlaySample
pt_CheckChanMask:
	MOVEM.L	D1,-(A7)
	MOVE.L	dat_RpChunkedSamples,D1
	BTST	D0,D1
	MOVEM.L	(A7)+,D1
	SNE	D1
	MOVEQ	#18,D7
	JSR	pt_MixEdPlayInit
	NOP
	NOP
	NOP
	NOP
pt_EdPlayFindChan:
	CMP.W	dat_CursorColumn,D7
	BEQ.S	pt_EdPlayChanFound
	SUBQ.W	#6,D7
	LEA	(-88,A4),A4
	LEA	(-16,A5),A5
	SUBQ.W	#1,D0
	BGE.S	pt_EdPlayFindChan
	RTS
pt_EdPlayChanFound:
	TST.B	D1
	BEQ.S	pt_EdPlaySample
	MOVE.W	dat_CurrentSample,D1
	MOVE.W	#$4000,INTENA
	BSR.W	pt_BuildChunkList
	BRA.W	pt_EdPlaySampleChunked
pt_EdPlaySample:
	MOVE.W	#$4000,INTENA
	LEA	dat_EffectData0,A6
	MOVE.W	dat_SamplePlayMode,D0
	BEQ.S	pt_SetupChannelParams
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	dat_ModulePtr,A0
	MOVE.L	(0,A0,D0.W),dat_CurSamplePtr
	LEA	dat_EffectData1,A6
	MOVEA.L	dat_ModulePtr,A0
	LEA	(-10,A0),A0
	MOVE.W	dat_SamplePlayMode,D0
	MOVE.B	D0,dat_PlayingSample
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVE.L	(s_length,A0),dat_EffectData1
	MOVE.L	(s_repeat,A0),dat_EffectData2
pt_SetupChannelParams:
	MOVE.B	dat_PlayingSample,(n_pt4_samplenum,A4)
	MOVE.W	(6,A6),D2
	MOVE.W	D2,(n_replen,A4)
	MOVE.W	(4,A6),D0
	MOVEQ	#0,D1
	MOVE.W	D0,D1
	BNE.S	pt_SampleAddOffset
	MOVE.W	(A6),D0
	BRA.S	pt_LoadSampleData
pt_SampleAddOffset:
	ADD.W	D2,D0
pt_LoadSampleData:
	MOVE.W	D0,(n_length,A4)
	BNE.S	pt_CalcSampleEnd
	MOVE.W	#$0001,(n_length,A4)
	LEA	chip_ScratchBuffer,A0
	MOVE.L	A0,(n_start,A4)
	MOVE.L	A0,(n_loopstart,A4)
	BRA.S	pt_ClearSampleOfs
pt_CalcSampleEnd:
	ADD.L	D1,D1
	MOVE.L	(8,A6),D0
	ADD.L	D0,D1
	MOVE.L	D1,(n_loopstart,A4)
	ADD.L	dat_SampleOffset,D0
	MOVE.L	D0,(n_start,A4)
pt_ClearSampleOfs:
	CLR.L	dat_SampleOffset
	MOVEQ	#0,D1
	MOVE.B	(3,A6),D1
	MOVE.B	D1,(n_volume,A4)
	MOVE.W	dat_PlaybackEnable,(n_period,A4)
	ST	(n_pt4_dmawait,A4)
	CLR.W	(n_pt4_dmacount,A4)
	SF	(n_pt4_chunked,A4)
	LEA	dat_SamplePlayBuf,A0
	MOVE.L	(n_start,A4),(A0)+
	MOVE.W	(n_length,A4),(A0)+
	SUBQ.W	#6,A0
	BSR.S	pt_EdPlayDma
	ST	(n_pt4_trigger,A4)
	BRA.W	pt_MainPlaybackLoop
pt_EdPlayDma:
	LEA	HARDBASE,A6
	MOVE.W	(2,A6),D0
	MOVE.W	(n_pt4_chanbit,A4),D1
	BTST	D1,D0
	BNE.S	pt_EdPlayDmaBusy
	MOVE.W	(n_pt4_intmask,A4),(154,A6)
	MOVE.W	(n_pt4_intmask,A4),(156,A6)
	MOVE.W	#$0001,(aud_PER,A5)
	MOVE.L	(A0)+,(A5)
	MOVE.W	(A0),(aud_LEN,A5)
	CLR.W	(aud_DAT,A5)
	BRA.S	pt_PlayNoteEnable
pt_EdPlayDmaBusy:
	MOVE.W	(n_pt4_intmask,A4),(154,A6)
	MOVE.W	(n_pt4_intmask,A4),(156,A6)
	MOVE.W	(n_pt4_dmacon,A4),(150,A6)
	MOVE.W	#$0001,(aud_PER,A5)
	BRA.W	pt_PlayNoteStart
pt_PlayNoteStart:
	DC.L	$2a983b50,$0004426d
	DC.W	$0008
pt_PlayNoteEnable:
	MOVE.W	#$c000,(154,A6)
	MOVE.W	(n_pt4_intena,A4),(154,A6)
	RTS
dat_PlayingSample:
	DS.W	1
dat_SamplePlayBuf:
	DS.L	1
	DS.W	1
pt_WaitDMASync:
	MOVE.L	D0,-(A7)
pt_r08a5e:
	MOVE.B	$00dff007.L,D0
pt_r08a64:
	CMP.B	$00dff007.L,D0
	BEQ.S	pt_r08a64
	DBF	D1,pt_r08a5e
	MOVE.L	(A7)+,D0
	RTS
pt_InitAudioChannels:
	LEA	dat_AudioChannelPtrs,A1
	LEA	dat_ChannelPtrTable,A0
	MOVEA.L	(A0)+,A2
	MOVE.W	#$0001,(n_pt4_dmacon,A2)
	MOVE.W	#$8001,(n_pt4_dmaset,A2)
	MOVE.W	#$0080,(n_pt4_intmask,A2)
	MOVE.W	#$8080,(n_pt4_intena,A2)
	MOVE.L	(A1)+,(n_pt4_chunklist,A2)
	CLR.W	(n_pt4_chanbit,A2)
	MOVEA.L	(A0)+,A2
	MOVE.W	#$0002,(n_pt4_dmacon,A2)
	MOVE.W	#$8002,(n_pt4_dmaset,A2)
	MOVE.W	#$0100,(n_pt4_intmask,A2)
	MOVE.W	#$8100,(n_pt4_intena,A2)
	MOVE.L	(A1)+,(n_pt4_chunklist,A2)
	MOVE.W	#$0001,(n_pt4_chanbit,A2)
	MOVEA.L	(A0)+,A2
	MOVE.W	#$0004,(n_pt4_dmacon,A2)
	MOVE.W	#$8004,(n_pt4_dmaset,A2)
	MOVE.W	#$0200,(n_pt4_intmask,A2)
	MOVE.W	#$8200,(n_pt4_intena,A2)
	MOVE.L	(A1)+,(n_pt4_chunklist,A2)
	MOVE.W	#$0002,(n_pt4_chanbit,A2)
	MOVEA.L	(A0)+,A2
	MOVE.W	#$0008,(n_pt4_dmacon,A2)
	MOVE.W	#$8008,(n_pt4_dmaset,A2)
	MOVE.W	#$0400,(n_pt4_intmask,A2)
	MOVE.W	#$8400,(n_pt4_intena,A2)
	MOVE.L	(A1)+,(n_pt4_chunklist,A2)
	MOVE.W	#$0003,(n_pt4_chanbit,A2)
	RTS
pt_BuildChunkList:
	MOVEM.L	D0-D1/D6-D7/A0-A3,-(A7)
	LEA	dat_AudioChannelPtrs,A3
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVEA.L	(0,A3,D0.W),A3
	MOVE.W	D1,D0
	BNE.S	pt_BuildChunkListPieces
	BRA.S	pt_BuildChunkListEnd
pt_BuildChunkListPieces:
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	dat_ModulePtr,A0
	MOVEA.L	(0,A0,D0.W),A1
	ADD.W	D0,D0
	LEA	SECSTRT_4,A0
	MOVEA.L	(0,A0,D0.W),A2
	MOVEQ	#0,D0
	MOVE.W	(A2)+,D7
	MOVE.W	(A2)+,D6
pt_BuildChunkListLoop:
	MOVE.L	A1,(A3)+
	MOVE.W	(A2)+,D1
	MOVE.W	D1,(A3)+
	MOVE.W	(A2)+,(A3)+
	ADD.W	D1,D1
	ADDA.W	D1,A1
	ADDQ.W	#1,D0
	CMP.W	D6,D0
	BNE.S	pt_BuildChunkListCheck
	MOVEA.L	A3,A0
pt_BuildChunkListCheck:
	CMP.W	D7,D0
	BLT.S	pt_BuildChunkListLoop
	TST.W	D6
	BEQ.S	pt_BuildChunkListEnd
	MOVEA.L	A3,A1
	ADDQ.W	#4,A1
	SUBA.L	A1,A0
	MOVE.L	A0,(A3)+
pt_BuildChunkListEnd:
	CLR.L	(A3)+
	MOVEM.L	(A7)+,D0-D1/D6-D7/A0-A3
	RTS
pt_EdPlaySampleChunked:
	LEA	dat_EffectData0,A6
	MOVE.W	dat_SamplePlayMode,D0
	BEQ.S	pt_EdPlaySampleChunked2
	LEA	dat_EffectData1,A6
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	dat_ModulePtr,A0
	MOVE.L	(0,A0,D0.W),dat_CurSamplePtr
	MOVE.W	dat_SamplePlayMode,D0
	MOVE.B	D0,dat_PlayingSample
	MOVEA.L	dat_ModulePtr,A0
	LEA	(-10,A0),A0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVE.L	(s_length,A0),dat_EffectData1
	MOVE.L	(s_repeat,A0),dat_EffectData2
pt_EdPlaySampleChunked2:
	MOVE.B	(dat_PlayingSample,PC),(n_pt4_samplenum,A4)
	MOVEQ	#0,D1
	MOVE.W	(6,A6),D2
	MOVE.W	D2,(n_replen,A4)
	MOVE.W	(4,A6),D0
	MOVE.W	D0,D1
	BNE.S	pt_SampleRepOffset
	MOVE.W	(A6),D0
	BRA.S	pt_SampleSetLength
pt_SampleRepOffset:
	ADD.W	D2,D0
pt_SampleSetLength:
	MOVE.W	D0,(n_length,A4)
	BNE.S	pt_SampleCalcLoop
	MOVE.W	#$0001,(n_length,A4)
pt_SampleCalcLoop:
	ADD.L	D1,D1
	MOVE.L	(8,A6),D0
	ADD.L	D0,D1
	MOVE.L	D1,(n_loopstart,A4)
	MOVEA.L	(n_pt4_chunklist,A4),A0
	MOVE.L	A0,(n_pt4_chunkstart,A4)
	MOVE.L	D0,D1
	MOVE.L	dat_SampleOffset,D2
	ADD.L	D2,D1
	MOVE.L	D1,(n_start,A4)
	CLR.L	dat_SampleOffset
	TST.W	dat_SamplePlayMode
	BNE.S	pt_EdPlaySampleChunkedGo
	TST.L	D2
	BEQ.S	pt_SampleChkDMA
pt_SampleFindSlot:
	MOVE.L	(A0),D0
	BEQ.S	pt_SampleAdjSlot
	CMP.L	D0,D1
	BLT.S	pt_SampleAdjSlot
	ADDQ.W	#8,A0
	BRA.S	pt_SampleFindSlot
pt_SampleAdjSlot:
	SUBQ.W	#8,A0
	MOVEQ	#0,D0
	MOVE.L	(A0),D0
	SUB.L	D1,D0
	NEG.L	D0
	LSR.L	#1,D0
	SUB.W	D0,(4,A0)
	MOVE.L	D1,(A0)
	MOVE.L	A0,(n_pt4_chunkstart,A4)
pt_SampleChkDMA:
	MOVE.W	(n_length,A4),D1
	MOVEQ	#0,D2
pt_SampleDMALoop:
	TST.L	(A0)
	BEQ.S	pt_EdPlaySampleChunkedGo
	MOVE.W	(4,A0),D0
	ADD.W	D0,D2
	CMP.W	D1,D2
	BCC.S	pt_SampleTrimLen
	ADDQ.W	#8,A0
	BRA.S	pt_SampleDMALoop
pt_SampleTrimLen:
	SUB.W	D1,D2
	SUB.W	D2,D0
	MOVE.W	D0,(4,A0)
	CLR.L	(8,A0)
pt_EdPlaySampleChunkedGo:
	MOVE.W	#$4000,INTENA
	MOVEQ	#0,D1
	MOVE.B	(3,A6),D1
	MOVE.B	D1,(n_volume,A4)
	MULU	(20,A4),D1
	ADD.W	#$0020,D1
	LSR.W	#6,D1
	MOVE.W	D1,(n_pt4_irqvol,A4)
	MOVE.W	dat_PlaybackEnable,(n_period,A4)
	SF	(n_pt4_dmawait,A4)
	CLR.W	(n_pt4_dmacount,A4)
	ST	(n_pt4_chunked,A4)
	MOVEA.L	(n_pt4_chunkstart,A4),A0
	MOVE.L	A0,(n_pt4_chunkptr,A4)
	BSR.W	pt_EdPlayDma
	ST	(n_pt4_trigger,A4)
	BRA.W	pt_MainPlaybackLoop
pt_PlaybackKeyHandler:
	CMPI.B	#$04,dat_PlayMode
	BNE.S	pt_PlayKeyReturn
	RTS
pt_PlayKeyReturn:
	MOVE.B	dat_KeyCode,D0
	BEQ.S	pt_PlayCheckCursor
	MOVE.B	dat_KeyCode,D0
	BEQ.S	pt_PlayCheckCursor
	TST.W	dat_TimingMode
	BNE.S	pt_PlayCheckCursor
	TSTPC.W	dat_KeyQual1
	BNE.S	pt_PlayCheckCursor
	TSTPC.W	dat_KeyQual2
	BNE.S	pt_PlayCheckCursor
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_053E
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_PlayCheckCursor
	CMP.B	#$4e,D0
	BEQ.W	pt_KeyCursorRight
	CMP.B	#$4f,D0
	BEQ.W	pt_KeyCursorLeft
pt_PlayCheckCursor:
	CMP.B	#$4c,D0
	BEQ.S	pt_KeyCursorUp
	CMP.B	#$4d,D0
	BEQ.W	pt_KeyCursorDown
	CLR.W	dat_KeyRepeatState
	CLR.W	dat_KeyRepeatCount
pt_053E:
	RTS
dat_KeyRepeatState:
	DS.W	1
dat_KeyRepeatCount:
	DS.W	1
pt_KeyCursorUp:
	TST.L	dat_RpPlayMode
	BNE.S	pt_CursorUpReturn
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_CursorUpReturn
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_CursorUpReturn
	CMPI.W	#$0006,dat_UIMode
	BEQ.S	pt_CursorUpReturn
	CMPI.W	#$0008,dat_UIMode
	BEQ.S	pt_CursorUpReturn
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_CursorUpReturn
	TSTPC.W	dat_KeyRepeatState
	BEQ.S	pt_DoCursorUp
	ADDQ.W	#1,dat_KeyRepeatCount
	TSTPC.W	dat_KeyQual2
	BNE.S	pt_CursorRepeat1
	TSTPC.W	dat_KeyQual1
	BNE.S	pt_CursorRepeat3
	CMPI.W	#$0006,dat_KeyRepeatCount
	BPL.S	pt_DoCursorUp
pt_CursorUpReturn:
	RTS
pt_CursorRepeat3:
	CMPI.W	#$0003,dat_KeyRepeatCount
	BPL.S	pt_DoCursorUp
	RTS
pt_CursorRepeat1:
	CMPI.W	#$0001,dat_KeyRepeatCount
	BPL.S	pt_DoCursorUp
	RTS
pt_DoCursorUp:
	CLR.W	dat_KeyRepeatCount
	MOVE.W	#$ffff,dat_KeyRepeatState
	CMPI.L	#$70617474,dat_RpPlayMode
	BNE.S	pt_PatPosDecrement
	RTS
pt_PatPosDecrement:
	SUBQ.W	#1,dat_PatternPosition
	ANDI.W	#$003f,dat_PatternPosition
	BRA.W	pt_PatViewSetRow
pt_KeyCursorDown:
	TST.L	dat_RpPlayMode
	BNE.S	pt_CursorDownReturn
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_CursorDownReturn
	CMPI.W	#$0003,dat_UIMode
	BEQ.S	pt_CursorDownReturn
	CMPI.W	#$0006,dat_UIMode
	BEQ.S	pt_CursorDownReturn
	CMPI.W	#$0008,dat_UIMode
	BEQ.S	pt_CursorDownReturn
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_CursorDownReturn
	TSTPC.W	dat_KeyRepeatState
	BEQ.S	pt_DoCursorDown
	ADDQ.W	#1,dat_KeyRepeatCount
	TSTPC.W	dat_KeyQual2
	BNE.S	pt_r08e34
	TSTPC.W	dat_KeyQual1
	BNE.S	pt_CursorDownRepeat3
	CMPI.W	#$0006,dat_KeyRepeatCount
	BPL.S	pt_DoCursorDown
pt_CursorDownReturn:
	RTS
pt_CursorDownRepeat3:
	CMPI.W	#$0003,dat_KeyRepeatCount
	BPL.S	pt_DoCursorDown
	RTS
pt_r08e34:
	CMPI.W	#$0001,dat_KeyRepeatCount
	BPL.S	pt_DoCursorDown
	RTS
pt_DoCursorDown:
	CLR.W	dat_KeyRepeatCount
	MOVE.W	#$ffff,dat_KeyRepeatState
	TST.L	dat_RpPlayMode
	BEQ.S	pt_PatPosIncrement
	RTS
pt_PatPosIncrement:
	ADDQ.W	#1,dat_PatternPosition
	ANDI.W	#$003f,dat_PatternPosition
	BRA.W	pt_PatViewSetRow
pt_AutoStepAdvance:
	TST.L	dat_RpPlayMode
	BEQ.S	pt_DoStepAdvance
	RTS
pt_DoStepAdvance:
	TST.B	dat_EditStepMode
	BNE.S	pt_DoCursorRight
	MOVE.W	dat_EditStepSize,D0
	ADD.W	D0,dat_PatternPosition
	ANDI.W	#$003f,dat_PatternPosition
	BRA.W	pt_PatViewSetRow
dat_EditStepSize:
	DC.W	$0001
pt_KeyCursorRight:
	DC.W	$4a7a
	DC.W	$fe8a
	BEQ.S	pt_DoCursorRight
	ADDQ.W	#1,dat_KeyRepeatCount
	CMPI.W	#$0006,dat_KeyRepeatCount
	BPL.S	pt_DoCursorRight
	RTS
pt_DoCursorRight:
	CLR.W	dat_KeyRepeatCount
	MOVE.W	#$ffff,dat_KeyRepeatState
	ADDQ.W	#1,dat_CursorColumn
	BTST	#5,dat_ModeFlags
	BNE.S	pt_CursorRight8ChWrap
	CMPI.W	#$0030,dat_CursorColumn
	BMI.S	pt_CursorMoveDone
	CLR.W	dat_CursorColumn
	BRA.S	pt_ReturnFromPlay
pt_CursorRight8ChWrap:
	CMPI.W	#$0018,dat_CursorColumn
	BMI.S	pt_CursorMoveDone
	CLR.W	dat_CursorColumn
pt_CursorMoveDone:
	BRA.S	pt_ReturnFromPlay
pt_KeyCursorLeft:
	TSTPC.W	dat_KeyRepeatState
	BEQ.S	pt_DoCursorLeft
	ADDQ.W	#1,dat_KeyRepeatCount
	CMPI.W	#$0006,dat_KeyRepeatCount
	BPL.S	pt_DoCursorLeft
	RTS
pt_DoCursorLeft:
	CLR.W	dat_KeyRepeatCount
	MOVE.W	#$ffff,dat_KeyRepeatState
	SUBQ.W	#1,dat_CursorColumn
	TST.W	dat_CursorColumn
	BPL.S	pt_ReturnFromPlay
	BTST	#5,dat_ModeFlags
	BNE.S	pt_CursorLeft8ChWrap
	MOVE.W	#$002f,dat_CursorColumn
	BRA.S	pt_ReturnFromPlay
pt_CursorLeft8ChWrap:
	MOVE.W	#$0017,dat_CursorColumn
pt_ReturnFromPlay:
	TST.W	dat_SamplerActive
	BEQ.S	pt_UpdateCursorSprite
	RTS
pt_UpdateCursorSprite:
	MOVE.W	dat_CursorColumn,D0
	LEA	dat_CursorPosMap,A0
	MOVE.B	(0,A0,D0.W),D0
	MOVE.W	D0,D1
	LSL.W	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_CursorSprite8ChAdj
	LSR.W	#1,D0
	ADDQ.W	#8,D0
pt_CursorSprite8ChAdj:
	MOVE.W	#$00c5,D1
	MOVEQ	#9,D2
	MOVEA.L	dat_SpriteBufAddr,A0
	JMP	pt_DrawSprite
pt_HandleCursorKeys:
	MOVE.B	dat_KeyCode,D0
	TST.W	dat_SamplerActive
	BNE.W	pt_CursorKeysReturn
	TST.B	D0
	BNE.S	pt_DispatchCursorKey
pt_CursorKeysReturn:
	RTS
pt_DispatchCursorKey:
	CMP.B	#$4c,D0
	BEQ.S	pt_CursorUpDispatch
	CMP.B	#$4d,D0
	BEQ.S	pt_CursorDownDispatch
	CMP.B	#$4f,D0
	BEQ.W	pt_CursorRightMode
	CMP.B	#$4e,D0
	BEQ.W	pt_CursorLeftMode
	RTS
pt_CursorUpDispatch:
	CMPI.W	#$0002,dat_UIMode
	BEQ.W	pt_041C
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_CursorUpMode6
	BSR.W	pt_SampleEdDrawMode
	JMP	pt_RefreshDisplay
pt_CursorUpMode6:
	CMPI.W	#$0006,dat_UIMode
	BNE.S	pt_CursorUpMode8
	JMP	pt_BtnPlstUp
pt_CursorUpMode8:
	CMPI.W	#$0008,dat_UIMode
	BNE.S	pt_CursorUpMode9
	JMP	pt_BtnInfoUp
pt_CursorUpMode9:
	CMPI.W	#$0009,dat_UIMode
	BEQ.W	pt_DecrBplUpdate
	RTS
pt_CursorDownDispatch:
	CMPI.W	#$0002,dat_UIMode
	BEQ.W	pt_041D
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_CursorDownMode6
	BSR.W	pt_SampleEdDrawXPos
	BSR.W	pt_RefreshDisplay
	RTS
pt_CursorDownMode6:
	CMPI.W	#$0006,dat_UIMode
	BNE.S	pt_CursorDownMode8
	JMP	pt_BtnPlstDown
pt_CursorDownMode8:
	CMPI.W	#$0008,dat_UIMode
	BNE.S	pt_CursorDownMode9
	JMP	pt_BtnInfoDown
pt_CursorDownMode9:
	CMPI.W	#$0009,dat_UIMode
	BEQ.W	pt_088E
	RTS
pt_CursorRightMode:
	TSTPC.W	dat_KeyQual1
	BNE.W	pt_DecrBplUpdate
	TSTPC.W	dat_KeyQual2
	BNE.W	pt_092A
	TSTPC.W	dat_KeyQual3
	BNE.W	pt_08A3
	CMPI.W	#$0002,dat_UIMode
	BEQ.W	pt_041E
	CMPI.W	#$0009,dat_UIMode
	BNE.S	pt_CursorRightReturn
	MOVE.W	#$ffff,dat_ButtonActive
	BRA.W	pt_BtnMainPatternArrows
pt_CursorRightReturn:
	RTS
pt_CursorLeftMode:
	TSTPC.W	dat_KeyQual1
	BNE.W	pt_088E
	TSTPC.W	dat_KeyQual2
	BNE.W	pt_CheckPatpMagic
	TSTPC.W	dat_KeyQual3
	BNE.W	pt_08A1
	CMPI.W	#$0002,dat_UIMode
	BEQ.W	pt_041F
	CMPI.W	#$0009,dat_UIMode
	BNE.S	pt_CursorLeftReturn
	CLR.W	dat_ButtonActive
	BRA.W	pt_BtnMainPatternArrows
pt_CursorLeftReturn:
	RTS
pt_DrawPlayCounter:
	MOVE.W	dat_PlayCounter,D0
	LSR.W	#1,D0
	MOVE.W	dat_PatternDelay,D1
	SUBQ.W	#1,D0
	MOVEQ	#2,D2
	LEA	chip_SpritePlayCtr,A0
	JMP	pt_DrawSprite
	DC.W	$4e75
pt_ExitProgram:
	BSR.S	pt_MainInputHandler
	CLR.W	dat_InitFlag
pt_ExitAnimLoop:
	BSR.W	pt_ScreenDragUpdate
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-270,A6)
	MOVEM.L	(A7)+,D0-D7/A0-A6
	SUBQ.W	#1,dat_ExitCounter
	BMI.S	pt_ExitCheckMouse
	LMB
	BEQ.S	pt_ExitAnimLoop
pt_ExitToMainLoop:
	MOVE.W	#$0014,dat_ExitCounter
	CLR.W	dat_ButtonActive
	JMP	pt_MainLoop
pt_ExitCheckMouse:
	MOVE.W	#$0001,dat_ExitCounter
	LMB
	BEQ.S	pt_ExitProgram
	BRA.S	pt_ExitToMainLoop
dat_ExitCounter:
	DC.W	$0014
pt_MainInputHandler:
	MOVE.W	dat_EditDigitValue,dat_SavedEditDigit
	MOVE.W	dat_PalEdSelectPos,dat_SavedPalSelect
	MOVEM.W	dat_SavedEditDigit,D0-D1
	MOVE.W	dat_SavedPalSelect,D1
	CMP.W	#$0079,D1
	BCC.W	pt_InputPatternArea
	CMPI.W	#$0002,dat_UIMode
	BEQ.S	pt_InputMode2
	CMPI.W	#$0003,dat_UIMode
	BEQ.W	pt_InputDiskOp
	CMPI.W	#$0005,dat_UIMode
	BEQ.W	pt_InputSetup
	CMPI.W	#$0006,dat_UIMode
	BEQ.S	pt_InputMode6
	CMPI.W	#$0008,dat_UIMode
	BEQ.S	pt_InputMode8
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_InputMode9
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_InputMain
	RTS
pt_InputMode6:
	JMP	pt_InputPlst
pt_InputMode8:
	JMP	pt_InputComment
pt_InputMode2:
	BRA.W	pt_InputHelp
pt_InputMode9:
	JMP	pt_InputPosEdit
pt_InputMode5Keys:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1437,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BNE.W	pt_DispatchButton3
	RTS
