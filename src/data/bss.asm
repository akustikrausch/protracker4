	SECTION S_3,BSS,CHIP

SECSTRT_3:
	DS.L	1408
chip_ScreenBuffer1:
	DS.L	1408
chip_BlitterBuffer:
	DS.L	256
chip_CopperWorkBuffer:
	DS.L	128
chip_AudioDMAEndMark:
	DS.L	1
chip_ScreenBitplanes2:
	DS.L	15120
chip_SilentSample:
	DS.L	1
chip_VuMux:
	DS.B	48*96+28+12

	SECTION S_4,BSS

SECSTRT_4:
	DS.L	200
dat_14CC:
	DS.L	200
dat_14CD:
	DS.L	200
dat_14CE:
	DS.L	200
dat_14CF:
	DS.L	66
dat_Channel1:
	DS.B	n_SIZEOF
dat_Channel2:
	DS.B	n_SIZEOF
dat_Channel3:
	DS.B	n_SIZEOF
dat_Channel4:
	DS.B	n_SIZEOF
dat_Channel5:
	DS.B	n_SIZEOF
dat_Channel6:
	DS.B	n_SIZEOF
dat_Channel7:
	DS.B	n_SIZEOF
dat_Channel8:
	DS.B	n_SIZEOF
dat_RpOldAudInt0:
	DS.L	1
dat_RpOldAudInt1:
	DS.L	1
dat_RpOldAudInt2:
	DS.L	1
dat_RpOldAudInt3:
	DS.L	1
dat_AudioDMAState:
	DS.L	1
dat_AudioDMACtrl:
	DS.L	1
dat_FileBrowserState:
	DS.W	1
dat_14E7:
	DS.B	1
dat_14E8:
	DS.B	1
dat_PatternEditVar:
	DS.L	1
dat_14EA:
	DS.L	27
dat_PatternEditBuf:
	DS.L	2
	DS.W	1
dat_14EC:
	DS.L	30
	DS.W	1
dat_14ED:
	DS.L	9
dat_DisplayBufPool:
	DS.L	64
dat_DisplayBufPool2:
	DS.L	64
dat_14F0:
	DS.L	64
dat_14F1:
	DS.L	64
dat_PatternDataBuf5:
	DS.L	512
dat_14F3:
	DS.L	512
dat_14F4:
	DS.L	64
dat_GfxBitplaneBuf:
	DS.L	38242
dat_WorkBuf1:
	DS.L	20
dat_WorkBuf2:
	DS.L	4
dat_14F8:
	DS.L	4
dat_CursorAnimBuf:
	DS.L	17
dat_CursorAnimState:
	DS.B	1
dat_CopperListFlag:
	DS.B	1
dat_CursorPhase:
	DS.W	1
dat_TimerCountHi:
	DS.W	1
dat_TimerCountLo:
	DS.W	1
dat_PatternBufFlag:
	DS.W	1
dat_PatternBufSize:
	DS.W	1
dat_PatternBufIdx:
	DS.W	1
dat_VBLCounterHi:
	DS.W	1
dat_VBLCounterLo:
	DS.W	1
dat_FontMode:
	DS.W	1
dat_SampleNameBuf:
	DS.W	1
dat_1506:
	DS.W	1
dat_1507:
	DS.W	1
	DS.B	1
dat_ModeFlags:
	DS.B	1
dat_1509:
	DS.W	1
	DS.B	1
dat_UICheckFlag:
	DS.B	1
dat_150B:
	DS.W	1
	DS.B	1
dat_InputReadyFlag:
	DS.B	1
dat_150D:
	DS.W	1
dat_UIBitFlags:
	DS.B	1
dat_UIStateFlag:
	DS.B	1
dat_NotifyHookVec:
	DS.L	8
dat_AudioBufWork:
	DS.L	4
dat_DiskIOReady:
	DS.B	1
dat_1513:
	DS.B	1
dat_1514:
	DS.B	1
dat_1515:
	DS.B	1
dat_1516:
	DS.W	1
dat_1517:
	DS.W	1
dat_DisplayWorkBuf:
	DS.L	5
dat_DisplayLineCount:
	DS.W	1
dat_SavedTempo:
	DS.W	1
dat_PalEdEntryIdx:
	DS.W	1
dat_PaletteIdxCounter:
	DS.W	1
dat_DisplayWorkBuf3:
	DS.L	123
dat_PatternLineBuf2:
	DS.L	123
dat_PatternDataBuf3:
	DS.L	48
dat_ScopeWorkBuf1:
	DS.L	8
	DS.W	1
dat_DisplayWorkBuf2:
	DS.L	12
dat_ScopeChanPos:
	DS.L	5
dat_1523:
	DS.L	5
dat_1524:
	DS.L	5
dat_1525:
	DS.L	5
dat_ScopeSampleTab:
	DS.L	496
dat_ScopeDisplayBuf:
	DS.L	160
dat_ScopeWorkBuf:
	DS.L	4
dat_PaletteEditBuf:
	DS.L	24
dat_152A:
	DS.L	9
	DS.W	1
dat_152B:
	DS.L	10
	DS.W	1
dat_FileNameBuf:
	DS.L	96
dat_FilePathBuf2:
	DS.L	96
dat_152E:
	DS.L	8
dat_ScopeAuxBuf:
	DS.L	7
dat_1530:
	DS.L	7
dat_ScopeBuf1:
	DS.L	7
	DS.W	1
dat_ScopeWorkBuf2:
	DS.L	7
	DS.W	1
dat_1533:
	DS.L	190
dat_1534:
	DS.L	44
dat_AudioIOReq:
	DS.L	18
dat_AudioMsgPort:
	DS.L	19
	DS.W	1
dat_PatternWorkBuf:
	DS.L	67
	DS.W	1
dat_WorkBuf3:
	DS.L	67
	DS.W	1
dat_FileIOBuf:
	DS.L	4
dat_FileIOBufAlt:
	DS.L	1
dat_153B:
	DS.L	1480
dat_WorkBufEnd:
	DS.L	1
dat_153D:
	DS.L	511
dat_153E:
	DS.L	1
dat_153F:
	DS.W	1
	DS.B	1
dat_1540:
	DS.B	1
	DS.W	1
dat_1541:
	DS.W	1
	DS.B	1
dat_1542:
	DS.B	1
	DS.W	1
	SHIFTPADBIG	8
dat_1543:
	DS.L	320
	IFD	DEBUGTRAP
dbg_Text:
	DS.B	32
	ENDC
	INCLUDE	"src/data/bss41.i"
	IFD	DEBUGFX
DBG_FXTICKS	EQU	1024
dbg_FxBuf:
	DS.B	DBG_FXTICKS*16
	ENDC
	IFD	DEBUGAUTO
dbg_AutoBuf:	DS.L	1
dbg_AutoBtnSteps: DS.W	1
dbg_AutoName:	DS.B	64
dbg_AutoPos:	DS.L	1
dbg_AutoLine:	DS.L	1
dbg_AutoFh:	DS.L	1
dbg_AutoLog:	DS.L	1
dbg_AutoX:	DS.W	1
dbg_AutoY:	DS.W	1
dbg_AutoWait:	DS.W	1
dbg_AutoHold:	DS.W	1
dbg_AutoLineLen: DS.W	1
dbg_AutoLmb:	DS.B	1
	EVEN
dbg_AutoBtnEnd:	DS.W	1
dbg_TickCnt:	DS.W	1
dbg_AutoRmb:	DS.B	1
dbg_AutoKeyRel:	DS.B	1
dbg_AutoPtrSet:	DS.B	1
dbg_AutoLoaded:	DS.B	1
dbg_AutoDone:	DS.B	1
dbg_AutoWaitStop: DS.B	1
dbg_AutoKeyQual: DS.B	1
dbg_AutoWaitTod: DS.B	1
	EVEN
dbg_AutoMainSP:	DS.L	1
dbg_AutoTypePtr: DS.L	1
dbg_AutoEclkTarget: DS.L	1
dbg_TimerBase:	DS.L	1
dbg_EPerFrame:	DS.L	1
dbg_EClock:	DS.L	2
dbg_TimerReq:	DS.B	40
dbg_AutoKeyN:	DS.W	1
dbg_AutoKeyNCode: DS.B	1
	EVEN
	ENDC
	IF	(chip_ScreenBitplanes-SECSTRT_2)<>$5000
	FAIL	Layout: chip_ScreenBitplanes muss SECSTRT_2+$5000 sein (zwei zusammenhaengende Bitplanes)
	ENDC
