SET DEFINE OFF;
CREATE OR REPLACE FUNCTION format_subac(p_Sub_Account IN varchar2) RETURN  varchar2 IS
--
-- Purpose: Tao format cho tieu khoan
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- TUNH        10/04/2010   Created

    v_Result varchar2(30);

BEGIN
    if length(p_Sub_Account) >0 then
        v_Result := substr(p_Sub_Account,1,4) || '.' || substr(p_Sub_Account,5,6);
    end if;

    RETURN v_Result ;
EXCEPTION
   WHEN others THEN return p_Sub_Account ;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
