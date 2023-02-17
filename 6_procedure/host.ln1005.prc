SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN1005" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PURPOSE: BAO CAO DANH SACH HOP DONG MARGIN DUOC GIA HAN
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- PHUNH        11-APR-2012 CREATED
-- ---------    ------      -------------------------------------------
    V_F_DATE DATE;
    V_T_DATE DATE;
BEGIN
    -- GET REPORT'S PARAMETERS
    V_F_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_T_DATE := TO_DATE(T_DATE,'DD/MM/YYYY');

    -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
        SELECT  cf.custodycd, cf.fullname, af.acctno, to_char(rpt.lnschdid) lnschdid, to_char(rpt.txdate,'DD/MM/RRRR') txdate,
                to_char(rpt.rlsdate,'DD/MM/RRRR') rlsdate, to_char(rpt.overduedate,'DD/MM/RRRR') overduedate, rpt.lnprinamt, rpt.lnintamt, rpt.lnfeeamt
          FROM  afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, rpt_change_term_4_margin rpt
         WHERE  af.acctno = rpt.afacctno AND af.custid = cf.custid
                AND rpt.txdate >= V_F_DATE
                AND rpt.txdate <= V_T_DATE;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
