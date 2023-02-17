SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca0033 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   PV_CUSTODYCD        IN       VARCHAR2,
   PV_AFACCTNO         IN       VARCHAR2,
   PV_TLTXCD               IN       VARCHAR2,
   CACODE                    IN       VARCHAR2,
   LOAI                          IN       VARCHAR2
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
    V_STRACCTNO    VARCHAR2 (20);
    V_STRCUSTODYCD     VARCHAR2 (20);
    V_STRTLTXCD  VARCHAR2 (40);
    v_cacode VARCHAR2 (200);
    v_loai   varchar2(100);
BEGIN
   V_STROPTION := OPT;



   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


   IF (PV_AFACCTNO <> 'ALL')
   THEN
      V_STRACCTNO := PV_AFACCTNO;
   ELSE
      V_STRACCTNO := '%%';
   END IF;



   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_STRCUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   IF (PV_TLTXCD <> 'ALL')
   THEN
      V_STRTLTXCD := PV_TLTXCD;
   ELSE
      V_STRTLTXCD := '%%';
   END IF;

      IF (CACODE <> 'ALL')
   THEN
      V_CACODE := CACODE;
   ELSE
      V_CACODE := '%%';
   END IF;

      IF (LOAI <> 'ALL')
   THEN
      V_LOAI := LOAI;
   ELSE
      V_LOAI := '%%';
   END IF;
   -- GET REPORT'S PARAMETERS

--TINH NGAY NHAN THANH TOAN BU TRU


OPEN PV_REFCURSOR
   FOR
         SELECT tl.txdate,tl.txnum,ca.camastid,sb.codeid,ca.balance,SUBSTR(optseacctnocr,1,10) optseacctnocr,SUBSTR(optseacctnodr,1,10) optseacctnodr,custodycdcr,custodycddr,sb.symbol,tl.tltxcd,tltx.txdesc TLTXDESC,
          TL.txdesc,ca.AMT, ca.QTTY
          FROM catrflog ca,sbsecurities sb, vw_tllog_all tl, tltx,camast cas
          WHERE nvl(ca.optcodeid,ca.codeid) = sb.codeid
          AND ca.txdate = tl.txdate
          AND ca.txnum = tl.txnum
          AND tl.tltxcd = tltx.tltxcd
          AND ca.camastid = cas.camastid
          and ca.camastid like V_CACODE
          and (case when cas.catype='014' then 'Y' else 'N' end) like V_LOAI
          AND tl.busdate BETWEEN to_date(F_DATE,'dd/mm/yyyy') AND to_date(t_date ,'dd/mm/yyyy')
          AND TL.tltxcd LIKE V_STRTLTXCD
          AND (custodycdcr LIKE V_STRCUSTODYCD OR custodycdDR LIKE V_STRCUSTODYCD)
          AND ( SUBSTR(optseacctnocr,1,10) LIKE V_STRACCTNO OR SUBSTR(optseacctnodr,1,10) LIKE V_STRACCTNO)
           ;
/*SELECT tl.txdate,tl.txnum,ca.camastid,sb.codeid,ca.balance,SUBSTR(optseacctnocr,1,10) optseacctnocr,SUBSTR(optseacctnodr,1,10) optseacctnodr,custodycdcr,custodycddr,sb.symbol,tl.tltxcd,tltx.txdesc TLTXDESC,
TL.txdesc, cas.amt, cas.qtty
FROM catrflog ca,sbsecurities sb, vw_tllog_all tl, tltx,caschd cas
WHERE nvl(ca.optcodeid,ca.codeid) = sb.codeid
AND ca.txdate = tl.txdate
AND ca.txnum = tl.txnum
AND tl.tltxcd = tltx.tltxcd
AND ca.camastid = cas.camastid
AND tl.busdate BETWEEN to_date(F_DATE,'dd/mm/yyyy') AND to_date(t_date ,'dd/mm/yyyy')
AND TL.tltxcd LIKE V_STRTLTXCD
AND (custodycdcr LIKE V_STRCUSTODYCD OR custodycdDR LIKE V_STRCUSTODYCD)
AND ( SUBSTR(optseacctnocr,1,10) LIKE V_STRACCTNO OR SUBSTR(optseacctnodr,1,10) LIKE V_STRACCTNO)
 ;*/


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
