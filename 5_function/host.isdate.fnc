SET DEFINE OFF;
CREATE OR REPLACE FUNCTION isdate(p_str IN VARCHAR2)
  RETURN  VARCHAR2 IS
-- ThangNV: Function to check a field is date or not
-- 30/09/2013
-- Cap nhat lai 24/10/2013: Chuyen lai dinh dang 'DD/MM/RRRR'
-- ---------   ------  -------------------------------------------
  p_date DATE;
BEGIN
    p_date := to_date(p_str,'DD/MM/RRRR') ;
    RETURN 'Y' ;
EXCEPTION
   WHEN others THEN
    RETURN 'N' ;
END isdate;

 
 
 
 
 
 
 
 
 
 
 
/
