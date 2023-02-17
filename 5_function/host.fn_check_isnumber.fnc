SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_isnumber(p_str IN varchar2)
  RETURN  VARCHAR2 IS
    p_num NUMBER;
    v_char1 VARCHAR2(100);
    v_char2 VARCHAR2(100);
BEGIN
    select SUBSTR(p_str,0,INSTR(p_str,'/') - 1), SUBSTR(p_str,INSTR(p_str,'/')+1,LENGTH(p_str)) into v_char1, v_char2 from dual;
    
    p_num := to_number(v_char1)/to_number(v_char2);
    RETURN p_str ;
EXCEPTION
   WHEN others THEN
    RETURN null;
END fn_check_isnumber;
 
/
