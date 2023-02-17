SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD1008" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TLTXCD         IN       VARCHAR2,
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
   V_STRTLTXCD              VARCHAR2 (8);
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

   IF (TLTXCD <> 'ALL')
   THEN
      V_STRTLTXCD := TLTXCD||'%';
   ELSE
      V_STRTLTXCD := '%%';
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

SELECT * FROM (
select tl.tltxcd  tltxcd, tl.txnum, tl.txdate, af.acctno, cf.custodycd,se.symbol ,tl.msgamt amt, se.namt  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, vw_setran_gen se, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf,vw_stschd_all sts,vw_citran_gen ci
where tl.txnum = se.txnum and tl.txdate =se.txdate and tl.tltxcd ='8865'
and se.afacctno = af.acctno and af.custid = cf.custid  and se.txcd ='0016' and ci.txcd ='0011'
AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
and se.ref = sts.orgorderid
and sts.duetype ='SM'
and tl.deltd <>'Y'
and ci.txnum = tl.txnum
and ci.txdate =tl.txdate
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
UNION ALL
select tl.tltxcd , tl.txnum, tl.txdate, af.acctno, cf.custodycd,se.symbol ,tl.msgamt amt, se.namt  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, vw_setran_gen se, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf
where tl.txnum = se.txnum and tl.txdate =se.txdate and tl.tltxcd ='8866'
and se.afacctno = af.acctno and af.custid = cf.custid  and se.txcd ='0020'
AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND TL.deltd<>'Y'
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
UNION all
select se.tltxcd , se.txnum, se.txdate, af.acctno, cf.custodycd,se.symbol ,ci.namt amt, se.namt  qtty,se.txdesc,af.corebank
from  vw_CItran_gen ci, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf, vw_setran_gen se,vw_stschd_all sts
where se.txnum = ci.txnum and se.txdate =ci.txdate and se.tltxcd ='8867'  and se.txcd ='0011'
and se.ref = sts.orgorderid
and sts.duetype ='SS'
and ci.acctno = af.acctno and af.custid = cf.custid AND AF.ACTYPE NOT IN ('0000')
--and tl.txdate =se.txdate and tl.txnum =se.txnum
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND se.deltd<>'Y'
and se.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND se.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
UNION ALL
select tl.tltxcd , tl.txnum, tl.txdate, af.acctno, cf.custodycd,se.symbol ,tl.msgamt amt, se.namt  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, vw_setran_gen se, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf
where tl.txnum = se.txnum and tl.txdate =se.txdate and tl.tltxcd ='8868'
and se.afacctno = af.acctno and af.custid = cf.custid  and se.txcd ='0045' AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND TL.deltd<>'Y'
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
UNION ALL
select tl.tltxcd , tl.txnum, tl.txdate, af.acctno, cf.custodycd,'' symbol ,tl.msgamt amt, 0  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, vw_citran_gen ci, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf
where tl.txnum = ci.txnum and tl.txdate =ci.txdate and tl.tltxcd ='8856'
and ci.acctno = af.acctno and af.custid = cf.custid  and ci.txcd ='0016' AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND TL.deltd<>'Y'
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
UNION ALL
select tl.tltxcd ||'T'|| '0'  tltxcd , tl.txnum, tl.txdate, af.acctno, cf.custodycd,' ' symbol ,tl.msgamt amt, 0  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, vw_citran_gen ci, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf,vw_stschd_all sts
where tl.txnum = ci.txnum and tl.txdate =ci.txdate and tl.tltxcd ='8855'
and ci.acctno = af.acctno and af.custid = cf.custid  and ci.txcd ='0011' AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND TL.deltd<>'Y'
and CI.ref = sts.orgorderid
and sts.duetype ='SM'
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
UNION ALL
select tl.tltxcd , tl.txnum, tl.txdate, af.acctno, cf.custodycd,'' symbol ,tl.msgamt amt, 0  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf
where tl.tltxcd ='0066'
and TL.msgacct = af.acctno and af.custid = cf.custid AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND TL.deltd<>'Y'
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
union all
select tl.tltxcd   tltxcd , tl.txnum, tl.txdate, af.acctno, cf.custodycd,sb.symbol symbol ,tl.msgamt amt, sts.qtty  qtty,tl.txdesc,af.corebank
from  vw_tllog_all tl, vw_citran_gen ci, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf,vw_stschd_all sts,sbsecurities sb
where tl.txnum = ci.txnum and tl.txdate =ci.txdate and tl.tltxcd ='8889'
and ci.acctno = af.acctno and af.custid = cf.custid  and ci.txcd ='0011' AND AF.ACTYPE NOT IN ('0000')
and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
AND TL.deltd<>'Y'
and CI.ref = sts.orgorderid
and sts.duetype ='SM'
and sts.codeid=sb.codeid
and tl.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND tl.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
) DTL
WHERE
/*DTL.txdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND DTL.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
and */
DTL.tltxcd like V_STRTLTXCD
and DTL.CUSTODYCD like V_STRCUSTOCYCD
AND corebank LIKE V_STRCOREBANK
ORDER BY tltxcd,TXDATE,TXNUM
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
