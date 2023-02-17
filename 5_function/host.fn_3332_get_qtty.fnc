SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_3332_get_qtty( pv_CAMASTID IN VARCHAR2,pv_AFACCTNO IN VARCHAR2,pv_TRADE IN NUMBER,pv_autoid number)
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

        IF l_catype = '009' THEN --gc_CA_CATYPE_KIND_DIVIDEND  'Kind dividend
          l_dbl_qttyexp := round(l_trade * l_dbl_right_devidentshares / l_dbl_left_devidentshares,0 );
          l_dbl_amtexp := trunc(l_exprice * MOD(l_trade *l_dbl_right_devidentshares  , l_dbl_left_devidentshares )/ l_dbl_left_devidentshares);
        ELSIF l_catype = '010' THEN --gc_CA_CATYPE_CASH_DIVIDEND 'Cash dividend(+QTTY,AMT)
            if(l_TYPERATE= 'R') THEN
          l_dbl_amtexp :=trunc( l_trade * l_parvalue /100* to_number(l_devidentrate),0);
          ELSE
            l_dbl_amtexp := trunc( l_trade*to_number(l_devidentvalue),0);
            END IF;
          l_roundtype :=0;
        ELSIF l_catype = '024' THEN --gc_CA_CATYPE_PAYING_INTERREST_BOND
          l_dbl_amtexp := trunc(l_trade * l_parvalue /100 *  to_number(l_devidentrate),0);
          l_roundtype := 0;
        ELSIF l_catype = '011' THEN --gc_CA_CATYPE_STOCK_DIVIDEND 'Stock dividend (+QTTY,AMT)
        -- plog.debug (pkgctx,'in case 011.2.1: '||  rec_trade.custid );

          l_dbl_qttyexp:=trunc (FLOOR( l_trade * l_dbl_right_devidentshares / l_dbl_left_devidentshares ),l_roundtype);
          l_dbl_amtexp:= trunc( l_exprice * trunc(l_trade * l_dbl_right_devidentshares / l_dbl_left_devidentshares -l_dbl_qttyexp,l_ciroundtype),0);

           ELSIF l_catype = '025' THEN --gc_CA_CATYPE_PRINCIPLE_BOND
          l_dbl_amtexp:= round (l_trade*l_exprice,0);
          l_dbl_aamtexp:= l_trade;
        ELSIF l_catype = '021' THEN --gc_CA_CATYPE_KIND_STOCK
          l_dbl_qttyexp:=trunc (FLOOR( l_trade * l_dbl_right_exrate / l_dbl_left_exrate ),l_roundtype);

          l_dbl_amtexp:= trunc (l_exprice * trunc(l_trade * l_dbl_right_exrate / l_dbl_left_exrate -l_dbl_qttyexp,l_ciroundtype),0);

        ELSIF l_catype = '020' THEN --gc_CA_CATYPE_CONVERT_STOCK
         l_dbl_aqttyexp:= l_trade;

        l_dbl_qttyexp:=trunc (FLOOR( l_trade * l_dbl_right_devidentshares / l_dbl_left_devidentshares ),l_roundtype);
          l_dbl_amtexp:= trunc( l_exprice * trunc(l_trade * l_dbl_right_devidentshares / l_dbl_left_devidentshares -l_dbl_qttyexp,l_ciroundtype),0);

        ELSIF l_catype = '012' THEN --gc_CA_CATYPE_STOCK_SPLIT 'Stock Split(+ QTTY,AMT)
          l_dbl_qttyexp:= TRUNC( l_trade/  to_number(l_splitrate)  - l_trade, l_roundtype );
          l_dbl_amtexp:= trunc(l_exprice*( l_trade / to_number( l_splitrate) - l_trade -  l_dbl_qttyexp ),0);
        ELSIF l_catype = '013' THEN --gc_CA_CATYPE_STOCK_MERGE 'Stock Merge(-AQTTY,+AMT)
          l_dbl_aqttyexp:= l_trade - TRUNC( l_trade/ to_number(l_splitrate) ,  l_roundtype) ;

         -- PhuongHT edit
          l_dbl_amtexp:= trunc(l_exprice *( l_aqttyexp  - (l_trade - l_trade / to_number( l_splitrate ))));

         -- end of PhuongHT edit

        ELSIF l_catype = '015' THEN --gc_CA_CATYPE_BOND_PAY_INTEREST 'Bond pay interest, Lai suat theo thang, chu ky theo nam (+AMT)
          l_dbl_amtexp:=round(l_trade * l_parvalue /100 * to_number(l_interestrate),0) ;
          l_roundtype := 0;
        ELSIF l_catype = '016' THEN -- gc_CA_CATYPE_BOND_PAY_INTEREST_PRINCIPAL 'Bond pay interest || prin, Lai suat theo thang, chu ky theo nam (+AMT)

          l_dbl_amtexp:=round ( l_trade *l_parvalue * (1+  to_number(l_interestrate)  /100 ),0) ;
           -- PhuongHT: ghi nhan rieng phan lai
           -- l_dbl_intamtexp:= round(l_trade * l_parvalue /100 *  to_number(l_interestrate),0) ;

          l_roundtype:= 0 ;

        ELSIF l_catype = '018' THEN -- gc_CA_CATYPE_CONVERT_RIGHT_TO_SHARE 'Convert Right to share (+QTTY Share, -AQTTY Right)
          l_dbl_qttyexp:= l_trade;
          l_dbl_aqttyexp:= l_trade;
          l_roundtype:= 0 ;
        ELSIF l_catype = '019' THEN -- gc_CA_CATYPE_CHANGE_TRADING_PLACE_STOCK 'Change trading place (+QTTY )
          l_dbl_qttyexp:= 0;
          l_dbl_amtexp:=0;
        --ELSIF  l_catype IN ( '005' , '006','022') THEN
            -- l_dbl_rqttyexp:= FLOOR((l_trade* l_dbl_right_devidentshares )/ l_dbl_left_devidentshares );
          ELSIF l_catype = '017' THEN -- gc_CA_CATYPE_CONVERT_BOND_TO_SHARE 'Convert bond to share (+QTTY Share,-AQTTY Bound)
          l_dbl_qttyexp:=trunc (FLOOR( l_trade * l_dbl_right_exrate / l_dbl_left_exrate ),l_roundtype);

        END IF;

    if l_catype in ('014') then
        select nvl(max(round(least(qtty, greatest(nvl(pv_TRADE,0)/trade * (pqtty+qtty) - pqtty,0)) ,0)),0) into l_dbl_qttyexp
        from caschd
        where autoid=pv_autoid ;
    end if;

    select nvl(max(case when pv_trade = trade then qtty else nvl(l_dbl_qttyexp,0) end),0) into l_dbl_qttyexp
        from caschd
     where autoid=pv_autoid ;

    v_Result:=nvl(l_dbl_qttyexp,0);
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
