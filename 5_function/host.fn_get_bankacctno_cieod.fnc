SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_BANKACCTNO_CIEOD
      RETURN varchar2--sysvar.varvalue%TYPE
   IS
      l_sys_value   varchar2(200);--sysvar.varvalue%TYPE;
   BEGIN
      SELECT varvalue
      INTO l_sys_value
      FROM sysvar
      WHERE varname = 'BANKACCTNO_CIEOD' AND grname = 'SYSTEM';

      RETURN l_sys_value;
   END;

 
 
 
 
/
