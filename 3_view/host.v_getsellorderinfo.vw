SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETSELLORDERINFO
(SEACCTNO, SECUREAMT, SECUREMTG, SERECEIVING, EXECQTTY)
BEQUEATH DEFINER
AS 
(

SELECT A.SEACCTNO, A.SECUREAMT + NVL(B.absecured,0) SECUREAMT, A.SECUREMTG, A.SERECEIVING, A.EXECQTTY FROM
    /*(
        SELECT SEACCTNO, SUM(SECUREAMT) SECUREAMT, SUM(SECUREMTG) SECUREMTG, SUM(RECEIVING) SERECEIVING, SUM(EXECQTTY) EXECQTTY
         FROM (
            SELECT OD.SEACCTNO,
                   CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
                   CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
                   0 RECEIVING, CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN OD.EXECQTTY ELSE 0 END EXECQTTY
               FROM ODMAST OD, ODTYPE TYP, SYSVAR SY
               WHERE OD.STSSTATUS='N' AND OD.EXECTYPE IN ('NS', 'SS','MS')
                   and not(nvl(od.grporder,'N')='Y' and od.matchtype='P')
                   and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
                   And OD.ACTYPE = TYP.ACTYPE
                   AND OD.TXDATE =(select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                   AND NVL(OD.GRPORDER,'N')<>'Y'
            )
        GROUP BY SEACCTNO
    ) A,*/
    ( SELECT se.acctno SEACCTNO,
                   NVL(SECUREREMAINAMT,0) + SE.EXECSELLQTTY  SECUREAMT,
                   NVL(SECUREREMAINMTG, 0) + SE.EXECMSQTTY SECUREMTG,
                   0 SERECEIVING, SE.EXECSELLQTTY EXECQTTY
               FROM  (select  SEACCTNO ,
                              SUM(CASE WHEN OD.EXECTYPE IN ('NS', 'SS') THEN to_number(nvl(varvalue,0))* OD.REMAINQTTY  ELSE 0 END) SECUREREMAINAMT,
                              SUM(CASE WHEN OD.EXECTYPE = 'MS'  THEN to_number(nvl(varvalue,0)) * OD.REMAINQTTY ELSE 0 END) SECUREREMAINMTG
                      from ODMAST OD, SYSVAR SY
                      where OD.STSSTATUS='N' AND OD.EXECTYPE IN ('NS', 'SS','MS')
                         and not(nvl(od.grporder,'N')='Y' and od.matchtype='P')
                         and od.REMAINQTTY >0
                         AND OD.TXDATE =(select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                         and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
                         AND NVL(OD.GRPORDER,'N')<>'Y'
                         GROUP BY SEACCTNO  ) OD,   semast se
               WHERE OD.Seacctno(+) = se.acctno
                   AND se.execsellqtty + nvl(od.SECUREREMAINAMT,0) + NVL(OD.SECUREREMAINMTG,0 ) >0 )A,
    (select od.SEACCTNO,
        sum(greatest(od.ORDERQTTY-org.ORDERQTTY,0)) absecured
         from odmast od,odmast org, ood, odtype typ, odtype orgtyp
        where od.orderid=ood.orgorderid
            and od.REFORDERID=org.orderid
            and od.actype=typ.actype
            and org.actype=orgtyp.actype
            and OODSTATUS='N' and od.exectype ='AS'
            and od.deltd <> 'Y' and org.deltd <>'Y'
    group by od.SEACCTNO
    ) B
    WHERE A.SEACCTNO = B.SEACCTNO (+)

)
/
