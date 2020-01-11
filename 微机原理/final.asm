.MODEL	TINY
;8259�궨��
I08259_0	EQU	0250H
I08259_1	EQU	0251H
;8255�궨��
COM_8255	EQU	0273H
PA_ADD	EQU	0270H
PB_ADD	EQU	0271H
PC_ADD  EQU     0272H
;8253�궨��
COM_ADDR EQU    0263H
T0_ADDR EQU     0260H
T1_ADDR EQU     0261H
	.STACK	100
	.DATA
;led�ƵĲ�ѯ��
LED_DATA	DB	11111111B
		DB	01111111B
		DB	00111111B
		DB	00011111B
		DB	00001111B
		DB	00000111B
		DB	00000011B
Counter	DB	?	;���ڼ���
Counter_1	DB ?
ReDisplayFlag	DB	0	;��־λ�������ж��Ƿ�����ж�
	.CODE
START:	MOV	AX,@DATA	;��ʼ��
	MOV	DS,AX
	MOV	ES,AX
	NOP
	CALL	Init8259
	CALL	Init8255
	CALL	WriIntver
	MOV	Counter,0
	MOV Counter_1,0
	STI
START1:		nop				;ִ�й���
	CMP		ReDisplayFlag,0	;�����жϲ��������־λ����Ϊ1���򲻻���ת��START1������ִ�����в���
	JZ		START1
	CALL	DLY5S			;5s��ʱ������ʵ�֣���5s��ʱ�䲦�����أ�Counter���¼��������
	MOV		ReDisplayFlag,0
	mov		al,Counter
	mov		Counter_1,al
	MOV		Counter,0
	CALL	LED				;led��ʾ����Counter���ڵ���6������˸��������в����ʾ����ִ�к�������
	CALL	DLY_WT			;����������ż���ӳ�1���2��
	CALL	MOVEMENT		;CounterС��6ʱ��������˲��裬�������еƵ��ƶ�
	
	JMP		START1
Init8255	PROC	NEAR	;8255��ʼ������
	MOV		AX,@DATA
	NOP
	MOV		DX,COM_8255
	MOV		AL,81H
	OUT		DX,AL		;A�����������81H=10000001
	MOV		DX,PA_ADD
	MOV		AL,0FFH
	OUT		DX,AL		;ͨ��A�˿��õ�ȫ��
	MOV		DX,PC_ADD
	MOV		AL,00H
	OUT		DX,AL		;��C�˿�ȫ���óɵ͵�ƽ
	RET
Init8255	ENDP
Init8259	PROC	NEAR	;8259��ʼ��
	MOV	DX,I08259_0
	MOV	AL,13H		;����icw1�����ش���
	OUT	DX,AL
	MOV	DX,I08259_1
	MOV	AL,08H		;����icw2
	OUT	DX,AL
	MOV	AL,19H		;����icw4������ȫǶ�ף����Զ�����
	OUT	DX,AL
	MOV	AL,0FBH		;����ocw1��IR2�жϣ�����Ҫ��IR2���жϴ򿪣�FB=11111011��0��ʾ��
	OUT	DX,AL
	RET
Init8259	ENDP
WriIntver	PROC	NEAR	;д�ж�
	PUSH	ES
	MOV		AX,0
	MOV		ES,AX
	MOV		DI,28H		;����icw2�����ģ�08H-0FH�ֱ��Ӧ��IR0-IR7���жϣ�IR2��0AH=00001010,������λ�õ���00101000=28H
	LEA		AX,INT_0
	STOSW
	MOV		AX,CS
	STOSW
	POP		ES
	RET
WriIntver	ENDP
LED	PROC	NEAR
	PUSH	DX
	PUSH	AX
	PUSH	BX
	PUSH	CX
	MOV		DX,PA_ADD
	MOV		AL,0FFH
	OUT		DX,AL
	MOV		CX,6		;������
	MOV		AL,Counter_1
	CMP		AL,6		;�жϴ������ڵ���6����С��6
	JA		FLASH
	LEA		BX,LED_DATA
	XLAT
	OUT		DX,AL
	JMP		LAST
FLASH: MOV	AL,00000000B
	OUT		DX,AL
	CALL	DLY500MS
	MOV		AL,11111111B
	OUT		DX,AL
	CALL	DLY500MS		;��˸ûҪ��Ҫ��Ӳ����ʱ�������õ��������ʱ��Ҳ�ɸĳ�call delay
	LOOP	FLASH
	JMP		START;��������6��˸��֮��ȫ������
LAST:	NOP
	POP	CX
	POP	BX
	POP	AX
	POP	DX
	ret
LED	ENDP
DLY500MS	PROC	NEAR		;500ms��ʱ�ӳ������ʵ�֣�
	PUSH	CX
	MOV		CX,60000
DL500MS1:	LOOP	DL500MS1
	POP	CX
	RET
DLY500MS	ENDP
DLY5S	PROC	NEAR		;5s��ʱ�ӳ������ʵ�֣�
	PUSH	CX
	MOV		CX,10
DLY5S1:	CALL	DLY500MS
	LOOP	DLY5S1
	POP		CX
	RET
DLY5S	ENDP

DELAY	PROC	NEAR		;1s��ʱ�ӳ���Ӳ��ʵ�֣�
	PUSH	DX
	PUSH	AX
	MOV		DX,COM_ADDR
	MOV		AL,31H
	OUT		DX,AL		;������T0������ģʽ0��BCD����
	MOV		DX,T0_ADDR
	MOV		AL,53H
	OUT		DX,AL
	MOV		AL,19H
	OUT		DX,AL		;��������0д���ֵ1953��CLK0-1953HZ����һ������Ҫ1/1953sʱ�䣬���1953������Ҫ1sʱ��
	XOR		AL,AL
	MOV		DX,PC_ADD	;��ʼ��ʼ��8255���ӳ������Ѿ���C��ȫ��дΪ�͵�ƽ��8253��ʱ����out0�˿��ǽ���8255��pc0�ϵ�
LP:	IN		AL,DX		;�ڸ�������0д��ֵʱ��ʹout0��Ϊ�͵�ƽ������������Ҳһֱ���ǵ͵�ƽ��ֻ���ڼ��������ˣ�out0�Ż��Ϊ�ߵ�ƽ
	AND		AL,01H		;�������ȡC�����һλ�����Ƿ�Ϊ�ߵ�ƽ����Ϊ�ߵ�ƽ��˵����������Ҳ���ǹ���1s
	JZ		LP
	POP		AX
	POP		DX
	RET
DELAY	ENDP

DLY_WT PROC NEAR
	MOV		AL,Counter_1
    AND		AL,01H
    JZ		EVEN11
	call 	DELAY
	jmp 	DONE
EVEN11:
	call DELAY
	call DELAY
DONE:
	ret
DLY_WT ENDP

MOVEMENT PROC  NEAR		;����С��6ʱ�������ӳ���
	 PUSH	DX
	 PUSH	AX
	 PUSH	BX
	 PUSH	CX
	 MOV	DX,PA_ADD
     MOV	AL,Counter_1
     AND	AL,01H;�ж���ż
     JZ		EVEN1
     MOV	AL,Counter_1
     LEA	BX,LED_DATA
     XLAT
ODD: 
	MOV 	AH,ReDisplayFlag
	CMP		AH,1
	JE		SHTDOWN
	ROR		AL,1;��
	OUT		DX,AL
	CALL	DELAY
    TEST	AL,01H
    JZ		SHTDOWN
    JMP		ODD
EVEN1:   MOV	AL,Counter_1;ż
	 LEA	BX,LED_DATA
	 XLAT
	 XOR	CX,CX
	 MOV	CL,2
EVEN3:
	mov 	ah,ReDisplayFlag
	cmp		ah,1
	JE		SHTDOWN	
	ROR	AL,CL
	OUT	DX,AL
	CALL	DELAY
	CALL	DELAY
	TEST	AL,01H
	JZ	SHTDOWN
	JMP	EVEN3
SHTDOWN:     MOV	DX,PA_ADD;Ϩ��
	MOV	AL,0FFH
    OUT	DX,AL
    POP	CX
    POP	BX
    POP	AX
    POP	DX
    RET
MOVEMENT ENDP

INT_0:	PUSH	DX		;�жϷ������ֻҪ�����˿��أ��ͽ��뵽�˳���
	PUSH	AX
	MOV		AL,Counter
	ADD		AL,1
	MOV		Counter,AL
	MOV		ReDisplayFlag,1
	MOV		DX,I08259_0;д��ocw2����ͨeoi������ʽ������ͬ���жϽ���
	MOV		AL,20H
	OUT		DX,AL
	POP		AX
	POP		DX
	IRET
	END		START

