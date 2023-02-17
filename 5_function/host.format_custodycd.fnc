SET DEFINE OFF;
CREATE OR REPLACE FUNCTION format_custodycd(p_str IN varchar2) RETURN  varchar2 IS
--
-- Purpose: Tao format so TK luu ky
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- TUNH        10/04/2010   Created

    v_Result varchar2(30);

BEGIN
    if length(p_str) >0 then
        v_Result := substr(p_str,1,4) || '.' || substr(p_str,5,6);
        v_Result := upper(v_Result);
    end if;

    RETURN v_Result ;
EXCEPTION
   WHEN others THEN return p_str ;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
