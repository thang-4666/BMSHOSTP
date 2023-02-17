SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CFCONTACTCV
(CUSTODYCD, TYPE, PERSON, TYPEPERSON, IDCODE, 
 IDDATE, IDPLACE, ADDRESS, EMAIL, DESCRIPTION, 
 BRID)
BEQUEATH DEFINER
AS 
select cf1.custodycd,'006' type , cf2.fullname PERSON ,AL.CDCONTENT TYPEPERSON, nvl(cf2.IDCODE,' ') IDCODE,  NVL(TO_CHAR(cf2.IDDATE,'DD-MM-YYYY'),' ')  IDDATE,nvl(cf2.IDPLACE,' ') IDPLACE ,nvl(cf2.ADDRESS,' ') ADDRESS,NVL(cf2.EMAIL,' ') EMAIL,' ' DESCRIPTION,CF1.BRID
  from cfrelation cfr, cfmast cf1 , cfmast cf2 , ALLCODE AL
where trim(cfr.custid) = cf1.custid
and trim(cfr.recustid) = cf2.custid
AND AL.CDVAL = cfr.retype 
and al.cdname='RETYPE' AND AL.CDTYPE ='CF'
order by cf1.custodycD
/
