pt_CheckNonZero:
	TST.W	D1
	BNE.S	pt_0DE8
	RTS
pt_0DE8:
	MOVE.W	D1,D3
	CLR.W	D1
	CMP.W	#$0009,D3
	BGE.S	pt_0DE9
	ADDQ.W	#1,dat_0DD0
	SUBQ.W	#1,D3
	MOVEQ	#5,D0
	BRA.S	pt_BitRotateLoop
pt_0DE9:
	ADDQ.W	#1,dat_0DD1
	SUB.W	#$0009,D3
	OR.W	#$0700,D3
	MOVEQ	#11,D0
pt_BitRotateLoop:
	SUBQ.W	#1,D0
pt_0DEB:
	LSR.L	#1,D3
	ROXL.L	#1,D2
	BCS.S	pt_0DED
	DBF	D0,pt_0DEB
	RTS
pt_0DEC:
	CLR.W	D0
pt_0DED:
	MOVE.L	D2,(A2)+
	MOVEQ	#1,D2
	DBF	D0,pt_0DEB
	RTS
pt_0DEE:
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEA.L	(dat_PaletteVar1,PC),A1
	MOVE.L	(dat_PaletteVar3,PC),D0
	MOVE.L	(dat_PaletteDataPtr,PC),D1
	BSR.S	pt_0DF1
	MOVEA.L	(dat_PaletteVar1,PC),A0
	MOVEA.L	dat_ModulePtr,A1
	MOVE.L	(dat_PaletteDataPtr,PC),D0
pt_0DEF:
	MOVE.B	(A0)+,(A1)+
	SUBQ.L	#1,D0
	BNE.S	pt_0DEF
	MOVEA.L	dat_ModulePtr,A0
	ADDA.L	dat_SampleEditCfg,A0
	MOVEA.L	dat_ModulePtr,A1
	ADDA.L	(dat_PaletteDataPtr,PC),A1
	SUBA.L	A1,A0
	MOVE.L	A0,D0
pt_0DF0:
	CLR.B	(A1)+
	SUBQ.L	#1,D0
	BNE.S	pt_0DF0
	RTS
pt_0DF1:
	ADDA.L	D0,A0
	MOVEA.L	D1,A2
	ADDA.L	A1,A2
	MOVE.L	-(A0),D0
pt_0DF2:
	LSR.L	#1,D0
	BNE.S	pt_0DF3
	BSR.S	pt_ReadColorReg
pt_0DF3:
	BCS.S	pt_0DFA
	MOVEQ	#8,D1
	MOVEQ	#1,D3
	LSR.L	#1,D0
	BNE.S	pt_0DF4
	BSR.S	pt_ReadColorReg
pt_0DF4:
	BCS.S	pt_0DFC
	MOVEQ	#3,D1
	CLR.W	D4
pt_0DF5:
	BSR.S	pt_BitCounterLoop
	MOVE.W	D2,D3
	ADD.W	D4,D3
pt_0DF6:
	MOVEQ	#7,D1
pt_0DF7:
	LSR.L	#1,D0
	BNE.S	pt_0DF8
	BSR.S	pt_ReadColorReg
pt_0DF8:
	ROXL.L	#1,D2
	DBF	D1,pt_0DF7
	MOVE.B	D2,-(A2)
	DBF	D3,pt_0DF6
	BRA.S	pt_0DFE
pt_0DF9:
	MOVEQ	#8,D1
	MOVEQ	#8,D4
	BRA.S	pt_0DF5
pt_0DFA:
	MOVEQ	#2,D1
	BSR.S	pt_BitCounterLoop
	CMP.B	#$02,D2
	BLT.S	pt_0DFB
	CMP.B	#$03,D2
	BEQ.S	pt_0DF9
	MOVEQ	#8,D1
	BSR.S	pt_BitCounterLoop
	MOVE.W	D2,D3
	MOVE.W	#$0008,D1
	BRA.S	pt_0DFC
pt_0DFB:
	MOVE.W	#$0009,D1
	ADD.W	D2,D1
	ADDQ.W	#2,D2
	MOVE.W	D2,D3
pt_0DFC:
	BSR.S	pt_BitCounterLoop
pt_0DFD:
	SUBQ.W	#1,A2
	MOVE.B	(0,A2,D2.W),(A2)
	DBF	D3,pt_0DFD
pt_0DFE:
	CMPA.L	A2,A1
	BLT.S	pt_0DF2
	RTS
pt_ReadColorReg:
	MOVE.L	-(A0),D0
	MOVE.W	D0,COLOR17
	MOVE	#$0010,CCR
	ROXR.L	#1,D0
	RTS
pt_BitCounterLoop:
	SUBQ.W	#1,D1
	CLR.W	D2
pt_0E01:
	LSR.L	#1,D0
	BNE.S	pt_0E02
	MOVE.L	-(A0),D0
	MOVE.W	D0,COLOR17
	MOVE	#$0010,CCR
	ROXR.L	#1,D0
pt_0E02:
	ROXL.L	#1,D2
	DBF	D1,pt_0E01
	RTS
dat_SongSaveChecksum:
	DS.W	1
pt_0E04:
	CMPI.L	#$43484721,dat_SongChangedMagic
	BNE.S	pt_0E05
	JSR	pt_SaveConfirmDialog
	CMP.W	#$0002,D0
	BEQ.S	pt_0E05
	RTS
pt_0E05:
	CLR.L	dat_SongChangedMagic
	CLR.W	dat_SongSaveChecksum
	CLR.W	dat_XpkLibFlag
	BSR.W	pt_ClearBufferLoop
pt_0E06:
	MOVE.W	#$0001,dat_RecordMode
	JSR	pt_SetPaletteDim
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_0E07:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0E07
	MOVEA.L	(dat_DosLibBase,PC),A6
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
	CMPI.L	#$50503230,(A0)
	BEQ.W	pt_0E09
	CMPI.L	#$50583230,(A0)
	BEQ.W	pt_0E0A
	CMPI.L	#$464f524d,(A0)
	BEQ.W	pt_0E89
	CMPI.L	#$58504b46,(A0)
	BEQ.W	pt_0E0B
	CMPI.L	#$4d4d4431,(A0)
	BEQ.W	pt_CloseFileAndContinue
	CMPI.L	#$4d4d4430,(A0)
	BEQ.W	pt_CloseFileAndContinue
	CMPI.L	#$4d4d4431,(A0)
	BEQ.W	pt_CloseFileAndContinue
	CMPI.L	#$4d4d4432,(A0)
	BEQ.W	pt_CloseFileAndContinue
	CMPI.L	#$4d4d4433,(A0)
	BEQ.W	pt_CloseFileAndContinue
	CMPI.L	#$000003f3,(A0)
	BEQ.W	pt_0E80
	CMPI.L	#$53796d4d,(A0)
	BEQ.W	pt_0E81
	CMPI.L	#$44494749,(A0)
	BEQ.W	pt_0E82
	CMPI.L	#$54464d58,(A0)
	BEQ.W	pt_0E83
	CMPI.L	#$46433134,(A0)
	BEQ.W	pt_0E84
	CMPI.L	#$534f4152,(A0)
	BEQ.W	pt_0E85
	CMPI.L	#$4f435441,(A0)
	BEQ.W	pt_0E86
	CMPI.L	#$494d5021,(A0)
	BEQ.W	pt_0E08
	BRA.W	pt_DosLibDiskOp
pt_0E08:
	LEA	dat_0E27,A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_CloseFileHandle
	RTS
pt_0E09:
	JSR	pt_OpenXpkLib
	TSTPC.L	dat_XpkLibBase
	BEQ.S	pt_0E0A
	LEA	str_LoadingPowerPacked,A0
	BRA.S	pt_0E0C
pt_0E0A:
	LEA	dat_0E26,A0
	JSR	pt_ShowStatusMsg
	BSR.W	pt_CloseFileHandle
	JSR	pt_OpenPPLib
	BEQ.W	pt_0E19
	MOVEA.L	D0,A6
	LEA	dat_FileNameBuf,A0
	MOVEQ	#2,D0
	MOVE.L	#$00010000,D1
	LEA	(dat_FileIOState,PC),A1
	LEA	(dat_0E34,PC),A2
	LEA	(dat_0E1C,PC),A3
	MOVEA.L	(dat_PPLibBase,PC),A6
	JSR	(-30,A6)
	MOVE.L	D0,-(A7)
	MOVE.L	(dat_FileIOState,PC),dat_HardwareCtrlWord
	MOVE.L	(A7)+,D0
	BNE.W	pt_0E11
	BRA.W	pt_DosLibDiskOp
pt_0E0B:
	JSR	pt_OpenXpkLib
	TSTPC.L	dat_XpkLibBase
	BEQ.S	pt_0E10
	LEA	str_LoadingXPK,A0
pt_0E0C:
	BSR.W	pt_ShowStatusMsg
	MOVE.W	#$0010,dat_XpkLibFlag
	MOVEA.L	#dat_FileNameBuf,A0
	MOVE.L	A0,dat_147D
	MOVEA.L	(dat_XpkLibBase,PC),A6
	LEA	dat_147C,A0
	JSR	(-48,A6)
	TST.L	D0
	BNE.S	pt_0E0D
	JSR	pt_CloseXpkLib
	BRA.W	pt_0E89
pt_0E0D:
	LEA	str_ErrorXPKFailed,A0
	BSR.W	pt_ShowStatusMsg
pt_0E0E:
	CLR.W	dat_RecordMode
	MOVE.L	dat_HardwareCtrlBuf,D0
	BEQ.S	pt_0E0F
	MOVEA.L	D0,A1
	MOVE.L	dat_1480,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_0E0F:
	MOVEQ	#0,D0
	RTS
pt_0E10:
	LEA	str_ErrorXPKNotFound,A0
	BSR.W	pt_ShowStatusMsg
	RTS
pt_0E11:
	MOVE.L	D0,dat_0E31
	MOVE.L	(dat_0E31,PC),D0
	CMP.L	#$ffffffff,D0
	BNE.S	pt_0E12
	LEA	(dat_0E2A,PC),A0
	BRA.S	pt_ClearRecordMode
pt_0E12:
	CMP.L	#$fffffffe,D0
	BNE.S	pt_0E13
	LEA	(dat_0E2B,PC),A0
	BRA.S	pt_ClearRecordMode
pt_0E13:
	CMP.L	#$fffffffd,D0
	BNE.S	pt_0E14
	LEA	(dat_0E29,PC),A0
	JSR	pt_SetupEditScreen
	BRA.S	pt_0E1B
pt_0E14:
	CMP.L	#$fffffffc,D0
	BNE.S	pt_0E15
	LEA	(dat_0E2C,PC),A0
	BRA.S	pt_ClearRecordMode
pt_0E15:
	CMP.L	#$fffffffb,D0
	BNE.S	pt_0E16
	LEA	(dat_0E2D,PC),A0
	BRA.S	pt_ClearRecordMode
pt_0E16:
	CMP.L	#$fffffffa,D0
	BNE.S	pt_0E17
	LEA	(dat_0E2E,PC),A0
	BRA.S	pt_ClearRecordMode
pt_0E17:
	CMP.L	#$fffffff9,D0
	BNE.S	pt_0E18
	LEA	(dat_0E2F,PC),A0
	BRA.S	pt_ClearRecordMode
pt_0E18:
	LEA	(dat_0E30,PC),A0
	BRA.S	pt_ClearRecordMode
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LEA	dat_0E28,A0
	BRA.S	pt_ClearRecordMode
pt_0E19:
	LEA	str_CantOpenPPLib,A0
pt_ClearRecordMode:
	BSR.W	pt_ShowStatusMsg
pt_0E1B:
	CLR.W	dat_RecordMode
	CLR.L	dat_FileIOState
	JSR	pt_SetPaletteEdit
	JMP	pt_InitTimeDisplay
dat_0E1C:
	MOVE.L	(4,A7),dat_0E24
	MOVE.L	(8,A7),dat_0E22
	MOVE.W	#$0003,dat_0E21
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	dat_03FB
	MOVEA.L	(dat_IntuiLibBase,PC),A6
	LEA	(dat_0E24+4,PC),A0
	JSR	(-204,A6)
	MOVE.L	D0,dat_0E1E
	BEQ.W	pt_r15924
pt_r15858:
	CLR.W	dat_PatEdScrollVar
	MOVE.L	(dat_0E24,PC),dat_0E23
pt_r15866:
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	(dat_0E1E,PC),A0
	MOVEA.L	(86,A0),A0
	JSR	(-384,A6)
	MOVEA.L	(dat_0E1E,PC),A0
	MOVEA.L	(86,A0),A0
	JSR	(-372,A6)
	MOVEA.L	D0,A0
	MOVE.L	(20,A0),dat_0E1D
	MOVE.L	(24,A0),dat_0E1F
	MOVEA.L	D0,A1
	JSR	(-378,A6)
	MOVE.L	(dat_0E1D,PC),D0
	CMP.L	#$00200000,D0
	BNE.S	pt_r15866
	MOVE.W	(dat_0E1F,PC),D0
	CMP.W	#$000d,D0
	BEQ.S	pt_r158f4
	MOVEA.L	(dat_0E23,PC),A0
	CMP.W	#$0008,D0
	BNE.S	pt_r158d0
	SUBQ.L	#1,A0
	SUBQ.W	#1,dat_PatEdScrollVar
	BPL.S	pt_r158ea
	MOVEA.L	(dat_0E24,PC),A0
	CLR.W	dat_PatEdScrollVar
	BRA.S	pt_r158ea
pt_r158d0:
	MOVE.B	D0,(A0)+
	ADDQ.W	#1,dat_PatEdScrollVar
	CMPI.W	#$0010,dat_PatEdScrollVar
	BNE.S	pt_r158ea
	SUBQ.L	#1,A0
	SUBQ.W	#1,dat_PatEdScrollVar
pt_r158ea:
	MOVE.L	A0,dat_0E23
	BRA.W	pt_r15866
pt_r158f4:
	MOVEA.L	(dat_0E23,PC),A0
	CLR.B	(A0)
	MOVEA.L	(dat_0E24,PC),A0
	MOVEA.L	(dat_PPLibBase,PC),A6
	JSR	(-42,A6)
	CMP.L	(dat_0E22,PC),D0
	BEQ.S	pt_r15932
	BSR.S	pt_r1594c
	SUBQ.W	#1,dat_0E21
	BGT.W	pt_r15858
	MOVEA.L	(dat_IntuiLibBase,PC),A6
	MOVEA.L	(dat_0E1E,PC),A0
	JSR	(-72,A6)
pt_r15924:
	JSR	pt_OpenScreenInit
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D0
	RTS
pt_r15932:
	MOVEA.L	(dat_IntuiLibBase,PC),A6
	MOVEA.L	(dat_0E1E,PC),A0
	JSR	(-72,A6)
	JSR	pt_OpenScreenInit
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#-1,D0
	RTS
pt_r1594c:
	SUBA.L	A0,A0
	MOVEA.L	(dat_IntuiLibBase,PC),A6
	JSR	(-96,A6)
	MOVEA.L	(dat_0E1E,PC),A0
	LEA	(dat_0E25+17,PC),A1
	MOVEA.L	#$ffffffff,A2
	JSR	(-276,A6)
	MOVEA.L	(dat_DosLibBase,PC),A5
	MOVEQ	#80,D1
	JSR	(-198,A5)
	MOVEA.L	(dat_0E1E,PC),A0
	LEA	(dat_0E25,PC),A1
	MOVEA.L	#$ffffffff,A2
	JSR	(-276,A6)
	RTS
dat_0E1D:
	DS.L	1
dat_0E1E:
	DS.L	1
dat_0E1F:
	DS.L	1
dat_PatEdScrollVar:
	DS.W	1
dat_0E21:
	DS.W	1
dat_0E22:
	DS.L	1
dat_0E23:
	DS.L	1
dat_0E24:
	DS.L	1
	DC.L	$00e10032,$00d0000b,$01030020,$00000001
	DC.L	$10060000
	DS.L	1
	DS.W	1
	DC.L	dat_0E25
	DS.L	2
	DC.L	$00960032,$014000c8
	DC.W	$0001
dat_0E25:
	DC.B	"  ENTER PASSWORD",0
	DC.B	"INCORRECT PASSWORD",0
dat_0E26:
	DC.B	"READING POWERPACKED MODULE..",0
dat_0E27:
	DC.B	"READING IMPLODED MODULE...",0,0
dat_0E28:
	DC.B	"ERROR WHILE DECRUNCHING!!",0
dat_0E29:
	DC.B	10,10,10
	DC.B	"   Not enough memory",10
	DC.B	"    for decruncher!",0
dat_0E2A:
	DC.B	"PP OPEN ERROR!!",0
dat_0E2B:
	DC.B	"PP READ ERROR!!",0
dat_0E2C:
	DC.B	"ENCRYPTED MODULE!!",0
dat_0E2D:
	DC.B	"PERMISSION DENIED!",0
dat_0E2E:
	DC.B	"UNKNOWN PP VERSION!",0
dat_0E2F:
	DC.B	"POWERPACKED FILE EMPTY!",0
dat_0E30:
	DC.B	"WEIRD PP ERROR!?",0
dat_0E31:
	DS.L	1
dat_PPLibBase:
	DS.L	2
dat_FileIOState:
	DS.L	1
dat_0E34:
	DS.L	1
dat_FileIOBufLen:
	DS.L	1
pt_DosLibDiskOp:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#$00000438,D2
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
	CMPI.L	#$4d2e4b2e,(A0)
	BEQ.W	pt_CheckModifiedAndInit
	CMPI.L	#$21504d21,(A0)
	BEQ.W	pt_CheckModifiedAndInit
	CMPI.L	#$464c5434,(A0)
	BEQ.W	pt_CheckModifiedAndInit
	CMPI.L	#$45584f34,(A0)
	BEQ.W	pt_CheckModifiedAndInit
	CMPI.L	#$3843484e,(A0)
	BEQ.W	pt_0E4C
	CMPI.L	#$4d214b21,(A0)
	BEQ.W	dat_0E46
	JSR	pt_FmtCheckMore
	NOP
	NOP
	NOP
	NOP
	NOP
	BSR.W	pt_CloseFileHandle
	LEA	(str_UnknownFormat,PC),A0
	BRA.W	pt_FinishPaletteEdit
pt_0E37:
	MOVE.W	#$ffff,dat_DiskOpFlag
	JSR	pt_CopyPatternBlock
	LEA	(dat_0E3D,PC),A0
	LEA	chip_CopperSpriteBuf,A1
	LEA	dat_1453,A2
	MOVE.L	#$00000460,D0
	JSR	pt_BlitCopyBlock
pt_WaitKeypress:
	IFD	DEBUGAUTO
	JSR	dbg_AutoStep
	ENDC
	JSR	pt_GetKeypress
	LMB
	BNE.S	pt_WaitKeypress
	MOVEM.W	dat_EditDigitValue,D0-D1
	LEA	dat_1445,A0
	JSR	pt_HandleUIBtnCore
	TST.W	D2
	BEQ.S	pt_WaitKeypress
	CMP.W	#$0001,D2
	BEQ.S	pt_0E39
	CMP.W	#$0002,D2
	BEQ.S	pt_0E3A
	CMP.W	#$0003,D2
	BEQ.S	pt_0E3B
	CMP.W	#$000a,D2
	BNE.S	pt_WaitKeypress
	JSR	pt_ScreenStateHandler
	BRA.S	pt_WaitKeypress
pt_0E39:
	MOVEQ	#1,D0
	BRA.S	pt_0E3C
pt_0E3A:
	MOVEQ	#2,D0
	BRA.S	pt_0E3C
pt_0E3B:
	MOVEQ	#3,D0
pt_0E3C:
	MOVE.L	D0,-(A7)
	JSR	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	MOVE.L	(A7)+,D0
	RTS
dat_0E3D:
	DC.B	10,10
	DC.B	"This file is not a standard",10
	DC.B	"ProTracker module! Load as",10
	DC.B	"31 or 15 instruments module?",0
pt_0E3E:
	BSR.W	pt_0E37
	CMP.W	#$0002,D0
	BEQ.S	pt_0E42
	CMP.W	#$0003,D0
	BEQ.S	pt_0E41
	MOVEA.L	dat_ModulePtr,A0
	LEA	(466,A0),A1
	ADDA.L	#$000101d6,A0
pt_0E3F:
	MOVE.L	(A0),(484,A0)
	CLR.L	(A0)
	SUBQ.L	#4,A0
	CMPA.L	A0,A1
	BNE.S	pt_0E3F
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_id,A0),A1
	LEA	(mod_songlen,A0),A0
pt_0E40:
	MOVE.W	(4,A0),(A0)+
	CMPA.L	A0,A1
	BNE.S	pt_0E40
	MOVE.L	#$4d2e4b2e,(A0)
	MOVEQ	#0,D0
	RTS
pt_0E41:
	MOVEA.L	dat_ModulePtr,A0
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
	MOVEQ	#-1,D0
	RTS
pt_0E42:
	MOVEQ	#-2,D0
	RTS
pt_0E43:
	BSR.W	pt_0E9D
	CMP.L	#$00000001,D0
	BEQ.W	pt_CheckModifiedAndInit
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
	LEA	pt_PaletteEditEntry,A0
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	MOVEQ	#0,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_ModulePtr,D2
	MOVE.L	#$000001d6,D3
	BSR.W	pt_CheckModHeader
	CMP.L	#$000001d6,D0
	BNE.W	pt_CloseAndInitModule
	MOVEA.L	dat_ModulePtr,A0
	ADDA.W	#$01d6,A0
	MOVEQ	#15,D0
pt_0E44:
	MOVEQ	#19,D1
pt_0E45:
	CLR.B	(A0)+
	DBF	D1,pt_0E45
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	CLR.W	(A0)+
	MOVE.W	#$0001,(A0)+
	DBF	D0,pt_0E44
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_ModulePtr,D2
	ADD.L	#$000003b6,D2
	MOVE.L	#$00000082,D3
	BSR.W	pt_CheckModHeader
	CMP.L	#$00000082,D0
	BNE.W	pt_CloseAndInitModule
	MOVEA.L	dat_ModulePtr,A0
	MOVE.B	#$7f,(951,A0)
	BRA.W	pt_0E53
dat_0E46:
	TSTPC.W	dat_SongSaveChecksum
	BNE.W	pt_CheckModifiedAndInit
	TST.B	dat_PatternBufFlag
	BNE.W	pt_CheckModifiedAndInit
	MOVE.L	(dat_FileHandle,PC),D1
	BEQ.S	pt_0E48
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-36,A6)
	CLR.L	dat_RecordMode
	TST.W	dat_XpkLibFlag
	BEQ.S	pt_0E47
	BSR.W	pt_0E0E
	CLR.W	dat_XpkLibFlag
pt_0E47:
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
pt_0E48:
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_0E49
	MOVEA.L	D1,A1
	MOVE.L	dat_SampleEditCfg,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_0E49:
	MOVE.B	#$01,dat_PatternBufFlag
	MOVE.L	#$0001943c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0E4A
	MOVE.L	#$0003243c,dat_SampleEditCfg
pt_0E4A:
	MOVE.L	dat_SampleEditCfg,D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_0E4B
	BRA.W	pt_SetupPaletteMode
pt_0E4B:
	MOVEA.L	(dat_DosLibBase,PC),A6
	TST.W	dat_SampleTableOfs
	BEQ.W	pt_0E06
	BRA.W	pt_0EAF
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_r15e80
	MOVE.W	#$0001,dat_DiskOpState
	BCLR	#5,dat_ModeFlags
	JSR	pt_ClearScreenBuf2
	MOVE.W	#$0006,dat_RpNumChannels
	BRA.W	pt_0E50
pt_r15e80:
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
	MOVE.W	#$0006,dat_RpNumChannels
	BRA.S	pt_0E50
pt_0E4C:
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_0E4D
	MOVE.W	#$0001,dat_DiskOpState
	BCLR	#5,dat_ModeFlags
	JSR	pt_ClearScreenBuf2
	MOVE.W	#$0008,dat_RpNumChannels
	BRA.W	pt_0E50
pt_0E4D:
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
	MOVE.W	#$0008,dat_RpNumChannels
	BRA.S	pt_0E50
pt_CheckModifiedAndInit:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0E4F
	MOVE.W	#$0001,dat_FileOpFlag
pt_0E4F:
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
pt_0E50:
	LEA	pt_PaletteEditEntry,A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0E51
	TST.W	dat_FileOpFlag
	BEQ.S	pt_0E51
	LEA	dat_12B8,A0
pt_0E51:
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	MOVEQ	#0,D2
	MOVEQ	#-1,D3
	BSR.W	pt_FileSeekPos
pt_0E52:
	MOVE.L	dat_FileHandle,D1
	MOVE.L	dat_ModulePtr,D2
	MOVE.L	#$0000043c,D3
	BSR.W	pt_CheckModHeader
	CMP.L	#$0000043c,D0
	BNE.W	pt_CloseAndInitModule
	MOVEA.L	dat_ModulePtr,A0
	JSR	pt_FmtAfterHeader
pt_0E53:
	LEA	pt_PaletteEditEntry,A0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0E54
	TST.W	dat_FileOpFlag
	BEQ.S	pt_0E54
	LEA	dat_12B8,A0
pt_0E54:
	BSR.W	pt_ShowStatusMsg
	MOVEA.L	dat_ModulePtr,A0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVE.B	(-1,A0),D0
	MOVEQ	#0,D3
pt_0E55:
	CMP.B	(A0)+,D3
	BHI.S	pt_0E56
	MOVE.B	(-1,A0),D3
pt_0E56:
	DBF	D0,pt_0E55
	ADDQ.W	#1,D3
	LSL.L	#8,D3
	LSL.L	#2,D3
	BTST	#5,dat_ModeFlags
	BNE.W	pt_0E5D
	TST.W	dat_FileOpFlag
	BEQ.S	pt_0E5C
	MOVE.L	D3,D5
	MOVE.W	dat_RpNumChannels,D6
	CMP.W	#$0004,D6
	BEQ.S	pt_0E57
	CMP.W	#$0006,D6
	BEQ.S	pt_0E58
	CMP.W	#$0008,D6
	BEQ.S	pt_0E59
pt_0E57:
	LSR.L	#4,D3
	BRA.S	pt_0E5A
pt_0E58:
	LSR.L	#6,D3
	BRA.S	pt_0E5A
pt_0E59:
	LSR.L	#8,D3
pt_0E5A:
	LSR.L	#2,D3
	MOVE.L	D3,D5
	LSL.L	#6,D5
	SUBQ.L	#1,D5
	MOVE.L	dat_ModulePtr,D2
	ADD.L	#$0000043c,D2
	MOVEQ	#0,D4
pt_0E5B:
	MOVEM.L	D3-D5,-(A7)
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	dat_ModulePtr,D2
	ADD.L	#$0000043c,D2
	LSL.L	#5,D4
	ADD.L	D4,D2
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVEQ	#16,D3
	BSR.W	pt_CheckModHeader
	MOVEM.L	(A7)+,D3-D5
	ADDQ.L	#1,D4
	DBF	D5,pt_0E5B
	BRA.S	pt_0E5E
pt_0E5C:
	LSL.L	#1,D3
pt_0E5D:
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	dat_ModulePtr,D2
	ADD.L	#$0000043c,D2
	MOVEA.L	(dat_DosLibBase,PC),A6
	BSR.W	pt_CheckModHeader
pt_0E5E:
	JSR	pt_FmtAfterPatterns
	CLR.L	dat_PatTableIdx
	CLR.L	dat_BplUpdateReq
	BSR.W	pt_PatViewDrawAll
	CLR.W	dat_PatternPosition
	BSR.W	pt_PatViewSetRow
	MOVE.W	#$0001,dat_CurrentSample
	BSR.W	pt_CheckRightButton
	BEQ.W	pt_GetFileHandle
	BTST	#4,dat_UIStateFlag
	BEQ.S	pt_0E5F
	JSR	pt_BtnDiskMainMenu
pt_0E5F:
	BTST	#5,dat_UIStateFlag
	BNE.W	pt_0E6A
	BSR.W	pt_CheckRightButton
	BEQ.W	pt_GetFileHandle
	BSR.W	pt_DrawSampleHex
	MOVE.W	(dat_CurrentSample,PC),dat_PrevSampleNum
	JSR	pt_InitTimeDisplay
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.W	(dat_CurrentSample,PC),D7
	MULU	#s_SIZEOF,D7
	MOVEQ	#0,D0
	MOVE.W	(12,A0,D7.W),D0
	BEQ.W	pt_CheckRowDataSize
	MOVE.B	(14,A0,D7.W),D1
	BTST	#7,D1
	SNE	D1
	MOVE.B	D1,dat_FileHandleVar
	ADD.L	D0,D0
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	dat_DiskOpViewMode,D1
	MOVE.L	D0,-(A7)
	JSR	(-198,A6)
	MOVE.L	(A7)+,D6
	TST.L	D0
	BNE.S	pt_0E60
	BSR.W	pt_SetupPaletteMode
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	D6,D2
	MOVEQ	#0,D3
	BRA.W	pt_CheckRowDataSize
pt_0E60:
	MOVE.W	(dat_CurrentSample,PC),D7
	LSL.W	#2,D7
	LEA	(dat_ModulePtr,PC),A0
	MOVE.L	D0,(0,A0,D7.W)
	MOVE.L	D6,(124,A0,D7.W)
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	D0,D2
	MOVE.L	D6,D3
	BSR.W	pt_CheckModHeader
	TST.B	dat_FileHandleVar
	BEQ.W	pt_0E62
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	#dat_FilePathBufPtr,D2
	MOVEQ	#4,D3
	BSR.W	pt_CheckModHeader
	MOVE.L	dat_FilePathBufPtr,D2
	BEQ.S	pt_0E62
	MOVE.L	D2,D0
	MOVE.L	D2,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#0,D1
	JSR	(-198,A6)
	MOVE.L	(A7)+,D2
	TST.L	D0
	BNE.S	pt_0E61
	BSR.W	pt_SetupPaletteMode
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_FileHandle,PC),D1
	MOVE.L	D6,D2
	MOVEQ	#0,D3
	BRA.S	pt_CheckRowDataSize
pt_0E61:
	LEA	SECSTRT_4,A0
	MOVE.W	dat_CurrentSample,D1
	LSL.W	#3,D1
	ADDA.W	D1,A0
	MOVE.L	D0,(A0)
	MOVE.L	D2,(4,A0)
	MOVE.L	D2,D3
	MOVE.L	D0,D2
	MOVE.L	dat_RpChunkedSamples,D1
	MOVE.W	dat_CurrentSample,D0
	BSET	D0,D1
	MOVE.L	D1,dat_RpChunkedSamples
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	pt_DynModRead
	NOP
pt_0E62:
	BSR.W	pt_RecordModeHandler
pt_CheckRowDataSize:
	CMPI.W	#$0006,dat_RpNumChannels
	BNE.S	pt_0E64
	MOVE.W	#$0008,dat_RpNumChannels
pt_0E64:
	BSR.W	pt_SampleClearLoop
	MOVEA.L	dat_ModulePtr,A0
	LEA	(12,A0),A0
	MOVEQ	#0,D0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	TST.W	(6,A0)
	BNE.S	pt_0E65
	ADDQ.W	#1,(6,A0)
pt_0E65:
	ADDQ.W	#1,dat_CurrentSample
	CMPI.W	#$0020,dat_CurrentSample
	BNE.W	pt_0E5F
pt_GetFileHandle:
	MOVE.L	(dat_FileHandle,PC),D1
	BEQ.S	pt_0E67
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
pt_0E67:
	MOVE.W	#$0001,dat_CurrentSample
	MOVE.L	#$00000006,dat_RpSpeed
	CLR.W	dat_RecordMode
	BSR.W	pt_ClearStatusMsg
	JSR	pt_SetPaletteBright
	BSR.W	pt_0A19
	BSR.W	pt_DrawSampleHex
	BSR.W	pt_RecordModeHandler
	BTST	#4,dat_UIStateFlag
	BNE.S	pt_0E68
	JSR	pt_ShowFileSelector
pt_0E68:
	MOVEQ	#15,D7
	JSR	pt_InitTimeDisplay
	CMPI.W	#$0001,dat_UIMode
	BNE.S	pt_0E69
	LEA	dat_SampleHeaderBuf,A0
	TST.L	(A0)
	BNE.W	pt_BtnSongComment
pt_0E69:
	RTS
pt_0E6A:
	JSR	pt_SetupSampleView
	BRA.S	pt_GetFileHandle
dat_FileOpFlag:
	DS.W	1
pt_CheckModHeader:
	TSTPC.L	dat_FileIOState
	BNE.S	pt_0E6F
	JMP	pt_FmtRead
	NOP
	NOP
	NOP
pt_CopyModData:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEA.L	dat_HardwareCtrlWord,A1
	MOVEA.L	D2,A0
pt_CopyModLoop:
	MOVE.B	(A1)+,(A0)+
	SUBQ.L	#1,D3
	BNE.S	pt_CopyModLoop
	MOVE.L	A1,dat_HardwareCtrlWord
	MOVEM.L	(A7)+,D1-D7/A0-A6
	MOVE.L	D3,D0
	RTS
pt_0E6F:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEA.L	(dat_FileIOBufLen,PC),A1
	MOVEA.L	D2,A0
pt_0E70:
	MOVE.B	(A1)+,(A0)+
	SUBQ.L	#1,D3
	BNE.S	pt_0E70
	MOVE.L	A1,dat_FileIOBufLen
	MOVEM.L	(A7)+,D1-D7/A0-A6
	MOVE.L	D3,D0
	RTS
pt_FileSeekPos:
	TSTPC.L	dat_FileIOState
	BNE.S	pt_0E77
	TST.W	dat_XpkLibFlag
	BNE.S	pt_0E73
	TST.W	dat_SampleTableOfs
	BEQ.S	pt_0E72
	JSR	pt_Exe8SeekAdd
pt_0E72:
	JMP	(-66,A6)
pt_0E73:
	CMP.L	#$ffffffff,D3
	BEQ.S	pt_0E75
	CMP.L	#$00000001,D3
	BEQ.S	pt_0E76
	TST.L	D3
	BEQ.S	pt_0E74
	RTS
pt_0E74:
	ADD.L	D2,dat_HardwareCtrlWord
	MOVE.L	D2,D0
	RTS
pt_0E75:
	MOVE.L	dat_HardwareCtrlBuf,dat_HardwareCtrlWord
	ADD.L	D2,dat_HardwareCtrlWord
	MOVE.L	D2,D0
	RTS
pt_0E76:
	MOVE.L	dat_HardwareCtrlBuf,dat_HardwareCtrlWord
	SUB.L	D2,dat_HardwareCtrlWord
	MOVE.L	D2,D0
	RTS
pt_0E77:
	CMP.L	#$ffffffff,D3
	BEQ.S	pt_0E79
	CMP.L	#$00000001,D3
	BEQ.S	pt_0E7A
	TST.L	D3
	BEQ.S	pt_0E78
	RTS
pt_0E78:
	ADD.L	D2,dat_FileIOBufLen
	MOVE.L	D2,D0
	RTS
pt_0E79:
	MOVE.L	(dat_FileIOState,PC),dat_FileIOBufLen
	ADD.L	D2,dat_FileIOBufLen
	MOVE.L	D2,D0
	RTS
pt_0E7A:
	MOVE.L	(dat_FileIOState,PC),dat_FileIOBufLen
	SUB.L	D2,dat_FileIOBufLen
	MOVE.L	D2,D0
	RTS
pt_CloseFileHandle:
	MOVE.L	(dat_FileHandle,PC),D1
	BEQ.S	pt_0E7C
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-36,A6)
	CLR.L	dat_FileHandle
pt_0E7C:
	TST.W	dat_XpkLibFlag
	BEQ.S	pt_0E7D
	BRA.W	pt_0E0E
pt_0E7D:
	MOVE.L	(dat_FileIOState,PC),D0
	TSTPC.L	dat_FileIOState
	BEQ.S	pt_0E7E
	MOVE.L	(dat_FileIOState,PC),D0
	MOVEA.L	D0,A1
	MOVE.L	(dat_0E34,PC),D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_FileIOState
pt_0E7E:
	CLR.W	dat_RecordMode
	RTS
pt_CloseFileAndContinue:
	BSR.S	pt_CloseFileHandle
	LEA	(dat_0F1B,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_0E80:
	BSR.S	pt_CloseFileHandle
	JMP	pt_0EAE
pt_0E81:
	BSR.S	pt_CloseFileHandle
	LEA	(dat_0F1C,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_0E82:
	BSR.S	pt_CloseFileHandle
	LEA	(dat_0F1D,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_0E83:
	BSR.S	pt_CloseFileHandle
	LEA	(dat_0F1E,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_0E84:
	BSR.S	pt_CloseFileHandle
	LEA	(dat_0F1F,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_0E85:
	BSR.W	pt_CloseFileHandle
	LEA	(dat_0F20,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_0E86:
	BSR.W	pt_CloseFileHandle
	LEA	(dat_0F21,PC),A0
	BRA.S	pt_FinishPaletteEdit
pt_CloseAndInitModule:
	BSR.W	pt_CloseFileHandle
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
	LEA	(dat_0F1A,PC),A0
pt_FinishPaletteEdit:
	BSR.W	pt_ShowStatusMsg
	MOVE.W	#$0028,dat_AnimPhaseCounter
	JMP	pt_SetPaletteEdit
pt_0E89:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_FileHandle,PC),D1
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
	BEQ.S	pt_0E8A
	CMPI.L	#$38535658,(A0)
	BEQ.W	pt_0E98
	CMPI.L	#$50544346,(A0)
	BEQ.W	pt_0E99
	BRA.W	pt_DosLibDiskOp
pt_0E8A:
	CLR.L	dat_FileReadPos
	LEA	dat_0F15,A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_InitNewModule
	JSR	pt_SetupSampleView
pt_DosLibFileOp:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	(dat_FileHandle,PC),D1
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
	BEQ.W	pt_0E94
	CMPI.L	#$494e464f,(A0)
	BEQ.W	pt_0E95
	CMPI.L	#$434d4e54,(A0)
	BEQ.W	pt_0E97
	CMPI.L	#$50544454,(A0)
	BEQ.S	pt_0E8C
	BRA.S	pt_DosLibFileOp
pt_0E8C:
	CMPI.W	#$0040,dat_SongConfigVar
	BCS.W	pt_DosLibCallFile
	TSTPC.W	dat_SongSaveChecksum
	BNE.W	pt_DosLibCallFile
	TST.B	dat_PatternBufFlag
	BNE.W	pt_DosLibCallFile
pt_0E8D:
	MOVE.L	dat_ModulePtr,D1
	BEQ.S	pt_0E8E
	MOVEA.L	D1,A1
	MOVE.L	dat_SampleEditCfg,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
pt_0E8E:
	EORI.B	#$01,dat_PatternBufFlag
	MOVE.L	#$0001043c,dat_SampleEditCfg
	MOVE.L	#$0000003f,dat_SampleEditState
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0E8F
	MOVE.L	#$0004043c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
	BRA.S	pt_0E90
pt_0E8F:
	TST.B	dat_PatternBufFlag
	BEQ.S	pt_0E90
	MOVE.L	#$0001943c,dat_SampleEditCfg
	MOVE.L	#$00000063,dat_SampleEditState
pt_0E90:
	MOVE.L	dat_SampleEditCfg,D0
	MOVE.L	#$00010001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,dat_ModulePtr
	BNE.S	pt_0E91
	BSR.W	pt_SetupPaletteMode
	MOVE.W	#$0001,dat_SongSaveChecksum
	BRA.W	pt_0E8D
pt_0E91:
	MOVE.L	(dat_FileHandle,PC),D1
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-36,A6)
	BRA.W	pt_0E06
pt_DosLibCallFile:
	MOVEA.L	(dat_DosLibBase,PC),A6
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
	BTST	#4,dat_UIStateFlag
	BEQ.S	pt_0E93
	BRA.W	pt_OptPageRefresh
pt_0E93:
	MOVEQ	#15,D7
	JMP	pt_InitTimeDisplay
pt_0E94:
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
	BRA.W	pt_DosLibFileOp
pt_0E95:
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
	BRA.W	pt_DosLibFileOp
	BTST	#5,dat_ModeFlags
	BNE.S	pt_r1669c
	MOVE.W	#$0001,dat_FileFormatFlag
pt_r1669c:
	BTST	#5,dat_SongModified
	BNE.S	pt_r166b4
	CMPI.W	#$0001,dat_FileFormatFlag
	BEQ.W	pt_DosLibFileOp
	BRA.S	pt_r166be
pt_r166b4:
	TST.W	dat_FileFormatFlag
	BEQ.W	pt_DosLibFileOp
pt_r166be:
	MOVE.B	dat_SongModified,dat_ModeFlags
	MOVE.B	dat_SongModified+1,dat_ModeFlags+1
	MOVE.W	#$0001,dat_DiskOpState
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_ClearScreenBuf2
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BRA.W	pt_0E06
dat_FileFormatFlag:
	DS.W	1
pt_0E97:
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
	BRA.W	pt_DosLibFileOp
pt_0E98:
	BSR.W	pt_CloseFileHandle
	JSR	pt_SetupSampleView
	BRA.W	pt_09A8
pt_0E99:
	BSR.W	pt_CloseAndInitModule
	BSR.W	pt_CloseFileHandle
	RTS
pt_0E9A:
	BTST	#5,dat_ModeFlags
	BNE.W	pt_0E9D
	BCLR	#5,dat_ModeFlags
	MOVE.W	#$0008,dat_RpNumChannels
	MOVE.W	#$0100,D0
	MULU	dat_RpNumChannels,D0
	MOVE.W	D0,dat_RowDataVar
	LEA	dat_ScopeCh1,A0
	MOVE.W	#$0026,(2,A0)
	LEA	dat_ScopeCh2,A0
	MOVE.W	#$004a,(2,A0)
	LEA	dat_ScopeCh3,A0
	MOVE.W	#$006e,(2,A0)
	LEA	dat_ScopeCh4,A0
	MOVE.W	#$0092,(2,A0)
	TST.W	dat_SamplerActive
	BEQ.S	pt_0E9B
	BSR.W	pt_BtnSmpExit
pt_0E9B:
	TST.W	dat_DiskOpState
	BEQ.S	pt_0E9C
	JSR	pt_InitModulePart
pt_0E9C:
	MOVEA.L	#dat_IMPFormatData2,A0
	JSR	pt_CheckModuleTypeWrap
	JSR	pt_UpdateDisplayMain
	CLR.W	dat_CursorColumn
	JSR	pt_ReturnFromPlay
	RTS
pt_0E9D:
	BSET	#5,dat_ModeFlags
	MOVE.W	#$0004,dat_RpNumChannels
	MOVE.W	#$0100,D0
	MULU	dat_RpNumChannels,D0
	MOVE.W	D0,dat_RowDataVar
	LEA	dat_ScopeCh1,A0
	MOVE.W	#$003a,(2,A0)
	LEA	dat_ScopeCh2,A0
	MOVE.W	#$0082,(2,A0)
	LEA	dat_ScopeCh3,A0
	MOVE.W	#$00ca,(2,A0)
	LEA	dat_ScopeCh4,A0
	MOVE.W	#$0112,(2,A0)
	TST.W	dat_SamplerActive
	BEQ.S	pt_0E9E
	BSR.W	pt_BtnSmpExit
pt_0E9E:
	TST.W	dat_DiskOpState
	BEQ.S	pt_0E9F
	JSR	pt_InitModulePart
pt_0E9F:
	MOVEA.L	#dat_IMPFormatData3,A0
	JSR	pt_CheckModuleTypeWrap
	JSR	pt_UpdateDisplayMain
	CLR.W	dat_CursorColumn
	JSR	pt_ReturnFromPlay
	RTS
pt_0EA0:
	MOVE.W	#$0006,dat_SampleEditorX
	MOVE.W	#$0001,dat_RecordMode
	JSR	pt_SetPaletteDim
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_0EA1:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0EA1
	LEA	dat_12BA,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	MOVE.L	dat_FileHandle,D1
	LEA	dat_SampleChannelMask,A0
	MOVE.L	A0,D2
	MOVEQ	#16,D3
	JSR	(-42,A6)
	CMP.L	#$00000010,D0
	BNE.W	pt_CloseAndInitModule
	LEA	dat_SampleChannelMask,A0
	CMPI.L	#$464f524d,(A0)+
	BNE.W	pt_ShowLoadMsg
	CMPI.L	#$50415454,(8,A0)
	BEQ.S	pt_0EA2
	CMPI.L	#$5452434b,(8,A0)
	BEQ.W	pt_0EAB
	BRA.S	pt_ShowLoadMsg
pt_0EA2:
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_PatternDataBuf5,D2
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0EA3
	MOVE.L	#$00000800,D3
	JSR	(-42,A6)
	CMP.L	#$00000800,D0
	BNE.S	pt_ShowLoadMsg
	BRA.S	pt_0EA4
pt_0EA3:
	MOVE.L	#$00000400,D3
	JSR	(-42,A6)
	CMP.L	#$00000400,D0
	BNE.S	pt_ShowLoadMsg
pt_0EA4:
	BSR.W	pt_CursorColCalc
	JSR	pt_ConvertKeyWithRedraw
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	LEA	str_EmptyLine,A0
	JSR	pt_ShowStatusMsg
	JSR	pt_SetPaletteBright
	BRA.W	pt_PatViewDrawAll
pt_ShowLoadMsg:
	LEA	dat_12BB,A0
	JSR	pt_ShowStatusMsg
	MOVEQ	#5,D3
pt_0EA6:
	JSR	pt_RefreshDisplay
	DBF	D3,pt_0EA6
	LEA	str_EmptyLine,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	BRA.W	pt_PatViewDrawAll
pt_CursorColCalc:
	MOVEQ	#0,D0
	MOVE.W	dat_CursorColumn,D0
	DIVU	#$0006,D0
	AND.L	#$00000003,D0
	LSL.L	#2,D0
	MOVEA.L	D0,A0
	ADDA.L	dat_ModulePtr,A0
	LEA	(mod_patterns,A0),A0
	MOVE.L	dat_PatTableIdx,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0EA8
	LSL.L	#1,D0
pt_0EA8:
	ADDA.L	D0,A0
	RTS
pt_0EA9:
	MOVE.W	#$0001,dat_RecordMode
	JSR	pt_SetPaletteDim
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_0EAA:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0EAA
	LEA	dat_12BC,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	MOVE.L	dat_FileHandle,D1
	LEA	dat_SampleChannelMask,A0
	MOVE.L	A0,D2
	MOVEQ	#16,D3
	JSR	(-42,A6)
	CMP.L	#$00000010,D0
	BNE.W	pt_CloseAndInitModule
	LEA	dat_SampleChannelMask,A0
	CMPI.L	#$464f524d,(A0)+
	BNE.S	pt_LoadStringRef
	CMPI.L	#$5452434b,(8,A0)
	BEQ.S	pt_0EAB
	CMPI.L	#$50415454,(8,A0)
	BEQ.W	pt_0EA2
	BRA.S	pt_LoadStringRef
pt_0EAB:
	MOVE.L	dat_FileHandle,D1
	MOVE.L	#dat_DisplayBufPool,D2
	MOVE.L	#$00000100,D3
	JSR	(-42,A6)
	CMP.L	#$00000100,D0
	BNE.S	pt_LoadStringRef
	BSR.W	pt_CursorColCalc
	JSR	pt_ConvertKeyNote
	BSR.W	pt_PatViewDrawAll
	LEA	str_EmptyLine,A0
	JSR	pt_ShowStatusMsg
	JSR	pt_SetPaletteBright
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	BRA.W	pt_PatViewDrawAll
pt_LoadStringRef:
	LEA	dat_12BD,A0
	JSR	pt_ShowStatusMsg
	MOVEQ	#8,D3
pt_0EAD:
	JSR	pt_RefreshDisplay
	DBF	D3,pt_0EAD
	LEA	str_EmptyLine,A0
	JSR	pt_ShowStatusMsg
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	dat_FileHandle,D1
	JSR	(-36,A6)
	BRA.W	pt_PatViewDrawAll
pt_0EAE:
	BSET	#1,CIAA_PRA
	BCLR	#1,dat_ModeFlags
	CLR.W	dat_SongSaveChecksum
	CLR.W	dat_XpkLibFlag
	BSR.W	pt_ClearBufferLoop
pt_0EAF:
	MOVE.W	#$0001,dat_RecordMode
	JSR	pt_SetPaletteDim
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	LEA	dat_ScopeBuf1,A0
	MOVEQ	#29,D0
pt_0EB0:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0EB0
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	MOVE.L	D0,dat_FileHandle
	BEQ.W	pt_DrawWaveform
	PEA	(pt_CloseFileHandle,PC)
	MOVE.L	dat_FileHandle,D1
	LEA	dat_FileIOBuf,A0
	MOVE.L	A0,D2
	MOVEQ	#4,D3
	JSR	(-42,A6)
	CMP.L	#$00000004,D0
	BNE.W	pt_CloseAndInitModule
	LEA	dat_FileIOBuf,A0
	CMPI.L	#$000003f3,(A0)
	BNE.S	pt_0EB1
	MOVE.L	dat_FileHandle,D1
	MOVEQ	#40,D2
	MOVEQ	#-1,D3
	JSR	(-66,A6)
	MOVE.L	dat_FileHandle,D1
	LEA	dat_SampleChannelMask,A0
	MOVE.L	A0,D2
	MOVEQ	#8,D3
	JSR	(-42,A6)
	CMP.L	#$00000008,D0
	BNE.W	pt_CloseAndInitModule
	LEA	dat_SampleChannelMask,A0
	JSR	pt_Exe8LoadMark
	NOP
	BSR.W	pt_DosLibDiskOp
	CLR.W	dat_SampleTableOfs
	RTS
pt_0EB1:
	BSR.W	pt_CloseFileHandle
	LEA	(str_NoPTProExec,PC),A0
	BRA.W	pt_FinishPaletteEdit
dat_SampleChannelMask:
	DS.L	2
dat_SampleTableOfs:
	DS.W	1
pt_GetSamplePtrAbs:
	MOVEA.L	dat_ModulePtr,A1
	LEA	(20,A1),A1
	MOVE.L	dat_RpChunkedSamples,D1
	MOVEQ	#1,D0
pt_0EB5:
	BTST	D0,D1
	BEQ.S	pt_0EB6
	ORI.B	#$80,(24,A1)
pt_0EB6:
	LEA	(30,A1),A1
	ADDQ.W	#1,D0
	CMP.W	#$0020,D0
	BLE.S	pt_0EB5
	RTS
pt_0EB7:
	MOVEA.L	dat_ModulePtr,A1
	LEA	(32,A1),A1
	MOVEQ	#1,D0
pt_0EB8:
	ANDI.B	#$7f,(24,A1)
	LEA	(30,A1),A1
	ADDQ.W	#1,D0
	CMP.W	#$0020,D0
	BLE.S	pt_0EB8
	RTS
pt_0EB9:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteDim
	BSR.S	pt_GetSamplePtrAbs
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	dat_NumSamples
pt_0EBA:
	MOVE.B	(0,A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#$0080,D0
	BHI.S	pt_0EBB
	MOVE.W	(dat_NumSamples,PC),D2
	CMP.W	D2,D1
	BLS.S	pt_0EBA
	MOVE.W	D1,dat_NumSamples
	BRA.S	pt_0EBA
pt_0EBB:
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.L	A1,-(A7)
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVEQ	#19,D0
pt_0EBC:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0EBC
	MOVEA.L	(A7),A1
	SUBQ.L	#1,A1
pt_0EBD:
	ADDQ.L	#1,A1
	TST.B	(A1)
	BNE.S	pt_0EBD
	MOVE.B	#$2e,(A1)+
	MOVE.B	#$45,(A1)+
	MOVE.B	#$58,(A1)+
	MOVE.B	#$45,(A1)+
	CLR.B	(A1)+
	MOVEA.L	(A7)+,A1
	JSR	pt_ReadEClock
	MOVE.L	D0,-(A7)
	MOVE.L	D0,D1
	LSR.L	#2,D0
	LSL.L	#2,D0
	CMP.L	D0,D1
	BEQ.S	pt_0EBE
	ADDQ.L	#4,D0
pt_0EBE:
	MOVE.L	D0,-(A7)
	LSR.L	#2,D0
	JSR	pt_Exe8Patch
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
	JSR	pt_OpenFileWrite
	BNE.S	pt_0EC0
	LEA	dat_12C0,A0
	BSR.W	pt_ShowStatusMsg
	JSR	pt_Exe8WriteParams
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	JSR	pt_WriteFileData
	BSR.S	pt_PrepareModSave
	MOVE.L	#$00000004,dat_FileWriteSize
	MOVE.L	#dat_0EC6,dat_FileWriteAddr
	MOVE.L	(A7)+,D0
	MOVE.L	(A7)+,D1
	CMP.L	D0,D1
	BEQ.S	pt_0EBF
	ADDQ.L	#2,dat_FileWriteSize
	SUBQ.L	#2,dat_FileWriteAddr
pt_0EBF:
	JSR	pt_WriteFileData
	JSR	pt_CloseFile
	RTS
pt_0EC0:
	ADDQ.L	#8,A7
	BRA.W	pt_DrawWaveform
pt_DrawWaveform:
	LEA	(dat_0FEA,PC),A0
pt_ShowMsgSetPal:
	BSR.W	pt_ShowStatusMsg
	JSR	pt_SetPaletteEdit
	CLR.W	dat_FileWriteSize
	MOVEQ	#0,D0
	RTS
pt_PrepareModSave:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.L	A0,dat_FileWriteAddr
	MOVE.L	#$0000043c,dat_FileWriteSize
	JSR	pt_Exe8PatBytes
	NOP
	NOP
	NOP
	ADD.L	D0,dat_FileWriteSize
	MOVE.B	#$7f,(951,A0)
	CLR.L	(mod_id,A0)
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
	JSR	pt_Exe8ModId
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
pt_SaveSampleLoop:
	BSR.W	pt_WriteFileData
	BNE.W	pt_CheckCloseAndBranch
	MOVE.W	(dat_CurrentSample,PC),dat_FileSizeWord
	MOVEQ	#1,D6
pt_SaveNextSample:
	MOVE.W	D6,dat_CurrentSample
	BSR.W	pt_0EDD
	BNE.W	pt_CheckCloseAndBranch
	ADDQ.B	#1,D6
	CMP.B	#$20,D6
	BNE.S	pt_SaveNextSample
	RTS
	DS.L	1
dat_0EC6:
	DC.L	$000003f2
pt_LoadModule:
	JSR	pt_SavePaletteState
	JSR	pt_SetPaletteDim
	BSR.W	pt_GetSamplePtrAbs
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(mod_positions,A0),A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CLR.W	dat_NumSamples
pt_0EC8:
	MOVE.B	(0,A0,D0.W),D1
	ADDQ.W	#1,D0
	CMP.W	#$0080,D0
	BHI.S	pt_0EC9
	MOVE.W	(dat_NumSamples,PC),D2
	CMP.W	D2,D1
	BLS.S	pt_0EC8
	MOVE.W	D1,dat_NumSamples
	BRA.S	pt_0EC8
pt_0EC9:
	BTST	#4,pt_BtnMainSetup
	BSR.W	pt_0F34
	BTST	#1,dat_UIStateFlag
	BNE.W	pt_0EF4
	CLR.L	dat_XPKWriteActive
	CLR.W	dat_FileSizeMode
pt_GetSamplePtrPC:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.L	A0,dat_FileWriteAddr
	CLR.L	dat_FileWriteSize
	TST.B	dat_SampleNameBuf
	BEQ.W	pt_0ED1
	BCLR	#2,dat_ModeFlags
	MOVE.L	dat_TimeAuxVal,D0
	ADD.L	dat_ModeConfigVal,D0
	MOVE.L	D0,dat_FileInfoPtr2
	LEA	str_UnnamedSong,A0
	CMPI.L	#$554e4e41,(A0)
	BNE.S	pt_0ECC
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	str_UnnamedSong,A1
	MOVEQ	#19,D0
pt_0ECB:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0ECB
pt_0ECC:
	MOVE.W	#$0020,dat_SongNameBufEnd
	MOVE.W	#$0040,dat_SongNameEnd
	MOVE.W	dat_NumSamples,dat_SongConfigVar
	MOVE.W	dat_RpMasterVol,dat_SongConfigVar2
	MOVE.W	dat_CurrentTempo,dat_DefaultTempo
	MOVE.B	dat_ModeFlags,dat_SongModified
	MOVE.B	dat_ModeFlags+1,dat_SongModified+1
	BCHG	#5,dat_SongModified
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
	MOVE.W	dat_SampleConfigA,dat_DSPControl
	MOVE.W	dat_SampleConfigB,dat_SongConfigA
	MOVE.W	dat_SampleConfigC,dat_SongConfigB
	MOVE.W	dat_SampleConfigD,dat_SongConfigC
	MOVE.W	dat_SampleConfigE,dat_SongConfigD
	MOVE.W	dat_SampleConfigF,dat_SongConfigE
	MOVEA.L	dat_ModulePtr,A0
	LEA	(42,A0),A0
	MOVE.W	dat_PrevSampleNum,D7
	SUBQ.W	#1,D7
	MOVE.W	#$001f,dat_PrevSampleNum
	MOVEQ	#0,D0
pt_0ECD:
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ASL.W	#1,D1
	ADD.L	D1,D0
	ADDA.W	#$001e,A0
	DBF	D7,pt_0ECD
	ADD.L	#$0000043c,D0
	MOVEA.L	dat_ModulePtr,A0
	MOVEQ	#127,D7
	ADDA.W	#$03b8,A0
	MOVEQ	#0,D6
pt_0ECE:
	MOVE.B	(A0)+,D5
	CMP.B	D5,D6
	BHI.S	pt_0ECF
	MOVE.B	D5,D6
pt_0ECF:
	DBF	D7,pt_0ECE
	ADDQ.W	#1,D6
	ASL.L	#8,D6
	ASL.L	#2,D6
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0ED0
	ASL.L	#1,D6
pt_0ED0:
	ADD.L	D6,D0
	MOVE.L	D0,dat_1420
	LEA	str_IFFFormID,A0
	MOVE.L	A0,dat_FileWriteAddr
	MOVE.L	#$00000212,D0
	MOVE.L	D0,dat_FileWriteSize
	BSR.W	pt_FileOpenCheck
	BNE.W	pt_DrawWaveform
	BSR.W	pt_WriteFileData
	BNE.W	pt_CheckCloseAndBranch
pt_0ED1:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.L	A0,dat_FileWriteAddr
	MOVE.L	#$0000043c,dat_FileWriteSize
	MOVEQ	#0,D0
	MOVE.W	(dat_NumSamples,PC),D0
	ADDQ.L	#1,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0ED2
	LSL.L	#1,D0
pt_0ED2:
	ADD.L	D0,dat_FileWriteSize
	MOVE.B	#$7f,(951,A0)
	CLR.L	(mod_id,A0)
	MOVE.L	#$4d2e4b2e,(mod_id,A0)
	BTST	#5,dat_ModeFlags
	BNE.S	pt_0ED3
	MOVE.L	#$3843484e,(mod_id,A0)
	BRA.S	pt_0ED4
pt_0ED3:
	CMPI.W	#$0040,dat_NumSamples
	BCS.S	pt_0ED4
	MOVE.L	#$4d214b21,(mod_id,A0)
pt_0ED4:
	TST.W	dat_FileSizeMode
	BNE.S	pt_CheckSampleName
	TST.L	dat_XPKWriteActive
	BNE.S	pt_CheckSampleName
	LEA	(dat_12BE,PC),A0
	BSR.W	pt_ShowStatusMsg
pt_CheckSampleName:
	TST.B	dat_SampleNameBuf
	BNE.S	pt_0ED6
	BSR.W	pt_FileOpenCheck
	BNE.W	pt_DrawWaveform
pt_0ED6:
	BSR.W	pt_WriteFileData
	BNE.S	pt_CheckCloseAndBranch
	MOVE.W	(dat_CurrentSample,PC),dat_FileSizeWord
	MOVEQ	#1,D6
pt_0ED7:
	MOVE.W	D6,dat_CurrentSample
	TST.W	dat_FileSizeMode
	BNE.S	pt_0ED8
	TST.L	dat_XPKWriteActive
	BNE.S	pt_0ED8
	BSR.W	pt_DrawSampleHex
pt_0ED8:
	BSR.S	pt_0EDD
	BNE.S	pt_CheckCloseAndBranch
	ADDQ.B	#1,D6
	CMP.B	#$20,D6
	BNE.S	pt_0ED7
	BSR.W	pt_CheckCanClose
	MOVE.W	(dat_FileSizeWord,PC),dat_CurrentSample
	TST.W	dat_FileSizeMode
	BEQ.S	pt_0ED9
	RTS
pt_0ED9:
	TST.L	dat_XPKWriteActive
	BEQ.S	pt_0EDA
	RTS
pt_0EDA:
	BSR.W	pt_DrawSampleHex
	BSR.W	pt_ClearStatusMsg
	JSR	pt_Efx8SaveNote
	NOP
	NOP
dat_FileSizeWord:
	DS.W	1
pt_CheckCloseAndBranch:
	BSR.W	pt_CheckCanClose
	BRA.W	pt_0FE6
pt_0EDD:
	MOVE.W	D6,D0
	LSL.W	#2,D0
	LEA	(dat_ModulePtr,PC),A0
	MOVE.L	(0,A0,D0.W),D1
	BNE.S	pt_0EDE
	RTS
pt_0EDE:
	MOVE.L	(124,A0,D0.W),D0
	BNE.S	pt_0EDF
	RTS
pt_0EDF:
	MOVE.L	D1,dat_FileWriteAddr
	MOVEA.L	(dat_ModulePtr,PC),A0
	LEA	(12,A0),A0
	MOVE.W	D6,D0
	MULU	#s_SIZEOF,D0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	MOVE.B	(2,A0),D1
	BTST	#7,D1
	SNE	D1
	MOVE.B	D1,dat_FileHandleVar
	LSL.L	#1,D0
	MOVE.L	D0,dat_FileWriteSize
	BNE.S	pt_0EE0
	MOVEQ	#0,D0
	RTS
pt_0EE0:
	BSR.W	pt_WriteFileData
	TST.B	dat_FileHandleVar
	BEQ.S	pt_ReturnFromSub
	LEA	SECSTRT_4,A0
	MOVE.W	D6,D1
	LSL.W	#3,D1
	ADDA.W	D1,A0
	MOVE.L	(A0)+,D1
	BEQ.S	pt_ReturnFromSub
	MOVE.L	(A0)+,D0
	BEQ.S	pt_ReturnFromSub
	MOVE.L	D1,dat_0EE3
	MOVE.L	D0,dat_FilePathBufPtr
	MOVE.L	#dat_FilePathBufPtr,dat_FileWriteAddr
	MOVE.L	#$00000004,dat_FileWriteSize
	BSR.S	pt_WriteFileData
	MOVE.L	dat_0EE3,dat_FileWriteAddr
	MOVE.L	dat_FilePathBufPtr,dat_FileWriteSize
	BSR.S	pt_WriteFileData
pt_ReturnFromSub:
	RTS
dat_FileHandleVar:
	DS.W	1
dat_0EE3:
	DS.L	1
dat_FilePathBufPtr:
	DS.L	1
pt_FileOpenCheck:
	TST.W	dat_FileSizeMode
	BNE.S	pt_FileOpenOK
	TST.L	dat_XPKWriteActive
	BNE.S	pt_FileOpenOK
pt_OpenFileWrite:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	#dat_FileNameBuf,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	MOVE.L	D0,D7
	BEQ.S	pt_FileOpFailed
pt_FileOpenOK:
	MOVEQ	#0,D0
	RTS
pt_WriteFileData:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	D7,D1
	MOVE.L	dat_FileWriteAddr,D2
	MOVE.L	dat_FileWriteSize,D3
	BSR.S	pt_DoWrite
	TST.L	D0
	BEQ.S	pt_FileOpFailed
	MOVEQ	#0,D0
	RTS
pt_FileOpFailed:
	MOVEQ	#-1,D0
	RTS
pt_CheckCanClose:
	TST.W	dat_FileSizeMode
	BEQ.S	pt_CloseFileOK
	RTS
pt_CloseFileOK:
	TST.L	dat_XPKWriteActive
	BEQ.S	pt_CloseFile
	RTS
pt_CloseFile:
	MOVEA.L	(dat_DosLibBase,PC),A6
	MOVE.L	D7,D1
	JMP	(-36,A6)
pt_DoWrite:
	TST.W	dat_FileSizeMode
	BNE.S	pt_CountBytes
	TST.L	dat_XPKWriteActive
	BNE.S	pt_MemCopyWrite
	JMP	(-48,A6)
pt_MemCopyWrite:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	(dat_XPKWritePtr,PC),A0
	MOVEA.L	D2,A1
pt_MemCopyLoop:
	MOVE.B	(A1)+,(A0)+
	SUBQ.L	#1,D3
	BGT.S	pt_MemCopyLoop
	MOVE.L	A0,dat_XPKWritePtr
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.L	D3,D0
	RTS
pt_CountBytes:
	ADD.L	D3,dat_FileSizeCount
	MOVE.L	D3,D0
	RTS
pt_CalcFileSize:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVE.L	dat_FileWriteSize,-(A7)
	MOVE.W	#$ffff,dat_FileSizeMode
	CLR.L	dat_FileSizeCount
	BSR.W	pt_GetSamplePtrPC
	CLR.W	dat_FileSizeMode
	MOVE.L	(A7)+,dat_FileWriteSize
	MOVEM.L	(A7)+,D1-D7/A0-A6
	MOVE.L	(dat_FileSizeCount,PC),D0
	RTS
dat_FileSizeMode:
	DS.W	1
dat_FileSizeCount:
	DS.L	1
pt_0EF4:
	CMPI.B	#$01,dat_PatternBufIdx
	BNE.W	pt_0EF7
	BSR.S	pt_CalcFileSize
	MOVE.L	D0,dat_FileWriteSize
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	#$00010000,D1
	MOVE.L	dat_FileWriteSize,D0
	JSR	(-198,A6)
	MOVE.L	D0,dat_XPKWriteActive
	BEQ.W	pt_0F00
	MOVE.L	D0,dat_XPKWritePtr
	MOVE.L	dat_FileWriteSize,-(A7)
	BSR.W	pt_GetSamplePtrPC
	MOVE.L	(A7)+,dat_FileWriteSize
	JSR	pt_OpenXpkLib
	TSTPC.L	dat_XpkLibBase
	BNE.S	pt_0EF5
	LEA	(str_CantOpenXpkLib,PC),A0
	BSR.W	pt_ShowStatusMsg
	JMP	pt_SetPaletteEdit
pt_0EF5:
	MOVEA.L	(dat_XpkLibBase,PC),A6
	MOVEQ	#0,D0
	MOVEQ	#1,D1
	LEA	(dat_0F2F,PC),A0
	SUBA.L	A1,A1
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(dat_0F10,PC),A0
	JSR	pt_ShowStatusMsg
	JSR	pt_SetPaletteSong
	MOVEM.L	(A7)+,D0-D7/A0-A6
	LEA	dat_068E,A0
	MOVEQ	#0,D0
	MOVE.B	dat_TimerCountHi,D0
	LSL.W	#2,D0
	LEA	(0,A0,D0.W),A0
	MOVE.L	(A0),dat_1486
	MOVE.L	dat_XPKWriteActive,dat_1482
	MOVE.L	dat_FileWriteSize,dat_1483
	BSR.W	pt_0F34
	MOVE.L	#dat_FileNameBuf,dat_1484
	MOVEQ	#0,D0
	MOVE.B	dat_TempoCounter,D0
	MOVE.L	D0,dat_1485
	LEA	dat_1481,A0
	JSR	(-42,A6)
	BEQ.S	pt_0EF6
	LEA	(dat_0F0A,PC),A0
	JSR	pt_SetupEditScreen
	BRA.W	pt_SetPalInitTime
pt_0EF6:
	MOVE.L	(dat_XPKWriteActive,PC),D0
	MOVEA.L	D0,A1
	MOVE.L	dat_FileWriteSize,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_XPKWriteActive
	CLR.W	dat_RecordMode
	JSR	pt_InitTimeDisplay
	JMP	pt_RestorePalette
	DC.W	$4e75
pt_0EF7:
	BSR.W	pt_CalcFileSize
	MOVE.L	D0,dat_FileWriteSize
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	#$00010000,D1
	MOVE.L	dat_FileWriteSize,D0
	JSR	(-198,A6)
	MOVE.L	D0,dat_XPKWriteActive
	BEQ.W	pt_0F01
	MOVE.L	D0,dat_XPKWritePtr
	MOVE.L	dat_FileWriteSize,-(A7)
	BSR.W	pt_GetSamplePtrPC
	MOVE.L	(A7)+,dat_FileWriteSize
	JSR	pt_OpenPPLib
	BNE.S	pt_0EF8
	BSR.W	pt_XPKDecompCleanup
	LEA	(str_CantOpenPPLib,PC),A0
	BSR.W	pt_ShowStatusMsg
	JMP	pt_SetPaletteEdit
pt_0EF8:
	MOVEA.L	(dat_PPLibBase,PC),A6
	MOVEQ	#0,D0
	MOVE.B	dat_CursorAnimState,D0
	MOVEQ	#1,D1
	LEA	(dat_0F2F,PC),A0
	SUBA.L	A1,A1
	JSR	(-96,A6)
	MOVE.L	D0,dat_ColorDataPtr
	BNE.S	pt_0EF9
	BSR.W	pt_XPKDecompCleanup
	LEA	(dat_0F0D,PC),A0
	JSR	pt_SetupEditScreen
	BRA.W	pt_SetPalInitTime
pt_0EF9:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(dat_0F10,PC),A0
	JSR	pt_ShowStatusMsg
	JSR	pt_SetPaletteSong
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BSR.W	pt_OpenDiskOp
	MOVEA.L	(dat_ColorDataPtr,PC),A0
	MOVEA.L	(dat_XPKWriteActive,PC),A1
	MOVE.L	dat_FileWriteSize,D0
	JSR	(-108,A6)
	MOVE.L	D0,dat_0F06
	BNE.S	pt_0EFA
	BSR.W	pt_CloseDiskOp
	BSR.W	pt_XPKDecompCleanup
	LEA	(dat_0F0E,PC),A0
	BRA.W	pt_ShowStatusWait
pt_0EFA:
	BSR.W	pt_CloseDiskOp
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(dat_0F11,PC),A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
	BSR.W	pt_OpenFileWrite
	TST.L	D0
	BEQ.S	pt_0EFB
	BSR.W	pt_XPKDecompCleanup
	LEA	(dat_0F0F,PC),A0
	BRA.W	pt_ShowStatusWait
pt_0EFB:
	MOVE.L	D7,dat_ColorMapPtr
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(dat_0F12,PC),A0
	JSR	pt_ShowStatusMsg
	JSR	pt_SetPaletteDim
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.L	(dat_ColorMapPtr,PC),D0
	MOVEQ	#0,D1
	MOVE.B	dat_CursorAnimState,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEA.L	(dat_PPLibBase,PC),A6
	JSR	(-114,A6)
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(dat_0F13,PC),A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.L	(dat_ColorMapPtr,PC),D1
	MOVE.L	(dat_XPKWriteActive,PC),D2
	MOVE.L	(dat_0F06,PC),D3
	MOVEA.L	(dat_DosLibBase,PC),A6
	JSR	(-48,A6)
	TST.L	D0
	BNE.S	pt_0EFC
	MOVE.L	(dat_ColorMapPtr,PC),D7
	BSR.W	pt_CloseFile
	BSR.S	pt_XPKDecompCleanup
	LEA	(dat_0F0F,PC),A0
	BRA.S	pt_ShowStatusWait
pt_0EFC:
	MOVE.L	(dat_ColorMapPtr,PC),D7
	BSR.W	pt_CloseFile
	BSR.S	pt_XPKDecompCleanup
	BSR.W	pt_ClearStatusMsg
	JMP	pt_RestorePalette
pt_XPKDecompCleanup:
	MOVE.L	(dat_ColorDataPtr,PC),D0
	BEQ.S	pt_0EFE
	MOVEA.L	D0,A0
	MOVEA.L	(dat_PPLibBase,PC),A6
	JSR	(-102,A6)
	CLR.L	dat_ColorDataPtr
pt_0EFE:
	MOVE.L	(dat_XPKWriteActive,PC),D0
	BEQ.S	pt_0EFF
	MOVEA.L	D0,A1
	MOVE.L	dat_FileWriteSize,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	dat_XPKWriteActive
pt_0EFF:
	CLR.W	dat_RecordMode
	JSR	pt_InitTimeDisplay
	JMP	pt_RestorePalette
pt_0F00:
	LEA	(dat_0F0B,PC),A0
	JSR	pt_SetupEditScreen
	BRA.S	pt_SetPalInitTime
pt_0F01:
	LEA	(dat_0F0C,PC),A0
	JSR	pt_SetupEditScreen
	BRA.S	pt_SetPalInitTime
pt_ShowStatusWait:
	BSR.W	pt_ShowStatusMsg
pt_SetPalInitTime:
	JSR	pt_SetPaletteEdit
	JMP	pt_InitTimeDisplay
dat_XPKWriteActive:
	DS.L	1
dat_ColorDataPtr:
	DS.L	1
dat_0F06:
	DS.L	1
dat_XPKWritePtr:
	DS.L	1
dat_ColorMapPtr:
	DS.L	1
dat_FileReadPos:
	DS.L	1
dat_0F0A:
	DC.B	10,10,10
	DC.B	"     Error while",10
	DC.B	"     XPK-Packing!",0
dat_0F0B:
	DC.B	10,10,10
	DC.B	"  Not enough memory",10
	DC.B	"   for XPK-Packing!",0
dat_0F0C:
	DC.B	10,10,10
	DC.B	"  Not enough memory",10
	DC.B	"  for PowerPacking!",0
dat_0F0D:
	DC.B	10,10,10
	DC.B	"  Not enough memory",10
	DC.B	"   for CrunchInfo!",0
dat_0F0E:
	DC.B	"ERROR WHILE CRUNCHING!!",0
dat_0F0F:
	DC.B	"ERROR WHILE WRITING FILE!",0
dat_0F10:
	DC.B	"STANDBY, PACKING...",0
dat_0F11:
	DC.B	"WRITING PP MODULE..",0
dat_0F12:
	DC.B	"WRITING PP HEADER...",0
dat_0F13:
	DC.B	"WRITING PP DATA...",0
dat_0F14:
	DC.B	"CRUNCHING...",0
dat_0F15:
	DC.B	"LOADING PT IFFMOD FORMAT",0
dat_0F16:
	DC.B	"READING VERSIONSHUNK ...",0
dat_0F17:
	DC.B	"READING INFOPARAMETERS ...",0
dat_0F18:
	DC.B	"READING COMMENTS ...",0
dat_0F19:
	DC.B	"READING SONGDATAS ...",0
dat_0F1A:
	DC.B	"MISMATCH FILE TYPE!?",0
dat_0F1B:
	DC.B	"ITS (OCTA)MED!",0
dat_0F1C:
	DC.B	"ITS SYMPHONIE!",0
dat_0F1D:
	DC.B	"ITS DIGIBOOSTER!",0
dat_0F1E:
	DC.B	"ITS TFMX!",0
dat_0F1F:
	DC.B	"ITS FUTURE COMPOSER!",0
dat_0F20:
	DC.B	"ITS SONIC ARRANGER!",0
dat_0F21:
	DC.B	"ITS OCTALYZER!",0
str_UnknownFormat:
	DC.B	"UNKNOWN FORMAT!",0
str_NoPTProExec:
	DC.B	"NO PROTRACKER PRO EXEC!",0
str_CantOpenPPLib:
	DC.B	"CANT OPEN POWERPACKER.LIB!",0
str_CantOpenXpkLib:
	DC.B	"CANT OPEN XPKMASTER.LIB!",0,0
dat_XpkLibFlag:
	DS.W	1
dat_PaletteVar1:
	DS.L	1
dat_0F28:
	DS.L	1
dat_PaletteDataPtr:
	DS.L	1
dat_PaletteVar2:
	DS.L	1
dat_0F2B:
	DS.L	1
dat_PaletteVar3:
	DS.L	1
pt_OpenDiskOp:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	#$ffff,dat_DiskOpFlag
	JSR	pt_CopyPatternBlock
	SUBA.L	A0,A0
	SUBA.L	A1,A1
	LEA	dat_144D,A2
	JSR	pt_BlitCopyBlock
	LEA	(dat_0F14,PC),A0
	MOVE.W	#$0116,D0
	MOVEQ	#62,D1
	JSR	pt_DrawBoxedText
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_CloseDiskOp:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_CopyScreenBufs
	CLR.W	dat_DiskOpFlag
	JSR	pt_ClearKeyState
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D0
	RTS
dat_0F2F:
	MOVE.L	(4,A7),dat_0F31
	MOVE.L	(8,A7),dat_0F32
	MOVE.L	(12,A7),dat_0F33
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	(dat_0F30,PC),D0
	MOVE.L	(dat_0F31,PC),D2
	MOVE.L	D2,dat_0F30
	MOVE.L	(dat_0F33,PC),D3
	CMP.L	D0,D2
	BHI.S	pt_r178e4
	MOVEQ	#0,D0
pt_r178e4:
	LSR.L	#6,D0
	LSR.L	#6,D2
	LSR.L	#6,D3
	MULU.W	#$00ec,D0
	MULU.W	#$00ec,D2
	DIVU.W	D3,D0
	DIVU.W	D3,D2
	ADD.W	#$00ca,D0
	ADD.W	#$00ca,D2
	MOVEQ	#77,D1
	MOVE.W	#$0056,D3
	MOVEQ	#1,D5
	JSR	pt_SetupAudioDisplay
pt_r1790c:
	IFD	DEBUGAUTO
	JSR	dbg_AutoStep
	ENDC
	JSR	pt_GetKeypress
	MOVE.B	dat_KeyCode,D0
	CMP.B	#$45,D0
	BEQ.S	pt_r1792a
	TST.B	D0
	BNE.S	pt_r1790c
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#-1,D0
	RTS
pt_r1792a:
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVEQ	#0,D0
	RTS
dat_0F30:
	DS.L	1
dat_0F31:
	DS.L	1
dat_0F32:
	DS.L	1
dat_0F33:
	DS.L	1
pt_0F34:
	TST.B	dat_SampleNameBuf
	BEQ.S	pt_0F36
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.B	#$70,(A1)+
	MOVE.B	#$74,(A1)+
	MOVE.B	#$6d,(A1)+
	MOVE.B	#$2e,(A1)+
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVEQ	#19,D0
pt_0F35:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0F35
	RTS
pt_0F36:
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVE.B	#$6d,(A1)+
	MOVE.B	#$6f,(A1)+
	MOVE.B	#$64,(A1)+
	MOVE.B	#$2e,(A1)+
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVEQ	#19,D0
pt_0F37:
	MOVE.B	(A0)+,(A1)+
	DBF	D0,pt_0F37
	RTS
pt_ClearStatusMsg:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	(str_EmptyLine,PC),A0
	BSR.S	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_ShowStatusMsg:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_ScreenBuf2Ptr,A1
	ADDA.W	#$280d,A1
	MOVEQ	#4,D0
pt_ClearMsgLine:
	MOVEQ	#37,D1
pt_ClearMsgByte:
	CLR.B	(A1)+
	DBF	D1,pt_ClearMsgByte
	LEA	(42,A1),A1
	DBF	D0,pt_ClearMsgLine
	MOVEA.L	A0,A1
	MOVE.W	#$280d,D1
	MOVEQ	#-1,D0
pt_CountMsgLen:
	ADDQ.W	#1,D0
	TST.B	(A1)+
	BNE.S	pt_CountMsgLen
	BSR.W	pt_DrawTextAt
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_PreKeyCheck:
	TST.W	dat_RecordMode
	BNE.S	pt_CheckDiskOp
	JSR	pt_ClearKeyState
pt_CheckDiskOp:
	TST.W	dat_SamplerActive
	BEQ.S	pt_PatViewDrawAll2
	RTS
