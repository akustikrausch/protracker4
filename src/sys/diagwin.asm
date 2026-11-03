; window diag (-DDIAGWIN): proc pri 30, 5 lines/s to diagwin.log
; vbl server samples ThisTask -> who eats the cpu; owners of layer locks
	IFD	DIAGWIN

; main loop, window open: start once
dw_Start:
	TST.B	dw_Started
	BNE.S	.r
	ST	dw_Started
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-600,A6)		; GetProgramDir
	MOVE.L	D0,D1
	JSR	(-96,A6)		; DupLock
	MOVE.L	D0,dw_Tags+12		; NP_CurrentDir
	MOVE.L	#dw_Tags,D1
	JSR	(-498,A6)		; CreateNewProc
	MOVE.L	D0,dw_Proc
	MOVEM.L	(A7)+,D0-D7/A0-A6
.r:	RTS

; teardown: ctrl-c, wait for exit
dw_Stop:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	dw_Proc,D0
	BEQ.S	.r
	MOVEA.L	D0,A1
	MOVE.L	#$1000,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-324,A6)		; Signal
	MOVEA.L	dat_DosLibBase,A6
	MOVE.W	#200,D7
.w:	CMP.B	#3,dw_State
	BEQ.S	.g
	MOVEQ	#1,D1
	JSR	(-198,A6)		; Delay
	DBF	D7,.w
.g:	CLR.L	dw_Proc
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; vertb server: count frames, forbid frames, ThisTask histogram
dw_Server:
	MOVEA.L	ABSEXECBASE.W,A6
	ADDQ.L	#1,dw_Vbl
	ADDQ.L	#1,dw_VblTot
	TST.B	295(A6)			; TDNestCnt
	BMI.S	.nf
	ADDQ.L	#1,dw_Forb
.nf:	MOVE.L	276(A6),D0		; ThisTask
	LEA	dw_Hist,A0
	MOVEQ	#15,D1
.h:	CMP.L	(A0),D0
	BEQ.S	.inc
	TST.L	(A0)
	BEQ.S	.new
	ADDQ.L	#8,A0
	DBF	D1,.h
	BRA.S	.d
.new:	MOVE.L	D0,(A0)
.inc:	ADDQ.L	#1,4(A0)
.d:	MOVEQ	#0,D0
	RTS

dw_ProcEntry:
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dw_InName(PC),A1
	JSR	(-294,A6)		; FindTask("input.device")
	MOVE.L	D0,dw_InTask
	MOVEQ	#5,D0			; INTB_VERTB
	LEA	dw_Int,A1
	JSR	(-168,A6)		; AddIntServer
	MOVE.L	#1006,D2		; MODE_NEWFILE: header
	LEA	dw_Head(PC),A0
	BSR.W	dw_Put
	MOVE.L	280(A6),dw_LIdle
	MOVE.L	284(A6),dw_LDisp
.loop:	MOVEA.L	dat_DosLibBase,A6
	MOVEQ	#10,D1
	JSR	(-198,A6)		; Delay 1/5 s
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	JSR	(-306,A6)		; SetSignal
	BTST	#12,D0
	BNE.W	.down
	BSR.W	dw_Line
	BRA.S	.loop
.down:	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#5,D0
	LEA	dw_Int,A1
	JSR	(-174,A6)		; RemIntServer
	JSR	(-132,A6)		; Forbid
	MOVE.B	#3,dw_State
	MOVEQ	#0,D0
	RTS

; one log line
dw_Line:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	dw_Args,A2
	ADDQ.L	#1,dw_Sec
	MOVE.L	dw_Sec,(A2)+
	JSR	(-120,A6)		; Disable: take counters
	MOVE.L	dw_Vbl,(A2)+
	CLR.L	dw_Vbl
	MOVE.L	dw_Forb,D7
	CLR.L	dw_Forb
	MOVE.L	dw_TFr,D5		; vbls in frame build / card write
	CLR.L	dw_TFr
	MOVE.L	dw_TBl,D4
	CLR.L	dw_TBl
	LEA	dw_Hist,A0
	LEA	dw_HCopy,A1
	MOVEQ	#31,D0
.cp:	MOVE.L	(A0),(A1)+
	CLR.L	(A0)+
	DBF	D0,.cp
	JSR	(-126,A6)		; Enable
	MOVE.L	280(A6),D0		; IdleCount
	MOVE.L	D0,D1
	SUB.L	dw_LIdle,D0
	MOVE.L	D1,dw_LIdle
	MOVE.L	D0,(A2)+
	MOVE.L	284(A6),D0		; DispCount
	MOVE.L	D0,D1
	SUB.L	dw_LDisp,D0
	MOVE.L	D1,dw_LDisp
	MOVE.L	D0,(A2)+
	MOVE.L	D7,(A2)+		; forbid frames
	MOVE.L	dw_Main,D0
	MOVE.L	D0,D1
	SUB.L	dw_LMain,D0
	MOVE.L	D1,dw_LMain
	MOVE.L	D0,(A2)+
	MOVE.L	rtg_Frames,D0
	MOVE.L	D0,D1
	SUB.L	dw_LFr,D0
	MOVE.L	D1,dw_LFr
	MOVE.L	D0,(A2)+
	MOVE.L	rtg_Reads,D0		; lines read from chip
	MOVE.L	D0,D1
	SUB.L	dw_LRd,D0
	MOVE.L	D1,dw_LRd
	MOVE.L	D0,(A2)+
	MOVE.L	D5,(A2)+
	MOVE.L	D4,(A2)+
	MOVEQ	#0,D0
	MOVE.B	rtg_WinHeld,D0
	MOVE.L	D0,(A2)+
	MOVE.B	rtg_InBlock,D0
	MOVE.L	D0,(A2)+
	MOVEQ	#0,D0
	BTST	#6,CIAA_PRA
	SEQ	D0
	AND.L	#1,D0
	MOVE.L	D0,(A2)+		; lmb
	MOVEA.L	dat_IntuiLibBase,A0
	MOVEQ	#0,D0
	MOVE.L	52(A0),D1		; ActiveWindow
	CMP.L	rtg_Window,D1
	SEQ	D0
	AND.L	#1,D0
	MOVE.L	D0,(A2)+
	MOVE.W	70(A0),D0		; MouseX
	EXT.L	D0
	MOVE.L	D0,(A2)+
	MOVE.W	68(A0),D0		; MouseY
	EXT.L	D0
	MOVE.L	D0,(A2)+
	JSR	(-132,A6)		; Forbid: owners
	MOVE.L	rtg_Window,D0
	BEQ.S	.nw
	MOVEA.L	D0,A0
	MOVE.L	4(A0),(A2)+		; left/top
	MOVEA.L	124(A0),A0		; WLayer
	MOVE.L	112(A0),D0		; Lock.ss_Owner
	BSR.W	dw_Name
	MOVE.W	116(A0),D0		; Lock.ss_QueueCount
	EXT.L	D0
	MOVE.L	D0,(A2)+
	MOVEA.L	68(A0),A0		; LayerInfo
	MOVE.L	64(A0),D0		; Lock.ss_Owner
	BSR.W	dw_Name
	MOVE.W	68(A0),D0
	EXT.L	D0
	MOVE.L	D0,(A2)+
	BRA.S	.in
.nw:	CLR.L	(A2)+
	MOVE.L	#dw_Dash,(A2)+
	CLR.L	(A2)+
	MOVE.L	#dw_Dash,(A2)+
	CLR.L	(A2)+
.in:	MOVE.L	dw_InTask,D0
	BEQ.S	.ni
	MOVEA.L	D0,A0
	MOVEQ	#0,D0
	MOVE.B	15(A0),D0		; tc_State
	MOVE.L	D0,(A2)+
	MOVE.L	22(A0),(A2)+		; tc_SigWait
	BRA.S	.top
.ni:	CLR.L	(A2)+
	CLR.L	(A2)+
.top:	MOVEQ	#4,D6			; top 5 tasks
.t:	LEA	dw_HCopy,A0
	MOVEQ	#15,D1
	MOVEQ	#0,D2			; best cnt
	SUBA.L	A1,A1
.tl:	CMP.L	4(A0),D2
	BCC.S	.tn
	MOVE.L	4(A0),D2
	MOVEA.L	A0,A1
.tn:	ADDQ.L	#8,A0
	DBF	D1,.tl
	MOVE.L	A1,D0
	BEQ.S	.te
	MOVE.L	(A1),D0
	CLR.L	4(A1)
	BSR.W	dw_Name
	MOVE.L	D2,(A2)+
	DBF	D6,.t
	BRA.S	.tx
.te:	MOVE.L	#dw_Dash,(A2)+
	CLR.L	(A2)+
	DBF	D6,.te
.tx:	JSR	(-138,A6)		; Permit
	LEA	dw_Fmt(PC),A0
	LEA	dw_Args,A1
	LEA	dw_PutC(PC),A2
	LEA	dw_Buf,A3
	JSR	(-522,A6)		; RawDoFmt
	MOVE.L	#1005,D2		; MODE_OLDFILE, append
	LEA	dw_Buf,A0
	BSR.S	dw_Put
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

; d0 = task -> name ptr to (a2)+ ; keeps a0
dw_Name:
	TST.L	D0
	BEQ.S	.no
	MOVE.L	A0,-(A7)
	MOVEA.L	D0,A0
	MOVE.L	10(A0),D0		; ln_Name
	MOVEA.L	(A7)+,A0
	TST.L	D0
	BEQ.S	.no
	MOVE.L	D0,(A2)+
	RTS
.no:	MOVE.L	#dw_Dash,(A2)+
	RTS

dw_PutC:
	MOVE.B	D0,(A3)+
	RTS

; a0 = 0-term text, d2 = mode; open, seek end, write, close
dw_Put:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	A0,A4
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#dw_File,D1
	JSR	(-30,A6)		; Open
	MOVE.L	D0,D7
	BEQ.S	.r
	MOVE.L	D7,D1
	MOVEQ	#0,D2
	MOVEQ	#1,D3			; OFFSET_END
	JSR	(-66,A6)		; Seek
	MOVEA.L	A4,A0
	MOVEQ	#-1,D3
.l:	ADDQ.L	#1,D3
	TST.B	(A0)+
	BNE.S	.l
	MOVE.L	D7,D1
	MOVE.L	A4,D2
	JSR	(-48,A6)		; Write
	MOVE.L	D7,D1
	JSR	(-36,A6)		; Close
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

dw_InName:	DC.B	"input.device",0
dw_File:	DC.B	"diagwin.log",0
dw_Dash:	DC.B	"-",0
dw_PName:	DC.B	"PT4.1 diag",0
dw_IName:	DC.B	"PT4.1 diag vbl",0
dw_Head:	DC.B	"sec vbl idle disp forb main mirr tbuild twrite held blk lmb active mx my winpos layowner q liowner q instate insig | top tasks (vbl samples)",10,0
dw_Fmt:		DC.B	"%ld v%ld i%ld d%ld f%ld m%ld r%ld rd%ld tf%ld tb%ld h%ld b%ld l%ld a%ld x%ld y%ld p%08lx lay=%s q%ld li=%s q%ld in=%ld/%08lx | %s %ld, %s %ld, %s %ld, %s %ld, %s %ld",10,0
	EVEN
dw_Tags:	DC.L	$800003eb,dw_ProcEntry	; NP_Entry
		DC.L	$800003f2,0		; NP_CurrentDir
		DC.L	$800003f4,dw_PName	; NP_Name
		DC.L	$800003f5,30		; NP_Priority
		DC.L	$800003f3,8192		; NP_StackSize
		DC.L	0
dw_Int:		DC.L	0,0
		DC.B	2,10			; NT_INTERRUPT, pri 10
		DC.L	dw_IName
		DC.L	0			; is_Data
		DC.L	dw_Server
dw_Proc:	DC.L	0
dw_InTask:	DC.L	0
dw_Sec:		DC.L	0
dw_Vbl:		DC.L	0
dw_VblTot:	DC.L	0
dw_TFr:		DC.L	0
dw_TBl:		DC.L	0
dw_Forb:	DC.L	0
dw_Main:	DC.L	0
dw_LMain:	DC.L	0
dw_LFr:		DC.L	0
dw_LRd:		DC.L	0
dw_LIdle:	DC.L	0
dw_LDisp:	DC.L	0
dw_Hist:	DS.L	32
dw_HCopy:	DS.L	32
dw_Args:	DS.L	34
dw_Buf:		DS.B	512
dw_Started:	DC.B	0
dw_State:	DC.B	0
	EVEN
	ENDC
