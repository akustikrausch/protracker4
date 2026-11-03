pt_CopyFilenameField:
	LEA	dat_1342,A0
	MOVEQ	#20,D0
pt_0988:
	MOVE.B	(A0)+,D1
	BEQ.S	pt_0989
	MOVE.B	D1,(A1)+
	SUBQ.W	#1,D0
	BGT.S	pt_0988
	RTS
pt_0989:
	MOVE.B	#$20,(A1)+
	SUBQ.W	#1,D0
	BGT.S	pt_0989
	RTS
pt_098A:
	LEA	dat_133D,A1
	BSR.S	pt_CopyFilenameField
	LEA	dat_133E,A1
	BSR.S	pt_CopyFilenameField
	LEA	dat_133F,A1
	BSR.S	pt_CopyFilenameField
	LEA	dat_1340,A1
	BSR.S	pt_CopyFilenameField
	LEA	dat_1341,A1
	BSR.S	pt_CopyFilenameField
	MOVE.B	#$ff,dat_SongTypeFlag
	SF	dat_AudioFlag1
	SF	dat_ChannelMaskVar
	CLR.L	dat_DiskListPtr
	CLR.L	dat_DiskListPos
	CLR.L	dat_1346
	CLR.L	dat_PatDataVar2
	CLR.L	dat_PatDataVar1
	CLR.L	dat_SamplePtrBuf1
	CLR.L	dat_SamplePtrBuf2
	CLR.W	dat_134C
	MOVEA.L	dat_PatTablePtr,A0
	MOVE.L	A0,dat_1349
	MOVE.L	(A0)+,D0
	CMP.L	#$4d414553,D0
	BEQ.W	pt_099B
	JSR	pt_SmpCheckRiff
	BNE.W	pt_099A
	MOVE.L	(A0)+,dat_134A
	CMPI.L	#$38535658,(A0)+
	BNE.S	pt_098F
	ST	dat_ChannelMaskVar
	MOVE.L	dat_1349,D0
	ADD.L	dat_134A,D0
	MOVE.L	D0,dat_134B
pt_098B:
	CMPA.L	dat_134B,A0
	BGE.S	pt_0990
	TST.B	dat_AudioFlag1
	BNE.W	pt_0991
	LEA	dat_1343,A1
	MOVE.L	(A0)+,D0
pt_098C:
	MOVE.L	(A1)+,D1
	BEQ.S	pt_098E
	CMP.L	D1,D0
	BNE.S	pt_098D
	MOVEA.L	(A1),A1
	JSR	(A1)
	BRA.S	pt_098B
pt_098D:
	ADDQ.W	#4,A1
	BRA.S	pt_098C
pt_098E:
	BSR.S	pt_0992
	ADDQ.W	#1,dat_134C
	BRA.S	pt_098B
pt_098F:
	JSR	pt_SmpCheckAiff
	NOP
	NOP
	NOP
	NOP
	NOP
	RTS
pt_0990:
	MOVE.B	#$01,dat_SongTypeFlag
	TST.L	dat_DiskListPtr
	BNE.S	pt_0992
	ST	dat_AudioFlag1
	MOVE.L	#dat_1335,dat_SongLengthPtr
pt_0991:
	RTS
pt_0992:
	MOVE.L	(A0)+,D0
	MOVEA.L	A0,A2
	ADDQ.L	#1,D0
	BCLR	#0,D0
	ADDA.L	D0,A0
	RTS
dat_0993:
	BSR.S	pt_0992
	MOVE.L	A2,dat_DiskListPtr
	MOVE.L	D0,dat_DiskListPos
	RTS
dat_0994:
	BSR.S	pt_0992
	MOVE.L	A2,dat_SamplePtrBuf1
	MOVE.L	D0,dat_SamplePtrBuf2
	RTS
dat_0995:
	BSR.S	pt_0992
	MOVE.L	(A2)+,dat_PatDataVar2
	MOVE.L	(A2)+,D0
	MOVE.L	D0,dat_PatDataVar1
	ADDQ.W	#4,A2
	MOVEQ	#0,D0
	MOVE.W	(A2)+,D0
	MOVE.L	D0,dat_SongDataBufPtr
	MOVE.B	(A2)+,D0
	CMP.B	#$01,D0
	BEQ.S	pt_r0f1f2
	ST	dat_AudioFlag1
	MOVE.L	#dat_1334,dat_SongLengthPtr
	BRA.S	pt_r0f206
pt_r0f1f2:
	TST.B	(A2)+
	BEQ.S	pt_r0f206
	ST	dat_AudioFlag1
	MOVE.L	#dat_1333,dat_SongLengthPtr
pt_r0f206:
	RTS
dat_0996:
	LEA	dat_133D,A3
	BRA.S	pt_r0f226
dat_0997:
	LEA	dat_133E,A3
	BRA.S	pt_r0f226
dat_0998:
	LEA	dat_133F,A3
	BRA.S	pt_r0f226
dat_0999:
	LEA	dat_1340,A3
pt_r0f226:
	BSR.W	pt_0992
	MOVE.L	D0,D7
	MOVEQ	#20,D7
	BRA.S	pt_r0f24a
pt_r0f230:
	MOVE.B	(A2)+,D0
	BNE.S	pt_r0f242
pt_r0f234:
	MOVE.B	#$20,(A3)+
	DBF	D7,pt_r0f234
	BRA.S	pt_r0f24e
pt_r0f23e:
	MOVEQ	#32,D0
	BRA.S	pt_r0f248
pt_r0f242:
	CMP.B	#$0a,D0
	BEQ.S	pt_r0f23e
pt_r0f248:
	MOVE.B	D0,(A3)+
pt_r0f24a:
	DBF	D7,pt_r0f230
pt_r0f24e:
	RTS
pt_099A:
	SF	dat_ChannelMaskVar
	MOVE.B	#$02,dat_SongTypeFlag
	MOVE.L	#$000020ab,dat_SongDataBufPtr
	MOVE.L	dat_PatTablePtr,dat_DiskListPtr
	MOVE.L	dat_PatTablePtr2,dat_DiskListPos
	RTS
pt_099B:
	CMPI.L	#$54524f00,(A0)+
	BNE.S	pt_099D
	MOVE.L	(A0)+,D0
	MOVE.L	D0,dat_DiskListPos
	MOVE.L	(A0)+,dat_SongDataBufPtr
	MOVE.L	A0,dat_DiskListPtr
	CMPI.L	#$00006d60,dat_SongDataBufPtr
	BLE.S	pt_099C
	LSR.L	#1,D0
	MOVE.L	D0,dat_DiskListPos
pt_099C:
	CLR.B	dat_SongTypeFlag
	SF	dat_ChannelMaskVar
	RTS
pt_099D:
	ST	dat_AudioFlag1
	MOVE.L	#dat_1337,dat_SongLengthPtr
	RTS
pt_099E:
	MOVEQ	#-2,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-84,A6)
	MOVE.L	D0,dat_PatternIndexBuf
	BNE.S	pt_099F
	JSR	pt_LoadFailFind41
pt_099F:
	MOVE.L	D0,D1
	MOVE.L	#dat_AudioDMAState,D2
	JSR	(-102,A6)
	TST.L	dat_AudioDMACtrl
	BPL.S	pt_09A1
	MOVE.L	dat_PatternIndexBuf,D1
	JSR	(-90,A6)
	MOVE.L	dat_PatternEditBuf,D0
	BNE.S	pt_09A0
	JSR	pt_LoadFailEmpty41
pt_09A0:
	RTS
pt_09A1:
	JSR	pt_LoadFailDir41
pt_09A2:
	JSR	pt_LoadSizeGuard41
	CLR.L	dat_PatTablePtr
	MOVEQ	#0,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_PatTablePtr
	BNE.S	pt_09A3
	LEA	dat_133B,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetupPaletteMode
pt_09A3:
	RTS
pt_09A4:
	MOVE.L	dat_PatTablePtr,D0
	BEQ.S	pt_09A5
	MOVEA.L	D0,A1
	MOVE.L	dat_PatTablePtr2,D0
	BEQ.S	pt_09A5
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_09A5:
	RTS
pt_09A6:
	MOVE.L	D1,-(A7)
	MOVE.L	dat_RpChunkedSamples,D1
	BCLR	D0,D1
	MOVE.L	D1,dat_RpChunkedSamples
	MOVE.L	(A7)+,D1
	RTS
pt_JmpSelectDiskMsg:
	JMP	pt_SelectDiskMsg
pt_09A8:
	TST.W	dat_CurrentSample
	BEQ.S	pt_JmpSelectDiskMsg
	JSR	pt_LoadSaveName41
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_09A9:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_09A9
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0),A0
	ADDA.L	D0,A0
	LEA	dat_ScopeBuf1,A1
	MOVEQ	#21,D0
pt_09AA:
	MOVE.B	(A1)+,(A0)+
	DBF	D0,pt_09AA
	JSR	pt_SetPaletteDim
	MOVE.L	#dat_FileNameBuf,D1
	BSR.W	pt_099E
	BSR.W	pt_09A2
	TST.L	D0
	BNE.S	pt_09AB
	JMP	pt_LoadRestoreName41
pt_09AB:
	LEA	dat_1332,A0
	JSR	pt_ShowStatusMsg
	MOVE.L	#dat_FileNameBuf,D1
pt_09AC:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	MOVE.L	D0,D7
	BNE.S	pt_09AD
	JMP	pt_DrawWaveform
pt_09AD:
	MOVE.L	D0,D1
	MOVE.L	dat_PatTablePtr,D2
	MOVE.L	dat_PatTablePtr2,D3
	JSR	(-42,A6)
	MOVE.L	D7,D1
	JSR	(-36,A6)
	MOVEA.L	dat_PatTablePtr,A0
	MOVEA.L	dat_PatTablePtr2,A1
	BSR.W	pt_098A
	TST.B	dat_AudioFlag1
	BEQ.S	pt_09AE
	MOVEA.L	dat_SongLengthPtr,A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_09A4
	JSR	pt_SetPaletteEdit
	RTS
pt_09AE:
	BSR.W	pt_StopAllAudio
	BSR.W	pt_GetSamplePtrEntry
	CMPI.L	#$0000fffe,dat_DiskListPos
	BLE.S	pt_09AF
	MOVE.L	#$0000fffe,dat_DiskListPos
pt_09AF:
	CMPI.W	#$0003,dat_UIMode
	BNE.S	pt_09B0
	LEA	dat_ScopeBuf1,A0
	MOVE.W	#$2355,D1
	MOVEQ	#22,D0
	JSR	pt_DrawTextAt
pt_09B0:
	MOVE.L	dat_DiskListPtr,D0
	ADD.L	dat_DiskListPos,D0
	MOVE.L	D0,dat_1346
	MOVE.L	dat_DiskListPos,D0
	LEA	dat_ModulePtr,A4
	MOVE.W	dat_CurrentSample,D1
	LSL.W	#2,D1
	ADDA.W	D1,A4
	MOVE.L	D0,(124,A4)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	(dat_DiskOpViewMode,PC),D1
	JSR	(-198,A6)
	MOVE.L	D0,(A4)
	MOVE.L	D0,dat_FileWriteAddr
	BNE.S	pt_09B1
	LEA	dat_1339,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetupPaletteMode
pt_09B1:
	MOVE.L	dat_SamplePtrBuf2,D0
	BEQ.W	pt_09B7
	BTST	#3,dat_UIBitFlags
	BNE.S	pt_09B4
	LEA	SECSTRT_4,A4
	MOVE.W	dat_CurrentSample,D1
	LSL.W	#3,D1
	ADDA.W	D1,A4
	MOVE.L	D0,(4,A4)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#0,D1
	JSR	(-198,A6)
	MOVE.L	D0,(A4)
	MOVE.L	D0,dat_1351
	BNE.S	pt_09B2
	CLR.L	(4,A0)
	LEA	dat_133A,A0
	JSR	pt_ShowStatusMsg
	BRA.W	pt_SetupPaletteMode
pt_09B2:
	MOVEA.L	dat_SamplePtrBuf1,A0
	MOVEA.L	dat_1351,A1
	MOVEA.L	A1,A2
	ADDA.L	dat_SamplePtrBuf2,A2
pt_09B3:
	MOVE.W	(A0)+,(A1)+
	CMPA.L	A2,A1
	BLT.S	pt_09B3
	JSR	pt_DynIffKeep
	NOP
	NOP
	BRA.S	pt_09B8
pt_09B4:
	LEA	dat_133C,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	dat_DiskListPtr,A0
	MOVEA.L	dat_SamplePtrBuf1,A1
	MOVEA.L	A0,A2
	ADDA.L	dat_DiskListPos,A2
	MOVE.W	(A1)+,D1
	ADDQ.W	#2,A1
pt_09B5:
	MOVEQ	#0,D7
	MOVE.W	(A1)+,D7
	ADD.L	D7,D7
	MOVE.W	(A1)+,D2
pt_09B6:
	CMPA.L	A2,A0
	BGE.S	pt_09B7
	MOVE.B	(A0),D0
	EXT.W	D0
	MULS	D2,D0
	DIVS	#$0040,D0
	MOVE.B	D0,(A0)+
	SUBQ.L	#1,D7
	BGT.S	pt_09B6
	SUBQ.W	#1,D1
	BGT.S	pt_09B5
pt_09B7:
	MOVE.W	dat_CurrentSample,D0
	BSR.W	pt_09A6
pt_09B8:
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0),A0
	ADDA.L	D0,A0
	MOVE.L	A0,dat_EffectCmdPtr
	MOVE.L	dat_DiskListPos,D0
	LSR.L	#1,D0
	MOVE.W	D0,(s_length,A0)
	MOVE.L	#$00400000,(s_finetune,A0)
	MOVE.W	#$0001,(s_replen,A0)
	BTST	#6,dat_UIStateFlag
	BEQ.S	pt_09BA
	MOVE.L	dat_PatDataVar1,D0
	BEQ.S	pt_09BA
	LSR.L	#1,D0
	MOVE.W	D0,(s_replen,A0)
	MOVE.L	dat_PatDataVar2,D0
	BNE.S	pt_09B9
	MOVEQ	#2,D0
pt_09B9:
	LSR.L	#1,D0
	MOVE.W	D0,(s_repeat,A0)
pt_09BA:
	MOVEA.L	dat_FileWriteAddr,A1
	MOVEA.L	dat_DiskListPtr,A0
	MOVEA.L	A1,A2
	ADDA.L	dat_DiskListPos,A2
	TST.B	dat_SongTypeFlag
	BEQ.S	pt_09BC
pt_09BB:
	MOVE.W	(A0)+,(A1)+
	CMPA.L	A2,A1
	BLT.S	pt_09BB
	BRA.S	pt_09C1
pt_09BC:
	CMPI.L	#$00006d60,dat_SongDataBufPtr
	BLE.S	pt_09C0
	MOVEM.L	A0-A2,-(A7)
	LEA	dat_1338,A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,A0-A2
	MOVEQ	#9,D2
pt_09BD:
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	EXT.L	D0
	EXT.L	D1
	ADD.L	D1,D0
	BMI.S	pt_09BE
	LSR.L	D2,D0
	BRA.S	pt_09BF
pt_09BE:
	NEG.L	D0
	LSR.L	D2,D0
	NEG.L	D0
pt_09BF:
	MOVE.B	D0,(A1)+
	CMPA.L	A2,A1
	BLT.S	pt_09BD
	BRA.S	pt_09C1
pt_09C0:
	MOVE.B	(A0)+,(A1)+
	ADDQ.W	#1,A0
	CMPA.L	A2,A1
	BLT.S	pt_09C0
pt_09C1:
	BSR.W	pt_09A4
	BSR.W	pt_SampleLengthValidate
	JSR	pt_DrawSampleHex
	MOVEA.L	dat_FileWriteAddr,A0
	CLR.W	(A0)
	JSR	pt_RecordModeHandler
	JSR	pt_ClearStatusMsg
	JMP	pt_RestorePalette
pt_09C2:
	LEA	dat_ScopeAuxBuf,A0
	MOVEQ	#27,D0
pt_09C3:
	CLR.B	(A0)+
	DBF	D0,pt_09C3
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0),A0
	ADDA.L	D0,A0
	MOVE.L	A0,dat_EffectCmdPtr
	MOVEQ	#0,D0
	MOVE.W	(s_length,A0),D0
	ADD.L	D0,D0
	MOVE.L	D0,dat_FileWriteSize
	MOVE.L	D0,dat_024A
	ADD.L	#$00000060,D0
	MOVE.L	D0,dat_0246
	MOVEQ	#0,D0
	MOVE.W	(s_length,A0),D0
	ADD.L	D0,D0
	MOVEQ	#0,D1
	MOVE.W	(s_replen,A0),D1
	CMP.W	#$0001,D1
	BLS.S	pt_09C4
	ADD.L	D1,D1
	MOVEQ	#0,D0
	MOVE.W	(s_repeat,A0),D0
	ADD.L	D0,D0
	BRA.S	pt_09C5
pt_09C4:
	MOVEQ	#0,D1
pt_09C5:
	MOVE.L	D0,dat_0247
	MOVE.L	D1,dat_0248
	LEA	dat_ScopeAuxBuf,A1
	LEA	dat_0249,A2
	MOVEQ	#21,D0
pt_09C6:
	MOVE.B	(A0),(A1)+
	MOVE.B	(A0)+,(A2)+
	DBF	D0,pt_09C6
	MOVE.L	#dat_ScopeAuxBuf,D1
	MOVE.L	D1,dat_ScreenBufPtr
	BSR.S	pt_09C8
	BEQ.S	pt_09CC
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVEA.L	#dat_ScopeAuxBuf,A0
pt_09C7:
	MOVE.B	(A0)+,(A1)+
	BNE.S	pt_09C7
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	RTS
pt_09C8:
	MOVEA.L	D1,A0
pt_09C9:
	MOVE.B	(A0)+,D0
	BEQ.S	pt_09CA
	CMP.B	#$3a,D0
	BEQ.S	pt_09CB
	BRA.S	pt_09C9
pt_09CA:
	MOVEQ	#-1,D0
	RTS
pt_09CB:
	MOVEQ	#0,D0
	RTS
pt_09CC:
	BTST	#7,dat_UIStateFlag
	BNE.S	pt_09CD
	RTS
pt_09CD:
	MOVEA.L	#dat_ScopeAuxBuf,A0
	MOVEA.L	A0,A1
	LEA	(21,A1),A1
	MOVEA.L	A1,A2
pt_09CE:
	MOVE.B	-(A1),D0
	CMP.B	#$3a,D0
	BEQ.S	pt_09CF
	CMP.B	#$2f,D0
	BEQ.S	pt_09CF
	MOVEA.L	A1,A2
	CMPA.L	A0,A1
	BHI.S	pt_09CE
pt_09CF:
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
pt_09D0:
	MOVE.B	(A2)+,(A1)+
	BNE.S	pt_09D0
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	RTS
pt_SampleLengthValidate:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(20,A0),A0
	MOVEQ	#30,D0
pt_09D2:
	MOVE.W	(22,A0),D1
	MOVE.W	(26,A0),D2
	MOVE.W	(28,A0),D3
	CMP.W	D1,D2
	BCC.S	pt_09D6
	ADD.W	D2,D3
	CMP.W	D1,D3
	BHI.S	pt_09D5
pt_09D3:
	TST.W	(28,A0)
	BNE.S	pt_09D4
	MOVE.W	#$0001,(28,A0)
pt_09D4:
	LEA	(30,A0),A0
	DBF	D0,pt_09D2
	RTS
pt_09D5:
	SUB.W	D2,D1
	MOVE.W	D1,(28,A0)
	BRA.S	pt_09D3
pt_09D6:
	MOVEQ	#1,D1
	MOVE.L	D1,(26,A0)
	BRA.S	pt_09D3
pt_09D7:
	CLR.B	dat_KeyCode
	TST.W	dat_CurrentSample
	BEQ.W	pt_JmpSelectDiskMsg
	BSR.W	pt_StopAllAudio
	BSR.W	pt_GetSamplePtrEntry
	BSR.W	pt_09C2
	MOVEA.L	dat_ScreenBufPtr,A0
	TST.B	(A0)
	BNE.S	pt_09D8
	RTS
pt_09D8:
	MOVE.L	dat_FileWriteSize,D0
	BNE.S	pt_09D9
	RTS
pt_09D9:
	MOVE.L	dat_FileWriteSize,D0
	BSR.S	pt_09DB
	MOVE.L	dat_FileWriteAddr,D0
	BEQ.S	pt_09DA
	JSR	pt_DrawSampleHex
	JSR	pt_0FE4
	JSR	pt_ClearStatusMsg
	MOVEA.L	dat_FileWriteAddr,A0
	MOVEA.L	dat_FileWriteAddr,A0
	MOVEA.L	dat_FileWriteSize,A1
	BSR.W	pt_0976
	BSR.W	pt_SampleLengthValidate
	JSR	pt_DrawSampleHex
	MOVEA.L	dat_FileWriteAddr,A0
	CLR.W	(A0)
	JSR	pt_RecordModeHandler
	MOVE.W	#$0001,dat_TimeDisplayInit
	RTS
pt_09DA:
	JSR	pt_SavePaletteState
	BSR.W	pt_SetupPaletteMode
	JSR	pt_RestorePalette
	JMP	pt_RecordModeHandler
pt_09DB:
	MOVE.L	D0,-(A7)
	MOVE.L	(dat_DiskOpViewMode,PC),D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_FileWriteAddr
	LEA	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D1
	LSL.W	#2,D1
	LEA	(0,A0,D1.W),A0
	MOVE.L	dat_FileWriteAddr,(A0)
	MOVE.L	(A7)+,(124,A0)
	RTS
pt_GetSamplePtrEntry:
	LEA	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_09DD
	RTS
pt_09DD:
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.L	(A0),D1
	BNE.S	pt_09DE
	RTS
pt_09DE:
	CLR.L	(A0)
	MOVE.L	(124,A0),D0
	BNE.S	pt_09DF
	RTS
pt_09DF:
	CLR.L	(124,A0)
	MOVEA.L	D1,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	LEA	SECSTRT_4,A0
	MOVE.W	dat_CurrentSample,D0
	BNE.S	pt_09E0
	RTS
pt_09E0:
	LSL.W	#3,D0
	ADDA.W	D0,A0
	MOVE.L	(A0),D1
	BNE.S	pt_09E1
	RTS
pt_09E1:
	CLR.L	(A0)
	MOVE.L	(4,A0),D0
	BNE.S	pt_09E2
	RTS
pt_09E2:
	CLR.L	(4,A0)
	MOVEA.L	D1,A1
	JSR	(-210,A6)
	RTS
pt_09E3:
	MOVE.W	dat_SampleEditorY,dat_SampleEditorX
	LEA	dat_12DA,A0
	JSR	pt_ShowYesNoDialog
	BEQ.S	pt_09E4
	RTS
pt_09E4:
	LEA	dat_12C5,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_09E5:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_09E5
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_ScreenBufPtr,D1
	MOVEA.L	D1,A0
	JSR	(-72,A6)
	JSR	pt_ClearStatusMsg
	JSR	pt_SetPaletteBright
	JSR	pt_SavePaletteState
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_09E6
	RTS
pt_09E6:
	MOVE.B	#$ff,dat_RedrawFlag
	JMP	pt_BtnDiskReadDir
pt_09E7:
	LEA	dat_ScopeBuf1,A0
	LEA	dat_ScopeWorkBuf2,A1
	MOVEQ	#23,D0
pt_09E8:
	MOVE.B	(A0)+,(A1)+
	BNE.S	pt_09E9
	SUBQ.L	#1,A0
pt_09E9:
	DBF	D0,pt_09E8
	MOVE.W	dat_SampleEditorY,dat_SampleEditorX
	LEA	(dat_09EF,PC),A0
	LEA	dat_ScopeWorkBuf2,A1
	MOVEQ	#24,D0
	LEA	chip_CopperSpriteBuf,A2
	JSR	pt_SetupDisplayMode
	BEQ.S	pt_09EA
	RTS
pt_09EA:
	LEA	dat_12C6,A0
	JSR	pt_ShowStatusMsg
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteSong
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeWorkBuf2,A0
	MOVEQ	#23,D0
pt_09EB:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_09EB
	LEA	dat_FileNameBuf,A0
	LEA	dat_152E,A1
pt_09EC:
	MOVE.B	(A0)+,(A1)+
	BNE.S	pt_09EC
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_09ED:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_09ED
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#dat_152E,D2
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-78,A6)
	JSR	pt_RestorePalette
	JSR	pt_ClearStatusMsg
	BTST	#3,dat_UIStateFlag
	BNE.S	pt_09EE
	RTS
pt_09EE:
	MOVE.B	#$ff,dat_RedrawFlag
	JMP	pt_BtnDiskReadDir
dat_09EF:
	DC.B	10,10
	DC.B	"   RENAME FILE AS:",0,0
pt_09F0:
	CMPI.L	#$43484721,dat_SongChangedMagic
	BNE.S	pt_09F1
	JSR	pt_SaveConfirmDialog
	CMP.W	#$0002,D0
	BEQ.S	pt_09F1
	RTS
pt_09F1:
	CLR.L	dat_SongChangedMagic
	CLR.W	dat_XpkLibFlag
	CLR.W	dat_SongSaveChecksum
	BSR.W	pt_ClearBufferLoop
	MOVE.W	#$0001,dat_RecordMode
pt_09F2:
	BSR.W	pt_InitNewModule
	BSR.W	pt_SetupSampleView
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_09F3:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_09F3
	MOVE.L	dat_ModulePtr,dat_FileWriteAddr
	MOVE.L	#dat_FileNameBuf,dat_ScreenBufPtr
	MOVE.L	(dat_SampleEditCfg,PC),dat_FileWriteSize
	LEA	dat_12B7,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	PEA	pt_CloseFileHandle
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileIOBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#4,D3
	JSR	(-42,A6)
	CMP.L	#$00000004,D0
	BNE.W	pt_CloseAndInitModule
	LEA	dat_FileIOBuf,A0
	CMPI.L	#$464f524d,(A0)
	BEQ.W	pt_0A06
	CMPI.L	#$50503230,(A0)
	BEQ.W	pt_0E09
	CMPI.L	#$58504b46,(A0)
	BEQ.S	pt_09F4
	BRA.S	pt_09F5
pt_09F4:
	BSR.W	pt_0E0B
	JSR	pt_BtnDiskMainMenu
pt_09F5:
	BSR.W	pt_InitNewModule
	BSR.W	pt_SetupSampleView
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVEQ	#0,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_ModulePtr,D2
	MOVE.L	#$0000043c,D3
	BSR.W	pt_CheckModHeader
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVE.B	(-1,A0),D0
	MOVEQ	#0,D3
pt_09F6:
	CMP.B	(A0)+,D3
	BHI.S	pt_09F7
	MOVE.B	(-1,A0),D3
pt_09F7:
	DBF	D0,pt_09F6
	ADDQ.W	#1,D3
	LSL.L	#8,D3
	LSL.L	#2,D3
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_ModulePtr,D2
	ADD.L	#$0000043c,D2
	MOVEA.L	dat_DosLibBase,A6
	BSR.W	pt_CheckModHeader
	MOVE.L	dat_FileHandle,D1
	BEQ.S	pt_09F8
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
	CLR.L	dat_RecordMode
	CLR.W	dat_XpkLibFlag
pt_09F8:
	MOVEA.L	dat_ModulePtr,A0
	CMPI.L	#$50414b4b,(A0)
	BEQ.S	pt_09F9
	CMPI.L	#$5041434b,(A0)
	BNE.S	pt_09FA
pt_09F9:
	MOVE.L	(4,A0),dat_PaletteVar3
	MOVE.L	(8,A0),dat_PaletteDataPtr
	MOVE.L	dat_ModulePtr,D0
	ADD.L	#$0001143c,D0
	SUB.L	(dat_PaletteDataPtr,PC),D0
	MOVE.L	D0,dat_PaletteVar1
	LEA	dat_12C7,A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_0DEE
	BSR.W	pt_ClearStatusMsg
pt_09FA:
	MOVEA.L	dat_ModulePtr,A0
	CMPI.L	#$4d214b21,(mod_id,A0)
	BNE.W	pt_09FF
	TST.W	dat_SongSaveChecksum
	BNE.W	pt_LoadStringTable
	TST.B	dat_PatternBufFlag
	BNE.W	pt_LoadStringTable
	MOVE.L	dat_FileHandle,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	CLR.L	dat_RecordMode
	CLR.W	dat_XpkLibFlag
	BSR.W	pt_InitNewModule
	BSR.W	pt_SetupSampleView
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_09FB
	MOVEA.L	D1,A1
	MOVE.L	(dat_SampleEditCfg,PC),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_09FB:
	MOVE.B	#$01,dat_PatternBufFlag
	BTST	#5,dat_ModeFlags
	BNE.S	pt_09FC
	MOVE.L	#$0003243c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
	BRA.S	pt_09FD
pt_09FC:
	MOVE.L	#$0001943c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
pt_09FD:
	MOVE.L	(dat_SampleEditCfg,PC),D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_09FE
	JMP	pt_SetupPaletteMode
pt_09FE:
	BRA.W	pt_09F0
pt_09FF:
	MOVEA.L	dat_ModulePtr,A0
	CMPI.L	#$4d2e4b2e,(mod_id,A0)
	BEQ.S	pt_LoadStringTable
	BSR.W	pt_0E3E
	CMP.W	#$0002,D0
	BEQ.W	pt_DrawWaveform
pt_LoadStringTable:
	LEA	dat_12B7,A0
	BSR.W	pt_ShowStatusMsg
	BSR.W	pt_CheckRightButton
	BEQ.W	pt_ResetCurSample
	BTST	#4,dat_UIStateFlag
	BEQ.S	pt_ClearAndRedraw
	JSR	pt_BtnDiskMainMenu
	CMPI.W	#$0001,dat_UIMode
	BNE.S	pt_ClearAndRedraw
	LEA	dat_SampleHeaderBuf,A0
	TST.L	(A0)
	BNE.S	pt_0A01
	BRA.S	pt_ClearAndRedraw
pt_0A01:
	BSR.W	pt_BtnSongComment
pt_ClearAndRedraw:
	CLR.L	dat_PatTableIdx
	CLR.L	dat_BplUpdateReq
	BSR.W	pt_PatViewDrawAll
	CLR.W	dat_PatternPosition
	BSR.W	pt_PatViewSetRow
	BSR.W	pt_0A13
	LEA	dat_SampleScrollBuf,A0
	MOVE.W	#$001e,D0
pt_0A03:
	BTST	#5,dat_UIStateFlag
	BNE.S	pt_0A05
	BSR.W	pt_CheckRightButton
	BEQ.S	pt_ResetCurSample
	MOVE.W	dat_CurrentSample,dat_PrevSampleNum
	JSR	pt_InitTimeDisplay
	MOVE.L	(A0)+,D1
	MOVE.W	D1,dat_CurrentSample
	MOVEM.L	D0-D1/A0,-(A7)
	BSR.W	pt_09D7
	JSR	pt_DrawSampleHex
	MOVEM.L	(A7)+,D0-D1/A0
	DBF	D0,pt_0A03
pt_ResetCurSample:
	MOVE.W	#$0001,dat_CurrentSample
	MOVE.L	#$00000006,dat_RpSpeed
	CLR.W	dat_RecordMode
	BSR.W	pt_ClearStatusMsg
	JSR	pt_SetPaletteBright
	JSR	pt_InitTimeDisplay
	BSR.W	pt_0A19
	JSR	pt_DrawSampleHex
	JMP	pt_RecordModeHandler
pt_0A05:
	BSR.W	pt_SetupSampleView
	BRA.S	pt_ResetCurSample
pt_0A06:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVEQ	#8,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileIOBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#4,D3
	BSR.W	pt_CheckModHeader
	CMP.L	#$00000004,D0
	BNE.W	pt_CloseAndInitModule
	LEA	dat_FileIOBuf,A0
	CMPI.L	#$4d4f444c,(A0)
	BEQ.S	pt_0A07
	CMPI.L	#$38535658,(A0)
	BEQ.W	pt_0E98
	BRA.W	pt_09F5
pt_0A07:
	CLR.L	dat_FileReadPos
	LEA	dat_0F15,A0
	BSR.W	pt_ShowStatusMsg
	BSR.W	pt_InitNewModule
	BSR.W	pt_SetupSampleView
pt_DosLibAccess:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileReadPos,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileIOBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#4,D3
	BSR.W	pt_CheckModHeader
	CMP.L	#$00000004,D0
	BNE.W	pt_CloseAndInitModule
	ADDQ.L	#1,dat_FileReadPos
	LEA	dat_FileIOBuf,A0
	CMPI.L	#$56455253,(A0)
	BEQ.W	pt_0A10
	CMPI.L	#$494e464f,(A0)
	BEQ.W	pt_0A11
	CMPI.L	#$434d4e54,(A0)
	BEQ.W	pt_0A12
	CMPI.L	#$50544454,(A0)
	BEQ.S	pt_0A09
	BRA.S	pt_DosLibAccess
pt_0A09:
	CMPI.W	#$0040,dat_SongConfigVar
	BCS.W	pt_DosLibOpenFile
	TST.W	dat_SongSaveChecksum
	BNE.W	pt_DosLibOpenFile
	TST.B	dat_PatternBufFlag
	BNE.W	pt_DosLibOpenFile
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_0A0A
	MOVEA.L	D1,A1
	MOVE.L	(dat_SampleEditCfg,PC),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_0A0A:
	EORI.B	#$01,dat_PatternBufFlag
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0A0B
	MOVE.L	#$0003243c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
	BRA.S	pt_0A0C
pt_0A0B:
	MOVE.L	#$0001943c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
pt_0A0C:
	MOVE.L	(dat_SampleEditCfg,PC),D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_0A0D
	JMP	pt_SetupPaletteMode
pt_0A0D:
	MOVE.L	dat_FileHandle,D1
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-36,A6)
	BRA.W	pt_09F2
pt_DosLibOpenFile:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileReadPos,D2
	ADDQ.L	#7,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	BSR.W	pt_0E52
	MOVE.W	dat_SongConfigVar,dat_NumSamples
	MOVE.W	dat_SongConfigVar2,dat_RpMasterVol
	MOVE.W	dat_DefaultTempo,dat_CurrentTempo
	BCHG	#5,dat_SongModified
	MOVE.B	dat_SongModified,dat_ModeFlags
	MOVE.B	dat_SongModified+1,dat_ModeFlags+1
	JSR	pt_DrawStatusBar
	BSR.W	pt_0E9A
	JSR	pt_SetTempo
	BSR.W	pt_ClearAndRedraw
	BTST	#4,dat_UIStateFlag
	BEQ.S	pt_0A0F
	JMP	pt_OptPageRefresh
pt_0A0F:
	MOVEQ	#15,D7
	JMP	pt_InitTimeDisplay
pt_0A10:
	LEA	dat_0F16,A0
	BSR.W	pt_ShowStatusMsg
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileReadPos,D2
	ADDQ.L	#7,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileInfoAddr,A0
	MOVE.L	A0,D2
	MOVEQ	#12,D3
	BSR.W	pt_CheckModHeader
	BRA.W	pt_DosLibAccess
pt_0A11:
	LEA	dat_0F17,A0
	BSR.W	pt_ShowStatusMsg
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileReadPos,D2
	ADDQ.L	#7,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	LEA	str_UnnamedSong,A0
	MOVE.L	A0,D2
	MOVEQ	#64,D3
	BSR.W	pt_CheckModHeader
	BRA.W	pt_DosLibAccess
	CLR.W	dat_FileFormatFlag
	BTST	#5,dat_ModeFlags
	BNE.S	pt_r100c0
	MOVE.W	#$0001,dat_FileFormatFlag
pt_r100c0:
	BTST	#5,dat_SongModified
	BEQ.S	pt_r100d8
	CMPI.W	#$0001,dat_FileFormatFlag
	BEQ.W	pt_DosLibAccess
	BRA.S	pt_r100e2
pt_r100d8:
	TST.W	dat_FileFormatFlag
	BEQ.W	pt_DosLibAccess
pt_r100e2:
	MOVE.B	dat_SongModified,dat_ModeFlags
	MOVE.B	dat_SongModified+1,dat_ModeFlags+1
	MOVE.W	#$0001,dat_DiskOpState
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.W	pt_ClearScreenBuf2
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.W	pt_09F2
pt_0A12:
	LEA	dat_0F18,A0
	BSR.W	pt_ShowStatusMsg
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_FileReadPos,D2
	ADDQ.L	#3,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	LEA	dat_IFFFormBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#4,D3
	BSR.W	pt_CheckModHeader
	MOVE.L	dat_FileHandle,D1
	LEA	str_UnnamedAuthor,A0
	MOVE.L	A0,D2
	MOVEQ	#32,D3
	LEA	dat_0F19,A0
	BSR.W	pt_ShowStatusMsg
	BSR.W	pt_CheckModHeader
	MOVE.L	dat_FileHandle,D1
	LEA	dat_SampleHeaderBuf,A0
	MOVE.L	A0,D2
	MOVE.L	dat_IFFFormBuf,D3
	SUB.L	#$00000020,D3
	BSR.W	pt_CheckModHeader
	BRA.W	pt_DosLibAccess
pt_0A13:
	MOVEM.L	D0-D4/A0-A1,-(A7)
	MOVEA.L	dat_ModulePtr,A0
	LEA	(23,A0),A0
	LEA	dat_SampleScrollBuf,A1
	MOVEQ	#1,D0
pt_0A14:
	MOVE.B	(A0)+,(A1)+
	MOVE.B	(A0),(A1)+
	MOVE.W	D0,(A1)+
	LEA	(29,A0),A0
	ADDQ.L	#1,D0
	CMP.L	#$00000020,D0
	BCS.S	pt_0A14
pt_0A15:
	CLR.W	dat_SampleScrollIdx
	LEA	dat_SampleScrollBuf,A0
	MOVEQ	#29,D2
pt_0A16:
	MOVE.W	(A0),D0
	MOVE.W	(4,A0),D1
	CMP.W	D0,D1
	BCC.S	pt_0A17
	MOVE.W	#$0001,dat_SampleScrollIdx
	MOVE.L	(A0),D3
	MOVE.L	(4,A0),D4
	MOVE.L	D4,(A0)
	MOVE.L	D3,(4,A0)
pt_0A17:
	ADDQ.L	#4,A0
	DBF	D2,pt_0A16
	TST.W	dat_SampleScrollIdx
	BNE.S	pt_0A15
	LEA	dat_SampleScrollBuf,A0
	MOVEQ	#30,D0
pt_0A18:
	CLR.W	(A0)
	ADDQ.L	#4,A0
	DBF	D0,pt_0A18
	MOVEM.L	(A7)+,D0-D4/A0-A1
	RTS
pt_0A19:
	MOVEA.L	dat_ModulePtr,A0
	ADDA.W	#$0014,A0
	MOVEQ	#30,D1
pt_0A1A:
	MOVE.W	(26,A0),D0
	ADD.W	(28,A0),D0
	CMP.W	(22,A0),D0
	BLS.S	pt_0A1B
	MOVE.W	(26,A0),D0
	LSR.W	#1,D0
	MOVE.W	D0,(26,A0)
pt_0A1B:
	ADDA.W	#$001e,A0
	DBF	D1,pt_0A1A
	RTS
