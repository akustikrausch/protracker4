pt_PalColorShadeTab:
	MOVE.L	#$f800f000,D4
	MOVE.L	#$f0008800,D5
	MOVE.L	#$80007800,D6
pt_0FDE:
	CMP.W	#$0053,D2
	BMI.S	pt_0FDF
	MOVEQ	#83,D2
pt_0FDF:
	CMP.W	#$0004,D2
	BPL.S	pt_0FE0
	MOVEQ	#4,D2
pt_0FE0:
	MOVEA.L	dat_SpriteBufAddr,A0
	CMPA.L	#$00000000,A0
	BEQ.S	pt_0FE1
	MOVE.L	(A0),dat_14B5
pt_0FE1:
	LEA	dat_SongModifiedFlag2,A0
	LEA	(4,A0),A0
	MOVE.L	D4,(A0)+
	MOVE.W	D2,D3
	SUBQ.W	#3,D3
pt_0FE2:
	MOVE.L	D5,(A0)+
	DBF	D3,pt_0FE2
	MOVE.L	D6,(A0)+
	MOVE.L	A0,dat_SpriteBufAddr
	LEA	dat_14B5,A1
	MOVEQ	#43,D3
pt_0FE3:
	MOVE.B	(A1)+,(A0)+
	DBF	D3,pt_0FE3
	LEA	dat_SongModifiedFlag2,A0
	BRA.W	pt_DrawSprite
pt_0FE4:
	TST.L	dat_FileWriteSize
	BEQ.S	pt_0FE5
	TST.L	dat_FileWriteAddr
	BEQ.S	pt_0FE5
	JSR	pt_SetPaletteDim
	LEA	(dat_12B6,PC),A0
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_ScreenBufPtr,PC),D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	(dat_FileWriteAddr,PC),D2
	MOVE.L	(dat_FileWriteSize,PC),D3
	JSR	(-42,A6)
	MOVE.L	(dat_FileHandle,PC),D1
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
pt_0FE5:
	JSR	pt_SetPaletteBright
	BSR.W	pt_ClearStatusMsg
	MOVEQ	#-1,D0
	RTS
	JSR	pt_SetPaletteDim
	LEA	(dat_12BD+25,PC),A0
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_ScreenBufPtr,PC),D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	(dat_FileWriteAddr,PC),D2
	MOVE.L	(dat_FileWriteSize,PC),D3
	JSR	(-48,A6)
	MOVE.L	(dat_FileHandle,PC),D1
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
	JMP	pt_SetPaletteBright
pt_0FE6:
	LEA	(dat_0FEB,PC),A0
	BRA.W	pt_ShowMsgSetPal
pt_0FE7:
	LEA	(dat_0FEC,PC),A0
	BRA.W	pt_ShowMsgSetPal
pt_0FE8:
	LEA	(dat_0FED,PC),A0
	BRA.W	pt_ShowMsgSetPal
pt_0FE9:
	LEA	(dat_0FEE,PC),A0
	BRA.W	pt_ShowMsgSetPal
dat_0FEA:
	DC.B	"CAN'T OPEN FILE !",0
dat_0FEB:
	DC.B	"CAN'T SAVE FILE !",0
dat_0FEC:
	DC.B	"EXAMINE ERROR !",0
dat_0FED:
	DC.B	"CAN'T FIND FILE !",0
dat_0FEE:
	DC.B	"FILE IS EMPTY !",0
pt_EnterPlst:
	CLR.B	dat_KeyCode
	CMPI.W	#$0006,dat_UIMode
	BEQ.W	pt_BtnPlstExit
	JSR	pt_EditModeDispatcher
	JSR	pt_WaitMouseRelease
	MOVE.W	#$0006,dat_UIMode
	ST	dat_EditInputLock
	ST	dat_ScopeBufferRef
	BSR.S	pt_0FF3
	BEQ.W	pt_BtnPlstExit
	CLR.W	dat_EditCursorVar
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	MOVE.W	#$0987,D0
pt_0FF0:
	CLR.L	(A0)+
	DBF	D0,pt_0FF0
	JSR	pt_SetPaletteBright
pt_PaletteEditorLoop:
	BSR.W	pt_1040
pt_0FF2:
	BSR.S	pt_EditFieldDrawText
	BSR.W	pt_RenderPaletteEdit
	BSR.W	pt_PalEditorRefresh
	BSR.W	pt_EditBufToDisplay
	RTS
pt_0FF3:
	LEA	dat_1465,A0
	JSR	pt_StoreModulePtr
	MOVEQ	#-1,D0
	RTS
pt_SetDisplayField2:
	MOVE.W	#$04c0,dat_TextBytePos
	MOVE.W	#$0005,dat_TextCharCount
	MOVEA.L	#dat_1313,A0
	BSR.W	pt_DrawTextSetup
	ADDQ.W	#1,dat_TextBytePos
	MOVEA.L	#dat_1317,A0
	BSR.W	pt_DrawTextSetup
	ADDQ.W	#1,dat_TextBytePos
	MOVEA.L	#dat_131B,A0
	BRA.W	pt_DrawTextSetup
pt_EditFieldDrawText:
	TST.L	dat_EditBufPtr
	BEQ.W	pt_0FFE
	TST.L	dat_EditFieldBufPtr
	BEQ.W	pt_0FFE
	MOVEA.L	(dat_EditBufPtr,PC),A0
	MOVE.W	(dat_EditBufX,PC),D7
	SUBQ.W	#1,D7
	TST.B	dat_SongInfoFlag
	BNE.S	pt_0FF6
	TST.B	dat_ModuleNameFlag
	BNE.S	pt_0FF6
	TST.B	dat_SampleNameFlag
	BEQ.S	pt_0FFD
pt_0FF6:
	MOVEA.L	(dat_1314,PC),A3
	MOVEA.L	(dat_1318,PC),A4
	MOVEA.L	(dat_131C,PC),A5
	MOVEQ	#0,D6
pt_0FF7:
	MOVE.W	#$7374,(A0)
	MOVE.B	(3,A0),D0
	CMP.B	#$61,D0
	BCS.S	pt_0FF8
	SUB.B	#$20,D0
pt_0FF8:
	MOVE.B	D0,(3,A0)
	MOVE.B	(4,A0),D0
	CMP.B	#$61,D0
	BCS.S	pt_0FF9
	SUB.B	#$20,D0
pt_0FF9:
	MOVE.B	D0,(4,A0)
	MOVE.L	(2,A0),D0
	CMP.L	A3,D0
	BNE.S	pt_0FFA
	MOVE.W	#$5354,(A0)
	ADDQ.W	#1,D6
	BRA.S	pt_AdvanceRecordPtr
pt_0FFA:
	CMP.L	A4,D0
	BNE.S	pt_0FFB
	MOVE.W	#$5354,(A0)
	ADDQ.W	#1,D6
	BRA.S	pt_AdvanceRecordPtr
pt_0FFB:
	CMP.L	A5,D0
	BNE.S	pt_AdvanceRecordPtr
	MOVE.W	#$5354,(A0)
	ADDQ.W	#1,D6
pt_AdvanceRecordPtr:
	ADDA.W	#$001e,A0
	DBF	D7,pt_0FF7
	MOVE.W	D6,dat_EditFieldPos
	CLR.W	dat_EditBufLen
	CLR.L	dat_EditFieldBuf
	RTS
pt_0FFD:
	MOVE.W	#$5354,(A0)
	LEA	(30,A0),A0
	DBF	D7,pt_0FFD
	MOVE.W	(dat_EditBufX,PC),dat_EditFieldPos
	CLR.W	dat_EditBufLen
	CLR.L	dat_EditFieldBuf
	RTS
pt_0FFE:
	CLR.W	dat_EditFieldPos
	CLR.W	dat_EditBufLen
	CLR.L	dat_EditFieldBuf
	RTS
pt_RenderPaletteEdit:
	MOVE.W	(dat_EditFieldPos,PC),dat_DisplayParam
	MOVE.W	#$015d,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	BSR.W	pt_SetDisplayField2
	MOVE.L	(dat_EditFieldBuf,PC),D6
	MOVEA.L	(dat_EditBufPtr,PC),A6
	MOVEA.W	#$0169,A5
	LEA	(dat_EditFieldBuf,PC),A4
	MOVEQ	#18,D7
	TST.L	D6
	BMI.W	pt_WriteDisplayBuf
pt_1000:
	CMPI.W	#$5354,(0,A6,D6.L)
	BNE.W	pt_1005
	MOVE.L	D6,(A4)+
	MOVE.W	A5,dat_TextBytePos
	MOVE.W	#$0013,dat_TextCharCount
	LEA	(0,A6,D6.L),A3
	BTST	#1,dat_FontMode
	BEQ.S	pt_1001
	BSET	#1,dat_FileStatus
	BCLR	#1,dat_FontMode
pt_1001:
	MOVE.L	A3,dat_TextStringPtr
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BTST	#1,dat_FileStatus
	BEQ.S	pt_1002
	BSET	#1,dat_FontMode
pt_1002:
	BTST	#7,dat_ModeFlags
	BNE.S	pt_1003
	ADDQ.W	#3,dat_TextBytePos
	MOVE.W	(22,A6,D6.L),dat_DisplayParam
	MOVE.W	dat_DisplayParam,D0
	LSL.W	#1,D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_DrawDecValue2
	ADDQ.W	#1,dat_TextBytePos
	MOVE.W	(26,A6,D6.L),dat_DisplayParam
	MOVE.W	dat_DisplayParam,D0
	LSL.W	#1,D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_DrawDecValue2
	ADDQ.W	#1,dat_TextBytePos
	MOVE.W	(28,A6,D6.L),dat_DisplayParam
	MOVE.W	dat_DisplayParam,D0
	LSL.W	#1,D0
	MOVE.W	D0,dat_DisplayParam
	BSR.W	pt_DrawDecValue2
	BRA.S	pt_1004
pt_1003:
	ADDI.W	#$000b,dat_TextBytePos
	MOVEQ	#0,D0
	MOVE.W	(22,A6,D6.L),D0
	LSL.W	#1,D0
	BSR.W	pt_FormatNumToDecimal
pt_1004:
	ADD.L	#$0000001e,D6
	CMP.L	(dat_EditFieldBufPtr,PC),D6
	BHI.S	pt_WriteDisplayBuf
	ADDA.W	#$01e0,A5
	DBF	D7,pt_1000
	RTS
pt_1005:
	ADD.L	#$0000001e,D6
	CMP.L	(dat_EditFieldBufPtr,PC),D6
	BHI.S	pt_WriteDisplayBuf
	BRA.W	pt_1000
pt_WriteDisplayBuf:
	MOVE.L	#$ffffffff,(A4)+
	MOVE.W	A5,dat_TextBytePos
	MOVE.W	#$0026,dat_TextCharCount
	MOVE.L	#pt_SampleEdEntry,dat_TextStringPtr
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_DrawTextWithFill
	MOVEM.L	(A7)+,D0-D7/A0-A6
	ADDA.W	#$01e0,A5
	DBF	D7,pt_WriteDisplayBuf
	RTS
pt_BtnPlstDisk3:
	LEA	(dat_SongInfoFlag,PC),A6
	MOVE.W	#$009c,dat_PlayCounter
	BRA.S	pt_100A
pt_BtnPlstDisk2:
	LEA	(dat_ModuleNameFlag,PC),A6
	MOVE.W	#$00cc,dat_PlayCounter
	BRA.S	pt_100A
pt_BtnPlstDisk1:
	LEA	(dat_SampleNameFlag,PC),A6
	MOVE.W	#$00fc,dat_PlayCounter
pt_100A:
	MOVE.W	#$0001,dat_PlaybackActive
	CLR.B	(A6)
	CLR.B	(1,A6)
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	BSR.W	pt_SetDisplayField2
	MOVE.W	#$0014,dat_PatternDelay
	JSR	pt_DrawPlayCounter
	JSR	pt_UpdateDisplayInput
	TST.B	dat_KeyCode
	BNE.W	pt_ClearKeyAndPalette
	RMB
	BEQ.W	pt_ClearKeyAndPalette
	ADD.W	D1,D1
	LEA	(str_NoteNames,PC),A0
	MOVE.B	(0,A0,D1.W),(A6)
	ADDQ.W	#8,dat_PlayCounter
	BSR.W	pt_SetDisplayField2
	JSR	pt_DrawPlayCounter
	JSR	pt_UpdateDisplayInput
	TST.B	dat_KeyCode
	BNE.W	pt_ClearKeyAndPalette
	RMB
	BEQ.W	pt_ClearKeyAndPalette
	ADD.W	D1,D1
	LEA	(str_NoteNames,PC),A0
	MOVE.B	(0,A0,D1.W),(1,A6)
	JSR	pt_RestorePalette
	BSR.W	pt_EditFieldDrawText
	BSR.W	pt_RenderPaletteEdit
	CLR.W	dat_PlayCounter
	MOVE.W	#$010e,dat_PatternDelay
	JSR	pt_DrawPlayCounter
	BRA.W	pt_PaletteEditorLoop
pt_BtnPlstClear:
	CLR.W	dat_PlaybackActive
	BSR.S	pt_100C
	BSR.W	pt_EditFieldDrawText
	BRA.W	pt_PaletteEditorLoop
pt_100C:
	MOVEQ	#0,D0
	MOVE.B	D0,dat_SongInfoFlag
	MOVE.B	D0,dat_1316
	MOVE.B	D0,dat_ModuleNameFlag
	MOVE.B	D0,dat_131A
	MOVE.B	D0,dat_SampleNameFlag
	MOVE.B	D0,dat_131E
	MOVE.B	D0,dat_131F
	MOVE.B	D0,dat_1320
	RTS
pt_BtnPlstMountL:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteDim
	BSR.S	pt_100C
	MOVE.W	#$0001,dat_PlaybackActive
	LEA	(dat_1013,PC),A4
	MOVEM.L	D1-D7/A0-A6,-(A7)
	BSR.S	pt_ClearBrowserState
	MOVEM.L	(A7)+,D1-D7/A0-A6
	LEA	(dat_1313,PC),A0
	BSR.S	pt_GetBrowserState
	LEA	(dat_1014,PC),A4
	MOVEM.L	D1-D7/A0-A6,-(A7)
	BSR.S	pt_ClearBrowserState
	MOVEM.L	(A7)+,D1-D7/A0-A6
	LEA	(dat_1317,PC),A0
	BSR.S	pt_GetBrowserState
	LEA	(dat_1015,PC),A4
	MOVEM.L	D1-D7/A0-A6,-(A7)
	BSR.S	pt_ClearBrowserState
	MOVEM.L	(A7)+,D1-D7/A0-A6
	LEA	(dat_131B,PC),A0
	BSR.S	pt_GetBrowserState
	CLR.W	dat_PlaybackActive
	JSR	pt_RestorePalette
	BRA.W	pt_1012
pt_ClearBrowserState:
	CLR.L	dat_FileBrowserState
	CLR.L	dat_PatternEditVar
	CLR.L	dat_14EA
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	A4,D1
	MOVEQ	#-2,D2
	JSR	(-84,A6)
	MOVE.L	D0,dat_PatternIndexBuf
	BEQ.S	pt_ReturnError2
	MOVE.L	(dat_PatternIndexBuf,PC),D1
	MOVE.L	#dat_AudioDMAState,D2
	JSR	(-102,A6)
	TST.L	D0
	BEQ.S	pt_ReturnError2
	MOVE.L	(dat_PatternIndexBuf,PC),D1
	JSR	(-90,A6)
pt_ReturnError2:
	MOVEQ	#-1,D0
	RTS
pt_GetBrowserState:
	MOVE.W	dat_FileBrowserState,D0
	BEQ.S	pt_ReturnError2
	MOVE.W	#$5354,D1
	AND.W	#$1f1f,D0
	AND.W	#$1f1f,D1
	CMP.W	D0,D1
	BNE.S	pt_ClearKeyAndPalette
	MOVE.B	dat_14E8,D0
	LSL.W	#8,D0
	MOVE.B	dat_PatternEditVar,D0
	CMP.W	#$3030,D0
	BEQ.S	pt_ClearKeyAndPalette
	MOVE.B	D0,(4,A0)
	LSR.W	#8,D0
	MOVE.B	D0,(3,A0)
	MOVEQ	#0,D0
	RTS
pt_ClearKeyAndPalette:
	CLR.B	dat_KeyCode
	JSR	pt_RestorePalette
	CLR.B	(A6)
	CLR.B	(1,A6)
	CLR.W	dat_PlayCounter
	MOVE.W	#$010e,dat_PatternDelay
	JSR	pt_DrawPlayCounter
pt_1012:
	BSR.W	pt_EditFieldDrawText
	BRA.W	pt_RenderPaletteEdit
dat_1013:
	DC.B	"DF0:",0,0
dat_1014:
	DC.B	"DF1:",0,0
dat_1015:
	DC.B	"DF2:",0,0
pt_InputPlst:
	MOVEM.W	dat_SavedEditDigit,D0-D1
	LEA	dat_143B,A0
	JSR	pt_HandleUIButton
	TST.W	D2
	BEQ.W	pt_1017
	CMP.W	#$0001,D2
	BEQ.W	pt_BtnPlstExit
	CMP.W	#$0002,D2
	BEQ.W	pt_JmpScreenHandler
	CMP.W	#$0003,D2
	BEQ.W	pt_BtnPlstList
	CMP.W	#$0004,D2
	BEQ.W	pt_BtnPlstExit
	CMP.W	#$0005,D2
	BEQ.W	pt_BtnPlstClear
	CMP.W	#$0006,D2
	BEQ.W	pt_BtnPlstMountL
	CMP.W	#$0007,D2
	BEQ.W	pt_BtnPlstDisk1
	CMP.W	#$0008,D2
	BEQ.W	pt_BtnPlstDisk2
	CMP.W	#$0009,D2
	BEQ.W	pt_BtnPlstDisk3
	CMP.W	#$000a,D2
	BEQ.W	pt_BtnPlstUp
	CMP.W	#$000b,D2
	BEQ.W	pt_BtnPlstDown
	CMP.W	#$000c,D2
	BEQ.W	pt_1023
	CMP.W	#$000d,D2
	BEQ.W	pt_1025
	CMP.W	#$000e,D2
	BEQ.W	pt_BtnPlstScroll
	CMP.W	#$000f,D2
	BEQ.W	pt_BtnPlstSampleList
	CMP.W	#$0011,D2
	BEQ.W	pt_BtnPlstDeleteDisk
	CMP.W	#$0012,D2
	BEQ.W	pt_BtnPlstDeletePreset
	CMP.W	#$0013,D2
	BEQ.W	pt_BtnPlstInsertPreset
	CMP.W	#$0014,D2
	BEQ.W	pt_BtnPlstAddPath
	CMP.W	#$0015,D2
	BEQ.W	pt_BtnPlstClearPlst
	CMP.W	#$0016,D2
	BEQ.W	pt_BtnPlstPath
	CMP.W	#$0017,D2
	BEQ.W	pt_BtnPlstPrint
	CMP.W	#$0018,D2
	BEQ.W	pt_BtnPlstSave
	CMP.W	#$0019,D2
	BEQ.W	pt_BtnPlstLoad
	CMP.W	#$001a,D2
	BEQ.W	pt_BtnPlstPresetUp
	CMP.W	#$001b,D2
	BEQ.W	pt_BtnPlstPresetDown
	CMP.W	#$001c,D2
	BEQ.W	pt_BtnPlstPageUp
	CMP.W	#$001d,D2
	BEQ.W	pt_BtnPlstPageDown
	CMP.W	#$001e,D2
	BEQ.W	pt_BtnPlstDiskName
pt_1017:
	JSR	pt_InputMode5Keys
	RTS
pt_BtnPlstExit:
	CLR.W	dat_PalEditorX
	MOVE.W	#$0053,dat_PalEditorY
	MOVE.B	#$f8,dat_SongModifiedFlag3
	MOVE.L	#$ffffffff,dat_PrevTimeDays
	MOVE.L	#$ffffffff,dat_PrevTimeMins
	MOVE.L	#$ffffffff,dat_PrevTimeTicks
	CMPI.W	#$ffff,dat_VBLSyncWord
	BEQ.S	pt_LeavePlst
	MOVEM.L	D0-D3/A0,-(A7)
	JSR	pt_CalcVBLTick
	MOVEM.L	(A7)+,D0-D3/A0
	MOVE.W	#$ffff,dat_VBLSyncWord
	MOVE.W	#$ffff,dat_DiskOpFlag
pt_LeavePlst:
	MOVE.W	#$0001,dat_UIMode
	JSR	pt_WaitMouseRelease
	CLR.B	dat_KeyCode
	BSR.W	pt_0FF3
	JSR	pt_InitAudioDisplay
	JMP	pt_LeaveToMain
pt_BtnPlstUp:
	TST.W	dat_EditFieldPos
	BNE.S	pt_101B
	RTS
pt_101B:
	JSR	pt_RefreshDisplay
	BSR.W	pt_PalEditorRefresh
	MOVE.W	dat_EditBufLen,D0
	MOVE.W	D0,D2
	SUBQ.W	#1,D0
	TST.W	dat_KeyQual1
	BNE.S	pt_101C
	RMB
	BNE.S	pt_101D
pt_101C:
	SUB.W	#$0011,D0
pt_101D:
	TST.W	D0
	BPL.S	pt_CallSubAndInit
	CLR.W	D0
	BRA.S	pt_CallSubAndInit
pt_BtnPlstDown:
	TST.W	dat_EditFieldPos
	BNE.S	pt_101F
	RTS
pt_101F:
	JSR	pt_RefreshDisplay
	BSR.W	pt_PalEditorRefresh
	MOVE.W	(dat_EditBufLen,PC),D0
	MOVE.W	D0,D2
	ADDQ.W	#1,D0
	TST.W	dat_KeyQual1
	BNE.S	pt_1020
	RMB
	BNE.S	pt_1021
pt_1020:
	ADD.W	#$0011,D0
pt_1021:
	MOVE.W	(dat_EditFieldPos,PC),D1
	SUB.W	#$0014,D1
	CMP.W	D0,D1
	BCC.S	pt_CallSubAndInit
	MOVE.W	D1,D0
pt_CallSubAndInit:
	BSR.S	pt_1027
	BRA.W	pt_RenderPaletteEdit
pt_1023:
	TST.W	dat_EditFieldPos
	BNE.S	pt_1024
	RTS
pt_1024:
	MOVE.W	#$0001,dat_EditBufLen
	BRA.W	pt_101B
pt_1025:
	TST.W	dat_EditFieldPos
	BNE.S	pt_1026
	RTS
pt_1026:
	MOVE.W	dat_EditFieldPos,dat_EditBufLen
	SUBQ.W	#1,dat_EditBufLen
	BRA.S	pt_101F
	BRA.W	pt_RenderPaletteEdit
pt_1027:
	MOVE.W	(dat_EditBufLen,PC),D1
	MOVE.W	D0,dat_EditBufLen
	CMP.W	D0,D1
	BNE.S	pt_CompareTrackNum
	RTS
pt_CompareTrackNum:
	TST.W	D0
	BEQ.S	pt_102B
	SUBQ.W	#1,D0
	MOVEA.L	(dat_EditBufPtr,PC),A0
	MOVEQ	#0,D6
pt_1029:
	CMPI.W	#$5354,(0,A0,D6.L)
	BEQ.S	pt_102A
	ADD.L	#$0000001e,D6
	BRA.S	pt_1029
pt_102A:
	ADD.L	#$0000001e,D6
	DBF	D0,pt_1029
	MOVE.L	D6,dat_EditFieldBuf
	RTS
pt_102B:
	CLR.L	dat_EditFieldBuf
	RTS
pt_BtnPlstList:
	SUBQ.L	#4,D1
	AND.L	#$0000ffff,D1
	DIVU	#$0006,D1
	LSL.W	#2,D1
	LEA	(dat_EditFieldBuf,PC),A0
	MOVE.L	(0,A0,D1.W),D1
	BPL.S	pt_102D
	RTS
pt_102D:
	DIVU	#$001e,D1
	ADDQ.W	#1,D1
	MOVE.W	D1,dat_12AE
	JSR	pt_WaitMouseRelease
	JMP	pt_0A23
dat_PalEditorX:
	DS.W	1
dat_PalEditorY:
	DS.W	1
dat_PalEdFieldPos:
	DS.W	1
pt_BtnPlstScroll:
	MOVE.W	dat_EditFieldPos,dat_PalEdFieldPos
	MOVE.W	#$ffff,dat_DiskOpFlag
	MOVE.W	dat_PalEdSelectPos,D1
	MOVE.W	(dat_PalEditorX,PC),D0
	ADD.W	#$0018,D0
	SUB.W	D0,D1
	BMI.W	pt_1036
	CMP.W	(dat_PalEditorY,PC),D1
	BPL.W	pt_1038
	MOVE.W	D1,D2
	MOVE.W	#$0053,D4
	SUB.W	(dat_PalEditorY,PC),D4
	BSR.W	pt_103C
	MOVE.W	dat_PalEdSelectPos,D1
pt_1032:
	JSR	pt_ScreenDragUpdate
	LMB
	BNE.S	pt_1035
	MOVE.W	D1,D3
	MOVE.W	dat_PalEdSelectPos,D1
	CMP.W	D1,D3
	BEQ.S	pt_1032
	SUB.W	D2,D1
	SUB.W	#$0018,D1
	BPL.S	pt_1033
	MOVEQ	#0,D1
pt_1033:
	CMP.W	D4,D1
	BMI.S	pt_1034
	MOVE.W	D4,D1
pt_1034:
	MOVE.W	D1,dat_PalEditorX
	BSR.W	pt_103A
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEdFieldPos,PC),D0
	SUB.W	#$0013,D0
	MULU	(dat_PalEditorX,PC),D0
	MOVE.W	#$0053,D1
	SUB.W	(dat_PalEditorY,PC),D1
	DIVU	D1,D0
	MOVE.W	D0,dat_EditBufLen
	BSR.W	pt_CompareTrackNum
	BSR.W	pt_RenderPaletteEdit
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LMB
	BEQ.S	pt_1032
pt_1035:
	BSR.W	pt_103B
	RTS
pt_1036:
	SUBI.W	#$0013,dat_EditBufLen
	BPL.S	pt_1037
	MOVE.W	#$0001,dat_EditBufLen
pt_1037:
	BSR.W	pt_PalEditorRefresh
	MOVE.W	dat_EditBufLen,D0
	BSR.W	pt_CompareTrackNum
	BSR.W	pt_RenderPaletteEdit
	RTS
pt_1038:
	ADDI.W	#$0013,dat_EditBufLen
	MOVE.W	(dat_PalEdFieldPos,PC),D0
	SUB.W	#$0013,D0
	CMP.W	dat_EditBufLen,D0
	BPL.S	pt_1039
	MOVE.W	D0,dat_EditBufLen
pt_1039:
	BSR.W	pt_PalEditorRefresh
	MOVE.W	dat_EditBufLen,D0
	BSR.W	pt_CompareTrackNum
	BSR.W	pt_RenderPaletteEdit
	RTS
pt_103A:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEditorX,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_PalEditorY,PC),D2
	LEA	dat_SongModifiedFlag2,A0
	BSR.W	pt_DrawSprite
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_103B:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEditorX,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_PalEditorY,PC),D2
	BSR.W	pt_PalColorShadeTab
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_103C:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_PalEditorX,PC),D1
	ADD.W	#$0018,D1
	MOVE.W	#$013d,D0
	MOVE.W	(dat_PalEditorY,PC),D2
	BSR.W	pt_InitHwPalette
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_PalEditorRefresh:
	MOVE.W	dat_EditFieldPos,dat_PalEdFieldPos
	MOVEM.L	D0-D3,-(A7)
	MOVEQ	#0,D3
	MOVE.W	#$0053,dat_PalEditorY
	CLR.W	dat_PalEditorX
	MOVEQ	#83,D0
	CLR.W	D1
	CMPI.W	#$0013,dat_PalEdFieldPos
	BMI.S	pt_103E
	BEQ.S	pt_103E
	MOVE.W	#$0629,D0
	MOVE.W	(dat_PalEdFieldPos,PC),D1
	EXT.L	D0
	DIVU	D1,D0
	MOVE.W	D0,dat_PalEditorY
	MOVE.W	dat_EditBufLen,D1
	MOVE.W	(dat_PalEdFieldPos,PC),D2
	MOVE.W	#$0053,D3
	SUB.W	D0,D3
	MULU	D1,D3
	SUB.W	#$0013,D2
	DIVU	D2,D3
	MOVE.W	D3,dat_PalEditorX
pt_103E:
	MOVE.W	(dat_PalEditorX,PC),D3
	ADD.W	(dat_PalEditorY,PC),D3
	CMP.W	#$0053,D3
	BMI.S	pt_103F
	MOVEQ	#83,D3
pt_103F:
	SUB.W	(dat_PalEditorY,PC),D3
	MOVE.W	D3,dat_PalEditorX
	BSR.W	pt_103B
	MOVEM.L	(A7)+,D0-D3
	RTS
pt_1040:
	CLR.W	dat_EditCursorVar
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	MOVE.W	#$0987,D0
pt_1041:
	CLR.L	(A0)+
	DBF	D0,pt_1041
	JSR	pt_SetPaletteBright
	BSR.W	pt_EditBufToDisplay
	BSR.W	pt_ProcessEditBuffer
	BSR.W	pt_BtnPlstPresetDown
	BSR.W	pt_BtnPlstPresetUp
	RTS
pt_BtnPlstAddPath:
	TST.L	dat_EditBufPtr
	BNE.S	pt_1043
	BSR.W	pt_SpeedAndReset
	TST.L	dat_EditBufPtr
	BEQ.W	pt_DosLibCall
pt_1043:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	#dat_SamplePathFmt,D1
	MOVEQ	#-2,D2
	JSR	(-84,A6)
	MOVE.L	D0,dat_PatternIndexBuf
	BEQ.W	pt_1050
	JSR	pt_SetPaletteDim
	LEA	(dat_12B5,PC),A0
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_PatternIndexBuf,PC),D1
	MOVE.L	#dat_AudioDMAState,D2
	JSR	(-102,A6)
	TST.L	D0
	BPL.W	pt_1050
	TST.L	dat_AudioDMACtrl
	BPL.S	pt_1044
	BSR.W	pt_1052
	BRA.S	pt_CheckEditBufSpeed
pt_1044:
	CMPI.B	#$2d,dat_14E7
	BNE.S	pt_CheckEditBufSpeed
	MOVE.B	dat_14E8,dat_ZeroCharBuf
	MOVE.B	dat_PatternEditVar,dat_TimeFormatStr
	BSR.W	pt_EditBufToDisplay
pt_CheckEditBufSpeed:
	MOVE.W	(dat_EditBufX,PC),D0
	CMP.W	dat_CurrentSpeed,D0
	BCS.S	pt_1046
	BSR.W	pt_10BE
	BRA.W	pt_DosLibCallAlt
pt_1046:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_PatternIndexBuf,PC),D1
	MOVE.L	#dat_AudioDMAState,D2
	JSR	(-108,A6)
	TST.L	D0
	BPL.W	pt_DosLibCallAlt
	RMB
	BEQ.W	pt_DosLibCallAlt
	TST.L	dat_AudioDMACtrl
	BPL.S	pt_CheckEditBufSpeed
	CMPI.L	#$2e696e66,dat_FileBrowserState
	BEQ.S	pt_CheckEditBufSpeed
	CMPI.L	#$2e696e66,dat_PatternEditVar
	BEQ.S	pt_CheckEditBufSpeed
	LEA	dat_FileBrowserState,A0
	MOVEQ	#28,D0
pt_1047:
	CMPI.B	#$2e,(A0)+
	BEQ.W	pt_104D
	DBF	D0,pt_1047
pt_FileOpenInit:
	CLR.W	dat_FileSizeVar
	MOVE.W	#$0001,dat_FileLengthVar
	LEA	dat_SamplePathFmt,A0
	JSR	pt_CopyFilename
	LEA	dat_FileBrowserState,A0
pt_1049:
	MOVE.B	(A0)+,(A1)+
	BNE.S	pt_1049
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.S	pt_104C
	MOVE.L	D0,D1
	LEA	(dat_1089,PC),A2
	CLR.L	(A2)
	MOVE.L	A2,D2
	MOVEQ	#12,D3
	JSR	(-42,A6)
	CMPI.L	#$464f524d,(A2)
	BNE.S	pt_OpenFileRead
	CMPI.L	#$38535658,(8,A2)
	BNE.S	pt_OpenFileRead
pt_104A:
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	A2,D2
	MOVEQ	#4,D3
	JSR	(-42,A6)
	TST.L	D0
	BEQ.S	pt_OpenFileRead
	CMPI.L	#$56484452,(A2)
	BNE.S	pt_104A
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	A2,D2
	MOVEQ	#12,D3
	JSR	(-42,A6)
	MOVE.L	(8,A2),D0
	BEQ.S	pt_OpenFileRead
	LSR.L	#1,D0
	MOVE.W	D0,dat_FileLengthVar
	MOVE.L	(4,A2),D0
	LSR.L	#1,D0
	MOVE.W	D0,dat_FileSizeVar
pt_OpenFileRead:
	MOVE.L	(dat_FileHandle,PC),D1
	JSR	(-36,A6)
pt_104C:
	BSR.S	pt_1052
	BSR.W	pt_EditBufToDisplay
	BSR.W	pt_0FF2
	BRA.W	pt_CheckEditBufSpeed
pt_104D:
	CMPI.B	#$69,(A0)+
	BNE.W	pt_FileOpenInit
	CMPI.B	#$6e,(A0)+
	BNE.W	pt_FileOpenInit
	CMPI.B	#$66,(A0)+
	BNE.W	pt_FileOpenInit
	CMPI.B	#$6f,(A0)+
	BNE.W	pt_FileOpenInit
	TST.B	(A0)+
	BNE.W	pt_FileOpenInit
	BRA.W	pt_CheckEditBufSpeed
pt_DosLibCallAlt:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_PatternIndexBuf,PC),D1
	BEQ.S	pt_104F
	JSR	(-90,A6)
pt_104F:
	JSR	pt_SetPaletteBright
	BSR.W	pt_ProcessEditBuffer
	BRA.W	pt_ClearStatusMsg
pt_1050:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_PatternIndexBuf,PC),D1
	BEQ.S	pt_1051
	JSR	(-90,A6)
pt_1051:
	JMP	pt_SetPaletteEdit
pt_1052:
	LEA	(dat_12F1,PC),A0
	LEA	(dat_SpacePadding,PC),A1
	MOVEQ	#21,D0
pt_1053:
	CLR.B	(A1)+
	DBF	D0,pt_1053
	LEA	(dat_SpacePadding,PC),A1
	MOVEQ	#5,D0
pt_1054:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_1054
	LEA	dat_FileBrowserState,A0
	MOVEQ	#14,D0
pt_1055:
	MOVE.B	(A0)+,D1
	BEQ.S	pt_1056
	MOVE.B	D1,(A1)+
	DBF	D0,pt_1055
pt_1056:
	CLR.B	(A1)
	MOVE.L	dat_PatternEditBuf,D0
	CMP.L	#$0000fffe,D0
	BLS.S	pt_1057
	MOVE.L	#$0000fffe,D0
pt_1057:
	LSR.W	#1,D0
	MOVE.W	D0,dat_EffectVarA
	CLR.W	dat_129A
	LEA	(dat_SpacePadding,PC),A6
	BSR.W	pt_1072
	ADDQ.W	#1,dat_EditBufX
	ADDI.L	#$0000001e,dat_EditFieldBufPtr
	RTS
pt_BtnPlstInsertPreset:
	TST.L	dat_EditBufPtr
	BNE.S	pt_1059
	BSR.W	pt_SpeedAndReset
	TST.L	dat_EditBufPtr
	BEQ.W	pt_DosLibCall
pt_1059:
	MOVE.W	(dat_EditBufX,PC),D0
	CMP.W	dat_SpeedResetVar,D0
	BCC.W	pt_10BE
	LEA	(dat_12FC,PC),A0
	LEA	(dat_SpacePadding,PC),A1
	MOVEQ	#39,D0
pt_105A:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_105A
pt_105B:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEA.L	(dat_ScreenBuf2Ptr,PC),A0
	LEA	(10592,A0),A0
	LEA	(dat_12B4,PC),A0
	BSR.W	pt_ShowStatusMsg
	MOVE.W	#$0053,dat_PatternDelay
	LEA	(dat_SpacePadding,PC),A6
	MOVEQ	#3,D7
	MOVE.B	#$04,dat_PlayMode
pt_DrawPointerInfo:
	LEA	(dat_12F6,PC),A0
	MOVEQ	#37,D0
	MOVE.W	#$1861,D1
	BSR.W	pt_DrawTextAt
	MOVE.W	D7,D0
	SUBQ.W	#3,D0
	ASL.W	#3,D0
	ADD.W	#$000c,D0
	MOVE.W	D0,dat_PlayCounter
	JSR	pt_DrawPlayCounter
pt_SampleEditorLoop:
	IFD	DEBUGAUTO
	JSR	dbg_AutoStep
	ENDC
	JSR	pt_GetKeypress
	MOVE.B	(dat_KeyCode,PC),D0
	BEQ.S	pt_SampleEditorLoop
	JSR	pt_HandleSampleKeys
	BTST	#7,D0
	BNE.S	pt_SampleEditorLoop
	CLR.B	dat_KeyCode
	AND.W	#$00ff,D0
	CMP.B	#$45,D0
	BEQ.W	pt_1069
	CMP.B	#$41,D0
	BEQ.W	pt_106A
	CMP.B	#$44,D0
	BEQ.W	pt_1066
	CMP.B	#$4f,D0
	BEQ.W	pt_106C
	CMP.B	#$4e,D0
	BEQ.W	pt_106F
	CMP.B	#$40,D0
	BHI.S	pt_SampleEditorLoop
	CMP.W	#$0028,D7
	BEQ.S	pt_SampleEditorLoop
	CMP.W	#$0016,D7
	BEQ.S	pt_SampleEditorLoop
	CMPI.B	#$01,dat_PatternBufSize
	BNE.S	pt_105E
	LEA	(dat_132E,PC),A0
	BRA.S	pt_1060
pt_105E:
	TST.B	dat_PatternBufSize
	BEQ.S	pt_105F
	TST.W	dat_KeymapBufPtr
	BEQ.S	pt_105F
	MOVEA.L	dat_KeymapBufPtr,A0
	BRA.S	pt_1060
pt_105F:
	LEA	(dat_1330,PC),A0
pt_1060:
	TST.W	dat_KeyQual1
	BEQ.S	pt_ReadByteIdx
	CMPI.B	#$01,dat_PatternBufSize
	BNE.S	pt_1061
	LEA	(dat_132F,PC),A0
	BRA.S	pt_ReadByteIdx
pt_1061:
	TST.B	dat_PatternBufSize
	BEQ.S	pt_1062
	TST.W	dat_KeymapBufPtr
	BEQ.S	pt_1062
	MOVEA.L	dat_KeymapBufPtr,A0
	ADDA.W	#$0041,A0
	BRA.S	pt_ReadByteIdx
pt_1062:
	LEA	(dat_1331,PC),A0
pt_ReadByteIdx:
	MOVE.B	(0,A0,D0.W),D1
	BEQ.W	pt_SampleEditorLoop
	CMP.W	#$0006,D7
	BCS.S	pt_1064
	CMP.W	#$0019,D7
	BCS.S	pt_StoreByteIdx
pt_1064:
	CMP.B	#$30,D1
	BCS.W	pt_SampleEditorLoop
	CMP.B	#$66,D1
	BHI.W	pt_SampleEditorLoop
	CMP.B	#$39,D1
	BLS.S	pt_StoreByteIdx
	CMP.B	#$61,D1
	BCC.S	pt_StoreByteIdx
	BRA.W	pt_SampleEditorLoop
pt_StoreByteIdx:
	MOVE.B	D1,(0,A6,D7.W)
	BRA.W	pt_106F
pt_1066:
	CMPI.B	#$20,dat_12F7
	BEQ.S	pt_1069
	LEA	dat_12F8,A0
	LEA	(dat_10B1,PC),A1
	MOVE.B	(A0)+,D1
	LSL.W	#8,D1
	MOVE.B	(A0),D1
	MOVEQ	#15,D0
pt_1067:
	CMP.W	-(A1),D1
	BEQ.S	pt_1068
	DBF	D0,pt_1067
	MOVEQ	#0,D0
pt_1068:
	MOVE.W	D0,dat_129A
	LEA	(dat_12F9,PC),A0
	BSR.W	pt_ReturnZero2
	LSR.W	#1,D0
	MOVE.W	D0,dat_EffectVarA
	LEA	(dat_12FA,PC),A0
	BSR.W	pt_ReturnZero2
	LSR.W	#1,D0
	MOVE.W	D0,dat_FileSizeVar
	LEA	(dat_12FB,PC),A0
	BSR.W	pt_ReturnZero2
	LSR.W	#1,D0
	MOVE.W	D0,dat_FileLengthVar
	BSR.W	pt_1072
	ADDQ.W	#1,dat_EditBufX
pt_1069:
	CLR.W	dat_PlayCounter
	MOVE.W	#$010e,dat_PatternDelay
	JSR	pt_DrawPlayCounter
	BSR.W	pt_ProcessEditBuffer
	BSR.W	pt_EditBufToDisplay
	BSR.W	pt_ClearStatusMsg
	CLR.B	dat_PlayMode
	JSR	pt_RestorePalette
	BRA.W	pt_PaletteEditorLoop
pt_106A:
	CMP.W	#$0017,D7
	BCC.S	pt_106B
	CMP.W	#$0006,D7
	BLS.S	pt_106B
	SUBQ.W	#1,D7
	MOVE.B	#$20,(0,A6,D7.W)
pt_106B:
	BRA.W	pt_DrawPointerInfo
pt_106C:
	SUBQ.W	#1,D7
	CMP.W	#$0002,D7
	BLS.S	pt_106E
	CMP.W	#$0005,D7
	BEQ.S	pt_PointerLeftCmd
	CMP.W	#$0016,D7
	BEQ.S	pt_PointerLeftCmd
	CMP.W	#$0019,D7
	BEQ.S	pt_PointerLeftCmd
	CMP.W	#$001e,D7
	BEQ.S	pt_PointerLeftCmd
	CMP.W	#$0023,D7
	BEQ.S	pt_PointerLeftCmd
	BRA.W	pt_DrawPointerInfo
pt_PointerLeftCmd:
	SUBQ.W	#1,D7
	BRA.W	pt_DrawPointerInfo
pt_106E:
	MOVEQ	#3,D7
	BRA.W	pt_DrawPointerInfo
pt_106F:
	ADDQ.W	#1,D7
	CMP.W	#$0005,D7
	BEQ.S	pt_PointerRightCmd
	CMP.W	#$0016,D7
	BEQ.S	pt_PointerRightCmd
	CMP.W	#$0019,D7
	BEQ.S	pt_PointerRightCmd
	CMP.W	#$001e,D7
	BEQ.S	pt_PointerRightCmd
	CMP.W	#$0023,D7
	BEQ.S	pt_PointerRightCmd
	CMP.W	#$0028,D7
	BCC.S	pt_1071
	BRA.W	pt_DrawPointerInfo
pt_PointerRightCmd:
	ADDQ.W	#1,D7
	BRA.W	pt_DrawPointerInfo
pt_1071:
	MOVEQ	#39,D7
	BRA.W	pt_DrawPointerInfo
pt_1072:
	MOVEQ	#23,D0
pt_1073:
	SUBQ.W	#1,D0
	CMPI.B	#$20,(0,A6,D0.W)
	BEQ.S	pt_1073
	CLR.B	(1,A6,D0.W)
	MOVEA.L	(dat_EditBufPtr,PC),A5
	SUBA.W	#$001e,A5
	LEA	(30,A5),A5
pt_1074:
	MOVEQ	#6,D0
	TST.B	(6,A5)
	BEQ.S	pt_CheckChannelFlag
pt_1075:
	MOVE.B	(0,A5,D0.W),D2
	BNE.S	pt_1076
	TST.B	(0,A6,D0.W)
	BNE.S	pt_1076
	CLR.B	(6,A5)
	SUBQ.W	#1,dat_EditBufX
	BRA.S	pt_CheckChannelFlag
pt_1076:
	CMP.B	#$41,D2
	BCS.S	pt_1077
	CMP.B	#$5a,D2
	BHI.S	pt_1077
	ADD.B	#$20,D2
pt_1077:
	MOVE.B	(0,A6,D0.W),D1
	CMP.B	#$41,D1
	BCS.S	pt_1078
	CMP.B	#$5a,D1
	BHI.S	pt_1078
	ADD.B	#$20,D1
pt_1078:
	CMP.B	D2,D1
	BEQ.S	pt_1079
	BHI.S	pt_107A
	BRA.S	pt_CheckChannelFlag
pt_1079:
	ADDQ.W	#1,D0
	CMP.W	#$0016,D0
	BNE.S	pt_1075
pt_107A:
	LEA	(30,A5),A5
	BRA.S	pt_1074
pt_CheckChannelFlag:
	TST.B	(6,A5)
	BEQ.S	pt_107D
	MOVEA.L	(dat_EditBufPtr,PC),A1
	SUBA.W	#$001e,A1
	MOVE.W	(dat_EditBufX,PC),D0
	BEQ.S	pt_107D
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A1
	LEA	(30,A1),A1
	CLR.B	(31,A1)
pt_107C:
	MOVE.W	(A1),(30,A1)
	SUBQ.L	#2,A1
	CMPA.L	A1,A5
	BLS.S	pt_107C
pt_107D:
	MOVEQ	#21,D0
pt_107E:
	MOVE.B	(0,A6,D0.W),D1
	ADD.B	#$20,D1
	CMP.B	#$41,D1
	BCS.S	pt_107F
	CMP.B	#$5a,D1
pt_107F:
	SUB.B	#$20,D1
	TST.B	D1
	BNE.S	pt_1080
	MOVEQ	#0,D1
pt_1080:
	MOVE.B	D1,(0,A5,D0.W)
	DBF	D0,pt_107E
	MOVE.W	(dat_EffectVarA,PC),(22,A5)
	MOVE.B	(dat_129B,PC),(24,A5)
	MOVE.B	#$40,(25,A5)
	MOVE.W	(dat_FileSizeVar,PC),(26,A5)
	MOVE.W	(dat_FileLengthVar,PC),(28,A5)
	RTS
pt_ReturnZero2:
	MOVEQ	#0,D0
	BSR.S	pt_ParseHexChar
	LSL.W	#8,D1
	LSL.W	#4,D1
	OR.W	D1,D0
	BSR.S	pt_ParseHexChar
	LSL.W	#8,D1
	OR.W	D1,D0
pt_BuildHexWord:
	BSR.S	pt_ParseHexChar
	LSL.W	#4,D1
	OR.W	D1,D0
	BSR.S	pt_ParseHexChar
	OR.W	D1,D0
	RTS
pt_ParseHexChar:
	MOVEQ	#0,D1
	MOVE.B	(A0)+,D1
	CMP.B	#$60,D1
	BCS.S	pt_1084
	SUB.B	#$20,D1
pt_1084:
	SUB.B	#$30,D1
	CMP.B	#$09,D1
	BLS.S	pt_1085
	SUBQ.B	#7,D1
pt_1085:
	RTS
pt_BtnPlstDeletePreset:
	JSR	pt_034F
	MOVE.W	#$0001,dat_EditCursorVar
	LEA	(dat_12C9,PC),A0
	BRA.W	pt_ShowStatusMsg
pt_BtnPlstClearPlst:
	LEA	dat_108A,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_1088
	RTS
pt_1088:
	BSR.W	pt_ClearSpeedState
	BRA.W	pt_PaletteEditorLoop
dat_1089:
	DS.L	3
dat_108A:
	DC.B	10,10,10
	DC.B	"    Clear the PLST?",0,0
pt_BtnPlstPrint:
	LEA	dat_12DC,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_108C
	RTS
pt_108C:
	JSR	pt_SavePaletteState
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	#dat_NotifyHookVec,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	JSR	pt_SetPaletteDim
	MOVE.L	D0,D1
	MOVE.L	#dat_12FD,D2
	MOVEQ	#56,D3
	JSR	(-48,A6)
	LEA	(dat_12D5,PC),A0
	BSR.W	pt_ShowStatusMsg
	CLR.W	dat_EditModeVar
pt_108D:
	MOVE.W	(dat_EditModeVar,PC),D0
	LEA	(dat_12FE,PC),A0
	BSR.W	pt_1093
	MOVEA.L	(dat_EditBufPtr,PC),A0
	SUBA.W	#$001e,A0
	MOVE.W	(dat_EditModeVar,PC),D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVE.L	A0,dat_RamTestPattern
	LEA	(dat_12FF,PC),A1
	MOVEA.L	A1,A2
	MOVEQ	#19,D1
pt_108E:
	MOVE.B	#$20,(A2)+
	DBF	D1,pt_108E
	MOVEQ	#19,D1
pt_108F:
	TST.B	(A0)
	BEQ.S	pt_1090
	MOVE.B	(A0)+,(A1)+
	DBF	D1,pt_108F
pt_1090:
	MOVEA.L	(dat_RamTestPattern,PC),A1
	MOVE.W	(22,A1),D0
	LEA	(dat_1300,PC),A0
	BSR.W	pt_HexDigitFormat
	MOVEA.L	(dat_RamTestPattern,PC),A1
	MOVE.W	(26,A1),D0
	LEA	(dat_1301,PC),A0
	BSR.W	pt_HexDigitFormat
	MOVEA.L	(dat_RamTestPattern,PC),A1
	MOVE.W	(28,A1),D0
	ADD.W	D0,D0
	LEA	(dat_1302,PC),A0
	BSR.S	pt_HexDigitFormat
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	#dat_12FE,D2
	MOVEQ	#53,D3
	JSR	(-48,A6)
	RMB
	BEQ.S	pt_1091
	ADDQ.W	#1,dat_EditModeVar
	MOVE.W	(dat_EditModeVar,PC),D0
	CMP.W	(dat_EditBufX,PC),D0
	BNE.W	pt_108D
	BRA.S	pt_1092
pt_1091:
	LEA	(dat_12B3,PC),A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_SetPaletteEdit
pt_1092:
	MOVE.L	(dat_FileHandle,PC),D1
	JSR	(-36,A6)
	BSR.W	pt_ClearStatusMsg
	JMP	pt_RestorePalette
pt_1093:
	MOVEQ	#3,D3
	MOVE.L	#$000003e8,D2
pt_1094:
	EXT.L	D0
	DIVU	D2,D0
	ADD.B	#$30,D0
	MOVE.B	D0,(A0)+
	DIVU	#$000a,D2
	SWAP	D0
	DBF	D3,pt_1094
	RTS
pt_1095:
	MOVEQ	#1,D2
	BRA.S	pt_1097
pt_HexDigitFormat:
	MOVEQ	#3,D2
pt_1097:
	MOVE.W	D0,D1
	AND.B	#$0f,D1
	CMP.B	#$0a,D1
	BCS.S	pt_1098
	ADDQ.B	#7,D1
pt_1098:
	ADD.B	#$30,D1
	MOVE.B	D1,-(A0)
	ROR.W	#4,D0
	DBF	D2,pt_1097
	RTS
pt_BtnPlstSave:
	LEA	dat_12EB,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_109A
	RTS
pt_109A:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteDim
	LEA	(dat_12C4,PC),A0
	BSR.W	pt_ShowStatusMsg
	LEA	dat_DrivePrefix,A0
	JSR	pt_CopyFilename
	LEA	(dat_10CE,PC),A0
	MOVEQ	#4,D0
pt_109B:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_109B
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ee,D2
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-30,A6)
	MOVE.L	D0,D7
	BEQ.W	pt_DrawWaveform
	MOVE.L	D0,D1
	MOVE.L	(dat_EditBufPtr,PC),D2
	MOVE.W	(dat_EditBufX,PC),D3
	MULU	#s_SIZEOF,D3
	JSR	(-48,A6)
	MOVE.L	D7,D1
	JSR	(-36,A6)
	BSR.W	pt_ClearStatusMsg
	JMP	pt_RestorePalette
pt_BtnPlstSampleList:
	BSR.W	pt_10B5
	CLR.W	dat_EditCursorVar
	JSR	pt_SetPaletteBright
	RTS
pt_BtnPlstPresetUp:
	SUBQ.W	#1,dat_EditBufY
	TST.W	dat_KeyQual1
	BNE.S	pt_109E
	JSR	pt_RefreshDisplay
	RMB
	BNE.S	pt_109F
pt_109E:
	SUBQ.W	#7,dat_EditBufY
pt_109F:
	CMPI.W	#$0001,dat_EditBufY
	BGE.S	pt_ProcessEditBuffer
pt_BtnPlstPageUp:
	MOVE.W	#$0001,dat_EditBufY
	BRA.S	pt_ProcessEditBuffer
pt_BtnPlstPresetDown:
	CMPI.W	#$0009,dat_EditBufX
	BCS.S	pt_ProcessEditBuffer
	JSR	pt_RefreshDisplay
	ADDQ.W	#1,dat_EditBufY
	TST.W	dat_KeyQual1
	BNE.S	pt_10A2
	RMB
	BNE.S	pt_10A3
pt_10A2:
	ADDQ.W	#7,dat_EditBufY
pt_10A3:
	MOVE.W	dat_EditBufX,D0
	SUB.W	#$000a,D0
	CMP.W	dat_EditBufY,D0
	BCC.S	pt_ProcessEditBuffer
pt_10A4:
	MOVE.W	D0,dat_EditBufY
	BRA.S	pt_ProcessEditBuffer
pt_BtnPlstPageDown:
	MOVE.W	(dat_EditBufX,PC),D0
	SUB.W	#$000b,D0
	BMI.S	pt_BtnPlstPageUp
	ADDQ.W	#1,D0
	BRA.S	pt_10A4
pt_ProcessEditBuffer:
	TST.W	dat_EditBufX
	BEQ.S	pt_10A7
	MOVE.W	#$0c31,D6
	MOVEQ	#6,D7
	MOVE.L	(dat_EditBufPtr,PC),D0
	SUB.W	#$001e,D0
	BNE.S	pt_10A8
pt_10A7:
	RTS
pt_10A8:
	MOVEA.L	D0,A5
	MOVE.W	(dat_EditBufY,PC),D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A5
pt_10A9:
	TST.B	(A5)
	BNE.S	pt_10AA
	RTS
pt_10AA:
	LEA	dat_1530,A1
	MOVEQ	#21,D0
pt_10AB:
	MOVE.B	#$20,(A1)+
	DBF	D0,pt_10AB
	MOVEA.L	A5,A0
	ADDQ.L	#3,A0
	LEA	(-22,A1),A1
pt_10AC:
	MOVE.B	(A0)+,D0
	BEQ.S	pt_10AD
	MOVE.B	D0,(A1)+
	BRA.S	pt_10AC
pt_10AD:
	BTST	#1,dat_FontMode
	BEQ.S	pt_10AE
	BSET	#1,dat_FileStatus
	BCLR	#1,dat_FontMode
pt_10AE:
	MOVE.W	#$0013,dat_TextCharCount
	LEA	dat_1530,A0
	MOVE.W	D6,D1
	LSL.L	#1,D1
	SUBQ.W	#1,D1
	MOVE.W	D1,dat_TextBytePos
	BSR.W	pt_DrawTextSetup
	BTST	#1,dat_FileStatus
	BEQ.S	pt_10AF
	BSET	#1,dat_FontMode
pt_10AF:
	ADD.W	#$0014,D6
	MOVE.W	D6,dat_TextBytePos
	MOVEQ	#0,D0
	MOVE.B	(24,A5),D0
	AND.B	#$0f,D0
	ADD.W	D0,D0
	LEA	(dat_10B0,PC,D0.W),A0
	MOVE.W	#$0002,dat_TextCharCount
	MOVE.W	D6,D1
	LSL.L	#1,D1
	SUB.W	#$0015,D1
	MOVE.W	D1,dat_TextBytePos
	BSR.W	pt_DrawTextSetup
	MOVE.W	(22,A5),D0
	ADD.W	D0,D0
	MOVE.W	D0,dat_DisplayParam
	ADDQ.W	#1,dat_TextBytePos
	BSR.W	pt_DrawDecValue2
	MOVE.W	(26,A5),D0
	ADD.W	D0,D0
	MOVE.W	D0,dat_DisplayParam
	ADDQ.W	#1,dat_TextBytePos
	BSR.W	pt_DrawDecValue2
	MOVE.W	(28,A5),D0
	ADD.W	D0,D0
	MOVE.W	D0,dat_DisplayParam
	ADDQ.W	#1,dat_TextBytePos
	BSR.W	pt_DrawDecValue2
	ADD.W	#$00dc,D6
	LEA	(30,A5),A5
	DBF	D7,pt_10A9
	RTS
dat_10B0:
	DC.B	" 0+1+2+3+4+5+6+7-8-7-6-5-4-3-2-1"
dat_10B1:
	DS.W	1
pt_BtnPlstPath:
	MOVE.W	#$0012,D1
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	CLR.L	dat_SongDataPtr
	LEA	dat_SamplePathFmt,A6
	JSR	pt_DrawPlayCounter
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDI.L	#$0000001f,dat_SongDataAddr
	MOVE.W	#$0014,dat_TextCharCount
	MOVEA.L	#$00000833,A4
	JSR	pt_UpdateKeyState
	CLR.L	dat_SongDataAddr
	JMP	pt_RestorePalette
pt_BtnPlstDiskName:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	CLR.L	dat_SongDataPtr
	CLR.B	dat_ZeroCharBuf
	CLR.B	dat_TimeFormatStr
	LEA	(dat_ZeroCharBuf,PC),A6
	MOVE.L	A6,dat_SongDataAddr
	MOVE.L	A6,dat_TextStringPtr
	ADDQ.L	#2,dat_SongDataAddr
	MOVE.W	#$0002,dat_TextCharCount
	MOVEA.L	#$00000ba5,A4
	MOVE.B	#$03,dat_PlayMode
	JSR	pt_UpdateKeyState
	LEA	(dat_ZeroCharBuf,PC),A6
	MOVE.B	#$3a,(2,A6)
	CLR.B	dat_PlayMode
	CLR.L	dat_SongDataAddr
	JSR	pt_RestorePalette
	BRA.W	pt_PaletteEditorLoop
pt_EditBufToDisplay:
	MOVE.W	dat_EditBufX,dat_DisplayParam
	MOVE.W	#$0f15,dat_TextBytePos
	BSR.W	pt_FormatDecimal
	LEA	dat_SamplePathFmt,A0
	MOVE.W	#$0833,D1
	MOVEQ	#20,D0
	BSR.W	pt_DrawTextAt
	LEA	dat_12F1,A0
	MOVE.W	#$0ba2,D1
	MOVEQ	#6,D0
	BRA.W	pt_DrawTextAt
	DC.W	$4e75
pt_10B5:
	CMPI.W	#$0001,dat_EditBufX
	BEQ.S	pt_ReturnFromRTS
	MOVE.W	(dat_SavedEditDigit,PC),D0
	MOVE.W	D1,D0
	SUB.W	#$0050,D0
	DIVU	#$0006,D0
	MOVE.L	D0,D1
	SWAP	D1
	CMP.W	#$0005,D1
	BEQ.S	pt_ReturnFromRTS
	MOVE.W	D0,D2
	ADD.W	(dat_EditBufY,PC),D2
	CMP.W	(dat_EditBufX,PC),D2
	BHI.S	pt_ReturnFromRTS
	MULU	#s_SIZEOF,D0
	MOVEA.L	(dat_EditBufPtr,PC),A5
	ADDA.L	D0,A5
	MOVE.W	(dat_EditBufY,PC),D0
	SUBQ.W	#1,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A5
	TST.W	dat_EditCursorVar
	BEQ.S	pt_10B7
	CMPI.W	#$0001,dat_EditCursorVar
	BEQ.S	pt_10BA
pt_ReturnFromRTS:
	RTS
pt_10B7:
	LEA	(dat_SpacePadding,PC),A0
	MOVEQ	#21,D0
pt_10B8:
	MOVE.B	(A5)+,D1
	BNE.S	pt_10B9
	MOVE.B	#$20,D1
pt_10B9:
	MOVE.B	D1,(A0)+
	DBF	D0,pt_10B8
	MOVEQ	#0,D0
	MOVE.B	(2,A5),D0
	AND.B	#$0f,D0
	ADD.W	D0,D0
	LEA	(dat_10B0,PC),A1
	LEA	(0,A1,D0.W),A1
	LEA	dat_12F8,A0
	MOVE.B	#$20,(-1,A0)
	MOVE.B	(A1)+,(A0)+
	MOVE.B	(A1),(A0)
	MOVE.W	(A5),D0
	ADD.W	D0,D0
	LEA	(6,A0),A0
	BSR.W	pt_HexDigitFormat
	MOVE.W	(4,A5),D0
	ADD.W	D0,D0
	LEA	(9,A0),A0
	BSR.W	pt_HexDigitFormat
	LEA	(9,A0),A0
	MOVE.W	(6,A5),D0
	ADD.W	D0,D0
	BSR.W	pt_HexDigitFormat
	BRA.W	pt_105B
pt_10BA:
	CLR.W	dat_EditCursorVar
	LEA	dat_12E9,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_10BB
	RTS
pt_10BB:
	MOVEA.L	(dat_EditBufPtr,PC),A1
	MOVE.W	(dat_EditBufX,PC),D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A1
pt_10BC:
	MOVE.W	(30,A5),(A5)
	ADDQ.L	#2,A5
	CMPA.L	A5,A1
	BHI.S	pt_10BC
	CLR.B	(A5)
	SUBQ.W	#1,dat_EditBufX
	SUBI.L	#$0000001e,dat_EditFieldBufPtr
	MOVE.W	(dat_EditBufY,PC),D0
	ADD.W	#$0009,D0
	CMP.W	(dat_EditBufX,PC),D0
	BHI.S	pt_10BD
	SUBQ.W	#1,dat_EditBufY
pt_10BD:
	BSR.W	pt_EditBufToDisplay
	BSR.W	pt_BtnPlstPresetUp
	BSR.W	pt_ProcessEditBuffer
	JSR	pt_SetPaletteBright
	JSR	pt_SavePaletteState
	BSR.W	pt_PaletteEditorLoop
	RTS
pt_10BE:
	LEA	(dat_12B2,PC),A0
	BSR.W	pt_ShowStatusMsg
	JMP	pt_SetPaletteEdit
pt_BtnPlstDeleteDisk:
	LEA	(dat_10C5,PC),A0
	MOVE.B	(dat_ZeroCharBuf,PC),(10,A0)
	MOVE.B	(dat_TimeFormatStr,PC),(11,A0)
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_10C0
	RTS
pt_10C0:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEA.L	(dat_EditBufPtr,PC),A0
	MOVEA.L	A0,A1
	MOVE.W	(dat_EditBufX,PC),D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A1
	MOVE.L	(dat_12F2,PC),D1
	MOVE.L	#$ff5f5fff,D2
	AND.L	D2,D1
pt_10C1:
	MOVE.L	(2,A0),D0
	AND.L	D2,D0
	CMP.L	D1,D0
	BNE.S	pt_10C3
	MOVEA.L	A0,A2
pt_10C2:
	MOVE.W	(30,A0),(A0)+
	CMPA.L	A1,A0
	BCS.S	pt_10C2
	SUBQ.W	#1,dat_EditBufX
	SUBI.L	#$0000001e,dat_EditFieldBufPtr
	MOVEA.L	A2,A0
	BRA.S	pt_10C4
pt_10C3:
	LEA	(30,A0),A0
pt_10C4:
	CMPA.L	A1,A0
	BCS.S	pt_10C1
	MOVE.W	#$0001,dat_EditBufY
	BSR.W	pt_EditBufToDisplay
	BSR.W	pt_ProcessEditBuffer
	JSR	pt_RestorePalette
	BRA.W	pt_PaletteEditorLoop
dat_10C5:
	DC.B	"Delete ST-.. ?",0,0
pt_BtnPlstLoad:
	LEA	dat_12EA,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_10C7
	RTS
pt_10C7:
	JSR	pt_WaitMouseRelease
	LEA	(dat_12C3,PC),A0
	BSR.W	pt_ShowStatusMsg
pt_10C8:
	JSR	pt_SavePaletteState
	LEA	dat_DrivePrefix,A0
	JSR	pt_CopyFilename
	LEA	(dat_10CE,PC),A0
	MOVEQ	#4,D0
pt_10C9:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_10C9
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-30,A6)
	MOVE.L	D0,D7
	BEQ.W	pt_10CB
	JSR	pt_SetPaletteDim
	CLR.L	dat_EditBufX
	BSR.S	pt_SpeedAndReset
	MOVE.L	(dat_EditBufPtr,PC),D2
	BEQ.W	pt_DosLibCall
	MOVE.L	D7,D1
	MOVE.L	dat_PatternBufPtr2,D3
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-42,A6)
	MOVE.L	D0,dat_EditFieldBufPtr
	DIVU	#$001e,D0
	MOVE.W	D0,dat_EditBufX
pt_DosLibCall:
	MOVE.L	D7,D1
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-36,A6)
pt_10CB:
	BSR.W	pt_EditFieldDrawText
	BSR.W	pt_ClearStatusMsg
	JSR	pt_RestorePalette
	CMPI.W	#$0006,dat_UIMode
	BNE.S	pt_10CC
	BSR.W	pt_1040
	BSR.W	pt_ProcessEditBuffer
	BRA.W	pt_PaletteEditorLoop
pt_10CC:
	RTS
dat_DrivePrefix:
	DC.L	$533a0000
dat_10CE:
	DC.B	"PLST",0,0
pt_SpeedAndReset:
	BSR.S	pt_ClearSpeedState
	MOVE.W	dat_CurrentSpeed,D0
	BNE.S	pt_10D0
	RTS
pt_10D0:
	MULU	#s_SIZEOF,D0
	MOVE.L	D0,dat_PatternBufPtr2
	MOVE.L	#$00010000,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_EditBufPtr
	MOVE.W	dat_CurrentSpeed,dat_SpeedResetVar
	RTS
pt_ClearSpeedState:
	CLR.W	dat_SpeedResetVar
	CLR.L	dat_EditFieldBufPtr
	CLR.W	dat_EditBufX
	MOVE.L	dat_EditBufPtr,D0
	BNE.S	pt_10D2
	RTS
pt_10D2:
	MOVEA.L	D0,A1
	MOVE.L	dat_PatternBufPtr2,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_EditBufPtr
	RTS
