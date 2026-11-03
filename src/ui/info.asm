pt_EnterComment:
	CMPI.W	#$0008,dat_UIMode
	BEQ.W	pt_BtnInfoExit
	JSR	pt_EditModeDispatcher
	JSR	pt_WaitMouseRelease
	MOVE.W	#$0008,dat_UIMode
	ST	dat_ScopeBufferRef
	ST	dat_EditInputLock
	BSR.S	pt_1224
	BEQ.S	pt_BtnInfoExit
	JSR	pt_InitAudioDisplay
	JSR	pt_SetPaletteBright
	BSR.W	pt_1227
	BSR.W	pt_SampleEditDrawUpdate
	RTS
pt_BtnInfoExit:
	CLR.W	dat_ButtonScanIdx
	MOVE.W	#$0053,dat_ButtonScanMax
	MOVE.B	#$f8,dat_SongModifiedFlag3
	MOVE.L	#$ffffffff,dat_PrevTimeDays
	MOVE.L	#$ffffffff,dat_PrevTimeMins
	MOVE.L	#$ffffffff,dat_PrevTimeTicks
	JSR	pt_WaitMouseRelease
	BSR.S	pt_1224
	JSR	pt_InitAudioDisplay
	JMP	pt_LeaveToMain
pt_1224:
	LEA	dat_1466,A0
	JSR	pt_StoreModulePtr
	MOVEQ	#-1,D0
	RTS
pt_InputComment:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_1438,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BEQ.W	pt_1226
	CMP.W	#$0001,D2
	BEQ.S	pt_BtnInfoExit
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnInfoSwitch
	CMP.W	#$0003,D2
	BEQ.W	pt_JmpScreenHandler
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnInfoExit
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnInfoDown
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnInfoUp
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnInfoScroll
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnInfoLine01
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnInfoLine02
	CMP.W	#$0012,D2
	BEQ.W	pt_BtnInfoLine03
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnInfoLine04
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnInfoLine05
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnInfoLine06
	CMP.W	#$0016,D2
	BEQ.W	pt_BtnInfoLine07
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnInfoLine08
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnInfoLine09
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnInfoLine10
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnInfoLine11
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnInfoLine12
	CMP.W	#$001c,D2
	BEQ.W	pt_BtnInfoLine13
	CMP.W	#$001d,D2
	BEQ.W	pt_BtnInfoLine14
	CMP.W	#$001e,D2
	BEQ.W	pt_BtnInfoLine15
	CMP.W	#$001f,D2
	BEQ.W	pt_BtnInfoLine16
pt_1226:
	RTS
pt_1227:
	CLR.L	dat_SampleMixCounter
	CLR.W	dat_SampleMixVar
	BSR.W	pt_InitFileBuffers
pt_SampleListRefresh:
	LEA	str_UnnamedSong,A1
	CMPI.L	#$554e4e41,(A1)
	BNE.S	pt_1229
	MOVE.L	(dat_ModulePtr,PC),dat_TextStringPtr
	MOVE.W	#$046e,dat_TextBytePos
	MOVE.W	#$0014,dat_TextCharCount
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.S	pt_122A
pt_1229:
	MOVE.L	#str_UnnamedSong,dat_TextStringPtr
	MOVE.W	#$046e,dat_TextBytePos
	MOVE.W	#$0014,dat_TextCharCount
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_122A:
	BSR.W	pt_123B
	MOVE.W	#$0b4e,dat_TextBytePos
	LEA	dat_FileWorkBuf,A1
	MOVE.L	(A1),D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#4,dat_TextBytePos
	LEA	dat_FileWorkBuf,A1
	MOVE.L	(4,A1),D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#4,dat_TextBytePos
	LEA	dat_FileWorkBuf,A1
	MOVE.L	(8,A1),D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	ADDQ.W	#4,dat_TextBytePos
	LEA	dat_FileWorkBuf,A1
	MOVE.L	(12,A1),D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
pt_122B:
	MOVEA.W	#$03e9,A3
	CLR.L	dat_SampleMixCounter
	CLR.W	dat_SampleMixVar
	MOVEQ	#0,D7
	MOVEQ	#0,D5
	MOVE.W	dat_FileFlags,D5
	MOVE.L	D5,D6
	ADD.L	#$00000010,D6
	MOVEQ	#1,D4
pt_122C:
	MOVE.W	A3,dat_TextBytePos
	MOVEQ	#0,D0
	MOVE.W	D7,D0
	ADDQ.W	#1,D0
	CLR.W	dat_SampleMixVar2
	CMP.W	D5,D7
	BLT.S	pt_122D
	CMP.W	D6,D7
	BGE.S	pt_122D
	MOVE.W	#$0001,dat_SampleMixVar2
pt_122D:
	TST.W	dat_SampleMixVar2
	BEQ.S	pt_122E
	ADDA.W	#$01e0,A3
	MOVE.W	D0,dat_DisplayParam
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_Format2DigitHex
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_122E:
	BTST	#1,dat_FontMode
	BEQ.S	pt_122F
	BSET	#1,dat_FileStatus
	BCLR	#1,dat_FontMode
pt_122F:
	MOVE.W	D0,D1
	MOVEA.L	dat_ModulePtr,A0
	LEA	(-10,A0),A0
	MOVE.W	D1,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$0016,dat_TextCharCount
	TST.W	dat_SampleMixVar2
	BEQ.S	pt_1230
	MOVEM.L	D0-D7/A0-A6,-(A7)
	ADDQ.W	#2,dat_TextBytePos
	BSR.W	pt_DrawTextWithFill
	ADDQ.W	#4,dat_TextBytePos
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_1230:
	BTST	#1,dat_FileStatus
	BEQ.S	pt_1231
	BSET	#1,dat_FontMode
pt_1231:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	ADDA.W	#$0016,A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	LSL.L	#1,D0
	TST.L	D0
	BEQ.S	pt_1232
	ADDQ.W	#1,dat_SampleMixVar
pt_1232:
	ADD.L	D0,dat_SampleMixCounter
	TST.W	dat_SampleMixVar2
	BEQ.S	pt_1233
	BSR.W	pt_FormatNumToDecimal
pt_1233:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	TST.L	D4
	BEQ.S	pt_1234
	BSR.W	pt_124E
pt_1234:
	CMP.L	#$0000001e,D7
	BEQ.S	pt_1235
	ADDQ.L	#1,D7
	BRA.W	pt_122C
pt_1235:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$1ff2,dat_TextBytePos
	MOVE.L	dat_SampleMixCounter,D0
	BSR.W	pt_FormatNumToDecimal
	MOVE.W	#$1920,dat_TextBytePos
	MOVE.W	dat_SampleMixVar,dat_DisplayParam
	BSR.W	pt_Format2DigitHex
	MOVE.W	#$1c82,dat_TextBytePos
	MOVE.L	dat_TimeAuxVal,D0
	SUB.L	dat_SampleMixCounter,D0
	BSR.W	pt_FormatNumToDecimal
	MOVE.W	#$2362,dat_TextBytePos
	MOVE.L	dat_TimeAuxVal,D0
	BSR.W	pt_FormatNumToDecimal
	MOVE.W	#$1915,dat_TextBytePos
	MOVE.L	dat_TimeAuxVal,D0
	SUB.L	dat_SampleMixCounter,D0
	SUB.L	#$0000043c,D0
	LSR.L	#8,D0
	LSR.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_1236
	LSR.L	#1,D0
pt_1236:
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_DrawTempoStr
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_SampleMixCounter:
	DS.L	1
dat_SampleMixVar:
	DS.W	1
dat_SampleMixVar2:
	DS.W	1
pt_RefreshSampleInfo:
	CMPI.W	#$0008,dat_UIMode
	BNE.S	pt_123C
pt_123B:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_songlen,A0),A0
	CLR.W	dat_DisplayParam
	MOVE.B	(A0),dat_ButtonStateFlag
	MOVE.W	#$2373,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	ADDA.L	dat_BplUpdateReq,A0
	CLR.B	dat_DisplayParam
	MOVE.B	(A0),dat_ButtonStateFlag
	MOVE.B	(A0),dat_PatSyncFlag
	MOVEQ	#0,D1
	MOVE.B	(A0),D1
	MOVE.W	#$2003,dat_TextBytePos
	MOVE.B	(A0),dat_ChannelSolo
	BSR.W	pt_FormatDecimal
	MOVE.W	dat_CurrentPattern,dat_DisplayParam
	MOVE.W	#$1c93,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	MOVEM.L	(A7)+,D0-D7/A0-A6
pt_123C:
	RTS
pt_BtnInfoLine01:
	MOVEQ	#1,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine02:
	MOVEQ	#2,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine03:
	MOVEQ	#3,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine04:
	MOVEQ	#4,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine05:
	MOVEQ	#5,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine06:
	MOVEQ	#6,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine07:
	MOVEQ	#7,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine08:
	MOVEQ	#8,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine09:
	MOVEQ	#9,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine10:
	MOVEQ	#10,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine11:
	MOVEQ	#11,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine12:
	MOVEQ	#12,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine13:
	MOVEQ	#13,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine14:
	MOVEQ	#14,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine15:
	MOVEQ	#15,D0
	BRA.S	pt_EditModeSetup
pt_BtnInfoLine16:
	MOVEQ	#16,D0
	BRA.W	pt_EditModeSetup
pt_EditModeSetup:
	MOVE.L	D0,-(A7)
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVE.L	(A7)+,D0
	MOVEA.L	dat_ModulePtr,A6
	LEA	(-10,A6),A6
	MOVE.L	D0,D7
	ADD.W	dat_FileFlags,D7
	MULU	#s_SIZEOF,D7
	ADDA.L	D7,A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$00000015,dat_SongDataAddr
	MOVE.W	#$0016,dat_TextCharCount
	MOVEA.L	#$0000002d,A4
	SUBQ.L	#1,D0
	MULU	#$0006,D0
	ADD.L	#$0000000c,D0
	MULU	#$0050,D0
	ADDA.L	D0,A4
	JSR	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JSR	pt_RestorePalette
	BSR.W	pt_122B
	RTS
pt_124E:
	LEA	str_UnnamedAuthor,A1
	CMPI.L	#$554e4e41,(A1)
	BNE.W	pt_1252
	MOVE.W	dat_TextStringPtr,dat_FileMode
	MOVEQ	#20,D0
	CMPI.W	#$0001,dat_SampleMixIdx
	BEQ.S	pt_SampleMixExit
pt_124F:
	MOVE.B	(0,A0,D0.W),D1
	LSL.W	#8,D1
	MOVE.B	(1,A0,D0.W),D1
	CMP.W	#$4259,D1
	BEQ.W	pt_1253
	CMP.W	#$6279,D1
	BEQ.W	pt_1253
	CMP.W	#$2863,D1
	BEQ.S	pt_SampleMixExit
	CMP.W	#$2843,D1
	BEQ.S	pt_SampleMixExit
	LSR.W	#8,D1
	CMP.B	#$23,D1
	BEQ.S	pt_SampleMixExit
	CMP.B	#$2f,D1
	BEQ.S	pt_SampleMixExit
pt_LoopEndDecrement:
	DBF	D0,pt_124F
	MOVE.W	dat_FileMode,dat_TextStringPtr
	RTS
pt_SampleMixExit:
	CLR.W	dat_SampleMixIdx
	MOVEQ	#0,D4
	MOVE.W	#$07de,dat_TextBytePos
	MOVE.L	A0,dat_TextStringPtr
	MOVE.W	#$0016,dat_TextCharCount
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.W	dat_FileMode,dat_TextStringPtr
	RTS
pt_1252:
	MOVE.W	#$07de,dat_TextBytePos
	MOVE.L	#str_UnnamedAuthor,dat_TextStringPtr
	MOVE.W	#$0016,dat_TextCharCount
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.W	dat_FileMode,dat_TextStringPtr
	RTS
pt_1253:
	TST.L	D0
	BEQ.S	pt_1254
	CMPI.B	#$20,(-1,A0,D0.W)
	BNE.W	pt_LoopEndDecrement
pt_1254:
	JSR	pt_AuthorWord41
	BEQ.S	pt_SetEditWriteFlag
	CMP.W	#$2000,D1
	BEQ.S	pt_SetEditWriteFlag
	CMP.W	#$2020,D1
	BEQ.S	pt_SetEditWriteFlag
	CMP.W	#$2e2e,D1
	BEQ.S	pt_SetEditWriteFlag
	NOP
	NOP
	CMP.W	#$0013,D0
	BGE.S	pt_SetEditWriteFlag
	CMPI.B	#$20,(2,A0,D0.W)
	BNE.W	pt_LoopEndDecrement
	BRA.W	pt_SampleMixExit
pt_SetEditWriteFlag:
	MOVE.W	#$0001,dat_SampleMixIdx
	BRA.W	pt_LoopEndDecrement
dat_SampleMixIdx:
	DS.W	1
pt_BtnInfoSwitch:
	CMPI.W	#$000f,dat_FileFlags
	BNE.S	pt_1258
	CLR.W	dat_FileFlags
	BRA.S	pt_1259
	DC.W	$5279
	DC.L	dat_FileFlags
pt_1258:
	MOVE.W	#$000f,dat_FileFlags
pt_1259:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_SampleListRefresh
	MOVEM.L	(A7)+,D0-D7/A0-A6
	CLR.B	dat_KeyCode
	CLR.W	dat_KeyBufCount
	BSR.W	pt_SampleEditDrawUpdate
	RTS
pt_BtnInfoUp:
	TST.W	dat_FileFlags
	BEQ.S	pt_125B
	BSR.W	pt_SampleEditDrawUpdate
	SUBQ.W	#1,dat_FileFlags
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_SampleListRefresh
	MOVEM.L	(A7)+,D0-D7/A0-A6
	CLR.W	dat_KeyBufCount
	JSR	pt_RefreshDisplay
pt_125B:
	RTS
pt_BtnInfoDown:
	CMPI.W	#$000f,dat_FileFlags
	BEQ.S	pt_125D
	BSR.W	pt_SampleEditDrawUpdate
	ADDQ.W	#1,dat_FileFlags
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_SampleListRefresh
	MOVEM.L	(A7)+,D0-D7/A0-A6
	CLR.W	dat_KeyBufCount
	JSR	pt_RefreshDisplay
pt_125D:
	RTS
dat_FileWorkBuf:
	DS.L	1
dat_125F:
	DS.L	1
dat_1260:
	DS.L	1
dat_1261:
	DS.L	1
dat_FileFlags:
	DS.W	1
dat_FileHandle:
	DS.L	1
dat_FileMode:
	DS.W	1
dat_FileStatus:
	DS.W	1
dat_PalEdColorPos:
	DS.W	1
dat_PalEdColorMax:
	DS.W	1
pt_PalEditorColors:
	DC.W	$0022
pt_BtnInfoScroll:
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.W	dat_PalEdSelectPos,D1
	MOVE.W	(dat_PalEdColorPos,PC),D0
	ADD.W	#$0018,D0
	SUB.W	D0,D1
	BMI.W	pt_126E
	CMP.W	(dat_PalEdColorMax,PC),D1
	BPL.W	pt_1270
	MOVE.W	D1,D2
	MOVE.W	#$0053,D4
	SUB.W	(dat_PalEdColorMax,PC),D4
	BSR.W	pt_1274
	MOVE.W	dat_PalEdSelectPos,D1
pt_126A:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_126D
	MOVE.W	D1,D3
	MOVE.W	dat_PalEdSelectPos,D1
	CMP.W	D1,D3
	BEQ.S	pt_126A
	SUB.W	D2,D1
	SUB.W	#$0018,D1
	BPL.S	pt_126B
	MOVEQ	#0,D1
pt_126B:
	CMP.W	D4,D1
	BMI.S	pt_126C
	MOVE.W	D4,D1
pt_126C:
	MOVE.W	D1,dat_PalEdColorPos
	BSR.W	pt_1272
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(pt_PalEditorColors,PC),D0
	SUB.W	#$0013,D0
	MULU	(dat_PalEdColorPos,PC),D0
	MOVE.W	#$0053,D1
	SUB.W	(dat_PalEdColorMax,PC),D1
	DIVU	D1,D0
	MOVE.W	D0,dat_FileFlags
	BSR.W	pt_SampleListRefresh
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LMB
	BEQ.S	pt_126A
pt_126D:
	BSR.S	pt_1273
	RTS
pt_126E:
	SUBI.W	#$0013,dat_FileFlags
	BPL.S	pt_126F
	CLR.W	dat_FileFlags
pt_126F:
	BSR.W	pt_SampleEditDrawUpdate
	MOVE.W	(dat_FileFlags,PC),D0
	BSR.W	pt_SampleListRefresh
	RTS
pt_1270:
	ADDI.W	#$0013,dat_FileFlags
	MOVE.W	(pt_PalEditorColors,PC),D0
	SUB.W	#$0013,D0
	CMP.W	(dat_FileFlags,PC),D0
	BPL.S	pt_1271
	MOVE.W	D0,dat_FileFlags
pt_1271:
	BSR.S	pt_SampleEditDrawUpdate
	MOVE.W	(dat_FileFlags,PC),D0
	BSR.W	pt_SampleListRefresh
	RTS
pt_1272:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEdColorPos,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_PalEdColorMax,PC),D2
	LEA	dat_SongModifiedFlag2,A0
	BSR.W	pt_DrawSprite
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_1273:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEdColorPos,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_PalEdColorMax,PC),D2
	BSR.W	pt_PalColorShadeTab
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_1274:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEdColorPos,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_PalEdColorMax,PC),D2
	BSR.W	pt_InitHwPalette
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_SampleEditDrawUpdate:
	MOVEM.L	D0-D3,-(A7)
	MOVEQ	#0,D3
	MOVE.W	#$0053,dat_PalEdColorMax
	CLR.W	dat_PalEdColorPos
	MOVEQ	#83,D0
	CLR.W	D1
	CMPI.W	#$0013,pt_PalEditorColors
	BMI.S	pt_1276
	BEQ.S	pt_1276
	MOVE.W	#$0629,D0
	MOVE.W	(pt_PalEditorColors,PC),D1
	EXT.L	D0
	DIVU	D1,D0
	MOVE.W	D0,dat_PalEdColorMax
	MOVE.W	(dat_FileFlags,PC),D1
	MOVE.W	(pt_PalEditorColors,PC),D2
	MOVE.W	#$0053,D3
	SUB.W	D0,D3
	MULU	D1,D3
	SUB.W	#$0013,D2
	DIVU	D2,D3
	MOVE.W	D3,dat_PalEdColorPos
pt_1276:
	MOVE.W	(dat_PalEdColorPos,PC),D3
	ADD.W	(dat_PalEdColorMax,PC),D3
	CMP.W	#$0053,D3
	BMI.S	pt_1277
	MOVEQ	#83,D3
pt_1277:
	SUB.W	(dat_PalEdColorMax,PC),D3
	MOVE.W	D3,dat_PalEdColorPos
	BSR.W	pt_1273
	MOVEM.L	(A7)+,D0-D3
	RTS
dat_LastSampleNum:
	DS.W	1
dat_NumSamples:
	DS.W	1
dat_CurrentSample:
	DS.W	1
dat_SamplePlayInit:
	DC.W	$0001
dat_SamplePlayMode:
	DS.B	1
dat_127D:
	DC.B	$01
dat_RpPatternPos:
	DS.L	1
dat_RpSongPos:
	DS.L	1
dat_RpCounter:
	DS.L	1
dat_PatBaseAddr:
	DS.L	1
dat_ModulePtr:
	DS.L	1
dat_RpSampleStarts:
	DS.L	64
dat_StackPointer:
	DS.L	4
dat_SampleEditorX:
	DS.W	1
dat_SampleEditorY:
	DS.W	1
dat_SampleEditorPtr:
	DS.L	1
dat_PatternIndexBuf:
	DS.L	1
dat_UIMode:
	DC.W	$0001
dat_PaletteSave0:
	DS.W	1
dat_PaletteSave1:
	DS.W	1
dat_PaletteSave2:
	DS.W	1
dat_SampleEditValue:
	DS.B	1
dat_TempoChanged:
	DS.B	1
dat_SampleScrollIdx:
	DS.W	1
dat_SampleScrollBuf:
	DS.L	33
	DS.W	1
dat_VBlankCounter:
	DS.B	1
dat_EditInputLock:
	DS.B	1
	DS.L	15
dat_PlayMode:
	DS.W	1
dat_TempBufPtr:
	DS.L	1
dat_MagicNumber:
	DC.L	$12345678
dat_PatternBufPtr2:
	DS.L	1
dat_SpeedResetVar:
	DS.W	1
dat_CurrentSpeed:
	DS.W	1
dat_EffectVarA:
	DS.W	1
dat_129A:
	DS.B	1
dat_129B:
	DS.B	1
dat_FileSizeVar:
	DS.W	1
dat_FileLengthVar:
	DS.W	1
dat_EditCursorVar:
	DS.W	1
dat_EditModeVar:
	DS.W	1
dat_RamTestPattern:
	DS.L	1
	DC.L	$53545354
	DC.W	$5354
dat_UndoHeader:
	DS.L	1
dat_12A2:
	DS.L	1
dat_UndoBufPtr:
	DS.L	1
dat_UndoBufSize:
	DS.L	1
dat_OldSamplePtr:
	DS.L	1
dat_OldSampleSize:
	DS.L	1
dat_EditBufPtr:
	DS.L	1
dat_EditBufX:
	DS.W	1
dat_EditBufY:
	DS.W	1
dat_EditBufLen:
	DS.W	1
dat_EditFieldBufPtr:
	DS.L	1
dat_EditFieldPos:
	DS.W	1
dat_EditFieldBuf:
	DS.L	14
dat_12AE:
	DC.W	$0001
dat_SongChangedMagic:
	DS.L	1
dat_RpVibratoTable:
	DC.L	$0018314a,$61788da1,$b4c5d4e0,$ebf4fafd
	DC.L	$fffdfaf4,$ebe0d4c5,$b4a18d78,$614a3118
str_EmptyLine:
	DC.B	"ALL RIGHT",0
	DC.B	"THE DISK IS WRITEPROTECTED!",0
	DC.B	"PRINT ABORTED!",0
	DC.B	"ENTER DATA",0
	DC.B	"DISK ERROR!!",0
dat_12B2:
	DC.B	"PLST IS FULL!",0
dat_12B3:
	DC.B	"PRINT ABORTED!",0
dat_12B4:
	DC.B	"ENTER DATA",0
dat_12B5:
	DC.B	"ADDING PATH...",0
	DC.B	"DISK ERROR!!",0
dat_12B6:
	DC.B	"LOADING..",0
dat_12B7:
	DC.B	"LOADING SONG...",0
dat_12B8:
	DC.B	"CONVERTING MODULE...",0
pt_PaletteEditEntry:
	DC.B	"LOADING MODULE..",0
	DC.B	"LOADING SAMPLE...",0
dat_12BA:
	DC.B	"LOADING PATTERN...",0
dat_12BB:
	DC.B	"NO PROTRACKER PRO PATTERN!",0
dat_12BC:
	DC.B	"LOADING TRACK...",0
dat_12BD:
	DC.B	"NO PROTRACKER PRO TRACK!",0
	DC.B	"SAVING...",0
	DC.B	"SAVING SONG",0
dat_12BE:
	DC.B	"SAVING MODULE...",0
dat_12BF:
	DC.B	"SAVING YOUR SAMPLE...",0
dat_12C0:
	DC.B	"SAVING EXECUTABLE...",0
dat_12C1:
	DC.B	"SAVING PATTERN...",0
dat_12C2:
	DC.B	"SAVING TRACK...",0
dat_12C3:
	DC.B	"LOADING PLST",0
dat_12C4:
	DC.B	"SAVING PLST",0
dat_12C5:
	DC.B	"DELETING FILE...",0
dat_12C6:
	DC.B	"RENAMING FILE..",0
dat_12C7:
	DC.B	"DECRUNCHING...",0
dat_12C8:
	DC.B	"CRUNCHING...",0
dat_12C9:
	DC.B	"SELECT ENTRY BELOW IN LIST",0
dat_12CA:
	DC.B	"SELECT SONG",0
dat_12CB:
	DC.B	"SELECT EXECUTABLE",0
dat_12CC:
	DC.B	"SELECT MODULE",0
dat_12CD:
	DC.B	"SELECT SAMPLE",0
dat_12CE:
	DC.B	"SELECT PATTERN",0
dat_12CF:
	DC.B	"SELECT TRACK",0
dat_12D0:
	DC.B	"SELECT FILE TO RENAME",0
dat_12D1:
	DC.B	"SELECT FILE TO DELETE!",0
dat_12D2:
	DC.B	"READING DIR...",0
dat_12D3:
	DC.B	"POSITION NOW SET",0
dat_12D4:
	DC.B	"PRINTING SONG...",0
dat_12D5:
	DC.B	"PRINTING PLST",0
dat_12D6:
	DC.B	10,10
	DC.B	"   Do you want to save",10
	DC.B	"       the song?",0
dat_12D7:
	DC.B	10,10
	DC.B	"   Do you want to save",10
	DC.B	"     the pattern?",0
dat_12D8:
	DC.B	10,10
	DC.B	"   Do you want to save",10
	DC.B	"     the Track?",0
dat_12D9:
	DC.B	10,10
	DC.B	"   Do you want to save",10
	DC.B	"     as executable?",0
dat_12DA:
	DC.B	10,10
	DC.B	"  Delete this file?",0
dat_12DB:
	DC.B	10,10
	DC.B	"  Do you want to save",10
	DC.B	"      the module?",0
dat_12DC:
	DC.B	10,10
	DC.B	"   Print presetlist ?",0
dat_12DD:
	DC.B	10,10
	DC.B	"  Do you want to print",10
	DC.B	"      the song?",0
dat_12DE:
	DC.B	10,10
	DC.B	"   Are you sure you",10
	DC.B	"    want to quit ?",0
dat_12DF:
	DC.B	10,10
	DC.B	"   Your Module is changed!",10
	DC.B	"   Do you really want to",10
	DC.B	"        loose it?",0
dat_12E0:
	DC.B	10,10
	DC.B	"  Do you want to change",10
	DC.B	"the actual patternmode?",10
	DC.B	"This clears all datas !",0
dat_12E1:
	DC.B	10,10
	DC.B	" Toggle 4/8 channel mode?",10
	DC.B	"Module data will be lost.",0
dat_12E2:
	DC.B	10,10
	DC.B	"   Are you sure you want",10
	DC.B	" to repair actual module?",0
dat_12E3:
	DC.B	10,10
	DC.B	"    This function works",10
	DC.B	"  only in 4 channel mode",10
	DC.B	"  at the current version.",0
dat_12E4:
	DC.B	10,10
	DC.B	"   Save all samples",10
	DC.B	"   to current samplepath?",0
dat_12E5:
	DC.B	10,10
	DC.B	"     Upsample?",0
dat_12E6:
	DC.B	10,10
	DC.B	"     Downsample?",0
dat_12E7:
	DC.B	10,10
	DC.B	"     Clear split",10
	DC.B	"    and transpose?",0
dat_12E8:
	DC.B	10,10
	DC.B	"Reset the configuration?",0
dat_12E9:
	DC.B	10,10
	DC.B	"    Delete preset ?",0
dat_12EA:
	DC.B	10,10
	DC.B	"   Load presetlist?",0
dat_12EB:
	DC.B	10,10
	DC.B	"   Save presetlist?",0
dat_12EC:
	DC.B	10,10
	DC.B	"   Kill this sample?",0
dat_12ED:
	DC.B	10,10
	DC.B	"    Abort loading?",0
dat_12EE:
	DC.B	10,10
	DC.B	"   Load configuration?",0
dat_12EF:
	DC.B	10,10
	DC.B	"  Save configuration?",0
	DC.B	10,10
	DC.B	"   Old configuration!",10
	DC.B	"      Load anyway?",0
	DC.B	"Disk formatin progressFormatting cyl ",0
	DC.B	"Verifying  cyl ",0
	DC.B	"Initializing",0,0
dat_SamplePathFmt:
	DC.L	$53542d30,$303a5361,$6d706c65,$73000000
	DS.L	9
dat_12F1:
	DC.W	$5354
dat_12F2:
	DC.B	$2d
dat_ZeroCharBuf:
	DC.B	$30
dat_TimeFormatStr:
	DC.W	$313a
dat_SpacePadding:
	DC.W	$2020
	DC.B	$20
dat_12F6:
	DC.B	$20
	DC.W	$2020
dat_12F7:
	DC.B	"                 "
dat_12F8:
	DC.B	$20
	DC.W	$2020
dat_12F9:
	DC.B	"     "
dat_12FA:
	DC.B	"     "
dat_12FB:
	DC.L	$20202020
dat_12FC:
	DC.B	"ST-01:                  0 0000 0000 0002"
dat_12FD:
	DC.B	"No.    Samplename               Length  Repeat  RepLen",10,10
dat_12FE:
	DC.B	"    :  "
dat_12FF:
	DC.B	"                             "
dat_1300:
	DC.B	"        "
dat_1301:
	DC.B	"        "
dat_1302:
	DC.W	$0a00
dat_1303:
	DC.B	9,"Protracker Song-Dump -- Made with Protracker Pro  ",13,10,10
	DC.B	9,"Songname:  "
dat_1304:
	DC.W	$0d0a
dat_1305:
	DC.W	$0c00
dat_1306:
	DC.B	9,9,9,"Pattern: "
dat_1307:
	DC.B	$30
dat_1308:
	DC.B	"0",13,10
	DC.B	13,10
dat_1309:
	DC.B	$09
dat_130A:
	DC.B	$30
dat_130B:
	DC.L	$30203a20
dat_130C:
	DC.B	"                        0000"
dat_130D:
	DC.B	"  0000"
dat_130E:
	DC.B	"  0000"
dat_130F:
	DC.B	"    ",13,10
dat_1310:
	DC.B	"        ",0
dat_1311:
	DC.B	"00  :                                                       "
dat_1312:
	DC.B	"    ",0
	DC.B	"                       ",0
dat_1313:
	DC.W	$5354
dat_1314:
	DC.B	$2d
dat_SongInfoFlag:
	DS.B	1
dat_1316:
	DC.W	$003a
dat_1317:
	DC.W	$5354
dat_1318:
	DC.B	$2d
dat_ModuleNameFlag:
	DS.B	1
dat_131A:
	DC.W	$003a
dat_131B:
	DC.W	$5354
dat_131C:
	DC.B	$2d
dat_SampleNameFlag:
	DS.B	1
dat_131E:
	DC.L	$003a5354
	DC.B	$2d
dat_131F:
	DS.B	1
dat_1320:
	DC.W	$003a
dat_1321:
	DC.B	"trackdisk.device",0
dat_1322:
	DC.B	"input.device",0
dat_HexPairTable:
	DC.B	$30
str_NoteNames:
	DC.B	"00102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E"
	DC.B	"1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3"
	DC.B	"D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B"
	DC.B	"5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797"
	DC.B	"A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798"
	DC.B	"999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B"
	DC.B	"7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5"
	DC.B	"D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F"
	DC.B	"4F5F6F7F8F9FAFBFCFDFEFF"
dat_1325:
	DC.L	$0a010203,$04050607,$08092035,$33221223
dat_1326:
	DC.L	$31213222,$33342435,$25362637,$38283929
	DC.L	$3a100211,$03121305,$14061507,$16170918
	DC.L	$0a191a0c,$1b464600
dat_PlaySongAddr:
	DC.L	$00010203,$04050607,$08090a0b,$0c0d0e0f
	DC.L	$100c0d0e,$0f101112,$13141516,$1718191a
	DC.L	$1b1c1d1e
	DC.W	$1f24
	DC.B	$24
dat_PlayPatAddr:
	DC.B	$0c
	DC.L	$0d0e0f10,$11121314,$15161718,$191a1b1c
	DC.L	$18191a1b,$1c1d1e1f,$20212223,$24242424
	DC.L	$24242424
	DC.W	$2424
pt_PatternRenderEntry:
	DC.B	"C-1 C#1 D-1 D#1 E-1 F-1 F#1 G-1 G#1 A-1 A#1 B-1 C-2 C#2 D-2 D"
	DC.B	"#2 E-2 F-2 F#2 G-2 G#2 A-2 A#2 B-2 C-3 C#3 D-3 D#3 E-3 F-3 F#"
	DC.B	"3 G-3 G#3 A-3 A#3 B-3 "
dat_DashSeparator:
	DC.L	$2d2d2d20
dat_132B:
	DC.B	"C-1 D^1 D-1 E^1 E-1 F-1 G^1 G-1 A^1 A-1 B^1 B-1 C-2 D^2 D-2 E"
	DC.B	"^2 E-2 F-2 G^2 G-2 A^2 A-2 B^2 B-2 C-3 D^3 D-3 E^3 E-3 F-3 G^"
	DC.B	"3 G-3 A^3 A-3 B^3 B-3 --- "
dat_PeriodTable:
	DC.L	$03580328,$02fa02d0,$02a60280,$025c023a
	DC.L	$021a01fc,$01e001c5,$01ac0194,$017d0168
	DC.L	$01530140,$012e011d,$010d00fe,$00f000e2
	DC.L	$00d600ca,$00be00b4,$00aa00a0,$0097008f
	DC.L	$0087007f,$00780071,$00000352,$032202f5
	DC.L	$02cb02a2,$027d0259,$02370217,$01f901dd
	DC.L	$01c201a9,$0191017b,$01650151,$013e012c
	DC.L	$011c010c,$00fd00ef,$00e100d5,$00c900bd
	DC.L	$00b300a9,$009f0096,$008e0086,$007e0077
	DC.L	$00710000,$034c031c,$02f002c5,$029e0278
	DC.L	$02550233,$021401f6,$01da01bf,$01a6018e
	DC.L	$01780163,$014f013c,$012a011a,$010a00fb
	DC.L	$00ed00e0,$00d300c7,$00bc00b1,$00a7009e
	DC.L	$0095008d,$0085007d,$00760070,$00000346
	DC.L	$031702ea,$02c00299,$02740250,$022f0210
	DC.L	$01f201d6,$01bc01a3,$018b0175,$0160014c
	DC.L	$013a0128,$01180108,$00f900eb,$00de00d1
	DC.L	$00c600bb,$00b000a6,$009d0094,$008c0084
	DC.L	$007d0076,$006f0000,$03400311,$02e502bb
	DC.L	$0294026f,$024c022b,$020c01ef,$01d301b9
	DC.L	$01a00188,$0172015e,$014a0138,$01260116
	DC.L	$010600f7,$00e900dc,$00d000c4,$00b900af
	DC.L	$00a5009c,$0093008b,$0083007c,$0075006e
	DC.L	$0000033a,$030b02e0,$02b6028f,$026b0248
	DC.L	$02270208,$01eb01cf,$01b5019d,$01860170
	DC.L	$015b0148,$01350124,$01140104,$00f500e8
	DC.L	$00db00ce,$00c300b8,$00ae00a4,$009b0092
	DC.L	$008a0082,$007b0074,$006d0000,$03340306
	DC.L	$02da02b1,$028b0266,$02440223,$020401e7
	DC.L	$01cc01b2,$019a0183,$016d0159,$01450133
	DC.L	$01220112,$010200f4,$00e600d9,$00cd00c1
	DC.L	$00b700ac,$00a3009a,$00910089,$0081007a
	DC.L	$0073006d,$0000032e,$030002d5,$02ac0286
	DC.L	$0262023f,$021f0201,$01e401c9,$01af0197
	DC.L	$0180016b,$01560143,$01310120,$01100100
	DC.L	$00f200e4,$00d800cc,$00c000b5,$00ab00a1
	DC.L	$00980090,$00880080,$00790072,$006c0000
	DC.L	$038b0358,$032802fa,$02d002a6,$0280025c
	DC.L	$023a021a,$01fc01e0,$01c501ac,$0194017d
	DC.L	$01680153,$0140012e,$011d010d,$00fe00f0
	DC.L	$00e200d6,$00ca00be,$00b400aa,$00a00097
	DC.L	$008f0087,$007f0078,$00000384,$03520322
	DC.L	$02f502cb,$02a3027c,$02590237,$021701f9
	DC.L	$01dd01c2,$01a90191,$017b0165,$0151013e
	DC.L	$012c011c,$010c00fd,$00ee00e1,$00d400c8
	DC.L	$00bd00b3,$00a9009f,$0096008e,$0086007e
	DC.L	$00770000,$037e034c,$031c02f0,$02c5029e
	DC.L	$02780255,$02330214,$01f601da,$01bf01a6
	DC.L	$018e0178,$0163014f,$013c012a,$011a010a
	DC.L	$00fb00ed,$00df00d3,$00c700bc,$00b100a7
	DC.L	$009e0095,$008d0085,$007d0076,$00000377
	DC.L	$03460317,$02ea02c0,$02990274,$0250022f
	DC.L	$021001f2,$01d601bc,$01a3018b,$01750160
	DC.L	$014c013a,$01280118,$010800f9,$00eb00de
	DC.L	$00d100c6,$00bb00b0,$00a6009d,$0094008c
	DC.L	$0084007d,$00760000,$03710340,$031102e5
	DC.L	$02bb0294,$026f024c,$022b020c,$01ee01d3
	DC.L	$01b901a0,$01880172,$015e014a,$01380126
	DC.L	$01160106,$00f700e9,$00dc00d0,$00c400b9
	DC.L	$00af00a5,$009c0093,$008b0083,$007b0075
	DC.L	$0000036b,$033a030b,$02e002b6,$028f026b
	DC.L	$02480227,$020801eb,$01cf01b5,$019d0186
	DC.L	$0170015b,$01480135,$01240114,$010400f5
	DC.L	$00e800db,$00ce00c3,$00b800ae,$00a4009b
	DC.L	$0092008a,$0082007b,$00740000,$03640334
	DC.L	$030602da,$02b1028b,$02660244,$02230204
	DC.L	$01e701cc,$01b2019a,$0183016d,$01590145
	DC.L	$01330122,$01120102,$00f400e6,$00d900cd
	DC.L	$00c100b7,$00ac00a3,$009a0091,$00890081
	DC.L	$007a0073,$0000035e,$032e0300,$02d502ac
	DC.L	$02860262,$023f021f,$020101e4,$01c901af
	DC.L	$01970180,$016b0156,$01430131,$01200110
	DC.L	$010000f2,$00e400d8,$00cb00c0,$00b500ab
	DC.L	$00a10098,$00900088,$00800079,$00720000
	DC.L	$00050607,$080a0b0d,$1013161a,$202b4080
dat_CursorPosMap:
	DC.L	$080e1012,$14161a20,$22242628,$2c323436
	DC.L	$383a3e44,$46484a4c,$5056585a,$5c5e6268
	DC.L	$6a6c6e70,$747a7c7e,$8082868c,$8e909294
dat_132E:
	DC.L	$60313233,$34353637,$383930df,$275c2a30
	DC.L	$71776572,$747a7569,$6f70fc2b,$2a313233
	DC.L	$61736466,$67686a6b,$6cf6e423,$00343536
	DC.L	$3c797863,$76626e6d,$2c2e2d00,$2e373839
	DC.B	$20
dat_132F:
	DC.B	$7e
	DC.L	$2122a724,$25262f28,$293d3f60,$7c2a3051
	DC.L	$57455254,$5a55494f,$50dc2a2a,$31323341
	DC.L	$53444647,$484a4b4c,$d6415e00,$3435363e
	DC.L	$59584356,$424e4d3b,$3a5f002e,$37383920
dat_1330:
	DC.B	"`1234567890-=\*0qwertyuiop[]*123asdfghjkl;'#",0
	DC.B	"456<zxcvbnm,./",0
	DC.B	".789 "
dat_1331:
	DC.B	"~!@#$%^&*()_+|*0QWERTYUIOP{}*123ASDFGHJKL:""^",0
	DC.B	"456>ZXCVBNM<>?",0
	DC.B	".789 "
dat_1332:
	DC.B	"LOADING SAMPLE...",0
dat_1333:
	DC.B	"NO FIBONACCI COMPRESSION!",0
dat_1334:
	DC.B	"ONLY 1 OCTAVE SAMPLES!",0
dat_1335:
	DC.B	"BODY NOT FOUND!",0
dat_1336:
	DC.B	"NOT AN 8SVX FILE!",0
	DC.B	"VHDR NOT FOUND!",0
dat_1337:
	DC.B	"NOT A 16 BIT MONO SAMPLE!",0
dat_1338:
	DC.B	"UPSAMPLING MAESTRO FILE!",0
dat_1339:
	DC.B	"COULD NOT ALLOCATE CHIP!",0
dat_133A:
	DC.B	"COULD NOT ALLOCATE DYN!",0
dat_133B:
	DC.B	"COULD NOT ALLOCATE PUB!",0
dat_133C:
	DC.B	"UNDYNNING...",0
	DC.B	"IFF HEADER INFORMATION:",10
	DC.B	"NAME: "
dat_133D:
	DC.B	"                    ",10
	DC.B	"AUTH: "
dat_133E:
	DC.B	"                    ",10
	DC.B	"COPY: "
dat_133F:
	DC.B	"                    ",10
	DC.B	"ANNO: "
dat_1340:
	DC.B	"                    ",10
	DC.B	"DYN : "
dat_1341:
	DC.B	"                    ",0
dat_1342:
	DC.B	"- Not available -",0,0
dat_1343:
	DC.L	$56484452
	DC.L	dat_0995
	DC.L	$4e414d45
	DC.L	dat_0996
	DC.L	$41555448
	DC.L	dat_0997
	DC.L	$414e4e4f
	DC.L	dat_0999
	DC.L	$28632920
	DC.L	dat_0998
	DC.L	$44594e20
	DC.L	dat_0994
	DC.L	$424f4459
	DC.L	dat_0993
	DS.L	2
dat_DiskListPtr:
	DS.L	1
dat_DiskListPos:
	DS.L	1
dat_1346:
	DS.L	1
dat_PatTablePtr:
	DS.L	1
dat_PatTablePtr2:
	DS.L	1
dat_1349:
	DS.L	1
dat_134A:
	DS.L	1
dat_134B:
	DS.L	1
dat_134C:
	DS.W	1
dat_PatDataVar2:
	DS.L	1
dat_PatDataVar1:
	DS.L	1
dat_SamplePtrBuf1:
	DS.L	1
dat_SamplePtrBuf2:
	DS.L	1
dat_1351:
	DS.L	1
dat_SongDataBufPtr:
	DS.L	1
dat_SongLengthPtr:
	DS.L	1
dat_AudioFlag1:
	DS.B	1
dat_SongTypeFlag:
	DS.B	1
dat_ChannelMaskVar:
	DS.W	1
dat_RpChunkedSamples:
	DS.L	1
dat_AudioChannelPtrs:
	DC.L	dat_14CC
	DC.L	dat_14CD
	DC.L	dat_14CE
	DC.L	dat_14CF
dat_RpMasterVol:
	DC.W	$8200
dat_NoteNamesPtr:
	DS.L	1
dat_SpriteBufAddr:
	DS.L	1
dat_135C:
	DS.L	1
dat_135D:
	DS.L	1
dat_135E:
	DS.L	1
dat_135F:
	DS.L	1
dat_BplPtr1:
	DS.L	1
dat_BplPtr2:
	DS.L	1
dat_BplPtr3:
	DS.L	1
dat_BplPtr4:
	DS.L	1
dat_RowCounter:
	DS.W	1
dat_1365:
	DS.W	1
dat_1366:
	DS.L	1
dat_SongDataPtr:
	DS.L	1
dat_RpPlayMode:
	DS.L	1
dat_ModuleChanged:
	DS.L	1
dat_ScreenBuf2Ptr:
	DS.L	1
dat_TextBytePos:
	DS.W	1
dat_TextCharCount:
	DS.W	1
dat_TextStringPtr:
	DS.L	1
dat_PatTableIdx:
	DS.W	1
dat_136F:
	DS.B	1
dat_1370:
	DS.B	1
dat_1371:
	DS.W	1
dat_BplUpdateBuf:
	DS.L	1
dat_BplUpdateReq:
	DS.W	1
dat_CurrentPattern:
	DS.W	1
dat_RpSpeed:
	DS.W	1
dat_RpSpeedLo:
	DS.W	1
dat_PlayModePtr:
	DS.L	1
dat_SongSpeed:
	DS.W	1
dat_KeyCode:
	DS.W	1
dat_PatJumpFlag:
	DS.W	1
dat_PlaybackActive:
	DS.W	1
dat_TimingMode:
	DS.W	1
dat_RecordMode:
	DS.W	1
dat_PlaybackEnable:
	DC.W	$00d6
dat_PlayCounter:
	DC.W	$fff0
dat_PatternDelay:
	DS.W	1
dat_SongDataAddr:
	DS.L	1
dat_PatternPosition:
	DS.W	1
dat_CursorColumn:
	DS.L	1
dat_DisplayParam:
	DS.B	1
dat_ButtonStateFlag:
	DS.B	1
dat_ButtonActive:
	DS.W	1
dat_ButtonRepeat:
	DS.W	1
dat_EditDigitValue:
	DS.W	1
dat_PalEdSelectPos:
	DS.W	1
dat_SavedEditDigit:
	DS.W	1
dat_SavedPalSelect:
	DS.W	1
dat_ChannelMaskTmp:
	DS.W	1
dat_ChannelSelTmp:
	DS.W	1
dat_MouseDelta:
	DS.W	1
dat_EffectTmp:
	DS.W	1
dat_EffectData0:
	DS.L	1
dat_EffectState0:
	DS.W	1
dat_EffectState1:
	DS.W	1
dat_EffectBuf:
	DS.L	5
dat_EffectData1:
	DS.L	1
dat_EffectData2:
	DS.L	1
dat_CurSamplePtr:
	DS.L	5
dat_ChannelMute:
	DS.W	1
	DS.B	1
dat_ChannelSolo:
	DS.B	1
dat_PosJumpFlag:
	DS.B	1
dat_RpBreakRow:
	DS.B	1
dat_RpPBreakFlag:
	DS.B	1
dat_SavedCIAPRA:
	DS.B	1
dat_PattDelayTime:
	DS.B	1
dat_PattDelayCount:
	DS.B	1
dat_PatRestartPos:
	DS.W	1
	DS.B	1
dat_PatSyncFlag:
	DS.B	1
dat_PatternSync:
	DS.L	1
	DS.W	1
dat_ScreenBufPtr:
	DS.L	1
dat_FileWriteAddr:
	DS.L	1
dat_FileWriteSize:
	DS.L	1
dat_LowMask:
	DC.B	$ff
dat_PatViewBusy:
	DS.B	1
dat_NextPosFlag:
	DS.W	1
pt_SampleEdEntry:
	DC.B	"                                       ",0
pt_EnterPosEdit:
	CLR.B	dat_KeyCode
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_LeavePosEdit
	JSR	pt_EditModeDispatcher
	JSR	pt_WaitMouseRelease
	MOVE.W	#$0009,dat_UIMode
	ST	dat_EditInputLock
	BSR.W	pt_13AD
	BEQ.S	pt_LeavePosEdit
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	MOVE.W	#$0987,D0
pt_13AA:
	CLR.L	(A0)+
	DBF	D0,pt_13AA
	BSR.W	pt_DrawSampleInfo
	JSR	pt_OptPageRefresh
	BSR.W	pt_13CC
	BSR.W	pt_ResetFileState
	RTS
pt_LeavePosEdit:
	CLR.W	dat_SampleCacheIdx
	MOVE.W	EXT_0002,dat_SampleCacheVal
	MOVE.B	#$f8,dat_SongModifiedFlag3
	MOVE.L	#$ffffffff,dat_PrevTimeDays
	MOVE.L	#$ffffffff,dat_PrevTimeMins
	MOVE.L	#$ffffffff,dat_PrevTimeTicks
	JSR	pt_WaitMouseRelease
	MOVE.W	#$0001,dat_UIMode
	BSR.S	pt_13AD
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	MOVE.W	#$0987,D0
pt_13AC:
	CLR.L	(A0)+
	DBF	D0,pt_13AC
	JMP	pt_LeaveToMain
pt_13AD:
	MOVE.L	(dat_OldSamplePtr,PC),D0
	BEQ.S	pt_13AE
	MOVEA.L	D0,A1
	BSR.S	pt_13AF
	JMP	pt_FreeOldSample
pt_13AE:
	LEA	dat_1467,A0
	JSR	pt_0824
	BNE.S	pt_13AF
	RTS
pt_13AF:
	LEA	SECSTRT_2,A0
	MOVEQ	#1,D2
	MOVEQ	#0,D3
pt_13B0:
	MOVE.W	#$04b9,D0
pt_13B1:
	MOVE.L	(A0),D1
	MOVE.L	(A1),(A0)+
	ADDQ.W	#4,D3
	CMP.W	#$0028,D3
	BNE.S	pt_13B2
	LEA	(40,A0),A0
	MOVEQ	#0,D3
pt_13B2:
	MOVE.L	D1,(A1)+
	DBF	D0,pt_13B1
	LEA	(10720,A0),A0
	DBF	D2,pt_13B0
	MOVEQ	#-1,D0
	RTS
pt_InputPosEdit:
	MOVEM.W	(dat_SavedEditDigit,PC),D0-D1
	LEA	dat_143A,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BEQ.S	pt_13B4
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnPosExit
	CMP.W	#$0002,D2
	BEQ.S	pt_BtnPosInsert
	CMP.W	#$0003,D2
	BEQ.S	pt_BtnPosDelete
	CMP.W	#$0004,D2
	BEQ.S	pt_BtnPosIncr
	CMP.W	#$0005,D2
	BEQ.S	pt_BtnPosDecr
	CMP.W	#$0008,D2
	BEQ.S	pt_BtnPosUp
	CMP.W	#$0009,D2
	BEQ.S	pt_BtnPosDown
	CMP.W	#$000a,D2
	BEQ.S	pt_BtnPosExit
	CMP.W	#$000b,D2
	BEQ.S	pt_BtnPosUp
	CMP.W	#$000c,D2
	BEQ.S	pt_BtnPosDown
	CMP.W	#$000d,D2
	BEQ.S	pt_JmpScreenHandler
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnPosScroll
pt_13B4:
	JSR	pt_InputMode5Keys
	RTS
pt_BtnPosInsert:
	JMP	pt_BtnMainPosInsert
pt_BtnPosDelete:
	JMP	pt_BtnMainPosDelete
pt_BtnPosUp:
	TSTPC.L	dat_RpPlayMode
	BNE.S	pt_13B8
	BSR.W	pt_SaveAllRegsFunc
pt_13B8:
	JMP	pt_DecrBplUpdate
pt_BtnPosDown:
	TSTPC.L	dat_RpPlayMode
	BNE.S	pt_13BA
	BSR.S	pt_SaveAllRegsFunc
pt_13BA:
	JMP	pt_088E
pt_BtnPosDecr:
	MOVE.W	#$ffff,dat_ButtonActive
	JSR	pt_BtnMainPatternArrows
	BRA.S	pt_EditModeHandler
pt_BtnPosIncr:
	CLR.W	dat_ButtonActive
	JSR	pt_BtnMainPatternArrows
	BRA.S	pt_EditModeHandler
pt_BtnPosExit:
	BRA.W	pt_LeavePosEdit
pt_JmpScreenHandler:
	JMP	pt_ScreenStateHandler
pt_SaveAllRegsFunc:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$0092,D0
	MOVEQ	#10,D1
	MOVE.W	#$00e4,D2
	MOVEQ	#108,D3
	MOVEQ	#0,D5
	BSR.W	pt_SetupAudioDisplay
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_DrawSampleInfo:
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_EditModeHandler
	RTS
pt_EditModeHandler:
	TSTPC.L	dat_RpPlayMode
	BEQ.S	pt_13C2
	BSR.S	pt_SaveAllRegsFunc
pt_13C2:
	MOVE.L	(dat_BplUpdateReq,PC),D7
	MOVEA.L	(dat_ModulePtr,PC),A0
	CMP.B	(mod_songlen,A0),D7
	BCS.S	pt_13C3
	MOVE.B	(mod_songlen,A0),D7
	SUBQ.L	#1,D7
pt_13C3:
	MOVE.L	D7,dat_BplUpdateBuf
	MOVEA.W	#$03d3,A5
	MOVEQ	#15,D6
	MOVEQ	#5,D5
	MOVE.L	(dat_BplUpdateBuf,PC),D7
	CMP.L	#$00000005,D7
	BGE.S	pt_13C5
	NEG.L	D7
	ADDQ.L	#4,D7
pt_13C4:
	ADDA.W	#$01e0,A5
	SUBQ.L	#1,D6
	SUBQ.L	#1,D5
	DBF	D7,pt_13C4
pt_13C5:
	MOVE.L	(dat_BplUpdateBuf,PC),D7
	SUB.L	D5,D7
	MOVEA.L	(dat_ModulePtr,PC),A1
	MOVEQ	#0,D4
	MOVE.B	(mod_songlen,A1),D4
	LEA	(mod_positions,A1),A1
pt_13C6:
	MOVE.L	D7,D0
	MOVEQ	#0,D1
	MOVE.B	(0,A1,D0.W),D1
	MOVE.L	D1,D2
	LSL.L	#4,D2
	ADDA.L	D2,A2
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	A5,dat_TextBytePos
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_FormatDecimal
	MOVEM.L	(A7)+,D0-D7/A0-A6
	ADDQ.W	#2,dat_TextBytePos
	MOVE.W	D1,dat_DisplayParam
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_Format2DigitHex
	MOVEM.L	(A7)+,D0-D7/A0-A6
	ADDQ.L	#1,D7
	CMP.L	D4,D7
	BEQ.S	pt_13C7
	ADDA.W	#$01e0,A5
	DBF	D6,pt_13C6
pt_13C7:
	BSR.W	pt_ResetFileState
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_songlen,A0),A0
	CLR.W	dat_DisplayParam
	MOVE.B	(A0),dat_ButtonStateFlag
	MOVE.W	#$1a93,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_positions,A0),A0
	ADDA.L	(dat_BplUpdateReq,PC),A0
	CLR.B	dat_DisplayParam
	MOVE.B	(A0),dat_ButtonStateFlag
	MOVE.B	(A0),dat_PatSyncFlag
	MOVEQ	#0,D1
	MOVE.B	(A0),D1
	MOVE.W	#$1d13,dat_TextBytePos
	MOVE.B	(A0),dat_ChannelSolo
	BSR.W	pt_FormatDecimal
	MOVE.W	(dat_CurrentPattern,PC),dat_DisplayParam
	MOVE.W	#$1f93,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	RTS
dat_SampleCacheIdx:
	DS.W	1
dat_SampleCacheVal:
	DS.W	1
dat_PatternScrollOffset:
	DS.B	1
dat_13CB:
	DS.B	1
pt_13CC:
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_songlen,A0),A0
	CLR.W	dat_PatternScrollOffset
	MOVE.B	(A0),D0
	ADD.B	#$12,D0
	MOVE.B	D0,dat_13CB
	RTS
pt_BtnPosScroll:
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_songlen,A0),A0
	CMPI.B	#$04,(A0)
	BGT.S	pt_13CE
	RTS
pt_13CE:
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.W	(dat_PalEdSelectPos,PC),D1
	MOVE.W	(dat_SampleCacheIdx,PC),D0
	ADD.W	#$0016,D0
	SUB.W	D0,D1
	BMI.W	pt_13D3
	CMP.W	(dat_SampleCacheVal,PC),D1
	BPL.W	pt_13D5
	MOVE.W	D1,D2
	MOVE.W	#$004a,D4
	SUB.W	(dat_SampleCacheVal,PC),D4
	BSR.W	pt_13D9
	MOVE.W	(dat_PalEdSelectPos,PC),D1
pt_13CF:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_13D2
	MOVE.W	D1,D3
	MOVE.W	(dat_PalEdSelectPos,PC),D1
	CMP.W	D1,D3
	BEQ.S	pt_13CF
	SUB.W	D2,D1
	SUB.W	#$0016,D1
	BPL.S	pt_13D0
	MOVEQ	#0,D1
pt_13D0:
	CMP.W	D4,D1
	BMI.S	pt_13D1
	MOVE.W	D4,D1
pt_13D1:
	MOVE.W	D1,dat_SampleCacheIdx
	BSR.W	pt_13D7
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PatternScrollOffset,PC),D0
	SUB.W	#$0013,D0
	MULU	(dat_SampleCacheIdx,PC),D0
	MOVE.W	#$004a,D1
	SUB.W	(dat_SampleCacheVal,PC),D1
	DIVU	D1,D0
	MOVE.W	D0,dat_CurrentPattern
	JSR	pt_BtnMainPosArrows
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LMB
	BEQ.S	pt_13CF
pt_13D2:
	BSR.W	pt_13D8
	RTS
pt_13D3:
	SUBI.L	#$00000013,dat_BplUpdateReq
	BPL.S	pt_13D4
	CLR.W	dat_CurrentPattern
pt_13D4:
	BSR.W	pt_ResetFileState
	MOVE.W	(dat_CurrentPattern,PC),D0
	JSR	pt_CheckBplUpdate
	RTS
pt_13D5:
	ADDI.W	#$0013,dat_CurrentPattern
	MOVE.W	(dat_PatternScrollOffset,PC),D0
	SUB.W	#$0013,D0
	CMP.W	(dat_CurrentPattern,PC),D0
	BPL.S	pt_13D6
	MOVE.W	D0,dat_CurrentPattern
pt_13D6:
	BSR.W	pt_ResetFileState
	MOVE.W	(dat_CurrentPattern,PC),D0
	JSR	pt_CheckBplUpdate
	RTS
pt_13D7:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_SampleCacheIdx,PC),D1
	ADD.W	#$0016,D1
	MOVE.W	#$0077,D0
	MOVE.W	(dat_SampleCacheVal,PC),D2
	LEA	dat_SongModifiedFlag2,A0
	BSR.W	pt_DrawSprite
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_13D8:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_SampleCacheIdx,PC),D1
	ADD.W	#$0016,D1
	MOVE.W	#$0077,D0
	MOVE.W	(dat_SampleCacheVal,PC),D2
	BSR.W	pt_PalColorShadeTab
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_13D9:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_SampleCacheIdx,PC),D1
	ADD.W	#$0016,D1
	MOVE.W	#$0077,D0
	MOVE.W	(dat_SampleCacheVal,PC),D2
	BSR.W	pt_InitHwPalette
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_ResetFileState:
	MOVEM.L	D0-D3,-(A7)
	MOVEQ	#0,D3
	MOVE.W	#$004a,dat_SampleCacheVal
	CLR.W	dat_SampleCacheIdx
	MOVE.W	#$004a,D0
	CLR.W	D1
	CMPI.W	#$0013,dat_PatternScrollOffset
	BMI.S	pt_13DB
	BEQ.S	pt_13DB
	MOVE.W	#$0629,D0
	MOVE.W	(dat_PatternScrollOffset,PC),D1
	EXT.L	D0
	DIVU	D1,D0
	MOVE.W	D0,dat_SampleCacheVal
	MOVE.W	(dat_CurrentPattern,PC),D1
	MOVE.W	(dat_PatternScrollOffset,PC),D2
	MOVE.W	#$004a,D3
	SUB.W	D0,D3
	MULU	D1,D3
	SUB.W	#$0013,D2
	DIVU	D2,D3
	MOVE.W	D3,dat_SampleCacheIdx
pt_13DB:
	MOVE.W	(dat_SampleCacheIdx,PC),D3
	ADD.W	(dat_SampleCacheVal,PC),D3
	CMP.W	#$004a,D3
	BMI.S	pt_13DC
	MOVE.W	#$004a,D3
pt_13DC:
	SUB.W	(dat_SampleCacheVal,PC),D3
	MOVE.W	D3,dat_SampleCacheIdx
	BSR.W	pt_13D8
	MOVEM.L	(A7)+,D0-D3
	RTS
pt_InitFileBuffers:
	CLR.L	dat_FileWorkBuf
	CLR.L	dat_125F
	CLR.L	dat_1260
	CLR.L	dat_1261
	MOVEQ	#0,D0
	MOVE.L	#$000001f4,D1
	MOVEQ	#1,D2
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(dat_FileWorkBuf,PC),A1
	BSR.S	pt_13DE
	MOVEQ	#0,D0
	RTS
pt_13DE:
	MOVE.L	#$00000006,dat_DiskReadPtr2
	CLR.L	dat_DiskReadBufPtr
	MOVE.L	D0,dat_DiskWriteBufPtr
	CLR.L	dat_FileReadBufPtr
	CLR.L	dat_FileWriteBuffer
	MOVE.B	D2,dat_13FE
pt_13DF:
	LEA	(mod_positions,A0),A2
	ADDA.L	dat_DiskWriteBufPtr,A2
	MOVEQ	#0,D0
	MOVE.B	(A2),D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_13E0
	LSL.L	#1,D0
pt_13E0:
	LEA	(mod_patterns,A0),A2
	ADDA.L	D0,A2
pt_13E1:
	LEA	(mod_positions,A0),A2
	ADDA.L	dat_DiskWriteBufPtr,A2
	MOVEQ	#0,D0
	MOVE.B	(A2),D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_13E2
	LSL.L	#1,D0
pt_13E2:
	LSL.L	#8,D0
	LSL.L	#2,D0
	LEA	(mod_patterns,A0),A2
	ADDA.L	D0,A2
	MOVE.L	dat_DiskReadBufPtr,D0
	LSL.L	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_13E3
	LSL.L	#1,D0
pt_13E3:
	ADDA.L	D0,A2
	MOVEQ	#3,D7
	BTST	#5,dat_ModeFlags
	BNE.S	pt_13E4
	MOVEQ	#7,D7
pt_13E4:
	RMB
	BEQ.W	pt_13EF
	LEA	dat_13F0,A3
	MOVE.L	(A2),D0
	AND.L	#$00000ff0,D0
	MOVE.L	D0,D2
	AND.L	#$00000f00,D2
	CMP.L	#$00000e00,D2
	BEQ.S	pt_13E5
	AND.L	#$00000f00,D0
pt_13E5:
	CMPI.L	#$ffffffff,(A3)
	BEQ.S	pt_13E7
	CMP.L	(A3),D0
	BNE.S	pt_13E6
	MOVEA.L	(4,A3),A3
	JSR	(A3)
	BRA.S	pt_13E7
pt_13E6:
	ADDQ.L	#8,A3
	BRA.S	pt_13E5
pt_13E7:
	ADDQ.L	#4,A2
	DBF	D7,pt_13E4
	BSR.W	pt_13EB
	ADDQ.L	#1,dat_DiskReadBufPtr
	TST.B	dat_FileWriteActive
	BNE.S	pt_13E8
	CMPI.L	#$00000040,dat_DiskReadBufPtr
	BNE.W	pt_13E1
pt_13E8:
	CLR.B	dat_FileWriteActive
	MOVE.L	dat_FileWriteBufPtr,dat_DiskReadBufPtr
	CLR.L	dat_FileWriteBufPtr
	TST.L	dat_FileWriteBuffer
	BEQ.S	pt_13E9
	MOVE.L	dat_FileWriteBuffer,dat_DiskWriteBufPtr
	CLR.L	dat_FileWriteBuffer
	BRA.S	pt_13EA
pt_13E9:
	ADDQ.L	#1,dat_DiskWriteBufPtr
	MOVE.L	dat_DiskWriteBufPtr,D0
	LEA	(mod_songlen,A0),A3
	CMP.B	(A3),D0
	BCS.W	pt_13DF
pt_13EA:
	MOVE.L	(12,A1),D0
	DIVU	#$00fa,D0
	AND.L	#$0000ffff,D0
	MOVE.L	D0,(12,A1)
	RTS
pt_13EB:
	MOVE.L	dat_DiskReadPtr2,D0
	SUBQ.L	#1,D0
pt_13EC:
	ADD.L	D1,(12,A1)
	DBF	D0,pt_13EC
	CMPI.L	#$000061a8,(12,A1)
	BCS.S	pt_13ED
	SUBI.L	#$000061a8,(12,A1)
	ADDQ.L	#1,(8,A1)
pt_13ED:
	CMPI.L	#$0000003c,(8,A1)
	BCS.S	pt_13EE
	SUBI.L	#$0000003c,(8,A1)
	ADDQ.L	#1,(4,A1)
pt_13EE:
	CMPI.L	#$0000003c,(4,A1)
	BCS.S	pt_13EF
	SUBI.L	#$0000003c,(4,A1)
	ADDQ.L	#1,(A1)
pt_13EF:
	RTS
dat_13F0:
	DC.L	$00000b00
	DC.L	dat_13F1
	DC.L	$00000d00
	DC.L	dat_13F2
	DC.L	$00000f00
	DC.L	dat_13F3
	DC.L	$00000e60
	DC.L	dat_13F4
	DC.L	$00000ee0
	DC.L	dat_13F5
	DC.L	$ffffffff,$ffffffff
dat_13F1:
	MOVE.L	(A2),D0
	AND.L	#$000000ff,D0
	MOVE.L	D0,dat_FileWriteBuffer
	MOVE.B	#$ff,dat_FileWriteActive
	RTS
dat_13F2:
	MOVE.L	(A2),D0
	AND.L	#$000000ff,D0
	MOVE.L	D0,dat_FileWriteBufPtr
	MOVE.B	#$ff,dat_FileWriteActive
	RTS
dat_13F3:
	MOVE.L	(A2),D0
	AND.L	#$000000ff,D0
	BEQ.S	pt_r1fe12
	TST.B	dat_13FE
	BEQ.S	pt_r1fe0a
	CMP.B	#$20,D0
	BCS.S	pt_r1fe0a
	MOVE.L	#$0000f424,D1
	DIVU.W	D0,D1
	AND.L	#$0000ffff,D1
	RTS
pt_r1fe0a:
	MOVE.L	D0,dat_DiskReadPtr2
	RTS
pt_r1fe12:
	MOVE.L	#$ffffffff,dat_FileWriteBuffer
	MOVE.B	#$ff,dat_FileWriteActive
	RTS
dat_13F4:
	MOVE.L	(A2),D0
	AND.L	#$0000000f,D0
	TST.L	D0
	BEQ.S	pt_r1fe44
	TST.L	dat_DiskWritePtr
	BEQ.S	pt_r1fe50
	SUBQ.L	#1,dat_DiskWritePtr
	BNE.S	pt_r1fe56
	RTS
pt_r1fe44:
	MOVE.L	dat_DiskReadBufPtr,dat_FileReadBufPtr
	RTS
pt_r1fe50:
	MOVE.L	D0,dat_DiskWritePtr
pt_r1fe56:
	MOVE.L	dat_FileReadBufPtr,dat_FileWriteBufPtr
	SUBQ.L	#1,dat_DiskWriteBufPtr
	MOVE.B	#$ff,dat_FileWriteActive
	RTS
	SUBQ.L	#1,dat_DiskWritePtr
	TST.L	dat_DiskWritePtr
	BEQ.S	pt_r1fe88
	MOVE.L	dat_FileReadBufPtr,dat_DiskReadBufPtr
pt_r1fe88:
	RTS
dat_13F5:
	MOVE.L	(A2),D0
	AND.L	#$0000000f,D0
	TST.L	D0
	BEQ.S	pt_r1fea2
	SUBQ.L	#1,D0
	MOVE.L	D0,D3
pt_r1fe9a:
	BSR.W	pt_13EB
	DBF	D3,pt_r1fe9a
pt_r1fea2:
	RTS
dat_DiskReadPtr2:
	DS.L	1
dat_DiskReadBufPtr:
	DS.L	1
dat_DiskWriteBufPtr:
	DS.L	1
dat_FileReadBufPtr:
	DS.L	1
dat_DiskWritePtr:
	DS.L	1
dat_FileWriteBuffer:
	DS.L	1
dat_FileWriteBufPtr:
	DS.L	1
dat_FileWriteActive:
	DS.B	1
dat_13FE:
	DS.B	1
pt_RpDmaWait:
	MOVEM.L	D0-D1,-(A7)
	BTST	#1,dat_TimerCountLo
	BEQ.S	pt_r1fed6
	MOVE.W	#$0a00,COLOR00
pt_r1fed6:
	BSR.S	pt_RpDmaWaitLines
	BTST	#1,dat_TimerCountLo
	BEQ.S	pt_r1fef2
	MOVE.W	#$00a0,COLOR00
pt_r1fef2:
	BSR.S	pt_RpDmaWaitLines
	MOVEM.L	(A7)+,D0-D1
	BTST	#1,dat_TimerCountLo
	BEQ.S	pt_r1ff10
	MOVE.W	#$0009,COLOR00
pt_r1ff10:
	RTS
pt_RpDmaWaitLines:
	MOVEQ	#0,D0
	MOVE.W	dat_RpDmaWaitCount,D0
	DIVU	#45,D0
	ADDQ.W	#1,D0
pt_RpDmaWaitLine:
	MOVE.B	$DFF006,D1
pt_RpDmaWaitSame:
	CMP.B	$DFF006,D1
	BEQ.S	pt_RpDmaWaitSame
	SUBQ.W	#1,D0
	BNE.S	pt_RpDmaWaitLine
	RTS
dat_RpFunkTable:
	DC.B	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
	EVEN
