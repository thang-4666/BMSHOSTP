SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3002" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                    IN       VARCHAR2,
   BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                 IN       VARCHAR2,
   T_DATE                 IN       VARCHAR2,
   E_EXCHANGE             IN       VARCHAR2,
   BASKET_ID              IN       VARCHAR2
  )
IS

--
-- BAO CAO DANH MUC CHUNG KHOAN THUC HIEN GIAO DICH KI QUY
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
-- QUOCTA      27-10-2011           CREATED
--

   CUR                      PKG_REPORT.REF_CURSOR;
   V_STROPTION              VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID                VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   v_FromDate               DATE;
   v_ToDate                 DATE;
   v_CurrDate               DATE;
   v_EXCHANGE               VARCHAR2(100);

   V_BASKET_ID              VARCHAR2(100);

BEGIN

   V_STROPTION              := OPT;

  IF V_STROPTION = 'A' THEN
      V_STRBRID    := '%';
  ELSIF V_STROPTION = 'B' THEN
      V_STRBRID    := substr(BRID,1,2) || '__' ;
  else
      V_STRBRID    := BRID;
  END IF;

  v_FromDate                := TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  v_ToDate                  := TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  v_EXCHANGE                := E_EXCHANGE;

    V_BASKET_ID    := upper(REPLACE(TRIM(BASKET_ID),' ','_'));
  /*IF (BASKET_ID <> 'ALL' OR BASKET_ID <> '')
  THEN
         V_BASKET_ID    := REPLACE(TRIM(BASKET_ID),' ','_');
  ELSE
         V_BASKET_ID    :=    '%';
  END IF;*/

  SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
  INTO   v_CurrDate
  FROM   SYSVAR
  WHERE  grname = 'SYSTEM' AND varname = 'CURRDATE';

OPEN PV_REFCURSOR
FOR
    SELECT  v_EXCHANGE EXCHANGE, MST.codeid, MST.SYMBOL,
        (CASE WHEN MST.CODEID_FR is not null then mst.symbol ELSE NULL END) SB_FR,
        (CASE WHEN MST.CODEID_d is not null then mst.symbol ELSE NULL END) SB_DEL,
        (CASE WHEN MST.CODEID_m is not null then mst.symbol ELSE NULL END) SB_ADD,
        (CASE WHEN MST.CODEID_To  is not null then mst.symbol ELSE NULL END) SB_TO,
        (100-nvl(sec.MRRATIOLOAN,100)) isMRRATIOLOAN
    FROM
        (
            select sb.codeid, sb.symbol, max(CODEID_FR) CODEID_FR, max(CODEID_d) CODEID_d, max(CODEID_m) CODEID_m, max(CODEID_To) CODEID_To
            from
                (
                    ----dong trong ky.
                    select CODEID, null CODEID_FR, CODEID CODEID_d, null CODEID_m, null CODEID_To
                    from securities_riskhist
                    where to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),'dd/mm/rrrr') >= v_FromDate
                        and to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),'dd/mm/rrrr') <= v_ToDate
                    union all
                    ----them trong ky.
                    select CODEID, null CODEID_FR, null CODEID_d, CODEID CODEID_m, null CODEID_To
                    from
                    (
                        SELECT SE.CODEID, SE.ISMARGINALLOW, nvl(OPENdate,v_CurrDate) OPENdate FROM SECURITIES_RISK SE
                        UNION ALL
                        SELECT SE.CODEID, SE.ISMARGINALLOW, nvl(OPENdate,v_CurrDate) OPENdate FROM SECURITIES_RISKHIST SE
                    )
                    where OPENdate >= v_FromDate
                        and OPENdate <= v_ToDate
                    union all
                    ------ma ck ky quy dau ky.
                    select CODEID, CODEID CODEID_FR, null CODEID_d, null  CODEID_m, null CODEID_To
                    from
                    (
                        SELECT SE.CODEID, SE.ISMARGINALLOW, v_FromDate+1 BACKUPDT, nvl(OPENdate,v_CurrDate) OPENdate FROM SECURITIES_RISK SE
                        UNION ALL
                        SELECT SE.CODEID, SE.ISMARGINALLOW, to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),'dd/mm/rrrr') BACKUPDT, nvl(OPENdate,v_CurrDate) OPENdate
                        FROM SECURITIES_RISKHIST SE
                    )
                    where OPENdate <= v_FromDate
                        and BACKUPDT > v_FromDate
                    union all
                    ------ma ck ky quy cuoi ky.
                    select CODEID, null CODEID_FR, null CODEID_d, null  CODEID_m, CODEID CODEID_To
                    from
                    (
                        SELECT SE.CODEID, SE.ISMARGINALLOW, v_ToDate+1 BACKUPDT, nvl(OPENdate,v_CurrDate) OPENdate FROM SECURITIES_RISK SE
                        UNION ALL
                        SELECT SE.CODEID, SE.ISMARGINALLOW, to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),'dd/mm/rrrr') BACKUPDT, nvl(OPENdate,v_CurrDate) OPENdate
                        FROM SECURITIES_RISKHIST SE
                    )
                    where OPENdate <= v_ToDate
                        and BACKUPDT > v_ToDate
                ) mst, sbsecurities sb
                where mst.codeid = sb.codeid
                    AND SB.TRADEPLACE LIKE V_EXCHANGE
                group by sb.symbol, sb.codeid
        ) MST,
        (
            select symbol, MRRATIOLOAN from secbasket where upper(basketid) = V_BASKET_ID
            union all
            select DISTINCT symbol, dfrate MRRATIOLOAN from dfbasket where upper(basketid) = V_BASKET_ID
        ) sec
    WHERE MST.SYMBOL = SEC.SYMBOL----(+)
    ORDER BY MST.SYMBOL
;


EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
