pt_InitTimeDisplay:
	MOVE.W	#$0001,dat_TimeDisplayInit
pt_UpdateTimeDisplay:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.W	dat_TimeDisplayInit
	BEQ.S	pt_TimeReadClock
	CLR.W	dat_TimeDisplayInit
	CLR.L	dat_LastEClockVal
	CLR.L	dat_TimeAuxVal
pt_TimeReadClock:
	BSR.W	pt_ReadEClock
	MOVEQ	#0,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-216,A6)
	CMP.L	(dat_LastEClockVal,PC),D0
	BEQ.W	pt_TimeNoChange
	MOVE.L	D0,dat_LastEClockVal
	BTST	#7,dat_ModeFlags
	BNE.W	pt_TimeSkipDraw
	MOVEQ	#2,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-216,A6)
	MOVE.L	D0,D6
	MOVE.W	#$2849,dat_TextBytePos
	SWAP	D0
	AND.W	#$00ff,D0
	MOVE.W	D0,dat_DisplayParam
	JSR	pt_DrawDecValue3
	MOVE.W	D6,dat_DisplayParam
	JSR	pt_DrawDecValue2
pt_TimeNoChange:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_TimeSkipDraw:
	MOVEQ	#2,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-216,A6)
	MOVE.W	#$2849,dat_TextBytePos
	JSR	pt_FormatNumToDecimal
	BRA.S	pt_TimeNoChange
pt_ReadEClock:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(42,A0),A0
	MOVE.W	(dat_PrevSampleNum,PC),D7
	SUBQ.W	#1,D7
	MOVE.W	#$001f,dat_PrevSampleNum
	MOVEQ	#0,D0
pt_0125:
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ASL.W	#1,D1
	ADD.L	D1,D0
	ADDA.W	#$001e,A0
	DBF	D7,pt_0125
	ADD.L	#$0000043c,D0
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#127,D7
	ADDA.W	#$03b8,A0
	MOVEQ	#0,D6
pt_0126:
	MOVE.B	(A0)+,D5
	CMP.B	D5,D6
	BHI.S	pt_0127
	MOVE.B	D5,D6
pt_0127:
	DBF	D7,pt_0126
	ADDQ.W	#1,D6
	ASL.L	#8,D6
	ASL.L	#2,D6
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0128
	ASL.L	#1,D6
pt_0128:
	ADD.L	D6,D0
	CMP.L	(dat_TimeAuxVal,PC),D0
	BNE.S	pt_0129
	RTS
pt_0129:
	MOVE.L	D0,dat_TimeAuxVal
	BTST	#7,dat_ModeFlags
	BNE.S	pt_012A
	MOVE.L	D0,D6
	MOVE.W	#$283e,dat_TextBytePos
	SWAP	D0
	AND.W	#$00ff,D0
	MOVE.W	D0,dat_DisplayParam
	JSR	pt_DrawDecValue3
	MOVE.W	D6,dat_DisplayParam
	JMP	pt_DrawDecValue2
pt_012A:
	MOVE.L	(dat_TimeAuxVal,PC),D0
	MOVE.W	#$283e,dat_TextBytePos
	JMP	pt_FormatNumToDecimal
pt_r02670:
	JSR	pt_EditMuteTrack
	CMP.W	#$0017,D0
	BCC.S	pt_ScopeCh3Toggle
	CMP.W	#$000c,D0
	BCC.S	pt_ScopeCh2Toggle
pt_ScopeCh1Toggle:
	LEA	(dat_ScopeCh1,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_ScopeCh2Toggle:
	LEA	(dat_ScopeCh2,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_ScopeCh3Toggle:
	LEA	(dat_ScopeCh3,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_ScopeCh4Toggle:
	LEA	(dat_ScopeCh4,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_012F:
	LEA	(dat_ChannelTableA,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_0130:
	LEA	(dat_ChannelTableB,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_0131:
	LEA	(dat_ChannelTableC,PC),A0
	BRA.S	pt_ToggleScopeFlag
pt_0132:
	LEA	(dat_ChannelTableD,PC),A0
pt_ToggleScopeFlag:
	MOVE.W	#$0004,dat_KeyRepeatDelay
	CLR.B	dat_KeyCode
	EORI.W	#$0001,(A0)
	BSR.W	pt_WaitMouseRelease
pt_0134:
	CLR.W	D0
	MOVE.W	(dat_ChannelTableD,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ChannelTableC,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ChannelTableB,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ChannelTableA,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ScopeCh4,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ScopeCh3,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ScopeCh2,PC),D0
	LSL.B	#1,D0
	OR.W	(dat_ScopeCh1,PC),D0
	MOVE.W	D0,dat_RpDmaChanMask
	BSR.S	pt_UpdateScopeDisplay
	BSR.S	pt_0135
	JSR	pt_RefreshDisplay
	JMP	pt_AudioChannelUpdate
pt_0135:
	MOVEM.L	D0/A0-A1,-(A7)
	LEA	dat_ScopeChanPos,A0
	LEA	dat_ScopeDisplayBuf,A1
	MOVE.L	A1,(A0)
	MOVE.L	A1,(20,A0)
	MOVE.L	A1,(40,A0)
	MOVE.L	A1,(60,A0)
	MOVEM.L	(A7)+,D0/A0-A1
	RTS
pt_UpdateScopeDisplay:
	MOVE.W	(dat_RpDmaChanMask,PC),D2
	MOVE.L	#$00000209,D0
	LEA	dat_Channel1,A1
	BSR.S	pt_ProcessChanScope
	LSR.W	#1,D2
	MOVE.L	#$0000020f,D0
	LEA	dat_Channel2,A1
	BSR.S	pt_ProcessChanScope
	LSR.W	#1,D2
	MOVE.L	#$00000215,D0
	LEA	dat_Channel3,A1
	BSR.S	pt_ProcessChanScope
	LSR.W	#1,D2
	MOVE.L	#$0000021b,D0
	LEA	dat_Channel4,A1
	BSR.S	pt_ProcessChanScope
	BSR.W	pt_InitChannelPtrs
	RTS
pt_ProcessChanScope:
	BTST	#0,D2
	BNE.S	pt_013B
	CLR.W	(n_pt4_volscale,A1)
	CMPI.W	#$0001,dat_UIMode
	BEQ.S	pt_FillAudioBuf
	CMPI.W	#$0009,dat_UIMode
	BEQ.S	pt_FillAudioBuf
	BRA.S	pt_013A
pt_FillAudioBuf:
	MOVEA.L	dat_ScreenBuf2Ptr,A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
	MOVEQ	#32,D1
pt_0139:
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	LEA	(75,A0),A0
	DBF	D1,pt_0139
pt_013A:
	RTS
pt_013B:
	MOVE.W	dat_RpMasterVol,(n_pt4_volscale,A1)
	RTS
pt_InitPalettes:
	JSR	pt_Vu8Init41
	LEA	(dat_ScopeCh1,PC),A3
	BSR.W	pt_DrawScopeSprite
	LEA	chip_PanelBitplane2,A2
	LEA	(dat_ScopeCh2,PC),A3
	BSR.W	pt_DrawScopeSprite
	LEA	chip_PanelBitplane3,A2
	LEA	(dat_ScopeCh3,PC),A3
	BSR.W	pt_DrawScopeSprite
	LEA	chip_PanelBitplane4,A2
	LEA	(dat_ScopeCh4,PC),A3
	BSR.W	pt_DrawScopeSprite
	RTS
pt_r027fc:
	JSR	pt_Vu8Tick41
	BNE.S	pt_r02806
	RTS
pt_r02806:
	LEA	dat_Channel1,A1
	LEA	chip_PanelBitplane1,A2
	LEA	(dat_ScopeCh1,PC),A3
	BSR.W	pt_r0284e
	LEA	dat_Channel2,A1
	LEA	chip_PanelBitplane2,A2
	LEA	(dat_ScopeCh2,PC),A3
	BSR.S	pt_r0284e
	LEA	dat_Channel3,A1
	LEA	chip_PanelBitplane3,A2
	LEA	(dat_ScopeCh3,PC),A3
	BSR.S	pt_r0284e
	LEA	dat_Channel4,A1
	LEA	chip_PanelBitplane4,A2
	LEA	(dat_ScopeCh4,PC),A3
pt_r0284e:
	MOVE.W	(A3),D0
	CMPI.B	#$02,dat_CursorPhase
	BEQ.S	pt_r028a6
	TST.L	dat_RpPlayMode
	BEQ.W	pt_r02904
	TST.W	D0
	BEQ.W	pt_r02904
	TST.L	dat_RpCounter
	BNE.W	pt_r02904
	TST.W	(A1)
	BEQ.W	pt_r02904
	MOVEQ	#0,D0
	MOVE.B	(19,A1),D0
	CMP.W	#$003f,D0
	BLS.S	pt_r02888
	MOVEQ	#63,D0
pt_r02888:
	MULU.W	#$0030,D0
	MULU.W	dat_RpMasterVol,D0
	ADD.L	#$00000020,D0
	LSR.L	#6,D0
	LSR.W	#6,D0
	BNE.S	pt_r028a0
	MOVEQ	#1,D0
pt_r028a0:
	MOVE.W	D0,(4,A3)
	BRA.S	pt_DrawScopeSprite
pt_r028a6:
	MOVE.W	(6,A3),D1
	MOVEQ	#0,D0
	MOVE.B	(19,A1),D0
	MULU.W	D1,D0
	MULU.W	#$0030,D0
	LSR.L	#7,D0
	MULU.W	dat_RpMasterVol,D0
	ADD.L	#$00000020,D0
	LSR.L	#6,D0
	LSR.W	#6,D0
	BNE.S	pt_r028cc
	MOVEQ	#1,D0
pt_r028cc:
	CMP.W	(4,A3),D0
	BMI.S	pt_r028f8
	MOVE.W	D0,(4,A3)
pt_DrawScopeSprite:
	MOVE.W	(4,A3),D2
	MOVE.W	#$00c6,D1
	SUB.W	D2,D1
	MOVE.W	(2,A3),D0
	TST.B	dat_CursorPhase
	BNE.S	pt_013E
	MOVEQ	#-64,D0
pt_013E:
	MOVEA.L	A2,A0
	JMP	pt_DrawSprite
	RTS
pt_r028f8:
	MOVE.W	(4,A3),D1
	SUB.W	D0,D1
	LSR.W	#1,D1
	SUB.W	D1,(4,A3)
pt_r02904:
	SUBQ.W	#1,(4,A3)
	CMPI.W	#$0001,(4,A3)
	BPL.S	pt_r02916
	MOVE.W	#$0001,(4,A3)
pt_r02916:
	BRA.S	pt_DrawScopeSprite
dat_ScopeBufferRef:
	DS.W	1
dat_ScopeDisplayCfg:
	DC.L	dat_ScopeDisplayBuf
dat_ScopeDisplay1:
	DS.L	1
dat_ScopeDisplay2:
	DS.L	1
dat_CopperSyncVar:
	DS.W	1
dat_TimeDisplayInit:
	DS.W	1
dat_LastEClockVal:
	DS.L	1
dat_TimeAuxVal:
	DS.L	1
dat_PrevSampleNum:
	DC.W	$001f
dat_PalEdScrollPos:
	DS.W	1
dat_0149:
	DC.L	$00050002
	DS.L	1
	DC.W	$0009
dat_014A:
	DS.W	1
dat_ButtonMode:
	DC.L	$00010000
dat_014C:
	DC.L	$00000009,$00060005,$00020000
dat_014D:
	DC.L	$00060009
dat_014E:
	DC.L	$00220000
dat_ScopeCh1:
	DC.L	$0001002e
	DC.W	$0001
dat_0150:
	DS.W	1
dat_ScopeCh1Flag:
	DS.W	1
dat_ScopeCh2:
	DC.L	$0001006a
	DC.W	$0001
dat_0153:
	DS.W	1
dat_ScopeCh2Flag:
	DS.W	1
dat_ScopeCh3:
	DC.L	$000100a6
	DC.W	$0001
dat_0156:
	DS.W	1
dat_ScopeCh3Flag:
	DS.W	1
dat_ScopeCh4:
	DC.L	$000100e2
	DC.W	$0001
dat_0159:
	DS.W	1
dat_ScopeCh4Flag:
	DS.W	1
dat_ChannelTableA:
	DC.L	$0001011e,$00010000
	DS.W	1
dat_ChannelTableB:
	DC.L	$0001015a,$00010000
	DS.W	1
dat_ChannelTableC:
	DC.L	$00010196,$00010000
	DS.W	1
dat_ChannelTableD:
	DC.L	$000101d2,$00010000
	DS.W	1
dat_RpDmaChanMask:
	DC.W	$000f
dat_ChannelIntCode:
	DC.L	$0f48e7f0,$80e14a84,$fcbafcf0,$a066164a
	DC.W	$7900
	DC.L	dat_ScopeCh1
	DC.L	$670e2279
	DC.L	dat_ScopeCh1Flag
	DC.L	$650633c2
	DC.L	dat_ScopeCh1Flag
	DC.L	$bafcf0b0,$66164a79
	DC.L	dat_ScopeCh2
	DC.L	$670e2279
	DC.L	dat_ScopeCh2Flag
	DC.L	$650633c2
	DC.L	dat_ScopeCh2Flag
	DC.L	$bafcf0c0,$66164a79
	DC.L	dat_ScopeCh3
	DC.L	$670e2279
	DC.L	dat_ScopeCh3Flag
	DC.L	$650633c2
	DC.L	dat_ScopeCh3Flag
	DC.L	$bafcf0d0,$66164a79
	DC.L	dat_ScopeCh4
	DC.L	$670e2279
	DC.L	dat_ScopeCh4Flag
	DC.L	$650633c2
	DC.L	dat_ScopeCh4Flag
	DS.W	1
pt_BtnMainVolumeUp:
	MOVEQ	#-1,D0
	RMB
	BNE.S	pt_0162
	MOVEQ	#-10,D0
pt_0162:
	BRA.S	pt_ScrollPalettePos
pt_BtnMainVolumeDown:
	MOVEQ	#1,D0
	RMB
	BNE.S	pt_0164
	MOVEQ	#10,D0
pt_0164:
	BRA.W	pt_ScrollPalettePos
pt_ScrollPalettePos:
	ADD.W	D0,dat_PalEdScrollPos
	BPL.S	pt_0166
	CLR.W	dat_PalEdScrollPos
pt_0166:
	CMPI.W	#$0022,dat_PalEdScrollPos
	BMI.S	pt_0167
	MOVE.W	#$0022,dat_PalEdScrollPos
pt_0167:
	BRA.W	pt_DrawStatusBar
pt_BtnMainTitleSide:
	MOVE.W	dat_PalEdSelectPos,D0
	MOVE.W	(dat_PalEdScrollPos,PC),D2
	SUBQ.W	#2,D0
	CMP.W	D0,D2
	BGT.S	pt_DecrementPalScroll
	MOVE.W	D0,D1
	SUBQ.W	#6,D1
	CMP.W	D1,D2
	BLE.S	pt_IncrementPalScroll
	MOVE.W	D0,D4
	SUB.W	D2,D4
	MOVE.W	#$0002,dat_ButtonMode
	BSR.W	pt_DrawStatusBar
pt_HandlePalEdMouseUp:
	LMB
	BNE.S	pt_016C
	JSR	pt_ScreenDragUpdate
	MOVE.W	dat_PalEdSelectPos,D0
	SUBQ.W	#2,D0
	SUB.W	D4,D0
	BGT.S	pt_016A
	MOVEQ	#0,D0
pt_016A:
	CMP.W	#$0022,D0
	BLS.S	pt_016B
	MOVE.W	#$0022,D0
pt_016B:
	CMP.W	D0,D2
	BEQ.S	pt_HandlePalEdMouseUp
	MOVE.W	D0,D2
	MOVE.W	D0,dat_PalEdScrollPos
	BSR.S	pt_DrawStatusBar
	LMB
	BEQ.S	pt_HandlePalEdMouseUp
pt_016C:
	MOVE.W	#$0001,dat_ButtonMode
	BRA.S	pt_DrawStatusBar
pt_DecrementPalScroll:
	SUBQ.W	#1,dat_PalEdScrollPos
	BPL.S	pt_016E
	CLR.W	dat_PalEdScrollPos
pt_016E:
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#1,D1
	JSR	(-198,A6)
	BRA.S	pt_DrawStatusBar
pt_IncrementPalScroll:
	ADDQ.W	#1,dat_PalEdScrollPos
	CMPI.W	#$0022,dat_PalEdScrollPos
	BMI.S	pt_0170
	MOVE.W	#$0022,dat_PalEdScrollPos
pt_0170:
	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#1,D1
	JSR	(-198,A6)
pt_DrawStatusBar:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEdScrollPos,PC),D0
	MOVE.W	D0,dat_014A
	MOVE.W	D0,dat_014C
	MOVE.W	D0,D1
	ADDQ.W	#6,D1
	MOVE.W	D1,dat_014D
	MOVE.W	#$0022,D1
	SUB.W	D0,D1
	MOVE.W	D1,dat_014E
	LEA	(dat_0149,PC),A0
	MOVE.W	#$0134,D0
	MOVEQ	#2,D1
	CMPI.W	#$0001,dat_UIMode
	BNE.S	pt_0172
	JSR	pt_SetDrawOffset
pt_0172:
	MOVE.W	#$0022,D1
	SUB.W	(dat_PalEdScrollPos,PC),D1
	MOVE.W	(dat_PalEdScrollPos,PC),D1
	MULU	#$0040,D1
	DIVU	#$0022,D1
	MOVE.W	#$0040,D0
	SUB.W	D1,D0
	MOVE.W	D0,dat_RpMasterVol
	TSTPC.W	dat_ScopeCh1
	BEQ.S	dat_0173
	MOVE.W	D0,dat_Channel1+n_pt4_volscale
dat_0173:
	TSTPC.W	dat_ScopeCh2
	BEQ.S	dat_0174
	MOVE.W	D0,dat_Channel2+n_pt4_volscale
dat_0174:
	TSTPC.W	dat_ScopeCh3
	BEQ.S	dat_0175
	MOVE.W	D0,dat_Channel3+n_pt4_volscale
dat_0175:
	TSTPC.W	dat_ScopeCh4
	BEQ.S	pt_0176
	MOVE.W	D0,dat_Channel4+n_pt4_volscale
pt_0176:
	BSR.S	pt_InitChannelPtrs
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_InitChannelPtrs:
	LEA	dat_ChannelPtrTable,A1
	LEA	AUD0LCH,A5
	MOVEQ	#3,D1
pt_0178:
	MOVEA.L	(A1)+,A0
	BSR.S	pt_0179
	LEA	(aud_SIZEOF,A5),A5
	DBF	D1,pt_0178
	RTS
pt_0179:
	MOVEQ	#0,D0
	MOVE.B	(n_volume,A0),D0
	MULS	(20,A0),D0
	ADD.L	#$00000020,D0
	LSR.L	#6,D0
	TST.B	(n_pt4_chunked,A0)
	BNE.S	pt_017A
	MOVE.W	D0,(aud_VOL,A5)
pt_017A:
	RTS
pt_HandleUIButton:
	MOVE.W	#$ffff,dat_DiskOpFlag
	BSR.S	pt_HandleUIBtnCore
	CLR.W	dat_DiskOpFlag
	RTS
pt_HandleUIBtnCore:
	CLR.B	dat_XORPlotFlag
pt_r02c0e:
	MOVE.W	D7,-(A7)
pt_ReadChannelWord:
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D7
	MOVE.W	(A0)+,D3
	MOVE.W	(A0)+,D4
	MOVE.W	(A0)+,D5
	MOVE.W	(A0)+,D6
	TST.W	D2
	BEQ.S	pt_RenderReturn
	CMP.W	D0,D3
	BHI.S	pt_ReadChannelWord
	CMP.W	D0,D5
	BCS.S	pt_ReadChannelWord
	CMP.W	D1,D4
	BHI.S	pt_ReadChannelWord
	CMP.W	D1,D6
	BCS.S	pt_ReadChannelWord
	MOVE.W	D7,dat_RenderCounter
	TST.W	D7
	BEQ.S	pt_RenderReturn
	TST.B	dat_RenderMode
	BNE.S	pt_RenderReturn
	BSR.S	pt_PlotXORStart
pt_RenderReturn:
	MOVE.W	(A7)+,D7
	RTS
dat_XORPlotFlag:
	DS.W	1
pt_PlotXORStart:
	MOVEQ	#0,D7
	BSR.W	pt_PlotWithXOR
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TSTPC.B	dat_XORPlotFlag
	BNE.S	pt_WaitDOSDelay
	MOVE.L	dat_DosLibBase,D0
	BEQ.S	pt_WaitDOSDelay
	MOVEA.L	D0,A6
	MOVEQ	#1,D1
	JSR	(-198,A6)
pt_WaitDOSDelay:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEM.W	D0-D1,-(A7)
pt_EditUpdateLoop:
	JSR	pt_ScreenDragUpdate
	MOVEM.W	dat_EditDigitValue,D0-D1
	TST.W	D7
	BEQ.S	pt_0183
	BSR.S	pt_0187
	BRA.S	pt_0184
pt_0183:
	BSR.S	pt_0188
pt_0184:
	LMB
	BEQ.S	pt_EditUpdateLoop
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TSTPC.B	dat_XORPlotFlag
	BNE.S	pt_WaitDOSDelay2
	MOVE.L	dat_DosLibBase,D0
	BEQ.S	pt_WaitDOSDelay2
	MOVEA.L	D0,A6
	MOVEQ	#1,D1
	JSR	(-198,A6)
pt_WaitDOSDelay2:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LMB
	BEQ.S	pt_EditUpdateLoop
	MOVEM.W	(A7)+,D0-D1
	MOVE.W	D7,D2
	BEQ.S	pt_PlotReturnCheck
	BSR.S	pt_018A
pt_PlotReturnCheck:
	RTS
pt_0187:
	CMP.W	D0,D3
	BHI.S	pt_PlotWithXOR
	CMP.W	D0,D5
	BCS.S	pt_PlotWithXOR
	CMP.W	D1,D4
	BHI.S	pt_PlotWithXOR
	CMP.W	D1,D6
	BCS.S	pt_PlotWithXOR
	RTS
pt_0188:
	CMP.W	D0,D3
	BHI.S	pt_PlotReturnCheck
	CMP.W	D0,D5
	BCS.S	pt_PlotReturnCheck
	CMP.W	D1,D4
	BHI.S	pt_PlotReturnCheck
	CMP.W	D1,D6
	BCS.S	pt_PlotReturnCheck
pt_PlotWithXOR:
	EOR.W	D2,D7
pt_018A:
	MOVEM.W	D0-D7,-(A7)
	CMPI.W	#$0001,dat_RenderCounter
	BNE.S	pt_018B
	BSR.S	pt_018E
pt_018B:
	CMPI.W	#$0002,dat_RenderCounter
	BNE.S	pt_018C
	BSR.S	pt_018D
pt_018C:
	MOVEM.W	(A7)+,D0-D7
	RTS
pt_018D:
	MOVE.W	D3,D0
	MOVE.W	D4,D1
	MOVE.W	D5,D2
	ADDQ.W	#1,D2
	MOVE.W	D6,D3
	ADDQ.W	#1,D3
	JMP	pt_0FA2
pt_018E:
	MOVE.W	D3,D7
	MOVE.W	D3,D0
	MOVE.W	D4,D1
	MOVE.W	D1,D3
	ADDQ.W	#1,D3
	MOVE.W	D5,D2
	JSR	pt_CloseGfxLib
	MOVE.W	D5,D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D2
	MOVE.W	D4,D1
	ADDQ.W	#1,D1
	MOVE.W	D6,D3
	ADDQ.W	#1,D3
	JSR	pt_CloseGfxLib
	MOVE.W	D7,D0
	ADDQ.W	#1,D0
	MOVE.W	D5,D2
	MOVE.W	D6,D1
	MOVE.W	D6,D3
	ADDQ.W	#1,D3
	JSR	pt_CloseGfxLib
	MOVE.W	D7,D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D2
	MOVE.W	D4,D1
	ADDQ.W	#1,D1
	MOVE.W	D6,D3
	JMP	pt_CloseGfxLib
dat_RenderCounter:
	DS.W	1
dat_RenderMode:
	DS.W	1
pt_SetDrawOffset:
	MOVE.W	D0,dat_DrawOffsetX
	MOVE.W	D1,dat_DrawOffsetY
pt_ProcessScopeCmd:
	MOVE.W	(A0)+,D0
	BEQ.W	pt_ProcessScopeExit
	CMP.W	#$0001,D0
	BNE.S	pt_0193
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	MOVE.W	#$0001,dat_ScopeStepX
	MOVE.W	#$0003,dat_ScopeStepY
	BSR.W	pt_CheckDraw2
	BRA.S	pt_ProcessScopeCmd
pt_0193:
	CMP.W	#$0002,D0
	BNE.S	pt_0194
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	MOVE.W	#$0003,dat_ScopeStepX
	MOVE.W	#$0001,dat_ScopeStepY
	BSR.W	pt_CheckDraw2
	BRA.S	pt_ProcessScopeCmd
pt_0194:
	CMP.W	#$0003,D0
	BNE.S	pt_0195
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	MOVE.W	#$0001,dat_ScopeStepX
	MOVE.W	#$0003,dat_ScopeStepY
	BSR.W	pt_CheckDraw3
	BRA.W	pt_ProcessScopeCmd
pt_0195:
	CMP.W	#$0004,D0
	BNE.S	pt_0196
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	MOVE.W	#$0003,dat_ScopeStepX
	MOVE.W	#$0001,dat_ScopeStepY
	BSR.W	pt_CheckDraw3
	BRA.W	pt_ProcessScopeCmd
pt_0196:
	CMP.W	#$0005,D0
	BNE.S	pt_0197
	MOVE.W	(A0)+,D5
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	BSR.W	pt_019F
	BRA.W	pt_ProcessScopeCmd
pt_0197:
	CMP.W	#$0006,D0
	BNE.S	pt_0198
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	LEA	pt_BlitPatternRow,A2
	BSR.W	pt_MemsetLoop
	BRA.W	pt_ProcessScopeCmd
pt_0198:
	CMP.W	#$0007,D0
	BNE.S	pt_0199
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	LEA	pt_SaveRegsAudioProc,A2
	BSR.S	pt_MemsetLoop
	BRA.W	pt_ProcessScopeCmd
pt_0199:
	CMP.W	#$0008,D0
	BNE.S	pt_019A
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	LEA	pt_SaveAllRegsProc,A2
	BSR.S	pt_MemsetLoop
	BRA.W	pt_ProcessScopeCmd
pt_019A:
	CMP.W	#$000a,D0
	BNE.S	pt_019B
	MOVE.W	(A0)+,D5
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MOVE.W	(A0)+,D3
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	ADD.W	(dat_DrawOffsetX,PC),D2
	ADD.W	(dat_DrawOffsetY,PC),D3
	JSR	pt_11D7
	BRA.W	pt_ProcessScopeCmd
pt_019B:
	CMP.W	#$0009,D0
	BNE.S	pt_ProcessScopeExit
	MOVE.W	(A0)+,D5
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	ADD.W	(dat_DrawOffsetX,PC),D0
	ADD.W	(dat_DrawOffsetY,PC),D1
	JSR	pt_11D3
	BRA.W	pt_ProcessScopeCmd
pt_ProcessScopeExit:
	RTS
pt_MemsetLoop:
	MOVEM.L	D0-D7,-(A7)
	MOVEA.L	A0,A1
	MOVEQ	#-1,D3
pt_019E:
	ADDQ.W	#1,D3
	TST.B	(A0)+
	BNE.S	pt_019E
	MOVE.L	A0,D4
	ADDQ.L	#1,D4
	AND.L	#$fffffffe,D4
	MOVEA.L	D4,A0
	MOVE.L	A0,-(A7)
	MOVEA.L	A1,A0
	JSR	(A2)
	MOVEA.L	(A7)+,A0
	MOVEM.L	(A7)+,D0-D7
	RTS
pt_019F:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.W	D2
	BLE.S	pt_DrawLoopEnd
	TST.W	D3
	BLE.S	pt_DrawLoopEnd
	ADD.W	D0,D2
	ADD.W	D1,D3
	JSR	pt_WaitAndRedrawUI
pt_DrawLoopEnd:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CheckDraw2:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.W	D2
	BLE.W	pt_LoopEndClean
	TST.W	D3
	BLE.W	pt_LoopEndClean
	ADD.W	D0,D2
	ADD.W	D1,D3
	MOVE.W	D0,dat_ScopeX1
	MOVE.W	D1,dat_ScopeY1
	MOVE.W	D2,dat_ScopeX2
	MOVE.W	D3,dat_ScopeY2
	MOVEQ	#2,D5
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX1,PC),D0
	MOVE.W	(dat_ScopeX2,PC),D2
	MOVE.W	(dat_ScopeY1,PC),D1
	SUBQ.W	#1,D2
	MOVE.W	D1,D3
	ADDQ.W	#1,D3
	MOVE.W	(dat_ScopeStepX,PC),D5
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX1,PC),D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D2
	MOVE.W	(dat_ScopeY1,PC),D1
	ADDQ.W	#1,D1
	MOVE.W	(dat_ScopeY2,PC),D3
	SUBQ.W	#1,D3
	MOVE.W	(dat_ScopeStepX,PC),D5
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX2,PC),D0
	MOVE.W	D0,D2
	SUBQ.W	#1,D0
	MOVE.W	(dat_ScopeY1,PC),D1
	ADDQ.W	#1,D1
	MOVE.W	(dat_ScopeY2,PC),D3
	MOVE.W	(dat_ScopeStepY,PC),D5
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX1,PC),D0
	ADDQ.W	#1,D0
	MOVE.W	(dat_ScopeX2,PC),D2
	MOVE.W	(dat_ScopeY2,PC),D1
	MOVE.W	D1,D3
	SUBQ.W	#1,D1
	MOVE.W	(dat_ScopeStepY,PC),D5
	JSR	pt_WaitAndRedrawUI
pt_LoopEndClean:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CheckDraw3:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.W	D2
	BLE.W	pt_LineEndClean
	TST.W	D3
	BLE.W	pt_LineEndClean
	ADD.W	D0,D2
	ADD.W	D1,D3
	MOVE.W	D0,dat_ScopeX1
	MOVE.W	D1,dat_ScopeY1
	MOVE.W	D2,dat_ScopeX2
	MOVE.W	D3,dat_ScopeY2
	MOVEQ	#2,D5
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX1,PC),D0
	MOVE.W	(dat_ScopeX2,PC),D2
	MOVE.W	(dat_ScopeY1,PC),D1
	SUBQ.W	#1,D2
	MOVE.W	D1,D3
	ADDQ.W	#1,D3
	MOVE.W	(dat_ScopeStepX,PC),D5
	JSR	pt_WaitAndRedrawUI
	ADDQ.W	#1,D1
	ADDQ.W	#1,D3
	SUBQ.W	#1,D2
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX1,PC),D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D2
	MOVE.W	(dat_ScopeY1,PC),D1
	ADDQ.W	#1,D1
	MOVE.W	(dat_ScopeY2,PC),D3
	SUBQ.W	#1,D3
	MOVE.W	(dat_ScopeStepX,PC),D5
	JSR	pt_WaitAndRedrawUI
	ADDQ.W	#1,D0
	ADDQ.W	#1,D2
	SUBQ.W	#1,D3
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX2,PC),D0
	MOVE.W	D0,D2
	SUBQ.W	#1,D0
	MOVE.W	(dat_ScopeY1,PC),D1
	ADDQ.W	#1,D1
	MOVE.W	(dat_ScopeY2,PC),D3
	MOVE.W	(dat_ScopeStepY,PC),D5
	JSR	pt_WaitAndRedrawUI
	SUBQ.W	#1,D0
	SUBQ.W	#1,D2
	ADDQ.W	#1,D1
	JSR	pt_WaitAndRedrawUI
	MOVE.W	(dat_ScopeX1,PC),D0
	ADDQ.W	#1,D0
	MOVE.W	(dat_ScopeX2,PC),D2
	MOVE.W	(dat_ScopeY2,PC),D1
	MOVE.W	D1,D3
	SUBQ.W	#1,D1
	MOVE.W	(dat_ScopeStepY,PC),D5
	JSR	pt_WaitAndRedrawUI
	SUBQ.W	#1,D1
	SUBQ.W	#1,D3
	ADDQ.W	#1,D0
	JSR	pt_WaitAndRedrawUI
pt_LineEndClean:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
dat_DrawOffsetX:
	DS.W	1
dat_DrawOffsetY:
	DS.W	1
dat_ScopeStepX:
	DC.W	$0001
dat_ScopeStepY:
	DC.W	$0002
dat_ScopeX1:
	DS.W	1
dat_ScopeY1:
	DS.W	1
dat_ScopeX2:
	DS.W	1
dat_ScopeY2:
	DS.W	1
pt_01AD:
	CMPI.W	#$0003,dat_UIMode
	BEQ.W	pt_BtnDiskMainMenu
	BSR.W	pt_EditModeDispatcher
pt_BtnMainDiskOp:
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.W	#$ffff,dat_VBLSyncWord
	BSR.W	pt_WaitMouseRelease
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.W	#$ffff,dat_VBLSyncWord
	MOVE.W	#$0003,dat_UIMode
	BSR.W	pt_ClearKeyState
	ST	dat_EditInputLock
	BSR.W	pt_InitAudioDisplay
	BSR.W	pt_CallStoreModule
	BNE.W	pt_LeaveToMain
	BSR.W	pt_01D4
	BSR.W	pt_ProcessHitbox
	BSR.W	pt_01C9
	BSR.W	pt_01CC
	BSR.W	pt_SampleNameRotate
	BSR.W	pt_026F
	BSR.W	pt_ShowFileSelector
	BSR.W	pt_TextInputMainLoop
	CLR.W	dat_DiskOpFlag
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVE.W	(24,A5),D0
	BSR.W	pt_DrawSampleEdAndUpdate
	BSR.W	pt_ScanButtonHitbox
	BTST	#3,dat_UIStateFlag
	BEQ.S	pt_SampleEdMode1Check
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	TST.W	(8,A5)
	BNE.S	pt_SampleEdMode1Check
pt_01AF:
	MOVE.W	dat_TextInputIdx,D0
	CMP.W	#$0002,D0
	BEQ.W	pt_EnterSampleEditMode
	BRA.W	pt_SampleEditorEntry
pt_SampleEdMode1Check:
	MOVE.W	dat_TextInputIdx,D0
	CMP.W	#$0001,D0
	BEQ.W	pt_SampleEditorMode0
	CMP.W	#$0002,D0
	BEQ.W	pt_SampleEditorEntry
	CMP.W	#$0003,D0
	BEQ.W	pt_SampleEditorMode2
	CMP.W	#$0004,D0
	BEQ.W	pt_SampleEditorMode3
	CMP.W	#$0005,D0
	BEQ.W	pt_SampleEditorSetup
	CMP.W	#$0006,D0
	BEQ.W	pt_SampleEditorMode5
	RTS
pt_CallStoreModule:
	LEA	dat_145F,A0
	JSR	pt_StoreModulePtr
	RTS
pt_InputDiskOp:
	MOVEA.L	(dat_ButtonHitboxes,PC),A5
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_142E,A0
	BSR.W	pt_HandleUIButton
	TST.W	D2
	BNE.S	pt_01B3
	RTS
pt_01B3:
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnDiskMainMenu
	CMP.W	#$0002,D2
	BEQ.W	pt_BtnDiskPacking
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnDiskSampForm
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnDiskModForm
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnDiskHideInfo
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnDiskResetPaths
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnDiskFormat
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnDiskRelabel
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnDiskMask
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnDiskMakeDir
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnDiskRenameFile
	CMP.W	#$000c,D2
	BEQ.W	pt_BtnDiskDeleteFile
	CMP.W	#$000d,D2
	BEQ.W	pt_BtnDiskPath
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnDiskFile
	CMP.W	#$000f,D2
	BEQ.W	pt_ScreenStateHandler
	CMP.W	#$0010,D2
	BEQ.W	pt_BtnDiskReadDir
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnDiskParent
	CMP.W	#$0012,D2
	BEQ.W	pt_BtnDiskFileType
	CMP.W	#$0014,D2
	BEQ.W	pt_SampleEditorMode0
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnDiskSaveExe
	CMP.W	#$0016,D2
	BEQ.W	pt_SampleEditorEntry
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnDiskSaveModule
	CMP.W	#$0018,D2
	BEQ.W	pt_SampleEditorMode2
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnDiskSaveSong
	CMP.W	#$001a,D2
	BEQ.W	pt_SampleEditorMode3
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnDiskSaveTrack
	CMP.W	#$001c,D2
	BEQ.W	pt_SampleEditorSetup
	CMP.W	#$001d,D2
	BEQ.W	pt_SampleEditorBranch
	CMP.W	#$001e,D2
	BEQ.W	pt_SampleEditorMode5
	CMP.W	#$001f,D2
	BEQ.W	pt_BtnDiskSavePatt
	CMP.W	#$0020,D2
	BEQ.W	pt_SampleEdDrawMode
	CMP.W	#$0021,D2
	BEQ.W	pt_BtnDiskListScroll
	CMP.W	#$0022,D2
	BEQ.W	pt_SampleEdDrawXPos
	CMP.W	#$0025,D2
	BEQ.W	pt_BtnDiskFree
	CMP.W	#$0026,D2
	BEQ.W	pt_BtnDiskFileList
	CMP.W	#$0064,D2
	BCC.W	pt_01E6
	RTS
