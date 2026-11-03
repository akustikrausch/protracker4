; wav / aiff sample loader
; beta loader: file in dat_PatTablePtr (len ..2), 8svx/maestro/raw
; out for copier pt_09BA: dat_SongTypeFlag 0 = 16 bit be (pos = out smps),
; 2 = 8 bit raw (pos = bytes); dat_SongDataBufPtr = rate (> 28000: type 0
; averages pairs, pos already halved)
; wav/aiff: stereo -> mono average, 16 bit le swapped, then beta paths

; hook pt_098A: d0 = first 4 bytes, a0 = buf+4; not riff -> flags as CMP
pt_SmpCheckRiff:
	CMP.L	#"RIFF",D0
	BNE.S	.notriff
	CMPI.L	#"WAVE",4(A0)
	BNE.S	.notriff
	ADDQ.L	#4,A7			; pop ret, return to detect caller
	MOVEM.L	D0-D7/A0-A3,-(A7)
	BSR.W	pt_SmpWav
	MOVEM.L	(A7)+,D0-D7/A0-A3
	RTS
.notriff:
	CMP.L	#"FORM",D0
	RTS

; hook pt_098F: a0 behind form type
pt_SmpCheckAiff:
	CMPI.L	#"AIFF",-4(A0)
	BNE.S	.not
	MOVEM.L	D0-D7/A0-A3,-(A7)
	BSR.W	pt_SmpAiff
	MOVEM.L	(A7)+,D0-D7/A0-A3
	RTS
.not:	ST	dat_AudioFlag1
	MOVE.L	#dat_1336,dat_SongLengthPtr
	RTS

;--- wav
; a0=buf+4 ("WAVE" at 4(a0)), chunks from 8(a0): "fmt " (1=pcm), "data"
pt_SmpWav:
	LEA	8(A0),A1
	MOVEA.L	dat_PatTablePtr,A3
	ADDA.L	dat_PatTablePtr2,A3	; file end
	MOVEQ	#0,D4			; ch
	MOVEQ	#0,D5			; bits
	MOVEQ	#0,D6			; rate
	SUBA.L	A2,A2			; data ptr
	MOVEQ	#0,D7			; data len
.chunk:	CMPA.L	A3,A1
	BCC.S	.done
	MOVE.L	(A1)+,D0		; chunk id
	MOVE.L	(A1)+,D1		; len (le)
	ROR.W	#8,D1
	SWAP	D1
	ROR.W	#8,D1
	CMP.L	#"fmt ",D0
	BNE.S	.ndata
	MOVE.W	2(A1),D4		; ch (le)
	ROR.W	#8,D4
	MOVE.L	4(A1),D6		; rate (le)
	ROR.W	#8,D6
	SWAP	D6
	ROR.W	#8,D6
	MOVE.W	14(A1),D5		; bits (le)
	ROR.W	#8,D5
	BRA.S	.next
.ndata:	CMP.L	#"data",D0
	BNE.S	.next
	MOVEA.L	A1,A2
	MOVE.L	D1,D7
.next:	ADDQ.L	#1,D1
	BCLR	#0,D1
	ADDA.L	D1,A1
	BRA.S	.chunk
.done:	MOVE.L	A2,D0
	BEQ.W	pt_SmpBad
	TST.W	D4
	BEQ.W	pt_SmpBad
; clip data len to file end
	MOVE.L	A3,D0
	SUB.L	A2,D0
	CMP.L	D0,D7
	BLS.S	.lenok
	MOVE.L	D0,D7
.lenok:	CMP.W	#16,D5
	BEQ.S	.w16
	CMP.W	#8,D5
	BNE.W	pt_SmpBad
; 8 bit unsigned -> signed, stereo averaged
	BSR.W	pt_SmpMono8
	MOVEA.L	A2,A0
	MOVE.L	D7,D0
	BEQ.W	pt_SmpBad
.u8:	EORI.B	#$80,(A0)+
	SUBQ.L	#1,D0
	BNE.S	.u8
	BSR.W	pt_SmpRaw8		; type 2, decimates > 28 kHz itself
	BRA.W	pt_SmpNote
.w16:	BSR.W	pt_SmpSwap16		; le -> be
	BSR.W	pt_SmpMono16
	BSR.W	pt_SmpType16
	BRA.W	pt_SmpNote

;--- aiff
; a0 behind "AIFF"; COMM: ch.w frames.l bits.w rate(80b), SSND: ofs.l
pt_SmpAiff:
	MOVEA.L	A0,A1
	MOVEA.L	dat_PatTablePtr,A3
	ADDA.L	dat_PatTablePtr2,A3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	SUBA.L	A2,A2
	MOVEQ	#0,D7
.chunk:	CMPA.L	A3,A1
	BCC.S	.done
	MOVE.L	(A1)+,D0
	MOVE.L	(A1)+,D1
	CMP.L	#"COMM",D0
	BNE.S	.nssnd
	MOVE.W	(A1),D4			; ch
	MOVE.W	6(A1),D5		; bits
; rate: 80 bit extended, exp.w (bias 16383), mantissa at 10(a1)
	MOVE.W	8(A1),D0
	AND.W	#$7fff,D0
	SUB.W	#16383,D0		; e -> rate = mant_hi32 >> (31-e)
	MOVE.L	10(A1),D6
	MOVEQ	#31,D2
	SUB.W	D0,D2
	BLE.S	.rok
	CMP.W	#31,D2
	BHI.S	.rzero
	LSR.L	D2,D6
	BRA.S	.rok
.rzero:	MOVEQ	#0,D6
.rok:	BRA.S	.next
.nssnd:	CMP.L	#"SSND",D0
	BNE.S	.next
	MOVE.L	(A1),D0			; ofs
	LEA	8(A1),A2
	ADDA.L	D0,A2
	MOVE.L	D1,D7
	SUBQ.L	#8,D7
	SUB.L	D0,D7
.next:	ADDQ.L	#1,D1
	BCLR	#0,D1
	ADDA.L	D1,A1
	BRA.S	.chunk
.done:	MOVE.L	A2,D0
	BEQ.S	pt_SmpBad
	TST.W	D4
	BEQ.S	pt_SmpBad
	MOVE.L	A3,D0
	SUB.L	A2,D0
	CMP.L	D0,D7
	BLS.S	.lenok
	MOVE.L	D0,D7
.lenok:	CMP.W	#16,D5
	BEQ.S	.w16
	CMP.W	#8,D5
	BNE.S	pt_SmpBad
	BSR.W	pt_SmpMono8		; already signed
	BSR.W	pt_SmpRaw8
	BRA.S	pt_SmpNote
.w16:	BSR.W	pt_SmpMono16
	BSR.W	pt_SmpType16
	BRA.S	pt_SmpNote

pt_SmpBad:				; unusable -> "NOT AN 8SVX FILE!"
	ST	dat_AudioFlag1
	MOVE.L	#dat_1336,dat_SongLengthPtr
	RTS

; status note "WAV 16BIT 44100HZ" / "AIFF ..." via pt_MixTaskPoll
pt_SmpNote:
	LEA	smp_MsgText,A0
	MOVE.W	D5,D0
	CMP.W	#16,D0
	BNE.S	.b8
	MOVE.B	#"1",11(A0)
	MOVE.B	#"6",12(A0)
	BRA.S	.rate
.b8:	MOVE.B	#" ",11(A0)
	MOVE.B	#"8",12(A0)
.rate:	LEA	22(A0),A1		; 5 digits rate, end at 22
	MOVE.L	D6,D0
	MOVEQ	#4,D2
.dig:	MOVEQ	#10,D1
	JSR	pt_MixDiv32
	ADD.B	#"0",D1
	MOVE.B	D1,-(A1)
	DBF	D2,.dig
	ST	smp_MsgPending
	RTS

;--- helpers: a2=data d7=bytes d4=ch d6=rate
pt_SmpSwap16:				; 16 bit words le -> be
	MOVEA.L	A2,A0
	MOVE.L	D7,D0
	LSR.L	#1,D0
	BEQ.S	.r
.l:	MOVE.W	(A0),D1
	ROR.W	#8,D1
	MOVE.W	D1,(A0)+
	SUBQ.L	#1,D0
	BNE.S	.l
.r:	RTS

pt_SmpMono16:				; stereo (d4=2) -> mono (l+r)/2 packed, d7 halved
	CMP.W	#2,D4
	BNE.S	.r
	MOVEA.L	A2,A0
	MOVEA.L	A2,A1
	MOVE.L	D7,D0
	LSR.L	#2,D0			; frames
	BEQ.S	.r
.l:	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	EXT.L	D1
	EXT.L	D2
	ADD.L	D2,D1
	ASR.L	#1,D1
	MOVE.W	D1,(A1)+
	SUBQ.L	#1,D0
	BNE.S	.l
	LSR.L	#1,D7
	MOVEQ	#1,D4
.r:	RTS

pt_SmpMono8:				; stereo 8 bit -> mono (averaging unsigned = signed)
	CMP.W	#2,D4
	BNE.S	.r
	MOVEA.L	A2,A0
	MOVEA.L	A2,A1
	MOVE.L	D7,D0
	LSR.L	#1,D0
	BEQ.S	.r
.l:	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
	EXT.W	D1
	EXT.W	D2
	ADD.W	D2,D1
	ASR.W	#1,D1
	MOVE.B	D1,(A1)+
	SUBQ.L	#1,D0
	BNE.S	.l
	LSR.L	#1,D7
	MOVEQ	#1,D4
.r:	RTS

pt_SmpRaw8:				; 8 bit signed mono -> type 2; > 28 kHz: drop every 2nd smp
	CMP.L	#28000,D6
	BLS.S	.set
	MOVEA.L	A2,A0
	MOVEA.L	A2,A1
	MOVE.L	D7,D0
	LSR.L	#1,D0
	BEQ.S	.set
.l:	MOVE.B	(A0)+,(A1)+
	ADDQ.L	#1,A0
	SUBQ.L	#1,D0
	BNE.S	.l
	LSR.L	#1,D7
	LSR.L	#1,D6
.set:	SF	dat_ChannelMaskVar
	MOVE.B	#2,dat_SongTypeFlag
	MOVE.L	D6,dat_SongDataBufPtr
	MOVE.L	A2,dat_DiskListPtr
	BCLR	#0,D7
	MOVE.L	D7,dat_DiskListPos
	RTS

pt_SmpType16:				; 16 bit be mono -> type 0, pos = out smps, > 28 kHz halved
	SF	dat_ChannelMaskVar
	CLR.B	dat_SongTypeFlag
	MOVE.L	D6,dat_SongDataBufPtr
	MOVE.L	A2,dat_DiskListPtr
	MOVE.L	D7,D0
	LSR.L	#1,D0			; smps
	CMP.L	#28000,D6
	BLS.S	.set
	LSR.L	#1,D0
.set:	BCLR	#0,D0
	MOVE.L	D0,dat_DiskListPos
	RTS

smp_MsgText:	DC.B	"PCM SAMPLE 16BIT 00000HZ",0
	EVEN

;--- load error paths (pt_099E / pt_09A2)
; orig jumped to the message and returned with random d0, pt_09A2 then
; allocated that "size" -> now msg, d0 = 0, return to pt_099E caller
pt_LoadFailDir41:
	MOVEM.L	D1/A0-A1/A6,-(A7)
	MOVE.L	dat_PatternIndexBuf,D1	; free lock
	MOVEA.L	dat_DosLibBase,A6
	JSR	(-90,A6)		; UnLock
	MOVEM.L	(A7)+,D1/A0-A1/A6
	JSR	pt_0FE7			; "EXAMINE ERROR !"
	BRA.S	pt_LoadFailRet41
pt_LoadFailFind41:
	JSR	pt_0FE8			; "CAN'T FIND FILE !"
	BRA.S	pt_LoadFailRet41
pt_LoadFailEmpty41:
	JSR	pt_0FE9			; "FILE IS EMPTY !"
pt_LoadFailRet41:
	MOVEQ	#0,D0
	ADDQ.L	#4,A7			; drop ret to pt_099E -> its caller
	RTS

; replaces MOVE.L D0,dat_PatTablePtr2 in pt_09A2: size 0 -> return d0 = 0
pt_LoadSizeGuard41:
	MOVE.L	D0,dat_PatTablePtr2
	BNE.S	.ok
	ADDQ.L	#4,A7			; drop ret to pt_09A2
.ok:	RTS

; orig writes the file name into the smp header before open;
; keep old name, restore on failure
pt_LoadSaveName41:
	JSR	pt_SavePaletteState	; orig
	MOVEM.L	D0/A0-A1,-(A7)
	BSR.S	pt_LoadNamePtr41
	LEA	smp_OldName,A1
	MOVEQ	#21,D0
.l:	MOVE.B	(A0)+,(A1)+
	DBF	D0,.l
	MOVEM.L	(A7)+,D0/A0-A1
	RTS
pt_LoadRestoreName41:
	MOVEM.L	D0/A0-A1,-(A7)
	BSR.S	pt_LoadNamePtr41
	LEA	smp_OldName,A1
	MOVEQ	#21,D0
.l:	MOVE.B	(A1)+,(A0)+
	DBF	D0,.l
	MOVEM.L	(A7)+,D0/A0-A1
	JMP	pt_DrawWaveform		; orig
pt_LoadNamePtr41:			; a0 = name of current smp (as pt_09A8)
	MOVEA.L	dat_ModulePtr,A0
	MOVE.W	dat_CurrentSample,D0
	MULU	#s_SIZEOF,D0
	LEA	(-10,A0),A0
	ADDA.L	D0,A0
	RTS
smp_OldName:	DS.B	22
	EVEN

; sample monitor abort check, every 184 smps from pt_1200 loop
; ints are off in the monitor, no key reaches the buffer -> esc read from
; cia-a sdr: $75 = esc down (rawcode $45 inverted, rotated)
; no icr read (would eat other cia events)
; exit: drop ret, continue like orig (pt_ResetIntFlag)
pt_SmpMonExit41:
	LMB
	BEQ.S	.exit
	CMPI.B	#$75,CIAA_SDR		; esc
	BEQ.S	.exit
	IFD	DEBUGAUTO
	TST.W	dbg_MonEsc		; dbg: fake esc after n checks
	BEQ.S	.r
	SUBQ.W	#1,dbg_MonEsc
	BEQ.S	.exit
	ENDC
.r:	RTS
.exit:	ADDQ.L	#4,A7
	JMP	pt_ResetIntFlag
