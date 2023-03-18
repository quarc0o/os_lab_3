
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase4>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase4()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	d2450513          	addi	a0,a0,-732 # d30 <malloc+0xe6>
  14:	00001097          	auipc	ra,0x1
  18:	b7e080e7          	jalr	-1154(ra) # b92 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	d3450513          	addi	a0,a0,-716 # d50 <malloc+0x106>
  24:	00001097          	auipc	ra,0x1
  28:	b6e080e7          	jalr	-1170(ra) # b92 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	88e080e7          	jalr	-1906(ra) # 8ba <pfreepages>

    if ((pid = fork()) == 0)
  34:	00000097          	auipc	ra,0x0
  38:	7be080e7          	jalr	1982(ra) # 7f2 <fork>
  3c:	c545                	beqz	a0,e4 <testcase4+0xe4>
  3e:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
  40:	00001517          	auipc	a0,0x1
  44:	e1050513          	addi	a0,a0,-496 # e50 <malloc+0x206>
  48:	00001097          	auipc	ra,0x1
  4c:	b4a080e7          	jalr	-1206(ra) # b92 <printf>
        print_free_frame_cnt();
  50:	00001097          	auipc	ra,0x1
  54:	86a080e7          	jalr	-1942(ra) # 8ba <pfreepages>

        global_array[0] = 111;
  58:	00002917          	auipc	s2,0x2
  5c:	fb890913          	addi	s2,s2,-72 # 2010 <global_array>
  60:	06f00793          	li	a5,111
  64:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
  68:	06f00593          	li	a1,111
  6c:	00001517          	auipc	a0,0x1
  70:	df450513          	addi	a0,a0,-524 # e60 <malloc+0x216>
  74:	00001097          	auipc	ra,0x1
  78:	b1e080e7          	jalr	-1250(ra) # b92 <printf>

        printf("[prnt] v3 --> ");
  7c:	00001517          	auipc	a0,0x1
  80:	e2c50513          	addi	a0,a0,-468 # ea8 <malloc+0x25e>
  84:	00001097          	auipc	ra,0x1
  88:	b0e080e7          	jalr	-1266(ra) # b92 <printf>
        print_free_frame_cnt();
  8c:	00001097          	auipc	ra,0x1
  90:	82e080e7          	jalr	-2002(ra) # 8ba <pfreepages>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
  94:	4581                	li	a1,0
  96:	854a                	mv	a0,s2
  98:	00001097          	auipc	ra,0x1
  9c:	81a080e7          	jalr	-2022(ra) # 8b2 <va2pa>
  a0:	85aa                	mv	a1,a0
  a2:	00001517          	auipc	a0,0x1
  a6:	e1650513          	addi	a0,a0,-490 # eb8 <malloc+0x26e>
  aa:	00001097          	auipc	ra,0x1
  ae:	ae8080e7          	jalr	-1304(ra) # b92 <printf>
    }

    if (wait(0) != pid)
  b2:	4501                	li	a0,0
  b4:	00000097          	auipc	ra,0x0
  b8:	74e080e7          	jalr	1870(ra) # 802 <wait>
  bc:	10951263          	bne	a0,s1,1c0 <testcase4+0x1c0>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v7 --> ");
  c0:	00001517          	auipc	a0,0x1
  c4:	e2050513          	addi	a0,a0,-480 # ee0 <malloc+0x296>
  c8:	00001097          	auipc	ra,0x1
  cc:	aca080e7          	jalr	-1334(ra) # b92 <printf>
    print_free_frame_cnt();
  d0:	00000097          	auipc	ra,0x0
  d4:	7ea080e7          	jalr	2026(ra) # 8ba <pfreepages>
}
  d8:	60e2                	ld	ra,24(sp)
  da:	6442                	ld	s0,16(sp)
  dc:	64a2                	ld	s1,8(sp)
  de:	6902                	ld	s2,0(sp)
  e0:	6105                	addi	sp,sp,32
  e2:	8082                	ret
        sleep(50);
  e4:	03200513          	li	a0,50
  e8:	00000097          	auipc	ra,0x0
  ec:	7a2080e7          	jalr	1954(ra) # 88a <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
  f0:	00002497          	auipc	s1,0x2
  f4:	f2048493          	addi	s1,s1,-224 # 2010 <global_array>
  f8:	4581                	li	a1,0
  fa:	8526                	mv	a0,s1
  fc:	00000097          	auipc	ra,0x0
 100:	7b6080e7          	jalr	1974(ra) # 8b2 <va2pa>
 104:	85aa                	mv	a1,a0
 106:	00001517          	auipc	a0,0x1
 10a:	c5a50513          	addi	a0,a0,-934 # d60 <malloc+0x116>
 10e:	00001097          	auipc	ra,0x1
 112:	a84080e7          	jalr	-1404(ra) # b92 <printf>
        printf("[chld] v4 --> ");
 116:	00001517          	auipc	a0,0x1
 11a:	c6250513          	addi	a0,a0,-926 # d78 <malloc+0x12e>
 11e:	00001097          	auipc	ra,0x1
 122:	a74080e7          	jalr	-1420(ra) # b92 <printf>
        print_free_frame_cnt();
 126:	00000097          	auipc	ra,0x0
 12a:	794080e7          	jalr	1940(ra) # 8ba <pfreepages>
        global_array[0] = 222;
 12e:	0de00793          	li	a5,222
 132:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 134:	0de00593          	li	a1,222
 138:	00001517          	auipc	a0,0x1
 13c:	c5050513          	addi	a0,a0,-944 # d88 <malloc+0x13e>
 140:	00001097          	auipc	ra,0x1
 144:	a52080e7          	jalr	-1454(ra) # b92 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 148:	4581                	li	a1,0
 14a:	8526                	mv	a0,s1
 14c:	00000097          	auipc	ra,0x0
 150:	766080e7          	jalr	1894(ra) # 8b2 <va2pa>
 154:	85aa                	mv	a1,a0
 156:	00001517          	auipc	a0,0x1
 15a:	c7a50513          	addi	a0,a0,-902 # dd0 <malloc+0x186>
 15e:	00001097          	auipc	ra,0x1
 162:	a34080e7          	jalr	-1484(ra) # b92 <printf>
        printf("[chld] v5 --> ");
 166:	00001517          	auipc	a0,0x1
 16a:	c8250513          	addi	a0,a0,-894 # de8 <malloc+0x19e>
 16e:	00001097          	auipc	ra,0x1
 172:	a24080e7          	jalr	-1500(ra) # b92 <printf>
        print_free_frame_cnt();
 176:	00000097          	auipc	ra,0x0
 17a:	744080e7          	jalr	1860(ra) # 8ba <pfreepages>
        global_array[2047] = 333;
 17e:	14d00793          	li	a5,333
 182:	00004717          	auipc	a4,0x4
 186:	e8f72523          	sw	a5,-374(a4) # 400c <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 18a:	14d00593          	li	a1,333
 18e:	00001517          	auipc	a0,0x1
 192:	c6a50513          	addi	a0,a0,-918 # df8 <malloc+0x1ae>
 196:	00001097          	auipc	ra,0x1
 19a:	9fc080e7          	jalr	-1540(ra) # b92 <printf>
        printf("[chld] v6 --> ");
 19e:	00001517          	auipc	a0,0x1
 1a2:	ca250513          	addi	a0,a0,-862 # e40 <malloc+0x1f6>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	9ec080e7          	jalr	-1556(ra) # b92 <printf>
        print_free_frame_cnt();
 1ae:	00000097          	auipc	ra,0x0
 1b2:	70c080e7          	jalr	1804(ra) # 8ba <pfreepages>
        exit(0);
 1b6:	4501                	li	a0,0
 1b8:	00000097          	auipc	ra,0x0
 1bc:	642080e7          	jalr	1602(ra) # 7fa <exit>
        printf("wait() error!");
 1c0:	00001517          	auipc	a0,0x1
 1c4:	d1050513          	addi	a0,a0,-752 # ed0 <malloc+0x286>
 1c8:	00001097          	auipc	ra,0x1
 1cc:	9ca080e7          	jalr	-1590(ra) # b92 <printf>
        exit(1);
 1d0:	4505                	li	a0,1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	628080e7          	jalr	1576(ra) # 7fa <exit>

00000000000001da <testcase3>:

void testcase3()
{
 1da:	1101                	addi	sp,sp,-32
 1dc:	ec06                	sd	ra,24(sp)
 1de:	e822                	sd	s0,16(sp)
 1e0:	e426                	sd	s1,8(sp)
 1e2:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 1e4:	00001517          	auipc	a0,0x1
 1e8:	d0c50513          	addi	a0,a0,-756 # ef0 <malloc+0x2a6>
 1ec:	00001097          	auipc	ra,0x1
 1f0:	9a6080e7          	jalr	-1626(ra) # b92 <printf>
    printf("[prnt] v1 --> ");
 1f4:	00001517          	auipc	a0,0x1
 1f8:	b5c50513          	addi	a0,a0,-1188 # d50 <malloc+0x106>
 1fc:	00001097          	auipc	ra,0x1
 200:	996080e7          	jalr	-1642(ra) # b92 <printf>
    print_free_frame_cnt();
 204:	00000097          	auipc	ra,0x0
 208:	6b6080e7          	jalr	1718(ra) # 8ba <pfreepages>

    if ((pid = fork()) == 0)
 20c:	00000097          	auipc	ra,0x0
 210:	5e6080e7          	jalr	1510(ra) # 7f2 <fork>
 214:	cd35                	beqz	a0,290 <testcase3+0xb6>
 216:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 218:	00001517          	auipc	a0,0x1
 21c:	c3850513          	addi	a0,a0,-968 # e50 <malloc+0x206>
 220:	00001097          	auipc	ra,0x1
 224:	972080e7          	jalr	-1678(ra) # b92 <printf>
        print_free_frame_cnt();
 228:	00000097          	auipc	ra,0x0
 22c:	692080e7          	jalr	1682(ra) # 8ba <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 230:	00002597          	auipc	a1,0x2
 234:	dd05a583          	lw	a1,-560(a1) # 2000 <global_var>
 238:	00001517          	auipc	a0,0x1
 23c:	d0850513          	addi	a0,a0,-760 # f40 <malloc+0x2f6>
 240:	00001097          	auipc	ra,0x1
 244:	952080e7          	jalr	-1710(ra) # b92 <printf>

        printf("[prnt] v3 --> ");
 248:	00001517          	auipc	a0,0x1
 24c:	c6050513          	addi	a0,a0,-928 # ea8 <malloc+0x25e>
 250:	00001097          	auipc	ra,0x1
 254:	942080e7          	jalr	-1726(ra) # b92 <printf>
        print_free_frame_cnt();
 258:	00000097          	auipc	ra,0x0
 25c:	662080e7          	jalr	1634(ra) # 8ba <pfreepages>
    }

    if (wait(0) != pid)
 260:	4501                	li	a0,0
 262:	00000097          	auipc	ra,0x0
 266:	5a0080e7          	jalr	1440(ra) # 802 <wait>
 26a:	08951663          	bne	a0,s1,2f6 <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 26e:	00001517          	auipc	a0,0x1
 272:	cfa50513          	addi	a0,a0,-774 # f68 <malloc+0x31e>
 276:	00001097          	auipc	ra,0x1
 27a:	91c080e7          	jalr	-1764(ra) # b92 <printf>
    print_free_frame_cnt();
 27e:	00000097          	auipc	ra,0x0
 282:	63c080e7          	jalr	1596(ra) # 8ba <pfreepages>
}
 286:	60e2                	ld	ra,24(sp)
 288:	6442                	ld	s0,16(sp)
 28a:	64a2                	ld	s1,8(sp)
 28c:	6105                	addi	sp,sp,32
 28e:	8082                	ret
        sleep(50);
 290:	03200513          	li	a0,50
 294:	00000097          	auipc	ra,0x0
 298:	5f6080e7          	jalr	1526(ra) # 88a <sleep>
        printf("[chld] v4 --> ");
 29c:	00001517          	auipc	a0,0x1
 2a0:	adc50513          	addi	a0,a0,-1316 # d78 <malloc+0x12e>
 2a4:	00001097          	auipc	ra,0x1
 2a8:	8ee080e7          	jalr	-1810(ra) # b92 <printf>
        print_free_frame_cnt();
 2ac:	00000097          	auipc	ra,0x0
 2b0:	60e080e7          	jalr	1550(ra) # 8ba <pfreepages>
        global_var = 100;
 2b4:	06400793          	li	a5,100
 2b8:	00002717          	auipc	a4,0x2
 2bc:	d4f72423          	sw	a5,-696(a4) # 2000 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 2c0:	06400593          	li	a1,100
 2c4:	00001517          	auipc	a0,0x1
 2c8:	c4c50513          	addi	a0,a0,-948 # f10 <malloc+0x2c6>
 2cc:	00001097          	auipc	ra,0x1
 2d0:	8c6080e7          	jalr	-1850(ra) # b92 <printf>
        printf("[chld] v5 --> ");
 2d4:	00001517          	auipc	a0,0x1
 2d8:	b1450513          	addi	a0,a0,-1260 # de8 <malloc+0x19e>
 2dc:	00001097          	auipc	ra,0x1
 2e0:	8b6080e7          	jalr	-1866(ra) # b92 <printf>
        print_free_frame_cnt();
 2e4:	00000097          	auipc	ra,0x0
 2e8:	5d6080e7          	jalr	1494(ra) # 8ba <pfreepages>
        exit(0);
 2ec:	4501                	li	a0,0
 2ee:	00000097          	auipc	ra,0x0
 2f2:	50c080e7          	jalr	1292(ra) # 7fa <exit>
        printf("wait() error!");
 2f6:	00001517          	auipc	a0,0x1
 2fa:	bda50513          	addi	a0,a0,-1062 # ed0 <malloc+0x286>
 2fe:	00001097          	auipc	ra,0x1
 302:	894080e7          	jalr	-1900(ra) # b92 <printf>
        exit(1);
 306:	4505                	li	a0,1
 308:	00000097          	auipc	ra,0x0
 30c:	4f2080e7          	jalr	1266(ra) # 7fa <exit>

0000000000000310 <testcase2>:

void testcase2()
{
 310:	1101                	addi	sp,sp,-32
 312:	ec06                	sd	ra,24(sp)
 314:	e822                	sd	s0,16(sp)
 316:	e426                	sd	s1,8(sp)
 318:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 31a:	00001517          	auipc	a0,0x1
 31e:	c5e50513          	addi	a0,a0,-930 # f78 <malloc+0x32e>
 322:	00001097          	auipc	ra,0x1
 326:	870080e7          	jalr	-1936(ra) # b92 <printf>
    printf("[prnt] v1 --> ");
 32a:	00001517          	auipc	a0,0x1
 32e:	a2650513          	addi	a0,a0,-1498 # d50 <malloc+0x106>
 332:	00001097          	auipc	ra,0x1
 336:	860080e7          	jalr	-1952(ra) # b92 <printf>
    print_free_frame_cnt();
 33a:	00000097          	auipc	ra,0x0
 33e:	580080e7          	jalr	1408(ra) # 8ba <pfreepages>

    if ((pid = fork()) == 0)
 342:	00000097          	auipc	ra,0x0
 346:	4b0080e7          	jalr	1200(ra) # 7f2 <fork>
 34a:	c531                	beqz	a0,396 <testcase2+0x86>
 34c:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 34e:	00001517          	auipc	a0,0x1
 352:	b0250513          	addi	a0,a0,-1278 # e50 <malloc+0x206>
 356:	00001097          	auipc	ra,0x1
 35a:	83c080e7          	jalr	-1988(ra) # b92 <printf>
        print_free_frame_cnt();
 35e:	00000097          	auipc	ra,0x0
 362:	55c080e7          	jalr	1372(ra) # 8ba <pfreepages>
    }

    if (wait(0) != pid)
 366:	4501                	li	a0,0
 368:	00000097          	auipc	ra,0x0
 36c:	49a080e7          	jalr	1178(ra) # 802 <wait>
 370:	08951263          	bne	a0,s1,3f4 <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 374:	00001517          	auipc	a0,0x1
 378:	c5c50513          	addi	a0,a0,-932 # fd0 <malloc+0x386>
 37c:	00001097          	auipc	ra,0x1
 380:	816080e7          	jalr	-2026(ra) # b92 <printf>
    print_free_frame_cnt();
 384:	00000097          	auipc	ra,0x0
 388:	536080e7          	jalr	1334(ra) # 8ba <pfreepages>
}
 38c:	60e2                	ld	ra,24(sp)
 38e:	6442                	ld	s0,16(sp)
 390:	64a2                	ld	s1,8(sp)
 392:	6105                	addi	sp,sp,32
 394:	8082                	ret
        sleep(50);
 396:	03200513          	li	a0,50
 39a:	00000097          	auipc	ra,0x0
 39e:	4f0080e7          	jalr	1264(ra) # 88a <sleep>
        printf("[chld] v3 --> ");
 3a2:	00001517          	auipc	a0,0x1
 3a6:	bf650513          	addi	a0,a0,-1034 # f98 <malloc+0x34e>
 3aa:	00000097          	auipc	ra,0x0
 3ae:	7e8080e7          	jalr	2024(ra) # b92 <printf>
        print_free_frame_cnt();
 3b2:	00000097          	auipc	ra,0x0
 3b6:	508080e7          	jalr	1288(ra) # 8ba <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 3ba:	00002597          	auipc	a1,0x2
 3be:	c465a583          	lw	a1,-954(a1) # 2000 <global_var>
 3c2:	00001517          	auipc	a0,0x1
 3c6:	be650513          	addi	a0,a0,-1050 # fa8 <malloc+0x35e>
 3ca:	00000097          	auipc	ra,0x0
 3ce:	7c8080e7          	jalr	1992(ra) # b92 <printf>
        printf("[chld] v4 --> ");
 3d2:	00001517          	auipc	a0,0x1
 3d6:	9a650513          	addi	a0,a0,-1626 # d78 <malloc+0x12e>
 3da:	00000097          	auipc	ra,0x0
 3de:	7b8080e7          	jalr	1976(ra) # b92 <printf>
        print_free_frame_cnt();
 3e2:	00000097          	auipc	ra,0x0
 3e6:	4d8080e7          	jalr	1240(ra) # 8ba <pfreepages>
        exit(0);
 3ea:	4501                	li	a0,0
 3ec:	00000097          	auipc	ra,0x0
 3f0:	40e080e7          	jalr	1038(ra) # 7fa <exit>
        printf("wait() error!");
 3f4:	00001517          	auipc	a0,0x1
 3f8:	adc50513          	addi	a0,a0,-1316 # ed0 <malloc+0x286>
 3fc:	00000097          	auipc	ra,0x0
 400:	796080e7          	jalr	1942(ra) # b92 <printf>
        exit(1);
 404:	4505                	li	a0,1
 406:	00000097          	auipc	ra,0x0
 40a:	3f4080e7          	jalr	1012(ra) # 7fa <exit>

000000000000040e <testcase1>:

void testcase1()
{
 40e:	1101                	addi	sp,sp,-32
 410:	ec06                	sd	ra,24(sp)
 412:	e822                	sd	s0,16(sp)
 414:	e426                	sd	s1,8(sp)
 416:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 418:	00001517          	auipc	a0,0x1
 41c:	bc850513          	addi	a0,a0,-1080 # fe0 <malloc+0x396>
 420:	00000097          	auipc	ra,0x0
 424:	772080e7          	jalr	1906(ra) # b92 <printf>
    printf("[prnt] v1 --> ");
 428:	00001517          	auipc	a0,0x1
 42c:	92850513          	addi	a0,a0,-1752 # d50 <malloc+0x106>
 430:	00000097          	auipc	ra,0x0
 434:	762080e7          	jalr	1890(ra) # b92 <printf>
    print_free_frame_cnt();
 438:	00000097          	auipc	ra,0x0
 43c:	482080e7          	jalr	1154(ra) # 8ba <pfreepages>

    if ((pid = fork()) == 0)
 440:	00000097          	auipc	ra,0x0
 444:	3b2080e7          	jalr	946(ra) # 7f2 <fork>
 448:	c531                	beqz	a0,494 <testcase1+0x86>
 44a:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 44c:	00001517          	auipc	a0,0x1
 450:	a5c50513          	addi	a0,a0,-1444 # ea8 <malloc+0x25e>
 454:	00000097          	auipc	ra,0x0
 458:	73e080e7          	jalr	1854(ra) # b92 <printf>
        print_free_frame_cnt();
 45c:	00000097          	auipc	ra,0x0
 460:	45e080e7          	jalr	1118(ra) # 8ba <pfreepages>
    }

    if (wait(0) != pid)
 464:	4501                	li	a0,0
 466:	00000097          	auipc	ra,0x0
 46a:	39c080e7          	jalr	924(ra) # 802 <wait>
 46e:	04951a63          	bne	a0,s1,4c2 <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 472:	00001517          	auipc	a0,0x1
 476:	b9e50513          	addi	a0,a0,-1122 # 1010 <malloc+0x3c6>
 47a:	00000097          	auipc	ra,0x0
 47e:	718080e7          	jalr	1816(ra) # b92 <printf>
    print_free_frame_cnt();
 482:	00000097          	auipc	ra,0x0
 486:	438080e7          	jalr	1080(ra) # 8ba <pfreepages>
}
 48a:	60e2                	ld	ra,24(sp)
 48c:	6442                	ld	s0,16(sp)
 48e:	64a2                	ld	s1,8(sp)
 490:	6105                	addi	sp,sp,32
 492:	8082                	ret
        sleep(50);
 494:	03200513          	li	a0,50
 498:	00000097          	auipc	ra,0x0
 49c:	3f2080e7          	jalr	1010(ra) # 88a <sleep>
        printf("[chld] v2 --> ");
 4a0:	00001517          	auipc	a0,0x1
 4a4:	b6050513          	addi	a0,a0,-1184 # 1000 <malloc+0x3b6>
 4a8:	00000097          	auipc	ra,0x0
 4ac:	6ea080e7          	jalr	1770(ra) # b92 <printf>
        print_free_frame_cnt();
 4b0:	00000097          	auipc	ra,0x0
 4b4:	40a080e7          	jalr	1034(ra) # 8ba <pfreepages>
        exit(0);
 4b8:	4501                	li	a0,0
 4ba:	00000097          	auipc	ra,0x0
 4be:	340080e7          	jalr	832(ra) # 7fa <exit>
        printf("wait() error!");
 4c2:	00001517          	auipc	a0,0x1
 4c6:	a0e50513          	addi	a0,a0,-1522 # ed0 <malloc+0x286>
 4ca:	00000097          	auipc	ra,0x0
 4ce:	6c8080e7          	jalr	1736(ra) # b92 <printf>
        exit(1);
 4d2:	4505                	li	a0,1
 4d4:	00000097          	auipc	ra,0x0
 4d8:	326080e7          	jalr	806(ra) # 7fa <exit>

00000000000004dc <main>:

int main(int argc, char *argv[])
{
 4dc:	1101                	addi	sp,sp,-32
 4de:	ec06                	sd	ra,24(sp)
 4e0:	e822                	sd	s0,16(sp)
 4e2:	e426                	sd	s1,8(sp)
 4e4:	1000                	addi	s0,sp,32
 4e6:	84ae                	mv	s1,a1
    if (argc < 2)
 4e8:	4785                	li	a5,1
 4ea:	02a7d863          	bge	a5,a0,51a <main+0x3e>
    {
        printf("Usage: cowtest test_id");
    }
    switch (atoi(argv[1]))
 4ee:	6488                	ld	a0,8(s1)
 4f0:	00000097          	auipc	ra,0x0
 4f4:	210080e7          	jalr	528(ra) # 700 <atoi>
 4f8:	478d                	li	a5,3
 4fa:	04f50c63          	beq	a0,a5,552 <main+0x76>
 4fe:	02a7c763          	blt	a5,a0,52c <main+0x50>
 502:	4785                	li	a5,1
 504:	02f50d63          	beq	a0,a5,53e <main+0x62>
 508:	4789                	li	a5,2
 50a:	04f51a63          	bne	a0,a5,55e <main+0x82>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 50e:	00000097          	auipc	ra,0x0
 512:	e02080e7          	jalr	-510(ra) # 310 <testcase2>

    default:
        printf("Error: No test with index %s", argv[1]);
        return 1;
    }
    return 0;
 516:	4501                	li	a0,0
        break;
 518:	a805                	j	548 <main+0x6c>
        printf("Usage: cowtest test_id");
 51a:	00001517          	auipc	a0,0x1
 51e:	b0650513          	addi	a0,a0,-1274 # 1020 <malloc+0x3d6>
 522:	00000097          	auipc	ra,0x0
 526:	670080e7          	jalr	1648(ra) # b92 <printf>
 52a:	b7d1                	j	4ee <main+0x12>
    switch (atoi(argv[1]))
 52c:	4791                	li	a5,4
 52e:	02f51863          	bne	a0,a5,55e <main+0x82>
        testcase4();
 532:	00000097          	auipc	ra,0x0
 536:	ace080e7          	jalr	-1330(ra) # 0 <testcase4>
    return 0;
 53a:	4501                	li	a0,0
        break;
 53c:	a031                	j	548 <main+0x6c>
        testcase1();
 53e:	00000097          	auipc	ra,0x0
 542:	ed0080e7          	jalr	-304(ra) # 40e <testcase1>
    return 0;
 546:	4501                	li	a0,0
 548:	60e2                	ld	ra,24(sp)
 54a:	6442                	ld	s0,16(sp)
 54c:	64a2                	ld	s1,8(sp)
 54e:	6105                	addi	sp,sp,32
 550:	8082                	ret
        testcase3();
 552:	00000097          	auipc	ra,0x0
 556:	c88080e7          	jalr	-888(ra) # 1da <testcase3>
    return 0;
 55a:	4501                	li	a0,0
        break;
 55c:	b7f5                	j	548 <main+0x6c>
        printf("Error: No test with index %s", argv[1]);
 55e:	648c                	ld	a1,8(s1)
 560:	00001517          	auipc	a0,0x1
 564:	ad850513          	addi	a0,a0,-1320 # 1038 <malloc+0x3ee>
 568:	00000097          	auipc	ra,0x0
 56c:	62a080e7          	jalr	1578(ra) # b92 <printf>
        return 1;
 570:	4505                	li	a0,1
 572:	bfd9                	j	548 <main+0x6c>

0000000000000574 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 574:	1141                	addi	sp,sp,-16
 576:	e406                	sd	ra,8(sp)
 578:	e022                	sd	s0,0(sp)
 57a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 57c:	00000097          	auipc	ra,0x0
 580:	f60080e7          	jalr	-160(ra) # 4dc <main>
  exit(0);
 584:	4501                	li	a0,0
 586:	00000097          	auipc	ra,0x0
 58a:	274080e7          	jalr	628(ra) # 7fa <exit>

000000000000058e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 58e:	1141                	addi	sp,sp,-16
 590:	e422                	sd	s0,8(sp)
 592:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 594:	87aa                	mv	a5,a0
 596:	0585                	addi	a1,a1,1
 598:	0785                	addi	a5,a5,1
 59a:	fff5c703          	lbu	a4,-1(a1)
 59e:	fee78fa3          	sb	a4,-1(a5)
 5a2:	fb75                	bnez	a4,596 <strcpy+0x8>
    ;
  return os;
}
 5a4:	6422                	ld	s0,8(sp)
 5a6:	0141                	addi	sp,sp,16
 5a8:	8082                	ret

00000000000005aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 5aa:	1141                	addi	sp,sp,-16
 5ac:	e422                	sd	s0,8(sp)
 5ae:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 5b0:	00054783          	lbu	a5,0(a0)
 5b4:	cb91                	beqz	a5,5c8 <strcmp+0x1e>
 5b6:	0005c703          	lbu	a4,0(a1)
 5ba:	00f71763          	bne	a4,a5,5c8 <strcmp+0x1e>
    p++, q++;
 5be:	0505                	addi	a0,a0,1
 5c0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 5c2:	00054783          	lbu	a5,0(a0)
 5c6:	fbe5                	bnez	a5,5b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 5c8:	0005c503          	lbu	a0,0(a1)
}
 5cc:	40a7853b          	subw	a0,a5,a0
 5d0:	6422                	ld	s0,8(sp)
 5d2:	0141                	addi	sp,sp,16
 5d4:	8082                	ret

00000000000005d6 <strlen>:

uint
strlen(const char *s)
{
 5d6:	1141                	addi	sp,sp,-16
 5d8:	e422                	sd	s0,8(sp)
 5da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 5dc:	00054783          	lbu	a5,0(a0)
 5e0:	cf91                	beqz	a5,5fc <strlen+0x26>
 5e2:	0505                	addi	a0,a0,1
 5e4:	87aa                	mv	a5,a0
 5e6:	86be                	mv	a3,a5
 5e8:	0785                	addi	a5,a5,1
 5ea:	fff7c703          	lbu	a4,-1(a5)
 5ee:	ff65                	bnez	a4,5e6 <strlen+0x10>
 5f0:	40a6853b          	subw	a0,a3,a0
 5f4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 5f6:	6422                	ld	s0,8(sp)
 5f8:	0141                	addi	sp,sp,16
 5fa:	8082                	ret
  for(n = 0; s[n]; n++)
 5fc:	4501                	li	a0,0
 5fe:	bfe5                	j	5f6 <strlen+0x20>

0000000000000600 <memset>:

void*
memset(void *dst, int c, uint n)
{
 600:	1141                	addi	sp,sp,-16
 602:	e422                	sd	s0,8(sp)
 604:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 606:	ca19                	beqz	a2,61c <memset+0x1c>
 608:	87aa                	mv	a5,a0
 60a:	1602                	slli	a2,a2,0x20
 60c:	9201                	srli	a2,a2,0x20
 60e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 612:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 616:	0785                	addi	a5,a5,1
 618:	fee79de3          	bne	a5,a4,612 <memset+0x12>
  }
  return dst;
}
 61c:	6422                	ld	s0,8(sp)
 61e:	0141                	addi	sp,sp,16
 620:	8082                	ret

0000000000000622 <strchr>:

char*
strchr(const char *s, char c)
{
 622:	1141                	addi	sp,sp,-16
 624:	e422                	sd	s0,8(sp)
 626:	0800                	addi	s0,sp,16
  for(; *s; s++)
 628:	00054783          	lbu	a5,0(a0)
 62c:	cb99                	beqz	a5,642 <strchr+0x20>
    if(*s == c)
 62e:	00f58763          	beq	a1,a5,63c <strchr+0x1a>
  for(; *s; s++)
 632:	0505                	addi	a0,a0,1
 634:	00054783          	lbu	a5,0(a0)
 638:	fbfd                	bnez	a5,62e <strchr+0xc>
      return (char*)s;
  return 0;
 63a:	4501                	li	a0,0
}
 63c:	6422                	ld	s0,8(sp)
 63e:	0141                	addi	sp,sp,16
 640:	8082                	ret
  return 0;
 642:	4501                	li	a0,0
 644:	bfe5                	j	63c <strchr+0x1a>

0000000000000646 <gets>:

char*
gets(char *buf, int max)
{
 646:	711d                	addi	sp,sp,-96
 648:	ec86                	sd	ra,88(sp)
 64a:	e8a2                	sd	s0,80(sp)
 64c:	e4a6                	sd	s1,72(sp)
 64e:	e0ca                	sd	s2,64(sp)
 650:	fc4e                	sd	s3,56(sp)
 652:	f852                	sd	s4,48(sp)
 654:	f456                	sd	s5,40(sp)
 656:	f05a                	sd	s6,32(sp)
 658:	ec5e                	sd	s7,24(sp)
 65a:	1080                	addi	s0,sp,96
 65c:	8baa                	mv	s7,a0
 65e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 660:	892a                	mv	s2,a0
 662:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 664:	4aa9                	li	s5,10
 666:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 668:	89a6                	mv	s3,s1
 66a:	2485                	addiw	s1,s1,1
 66c:	0344d863          	bge	s1,s4,69c <gets+0x56>
    cc = read(0, &c, 1);
 670:	4605                	li	a2,1
 672:	faf40593          	addi	a1,s0,-81
 676:	4501                	li	a0,0
 678:	00000097          	auipc	ra,0x0
 67c:	19a080e7          	jalr	410(ra) # 812 <read>
    if(cc < 1)
 680:	00a05e63          	blez	a0,69c <gets+0x56>
    buf[i++] = c;
 684:	faf44783          	lbu	a5,-81(s0)
 688:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 68c:	01578763          	beq	a5,s5,69a <gets+0x54>
 690:	0905                	addi	s2,s2,1
 692:	fd679be3          	bne	a5,s6,668 <gets+0x22>
  for(i=0; i+1 < max; ){
 696:	89a6                	mv	s3,s1
 698:	a011                	j	69c <gets+0x56>
 69a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 69c:	99de                	add	s3,s3,s7
 69e:	00098023          	sb	zero,0(s3)
  return buf;
}
 6a2:	855e                	mv	a0,s7
 6a4:	60e6                	ld	ra,88(sp)
 6a6:	6446                	ld	s0,80(sp)
 6a8:	64a6                	ld	s1,72(sp)
 6aa:	6906                	ld	s2,64(sp)
 6ac:	79e2                	ld	s3,56(sp)
 6ae:	7a42                	ld	s4,48(sp)
 6b0:	7aa2                	ld	s5,40(sp)
 6b2:	7b02                	ld	s6,32(sp)
 6b4:	6be2                	ld	s7,24(sp)
 6b6:	6125                	addi	sp,sp,96
 6b8:	8082                	ret

00000000000006ba <stat>:

int
stat(const char *n, struct stat *st)
{
 6ba:	1101                	addi	sp,sp,-32
 6bc:	ec06                	sd	ra,24(sp)
 6be:	e822                	sd	s0,16(sp)
 6c0:	e426                	sd	s1,8(sp)
 6c2:	e04a                	sd	s2,0(sp)
 6c4:	1000                	addi	s0,sp,32
 6c6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 6c8:	4581                	li	a1,0
 6ca:	00000097          	auipc	ra,0x0
 6ce:	170080e7          	jalr	368(ra) # 83a <open>
  if(fd < 0)
 6d2:	02054563          	bltz	a0,6fc <stat+0x42>
 6d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 6d8:	85ca                	mv	a1,s2
 6da:	00000097          	auipc	ra,0x0
 6de:	178080e7          	jalr	376(ra) # 852 <fstat>
 6e2:	892a                	mv	s2,a0
  close(fd);
 6e4:	8526                	mv	a0,s1
 6e6:	00000097          	auipc	ra,0x0
 6ea:	13c080e7          	jalr	316(ra) # 822 <close>
  return r;
}
 6ee:	854a                	mv	a0,s2
 6f0:	60e2                	ld	ra,24(sp)
 6f2:	6442                	ld	s0,16(sp)
 6f4:	64a2                	ld	s1,8(sp)
 6f6:	6902                	ld	s2,0(sp)
 6f8:	6105                	addi	sp,sp,32
 6fa:	8082                	ret
    return -1;
 6fc:	597d                	li	s2,-1
 6fe:	bfc5                	j	6ee <stat+0x34>

0000000000000700 <atoi>:

int
atoi(const char *s)
{
 700:	1141                	addi	sp,sp,-16
 702:	e422                	sd	s0,8(sp)
 704:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 706:	00054683          	lbu	a3,0(a0)
 70a:	fd06879b          	addiw	a5,a3,-48
 70e:	0ff7f793          	zext.b	a5,a5
 712:	4625                	li	a2,9
 714:	02f66863          	bltu	a2,a5,744 <atoi+0x44>
 718:	872a                	mv	a4,a0
  n = 0;
 71a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 71c:	0705                	addi	a4,a4,1
 71e:	0025179b          	slliw	a5,a0,0x2
 722:	9fa9                	addw	a5,a5,a0
 724:	0017979b          	slliw	a5,a5,0x1
 728:	9fb5                	addw	a5,a5,a3
 72a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 72e:	00074683          	lbu	a3,0(a4)
 732:	fd06879b          	addiw	a5,a3,-48
 736:	0ff7f793          	zext.b	a5,a5
 73a:	fef671e3          	bgeu	a2,a5,71c <atoi+0x1c>
  return n;
}
 73e:	6422                	ld	s0,8(sp)
 740:	0141                	addi	sp,sp,16
 742:	8082                	ret
  n = 0;
 744:	4501                	li	a0,0
 746:	bfe5                	j	73e <atoi+0x3e>

0000000000000748 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 748:	1141                	addi	sp,sp,-16
 74a:	e422                	sd	s0,8(sp)
 74c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 74e:	02b57463          	bgeu	a0,a1,776 <memmove+0x2e>
    while(n-- > 0)
 752:	00c05f63          	blez	a2,770 <memmove+0x28>
 756:	1602                	slli	a2,a2,0x20
 758:	9201                	srli	a2,a2,0x20
 75a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 75e:	872a                	mv	a4,a0
      *dst++ = *src++;
 760:	0585                	addi	a1,a1,1
 762:	0705                	addi	a4,a4,1
 764:	fff5c683          	lbu	a3,-1(a1)
 768:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 76c:	fee79ae3          	bne	a5,a4,760 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 770:	6422                	ld	s0,8(sp)
 772:	0141                	addi	sp,sp,16
 774:	8082                	ret
    dst += n;
 776:	00c50733          	add	a4,a0,a2
    src += n;
 77a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 77c:	fec05ae3          	blez	a2,770 <memmove+0x28>
 780:	fff6079b          	addiw	a5,a2,-1
 784:	1782                	slli	a5,a5,0x20
 786:	9381                	srli	a5,a5,0x20
 788:	fff7c793          	not	a5,a5
 78c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 78e:	15fd                	addi	a1,a1,-1
 790:	177d                	addi	a4,a4,-1
 792:	0005c683          	lbu	a3,0(a1)
 796:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 79a:	fee79ae3          	bne	a5,a4,78e <memmove+0x46>
 79e:	bfc9                	j	770 <memmove+0x28>

00000000000007a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 7a6:	ca05                	beqz	a2,7d6 <memcmp+0x36>
 7a8:	fff6069b          	addiw	a3,a2,-1
 7ac:	1682                	slli	a3,a3,0x20
 7ae:	9281                	srli	a3,a3,0x20
 7b0:	0685                	addi	a3,a3,1
 7b2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 7b4:	00054783          	lbu	a5,0(a0)
 7b8:	0005c703          	lbu	a4,0(a1)
 7bc:	00e79863          	bne	a5,a4,7cc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 7c0:	0505                	addi	a0,a0,1
    p2++;
 7c2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 7c4:	fed518e3          	bne	a0,a3,7b4 <memcmp+0x14>
  }
  return 0;
 7c8:	4501                	li	a0,0
 7ca:	a019                	j	7d0 <memcmp+0x30>
      return *p1 - *p2;
 7cc:	40e7853b          	subw	a0,a5,a4
}
 7d0:	6422                	ld	s0,8(sp)
 7d2:	0141                	addi	sp,sp,16
 7d4:	8082                	ret
  return 0;
 7d6:	4501                	li	a0,0
 7d8:	bfe5                	j	7d0 <memcmp+0x30>

00000000000007da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 7da:	1141                	addi	sp,sp,-16
 7dc:	e406                	sd	ra,8(sp)
 7de:	e022                	sd	s0,0(sp)
 7e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 7e2:	00000097          	auipc	ra,0x0
 7e6:	f66080e7          	jalr	-154(ra) # 748 <memmove>
}
 7ea:	60a2                	ld	ra,8(sp)
 7ec:	6402                	ld	s0,0(sp)
 7ee:	0141                	addi	sp,sp,16
 7f0:	8082                	ret

00000000000007f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 7f2:	4885                	li	a7,1
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 7fa:	4889                	li	a7,2
 ecall
 7fc:	00000073          	ecall
 ret
 800:	8082                	ret

0000000000000802 <wait>:
.global wait
wait:
 li a7, SYS_wait
 802:	488d                	li	a7,3
 ecall
 804:	00000073          	ecall
 ret
 808:	8082                	ret

000000000000080a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 80a:	4891                	li	a7,4
 ecall
 80c:	00000073          	ecall
 ret
 810:	8082                	ret

0000000000000812 <read>:
.global read
read:
 li a7, SYS_read
 812:	4895                	li	a7,5
 ecall
 814:	00000073          	ecall
 ret
 818:	8082                	ret

000000000000081a <write>:
.global write
write:
 li a7, SYS_write
 81a:	48c1                	li	a7,16
 ecall
 81c:	00000073          	ecall
 ret
 820:	8082                	ret

0000000000000822 <close>:
.global close
close:
 li a7, SYS_close
 822:	48d5                	li	a7,21
 ecall
 824:	00000073          	ecall
 ret
 828:	8082                	ret

000000000000082a <kill>:
.global kill
kill:
 li a7, SYS_kill
 82a:	4899                	li	a7,6
 ecall
 82c:	00000073          	ecall
 ret
 830:	8082                	ret

0000000000000832 <exec>:
.global exec
exec:
 li a7, SYS_exec
 832:	489d                	li	a7,7
 ecall
 834:	00000073          	ecall
 ret
 838:	8082                	ret

000000000000083a <open>:
.global open
open:
 li a7, SYS_open
 83a:	48bd                	li	a7,15
 ecall
 83c:	00000073          	ecall
 ret
 840:	8082                	ret

0000000000000842 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 842:	48c5                	li	a7,17
 ecall
 844:	00000073          	ecall
 ret
 848:	8082                	ret

000000000000084a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 84a:	48c9                	li	a7,18
 ecall
 84c:	00000073          	ecall
 ret
 850:	8082                	ret

0000000000000852 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 852:	48a1                	li	a7,8
 ecall
 854:	00000073          	ecall
 ret
 858:	8082                	ret

000000000000085a <link>:
.global link
link:
 li a7, SYS_link
 85a:	48cd                	li	a7,19
 ecall
 85c:	00000073          	ecall
 ret
 860:	8082                	ret

0000000000000862 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 862:	48d1                	li	a7,20
 ecall
 864:	00000073          	ecall
 ret
 868:	8082                	ret

000000000000086a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 86a:	48a5                	li	a7,9
 ecall
 86c:	00000073          	ecall
 ret
 870:	8082                	ret

0000000000000872 <dup>:
.global dup
dup:
 li a7, SYS_dup
 872:	48a9                	li	a7,10
 ecall
 874:	00000073          	ecall
 ret
 878:	8082                	ret

000000000000087a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 87a:	48ad                	li	a7,11
 ecall
 87c:	00000073          	ecall
 ret
 880:	8082                	ret

0000000000000882 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 882:	48b1                	li	a7,12
 ecall
 884:	00000073          	ecall
 ret
 888:	8082                	ret

000000000000088a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 88a:	48b5                	li	a7,13
 ecall
 88c:	00000073          	ecall
 ret
 890:	8082                	ret

0000000000000892 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 892:	48b9                	li	a7,14
 ecall
 894:	00000073          	ecall
 ret
 898:	8082                	ret

000000000000089a <ps>:
.global ps
ps:
 li a7, SYS_ps
 89a:	48d9                	li	a7,22
 ecall
 89c:	00000073          	ecall
 ret
 8a0:	8082                	ret

00000000000008a2 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 8a2:	48dd                	li	a7,23
 ecall
 8a4:	00000073          	ecall
 ret
 8a8:	8082                	ret

00000000000008aa <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 8aa:	48e1                	li	a7,24
 ecall
 8ac:	00000073          	ecall
 ret
 8b0:	8082                	ret

00000000000008b2 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 8b2:	48e9                	li	a7,26
 ecall
 8b4:	00000073          	ecall
 ret
 8b8:	8082                	ret

00000000000008ba <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 8ba:	48e5                	li	a7,25
 ecall
 8bc:	00000073          	ecall
 ret
 8c0:	8082                	ret

00000000000008c2 <vatopa>:
.global vatopa
vatopa:
 li a7, SYS_vatopa
 8c2:	48ed                	li	a7,27
 ecall
 8c4:	00000073          	ecall
 ret
 8c8:	8082                	ret

00000000000008ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 8ca:	1101                	addi	sp,sp,-32
 8cc:	ec06                	sd	ra,24(sp)
 8ce:	e822                	sd	s0,16(sp)
 8d0:	1000                	addi	s0,sp,32
 8d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 8d6:	4605                	li	a2,1
 8d8:	fef40593          	addi	a1,s0,-17
 8dc:	00000097          	auipc	ra,0x0
 8e0:	f3e080e7          	jalr	-194(ra) # 81a <write>
}
 8e4:	60e2                	ld	ra,24(sp)
 8e6:	6442                	ld	s0,16(sp)
 8e8:	6105                	addi	sp,sp,32
 8ea:	8082                	ret

00000000000008ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 8ec:	7139                	addi	sp,sp,-64
 8ee:	fc06                	sd	ra,56(sp)
 8f0:	f822                	sd	s0,48(sp)
 8f2:	f426                	sd	s1,40(sp)
 8f4:	f04a                	sd	s2,32(sp)
 8f6:	ec4e                	sd	s3,24(sp)
 8f8:	0080                	addi	s0,sp,64
 8fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 8fc:	c299                	beqz	a3,902 <printint+0x16>
 8fe:	0805c963          	bltz	a1,990 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 902:	2581                	sext.w	a1,a1
  neg = 0;
 904:	4881                	li	a7,0
 906:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 90a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 90c:	2601                	sext.w	a2,a2
 90e:	00000517          	auipc	a0,0x0
 912:	7aa50513          	addi	a0,a0,1962 # 10b8 <digits>
 916:	883a                	mv	a6,a4
 918:	2705                	addiw	a4,a4,1
 91a:	02c5f7bb          	remuw	a5,a1,a2
 91e:	1782                	slli	a5,a5,0x20
 920:	9381                	srli	a5,a5,0x20
 922:	97aa                	add	a5,a5,a0
 924:	0007c783          	lbu	a5,0(a5)
 928:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 92c:	0005879b          	sext.w	a5,a1
 930:	02c5d5bb          	divuw	a1,a1,a2
 934:	0685                	addi	a3,a3,1
 936:	fec7f0e3          	bgeu	a5,a2,916 <printint+0x2a>
  if(neg)
 93a:	00088c63          	beqz	a7,952 <printint+0x66>
    buf[i++] = '-';
 93e:	fd070793          	addi	a5,a4,-48
 942:	00878733          	add	a4,a5,s0
 946:	02d00793          	li	a5,45
 94a:	fef70823          	sb	a5,-16(a4)
 94e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 952:	02e05863          	blez	a4,982 <printint+0x96>
 956:	fc040793          	addi	a5,s0,-64
 95a:	00e78933          	add	s2,a5,a4
 95e:	fff78993          	addi	s3,a5,-1
 962:	99ba                	add	s3,s3,a4
 964:	377d                	addiw	a4,a4,-1
 966:	1702                	slli	a4,a4,0x20
 968:	9301                	srli	a4,a4,0x20
 96a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 96e:	fff94583          	lbu	a1,-1(s2)
 972:	8526                	mv	a0,s1
 974:	00000097          	auipc	ra,0x0
 978:	f56080e7          	jalr	-170(ra) # 8ca <putc>
  while(--i >= 0)
 97c:	197d                	addi	s2,s2,-1
 97e:	ff3918e3          	bne	s2,s3,96e <printint+0x82>
}
 982:	70e2                	ld	ra,56(sp)
 984:	7442                	ld	s0,48(sp)
 986:	74a2                	ld	s1,40(sp)
 988:	7902                	ld	s2,32(sp)
 98a:	69e2                	ld	s3,24(sp)
 98c:	6121                	addi	sp,sp,64
 98e:	8082                	ret
    x = -xx;
 990:	40b005bb          	negw	a1,a1
    neg = 1;
 994:	4885                	li	a7,1
    x = -xx;
 996:	bf85                	j	906 <printint+0x1a>

0000000000000998 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 998:	715d                	addi	sp,sp,-80
 99a:	e486                	sd	ra,72(sp)
 99c:	e0a2                	sd	s0,64(sp)
 99e:	fc26                	sd	s1,56(sp)
 9a0:	f84a                	sd	s2,48(sp)
 9a2:	f44e                	sd	s3,40(sp)
 9a4:	f052                	sd	s4,32(sp)
 9a6:	ec56                	sd	s5,24(sp)
 9a8:	e85a                	sd	s6,16(sp)
 9aa:	e45e                	sd	s7,8(sp)
 9ac:	e062                	sd	s8,0(sp)
 9ae:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 9b0:	0005c903          	lbu	s2,0(a1)
 9b4:	18090c63          	beqz	s2,b4c <vprintf+0x1b4>
 9b8:	8aaa                	mv	s5,a0
 9ba:	8bb2                	mv	s7,a2
 9bc:	00158493          	addi	s1,a1,1
  state = 0;
 9c0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 9c2:	02500a13          	li	s4,37
 9c6:	4b55                	li	s6,21
 9c8:	a839                	j	9e6 <vprintf+0x4e>
        putc(fd, c);
 9ca:	85ca                	mv	a1,s2
 9cc:	8556                	mv	a0,s5
 9ce:	00000097          	auipc	ra,0x0
 9d2:	efc080e7          	jalr	-260(ra) # 8ca <putc>
 9d6:	a019                	j	9dc <vprintf+0x44>
    } else if(state == '%'){
 9d8:	01498d63          	beq	s3,s4,9f2 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 9dc:	0485                	addi	s1,s1,1
 9de:	fff4c903          	lbu	s2,-1(s1)
 9e2:	16090563          	beqz	s2,b4c <vprintf+0x1b4>
    if(state == 0){
 9e6:	fe0999e3          	bnez	s3,9d8 <vprintf+0x40>
      if(c == '%'){
 9ea:	ff4910e3          	bne	s2,s4,9ca <vprintf+0x32>
        state = '%';
 9ee:	89d2                	mv	s3,s4
 9f0:	b7f5                	j	9dc <vprintf+0x44>
      if(c == 'd'){
 9f2:	13490263          	beq	s2,s4,b16 <vprintf+0x17e>
 9f6:	f9d9079b          	addiw	a5,s2,-99
 9fa:	0ff7f793          	zext.b	a5,a5
 9fe:	12fb6563          	bltu	s6,a5,b28 <vprintf+0x190>
 a02:	f9d9079b          	addiw	a5,s2,-99
 a06:	0ff7f713          	zext.b	a4,a5
 a0a:	10eb6f63          	bltu	s6,a4,b28 <vprintf+0x190>
 a0e:	00271793          	slli	a5,a4,0x2
 a12:	00000717          	auipc	a4,0x0
 a16:	64e70713          	addi	a4,a4,1614 # 1060 <malloc+0x416>
 a1a:	97ba                	add	a5,a5,a4
 a1c:	439c                	lw	a5,0(a5)
 a1e:	97ba                	add	a5,a5,a4
 a20:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 a22:	008b8913          	addi	s2,s7,8
 a26:	4685                	li	a3,1
 a28:	4629                	li	a2,10
 a2a:	000ba583          	lw	a1,0(s7)
 a2e:	8556                	mv	a0,s5
 a30:	00000097          	auipc	ra,0x0
 a34:	ebc080e7          	jalr	-324(ra) # 8ec <printint>
 a38:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 a3a:	4981                	li	s3,0
 a3c:	b745                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 a3e:	008b8913          	addi	s2,s7,8
 a42:	4681                	li	a3,0
 a44:	4629                	li	a2,10
 a46:	000ba583          	lw	a1,0(s7)
 a4a:	8556                	mv	a0,s5
 a4c:	00000097          	auipc	ra,0x0
 a50:	ea0080e7          	jalr	-352(ra) # 8ec <printint>
 a54:	8bca                	mv	s7,s2
      state = 0;
 a56:	4981                	li	s3,0
 a58:	b751                	j	9dc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 a5a:	008b8913          	addi	s2,s7,8
 a5e:	4681                	li	a3,0
 a60:	4641                	li	a2,16
 a62:	000ba583          	lw	a1,0(s7)
 a66:	8556                	mv	a0,s5
 a68:	00000097          	auipc	ra,0x0
 a6c:	e84080e7          	jalr	-380(ra) # 8ec <printint>
 a70:	8bca                	mv	s7,s2
      state = 0;
 a72:	4981                	li	s3,0
 a74:	b7a5                	j	9dc <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 a76:	008b8c13          	addi	s8,s7,8
 a7a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a7e:	03000593          	li	a1,48
 a82:	8556                	mv	a0,s5
 a84:	00000097          	auipc	ra,0x0
 a88:	e46080e7          	jalr	-442(ra) # 8ca <putc>
  putc(fd, 'x');
 a8c:	07800593          	li	a1,120
 a90:	8556                	mv	a0,s5
 a92:	00000097          	auipc	ra,0x0
 a96:	e38080e7          	jalr	-456(ra) # 8ca <putc>
 a9a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a9c:	00000b97          	auipc	s7,0x0
 aa0:	61cb8b93          	addi	s7,s7,1564 # 10b8 <digits>
 aa4:	03c9d793          	srli	a5,s3,0x3c
 aa8:	97de                	add	a5,a5,s7
 aaa:	0007c583          	lbu	a1,0(a5)
 aae:	8556                	mv	a0,s5
 ab0:	00000097          	auipc	ra,0x0
 ab4:	e1a080e7          	jalr	-486(ra) # 8ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 ab8:	0992                	slli	s3,s3,0x4
 aba:	397d                	addiw	s2,s2,-1
 abc:	fe0914e3          	bnez	s2,aa4 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 ac0:	8be2                	mv	s7,s8
      state = 0;
 ac2:	4981                	li	s3,0
 ac4:	bf21                	j	9dc <vprintf+0x44>
        s = va_arg(ap, char*);
 ac6:	008b8993          	addi	s3,s7,8
 aca:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 ace:	02090163          	beqz	s2,af0 <vprintf+0x158>
        while(*s != 0){
 ad2:	00094583          	lbu	a1,0(s2)
 ad6:	c9a5                	beqz	a1,b46 <vprintf+0x1ae>
          putc(fd, *s);
 ad8:	8556                	mv	a0,s5
 ada:	00000097          	auipc	ra,0x0
 ade:	df0080e7          	jalr	-528(ra) # 8ca <putc>
          s++;
 ae2:	0905                	addi	s2,s2,1
        while(*s != 0){
 ae4:	00094583          	lbu	a1,0(s2)
 ae8:	f9e5                	bnez	a1,ad8 <vprintf+0x140>
        s = va_arg(ap, char*);
 aea:	8bce                	mv	s7,s3
      state = 0;
 aec:	4981                	li	s3,0
 aee:	b5fd                	j	9dc <vprintf+0x44>
          s = "(null)";
 af0:	00000917          	auipc	s2,0x0
 af4:	56890913          	addi	s2,s2,1384 # 1058 <malloc+0x40e>
        while(*s != 0){
 af8:	02800593          	li	a1,40
 afc:	bff1                	j	ad8 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 afe:	008b8913          	addi	s2,s7,8
 b02:	000bc583          	lbu	a1,0(s7)
 b06:	8556                	mv	a0,s5
 b08:	00000097          	auipc	ra,0x0
 b0c:	dc2080e7          	jalr	-574(ra) # 8ca <putc>
 b10:	8bca                	mv	s7,s2
      state = 0;
 b12:	4981                	li	s3,0
 b14:	b5e1                	j	9dc <vprintf+0x44>
        putc(fd, c);
 b16:	02500593          	li	a1,37
 b1a:	8556                	mv	a0,s5
 b1c:	00000097          	auipc	ra,0x0
 b20:	dae080e7          	jalr	-594(ra) # 8ca <putc>
      state = 0;
 b24:	4981                	li	s3,0
 b26:	bd5d                	j	9dc <vprintf+0x44>
        putc(fd, '%');
 b28:	02500593          	li	a1,37
 b2c:	8556                	mv	a0,s5
 b2e:	00000097          	auipc	ra,0x0
 b32:	d9c080e7          	jalr	-612(ra) # 8ca <putc>
        putc(fd, c);
 b36:	85ca                	mv	a1,s2
 b38:	8556                	mv	a0,s5
 b3a:	00000097          	auipc	ra,0x0
 b3e:	d90080e7          	jalr	-624(ra) # 8ca <putc>
      state = 0;
 b42:	4981                	li	s3,0
 b44:	bd61                	j	9dc <vprintf+0x44>
        s = va_arg(ap, char*);
 b46:	8bce                	mv	s7,s3
      state = 0;
 b48:	4981                	li	s3,0
 b4a:	bd49                	j	9dc <vprintf+0x44>
    }
  }
}
 b4c:	60a6                	ld	ra,72(sp)
 b4e:	6406                	ld	s0,64(sp)
 b50:	74e2                	ld	s1,56(sp)
 b52:	7942                	ld	s2,48(sp)
 b54:	79a2                	ld	s3,40(sp)
 b56:	7a02                	ld	s4,32(sp)
 b58:	6ae2                	ld	s5,24(sp)
 b5a:	6b42                	ld	s6,16(sp)
 b5c:	6ba2                	ld	s7,8(sp)
 b5e:	6c02                	ld	s8,0(sp)
 b60:	6161                	addi	sp,sp,80
 b62:	8082                	ret

0000000000000b64 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b64:	715d                	addi	sp,sp,-80
 b66:	ec06                	sd	ra,24(sp)
 b68:	e822                	sd	s0,16(sp)
 b6a:	1000                	addi	s0,sp,32
 b6c:	e010                	sd	a2,0(s0)
 b6e:	e414                	sd	a3,8(s0)
 b70:	e818                	sd	a4,16(s0)
 b72:	ec1c                	sd	a5,24(s0)
 b74:	03043023          	sd	a6,32(s0)
 b78:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b7c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b80:	8622                	mv	a2,s0
 b82:	00000097          	auipc	ra,0x0
 b86:	e16080e7          	jalr	-490(ra) # 998 <vprintf>
}
 b8a:	60e2                	ld	ra,24(sp)
 b8c:	6442                	ld	s0,16(sp)
 b8e:	6161                	addi	sp,sp,80
 b90:	8082                	ret

0000000000000b92 <printf>:

void
printf(const char *fmt, ...)
{
 b92:	711d                	addi	sp,sp,-96
 b94:	ec06                	sd	ra,24(sp)
 b96:	e822                	sd	s0,16(sp)
 b98:	1000                	addi	s0,sp,32
 b9a:	e40c                	sd	a1,8(s0)
 b9c:	e810                	sd	a2,16(s0)
 b9e:	ec14                	sd	a3,24(s0)
 ba0:	f018                	sd	a4,32(s0)
 ba2:	f41c                	sd	a5,40(s0)
 ba4:	03043823          	sd	a6,48(s0)
 ba8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 bac:	00840613          	addi	a2,s0,8
 bb0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 bb4:	85aa                	mv	a1,a0
 bb6:	4505                	li	a0,1
 bb8:	00000097          	auipc	ra,0x0
 bbc:	de0080e7          	jalr	-544(ra) # 998 <vprintf>
}
 bc0:	60e2                	ld	ra,24(sp)
 bc2:	6442                	ld	s0,16(sp)
 bc4:	6125                	addi	sp,sp,96
 bc6:	8082                	ret

0000000000000bc8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bc8:	1141                	addi	sp,sp,-16
 bca:	e422                	sd	s0,8(sp)
 bcc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bd2:	00001797          	auipc	a5,0x1
 bd6:	4367b783          	ld	a5,1078(a5) # 2008 <freep>
 bda:	a02d                	j	c04 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 bdc:	4618                	lw	a4,8(a2)
 bde:	9f2d                	addw	a4,a4,a1
 be0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 be4:	6398                	ld	a4,0(a5)
 be6:	6310                	ld	a2,0(a4)
 be8:	a83d                	j	c26 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 bea:	ff852703          	lw	a4,-8(a0)
 bee:	9f31                	addw	a4,a4,a2
 bf0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 bf2:	ff053683          	ld	a3,-16(a0)
 bf6:	a091                	j	c3a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bf8:	6398                	ld	a4,0(a5)
 bfa:	00e7e463          	bltu	a5,a4,c02 <free+0x3a>
 bfe:	00e6ea63          	bltu	a3,a4,c12 <free+0x4a>
{
 c02:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c04:	fed7fae3          	bgeu	a5,a3,bf8 <free+0x30>
 c08:	6398                	ld	a4,0(a5)
 c0a:	00e6e463          	bltu	a3,a4,c12 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c0e:	fee7eae3          	bltu	a5,a4,c02 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 c12:	ff852583          	lw	a1,-8(a0)
 c16:	6390                	ld	a2,0(a5)
 c18:	02059813          	slli	a6,a1,0x20
 c1c:	01c85713          	srli	a4,a6,0x1c
 c20:	9736                	add	a4,a4,a3
 c22:	fae60de3          	beq	a2,a4,bdc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 c26:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 c2a:	4790                	lw	a2,8(a5)
 c2c:	02061593          	slli	a1,a2,0x20
 c30:	01c5d713          	srli	a4,a1,0x1c
 c34:	973e                	add	a4,a4,a5
 c36:	fae68ae3          	beq	a3,a4,bea <free+0x22>
    p->s.ptr = bp->s.ptr;
 c3a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 c3c:	00001717          	auipc	a4,0x1
 c40:	3cf73623          	sd	a5,972(a4) # 2008 <freep>
}
 c44:	6422                	ld	s0,8(sp)
 c46:	0141                	addi	sp,sp,16
 c48:	8082                	ret

0000000000000c4a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c4a:	7139                	addi	sp,sp,-64
 c4c:	fc06                	sd	ra,56(sp)
 c4e:	f822                	sd	s0,48(sp)
 c50:	f426                	sd	s1,40(sp)
 c52:	f04a                	sd	s2,32(sp)
 c54:	ec4e                	sd	s3,24(sp)
 c56:	e852                	sd	s4,16(sp)
 c58:	e456                	sd	s5,8(sp)
 c5a:	e05a                	sd	s6,0(sp)
 c5c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c5e:	02051493          	slli	s1,a0,0x20
 c62:	9081                	srli	s1,s1,0x20
 c64:	04bd                	addi	s1,s1,15
 c66:	8091                	srli	s1,s1,0x4
 c68:	0014899b          	addiw	s3,s1,1
 c6c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 c6e:	00001517          	auipc	a0,0x1
 c72:	39a53503          	ld	a0,922(a0) # 2008 <freep>
 c76:	c515                	beqz	a0,ca2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c7a:	4798                	lw	a4,8(a5)
 c7c:	02977f63          	bgeu	a4,s1,cba <malloc+0x70>
  if(nu < 4096)
 c80:	8a4e                	mv	s4,s3
 c82:	0009871b          	sext.w	a4,s3
 c86:	6685                	lui	a3,0x1
 c88:	00d77363          	bgeu	a4,a3,c8e <malloc+0x44>
 c8c:	6a05                	lui	s4,0x1
 c8e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c92:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c96:	00001917          	auipc	s2,0x1
 c9a:	37290913          	addi	s2,s2,882 # 2008 <freep>
  if(p == (char*)-1)
 c9e:	5afd                	li	s5,-1
 ca0:	a895                	j	d14 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 ca2:	04001797          	auipc	a5,0x4001
 ca6:	36e78793          	addi	a5,a5,878 # 4002010 <base>
 caa:	00001717          	auipc	a4,0x1
 cae:	34f73f23          	sd	a5,862(a4) # 2008 <freep>
 cb2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 cb4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 cb8:	b7e1                	j	c80 <malloc+0x36>
      if(p->s.size == nunits)
 cba:	02e48c63          	beq	s1,a4,cf2 <malloc+0xa8>
        p->s.size -= nunits;
 cbe:	4137073b          	subw	a4,a4,s3
 cc2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cc4:	02071693          	slli	a3,a4,0x20
 cc8:	01c6d713          	srli	a4,a3,0x1c
 ccc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 cce:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 cd2:	00001717          	auipc	a4,0x1
 cd6:	32a73b23          	sd	a0,822(a4) # 2008 <freep>
      return (void*)(p + 1);
 cda:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 cde:	70e2                	ld	ra,56(sp)
 ce0:	7442                	ld	s0,48(sp)
 ce2:	74a2                	ld	s1,40(sp)
 ce4:	7902                	ld	s2,32(sp)
 ce6:	69e2                	ld	s3,24(sp)
 ce8:	6a42                	ld	s4,16(sp)
 cea:	6aa2                	ld	s5,8(sp)
 cec:	6b02                	ld	s6,0(sp)
 cee:	6121                	addi	sp,sp,64
 cf0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 cf2:	6398                	ld	a4,0(a5)
 cf4:	e118                	sd	a4,0(a0)
 cf6:	bff1                	j	cd2 <malloc+0x88>
  hp->s.size = nu;
 cf8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 cfc:	0541                	addi	a0,a0,16
 cfe:	00000097          	auipc	ra,0x0
 d02:	eca080e7          	jalr	-310(ra) # bc8 <free>
  return freep;
 d06:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 d0a:	d971                	beqz	a0,cde <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d0c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d0e:	4798                	lw	a4,8(a5)
 d10:	fa9775e3          	bgeu	a4,s1,cba <malloc+0x70>
    if(p == freep)
 d14:	00093703          	ld	a4,0(s2)
 d18:	853e                	mv	a0,a5
 d1a:	fef719e3          	bne	a4,a5,d0c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 d1e:	8552                	mv	a0,s4
 d20:	00000097          	auipc	ra,0x0
 d24:	b62080e7          	jalr	-1182(ra) # 882 <sbrk>
  if(p == (char*)-1)
 d28:	fd5518e3          	bne	a0,s5,cf8 <malloc+0xae>
        return 0;
 d2c:	4501                	li	a0,0
 d2e:	bf45                	j	cde <malloc+0x94>
