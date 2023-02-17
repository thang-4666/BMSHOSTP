SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca21thq (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2
   )
IS
--
-- PURPOSE: DANH SACH NDT DANG KY MUA CK
-- PERSON      DATE    COMMENTS
-- PHUONGNN   16-05-10  CREATE
-- ---------   ------  -------------------------------------------
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRSYMBOL    VARCHAR2 (20);
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   if SYMBOL IS NULL  THEN
      V_STRSYMBOL :=  '%%';
   else
      V_STRSYMBOL := SYMBOL;
   end if;
   -- GET REPORT'S PARAMETERS

OPEN PV_REFCURSOR
   FOR
        SELECT  sb.symbol,
                iss.fullname secname,
                cf.fullname,
                --cf.Idcode,
                (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
                cf.iddate,
                cf.idplace,
                cf.address,
                cf.custodycd,
                '' sectype,
                ca.pqtty qtty,
                mst.price,
                ca.aamt aamt,
                mst.reportdate,
                mst.actiondate,
                mst.rightoffrate
        FROM camast mst , sbsecurities sb, caschd ca, afmast af, cfmast cf, issuers iss
        WHERE mst.camastid = ca.camastid
        AND ca.afacctno = af.acctno
        AND af.custid = cf.custid
        AND sb.codeid = ca.codeid
        AND sb.issuerid = iss.issuerid
        AND ca.status IN ('A','S','M') AND ca.status <> 'Y' AND ca.deltd <> 'Y'
        AND mst.catype = '014' AND ca.pqtty > 0 AND ca.pbalance > 0
        and sb.symbol like V_STRSYMBOL;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
