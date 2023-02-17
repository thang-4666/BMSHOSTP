SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0040" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_AFACCTNO              IN       VARCHAR2,
   PV_ACCTYPE               IN       VARCHAR2,
   PV_CUSTODYPLACE          IN       VARCHAR2,
   PV_EXECTYPE              IN       VARCHAR2,
   PV_MATCHTYPE             IN       VARCHAR2,
   PV_TRADEPLACE            IN       VARCHAR2,
   CASHPLACE                IN       VARCHAR2,
   BRGID                  IN       VARCHAR2,
   CAREBY                   IN       VARCHAR2,
   DATE_T                   IN       VARCHAR2,
   pv_ALTERNATEACCT         IN       VARCHAR2,
----   p_SIGNTYPE               IN       VARCHAR2
   PV_SECTYPE      IN       VARCHAR2,
   TLID            IN       VARCHAR2,
   PV_SYMBOL       IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- PERSON   DATE  COMMENTS
-- QUOCTA  29-12-2011  CREATED
-- GianhVG 03/03/2012 _modify
-- Them phan chia theo nguon tien quan ly cua khach hang
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID           VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID            VARCHAR2 (4);

   V_FDATE             DATE;
   V_TDATE             DATE;
   V_CUSTODYCD         VARCHAR2(100);
   V_AFACCTNO          VARCHAR2(100);
   V_ACCTYPE           VARCHAR2(100);
   V_CUSTODYPLACE      VARCHAR2(100);
   V_EXECTYPE          VARCHAR2(100);
   V_MATCHTYPE         VARCHAR2(100);
   V_TRADEPLACE        VARCHAR2(100);

   V_CRRDATE           DATE;
   V_STRCASHPLACE    VARCHAR2(1000);

   V_p_STRBRID           VARCHAR2 (10);

   V_STRCAREBY           VARCHAR2 (10);

   v_chinhanh           varchar2(100);
   v_noilk              VARCHAR2 (50);
   v_noidetien          varchar2(100);
   v_nhomql             varchar2(50);
   p_SIGNTYPE           varchar2(5);
   V_STRSECTYPE           VARCHAR2(40);
   V_STRTLID           VARCHAR2(6);
   V_symbol            VARCHAR2(20);
   v_strALTERNATEACCT  VARCHAR2(6);
   V_VAT NUMBER ;
   V_WHTAX NUMBER ;
BEGIN
    V_STRTLID:= TLID;
    V_STROPTION := upper(OPT);
    V_INBRID := pv_BRID;
    IF (V_STROPTION = 'A') THEN
         V_STRBRID := '%';
    ELSE if (V_STROPTION = 'B') then
            select brgrp.BRID into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    END IF;
    if(substr(V_INBRID,1,2) = '01') then
        p_SIGNTYPE := 'GDCN';
    else
        p_SIGNTYPE := 'TGD';
    end if;


-- GET REPORT'S PARAMETERS
    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '')
    THEN
         V_CUSTODYCD    :=    PV_CUSTODYCD;
    ELSE
         V_CUSTODYCD    :=    '%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '')
    THEN
         V_AFACCTNO    :=    PV_AFACCTNO;
    ELSE
         V_AFACCTNO    :=    '%';
    END IF;

    IF (PV_ACCTYPE <> 'ALL' OR PV_ACCTYPE <> '')
    THEN
         V_ACCTYPE    :=    PV_ACCTYPE;
    ELSE
         V_ACCTYPE    :=    '%';
    END IF;

    IF (pv_ALTERNATEACCT = 'ALL')
    THEN
         v_strALTERNATEACCT := '%';
    ELSE
         v_strALTERNATEACCT := pv_ALTERNATEACCT;
    END IF;

    IF (PV_CUSTODYPLACE <> 'ALL' OR PV_CUSTODYPLACE <> '')
    THEN
         V_CUSTODYPLACE    :=    CASE WHEN PV_CUSTODYPLACE='001' then 'Y' else 'N' end;
    ELSE
         V_CUSTODYPLACE    :=    '%';
    END IF;

    IF (PV_EXECTYPE <> 'ALL' OR PV_EXECTYPE <> '')
    THEN
         V_EXECTYPE    :=    PV_EXECTYPE;
    ELSE
         V_EXECTYPE    :=    '%';
    END IF;

    IF (PV_MATCHTYPE <> 'ALL' OR PV_MATCHTYPE <> '')
    THEN
         V_MATCHTYPE    :=    PV_MATCHTYPE;
    ELSE
         V_MATCHTYPE    :=    '%';
    END IF;

    IF (PV_TRADEPLACE <> 'ALL' OR PV_TRADEPLACE <> '')
    THEN
         V_TRADEPLACE    :=    PV_TRADEPLACE;
    ELSE
         V_TRADEPLACE    :=    '%';
    END IF;

    IF  (CASHPLACE <> 'ALL')
    THEN
      V_STRCASHPLACE := CASHPLACE;
    ELSE
      V_STRCASHPLACE := '%';
    END IF;

    IF(PV_SECTYPE <> 'ALL')
    THEN
        V_STRSECTYPE  := PV_SECTYPE;
    ELSE
        V_STRSECTYPE  := '%';
    END IF;

    IF (PV_SYMBOL <> 'ALL' OR PV_SYMBOL <> '')
    THEN
         V_symbol    :=    PV_SYMBOL;
    ELSE
         V_symbol    :=    '%';
    END IF;

    if(upper(BRGID) = 'ALL' OR LENGTH(BRGID) <= 1) then
        V_p_STRBRID := '%';
    else
            V_p_STRBRID := BRGID;
    end if;

    if(upper(CAREBY) = 'ALL' or LENGTH(CAREBY) <= 1) then
        V_STRCAREBY := '%';
    else
        V_STRCAREBY := CAREBY;
    end if;


    V_FDATE              :=    TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
    V_TDATE              :=    TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CRRDATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

    SELECT TO_NUMBER( VARVALUE) INTO V_VAT  FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY' AND GRNAME = 'SYSTEM';
    SELECT TO_NUMBER( VARVALUE) INTO V_WHTAX FROM SYSVAR WHERE VARNAME = 'WHTAX' AND GRNAME = 'SYSTEM';

    -- Noi luu ky
    IF PV_CUSTODYPLACE = 'ALL' THEN
        v_noilk :='Tất cả';
    ELSIF PV_CUSTODYPLACE = '001' THEN
        v_noilk := 'Tại cty CK';
    ELSE
        v_noilk := 'Lưu ký nơi khác';
    END IF;

    -- Chi nhanh

     IF (upper(BRGID) <> 'ALL' OR upper(BRGID) <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO v_chinhanh FROM BRGRP WHERE BRID LIKE BRGID;
      END;
   ELSE
      v_chinhanh   :=  ' Toàn công ty ';
   END IF;


    --Noi de tien
    IF CASHPLACE = 'ALL' THEN
        v_noidetien := 'Tất cả';
    ELSIF CASHPLACE = '000' THEN
        v_noidetien := 'Công ty chứng khoán';
    ELSIF CASHPLACE = '111' THEN
        v_noidetien :='Kết nối ngân hàng';
    ELSE
        SELECT nvl(cdcontent,' ') INTO v_noidetien
        FROM allcode WHERE cdtype = 'CF' AND cdname = 'BANKNAME'
        AND cdval = CASHPLACE;
    END IF;

    --nhom quan ly
    IF CAREBY = 'ALL' THEN
        v_nhomql := 'Tất cả';
    ELSE
        SELECT nvl(grpname,' ') INTO v_nhomql
        FROM  TLGROUPS WHERE GRPTYPE ='2' AND grpid = CAREBY;
    END IF;

OPEN PV_REFCURSOR
FOR

     SELECT  v_noidetien noi_de_tien, v_chinhanh chi_nhanh, v_noilk noi_luu_ky, v_nhomql nhom_ql, DATE_T ck_thanh_toan,
             T.TXDATE, T.SECTYPE_NAME, T.SYMBOL, T.EXECTYPE, T.EXECTYPE_NAME, T.ORDERID,
             T.CUSTODYCD, T.ACCTNO AFACCTNO, T.VAT, T.CUSTTYPE, T.CUSTTYPE_NAME, T.CUSTODY_PLACE,
             T.MATCHTYPE, T.TRADEPLACE, T.GR_I, T.GR_II, T.TYPE_OD_NAME, T.TYPE_TRANS_NAME,
             --- GIAO DICH MUA
             (CASE WHEN T.EXECTYPE IN('NB','BC') THEN NVL(IO.MATCHQTTY,0) ELSE 0 END) MATCHQTTY_B,


             (CASE WHEN T.EXECTYPE IN('NB','BC') THEN
                   (case when nvl(repo.LEG,'A') = 'V' then (case when repo.qtty = 0 then 0 else round(repo.amt1/repo.qtty,6) end) else
                   NVL(IO.MATCHPRICE,0) end) ELSE 0 END) MATCHPRICE_B,

             (CASE WHEN T.EXECTYPE IN('NB','BC') THEN
             (case when nvl(repo.LEG,'A') = 'V' then repo.amt1 else
                    (NVL(IO.MATCHQTTY,0) * NVL(IO.MATCHPRICE,0)) end) ELSE 0 END)  EXECAMT_B,

             --- GIAO DICH BAN
             (CASE WHEN T.EXECTYPE IN('NS','SS','MS') THEN NVL(IO.MATCHQTTY,0) ELSE 0 END) MATCHQTTY_S,

             (CASE WHEN T.EXECTYPE IN('NS','SS','MS') THEN
                   (case when nvl(repo.LEG,'A') = 'V' then (case when repo.qtty = 0 then 0 else round(repo.amt1/repo.qtty,0) end) else
                         NVL(IO.MATCHPRICE,0) end) ELSE 0 END) MATCHPRICE_S,

             (CASE WHEN T.EXECTYPE IN('NS','SS','MS') THEN
                   (case when nvl(repo.LEG,'A') = 'V' then repo.amt1 else
                        (NVL(IO.MATCHQTTY,0) * NVL(IO.MATCHPRICE,0)) end) ELSE 0 END) EXECAMT_S,

             --- TI LE HOA HONG --> TI LE PHI LENH
             (case when nvl(repo.LEG,'A') = 'V' then (case when repo.feeamt = 0 or repo.amt1 = 0  then 0 else round(repo.feeamt/repo.amt1,6) end) else
              (case when t.execamt>0 and t.feeacr=0  AND T.TXDATE = V_CRRDATE THEN  t.deffeerate
               when t.execamt>0 and t.feeacr=0  AND T.TXDATE <> V_CRRDATE THEN 0
             else
               (CASE WHEN (t.execamt * t.feeacr) = 0  THEN 0 ELSE
                   (CASE WHEN T.TXDATE = V_CRRDATE AND T.EXECTYPE IN('NS','SS','MS')
                         THEN round(100 * t.feeacr/(t.execamt),3)--ROUND ((io.matchqtty * io.matchprice * t.deffeerate / 100) * 100 / (IO.MATCHPRICE*IO.MATCHQTTY), 2)
                         WHEN T.EXECTYPE IN('NS','SS','MS') THEN ROUND ((io.matchqtty * io.matchprice / t.execamt * t.feeacr) * 100 / (IO.MATCHPRICE*IO.MATCHQTTY), 3)
                         WHEN T.txdate = V_CRRDATE AND T.EXECTYPE IN('NB','BC')
                         THEN round(100 * t.feeacr/(t.execamt),3)--ROUND((io.matchqtty * io.matchprice * t.deffeerate/100 )* 100 / (IO.MATCHPRICE*IO.MATCHQTTY),2)
                         WHEN T.EXECTYPE IN('NB','BC') THEN ROUND((io.matchqtty * io.matchprice/t.execamt * t.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),3) END)
               END)
             end) end)  FEE_RATE,

             --- TIEN HOA HONG
/*             case when t.execamt > 0 and t.feeacr=0 then
                  ROUND(IO.matchqtty * io.matchprice * t.deffeerate / 100, 2)
             else*/
             (case when nvl(repo.LEG,'A') = 'V' then repo.feeamt else
               (CASE WHEN t.execamt = 0 THEN 0 ELSE
                   (CASE WHEN io.iodfeeacr = 0 and t.Txdate = V_CRRDATE  THEN ROUND(IO.matchqtty * io.matchprice * t.deffeerate / 100, 2)
                         ELSE io.iodfeeacr END)
               END) end )            ---end
             FEE_AMT_DETAIL,
            --- Thue TNCN
            /*
             (CASE WHEN T.EXECTYPE IN('NS','SS','MS') AND T.VAT = 'Y' THEN
                (CASE WHEN IO.iodtaxsellamt <> 0 THEN IO.iodtaxsellamt ELSE (ROUND(IO.MATCHQTTY * IO.MATCHPRICE *
                (SELECT VARVALUE FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY' AND GRNAME = 'SYSTEM')/100, 2) +
                NVL(T.ARIGHT, 0)) END)
              ELSE 0 END) FEETAX_AMT_DETAIL,
              */
              (CASE WHEN T.EXECTYPE IN('NS','SS','MS') AND T.VAT = 'Y' THEN
                (CASE WHEN IO.iodtaxsellamt <> 0 THEN decode (T.VAT,'Y',IO.iodtaxsellamt , T.VAT,'N',0) + NVL(s.ARIGHT, 0)
                        ELSE (ROUND(IO.MATCHQTTY * IO.MATCHPRICE * DECODE (T.VAT,'Y',V_VAT,'N',0 )/100, 2) + NVL(s.ARIGHT, 0))
                    END)
              ELSE 0 END) FEETAX_AMT_DETAIL,
               (CASE WHEN T.EXECTYPE IN('NS','SS','MS') AND T.WHTAX = 'Y' THEN
                (CASE WHEN IO.iodtaxsellamt <> 0 THEN decode (T.WHTAX,'Y',IO.iodtaxsellamt , T.WHTAX,'N',0) + NVL(s.ARIGHT, 0)
                    ELSE (ROUND(IO.MATCHQTTY * IO.MATCHPRICE *  DECODE (T.WHTAX,'Y',V_WHTAX,'N',0 ) /100, 2) +  NVL(s.ARIGHT, 0))
                END)
              ELSE 0 END) WHTAX_AMT_DETAIL,

               p_SIGNTYPE SIGNTYPE,
        (CASE WHEN T.EXECTYPE IN('NS','SS','MS') /*AND T.VAT = 'Y'*/ THEN T.taxsellamt else 0 end) taxsellamt, t.sectype HD_sectype,
        T.VIA, T.username
     FROM
            (SELECT AF.ACCTNO, CF.CUSTODYCD, OD.TXDATE, OD.ORDERID, OD.CONTRAORDERID, CF.FULLNAME, CF.IDCODE, CF.IDDATE,
                CF.IDPLACE, CF.ADDRESS, cf.VAT, CF.WHTAX ,OD.EXECTYPE,
                     CASE WHEN sb.sectype IN ('003' ,'006' ,'222','012') THEN 'TP'
                          WHEN sb.sectype IN ('001', '002', '008') THEN 'CP '
                          WHEN sb.sectype IN ('011') THEN 'CW' END sectype, --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                SB.SYMBOL, ODT.DEFFEERATE , OD.FEEACR,
                od.EXECAMT EXECAMT,--io.matchamt EXECAMT,
                sts.clearday,
                         A2.CDCONTENT SECTYPE_NAME, A3.CDCONTENT EXECTYPE_NAME, CF.CUSTTYPE, OD.MATCHTYPE, od.TRADEPLACE,
                         --(TRIM(CF.CUSTTYPE) || DECODE(TRIM(SUBSTR(CF.CUSTODYCD, 4, 1)) ,'B','C',TRIM(SUBSTR(CF.CUSTODYCD, 4, 1)))) CUSTTYPE_NAME,
                         TRIM(CF.CUSTTYPE) || case when SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' then 'F' else 'C' end  CUSTTYPE_NAME,
                         STS.ARIGHT,
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
                ROUND((CASE WHEN  od.txdate <> V_CRRDATE OR od.taxsellamt <> 0  THEN decode(cf.vat,'Y',od.taxsellamt + NVL(STS.ARIGHT,0),0) --PHUC ADD 25/01/2021
                            ELSE decode(cf.vat,'Y',1,0) * OD.execamt*((SELECT VARVALUE FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY' AND GRNAME = 'SYSTEM')/100) END),0) taxsellamt
                , A4.cdcontent VIA, tlp.tlname username
             FROM
                         Vw_Odmast_Tradeplace_All OD, SBSECURITIES SB,
                         (select * from afmast where (case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000' or CASHPLACE = '---' then corebank
                                                        when CASHPLACE = '111' then corebank
                                                        else corebank || bankname end)
                                                   = case when CASHPLACE = 'ALL' then 'ALL'
                                                        when CASHPLACE = '000'  or CASHPLACE = '---' then 'N'
                                                        when CASHPLACE = '111'  then 'Y'
                                                        else 'Y' || V_STRCASHPLACE  end ) AF,
                         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ODTYPE ODT,
                         ALLCODE A2, ALLCODE A3, AFTYPE AFT, ALLCODE A4, tlprofiles tlp,MRTYPE MR,
                         (SELECT * FROM STSCHD UNION ALL SELECT * FROM STSCHDHIST) STS--,
                         /*(select orgorderid, sum(matchqtty * matchprice) matchamt , sum(iodfeeacr) iodfeeacr
                         from VW_IOD_ALL
                         group by orgorderid
                         ) io*/
             WHERE       OD.CODEID        =    SB.CODEID
                    --and od.orderid = io.orgorderid
                  AND    OD.AFACCTNO      =    AF.ACCTNO
                  and    MR.MRTYPE        LIKE  v_strALTERNATEACCT
                  AND    AFT.MRTYPE       =     MR.ACTYPE
                  AND    AF.ACCTNO        LIKE V_AFACCTNO
                --  AND    AF.ACTYPE        NOT IN ('0000')
                  AND    OD.EXECTYPE      LIKE V_EXECTYPE
                  AND    AF.CUSTID        =    CF.CUSTID
                  AND    CF.CUSTODYCD     LIKE V_CUSTODYCD
                  AND    OD.ACTYPE        =    ODT.ACTYPE
                  and A4.cdtype = 'OD' and A4.cdname = 'VIA' and A4.cdval = od.via
                  and od.tlid = tlp.tlid
                  AND    OD.DELTD         <>   'Y'
                  AND    OD.execamt >0
                  AND    OD.TXDATE        BETWEEN V_FDATE AND V_TDATE
                  AND    A2.CDNAME        =    'SECTYPE'
                  AND    A2.CDTYPE        =    'SA'
                  AND    A2.CDVAL         =    SB.SECTYPE
                  AND    A3.CDNAME        =    'EXECTYPE'
                  AND    A3.CDTYPE        =    'OD'
                  AND    A3.CDVAL         =    OD.EXECTYPE
                  AND    AF.ACTYPE        =    AFT.ACTYPE
                  AND    OD.MATCHTYPE     LIKE V_MATCHTYPE
                  AND    (case when PV_TRADEPLACE = '999' and OD.TRADEPLACE IN ('001','002') then '999'
                    else OD.TRADEPLACE end ) LIKE V_TRADEPLACE
                  and   (case when TO_NUMBER(DATE_T) = 0 then 0 else od.clearday end)     =    TO_NUMBER(DATE_T)
                  AND    OD.ORDERID       =    STS.ORGORDERID(+)
                  AND    STS.DELTD        <>   'Y'
                  AND nvl(STS.DUETYPE ,(CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)) =
                    (CASE WHEN OD.EXECTYPE IN('NB','BC') THEN 'SM' ELSE 'RM' END)
                  AND    OD.EXECTYPE      IN ('NB','NS','MS')
                  AND    OD.TRADEPLACE    IN ('001','002','005','007','008')
                  and cf.brid like V_p_STRBRID
                  and (cf.brid like V_STRBRID or instr(V_STRBRID,cf.brid) <> 0)
                  AND sb.symbol LIKE v_symbol
                  and af.careby like V_STRCAREBY
            ) T INNER JOIN VW_IOD_ALL IO ON T.ORDERID = IO.ORGORDERID
            --left join SEPITALLOCATE s on IO.ORGORDERID = s.orgorderid and IO.txnum = s.txnum and IO.txdate = s.txdate
            left join (select txnum, txdate, sum(ARIGHT) ARIGHT from SEPITALLOCATE group by txnum, txdate) s
                on IO.txnum = s.txnum and IO.txdate = s.txdate
            left join (SELECT ORDERID, REPOACCTNO, TXDATE, QTTY, AMT1,FEEAMT, LEG  FROM BONDREPO) repo
            on T.ORDERID = repo.ORDERID
     WHERE    IO.DELTD                   <>    'Y'
     AND      T.CUSTTYPE_NAME            LIKE  V_ACCTYPE
     AND      T.CUSTODY_PLACE            LIKE  V_CUSTODYPLACE
     AND      T.sectype like V_STRSECTYPE
     ORDER BY T.TXDATE, T.ORDERID, T.SYMBOL, T.ACCTNO;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;


-- End of DDL Script for Procedure HOST.OD0040
 
/
