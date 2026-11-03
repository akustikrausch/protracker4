; channel, paula and mod header structs; offsets pinned by FAIL checks

;--- channel struct (88 bytes)
	RSRESET
n_note		RS.W	1	; cur note (period from pat)
n_cmd		RS.B	1	; effect cmd (hi nibble = smp hi)
n_cmdlo		RS.B	1	; effect param
n_start		RS.L	1	; smp start -> AUDxLCH
n_length	RS.W	1	; words -> AUDxLEN
n_loopstart	RS.L	1
n_replen	RS.W	1	; words
n_period	RS.W	1	; -> AUDxPER
n_finetune	RS.B	1	; 0-15
n_volume	RS.B	1	; 0-64 -> AUDxVOL
n_pt4_volscale	RS.W	1	; 0-64 from dat_RpMasterVol, pt2.3: n_dmabit
n_toneportdirec	RS.B	1
n_toneportspeed	RS.B	1
n_wantedperiod	RS.W	1
n_vibratocmd	RS.B	1
n_vibratopos	RS.B	1
n_tremolocmd	RS.B	1
n_tremolopos	RS.B	1
n_wavecontrol	RS.B	1	; E4x/E7x
n_glissfunk	RS.B	1	; E3x / EFx
n_sampleoffset	RS.B	1	; 9xx
n_pattpos	RS.B	1	; E6x
n_loopcount	RS.B	1	; E6x
n_funkoffset	RS.B	1
n_wavestart	RS.L	1	; funk repeat ptr
n_reallength	RS.W	1	; words
;--- pt4 extensions
n_pt4_trigger	RS.B	1	; st after dma start
n_pt4_samplenum	RS.B	1	; 1-31
n_pt4_chanoff	RS.B	1	; <>0: ch off (no notes, no paula access)
n_pt4_chanon	RS.B	1	; not n_pt4_chanoff
n_pt4_samplestart RS.L	1	; from dat_SamplePtrTable
n_pt4_samplelen	RS.W	1	; from smp header
n_pt4_pad52	RS.W	1	; copied with n_pt4_samplelen as long to n_length
n_pt4_chunked	RS.B	1	; <>0: smp in chunks (dat_RpChunkedSamples), refill in audio irq
n_pt4_b55	RS.B	1	; cleared on ch reset
n_pt4_dmawait	RS.B	1	; <>0: dma start phase (irq 1 vol, irq 2 loop)
n_pt4_pad57	RS.B	1	; unused
n_pt4_dmacount	RS.W	1	; audio irqs since dma start
n_pt4_chunklist	RS.L	1	; {adr.l, len.w, x.w}
n_pt4_chunkptr	RS.L	1	; cur chunk -> AUDxLCH/LEN
n_pt4_chunkstart	RS.L	1	; first chunk of cur note
n_pt4_volmul	RS.W	1	; extra vol factor in chunk path, 0 = off
n_pt4_chunkvol	RS.W	1	; vol factor of next chunk
n_pt4_irqvol	RS.W	1	; scaled vol for audio irq
n_pt4_dmacon	RS.W	1
n_pt4_dmaset	RS.W	1	; $8000|n_pt4_dmacon
n_pt4_intmask	RS.W	1	; INTENA/INTREQ value
n_pt4_intena	RS.W	1
n_pt4_chanbit	RS.W	1	; bit no. (btst dat_ScopeConfig)
n_SIZEOF	RS.B	0

	IF	n_SIZEOF<>88
	FAIL	"pt_structs.i: Kanal-Struct muss 88 Byte gross sein"
	ENDC
	IF	(n_period<>16)|(n_volume<>19)|(n_pt4_volscale<>20)|(n_wavestart<>36)|(n_pt4_chanoff<>44)|(n_pt4_chanbit<>86)
	FAIL	"pt_structs.i: Kanal-Struct-Offsets stimmen nicht mit dem Original ueberein"
	ENDC

;--- paula channel (16 bytes)
	RSRESET
aud_LCH		RS.L	1	; AUDxLCH/LCL
aud_LEN		RS.W	1	; words
aud_PER		RS.W	1
aud_VOL		RS.W	1
aud_DAT		RS.W	1
		RS.W	2	; 12 unbenutzt
aud_SIZEOF	RS.B	0

	IF	aud_SIZEOF<>16
	FAIL	"pt_structs.i: Paula-Kanalstruct muss 16 Byte gross sein"
	ENDC

;--- mod sample header (30 bytes)
	RSRESET
s_name		RS.B	22	; 22 chars
s_length	RS.W	1	; words
s_finetune	RS.B	1	; bits 0-3
s_volume	RS.B	1	; 0-64
s_repeat	RS.W	1	; words
s_replen	RS.W	1	; words
s_SIZEOF	RS.B	0

	IF	s_SIZEOF<>30
	FAIL	"pt_structs.i: Sample-Header muss 30 Byte gross sein"
	ENDC

;--- mod song header (1084 bytes)
mod_title	EQU	0	; 20 chars
mod_samples	EQU	20	; 31 headers of 30 bytes
mod_songlen	EQU	950	; 1-128
mod_restart	EQU	951	; pt: 127
mod_positions	EQU	952	; 128 pat numbers
mod_id		EQU	1080	; "M.K.", "8CHN", ...
mod_patterns	EQU	1084	; pattern data
