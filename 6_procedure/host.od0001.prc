SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0001 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   CUSTODYCD                IN       VARCHAR2,
   PV_AFACCTNO              IN       VARCHAR2,
   EXECTYPE                 IN       VARCHAR2,
   SYMBOL                   IN       VARCHAR2,
   TLID                     IN       VARCHAR2,
   CURRENT_INDEX            NUMBER   DEFAULT NULL,
   OFFSET_NUMBER            NUMBER   DEFAULT NULL,
   ONL                      VARCHAR2 DEFAULT NULL
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_STREXECTYPE    VARCHAR2 (5);
   V_STRSYMBOL      VARCHAR2 (20);
   V_STRTRADEPLACE  VARCHAR2 (3);
   V_AFACCTNO       VARCHAR2 (20);
   V_CUSTODYCD       VARCHAR2 (20);

   V_NUMBUY         NUMBER (20,2);

   v_taxrate        NUMBER;
   v_whtax              NUMBER;

   --V_TRADELOG CHAR(2);
   --V_AUTOID NUMBER;
   v_TLID varchar2(10);
   V_CUR_DATE DATE ;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   v_TLID := TLID;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS
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

   --
   V_AFACCTNO := PV_AFACCTNO;

   IF  V_AFACCTNO = 'ALL' THEN
        V_AFACCTNO:= '%%';
   END IF;

   V_CUSTODYCD:= CUSTODYCD;

   SELECT TO_DATE(VARVALUE ,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

        select to_number(varvalue) into v_taxrate  from sysvar where varname = 'ADVSELLDUTY';
        select to_number(varvalue) into v_whtax  from sysvar where varname = 'WHTAX';

    BEGIN
        SELECT SUM(CASE WHEN ODM.EXECTYPE = 'NB' OR ODM.EXECTYPE = 'BC' THEN NVL(ODM.EXECAMT,0) ELSE 0 END )
        INTO V_NUMBUY
        FROM vw_odmast_all ODM, afmast af, cfmast cf,sbsecurities sb
            WHERE ODM.TXDATE >= TO_DATE(F_DATE, 'DD/MM/YYYY')
                AND ODM.TXDATE <= TO_DATE(T_DATE, 'DD/MM/YYYY')
                AND ODM.EXECTYPE IN ('NB','CB')
                AND ODM.EXECTYPE like V_STREXECTYPE
                AND ODM.EXECAMT <> 0
                AND ODM.DELTD <> 'Y'
                AND af.acctno = odm.afacctno
                AND cf.custid = af.custid
                AND cf.custodycd = V_CUSTODYCD
                AND ODM.codeid= sb.codeid
                AND SB.symbol LIKE V_STRSYMBOL
                AND ODM.afacctno like V_AFACCTNO
                and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = v_TLID );
    EXCEPTION
    WHEN no_data_found THEN
    V_NUMBUY:=0;
    END;

   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
        SELECT CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME, OD.TXDATE , OD.CLEARDATE,
            OD.EXECTYPE, OD.CODEID,SB.SYMBOL, AL.CDCONTENT EXECTYPE_NAME, OD.MATCHPRICE, OD.MATCHQTTY,
            OD.MATCHPRICE*OD.MATCHQTTY VAL_IO, OD.FEERATE,
            --(case when cf.custtype = 'B' and cf.vat = 'N' then 0 else OD.TAXRATE end) TAXRATE
        CASE WHEN  INSTR(OD.EXECTYPE,'S')>0 THEN      decode (CF.VAT,'Y',v_taxrate,'N',0) + decode (CF.WHTAX,'Y',v_whtax,'N',0) ELSE 0 END  TAXRATE
            , OD.FEEAMT,
            (case when cf.custtype = 'B' and cf.vat = 'N' and cf.whtax='N' then 0 else ODAMT*(   decode (CF.VAT,'Y',v_taxrate,'N',0) + decode (CF.WHTAX,'Y',v_whtax,'N',0))/100 end) TAXSELLAMT, nvl(V_NUMBUY,0) NUMBUY,
            OD.orderid, OD.orderqtty, OD.quoteprice
        FROM SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL,
            (
                SELECT OD.orderid, MAX(OD.orderqtty) orderqtty, MAX(OD.quoteprice) quoteprice,
                    OD.TXDATE, OD.CLEARDATE, OD.EXECTYPE, OD.AFACCTNO, OD.CODEID, OD.MATCHPRICE, SUM(OD.MATCHQTTY) MATCHQTTY,
                    ROUND( AVG(OD.FEERATE),4) FEERATE,ROUND( AVG(OD.TAXRATE),4) TAXRATE,
                    ROUND(  SUM( CASE WHEN  OD.iodfeeacr <>0 THEN OD.iodfeeacr
                            WHEN OD.iodfeeacr=0 AND OD.TXDATE<>V_CUR_DATE THEN 0 ELSE od.MATCHPRICE*MATCHQTTY * FEERATE/100 END  )) FEEAMT,
                  --  ROUND(  SUM(CASE WHEN OD.iodtaxsellamt <>0 THEN OD.iodtaxsellamt ELSE od.MATCHPRICE*MATCHQTTY *TAXRATE/100 end  )) TAXSELLAMT
                  SUM( OD.iodtaxsellamt) iodtaxsellamt, CASE WHEN INSTR(OD.EXECTYPE,'S')>0 THEN  SUM(od.MATCHPRICE*MATCHQTTY) ELSE 0 END  ODAMT
                FROM
                    (
                    SELECT  OD.orderid, OD.orderqtty, OD.quoteprice, OD.TXDATE,STS.CLEARDATE, OD.CODEID,
                        OD.EXECTYPE, iodfeeacr,iodtaxsellamt,
                        OD.AFACCTNO,IOD.MATCHPRICE, IOD.MATCHQTTY,
                        CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.TXDATE = V_CUR_DATE AND OD.STSSTATUS = 'N' THEN ROUND(ODT.DEFFEERATE,5)
                          WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.TXDATE <> V_CUR_DATE  THEN 0
                             ELSE ROUND(OD.FEEACR/OD.EXECAMT*100,3) END FEERATE,
                        CASE WHEN OD.EXECAMT >0 AND INSTR(OD.EXECTYPE,'S')>0 AND OD.STSSTATUS = 'N'
                                THEN ROUND(TO_NUMBER(SYS.VARVALUE),5) ELSE NVL(OD.TAXRATE,0) END TAXRATE
                    FROM VW_ODMAST_ALL OD,VW_STSCHD_ALL STS, VW_IOD_ALL IOD, ODTYPE ODT, SYSVAR SYS
                    WHERE  OD.ORDERID = STS.ORGORDERID AND STS.DUETYPE IN ('RM', 'RS')
                        AND OD.ORDERID = IOD.ORGORDERID AND IOD.DELTD = 'N' AND STS.DELTD = 'N' AND OD.DELTD = 'N'
                        AND ODT.ACTYPE = OD.ACTYPE
                        AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                        AND OD.TXDATE >= TO_DATE (F_DATE,'DD/MM/YYYY')
                        AND OD.TXDATE <= TO_DATE (T_DATE,'DD/MM/YYYY')
                        AND OD.EXECTYPE LIKE V_STREXECTYPE
                    ) OD
                GROUP BY OD.orderid, OD.TXDATE, OD.CLEARDATE, OD.EXECTYPE, OD.AFACCTNO, OD.CODEID, OD.MATCHPRICE
            ) OD
        WHERE OD.CODEID = SB.CODEID
            AND OD.AFACCTNO = AF.ACCTNO
            AND AF.CUSTID = CF.CUSTID
            AND AL.CDNAME = 'EXECTYPE' AND AL.CDTYPE = 'OD' AND AL.CDVAL = OD.EXECTYPE
            AND SB.SYMBOL LIKE V_STRSYMBOL
            AND AF.ACCTNO LIKE V_AFACCTNO
            --AND AF.ACTYPE NOT IN ('0000')
            AND CF.CUSTODYCD = V_CUSTODYCD
            ORDER BY OD.AFACCTNO, OD.TXDATE, SB.SYMBOL, OD.ORDERID, OD.MATCHPRICE
            ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
/
