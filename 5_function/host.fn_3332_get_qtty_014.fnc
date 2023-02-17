SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_3332_GET_QTTY_014( pv_CAMASTID IN VARCHAR2,pv_AFACCTNO IN VARCHAR2,pv_TRADE IN NUMBER,pv_Pqtty in number,pv_autoid number)
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
    l_dbl_balanceExp        number;
BEGIN
    l_trade:=nvl(pv_TRADE,0);
    l_camastid:=REPLACE(pv_camastid,'.');
    l_dbl_qttyexp:=0;

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
   /*
    select nvl(max(round(least(qtty, greatest(nvl(pv_TRADE,0)/trade * (pqtty+qtty) - pqtty,0)) ,0)),0) into l_dbl_qttyexp
        from caschd
    where afacctno = replace(pv_AFACCTNO,'.','') and camastid = replace(pv_CAMASTID,'.','') and deltd <> 'Y';*/
   -- so quyen da dk mua tuong ung voi so luong chuyen
    select nvl(max(round(least(qtty, greatest(nvl(pv_TRADE,0)/trade * (pqtty+qtty) - pv_Pqtty,0)) ,0)),0) into l_dbl_qttyexp
        from caschd
     where autoid=pv_autoid ;
    -- tinh ra so luong CK cho ve tuong ung
    --l_dbl_qttyexp:=round(l_dbl_balanceExp*l_dbl_right_rightoffrate/l_dbl_left_rightoffrate);

    select nvl(max(case when pv_trade = trade then qtty else nvl(l_dbl_qttyexp,0) end),0) into l_dbl_qttyexp
        from caschd
     where autoid=pv_autoid ;
    --
    v_Result:=nvl(l_dbl_qttyexp,0);
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
