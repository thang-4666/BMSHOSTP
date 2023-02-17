SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_buyingpower(pv_afacctno In VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(20);

BEGIN
    select MAX(buyingpower)  into v_Result
    from TDTYPE
    where actype = pv_afacctno;
    v_Result := NVL(v_Result,'N');
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;

 
 
 
 
 
/
