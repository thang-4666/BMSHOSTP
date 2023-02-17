SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_CAL_PAID_INTFEE_DF(pv_lnacctno In VARCHAR2,pv_currval IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  NUMBER;
    v_overduedate DATE;
    v_currdate DATE;
BEGIN
    -- neu ngay hien tai da qua hoac bang ngay het han: gia tri phi trong han luon bang 0
        SELECT overduedate INTO v_overduedate FROM lnschd WHERE acctno=pv_lnacctno AND reftype='P';
        SELECT to_date(varvalue,'DD/MM/YYYY') INTO v_currdate FROM sysvar WHERE varname='CURRDATE';
        if(v_currdate >= v_overduedate ) THEN
        v_Result:= 0;
        ELSE
          v_Result:= to_number  (pv_currval);
          END IF;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
