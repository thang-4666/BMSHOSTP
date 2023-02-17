SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0020" (
       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
       OPT            IN       VARCHAR2,
       pv_BRID           IN       VARCHAR2,
       TLGOUPS        IN       VARCHAR2,
       TLSCOPE        IN       VARCHAR2,
       I_DATE         IN       VARCHAR2,
       PLSENT         IN       VARCHAR2,
       PV_TRADEPLACE     IN       VARCHAR2
)
IS

-- PURPOSE:
-- B?O C?O V? T?H H?H S? H?U CH?NG KHO?N LUU K?C?A NH? ?U TU NU?C NGO?I
-- PERSON               DATE                COMMENTS
-- ---------------      ----------          ----------------------
-- QUOCTA               15/02/2012          SUA THEO YC BVS
-- ---------------      ----------          ----------------------

  V_STROPTION           VARCHAR2 (50);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_IN_DATE             DATE;
  V_CURR_DATE           DATE;
  V_INBRID        VARCHAR2(10);
  V_STRBRID      VARCHAR2 (500);
   vn_TRADEPLACE varchar2(500);
   v_strTRADEPLACE VARCHAR2 (40);

BEGIN

     V_STROPTION := upper(OPT);
     V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

    V_IN_DATE := TO_DATE(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CURR_DATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';



IF  (upper(PV_TRADEPLACE) <> 'ALL')
THEN
      v_strTRADEPLACE := upper(PV_TRADEPLACE);
      SELECT cdcontent INTO vn_TRADEPLACE FROM allcode WHERE cdtype = 'SE' AND cdname = 'TRADEPLACE' AND cdval like PV_TRADEPLACE ;
ELSE
   v_strTRADEPLACE := '%';
   vn_TRADEPLACE := 'ALL';
END IF;



-- MAIN REPORT
OPEN PV_REFCURSOR FOR
SELECT SB.* FROM (
SELECT  /*max*/(CASE WHEN SB.SECTYPE = '001' THEN ' I. C? PHI?U '
              WHEN SB.SECTYPE in ('003','006') THEN ' II. TR?I PHI?U '
              WHEN SB.SECTYPE = '008' THEN ' III. CH?NG CH? QU? ' END) GR_I,
        /*max*/(CASE WHEN SB.TRADEPLACE = '001' THEN ' 2. Ni?y?t t?i HOSE '
              WHEN SB.TRADEPLACE = '002' THEN ' 1. Ni?y?t t?i HNX '
              ELSE ' 3. UPCOM ' END) GR_II,
        SB.SYMBOL,SB.CODEID,SB.TRADEPLACE,  (CF.CUSTODYCD || ' : ' || CF.FULLNAME) CUST_FULLNAME,
        /*max*/(CASE WHEN CF.CUSTTYPE = 'B' THEN ' 2 '
              ELSE ' 1 ' END) CUSTTYPE_NAME,
        (CASE WHEN CF.country = '234' THEN CF.idcode ELSE CF.tradingcode END) IDCODE,
       /* SUM*/(MST.TOTAL_AMT) TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
FROM
        (
        SELECT CRR.CUSTODYCD, CRR.CODEID, (NVL(CRR.CRR_TOTAL_TRANS, 0) - NVL(MST.MST_TOTAL_TRANS, 0)) TOTAL_AMT
        FROM
        --- SO DU SO HUU HIEN TAI
        (SELECT  CF.CUSTODYCD, SE.CODEID,
            SUM(SE.TRADE + SE.MORTAGE + SE.BLOCKED + SE.NETTING + SE.WTRADE) CRR_TOTAL_TRANS
         FROM     SEMAST SE, CFMAST CF, AFMAST AF
         WHERE    SE.AFACCTNO       =   AF.ACCTNO
         AND      CF.CUSTID         =   AF.CUSTID
         --- AND      cf.COUNTRY <> '234' ---
         and TRIM(SUBSTR(CF.CUSTODYCD, 4, 1)) = 'F'
         and cf.custatcom = 'Y'
         AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
         GROUP BY CF.CUSTODYCD, SE.CODEID
         ) CRR
        LEFT JOIN
        --- LAY CAC PHAT SINH TU NGAY IN_DATE + 1 DEN NGAY HIEN TAI
        (SELECT MT.custodycd, MT.codeid,
                (ROUND(SUM(CASE WHEN MT.FIELD = 'TRADE' THEN (CASE WHEN MT.TXTYPE = 'D' THEN -MT.NAMT ELSE MT.NAMT END)
                                ELSE 0 END)) +        -- SO DU DAT LENH
                ROUND(SUM(CASE WHEN MT.FIELD = 'MORTAGE' THEN (CASE WHEN MT.TXTYPE = 'D' THEN -MT.NAMT ELSE MT.NAMT END)
                                ELSE 0 END)) +        -- SO DU CAM CO
                ROUND(SUM(CASE WHEN MT.FIELD = 'BLOCKED' THEN (CASE WHEN MT.TXTYPE = 'D' THEN -MT.NAMT ELSE MT.NAMT END)
                                ELSE 0 END)) +        -- SO DU PHONG TOA
                ROUND(SUM(CASE WHEN MT.FIELD = 'NETTING' THEN (CASE WHEN MT.TXTYPE = 'D' THEN -MT.NAMT ELSE MT.NAMT END)
                                ELSE 0 END)) +        -- SO DU CHO GIAO
                ROUND(SUM(CASE WHEN MT.FIELD = 'WTRADE' THEN (CASE WHEN MT.TXTYPE = 'D' THEN -MT.NAMT ELSE MT.NAMT END)
                                ELSE 0 END))
                ) MST_TOTAL_TRANS                     -- TONG CAC PHAT SINH SO DU
         FROM   VW_SETRAN_GEN MT, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf, afmast af
         WHERE  MT.deltd      <>   'Y'
         AND    MT.busdate    >    V_IN_DATE
         AND    MT.busdate    <=   V_CURR_DATE
         AND    MT.namt       >    0
         and mt.CUSTODYCD =  cf.CUSTODYCD
         AND    MT.field      IN   ('TRADE', 'MORTAGE', 'BLOCKED', 'NETTING', 'WTRADE')
----         AND    cf.COUNTRY <> '234' ---
         and TRIM(SUBSTR(MT.CUSTODYCD, 4, 1)) = 'F'
         and cf.custatcom = 'Y'
         AND mt.afacctno=af.acctno
         AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
         GROUP BY MT.custodycd, MT.codeid
         ) MST ON CRR.CUSTODYCD   =   MST.CUSTODYCD AND CRR.CODEID = MST.CODEID
    ) MST,  (select NVL(SB1.TRADEPLACE,SB.TRADEPLACE) TRADEPLACE, NVL(SB.SECTYPE,SB1.SECTYPE) SECTYPE ,SB.CODEID,
    nvl(sb1.symbol,sb.symbol) symbol, nvl(sb1.CODEID,sb.CODEID) REFCODEID
from sbsecurities sb, sbsecurities sb1
where nvl(sb.refcodeid,' ') = sb1.codeid(+) ) SB
---sbsecurities SB
, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  CF
WHERE    TRIM(SUBSTR(MST.CUSTODYCD, 4, 1)) = 'F'
    AND      MST.CUSTODYCD =  CF.CUSTODYCD
    AND      MST.CODEID    =  SB.CODEID
    AND      SB.SECTYPE    IN ('001', '006','003', '008')
    AND      SB.TRADEPLACE IN ('001', '002', '005')
    AND      MST.TOTAL_AMT > 0
   -- GROUP BY SB.SYMBOL,SB.SYMBOL,SB.TRADEPLACE,  (CF.CUSTODYCD || ' : ' || CF.FULLNAME) , (CASE WHEN CF.country = '234' THEN CF.idcode ELSE CF.tradingcode END)


) sb , setradeplace setr

       where sb.codeid = setr.codeid (+)

       and case when nvl(setr.codeid,'xxx') = sb.codeid and setr.txdate > to_date(I_DATE,'DD/MM/YYYY') then setr.frtradeplace
                else sb.TRADEPLACE  end like v_strTRADEPLACE


union all
select ' I. C? PHI?U ' GR_I, ' 1. Ni?y?t t?i HNX ' GR_II,
    NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual
union all
select ' I. C? PHI?U ' GR_I, ' 2. Ni?y?t t?i HOSE ' GR_II,
        NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual
union all
select ' I. C? PHI?U ' GR_I, ' 3. UPCOM ' GR_II,
    NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual

union all
select ' II. TR?I PHI?U ' GR_I, ' 1. Ni?y?t t?i HNX ' GR_II,
    NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual
union all
select ' II. TR?I PHI?U ' GR_I, ' 2. Ni?y?t t?i HOSE ' GR_II,
        NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual
union all
select ' II. TR?I PHI?U ' GR_I, ' 3. UPCOM 'GR_II,
    NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual

union all
select ' III. CH?NG CH? QU? ' GR_I, ' 1. Ni?y?t t?i HNX ' GR_II,
    NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual
union all
select ' III. CH?NG CH? QU? ' GR_I, ' 2. Ni?y?t t?i HOSE ' GR_II,
        NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual
union all
select ' III. CH?NG CH? QU? ' GR_I, ' 3. UPCOM 'GR_II,
    NULL SYMBOL, NULL CODEID, NULL TRADEPLACE, NULL CUST_FULLNAME, NULL CUSTTYPE_NAME,
    null IDCODE, 0 TOTAL_AMT , PLSENT PLSENT, V_IN_DATE DATE_TRANS
from dual

;


EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;



-- End of DDL Script for Procedure HOST.SE0020
 
/
