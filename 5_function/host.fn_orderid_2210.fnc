SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_orderid_2210(p_afacctno in varchar2)
  RETURN  VARCHAR2
  IS
  l_strORDERID varchar2(100);
BEGIN
    SELECT SUBSTR(p_afacctno,1,4) || TO_CHAR(TO_DATE (varvalue, 'DD\MM\RR'),'DDMMRR') || LPAD (seq_odmast.NEXTVAL, 6, '0')
        INTO l_strORDERID
    FROM sysvar WHERE varname ='CURRDATE' AND grname='SYSTEM';

    RETURN l_strORDERID ;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
