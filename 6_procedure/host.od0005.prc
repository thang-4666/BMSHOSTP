SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0005 (
   PV_REFCURSOR      IN OUT   PKG_REPORT.REF_CURSOR,
   OPT               IN       VARCHAR2,
   pv_BRID              IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2,
   PV_TRADEPLACE     IN       VARCHAR2,
   PV_SYMBOL         IN       VARCHAR2,
   PV_ODSTATUS       IN       VARCHAR2,
   PV_ODTYPE         IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION          VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID            VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_BRID            VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0

   V_INDATE             DATE;
   V_STRCUSTODYCD      VARCHAR2(20);
   V_STRTRADEPACE      VARCHAR2(20);
   V_STRSYMBOL         VARCHAR2(20);
   V_STRODSTATUS       VARCHAR2(20);
   V_STRODTYPE         VARCHAR2(20);
   v_taxrate        NUMBER;
   v_whtax              NUMBER;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
   V_STROPTION := OPT;
   V_BRID := pv_BRID;

       select to_number(varvalue) into v_taxrate  from sysvar where varname = 'ADVSELLDUTY';
        select to_number(varvalue) into v_whtax  from sysvar where varname = 'WHTAX';

   IF (OPT <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%';
   END IF;

   IF(UPPER(PV_CUSTODYCD) = 'ALL' OR PV_CUSTODYCD IS NULL) THEN
       V_STRCUSTODYCD := '%';
   ELSE
       V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
   END IF;

   IF(UPPER(PV_TRADEPLACE) = 'ALL' OR PV_TRADEPLACE IS NULL) THEN
       V_STRTRADEPACE := '%';
   ELSE
       V_STRTRADEPACE := UPPER(PV_TRADEPLACE);
   END IF;

   IF(UPPER(PV_SYMBOL) = 'ALL' OR PV_SYMBOL IS NULL) THEN
       V_STRSYMBOL := '%';
   ELSE
       V_STRSYMBOL := UPPER(PV_SYMBOL);
   END IF;

   IF(UPPER(PV_ODSTATUS) = 'ALL' OR PV_ODSTATUS IS NULL) THEN
       V_STRODSTATUS := '%';
   ELSE
       V_STRODSTATUS := UPPER(PV_ODSTATUS);
   END IF;

   IF(UPPER(PV_ODTYPE) = 'ALL' OR PV_ODTYPE IS NULL) THEN
       V_STRODTYPE := '%';
   ELSE
       V_STRODTYPE := UPPER(PV_ODTYPE);
   END IF;

   V_INDATE := TO_DATE(PV_I_DATE,'DD/MM/RRRR');

OPEN PV_REFCURSOR
FOR

SELECT DISTINCT OD.inSTRCUSTODYCD, OD.inSTRTRADEPACE, OD.inSTRSYMBOL, OD.inSTRODSTATUS,
    OD.inSTRODTYPE, OD.ORDERID, OD.TXDATE, OD.TXTIME, OD.SYMBOL, OD.QUOTEPRICE, OD.ORDERQTTY,
    OD.CIACCTNO, OD.FULLNAME, OD.brname, OD.FEEACR, OD.FEERATE, OD.CUSTODYCD , OD.VIA, OD.MATCHTYPE,
    OD.EXTY, OD.TYORDER, OD.ORSTATUS, OD.tradeplace, OD.mnemonic, OD.EXECTYPE, OD.PRICETYPE, OD.VAT,
    OD.username, OD.offname, OD.cnname
FROM(
SELECT (case when V_STRCUSTODYCD = '%' then 'ALL' else V_STRCUSTODYCD end) inSTRCUSTODYCD,
        (case when V_STRTRADEPACE = '%' then 'ALL' else A2.cdcontent end) inSTRTRADEPACE,
        (case when V_STRSYMBOL = '%' then 'ALL' else V_STRSYMBOL end) inSTRSYMBOL,
        (case when V_STRODSTATUS = '%' then 'ALL' else V_STRODSTATUS end) inSTRODSTATUS,
        (case when V_STRODTYPE = '%' then 'ALL' else V_STRODTYPE end) inSTRODTYPE,
    OD.ORDERID, OD.TXDATE, OD.TXTIME, SB.SYMBOL, (CASE WHEN OD.PRICETYPE IN ('ATO','ATC')THEN  OD.PRICETYPE
                ELSE TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE , OD.ORDERQTTY,OD.CIACCTNO,CF.FULLNAME, BR.brname,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N'
                THEN ROUND(OD.EXECAMT * ODT.DEFFEERATE/100) ELSE OD.FEEACR END FEEACR, ODT.DEFFEERATE FEERATE,
                CF.CUSTODYCD , OD.VIA  VIA, OD.MATCHTYPE,
                (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE OD.EXECTYPE END) EXTY,
                (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE 'O' END) TYORDER,
                (case when od.cancelstatus = 'N' then A1.cdcontent else A4.cdcontent end) ORSTATUS,
                A2.cdcontent tradeplace, AFT.mnemonic, A3.cdcontent EXECTYPE, OD.PRICETYPE,
                (CASE  WHEN cf.vat = 'N' then 0 else (decode (CF.VAT,'Y',v_taxrate,'N',0) + decode (CF.WHTAX,'Y',v_whtax,'N',0))/100*OD.EXECAMT END) VAT,
                tlp.tlname username, tlp2.tlname offname, br2.brname cnname
            FROM (SELECT * FROM vw_odmast_tradeplace_all WHERE deltd <> 'Y') OD,
                SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ODTYPE odt, AFTYPE AFT,
                ALLCODE A1, ALLCODE A2, allcode A3, sysvar sys, vw_tllog_all tl,
                tlprofiles tlp, tlprofiles tlp2, brgrp BR, brgrp BR2, ALLCODE A4
            WHERE OD.CODEID = SB.CODEID AND odt.actype = OD.ACTYPE AND OD.CIACCTNO = AF.ACCTNO
              --  AND AF.ACTYPE NOT IN ('0000')
                AND AF.CUSTID = CF.CUSTID AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'ORSTATUS'
                AND (CASE
                    WHEN (tl.offid IS NULL) AND od.via <> 'W'
                    AND tl.tltxcd NOT IN
                           ('8874', '8875', '8876','8877','8882','8883','8884','8885','8890','8891','8886')
                       THEN '9'
                    WHEN (tl.offid IS NOT NULL) AND tl.txstatus = '5'
                       THEN '6'
                    WHEN (tl.offid IS NOT NULL) AND tl.txstatus = '8'
                       THEN '0'
                    WHEN od.orstatus='8' Then '11'
                    ELSE od.orstatus
                 END) = A1.cdval
                AND A1.cdval LIKE V_STRODSTATUS
                AND A4.cdtype = 'OD' AND A4.cdname = 'CANCELSTATUS' and A4.cdval=OD.cancelstatus
                AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'TRADEPLACE' AND OD.tradeplace = A2.cdval
                AND AF.actype = AFT.actype
                AND A3.cdtype = 'OD' and A3.cdname = 'EXECTYPE' AND OD.EXECTYPE = A3.cdval
                and sys.varname like 'ADVSELLDUTY' and sys.grname = 'SYSTEM' and sys.editallow = 'N'
                and od.txnum = tl.txnum and od.txdate = tl.txdate and tl.tlid = tlp.tlid
                and tl.offid = tlp2.tlid(+) and tl.deltd <> 'Y' AND SUBSTR(CF.CUSTID,1,4) = BR.brid
                and BR2.brid = V_BRID
                AND OD.TXDATE = V_INDATE AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
                AND OD.tradeplace LIKE V_STRTRADEPACE AND SB.SYMBOL LIKE V_STRSYMBOL
                AND NVL(OD.voucher,'DDD') LIKE V_STRODSTATUS AND NVL(OD.EXECTYPE,'DDD') LIKE V_STRODTYPE
    UNION
    SELECT (case when V_STRCUSTODYCD = '%' then 'ALL' else V_STRCUSTODYCD end) inSTRCUSTODYCD,
        (case when V_STRTRADEPACE = '%' then 'ALL' else A2.cdcontent end) inSTRTRADEPACE,
        (case when V_STRSYMBOL = '%' then 'ALL' else V_STRSYMBOL end) inSTRSYMBOL,
        (case when V_STRODSTATUS = '%' then 'ALL' else V_STRODSTATUS end) inSTRODSTATUS,
        (case when V_STRODTYPE = '%' then 'ALL' else V_STRODTYPE end) inSTRODTYPE,
    OD.ORDERID, OD.TXDATE, OD.TXTIME, SB.SYMBOL, (CASE WHEN OD.PRICETYPE IN ('ATO','ATC')THEN  OD.PRICETYPE
                ELSE TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE , OD.ORDERQTTY,OD.CIACCTNO,CF.FULLNAME, BR.brname,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N'
                THEN ROUND(OD.EXECAMT * ODT.DEFFEERATE/100) ELSE OD.FEEACR END FEEACR, ODT.DEFFEERATE FEERATE,
                CF.CUSTODYCD , OD.VIA  VIA, OD.MATCHTYPE,
                (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE OD.EXECTYPE END) EXTY,
                (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE 'O' END) TYORDER,
                (case when od.cancelstatus = 'N' then A1.cdcontent else A4.cdcontent end) ORSTATUS,
                A2.cdcontent tradeplace, AFT.mnemonic, A3.cdcontent EXECTYPE, OD.PRICETYPE,
                (CASE  WHEN cf.vat = 'N' then 0 else (decode (CF.VAT,'Y',v_taxrate,'N',0) + decode (CF.WHTAX,'Y',v_whtax,'N',0))/100*OD.EXECAMT END) VAT,
                tlp.tlname username, tlp2.tlname offname, br2.brname cnname
            FROM (SELECT * FROM vw_odmast_tradeplace_all WHERE deltd <> 'Y') OD,
                SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ODTYPE odt, AFTYPE AFT,
                ALLCODE A1, ALLCODE A2, allcode A3, sysvar sys, vw_tllog_all tl,
                tlprofiles tlp, tlprofiles tlp2, brgrp BR, brgrp BR2, ALLCODE A4
            WHERE OD.CODEID = SB.CODEID AND odt.actype = OD.ACTYPE AND OD.CIACCTNO = AF.ACCTNO
              --  AND AF.ACTYPE NOT IN ('0000')
                AND AF.CUSTID = CF.CUSTID AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'ORSTATUS'
                AND (CASE
                    WHEN (tl.offid IS NULL) AND od.via <> 'W'
                    AND tl.tltxcd NOT IN
                           ('8874', '8875', '8876','8877','8882','8883','8884','8885','8890','8891','8886')
                       THEN '9'
                    WHEN (tl.offid IS NOT NULL) AND tl.txstatus = '5'
                       THEN '6'
                    WHEN (tl.offid IS NOT NULL) AND tl.txstatus = '8'
                       THEN '0'
                    WHEN od.orstatus='8' Then '11'
                    ELSE od.orstatus
                 END) = A1.cdval
                AND A4.cdtype = 'OD' AND A4.cdname = 'CANCELSTATUS' and A4.cdval=OD.cancelstatus
                AND A4.cdval LIKE V_STRODSTATUS
                AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'TRADEPLACE' AND OD.tradeplace = A2.cdval
                AND AF.actype = AFT.actype
                AND A3.cdtype = 'OD' and A3.cdname = 'EXECTYPE' AND OD.EXECTYPE = A3.cdval
                and sys.varname like 'ADVSELLDUTY' and sys.grname = 'SYSTEM' and sys.editallow = 'N'
                and od.txnum = tl.txnum and od.txdate = tl.txdate and tl.tlid = tlp.tlid
                and tl.offid = tlp2.tlid(+) and tl.deltd <> 'Y' AND SUBSTR(CF.CUSTID,1,4) = BR.brid
                and BR2.brid = V_BRID
                AND OD.TXDATE = V_INDATE AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
                AND OD.tradeplace LIKE V_STRTRADEPACE AND SB.SYMBOL LIKE V_STRSYMBOL
                AND NVL(OD.voucher,'DDD') LIKE V_STRODSTATUS AND NVL(OD.EXECTYPE,'DDD') LIKE V_STRODTYPE
) OD
   ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
