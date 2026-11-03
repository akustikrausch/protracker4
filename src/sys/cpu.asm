; cpu bench, 68060 detect, about-box info lines

pt_CpuBench:
	MOVEM.L	D1-D7/A0-A1/A6,-(A7)
	CLR.L	dat_CpuBench
	LEA	cpu_TimerName(PC),A0
	MOVEQ	#3,D0			; UNIT_ECLOCK
	LEA	cpu_TimerReq,A1
	MOVEQ	#0,D1
	MOVEA.L	ABSEXECBASE.W,A6
	JSR	(-444,A6)		; OpenDevice
	TST.L	D0
	BNE.W	.fail
	MOVEA.L	cpu_TimerReq+20,A6	; io_Device = TimerBase
	LEA	cpu_EClock,A0
	JSR	(-60,A6)		; ReadEClock -> D0 = Takt/s
	MOVEQ	#50,D1
	JSR	pt_MixDiv32
	MOVE.L	D0,D3			; d3 = eclk ticks per 1/50 s
	LEA	cpu_EClock,A0
	JSR	(-60,A6)
	MOVE.L	cpu_EClock+4,D4		; start
	MOVEQ	#0,D5			; loop cnt
	MOVEQ	#0,D6
.loop:	; 16 reg-only ops, no chip ram contention
	ADD.L	D6,D6
	EOR.L	D5,D6
	ROL.L	#3,D6
	SUB.L	D5,D6
	ADD.L	D6,D6
	EOR.L	D5,D6
	ROL.L	#3,D6
	SUB.L	D5,D6
	ADD.L	D6,D6
	EOR.L	D5,D6
	ROL.L	#3,D6
	SUB.L	D5,D6
	ADD.L	D6,D6
	EOR.L	D5,D6
	ROL.L	#3,D6
	SUB.L	D5,D6
	ADDQ.L	#1,D5
	MOVE.L	D5,D0
	AND.L	#63,D0
	BNE.S	.loop			; read clock every 64 loops only
	LEA	cpu_EClock,A0
	JSR	(-60,A6)
	MOVE.L	cpu_EClock+4,D0
	SUB.L	D4,D0
	CMP.L	D3,D0
	BCS.S	.loop
	MOVE.L	D5,dat_CpuBench
	MOVEA.L	ABSEXECBASE.W,A6
	LEA	cpu_TimerReq,A1
	JSR	(-450,A6)		; CloseDevice
.fail:	MOVEM.L	(A7)+,D1-D7/A0-A1/A6
	RTS
cpu_TimerName:	DC.B	"timer.device",0
	EVEN
cpu_060Known:	DC.B	0
cpu_Is060:	DC.B	0		; 68060 found
	EVEN

; detect 68060: attnflags lacks it without 68060.library, exec says 68040
; movec pcr exists on 68060 only, 68040 traps illegal (vec 4 via vbr)
; result cached, returns Z=0 if 68060, regs kept
pt_CpuIs060:
	MOVEM.L	D0-D2/A0-A1/A5-A6,-(A7)
	TST.B	cpu_060Known
	BNE.S	.known
	ST	cpu_060Known
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.W	(296,A6),D0		; AttnFlags
	BTST	#7,D0			; AFB_68060 (68060.library)
	BNE.S	.yes
	BTST	#3,D0			; nur ein gemeldeter 68040 kann ein 68060 sein
	BEQ.S	.known
	LEA	.sup(PC),A5
	JSR	(-30,A6)		; Supervisor
	TST.B	D0
	BEQ.S	.known
.yes:	ST	cpu_Is060
.known:	TST.B	cpu_Is060
	MOVEM.L	(A7)+,D0-D2/A0-A1/A5-A6
	RTS
; supervisor: d0.b=1 if movec pcr ran
.sup:	ORI.W	#$0700,SR		; ints off while vector is redirected
	DC.W	$4e7a,$8801		; MOVEC VBR,A0 (68010+)
	MOVE.L	($10,A0),D1		; Vektor 4: illegaler Befehl
	LEA	.ill(PC),A1
	MOVE.L	A1,($10,A0)
	MOVEA.L	A7,A1			; keep sp, exception frame is dropped
	MOVEQ	#0,D0
	DC.W	$4e7a,$2808		; MOVEC PCR,D2 (nur 68060)
	MOVEQ	#1,D0
.back:	MOVEA.L	A1,A7
	MOVE.L	D1,($10,A0)
	RTE
.ill:	BRA.S	.back

; fill str_AboutCpu: cpu type, bench index, output path
; cols: cpu 18, index 36-41, path 52
pt_CpuAboutFill:
	MOVEM.L	D0-D3/A0-A1/A6,-(A7)
	LEA	str_AboutCpu,A0
	MOVEA.L	ABSEXECBASE.W,A6
	MOVE.W	(296,A6),D0		; AttnFlags
	MOVEQ	#"0",D1
	BTST	#0,D0
	BEQ.S	.cpu
	MOVEQ	#"1",D1
	BTST	#1,D0
	BEQ.S	.cpu
	MOVEQ	#"2",D1
	BTST	#2,D0
	BEQ.S	.cpu
	MOVEQ	#"3",D1
	BTST	#3,D0
	BEQ.S	.cpu
	MOVEQ	#"4",D1
	BSR.W	pt_CpuIs060
	BEQ.S	.cpu
	MOVEQ	#"6",D1
.cpu:	MOVE.B	D1,18(A0)		; "680x0"
	; Leistungsindex 6-stellig dezimal ab Spalte 35
	MOVE.L	dat_CpuBench,D0
	LEA	42(A0),A1
	MOVEQ	#5,D2
.dig:	MOVEQ	#10,D1
	JSR	pt_MixDiv32		; D0 / 10, D1 Rest
	ADD.B	#"0",D1
	MOVE.B	D1,-(A1)
	DBF	D2,.dig
	; output path: col 52, 8 chars
	LEA	.paula(PC),A1
	TST.B	ahi_Active
	BEQ.S	.p
	LEA	.ahi(PC),A1
	BRA.S	.cp
.p:	BTST	#5,dat_ModeFlags	; 4-Kanal-Modus
	BNE.S	.cp
	TST.B	mix_Enabled
	BEQ.S	.cp
	LEA	.mix(PC),A1
.cp:	MOVEQ	#7,D2
	LEA	52(A0),A0
.c:	MOVE.B	(A1)+,(A0)+
	DBF	D2,.c
	MOVEM.L	(A7)+,D0-D3/A0-A1/A6
	RTS
.paula:	DC.B	"Paula   "
.mix:	DC.B	"Paula 8 "
.ahi:	DC.B	"AHI     "
	EVEN

; fill str_AboutMem: free chip kb / fast mb, 6 digits each
;          "        Free memory: Chip 000000 KB    Fast 000000 MB"
;           0         10        20   26    32        42   47
pt_MemAboutFill:
	MOVEM.L	D0-D3/A0-A1/A6,-(A7)
	MOVEA.L	ABSEXECBASE.W,A6
	MOVEQ	#2,D1			; MEMF_CHIP
	JSR	(-216,A6)		; AvailMem
	MOVEQ	#10,D1
	LSR.L	D1,D0			; KB
	LEA	str_AboutMem+32,A1
	BSR.S	.six
	MOVEQ	#4,D1			; MEMF_FAST
	JSR	(-216,A6)
	MOVEQ	#20,D1
	LSR.L	D1,D0			; MB
	LEA	str_AboutMem+50,A1
	BSR.S	.six
	MOVEM.L	(A7)+,D0-D3/A0-A1/A6
	RTS
.six:	; d0 -> 6 digits left of a1, leading zeros -> spaces
	MOVEQ	#5,D2
.d:	MOVEQ	#10,D1
	JSR	pt_MixDiv32		; D0 / 10, Rest D1
	ADD.B	#"0",D1
	MOVE.B	D1,-(A1)
	DBF	D2,.d
	MOVEQ	#4,D2
.z:	CMPI.B	#"0",(A1)
	BNE.S	.zr
	MOVE.B	#" ",(A1)+
	DBF	D2,.z
.zr:	RTS

; about-box hook: refresh mem line on open
pt_MemAboutHook:
	BSR.W	pt_MemAboutFill
	BSR.W	pt_CpuAboutFill
	LEA	SECSTRT_1,A0
	RTS

; 100 patterns do not fit -> status hint before 64 pattern fallback
pt_MemOnly64:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	LEA	mem_Only64(PC),A0
	JSR	pt_ShowStatusMsg
	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS
mem_Only64:	DC.B	"ONLY 64 PATTERNS (MEMORY)",0
	EVEN

; odd-address safe word fetch for author search, d1=word
pt_AuthorWord41:
	MOVE.B	(2,A0,D0.W),D1
	LSL.W	#8,D1
	MOVE.B	(3,A0,D0.W),D1
	TST.W	D1
	RTS
