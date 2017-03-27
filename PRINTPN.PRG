set device to print
set print on

setprc (0,0)
@ prow (),00     say chr(18)
@ prow (),pcol() say chr(27)+chr(80)
@ prow (),pcol() say chr(27)+chr(67)+chr(39)
nctr := 0

do while nctr <= 1

   @ 2 ,72 say '123456'                  // PN NUMBER
   @ 3 ,64 say '001-201-999999'          // INTERNAL ACCOUNT NUMBER
   @ 5 ,67 say '12/03/2007'              // VALUE DATE
   @ 6 ,67 say '30 DAYS'                 // TERM
   @ 7 ,67 say '01/02/2008'              // MATURITY DATE
   @ 13,10 say 'ONE MILLION PESOS'       // AMOUNT IN WORDS
   @ 17,10 say 'EDUARDO R. ALVAREZ'      // PAYEE/s
   @ 20,10 say 'ONE MILLION FIVE THOUSAND PESOS'   // PRINCIPAL SUM
   @ 22,23 say ' 6.00%'                            // ANNUAL RATE

   @ 26,09 say 'PROTACIO C. BANTAYAN JR.'
   @ 26,49 say 'EDNA L. LAYOSA'

   @ 28,23 say '2007-101'
   @ 28,63 say '2007-102'
   @ 29,23 say '11/28/2007'
   @ 29,63 say '11/28/2007'

   __eject()
   nctr++

enddo

__eject()

setprc(0,0)
@ prow(),00     say chr(18)
@ prow(),pcol() say chr(27)+chr(80)
@ prow(),pcol() say chr(27)+chr(67)+chr(66)

set print off
set device to screen
