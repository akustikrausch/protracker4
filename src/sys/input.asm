pt_DeleteMsgPort:
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dat_DisplayWorkBuf2,A1
	MOVE.W	#$000a,(28,A1)
	MOVE.L	#dat_InputIntStruct,(40,A1)
	JSR	(-456,A6)
	LEA	dat_DisplayWorkBuf2,A1
	JSR	(-450,A6)
	LEA	dat_ScopeWorkBuf1,A1
	JSR	(-360,A6)
	RTS
	DS.W	1
dat_InputIntStruct:
	DS.L	2
	DC.W	$0234
	DC.L	str_InputHandler
	DS.L	1
	DC.L	dat_InputHandlerCode
str_InputHandler:
	DC.B	"Protracker InputHandler",0,0,0
dat_InputHandlerCode:
	MOVE.L	A2,-(A7)
	TST.B	dat_VBlankCounter
	BNE.S	pt_r019b2
	SUBA.L	A2,A2
	MOVEA.L	A0,A1
	MOVE.B	(4,A1),D0
	CMP.B	#$01,D0
	BEQ.S	pt_r019b8
	CMP.B	#$02,D0
	BEQ.S	pt_r019d2
	MOVEA.L	A1,A2
pt_r019ac:
	MOVEA.L	(A1),A1
	MOVE.L	A1,D0
	BNE.S	dat_InputHandlerCode
pt_r019b2:
	MOVE.L	A0,D0
	MOVEA.L	(A7)+,A2
	RTS
pt_r019b8:
	BSR.W	pt_r01a68
	MOVE.W	(6,A1),D0
	MOVE.W	(8,A1),D1
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_r01a74
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.S	pt_r019ac
pt_r019d2:
	BSR.W	pt_r01a68
	MOVE.W	dat_ChannelMaskTmp,D0
	MOVE.W	dat_ButtonRepeat,D1
	MOVE.W	(10,A1),D2
	MOVE.W	(12,A1),D3
	TST.W	dat_MouseState
	BEQ.S	pt_r019fe
	ADD.W	D2,dat_MouseDelta
	ADD.W	D3,dat_EffectTmp
pt_r019fe:
	TST.W	dat_MouseState
	BNE.S	pt_r01a3a
	ADD.W	D2,D0
	ADD.W	D3,D1
	ASR.W	#1,D3
	TST.W	D0
	BPL.S	pt_r01a12
	MOVEQ	#0,D0
pt_r01a12:
	TST.W	D1
	BPL.S	pt_r01a18
	MOVEQ	#0,D1
pt_r01a18:
	CMP.W	#$027f,D0
	BMI.S	pt_r01a22
	MOVE.W	#$027f,D0
pt_r01a22:
	MOVE.W	#$01ff,D2
	BTST	#0,dat_UICheckFlag
	BEQ.S	pt_r01a34
	SUB.W	#$0064,D2
pt_r01a34:
	CMP.W	D2,D1
	BMI.S	pt_r01a3a
	MOVE.W	D2,D1
pt_r01a3a:
	MOVE.W	D1,dat_ButtonRepeat
	MOVE.W	dat_ScrollOffset,D2
	ADD.W	D2,D2
	ADD.W	D2,D1
	MOVE.W	D0,dat_ChannelMaskTmp
	MOVE.W	D1,dat_ChannelSelTmp
	LSR.W	#1,D1
	MOVE.W	D0,dat_EditDigitValue
	MOVE.W	D1,dat_PalEdSelectPos
	BRA.W	pt_r019ac
pt_r01a68:
	MOVE.L	A2,D0
	BNE.S	pt_r01a70
	MOVEA.L	(A1),A0
	RTS
pt_r01a70:
	MOVE.L	(A1),(A2)
	RTS
pt_r01a74:
	CMP.B	dat_RawKeyCode,D0
	BNE.S	pt_r01a88
	TST.B	dat_KeyUpDown
	BNE.S	pt_r01a86
	RTS
pt_r01a86:
	BRA.S	pt_r01ae8
pt_r01a88:
	MOVE.B	D0,dat_RawKeyCode
	CMP.B	#$60,D0
	BEQ.W	pt_r01b28
	CMP.B	#$61,D0
	BEQ.W	pt_r01b32
	CMP.B	#$64,D0
	BEQ.W	pt_r01b44
	CMP.B	#$65,D0
	BEQ.W	pt_r01b4e
	CMP.B	#$63,D0
	BEQ.W	pt_r01b60
	CMP.B	#$66,D0
	BEQ.W	pt_r01b72
	CMP.B	#$e3,D0
	BEQ.W	pt_r01b6a
	CMP.B	#$e4,D0
	BEQ.W	pt_r01b58
	CMP.B	#$e0,D0
	BEQ.S	pt_r01b3c
	CMP.B	#$e5,D0
	BEQ.S	pt_r01b58
	CMP.B	#$e1,D0
	BEQ.S	pt_r01b3c
	CMP.B	#$e6,D0
	BEQ.W	pt_r01b7c
pt_r01ae8:
	CMP.B	#$62,D0
	BEQ.S	pt_r01b18
	CMP.B	#$e2,D0
	BEQ.S	pt_r01b20
pt_r01af4:
	TST.B	D0
	BNE.S	pt_r01afc
	MOVE.B	#$7f,D0
pt_r01afc:
	MOVE.W	(dat_KeyBufCount,PC),D1
	CMP.W	#$0014,D1
	BCS.S	pt_r01b08
	RTS
pt_r01b08:
	LEA	(dat_KeyBuffer,PC),A3
	MOVE.B	D0,(0,A3,D1.W)
	ADDQ.W	#1,dat_KeyBufCount
	RTS
pt_r01b18:
	ST	dat_KeyUpDown
	RTS
pt_r01b20:
	SF	dat_KeyUpDown
	RTS
pt_r01b28:
	MOVE.W	#$0001,dat_KeyQual1
	RTS
pt_r01b32:
	MOVE.W	#$0001,dat_KeyQual1
	BRA.S	pt_r01af4
pt_r01b3c:
	CLR.W	dat_KeyQual1
	RTS
pt_r01b44:
	MOVE.W	#$0001,dat_KeyQual2
	RTS
pt_r01b4e:
	MOVE.W	#$0001,dat_KeyQual2
	BRA.S	pt_r01af4
pt_r01b58:
	CLR.W	dat_KeyQual2
	RTS
pt_r01b60:
	MOVE.W	#$0001,dat_KeyQual3
	RTS
pt_r01b6a:
	CLR.W	dat_KeyQual3
	RTS
pt_r01b72:
	MOVE.W	#$0001,dat_KeyQual4
	RTS
pt_r01b7c:
	CLR.W	dat_KeyQual4
	RTS
pt_ToggleEditCursor:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	pt_ClearKeyState
	LEA	dat_CursorChar,A0
	TST.W	dat_CursorToggle
	BEQ.S	pt_CursorHide
	MOVE.B	#$20,(A0)
	CLR.W	dat_CursorToggle
	BRA.S	pt_CursorShow
pt_CursorHide:
	MOVE.W	#$0001,dat_CursorToggle
	MOVE.B	#$58,(A0)
pt_CursorShow:
	MOVEQ	#1,D0
	MOVE.W	#$2834,D1
	JSR	pt_DrawTextAt
	JSR	pt_RefreshDisplay
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_ClearKeyState:
	CLR.W	dat_KeyQual2
	CLR.W	dat_KeyQual3
	CLR.W	dat_KeyQual4
	CLR.W	dat_KeyQual1
	CLR.B	dat_KeyCode
	RTS
pt_GetKeypress:
	MOVE.W	(dat_KeyBufCount,PC),D0
	BNE.S	pt_ProcessKeyBuf
	RTS
pt_ProcessKeyBuf:
	SUBQ.W	#1,D0
	LEA	(dat_KeyBuffer,PC),A0
	MOVE.B	(0,A0,D0.W),D1
	MOVE.W	D0,dat_KeyBufCount
	JSR	pt_EditWheelKey
	MOVE.B	D1,dat_LastRawKey
	AND.B	#$80,D1
	BEQ.S	pt_KeyProcessed
	CLR.B	dat_KeyCode
	CLR.B	dat_RawKeyCode
	CLR.W	dat_KeyRepeatCnt
pt_KeyProcessed:
	RTS
dat_KeyBufCount:
	DS.W	1
dat_KeyBuffer:
	DS.L	4
dat_KeyQual1:
	DS.W	1
dat_KeyQual2:
	DS.W	1
dat_KeyQual3:
	DS.W	1
dat_KeyQual4:
	DS.W	1
dat_CursorToggle:
	DS.W	1
dat_RawKeyCode:
	DC.W	$ff00
dat_LastRawKey:
	DS.B	1
dat_KeyUpDown:
	DS.B	1
dat_KeyModifiers:
	DS.W	1
dat_KeyRepeatCnt:
	DS.W	1
dat_CursorChar:
	DC.L	$20200000
	DS.W	1
pt_UpdateMousePos:
	MOVE.W	dat_EditDigitValue,D0
	LSR.W	#1,D0
	ADDQ.W	#3,D0
	MOVE.W	dat_ButtonRepeat,D1
	LSR.W	#1,D1
	MOVEQ	#11,D2
	MOVEA.L	(dat_SpriteDataPtr,PC),A0
	ADD.W	dat_ScrollOffset,D1
	JSR	pt_DrawSprite
	RTS
pt_r01c76:
	CMPI.L	#$70617470,dat_RpPlayMode
	BEQ.S	pt_r01c84
	RTS
pt_r01c84:
	ADDQ.W	#1,dat_TimerDuration
	MOVE.W	(dat_TimerDuration,PC),D0
	MOVEA.L	ABSEXECBASE.W,A0
	CMP.B	(530,A0),D0
	BEQ.S	pt_r01c9a
	RTS
pt_r01c9a:
	CLR.W	dat_TimerDuration
	ADDQ.L	#1,dat_MonthNames
	RTS
pt_HandlePlayTimer:
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_FormatTimeDisplay
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_FormatTimeDisplay
	RTS
pt_FormatTimeDisplay:
	CLR.W	dat_DisplayParam
	MOVE.W	#$0a96,dat_TextBytePos
	JSR	pt_Format2DigitHex
	MOVE.L	(dat_MonthNames,PC),D0
	DIVU	#$003c,D0
	MOVE.W	D0,dat_DisplayParam
	SWAP	D0
	MOVE.W	D0,D7
	ADDQ.W	#1,dat_TextBytePos
	JSR	pt_Format2DigitHex
	MOVE.W	D7,dat_DisplayParam
	ADDQ.W	#1,dat_TextBytePos
	JSR	pt_Format2DigitHex
	MOVE.L	#dat_DateStampBuf,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-192,A6)
	MOVE.L	dat_DateStampBuf,D0
	MOVE.L	dat_PrevTimeDays,D1
	BSR.W	pt_0107
	MOVE.L	dat_0109,D0
	MOVE.L	dat_PrevTimeMins,D1
	BSR.S	pt_0105
	MOVE.L	dat_TimeStampBuf,D0
	DIVU	#$0032,D0
	MOVE.L	D0,dat_TimeStampBuf
	MOVE.L	dat_PrevTimeTicks,D1
	CMP.L	D1,D0
	BEQ.S	pt_0104
	BSR.S	pt_0106
pt_0104:
	LEA	dat_DateStampBuf,A0
	LEA	dat_PrevTimeDays,A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	RTS
pt_0105:
	DIVU	#$003c,D0
	MOVE.W	D0,dat_SampleConfigD
	MOVE.W	D0,dat_DisplayParam
	SWAP	D0
	MOVE.W	D0,-(A7)
	MOVE.W	#$0816,dat_TextBytePos
	JSR	pt_Format2DigitHex
	MOVE.W	(A7)+,D0
	MOVE.W	D0,dat_DisplayParam
	ADDQ.W	#1,dat_TextBytePos
	MOVE.W	D0,dat_SampleConfigE
	JSR	pt_Format2DigitHex
	RTS
pt_0106:
	EXT.L	D0
	DIVU	#$003c,D0
	SWAP	D0
	MOVE.W	D0,dat_DisplayParam
	MOVE.W	#$081c,dat_TextBytePos
	MOVE.W	D0,dat_SampleConfigF
	JSR	pt_Format2DigitHex
	RTS
pt_0107:
	JSR	pt_02EC
	BEQ.W	pt_FormatTimeDisplay
	MOVE.W	dat_DirListVar2,D0
	MOVE.W	D0,dat_DisplayParam
	MOVE.W	D0,dat_SampleConfigA
	MOVE.W	#$0596,dat_TextBytePos
	JSR	pt_Format2DigitHex
	LEA	dat_MonthAbbrevTable,A0
	MOVE.W	dat_DirListVar1,D0
	MOVE.W	D0,dat_SampleConfigB
	SUBQ.W	#1,D0
	MULU	#$0005,D0
	ADDA.W	D0,A0
	MOVE.W	#$0598,D1
	MOVE.W	#$0005,D0
	JSR	pt_DrawTextAt
	MOVE.W	dat_DisplayParamVar,D0
	MOVE.W	D0,dat_DisplayParam
	MOVE.W	D0,dat_SampleConfigC
	MOVE.W	#$059d,dat_TextBytePos
	JSR	pt_Format2DigitHex
	RTS
dat_DateStampBuf:
	DS.L	1
dat_0109:
	DS.L	1
dat_TimeStampBuf:
	DS.L	1
dat_PrevTimeDays:
	DS.L	1
dat_PrevTimeMins:
	DS.L	1
dat_PrevTimeTicks:
	DS.L	1
dat_TimerDuration:
	DS.W	1
dat_MonthNames:
	DS.L	1
dat_MonthAbbrevTable:
	DC.L	$2d4a414e,$2d2d4645,$422d2d4d,$41522d2d
	DC.L	$4150522d,$2d4d4159,$2d2d4a55,$4e2d2d4a
	DC.L	$554c2d2d,$4155472d,$2d534550,$2d2d4f43
	DC.L	$542d2d4e,$4f562d2d,$4445432d,$4d4f4e2d
	DC.L	$5455452d,$5745442d,$5448552d,$4652492d
	DC.L	$5341542d,$53554e2d
pt_ScopeTrackPos:
	JSR	pt_ScopeBase
	LEA	dat_ScopeChanPos,A2
	LEA	dat_ScopeSampleTab,A1
	LEA	dat_ScopeDisplayBuf,A3
	MOVEQ	#3,D6
pt_r01ec6:
	MOVE.W	(A0),D0
	AND.W	#$0fff,D0
	OR.W	(16,A0),D0
	BEQ.S	pt_r01f3c
	MOVE.W	(16,A0),(16,A2)
	MOVE.B	(19,A0),(18,A2)
	TST.B	(42,A0)
	BEQ.S	pt_r01f14
	SF	(42,A0)
	BSR.W	pt_ScopeSetSample
	MOVEQ	#0,D0
	MOVE.B	(43,A0),D0
	SUBQ.W	#1,D0
	LSL.W	#4,D0
	MOVE.L	(0,A1,D0.W),(A2)
	MOVE.L	(4,A1,D0.W),(4,A2)
	MOVE.L	(8,A1,D0.W),(8,A2)
	MOVE.L	(12,A1,D0.W),(12,A2)
	MOVE.L	(A2),D0
	CMP.L	A3,D0
	BEQ.S	pt_r01f56
	BRA.S	pt_r01f30
pt_r01f14:
	MOVE.L	(A2),D0
	CMP.L	A3,D0
	BEQ.S	pt_r01f56
	MOVEQ	#0,D1
	MOVE.W	(16,A2),D1
	LSR.W	#1,D1
	BEQ.S	pt_r01f56
	JSR	pt_ScopeStep41
	NOP
	NOP
	ADD.L	D2,D0
pt_r01f30:
	CMP.L	(4,A2),D0
	BCS.S	pt_r01f54
	TST.L	(8,A2)
	BNE.S	pt_ScopeWrapLoop
pt_r01f3c:
	MOVE.L	A3,D0
	BRA.S	pt_r01f54
pt_ScopeWrapLoop:
	SUB.L	(4,A2),D0
	ADD.L	(8,A2),D0
	MOVE.L	(12,A2),(4,A2)
	CMP.L	(4,A2),D0
	BCC.S	pt_ScopeWrapLoop
pt_r01f54:
	MOVE.L	D0,(A2)
pt_r01f56:
	ADDA.W	#$0014,A2
	LEA	(88,A0),A0
	DBF	D6,pt_r01ec6
	MOVEQ	#-1,D4
	TST.W	dat_SamplerActive
	BEQ.S	pt_r01f6e
	MOVEQ	#0,D4
pt_r01f6e:
	MOVEQ	#0,D7
	MOVE.W	DMACONR,D6
	CLR.W	dat_CopperSyncVar
	BTST	#0,dat_ChannelIntCode
	BEQ.S	pt_r01fae
	MOVE.L	#$00000209,D0
	MOVEQ	#0,D5
	MOVEA.L	#$00000709,A1
	LEA	dat_ScopeDisplayCfg,A2
	BTST	#0,D6
	BEQ.S	pt_r01faa
	LEA	dat_ScopeChanPos,A2
	MOVE.B	(18,A2),D5
pt_r01faa:
	BSR.W	pt_r02082
pt_r01fae:
	MOVE.W	(dat_CopperSyncVar,PC),D0
	MOVE.W	D0,dat_0150
	CLR.W	dat_CopperSyncVar
	BTST	#1,dat_ChannelIntCode
	BEQ.S	pt_r01ff0
	MOVE.L	#$0000020f,D0
	MOVEQ	#0,D5
	MOVEA.L	#$0000070f,A1
	LEA	dat_ScopeDisplayCfg,A2
	BTST	#1,D6
	BEQ.S	pt_r01fec
	LEA	dat_1523,A2
	MOVE.B	(18,A2),D5
pt_r01fec:
	BSR.W	pt_r02082
pt_r01ff0:
	MOVE.W	(dat_CopperSyncVar,PC),D0
	MOVE.W	D0,dat_0153
	CLR.W	dat_CopperSyncVar
	BTST	#2,dat_ChannelIntCode
	BEQ.S	pt_r02030
	MOVE.L	#$00000215,D0
	MOVEQ	#0,D5
	MOVEA.L	#$00000715,A1
	LEA	dat_ScopeDisplayCfg,A2
	BTST	#2,D6
	BEQ.S	pt_r0202e
	LEA	dat_1524,A2
	MOVE.B	(18,A2),D5
pt_r0202e:
	BSR.S	pt_r02082
pt_r02030:
	MOVE.W	(dat_CopperSyncVar,PC),D0
	MOVE.W	D0,dat_0156
	CLR.W	dat_CopperSyncVar
	BTST	#3,dat_ChannelIntCode
	BEQ.S	pt_r02070
	MOVE.L	#$0000021b,D0
	MOVEQ	#0,D5
	MOVEA.L	#$0000071b,A1
	LEA	dat_ScopeDisplayCfg,A2
	BTST	#3,D6
	BEQ.S	pt_r0206e
	LEA	dat_1525,A2
	MOVE.B	(18,A2),D5
pt_r0206e:
	BSR.S	pt_r02082
pt_r02070:
	MOVE.W	(dat_CopperSyncVar,PC),D0
	MOVE.W	D0,dat_0159
	TST.L	D7
	BEQ.W	pt_r02224
	RTS
pt_r02082:
	TST.B	dat_ScopeBufferRef
	BEQ.W	pt_r021d6
	CMPI.B	#$02,dat_CursorPhase
	BEQ.S	pt_r020ae
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_r020ae
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_r020ae
	BNE.W	pt_r021d6
pt_r020ae:
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_r020c4
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_r020c4
	BNE.S	pt_r02128
pt_r020c4:
	CMPI.B	#$04,dat_ScopeMode
	BEQ.S	pt_r020da
	CMPI.B	#$05,dat_ScopeMode
	BEQ.S	pt_r020da
	BRA.S	pt_r020ea
pt_r020da:
	CMP.L	#$0000020f,D0
	BEQ.S	pt_r02128
	CMP.L	#$0000021b,D0
	BEQ.S	pt_r02128
pt_r020ea:
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
	MOVEQ	#32,D1
pt_r020f6:
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)
	CMPI.B	#$04,dat_ScopeMode
	BEQ.S	pt_r02118
	CMPI.B	#$05,dat_ScopeMode
	BEQ.S	pt_r02118
	BRA.S	pt_r02120
pt_r02118:
	MOVE.B	D0,(1,A0)
	MOVE.L	D0,(2,A0)
pt_r02120:
	LEA	(75,A0),A0
	DBF	D1,pt_r020f6
pt_r02128:
	MULS.W	dat_RpMasterVol,D5
	ADD.L	#$00000020,D5
	LSR.L	#6,D5
	LSR.W	#1,D5
	CMP.W	#$0020,D5
	BLS.S	pt_r02140
	MOVEQ	#32,D5
pt_r02140:
	MOVEA.L	(A2),A0
	ADDA.L	dat_ScreenBuf2Ptr,A1
	MOVEM.L	D6-D7,-(A7)
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_r02168
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_r02168
	BRA.W	pt_r021c8
pt_r02168:
	BSR.W	pt_0114
	TST.B	dat_ScopeMode
	BEQ.S	pt_r021a8
	CMPI.B	#$01,dat_ScopeMode
	BEQ.S	pt_r021aa
	CMPI.B	#$02,dat_ScopeMode
	BEQ.S	pt_r021b0
	CMPI.B	#$03,dat_ScopeMode
	BEQ.S	pt_r021b6
	CMPI.B	#$04,dat_ScopeMode
	BEQ.S	pt_r021bc
	CMPI.B	#$05,dat_ScopeMode
	BEQ.S	pt_r021c2
	BRA.S	pt_r021c8
pt_r021a8:
	BRA.S	pt_r021c8
pt_r021aa:
	BSR.W	pt_r0222c
	BRA.S	pt_r021cc
pt_r021b0:
	BSR.W	pt_r0225e
	BRA.S	pt_r021cc
pt_r021b6:
	BSR.W	pt_r022a8
	BRA.S	pt_r021cc
pt_r021bc:
	BSR.W	pt_r02316
	BRA.S	pt_r021cc
pt_r021c2:
	BSR.W	pt_r02364
	BRA.S	pt_r021cc
pt_r021c8:
	BSR.W	pt_r023c4
pt_r021cc:
	MOVE.W	D7,dat_CopperSyncVar
	MOVEM.L	(A7)+,D6-D7
pt_r021d6:
	TST.B	D4
	BEQ.S	pt_r021dc
	RTS
pt_r021dc:
	LEA	(dat_ScopeDisplayCfg,PC),A0
	CMPA.L	A0,A2
	BEQ.S	pt_r02224
	MOVE.L	(A2),D1
	MOVE.L	(dat_ScopeDisplay1,PC),D0
	CMP.L	D0,D1
	BHI.S	pt_r021f0
	RTS
pt_r021f0:
	CMP.L	(dat_ScopeDisplay2,PC),D1
	BCS.S	pt_r021f8
	RTS
pt_r021f8:
	SUB.L	D0,D1
	MULU.W	#$013a,D1
	MOVE.L	dat_DiskBufLen,D0
	BNE.S	pt_r02208
	RTS
pt_r02208:
	DIVU.W	D0,D1
	ST	D4
	ST	D7
	MOVE.L	D1,D0
	ADDQ.W	#6,D0
	MOVE.W	#$008b,D1
pt_r02216:
	MOVEQ	#64,D2
	LEA	chip_BorderRight,A0
	JMP	pt_DrawSprite
pt_r02224:
	MOVEQ	#0,D0
	MOVE.W	#$010e,D1
	BRA.S	pt_r02216
pt_r0222c:
	MOVEQ	#4,D2
pt_r0222e:
	MOVEQ	#7,D3
pt_r02230:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.W	D0,D6
	BPL.S	pt_r0223a
	NEG.W	D6
pt_r0223a:
	CMP.W	D6,D7
	BGE.S	pt_r02240
	MOVE.W	D6,D7
pt_r02240:
	NEG.W	D0
	MULS.W	D5,D0
	ASR.W	#8,D0
	MOVE.W	D0,D1
	ASL.W	#6,D0
	ASL.W	#4,D1
	ADD.W	D1,D0
	BSET	D3,(0,A1,D0.W)
	DBF	D3,pt_r02230
	ADDQ.L	#1,A1
	DBF	D2,pt_r0222e
	RTS
pt_r0225e:
	MOVEQ	#4,D2
pt_r02260:
	MOVEQ	#7,D3
pt_r02262:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.W	D0,D6
	BPL.S	pt_r0226c
	NEG.W	D6
pt_r0226c:
	CMP.W	D6,D7
	BGE.S	pt_r02272
	MOVE.W	D6,D7
pt_r02272:
	NEG.W	D0
	MULS.W	D5,D0
	ASR.W	#8,D0
	MOVE.W	D0,D1
	ASL.W	#6,D0
	ASL.W	#4,D1
	ADD.W	D1,D0
pt_r02280:
	BSET	D3,(0,A1,D0.W)
	TST.W	D0
	BEQ.S	pt_r02296
	BMI.S	pt_r02290
	SUB.W	#$0050,D0
	BRA.S	pt_r02280
pt_r02290:
	ADD.W	#$0050,D0
	BRA.S	pt_r02280
pt_r02296:
	DBF	D3,pt_r02262
	ADDQ.L	#1,A1
	DBF	D2,pt_r02260
	RTS
dat_DataWord1:
	DS.W	1
dat_0112:
	DS.W	1
dat_TriggerData:
	DC.W	$0000
pt_r022a8:
	MOVEQ	#4,D2
	MOVE.W	#$0001,dat_TriggerData
pt_r022b2:
	MOVEQ	#7,D3
pt_r022b4:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.W	D0,D6
	BPL.S	pt_r022be
	NEG.W	D6
pt_r022be:
	CMP.W	D6,D7
	BGE.S	pt_r022c4
	MOVE.W	D6,D7
pt_r022c4:
	NEG.W	D0
	MULS.W	D5,D0
	ASR.W	#8,D0
	MOVE.W	D0,D1
	ASL.W	#6,D0
	ASL.W	#4,D1
	ADD.W	D1,D0
	TSTPC.W	dat_TriggerData
	BEQ.S	pt_r022e4
	MOVE.W	D0,dat_DataWord1
	CLR.W	dat_TriggerData
pt_r022e4:
	MOVE.W	(dat_DataWord1,PC),dat_0112
	MOVE.W	D0,dat_DataWord1
pt_r022f2:
	BSET	D3,(0,A1,D0.W)
	CMP.W	(dat_0112,PC),D0
	BEQ.S	pt_r0230a
	BMI.S	pt_r02304
	SUB.W	#$0050,D0
	BRA.S	pt_r022f2
pt_r02304:
	ADD.W	#$0050,D0
	BRA.S	pt_r022f2
pt_r0230a:
	DBF	D3,pt_r022b4
	ADDQ.L	#1,A1
	DBF	D2,pt_r022b2
	RTS
pt_r02316:
	MOVE.L	A1,D2
	SUB.L	dat_ScreenBuf2Ptr,D2
	CMP.L	#$0000070f,D2
	BEQ.S	pt_r02360
	CMP.L	#$0000071b,D2
	BEQ.S	pt_r02360
pt_r0232e:
	MOVEQ	#10,D2
pt_r02330:
	MOVEQ	#7,D3
pt_r02332:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.W	D0,D6
	BPL.S	pt_r0233c
	NEG.W	D6
pt_r0233c:
	CMP.W	D6,D7
	BGE.S	pt_r02342
	MOVE.W	D6,D7
pt_r02342:
	NEG.W	D0
	MULS.W	D5,D0
	ASR.W	#8,D0
	MOVE.W	D0,D1
	ASL.W	#6,D0
	ASL.W	#4,D1
	ADD.W	D1,D0
	BSET	D3,(0,A1,D0.W)
	DBF	D3,pt_r02332
	ADDQ.L	#1,A1
	DBF	D2,pt_r02330
	RTS
pt_r02360:
	SUBQ.L	#6,A1
	BRA.S	pt_r0232e
pt_r02364:
	MOVE.L	A1,D2
	SUB.L	dat_ScreenBuf2Ptr,D2
	CMP.L	#$0000070f,D2
	BEQ.S	pt_r023c0
	CMP.L	#$0000071b,D2
	BEQ.S	pt_r023c0
pt_r0237c:
	MOVEQ	#10,D2
pt_r0237e:
	MOVEQ	#7,D3
pt_r02380:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	MOVE.W	D0,D6
	BPL.S	pt_r0238a
	NEG.W	D6
pt_r0238a:
	CMP.W	D6,D7
	BGE.S	pt_r02390
	MOVE.W	D6,D7
pt_r02390:
	NEG.W	D0
	MULS.W	D5,D0
	ASR.W	#8,D0
	MOVE.W	D0,D1
	ASL.W	#6,D0
	ASL.W	#4,D1
	ADD.W	D1,D0
pt_r0239e:
	BSET	D3,(0,A1,D0.W)
	TST.W	D0
	BEQ.S	pt_r023b4
	BMI.S	pt_r023ae
	SUB.W	#$0050,D0
	BRA.S	pt_r0239e
pt_r023ae:
	ADD.W	#$0050,D0
	BRA.S	pt_r0239e
pt_r023b4:
	DBF	D3,pt_r02380
	ADDQ.L	#1,A1
	DBF	D2,pt_r0237e
	RTS
pt_r023c0:
	SUBQ.L	#6,A1
	BRA.S	pt_r0237c
pt_r023c4:
	CMPI.B	#$02,dat_CursorPhase
	BEQ.S	pt_r023d0
	RTS
pt_r023d0:
	MOVEQ	#39,D2
pt_r023d2:
	MOVE.B	(A0)+,D0
	EXT.W	D0
	BPL.S	pt_r023da
	NEG.W	D0
pt_r023da:
	CMP.W	D0,D7
	BGE.S	pt_r023e0
	MOVE.W	D0,D7
pt_r023e0:
	DBF	D2,pt_r023d2
	RTS
pt_ScopeSetSample:
	MOVEQ	#0,D1
	MOVE.B	(43,A0),D1
	SUBQ.W	#1,D1
	LSL.W	#4,D1
	LEA	dat_ScopeSampleTab,A4
	LEA	(0,A4,D1.W),A4
	MOVE.L	(4,A0),D0
	MOVE.L	D0,(A4)
	MOVEQ	#0,D1
	MOVE.W	(8,A0),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	D0,(4,A4)
	MOVE.L	(10,A0),D0
	MOVE.L	D0,(8,A4)
	MOVEQ	#0,D1
	MOVE.W	(14,A0),D1
	CMP.W	#$0002,D1
	BCS.S	pt_ScopeSetNoLoop
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	D0,(12,A4)
	RTS
pt_ScopeSetNoLoop:
	CLR.L	(8,A4)
	RTS
pt_0114:
	MOVEM.L	D0/A0,-(A7)
	TST.B	dat_ScopeMode
	BNE.S	pt_0115
	MOVEA.L	#dat_CreditsLogo41,A0
pt_0115:
	CMPI.B	#$01,dat_ScopeMode
	BNE.S	pt_0116
	MOVEA.L	#dat_IMPFormatData,A0
pt_0116:
	CMPI.B	#$02,dat_ScopeMode
	BNE.S	pt_0117
	MOVEA.L	#dat_IMPFormatData,A0
pt_0117:
	CMPI.B	#$03,dat_ScopeMode
	BNE.S	pt_0118
	MOVEA.L	#dat_IMPFormatData,A0
pt_0118:
	CMPI.B	#$04,dat_ScopeMode
	BNE.S	pt_0119
	MOVEA.L	#dat_1473,A0
pt_0119:
	CMPI.B	#$05,dat_ScopeMode
	BNE.S	pt_011A
	MOVEA.L	#dat_1473,A0
pt_011A:
	MOVE.B	dat_ScopeMode,D0
	CMP.B	dat_0658,D0
	BEQ.S	pt_WaitAllocBufOrRet
	MOVE.B	dat_ScopeMode,dat_0658
	CMPI.L	#$494d5021,(A0)
	BNE.S	pt_011B
	MOVEM.L	D0-D7/A1-A6,-(A7)
	JSR	pt_CheckAllocBuf
	MOVEM.L	(A7)+,D0-D7/A1-A6
pt_011B:
	MOVEA.L	A0,A1
	LEA	SECSTRT_2,A0
	ADDA.W	#$0028,A0
	MOVEQ	#1,D0
pt_011C:
	MOVEQ	#43,D1
pt_011D:
	MOVE.L	(A1)+,(A0)
	MOVE.L	(A1)+,(4,A0)
	MOVE.L	(A1)+,(8,A0)
	MOVE.L	(A1)+,(12,A0)
	MOVE.L	(A1)+,(16,A0)
	MOVE.L	(A1)+,(20,A0)
	MOVE.B	(A1)+,(24,A0)
	ADDQ.L	#1,A1
	ADDA.W	#$0050,A0
	DBF	D1,pt_011D
	LEA	SECSTRT_2,A0
	ADDA.W	#$5028,A0
	DBF	D0,pt_011C
	TST.L	dat_AllocBufPtr
	BEQ.S	pt_WaitAllocBufOrRet
	MOVEM.L	D0-D7/A1-A6,-(A7)
	JSR	pt_LoadAllocBuf
	MOVEM.L	(A7)+,D0-D7/A1-A6
pt_WaitAllocBufOrRet:
	MOVEM.L	(A7)+,D0/A0
	RTS
