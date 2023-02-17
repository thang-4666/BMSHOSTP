SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_TODATE_5574(P_AUTOID IN VARCHAR2)
    RETURN DATE IS

    V_RESULT DATE ;
v_overduedate date ;
v_acctno varchar2(20);
v_MAXEXDAYS number ;

BEGIN

SELECT overduedate,acctno into v_overduedate , v_acctno  FROM lnschd WHERE autoid = P_AUTOID;

select lnt.MAXEXDAYS into  v_MAXEXDAYS from lnmast ln,lntype lnt where ln.actype = lnt.actype  and ln.acctno =v_acctno;

SELECT MAX(SBDATE) INTO V_RESULT FROM sbcldr  WHERE SBDATE <= getduedate (v_overduedate,'N','000',v_MAXEXDAYS) AND cldrtype ='000' AND holiday ='N';

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN TO_DATE ('01/01/2000','DD/MM/YYYY');
END;
 
 
 
 
/
