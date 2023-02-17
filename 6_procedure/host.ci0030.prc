SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0030" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO TINH PHI LUU KY CHO TUNG TAI KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUYETKD    29-05-2011  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2  (5);
   V_STRBRID       VARCHAR2  (4);
   V_STRCUSTODYCD   VARCHAR2 (20);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
  IF (CUSTODYCD <> 'ALL' or CUSTODYCD <> '')
   THEN
      V_STRCUSTODYCD :=  CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   -- GET REPORT'S DATA

   OPEN PV_REFCURSOR
       FOR

SELECT
cf.custodycd custodycd,
cf.fullname,
ci.afacctno,
ci.frdate,
ci.todate,
ci.deporate,
ci.depoqtty,
Decode(depotype,'T','Trai phieu','Co phieu/CC Quy') depotype ,
ci.cidepofeeacr, 0 FEELK_DATRA, 0 FEE_LK, 0 FEE_LK_KT
from cidepofeetran ci , afmast af ,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
Where ci.afacctno = af.acctno
and af.custid = cf.custid
and cf.custodycd like V_STRCUSTODYCD
and ci.todate >= to_date(F_DATE,'dd/mm/yyyy')
and ci.todate <= to_date(T_DATE,'dd/mm/yyyy')
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
