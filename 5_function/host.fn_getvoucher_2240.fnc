SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getvoucher_2240(PV_ISCONFIRM IN VARCHAR2)
    RETURN String IS
-- PURPOSE: PHI CHUYEN KHOAN CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   20/03/2012     CREATED
    V_RESULT varchar2(100);
BEGIN
    V_RESULT := ' ';

    if UPPER(PV_ISCONFIRM) = 'N' then
        V_RESULT := 'SE08ALK';
    else
        V_RESULT := 'SE08ALK/SE10LK';
    end if;

    RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 'SE08ALK/SE10LK';
END;

 
 
 
 
 
 
 
 
 
 
 
/
