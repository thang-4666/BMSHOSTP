SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0068 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE                   IN       VARCHAR2,
   TRADEPLACE               IN       VARCHAR2,
   PV_SECTYPE               IN       VARCHAR2,
   CASHPLACE                IN       VARCHAR2,
   BRGID                  IN       VARCHAR2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------

    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID          VARCHAR2 (40);
    V_INBRID          VARCHAR2 (4);

    SYMBOL             VARCHAR2(20);
    V_STRSYMBOL        VARCHAR2(20);
    PV_CUSTODYCD       VARCHAR2(20);
    V_CUSTODYCD        VARCHAR2(20);
    TYPEDATE           VARCHAR2(4);
    V_TYPEDATE         VARCHAR2(4);
    v_OnDate           DATE;
    v_TradePlace       VARCHAR2(20);
    PV_CLEARDAY        NUMBER(10);
    v_Clearday         NUMBER(10);
    V_SECTYPE          VARCHAR2(100);
    V_STRCASHPLACE     VARCHAR2 (100);
    v_CashPlaceName    VARCHAR2(1000);

    V_PV_STRBRID       VARCHAR2 (50);
    V_p_STRBRID        VARCHAR2 (10);

BEGIN
    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
    IF (V_STROPTION = 'A') then
        V_STRBRID := '%';
    ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
         else
            V_STRBRID := V_INBRID;
         end if;
    END IF;

    -- GET REPORT'S PARAMETERS
    v_OnDate := to_date(I_DATE,'DD/MM/RRRR');
    PV_CUSTODYCD :=   'ALL';
    V_CUSTODYCD := replace (upper(PV_CUSTODYCD),'.','');
    SYMBOL      :=    'ALL';
    V_STRSYMBOL := replace (upper(SYMBOL),'.','');
    v_TradePlace := TRADEPLACE;

    IF  (PV_CUSTODYCD <> 'ALL') THEN
        V_CUSTODYCD := PV_CUSTODYCD;
    ELSE
        V_CUSTODYCD := '%';
    END IF;

    IF  (SYMBOL <> 'ALL') THEN
        V_STRSYMBOL := V_STRSYMBOL;
    ELSE
        V_STRSYMBOL := '%';
    END IF;

    IF  (v_TradePlace <> 'ALL') THEN
        v_TradePlace := v_TradePlace;
    ELSE
        v_TradePlace := '%';
    END IF;

    IF  (PV_SECTYPE <> 'ALL')
    THEN
        V_SECTYPE := PV_SECTYPE;
    ELSE
        V_SECTYPE := '%';
    END IF;

    IF  (CASHPLACE <> 'ALL')
    THEN
        V_STRCASHPLACE := CASHPLACE;
    ELSE
        V_STRCASHPLACE := '%';
    END IF;

    If  CASHPLACE = 'ALL' Then
        v_CashPlaceName := 'Tat ca';
    ELSIF CASHPLACE = '000' Then
        v_CashPlaceName := 'Cty chung khoan';
    Else
        Begin
             Select CDCONTENT Into v_CashPlaceName from Allcode Where cdval = CASHPLACE And cdname ='BANKNAME' and cdtype ='CF';
        EXCEPTION
             WHEN OTHERS THEN v_CashPlaceName := '';
        End;
    End If;

    TYPEDATE   := '001';

    V_TYPEDATE := TYPEDATE;

    PV_CLEARDAY := 3;

    v_Clearday := PV_CLEARDAY;


    if(upper(BRGID) = 'ALL' OR LENGTH(BRGID) <= 1) then
        V_p_STRBRID := '%';
    else
        V_p_STRBRID := BRGID;
    end if;


IF (CASHPLACE = 'ALL') THEN

    OPEN PV_REFCURSOR FOR
    SELECT
    V_TYPEDATE TYPEDATE,
    max(SETTDATE) SETTDATE,
    max(CF.CUSTODYCD) CUSTODYCD,
    SYMBOL,
    max(CF.FULLNAME) FULLNAME,
    max(TRADATE) TRADATE,
      max(case
          when tradeplace='002' then 'HNX'
          when tradeplace='001' then 'HOSE'
          when tradeplace='005' then 'UPCOM'
          when tradeplace='007' then 'TRAI PHIEU CHUYEN BIET'
          when tradeplace='008' then 'TIN PHIEU' else '' end)tradeplace ,
           I_DATE I_DATE   ,

    max(cdcontent) TRADEPLACE_NAME,
        sum(NVL(D_BAMT,0)) D_BAMT,       -- TU DOANH: MUA
        sum(NVL(D_SAMT,0)) D_SAMT,       -- TU DOANH: BAN
        sum(NVL(BD_BAMT,0)) BD_BAMT,     -- TRONG NUOC: MUA
        sum(NVL(BD_SAMT,0)) BD_SAMT,     -- TRUONG NUOC: BAN
        sum(NVL(BF_BAMT,0)) BF_BAMT,     -- NUOC NGOAI: MUA
        sum(NVL(BF_SAMT,0)) BF_SAMT      -- NUOC NGOAI: BAN

    FROM CFMAST CF, allcode cd ,
    (
        -- Tu Doanh
        SELECT af.custid, cleardate SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            SUM(CHD.QTTY) D_BAMT,     -- Nhan CK
            0 D_SAMT,     -- Giao CK
            0 BD_BAMT,          --
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS' AND SUBSTR(CF.CUSTODYCD,4,1) = 'P' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   = AFT.ACTYPE
            AND AFT.COREBANK LIKE '%'
            --AND CHD.CLEARDAY = v_Clearday
            ---AND   (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.brid like V_p_STRBRID or instr(V_pV_STRBRID,CF.brid) <> 0 )
            and (CF.brid like V_STRBRID or INSTR(V_STRBRID,CF.brid) <> 0)
        GROUP BY af.custid, cleardate, CHD.TXDATE, SB.symbol, chd.tradeplace
        union all
        SELECT af.custid, cleardate SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,     -- Nhan CK
            SUM(CHD.QTTY) D_SAMT,     -- Giao CK
            0 BD_BAMT,          --
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'P' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE '%'
            --AND CHD.CLEARDAY = v_Clearday
            --AND   (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
        GROUP BY af.custid, cleardate, CHD.TXDATE, SB.symbol, chd.tradeplace
        -- Trong nuoc
        UNION ALL
        ----- Trong nuoc: mua ck
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            SUM(CHD.QTTY) BD_BAMT,
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS'AND SUBSTR(CF.CUSTODYCD,4,1) = 'C' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE '%'
            ---AND   (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        ----- Trong nuoc: ban ck
        UNION ALL
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            SUM(CHD.QTTY) BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'C' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE '%'
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        -- Nuoc ngoai
        UNION ALL
        --------- Nuoc ngoai: Mua ck
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            0 BD_SAMT,
            SUM(CHD.QTTY) BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS' AND SUBSTR(CF.CUSTODYCD,4,1) = 'F' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE '%'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        --------- Nuoc ngoai: Ban ck
        UNION ALL
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            0 BD_SAMT,
            0 BF_BAMT,
            SUM(CHD.QTTY) BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'F' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE '%'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
    ) A
    WHERE CF.CUSTID = A.CUSTID and cdtype = 'OD' and cdname = 'TRADEPLACE' and a.tradeplace = cd.cdval
    group by symbol
    order  by TRADATE, SYMBOL;

ELSIF (CASHPLACE = '000') THEN

    OPEN PV_REFCURSOR FOR
    SELECT
    V_TYPEDATE TYPEDATE,
    max(SETTDATE) SETTDATE,
    max(CF.CUSTODYCD) CUSTODYCD,
    SYMBOL,
    max(CF.FULLNAME) FULLNAME,
    max(TRADATE)TRADATE,
       max(case
          when tradeplace='002' then 'HNX'
          when tradeplace='001' then 'HOSE'
          when tradeplace='005' then 'UPCOM'
          when tradeplace='007' then 'TRAI PHIEU CHUYEN BIET'
          when tradeplace='008' then 'TIN PHIEU' else '' end)tradeplace ,
           I_DATE I_DATE   ,
    max(cdcontent) TRADEPLACE_NAME,
        sum(NVL(D_BAMT,0)) D_BAMT,       -- TU DOANH: MUA
        sum(NVL(D_SAMT,0)) D_SAMT,       -- TU DOANH: BAN
        sum(NVL(BD_BAMT,0)) BD_BAMT,     -- TRONG NUOC: MUA
        sum(NVL(BD_SAMT,0)) BD_SAMT,     -- TRUONG NUOC: BAN
        sum(NVL(BF_BAMT,0)) BF_BAMT,     -- NUOC NGOAI: MUA
        sum(NVL(BF_SAMT,0)) BF_SAMT      -- NUOC NGOAI: BAN

    FROM CFMAST CF, allcode cd ,
    (
        -- Tu Doanh
        SELECT af.custid, cleardate SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            SUM(CHD.QTTY) D_BAMT,     -- Nhan CK
            0 D_SAMT,     -- Giao CK
            0 BD_BAMT,          --
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS' AND SUBSTR(CF.CUSTODYCD,4,1) = 'P' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'N'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, cleardate, CHD.TXDATE, SB.symbol, chd.tradeplace
        union all
        SELECT af.custid, cleardate SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,     -- Nhan CK
            SUM(CHD.QTTY) D_SAMT,     -- Giao CK
            0 BD_BAMT,          --
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'P' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'N'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, cleardate, CHD.TXDATE, SB.symbol, chd.tradeplace
        -- Trong nuoc
        UNION ALL
        ----- Trong nuoc: mua ck
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            SUM(CHD.QTTY) BD_BAMT,
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS'AND SUBSTR(CF.CUSTODYCD,4,1) = 'C' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'N'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        ----- Trong nuoc: ban ck
        UNION ALL
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            SUM(CHD.QTTY) BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'C' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'N'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        -- Nuoc ngoai
        UNION ALL
        --------- Nuoc ngoai: Mua ck
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            0 BD_SAMT,
            SUM(CHD.QTTY) BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS' AND SUBSTR(CF.CUSTODYCD,4,1) = 'F' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'N'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        --------- Nuoc ngoai: Ban ck
        UNION ALL
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            0 BD_SAMT,
            0 BF_BAMT,
            SUM(CHD.QTTY) BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'F' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE '%'
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'N'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
    ) A
    WHERE CF.CUSTID = A.CUSTID and cdtype = 'OD' and cdname = 'TRADEPLACE' and a.tradeplace = cd.cdval
    group by symbol
    order  by TRADATE, SYMBOL;

ELSE

    OPEN PV_REFCURSOR FOR
    SELECT
    V_TYPEDATE TYPEDATE,
    max(SETTDATE) SETTDATE,
    max(CF.CUSTODYCD) CUSTODYCD,
    SYMBOL,
    max(CF.FULLNAME) FULLNAME,
    max(TRADATE)TRADATE,
       max(case
          when tradeplace='002' then 'HNX'
          when tradeplace='001' then 'HOSE'
          when tradeplace='005' then 'UPCOM'
          when tradeplace='007' then 'TRAI PHIEU CHUYEN BIET'
          when tradeplace='008' then 'TIN PHIEU' else '' end)tradeplace ,
           I_DATE I_DATE   ,
    max(cdcontent) TRADEPLACE_NAME,
        sum(NVL(D_BAMT,0)) D_BAMT,       -- TU DOANH: MUA
        sum(NVL(D_SAMT,0)) D_SAMT,       -- TU DOANH: BAN
        sum(NVL(BD_BAMT,0)) BD_BAMT,     -- TRONG NUOC: MUA
        sum(NVL(BD_SAMT,0)) BD_SAMT,     -- TRUONG NUOC: BAN
        sum(NVL(BF_BAMT,0)) BF_BAMT,     -- NUOC NGOAI: MUA
        sum(NVL(BF_SAMT,0)) BF_SAMT      -- NUOC NGOAI: BAN
    FROM CFMAST CF, allcode cd ,
    (
        -- Tu Doanh
        SELECT af.custid, cleardate SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            SUM(CHD.QTTY) D_BAMT,     -- Nhan CK
            0 D_SAMT,     -- Giao CK
            0 BD_BAMT,          --
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS' AND SUBSTR(CF.CUSTODYCD,4,1) = 'P' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE V_STRCASHPLACE
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'Y'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, cleardate, CHD.TXDATE, SB.symbol, chd.tradeplace
        union all
        SELECT af.custid, cleardate SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,     -- Nhan CK
            SUM(CHD.QTTY) D_SAMT,     -- Giao CK
            0 BD_BAMT,          --
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'P' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ----AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE V_STRCASHPLACE
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'Y'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, cleardate, CHD.TXDATE, SB.symbol, chd.tradeplace
        -- Trong nuoc
        UNION ALL
        ----- Trong nuoc: mua ck
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            SUM(CHD.QTTY) BD_BAMT,
            0 BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS'AND SUBSTR(CF.CUSTODYCD,4,1) = 'C' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE V_STRCASHPLACE
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'Y'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        ----- Trong nuoc: ban ck
        UNION ALL
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            SUM(CHD.QTTY) BD_SAMT,
            0 BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'C' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE V_STRCASHPLACE
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'Y'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        -- Nuoc ngoai
        UNION ALL
        --------- Nuoc ngoai: Mua ck
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            0 BD_SAMT,
            SUM(CHD.QTTY) BF_BAMT,
            0 BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.ACCTNO = SE.ACCTNO
            AND CHD.DUETYPE = 'RS' AND SUBSTR(CF.CUSTODYCD,4,1) = 'F' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND AF.BANKNAME LIKE V_STRCASHPLACE
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'Y'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
        --------- Nuoc ngoai: Ban ck
        UNION ALL
        SELECT af.custid, CLEARDATE SETTDATE, CHD.TXDATE TRADATE,SB.symbol,chd.tradeplace,
            0 D_BAMT,
            0 D_SAMT,
            0 BD_BAMT,
            0 BD_SAMT,
            0 BF_BAMT,
            SUM(CHD.QTTY) BF_SAMT
        FROM vw_stschd_tradeplace_all CHD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, SBSECURITIES SB, SEMAST SE, AFTYPE AFT
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = SE.AFACCTNO AND SB.CODEID = SE.CODEID
            AND CHD.AFACCTNO || CHD.CODEID = SE.ACCTNO
            AND CHD.DUETYPE = 'RM' AND SUBSTR(CF.CUSTODYCD,4,1) = 'F' AND cf.custatcom ='Y'
            AND CF.CUSTODYCD LIKE V_CUSTODYCD AND SB.SYMBOL LIKE V_STRSYMBOL
            AND CHD.TXDATE = v_OnDate
            AND (case when v_TradePlace = '999' and chd.tradeplace IN ('001','002','005') then '999'
                    else chd.tradeplace end) like v_TradePlace
            AND chd.tradeplace IN ('001','002','005','007','008')
            ---AND (substr(af.acctno,1,4) like V_p_STRBRID or instr((V_pV_STRBRID),substr(af.acctno,1,4)) <> 0 )
            AND (CF.BRID like V_p_STRBRID or instr(V_pV_STRBRID,CF.BRID) <> 0 )
            and (CF.BRID like V_STRBRID or INSTR(V_STRBRID,CF.BRID) <> 0)
            AND (case when SB.SECTYPE = '003' then '006' else sb.sectype end) LIKE V_SECTYPE
            AND SB.SECTYPE IN ('001','006','008','003','011') --Ngay 23/03/2017 CW NamTv them sectype 011
            AND AF.BANKNAME LIKE V_STRCASHPLACE
            AND AF.ACTYPE   =    AFT.ACTYPE
            AND AFT.COREBANK LIKE 'Y'
            --AND CHD.CLEARDAY = v_Clearday
        GROUP BY af.custid, CLEARDATE, CHD.TXDATE, SB.symbol, chd.tradeplace
    ) A
    WHERE CF.CUSTID = A.CUSTID and cdtype = 'OD' and cdname = 'TRADEPLACE' and a.tradeplace = cd.cdval
    group by symbol
    order  by TRADATE, A.SYMBOL;

END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
