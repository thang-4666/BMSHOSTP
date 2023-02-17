SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1009 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2,
   COREBANK       IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

 V_STRCOREBANK             VARCHAR2 (6);
   V_STRTLTXCD              VARCHAR2 (6);
   V_STRMAKER            VARCHAR2 (20);
   V_STRCHECKER             VARCHAR2 (20);
   V_STRCUSTOCYCD           VARCHAR2 (20);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;



   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTOCYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTOCYCD := '%%';
   END IF;

   IF (COREBANK <> 'ALL')
   THEN
      V_STRCOREBANK := COREBANK;
   ELSE
      V_STRCOREBANK := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR

select sts.cleardate,sts.txdate ,  SUM (   CASE WHEN CF.VAT='Y' OR CF.WHTAX='Y' THEN od.taxsellamt ELSE 0 END     )     VAT , SUM(DECODE ( STS.duetype,'RM',FEEACR,0 )) FEEACR_S, SUM(DECODE ( STS.duetype,'SM',FEEACR,0 )) FEEACR_B
from (select orgorderid, duetype,txdate, cleardate, sum( round( DECODE (duetype,'RM',AMT*0.0005,0 ))) amtvat
      from  vw_stschd_all
      where duetype in ('RM','SM') group by orgorderid, duetype,cleardate,txdate) sts ,vw_odmast_all od,afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf,AFTYPE
where sts.orgorderid= od.orderid
and od.deltd <>'Y' and sts.duetype in ('RM','SM')
AND AF.ACTYPE=AFTYPE.ACTYPE
AND sts.cleardate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND sts.cleardate <= TO_DATE(T_DATE,'DD/MM/YYYY')
and cf.CUSTODYCD like V_STRCUSTOCYCD
AND AF.corebank LIKE V_STRCOREBANK
and od.afacctno =af.acctno  and af.custid = cf.custid
AND AF.ACTYPE NOT IN ('0000')
AND   (SUBSTR(af.acctno,1,4) like  V_STRBRID or instr(V_STRBRID,SUBSTR(af.acctno,1,4)) <> 0)
and cf.custatcom ='Y'
GROUP BY  sts.txdate,sts.cleardate
HAVING  SUM(DECODE ( STS.duetype,'RM',FEEACR,0 ))+ SUM(DECODE ( STS.duetype,'SM',FEEACR,0 ))>0
ORDER BY sts.cleardate

;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
