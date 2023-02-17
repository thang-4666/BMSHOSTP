SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getcust_voucher(PV_CUSTODYCD IN VARCHAR2)
    RETURN String IS
-- PURPOSE: LAY VOUCHER TO CHUC HOAC CA NHAN GUI LUU KY CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- QUYETKD   05/07/2012     CREATED

    V_RESULT varchar2(100);
BEGIN
V_RESULT :='';

if UPPER(PV_CUSTODYCD) = 'Y' then
    V_RESULT:='SE08ALK/SE10LK';
else
    V_RESULT:='SE08ALK';
end if;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;
 
 
 
 
 
 
 
 
 
 
 
/
