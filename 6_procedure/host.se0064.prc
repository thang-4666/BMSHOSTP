SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0064 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2
)
IS
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);

   V_STRAFACCTNO  VARCHAR2 (15);
   V_CUSTODYCD VARCHAR2 (15);
   V_STRSYMBOL VARCHAR2 (20);

BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_AFACCTNO <> 'ALL')
   THEN
         V_STRAFACCTNO := PV_AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%';
   END IF;

   IF  (UPPER(PV_SYMBOL) <> 'ALL' AND PV_SYMBOL IS NOT NULL)
   THEN
         V_STRSYMBOL := PV_SYMBOL;
   ELSE
      V_STRSYMBOL := '%';
   END IF;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT se.txdate, cf.fullname, af.acctno, cf.custodycd, sb.symbol, iss.fullname securitiesname, msgamt qtty, se.price
FROM seretail se, vw_tllog_all tl,
 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, sbsecurities sb, issuers iss
WHERE substr(se.acctno,1,10) = af.acctno AND af.custid = cf.custid
AND substr(se.acctno,11,6) = sb.codeid AND sb.issuerid = iss.issuerid
AND se.status <> 'R'
AND tl.txdate = se.txdate AND tl.txnum = se.txnum
AND se.txdate <= to_date(T_DATE,'DD/MM/RRRR')
AND se.txdate >= to_date(F_DATE,'DD/MM/RRRR')
AND sb.symbol LIKE V_STRSYMBOL
AND cf.custodycd LIKE V_CUSTODYCD
AND af.acctno LIKE V_STRAFACCTNO
AND (substr(cf.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cf.custid,1,4))<> 0)
ORDER BY cf.custodycd
;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
