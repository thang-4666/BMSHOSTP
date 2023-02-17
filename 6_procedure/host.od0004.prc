SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   CUSTID         IN       VARCHAR2

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
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0
   V_GROUP            VARCHAR2(10);
   V_STRCUSTID         VARCHAR2(20);
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_CUR_DATE      DATE;
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := OPT;
   V_FROMDATE  := to_date(F_DATE,'DD/MM/RRRR');
   V_TODATE    := to_date(T_DATE,'DD/MM/RRRR');

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

    IF  (CUSTID <> 'ALL')
   THEN
      V_STRCUSTID := CUSTID;
   ELSE
      V_STRCUSTID := '%%';
   END IF;
  SELECT TO_DATE(VARVALUE ,'dd/mm/rrrr') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

   -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA
      OPEN PV_REFCURSOR
       FOR
        SELECT CF.CUSTODYCD, CF.FULLNAME, OD.TXDATE, OD.EXECTYPE, OD.CODEID, SB.SYMBOL, AL.CDCONTENT EXECTYPE_NAME,
    OD.MATCHPRICE, OD.MATCHQTTY, OD.MATCHPRICE*OD.MATCHQTTY VAL_IO, OD.FEERATE, OD.FEEAMT, cf.commrate
        FROM SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL,
            (
         
                        SELECT OD.TXDATE, OD.CODEID,
                            (CASE WHEN OD.EXECTYPE IN('NB','BC','NS','SS') AND OD.REFORDERID IS NOT NULL
                                AND OD.CORRECTIONNUMBER = 0 and OD.ferrod = 'N' THEN 'C' ELSE OD.EXECTYPE END) EXECTYPE,
                        OD.AFACCTNO, IO.MATCHPRICE, IO.MATCHQTTY,
                       (   case when OD.execamt>0 and OD.feeacr=0  AND OD.TXDATE = V_CUR_DATE THEN  ODT.deffeerate
                           when OD.execamt>0 and OD.feeacr=0  AND OD.TXDATE <> V_CUR_DATE THEN 0
                         else
                           (CASE WHEN (OD.execamt * OD.feeacr) = 0 THEN 0 ELSE
                               (CASE WHEN OD.TXDATE = V_CUR_DATE
                                     THEN round(100 * OD.feeacr/(OD.execamt),2)
                                     ELSE  ROUND ((io.matchqtty * io.matchprice / OD.execamt * OD.feeacr) * 100 / (IO.MATCHPRICE*IO.MATCHQTTY), 2)
                                  END)
                           END)
                         end ) FEERATE,
                          (CASE WHEN OD.execamt = 0 THEN 0 ELSE
                         (CASE WHEN io.iodfeeacr = 0 and OD.Txdate = V_CUR_DATE  THEN ROUND(IO.matchqtty * io.matchprice * ODT.deffeerate / 100, 2)
                         ELSE io.iodfeeacr END)
                           END)   feeamt
                    FROM VW_ODMAST_ALL OD, VW_IOD_ALL IO, ODTYPE ODT
                    WHERE  OD.ORDERID = IO.ORGORDERID AND IO.DELTD = 'N' AND OD.DELTD = 'N'
                        AND ODT.ACTYPE = OD.ACTYPE
                        AND OD.TXDATE >= V_FROMDATE
                        AND OD.TXDATE <= V_TODATE
                     ) OD
        WHERE OD.CODEID = SB.CODEID
            AND OD.AFACCTNO = AF.ACCTNO
            AND AF.CUSTID = CF.CUSTID
            AND CF.CUSTATCOM='N'
            AND AL.CDNAME = 'EXECTYPE' AND AL.CDTYPE = 'OD' AND AL.CDVAL = OD.EXECTYPE
            AND CF.CUSTODYCD like V_STRCUSTID
        ORDER BY CF.CUSTODYCD, OD.TXDATE, SB.SYMBOL, OD.MATCHPRICE;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
