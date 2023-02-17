SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0012 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   TLID                     IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- B?O C?O GIAO D?CH CH?NG KHO?N THEO S? T?I KHO?N KI? B?NG K?HOA H?NG M? GI?I PH?T SINH TRONG TH?NG
-- PERSON   DATE  COMMENTS
-- QUOCTA  29-12-2011  CREATED
-- GianhVG 03/03/2012 _modify
-- Them phan chia theo nguon tien quan ly cua khach hang
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID           VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID            VARCHAR2 (4);

   V_CURRDATE          DATE;
   V_STRTLID           VARCHAR2(6);
   V_TAXRATE NUMBER ;
   V_WHTAX NUMBER ;
/*   V_FDATE             DATE;
   V_TDATE             DATE;
   V_CUSTODYCD         VARCHAR2(100);
   V_AFACCTNO          VARCHAR2(100);
   V_ACCTYPE           VARCHAR2(100);
   V_CUSTODYPLACE      VARCHAR2(100);
   V_EXECTYPE          VARCHAR2(100);
   V_MATCHTYPE         VARCHAR2(100);
   V_TRADEPLACE        VARCHAR2(100);

   V_CRRDATE           DATE;
   V_STRCASHPLACE      VARCHAR2(1000);


   V_pV_STRBRID        VARCHAR2 (50);
   V_p_STRBRID         VARCHAR2 (10);
   V_STRCAREBY         VARCHAR2 (10);

   v_chinhanh          varchar2(100);
   v_noilk             VARCHAR2 (50);
   v_noidetien         varchar2(100);
   v_nhomql            varchar2(50);

   V_STRCLEARDAY       number;
   V_STRTLID           VARCHAR2(6);
   V_symbol           VARCHAR2(6);*/

BEGIN

    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    V_STRTLID := TLID;
    IF (V_STROPTION = 'A') THEN
         V_STRBRID := '%';
    ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    END IF;

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CURRDATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';
    select to_number(varvalue) into v_taxrate  from sysvar where varname = 'ADVSELLDUTY';
    select to_number(varvalue) into v_whtax  from sysvar where varname = 'WHTAX';

OPEN PV_REFCURSOR
FOR
    SELECT T.TXDATE, T.SECTYPE_NAME, T.SYMBOL, T.EXECTYPE, T.EXECTYPE_NAME, T.ORDERID,
        T.CUSTODYCD, T.ACCTNO AFACCTNO, T.VAT, T.CUSTTYPE, T.CUSTTYPE_NAME, T.CUSTODY_PLACE,
        T.MATCHTYPE, T.TRADEPLACE, T.GR_I, T.GR_II, T.TYPE_OD_NAME, T.TYPE_TRANS_NAME,
        --- GIAO DICH MUA
        (CASE WHEN T.EXECTYPE IN('NB','BC') THEN NVL(IO.MATCHQTTY,0) ELSE 0 END) MATCHQTTY_B,
        (CASE WHEN T.EXECTYPE IN('NB','BC') THEN NVL(IO.MATCHPRICE,0) ELSE 0 END) MATCHPRICE_B,
        (CASE WHEN T.EXECTYPE IN('NB','BC') THEN (NVL(IO.MATCHQTTY,0) * NVL(IO.MATCHPRICE,0)) ELSE 0 END) EXECAMT_B,

        --- GIAO DICH BAN
        (CASE WHEN T.EXECTYPE IN('NS','SS','MS') THEN NVL(IO.MATCHQTTY,0) ELSE 0 END) MATCHQTTY_S,
        (CASE WHEN T.EXECTYPE IN('NS','SS','MS') THEN NVL(IO.MATCHPRICE,0) ELSE 0 END) MATCHPRICE_S,
        (CASE WHEN T.EXECTYPE IN('NS','SS','MS') THEN (NVL(IO.MATCHQTTY,0) * NVL(IO.MATCHPRICE,0)) ELSE 0 END) EXECAMT_S,

        --- TI LE HOA HONG --> TI LE PHI LENH
        case when t.execamt > 0 and t.feeacr=0 then t.deffeerate else
        (CASE WHEN (t.execamt * t.feeacr) = 0 THEN 0 ELSE
        (CASE WHEN T.TXDATE = V_CURRDATE AND T.EXECTYPE IN('NS','SS','MS')
        THEN round(100 * t.feeacr/(t.execamt),2)
        WHEN T.EXECTYPE IN('NS','SS','MS') THEN ROUND ((io.matchqtty * io.matchprice / t.execamt * t.feeacr) * 100 / (IO.MATCHPRICE*IO.MATCHQTTY), 2)
        WHEN T.txdate = V_CURRDATE AND T.EXECTYPE IN('NB','BC')
        THEN round(100 * t.feeacr/(t.execamt),2)
        WHEN T.EXECTYPE IN('NB','BC') THEN ROUND((io.matchqtty * io.matchprice/t.execamt * t.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2) END)
        END)
        end  FEE_RATE,

        --- TIEN HOA HONG
        (CASE WHEN t.execamt = 0 THEN 0 ELSE
        (CASE WHEN T.TXDATE = v_currdate THEN ROUND(IO.matchqtty * io.matchprice * t.deffeerate / 100, 2)
        ELSE io.iodfeeacr END)
        END)             ---end
        FEE_AMT_DETAIL,
        --- THUE TNCN
        (CASE WHEN T.EXECTYPE IN('NS','SS','MS') AND T.VAT = 'Y' THEN
        ROUND(IO.MATCHQTTY * IO.MATCHPRICE * (decode (T.VAT,'Y',V_TAXRATE,'N',0) + decode (T.WHTAX,'Y',V_WHTAX,'N',0))/100, 2) + NVL(T.ARIGHT, 0)
        ELSE 0 END) FEETAX_AMT_DETAIL, t.clearday,
        (CASE WHEN T.EXECTYPE IN('NS','SS','MS') AND T.VAT = 'Y' THEN T.taxsellamt else 0 end) taxsellamt,
        T.VIA, T.username
     FROM
            (SELECT AF.ACCTNO, CF.CUSTODYCD, OD.TXDATE, OD.ORDERID, OD.CONTRAORDERID, CF.FULLNAME, CF.IDCODE, CF.IDDATE,
                CF.IDPLACE, CF.ADDRESS, CF.VAT,CF.WHTAX, OD.EXECTYPE,
                SB.SYMBOL, ODT.DEFFEERATE , OD.FEEACR, io.matchamt EXECAMT,
                    sts.cleardate clearday,
                         A2.CDCONTENT SECTYPE_NAME, A3.CDCONTENT EXECTYPE_NAME, CF.CUSTTYPE, OD.MATCHTYPE, SB.TRADEPLACE,
                         (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) CUSTTYPE_NAME, STS.ARIGHT,
                         (CASE WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'IC' THEN utf8nums.c_const_custtype_custodycd_ic
                               WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'BC' THEN utf8nums.c_const_custtype_custodycd_bc
                               WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'IF' THEN utf8nums.c_const_custtype_custodycd_if
                               WHEN (TRIM(CF.CUSTTYPE) || TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'BF' THEN utf8nums.c_const_custtype_custodycd_bf
                          ELSE NULL END) GR_I,
                         (CASE WHEN (TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'C' THEN utf8nums.c_const_custodycd_type_c
                               WHEN (TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'F' THEN utf8nums.c_const_custodycd_type_f
                               WHEN (TRIM(SUBSTR(CF.CUSTODYCD, 4, 1))) = 'P' THEN utf8nums.c_const_custodycd_type_p
                          ELSE NULL END) GR_II,
                         CF.CUSTATCOM CUSTODY_PLACE,
                         (CASE WHEN OD.PRICETYPE IN('ATO','ATC') AND OD.EXECTYPE IN('NB','BC') THEN OD.PRICETYPE
                               WHEN OD.EXECTYPE  IN('NB','BC') THEN TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE_B,
                         (CASE WHEN OD.PRICETYPE IN('ATO','ATC') AND OD.EXECTYPE IN('NS','SS') THEN OD.PRICETYPE
                               WHEN OD.EXECTYPE  IN('NS','SS','MS') THEN TO_CHAR(OD.QUOTEPRICE) END )QUOTEPRICE_S,
                         (CASE WHEN OD.EXECTYPE  IN('NB','BC') THEN OD.ORDERQTTY END) ORDERQTTY_B,
                         (CASE WHEN OD.EXECTYPE  IN('NS','SS','MS') THEN OD.ORDERQTTY END) ORDERQTTY_S,
                         (CASE WHEN OD.EXECTYPE  = 'NS' THEN 'TT'
                               WHEN OD.EXECTYPE  = 'MS' THEN 'CC'
                               ELSE NULL END) TYPE_OD_NAME,
                         (CASE WHEN OD.EXECTYPE  IN('NS', 'MS') THEN 'S' ELSE 'B' END) TYPE_TRANS_NAME,
                         od.taxsellamt, A4.cdcontent VIA, tlp.tlname username
             FROM odmast OD, SBSECURITIES SB, afmast  AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ODTYPE ODT,
                ALLCODE A2, ALLCODE A3, AFTYPE AFT, ALLCODE A4, tlprofiles tlp,
                STSCHD  STS,
                         (select orgorderid, sum(matchqtty * matchprice) matchamt
                         from VW_IOD_ALL where txdate = V_CURRDATE
                         group by orgorderid
                         ) io
             WHERE OD.CODEID        =    SB.CODEID
                  and od.orderid = io.orgorderid
                  AND    OD.AFACCTNO      =    AF.ACCTNO
                  AND    AF.CUSTID        =    CF.CUSTID
                  AND    OD.ACTYPE        =    ODT.ACTYPE
                  and A4.cdtype = 'OD' and A4.cdname = 'VIA' and A4.cdval = od.via
                  and od.tlid = tlp.tlid
                  AND    OD.DELTD         <>   'Y'
                  AND    OD.TXDATE = V_CURRDATE
                  AND    A2.CDNAME        =    'SECTYPE'
                  AND    A2.CDTYPE        =    'SA'
                  AND    A2.CDVAL         =    SB.SECTYPE
                  AND    A3.CDNAME        =    'EXECTYPE'
                  AND    A3.CDTYPE        =    'OD'
                  AND    A3.CDVAL         =    OD.EXECTYPE
                  AND    AF.ACTYPE        =    AFT.ACTYPE
                  AND    OD.ORDERID       =    STS.ORGORDERID(+)
                  AND    STS.DELTD        <>   'Y'
                  AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                  AND    OD.EXECTYPE      IN ('NB','NS','MS')
                  AND    SB.TRADEPLACE    IN ('001','002','005')
                  and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID)
            ) T INNER JOIN VW_IOD_ALL IO ON T.ORDERID = IO.ORGORDERID and IO.DELTD <>    'Y'
     ORDER BY T.TXDATE, T.SYMBOL, T.ACCTNO;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;


-- End of DDL Script for Procedure HOST.OD0040

 
 
 
 
/
