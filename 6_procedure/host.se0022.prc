SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0022 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_TLTXCD      IN       VARCHAR2
)
IS

   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);

   V_CUSTODYCD      VARCHAR2 (20);
   V_CURRDATE       date;
   V_SYMBOL         varchar2 (20);
   V_TLTXCD         varchar2 (10);
   V_FROMDATE       DATE;
   V_TODATE         DATE;

BEGIN
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

   If (PV_SYMBOL IS NULL OR UPPER(PV_SYMBOL) = 'ALL')
   then
        V_SYMBOL := '%';
   else
        V_SYMBOL := replace(PV_SYMBOL,' ', '_');
   end if;


   IF (PV_TLTXCD IS NULL OR UPPER(PV_TLTXCD) = 'ALL')
   THEN
        V_TLTXCD := '%';
   ELSE
        V_TLTXCD := PV_TLTXCD;
   END IF;

   select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE from sysvar where varname = 'CURRDATE';

   V_FROMDATE := to_date(F_DATE, 'DD/MM/RRRR');
   V_TODATE   := to_date(T_DATE, 'DD/MM/RRRR');

OPEN PV_REFCURSOR FOR
SELECT tl.txdate,'3315' tltxcd, ca.camastid "code", sb.symbol , a.cdcontent "TYPE" , ca.description, ca.tradedate
FROM camast ca , vw_tllog_all tl, sbsecurities sb, allcode a
WHERE tl.tltxcd = '3315' AND tl.MSGACCT = ca.camastid AND sb.codeid = NVL(ca.tocodeid,ca.codeid)
AND a.cdtype = 'CA' AND a.cdname = 'CATYPE' AND ca.catype = a.cdval
AND tl.tltxcd LIKE V_TLTXCD AND sb.symbol LIKE v_symbol AND tl.txdate BETWEEN V_FROMDATE AND V_TODATE
UNION ALL
SELECT tl.txdate,'2225' tltxcd, lg.afacctno "code", refsb.symbol, 'CK luu ky' "TYPE", tl.txdesc ,lg.tradedate
FROM SEDEPOWFTLOG lg, vw_tllog_all tl , sbsecurities sb, sbsecurities refsb
WHERE lg.tradedate IS NOT NULL AND lg.deltd <> 'Y' AND tl.DELTD <> 'Y'
AND tl.MSGACCT = lg.afacctno AND tl.tltxcd = '2225' AND tl.ccyusage = lg.codeid
AND lg.codeid = sb.codeid AND sb.refcodeid = refsb.codeid
AND tl.tltxcd LIKE V_TLTXCD AND refsb.symbol LIKE v_symbol AND tl.txdate BETWEEN V_FROMDATE AND V_TODATE
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
