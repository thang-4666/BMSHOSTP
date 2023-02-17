SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1029 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,

   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_ACCTNO                IN       VARCHAR2,
   EXECTYPE                 IN       VARCHAR2,
   PV_SYMBOL                IN       VARCHAR2,
   VIA                      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO THONG KE DAT LENH
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   13-02-2012   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (40);
   V_INBRID            VARCHAR2  (4);

   V_FDATE             DATE;
   V_TDATE             DATE;

   V_CUSTODYCD         VARCHAR2(50);
   V_ACCTNO            VARCHAR2(50);
   V_STRAFACCTNO       VARCHAR2(50);
   V_EXECTYPE          VARCHAR2(50);
   V_VIA               VARCHAR2(50);
   V_SYMBOL            VARCHAR2(50);

BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
   END IF;

-- GET REPORT'S PARAMETERS

   V_FDATE              :=    TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
   V_TDATE              :=    TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

   V_CUSTODYCD   := UPPER(PV_CUSTODYCD);

   IF (UPPER(PV_ACCTNO) <> 'ALL' OR PV_ACCTNO <> '' OR PV_ACCTNO <> NULL) THEN
      V_ACCTNO      := UPPER(PV_ACCTNO);
      V_STRAFACCTNO := V_ACCTNO;
   ELSE
      V_ACCTNO      := '%';
      V_STRAFACCTNO := 'ALL';
   END IF;

   IF (EXECTYPE <> 'ALL' OR EXECTYPE <> '' OR EXECTYPE <> NULL) THEN
      V_EXECTYPE      := EXECTYPE;
   ELSE
      V_EXECTYPE      := '%';
   END IF;
    IF (UPPER(VIA) <> 'ALL' OR VIA <> '' OR VIA <> NULL) THEN
      V_VIA      := VIA;
   ELSE
      V_VIA      := '%';
   END IF;

    IF (PV_SYMBOL <> 'ALL' OR PV_SYMBOL <> '')
    THEN
         V_symbol    :=    PV_SYMBOL;
    ELSE
         V_symbol    :=    '%';
    END IF;
--- GET REPORT'S DATA
OPEN PV_REFCURSOR
FOR
SELECT * FROM (
    SELECT V_STRAFACCTNO STRAFACCTNO, OD.FULLNAME, OD.CUSTODYCD, OD.AFACCTNO,
        OD.EXECTYPE, OD.TXDATE, OD.ORDERID,
        OD.QUOTEPRICE1, od.QUOTEPRICE2, OD.ORDERQTTY --, OD.DEFFEERATE
        , OD.VATRATE,
        NVL(IO.MATCHQTTY,0) MATCHQTTY, NVL(IO.MATCHPRICE,0) MATCHPRICE,
        NVL(IO.MATCHQTTY*IO.MATCHPRICE,0) MATCHAMT,
        NVL((CASE WHEN IO.MATCHQTTY <> 0 AND IO.IODFEEACR = 0 THEN
        ROUND(((IO.MATCHQTTY*IO.MATCHPRICE)*OD.DEFFEERATE/100),5)
        ELSE IO.IODFEEACR END),0) MATCHFEE, OD.SYMBOL,

        case when ioS.matchamt>0 and OD.feeacr=0 then
                  OD.deffeerate
             else
               (CASE WHEN (ioS.matchamt * OD.feeacr) = 0 THEN 0 ELSE
                   (CASE WHEN OD.TXDATE = GETCURRDATE AND OD.EXECTYPET IN('NS','SS','MS')
                         THEN round(100 * OD.feeacr/(ioS.matchamt),2)
                         WHEN OD.EXECTYPET IN('NS','SS','MS') THEN ROUND ((io.matchqtty * io.matchprice / ioS.matchamt * OD.feeacr) * 100 / (IO.MATCHPRICE*IO.MATCHQTTY), 2)
                         WHEN OD.TXDATE = GETCURRDATE AND OD.EXECTYPET IN('NB','BC')
                         THEN round(100 * OD.feeacr/(ioS.matchamt),2)
                         WHEN OD.EXECTYPET IN('NB','BC') THEN ROUND((io.matchqtty * io.matchprice/ioS.matchamt * OD.feeacr)*100/ (IO.MATCHPRICE*IO.MATCHQTTY),2) END)
               END)
             end  DEFFEERATE


    FROM (select orgorderid, sum(matchqtty * matchprice) matchamt
           from VW_IOD_ALL
           group by orgorderid
         ) ioS,
    (
        SELECT CF.FULLNAME, CF.CUSTODYCD, OD.AFACCTNO,OD.feeacr, OD.EXECTYPE EXECTYPET,
            A1.CDCONTENT EXECTYPE, OD.TXDATE, OD.ORDERID,
            (CASE WHEN OD.PRICETYPE IN ('ATO','ATC')THEN  OD.PRICETYPE  ELSE '' END ) QUOTEPRICE1 ,
            OD.QUOTEPRICE QUOTEPRICE2, OD.ORDERQTTY, ODT.DEFFEERATE,
            (CASE WHEN CF.VAT = 'Y' THEN ROUND(TO_NUMBER(SYS.VARVALUE),5) ELSE 0 END) + (CASE WHEN CF.whtax = 'Y' THEN ROUND(TO_NUMBER(SYS1.VARVALUE),5) ELSE 0 END) VATRATE,
            SB.SYMBOL
        FROM VW_ODMAST_ALL OD, ODTYPE ODT, SYSVAR SYS, Cfmast CF, AFMAST AF, ALLCODE A1, SBSECURITIES SB, SYSVAR SYS1
        WHERE OD.DELTD = 'N'
            AND ODT.ACTYPE = OD.ACTYPE AND CF.CUSTID = AF.CUSTID
            AND AF.ACTYPE NOT IN ('0000')
            AND OD.AFACCTNO = AF.ACCTNO
            AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
            AND SYS1.GRNAME = 'SYSTEM' AND SYS1.VARNAME = 'WHTAX'
            AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'EXECTYPE' AND OD.EXECTYPE = A1.CDVAL
            AND OD.CODEID = SB.CODEID
            AND OD.EXECTYPE IN ('NS','NB','MS')
            AND OD.EXECTYPE LIKE V_EXECTYPE
            AND OD.VIA LIKE V_VIA
            AND OD.TXDATE BETWEEN V_FDATE AND V_TDATE
            AND AF.ACCTNO LIKE V_ACCTNO
            AND CF.CUSTODYCD = V_CUSTODYCD
            AND SB.SYMBOL LIKE V_symbol
    ----        AND (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,AF.BRID) <> 0)
    ---        AND (INSTR(V_STRBRID,SUBSTR(AFACCTNO,1,4))>0 OR SUBSTR(AFACCTNO,1,4) LIKE V_STRBRID)
    ) OD
    LEFT JOIN
    (
        SELECT * FROM IOD
        WHERE DELTD <> 'Y'
        UNION ALL
        SELECT * FROM IODHIST
        WHERE DELTD<>'Y'
    ) IO
    ON OD.ORDERID = IO.ORGORDERID
    WHERE OD.ORDERID = ioS.orgorderid
) WHERE MATCHQTTY > 0 order by TXDATE
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
