SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0098(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
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
    SELECT CASE
             WHEN rep.leg = 'D' THEN
              begindate
             ELSE
              enddate
           END txdate,
           rep.amt1,
           rep.amt2,
           rep.intcoupon,
           rep.symbol,
           rep.brname,
           rep.leg,
           rep.interrestrate,
           rep.execqtty,
           rep.begindate,
           rep.enddate,
           rep.quoteprice,
           rep.partnerSell,
           rep.partnerBuy,
           rep.isVCBSSell,
           REp.Sell_VCBS,
           rep.buy_VCBS
      FROM (SELECT sb.symbol,
                   br.brname,
                   rp1.leg,
                   rp1.interrestrate,
                   od.execqtty,
                   sb.intcoupon,
                   (CASE
                     WHEN rp1.leg = 'D' THEN
                      rp1.amt1
                     ELSE
                      rp2.amt1
                   END) amt1,
                   (CASE
                     WHEN rp1.leg = 'D' THEN
                      rp1.amt2
                     ELSE
                      rp2.amt2
                   end) amt2,
                   CASE
                     WHEN rp1.leg = 'D' THEN
                      rp1.txdate
                     ELSE
                      rp2.txdate
                   END begindate,
                   CASE
                     WHEN rp1.leg = 'D' THEN
                      rp1.enddate
                     ELSE
                      rp1.txdate
                   END enddate,
                   od.quoteprice,
                   CASE
                     WHEN rp1.leg = 'D' THEN
                      (CASE
                        WHEN od.exectype LIKE '%B%' THEN
                         rp1.partner
                        ELSE
                         cf.fullname
                      end)
                     ELSE
                      (CASE
                        WHEN od.exectype LIKE '%B%' THEN
                         rp2.partner
                        ELSE
                         cf.fullname
                      end)
                   END partnerSell,
                   CASE
                     WHEN rp1.leg = 'D' THEN
                      (CASE
                        WHEN od.exectype LIKE '%B%' THEN
                         ''
                        ELSE
                         'X'
                      end)
                     ELSE
                      (CASE
                        WHEN od.exectype LIKE '%B%' THEN
                         ''
                        ELSE
                         'X'
                      end)
                   END Sell_VCBS,
                   CASE
                     WHEN rp1.leg = 'D' THEN
                      (CASE
                        WHEN od.exectype LIKE '%S%' THEN
                         rp1.partner
                        ELSE
                         cf.fullname
                      end)
                     ELSE
                      (CASE
                        WHEN od.exectype LIKE '%S%' THEN
                         rp2.partner
                        ELSE
                         cf.fullname
                      end)
                   end partnerBuy,
                   --
                   CASE
                     WHEN rp1.leg = 'D' THEN
                      (CASE
                        WHEN od.exectype LIKE '%S%' THEN
                         ''
                        ELSE
                         'X'
                      end)
                     ELSE
                      (CASE
                        WHEN od.exectype LIKE '%S%' THEN
                         ''
                        ELSE
                         'X'
                      end)
                   end Buy_VCBS,
                   --
                   (CASE
                     WHEN od.exectype LIKE '%B%' THEN
                      'N'
                     ELSE
                      'Y'
                   end) iSVCBSSell
              FROM (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist) od,
                   bondrepo rp1,
                   bondrepo rp2,
                   sbsecurities sb,
                   cfmast cf,
                   afmast af,
                   brgrp br
             WHERE od.orderid = rp1.orderid
               AND rp1.refrepoacctno = rp2.repoacctno(+)
               AND od.codeid = sb.codeid
               AND od.afacctno = af.acctno
               AND af.custid = cf.custid
               AND cf.brid = br.brid
               AND od.txdate >= to_date(F_DATE, 'DD/MM/RRRR')
               AND od.txdate <= to_date(T_DATE, 'DD/MM/RRRR')) rep;
  /*END IF;*/
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
