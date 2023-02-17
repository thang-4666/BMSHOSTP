SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SS_CIMAST_BF_BATCH
(DESCRIPTION, ALTERNATEACCT, BALANCE_FLEX, TR_BANK, AMTT3_FLEX, 
 BALANCE_SBS, AMTT3_SBS, CHENHLECH)
BEQUEATH DEFINER
AS 
SELECT CI_FLEX.DESCRIPTION, ALTERNATEACCT, CI_FLEX.BALANCE BALANCE_FLEX , NVL(CI_FLEX.TR_BANK,0) TR_BANK  ,
NVL(LN_FLEX.AMTT3,0) AMTT3_FLEX,CI_SBS.BALANCE BALANCE_SBS , NVL(LN_SBS.AMTT3,0) AMTT3_SBS ,
NVL(CI_FLEX.BALANCE,0 )- NVL(CI_SBS.BALANCE ,0) CHENHLECH
FROM 
    (
        SELECT CF.CUSTODYCD||CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END DESCRIPTION,ci.acctno,
        (ALTERNATEACCT) ALTERNATEACCT, af.corebank,
         (CI.BALANCE)-  NVL( tr.namt,0)- sts.execbuyamt -ci.odamt  BALANCE, (TR_BANK.NAMT) TR_BANK,
         CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END ACCOUNTTYPE
        FROM CIMAST CI,AFMAST AF ,
        (SELECT sum( CASE WHEN TR.TXTYPE='C' THEN TR.NAMT ELSE - TR.NAMT END ) namt ,acctno FROM vw_citran_gen tr 
             WHERE busdate >= '29-DEC-2022'  AND field ='BALANCE' 
         GROUP BY acctno     
             )TR,
        (SELECT ACCTNO, SUM(NAMT) NAMT FROM vw_citran_gen  WHERE busdate >= '29-DEC-2022'  AND field ='BALANCE' AND TLTXCD ='6669' GROUP BY ACCTNO )TR_BANK,
        AFTYPE , CFMAST CF,v_getbuyorderinfo  sts 
        WHERE CI.afacctno = AF.ACCTNO
        AND AF.COREBANK='N'
        AND CI.acctno= TR.acctno(+)
        AND CI.ACCTNO =TR_BANK.acctno(+)
        AND ci.acctno = sts.afacctno(+)
        AND AF.actype= AFTYPE.actype
        AND AF.custid= CF.custid 
        --GROUP BY CF.CUSTODYCD,AFTYPE.mnemonic
     )CI_FLEX, 
    (SELECT CUSTODYCD ||accounttype DESCRIPTION , SUM( BALANCE) BALANCE FROM  cimastcv GROUP BY CUSTODYCD,accounttype )CI_SBS,
    (SELECT CF.custodycd||'T' DESCRIPTION,SUM (prinnml+prinovd) AMTT3
        FROM lnmast ln ,afmast af , aftype ,CFMAST CF
        WHERE ln.trfacctno=af.acctno 
        AND af.actype = aftype.actype
        --AND aftype.mnemonic='T3'
        AND CF.custid=AF.custid
        GROUP BY CF.custodycd
    )LN_FLEX,
    ( SELECT SUM(prinml) AMTT3, CUSTODYCD|| accounttype DESCRIPTION FROM lnmastcv WHERE accounttype ='T' GROUP BY CUSTODYCD,accounttype ) LN_SBS
WHERE CI_FLEX.DESCRIPTION =   CI_SBS.DESCRIPTION(+)
    AND CI_FLEX.DESCRIPTION =   LN_FLEX.DESCRIPTION(+)
    AND CI_FLEX.DESCRIPTION =   LN_SBS.DESCRIPTION(+)
    AND NVL(CI_FLEX.BALANCE,0)<> NVL(CI_SBS.BALANCE   ,0)
    AND substr(CI_FLEX.DESCRIPTION,11) in( 'C','M','T')
    AND alternateacct ='N' and corebank <> 'Y'
    and (case when  ACCOUNTTYPE in ('M','T') then CI_FLEX.BALANCE else 1 end )>0




UNION

SELECT CI_FLEX.DESCRIPTION, ALTERNATEACCT, CI_FLEX.BALANCE BALANCE_FLEX ,NVL( CI_FLEX.TR_BANK,0)  TR_BANK,0 AMTT3_FLEX,CI_SBS.BALANCE BALANCE_SBS , 0 AMTT3_SBS ,
NVL(CI_FLEX.BALANCE,0 )- NVL(CI_SBS.BALANCE   ,0) CHENHLECH
FROM (

SELECT CF.CUSTODYCD||CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END DESCRIPTION,ci.acctno,
(af.ALTERNATEACCT) ALTERNATEACCT,af.corebank,
 (CI.BALANCE)-  NVL( tr.namt,0)- sts.execbuyamt -ci.odamt   BALANCE, (TR_BANK.NAMT) TR_BANK,
 CASE WHEN AFTYPE.mnemonic='T3' THEN 'T' WHEN  AFTYPE.mnemonic='Margin' THEN 'M' ELSE 'C' END ACCOUNTTYPE
FROM CIMAST CI,AFMAST AF ,
(SELECT sum( CASE WHEN TR.TXTYPE='C' THEN TR.NAMT ELSE - TR.NAMT END ) namt ,acctno FROM vw_citran_gen tr 
     WHERE busdate >= '29-DEC-2022'  AND field ='BALANCE' 
 GROUP BY acctno     
     )TR,
(SELECT ACCTNO, SUM(NAMT) NAMT FROM vw_citran_gen  WHERE busdate >= '29-DEC-2022'  AND field ='BALANCE' AND TLTXCD ='6669' GROUP BY ACCTNO )TR_BANK,
AFTYPE , CFMAST CF,v_getbuyorderinfo  sts 
WHERE CI.afacctno = AF.ACCTNO
AND AF.COREBANK='N'
AND CI.acctno= TR.acctno(+)
AND CI.ACCTNO =TR_BANK.acctno(+)
AND ci.acctno = sts.afacctno(+)
AND AF.actype= AFTYPE.actype
AND AF.custid= CF.custid

--GROUP BY CF.CUSTODYCD,AFTYPE.mnemonic
 )CI_FLEX, 
(SELECT CUSTODYCD ||accounttype DESCRIPTION , SUM( BALANCE) BALANCE FROM  cimastcv GROUP BY CUSTODYCD,accounttype )CI_SBS
WHERE   CI_SBS.DESCRIPTION=CI_FLEX.DESCRIPTION (+)
AND NVL(CI_FLEX.BALANCE,0)<> NVL(CI_SBS.BALANCE ,0)
AND substr(CI_FLEX.DESCRIPTION,11) in( 'C','M','T')
AND alternateacct ='N' and corebank <> 'Y'
and (case when ACCOUNTTYPE in ('M','T') then CI_FLEX.BALANCE else 1 end )>0
/
