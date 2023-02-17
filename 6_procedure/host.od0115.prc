SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0115 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   SEARCHDATE                   IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- THONG TIN TTBT
-- PERSON      DATE    COMMENTS
-- MAI.NGUYENPHUONG   11-AUG-22  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_CUR_DATE       DATE;
   V_DATE           DATE;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   SELECT TO_DATE(VARVALUE ,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';
   V_DATE := to_date(SEARCHDATE,'DD/MM/RRRR');


   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
          SELECT sts.txdate, max(sts.cleardate) cleardate, CASE WHEN sb.sectype IN ('003','006','012') THEN '222' ELSE '111' END sectype,
                 COUNT(DISTINCT cf.custodycd) cfnumber,
                 sum(CASE WHEN sts.DUETYPE IN ('RS') THEN sts.QTTY ELSE 0 END) BUYQTTY,
                 sum(CASE WHEN sts.DUETYPE IN ('SS') THEN sts.QTTY ELSE 0 END) SELLQTTY,
                 sum(CASE WHEN sts.DUETYPE IN ('SM') THEN sts.AMT ELSE 0 END) BUYAMT,
                 sum(CASE WHEN sts.DUETYPE IN ('RM') THEN sts.AMT ELSE 0 END) SELLAMT
            FROM vw_stschd_all sts, afmast af, cfmast cf, sbsecurities sb
           WHERE sts.afacctno = af.acctno
             AND af.custid = cf.custid
             AND sts.codeid = sb.codeid
             AND sts.txdate = V_DATE
             AND sts.txdate <= V_CUR_DATE
             AND sts.STATUS = 'C'
             AND cf.custatcom = 'Y'
             AND sts.deltd <> 'Y'
             AND SUBSTR(cf.custodycd,4,1) <> 'P'
           GROUP BY sts.txdate,CASE WHEN sb.sectype IN ('003','006','012') THEN '222' ELSE '111' END
           ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
                                                     -- PROCEDURE
/
