; diskop: free space, requesters, progdir, long names, dos list
; pt_DiskFreeCalc: free blocks d0 * bytes/block d2 as 64 bit product
; (26,A5) = low 32 bits, ovfl -> $ffffffff; dat_DiskFreeMB = mb
pt_DiskFreeCalc:
	MOVEM.L	D0-D5,-(A7)
; 32x32 -> 64: (ah*2^16+al)*(bh*2^16+bl)
	MOVE.L	D0,D1
	MOVE.L	D2,D3
	MOVE.W	D0,D4
	MULU	D2,D4			; al*bl
	SWAP	D1
	MOVE.W	D1,D5
	MULU	D2,D5			; ah*bl
	SWAP	D3
	MULU	D3,D1			; ah*bh
	MULU	D3,D0			; al*bh (D0.W = al)
; lo = al*bl + ((ah*bl + al*bh) << 16), hi = ah*bh + carries
	MOVEQ	#0,D2
	ADD.L	D5,D0			; ah*bl + al*bh
	ADDX.W	D2,D2			; carry (bit 32 of cross sum)
	MOVE.L	D0,D3
	SWAP	D3
	MOVE.W	D2,D3			; d3 = cross sum >> 16 with carry, rebuild
	MOVEQ	#0,D3
	MOVE.W	D0,D3
	SWAP	D3			; d3 = (cross & $ffff) << 16
	CLR.W	D0
	SWAP	D0			; d0 = cross >> 16
	SWAP	D2
	CLR.W	D2			; d2 = carry << 16
	ADD.L	D2,D0
	ADD.L	D0,D1			; hi = ah*bh + (cross >> 16) + carry
	ADD.L	D3,D4			; lo = al*bl + (cross << 16)
	MOVEQ	#0,D0
	ADDX.L	D0,D1			; carry lo -> hi
; mb = (hi << 12) | (lo >> 20)
	MOVE.L	D1,D2
	MOVEQ	#12,D0
	LSL.L	D0,D2
	MOVE.L	D4,D3
	MOVEQ	#20,D0
	LSR.L	D0,D3
	OR.L	D3,D2
	MOVE.L	D2,dat_DiskFreeMB
	MOVE.L	D4,D3
	TST.L	D1
	BEQ.S	.store
	MOVEQ	#-1,D3			; > 4 gb: clamp to 4095 mb
.store:	MOVE.L	D3,(26,A5)
	MOVEM.L	(A7)+,D0-D5
	RTS

; free space: replaces MOVE.L (26,A5),D0 / MOVE.W #$2001,dat_TextBytePos
; always from dat_DiskFreeMB; 7 chars "dddd MB"/GB/TB (from 10000),
; leading zeros blank, skips the caller's byte/mb output
pt_DiskFreeShow:
	MOVE.W	#$2001,dat_TextBytePos
	MOVEM.L	D0-D3/A0-A1,-(A7)
	MOVE.L	dat_DiskFreeMB,D0
	MOVEQ	#"M",D2
	CMP.L	#10000,D0
	BCS.S	.unit
	MOVEQ	#10,D1
	LSR.L	D1,D0			; gb
	MOVEQ	#"G",D2
	CMP.L	#10000,D0
	BCS.S	.unit
	LSR.L	D1,D0			; tb
	MOVEQ	#"T",D2
	CMP.L	#9999,D0
	BLS.S	.unit
	MOVE.L	#9999,D0
.unit:	LEA	disk_FreeText,A0
	MOVE.B	#" ",4(A0)
	MOVE.B	D2,5(A0)
	MOVE.B	#"B",6(A0)
; four digits, leading zeros blank (d3 = digit already out)
	MOVEQ	#0,D3
	DIVU	#1000,D0
	BSR.S	.dig
	DIVU	#100,D0
	BSR.S	.dig
	DIVU	#10,D0
	BSR.S	.dig
	ADD.B	#"0",D0
	MOVE.B	D0,(A0)+
; put 7 chars (pt_DisplayDigitFormat: d0 = char, trashes a0/d1)
	LEA	disk_FreeText,A1
	MOVEQ	#6,D3
.out:	MOVE.B	(A1)+,D0
	MOVEM.L	D3/A1,-(A7)
	JSR	pt_DisplayDigitFormat
	MOVEM.L	(A7)+,D3/A1
	DBF	D3,.out
	MOVEM.L	(A7)+,D0-D3/A0-A1
	MOVE.L	#pt_ProcessHitboxEnd,(A7)	; skip caller byte/mb output
	RTS
.dig:	; d0 = quot(lo) rem(hi) -> digit (a0)+, d0 = rem; lead 0 blank
	MOVE.W	D0,D1
	ADD.B	#"0",D1
	TST.W	D3
	BNE.S	.put
	CMP.B	#"0",D1
	BNE.S	.put
	MOVEQ	#" ",D1
	BRA.S	.store
.put:	MOVEQ	#1,D3
.store:	MOVE.B	D1,(A0)+
	CLR.W	D0
	SWAP	D0			; rem
	RTS

;--- system requesters
; pr_WindowPtr = -1 suppresses dos requesters ("No disk present"),
; lock/open return 0 + ioerr; old value restored on exit
pt_DosNoRequesters:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	SUBA.L	A1,A1
	JSR	(-294,A6)		; FindTask(0)
	MOVEA.L	D0,A0
	MOVE.L	A0,disk_ProcPtr
	MOVE.L	(184,A0),disk_OldWindowPtr	; pr_WindowPtr
	MOVE.L	#-1,(184,A0)
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS
pt_DosRestoreRequesters:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	SUBA.L	A1,A1
	JSR	(-294,A6)
	MOVEA.L	D0,A0
	MOVE.L	disk_OldWindowPtr,(184,A0)
	CLR.L	disk_ProcPtr
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

;--- progdir: and tooltypes
; help/config: PROGDIR: first, then S:; config saved where it was found
; wb start (str_VersionTag = wbstartup msg): tooltype CONFIG=nn (hex) once

; help open, replaces 2x str_HelpFilePath / $3ed / DosLibBase / Open
; -> d0 = fh, a6 = dosbase, d1/d2 trashed
pt_OpenHelpFile:
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#disk_ProgdirHelp,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)		; Open(PROGDIR:PT.help)
	TST.L	D0
	BNE.S	.r
	MOVE.L	#str_HelpFilePath,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)		; fallback s:PT.help
.r:	RTS

; copy "PT.config-xx" (13 bytes) FilePathBuf2+2 -> disk_ProgdirCfg+8
pt_CfgProgdirName:
	MOVEM.L	D0/A0-A1,-(A7)
	LEA	dat_FilePathBuf2+2,A0
	LEA	disk_ProgdirCfg+8,A1
	MOVEQ	#12,D0
.c:	MOVE.B	(A0)+,(A1)+
	DBF	D0,.c
	MOVEM.L	(A7)+,D0/A0-A1
	RTS

; config read, replaces FilePathBuf2 / $3ed / DosLibBase / Open
pt_OpenConfigRead:
	MOVEA.L	dat_DosLibBase,A6
	BSR.S	pt_CfgProgdirName
	MOVE.L	#disk_ProgdirCfg,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	ST	disk_CfgProgdir
	TST.L	D0
	BNE.S	.r
	SF	disk_CfgProgdir
	MOVE.L	#dat_FilePathBuf2,D1
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)		; fallback S:PT.config-xx
.r:	RTS

; config write, replaces FilePathBuf2 / $3ee / Open (a6 = dosbase)
pt_OpenConfigWrite:
	BSR.S	pt_CfgProgdirName
	TST.B	disk_CfgProgdir
	BNE.S	.pd			; loaded from progdir: -> save there
	MOVE.L	#disk_ProgdirCfg,D1	; else only if one exists there
	MOVE.L	#$000003ed,D2
	JSR	(-30,A6)
	TST.L	D0
	BEQ.S	.s
	MOVE.L	D0,D1
	JSR	(-36,A6)		; Close
.pd:	MOVE.L	#disk_ProgdirCfg,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
	TST.L	D0
	BNE.S	.r
.s:	MOVE.L	#dat_FilePathBuf2,D1
	MOVE.L	#$000003ee,D2
	JSR	(-30,A6)
.r:	RTS

; head of pt_06E1 (config load): first call -> tooltype CONFIG=nn,
; then orig pt_SavePaletteState / pt_0703
pt_CfgPrepare:
	TST.B	disk_ToolDone
	BNE.S	.go
	ST	disk_ToolDone
	BSR.S	pt_CfgToolTypes
	JSR	pt_PrefsLoad41		; prefs, once
	JSR	pt_AhiDetect		; ahi detect
.go:	JSR	pt_SavePaletteState
	JMP	pt_0703

; wb start: wbstartup > wbarg > GetDiskObject > FindToolType CONFIG
pt_CfgToolTypes:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEA.L	str_VersionTag,A2	; wbstartup msg (0 = cli)
	MOVE.L	A2,D0
	BEQ.W	.r
	TST.L	28(A2)			; sm_NumArgs
	BEQ.W	.r
	MOVEA.L	36(A2),A3		; sm_ArgList
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	disk_IconName(PC),A1
	MOVEQ	#36,D0
	JSR	(-552,A6)		; OpenLibrary("icon.library", 36)
	MOVE.L	D0,D7
	BEQ.W	.r
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	(A3),D1			; wa_Lock
	JSR	(-126,A6)		; CurrentDir()
	MOVE.L	D0,D6			; old lock
	MOVEA.L	D7,A6
	MOVEA.L	4(A3),A0		; wa_Name
	JSR	(-78,A6)		; GetDiskObject()
	MOVE.L	D0,D5
	BEQ.W	.cd
	MOVEA.L	D0,A0
	MOVEA.L	54(A0),A0		; do_ToolTypes
	MOVE.L	A0,D0
	BEQ.W	.free
	LEA	disk_ToolAhi(PC),A1
	JSR	(-96,A6)		; FindToolType("AHI")
	TST.L	D0
	BEQ.S	.noahi
	ST	ahi_Want
.noahi:	MOVEA.L	D5,A0
	MOVEA.L	54(A0),A0
	LEA	disk_ToolRtg(PC),A1
	JSR	(-96,A6)		; FindToolType("RTG")
	TST.L	D0
	BEQ.S	.nortg
	ST	rtg_Want
	MOVEA.L	D0,A0			; RTG=WINDOW
	MOVE.B	(A0),D0
	AND.B	#$df,D0
	CMP.B	#'W',D0
	BNE.S	.nortg
	MOVE.B	#1,rtg_WinMode
.nortg:	MOVEA.L	D5,A0
	MOVEA.L	54(A0),A0
	LEA	disk_ToolCfg(PC),A1
	JSR	(-96,A6)		; FindToolType
	TST.L	D0
	BEQ.S	.free
	MOVEA.L	D0,A0
	MOVEQ	#0,D1			; hex, max 2 digits
	MOVEQ	#1,D2
.dig:	MOVE.B	(A0)+,D0
	BEQ.S	.set
	CMP.B	#"a",D0
	BCS.S	.up
	SUB.B	#$20,D0			; lower -> upper
.up:	SUB.B	#"0",D0
	BCS.S	.set
	CMP.B	#9,D0
	BLS.S	.ok
	SUB.B	#"A"-"0"-10,D0		; "A" -> 10
	CMP.B	#10,D0
	BCS.S	.set
	CMP.B	#15,D0
	BHI.S	.set
.ok:	LSL.W	#4,D1
	OR.B	D0,D1
	DBF	D2,.dig
.set:	MOVE.W	D1,dat_DiskOpVar1
.free:	MOVE.L	D5,D0
	BEQ.S	.cd
	MOVEA.L	D0,A0
	JSR	(-90,A6)		; FreeDiskObject()
.cd:	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	D6,D1
	JSR	(-126,A6)		; CurrentDir(old)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEA.L	D7,A1
	JSR	(-414,A6)		; CloseLibrary()
.r:	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
disk_IconName:	DC.B	"icon.library",0
disk_ToolCfg:	DC.B	"CONFIG",0
disk_ToolAhi:	DC.B	"AHI",0
disk_ToolRtg:	DC.B	"RTG",0
disk_ProgdirHelp:	DC.B	"PROGDIR:PT.help",0
disk_ProgdirCfg:	DC.B	"PROGDIR:PT.config-00",0,0
	CNOP	0,2

;--- long file names
; dir entries are 36 bytes (30 name, date, size), list grows by 50;
; name > 30: 25 chars, byte 25 = 0, 26 = $ff, 27 = pool index
; (pool 128 x 108 chars); click keeps full name in disk_LongPtr,
; pt_CopyFilename appends it; dirs with long names entered by full name
DISK_LONGMAX	EQU	128

; store entry name: a0=fib_FileName a1=entry a5=list head (22,a5)=cnt
pt_DiskStoreName:
	MOVEM.L	D0-D2/A0-A2,-(A7)
	TST.W	(22,A5)
	BNE.S	.len
	CLR.W	disk_LongCount		; first entry of new dir -> clear pool
	CLR.L	disk_LongPtr
.len:	MOVEA.L	A0,A2
	MOVEQ	#0,D2
.l:	TST.B	(A2)+
	BEQ.S	.got
	ADDQ.W	#1,D2
	CMP.W	#107,D2
	BLO.S	.l
.got:	CMP.W	#30,D2
	BLS.S	.short
	MOVE.W	disk_LongCount,D1
	CMP.W	#DISK_LONGMAX,D1
	BHS.S	.short			; pool full -> truncate
	TST.L	disk_LongPool		; alloc pool on first long name (MEMF_PUBLIC|CLEAR)
	BNE.S	.pool
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	#DISK_LONGMAX*108,D0
	MOVE.L	#$10001,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-198,A6)
	MOVE.L	D0,disk_LongPool
	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	TST.L	disk_LongPool
	BEQ.S	.short			; no mem -> truncate
.pool:	MOVEA.L	A0,A2
	MOVEQ	#24,D0
.c25:	MOVE.B	(A2)+,(A1)+
	DBF	D0,.c25
	CLR.B	(A1)+			; byte 25
	MOVE.B	#$ff,(A1)+		; byte 26: mark
	MOVE.B	D1,(A1)+		; byte 27: index
	MULU	#108,D1
	MOVEA.L	disk_LongPool,A2
	ADDA.L	D1,A2
	MOVEQ	#107,D0
.cp:	MOVE.B	(A0)+,(A2)+
	DBF	D0,.cp
	CLR.B	-1(A2)
	ADDQ.W	#1,disk_LongCount
	BRA.S	.r
.short:	MOVEQ	#29,D0			; orig: up to 30 chars incl end
.s:	MOVE.B	(A0)+,D1
	MOVE.B	D1,(A1)+
	TST.B	D1
	BEQ.S	.r
	DBF	D0,.s
.r:	MOVEM.L	(A7)+,D0-D2/A0-A2
	RTS

; entry (a0) marked? -> d0 = full name ptr else 0, trashes d0
pt_DiskLongOf:
	MOVEQ	#0,D0
	TST.B	25(A0)
	BNE.S	.r
	CMPI.B	#$ff,26(A0)
	BNE.S	.r
	MOVE.B	27(A0),D0
	MULU	#108,D0
	ADD.L	disk_LongPool,D0
.r:	TST.L	D0
	RTS

; free pool (exit, from pt_MixExitHook)
pt_DiskLongFree:
	MOVEM.L	D0-D1/A0-A1/A6,-(A7)
	MOVE.L	disk_LongPool,D0
	BEQ.S	.r
	MOVEA.L	D0,A1
	MOVE.L	#DISK_LONGMAX*108,D0
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-210,A6)
	CLR.L	disk_LongPool
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1/A6
	RTS

; file clicked, replaces LEA dat_ScopeBuf1,A1 / MOVEQ 29,D0; keep name
pt_DiskUseName:
	BSR.S	pt_DiskLongOf
	MOVE.L	D0,disk_LongPtr
	LEA	dat_ScopeBuf1,A1
	MOVEQ	#29,D0
	RTS

; dir clicked, replaces MOVE.L A0,-(A7) / MOVEA.L dat_SampleEditorPtr,A0 /
; BSR pt_CopyFilename / MOVEA.L (A7)+,A0 / MOVEQ 79,D0 (a0 = entry)
; orig then copies 80 chars (a0) -> (a1): full name if long
pt_DiskDirName:
	MOVE.L	A0,-(A7)
	CLR.L	disk_LongPtr
	MOVEA.L	dat_SampleEditorPtr,A0
	JSR	pt_CopyFilename
	MOVEA.L	(A7)+,A0
	BSR.S	pt_DiskLongOf
	BEQ.S	.plain
	MOVEA.L	D0,A0
.plain:	MOVEQ	#79,D0
	RTS

; head of pt_CopyFilename, replaces LEA dat_FileNameBuf,A1; else orig
; else copy path like orig (add / or :), append full name, clear mark,
; a1 -> scratch (caller copies 30 chars of dat_ScopeBuf1 blindly)
; only if dat_ScopeBuf1 starts with the first 25 chars of the long name
pt_DiskCopyFilename:
	LEA	dat_FileNameBuf,A1
	MOVE.L	disk_LongPtr,D0
	BEQ.S	.r
	MOVEM.L	D1/A0/A2-A3,-(A7)
	MOVEA.L	D0,A2
	LEA	dat_ScopeBuf1,A3
	MOVEQ	#24,D1
.chk:	CMPM.B	(A2)+,(A3)+
	DBNE	D1,.chk
	BNE.S	.stale
	TST.B	(A0)
	BEQ.S	.name
.path:	MOVE.B	(A0)+,(A1)+
	BNE.S	.path
	CMPI.B	#":",(-2,A1)
	BEQ.S	.sep
	CMPI.B	#"/",(-2,A1)
	BEQ.S	.sep
	MOVE.B	#"/",(-1,A1)
	BRA.S	.name
.sep:	SUBQ.L	#1,A1
.name:	MOVEA.L	D0,A2
.cn:	MOVE.B	(A2)+,(A1)+
	BNE.S	.cn
	CLR.L	disk_LongPtr
	LEA	disk_Scratch,A1
	MOVEM.L	(A7)+,D1/A0/A2-A3
	ADDQ.L	#4,A7			; pop ret, return to pt_CopyFilename caller
	RTS
.stale:	CLR.L	disk_LongPtr
	MOVEM.L	(A7)+,D1/A0/A2-A3
	LEA	dat_FileNameBuf,A1
.r:	RTS

;--- dos list lock
; dev/vol/assign list: dos >= v36 LockDosList(DEV|VOL|ASSIGN|READ),
; else Forbid/Permit as orig
; both leave a6 = execbase like the orig spots
LDF_ALLREAD	EQU	$1d

pt_DosListLock:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	MOVEA.L	dat_DosLibBase,A6
	CMPI.W	#36,20(A6)		; lib_Version
	BLO.S	.forbid
	MOVE.L	#LDF_ALLREAD,D1
	JSR	(-654,A6)		; LockDosList()
	ST	disk_DosLocked
	BRA.S	.r
.forbid:
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-132,A6)		; Forbid()
	SF	disk_DosLocked
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1
	MOVEA.L	ABSEXECBASE.W,A6
	RTS

pt_DosListUnlock:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	TST.B	disk_DosLocked
	BEQ.S	.permit
	SF	disk_DosLocked
	MOVEA.L	dat_DosLibBase,A6
	MOVE.L	#LDF_ALLREAD,D1
	JSR	(-660,A6)		; UnLockDosList()
	BRA.S	.r
.permit:
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-138,A6)		; Permit()
.r:	MOVEM.L	(A7)+,D0-D1/A0-A1
	MOVEA.L	ABSEXECBASE.W,A6
	RTS

;--- dir read
; orig redraws the list after every entry; now only while first page fills
; (19 entries), then every 32nd; callers draw the final state
pt_DiskEntryRedraw:
	MOVE.W	(22,A5),D0
	CMP.W	#19,D0
	BLS.S	.draw
	AND.W	#31,D0
	BNE.S	.r
.draw:	MOVEM.L	D0-D7/A0-A6,-(A7)
	CLR.W	D0
	JSR	pt_02DC
	JSR	pt_ScanButtonHitbox
	MOVEM.L	(A7)+,D0-D7/A0-A6
.r:	RTS

;--- load sample
; main screen gadget $30 had no handler; replaces end of dispatch chain
; (BEQ.W pt_BtnMainCredits / RTS, flags of CMP.W #$0056,D2 live):
; opens disk op in sample load mode (hook at SAVE SAMPLE)
pt_MainDispatchMore:
	BEQ.W	pt_MainCreditsJmp
	CMP.W	#$0030,D2
	BEQ.S	pt_MainLoadSample
	RTS
pt_MainCreditsJmp:
	JMP	pt_BtnMainCredits
pt_MainLoadSample:
	JSR	pt_BtnMainDiskOp
	JMP	pt_SampleEditorSetup

; key check in pt_SetupDisplayMode text input (makedir, rename, format)
; esc = cancel, return unused; replaces pt_ScreenDragUpdate/GetKeypress
pt_DlgKeys41:
	JSR	pt_ScreenDragUpdate
	JSR	pt_GetKeypress
	CMPI.B	#$45,dat_KeyCode	; ESC
	BEQ.S	.esc
	RTS
.esc:	CLR.B	dat_KeyCode
	ADDQ.L	#4,A7			; drop ret, continue like gadget CANCEL
	JMP	pt_032C

; format window (pt_05B1): esc = cancel (pt_05B6, ret -1), else Z like LMB
; (BTST #6,$BFE001: Z=1 = pressed) for the loop BNE.S
pt_FmtKeys41:
	JSR	pt_ScreenDragUpdate
	JSR	pt_GetKeypress
	CMPI.B	#$45,dat_KeyCode	; ESC
	BEQ.S	.esc
	LMB				; like orig
	RTS
.esc:	CLR.B	dat_KeyCode
	ADDQ.L	#4,A7
	JMP	pt_05B6

;--- screen switcher
; orig sends the screen back and waits for the user to bring it up;
; now a small window on the default screen: click or close -> pt front
; per pt_WaitScreenFree loop, replaces MOVEA.L dat_DosLibBase,A6
pt_ScrBackPoll41:
	MOVEM.L	D0-D2/A0-A1,-(A7)
	MOVEA.L	dat_IntuiLibBase,A6
	MOVE.L	scr41_Win,D0
	BNE.S	.have
	TST.B	scr41_Fail
	BNE.W	.out
	SUBA.L	A0,A0			; OpenWindowTagList(NULL, Tags)
	LEA	scr41_Tags,A1
	JSR	(-606,A6)
	MOVE.L	D0,scr41_Win
	BNE.S	.have
	ST	scr41_Fail		; no window: wait like orig
	BRA.S	.out
.have:	MOVEA.L	D0,A0
	MOVEA.L	(86,A0),A0		; wd_UserPort
	MOVEQ	#0,D2
.msg:	MOVE.L	A0,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-372,A6)		; GetMsg
	MOVEA.L	(A7)+,A0
	TST.L	D0
	BEQ.S	.nomsg
	MOVEQ	#1,D2
	MOVEA.L	D0,A1
	MOVE.L	A0,-(A7)
	JSR	(-378,A6)		; ReplyMsg
	MOVEA.L	(A7)+,A0
	BRA.S	.msg
.nomsg:
	IFD	DEBUGAUTO
	ADDQ.W	#1,dbg_ScrBackPolls	; dbg: no driver here, fake click after ~3 s
	CMPI.W	#15,dbg_ScrBackPolls
	BNE.S	.dbg
	MOVE.L	scr41_Win,dbg_ScrBackWin
	MOVEQ	#1,D2
.dbg:
	ENDC
	TST.W	D2
	BEQ.S	.out
	MOVEA.L	dat_IntuiLibBase,A6	; click: pt to front, wait loop ends next pass
	MOVEA.L	dat_ScreenPtr,A0
	JSR	(-252,A6)		; ScreenToFront
.out:	MOVEM.L	(A7)+,D0-D2/A0-A1
	MOVEA.L	dat_DosLibBase,A6
	RTS

; before pt_OpenScreenInit: close window, a6 = intuitionbase
pt_ScrBackDone41:
	MOVEA.L	dat_IntuiLibBase,A6
	MOVE.L	scr41_Win,D0
	BEQ.S	.r
	MOVE.L	A0,-(A7)
	MOVEA.L	D0,A0
	CLR.L	scr41_Win
	JSR	(-72,A6)		; CloseWindow
	MOVEA.L	(A7)+,A0
.r:	SF	scr41_Fail
	IFD	DEBUGAUTO
	CLR.W	dbg_ScrBackPolls
	ENDC
	RTS

	CNOP	0,4
scr41_Tags:	DC.L	$80000064,40		; WA_Left
	DC.L	$80000065,30		; WA_Top
	DC.L	$80000066,400		; WA_Width
	DC.L	$80000067,40		; WA_Height
	DC.L	$8000006a,$00040208	; WA_IDCMP: MOUSEBUTTONS|CLOSEWINDOW|ACTIVEWINDOW
	DC.L	$8000006b,$0002000e	; WA_Flags: DRAGBAR|DEPTHGADGET|CLOSEGADGET|NOCAREREFRESH
	DC.L	$8000006e,scr41_Title	; WA_Title
	DC.L	0
scr41_Title:	DC.B	"ProTracker 4.1.1 - click here to return",0
	EVEN
