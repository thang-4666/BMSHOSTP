SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getTLFullName(PV_TLID IN VARCHAR2)
    RETURN String IS
-- PURPOSE: lay ten TLNAME de in chung tu
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- QUYETKD   05/07/2012     CREATED

V_RESULT varchar2(100);

BEGIN
V_RESULT :=' ';

Select tlfullname into V_RESULT From tlprofiles  where tlid =PV_TLID;
RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
   RETURN '';
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
