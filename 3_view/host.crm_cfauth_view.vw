SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CRM_CFAUTH_VIEW
(CFCUSTID, TELEPHONE, FULLNAME, LICENSENO, VALDATE, 
 EXPDATE)
BEQUEATH DEFINER
AS 
select au.cfcustid,case when au.custid is null then au.telephone else cf.mobilesms end telephone,
case when au.custid is null then au.fullname else cf.fullname end fullname ,
case when au.custid is null then au.licenseno else cf.idcode end licenseno,
au.valdate,au.expdate
from CFAUTH au, cfmast cf
where au.deltd<>'Y' and cf.custid = au.custid
and au.valdate <=sysdate and au.expdate>=trunc(sysdate)
/
