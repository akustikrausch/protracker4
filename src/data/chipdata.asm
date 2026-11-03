	SECTION S_2,DATA,CHIP

SECSTRT_2:
	DS.L	4
chip_ScratchBuffer:
	DS.L	6
dat_1489:
	DS.L	880
dat_148A:
	DS.L	116
dat_148B:
	DS.B	1
dat_148C:
	DS.B	1
	DS.L	1753
	DS.W	1
dat_148D:
	DS.L	342
	DS.B	1
dat_148E:
	DS.B	1
	DS.L	2017
	DS.W	1
	SHIFTPADBIG	6
chip_ScreenBitplanes:
	DS.L	5120
	SHIFTPADBIG	7
chip_FontNormal:
	DC.L	$0030cc48,$78cc6030,$30c06c30,$0000000c
	DC.L	$7830f8f8,$ccfc7cfc,$78786060,$300060f8
	DC.L	$0078f878,$f8fcfc7c,$ccfc0ccc,$c084cc78
	DC.L	$f878f87c,$fccccccc,$ccccfcf0,$0cf02000
	DC.L	$60000000
	DS.L	6
	DC.L	$02000000,$0030ccfc,$a0d89060,$60603830
	DC.L	$00000018,$dc700c0c,$ccc0c00c,$cccc6060
	DC.L	$60fc300c,$00cccccc,$ccc0c0c0,$cc300cd8
	DC.L	$c0cceccc,$ccccccc0,$30cccccc,$78cc18c0
	DC.L	$18307000,$30000000
	DS.L	6
	DC.L	$06000000,$00300048,$70306400,$6060fefc
	DC.L	$00fc0030,$ec307838,$fcf8f818,$787c0000
	DC.L	$c0001838,$00fcf8c0,$ccf0f0dc,$fc300cf0
	DC.L	$c0fcfccc,$f8ccf878,$30ccccfc,$307c30c0
	DC.L	$3030d800
	DS.L	7
	DC.L	$cc000000,$000000fc,$286c9800,$60603830
	DC.L	$30006060,$cc30c00c,$0c0ccc30,$cc0c6060
	DC.L	$60fc3000,$00cccccc,$ccc0c0cc,$cc30ccd8
	DC.L	$c0ccdccc,$c0dcd80c,$30cc78cc,$780c60c0
	DC.L	$60300000
	DS.L	7
	DC.L	$78000000,$00300048,$f0cc7400,$30c06c30
	DC.L	$600060c0,$78fcfcf8,$0cf87830,$78f860c0
	DC.L	$30006030,$00ccf878,$f8fcc07c,$ccfc78cc
	DC.L	$fccccc78,$c07cccf8,$30783084,$ccf8fcf0
	DC.L	$c0f000fc
	DS.L	7
	DC.L	$30000000
chip_FontBold:
	DC.L	$0030cc48,$78cc6030,$30c06c30,$0000000c
	DC.L	$7830f8f8,$ccfc7cfc,$78786060,$300060f8
	DC.L	$0078f878,$f8fcfc7c,$ccfc0ccc,$c084cc78
	DC.L	$f878f87c,$fccccccc,$ccccfcf0,$0cf02000
	DC.L	$02000000
	DS.L	1
	DC.L	$00c00000
	DS.L	5
	DC.L	$0038eefc,$bcfeb078,$78603e38,$0000001e
	DC.L	$fc787c7c,$eefefe7e,$fcfc7070,$78fc307c
	DC.L	$00fcfcfc,$fcfefefe,$ee7e0efe,$e0ceeefc
	DC.L	$fcfcfcfe,$7eeeeeee,$7eee7ef8,$1e787000
	DC.L	$07000000
	DS.L	1
	DC.L	$00e00000
	DS.L	5
	DC.L	$0038667e,$707c6c30,$7070fefc,$00fc003c
	DC.L	$ee387e3e,$fef8f81e,$7e7e3030,$f07e183e
	DC.L	$00fefee6,$eef0f0fc,$fe380efc,$e0fefeee
	DC.L	$feeefe78,$38eeeefe,$3c7e3ce0,$3c38f800
	DC.L	$cf000000
	DS.L	1
	DC.L	$00f80000
	DS.L	5
	DC.L	$001800fc,$387cba00,$70707f7e,$307e6078
	DC.L	$fe38fc1c,$7e7cfc3c,$fc3e6060,$60fc3c1c
	DC.L	$00fefcec,$eef8f8ee,$fe38cef8,$e0fefeee
	DC.L	$fcfefc3c,$38ee7efe,$783c78e0,$78386c00
	DC.L	$7e000000
	DS.L	1
	DC.L	$00fc0000
	DS.L	5
	DC.L	$0030007e,$f4fe7c00,$30f07c38,$780070f0
	DC.L	$7efcfcfe,$0efe7e38,$7efe70f0,$307e7830
	DC.L	$00eefe7e,$fefce07e,$eefc7eec,$fceeee7e
	DC.L	$e07eecfe,$387e3ce6,$fc38fcf0,$f0f800fc
	DC.L	$3c000000
	DS.L	1
	DC.L	$00fe0000
	DS.L	5
	DC.L	$00180024,$78663a00,$18603618,$30003060
	DC.L	$3c7e7e7c,$067c3c18,$3c7c3060,$18003018
	DC.L	$00667c3c,$7c7e603e,$667e3c66,$7e66663c
	DC.L	$603e667c,$183c1842,$66187e78,$6078007e
	DC.L	$18000000
	DS.L	1
	DC.L	$007c0000
	DS.L	5
	DC.L	$ffcf33b7,$87339fcf,$cf3f93cf,$fffffff3
	DC.L	$87cf0707,$33038303,$87879f9f,$cfff9f07
	DC.L	$ff870787,$07030383,$3303f333,$3f7b3387
	DC.L	$07870783,$03333333,$3333030f,$f30fdfff
	DC.L	$fdffffff,$ffffffff,$ff3fffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffcf3303,$5f276f9f,$9f9fc7cf,$ffffffe7
	DC.L	$238ff3f3,$333f3ff3,$33339f9f,$9f03cff3
	DC.L	$ff333333,$333f3f3f,$33cff327,$3f331333
	DC.L	$3333333f,$cf333333,$8733e73f,$e7cf8fff
	DC.L	$f9ffffff,$ffffffff,$ff3fffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffcfffb7,$8fcf9bff,$9f9f0103,$ff03ffcf
	DC.L	$13cf87c7,$030707e7,$8783ffff,$3fffe7c7
	DC.L	$ff03073f,$330f0f23,$03cff30f,$3f030333
	DC.L	$07330787,$cf333303,$cf87cf3f,$cfcf27ff
	DC.L	$33ffffff,$ffffffff,$ff07ffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffff03,$d79367ff,$9f9fc7cf,$cfff9f9f
	DC.L	$33cf3ff3,$f3f333cf,$33f39f9f,$9f03cfff
	DC.L	$ff333333,$333f3f33,$33cf3327,$3f332333
	DC.L	$3f2327f3,$cf338733,$87cf9f3f,$9fcfffff
	DC.L	$87ffffff,$ffffffff,$ff33ffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffcfffb7,$0f338bff,$cf3f93cf,$9fff9f3f
	DC.L	$87030307,$f30787cf,$87079f3f,$cfff9fcf
	DC.L	$ff330787,$07033f83,$33038733,$03333387
	DC.L	$3f833307,$cf87cf7b,$33cf030f,$3f0fff03
	DC.L	$cfffffff,$ffffffff,$ff07ffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
	DC.L	$ffffffff,$ffffffff,$ffffffff,$ffffffff
chip_CopperlistMain:
	DC.L	$01200000,$01220000,$01240000,$01260000
	DC.L	$01280000,$012a0000,$012c0000,$012e0000
	DC.L	$01300000,$01320000,$01340000,$01360000
	DC.L	$01380000,$013a0000,$013c0000,$013e0000
chip_CopperBplPtrs:
	DC.L	$00e00000,$00e20000,$00e40000,$00e60000
	DC.W	$00e8
dat_1494:
	DC.L	$000000ea
dat_1495:
	DS.W	1
chip_Palette1:
	DC.L	$01a20aaa,$01a40888,$01a60666,$01a00000
	DC.W	$0180
chip_Palette2:
	DC.L	$00000182,$0aaa0184,$07770186,$04440188
chip_Palette3:
	DC.L	$0ccc018a,$0a00018c,$0000018e,$004d01ae
	DC.L	$0a0001aa,$070001ac,$04000106,$0063008e
chip_SpriteYPos0:
	DC.B	$2c
chip_SpriteXPos0:
	DC.B	$81
	DC.W	$0090
chip_SpriteYPos1:
	DC.B	$2c
chip_SpriteXPos1:
	DC.B	$c1
	DC.W	$0092
chip_SpriteBplPtr0:
	DC.L	$003c0094
chip_SpriteBplPtr1:
	DC.L	$00d40108,$0000010a,$00000102
chip_SpriteColor0:
	DC.L	$00000104
	DC.W	$0024
chip_SpriteYPos2:
	DC.L	$2c07fffe
	DC.W	$0100
chip_SpriteCtrlWord2:
	DC.W	$b200
chip_SpriteYPos3:
	DC.L	$5801ff00,$009c8010
chip_CopperPalEdit:
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000,$01fe0000,$01fe0000
	DC.L	$01fe0000,$01fe0000
chip_CopperWaitLine:
	DC.L	$bb07fffe
	DC.W	$0100
chip_CopperColor4:
	DC.W	$a200
dat_14A6:
	DC.L	$00e80000,$00ea0000
	DC.W	$0188
chip_CopperColor6:
	DC.W	$004d
dat_14A8:
	DC.L	$c207fffe
	DC.W	$0100
chip_CopperColor7Pal:
	DC.L	$b30001aa
chip_CopperColor7:
	DS.W	1
dat_14AB:
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
	DC.L	$01fe01fe,$01fe01fe,$01fe01fe,$01fe01fe
dat_14AC:
	DC.L	$f007fffe,$01b20000,$01b40000,$01b60000
	DC.L	$01ba0000,$01bc0000,$01be0000
dat_14AD:
	DC.L	$ffdffffe
dat_14AE:
	DC.L	$2907fffe
	DC.W	$0100
chip_CopperPalette4:
	DC.L	$a300ffff
	DC.W	$fffe
dat_14B0:
	DC.L	$b607fffe
	DC.W	$0188
chip_PaletteWork:
	DC.L	$004d01b2,$00f001ba,$00ffffff
	DC.W	$fffe
dat_14B2:
	DS.L	2
	DS.W	1
chip_IconData:
	DC.L	$c560d501,$c0004000,$7000b000,$3c004c00
	DC.L	$3f004300,$1fc020c0,$1fc02000,$0f001100
	DC.L	$0d801280,$04c00940,$046008a0,$00200040
	DS.L	5
chip_IconData2:
	DS.L	2
dat_14B5:
	DS.L	8
	DC.L	$fc00fc00,$0000fc00
	DS.L	1
	DS.W	1
dat_SongModifiedFlag2:
	DS.B	1
dat_SongModifiedFlag3:
	DS.B	1
	DS.L	94
	DS.W	1
chip_SpritePlayCtr:
	DS.L	1
	DC.L	$3c000000,$3c000000
	DS.L	2
chip_SpriteStatusBar:
	DS.B	1
chip_SpritePalEdCtrl:
	DS.B	1
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DC.L	$00003f00,$00003f00,$00003f00,$00003f00
	DS.W	1
dat_SprScrollbar:
	DS.B	1
dat_14BC:
	DS.B	1
	DS.W	1
	DC.B	$f8
dat_14BD:
	DS.B	1
	DC.L	$f000f000,$8800f000,$8800f000,$8800f000
	DC.L	$8800f000,$8800f000,$8800f000,$8800f000
	DC.L	$8800f000,$8800f000,$8800f000,$8800f000
	DC.L	$8800f000,$8800f000,$8800f000,$8800f000
	DC.L	$8800f000,$8800f000,$8800f000,$8800f000
	DC.L	$8800f000,$8800f000,$88008000,$78000000
	DS.L	1
	DC.L	$0000c0c0
	DC.W	$3fc0
chip_PanelBitplane1:
	DS.L	1
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DS.L	2
	DC.L	$c0c03fc0
chip_PanelBitplane2:
	DS.L	1
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DS.L	2
	DC.L	$c0c03fc0
chip_PanelBitplane3:
	DS.L	1
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DS.L	2
	DC.L	$c0c03fc0
chip_PanelBitplane4:
	DS.L	1
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DC.L	$c0c03fc0,$c0c03fc0,$c0c03fc0,$c0c03fc0
	DS.L	2
	DC.L	$c0c03fc0
chip_BorderLeft:
	DS.L	1
	DC.L	$f0000000,$f0000000,$f0000000,$f0000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DC.L	$10000000,$10000000,$10000000,$10000000
	DS.L	1
chip_BorderCenter:
	DS.L	1
	DC.L	$f0000000,$f0000000,$f0000000,$f0000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DS.L	1
chip_BorderRight:
	DS.L	1
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DC.L	$80000000,$80000000,$80000000,$80000000
	DS.L	1
	DC.L	$80000000
