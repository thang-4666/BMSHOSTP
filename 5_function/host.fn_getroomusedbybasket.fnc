SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getroomusedbybasket( p_codeid in varchar2, p_basketid in varchar2) return number
is
    v_currdate date;
    v_seqtty number;
begin
    v_currdate:= getcurrdate;
    select nvl(sum(se.trade +  nvl(sts.receiving,0) + nvl(OD.BUYQTTY,0) - nvl(od.EXECQTTY,0) ),0) into v_seqtty
                from semast se, afmast af, aftype aft, lntype lnt, lnsebasket lnb,mrtype mrt,
                    (select sum(BUYQTTY) BUYQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO
                            from (
                                SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                                        (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO
                                FROM odmast od,
                                    (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                                   where od.orderid = dfex.orderid(+)
                                   and od.txdate = v_currdate
                                   AND od.deltd <> 'Y'
                                   and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                                   AND od.exectype IN ('NS', 'MS','NB','BC')
                                   and od.codeid = p_codeid
                                )
                     group by AFACCTNO
                     ) OD,
                    (SELECT STS.AFACCTNO,
                            SUM(CASE WHEN STS.TXDATE <> v_currdate THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                        FROM STSCHD STS
                        WHERE STS.DUETYPE = 'RS' AND STS.STATUS ='N'
                            AND STS.DELTD <>'Y'
                            and sts.codeid = p_codeid
                            GROUP BY STS.AFACCTNO
                     ) sts
                where se.afacctno = af.acctno and se.roomchk ='Y'
                and se.codeid = p_codeid
                and lnb.actype= lnt.actype and aft.lntype = lnt.actype
                and aft.actype = af.actype and lnb.basketid = p_basketid
                and aft.mrtype = mrt.actype and mrt.mrtype in ('S','T')
                and OD.afacctno(+) =se.afacctno
                and sts.afacctno(+) =se.afacctno;

    Return v_seqtty;
exception when others then
    return 0;
end;

 
 
 
 
/
