
alert ( "start of the program"  )

set century on

sele 1
use intsked
// inde on d1 + dtos(paydate) to spred
set inde to spred

sele 2
use udi0800
set index to d2

alert ( "START OF PROCESSING . . ."  )

select 2
go top
do while !eof()

   md1 = d1
   sele intsked
   seek md1 + '200008'

   if found()

      sele udi0800

      if substr(udi0800->d1,1,4) != '1801'

*************         if udi0800->valdate >= ctod ( '06/01/2000' )
*************            replace d5 with intsked->intamt
*************         endif
*************      else

         replace d5 with intsked->intamt
      endif

   endif

   sele udi0800
   skip

enddo

alert ( "END OF THE PROGRAM AND PROCESSING"  )
