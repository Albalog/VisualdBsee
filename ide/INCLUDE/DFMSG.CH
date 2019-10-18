/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                            dBsee Message                             |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#include "dfGenMsg.ch"

#ifndef _DFMSG_CH
   #define _DFMSG_CH

   #define MSG_LANGUAGE           1

   #define MSG_INITERROR          2

   #define MSG_STD_YES            3
   #define MSG_STD_NO             4

   #define MSG_TABGET01           5
   #define MSG_TABGET02           6
   #define MSG_TABGET03           7
   #define MSG_TABGET04           8

   #define MSG_TABCHK01           9
   #define MSG_TABCHK02          10
   #define MSG_TABCHK03          11
   #define MSG_TABCHK04          12
   #define MSG_TABCHK05          13
   #define MSG_TABCHK06          14
   #define MSG_TABCHK07          15
   #define MSG_TABCHK08          16
   #define MSG_TABCHK09          17
   #define MSG_TABCHK10          18
   #define MSG_TABCHK11          19
   #define MSG_TABCHK12          20
   #define MSG_TABCHK13          21
   #define MSG_TABCHK14          22

   #define MSG_ERRSYS01          23
   #define MSG_ERRSYS02          24
   #define MSG_ERRSYS03          25
   #define MSG_ERRSYS04          26
   #define MSG_ERRSYS05          27
   #define MSG_ERRSYS06          28
   #define MSG_ERRSYS07          29
   #define MSG_ERRSYS08          30
   #define MSG_ERRSYS09          31
   #define MSG_ERRSYS10          32
   #define MSG_ERRSYS11          33
   #define MSG_ERRSYS12          34
   #define MSG_ACTINT153         35
   #define MSG_ERRSYS14          36
   #define MSG_ERRSYS15          37
   #define MSG_ERRSYS16          38

   #define MSG_DBPATH01          39
   #define MSG_DBPATH02          40

   #define MSG_DDUSE01           41
   #define MSG_DDUSE02           42
   #define MSG_DDUSE03           43
   #define MSG_DDUSE04           44
   #define MSG_DDUSE05           45
   #define MSG_ACTINT154         46
   #define MSG_DDUSE07           47
   #define MSG_DDUSE08           48
   #define MSG_DDUSE09           49
   #define MSG_DDUSE10           50

   #define MSG_DBMSGERR          51

   #define MSG_DE_STATE_INK      52
   #define MSG_DE_STATE_ADD      53
   #define MSG_DE_STATE_MOD      54
   #define MSG_DE_STATE_DEL      55

   #define MSG_TBSKIP01          56
   #define MSG_TBSKIP02          57
   #define MSG_TBSKIP03          58

   #define MSG_NUM2WORD01        59
   #define MSG_NUM2WORD02        60
   #define MSG_NUM2WORD03        61
   #define MSG_NUM2WORD04        62
   #define MSG_NUM2WORD05        63
   #define MSG_NUM2WORD06        64
   #define MSG_NUM2WORD07        65
   #define MSG_NUM2WORD08        66
   #define MSG_NUM2WORD09        67
   #define MSG_NUM2WORD10        68
   #define MSG_NUM2WORD11        69
   #define MSG_NUM2WORD12        70
   #define MSG_NUM2WORD13        71
   #define MSG_NUM2WORD14        72
   #define MSG_NUM2WORD15        73
   #define MSG_NUM2WORD16        74
   #define MSG_NUM2WORD17        75
   #define MSG_NUM2WORD18        76
   #define MSG_NUM2WORD19        77
   #define MSG_NUM2WORD20        78
   #define MSG_NUM2WORD21        79
   #define MSG_NUM2WORD22        80
   #define MSG_NUM2WORD23        81
   #define MSG_NUM2WORD24        82
   #define MSG_NUM2WORD25        83
   #define MSG_NUM2WORD26        84
   #define MSG_NUM2WORD27        85
   #define MSG_NUM2WORD28        86
   #define MSG_NUM2WORD29        87
   #define MSG_NUM2WORD30        88
   #define MSG_NUM2WORD31        89
   #define MSG_NUM2WORD32        90
   #define MSG_NUM2WORD33        91
   #define MSG_NUM2WORD34        92
   #define MSG_NUM2WORD35        93
   #define MSG_NUM2WORD36        94

   #define MSG_NTXSYS01          95
   #define MSG_ACTINT155         96
   #define MSG_NTXSYS03          97
   #define MSG_NTXSYS04          98
   #define MSG_NTXSYS05          99

   #define MSG_PGLIST01         100

   #define MSG_DBCFGOPE01       101
   #define MSG_DBCFGOPE02       102

   #define MSG_HLP01            103
   #define MSG_HLP02            104
   #define MSG_HLP03            105
   #define MSG_HLP04            106
   #define MSG_HLP05            107
   #define MSG_HLP06            108
   #define MSG_HLP07            109
   #define MSG_HLP08            110
   #define MSG_HLP09            111
   #define MSG_HLP10            112
   #define MSG_HLP11            113
   #define MSG_HLP12            114
   #define MSG_HLP13            115
   #define MSG_HLP14            116
   #define MSG_HLP15            117
   #define MSG_HLP16            118

   #define MSG_USRHELP01        119
   #define MSG_USRHELP02        120
   #define MSG_USRHELP03        121

   #define MSG_DDINDEX01        122
   #define MSG_DDINDEX02        123
   #define MSG_DDINDEX03        124
   #define MSG_DDINDEX04        125
   #define MSG_DDINDEX05        126
   #define MSG_DDINDEX06        127
   #define MSG_DDINDEX07        128
   #define MSG_DDINDEX08        129
   #define MSG_DDINDEX09        130
   #define MSG_DDINDEX10        131
   #define MSG_DDINDEX11        132
   #define MSG_DDINDEX12        133
   #define MSG_DDINDEX13        134
   #define MSG_DDINDEX14        135

   #define MSG_DDINDEXFL01      136
   #define MSG_DDINDEXFL02      137
   #define MSG_DDINDEXFL03      138

   #define MSG_DDWIN01          139
   #define MSG_DDWIN02          140
   #define MSG_DDWIN03          141
   #define MSG_DDWIN04          142
   #define MSG_DDWIN05          143

   #define MSG_DFAUTOFORM01     144
   #define MSG_DFAUTOFORM02     145

   #define MSG_DFCOLOR01        146
   #define MSG_DFCOLOR02        147

   #define MSG_DFALERT01        148
   #define MSG_DFALERT02        149

   #define MSG_DFMEMO01         150
   #define MSG_DFMEMO02         151
   #define MSG_DFMEMO03         152
   #define MSG_DFMEMO05         153
   #define MSG_DFMEMO06         154
   #define MSG_DFMEMO07         155
   #define MSG_DFMEMO08         156
   #define MSG_DFMEMO09         157
   #define MSG_DFMEMO10         158
   #define MSG_DFMEMO11         159
   #define MSG_DFMEMO12         160
   #define MSG_DFMEMO13         161
   #define MSG_DFMEMO14         162
   #define MSG_DFCHKDBF01       163
   #define MSG_DFMEMO16         164
   #define MSG_DFMEMO17         165

   #define MSG_DFQRY01          166
   #define MSG_DFQRY02          167
   #define MSG_DFQRY03          168
   #define MSG_DFQRY04          169
   #define MSG_DFQRY05          170
   #define MSG_DFQRY06          171
   #define MSG_DFQRY07          172
   #define MSG_DFQRY08          173
   #define MSG_DFQRY09          174
   #define MSG_DFQRY10          175
   #define MSG_DFQRY11          176
   #define MSG_DFQRY12          177
   #define MSG_DFQRY13          178

   #define MSG_DDQRY15          179
   #define MSG_DDQRY16          180
   #define MSG_DDQRY17          181

   #define MSG_TBGET04          182
   #define MSG_TBBRWNEW33       183
   #define MSG_DFCHKDBF02       184

   #define MSG_DFINI01          185
   #define MSG_DFINI02          186
   #define MSG_DFINI03          187

   #define MSG_DFFILE2PRN01     188
   #define MSG_DFFILE2PRN02     189
   #define MSG_DFFILE2PRN03     190

   #define MSG_DFNET01          191
   #define MSG_DFNET02          192
   #define MSG_DFNET03          193
   #define MSG_DFNET04          194

   #define MSG_DDINDEX15        195

   #define MSG_DFNET06          196
   #define MSG_DFNET07          197
   #define MSG_DFNET08          198
   #define MSG_DFNET09          199
   #define MSG_DFNET10          200

   #define MSG_DFMEMOWRI01      201
   #define MSG_DFMEMOWRI02      202
   #define MSG_DFMEMOWRI03      203
   #define MSG_DFMEMOWRI04      204
   #define MSG_DFCHKDBF03       205
   #define MSG_DFCHKDBF04       206

   #define MSG_DFINIPATH01      207

   #define MSG_DFINIFONT01      208

   #define MSG_DFINIPRN01       209

   #define MSG_DFPROGIND01      210
   #define MSG_DFPROGIND02      211

   #define MSG_DBLOOK01         212
   #define MSG_DBLOOK02         213
   #define MSG_DBLOOK03         214
   #define MSG_DBLOOK04         215
   #define MSG_DBLOOK05         216
   #define MSG_DBLOOK06         217
   #define MSG_DBLOOK07         218

   #define MSG_DFTABDE01        219
   #define MSG_DFTABDE02        220
   #define MSG_DFTABDE03        221
   #define MSG_DFTABDE04        222

   #define MSG_DBINK01          223
   #define MSG_DBINK02          224

   #define MSG_DFCHKDBF05       225

   #define MSG_DFINIPOR01       226

   #define MSG_DFGET01          227
   #define MSG_DFGET02          228

   #define MSG_TBBRWNEW01       229
   #define MSG_TBBRWNEW02       230
   #define MSG_TBBRWNEW03       231
   #define MSG_TBBRWNEW04       232
   #define MSG_TBBRWNEW05       233
   #define MSG_TBBRWNEW06       234
   #define MSG_TBBRWNEW07       235
   #define MSG_TBBRWNEW08       236
   #define MSG_TBBRWNEW09       237
   #define MSG_TBBRWNEW10       238
   #define MSG_TBBRWNEW11       239
   #define MSG_TBBRWNEW12       240
   #define MSG_TBBRWNEW13       241
   #define MSG_TBBRWNEW14       242
   #define MSG_TBBRWNEW15       243
   #define MSG_TBBRWNEW16       244
   #define MSG_TBBRWNEW17       245
   #define MSG_TBBRWNEW18       246
   #define MSG_TBBRWNEW19       247
   #define MSG_TBBRWNEW20       248
   #define MSG_TBBRWNEW21       249
   #define MSG_TBBRWNEW22       250
   #define MSG_TBBRWNEW23       251
   #define MSG_TBBRWNEW24       252
   #define MSG_TBBRWNEW25       253
   #define MSG_TBBRWNEW26       254
   #define MSG_TBBRWNEW27       255
   #define MSG_TBBRWNEW28       256
   #define MSG_TBBRWNEW29       257
   #define MSG_TBBRWNEW30       258

   #define MSG_DDGENDBF01       259
   #define MSG_DDGENDBF02       260

   #define MSG_DFTABPRINT01     261
   #define MSG_DFTABPRINT02     262
   #define MSG_DFTABPRINT03     263

   #define MSG_DFCHKDBF06       264

   #define MSG_DFPRNSTART01     265
   #define MSG_DFPRNSTART02     266
   #define MSG_DFPRNSTART03     267
   #define MSG_DFPRNSTART04     268
   #define MSG_DFPRNSTART05     269
   #define MSG_DFPRNSTART06     270
   #define MSG_DFPRNSTART07     271
   #define MSG_DFPRNSTART08     272
   #define MSG_DFPRNSTART09     273
   #define MSG_DFPRNSTART10     274
   #define MSG_DFPRNSTART11     275
   #define MSG_DFPRNSTART12     276
   #define MSG_DFPRNSTART13     277
   #define MSG_DFPRNSTART14     278
   #define MSG_DFPRNSTART15     279
   #define MSG_DFPRNSTART16     280
   #define MSG_DFPRNSTART17     281
   #define MSG_DFPRNSTART18     282
   #define MSG_DFPRNSTART19     283
   #define MSG_DFPRNSTART20     284
   #define MSG_DFPRNSTART21     285
   #define MSG_DFPRNSTART22     286
   #define MSG_DFPRNSTART23     287
   #define MSG_DFPRNSTART24     288
   #define MSG_DFPRNSTART25     289
   #define MSG_DFPRNSTART26     290
   #define MSG_DFPRNSTART27     291
   #define MSG_DFPRNSTART28     292
   #define MSG_DFPRNSTART29     293

   #define MSG_DDDE01           294
   #define MSG_DDDE02           295
   #define MSG_DDDE03           296
   #define MSG_DDDE04           297
   #define MSG_DDDE05           298
   #define MSG_DDDE06           299
   #define MSG_DDDE07           300

   #define MSG_TBINK01          301

   #define MSG_TBGETKEY01       302
   #define MSG_TBGETKEY02       303

   #define MSG_DFCHKDBF07       304

   #define MSG_TBGETKEY04       305
   #define MSG_TBGETKEY05       306
   #define MSG_TBGETKEY06       307
   #define MSG_TBGETKEY07       308
   #define MSG_TBGETKEY08       309
   #define MSG_TBGETKEY09       310
   #define MSG_TBGETKEY10       311
   #define MSG_TBGETKEY11       312

   #define MSG_DFPRNSTART32     313
   #define MSG_DFPRNSTART33     314

   #define MSG_DFSVILLEV01      315

   #define MSG_DFLOGIN01        316
   #define MSG_DFLOGIN02        317
   #define MSG_DFLOGIN03        318
   #define MSG_DFLOGIN04        319
   #define MSG_DFLOGIN05        320
   #define MSG_DFLOGIN06        321
   #define MSG_DFLOGIN07        322
   #define MSG_DFLOGIN08        323
   #define MSG_DFLOGIN09        324
   #define MSG_DFLOGIN10        325
   #define MSG_DFLOGIN11        326
   #define MSG_DFLOGIN12        327
   #define MSG_DFLOGIN13        328
   #define MSG_DFLOGIN14        329
   #define MSG_DFLOGIN15        330
   #define MSG_DFLOGIN16        331
   #define MSG_DFLOGIN17        332

   #define MSG_DDWIT01          333
   #define MSG_DDWIT02          334
   #define MSG_DDWIT03          335
   #define MSG_DDWIT04          336
   #define MSG_DDWIT05          337
   #define MSG_DDWIT06          338
   #define MSG_DDWIT07          339
   #define MSG_DDWIT08          340

   #define MSG_DDKEY01          341
   #define MSG_DDKEY02          342
   #define MSG_DDKEY03          343
   #define MSG_DDKEY04          344
   #define MSG_DDKEY05          345
   #define MSG_DDKEY06          346
   #define MSG_DDKEY07          347
   #define MSG_DDKEY08          348
   #define MSG_DDKEY09          349
   #define MSG_DDKEY10          350

   #define MSG_DDUPDDBF01       351

   #define MSG_DFPRNSTART34     352

   #define MSG_DFTABFRM03       353
   #define MSG_DFTABFRM04       354
   #define MSG_DFTABFRM05       355
   #define MSG_DFTABFRM06       356

   #define MSG_DFPK01           357
   #define MSG_DFPK02           358
   #define MSG_DFPK03           359
   #define MSG_DFPK04           360
   #define MSG_DFPK05           361
   #define MSG_DFPK06           362
   #define MSG_DFPK07           363

   #define MSG_DFPRNSTART35     364

   #define MSG_DDQRY01          365
   #define MSG_DDQRY02          366
   #define MSG_DDQRY03          367
   #define MSG_DDQRY04          368
   #define MSG_DDQRY05          369
   #define MSG_DDQRY06          370
   #define MSG_DDQRY07          371
   #define MSG_DDQRY08          372
   #define MSG_DDQRY09          373
   #define MSG_DDQRY10          374
   #define MSG_DDQRY11          375
   #define MSG_DDQRY12          376
   #define MSG_DDQRY13          377
   #define MSG_DDQRY14          378

   #define MSG_TBGET01          379
   #define MSG_TBGET02          380

   #define MSG_DFSTA01          381
   #define MSG_DFSTA02          382

   #define MSG_TBGETKEY14       383
   #define MSG_TBGETKEY15       384

   #define MSG_DFPRNSTART30     385
   #define MSG_DFINIREP01       386

   #define MSG_DFLOGIN18        387

   #define MSG_DFCALC01         388
   #define MSG_DFCALC02         389
   #define MSG_DFCALC03         390
   #define MSG_DFCALC04         391
   #define MSG_DFCALC06         392
   #define MSG_DFCALC07         393
   #define MSG_DFCALC08         394
   #define MSG_DFCALC09         395

   #define MSG_USRHELP04        396
   #define MSG_USRHELP05        397
   #define MSG_USRHELP06        398

   #define MSG_TBGET03          399

   #define MSG_DDINDEXFL04      400

   #define MSG_DDDE08           401

   #define MSG_TBBRWNEW31       402

   #define MSG_DFPRNSTART31     403

   #define MSG_TBBRWNEW32       404

   #define MSG_TBGETKEY16       405
   #define MSG_TBGETKEY17       406
   #define MSG_TBGETKEY18       407
   #define MSG_TBGETKEY19       408

   #define MSG_INTCOL01         409
   #define MSG_INTCOL02         410
   #define MSG_INTCOL03         411
   #define MSG_INTCOL04         412
   #define MSG_INTCOL05         413
   #define MSG_INTCOL06         414
   #define MSG_INTCOL07         415
   #define MSG_INTCOL08         416
   #define MSG_INTCOL09         417
   #define MSG_INTCOL10         418
   #define MSG_INTCOL11         419
   #define MSG_INTCOL12         420
   #define MSG_INTCOL13         421
   #define MSG_INTCOL14         422
   #define MSG_INTCOL15         423
   #define MSG_INTCOL16         424

   #define MSG_INTPRN01         425

   #define MSG_DFCHKDBF08       426
   #define MSG_DDKEY12          427

   #define MSG_ACTINT001        428
   #define MSG_ACTINT002        429
   #define MSG_ACTINT003        430
   #define MSG_ACTINT004        431
   #define MSG_ACTINT005        432
   #define MSG_ACTINT006        433
   #define MSG_ACTINT007        434
   #define MSG_ACTINT008        435
   #define MSG_ACTINT009        436

   #define MSG_DDFILEST01       437
   #define MSG_DDFILEST02       438
   //----- MSG_ACTINT012        439
   //----- MSG_ACTINT013        440
   //----- MSG_ACTINT014        441
   //----- MSG_ACTINT015        442
   //----- MSG_ACTINT016        443
   //----- MSG_ACTINT017        444
   //----- MSG_ACTINT018        445

   #define MSG_ACTINT019        446
   #define MSG_ACTINT020        447
   #define MSG_ACTINT021        448
   #define MSG_ACTINT022        449
   #define MSG_ACTINT023        450
   #define MSG_ACTINT024        451
   #define MSG_ACTINT025        452
   #define MSG_ACTINT026        453
   #define MSG_ACTINT027        454
   #define MSG_ACTINT028        455
   #define MSG_ACTINT029        456
   #define MSG_ACTINT030        457
   #define MSG_ACTINT031        458
   #define MSG_ACTINT032        459
   //----- MSG_ACTINT033        460
   //----- MSG_ACTINT034        461
   //----- MSG_ACTINT035        462
   //----- MSG_ACTINT036        463
   //----- MSG_ACTINT037        464
   //----- MSG_ACTINT038        465
   //----- MSG_ACTINT039        466
   //----- MSG_ACTINT040        467
   //----- MSG_ACTINT041        468
   //----- MSG_ACTINT042        469
   //----- MSG_ACTINT043        470
   //----- MSG_ACTINT044        471
   //----- MSG_ACTINT045        472
   //----- MSG_ACTINT046        473
   //----- MSG_ACTINT047        474
   //----- MSG_ACTINT048        475
   //----- MSG_ACTINT049        476
   //----- MSG_ACTINT050        477
   //----- MSG_ACTINT051        478
   //----- MSG_ACTINT052        479
   //----- MSG_ACTINT053        480
   //----- MSG_ACTINT054        481
   //----- MSG_ACTINT055        482
   //----- MSG_ACTINT056        483
   //----- MSG_ACTINT057        484
   //----- MSG_ACTINT058        485
   //----- MSG_ACTINT059        486
   //----- MSG_ACTINT060        487
   //----- MSG_ACTINT061        488
   //----- MSG_ACTINT062        489
   //----- MSG_ACTINT063        490
   //----- MSG_ACTINT064        491
   //----- MSG_ACTINT065        492
   //----- MSG_ACTINT066        493
   #define MSG_ACTINT067        494
   #define MSG_ACTINT068        495
   #define MSG_ACTINT069        496
   #define MSG_ACTINT070        497
   #define MSG_ACTINT071        498
   #define MSG_ACTINT072        499
   #define MSG_ACTINT073        500
   #define MSG_ACTINT074        501
   #define MSG_ACTINT075        502
   #define MSG_ACTINT076        503
   #define MSG_ACTINT077        504
   #define MSG_ACTINT078        505
   #define MSG_ACTINT079        506
   #define MSG_ACTINT080        507
   #define MSG_ACTINT081        508
   #define MSG_ACTINT082        509
   #define MSG_ACTINT083        510
   #define MSG_ACTINT084        511
   #define MSG_ACTINT085        512
   #define MSG_ACTINT086        513
   #define MSG_ACTINT087        514
   #define MSG_ACTINT088        515
   #define MSG_ACTINT089        516
   #define MSG_ACTINT090        517
   #define MSG_ACTINT091        518
   #define MSG_ACTINT092        519
   #define MSG_ACTINT093        520
   #define MSG_ACTINT094        521
   #define MSG_ACTINT095        522
   #define MSG_ACTINT096        523
   #define MSG_ACTINT097        524
   #define MSG_ACTINT098        525
   #define MSG_ACTINT099        526
   #define MSG_ACTINT100        527
   #define MSG_ACTINT101        528
   #define MSG_ACTINT102        529
   #define MSG_ACTINT103        530
   #define MSG_ACTINT104        531
   #define MSG_ACTINT105        532
   #define MSG_ACTINT106        533
   #define MSG_ACTINT107        534
   #define MSG_ACTINT108        535
   #define MSG_ACTINT109        536
   #define MSG_ACTINT110        537
   #define MSG_ACTINT111        538
   #define MSG_ACTINT112        539
   #define MSG_ACTINT113        540
   #define MSG_ACTINT114        541
   #define MSG_ACTINT115        542
   #define MSG_ACTINT116        543
   #define MSG_ACTINT117        544
   #define MSG_ACTINT118        545
   #define MSG_ACTINT119        546
   #define MSG_ACTINT120        547
   //----- MSG_ACTINT121        548
   //----- MSG_ACTINT122        549
   //----- MSG_ACTINT123        550
   //----- MSG_ACTINT124        551
   //----- MSG_ACTINT125        552
   //----- MSG_ACTINT126        553
   #define MSG_ACTINT127        554
   #define MSG_ACTINT128        555
   #define MSG_ACTINT129        556
   #define MSG_ACTINT130        557
   #define MSG_ACTINT131        558
   #define MSG_ACTINT132        559
   #define MSG_ACTINT133        560
   #define MSG_ACTINT134        561
   #define MSG_ACTINT135        562
   #define MSG_ACTINT136        563
   #define MSG_ACTINT137        564
   #define MSG_ACTINT138        565
   #define MSG_ACTINT139        566
   #define MSG_ACTINT140        567
   #define MSG_ACTINT141        568
   #define MSG_ACTINT142        569
   #define MSG_ACTINT143        570
   //----- MSG_ACTINT144        571
   #define MSG_ACTINT145        572
   #define MSG_ACTINT146        573
   #define MSG_ACTINT147        574
   #define MSG_ACTINT148        575
   #define MSG_ACTINT149        576
   #define MSG_ACTINT150        577
   #define MSG_ACTINT151        578

   #define MSG_DDGENDBF03       579

   #define MSG_INFO01           580
   #define MSG_INFO02           581
   #define MSG_INFO03           582
   #define MSG_INFO04           583
   #define MSG_INFO05           584
   #define MSG_INFO06           585

   #define MSG_ERRSYS17         586
   #define MSG_ERRSYS18         587
   #define MSG_ERRSYS19         588
   #define MSG_ERRSYS20         589
   #define MSG_ERRSYS21         590
   #define MSG_ERRSYS22         591
   #define MSG_ERRSYS23         592
   #define MSG_ERRSYS24         593
   #define MSG_ERRSYS25         594
   #define MSG_ERRSYS26         595
   #define MSG_ERRSYS27         596
   #define MSG_ERRSYS28         597
   #define MSG_ERRSYS29         598
   #define MSG_ERRSYS30         599
   #define MSG_ERRSYS31         600
   #define MSG_ERRSYS32         601
   #define MSG_ERRSYS33         602
   #define MSG_ERRSYS34         603
   #define MSG_ERRSYS35         604
   #define MSG_ERRSYS36         605
   #define MSG_ERRSYS37         606
   #define MSG_ERRSYS38         607
   #define MSG_ERRSYS39         608
   #define MSG_ERRSYS40         609
   #define MSG_ERRSYS41         610
   #define MSG_ERRSYS42         611
   #define MSG_ERRSYS43         612
   #define MSG_ERRSYS44         613
   #define MSG_ERRSYS45         614
   #define MSG_ERRSYS46         615
   #define MSG_ERRSYS47         616
   #define MSG_ERRSYS48         617
   #define MSG_ERRSYS49         618
   #define MSG_ERRSYS50         619
   #define MSG_ERRSYS51         620
   #define MSG_ERRSYS52         621
   #define MSG_ERRSYS53         622
   #define MSG_ERRSYS54         623
   #define MSG_ERRSYS55         624
   #define MSG_ERRSYS56         625
   #define MSG_TBBRWNEW35       626
   #define MSG_ERRSYS58         627
   #define MSG_ERRSYS59         628
   #define MSG_ERRSYS60         629
   #define MSG_ERRSYS61         630
   #define MSG_ERRSYS62         631
   #define MSG_ERRSYS63         632
   #define MSG_ERRSYS64         633
   #define MSG_ERRSYS65         634
   #define MSG_ERRSYS66         635
   #define MSG_ERRSYS67         636
   #define MSG_ERRSYS68         637
   #define MSG_ERRSYS69         638
   #define MSG_ERRSYS70         639
   #define MSG_ERRSYS71         640
   #define MSG_ERRSYS72         641
   #define MSG_ERRSYS73         642
   #define MSG_ERRSYS74         643
   #define MSG_ERRSYS75         644
   #define MSG_ERRSYS76         645
   #define MSG_ERRSYS77         646
   #define MSG_ERRSYS78         647

   #define MSG_DDKEY11          648

   #define MSG_TBGETKEY20       649
   #define MSG_TBGETKEY21       650
   #define MSG_TBGETKEY22       651

   #define MSG_INFO07           652

   #define MSG_DFPRNSTART36     653
   #define MSG_DFPRNSTART37     654
   #define MSG_DFPRNSTART38     655
   #define MSG_DFPRNSTART39     656
   #define MSG_DFPRNSTART40     657
   #define MSG_DFPRNSTART41     658
   //------------------------------
   #define MSG_DFPRNSTART43     660
   #define MSG_DFPRNSTART44     661
   #define MSG_DFPRNSTART45     662
   #define MSG_DFPRNSTART46     663
   #define MSG_DFPRNSTART47     664

   #define MSG_DFISPIRATE01     665
   #define MSG_DFISPIRATE02     666
   #define MSG_DFISPIRATE03     667
   #define MSG_DFISPIRATE04     668

   #define MSG_INFO08           669

   #define MSG_TBGET05          670
   #define MSG_TBGET06          671
   #define MSG_TBGET07          672
   #define MSG_TBGET08          673

   #define MSG_DFCFGPAL01       674
   #define MSG_DFCFGPAL02       675

   #define MSG_AS40001          676
   #define MSG_AS40002          677
   #define MSG_AS40003          678
   #define MSG_AS40004          679

   #define MSG_DE_STATE_COPY    680
   #define MSG_DE_STATE_QRY     681

   #define MSG_AS40005          682

   #define MSG_DFDATEFT01       683
   #define MSG_DFDATEFT02       684

   #define MSG_DFPRNSTART48     685
   #define MSG_DFPRNSTART49     686

   #define MSG_TBBRWNEW34       687

   #define MSG_DFPRNLAB01       688
   #define MSG_DFPRNLAB02       689
   #define MSG_DFPRNLAB03       690
   #define MSG_DFPRNLAB04       691
   #define MSG_DFPRNLAB05       692

   #define MSG_DFCOL2PRN01      693

   #define MSG_NUM2WORD39       694
   #define MSG_NUM2WORD40       695
   #define MSG_NUM2WORD41       696
   #define MSG_NUM2WORD42       697
   #define MSG_NUM2WORD43       698
   #define MSG_NUM2WORD44       699
   #define MSG_NUM2WORD45       700
   #define MSG_NUM2WORD46       701
   #define MSG_NUM2WORD47       702

   #define MSG_DFFILEDLG01      703
   #define MSG_DFFILEDLG02      704
   #define MSG_DFFILEDLG03      705
   #define MSG_DFFILEDLG04      706
   #define MSG_DFFILEDLG05      707
   #define MSG_DFFILEDLG06      708
   #define MSG_DFFILEDLG07      709
   #define MSG_DFFILEDLG08      710
   #define MSG_DFFILEDLG09      711
   #define MSG_DFFILEDLG10      712

   #define MSG_DFCALC10         800
   #define MSG_DFCALC11         801

   #define MSG_DFLOGIN19        810

   #define MSG_TBBRWNEW36       811
   #define MSG_TBBRWNEW37       812
   #define MSG_TBBRWNEW38       813

   #define MSG_DDGENDBF04       820
   #define MSG_DDGENDBF05       821
   #define MSG_DDGENDBF06       822
   #define MSG_DDGENDBF07       823

   #define MSG_DDUSE11          830 
  
#endif
