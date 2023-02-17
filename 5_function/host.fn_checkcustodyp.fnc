SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkcustodyp(v_custodycd IN varchar2) RETURN  varchar2 IS
--
-- Purpose: Tao format so TK luu ky
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- TUNH        10/04/2010   Created

    v_result        NUMBER;
    v_strCusType    varchar2(1);
    v_count         NUMBER;

BEGIN
    --Lay noi luu ky
    if(substr(v_custodycd,1,4) = systemnums.C_DEALINGCD) then
        return 0;
    else
        return -1;
    end if;
    RETURN -1;
EXCEPTION
   WHEN others THEN
   return -1;
END;
 
 
 
 
/
