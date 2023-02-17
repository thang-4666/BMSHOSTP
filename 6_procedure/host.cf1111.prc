SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1111 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   pv_CUSTODYCD             IN       VARCHAR2
           )
IS
    v_CUSTODYCD VARCHAR2(15);
BEGIN

    v_CUSTODYCD:= pv_CUSTODYCD;

OPEN PV_REFCURSOR
FOR
select cf.custodycd,cf.fullname,cf.idcode,cf.iddate,cf.idplace,cf.address,cf.mobile,cf.mobilesms mobilesms,cf.fax,cf.email,cf.dateofbirth,A1.cdcontent country,
nvl(cfrm.fullname,'') cfrmfullname, nvl(cfrm.licenseno,'') cfrmidcode, nvl(cfrm.description,'') cfrmdescription
from cfmast cf,
(select cdval,cdcontent from allcode where cdname = 'COUNTRY') A1,
(SELECT trim(CFR.CUSTID) custid,CFR.FULLNAME fullname,CFR.LICENSENO licenseno,RET.DISPLAY description FROM CFRELATION CFR,
     (SELECT  CDVAL VALUECD, CDVAL VALUE, CDCONTENT DISPLAY FROM ALLCODE WHERE CDTYPE = 'CF' AND CDNAME = 'RETYPE') RET
 WHERE CFR.RETYPE = RET.VALUE
) cfrm
where A1.cdval = cf.country
and cf.CUSTID = cfrm.CUSTID(+)
and cf.custodycd = v_CUSTODYCD;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
