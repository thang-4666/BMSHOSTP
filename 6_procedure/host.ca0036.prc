SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0036"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     CACODE       IN VARCHAR2,
                                     PV_CUSTODYCD IN VARCHAR2,
                                     PV_AFACCTNO  IN VARCHAR2) IS
  --

  CUR            PKG_REPORT.REF_CURSOR;
  V_STROPTION    VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID      VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_INBRID       VARCHAR2(4);
  V_STRAFACCTNO  VARCHAR2(20);
  V_STRCUSTODYCD VARCHAR2(20);
  V_STRCACODE    VARCHAR2(20);
  V_todate       DATE;
  V_fromdate     DATE;
BEGIN
  V_STROPTION := UPPER(OPT);
  V_INBRID    := pv_BRID;

  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSE
    IF (V_STROPTION = 'B') THEN
      SELECT BRGRP.MAPID
        INTO V_STRBRID
        FROM BRGRP
       WHERE BRGRP.BRID = V_INBRID;
    ELSE
      V_STRBRID := V_INBRID;
    END IF;
  END IF; ---hoangnd loc theo pham vi

  IF (PV_AFACCTNO <> 'ALL') THEN
    V_STRAFACCTNO := PV_AFACCTNO;
  ELSE
    V_STRAFACCTNO := '%%';
  END IF;

  IF (PV_CUSTODYCD <> 'ALL') THEN
    V_STRCUSTODYCD := PV_CUSTODYCD;
  ELSE
    V_STRCUSTODYCD := '%%';
  END IF;

  IF (CACODE <> 'ALL') THEN
    V_STRCACODE := CACODE;
  ELSE
    V_STRCACODE := '%%';
  END IF;

  V_todate   := to_date(T_DATE, 'DD/MM/RRRR');
  V_fromdate := to_date(F_DATE, 'DD/MM/RRRR');

  --GET REPORT'S PARAMETERS

  OPEN PV_REFCURSOR FOR
  
    SELECT cf.fullname,
           cf.address,
           CASE
             WHEN cf.mobile IS NULL THEN
              nvl(cf.phone, ' ')
             ELSE
              nvl(cf.mobile, ' ')
           END phone,
           CASE
             WHEN country = '234' THEN
              cf.idcode
             ELSE
              cf.tradingcode
           END IDCODE,
           (case
             when cf.country = '234' then
              cf.IDDATE
             else
              cf.tradingcodedt
           end) IDDATE,
           cf.idplace,
           cf.custodycd,
           af.acctno,
           brname,
           sb.symbol,
           iss.fullname sefullname,
           ca.exrate,
           ca.begindate,
           ca.duedate,
           sum(chd.trade) trade,
           sum(chd.pqtty + chd.qtty) pqtty
          ,ca.reportdate ,
           ca.parvalue
          ,ca.interestrate
      FROM caschd chd,
           camast ca,
           afmast af,
           (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           BRGRP,
           issuers iss,
           sbsecurities sb
     WHERE ca.camastid = chd.camastid
       AND ca.catype = '023'
       AND substr(af.acctno, 1, 4) = BRGRP.brid
       AND chd.deltd <> 'Y'
       AND af.acctno = chd.afacctno
       AND cf.custid = af.custid
       AND sb.issuerid = iss.issuerid
       AND sb.codeid = ca.codeid
       AND (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID, AF.BRID) <> 0)
       AND af.acctno like V_STRAFACCTNO
       AND cf.custodycd like V_STRCUSTODYCD
       AND ca.camastid like V_STRCACODE
       AND ca.reportdate <= V_todate
       AND ca.reportdate >= V_fromdate
     GROUP BY cf.fullname,
              cf.address,
              CASE
                WHEN cf.mobile IS NULL THEN
                 nvl(cf.phone, ' ')
                ELSE
                 nvl(cf.mobile, ' ')
              END,
              CASE
                WHEN country = '234' THEN
                 cf.idcode
                ELSE
                 cf.tradingcode
              END,
              (case
                when cf.country = '234' then
                 cf.IDDATE
                else
                 cf.tradingcodedt
              end),
              cf.idplace,
              cf.custodycd,
              af.acctno,
              brname,
              sb.symbol,
              iss.fullname,
              ca.exrate,
              ca.begindate,
              ca.duedate,
              ca.reportdate ,
              ca.parvalue,
              ca.interestrate
    
    ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;

 
 
 
 
/
