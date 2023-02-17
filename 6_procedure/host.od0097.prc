SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0097(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                   OPT          IN VARCHAR2,
                                   PV_BRID      IN VARCHAR2,
                                   TLGOUPS      IN VARCHAR2,
                                   TLSCOPE      IN VARCHAR2,
                                   F_DATE       IN VARCHAR2,
                                   T_DATE       IN VARCHAR2) IS
  --
  -- PURPOSE: THONG KE GIAO DICH TRAI PHIEU THONG THUONG
  --
  -- MODIFICATION HISTORY
  -- PERSON      DATE    COMMENTS
  --DONT        07/09/16    CREATE
  -- ---------   ------  -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(4); -- USED WHEN V_NUMOPTION > 0
  V_STRBRGID  VARCHAR2(10);

  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  V_STROPTION := OPT;

  IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL') THEN
    V_STRBRID := PV_BRID;
  ELSE
    V_STRBRID := '%%';
  END IF;

  -- GET REPORT'S PARAMETERS

  -- END OF GETTING REPORT'S PARAMETERS

  -- GET REPORT'S DATA
  /*IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
  THEN*/
  OPEN PV_REFCURSOR FOR
    SELECT od.orderid,
           od.txdate,
           sb.symbol,
           sb.codeid,
           pt.billpirce,
           od.execqtty,
           od.execamt,
           od.quoteprice,
           (CASE
             WHEN od.exectype LIKE '%B%' THEN
              pt.partner
             ELSE
              cf.fullname
           end) partnerSell,
           (CASE
             WHEN od.exectype LIKE '%B%' THEN
              ''
             ELSE
              'X'
           end) Sell_vcbs,
           (CASE
             WHEN od.exectype LIKE '%S%' THEN
              pt.partner
             ELSE
              cf.fullname
           end) partnerBuy,
            (CASE
             WHEN od.exectype LIKE '%S%' THEN
              ''
             ELSE
              'X'
           end) Buy_VCBS,
           (CASE
             WHEN od.exectype LIKE '%B%' THEN
              'N'
             ELSE
              'Y'
           end) iSVCBSSell,
           br.brname
      FROM (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist) od,
           bondtransactpt pt,
           sbsecurities sb,
           afmast af,
           brgrp br,
           cfmast cf
     WHERE od.orderid = pt.orderid
       AND od.codeid = sb.codeid
       AND od.afacctno = af.acctno
       AND af.custid = cf.custid
       AND cf.brid = br.brid
       AND od.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
       AND od.txdate <= to_date(T_DATE, 'DD/MM/RRRR');

  /*END IF;*/
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
