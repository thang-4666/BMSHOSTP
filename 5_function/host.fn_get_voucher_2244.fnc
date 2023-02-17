SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_Get_Voucher_2244(PV_TYPE IN VARCHAR2)
    RETURN String IS
-- PURPOSE: PHI CHUYEN KHOAN CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   20/03/2012     CREATED
    V_RESULT varchar2(100);
BEGIN
V_RESULT :=' ';

if replace(PV_TYPE,'''','')='001' then
    V_RESULT:='CA010ALK';
ELSE
    V_RESULT:='SE01CQSH';
end if;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;




-- End of DDL Script for Function HOSTBSCT3.FN_GETBANK_VOUCHER_1
 
 
 
 
 
 
 
 
/
