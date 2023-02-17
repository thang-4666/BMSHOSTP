SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getfeeclose0088(PV_AFACCTNO IN VARCHAR2,P_FEETYPE IN VARCHAR2, p_CLOSETYPE in varchar2 DEFAULT '000')
    RETURN NUMBER IS

    V_RESULT NUMBER;
    V_FEERATE NUMBER(20,4);
    V_FEEMAX number (20);
    V_FEEMIN number(20);
    V_FEETYPE varchar2(1);
BEGIN

/*if p_CLOSETYPE = '001' then
    SELECT case when SUM( NVL((SE.TRADE + SE.MORTAGE + SE.BLOCKED + SE.WITHDRAW
    + SE.DEPOSIT  + SE.SENDDEPOSIT),0))> 0 then 100000 else 0 end  INTO V_RESULT
    FROM SEMAST SE, sbsecurities sym, cfmast cf, afmast af
    WHERE se.codeid=sym.codeid and cf.custid = af.custid and se.afacctno = af.acctno
    AND sym.sectype <> '004'
    and cf.custid in (select custid from afmast where acctno=  PV_AFACCTNO)
    GROUP BY se.custid;

else
    V_RESULT:=0;
end if;*/


SELECT FEERATE/100, MAXVAL, minval, FORP INTO V_FEERATE, V_FEEMAX, V_FEEMIN, V_FEETYPE
FROM FEEMASTER WHERE FEECD = P_FEETYPE AND STATUS ='A';

if V_FEETYPE = 'F' then --loai phi co dinh
    select MAX(feeamt) into V_RESULT from feemaster where  FEECD = P_FEETYPE AND STATUS ='A';
else
    V_RESULT := 0 ;
end if ;


RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
