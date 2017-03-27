
alert ( "start of the program"  )

sele 1
use intsked
// inde on d1 + dtos(paydate) to spred
set inde to spred

sele 2
use alir0800        // LEASING
set index to d1

alert ( "START OF PROCESSING . . ."  )
select 2
go top
do while !eof()
   md1 = d1
   sele intsked
   seek md1 + '200008'
   if found()
      sele alir0800
      if d3 <> 0 .or. d4 <> 0
         replace d5 with intsked->intamt
      endif
   endif
   sele alir0800
   skip
enddo
alert ( "END OF THE PROGRAM AND PROCESSING"  )
