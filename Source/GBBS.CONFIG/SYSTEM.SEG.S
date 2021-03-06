; *******************
; GBBS "Pro" V:2.2n
; Copyright 1980-2017
;  Kevin M. Smallwood
; *******************

; system segment - 4/2/90

 on nocar goto term1

system
 x=(clock(2)-clock(1))/60:y=clock(2):x$=right$("0"+str$(x),2)
 if clock(1)>clock(2) x$="!!"
 if x=0 x$="--"
 if not y x$="**"
 if info(5) x$="::"
 print \"["x$"][System Level] ";
 input "Option (?=Help):" i$:push system
 if i$="L" goto log
 if i$="F" goto file
 if i$="R" goto request
 if i$="W" goto welcome
 if i$="D" goto dos.cmd
 if i$="N" goto new.user
 if i$="S" goto set.date
 if i$="T" goto terminate
 if i$="P" goto edit.pass
 if i$="K" goto kill.pass
 if i$="G" goto edit.file
 if i$="A" pop:link "a:main.seg","fromsys"
 if i$<>"?" print \"Illegal command":return

 setint(1):print sc$\s$\'
----------------------------------
   List of supported commands:

A: Abort back    D: DOS commands
F: Read a file   G: Edit any file
K: Kill a user   L: The system log
N: Add new user  P: Edit any user
R: Read request  S: Set a new date
T: Terminate     W: Welcome update
----------------------------------':return

edit.pass
 input @2 \"Pass #" i$:if i$="" return
 a=val(i$):if i$="C" then a=un

ed.pass0
 if (a<1) or (a>nu) print \"No Such User":return
 d1$=a1$:d2$=a2$:d3$=a3$:d4$=a4$:d5$=a5$
 move ram,58 to ram2:if a<>un gosub rd.user
 if d1$<>"" goto ed.pass2
 input @2 \"No such user - create (Y/[N]) ?" i$
 if left$(i$,1)<>"Y" move ram2,58 to ram:return
ed.pass1
 fill ram,58,0:d1$="NEW":d2$="USER":
 d3$="New User":d4$="CITY":d5$="ST"
 pa$="PASSWORD":ph$="XXX-XXX-XXXX":nibble(5)=3

ed.pass2
 print \"A:"d3$\"B:"d4$", "d5$
 print "C:"a"-"pa$\"D:"ph$\"E:";
 for x=1 to 34:print flag(x);:next
 print \"F:"nibble(5)*10\"G:"when$
 input @2 \"Which (A-F):" i$

 if i$="A" input @3 \"Full Name:" d3$:gosub name.cov:goto ed.pass2
 if i$="B" input \"City:" d4$:input "State:" d5$:goto ed.pass2
 if i$="C" input \"Pass:" a$:pa$=left$(a$+"        ",8):goto ed.pass2
 if i$="D" input \"Phone:" a$:ph$=a$:goto ed.pass2
 if i$="F" input \"Time on:" x:nibble(5)=x/10
 if i$="" goto ed.pass5
 if i$<>"E" goto ed.pass2

 input @2 \"Lvl:" a$:if a$="" goto ed.pass2
 if a$="?" goto ed.pass3
 for x=1 to len(a$):if x>34 then x=len(a$)
 flag(x)=(mid$(a$,x,1)="1"):next:goto ed.pass2

ed.pass3
 open #1,"b:data2":for x=1 to 34
 position #1,32,x:input #1,a$:if a$="" goto ed.pass4
 print \a$\"Access (Y,N,S,Q):";:input @2 a$
 if a$="Q" then x=34
 if a$="Y" then flag(x)=1
 if a$="N" then flag(x)=0
ed.pass4
 next:close #1:goto ed.pass2

ed.pass5
 b=len(d1$+d2$+d4$+d5$):if b<32 goto ed.pass6
 print \"Name and City are too long."
 print "Max len=32, current len="b:goto ed.pass2

ed.pass6
 input @0 \"Save, Abort, or Return ?" i$
 if i$="A" move ram2,58 to ram:return
 if i$<>"S" goto ed.pass2
 if a>nu then nu=a
 if a=un then a1$=d1$:a2$=d2$:a3$=d3$:a4$=d4$:a5$=d5$:return
 gosub wr.user:move ram2,58 to ram:return

kill.pass
 input \"Kill #" a
 if (a<1) or (a>nu) return
 move ram,58 to ram2:gosub rd.user
 a$=mid$(" "+when$,2)
 if d1$="" print \"That user does not exist":move ram2,58 to ram:return
 print \"Kill "d3$\"Last on "a$;
 input @0 " ?" i$
 if i$<>"Y" move ram2,58 to ram:return
 d1$="":gosub wr.user
 print \"User Killed"
 move ram2,58 to ram:return

request
 print \"Read Request File":open #2,"b:request"
 if mark(2) close:print \"File empty":return
 input @2 \"Send file to printer (Y/[N]) ?" i$
 if i$="Y" setint(1):copy #2,#5:mark(2)=0
req2
 input #2,a:b=mark(2):if a goto req3
 close:input @0 \"Delete File ?" i$:if i$="Y" kill "b:request"
 return
req3
 mark(2)=b:print \md$
req3a
 input #2,i$:if i$<>chr$(1) print i$:goto req3a
 print md$
req4
 input @2 \"Request [V, K, C, R, A, Q]:" i$
 if i$="R" goto req3
 if i$="Q" close:return
 if i$="C" or i$="" goto req2
 if i$="K" then d1$="":gosub wr.user:goto req2
 if i$="V" gosub ed.pass0:goto req2
 if i$<>"A" goto req4
 print \"Enter message now, "edit(3)" col, 4k bytes max"
 print 'Type "DONE" when finished ".h" for help'
 edit(0):edit(1):if not edit(2) goto req4
 print \"Wait...";:x=mark(2):close:ready "g:mail"
 print #msg(a),1\"From ->"a3$" (#1)"
 print #6,"Date ->"date$" "time$\:copy #8,#6
 print #msg(a),chr$(4);chr$(0);:msg(a)=1:update
 open #2,"b:request":mark(2)=x
 print ".Letter sent":goto req4

file
 input @2 \"File Name (to read):" i$
 f$=i$:if i$="" return
 input @2 \"Show file on printer (Y/[N]) ?" i$
 if i$<>"Y" goto show.file
 setint(1):copy f$,#5:return

log
 input @0 \"Log: D)elete, S)how, P)rint, Q)uit ?" i$
 if i$="D" kill "b:log.system":return
 if i$="S" f$="b:log.system":gosub show.file
 if i$="P" setint(1):copy "b:log.system",#5:setint("")
 if (i$="A") or (i$="Q") return
 goto log

terminate
 print \"Terminate Connection"
 input @2 \"Are you sure (Y/[N]) ?" i$
 if left$(i$,1)<>"Y" return
term1
 link "a:main.seg","termin2"

welcome
 print \"Show current welcome to all users ([Y]/N) ?";
 input @2 i$:if left$(i$,1)="N" return
 wm=mn:mn=mn+1:print \"News updated":return

edit.file
 print \"Edit a File"
 input @2 \"File Name (to load):" i$
 edit(0):if i$<>"" copy i$,#8
 print \"Enter/Edit File Now: "edit(3)" cols, 4k max"
 print 'Type "DONE" when finished ".h" for help'
 edit(1):if not edit(2) return
 input @2 \"File Name (to save):" i$
 if i$="" return
 kill i$:create i$:open #1,i$
 copy #8,#1:close:return

dos.cmd
 input @2 \"DOS:" i$:if i$="" return
 use "b:xdos",i$:return

new.user
 input @0 \"Add a new user (Y/[N]) ?" i$
 if left$(i$,1)<>"Y" return
 move ram,58 to ram2
 a=nu+1:goto ed.pass1

set.date
 print \"Current date: "date$
 input @2 \"Today's Date: "i$:date$=i$
 print \"New date: "date$:return

; *** sub-routines ***

rd.user
 open #1,"b:users"
 position #1,128,a
 input #1,d1$,d2$\d3$\d4$,d5$
 position #1,128,a,70
 read #1,ram,58
 close #1
 return

wr.user
 open #1,"b:users":position #1,128,a
 if d1$="" then d1$="":d2$=""
 print #1,d1$","d2$\d3$\d4$","d5$
 position #1,128,a,70
 write #1,ram,58:close #1
 if d1$="" ready "g:mail":kill #msg(a):update
 return

show.file
 setint(1):print \s$\:copy f$:return

name.cov
 i$=d3$:a$="":for l=1 to len(i$)
 x=asc(mid$(i$,l,1)):if x>96 then x=x-32
 a$=a$+chr$(x):next:x=instr(" ",a$)
 if not(x) d2$=a$:d1$=".":return
 d1$=left$(a$,x-1):d2$=mid$(a$,x+1)
 return
