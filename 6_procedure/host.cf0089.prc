SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0089 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CUSTODYCD      IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
       )
IS

-- RP NAME : Bao cao cong viec dong tai khoan
-- PERSON : PhucPP
-- DATE : 03/03/2012
-- COMMENTS :    CREATE NEW
-- ---------   ------  -------------------------------------------
   V_SYMBOL  VARCHAR2 (20);
   v_CustodyCD varchar2(20);
   v_AFAcctno varchar2(20);


BEGIN
-- GET REPORT'S PARAMETERS
   v_CustodyCD:= upper(replace(CUSTODYCD,'.',''));
v_AFAcctno:= upper(replace(PV_AFACCTNO,'.',''));

if v_AFAcctno = 'ALL' or v_AFAcctno is null then
    v_AFAcctno := '%';
else
    v_AFAcctno := v_AFAcctno;
end if;


-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
       SELECT CF.CUSTODYCD, NVL(CF.PHONE,0) CUSTPHONE, cf.address, TLP.TLFULLNAME, RF.* FROM
         (SELECT *
          FROM   (SELECT DTL.TXNUM,DTL.TXDATE, DTL.FLDCD, NVL(DTL.CVALUE,DTL.NVALUE) REFVAL
                  FROM   VW_TLLOG_ALL MST, VW_TLLOGFLD_ALL DTL WHERE MST.TXNUM=DTL.TXNUM AND MST.TXDATE=DTL.TXDATE AND MST.TLTXCD = '0088' )
          PIVOT  (MAX(REFVAL) AS R FOR (FLDCD) IN
          ('03' as AFACCTNO, '04' as CRINTACR, '05' as ODINTACR, '06' as ODAMT, '07' as ADVBALANCE, '08' as BLOCKED,
          '09' as DF_QTTY, '10' as BALANCE, '11' as GROUPFEETYPE, '12' as MRCRLIMITMAX, '13' as MRCRLIMIT, '14' as T0AMT, '15' as CA_QTTY,
           '16' as GROUPLEADER, '17' as CIDATEFEEACR, '18' as DATEFEEAC, '19' as DEPOAMT, '20' as TRADE_QTTY, '21' as WAIT_QTTY, '22' as ISCAWAIT,
            '23' as EMKAMT, '24' as STANDING, '25' as FEETYPE, '30' as DES, '31' as NAME, '32' as IDCODE,
             '40' as TRADE_LIMIT_QTTY, '41' as DEPOSIT_QTTY, '42' as WITHDRAW_QTTY, '43' as SERETAIL_QTTY, '44' as NS_CHK_QTTY, '46' as TDAMT,
              '65' as DEPOFEEAMT, '66' as CIDEPOFEEACR, '67' as NB_CHK_QTTY, '68' as TRFEE, '49' as DFBLOCKAMT, '72' AS RPPTSTATUS
              )))RF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, TLPROFILES TLP, VW_TLLOG_ALL TLALL
    WHERE CF.CUSTID = AF.CUSTID
    AND AF.ACCTNO = RF.AFACCTNO_R
    AND TLALL.TXNUM = RF.TXNUM
    AND TLALL.TXDATE = RF.TXDATE
    AND TLP.TLID = TLALL.TLID
    AND CF.CUSTODYCD = v_CustodyCD
    AND AF.ACCTNO LIKE v_AFAcctno

      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
