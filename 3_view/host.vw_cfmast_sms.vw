SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_CFMAST_SMS
(MOBILESMS, EMAIL, CUSTODYCD, CUSTID, FULLNAME, 
 ADDRESS, IDCODE, IDDATE, IDPLACE)
BEQUEATH DEFINER
AS 
select /*nvl( case  when LENGTH(cf.mobilesms)>=10 and substr(cf.mobilesms,1,2) in ('01','09') then  cf.mobilesms else '' end ,
            case  when LENGTH(cf.mobile)>=10 and substr(cf.mobile,1,2) in ('01','09') then  cf.mobile else '' end  )
            mobilesms*/
        nvl(cf.mobilesms,nvl(cf.mobile,'123456789')) mobilesms
, cf.email, cf.custodycd,cf.custid,cf.fullname,cf.address,cf.idcode,cf.iddate,cf.idplace
from cfmast cf
/
