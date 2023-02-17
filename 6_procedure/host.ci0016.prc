SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0016" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TXNUM          IN       VARCHAR2

       )
IS
--
-- PURPOSE: BANG KE UY NHIEM CHI
-- PERSON      DATE    COMMENTS
-- TRUONGLD   21-MAY-10  CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRTXNUM     VARCHAR2 (20);

   CUR            PKG_REPORT.REF_CURSOR;

   V_DATE         DATE;
   V_CURR_DATE    DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);


BEGIN
/*
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
*/
 V_STROPTION := upper(OPT);
 V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   V_STRTXNUM := TXNUM;

   V_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');

   SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CURR_DATE  FROM SYSVAR WHERE VARNAME='CURRDATE';
   -- GET REPORT'S PARAMETERS



OPEN PV_REFCURSOR  FOR
SELECT CIR.TXNUM, CF.CUSTODYCD, CI.AFACCTNO, CIR.BENEFCUSTNAME,
CIR.BENEFBANK, CIR.BENEFACCT, CIR.AMT, cir.txdate, cir.potxdate, CIR.POTXNUM, blog.requestid, CIR.txdesc, CF.Idcode, CF.Iddate, cir.FEETYPE
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, CIMAST CI,
(SELECT CIR.*, TL.TXDESC FROM CIREMITTANCE CIR, VW_TLLOG_ALL TL WHERE CIR.deltd <> 'Y' AND TL.TXNUM=CIR.TXNUM AND TL.TXDATE=CIR.TXDATE) cir,
(SELECT * FROM borqslog UNION ALL SELECT * FROM borqsloghist) blog,
 AFMAST AF
WHERE CF.CUSTID = AF.CUSTID
  AND CI.ACCTNO = CIR.ACCTNO
  AND CIR.RMSTATUS ='C'
  AND CIR.TXNUM = blog.txnum (+)
  AND (BLOG.TXDATE  = to_date(CIR.Txdate,'DD/MM/RRRR') OR BLOG.TXDATE IS NULL)
  AND cir.potxnum = V_STRTXNUM
  AND cir.potxdate = V_DATE
  AND CIR.ACCTNO=AF.ACCTNO
  AND (SUBSTR(cir.potxnum,1,4) LIKE V_STRBRID or instr(V_STRBRID,SUBSTR(cir.potxnum,1,4)) <> 0 )
ORDER BY CIR.Txdate, cir.TXNUM;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
