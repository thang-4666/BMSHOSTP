SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_GetBank_Voucher_1(PV_BANKID IN VARCHAR2)
    RETURN String IS
-- PURPOSE: PHI CHUYEN KHOAN CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   20/03/2012     CREATED
    V_RESULT varchar2(100);
BEGIN
V_RESULT :=' ';

if LENGTH(PV_BANKID)>0 then
V_RESULT:='RM1131';
end if;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;

 
 
 
 
 
 
 
 
 
 
 
/
