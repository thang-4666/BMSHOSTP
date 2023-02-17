SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_2226_GET_PQTTY( pv_CAMASTID IN VARCHAR2,pv_TRADE IN NUMBER,pv_QTTY IN NUMBER,pv_REGISQTTY IN NUMBER)
    RETURN NUMBER IS
    v_Result  NUMBER;
    l_catype  VARCHAR2(10);
    l_exrate  VARCHAR2(50);
    l_dbl_left_exrate NUMBER;
    l_dbl_right_exrate NUMBER;
    l_interestrate NUMBER;
    l_camastid     VARCHAR2(50);
    l_trade        NUMBER;
    l_dbl_amtexp   NUMBER;
    l_exprice      NUMBER;
    l_parvalue     NUMBER;
    l_dbl_right_devidentshares NUMBER;
    l_dbl_left_devidentshares NUMBER;
    l_devidentshares          VARCHAR2(250);
    l_roundtype               NUMBER;
    l_typerate                varchar(2)   ;
    l_devidentrate            VARCHAR2(50);
    l_devidentvalue           VARCHAR2(50);
    l_ciroundtype             NUMBER;
    l_dbl_qttyexp             NUMBER;
    l_splitrate               VARCHAR2(50);
    l_dbl_aqttyexp            NUMBER;
    l_aqttyexp                NUMBER;
    l_dbl_right_rightoffrate  NUMBER;
    l_dbl_left_rightoffrate NUMBER;
    l_rightoffrate          VARCHAR2(250);
    l_dbl_aamtexp           NUMBER;
    l_dbl_RETAILBALEXP      NUMBER;
    l_dbl_pqtty        NUMBER;
    l_dbl_qtty              NUMBER;
BEGIN
    l_trade:=nvl(pv_TRADE,0);
    l_camastid:=REPLACE(pv_camastid,'.');
    l_dbl_qtty:=pv_QTTY;
    l_dbl_qttyexp:=0;
    l_dbl_aqttyexp:=0;
    l_dbl_pqtty:=0;
SELECT catype,nvl(exrate,'1/1'),nvl(interestrate,0),nvl(exprice,0),nvl(parvalue,0),
    nvl(devidentshares,'1/1'),nvl(roundtype,0),nvl(typerate,'A'),nvl(devidentrate,'0'),nvl(devidentvalue,'0'),
    nvl(ciroundtype,0),nvl(splitrate,'1/1'),nvl(rightoffrate,'1/1')
    INTO l_catype,l_exrate,l_interestrate,l_exprice,l_parvalue,l_devidentshares,l_roundtype,l_typerate,l_devidentrate,l_devidentvalue,
    l_ciroundtype,l_splitrate,l_rightoffrate
    FROM camast
    WHERE camastid=l_camastid;
    l_dbl_left_exrate := nvl(to_number(substr(l_exrate,0,instr(l_exrate,'/') - 1)),'1');
    l_dbl_right_exrate :=nvl(to_number( substr(l_exrate,instr(l_exrate,'/') + 1,length(l_exrate))),1);
    l_dbl_left_devidentshares:=nvl( to_number(substr(l_devidentshares,0,instr(l_devidentshares,'/') - 1)),1);
    l_dbl_right_devidentshares:=nvl(to_number( substr(l_devidentshares,instr(l_devidentshares,'/') + 1,length(l_devidentshares))),1);
    l_dbl_left_rightoffrate := nvl(to_number(substr(l_rightoffrate,0,instr(l_rightoffrate,'/') - 1)),1);
    l_dbl_right_rightoffrate := nvl(to_number(substr(l_rightoffrate,instr(l_rightoffrate,'/') + 1,length(l_rightoffrate))),1);

       if(l_catype='023') THEN
         l_dbl_qttyexp:=trunc (FLOOR( l_trade * l_dbl_right_exrate / l_dbl_left_exrate ),l_roundtype);
         l_dbl_pqtty:=l_dbl_qttyexp-l_dbl_qtty;
       ELSIF (l_catype='014') THEN
         l_dbl_qttyexp:=FLOOR((l_trade *l_dbl_right_rightoffrate * l_dbl_right_exrate )/( l_dbl_left_rightoffrate * l_dbl_left_exrate ));
         l_dbl_pqtty:=round(l_dbl_qttyexp-l_dbl_qtty);
       ELSE
         l_dbl_pqtty:=-l_dbl_qtty;
       END IF;

    v_Result:=nvl(l_dbl_pqtty,0);
    v_Result:=v_Result-pv_REGISQTTY;
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
