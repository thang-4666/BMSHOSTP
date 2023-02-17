SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdealsellqtty(pv_dfacctno IN varchar2)
RETURN NUMBER
IS
l_securedratiomin number(20,4);
l_securedratiomax number(20,4);
l_afacctno varchar2(30);
l_codeid varchar2(20);
l_symbol varchar2(20);
l_floorprice number(20,2);
l_refprice number(20,2);
l_tradeunit number(20);
l_unpaidamt number(20,4);
l_aintrate number(20,4);
l_advfeerate number(20,4);
l_matchamt number(20,0);
l_unmatchamt number(20,0);
l_tradelot number(20,0);
l_avldealqtty number(20,0);
l_avltradeqtty number(20,0);
l_busdate DATE;
l_dfqtty number(20,0);
l_orderqtty number(20,0);
l_tradeqtty number(20,0);
l_dealorderqtty number(20,0);
l_deffeerate number(20,4);
l_vatrate number(20,4);
l_qtty number(20);
BEGIN
    SELECT to_date(varvalue, 'DD/MM/RRRR') INTO l_busdate FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
    -- get l_afacctno l_codeid
    SELECT afacctno, codeid INTO l_afacctno, l_codeid FROM dfmast WHERE acctno = pv_dfacctno;
    -- get l_symbol
    SELECT symbol, floorprice, tradeunit, securedratiomin , securedratiomax, tradelot
        INTO l_symbol,l_floorprice,l_tradeunit,l_securedratiomin , l_securedratiomax, l_tradelot
    FROM securities_info WHERE codeid = l_codeid;
    l_refprice:=l_floorprice;
    -- lay fee
    FOR i IN
    (SELECT odt.deffeerate FROM odtype odt
    WHERE odt.status = 'Y'
    AND EXISTS (SELECT 1 FROM afmast af, aftype aft, afidtype afid
                WHERE af.actype = aft.actype
                AND aft.actype = afid.aftype
                AND odt.actype = afid.actype
                AND afid.objname = 'OD.ODTYPE'
                AND af.acctno = l_afacctno))
    LOOP
        l_deffeerate:= GREATEST( i.deffeerate,nvl(l_deffeerate,0));
    END LOOP;
    -- lay thue
	begin
    SELECT max(decode(cf.vat , 'Y',iccf.icrate,0))
        INTO  l_vatrate
    FROM aftype aft, (SELECT * FROM iccftypedef WHERE modcode = 'CF' AND eventcode = 'CFSELLVAT') iccf , afmast af, cfmast cf
    WHERE iccf.actype(+) = aft.actype AND af.actype = aft.actype and af.custid = cf.custid
    AND af.acctno = l_afacctno;
	EXCEPTION
    WHEN others THEN
        l_vatrate:=0;
	end;


---------------lay no chua tra.
	begin
    SELECT nvl(round(ln.INTNMLACR,0)+round(ln.INTOVDACR,0)+
            round(ln.INTNMLOVD,0)+round(ln.INTDUE,0) + round(ln.PRINNML,0)+
            round(ln.PRINOVD,0),0)
            INTO l_unpaidamt
    FROM dfmast df, lnmast ln
    WHERE df.lnacctno = ln.acctno AND df.acctno = pv_dfacctno;
	EXCEPTION
    WHEN others THEN
        l_unpaidamt:=0;
	end;

--------------lay phi ung truoc tien ban.
    SELECT to_number(varvalue)
        INTO l_aintrate
    FROM sysvar WHERE varname = 'AINTRATE';
    l_advfeerate:= l_aintrate / 360;

--------------lay gia tri khop ban.
--------------lay gia tri dat ban.
    BEGIN
        SELECT nvl(sum(matchamt),0), nvl(SUM (remainqtty * quoteprice),0)
            INTO l_matchamt, l_unmatchamt
        FROM odmast
        WHERE exectype = 'MS' AND dfacctno = pv_dfacctno
        AND txdate(+) = l_busdate
        group BY dfacctno;
    EXCEPTION
    WHEN others THEN
        l_matchamt:=0;
        l_unmatchamt:=0;
    END;

--------------lay so luong deal co the ban.
	begin
    SELECT nvl(max(df.dfqtty),0) dfqtty, nvl(sum(remainqtty + execqtty),0) dealorderqtty
        INTO l_dfqtty, l_dealorderqtty
    FROM dfmast df, odmast od
    where od.txdate(+) = l_busdate
    AND df.acctno = od.dfacctno(+)
    AND df.acctno = pv_dfacctno
    group BY df.acctno;
	EXCEPTION
    WHEN others THEN
        l_dfqtty:=0;
        l_dealorderqtty:=0;
	end;
-------------lay so luong ck co the ban tren tai khoan.
    begin
    SELECT nvl(trade+df.sumdfqtty,0)
        INTO l_tradeqtty
    FROM semast se, (SELECT afacctno, codeid,sum(dfqtty) sumdfqtty FROM dfmast GROUP BY afacctno, codeid) df
    WHERE se.afacctno = l_afacctno AND se.codeid = l_codeid AND df.afacctno = se.afacctno AND se.codeid = df.codeid;
    EXCEPTION
    WHEN others THEN
        l_tradeqtty:=0;
    end;
	begin
    SELECT nvl(sum(remainqtty),0)
        INTO l_orderqtty
    FROM odmast od
    WHERE od.txdate(+) = l_busdate AND od.exectype IN ('NS','NB','MS')
    AND od.afacctno = l_afacctno AND od.codeid = l_codeid
    GROUP BY od.afacctno, od.codeid;
    EXCEPTION
    WHEN others THEN
        l_orderqtty:=0;
    end;
--------------Tinh so luong ban theo cong thuc--------------------------
/*
X= (No chua tra)/(1 - %phi GD - %thue)*(1 - %phi UTTB*3)*Gia san - (GT khop ban + GT dat ban )/Gia san

So luong can dat ban = min ( X lam tron len theo lo chan, so luong con duoc dat ban cua deal  lam tron xuong theo lo chan,
    so luong con co the dat ban cua ma can tinh  lam tron xuong theo lo chan)
*/
/*
dbms_output.put_line('l_unpaidamt:'||l_unpaidamt);
dbms_output.put_line('l_deffeerate:'||l_deffeerate);
dbms_output.put_line('l_vatrate:'||l_vatrate);
dbms_output.put_line('l_advfeerate:'||l_advfeerate);
dbms_output.put_line('l_refprice:'||l_refprice);
dbms_output.put_line('l_unmatchamt:'||l_unmatchamt);
dbms_output.put_line('l_tradelot:'||l_tradelot);
dbms_output.put_line('l_dfqtty:'||l_dfqtty);
dbms_output.put_line('l_dealorderqtty:'||l_dealorderqtty);
dbms_output.put_line('l_tradeqtty:'||l_tradeqtty);
dbms_output.put_line('l_orderqtty:'||l_orderqtty);
*/
    l_qtty:= least(
        ceil((nvl(l_unpaidamt,0) / ((1-nvl(l_deffeerate,0)/100-nvl(l_vatrate,0)/100)*(1-nvl(l_advfeerate,0)/100*3)*l_refprice)
          - (nvl(l_matchamt,0) + nvl(l_unmatchamt,0))/l_refprice)/l_tradelot) * l_tradelot,

                (floor((nvl(l_dfqtty,0) - nvl(l_dealorderqtty,0)) /l_tradelot)) * l_tradelot,

                (floor((nvl(l_tradeqtty,0) - nvl(l_orderqtty,0)) /l_tradelot)) * l_tradelot
                );

    RETURN l_qtty;

EXCEPTION WHEN OTHERS THEN
RETURN 0;

END;
 
 
 
 
 
 
 
 
 
 
 
/
