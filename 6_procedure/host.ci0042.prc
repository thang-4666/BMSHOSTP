SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci0042 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2

 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (10);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (10);        -- USED WHEN V_NUMOPTION > 0

   V_RLSAMT           NUMBER;
   V_TOTAL_PAIDMR       NUMBER;
   V_AMT_PAIDMR       NUMBER;
   V_POOL            NUMBER;

   V_FROMDATE         DATE;
   V_TODATE           DATE;

BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;


    V_FROMDATE:=TO_DATE(F_DATE,'DD/MM/YYYY');
    V_TODATE:=TO_DATE(T_DATE,'DD/MM/YYYY');


    SELECT NVL(SUM(NAMT),0) INTO V_RLSAMT FROM VW_CITRAN_GEN WHERE TLTXCD IN ('5566') AND FIELD='BALANCE'
    AND DELTD<>'Y' AND TXDATE BETWEEN V_FROMDATE AND V_TODATE;

    SELECT NVL(SUM(CASE WHEN INSTR(TRDESC,'g')>0 THEN NAMT ELSE 0 END),0) AMT,NVL(SUM(NAMT),0) NAMT INTO V_AMT_PAIDMR,V_TOTAL_PAIDMR
    FROM VW_CITRAN_GEN WHERE TLTXCD IN ('5540','5567') AND FIELD='BALANCE' AND DELTD<>'Y'
    AND TXDATE BETWEEN V_FROMDATE AND V_TODATE;

    SELECT sum(  (NVL(MST.PRINUSED,0) + (case when mst.pooltype='SY' then nvl(afpool.afpoolused,0) else 0 end))+
        GREATEST(NVL(tran.amt,0),0)) PRINUSEDBOD INTO V_POOL
    FROM PRMASTER MST,
    (select sum(namt) amt, acctno prcode from prtran where txcd='0003' and deltd <> 'Y' and fn_check_after_batch<>1 group by  acctno) tran,
    (SELECT SUM(prlimit) afpoolused  from prmaster WHERE pooltype IN ('AF','GR') AND prstatus='A' ) afpool
    WHERE  mst.prcode=tran.prcode(+)
    AND mst.pooltype <>'TY';

OPEN PV_REFCURSOR
  FOR

     SELECT ADV.*, nvl(cspks_cfproc.fn_get_bank_outstanding(mst.bankid,mst.lmsubtype),0) ODAMT
     FROM (
             SELECT 'AD' TIEUDE, V_RLSAMT RLSAMT, V_AMT_PAIDMR AMT_PAIDMR,V_TOTAL_PAIDMR TOTAL_PAIDMR, V_STRBRID V_STRBRID,
                      CF.CUSTID,CF.FULLNAME,CF.SHORTNAME, NVL(SUM(ADV.AMT),0) AMT,NVL(SUM(ADV.FEEADV),0) FEEADV,NVL(SUM(ADV.NAMT),0) NAMT,
                      NVL(SUM(ADV_TRA.AMT_TRA),0) AMT_TRA,NVL(SUM(ADV_TRA.FEEADV_TRA),0) FEEADV_TRA,NVL(SUM(ADV_TRA.NAMT_TRA),0) NAMT_TRA
              FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                        (SELECT CUSTBANK,SUM(AMT-FEEADV) AMT,SUM(FEEADV) FEEADV,SUM(AMT) NAMT
                        FROM VW_ADVSRESLOG_ALL
                        WHERE TXDATE BETWEEN V_FROMDATE AND V_TODATE
                        GROUP BY CUSTBANK) ADV,
                        (SELECT  ADT.CUSTBANK,SUM(ADT.AMT-ADT.FEEADV) AMT_TRA,SUM(ADT.FEEADV) FEEADV_TRA,SUM(ADT.AMT) NAMT_TRA
                         FROM VW_ADVSRESLOG_ALL ADT,
                        (SELECT * FROM ADSCHD UNION ALL SELECT * FROM ADSCHDHIST) AD
                        WHERE ADT.TXDATE=AD.TXDATE AND ADT.TXNUM=AD.TXNUM
                        AND CLEARDT  BETWEEN V_FROMDATE AND V_TODATE
                         GROUP BY ADT.CUSTBANK) ADV_TRA
                WHERE CF.CUSTID=ADV.CUSTBANK(+)
                      AND CF.CUSTID=ADV_TRA.CUSTBANK(+)
                      AND CF.BRID LIKE V_STRBRID
                      HAVING NVL(SUM(ADV.AMT),0)+NVL(SUM(ADV.FEEADV),0) +NVL(SUM(ADV.NAMT),0)+
                      NVL(SUM(ADV_TRA.AMT_TRA),0)+NVL(SUM(ADV_TRA.FEEADV_TRA),0)+NVL(SUM(ADV_TRA.NAMT_TRA),0) >0
                      GROUP BY CF.CUSTID,CF.FULLNAME,CF.SHORTNAME
    ) ADV, CFLIMIT MST
    WHERE MST.LMSUBTYPE='ADV' AND MST.BANKID=ADV.CUSTID
    UNION ALL
    SELECT 'MR' TIEUDE, V_RLSAMT RLSAMT, V_AMT_PAIDMR AMT_PAIDMR,V_TOTAL_PAIDMR TOTAL_PAIDMR, V_STRBRID V_STRBRID,
          '' CUSTID,'' FULLNAME,'' SHORTNAME,0 AMT,0 FEEADV,0 NAMT,
         0 AMT_TRA,0 FEEADV_TRA,0 NAMT_TRA, V_POOL ODAMT
          FROM DUAL
        --  WHERE V_RLSAMT+V_AMT_PAIDMR+V_TOTAL_PAIDMR>0
        ;

 EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
