; extra 8ch ids: OCTA, CD81, FLT8
; octa/cd81 = 8chn layout (2048 bytes/pat)
; flt8: positions doubled (0,2,4..), 8ch pat = two 1024-byte 4ch pats
; (ch1-4, then ch5-8); positions halved after header, pats
; interleaved row by row after the pattern read
; hooks: end of id chain in pt_DosLibDiskOp, pt_0E52, pt_0E5E

; a0 -> id at file ofs 1080
pt_FmtCheckMore:
	CMPI.L	#"OCTA",(A0)
	BEQ.S	.eight
	CMPI.L	#"CD81",(A0)
	BEQ.S	.eight
	CMPI.L	#"FLT8",(A0)
	BNE.S	.unknown
	ST	fmt_Flt8Pending
.eight:	ADDQ.L	#4,A7			; pop ret, jump like the original BEQ.W
	JMP	pt_0E4C
.unknown:				; orig: try 15-smp module, else unknown format
	SF	fmt_Flt8Pending
	JSR	pt_0E37
	CMP.L	#2,D0
	BEQ.S	.ret
	ADDQ.L	#4,A7
	JMP	pt_0E43
.ret:	RTS

; a0=dat_ModulePtr after 1084-byte header; sanitize smp headers
; vol <= 64, replen 0 -> 1, loop end <= len, finetune nibble
; (bit 7 = dyn envelope follows, kept)
pt_FmtAfterHeader:
	MOVE.B	#$7f,(951,A0)
	MOVEM.L	D0-D3/A1,-(A7)
	LEA	mod_samples(A0),A1
	MOVEQ	#30,D3
.smp:	MOVEQ	#0,D0
	MOVE.W	s_length(A1),D0		; words
	CMPI.B	#64,s_volume(A1)
	BLS.S	.volok
	MOVE.B	#64,s_volume(A1)
.volok:	ANDI.B	#$8f,s_finetune(A1)	; bit 7 kept
	MOVE.W	s_replen(A1),D1
	BNE.S	.replenok
	MOVEQ	#1,D1
	MOVE.W	D1,s_replen(A1)
.replenok:
	MOVEQ	#0,D2
	MOVE.W	s_repeat(A1),D2
	CMP.L	D0,D2			; loop start past end?
	BCS.S	.repok
	CLR.W	s_repeat(A1)
	MOVE.W	#1,s_replen(A1)
	BRA.S	.next
.repok:	ADD.L	D1,D2			; loop end
	CMP.L	D0,D2
	BLS.S	.next
	SUB.L	D0,D2			; overhang
	SUB.W	D2,s_replen(A1)
	BNE.S	.next
	MOVE.W	#1,s_replen(A1)
.next:	LEA	s_SIZEOF(A1),A1
	DBF	D3,.smp
	MOVEM.L	(A7)+,D0-D3/A1
	TST.B	fmt_Flt8Pending
	BEQ.S	.r
	MOVEM.L	D0-D1/A1,-(A7)
	LEA	mod_positions(A0),A1
	MOVEQ	#127,D0
.half:	MOVE.B	(A1),D1
	LSR.B	#1,D1
	MOVE.B	D1,(A1)+
	DBF	D0,.half
	MOVEM.L	(A7)+,D0-D1/A1
.r:	RTS

pt_FmtAfterPatterns:
	CLR.W	dat_FileOpFlag
	BSR.W	pt_FmtScanPeriods	; ext octaves check
	TST.B	fmt_Flt8Pending
	BEQ.S	.r
	SF	fmt_Flt8Pending
	MOVEM.L	D0-D3/A0-A3,-(A7)
	MOVEA.L	dat_ModulePtr,A0
	MOVE.L	#"8CHN",mod_id(A0)
; npat = max(positions)+1
	LEA	mod_positions(A0),A1
	MOVEQ	#0,D0
	MOVEQ	#127,D1
.pm:	MOVE.B	(A1)+,D2
	CMP.B	D0,D2
	BLS.S	.pm2
	MOVE.B	D2,D0
.pm2:	DBF	D1,.pm
	LEA	mod_patterns(A0),A1		; a1 = pat block (2048 bytes/pat)
.pat:	; copy to own buffer: the mixer irq writes mix_TickBuf
	LEA	fmt_Flt8Buf,A2
	MOVEA.L	A1,A3
	MOVE.W	#2048/4-1,D1
.cp:	MOVE.L	(A3)+,(A2)+
	DBF	D1,.cp
	LEA	fmt_Flt8Buf,A2			; a2 = ch1-4 (row r at 16r)
	LEA	1024(A2),A3			; a3 = ch5-8
	MOVEQ	#63,D1
.row:	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A2)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	MOVE.L	(A3)+,(A1)+
	DBF	D1,.row
	DBF	D0,.pat
	MOVEM.L	(A7)+,D0-D3/A0-A3
.r:	RTS

; periods outside 113..856 are counted, reported once (pt_MixTaskPoll)
pt_FmtScanPeriods:
	MOVEM.L	D0-D3/A0-A1,-(A7)
	CLR.W	fmt_ExtPeriods
	MOVEA.L	dat_ModulePtr,A0
	LEA	mod_positions(A0),A1
	MOVEQ	#0,D0
	MOVEQ	#127,D1
.pm:	MOVE.B	(A1)+,D2
	CMP.B	D0,D2
	BLS.S	.pm2
	MOVE.B	D2,D0
.pm2:	DBF	D1,.pm
	ADDQ.W	#1,D0			; pats
	MULU	#64,D0
	MULU	dat_RpNumChannels,D0	; cells
	LEA	mod_patterns(A0),A1
	MOVEQ	#0,D3
.cell:	MOVE.B	(A1),D1			; smp nr > 31 (nibbles of byte 0/2) -> 0, else replayer reads past table
	AND.B	#$f0,D1
	MOVE.B	2(A1),D2
	LSR.B	#4,D2
	OR.B	D2,D1
	CMP.B	#31,D1
	BLS.S	.smpok
	AND.B	#$0f,(A1)
	AND.B	#$0f,2(A1)
.smpok:	MOVE.W	(A1),D1
	ADDQ.L	#4,A1
	AND.W	#$0fff,D1
	BEQ.S	.next
	CMP.W	#113,D1
	BCS.S	.ext
	CMP.W	#856,D1
	BLS.S	.next
.ext:	ADDQ.W	#1,D3
.next:	SUBQ.L	#1,D0
	BNE.S	.cell
	MOVE.W	D3,fmt_ExtPeriods
	BEQ.S	.r
	ST	fmt_ExtPending		; report from task context
.r:	MOVEM.L	(A7)+,D0-D3/A0-A1
	RTS

; hook pt_CheckModHeader: d1=fh d2=buf d3=len -> d0=bytes read
; xpk: plain copy. dos: short read -> zero-fill rest, flag truncated
pt_FmtRead:
	TST.W	dat_XpkLibFlag
	BEQ.S	.dos
	JMP	pt_CopyModData
.dos:
	MOVEM.L	D2-D3/A0,-(A7)
	JSR	(-42,A6)		; Read()
	MOVEM.L	(A7)+,D2-D3/A0
	TST.L	D0
	BMI.S	.r			; error: caller handles
	CMP.L	D3,D0
	BCC.S	.r
	MOVEM.L	D0/D3/A0,-(A7)
	MOVEA.L	D2,A0
	ADDA.L	D0,A0
	SUB.L	D0,D3
.clr:	CLR.B	(A0)+
	SUBQ.L	#1,D3
	BNE.S	.clr
	ST	fmt_TruncPending
	IFD	DEBUGFX
	ADDQ.L	#1,dbg_TruncCnt		; dbg: count padded reads
	ENDC
	MOVEM.L	(A7)+,D0/D3/A0
.r:	RTS
fmt_TruncText:	DC.B	"MODULE TRUNCATED",0
	CNOP	0,2
