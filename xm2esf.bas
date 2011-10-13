#COMPILE EXE
#DIM NONE


TYPE PATTERNDATA
    note AS STRING * 1
    INST AS STRING * 1
    VC AS STRING * 1
    ET AS STRING * 1
    EP AS STRING * 1
END TYPE

FUNCTION PBMAIN () AS LONG
    TRACE NEW "log.txt"


    '************************************
    '* XM2ESF/oerg                      *
    '************************************
    '
    ' Converts XM-format module music to
    ' Echo Stream Format
    '
    ' VERSION:
    version$ = "0.97"

    '
    ' (C) 2009, 2010, 2011 Oerg866
    '
    ' XM Splitter (C) 2007 Nineko

    ' Developed according to official Echo docs. (C) 2011 Sik

        '
    DIM pi AS DOUBLE

    pi= 3.14159265358979323846264338   ' The Pi is a lie :(

    PRINT "XM2ESF - Convert XM to Echo Stream Format"
    PRINT "*** ALPHA VERSION "+version$
    PRINT ""
    PRINT "Copyright (C) 2011 Oerg866"
    PRINT ""
    PRINT "Echo (C) 2011 Sik      http://echo.mdscene.net (Website N/A yet)"
    PRINT ""
    PRINT "PLEASE REPORT BUGS TO GITHUB OR oerg866@tototek.com!!"
    PRINT ""
    PRINT "This program is freeware. It must not be sold. This is a temporary"
    PRINT "disclaimer until we actually bother setting up license stuffs =P"
    PRINT ""
    PRINT "Please take a few seconds to acknowledge that this"
    PRINT "Software is currently in alpha state, and may or may not"
    PRINT "Function correctly. You hereby agree that its creator can not"
    PRINT "be held liable in case anything goes wrong."
    PRINT ""
    PRINT "Also, lots of hours of bugfixing and testing went into this."
    PRINT "Please show a little compassion or something when using this"
    PRINT "program :)"
    PRINT ""
    PRINT "Please wait two seconds or press q to quit"

    counter& = 20
    FOR il& = 1 TO counter&
    a$ = INKEY$
    IF LCASE$(a$) = "q" THEN

        PRINT ""
        PRINT "Sorry to hear that. Good bye !"

            EXIT FUNCTION
    END IF
            SLEEP 100
    NEXT il&




    IF COMMAND$ = "" THEN
        PRINT "usage: xm2esf <infile> <outfile>"
        PRINT ""
        PRINT "<infile>  is the pointer to an XIF file. An XIF file is a descriptor"
        PRINT "          file that contains all the parameters which xm2esf will"
        PRINT "          respect while creating the resulting ESF file, and also the"
        PRINT "          path and filename to the input XM file."
        PRINT ""
        PRINT "          Creating an XIF file is possible using 'xm2esfgui' by"
        PRINT "          Oerg866. It is very easy to use and creates a XIF file"
        PRINT "          that is perfectly parseable by xm2esf :)"
        PRINT ""
        PRINT "          For other software and information, please visit"
        PRINT "          http://echo.mdscene.net/software"
        PRINT ""
        PRINT "---<PRESS ANY KEY TO CONTINUE TO NEXT PAGE>"
        WAITKEY$
        PRINT "<outfile> is the output path ad filename xm2esf will use to create"
        PRINT "          the resulting ESF file. Please note that if this file exists"
        PRINT "          it WILL BE OVERWRITTEN, even if you encounter a bug and the"
        PRINT "          conversion somehow fails (well.. it shouldn't :P but just"
        PRINT "          keep in mind to back up often while xm2esf is in alpha stage"
        PRINT ""
        PRINT "---<PRESS ANY KEY TO QUIT>"
        WAITKEY$
        PRINT ""
        PRINT "Bye :D!"



        EXIT FUNCTION
        END IF


    OPEN COMMAND$(1) FOR INPUT AS #1

    DIM xmfm&(1 TO 6)
    DIM xmpsg&(1 TO 3)
    DIM fm&
    DIM psg&

    tempo& = 7      ' Default tempo :P

    WHILE setting$ <> "[Instruments]"
        LINE INPUT #1, setting$
        IF MID$(setting$, 1, 1) <> "#" THEN
           SELECT CASE spleft(setting$)

              CASE "FILE"
                xm$ = param(setting$, 1)
                PRINT "XM File: " + xm$
              CASE "TYPE"
                SELECT CASE param(setting$, 1)
                CASE "BGM"
                filetype& = 1
                CASE "SFX"
                filetype& = 2
                END SELECT
                SELECT CASE param(setting$, 2)
                CASE "LOOP"

                esfloop& = 1
                IF filetype& = 2 THEN
                    PRINT "Input file errorneously declares loop while being a SFX. File rejected."
                    PRINT "Press any key!"
                    WAITKEY$
                    CLOSE
                    EXIT FUNCTION
                END IF
                CASE "NOLOOP"
                esfloop& = 0


                END SELECT

              CASE "TEMPO"
                  tempo& = VAL(param(setting$, 1))
              CASE "FM"
                  fm& = VAL(param(setting$, 1))
                  IF fm > 6 THEN
                      PRINT "Declared more than 6 FM channels. Press any key!"

                  WAITKEY$:CLOSE:EXIT FUNCTION
                  END IF
              CASE "PSG"
                  psg& = VAL(param(setting$, 1))
                  IF psg& > 3 THEN
                      PRINT "Declared more than 3 PSG channels. Press any key!"
                      PRINT "Press any key!"
                      WAITKEY$
                      CLOSE
                      EXIT FUNCTION
                  END IF
              CASE "PCM"
                  pcm& = 1
                  IF fm& = 6 THEN
                      PRINT "Input file errorneously declares PCM even though 6 FM channels are used"
                      PRINT "Press any key!"
                      WAITKEY$
                      CLOSE
                      EXIT FUNCTION

                  END IF
              CASE "NOISE"
                  noise& = VAL(param(setting$, 1))
              CASE "FM1"
                  xmfm&(1) = VAL(param(setting$, 1))
              CASE "FM2"
                  xmfm&(2) = VAL(param(setting$, 1))
              CASE "FM3"
                  xmfm&(3) = VAL(param(setting$, 1))
              CASE "FM4"
                  xmfm&(4) = VAL(param(setting$, 1))
              CASE "FM5"
                  xmfm&(5) = VAL(param(setting$, 1))
              CASE "FM6"
                  xmfm&(6) = VAL(param(setting$, 1))
              CASE "PCMC"
                  xmpcm& = VAL(param(setting$,1))
              CASE "PSG1"
                  xmpsg&(1) = VAL(param(setting$, 1))
              CASE "PSG2"
                  xmpsg&(2) = VAL(param(setting$, 1))
              CASE "PSG3"
                  xmpsg&(3) = VAL(param(setting$, 1))
              CASE "PSGN"
                  xmnoise& = VAL(param(setting$, 1))
              CASE "NOISEFREQ" ' 1 = stock, 0 = psg3
                  noisetype& = VAL(param(setting$, 1))
              CASE "NOISETYPE"
                  noisemode& = VAL(param(setting$, 1))
                  '1 = white noise, 0 = periodic noise

           END SELECT
        END IF

    WEND

    PRINT "loading XM file: " + xm$
    s$ = "loadxm " +  CHR$(34) + xm$ + CHR$(34)
    SHELL s$
    PRINT "XM pattern data extracted"

    'INSTRUMENT ASSIGNMENTS
    DIM esfins&(1 TO 256)

    WHILE setting$ <> "[Pitch]"

        IF MID$(setting$,1,1) <> "#" THEN

        LINE INPUT #1, setting$
        esfins&(VAL(spleft(setting$))) = VAL("&H" + param(setting$,1))

        ELSE
            LINE INPUT #1, setting$

        END IF

    WEND

    PRINT "Loaded pitches"
    'PITCH

    ' 123456 = FM
    ' 789    = PSG

    ' 11     = PCM
    ' 10     = NSE



    DIM pitch&(1 TO 11)

    WHILE setting$ <> "[Volume]"
        LINE INPUT #1, setting$
        IF MID$(setting$,1,1) <> "#" THEN

            SELECT CASE spleft(setting$)
                CASE "FM1"
                    pitch&(1) = VAL(param(setting$,1))
                CASE "FM2"
                    pitch&(2) = VAL(param(setting$,1))
                CASE "FM3"
                    pitch&(3) = VAL(param(setting$,1))
                CASE "FM4"
                    pitch&(4) = VAL(param(setting$,1))
                CASE "FM5"
                    pitch&(5) = VAL(param(setting$,1))
                CASE "FM6"
                    pitch&(6) = VAL(param(setting$,1))

                CASE "PSG1"
                    pitch&(7) = VAL(param(setting$,1))
                CASE "PSG2"
                    pitch&(8) = VAL(param(setting$,1))
                CASE "PSG3"
                    pitch&(9) = VAL(param(setting$,1))
                END SELECT
        END IF


    WEND

    DIM vol&(1 TO 11)

    WHILE setting$ <> "[END]"
        LINE INPUT #1, setting$
        IF MID$(setting$,1,1) <> "#" THEN

            SELECT CASE spleft(setting$)
                CASE "FM1"
                    vol&(1) = VAL(param(setting$,1))
                CASE "FM2"
                    vol&(2) = VAL(param(setting$,1))
                CASE "FM3"
                    vol&(3) = VAL(param(setting$,1))
                CASE "FM4"
                    vol&(4) = VAL(param(setting$,1))
                CASE "FM5"
                    vol&(5) = VAL(param(setting$,1))
                CASE "FM6"
                    vol&(6) = VAL(param(setting$,1))

                CASE "PSG1"
                    vol&(7) = VAL(param(setting$,1))
                CASE "PSG2"
                    vol&(8) = VAL(param(setting$,1))
                CASE "PSG3"
                    vol&(9) = VAL(param(setting$,1))
                CASE "PSG3"
                    vol&(9) = VAL(param(setting$,1))
                CASE "PSGN"
                    vol&(11) = VAL(param(setting$,1))
                END SELECT
        END IF


    WEND
    '
    CLOSE

    OPEN COMMAND$(2) FOR BINARY AS #20


    DIM i AS INTEGER
    DIM present&(1 TO 11)
    FOR i = 1 TO fm&

    present&(i) = 1
    OPEN "temp\C" + TRIM$(STR$(xmfm&(i))) + ".tmp" FOR BINARY AS #i

    NEXT i

    FOR i = 7 TO psg& + 6
    present&(i) = 1

    OPEN "temp\C" + TRIM$(STR$(xmpsg&(i-6))) + ".tmp" FOR BINARY AS #i

    NEXT i

    IF pcm& = 1 THEN

    present&(10) = 1
    OPEN "temp\C" + TRIM$(STR$(xmpcm&)) + ".tmp" FOR BINARY AS #10

    END IF

    IF noise& = 1 THEN

    present&(11) = 1
    OPEN "temp\C" + TRIM$(STR$(xmnoise&)) + ".tmp" FOR BINARY AS #11

    END IF
    PRINT "Channels assigned and loaded"

    '       $00nn ..... Note on FM channel #1              bollocks :(
    '       $01nn ..... Note on FM channel #2
    '       $02nn ..... Note on FM channel #3
    '       $04nn ..... Note on FM channel #4
    '       $05nn ..... Note on FM channel #5
    '       $06nn ..... Note on FM channel #6
    '       $08nn ..... Note on PSG channel #1
    '       $09nn ..... Note on PSG channel #2
    '       $0Ann ..... Note on PSG channel #3
    '       $0Bnn ..... Note on PSG channel #4
    '       $0Cnn ..... Note on PCM channel
    '
    '

    DIM esfchan&(1 TO 11)

    esfchan&(1)  = 0
    esfchan&(2)  = 1
    esfchan&(3)  = 2
    esfchan&(4)  = 4
    esfchan&(5)  = 5
    esfchan&(6)  = 6
    esfchan&(7)  = 8
    esfchan&(8)  = 9
    esfchan&(9)  = 10
    esfchan&(10) = 12
    esfchan&(11) = 11

    DIM fmnote&(1 TO 11)

    fmnote&(0) = 644
    fmnote&(1) = 681
    fmnote&(2) = 722
    fmnote&(3) = 765
    fmnote&(4) = 810
    fmnote&(5) = 858
    fmnote&(6) = 910
    fmnote&(7) = 964
    fmnote&(8) = 1024
    fmnote&(9) = 1081
    fmnote&(10) = 1146
    fmnote&(11) = 1214

    DIM psgnote&(0 TO 384)
    OPEN "psg.txt" FOR INPUT AS #1337

    t&=0
    WHILE NOT EOF(1337)

    LINE INPUT #1337, c$
    psgnote&(t&) = VAL(c$)

    t&=t&+1
    WEND
    CLOSE #1337
    PRINT "PSG Freq init."

    '            freq& = INT(fmnote&(subtone&) * (2^octave&))

    DIM ctype(1 TO 11)  AS INTEGER
    ctype(7) = 1
    ctype(8) = 1
    ctype(9) = 1
    ctype(10) = 2 'pcm
    ctype(11) = 3 'noise

    OPEN "temp\file.inf" FOR INPUT AS #1234
    LINE INPUT #1234, a$
    LINE INPUT #1234, a$: restart& = VAL(a$)
    LINE INPUT #1234, a$: total& = VAL(a$)
    CLOSE #1234

    PRINT "File info read..."


    DIM effectdat&(1 TO 11)
    DIM effectval&(1 TO 11)

    DIM row$(1 TO 11)
    FOR i = 1 TO 11
        row$(i) = "     "
        effectdat&(i) = 255
        effectval&(i) = 255
    NEXT i

    DIM quotient(1 TO 11) AS DOUBLE

    FOR i = 1 TO 11

        quotient(i) = vol&(i) / 64

    NEXT i

    DIM slidestep(1 TO 11) AS DOUBLE

    DIM slidetarget&(1 TO 11)
    DIM slidespeed&(1 TO 11)

    DIM volslidepos(1 TO 11) AS DOUBLE
    DIM volslidespeed(1 TO 11) AS DOUBLE

    DIM arpnote1&(1 TO 11)
    DIM arpnote2&(1 TO 11)

    DIM vibstep(1 TO 11  )   AS DOUBLE
    DIM vibspeed&(1 TO 11)
    DIM vibdepth&(1 TO 11)

    DIM curins&(1 TO 11)
    DIM curnote&(1 TO 11)
    DIM curvol&(1 TO 11)
    DIM curfreq&(1 TO 9)
    DIM xmins&

    PRINT "Effect vals initialized"

    IF filetype& = 2 THEN
        FOR i =  1 TO 11
            IF present&(i) = 1 THEN
                IF i = 11 THEN
                    PUT$ #20, CHR$(&hE6)
                ELSE
                    PUT$ #20, CHR$(&hE0 + esfchan&(i))
                END IF
            END IF
        NEXT i
    END IF

    DIM currow AS LONG

    DIM conversion AS DOUBLE

    FOR currow = 1 TO total&
        IF currow-1 = restart& THEN
            IF esfloop& = 1 THEN PUT$ #20, CHR$(&hFD)
        END IF



        FOR i = 1 TO 11
            IF present&(i) = 1 THEN

                GET #i, , row$(i)
                xmnote&=      ASC(MID$(row$(i), 1, 1))
                xmins& =      ASC(MID$(row$(i), 2, 1))
                xmvol& =      ASC(MID$(row$(i), 3, 1))
                xmeff& =      ASC(MID$(row$(i), 4, 1))
                xmeffdat& =   ASC(MID$(row$(i), 5, 1))

' TEMP: Converting XM volume to FM volume (formula supplied by sik)

'-(int(log10(x / 63.0) * 63))

                IF xmeff& >4 OR xmeff& = 0 THEN
                    slidestep(i) = 0
                    slidespeed&(i) = 0
                    slidetarget&(i) = 0
                END IF

                IF xmeff& = 0 AND xmeffdat& = 0 THEN

                    curvol&(i) = 64
                    effectdat&(i) = 255
                    effectval&(i) = 255
                END IF

                IF xmeff& = 0 AND xmeffdat& <> 0 THEN
                    effectdat&(i) = 0
                    effectval&(i) = xmeffdat&
                    arpnote1&(i) = INT(xmeffdat& / 16)
                    arpnote2&(i) = INT(xmeffdat& MOD 16)
                END IF

                IF xmeff& = 8 THEN
                    'Set Panning
                    IF ctype(i) <> 0 AND ctype(i) <> 2 THEN
                        PRINT "WARNING: Panning on PSG or Noise channel! Ignoring..."
                    ELSE
                        PUT$ #20, CHR$(esfchan&(i) + &hF0)                 '' 9-9-2011 this is teh bugfix for panning..... yah isux inorite?
                        IF xmeffdat& = &h80 THEN
                            PUT$ #20, CHR$(&hC0)
                        ELSEIF xmeffdat& > &h80 THEN
                            PUT$ #20, CHR$(&h40)
                        ELSE
                            PUT$ #20, CHR$(&h80)
                        END IF
                    END IF
                END IF

                IF xmeff& = 4 THEN

                        IF effectdat&(i) = 4 THEN
                            vibspeed&(i) = INT(xmeffdat& / 16)
                            vibdepth&(i) = INT(xmeffdat& MOD 16)
                        effectdat&(i) = 4
                        effectval&(i) = xmeffdat&

                        ELSE
                        effectdat&(i) = 4
                        effectval&(i) = xmeffdat&

                            vibspeed&(i) = INT(xmeffdat& / 16)
                            vibdepth&(i) = INT(xmeffdat& MOD 16)
                            vibstep(i) = 0
                        END IF
                END IF




                IF xmeff& = 3 THEN
                        IF effectdat&(i) > 4 OR effectdat&(i) = 1 THEN
                            slidestep(i) = curnote&(i)
                            IF effectdat&(i) = 3 THEN
                                IF slidespeed&(i) < 0 THEN
                                    slidespeed&(i) = (-1) * xmeffdat&
                                ELSE
                                    slidespeed&(I) = xmeffdat&
                                END IF
                            END IF

                        ELSE

                        END IF

                        effectdat&(i) = 3
                        effectval&(i) = xmeffdat&



                    IF xmnote& > 0 AND xmnote& < 97 THEN
                      IF slidestep(i) <> 0 THEN
                       IF xmnote& + pitch&(i) < slidestep(i) THEN slidespeed&(i) = (-1)*xmeffdat& ELSE slidespeed&(i) = xmeffdat&

                      ELSE
                       IF xmnote& + pitch&(i) < curnote&(i) THEN slidespeed&(i) = (-1)*xmeffdat& ELSE slidespeed&(i) = xmeffdat&
                       slidestep(i) = curnote&(i)
                      END IF
                        slidetarget&(i) = xmnote& + pitch&(i)


                    END IF
                END IF

                IF xmeff& = 1 THEN

                        IF effectdat&(i) <> 1 THEN slidestep(i) = curnote&(i)
                        effectdat&(i) = 1
                        effectval&(i) = xmeffdat&


                IF xmnote& < 97 AND xmnote& > 0 THEN  curnote&(i) = xmnote& +pitch&(i)

                       slidespeed&(i) = xmeffdat&
                       sliDetarget&(i) = 96
                END IF
                IF xmnote& < 97 AND xmnote& > 0 THEN  curnote&(i) = xmnote& +pitch&(i)

                IF xmeff& = 2 AND xmnote& > 0 AND xmnote& < 97  THEN
                        effectdat&(i) = 2
                        effectval&(i) = xmeffdat&
                       IF xmnote& < 97 AND xmnote& > 0 THEN  curnote&(i) = xmnote& +pitch&(i)
                       slidestep(i) = curnote&(i)
                       slidespeed&(i) = -xmeffdat&
                       sliDetarget&(i) = 0
                END IF

                IF xmnote& = 97 THEN

                    PUT$ #20, CHR$(esfchan&(i)+&h10)

                END IF
                IF xmnote& < 97 AND xmnote& > 0 THEN  curnote&(i) = xmnote& +pitch&(i)



                IF xmnote& > 0 AND xmnote& < 97 THEN

                   IF ctype(i) = 0 OR ctype(i) = 1 THEN
                            SELECT CASE effectdat&(i)
                                CASE 1 TO 4
                                    liquidtlo& = 24
                                CASE &hC
                                CASE ELSE

                                          'reset volume
                                          PUT$ #20, CHR$(esfchan&(i) + &h20)                        ' it took me seven hours to find out this actually belong here

                                          ' Hoyl shit guys. this is terrible.

                                          IF ctype(i) = 0 THEN
                                                 curvol&(i) = 64
                                                 temp& = INT(fmvol(quotient(i) * 64))
                                                 PUT$ #20, CHR$(temp&)
                                          ELSE
                                                 curvol&(i) = 64
                                                 temp& = INT(psgvol(quotient(i) * 64))
                                                 PUT$ #20, CHR$(temp&)
                                          END IF
                            END SELECT

                            IF liquidtlo& <> 24 THEN


                            'instrument being 0 means that we play the note as if the instrument is the same
                            IF curins&(i) <> xmins&  THEN

                              IF ctype(i) <> 2 THEN
                                curins&(i) = xmins&

                                PUT$ #20, CHR$(&H40 + esfchan&(i))
                                PUT$ #20, CHR$(INT(esfins&(curins&(i))))

                              END IF
                            END IF

                            IF ctype(i) = 0 THEN

                                PUT$ #20, CHR$(esfchan&(i))
                                PUT$ #20, CHR$(INT(32 * INT(curnote&(i) / 12) + (2 * (curnote&(i) MOD 12)) + 1))

                            ELSEIF ctype(i) = 1 THEN

                                PUT$ #20, CHR$(esfchan&(i))
                                PUT$ #20, CHR$(INT(24 * INT(curnote&(i) / 12) + (2 * (curnote&(i) MOD 12))))

                            END IF

                            END IF
                                liquidtlo& = 0



                    ELSEIF ctype(i) = 2 THEN

                            curins&(i) = xmins&
                            PUT$ #20, CHR$(esfchan&(i))
                            PUT$ #20, CHR$(esfins&(curins&(i)))

                    ELSEIF ctype(i) = 3 THEN
                        SELECT CASE xmeff&
                                CASE 1 TO 4
                                    liquidtlo& = 24
                                CASE ELSE

                                    IF xmeff& <> &hC  THEN
                                          'reset volume

                                                 PUT$ #20, CHR$(&h2B)
                                                 curvol&(i) = 64
                                                 PUT$ #20, CHR$(psgvol(quotient(i) * 64))




                                    END IF
                            END SELECT

                            IF liquidtlo& <>24 THEN

                            IF curins&(i) <> xmins& THEN
                              Curins&(i) = xmins&

                                PUT$ #20, CHR$(&H40 + esfchan&(i))
                                PUT$ #20, CHR$(esfins&(curins&(i)))

                            END IF
                            tmp& = 0
                            IF noisetype& = 1 THEN
                                tmp& = 3
                                PUT$ #20, CHR$(&hB)
                                IF noisemode& = 0 THEN
                                    PUT$ #20, CHR$(&h0)
                                ELSE
                                    PUT$ #20, CHR$(&h4)
                                END IF
                            ELSE
                                tmp& = 3
                                curfreq&(i) = INT((0.5^((curnote&(i))/12-1))/2*851)
                                PUT$ #20, CHR$(&h3A)
                                PUT$ #20, CHR$(INT(curfreq&(i) MOD 16)) + CHR$(INT(curfreq&(i) / 16))
                                PUT$ #20, CHR$(&hB)
                                IF noisemode& = 1 THEN
                                    PUT$ #20, CHR$(&h3)
                                ELSE
                                    PUT$ #20, CHR$(&h7)
                                END IF

                            END IF


                            END IF
                                liquidtlo& = 0

                    END IF

                END IF

                IF xmeff& = &HA THEN

                    IF ctype(i) <> 2 THEN
                          IF effectdat&(i) <> &hA THEN
                          effectdat&(i) = &hA
                          volslidepos(i) = curvol&(i)
                          END IF
                          IF INT(xmeffdat& / 16) = &hF AND INT(xmeffdat& MOD 16) > 0 THEN
                              PRINT "WARNING: Fine volume slide detected, ignoring"
                          ELSEIF INT(xmeffdat& MOD 16) = &hF AND INT(xmeffdat& / 16) > 0 THEN
                              PRINT "WARNING: Fine volume slide detected, ignoring"
                          ELSE
                              IF INT(xmeffdat& MOD 16) > 0 THEN
                                  ' Volume slide DOWN
                                  volslidespeed(i) = -(tempo& - 1)
                                  effectval&(i) = INT(xmeffdat& MOD 16)
                              ELSEIF INT(xmeffdat& / 16) > 0 THEN
                                  volslidespeed(i) = (tempo& - 1)
                                  effectval&(i) = INT(xmeffdat& / 16)
                              END IF
                          END IF
                    END IF
                END IF



                IF xmeff& = &HC THEN
                 IF ctype(i) = 0 THEN
                    effectdat&(i) = &HC
                    effectval&(i) = xmeffdat&
                    PUT$ #20, CHR$(esfchan&(i) + &H20)

                    temp& = INT(fmvol(xmeffdat& * quotient(i)))
                    PUT$ #20, CHR$(temp&)

                  ELSEIF ctype(i)=1 THEN

                    effectdat&(i)= &HC
                    effectval&(i) = xmeffdat&
                    PUT$ #20, CHR$(esfchan&(i) + &H20)
                    PUT$ #20, CHR$(temp&)

                  ELSEIF ctype(i) = 3 THEN
                    effectdat&(i) = &HC
                    effectval&(i) = xmeffdat&

                    PUT$ #20, CHR$(&h2B)
                    temp& = INT(psgvol(xmeffdat& * quotient(i)))
                    PUT$ #20, CHR$(temp&)

                  ELSE
                      'ignore for pcm +noise
                      effectdat&(i) = 255
                      effectval&(i) = 255
                  END IF
                 END IF





            END IF
        NEXT i

        FOR pf& = 1 TO tempo&
        ' PROCESS EFFECTS

        ' 0     Arpeggio
        ' 1     Portamento up
        ' 2     Portamento down
        ' 3     Tone portamento
        ' 4     Vibrato

            FOR i = 1 TO 11

                SELECT CASE effectdat&(i)


                CASE &h0
                    IF effectval&(i) <> 0 THEN
                          IF ctype(i) < 2 THEN
                               SELECT CASE pf& MOD 3
                                    CASE 0

                                        IF ctype(i) = 0 THEN
                                            curfreq&(i) = fmfreq2(curnote&(i))
                                            PUT$ #20, CHR$(esfchan&(i) + &h30)
                                            PUT$ #20, CHR$(INT(curfreq&(i) / 256))
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 256))

                                        ELSE

                                            curfreq&(i) = INT((0.5^((curnote&(i))/12-1))/2*851)
                                            PUT$ #20, CHR$(esfchan&(i) + &h30)
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 16)) + CHR$(INT(curfreq&(i) / 16))

                                        END IF
                                    CASE 1

                                        IF ctype(i) = 0 THEN

                                             curfreq&(i) = fmfreq2(curnote&(i) + arpnote1&(i))
                                            PUT$ #20, CHR$(esfchan&(i) + &h30)
                                            PUT$ #20, CHR$(INT(curfreq&(i) / 256))
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 256))

                                        ELSE

                                            curfreq&(i) = INT((0.5^((curnote&(i) + arpnote1&(i))/12-1))/2*851)
                                            PUT$ #20, CHR$(esfchan&(i) + &h30)
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 16)) + CHR$(INT(curfreq&(i) / 16))

                                        END IF
                                    CASE 2

                                        IF ctype(i) = 0 THEN
                                             curfreq&(i) = fmfreq2(curnote&(i) + arpnote2&(i))
                                             PUT$ #20, CHR$(esfchan&(i) + &h30)
                                            PUT$ #20, CHR$(INT(curfreq&(i) / 256))
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 256))

                                        ELSE

                                            curfreq&(i) = INT((0.5^((curnote&(i) + arpnote2&(i))/12-1))/2*851)
                                            PUT$ #20, CHR$(esfchan&(i) + &h30)
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 16)) + CHR$(INT(curfreq&(i) / 16))

                                        END IF
                                    END SELECT
                          END IF
                    END IF
                CASE &hA
                    'Volume slide. one tick is (ticks per row - 1) from real volume ( 0 to 63)
                   IF pf& < effectval&(i)+1 THEN
                    IF ctype(i) <> 2 THEN
                            IF volslidepos(i) < 65 AND volslidepos(i) > 0 THEN
                                volslidepos(i) = volslidepos(i) + volslidespeed(i)/5
                                IF volslidepos(i) < 0 THEN volslidepos(i) = 0
                               curvol&(i) = volslidepos(i)

                            ELSE

                            END IF

                            IF volslidepos(i) < 65 AND volslidepos(i) > -1 THEN
                             IF ctype(i) = 0 THEN
                                PUT$ #20, CHR$(esfchan&(i) + &H20)
                                PUT$ #20, CHR$(fmvol(quotient(i) * volslidepos(i)))

                             ELSE
                                IF ctype(i) = 3 THEN PUT$ #20, CHR$(&H2A) ELSE PUT$ #20, CHR$(esfchan&(i) + &H20)
                                PUT$ #20, CHR$(psgvol(quotient(i) * volslidepos(i)))
                             END IF
                            END IF
                    END IF
                   END IF

                CASE 1 TO 2

                    IF ctype(i) <> 2 THEN
                        slidestep(i) = slidestep(i) + slidespeed&(i) / 20
                        IF effectdat&(i) = 2 THEN
                            IF slidetarget&(i) > slidestep(i) THEN slidestep(i) = slidetarget&(i)
                        ELSE
                            IF slidetarget&(i) < slidestep(i) THEN slidestep(i) = slidetarget&(i)
                        END IF
                        IF ctype(i)= 3 THEN
                            PUT$ #20, CHR$(&h3A)
                        ELSE
                            PUT$ #20, CHR$(esfchan&(i) + &H30)
                        END IF

                        SELECT CASE ctype(i)
                            CASE 0

                                curfreq&(i) = fmfreq(slidestep(i))
                                PUT$ #20, CHR$(INT(curfreq&(i) / 256))
                                PUT$ #20, CHR$(INT(curfreq&(i) MOD 256))

                            CASE 1 TO 3
                                curfreq&(i) = INT((0.5^((slidestep(i)/12))*2)/2*851)
                                            PUT$ #20, CHR$(INT(curfreq&(i) MOD 16)) + CHR$(INT(curfreq&(i) / 16))
                        END SELECT
                    END IF

                CASE 3
                    slidestep(i) = slidestep(i) + slidespeed&(i) / 20
                    IF slidespeed&(i) < 0 AND slidetarget&(i) > slidestep(i) THEN slidestep(i) = slidetarget&(i)
                    IF slidespeed&(i) > 0 AND slidetarget&(i) < slidestep(i) THEN slidestep(i) = slidetarget&(i)

                    IF ctype(i) = 0 THEN
                     curfreq&(i) = fmfreq(slidestep(i))
                     PUT$ #20, CHR$(esfchan&(i) + &H30)
                     temp& = INT(curfreq&(i) / 256 )
                     PUT$ #20, CHR$(temp&)
                     temp& = INT(curfreq&(i) MOD 256)
                     PUT$ #20, CHR$(temp&)



                    ELSEIF ctype(i) = 1 THEN

                     curfreq&(i) = INT((0.5^((slidestep(i)/12))*2)/2*851)
                     PUT$ #20, CHR$(esfchan&(i) + &H30)
                     temp& = INT(curfreq&(i) MOD 16)
                     PUT$ #20, CHR$(temp&)
                     temp& = INT(curfreq&(i) / 16)
                     PUT$ #20, CHR$(temp&)

                    ELSEIF ctype(i) = 3 THEN

                    IF noisetype& = 1 THEN
                     curfreq&(i) = INT((0.5^((slidestep(i)/12))*2)/2*851)
                     PUT$ #20, CHR$(&h3A)    'PSG Channel 3
                     temp& = INT(curfreq&(i) MOD 16)
                     PUT$ #20, CHR$(temp&)
                     temp& = INT(curfreq&(i) / 16)
                     PUT$ #20, CHR$(temp&)


                    END IF


                        ' Ignore this effect for anything else


                   END IF
                CASE 4
                   vibstep(i) = vibstep(i) + vibspeed&(i)*4
                   conversion = SIN(pi/180 * vibstep(i))*vibdepth&(i)/5 + curnote&(i)


                   IF ctype(i) = 0 THEN
                   curfreq&(i) = INT(fmfreq(conversion))
                                PUT$ #20, CHR$(esfchan&(i) + &h30)
                                PUT$ #20, CHR$(INT(curfreq&(i) / 256))
                                PUT$ #20, CHR$(INT(curfreq&(i) MOD 256))
                   ELSEIF ctype(i) <> 2 THEN
                   curfreq&(i) = INT((0.5^((slidestep(i)/12))*2)/2*851)
                                IF ctype(i) <> 3 THEN
                                    PUT$ #20, CHR$(esfchan&(i) + &h30)
                                ELSE
                                    PUT$ #20, CHR$(&h3A)
                                END IF
                                PUT$ #20, CHR$(INT(curfreq&(i) / 256))
                                PUT$ #20, CHR$(INT(curfreq&(i) MOD 256))
                   END IF


                END SELECT
            NEXT i

            PUT$ #20, CHR$(&HFE)
            PUT$ #20, CHR$(&H1)
        NEXT pf&
    NEXT currow

    IF esfloop& = 0 THEN PUT$ #20, CHR$(&hFF) ELSE PUT$ #20, CHR$(&hFC)

    PRINT "Conversion done!"

    CLOSE
    TRACE CLOSE

END FUNCTION


FUNCTION param(strn$, b&) AS STRING
    c& = 0
    i& = 1
    car$ = MID$(strn$, 1, 1)
    IF car$ = CHR$(34) THEN
        comp$ = CHR$(34)
        i& = 2
        car$ = MID$(strn$, 2, 1)
    ELSE
        comp$ = " "
    END IF
    WHILE c& <> b&
    WHILE car$ <> comp$
          SPEFT$ = SPEFT$ + car$
          i& = i& + 1
          car$ = MID$(strn$, i&, 1)
          IF i& > LEN(strn$) THEN
              SPEFT$ = ""
              param = SPEFT$
              EXIT FUNCTION
          END IF
    WEND

   i& = i& + 1
   c& = c& + 1
   ' SPEFT$ = MID$(strn$, i&, 1)
    car$ = SPEFT$
    WEND


    param = RTRIM$(spleft(MID$(strn$,i&)))

END FUNCTION

FUNCTION SPLEFT(strn$) AS STRING

    i& = 1
    car$ = MID$(strn$, 1, 1)
    IF car$ = CHR$(34) THEN
        comp$ = CHR$(34)
        i& = 2
        car$ = MID$(strn$, 2, 1)
    ELSE
        comp$ = " "
    END IF
    WHILE car$ <> comp$
          SPEFT$ = SPEFT$ + car$
          i& = i& + 1
          car$ = MID$(strn$, i&, 1)
          IF i& > LEN(strn$) THEN
              SPLEFT = SPEFT$ + cars$
              EXIT FUNCTION
          END IF
    WEND
              SPLEFT = SPEFT$
END FUNCTION

FUNCTION fmfreq(a AS DOUBLE) AS INTEGER

                                temp2& = INT(644*(2^(((a) MOD 12)/12)))

                           '     print 644*(2^(((slidestep(i)-1) MOD 12)/12))
                                temp& =          ((INT(a/12)) * 2048)
                          '      print bin$(    temp&    ,16)

                                temp2& = INT((temp2& AND 2047) + temp&)

                                fmfreq=temp2&
END FUNCTION


FUNCTION fmfreq2(a AS LONG   ) AS INTEGER

                                temp2& = INT(644*(2^(((a) MOD 12)/12)))

                           '     print 644*(2^(((slidestep(i)-1) MOD 12)/12))
                                temp& =          ((INT(a/12)) * 2048)
                          '      print bin$(    temp&    ,16)

                                temp2& = INT((temp2& AND 2047) + temp&)
                                fmfreq2=temp2&
END FUNCTION


FUNCTION fmvol(a AS DOUBLE) AS BYTE

    DIM b AS INTEGER
    b = -(INT(LOG10(a / 63.0) * 63))
    IF b > 127 THEN b = 127
    IF b < 0 THEN b = 0
    IF a = 64 THEN b = 0
    IF a = 0  THEN b = 127

    fmvol= b

END FUNCTION

FUNCTION fmvol2(a AS INTEGER) AS BYTE

    DIM b AS INTEGER
    b =  -(INT(LOG10(a / 63.0) * 63))
    IF b > 127 THEN b = 127
    IF b < 0 THEN b = 0
    IF a = 64 THEN b = 0
    IF a = 0  THEN b= 127

    fmvol2= b
END FUNCTION


FUNCTION psgvol(a AS DOUBLE) AS BYTE

    DIM b AS INTEGER
    b =   -(INT(LOG10(a / 63.0) * 7))


    IF b > 15 THEN b = 15
    IF a = 64 THEN b = 0
    IF a = 0  THEN b = 15
    psgvol= b
END FUNCTION

FUNCTION psgvol2(a AS INTEGER) AS BYTE

    DIM b AS INTEGER
    b =   -(INT(LOG10(a / 63.0) * 7))

    IF b > 15 THEN b = 15
    IF a = 64 THEN b = 0
    IF a = 0  THEN b = 15

    psgvol2 = b

END FUNCTION