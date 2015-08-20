;Lights off sequencer
;For questions on code, email j.tran4418@gmail.com with code and questions
;To test sequencer, press (while sequencer is running):
;               C for corridor C
;               E for corridoe E
;               T for stance in corridor C
;               W for swing in corridor C
;Codes:         1 - BEGST
;               2 - MIDST
;               3 - BEGSW
;               4 - MIDSW
;               0A (10) - END OF ROUND

; CHANGE THESE VARIABLES HERE
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
                VAR    V4,DkD=s(0.2)   ;dark duration time in seconds
                VAR    V1,level=VDAC16(0.88) ;set voltage threshhold for what is stance and swing
                VAR    V3,EStD=s(0.15) ;early stance duration time in sec for early mid stance
                VAR    V5,StD=s(0.28)   ;stance delay duration time in sec for mid stance
                VAR    V6,SwD=s(0.15)  ;swing delay duration time in sec for mid swing
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

                SET    0.100,1,0       ;1ms per step in sequencer, DAC scale 1V
0000            DAC    0,5             ;turn light on
                VAR    V2,data         ;allocate memory for channel data storing

0001 START:     BRAND  CorrC,0.85      ;80% chance to jump CorrC

0003 CORRE: 'E  CHAN   data,6          ;retrieve data from channel 6,
0004            BLT    data,VDAC16(2.0),CorrE ;if gates channel less than 2.0V, repeat (jump to CORRE)
0005            DELAY  s(0.5)          ;delay half second before proceeding
0006            BGT    data,VDAC16(5.0),ENDROUND ;if gates channel more than 4.0V, end round
0007            BRAND  WSTE,0.5
0008            JUMP   WSWE            ;jump to stance-e or swing-e based on result of line 0001

0009 CORRC: 'C  CHAN   data,6          ;retrieve data from channel 6, gates channel
0010            BLT    data,VDAC16(-1.2),CorrC ;if gates channel is less than -0.5V, repeat (jump to CORRC)
0011            DELAY  s(0.5)          ;delay half second before proceeding
0012            BRAND  WSTC,0.6        ;probability offset for 3 stance tasks (1/2 * 1/5 + 1/2 = 3/5 percent for stance)
0013            JUMP   WSWC            ;jump to stance-c or swing-c based on result of line 0001

0014 STANCEC: 'T CHAN  data,5          ;retrieve data from channel 5, step channel
0015            BGT    data,level,STANCEC ;if data is greater than level var, repeat (greater means still in swing)
0016            CHAN   data,6          ;grab data from channel 6, gates channel
0017            BGT    data,VDAC16(0.7),ENDROUND ;if the data is greater than 0.7V, end round
0018            BRAND  BEGST,0.175     ;11.7% chance to jump to beginning of stance
0019            BRAND  MIDST,0.212    ;11.7% chance to jump to middle of stance
;BRAND  MIDEST,0.151    ;11.7% chance to jump to early middle of stance
0021 WSTC:      CHAN   data,5          ;65% chance for no light on this step, retrieve data from channel 5
0022            BLT    data,level,WSTC ;if data is less than level (still stance), jump back one line
0023            JUMP   STANCEC         ;jump to STANCEC when data indicates foot is lifted again

0024 SWINGC: 'W CHAN   data,5          ;retrieve data from channel 5, step channel
0025            BLT    data,level,SWINGC ;if data is greater than level var, repeat (less means still in stance)
0026            CHAN   data,6          ;grab data from channel 6, gates channel
0027            BGT    data,VDAC16(0.7),ENDROUND ;if the data is greater than 2.0V, end round
0028            BRAND  BEGSW,0.175     ;17.5% chance to jump to beginning of swing
0029            BRAND  MIDSW,0.212     ;17.5% chance to jump to middle of swing
0030 WSWC:      CHAN   data,5          ;65% chance for no light on this step, retrieve data from channel 5
0031            BGT    data,level,WSWC ;if data is less than level (still swing), jump back one line
0032            JUMP   SWINGC          ;jump to SWINGC when data indicates foot is touches floor

0033 STANCEE:   CHAN   data,5          ;retrieve data from channel 5, step channel
0034            BGT    data,level,STANCEE ;if data is greater than level var, repeat (greater means still in swing)
0035            CHAN   data,6          ;grab data from channel 6, gates channel
0036            BGT    data,VDAC16(3.36),ENDROUND
0037            BRAND  BEGST,0.175     ;11.7% chance to jump to beginning of stance
0038            BRAND  MIDST,0.212    ;11.7% chance to jump to beginning of stance
;BRAND  MIDEST,0.151    ;11.7% chance to jump to early middle of stance
0040 WSTE:      CHAN   data,5          ;65% chance for no light on this step, retrieve data from channel 5
0041            BLT    data,level,WSTE ;if data is less than level (still stance), jump back one line
0042            JUMP   STANCEE         ;jump to STANCEC when data indicates foot is lifted again

0043 SWINGE:    CHAN   data,5          ;retrieve data from channel 5, step channel
0044            BLT    data,level,SWINGE ;if data is greater than level var, repeat (less means still in stance)
0045            CHAN   data,6          ;grab data from channel 6, gates channel
0046            BGT    data,VDAC16(3.36),ENDROUND
0047            BRAND  BEGSW,0.175     ;17.5% chance to jump to beginning of swing
0048            BRAND  MIDSW,0.212     ;17.5% chance to jump to middle of swing
0049 WSWE:      CHAN   data,5          ;65% chance for no light on this step, retrieve data from channel 5
0050            BGT    data,level,WSWE ;if data is less than level (still swing), jump back one line
0051            JUMP   SWINGE          ;jump to SWINGC when data indicates foot is touches floor

0052 BEGST:     DAC    0,0             ;turn light off
0053            DELAY  DkD             ;delay for dark duration
0054            DAC    0,5             ;turn light on
0055            MARK   1               ;mark 1 for beginning of stance
0056            JUMP   ENDROUND

0057 MIDEST:    DELAY  EStD            ;delay for designated time after beginning of stance
0058            DAC    0,0             ;turn light off
0059            DELAY  DkD             ;delay for dark duration
0060            DAC    0,5             ;turn light back on
0061            MARK   2               ;mark 3 for middle early of stance
0062            JUMP   ENDROUND

0063 MIDST:     DELAY  StD             ;delay for designated time after stance
0064            DAC    0,0             ;turn light off
0065            DELAY  DkD             ;delay for dark duration
0066            DAC    0,5             ;turn light back on
0067            MARK   2               ;mark 2 for middle of stance
0068            JUMP   ENDROUND

0069 BEGSW:     DAC    0,0             ;turn light off
0070            DELAY  DkD             ;delay for dark duration
0071            DAC    0,5             ;turn light on
0072            MARK   4               ;mark 4 for beginning of swing
0073            JUMP   ENDROUND

0074 MIDSW:     DELAY  SwD             ;delay 0.140s
0075            DAC    0,0             ;turn light off
0076            DELAY  DkD             ;delay for dark duration
0077            DAC    0,5             ;turn light back on
0078            MARK   5               ;mark 5 for middle of swing
0079            JUMP   ENDROUND

0080 ENDROUND:  CHAN   data,6          ;retrieve data from channel 6, gates channel
0081            BGT    data,VDAC16(-1.26),ENDROUND ;if data is larger than -0.5V, jump up one line
0082            MARK   10              ;mark 10 for end of round
0083            JUMP   START           ;jump to beginning of sequence
