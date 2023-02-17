SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od3001 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_REGTYPE     IN      VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_AFACCTNO       VARCHAR2 (20);
   V_CUSTODYCD       VARCHAR2 (20);
   v_TLID varchar2(10);
   V_CUR_DATE DATE ;
   V_FDATE  DATE;
   V_TODATE DATE;
   V_REGTYPE       VARCHAR2(10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS
   V_AFACCTNO := NVL(PV_AFACCTNO,'ALL');

   IF V_AFACCTNO = 'ALL'  THEN
        V_AFACCTNO:= '%';
   END IF;

   V_CUSTODYCD:= NVL(PV_CUSTODYCD,'ALL');
   IF V_CUSTODYCD = 'ALL'  THEN
        V_CUSTODYCD := '%';
   END IF;
   V_FDATE  := TO_DATE(F_DATE ,'DD/MM/YYYY');
   V_TODATE := TO_DATE(T_DATE ,'DD/MM/YYYY');

   SELECT TO_DATE(VARVALUE ,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

    IF PV_REGTYPE = 'ALL' THEN
        V_REGTYPE := '%%';
    ELSE
        V_REGTYPE := PV_REGTYPE;
    END IF;

   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
        SELECT TO_CHAR(TXDATE,'DD/MM/YYYY') TXDATE, CUSTODYCD, AFACCTNO, FULLNAME, CAREBYID, REGTYPE, BLACCTNO
    FROM
    (
        SELECT blr.regdate TXDATE, cf.CUSTODYCD, blr.AFACCTNO, cf.FULLNAME,  tlg.grpid CAREBYID, 'R' REGTYPE,
            BLR.BLACCTNO
        FROM bl_register blr, cfmast cf, tlgroups tlg,afmast af
        WHERE blr.afacctno = af.acctno AND af.custid = cf.custid
            AND cf.careby = tlg.grpid
            AND blr.regdate >= V_FDATE
            AND blr.regdate <= V_TODATE
            AND cf.custodycd LIKE V_CUSTODYCD
            AND blr.afacctno LIKE V_AFACCTNO
        UNION ALL
        SELECT blr.clsdate TXDATE, cf.CUSTODYCD, blr.AFACCTNO, cf.FULLNAME, tlg.grpid CAREBYID, 'C' REGTYPE,
            BLR.BLACCTNO
        FROM bl_register blr, cfmast cf, tlgroups tlg, afmast af
        WHERE blr.afacctno = af.acctno AND af.custid = cf.custid
            AND cf.careby = tlg.grpid AND blr.clsdate IS NOT NULL
            AND blr.clsdate >= V_FDATE
            AND blr.clsdate <= V_TODATE
            AND cf.custodycd LIKE V_CUSTODYCD
            AND blr.afacctno LIKE V_AFACCTNO
    ) BL
    WHERE BL.regtype LIKE V_REGTYPE
    ORDER BY bl.regtype DESC, bl.txdate, bl.custodycd;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
 
 
 
/
