SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GL_REGR
(CUSTODYCD, FULLNAME, CAREBY, REFRECFLNKID, GRP, 
 TYPEGR, RE_FRDATE, RE_TODATE, REGL_FRDATE, REGL_TODATE)
BEQUEATH DEFINER
AS 
SELECT cf.custodycd, cf.fullname ,cf2.fullname careby , REGl.refrecflnkid,regrp.fullname GRP 
, CASE WHEN RETYPE.actype IN ('1000','1001') THEN 'SALE'
       WHEN RETYPE.actype IN ('1002') THEN 'TC'
       WHEN RETYPE.actype IN ('1003') THEN 'CTV'
       WHEN RETYPE.actype IN ('1004') THEN 'DHT'
       WHEN RETYPE.actype IN ('1111','1112') THEN 'MGA'
       WHEN RETYPE.actype IN ('1012') THEN 'KHN'
  END TYPEGR,     
 re.frdate re_frdate, nvl(re.clstxdate-1, re.todate) re_todate ,
   REGl.frdate REGl_frdate, nvl(REGl.clstxdate-1, REGl.todate) REGl_todate
FROM reaflnk re, regrplnk REGl,retype,cfmast cf, cfmast cf2,regrp 
WHERE re.reacctno = REGl.reacctno(+)
AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
AND retype.rerole ='RM'
AND re.afacctno = cf.custid
AND substr(re.reacctno,1,10)= cf2.custid
AND regl.refrecflnkid= regrp.autoid
/
