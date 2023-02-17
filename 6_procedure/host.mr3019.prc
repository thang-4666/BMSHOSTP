SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3019"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     E_EXCHANGE   IN VARCHAR2
                                     
                                     ) IS
  --
  --ngoc.vu edit 01/09/2016
  -- ---------   ------  -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_INBRID    VARCHAR2(4);
  V_CFROMDATE DATE;
  V_CTODATE   DATE;
  /* V_I_DATE   DATE;
  V_ID DATE;*/

  v_fromdate date;
  v_todate   date;
  v_EXCHANGE VARCHAR2(100);
  v_CurrDate DATE;

BEGIN
  V_STROPTION := upper(OPT);
  V_INBRID    := pv_BRID;

  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSE
    if (V_STROPTION = 'B') then
      select brgrp.mapid
        into V_STRBRID
        from brgrp
       where brgrp.brid = V_INBRID;
    else
      V_STRBRID := V_INBRID;
    end if;
  END IF;
  -- GET REPORT'S PARAMETERS

  -- V_ID:= TO_DATE(I_DATE,'DD/MM/YYYY');

  v_fromdate := TO_DATE(F_DATE, 'DD/MM/RRRR');
  v_todate   := TO_DATE(T_DATE, 'DD/MM/RRRR');
  v_EXCHANGE := E_EXCHANGE;

  SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
    INTO v_CurrDate
    FROM SYSVAR
   WHERE grname = 'SYSTEM'
     AND varname = 'CURRDATE';

  /*   IF TO_NUMBER(SUBSTR(I_DATE,4,2)) <= 12 THEN
          V_CFROMDATE := TO_DATE('01/' || SUBSTR(I_DATE,4,2) || '/' || SUBSTR(I_DATE,7,4),'DD/MM/RRRR');
      ELSE
          V_CFROMDATE := TO_DATE('31/12/9999','DD/MM/RRRR');
      END IF;
  
        SELECT TO_DATE(V_CFROMDATE,'DD/MM/YYYY')-1 INTO V_CTODATE FROM DUAL;
        SELECT  TO_DATE('01/' || SUBSTR(V_CTODATE,4,2) || '/' || SUBSTR(V_CTODATE,7,4),'DD/MM/RRRR') INTO V_I_DATE FROM DUAL;
  */
  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR FOR
  
    SELECT v_EXCHANGE EXCHANGE,
           MST.codeid,
           MST.SYMBOL,
           (CASE
             WHEN MST.CODEID_FR is not null then
              mst.symbol
             ELSE
              NULL
           END) SB_FR,
           (CASE
             WHEN MST.CODEID_d is not null then
              mst.symbol
             ELSE
              NULL
           END) SB_DEL,
           (CASE
             WHEN MST.CODEID_m is not null then
              mst.symbol
             ELSE
              NULL
           END) SB_ADD,
           (CASE
             WHEN MST.CODEID_To is not null then
              mst.symbol
             ELSE
              NULL
           END) SB_TO
      FROM (select sb.codeid,
                   sb.symbol,
                   max(CODEID_FR) CODEID_FR,
                   max(CODEID_d) CODEID_d,
                   max(CODEID_m) CODEID_m,
                   max(CODEID_To) CODEID_To
              from (
                    ----dong trong ky.
                    select CODEID,
                            null   CODEID_FR,
                            CODEID CODEID_d,
                            null   CODEID_m,
                            null   CODEID_To
                      from securities_riskhist
                     where to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),
                                   'dd/mm/rrrr') >= v_FromDate
                       and to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),
                                   'dd/mm/rrrr') <= v_ToDate
                    union all
                    ----them trong ky.
                    select CODEID,
                            null   CODEID_FR,
                            null   CODEID_d,
                            CODEID CODEID_m,
                            null   CODEID_To
                      from (SELECT SE.CODEID,
                                    SE.ISMARGINALLOW,
                                    nvl(OPENdate,
                                        TO_DATE('01/01/1900', 'dd/mm/rrrr')) OPENdate
                               FROM SECURITIES_RISK SE
                              where status = 'A'
                                 or (status = 'P' and pstatus is not null)
                             UNION ALL
                             SELECT SE.CODEID,
                                    SE.ISMARGINALLOW,
                                    nvl(OPENdate,
                                        TO_DATE('01/01/1900', 'dd/mm/rrrr')) OPENdate
                               FROM SECURITIES_RISKHIST SE)
                     where OPENdate >= v_FromDate
                       and OPENdate <= v_ToDate
                    union all
                    ------ma ck ky quy dau ky.
                    select CODEID,
                            CODEID CODEID_FR,
                            null   CODEID_d,
                            null   CODEID_m,
                            null   CODEID_To
                      from (SELECT SE.CODEID,
                                    SE.ISMARGINALLOW,
                                    v_FromDate + 1 BACKUPDT,
                                    nvl(OPENdate,
                                        TO_DATE('01/01/1900', 'dd/mm/rrrr')) OPENdate
                               FROM SECURITIES_RISK SE
                              where status = 'A'
                                 or (status = 'P' and pstatus is not null)
                             UNION ALL
                             SELECT SE.CODEID,
                                    SE.ISMARGINALLOW,
                                    to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),
                                            'dd/mm/rrrr') BACKUPDT,
                                    nvl(OPENdate,
                                        TO_DATE('01/01/1900', 'dd/mm/rrrr')) OPENdate
                               FROM SECURITIES_RISKHIST SE)
                     where OPENdate <= v_FromDate
                       and BACKUPDT > v_FromDate
                    union all
                    ------ma ck ky quy cuoi ky.
                    select CODEID,
                            null   CODEID_FR,
                            null   CODEID_d,
                            null   CODEID_m,
                            CODEID CODEID_To
                      from (SELECT SE.CODEID,
                                    SE.ISMARGINALLOW,
                                    v_ToDate + 1 BACKUPDT,
                                    nvl(OPENdate,
                                        TO_DATE('01/01/1900', 'dd/mm/rrrr')) OPENdate
                               FROM SECURITIES_RISK SE
                              where status = 'A'
                                 or (status = 'P' and pstatus is not null)
                             UNION ALL
                             SELECT SE.CODEID,
                                    SE.ISMARGINALLOW,
                                    to_date(SUBSTR(UPPER(BACKUPDT), 1, 10),
                                            'dd/mm/rrrr') BACKUPDT,
                                    nvl(OPENdate,
                                        TO_DATE('01/01/1900', 'dd/mm/rrrr')) OPENdate
                               FROM SECURITIES_RISKHIST SE)
                     where OPENdate <= v_ToDate
                       and BACKUPDT > v_ToDate) mst,
                   sbsecurities sb
             where mst.codeid = sb.codeid
               AND SB.TRADEPLACE LIKE V_EXCHANGE
             group by sb.symbol, sb.codeid) MST,
           (select symbol, max(MRPRICELOAN) MRPRICELOAN
              from (SELECT symbol, MRPRICELOAN
                      FROM secbasket
                     where basketid = 'Margin'
                       AND MRPRICELOAN > 0
                       and  nvl(CHSTATUS,'C') <> 'A'
                    UNION ALL
                     SELECT mst.symbol, mst.MRPRICELOAN
                      FROM SECBASKETHIST mst, (SELECT symbol, min(to_date(substr(t.backupdt, 0, 10),
                                               'dd/MM/rrrr')) bkdate
                              FROM SECBASKETHIST t
                             where to_date(substr(t.backupdt, 0, 10),
                                           'dd/MM/rrrr') >
                                   to_date(T_DATE, 'dd/MM/rrrr') group by symbol
                                   )tr                                   
                     WHERE mst.basketid = 'Margin'
                       AND mst.MRPRICELOAN > 0
                       and to_date(substr(mst.backupdt, 0, 10), 'dd/MM/rrrr') = tr.bkdate
                       and mst.symbol = tr.symbol)
             where 1 = 1
             group by symbol) sec
     WHERE MST.SYMBOL = SEC.SYMBOL
       and sec.MRPRICELOAN > 0
     ORDER BY MST.SYMBOL;
  /*SELECT V_ID I_DATE, V_I_DATE L_DATE,
  (CASE WHEN B.ACTIVE2='Y' THEN '' ELSE A.SYMBOL END ) SYMBOL_F,
  (CASE WHEN A.ACTIVE1='N' THEN '' ELSE A.SYMBOL END ) SYMBOL,NVL(B.SYMBOL_A,'') SYMBOL_A,
  (CASE WHEN A.ACTIVE1='Y' AND B.ACTIVE2='Y' THEN '' ELSE NVL(C.SYMBOL_D,'') END)  SYMBOL_D
  FROM(
  --TOTAL
  SELECT SB.SYMBOL SYMBOL, NVL(SE.ISMARGINALLOW,'N') ACTIVE1 FROM SECURITIES_RISK SE, SBSECURITIES SB
  WHERE SB.CODEID=SE.CODEID(+))A
  LEFT JOIN
  (-- ADD
  SELECT SB.SYMBOL SYMBOL_A,'Y' ACTIVE2 FROM MAINTAIN_LOG  MA, SBSECURITIES SB
  WHERE table_name='SECURITIES_RISK'
  AND column_name='ISMARGINALLOW'
  AND TO_VALUE='Y'
  AND SB.CODEID=substr(trim(record_key),11,6)
  AND ACTION_FLAG IN ('EDIT','ADD')
  AND MAKER_DT BETWEEN V_I_DATE AND V_CTODATE) B ON A.SYMBOL=B.SYMBOL_A
  LEFT JOIN
  (--DEL
  SELECT SB.SYMBOL SYMBOL_D,'N' ACTIVE3 FROM MAINTAIN_LOG MA,SBSECURITIES SB
  WHERE table_name='SECURITIES_RISK'
  AND SB.CODEID=substr(trim(record_key),11,6)
  AND column_name='ISMARGINALLOW'
  AND TO_VALUE='N'
  AND ACTION_FLAG IN ('EDIT')
  AND MAKER_DT BETWEEN V_I_DATE AND V_CTODATE
  UNION ALL
  SELECT SB.SYMBOL SYMBOL_D,'N' ACTIVE3 FROM MAINTAIN_LOG MA,SBSECURITIES SB
  WHERE table_name='SECURITIES_RISK'
  AND ACTION_FLAG='DELETE'
  AND SB.CODEID=substr(trim(record_key),11,6)
  AND  MAKER_DT BETWEEN V_I_DATE AND V_CTODATE) C ON C.SYMBOL_D=A.SYMBOL
  
  ORDER BY SYMBOL
  ;*/
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
