SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SA9901
(CUSTODYCD, FULLNAME, PERSON, ADDRESS1, ADDRESS, 
 SEX, OPNDATE, DESCRIPTION, IDCODE, IDDATE, 
 IDPLACE, PHONE, MOBILE, FAX, EMAIL, 
 LOAIHINH, STATUS)
BEQUEATH DEFINER
AS 
SELECT CF.custodycd , CF.fullname, nvl(cfc.person,'NULL') person, nvl(cfc.address,'NULL') address1,cf.address , (case when cf.sex ='001' then 'NAM' ELSE 'NU' END ) SEX, AF.opndate,cf.description ,cf.idcode ,cf.iddate  
,cf.idplace  ,CF.phone, CF.mobile, CF.fax, CF.email, (CASE WHEN IDTYPE ='001' THEN 'CANHAN' ELSE 'TOCHUC' END) LOAIHINH, CF.STATUS
FROM  CFMAST CF, AFMAST AF , cfcontact cfc
WHERE CF.custid = AF.custid 
and cf.custid = cfc.custid(+)
ORDER BY CF.custodycd
/
