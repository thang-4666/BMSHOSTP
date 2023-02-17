SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CRM_CF_VIEW
(BRNAME, ACCTNO, CUSTODYCD, FULLNAME, OPNDATE, 
 SEX, IDCODE, TRADEPHONE, PHONE1, PIN, 
 IDDATE, IDPLACE, EMAIL, ADDRESS, CUSTID, 
 CLASS, REFNAME, DATEOFBIRTH, AFTYPE)
BEQUEATH DEFINER
AS 
select br.brname,af.acctno, cf.custodycd,cf.fullname, af.opndate, cf.sex, cf.idcode, cf.mobilesms tradephone,cf.mobile phone1,
cf.pin, cf.iddate,cf.idplace,cf.email, cf.address, af.custid, cf.class, cf.refname,
 to_date(to_char(cf.DATEOFBIRTH,'mm/dd/yyyy'),'mm/dd/yyyy'), af.aftype
from afmast af, cfmast cf, brgrp br
where af.custid=cf.custid
and af.status = 'A'
and substr(af.acctno,1,4)=br.brid
/
