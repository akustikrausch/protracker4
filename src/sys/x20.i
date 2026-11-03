; x20: 68020-only tables, alloc'd by pt_MixInitTask, X20LEA ofs,An
	RSRESET
X20_VOLTAB	RS.B	65*256		; voltab[vol][smp] = (smp*vol)>>7
X20_RTGP2C	RS.B	2048		; rtg: p2c 256x8
X20_RTGSIG	RS.L	256		; rtg: line sigs
X20_RTGPSIG	RS.L	256		; rtg: plane data sum per line
X20_RTGKEY	RS.L	256		; rtg: bank, planes, ptrs per line
X20_RTGHEAT	RS.B	256		; rtg: frames a line stays read
X20_RTGBANKS	RS.W	8*30		; rtg: color banks
X20_RTGSEGS	RS.B	12*32		; rtg: spr segs
X20_RTGSPRRGB	RS.W	256		; rtg: spr colors
X20_RTGCOLMAP	RS.B	4096		; rtg: $0rgb -> clut idx
X20_SIZE	RS.B	0

X20LEA	MACRO
	MOVEA.L	x20_Base,\2
	LEA	\1(\2),\2
	ENDM
