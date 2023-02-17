SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getDefaultAcctno(p_custid IN VARCHAR2, p_acctno IN VARCHAR2)
RETURN CHAR
IS
	l_isdefault char(1);
BEGIN
SELECT CASE WHEN rownumid = 1 THEN 'Y' ELSE 'N' END  INTO l_isdefault
FROM (
	SELECT custid,acctno, ROWNUM rownumid
	FROM (
		SELECT af.custid,af.acctno
		FROM afmast af, aftype aft, mrtype mrt
		WHERE af.actype = aft.actype AND aft.mrtype = mrt.actype
		AND af.custid = p_custid
	order BY CASE WHEN mrt.mrtype = 'N' THEN 0 ELSE 1 END, opndate, af.custid,af.acctno
	)
)
WHERE acctno = p_acctno;
RETURN l_isdefault;
EXCEPTION
WHEN OTHERS THEN
l_isdefault:= 'N';
RETURN l_isdefault;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
