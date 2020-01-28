; ------------------------------------------------------------------------------
; PROJECT	    : CLOCK
; AUTHOR	    : BIELEN PIERRE
; PIC		    : 18F452
; REQUIERED	    : p18LCD.asm
;		    : p18MATH.asm
;		    : p2plsp18.lkr
; BEGINING DATE	    : 2019/11/05
; ------------------------------------------------------------------------------

; PIC18F452 Configuration Bit Settings

; Assembly source line config statements
	list p=18f452
	#include p18f452.inc

; CONFIG1H
  CONFIG  OSC = HS            ; Oscillator Selection bits (RC oscillator w/ OSC2 configured as RA6)
  CONFIG  OSCS = OFF            ; Oscillator System Clock Switch Enable bit (Oscillator system clock switch option is disabled (main oscillator is source))

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = ON              ; Brown-out Reset Enable bit (Brown-out Reset enabled)
  CONFIG  BORV = 20             ; Brown-out Reset Voltage bits (VBOR set to 2.0V)

; CONFIG2H
  CONFIG  WDT = OFF              ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  WDTPS = 128           ; Watchdog Timer Postscale Select bits (1:128)

; CONFIG3H
  CONFIG  CCP2MUX = ON          ; CCP2 Mux bit (CCP2 input/output is multiplexed with RC1)

; CONFIG4L
  CONFIG  STVR = ON             ; Stack Full/Underflow Reset Enable bit (Stack Full/Underflow will cause RESET)
  CONFIG  LVP = ON              ; Low Voltage ICSP Enable bit (Low Voltage ICSP enabled)

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000200-001FFFh) not code protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot Block (000000-0001FFh) not code protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000200-001FFFh) not write protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block (000000-0001FFh) not write protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000200-001FFFh) not protected from Table Reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from Table Reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from Table Reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from Table Reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot Block (000000-0001FFh) not protected from Table Reads executed in other blocks)
;*******************************************************************************
; DEFINE SECTION
;*******************************************************************************
	#define select PORTA,4      ; BT s1 select
	#define scroll PORTB,0      ; BT s2 next
	#define led PORTB,3	    ; debuging led
	#define tic PORTD,7
	#define set_minutes mode_set_f,0    ; flag for set minute or hours
	#define mode_24 mode_set_f,1	    ; flag display hours 24 or 12
	#define chrono_started mode_set_f,2 ; chrono is started
	#define menu_display mode,0         ; menu display time
	#define menu_set mode,1		    ; menu set time
	#define menu_chrono mode,2	    ; menu chrono
	#define menu_countdown mode,3	    ; menu countdown
	#define action_display mode,4       ; action display time
	#define action_set mode,5	    ; action set time
	#define action_chrono mode,6	    ; action chrono
	#define action_countdown mode,7	    ; action countdown
	#define cd_sel_hours cd_select,0    ; select hours for countdown
	#define cd_sel_minutes cd_select,1  ; select minutes for countdown
	#define cd_sel_seconds cd_select,2  ; select seconds for countdown
	#define	cd_started  cd_select,3     ; countdown is started
	#define	cd_stoped  cd_select,4      ; countdown is started
	#define	cd_finished  cd_select,5    ; countdown is finished
	#define seconds_equal_0 tmp,0       ; flag if seconds = 0
	#define minutes_equal_0 tmp,1       ; flag if minutes = 0
	#define hours_equal_0 tmp,2         ; flag if hours = 0
	EXTERN	LCDInit, temp_wr, d_write, i_write, LCDLine_1, LCDLine_2
;*******************************************************************************
; VARIABLE SECTION
;*******************************************************************************	
variables	UDATA
ptr_pos		RES 1
ptr_count	RES 1
temp_1		RES 1
temp_2		RES 1
temp_3		RES 1
n_ms		RES 1
n_seconds	RES 1		
n_minutes	RES 1
n_hours		RES 1
d_seconds	RES 1
d_minutes	RES 1
d_hours		RES 1	
hour_dsp	RES 1
LSD		RES 1
MsD		RES 1
MSD		RES 1	
mode		RES 1 ;0000 0001 ; menu select time
		      ;0000 0010 ; menu setup time
		      ;0000 0100 ; menu chronometre
		      ;0000 1000 ; menu compte a rebourt
		      ;0001 0000 ; mode display time
		      ;0010 0000 ; mode setup time
		      ;0100 0000 ; mode chronometre
		      ;1000 0000 ; mode compte a rebourt
mode_set_f      RES 1 ; flag mode
; for chrono
cn_seconds	RES 1		
cn_minutes	RES 1
cn_hours	RES 1
cd_seconds	RES 1
cd_minutes	RES 1
cd_hours	RES 1
; for countdown
cdn_seconds	RES 1		
cdn_minutes	RES 1
cdn_hours	RES 1
cdd_seconds	RES 1
cdd_minutes	RES 1
cdd_hours	RES 1
cd_select	RES 1	
el_seconds	RES 1 ; elpased time
el_minutes	RES 1
el_hours	RES 1
tmp		RES 1
;*******************************************************************************
; STARTUP SECTION
;*******************************************************************************	
STARTUP CODE
    goto	start
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
INT_REQ
    goto isr_tempo
;*******************************************************************************
; PROGRAM SECTION
;*******************************************************************************	    
PROG1 	CODE 
	
stan_table
	  ;XXXXXXXXXXXXXXXX
    data  "S1:Stop  S2:Exit" ; 0
    data  "FINICHED S1:Exit" ; 16
    data  " Display time   " ; 32
    data  "S1:Sel  S2:next " ; 48
    data  "S1:Exit S2: 12H " ; 64
    data  "S1:Exit S2: 24H " ; 80
    data  "Setup  Time     " ; 96
    data  "S1:->/Exit S2:++" ; 112
    data  "Setup at   :    " ; 128
    data  "Chronographe    " ; 144
    data  "Countdown       " ; 160
    data  "S1:Start S2:Exit" ; 176
    data  "S1:Stop  S2:Exit" ; 192
    data  "                " ; 208
    data  "S1:->      S2:++" ; 224
    data  "S1:Start   S2:++" ; 240
start
    call LCDInit	; lcd initiation
    ;***************************************
    ; INITIATION OF PORT
    ;***************************************
    bsf	TRISA,4			;make switch RA4 an Input
    bsf	TRISB,0			;make switch RB0 an Input
    bcf	TRISB,3                 ;make switch RB3 an Input
    bcf TRISD,7
    ;***************************************
    ; INITIATION LED FOR DEBUGING
    ;***************************************
    bcf	    led
    ;***************************************
    ; INITIATION OF VARIABLES
    ;***************************************
    movlw	.100
    movwf	n_ms
    movlw	.60
    movwf	n_seconds
    movlw	.60
    movwf	n_minutes
    movlw	.24
    movwf	n_hours
    clrf	d_seconds
    clrf	d_minutes
    clrf	d_hours
    movlw	b'00000001' ; menu display time for start
    movwf	mode
    bcf		set_minutes ; when we start we set hours
    bcf		chrono_started ; we start with chrono stoped
    bsf		mode_24
    ; for chrono
    movlw	.60
    movwf	cn_seconds
    movwf	cn_minutes
    movlw	.24
    movwf	cn_hours
    clrf	cd_seconds
    clrf	cd_minutes
    clrf	cd_hours
    ; for countdown
    movlw	.60
    movwf	cdn_seconds		
    movwf	cdn_minutes	
    movlw	.24
    movwf	cdn_hours	
    clrf	cdd_seconds	
    clrf	cdd_minutes	
    clrf	cdd_hours
;    bsf         cd_sel_hours ; we start countdown with selected hours
    bsf         cd_sel_minutes ; we start countdown with selected minutes
    bcf		cd_started   ; the countdown is not started or stoped
    bcf		cd_stoped
    ;clrf	mode
    ;bsf		action_chrono ; for debubing go to action chrono
    ;***************************************
    ; INITIATION OF TIMER
    ;***************************************
    bsf T1CON,RD16	    ; TMR1 16 bits

    bcf T1CON,T1CKPS1   ; prescal 1:1
    bcf T1CON,T1CKPS0   ;
	
    bcf T1CON,T1OSCEN   ; Timer 1 oscilator is enable
	
    bcf T1CON,T1SYNC    ; External clock syncro ignored 
			; because internal clock
			    
    bcf T1CON,TMR1CS    ; internal clock
	
    bsf T1CON,TMR1ON    ; enable timer
    ;***************************************
    ; INITIATION OF COOMPARATOR
    ;***************************************
    bcf T3CON,T3CCP2    ; timer 1 linked with CCPR1
    bcf T3CON,T3CCP1
    
    movlw 0x0B
    movwf CCP1CON
    
    movlw 0x27	    ; equal after 10000 periods of 1us
    movwf CCPR1H
    movwf 0x10	    ; like 10ms
    movwf CCPR1L
    
    ; for debuging 50 x more fast
;    movlw 0x01	    ; 
;    movwf CCPR1H
;    movwf 0xF4	    ; 
;    movwf CCPR1L
    
    bsf   PIE1,CCP1IE   ; enable comparator CCPR1
    bcf   PIR1,CCP1IF
    ;***************************************
    ; RUN TIMER
    ;***************************************
    bsf RCON,IPEN
    bsf IPR1,CCP1IP
    bsf INTCON,GIEH
    bsf INTCON,GIEL
;*******************************************************************************
; POLINK SPOT
;*******************************************************************************
; ------------------------------------------------------------------------------
; DISPLAY MENUS
; ------------------------------------------------------------------------------
m_display   ; menu display time
    btfss   scroll ; wait for scroll released
	goto    $-2
    btfss   select ; wait for select released
	goto    $-2	
    
    clrf    mode ; reset mode
    bsf	    menu_display ; menu display
d_wait      ; wait menu display action 
    btfss   select	; if is pushed
	bra	    a_display	; go to action display 
    btfss   scroll      ; if is pushed
	bra	    m_setup	; go to menu setup 
    bra	    d_wait      ; loop to wait action
m_setup     ; menu setup time
    btfss   scroll ; wait for scroll released
	goto    $-2
    btfss   select ; wait for select released
	goto    $-2
    
    clrf    mode   ; reset mode 
    bsf	    menu_set ; set mode menu setup    
s_wait	    ; menu setup action
    btfss   select	; if is pushed
	bra	    a_setup     ; got ot action setup time
    btfss   scroll	; if is pushed
	bra	    m_chrono    ; go to menu chrono
    bra	    s_wait	; loop for wait action
m_chrono
    btfss   scroll ; wait for scroll released
	goto    $-2
    btfss   select ; wait for select released
	goto    $-2
    
    clrf    mode ; reset mode
    bsf	    menu_chrono ; set menu chrono
mc_wait
    btfss   select ; if is pushed
	bra	a_chrono ; go to action chrono
	
    btfss   scroll ; if next button is pushed
	bra	m_countdown ; go to menu countdown	
    bra	    mc_wait
m_countdown
    btfss   scroll ; wait for scroll released
	goto    $-2
    btfss   select ; wait for select released
	goto    $-2
    ; set mode to menu countdown
    clrf    mode ; reset mode
    bsf	    menu_countdown 
cod_wait  ; wait for action
    btfss   scroll ; if newt button is pushed
	    bra  m_display ; go to dispay menu
    btfss   select ; if select is pushed
	    bra  a_countdown ; got to countdown action
    bra cod_wait ; loop for wait a action
;c_wait
; ------------------------------------------------------------------------------
; MANAGE ACTIONS
; ------------------------------------------------------------------------------
a_display   ; action display time
    btfss   scroll ; wait for scroll released
	goto    $-2
    btfss   select ; wait for select released
	goto    $-2
    
    clrf    mode   ; reset mode 
    bsf	    action_display ; set action display time
ad_wait	    ; action display wait action  
   btfss    select	    ; if is pushed
	bra	    a_display_exit  ; go to action exit	 
   btfss    scroll	    ; if is pushed
	bra	   ad_switch
   bra	    ad_wait         ; loop for wait action
ad_switch
   btfss   scroll ; wait for scroll released
	goto    $-2
   movlw  0x02
   xorwf  mode_set_f
   call	  delay_1s
   bra	    ad_wait         ; loop for wait action
a_display_exit
   btfss   scroll ; wait for scroll released
	goto    $-2
   btfss   select ; wait for select released
	goto    $-2
   
   clrf	   mode  ; reset mode
   bsf	   menu_display ;set menu display
   bra	   m_display 
a_setup	   ; action setup time
   btfss   scroll ; wait for scroll released
	goto    $-2
   btfss   select ; wait for select released
	goto    $-2
   
   clrf    mode   ; reset mode 
   bsf	   action_set ; set action setup time
as_wait	   ; wait setup action
   btfss    scroll ; wait for action ++
	bra	    as_increm ; go to 
   btfss    select ; wait for action next or exit
	 bra	    as_next 
   bra	    as_wait ; loop for wait action
as_increm  ; increment hours or minutes ?
   btfss   scroll ; wait for scroll released
	goto    $-2
   btfss   set_minutes
	bra as_increm_hours
   bra as_increm_minutes
as_increm_hours
   decfsz  n_hours ; decrement hours number
	bra	   as_ih   
   clrf	   d_hours
   movlw    .24
   movwf   n_hours 
   bra	   as_wait ; loop for wait action
as_ih
   incf	  d_hours ; increment displaying hours
   bra	  as_wait ; loop for wait action
as_increm_minutes
   decfsz  n_minutes ; decrement minutes number
	bra	   as_im   
   clrf	   d_minutes
   movlw    .60
   movwf   n_minutes 
   ; set seconds to 0
   movlw    .60
   movwf  n_seconds
   clrf	  d_seconds
   bra	  as_wait ; loop for wait action
as_im
   incf	  d_minutes ; increment displaying minutes
   ; set seconds to 0
   movlw    .60
   movwf  n_seconds
   clrf	  d_seconds
   bra	  as_wait ; loop for wait action
as_next
   btfss   select ; wait for select released
	goto    $-2
   btfsc  set_minutes
	bra	  as_exit
   bsf	  set_minutes
   bra	  as_wait ; loop for wait action
as_exit
   bcf	 set_minutes
   ; set seconds to 0
   movlw    .60
   movwf  n_seconds
   clrf	  d_seconds
   bra	 a_display   
a_chrono    ; chrono action
   btfss   scroll ; wait for scroll released
	goto    $-2
   btfss   select ; wait for select released
	goto    $-2
   
   clrf	    mode ; reset mode
   bsf	    action_chrono ; set action of chrono
c_wait     ; wait action of chrono
   btfss   select ; start or stop
	bra	   ca_start 
   btfss   scroll ; exit
	bra	   ca_exit 
   bra	   c_wait ; loop for wait action
ca_start  ; start or stop
   btfss   select ; wait for select released
	goto    $-2
   btfss   chrono_started
	bra	   ca_go_start  
   bra	   ca_go_stop
ca_go_start
   bsf	   chrono_started
   bra	   c_wait 
ca_go_stop
   bcf	   chrono_started  
   bra	   c_wait
ca_exit   ; exit of chrono mode
    movlw	.60
    movwf	cn_seconds
    movwf	cn_minutes
    movlw	.24
    movwf	cn_hours
    clrf	cd_seconds
    clrf	cd_minutes
    clrf	cd_hours	
      
    bcf		chrono_started 
    bra		m_chrono
a_countdown ; action for count down
    btfss   scroll ; wait for scroll released
	goto    $-2
    btfss   select ; wait for select released
	goto    $-2
	
    clrf    mode ; reset mode
    bsf	    action_countdown ; action count down
acd_wait   ; wait action
    btfss   select ; if select is pushed
	bra	acd_set
    btfss   scroll ; if scroll is pushed
	bra	acd_increm
    bra	   acd_wait ; loof for wait action
acd_set
    btfss   select ; if select is pushed
	goto    $-2
	
    btfsc  cd_sel_minutes 
	bra	   acd_set_seconds
    btfsc   cd_started
	bra	    acd_stop
    btfsc   cd_finished
	bra	    acd_finished   
    bra acd_start
acd_set_minutes
    clrf   cd_select ; reset select switch
    bsf	   cd_sel_minutes 
    bra	   acd_wait ; loof for wait action
acd_set_seconds
    clrf   cd_select ; reset select switch
    bsf	   cd_sel_seconds 
    bra	   acd_wait ; loof for wait action
acd_start
    ; look if seconds,minutes,hours = 0
    clrf tmp
    ; look for seconds
    movf cdd_seconds,W 
	sublw 0x00
    btfsc STATUS,C
	bsf seconds_equal_0
    ; look for minutes
    movf cdd_minutes,W 
	sublw 0x00
    btfsc STATUS,C
	bsf minutes_equal_0
    ; look for hours
    movf cdd_hours,W 
	sublw 0x00
    btfsc STATUS,C
	bsf hours_equal_0
    ; if seconds and minutes and hours equal to 0
    ; we can't start the countdown
    movf   tmp,W
	sublw  0x07
    btfsc STATUS, Z
	bra	acd_wait ; seconds, minutes, hours are aqual to 0
   	
    clrf   cd_select ; reset select switch
    bsf	   cd_started ; start countdown
    bcf    cd_finished
    bra	   acd_wait ; loof for wait action 
acd_stop
    clrf   cd_select ; reset select switch
    bsf	   cd_stoped ; stop countdown
    bra	   acd_wait ; loof for wait action
acd_finished
    clrf   cd_select ; reset select switch
    clrf   mode      ; reset mode
    bsf	   menu_display
    bra	   m_display
acd_increm
    btfss   scroll ; wait for scroll released
	goto    $-2
	
    btfsc  cd_sel_hours
	bra	acd_inc_hours
    btfsc  cd_sel_minutes
	bra	acd_inc_minutes
    bra acd_inc_seconds
acd_inc_hours
    decfsz cdn_hours ; > 24
	bra	acd_inc_h_ok 
    movlw  .24
    movwf   cdn_hours
    clrf    cdd_hours
    bra	   acd_wait ; loof for wait action
acd_inc_h_ok
    incf   cdd_hours
    bra	   acd_wait ; loof for wait action
acd_inc_minutes
    decfsz  cdn_minutes ; > 60
	bra	acd_inc_m_ok
    movlw  .60
    movwf   cdn_minutes
    clrf    cdd_minutes
    bra	   acd_wait ; loof for wait action
acd_inc_m_ok
    incf   cdd_minutes
    bra	   acd_wait ; loof for wait action
acd_inc_seconds
    decfsz  cdn_seconds ; > 60
	bra	acd_inc_s_ok
    movlw  .60
    movwf   cdn_seconds
    clrf    cdd_seconds
    bra	   acd_wait ; loof for wait action
acd_inc_s_ok
    incf   cdd_seconds
    bra	   acd_wait ; loof for wait action
;*******************************************************************************
; FUNCTIONS
;*******************************************************************************
;-------------------------------------------------------------------------------    
; LCD FUNCTIONS
;-------------------------------------------------------------------------------
stan_char_1
	call	LCDLine_1		;move cursor to line 1 
	movlw	.16			;1-full line of LCD
	movwf	ptr_count
	movlw	UPPER stan_table
	movwf	TBLPTRU
	movlw	HIGH stan_table
	movwf	TBLPTRH
	movlw	LOW stan_table
	movwf	TBLPTRL
	movf	ptr_pos,W
	addwf	TBLPTRL,F
	clrf	WREG
	addwfc	TBLPTRH,F
	addwfc	TBLPTRU,F	
stan_next_char_1
	tblrd	*+
	movff	TABLAT,temp_wr			
	call	d_write			;send character to LCD

	decfsz	ptr_count,F		;move pointer to next char
	bra	stan_next_char_1

	return
;----Standard code, Place characters on line-2--------------------------
stan_char_2	
	call	LCDLine_2		;move cursor to line 2 
	movlw	.16			;1-full line of LCD
	movwf	ptr_count
	movlw	UPPER stan_table
	movwf	TBLPTRU
	movlw	HIGH stan_table
	movwf	TBLPTRH
	movlw	LOW stan_table
	movwf	TBLPTRL
	movf	ptr_pos,W
	addwf	TBLPTRL,F
	clrf	WREG
	addwfc	TBLPTRH,F
	addwfc	TBLPTRU,F

stan_next_char_2
	tblrd	*+
	movff	TABLAT,temp_wr
	call	d_write			;send character to LCD

	decfsz	ptr_count,F		;move pointer to next char
	bra	stan_next_char_2

	return	    
;------------------------------------------------------------------------------- 
; Binary (8-bit) to BCD 
;		255 = highest possible result
;-------------------------------------------------------------------------------
bin_bcd
	clrf	MSD
	clrf	MsD
	movwf	LSD		;move value to LSD
ghundreth	
	movlw	.100		;subtract 100 from LSD
	subwf	LSD,W
	btfss	STATUS,C	;is value greater then 100
	bra	gtenth		;NO goto tenths
	movwf	LSD		;YES, move subtraction result into LSD
	incf	MSD,F		;increment hundreths
	bra	ghundreth	
gtenth
	movlw	.10		;take care of tenths
	subwf	LSD,W
	btfss	STATUS,C
	bra	over		;finished conversion
	movwf	LSD
	incf	MsD,F		;increment tenths position
	bra	gtenth
over				;0 - 9, high nibble = 3 for LCD
	movf	MSD,W		;get BCD values ready for LCD display
	xorlw	0x30		;convert to LCD digit
	movwf	MSD
	movf	MsD,W
	xorlw	0x30		;convert to LCD digit
	movwf	MsD
	movf	LSD,W
	xorlw	0x30		;convert to LCD digit
	movwf	LSD
	retlw	0
;------------------------------------------------------------------------------- 
; DELAY FUNCTION
;-------------------------------------------------------------------------------	
;------------------ 100ms Delay --------------------------------
delay_100ms
	movlw	0xFF
	movwf	temp_1
	movlw	0x83
	movwf	temp_2

d100l1
	decfsz	temp_1,F
	bra	d100l1
	decfsz	temp_2,F
	bra	d100l1
	return

;---------------- 1s Delay -----------------------------------
delay_1s
	movlw	0xFF
	movwf	temp_1
	movwf	temp_2
	movlw	0x05
	movwf	temp_3
d1l1
	decfsz	temp_1,F
	bra	d1l1
	decfsz	temp_2,F
	bra	d1l1
	decfsz	temp_3,F
	bra	d1l1
	return	
	
;------------------------------------------------------------------------------- 
; User FUNCTIONS 
;-------------------------------------------------------------------------------
; increment clock time
f_inc_seconds
    decfsz	n_seconds ; seconds == 59
	    goto	inc_s
    clrf	d_seconds
    movlw	.60
    movwf	n_seconds
    decfsz	n_minutes ; test if minutes == 59
	    goto	inc_m     ; increment minutes
    movlw	.60
    movwf	n_minutes
    clrf	d_minutes
    decfsz	n_hours  ; test if hours == 23
	    goto	inc_h    ; increment hours
    movlw	.24
    movwf	n_hours
    clrf	d_hours
    goto	go_back
inc_s		
    incf	d_seconds
    goto	go_back
inc_m
    incf	d_minutes ; minutes ++
    goto	go_back
inc_h
    incf	d_hours
    goto        go_back
go_back
    call	display
    return
; increment chrono time
f_inc_chrono
    btfss	chrono_started ; chrono not started
	    return  
    decfsz	cn_seconds ; seconds == 59
	     goto	inc_cs
    clrf	cd_seconds
    movlw	.60
    movwf	cn_seconds
    decfsz	cn_minutes ; test if minutes == 59
	    goto	inc_cm     ; increment minutes
    movlw	.60
    movwf	cn_minutes
    clrf	cd_minutes
    decfsz	cn_hours  ; test if hours == 23
	    goto	inc_ch    ; increment hours
    movlw	.24
    movwf	cn_hours
    clrf	cd_hours
    goto	go_cback
inc_cs		
    incf	cd_seconds
    goto	go_cback
inc_cm
    incf	cd_minutes ; minutes ++
    goto	go_cback
inc_ch
    incf	cd_hours
    goto        go_cback
go_cback
    call	display
    return
; increment countdown
f_inc_count
    btfss	cd_started ; countdown not started
	return 
    ; look if seconds,minutes,hours = 0
    clrf tmp
    ; look for seconds
    movf cdd_seconds,W 
	sublw 0x00
    btfsc STATUS,C
	bsf seconds_equal_0
    ; look for minutes
    movf cdd_minutes,W 
	sublw 0x00
    btfsc STATUS,C
	bsf minutes_equal_0
    ; look for hours
    movf cdd_hours,W 
	sublw 0x00
    btfsc STATUS,C
	bsf hours_equal_0
    ; if hours = 0 AND minutes > 0 AND seconds = 0
    movf   tmp,W
	sublw  0x05
    btfsc STATUS, Z
	bra	icd_h_0_m_0_s_1    
    bra icd_resume
icd_h_0_m_0_s_1	
    decf cdd_minutes
    movlw .60
    movwf  cdn_seconds
    movwf  cdd_seconds
    movwf  cdn_minutes
icd_resume	
    decfsz	cdn_seconds ; seconds == 59
	     goto	inc_cds
    clrf	cdd_seconds
    btfsc	minutes_equal_0
	bra     go_cdback
    movlw	.60
    movwf	cdn_seconds
    movwf	cdd_seconds
    decf	cdd_minutes
inc_cds		
    decf	cdd_seconds
    goto	go_cdback
go_cdback
    ; look if seconds,minutes,hours = 0
    clrf tmp
    ; look for seconds
    movf cdd_seconds,W 
	sublw 0x00
    btfsc STATUS,C
	bsf seconds_equal_0
    ; look for minutes
    movf cdd_minutes,W 
	sublw 0x00
    btfsc STATUS,C
	bsf minutes_equal_0
    ; look for hours
    movf cdd_hours,W 
	sublw 0x00
    btfsc STATUS,C
	bsf hours_equal_0
    ; if seconds and minutes and hours equal to 0
    ; we can't start the countdown
    movf   tmp,W
	sublw  0x07
    btfsc STATUS, Z
	bra  cd_finish; seconds, minutes, hours are aqual to 0
    bra cd_resume
cd_finish
	bcf  cd_started
	bsf  cd_finished
cd_resume
    call	display
    return
; diplay to lcd function
display		    ; rounting
    btfsc   menu_display ; menu display
	goto    dsp_m_select_time
    btfsc   menu_set ; menu setup time
	goto	dsp_m_set_time
    btfsc   menu_chrono ; menu chrono
	goto    dsp_m_chrono
    btfsc   menu_countdown ; menu countdown
	goto    dsp_m_cdo
    btfsc   action_display ; mode display
	goto    dsp_hour
    btfsc   action_set ; mode setup time
	goto	dsp_setup
    btfsc action_chrono
	goto dsp_action_chrono
    btfsc action_countdown
	goto dsp_a_cdo ; display action countdown
    return
dsp_m_select_time    ; menu display time    
    movlw   .32
    movwf   ptr_pos			;send "Affichage " to LCD line 1
    call    stan_char_1
    movlw   .48
    movwf   ptr_pos			;send "S1:Sel  S2:next " to LCD line 2
    call    stan_char_2
    return
dsp_m_set_time   ; menu set time
    movlw   .96
    movwf   ptr_pos			;send "Regler horloge" to LCD line 1
    call    stan_char_1
    movlw   .48
    movwf   ptr_pos			;send "S1:Sel  S2:next " to LCD line 2
    call    stan_char_2
    return
dsp_m_chrono
    movlw   .144
    movwf   ptr_pos			;send "chronographe" to LCD line 1
    call    stan_char_1
    movlw   .48
    movwf   ptr_pos			;send "S1:Sel  S2:next " to LCD line 2
    call    stan_char_2
    return
dsp_action_chrono    ; menu action chrono
    call	LCDLine_1		; clear line 1
    ; display chrono time
    movlw	A'C'
    movwf	temp_wr
    call	d_write
    movlw	A'h'
    movwf	temp_wr
    call	d_write
    movlw	A'r'
    movwf	temp_wr
    call	d_write
    movlw	A'o'
    movwf	temp_wr
    call	d_write
    movlw	A'n'
    movwf	temp_wr
    call	d_write
    movlw	0x20
    movwf	temp_wr
    call	d_write
    movlw	A':'
    movwf	temp_wr
    call	d_write
    movlw	0x20
    movwf	temp_wr
    call	d_write
    ; display hours
    movf	cd_hours,W
    call	bin_bcd			;get hours ready for LCD
	
    movf	MsD,W			;send middle digit
    movwf	temp_wr
    call	d_write
    movf	LSD,W			;send low digit
    movwf	temp_wr
    call	d_write
    ; display separator
    movlw	A':'
    movwf	temp_wr
    call	d_write
    ; display minutes
    movf	cd_minutes,W
    call	bin_bcd			;get minutes ready for LCD

    movf	MsD,W			;send middle digit
    movwf	temp_wr
    call	d_write
    movf	LSD,W			;send low digit
    movwf	temp_wr
    call	d_write
    ; display separator
    movlw	A':'
    movwf	temp_wr
    call	d_write
    ; display seconds
    movf	cd_seconds,W
    call	bin_bcd			;get seconds ready for LCD

    movf	MsD,W			;send middle digit
    movwf	temp_wr
    call	d_write
    movf	LSD,W			;send low digit
    movwf	temp_wr
    call	d_write

    btfsc   chrono_started
	    bra	cd_start
    bra	cd_stop
cd_start    
    movlw   .192                        ; display stop
    bra	    cd_dsp_line
cd_stop    
    movlw   .176                        ; display start 
cd_dsp_line    
    movwf   ptr_pos			;
    call    stan_char_2    
    
    return 

dsp_m_cdo      ; menu countdown
    movlw   .160
    movwf   ptr_pos			;send "count down" to LCD line 1
    call    stan_char_1
    movlw   .48
    movwf   ptr_pos			;send "S1:Sel  S2:next " to LCD line 2
    call    stan_char_2
    return 
dsp_hour      ; display time
	movlw   .208	    ; clear line 1
	movwf   ptr_pos			
	call    stan_char_1
	call	LCDLine_1		
	; display time
	movlw	A'T'
	movwf	temp_wr
	call	d_write
	movlw	A'i'
	movwf	temp_wr
	call	d_write
	movlw	A'm'
	movwf	temp_wr
	call	d_write
	movlw	A'e'
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write
	movlw	A':'
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write
	; display hours
	btfsc mode_24
	    bra set_h_24
	; test hour > 12    
	movf  d_hours,W
	sublw 0x0C
	btfsc STATUS,C
	    bra set_h_24
	bra h_up_12
h_up_12
	bsf  led
	movf    d_hours,W
	movwf   hour_dsp
	movlw 0x0C
	subwf hour_dsp,F
	bra  dsp_hour_main   
set_h_24
	movf    d_hours,W
	movwf   hour_dsp
dsp_hour_main
	movf	hour_dsp,W
	call	bin_bcd			;get hours ready for LCD
	
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	; display separator
	movlw	A':'
	movwf	temp_wr
	call	d_write
	; display minutes
	movf	d_minutes,W
	call	bin_bcd			;get minutes ready for LCD
	
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	; display separator
	movlw	A':'
	movwf	temp_wr
	call	d_write
	; display seconds
	movf	d_seconds,W
	call	bin_bcd			;get seconds ready for LCD
	
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	
	; dipslay menu
	btfss	mode_24
	    bra dsp_24h
	movlw   .64
	movwf   ptr_pos			;send "S1:Exit  S2: 24H " to LCD line 2
	call    stan_char_2
	bra dsp_hour_ret
dsp_24h		
	movlw   .80
	movwf   ptr_pos			;send "S1:Exit  S2: 12H " to LCD line 2
	call    stan_char_2
dsp_hour_ret
	return
dsp_setup 	; display submenu setup time for action
	movlw   .128
	movwf   ptr_pos			;send "Regler a" to LCD line 1
	call    stan_char_1
	movlw   .112
	movwf   ptr_pos			;send "S1:->/Exit S2:++" to LCD line 2
	call    stan_char_2
	
	; hours
	movf	d_hours,W
	call	bin_bcd			;get hours ready for LCD
	movlw	0x89                    ; set position
	movwf	temp_wr
	call	i_write
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movlw	0x8A			; set position
	movwf	temp_wr
	call	i_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	; minutes
	movf	d_minutes,W
	call	bin_bcd			;get minutes ready for LCD
	movlw	0x8C			; set position
	movwf	temp_wr			
	call	i_write
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movlw	0x8D
	movwf	temp_wr
	call	i_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	btfsc	set_minutes ; for display carre if set minute of hours
	    bra setup_minutes ; we set minutes
setup_hours	
	movlw	0x8A
	movwf	temp_wr
	call	i_write
	return
setup_minutes
	movlw	0x8D
	movwf	temp_wr
	call	i_write
	return
dsp_a_cdo ; display action count down
	movlw   .208	    ; clear line 1
	movwf   ptr_pos			
	call    stan_char_1
	call	LCDLine_1		
	; display time
	movlw	A'C'
	movwf	temp_wr
	call	d_write
	movlw	A'o'
	movwf	temp_wr
	call	d_write
	movlw	A'u'
	movwf	temp_wr
	call	d_write
	movlw	A'n'
	movwf	temp_wr
	call	d_write
	movlw	A't'
	movwf	temp_wr
	call	d_write
	movlw	0x10
	movwf	temp_wr
	call	d_write
	movlw	A':'
	movwf	temp_wr
	call	d_write
	movlw	0x20
	movwf	temp_wr
	call	d_write

	movlw	A' '
	movwf	temp_wr
	call	d_write
	call	d_write
	call	d_write
	; display minutes
	movf	cdd_minutes,W
	call	bin_bcd			;get minutes ready for LCD
	
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	; display separator
	movlw	A':'
	movwf	temp_wr
	call	d_write
	; display seconds
	movf	cdd_seconds,W
	call	bin_bcd			;get seconds ready for LCD
	
	movf	MsD,W			;send middle digit
	movwf	temp_wr
	call	d_write
	movf	LSD,W			;send low digit
	movwf	temp_wr
	call	d_write
	
	movlw   .224
	movwf   ptr_pos			;send "S1:->  S2:++ " to LCD line 2
	call    stan_char_2
	btfsc	cd_sel_hours
		bra	cd_setup_hours
	btfsc	cd_sel_minutes
		bra	cd_setup_minutes
	btfsc	cd_sel_seconds
		bra	cd_setup_seconds
	btfsc	cd_started
		bra	cd_dsp_stop
	btfsc   cd_finished
		bra	cd_dsp_finished
	return
cd_setup_hours
	movlw	0x89
	movwf	temp_wr
	call	i_write
	return
cd_setup_minutes
	movlw	0x8C
	movwf	temp_wr
	call	i_write
	return
cd_setup_seconds
	movlw   .240
	movwf   ptr_pos			;send "S1:Start  S2:++ " to LCD line 2
	call    stan_char_2
	
	movlw	0x8F
	movwf	temp_wr
	call	i_write
	return
cd_dsp_stop
	movlw   .0
	movwf   ptr_pos			;send "S1:Stop  S2:Exit " to LCD line 2
	call    stan_char_2
	return
cd_dsp_finished
	movlw   .16
	movwf   ptr_pos			;FINISHED  S1:Exit " to LCD line 2
	call    stan_char_2
	return
;*******************************************************************************
; INTERUPT SPOT
;*******************************************************************************	    
isr_tempo
    clrf    TMR1H
    clrf    TMR1L
    ; ------------ increment second after 100 * 10 ms or 1s -------------
    decfsz  n_ms            	
    goto    reset_temp
    goto    incr_sec
    ; -------------------------------------------------------------------
incr_sec
    ; ----------- increment seconds -------------------------------------
    call    f_inc_chrono
    call    f_inc_seconds
    call    f_inc_count
    ;--------------------------------------------------------------------
    movlw   .100
    movwf   n_ms
reset_temp
    bcf PIR1,CCP1IF    
    retfie		
end