SET DEFINE OFF;
CREATE OR REPLACE FUNCTION isnumber(p_str IN varchar2)
  RETURN  VARCHAR2 IS
-- ThangNV: Function to check a field is number or not
-- 30/09/2013
-- ---------   ------  -------------------------------------------
    p_num NUMBER;
BEGIN
    p_num := to_number(p_str);
    RETURN 'Y' ;
EXCEPTION
   WHEN others THEN
    RETURN 'N';
END isnumber;

 
 
 
 
 
 
 
 
 
 
 
/
