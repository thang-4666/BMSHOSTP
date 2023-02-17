SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ISSUERSCV
(BRID, SYMBOL, FULLNAME, ADDRESS, PHONE, 
 FAX, LICENSENO, LICENSEDATE, LEGALCAPTIAL, SHARECAPITAL)
BEQUEATH DEFINER
AS 
select '0001' brid , nvl(SB.SYMBOL,' ')SYMBOL ,nvl( fullname,' ') fullname ,nvl(address,' ') address, nvl(phone,' ')phone , nvl(fax,' ') fax, nvl( licenseno,' ')licenseno,nvl(to_char(licensedate,'DD-MM-YYYY'),' ') licensedate,nvl(legalcaptial,0) legalcaptial,nvl(sharecapital,0)sharecapital  
from issuers ISS,SBSECURITIES SB
WHERE ISS.ISSUERID =SB.ISSUERID
AND SB.REFCODEID IS NULL 
ORDER BY SYMBOL ,fullname
/
