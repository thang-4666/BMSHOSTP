SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkcatype(v_CATYPE IN varchar2, V_ACTIONDATE IN VARCHAR2,V_CAMASTID IN VARCHAR2) RETURN  varchar2 IS
--
-- Purpose: Tao format so TK luu ky
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- TUNH        10/04/2010   Created

    v_result        NUMBER;

BEGIN
    --Lay noi luu ky
    if(v_CATYPE = '015' or v_CATYPE = '010' ) then
        if to_DATE(V_ACTIONDATE,'DD/MM/RRRR') < GETCURRDATE then
            return -1;
        else
            return 0;
        end if;
    end if;
    RETURN 0;
EXCEPTION
   WHEN others THEN
   return 0;
END;

 
 
 
 
/
