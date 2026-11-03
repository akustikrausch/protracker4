; editor: 8 track mute, wheel, scope base, help slider
; ctrl+a: mute track under cursor, d0=trk*11+4 -> toggle of ch 1-8
pt_EditMuteTrack:
	ADDQ.L	#4,A7			; toggles return on their own
	SUBQ.W	#4,D0
	BPL.S	.ok
	MOVEQ	#0,D0
.ok:	EXT.L	D0
	DIVU	#11,D0			; track 0-7
	AND.W	#7,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	.tab(PC),A0
	MOVEA.L	(A0,D0.W),A0
	JMP	(A0)
.tab:	DC.L	pt_ScopeCh1Toggle,pt_ScopeCh2Toggle,pt_ScopeCh3Toggle,pt_ScopeCh4Toggle
	DC.L	pt_012F,pt_0130,pt_0131,pt_0132

; wheel: newmouse $7a/$7b -> cursor up/down ($4c/$4d, release $cc/$cd)
pt_EditWheelKey:
	MOVE.B	D1,D0
	AND.B	#$7f,D0
	CMP.B	#$7a,D0
	BNE.S	.n1
	SUB.B	#$7a-$4c,D1
	BRA.S	.st
.n1:	CMP.B	#$7b,D0
	BNE.S	.st
	SUB.B	#$7b-$4d,D1
.st:	MOVE.B	D1,dat_KeyCode
	RTS

; sampler: scopes show the cursor half (col>=24 -> ch5-8)
pt_ScopeBase:
	LEA	dat_Channel1,A0
	BTST	#5,dat_ModeFlags	; set = 4ch
	BNE.S	.r
	CMPI.W	#24,dat_CursorColumn
	BCS.S	.r
	LEA	dat_Channel5,A0
.r:	JSR	pt_Mix68ScopeOff	; a500 mode -> scopes off
	BEQ.S	.rr
	ADDQ.L	#4,A7			; leave caller too
	RTS
.rr:	BTST	#5,dat_ModeFlags
	BNE.S	.x
	TST.W	dat_SamplerActive
	BEQ.S	.s8
	JSR	pt_Vu8StegOff
	BRA.S	.x
.s8:	JSR	pt_Scope8		; 8ch: all channels
	ADDQ.L	#4,A7
.x:	RTS

; d0=len input -> d0=1..128
pt_SongLenClamp41:
	CMP.W	#$0080,D0
	BLS.S	.lo
	MOVE.W	#$0080,D0
.lo:	TST.W	D0
	BNE.S	.r
	MOVEQ	#1,D0
.r:	RTS

; scope step = $8a8d/d1, d1=per/2 (unsigned)
pt_ScopeStep41:
	MOVE.L	#$00008a8d,D2
	DIVU.W	D1,D2
	AND.L	#$0000ffff,D2
	RTS

; help page: 15 lines + slider (head b6='S', b9=top, b12=height)
HLP_ROW0	EQU	17*80+78
pt_HelpPage41:
	MOVEM.L	D0-D2/A0-A2,-(A7)
	LEA	SECSTRT_2+HLP_ROW0,A0
	LEA	chip_ScreenBitplanes+HLP_ROW0,A1
	MOVEA.L	dat_ScreenBuf2Ptr,A2
	LEA	HLP_ROW0(A2),A2
	MOVEQ	#92-1,D0		; clear old slider
.clr:	CLR.B	(A0)
	CLR.B	(A1)
	CLR.B	(A2)
	LEA	80(A0),A0
	LEA	80(A1),A1
	LEA	80(A2),A2
	DBF	D0,.clr
	CMPI.B	#'S',dat_153E+6
	BNE.W	.done
	LEA	SECSTRT_2+HLP_ROW0,A0
	LEA	chip_ScreenBitplanes+HLP_ROW0,A1
	MOVE.B	#$ff,(A1)		; rail frame
	MOVE.B	#$ff,91*80(A1)
	LEA	80(A1),A2
	MOVEQ	#90-1,D0
.rail:	MOVE.B	#$81,(A2)
	LEA	80(A2),A2
	DBF	D0,.rail
	MOVEQ	#0,D1
	MOVE.B	dat_153E+9,D1
	SUB.W	#32,D1
	MOVEQ	#0,D2
	MOVE.B	dat_153E+12,D2
	SUB.W	#32,D2
	CMP.W	#3,D2
	BLT.S	.done
	MOVE.W	D1,D0
	ADD.W	D2,D0
	CMP.W	#90,D0
	BHI.S	.done			; bad head -> no slider
	MULU.W	#80,D1
	LEA	80(A0,D1.L),A0
	LEA	80(A1,D1.L),A1
	MOVE.B	#$7e,(A0)
	MOVE.B	#$83,(A1)
	SUBQ.W	#3,D2
.mid:	LEA	80(A0),A0
	LEA	80(A1),A1
	MOVE.B	#$42,(A0)
	MOVE.B	#$bf,(A1)
	DBF	D2,.mid
	MOVE.B	#$7e,80(A0)
	MOVE.B	#$bf,80(A1)
.done:	MOVEM.L	(A7)+,D0-D2/A0-A2
	MOVE.W	#$05a0,D6
	MOVEQ	#15-1,D7
	RTS
