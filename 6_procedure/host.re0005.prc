SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE re0005 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE        IN       VARCHAR2,
   T_DATE        IN       VARCHAR2,
   CFROM_DATE        IN       VARCHAR2,
   CTO_DATE        IN       VARCHAR2,
   I_BRIDGD         IN       VARCHAR2,
   TYPE            IN       VARCHAR2,
   CUSTTYPE       IN       VARCHAR2,
   CFTYPE         IN       VARCHAR2

 )
IS

--BAO CAO TINH HINH KHACH HANG TAI VCBS
--NGOCVTT 22/05/2015
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (50);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2 (50);

    V_CFTYPE  VARCHAR2(100);
    V_CUSTTYPE  VARCHAR2(100);
    V_TYPE     VARCHAR2(100);

   V_CFROMDATE       DATE;
   V_CTODATE         DATE;
   V_TODATE         DATE;
   V_FROMDATE          DATE;

   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);

   V_HNX_F       NUMBER;
   V_HNX_T       NUMBER;
   V_HOSE_F      NUMBER;
   V_HOSE_T      NUMBER;
   V_UPCOM_F      NUMBER;
   V_UPCOM_T     NUMBER;


BEGIN


    V_STROPT := OPT;

    IF (V_STROPT <> 'A') AND (pv_BRID <> 'ALL')
    THEN
      V_STRBRID := pv_BRID;
    ELSE
      V_STRBRID := '%%';
    END IF;
    -- GET REPORT'S PARAMETERS
      IF(CFTYPE <> 'ALL')
   THEN
        V_CFTYPE := CFTYPE;
   ELSE
        V_CFTYPE  := '%%';
   END IF;

       IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

    IF CUSTTYPE = 'ALL' OR CUSTTYPE IS NULL THEN
        V_CUSTTYPE := '%%';
    ELSE
        V_CUSTTYPE := CUSTTYPE;
    END IF;

       IF TYPE = 'ALL' OR TYPE IS NULL THEN
        V_TYPE := '%%';
    ELSE
        V_TYPE := TYPE;
    END IF;

   V_CFROMDATE:= TO_DATE(CFROM_DATE,'DD/MM/YYYY');
   V_CTODATE:= TO_DATE(CTO_DATE,'DD/MM/YYYY');
   V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/YYYY');
   V_TODATE:=TO_DATE(T_DATE,'DD/MM/YYYY');

      -------------------------
      SELECT
            SUM(CASE WHEN OD.TXDATE>=V_FROMDATE AND OD.TXDATE<=V_TODATE AND SB.TRADEPLACE='001' THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_001_1,
            SUM(CASE WHEN OD.TXDATE>=V_FROMDATE AND OD.TXDATE<=V_TODATE AND SB.TRADEPLACE='002' THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_002_1,
            SUM(CASE WHEN OD.TXDATE>=V_FROMDATE AND OD.TXDATE<=V_TODATE AND SB.TRADEPLACE='005' THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_005_1,
            SUM(CASE WHEN OD.TXDATE>=V_CFROMDATE AND OD.TXDATE<=V_CTODATE AND SB.TRADEPLACE='001' THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_001_2,
            SUM(CASE WHEN OD.TXDATE>=V_CFROMDATE AND OD.TXDATE<=V_CTODATE AND SB.TRADEPLACE='002' THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_002_2,
            SUM(CASE WHEN OD.TXDATE>=V_CFROMDATE AND OD.TXDATE<=V_CTODATE AND SB.TRADEPLACE='005' THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_005_2
            INTO V_HOSE_F,V_HNX_F,V_UPCOM_F,V_HOSE_T,V_HNX_T,V_UPCOM_T
      FROM (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,
            AFMAST AF,CFTYPE CFT,ODTYPE ODT,
              ( SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                   WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                       FROM TRADEPLACE PA, TRADECAREBY CA
                       WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                   UNION ALL
                   SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                   FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR,
                    SBSECURITIES SB, VW_ODMAST_ALL OD
      INNER JOIN VW_IOD_ALL IO ON OD.ORDERID = IO.ORGORDERID
      WHERE CF.CUSTID=AF.CUSTID
            AND CF.ACTYPE=CFT.ACTYPE
            AND CF.BRID = SUBSTR(BR.BRID,1,4)
            AND CF.CAREBY=BR.CAREBY
            AND OD.ACTYPE =ODT.ACTYPE
            AND SB.CODEID=OD.CODEID
            AND OD.AFACCTNO=AF.ACCTNO
            AND OD.DELTD<>'Y'
            AND SUBSTR(CF.CUSTODYCD,4,1)<>'P'
            AND SB.TRADEPLACE IN ('001','002','005')
            AND CF.CUSTTYPE LIKE V_CUSTTYPE
            AND CF.ACTYPE LIKE V_CFTYPE
            AND BR.BRID LIKE V_I_BRIDGD
            AND (CASE WHEN CF.COUNTRY='234' THEN 'IN' ELSE 'OUT' END) LIKE V_TYPE
            AND OD.TXDATE BETWEEN V_FROMDATE AND V_CTODATE
            AND OD.EXECTYPE IN ('NS','SS','MS','NB','BC')
            AND SB.SECTYPE IN('001', '002', '007', '008', '111','011'); --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011




   -- GET REPORT'S DATA
    OPEN  PV_REFCURSOR
     FOR
          SELECT V_HOSE_F HOSE_F,V_HNX_F HNX_F,V_UPCOM_F UPCOM_F,V_HOSE_T HOSE_T,V_HNX_T HNX_T,V_UPCOM_T UPCOM_T,
                 V_FROMDATE DATE1, V_TODATE DATE2,V_CFROMDATE DATE3,V_CTODATE DATE4, BR.BRID, BR.BRNAME,CF.CUSTTYPE,CFT.TYPENAME,
                 (CASE WHEN CF.COUNTRY='234' THEN 'IN' ELSE 'OUT' END) COUNTRY,
                        SUM(CASE WHEN OD.TXDATE>=V_FROMDATE AND OD.TXDATE<=V_TODATE THEN (CASE WHEN OD.EXECAMT = 0 THEN 0 ELSE
                        (CASE WHEN IO.IODFEEACR = 0 and OD.TXDATE = getcurrdate THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                                   ELSE io.iodfeeacr END)
                  END) ELSE 0 END) FEE_1,
                  SUM(CASE WHEN OD.TXDATE>=V_FROMDATE AND OD.TXDATE<=V_TODATE THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_1,
                            SUM(CASE WHEN OD.TXDATE>=V_CFROMDATE AND OD.TXDATE<=V_CTODATE THEN (CASE WHEN OD.EXECAMT = 0 THEN 0 ELSE
                            (CASE WHEN IO.IODFEEACR = 0 and OD.TXDATE = getcurrdate THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                            ELSE io.iodfeeacr END)
                  END) ELSE 0 END) FEE_2,
                  SUM(CASE WHEN OD.TXDATE>=V_CFROMDATE AND OD.TXDATE<=V_CTODATE THEN NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) ELSE 0 END ) MATCHAMT_2
          FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                AFMAST AF,CFTYPE CFT,ODTYPE ODT,
                  ( SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                   WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                       FROM TRADEPLACE PA, TRADECAREBY CA
                       WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                   UNION ALL
                   SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                   FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR,
                    SBSECURITIES SB, VW_ODMAST_ALL OD
          INNER JOIN VW_IOD_ALL IO ON OD.ORDERID = IO.ORGORDERID
          WHERE CF.CUSTID=AF.CUSTID
                  AND CF.ACTYPE=CFT.ACTYPE
                  AND CF.BRID = SUBSTR(BR.BRID,1,4)
                  AND CF.CAREBY=BR.CAREBY
                  AND OD.ACTYPE =ODT.ACTYPE
                  AND SB.CODEID=OD.CODEID
                  AND OD.AFACCTNO=AF.ACCTNO
                  AND OD.DELTD<>'Y'
                  AND SUBSTR(CF.CUSTODYCD,4,1)<>'P'
                  AND CF.CUSTTYPE LIKE V_CUSTTYPE
                  AND CF.ACTYPE LIKE V_CFTYPE
                  AND BR.BRID LIKE V_I_BRIDGD
                  AND SB.TRADEPLACE IN ('001','002','005')
                  AND (CASE WHEN CF.COUNTRY='234' THEN 'IN' ELSE 'OUT' END) LIKE V_TYPE
                  AND OD.TXDATE BETWEEN V_FROMDATE AND V_CTODATE
                  AND OD.EXECTYPE IN ('NS','SS','MS','NB','BC')
                  AND SB.SECTYPE IN('001', '002', '007', '008', '111','011') --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                  GROUP BY BR.BRID, BR.BRNAME,CF.COUNTRY,CF.CUSTTYPE,CFT.TYPENAME
                  ORDER BY BR.BRID, (CASE WHEN CF.COUNTRY='234' THEN 'IN' ELSE 'OUT' END),CF.CUSTTYPE,CFT.TYPENAME;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
