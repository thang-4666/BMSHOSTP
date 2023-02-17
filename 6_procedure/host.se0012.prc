SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0012" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_SECTYPE     IN       VARCHAR2,
   PV_TRADEPLACE  IN       VARCHAR2
)
IS
--
-- Bao cao luu ky
-- created by chaunh at 25/06/2012
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_STRSYMBOL      VARCHAR (20);
   V_STRSECTYPE        VARCHAR (40);
   V_STRTRADEPLACE     VARCHAR2 (20);
   V_FROMDATE           DATE;
   V_TODATE           DATE;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   -- GET REPORT'S PARAMETERS

   IF(PV_SYMBOL <> 'ALL') THEN
     V_STRSYMBOL := replace(PV_SYMBOL,' ','_');
   ELSE
     V_STRSYMBOL := '%';
   END IF;

   IF(PV_SECTYPE <> 'ALL') THEN
     V_STRSECTYPE := PV_SECTYPE;
   ELSE
     V_STRSECTYPE := '%';
   END IF;

   IF(PV_TRADEPLACE  <> 'ALL')
   THEN
      V_STRTRADEPLACE := replace(PV_TRADEPLACE,' ','_');
   ELSE
      V_STRTRADEPLACE := '%';
   END IF;

   V_FROMDATE := to_date(F_DATE,'DD/MM/YYYY');
   V_TODATE := to_date(T_DATE,'DD/MM/YYYY');


-- GET REPORT'S DATA
OPEN PV_REFCURSOR
    FOR
SELECT iss.fullname, sb2.symbol, sum(a.amt) amt ,
           CASE WHEN inf.txdate < V_FROMDATE THEN 'Old' ELSE 'New' END note
    FROM
        (
        SELECT substr(tl.msgacct,11,6) codeid, sum(nvl(tl.msgamt,0)) amt
         FROM vw_tllog_all tl, semast se, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
        WHERE tl.tltxcd = '2246' AND tl.deltd <> 'Y'
        AND tl.busdate >= V_FROMDATE AND tl.busdate <= V_TODATE
        AND se.acctno = tl.msgacct AND cf.custid = af.custid AND se.afacctno = af.acctno
        AND (substr(cf.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cf.custid,1,4))<> 0)
        GROUP BY substr(tl.msgacct,11,6)
        UNION ALL
        SELECT codeid, sum(namt) amt FROM vw_setran_gen
        WHERE tltxcd = '3351' AND busdate >= V_FROMDATE AND busdate <= V_TODATE
        AND field = 'DCRQTTY'
        AND (substr(custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(custid,1,4))<> 0)
        GROUP BY codeid
        /*UNION all
        SELECT nvl(ca.tocodeid,ca.codeid) codeid, sum(nvl(tl.msgamt,0)) amt
        FROM vw_tllog_all tl , camast ca
        WHERE tl.tltxcd = '3341' AND tl.deltd <> 'Y'
        AND tl.busdate >= V_FROMDATE AND tl.busdate <= V_TODATE
        AND ca.camastid = tl.msgacct
        GROUP BY nvl(ca.tocodeid,ca.codeid)*/
        ) a, sbsecurities sb1, sbsecurities sb2, issuers iss, securities_info inf
    WHERE sb1.codeid = a.codeid
    AND nvl(sb1.refcodeid,sb1.codeid) = sb2.codeid
    AND iss.issuerid = sb2.issuerid
    AND sb2.codeid = inf.codeid
    AND sb2.tradeplace LIKE  V_STRTRADEPLACE
    AND sb2.symbol LIKE V_STRSYMBOL
    AND CASE WHEN V_STRSECTYPE = '%' THEN 1
         WHEN V_STRSECTYPE <>  '%' AND instr(V_STRSECTYPE, sb2.sectype ) <> 0 THEN 1
         ELSE 0 END = 1
    GROUP BY iss.fullname, sb2.symbol, CASE WHEN inf.txdate < V_FROMDATE THEN 'Old' ELSE 'New' END
    HAVING sum(a.amt) <> 0
    ORDER BY sb2.symbol


/*SELECT  V_INDATE i_date, sb2.symbol,iss.fullname,
    sum(SE.TRADE + SE.BLOCKED + se.secured + SE.WITHDRAW
        + SE.MORTAGE +NVL(SE.netting,0) + NVL(SE.dtoclose,0)  + SE.WTRADE - nvl(tran.amt,0)) AMT
FROM semast se,sbsecurities sb, sbsecurities sb2, issuers iss, cfmast cf, afmast af,
    (
        SELECT tran.codeid, tran.acctno,  sum(CASE WHEN tran.txtype = 'D' THEN -tran.namt ELSE tran.namt END) amt FROM vw_setran_gen tran
        WHERE tran.txtype IN ('D','C')
        AND tran.field IN ('TRADE','BLOCKED','WITHDRAW','MORTAGE','SECURED','NETTING','DTOCLOSE','WTRADE')
        AND tran.busdate > V_INDATE
        GROUP BY tran.codeid, tran.acctno
    ) tran
WHERE iss.issuerid = sb.issuerid
AND se.codeid = sb.codeid
AND sb.sectype <> '004'
AND cf.custid = af.custid AND af.acctno = se.afacctno
AND cf.custatcom = 'Y'
AND se.acctno = tran.acctno (+)
AND nvl(sb.refcodeid, sb.codeid) = sb2.codeid
AND sb2.tradeplace LIKE  V_STRTRADEPLACE
AND sb2.symbol LIKE V_STRSYMBOL
AND CASE WHEN V_STRSECTYPE = '%' THEN 1
         WHEN V_STRSECTYPE <>  '%' AND instr(V_STRSECTYPE, sb2.sectype ) <> 0 THEN 1
         ELSE 0 END = 1
--AND (SUBSTR(af.acctno,1,4) like  V_STRBRID or instr(V_STRBRID,SUBSTR(af.acctno,1,4)) <> 0)
GROUP BY sb2.symbol,iss.fullname
ORDER BY sb2.symbol*/
;


 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
