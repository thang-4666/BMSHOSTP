SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0005" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   STATUS         IN       VARCHAR2
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
    V_STRSTATUS    VARCHAR2 (20);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    IF (STATUS <> 'ALL')
   THEN
      V_STRSTATUS := STATUS;
   ELSE
      V_STRSTATUS := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

--Tinh ngay nhan thanh toan bu tru


OPEN PV_REFCURSOR
   FOR
        SELECT cam.camastid, se.symbol, cam.REPORTDATE,  cam.RIGHTOFFRATE, cam.ROUNDTYPE, cam.FRDATETRANSFER, cam.TODATETRANSFER,
                cam.EXPRICE, cam.actiondate, A1.cdcontent status, A0.cdcontent ROUNDTYPEdes, cam.duedate,
                sb2.symbol tocodeid
        FROM  sbsecurities se, camast cam, allcode A0, Allcode A1, sbsecurities sb2
        WHERE cam.codeid = se.codeid
        AND sb2.codeid = nvl(cam.tocodeid,cam.codeid)
        AND a0.CDTYPE = 'CA' AND a0.CDNAME = 'ROUNDTYPE' AND a0.CDVAL = cam.ROUNDTYPE
        AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = cam.STATUS
        AND cam.catype = '014'
        AND cam.REPORTDATE >= to_date(F_DATE,'DD/MM/YYYY')
        AND cam.REPORTDATE <= to_date(T_DATE,'DD/MM/YYYY')
        AND cam.status LIKE V_STRSTATUS
 ORDER BY      cam.duedate,cam.camastid

--    AND cam.camastid LIKE V_STRCACODE
  ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
