;--- mixer
	RSRESET
mv_pos		RS.L	1	; abs addr
mv_frac		RS.W	1
mv_step		RS.L	1	; 16.16 smp per out smp
mv_end		RS.L	1	; abs addr, exclusive
mv_loopstart	RS.L	1	; abs addr
mv_looplen	RS.L	1	; bytes, 0 = no loop
mv_period	RS.W	1	; period mv_step is valid for
mv_vol		RS.W	1	; 0..64
mv_active	RS.B	1
mv_back		RS.B	1	; <>0: backwards (81y)
mv_SIZEOF	RS.B	0

MIX_RING	EQU	8192		; bytes per paula ch, power of 2
MIX_TICKMAX	EQU	4096		; smp, 32 bpm at 28.6 khz = 2235
MIX_LEAD	EQU	2		; ticks

mix_AudPtrTable: DS.L	8		; a5 per voice: paula regs or shadow
mix_AudPtrCur:	DS.L	1
mix_Shadow:	DS.B	8*aud_SIZEOF
mix_ChunkLists:	DS.B	4*800		; chunk lists voices 5-8
mix_Voices:	DS.B	8*mv_SIZEOF
mix_TickBuf:	DS.B	MIX_TICKMAX	; one tick of one paula ch
mix_Silence:	DS.B	16
mix_Ring:	DS.L	1		; chip 4*MIX_RING or 0
mix_WriteInt:	DS.L	1		; smp
mix_WriteFrac:	DS.W	1
mix_Spt:	DS.L	1		; smp per tick 16.16
mix_SptBpm:	DS.W	1		; bpm mix_Spt was built for
mix_SptMode:	DS.W	1		; dat_ModeFlags bit 0 mix_Spt is valid for
mix_Rate:	DS.W	1		; hz
mix_Period:	DS.W	1
mix_TicksDue:	DS.W	1		; ticks requested, not mixed yet
mix_PairMask:	DS.B	1		; bit n: pair n (voice n+1, n+5) mixed
mix_Active:	DS.B	1
mix_Enabled:	DS.B	1		; dat_CPUType >= 2
mix_Init:	DS.B	1
mix_RingFail:	DS.B	1
mix_RateLock:	DS.B	1		; rmb debounce
mix_RateSel:	DS.B	1		; 0 auto, 1 14khz, 2 22khz, 3 28.6khz
mix_Is68k:	DS.B	1		; 68000 mixer: paula 2/3 mixed, voices 1/2 direct
	EVEN
;--- 68000 mixer
mix68_VolTab:	DS.L	1		; 65*256
mix68_WinBase:	DS.L	1
mix68_RingBlock: DS.L	1		; chip block rings 2/3 (2*MIX_RING), 0 = none
mix68_GroupMv:	DS.L	3
mix68_ExpSrc:	DS.L	16		; per voice loopstart,len the loop buf is valid for
mix68_ExpLen:	DS.L	16		; per voice buf len (idx*8 like ExpSrc)
mix68_StepRate:	DS.W	1		; rate step table is valid for, 0 = none
mix68_Act:	DS.L	3
mix68_PA:	DS.L	1		; pt_Mix68Pair args
mix68_PB:	DS.L	1
mix68_PDst:	DS.L	1
mix68_PRest:	DS.L	1
mix68_PCnt:	DS.L	1
mix68_TBBase:	DS.L	1
mix68_TBWin:	DS.L	1
mix68_TBPos:	DS.W	1
mix68_TBFrac:	DS.W	1
mix68_TBIstep:	DS.W	1
mix68_TBFstep:	DS.W	1
mix68_TBVol:	DS.W	1
mix68_Drops:	DS.W	1		; ticks dropped
mix_TickLine:	DS.W	1		; raster line of last tick
mix68_DTick:	DS.W	1
mix68_DPend:	DS.W	1		; dma bits voices 1/2 started this tick
mix68_DLine:	DS.W	1
mix68_DLead:	DS.W	1		; ticks (2, slow mode 4)
mix68_DFifo:	DS.B	2*8*20		; 8 ticks * 2 voices * M68D_SIZE
mix68_DOn:	DS.B	1
	EVEN
	IFD	DEBUGFX
dbg75_EC:	DS.L	2
dbg75_T0:	DS.L	1
dbg75_WAbs:	DS.L	1
dbg75_Mix:	DS.L	16
dbg75_Dir:	DS.L	16
dbg75_NM:	DS.W	1
dbg75_ND:	DS.W	1
dbg75_Starts:	DS.W	1
dbg68_DTrig:	DS.W	1
dbg68_DDma:	DS.W	1
dbg68_DDmaOr:	DS.W	1
dbg68_CauseLine: DS.W	1
dbg68_LatMax:	DS.W	1		; lines
dbg68_LatSum:	DS.L	1
dbg68_Polls:	DS.L	1
dbg68_TLast:	DS.W	1
	EVEN
dbg68_TUpd:	DS.L	1
dbg68_TMix:	DS.L	1
dbg68_TCopy:	DS.L	1
	ENDC
mix68_Slow:	DS.B	1		; slow mode (7 mhz + fast ram, 5 khz, scopes off)
mix68_MemFail:	DS.B	1
	EVEN
	EVEN
mix_HintChans:	DS.W	1
;--- formats
fmt_Flt8Pending: DS.B	1
fmt_TruncPending:	DS.B	1
fmt_ExtPending:	DS.B	1
	EVEN
fmt_ExtPeriods:	DS.W	1		; cells with period outside 113..856
	EVEN
dat_CpuBench:	DS.L	1		; loops per 1/50 s, 0 = not measured
;--- efx8
efx8_State:	DS.L	8		; per ch: slide rate, tremor y, tremor cnt, retrig
efx8_Blend:	DS.B	4		; 84y per pair: share of voice n+4 in 15ths, 0 = off
efx8_PlayPrev:	DS.L	1
efx8_SavePending: DS.B	1
smp_MsgPending:	DS.B	1
	EVEN
;--- diskop
disk_ProcPtr:	DS.L	1
disk_OldWindowPtr: DS.L	1		; old pr_WindowPtr
disk_CfgProgdir:	DS.B	1
disk_ToolDone:	DS.B	1
disk_LongPtr:	DS.L	1		; full name of clicked entry, 0 = none
disk_LongCount:	DS.W	1
disk_Scratch:	DS.B	32
disk_LongPool:	DS.L	1		; 128*108, allocated on demand, not in bss (1 mb a500+ needs the room)
disk_DosLocked:	DS.B	1
	CNOP	0,2
;--- ahi
ahi_Want:	DS.B	1
ahi_Active:	DS.B	1
ahi_Failed:	DS.B	1
ahi_DevOpen:	DS.B	1
ahi_NoPaula:	DS.B	1
ahi_Half:	DS.B	1		; 0/1
ahi_Step:	DS.B	1
ahi_IoErr:	DS.B	1
	CNOP	0,2
ahi_Freq:	DS.W	1
ahi_Peak:	DS.W	1
ahi_ProcState:	DS.B	1		; 0 starting, 1 ready, 2 error, 3 done
	CNOP	0,4
ahi_Proc:	DS.L	1
	CNOP	0,4
ahi_Port:	DS.L	1
ahi_Req1:	DS.L	1
ahi_Base:	DS.L	1
ahi_Ctrl:	DS.L	1
ahi_Buf1:	DS.L	1		; 2 halves s16s
ahi_ReadPos:	DS.L	1		; smp in mixer ring
ahi_Sent:	DS.L	1
ahi_Done:	DS.L	1
ahi_Resync:	DS.L	1
ahi_Polls:	DS.L	1
ahi_Hook:	DS.L	5		; struct Hook
ahi_Info:	DS.L	6		; 2 * AHISampleInfo
ahi_Tags:	DS.L	12
;--- rtg
rtg_Want:	DS.B	1
rtg_Tried:	DS.B	1
rtg_ProcState:	DS.B	1		; 0 starting, 1 running, 2 error, 3 done
rtg_Step:	DS.B	1
rtg_Double:	DS.B	1		; double lines (640x512)
rtg_PalDirty:	DS.B	1		; reload clut
rtg_VblUp:	DS.B	1		; frame clock server installed
rtg_PriOld:	DS.B	1		; pri before the layer lock
	CNOP	0,4
rtg_Proc:	DS.L	1
rtg_Mode:	DS.L	1
rtg_Screen:	DS.L	1
rtg_Window:	DS.L	1
rtg_LineBuf:	DS.L	1		; 2*640
rtg_Blank:	DS.L	1		; empty ptr (chip)
rtg_Vbl:	DS.L	1		; vbl count, frame clock
rtg_FrameT0:	DS.L	1		; vbl count at last frame start
rtg_VblTask:	DS.L	1		; mirror proc, woken each vbl
rtg_VblMask:	DS.L	1
rtg_VblInt:	DS.B	22		; struct Interrupt
rtg_Frames:	DS.L	1
rtg_Stripe:	DS.W	1		; first line of this frame's check stripe
rtg_Full:	DS.B	1		; frames left reading every line (input)
	EVEN
rtg_Lines:	DS.L	1
rtg_Reads:	DS.L	1		; lines read from chip
rtg_Cop2:	DS.L	1
rtg_BplPt:	DS.L	6
rtg_ScrH:	DS.W	1
rtg_YOff:	DS.W	1
rtg_Con0:	DS.W	1
rtg_Mod1:	DS.W	1
rtg_Mod2:	DS.W	1
rtg_VStart:	DS.W	1
rtg_NumBanks:	DS.W	1
rtg_DiwH:	DS.W	1		; diwstrt h (sprite x)
rtg_SprNext:	DS.W	1		; next free sprite color idx (down)
rtg_Colors:	DS.W	32
rtg_PalTab:	DS.L	2+30*8*3+16*3+1
rtg_DimBuf:	DS.B	96
rtg_SprPt:	DS.L	8
rtg_NumSegs:	DS.W	1
rtg_SprIdx:	DS.B	4
disk_FreeText:	DS.B	8		; "dddd MB"
dat_DiskFreeMB:	DS.L	1		; free mb of diskop drive
cpu_EClock:	DS.L	2
cpu_TimerReq:	DS.B	40
;--- misc
mix_Overrun:	DS.W	1		; softint longer than a tick
	EVEN
mix_SoftInt:	DS.B	22		; struct Interrupt for Cause()
	EVEN
	IFD	DEBUGFX
DBG_MIXCH	EQU	49152		; bytes per ch in mix dump
dbg_MixBuf:	DS.L	1		; 4*DBG_MIXCH, allocated in pt_MixTaskPoll
dbg_MixPos:	DS.L	1
dbg_MixSoftCnt:	DS.L	1
dbg_MixCauseCnt: DS.L	1
dbg_MixStartCnt: DS.L	1
dbg_MixStopCnt:	DS.L	1
dbg_MixInitCnt:	DS.L	1
dbg_MixPlayPrev: DS.L	1
dbg_MixRestartCnt: DS.L	1
dbg_TruncCnt:	DS.L	1
dbg_MixLineStart: DS.W	1
dbg_MixLinesMax: DS.W	1		; lines
dbg_MixLinesSum: DS.L	1		; lines
	ENDC

	IFD	DEBUGAUTO
dbg_WdTicks:	DS.W	1		; cia ticks since last driver step
dbg_WdDone:	DS.B	1
	EVEN
dbg_WdText:	DS.B	64
dbg_StopInfo:	DS.B	48
dbg_StopCnt:	DS.W	1
dbg80_Idle:	DS.L	1		; exec IdleCount/DispCount/IDNestCnt/TDNestCnt
dbg80_Disp:	DS.L	1
dbg80_IDN:	DS.B	1
dbg80_TDN:	DS.B	1
dbg_InOrig:	DS.L	1		; orig is_Code of input handler
dbg_InEvent:	DS.B	22		; event for IND_WRITEEVENT
dbg_HwSnap:	DS.W	4		; HW cmd: DMACONR, INTENAR, INTREQR, ADKCONR
dbg_F00Cnt:	DS.W	1
dbg_F00Chan:	DS.L	1
dbg_F00Pat:	DS.L	1
dbg_F00Song:	DS.L	1
dbg_F00Note:	DS.L	1
dbg_StopPbCnt:	DS.W	1
dbg_StopPbRet:	DS.L	1
dbg_StopPbRet2: DS.L	1
dbg_StopPbPat:	DS.L	1
dbg_StopWas:	DS.B	1
	EVEN
dbg_ProcNow:	DS.L	1
dbg_WinPtrNow:	DS.L	1
	ENDC
	EVEN
x20_Base:	DS.L	1		; 68020 area, 0 on 68000
mix_Offline:	DS.B	1		; offline render in task, replayer irq calls do nothing
mix_OffCall:	DS.B	1		; pt_RpMusic call from renderer
mixit_SaveRate:	DS.W	1
mixit_SaveTempo:	DS.W	1
mixit_RowSize:	DS.W	1
mixit_SaveSpeed:	DS.L	1
mixit_SavePat:	DS.L	1
mixit_SavePos:	DS.L	1
mixit_SaveSong:	DS.L	1
mixit_Rate:	DS.L	1
mixit_Buf:	DS.L	1
;--- setup
set_Page:	DS.B	1		; 0 setup, 1 system
set_PollCnt:	DS.B	1
set_Line:	DS.B	48
set_Line2:	DS.B	64
set_Line3:	DS.B	64
set_Num:	DS.B	16
set_Num2:	DS.B	16
	EVEN
snd_Choice:	DS.B	1		; 0 none, 1 paula, 2 ahi
snd_VolDown:	DS.B	1		; tenths down, 0 = 100%
snd_StereoDown:	DS.B	1		; quarters down, 0 = 100%
snd_NameOk:	DS.B	1		; snd_AhiName valid for snd_AhiMode
snd_AhiMode:	DS.L	1		; 0 = AHI_DEFAULT_ID
snd_AhiName:	DS.B	40
snd_Tags:	DS.L	6
snd_Req:	DS.L	20		; AHIRequest (80 bytes)
rtg_UserMode:	DS.L	1		; 0 = auto
rtg_Scale1x:	DS.B	1		; no 2x, centered
rtg_WaitAdj:	DS.B	1		; frame period in vbl = 1 + adj (0..3)
;--- rtg window
prf_Chan:	DS.B	1		; 4/8, 0 = not saved
rtg_WinMode:	DS.B	1		; window on default public screen
rtg_BackCnt:	DS.B	1
rtg_RunWin:	DS.B	1		; running mirror is the wb window (rtg_WinMode when it started)
rtg_WinHeld:	DS.B	1		; frames left before drawing again after a drag
rtg_InBlock:	DS.B	1		; 1 = input not for pt
rtg_WinFail:	DS.B	1		; failed window step (10..14), 0 = ok
	EVEN
rtg_CgxBase:	DS.L	1
rtg_InOrig:	DS.L	1		; orig is_Code
rtg_XMap:	DS.L	1		; 4096 words src x per dst x, then 4096 bytes scale buf
rtg_ScaleBuf:	DS.L	1
rtg_WinLastPos:	DS.L	1		; window left/top seen last frame
rtg_LutBuf:	DS.L	1		; win w x h pixel values, 0 = direct rows
rtg_LutSize:	DS.L	1
rtg_WinW:	DS.W	1
rtg_WinH:	DS.W	1
rtg_DirtyY0:	DS.W	1		; dst rows to blit, y0 > y1 = none
rtg_DirtyY1:	DS.W	1
rtg_BlitAll:	DS.B	1		; next blit: whole window
	EVEN
rtg_CTab:	DS.L	256		; $00rrggbb per pixel value
rtg_Synth:	DS.B	22		; synthetic RAWMOUSE event
	EVEN
prf_Loaded:	DS.B	1
snd_Started:	DS.B	1
prf_Buf:	DS.L	10
	EVEN
set_Ready:	DS.B	1
sch_Scheme:	DS.B	1		; 0 = 4.1, 1 = 2.3
	EVEN
snd_Defer:	DS.B	1		; output switch in n main loops
scr41_Fail:	DS.B	1
	EVEN
scr41_Win:	DS.L	1		; 0 = none
	IFD	DEBUGAUTO
dbg_ScrBackPolls: DS.W	1
dbg_MonEsc:	DS.W	1		; sample monitor quits after n polls like esc
	EVEN
dbg_ScrBackWin:	DS.L	1
	ENDC
snd_ResDefer:	DS.B	1		; resume in n main loops
	EVEN
snd_ResMode:	DS.L	1		; dat_RpPlayMode, 0 = none
snd_ResSong:	DS.L	1
snd_ResPat:	DS.L	1
	EVEN
prf_Found:	DS.B	1
prf_AutoAhi:	DS.B	1
prf_AutoRtg:	DS.B	1
prf_MsgDone:	DS.B	1
prf_MsgCnt:	DS.W	1
aut_Buf:	DS.B	256
aut_Name:	DS.B	32
	EVEN
;--- vu8
vu8_On:		DS.B	1		; sprite data in 2-bar format
vu8_Cop:	DS.B	1		; copper multiplex jump installed
vu8_Frame:	DS.B	1		; plot every 2nd call
vu8_Steg:	DS.B	1		; 1/2 = bar bytes drawn in the analyzer backdrop
	EVEN
vu8_Dummy:	DS.L	2		; sprite header sink
vu8_Pos:	DS.B	8*20		; scope pos per ch like dat_ScopeChanPos
vu8_Src:	DS.B	8*8		; per ch: src ptr.l, scale.w, pad
vu8_CopOrg:	DS.L	3		; dat_14AB start before the jump
vu8_Bar2:	DS.L	4*48		; 2nd bar data per spr and row, like dma
vu8_Prev:	DS.W	4*3		; per spr: thresholds bar 1/2, pos
;--- formats
fmt_Flt8Buf:	DS.B	2048		; flt8 pattern pair while interleaving
