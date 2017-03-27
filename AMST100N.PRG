/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  AMST100N.PRG                                         ³
³   Description........:  Other Collaterals                                    ³
³   Author.............:  Renan S. Evangelista                                 ³
³   Date...............:  01:30pm 05-Jun-1996                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        ABB        ³     10.22.04  ³         FOR ONLINE USE                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "INKEY.CH"
#include "SETCURS.CH"
#include "COLF.CH"


*************************************
*
Function othercoltrl(nAcctn)
*************************************
#defi clr_mono "w/n,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,w/n"
#defi clr_colo "w/gr,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/gr"

local _dcolor:=iscolor(),old_scr:=savescreen( , , , )
local mu:=savedbf(),xamp2,recnum
local col1_,old_row,tot_count,lLength,nstart,xamp,b,ch
local _afld:={},st_:={},f6flg:=.f.

tones()
if !CHKPASS(procname(), AX_LEVEL, g_USER_ID)
    return
endif

dbselectarea('Ctrlothr')
Ctrlothr->(dbsetorder(1))       // brcode + acctno
**Ctrlothr->(dbseek(Acctdaly->brcode+Acctdaly->acctno))    // abb 10.22.2004

Ctrlothr->(dbseek(nACCTN))    && RED

//chkifeof()
fShadow( 8, 3, 23, 78, 2, 'n/w', 'Other Collateral' )
@ 8,4 say 'Other Collateral' color 'w+/w'
for x:=10 to 21
    @ x, 78 say chr(177)  color 'w/n'
next

@ 22,78 say  chr(31)  color 'n/w+'
@ 9,78  say  chr(30)  color 'n/w+'

@ 24,01 say '<Ins>-Add  <F2>-Edit               <Del>-Delete  <'+chr(27)+chr(24)+chr(25)+chr(26)+'><PgUp> <PgDn> <Esc>'  color 'w+/n'
@ 24,06 say '-Add'    color 'w/n'
@ 24,16 say '-Edit'   color 'w/n'
//@ 24,27 say '-Codes'  color 'w/n'
@ 24,41 say '-Delete' color 'w/n'

col1_:={                ;
        tbcolumnnew( padc('Other Collateral Description',70), {|| Colainfo   })         ;
        }
//tbcolumnnew('Account No.',   {|| tran(Acctno,'@R 9999-99999-99999')} ) ;
b := TBrowseDB(09,4,22,77)
FOR x := 1 TO len(col1_)
    b:AddColumn(col1_[x])
NEXT
old_row         := 10
***** tot_count       := count_them(nacctn,@st_,b)  //b:rowcount  abb 10.22.04
tot_count       := 0
lLength         := 12
nstart          := 9
xamp            := round(lLength/tot_count,2)    //if(round(lLength/tot_count,0) < 1,1,round(lLength/tot_count,0))


b:gotopblock    := { |   |  fRecp0700( 'top'   , nACCTN ) }                          &&Acctdaly->brcode+nacctn ) }
b:gobottomblock := { |   |  fRecp0700( 'bottom', nACCTN ) }                          &&Acctdaly->brcode+nacctn ) }
b:skipblock     := { | n |  fRecp0700( 'skip'  , nACCTN,  ;                          &&Acctdaly->brcode+nacctn,  ;
                   { | x |  CTRLOTHR->BRCODE+Ctrlothr->Acctno == nACCTN }, n ) }     &&{ | x |  Ctrlothr->Acctno == nACCTN .and. ;
                                                                                     &&         Ctrlothr->Brcode == Acctdaly->brcode ;

b:colpos        := 2
b:headSep       := "ÄÂÄ"
b:colSep        := " ³ "
b:gotop()
b:colorspec     := clr_colo
b:refreshall()
recnum          := 1
DO WHILE .t.
   DO WHILE .not. b:stabilize()
      ch := Inkey()
      IF ch <> 0
         exit
      ENDIF
   ENDDO

   b:colorRect({b:rowpos,1,b:rowpos,b:colcount},{3,4})
   recnum := ascan(st_,recno())

   dispbegin()
      xamp2:=if(round(recnum*xamp,0) <= 0,1,round(recnum*xamp,0) )
      xamp2:=if(xamp2 >= lLength,lLength,xamp2)
      xamp2:=if(recnum = 1, 1, xamp2)
      @old_row, 78 say '±' color 'w/n'
      old_row:=nstart+xamp2
      @old_row, 78 say 'þ' color 'n/w+'
   dispend()

   IF b:stable
      IF b:hittop .OR. b:hitbottom
         TONE(1000,5)
         if(b:hittop,b:gotop(),b:gobottom())
      endif
      if !f6flg
         ch := eval({|| Inkey( 0 ) } )
      else
         ch := K_F6
         f6flg:=.f.
      endif
   endif

      setcursor(0)
      IF ch == K_UP
         recnum := if(recnum-1 <= 0,1,recnum-1)
         nrecno := Ctrlothr->(recno())
         Ctrlothr->(dbskip(-1))
         if Ctrlothr->(bof()) .or. ;
            CTRLOTHR->BRCODE+CTRLOTHR->ACCTNO != nACCTN
            &&Ctrlothr->brcode != sbrcode .or. ;
            &&Ctrlothr->acctno != Acctdaly->Acctno
            // Ctrlothr->(dbseek(sbrcode+Acctdaly->acctno))
            Ctrlothr->(dbgoto(nrecno))
            loop
         endif
//         b:up()
         b:refreshall()
      ELSEIF ch == K_DOWN
      **   if !empty(st_)

         nrecno := Ctrlothr->(recno())
         Ctrlothr->(dbskip(+1))
         if Ctrlothr->(eof()) .or. ;
            CTRLOTHR->BRCODE+CTRLOTHR->ACCTNO != nACCTN
            &&Ctrlothr->brcode != sbrcode .or. ;
            &&Ctrlothr->acctno != Acctdaly->Acctno
            Ctrlothr->(dbgoto(nrecno))
            loop
         endif

  //          b:down()
            b:refreshall()
**         else
**             if empty(st_)
**               __keyboard( chr(K_UP) )
**             endif
**             tone(1000,3)
**         endif
      ELSEIF ch == K_LEFT
      ELSEIF ch == K_RIGHT
      ELSEIF ch == K_F3
        _dcolor:=!_dcolor
        b:colorspec := if(!_dcolor,clr_mono,clr_colo)
        b:gotop()
        b:configure()
      ELSEIF ch == K_PGUP
          b:pageUp()
          b:refreshall()
      ELSEIF ch == K_PGDN
          if !empty(st_)
             b:pageDown()
             b:refreshall()
          else
            tone(1000,3)
          endif
      ELSEIF ch == K_CTRL_PGUP
          recnum:=1
          b:gotop()
          b:refreshall()
      ELSEIF ch == K_CTRL_PGDN
          recnum:=tot_count
          if !empty(st_)
             b:goBotTOm()
             b:refreshall()
          else
             tone(1000,3)
          endif
      ELSEIF ch == K_ESC
          if Exitmod()
             exit
          endif
      ELSEIF ch == K_INS
              IF CURRBRCH(LEFT(nACCTN,3))
                 edit_cell(.t.,nacctn)
****                 xamp:=round(lLength/count_them(nacctn,@st_,b),2)
                 /*if empty(st_)    && RED
                    dbgobottom()
                    dbskip(1)
                 endif*/
                 b:refreshall()
              ENDIF
      ELSEIF ch == K_DEL
**          if empty(st_)
  **           tone(980,2)
    **         loop
      **    endif

          if CURRBRCH(CTRLOTHR->BRCODE) .AND. yes_no2( 'Delete this Record ? ',, ' Yes ', ' No ', .f. )
             MSGWIN(12,35,'Deleting','W+/BG','R*/BG','ON')
             if Ctrlothr->(netlock('R',5))
                tone(700,0)
                Ctrlothr->(dbdelete())
                Ctrlothr->(dbskip(+1))
                Ctrlothr->(dbunlock())
             endif
             MSGWIN(12,35,'Deleting',,,'OFF')
//            xamp:=round(lLength/count_them(nacctn,@st_,b),2)
             b:refreshall()
          endif
      ELSEIF ch == K_F2
**          if empty(st_)
  **           tone(990,2)
    **         loop
      **    endif
          IF CURRBRCH(CTRLOTHR->BRCODE)
          EDIT_CELL(.f.,nacctn)
          b:refreshcurrent()
          ENDIF
      ENDIF
    //b:refreshall()
ENDDO

restscreen(, , , ,old_scr)
//Colacode->(dbclosearea())
//Ctrlothr->(dbclosearea())
restdbf(mu)
return nil
//////-------------------------------------
Static Function edit_cell( addflg,nAcctno )         //Edit or add to CTRLOTHR
local old_colo,editflg,nkey,_afld,dg,ndata:=if(addflg,spac(73), Ctrlothr->Colainfo )
local gf:=savescreen( ,,, ),bf:=savedbf(),xx:='',eva_:=setcursor()
_afld:={}
setcursor(1)
old_colo:=setcolor()
setcolor('w/n,w+/n')
xx:=if( addflg,'Type','Edit' )
fShadow( 10, 5, 12, 70, 2, 'w/bg+' )
@ 10,7 say xx + ' your Data Here' color 'n/bg+'
@ 11,6 get ndata picture '@!XS63'

setkey ( K_ESC, { || Fescape('Abort') } )
setcursor(3)
read
setkey ( K_ESC, nil )
setcursor(0)

if lastkey() <>  K_ESC
   MSGWIN(12,35,'Saving','W+/BG','R*/BG','On')
   IF Ctrlothr->(netlock( if(addflg, 'A', 'R' ), 5))
      Ctrlothr->Acctno  := RIGHT(nAcctno,14)
      Ctrlothr->Colainfo:= ndata
      Ctrlothr->brcode  := LEFT(nACCTNO,3)   &&sbrcode
      Ctrlothr->( dbunlock() )
      Ctrlothr->( dbcommit() )
   ENDIF
   MSGWIN(12,35,'Saving',,,'OfF')
endif

if lastkey() <> K_ESC .and. addflg
//    Ctrlothr->(dbseek(sbrcode+nAcctno+ndata,.f.))
   &&Ctrlothr->(dbseek(sbrcode+nAcctno,.f.))
   Ctrlothr->(dbseek(nACCTNO,.f.))
endif

setcolor(old_colo)
setcursor(0)
setcursor(eva_)
restscreen( ,,,,gf )
//restdbf(bf)
return nil

/////------------------------------------------------------
static function fRecp0700( how, what, which, howmany, vax )    //skip block function that filters the display
local  actual := 0, soft                                       //of records per account number

do case
   case how = 'top'
        dbseek( what,.f. )
   case how = 'bottom'
        soft  := set( _SET_SOFTSEEK, .t. )
        dbseek( left( what, len( what ) - 1 ) + chr( 255 ) )
        dbskip( -1 )
        set( _SET_SOFTSEEK, soft )
   case how = 'skip'
        do case
           case howmany < 0
                while ( actual > howmany ) .and. ( !bof() ) .and.;
                      eval( which, what )
                      dbskip( -1 )
                      if !bof() .and. eval( which, what )
                         actual--
                      endif
                enddo
                if !eval( which, what )
                   dbskip( +1 )
                endif    
           case howmany > 0
                while ( actual < howmany ) .and. ( !eof() ) .and.;
                      eval( which, what )
                      dbskip( +1 )
                      if !eof() .and. eval( which, what )
                         actual++
                      endif
                enddo
                if ( eof() .or. !eval( which, what ) ) .and. !empty( what )
                   dbskip( -1 )
                endif
                dbskip(0)
           otherwise
                dbskip( 0 )
        endcase
   otherwise
endcase
return( actual )

/////-----------------------------------
static Function count_them(nacct,ts_,b)  //reccount of all undeleted and filtered records
local mValue:=0,nrec:=recno()

ts_:={}
//dbgotop()

do while !eof()
  if !empty(nacct)
     if !deleted() .and. acctno == nacct
        aadd(ts_,recno())
        mValue++
     endif
  else
     if !deleted() 
        aadd(ts_,recno())
        mValue++
     endif
  endif
  dbskip()
enddo
//if scan(ts_,nrec) == 0
altd()
dbgoto(nrec)
if deleted()
   while deleted() .and. !eof();dbskip();enddo
   if eof()
      while deleted() .and. !bof();dbskip(-1);enddo
      if bof()
         dbgobottom()
         dbskip(1)
      endif
   endif
endif
b:refreshall()
return mValue
/////----------------------
////----------------------
//////////---------- E O F ---------////////
