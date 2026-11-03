pt_RpInterrupt:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	pt_RpDispatch
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_RpDispatch:
	BTST	#3,dat_ModeFlags
	BEQ.S	pt_RpMusic
	LEA	dat_RpSoftInt,A1
	MOVEA.L	ABSEXECBASE.W,A6
	JMP	(-180,A6)
pt_RpMusic:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	JSR	pt_MixMusicEntry
	NOP
	CMP.L	#$70617474,D0
	BEQ.S	pt_RpMusicCount
	MOVE.L	(dat_RpSongPos,PC),dat_BplUpdateReq
pt_RpMusicCount:
	MOVEA.L	(dat_ModulePtr,PC),A0
	MOVE.B	(mod_songlen,A0),dat_BplPtr2
	TST.W	dat_StopRequest
	BNE.S	pt_RpNewRow
	ADDQ.L	#1,dat_RpCounter
	MOVE.L	(dat_RpCounter,PC),D0
	CMP.L	(dat_RpSpeed,PC),D0
	BCS.S	pt_RpNoNewRow
pt_RpNewRow:
	CLR.L	dat_RpCounter
	TST.B	dat_PattDelayCount
	BEQ.W	pt_RpGetNewNote
	BSR.S	pt_RpNoNewAllChannels
	BRA.W	pt_RpNextRow
pt_RpNoNewRow:
	BSR.S	pt_RpNoNewAllChannels
	BRA.W	pt_RpExit
pt_RpNoNewAllChannels:
	JSR	pt_MixLoopInit
	NOP
	NOP
	NOP
	NOP
pt_RpNoNewLoop:
	MOVEM.L	D7,-(A7)
	BSR.W	pt_RpCheckEfxChan
	MOVEM.L	(A7)+,D7
	JSR	pt_MixNextVoice
	NOP
	DBF	D7,pt_RpNoNewLoop
	RTS
pt_RpSetVolume:
	TST.B	(n_pt4_chanoff,A6)
	BEQ.S	pt_RpSetVolumeDirect
	RTS
pt_RpSetVolumeDirect:
	TST.B	(n_pt4_chunked,A6)
	BNE.S	pt_RpSetVolumeChunked
	MOVEQ	#0,D0
	MOVE.B	(n_volume,A6),D0
	MULU.W	(n_pt4_volscale,A6),D0
	ADD.W	#$0020,D0
	LSR.W	#6,D0
	MOVE.W	D0,(aud_VOL,A5)
	RTS
pt_RpSetVolumeChunked:
	MOVEQ	#0,D0
	MOVE.B	(n_volume,A6),D0
	MULU.W	(n_pt4_volscale,A6),D0
	ADD.W	#$0020,D0
	LSR.W	#6,D0
	MOVE.W	D0,(n_pt4_irqvol,A6)
	MOVE.W	D2,-(A7)
	MOVE.W	(n_pt4_volmul,A6),D2
	BNE.S	pt_RpSetVolumeMul
	MOVEQ	#0,D0
	BRA.S	pt_RpSetVolumeWrite
pt_RpSetVolumeMul:
	MULU.W	D2,D0
	ADD.W	#$0020,D0
	LSR.W	#6,D0
	BNE.S	pt_RpSetVolumeWrite
	MOVEQ	#1,D0
pt_RpSetVolumeWrite:
	MOVE.W	D0,(aud_VOL,A5)
	MOVE.W	(A7)+,D2
	RTS
pt_RpGetNewNote:
	LEA	(12,A0),A3
	LEA	(mod_positions,A0),A2
	LEA	(mod_patterns,A0),A0
	MOVEQ	#0,D1
	MOVE.L	(dat_RpSongPos,PC),D0
	MOVE.B	(0,A2,D0.W),D1
	CMPI.L	#$70617474,dat_RpPlayMode
	BNE.S	pt_RpGetNewNotePat
	MOVE.L	(dat_PatTableIdx,PC),D1
pt_RpGetNewNotePat:
	ASL.L	#8,D1
	ASL.L	#2,D1
	BTST	#5,dat_ModeFlags
	BNE.S	pt_RpGetNewNoteAddr
	ASL.L	#1,D1
pt_RpGetNewNoteAddr:
	ADD.L	(dat_RpPatternPos,PC),D1
	MOVE.L	D1,dat_PatBaseAddr
	JSR	pt_MixLoopInit
	NOP
	NOP
	NOP
	NOP
pt_RpGetNewNoteLoop:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	pt_RpPlayVoice
	BSR.W	pt_RpSetVolume
	MOVEM.L	(A7)+,D0-D7/A0-A6
	JSR	pt_MixNextVoice
	NOP
	ADDQ.L	#4,D1
	DBF	D7,pt_RpGetNewNoteLoop
	BRA.W	pt_RpNextRow
pt_RpMetronome:
	ADDQ.B	#1,D2
	CMP.B	dat_RpMetroChannel,D2
	BEQ.S	pt_RpMetronomeInterval
	RTS
pt_RpMetronomeInterval:
	MOVE.B	dat_RpMetroInterval,D2
	BNE.S	pt_RpMetronomeRow
	RTS
pt_RpMetronomeRow:
	AND.W	#$00ff,D2
	MOVE.L	dat_RpPatternPos,D3
	LSR.L	#4,D3
	BTST	#5,dat_ModeFlags
	BNE.S	pt_RpMetronomeDiv
	LSR.L	#1,D3
pt_RpMetronomeDiv:
	DIVU.W	D2,D3
	SWAP	D3
	TST.W	D3
	BEQ.S	pt_RpMetronomeNote
	RTS
pt_RpMetronomeNote:
	ANDI.L	#$00000fff,(A6)
	ORI.L	#$10d6f000,(A6)
	RTS
pt_RpPlayVoice:
	MOVE.B	(n_pt4_chanoff,A6),D5
	BNE.S	pt_RpPlayVoicePeriod
	TST.L	(A6)
	BNE.S	pt_RpReadNote
pt_RpPlayVoicePeriod:
	MOVE.W	(n_period,A6),(aud_PER,A5)
	TST.B	D5
	BEQ.S	pt_RpReadNote
	BSR.S	pt_RpMetronome
	RTS
pt_RpReadNote:
	MOVE.L	(0,A0,D1.L),(A6)
	BSR.S	pt_RpMetronome
	MOVEQ	#0,D2
	MOVE.B	(n_cmd,A6),D2
	AND.B	#$f0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$f0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ.W	pt_RpSetRegs
	MOVEQ	#0,D3
	LEA	(dat_RpSampleStarts,PC),A1
	MOVE.L	dat_RpChunkedSamples,D4
	BTST	D2,D4
	SNE	(n_pt4_chunked,A6)
	MOVE.W	D2,D4
	MOVE.B	D2,(n_pt4_samplenum,A6)
	SUBQ.L	#1,D2
	LSL.L	#2,D2
	MULU.W	#s_SIZEOF,D4
	MOVE.L	(0,A1,D2.L),(n_pt4_samplestart,A6)
	MOVE.L	(n_pt4_samplestart,A6),(n_start,A6)
	MOVE.W	(0,A3,D4.L),(n_pt4_samplelen,A6)
	MOVE.L	(n_pt4_samplelen,A6),(n_length,A6)
	MOVE.W	(0,A3,D4.L),(n_reallength,A6)
	MOVE.B	(2,A3,D4.L),(n_finetune,A6)
	MOVEQ	#0,D0
	MOVE.B	(3,A3,D4.L),D0
	MOVE.B	D0,(n_volume,A6)
	MOVEQ	#0,D3
	MOVE.W	(4,A3,D4.L),D3
	TST.W	D3
	BEQ.S	pt_RpNoLoop
	MOVE.L	(n_start,A6),D2
	ASL.W	#1,D3
	ADD.L	D3,D2
	MOVE.L	D2,(n_loopstart,A6)
	MOVE.L	D2,(n_wavestart,A6)
	MOVE.W	(4,A3,D4.L),D0
	ADD.W	(6,A3,D4.L),D0
	MOVE.W	D0,(n_length,A6)
	MOVE.W	(6,A3,D4.L),(n_replen,A6)
	BRA.S	pt_RpSetRegs
pt_RpNoLoop:
	MOVE.L	(n_start,A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,(n_loopstart,A6)
	MOVE.L	D2,(n_wavestart,A6)
	MOVE.W	(6,A3,D4.L),(n_replen,A6)
pt_RpSetRegs:
	MOVE.W	(A6),D0
	AND.W	#$0fff,D0
	BEQ.W	pt_RpCheckMoreEfx
	MOVE.W	(n_cmd,A6),D0
	AND.W	#$0ff0,D0
	CMP.W	#$0e50,D0
	BEQ.S	pt_RpSetRegsE5
	MOVE.B	(n_cmd,A6),D0
	AND.B	#$0f,D0
	CMP.B	#$03,D0
	BNE.S	pt_RpSetRegs5
	BSR.W	pt_RpSetTonePorta
	BRA.W	pt_RpCheckMoreEfx
pt_RpSetRegs5:
	CMP.B	#$05,D0
	BNE.S	pt_RpSetRegsC
	BSR.W	pt_RpSetTonePorta
	BRA.W	pt_RpCheckMoreEfx
pt_RpSetRegsC:
	CMP.B	#$0c,D0
	BNE.S	pt_RpSetRegs9
	BSR.W	pt_RpVolumeChange
	BRA.S	pt_RpSetPeriod
pt_RpSetRegs9:
	CMP.B	#$09,D0
	BNE.S	pt_RpSetPeriod
	BSR.W	pt_RpCheckMoreEfx
	BRA.S	pt_RpSetPeriod
pt_RpSetRegsE5:
	BSR.W	pt_RpSetFineTune
pt_RpSetPeriod:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	MOVE.W	(A6),D1
	AND.W	#$0fff,D1
	LEA	(dat_PeriodTable,PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D7
pt_RpSetPeriodLoop:
	CMP.W	(0,A1,D0.W),D1
	BCC.S	pt_RpSetPeriodFound
	ADDQ.L	#2,D0
	DBF	D7,pt_RpSetPeriodLoop
pt_RpSetPeriodFound:
	MOVEQ	#0,D1
	MOVE.B	(n_finetune,A6),D1
	AND.B	#$0f,D1
	MULU.W	#$004a,D1
	ADDA.L	D1,A1
	MOVE.W	(0,A1,D0.W),(n_period,A6)
	MOVEM.L	(A7)+,D0-D1/A0-A1
	MOVE.W	(n_cmd,A6),D0
	AND.W	#$0ff0,D0
	CMP.W	#$0ed0,D0
	BEQ.W	pt_RpCheckMoreEfx
	BTST	#2,(n_wavecontrol,A6)
	BNE.S	pt_RpSetPeriodVib
	CLR.B	(n_vibratopos,A6)
pt_RpSetPeriodVib:
	BTST	#6,(n_wavecontrol,A6)
	BNE.S	pt_RpSetPeriodTrem
	CLR.B	(n_tremolopos,A6)
pt_RpSetPeriodTrem:
	TST.B	(n_pt4_chunked,A6)
	BEQ.S	pt_RpStartDma
	BSR.W	pt_RpStartChunked
	BRA.W	pt_RpCheckMoreEfx2
pt_RpStartDma:
	MOVEM.L	D0-D1/A0,-(A7)
	JSR	pt_RpDmaWait
	MOVE.W	dat_RpDmaChanMask,D0
	MOVE.W	(n_pt4_chanbit,A6),D1
	BTST	D1,D0
	BEQ.S	pt_RpStartDmaDone
	ST	(n_pt4_dmawait,A6)
	CLR.W	(n_pt4_dmacount,A6)
	CMPI.W	#$0002,(n_length,A6)
	BLS.S	pt_RpUseSilence
	TST.L	(n_start,A6)
	BNE.S	pt_RpStartDmaRegs
pt_RpUseSilence:
	LEA	chip_ScratchBuffer,A0
	MOVE.L	A0,(n_start,A6)
	MOVE.L	A0,(n_loopstart,A6)
	MOVE.W	#$0010,(n_replen,A6)
	MOVE.W	#$0010,(n_length,A6)
pt_RpStartDmaRegs:
	LEA	HARDBASE,A0
	MOVE.W	(n_pt4_intmask,A6),(154,A0)
	MOVE.W	(n_pt4_intmask,A6),(156,A0)
	MOVE.W	(n_pt4_dmacon,A6),(150,A0)
	MOVE.W	#$0001,(aud_PER,A5)
	CLR.W	(aud_DAT,A5)
	MOVE.L	(n_start,A6),(A5)
	MOVE.W	(n_length,A6),(aud_LEN,A5)
	MOVE.W	(n_pt4_intena,A6),(154,A0)
	ST	(n_pt4_trigger,A6)
pt_RpStartDmaDone:
	MOVEM.L	(A7)+,D0-D1/A0
	BRA.W	pt_RpCheckMoreEfx2
pt_RpStartChunked:
	MOVEM.L	D0-D2/A0-A1,-(A7)
	MOVE.W	#$4000,INTENA
	MOVE.W	dat_RpDmaChanMask,D1
	MOVE.W	(n_pt4_chanbit,A6),D0
	BTST	D0,D1
	BEQ.W	pt_RpStartChunkedDone
	MOVEQ	#0,D1
	MOVE.B	(n_pt4_samplenum,A6),D1
	JSR	pt_BuildChunkList
	MOVEQ	#0,D1
	MOVE.B	(n_volume,A6),D1
	MULU.W	dat_RpMasterVol,D1
	ADD.W	#$0020,D1
	LSR.W	#6,D1
	MOVE.W	D1,(n_pt4_irqvol,A6)
	SF	(n_pt4_dmawait,A6)
	CLR.W	(n_pt4_dmacount,A6)
	ST	(n_pt4_chunked,A6)
	MOVEA.L	(n_pt4_chunklist,A6),A0
	MOVE.L	A0,(n_pt4_chunkptr,A6)
	TST.B	(n_sampleoffset,A6)
	BEQ.S	pt_RpChunkDma
	MOVE.L	(n_start,A6),D1
pt_RpChunkSeek:
	MOVE.L	(A0),D0
	BEQ.S	pt_RpChunkSeekFound
	CMP.L	D0,D1
	BLT.S	pt_RpChunkSeekFound
	ADDQ.W	#8,A0
	BRA.S	pt_RpChunkSeek
pt_RpChunkSeekFound:
	SUBQ.W	#8,A0
	MOVEQ	#0,D0
	MOVE.L	(A0),D0
	SUB.L	D1,D0
	NEG.L	D0
	LSR.L	#1,D0
	SUB.W	D0,(4,A0)
	MOVE.L	D1,(A0)
	MOVE.L	A0,(n_pt4_chunkptr,A6)
	MOVE.W	(n_length,A6),D1
	MOVEQ	#0,D2
pt_RpChunkLenLoop:
	TST.L	(A0)
	BEQ.S	pt_RpChunkDma
	MOVE.W	(4,A0),D0
	ADD.W	D0,D2
	CMP.W	D1,D2
	BCC.S	pt_RpChunkLenCut
	ADDQ.W	#8,A0
	BRA.S	pt_RpChunkLenLoop
pt_RpChunkLenCut:
	SUB.W	D1,D2
	SUB.W	D2,D0
	MOVE.W	D0,(4,A0)
	CLR.L	(8,A0)
pt_RpChunkDma:
	MOVEA.L	(n_pt4_chunkptr,A6),A1
	LEA	HARDBASE,A0
	MOVE.W	(2,A0),D0
	MOVE.W	(n_pt4_chanbit,A6),D1
	BTST	D1,D0
	BNE.S	pt_RpChunkDmaOn
	MOVE.W	(n_pt4_intmask,A6),(154,A0)
	BRA.S	pt_RpChunkDmaRegs
pt_RpChunkDmaOn:
	MOVE.W	(n_pt4_intmask,A6),(154,A0)
	MOVE.W	(n_pt4_dmacon,A6),(150,A0)
	MOVE.W	(n_pt4_intmask,A6),(156,A0)
pt_RpChunkDmaRegs:
	MOVE.W	#$0001,(aud_PER,A5)
	MOVE.L	(A1)+,(A5)
	MOVE.W	(A1),(aud_LEN,A5)
	CLR.W	(aud_VOL,A5)
	MOVE.W	(n_pt4_intena,A6),(154,A0)
	ST	(n_pt4_trigger,A6)
pt_RpStartChunkedDone:
	MOVEM.L	(A7)+,D0-D2/A0-A1
	MOVE.W	#$c000,INTENA
	RTS
pt_RpNextRow:
	TST.L	dat_RpPlayMode
	BEQ.S	pt_RpNextRowAdvance
	JSR	pt_PatViewSetRowReplayer
pt_RpNextRowAdvance:
	MOVE.L	(dat_RpPatternPos,PC),D0
	LSR.L	#4,D0
	MOVE.W	D0,dat_PatternPosition
	MOVEQ	#4,D0
	MULU.W	dat_RpNumChannels,D0
	ADD.L	D0,dat_RpPatternPos
	MOVE.B	dat_PattDelayTime,D0
	BEQ.S	pt_RpNextRowDelay
	MOVE.B	D0,dat_PattDelayCount
	CLR.B	dat_PattDelayTime
pt_RpNextRowDelay:
	TST.B	dat_PattDelayCount
	BEQ.S	pt_RpNextRowLoop
	SUBQ.B	#1,dat_PattDelayCount
	BEQ.S	pt_RpNextRowLoop
	MOVEQ	#4,D0
	MULU.W	dat_RpNumChannels,D0
	SUB.L	D0,dat_RpPatternPos
pt_RpNextRowLoop:
	TST.B	dat_RpPBreakFlag
	BEQ.S	pt_RpNextRowRedraw
	SF	dat_RpPBreakFlag
	MOVEQ	#0,D0
	MOVE.B	(dat_RpBreakRow,PC),D0
	LSL.W	#4,D0
	MOVE.L	D0,dat_RpPatternPos
	CLR.B	dat_RpBreakRow
pt_RpNextRowRedraw:
	TST.W	dat_StopRequest
	BEQ.S	pt_RpNextRowEnd
	JSR	pt_StopPlayback
	CLR.W	dat_StopRequest
	MOVE.L	(dat_RpPatternPos,PC),D0
	LSR.L	#4,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_RpNextRowRedraw2
	LSR.L	#1,D0
pt_RpNextRowRedraw2:
	AND.W	#$003f,D0
	MOVE.W	D0,dat_PatternPosition
pt_RpNextRowEnd:
	BTST	#5,dat_ModeFlags
	BEQ.S	pt_RpNextRowEnd8
	CMPI.L	#$00000400,dat_RpPatternPos
	BNE.W	pt_RpExit
	BRA.S	pt_RpNextPosition
pt_RpNextRowEnd8:
	CMPI.L	#$00000800,dat_RpPatternPos
	BNE.W	pt_RpExit
pt_RpNextPosition:
	MOVEQ	#0,D0
	MOVE.B	(dat_RpBreakRow,PC),D0
	LSL.W	#4,D0
	MOVE.L	D0,dat_RpPatternPos
	CLR.B	dat_RpBreakRow
	CLR.B	dat_PosJumpFlag
	CMPI.L	#$70617470,dat_RpPlayMode
	BNE.S	pt_RpExit
	ADDQ.L	#1,dat_RpSongPos
	ST	dat_NextPosFlag
	ANDI.L	#$0000007f,dat_RpSongPos
	MOVE.L	(dat_RpSongPos,PC),D1
	MOVEA.L	(dat_ModulePtr,PC),A0
	CMP.B	(mod_songlen,A0),D1
	BCS.S	pt_RpExit
	CLR.L	dat_RpSongPos
	TST.W	dat_StopRequest
	BEQ.S	pt_RpExit
	JSR	pt_StopPlayback
	CLR.W	dat_StopRequest
	MOVE.L	(dat_RpPatternPos,PC),D0
	LSR.L	#4,D0
	MOVE.W	D0,dat_PatternPosition
pt_RpExit:
	TST.B	dat_PosJumpFlag
	BNE.W	pt_RpNextPosition
	IFD	DEBUGFX
	JSR	dbg_FxTick
	ENDC
	JMP	pt_MixTickExit
pt_RpCheckEfxChan:
	TST.B	(n_pt4_chanoff,A6)
	BEQ.S	pt_RpCheckEfxChanOn
	RTS
pt_RpCheckEfxChanOn:
	BSR.S	pt_RpCheckEfx
	JMP	pt_Efx8SetVolume
pt_RpCheckEfx:
	BSR.W	pt_RpUpdateFunk
	JSR	pt_Efx8Tick
	NOP
	BNE.S	pt_RpCheckEfxDispatch
	RTS
pt_RpCheckEfxDispatch:
	MOVE.B	(n_cmd,A6),D0
	AND.B	#$0f,D0
	TST.B	D0
	BEQ.S	pt_RpArpeggio
	CMP.B	#$01,D0
	BEQ.W	pt_RpPortaUp
	CMP.B	#$02,D0
	BEQ.W	pt_RpPortaDown
	CMP.B	#$03,D0
	BEQ.W	pt_RpTonePortamento
	CMP.B	#$04,D0
	BEQ.W	pt_RpVibrato
	CMP.B	#$05,D0
	BEQ.W	pt_RpTonePlusVolSlide
	CMP.B	#$06,D0
	BEQ.W	pt_RpVibratoPlusVolSlide
	CMP.B	#$0e,D0
	BEQ.W	pt_RpECommands
	MOVE.W	(n_period,A6),(aud_PER,A5)
	CMP.B	#$07,D0
	BEQ.W	pt_RpTremolo
	CMP.B	#$0a,D0
	BEQ.W	pt_RpVolumeSlide
	CMP.B	#$08,D0
	BEQ.W	pt_RpEfx8Color
	RTS
pt_RpPerNop:
	MOVE.W	(n_period,A6),(aud_PER,A5)
	RTS
pt_RpArpeggio:
	MOVEQ	#0,D0
	MOVE.L	(dat_RpCounter,PC),D0
	DIVS.W	#$0003,D0
	SWAP	D0
	CMP.W	#$0001,D0
	BEQ.S	pt_RpArpeggio1
	CMP.W	#$0002,D0
	BEQ.S	pt_RpArpeggio2
	MOVE.W	(n_period,A6),D2
	BRA.S	pt_RpArpeggioSet
pt_RpArpeggio1:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	LSR.B	#4,D0
	BRA.S	pt_RpArpeggioFind
pt_RpArpeggio2:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
pt_RpArpeggioFind:
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	(n_finetune,A6),D1
	AND.B	#$0f,D1
	MULU.W	#$004a,D1
	LEA	(dat_PeriodTable,PC),A0
	ADDA.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	(n_period,A6),D1
	MOVEQ	#36,D7
pt_RpArpeggioLoop:
	MOVE.W	(0,A0,D0.W),D2
	CMP.W	(A0),D1
	BCC.S	pt_RpArpeggioSet
	ADDQ.L	#2,A0
	DBF	D7,pt_RpArpeggioLoop
	RTS
pt_RpArpeggioSet:
	IFD	DEBUGFX
	JSR	dbg_FxPer2
	ELSE
	MOVE.W	D2,(aud_PER,A5)
	ENDC
	RTS
pt_RpFinePortaUp:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpFinePortaUp2
	RTS
pt_RpFinePortaUp2:
	MOVE.B	#$0f,dat_LowMask
pt_RpPortaUp:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	dat_LowMask,D0
	MOVE.B	#$ff,dat_LowMask
	SUB.W	D0,(n_period,A6)
	MOVE.W	(n_period,A6),D0
	AND.W	#$0fff,D0
	CMP.W	#$0071,D0
	BPL.S	pt_RpPortaUpSet
	ANDI.W	#$f000,(n_period,A6)
	ORI.W	#$0071,(n_period,A6)
pt_RpPortaUpSet:
	MOVE.W	(n_period,A6),D0
	AND.W	#$0fff,D0
	MOVE.W	D0,(aud_PER,A5)
	RTS
pt_RpFinePortaDown:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpFinePortaDown2
	RTS
pt_RpFinePortaDown2:
	MOVE.B	#$0f,dat_LowMask
pt_RpPortaDown:
	CLR.W	D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	dat_LowMask,D0
	MOVE.B	#$ff,dat_LowMask
	ADD.W	D0,(n_period,A6)
	MOVE.W	(n_period,A6),D0
	AND.W	#$0fff,D0
	CMP.W	#$0358,D0
	BMI.S	pt_RpPortaDownSet
	ANDI.W	#$f000,(n_period,A6)
	ORI.W	#$0358,(n_period,A6)
pt_RpPortaDownSet:
	MOVE.W	(n_period,A6),D0
	AND.W	#$0fff,D0
	MOVE.W	D0,(aud_PER,A5)
	RTS
pt_RpSetTonePorta:
	MOVE.L	A0,-(A7)
	MOVE.W	(A6),D2
	AND.W	#$0fff,D2
	MOVEQ	#0,D0
	MOVE.B	(n_finetune,A6),D0
	AND.B	#$0f,D0
	MULU.W	#$004a,D0
	LEA	(dat_PeriodTable,PC),A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
pt_RpSetTonePortaLoop:
	CMP.W	(0,A0,D0.W),D2
	BCC.S	pt_RpSetTonePortaFtu
	ADDQ.W	#2,D0
	CMP.W	#$004a,D0
	BCS.S	pt_RpSetTonePortaLoop
	MOVEQ	#70,D0
pt_RpSetTonePortaFtu:
	MOVE.B	(n_finetune,A6),D2
	AND.B	#$08,D2
	BEQ.S	pt_RpSetTonePortaDir
	TST.W	D0
	BEQ.S	pt_RpSetTonePortaDir
	SUBQ.W	#2,D0
pt_RpSetTonePortaDir:
	MOVE.W	(0,A0,D0.W),D2
	MOVEA.L	(A7)+,A0
	MOVE.W	D2,(n_wantedperiod,A6)
	MOVE.W	(n_period,A6),D0
	CLR.B	(n_toneportdirec,A6)
	CMP.W	D0,D2
	BEQ.S	pt_RpSetTonePortaClear
	BLT.S	pt_RpSetTonePortaUp
	RTS
pt_RpSetTonePortaUp:
	MOVE.B	#$01,(n_toneportdirec,A6)
	RTS
pt_RpSetTonePortaClear:
	CLR.W	(n_wantedperiod,A6)
	RTS
pt_RpTonePortamento:
	MOVE.B	(n_cmdlo,A6),D0
	BEQ.S	pt_RpTonePortNoChange
	MOVE.B	D0,(n_toneportspeed,A6)
	CLR.B	(n_cmdlo,A6)
pt_RpTonePortNoChange:
	TST.W	(n_wantedperiod,A6)
	BNE.S	pt_RpTonePortSlide
	RTS
pt_RpTonePortSlide:
	MOVEQ	#0,D0
	MOVE.B	(n_toneportspeed,A6),D0
	TST.B	(n_toneportdirec,A6)
	BNE.S	pt_RpTonePortaDown2
	ADD.W	D0,(n_period,A6)
	MOVE.W	(n_wantedperiod,A6),D0
	CMP.W	(n_period,A6),D0
	BGT.S	pt_RpTonePortaSetPer
	MOVE.W	(n_wantedperiod,A6),(n_period,A6)
	CLR.W	(n_wantedperiod,A6)
	BRA.S	pt_RpTonePortaSetPer
pt_RpTonePortaDown2:
	SUB.W	D0,(n_period,A6)
	MOVE.W	(n_wantedperiod,A6),D0
	CMP.W	(n_period,A6),D0
	BLT.S	pt_RpTonePortaSetPer
	MOVE.W	(n_wantedperiod,A6),(n_period,A6)
	CLR.W	(n_wantedperiod,A6)
pt_RpTonePortaSetPer:
	MOVE.W	(n_period,A6),D2
	MOVE.B	(n_glissfunk,A6),D0
	AND.B	#$0f,D0
	BEQ.S	pt_RpGlissSkip
	MOVEQ	#0,D0
	MOVE.B	(n_finetune,A6),D0
	AND.B	#$0f,D0
	MULU.W	#$004a,D0
	LEA	(dat_PeriodTable,PC),A0
	ADDA.L	D0,A0
	MOVEQ	#0,D0
pt_RpGlissLoop:
	CMP.W	(0,A0,D0.W),D2
	BCC.S	pt_RpGlissFound
	ADDQ.W	#2,D0
	CMP.W	#$004a,D0
	BCS.S	pt_RpGlissLoop
	MOVEQ	#70,D0
pt_RpGlissFound:
	MOVE.W	(0,A0,D0.W),D2
pt_RpGlissSkip:
	MOVE.W	D2,(aud_PER,A5)
	RTS
pt_RpVibrato:
	MOVE.B	(n_cmdlo,A6),D0
	BEQ.S	pt_RpVibrato2
	MOVE.B	(n_vibratocmd,A6),D2
	AND.B	#$0f,D0
	BEQ.S	pt_RpVibratoSpeed
	AND.B	#$f0,D2
	OR.B	D0,D2
pt_RpVibratoSpeed:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$f0,D0
	BEQ.S	pt_RpVibratoStore
	AND.B	#$0f,D2
	OR.B	D0,D2
pt_RpVibratoStore:
	MOVE.B	D2,(n_vibratocmd,A6)
pt_RpVibrato2:
	MOVE.L	A4,-(A7)
	MOVE.B	(n_vibratopos,A6),D0
	LEA	(dat_RpVibratoTable,PC),A4
	LSR.W	#2,D0
	AND.W	#$001f,D0
	MOVEQ	#0,D2
	MOVE.B	(n_wavecontrol,A6),D2
	AND.B	#$03,D2
	BEQ.S	pt_RpVibratoSine
	LSL.B	#3,D0
	CMP.B	#$01,D2
	BEQ.S	pt_RpVibratoRampDown
	MOVE.B	#$ff,D2
	BRA.S	pt_RpVibratoApply
pt_RpVibratoRampDown:
	TST.B	(n_vibratopos,A6)
	BPL.S	pt_RpVibratoSet
	MOVE.B	#$ff,D2
	SUB.B	D0,D2
	BRA.S	pt_RpVibratoApply
pt_RpVibratoSet:
	MOVE.B	D0,D2
	BRA.S	pt_RpVibratoApply
pt_RpVibratoSine:
	MOVE.B	(0,A4,D0.W),D2
pt_RpVibratoApply:
	MOVE.B	(n_vibratocmd,A6),D0
	AND.W	#$000f,D0
	MULU.W	D0,D2
	LSR.W	#7,D2
	MOVE.W	(n_period,A6),D0
	TST.B	(n_vibratopos,A6)
	BMI.S	pt_RpVibratoNeg
	ADD.W	D2,D0
	BRA.S	pt_RpVibratoWrite
pt_RpVibratoNeg:
	SUB.W	D2,D0
pt_RpVibratoWrite:
	IFD	DEBUGFX
	JSR	dbg_FxPer0
	ELSE
	MOVE.W	D0,(aud_PER,A5)
	ENDC
	MOVE.B	(n_vibratocmd,A6),D0
	LSR.W	#2,D0
	AND.W	#$003c,D0
	ADD.B	D0,(n_vibratopos,A6)
	MOVEA.L	(A7)+,A4
	RTS
pt_RpTonePlusVolSlide:
	BSR.W	pt_RpTonePortNoChange
	BRA.W	pt_RpVolumeSlide
pt_RpVibratoPlusVolSlide:
	BSR.S	pt_RpVibrato2
	BRA.W	pt_RpVolumeSlide
pt_RpTremolo:
	MOVE.L	A4,-(A7)
	MOVE.B	(n_cmdlo,A6),D0
	BEQ.S	pt_RpTremolo2
	MOVE.B	(n_tremolocmd,A6),D2
	AND.B	#$0f,D0
	BEQ.S	pt_RpTremoloSpeed
	AND.B	#$f0,D2
	OR.B	D0,D2
pt_RpTremoloSpeed:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$f0,D0
	BEQ.S	pt_RpTremoloStore
	AND.B	#$0f,D2
	OR.B	D0,D2
pt_RpTremoloStore:
	MOVE.B	D2,(n_tremolocmd,A6)
pt_RpTremolo2:
	MOVE.B	(n_tremolopos,A6),D0
	LEA	(dat_RpVibratoTable,PC),A4
	LSR.W	#2,D0
	AND.W	#$001f,D0
	MOVEQ	#0,D2
	MOVE.B	(n_wavecontrol,A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	pt_RpTremoloSine
	LSL.B	#3,D0
	CMP.B	#$01,D2
	BEQ.S	pt_RpTremoloRampDown
	MOVE.B	#$ff,D2
	BRA.S	pt_RpTremoloApply
pt_RpTremoloRampDown:
	TST.B	(n_vibratopos,A6)
	BPL.S	pt_RpTremoloSet
	MOVE.B	#$ff,D2
	SUB.B	D0,D2
	BRA.S	pt_RpTremoloApply
pt_RpTremoloSet:
	MOVE.B	D0,D2
	BRA.S	pt_RpTremoloApply
pt_RpTremoloSine:
	MOVE.B	(0,A4,D0.W),D2
pt_RpTremoloApply:
	MOVE.B	(n_tremolocmd,A6),D0
	AND.W	#$000f,D0
	MULU.W	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	(n_volume,A6),D0
	TST.B	(n_tremolopos,A6)
	BMI.S	pt_RpTremoloNeg
	ADD.W	D2,D0
	BRA.S	pt_RpTremoloClamp
pt_RpTremoloNeg:
	SUB.W	D2,D0
pt_RpTremoloClamp:
	BPL.S	pt_RpTremoloMax
	CLR.W	D0
pt_RpTremoloMax:
	CMP.W	#$0040,D0
	BLS.S	pt_RpTremoloWrite
	MOVE.W	#$0040,D0
pt_RpTremoloWrite:
	MULU.W	(dat_RpMasterVol,PC),D0
	ADD.L	#$00000020,D0
	LSR.L	#6,D0
	IFD	DEBUGFX
	JSR	dbg_FxVol0
	ELSE
	MOVE.W	D0,(aud_VOL,A5)
	ENDC
	MOVE.B	(n_tremolocmd,A6),D0
	LSR.W	#2,D0
	AND.W	#$003c,D0
	ADD.B	D0,(n_tremolopos,A6)
	MOVEA.L	(A7)+,A4
	ADDQ.L	#4,A7
	RTS
pt_RpSampleOffset:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	BEQ.S	pt_RpSampleOffset2
	MOVE.B	D0,(n_sampleoffset,A6)
pt_RpSampleOffset2:
	MOVE.B	(n_sampleoffset,A6),D0
	LSL.L	#7,D0
	CMP.W	(n_length,A6),D0
	BGE.S	pt_RpSampleOffsetEnd
	MOVE.W	(n_pt4_samplelen,A6),D1
	SUB.W	D0,D1
	MOVE.W	D1,(n_length,A6)
	ADD.L	D0,D0
	ADD.L	(n_pt4_samplestart,A6),D0
	MOVE.L	D0,(n_start,A6)
	RTS
pt_RpSampleOffsetEnd:
	MOVE.W	#$0001,(n_length,A6)
	RTS
pt_RpVolumeSlide:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	pt_RpVolSlideDown
pt_RpVolSlideUp:
	ADD.B	D0,(n_volume,A6)
	CMPI.B	#$40,(n_volume,A6)
	BMI.S	pt_RpVolSlideUpDone
	MOVE.B	#$40,(n_volume,A6)
pt_RpVolSlideUpDone:
	MOVE.B	(n_volume,A6),D0
	RTS
pt_RpVolSlideDown:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
pt_RpVolSlideDown2:
	SUB.B	D0,(n_volume,A6)
	BPL.S	pt_RpVolSlideDownDone
	CLR.B	(n_volume,A6)
pt_RpVolSlideDownDone:
	MOVE.B	(n_volume,A6),D0
	RTS
pt_RpPositionJump:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	SUBQ.B	#1,D0
	MOVE.L	D0,dat_RpSongPos
pt_RpPositionJumpSet:
	CLR.B	dat_RpBreakRow
	ST	dat_PosJumpFlag
	RTS
pt_RpVolumeChange:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	CMP.B	#$40,D0
	BLS.S	pt_RpVolumeChangeSet
	MOVEQ	#64,D0
pt_RpVolumeChangeSet:
	MOVE.B	D0,(n_volume,A6)
	RTS
pt_RpPatternBreak:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU.W	#$000a,D0
	AND.B	#$0f,D2
	ADD.B	D2,D0
	BTST	#5,dat_ModeFlags
	BNE.S	pt_RpPatternBreak4
	LSL.W	#1,D0
	CMP.B	#$7e,D0
	BHI.S	pt_RpPositionJumpSet
	BRA.S	pt_RpPatternBreakSet
pt_RpPatternBreak4:
	CMP.B	#$3f,D0
	BHI.S	pt_RpPositionJumpSet
pt_RpPatternBreakSet:
	MOVE.B	D0,dat_RpBreakRow
	ST	dat_PosJumpFlag
	RTS
pt_RpSetSpeed:
	MOVE.B	(n_cmdlo,A6),D0
	AND.W	#$00ff,D0
	BEQ.S	pt_RpSetSpeedStop
	BTST	#0,dat_ModeFlags
	BEQ.S	pt_RpSetSpeedTicks
	CMP.W	#$0020,D0
	BCS.S	pt_RpSetSpeedTicks
	MOVE.W	D0,dat_CurrentTempo
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.W	(dat_SamplerActive,PC),-(A7)
	ST	dat_SamplerActive
	ST	dat_TempoChanged
	JSR	pt_SetTempo
	MOVE.W	(A7)+,dat_SamplerActive
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
pt_RpSetSpeedTicks:
	CLR.L	dat_RpCounter
	MOVE.W	D0,dat_RpSpeedLo
	RTS
pt_RpSetSpeedStop:
	IFD	DEBUGAUTO
	JSR	dbg_F00Stop
	ELSE
	CLR.L	dat_RpPlayMode
	ENDC
	JSR	pt_SetPaletteBright
	RTS
pt_RpEfx8Color:
	JSR	pt_Efx8Set
	NOP
	LSR.B	#4,D0
	CMP.B	#$01,D0
	BEQ.S	pt_RpEfx8Color1
	CMP.B	#$02,D0
	BEQ.S	pt_RpEfx8Color2
	CMP.B	#$03,D0
	BEQ.W	pt_RpEfx8Color3
	CMP.B	#$04,D0
	BEQ.W	pt_RpEfx8Color4
	CMP.B	#$05,D0
	BEQ.W	pt_RpEfx8Color5
	CMP.B	#$06,D0
	BEQ.W	pt_RpEfx8Color6
	CMP.B	#$07,D0
	BEQ.W	pt_RpEfx8Color7
	CMP.B	#$08,D0
	BEQ.W	pt_RpEfx8Color8
	CMP.B	#$09,D0
	BEQ.W	pt_RpEfx8Color9
	CMP.B	#$0a,D0
	BEQ.W	pt_RpEfx8ColorA
	CMP.B	#$0b,D0
	BEQ.W	pt_RpEfx8ColorB
	CMP.B	#$0c,D0
	BEQ.W	pt_RpEfx8ColorC
	CMP.B	#$0d,D0
	BEQ.W	pt_RpEfx8ColorD
	CMP.B	#$0e,D0
	BEQ.W	pt_RpEfx8ColorE
	CMP.B	#$0f,D0
	BEQ.W	pt_RpEfx8ColorF
	RTS
pt_RpEfx8Color1:
	MOVE.W	#$f000,COLOR00
	RTS
pt_RpEfx8Color2:
	MOVE.W	#$fd00,COLOR00
	RTS
pt_RpEfx8Color3:
	MOVE.W	#$ffa0,COLOR00
	RTS
pt_RpEfx8Color4:
	MOVE.W	#$ff0a,COLOR00
	RTS
pt_RpEfx8Color5:
	MOVE.W	#$0ff0,COLOR00
	RTS
pt_RpEfx8Color6:
	MOVE.W	#$0f0f,COLOR00
	RTS
pt_RpEfx8Color7:
	MOVE.W	#$00ff,COLOR00
	RTS
pt_RpEfx8Color8:
	MOVE.W	#$fff0,COLOR00
	RTS
pt_RpEfx8Color9:
	MOVE.W	#$aa0a,COLOR00
	RTS
pt_RpEfx8ColorA:
	MOVE.W	#$7777,COLOR00
	RTS
pt_RpEfx8ColorB:
	MOVE.W	#$1ffd,COLOR00
	RTS
pt_RpEfx8ColorC:
	MOVE.W	#$ff04,COLOR00
	RTS
pt_RpEfx8ColorD:
	MOVE.W	#$4f4f,COLOR00
	RTS
pt_RpEfx8ColorE:
	MOVE.W	#$f4f4,COLOR00
	RTS
pt_RpEfx8ColorF:
	MOVE.W	#$ffff,COLOR00
	RTS
pt_RpCheckMoreEfx:
	MOVE.B	(n_cmd,A6),D0
	AND.B	#$0f,D0
	CMP.B	#$09,D0
	BEQ.W	pt_RpSampleOffset
	CMP.B	#$0b,D0
	BEQ.W	pt_RpPositionJump
	CMP.B	#$0d,D0
	BEQ.W	pt_RpPatternBreak
	CMP.B	#$0e,D0
	BEQ.S	pt_RpECommands
	CMP.B	#$0f,D0
	BEQ.W	pt_RpSetSpeed
	CMP.B	#$0c,D0
	BEQ.W	pt_RpVolumeChange
	BRA.W	pt_RpPerNop
pt_RpCheckMoreEfx2:
	MOVE.B	(n_cmd,A6),D0
	AND.B	#$0f,D0
	CMP.B	#$0b,D0
	BEQ.W	pt_RpPositionJump
	CMP.B	#$0d,D0
	BEQ.W	pt_RpPatternBreak
	CMP.B	#$0e,D0
	BEQ.S	pt_RpECommands
	CMP.B	#$0f,D0
	BEQ.W	pt_RpSetSpeed
	RTS
pt_RpECommands:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$f0,D0
	LSR.B	#4,D0
	BEQ.S	pt_RpFilterOnOff
	CMP.B	#$01,D0
	BEQ.W	pt_RpFinePortaUp
	CMP.B	#$02,D0
	BEQ.W	pt_RpFinePortaDown
	CMP.B	#$03,D0
	BEQ.S	pt_RpSetGlissControl
	CMP.B	#$04,D0
	BEQ.W	pt_RpSetVibratoControl
	CMP.B	#$05,D0
	BEQ.W	pt_RpSetFineTune
	CMP.B	#$06,D0
	BEQ.W	pt_RpJumpLoop
	CMP.B	#$07,D0
	BEQ.W	pt_RpSetTremoloControl
	CMP.B	#$0e,D0
	BEQ.W	pt_RpPatternDelay
	CMP.B	#$09,D0
	BEQ.W	pt_RpRetrigNote
	CMP.B	#$0a,D0
	BEQ.W	pt_RpVolumeFineUp
	CMP.B	#$0b,D0
	BEQ.W	pt_RpVolumeFineDown
	CMP.B	#$0c,D0
	BEQ.W	pt_RpNoteCut
	CMP.B	#$0d,D0
	BEQ.W	pt_RpNoteDelay
	CMP.B	#$0f,D0
	BEQ.W	pt_RpFunkIt
	RTS
pt_RpFilterOnOff:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$01,D0
	ASL.B	#1,D0
	ANDI.B	#$fd,CIAA_PRA
	OR.B	D0,CIAA_PRA
	RTS
pt_RpSetGlissControl:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	ANDI.B	#$f0,(n_glissfunk,A6)
	OR.B	D0,(n_glissfunk,A6)
	RTS
pt_RpSetVibratoControl:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	ANDI.B	#$f0,(n_wavecontrol,A6)
	OR.B	D0,(n_wavecontrol,A6)
	RTS
pt_RpSetFineTune:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	MOVE.B	D0,(n_finetune,A6)
	RTS
pt_RpJumpLoop:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpJumpLoop2
	RTS
pt_RpJumpLoop2:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	BEQ.S	pt_RpSetLoopRow
	TST.B	(n_loopcount,A6)
	BEQ.S	pt_RpJumpLoopStart
	SUBQ.B	#1,(n_loopcount,A6)
	BNE.S	pt_RpJumpLoopGo
	RTS
pt_RpJumpLoopGo:
	MOVE.B	(n_pattpos,A6),dat_RpBreakRow
	ST	dat_RpPBreakFlag
	RTS
pt_RpJumpLoopStart:
	MOVE.B	D0,(n_loopcount,A6)
	BRA.S	pt_RpJumpLoopGo
pt_RpSetLoopRow:
	BTST	#5,dat_ModeFlags
	BNE.S	pt_RpSetLoopRow4
	MOVE.L	dat_RpPatternPos,D0
	LSR.L	#4,D0
	AND.B	#$7e,D0
	MOVE.B	D0,(n_pattpos,A6)
	RTS
pt_RpSetLoopRow4:
	MOVE.L	dat_RpPatternPos,D0
	LSR.L	#4,D0
	AND.B	#$3f,D0
	MOVE.B	D0,(n_pattpos,A6)
	RTS
pt_RpSetTremoloControl:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	LSL.B	#4,D0
	ANDI.B	#$0f,(n_wavecontrol,A6)
	OR.B	D0,(n_wavecontrol,A6)
	RTS
	SUBQ.W	#2,D0
pt_RpRetrigNote:
	MOVE.L	D1,-(A7)
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	BEQ.W	pt_RpRetrigExit
	MOVE.L	dat_RpCounter,D1
	BNE.S	pt_RpRetrigCount
	MOVE.W	(A6),D1
	AND.W	#$0fff,D1
	BNE.S	pt_RpRetrigExit
	MOVE.L	dat_RpCounter,D1
pt_RpRetrigCount:
	DIVU.W	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	pt_RpRetrigExit
pt_RpDoRetrig:
	TST.B	(n_pt4_chunked,A6)
	BNE.S	pt_RpDoRetrigChunked
	MOVE.L	A0,-(A7)
	MOVE.W	dat_RpDmaChanMask,D0
	MOVE.W	(n_pt4_chanbit,A6),D1
	BTST	D1,D0
	BEQ.S	pt_RpDoRetrigDone
	LEA	HARDBASE,A0
	ST	(n_pt4_dmawait,A6)
	CLR.W	(n_pt4_dmacount,A6)
	MOVE.W	(2,A0),D0
	BTST	D1,D0
	BNE.S	pt_RpDoRetrigDmaOn
	MOVE.W	(n_pt4_intmask,A6),(154,A0)
	BRA.S	pt_RpDoRetrigRegs
pt_RpDoRetrigDmaOn:
	MOVE.W	(n_pt4_intmask,A6),(154,A0)
	MOVE.W	(n_pt4_intmask,A6),(156,A0)
	MOVE.W	(n_pt4_dmacon,A6),(150,A0)
pt_RpDoRetrigRegs:
	MOVE.W	#$0001,(aud_PER,A5)
	MOVE.L	(n_start,A6),(A5)
	MOVE.W	(n_length,A6),(aud_LEN,A5)
	MOVE.W	(n_pt4_intena,A6),(154,A0)
	ST	(n_pt4_trigger,A6)
pt_RpDoRetrigDone:
	MOVEA.L	(A7)+,A0
	BRA.S	pt_RpRetrigExit
pt_RpDoRetrigChunked:
	BSR.W	pt_RpStartChunked
pt_RpRetrigExit:
	MOVE.L	(A7)+,D1
	RTS
pt_RpVolumeFineUp:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpVolumeFineUp2
	RTS
pt_RpVolumeFineUp2:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	BRA.W	pt_RpVolSlideUp
pt_RpVolumeFineDown:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpVolumeFineDown2
	RTS
pt_RpVolumeFineDown2:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	BRA.W	pt_RpVolSlideDown2
pt_RpNoteCut:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	CMP.L	dat_RpCounter,D0
	BEQ.S	pt_RpNoteCutNow
	RTS
pt_RpNoteCutNow:
	CLR.B	(n_volume,A6)
	RTS
pt_RpNoteDelay:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	CMP.L	dat_RpCounter,D0
	BEQ.S	pt_RpNoteDelayCheck
	RTS
pt_RpNoteDelayCheck:
	MOVE.W	(A6),D0
	AND.W	#$0fff,D0
	BNE.S	pt_RpNoteDelayGo
	RTS
pt_RpNoteDelayGo:
	MOVE.L	D1,-(A7)
	BRA.W	pt_RpDoRetrig
pt_RpPatternDelay:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpPatternDelay2
	RTS
pt_RpPatternDelay2:
	MOVEQ	#0,D0
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	TST.B	dat_PattDelayCount
	BEQ.S	pt_RpPatternDelaySet
	RTS
pt_RpPatternDelaySet:
	ADDQ.B	#1,D0
	MOVE.B	D0,dat_PattDelayTime
	RTS
pt_RpFunkIt:
	TST.L	dat_RpCounter
	BEQ.S	pt_RpFunkIt2
	RTS
pt_RpFunkIt2:
	MOVE.B	(n_cmdlo,A6),D0
	AND.B	#$0f,D0
	LSL.B	#4,D0
	ANDI.B	#$0f,(n_glissfunk,A6)
	OR.B	D0,(n_glissfunk,A6)
	TST.B	D0
	BNE.S	pt_RpUpdateFunk
	RTS
pt_RpUpdateFunk:
	MOVEM.L	D1/A0,-(A7)
	MOVEQ	#0,D0
	MOVE.B	(n_glissfunk,A6),D0
	LSR.B	#4,D0
	BEQ.S	pt_RpUpdateFunkDone
	LEA	(dat_RpFunkTable,PC),A0
	MOVE.B	(0,A0,D0.W),D0
	ADD.B	D0,(n_funkoffset,A6)
	BTST	#7,(n_funkoffset,A6)
	BEQ.S	pt_RpUpdateFunkDone
	CLR.B	(n_funkoffset,A6)
	MOVE.L	(n_loopstart,A6),D0
	MOVEQ	#0,D1
	MOVE.W	(n_replen,A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVEA.L	(n_wavestart,A6),A0
	ADDQ.L	#1,A0
	CMPA.L	D0,A0
	BCS.S	pt_RpUpdateFunkInvert
	MOVEA.L	(n_loopstart,A6),A0
pt_RpUpdateFunkInvert:
	MOVE.L	A0,(n_wavestart,A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
pt_RpUpdateFunkDone:
	MOVEM.L	(A7)+,D1/A0
	RTS
