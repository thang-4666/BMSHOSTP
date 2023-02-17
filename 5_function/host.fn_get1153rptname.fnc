SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get1153rptname( p_afacctno IN VARCHAR2)
    RETURN varchar2 IS
    l_reportname varchar2(100);
BEGIN
    select 'CI1153MANUAL'
           into l_reportname
    from dual;

    RETURN l_reportname;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;
 
 
 
 
 
 
 
 
 
 
 
/
