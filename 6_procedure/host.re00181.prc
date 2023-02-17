SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE RE00181 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
 )
IS

-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Ngoc.vu      10/11/2016 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_INBRID           VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STRTLID        VARCHAR2(6);

   v_fromdate        date;
   v_todate          date;

BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


    v_fromdate       := to_date(F_DATE,'dd/mm/rrrr');
    v_todate         := to_date(T_DATE,'dd/mm/rrrr');



     OPEN PV_REFCURSOR
     FOR

     SELECT TRADINGDATE,TTHOAMT,TTHAAMT,TTUPCOMAMT,VCBSHOAMT,VCBSHAAMT,VCBSUPCOMAMT,
          VSD, VCBS, ROUND(DECODE(VSD,0,0,VCBS/(VSD*2)),4)*100 TP,
          ROUND(DECODE(TTHOAMT,0,0,VCBSHOAMT/(TTHOAMT*2)),4)*100 TPHo,
          ROUND(DECODE(TTHAAMT,0,0,VCBSHAAMT/(TTHAAMT*2)),4)*100 TPHA,
           ROUND(DECODE(TTUPCOMAMT,0,0,VCBSUPCOMAMT/(TTUPCOMAMT*2)),4)*100 TPUPCOM
          FROM(
            SELECT VSD.TRADINGDATE, round(VSD.TTHOAMT/1000,4) TTHOAMT,
                   round(VSD.TTHAAMT/1000,4) TTHAAMT,
                   round(VSD.TTUPCOMAMT/1000,4) TTUPCOMAMT,
                   round(NVL(VCBS.VCBSHOAMT,0)/1000,4) VCBSHOAMT,
                   round(NVL(VCBS.VCBSHAAMT,0)/1000,4) VCBSHAAMT,
                   round(NVL(VCBS.VCBSUPCOMAMT,0)/1000,4) VCBSUPCOMAMT,
                   round(VSD.TTHOAMT/1000,4)+round(VSD.TTHAAMT/1000,4)+round(VSD.TTUPCOMAMT/1000,4) VSD,
                   round(NVL(VCBS.VCBSHOAMT,0)/1000,4)+ round(NVL(VCBS.VCBSHAAMT,0)/1000,4)+
                   round(NVL(VCBS.VCBSUPCOMAMT,0)/1000,4) VCBS
            FROM (
                SELECT TRADINGDATE, SUM(DECODE(MARKETID,'10',NVL(TOTALVOLUME,0),0)) TTHOAMT,
                       SUM(DECODE(MARKETID,'02',NVL(TOTALVOLUME,0),0)) TTHAAMT,
                       SUM(DECODE(MARKETID,'04',NVL(TOTALVOLUME,0),0)) TTUPCOMAMT
                FROM
                      (SELECT TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') TRADINGDATE, NVL(TO_NUMBER(HI.totalvalue),0) - NVL(TO_NUMBER(HI.PT_TOTAL_VALUE),0) TOTALVOLUME,
                              HI.MARKETID, NVL(HI.MARKETCODE,'') MARKETCODE
                      FROM MARKETINFOR_HIST HI
                      WHERE HI.MARKETID IN ('10','02','04')
                            and TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') BETWEEN v_fromdate AND v_todate
                            AND HI.TRADINGDATE IS NOT NULL

                      UNION ALL

                      SELECT TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') TRADINGDATE, NVL(TO_NUMBER(HI.totalvalue),0) - NVL(TO_NUMBER(HI.PT_TOTAL_VALUE),0) TOTALVOLUME,
                             HI.MARKETID, NVL(HI.MARKETCODE,'') MARKETCODE
                      FROM MARKETINFOR HI
                      WHERE HI.MARKETID IN ('10','02','04')
                            and TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') BETWEEN v_fromdate AND v_todate
                            AND HI.TRADINGDATE IS NOT NULL
                      ) GROUP BY TRADINGDATE
                ) VSD,

                (SELECT OD.TXDATE,
                        SUM(DECODE(SB.tradeplace,'001',OD.EXECAMT,0)) VCBSHOAMT,
                        SUM(DECODE(SB.tradeplace,'002',OD.EXECAMT,0)) VCBSHAAMT,
                        SUM(DECODE(SB.tradeplace,'005',OD.EXECAMT,0)) VCBSUPCOMAMT
                FROM VW_ODMAST_ALL OD, SBSECURITIES SB
                WHERE SB.tradeplace IN ('001','002','005') and sb.SECTYPE in ('001')
                        AND OD.TXDATE BETWEEN v_fromdate AND v_todate
                        AND OD.EXECAMT>0 AND OD.CODEID=SB.CODEID
                        and od.MATCHTYPE<>'P'
                        GROUP BY OD.TXDATE
                ) VCBS
            WHERE VSD.TRADINGDATE=VCBS.TXDATE(+)

            UNION

             SELECT VCBS.TXDATE TRADINGDATE, round(NVL(VSD.TTHOAMT,0)/1000,4) TTHOAMT,
                   round(NVL(VSD.TTHAAMT,0)/1000,4) TTHAAMT,
                   round(NVL(VSD.TTUPCOMAMT,0)/1000,4) TTUPCOMAMT,
                   round(NVL(VCBS.VCBSHOAMT,0)/1000,4) VCBSHOAMT,
                   round(NVL(VCBS.VCBSHAAMT,0)/1000,4) VCBSHAAMT,
                   round(NVL(VCBS.VCBSUPCOMAMT,0)/1000,4) VCBSUPCOMAMT,
                   round(NVL(VSD.TTHOAMT,0)/1000,4)+round(NVL(VSD.TTHAAMT,0)/1000,4)+round(NVL(VSD.TTUPCOMAMT,0)/1000,4) VSD,
                   round(NVL(VCBS.VCBSHOAMT,0)/1000,4)+ round(NVL(VCBS.VCBSHAAMT,0)/1000,4)+
                   round(NVL(VCBS.VCBSUPCOMAMT,0)/1000,4) VCBS
            FROM (
                SELECT TRADINGDATE, SUM(DECODE(MARKETID,'10',NVL(TOTALVOLUME,0),0)) TTHOAMT,
                       SUM(DECODE(MARKETID,'02',NVL(TOTALVOLUME,0),0)) TTHAAMT,
                       SUM(DECODE(MARKETID,'04',NVL(TOTALVOLUME,0),0)) TTUPCOMAMT
                FROM
                      (SELECT TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') TRADINGDATE, NVL(TO_NUMBER(HI.totalvalue),0)- NVL(TO_NUMBER(HI.PT_TOTAL_VALUE),0) TOTALVOLUME,
                              HI.MARKETID, NVL(HI.MARKETCODE,'') MARKETCODE
                      FROM MARKETINFOR_HIST HI
                      WHERE HI.MARKETID IN ('10','02','04')
                            and TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') BETWEEN v_fromdate AND v_todate
                            AND HI.TRADINGDATE IS NOT NULL

                      UNION ALL

                      SELECT TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') TRADINGDATE, NVL(TO_NUMBER(HI.totalvalue),0)- NVL(TO_NUMBER(HI.PT_TOTAL_VALUE),0) TOTALVOLUME,
                             HI.MARKETID, NVL(HI.MARKETCODE,'') MARKETCODE
                      FROM MARKETINFOR HI
                      WHERE HI.MARKETID IN ('10','02','04')
                            and TO_DATE(HI.TRADINGDATE,'DD/MM/RRRR') BETWEEN v_fromdate AND v_todate
                            AND HI.TRADINGDATE IS NOT NULL
                      ) GROUP BY TRADINGDATE
                ) VSD,

                (SELECT OD.TXDATE,
                        SUM(DECODE(SB.tradeplace,'001',OD.EXECAMT,0)) VCBSHOAMT,
                        SUM(DECODE(SB.tradeplace,'002',OD.EXECAMT,0)) VCBSHAAMT,
                        SUM(DECODE(SB.tradeplace,'005',OD.EXECAMT,0)) VCBSUPCOMAMT,
                        sum(od.FEEACR) FEEACR
                FROM VW_ODMAST_ALL OD, SBSECURITIES SB
                WHERE SB.tradeplace IN ('001','002','005') and sb.SECTYPE in ('001')
                        AND OD.TXDATE BETWEEN v_fromdate AND v_todate
                        AND OD.EXECAMT>0 AND OD.CODEID=SB.CODEID
                        and od.MATCHTYPE<>'P'
                        GROUP BY OD.TXDATE
                ) VCBS
            WHERE VCBS.TXDATE=VSD.TRADINGDATE(+)


            )  ORDER BY TRADINGDATE DESC;


EXCEPTION
   WHEN OTHERS
   THEN

    OPEN PV_REFCURSOR
  FOR
  SELECT 0 A FROM DUAL WHERE 0=1;
End;
 
 
 
 
/
