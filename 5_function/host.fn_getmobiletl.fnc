SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getmobiletl(PV_TLID IN VARCHAR2)
    RETURN String IS
-- PURPOSE: lay ten So DT cua user de in chung tu
-- USE in : GD 2240
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- QUYETKD   05/07/2012     CREATED

V_RESULT varchar2(100);

BEGIN
V_RESULT :=' ';

Select tlprn into V_RESULT From tlprofiles  where tlid =PV_TLID;
RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
   RETURN '';
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
