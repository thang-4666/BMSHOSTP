SET DEFINE OFF;
CREATE OR REPLACE FUNCTION dtoc( pv_Date IN Date) RETURN  varchar2 IS

-- Purpose: Chuyen bien kieu Date sang bien kieu character
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    ------         -------------------------------------------
-- TUNH         02/05/2008      Created

   v_format  varchar2(10);

BEGIN
    v_format := 'DD/MM/RRRR';
    RETURN to_char(pv_Date,v_format);

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;

END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
