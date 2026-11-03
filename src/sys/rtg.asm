; rtg mirror: copper list -> chunky -> card (own proc, 68020+)
; not emulated: attached spr, fmode spr
RTG_ROWS	EQU	256
RTG_BANKS	EQU	30
RTG_SEGS	EQU	32
RTG_WINBUF	EQU	4096*2+4096*3	; x table (words) + rgb row, win width up to 4096
RTG_ROWCOPY	EQU	1280		; line buffer offset of the plane copy
RTG_COPCOPY	EQU	RTG_ROWCOPY+4*80	; copper list copy, one chip read per frame
RTG_COPMAX	EQU	4000
RTG_STRIPE	EQU	16		; lines checked per frame without a reason
RTG_HOT	EQU	25		; frames a changed line stays read
RTG_FULLN	EQU	10		; frames all lines read after input
RTG_LINEBUF	EQU	RTG_COPCOPY+4*RTG_COPMAX
SA_Width_	EQU	$80000023
SA_Height_	EQU	$80000024
SA_Depth_	EQU	$80000025
SA_Title_	EQU	$80000028
SA_Type_	EQU	$8000002d
SA_DisplayID_	EQU	$80000032
SA_ShowTitle_	EQU	$80000036
SA_Quiet_	EQU	$80000038
WA_Left_	EQU	$80000064
WA_Top_		EQU	$80000065
WA_Width_	EQU	$80000066
WA_Height_	EQU	$80000067
WA_CustomScreen_	EQU	$80000070
WA_Backdrop_	EQU	$80000085
WA_NoCareRefresh_	EQU	$80000087
WA_Borderless_	EQU	$80000088
WA_Activate_	EQU	$80000089
WA_RMBTrap_	EQU	$8000008a
WA_SimpleRefresh_	EQU	$8000008c
; wb window tags
WA_Title_	EQU	$8000006e
WA_MinWidth_	EQU	$80000072
WA_MinHeight_	EQU	$80000073
WA_MaxWidth_	EQU	$80000074
WA_MaxHeight_	EQU	$80000075
WA_InnerWidth_	EQU	$80000076
WA_InnerHeight_	EQU	$80000077
WA_PubScreen_	EQU	$80000079
WA_SizeGadget_	EQU	$80000081
WA_DragBar_	EQU	$80000082
WA_DepthGadget_	EQU	$80000083
WA_SmartRefresh_	EQU	$8000008d
WA_SizeBBottom_	EQU	$8000008f
WA_AutoAdjust_	EQU	$80000090

;--- pt task
; first poll: check wish, start proc once
pt_RtgPoll:
	TST.B	rtg_Tried
	BNE.S	.r
	ST	rtg_Tried
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	BTST	#1,(297,A6)		; AttnFlags AFB_68020
	BEQ.S	.no
	TST.B	rtg_Want		; tooltype rtg
	BNE.S	.go
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#rtg_FileName,D1
	MOVEQ	#-2,D2
	JSR	(-84,A6)		; Lock
	TST.L	D0
	BEQ.S	.auto
	MOVE.L	D0,D1
	JSR	(-90,A6)		; UnLock
	ST	rtg_Want
	BRA.S	.go
.auto:	JSR	pt_AutoRtg		; first run + matching card mode -> mirror on
	BEQ.S	.no
.go:	CLR.B	rtg_ProcState
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#rtg_ProcTags,D1
	JSR	(-498,A6)		; CreateNewProc
	MOVE.L	D0,rtg_Proc
.no:	MOVEM.L	(A7)+,D0-D7/A0-A6
.r:	RTS

; stop proc via ctrl-c, wait 3 s max
pt_RtgClose:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	rtg_Proc,D0
	BEQ.S	.r
	CMP.B	#3,rtg_ProcState
	BEQ.S	.gone
	MOVEA.L	D0,A1
	MOVE.L	#$1000,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-324,A6)		; Signal
	MOVEA.L	dat_DosLibBase,A6
	MOVE.W	#150,D7
.w:	CMP.B	#3,rtg_ProcState
	BEQ.S	.gone
	MOVEQ	#1,D1
	JSR	(-198,A6)		; Delay
	DBF	D7,.w
.gone:	CLR.L	rtg_Proc
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

;--- rtg process
pt_RtgProc:
	MOVEA.L	ABSEXECBASE.W,A6
	SUBA.L	A1,A1
	JSR	(-294,A6)		; FindTask(0)
	MOVEA.L	D0,A0
	MOVE.L	#-1,(184,A0)		; no dos requesters from mirror proc
	BSR.W	pt_RtgSetup
	TST.L	D0
	BNE.W	.err
	BSR.W	pt_RtgVblOn
	MOVE.B	#1,rtg_ProcState	; pri 1 in the window too: pt passes are
.loop:	MOVE.L	rtg_Vbl,D1		; long, pacing leaves pt half the cpu
	SUB.L	rtg_FrameT0,D1		; vbl spent on the last frame
	CMP.L	#50,D1
	BLS.S	.spent
	MOVEQ	#50,D1
.spent:	MOVEQ	#1,D7
	ADD.B	rtg_WaitAdj,D7
	SUB.W	D1,D7			; rest of the period
	CMP.W	D1,D7			; slow cpu: mirror takes half at most
	BGE.S	.rest
	MOVE.W	D1,D7
.rest:	TST.W	D7
	BGT.S	.more
	MOVEQ	#1,D7			; always one vbl for everybody else
.more:	SUBQ.W	#1,D7
	MOVEA.L	ABSEXECBASE.W,A6
.tof:	MOVE.L	rtg_VblMask,D1		; own vbl signal: sure to sleep, waittof
	BEQ.S	.gtof			; may poll the card
	MOVEQ	#0,D0
	JSR	(-306,A6)		; SetSignal: drop an old tick
	MOVE.L	rtg_VblMask,D0
	JSR	(-318,A6)		; Wait
	BRA.S	.tofn
.gtof:	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-270,A6)		; WaitTOF
	MOVEA.L	ABSEXECBASE.W,A6
.tofn:	DBF	D7,.tof
	MOVE.L	rtg_Vbl,rtg_FrameT0
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	JSR	(-306,A6)		; SetSignal(0,0)
	BTST	#12,D0			; SIGBREAKB_CTRL_C
	BNE.S	.down
	TST.B	rtg_RunWin		; win size per frame
	BEQ.S	.fr
	BSR.W	pt_RtgWinGeom
	BSR.W	pt_RtgWinHold		; dragging/sizing: hands off the layers
	BNE.W	.loop
.fr:	MOVE.W	#$0100,DMACON		; native picture unseen: no bpl dma, chip reads 2x
	IFD	DIAGWIN
	MOVE.L	dw_VblTot,-(A7)
	ENDC
	BSR.W	pt_RtgFrame
	IFD	DIAGWIN
	MOVE.L	dw_VblTot,D0
	SUB.L	(A7)+,D0
	ADD.L	D0,dw_TFr
	MOVE.L	dw_VblTot,-(A7)
	ENDC
	TST.B	rtg_RunWin
	BEQ.S	.cnt
	BSR.W	pt_RtgWinBlit
.cnt:
	IFD	DIAGWIN
	MOVE.L	dw_VblTot,D0
	SUB.L	(A7)+,D0
	ADD.L	D0,dw_TBl
	ENDC
	ADDQ.L	#1,rtg_Frames
	BRA.W	.loop
.err:	MOVE.B	#2,rtg_ProcState
.down:	BSR.W	pt_RtgVblOff
	BSR.W	pt_RtgTeardown
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-132,A6)		; Forbid, exit race-free
	MOVE.B	#3,rtg_ProcState
	MOVEQ	#0,D0
	RTS

; vertb server: frame clock of the mirror
pt_RtgVblSrv:
	ADDQ.L	#1,rtg_Vbl
	MOVE.L	rtg_VblMask,D0
	BEQ.S	.r
	MOVEA.L	rtg_VblTask,A1
	MOVE.L	A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-324,A6)		; Signal
	MOVEA.L	(A7)+,A6
.r:	MOVEQ	#0,D0
	RTS

pt_RtgVblOn:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	rtg_Vbl,rtg_FrameT0
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	276(A6),rtg_VblTask	; ThisTask
	MOVEQ	#-1,D0
	JSR	(-330,A6)		; AllocSignal
	MOVEQ	#0,D1
	TST.B	D0
	BMI.S	.ns
	BSET	D0,D1
.ns:	MOVE.L	D1,rtg_VblMask		; 0: no signal, then no wait either
	LEA	rtg_VblInt,A1
	MOVE.B	#2,8(A1)		; NT_INTERRUPT
	MOVE.B	#10,9(A1)		; pri 10: lower servers may be cut off
	MOVE.L	#rtg_ProcName,10(A1)
	MOVE.L	#pt_RtgVblSrv,18(A1)
	MOVEQ	#5,D0			; INTB_VERTB
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-168,A6)		; AddIntServer
	ST	rtg_VblUp
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

pt_RtgVblOff:
	TST.B	rtg_VblUp
	BEQ.S	.r
	SF	rtg_VblUp
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	LEA	rtg_VblInt,A1
	MOVEQ	#5,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-174,A6)		; RemIntServer
	MOVE.L	rtg_VblMask,D1
	BEQ.S	.nf
	CLR.L	rtg_VblMask
	MOVEQ	#-1,D0
.b:	ADDQ.L	#1,D0
	LSR.L	#1,D1
	BCC.S	.b			; mask -> signal number
	JSR	(-336,A6)		; FreeSignal
.nf:
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
.r:	RTS

; z=0: skip frame (window moving, lmb held off the picture = drag/size)
; z=1: draw; after a pause the whole window once more
pt_RtgWinHold:
	MOVEM.L	D0/A0,-(A7)
	MOVEA.L	rtg_Window,A0
	MOVE.L	4(A0),D0		; LeftEdge/TopEdge
	CMP.L	rtg_WinLastPos,D0
	BEQ.S	.still
	MOVE.L	D0,rtg_WinLastPos
	BRA.S	.hold
.still:	BTST	#6,CIAA_PRA		; lmb down?
	BNE.S	.free
	TST.B	rtg_InBlock		; ... off the picture
	BEQ.S	.free
	MOVEA.L	dat_IntuiLibBase,A0	; ... of our own window (border/title), not elsewhere
	MOVEA.L	52(A0),A0		; IntuitionBase->ActiveWindow
	CMPA.L	rtg_Window,A0
	BEQ.S	.hold
.free:	TST.B	rtg_WinHeld
	BEQ.S	.go
	SUBQ.B	#1,rtg_WinHeld
	BNE.S	.busy
	BSR.W	pt_RtgWinRedraw
.go:	MOVEM.L	(A7)+,D0/A0
	CMP.B	D0,D0			; z=1
	RTS
.hold:	MOVE.B	#3,rtg_WinHeld
.busy:	MOVEM.L	(A7)+,D0/A0
	MOVEQ	#1,D0			; z=0
	RTS

; find card mode 640 x d0, depth 8; a6=gfxbase -> d0=id or -1
; card ids >= $00100000; p96 lacks DIPF_IS_FOREIGN -> no BestModeID
pt_RtgFindMode:
	MOVEM.L	D1-D7/A0-A1,-(A7)
	MOVE.L	D0,D6			; Hoehe
	MOVEQ	#-1,D7
.next:	MOVE.L	D7,D0
	JSR	(-732,A6)		; NextDisplayInfo
	MOVE.L	D0,D7
	CMP.L	#-1,D0
	BEQ.S	.out
	CMP.L	#$00100000,D7
	BLO.S	.next
	SUBA.L	A0,A0
	LEA	rtg_DimBuf,A1
	MOVEQ	#88,D0
	MOVE.L	#$80001000,D1		; DTAG_DIMS
	MOVE.L	D7,D2
	JSR	(-756,A6)		; GetDisplayInfoData
	TST.L	D0
	BEQ.S	.next
	LEA	rtg_DimBuf,A1
	CMP.W	#8,16(A1)		; MaxDepth
	BNE.S	.next
	MOVE.W	30(A1),D0		; Nominal.MaxX
	SUB.W	26(A1),D0
	CMP.W	#639,D0
	BNE.S	.next
	MOVE.W	32(A1),D0		; Nominal.MaxY
	SUB.W	28(A1),D0
	ADDQ.W	#1,D0
	CMP.W	D6,D0
	BNE.S	.next
.out:	MOVE.L	D7,D0
	MOVEM.L	(A7)+,D1-D7/A0-A1
	RTS

; mode d0 8 bit + 640 wide -> d1=height else 0, a6=gfxbase
pt_RtgModeH:
	MOVEM.L	D0/D2/A0-A1,-(A7)
	MOVE.L	D0,D2
	SUBA.L	A0,A0
	LEA	rtg_DimBuf,A1
	MOVEQ	#88,D0
	MOVE.L	#$80001000,D1		; DTAG_DIMS
	JSR	(-756,A6)		; GetDisplayInfoData
	MOVEQ	#0,D1
	TST.L	D0
	BEQ.S	.r
	LEA	rtg_DimBuf,A1
	CMP.W	#8,16(A1)		; MaxDepth
	BNE.S	.r
	MOVE.W	30(A1),D0
	SUB.W	26(A1),D0
	CMP.W	#639,D0
	BNE.S	.r
	MOVE.W	32(A1),D1
	SUB.W	28(A1),D1
	ADDQ.W	#1,D1
.r:	MOVEM.L	(A7)+,D0/D2/A0-A1
	RTS

; open scr/win/bufs -> d0=0 ok
pt_RtgSetup:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVE.B	rtg_WinMode,rtg_RunWin
	MOVE.B	#1,rtg_Step
	TST.L	x20_Base		; tables live in x20 area
	BEQ.W	.fail
	TST.B	rtg_RunWin		; wb window
	BEQ.S	.scr
	BSR.W	pt_RtgWinSetup
	TST.L	D0
	BEQ.W	.common
	SF	rtg_WinMode
	SF	rtg_RunWin		; no card on wb / no cybergraphics -> own screen
.scr:
	; mode: 640x512 (line doubled) else 640x480 centered, setup choice first
	MOVEA.L	dat_GfxLibBase,A6
	MOVE.L	rtg_UserMode,D0
	BEQ.S	.auto
	BSR.W	pt_RtgModeH		; d1 = height or 0
	CMP.W	#512,D1
	BEQ.S	.m512
	CMP.W	#480,D1
	BEQ.S	.m480
.auto:	MOVE.L	#512,D0
	BSR.W	pt_RtgFindMode
	CMP.L	#-1,D0
	BNE.S	.m512
	MOVE.L	#480,D0
	BSR.W	pt_RtgFindMode
	CMP.L	#-1,D0
	BEQ.W	.fail
.m480:	SF	rtg_Double
	MOVE.W	#480,rtg_ScrH
	MOVE.W	#(480-RTG_ROWS)/2,rtg_YOff
	BRA.S	.mode
.m512:	MOVE.W	#512,rtg_ScrH
	ST	rtg_Double
	CLR.W	rtg_YOff
	TST.B	rtg_Scale1x		; scale 1x: no doubling, centered
	BEQ.S	.mode
	SF	rtg_Double
	MOVE.W	#(512-RTG_ROWS)/2,rtg_YOff
.mode:	MOVE.L	D0,rtg_Mode
	MOVE.B	#2,rtg_Step
	LEA	rtg_ScrTags,A1
	MOVE.L	D0,4(A1)		; SA_DisplayID
	MOVEQ	#0,D0
	MOVE.W	rtg_ScrH,D0
	MOVE.L	D0,20(A1)		; SA_Height
	SUBA.L	A0,A0
	MOVEA.L	dat_IntuiLibBase,A6
	JSR	(-612,A6)		; OpenScreenTagList
	MOVE.L	D0,rtg_Screen
	BEQ.W	.fail
	MOVE.B	#3,rtg_Step
	LEA	rtg_WinTags,A1
	MOVE.L	D0,4(A1)		; WA_CustomScreen
	MOVEQ	#0,D0
	MOVE.W	rtg_ScrH,D0
	MOVE.L	D0,36(A1)		; WA_Height
	SUBA.L	A0,A0
	JSR	(-606,A6)		; OpenWindowTagList
	MOVE.L	D0,rtg_Window
	BEQ.W	.fail
.common:
	MOVE.B	#4,rtg_Step
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#16,D0
	MOVE.L	#$10003,D1		; chip|clear: empty ptr
	JSR	(-198,A6)
	MOVE.L	D0,rtg_Blank
	BEQ.S	.nobl
	TST.B	rtg_RunWin		; window: wb ptr stays
	BNE.S	.nobl
	MOVEA.L	rtg_Window,A0
	MOVEA.L	D0,A1
	MOVEQ	#1,D0			; Hoehe
	MOVEQ	#16,D1			; Breite
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEA.L	dat_IntuiLibBase,A6
	JSR	(-270,A6)		; SetPointer, hide intui ptr (pt draws its own)
.nobl:	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	#RTG_LINEBUF,D0
	MOVEQ	#1,D1			; MEMF_PUBLIC
	JSR	(-198,A6)
	MOVE.L	D0,rtg_LineBuf
	BEQ.W	.fail
	MOVE.B	#5,rtg_Step
	; p2c table: byte -> 8 bytes 0/1 (msb first)
	X20LEA	X20_RTGP2C,A0
	MOVEQ	#0,D0
.t1:	MOVEQ	#7,D1
.t2:	MOVEQ	#0,D2
	BTST	D1,D0
	BEQ.S	.t3
	MOVEQ	#1,D2
.t3:	MOVE.B	D2,(A0)+
	DBF	D1,.t2
	ADDQ.B	#1,D0
	BNE.S	.t1
	BSR.W	pt_RtgPoolReset
	MOVE.B	#6,rtg_Step
	MOVEQ	#0,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
.fail:	MOVEQ	#-1,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS

pt_RtgTeardown:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	IFD	DIAGWIN
	BSR.W	dw_Stop
	ENDC
	BSR.W	pt_RtgInUnhook		; input direct to pt again
	SF	rtg_InBlock
	MOVE.W	#$8100,DMACON		; native picture back
	MOVEA.L	dat_IntuiLibBase,A6
	BSR.W	pt_RtgBufFree
	MOVE.L	rtg_Window,D0
	BEQ.S	.nw
	MOVEA.L	D0,A0
	JSR	(-72,A6)		; CloseWindow
	CLR.L	rtg_Window
	TST.B	rtg_RunWin		; win: pt screen back to front
	BEQ.S	.nw
	MOVE.L	dat_ScreenPtr,D0
	BEQ.S	.nw
	MOVEA.L	D0,A0
	JSR	(-252,A6)		; ScreenToFront
.nw:	MOVE.L	rtg_Screen,D0
	BEQ.S	.ns
	MOVEA.L	D0,A0
	JSR	(-66,A6)		; CloseScreen
	CLR.L	rtg_Screen
.ns:	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.L	rtg_LineBuf,D0
	BEQ.S	.nb
	MOVEA.L	D0,A1
	MOVE.L	#RTG_LINEBUF,D0
	JSR	(-210,A6)
	CLR.L	rtg_LineBuf
.nb:	MOVE.L	rtg_Blank,D0
	BEQ.S	.nbl
	MOVEA.L	D0,A1
	MOVEQ	#16,D0
	JSR	(-210,A6)
	CLR.L	rtg_Blank
.nbl:	MOVE.L	rtg_XMap,D0
	BEQ.S	.nx
	MOVEA.L	D0,A1
	MOVE.L	#RTG_WINBUF,D0
	JSR	(-210,A6)
	CLR.L	rtg_XMap
.nx:	MOVE.L	rtg_CgxBase,D0
	BEQ.S	.r
	MOVEA.L	D0,A1
	JSR	(-414,A6)		; CloseLibrary
	CLR.L	rtg_CgxBase
.r:	SF	rtg_RunWin
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; force full redraw
pt_RtgInvalidate:
	MOVEM.L	D0/A0,-(A7)
	X20LEA	X20_RTGSIG,A0
	MOVE.W	#RTG_ROWS-1,D0
.i:	MOVE.L	#-1,(A0)+
	DBF	D0,.i
	MOVEM.L	(A7)+,D0/A0
	RTS

;--- frame
; walk copper list, render rows; a4=cop d4=raster line d5=vhigh ofs
pt_RtgFrame:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	ADD.W	#RTG_STRIPE,rtg_Stripe	; next stripe
	TST.B	dat_KeyCode		; input: pt answers on screen, read all
	BNE.S	.in
	BTST	#6,CIAA_PRA		; lmb
	BEQ.S	.in
	BTST	#2,$dff016		; rmb
	BEQ.S	.in
	TST.B	rtg_Full
	BEQ.S	.go
	SUBQ.B	#1,rtg_Full
	BRA.S	.go
.in:	MOVE.B	#RTG_FULLN,rtg_Full
.go:
	MOVE.L	dat_ActiveCopperPtr,D0
	BEQ.W	.out
	MOVEA.L	D0,A0
	MOVEA.L	rtg_LineBuf,A4
	LEA	RTG_COPCOPY(A4),A4
	MOVEA.L	A4,A1
	MOVE.W	#RTG_COPMAX-2,D0
.cc:	MOVE.L	(A0)+,D1		; chip is slow: list read once into fast ram
	MOVE.L	D1,(A1)+
	CMP.L	#$fffffffe,D1
	DBEQ	D0,.cc
	MOVE.L	#$fffffffe,(A1)		; end even if cut
	BSR.W	pt_RtgSprBuild		; spr from SPRxPT in cop list
	LEA	rtg_BplPt,A0
	MOVEQ	#5,D0
.cb:	CLR.L	(A0)+
	DBF	D0,.cb
	CLR.W	rtg_Con0
	CLR.W	rtg_Mod1
	CLR.W	rtg_Mod2
	MOVE.W	#$2c,rtg_VStart
	MOVEQ	#0,D4			; Rasterzeile
	MOVEQ	#0,D5			; vhigh
	MOVE.W	#4000,D7		; insn limit
.cop:	SUBQ.W	#1,D7
	BMI.W	.end
	MOVE.L	(A4)+,D1
	MOVE.L	D1,D0
	SWAP	D0
	BTST	#0,D0
	BNE.W	.waitskip
	AND.W	#$01fe,D0
	CMP.W	#$0180,D0
	BLO.S	.notcol
	CMP.W	#$01be,D0
	BHI.S	.cop
	SUB.W	#$0180,D0
	LEA	rtg_Colors,A0
	MOVE.W	D1,(A0,D0.W)
	BRA.S	.cop
.notcol:
	CMP.W	#$00e0,D0
	BLO.S	.notbpl
	CMP.W	#$00f6,D0
	BHI.S	.notbpl
	SUB.W	#$00e0,D0
	LEA	rtg_BplPt,A0
	BTST	#1,D0
	BNE.S	.lo
	MOVE.W	D1,(A0,D0.W)		; hohes Wort
	BRA.S	.cop
.lo:	MOVE.W	D1,(A0,D0.W)		; lo word (+2 in long)
	BRA.S	.cop
.notbpl:
	CMP.W	#$0100,D0
	BNE.S	.n100
	MOVE.W	D1,rtg_Con0
	BRA.S	.cop
.n100:	CMP.W	#$0108,D0
	BNE.S	.n108
	MOVE.W	D1,rtg_Mod1
	BRA.W	.cop
.n108:	CMP.W	#$010a,D0
	BNE.S	.n10a
	MOVE.W	D1,rtg_Mod2
	BRA.W	.cop
.n10a:	CMP.W	#$008e,D0
	BNE.S	.n8e
	MOVE.W	D1,D2
	LSR.W	#8,D2
	MOVE.W	D2,rtg_VStart
	AND.W	#$ff,D1
	MOVE.W	D1,rtg_DiwH
	BRA.W	.cop
.n8e:	CMP.W	#$0084,D0
	BNE.S	.n84
	MOVE.W	D1,rtg_Cop2
	BRA.W	.cop
.n84:	CMP.W	#$0086,D0
	BNE.S	.n86
	MOVE.W	D1,rtg_Cop2+2
	BRA.W	.cop
.n86:	CMP.W	#$008a,D0		; COPJMP2
	BNE.W	.cop
	MOVE.L	rtg_Cop2,D2
	BEQ.W	.cop
	MOVEA.L	D2,A4
	BRA.W	.cop
.waitskip:
	BTST	#0,D1
	BNE.W	.cop			; ignore SKIP
	CMP.W	#$ffff,D0
	BNE.S	.wait
	CMP.W	#$fffe,D1
	BEQ.S	.end
.wait:	MOVEQ	#0,D2
	MOVE.W	D0,D2
	LSR.W	#8,D2
	ADD.W	D5,D2			; Zielzeile
	CMP.W	D4,D2
	BHS.S	.wfwd
	MOVE.W	D4,D2			; target passed: hw does not wait (e.g. $E307 after $E507)
.wfwd:	BSR.W	pt_RtgLines		; D4 .. D2-1
	MOVE.W	D2,D4
	CMP.W	#$ffdf,D0
	BNE.W	.cop
	MOVE.W	#256,D5
	BRA.W	.cop
.end:	MOVE.W	rtg_VStart,D2		; rest of win
	ADD.W	#RTG_ROWS,D2
	BSR.W	pt_RtgLines
	BSR.W	pt_RtgPalette
.out:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; rows d4..d2-1, only inside win VStart..VStart+255
pt_RtgLines:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	D4,D6
.l:	CMP.W	D2,D6
	BHS.S	.r
	MOVE.W	D6,D0
	SUB.W	rtg_VStart,D0
	BMI.S	.n
	CMP.W	#RTG_ROWS,D0
	BHS.S	.n
	MOVEM.L	D2/D6,-(A7)
	BSR.W	pt_RtgRow		; D0 = Bildzeile
	MOVEM.L	(A7)+,D2/D6
.n:	ADDQ.W	#1,D6
	BRA.S	.l
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; one row d0=0..255: bank, sig, convert+write if changed, advance ptrs
; chip is slow: a line is read only if hot, in the stripe, after input
; or when its bank/ptrs/sprites changed; else its last plane sum counts
pt_RtgRow:
	MOVE.W	D0,D7			; row
	MOVE.W	rtg_Con0,D3
	LSR.W	#8,D3
	LSR.W	#4,D3
	AND.W	#7,D3			; Bitplanes
	CMP.W	#4,D3
	BLS.S	.np
	MOVEQ	#4,D3
.np:	BSR.W	pt_RtgBank		; bank
	MOVE.L	D1,D5			; key: bank, planes, ptrs
	SWAP	D5
	OR.W	D3,D5
	LEA	rtg_BplPt,A2
	MOVE.W	D3,D2
	BRA.S	.ke
.kl:	ROL.L	#5,D5
	ADD.L	(A2)+,D5
.ke:	DBF	D2,.kl
	MOVE.W	D7,D4
	LSL.W	#2,D4			; long idx
	X20LEA	X20_RTGKEY,A0
	CMP.L	(A0,D4.W),D5
	BNE.S	.rd
	TST.B	rtg_Full
	BNE.S	.rd
	X20LEA	X20_RTGHEAT,A0
	TST.B	(A0,D7.W)
	BNE.S	.rd
	MOVE.W	D7,D0
	SUB.W	rtg_Stripe,D0
	AND.W	#RTG_ROWS-1,D0
	CMP.W	#RTG_STRIPE,D0
	BLO.S	.rd
	X20LEA	X20_RTGPSIG,A0		; untouched: last sum, no chip read
	MOVE.L	(A0,D4.W),D6
	ADD.L	D5,D6
	BSR.W	pt_RtgSprSig
	X20LEA	X20_RTGSIG,A0
	CMP.L	(A0,D4.W),D6
	BEQ.W	.adv
.rd:	X20LEA	X20_RTGKEY,A0
	MOVE.L	D5,(A0,D4.W)
	ADDQ.L	#1,rtg_Reads
	MOVEQ	#0,D6			; plane sum, 20 longs each
	LEA	rtg_BplPt,A2
	MOVEA.L	rtg_LineBuf,A4
	LEA	RTG_ROWCOPY(A4),A4	; planes to fast ram, chip read once
	MOVE.W	D3,D2
	SUBQ.W	#1,D2
	BMI.S	.sigd
.sp:	MOVEA.L	(A2)+,A0
	MOVE.L	A0,D0
	BTST	#0,D0
	BNE.S	.odd			; odd -> not fetched
	MOVEQ	#19,D0
.sl:	ROL.L	#1,D6
	MOVE.L	(A0)+,(A4)
	ADD.L	(A4)+,D6
	DBF	D0,.sl
	BRA.S	.spn
.odd:	MOVEQ	#19,D0
.oc:	MOVE.L	(A0)+,(A4)+
	DBF	D0,.oc
.spn:	DBF	D2,.sp
.sigd:	X20LEA	X20_RTGHEAT,A1
	X20LEA	X20_RTGPSIG,A0
	CMP.L	(A0,D4.W),D6
	BEQ.S	.cold
	MOVE.L	D6,(A0,D4.W)
	MOVE.B	#RTG_HOT,(A1,D7.W)	; changed: read it every frame a while
	BRA.S	.sum
.cold:	TST.B	(A1,D7.W)
	BEQ.S	.sum
	SUBQ.B	#1,(A1,D7.W)
.sum:	ADD.L	D5,D6
	BSR.W	pt_RtgSprSig
	X20LEA	X20_RTGSIG,A0
	CMP.L	(A0,D4.W),D6
	BEQ.W	.adv
	MOVE.L	D6,(A0,D4.W)
	; convert to rtg_LineBuf
	MOVEA.L	rtg_LineBuf,A1
	MOVE.L	D1,D5
	LSL.L	#3,D5			; bank * 8
	MOVE.L	D5,D0
	LSL.L	#8,D0
	OR.L	D0,D5
	MOVE.L	D5,D0
	SWAP	D0
	OR.L	D0,D5			; all 4 bytes
	X20LEA	X20_RTGP2C,A3
	MOVEA.L	rtg_LineBuf,A4
	LEA	RTG_ROWCOPY(A4),A4
	MOVEQ	#0,D4			; byte idx 0..79
.bx:	MOVE.L	D5,D0			; px 0-3
	MOVE.L	D5,D1			; px 4-7
	MOVEA.L	A4,A2
	MOVEQ	#0,D6			; plane
.pl:	CMP.W	D3,D6
	BHS.S	.pld
	MOVEQ	#0,D2
	MOVE.B	(A2,D4.W),D2
	LEA	80(A2),A2
	LSL.W	#3,D2
	MOVE.L	(A3,D2.W),A5		; bits 7-4 as bytes
	MOVE.L	4(A3,D2.W),A6		; bits 3-0
	MOVE.L	A5,D2
	LSL.L	D6,D2
	OR.L	D2,D0
	MOVE.L	A6,D2
	LSL.L	D6,D2
	OR.L	D2,D1
	ADDQ.W	#1,D6
	BRA.S	.pl
.pld:	MOVE.L	D0,(A1)+
	MOVE.L	D1,(A1)+
	ADDQ.W	#1,D4
	CMP.W	#80,D4
	BLO.S	.bx
	; sprites
	BSR.W	pt_RtgSprites
	TST.B	rtg_RunWin		; win: write scaled into wb window
	BEQ.S	.scrw
	BSR.W	pt_RtgWinRow
	BRA.W	.adv
.scrw:
	MOVEA.L	rtg_LineBuf,A0
	MOVEQ	#0,D1			; ystart
	MOVE.W	D7,D1
	MOVE.L	D1,D3
	TST.B	rtg_Double
	BEQ.S	.single
	ADD.L	D1,D1
	MOVE.L	D1,D3
	ADDQ.L	#1,D3			; two rows
	LEA	640(A0),A1		; 2nd row = copy
	MOVE.W	#640/4-1,D0
.cp:	MOVE.L	(A0)+,(A1)+
	DBF	D0,.cp
	MOVEA.L	rtg_LineBuf,A0
	BRA.S	.wr
.single:
	ADD.W	rtg_YOff,D1
	MOVE.L	D1,D3
.wr:	MOVEA.L	A0,A2			; array
	MOVEA.L	rtg_Screen,A0
	LEA	84(A0),A0		; Screen->RastPort
	MOVEQ	#0,D0			; xstart
	MOVE.L	#639,D2			; xstop
	MOVE.L	#640,D4			; bytesperrow
	MOVE.L	A6,-(A7)
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-1056,A6)		; WriteChunkyPixels(rp,xstart,ystart,xstop,ystop,array,bpr)
	MOVEA.L	(A7)+,A6
	ADDQ.L	#1,rtg_Lines
.adv:	; .adv: ; bpl ptrs: only active planes advance, 80 + modulo
	; odd planes BPL1MOD, even BPL2MOD, disabled planes fetch nothing
	LEA	rtg_BplPt,A0
	MOVE.W	rtg_Mod1,D0
	EXT.L	D0
	ADD.L	#80,D0
	MOVE.W	rtg_Mod2,D1
	EXT.L	D1
	ADD.L	#80,D1
	MOVE.W	rtg_Con0,D2
	LSR.W	#8,D2
	LSR.W	#4,D2
	AND.W	#7,D2
	SUBQ.W	#1,D2
	BMI.S	.advd
.advl:	ADD.L	D0,(A0)+
	EXG	D0,D1
	DBF	D2,.advl
.advd:	RTS

; find/alloc color bank for rtg_Colors[0..7] -> d1 = bank
pt_RtgBank:
	MOVEM.L	D0/D2-D3/A0-A1,-(A7)
	X20LEA	X20_RTGBANKS,A0
	MOVEQ	#0,D1
.s:	CMP.W	rtg_NumBanks,D1
	BHS.S	.new
	MOVEQ	#7,D2
	LEA	rtg_Colors,A1
	MOVE.L	A0,-(A7)
.c:	CMPM.W	(A0)+,(A1)+
	DBNE	D2,.c
	MOVEA.L	(A7)+,A0
	BEQ.S	.got
	LEA	16(A0),A0
	ADDQ.W	#1,D1
	BRA.S	.s
.new:	CMP.W	#RTG_BANKS,D1
	BHS.S	.full
	MOVE.W	D1,D2			; new bank must stay below spr color pool
	LSL.W	#3,D2
	ADDQ.W	#7,D2
	CMP.W	rtg_SprNext,D2
	BLS.S	.add
.full:	BSR.W	pt_RtgPoolReset		; full: restart, redraw all
	X20LEA	X20_RTGBANKS,A0
	MOVEQ	#0,D1
.add:	LEA	rtg_Colors,A1
	MOVEQ	#7,D2
.a:	MOVE.W	(A1)+,(A0)+
	DBF	D2,.a
	ADDQ.W	#1,rtg_NumBanks
	ST	rtg_PalDirty
.got:	MOVEM.L	(A7)+,D0/D2-D3/A0-A1
	RTS

; reset color pools (banks from 0, spr colors from 255 down), redraw all
pt_RtgPoolReset:
	MOVEM.L	D0/A0,-(A7)
	CLR.W	rtg_NumBanks
	MOVE.W	#255,rtg_SprNext
	X20LEA	X20_RTGCOLMAP,A0
	MOVE.W	#4096/4-1,D0
.c:	CLR.L	(A0)+
	DBF	D0,.c
	ST	rtg_PalDirty
	BSR.W	pt_RtgInvalidate
	MOVEM.L	(A7)+,D0/A0
	RTS

; spr segs: SPRxPT from cop (MOVE $120-$13E), chain POS/CTL/data to 0/0
; 16 px wide, fmode 0 -> rtg_Segs (spr, vstart, vstop, hstart, data)
pt_RtgSprBuild:
	MOVEM.L	D0-D7/A0-A2,-(A7)
	LEA	rtg_SprPt,A0
	MOVEQ	#7,D0
.cl:	CLR.L	(A0)+
	DBF	D0,.cl
	MOVEA.L	rtg_LineBuf,A1
	LEA	RTG_COPCOPY(A1),A1	; copy made by pt_RtgFrame
	MOVE.W	#RTG_COPMAX,D7
.sc:	SUBQ.W	#1,D7
	BMI.S	.scd
	MOVE.L	(A1)+,D1
	MOVE.L	D1,D0
	SWAP	D0
	BTST	#0,D0
	BNE.S	.scw
	AND.W	#$01fe,D0
	CMP.W	#$0120,D0
	BLO.S	.sc
	CMP.W	#$013e,D0
	BHI.S	.sc
	SUB.W	#$0120,D0
	LEA	rtg_SprPt,A0
	MOVE.W	D1,(A0,D0.W)
	BRA.S	.sc
.scw:	CMP.W	#$ffff,D0
	BNE.S	.sc
	CMP.W	#$fffe,D1
	BNE.S	.sc
.scd:	X20LEA	X20_RTGSEGS,A2
	MOVEQ	#0,D6			; segs
	MOVEQ	#0,D5			; Sprite
.sp:	LEA	rtg_SprPt,A0
	MOVE.W	D5,D0
	LSL.W	#2,D0
	MOVE.L	(A0,D0.W),D0
	BEQ.W	.spn
	BTST	#0,D0
	BNE.W	.spn
	CMP.L	#$00200000,D0		; chip ram only
	BHS.W	.spn
	MOVEA.L	D0,A1
	MOVEQ	#7,D4			; max 8 segs per spr
	MOVEQ	#$19,D7			; spr dma starts at line 25
.sg:	MOVE.W	(A1)+,D0		; POS
	MOVE.W	(A1)+,D1		; CTL
	MOVE.W	D0,D2
	OR.W	D1,D2
	BEQ.W	.spn
	MOVE.W	D0,D2
	LSR.W	#8,D2			; VSTART
	BTST	#2,D1
	BEQ.S	.v1
	BSET	#8,D2
.v1:	MOVE.W	D1,D3
	LSR.W	#8,D3			; VSTOP
	BTST	#1,D1
	BEQ.S	.v2
	BSET	#8,D3
.v2:	CMP.W	D2,D3
	BLS.W	.spn
	CMP.W	D7,D2			; vstart compares for equality: passed -> spr stays off
	BLO.W	.spn
	CMP.W	#$138,D2
	BHI.W	.spn
	MOVE.W	D3,D7
	ADDQ.W	#1,D7			; next POS/CTL fetched in line after vstop
	CMP.W	#RTG_SEGS,D6
	BHS.W	.done
	MOVE.W	D5,(A2)+
	MOVE.W	D2,(A2)+
	MOVE.W	D3,(A2)+
	AND.W	#$ff,D0
	ADD.W	D0,D0
	BTST	#0,D1
	BEQ.S	.h
	ADDQ.W	#1,D0
.h:	MOVE.W	D0,(A2)+		; hstart (lores clk)
	MOVE.L	A1,(A2)+
	ADDQ.W	#1,D6
	SUB.W	D2,D3
	EXT.L	D3
	LSL.L	#2,D3
	ADDA.L	D3,A1
	DBF	D4,.sg
.spn:	ADDQ.W	#1,D5
	CMP.W	#8,D5
	BLO.W	.sp
.done:	TST.B	vu8_Cop
	BEQ.S	.dn
	BSR.S	pt_RtgVuSegs
.dn:	MOVE.W	D6,rtg_NumSegs
	MOVEM.L	(A7)+,D0-D7/A0-A2
	RTS

; vu spr 4-7: 2nd bar seg 72 clk right of the first, data from vu8_Bar2
pt_RtgVuSegs:
	MOVEM.L	D0-D4/A0-A1,-(A7)
	X20LEA	X20_RTGSEGS,A0
	MOVE.W	D6,D4
	BRA.S	.e
.l:	MOVE.W	(A0),D0
	SUBQ.W	#4,D0
	CMP.W	#3,D0
	BHI.S	.n
	CMP.W	#RTG_SEGS,D6
	BHS.S	.n
	MOVE.W	(A0),(A2)+
	MOVE.W	2(A0),(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	6(A0),D1
	ADD.W	#2*VU8_DX,D1
	MOVE.W	D1,(A2)+
	MULU	#192,D0
	LEA	vu8_Bar2,A1
	ADDA.L	D0,A1
	MOVE.L	A1,(A2)+
	ADDQ.W	#1,D6
.n:	LEA	12(A0),A0
.e:	DBF	D4,.l
	MOVEM.L	(A7)+,D0-D4/A0-A1
	RTS

; spr part of row sig: row d7, sig d6
pt_RtgSprSig:
	MOVEM.L	D0-D3/A0-A1,-(A7)
	MOVE.W	D7,D2
	ADD.W	rtg_VStart,D2		; Rasterzeile
	X20LEA	X20_RTGSEGS,A0
	MOVE.W	rtg_NumSegs,D3
	BRA.S	.e
.l:	CMP.W	2(A0),D2
	BLO.S	.n
	CMP.W	4(A0),D2
	BHS.S	.n
	MOVE.W	D2,D0
	SUB.W	2(A0),D0
	LSL.W	#2,D0
	MOVEA.L	8(A0),A1
	ROL.L	#3,D6
	ADD.L	(A1,D0.W),D6		; data a/b
	ROL.L	#3,D6
	ADD.W	6(A0),D6		; Position
	MOVE.W	(A0),D0
	LSR.W	#1,D0
	LSL.W	#3,D0			; pair * 4 colors * 2 bytes
	LEA	rtg_Colors+32,A1
	ROL.L	#1,D6
	ADD.L	2(A1,D0.W),D6		; colors 1, 2
	ROL.L	#1,D6
	ADD.W	6(A1,D0.W),D6		; color 3
.n:	LEA	12(A0),A0
.e:	DBF	D3,.l
	MOVEM.L	(A7)+,D0-D3/A0-A1
	RTS

; spr into rtg_LineBuf row d7: spr 7 first, spr 0 on top, behind planes
; (BPLCON2 $0024); px = 2 hires px, x = (HSTART-DIWSTRT-H)*2, COLOR16-31
pt_RtgSprites:
	MOVEM.L	D0-D6/A0-A3,-(A7)
	MOVE.W	D7,D2
	ADD.W	rtg_VStart,D2
	MOVE.W	rtg_NumSegs,D3
	BEQ.W	.r
	X20LEA	X20_RTGSEGS,A0
	MOVE.W	D3,D0
	MULU	#12,D0
	ADDA.L	D0,A0
.l:	LEA	-12(A0),A0
	TST.B	rtg_RunWin		; win: wb has own ptr, skip pt mouse spr (0)
	BEQ.S	.spr
	TST.W	(A0)
	BEQ.W	.n
.spr:	CMP.W	2(A0),D2
	BLO.W	.n
	CMP.W	4(A0),D2
	BHS.W	.n
	MOVE.W	D2,D0
	SUB.W	2(A0),D0
	LSL.W	#2,D0
	MOVEA.L	8(A0),A1
	MOVE.L	(A1,D0.W),D4		; a word (top), b word (bottom)
	BEQ.W	.n
	LEA	rtg_SprIdx,A2
	MOVE.W	(A0),D0
	LSR.W	#1,D0
	LSL.W	#3,D0
	LEA	rtg_Colors+32,A1
	ADDA.W	D0,A1
	MOVE.W	2(A1),D1
	BSR.W	pt_RtgSprCol
	MOVE.B	D1,1(A2)
	MOVE.W	4(A1),D1
	BSR.W	pt_RtgSprCol
	MOVE.B	D1,2(A2)
	MOVE.W	6(A1),D1
	BSR.W	pt_RtgSprCol
	MOVE.B	D1,3(A2)
	MOVE.W	6(A0),D5
	SUB.W	rtg_DiwH,D5
	ADD.W	D5,D5			; hires x
	MOVEA.L	rtg_LineBuf,A3
	MOVEQ	#15,D6
.px:	MOVEQ	#0,D0
	MOVE.W	D6,D1
	ADD.W	#16,D1
	BTST	D1,D4
	BEQ.S	.na
	MOVEQ	#1,D0
.na:	BTST	D6,D4
	BEQ.S	.nb
	ADDQ.W	#2,D0
.nb:	TST.W	D0
	BEQ.S	.sk
	MOVE.B	(A2,D0.W),D0
	CMP.W	#639,D5
	BHI.S	.sk			; also off left (negative)
	MOVE.B	D0,(A3,D5.W)
	CMP.W	#638,D5
	BHI.S	.sk
	MOVE.B	D0,1(A3,D5.W)
.sk:	ADDQ.W	#2,D5
	DBF	D6,.px
.n:	SUBQ.W	#1,D3
	BNE.W	.l
.r:	MOVEM.L	(A7)+,D0-D6/A0-A3
	RTS

; spr color d1=$0RGB -> clut idx from pool 255 down, d1=idx
pt_RtgSprCol:
	MOVEM.L	D0/D2/A0,-(A7)
	AND.W	#$0fff,D1
	X20LEA	X20_RTGCOLMAP,A0
	MOVEQ	#0,D0
	MOVE.B	(A0,D1.W),D0
	BNE.S	.got
	MOVE.W	rtg_SprNext,D0
	MOVE.W	rtg_NumBanks,D2
	LSL.W	#3,D2			; first free idx above banks
	CMP.W	D2,D0
	BHS.S	.new
	BSR.W	pt_RtgPoolReset		; full: restart (row redrawn next frame)
	X20LEA	X20_RTGCOLMAP,A0
	MOVE.W	rtg_SprNext,D0
.new:	MOVE.B	D0,(A0,D1.W)
	SUBQ.W	#1,rtg_SprNext
	X20LEA	X20_RTGSPRRGB,A0
	ADD.W	D0,D0
	MOVE.W	D1,(A0,D0.W)
	LSR.W	#1,D0
	ST	rtg_PalDirty
.got:	MOVE.W	D0,D1
	MOVEM.L	(A7)+,D0/D2/A0
	RTS

; load clut if colors changed (LoadRGB32: banks from 0, spr colors to 255)
pt_RtgPalette:
	TST.B	rtg_PalDirty
	BEQ.W	.r
	SF	rtg_PalDirty
	TST.B	rtg_RunWin		; win: color table built by pt_RtgWinRow (pt_RtgCTab)
	BNE.W	.r
	MOVEM.L	D0-D3/A0-A2/A6,-(A7)
	LEA	rtg_PalTab,A0
	MOVE.W	rtg_NumBanks,D0
	LSL.W	#3,D0			; color cnt
	BEQ.S	.spr			; cnt 0 would end table
	MOVE.W	D0,(A0)+
	CLR.W	(A0)+			; first idx 0
	X20LEA	X20_RTGBANKS,A1
	SUBQ.W	#1,D0
.c:	MOVE.W	(A1)+,D1
	BSR.S	.rgb
	DBF	D0,.c
.spr:	MOVE.W	#255,D0
	SUB.W	rtg_SprNext,D0		; spr colors SprNext+1 .. 255
	BEQ.S	.end
	MOVE.W	D0,(A0)+
	MOVE.W	rtg_SprNext,D1
	ADDQ.W	#1,D1
	MOVE.W	D1,(A0)+
	X20LEA	X20_RTGSPRRGB,A1
	ADD.W	D1,D1
	ADDA.W	D1,A1
	SUBQ.W	#1,D0
.s:	MOVE.W	(A1)+,D1
	BSR.S	.rgb
	DBF	D0,.s
.end:	CLR.L	(A0)
	MOVEA.L	rtg_Screen,A0
	LEA	44(A0),A0		; ViewPort
	LEA	rtg_PalTab,A1
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-882,A6)		; LoadRGB32
	MOVEM.L	(A7)+,D0-D3/A0-A2/A6
.r:	RTS
.rgb:	; .rgb: ; d1 = $0RGB -> 3 longs, nibble repeated
	MOVE.W	D1,D2
	LSR.W	#8,D2
	BSR.S	.gun
	MOVE.W	D1,D2
	LSR.W	#4,D2
	BSR.S	.gun
	MOVE.W	D1,D2
.gun:	AND.L	#$f,D2
	MOVE.L	D2,D3
	LSL.L	#4,D3
	OR.L	D3,D2
	MOVE.L	D2,D3
	LSL.L	#8,D3
	OR.L	D3,D2
	MOVE.L	D2,D3
	SWAP	D3
	OR.L	D3,D2			; $nnnnnnnn
	MOVE.L	D2,(A0)+
	RTS

;--- window
; wb window on pubscreen, nearest-neighbour scaled, cgx WritePixelArray
; input: pt_RtgInWrap before pt handler, keys only if win active,
; mouse pos from win (fake RAWMOUSE); buttons: pt_LMB41/RMB41
; wb ptr stays visible, pt mouse ptr not drawn in win
pt_RtgWinSetup:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.B	#10,rtg_Step		; step 10 cgx, 11 buf, 12 wb, 13 card, 14 win
	LEA	rtg_CgxName(PC),A1
	MOVEQ	#40,D0
	JSR	(-552,A6)		; OpenLibrary("cybergraphics.library", 40)
	MOVE.L	D0,rtg_CgxBase
	BEQ.W	.fail
	MOVE.B	#11,rtg_Step
	MOVE.L	#RTG_WINBUF,D0
	MOVEQ	#1,D1			; MEMF_PUBLIC
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,rtg_XMap
	BEQ.W	.fail
	ADD.L	#4096*2,D0
	MOVE.L	D0,rtg_ScaleBuf
	MOVE.B	#12,rtg_Step
	MOVEA.L	dat_IntuiLibBase,A6
	SUBA.L	A0,A0
	JSR	(-510,A6)		; LockPubScreen(NULL)
	MOVE.L	D0,D7
	BEQ.W	.fail
	MOVE.B	#13,rtg_Step
	MOVEA.L	D0,A0
	LEA	44(A0),A0		; Screen->ViewPort
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-792,A6)		; GetVPModeID: card modes >= $00100000
	MOVEA.L	dat_IntuiLibBase,A6	; P96 CYBRMATTR_ISCYBERGFX unreliable
	CMP.L	#$00100000,D0
	BCS.S	.unl
	MOVE.B	#14,rtg_Step
	LEA	rtg_PubTags,A1
	MOVE.L	D7,4(A1)		; WA_PubScreen
	SUBA.L	A0,A0
	JSR	(-606,A6)		; OpenWindowTagList
	MOVE.L	D0,rtg_Window
.unl:	SUBA.L	A0,A0
	MOVEA.L	D7,A1
	JSR	(-516,A6)		; UnlockPubScreen(NULL, Screen)
	MOVE.L	rtg_Window,D0
	BEQ.S	.fail
	CLR.L	rtg_WinW		; size computed in first frame (pt_RtgWinGeom)
	MOVE.L	dat_ScreenPtr,D0	; pt screen to back, wb to front
	BEQ.S	.nb
	MOVEA.L	D0,A0
	JSR	(-246,A6)		; ScreenToBack
.nb:	MOVEA.L	rtg_Window,A0
	MOVEA.L	46(A0),A0		; Window->WScreen
	JSR	(-252,A6)		; ScreenToFront
	MOVEA.L	rtg_Window,A0
	JSR	(-450,A6)		; ActivateWindow, WA_Activate alone fails after scr switch
	MOVE.B	#1,rtg_InBlock
	BSR.W	pt_RtgInHook
	MOVEQ	#0,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS
.fail:	MOVE.B	rtg_Step,rtg_WinFail
	MOVEQ	#-1,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS

; check inner area, changed -> rebuild x table, redraw all
pt_RtgWinGeom:
	MOVEM.L	D0-D5/A0-A1,-(A7)
	MOVEA.L	rtg_Window,A0
	MOVEQ	#0,D1
	MOVE.W	8(A0),D0		; Width
	MOVE.B	54(A0),D1		; BorderLeft
	SUB.W	D1,D0
	MOVE.B	56(A0),D1		; BorderRight
	SUB.W	D1,D0
	MOVE.W	10(A0),D2		; Height
	MOVE.B	55(A0),D1		; BorderTop
	SUB.W	D1,D2
	MOVE.B	57(A0),D1		; BorderBottom
	SUB.W	D1,D2
	CMP.W	#1,D0
	BGE.S	.w1
	MOVEQ	#1,D0
.w1:	CMP.W	#4096,D0
	BLE.S	.w2
	MOVE.W	#4096,D0
.w2:	CMP.W	#1,D2
	BGE.S	.h1
	MOVEQ	#1,D2
.h1:	CMP.W	rtg_WinW,D0
	BNE.S	.chg
	CMP.W	rtg_WinH,D2
	BEQ.S	.r
.chg:	MOVE.W	D0,rtg_WinW
	MOVE.W	D2,rtg_WinH
	MOVEA.L	rtg_XMap,A1
	MOVEQ	#0,D3
.x:	MOVE.L	D3,D5
	MULU	#640,D5
	DIVU	D0,D5			; src x = dst x * 640 / width
	MOVE.W	D5,(A1)+
	ADDQ.W	#1,D3
	CMP.W	D0,D3
	BLO.S	.x
	BSR.W	pt_RtgBufAlloc		; new size: new lut buffer
	BSR.W	pt_RtgInvalidate
.r:	MOVEM.L	(A7)+,D0-D5/A0-A1
	RTS

; row d7 (640 px) scaled to win rows d7*H/256..(d7+1)*H/256-1
pt_RtgWinRow:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.B	rtg_PalDirty		; new colors (bank/spr) before writing table
	BEQ.S	.pal
	BSR.W	pt_RtgCTab
	ST	rtg_BlitAll		; lut buffer: all pixels change color
.pal:	MOVEQ	#0,D0
	MOVE.W	D7,D0
	MULU	rtg_WinH,D0
	LSR.L	#8,D0			; first dst row
	MOVEQ	#0,D6
	MOVE.W	D7,D6
	ADDQ.W	#1,D6
	MULU	rtg_WinH,D6
	LSR.L	#8,D6
	SUB.L	D0,D6			; dst row cnt (0 when shrunk)
	BEQ.W	.r
	MOVE.L	D0,D4
	TST.L	rtg_LutBuf
	BNE.W	.lut
	MOVEA.L	rtg_LineBuf,A0		; scale horizontally, color lookup -> rgb (3 bytes/px)
	MOVEA.L	rtg_ScaleBuf,A1
	MOVEA.L	rtg_XMap,A2
	LEA	rtg_CTab,A4
	MOVE.W	rtg_WinW,D2
	SUBQ.W	#1,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D1
.s:	MOVE.W	(A2)+,D3
	MOVE.B	(A0,D3.L),D1
	MOVE.W	D1,D0
	LSL.W	#2,D0
	MOVE.L	(A4,D0.W),D5		; $00RRGGBB
	SWAP	D5
	MOVE.B	D5,(A1)+		; R
	ROL.L	#8,D5
	MOVE.B	D5,(A1)+		; G
	ROL.L	#8,D5
	MOVE.B	D5,(A1)+		; B
	DBF	D2,.s
	SUBQ.W	#1,D6
	MOVEA.L	rtg_Window,A3
	MOVEQ	#0,D0
	MOVE.B	55(A3),D0		; BorderTop
	ADD.L	D0,D4
	MOVEA.L	124(A3),A5		; Window->WLayer
	BSR.W	pt_RtgPriUp
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-654,A6)		; AttemptLockLayerRom: never wait on a layer intuition holds (drag/size)
	TST.L	D0
	BNE.S	.y
	BSR.W	pt_RtgPriDown
	BSR.W	pt_RtgInvalidate	; busy -> skip, whole window again next frame
	BRA.W	.r
.y:	MOVEM.L	D4/D6,-(A7)
	MOVEA.L	rtg_ScaleBuf,A0		; srcRect
	MOVEQ	#0,D0			; SrcX
	MOVEQ	#0,D1			; SrcY
	MOVEQ	#0,D2
	MOVE.W	rtg_WinW,D2
	MULU	#3,D2			; SrcMod (bytes/row)
	MOVEA.L	50(A3),A1		; Window->RPort
	MOVEQ	#0,D3
	MOVE.B	54(A3),D3		; DestX = BorderLeft
	MOVEQ	#0,D5
	MOVE.W	rtg_WinW,D5		; SizeX
	MOVEQ	#1,D6			; SizeY
	MOVEQ	#0,D7			; RECTFMT_RGB
	MOVEA.L	rtg_CgxBase,A6
	JSR	(-126,A6)		; WritePixelArray (cybergraphics V40)
	MOVEM.L	(A7)+,D4/D6
	ADDQ.L	#1,D4
	DBF	D6,.y
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-438,A6)		; UnlockLayerRom (a5 = layer)
	BSR.W	pt_RtgPriDown
	ADDQ.L	#1,rtg_Lines
	BRA.S	.r
.lut:	SUBQ.W	#1,D6			; lut buffer: scale into ram, one write per frame
	CMP.W	rtg_DirtyY0,D4
	BGE.S	.l0
	MOVE.W	D4,rtg_DirtyY0
.l0:	MOVE.W	D4,D0
	ADD.W	D6,D0
	CMP.W	rtg_DirtyY1,D0
	BLE.S	.l1
	MOVE.W	D0,rtg_DirtyY1
.l1:	MOVEQ	#0,D5
	MOVE.W	rtg_WinW,D5		; bytes per row
	MOVE.L	D4,D0
	MULU	D5,D0
	MOVEA.L	rtg_LutBuf,A1
	ADDA.L	D0,A1
	MOVEA.L	A1,A3			; first dst row
	MOVEA.L	rtg_LineBuf,A0
	MOVEA.L	rtg_XMap,A2
	MOVE.W	D5,D2
	SUBQ.W	#1,D2
	MOVEQ	#0,D3
.lx:	MOVE.W	(A2)+,D3
	MOVE.B	(A0,D3.L),(A1)+
	DBF	D2,.lx
	BRA.S	.lc
.lr:	MOVEA.L	A3,A0			; more dst rows: copy the first
	MOVE.W	D5,D2
	LSR.W	#2,D2
	BRA.S	.ll
.lm:	MOVE.L	(A0)+,(A1)+
.ll:	DBF	D2,.lm
	MOVE.W	D5,D2
	AND.W	#3,D2
	BRA.S	.lb
.lbm:	MOVE.B	(A0)+,(A1)+
.lb:	DBF	D2,.lbm
.lc:	DBF	D6,.lr
	ADDQ.L	#1,rtg_Lines
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; lut buffer -> window, one WriteLUTPixelArray per frame; busy: keep band
pt_RtgWinBlit:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	TST.L	rtg_LutBuf
	BEQ.W	.r
	MOVE.W	rtg_DirtyY0,D1
	MOVE.W	rtg_DirtyY1,D6
	TST.B	rtg_BlitAll
	BEQ.S	.b
	MOVEQ	#0,D1
	MOVE.W	rtg_WinH,D6
	SUBQ.W	#1,D6
.b:	CMP.W	D1,D6
	BLT.W	.r
	MOVEA.L	rtg_Window,A3
	MOVEA.L	124(A3),A5		; Window->WLayer
	BSR.W	pt_RtgPriUp
	MOVEA.L	dat_GfxLibBase,A6
	MOVE.L	D1,-(A7)
	JSR	(-654,A6)		; AttemptLockLayerRom
	MOVE.L	(A7)+,D1
	TST.L	D0
	BEQ.S	.nl			; intuition busy: next frame
	EXT.L	D1			; SrcY = y0
	SUB.W	D1,D6
	ADDQ.W	#1,D6
	EXT.L	D6			; SizeY
	MOVEA.L	rtg_LutBuf,A0
	MOVEQ	#0,D0			; SrcX
	MOVEQ	#0,D2
	MOVE.W	rtg_WinW,D2		; SrcMod
	MOVEA.L	50(A3),A1		; Window->RPort
	LEA	rtg_CTab,A2		; $00rrggbb
	MOVEQ	#0,D3
	MOVE.B	54(A3),D3		; DestX = BorderLeft
	MOVEQ	#0,D4
	MOVE.B	55(A3),D4
	ADD.L	D1,D4			; DestY = BorderTop + y0
	MOVE.L	D2,D5			; SizeX
	MOVEQ	#0,D7			; CTABFMT_XRGB8
	MOVEA.L	rtg_CgxBase,A6
	JSR	(-198,A6)		; WriteLUTPixelArray
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-438,A6)		; UnlockLayerRom
	SF	rtg_BlitAll
	MOVE.W	#$7fff,rtg_DirtyY0
	CLR.W	rtg_DirtyY1
.nl:	BSR.W	pt_RtgPriDown
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; layer lock held: just below input.device, which drags the window
; and may wait for it; at pri 0 every busy task would preempt the
; holder and the gui stands still
pt_RtgPriUp:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	276(A6),A1		; ThisTask
	MOVEQ	#19,D0
	JSR	(-300,A6)		; SetTaskPri
	MOVE.B	D0,rtg_PriOld
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS
pt_RtgPriDown:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	276(A6),A1
	MOVE.B	rtg_PriOld,D0
	EXT.W	D0
	EXT.L	D0
	JSR	(-300,A6)		; SetTaskPri
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

; (re)alloc lut buffer rtg_WinW x rtg_WinH (cgx 41+), else direct rows
pt_RtgBufAlloc:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	BSR.S	pt_RtgBufFree
	MOVEA.L	rtg_CgxBase,A0
	CMPI.W	#41,20(A0)		; lib_Version: WriteLUTPixelArray
	BLO.S	.r
	MOVEQ	#0,D0
	MOVE.W	rtg_WinW,D0
	MULU	rtg_WinH,D0
	MOVE.L	D0,rtg_LutSize
	MOVE.L	#$10001,D1		; MEMF_PUBLIC|MEMF_CLEAR: rows the copper skips stay black
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)		; AllocMem
	MOVE.L	D0,rtg_LutBuf
	BEQ.S	.r
	ST	rtg_BlitAll
.r:	MOVE.W	#$7fff,rtg_DirtyY0
	CLR.W	rtg_DirtyY1
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

pt_RtgBufFree:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	rtg_LutBuf,D0
	BEQ.S	.r
	MOVEA.L	D0,A1
	MOVE.L	rtg_LutSize,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)		; FreeMem
	CLR.L	rtg_LutBuf
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

; whole window again: lut buffer still holds it, else convert anew
pt_RtgWinRedraw:
	TST.L	rtg_LutBuf
	BEQ.W	pt_RtgInvalidate
	ST	rtg_BlitAll
	RTS

; color table: banks + spr colors (SprNext+1..255), $0RGB -> $00RRGGBB
pt_RtgCTab:
	MOVEM.L	D0-D2/A0-A1,-(A7)
	LEA	rtg_CTab,A0
	X20LEA	X20_RTGBANKS,A1
	MOVE.W	rtg_NumBanks,D0
	LSL.W	#3,D0
	SUBQ.W	#1,D0
	BMI.S	.spr
.b:	MOVE.W	(A1)+,D1
	BSR.S	.x
	MOVE.L	D1,(A0)+
	DBF	D0,.b
.spr:	MOVE.W	rtg_SprNext,D0
	ADDQ.W	#1,D0
.s:	CMP.W	#255,D0
	BHI.S	.r
	X20LEA	X20_RTGSPRRGB,A1
	MOVE.W	D0,D2
	ADD.W	D2,D2
	MOVE.W	(A1,D2.W),D1
	BSR.S	.x
	LEA	rtg_CTab,A0
	ADD.W	D2,D2
	MOVE.L	D1,(A0,D2.W)
	ADDQ.W	#1,D0
	BRA.S	.s
.r:	MOVEM.L	(A7)+,D0-D2/A0-A1
	RTS
.x:	MOVEM.L	D0/D2,-(A7)		; d1=$0RGB -> $00RRGGBB (nibble * 17)
	MOVE.W	D1,D2
	LSR.W	#8,D2
	AND.L	#15,D2
	MULU	#17,D2
	SWAP	D2			; R << 16
	MOVE.L	D2,D0
	MOVE.W	D1,D2
	LSR.W	#4,D2
	AND.L	#15,D2
	MULU	#17,D2
	LSL.L	#8,D2			; G << 8
	OR.L	D2,D0
	MOVE.W	D1,D2
	AND.L	#15,D2
	MULU	#17,D2			; B
	OR.L	D2,D0
	MOVE.L	D0,D1
	MOVEM.L	(A7)+,D0/D2
	RTS

; hook/unhook input wrap (is_Code of pt handler)
pt_RtgInHook:
	MOVE.L	dat_InputIntStruct+18,rtg_InOrig
	MOVE.L	#pt_RtgInWrap,dat_InputIntStruct+18
	RTS
pt_RtgInUnhook:
	CMPI.L	#pt_RtgInWrap,dat_InputIntStruct+18
	BNE.S	.r
	MOVE.L	rtg_InOrig,dat_InputIntStruct+18
.r:	RTS

; input wrap (input.device): a0=event chain a1=is_Data -> d0
; pt handler takes single events only -> pass one by one
pt_RtgInWrap:
	TST.B	rtg_RunWin
	BEQ.S	.orig
	TST.L	rtg_Window
	BNE.S	.win
.orig:	MOVE.L	rtg_InOrig,-(A7)
	RTS
.win:	MOVEM.L	D1-D7/A1-A6,-(A7)
	MOVEA.L	A1,A5			; is_Data
	MOVE.L	A0,D6			; head of new chain
	MOVEQ	#0,D4			; mouse move for pt
	MOVEQ	#0,D5
	MOVEQ	#1,D7			; blocked
	MOVEA.L	dat_IntuiLibBase,A6
	MOVEA.L	rtg_Window,A3
	CMPA.L	52(A6),A3		; IntuitionBase->ActiveWindow
	BNE.S	.blk
	MOVEQ	#0,D0
	MOVEA.L	46(A3),A0		; Window->WScreen: screen mouse pos
	MOVE.W	18(A0),D2		; Window->MouseX/Y stale after size gadget drag
	SUB.W	4(A3),D2		; - LeftEdge
	MOVE.B	54(A3),D0
	SUB.W	D0,D2			; - BorderLeft
	BMI.S	.blk
	CMP.W	rtg_WinW,D2
	BGE.S	.blk
	MOVE.W	16(A0),D3		; Screen->MouseY
	SUB.W	6(A3),D3		; - TopEdge
	MOVE.B	55(A3),D0
	SUB.W	D0,D3
	BMI.S	.blk
	CMP.W	rtg_WinH,D3
	BGE.S	.blk
	MOVEQ	#0,D7			; active and over image
	MULU	#640,D2
	DIVU	rtg_WinW,D2		; dst x 0..639
	MULU	#512,D3
	DIVU	rtg_WinH,D3		; dst y raw 0..511 (rows * 2)
	MOVE.W	D2,D4
	SUB.W	dat_ChannelMaskTmp,D4
	MOVE.W	D3,D5
	SUB.W	dat_ButtonRepeat,D5
.blk:	MOVE.B	D7,rtg_InBlock
	SUBA.L	A2,A2			; prev
	MOVEA.L	D6,A4			; current event
.l:	MOVE.L	A4,D0
	BEQ.S	.done
	MOVE.L	(A4),D3			; next
	TST.B	D7
	BNE.S	.keep
	CMPI.B	#1,4(A4)		; IECLASS_RAWKEY -> single to pt
	BNE.S	.keep
	CLR.L	(A4)
	MOVEA.L	A4,A0
	BSR.S	.call
	MOVE.L	D3,(A4)
	TST.L	D0
	BNE.S	.keep			; passed on (e.g. system requester open)
	MOVE.L	A2,D0			; consumed: unlink
	BEQ.S	.head
	MOVE.L	D3,(A2)
	BRA.S	.nx
.head:	MOVE.L	D3,D6
	BRA.S	.nx
.keep:	MOVEA.L	A4,A2
.nx:	MOVEA.L	D3,A4
	BRA.S	.l
.done:	TST.B	D7			; mouse pos from win to pt
	BNE.S	.ret
	MOVE.W	D4,D0
	OR.W	D5,D0
	BEQ.S	.ret
	LEA	rtg_Synth,A0
	CLR.L	(A0)
	MOVE.W	#$0200,4(A0)		; IECLASS_RAWMOUSE, subclass 0
	MOVE.W	#$00ff,6(A0)		; IECODE_NOBUTTON
	CLR.W	8(A0)
	MOVE.W	D4,10(A0)
	MOVE.W	D5,12(A0)
	BSR.S	.call
.ret:	MOVE.L	D6,D0
	MOVEM.L	(A7)+,D1-D7/A1-A6
	RTS
.call:	MOVEM.L	D1-D7/A1-A6,-(A7)	; a0 = single event
	MOVEA.L	A5,A1
	MOVEA.L	rtg_InOrig,A6
	JSR	(A6)
	MOVEM.L	(A7)+,D1-D7/A1-A6
	RTS

; main loop: wb window -> wait for vbl, leave the cpu to the system
pt_MainYield41:
	BSR.S	pt_BreakQuit41
	TST.B	rtg_RunWin
	BEQ.S	.go
	TST.L	rtg_Window
	BEQ.S	.go
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	IFD	DIAGWIN
	ADDQ.L	#1,dw_Main
	BSR.W	dw_Start
	ENDC
	MOVEA.L	dat_GfxLibBase,A6
	JSR	(-270,A6)		; WaitTOF
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
.go:	JMP	pt_ScreenDragUpdate

; ctrl-c on pt: quit like EXIT, without asking
pt_BreakQuit41:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#0,D0
	MOVE.L	#$1000,D1
	JSR	(-306,A6)		; SetSignal: take ctrl-c
	BTST	#12,D0
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	BNE.S	.q
	RTS
.q:
	IFD	DEBUGAUTO
	JSR	dbg_AutoQuit
	ENDC
	JMP	pt_SyncAndStop

; scr gadget (dat_03FB): win mode -> window to back only, d0=-1
; (= "no screen", pt_ScreenStateHandler does nothing)
; else original: TST.L dat_ScreenPtr for the BEQ.S after
pt_ScrBack41:
	TST.B	rtg_RunWin
	BEQ.S	.orig
	TST.L	rtg_Window
	BEQ.S	.orig
	MOVEM.L	D1/A0-A1/A6,-(A7)
	MOVEA.L	dat_IntuiLibBase,A6
	MOVEA.L	rtg_Window,A0
	JSR	(-306,A6)		; WindowToBack
	ADDQ.B	#1,rtg_BackCnt
	MOVEM.L	(A7)+,D1/A0-A1/A6
	ADDQ.L	#4,A7			; drop return to dat_03FB
	MOVEQ	#-1,D0			; to pt_ScreenStateHandler: Z=0 -> nothing
	RTS
.orig:	TST.L	dat_ScreenPtr
	RTS

; ch cnt at start (replaces JSR pt_ClearScreenBuf2 in pt_Init)
; prefs byte +15 (4/8) first, else 8ch if mixer copes (68020+/fast 68000,
; not a500 mode) unless PROGDIR:PT.4ch exists; then pt_ClearScreenBuf2
pt_ChanDefault41:
	MOVEM.L	D0-D2/A0-A1/A6,-(A7)
	MOVE.B	prf_Chan,D0
	CMP.B	#8,D0
	BEQ.S	.ch8
	CMP.B	#4,D0
	BEQ.S	.ch4
	TST.B	mix_Enabled
	BEQ.S	.r
	TST.B	mix68_Slow
	BNE.S	.r
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#.n4ch,D1
	MOVEQ	#-2,D2
	JSR	(-84,A6)		; Lock("PROGDIR:PT.4ch")
	MOVE.L	D0,D1
	BEQ.S	.ch8
	JSR	(-90,A6)		; UnLock
	BRA.S	.r
.ch4:	BSET	#5,dat_ModeFlags
	BRA.S	.r
.ch8:	BCLR	#5,dat_ModeFlags
.r:	MOVEM.L	(A7)+,D0-D2/A0-A1/A6
	JMP	pt_ClearScreenBuf2
.n4ch:	DC.B	"PROGDIR:PT.4ch",0
	EVEN

; req cnt down (return of intui patch pt_SetVectorAud0), never below 0
; orig SUBQ unchecked: FreeSysRequest w/o counted BuildSysRequest went
; negative -> input handler passed everything through
pt_ReqDec41:
	TST.B	dat_VBlankCounter
	BEQ.S	.r
	SUBQ.B	#1,dat_VBlankCounter
	BNE.S	.r
	JMP	pt_SetupCopper		; last req closed: restore display
.r:	RTS

; LMB/RMB macro test: win mode only if win active and ptr over image,
; else "up" (Z=0); otherwise hw btst
pt_LMB41:
	TST.B	rtg_InBlock
	BNE.S	pt_BtnUp41
	BTST	#6,CIAA_PRA
	RTS
pt_RMB41:
	TST.B	rtg_InBlock
	BNE.S	pt_BtnUp41
	BTST	#2,POTGOR
	RTS
pt_BtnUp41:
	ANDI	#$fb,CCR
	RTS

rtg_PubTags:	DC.L	WA_PubScreen_,0
		DC.L	WA_Title_,rtg_WinTitle
		DC.L	WA_InnerWidth_,640
		DC.L	WA_InnerHeight_,512
		DC.L	WA_MinWidth_,180
		DC.L	WA_MinHeight_,90
		DC.L	WA_MaxWidth_,-1
		DC.L	WA_MaxHeight_,-1
		DC.L	WA_DragBar_,1
		DC.L	WA_DepthGadget_,1
		DC.L	WA_SizeGadget_,1
		DC.L	WA_SizeBBottom_,1
		DC.L	WA_SmartRefresh_,1
		DC.L	WA_NoCareRefresh_,1
		DC.L	WA_AutoAdjust_,1
		DC.L	WA_Activate_,1
		DC.L	WA_RMBTrap_,1
		DC.L	0,0
rtg_CgxName:	DC.B	"cybergraphics.library",0
rtg_WinTitle:	DC.B	"ProTracker 4.1.1",0
	CNOP	0,2

rtg_ScrTags:	DC.L	SA_DisplayID_,0
		DC.L	SA_Width_,640
		DC.L	SA_Height_,512
		DC.L	SA_Depth_,8
		DC.L	SA_Quiet_,1
		DC.L	SA_ShowTitle_,0
		DC.L	SA_Type_,$000f		; CUSTOMSCREEN
		DC.L	SA_Title_,rtg_ProcName
		DC.L	0,0
rtg_WinTags:	DC.L	WA_CustomScreen_,0
		DC.L	WA_Left_,0
		DC.L	WA_Top_,0
		DC.L	WA_Width_,640
		DC.L	WA_Height_,512
		DC.L	WA_Backdrop_,1
		DC.L	WA_Borderless_,1
		DC.L	WA_Activate_,1
		DC.L	WA_RMBTrap_,1
		DC.L	WA_SimpleRefresh_,1
		DC.L	WA_NoCareRefresh_,1
		DC.L	0,0
rtg_ProcTags:	DC.L	$800003eb,pt_RtgProc	; NP_Entry
		DC.L	$800003f4,rtg_ProcName	; NP_Name
		DC.L	$800003f5,1		; NP_Priority 1, above pt (pt busy waits)
		DC.L	$800003f3,8192		; NP_StackSize
		DC.L	0,0
rtg_ProcName:	DC.B	"PT4.1 RTG",0
rtg_FileName:	DC.B	"PROGDIR:PT.rtg",0
	CNOP	0,2
