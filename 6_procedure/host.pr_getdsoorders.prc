SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE PR_GetDSOOrders
   (
     PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR,
     pv_GROUPID    IN number,
     pv_BORS  in varchar2,
     pv_SYMBOL in varchar2,
     pv_PRICE in number,
     pv_PRICETYPE varchar2,
     pv_DSOtype varchar2, --  ALL     100%
                          --- WEIGHT   x%
                          --- TOTAL
     pv_DSOvalue number DEFAULT 100,
     pv_via varchar2 default 'O'
   )
   IS
   v_txDate DATE;
   v_tradelot number;
   v_price number;
   v_totaltrade number;
   v_rate number;
BEGIN -- Proc
    Select to_date(varvalue,'dd/MM/yyyy') into v_txDate from sysvar where upper(varname) = 'CURRDATE' AND GRNAME='SYSTEM';
    Select s.tradelot,
        Case  pv_pricetype
            when 'LO'  then pv_PRICE*1000
            else  decode(pv_BORS,'B',s.ceilingprice,s.closeprice)
        End Price
    Into  v_tradelot,v_price
    From securities_info s
    Where s.symbol=pv_symbol;

    If pv_BORS = 'NS' then
        v_rate:=1;
        If pv_DSOtype ='ALL' then
            v_rate:=1;--100%
        ELSIF pv_DSOtype ='WEIGHT' THEN
            v_rate:= least(1,pv_DSOvalue/100);
        ELSIF pv_DSOtype ='TOTAL'   THEN
           v_totaltrade:=0;
           Select sum(se.trade) into v_totaltrade
            From dsogrp g, afdsogrp afd ,   buf_se_account se
            Where g.autoid=afd.refautoid
                and g.autoid=pv_GROUPID
                and afd.afacctno=se.afacctno
                and se.symbol=pv_symbol;
            v_rate:= least(1,pv_DSOvalue/v_totaltrade);
        End if;

        OPEN PV_REFCURSOR FOR
        Select cf.custodycd,af.acctno,cf.fullname, pv_SYMBOL Symbol,
            floor(se.trade*v_rate / v_tradelot) * v_tradelot quantity
        From dsogrp g, afdsogrp afd , afmast af, cfmast cf, buf_se_account se
        Where g.autoid=afd.refautoid
            and afd.afacctno=af.acctno
            and af.custid=cf.custid
            and g.autoid=pv_GROUPID
            and af.acctno=se.afacctno
            and se.symbol=pv_symbol
            and floor(se.trade*v_rate / v_tradelot) * v_tradelot>0;

    Else -- Buy
        v_rate:=1;
        If pv_DSOtype ='ALL' then
            v_rate:=1;--100%
        ELSIF pv_DSOtype ='WEIGHT' THEN
            v_rate:= least(1,pv_DSOvalue/100);
        ELSIF pv_DSOtype ='TOTAL'   THEN
           v_totaltrade:=0;
           Select sum(fn_getmaxbuyqtty(afd.afacctno,pv_SYMBOL,v_price,pv_via)) into v_totaltrade
            From dsogrp g, afdsogrp afd
            Where g.autoid=afd.refautoid
                and g.autoid=pv_GROUPID;
            v_rate:= least(1,pv_DSOvalue/v_totaltrade);
        End if;
        OPEN PV_REFCURSOR FOR
        Select cf.custodycd,af.acctno,cf.fullname, pv_SYMBOL Symbol,
            floor(fn_getmaxbuyqtty(afd.afacctno,pv_SYMBOL,v_price,pv_via)*v_rate / v_tradelot) * v_tradelot quantity
        From dsogrp g, afdsogrp afd , afmast af, cfmast cf
        Where g.autoid=afd.refautoid
            and afd.afacctno=af.acctno
            and af.custid=cf.custid
            and g.autoid=pv_GROUPID
            and floor(fn_getmaxbuyqtty(afd.afacctno,pv_SYMBOL,v_price,pv_via)*v_rate / v_tradelot) * v_tradelot>0;

    End if;

EXCEPTION
    WHEN others THEN
        return;
END;
 
 
 
 
/
