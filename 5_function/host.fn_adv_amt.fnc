SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_adv_amt( PV_ACTYPE IN VARCHAR2)
    RETURN number IS
   v_amt number;
   v_rrtype VARCHAR2(10) ;
   v_custbank VARCHAR2(10) ;
BEGIN
   v_amt:=0;

SELECT rrtype,custbank INTO v_rrtype,v_custbank  FROM ADTYPE WHERE ACTYPE =PV_ACTYPE;

IF v_rrtype ='C' THEN

  select min(lmamtmax)- nvl(min(amt),0) into v_amt
            from cflimit,(SELECT SUM (AMT) amt FROM adschd where  rrtype ='C' AND STATUS ='N')ads,cfmast cf
            WHERE lmsubtype ='ADV'
            and cflimit.bankid = cf.custid
            AND cf.fullname='BMSCAD';
ELSE
           select min(lmamtmax)- nvl(min(amt),0) into v_amt
            from cflimit,(SELECT SUM (AMT) amt FROM adschd where  custbank =v_custbank AND STATUS ='N')ads
            WHERE lmsubtype ='ADV'
            AND BANKID =v_custbank ;

END IF;





RETURN v_amt;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
