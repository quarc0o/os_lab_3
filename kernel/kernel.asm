
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	bc010113          	addi	sp,sp,-1088 # 80008bc0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	a3070713          	addi	a4,a4,-1488 # 80008a80 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	05e78793          	addi	a5,a5,94 # 800060c0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc90f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e8e78793          	addi	a5,a5,-370 # 80000f3a <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	5fe080e7          	jalr	1534(ra) # 80002728 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	792080e7          	jalr	1938(ra) # 800008cc <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000180:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	a3c50513          	addi	a0,a0,-1476 # 80010bc0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	b0e080e7          	jalr	-1266(ra) # 80000c9a <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a2c48493          	addi	s1,s1,-1492 # 80010bc0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	abc90913          	addi	s2,s2,-1348 # 80010c58 <cons+0x98>
    while (n > 0)
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
        while (cons.r == cons.w)
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
            if (killed(myproc()))
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	9ae080e7          	jalr	-1618(ra) # 80001b62 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	3b6080e7          	jalr	950(ra) # 80002572 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
            sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	100080e7          	jalr	256(ra) # 800022ca <sleep>
        while (cons.r == cons.w)
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	9e270713          	addi	a4,a4,-1566 # 80010bc0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

        if (c == C('D'))
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
            }
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	4c2080e7          	jalr	1218(ra) # 800026d2 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
            break;

        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1

        if (c == '\n')
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	99850513          	addi	a0,a0,-1640 # 80010bc0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	b1e080e7          	jalr	-1250(ra) # 80000d4e <release>

    return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
                release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	98250513          	addi	a0,a0,-1662 # 80010bc0 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	b08080e7          	jalr	-1272(ra) # 80000d4e <release>
                return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
            if (n < target)
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
                cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	9ef72523          	sw	a5,-1558(a4) # 80010c58 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
        uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	572080e7          	jalr	1394(ra) # 800007fa <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
        uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	560080e7          	jalr	1376(ra) # 800007fa <uartputc_sync>
        uartputc_sync(' ');
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	554080e7          	jalr	1364(ra) # 800007fa <uartputc_sync>
        uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	54a080e7          	jalr	1354(ra) # 800007fa <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	8f850513          	addi	a0,a0,-1800 # 80010bc0 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	9ca080e7          	jalr	-1590(ra) # 80000c9a <acquire>

    switch (c)
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	490080e7          	jalr	1168(ra) # 8000277e <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	8ca50513          	addi	a0,a0,-1846 # 80010bc0 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	a50080e7          	jalr	-1456(ra) # 80000d4e <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
    switch (c)
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	8a670713          	addi	a4,a4,-1882 # 80010bc0 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
            consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	87c78793          	addi	a5,a5,-1924 # 80010bc0 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	8e67a783          	lw	a5,-1818(a5) # 80010c58 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
        while (cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	83a70713          	addi	a4,a4,-1990 # 80010bc0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	82a48493          	addi	s1,s1,-2006 # 80010bc0 <cons>
        while (cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
            cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
        while (cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	7ee70713          	addi	a4,a4,2030 # 80010bc0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
            cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	86f72c23          	sw	a5,-1928(a4) # 80010c60 <cons+0xa0>
            consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
            consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	7b278793          	addi	a5,a5,1970 # 80010bc0 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	82c7a523          	sw	a2,-2006(a5) # 80010c5c <cons+0x9c>
                wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	81e50513          	addi	a0,a0,-2018 # 80010c58 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	eec080e7          	jalr	-276(ra) # 8000232e <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bcc58593          	addi	a1,a1,-1076 # 80008020 <__func__.1+0x18>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	76450513          	addi	a0,a0,1892 # 80010bc0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	7a6080e7          	jalr	1958(ra) # 80000c0a <initlock>

    uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	33e080e7          	jalr	830(ra) # 800007aa <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	8e478793          	addi	a5,a5,-1820 # 80020d58 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004b2:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b9a60613          	addi	a2,a2,-1126 # 80008050 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

    if (sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
        buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
    while (--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
        x = -xx;
    80000534:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
        x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    8000053c:	711d                	addi	sp,sp,-96
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
    80000548:	e40c                	sd	a1,8(s0)
    8000054a:	e810                	sd	a2,16(s0)
    8000054c:	ec14                	sd	a3,24(s0)
    8000054e:	f018                	sd	a4,32(s0)
    80000550:	f41c                	sd	a5,40(s0)
    80000552:	03043823          	sd	a6,48(s0)
    80000556:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000055a:	00010797          	auipc	a5,0x10
    8000055e:	7207a323          	sw	zero,1830(a5) # 80010c80 <pr+0x18>
    printf("panic: ");
    80000562:	00008517          	auipc	a0,0x8
    80000566:	ac650513          	addi	a0,a0,-1338 # 80008028 <__func__.1+0x20>
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	02e080e7          	jalr	46(ra) # 80000598 <printf>
    printf(s);
    80000572:	8526                	mv	a0,s1
    80000574:	00000097          	auipc	ra,0x0
    80000578:	024080e7          	jalr	36(ra) # 80000598 <printf>
    printf("\n");
    8000057c:	00008517          	auipc	a0,0x8
    80000580:	b0c50513          	addi	a0,a0,-1268 # 80008088 <digits+0x38>
    80000584:	00000097          	auipc	ra,0x0
    80000588:	014080e7          	jalr	20(ra) # 80000598 <printf>
    panicked = 1; // freeze uart output from other CPUs
    8000058c:	4785                	li	a5,1
    8000058e:	00008717          	auipc	a4,0x8
    80000592:	4af72123          	sw	a5,1186(a4) # 80008a30 <panicked>
    for (;;)
    80000596:	a001                	j	80000596 <panic+0x5a>

0000000080000598 <printf>:
{
    80000598:	7131                	addi	sp,sp,-192
    8000059a:	fc86                	sd	ra,120(sp)
    8000059c:	f8a2                	sd	s0,112(sp)
    8000059e:	f4a6                	sd	s1,104(sp)
    800005a0:	f0ca                	sd	s2,96(sp)
    800005a2:	ecce                	sd	s3,88(sp)
    800005a4:	e8d2                	sd	s4,80(sp)
    800005a6:	e4d6                	sd	s5,72(sp)
    800005a8:	e0da                	sd	s6,64(sp)
    800005aa:	fc5e                	sd	s7,56(sp)
    800005ac:	f862                	sd	s8,48(sp)
    800005ae:	f466                	sd	s9,40(sp)
    800005b0:	f06a                	sd	s10,32(sp)
    800005b2:	ec6e                	sd	s11,24(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005ca:	00010d97          	auipc	s11,0x10
    800005ce:	6b6dad83          	lw	s11,1718(s11) # 80010c80 <pr+0x18>
    if (locking)
    800005d2:	020d9b63          	bnez	s11,80000608 <printf+0x70>
    if (fmt == 0)
    800005d6:	040a0263          	beqz	s4,8000061a <printf+0x82>
    va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	14050f63          	beqz	a0,80000744 <printf+0x1ac>
    800005ea:	4981                	li	s3,0
        if (c != '%')
    800005ec:	02500a93          	li	s5,37
        switch (c)
    800005f0:	07000b93          	li	s7,112
    consputc('x');
    800005f4:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f6:	00008b17          	auipc	s6,0x8
    800005fa:	a5ab0b13          	addi	s6,s6,-1446 # 80008050 <digits>
        switch (c)
    800005fe:	07300c93          	li	s9,115
    80000602:	06400c13          	li	s8,100
    80000606:	a82d                	j	80000640 <printf+0xa8>
        acquire(&pr.lock);
    80000608:	00010517          	auipc	a0,0x10
    8000060c:	66050513          	addi	a0,a0,1632 # 80010c68 <pr>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	68a080e7          	jalr	1674(ra) # 80000c9a <acquire>
    80000618:	bf7d                	j	800005d6 <printf+0x3e>
        panic("null fmt");
    8000061a:	00008517          	auipc	a0,0x8
    8000061e:	a1e50513          	addi	a0,a0,-1506 # 80008038 <__func__.1+0x30>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	f1a080e7          	jalr	-230(ra) # 8000053c <panic>
            consputc(c);
    8000062a:	00000097          	auipc	ra,0x0
    8000062e:	c4e080e7          	jalr	-946(ra) # 80000278 <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c503          	lbu	a0,0(a5)
    8000063c:	10050463          	beqz	a0,80000744 <printf+0x1ac>
        if (c != '%')
    80000640:	ff5515e3          	bne	a0,s5,8000062a <printf+0x92>
        c = fmt[++i] & 0xff;
    80000644:	2985                	addiw	s3,s3,1
    80000646:	013a07b3          	add	a5,s4,s3
    8000064a:	0007c783          	lbu	a5,0(a5)
    8000064e:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000652:	cbed                	beqz	a5,80000744 <printf+0x1ac>
        switch (c)
    80000654:	05778a63          	beq	a5,s7,800006a8 <printf+0x110>
    80000658:	02fbf663          	bgeu	s7,a5,80000684 <printf+0xec>
    8000065c:	09978863          	beq	a5,s9,800006ec <printf+0x154>
    80000660:	07800713          	li	a4,120
    80000664:	0ce79563          	bne	a5,a4,8000072e <printf+0x196>
            printint(va_arg(ap, int), 16, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	85ea                	mv	a1,s10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e1e080e7          	jalr	-482(ra) # 80000498 <printint>
            break;
    80000682:	bf45                	j	80000632 <printf+0x9a>
        switch (c)
    80000684:	09578f63          	beq	a5,s5,80000722 <printf+0x18a>
    80000688:	0b879363          	bne	a5,s8,8000072e <printf+0x196>
            printint(va_arg(ap, int), 10, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	45a9                	li	a1,10
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	dfa080e7          	jalr	-518(ra) # 80000498 <printint>
            break;
    800006a6:	b771                	j	80000632 <printf+0x9a>
            printptr(va_arg(ap, uint64));
    800006a8:	f8843783          	ld	a5,-120(s0)
    800006ac:	00878713          	addi	a4,a5,8
    800006b0:	f8e43423          	sd	a4,-120(s0)
    800006b4:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006b8:	03000513          	li	a0,48
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	bbc080e7          	jalr	-1092(ra) # 80000278 <consputc>
    consputc('x');
    800006c4:	07800513          	li	a0,120
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bb0080e7          	jalr	-1104(ra) # 80000278 <consputc>
    800006d0:	84ea                	mv	s1,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	03c95793          	srli	a5,s2,0x3c
    800006d6:	97da                	add	a5,a5,s6
    800006d8:	0007c503          	lbu	a0,0(a5)
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	b9c080e7          	jalr	-1124(ra) # 80000278 <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e4:	0912                	slli	s2,s2,0x4
    800006e6:	34fd                	addiw	s1,s1,-1
    800006e8:	f4ed                	bnez	s1,800006d2 <printf+0x13a>
    800006ea:	b7a1                	j	80000632 <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006ec:	f8843783          	ld	a5,-120(s0)
    800006f0:	00878713          	addi	a4,a5,8
    800006f4:	f8e43423          	sd	a4,-120(s0)
    800006f8:	6384                	ld	s1,0(a5)
    800006fa:	cc89                	beqz	s1,80000714 <printf+0x17c>
            for (; *s; s++)
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	d90d                	beqz	a0,80000632 <printf+0x9a>
                consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b76080e7          	jalr	-1162(ra) # 80000278 <consputc>
            for (; *s; s++)
    8000070a:	0485                	addi	s1,s1,1
    8000070c:	0004c503          	lbu	a0,0(s1)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x16a>
    80000712:	b705                	j	80000632 <printf+0x9a>
                s = "(null)";
    80000714:	00008497          	auipc	s1,0x8
    80000718:	91c48493          	addi	s1,s1,-1764 # 80008030 <__func__.1+0x28>
            for (; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x16a>
            consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b54080e7          	jalr	-1196(ra) # 80000278 <consputc>
            break;
    8000072c:	b719                	j	80000632 <printf+0x9a>
            consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b48080e7          	jalr	-1208(ra) # 80000278 <consputc>
            consputc(c);
    80000738:	8526                	mv	a0,s1
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b3e080e7          	jalr	-1218(ra) # 80000278 <consputc>
            break;
    80000742:	bdc5                	j	80000632 <printf+0x9a>
    if (locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1ce>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
        release(&pr.lock);
    80000766:	00010517          	auipc	a0,0x10
    8000076a:	50250513          	addi	a0,a0,1282 # 80010c68 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	5e0080e7          	jalr	1504(ra) # 80000d4e <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b0>

0000000080000778 <printfinit>:
        ;
}

void printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000782:	00010497          	auipc	s1,0x10
    80000786:	4e648493          	addi	s1,s1,1254 # 80010c68 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	8be58593          	addi	a1,a1,-1858 # 80008048 <__func__.1+0x40>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	476080e7          	jalr	1142(ra) # 80000c0a <initlock>
    pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	88e58593          	addi	a1,a1,-1906 # 80008068 <digits+0x18>
    800007e2:	00010517          	auipc	a0,0x10
    800007e6:	4a650513          	addi	a0,a0,1190 # 80010c88 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	420080e7          	jalr	1056(ra) # 80000c0a <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	448080e7          	jalr	1096(ra) # 80000c4e <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	2227a783          	lw	a5,546(a5) # 80008a30 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dfe5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f513          	zext.b	a0,s1
    8000082c:	100007b7          	lui	a5,0x10000
    80000830:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	4ba080e7          	jalr	1210(ra) # 80000cee <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008797          	auipc	a5,0x8
    8000084a:	1f27b783          	ld	a5,498(a5) # 80008a38 <uart_tx_r>
    8000084e:	00008717          	auipc	a4,0x8
    80000852:	1f273703          	ld	a4,498(a4) # 80008a40 <uart_tx_w>
    80000856:	06f70a63          	beq	a4,a5,800008ca <uartstart+0x84>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	418a0a13          	addi	s4,s4,1048 # 80010c88 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	1c048493          	addi	s1,s1,448 # 80008a38 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	1c098993          	addi	s3,s3,448 # 80008a40 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	02077713          	andi	a4,a4,32
    80000890:	c705                	beqz	a4,800008b8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000892:	01f7f713          	andi	a4,a5,31
    80000896:	9752                	add	a4,a4,s4
    80000898:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000089c:	0785                	addi	a5,a5,1
    8000089e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a0:	8526                	mv	a0,s1
    800008a2:	00002097          	auipc	ra,0x2
    800008a6:	a8c080e7          	jalr	-1396(ra) # 8000232e <wakeup>
    
    WriteReg(THR, c);
    800008aa:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ae:	609c                	ld	a5,0(s1)
    800008b0:	0009b703          	ld	a4,0(s3)
    800008b4:	fcf71ae3          	bne	a4,a5,80000888 <uartstart+0x42>
  }
}
    800008b8:	70e2                	ld	ra,56(sp)
    800008ba:	7442                	ld	s0,48(sp)
    800008bc:	74a2                	ld	s1,40(sp)
    800008be:	7902                	ld	s2,32(sp)
    800008c0:	69e2                	ld	s3,24(sp)
    800008c2:	6a42                	ld	s4,16(sp)
    800008c4:	6aa2                	ld	s5,8(sp)
    800008c6:	6121                	addi	sp,sp,64
    800008c8:	8082                	ret
    800008ca:	8082                	ret

00000000800008cc <uartputc>:
{
    800008cc:	7179                	addi	sp,sp,-48
    800008ce:	f406                	sd	ra,40(sp)
    800008d0:	f022                	sd	s0,32(sp)
    800008d2:	ec26                	sd	s1,24(sp)
    800008d4:	e84a                	sd	s2,16(sp)
    800008d6:	e44e                	sd	s3,8(sp)
    800008d8:	e052                	sd	s4,0(sp)
    800008da:	1800                	addi	s0,sp,48
    800008dc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008de:	00010517          	auipc	a0,0x10
    800008e2:	3aa50513          	addi	a0,a0,938 # 80010c88 <uart_tx_lock>
    800008e6:	00000097          	auipc	ra,0x0
    800008ea:	3b4080e7          	jalr	948(ra) # 80000c9a <acquire>
  if(panicked){
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	1427a783          	lw	a5,322(a5) # 80008a30 <panicked>
    800008f6:	e7c9                	bnez	a5,80000980 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008717          	auipc	a4,0x8
    800008fc:	14873703          	ld	a4,328(a4) # 80008a40 <uart_tx_w>
    80000900:	00008797          	auipc	a5,0x8
    80000904:	1387b783          	ld	a5,312(a5) # 80008a38 <uart_tx_r>
    80000908:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000090c:	00010997          	auipc	s3,0x10
    80000910:	37c98993          	addi	s3,s3,892 # 80010c88 <uart_tx_lock>
    80000914:	00008497          	auipc	s1,0x8
    80000918:	12448493          	addi	s1,s1,292 # 80008a38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000091c:	00008917          	auipc	s2,0x8
    80000920:	12490913          	addi	s2,s2,292 # 80008a40 <uart_tx_w>
    80000924:	00e79f63          	bne	a5,a4,80000942 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	8526                	mv	a0,s1
    8000092c:	00002097          	auipc	ra,0x2
    80000930:	99e080e7          	jalr	-1634(ra) # 800022ca <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093703          	ld	a4,0(s2)
    80000938:	609c                	ld	a5,0(s1)
    8000093a:	02078793          	addi	a5,a5,32
    8000093e:	fee785e3          	beq	a5,a4,80000928 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00010497          	auipc	s1,0x10
    80000946:	34648493          	addi	s1,s1,838 # 80010c88 <uart_tx_lock>
    8000094a:	01f77793          	andi	a5,a4,31
    8000094e:	97a6                	add	a5,a5,s1
    80000950:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000954:	0705                	addi	a4,a4,1
    80000956:	00008797          	auipc	a5,0x8
    8000095a:	0ee7b523          	sd	a4,234(a5) # 80008a40 <uart_tx_w>
  uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee8080e7          	jalr	-280(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	3e6080e7          	jalr	998(ra) # 80000d4e <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret
    for(;;)
    80000980:	a001                	j	80000980 <uartputc+0xb4>

0000000080000982 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000982:	1141                	addi	sp,sp,-16
    80000984:	e422                	sd	s0,8(sp)
    80000986:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000988:	100007b7          	lui	a5,0x10000
    8000098c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000990:	8b85                	andi	a5,a5,1
    80000992:	cb81                	beqz	a5,800009a2 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000994:	100007b7          	lui	a5,0x10000
    80000998:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000099c:	6422                	ld	s0,8(sp)
    8000099e:	0141                	addi	sp,sp,16
    800009a0:	8082                	ret
    return -1;
    800009a2:	557d                	li	a0,-1
    800009a4:	bfe5                	j	8000099c <uartgetc+0x1a>

00000000800009a6 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009a6:	1101                	addi	sp,sp,-32
    800009a8:	ec06                	sd	ra,24(sp)
    800009aa:	e822                	sd	s0,16(sp)
    800009ac:	e426                	sd	s1,8(sp)
    800009ae:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b0:	54fd                	li	s1,-1
    800009b2:	a029                	j	800009bc <uartintr+0x16>
      break;
    consoleintr(c);
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	906080e7          	jalr	-1786(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009bc:	00000097          	auipc	ra,0x0
    800009c0:	fc6080e7          	jalr	-58(ra) # 80000982 <uartgetc>
    if(c == -1)
    800009c4:	fe9518e3          	bne	a0,s1,800009b4 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009c8:	00010497          	auipc	s1,0x10
    800009cc:	2c048493          	addi	s1,s1,704 # 80010c88 <uart_tx_lock>
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2c8080e7          	jalr	712(ra) # 80000c9a <acquire>
  uartstart();
    800009da:	00000097          	auipc	ra,0x0
    800009de:	e6c080e7          	jalr	-404(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009e2:	8526                	mv	a0,s1
    800009e4:	00000097          	auipc	ra,0x0
    800009e8:	36a080e7          	jalr	874(ra) # 80000d4e <release>
}
    800009ec:	60e2                	ld	ra,24(sp)
    800009ee:	6442                	ld	s0,16(sp)
    800009f0:	64a2                	ld	s1,8(sp)
    800009f2:	6105                	addi	sp,sp,32
    800009f4:	8082                	ret

00000000800009f6 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009f6:	1101                	addi	sp,sp,-32
    800009f8:	ec06                	sd	ra,24(sp)
    800009fa:	e822                	sd	s0,16(sp)
    800009fc:	e426                	sd	s1,8(sp)
    800009fe:	e04a                	sd	s2,0(sp)
    80000a00:	1000                	addi	s0,sp,32
    80000a02:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a04:	00008797          	auipc	a5,0x8
    80000a08:	04c7b783          	ld	a5,76(a5) # 80008a50 <MAX_PAGES>
    80000a0c:	c799                	beqz	a5,80000a1a <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a0e:	00008717          	auipc	a4,0x8
    80000a12:	03a73703          	ld	a4,58(a4) # 80008a48 <FREE_PAGES>
    80000a16:	06f77663          	bgeu	a4,a5,80000a82 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a1a:	03449793          	slli	a5,s1,0x34
    80000a1e:	efc1                	bnez	a5,80000ab6 <kfree+0xc0>
    80000a20:	00021797          	auipc	a5,0x21
    80000a24:	4d078793          	addi	a5,a5,1232 # 80021ef0 <end>
    80000a28:	08f4e763          	bltu	s1,a5,80000ab6 <kfree+0xc0>
    80000a2c:	47c5                	li	a5,17
    80000a2e:	07ee                	slli	a5,a5,0x1b
    80000a30:	08f4f363          	bgeu	s1,a5,80000ab6 <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a34:	6605                	lui	a2,0x1
    80000a36:	4585                	li	a1,1
    80000a38:	8526                	mv	a0,s1
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	35c080e7          	jalr	860(ra) # 80000d96 <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000a42:	00010917          	auipc	s2,0x10
    80000a46:	27e90913          	addi	s2,s2,638 # 80010cc0 <kmem>
    80000a4a:	854a                	mv	a0,s2
    80000a4c:	00000097          	auipc	ra,0x0
    80000a50:	24e080e7          	jalr	590(ra) # 80000c9a <acquire>
    r->next = kmem.freelist;
    80000a54:	01893783          	ld	a5,24(s2)
    80000a58:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a5a:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a5e:	00008717          	auipc	a4,0x8
    80000a62:	fea70713          	addi	a4,a4,-22 # 80008a48 <FREE_PAGES>
    80000a66:	631c                	ld	a5,0(a4)
    80000a68:	0785                	addi	a5,a5,1
    80000a6a:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a6c:	854a                	mv	a0,s2
    80000a6e:	00000097          	auipc	ra,0x0
    80000a72:	2e0080e7          	jalr	736(ra) # 80000d4e <release>
}
    80000a76:	60e2                	ld	ra,24(sp)
    80000a78:	6442                	ld	s0,16(sp)
    80000a7a:	64a2                	ld	s1,8(sp)
    80000a7c:	6902                	ld	s2,0(sp)
    80000a7e:	6105                	addi	sp,sp,32
    80000a80:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000a82:	03700693          	li	a3,55
    80000a86:	00007617          	auipc	a2,0x7
    80000a8a:	58260613          	addi	a2,a2,1410 # 80008008 <__func__.1>
    80000a8e:	00007597          	auipc	a1,0x7
    80000a92:	5e258593          	addi	a1,a1,1506 # 80008070 <digits+0x20>
    80000a96:	00007517          	auipc	a0,0x7
    80000a9a:	5ea50513          	addi	a0,a0,1514 # 80008080 <digits+0x30>
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	afa080e7          	jalr	-1286(ra) # 80000598 <printf>
    80000aa6:	00007517          	auipc	a0,0x7
    80000aaa:	5ea50513          	addi	a0,a0,1514 # 80008090 <digits+0x40>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	a8e080e7          	jalr	-1394(ra) # 8000053c <panic>
        panic("kfree");
    80000ab6:	00007517          	auipc	a0,0x7
    80000aba:	5ea50513          	addi	a0,a0,1514 # 800080a0 <digits+0x50>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	a7e080e7          	jalr	-1410(ra) # 8000053c <panic>

0000000080000ac6 <freerange>:
{
    80000ac6:	7179                	addi	sp,sp,-48
    80000ac8:	f406                	sd	ra,40(sp)
    80000aca:	f022                	sd	s0,32(sp)
    80000acc:	ec26                	sd	s1,24(sp)
    80000ace:	e84a                	sd	s2,16(sp)
    80000ad0:	e44e                	sd	s3,8(sp)
    80000ad2:	e052                	sd	s4,0(sp)
    80000ad4:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000ad6:	6785                	lui	a5,0x1
    80000ad8:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000adc:	00e504b3          	add	s1,a0,a4
    80000ae0:	777d                	lui	a4,0xfffff
    80000ae2:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ae4:	94be                	add	s1,s1,a5
    80000ae6:	0095ee63          	bltu	a1,s1,80000b02 <freerange+0x3c>
    80000aea:	892e                	mv	s2,a1
        kfree(p);
    80000aec:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aee:	6985                	lui	s3,0x1
        kfree(p);
    80000af0:	01448533          	add	a0,s1,s4
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	f02080e7          	jalr	-254(ra) # 800009f6 <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000afc:	94ce                	add	s1,s1,s3
    80000afe:	fe9979e3          	bgeu	s2,s1,80000af0 <freerange+0x2a>
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6942                	ld	s2,16(sp)
    80000b0a:	69a2                	ld	s3,8(sp)
    80000b0c:	6a02                	ld	s4,0(sp)
    80000b0e:	6145                	addi	sp,sp,48
    80000b10:	8082                	ret

0000000080000b12 <kinit>:
{
    80000b12:	1141                	addi	sp,sp,-16
    80000b14:	e406                	sd	ra,8(sp)
    80000b16:	e022                	sd	s0,0(sp)
    80000b18:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b1a:	00007597          	auipc	a1,0x7
    80000b1e:	58e58593          	addi	a1,a1,1422 # 800080a8 <digits+0x58>
    80000b22:	00010517          	auipc	a0,0x10
    80000b26:	19e50513          	addi	a0,a0,414 # 80010cc0 <kmem>
    80000b2a:	00000097          	auipc	ra,0x0
    80000b2e:	0e0080e7          	jalr	224(ra) # 80000c0a <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b32:	45c5                	li	a1,17
    80000b34:	05ee                	slli	a1,a1,0x1b
    80000b36:	00021517          	auipc	a0,0x21
    80000b3a:	3ba50513          	addi	a0,a0,954 # 80021ef0 <end>
    80000b3e:	00000097          	auipc	ra,0x0
    80000b42:	f88080e7          	jalr	-120(ra) # 80000ac6 <freerange>
    MAX_PAGES = FREE_PAGES;
    80000b46:	00008797          	auipc	a5,0x8
    80000b4a:	f027b783          	ld	a5,-254(a5) # 80008a48 <FREE_PAGES>
    80000b4e:	00008717          	auipc	a4,0x8
    80000b52:	f0f73123          	sd	a5,-254(a4) # 80008a50 <MAX_PAGES>
}
    80000b56:	60a2                	ld	ra,8(sp)
    80000b58:	6402                	ld	s0,0(sp)
    80000b5a:	0141                	addi	sp,sp,16
    80000b5c:	8082                	ret

0000000080000b5e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000b68:	00008797          	auipc	a5,0x8
    80000b6c:	ee07b783          	ld	a5,-288(a5) # 80008a48 <FREE_PAGES>
    80000b70:	cbb1                	beqz	a5,80000bc4 <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000b72:	00010497          	auipc	s1,0x10
    80000b76:	14e48493          	addi	s1,s1,334 # 80010cc0 <kmem>
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	00000097          	auipc	ra,0x0
    80000b80:	11e080e7          	jalr	286(ra) # 80000c9a <acquire>
    r = kmem.freelist;
    80000b84:	6c84                	ld	s1,24(s1)
    if (r)
    80000b86:	c8ad                	beqz	s1,80000bf8 <kalloc+0x9a>
        kmem.freelist = r->next;
    80000b88:	609c                	ld	a5,0(s1)
    80000b8a:	00010517          	auipc	a0,0x10
    80000b8e:	13650513          	addi	a0,a0,310 # 80010cc0 <kmem>
    80000b92:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000b94:	00000097          	auipc	ra,0x0
    80000b98:	1ba080e7          	jalr	442(ra) # 80000d4e <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000b9c:	6605                	lui	a2,0x1
    80000b9e:	4595                	li	a1,5
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	00000097          	auipc	ra,0x0
    80000ba6:	1f4080e7          	jalr	500(ra) # 80000d96 <memset>
    FREE_PAGES--;
    80000baa:	00008717          	auipc	a4,0x8
    80000bae:	e9e70713          	addi	a4,a4,-354 # 80008a48 <FREE_PAGES>
    80000bb2:	631c                	ld	a5,0(a4)
    80000bb4:	17fd                	addi	a5,a5,-1
    80000bb6:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000bb8:	8526                	mv	a0,s1
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret
    assert(FREE_PAGES > 0);
    80000bc4:	04f00693          	li	a3,79
    80000bc8:	00007617          	auipc	a2,0x7
    80000bcc:	43860613          	addi	a2,a2,1080 # 80008000 <etext>
    80000bd0:	00007597          	auipc	a1,0x7
    80000bd4:	4a058593          	addi	a1,a1,1184 # 80008070 <digits+0x20>
    80000bd8:	00007517          	auipc	a0,0x7
    80000bdc:	4a850513          	addi	a0,a0,1192 # 80008080 <digits+0x30>
    80000be0:	00000097          	auipc	ra,0x0
    80000be4:	9b8080e7          	jalr	-1608(ra) # 80000598 <printf>
    80000be8:	00007517          	auipc	a0,0x7
    80000bec:	4a850513          	addi	a0,a0,1192 # 80008090 <digits+0x40>
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	94c080e7          	jalr	-1716(ra) # 8000053c <panic>
    release(&kmem.lock);
    80000bf8:	00010517          	auipc	a0,0x10
    80000bfc:	0c850513          	addi	a0,a0,200 # 80010cc0 <kmem>
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	14e080e7          	jalr	334(ra) # 80000d4e <release>
    if (r)
    80000c08:	b74d                	j	80000baa <kalloc+0x4c>

0000000080000c0a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c0a:	1141                	addi	sp,sp,-16
    80000c0c:	e422                	sd	s0,8(sp)
    80000c0e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c10:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c12:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c16:	00053823          	sd	zero,16(a0)
}
    80000c1a:	6422                	ld	s0,8(sp)
    80000c1c:	0141                	addi	sp,sp,16
    80000c1e:	8082                	ret

0000000080000c20 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c20:	411c                	lw	a5,0(a0)
    80000c22:	e399                	bnez	a5,80000c28 <holding+0x8>
    80000c24:	4501                	li	a0,0
  return r;
}
    80000c26:	8082                	ret
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c32:	6904                	ld	s1,16(a0)
    80000c34:	00001097          	auipc	ra,0x1
    80000c38:	f12080e7          	jalr	-238(ra) # 80001b46 <mycpu>
    80000c3c:	40a48533          	sub	a0,s1,a0
    80000c40:	00153513          	seqz	a0,a0
}
    80000c44:	60e2                	ld	ra,24(sp)
    80000c46:	6442                	ld	s0,16(sp)
    80000c48:	64a2                	ld	s1,8(sp)
    80000c4a:	6105                	addi	sp,sp,32
    80000c4c:	8082                	ret

0000000080000c4e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c4e:	1101                	addi	sp,sp,-32
    80000c50:	ec06                	sd	ra,24(sp)
    80000c52:	e822                	sd	s0,16(sp)
    80000c54:	e426                	sd	s1,8(sp)
    80000c56:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c58:	100024f3          	csrr	s1,sstatus
    80000c5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c62:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c66:	00001097          	auipc	ra,0x1
    80000c6a:	ee0080e7          	jalr	-288(ra) # 80001b46 <mycpu>
    80000c6e:	5d3c                	lw	a5,120(a0)
    80000c70:	cf89                	beqz	a5,80000c8a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c72:	00001097          	auipc	ra,0x1
    80000c76:	ed4080e7          	jalr	-300(ra) # 80001b46 <mycpu>
    80000c7a:	5d3c                	lw	a5,120(a0)
    80000c7c:	2785                	addiw	a5,a5,1
    80000c7e:	dd3c                	sw	a5,120(a0)
}
    80000c80:	60e2                	ld	ra,24(sp)
    80000c82:	6442                	ld	s0,16(sp)
    80000c84:	64a2                	ld	s1,8(sp)
    80000c86:	6105                	addi	sp,sp,32
    80000c88:	8082                	ret
    mycpu()->intena = old;
    80000c8a:	00001097          	auipc	ra,0x1
    80000c8e:	ebc080e7          	jalr	-324(ra) # 80001b46 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c92:	8085                	srli	s1,s1,0x1
    80000c94:	8885                	andi	s1,s1,1
    80000c96:	dd64                	sw	s1,124(a0)
    80000c98:	bfe9                	j	80000c72 <push_off+0x24>

0000000080000c9a <acquire>:
{
    80000c9a:	1101                	addi	sp,sp,-32
    80000c9c:	ec06                	sd	ra,24(sp)
    80000c9e:	e822                	sd	s0,16(sp)
    80000ca0:	e426                	sd	s1,8(sp)
    80000ca2:	1000                	addi	s0,sp,32
    80000ca4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ca6:	00000097          	auipc	ra,0x0
    80000caa:	fa8080e7          	jalr	-88(ra) # 80000c4e <push_off>
  if(holding(lk))
    80000cae:	8526                	mv	a0,s1
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f70080e7          	jalr	-144(ra) # 80000c20 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cb8:	4705                	li	a4,1
  if(holding(lk))
    80000cba:	e115                	bnez	a0,80000cde <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cbc:	87ba                	mv	a5,a4
    80000cbe:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cc2:	2781                	sext.w	a5,a5
    80000cc4:	ffe5                	bnez	a5,80000cbc <acquire+0x22>
  __sync_synchronize();
    80000cc6:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cca:	00001097          	auipc	ra,0x1
    80000cce:	e7c080e7          	jalr	-388(ra) # 80001b46 <mycpu>
    80000cd2:	e888                	sd	a0,16(s1)
}
    80000cd4:	60e2                	ld	ra,24(sp)
    80000cd6:	6442                	ld	s0,16(sp)
    80000cd8:	64a2                	ld	s1,8(sp)
    80000cda:	6105                	addi	sp,sp,32
    80000cdc:	8082                	ret
    panic("acquire");
    80000cde:	00007517          	auipc	a0,0x7
    80000ce2:	3d250513          	addi	a0,a0,978 # 800080b0 <digits+0x60>
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	856080e7          	jalr	-1962(ra) # 8000053c <panic>

0000000080000cee <pop_off>:

void
pop_off(void)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e406                	sd	ra,8(sp)
    80000cf2:	e022                	sd	s0,0(sp)
    80000cf4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cf6:	00001097          	auipc	ra,0x1
    80000cfa:	e50080e7          	jalr	-432(ra) # 80001b46 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cfe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d02:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d04:	e78d                	bnez	a5,80000d2e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d06:	5d3c                	lw	a5,120(a0)
    80000d08:	02f05b63          	blez	a5,80000d3e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d0c:	37fd                	addiw	a5,a5,-1
    80000d0e:	0007871b          	sext.w	a4,a5
    80000d12:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d14:	eb09                	bnez	a4,80000d26 <pop_off+0x38>
    80000d16:	5d7c                	lw	a5,124(a0)
    80000d18:	c799                	beqz	a5,80000d26 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d1a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d1e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d22:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d26:	60a2                	ld	ra,8(sp)
    80000d28:	6402                	ld	s0,0(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret
    panic("pop_off - interruptible");
    80000d2e:	00007517          	auipc	a0,0x7
    80000d32:	38a50513          	addi	a0,a0,906 # 800080b8 <digits+0x68>
    80000d36:	00000097          	auipc	ra,0x0
    80000d3a:	806080e7          	jalr	-2042(ra) # 8000053c <panic>
    panic("pop_off");
    80000d3e:	00007517          	auipc	a0,0x7
    80000d42:	39250513          	addi	a0,a0,914 # 800080d0 <digits+0x80>
    80000d46:	fffff097          	auipc	ra,0xfffff
    80000d4a:	7f6080e7          	jalr	2038(ra) # 8000053c <panic>

0000000080000d4e <release>:
{
    80000d4e:	1101                	addi	sp,sp,-32
    80000d50:	ec06                	sd	ra,24(sp)
    80000d52:	e822                	sd	s0,16(sp)
    80000d54:	e426                	sd	s1,8(sp)
    80000d56:	1000                	addi	s0,sp,32
    80000d58:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d5a:	00000097          	auipc	ra,0x0
    80000d5e:	ec6080e7          	jalr	-314(ra) # 80000c20 <holding>
    80000d62:	c115                	beqz	a0,80000d86 <release+0x38>
  lk->cpu = 0;
    80000d64:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d68:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d6c:	0f50000f          	fence	iorw,ow
    80000d70:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d74:	00000097          	auipc	ra,0x0
    80000d78:	f7a080e7          	jalr	-134(ra) # 80000cee <pop_off>
}
    80000d7c:	60e2                	ld	ra,24(sp)
    80000d7e:	6442                	ld	s0,16(sp)
    80000d80:	64a2                	ld	s1,8(sp)
    80000d82:	6105                	addi	sp,sp,32
    80000d84:	8082                	ret
    panic("release");
    80000d86:	00007517          	auipc	a0,0x7
    80000d8a:	35250513          	addi	a0,a0,850 # 800080d8 <digits+0x88>
    80000d8e:	fffff097          	auipc	ra,0xfffff
    80000d92:	7ae080e7          	jalr	1966(ra) # 8000053c <panic>

0000000080000d96 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d9c:	ca19                	beqz	a2,80000db2 <memset+0x1c>
    80000d9e:	87aa                	mv	a5,a0
    80000da0:	1602                	slli	a2,a2,0x20
    80000da2:	9201                	srli	a2,a2,0x20
    80000da4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000da8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000dac:	0785                	addi	a5,a5,1
    80000dae:	fee79de3          	bne	a5,a4,80000da8 <memset+0x12>
  }
  return dst;
}
    80000db2:	6422                	ld	s0,8(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dbe:	ca05                	beqz	a2,80000dee <memcmp+0x36>
    80000dc0:	fff6069b          	addiw	a3,a2,-1
    80000dc4:	1682                	slli	a3,a3,0x20
    80000dc6:	9281                	srli	a3,a3,0x20
    80000dc8:	0685                	addi	a3,a3,1
    80000dca:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dcc:	00054783          	lbu	a5,0(a0)
    80000dd0:	0005c703          	lbu	a4,0(a1)
    80000dd4:	00e79863          	bne	a5,a4,80000de4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dd8:	0505                	addi	a0,a0,1
    80000dda:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ddc:	fed518e3          	bne	a0,a3,80000dcc <memcmp+0x14>
  }

  return 0;
    80000de0:	4501                	li	a0,0
    80000de2:	a019                	j	80000de8 <memcmp+0x30>
      return *s1 - *s2;
    80000de4:	40e7853b          	subw	a0,a5,a4
}
    80000de8:	6422                	ld	s0,8(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret
  return 0;
    80000dee:	4501                	li	a0,0
    80000df0:	bfe5                	j	80000de8 <memcmp+0x30>

0000000080000df2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000df2:	1141                	addi	sp,sp,-16
    80000df4:	e422                	sd	s0,8(sp)
    80000df6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000df8:	c205                	beqz	a2,80000e18 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dfa:	02a5e263          	bltu	a1,a0,80000e1e <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dfe:	1602                	slli	a2,a2,0x20
    80000e00:	9201                	srli	a2,a2,0x20
    80000e02:	00c587b3          	add	a5,a1,a2
{
    80000e06:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e08:	0585                	addi	a1,a1,1
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	fff5c683          	lbu	a3,-1(a1)
    80000e10:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e14:	fef59ae3          	bne	a1,a5,80000e08 <memmove+0x16>

  return dst;
}
    80000e18:	6422                	ld	s0,8(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret
  if(s < d && s + n > d){
    80000e1e:	02061693          	slli	a3,a2,0x20
    80000e22:	9281                	srli	a3,a3,0x20
    80000e24:	00d58733          	add	a4,a1,a3
    80000e28:	fce57be3          	bgeu	a0,a4,80000dfe <memmove+0xc>
    d += n;
    80000e2c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e2e:	fff6079b          	addiw	a5,a2,-1
    80000e32:	1782                	slli	a5,a5,0x20
    80000e34:	9381                	srli	a5,a5,0x20
    80000e36:	fff7c793          	not	a5,a5
    80000e3a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e3c:	177d                	addi	a4,a4,-1
    80000e3e:	16fd                	addi	a3,a3,-1
    80000e40:	00074603          	lbu	a2,0(a4)
    80000e44:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e48:	fee79ae3          	bne	a5,a4,80000e3c <memmove+0x4a>
    80000e4c:	b7f1                	j	80000e18 <memmove+0x26>

0000000080000e4e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e406                	sd	ra,8(sp)
    80000e52:	e022                	sd	s0,0(sp)
    80000e54:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e56:	00000097          	auipc	ra,0x0
    80000e5a:	f9c080e7          	jalr	-100(ra) # 80000df2 <memmove>
}
    80000e5e:	60a2                	ld	ra,8(sp)
    80000e60:	6402                	ld	s0,0(sp)
    80000e62:	0141                	addi	sp,sp,16
    80000e64:	8082                	ret

0000000080000e66 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e66:	1141                	addi	sp,sp,-16
    80000e68:	e422                	sd	s0,8(sp)
    80000e6a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e6c:	ce11                	beqz	a2,80000e88 <strncmp+0x22>
    80000e6e:	00054783          	lbu	a5,0(a0)
    80000e72:	cf89                	beqz	a5,80000e8c <strncmp+0x26>
    80000e74:	0005c703          	lbu	a4,0(a1)
    80000e78:	00f71a63          	bne	a4,a5,80000e8c <strncmp+0x26>
    n--, p++, q++;
    80000e7c:	367d                	addiw	a2,a2,-1
    80000e7e:	0505                	addi	a0,a0,1
    80000e80:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e82:	f675                	bnez	a2,80000e6e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e84:	4501                	li	a0,0
    80000e86:	a809                	j	80000e98 <strncmp+0x32>
    80000e88:	4501                	li	a0,0
    80000e8a:	a039                	j	80000e98 <strncmp+0x32>
  if(n == 0)
    80000e8c:	ca09                	beqz	a2,80000e9e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e8e:	00054503          	lbu	a0,0(a0)
    80000e92:	0005c783          	lbu	a5,0(a1)
    80000e96:	9d1d                	subw	a0,a0,a5
}
    80000e98:	6422                	ld	s0,8(sp)
    80000e9a:	0141                	addi	sp,sp,16
    80000e9c:	8082                	ret
    return 0;
    80000e9e:	4501                	li	a0,0
    80000ea0:	bfe5                	j	80000e98 <strncmp+0x32>

0000000080000ea2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ea8:	87aa                	mv	a5,a0
    80000eaa:	86b2                	mv	a3,a2
    80000eac:	367d                	addiw	a2,a2,-1
    80000eae:	00d05963          	blez	a3,80000ec0 <strncpy+0x1e>
    80000eb2:	0785                	addi	a5,a5,1
    80000eb4:	0005c703          	lbu	a4,0(a1)
    80000eb8:	fee78fa3          	sb	a4,-1(a5)
    80000ebc:	0585                	addi	a1,a1,1
    80000ebe:	f775                	bnez	a4,80000eaa <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ec0:	873e                	mv	a4,a5
    80000ec2:	9fb5                	addw	a5,a5,a3
    80000ec4:	37fd                	addiw	a5,a5,-1
    80000ec6:	00c05963          	blez	a2,80000ed8 <strncpy+0x36>
    *s++ = 0;
    80000eca:	0705                	addi	a4,a4,1
    80000ecc:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000ed0:	40e786bb          	subw	a3,a5,a4
    80000ed4:	fed04be3          	bgtz	a3,80000eca <strncpy+0x28>
  return os;
}
    80000ed8:	6422                	ld	s0,8(sp)
    80000eda:	0141                	addi	sp,sp,16
    80000edc:	8082                	ret

0000000080000ede <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ede:	1141                	addi	sp,sp,-16
    80000ee0:	e422                	sd	s0,8(sp)
    80000ee2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ee4:	02c05363          	blez	a2,80000f0a <safestrcpy+0x2c>
    80000ee8:	fff6069b          	addiw	a3,a2,-1
    80000eec:	1682                	slli	a3,a3,0x20
    80000eee:	9281                	srli	a3,a3,0x20
    80000ef0:	96ae                	add	a3,a3,a1
    80000ef2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ef4:	00d58963          	beq	a1,a3,80000f06 <safestrcpy+0x28>
    80000ef8:	0585                	addi	a1,a1,1
    80000efa:	0785                	addi	a5,a5,1
    80000efc:	fff5c703          	lbu	a4,-1(a1)
    80000f00:	fee78fa3          	sb	a4,-1(a5)
    80000f04:	fb65                	bnez	a4,80000ef4 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f06:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f0a:	6422                	ld	s0,8(sp)
    80000f0c:	0141                	addi	sp,sp,16
    80000f0e:	8082                	ret

0000000080000f10 <strlen>:

int
strlen(const char *s)
{
    80000f10:	1141                	addi	sp,sp,-16
    80000f12:	e422                	sd	s0,8(sp)
    80000f14:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f16:	00054783          	lbu	a5,0(a0)
    80000f1a:	cf91                	beqz	a5,80000f36 <strlen+0x26>
    80000f1c:	0505                	addi	a0,a0,1
    80000f1e:	87aa                	mv	a5,a0
    80000f20:	86be                	mv	a3,a5
    80000f22:	0785                	addi	a5,a5,1
    80000f24:	fff7c703          	lbu	a4,-1(a5)
    80000f28:	ff65                	bnez	a4,80000f20 <strlen+0x10>
    80000f2a:	40a6853b          	subw	a0,a3,a0
    80000f2e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000f30:	6422                	ld	s0,8(sp)
    80000f32:	0141                	addi	sp,sp,16
    80000f34:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f36:	4501                	li	a0,0
    80000f38:	bfe5                	j	80000f30 <strlen+0x20>

0000000080000f3a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f3a:	1141                	addi	sp,sp,-16
    80000f3c:	e406                	sd	ra,8(sp)
    80000f3e:	e022                	sd	s0,0(sp)
    80000f40:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f42:	00001097          	auipc	ra,0x1
    80000f46:	bf4080e7          	jalr	-1036(ra) # 80001b36 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f4a:	00008717          	auipc	a4,0x8
    80000f4e:	b0e70713          	addi	a4,a4,-1266 # 80008a58 <started>
  if(cpuid() == 0){
    80000f52:	c139                	beqz	a0,80000f98 <main+0x5e>
    while(started == 0)
    80000f54:	431c                	lw	a5,0(a4)
    80000f56:	2781                	sext.w	a5,a5
    80000f58:	dff5                	beqz	a5,80000f54 <main+0x1a>
      ;
    __sync_synchronize();
    80000f5a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f5e:	00001097          	auipc	ra,0x1
    80000f62:	bd8080e7          	jalr	-1064(ra) # 80001b36 <cpuid>
    80000f66:	85aa                	mv	a1,a0
    80000f68:	00007517          	auipc	a0,0x7
    80000f6c:	19050513          	addi	a0,a0,400 # 800080f8 <digits+0xa8>
    80000f70:	fffff097          	auipc	ra,0xfffff
    80000f74:	628080e7          	jalr	1576(ra) # 80000598 <printf>
    kvminithart();    // turn on paging
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	0d8080e7          	jalr	216(ra) # 80001050 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f80:	00002097          	auipc	ra,0x2
    80000f84:	acc080e7          	jalr	-1332(ra) # 80002a4c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f88:	00005097          	auipc	ra,0x5
    80000f8c:	178080e7          	jalr	376(ra) # 80006100 <plicinithart>
  }

  scheduler();        
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	218080e7          	jalr	536(ra) # 800021a8 <scheduler>
    consoleinit();
    80000f98:	fffff097          	auipc	ra,0xfffff
    80000f9c:	4b4080e7          	jalr	1204(ra) # 8000044c <consoleinit>
    printfinit();
    80000fa0:	fffff097          	auipc	ra,0xfffff
    80000fa4:	7d8080e7          	jalr	2008(ra) # 80000778 <printfinit>
    printf("\n");
    80000fa8:	00007517          	auipc	a0,0x7
    80000fac:	0e050513          	addi	a0,a0,224 # 80008088 <digits+0x38>
    80000fb0:	fffff097          	auipc	ra,0xfffff
    80000fb4:	5e8080e7          	jalr	1512(ra) # 80000598 <printf>
    printf("xv6 kernel is booting\n");
    80000fb8:	00007517          	auipc	a0,0x7
    80000fbc:	12850513          	addi	a0,a0,296 # 800080e0 <digits+0x90>
    80000fc0:	fffff097          	auipc	ra,0xfffff
    80000fc4:	5d8080e7          	jalr	1496(ra) # 80000598 <printf>
    printf("\n");
    80000fc8:	00007517          	auipc	a0,0x7
    80000fcc:	0c050513          	addi	a0,a0,192 # 80008088 <digits+0x38>
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	5c8080e7          	jalr	1480(ra) # 80000598 <printf>
    kinit();         // physical page allocator
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	b3a080e7          	jalr	-1222(ra) # 80000b12 <kinit>
    kvminit();       // create kernel page table
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	326080e7          	jalr	806(ra) # 80001306 <kvminit>
    kvminithart();   // turn on paging
    80000fe8:	00000097          	auipc	ra,0x0
    80000fec:	068080e7          	jalr	104(ra) # 80001050 <kvminithart>
    procinit();      // process table
    80000ff0:	00001097          	auipc	ra,0x1
    80000ff4:	a6e080e7          	jalr	-1426(ra) # 80001a5e <procinit>
    trapinit();      // trap vectors
    80000ff8:	00002097          	auipc	ra,0x2
    80000ffc:	a2c080e7          	jalr	-1492(ra) # 80002a24 <trapinit>
    trapinithart();  // install kernel trap vector
    80001000:	00002097          	auipc	ra,0x2
    80001004:	a4c080e7          	jalr	-1460(ra) # 80002a4c <trapinithart>
    plicinit();      // set up interrupt controller
    80001008:	00005097          	auipc	ra,0x5
    8000100c:	0e2080e7          	jalr	226(ra) # 800060ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001010:	00005097          	auipc	ra,0x5
    80001014:	0f0080e7          	jalr	240(ra) # 80006100 <plicinithart>
    binit();         // buffer cache
    80001018:	00002097          	auipc	ra,0x2
    8000101c:	2ec080e7          	jalr	748(ra) # 80003304 <binit>
    iinit();         // inode table
    80001020:	00003097          	auipc	ra,0x3
    80001024:	98a080e7          	jalr	-1654(ra) # 800039aa <iinit>
    fileinit();      // file table
    80001028:	00004097          	auipc	ra,0x4
    8000102c:	900080e7          	jalr	-1792(ra) # 80004928 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001030:	00005097          	auipc	ra,0x5
    80001034:	1d8080e7          	jalr	472(ra) # 80006208 <virtio_disk_init>
    userinit();      // first user process
    80001038:	00001097          	auipc	ra,0x1
    8000103c:	e02080e7          	jalr	-510(ra) # 80001e3a <userinit>
    __sync_synchronize();
    80001040:	0ff0000f          	fence
    started = 1;
    80001044:	4785                	li	a5,1
    80001046:	00008717          	auipc	a4,0x8
    8000104a:	a0f72923          	sw	a5,-1518(a4) # 80008a58 <started>
    8000104e:	b789                	j	80000f90 <main+0x56>

0000000080001050 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001050:	1141                	addi	sp,sp,-16
    80001052:	e422                	sd	s0,8(sp)
    80001054:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001056:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000105a:	00008797          	auipc	a5,0x8
    8000105e:	a067b783          	ld	a5,-1530(a5) # 80008a60 <kernel_pagetable>
    80001062:	83b1                	srli	a5,a5,0xc
    80001064:	577d                	li	a4,-1
    80001066:	177e                	slli	a4,a4,0x3f
    80001068:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000106a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000106e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001072:	6422                	ld	s0,8(sp)
    80001074:	0141                	addi	sp,sp,16
    80001076:	8082                	ret

0000000080001078 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001078:	7139                	addi	sp,sp,-64
    8000107a:	fc06                	sd	ra,56(sp)
    8000107c:	f822                	sd	s0,48(sp)
    8000107e:	f426                	sd	s1,40(sp)
    80001080:	f04a                	sd	s2,32(sp)
    80001082:	ec4e                	sd	s3,24(sp)
    80001084:	e852                	sd	s4,16(sp)
    80001086:	e456                	sd	s5,8(sp)
    80001088:	e05a                	sd	s6,0(sp)
    8000108a:	0080                	addi	s0,sp,64
    8000108c:	84aa                	mv	s1,a0
    8000108e:	89ae                	mv	s3,a1
    80001090:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001092:	57fd                	li	a5,-1
    80001094:	83e9                	srli	a5,a5,0x1a
    80001096:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001098:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000109a:	04b7f263          	bgeu	a5,a1,800010de <walk+0x66>
    panic("walk");
    8000109e:	00007517          	auipc	a0,0x7
    800010a2:	07250513          	addi	a0,a0,114 # 80008110 <digits+0xc0>
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	496080e7          	jalr	1174(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010ae:	060a8663          	beqz	s5,8000111a <walk+0xa2>
    800010b2:	00000097          	auipc	ra,0x0
    800010b6:	aac080e7          	jalr	-1364(ra) # 80000b5e <kalloc>
    800010ba:	84aa                	mv	s1,a0
    800010bc:	c529                	beqz	a0,80001106 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010be:	6605                	lui	a2,0x1
    800010c0:	4581                	li	a1,0
    800010c2:	00000097          	auipc	ra,0x0
    800010c6:	cd4080e7          	jalr	-812(ra) # 80000d96 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010ca:	00c4d793          	srli	a5,s1,0xc
    800010ce:	07aa                	slli	a5,a5,0xa
    800010d0:	0017e793          	ori	a5,a5,1
    800010d4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010d8:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd107>
    800010da:	036a0063          	beq	s4,s6,800010fa <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010de:	0149d933          	srl	s2,s3,s4
    800010e2:	1ff97913          	andi	s2,s2,511
    800010e6:	090e                	slli	s2,s2,0x3
    800010e8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010ea:	00093483          	ld	s1,0(s2)
    800010ee:	0014f793          	andi	a5,s1,1
    800010f2:	dfd5                	beqz	a5,800010ae <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010f4:	80a9                	srli	s1,s1,0xa
    800010f6:	04b2                	slli	s1,s1,0xc
    800010f8:	b7c5                	j	800010d8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010fa:	00c9d513          	srli	a0,s3,0xc
    800010fe:	1ff57513          	andi	a0,a0,511
    80001102:	050e                	slli	a0,a0,0x3
    80001104:	9526                	add	a0,a0,s1
}
    80001106:	70e2                	ld	ra,56(sp)
    80001108:	7442                	ld	s0,48(sp)
    8000110a:	74a2                	ld	s1,40(sp)
    8000110c:	7902                	ld	s2,32(sp)
    8000110e:	69e2                	ld	s3,24(sp)
    80001110:	6a42                	ld	s4,16(sp)
    80001112:	6aa2                	ld	s5,8(sp)
    80001114:	6b02                	ld	s6,0(sp)
    80001116:	6121                	addi	sp,sp,64
    80001118:	8082                	ret
        return 0;
    8000111a:	4501                	li	a0,0
    8000111c:	b7ed                	j	80001106 <walk+0x8e>

000000008000111e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000111e:	57fd                	li	a5,-1
    80001120:	83e9                	srli	a5,a5,0x1a
    80001122:	00b7f463          	bgeu	a5,a1,8000112a <walkaddr+0xc>
    return 0;
    80001126:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001128:	8082                	ret
{
    8000112a:	1141                	addi	sp,sp,-16
    8000112c:	e406                	sd	ra,8(sp)
    8000112e:	e022                	sd	s0,0(sp)
    80001130:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001132:	4601                	li	a2,0
    80001134:	00000097          	auipc	ra,0x0
    80001138:	f44080e7          	jalr	-188(ra) # 80001078 <walk>
  if(pte == 0)
    8000113c:	c105                	beqz	a0,8000115c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000113e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001140:	0117f693          	andi	a3,a5,17
    80001144:	4745                	li	a4,17
    return 0;
    80001146:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001148:	00e68663          	beq	a3,a4,80001154 <walkaddr+0x36>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
  pa = PTE2PA(*pte);
    80001154:	83a9                	srli	a5,a5,0xa
    80001156:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000115a:	bfcd                	j	8000114c <walkaddr+0x2e>
    return 0;
    8000115c:	4501                	li	a0,0
    8000115e:	b7fd                	j	8000114c <walkaddr+0x2e>

0000000080001160 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001160:	715d                	addi	sp,sp,-80
    80001162:	e486                	sd	ra,72(sp)
    80001164:	e0a2                	sd	s0,64(sp)
    80001166:	fc26                	sd	s1,56(sp)
    80001168:	f84a                	sd	s2,48(sp)
    8000116a:	f44e                	sd	s3,40(sp)
    8000116c:	f052                	sd	s4,32(sp)
    8000116e:	ec56                	sd	s5,24(sp)
    80001170:	e85a                	sd	s6,16(sp)
    80001172:	e45e                	sd	s7,8(sp)
    80001174:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001176:	c639                	beqz	a2,800011c4 <mappages+0x64>
    80001178:	8aaa                	mv	s5,a0
    8000117a:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000117c:	777d                	lui	a4,0xfffff
    8000117e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001182:	fff58993          	addi	s3,a1,-1
    80001186:	99b2                	add	s3,s3,a2
    80001188:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000118c:	893e                	mv	s2,a5
    8000118e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001192:	6b85                	lui	s7,0x1
    80001194:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001198:	4605                	li	a2,1
    8000119a:	85ca                	mv	a1,s2
    8000119c:	8556                	mv	a0,s5
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	eda080e7          	jalr	-294(ra) # 80001078 <walk>
    800011a6:	cd1d                	beqz	a0,800011e4 <mappages+0x84>
    if(*pte & PTE_V)
    800011a8:	611c                	ld	a5,0(a0)
    800011aa:	8b85                	andi	a5,a5,1
    800011ac:	e785                	bnez	a5,800011d4 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011ae:	80b1                	srli	s1,s1,0xc
    800011b0:	04aa                	slli	s1,s1,0xa
    800011b2:	0164e4b3          	or	s1,s1,s6
    800011b6:	0014e493          	ori	s1,s1,1
    800011ba:	e104                	sd	s1,0(a0)
    if(a == last)
    800011bc:	05390063          	beq	s2,s3,800011fc <mappages+0x9c>
    a += PGSIZE;
    800011c0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011c2:	bfc9                	j	80001194 <mappages+0x34>
    panic("mappages: size");
    800011c4:	00007517          	auipc	a0,0x7
    800011c8:	f5450513          	addi	a0,a0,-172 # 80008118 <digits+0xc8>
    800011cc:	fffff097          	auipc	ra,0xfffff
    800011d0:	370080e7          	jalr	880(ra) # 8000053c <panic>
      panic("mappages: remap");
    800011d4:	00007517          	auipc	a0,0x7
    800011d8:	f5450513          	addi	a0,a0,-172 # 80008128 <digits+0xd8>
    800011dc:	fffff097          	auipc	ra,0xfffff
    800011e0:	360080e7          	jalr	864(ra) # 8000053c <panic>
      return -1;
    800011e4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011e6:	60a6                	ld	ra,72(sp)
    800011e8:	6406                	ld	s0,64(sp)
    800011ea:	74e2                	ld	s1,56(sp)
    800011ec:	7942                	ld	s2,48(sp)
    800011ee:	79a2                	ld	s3,40(sp)
    800011f0:	7a02                	ld	s4,32(sp)
    800011f2:	6ae2                	ld	s5,24(sp)
    800011f4:	6b42                	ld	s6,16(sp)
    800011f6:	6ba2                	ld	s7,8(sp)
    800011f8:	6161                	addi	sp,sp,80
    800011fa:	8082                	ret
  return 0;
    800011fc:	4501                	li	a0,0
    800011fe:	b7e5                	j	800011e6 <mappages+0x86>

0000000080001200 <kvmmap>:
{
    80001200:	1141                	addi	sp,sp,-16
    80001202:	e406                	sd	ra,8(sp)
    80001204:	e022                	sd	s0,0(sp)
    80001206:	0800                	addi	s0,sp,16
    80001208:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000120a:	86b2                	mv	a3,a2
    8000120c:	863e                	mv	a2,a5
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f52080e7          	jalr	-174(ra) # 80001160 <mappages>
    80001216:	e509                	bnez	a0,80001220 <kvmmap+0x20>
}
    80001218:	60a2                	ld	ra,8(sp)
    8000121a:	6402                	ld	s0,0(sp)
    8000121c:	0141                	addi	sp,sp,16
    8000121e:	8082                	ret
    panic("kvmmap");
    80001220:	00007517          	auipc	a0,0x7
    80001224:	f1850513          	addi	a0,a0,-232 # 80008138 <digits+0xe8>
    80001228:	fffff097          	auipc	ra,0xfffff
    8000122c:	314080e7          	jalr	788(ra) # 8000053c <panic>

0000000080001230 <kvmmake>:
{
    80001230:	1101                	addi	sp,sp,-32
    80001232:	ec06                	sd	ra,24(sp)
    80001234:	e822                	sd	s0,16(sp)
    80001236:	e426                	sd	s1,8(sp)
    80001238:	e04a                	sd	s2,0(sp)
    8000123a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000123c:	00000097          	auipc	ra,0x0
    80001240:	922080e7          	jalr	-1758(ra) # 80000b5e <kalloc>
    80001244:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001246:	6605                	lui	a2,0x1
    80001248:	4581                	li	a1,0
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	b4c080e7          	jalr	-1204(ra) # 80000d96 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001252:	4719                	li	a4,6
    80001254:	6685                	lui	a3,0x1
    80001256:	10000637          	lui	a2,0x10000
    8000125a:	100005b7          	lui	a1,0x10000
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	fa0080e7          	jalr	-96(ra) # 80001200 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001268:	4719                	li	a4,6
    8000126a:	6685                	lui	a3,0x1
    8000126c:	10001637          	lui	a2,0x10001
    80001270:	100015b7          	lui	a1,0x10001
    80001274:	8526                	mv	a0,s1
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	f8a080e7          	jalr	-118(ra) # 80001200 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000127e:	4719                	li	a4,6
    80001280:	004006b7          	lui	a3,0x400
    80001284:	0c000637          	lui	a2,0xc000
    80001288:	0c0005b7          	lui	a1,0xc000
    8000128c:	8526                	mv	a0,s1
    8000128e:	00000097          	auipc	ra,0x0
    80001292:	f72080e7          	jalr	-142(ra) # 80001200 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001296:	00007917          	auipc	s2,0x7
    8000129a:	d6a90913          	addi	s2,s2,-662 # 80008000 <etext>
    8000129e:	4729                	li	a4,10
    800012a0:	80007697          	auipc	a3,0x80007
    800012a4:	d6068693          	addi	a3,a3,-672 # 8000 <_entry-0x7fff8000>
    800012a8:	4605                	li	a2,1
    800012aa:	067e                	slli	a2,a2,0x1f
    800012ac:	85b2                	mv	a1,a2
    800012ae:	8526                	mv	a0,s1
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	f50080e7          	jalr	-176(ra) # 80001200 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012b8:	4719                	li	a4,6
    800012ba:	46c5                	li	a3,17
    800012bc:	06ee                	slli	a3,a3,0x1b
    800012be:	412686b3          	sub	a3,a3,s2
    800012c2:	864a                	mv	a2,s2
    800012c4:	85ca                	mv	a1,s2
    800012c6:	8526                	mv	a0,s1
    800012c8:	00000097          	auipc	ra,0x0
    800012cc:	f38080e7          	jalr	-200(ra) # 80001200 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012d0:	4729                	li	a4,10
    800012d2:	6685                	lui	a3,0x1
    800012d4:	00006617          	auipc	a2,0x6
    800012d8:	d2c60613          	addi	a2,a2,-724 # 80007000 <_trampoline>
    800012dc:	040005b7          	lui	a1,0x4000
    800012e0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012e2:	05b2                	slli	a1,a1,0xc
    800012e4:	8526                	mv	a0,s1
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	f1a080e7          	jalr	-230(ra) # 80001200 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012ee:	8526                	mv	a0,s1
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	6d8080e7          	jalr	1752(ra) # 800019c8 <proc_mapstacks>
}
    800012f8:	8526                	mv	a0,s1
    800012fa:	60e2                	ld	ra,24(sp)
    800012fc:	6442                	ld	s0,16(sp)
    800012fe:	64a2                	ld	s1,8(sp)
    80001300:	6902                	ld	s2,0(sp)
    80001302:	6105                	addi	sp,sp,32
    80001304:	8082                	ret

0000000080001306 <kvminit>:
{
    80001306:	1141                	addi	sp,sp,-16
    80001308:	e406                	sd	ra,8(sp)
    8000130a:	e022                	sd	s0,0(sp)
    8000130c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	f22080e7          	jalr	-222(ra) # 80001230 <kvmmake>
    80001316:	00007797          	auipc	a5,0x7
    8000131a:	74a7b523          	sd	a0,1866(a5) # 80008a60 <kernel_pagetable>
}
    8000131e:	60a2                	ld	ra,8(sp)
    80001320:	6402                	ld	s0,0(sp)
    80001322:	0141                	addi	sp,sp,16
    80001324:	8082                	ret

0000000080001326 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001326:	715d                	addi	sp,sp,-80
    80001328:	e486                	sd	ra,72(sp)
    8000132a:	e0a2                	sd	s0,64(sp)
    8000132c:	fc26                	sd	s1,56(sp)
    8000132e:	f84a                	sd	s2,48(sp)
    80001330:	f44e                	sd	s3,40(sp)
    80001332:	f052                	sd	s4,32(sp)
    80001334:	ec56                	sd	s5,24(sp)
    80001336:	e85a                	sd	s6,16(sp)
    80001338:	e45e                	sd	s7,8(sp)
    8000133a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000133c:	03459793          	slli	a5,a1,0x34
    80001340:	e795                	bnez	a5,8000136c <uvmunmap+0x46>
    80001342:	8a2a                	mv	s4,a0
    80001344:	892e                	mv	s2,a1
    80001346:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001348:	0632                	slli	a2,a2,0xc
    8000134a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000134e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001350:	6b05                	lui	s6,0x1
    80001352:	0735e263          	bltu	a1,s3,800013b6 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001356:	60a6                	ld	ra,72(sp)
    80001358:	6406                	ld	s0,64(sp)
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	7942                	ld	s2,48(sp)
    8000135e:	79a2                	ld	s3,40(sp)
    80001360:	7a02                	ld	s4,32(sp)
    80001362:	6ae2                	ld	s5,24(sp)
    80001364:	6b42                	ld	s6,16(sp)
    80001366:	6ba2                	ld	s7,8(sp)
    80001368:	6161                	addi	sp,sp,80
    8000136a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000136c:	00007517          	auipc	a0,0x7
    80001370:	dd450513          	addi	a0,a0,-556 # 80008140 <digits+0xf0>
    80001374:	fffff097          	auipc	ra,0xfffff
    80001378:	1c8080e7          	jalr	456(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    8000137c:	00007517          	auipc	a0,0x7
    80001380:	ddc50513          	addi	a0,a0,-548 # 80008158 <digits+0x108>
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	1b8080e7          	jalr	440(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    8000138c:	00007517          	auipc	a0,0x7
    80001390:	ddc50513          	addi	a0,a0,-548 # 80008168 <digits+0x118>
    80001394:	fffff097          	auipc	ra,0xfffff
    80001398:	1a8080e7          	jalr	424(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    8000139c:	00007517          	auipc	a0,0x7
    800013a0:	de450513          	addi	a0,a0,-540 # 80008180 <digits+0x130>
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	198080e7          	jalr	408(ra) # 8000053c <panic>
    *pte = 0;
    800013ac:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013b0:	995a                	add	s2,s2,s6
    800013b2:	fb3972e3          	bgeu	s2,s3,80001356 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013b6:	4601                	li	a2,0
    800013b8:	85ca                	mv	a1,s2
    800013ba:	8552                	mv	a0,s4
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	cbc080e7          	jalr	-836(ra) # 80001078 <walk>
    800013c4:	84aa                	mv	s1,a0
    800013c6:	d95d                	beqz	a0,8000137c <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013c8:	6108                	ld	a0,0(a0)
    800013ca:	00157793          	andi	a5,a0,1
    800013ce:	dfdd                	beqz	a5,8000138c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013d0:	3ff57793          	andi	a5,a0,1023
    800013d4:	fd7784e3          	beq	a5,s7,8000139c <uvmunmap+0x76>
    if(do_free){
    800013d8:	fc0a8ae3          	beqz	s5,800013ac <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013dc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013de:	0532                	slli	a0,a0,0xc
    800013e0:	fffff097          	auipc	ra,0xfffff
    800013e4:	616080e7          	jalr	1558(ra) # 800009f6 <kfree>
    800013e8:	b7d1                	j	800013ac <uvmunmap+0x86>

00000000800013ea <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013ea:	1101                	addi	sp,sp,-32
    800013ec:	ec06                	sd	ra,24(sp)
    800013ee:	e822                	sd	s0,16(sp)
    800013f0:	e426                	sd	s1,8(sp)
    800013f2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013f4:	fffff097          	auipc	ra,0xfffff
    800013f8:	76a080e7          	jalr	1898(ra) # 80000b5e <kalloc>
    800013fc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013fe:	c519                	beqz	a0,8000140c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001400:	6605                	lui	a2,0x1
    80001402:	4581                	li	a1,0
    80001404:	00000097          	auipc	ra,0x0
    80001408:	992080e7          	jalr	-1646(ra) # 80000d96 <memset>
  return pagetable;
}
    8000140c:	8526                	mv	a0,s1
    8000140e:	60e2                	ld	ra,24(sp)
    80001410:	6442                	ld	s0,16(sp)
    80001412:	64a2                	ld	s1,8(sp)
    80001414:	6105                	addi	sp,sp,32
    80001416:	8082                	ret

0000000080001418 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001418:	7179                	addi	sp,sp,-48
    8000141a:	f406                	sd	ra,40(sp)
    8000141c:	f022                	sd	s0,32(sp)
    8000141e:	ec26                	sd	s1,24(sp)
    80001420:	e84a                	sd	s2,16(sp)
    80001422:	e44e                	sd	s3,8(sp)
    80001424:	e052                	sd	s4,0(sp)
    80001426:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001428:	6785                	lui	a5,0x1
    8000142a:	04f67863          	bgeu	a2,a5,8000147a <uvmfirst+0x62>
    8000142e:	8a2a                	mv	s4,a0
    80001430:	89ae                	mv	s3,a1
    80001432:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001434:	fffff097          	auipc	ra,0xfffff
    80001438:	72a080e7          	jalr	1834(ra) # 80000b5e <kalloc>
    8000143c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000143e:	6605                	lui	a2,0x1
    80001440:	4581                	li	a1,0
    80001442:	00000097          	auipc	ra,0x0
    80001446:	954080e7          	jalr	-1708(ra) # 80000d96 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000144a:	4779                	li	a4,30
    8000144c:	86ca                	mv	a3,s2
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	8552                	mv	a0,s4
    80001454:	00000097          	auipc	ra,0x0
    80001458:	d0c080e7          	jalr	-756(ra) # 80001160 <mappages>
  memmove(mem, src, sz);
    8000145c:	8626                	mv	a2,s1
    8000145e:	85ce                	mv	a1,s3
    80001460:	854a                	mv	a0,s2
    80001462:	00000097          	auipc	ra,0x0
    80001466:	990080e7          	jalr	-1648(ra) # 80000df2 <memmove>
}
    8000146a:	70a2                	ld	ra,40(sp)
    8000146c:	7402                	ld	s0,32(sp)
    8000146e:	64e2                	ld	s1,24(sp)
    80001470:	6942                	ld	s2,16(sp)
    80001472:	69a2                	ld	s3,8(sp)
    80001474:	6a02                	ld	s4,0(sp)
    80001476:	6145                	addi	sp,sp,48
    80001478:	8082                	ret
    panic("uvmfirst: more than a page");
    8000147a:	00007517          	auipc	a0,0x7
    8000147e:	d1e50513          	addi	a0,a0,-738 # 80008198 <digits+0x148>
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	0ba080e7          	jalr	186(ra) # 8000053c <panic>

000000008000148a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000148a:	1101                	addi	sp,sp,-32
    8000148c:	ec06                	sd	ra,24(sp)
    8000148e:	e822                	sd	s0,16(sp)
    80001490:	e426                	sd	s1,8(sp)
    80001492:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001494:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001496:	00b67d63          	bgeu	a2,a1,800014b0 <uvmdealloc+0x26>
    8000149a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000149c:	6785                	lui	a5,0x1
    8000149e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014a0:	00f60733          	add	a4,a2,a5
    800014a4:	76fd                	lui	a3,0xfffff
    800014a6:	8f75                	and	a4,a4,a3
    800014a8:	97ae                	add	a5,a5,a1
    800014aa:	8ff5                	and	a5,a5,a3
    800014ac:	00f76863          	bltu	a4,a5,800014bc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014b0:	8526                	mv	a0,s1
    800014b2:	60e2                	ld	ra,24(sp)
    800014b4:	6442                	ld	s0,16(sp)
    800014b6:	64a2                	ld	s1,8(sp)
    800014b8:	6105                	addi	sp,sp,32
    800014ba:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014bc:	8f99                	sub	a5,a5,a4
    800014be:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014c0:	4685                	li	a3,1
    800014c2:	0007861b          	sext.w	a2,a5
    800014c6:	85ba                	mv	a1,a4
    800014c8:	00000097          	auipc	ra,0x0
    800014cc:	e5e080e7          	jalr	-418(ra) # 80001326 <uvmunmap>
    800014d0:	b7c5                	j	800014b0 <uvmdealloc+0x26>

00000000800014d2 <uvmalloc>:
  if(newsz < oldsz)
    800014d2:	0ab66563          	bltu	a2,a1,8000157c <uvmalloc+0xaa>
{
    800014d6:	7139                	addi	sp,sp,-64
    800014d8:	fc06                	sd	ra,56(sp)
    800014da:	f822                	sd	s0,48(sp)
    800014dc:	f426                	sd	s1,40(sp)
    800014de:	f04a                	sd	s2,32(sp)
    800014e0:	ec4e                	sd	s3,24(sp)
    800014e2:	e852                	sd	s4,16(sp)
    800014e4:	e456                	sd	s5,8(sp)
    800014e6:	e05a                	sd	s6,0(sp)
    800014e8:	0080                	addi	s0,sp,64
    800014ea:	8aaa                	mv	s5,a0
    800014ec:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014ee:	6785                	lui	a5,0x1
    800014f0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014f2:	95be                	add	a1,a1,a5
    800014f4:	77fd                	lui	a5,0xfffff
    800014f6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014fa:	08c9f363          	bgeu	s3,a2,80001580 <uvmalloc+0xae>
    800014fe:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001500:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	65a080e7          	jalr	1626(ra) # 80000b5e <kalloc>
    8000150c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000150e:	c51d                	beqz	a0,8000153c <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001510:	6605                	lui	a2,0x1
    80001512:	4581                	li	a1,0
    80001514:	00000097          	auipc	ra,0x0
    80001518:	882080e7          	jalr	-1918(ra) # 80000d96 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000151c:	875a                	mv	a4,s6
    8000151e:	86a6                	mv	a3,s1
    80001520:	6605                	lui	a2,0x1
    80001522:	85ca                	mv	a1,s2
    80001524:	8556                	mv	a0,s5
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	c3a080e7          	jalr	-966(ra) # 80001160 <mappages>
    8000152e:	e90d                	bnez	a0,80001560 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001530:	6785                	lui	a5,0x1
    80001532:	993e                	add	s2,s2,a5
    80001534:	fd4968e3          	bltu	s2,s4,80001504 <uvmalloc+0x32>
  return newsz;
    80001538:	8552                	mv	a0,s4
    8000153a:	a809                	j	8000154c <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000153c:	864e                	mv	a2,s3
    8000153e:	85ca                	mv	a1,s2
    80001540:	8556                	mv	a0,s5
    80001542:	00000097          	auipc	ra,0x0
    80001546:	f48080e7          	jalr	-184(ra) # 8000148a <uvmdealloc>
      return 0;
    8000154a:	4501                	li	a0,0
}
    8000154c:	70e2                	ld	ra,56(sp)
    8000154e:	7442                	ld	s0,48(sp)
    80001550:	74a2                	ld	s1,40(sp)
    80001552:	7902                	ld	s2,32(sp)
    80001554:	69e2                	ld	s3,24(sp)
    80001556:	6a42                	ld	s4,16(sp)
    80001558:	6aa2                	ld	s5,8(sp)
    8000155a:	6b02                	ld	s6,0(sp)
    8000155c:	6121                	addi	sp,sp,64
    8000155e:	8082                	ret
      kfree(mem);
    80001560:	8526                	mv	a0,s1
    80001562:	fffff097          	auipc	ra,0xfffff
    80001566:	494080e7          	jalr	1172(ra) # 800009f6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000156a:	864e                	mv	a2,s3
    8000156c:	85ca                	mv	a1,s2
    8000156e:	8556                	mv	a0,s5
    80001570:	00000097          	auipc	ra,0x0
    80001574:	f1a080e7          	jalr	-230(ra) # 8000148a <uvmdealloc>
      return 0;
    80001578:	4501                	li	a0,0
    8000157a:	bfc9                	j	8000154c <uvmalloc+0x7a>
    return oldsz;
    8000157c:	852e                	mv	a0,a1
}
    8000157e:	8082                	ret
  return newsz;
    80001580:	8532                	mv	a0,a2
    80001582:	b7e9                	j	8000154c <uvmalloc+0x7a>

0000000080001584 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001584:	7179                	addi	sp,sp,-48
    80001586:	f406                	sd	ra,40(sp)
    80001588:	f022                	sd	s0,32(sp)
    8000158a:	ec26                	sd	s1,24(sp)
    8000158c:	e84a                	sd	s2,16(sp)
    8000158e:	e44e                	sd	s3,8(sp)
    80001590:	e052                	sd	s4,0(sp)
    80001592:	1800                	addi	s0,sp,48
    80001594:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001596:	84aa                	mv	s1,a0
    80001598:	6905                	lui	s2,0x1
    8000159a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000159c:	4985                	li	s3,1
    8000159e:	a829                	j	800015b8 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015a0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015a2:	00c79513          	slli	a0,a5,0xc
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	fde080e7          	jalr	-34(ra) # 80001584 <freewalk>
      pagetable[i] = 0;
    800015ae:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015b2:	04a1                	addi	s1,s1,8
    800015b4:	03248163          	beq	s1,s2,800015d6 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800015b8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015ba:	00f7f713          	andi	a4,a5,15
    800015be:	ff3701e3          	beq	a4,s3,800015a0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015c2:	8b85                	andi	a5,a5,1
    800015c4:	d7fd                	beqz	a5,800015b2 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015c6:	00007517          	auipc	a0,0x7
    800015ca:	bf250513          	addi	a0,a0,-1038 # 800081b8 <digits+0x168>
    800015ce:	fffff097          	auipc	ra,0xfffff
    800015d2:	f6e080e7          	jalr	-146(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    800015d6:	8552                	mv	a0,s4
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	41e080e7          	jalr	1054(ra) # 800009f6 <kfree>
}
    800015e0:	70a2                	ld	ra,40(sp)
    800015e2:	7402                	ld	s0,32(sp)
    800015e4:	64e2                	ld	s1,24(sp)
    800015e6:	6942                	ld	s2,16(sp)
    800015e8:	69a2                	ld	s3,8(sp)
    800015ea:	6a02                	ld	s4,0(sp)
    800015ec:	6145                	addi	sp,sp,48
    800015ee:	8082                	ret

00000000800015f0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015f0:	1101                	addi	sp,sp,-32
    800015f2:	ec06                	sd	ra,24(sp)
    800015f4:	e822                	sd	s0,16(sp)
    800015f6:	e426                	sd	s1,8(sp)
    800015f8:	1000                	addi	s0,sp,32
    800015fa:	84aa                	mv	s1,a0
  if(sz > 0)
    800015fc:	e999                	bnez	a1,80001612 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015fe:	8526                	mv	a0,s1
    80001600:	00000097          	auipc	ra,0x0
    80001604:	f84080e7          	jalr	-124(ra) # 80001584 <freewalk>
}
    80001608:	60e2                	ld	ra,24(sp)
    8000160a:	6442                	ld	s0,16(sp)
    8000160c:	64a2                	ld	s1,8(sp)
    8000160e:	6105                	addi	sp,sp,32
    80001610:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001612:	6785                	lui	a5,0x1
    80001614:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001616:	95be                	add	a1,a1,a5
    80001618:	4685                	li	a3,1
    8000161a:	00c5d613          	srli	a2,a1,0xc
    8000161e:	4581                	li	a1,0
    80001620:	00000097          	auipc	ra,0x0
    80001624:	d06080e7          	jalr	-762(ra) # 80001326 <uvmunmap>
    80001628:	bfd9                	j	800015fe <uvmfree+0xe>

000000008000162a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000162a:	c679                	beqz	a2,800016f8 <uvmcopy+0xce>
{
    8000162c:	715d                	addi	sp,sp,-80
    8000162e:	e486                	sd	ra,72(sp)
    80001630:	e0a2                	sd	s0,64(sp)
    80001632:	fc26                	sd	s1,56(sp)
    80001634:	f84a                	sd	s2,48(sp)
    80001636:	f44e                	sd	s3,40(sp)
    80001638:	f052                	sd	s4,32(sp)
    8000163a:	ec56                	sd	s5,24(sp)
    8000163c:	e85a                	sd	s6,16(sp)
    8000163e:	e45e                	sd	s7,8(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8aae                	mv	s5,a1
    80001646:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001648:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000164a:	4601                	li	a2,0
    8000164c:	85ce                	mv	a1,s3
    8000164e:	855a                	mv	a0,s6
    80001650:	00000097          	auipc	ra,0x0
    80001654:	a28080e7          	jalr	-1496(ra) # 80001078 <walk>
    80001658:	c531                	beqz	a0,800016a4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000165a:	6118                	ld	a4,0(a0)
    8000165c:	00177793          	andi	a5,a4,1
    80001660:	cbb1                	beqz	a5,800016b4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001662:	00a75593          	srli	a1,a4,0xa
    80001666:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000166a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	4f0080e7          	jalr	1264(ra) # 80000b5e <kalloc>
    80001676:	892a                	mv	s2,a0
    80001678:	c939                	beqz	a0,800016ce <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000167a:	6605                	lui	a2,0x1
    8000167c:	85de                	mv	a1,s7
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	774080e7          	jalr	1908(ra) # 80000df2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001686:	8726                	mv	a4,s1
    80001688:	86ca                	mv	a3,s2
    8000168a:	6605                	lui	a2,0x1
    8000168c:	85ce                	mv	a1,s3
    8000168e:	8556                	mv	a0,s5
    80001690:	00000097          	auipc	ra,0x0
    80001694:	ad0080e7          	jalr	-1328(ra) # 80001160 <mappages>
    80001698:	e515                	bnez	a0,800016c4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000169a:	6785                	lui	a5,0x1
    8000169c:	99be                	add	s3,s3,a5
    8000169e:	fb49e6e3          	bltu	s3,s4,8000164a <uvmcopy+0x20>
    800016a2:	a081                	j	800016e2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016a4:	00007517          	auipc	a0,0x7
    800016a8:	b2450513          	addi	a0,a0,-1244 # 800081c8 <digits+0x178>
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	e90080e7          	jalr	-368(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800016b4:	00007517          	auipc	a0,0x7
    800016b8:	b3450513          	addi	a0,a0,-1228 # 800081e8 <digits+0x198>
    800016bc:	fffff097          	auipc	ra,0xfffff
    800016c0:	e80080e7          	jalr	-384(ra) # 8000053c <panic>
      kfree(mem);
    800016c4:	854a                	mv	a0,s2
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	330080e7          	jalr	816(ra) # 800009f6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ce:	4685                	li	a3,1
    800016d0:	00c9d613          	srli	a2,s3,0xc
    800016d4:	4581                	li	a1,0
    800016d6:	8556                	mv	a0,s5
    800016d8:	00000097          	auipc	ra,0x0
    800016dc:	c4e080e7          	jalr	-946(ra) # 80001326 <uvmunmap>
  return -1;
    800016e0:	557d                	li	a0,-1
}
    800016e2:	60a6                	ld	ra,72(sp)
    800016e4:	6406                	ld	s0,64(sp)
    800016e6:	74e2                	ld	s1,56(sp)
    800016e8:	7942                	ld	s2,48(sp)
    800016ea:	79a2                	ld	s3,40(sp)
    800016ec:	7a02                	ld	s4,32(sp)
    800016ee:	6ae2                	ld	s5,24(sp)
    800016f0:	6b42                	ld	s6,16(sp)
    800016f2:	6ba2                	ld	s7,8(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret
  return 0;
    800016f8:	4501                	li	a0,0
}
    800016fa:	8082                	ret

00000000800016fc <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016fc:	1141                	addi	sp,sp,-16
    800016fe:	e406                	sd	ra,8(sp)
    80001700:	e022                	sd	s0,0(sp)
    80001702:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001704:	4601                	li	a2,0
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	972080e7          	jalr	-1678(ra) # 80001078 <walk>
  if(pte == 0)
    8000170e:	c901                	beqz	a0,8000171e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001710:	611c                	ld	a5,0(a0)
    80001712:	9bbd                	andi	a5,a5,-17
    80001714:	e11c                	sd	a5,0(a0)
}
    80001716:	60a2                	ld	ra,8(sp)
    80001718:	6402                	ld	s0,0(sp)
    8000171a:	0141                	addi	sp,sp,16
    8000171c:	8082                	ret
    panic("uvmclear");
    8000171e:	00007517          	auipc	a0,0x7
    80001722:	aea50513          	addi	a0,a0,-1302 # 80008208 <digits+0x1b8>
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	e16080e7          	jalr	-490(ra) # 8000053c <panic>

000000008000172e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000172e:	c6bd                	beqz	a3,8000179c <copyout+0x6e>
{
    80001730:	715d                	addi	sp,sp,-80
    80001732:	e486                	sd	ra,72(sp)
    80001734:	e0a2                	sd	s0,64(sp)
    80001736:	fc26                	sd	s1,56(sp)
    80001738:	f84a                	sd	s2,48(sp)
    8000173a:	f44e                	sd	s3,40(sp)
    8000173c:	f052                	sd	s4,32(sp)
    8000173e:	ec56                	sd	s5,24(sp)
    80001740:	e85a                	sd	s6,16(sp)
    80001742:	e45e                	sd	s7,8(sp)
    80001744:	e062                	sd	s8,0(sp)
    80001746:	0880                	addi	s0,sp,80
    80001748:	8b2a                	mv	s6,a0
    8000174a:	8c2e                	mv	s8,a1
    8000174c:	8a32                	mv	s4,a2
    8000174e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001750:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001752:	6a85                	lui	s5,0x1
    80001754:	a015                	j	80001778 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001756:	9562                	add	a0,a0,s8
    80001758:	0004861b          	sext.w	a2,s1
    8000175c:	85d2                	mv	a1,s4
    8000175e:	41250533          	sub	a0,a0,s2
    80001762:	fffff097          	auipc	ra,0xfffff
    80001766:	690080e7          	jalr	1680(ra) # 80000df2 <memmove>

    len -= n;
    8000176a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000176e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001770:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001774:	02098263          	beqz	s3,80001798 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001778:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000177c:	85ca                	mv	a1,s2
    8000177e:	855a                	mv	a0,s6
    80001780:	00000097          	auipc	ra,0x0
    80001784:	99e080e7          	jalr	-1634(ra) # 8000111e <walkaddr>
    if(pa0 == 0)
    80001788:	cd01                	beqz	a0,800017a0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000178a:	418904b3          	sub	s1,s2,s8
    8000178e:	94d6                	add	s1,s1,s5
    80001790:	fc99f3e3          	bgeu	s3,s1,80001756 <copyout+0x28>
    80001794:	84ce                	mv	s1,s3
    80001796:	b7c1                	j	80001756 <copyout+0x28>
  }
  return 0;
    80001798:	4501                	li	a0,0
    8000179a:	a021                	j	800017a2 <copyout+0x74>
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret
      return -1;
    800017a0:	557d                	li	a0,-1
}
    800017a2:	60a6                	ld	ra,72(sp)
    800017a4:	6406                	ld	s0,64(sp)
    800017a6:	74e2                	ld	s1,56(sp)
    800017a8:	7942                	ld	s2,48(sp)
    800017aa:	79a2                	ld	s3,40(sp)
    800017ac:	7a02                	ld	s4,32(sp)
    800017ae:	6ae2                	ld	s5,24(sp)
    800017b0:	6b42                	ld	s6,16(sp)
    800017b2:	6ba2                	ld	s7,8(sp)
    800017b4:	6c02                	ld	s8,0(sp)
    800017b6:	6161                	addi	sp,sp,80
    800017b8:	8082                	ret

00000000800017ba <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017ba:	caa5                	beqz	a3,8000182a <copyin+0x70>
{
    800017bc:	715d                	addi	sp,sp,-80
    800017be:	e486                	sd	ra,72(sp)
    800017c0:	e0a2                	sd	s0,64(sp)
    800017c2:	fc26                	sd	s1,56(sp)
    800017c4:	f84a                	sd	s2,48(sp)
    800017c6:	f44e                	sd	s3,40(sp)
    800017c8:	f052                	sd	s4,32(sp)
    800017ca:	ec56                	sd	s5,24(sp)
    800017cc:	e85a                	sd	s6,16(sp)
    800017ce:	e45e                	sd	s7,8(sp)
    800017d0:	e062                	sd	s8,0(sp)
    800017d2:	0880                	addi	s0,sp,80
    800017d4:	8b2a                	mv	s6,a0
    800017d6:	8a2e                	mv	s4,a1
    800017d8:	8c32                	mv	s8,a2
    800017da:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017dc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017de:	6a85                	lui	s5,0x1
    800017e0:	a01d                	j	80001806 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017e2:	018505b3          	add	a1,a0,s8
    800017e6:	0004861b          	sext.w	a2,s1
    800017ea:	412585b3          	sub	a1,a1,s2
    800017ee:	8552                	mv	a0,s4
    800017f0:	fffff097          	auipc	ra,0xfffff
    800017f4:	602080e7          	jalr	1538(ra) # 80000df2 <memmove>

    len -= n;
    800017f8:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017fc:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017fe:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001802:	02098263          	beqz	s3,80001826 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001806:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000180a:	85ca                	mv	a1,s2
    8000180c:	855a                	mv	a0,s6
    8000180e:	00000097          	auipc	ra,0x0
    80001812:	910080e7          	jalr	-1776(ra) # 8000111e <walkaddr>
    if(pa0 == 0)
    80001816:	cd01                	beqz	a0,8000182e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001818:	418904b3          	sub	s1,s2,s8
    8000181c:	94d6                	add	s1,s1,s5
    8000181e:	fc99f2e3          	bgeu	s3,s1,800017e2 <copyin+0x28>
    80001822:	84ce                	mv	s1,s3
    80001824:	bf7d                	j	800017e2 <copyin+0x28>
  }
  return 0;
    80001826:	4501                	li	a0,0
    80001828:	a021                	j	80001830 <copyin+0x76>
    8000182a:	4501                	li	a0,0
}
    8000182c:	8082                	ret
      return -1;
    8000182e:	557d                	li	a0,-1
}
    80001830:	60a6                	ld	ra,72(sp)
    80001832:	6406                	ld	s0,64(sp)
    80001834:	74e2                	ld	s1,56(sp)
    80001836:	7942                	ld	s2,48(sp)
    80001838:	79a2                	ld	s3,40(sp)
    8000183a:	7a02                	ld	s4,32(sp)
    8000183c:	6ae2                	ld	s5,24(sp)
    8000183e:	6b42                	ld	s6,16(sp)
    80001840:	6ba2                	ld	s7,8(sp)
    80001842:	6c02                	ld	s8,0(sp)
    80001844:	6161                	addi	sp,sp,80
    80001846:	8082                	ret

0000000080001848 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001848:	c2dd                	beqz	a3,800018ee <copyinstr+0xa6>
{
    8000184a:	715d                	addi	sp,sp,-80
    8000184c:	e486                	sd	ra,72(sp)
    8000184e:	e0a2                	sd	s0,64(sp)
    80001850:	fc26                	sd	s1,56(sp)
    80001852:	f84a                	sd	s2,48(sp)
    80001854:	f44e                	sd	s3,40(sp)
    80001856:	f052                	sd	s4,32(sp)
    80001858:	ec56                	sd	s5,24(sp)
    8000185a:	e85a                	sd	s6,16(sp)
    8000185c:	e45e                	sd	s7,8(sp)
    8000185e:	0880                	addi	s0,sp,80
    80001860:	8a2a                	mv	s4,a0
    80001862:	8b2e                	mv	s6,a1
    80001864:	8bb2                	mv	s7,a2
    80001866:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001868:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000186a:	6985                	lui	s3,0x1
    8000186c:	a02d                	j	80001896 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000186e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001872:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001874:	37fd                	addiw	a5,a5,-1
    80001876:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000187a:	60a6                	ld	ra,72(sp)
    8000187c:	6406                	ld	s0,64(sp)
    8000187e:	74e2                	ld	s1,56(sp)
    80001880:	7942                	ld	s2,48(sp)
    80001882:	79a2                	ld	s3,40(sp)
    80001884:	7a02                	ld	s4,32(sp)
    80001886:	6ae2                	ld	s5,24(sp)
    80001888:	6b42                	ld	s6,16(sp)
    8000188a:	6ba2                	ld	s7,8(sp)
    8000188c:	6161                	addi	sp,sp,80
    8000188e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001890:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001894:	c8a9                	beqz	s1,800018e6 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001896:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000189a:	85ca                	mv	a1,s2
    8000189c:	8552                	mv	a0,s4
    8000189e:	00000097          	auipc	ra,0x0
    800018a2:	880080e7          	jalr	-1920(ra) # 8000111e <walkaddr>
    if(pa0 == 0)
    800018a6:	c131                	beqz	a0,800018ea <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800018a8:	417906b3          	sub	a3,s2,s7
    800018ac:	96ce                	add	a3,a3,s3
    800018ae:	00d4f363          	bgeu	s1,a3,800018b4 <copyinstr+0x6c>
    800018b2:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018b4:	955e                	add	a0,a0,s7
    800018b6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018ba:	daf9                	beqz	a3,80001890 <copyinstr+0x48>
    800018bc:	87da                	mv	a5,s6
    800018be:	885a                	mv	a6,s6
      if(*p == '\0'){
    800018c0:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800018c4:	96da                	add	a3,a3,s6
    800018c6:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018c8:	00f60733          	add	a4,a2,a5
    800018cc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd110>
    800018d0:	df59                	beqz	a4,8000186e <copyinstr+0x26>
        *dst = *p;
    800018d2:	00e78023          	sb	a4,0(a5)
      dst++;
    800018d6:	0785                	addi	a5,a5,1
    while(n > 0){
    800018d8:	fed797e3          	bne	a5,a3,800018c6 <copyinstr+0x7e>
    800018dc:	14fd                	addi	s1,s1,-1
    800018de:	94c2                	add	s1,s1,a6
      --max;
    800018e0:	8c8d                	sub	s1,s1,a1
      dst++;
    800018e2:	8b3e                	mv	s6,a5
    800018e4:	b775                	j	80001890 <copyinstr+0x48>
    800018e6:	4781                	li	a5,0
    800018e8:	b771                	j	80001874 <copyinstr+0x2c>
      return -1;
    800018ea:	557d                	li	a0,-1
    800018ec:	b779                	j	8000187a <copyinstr+0x32>
  int got_null = 0;
    800018ee:	4781                	li	a5,0
  if(got_null){
    800018f0:	37fd                	addiw	a5,a5,-1
    800018f2:	0007851b          	sext.w	a0,a5
}
    800018f6:	8082                	ret

00000000800018f8 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    800018f8:	715d                	addi	sp,sp,-80
    800018fa:	e486                	sd	ra,72(sp)
    800018fc:	e0a2                	sd	s0,64(sp)
    800018fe:	fc26                	sd	s1,56(sp)
    80001900:	f84a                	sd	s2,48(sp)
    80001902:	f44e                	sd	s3,40(sp)
    80001904:	f052                	sd	s4,32(sp)
    80001906:	ec56                	sd	s5,24(sp)
    80001908:	e85a                	sd	s6,16(sp)
    8000190a:	e45e                	sd	s7,8(sp)
    8000190c:	e062                	sd	s8,0(sp)
    8000190e:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    80001910:	8792                	mv	a5,tp
    int id = r_tp();
    80001912:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001914:	0000fa97          	auipc	s5,0xf
    80001918:	3cca8a93          	addi	s5,s5,972 # 80010ce0 <cpus>
    8000191c:	00779713          	slli	a4,a5,0x7
    80001920:	00ea86b3          	add	a3,s5,a4
    80001924:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd110>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001928:	0721                	addi	a4,a4,8
    8000192a:	9aba                	add	s5,s5,a4
                c->proc = p;
    8000192c:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    8000192e:	00007c17          	auipc	s8,0x7
    80001932:	08ac0c13          	addi	s8,s8,138 # 800089b8 <sched_pointer>
    80001936:	00000b97          	auipc	s7,0x0
    8000193a:	fc2b8b93          	addi	s7,s7,-62 # 800018f8 <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000193e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001942:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001946:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    8000194a:	0000f497          	auipc	s1,0xf
    8000194e:	7c648493          	addi	s1,s1,1990 # 80011110 <proc>
            if (p->state == RUNNABLE)
    80001952:	498d                	li	s3,3
                p->state = RUNNING;
    80001954:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001956:	00015a17          	auipc	s4,0x15
    8000195a:	1baa0a13          	addi	s4,s4,442 # 80016b10 <tickslock>
    8000195e:	a81d                	j	80001994 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001960:	8526                	mv	a0,s1
    80001962:	fffff097          	auipc	ra,0xfffff
    80001966:	3ec080e7          	jalr	1004(ra) # 80000d4e <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    8000196a:	60a6                	ld	ra,72(sp)
    8000196c:	6406                	ld	s0,64(sp)
    8000196e:	74e2                	ld	s1,56(sp)
    80001970:	7942                	ld	s2,48(sp)
    80001972:	79a2                	ld	s3,40(sp)
    80001974:	7a02                	ld	s4,32(sp)
    80001976:	6ae2                	ld	s5,24(sp)
    80001978:	6b42                	ld	s6,16(sp)
    8000197a:	6ba2                	ld	s7,8(sp)
    8000197c:	6c02                	ld	s8,0(sp)
    8000197e:	6161                	addi	sp,sp,80
    80001980:	8082                	ret
            release(&p->lock);
    80001982:	8526                	mv	a0,s1
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	3ca080e7          	jalr	970(ra) # 80000d4e <release>
        for (p = proc; p < &proc[NPROC]; p++)
    8000198c:	16848493          	addi	s1,s1,360
    80001990:	fb4487e3          	beq	s1,s4,8000193e <rr_scheduler+0x46>
            acquire(&p->lock);
    80001994:	8526                	mv	a0,s1
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	304080e7          	jalr	772(ra) # 80000c9a <acquire>
            if (p->state == RUNNABLE)
    8000199e:	4c9c                	lw	a5,24(s1)
    800019a0:	ff3791e3          	bne	a5,s3,80001982 <rr_scheduler+0x8a>
                p->state = RUNNING;
    800019a4:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    800019a8:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    800019ac:	06048593          	addi	a1,s1,96
    800019b0:	8556                	mv	a0,s5
    800019b2:	00001097          	auipc	ra,0x1
    800019b6:	008080e7          	jalr	8(ra) # 800029ba <swtch>
                if (sched_pointer != &rr_scheduler)
    800019ba:	000c3783          	ld	a5,0(s8)
    800019be:	fb7791e3          	bne	a5,s7,80001960 <rr_scheduler+0x68>
                c->proc = 0;
    800019c2:	00093023          	sd	zero,0(s2)
    800019c6:	bf75                	j	80001982 <rr_scheduler+0x8a>

00000000800019c8 <proc_mapstacks>:
{
    800019c8:	7139                	addi	sp,sp,-64
    800019ca:	fc06                	sd	ra,56(sp)
    800019cc:	f822                	sd	s0,48(sp)
    800019ce:	f426                	sd	s1,40(sp)
    800019d0:	f04a                	sd	s2,32(sp)
    800019d2:	ec4e                	sd	s3,24(sp)
    800019d4:	e852                	sd	s4,16(sp)
    800019d6:	e456                	sd	s5,8(sp)
    800019d8:	e05a                	sd	s6,0(sp)
    800019da:	0080                	addi	s0,sp,64
    800019dc:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    800019de:	0000f497          	auipc	s1,0xf
    800019e2:	73248493          	addi	s1,s1,1842 # 80011110 <proc>
        uint64 va = KSTACK((int)(p - proc));
    800019e6:	8b26                	mv	s6,s1
    800019e8:	00006a97          	auipc	s5,0x6
    800019ec:	628a8a93          	addi	s5,s5,1576 # 80008010 <__func__.1+0x8>
    800019f0:	04000937          	lui	s2,0x4000
    800019f4:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019f6:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    800019f8:	00015a17          	auipc	s4,0x15
    800019fc:	118a0a13          	addi	s4,s4,280 # 80016b10 <tickslock>
        char *pa = kalloc();
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	15e080e7          	jalr	350(ra) # 80000b5e <kalloc>
    80001a08:	862a                	mv	a2,a0
        if (pa == 0)
    80001a0a:	c131                	beqz	a0,80001a4e <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001a0c:	416485b3          	sub	a1,s1,s6
    80001a10:	858d                	srai	a1,a1,0x3
    80001a12:	000ab783          	ld	a5,0(s5)
    80001a16:	02f585b3          	mul	a1,a1,a5
    80001a1a:	2585                	addiw	a1,a1,1
    80001a1c:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a20:	4719                	li	a4,6
    80001a22:	6685                	lui	a3,0x1
    80001a24:	40b905b3          	sub	a1,s2,a1
    80001a28:	854e                	mv	a0,s3
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	7d6080e7          	jalr	2006(ra) # 80001200 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001a32:	16848493          	addi	s1,s1,360
    80001a36:	fd4495e3          	bne	s1,s4,80001a00 <proc_mapstacks+0x38>
}
    80001a3a:	70e2                	ld	ra,56(sp)
    80001a3c:	7442                	ld	s0,48(sp)
    80001a3e:	74a2                	ld	s1,40(sp)
    80001a40:	7902                	ld	s2,32(sp)
    80001a42:	69e2                	ld	s3,24(sp)
    80001a44:	6a42                	ld	s4,16(sp)
    80001a46:	6aa2                	ld	s5,8(sp)
    80001a48:	6b02                	ld	s6,0(sp)
    80001a4a:	6121                	addi	sp,sp,64
    80001a4c:	8082                	ret
            panic("kalloc");
    80001a4e:	00006517          	auipc	a0,0x6
    80001a52:	7ca50513          	addi	a0,a0,1994 # 80008218 <digits+0x1c8>
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	ae6080e7          	jalr	-1306(ra) # 8000053c <panic>

0000000080001a5e <procinit>:
{
    80001a5e:	7139                	addi	sp,sp,-64
    80001a60:	fc06                	sd	ra,56(sp)
    80001a62:	f822                	sd	s0,48(sp)
    80001a64:	f426                	sd	s1,40(sp)
    80001a66:	f04a                	sd	s2,32(sp)
    80001a68:	ec4e                	sd	s3,24(sp)
    80001a6a:	e852                	sd	s4,16(sp)
    80001a6c:	e456                	sd	s5,8(sp)
    80001a6e:	e05a                	sd	s6,0(sp)
    80001a70:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001a72:	00006597          	auipc	a1,0x6
    80001a76:	7ae58593          	addi	a1,a1,1966 # 80008220 <digits+0x1d0>
    80001a7a:	0000f517          	auipc	a0,0xf
    80001a7e:	66650513          	addi	a0,a0,1638 # 800110e0 <pid_lock>
    80001a82:	fffff097          	auipc	ra,0xfffff
    80001a86:	188080e7          	jalr	392(ra) # 80000c0a <initlock>
    initlock(&wait_lock, "wait_lock");
    80001a8a:	00006597          	auipc	a1,0x6
    80001a8e:	79e58593          	addi	a1,a1,1950 # 80008228 <digits+0x1d8>
    80001a92:	0000f517          	auipc	a0,0xf
    80001a96:	66650513          	addi	a0,a0,1638 # 800110f8 <wait_lock>
    80001a9a:	fffff097          	auipc	ra,0xfffff
    80001a9e:	170080e7          	jalr	368(ra) # 80000c0a <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001aa2:	0000f497          	auipc	s1,0xf
    80001aa6:	66e48493          	addi	s1,s1,1646 # 80011110 <proc>
        initlock(&p->lock, "proc");
    80001aaa:	00006b17          	auipc	s6,0x6
    80001aae:	78eb0b13          	addi	s6,s6,1934 # 80008238 <digits+0x1e8>
        p->kstack = KSTACK((int)(p - proc));
    80001ab2:	8aa6                	mv	s5,s1
    80001ab4:	00006a17          	auipc	s4,0x6
    80001ab8:	55ca0a13          	addi	s4,s4,1372 # 80008010 <__func__.1+0x8>
    80001abc:	04000937          	lui	s2,0x4000
    80001ac0:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ac2:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001ac4:	00015997          	auipc	s3,0x15
    80001ac8:	04c98993          	addi	s3,s3,76 # 80016b10 <tickslock>
        initlock(&p->lock, "proc");
    80001acc:	85da                	mv	a1,s6
    80001ace:	8526                	mv	a0,s1
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	13a080e7          	jalr	314(ra) # 80000c0a <initlock>
        p->state = UNUSED;
    80001ad8:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001adc:	415487b3          	sub	a5,s1,s5
    80001ae0:	878d                	srai	a5,a5,0x3
    80001ae2:	000a3703          	ld	a4,0(s4)
    80001ae6:	02e787b3          	mul	a5,a5,a4
    80001aea:	2785                	addiw	a5,a5,1
    80001aec:	00d7979b          	slliw	a5,a5,0xd
    80001af0:	40f907b3          	sub	a5,s2,a5
    80001af4:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001af6:	16848493          	addi	s1,s1,360
    80001afa:	fd3499e3          	bne	s1,s3,80001acc <procinit+0x6e>
}
    80001afe:	70e2                	ld	ra,56(sp)
    80001b00:	7442                	ld	s0,48(sp)
    80001b02:	74a2                	ld	s1,40(sp)
    80001b04:	7902                	ld	s2,32(sp)
    80001b06:	69e2                	ld	s3,24(sp)
    80001b08:	6a42                	ld	s4,16(sp)
    80001b0a:	6aa2                	ld	s5,8(sp)
    80001b0c:	6b02                	ld	s6,0(sp)
    80001b0e:	6121                	addi	sp,sp,64
    80001b10:	8082                	ret

0000000080001b12 <copy_array>:
{
    80001b12:	1141                	addi	sp,sp,-16
    80001b14:	e422                	sd	s0,8(sp)
    80001b16:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001b18:	00c05c63          	blez	a2,80001b30 <copy_array+0x1e>
    80001b1c:	87aa                	mv	a5,a0
    80001b1e:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001b20:	0007c703          	lbu	a4,0(a5)
    80001b24:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001b28:	0785                	addi	a5,a5,1
    80001b2a:	0585                	addi	a1,a1,1
    80001b2c:	fea79ae3          	bne	a5,a0,80001b20 <copy_array+0xe>
}
    80001b30:	6422                	ld	s0,8(sp)
    80001b32:	0141                	addi	sp,sp,16
    80001b34:	8082                	ret

0000000080001b36 <cpuid>:
{
    80001b36:	1141                	addi	sp,sp,-16
    80001b38:	e422                	sd	s0,8(sp)
    80001b3a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b3c:	8512                	mv	a0,tp
}
    80001b3e:	2501                	sext.w	a0,a0
    80001b40:	6422                	ld	s0,8(sp)
    80001b42:	0141                	addi	sp,sp,16
    80001b44:	8082                	ret

0000000080001b46 <mycpu>:
{
    80001b46:	1141                	addi	sp,sp,-16
    80001b48:	e422                	sd	s0,8(sp)
    80001b4a:	0800                	addi	s0,sp,16
    80001b4c:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001b4e:	2781                	sext.w	a5,a5
    80001b50:	079e                	slli	a5,a5,0x7
}
    80001b52:	0000f517          	auipc	a0,0xf
    80001b56:	18e50513          	addi	a0,a0,398 # 80010ce0 <cpus>
    80001b5a:	953e                	add	a0,a0,a5
    80001b5c:	6422                	ld	s0,8(sp)
    80001b5e:	0141                	addi	sp,sp,16
    80001b60:	8082                	ret

0000000080001b62 <myproc>:
{
    80001b62:	1101                	addi	sp,sp,-32
    80001b64:	ec06                	sd	ra,24(sp)
    80001b66:	e822                	sd	s0,16(sp)
    80001b68:	e426                	sd	s1,8(sp)
    80001b6a:	1000                	addi	s0,sp,32
    push_off();
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	0e2080e7          	jalr	226(ra) # 80000c4e <push_off>
    80001b74:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001b76:	2781                	sext.w	a5,a5
    80001b78:	079e                	slli	a5,a5,0x7
    80001b7a:	0000f717          	auipc	a4,0xf
    80001b7e:	16670713          	addi	a4,a4,358 # 80010ce0 <cpus>
    80001b82:	97ba                	add	a5,a5,a4
    80001b84:	6384                	ld	s1,0(a5)
    pop_off();
    80001b86:	fffff097          	auipc	ra,0xfffff
    80001b8a:	168080e7          	jalr	360(ra) # 80000cee <pop_off>
}
    80001b8e:	8526                	mv	a0,s1
    80001b90:	60e2                	ld	ra,24(sp)
    80001b92:	6442                	ld	s0,16(sp)
    80001b94:	64a2                	ld	s1,8(sp)
    80001b96:	6105                	addi	sp,sp,32
    80001b98:	8082                	ret

0000000080001b9a <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b9a:	1141                	addi	sp,sp,-16
    80001b9c:	e406                	sd	ra,8(sp)
    80001b9e:	e022                	sd	s0,0(sp)
    80001ba0:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001ba2:	00000097          	auipc	ra,0x0
    80001ba6:	fc0080e7          	jalr	-64(ra) # 80001b62 <myproc>
    80001baa:	fffff097          	auipc	ra,0xfffff
    80001bae:	1a4080e7          	jalr	420(ra) # 80000d4e <release>

    if (first)
    80001bb2:	00007797          	auipc	a5,0x7
    80001bb6:	dfe7a783          	lw	a5,-514(a5) # 800089b0 <first.1>
    80001bba:	eb89                	bnez	a5,80001bcc <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001bbc:	00001097          	auipc	ra,0x1
    80001bc0:	ea8080e7          	jalr	-344(ra) # 80002a64 <usertrapret>
}
    80001bc4:	60a2                	ld	ra,8(sp)
    80001bc6:	6402                	ld	s0,0(sp)
    80001bc8:	0141                	addi	sp,sp,16
    80001bca:	8082                	ret
        first = 0;
    80001bcc:	00007797          	auipc	a5,0x7
    80001bd0:	de07a223          	sw	zero,-540(a5) # 800089b0 <first.1>
        fsinit(ROOTDEV);
    80001bd4:	4505                	li	a0,1
    80001bd6:	00002097          	auipc	ra,0x2
    80001bda:	d54080e7          	jalr	-684(ra) # 8000392a <fsinit>
    80001bde:	bff9                	j	80001bbc <forkret+0x22>

0000000080001be0 <allocpid>:
{
    80001be0:	1101                	addi	sp,sp,-32
    80001be2:	ec06                	sd	ra,24(sp)
    80001be4:	e822                	sd	s0,16(sp)
    80001be6:	e426                	sd	s1,8(sp)
    80001be8:	e04a                	sd	s2,0(sp)
    80001bea:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001bec:	0000f917          	auipc	s2,0xf
    80001bf0:	4f490913          	addi	s2,s2,1268 # 800110e0 <pid_lock>
    80001bf4:	854a                	mv	a0,s2
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	0a4080e7          	jalr	164(ra) # 80000c9a <acquire>
    pid = nextpid;
    80001bfe:	00007797          	auipc	a5,0x7
    80001c02:	dc278793          	addi	a5,a5,-574 # 800089c0 <nextpid>
    80001c06:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001c08:	0014871b          	addiw	a4,s1,1
    80001c0c:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001c0e:	854a                	mv	a0,s2
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	13e080e7          	jalr	318(ra) # 80000d4e <release>
}
    80001c18:	8526                	mv	a0,s1
    80001c1a:	60e2                	ld	ra,24(sp)
    80001c1c:	6442                	ld	s0,16(sp)
    80001c1e:	64a2                	ld	s1,8(sp)
    80001c20:	6902                	ld	s2,0(sp)
    80001c22:	6105                	addi	sp,sp,32
    80001c24:	8082                	ret

0000000080001c26 <proc_pagetable>:
{
    80001c26:	1101                	addi	sp,sp,-32
    80001c28:	ec06                	sd	ra,24(sp)
    80001c2a:	e822                	sd	s0,16(sp)
    80001c2c:	e426                	sd	s1,8(sp)
    80001c2e:	e04a                	sd	s2,0(sp)
    80001c30:	1000                	addi	s0,sp,32
    80001c32:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	7b6080e7          	jalr	1974(ra) # 800013ea <uvmcreate>
    80001c3c:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001c3e:	c121                	beqz	a0,80001c7e <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c40:	4729                	li	a4,10
    80001c42:	00005697          	auipc	a3,0x5
    80001c46:	3be68693          	addi	a3,a3,958 # 80007000 <_trampoline>
    80001c4a:	6605                	lui	a2,0x1
    80001c4c:	040005b7          	lui	a1,0x4000
    80001c50:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c52:	05b2                	slli	a1,a1,0xc
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	50c080e7          	jalr	1292(ra) # 80001160 <mappages>
    80001c5c:	02054863          	bltz	a0,80001c8c <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c60:	4719                	li	a4,6
    80001c62:	05893683          	ld	a3,88(s2)
    80001c66:	6605                	lui	a2,0x1
    80001c68:	020005b7          	lui	a1,0x2000
    80001c6c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c6e:	05b6                	slli	a1,a1,0xd
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	4ee080e7          	jalr	1262(ra) # 80001160 <mappages>
    80001c7a:	02054163          	bltz	a0,80001c9c <proc_pagetable+0x76>
}
    80001c7e:	8526                	mv	a0,s1
    80001c80:	60e2                	ld	ra,24(sp)
    80001c82:	6442                	ld	s0,16(sp)
    80001c84:	64a2                	ld	s1,8(sp)
    80001c86:	6902                	ld	s2,0(sp)
    80001c88:	6105                	addi	sp,sp,32
    80001c8a:	8082                	ret
        uvmfree(pagetable, 0);
    80001c8c:	4581                	li	a1,0
    80001c8e:	8526                	mv	a0,s1
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	960080e7          	jalr	-1696(ra) # 800015f0 <uvmfree>
        return 0;
    80001c98:	4481                	li	s1,0
    80001c9a:	b7d5                	j	80001c7e <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c9c:	4681                	li	a3,0
    80001c9e:	4605                	li	a2,1
    80001ca0:	040005b7          	lui	a1,0x4000
    80001ca4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ca6:	05b2                	slli	a1,a1,0xc
    80001ca8:	8526                	mv	a0,s1
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	67c080e7          	jalr	1660(ra) # 80001326 <uvmunmap>
        uvmfree(pagetable, 0);
    80001cb2:	4581                	li	a1,0
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	00000097          	auipc	ra,0x0
    80001cba:	93a080e7          	jalr	-1734(ra) # 800015f0 <uvmfree>
        return 0;
    80001cbe:	4481                	li	s1,0
    80001cc0:	bf7d                	j	80001c7e <proc_pagetable+0x58>

0000000080001cc2 <proc_freepagetable>:
{
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	e04a                	sd	s2,0(sp)
    80001ccc:	1000                	addi	s0,sp,32
    80001cce:	84aa                	mv	s1,a0
    80001cd0:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cd2:	4681                	li	a3,0
    80001cd4:	4605                	li	a2,1
    80001cd6:	040005b7          	lui	a1,0x4000
    80001cda:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cdc:	05b2                	slli	a1,a1,0xc
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	648080e7          	jalr	1608(ra) # 80001326 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ce6:	4681                	li	a3,0
    80001ce8:	4605                	li	a2,1
    80001cea:	020005b7          	lui	a1,0x2000
    80001cee:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cf0:	05b6                	slli	a1,a1,0xd
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	632080e7          	jalr	1586(ra) # 80001326 <uvmunmap>
    uvmfree(pagetable, sz);
    80001cfc:	85ca                	mv	a1,s2
    80001cfe:	8526                	mv	a0,s1
    80001d00:	00000097          	auipc	ra,0x0
    80001d04:	8f0080e7          	jalr	-1808(ra) # 800015f0 <uvmfree>
}
    80001d08:	60e2                	ld	ra,24(sp)
    80001d0a:	6442                	ld	s0,16(sp)
    80001d0c:	64a2                	ld	s1,8(sp)
    80001d0e:	6902                	ld	s2,0(sp)
    80001d10:	6105                	addi	sp,sp,32
    80001d12:	8082                	ret

0000000080001d14 <freeproc>:
{
    80001d14:	1101                	addi	sp,sp,-32
    80001d16:	ec06                	sd	ra,24(sp)
    80001d18:	e822                	sd	s0,16(sp)
    80001d1a:	e426                	sd	s1,8(sp)
    80001d1c:	1000                	addi	s0,sp,32
    80001d1e:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001d20:	6d28                	ld	a0,88(a0)
    80001d22:	c509                	beqz	a0,80001d2c <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	cd2080e7          	jalr	-814(ra) # 800009f6 <kfree>
    p->trapframe = 0;
    80001d2c:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001d30:	68a8                	ld	a0,80(s1)
    80001d32:	c511                	beqz	a0,80001d3e <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001d34:	64ac                	ld	a1,72(s1)
    80001d36:	00000097          	auipc	ra,0x0
    80001d3a:	f8c080e7          	jalr	-116(ra) # 80001cc2 <proc_freepagetable>
    p->pagetable = 0;
    80001d3e:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001d42:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001d46:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001d4a:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001d4e:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001d52:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001d56:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001d5a:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001d5e:	0004ac23          	sw	zero,24(s1)
}
    80001d62:	60e2                	ld	ra,24(sp)
    80001d64:	6442                	ld	s0,16(sp)
    80001d66:	64a2                	ld	s1,8(sp)
    80001d68:	6105                	addi	sp,sp,32
    80001d6a:	8082                	ret

0000000080001d6c <allocproc>:
{
    80001d6c:	1101                	addi	sp,sp,-32
    80001d6e:	ec06                	sd	ra,24(sp)
    80001d70:	e822                	sd	s0,16(sp)
    80001d72:	e426                	sd	s1,8(sp)
    80001d74:	e04a                	sd	s2,0(sp)
    80001d76:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001d78:	0000f497          	auipc	s1,0xf
    80001d7c:	39848493          	addi	s1,s1,920 # 80011110 <proc>
    80001d80:	00015917          	auipc	s2,0x15
    80001d84:	d9090913          	addi	s2,s2,-624 # 80016b10 <tickslock>
        acquire(&p->lock);
    80001d88:	8526                	mv	a0,s1
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	f10080e7          	jalr	-240(ra) # 80000c9a <acquire>
        if (p->state == UNUSED)
    80001d92:	4c9c                	lw	a5,24(s1)
    80001d94:	cf81                	beqz	a5,80001dac <allocproc+0x40>
            release(&p->lock);
    80001d96:	8526                	mv	a0,s1
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	fb6080e7          	jalr	-74(ra) # 80000d4e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001da0:	16848493          	addi	s1,s1,360
    80001da4:	ff2492e3          	bne	s1,s2,80001d88 <allocproc+0x1c>
    return 0;
    80001da8:	4481                	li	s1,0
    80001daa:	a889                	j	80001dfc <allocproc+0x90>
    p->pid = allocpid();
    80001dac:	00000097          	auipc	ra,0x0
    80001db0:	e34080e7          	jalr	-460(ra) # 80001be0 <allocpid>
    80001db4:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001db6:	4785                	li	a5,1
    80001db8:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	da4080e7          	jalr	-604(ra) # 80000b5e <kalloc>
    80001dc2:	892a                	mv	s2,a0
    80001dc4:	eca8                	sd	a0,88(s1)
    80001dc6:	c131                	beqz	a0,80001e0a <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001dc8:	8526                	mv	a0,s1
    80001dca:	00000097          	auipc	ra,0x0
    80001dce:	e5c080e7          	jalr	-420(ra) # 80001c26 <proc_pagetable>
    80001dd2:	892a                	mv	s2,a0
    80001dd4:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001dd6:	c531                	beqz	a0,80001e22 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001dd8:	07000613          	li	a2,112
    80001ddc:	4581                	li	a1,0
    80001dde:	06048513          	addi	a0,s1,96
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	fb4080e7          	jalr	-76(ra) # 80000d96 <memset>
    p->context.ra = (uint64)forkret;
    80001dea:	00000797          	auipc	a5,0x0
    80001dee:	db078793          	addi	a5,a5,-592 # 80001b9a <forkret>
    80001df2:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001df4:	60bc                	ld	a5,64(s1)
    80001df6:	6705                	lui	a4,0x1
    80001df8:	97ba                	add	a5,a5,a4
    80001dfa:	f4bc                	sd	a5,104(s1)
}
    80001dfc:	8526                	mv	a0,s1
    80001dfe:	60e2                	ld	ra,24(sp)
    80001e00:	6442                	ld	s0,16(sp)
    80001e02:	64a2                	ld	s1,8(sp)
    80001e04:	6902                	ld	s2,0(sp)
    80001e06:	6105                	addi	sp,sp,32
    80001e08:	8082                	ret
        freeproc(p);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	f08080e7          	jalr	-248(ra) # 80001d14 <freeproc>
        release(&p->lock);
    80001e14:	8526                	mv	a0,s1
    80001e16:	fffff097          	auipc	ra,0xfffff
    80001e1a:	f38080e7          	jalr	-200(ra) # 80000d4e <release>
        return 0;
    80001e1e:	84ca                	mv	s1,s2
    80001e20:	bff1                	j	80001dfc <allocproc+0x90>
        freeproc(p);
    80001e22:	8526                	mv	a0,s1
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	ef0080e7          	jalr	-272(ra) # 80001d14 <freeproc>
        release(&p->lock);
    80001e2c:	8526                	mv	a0,s1
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	f20080e7          	jalr	-224(ra) # 80000d4e <release>
        return 0;
    80001e36:	84ca                	mv	s1,s2
    80001e38:	b7d1                	j	80001dfc <allocproc+0x90>

0000000080001e3a <userinit>:
{
    80001e3a:	1101                	addi	sp,sp,-32
    80001e3c:	ec06                	sd	ra,24(sp)
    80001e3e:	e822                	sd	s0,16(sp)
    80001e40:	e426                	sd	s1,8(sp)
    80001e42:	1000                	addi	s0,sp,32
    p = allocproc();
    80001e44:	00000097          	auipc	ra,0x0
    80001e48:	f28080e7          	jalr	-216(ra) # 80001d6c <allocproc>
    80001e4c:	84aa                	mv	s1,a0
    initproc = p;
    80001e4e:	00007797          	auipc	a5,0x7
    80001e52:	c0a7bd23          	sd	a0,-998(a5) # 80008a68 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e56:	03400613          	li	a2,52
    80001e5a:	00007597          	auipc	a1,0x7
    80001e5e:	b7658593          	addi	a1,a1,-1162 # 800089d0 <initcode>
    80001e62:	6928                	ld	a0,80(a0)
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	5b4080e7          	jalr	1460(ra) # 80001418 <uvmfirst>
    p->sz = PGSIZE;
    80001e6c:	6785                	lui	a5,0x1
    80001e6e:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001e70:	6cb8                	ld	a4,88(s1)
    80001e72:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001e76:	6cb8                	ld	a4,88(s1)
    80001e78:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e7a:	4641                	li	a2,16
    80001e7c:	00006597          	auipc	a1,0x6
    80001e80:	3c458593          	addi	a1,a1,964 # 80008240 <digits+0x1f0>
    80001e84:	15848513          	addi	a0,s1,344
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	056080e7          	jalr	86(ra) # 80000ede <safestrcpy>
    p->cwd = namei("/");
    80001e90:	00006517          	auipc	a0,0x6
    80001e94:	3c050513          	addi	a0,a0,960 # 80008250 <digits+0x200>
    80001e98:	00002097          	auipc	ra,0x2
    80001e9c:	4b0080e7          	jalr	1200(ra) # 80004348 <namei>
    80001ea0:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001ea4:	478d                	li	a5,3
    80001ea6:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001ea8:	8526                	mv	a0,s1
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	ea4080e7          	jalr	-348(ra) # 80000d4e <release>
}
    80001eb2:	60e2                	ld	ra,24(sp)
    80001eb4:	6442                	ld	s0,16(sp)
    80001eb6:	64a2                	ld	s1,8(sp)
    80001eb8:	6105                	addi	sp,sp,32
    80001eba:	8082                	ret

0000000080001ebc <growproc>:
{
    80001ebc:	1101                	addi	sp,sp,-32
    80001ebe:	ec06                	sd	ra,24(sp)
    80001ec0:	e822                	sd	s0,16(sp)
    80001ec2:	e426                	sd	s1,8(sp)
    80001ec4:	e04a                	sd	s2,0(sp)
    80001ec6:	1000                	addi	s0,sp,32
    80001ec8:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001eca:	00000097          	auipc	ra,0x0
    80001ece:	c98080e7          	jalr	-872(ra) # 80001b62 <myproc>
    80001ed2:	84aa                	mv	s1,a0
    sz = p->sz;
    80001ed4:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001ed6:	01204c63          	bgtz	s2,80001eee <growproc+0x32>
    else if (n < 0)
    80001eda:	02094663          	bltz	s2,80001f06 <growproc+0x4a>
    p->sz = sz;
    80001ede:	e4ac                	sd	a1,72(s1)
    return 0;
    80001ee0:	4501                	li	a0,0
}
    80001ee2:	60e2                	ld	ra,24(sp)
    80001ee4:	6442                	ld	s0,16(sp)
    80001ee6:	64a2                	ld	s1,8(sp)
    80001ee8:	6902                	ld	s2,0(sp)
    80001eea:	6105                	addi	sp,sp,32
    80001eec:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001eee:	4691                	li	a3,4
    80001ef0:	00b90633          	add	a2,s2,a1
    80001ef4:	6928                	ld	a0,80(a0)
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	5dc080e7          	jalr	1500(ra) # 800014d2 <uvmalloc>
    80001efe:	85aa                	mv	a1,a0
    80001f00:	fd79                	bnez	a0,80001ede <growproc+0x22>
            return -1;
    80001f02:	557d                	li	a0,-1
    80001f04:	bff9                	j	80001ee2 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f06:	00b90633          	add	a2,s2,a1
    80001f0a:	6928                	ld	a0,80(a0)
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	57e080e7          	jalr	1406(ra) # 8000148a <uvmdealloc>
    80001f14:	85aa                	mv	a1,a0
    80001f16:	b7e1                	j	80001ede <growproc+0x22>

0000000080001f18 <ps>:
{
    80001f18:	715d                	addi	sp,sp,-80
    80001f1a:	e486                	sd	ra,72(sp)
    80001f1c:	e0a2                	sd	s0,64(sp)
    80001f1e:	fc26                	sd	s1,56(sp)
    80001f20:	f84a                	sd	s2,48(sp)
    80001f22:	f44e                	sd	s3,40(sp)
    80001f24:	f052                	sd	s4,32(sp)
    80001f26:	ec56                	sd	s5,24(sp)
    80001f28:	e85a                	sd	s6,16(sp)
    80001f2a:	e45e                	sd	s7,8(sp)
    80001f2c:	e062                	sd	s8,0(sp)
    80001f2e:	0880                	addi	s0,sp,80
    80001f30:	84aa                	mv	s1,a0
    80001f32:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	c2e080e7          	jalr	-978(ra) # 80001b62 <myproc>
    if (count == 0)
    80001f3c:	120b8063          	beqz	s7,8000205c <ps+0x144>
    void *result = (void *)myproc()->sz;
    80001f40:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80001f44:	003b951b          	slliw	a0,s7,0x3
    80001f48:	0175053b          	addw	a0,a0,s7
    80001f4c:	0025151b          	slliw	a0,a0,0x2
    80001f50:	00000097          	auipc	ra,0x0
    80001f54:	f6c080e7          	jalr	-148(ra) # 80001ebc <growproc>
    80001f58:	10054463          	bltz	a0,80002060 <ps+0x148>
    struct user_proc loc_result[count];
    80001f5c:	003b9a13          	slli	s4,s7,0x3
    80001f60:	9a5e                	add	s4,s4,s7
    80001f62:	0a0a                	slli	s4,s4,0x2
    80001f64:	00fa0793          	addi	a5,s4,15
    80001f68:	8391                	srli	a5,a5,0x4
    80001f6a:	0792                	slli	a5,a5,0x4
    80001f6c:	40f10133          	sub	sp,sp,a5
    80001f70:	8a8a                	mv	s5,sp
    struct proc *p = proc + (start * sizeof(proc));
    80001f72:	007e97b7          	lui	a5,0x7e9
    80001f76:	02f484b3          	mul	s1,s1,a5
    80001f7a:	0000f797          	auipc	a5,0xf
    80001f7e:	19678793          	addi	a5,a5,406 # 80011110 <proc>
    80001f82:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80001f84:	00015797          	auipc	a5,0x15
    80001f88:	b8c78793          	addi	a5,a5,-1140 # 80016b10 <tickslock>
    80001f8c:	0cf4fc63          	bgeu	s1,a5,80002064 <ps+0x14c>
        if (localCount == count)
    80001f90:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80001f94:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80001f96:	8c3e                	mv	s8,a5
    80001f98:	a069                	j	80002022 <ps+0x10a>
            loc_result[localCount].state = UNUSED;
    80001f9a:	00399793          	slli	a5,s3,0x3
    80001f9e:	97ce                	add	a5,a5,s3
    80001fa0:	078a                	slli	a5,a5,0x2
    80001fa2:	97d6                	add	a5,a5,s5
    80001fa4:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	da4080e7          	jalr	-604(ra) # 80000d4e <release>
    if (localCount < count)
    80001fb2:	0179f963          	bgeu	s3,s7,80001fc4 <ps+0xac>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80001fb6:	00399793          	slli	a5,s3,0x3
    80001fba:	97ce                	add	a5,a5,s3
    80001fbc:	078a                	slli	a5,a5,0x2
    80001fbe:	97d6                	add	a5,a5,s5
    80001fc0:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80001fc4:	84da                	mv	s1,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	b9c080e7          	jalr	-1124(ra) # 80001b62 <myproc>
    80001fce:	86d2                	mv	a3,s4
    80001fd0:	8656                	mv	a2,s5
    80001fd2:	85da                	mv	a1,s6
    80001fd4:	6928                	ld	a0,80(a0)
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	758080e7          	jalr	1880(ra) # 8000172e <copyout>
}
    80001fde:	8526                	mv	a0,s1
    80001fe0:	fb040113          	addi	sp,s0,-80
    80001fe4:	60a6                	ld	ra,72(sp)
    80001fe6:	6406                	ld	s0,64(sp)
    80001fe8:	74e2                	ld	s1,56(sp)
    80001fea:	7942                	ld	s2,48(sp)
    80001fec:	79a2                	ld	s3,40(sp)
    80001fee:	7a02                	ld	s4,32(sp)
    80001ff0:	6ae2                	ld	s5,24(sp)
    80001ff2:	6b42                	ld	s6,16(sp)
    80001ff4:	6ba2                	ld	s7,8(sp)
    80001ff6:	6c02                	ld	s8,0(sp)
    80001ff8:	6161                	addi	sp,sp,80
    80001ffa:	8082                	ret
            loc_result[localCount].parent_id = p->parent->pid;
    80001ffc:	5b9c                	lw	a5,48(a5)
    80001ffe:	fef92e23          	sw	a5,-4(s2)
        release(&p->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	d4a080e7          	jalr	-694(ra) # 80000d4e <release>
        localCount++;
    8000200c:	2985                	addiw	s3,s3,1
    8000200e:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    80002012:	16848493          	addi	s1,s1,360
    80002016:	f984fee3          	bgeu	s1,s8,80001fb2 <ps+0x9a>
        if (localCount == count)
    8000201a:	02490913          	addi	s2,s2,36
    8000201e:	fb3b83e3          	beq	s7,s3,80001fc4 <ps+0xac>
        acquire(&p->lock);
    80002022:	8526                	mv	a0,s1
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	c76080e7          	jalr	-906(ra) # 80000c9a <acquire>
        if (p->state == UNUSED)
    8000202c:	4c9c                	lw	a5,24(s1)
    8000202e:	d7b5                	beqz	a5,80001f9a <ps+0x82>
        loc_result[localCount].state = p->state;
    80002030:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    80002034:	549c                	lw	a5,40(s1)
    80002036:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    8000203a:	54dc                	lw	a5,44(s1)
    8000203c:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    80002040:	589c                	lw	a5,48(s1)
    80002042:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002046:	4641                	li	a2,16
    80002048:	85ca                	mv	a1,s2
    8000204a:	15848513          	addi	a0,s1,344
    8000204e:	00000097          	auipc	ra,0x0
    80002052:	ac4080e7          	jalr	-1340(ra) # 80001b12 <copy_array>
        if (p->parent != 0) // init
    80002056:	7c9c                	ld	a5,56(s1)
    80002058:	f3d5                	bnez	a5,80001ffc <ps+0xe4>
    8000205a:	b765                	j	80002002 <ps+0xea>
        return result;
    8000205c:	4481                	li	s1,0
    8000205e:	b741                	j	80001fde <ps+0xc6>
        return result;
    80002060:	4481                	li	s1,0
    80002062:	bfb5                	j	80001fde <ps+0xc6>
        return result;
    80002064:	4481                	li	s1,0
    80002066:	bfa5                	j	80001fde <ps+0xc6>

0000000080002068 <fork>:
{
    80002068:	7139                	addi	sp,sp,-64
    8000206a:	fc06                	sd	ra,56(sp)
    8000206c:	f822                	sd	s0,48(sp)
    8000206e:	f426                	sd	s1,40(sp)
    80002070:	f04a                	sd	s2,32(sp)
    80002072:	ec4e                	sd	s3,24(sp)
    80002074:	e852                	sd	s4,16(sp)
    80002076:	e456                	sd	s5,8(sp)
    80002078:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000207a:	00000097          	auipc	ra,0x0
    8000207e:	ae8080e7          	jalr	-1304(ra) # 80001b62 <myproc>
    80002082:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002084:	00000097          	auipc	ra,0x0
    80002088:	ce8080e7          	jalr	-792(ra) # 80001d6c <allocproc>
    8000208c:	10050c63          	beqz	a0,800021a4 <fork+0x13c>
    80002090:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002092:	048ab603          	ld	a2,72(s5)
    80002096:	692c                	ld	a1,80(a0)
    80002098:	050ab503          	ld	a0,80(s5)
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	58e080e7          	jalr	1422(ra) # 8000162a <uvmcopy>
    800020a4:	04054863          	bltz	a0,800020f4 <fork+0x8c>
    np->sz = p->sz;
    800020a8:	048ab783          	ld	a5,72(s5)
    800020ac:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    800020b0:	058ab683          	ld	a3,88(s5)
    800020b4:	87b6                	mv	a5,a3
    800020b6:	058a3703          	ld	a4,88(s4)
    800020ba:	12068693          	addi	a3,a3,288
    800020be:	0007b803          	ld	a6,0(a5)
    800020c2:	6788                	ld	a0,8(a5)
    800020c4:	6b8c                	ld	a1,16(a5)
    800020c6:	6f90                	ld	a2,24(a5)
    800020c8:	01073023          	sd	a6,0(a4)
    800020cc:	e708                	sd	a0,8(a4)
    800020ce:	eb0c                	sd	a1,16(a4)
    800020d0:	ef10                	sd	a2,24(a4)
    800020d2:	02078793          	addi	a5,a5,32
    800020d6:	02070713          	addi	a4,a4,32
    800020da:	fed792e3          	bne	a5,a3,800020be <fork+0x56>
    np->trapframe->a0 = 0;
    800020de:	058a3783          	ld	a5,88(s4)
    800020e2:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800020e6:	0d0a8493          	addi	s1,s5,208
    800020ea:	0d0a0913          	addi	s2,s4,208
    800020ee:	150a8993          	addi	s3,s5,336
    800020f2:	a00d                	j	80002114 <fork+0xac>
        freeproc(np);
    800020f4:	8552                	mv	a0,s4
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	c1e080e7          	jalr	-994(ra) # 80001d14 <freeproc>
        release(&np->lock);
    800020fe:	8552                	mv	a0,s4
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	c4e080e7          	jalr	-946(ra) # 80000d4e <release>
        return -1;
    80002108:	597d                	li	s2,-1
    8000210a:	a059                	j	80002190 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    8000210c:	04a1                	addi	s1,s1,8
    8000210e:	0921                	addi	s2,s2,8
    80002110:	01348b63          	beq	s1,s3,80002126 <fork+0xbe>
        if (p->ofile[i])
    80002114:	6088                	ld	a0,0(s1)
    80002116:	d97d                	beqz	a0,8000210c <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    80002118:	00003097          	auipc	ra,0x3
    8000211c:	8a2080e7          	jalr	-1886(ra) # 800049ba <filedup>
    80002120:	00a93023          	sd	a0,0(s2)
    80002124:	b7e5                	j	8000210c <fork+0xa4>
    np->cwd = idup(p->cwd);
    80002126:	150ab503          	ld	a0,336(s5)
    8000212a:	00002097          	auipc	ra,0x2
    8000212e:	a3a080e7          	jalr	-1478(ra) # 80003b64 <idup>
    80002132:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002136:	4641                	li	a2,16
    80002138:	158a8593          	addi	a1,s5,344
    8000213c:	158a0513          	addi	a0,s4,344
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	d9e080e7          	jalr	-610(ra) # 80000ede <safestrcpy>
    pid = np->pid;
    80002148:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    8000214c:	8552                	mv	a0,s4
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	c00080e7          	jalr	-1024(ra) # 80000d4e <release>
    acquire(&wait_lock);
    80002156:	0000f497          	auipc	s1,0xf
    8000215a:	fa248493          	addi	s1,s1,-94 # 800110f8 <wait_lock>
    8000215e:	8526                	mv	a0,s1
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	b3a080e7          	jalr	-1222(ra) # 80000c9a <acquire>
    np->parent = p;
    80002168:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	be0080e7          	jalr	-1056(ra) # 80000d4e <release>
    acquire(&np->lock);
    80002176:	8552                	mv	a0,s4
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	b22080e7          	jalr	-1246(ra) # 80000c9a <acquire>
    np->state = RUNNABLE;
    80002180:	478d                	li	a5,3
    80002182:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002186:	8552                	mv	a0,s4
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	bc6080e7          	jalr	-1082(ra) # 80000d4e <release>
}
    80002190:	854a                	mv	a0,s2
    80002192:	70e2                	ld	ra,56(sp)
    80002194:	7442                	ld	s0,48(sp)
    80002196:	74a2                	ld	s1,40(sp)
    80002198:	7902                	ld	s2,32(sp)
    8000219a:	69e2                	ld	s3,24(sp)
    8000219c:	6a42                	ld	s4,16(sp)
    8000219e:	6aa2                	ld	s5,8(sp)
    800021a0:	6121                	addi	sp,sp,64
    800021a2:	8082                	ret
        return -1;
    800021a4:	597d                	li	s2,-1
    800021a6:	b7ed                	j	80002190 <fork+0x128>

00000000800021a8 <scheduler>:
{
    800021a8:	1101                	addi	sp,sp,-32
    800021aa:	ec06                	sd	ra,24(sp)
    800021ac:	e822                	sd	s0,16(sp)
    800021ae:	e426                	sd	s1,8(sp)
    800021b0:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    800021b2:	00007497          	auipc	s1,0x7
    800021b6:	80648493          	addi	s1,s1,-2042 # 800089b8 <sched_pointer>
    800021ba:	609c                	ld	a5,0(s1)
    800021bc:	9782                	jalr	a5
    while (1)
    800021be:	bff5                	j	800021ba <scheduler+0x12>

00000000800021c0 <sched>:
{
    800021c0:	7179                	addi	sp,sp,-48
    800021c2:	f406                	sd	ra,40(sp)
    800021c4:	f022                	sd	s0,32(sp)
    800021c6:	ec26                	sd	s1,24(sp)
    800021c8:	e84a                	sd	s2,16(sp)
    800021ca:	e44e                	sd	s3,8(sp)
    800021cc:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800021ce:	00000097          	auipc	ra,0x0
    800021d2:	994080e7          	jalr	-1644(ra) # 80001b62 <myproc>
    800021d6:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800021d8:	fffff097          	auipc	ra,0xfffff
    800021dc:	a48080e7          	jalr	-1464(ra) # 80000c20 <holding>
    800021e0:	c53d                	beqz	a0,8000224e <sched+0x8e>
    800021e2:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800021e4:	2781                	sext.w	a5,a5
    800021e6:	079e                	slli	a5,a5,0x7
    800021e8:	0000f717          	auipc	a4,0xf
    800021ec:	af870713          	addi	a4,a4,-1288 # 80010ce0 <cpus>
    800021f0:	97ba                	add	a5,a5,a4
    800021f2:	5fb8                	lw	a4,120(a5)
    800021f4:	4785                	li	a5,1
    800021f6:	06f71463          	bne	a4,a5,8000225e <sched+0x9e>
    if (p->state == RUNNING)
    800021fa:	4c98                	lw	a4,24(s1)
    800021fc:	4791                	li	a5,4
    800021fe:	06f70863          	beq	a4,a5,8000226e <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002202:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002206:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002208:	ebbd                	bnez	a5,8000227e <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000220a:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    8000220c:	0000f917          	auipc	s2,0xf
    80002210:	ad490913          	addi	s2,s2,-1324 # 80010ce0 <cpus>
    80002214:	2781                	sext.w	a5,a5
    80002216:	079e                	slli	a5,a5,0x7
    80002218:	97ca                	add	a5,a5,s2
    8000221a:	07c7a983          	lw	s3,124(a5)
    8000221e:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    80002220:	2581                	sext.w	a1,a1
    80002222:	059e                	slli	a1,a1,0x7
    80002224:	05a1                	addi	a1,a1,8
    80002226:	95ca                	add	a1,a1,s2
    80002228:	06048513          	addi	a0,s1,96
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	78e080e7          	jalr	1934(ra) # 800029ba <swtch>
    80002234:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002236:	2781                	sext.w	a5,a5
    80002238:	079e                	slli	a5,a5,0x7
    8000223a:	993e                	add	s2,s2,a5
    8000223c:	07392e23          	sw	s3,124(s2)
}
    80002240:	70a2                	ld	ra,40(sp)
    80002242:	7402                	ld	s0,32(sp)
    80002244:	64e2                	ld	s1,24(sp)
    80002246:	6942                	ld	s2,16(sp)
    80002248:	69a2                	ld	s3,8(sp)
    8000224a:	6145                	addi	sp,sp,48
    8000224c:	8082                	ret
        panic("sched p->lock");
    8000224e:	00006517          	auipc	a0,0x6
    80002252:	00a50513          	addi	a0,a0,10 # 80008258 <digits+0x208>
    80002256:	ffffe097          	auipc	ra,0xffffe
    8000225a:	2e6080e7          	jalr	742(ra) # 8000053c <panic>
        panic("sched locks");
    8000225e:	00006517          	auipc	a0,0x6
    80002262:	00a50513          	addi	a0,a0,10 # 80008268 <digits+0x218>
    80002266:	ffffe097          	auipc	ra,0xffffe
    8000226a:	2d6080e7          	jalr	726(ra) # 8000053c <panic>
        panic("sched running");
    8000226e:	00006517          	auipc	a0,0x6
    80002272:	00a50513          	addi	a0,a0,10 # 80008278 <digits+0x228>
    80002276:	ffffe097          	auipc	ra,0xffffe
    8000227a:	2c6080e7          	jalr	710(ra) # 8000053c <panic>
        panic("sched interruptible");
    8000227e:	00006517          	auipc	a0,0x6
    80002282:	00a50513          	addi	a0,a0,10 # 80008288 <digits+0x238>
    80002286:	ffffe097          	auipc	ra,0xffffe
    8000228a:	2b6080e7          	jalr	694(ra) # 8000053c <panic>

000000008000228e <yield>:
{
    8000228e:	1101                	addi	sp,sp,-32
    80002290:	ec06                	sd	ra,24(sp)
    80002292:	e822                	sd	s0,16(sp)
    80002294:	e426                	sd	s1,8(sp)
    80002296:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	8ca080e7          	jalr	-1846(ra) # 80001b62 <myproc>
    800022a0:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	9f8080e7          	jalr	-1544(ra) # 80000c9a <acquire>
    p->state = RUNNABLE;
    800022aa:	478d                	li	a5,3
    800022ac:	cc9c                	sw	a5,24(s1)
    sched();
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	f12080e7          	jalr	-238(ra) # 800021c0 <sched>
    release(&p->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	a96080e7          	jalr	-1386(ra) # 80000d4e <release>
}
    800022c0:	60e2                	ld	ra,24(sp)
    800022c2:	6442                	ld	s0,16(sp)
    800022c4:	64a2                	ld	s1,8(sp)
    800022c6:	6105                	addi	sp,sp,32
    800022c8:	8082                	ret

00000000800022ca <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800022ca:	7179                	addi	sp,sp,-48
    800022cc:	f406                	sd	ra,40(sp)
    800022ce:	f022                	sd	s0,32(sp)
    800022d0:	ec26                	sd	s1,24(sp)
    800022d2:	e84a                	sd	s2,16(sp)
    800022d4:	e44e                	sd	s3,8(sp)
    800022d6:	1800                	addi	s0,sp,48
    800022d8:	89aa                	mv	s3,a0
    800022da:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	886080e7          	jalr	-1914(ra) # 80001b62 <myproc>
    800022e4:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	9b4080e7          	jalr	-1612(ra) # 80000c9a <acquire>
    release(lk);
    800022ee:	854a                	mv	a0,s2
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	a5e080e7          	jalr	-1442(ra) # 80000d4e <release>

    // Go to sleep.
    p->chan = chan;
    800022f8:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    800022fc:	4789                	li	a5,2
    800022fe:	cc9c                	sw	a5,24(s1)

    sched();
    80002300:	00000097          	auipc	ra,0x0
    80002304:	ec0080e7          	jalr	-320(ra) # 800021c0 <sched>

    // Tidy up.
    p->chan = 0;
    80002308:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	a40080e7          	jalr	-1472(ra) # 80000d4e <release>
    acquire(lk);
    80002316:	854a                	mv	a0,s2
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	982080e7          	jalr	-1662(ra) # 80000c9a <acquire>
}
    80002320:	70a2                	ld	ra,40(sp)
    80002322:	7402                	ld	s0,32(sp)
    80002324:	64e2                	ld	s1,24(sp)
    80002326:	6942                	ld	s2,16(sp)
    80002328:	69a2                	ld	s3,8(sp)
    8000232a:	6145                	addi	sp,sp,48
    8000232c:	8082                	ret

000000008000232e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000232e:	7139                	addi	sp,sp,-64
    80002330:	fc06                	sd	ra,56(sp)
    80002332:	f822                	sd	s0,48(sp)
    80002334:	f426                	sd	s1,40(sp)
    80002336:	f04a                	sd	s2,32(sp)
    80002338:	ec4e                	sd	s3,24(sp)
    8000233a:	e852                	sd	s4,16(sp)
    8000233c:	e456                	sd	s5,8(sp)
    8000233e:	0080                	addi	s0,sp,64
    80002340:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002342:	0000f497          	auipc	s1,0xf
    80002346:	dce48493          	addi	s1,s1,-562 # 80011110 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000234a:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    8000234c:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000234e:	00014917          	auipc	s2,0x14
    80002352:	7c290913          	addi	s2,s2,1986 # 80016b10 <tickslock>
    80002356:	a811                	j	8000236a <wakeup+0x3c>
            }
            release(&p->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	9f4080e7          	jalr	-1548(ra) # 80000d4e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002362:	16848493          	addi	s1,s1,360
    80002366:	03248663          	beq	s1,s2,80002392 <wakeup+0x64>
        if (p != myproc())
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	7f8080e7          	jalr	2040(ra) # 80001b62 <myproc>
    80002372:	fea488e3          	beq	s1,a0,80002362 <wakeup+0x34>
            acquire(&p->lock);
    80002376:	8526                	mv	a0,s1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	922080e7          	jalr	-1758(ra) # 80000c9a <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002380:	4c9c                	lw	a5,24(s1)
    80002382:	fd379be3          	bne	a5,s3,80002358 <wakeup+0x2a>
    80002386:	709c                	ld	a5,32(s1)
    80002388:	fd4798e3          	bne	a5,s4,80002358 <wakeup+0x2a>
                p->state = RUNNABLE;
    8000238c:	0154ac23          	sw	s5,24(s1)
    80002390:	b7e1                	j	80002358 <wakeup+0x2a>
        }
    }
}
    80002392:	70e2                	ld	ra,56(sp)
    80002394:	7442                	ld	s0,48(sp)
    80002396:	74a2                	ld	s1,40(sp)
    80002398:	7902                	ld	s2,32(sp)
    8000239a:	69e2                	ld	s3,24(sp)
    8000239c:	6a42                	ld	s4,16(sp)
    8000239e:	6aa2                	ld	s5,8(sp)
    800023a0:	6121                	addi	sp,sp,64
    800023a2:	8082                	ret

00000000800023a4 <reparent>:
{
    800023a4:	7179                	addi	sp,sp,-48
    800023a6:	f406                	sd	ra,40(sp)
    800023a8:	f022                	sd	s0,32(sp)
    800023aa:	ec26                	sd	s1,24(sp)
    800023ac:	e84a                	sd	s2,16(sp)
    800023ae:	e44e                	sd	s3,8(sp)
    800023b0:	e052                	sd	s4,0(sp)
    800023b2:	1800                	addi	s0,sp,48
    800023b4:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023b6:	0000f497          	auipc	s1,0xf
    800023ba:	d5a48493          	addi	s1,s1,-678 # 80011110 <proc>
            pp->parent = initproc;
    800023be:	00006a17          	auipc	s4,0x6
    800023c2:	6aaa0a13          	addi	s4,s4,1706 # 80008a68 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023c6:	00014997          	auipc	s3,0x14
    800023ca:	74a98993          	addi	s3,s3,1866 # 80016b10 <tickslock>
    800023ce:	a029                	j	800023d8 <reparent+0x34>
    800023d0:	16848493          	addi	s1,s1,360
    800023d4:	01348d63          	beq	s1,s3,800023ee <reparent+0x4a>
        if (pp->parent == p)
    800023d8:	7c9c                	ld	a5,56(s1)
    800023da:	ff279be3          	bne	a5,s2,800023d0 <reparent+0x2c>
            pp->parent = initproc;
    800023de:	000a3503          	ld	a0,0(s4)
    800023e2:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800023e4:	00000097          	auipc	ra,0x0
    800023e8:	f4a080e7          	jalr	-182(ra) # 8000232e <wakeup>
    800023ec:	b7d5                	j	800023d0 <reparent+0x2c>
}
    800023ee:	70a2                	ld	ra,40(sp)
    800023f0:	7402                	ld	s0,32(sp)
    800023f2:	64e2                	ld	s1,24(sp)
    800023f4:	6942                	ld	s2,16(sp)
    800023f6:	69a2                	ld	s3,8(sp)
    800023f8:	6a02                	ld	s4,0(sp)
    800023fa:	6145                	addi	sp,sp,48
    800023fc:	8082                	ret

00000000800023fe <exit>:
{
    800023fe:	7179                	addi	sp,sp,-48
    80002400:	f406                	sd	ra,40(sp)
    80002402:	f022                	sd	s0,32(sp)
    80002404:	ec26                	sd	s1,24(sp)
    80002406:	e84a                	sd	s2,16(sp)
    80002408:	e44e                	sd	s3,8(sp)
    8000240a:	e052                	sd	s4,0(sp)
    8000240c:	1800                	addi	s0,sp,48
    8000240e:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	752080e7          	jalr	1874(ra) # 80001b62 <myproc>
    80002418:	89aa                	mv	s3,a0
    if (p == initproc)
    8000241a:	00006797          	auipc	a5,0x6
    8000241e:	64e7b783          	ld	a5,1614(a5) # 80008a68 <initproc>
    80002422:	0d050493          	addi	s1,a0,208
    80002426:	15050913          	addi	s2,a0,336
    8000242a:	02a79363          	bne	a5,a0,80002450 <exit+0x52>
        panic("init exiting");
    8000242e:	00006517          	auipc	a0,0x6
    80002432:	e7250513          	addi	a0,a0,-398 # 800082a0 <digits+0x250>
    80002436:	ffffe097          	auipc	ra,0xffffe
    8000243a:	106080e7          	jalr	262(ra) # 8000053c <panic>
            fileclose(f);
    8000243e:	00002097          	auipc	ra,0x2
    80002442:	5ce080e7          	jalr	1486(ra) # 80004a0c <fileclose>
            p->ofile[fd] = 0;
    80002446:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000244a:	04a1                	addi	s1,s1,8
    8000244c:	01248563          	beq	s1,s2,80002456 <exit+0x58>
        if (p->ofile[fd])
    80002450:	6088                	ld	a0,0(s1)
    80002452:	f575                	bnez	a0,8000243e <exit+0x40>
    80002454:	bfdd                	j	8000244a <exit+0x4c>
    begin_op();
    80002456:	00002097          	auipc	ra,0x2
    8000245a:	0f2080e7          	jalr	242(ra) # 80004548 <begin_op>
    iput(p->cwd);
    8000245e:	1509b503          	ld	a0,336(s3)
    80002462:	00002097          	auipc	ra,0x2
    80002466:	8fa080e7          	jalr	-1798(ra) # 80003d5c <iput>
    end_op();
    8000246a:	00002097          	auipc	ra,0x2
    8000246e:	158080e7          	jalr	344(ra) # 800045c2 <end_op>
    p->cwd = 0;
    80002472:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002476:	0000f497          	auipc	s1,0xf
    8000247a:	c8248493          	addi	s1,s1,-894 # 800110f8 <wait_lock>
    8000247e:	8526                	mv	a0,s1
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	81a080e7          	jalr	-2022(ra) # 80000c9a <acquire>
    reparent(p);
    80002488:	854e                	mv	a0,s3
    8000248a:	00000097          	auipc	ra,0x0
    8000248e:	f1a080e7          	jalr	-230(ra) # 800023a4 <reparent>
    wakeup(p->parent);
    80002492:	0389b503          	ld	a0,56(s3)
    80002496:	00000097          	auipc	ra,0x0
    8000249a:	e98080e7          	jalr	-360(ra) # 8000232e <wakeup>
    acquire(&p->lock);
    8000249e:	854e                	mv	a0,s3
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	7fa080e7          	jalr	2042(ra) # 80000c9a <acquire>
    p->xstate = status;
    800024a8:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    800024ac:	4795                	li	a5,5
    800024ae:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    800024b2:	8526                	mv	a0,s1
    800024b4:	fffff097          	auipc	ra,0xfffff
    800024b8:	89a080e7          	jalr	-1894(ra) # 80000d4e <release>
    sched();
    800024bc:	00000097          	auipc	ra,0x0
    800024c0:	d04080e7          	jalr	-764(ra) # 800021c0 <sched>
    panic("zombie exit");
    800024c4:	00006517          	auipc	a0,0x6
    800024c8:	dec50513          	addi	a0,a0,-532 # 800082b0 <digits+0x260>
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	070080e7          	jalr	112(ra) # 8000053c <panic>

00000000800024d4 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800024d4:	7179                	addi	sp,sp,-48
    800024d6:	f406                	sd	ra,40(sp)
    800024d8:	f022                	sd	s0,32(sp)
    800024da:	ec26                	sd	s1,24(sp)
    800024dc:	e84a                	sd	s2,16(sp)
    800024de:	e44e                	sd	s3,8(sp)
    800024e0:	1800                	addi	s0,sp,48
    800024e2:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024e4:	0000f497          	auipc	s1,0xf
    800024e8:	c2c48493          	addi	s1,s1,-980 # 80011110 <proc>
    800024ec:	00014997          	auipc	s3,0x14
    800024f0:	62498993          	addi	s3,s3,1572 # 80016b10 <tickslock>
    {
        acquire(&p->lock);
    800024f4:	8526                	mv	a0,s1
    800024f6:	ffffe097          	auipc	ra,0xffffe
    800024fa:	7a4080e7          	jalr	1956(ra) # 80000c9a <acquire>
        if (p->pid == pid)
    800024fe:	589c                	lw	a5,48(s1)
    80002500:	01278d63          	beq	a5,s2,8000251a <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	848080e7          	jalr	-1976(ra) # 80000d4e <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000250e:	16848493          	addi	s1,s1,360
    80002512:	ff3491e3          	bne	s1,s3,800024f4 <kill+0x20>
    }
    return -1;
    80002516:	557d                	li	a0,-1
    80002518:	a829                	j	80002532 <kill+0x5e>
            p->killed = 1;
    8000251a:	4785                	li	a5,1
    8000251c:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000251e:	4c98                	lw	a4,24(s1)
    80002520:	4789                	li	a5,2
    80002522:	00f70f63          	beq	a4,a5,80002540 <kill+0x6c>
            release(&p->lock);
    80002526:	8526                	mv	a0,s1
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	826080e7          	jalr	-2010(ra) # 80000d4e <release>
            return 0;
    80002530:	4501                	li	a0,0
}
    80002532:	70a2                	ld	ra,40(sp)
    80002534:	7402                	ld	s0,32(sp)
    80002536:	64e2                	ld	s1,24(sp)
    80002538:	6942                	ld	s2,16(sp)
    8000253a:	69a2                	ld	s3,8(sp)
    8000253c:	6145                	addi	sp,sp,48
    8000253e:	8082                	ret
                p->state = RUNNABLE;
    80002540:	478d                	li	a5,3
    80002542:	cc9c                	sw	a5,24(s1)
    80002544:	b7cd                	j	80002526 <kill+0x52>

0000000080002546 <setkilled>:

void setkilled(struct proc *p)
{
    80002546:	1101                	addi	sp,sp,-32
    80002548:	ec06                	sd	ra,24(sp)
    8000254a:	e822                	sd	s0,16(sp)
    8000254c:	e426                	sd	s1,8(sp)
    8000254e:	1000                	addi	s0,sp,32
    80002550:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	748080e7          	jalr	1864(ra) # 80000c9a <acquire>
    p->killed = 1;
    8000255a:	4785                	li	a5,1
    8000255c:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    8000255e:	8526                	mv	a0,s1
    80002560:	ffffe097          	auipc	ra,0xffffe
    80002564:	7ee080e7          	jalr	2030(ra) # 80000d4e <release>
}
    80002568:	60e2                	ld	ra,24(sp)
    8000256a:	6442                	ld	s0,16(sp)
    8000256c:	64a2                	ld	s1,8(sp)
    8000256e:	6105                	addi	sp,sp,32
    80002570:	8082                	ret

0000000080002572 <killed>:

int killed(struct proc *p)
{
    80002572:	1101                	addi	sp,sp,-32
    80002574:	ec06                	sd	ra,24(sp)
    80002576:	e822                	sd	s0,16(sp)
    80002578:	e426                	sd	s1,8(sp)
    8000257a:	e04a                	sd	s2,0(sp)
    8000257c:	1000                	addi	s0,sp,32
    8000257e:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	71a080e7          	jalr	1818(ra) # 80000c9a <acquire>
    k = p->killed;
    80002588:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    8000258c:	8526                	mv	a0,s1
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	7c0080e7          	jalr	1984(ra) # 80000d4e <release>
    return k;
}
    80002596:	854a                	mv	a0,s2
    80002598:	60e2                	ld	ra,24(sp)
    8000259a:	6442                	ld	s0,16(sp)
    8000259c:	64a2                	ld	s1,8(sp)
    8000259e:	6902                	ld	s2,0(sp)
    800025a0:	6105                	addi	sp,sp,32
    800025a2:	8082                	ret

00000000800025a4 <wait>:
{
    800025a4:	715d                	addi	sp,sp,-80
    800025a6:	e486                	sd	ra,72(sp)
    800025a8:	e0a2                	sd	s0,64(sp)
    800025aa:	fc26                	sd	s1,56(sp)
    800025ac:	f84a                	sd	s2,48(sp)
    800025ae:	f44e                	sd	s3,40(sp)
    800025b0:	f052                	sd	s4,32(sp)
    800025b2:	ec56                	sd	s5,24(sp)
    800025b4:	e85a                	sd	s6,16(sp)
    800025b6:	e45e                	sd	s7,8(sp)
    800025b8:	e062                	sd	s8,0(sp)
    800025ba:	0880                	addi	s0,sp,80
    800025bc:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	5a4080e7          	jalr	1444(ra) # 80001b62 <myproc>
    800025c6:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800025c8:	0000f517          	auipc	a0,0xf
    800025cc:	b3050513          	addi	a0,a0,-1232 # 800110f8 <wait_lock>
    800025d0:	ffffe097          	auipc	ra,0xffffe
    800025d4:	6ca080e7          	jalr	1738(ra) # 80000c9a <acquire>
        havekids = 0;
    800025d8:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800025da:	4a15                	li	s4,5
                havekids = 1;
    800025dc:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800025de:	00014997          	auipc	s3,0x14
    800025e2:	53298993          	addi	s3,s3,1330 # 80016b10 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800025e6:	0000fc17          	auipc	s8,0xf
    800025ea:	b12c0c13          	addi	s8,s8,-1262 # 800110f8 <wait_lock>
    800025ee:	a0d1                	j	800026b2 <wait+0x10e>
                    pid = pp->pid;
    800025f0:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025f4:	000b0e63          	beqz	s6,80002610 <wait+0x6c>
    800025f8:	4691                	li	a3,4
    800025fa:	02c48613          	addi	a2,s1,44
    800025fe:	85da                	mv	a1,s6
    80002600:	05093503          	ld	a0,80(s2)
    80002604:	fffff097          	auipc	ra,0xfffff
    80002608:	12a080e7          	jalr	298(ra) # 8000172e <copyout>
    8000260c:	04054163          	bltz	a0,8000264e <wait+0xaa>
                    freeproc(pp);
    80002610:	8526                	mv	a0,s1
    80002612:	fffff097          	auipc	ra,0xfffff
    80002616:	702080e7          	jalr	1794(ra) # 80001d14 <freeproc>
                    release(&pp->lock);
    8000261a:	8526                	mv	a0,s1
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	732080e7          	jalr	1842(ra) # 80000d4e <release>
                    release(&wait_lock);
    80002624:	0000f517          	auipc	a0,0xf
    80002628:	ad450513          	addi	a0,a0,-1324 # 800110f8 <wait_lock>
    8000262c:	ffffe097          	auipc	ra,0xffffe
    80002630:	722080e7          	jalr	1826(ra) # 80000d4e <release>
}
    80002634:	854e                	mv	a0,s3
    80002636:	60a6                	ld	ra,72(sp)
    80002638:	6406                	ld	s0,64(sp)
    8000263a:	74e2                	ld	s1,56(sp)
    8000263c:	7942                	ld	s2,48(sp)
    8000263e:	79a2                	ld	s3,40(sp)
    80002640:	7a02                	ld	s4,32(sp)
    80002642:	6ae2                	ld	s5,24(sp)
    80002644:	6b42                	ld	s6,16(sp)
    80002646:	6ba2                	ld	s7,8(sp)
    80002648:	6c02                	ld	s8,0(sp)
    8000264a:	6161                	addi	sp,sp,80
    8000264c:	8082                	ret
                        release(&pp->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	6fe080e7          	jalr	1790(ra) # 80000d4e <release>
                        release(&wait_lock);
    80002658:	0000f517          	auipc	a0,0xf
    8000265c:	aa050513          	addi	a0,a0,-1376 # 800110f8 <wait_lock>
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	6ee080e7          	jalr	1774(ra) # 80000d4e <release>
                        return -1;
    80002668:	59fd                	li	s3,-1
    8000266a:	b7e9                	j	80002634 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000266c:	16848493          	addi	s1,s1,360
    80002670:	03348463          	beq	s1,s3,80002698 <wait+0xf4>
            if (pp->parent == p)
    80002674:	7c9c                	ld	a5,56(s1)
    80002676:	ff279be3          	bne	a5,s2,8000266c <wait+0xc8>
                acquire(&pp->lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	61e080e7          	jalr	1566(ra) # 80000c9a <acquire>
                if (pp->state == ZOMBIE)
    80002684:	4c9c                	lw	a5,24(s1)
    80002686:	f74785e3          	beq	a5,s4,800025f0 <wait+0x4c>
                release(&pp->lock);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	6c2080e7          	jalr	1730(ra) # 80000d4e <release>
                havekids = 1;
    80002694:	8756                	mv	a4,s5
    80002696:	bfd9                	j	8000266c <wait+0xc8>
        if (!havekids || killed(p))
    80002698:	c31d                	beqz	a4,800026be <wait+0x11a>
    8000269a:	854a                	mv	a0,s2
    8000269c:	00000097          	auipc	ra,0x0
    800026a0:	ed6080e7          	jalr	-298(ra) # 80002572 <killed>
    800026a4:	ed09                	bnez	a0,800026be <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800026a6:	85e2                	mv	a1,s8
    800026a8:	854a                	mv	a0,s2
    800026aa:	00000097          	auipc	ra,0x0
    800026ae:	c20080e7          	jalr	-992(ra) # 800022ca <sleep>
        havekids = 0;
    800026b2:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800026b4:	0000f497          	auipc	s1,0xf
    800026b8:	a5c48493          	addi	s1,s1,-1444 # 80011110 <proc>
    800026bc:	bf65                	j	80002674 <wait+0xd0>
            release(&wait_lock);
    800026be:	0000f517          	auipc	a0,0xf
    800026c2:	a3a50513          	addi	a0,a0,-1478 # 800110f8 <wait_lock>
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	688080e7          	jalr	1672(ra) # 80000d4e <release>
            return -1;
    800026ce:	59fd                	li	s3,-1
    800026d0:	b795                	j	80002634 <wait+0x90>

00000000800026d2 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026d2:	7179                	addi	sp,sp,-48
    800026d4:	f406                	sd	ra,40(sp)
    800026d6:	f022                	sd	s0,32(sp)
    800026d8:	ec26                	sd	s1,24(sp)
    800026da:	e84a                	sd	s2,16(sp)
    800026dc:	e44e                	sd	s3,8(sp)
    800026de:	e052                	sd	s4,0(sp)
    800026e0:	1800                	addi	s0,sp,48
    800026e2:	84aa                	mv	s1,a0
    800026e4:	892e                	mv	s2,a1
    800026e6:	89b2                	mv	s3,a2
    800026e8:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	478080e7          	jalr	1144(ra) # 80001b62 <myproc>
    if (user_dst)
    800026f2:	c08d                	beqz	s1,80002714 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800026f4:	86d2                	mv	a3,s4
    800026f6:	864e                	mv	a2,s3
    800026f8:	85ca                	mv	a1,s2
    800026fa:	6928                	ld	a0,80(a0)
    800026fc:	fffff097          	auipc	ra,0xfffff
    80002700:	032080e7          	jalr	50(ra) # 8000172e <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002704:	70a2                	ld	ra,40(sp)
    80002706:	7402                	ld	s0,32(sp)
    80002708:	64e2                	ld	s1,24(sp)
    8000270a:	6942                	ld	s2,16(sp)
    8000270c:	69a2                	ld	s3,8(sp)
    8000270e:	6a02                	ld	s4,0(sp)
    80002710:	6145                	addi	sp,sp,48
    80002712:	8082                	ret
        memmove((char *)dst, src, len);
    80002714:	000a061b          	sext.w	a2,s4
    80002718:	85ce                	mv	a1,s3
    8000271a:	854a                	mv	a0,s2
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	6d6080e7          	jalr	1750(ra) # 80000df2 <memmove>
        return 0;
    80002724:	8526                	mv	a0,s1
    80002726:	bff9                	j	80002704 <either_copyout+0x32>

0000000080002728 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002728:	7179                	addi	sp,sp,-48
    8000272a:	f406                	sd	ra,40(sp)
    8000272c:	f022                	sd	s0,32(sp)
    8000272e:	ec26                	sd	s1,24(sp)
    80002730:	e84a                	sd	s2,16(sp)
    80002732:	e44e                	sd	s3,8(sp)
    80002734:	e052                	sd	s4,0(sp)
    80002736:	1800                	addi	s0,sp,48
    80002738:	892a                	mv	s2,a0
    8000273a:	84ae                	mv	s1,a1
    8000273c:	89b2                	mv	s3,a2
    8000273e:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002740:	fffff097          	auipc	ra,0xfffff
    80002744:	422080e7          	jalr	1058(ra) # 80001b62 <myproc>
    if (user_src)
    80002748:	c08d                	beqz	s1,8000276a <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    8000274a:	86d2                	mv	a3,s4
    8000274c:	864e                	mv	a2,s3
    8000274e:	85ca                	mv	a1,s2
    80002750:	6928                	ld	a0,80(a0)
    80002752:	fffff097          	auipc	ra,0xfffff
    80002756:	068080e7          	jalr	104(ra) # 800017ba <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    8000275a:	70a2                	ld	ra,40(sp)
    8000275c:	7402                	ld	s0,32(sp)
    8000275e:	64e2                	ld	s1,24(sp)
    80002760:	6942                	ld	s2,16(sp)
    80002762:	69a2                	ld	s3,8(sp)
    80002764:	6a02                	ld	s4,0(sp)
    80002766:	6145                	addi	sp,sp,48
    80002768:	8082                	ret
        memmove(dst, (char *)src, len);
    8000276a:	000a061b          	sext.w	a2,s4
    8000276e:	85ce                	mv	a1,s3
    80002770:	854a                	mv	a0,s2
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	680080e7          	jalr	1664(ra) # 80000df2 <memmove>
        return 0;
    8000277a:	8526                	mv	a0,s1
    8000277c:	bff9                	j	8000275a <either_copyin+0x32>

000000008000277e <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000277e:	715d                	addi	sp,sp,-80
    80002780:	e486                	sd	ra,72(sp)
    80002782:	e0a2                	sd	s0,64(sp)
    80002784:	fc26                	sd	s1,56(sp)
    80002786:	f84a                	sd	s2,48(sp)
    80002788:	f44e                	sd	s3,40(sp)
    8000278a:	f052                	sd	s4,32(sp)
    8000278c:	ec56                	sd	s5,24(sp)
    8000278e:	e85a                	sd	s6,16(sp)
    80002790:	e45e                	sd	s7,8(sp)
    80002792:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002794:	00006517          	auipc	a0,0x6
    80002798:	8f450513          	addi	a0,a0,-1804 # 80008088 <digits+0x38>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	dfc080e7          	jalr	-516(ra) # 80000598 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800027a4:	0000f497          	auipc	s1,0xf
    800027a8:	ac448493          	addi	s1,s1,-1340 # 80011268 <proc+0x158>
    800027ac:	00014917          	auipc	s2,0x14
    800027b0:	4bc90913          	addi	s2,s2,1212 # 80016c68 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027b4:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    800027b6:	00006997          	auipc	s3,0x6
    800027ba:	b0a98993          	addi	s3,s3,-1270 # 800082c0 <digits+0x270>
        printf("%d <%s %s", p->pid, state, p->name);
    800027be:	00006a97          	auipc	s5,0x6
    800027c2:	b0aa8a93          	addi	s5,s5,-1270 # 800082c8 <digits+0x278>
        printf("\n");
    800027c6:	00006a17          	auipc	s4,0x6
    800027ca:	8c2a0a13          	addi	s4,s4,-1854 # 80008088 <digits+0x38>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ce:	00006b97          	auipc	s7,0x6
    800027d2:	c22b8b93          	addi	s7,s7,-990 # 800083f0 <states.0>
    800027d6:	a00d                	j	800027f8 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800027d8:	ed86a583          	lw	a1,-296(a3)
    800027dc:	8556                	mv	a0,s5
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	dba080e7          	jalr	-582(ra) # 80000598 <printf>
        printf("\n");
    800027e6:	8552                	mv	a0,s4
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	db0080e7          	jalr	-592(ra) # 80000598 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800027f0:	16848493          	addi	s1,s1,360
    800027f4:	03248263          	beq	s1,s2,80002818 <procdump+0x9a>
        if (p->state == UNUSED)
    800027f8:	86a6                	mv	a3,s1
    800027fa:	ec04a783          	lw	a5,-320(s1)
    800027fe:	dbed                	beqz	a5,800027f0 <procdump+0x72>
            state = "???";
    80002800:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002802:	fcfb6be3          	bltu	s6,a5,800027d8 <procdump+0x5a>
    80002806:	02079713          	slli	a4,a5,0x20
    8000280a:	01d75793          	srli	a5,a4,0x1d
    8000280e:	97de                	add	a5,a5,s7
    80002810:	6390                	ld	a2,0(a5)
    80002812:	f279                	bnez	a2,800027d8 <procdump+0x5a>
            state = "???";
    80002814:	864e                	mv	a2,s3
    80002816:	b7c9                	j	800027d8 <procdump+0x5a>
    }
}
    80002818:	60a6                	ld	ra,72(sp)
    8000281a:	6406                	ld	s0,64(sp)
    8000281c:	74e2                	ld	s1,56(sp)
    8000281e:	7942                	ld	s2,48(sp)
    80002820:	79a2                	ld	s3,40(sp)
    80002822:	7a02                	ld	s4,32(sp)
    80002824:	6ae2                	ld	s5,24(sp)
    80002826:	6b42                	ld	s6,16(sp)
    80002828:	6ba2                	ld	s7,8(sp)
    8000282a:	6161                	addi	sp,sp,80
    8000282c:	8082                	ret

000000008000282e <schedls>:

void schedls()
{
    8000282e:	1141                	addi	sp,sp,-16
    80002830:	e406                	sd	ra,8(sp)
    80002832:	e022                	sd	s0,0(sp)
    80002834:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002836:	00006517          	auipc	a0,0x6
    8000283a:	aa250513          	addi	a0,a0,-1374 # 800082d8 <digits+0x288>
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	d5a080e7          	jalr	-678(ra) # 80000598 <printf>
    printf("====================================\n");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	aba50513          	addi	a0,a0,-1350 # 80008300 <digits+0x2b0>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	d4a080e7          	jalr	-694(ra) # 80000598 <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002856:	00006717          	auipc	a4,0x6
    8000285a:	1c273703          	ld	a4,450(a4) # 80008a18 <available_schedulers+0x10>
    8000285e:	00006797          	auipc	a5,0x6
    80002862:	15a7b783          	ld	a5,346(a5) # 800089b8 <sched_pointer>
    80002866:	04f70663          	beq	a4,a5,800028b2 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    8000286a:	00006517          	auipc	a0,0x6
    8000286e:	ac650513          	addi	a0,a0,-1338 # 80008330 <digits+0x2e0>
    80002872:	ffffe097          	auipc	ra,0xffffe
    80002876:	d26080e7          	jalr	-730(ra) # 80000598 <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    8000287a:	00006617          	auipc	a2,0x6
    8000287e:	1a662603          	lw	a2,422(a2) # 80008a20 <available_schedulers+0x18>
    80002882:	00006597          	auipc	a1,0x6
    80002886:	18658593          	addi	a1,a1,390 # 80008a08 <available_schedulers>
    8000288a:	00006517          	auipc	a0,0x6
    8000288e:	aae50513          	addi	a0,a0,-1362 # 80008338 <digits+0x2e8>
    80002892:	ffffe097          	auipc	ra,0xffffe
    80002896:	d06080e7          	jalr	-762(ra) # 80000598 <printf>
    }
    printf("\n*: current scheduler\n\n");
    8000289a:	00006517          	auipc	a0,0x6
    8000289e:	aa650513          	addi	a0,a0,-1370 # 80008340 <digits+0x2f0>
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	cf6080e7          	jalr	-778(ra) # 80000598 <printf>
}
    800028aa:	60a2                	ld	ra,8(sp)
    800028ac:	6402                	ld	s0,0(sp)
    800028ae:	0141                	addi	sp,sp,16
    800028b0:	8082                	ret
            printf("[*]\t");
    800028b2:	00006517          	auipc	a0,0x6
    800028b6:	a7650513          	addi	a0,a0,-1418 # 80008328 <digits+0x2d8>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	cde080e7          	jalr	-802(ra) # 80000598 <printf>
    800028c2:	bf65                	j	8000287a <schedls+0x4c>

00000000800028c4 <schedset>:

void schedset(int id)
{
    800028c4:	1141                	addi	sp,sp,-16
    800028c6:	e406                	sd	ra,8(sp)
    800028c8:	e022                	sd	s0,0(sp)
    800028ca:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    800028cc:	e90d                	bnez	a0,800028fe <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    800028ce:	00006797          	auipc	a5,0x6
    800028d2:	14a7b783          	ld	a5,330(a5) # 80008a18 <available_schedulers+0x10>
    800028d6:	00006717          	auipc	a4,0x6
    800028da:	0ef73123          	sd	a5,226(a4) # 800089b8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    800028de:	00006597          	auipc	a1,0x6
    800028e2:	12a58593          	addi	a1,a1,298 # 80008a08 <available_schedulers>
    800028e6:	00006517          	auipc	a0,0x6
    800028ea:	a9a50513          	addi	a0,a0,-1382 # 80008380 <digits+0x330>
    800028ee:	ffffe097          	auipc	ra,0xffffe
    800028f2:	caa080e7          	jalr	-854(ra) # 80000598 <printf>
}
    800028f6:	60a2                	ld	ra,8(sp)
    800028f8:	6402                	ld	s0,0(sp)
    800028fa:	0141                	addi	sp,sp,16
    800028fc:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    800028fe:	00006517          	auipc	a0,0x6
    80002902:	a5a50513          	addi	a0,a0,-1446 # 80008358 <digits+0x308>
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	c92080e7          	jalr	-878(ra) # 80000598 <printf>
        return;
    8000290e:	b7e5                	j	800028f6 <schedset+0x32>

0000000080002910 <someFunc>:

int someFunc(uint64 addr, int pid) {
    80002910:	1101                	addi	sp,sp,-32
    80002912:	ec06                	sd	ra,24(sp)
    80002914:	e822                	sd	s0,16(sp)
    80002916:	e426                	sd	s1,8(sp)
    80002918:	e04a                	sd	s2,0(sp)
    8000291a:	1000                	addi	s0,sp,32
    8000291c:	892a                	mv	s2,a0
    8000291e:	84ae                	mv	s1,a1
    uint64 virtualAdress;
    struct proc *p;

    virtualAdress = addr;

    printf("vals: %u, %s", addr, pid);
    80002920:	862e                	mv	a2,a1
    80002922:	85aa                	mv	a1,a0
    80002924:	00006517          	auipc	a0,0x6
    80002928:	a8450513          	addi	a0,a0,-1404 # 800083a8 <digits+0x358>
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	c6c080e7          	jalr	-916(ra) # 80000598 <printf>

    printf("working");
    80002934:	00006517          	auipc	a0,0x6
    80002938:	a8450513          	addi	a0,a0,-1404 # 800083b8 <digits+0x368>
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	c5c080e7          	jalr	-932(ra) # 80000598 <printf>
    if (pid == 0) {
        p=myproc();
    } else {
        for (p = proc; p < &proc[NPROC]; p++) {
    80002944:	0000e797          	auipc	a5,0xe
    80002948:	7cc78793          	addi	a5,a5,1996 # 80011110 <proc>
    8000294c:	00014697          	auipc	a3,0x14
    80002950:	1c468693          	addi	a3,a3,452 # 80016b10 <tickslock>
    if (pid == 0) {
    80002954:	c891                	beqz	s1,80002968 <someFunc+0x58>
            if (p->pid == pid) {
    80002956:	5b98                	lw	a4,48(a5)
    80002958:	00970e63          	beq	a4,s1,80002974 <someFunc+0x64>
        for (p = proc; p < &proc[NPROC]; p++) {
    8000295c:	16878793          	addi	a5,a5,360
    80002960:	fed79be3          	bne	a5,a3,80002956 <someFunc+0x46>
                break;
            }
        }
        if (p == &proc[NPROC]) {
            // No process with the given PID found
            return 0;
    80002964:	4501                	li	a0,0
    80002966:	a091                	j	800029aa <someFunc+0x9a>
        p=myproc();
    80002968:	fffff097          	auipc	ra,0xfffff
    8000296c:	1fa080e7          	jalr	506(ra) # 80001b62 <myproc>
    80002970:	87aa                	mv	a5,a0
    80002972:	a039                	j	80002980 <someFunc+0x70>
        if (p == &proc[NPROC]) {
    80002974:	00014717          	auipc	a4,0x14
    80002978:	19c70713          	addi	a4,a4,412 # 80016b10 <tickslock>
    8000297c:	02e78d63          	beq	a5,a4,800029b6 <someFunc+0xa6>
        }
    }

    pte_t *pte = (pte_t *) walkaddr(p->pagetable, (uint64) virtualAdress);
    80002980:	85ca                	mv	a1,s2
    80002982:	6ba8                	ld	a0,80(a5)
    80002984:	ffffe097          	auipc	ra,0xffffe
    80002988:	79a080e7          	jalr	1946(ra) # 8000111e <walkaddr>
    8000298c:	87aa                	mv	a5,a0


    if (pte == 0 || !(*pte & PTE_V)) {
        // No mapping exists for the given virtual address
        return 0;
    8000298e:	4501                	li	a0,0
    if (pte == 0 || !(*pte & PTE_V)) {
    80002990:	cf89                	beqz	a5,800029aa <someFunc+0x9a>
    80002992:	639c                	ld	a5,0(a5)
    80002994:	0017f713          	andi	a4,a5,1
    80002998:	cb09                	beqz	a4,800029aa <someFunc+0x9a>
    }

    return PTE2PA(*pte) | (virtualAdress & (PGSIZE-1));
    8000299a:	83a9                	srli	a5,a5,0xa
    8000299c:	00c7979b          	slliw	a5,a5,0xc
    800029a0:	03491513          	slli	a0,s2,0x34
    800029a4:	9151                	srli	a0,a0,0x34
    800029a6:	8d5d                	or	a0,a0,a5
    800029a8:	2501                	sext.w	a0,a0
    800029aa:	60e2                	ld	ra,24(sp)
    800029ac:	6442                	ld	s0,16(sp)
    800029ae:	64a2                	ld	s1,8(sp)
    800029b0:	6902                	ld	s2,0(sp)
    800029b2:	6105                	addi	sp,sp,32
    800029b4:	8082                	ret
            return 0;
    800029b6:	4501                	li	a0,0
    800029b8:	bfcd                	j	800029aa <someFunc+0x9a>

00000000800029ba <swtch>:
    800029ba:	00153023          	sd	ra,0(a0)
    800029be:	00253423          	sd	sp,8(a0)
    800029c2:	e900                	sd	s0,16(a0)
    800029c4:	ed04                	sd	s1,24(a0)
    800029c6:	03253023          	sd	s2,32(a0)
    800029ca:	03353423          	sd	s3,40(a0)
    800029ce:	03453823          	sd	s4,48(a0)
    800029d2:	03553c23          	sd	s5,56(a0)
    800029d6:	05653023          	sd	s6,64(a0)
    800029da:	05753423          	sd	s7,72(a0)
    800029de:	05853823          	sd	s8,80(a0)
    800029e2:	05953c23          	sd	s9,88(a0)
    800029e6:	07a53023          	sd	s10,96(a0)
    800029ea:	07b53423          	sd	s11,104(a0)
    800029ee:	0005b083          	ld	ra,0(a1)
    800029f2:	0085b103          	ld	sp,8(a1)
    800029f6:	6980                	ld	s0,16(a1)
    800029f8:	6d84                	ld	s1,24(a1)
    800029fa:	0205b903          	ld	s2,32(a1)
    800029fe:	0285b983          	ld	s3,40(a1)
    80002a02:	0305ba03          	ld	s4,48(a1)
    80002a06:	0385ba83          	ld	s5,56(a1)
    80002a0a:	0405bb03          	ld	s6,64(a1)
    80002a0e:	0485bb83          	ld	s7,72(a1)
    80002a12:	0505bc03          	ld	s8,80(a1)
    80002a16:	0585bc83          	ld	s9,88(a1)
    80002a1a:	0605bd03          	ld	s10,96(a1)
    80002a1e:	0685bd83          	ld	s11,104(a1)
    80002a22:	8082                	ret

0000000080002a24 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a24:	1141                	addi	sp,sp,-16
    80002a26:	e406                	sd	ra,8(sp)
    80002a28:	e022                	sd	s0,0(sp)
    80002a2a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a2c:	00006597          	auipc	a1,0x6
    80002a30:	9f458593          	addi	a1,a1,-1548 # 80008420 <states.0+0x30>
    80002a34:	00014517          	auipc	a0,0x14
    80002a38:	0dc50513          	addi	a0,a0,220 # 80016b10 <tickslock>
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	1ce080e7          	jalr	462(ra) # 80000c0a <initlock>
}
    80002a44:	60a2                	ld	ra,8(sp)
    80002a46:	6402                	ld	s0,0(sp)
    80002a48:	0141                	addi	sp,sp,16
    80002a4a:	8082                	ret

0000000080002a4c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a4c:	1141                	addi	sp,sp,-16
    80002a4e:	e422                	sd	s0,8(sp)
    80002a50:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a52:	00003797          	auipc	a5,0x3
    80002a56:	5de78793          	addi	a5,a5,1502 # 80006030 <kernelvec>
    80002a5a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a5e:	6422                	ld	s0,8(sp)
    80002a60:	0141                	addi	sp,sp,16
    80002a62:	8082                	ret

0000000080002a64 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a64:	1141                	addi	sp,sp,-16
    80002a66:	e406                	sd	ra,8(sp)
    80002a68:	e022                	sd	s0,0(sp)
    80002a6a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a6c:	fffff097          	auipc	ra,0xfffff
    80002a70:	0f6080e7          	jalr	246(ra) # 80001b62 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a78:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a7a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a7e:	00004697          	auipc	a3,0x4
    80002a82:	58268693          	addi	a3,a3,1410 # 80007000 <_trampoline>
    80002a86:	00004717          	auipc	a4,0x4
    80002a8a:	57a70713          	addi	a4,a4,1402 # 80007000 <_trampoline>
    80002a8e:	8f15                	sub	a4,a4,a3
    80002a90:	040007b7          	lui	a5,0x4000
    80002a94:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002a96:	07b2                	slli	a5,a5,0xc
    80002a98:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a9e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002aa0:	18002673          	csrr	a2,satp
    80002aa4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aa6:	6d30                	ld	a2,88(a0)
    80002aa8:	6138                	ld	a4,64(a0)
    80002aaa:	6585                	lui	a1,0x1
    80002aac:	972e                	add	a4,a4,a1
    80002aae:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ab0:	6d38                	ld	a4,88(a0)
    80002ab2:	00000617          	auipc	a2,0x0
    80002ab6:	13460613          	addi	a2,a2,308 # 80002be6 <usertrap>
    80002aba:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002abc:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002abe:	8612                	mv	a2,tp
    80002ac0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ac2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ac6:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002aca:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ace:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ad2:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ad4:	6f18                	ld	a4,24(a4)
    80002ad6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ada:	6928                	ld	a0,80(a0)
    80002adc:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002ade:	00004717          	auipc	a4,0x4
    80002ae2:	5be70713          	addi	a4,a4,1470 # 8000709c <userret>
    80002ae6:	8f15                	sub	a4,a4,a3
    80002ae8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002aea:	577d                	li	a4,-1
    80002aec:	177e                	slli	a4,a4,0x3f
    80002aee:	8d59                	or	a0,a0,a4
    80002af0:	9782                	jalr	a5
}
    80002af2:	60a2                	ld	ra,8(sp)
    80002af4:	6402                	ld	s0,0(sp)
    80002af6:	0141                	addi	sp,sp,16
    80002af8:	8082                	ret

0000000080002afa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002afa:	1101                	addi	sp,sp,-32
    80002afc:	ec06                	sd	ra,24(sp)
    80002afe:	e822                	sd	s0,16(sp)
    80002b00:	e426                	sd	s1,8(sp)
    80002b02:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b04:	00014497          	auipc	s1,0x14
    80002b08:	00c48493          	addi	s1,s1,12 # 80016b10 <tickslock>
    80002b0c:	8526                	mv	a0,s1
    80002b0e:	ffffe097          	auipc	ra,0xffffe
    80002b12:	18c080e7          	jalr	396(ra) # 80000c9a <acquire>
  ticks++;
    80002b16:	00006517          	auipc	a0,0x6
    80002b1a:	f5a50513          	addi	a0,a0,-166 # 80008a70 <ticks>
    80002b1e:	411c                	lw	a5,0(a0)
    80002b20:	2785                	addiw	a5,a5,1
    80002b22:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	80a080e7          	jalr	-2038(ra) # 8000232e <wakeup>
  release(&tickslock);
    80002b2c:	8526                	mv	a0,s1
    80002b2e:	ffffe097          	auipc	ra,0xffffe
    80002b32:	220080e7          	jalr	544(ra) # 80000d4e <release>
}
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	64a2                	ld	s1,8(sp)
    80002b3c:	6105                	addi	sp,sp,32
    80002b3e:	8082                	ret

0000000080002b40 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b40:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b44:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002b46:	0807df63          	bgez	a5,80002be4 <devintr+0xa4>
{
    80002b4a:	1101                	addi	sp,sp,-32
    80002b4c:	ec06                	sd	ra,24(sp)
    80002b4e:	e822                	sd	s0,16(sp)
    80002b50:	e426                	sd	s1,8(sp)
    80002b52:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002b54:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002b58:	46a5                	li	a3,9
    80002b5a:	00d70d63          	beq	a4,a3,80002b74 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002b5e:	577d                	li	a4,-1
    80002b60:	177e                	slli	a4,a4,0x3f
    80002b62:	0705                	addi	a4,a4,1
    return 0;
    80002b64:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b66:	04e78e63          	beq	a5,a4,80002bc2 <devintr+0x82>
  }
}
    80002b6a:	60e2                	ld	ra,24(sp)
    80002b6c:	6442                	ld	s0,16(sp)
    80002b6e:	64a2                	ld	s1,8(sp)
    80002b70:	6105                	addi	sp,sp,32
    80002b72:	8082                	ret
    int irq = plic_claim();
    80002b74:	00003097          	auipc	ra,0x3
    80002b78:	5c4080e7          	jalr	1476(ra) # 80006138 <plic_claim>
    80002b7c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b7e:	47a9                	li	a5,10
    80002b80:	02f50763          	beq	a0,a5,80002bae <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002b84:	4785                	li	a5,1
    80002b86:	02f50963          	beq	a0,a5,80002bb8 <devintr+0x78>
    return 1;
    80002b8a:	4505                	li	a0,1
    } else if(irq){
    80002b8c:	dcf9                	beqz	s1,80002b6a <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b8e:	85a6                	mv	a1,s1
    80002b90:	00006517          	auipc	a0,0x6
    80002b94:	89850513          	addi	a0,a0,-1896 # 80008428 <states.0+0x38>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	a00080e7          	jalr	-1536(ra) # 80000598 <printf>
      plic_complete(irq);
    80002ba0:	8526                	mv	a0,s1
    80002ba2:	00003097          	auipc	ra,0x3
    80002ba6:	5ba080e7          	jalr	1466(ra) # 8000615c <plic_complete>
    return 1;
    80002baa:	4505                	li	a0,1
    80002bac:	bf7d                	j	80002b6a <devintr+0x2a>
      uartintr();
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	df8080e7          	jalr	-520(ra) # 800009a6 <uartintr>
    if(irq)
    80002bb6:	b7ed                	j	80002ba0 <devintr+0x60>
      virtio_disk_intr();
    80002bb8:	00004097          	auipc	ra,0x4
    80002bbc:	a6a080e7          	jalr	-1430(ra) # 80006622 <virtio_disk_intr>
    if(irq)
    80002bc0:	b7c5                	j	80002ba0 <devintr+0x60>
    if(cpuid() == 0){
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	f74080e7          	jalr	-140(ra) # 80001b36 <cpuid>
    80002bca:	c901                	beqz	a0,80002bda <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bcc:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002bd0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bd2:	14479073          	csrw	sip,a5
    return 2;
    80002bd6:	4509                	li	a0,2
    80002bd8:	bf49                	j	80002b6a <devintr+0x2a>
      clockintr();
    80002bda:	00000097          	auipc	ra,0x0
    80002bde:	f20080e7          	jalr	-224(ra) # 80002afa <clockintr>
    80002be2:	b7ed                	j	80002bcc <devintr+0x8c>
}
    80002be4:	8082                	ret

0000000080002be6 <usertrap>:
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	e04a                	sd	s2,0(sp)
    80002bf0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bf6:	1007f793          	andi	a5,a5,256
    80002bfa:	e3b1                	bnez	a5,80002c3e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bfc:	00003797          	auipc	a5,0x3
    80002c00:	43478793          	addi	a5,a5,1076 # 80006030 <kernelvec>
    80002c04:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c08:	fffff097          	auipc	ra,0xfffff
    80002c0c:	f5a080e7          	jalr	-166(ra) # 80001b62 <myproc>
    80002c10:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c12:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c14:	14102773          	csrr	a4,sepc
    80002c18:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c1a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c1e:	47a1                	li	a5,8
    80002c20:	02f70763          	beq	a4,a5,80002c4e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c24:	00000097          	auipc	ra,0x0
    80002c28:	f1c080e7          	jalr	-228(ra) # 80002b40 <devintr>
    80002c2c:	892a                	mv	s2,a0
    80002c2e:	c151                	beqz	a0,80002cb2 <usertrap+0xcc>
  if(killed(p))
    80002c30:	8526                	mv	a0,s1
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	940080e7          	jalr	-1728(ra) # 80002572 <killed>
    80002c3a:	c929                	beqz	a0,80002c8c <usertrap+0xa6>
    80002c3c:	a099                	j	80002c82 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002c3e:	00006517          	auipc	a0,0x6
    80002c42:	80a50513          	addi	a0,a0,-2038 # 80008448 <states.0+0x58>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	8f6080e7          	jalr	-1802(ra) # 8000053c <panic>
    if(killed(p))
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	924080e7          	jalr	-1756(ra) # 80002572 <killed>
    80002c56:	e921                	bnez	a0,80002ca6 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002c58:	6cb8                	ld	a4,88(s1)
    80002c5a:	6f1c                	ld	a5,24(a4)
    80002c5c:	0791                	addi	a5,a5,4
    80002c5e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c68:	10079073          	csrw	sstatus,a5
    syscall();
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	2d4080e7          	jalr	724(ra) # 80002f40 <syscall>
  if(killed(p))
    80002c74:	8526                	mv	a0,s1
    80002c76:	00000097          	auipc	ra,0x0
    80002c7a:	8fc080e7          	jalr	-1796(ra) # 80002572 <killed>
    80002c7e:	c911                	beqz	a0,80002c92 <usertrap+0xac>
    80002c80:	4901                	li	s2,0
    exit(-1);
    80002c82:	557d                	li	a0,-1
    80002c84:	fffff097          	auipc	ra,0xfffff
    80002c88:	77a080e7          	jalr	1914(ra) # 800023fe <exit>
  if(which_dev == 2)
    80002c8c:	4789                	li	a5,2
    80002c8e:	04f90f63          	beq	s2,a5,80002cec <usertrap+0x106>
  usertrapret();
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	dd2080e7          	jalr	-558(ra) # 80002a64 <usertrapret>
}
    80002c9a:	60e2                	ld	ra,24(sp)
    80002c9c:	6442                	ld	s0,16(sp)
    80002c9e:	64a2                	ld	s1,8(sp)
    80002ca0:	6902                	ld	s2,0(sp)
    80002ca2:	6105                	addi	sp,sp,32
    80002ca4:	8082                	ret
      exit(-1);
    80002ca6:	557d                	li	a0,-1
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	756080e7          	jalr	1878(ra) # 800023fe <exit>
    80002cb0:	b765                	j	80002c58 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cb2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cb6:	5890                	lw	a2,48(s1)
    80002cb8:	00005517          	auipc	a0,0x5
    80002cbc:	7b050513          	addi	a0,a0,1968 # 80008468 <states.0+0x78>
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	8d8080e7          	jalr	-1832(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ccc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cd0:	00005517          	auipc	a0,0x5
    80002cd4:	7c850513          	addi	a0,a0,1992 # 80008498 <states.0+0xa8>
    80002cd8:	ffffe097          	auipc	ra,0xffffe
    80002cdc:	8c0080e7          	jalr	-1856(ra) # 80000598 <printf>
    setkilled(p);
    80002ce0:	8526                	mv	a0,s1
    80002ce2:	00000097          	auipc	ra,0x0
    80002ce6:	864080e7          	jalr	-1948(ra) # 80002546 <setkilled>
    80002cea:	b769                	j	80002c74 <usertrap+0x8e>
    yield();
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	5a2080e7          	jalr	1442(ra) # 8000228e <yield>
    80002cf4:	bf79                	j	80002c92 <usertrap+0xac>

0000000080002cf6 <kerneltrap>:
{
    80002cf6:	7179                	addi	sp,sp,-48
    80002cf8:	f406                	sd	ra,40(sp)
    80002cfa:	f022                	sd	s0,32(sp)
    80002cfc:	ec26                	sd	s1,24(sp)
    80002cfe:	e84a                	sd	s2,16(sp)
    80002d00:	e44e                	sd	s3,8(sp)
    80002d02:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d04:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d08:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d0c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d10:	1004f793          	andi	a5,s1,256
    80002d14:	cb85                	beqz	a5,80002d44 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d1a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d1c:	ef85                	bnez	a5,80002d54 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	e22080e7          	jalr	-478(ra) # 80002b40 <devintr>
    80002d26:	cd1d                	beqz	a0,80002d64 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d28:	4789                	li	a5,2
    80002d2a:	06f50a63          	beq	a0,a5,80002d9e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d2e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d32:	10049073          	csrw	sstatus,s1
}
    80002d36:	70a2                	ld	ra,40(sp)
    80002d38:	7402                	ld	s0,32(sp)
    80002d3a:	64e2                	ld	s1,24(sp)
    80002d3c:	6942                	ld	s2,16(sp)
    80002d3e:	69a2                	ld	s3,8(sp)
    80002d40:	6145                	addi	sp,sp,48
    80002d42:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d44:	00005517          	auipc	a0,0x5
    80002d48:	77450513          	addi	a0,a0,1908 # 800084b8 <states.0+0xc8>
    80002d4c:	ffffd097          	auipc	ra,0xffffd
    80002d50:	7f0080e7          	jalr	2032(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002d54:	00005517          	auipc	a0,0x5
    80002d58:	78c50513          	addi	a0,a0,1932 # 800084e0 <states.0+0xf0>
    80002d5c:	ffffd097          	auipc	ra,0xffffd
    80002d60:	7e0080e7          	jalr	2016(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002d64:	85ce                	mv	a1,s3
    80002d66:	00005517          	auipc	a0,0x5
    80002d6a:	79a50513          	addi	a0,a0,1946 # 80008500 <states.0+0x110>
    80002d6e:	ffffe097          	auipc	ra,0xffffe
    80002d72:	82a080e7          	jalr	-2006(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d76:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d7a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d7e:	00005517          	auipc	a0,0x5
    80002d82:	79250513          	addi	a0,a0,1938 # 80008510 <states.0+0x120>
    80002d86:	ffffe097          	auipc	ra,0xffffe
    80002d8a:	812080e7          	jalr	-2030(ra) # 80000598 <printf>
    panic("kerneltrap");
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	79a50513          	addi	a0,a0,1946 # 80008528 <states.0+0x138>
    80002d96:	ffffd097          	auipc	ra,0xffffd
    80002d9a:	7a6080e7          	jalr	1958(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	dc4080e7          	jalr	-572(ra) # 80001b62 <myproc>
    80002da6:	d541                	beqz	a0,80002d2e <kerneltrap+0x38>
    80002da8:	fffff097          	auipc	ra,0xfffff
    80002dac:	dba080e7          	jalr	-582(ra) # 80001b62 <myproc>
    80002db0:	4d18                	lw	a4,24(a0)
    80002db2:	4791                	li	a5,4
    80002db4:	f6f71de3          	bne	a4,a5,80002d2e <kerneltrap+0x38>
    yield();
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	4d6080e7          	jalr	1238(ra) # 8000228e <yield>
    80002dc0:	b7bd                	j	80002d2e <kerneltrap+0x38>

0000000080002dc2 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002dc2:	1101                	addi	sp,sp,-32
    80002dc4:	ec06                	sd	ra,24(sp)
    80002dc6:	e822                	sd	s0,16(sp)
    80002dc8:	e426                	sd	s1,8(sp)
    80002dca:	1000                	addi	s0,sp,32
    80002dcc:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002dce:	fffff097          	auipc	ra,0xfffff
    80002dd2:	d94080e7          	jalr	-620(ra) # 80001b62 <myproc>
    switch (n)
    80002dd6:	4795                	li	a5,5
    80002dd8:	0497e163          	bltu	a5,s1,80002e1a <argraw+0x58>
    80002ddc:	048a                	slli	s1,s1,0x2
    80002dde:	00005717          	auipc	a4,0x5
    80002de2:	78270713          	addi	a4,a4,1922 # 80008560 <states.0+0x170>
    80002de6:	94ba                	add	s1,s1,a4
    80002de8:	409c                	lw	a5,0(s1)
    80002dea:	97ba                	add	a5,a5,a4
    80002dec:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002dee:	6d3c                	ld	a5,88(a0)
    80002df0:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret
        return p->trapframe->a1;
    80002dfc:	6d3c                	ld	a5,88(a0)
    80002dfe:	7fa8                	ld	a0,120(a5)
    80002e00:	bfcd                	j	80002df2 <argraw+0x30>
        return p->trapframe->a2;
    80002e02:	6d3c                	ld	a5,88(a0)
    80002e04:	63c8                	ld	a0,128(a5)
    80002e06:	b7f5                	j	80002df2 <argraw+0x30>
        return p->trapframe->a3;
    80002e08:	6d3c                	ld	a5,88(a0)
    80002e0a:	67c8                	ld	a0,136(a5)
    80002e0c:	b7dd                	j	80002df2 <argraw+0x30>
        return p->trapframe->a4;
    80002e0e:	6d3c                	ld	a5,88(a0)
    80002e10:	6bc8                	ld	a0,144(a5)
    80002e12:	b7c5                	j	80002df2 <argraw+0x30>
        return p->trapframe->a5;
    80002e14:	6d3c                	ld	a5,88(a0)
    80002e16:	6fc8                	ld	a0,152(a5)
    80002e18:	bfe9                	j	80002df2 <argraw+0x30>
    panic("argraw");
    80002e1a:	00005517          	auipc	a0,0x5
    80002e1e:	71e50513          	addi	a0,a0,1822 # 80008538 <states.0+0x148>
    80002e22:	ffffd097          	auipc	ra,0xffffd
    80002e26:	71a080e7          	jalr	1818(ra) # 8000053c <panic>

0000000080002e2a <fetchaddr>:
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	e04a                	sd	s2,0(sp)
    80002e34:	1000                	addi	s0,sp,32
    80002e36:	84aa                	mv	s1,a0
    80002e38:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002e3a:	fffff097          	auipc	ra,0xfffff
    80002e3e:	d28080e7          	jalr	-728(ra) # 80001b62 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e42:	653c                	ld	a5,72(a0)
    80002e44:	02f4f863          	bgeu	s1,a5,80002e74 <fetchaddr+0x4a>
    80002e48:	00848713          	addi	a4,s1,8
    80002e4c:	02e7e663          	bltu	a5,a4,80002e78 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e50:	46a1                	li	a3,8
    80002e52:	8626                	mv	a2,s1
    80002e54:	85ca                	mv	a1,s2
    80002e56:	6928                	ld	a0,80(a0)
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	962080e7          	jalr	-1694(ra) # 800017ba <copyin>
    80002e60:	00a03533          	snez	a0,a0
    80002e64:	40a00533          	neg	a0,a0
}
    80002e68:	60e2                	ld	ra,24(sp)
    80002e6a:	6442                	ld	s0,16(sp)
    80002e6c:	64a2                	ld	s1,8(sp)
    80002e6e:	6902                	ld	s2,0(sp)
    80002e70:	6105                	addi	sp,sp,32
    80002e72:	8082                	ret
        return -1;
    80002e74:	557d                	li	a0,-1
    80002e76:	bfcd                	j	80002e68 <fetchaddr+0x3e>
    80002e78:	557d                	li	a0,-1
    80002e7a:	b7fd                	j	80002e68 <fetchaddr+0x3e>

0000000080002e7c <fetchstr>:
{
    80002e7c:	7179                	addi	sp,sp,-48
    80002e7e:	f406                	sd	ra,40(sp)
    80002e80:	f022                	sd	s0,32(sp)
    80002e82:	ec26                	sd	s1,24(sp)
    80002e84:	e84a                	sd	s2,16(sp)
    80002e86:	e44e                	sd	s3,8(sp)
    80002e88:	1800                	addi	s0,sp,48
    80002e8a:	892a                	mv	s2,a0
    80002e8c:	84ae                	mv	s1,a1
    80002e8e:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	cd2080e7          	jalr	-814(ra) # 80001b62 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e98:	86ce                	mv	a3,s3
    80002e9a:	864a                	mv	a2,s2
    80002e9c:	85a6                	mv	a1,s1
    80002e9e:	6928                	ld	a0,80(a0)
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	9a8080e7          	jalr	-1624(ra) # 80001848 <copyinstr>
    80002ea8:	00054e63          	bltz	a0,80002ec4 <fetchstr+0x48>
    return strlen(buf);
    80002eac:	8526                	mv	a0,s1
    80002eae:	ffffe097          	auipc	ra,0xffffe
    80002eb2:	062080e7          	jalr	98(ra) # 80000f10 <strlen>
}
    80002eb6:	70a2                	ld	ra,40(sp)
    80002eb8:	7402                	ld	s0,32(sp)
    80002eba:	64e2                	ld	s1,24(sp)
    80002ebc:	6942                	ld	s2,16(sp)
    80002ebe:	69a2                	ld	s3,8(sp)
    80002ec0:	6145                	addi	sp,sp,48
    80002ec2:	8082                	ret
        return -1;
    80002ec4:	557d                	li	a0,-1
    80002ec6:	bfc5                	j	80002eb6 <fetchstr+0x3a>

0000000080002ec8 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	e426                	sd	s1,8(sp)
    80002ed0:	1000                	addi	s0,sp,32
    80002ed2:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002ed4:	00000097          	auipc	ra,0x0
    80002ed8:	eee080e7          	jalr	-274(ra) # 80002dc2 <argraw>
    80002edc:	c088                	sw	a0,0(s1)
}
    80002ede:	60e2                	ld	ra,24(sp)
    80002ee0:	6442                	ld	s0,16(sp)
    80002ee2:	64a2                	ld	s1,8(sp)
    80002ee4:	6105                	addi	sp,sp,32
    80002ee6:	8082                	ret

0000000080002ee8 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	1000                	addi	s0,sp,32
    80002ef2:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002ef4:	00000097          	auipc	ra,0x0
    80002ef8:	ece080e7          	jalr	-306(ra) # 80002dc2 <argraw>
    80002efc:	e088                	sd	a0,0(s1)
}
    80002efe:	60e2                	ld	ra,24(sp)
    80002f00:	6442                	ld	s0,16(sp)
    80002f02:	64a2                	ld	s1,8(sp)
    80002f04:	6105                	addi	sp,sp,32
    80002f06:	8082                	ret

0000000080002f08 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f08:	7179                	addi	sp,sp,-48
    80002f0a:	f406                	sd	ra,40(sp)
    80002f0c:	f022                	sd	s0,32(sp)
    80002f0e:	ec26                	sd	s1,24(sp)
    80002f10:	e84a                	sd	s2,16(sp)
    80002f12:	1800                	addi	s0,sp,48
    80002f14:	84ae                	mv	s1,a1
    80002f16:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002f18:	fd840593          	addi	a1,s0,-40
    80002f1c:	00000097          	auipc	ra,0x0
    80002f20:	fcc080e7          	jalr	-52(ra) # 80002ee8 <argaddr>
    return fetchstr(addr, buf, max);
    80002f24:	864a                	mv	a2,s2
    80002f26:	85a6                	mv	a1,s1
    80002f28:	fd843503          	ld	a0,-40(s0)
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	f50080e7          	jalr	-176(ra) # 80002e7c <fetchstr>
}
    80002f34:	70a2                	ld	ra,40(sp)
    80002f36:	7402                	ld	s0,32(sp)
    80002f38:	64e2                	ld	s1,24(sp)
    80002f3a:	6942                	ld	s2,16(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret

0000000080002f40 <syscall>:
    [SYS_va2pa] sys_va2pa,
    [SYS_vatopa] sys_vatopa,
};

void syscall(void)
{
    80002f40:	1101                	addi	sp,sp,-32
    80002f42:	ec06                	sd	ra,24(sp)
    80002f44:	e822                	sd	s0,16(sp)
    80002f46:	e426                	sd	s1,8(sp)
    80002f48:	e04a                	sd	s2,0(sp)
    80002f4a:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	c16080e7          	jalr	-1002(ra) # 80001b62 <myproc>
    80002f54:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80002f56:	05853903          	ld	s2,88(a0)
    80002f5a:	0a893783          	ld	a5,168(s2)
    80002f5e:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002f62:	37fd                	addiw	a5,a5,-1
    80002f64:	4769                	li	a4,26
    80002f66:	00f76f63          	bltu	a4,a5,80002f84 <syscall+0x44>
    80002f6a:	00369713          	slli	a4,a3,0x3
    80002f6e:	00005797          	auipc	a5,0x5
    80002f72:	60a78793          	addi	a5,a5,1546 # 80008578 <syscalls>
    80002f76:	97ba                	add	a5,a5,a4
    80002f78:	639c                	ld	a5,0(a5)
    80002f7a:	c789                	beqz	a5,80002f84 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80002f7c:	9782                	jalr	a5
    80002f7e:	06a93823          	sd	a0,112(s2)
    80002f82:	a839                	j	80002fa0 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80002f84:	15848613          	addi	a2,s1,344
    80002f88:	588c                	lw	a1,48(s1)
    80002f8a:	00005517          	auipc	a0,0x5
    80002f8e:	5b650513          	addi	a0,a0,1462 # 80008540 <states.0+0x150>
    80002f92:	ffffd097          	auipc	ra,0xffffd
    80002f96:	606080e7          	jalr	1542(ra) # 80000598 <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80002f9a:	6cbc                	ld	a5,88(s1)
    80002f9c:	577d                	li	a4,-1
    80002f9e:	fbb8                	sd	a4,112(a5)
    }
}
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	64a2                	ld	s1,8(sp)
    80002fa6:	6902                	ld	s2,0(sp)
    80002fa8:	6105                	addi	sp,sp,32
    80002faa:	8082                	ret

0000000080002fac <sys_exit>:
extern uint64 FREE_PAGES; // kalloc.c keeps track of those
extern struct proc proc[];

uint64
sys_exit(void)
{
    80002fac:	1101                	addi	sp,sp,-32
    80002fae:	ec06                	sd	ra,24(sp)
    80002fb0:	e822                	sd	s0,16(sp)
    80002fb2:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80002fb4:	fec40593          	addi	a1,s0,-20
    80002fb8:	4501                	li	a0,0
    80002fba:	00000097          	auipc	ra,0x0
    80002fbe:	f0e080e7          	jalr	-242(ra) # 80002ec8 <argint>
    exit(n);
    80002fc2:	fec42503          	lw	a0,-20(s0)
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	438080e7          	jalr	1080(ra) # 800023fe <exit>
    return 0; // not reached
}
    80002fce:	4501                	li	a0,0
    80002fd0:	60e2                	ld	ra,24(sp)
    80002fd2:	6442                	ld	s0,16(sp)
    80002fd4:	6105                	addi	sp,sp,32
    80002fd6:	8082                	ret

0000000080002fd8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fd8:	1141                	addi	sp,sp,-16
    80002fda:	e406                	sd	ra,8(sp)
    80002fdc:	e022                	sd	s0,0(sp)
    80002fde:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80002fe0:	fffff097          	auipc	ra,0xfffff
    80002fe4:	b82080e7          	jalr	-1150(ra) # 80001b62 <myproc>
}
    80002fe8:	5908                	lw	a0,48(a0)
    80002fea:	60a2                	ld	ra,8(sp)
    80002fec:	6402                	ld	s0,0(sp)
    80002fee:	0141                	addi	sp,sp,16
    80002ff0:	8082                	ret

0000000080002ff2 <sys_fork>:

uint64
sys_fork(void)
{
    80002ff2:	1141                	addi	sp,sp,-16
    80002ff4:	e406                	sd	ra,8(sp)
    80002ff6:	e022                	sd	s0,0(sp)
    80002ff8:	0800                	addi	s0,sp,16
    return fork();
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	06e080e7          	jalr	110(ra) # 80002068 <fork>
}
    80003002:	60a2                	ld	ra,8(sp)
    80003004:	6402                	ld	s0,0(sp)
    80003006:	0141                	addi	sp,sp,16
    80003008:	8082                	ret

000000008000300a <sys_wait>:

uint64
sys_wait(void)
{
    8000300a:	1101                	addi	sp,sp,-32
    8000300c:	ec06                	sd	ra,24(sp)
    8000300e:	e822                	sd	s0,16(sp)
    80003010:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003012:	fe840593          	addi	a1,s0,-24
    80003016:	4501                	li	a0,0
    80003018:	00000097          	auipc	ra,0x0
    8000301c:	ed0080e7          	jalr	-304(ra) # 80002ee8 <argaddr>
    return wait(p);
    80003020:	fe843503          	ld	a0,-24(s0)
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	580080e7          	jalr	1408(ra) # 800025a4 <wait>
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	6105                	addi	sp,sp,32
    80003032:	8082                	ret

0000000080003034 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003034:	7179                	addi	sp,sp,-48
    80003036:	f406                	sd	ra,40(sp)
    80003038:	f022                	sd	s0,32(sp)
    8000303a:	ec26                	sd	s1,24(sp)
    8000303c:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    8000303e:	fdc40593          	addi	a1,s0,-36
    80003042:	4501                	li	a0,0
    80003044:	00000097          	auipc	ra,0x0
    80003048:	e84080e7          	jalr	-380(ra) # 80002ec8 <argint>
    addr = myproc()->sz;
    8000304c:	fffff097          	auipc	ra,0xfffff
    80003050:	b16080e7          	jalr	-1258(ra) # 80001b62 <myproc>
    80003054:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003056:	fdc42503          	lw	a0,-36(s0)
    8000305a:	fffff097          	auipc	ra,0xfffff
    8000305e:	e62080e7          	jalr	-414(ra) # 80001ebc <growproc>
    80003062:	00054863          	bltz	a0,80003072 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003066:	8526                	mv	a0,s1
    80003068:	70a2                	ld	ra,40(sp)
    8000306a:	7402                	ld	s0,32(sp)
    8000306c:	64e2                	ld	s1,24(sp)
    8000306e:	6145                	addi	sp,sp,48
    80003070:	8082                	ret
        return -1;
    80003072:	54fd                	li	s1,-1
    80003074:	bfcd                	j	80003066 <sys_sbrk+0x32>

0000000080003076 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003076:	7139                	addi	sp,sp,-64
    80003078:	fc06                	sd	ra,56(sp)
    8000307a:	f822                	sd	s0,48(sp)
    8000307c:	f426                	sd	s1,40(sp)
    8000307e:	f04a                	sd	s2,32(sp)
    80003080:	ec4e                	sd	s3,24(sp)
    80003082:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003084:	fcc40593          	addi	a1,s0,-52
    80003088:	4501                	li	a0,0
    8000308a:	00000097          	auipc	ra,0x0
    8000308e:	e3e080e7          	jalr	-450(ra) # 80002ec8 <argint>
    acquire(&tickslock);
    80003092:	00014517          	auipc	a0,0x14
    80003096:	a7e50513          	addi	a0,a0,-1410 # 80016b10 <tickslock>
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	c00080e7          	jalr	-1024(ra) # 80000c9a <acquire>
    ticks0 = ticks;
    800030a2:	00006917          	auipc	s2,0x6
    800030a6:	9ce92903          	lw	s2,-1586(s2) # 80008a70 <ticks>
    while (ticks - ticks0 < n)
    800030aa:	fcc42783          	lw	a5,-52(s0)
    800030ae:	cf9d                	beqz	a5,800030ec <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800030b0:	00014997          	auipc	s3,0x14
    800030b4:	a6098993          	addi	s3,s3,-1440 # 80016b10 <tickslock>
    800030b8:	00006497          	auipc	s1,0x6
    800030bc:	9b848493          	addi	s1,s1,-1608 # 80008a70 <ticks>
        if (killed(myproc()))
    800030c0:	fffff097          	auipc	ra,0xfffff
    800030c4:	aa2080e7          	jalr	-1374(ra) # 80001b62 <myproc>
    800030c8:	fffff097          	auipc	ra,0xfffff
    800030cc:	4aa080e7          	jalr	1194(ra) # 80002572 <killed>
    800030d0:	ed15                	bnez	a0,8000310c <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    800030d2:	85ce                	mv	a1,s3
    800030d4:	8526                	mv	a0,s1
    800030d6:	fffff097          	auipc	ra,0xfffff
    800030da:	1f4080e7          	jalr	500(ra) # 800022ca <sleep>
    while (ticks - ticks0 < n)
    800030de:	409c                	lw	a5,0(s1)
    800030e0:	412787bb          	subw	a5,a5,s2
    800030e4:	fcc42703          	lw	a4,-52(s0)
    800030e8:	fce7ece3          	bltu	a5,a4,800030c0 <sys_sleep+0x4a>
    }
    release(&tickslock);
    800030ec:	00014517          	auipc	a0,0x14
    800030f0:	a2450513          	addi	a0,a0,-1500 # 80016b10 <tickslock>
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	c5a080e7          	jalr	-934(ra) # 80000d4e <release>
    return 0;
    800030fc:	4501                	li	a0,0
}
    800030fe:	70e2                	ld	ra,56(sp)
    80003100:	7442                	ld	s0,48(sp)
    80003102:	74a2                	ld	s1,40(sp)
    80003104:	7902                	ld	s2,32(sp)
    80003106:	69e2                	ld	s3,24(sp)
    80003108:	6121                	addi	sp,sp,64
    8000310a:	8082                	ret
            release(&tickslock);
    8000310c:	00014517          	auipc	a0,0x14
    80003110:	a0450513          	addi	a0,a0,-1532 # 80016b10 <tickslock>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	c3a080e7          	jalr	-966(ra) # 80000d4e <release>
            return -1;
    8000311c:	557d                	li	a0,-1
    8000311e:	b7c5                	j	800030fe <sys_sleep+0x88>

0000000080003120 <sys_kill>:

uint64
sys_kill(void)
{
    80003120:	1101                	addi	sp,sp,-32
    80003122:	ec06                	sd	ra,24(sp)
    80003124:	e822                	sd	s0,16(sp)
    80003126:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    80003128:	fec40593          	addi	a1,s0,-20
    8000312c:	4501                	li	a0,0
    8000312e:	00000097          	auipc	ra,0x0
    80003132:	d9a080e7          	jalr	-614(ra) # 80002ec8 <argint>
    return kill(pid);
    80003136:	fec42503          	lw	a0,-20(s0)
    8000313a:	fffff097          	auipc	ra,0xfffff
    8000313e:	39a080e7          	jalr	922(ra) # 800024d4 <kill>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	6105                	addi	sp,sp,32
    80003148:	8082                	ret

000000008000314a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000314a:	1101                	addi	sp,sp,-32
    8000314c:	ec06                	sd	ra,24(sp)
    8000314e:	e822                	sd	s0,16(sp)
    80003150:	e426                	sd	s1,8(sp)
    80003152:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003154:	00014517          	auipc	a0,0x14
    80003158:	9bc50513          	addi	a0,a0,-1604 # 80016b10 <tickslock>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	b3e080e7          	jalr	-1218(ra) # 80000c9a <acquire>
    xticks = ticks;
    80003164:	00006497          	auipc	s1,0x6
    80003168:	90c4a483          	lw	s1,-1780(s1) # 80008a70 <ticks>
    release(&tickslock);
    8000316c:	00014517          	auipc	a0,0x14
    80003170:	9a450513          	addi	a0,a0,-1628 # 80016b10 <tickslock>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	bda080e7          	jalr	-1062(ra) # 80000d4e <release>
    return xticks;
}
    8000317c:	02049513          	slli	a0,s1,0x20
    80003180:	9101                	srli	a0,a0,0x20
    80003182:	60e2                	ld	ra,24(sp)
    80003184:	6442                	ld	s0,16(sp)
    80003186:	64a2                	ld	s1,8(sp)
    80003188:	6105                	addi	sp,sp,32
    8000318a:	8082                	ret

000000008000318c <sys_ps>:

void *
sys_ps(void)
{
    8000318c:	1101                	addi	sp,sp,-32
    8000318e:	ec06                	sd	ra,24(sp)
    80003190:	e822                	sd	s0,16(sp)
    80003192:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003194:	fe042623          	sw	zero,-20(s0)
    80003198:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    8000319c:	fec40593          	addi	a1,s0,-20
    800031a0:	4501                	li	a0,0
    800031a2:	00000097          	auipc	ra,0x0
    800031a6:	d26080e7          	jalr	-730(ra) # 80002ec8 <argint>
    argint(1, &count);
    800031aa:	fe840593          	addi	a1,s0,-24
    800031ae:	4505                	li	a0,1
    800031b0:	00000097          	auipc	ra,0x0
    800031b4:	d18080e7          	jalr	-744(ra) # 80002ec8 <argint>
    return ps((uint8)start, (uint8)count);
    800031b8:	fe844583          	lbu	a1,-24(s0)
    800031bc:	fec44503          	lbu	a0,-20(s0)
    800031c0:	fffff097          	auipc	ra,0xfffff
    800031c4:	d58080e7          	jalr	-680(ra) # 80001f18 <ps>
}
    800031c8:	60e2                	ld	ra,24(sp)
    800031ca:	6442                	ld	s0,16(sp)
    800031cc:	6105                	addi	sp,sp,32
    800031ce:	8082                	ret

00000000800031d0 <sys_schedls>:

uint64 sys_schedls(void)
{
    800031d0:	1141                	addi	sp,sp,-16
    800031d2:	e406                	sd	ra,8(sp)
    800031d4:	e022                	sd	s0,0(sp)
    800031d6:	0800                	addi	s0,sp,16
    schedls();
    800031d8:	fffff097          	auipc	ra,0xfffff
    800031dc:	656080e7          	jalr	1622(ra) # 8000282e <schedls>
    return 0;
}
    800031e0:	4501                	li	a0,0
    800031e2:	60a2                	ld	ra,8(sp)
    800031e4:	6402                	ld	s0,0(sp)
    800031e6:	0141                	addi	sp,sp,16
    800031e8:	8082                	ret

00000000800031ea <sys_schedset>:

uint64 sys_schedset(void)
{
    800031ea:	1101                	addi	sp,sp,-32
    800031ec:	ec06                	sd	ra,24(sp)
    800031ee:	e822                	sd	s0,16(sp)
    800031f0:	1000                	addi	s0,sp,32
    int id = 0;
    800031f2:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800031f6:	fec40593          	addi	a1,s0,-20
    800031fa:	4501                	li	a0,0
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	ccc080e7          	jalr	-820(ra) # 80002ec8 <argint>
    schedset(id - 1);
    80003204:	fec42503          	lw	a0,-20(s0)
    80003208:	357d                	addiw	a0,a0,-1
    8000320a:	fffff097          	auipc	ra,0xfffff
    8000320e:	6ba080e7          	jalr	1722(ra) # 800028c4 <schedset>
    return 0;
}
    80003212:	4501                	li	a0,0
    80003214:	60e2                	ld	ra,24(sp)
    80003216:	6442                	ld	s0,16(sp)
    80003218:	6105                	addi	sp,sp,32
    8000321a:	8082                	ret

000000008000321c <sys_va2pa>:

uint64 sys_va2pa(void)
{
    8000321c:	7179                	addi	sp,sp,-48
    8000321e:	f406                	sd	ra,40(sp)
    80003220:	f022                	sd	s0,32(sp)
    80003222:	ec26                	sd	s1,24(sp)
    80003224:	e84a                	sd	s2,16(sp)
    80003226:	1800                	addi	s0,sp,48
    int pid = 0;
    80003228:	fc042e23          	sw	zero,-36(s0)
    uint64 va = 0;
    8000322c:	fc043823          	sd	zero,-48(s0)
    
    argint(0, &pid);
    80003230:	fdc40593          	addi	a1,s0,-36
    80003234:	4501                	li	a0,0
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	c92080e7          	jalr	-878(ra) # 80002ec8 <argint>
    argaddr(1, &va);
    8000323e:	fd040593          	addi	a1,s0,-48
    80003242:	4505                	li	a0,1
    80003244:	00000097          	auipc	ra,0x0
    80003248:	ca4080e7          	jalr	-860(ra) # 80002ee8 <argaddr>

    struct proc *p;
    int pidExists = 0;

    if (pid != 0) {
    8000324c:	fdc42783          	lw	a5,-36(s0)
    80003250:	c3a5                	beqz	a5,800032b0 <sys_va2pa+0x94>
        for (p = proc; p < &proc[NPROC]; p++) {
    80003252:	0000e497          	auipc	s1,0xe
    80003256:	ebe48493          	addi	s1,s1,-322 # 80011110 <proc>
    8000325a:	00014917          	auipc	s2,0x14
    8000325e:	8b690913          	addi	s2,s2,-1866 # 80016b10 <tickslock>
            acquire(&p->lock);
    80003262:	8526                	mv	a0,s1
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	a36080e7          	jalr	-1482(ra) # 80000c9a <acquire>
            if (p->pid == pid) {
    8000326c:	5898                	lw	a4,48(s1)
    8000326e:	fdc42783          	lw	a5,-36(s0)
    80003272:	00f70d63          	beq	a4,a5,8000328c <sys_va2pa+0x70>
                release(&p->lock);
                pidExists = 1;
                break;
            }
            release(&p->lock);
    80003276:	8526                	mv	a0,s1
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	ad6080e7          	jalr	-1322(ra) # 80000d4e <release>
        for (p = proc; p < &proc[NPROC]; p++) {
    80003280:	16848493          	addi	s1,s1,360
    80003284:	fd249fe3          	bne	s1,s2,80003262 <sys_va2pa+0x46>
        }
        if (pidExists == 0) {
            return 0;
    80003288:	4501                	li	a0,0
    8000328a:	a829                	j	800032a4 <sys_va2pa+0x88>
                release(&p->lock);
    8000328c:	8526                	mv	a0,s1
    8000328e:	ffffe097          	auipc	ra,0xffffe
    80003292:	ac0080e7          	jalr	-1344(ra) # 80000d4e <release>
        p = myproc();
    }


    pagetable_t pagetable = p->pagetable;
    uint64 pa = walkaddr(pagetable, va);
    80003296:	fd043583          	ld	a1,-48(s0)
    8000329a:	68a8                	ld	a0,80(s1)
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	e82080e7          	jalr	-382(ra) # 8000111e <walkaddr>
    } else {
        return pa;
    }

    return 0;
}
    800032a4:	70a2                	ld	ra,40(sp)
    800032a6:	7402                	ld	s0,32(sp)
    800032a8:	64e2                	ld	s1,24(sp)
    800032aa:	6942                	ld	s2,16(sp)
    800032ac:	6145                	addi	sp,sp,48
    800032ae:	8082                	ret
        printf("No pid supplied pid\n");
    800032b0:	00005517          	auipc	a0,0x5
    800032b4:	3a850513          	addi	a0,a0,936 # 80008658 <syscalls+0xe0>
    800032b8:	ffffd097          	auipc	ra,0xffffd
    800032bc:	2e0080e7          	jalr	736(ra) # 80000598 <printf>
        p = myproc();
    800032c0:	fffff097          	auipc	ra,0xfffff
    800032c4:	8a2080e7          	jalr	-1886(ra) # 80001b62 <myproc>
    800032c8:	84aa                	mv	s1,a0
    800032ca:	b7f1                	j	80003296 <sys_va2pa+0x7a>

00000000800032cc <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    800032cc:	1141                	addi	sp,sp,-16
    800032ce:	e406                	sd	ra,8(sp)
    800032d0:	e022                	sd	s0,0(sp)
    800032d2:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    800032d4:	00005597          	auipc	a1,0x5
    800032d8:	7745b583          	ld	a1,1908(a1) # 80008a48 <FREE_PAGES>
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	27c50513          	addi	a0,a0,636 # 80008558 <states.0+0x168>
    800032e4:	ffffd097          	auipc	ra,0xffffd
    800032e8:	2b4080e7          	jalr	692(ra) # 80000598 <printf>
    return 0;
}
    800032ec:	4501                	li	a0,0
    800032ee:	60a2                	ld	ra,8(sp)
    800032f0:	6402                	ld	s0,0(sp)
    800032f2:	0141                	addi	sp,sp,16
    800032f4:	8082                	ret

00000000800032f6 <sys_vatopa>:

int sys_vatopa(void)
{
    800032f6:	1141                	addi	sp,sp,-16
    800032f8:	e422                	sd	s0,8(sp)
    800032fa:	0800                	addi	s0,sp,16

    return 1;
    800032fc:	4505                	li	a0,1
    800032fe:	6422                	ld	s0,8(sp)
    80003300:	0141                	addi	sp,sp,16
    80003302:	8082                	ret

0000000080003304 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003304:	7179                	addi	sp,sp,-48
    80003306:	f406                	sd	ra,40(sp)
    80003308:	f022                	sd	s0,32(sp)
    8000330a:	ec26                	sd	s1,24(sp)
    8000330c:	e84a                	sd	s2,16(sp)
    8000330e:	e44e                	sd	s3,8(sp)
    80003310:	e052                	sd	s4,0(sp)
    80003312:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003314:	00005597          	auipc	a1,0x5
    80003318:	35c58593          	addi	a1,a1,860 # 80008670 <syscalls+0xf8>
    8000331c:	00014517          	auipc	a0,0x14
    80003320:	80c50513          	addi	a0,a0,-2036 # 80016b28 <bcache>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	8e6080e7          	jalr	-1818(ra) # 80000c0a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000332c:	0001b797          	auipc	a5,0x1b
    80003330:	7fc78793          	addi	a5,a5,2044 # 8001eb28 <bcache+0x8000>
    80003334:	0001c717          	auipc	a4,0x1c
    80003338:	a5c70713          	addi	a4,a4,-1444 # 8001ed90 <bcache+0x8268>
    8000333c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003340:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003344:	00013497          	auipc	s1,0x13
    80003348:	7fc48493          	addi	s1,s1,2044 # 80016b40 <bcache+0x18>
    b->next = bcache.head.next;
    8000334c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000334e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003350:	00005a17          	auipc	s4,0x5
    80003354:	328a0a13          	addi	s4,s4,808 # 80008678 <syscalls+0x100>
    b->next = bcache.head.next;
    80003358:	2b893783          	ld	a5,696(s2)
    8000335c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000335e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003362:	85d2                	mv	a1,s4
    80003364:	01048513          	addi	a0,s1,16
    80003368:	00001097          	auipc	ra,0x1
    8000336c:	496080e7          	jalr	1174(ra) # 800047fe <initsleeplock>
    bcache.head.next->prev = b;
    80003370:	2b893783          	ld	a5,696(s2)
    80003374:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003376:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000337a:	45848493          	addi	s1,s1,1112
    8000337e:	fd349de3          	bne	s1,s3,80003358 <binit+0x54>
  }
}
    80003382:	70a2                	ld	ra,40(sp)
    80003384:	7402                	ld	s0,32(sp)
    80003386:	64e2                	ld	s1,24(sp)
    80003388:	6942                	ld	s2,16(sp)
    8000338a:	69a2                	ld	s3,8(sp)
    8000338c:	6a02                	ld	s4,0(sp)
    8000338e:	6145                	addi	sp,sp,48
    80003390:	8082                	ret

0000000080003392 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003392:	7179                	addi	sp,sp,-48
    80003394:	f406                	sd	ra,40(sp)
    80003396:	f022                	sd	s0,32(sp)
    80003398:	ec26                	sd	s1,24(sp)
    8000339a:	e84a                	sd	s2,16(sp)
    8000339c:	e44e                	sd	s3,8(sp)
    8000339e:	1800                	addi	s0,sp,48
    800033a0:	892a                	mv	s2,a0
    800033a2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033a4:	00013517          	auipc	a0,0x13
    800033a8:	78450513          	addi	a0,a0,1924 # 80016b28 <bcache>
    800033ac:	ffffe097          	auipc	ra,0xffffe
    800033b0:	8ee080e7          	jalr	-1810(ra) # 80000c9a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033b4:	0001c497          	auipc	s1,0x1c
    800033b8:	a2c4b483          	ld	s1,-1492(s1) # 8001ede0 <bcache+0x82b8>
    800033bc:	0001c797          	auipc	a5,0x1c
    800033c0:	9d478793          	addi	a5,a5,-1580 # 8001ed90 <bcache+0x8268>
    800033c4:	02f48f63          	beq	s1,a5,80003402 <bread+0x70>
    800033c8:	873e                	mv	a4,a5
    800033ca:	a021                	j	800033d2 <bread+0x40>
    800033cc:	68a4                	ld	s1,80(s1)
    800033ce:	02e48a63          	beq	s1,a4,80003402 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033d2:	449c                	lw	a5,8(s1)
    800033d4:	ff279ce3          	bne	a5,s2,800033cc <bread+0x3a>
    800033d8:	44dc                	lw	a5,12(s1)
    800033da:	ff3799e3          	bne	a5,s3,800033cc <bread+0x3a>
      b->refcnt++;
    800033de:	40bc                	lw	a5,64(s1)
    800033e0:	2785                	addiw	a5,a5,1
    800033e2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033e4:	00013517          	auipc	a0,0x13
    800033e8:	74450513          	addi	a0,a0,1860 # 80016b28 <bcache>
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	962080e7          	jalr	-1694(ra) # 80000d4e <release>
      acquiresleep(&b->lock);
    800033f4:	01048513          	addi	a0,s1,16
    800033f8:	00001097          	auipc	ra,0x1
    800033fc:	440080e7          	jalr	1088(ra) # 80004838 <acquiresleep>
      return b;
    80003400:	a8b9                	j	8000345e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003402:	0001c497          	auipc	s1,0x1c
    80003406:	9d64b483          	ld	s1,-1578(s1) # 8001edd8 <bcache+0x82b0>
    8000340a:	0001c797          	auipc	a5,0x1c
    8000340e:	98678793          	addi	a5,a5,-1658 # 8001ed90 <bcache+0x8268>
    80003412:	00f48863          	beq	s1,a5,80003422 <bread+0x90>
    80003416:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003418:	40bc                	lw	a5,64(s1)
    8000341a:	cf81                	beqz	a5,80003432 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000341c:	64a4                	ld	s1,72(s1)
    8000341e:	fee49de3          	bne	s1,a4,80003418 <bread+0x86>
  panic("bget: no buffers");
    80003422:	00005517          	auipc	a0,0x5
    80003426:	25e50513          	addi	a0,a0,606 # 80008680 <syscalls+0x108>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	112080e7          	jalr	274(ra) # 8000053c <panic>
      b->dev = dev;
    80003432:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003436:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000343a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000343e:	4785                	li	a5,1
    80003440:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003442:	00013517          	auipc	a0,0x13
    80003446:	6e650513          	addi	a0,a0,1766 # 80016b28 <bcache>
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	904080e7          	jalr	-1788(ra) # 80000d4e <release>
      acquiresleep(&b->lock);
    80003452:	01048513          	addi	a0,s1,16
    80003456:	00001097          	auipc	ra,0x1
    8000345a:	3e2080e7          	jalr	994(ra) # 80004838 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000345e:	409c                	lw	a5,0(s1)
    80003460:	cb89                	beqz	a5,80003472 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003462:	8526                	mv	a0,s1
    80003464:	70a2                	ld	ra,40(sp)
    80003466:	7402                	ld	s0,32(sp)
    80003468:	64e2                	ld	s1,24(sp)
    8000346a:	6942                	ld	s2,16(sp)
    8000346c:	69a2                	ld	s3,8(sp)
    8000346e:	6145                	addi	sp,sp,48
    80003470:	8082                	ret
    virtio_disk_rw(b, 0);
    80003472:	4581                	li	a1,0
    80003474:	8526                	mv	a0,s1
    80003476:	00003097          	auipc	ra,0x3
    8000347a:	f7c080e7          	jalr	-132(ra) # 800063f2 <virtio_disk_rw>
    b->valid = 1;
    8000347e:	4785                	li	a5,1
    80003480:	c09c                	sw	a5,0(s1)
  return b;
    80003482:	b7c5                	j	80003462 <bread+0xd0>

0000000080003484 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003484:	1101                	addi	sp,sp,-32
    80003486:	ec06                	sd	ra,24(sp)
    80003488:	e822                	sd	s0,16(sp)
    8000348a:	e426                	sd	s1,8(sp)
    8000348c:	1000                	addi	s0,sp,32
    8000348e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003490:	0541                	addi	a0,a0,16
    80003492:	00001097          	auipc	ra,0x1
    80003496:	440080e7          	jalr	1088(ra) # 800048d2 <holdingsleep>
    8000349a:	cd01                	beqz	a0,800034b2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000349c:	4585                	li	a1,1
    8000349e:	8526                	mv	a0,s1
    800034a0:	00003097          	auipc	ra,0x3
    800034a4:	f52080e7          	jalr	-174(ra) # 800063f2 <virtio_disk_rw>
}
    800034a8:	60e2                	ld	ra,24(sp)
    800034aa:	6442                	ld	s0,16(sp)
    800034ac:	64a2                	ld	s1,8(sp)
    800034ae:	6105                	addi	sp,sp,32
    800034b0:	8082                	ret
    panic("bwrite");
    800034b2:	00005517          	auipc	a0,0x5
    800034b6:	1e650513          	addi	a0,a0,486 # 80008698 <syscalls+0x120>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	082080e7          	jalr	130(ra) # 8000053c <panic>

00000000800034c2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034c2:	1101                	addi	sp,sp,-32
    800034c4:	ec06                	sd	ra,24(sp)
    800034c6:	e822                	sd	s0,16(sp)
    800034c8:	e426                	sd	s1,8(sp)
    800034ca:	e04a                	sd	s2,0(sp)
    800034cc:	1000                	addi	s0,sp,32
    800034ce:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034d0:	01050913          	addi	s2,a0,16
    800034d4:	854a                	mv	a0,s2
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	3fc080e7          	jalr	1020(ra) # 800048d2 <holdingsleep>
    800034de:	c925                	beqz	a0,8000354e <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800034e0:	854a                	mv	a0,s2
    800034e2:	00001097          	auipc	ra,0x1
    800034e6:	3ac080e7          	jalr	940(ra) # 8000488e <releasesleep>

  acquire(&bcache.lock);
    800034ea:	00013517          	auipc	a0,0x13
    800034ee:	63e50513          	addi	a0,a0,1598 # 80016b28 <bcache>
    800034f2:	ffffd097          	auipc	ra,0xffffd
    800034f6:	7a8080e7          	jalr	1960(ra) # 80000c9a <acquire>
  b->refcnt--;
    800034fa:	40bc                	lw	a5,64(s1)
    800034fc:	37fd                	addiw	a5,a5,-1
    800034fe:	0007871b          	sext.w	a4,a5
    80003502:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003504:	e71d                	bnez	a4,80003532 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003506:	68b8                	ld	a4,80(s1)
    80003508:	64bc                	ld	a5,72(s1)
    8000350a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000350c:	68b8                	ld	a4,80(s1)
    8000350e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003510:	0001b797          	auipc	a5,0x1b
    80003514:	61878793          	addi	a5,a5,1560 # 8001eb28 <bcache+0x8000>
    80003518:	2b87b703          	ld	a4,696(a5)
    8000351c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000351e:	0001c717          	auipc	a4,0x1c
    80003522:	87270713          	addi	a4,a4,-1934 # 8001ed90 <bcache+0x8268>
    80003526:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003528:	2b87b703          	ld	a4,696(a5)
    8000352c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000352e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003532:	00013517          	auipc	a0,0x13
    80003536:	5f650513          	addi	a0,a0,1526 # 80016b28 <bcache>
    8000353a:	ffffe097          	auipc	ra,0xffffe
    8000353e:	814080e7          	jalr	-2028(ra) # 80000d4e <release>
}
    80003542:	60e2                	ld	ra,24(sp)
    80003544:	6442                	ld	s0,16(sp)
    80003546:	64a2                	ld	s1,8(sp)
    80003548:	6902                	ld	s2,0(sp)
    8000354a:	6105                	addi	sp,sp,32
    8000354c:	8082                	ret
    panic("brelse");
    8000354e:	00005517          	auipc	a0,0x5
    80003552:	15250513          	addi	a0,a0,338 # 800086a0 <syscalls+0x128>
    80003556:	ffffd097          	auipc	ra,0xffffd
    8000355a:	fe6080e7          	jalr	-26(ra) # 8000053c <panic>

000000008000355e <bpin>:

void
bpin(struct buf *b) {
    8000355e:	1101                	addi	sp,sp,-32
    80003560:	ec06                	sd	ra,24(sp)
    80003562:	e822                	sd	s0,16(sp)
    80003564:	e426                	sd	s1,8(sp)
    80003566:	1000                	addi	s0,sp,32
    80003568:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000356a:	00013517          	auipc	a0,0x13
    8000356e:	5be50513          	addi	a0,a0,1470 # 80016b28 <bcache>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	728080e7          	jalr	1832(ra) # 80000c9a <acquire>
  b->refcnt++;
    8000357a:	40bc                	lw	a5,64(s1)
    8000357c:	2785                	addiw	a5,a5,1
    8000357e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003580:	00013517          	auipc	a0,0x13
    80003584:	5a850513          	addi	a0,a0,1448 # 80016b28 <bcache>
    80003588:	ffffd097          	auipc	ra,0xffffd
    8000358c:	7c6080e7          	jalr	1990(ra) # 80000d4e <release>
}
    80003590:	60e2                	ld	ra,24(sp)
    80003592:	6442                	ld	s0,16(sp)
    80003594:	64a2                	ld	s1,8(sp)
    80003596:	6105                	addi	sp,sp,32
    80003598:	8082                	ret

000000008000359a <bunpin>:

void
bunpin(struct buf *b) {
    8000359a:	1101                	addi	sp,sp,-32
    8000359c:	ec06                	sd	ra,24(sp)
    8000359e:	e822                	sd	s0,16(sp)
    800035a0:	e426                	sd	s1,8(sp)
    800035a2:	1000                	addi	s0,sp,32
    800035a4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035a6:	00013517          	auipc	a0,0x13
    800035aa:	58250513          	addi	a0,a0,1410 # 80016b28 <bcache>
    800035ae:	ffffd097          	auipc	ra,0xffffd
    800035b2:	6ec080e7          	jalr	1772(ra) # 80000c9a <acquire>
  b->refcnt--;
    800035b6:	40bc                	lw	a5,64(s1)
    800035b8:	37fd                	addiw	a5,a5,-1
    800035ba:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035bc:	00013517          	auipc	a0,0x13
    800035c0:	56c50513          	addi	a0,a0,1388 # 80016b28 <bcache>
    800035c4:	ffffd097          	auipc	ra,0xffffd
    800035c8:	78a080e7          	jalr	1930(ra) # 80000d4e <release>
}
    800035cc:	60e2                	ld	ra,24(sp)
    800035ce:	6442                	ld	s0,16(sp)
    800035d0:	64a2                	ld	s1,8(sp)
    800035d2:	6105                	addi	sp,sp,32
    800035d4:	8082                	ret

00000000800035d6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035d6:	1101                	addi	sp,sp,-32
    800035d8:	ec06                	sd	ra,24(sp)
    800035da:	e822                	sd	s0,16(sp)
    800035dc:	e426                	sd	s1,8(sp)
    800035de:	e04a                	sd	s2,0(sp)
    800035e0:	1000                	addi	s0,sp,32
    800035e2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035e4:	00d5d59b          	srliw	a1,a1,0xd
    800035e8:	0001c797          	auipc	a5,0x1c
    800035ec:	c1c7a783          	lw	a5,-996(a5) # 8001f204 <sb+0x1c>
    800035f0:	9dbd                	addw	a1,a1,a5
    800035f2:	00000097          	auipc	ra,0x0
    800035f6:	da0080e7          	jalr	-608(ra) # 80003392 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035fa:	0074f713          	andi	a4,s1,7
    800035fe:	4785                	li	a5,1
    80003600:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003604:	14ce                	slli	s1,s1,0x33
    80003606:	90d9                	srli	s1,s1,0x36
    80003608:	00950733          	add	a4,a0,s1
    8000360c:	05874703          	lbu	a4,88(a4)
    80003610:	00e7f6b3          	and	a3,a5,a4
    80003614:	c69d                	beqz	a3,80003642 <bfree+0x6c>
    80003616:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003618:	94aa                	add	s1,s1,a0
    8000361a:	fff7c793          	not	a5,a5
    8000361e:	8f7d                	and	a4,a4,a5
    80003620:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003624:	00001097          	auipc	ra,0x1
    80003628:	0f6080e7          	jalr	246(ra) # 8000471a <log_write>
  brelse(bp);
    8000362c:	854a                	mv	a0,s2
    8000362e:	00000097          	auipc	ra,0x0
    80003632:	e94080e7          	jalr	-364(ra) # 800034c2 <brelse>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6902                	ld	s2,0(sp)
    8000363e:	6105                	addi	sp,sp,32
    80003640:	8082                	ret
    panic("freeing free block");
    80003642:	00005517          	auipc	a0,0x5
    80003646:	06650513          	addi	a0,a0,102 # 800086a8 <syscalls+0x130>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	ef2080e7          	jalr	-270(ra) # 8000053c <panic>

0000000080003652 <balloc>:
{
    80003652:	711d                	addi	sp,sp,-96
    80003654:	ec86                	sd	ra,88(sp)
    80003656:	e8a2                	sd	s0,80(sp)
    80003658:	e4a6                	sd	s1,72(sp)
    8000365a:	e0ca                	sd	s2,64(sp)
    8000365c:	fc4e                	sd	s3,56(sp)
    8000365e:	f852                	sd	s4,48(sp)
    80003660:	f456                	sd	s5,40(sp)
    80003662:	f05a                	sd	s6,32(sp)
    80003664:	ec5e                	sd	s7,24(sp)
    80003666:	e862                	sd	s8,16(sp)
    80003668:	e466                	sd	s9,8(sp)
    8000366a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000366c:	0001c797          	auipc	a5,0x1c
    80003670:	b807a783          	lw	a5,-1152(a5) # 8001f1ec <sb+0x4>
    80003674:	cff5                	beqz	a5,80003770 <balloc+0x11e>
    80003676:	8baa                	mv	s7,a0
    80003678:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000367a:	0001cb17          	auipc	s6,0x1c
    8000367e:	b6eb0b13          	addi	s6,s6,-1170 # 8001f1e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003682:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003684:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003686:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003688:	6c89                	lui	s9,0x2
    8000368a:	a061                	j	80003712 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000368c:	97ca                	add	a5,a5,s2
    8000368e:	8e55                	or	a2,a2,a3
    80003690:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003694:	854a                	mv	a0,s2
    80003696:	00001097          	auipc	ra,0x1
    8000369a:	084080e7          	jalr	132(ra) # 8000471a <log_write>
        brelse(bp);
    8000369e:	854a                	mv	a0,s2
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	e22080e7          	jalr	-478(ra) # 800034c2 <brelse>
  bp = bread(dev, bno);
    800036a8:	85a6                	mv	a1,s1
    800036aa:	855e                	mv	a0,s7
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	ce6080e7          	jalr	-794(ra) # 80003392 <bread>
    800036b4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036b6:	40000613          	li	a2,1024
    800036ba:	4581                	li	a1,0
    800036bc:	05850513          	addi	a0,a0,88
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	6d6080e7          	jalr	1750(ra) # 80000d96 <memset>
  log_write(bp);
    800036c8:	854a                	mv	a0,s2
    800036ca:	00001097          	auipc	ra,0x1
    800036ce:	050080e7          	jalr	80(ra) # 8000471a <log_write>
  brelse(bp);
    800036d2:	854a                	mv	a0,s2
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	dee080e7          	jalr	-530(ra) # 800034c2 <brelse>
}
    800036dc:	8526                	mv	a0,s1
    800036de:	60e6                	ld	ra,88(sp)
    800036e0:	6446                	ld	s0,80(sp)
    800036e2:	64a6                	ld	s1,72(sp)
    800036e4:	6906                	ld	s2,64(sp)
    800036e6:	79e2                	ld	s3,56(sp)
    800036e8:	7a42                	ld	s4,48(sp)
    800036ea:	7aa2                	ld	s5,40(sp)
    800036ec:	7b02                	ld	s6,32(sp)
    800036ee:	6be2                	ld	s7,24(sp)
    800036f0:	6c42                	ld	s8,16(sp)
    800036f2:	6ca2                	ld	s9,8(sp)
    800036f4:	6125                	addi	sp,sp,96
    800036f6:	8082                	ret
    brelse(bp);
    800036f8:	854a                	mv	a0,s2
    800036fa:	00000097          	auipc	ra,0x0
    800036fe:	dc8080e7          	jalr	-568(ra) # 800034c2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003702:	015c87bb          	addw	a5,s9,s5
    80003706:	00078a9b          	sext.w	s5,a5
    8000370a:	004b2703          	lw	a4,4(s6)
    8000370e:	06eaf163          	bgeu	s5,a4,80003770 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003712:	41fad79b          	sraiw	a5,s5,0x1f
    80003716:	0137d79b          	srliw	a5,a5,0x13
    8000371a:	015787bb          	addw	a5,a5,s5
    8000371e:	40d7d79b          	sraiw	a5,a5,0xd
    80003722:	01cb2583          	lw	a1,28(s6)
    80003726:	9dbd                	addw	a1,a1,a5
    80003728:	855e                	mv	a0,s7
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	c68080e7          	jalr	-920(ra) # 80003392 <bread>
    80003732:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003734:	004b2503          	lw	a0,4(s6)
    80003738:	000a849b          	sext.w	s1,s5
    8000373c:	8762                	mv	a4,s8
    8000373e:	faa4fde3          	bgeu	s1,a0,800036f8 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003742:	00777693          	andi	a3,a4,7
    80003746:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000374a:	41f7579b          	sraiw	a5,a4,0x1f
    8000374e:	01d7d79b          	srliw	a5,a5,0x1d
    80003752:	9fb9                	addw	a5,a5,a4
    80003754:	4037d79b          	sraiw	a5,a5,0x3
    80003758:	00f90633          	add	a2,s2,a5
    8000375c:	05864603          	lbu	a2,88(a2)
    80003760:	00c6f5b3          	and	a1,a3,a2
    80003764:	d585                	beqz	a1,8000368c <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003766:	2705                	addiw	a4,a4,1
    80003768:	2485                	addiw	s1,s1,1
    8000376a:	fd471ae3          	bne	a4,s4,8000373e <balloc+0xec>
    8000376e:	b769                	j	800036f8 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003770:	00005517          	auipc	a0,0x5
    80003774:	f5050513          	addi	a0,a0,-176 # 800086c0 <syscalls+0x148>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	e20080e7          	jalr	-480(ra) # 80000598 <printf>
  return 0;
    80003780:	4481                	li	s1,0
    80003782:	bfa9                	j	800036dc <balloc+0x8a>

0000000080003784 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003784:	7179                	addi	sp,sp,-48
    80003786:	f406                	sd	ra,40(sp)
    80003788:	f022                	sd	s0,32(sp)
    8000378a:	ec26                	sd	s1,24(sp)
    8000378c:	e84a                	sd	s2,16(sp)
    8000378e:	e44e                	sd	s3,8(sp)
    80003790:	e052                	sd	s4,0(sp)
    80003792:	1800                	addi	s0,sp,48
    80003794:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003796:	47ad                	li	a5,11
    80003798:	02b7e863          	bltu	a5,a1,800037c8 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000379c:	02059793          	slli	a5,a1,0x20
    800037a0:	01e7d593          	srli	a1,a5,0x1e
    800037a4:	00b504b3          	add	s1,a0,a1
    800037a8:	0504a903          	lw	s2,80(s1)
    800037ac:	06091e63          	bnez	s2,80003828 <bmap+0xa4>
      addr = balloc(ip->dev);
    800037b0:	4108                	lw	a0,0(a0)
    800037b2:	00000097          	auipc	ra,0x0
    800037b6:	ea0080e7          	jalr	-352(ra) # 80003652 <balloc>
    800037ba:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037be:	06090563          	beqz	s2,80003828 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800037c2:	0524a823          	sw	s2,80(s1)
    800037c6:	a08d                	j	80003828 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037c8:	ff45849b          	addiw	s1,a1,-12
    800037cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037d0:	0ff00793          	li	a5,255
    800037d4:	08e7e563          	bltu	a5,a4,8000385e <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037d8:	08052903          	lw	s2,128(a0)
    800037dc:	00091d63          	bnez	s2,800037f6 <bmap+0x72>
      addr = balloc(ip->dev);
    800037e0:	4108                	lw	a0,0(a0)
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	e70080e7          	jalr	-400(ra) # 80003652 <balloc>
    800037ea:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037ee:	02090d63          	beqz	s2,80003828 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037f2:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037f6:	85ca                	mv	a1,s2
    800037f8:	0009a503          	lw	a0,0(s3)
    800037fc:	00000097          	auipc	ra,0x0
    80003800:	b96080e7          	jalr	-1130(ra) # 80003392 <bread>
    80003804:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003806:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000380a:	02049713          	slli	a4,s1,0x20
    8000380e:	01e75593          	srli	a1,a4,0x1e
    80003812:	00b784b3          	add	s1,a5,a1
    80003816:	0004a903          	lw	s2,0(s1)
    8000381a:	02090063          	beqz	s2,8000383a <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000381e:	8552                	mv	a0,s4
    80003820:	00000097          	auipc	ra,0x0
    80003824:	ca2080e7          	jalr	-862(ra) # 800034c2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003828:	854a                	mv	a0,s2
    8000382a:	70a2                	ld	ra,40(sp)
    8000382c:	7402                	ld	s0,32(sp)
    8000382e:	64e2                	ld	s1,24(sp)
    80003830:	6942                	ld	s2,16(sp)
    80003832:	69a2                	ld	s3,8(sp)
    80003834:	6a02                	ld	s4,0(sp)
    80003836:	6145                	addi	sp,sp,48
    80003838:	8082                	ret
      addr = balloc(ip->dev);
    8000383a:	0009a503          	lw	a0,0(s3)
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	e14080e7          	jalr	-492(ra) # 80003652 <balloc>
    80003846:	0005091b          	sext.w	s2,a0
      if(addr){
    8000384a:	fc090ae3          	beqz	s2,8000381e <bmap+0x9a>
        a[bn] = addr;
    8000384e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003852:	8552                	mv	a0,s4
    80003854:	00001097          	auipc	ra,0x1
    80003858:	ec6080e7          	jalr	-314(ra) # 8000471a <log_write>
    8000385c:	b7c9                	j	8000381e <bmap+0x9a>
  panic("bmap: out of range");
    8000385e:	00005517          	auipc	a0,0x5
    80003862:	e7a50513          	addi	a0,a0,-390 # 800086d8 <syscalls+0x160>
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	cd6080e7          	jalr	-810(ra) # 8000053c <panic>

000000008000386e <iget>:
{
    8000386e:	7179                	addi	sp,sp,-48
    80003870:	f406                	sd	ra,40(sp)
    80003872:	f022                	sd	s0,32(sp)
    80003874:	ec26                	sd	s1,24(sp)
    80003876:	e84a                	sd	s2,16(sp)
    80003878:	e44e                	sd	s3,8(sp)
    8000387a:	e052                	sd	s4,0(sp)
    8000387c:	1800                	addi	s0,sp,48
    8000387e:	89aa                	mv	s3,a0
    80003880:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003882:	0001c517          	auipc	a0,0x1c
    80003886:	98650513          	addi	a0,a0,-1658 # 8001f208 <itable>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	410080e7          	jalr	1040(ra) # 80000c9a <acquire>
  empty = 0;
    80003892:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003894:	0001c497          	auipc	s1,0x1c
    80003898:	98c48493          	addi	s1,s1,-1652 # 8001f220 <itable+0x18>
    8000389c:	0001d697          	auipc	a3,0x1d
    800038a0:	41468693          	addi	a3,a3,1044 # 80020cb0 <log>
    800038a4:	a039                	j	800038b2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038a6:	02090b63          	beqz	s2,800038dc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038aa:	08848493          	addi	s1,s1,136
    800038ae:	02d48a63          	beq	s1,a3,800038e2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038b2:	449c                	lw	a5,8(s1)
    800038b4:	fef059e3          	blez	a5,800038a6 <iget+0x38>
    800038b8:	4098                	lw	a4,0(s1)
    800038ba:	ff3716e3          	bne	a4,s3,800038a6 <iget+0x38>
    800038be:	40d8                	lw	a4,4(s1)
    800038c0:	ff4713e3          	bne	a4,s4,800038a6 <iget+0x38>
      ip->ref++;
    800038c4:	2785                	addiw	a5,a5,1
    800038c6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038c8:	0001c517          	auipc	a0,0x1c
    800038cc:	94050513          	addi	a0,a0,-1728 # 8001f208 <itable>
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	47e080e7          	jalr	1150(ra) # 80000d4e <release>
      return ip;
    800038d8:	8926                	mv	s2,s1
    800038da:	a03d                	j	80003908 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038dc:	f7f9                	bnez	a5,800038aa <iget+0x3c>
    800038de:	8926                	mv	s2,s1
    800038e0:	b7e9                	j	800038aa <iget+0x3c>
  if(empty == 0)
    800038e2:	02090c63          	beqz	s2,8000391a <iget+0xac>
  ip->dev = dev;
    800038e6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038ea:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038ee:	4785                	li	a5,1
    800038f0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038f4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038f8:	0001c517          	auipc	a0,0x1c
    800038fc:	91050513          	addi	a0,a0,-1776 # 8001f208 <itable>
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	44e080e7          	jalr	1102(ra) # 80000d4e <release>
}
    80003908:	854a                	mv	a0,s2
    8000390a:	70a2                	ld	ra,40(sp)
    8000390c:	7402                	ld	s0,32(sp)
    8000390e:	64e2                	ld	s1,24(sp)
    80003910:	6942                	ld	s2,16(sp)
    80003912:	69a2                	ld	s3,8(sp)
    80003914:	6a02                	ld	s4,0(sp)
    80003916:	6145                	addi	sp,sp,48
    80003918:	8082                	ret
    panic("iget: no inodes");
    8000391a:	00005517          	auipc	a0,0x5
    8000391e:	dd650513          	addi	a0,a0,-554 # 800086f0 <syscalls+0x178>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	c1a080e7          	jalr	-998(ra) # 8000053c <panic>

000000008000392a <fsinit>:
fsinit(int dev) {
    8000392a:	7179                	addi	sp,sp,-48
    8000392c:	f406                	sd	ra,40(sp)
    8000392e:	f022                	sd	s0,32(sp)
    80003930:	ec26                	sd	s1,24(sp)
    80003932:	e84a                	sd	s2,16(sp)
    80003934:	e44e                	sd	s3,8(sp)
    80003936:	1800                	addi	s0,sp,48
    80003938:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000393a:	4585                	li	a1,1
    8000393c:	00000097          	auipc	ra,0x0
    80003940:	a56080e7          	jalr	-1450(ra) # 80003392 <bread>
    80003944:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003946:	0001c997          	auipc	s3,0x1c
    8000394a:	8a298993          	addi	s3,s3,-1886 # 8001f1e8 <sb>
    8000394e:	02000613          	li	a2,32
    80003952:	05850593          	addi	a1,a0,88
    80003956:	854e                	mv	a0,s3
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	49a080e7          	jalr	1178(ra) # 80000df2 <memmove>
  brelse(bp);
    80003960:	8526                	mv	a0,s1
    80003962:	00000097          	auipc	ra,0x0
    80003966:	b60080e7          	jalr	-1184(ra) # 800034c2 <brelse>
  if(sb.magic != FSMAGIC)
    8000396a:	0009a703          	lw	a4,0(s3)
    8000396e:	102037b7          	lui	a5,0x10203
    80003972:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003976:	02f71263          	bne	a4,a5,8000399a <fsinit+0x70>
  initlog(dev, &sb);
    8000397a:	0001c597          	auipc	a1,0x1c
    8000397e:	86e58593          	addi	a1,a1,-1938 # 8001f1e8 <sb>
    80003982:	854a                	mv	a0,s2
    80003984:	00001097          	auipc	ra,0x1
    80003988:	b2c080e7          	jalr	-1236(ra) # 800044b0 <initlog>
}
    8000398c:	70a2                	ld	ra,40(sp)
    8000398e:	7402                	ld	s0,32(sp)
    80003990:	64e2                	ld	s1,24(sp)
    80003992:	6942                	ld	s2,16(sp)
    80003994:	69a2                	ld	s3,8(sp)
    80003996:	6145                	addi	sp,sp,48
    80003998:	8082                	ret
    panic("invalid file system");
    8000399a:	00005517          	auipc	a0,0x5
    8000399e:	d6650513          	addi	a0,a0,-666 # 80008700 <syscalls+0x188>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	b9a080e7          	jalr	-1126(ra) # 8000053c <panic>

00000000800039aa <iinit>:
{
    800039aa:	7179                	addi	sp,sp,-48
    800039ac:	f406                	sd	ra,40(sp)
    800039ae:	f022                	sd	s0,32(sp)
    800039b0:	ec26                	sd	s1,24(sp)
    800039b2:	e84a                	sd	s2,16(sp)
    800039b4:	e44e                	sd	s3,8(sp)
    800039b6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039b8:	00005597          	auipc	a1,0x5
    800039bc:	d6058593          	addi	a1,a1,-672 # 80008718 <syscalls+0x1a0>
    800039c0:	0001c517          	auipc	a0,0x1c
    800039c4:	84850513          	addi	a0,a0,-1976 # 8001f208 <itable>
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	242080e7          	jalr	578(ra) # 80000c0a <initlock>
  for(i = 0; i < NINODE; i++) {
    800039d0:	0001c497          	auipc	s1,0x1c
    800039d4:	86048493          	addi	s1,s1,-1952 # 8001f230 <itable+0x28>
    800039d8:	0001d997          	auipc	s3,0x1d
    800039dc:	2e898993          	addi	s3,s3,744 # 80020cc0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039e0:	00005917          	auipc	s2,0x5
    800039e4:	d4090913          	addi	s2,s2,-704 # 80008720 <syscalls+0x1a8>
    800039e8:	85ca                	mv	a1,s2
    800039ea:	8526                	mv	a0,s1
    800039ec:	00001097          	auipc	ra,0x1
    800039f0:	e12080e7          	jalr	-494(ra) # 800047fe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039f4:	08848493          	addi	s1,s1,136
    800039f8:	ff3498e3          	bne	s1,s3,800039e8 <iinit+0x3e>
}
    800039fc:	70a2                	ld	ra,40(sp)
    800039fe:	7402                	ld	s0,32(sp)
    80003a00:	64e2                	ld	s1,24(sp)
    80003a02:	6942                	ld	s2,16(sp)
    80003a04:	69a2                	ld	s3,8(sp)
    80003a06:	6145                	addi	sp,sp,48
    80003a08:	8082                	ret

0000000080003a0a <ialloc>:
{
    80003a0a:	7139                	addi	sp,sp,-64
    80003a0c:	fc06                	sd	ra,56(sp)
    80003a0e:	f822                	sd	s0,48(sp)
    80003a10:	f426                	sd	s1,40(sp)
    80003a12:	f04a                	sd	s2,32(sp)
    80003a14:	ec4e                	sd	s3,24(sp)
    80003a16:	e852                	sd	s4,16(sp)
    80003a18:	e456                	sd	s5,8(sp)
    80003a1a:	e05a                	sd	s6,0(sp)
    80003a1c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a1e:	0001b717          	auipc	a4,0x1b
    80003a22:	7d672703          	lw	a4,2006(a4) # 8001f1f4 <sb+0xc>
    80003a26:	4785                	li	a5,1
    80003a28:	04e7f863          	bgeu	a5,a4,80003a78 <ialloc+0x6e>
    80003a2c:	8aaa                	mv	s5,a0
    80003a2e:	8b2e                	mv	s6,a1
    80003a30:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a32:	0001ba17          	auipc	s4,0x1b
    80003a36:	7b6a0a13          	addi	s4,s4,1974 # 8001f1e8 <sb>
    80003a3a:	00495593          	srli	a1,s2,0x4
    80003a3e:	018a2783          	lw	a5,24(s4)
    80003a42:	9dbd                	addw	a1,a1,a5
    80003a44:	8556                	mv	a0,s5
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	94c080e7          	jalr	-1716(ra) # 80003392 <bread>
    80003a4e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a50:	05850993          	addi	s3,a0,88
    80003a54:	00f97793          	andi	a5,s2,15
    80003a58:	079a                	slli	a5,a5,0x6
    80003a5a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a5c:	00099783          	lh	a5,0(s3)
    80003a60:	cf9d                	beqz	a5,80003a9e <ialloc+0x94>
    brelse(bp);
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	a60080e7          	jalr	-1440(ra) # 800034c2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a6a:	0905                	addi	s2,s2,1
    80003a6c:	00ca2703          	lw	a4,12(s4)
    80003a70:	0009079b          	sext.w	a5,s2
    80003a74:	fce7e3e3          	bltu	a5,a4,80003a3a <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003a78:	00005517          	auipc	a0,0x5
    80003a7c:	cb050513          	addi	a0,a0,-848 # 80008728 <syscalls+0x1b0>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	b18080e7          	jalr	-1256(ra) # 80000598 <printf>
  return 0;
    80003a88:	4501                	li	a0,0
}
    80003a8a:	70e2                	ld	ra,56(sp)
    80003a8c:	7442                	ld	s0,48(sp)
    80003a8e:	74a2                	ld	s1,40(sp)
    80003a90:	7902                	ld	s2,32(sp)
    80003a92:	69e2                	ld	s3,24(sp)
    80003a94:	6a42                	ld	s4,16(sp)
    80003a96:	6aa2                	ld	s5,8(sp)
    80003a98:	6b02                	ld	s6,0(sp)
    80003a9a:	6121                	addi	sp,sp,64
    80003a9c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a9e:	04000613          	li	a2,64
    80003aa2:	4581                	li	a1,0
    80003aa4:	854e                	mv	a0,s3
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	2f0080e7          	jalr	752(ra) # 80000d96 <memset>
      dip->type = type;
    80003aae:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003ab2:	8526                	mv	a0,s1
    80003ab4:	00001097          	auipc	ra,0x1
    80003ab8:	c66080e7          	jalr	-922(ra) # 8000471a <log_write>
      brelse(bp);
    80003abc:	8526                	mv	a0,s1
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	a04080e7          	jalr	-1532(ra) # 800034c2 <brelse>
      return iget(dev, inum);
    80003ac6:	0009059b          	sext.w	a1,s2
    80003aca:	8556                	mv	a0,s5
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	da2080e7          	jalr	-606(ra) # 8000386e <iget>
    80003ad4:	bf5d                	j	80003a8a <ialloc+0x80>

0000000080003ad6 <iupdate>:
{
    80003ad6:	1101                	addi	sp,sp,-32
    80003ad8:	ec06                	sd	ra,24(sp)
    80003ada:	e822                	sd	s0,16(sp)
    80003adc:	e426                	sd	s1,8(sp)
    80003ade:	e04a                	sd	s2,0(sp)
    80003ae0:	1000                	addi	s0,sp,32
    80003ae2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ae4:	415c                	lw	a5,4(a0)
    80003ae6:	0047d79b          	srliw	a5,a5,0x4
    80003aea:	0001b597          	auipc	a1,0x1b
    80003aee:	7165a583          	lw	a1,1814(a1) # 8001f200 <sb+0x18>
    80003af2:	9dbd                	addw	a1,a1,a5
    80003af4:	4108                	lw	a0,0(a0)
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	89c080e7          	jalr	-1892(ra) # 80003392 <bread>
    80003afe:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b00:	05850793          	addi	a5,a0,88
    80003b04:	40d8                	lw	a4,4(s1)
    80003b06:	8b3d                	andi	a4,a4,15
    80003b08:	071a                	slli	a4,a4,0x6
    80003b0a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b0c:	04449703          	lh	a4,68(s1)
    80003b10:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b14:	04649703          	lh	a4,70(s1)
    80003b18:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b1c:	04849703          	lh	a4,72(s1)
    80003b20:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b24:	04a49703          	lh	a4,74(s1)
    80003b28:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b2c:	44f8                	lw	a4,76(s1)
    80003b2e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b30:	03400613          	li	a2,52
    80003b34:	05048593          	addi	a1,s1,80
    80003b38:	00c78513          	addi	a0,a5,12
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	2b6080e7          	jalr	694(ra) # 80000df2 <memmove>
  log_write(bp);
    80003b44:	854a                	mv	a0,s2
    80003b46:	00001097          	auipc	ra,0x1
    80003b4a:	bd4080e7          	jalr	-1068(ra) # 8000471a <log_write>
  brelse(bp);
    80003b4e:	854a                	mv	a0,s2
    80003b50:	00000097          	auipc	ra,0x0
    80003b54:	972080e7          	jalr	-1678(ra) # 800034c2 <brelse>
}
    80003b58:	60e2                	ld	ra,24(sp)
    80003b5a:	6442                	ld	s0,16(sp)
    80003b5c:	64a2                	ld	s1,8(sp)
    80003b5e:	6902                	ld	s2,0(sp)
    80003b60:	6105                	addi	sp,sp,32
    80003b62:	8082                	ret

0000000080003b64 <idup>:
{
    80003b64:	1101                	addi	sp,sp,-32
    80003b66:	ec06                	sd	ra,24(sp)
    80003b68:	e822                	sd	s0,16(sp)
    80003b6a:	e426                	sd	s1,8(sp)
    80003b6c:	1000                	addi	s0,sp,32
    80003b6e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b70:	0001b517          	auipc	a0,0x1b
    80003b74:	69850513          	addi	a0,a0,1688 # 8001f208 <itable>
    80003b78:	ffffd097          	auipc	ra,0xffffd
    80003b7c:	122080e7          	jalr	290(ra) # 80000c9a <acquire>
  ip->ref++;
    80003b80:	449c                	lw	a5,8(s1)
    80003b82:	2785                	addiw	a5,a5,1
    80003b84:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b86:	0001b517          	auipc	a0,0x1b
    80003b8a:	68250513          	addi	a0,a0,1666 # 8001f208 <itable>
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	1c0080e7          	jalr	448(ra) # 80000d4e <release>
}
    80003b96:	8526                	mv	a0,s1
    80003b98:	60e2                	ld	ra,24(sp)
    80003b9a:	6442                	ld	s0,16(sp)
    80003b9c:	64a2                	ld	s1,8(sp)
    80003b9e:	6105                	addi	sp,sp,32
    80003ba0:	8082                	ret

0000000080003ba2 <ilock>:
{
    80003ba2:	1101                	addi	sp,sp,-32
    80003ba4:	ec06                	sd	ra,24(sp)
    80003ba6:	e822                	sd	s0,16(sp)
    80003ba8:	e426                	sd	s1,8(sp)
    80003baa:	e04a                	sd	s2,0(sp)
    80003bac:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bae:	c115                	beqz	a0,80003bd2 <ilock+0x30>
    80003bb0:	84aa                	mv	s1,a0
    80003bb2:	451c                	lw	a5,8(a0)
    80003bb4:	00f05f63          	blez	a5,80003bd2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bb8:	0541                	addi	a0,a0,16
    80003bba:	00001097          	auipc	ra,0x1
    80003bbe:	c7e080e7          	jalr	-898(ra) # 80004838 <acquiresleep>
  if(ip->valid == 0){
    80003bc2:	40bc                	lw	a5,64(s1)
    80003bc4:	cf99                	beqz	a5,80003be2 <ilock+0x40>
}
    80003bc6:	60e2                	ld	ra,24(sp)
    80003bc8:	6442                	ld	s0,16(sp)
    80003bca:	64a2                	ld	s1,8(sp)
    80003bcc:	6902                	ld	s2,0(sp)
    80003bce:	6105                	addi	sp,sp,32
    80003bd0:	8082                	ret
    panic("ilock");
    80003bd2:	00005517          	auipc	a0,0x5
    80003bd6:	b6e50513          	addi	a0,a0,-1170 # 80008740 <syscalls+0x1c8>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	962080e7          	jalr	-1694(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003be2:	40dc                	lw	a5,4(s1)
    80003be4:	0047d79b          	srliw	a5,a5,0x4
    80003be8:	0001b597          	auipc	a1,0x1b
    80003bec:	6185a583          	lw	a1,1560(a1) # 8001f200 <sb+0x18>
    80003bf0:	9dbd                	addw	a1,a1,a5
    80003bf2:	4088                	lw	a0,0(s1)
    80003bf4:	fffff097          	auipc	ra,0xfffff
    80003bf8:	79e080e7          	jalr	1950(ra) # 80003392 <bread>
    80003bfc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bfe:	05850593          	addi	a1,a0,88
    80003c02:	40dc                	lw	a5,4(s1)
    80003c04:	8bbd                	andi	a5,a5,15
    80003c06:	079a                	slli	a5,a5,0x6
    80003c08:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c0a:	00059783          	lh	a5,0(a1)
    80003c0e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c12:	00259783          	lh	a5,2(a1)
    80003c16:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c1a:	00459783          	lh	a5,4(a1)
    80003c1e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c22:	00659783          	lh	a5,6(a1)
    80003c26:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c2a:	459c                	lw	a5,8(a1)
    80003c2c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c2e:	03400613          	li	a2,52
    80003c32:	05b1                	addi	a1,a1,12
    80003c34:	05048513          	addi	a0,s1,80
    80003c38:	ffffd097          	auipc	ra,0xffffd
    80003c3c:	1ba080e7          	jalr	442(ra) # 80000df2 <memmove>
    brelse(bp);
    80003c40:	854a                	mv	a0,s2
    80003c42:	00000097          	auipc	ra,0x0
    80003c46:	880080e7          	jalr	-1920(ra) # 800034c2 <brelse>
    ip->valid = 1;
    80003c4a:	4785                	li	a5,1
    80003c4c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c4e:	04449783          	lh	a5,68(s1)
    80003c52:	fbb5                	bnez	a5,80003bc6 <ilock+0x24>
      panic("ilock: no type");
    80003c54:	00005517          	auipc	a0,0x5
    80003c58:	af450513          	addi	a0,a0,-1292 # 80008748 <syscalls+0x1d0>
    80003c5c:	ffffd097          	auipc	ra,0xffffd
    80003c60:	8e0080e7          	jalr	-1824(ra) # 8000053c <panic>

0000000080003c64 <iunlock>:
{
    80003c64:	1101                	addi	sp,sp,-32
    80003c66:	ec06                	sd	ra,24(sp)
    80003c68:	e822                	sd	s0,16(sp)
    80003c6a:	e426                	sd	s1,8(sp)
    80003c6c:	e04a                	sd	s2,0(sp)
    80003c6e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c70:	c905                	beqz	a0,80003ca0 <iunlock+0x3c>
    80003c72:	84aa                	mv	s1,a0
    80003c74:	01050913          	addi	s2,a0,16
    80003c78:	854a                	mv	a0,s2
    80003c7a:	00001097          	auipc	ra,0x1
    80003c7e:	c58080e7          	jalr	-936(ra) # 800048d2 <holdingsleep>
    80003c82:	cd19                	beqz	a0,80003ca0 <iunlock+0x3c>
    80003c84:	449c                	lw	a5,8(s1)
    80003c86:	00f05d63          	blez	a5,80003ca0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c8a:	854a                	mv	a0,s2
    80003c8c:	00001097          	auipc	ra,0x1
    80003c90:	c02080e7          	jalr	-1022(ra) # 8000488e <releasesleep>
}
    80003c94:	60e2                	ld	ra,24(sp)
    80003c96:	6442                	ld	s0,16(sp)
    80003c98:	64a2                	ld	s1,8(sp)
    80003c9a:	6902                	ld	s2,0(sp)
    80003c9c:	6105                	addi	sp,sp,32
    80003c9e:	8082                	ret
    panic("iunlock");
    80003ca0:	00005517          	auipc	a0,0x5
    80003ca4:	ab850513          	addi	a0,a0,-1352 # 80008758 <syscalls+0x1e0>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	894080e7          	jalr	-1900(ra) # 8000053c <panic>

0000000080003cb0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cb0:	7179                	addi	sp,sp,-48
    80003cb2:	f406                	sd	ra,40(sp)
    80003cb4:	f022                	sd	s0,32(sp)
    80003cb6:	ec26                	sd	s1,24(sp)
    80003cb8:	e84a                	sd	s2,16(sp)
    80003cba:	e44e                	sd	s3,8(sp)
    80003cbc:	e052                	sd	s4,0(sp)
    80003cbe:	1800                	addi	s0,sp,48
    80003cc0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cc2:	05050493          	addi	s1,a0,80
    80003cc6:	08050913          	addi	s2,a0,128
    80003cca:	a021                	j	80003cd2 <itrunc+0x22>
    80003ccc:	0491                	addi	s1,s1,4
    80003cce:	01248d63          	beq	s1,s2,80003ce8 <itrunc+0x38>
    if(ip->addrs[i]){
    80003cd2:	408c                	lw	a1,0(s1)
    80003cd4:	dde5                	beqz	a1,80003ccc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cd6:	0009a503          	lw	a0,0(s3)
    80003cda:	00000097          	auipc	ra,0x0
    80003cde:	8fc080e7          	jalr	-1796(ra) # 800035d6 <bfree>
      ip->addrs[i] = 0;
    80003ce2:	0004a023          	sw	zero,0(s1)
    80003ce6:	b7dd                	j	80003ccc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ce8:	0809a583          	lw	a1,128(s3)
    80003cec:	e185                	bnez	a1,80003d0c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cee:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cf2:	854e                	mv	a0,s3
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	de2080e7          	jalr	-542(ra) # 80003ad6 <iupdate>
}
    80003cfc:	70a2                	ld	ra,40(sp)
    80003cfe:	7402                	ld	s0,32(sp)
    80003d00:	64e2                	ld	s1,24(sp)
    80003d02:	6942                	ld	s2,16(sp)
    80003d04:	69a2                	ld	s3,8(sp)
    80003d06:	6a02                	ld	s4,0(sp)
    80003d08:	6145                	addi	sp,sp,48
    80003d0a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d0c:	0009a503          	lw	a0,0(s3)
    80003d10:	fffff097          	auipc	ra,0xfffff
    80003d14:	682080e7          	jalr	1666(ra) # 80003392 <bread>
    80003d18:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d1a:	05850493          	addi	s1,a0,88
    80003d1e:	45850913          	addi	s2,a0,1112
    80003d22:	a021                	j	80003d2a <itrunc+0x7a>
    80003d24:	0491                	addi	s1,s1,4
    80003d26:	01248b63          	beq	s1,s2,80003d3c <itrunc+0x8c>
      if(a[j])
    80003d2a:	408c                	lw	a1,0(s1)
    80003d2c:	dde5                	beqz	a1,80003d24 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d2e:	0009a503          	lw	a0,0(s3)
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	8a4080e7          	jalr	-1884(ra) # 800035d6 <bfree>
    80003d3a:	b7ed                	j	80003d24 <itrunc+0x74>
    brelse(bp);
    80003d3c:	8552                	mv	a0,s4
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	784080e7          	jalr	1924(ra) # 800034c2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d46:	0809a583          	lw	a1,128(s3)
    80003d4a:	0009a503          	lw	a0,0(s3)
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	888080e7          	jalr	-1912(ra) # 800035d6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d56:	0809a023          	sw	zero,128(s3)
    80003d5a:	bf51                	j	80003cee <itrunc+0x3e>

0000000080003d5c <iput>:
{
    80003d5c:	1101                	addi	sp,sp,-32
    80003d5e:	ec06                	sd	ra,24(sp)
    80003d60:	e822                	sd	s0,16(sp)
    80003d62:	e426                	sd	s1,8(sp)
    80003d64:	e04a                	sd	s2,0(sp)
    80003d66:	1000                	addi	s0,sp,32
    80003d68:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d6a:	0001b517          	auipc	a0,0x1b
    80003d6e:	49e50513          	addi	a0,a0,1182 # 8001f208 <itable>
    80003d72:	ffffd097          	auipc	ra,0xffffd
    80003d76:	f28080e7          	jalr	-216(ra) # 80000c9a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d7a:	4498                	lw	a4,8(s1)
    80003d7c:	4785                	li	a5,1
    80003d7e:	02f70363          	beq	a4,a5,80003da4 <iput+0x48>
  ip->ref--;
    80003d82:	449c                	lw	a5,8(s1)
    80003d84:	37fd                	addiw	a5,a5,-1
    80003d86:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d88:	0001b517          	auipc	a0,0x1b
    80003d8c:	48050513          	addi	a0,a0,1152 # 8001f208 <itable>
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	fbe080e7          	jalr	-66(ra) # 80000d4e <release>
}
    80003d98:	60e2                	ld	ra,24(sp)
    80003d9a:	6442                	ld	s0,16(sp)
    80003d9c:	64a2                	ld	s1,8(sp)
    80003d9e:	6902                	ld	s2,0(sp)
    80003da0:	6105                	addi	sp,sp,32
    80003da2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003da4:	40bc                	lw	a5,64(s1)
    80003da6:	dff1                	beqz	a5,80003d82 <iput+0x26>
    80003da8:	04a49783          	lh	a5,74(s1)
    80003dac:	fbf9                	bnez	a5,80003d82 <iput+0x26>
    acquiresleep(&ip->lock);
    80003dae:	01048913          	addi	s2,s1,16
    80003db2:	854a                	mv	a0,s2
    80003db4:	00001097          	auipc	ra,0x1
    80003db8:	a84080e7          	jalr	-1404(ra) # 80004838 <acquiresleep>
    release(&itable.lock);
    80003dbc:	0001b517          	auipc	a0,0x1b
    80003dc0:	44c50513          	addi	a0,a0,1100 # 8001f208 <itable>
    80003dc4:	ffffd097          	auipc	ra,0xffffd
    80003dc8:	f8a080e7          	jalr	-118(ra) # 80000d4e <release>
    itrunc(ip);
    80003dcc:	8526                	mv	a0,s1
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	ee2080e7          	jalr	-286(ra) # 80003cb0 <itrunc>
    ip->type = 0;
    80003dd6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003dda:	8526                	mv	a0,s1
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	cfa080e7          	jalr	-774(ra) # 80003ad6 <iupdate>
    ip->valid = 0;
    80003de4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003de8:	854a                	mv	a0,s2
    80003dea:	00001097          	auipc	ra,0x1
    80003dee:	aa4080e7          	jalr	-1372(ra) # 8000488e <releasesleep>
    acquire(&itable.lock);
    80003df2:	0001b517          	auipc	a0,0x1b
    80003df6:	41650513          	addi	a0,a0,1046 # 8001f208 <itable>
    80003dfa:	ffffd097          	auipc	ra,0xffffd
    80003dfe:	ea0080e7          	jalr	-352(ra) # 80000c9a <acquire>
    80003e02:	b741                	j	80003d82 <iput+0x26>

0000000080003e04 <iunlockput>:
{
    80003e04:	1101                	addi	sp,sp,-32
    80003e06:	ec06                	sd	ra,24(sp)
    80003e08:	e822                	sd	s0,16(sp)
    80003e0a:	e426                	sd	s1,8(sp)
    80003e0c:	1000                	addi	s0,sp,32
    80003e0e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	e54080e7          	jalr	-428(ra) # 80003c64 <iunlock>
  iput(ip);
    80003e18:	8526                	mv	a0,s1
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	f42080e7          	jalr	-190(ra) # 80003d5c <iput>
}
    80003e22:	60e2                	ld	ra,24(sp)
    80003e24:	6442                	ld	s0,16(sp)
    80003e26:	64a2                	ld	s1,8(sp)
    80003e28:	6105                	addi	sp,sp,32
    80003e2a:	8082                	ret

0000000080003e2c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e2c:	1141                	addi	sp,sp,-16
    80003e2e:	e422                	sd	s0,8(sp)
    80003e30:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e32:	411c                	lw	a5,0(a0)
    80003e34:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e36:	415c                	lw	a5,4(a0)
    80003e38:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e3a:	04451783          	lh	a5,68(a0)
    80003e3e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e42:	04a51783          	lh	a5,74(a0)
    80003e46:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e4a:	04c56783          	lwu	a5,76(a0)
    80003e4e:	e99c                	sd	a5,16(a1)
}
    80003e50:	6422                	ld	s0,8(sp)
    80003e52:	0141                	addi	sp,sp,16
    80003e54:	8082                	ret

0000000080003e56 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e56:	457c                	lw	a5,76(a0)
    80003e58:	0ed7e963          	bltu	a5,a3,80003f4a <readi+0xf4>
{
    80003e5c:	7159                	addi	sp,sp,-112
    80003e5e:	f486                	sd	ra,104(sp)
    80003e60:	f0a2                	sd	s0,96(sp)
    80003e62:	eca6                	sd	s1,88(sp)
    80003e64:	e8ca                	sd	s2,80(sp)
    80003e66:	e4ce                	sd	s3,72(sp)
    80003e68:	e0d2                	sd	s4,64(sp)
    80003e6a:	fc56                	sd	s5,56(sp)
    80003e6c:	f85a                	sd	s6,48(sp)
    80003e6e:	f45e                	sd	s7,40(sp)
    80003e70:	f062                	sd	s8,32(sp)
    80003e72:	ec66                	sd	s9,24(sp)
    80003e74:	e86a                	sd	s10,16(sp)
    80003e76:	e46e                	sd	s11,8(sp)
    80003e78:	1880                	addi	s0,sp,112
    80003e7a:	8b2a                	mv	s6,a0
    80003e7c:	8bae                	mv	s7,a1
    80003e7e:	8a32                	mv	s4,a2
    80003e80:	84b6                	mv	s1,a3
    80003e82:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e84:	9f35                	addw	a4,a4,a3
    return 0;
    80003e86:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e88:	0ad76063          	bltu	a4,a3,80003f28 <readi+0xd2>
  if(off + n > ip->size)
    80003e8c:	00e7f463          	bgeu	a5,a4,80003e94 <readi+0x3e>
    n = ip->size - off;
    80003e90:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e94:	0a0a8963          	beqz	s5,80003f46 <readi+0xf0>
    80003e98:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e9a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e9e:	5c7d                	li	s8,-1
    80003ea0:	a82d                	j	80003eda <readi+0x84>
    80003ea2:	020d1d93          	slli	s11,s10,0x20
    80003ea6:	020ddd93          	srli	s11,s11,0x20
    80003eaa:	05890613          	addi	a2,s2,88
    80003eae:	86ee                	mv	a3,s11
    80003eb0:	963a                	add	a2,a2,a4
    80003eb2:	85d2                	mv	a1,s4
    80003eb4:	855e                	mv	a0,s7
    80003eb6:	fffff097          	auipc	ra,0xfffff
    80003eba:	81c080e7          	jalr	-2020(ra) # 800026d2 <either_copyout>
    80003ebe:	05850d63          	beq	a0,s8,80003f18 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ec2:	854a                	mv	a0,s2
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	5fe080e7          	jalr	1534(ra) # 800034c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ecc:	013d09bb          	addw	s3,s10,s3
    80003ed0:	009d04bb          	addw	s1,s10,s1
    80003ed4:	9a6e                	add	s4,s4,s11
    80003ed6:	0559f763          	bgeu	s3,s5,80003f24 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003eda:	00a4d59b          	srliw	a1,s1,0xa
    80003ede:	855a                	mv	a0,s6
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	8a4080e7          	jalr	-1884(ra) # 80003784 <bmap>
    80003ee8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003eec:	cd85                	beqz	a1,80003f24 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003eee:	000b2503          	lw	a0,0(s6)
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	4a0080e7          	jalr	1184(ra) # 80003392 <bread>
    80003efa:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003efc:	3ff4f713          	andi	a4,s1,1023
    80003f00:	40ec87bb          	subw	a5,s9,a4
    80003f04:	413a86bb          	subw	a3,s5,s3
    80003f08:	8d3e                	mv	s10,a5
    80003f0a:	2781                	sext.w	a5,a5
    80003f0c:	0006861b          	sext.w	a2,a3
    80003f10:	f8f679e3          	bgeu	a2,a5,80003ea2 <readi+0x4c>
    80003f14:	8d36                	mv	s10,a3
    80003f16:	b771                	j	80003ea2 <readi+0x4c>
      brelse(bp);
    80003f18:	854a                	mv	a0,s2
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	5a8080e7          	jalr	1448(ra) # 800034c2 <brelse>
      tot = -1;
    80003f22:	59fd                	li	s3,-1
  }
  return tot;
    80003f24:	0009851b          	sext.w	a0,s3
}
    80003f28:	70a6                	ld	ra,104(sp)
    80003f2a:	7406                	ld	s0,96(sp)
    80003f2c:	64e6                	ld	s1,88(sp)
    80003f2e:	6946                	ld	s2,80(sp)
    80003f30:	69a6                	ld	s3,72(sp)
    80003f32:	6a06                	ld	s4,64(sp)
    80003f34:	7ae2                	ld	s5,56(sp)
    80003f36:	7b42                	ld	s6,48(sp)
    80003f38:	7ba2                	ld	s7,40(sp)
    80003f3a:	7c02                	ld	s8,32(sp)
    80003f3c:	6ce2                	ld	s9,24(sp)
    80003f3e:	6d42                	ld	s10,16(sp)
    80003f40:	6da2                	ld	s11,8(sp)
    80003f42:	6165                	addi	sp,sp,112
    80003f44:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f46:	89d6                	mv	s3,s5
    80003f48:	bff1                	j	80003f24 <readi+0xce>
    return 0;
    80003f4a:	4501                	li	a0,0
}
    80003f4c:	8082                	ret

0000000080003f4e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f4e:	457c                	lw	a5,76(a0)
    80003f50:	10d7e863          	bltu	a5,a3,80004060 <writei+0x112>
{
    80003f54:	7159                	addi	sp,sp,-112
    80003f56:	f486                	sd	ra,104(sp)
    80003f58:	f0a2                	sd	s0,96(sp)
    80003f5a:	eca6                	sd	s1,88(sp)
    80003f5c:	e8ca                	sd	s2,80(sp)
    80003f5e:	e4ce                	sd	s3,72(sp)
    80003f60:	e0d2                	sd	s4,64(sp)
    80003f62:	fc56                	sd	s5,56(sp)
    80003f64:	f85a                	sd	s6,48(sp)
    80003f66:	f45e                	sd	s7,40(sp)
    80003f68:	f062                	sd	s8,32(sp)
    80003f6a:	ec66                	sd	s9,24(sp)
    80003f6c:	e86a                	sd	s10,16(sp)
    80003f6e:	e46e                	sd	s11,8(sp)
    80003f70:	1880                	addi	s0,sp,112
    80003f72:	8aaa                	mv	s5,a0
    80003f74:	8bae                	mv	s7,a1
    80003f76:	8a32                	mv	s4,a2
    80003f78:	8936                	mv	s2,a3
    80003f7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f7c:	00e687bb          	addw	a5,a3,a4
    80003f80:	0ed7e263          	bltu	a5,a3,80004064 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f84:	00043737          	lui	a4,0x43
    80003f88:	0ef76063          	bltu	a4,a5,80004068 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f8c:	0c0b0863          	beqz	s6,8000405c <writei+0x10e>
    80003f90:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f92:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f96:	5c7d                	li	s8,-1
    80003f98:	a091                	j	80003fdc <writei+0x8e>
    80003f9a:	020d1d93          	slli	s11,s10,0x20
    80003f9e:	020ddd93          	srli	s11,s11,0x20
    80003fa2:	05848513          	addi	a0,s1,88
    80003fa6:	86ee                	mv	a3,s11
    80003fa8:	8652                	mv	a2,s4
    80003faa:	85de                	mv	a1,s7
    80003fac:	953a                	add	a0,a0,a4
    80003fae:	ffffe097          	auipc	ra,0xffffe
    80003fb2:	77a080e7          	jalr	1914(ra) # 80002728 <either_copyin>
    80003fb6:	07850263          	beq	a0,s8,8000401a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003fba:	8526                	mv	a0,s1
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	75e080e7          	jalr	1886(ra) # 8000471a <log_write>
    brelse(bp);
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	fffff097          	auipc	ra,0xfffff
    80003fca:	4fc080e7          	jalr	1276(ra) # 800034c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fce:	013d09bb          	addw	s3,s10,s3
    80003fd2:	012d093b          	addw	s2,s10,s2
    80003fd6:	9a6e                	add	s4,s4,s11
    80003fd8:	0569f663          	bgeu	s3,s6,80004024 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003fdc:	00a9559b          	srliw	a1,s2,0xa
    80003fe0:	8556                	mv	a0,s5
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	7a2080e7          	jalr	1954(ra) # 80003784 <bmap>
    80003fea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fee:	c99d                	beqz	a1,80004024 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ff0:	000aa503          	lw	a0,0(s5)
    80003ff4:	fffff097          	auipc	ra,0xfffff
    80003ff8:	39e080e7          	jalr	926(ra) # 80003392 <bread>
    80003ffc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ffe:	3ff97713          	andi	a4,s2,1023
    80004002:	40ec87bb          	subw	a5,s9,a4
    80004006:	413b06bb          	subw	a3,s6,s3
    8000400a:	8d3e                	mv	s10,a5
    8000400c:	2781                	sext.w	a5,a5
    8000400e:	0006861b          	sext.w	a2,a3
    80004012:	f8f674e3          	bgeu	a2,a5,80003f9a <writei+0x4c>
    80004016:	8d36                	mv	s10,a3
    80004018:	b749                	j	80003f9a <writei+0x4c>
      brelse(bp);
    8000401a:	8526                	mv	a0,s1
    8000401c:	fffff097          	auipc	ra,0xfffff
    80004020:	4a6080e7          	jalr	1190(ra) # 800034c2 <brelse>
  }

  if(off > ip->size)
    80004024:	04caa783          	lw	a5,76(s5)
    80004028:	0127f463          	bgeu	a5,s2,80004030 <writei+0xe2>
    ip->size = off;
    8000402c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004030:	8556                	mv	a0,s5
    80004032:	00000097          	auipc	ra,0x0
    80004036:	aa4080e7          	jalr	-1372(ra) # 80003ad6 <iupdate>

  return tot;
    8000403a:	0009851b          	sext.w	a0,s3
}
    8000403e:	70a6                	ld	ra,104(sp)
    80004040:	7406                	ld	s0,96(sp)
    80004042:	64e6                	ld	s1,88(sp)
    80004044:	6946                	ld	s2,80(sp)
    80004046:	69a6                	ld	s3,72(sp)
    80004048:	6a06                	ld	s4,64(sp)
    8000404a:	7ae2                	ld	s5,56(sp)
    8000404c:	7b42                	ld	s6,48(sp)
    8000404e:	7ba2                	ld	s7,40(sp)
    80004050:	7c02                	ld	s8,32(sp)
    80004052:	6ce2                	ld	s9,24(sp)
    80004054:	6d42                	ld	s10,16(sp)
    80004056:	6da2                	ld	s11,8(sp)
    80004058:	6165                	addi	sp,sp,112
    8000405a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000405c:	89da                	mv	s3,s6
    8000405e:	bfc9                	j	80004030 <writei+0xe2>
    return -1;
    80004060:	557d                	li	a0,-1
}
    80004062:	8082                	ret
    return -1;
    80004064:	557d                	li	a0,-1
    80004066:	bfe1                	j	8000403e <writei+0xf0>
    return -1;
    80004068:	557d                	li	a0,-1
    8000406a:	bfd1                	j	8000403e <writei+0xf0>

000000008000406c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000406c:	1141                	addi	sp,sp,-16
    8000406e:	e406                	sd	ra,8(sp)
    80004070:	e022                	sd	s0,0(sp)
    80004072:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004074:	4639                	li	a2,14
    80004076:	ffffd097          	auipc	ra,0xffffd
    8000407a:	df0080e7          	jalr	-528(ra) # 80000e66 <strncmp>
}
    8000407e:	60a2                	ld	ra,8(sp)
    80004080:	6402                	ld	s0,0(sp)
    80004082:	0141                	addi	sp,sp,16
    80004084:	8082                	ret

0000000080004086 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004086:	7139                	addi	sp,sp,-64
    80004088:	fc06                	sd	ra,56(sp)
    8000408a:	f822                	sd	s0,48(sp)
    8000408c:	f426                	sd	s1,40(sp)
    8000408e:	f04a                	sd	s2,32(sp)
    80004090:	ec4e                	sd	s3,24(sp)
    80004092:	e852                	sd	s4,16(sp)
    80004094:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004096:	04451703          	lh	a4,68(a0)
    8000409a:	4785                	li	a5,1
    8000409c:	00f71a63          	bne	a4,a5,800040b0 <dirlookup+0x2a>
    800040a0:	892a                	mv	s2,a0
    800040a2:	89ae                	mv	s3,a1
    800040a4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040a6:	457c                	lw	a5,76(a0)
    800040a8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040aa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ac:	e79d                	bnez	a5,800040da <dirlookup+0x54>
    800040ae:	a8a5                	j	80004126 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040b0:	00004517          	auipc	a0,0x4
    800040b4:	6b050513          	addi	a0,a0,1712 # 80008760 <syscalls+0x1e8>
    800040b8:	ffffc097          	auipc	ra,0xffffc
    800040bc:	484080e7          	jalr	1156(ra) # 8000053c <panic>
      panic("dirlookup read");
    800040c0:	00004517          	auipc	a0,0x4
    800040c4:	6b850513          	addi	a0,a0,1720 # 80008778 <syscalls+0x200>
    800040c8:	ffffc097          	auipc	ra,0xffffc
    800040cc:	474080e7          	jalr	1140(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d0:	24c1                	addiw	s1,s1,16
    800040d2:	04c92783          	lw	a5,76(s2)
    800040d6:	04f4f763          	bgeu	s1,a5,80004124 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040da:	4741                	li	a4,16
    800040dc:	86a6                	mv	a3,s1
    800040de:	fc040613          	addi	a2,s0,-64
    800040e2:	4581                	li	a1,0
    800040e4:	854a                	mv	a0,s2
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	d70080e7          	jalr	-656(ra) # 80003e56 <readi>
    800040ee:	47c1                	li	a5,16
    800040f0:	fcf518e3          	bne	a0,a5,800040c0 <dirlookup+0x3a>
    if(de.inum == 0)
    800040f4:	fc045783          	lhu	a5,-64(s0)
    800040f8:	dfe1                	beqz	a5,800040d0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040fa:	fc240593          	addi	a1,s0,-62
    800040fe:	854e                	mv	a0,s3
    80004100:	00000097          	auipc	ra,0x0
    80004104:	f6c080e7          	jalr	-148(ra) # 8000406c <namecmp>
    80004108:	f561                	bnez	a0,800040d0 <dirlookup+0x4a>
      if(poff)
    8000410a:	000a0463          	beqz	s4,80004112 <dirlookup+0x8c>
        *poff = off;
    8000410e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004112:	fc045583          	lhu	a1,-64(s0)
    80004116:	00092503          	lw	a0,0(s2)
    8000411a:	fffff097          	auipc	ra,0xfffff
    8000411e:	754080e7          	jalr	1876(ra) # 8000386e <iget>
    80004122:	a011                	j	80004126 <dirlookup+0xa0>
  return 0;
    80004124:	4501                	li	a0,0
}
    80004126:	70e2                	ld	ra,56(sp)
    80004128:	7442                	ld	s0,48(sp)
    8000412a:	74a2                	ld	s1,40(sp)
    8000412c:	7902                	ld	s2,32(sp)
    8000412e:	69e2                	ld	s3,24(sp)
    80004130:	6a42                	ld	s4,16(sp)
    80004132:	6121                	addi	sp,sp,64
    80004134:	8082                	ret

0000000080004136 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004136:	711d                	addi	sp,sp,-96
    80004138:	ec86                	sd	ra,88(sp)
    8000413a:	e8a2                	sd	s0,80(sp)
    8000413c:	e4a6                	sd	s1,72(sp)
    8000413e:	e0ca                	sd	s2,64(sp)
    80004140:	fc4e                	sd	s3,56(sp)
    80004142:	f852                	sd	s4,48(sp)
    80004144:	f456                	sd	s5,40(sp)
    80004146:	f05a                	sd	s6,32(sp)
    80004148:	ec5e                	sd	s7,24(sp)
    8000414a:	e862                	sd	s8,16(sp)
    8000414c:	e466                	sd	s9,8(sp)
    8000414e:	1080                	addi	s0,sp,96
    80004150:	84aa                	mv	s1,a0
    80004152:	8b2e                	mv	s6,a1
    80004154:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004156:	00054703          	lbu	a4,0(a0)
    8000415a:	02f00793          	li	a5,47
    8000415e:	02f70263          	beq	a4,a5,80004182 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004162:	ffffe097          	auipc	ra,0xffffe
    80004166:	a00080e7          	jalr	-1536(ra) # 80001b62 <myproc>
    8000416a:	15053503          	ld	a0,336(a0)
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	9f6080e7          	jalr	-1546(ra) # 80003b64 <idup>
    80004176:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004178:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000417c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000417e:	4b85                	li	s7,1
    80004180:	a875                	j	8000423c <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004182:	4585                	li	a1,1
    80004184:	4505                	li	a0,1
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	6e8080e7          	jalr	1768(ra) # 8000386e <iget>
    8000418e:	8a2a                	mv	s4,a0
    80004190:	b7e5                	j	80004178 <namex+0x42>
      iunlockput(ip);
    80004192:	8552                	mv	a0,s4
    80004194:	00000097          	auipc	ra,0x0
    80004198:	c70080e7          	jalr	-912(ra) # 80003e04 <iunlockput>
      return 0;
    8000419c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000419e:	8552                	mv	a0,s4
    800041a0:	60e6                	ld	ra,88(sp)
    800041a2:	6446                	ld	s0,80(sp)
    800041a4:	64a6                	ld	s1,72(sp)
    800041a6:	6906                	ld	s2,64(sp)
    800041a8:	79e2                	ld	s3,56(sp)
    800041aa:	7a42                	ld	s4,48(sp)
    800041ac:	7aa2                	ld	s5,40(sp)
    800041ae:	7b02                	ld	s6,32(sp)
    800041b0:	6be2                	ld	s7,24(sp)
    800041b2:	6c42                	ld	s8,16(sp)
    800041b4:	6ca2                	ld	s9,8(sp)
    800041b6:	6125                	addi	sp,sp,96
    800041b8:	8082                	ret
      iunlock(ip);
    800041ba:	8552                	mv	a0,s4
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	aa8080e7          	jalr	-1368(ra) # 80003c64 <iunlock>
      return ip;
    800041c4:	bfe9                	j	8000419e <namex+0x68>
      iunlockput(ip);
    800041c6:	8552                	mv	a0,s4
    800041c8:	00000097          	auipc	ra,0x0
    800041cc:	c3c080e7          	jalr	-964(ra) # 80003e04 <iunlockput>
      return 0;
    800041d0:	8a4e                	mv	s4,s3
    800041d2:	b7f1                	j	8000419e <namex+0x68>
  len = path - s;
    800041d4:	40998633          	sub	a2,s3,s1
    800041d8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800041dc:	099c5863          	bge	s8,s9,8000426c <namex+0x136>
    memmove(name, s, DIRSIZ);
    800041e0:	4639                	li	a2,14
    800041e2:	85a6                	mv	a1,s1
    800041e4:	8556                	mv	a0,s5
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	c0c080e7          	jalr	-1012(ra) # 80000df2 <memmove>
    800041ee:	84ce                	mv	s1,s3
  while(*path == '/')
    800041f0:	0004c783          	lbu	a5,0(s1)
    800041f4:	01279763          	bne	a5,s2,80004202 <namex+0xcc>
    path++;
    800041f8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041fa:	0004c783          	lbu	a5,0(s1)
    800041fe:	ff278de3          	beq	a5,s2,800041f8 <namex+0xc2>
    ilock(ip);
    80004202:	8552                	mv	a0,s4
    80004204:	00000097          	auipc	ra,0x0
    80004208:	99e080e7          	jalr	-1634(ra) # 80003ba2 <ilock>
    if(ip->type != T_DIR){
    8000420c:	044a1783          	lh	a5,68(s4)
    80004210:	f97791e3          	bne	a5,s7,80004192 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004214:	000b0563          	beqz	s6,8000421e <namex+0xe8>
    80004218:	0004c783          	lbu	a5,0(s1)
    8000421c:	dfd9                	beqz	a5,800041ba <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000421e:	4601                	li	a2,0
    80004220:	85d6                	mv	a1,s5
    80004222:	8552                	mv	a0,s4
    80004224:	00000097          	auipc	ra,0x0
    80004228:	e62080e7          	jalr	-414(ra) # 80004086 <dirlookup>
    8000422c:	89aa                	mv	s3,a0
    8000422e:	dd41                	beqz	a0,800041c6 <namex+0x90>
    iunlockput(ip);
    80004230:	8552                	mv	a0,s4
    80004232:	00000097          	auipc	ra,0x0
    80004236:	bd2080e7          	jalr	-1070(ra) # 80003e04 <iunlockput>
    ip = next;
    8000423a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000423c:	0004c783          	lbu	a5,0(s1)
    80004240:	01279763          	bne	a5,s2,8000424e <namex+0x118>
    path++;
    80004244:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004246:	0004c783          	lbu	a5,0(s1)
    8000424a:	ff278de3          	beq	a5,s2,80004244 <namex+0x10e>
  if(*path == 0)
    8000424e:	cb9d                	beqz	a5,80004284 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004250:	0004c783          	lbu	a5,0(s1)
    80004254:	89a6                	mv	s3,s1
  len = path - s;
    80004256:	4c81                	li	s9,0
    80004258:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000425a:	01278963          	beq	a5,s2,8000426c <namex+0x136>
    8000425e:	dbbd                	beqz	a5,800041d4 <namex+0x9e>
    path++;
    80004260:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004262:	0009c783          	lbu	a5,0(s3)
    80004266:	ff279ce3          	bne	a5,s2,8000425e <namex+0x128>
    8000426a:	b7ad                	j	800041d4 <namex+0x9e>
    memmove(name, s, len);
    8000426c:	2601                	sext.w	a2,a2
    8000426e:	85a6                	mv	a1,s1
    80004270:	8556                	mv	a0,s5
    80004272:	ffffd097          	auipc	ra,0xffffd
    80004276:	b80080e7          	jalr	-1152(ra) # 80000df2 <memmove>
    name[len] = 0;
    8000427a:	9cd6                	add	s9,s9,s5
    8000427c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004280:	84ce                	mv	s1,s3
    80004282:	b7bd                	j	800041f0 <namex+0xba>
  if(nameiparent){
    80004284:	f00b0de3          	beqz	s6,8000419e <namex+0x68>
    iput(ip);
    80004288:	8552                	mv	a0,s4
    8000428a:	00000097          	auipc	ra,0x0
    8000428e:	ad2080e7          	jalr	-1326(ra) # 80003d5c <iput>
    return 0;
    80004292:	4a01                	li	s4,0
    80004294:	b729                	j	8000419e <namex+0x68>

0000000080004296 <dirlink>:
{
    80004296:	7139                	addi	sp,sp,-64
    80004298:	fc06                	sd	ra,56(sp)
    8000429a:	f822                	sd	s0,48(sp)
    8000429c:	f426                	sd	s1,40(sp)
    8000429e:	f04a                	sd	s2,32(sp)
    800042a0:	ec4e                	sd	s3,24(sp)
    800042a2:	e852                	sd	s4,16(sp)
    800042a4:	0080                	addi	s0,sp,64
    800042a6:	892a                	mv	s2,a0
    800042a8:	8a2e                	mv	s4,a1
    800042aa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042ac:	4601                	li	a2,0
    800042ae:	00000097          	auipc	ra,0x0
    800042b2:	dd8080e7          	jalr	-552(ra) # 80004086 <dirlookup>
    800042b6:	e93d                	bnez	a0,8000432c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042b8:	04c92483          	lw	s1,76(s2)
    800042bc:	c49d                	beqz	s1,800042ea <dirlink+0x54>
    800042be:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042c0:	4741                	li	a4,16
    800042c2:	86a6                	mv	a3,s1
    800042c4:	fc040613          	addi	a2,s0,-64
    800042c8:	4581                	li	a1,0
    800042ca:	854a                	mv	a0,s2
    800042cc:	00000097          	auipc	ra,0x0
    800042d0:	b8a080e7          	jalr	-1142(ra) # 80003e56 <readi>
    800042d4:	47c1                	li	a5,16
    800042d6:	06f51163          	bne	a0,a5,80004338 <dirlink+0xa2>
    if(de.inum == 0)
    800042da:	fc045783          	lhu	a5,-64(s0)
    800042de:	c791                	beqz	a5,800042ea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042e0:	24c1                	addiw	s1,s1,16
    800042e2:	04c92783          	lw	a5,76(s2)
    800042e6:	fcf4ede3          	bltu	s1,a5,800042c0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042ea:	4639                	li	a2,14
    800042ec:	85d2                	mv	a1,s4
    800042ee:	fc240513          	addi	a0,s0,-62
    800042f2:	ffffd097          	auipc	ra,0xffffd
    800042f6:	bb0080e7          	jalr	-1104(ra) # 80000ea2 <strncpy>
  de.inum = inum;
    800042fa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042fe:	4741                	li	a4,16
    80004300:	86a6                	mv	a3,s1
    80004302:	fc040613          	addi	a2,s0,-64
    80004306:	4581                	li	a1,0
    80004308:	854a                	mv	a0,s2
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	c44080e7          	jalr	-956(ra) # 80003f4e <writei>
    80004312:	1541                	addi	a0,a0,-16
    80004314:	00a03533          	snez	a0,a0
    80004318:	40a00533          	neg	a0,a0
}
    8000431c:	70e2                	ld	ra,56(sp)
    8000431e:	7442                	ld	s0,48(sp)
    80004320:	74a2                	ld	s1,40(sp)
    80004322:	7902                	ld	s2,32(sp)
    80004324:	69e2                	ld	s3,24(sp)
    80004326:	6a42                	ld	s4,16(sp)
    80004328:	6121                	addi	sp,sp,64
    8000432a:	8082                	ret
    iput(ip);
    8000432c:	00000097          	auipc	ra,0x0
    80004330:	a30080e7          	jalr	-1488(ra) # 80003d5c <iput>
    return -1;
    80004334:	557d                	li	a0,-1
    80004336:	b7dd                	j	8000431c <dirlink+0x86>
      panic("dirlink read");
    80004338:	00004517          	auipc	a0,0x4
    8000433c:	45050513          	addi	a0,a0,1104 # 80008788 <syscalls+0x210>
    80004340:	ffffc097          	auipc	ra,0xffffc
    80004344:	1fc080e7          	jalr	508(ra) # 8000053c <panic>

0000000080004348 <namei>:

struct inode*
namei(char *path)
{
    80004348:	1101                	addi	sp,sp,-32
    8000434a:	ec06                	sd	ra,24(sp)
    8000434c:	e822                	sd	s0,16(sp)
    8000434e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004350:	fe040613          	addi	a2,s0,-32
    80004354:	4581                	li	a1,0
    80004356:	00000097          	auipc	ra,0x0
    8000435a:	de0080e7          	jalr	-544(ra) # 80004136 <namex>
}
    8000435e:	60e2                	ld	ra,24(sp)
    80004360:	6442                	ld	s0,16(sp)
    80004362:	6105                	addi	sp,sp,32
    80004364:	8082                	ret

0000000080004366 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004366:	1141                	addi	sp,sp,-16
    80004368:	e406                	sd	ra,8(sp)
    8000436a:	e022                	sd	s0,0(sp)
    8000436c:	0800                	addi	s0,sp,16
    8000436e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004370:	4585                	li	a1,1
    80004372:	00000097          	auipc	ra,0x0
    80004376:	dc4080e7          	jalr	-572(ra) # 80004136 <namex>
}
    8000437a:	60a2                	ld	ra,8(sp)
    8000437c:	6402                	ld	s0,0(sp)
    8000437e:	0141                	addi	sp,sp,16
    80004380:	8082                	ret

0000000080004382 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004382:	1101                	addi	sp,sp,-32
    80004384:	ec06                	sd	ra,24(sp)
    80004386:	e822                	sd	s0,16(sp)
    80004388:	e426                	sd	s1,8(sp)
    8000438a:	e04a                	sd	s2,0(sp)
    8000438c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000438e:	0001d917          	auipc	s2,0x1d
    80004392:	92290913          	addi	s2,s2,-1758 # 80020cb0 <log>
    80004396:	01892583          	lw	a1,24(s2)
    8000439a:	02892503          	lw	a0,40(s2)
    8000439e:	fffff097          	auipc	ra,0xfffff
    800043a2:	ff4080e7          	jalr	-12(ra) # 80003392 <bread>
    800043a6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043a8:	02c92603          	lw	a2,44(s2)
    800043ac:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043ae:	00c05f63          	blez	a2,800043cc <write_head+0x4a>
    800043b2:	0001d717          	auipc	a4,0x1d
    800043b6:	92e70713          	addi	a4,a4,-1746 # 80020ce0 <log+0x30>
    800043ba:	87aa                	mv	a5,a0
    800043bc:	060a                	slli	a2,a2,0x2
    800043be:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800043c0:	4314                	lw	a3,0(a4)
    800043c2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800043c4:	0711                	addi	a4,a4,4
    800043c6:	0791                	addi	a5,a5,4
    800043c8:	fec79ce3          	bne	a5,a2,800043c0 <write_head+0x3e>
  }
  bwrite(buf);
    800043cc:	8526                	mv	a0,s1
    800043ce:	fffff097          	auipc	ra,0xfffff
    800043d2:	0b6080e7          	jalr	182(ra) # 80003484 <bwrite>
  brelse(buf);
    800043d6:	8526                	mv	a0,s1
    800043d8:	fffff097          	auipc	ra,0xfffff
    800043dc:	0ea080e7          	jalr	234(ra) # 800034c2 <brelse>
}
    800043e0:	60e2                	ld	ra,24(sp)
    800043e2:	6442                	ld	s0,16(sp)
    800043e4:	64a2                	ld	s1,8(sp)
    800043e6:	6902                	ld	s2,0(sp)
    800043e8:	6105                	addi	sp,sp,32
    800043ea:	8082                	ret

00000000800043ec <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043ec:	0001d797          	auipc	a5,0x1d
    800043f0:	8f07a783          	lw	a5,-1808(a5) # 80020cdc <log+0x2c>
    800043f4:	0af05d63          	blez	a5,800044ae <install_trans+0xc2>
{
    800043f8:	7139                	addi	sp,sp,-64
    800043fa:	fc06                	sd	ra,56(sp)
    800043fc:	f822                	sd	s0,48(sp)
    800043fe:	f426                	sd	s1,40(sp)
    80004400:	f04a                	sd	s2,32(sp)
    80004402:	ec4e                	sd	s3,24(sp)
    80004404:	e852                	sd	s4,16(sp)
    80004406:	e456                	sd	s5,8(sp)
    80004408:	e05a                	sd	s6,0(sp)
    8000440a:	0080                	addi	s0,sp,64
    8000440c:	8b2a                	mv	s6,a0
    8000440e:	0001da97          	auipc	s5,0x1d
    80004412:	8d2a8a93          	addi	s5,s5,-1838 # 80020ce0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004416:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004418:	0001d997          	auipc	s3,0x1d
    8000441c:	89898993          	addi	s3,s3,-1896 # 80020cb0 <log>
    80004420:	a00d                	j	80004442 <install_trans+0x56>
    brelse(lbuf);
    80004422:	854a                	mv	a0,s2
    80004424:	fffff097          	auipc	ra,0xfffff
    80004428:	09e080e7          	jalr	158(ra) # 800034c2 <brelse>
    brelse(dbuf);
    8000442c:	8526                	mv	a0,s1
    8000442e:	fffff097          	auipc	ra,0xfffff
    80004432:	094080e7          	jalr	148(ra) # 800034c2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004436:	2a05                	addiw	s4,s4,1
    80004438:	0a91                	addi	s5,s5,4
    8000443a:	02c9a783          	lw	a5,44(s3)
    8000443e:	04fa5e63          	bge	s4,a5,8000449a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004442:	0189a583          	lw	a1,24(s3)
    80004446:	014585bb          	addw	a1,a1,s4
    8000444a:	2585                	addiw	a1,a1,1
    8000444c:	0289a503          	lw	a0,40(s3)
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	f42080e7          	jalr	-190(ra) # 80003392 <bread>
    80004458:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000445a:	000aa583          	lw	a1,0(s5)
    8000445e:	0289a503          	lw	a0,40(s3)
    80004462:	fffff097          	auipc	ra,0xfffff
    80004466:	f30080e7          	jalr	-208(ra) # 80003392 <bread>
    8000446a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000446c:	40000613          	li	a2,1024
    80004470:	05890593          	addi	a1,s2,88
    80004474:	05850513          	addi	a0,a0,88
    80004478:	ffffd097          	auipc	ra,0xffffd
    8000447c:	97a080e7          	jalr	-1670(ra) # 80000df2 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004480:	8526                	mv	a0,s1
    80004482:	fffff097          	auipc	ra,0xfffff
    80004486:	002080e7          	jalr	2(ra) # 80003484 <bwrite>
    if(recovering == 0)
    8000448a:	f80b1ce3          	bnez	s6,80004422 <install_trans+0x36>
      bunpin(dbuf);
    8000448e:	8526                	mv	a0,s1
    80004490:	fffff097          	auipc	ra,0xfffff
    80004494:	10a080e7          	jalr	266(ra) # 8000359a <bunpin>
    80004498:	b769                	j	80004422 <install_trans+0x36>
}
    8000449a:	70e2                	ld	ra,56(sp)
    8000449c:	7442                	ld	s0,48(sp)
    8000449e:	74a2                	ld	s1,40(sp)
    800044a0:	7902                	ld	s2,32(sp)
    800044a2:	69e2                	ld	s3,24(sp)
    800044a4:	6a42                	ld	s4,16(sp)
    800044a6:	6aa2                	ld	s5,8(sp)
    800044a8:	6b02                	ld	s6,0(sp)
    800044aa:	6121                	addi	sp,sp,64
    800044ac:	8082                	ret
    800044ae:	8082                	ret

00000000800044b0 <initlog>:
{
    800044b0:	7179                	addi	sp,sp,-48
    800044b2:	f406                	sd	ra,40(sp)
    800044b4:	f022                	sd	s0,32(sp)
    800044b6:	ec26                	sd	s1,24(sp)
    800044b8:	e84a                	sd	s2,16(sp)
    800044ba:	e44e                	sd	s3,8(sp)
    800044bc:	1800                	addi	s0,sp,48
    800044be:	892a                	mv	s2,a0
    800044c0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044c2:	0001c497          	auipc	s1,0x1c
    800044c6:	7ee48493          	addi	s1,s1,2030 # 80020cb0 <log>
    800044ca:	00004597          	auipc	a1,0x4
    800044ce:	2ce58593          	addi	a1,a1,718 # 80008798 <syscalls+0x220>
    800044d2:	8526                	mv	a0,s1
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	736080e7          	jalr	1846(ra) # 80000c0a <initlock>
  log.start = sb->logstart;
    800044dc:	0149a583          	lw	a1,20(s3)
    800044e0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044e2:	0109a783          	lw	a5,16(s3)
    800044e6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044e8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044ec:	854a                	mv	a0,s2
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	ea4080e7          	jalr	-348(ra) # 80003392 <bread>
  log.lh.n = lh->n;
    800044f6:	4d30                	lw	a2,88(a0)
    800044f8:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044fa:	00c05f63          	blez	a2,80004518 <initlog+0x68>
    800044fe:	87aa                	mv	a5,a0
    80004500:	0001c717          	auipc	a4,0x1c
    80004504:	7e070713          	addi	a4,a4,2016 # 80020ce0 <log+0x30>
    80004508:	060a                	slli	a2,a2,0x2
    8000450a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000450c:	4ff4                	lw	a3,92(a5)
    8000450e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004510:	0791                	addi	a5,a5,4
    80004512:	0711                	addi	a4,a4,4
    80004514:	fec79ce3          	bne	a5,a2,8000450c <initlog+0x5c>
  brelse(buf);
    80004518:	fffff097          	auipc	ra,0xfffff
    8000451c:	faa080e7          	jalr	-86(ra) # 800034c2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004520:	4505                	li	a0,1
    80004522:	00000097          	auipc	ra,0x0
    80004526:	eca080e7          	jalr	-310(ra) # 800043ec <install_trans>
  log.lh.n = 0;
    8000452a:	0001c797          	auipc	a5,0x1c
    8000452e:	7a07a923          	sw	zero,1970(a5) # 80020cdc <log+0x2c>
  write_head(); // clear the log
    80004532:	00000097          	auipc	ra,0x0
    80004536:	e50080e7          	jalr	-432(ra) # 80004382 <write_head>
}
    8000453a:	70a2                	ld	ra,40(sp)
    8000453c:	7402                	ld	s0,32(sp)
    8000453e:	64e2                	ld	s1,24(sp)
    80004540:	6942                	ld	s2,16(sp)
    80004542:	69a2                	ld	s3,8(sp)
    80004544:	6145                	addi	sp,sp,48
    80004546:	8082                	ret

0000000080004548 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004548:	1101                	addi	sp,sp,-32
    8000454a:	ec06                	sd	ra,24(sp)
    8000454c:	e822                	sd	s0,16(sp)
    8000454e:	e426                	sd	s1,8(sp)
    80004550:	e04a                	sd	s2,0(sp)
    80004552:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004554:	0001c517          	auipc	a0,0x1c
    80004558:	75c50513          	addi	a0,a0,1884 # 80020cb0 <log>
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	73e080e7          	jalr	1854(ra) # 80000c9a <acquire>
  while(1){
    if(log.committing){
    80004564:	0001c497          	auipc	s1,0x1c
    80004568:	74c48493          	addi	s1,s1,1868 # 80020cb0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000456c:	4979                	li	s2,30
    8000456e:	a039                	j	8000457c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004570:	85a6                	mv	a1,s1
    80004572:	8526                	mv	a0,s1
    80004574:	ffffe097          	auipc	ra,0xffffe
    80004578:	d56080e7          	jalr	-682(ra) # 800022ca <sleep>
    if(log.committing){
    8000457c:	50dc                	lw	a5,36(s1)
    8000457e:	fbed                	bnez	a5,80004570 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004580:	5098                	lw	a4,32(s1)
    80004582:	2705                	addiw	a4,a4,1
    80004584:	0027179b          	slliw	a5,a4,0x2
    80004588:	9fb9                	addw	a5,a5,a4
    8000458a:	0017979b          	slliw	a5,a5,0x1
    8000458e:	54d4                	lw	a3,44(s1)
    80004590:	9fb5                	addw	a5,a5,a3
    80004592:	00f95963          	bge	s2,a5,800045a4 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004596:	85a6                	mv	a1,s1
    80004598:	8526                	mv	a0,s1
    8000459a:	ffffe097          	auipc	ra,0xffffe
    8000459e:	d30080e7          	jalr	-720(ra) # 800022ca <sleep>
    800045a2:	bfe9                	j	8000457c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045a4:	0001c517          	auipc	a0,0x1c
    800045a8:	70c50513          	addi	a0,a0,1804 # 80020cb0 <log>
    800045ac:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	7a0080e7          	jalr	1952(ra) # 80000d4e <release>
      break;
    }
  }
}
    800045b6:	60e2                	ld	ra,24(sp)
    800045b8:	6442                	ld	s0,16(sp)
    800045ba:	64a2                	ld	s1,8(sp)
    800045bc:	6902                	ld	s2,0(sp)
    800045be:	6105                	addi	sp,sp,32
    800045c0:	8082                	ret

00000000800045c2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045c2:	7139                	addi	sp,sp,-64
    800045c4:	fc06                	sd	ra,56(sp)
    800045c6:	f822                	sd	s0,48(sp)
    800045c8:	f426                	sd	s1,40(sp)
    800045ca:	f04a                	sd	s2,32(sp)
    800045cc:	ec4e                	sd	s3,24(sp)
    800045ce:	e852                	sd	s4,16(sp)
    800045d0:	e456                	sd	s5,8(sp)
    800045d2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045d4:	0001c497          	auipc	s1,0x1c
    800045d8:	6dc48493          	addi	s1,s1,1756 # 80020cb0 <log>
    800045dc:	8526                	mv	a0,s1
    800045de:	ffffc097          	auipc	ra,0xffffc
    800045e2:	6bc080e7          	jalr	1724(ra) # 80000c9a <acquire>
  log.outstanding -= 1;
    800045e6:	509c                	lw	a5,32(s1)
    800045e8:	37fd                	addiw	a5,a5,-1
    800045ea:	0007891b          	sext.w	s2,a5
    800045ee:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045f0:	50dc                	lw	a5,36(s1)
    800045f2:	e7b9                	bnez	a5,80004640 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045f4:	04091e63          	bnez	s2,80004650 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800045f8:	0001c497          	auipc	s1,0x1c
    800045fc:	6b848493          	addi	s1,s1,1720 # 80020cb0 <log>
    80004600:	4785                	li	a5,1
    80004602:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004604:	8526                	mv	a0,s1
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	748080e7          	jalr	1864(ra) # 80000d4e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000460e:	54dc                	lw	a5,44(s1)
    80004610:	06f04763          	bgtz	a5,8000467e <end_op+0xbc>
    acquire(&log.lock);
    80004614:	0001c497          	auipc	s1,0x1c
    80004618:	69c48493          	addi	s1,s1,1692 # 80020cb0 <log>
    8000461c:	8526                	mv	a0,s1
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	67c080e7          	jalr	1660(ra) # 80000c9a <acquire>
    log.committing = 0;
    80004626:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000462a:	8526                	mv	a0,s1
    8000462c:	ffffe097          	auipc	ra,0xffffe
    80004630:	d02080e7          	jalr	-766(ra) # 8000232e <wakeup>
    release(&log.lock);
    80004634:	8526                	mv	a0,s1
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	718080e7          	jalr	1816(ra) # 80000d4e <release>
}
    8000463e:	a03d                	j	8000466c <end_op+0xaa>
    panic("log.committing");
    80004640:	00004517          	auipc	a0,0x4
    80004644:	16050513          	addi	a0,a0,352 # 800087a0 <syscalls+0x228>
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	ef4080e7          	jalr	-268(ra) # 8000053c <panic>
    wakeup(&log);
    80004650:	0001c497          	auipc	s1,0x1c
    80004654:	66048493          	addi	s1,s1,1632 # 80020cb0 <log>
    80004658:	8526                	mv	a0,s1
    8000465a:	ffffe097          	auipc	ra,0xffffe
    8000465e:	cd4080e7          	jalr	-812(ra) # 8000232e <wakeup>
  release(&log.lock);
    80004662:	8526                	mv	a0,s1
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	6ea080e7          	jalr	1770(ra) # 80000d4e <release>
}
    8000466c:	70e2                	ld	ra,56(sp)
    8000466e:	7442                	ld	s0,48(sp)
    80004670:	74a2                	ld	s1,40(sp)
    80004672:	7902                	ld	s2,32(sp)
    80004674:	69e2                	ld	s3,24(sp)
    80004676:	6a42                	ld	s4,16(sp)
    80004678:	6aa2                	ld	s5,8(sp)
    8000467a:	6121                	addi	sp,sp,64
    8000467c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000467e:	0001ca97          	auipc	s5,0x1c
    80004682:	662a8a93          	addi	s5,s5,1634 # 80020ce0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004686:	0001ca17          	auipc	s4,0x1c
    8000468a:	62aa0a13          	addi	s4,s4,1578 # 80020cb0 <log>
    8000468e:	018a2583          	lw	a1,24(s4)
    80004692:	012585bb          	addw	a1,a1,s2
    80004696:	2585                	addiw	a1,a1,1
    80004698:	028a2503          	lw	a0,40(s4)
    8000469c:	fffff097          	auipc	ra,0xfffff
    800046a0:	cf6080e7          	jalr	-778(ra) # 80003392 <bread>
    800046a4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800046a6:	000aa583          	lw	a1,0(s5)
    800046aa:	028a2503          	lw	a0,40(s4)
    800046ae:	fffff097          	auipc	ra,0xfffff
    800046b2:	ce4080e7          	jalr	-796(ra) # 80003392 <bread>
    800046b6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046b8:	40000613          	li	a2,1024
    800046bc:	05850593          	addi	a1,a0,88
    800046c0:	05848513          	addi	a0,s1,88
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	72e080e7          	jalr	1838(ra) # 80000df2 <memmove>
    bwrite(to);  // write the log
    800046cc:	8526                	mv	a0,s1
    800046ce:	fffff097          	auipc	ra,0xfffff
    800046d2:	db6080e7          	jalr	-586(ra) # 80003484 <bwrite>
    brelse(from);
    800046d6:	854e                	mv	a0,s3
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	dea080e7          	jalr	-534(ra) # 800034c2 <brelse>
    brelse(to);
    800046e0:	8526                	mv	a0,s1
    800046e2:	fffff097          	auipc	ra,0xfffff
    800046e6:	de0080e7          	jalr	-544(ra) # 800034c2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046ea:	2905                	addiw	s2,s2,1
    800046ec:	0a91                	addi	s5,s5,4
    800046ee:	02ca2783          	lw	a5,44(s4)
    800046f2:	f8f94ee3          	blt	s2,a5,8000468e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	c8c080e7          	jalr	-884(ra) # 80004382 <write_head>
    install_trans(0); // Now install writes to home locations
    800046fe:	4501                	li	a0,0
    80004700:	00000097          	auipc	ra,0x0
    80004704:	cec080e7          	jalr	-788(ra) # 800043ec <install_trans>
    log.lh.n = 0;
    80004708:	0001c797          	auipc	a5,0x1c
    8000470c:	5c07aa23          	sw	zero,1492(a5) # 80020cdc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004710:	00000097          	auipc	ra,0x0
    80004714:	c72080e7          	jalr	-910(ra) # 80004382 <write_head>
    80004718:	bdf5                	j	80004614 <end_op+0x52>

000000008000471a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000471a:	1101                	addi	sp,sp,-32
    8000471c:	ec06                	sd	ra,24(sp)
    8000471e:	e822                	sd	s0,16(sp)
    80004720:	e426                	sd	s1,8(sp)
    80004722:	e04a                	sd	s2,0(sp)
    80004724:	1000                	addi	s0,sp,32
    80004726:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004728:	0001c917          	auipc	s2,0x1c
    8000472c:	58890913          	addi	s2,s2,1416 # 80020cb0 <log>
    80004730:	854a                	mv	a0,s2
    80004732:	ffffc097          	auipc	ra,0xffffc
    80004736:	568080e7          	jalr	1384(ra) # 80000c9a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000473a:	02c92603          	lw	a2,44(s2)
    8000473e:	47f5                	li	a5,29
    80004740:	06c7c563          	blt	a5,a2,800047aa <log_write+0x90>
    80004744:	0001c797          	auipc	a5,0x1c
    80004748:	5887a783          	lw	a5,1416(a5) # 80020ccc <log+0x1c>
    8000474c:	37fd                	addiw	a5,a5,-1
    8000474e:	04f65e63          	bge	a2,a5,800047aa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004752:	0001c797          	auipc	a5,0x1c
    80004756:	57e7a783          	lw	a5,1406(a5) # 80020cd0 <log+0x20>
    8000475a:	06f05063          	blez	a5,800047ba <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000475e:	4781                	li	a5,0
    80004760:	06c05563          	blez	a2,800047ca <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004764:	44cc                	lw	a1,12(s1)
    80004766:	0001c717          	auipc	a4,0x1c
    8000476a:	57a70713          	addi	a4,a4,1402 # 80020ce0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000476e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004770:	4314                	lw	a3,0(a4)
    80004772:	04b68c63          	beq	a3,a1,800047ca <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004776:	2785                	addiw	a5,a5,1
    80004778:	0711                	addi	a4,a4,4
    8000477a:	fef61be3          	bne	a2,a5,80004770 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000477e:	0621                	addi	a2,a2,8
    80004780:	060a                	slli	a2,a2,0x2
    80004782:	0001c797          	auipc	a5,0x1c
    80004786:	52e78793          	addi	a5,a5,1326 # 80020cb0 <log>
    8000478a:	97b2                	add	a5,a5,a2
    8000478c:	44d8                	lw	a4,12(s1)
    8000478e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004790:	8526                	mv	a0,s1
    80004792:	fffff097          	auipc	ra,0xfffff
    80004796:	dcc080e7          	jalr	-564(ra) # 8000355e <bpin>
    log.lh.n++;
    8000479a:	0001c717          	auipc	a4,0x1c
    8000479e:	51670713          	addi	a4,a4,1302 # 80020cb0 <log>
    800047a2:	575c                	lw	a5,44(a4)
    800047a4:	2785                	addiw	a5,a5,1
    800047a6:	d75c                	sw	a5,44(a4)
    800047a8:	a82d                	j	800047e2 <log_write+0xc8>
    panic("too big a transaction");
    800047aa:	00004517          	auipc	a0,0x4
    800047ae:	00650513          	addi	a0,a0,6 # 800087b0 <syscalls+0x238>
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	d8a080e7          	jalr	-630(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800047ba:	00004517          	auipc	a0,0x4
    800047be:	00e50513          	addi	a0,a0,14 # 800087c8 <syscalls+0x250>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	d7a080e7          	jalr	-646(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800047ca:	00878693          	addi	a3,a5,8
    800047ce:	068a                	slli	a3,a3,0x2
    800047d0:	0001c717          	auipc	a4,0x1c
    800047d4:	4e070713          	addi	a4,a4,1248 # 80020cb0 <log>
    800047d8:	9736                	add	a4,a4,a3
    800047da:	44d4                	lw	a3,12(s1)
    800047dc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047de:	faf609e3          	beq	a2,a5,80004790 <log_write+0x76>
  }
  release(&log.lock);
    800047e2:	0001c517          	auipc	a0,0x1c
    800047e6:	4ce50513          	addi	a0,a0,1230 # 80020cb0 <log>
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	564080e7          	jalr	1380(ra) # 80000d4e <release>
}
    800047f2:	60e2                	ld	ra,24(sp)
    800047f4:	6442                	ld	s0,16(sp)
    800047f6:	64a2                	ld	s1,8(sp)
    800047f8:	6902                	ld	s2,0(sp)
    800047fa:	6105                	addi	sp,sp,32
    800047fc:	8082                	ret

00000000800047fe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047fe:	1101                	addi	sp,sp,-32
    80004800:	ec06                	sd	ra,24(sp)
    80004802:	e822                	sd	s0,16(sp)
    80004804:	e426                	sd	s1,8(sp)
    80004806:	e04a                	sd	s2,0(sp)
    80004808:	1000                	addi	s0,sp,32
    8000480a:	84aa                	mv	s1,a0
    8000480c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000480e:	00004597          	auipc	a1,0x4
    80004812:	fda58593          	addi	a1,a1,-38 # 800087e8 <syscalls+0x270>
    80004816:	0521                	addi	a0,a0,8
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	3f2080e7          	jalr	1010(ra) # 80000c0a <initlock>
  lk->name = name;
    80004820:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004824:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004828:	0204a423          	sw	zero,40(s1)
}
    8000482c:	60e2                	ld	ra,24(sp)
    8000482e:	6442                	ld	s0,16(sp)
    80004830:	64a2                	ld	s1,8(sp)
    80004832:	6902                	ld	s2,0(sp)
    80004834:	6105                	addi	sp,sp,32
    80004836:	8082                	ret

0000000080004838 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004838:	1101                	addi	sp,sp,-32
    8000483a:	ec06                	sd	ra,24(sp)
    8000483c:	e822                	sd	s0,16(sp)
    8000483e:	e426                	sd	s1,8(sp)
    80004840:	e04a                	sd	s2,0(sp)
    80004842:	1000                	addi	s0,sp,32
    80004844:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004846:	00850913          	addi	s2,a0,8
    8000484a:	854a                	mv	a0,s2
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	44e080e7          	jalr	1102(ra) # 80000c9a <acquire>
  while (lk->locked) {
    80004854:	409c                	lw	a5,0(s1)
    80004856:	cb89                	beqz	a5,80004868 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004858:	85ca                	mv	a1,s2
    8000485a:	8526                	mv	a0,s1
    8000485c:	ffffe097          	auipc	ra,0xffffe
    80004860:	a6e080e7          	jalr	-1426(ra) # 800022ca <sleep>
  while (lk->locked) {
    80004864:	409c                	lw	a5,0(s1)
    80004866:	fbed                	bnez	a5,80004858 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004868:	4785                	li	a5,1
    8000486a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000486c:	ffffd097          	auipc	ra,0xffffd
    80004870:	2f6080e7          	jalr	758(ra) # 80001b62 <myproc>
    80004874:	591c                	lw	a5,48(a0)
    80004876:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004878:	854a                	mv	a0,s2
    8000487a:	ffffc097          	auipc	ra,0xffffc
    8000487e:	4d4080e7          	jalr	1236(ra) # 80000d4e <release>
}
    80004882:	60e2                	ld	ra,24(sp)
    80004884:	6442                	ld	s0,16(sp)
    80004886:	64a2                	ld	s1,8(sp)
    80004888:	6902                	ld	s2,0(sp)
    8000488a:	6105                	addi	sp,sp,32
    8000488c:	8082                	ret

000000008000488e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000488e:	1101                	addi	sp,sp,-32
    80004890:	ec06                	sd	ra,24(sp)
    80004892:	e822                	sd	s0,16(sp)
    80004894:	e426                	sd	s1,8(sp)
    80004896:	e04a                	sd	s2,0(sp)
    80004898:	1000                	addi	s0,sp,32
    8000489a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000489c:	00850913          	addi	s2,a0,8
    800048a0:	854a                	mv	a0,s2
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	3f8080e7          	jalr	1016(ra) # 80000c9a <acquire>
  lk->locked = 0;
    800048aa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048ae:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048b2:	8526                	mv	a0,s1
    800048b4:	ffffe097          	auipc	ra,0xffffe
    800048b8:	a7a080e7          	jalr	-1414(ra) # 8000232e <wakeup>
  release(&lk->lk);
    800048bc:	854a                	mv	a0,s2
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	490080e7          	jalr	1168(ra) # 80000d4e <release>
}
    800048c6:	60e2                	ld	ra,24(sp)
    800048c8:	6442                	ld	s0,16(sp)
    800048ca:	64a2                	ld	s1,8(sp)
    800048cc:	6902                	ld	s2,0(sp)
    800048ce:	6105                	addi	sp,sp,32
    800048d0:	8082                	ret

00000000800048d2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048d2:	7179                	addi	sp,sp,-48
    800048d4:	f406                	sd	ra,40(sp)
    800048d6:	f022                	sd	s0,32(sp)
    800048d8:	ec26                	sd	s1,24(sp)
    800048da:	e84a                	sd	s2,16(sp)
    800048dc:	e44e                	sd	s3,8(sp)
    800048de:	1800                	addi	s0,sp,48
    800048e0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048e2:	00850913          	addi	s2,a0,8
    800048e6:	854a                	mv	a0,s2
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	3b2080e7          	jalr	946(ra) # 80000c9a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048f0:	409c                	lw	a5,0(s1)
    800048f2:	ef99                	bnez	a5,80004910 <holdingsleep+0x3e>
    800048f4:	4481                	li	s1,0
  release(&lk->lk);
    800048f6:	854a                	mv	a0,s2
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	456080e7          	jalr	1110(ra) # 80000d4e <release>
  return r;
}
    80004900:	8526                	mv	a0,s1
    80004902:	70a2                	ld	ra,40(sp)
    80004904:	7402                	ld	s0,32(sp)
    80004906:	64e2                	ld	s1,24(sp)
    80004908:	6942                	ld	s2,16(sp)
    8000490a:	69a2                	ld	s3,8(sp)
    8000490c:	6145                	addi	sp,sp,48
    8000490e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004910:	0284a983          	lw	s3,40(s1)
    80004914:	ffffd097          	auipc	ra,0xffffd
    80004918:	24e080e7          	jalr	590(ra) # 80001b62 <myproc>
    8000491c:	5904                	lw	s1,48(a0)
    8000491e:	413484b3          	sub	s1,s1,s3
    80004922:	0014b493          	seqz	s1,s1
    80004926:	bfc1                	j	800048f6 <holdingsleep+0x24>

0000000080004928 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004928:	1141                	addi	sp,sp,-16
    8000492a:	e406                	sd	ra,8(sp)
    8000492c:	e022                	sd	s0,0(sp)
    8000492e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004930:	00004597          	auipc	a1,0x4
    80004934:	ec858593          	addi	a1,a1,-312 # 800087f8 <syscalls+0x280>
    80004938:	0001c517          	auipc	a0,0x1c
    8000493c:	4c050513          	addi	a0,a0,1216 # 80020df8 <ftable>
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	2ca080e7          	jalr	714(ra) # 80000c0a <initlock>
}
    80004948:	60a2                	ld	ra,8(sp)
    8000494a:	6402                	ld	s0,0(sp)
    8000494c:	0141                	addi	sp,sp,16
    8000494e:	8082                	ret

0000000080004950 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004950:	1101                	addi	sp,sp,-32
    80004952:	ec06                	sd	ra,24(sp)
    80004954:	e822                	sd	s0,16(sp)
    80004956:	e426                	sd	s1,8(sp)
    80004958:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000495a:	0001c517          	auipc	a0,0x1c
    8000495e:	49e50513          	addi	a0,a0,1182 # 80020df8 <ftable>
    80004962:	ffffc097          	auipc	ra,0xffffc
    80004966:	338080e7          	jalr	824(ra) # 80000c9a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000496a:	0001c497          	auipc	s1,0x1c
    8000496e:	4a648493          	addi	s1,s1,1190 # 80020e10 <ftable+0x18>
    80004972:	0001d717          	auipc	a4,0x1d
    80004976:	43e70713          	addi	a4,a4,1086 # 80021db0 <disk>
    if(f->ref == 0){
    8000497a:	40dc                	lw	a5,4(s1)
    8000497c:	cf99                	beqz	a5,8000499a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000497e:	02848493          	addi	s1,s1,40
    80004982:	fee49ce3          	bne	s1,a4,8000497a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004986:	0001c517          	auipc	a0,0x1c
    8000498a:	47250513          	addi	a0,a0,1138 # 80020df8 <ftable>
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	3c0080e7          	jalr	960(ra) # 80000d4e <release>
  return 0;
    80004996:	4481                	li	s1,0
    80004998:	a819                	j	800049ae <filealloc+0x5e>
      f->ref = 1;
    8000499a:	4785                	li	a5,1
    8000499c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000499e:	0001c517          	auipc	a0,0x1c
    800049a2:	45a50513          	addi	a0,a0,1114 # 80020df8 <ftable>
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	3a8080e7          	jalr	936(ra) # 80000d4e <release>
}
    800049ae:	8526                	mv	a0,s1
    800049b0:	60e2                	ld	ra,24(sp)
    800049b2:	6442                	ld	s0,16(sp)
    800049b4:	64a2                	ld	s1,8(sp)
    800049b6:	6105                	addi	sp,sp,32
    800049b8:	8082                	ret

00000000800049ba <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049ba:	1101                	addi	sp,sp,-32
    800049bc:	ec06                	sd	ra,24(sp)
    800049be:	e822                	sd	s0,16(sp)
    800049c0:	e426                	sd	s1,8(sp)
    800049c2:	1000                	addi	s0,sp,32
    800049c4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049c6:	0001c517          	auipc	a0,0x1c
    800049ca:	43250513          	addi	a0,a0,1074 # 80020df8 <ftable>
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	2cc080e7          	jalr	716(ra) # 80000c9a <acquire>
  if(f->ref < 1)
    800049d6:	40dc                	lw	a5,4(s1)
    800049d8:	02f05263          	blez	a5,800049fc <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049dc:	2785                	addiw	a5,a5,1
    800049de:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049e0:	0001c517          	auipc	a0,0x1c
    800049e4:	41850513          	addi	a0,a0,1048 # 80020df8 <ftable>
    800049e8:	ffffc097          	auipc	ra,0xffffc
    800049ec:	366080e7          	jalr	870(ra) # 80000d4e <release>
  return f;
}
    800049f0:	8526                	mv	a0,s1
    800049f2:	60e2                	ld	ra,24(sp)
    800049f4:	6442                	ld	s0,16(sp)
    800049f6:	64a2                	ld	s1,8(sp)
    800049f8:	6105                	addi	sp,sp,32
    800049fa:	8082                	ret
    panic("filedup");
    800049fc:	00004517          	auipc	a0,0x4
    80004a00:	e0450513          	addi	a0,a0,-508 # 80008800 <syscalls+0x288>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	b38080e7          	jalr	-1224(ra) # 8000053c <panic>

0000000080004a0c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a0c:	7139                	addi	sp,sp,-64
    80004a0e:	fc06                	sd	ra,56(sp)
    80004a10:	f822                	sd	s0,48(sp)
    80004a12:	f426                	sd	s1,40(sp)
    80004a14:	f04a                	sd	s2,32(sp)
    80004a16:	ec4e                	sd	s3,24(sp)
    80004a18:	e852                	sd	s4,16(sp)
    80004a1a:	e456                	sd	s5,8(sp)
    80004a1c:	0080                	addi	s0,sp,64
    80004a1e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a20:	0001c517          	auipc	a0,0x1c
    80004a24:	3d850513          	addi	a0,a0,984 # 80020df8 <ftable>
    80004a28:	ffffc097          	auipc	ra,0xffffc
    80004a2c:	272080e7          	jalr	626(ra) # 80000c9a <acquire>
  if(f->ref < 1)
    80004a30:	40dc                	lw	a5,4(s1)
    80004a32:	06f05163          	blez	a5,80004a94 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a36:	37fd                	addiw	a5,a5,-1
    80004a38:	0007871b          	sext.w	a4,a5
    80004a3c:	c0dc                	sw	a5,4(s1)
    80004a3e:	06e04363          	bgtz	a4,80004aa4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a42:	0004a903          	lw	s2,0(s1)
    80004a46:	0094ca83          	lbu	s5,9(s1)
    80004a4a:	0104ba03          	ld	s4,16(s1)
    80004a4e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a52:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a56:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a5a:	0001c517          	auipc	a0,0x1c
    80004a5e:	39e50513          	addi	a0,a0,926 # 80020df8 <ftable>
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	2ec080e7          	jalr	748(ra) # 80000d4e <release>

  if(ff.type == FD_PIPE){
    80004a6a:	4785                	li	a5,1
    80004a6c:	04f90d63          	beq	s2,a5,80004ac6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a70:	3979                	addiw	s2,s2,-2
    80004a72:	4785                	li	a5,1
    80004a74:	0527e063          	bltu	a5,s2,80004ab4 <fileclose+0xa8>
    begin_op();
    80004a78:	00000097          	auipc	ra,0x0
    80004a7c:	ad0080e7          	jalr	-1328(ra) # 80004548 <begin_op>
    iput(ff.ip);
    80004a80:	854e                	mv	a0,s3
    80004a82:	fffff097          	auipc	ra,0xfffff
    80004a86:	2da080e7          	jalr	730(ra) # 80003d5c <iput>
    end_op();
    80004a8a:	00000097          	auipc	ra,0x0
    80004a8e:	b38080e7          	jalr	-1224(ra) # 800045c2 <end_op>
    80004a92:	a00d                	j	80004ab4 <fileclose+0xa8>
    panic("fileclose");
    80004a94:	00004517          	auipc	a0,0x4
    80004a98:	d7450513          	addi	a0,a0,-652 # 80008808 <syscalls+0x290>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	aa0080e7          	jalr	-1376(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004aa4:	0001c517          	auipc	a0,0x1c
    80004aa8:	35450513          	addi	a0,a0,852 # 80020df8 <ftable>
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	2a2080e7          	jalr	674(ra) # 80000d4e <release>
  }
}
    80004ab4:	70e2                	ld	ra,56(sp)
    80004ab6:	7442                	ld	s0,48(sp)
    80004ab8:	74a2                	ld	s1,40(sp)
    80004aba:	7902                	ld	s2,32(sp)
    80004abc:	69e2                	ld	s3,24(sp)
    80004abe:	6a42                	ld	s4,16(sp)
    80004ac0:	6aa2                	ld	s5,8(sp)
    80004ac2:	6121                	addi	sp,sp,64
    80004ac4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ac6:	85d6                	mv	a1,s5
    80004ac8:	8552                	mv	a0,s4
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	348080e7          	jalr	840(ra) # 80004e12 <pipeclose>
    80004ad2:	b7cd                	j	80004ab4 <fileclose+0xa8>

0000000080004ad4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ad4:	715d                	addi	sp,sp,-80
    80004ad6:	e486                	sd	ra,72(sp)
    80004ad8:	e0a2                	sd	s0,64(sp)
    80004ada:	fc26                	sd	s1,56(sp)
    80004adc:	f84a                	sd	s2,48(sp)
    80004ade:	f44e                	sd	s3,40(sp)
    80004ae0:	0880                	addi	s0,sp,80
    80004ae2:	84aa                	mv	s1,a0
    80004ae4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ae6:	ffffd097          	auipc	ra,0xffffd
    80004aea:	07c080e7          	jalr	124(ra) # 80001b62 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004aee:	409c                	lw	a5,0(s1)
    80004af0:	37f9                	addiw	a5,a5,-2
    80004af2:	4705                	li	a4,1
    80004af4:	04f76763          	bltu	a4,a5,80004b42 <filestat+0x6e>
    80004af8:	892a                	mv	s2,a0
    ilock(f->ip);
    80004afa:	6c88                	ld	a0,24(s1)
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	0a6080e7          	jalr	166(ra) # 80003ba2 <ilock>
    stati(f->ip, &st);
    80004b04:	fb840593          	addi	a1,s0,-72
    80004b08:	6c88                	ld	a0,24(s1)
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	322080e7          	jalr	802(ra) # 80003e2c <stati>
    iunlock(f->ip);
    80004b12:	6c88                	ld	a0,24(s1)
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	150080e7          	jalr	336(ra) # 80003c64 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b1c:	46e1                	li	a3,24
    80004b1e:	fb840613          	addi	a2,s0,-72
    80004b22:	85ce                	mv	a1,s3
    80004b24:	05093503          	ld	a0,80(s2)
    80004b28:	ffffd097          	auipc	ra,0xffffd
    80004b2c:	c06080e7          	jalr	-1018(ra) # 8000172e <copyout>
    80004b30:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b34:	60a6                	ld	ra,72(sp)
    80004b36:	6406                	ld	s0,64(sp)
    80004b38:	74e2                	ld	s1,56(sp)
    80004b3a:	7942                	ld	s2,48(sp)
    80004b3c:	79a2                	ld	s3,40(sp)
    80004b3e:	6161                	addi	sp,sp,80
    80004b40:	8082                	ret
  return -1;
    80004b42:	557d                	li	a0,-1
    80004b44:	bfc5                	j	80004b34 <filestat+0x60>

0000000080004b46 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b46:	7179                	addi	sp,sp,-48
    80004b48:	f406                	sd	ra,40(sp)
    80004b4a:	f022                	sd	s0,32(sp)
    80004b4c:	ec26                	sd	s1,24(sp)
    80004b4e:	e84a                	sd	s2,16(sp)
    80004b50:	e44e                	sd	s3,8(sp)
    80004b52:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b54:	00854783          	lbu	a5,8(a0)
    80004b58:	c3d5                	beqz	a5,80004bfc <fileread+0xb6>
    80004b5a:	84aa                	mv	s1,a0
    80004b5c:	89ae                	mv	s3,a1
    80004b5e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b60:	411c                	lw	a5,0(a0)
    80004b62:	4705                	li	a4,1
    80004b64:	04e78963          	beq	a5,a4,80004bb6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b68:	470d                	li	a4,3
    80004b6a:	04e78d63          	beq	a5,a4,80004bc4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b6e:	4709                	li	a4,2
    80004b70:	06e79e63          	bne	a5,a4,80004bec <fileread+0xa6>
    ilock(f->ip);
    80004b74:	6d08                	ld	a0,24(a0)
    80004b76:	fffff097          	auipc	ra,0xfffff
    80004b7a:	02c080e7          	jalr	44(ra) # 80003ba2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b7e:	874a                	mv	a4,s2
    80004b80:	5094                	lw	a3,32(s1)
    80004b82:	864e                	mv	a2,s3
    80004b84:	4585                	li	a1,1
    80004b86:	6c88                	ld	a0,24(s1)
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	2ce080e7          	jalr	718(ra) # 80003e56 <readi>
    80004b90:	892a                	mv	s2,a0
    80004b92:	00a05563          	blez	a0,80004b9c <fileread+0x56>
      f->off += r;
    80004b96:	509c                	lw	a5,32(s1)
    80004b98:	9fa9                	addw	a5,a5,a0
    80004b9a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b9c:	6c88                	ld	a0,24(s1)
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	0c6080e7          	jalr	198(ra) # 80003c64 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	70a2                	ld	ra,40(sp)
    80004baa:	7402                	ld	s0,32(sp)
    80004bac:	64e2                	ld	s1,24(sp)
    80004bae:	6942                	ld	s2,16(sp)
    80004bb0:	69a2                	ld	s3,8(sp)
    80004bb2:	6145                	addi	sp,sp,48
    80004bb4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004bb6:	6908                	ld	a0,16(a0)
    80004bb8:	00000097          	auipc	ra,0x0
    80004bbc:	3c2080e7          	jalr	962(ra) # 80004f7a <piperead>
    80004bc0:	892a                	mv	s2,a0
    80004bc2:	b7d5                	j	80004ba6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bc4:	02451783          	lh	a5,36(a0)
    80004bc8:	03079693          	slli	a3,a5,0x30
    80004bcc:	92c1                	srli	a3,a3,0x30
    80004bce:	4725                	li	a4,9
    80004bd0:	02d76863          	bltu	a4,a3,80004c00 <fileread+0xba>
    80004bd4:	0792                	slli	a5,a5,0x4
    80004bd6:	0001c717          	auipc	a4,0x1c
    80004bda:	18270713          	addi	a4,a4,386 # 80020d58 <devsw>
    80004bde:	97ba                	add	a5,a5,a4
    80004be0:	639c                	ld	a5,0(a5)
    80004be2:	c38d                	beqz	a5,80004c04 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004be4:	4505                	li	a0,1
    80004be6:	9782                	jalr	a5
    80004be8:	892a                	mv	s2,a0
    80004bea:	bf75                	j	80004ba6 <fileread+0x60>
    panic("fileread");
    80004bec:	00004517          	auipc	a0,0x4
    80004bf0:	c2c50513          	addi	a0,a0,-980 # 80008818 <syscalls+0x2a0>
    80004bf4:	ffffc097          	auipc	ra,0xffffc
    80004bf8:	948080e7          	jalr	-1720(ra) # 8000053c <panic>
    return -1;
    80004bfc:	597d                	li	s2,-1
    80004bfe:	b765                	j	80004ba6 <fileread+0x60>
      return -1;
    80004c00:	597d                	li	s2,-1
    80004c02:	b755                	j	80004ba6 <fileread+0x60>
    80004c04:	597d                	li	s2,-1
    80004c06:	b745                	j	80004ba6 <fileread+0x60>

0000000080004c08 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004c08:	00954783          	lbu	a5,9(a0)
    80004c0c:	10078e63          	beqz	a5,80004d28 <filewrite+0x120>
{
    80004c10:	715d                	addi	sp,sp,-80
    80004c12:	e486                	sd	ra,72(sp)
    80004c14:	e0a2                	sd	s0,64(sp)
    80004c16:	fc26                	sd	s1,56(sp)
    80004c18:	f84a                	sd	s2,48(sp)
    80004c1a:	f44e                	sd	s3,40(sp)
    80004c1c:	f052                	sd	s4,32(sp)
    80004c1e:	ec56                	sd	s5,24(sp)
    80004c20:	e85a                	sd	s6,16(sp)
    80004c22:	e45e                	sd	s7,8(sp)
    80004c24:	e062                	sd	s8,0(sp)
    80004c26:	0880                	addi	s0,sp,80
    80004c28:	892a                	mv	s2,a0
    80004c2a:	8b2e                	mv	s6,a1
    80004c2c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c2e:	411c                	lw	a5,0(a0)
    80004c30:	4705                	li	a4,1
    80004c32:	02e78263          	beq	a5,a4,80004c56 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c36:	470d                	li	a4,3
    80004c38:	02e78563          	beq	a5,a4,80004c62 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c3c:	4709                	li	a4,2
    80004c3e:	0ce79d63          	bne	a5,a4,80004d18 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c42:	0ac05b63          	blez	a2,80004cf8 <filewrite+0xf0>
    int i = 0;
    80004c46:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004c48:	6b85                	lui	s7,0x1
    80004c4a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c4e:	6c05                	lui	s8,0x1
    80004c50:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c54:	a851                	j	80004ce8 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004c56:	6908                	ld	a0,16(a0)
    80004c58:	00000097          	auipc	ra,0x0
    80004c5c:	22a080e7          	jalr	554(ra) # 80004e82 <pipewrite>
    80004c60:	a045                	j	80004d00 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c62:	02451783          	lh	a5,36(a0)
    80004c66:	03079693          	slli	a3,a5,0x30
    80004c6a:	92c1                	srli	a3,a3,0x30
    80004c6c:	4725                	li	a4,9
    80004c6e:	0ad76f63          	bltu	a4,a3,80004d2c <filewrite+0x124>
    80004c72:	0792                	slli	a5,a5,0x4
    80004c74:	0001c717          	auipc	a4,0x1c
    80004c78:	0e470713          	addi	a4,a4,228 # 80020d58 <devsw>
    80004c7c:	97ba                	add	a5,a5,a4
    80004c7e:	679c                	ld	a5,8(a5)
    80004c80:	cbc5                	beqz	a5,80004d30 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004c82:	4505                	li	a0,1
    80004c84:	9782                	jalr	a5
    80004c86:	a8ad                	j	80004d00 <filewrite+0xf8>
      if(n1 > max)
    80004c88:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004c8c:	00000097          	auipc	ra,0x0
    80004c90:	8bc080e7          	jalr	-1860(ra) # 80004548 <begin_op>
      ilock(f->ip);
    80004c94:	01893503          	ld	a0,24(s2)
    80004c98:	fffff097          	auipc	ra,0xfffff
    80004c9c:	f0a080e7          	jalr	-246(ra) # 80003ba2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ca0:	8756                	mv	a4,s5
    80004ca2:	02092683          	lw	a3,32(s2)
    80004ca6:	01698633          	add	a2,s3,s6
    80004caa:	4585                	li	a1,1
    80004cac:	01893503          	ld	a0,24(s2)
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	29e080e7          	jalr	670(ra) # 80003f4e <writei>
    80004cb8:	84aa                	mv	s1,a0
    80004cba:	00a05763          	blez	a0,80004cc8 <filewrite+0xc0>
        f->off += r;
    80004cbe:	02092783          	lw	a5,32(s2)
    80004cc2:	9fa9                	addw	a5,a5,a0
    80004cc4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cc8:	01893503          	ld	a0,24(s2)
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	f98080e7          	jalr	-104(ra) # 80003c64 <iunlock>
      end_op();
    80004cd4:	00000097          	auipc	ra,0x0
    80004cd8:	8ee080e7          	jalr	-1810(ra) # 800045c2 <end_op>

      if(r != n1){
    80004cdc:	009a9f63          	bne	s5,s1,80004cfa <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004ce0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ce4:	0149db63          	bge	s3,s4,80004cfa <filewrite+0xf2>
      int n1 = n - i;
    80004ce8:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004cec:	0004879b          	sext.w	a5,s1
    80004cf0:	f8fbdce3          	bge	s7,a5,80004c88 <filewrite+0x80>
    80004cf4:	84e2                	mv	s1,s8
    80004cf6:	bf49                	j	80004c88 <filewrite+0x80>
    int i = 0;
    80004cf8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cfa:	033a1d63          	bne	s4,s3,80004d34 <filewrite+0x12c>
    80004cfe:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d00:	60a6                	ld	ra,72(sp)
    80004d02:	6406                	ld	s0,64(sp)
    80004d04:	74e2                	ld	s1,56(sp)
    80004d06:	7942                	ld	s2,48(sp)
    80004d08:	79a2                	ld	s3,40(sp)
    80004d0a:	7a02                	ld	s4,32(sp)
    80004d0c:	6ae2                	ld	s5,24(sp)
    80004d0e:	6b42                	ld	s6,16(sp)
    80004d10:	6ba2                	ld	s7,8(sp)
    80004d12:	6c02                	ld	s8,0(sp)
    80004d14:	6161                	addi	sp,sp,80
    80004d16:	8082                	ret
    panic("filewrite");
    80004d18:	00004517          	auipc	a0,0x4
    80004d1c:	b1050513          	addi	a0,a0,-1264 # 80008828 <syscalls+0x2b0>
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	81c080e7          	jalr	-2020(ra) # 8000053c <panic>
    return -1;
    80004d28:	557d                	li	a0,-1
}
    80004d2a:	8082                	ret
      return -1;
    80004d2c:	557d                	li	a0,-1
    80004d2e:	bfc9                	j	80004d00 <filewrite+0xf8>
    80004d30:	557d                	li	a0,-1
    80004d32:	b7f9                	j	80004d00 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004d34:	557d                	li	a0,-1
    80004d36:	b7e9                	j	80004d00 <filewrite+0xf8>

0000000080004d38 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d38:	7179                	addi	sp,sp,-48
    80004d3a:	f406                	sd	ra,40(sp)
    80004d3c:	f022                	sd	s0,32(sp)
    80004d3e:	ec26                	sd	s1,24(sp)
    80004d40:	e84a                	sd	s2,16(sp)
    80004d42:	e44e                	sd	s3,8(sp)
    80004d44:	e052                	sd	s4,0(sp)
    80004d46:	1800                	addi	s0,sp,48
    80004d48:	84aa                	mv	s1,a0
    80004d4a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d4c:	0005b023          	sd	zero,0(a1)
    80004d50:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d54:	00000097          	auipc	ra,0x0
    80004d58:	bfc080e7          	jalr	-1028(ra) # 80004950 <filealloc>
    80004d5c:	e088                	sd	a0,0(s1)
    80004d5e:	c551                	beqz	a0,80004dea <pipealloc+0xb2>
    80004d60:	00000097          	auipc	ra,0x0
    80004d64:	bf0080e7          	jalr	-1040(ra) # 80004950 <filealloc>
    80004d68:	00aa3023          	sd	a0,0(s4)
    80004d6c:	c92d                	beqz	a0,80004dde <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d6e:	ffffc097          	auipc	ra,0xffffc
    80004d72:	df0080e7          	jalr	-528(ra) # 80000b5e <kalloc>
    80004d76:	892a                	mv	s2,a0
    80004d78:	c125                	beqz	a0,80004dd8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d7a:	4985                	li	s3,1
    80004d7c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d80:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d84:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d88:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d8c:	00004597          	auipc	a1,0x4
    80004d90:	aac58593          	addi	a1,a1,-1364 # 80008838 <syscalls+0x2c0>
    80004d94:	ffffc097          	auipc	ra,0xffffc
    80004d98:	e76080e7          	jalr	-394(ra) # 80000c0a <initlock>
  (*f0)->type = FD_PIPE;
    80004d9c:	609c                	ld	a5,0(s1)
    80004d9e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004da2:	609c                	ld	a5,0(s1)
    80004da4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004da8:	609c                	ld	a5,0(s1)
    80004daa:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004dae:	609c                	ld	a5,0(s1)
    80004db0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004db4:	000a3783          	ld	a5,0(s4)
    80004db8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004dbc:	000a3783          	ld	a5,0(s4)
    80004dc0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004dc4:	000a3783          	ld	a5,0(s4)
    80004dc8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004dcc:	000a3783          	ld	a5,0(s4)
    80004dd0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004dd4:	4501                	li	a0,0
    80004dd6:	a025                	j	80004dfe <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004dd8:	6088                	ld	a0,0(s1)
    80004dda:	e501                	bnez	a0,80004de2 <pipealloc+0xaa>
    80004ddc:	a039                	j	80004dea <pipealloc+0xb2>
    80004dde:	6088                	ld	a0,0(s1)
    80004de0:	c51d                	beqz	a0,80004e0e <pipealloc+0xd6>
    fileclose(*f0);
    80004de2:	00000097          	auipc	ra,0x0
    80004de6:	c2a080e7          	jalr	-982(ra) # 80004a0c <fileclose>
  if(*f1)
    80004dea:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dee:	557d                	li	a0,-1
  if(*f1)
    80004df0:	c799                	beqz	a5,80004dfe <pipealloc+0xc6>
    fileclose(*f1);
    80004df2:	853e                	mv	a0,a5
    80004df4:	00000097          	auipc	ra,0x0
    80004df8:	c18080e7          	jalr	-1000(ra) # 80004a0c <fileclose>
  return -1;
    80004dfc:	557d                	li	a0,-1
}
    80004dfe:	70a2                	ld	ra,40(sp)
    80004e00:	7402                	ld	s0,32(sp)
    80004e02:	64e2                	ld	s1,24(sp)
    80004e04:	6942                	ld	s2,16(sp)
    80004e06:	69a2                	ld	s3,8(sp)
    80004e08:	6a02                	ld	s4,0(sp)
    80004e0a:	6145                	addi	sp,sp,48
    80004e0c:	8082                	ret
  return -1;
    80004e0e:	557d                	li	a0,-1
    80004e10:	b7fd                	j	80004dfe <pipealloc+0xc6>

0000000080004e12 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e12:	1101                	addi	sp,sp,-32
    80004e14:	ec06                	sd	ra,24(sp)
    80004e16:	e822                	sd	s0,16(sp)
    80004e18:	e426                	sd	s1,8(sp)
    80004e1a:	e04a                	sd	s2,0(sp)
    80004e1c:	1000                	addi	s0,sp,32
    80004e1e:	84aa                	mv	s1,a0
    80004e20:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e22:	ffffc097          	auipc	ra,0xffffc
    80004e26:	e78080e7          	jalr	-392(ra) # 80000c9a <acquire>
  if(writable){
    80004e2a:	02090d63          	beqz	s2,80004e64 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e2e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e32:	21848513          	addi	a0,s1,536
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	4f8080e7          	jalr	1272(ra) # 8000232e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e3e:	2204b783          	ld	a5,544(s1)
    80004e42:	eb95                	bnez	a5,80004e76 <pipeclose+0x64>
    release(&pi->lock);
    80004e44:	8526                	mv	a0,s1
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	f08080e7          	jalr	-248(ra) # 80000d4e <release>
    kfree((char*)pi);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	ffffc097          	auipc	ra,0xffffc
    80004e54:	ba6080e7          	jalr	-1114(ra) # 800009f6 <kfree>
  } else
    release(&pi->lock);
}
    80004e58:	60e2                	ld	ra,24(sp)
    80004e5a:	6442                	ld	s0,16(sp)
    80004e5c:	64a2                	ld	s1,8(sp)
    80004e5e:	6902                	ld	s2,0(sp)
    80004e60:	6105                	addi	sp,sp,32
    80004e62:	8082                	ret
    pi->readopen = 0;
    80004e64:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e68:	21c48513          	addi	a0,s1,540
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	4c2080e7          	jalr	1218(ra) # 8000232e <wakeup>
    80004e74:	b7e9                	j	80004e3e <pipeclose+0x2c>
    release(&pi->lock);
    80004e76:	8526                	mv	a0,s1
    80004e78:	ffffc097          	auipc	ra,0xffffc
    80004e7c:	ed6080e7          	jalr	-298(ra) # 80000d4e <release>
}
    80004e80:	bfe1                	j	80004e58 <pipeclose+0x46>

0000000080004e82 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e82:	711d                	addi	sp,sp,-96
    80004e84:	ec86                	sd	ra,88(sp)
    80004e86:	e8a2                	sd	s0,80(sp)
    80004e88:	e4a6                	sd	s1,72(sp)
    80004e8a:	e0ca                	sd	s2,64(sp)
    80004e8c:	fc4e                	sd	s3,56(sp)
    80004e8e:	f852                	sd	s4,48(sp)
    80004e90:	f456                	sd	s5,40(sp)
    80004e92:	f05a                	sd	s6,32(sp)
    80004e94:	ec5e                	sd	s7,24(sp)
    80004e96:	e862                	sd	s8,16(sp)
    80004e98:	1080                	addi	s0,sp,96
    80004e9a:	84aa                	mv	s1,a0
    80004e9c:	8aae                	mv	s5,a1
    80004e9e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ea0:	ffffd097          	auipc	ra,0xffffd
    80004ea4:	cc2080e7          	jalr	-830(ra) # 80001b62 <myproc>
    80004ea8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	ffffc097          	auipc	ra,0xffffc
    80004eb0:	dee080e7          	jalr	-530(ra) # 80000c9a <acquire>
  while(i < n){
    80004eb4:	0b405663          	blez	s4,80004f60 <pipewrite+0xde>
  int i = 0;
    80004eb8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004eba:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ebc:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ec0:	21c48b93          	addi	s7,s1,540
    80004ec4:	a089                	j	80004f06 <pipewrite+0x84>
      release(&pi->lock);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	ffffc097          	auipc	ra,0xffffc
    80004ecc:	e86080e7          	jalr	-378(ra) # 80000d4e <release>
      return -1;
    80004ed0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ed2:	854a                	mv	a0,s2
    80004ed4:	60e6                	ld	ra,88(sp)
    80004ed6:	6446                	ld	s0,80(sp)
    80004ed8:	64a6                	ld	s1,72(sp)
    80004eda:	6906                	ld	s2,64(sp)
    80004edc:	79e2                	ld	s3,56(sp)
    80004ede:	7a42                	ld	s4,48(sp)
    80004ee0:	7aa2                	ld	s5,40(sp)
    80004ee2:	7b02                	ld	s6,32(sp)
    80004ee4:	6be2                	ld	s7,24(sp)
    80004ee6:	6c42                	ld	s8,16(sp)
    80004ee8:	6125                	addi	sp,sp,96
    80004eea:	8082                	ret
      wakeup(&pi->nread);
    80004eec:	8562                	mv	a0,s8
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	440080e7          	jalr	1088(ra) # 8000232e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ef6:	85a6                	mv	a1,s1
    80004ef8:	855e                	mv	a0,s7
    80004efa:	ffffd097          	auipc	ra,0xffffd
    80004efe:	3d0080e7          	jalr	976(ra) # 800022ca <sleep>
  while(i < n){
    80004f02:	07495063          	bge	s2,s4,80004f62 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f06:	2204a783          	lw	a5,544(s1)
    80004f0a:	dfd5                	beqz	a5,80004ec6 <pipewrite+0x44>
    80004f0c:	854e                	mv	a0,s3
    80004f0e:	ffffd097          	auipc	ra,0xffffd
    80004f12:	664080e7          	jalr	1636(ra) # 80002572 <killed>
    80004f16:	f945                	bnez	a0,80004ec6 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f18:	2184a783          	lw	a5,536(s1)
    80004f1c:	21c4a703          	lw	a4,540(s1)
    80004f20:	2007879b          	addiw	a5,a5,512
    80004f24:	fcf704e3          	beq	a4,a5,80004eec <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f28:	4685                	li	a3,1
    80004f2a:	01590633          	add	a2,s2,s5
    80004f2e:	faf40593          	addi	a1,s0,-81
    80004f32:	0509b503          	ld	a0,80(s3)
    80004f36:	ffffd097          	auipc	ra,0xffffd
    80004f3a:	884080e7          	jalr	-1916(ra) # 800017ba <copyin>
    80004f3e:	03650263          	beq	a0,s6,80004f62 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f42:	21c4a783          	lw	a5,540(s1)
    80004f46:	0017871b          	addiw	a4,a5,1
    80004f4a:	20e4ae23          	sw	a4,540(s1)
    80004f4e:	1ff7f793          	andi	a5,a5,511
    80004f52:	97a6                	add	a5,a5,s1
    80004f54:	faf44703          	lbu	a4,-81(s0)
    80004f58:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f5c:	2905                	addiw	s2,s2,1
    80004f5e:	b755                	j	80004f02 <pipewrite+0x80>
  int i = 0;
    80004f60:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004f62:	21848513          	addi	a0,s1,536
    80004f66:	ffffd097          	auipc	ra,0xffffd
    80004f6a:	3c8080e7          	jalr	968(ra) # 8000232e <wakeup>
  release(&pi->lock);
    80004f6e:	8526                	mv	a0,s1
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	dde080e7          	jalr	-546(ra) # 80000d4e <release>
  return i;
    80004f78:	bfa9                	j	80004ed2 <pipewrite+0x50>

0000000080004f7a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f7a:	715d                	addi	sp,sp,-80
    80004f7c:	e486                	sd	ra,72(sp)
    80004f7e:	e0a2                	sd	s0,64(sp)
    80004f80:	fc26                	sd	s1,56(sp)
    80004f82:	f84a                	sd	s2,48(sp)
    80004f84:	f44e                	sd	s3,40(sp)
    80004f86:	f052                	sd	s4,32(sp)
    80004f88:	ec56                	sd	s5,24(sp)
    80004f8a:	e85a                	sd	s6,16(sp)
    80004f8c:	0880                	addi	s0,sp,80
    80004f8e:	84aa                	mv	s1,a0
    80004f90:	892e                	mv	s2,a1
    80004f92:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f94:	ffffd097          	auipc	ra,0xffffd
    80004f98:	bce080e7          	jalr	-1074(ra) # 80001b62 <myproc>
    80004f9c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	ffffc097          	auipc	ra,0xffffc
    80004fa4:	cfa080e7          	jalr	-774(ra) # 80000c9a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fa8:	2184a703          	lw	a4,536(s1)
    80004fac:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fb0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fb4:	02f71763          	bne	a4,a5,80004fe2 <piperead+0x68>
    80004fb8:	2244a783          	lw	a5,548(s1)
    80004fbc:	c39d                	beqz	a5,80004fe2 <piperead+0x68>
    if(killed(pr)){
    80004fbe:	8552                	mv	a0,s4
    80004fc0:	ffffd097          	auipc	ra,0xffffd
    80004fc4:	5b2080e7          	jalr	1458(ra) # 80002572 <killed>
    80004fc8:	e949                	bnez	a0,8000505a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fca:	85a6                	mv	a1,s1
    80004fcc:	854e                	mv	a0,s3
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	2fc080e7          	jalr	764(ra) # 800022ca <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fd6:	2184a703          	lw	a4,536(s1)
    80004fda:	21c4a783          	lw	a5,540(s1)
    80004fde:	fcf70de3          	beq	a4,a5,80004fb8 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fe2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fe4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fe6:	05505463          	blez	s5,8000502e <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004fea:	2184a783          	lw	a5,536(s1)
    80004fee:	21c4a703          	lw	a4,540(s1)
    80004ff2:	02f70e63          	beq	a4,a5,8000502e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ff6:	0017871b          	addiw	a4,a5,1
    80004ffa:	20e4ac23          	sw	a4,536(s1)
    80004ffe:	1ff7f793          	andi	a5,a5,511
    80005002:	97a6                	add	a5,a5,s1
    80005004:	0187c783          	lbu	a5,24(a5)
    80005008:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000500c:	4685                	li	a3,1
    8000500e:	fbf40613          	addi	a2,s0,-65
    80005012:	85ca                	mv	a1,s2
    80005014:	050a3503          	ld	a0,80(s4)
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	716080e7          	jalr	1814(ra) # 8000172e <copyout>
    80005020:	01650763          	beq	a0,s6,8000502e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005024:	2985                	addiw	s3,s3,1
    80005026:	0905                	addi	s2,s2,1
    80005028:	fd3a91e3          	bne	s5,s3,80004fea <piperead+0x70>
    8000502c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000502e:	21c48513          	addi	a0,s1,540
    80005032:	ffffd097          	auipc	ra,0xffffd
    80005036:	2fc080e7          	jalr	764(ra) # 8000232e <wakeup>
  release(&pi->lock);
    8000503a:	8526                	mv	a0,s1
    8000503c:	ffffc097          	auipc	ra,0xffffc
    80005040:	d12080e7          	jalr	-750(ra) # 80000d4e <release>
  return i;
}
    80005044:	854e                	mv	a0,s3
    80005046:	60a6                	ld	ra,72(sp)
    80005048:	6406                	ld	s0,64(sp)
    8000504a:	74e2                	ld	s1,56(sp)
    8000504c:	7942                	ld	s2,48(sp)
    8000504e:	79a2                	ld	s3,40(sp)
    80005050:	7a02                	ld	s4,32(sp)
    80005052:	6ae2                	ld	s5,24(sp)
    80005054:	6b42                	ld	s6,16(sp)
    80005056:	6161                	addi	sp,sp,80
    80005058:	8082                	ret
      release(&pi->lock);
    8000505a:	8526                	mv	a0,s1
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	cf2080e7          	jalr	-782(ra) # 80000d4e <release>
      return -1;
    80005064:	59fd                	li	s3,-1
    80005066:	bff9                	j	80005044 <piperead+0xca>

0000000080005068 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005068:	1141                	addi	sp,sp,-16
    8000506a:	e422                	sd	s0,8(sp)
    8000506c:	0800                	addi	s0,sp,16
    8000506e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005070:	8905                	andi	a0,a0,1
    80005072:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005074:	8b89                	andi	a5,a5,2
    80005076:	c399                	beqz	a5,8000507c <flags2perm+0x14>
      perm |= PTE_W;
    80005078:	00456513          	ori	a0,a0,4
    return perm;
}
    8000507c:	6422                	ld	s0,8(sp)
    8000507e:	0141                	addi	sp,sp,16
    80005080:	8082                	ret

0000000080005082 <exec>:

int
exec(char *path, char **argv)
{
    80005082:	df010113          	addi	sp,sp,-528
    80005086:	20113423          	sd	ra,520(sp)
    8000508a:	20813023          	sd	s0,512(sp)
    8000508e:	ffa6                	sd	s1,504(sp)
    80005090:	fbca                	sd	s2,496(sp)
    80005092:	f7ce                	sd	s3,488(sp)
    80005094:	f3d2                	sd	s4,480(sp)
    80005096:	efd6                	sd	s5,472(sp)
    80005098:	ebda                	sd	s6,464(sp)
    8000509a:	e7de                	sd	s7,456(sp)
    8000509c:	e3e2                	sd	s8,448(sp)
    8000509e:	ff66                	sd	s9,440(sp)
    800050a0:	fb6a                	sd	s10,432(sp)
    800050a2:	f76e                	sd	s11,424(sp)
    800050a4:	0c00                	addi	s0,sp,528
    800050a6:	892a                	mv	s2,a0
    800050a8:	dea43c23          	sd	a0,-520(s0)
    800050ac:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050b0:	ffffd097          	auipc	ra,0xffffd
    800050b4:	ab2080e7          	jalr	-1358(ra) # 80001b62 <myproc>
    800050b8:	84aa                	mv	s1,a0

  begin_op();
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	48e080e7          	jalr	1166(ra) # 80004548 <begin_op>

  if((ip = namei(path)) == 0){
    800050c2:	854a                	mv	a0,s2
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	284080e7          	jalr	644(ra) # 80004348 <namei>
    800050cc:	c92d                	beqz	a0,8000513e <exec+0xbc>
    800050ce:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	ad2080e7          	jalr	-1326(ra) # 80003ba2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050d8:	04000713          	li	a4,64
    800050dc:	4681                	li	a3,0
    800050de:	e5040613          	addi	a2,s0,-432
    800050e2:	4581                	li	a1,0
    800050e4:	8552                	mv	a0,s4
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	d70080e7          	jalr	-656(ra) # 80003e56 <readi>
    800050ee:	04000793          	li	a5,64
    800050f2:	00f51a63          	bne	a0,a5,80005106 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800050f6:	e5042703          	lw	a4,-432(s0)
    800050fa:	464c47b7          	lui	a5,0x464c4
    800050fe:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005102:	04f70463          	beq	a4,a5,8000514a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005106:	8552                	mv	a0,s4
    80005108:	fffff097          	auipc	ra,0xfffff
    8000510c:	cfc080e7          	jalr	-772(ra) # 80003e04 <iunlockput>
    end_op();
    80005110:	fffff097          	auipc	ra,0xfffff
    80005114:	4b2080e7          	jalr	1202(ra) # 800045c2 <end_op>
  }
  return -1;
    80005118:	557d                	li	a0,-1
}
    8000511a:	20813083          	ld	ra,520(sp)
    8000511e:	20013403          	ld	s0,512(sp)
    80005122:	74fe                	ld	s1,504(sp)
    80005124:	795e                	ld	s2,496(sp)
    80005126:	79be                	ld	s3,488(sp)
    80005128:	7a1e                	ld	s4,480(sp)
    8000512a:	6afe                	ld	s5,472(sp)
    8000512c:	6b5e                	ld	s6,464(sp)
    8000512e:	6bbe                	ld	s7,456(sp)
    80005130:	6c1e                	ld	s8,448(sp)
    80005132:	7cfa                	ld	s9,440(sp)
    80005134:	7d5a                	ld	s10,432(sp)
    80005136:	7dba                	ld	s11,424(sp)
    80005138:	21010113          	addi	sp,sp,528
    8000513c:	8082                	ret
    end_op();
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	484080e7          	jalr	1156(ra) # 800045c2 <end_op>
    return -1;
    80005146:	557d                	li	a0,-1
    80005148:	bfc9                	j	8000511a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000514a:	8526                	mv	a0,s1
    8000514c:	ffffd097          	auipc	ra,0xffffd
    80005150:	ada080e7          	jalr	-1318(ra) # 80001c26 <proc_pagetable>
    80005154:	8b2a                	mv	s6,a0
    80005156:	d945                	beqz	a0,80005106 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005158:	e7042d03          	lw	s10,-400(s0)
    8000515c:	e8845783          	lhu	a5,-376(s0)
    80005160:	10078463          	beqz	a5,80005268 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005164:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005166:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005168:	6c85                	lui	s9,0x1
    8000516a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000516e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005172:	6a85                	lui	s5,0x1
    80005174:	a0b5                	j	800051e0 <exec+0x15e>
      panic("loadseg: address should exist");
    80005176:	00003517          	auipc	a0,0x3
    8000517a:	6ca50513          	addi	a0,a0,1738 # 80008840 <syscalls+0x2c8>
    8000517e:	ffffb097          	auipc	ra,0xffffb
    80005182:	3be080e7          	jalr	958(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80005186:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005188:	8726                	mv	a4,s1
    8000518a:	012c06bb          	addw	a3,s8,s2
    8000518e:	4581                	li	a1,0
    80005190:	8552                	mv	a0,s4
    80005192:	fffff097          	auipc	ra,0xfffff
    80005196:	cc4080e7          	jalr	-828(ra) # 80003e56 <readi>
    8000519a:	2501                	sext.w	a0,a0
    8000519c:	24a49863          	bne	s1,a0,800053ec <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    800051a0:	012a893b          	addw	s2,s5,s2
    800051a4:	03397563          	bgeu	s2,s3,800051ce <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    800051a8:	02091593          	slli	a1,s2,0x20
    800051ac:	9181                	srli	a1,a1,0x20
    800051ae:	95de                	add	a1,a1,s7
    800051b0:	855a                	mv	a0,s6
    800051b2:	ffffc097          	auipc	ra,0xffffc
    800051b6:	f6c080e7          	jalr	-148(ra) # 8000111e <walkaddr>
    800051ba:	862a                	mv	a2,a0
    if(pa == 0)
    800051bc:	dd4d                	beqz	a0,80005176 <exec+0xf4>
    if(sz - i < PGSIZE)
    800051be:	412984bb          	subw	s1,s3,s2
    800051c2:	0004879b          	sext.w	a5,s1
    800051c6:	fcfcf0e3          	bgeu	s9,a5,80005186 <exec+0x104>
    800051ca:	84d6                	mv	s1,s5
    800051cc:	bf6d                	j	80005186 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051ce:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051d2:	2d85                	addiw	s11,s11,1
    800051d4:	038d0d1b          	addiw	s10,s10,56
    800051d8:	e8845783          	lhu	a5,-376(s0)
    800051dc:	08fdd763          	bge	s11,a5,8000526a <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051e0:	2d01                	sext.w	s10,s10
    800051e2:	03800713          	li	a4,56
    800051e6:	86ea                	mv	a3,s10
    800051e8:	e1840613          	addi	a2,s0,-488
    800051ec:	4581                	li	a1,0
    800051ee:	8552                	mv	a0,s4
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	c66080e7          	jalr	-922(ra) # 80003e56 <readi>
    800051f8:	03800793          	li	a5,56
    800051fc:	1ef51663          	bne	a0,a5,800053e8 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80005200:	e1842783          	lw	a5,-488(s0)
    80005204:	4705                	li	a4,1
    80005206:	fce796e3          	bne	a5,a4,800051d2 <exec+0x150>
    if(ph.memsz < ph.filesz)
    8000520a:	e4043483          	ld	s1,-448(s0)
    8000520e:	e3843783          	ld	a5,-456(s0)
    80005212:	1ef4e863          	bltu	s1,a5,80005402 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005216:	e2843783          	ld	a5,-472(s0)
    8000521a:	94be                	add	s1,s1,a5
    8000521c:	1ef4e663          	bltu	s1,a5,80005408 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80005220:	df043703          	ld	a4,-528(s0)
    80005224:	8ff9                	and	a5,a5,a4
    80005226:	1e079463          	bnez	a5,8000540e <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000522a:	e1c42503          	lw	a0,-484(s0)
    8000522e:	00000097          	auipc	ra,0x0
    80005232:	e3a080e7          	jalr	-454(ra) # 80005068 <flags2perm>
    80005236:	86aa                	mv	a3,a0
    80005238:	8626                	mv	a2,s1
    8000523a:	85ca                	mv	a1,s2
    8000523c:	855a                	mv	a0,s6
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	294080e7          	jalr	660(ra) # 800014d2 <uvmalloc>
    80005246:	e0a43423          	sd	a0,-504(s0)
    8000524a:	1c050563          	beqz	a0,80005414 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000524e:	e2843b83          	ld	s7,-472(s0)
    80005252:	e2042c03          	lw	s8,-480(s0)
    80005256:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000525a:	00098463          	beqz	s3,80005262 <exec+0x1e0>
    8000525e:	4901                	li	s2,0
    80005260:	b7a1                	j	800051a8 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005262:	e0843903          	ld	s2,-504(s0)
    80005266:	b7b5                	j	800051d2 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005268:	4901                	li	s2,0
  iunlockput(ip);
    8000526a:	8552                	mv	a0,s4
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	b98080e7          	jalr	-1128(ra) # 80003e04 <iunlockput>
  end_op();
    80005274:	fffff097          	auipc	ra,0xfffff
    80005278:	34e080e7          	jalr	846(ra) # 800045c2 <end_op>
  p = myproc();
    8000527c:	ffffd097          	auipc	ra,0xffffd
    80005280:	8e6080e7          	jalr	-1818(ra) # 80001b62 <myproc>
    80005284:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005286:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000528a:	6985                	lui	s3,0x1
    8000528c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000528e:	99ca                	add	s3,s3,s2
    80005290:	77fd                	lui	a5,0xfffff
    80005292:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005296:	4691                	li	a3,4
    80005298:	6609                	lui	a2,0x2
    8000529a:	964e                	add	a2,a2,s3
    8000529c:	85ce                	mv	a1,s3
    8000529e:	855a                	mv	a0,s6
    800052a0:	ffffc097          	auipc	ra,0xffffc
    800052a4:	232080e7          	jalr	562(ra) # 800014d2 <uvmalloc>
    800052a8:	892a                	mv	s2,a0
    800052aa:	e0a43423          	sd	a0,-504(s0)
    800052ae:	e509                	bnez	a0,800052b8 <exec+0x236>
  if(pagetable)
    800052b0:	e1343423          	sd	s3,-504(s0)
    800052b4:	4a01                	li	s4,0
    800052b6:	aa1d                	j	800053ec <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052b8:	75f9                	lui	a1,0xffffe
    800052ba:	95aa                	add	a1,a1,a0
    800052bc:	855a                	mv	a0,s6
    800052be:	ffffc097          	auipc	ra,0xffffc
    800052c2:	43e080e7          	jalr	1086(ra) # 800016fc <uvmclear>
  stackbase = sp - PGSIZE;
    800052c6:	7bfd                	lui	s7,0xfffff
    800052c8:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800052ca:	e0043783          	ld	a5,-512(s0)
    800052ce:	6388                	ld	a0,0(a5)
    800052d0:	c52d                	beqz	a0,8000533a <exec+0x2b8>
    800052d2:	e9040993          	addi	s3,s0,-368
    800052d6:	f9040c13          	addi	s8,s0,-112
    800052da:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052dc:	ffffc097          	auipc	ra,0xffffc
    800052e0:	c34080e7          	jalr	-972(ra) # 80000f10 <strlen>
    800052e4:	0015079b          	addiw	a5,a0,1
    800052e8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052ec:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800052f0:	13796563          	bltu	s2,s7,8000541a <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052f4:	e0043d03          	ld	s10,-512(s0)
    800052f8:	000d3a03          	ld	s4,0(s10)
    800052fc:	8552                	mv	a0,s4
    800052fe:	ffffc097          	auipc	ra,0xffffc
    80005302:	c12080e7          	jalr	-1006(ra) # 80000f10 <strlen>
    80005306:	0015069b          	addiw	a3,a0,1
    8000530a:	8652                	mv	a2,s4
    8000530c:	85ca                	mv	a1,s2
    8000530e:	855a                	mv	a0,s6
    80005310:	ffffc097          	auipc	ra,0xffffc
    80005314:	41e080e7          	jalr	1054(ra) # 8000172e <copyout>
    80005318:	10054363          	bltz	a0,8000541e <exec+0x39c>
    ustack[argc] = sp;
    8000531c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005320:	0485                	addi	s1,s1,1
    80005322:	008d0793          	addi	a5,s10,8
    80005326:	e0f43023          	sd	a5,-512(s0)
    8000532a:	008d3503          	ld	a0,8(s10)
    8000532e:	c909                	beqz	a0,80005340 <exec+0x2be>
    if(argc >= MAXARG)
    80005330:	09a1                	addi	s3,s3,8
    80005332:	fb8995e3          	bne	s3,s8,800052dc <exec+0x25a>
  ip = 0;
    80005336:	4a01                	li	s4,0
    80005338:	a855                	j	800053ec <exec+0x36a>
  sp = sz;
    8000533a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000533e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005340:	00349793          	slli	a5,s1,0x3
    80005344:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd0a0>
    80005348:	97a2                	add	a5,a5,s0
    8000534a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000534e:	00148693          	addi	a3,s1,1
    80005352:	068e                	slli	a3,a3,0x3
    80005354:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005358:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000535c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005360:	f57968e3          	bltu	s2,s7,800052b0 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005364:	e9040613          	addi	a2,s0,-368
    80005368:	85ca                	mv	a1,s2
    8000536a:	855a                	mv	a0,s6
    8000536c:	ffffc097          	auipc	ra,0xffffc
    80005370:	3c2080e7          	jalr	962(ra) # 8000172e <copyout>
    80005374:	0a054763          	bltz	a0,80005422 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005378:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000537c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005380:	df843783          	ld	a5,-520(s0)
    80005384:	0007c703          	lbu	a4,0(a5)
    80005388:	cf11                	beqz	a4,800053a4 <exec+0x322>
    8000538a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000538c:	02f00693          	li	a3,47
    80005390:	a039                	j	8000539e <exec+0x31c>
      last = s+1;
    80005392:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005396:	0785                	addi	a5,a5,1
    80005398:	fff7c703          	lbu	a4,-1(a5)
    8000539c:	c701                	beqz	a4,800053a4 <exec+0x322>
    if(*s == '/')
    8000539e:	fed71ce3          	bne	a4,a3,80005396 <exec+0x314>
    800053a2:	bfc5                	j	80005392 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    800053a4:	4641                	li	a2,16
    800053a6:	df843583          	ld	a1,-520(s0)
    800053aa:	158a8513          	addi	a0,s5,344
    800053ae:	ffffc097          	auipc	ra,0xffffc
    800053b2:	b30080e7          	jalr	-1232(ra) # 80000ede <safestrcpy>
  oldpagetable = p->pagetable;
    800053b6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800053ba:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800053be:	e0843783          	ld	a5,-504(s0)
    800053c2:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053c6:	058ab783          	ld	a5,88(s5)
    800053ca:	e6843703          	ld	a4,-408(s0)
    800053ce:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053d0:	058ab783          	ld	a5,88(s5)
    800053d4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053d8:	85e6                	mv	a1,s9
    800053da:	ffffd097          	auipc	ra,0xffffd
    800053de:	8e8080e7          	jalr	-1816(ra) # 80001cc2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053e2:	0004851b          	sext.w	a0,s1
    800053e6:	bb15                	j	8000511a <exec+0x98>
    800053e8:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800053ec:	e0843583          	ld	a1,-504(s0)
    800053f0:	855a                	mv	a0,s6
    800053f2:	ffffd097          	auipc	ra,0xffffd
    800053f6:	8d0080e7          	jalr	-1840(ra) # 80001cc2 <proc_freepagetable>
  return -1;
    800053fa:	557d                	li	a0,-1
  if(ip){
    800053fc:	d00a0fe3          	beqz	s4,8000511a <exec+0x98>
    80005400:	b319                	j	80005106 <exec+0x84>
    80005402:	e1243423          	sd	s2,-504(s0)
    80005406:	b7dd                	j	800053ec <exec+0x36a>
    80005408:	e1243423          	sd	s2,-504(s0)
    8000540c:	b7c5                	j	800053ec <exec+0x36a>
    8000540e:	e1243423          	sd	s2,-504(s0)
    80005412:	bfe9                	j	800053ec <exec+0x36a>
    80005414:	e1243423          	sd	s2,-504(s0)
    80005418:	bfd1                	j	800053ec <exec+0x36a>
  ip = 0;
    8000541a:	4a01                	li	s4,0
    8000541c:	bfc1                	j	800053ec <exec+0x36a>
    8000541e:	4a01                	li	s4,0
  if(pagetable)
    80005420:	b7f1                	j	800053ec <exec+0x36a>
  sz = sz1;
    80005422:	e0843983          	ld	s3,-504(s0)
    80005426:	b569                	j	800052b0 <exec+0x22e>

0000000080005428 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005428:	7179                	addi	sp,sp,-48
    8000542a:	f406                	sd	ra,40(sp)
    8000542c:	f022                	sd	s0,32(sp)
    8000542e:	ec26                	sd	s1,24(sp)
    80005430:	e84a                	sd	s2,16(sp)
    80005432:	1800                	addi	s0,sp,48
    80005434:	892e                	mv	s2,a1
    80005436:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005438:	fdc40593          	addi	a1,s0,-36
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	a8c080e7          	jalr	-1396(ra) # 80002ec8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005444:	fdc42703          	lw	a4,-36(s0)
    80005448:	47bd                	li	a5,15
    8000544a:	02e7eb63          	bltu	a5,a4,80005480 <argfd+0x58>
    8000544e:	ffffc097          	auipc	ra,0xffffc
    80005452:	714080e7          	jalr	1812(ra) # 80001b62 <myproc>
    80005456:	fdc42703          	lw	a4,-36(s0)
    8000545a:	01a70793          	addi	a5,a4,26
    8000545e:	078e                	slli	a5,a5,0x3
    80005460:	953e                	add	a0,a0,a5
    80005462:	611c                	ld	a5,0(a0)
    80005464:	c385                	beqz	a5,80005484 <argfd+0x5c>
    return -1;
  if(pfd)
    80005466:	00090463          	beqz	s2,8000546e <argfd+0x46>
    *pfd = fd;
    8000546a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000546e:	4501                	li	a0,0
  if(pf)
    80005470:	c091                	beqz	s1,80005474 <argfd+0x4c>
    *pf = f;
    80005472:	e09c                	sd	a5,0(s1)
}
    80005474:	70a2                	ld	ra,40(sp)
    80005476:	7402                	ld	s0,32(sp)
    80005478:	64e2                	ld	s1,24(sp)
    8000547a:	6942                	ld	s2,16(sp)
    8000547c:	6145                	addi	sp,sp,48
    8000547e:	8082                	ret
    return -1;
    80005480:	557d                	li	a0,-1
    80005482:	bfcd                	j	80005474 <argfd+0x4c>
    80005484:	557d                	li	a0,-1
    80005486:	b7fd                	j	80005474 <argfd+0x4c>

0000000080005488 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005488:	1101                	addi	sp,sp,-32
    8000548a:	ec06                	sd	ra,24(sp)
    8000548c:	e822                	sd	s0,16(sp)
    8000548e:	e426                	sd	s1,8(sp)
    80005490:	1000                	addi	s0,sp,32
    80005492:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005494:	ffffc097          	auipc	ra,0xffffc
    80005498:	6ce080e7          	jalr	1742(ra) # 80001b62 <myproc>
    8000549c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000549e:	0d050793          	addi	a5,a0,208
    800054a2:	4501                	li	a0,0
    800054a4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054a6:	6398                	ld	a4,0(a5)
    800054a8:	cb19                	beqz	a4,800054be <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800054aa:	2505                	addiw	a0,a0,1
    800054ac:	07a1                	addi	a5,a5,8
    800054ae:	fed51ce3          	bne	a0,a3,800054a6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054b2:	557d                	li	a0,-1
}
    800054b4:	60e2                	ld	ra,24(sp)
    800054b6:	6442                	ld	s0,16(sp)
    800054b8:	64a2                	ld	s1,8(sp)
    800054ba:	6105                	addi	sp,sp,32
    800054bc:	8082                	ret
      p->ofile[fd] = f;
    800054be:	01a50793          	addi	a5,a0,26
    800054c2:	078e                	slli	a5,a5,0x3
    800054c4:	963e                	add	a2,a2,a5
    800054c6:	e204                	sd	s1,0(a2)
      return fd;
    800054c8:	b7f5                	j	800054b4 <fdalloc+0x2c>

00000000800054ca <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054ca:	715d                	addi	sp,sp,-80
    800054cc:	e486                	sd	ra,72(sp)
    800054ce:	e0a2                	sd	s0,64(sp)
    800054d0:	fc26                	sd	s1,56(sp)
    800054d2:	f84a                	sd	s2,48(sp)
    800054d4:	f44e                	sd	s3,40(sp)
    800054d6:	f052                	sd	s4,32(sp)
    800054d8:	ec56                	sd	s5,24(sp)
    800054da:	e85a                	sd	s6,16(sp)
    800054dc:	0880                	addi	s0,sp,80
    800054de:	8b2e                	mv	s6,a1
    800054e0:	89b2                	mv	s3,a2
    800054e2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054e4:	fb040593          	addi	a1,s0,-80
    800054e8:	fffff097          	auipc	ra,0xfffff
    800054ec:	e7e080e7          	jalr	-386(ra) # 80004366 <nameiparent>
    800054f0:	84aa                	mv	s1,a0
    800054f2:	14050b63          	beqz	a0,80005648 <create+0x17e>
    return 0;

  ilock(dp);
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	6ac080e7          	jalr	1708(ra) # 80003ba2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054fe:	4601                	li	a2,0
    80005500:	fb040593          	addi	a1,s0,-80
    80005504:	8526                	mv	a0,s1
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	b80080e7          	jalr	-1152(ra) # 80004086 <dirlookup>
    8000550e:	8aaa                	mv	s5,a0
    80005510:	c921                	beqz	a0,80005560 <create+0x96>
    iunlockput(dp);
    80005512:	8526                	mv	a0,s1
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	8f0080e7          	jalr	-1808(ra) # 80003e04 <iunlockput>
    ilock(ip);
    8000551c:	8556                	mv	a0,s5
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	684080e7          	jalr	1668(ra) # 80003ba2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005526:	4789                	li	a5,2
    80005528:	02fb1563          	bne	s6,a5,80005552 <create+0x88>
    8000552c:	044ad783          	lhu	a5,68(s5)
    80005530:	37f9                	addiw	a5,a5,-2
    80005532:	17c2                	slli	a5,a5,0x30
    80005534:	93c1                	srli	a5,a5,0x30
    80005536:	4705                	li	a4,1
    80005538:	00f76d63          	bltu	a4,a5,80005552 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000553c:	8556                	mv	a0,s5
    8000553e:	60a6                	ld	ra,72(sp)
    80005540:	6406                	ld	s0,64(sp)
    80005542:	74e2                	ld	s1,56(sp)
    80005544:	7942                	ld	s2,48(sp)
    80005546:	79a2                	ld	s3,40(sp)
    80005548:	7a02                	ld	s4,32(sp)
    8000554a:	6ae2                	ld	s5,24(sp)
    8000554c:	6b42                	ld	s6,16(sp)
    8000554e:	6161                	addi	sp,sp,80
    80005550:	8082                	ret
    iunlockput(ip);
    80005552:	8556                	mv	a0,s5
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	8b0080e7          	jalr	-1872(ra) # 80003e04 <iunlockput>
    return 0;
    8000555c:	4a81                	li	s5,0
    8000555e:	bff9                	j	8000553c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005560:	85da                	mv	a1,s6
    80005562:	4088                	lw	a0,0(s1)
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	4a6080e7          	jalr	1190(ra) # 80003a0a <ialloc>
    8000556c:	8a2a                	mv	s4,a0
    8000556e:	c529                	beqz	a0,800055b8 <create+0xee>
  ilock(ip);
    80005570:	ffffe097          	auipc	ra,0xffffe
    80005574:	632080e7          	jalr	1586(ra) # 80003ba2 <ilock>
  ip->major = major;
    80005578:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000557c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005580:	4905                	li	s2,1
    80005582:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005586:	8552                	mv	a0,s4
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	54e080e7          	jalr	1358(ra) # 80003ad6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005590:	032b0b63          	beq	s6,s2,800055c6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005594:	004a2603          	lw	a2,4(s4)
    80005598:	fb040593          	addi	a1,s0,-80
    8000559c:	8526                	mv	a0,s1
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	cf8080e7          	jalr	-776(ra) # 80004296 <dirlink>
    800055a6:	06054f63          	bltz	a0,80005624 <create+0x15a>
  iunlockput(dp);
    800055aa:	8526                	mv	a0,s1
    800055ac:	fffff097          	auipc	ra,0xfffff
    800055b0:	858080e7          	jalr	-1960(ra) # 80003e04 <iunlockput>
  return ip;
    800055b4:	8ad2                	mv	s5,s4
    800055b6:	b759                	j	8000553c <create+0x72>
    iunlockput(dp);
    800055b8:	8526                	mv	a0,s1
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	84a080e7          	jalr	-1974(ra) # 80003e04 <iunlockput>
    return 0;
    800055c2:	8ad2                	mv	s5,s4
    800055c4:	bfa5                	j	8000553c <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055c6:	004a2603          	lw	a2,4(s4)
    800055ca:	00003597          	auipc	a1,0x3
    800055ce:	29658593          	addi	a1,a1,662 # 80008860 <syscalls+0x2e8>
    800055d2:	8552                	mv	a0,s4
    800055d4:	fffff097          	auipc	ra,0xfffff
    800055d8:	cc2080e7          	jalr	-830(ra) # 80004296 <dirlink>
    800055dc:	04054463          	bltz	a0,80005624 <create+0x15a>
    800055e0:	40d0                	lw	a2,4(s1)
    800055e2:	00003597          	auipc	a1,0x3
    800055e6:	28658593          	addi	a1,a1,646 # 80008868 <syscalls+0x2f0>
    800055ea:	8552                	mv	a0,s4
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	caa080e7          	jalr	-854(ra) # 80004296 <dirlink>
    800055f4:	02054863          	bltz	a0,80005624 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800055f8:	004a2603          	lw	a2,4(s4)
    800055fc:	fb040593          	addi	a1,s0,-80
    80005600:	8526                	mv	a0,s1
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	c94080e7          	jalr	-876(ra) # 80004296 <dirlink>
    8000560a:	00054d63          	bltz	a0,80005624 <create+0x15a>
    dp->nlink++;  // for ".."
    8000560e:	04a4d783          	lhu	a5,74(s1)
    80005612:	2785                	addiw	a5,a5,1
    80005614:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005618:	8526                	mv	a0,s1
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	4bc080e7          	jalr	1212(ra) # 80003ad6 <iupdate>
    80005622:	b761                	j	800055aa <create+0xe0>
  ip->nlink = 0;
    80005624:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005628:	8552                	mv	a0,s4
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	4ac080e7          	jalr	1196(ra) # 80003ad6 <iupdate>
  iunlockput(ip);
    80005632:	8552                	mv	a0,s4
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	7d0080e7          	jalr	2000(ra) # 80003e04 <iunlockput>
  iunlockput(dp);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	7c6080e7          	jalr	1990(ra) # 80003e04 <iunlockput>
  return 0;
    80005646:	bddd                	j	8000553c <create+0x72>
    return 0;
    80005648:	8aaa                	mv	s5,a0
    8000564a:	bdcd                	j	8000553c <create+0x72>

000000008000564c <sys_dup>:
{
    8000564c:	7179                	addi	sp,sp,-48
    8000564e:	f406                	sd	ra,40(sp)
    80005650:	f022                	sd	s0,32(sp)
    80005652:	ec26                	sd	s1,24(sp)
    80005654:	e84a                	sd	s2,16(sp)
    80005656:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005658:	fd840613          	addi	a2,s0,-40
    8000565c:	4581                	li	a1,0
    8000565e:	4501                	li	a0,0
    80005660:	00000097          	auipc	ra,0x0
    80005664:	dc8080e7          	jalr	-568(ra) # 80005428 <argfd>
    return -1;
    80005668:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000566a:	02054363          	bltz	a0,80005690 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000566e:	fd843903          	ld	s2,-40(s0)
    80005672:	854a                	mv	a0,s2
    80005674:	00000097          	auipc	ra,0x0
    80005678:	e14080e7          	jalr	-492(ra) # 80005488 <fdalloc>
    8000567c:	84aa                	mv	s1,a0
    return -1;
    8000567e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005680:	00054863          	bltz	a0,80005690 <sys_dup+0x44>
  filedup(f);
    80005684:	854a                	mv	a0,s2
    80005686:	fffff097          	auipc	ra,0xfffff
    8000568a:	334080e7          	jalr	820(ra) # 800049ba <filedup>
  return fd;
    8000568e:	87a6                	mv	a5,s1
}
    80005690:	853e                	mv	a0,a5
    80005692:	70a2                	ld	ra,40(sp)
    80005694:	7402                	ld	s0,32(sp)
    80005696:	64e2                	ld	s1,24(sp)
    80005698:	6942                	ld	s2,16(sp)
    8000569a:	6145                	addi	sp,sp,48
    8000569c:	8082                	ret

000000008000569e <sys_read>:
{
    8000569e:	7179                	addi	sp,sp,-48
    800056a0:	f406                	sd	ra,40(sp)
    800056a2:	f022                	sd	s0,32(sp)
    800056a4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056a6:	fd840593          	addi	a1,s0,-40
    800056aa:	4505                	li	a0,1
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	83c080e7          	jalr	-1988(ra) # 80002ee8 <argaddr>
  argint(2, &n);
    800056b4:	fe440593          	addi	a1,s0,-28
    800056b8:	4509                	li	a0,2
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	80e080e7          	jalr	-2034(ra) # 80002ec8 <argint>
  if(argfd(0, 0, &f) < 0)
    800056c2:	fe840613          	addi	a2,s0,-24
    800056c6:	4581                	li	a1,0
    800056c8:	4501                	li	a0,0
    800056ca:	00000097          	auipc	ra,0x0
    800056ce:	d5e080e7          	jalr	-674(ra) # 80005428 <argfd>
    800056d2:	87aa                	mv	a5,a0
    return -1;
    800056d4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056d6:	0007cc63          	bltz	a5,800056ee <sys_read+0x50>
  return fileread(f, p, n);
    800056da:	fe442603          	lw	a2,-28(s0)
    800056de:	fd843583          	ld	a1,-40(s0)
    800056e2:	fe843503          	ld	a0,-24(s0)
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	460080e7          	jalr	1120(ra) # 80004b46 <fileread>
}
    800056ee:	70a2                	ld	ra,40(sp)
    800056f0:	7402                	ld	s0,32(sp)
    800056f2:	6145                	addi	sp,sp,48
    800056f4:	8082                	ret

00000000800056f6 <sys_write>:
{
    800056f6:	7179                	addi	sp,sp,-48
    800056f8:	f406                	sd	ra,40(sp)
    800056fa:	f022                	sd	s0,32(sp)
    800056fc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056fe:	fd840593          	addi	a1,s0,-40
    80005702:	4505                	li	a0,1
    80005704:	ffffd097          	auipc	ra,0xffffd
    80005708:	7e4080e7          	jalr	2020(ra) # 80002ee8 <argaddr>
  argint(2, &n);
    8000570c:	fe440593          	addi	a1,s0,-28
    80005710:	4509                	li	a0,2
    80005712:	ffffd097          	auipc	ra,0xffffd
    80005716:	7b6080e7          	jalr	1974(ra) # 80002ec8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000571a:	fe840613          	addi	a2,s0,-24
    8000571e:	4581                	li	a1,0
    80005720:	4501                	li	a0,0
    80005722:	00000097          	auipc	ra,0x0
    80005726:	d06080e7          	jalr	-762(ra) # 80005428 <argfd>
    8000572a:	87aa                	mv	a5,a0
    return -1;
    8000572c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000572e:	0007cc63          	bltz	a5,80005746 <sys_write+0x50>
  return filewrite(f, p, n);
    80005732:	fe442603          	lw	a2,-28(s0)
    80005736:	fd843583          	ld	a1,-40(s0)
    8000573a:	fe843503          	ld	a0,-24(s0)
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	4ca080e7          	jalr	1226(ra) # 80004c08 <filewrite>
}
    80005746:	70a2                	ld	ra,40(sp)
    80005748:	7402                	ld	s0,32(sp)
    8000574a:	6145                	addi	sp,sp,48
    8000574c:	8082                	ret

000000008000574e <sys_close>:
{
    8000574e:	1101                	addi	sp,sp,-32
    80005750:	ec06                	sd	ra,24(sp)
    80005752:	e822                	sd	s0,16(sp)
    80005754:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005756:	fe040613          	addi	a2,s0,-32
    8000575a:	fec40593          	addi	a1,s0,-20
    8000575e:	4501                	li	a0,0
    80005760:	00000097          	auipc	ra,0x0
    80005764:	cc8080e7          	jalr	-824(ra) # 80005428 <argfd>
    return -1;
    80005768:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000576a:	02054463          	bltz	a0,80005792 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000576e:	ffffc097          	auipc	ra,0xffffc
    80005772:	3f4080e7          	jalr	1012(ra) # 80001b62 <myproc>
    80005776:	fec42783          	lw	a5,-20(s0)
    8000577a:	07e9                	addi	a5,a5,26
    8000577c:	078e                	slli	a5,a5,0x3
    8000577e:	953e                	add	a0,a0,a5
    80005780:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005784:	fe043503          	ld	a0,-32(s0)
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	284080e7          	jalr	644(ra) # 80004a0c <fileclose>
  return 0;
    80005790:	4781                	li	a5,0
}
    80005792:	853e                	mv	a0,a5
    80005794:	60e2                	ld	ra,24(sp)
    80005796:	6442                	ld	s0,16(sp)
    80005798:	6105                	addi	sp,sp,32
    8000579a:	8082                	ret

000000008000579c <sys_fstat>:
{
    8000579c:	1101                	addi	sp,sp,-32
    8000579e:	ec06                	sd	ra,24(sp)
    800057a0:	e822                	sd	s0,16(sp)
    800057a2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057a4:	fe040593          	addi	a1,s0,-32
    800057a8:	4505                	li	a0,1
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	73e080e7          	jalr	1854(ra) # 80002ee8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057b2:	fe840613          	addi	a2,s0,-24
    800057b6:	4581                	li	a1,0
    800057b8:	4501                	li	a0,0
    800057ba:	00000097          	auipc	ra,0x0
    800057be:	c6e080e7          	jalr	-914(ra) # 80005428 <argfd>
    800057c2:	87aa                	mv	a5,a0
    return -1;
    800057c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057c6:	0007ca63          	bltz	a5,800057da <sys_fstat+0x3e>
  return filestat(f, st);
    800057ca:	fe043583          	ld	a1,-32(s0)
    800057ce:	fe843503          	ld	a0,-24(s0)
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	302080e7          	jalr	770(ra) # 80004ad4 <filestat>
}
    800057da:	60e2                	ld	ra,24(sp)
    800057dc:	6442                	ld	s0,16(sp)
    800057de:	6105                	addi	sp,sp,32
    800057e0:	8082                	ret

00000000800057e2 <sys_link>:
{
    800057e2:	7169                	addi	sp,sp,-304
    800057e4:	f606                	sd	ra,296(sp)
    800057e6:	f222                	sd	s0,288(sp)
    800057e8:	ee26                	sd	s1,280(sp)
    800057ea:	ea4a                	sd	s2,272(sp)
    800057ec:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057ee:	08000613          	li	a2,128
    800057f2:	ed040593          	addi	a1,s0,-304
    800057f6:	4501                	li	a0,0
    800057f8:	ffffd097          	auipc	ra,0xffffd
    800057fc:	710080e7          	jalr	1808(ra) # 80002f08 <argstr>
    return -1;
    80005800:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005802:	10054e63          	bltz	a0,8000591e <sys_link+0x13c>
    80005806:	08000613          	li	a2,128
    8000580a:	f5040593          	addi	a1,s0,-176
    8000580e:	4505                	li	a0,1
    80005810:	ffffd097          	auipc	ra,0xffffd
    80005814:	6f8080e7          	jalr	1784(ra) # 80002f08 <argstr>
    return -1;
    80005818:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000581a:	10054263          	bltz	a0,8000591e <sys_link+0x13c>
  begin_op();
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	d2a080e7          	jalr	-726(ra) # 80004548 <begin_op>
  if((ip = namei(old)) == 0){
    80005826:	ed040513          	addi	a0,s0,-304
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	b1e080e7          	jalr	-1250(ra) # 80004348 <namei>
    80005832:	84aa                	mv	s1,a0
    80005834:	c551                	beqz	a0,800058c0 <sys_link+0xde>
  ilock(ip);
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	36c080e7          	jalr	876(ra) # 80003ba2 <ilock>
  if(ip->type == T_DIR){
    8000583e:	04449703          	lh	a4,68(s1)
    80005842:	4785                	li	a5,1
    80005844:	08f70463          	beq	a4,a5,800058cc <sys_link+0xea>
  ip->nlink++;
    80005848:	04a4d783          	lhu	a5,74(s1)
    8000584c:	2785                	addiw	a5,a5,1
    8000584e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	282080e7          	jalr	642(ra) # 80003ad6 <iupdate>
  iunlock(ip);
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	406080e7          	jalr	1030(ra) # 80003c64 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005866:	fd040593          	addi	a1,s0,-48
    8000586a:	f5040513          	addi	a0,s0,-176
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	af8080e7          	jalr	-1288(ra) # 80004366 <nameiparent>
    80005876:	892a                	mv	s2,a0
    80005878:	c935                	beqz	a0,800058ec <sys_link+0x10a>
  ilock(dp);
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	328080e7          	jalr	808(ra) # 80003ba2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005882:	00092703          	lw	a4,0(s2)
    80005886:	409c                	lw	a5,0(s1)
    80005888:	04f71d63          	bne	a4,a5,800058e2 <sys_link+0x100>
    8000588c:	40d0                	lw	a2,4(s1)
    8000588e:	fd040593          	addi	a1,s0,-48
    80005892:	854a                	mv	a0,s2
    80005894:	fffff097          	auipc	ra,0xfffff
    80005898:	a02080e7          	jalr	-1534(ra) # 80004296 <dirlink>
    8000589c:	04054363          	bltz	a0,800058e2 <sys_link+0x100>
  iunlockput(dp);
    800058a0:	854a                	mv	a0,s2
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	562080e7          	jalr	1378(ra) # 80003e04 <iunlockput>
  iput(ip);
    800058aa:	8526                	mv	a0,s1
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	4b0080e7          	jalr	1200(ra) # 80003d5c <iput>
  end_op();
    800058b4:	fffff097          	auipc	ra,0xfffff
    800058b8:	d0e080e7          	jalr	-754(ra) # 800045c2 <end_op>
  return 0;
    800058bc:	4781                	li	a5,0
    800058be:	a085                	j	8000591e <sys_link+0x13c>
    end_op();
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	d02080e7          	jalr	-766(ra) # 800045c2 <end_op>
    return -1;
    800058c8:	57fd                	li	a5,-1
    800058ca:	a891                	j	8000591e <sys_link+0x13c>
    iunlockput(ip);
    800058cc:	8526                	mv	a0,s1
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	536080e7          	jalr	1334(ra) # 80003e04 <iunlockput>
    end_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	cec080e7          	jalr	-788(ra) # 800045c2 <end_op>
    return -1;
    800058de:	57fd                	li	a5,-1
    800058e0:	a83d                	j	8000591e <sys_link+0x13c>
    iunlockput(dp);
    800058e2:	854a                	mv	a0,s2
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	520080e7          	jalr	1312(ra) # 80003e04 <iunlockput>
  ilock(ip);
    800058ec:	8526                	mv	a0,s1
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	2b4080e7          	jalr	692(ra) # 80003ba2 <ilock>
  ip->nlink--;
    800058f6:	04a4d783          	lhu	a5,74(s1)
    800058fa:	37fd                	addiw	a5,a5,-1
    800058fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005900:	8526                	mv	a0,s1
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	1d4080e7          	jalr	468(ra) # 80003ad6 <iupdate>
  iunlockput(ip);
    8000590a:	8526                	mv	a0,s1
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	4f8080e7          	jalr	1272(ra) # 80003e04 <iunlockput>
  end_op();
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	cae080e7          	jalr	-850(ra) # 800045c2 <end_op>
  return -1;
    8000591c:	57fd                	li	a5,-1
}
    8000591e:	853e                	mv	a0,a5
    80005920:	70b2                	ld	ra,296(sp)
    80005922:	7412                	ld	s0,288(sp)
    80005924:	64f2                	ld	s1,280(sp)
    80005926:	6952                	ld	s2,272(sp)
    80005928:	6155                	addi	sp,sp,304
    8000592a:	8082                	ret

000000008000592c <sys_unlink>:
{
    8000592c:	7151                	addi	sp,sp,-240
    8000592e:	f586                	sd	ra,232(sp)
    80005930:	f1a2                	sd	s0,224(sp)
    80005932:	eda6                	sd	s1,216(sp)
    80005934:	e9ca                	sd	s2,208(sp)
    80005936:	e5ce                	sd	s3,200(sp)
    80005938:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000593a:	08000613          	li	a2,128
    8000593e:	f3040593          	addi	a1,s0,-208
    80005942:	4501                	li	a0,0
    80005944:	ffffd097          	auipc	ra,0xffffd
    80005948:	5c4080e7          	jalr	1476(ra) # 80002f08 <argstr>
    8000594c:	18054163          	bltz	a0,80005ace <sys_unlink+0x1a2>
  begin_op();
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	bf8080e7          	jalr	-1032(ra) # 80004548 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005958:	fb040593          	addi	a1,s0,-80
    8000595c:	f3040513          	addi	a0,s0,-208
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	a06080e7          	jalr	-1530(ra) # 80004366 <nameiparent>
    80005968:	84aa                	mv	s1,a0
    8000596a:	c979                	beqz	a0,80005a40 <sys_unlink+0x114>
  ilock(dp);
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	236080e7          	jalr	566(ra) # 80003ba2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005974:	00003597          	auipc	a1,0x3
    80005978:	eec58593          	addi	a1,a1,-276 # 80008860 <syscalls+0x2e8>
    8000597c:	fb040513          	addi	a0,s0,-80
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	6ec080e7          	jalr	1772(ra) # 8000406c <namecmp>
    80005988:	14050a63          	beqz	a0,80005adc <sys_unlink+0x1b0>
    8000598c:	00003597          	auipc	a1,0x3
    80005990:	edc58593          	addi	a1,a1,-292 # 80008868 <syscalls+0x2f0>
    80005994:	fb040513          	addi	a0,s0,-80
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	6d4080e7          	jalr	1748(ra) # 8000406c <namecmp>
    800059a0:	12050e63          	beqz	a0,80005adc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059a4:	f2c40613          	addi	a2,s0,-212
    800059a8:	fb040593          	addi	a1,s0,-80
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	6d8080e7          	jalr	1752(ra) # 80004086 <dirlookup>
    800059b6:	892a                	mv	s2,a0
    800059b8:	12050263          	beqz	a0,80005adc <sys_unlink+0x1b0>
  ilock(ip);
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	1e6080e7          	jalr	486(ra) # 80003ba2 <ilock>
  if(ip->nlink < 1)
    800059c4:	04a91783          	lh	a5,74(s2)
    800059c8:	08f05263          	blez	a5,80005a4c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059cc:	04491703          	lh	a4,68(s2)
    800059d0:	4785                	li	a5,1
    800059d2:	08f70563          	beq	a4,a5,80005a5c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059d6:	4641                	li	a2,16
    800059d8:	4581                	li	a1,0
    800059da:	fc040513          	addi	a0,s0,-64
    800059de:	ffffb097          	auipc	ra,0xffffb
    800059e2:	3b8080e7          	jalr	952(ra) # 80000d96 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059e6:	4741                	li	a4,16
    800059e8:	f2c42683          	lw	a3,-212(s0)
    800059ec:	fc040613          	addi	a2,s0,-64
    800059f0:	4581                	li	a1,0
    800059f2:	8526                	mv	a0,s1
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	55a080e7          	jalr	1370(ra) # 80003f4e <writei>
    800059fc:	47c1                	li	a5,16
    800059fe:	0af51563          	bne	a0,a5,80005aa8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a02:	04491703          	lh	a4,68(s2)
    80005a06:	4785                	li	a5,1
    80005a08:	0af70863          	beq	a4,a5,80005ab8 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	3f6080e7          	jalr	1014(ra) # 80003e04 <iunlockput>
  ip->nlink--;
    80005a16:	04a95783          	lhu	a5,74(s2)
    80005a1a:	37fd                	addiw	a5,a5,-1
    80005a1c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a20:	854a                	mv	a0,s2
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	0b4080e7          	jalr	180(ra) # 80003ad6 <iupdate>
  iunlockput(ip);
    80005a2a:	854a                	mv	a0,s2
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	3d8080e7          	jalr	984(ra) # 80003e04 <iunlockput>
  end_op();
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	b8e080e7          	jalr	-1138(ra) # 800045c2 <end_op>
  return 0;
    80005a3c:	4501                	li	a0,0
    80005a3e:	a84d                	j	80005af0 <sys_unlink+0x1c4>
    end_op();
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	b82080e7          	jalr	-1150(ra) # 800045c2 <end_op>
    return -1;
    80005a48:	557d                	li	a0,-1
    80005a4a:	a05d                	j	80005af0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a4c:	00003517          	auipc	a0,0x3
    80005a50:	e2450513          	addi	a0,a0,-476 # 80008870 <syscalls+0x2f8>
    80005a54:	ffffb097          	auipc	ra,0xffffb
    80005a58:	ae8080e7          	jalr	-1304(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a5c:	04c92703          	lw	a4,76(s2)
    80005a60:	02000793          	li	a5,32
    80005a64:	f6e7f9e3          	bgeu	a5,a4,800059d6 <sys_unlink+0xaa>
    80005a68:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a6c:	4741                	li	a4,16
    80005a6e:	86ce                	mv	a3,s3
    80005a70:	f1840613          	addi	a2,s0,-232
    80005a74:	4581                	li	a1,0
    80005a76:	854a                	mv	a0,s2
    80005a78:	ffffe097          	auipc	ra,0xffffe
    80005a7c:	3de080e7          	jalr	990(ra) # 80003e56 <readi>
    80005a80:	47c1                	li	a5,16
    80005a82:	00f51b63          	bne	a0,a5,80005a98 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a86:	f1845783          	lhu	a5,-232(s0)
    80005a8a:	e7a1                	bnez	a5,80005ad2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a8c:	29c1                	addiw	s3,s3,16
    80005a8e:	04c92783          	lw	a5,76(s2)
    80005a92:	fcf9ede3          	bltu	s3,a5,80005a6c <sys_unlink+0x140>
    80005a96:	b781                	j	800059d6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a98:	00003517          	auipc	a0,0x3
    80005a9c:	df050513          	addi	a0,a0,-528 # 80008888 <syscalls+0x310>
    80005aa0:	ffffb097          	auipc	ra,0xffffb
    80005aa4:	a9c080e7          	jalr	-1380(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005aa8:	00003517          	auipc	a0,0x3
    80005aac:	df850513          	addi	a0,a0,-520 # 800088a0 <syscalls+0x328>
    80005ab0:	ffffb097          	auipc	ra,0xffffb
    80005ab4:	a8c080e7          	jalr	-1396(ra) # 8000053c <panic>
    dp->nlink--;
    80005ab8:	04a4d783          	lhu	a5,74(s1)
    80005abc:	37fd                	addiw	a5,a5,-1
    80005abe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ac2:	8526                	mv	a0,s1
    80005ac4:	ffffe097          	auipc	ra,0xffffe
    80005ac8:	012080e7          	jalr	18(ra) # 80003ad6 <iupdate>
    80005acc:	b781                	j	80005a0c <sys_unlink+0xe0>
    return -1;
    80005ace:	557d                	li	a0,-1
    80005ad0:	a005                	j	80005af0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ad2:	854a                	mv	a0,s2
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	330080e7          	jalr	816(ra) # 80003e04 <iunlockput>
  iunlockput(dp);
    80005adc:	8526                	mv	a0,s1
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	326080e7          	jalr	806(ra) # 80003e04 <iunlockput>
  end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	adc080e7          	jalr	-1316(ra) # 800045c2 <end_op>
  return -1;
    80005aee:	557d                	li	a0,-1
}
    80005af0:	70ae                	ld	ra,232(sp)
    80005af2:	740e                	ld	s0,224(sp)
    80005af4:	64ee                	ld	s1,216(sp)
    80005af6:	694e                	ld	s2,208(sp)
    80005af8:	69ae                	ld	s3,200(sp)
    80005afa:	616d                	addi	sp,sp,240
    80005afc:	8082                	ret

0000000080005afe <sys_open>:

uint64
sys_open(void)
{
    80005afe:	7131                	addi	sp,sp,-192
    80005b00:	fd06                	sd	ra,184(sp)
    80005b02:	f922                	sd	s0,176(sp)
    80005b04:	f526                	sd	s1,168(sp)
    80005b06:	f14a                	sd	s2,160(sp)
    80005b08:	ed4e                	sd	s3,152(sp)
    80005b0a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b0c:	f4c40593          	addi	a1,s0,-180
    80005b10:	4505                	li	a0,1
    80005b12:	ffffd097          	auipc	ra,0xffffd
    80005b16:	3b6080e7          	jalr	950(ra) # 80002ec8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b1a:	08000613          	li	a2,128
    80005b1e:	f5040593          	addi	a1,s0,-176
    80005b22:	4501                	li	a0,0
    80005b24:	ffffd097          	auipc	ra,0xffffd
    80005b28:	3e4080e7          	jalr	996(ra) # 80002f08 <argstr>
    80005b2c:	87aa                	mv	a5,a0
    return -1;
    80005b2e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b30:	0a07c863          	bltz	a5,80005be0 <sys_open+0xe2>

  begin_op();
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	a14080e7          	jalr	-1516(ra) # 80004548 <begin_op>

  if(omode & O_CREATE){
    80005b3c:	f4c42783          	lw	a5,-180(s0)
    80005b40:	2007f793          	andi	a5,a5,512
    80005b44:	cbdd                	beqz	a5,80005bfa <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005b46:	4681                	li	a3,0
    80005b48:	4601                	li	a2,0
    80005b4a:	4589                	li	a1,2
    80005b4c:	f5040513          	addi	a0,s0,-176
    80005b50:	00000097          	auipc	ra,0x0
    80005b54:	97a080e7          	jalr	-1670(ra) # 800054ca <create>
    80005b58:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b5a:	c951                	beqz	a0,80005bee <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b5c:	04449703          	lh	a4,68(s1)
    80005b60:	478d                	li	a5,3
    80005b62:	00f71763          	bne	a4,a5,80005b70 <sys_open+0x72>
    80005b66:	0464d703          	lhu	a4,70(s1)
    80005b6a:	47a5                	li	a5,9
    80005b6c:	0ce7ec63          	bltu	a5,a4,80005c44 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	de0080e7          	jalr	-544(ra) # 80004950 <filealloc>
    80005b78:	892a                	mv	s2,a0
    80005b7a:	c56d                	beqz	a0,80005c64 <sys_open+0x166>
    80005b7c:	00000097          	auipc	ra,0x0
    80005b80:	90c080e7          	jalr	-1780(ra) # 80005488 <fdalloc>
    80005b84:	89aa                	mv	s3,a0
    80005b86:	0c054a63          	bltz	a0,80005c5a <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b8a:	04449703          	lh	a4,68(s1)
    80005b8e:	478d                	li	a5,3
    80005b90:	0ef70563          	beq	a4,a5,80005c7a <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b94:	4789                	li	a5,2
    80005b96:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005b9a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005b9e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005ba2:	f4c42783          	lw	a5,-180(s0)
    80005ba6:	0017c713          	xori	a4,a5,1
    80005baa:	8b05                	andi	a4,a4,1
    80005bac:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bb0:	0037f713          	andi	a4,a5,3
    80005bb4:	00e03733          	snez	a4,a4
    80005bb8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bbc:	4007f793          	andi	a5,a5,1024
    80005bc0:	c791                	beqz	a5,80005bcc <sys_open+0xce>
    80005bc2:	04449703          	lh	a4,68(s1)
    80005bc6:	4789                	li	a5,2
    80005bc8:	0cf70063          	beq	a4,a5,80005c88 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005bcc:	8526                	mv	a0,s1
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	096080e7          	jalr	150(ra) # 80003c64 <iunlock>
  end_op();
    80005bd6:	fffff097          	auipc	ra,0xfffff
    80005bda:	9ec080e7          	jalr	-1556(ra) # 800045c2 <end_op>

  return fd;
    80005bde:	854e                	mv	a0,s3
}
    80005be0:	70ea                	ld	ra,184(sp)
    80005be2:	744a                	ld	s0,176(sp)
    80005be4:	74aa                	ld	s1,168(sp)
    80005be6:	790a                	ld	s2,160(sp)
    80005be8:	69ea                	ld	s3,152(sp)
    80005bea:	6129                	addi	sp,sp,192
    80005bec:	8082                	ret
      end_op();
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	9d4080e7          	jalr	-1580(ra) # 800045c2 <end_op>
      return -1;
    80005bf6:	557d                	li	a0,-1
    80005bf8:	b7e5                	j	80005be0 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005bfa:	f5040513          	addi	a0,s0,-176
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	74a080e7          	jalr	1866(ra) # 80004348 <namei>
    80005c06:	84aa                	mv	s1,a0
    80005c08:	c905                	beqz	a0,80005c38 <sys_open+0x13a>
    ilock(ip);
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	f98080e7          	jalr	-104(ra) # 80003ba2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c12:	04449703          	lh	a4,68(s1)
    80005c16:	4785                	li	a5,1
    80005c18:	f4f712e3          	bne	a4,a5,80005b5c <sys_open+0x5e>
    80005c1c:	f4c42783          	lw	a5,-180(s0)
    80005c20:	dba1                	beqz	a5,80005b70 <sys_open+0x72>
      iunlockput(ip);
    80005c22:	8526                	mv	a0,s1
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	1e0080e7          	jalr	480(ra) # 80003e04 <iunlockput>
      end_op();
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	996080e7          	jalr	-1642(ra) # 800045c2 <end_op>
      return -1;
    80005c34:	557d                	li	a0,-1
    80005c36:	b76d                	j	80005be0 <sys_open+0xe2>
      end_op();
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	98a080e7          	jalr	-1654(ra) # 800045c2 <end_op>
      return -1;
    80005c40:	557d                	li	a0,-1
    80005c42:	bf79                	j	80005be0 <sys_open+0xe2>
    iunlockput(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	1be080e7          	jalr	446(ra) # 80003e04 <iunlockput>
    end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	974080e7          	jalr	-1676(ra) # 800045c2 <end_op>
    return -1;
    80005c56:	557d                	li	a0,-1
    80005c58:	b761                	j	80005be0 <sys_open+0xe2>
      fileclose(f);
    80005c5a:	854a                	mv	a0,s2
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	db0080e7          	jalr	-592(ra) # 80004a0c <fileclose>
    iunlockput(ip);
    80005c64:	8526                	mv	a0,s1
    80005c66:	ffffe097          	auipc	ra,0xffffe
    80005c6a:	19e080e7          	jalr	414(ra) # 80003e04 <iunlockput>
    end_op();
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	954080e7          	jalr	-1708(ra) # 800045c2 <end_op>
    return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	b7a5                	j	80005be0 <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005c7a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005c7e:	04649783          	lh	a5,70(s1)
    80005c82:	02f91223          	sh	a5,36(s2)
    80005c86:	bf21                	j	80005b9e <sys_open+0xa0>
    itrunc(ip);
    80005c88:	8526                	mv	a0,s1
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	026080e7          	jalr	38(ra) # 80003cb0 <itrunc>
    80005c92:	bf2d                	j	80005bcc <sys_open+0xce>

0000000080005c94 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c94:	7175                	addi	sp,sp,-144
    80005c96:	e506                	sd	ra,136(sp)
    80005c98:	e122                	sd	s0,128(sp)
    80005c9a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	8ac080e7          	jalr	-1876(ra) # 80004548 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ca4:	08000613          	li	a2,128
    80005ca8:	f7040593          	addi	a1,s0,-144
    80005cac:	4501                	li	a0,0
    80005cae:	ffffd097          	auipc	ra,0xffffd
    80005cb2:	25a080e7          	jalr	602(ra) # 80002f08 <argstr>
    80005cb6:	02054963          	bltz	a0,80005ce8 <sys_mkdir+0x54>
    80005cba:	4681                	li	a3,0
    80005cbc:	4601                	li	a2,0
    80005cbe:	4585                	li	a1,1
    80005cc0:	f7040513          	addi	a0,s0,-144
    80005cc4:	00000097          	auipc	ra,0x0
    80005cc8:	806080e7          	jalr	-2042(ra) # 800054ca <create>
    80005ccc:	cd11                	beqz	a0,80005ce8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cce:	ffffe097          	auipc	ra,0xffffe
    80005cd2:	136080e7          	jalr	310(ra) # 80003e04 <iunlockput>
  end_op();
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	8ec080e7          	jalr	-1812(ra) # 800045c2 <end_op>
  return 0;
    80005cde:	4501                	li	a0,0
}
    80005ce0:	60aa                	ld	ra,136(sp)
    80005ce2:	640a                	ld	s0,128(sp)
    80005ce4:	6149                	addi	sp,sp,144
    80005ce6:	8082                	ret
    end_op();
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	8da080e7          	jalr	-1830(ra) # 800045c2 <end_op>
    return -1;
    80005cf0:	557d                	li	a0,-1
    80005cf2:	b7fd                	j	80005ce0 <sys_mkdir+0x4c>

0000000080005cf4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cf4:	7135                	addi	sp,sp,-160
    80005cf6:	ed06                	sd	ra,152(sp)
    80005cf8:	e922                	sd	s0,144(sp)
    80005cfa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	84c080e7          	jalr	-1972(ra) # 80004548 <begin_op>
  argint(1, &major);
    80005d04:	f6c40593          	addi	a1,s0,-148
    80005d08:	4505                	li	a0,1
    80005d0a:	ffffd097          	auipc	ra,0xffffd
    80005d0e:	1be080e7          	jalr	446(ra) # 80002ec8 <argint>
  argint(2, &minor);
    80005d12:	f6840593          	addi	a1,s0,-152
    80005d16:	4509                	li	a0,2
    80005d18:	ffffd097          	auipc	ra,0xffffd
    80005d1c:	1b0080e7          	jalr	432(ra) # 80002ec8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d20:	08000613          	li	a2,128
    80005d24:	f7040593          	addi	a1,s0,-144
    80005d28:	4501                	li	a0,0
    80005d2a:	ffffd097          	auipc	ra,0xffffd
    80005d2e:	1de080e7          	jalr	478(ra) # 80002f08 <argstr>
    80005d32:	02054b63          	bltz	a0,80005d68 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d36:	f6841683          	lh	a3,-152(s0)
    80005d3a:	f6c41603          	lh	a2,-148(s0)
    80005d3e:	458d                	li	a1,3
    80005d40:	f7040513          	addi	a0,s0,-144
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	786080e7          	jalr	1926(ra) # 800054ca <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d4c:	cd11                	beqz	a0,80005d68 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	0b6080e7          	jalr	182(ra) # 80003e04 <iunlockput>
  end_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	86c080e7          	jalr	-1940(ra) # 800045c2 <end_op>
  return 0;
    80005d5e:	4501                	li	a0,0
}
    80005d60:	60ea                	ld	ra,152(sp)
    80005d62:	644a                	ld	s0,144(sp)
    80005d64:	610d                	addi	sp,sp,160
    80005d66:	8082                	ret
    end_op();
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	85a080e7          	jalr	-1958(ra) # 800045c2 <end_op>
    return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	b7fd                	j	80005d60 <sys_mknod+0x6c>

0000000080005d74 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d74:	7135                	addi	sp,sp,-160
    80005d76:	ed06                	sd	ra,152(sp)
    80005d78:	e922                	sd	s0,144(sp)
    80005d7a:	e526                	sd	s1,136(sp)
    80005d7c:	e14a                	sd	s2,128(sp)
    80005d7e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	de2080e7          	jalr	-542(ra) # 80001b62 <myproc>
    80005d88:	892a                	mv	s2,a0
  
  begin_op();
    80005d8a:	ffffe097          	auipc	ra,0xffffe
    80005d8e:	7be080e7          	jalr	1982(ra) # 80004548 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d92:	08000613          	li	a2,128
    80005d96:	f6040593          	addi	a1,s0,-160
    80005d9a:	4501                	li	a0,0
    80005d9c:	ffffd097          	auipc	ra,0xffffd
    80005da0:	16c080e7          	jalr	364(ra) # 80002f08 <argstr>
    80005da4:	04054b63          	bltz	a0,80005dfa <sys_chdir+0x86>
    80005da8:	f6040513          	addi	a0,s0,-160
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	59c080e7          	jalr	1436(ra) # 80004348 <namei>
    80005db4:	84aa                	mv	s1,a0
    80005db6:	c131                	beqz	a0,80005dfa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	dea080e7          	jalr	-534(ra) # 80003ba2 <ilock>
  if(ip->type != T_DIR){
    80005dc0:	04449703          	lh	a4,68(s1)
    80005dc4:	4785                	li	a5,1
    80005dc6:	04f71063          	bne	a4,a5,80005e06 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005dca:	8526                	mv	a0,s1
    80005dcc:	ffffe097          	auipc	ra,0xffffe
    80005dd0:	e98080e7          	jalr	-360(ra) # 80003c64 <iunlock>
  iput(p->cwd);
    80005dd4:	15093503          	ld	a0,336(s2)
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	f84080e7          	jalr	-124(ra) # 80003d5c <iput>
  end_op();
    80005de0:	ffffe097          	auipc	ra,0xffffe
    80005de4:	7e2080e7          	jalr	2018(ra) # 800045c2 <end_op>
  p->cwd = ip;
    80005de8:	14993823          	sd	s1,336(s2)
  return 0;
    80005dec:	4501                	li	a0,0
}
    80005dee:	60ea                	ld	ra,152(sp)
    80005df0:	644a                	ld	s0,144(sp)
    80005df2:	64aa                	ld	s1,136(sp)
    80005df4:	690a                	ld	s2,128(sp)
    80005df6:	610d                	addi	sp,sp,160
    80005df8:	8082                	ret
    end_op();
    80005dfa:	ffffe097          	auipc	ra,0xffffe
    80005dfe:	7c8080e7          	jalr	1992(ra) # 800045c2 <end_op>
    return -1;
    80005e02:	557d                	li	a0,-1
    80005e04:	b7ed                	j	80005dee <sys_chdir+0x7a>
    iunlockput(ip);
    80005e06:	8526                	mv	a0,s1
    80005e08:	ffffe097          	auipc	ra,0xffffe
    80005e0c:	ffc080e7          	jalr	-4(ra) # 80003e04 <iunlockput>
    end_op();
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	7b2080e7          	jalr	1970(ra) # 800045c2 <end_op>
    return -1;
    80005e18:	557d                	li	a0,-1
    80005e1a:	bfd1                	j	80005dee <sys_chdir+0x7a>

0000000080005e1c <sys_exec>:

uint64
sys_exec(void)
{
    80005e1c:	7121                	addi	sp,sp,-448
    80005e1e:	ff06                	sd	ra,440(sp)
    80005e20:	fb22                	sd	s0,432(sp)
    80005e22:	f726                	sd	s1,424(sp)
    80005e24:	f34a                	sd	s2,416(sp)
    80005e26:	ef4e                	sd	s3,408(sp)
    80005e28:	eb52                	sd	s4,400(sp)
    80005e2a:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e2c:	e4840593          	addi	a1,s0,-440
    80005e30:	4505                	li	a0,1
    80005e32:	ffffd097          	auipc	ra,0xffffd
    80005e36:	0b6080e7          	jalr	182(ra) # 80002ee8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e3a:	08000613          	li	a2,128
    80005e3e:	f5040593          	addi	a1,s0,-176
    80005e42:	4501                	li	a0,0
    80005e44:	ffffd097          	auipc	ra,0xffffd
    80005e48:	0c4080e7          	jalr	196(ra) # 80002f08 <argstr>
    80005e4c:	87aa                	mv	a5,a0
    return -1;
    80005e4e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e50:	0c07c263          	bltz	a5,80005f14 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005e54:	10000613          	li	a2,256
    80005e58:	4581                	li	a1,0
    80005e5a:	e5040513          	addi	a0,s0,-432
    80005e5e:	ffffb097          	auipc	ra,0xffffb
    80005e62:	f38080e7          	jalr	-200(ra) # 80000d96 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e66:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005e6a:	89a6                	mv	s3,s1
    80005e6c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e6e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e72:	00391513          	slli	a0,s2,0x3
    80005e76:	e4040593          	addi	a1,s0,-448
    80005e7a:	e4843783          	ld	a5,-440(s0)
    80005e7e:	953e                	add	a0,a0,a5
    80005e80:	ffffd097          	auipc	ra,0xffffd
    80005e84:	faa080e7          	jalr	-86(ra) # 80002e2a <fetchaddr>
    80005e88:	02054a63          	bltz	a0,80005ebc <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005e8c:	e4043783          	ld	a5,-448(s0)
    80005e90:	c3b9                	beqz	a5,80005ed6 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e92:	ffffb097          	auipc	ra,0xffffb
    80005e96:	ccc080e7          	jalr	-820(ra) # 80000b5e <kalloc>
    80005e9a:	85aa                	mv	a1,a0
    80005e9c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ea0:	cd11                	beqz	a0,80005ebc <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ea2:	6605                	lui	a2,0x1
    80005ea4:	e4043503          	ld	a0,-448(s0)
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	fd4080e7          	jalr	-44(ra) # 80002e7c <fetchstr>
    80005eb0:	00054663          	bltz	a0,80005ebc <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005eb4:	0905                	addi	s2,s2,1
    80005eb6:	09a1                	addi	s3,s3,8
    80005eb8:	fb491de3          	bne	s2,s4,80005e72 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ebc:	f5040913          	addi	s2,s0,-176
    80005ec0:	6088                	ld	a0,0(s1)
    80005ec2:	c921                	beqz	a0,80005f12 <sys_exec+0xf6>
    kfree(argv[i]);
    80005ec4:	ffffb097          	auipc	ra,0xffffb
    80005ec8:	b32080e7          	jalr	-1230(ra) # 800009f6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ecc:	04a1                	addi	s1,s1,8
    80005ece:	ff2499e3          	bne	s1,s2,80005ec0 <sys_exec+0xa4>
  return -1;
    80005ed2:	557d                	li	a0,-1
    80005ed4:	a081                	j	80005f14 <sys_exec+0xf8>
      argv[i] = 0;
    80005ed6:	0009079b          	sext.w	a5,s2
    80005eda:	078e                	slli	a5,a5,0x3
    80005edc:	fd078793          	addi	a5,a5,-48
    80005ee0:	97a2                	add	a5,a5,s0
    80005ee2:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ee6:	e5040593          	addi	a1,s0,-432
    80005eea:	f5040513          	addi	a0,s0,-176
    80005eee:	fffff097          	auipc	ra,0xfffff
    80005ef2:	194080e7          	jalr	404(ra) # 80005082 <exec>
    80005ef6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ef8:	f5040993          	addi	s3,s0,-176
    80005efc:	6088                	ld	a0,0(s1)
    80005efe:	c901                	beqz	a0,80005f0e <sys_exec+0xf2>
    kfree(argv[i]);
    80005f00:	ffffb097          	auipc	ra,0xffffb
    80005f04:	af6080e7          	jalr	-1290(ra) # 800009f6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f08:	04a1                	addi	s1,s1,8
    80005f0a:	ff3499e3          	bne	s1,s3,80005efc <sys_exec+0xe0>
  return ret;
    80005f0e:	854a                	mv	a0,s2
    80005f10:	a011                	j	80005f14 <sys_exec+0xf8>
  return -1;
    80005f12:	557d                	li	a0,-1
}
    80005f14:	70fa                	ld	ra,440(sp)
    80005f16:	745a                	ld	s0,432(sp)
    80005f18:	74ba                	ld	s1,424(sp)
    80005f1a:	791a                	ld	s2,416(sp)
    80005f1c:	69fa                	ld	s3,408(sp)
    80005f1e:	6a5a                	ld	s4,400(sp)
    80005f20:	6139                	addi	sp,sp,448
    80005f22:	8082                	ret

0000000080005f24 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f24:	7139                	addi	sp,sp,-64
    80005f26:	fc06                	sd	ra,56(sp)
    80005f28:	f822                	sd	s0,48(sp)
    80005f2a:	f426                	sd	s1,40(sp)
    80005f2c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f2e:	ffffc097          	auipc	ra,0xffffc
    80005f32:	c34080e7          	jalr	-972(ra) # 80001b62 <myproc>
    80005f36:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f38:	fd840593          	addi	a1,s0,-40
    80005f3c:	4501                	li	a0,0
    80005f3e:	ffffd097          	auipc	ra,0xffffd
    80005f42:	faa080e7          	jalr	-86(ra) # 80002ee8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f46:	fc840593          	addi	a1,s0,-56
    80005f4a:	fd040513          	addi	a0,s0,-48
    80005f4e:	fffff097          	auipc	ra,0xfffff
    80005f52:	dea080e7          	jalr	-534(ra) # 80004d38 <pipealloc>
    return -1;
    80005f56:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f58:	0c054463          	bltz	a0,80006020 <sys_pipe+0xfc>
  fd0 = -1;
    80005f5c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f60:	fd043503          	ld	a0,-48(s0)
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	524080e7          	jalr	1316(ra) # 80005488 <fdalloc>
    80005f6c:	fca42223          	sw	a0,-60(s0)
    80005f70:	08054b63          	bltz	a0,80006006 <sys_pipe+0xe2>
    80005f74:	fc843503          	ld	a0,-56(s0)
    80005f78:	fffff097          	auipc	ra,0xfffff
    80005f7c:	510080e7          	jalr	1296(ra) # 80005488 <fdalloc>
    80005f80:	fca42023          	sw	a0,-64(s0)
    80005f84:	06054863          	bltz	a0,80005ff4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f88:	4691                	li	a3,4
    80005f8a:	fc440613          	addi	a2,s0,-60
    80005f8e:	fd843583          	ld	a1,-40(s0)
    80005f92:	68a8                	ld	a0,80(s1)
    80005f94:	ffffb097          	auipc	ra,0xffffb
    80005f98:	79a080e7          	jalr	1946(ra) # 8000172e <copyout>
    80005f9c:	02054063          	bltz	a0,80005fbc <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005fa0:	4691                	li	a3,4
    80005fa2:	fc040613          	addi	a2,s0,-64
    80005fa6:	fd843583          	ld	a1,-40(s0)
    80005faa:	0591                	addi	a1,a1,4
    80005fac:	68a8                	ld	a0,80(s1)
    80005fae:	ffffb097          	auipc	ra,0xffffb
    80005fb2:	780080e7          	jalr	1920(ra) # 8000172e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fb6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fb8:	06055463          	bgez	a0,80006020 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005fbc:	fc442783          	lw	a5,-60(s0)
    80005fc0:	07e9                	addi	a5,a5,26
    80005fc2:	078e                	slli	a5,a5,0x3
    80005fc4:	97a6                	add	a5,a5,s1
    80005fc6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fca:	fc042783          	lw	a5,-64(s0)
    80005fce:	07e9                	addi	a5,a5,26
    80005fd0:	078e                	slli	a5,a5,0x3
    80005fd2:	94be                	add	s1,s1,a5
    80005fd4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fd8:	fd043503          	ld	a0,-48(s0)
    80005fdc:	fffff097          	auipc	ra,0xfffff
    80005fe0:	a30080e7          	jalr	-1488(ra) # 80004a0c <fileclose>
    fileclose(wf);
    80005fe4:	fc843503          	ld	a0,-56(s0)
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	a24080e7          	jalr	-1500(ra) # 80004a0c <fileclose>
    return -1;
    80005ff0:	57fd                	li	a5,-1
    80005ff2:	a03d                	j	80006020 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ff4:	fc442783          	lw	a5,-60(s0)
    80005ff8:	0007c763          	bltz	a5,80006006 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ffc:	07e9                	addi	a5,a5,26
    80005ffe:	078e                	slli	a5,a5,0x3
    80006000:	97a6                	add	a5,a5,s1
    80006002:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006006:	fd043503          	ld	a0,-48(s0)
    8000600a:	fffff097          	auipc	ra,0xfffff
    8000600e:	a02080e7          	jalr	-1534(ra) # 80004a0c <fileclose>
    fileclose(wf);
    80006012:	fc843503          	ld	a0,-56(s0)
    80006016:	fffff097          	auipc	ra,0xfffff
    8000601a:	9f6080e7          	jalr	-1546(ra) # 80004a0c <fileclose>
    return -1;
    8000601e:	57fd                	li	a5,-1
}
    80006020:	853e                	mv	a0,a5
    80006022:	70e2                	ld	ra,56(sp)
    80006024:	7442                	ld	s0,48(sp)
    80006026:	74a2                	ld	s1,40(sp)
    80006028:	6121                	addi	sp,sp,64
    8000602a:	8082                	ret
    8000602c:	0000                	unimp
	...

0000000080006030 <kernelvec>:
    80006030:	7111                	addi	sp,sp,-256
    80006032:	e006                	sd	ra,0(sp)
    80006034:	e40a                	sd	sp,8(sp)
    80006036:	e80e                	sd	gp,16(sp)
    80006038:	ec12                	sd	tp,24(sp)
    8000603a:	f016                	sd	t0,32(sp)
    8000603c:	f41a                	sd	t1,40(sp)
    8000603e:	f81e                	sd	t2,48(sp)
    80006040:	fc22                	sd	s0,56(sp)
    80006042:	e0a6                	sd	s1,64(sp)
    80006044:	e4aa                	sd	a0,72(sp)
    80006046:	e8ae                	sd	a1,80(sp)
    80006048:	ecb2                	sd	a2,88(sp)
    8000604a:	f0b6                	sd	a3,96(sp)
    8000604c:	f4ba                	sd	a4,104(sp)
    8000604e:	f8be                	sd	a5,112(sp)
    80006050:	fcc2                	sd	a6,120(sp)
    80006052:	e146                	sd	a7,128(sp)
    80006054:	e54a                	sd	s2,136(sp)
    80006056:	e94e                	sd	s3,144(sp)
    80006058:	ed52                	sd	s4,152(sp)
    8000605a:	f156                	sd	s5,160(sp)
    8000605c:	f55a                	sd	s6,168(sp)
    8000605e:	f95e                	sd	s7,176(sp)
    80006060:	fd62                	sd	s8,184(sp)
    80006062:	e1e6                	sd	s9,192(sp)
    80006064:	e5ea                	sd	s10,200(sp)
    80006066:	e9ee                	sd	s11,208(sp)
    80006068:	edf2                	sd	t3,216(sp)
    8000606a:	f1f6                	sd	t4,224(sp)
    8000606c:	f5fa                	sd	t5,232(sp)
    8000606e:	f9fe                	sd	t6,240(sp)
    80006070:	c87fc0ef          	jal	ra,80002cf6 <kerneltrap>
    80006074:	6082                	ld	ra,0(sp)
    80006076:	6122                	ld	sp,8(sp)
    80006078:	61c2                	ld	gp,16(sp)
    8000607a:	7282                	ld	t0,32(sp)
    8000607c:	7322                	ld	t1,40(sp)
    8000607e:	73c2                	ld	t2,48(sp)
    80006080:	7462                	ld	s0,56(sp)
    80006082:	6486                	ld	s1,64(sp)
    80006084:	6526                	ld	a0,72(sp)
    80006086:	65c6                	ld	a1,80(sp)
    80006088:	6666                	ld	a2,88(sp)
    8000608a:	7686                	ld	a3,96(sp)
    8000608c:	7726                	ld	a4,104(sp)
    8000608e:	77c6                	ld	a5,112(sp)
    80006090:	7866                	ld	a6,120(sp)
    80006092:	688a                	ld	a7,128(sp)
    80006094:	692a                	ld	s2,136(sp)
    80006096:	69ca                	ld	s3,144(sp)
    80006098:	6a6a                	ld	s4,152(sp)
    8000609a:	7a8a                	ld	s5,160(sp)
    8000609c:	7b2a                	ld	s6,168(sp)
    8000609e:	7bca                	ld	s7,176(sp)
    800060a0:	7c6a                	ld	s8,184(sp)
    800060a2:	6c8e                	ld	s9,192(sp)
    800060a4:	6d2e                	ld	s10,200(sp)
    800060a6:	6dce                	ld	s11,208(sp)
    800060a8:	6e6e                	ld	t3,216(sp)
    800060aa:	7e8e                	ld	t4,224(sp)
    800060ac:	7f2e                	ld	t5,232(sp)
    800060ae:	7fce                	ld	t6,240(sp)
    800060b0:	6111                	addi	sp,sp,256
    800060b2:	10200073          	sret
    800060b6:	00000013          	nop
    800060ba:	00000013          	nop
    800060be:	0001                	nop

00000000800060c0 <timervec>:
    800060c0:	34051573          	csrrw	a0,mscratch,a0
    800060c4:	e10c                	sd	a1,0(a0)
    800060c6:	e510                	sd	a2,8(a0)
    800060c8:	e914                	sd	a3,16(a0)
    800060ca:	6d0c                	ld	a1,24(a0)
    800060cc:	7110                	ld	a2,32(a0)
    800060ce:	6194                	ld	a3,0(a1)
    800060d0:	96b2                	add	a3,a3,a2
    800060d2:	e194                	sd	a3,0(a1)
    800060d4:	4589                	li	a1,2
    800060d6:	14459073          	csrw	sip,a1
    800060da:	6914                	ld	a3,16(a0)
    800060dc:	6510                	ld	a2,8(a0)
    800060de:	610c                	ld	a1,0(a0)
    800060e0:	34051573          	csrrw	a0,mscratch,a0
    800060e4:	30200073          	mret
	...

00000000800060ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060ea:	1141                	addi	sp,sp,-16
    800060ec:	e422                	sd	s0,8(sp)
    800060ee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060f0:	0c0007b7          	lui	a5,0xc000
    800060f4:	4705                	li	a4,1
    800060f6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060f8:	c3d8                	sw	a4,4(a5)
}
    800060fa:	6422                	ld	s0,8(sp)
    800060fc:	0141                	addi	sp,sp,16
    800060fe:	8082                	ret

0000000080006100 <plicinithart>:

void
plicinithart(void)
{
    80006100:	1141                	addi	sp,sp,-16
    80006102:	e406                	sd	ra,8(sp)
    80006104:	e022                	sd	s0,0(sp)
    80006106:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006108:	ffffc097          	auipc	ra,0xffffc
    8000610c:	a2e080e7          	jalr	-1490(ra) # 80001b36 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006110:	0085171b          	slliw	a4,a0,0x8
    80006114:	0c0027b7          	lui	a5,0xc002
    80006118:	97ba                	add	a5,a5,a4
    8000611a:	40200713          	li	a4,1026
    8000611e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006122:	00d5151b          	slliw	a0,a0,0xd
    80006126:	0c2017b7          	lui	a5,0xc201
    8000612a:	97aa                	add	a5,a5,a0
    8000612c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006130:	60a2                	ld	ra,8(sp)
    80006132:	6402                	ld	s0,0(sp)
    80006134:	0141                	addi	sp,sp,16
    80006136:	8082                	ret

0000000080006138 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006138:	1141                	addi	sp,sp,-16
    8000613a:	e406                	sd	ra,8(sp)
    8000613c:	e022                	sd	s0,0(sp)
    8000613e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006140:	ffffc097          	auipc	ra,0xffffc
    80006144:	9f6080e7          	jalr	-1546(ra) # 80001b36 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006148:	00d5151b          	slliw	a0,a0,0xd
    8000614c:	0c2017b7          	lui	a5,0xc201
    80006150:	97aa                	add	a5,a5,a0
  return irq;
}
    80006152:	43c8                	lw	a0,4(a5)
    80006154:	60a2                	ld	ra,8(sp)
    80006156:	6402                	ld	s0,0(sp)
    80006158:	0141                	addi	sp,sp,16
    8000615a:	8082                	ret

000000008000615c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000615c:	1101                	addi	sp,sp,-32
    8000615e:	ec06                	sd	ra,24(sp)
    80006160:	e822                	sd	s0,16(sp)
    80006162:	e426                	sd	s1,8(sp)
    80006164:	1000                	addi	s0,sp,32
    80006166:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006168:	ffffc097          	auipc	ra,0xffffc
    8000616c:	9ce080e7          	jalr	-1586(ra) # 80001b36 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006170:	00d5151b          	slliw	a0,a0,0xd
    80006174:	0c2017b7          	lui	a5,0xc201
    80006178:	97aa                	add	a5,a5,a0
    8000617a:	c3c4                	sw	s1,4(a5)
}
    8000617c:	60e2                	ld	ra,24(sp)
    8000617e:	6442                	ld	s0,16(sp)
    80006180:	64a2                	ld	s1,8(sp)
    80006182:	6105                	addi	sp,sp,32
    80006184:	8082                	ret

0000000080006186 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006186:	1141                	addi	sp,sp,-16
    80006188:	e406                	sd	ra,8(sp)
    8000618a:	e022                	sd	s0,0(sp)
    8000618c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000618e:	479d                	li	a5,7
    80006190:	04a7cc63          	blt	a5,a0,800061e8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006194:	0001c797          	auipc	a5,0x1c
    80006198:	c1c78793          	addi	a5,a5,-996 # 80021db0 <disk>
    8000619c:	97aa                	add	a5,a5,a0
    8000619e:	0187c783          	lbu	a5,24(a5)
    800061a2:	ebb9                	bnez	a5,800061f8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800061a4:	00451693          	slli	a3,a0,0x4
    800061a8:	0001c797          	auipc	a5,0x1c
    800061ac:	c0878793          	addi	a5,a5,-1016 # 80021db0 <disk>
    800061b0:	6398                	ld	a4,0(a5)
    800061b2:	9736                	add	a4,a4,a3
    800061b4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800061b8:	6398                	ld	a4,0(a5)
    800061ba:	9736                	add	a4,a4,a3
    800061bc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800061c0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800061c4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800061c8:	97aa                	add	a5,a5,a0
    800061ca:	4705                	li	a4,1
    800061cc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800061d0:	0001c517          	auipc	a0,0x1c
    800061d4:	bf850513          	addi	a0,a0,-1032 # 80021dc8 <disk+0x18>
    800061d8:	ffffc097          	auipc	ra,0xffffc
    800061dc:	156080e7          	jalr	342(ra) # 8000232e <wakeup>
}
    800061e0:	60a2                	ld	ra,8(sp)
    800061e2:	6402                	ld	s0,0(sp)
    800061e4:	0141                	addi	sp,sp,16
    800061e6:	8082                	ret
    panic("free_desc 1");
    800061e8:	00002517          	auipc	a0,0x2
    800061ec:	6c850513          	addi	a0,a0,1736 # 800088b0 <syscalls+0x338>
    800061f0:	ffffa097          	auipc	ra,0xffffa
    800061f4:	34c080e7          	jalr	844(ra) # 8000053c <panic>
    panic("free_desc 2");
    800061f8:	00002517          	auipc	a0,0x2
    800061fc:	6c850513          	addi	a0,a0,1736 # 800088c0 <syscalls+0x348>
    80006200:	ffffa097          	auipc	ra,0xffffa
    80006204:	33c080e7          	jalr	828(ra) # 8000053c <panic>

0000000080006208 <virtio_disk_init>:
{
    80006208:	1101                	addi	sp,sp,-32
    8000620a:	ec06                	sd	ra,24(sp)
    8000620c:	e822                	sd	s0,16(sp)
    8000620e:	e426                	sd	s1,8(sp)
    80006210:	e04a                	sd	s2,0(sp)
    80006212:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006214:	00002597          	auipc	a1,0x2
    80006218:	6bc58593          	addi	a1,a1,1724 # 800088d0 <syscalls+0x358>
    8000621c:	0001c517          	auipc	a0,0x1c
    80006220:	cbc50513          	addi	a0,a0,-836 # 80021ed8 <disk+0x128>
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	9e6080e7          	jalr	-1562(ra) # 80000c0a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000622c:	100017b7          	lui	a5,0x10001
    80006230:	4398                	lw	a4,0(a5)
    80006232:	2701                	sext.w	a4,a4
    80006234:	747277b7          	lui	a5,0x74727
    80006238:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000623c:	14f71b63          	bne	a4,a5,80006392 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006240:	100017b7          	lui	a5,0x10001
    80006244:	43dc                	lw	a5,4(a5)
    80006246:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006248:	4709                	li	a4,2
    8000624a:	14e79463          	bne	a5,a4,80006392 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000624e:	100017b7          	lui	a5,0x10001
    80006252:	479c                	lw	a5,8(a5)
    80006254:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006256:	12e79e63          	bne	a5,a4,80006392 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000625a:	100017b7          	lui	a5,0x10001
    8000625e:	47d8                	lw	a4,12(a5)
    80006260:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006262:	554d47b7          	lui	a5,0x554d4
    80006266:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000626a:	12f71463          	bne	a4,a5,80006392 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000626e:	100017b7          	lui	a5,0x10001
    80006272:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006276:	4705                	li	a4,1
    80006278:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000627a:	470d                	li	a4,3
    8000627c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000627e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006280:	c7ffe6b7          	lui	a3,0xc7ffe
    80006284:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc86f>
    80006288:	8f75                	and	a4,a4,a3
    8000628a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000628c:	472d                	li	a4,11
    8000628e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006290:	5bbc                	lw	a5,112(a5)
    80006292:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006296:	8ba1                	andi	a5,a5,8
    80006298:	10078563          	beqz	a5,800063a2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000629c:	100017b7          	lui	a5,0x10001
    800062a0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800062a4:	43fc                	lw	a5,68(a5)
    800062a6:	2781                	sext.w	a5,a5
    800062a8:	10079563          	bnez	a5,800063b2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062ac:	100017b7          	lui	a5,0x10001
    800062b0:	5bdc                	lw	a5,52(a5)
    800062b2:	2781                	sext.w	a5,a5
  if(max == 0)
    800062b4:	10078763          	beqz	a5,800063c2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800062b8:	471d                	li	a4,7
    800062ba:	10f77c63          	bgeu	a4,a5,800063d2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800062be:	ffffb097          	auipc	ra,0xffffb
    800062c2:	8a0080e7          	jalr	-1888(ra) # 80000b5e <kalloc>
    800062c6:	0001c497          	auipc	s1,0x1c
    800062ca:	aea48493          	addi	s1,s1,-1302 # 80021db0 <disk>
    800062ce:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062d0:	ffffb097          	auipc	ra,0xffffb
    800062d4:	88e080e7          	jalr	-1906(ra) # 80000b5e <kalloc>
    800062d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062da:	ffffb097          	auipc	ra,0xffffb
    800062de:	884080e7          	jalr	-1916(ra) # 80000b5e <kalloc>
    800062e2:	87aa                	mv	a5,a0
    800062e4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062e6:	6088                	ld	a0,0(s1)
    800062e8:	cd6d                	beqz	a0,800063e2 <virtio_disk_init+0x1da>
    800062ea:	0001c717          	auipc	a4,0x1c
    800062ee:	ace73703          	ld	a4,-1330(a4) # 80021db8 <disk+0x8>
    800062f2:	cb65                	beqz	a4,800063e2 <virtio_disk_init+0x1da>
    800062f4:	c7fd                	beqz	a5,800063e2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800062f6:	6605                	lui	a2,0x1
    800062f8:	4581                	li	a1,0
    800062fa:	ffffb097          	auipc	ra,0xffffb
    800062fe:	a9c080e7          	jalr	-1380(ra) # 80000d96 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006302:	0001c497          	auipc	s1,0x1c
    80006306:	aae48493          	addi	s1,s1,-1362 # 80021db0 <disk>
    8000630a:	6605                	lui	a2,0x1
    8000630c:	4581                	li	a1,0
    8000630e:	6488                	ld	a0,8(s1)
    80006310:	ffffb097          	auipc	ra,0xffffb
    80006314:	a86080e7          	jalr	-1402(ra) # 80000d96 <memset>
  memset(disk.used, 0, PGSIZE);
    80006318:	6605                	lui	a2,0x1
    8000631a:	4581                	li	a1,0
    8000631c:	6888                	ld	a0,16(s1)
    8000631e:	ffffb097          	auipc	ra,0xffffb
    80006322:	a78080e7          	jalr	-1416(ra) # 80000d96 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006326:	100017b7          	lui	a5,0x10001
    8000632a:	4721                	li	a4,8
    8000632c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000632e:	4098                	lw	a4,0(s1)
    80006330:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006334:	40d8                	lw	a4,4(s1)
    80006336:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000633a:	6498                	ld	a4,8(s1)
    8000633c:	0007069b          	sext.w	a3,a4
    80006340:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006344:	9701                	srai	a4,a4,0x20
    80006346:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000634a:	6898                	ld	a4,16(s1)
    8000634c:	0007069b          	sext.w	a3,a4
    80006350:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006354:	9701                	srai	a4,a4,0x20
    80006356:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000635a:	4705                	li	a4,1
    8000635c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000635e:	00e48c23          	sb	a4,24(s1)
    80006362:	00e48ca3          	sb	a4,25(s1)
    80006366:	00e48d23          	sb	a4,26(s1)
    8000636a:	00e48da3          	sb	a4,27(s1)
    8000636e:	00e48e23          	sb	a4,28(s1)
    80006372:	00e48ea3          	sb	a4,29(s1)
    80006376:	00e48f23          	sb	a4,30(s1)
    8000637a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000637e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006382:	0727a823          	sw	s2,112(a5)
}
    80006386:	60e2                	ld	ra,24(sp)
    80006388:	6442                	ld	s0,16(sp)
    8000638a:	64a2                	ld	s1,8(sp)
    8000638c:	6902                	ld	s2,0(sp)
    8000638e:	6105                	addi	sp,sp,32
    80006390:	8082                	ret
    panic("could not find virtio disk");
    80006392:	00002517          	auipc	a0,0x2
    80006396:	54e50513          	addi	a0,a0,1358 # 800088e0 <syscalls+0x368>
    8000639a:	ffffa097          	auipc	ra,0xffffa
    8000639e:	1a2080e7          	jalr	418(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    800063a2:	00002517          	auipc	a0,0x2
    800063a6:	55e50513          	addi	a0,a0,1374 # 80008900 <syscalls+0x388>
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	192080e7          	jalr	402(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800063b2:	00002517          	auipc	a0,0x2
    800063b6:	56e50513          	addi	a0,a0,1390 # 80008920 <syscalls+0x3a8>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	182080e7          	jalr	386(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800063c2:	00002517          	auipc	a0,0x2
    800063c6:	57e50513          	addi	a0,a0,1406 # 80008940 <syscalls+0x3c8>
    800063ca:	ffffa097          	auipc	ra,0xffffa
    800063ce:	172080e7          	jalr	370(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800063d2:	00002517          	auipc	a0,0x2
    800063d6:	58e50513          	addi	a0,a0,1422 # 80008960 <syscalls+0x3e8>
    800063da:	ffffa097          	auipc	ra,0xffffa
    800063de:	162080e7          	jalr	354(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800063e2:	00002517          	auipc	a0,0x2
    800063e6:	59e50513          	addi	a0,a0,1438 # 80008980 <syscalls+0x408>
    800063ea:	ffffa097          	auipc	ra,0xffffa
    800063ee:	152080e7          	jalr	338(ra) # 8000053c <panic>

00000000800063f2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063f2:	7159                	addi	sp,sp,-112
    800063f4:	f486                	sd	ra,104(sp)
    800063f6:	f0a2                	sd	s0,96(sp)
    800063f8:	eca6                	sd	s1,88(sp)
    800063fa:	e8ca                	sd	s2,80(sp)
    800063fc:	e4ce                	sd	s3,72(sp)
    800063fe:	e0d2                	sd	s4,64(sp)
    80006400:	fc56                	sd	s5,56(sp)
    80006402:	f85a                	sd	s6,48(sp)
    80006404:	f45e                	sd	s7,40(sp)
    80006406:	f062                	sd	s8,32(sp)
    80006408:	ec66                	sd	s9,24(sp)
    8000640a:	e86a                	sd	s10,16(sp)
    8000640c:	1880                	addi	s0,sp,112
    8000640e:	8a2a                	mv	s4,a0
    80006410:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006412:	00c52c83          	lw	s9,12(a0)
    80006416:	001c9c9b          	slliw	s9,s9,0x1
    8000641a:	1c82                	slli	s9,s9,0x20
    8000641c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006420:	0001c517          	auipc	a0,0x1c
    80006424:	ab850513          	addi	a0,a0,-1352 # 80021ed8 <disk+0x128>
    80006428:	ffffb097          	auipc	ra,0xffffb
    8000642c:	872080e7          	jalr	-1934(ra) # 80000c9a <acquire>
  for(int i = 0; i < 3; i++){
    80006430:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006432:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006434:	0001cb17          	auipc	s6,0x1c
    80006438:	97cb0b13          	addi	s6,s6,-1668 # 80021db0 <disk>
  for(int i = 0; i < 3; i++){
    8000643c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000643e:	0001cc17          	auipc	s8,0x1c
    80006442:	a9ac0c13          	addi	s8,s8,-1382 # 80021ed8 <disk+0x128>
    80006446:	a095                	j	800064aa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006448:	00fb0733          	add	a4,s6,a5
    8000644c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006450:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006452:	0207c563          	bltz	a5,8000647c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006456:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006458:	0591                	addi	a1,a1,4
    8000645a:	05560d63          	beq	a2,s5,800064b4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000645e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006460:	0001c717          	auipc	a4,0x1c
    80006464:	95070713          	addi	a4,a4,-1712 # 80021db0 <disk>
    80006468:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000646a:	01874683          	lbu	a3,24(a4)
    8000646e:	fee9                	bnez	a3,80006448 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006470:	2785                	addiw	a5,a5,1
    80006472:	0705                	addi	a4,a4,1
    80006474:	fe979be3          	bne	a5,s1,8000646a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006478:	57fd                	li	a5,-1
    8000647a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000647c:	00c05e63          	blez	a2,80006498 <virtio_disk_rw+0xa6>
    80006480:	060a                	slli	a2,a2,0x2
    80006482:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006486:	0009a503          	lw	a0,0(s3)
    8000648a:	00000097          	auipc	ra,0x0
    8000648e:	cfc080e7          	jalr	-772(ra) # 80006186 <free_desc>
      for(int j = 0; j < i; j++)
    80006492:	0991                	addi	s3,s3,4
    80006494:	ffa999e3          	bne	s3,s10,80006486 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006498:	85e2                	mv	a1,s8
    8000649a:	0001c517          	auipc	a0,0x1c
    8000649e:	92e50513          	addi	a0,a0,-1746 # 80021dc8 <disk+0x18>
    800064a2:	ffffc097          	auipc	ra,0xffffc
    800064a6:	e28080e7          	jalr	-472(ra) # 800022ca <sleep>
  for(int i = 0; i < 3; i++){
    800064aa:	f9040993          	addi	s3,s0,-112
{
    800064ae:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800064b0:	864a                	mv	a2,s2
    800064b2:	b775                	j	8000645e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064b4:	f9042503          	lw	a0,-112(s0)
    800064b8:	00a50713          	addi	a4,a0,10
    800064bc:	0712                	slli	a4,a4,0x4

  if(write)
    800064be:	0001c797          	auipc	a5,0x1c
    800064c2:	8f278793          	addi	a5,a5,-1806 # 80021db0 <disk>
    800064c6:	00e786b3          	add	a3,a5,a4
    800064ca:	01703633          	snez	a2,s7
    800064ce:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064d0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800064d4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064d8:	f6070613          	addi	a2,a4,-160
    800064dc:	6394                	ld	a3,0(a5)
    800064de:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064e0:	00870593          	addi	a1,a4,8
    800064e4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064e6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064e8:	0007b803          	ld	a6,0(a5)
    800064ec:	9642                	add	a2,a2,a6
    800064ee:	46c1                	li	a3,16
    800064f0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064f2:	4585                	li	a1,1
    800064f4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800064f8:	f9442683          	lw	a3,-108(s0)
    800064fc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006500:	0692                	slli	a3,a3,0x4
    80006502:	9836                	add	a6,a6,a3
    80006504:	058a0613          	addi	a2,s4,88
    80006508:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000650c:	0007b803          	ld	a6,0(a5)
    80006510:	96c2                	add	a3,a3,a6
    80006512:	40000613          	li	a2,1024
    80006516:	c690                	sw	a2,8(a3)
  if(write)
    80006518:	001bb613          	seqz	a2,s7
    8000651c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006520:	00166613          	ori	a2,a2,1
    80006524:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006528:	f9842603          	lw	a2,-104(s0)
    8000652c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006530:	00250693          	addi	a3,a0,2
    80006534:	0692                	slli	a3,a3,0x4
    80006536:	96be                	add	a3,a3,a5
    80006538:	58fd                	li	a7,-1
    8000653a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000653e:	0612                	slli	a2,a2,0x4
    80006540:	9832                	add	a6,a6,a2
    80006542:	f9070713          	addi	a4,a4,-112
    80006546:	973e                	add	a4,a4,a5
    80006548:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000654c:	6398                	ld	a4,0(a5)
    8000654e:	9732                	add	a4,a4,a2
    80006550:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006552:	4609                	li	a2,2
    80006554:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006558:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000655c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006560:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006564:	6794                	ld	a3,8(a5)
    80006566:	0026d703          	lhu	a4,2(a3)
    8000656a:	8b1d                	andi	a4,a4,7
    8000656c:	0706                	slli	a4,a4,0x1
    8000656e:	96ba                	add	a3,a3,a4
    80006570:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006574:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006578:	6798                	ld	a4,8(a5)
    8000657a:	00275783          	lhu	a5,2(a4)
    8000657e:	2785                	addiw	a5,a5,1
    80006580:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006584:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006588:	100017b7          	lui	a5,0x10001
    8000658c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006590:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006594:	0001c917          	auipc	s2,0x1c
    80006598:	94490913          	addi	s2,s2,-1724 # 80021ed8 <disk+0x128>
  while(b->disk == 1) {
    8000659c:	4485                	li	s1,1
    8000659e:	00b79c63          	bne	a5,a1,800065b6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800065a2:	85ca                	mv	a1,s2
    800065a4:	8552                	mv	a0,s4
    800065a6:	ffffc097          	auipc	ra,0xffffc
    800065aa:	d24080e7          	jalr	-732(ra) # 800022ca <sleep>
  while(b->disk == 1) {
    800065ae:	004a2783          	lw	a5,4(s4)
    800065b2:	fe9788e3          	beq	a5,s1,800065a2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800065b6:	f9042903          	lw	s2,-112(s0)
    800065ba:	00290713          	addi	a4,s2,2
    800065be:	0712                	slli	a4,a4,0x4
    800065c0:	0001b797          	auipc	a5,0x1b
    800065c4:	7f078793          	addi	a5,a5,2032 # 80021db0 <disk>
    800065c8:	97ba                	add	a5,a5,a4
    800065ca:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800065ce:	0001b997          	auipc	s3,0x1b
    800065d2:	7e298993          	addi	s3,s3,2018 # 80021db0 <disk>
    800065d6:	00491713          	slli	a4,s2,0x4
    800065da:	0009b783          	ld	a5,0(s3)
    800065de:	97ba                	add	a5,a5,a4
    800065e0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065e4:	854a                	mv	a0,s2
    800065e6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065ea:	00000097          	auipc	ra,0x0
    800065ee:	b9c080e7          	jalr	-1124(ra) # 80006186 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065f2:	8885                	andi	s1,s1,1
    800065f4:	f0ed                	bnez	s1,800065d6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065f6:	0001c517          	auipc	a0,0x1c
    800065fa:	8e250513          	addi	a0,a0,-1822 # 80021ed8 <disk+0x128>
    800065fe:	ffffa097          	auipc	ra,0xffffa
    80006602:	750080e7          	jalr	1872(ra) # 80000d4e <release>
}
    80006606:	70a6                	ld	ra,104(sp)
    80006608:	7406                	ld	s0,96(sp)
    8000660a:	64e6                	ld	s1,88(sp)
    8000660c:	6946                	ld	s2,80(sp)
    8000660e:	69a6                	ld	s3,72(sp)
    80006610:	6a06                	ld	s4,64(sp)
    80006612:	7ae2                	ld	s5,56(sp)
    80006614:	7b42                	ld	s6,48(sp)
    80006616:	7ba2                	ld	s7,40(sp)
    80006618:	7c02                	ld	s8,32(sp)
    8000661a:	6ce2                	ld	s9,24(sp)
    8000661c:	6d42                	ld	s10,16(sp)
    8000661e:	6165                	addi	sp,sp,112
    80006620:	8082                	ret

0000000080006622 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006622:	1101                	addi	sp,sp,-32
    80006624:	ec06                	sd	ra,24(sp)
    80006626:	e822                	sd	s0,16(sp)
    80006628:	e426                	sd	s1,8(sp)
    8000662a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000662c:	0001b497          	auipc	s1,0x1b
    80006630:	78448493          	addi	s1,s1,1924 # 80021db0 <disk>
    80006634:	0001c517          	auipc	a0,0x1c
    80006638:	8a450513          	addi	a0,a0,-1884 # 80021ed8 <disk+0x128>
    8000663c:	ffffa097          	auipc	ra,0xffffa
    80006640:	65e080e7          	jalr	1630(ra) # 80000c9a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006644:	10001737          	lui	a4,0x10001
    80006648:	533c                	lw	a5,96(a4)
    8000664a:	8b8d                	andi	a5,a5,3
    8000664c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000664e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006652:	689c                	ld	a5,16(s1)
    80006654:	0204d703          	lhu	a4,32(s1)
    80006658:	0027d783          	lhu	a5,2(a5)
    8000665c:	04f70863          	beq	a4,a5,800066ac <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006660:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006664:	6898                	ld	a4,16(s1)
    80006666:	0204d783          	lhu	a5,32(s1)
    8000666a:	8b9d                	andi	a5,a5,7
    8000666c:	078e                	slli	a5,a5,0x3
    8000666e:	97ba                	add	a5,a5,a4
    80006670:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006672:	00278713          	addi	a4,a5,2
    80006676:	0712                	slli	a4,a4,0x4
    80006678:	9726                	add	a4,a4,s1
    8000667a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000667e:	e721                	bnez	a4,800066c6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006680:	0789                	addi	a5,a5,2
    80006682:	0792                	slli	a5,a5,0x4
    80006684:	97a6                	add	a5,a5,s1
    80006686:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006688:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000668c:	ffffc097          	auipc	ra,0xffffc
    80006690:	ca2080e7          	jalr	-862(ra) # 8000232e <wakeup>

    disk.used_idx += 1;
    80006694:	0204d783          	lhu	a5,32(s1)
    80006698:	2785                	addiw	a5,a5,1
    8000669a:	17c2                	slli	a5,a5,0x30
    8000669c:	93c1                	srli	a5,a5,0x30
    8000669e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800066a2:	6898                	ld	a4,16(s1)
    800066a4:	00275703          	lhu	a4,2(a4)
    800066a8:	faf71ce3          	bne	a4,a5,80006660 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800066ac:	0001c517          	auipc	a0,0x1c
    800066b0:	82c50513          	addi	a0,a0,-2004 # 80021ed8 <disk+0x128>
    800066b4:	ffffa097          	auipc	ra,0xffffa
    800066b8:	69a080e7          	jalr	1690(ra) # 80000d4e <release>
}
    800066bc:	60e2                	ld	ra,24(sp)
    800066be:	6442                	ld	s0,16(sp)
    800066c0:	64a2                	ld	s1,8(sp)
    800066c2:	6105                	addi	sp,sp,32
    800066c4:	8082                	ret
      panic("virtio_disk_intr status");
    800066c6:	00002517          	auipc	a0,0x2
    800066ca:	2d250513          	addi	a0,a0,722 # 80008998 <syscalls+0x420>
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	e6e080e7          	jalr	-402(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
