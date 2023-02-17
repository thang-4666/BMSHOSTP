SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0035"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     CACODE       in varchar2,
                                     TLLID        in varchar2) IS
  --
  -- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
  -- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
  -- MODIFICATION HISTORY
  -- PERSON      DATE    COMMENTS
  -- THANHNM   23-APR-12  CREATED
  -- ---------   ------  -------------------------------------------

  CUR         PKG_REPORT.REF_CURSOR;
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(40);
  V_INBRID    VARCHAR2(4);
  V_STRACCTNO VARCHAR2(20);
  V_CACODE    VARCHAR2(20);
  V_TLLID     VARCHAR2(4);
BEGIN

  V_STROPTION := upper(OPT);
  V_TLLID     := TLLID;
  V_INBRID    := pv_BRID;
  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSE
    if (V_STROPTION = 'B') then
      select br.mapid
        into V_STRBRID
        from brgrp br
       where br.brid = V_INBRID;
    else
      V_STRBRID := V_INBRID;
    end if;
  END IF;

  IF (CACODE <> 'ALL') THEN
    V_CACODE := CACODE;
  ELSE
    V_CACODE := '%';
  END IF;

  --   IF(PV_CUSTODYCD <> 'ALL')   THEN  V_STRCUSTODYCD  := PV_CUSTODYCD;
  --   ELSE   V_STRCUSTODYCD  := '%';
  --   END IF;

  -- GET REPORT'S PARAMETERS

  OPEN PV_REFCURSOR FOR
  /*
  SELECT SUM(CAS.TRADE) TRADE, ROUND( SUM(CAS.TRADE - CAS.BALANCE) , CA.CIROUNDTYPE ) EX_QTTY, ROUND(SUM(CAS.BALANCE),CA.CIROUNDTYPE) BALANCE,
      SUM(CAS.QTTY) QTTY, SUM(CAS.PQTTY) PQTTY, SUM(CAS.AMT) AMT,
      CF.COUNTRY,  CA.CODEID , SB.SYMBOL, CA.PARVALUE, CA.EXRATE, DUEDATE, ISS.FULLNAME ISSFULLNAME, CA.INTERESTRATE, CA.TOCODEID, CA.CIROUNDTYPE, TL.BRID
  FROM CAMAST CA, CASCHD CAS, CFMAST CF, AFMAST AF, BRGRP BR, SBSECURITIES SB, ISSUERS ISS, TLPROFILES TL
  WHERE CF.CUSTID=AF.CUSTID AND CAS.AFACCTNO = AF.ACCTNO
      AND CA.CAMASTID=CAS.CAMASTID AND CA.CATYPE='023'
      AND BR.BRID = SUBSTR(AF.ACCTNO,1,4) AND SB.CODEID=CA.CODEID
      AND ISS.SHORTNAME = SB.SYMBOL
      AND  (SUBSTR(AF.ACCTNO,1,4) LIKE V_STRBRID OR INSTR(V_STRBRID,SUBSTR(AF.ACCTNO,1,4)) <> 0)
      AND CA.camastid= V_CACODE
      AND TL.TLID=V_TLLID
  GROUP BY CA.CIROUNDTYPE,CF.COUNTRY,  CA.CODEID , SB.SYMBOL, CA.PARVALUE, CA.EXRATE, DUEDATE, ISS.FULLNAME,
      CA.INTERESTRATE, CA.TOCODEID, CA.CIROUNDTYPE,TL.BRID     ;
  */

    SELECT SUM(TRADE_IN) TRADE_IN,
           SUM(TRADE_OUT) TRADE_OUT,
           SUM(EXQTTY_IN) EXQTTY_IN,
           SUM(EXQTTY_OUT) EXQTTY_OUT,
            SUM(TRADE_IN) BALANCE_IN,
           SUM(TRADE_OUT) BALANCE_OUT,
            SUM(TRADE_IN)- SUM(EXQTTY_IN) AMT_IN,
            SUM(TRADE_OUT)- SUM(EXQTTY_OUT) AMT_OUT,
           SUM(QTTY_IN) QTTY_IN,
           SUM(QTTY_OUT) QTTY_OUT,
           CODEID,
           SYMBOL,
           PARVALUE,
           EXRATE,
           REPORTDATE,
           DUEDATE,
           ISSFULLNAME,
           INTERESTRATE,
           TOCODEID,
           CIROUNDTYPE,
           BRID
      FROM (SELECT CASE
                     WHEN COUNTRY = '234' THEN
                      CAS.TRADE
                     ELSE
                      0
                   END TRADE_IN,
                   CASE
                     WHEN COUNTRY <> '234' THEN
                      CAS.TRADE
                     ELSE
                      0
                   END TRADE_OUT,
                   CASE
                     WHEN COUNTRY = '234' THEN
                      CAS.QTTY*substr(ca.exrate,0,instr(ca.exrate,'/') - 1)/substr(ca.exrate,instr(ca.exrate,'/') + 1,length(ca.exrate))
                     ELSE
                      0
                   END EXQTTY_IN,
                   CASE
                     WHEN COUNTRY <> '234' THEN
                       CAS.QTTY*substr(ca.exrate,0,instr(ca.exrate,'/') - 1)/substr(ca.exrate,instr(ca.exrate,'/') + 1,length(ca.exrate))
                     
                     ELSE
                      0
                   END EXQTTY_OUT,
                   CASE
                     WHEN COUNTRY = '234' THEN
                      CAS.TRADE
                     ELSE
                      0
                   END BALANCE_IN,
                   CASE
                     WHEN COUNTRY <> '234' THEN
                      CAS.TRADE
                     ELSE
                      0
                   END BALANCE_OUT,
                   CASE
                     WHEN COUNTRY = '234' THEN
                      CAS.PQTTY
                     ELSE
                      0
                   END AMT_IN,
                   CASE
                     WHEN COUNTRY <> '234' THEN
                      CAS.PQTTY
                     ELSE
                      0
                   END AMT_OUT,
                    CASE
                     WHEN COUNTRY = '234' THEN
                      CAS.TRADE - CAS.QTTY
                     ELSE
                      0
                   END QTTY_IN,
                   CASE
                     WHEN COUNTRY <> '234' THEN
                      CAS.TRADE - CAS.QTTY
                     ELSE
                      0
                   END QTTY_OUT,
                   CF.COUNTRY,
                   CA.CODEID,
                   SB.SYMBOL,
                   CA.PARVALUE,
                   CA.EXRATE,
                   REPORTDATE,
                   DUEDATE,
                   ISS.FULLNAME ISSFULLNAME,
                   CA.INTERESTRATE,
                   CA.TOCODEID,
                   CA.CIROUNDTYPE,
                   TL.BRID
              FROM CAMAST CA,
                   CASCHD CAS,
                   (SELECT *
                      FROM CFMAST
                     WHERE FNC_VALIDATE_SCOPE(BRID,
                                              CAREBY,
                                              TLSCOPE,
                                              pv_BRID,
                                              TLGOUPS) = 0) CF,
                   AFMAST AF,
                   BRGRP BR,
                   SBSECURITIES SB,
                   ISSUERS ISS,
                   TLPROFILES TL
             WHERE CF.CUSTID = AF.CUSTID
               AND CAS.AFACCTNO = AF.ACCTNO
               AND CA.CAMASTID = CAS.CAMASTID
               AND CA.CATYPE = '023'
               AND BR.BRID = SUBSTR(AF.ACCTNO, 1, 4)
               AND SB.CODEID = CA.CODEID
               AND ISS.SHORTNAME = SB.SYMBOL
                  --AND  (SUBSTR(AF.ACCTNO,1,4) LIKE V_STRBRID OR INSTR(V_STRBRID,SUBSTR(AF.ACCTNO,1,4)) <> 0)
               AND CA.camastid LIKE V_CACODE
               and cas.deltd <> 'Y'
               AND TL.TLID = V_TLLID)
     GROUP BY CIROUNDTYPE,
              CODEID,
              SYMBOL,
              PARVALUE,
              EXRATE,
              REPORTDATE,
              DUEDATE,
              ISSFULLNAME,
              INTERESTRATE,
              TOCODEID,
              CIROUNDTYPE,
              BRID;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
