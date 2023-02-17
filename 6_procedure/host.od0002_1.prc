SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0002_1 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2,
   EXECTYPE       IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   VIA            IN       VARCHAR2,
   GRCAREBY       IN       VARCHAR2,
   CUSTTYPE         IN       VARCHAR2,
   CUSTATCOM        IN       VARCHAR2,
   MAKER      IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   MARGIN         IN       VARCHAR2,
   CONFIRM        IN       VARCHAR2
   )
IS

--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NGOCVTT   11-08-15 CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION          VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STREXECTYPE        VARCHAR2 (5);
   V_STRSYMBOL          VARCHAR2 (20);
   V_STRTRADEPLACE      VARCHAR2 (3);
  -- V_STRTYPEORDER       VARCHAR2 (3);
   V_STRCONFIRM      VARCHAR2 (10);
   V_STRVIA             VARCHAR2 (10);
   V_StrCAREBY VARCHAR2 (20);
   V_STRCUSTTYPE       VARCHAR2(20);
   V_STRCUSTATCOM      VARCHAR2(20);
   V_STRMAKER           VARCHAR2(20);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_CURRDATE       DATE;

   V_STRCUSTODYCD   VARCHAR2(20);
   V_I_BRID          VARCHAR2(20);
   V_STRMARGIN      VARCHAR2(20);


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;
   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF (TRADEPLACE <> 'ALL')
   THEN
      V_STRTRADEPLACE := TRADEPLACE;
   ELSE
      V_STRTRADEPLACE := '%%';
   END IF;


   --
    IF (SYMBOL <> 'ALL')
   THEN
      V_STRSYMBOL := SYMBOL;
   ELSE
      V_STRSYMBOL := '%%';
   END IF;
   --
   IF (EXECTYPE <> 'ALL')
   THEN
      V_STREXECTYPE := EXECTYPE;
   ELSE
      V_STREXECTYPE := '%%';
   END IF;


   IF (VIA <> 'ALL')
   THEN
      V_STRVIA := VIA;
   ELSE
      V_STRVIA := '%%';
   END IF;


   IF (GRCAREBY <> 'ALL')
  THEN
     V_StrCAREBY := GRCAREBY;
  ELSE
      V_StrCAREBY:='%';
   END IF;

    if(CUSTTYPE <> 'ALL' ) THEN
        V_STRCUSTTYPE := CUSTTYPE;
    else
        V_STRCUSTTYPE := '%';
    end if;

        if(PV_CUSTODYCD = 'ALL' ) THEN
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := PV_CUSTODYCD;
    end if;

    if(I_BRIDGD = 'ALL' ) THEN
        V_I_BRID := '%';
    else
        V_I_BRID := I_BRIDGD;
    end if;

    if(MARGIN = 'ALL' ) THEN
        V_STRMARGIN := '%';
    else
        V_STRMARGIN := MARGIN;
    end if;

        if(CONFIRM = 'ALL' ) THEN
        V_STRCONFIRM := '%';
    else
        V_STRCONFIRM := CONFIRM;
    end if;

      if(CUSTATCOM = 'ALL' ) THEN
        V_STRCUSTATCOM := '%';
    else
        V_STRCUSTATCOM := CUSTATCOM;
    end if;


    if(UPPER(MAKER) = 'ALL' or LENGTH(MAKER) <= 1 ) THEN
        V_STRMAKER := '%';
    else
        V_STRMAKER := MAKER;
    end if;

        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';


   -- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR
     SELECT V_CURRDATE CURRENTDATE,V_STRMARGIN MARGIN,V_STRCUSTATCOM CUSTTAT, T.BRID,T.BRNAME,T.TXTIME, T.TXDATE,  T.SYMBOL,
             T.EXECTYPE, T.EXECTYPE_NAME, T.ORDERID,T.REFORDERID,T.FULLNAME,T.IDCODE,
             T.CUSTODYCD, T.ACCTNO AFACCTNO, T.MRTYPE,CASE when T.VAT='Y' OR T.WHTAX ='Y' THEN 'Y' ELSE 'N' END VAT , T.CUSTTYPE,
             T.MATCHTYPE, T.TRADEPLACE, NVL(IO.MATCHQTTY,0) MATCHQTTY, NVL(IO.MATCHPRICE,0)  MATCHPRICE,
             (NVL(IO.MATCHQTTY,0) * NVL(IO.MATCHPRICE,0))EXECAMT,T.QUOTEPRICE,T.ORDERQTTY,
              (case when t.execamt>0 and t.feeacr=0  AND T.TXDATE = V_CURRDATE THEN  t.deffeerate
               when t.execamt>0 and t.feeacr=0  AND T.TXDATE <> V_CURRDATE THEN 0
              else
               (CASE WHEN (t.execamt * t.feeacr) = 0 THEN 0 ELSE
                   (CASE WHEN T.TXDATE = V_CURRDATE
                         THEN round(100 * t.feeacr/(t.execamt),2)
                         ELSE ROUND ((io.matchqtty * io.matchprice / t.execamt * t.feeacr) * 100 / (IO.MATCHPRICE*IO.MATCHQTTY), 2)
                     END)
               END)
              end)  FEE_RATE,

               (CASE WHEN t.execamt = 0 THEN 0 ELSE
                   (CASE WHEN io.iodfeeacr = 0 and t.Txdate = getcurrdate  THEN ROUND(IO.matchqtty * io.matchprice * t.deffeerate / 100, 2)
                         ELSE io.iodfeeacr END)
               END)    FEE_AMT_DETAIL,  T.VIA, T.username,T.SAN,NVL(CON.CONFIRMED,'N') CONFIRM,T.PRODUCTTYPE
     FROM
            (SELECT AF.ACCTNO, CF.CUSTODYCD, OD.TXDATE, OD.ORDERID, OD.CONTRAORDERID, CF.FULLNAME, CF.IDCODE, CF.IDDATE,
                CF.IDPLACE, CF.ADDRESS, cf.VAT,cf.whtax , OD.EXECTYPE,SB.SYMBOL, ODT.DEFFEERATE , OD.FEEACR,od.EXECAMT EXECAMT,
                A3.CDCONTENT EXECTYPE_NAME, CF.CUSTTYPE, OD.MATCHTYPE, SB.TRADEPLACE,OD.QUOTEPRICE,OD.ORDERQTTY,
                A4.cdcontent VIA, tlp.tlname username,OD.TXTIME,MR.MRTYPE,A5.CDCONTENT SAN,BR.BRID,
                 BR.BRNAME,OD.REFORDERID,A0.CDCONTENT PRODUCTTYPE
             FROM
                         VW_ODMAST_ALL OD, SBSECURITIES SB,AFMAST AF,
                         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ODTYPE ODT,
                          ALLCODE A3, AFTYPE AFT, ALLCODE A4, tlprofiles tlp,MRTYPE MR,ALLCODE A5,ALLCODE A0,
                         ( SELECT BR.BRID,BR.BRNAME,TL.GRPID CAREBY FROM BRGRP BR, TLGROUPS TL
                         WHERE TL.GRPTYPE='2' AND TL.GRPID NOT IN (SELECT CA.GRPID
                             FROM TRADEPLACE PA, TRADECAREBY CA
                             WHERE  PA.TRAID=CA.TRADEID AND PA.BRID=SUBSTR(BR.BRID,1,4))
                         UNION ALL
                         SELECT BRID||TRAID BRID, TRADENAME BRNAME, CA.GRPID CAREBY
                         FROM TRADEPLACE PA, TRADECAREBY CA WHERE PA.TRAID=CA.TRADEID) BR
             WHERE       OD.CODEID        =    SB.CODEID
                  AND    OD.AFACCTNO      =    AF.ACCTNO
                  AND    AFT.MRTYPE       =     MR.ACTYPE
                  AND    AF.CUSTID        =    CF.CUSTID
                  AND    OD.ACTYPE        =    ODT.ACTYPE
                  and    od.tlid          =    tlp.tlid
                  AND    CF.BRID          =    SUBSTR(BR.BRID,1,4)
                  AND    CF.CAREBY        =    BR.CAREBY
                  and    A4.cdtype        =    'OD' and A4.cdname = 'VIA' and A4.cdval = od.via
                  AND    A3.CDNAME        =    'EXECTYPE'AND A3.CDTYPE = 'OD' AND A3.CDVAL = OD.EXECTYPE
                  AND    A5.CDNAME        =    'TRADEPLACE'AND A5.CDTYPE = 'OD' AND A5.CDVAL = SB.TRADEPLACE
                  AND    A0.CDTYPE        =    'CF' AND A0.CDNAME='PRODUCTTYPE' AND AFT.PRODUCTTYPE=A0.CDVAL
                  AND    AF.ACTYPE        =    AFT.ACTYPE
                  AND    OD.TXDATE       BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
                  AND    CF.CUSTODYCD    LIKE   V_STRCUSTODYCD
                  AND    (CASE WHEN OD.EXECTYPE IN ('CS','CB') THEN 'CANCEL'
                  WHEN   OD.EXECTYPE IN ('AB','AS') THEN 'ADJUST' ELSE 'ORDER' END)   LIKE   V_STREXECTYPE
                  AND    SB.tradeplace   LIKE   V_STRTRADEPLACE
                  AND    OD.VIA          LIKE   V_STRVIA
                  AND    CF.CAREBY       LIKE   V_StrCAREBY
                  AND    OD.TLID         LIKE   V_STRMAKER
                  AND    CF.CUSTTYPE     LIKE   V_STRCUSTTYPE
                  AND    CF.CUSTATCOM    LIKE   V_STRCUSTATCOM
                  AND    MR.MRTYPE       LIKE   V_STRMARGIN


            ) T LEFT JOIN VW_IOD_ALL IO ON T.ORDERID = IO.ORGORDERID
            LEFT JOIN CONFIRMODRSTS CON ON T.ORDERID = CON.ORDERID
            WHERE NVL(CON.CONFIRMED,'N') LIKE V_STRCONFIRM
              AND   T.SYMBOL       LIKE   V_STRSYMBOL
              AND   T.BRID       LIKE V_I_BRID
     ORDER BY  T.TXDATE,T.TXTIME,T.CUSTODYCD, T.ACCTNO
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
