SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getusedselimit (p_acctno IN VARCHAR2, p_codeid in varchar2)
RETURN NUMBER
  IS
l_amt number;
BEGIN
    select trade + receiving - EXECQTTY + BUYQTTY  into l_amt
    from (
      select se.codeid, af.actype,se.afacctno,se.acctno, se.trade + se.grpordamt trade, nvl(sts.receiving,0) receiving,nvl(BUYQTTY,0) BUYQTTY,nvl(od.EXECQTTY,0) EXECQTTY
       from semast se inner join afmast af on se.afacctno =af.acctno
       left join
       (select sum(BUYQTTY) BUYQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                            from (
                                SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                                        (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                                FROM odmast od, afmast af,
                                    (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                                   where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                                   and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                                   AND od.deltd <> 'Y'
                                   and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                                   AND od.exectype IN ('NS', 'MS','NB','BC')
                                )
                     group by AFACCTNO, CODEID
        ) OD
       on OD.afacctno =se.afacctno and OD.codeid =se.codeid
       left join
       (SELECT STS.CODEID,STS.AFACCTNO,
                            SUM(CASE WHEN STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                        FROM STSCHD STS, ODMAST OD, ODTYPE TYP, sysvar sy
                        WHERE STS.DUETYPE = 'RS' AND STS.STATUS ='N'
                            and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                            AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                            GROUP BY STS.AFACCTNO,STS.CODEID
        ) sts
       on sts.afacctno =se.afacctno and sts.codeid=se.codeid
       where se.afacctno = p_acctno and se.codeid = p_codeid
    );


    return l_amt;
EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
/
