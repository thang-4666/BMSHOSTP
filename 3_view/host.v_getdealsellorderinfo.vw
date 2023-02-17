SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETDEALSELLORDERINFO
(DFACCTNO, AFACCTNO, SECUREAMT, SECUREMAT)
BEQUEATH DEFINER
AS 
(
SELECT dfacctno,afacctno, SUM(SECUREAMT) SECUREAMT,SUM(SECUREMAT) SECUREMAT
 FROM (SELECT map.refid dfacctno,od.afacctno,
           to_number(nvl(sy.varvalue,0)) * map.qtty  SECUREAMT,
           map.execqtty SECUREMAT
        FROM ODMAST OD,ODMAPEXT MAP, ODTYPE TYP, SYSVAR SY
       WHERE OD.DELTD <> 'Y'  AND OD.EXECTYPE ='MS' AND OD.ORDERID=MAP.ORDERID
        AND MAP.deltd <> 'Y' and map.TYPE='D'
           And OD.ACTYPE = TYP.ACTYPE
           and OD.TXDATE =(select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
           and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
           ) GROUP BY dfacctno,afacctno )
/
