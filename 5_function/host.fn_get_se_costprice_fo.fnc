SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_costprice_fo(PV_SEACCTNO IN VARCHAR2, PV_TXDATE IN VARCHAR2)
    RETURN NUMBER IS
-- Purpose: Lay gia von chung khoan CK
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- THANHNM   31/01/2012     Created
    V_RESULT    NUMBER(20,2);
    V_INDATE    DATE;
    V_COSTDATE  DATE;
BEGIN

    V_INDATE := TO_DATE(PV_TXDATE,'DD/MM/YYYY');

    select max(txdate) into V_COSTDATE
    from secostprice where ACCTNO = REPLACE(PV_SEACCTNO,'.','')
    and txdate <= V_INDATE;

    V_COSTDATE := nvl(V_COSTDATE,V_INDATE);

    SELECT COSTPRICE INTO V_RESULT
    FROM secostprice
    WHERE ACCTNO = REPLACE(PV_SEACCTNO,'.','') and txdate = V_COSTDATE;
    V_RESULT := nvl(V_RESULT,0);

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
