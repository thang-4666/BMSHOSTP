SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_GETPOTXNUM(PV_BRID IN VARCHAR2) RETURN VARCHAR2
IS
   l_Return VARCHAR2(10) := '1';
   l_BRID   VARCHAR2(4);
BEGIN

    l_BRID := PV_BRID;
    Begin
        SELECT NVL(MAX(ODR)+1,1) INTO  l_Return FROM
                      (SELECT ROWNUM ODR, INVACCT
                      FROM (SELECT TXNUM INVACCT FROM POMAST WHERE BRID = l_BRID ORDER BY TXNUM) DAT
                      ) INVTAB;

        l_Return := substr('000000' || l_Return,length('000000' || l_Return)-5,6);
        l_Return := l_BRID || l_Return;

    EXCEPTION
        WHEN OTHERS THEN  l_Return := '1';
        l_Return := substr('000000' || l_Return,length('000000' || l_Return)-5,6);
        l_Return := l_BRID || l_Return;
        return l_Return;
   End;
    RETURN l_Return;
EXCEPTION
  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
