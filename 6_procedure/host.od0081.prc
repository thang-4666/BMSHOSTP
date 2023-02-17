SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0081" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
    T_DATE         IN       VARCHAR2,
   LOAI      IN       VARCHAR2
 )
IS
--

-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2 (4);


   V_LOAI        varchar2(20);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   -- GET REPORT'S PARAMETERS

      IF (LOAI <> 'ALL' OR LOAI <> '')
   THEN
      V_LOAI :=  LOAI;
   ELSE
      V_LOAI := '%%';
   END IF;

   -- GET REPORT'S DATA

OPEN  PV_REFCURSOR FOR
SELECT * FROM (
      SELECT TXDATE,SUM(AMT) AMT, SUM(PAIDAMT) PAID, GREATEST(SUM(NVL(AMT,0))-SUM(NVL(PAIDAMT,0)),0) SO_DU,'UT' LOAI
      FROM (SELECT * FROM ADSCHD UNION ALL SELECT * FROM ADSCHDHIST)
      WHERE RRTYPE='C'
            AND TXDATE >=to_date(F_DATE,'DD/MM/YYYY')
            AND TXDATE<=to_date(T_DATE,'DD/MM/YYYY')
      GROUP BY TXDATE

UNION ALL

      SELECT TXDATE,SUM(AMT) AMT, SUM(PAIDAMT) PAID, GREATEST(SUM(NVL(AMT,0))-SUM(NVL(PAIDAMT,0)),0) SO_DU,'UT3' LOAI
      FROM (SELECT * FROM ADSCHD UNION ALL SELECT * FROM ADSCHDHIST)
      WHERE RRTYPE='B'
            AND TXDATE >=to_date(F_DATE,'DD/MM/YYYY')
            AND TXDATE<=to_date(T_DATE,'DD/MM/YYYY')
      GROUP BY TXDATE

UNION ALL

      SELECT LOG.TXDATE,SUM(LOG.NML) AMT,SUM(NVL(A.PAID,0)) PAIDAMT, GREATEST(SUM(NVL(LOG.NML,0))-NVL(A.PAID,0),0) SO_DU,'MR' LOAI
      FROM VW_LNSCHD_ALL LN, VW_LNSCHDLOG_ALL LOG ,
           (SELECT LOG.TXDATE,SUM(LOG.PAID) PAID FROM VW_LNSCHD_ALL LN, VW_LNSCHDLOG_ALL LOG
            WHERE LOG.AUTOID=LN.AUTOID
                  AND LOG.TXDATE >=to_date(F_DATE,'DD/MM/YYYY')
                  AND LOG.TXDATE<=to_date(T_DATE,'DD/MM/YYYY')
                  AND LOG.NML<0 AND LOG.PAID>0
                  GROUP BY LOG.TXDATE

                  ) A
      WHERE LOG.AUTOID=LN.AUTOID
            AND LOG.TXDATE >=to_date(F_DATE,'DD/MM/YYYY')
            AND LOG.TXDATE<=to_date(T_DATE,'DD/MM/YYYY')
            AND LOG.NML>0
            AND LOG.TXDATE=A.TXDATE(+)
      GROUP BY LOG.TXDATE,A.PAID
      )
      WHERE LOAI LIKE V_LOAI
ORDER BY TXDATE,loai

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
