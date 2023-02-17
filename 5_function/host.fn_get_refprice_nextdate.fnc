SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_refprice_nextdate ( pv_codeid IN VARCHAR2,pv_dbl_oldrefprice IN NUMBER,pv_days IN NUMBER)
RETURN NUMBER
  IS
    l_dbl_new_refprice NUMBER(20);
    l_dtNextDate DATE;
    l_strExrate VARCHAR2(50);
    l_strRIGHTOFFRATE VARCHAR2(50);
    l_left_rightoffrate varchar2(50);
    l_right_rightoffrate varchar2(50);
    l_left_exrate varchar2(50);
    l_right_exrate varchar2(50);
    l_camastid VARCHAR2(50);
    l_dblEXPRICE  NUMBER(20,4);
    l_dblI1 NUMBER(20,4);
    l_dblPr1 NUMBER(20,4);
    l_dblI2 NUMBER(20,4);
    l_dblPr2 NUMBER(20,4);
    l_dblI3 NUMBER(20,4);
    l_dblPr3 NUMBER(20,4);
    l_dblTTH_CP NUMBER(20,4);
    l_dblDiv_CP NUMBER(20,4);
    l_strTYPERATE VARCHAR2(1);
    l_dblDevidentValue NUMBER(20,4);
    l_dblParvalue NUMBER(20,4);
    l_dblTTH      NUMBER(20,4);
    l_days        NUMBER;
    l_ticksize    NUMBER;
    l_strExrate2  VARCHAR2(50);
    l_left_exrate2 varchar2(50);
    l_right_exrate2 varchar2(50);
    l_strExrate3  VARCHAR2(50);
    l_left_exrate3 varchar2(50);
    l_right_exrate3 varchar2(50);
    l_strExrate4  VARCHAR2(50);
    l_left_exrate4 varchar2(50);
    l_right_exrate4 varchar2(50);
    l_strI1         VARCHAR2(1000);
    l_strI2         VARCHAR2(1000);
    l_strTTH_CP     VARCHAR2(1000);
    l_strI3         VARCHAR2(1000);
    l_strTTH        VARCHAR2(1000);
    L_strI1Pr1      VARCHAR2(2000);
    l_strI2Pr2      VARCHAR2(2000);
    l_strI3Pr3      VARCHAR2(2000);
    l_strSQL        VARCHAR2(5000);

BEGIN
    SELECT to_date(varvalue,'DD/MM/RRRR')
    INTO l_dtNextDate
    FROM sysvar WHERE varname='NEXTDATE';
    l_days:=pv_days;


    -- xet xem co phieu co su kien quyen mua
            l_strExrate:='1/0';
            l_strRIGHTOFFRATE:='1/0';
            l_dblPr1:=0;
            l_strI1:='0';
            l_strI1Pr1:='0';
    FOR rec IN
               (SELECT  exrate,rightoffrate,EXPRICE

               FROM camast

               WHERE reportdate = fn_get_nextdate(l_dtNextDate,l_days)
               AND codeid=pv_codeid
               AND catype='014' AND deltd='N'
               AND status<>'P'
               )
     LOOP
          l_strExrate:=rec.exrate;
          l_strRIGHTOFFRATE:=rec.rightoffrate;
          l_dblPr1:=rec.EXPRICE;
          l_left_rightoffrate := substr(l_strRIGHTOFFRATE,0,instr(l_strRIGHTOFFRATE,'/') - 1);
          l_right_rightoffrate := substr(l_strRIGHTOFFRATE,instr(l_strRIGHTOFFRATE,'/') + 1,length(l_strRIGHTOFFRATE));
          l_left_exrate := substr(l_strExrate,0,instr(l_strExrate,'/') - 1);
          l_right_exrate := substr(l_strExrate,instr(l_strExrate,'/') + 1,length(l_strExrate));
          l_strI1:=l_strI1 ||' + (' || l_right_exrate || ' * '|| l_right_rightoffrate ||' / ( ' || l_left_exrate || ' * '|| l_left_rightoffrate || ' ) ) ';
          l_strI1Pr1:=l_strI1Pr1 ||' + (' || l_right_exrate || ' * '|| l_right_rightoffrate ||' / ( ' || l_left_exrate || ' * '|| l_left_rightoffrate || ' ) ) ' ||' * '||to_char(l_dblPr1) ;
          l_dblI1:=l_dblI1+(to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate));
     END LOOP;




    -- co phieu thuong
        l_strExrate2:='1/0';
        l_dblPr2:=0;
        l_strI2:='0';
        l_strTTH_CP:='0';
        l_strI2Pr2:='0';
        FOR rec IN (
                    SELECT  exrate,exprice
                    FROM camast
                    WHERE reportdate = fn_get_nextdate(l_dtNextDate,l_days)
                    AND codeid=pv_codeid
                    AND catype='021' AND deltd='N'
                    AND status<>'P'

                    )
        LOOP
          l_strExrate2:=rec.exrate;
          l_dblPr2:=rec.exprice;
          l_left_exrate2 := substr(l_strExrate2,0,instr(l_strExrate2,'/') - 1);
          l_right_exrate2 := substr(l_strExrate2,instr(l_strExrate2,'/') + 1,length(l_strExrate2));
          l_dblI2:=to_number(l_right_exrate2)/to_number(l_left_exrate2);
          l_dblTTH_CP:=ROUND(l_dblI2*l_dblPr2);

          l_strI2:=l_strI2||' + (' ||l_right_exrate2 ||' / '||l_left_exrate2 ||' ) ';
          l_strI2Pr2:=l_strI2Pr2 ||' + (' ||l_right_exrate2 ||' / '||l_left_exrate2 ||' ) ' ||' * '||to_char(l_dblPr2);

        END LOOP;


    -- chia co tuc bang co phieu
        l_strExrate3:='1/0';
        l_dblPr3:=0;
        l_dblI3:=0;
        l_strI3:='0';
        l_strI3Pr3:='0';
        FOR rec IN (
                   SELECT  DEVIDENTSHARES,exprice
                   FROM camast
                   WHERE reportdate = fn_get_nextdate(l_dtNextDate,l_days)
                   AND codeid=pv_codeid
                   AND catype='011' AND deltd='N'
                   AND status<>'P'
                   )
        LOOP
          l_strExrate3:=rec.DEVIDENTSHARES;
          l_dblPr3:=rec.exprice;
          l_left_exrate3 := substr(l_strExrate3,0,instr(l_strExrate3,'/') - 1);
          l_right_exrate3 := substr(l_strExrate3,instr(l_strExrate3,'/') + 1,length(l_strExrate3));
          l_dblI3:=to_number(l_right_exrate3)/to_number(l_left_exrate3);
          l_dblDiv_CP:=ROUND(l_dblI3*l_dblPr3);
          l_strI3:=l_strI3||' + ( '|| l_right_exrate3 ||' / '|| l_left_exrate3||' ) ';
          l_strI3Pr3:=l_strI3Pr3||' + ( '|| l_right_exrate3 ||' / '|| l_left_exrate3||' ) ' ||' * '||to_char(l_dblPr3);
        END LOOP;



    -- chia co tuc bang tien
        l_strExrate4:='0';
        l_dblDevidentValue:=0;
        l_strTYPERATE:='R';
        l_dblparvalue:=10000;
        l_strTTH:='0';
        SELECT parvalue INTO l_dblparvalue
        FROM sbsecurities WHERE codeid=pv_codeid;
        FOR rec IN (SELECT  devidentrate,devidentvalue,typerate,parvalue
                   FROM camast
                   WHERE reportdate =  fn_get_nextdate(l_dtNextDate,l_days)
                   AND codeid=pv_codeid
                   AND catype='010' AND deltd='N'
                   AND status<>'P')
        LOOP
                l_strExrate4:=rec.devidentrate;
                l_dblDevidentValue:=rec.devidentvalue;
                l_strTYPERATE:=rec.typerate;
                IF(l_strTYPERATE='R') THEN
                  l_dblTTH:=to_number(l_strExrate4)*l_dblparvalue/100;
                  l_strTTH:=l_strTTH||' + ( '||l_strExrate4||' * '|| to_char(l_dblparvalue) ||' /100 ) ';
                ELSE
                  l_dblTTH:=l_dblDevidentValue;
                  l_strTTH:=l_strTTH||' + ( '||to_char(l_dblDevidentValue)||'  ) ';
                END IF;
        END LOOP;

                -- tinh lai gia tham chieu
     /*   l_dbl_new_refprice:=(pv_dbl_oldrefprice+l_dblI1*l_dblPr1+l_dblI2*l_dblPr2+l_dblI3*l_dblPr3-l_dblTTH_CP-l_dblDiv_CP-l_dblTTH)/
                             (1+l_dblI1+l_dblI2+l_dblI3);*/
/*                             l_dbl_new_refprice:= ( pv_dbl_oldrefprice+ (l_strI1Pr1)-(l_strTTH))/(1+(l_strI1)+(l_strI2)+(l_strI3));*/
               l_strSQL:=     'SELECT ( ' || to_char( pv_dbl_oldrefprice) || '+' || l_strI1Pr1|| ' - (' ||l_strTTH|| ') )/(1+ '
                              || l_strI1 ||' + '|| l_strI2 || '+' ||l_strI3 || ' )
                               FROM dual' ;
               EXECUTE IMMEDIATE l_strSQL  INTO l_dbl_new_refprice;
        /* if(l_strTYPERATE='R') THEN
             l_dbl_new_refprice:=((pv_dbl_oldrefprice+
                             ((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))*l_dblPr1
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3
                             -((to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2)
                             -((to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3)-(to_number(l_strExrate4)*l_dblparvalue/100))/
                             (1+((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))));
         ELSE
                l_dbl_new_refprice:=((pv_dbl_oldrefprice+
                             ((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))*l_dblPr1
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3
                             -((to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2)
                             -((to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3)-l_dblDevidentValue)/
                             (1+((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))));
         END IF;*/

      -- lam tron theo ticksize

       BEGIN
           SELECT ticksize INTO l_ticksize
           FROM securities_ticksize
           WHERE fromprice <=l_dbl_new_refprice
           AND toprice>=l_dbl_new_refprice
           AND status='Y'
           AND codeid=pv_codeid;
       EXCEPTION WHEN OTHERS THEN
            l_ticksize:=1;

        END;

         -- tinh lai gia tham chieu
     /*   l_dbl_new_refprice:=(pv_dbl_oldrefprice+l_dblI1*l_dblPr1+l_dblI2*l_dblPr2+l_dblI3*l_dblPr3-l_dblTTH_CP-l_dblDiv_CP-l_dblTTH)/
                             (1+l_dblI1+l_dblI2+l_dblI3);*/

          l_strSQL:=     'SELECT round ((( ' || to_char( pv_dbl_oldrefprice) || ' + ' || l_strI1Pr1|| ' - (' ||l_strTTH|| ' ) )/(1+ '
                              || l_strI1 ||' + '|| l_strI2 || ' + ' ||l_strI3 || ' ))/ '|| to_char( l_ticksize) || ') *' || to_char( l_ticksize)
                              ||' FROM dual' ;
               EXECUTE IMMEDIATE l_strSQL  INTO l_dbl_new_refprice;

       /*  if(l_strTYPERATE='R') THEN
             l_dbl_new_refprice:=ROUND(((pv_dbl_oldrefprice+
                             ((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))*l_dblPr1
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3
                             -((to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2)
                             -((to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3)-(to_number(l_strExrate4)*l_dblparvalue/100))/
                             (1+((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))))/l_ticksize)*l_ticksize;
         ELSE
                l_dbl_new_refprice:=ROUND(((pv_dbl_oldrefprice+
                             ((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))*l_dblPr1
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3
                             -((to_number(l_right_exrate2)/to_number(l_left_exrate2))*l_dblPr2)
                             -((to_number(l_right_exrate3)/to_number(l_left_exrate3))*l_dblPr3)-l_dblDevidentValue)/
                             (1+((to_number(l_right_exrate)*l_right_rightoffrate)/(to_number(l_left_exrate)*to_number(l_left_rightoffrate)))
                             +(to_number(l_right_exrate2)/to_number(l_left_exrate2))
                             +(to_number(l_right_exrate3)/to_number(l_left_exrate3))))/l_ticksize)*l_ticksize;
         END IF;*/

--RETURN l_dbl_new_refprice;

  if   l_dbl_new_refprice <> pv_dbl_oldrefprice then
    insert into REFPRICE_LOG(txdate,codeid, old_refprice, new_refprice, last_change)
    values (SYSDATE,pv_codeid,pv_dbl_oldrefprice,l_dbl_new_refprice,systimestamp);
  end if;

  RETURN pv_dbl_oldrefprice;
EXCEPTION WHEN others THEN
    plog.error(dbms_utility.format_error_backtrace);
    return  pv_dbl_oldrefprice;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
