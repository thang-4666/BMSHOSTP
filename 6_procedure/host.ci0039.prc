SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0039" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE        IN       VARCHAR2,
   T_DATE         IN       VARCHAR2

 )
IS

--
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (5);

   V_STRISBRID      VARCHAR2 (5);
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_CURR_DATE   DATE;


BEGIN


    V_STROPT := OPT;

    IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
    THEN
      V_STRBRID := pv_BRID;
    ELSE
      V_STRBRID := '%%';
    END IF;
    -- GET REPORT'S PARAMETERS


        SELECT to_date(varvalue,'DD/MM/RRRR') INTO V_CURR_DATE FROM sysvar WHERE varname = 'CURRDATE';
        V_FROMDATE := TO_DATE(F_DATE,'DD/MM/RRRR');
        V_TODATE := TO_DATE(T_DATE,'DD/MM/RRRR');

   -- GET REPORT'S DATA

    OPEN  PV_REFCURSOR FOR
        SELECT V_FROMDATE FROMDATE,V_TODATE TODATE,V_CURR_DATE CURRDATE,NVL(SUM(AMT),0) AMT,
			NVL(SUM(PAIDAMT),0) PAIDAMT,NVL(SUM(BANKFEE),0) BANKFEE, NVL(SUM(FEEAMT),0) FEEAMT, NVL(SUM(VATAMT),0) VATAMT
        FROM
            (SELECT TXNUM, TXDATE, AMT PAIDAMT, FEEADVB BANKFEE,FEEADVC VATAMT,FEEADV FEEAMT,AMT-FEEADV  AMT
            FROM VW_ADVSRESLOG_ALL
            WHERE  TXDATE >= V_FROMDATE
            and TXDATE <= V_TODATE
            AND DELTD<>'Y'
            AND RRTYPE ='B')                
     ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
