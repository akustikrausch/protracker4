; save exe, 8ch: player stub + 8chn module
; 4ch keeps the original stub (dat_HunkHeaderData), 8ch writes exe8_Stub

	INCLUDE	"src/data/bin/exe8_stub.i"

; hook pt_0EBE: patch hunk sizes, d0 = mod size in longs
pt_Exe8Patch:
	BTST	#5,dat_ModeFlags	; bit 5 = 4ch
	BNE.S	.ch4
	LEA	exe8_Stub+EXE8_DATASIZE,A0
	MOVE.L	D0,(A0)
	LEA	exe8_Stub+EXE8_HDRSIZE,A0
	ADD.L	#$40000000,D0		; chip hunk
	MOVE.L	D0,(A0)
	RTS
.ch4:	LEA	dat_HunkHeaderData,A0
	ADDA.W	#$1590,A0
	MOVE.L	D0,(A0)
	LEA	dat_HunkHeaderData,A0
	ADDA.W	#$0018,A0
	ADD.L	#$40000000,D0
	MOVE.L	D0,(A0)
	RTS

; hook: file write size/addr
pt_Exe8WriteParams:
	BTST	#5,dat_ModeFlags
	BNE.S	.ch4
	MOVE.L	#EXE8_LEN,dat_FileWriteSize
	MOVE.L	#exe8_Stub,dat_FileWriteAddr
	RTS
.ch4:	MOVE.L	#$00001594,dat_FileWriteSize
	MOVE.L	#dat_HunkHeaderData,dat_FileWriteAddr
	RTS

; hook pt_PrepareModSave: d0 = pattern bytes (1024/pat, 2048 in 8ch)
pt_Exe8PatBytes:
	MOVEQ	#0,D0
	MOVE.W	dat_NumSamples,D0
	ADDQ.L	#1,D0
	LSL.L	#8,D0
	LSL.L	#2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	.r
	ADD.L	D0,D0
.r:	RTS

; hook: a0 = mod, 8chn id in 8ch
pt_Exe8ModId:
	BTST	#5,dat_ModeFlags
	BNE.S	.ch4
	MOVE.L	#$3843484e,(mod_id,A0)	; "8CHN"
	RTS
.ch4:	CMPI.W	#$0040,dat_NumSamples
	BCS.S	.r
	MOVE.L	#$4d214b21,(mod_id,A0)	; "M!K!" from 64 pats
.r:	RTS

; hook: exe load; file ofs 40 = 8ch stub id -> mod after exe8_Stub
pt_Exe8LoadMark:
	MOVE.W	#$0001,dat_SampleTableOfs
	MOVE.L	#$00001594,exe8_Skip
	MOVEM.L	D0/A1,-(A7)
	LEA	exe8_Stub+40,A1
	MOVE.L	dat_SampleChannelMask,D0
	CMP.L	(A1)+,D0
	BNE.S	.r
	MOVE.L	dat_SampleChannelMask+4,D0
	CMP.L	(A1),D0
	BNE.S	.r
	MOVE.L	#EXE8_LEN,exe8_Skip
.r:	MOVEM.L	(A7)+,D0/A1
	RTS

; hook pt_FileSeekPos
pt_Exe8SeekAdd:
	ADD.L	exe8_Skip,D2
	RTS

exe8_Skip:	DC.L	$00001594

	CNOP	0,4
exe8_Stub:
	INCBIN	"src/data/bin/exe8_stub.bin"
	CNOP	0,4
