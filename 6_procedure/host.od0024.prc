SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0024 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS
---------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);
   V_CURRDATE        DATE;


BEGIN
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

   SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CURRDATE
   FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

OPEN PV_REFCURSOR
  FOR


SELECT cf.fullname, cf.custodycd,OD.TXDATE,BR.BRNAME,
       sum(CASE WHEN OD.exectype IN ('MS','NS','SS') THEN OD.execqtty ELSE 0 END) S_qtty,
       sum(CASE WHEN OD.exectype IN ('MS','NS','SS') THEN OD.execamt ELSE 0 END) S_amt,
       sum(CASE WHEN OD.exectype = 'NB' THEN OD.execqtty ELSE 0 END) B_qtty,
       sum(CASE WHEN OD.exectype = 'NB' THEN OD.execamt ELSE 0 END) B_amt,
       sum(CASE WHEN od.execamt = 0 THEN 0 ELSE
            (CASE WHEN od.TXDATE = V_CURRDATE and OD.feeacr=0 THEN ROUND(OD.execamt * odtype.deffeerate / 100, 2)
            ELSE OD.feeacr END)
        END) fee,
      SUM(CASE WHEN od.EXECTYPE IN('NS','SS','MS')THEN
      (CASE WHEN od.txdate  = V_CURRDATE THEN ROUND(   ( DECODE ( CF.VAT,'Y',TO_NUMBER(SYS.VARVALUE),'N',0) +DECODE ( CF.WHTAX,'Y',TO_NUMBER(SYS1.VARVALUE),'N',0)   )/100*OD.execamt)
        ELSE decode(Cf.vat,'Y', od.taxsellamt,0) END)
      ELSE 0 END) VAT
FROM vw_odmast_all od, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
     aftype, odtype, sbsecurities sb, SYSVAR SYS, BRGRP BR, SYSVAR SYS1
WHERE od.deltd <> 'Y'
    AND od.afacctno = af.acctno
    AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
    AND SYS1.GRNAME = 'SYSTEM' AND SYS1.VARNAME = 'WHTAX'
    AND af.custid = cf.custid
    AND AF.ACTYPE NOT IN ('0000')
    AND af.actype = aftype.actype
    AND odtype.actype = od.actype
    AND od.codeid = sb.codeid
    AND CF.BRID=BR.BRID
    AND OD.execamt > 0
    AND od.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
    AND od.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
   -- AND CF.BRID LIKE V_STRBRID
GROUP BY cf.fullname, cf.custodycd,OD.TXDATE,BR.BRNAME
ORDER BY OD.TXDATE,cf.fullname, cf.custodycd



;



EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
