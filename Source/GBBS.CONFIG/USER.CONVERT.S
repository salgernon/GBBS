; *******************
; GBBS "Pro" V:2.2n
; Copyright 1980-1990
;  Kevin M. Smallwood
; *******************
; 12/23/86  By Lance
; 04/11/90  Updated to 2.1 - LPT
; 02/19/2017 Updated to 2.2n
; Get data from the Data file for number of users to convert

user.conv
 print '
This program will convert your 1.2 user
file to run under the 2.2 format.  It
will not harm your existing user file.':print
 print \"Do you wish to continue (YES/[NO]) ? NO";
 print chr$(8,2):input i$
 if i$<>"YES" end

rd.data
 open #1,"b:data"
 input #1,c1,c2,ct,ct$,da$
 input #1,nu,mn,wm,tm\lu$:close
 print "System has "nu" users"\

; Start the actual conversion
; create the temp user file

 create "b:users.temp"
 open #1,"b:users"
 open #2,"b:users.temp"
 print "Converting User #";
 for x=1 to nu:print x;

; set the ram for the old file

 set pa$=ram,8:set ph$=ram+8,12
 when$=ram+20:flag=ram+22
 nibble=ram+27:byte=ram+29
 gosub rd.old.user
 d$=d1$+" "+d2$:gosub cn.name:d3$=xx$

; Save the stats for conversion to the new format

 tl=nibble(1):ct=nibble(2):up=nibble(3)
 tc=byte(0):bp=byte(1):dl=byte(2)
 lm=byte(3):hm=byte(4):wh$=when$:z=flag

; Set up the new 128 byte ram area

 set pa$=ram,8:set ph$=ram+8,12
 when$=ram+20:flag=ram+22
 nibble=ram+27:byte=ram+37

; Give all users zero nulls & convert the number of uploads

 for l=1 to 4:nibble(l)=0:next
 nibble(5)=tl:nibble(6)=ct:byte(1)=tc
 byte(2)=bp:byte(3)=dl:byte(4)=ul
 byte(5)=lm:byte(6)=hm:byte(0)=0
 when$=wh$:flag=z:d4$="":d5$=""
 gosub wr.new.user

 print chr$(8,(len(str$(x))));
 next:close

; Rename the files so that 2.2 will run. (saving 1.2's file)

 use "b:xdos","r b:users,b:users.1.2"
 use "b:xdos","r b:users.temp,b:users"
 print "System is now ready for 2.1":end

rd.old.user
 position #1,64,x
 input #1,d1$,d2$\d3$
 position #1,64,x,30
 read #1,ram,34:return

wr.new.user
 position #2,128,x
 print #2,d1$,d2$\d3$\d4$,d5$
 position #2,128,x,70
 write #2,ram,58:return

cn.name
 xx$="":for y=2 to len(d$)
 q$=mid$(d$,y,1):if q$=" " q$=mid$(d$,y,2):y=y+1:goto cn.name2
 if q$="." q$=mid$(d$,y,2):y=y+1:goto cn.name2
 if q$="-" q$=mid$(d$,y,2):y=y+1:goto cn.name2
 if q$="_" q$=mid$(d$,y,2):y=y+1:goto cn.name2
 if q$=" " q$=mid$(d$,y,2):y=y+1:goto cn.name2
 a=asc(q$):if (a<65) or (a>91) and (a<97) y=y+1:goto cn.name2
 a=a+32:q$=chr$(a)
cn.name2
 xx$=xx$+q$:next:xx$=left$(d$,1)+xx$:return
