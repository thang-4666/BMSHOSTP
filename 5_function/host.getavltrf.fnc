SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getavltrf (p_afacctno IN VARCHAR2, p_rlsamt IN  NUMBER,p_pp IN NUMBER  )
RETURN NUMBER
  IS
    l_avltrf NUMBER(20,2);
    l_afacctno varchar2(20);

BEGIN
l_avltrf:=0;
l_afacctno:=substr( REPLACE( p_afacctno,'''',''),1,10);

SELECT  LEAST( GREATEST( dueamt + ovamt-balance,0),p_pp + p_rlsamt) INTO l_avltrf FROM cimast WHERE acctno  = l_afacctno;

RETURN l_avltrf;


EXCEPTION WHEN others THEN
    return 0;
END;
 
 
 
 
/
