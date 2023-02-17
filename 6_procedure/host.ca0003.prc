SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0003" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   AFACCTNO       IN       VARCHAR2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRCACODE    VARCHAR2 (20);
   V_STRAFACCTNO    VARCHAR2 (20);
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF (CACODE <> 'ALL')
   THEN
      V_STRCACODE := CACODE;
   ELSE
      V_STRCACODE := '%%';
   END IF;

     IF (AFACCTNO <> 'ALL')
   THEN
       V_STRAFACCTNO := AFACCTNO;
   ELSE
       V_STRAFACCTNO := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

--Tinh ngay nhan thanh toan bu tru


OPEN PV_REFCURSOR
   FOR
    SELECT af.acctno, se.symbol, cam.REPORTDATE, cf.custodycd, cf.fullname, cf.MOBILE, (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE, cas.balance SLCKSH, cas.Qtty SLCKDN,
       cam.DEVIDENTSHARES, A0.cdcontent Catype,  A1.cdcontent status, cam.camastid, cas.AMT, af.status status_af
    FROM vw_caschd_all cas, sbsecurities se, vw_camast_all cam, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode A0, Allcode A1
    WHERE cas.codeid = se.codeid
    AND cam.camastid = cas.camastid
    AND cas.afacctno = af.acctno
    AND af.custid = cf.custid
    AND a0.CDTYPE = 'CA' AND a0.CDNAME = 'CATYPE' AND a0.CDVAL = cam.CATYPE
    AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = cas.STATUS
    and cas.deltd<>'Y'
    AND cam.camastid LIKE V_STRCACODE
    and cas.afacctno like V_STRAFACCTNO
    ORDER BY af.acctno
  ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
