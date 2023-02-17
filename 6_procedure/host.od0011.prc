SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0011 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   AFACCTNO       IN       VARCHAR2,
   SYMBOL         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   EXECTYPE       IN       VARCHAR2,
   PRICETYPE      IN       VARCHAR2,
   VIA            IN       VARCHAR2,
   VOUCHER        IN       VARCHAR2,
   TYPEORDER      IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION          VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID            VARCHAR2 (4);               -- USED WHEN V_NUMOPTION > 0
   V_STREXECTYPE        VARCHAR2 (5);
   V_STRSYMBOL          VARCHAR2 (20);
   V_STRTRADEPLACE      VARCHAR2 (3);
   V_STRVOUCHER         VARCHAR2 (3);
   V_STRTYPEORDER       VARCHAR2 (3);
   V_STRPRICETYPE       VARCHAR2 (10);
   V_STRVIA             VARCHAR2 (10);
    V_STRAFACCTNO       VARCHAR2 (20);

   CUR            PKG_REPORT.REF_CURSOR;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS
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

    IF (VOUCHER <> 'ALL')
   THEN
      V_STRVOUCHER := VOUCHER;
   ELSE
      V_STRVOUCHER := '%%';
   END IF;

   IF (VIA <> 'ALL')
   THEN
      V_STRVIA := VIA;
   ELSE
      V_STRVIA := '%%';
   END IF;

    IF (TYPEORDER <> 'ALL')
   THEN
      V_STRTYPEORDER := TYPEORDER;
   ELSE
      V_STRTYPEORDER := '%%';
   END IF;

    IF (PRICETYPE <> 'ALL')
   THEN
      V_STRPRICETYPE := PRICETYPE;
   ELSE
      V_STRPRICETYPE := '%%';
   END IF;

  IF (AFACCTNO <> 'ALL')
   THEN
      V_STRAFACCTNO := AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%%';
   END IF;



   --

   -- GET REPORT'S DATA

      OPEN PV_REFCURSOR
       FOR
         SELECT T.*,NVL(IO.MATCHQTTY,0) MATCHQTTY,NVL(IO.MATCHPRICE,0) MATCHPRICE FROM
                 (SELECT OD.ORDERID, od.bratio,OD.TXDATE,SB.SYMBOL,(CASE WHEN OD.PRICETYPE IN ('ATO','ATC')THEN  OD.PRICETYPE  ELSE   TO_CHAR(OD.QUOTEPRICE) END )QUOTEPRICE ,OD.ORDERQTTY,OD.CIACCTNO,CF.FULLNAME,OD.FEEACR,
                         SB.TRADEPLACE TRADEPLACE,CF.CUSTODYCD , OD.VIA  VIA,
                         (CASE  WHEN OD.REFORDERID IS NOT NULL AND OD.EXECTYPE IN('NB','BC','NS','SS') AND OD.CORRECTIONNUMBER = 0 THEN 'C' ELSE OD.EXECTYPE END)EXTY,OD.EXECTYPE,
                         (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE 'O' END ) TYORDER
                 FROM (SELECT* FROM ODMAST
                        WHERE deltd <>'Y' and (SUBSTR(ORDERID,1,4) LIKE V_STRBRID OR SUBSTR(AFACCTNO,1,4) LIKE V_STRBRID)
                        UNION ALL
                        SELECT * FROM ODMASTHIST
                        WHERE deltd <>'Y' and (SUBSTR(ORDERID,1,4) LIKE V_STRBRID OR SUBSTR(AFACCTNO,1,4) LIKE V_STRBRID) )OD,
                        SBSECURITIES SB,AFMAST AF ,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
                  WHERE  OD.CODEID=SB.CODEID
                       AND OD.CIACCTNO=AF.ACCTNO
                       AND AF.CUSTID=CF.CUSTID
                       AND OD.TXDATE >= TO_DATE (F_DATE, 'DD/MM/YYYY')
                       AND OD.TXDATE <= TO_DATE (T_DATE, 'DD/MM/YYYY')
                       AND SB.SYMBOL LIKE V_STRSYMBOL
                       AND OD.EXECTYPE LIKE V_STREXECTYPE
                       AND SB.TRADEPLACE LIKE  V_STRTRADEPLACE
                       AND OD.PRICETYPE LIKE V_STRPRICETYPE
                       AND OD.VOUCHER LIKE V_STRVOUCHER
                       AND OD.Via like V_STRVIA
                       and OD.AFACCTNO like V_STRAFACCTNO
                       AND od.bratio < 100
                       AND od.EXECTYPE  IN ('NB','BC','NS','SS','MS')
                       )T
                  LEFT JOIN
                  ( SELECT * FROM IOD
                   WHERE DELTD<>'Y'
                  UNION ALL
                 SELECT * FROM IODHIST
                  WHERE DELTD<>'Y'
                  ) IO
                  ON IO.ORGORDERID=T.ORDERID
                  WHERE T.TYORDER LIKE V_STRTYPEORDER
                  ORDER BY  T.EXECTYPE, T.SYMBOL,T.TXDATE,T.CIACCTNO
          ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
/
