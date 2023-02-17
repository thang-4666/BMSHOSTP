SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GL_INVESTOR_INFO
(CUSTID, CUSTODYCD, SHORTNAME, FULLNAME, IDTYPE, 
 IDCODE, IDDATE, IDPLACE, ADDRESS, PHONE, 
 MOBILE, FAX, SEX, DATEOFBIRTH, COUNTRYCD, 
 COUNTRY, CUSTTYPECD, CUSTTYPE, BRID, BRNAME, 
 TAXCODE, OPNDATE, EMAIL)
BEQUEATH DEFINER
AS 
select DISTINCT(cf.custid),cf.custodycd,cf.shortname,cf.fullname,
       a.cdcontent idtype,cf.idcode,TO_CHAR(cf.iddate,'YYYY-MM-DD') iddate,cf.idplace,cf.address,cf.phone,cf.mobile,cf.fax,
       a1.cdcontent sex,TO_CHAR(cf.dateofbirth,'YYYY-MM-DD') dateofbirth,cf.country countrycd, a2.cdcontent country,
       cf.custtype custtypecd, a3.cdcontent custtype, br.brid, br.brname,cf.taxcode, cf.opndate, cf.email
from cfmast cf ,allcode a ,allcode a1 , allcode a2 ,allcode a3 , brgrp br
where cf.idtype = a.cdval(+)
and nvl(a.cdname,'IDTYPE')='IDTYPE'
and nvl(a.cdtype,'CF')='CF'
and cf.sex = a1.cdval
and nvl(a1.cdname,'SEX')='SEX'
and nvl(a1.cdtype,'CF')='CF'
and cf.country = a2.cdval
and nvl(a2.cdname,'COUNTRY')='COUNTRY'
and nvl(a2.cdtype,'CF')='CF'
and cf.custtype = a3.cdval
and nvl(a3.cdtype,'CF')='CF'
and nvl(a3.cdname,'CUSTTYPE')='CUSTTYPE'
and br.brid = cf.brid
ORDER BY cf.custid
/
