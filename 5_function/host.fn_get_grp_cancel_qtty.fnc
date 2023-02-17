SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_grp_cancel_qtty (PV_ORDERID VARCHAR2)
RETURN NUMBER
IS
V_RESULT NUMBER(20,0);
BEGIN
    select NVL( sum(cancelqtty),0) INTO V_RESULT
        from VW_ODMAST_ALL where
        --deltd <> 'Y'           AND
        voucher=PV_ORDERID;
    RETURN V_RESULT;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
