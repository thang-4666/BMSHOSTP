SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_sysvar_for_report (p_sys_grp IN varchar2, p_sys_name IN varchar2)
      RETURN varchar2--sysvar.varvalue%TYPE
   IS
      l_sys_value   varchar2(200);--sysvar.varvalue%TYPE;
   BEGIN
      SELECT varvalue
      INTO l_sys_value
      FROM sysvar
      WHERE varname = p_sys_name AND grname = p_sys_grp;

      RETURN l_sys_value;
   END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
