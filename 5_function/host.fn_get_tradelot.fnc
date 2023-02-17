SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_TRADELOT ( pv_tradeplace IN VARCHAR2)
RETURN NUMBER IS
    l_tradelot NUMBER;
    l_tradeplace VARCHAR2(50);
    v_Result  VARCHAR2(1000);
BEGIN
    IF pv_tradeplace = '001' THEN 
        l_tradeplace:='HOSETRADELOT';
    ELSIF pv_tradeplace = '002' THEN
        l_tradeplace:='HNXTRADELOT';    
    ELSE
        l_tradeplace:='UPCOMTRADELOT';    
    END IF;        
    select varvalue into l_tradelot
    from sysvar where varname = l_tradeplace;
RETURN l_tradelot;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '100';
END;
 
/
