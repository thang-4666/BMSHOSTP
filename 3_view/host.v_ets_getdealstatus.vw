SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_ETS_GETDEALSTATUS
(CUSTODYCD, FULLNAME, SYMBOL, AFACCTNO, TXDATE, 
 ORDERID, EXECQTTY, EXECAMT, ACCTNO, QTTY, 
 AMT, ISNEGATIVE, ISTRIGGER, ISCALL, ISOVERDUE, 
 ISDUE, DESCRIPTION, DTDATE, CODEID)
BEQUEATH DEFINER
AS 
SELECT DISTINCT "CUSTODYCD","FULLNAME","SYMBOL","AFACCTNO","TXDATE","ORDERID","EXECQTTY","EXECAMT","ACCTNO","QTTY","AMT","ISNEGATIVE","ISTRIGGER","ISCALL","ISOVERDUE","ISDUE","DESCRIPTION","DTDATE","CODEID" FROM (
select DISTINCT cf.custodycd, cf.fullname, sb.symbol, od.afacctno, od.txdate, od.orderid, od.execqtty, od.execamt, DTL."ACCTNO",DTL."QTTY",DTL."AMT",DTL."ISNEGATIVE",DTL."ISTRIGGER",DTL."ISCALL",DTL."ISOVERDUE",DTL."ISDUE",DTL."DESCRIPTION",DTL."DTDATE", od.codeid
from odmast od, afmast af, cfmast cf,sbsecurities sb,
(SELECT ACCTNO, TRADE QTTY, 0 amt, 'Y' ISNEGATIVE, 'N' ISTRIGGER, 'N' ISCALL, 'N' ISOVERDUE, 'N' ISDUE, '' description, lastdate dtdate FROM SEMAST WHERE TRADE<0 --BAN AM TAI KHO?N
UNION ALL SELECT v.afacctno || v.CODEID ACCTNO, v.dfqtty QTTY, v.prinnml+v.prinovd amt, 'N' isnegative,
       (case when (v.callamt>0 or (v.calltype <> 'Theo gia' and  v.rtt<v.mrate) or v.FLAGTRIGGER = 'T') then 'Y' else 'N' end) istrigger,
       (case when (v.status='A' and ((v.basicprice<=v.mrate/100*v.refprice) or (v.calltype <> 'Theo gia' and  v.rtt<v.mrate) or v.prinovd + v.oprinovd>0 or nvl(sts.NML,0)>0 or v.FLAGTRIGGER = 'C')) then 'Y' else 'N' end) iscall,
       (case when (v.prinovd + v.oprinovd)>0 then 'Y' else 'N' end) isoverdue,
       (case when nvl(sts.NML,0)>0 then 'Y' else 'N' end) isdue,
       v.description, v.rlsdate dtdate
FROM v_getdealinfo v,ALLCODE CD1,
    (select DISTINCT acctno, overduedate  from (select acctno, overduedate from lnschd union all select acctno, overduedate from lnschdhist) )ln,
    (SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
        WHERE S.OVERDUEDATE = TO_DATE((select varvalue from sysvar where grname ='SYSTEM' and varname ='CURRDATE'),'DD/MM/YYYY') AND S.NML > 0 AND S.REFTYPE IN ('P')
            AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C')
        GROUP BY S.ACCTNO, M.TRFACCTNO
        ORDER BY S.ACCTNO) sts
      where CD1.cdname = 'FLAGTRIGGER' and CD1.cdtype ='DF' AND CD1.CDVAL = v.FLAGTRIGGER
      and v.lnacctno = sts.acctno (+) and v.lnacctno = ln.acctno
      and ((v.prinovd + v.oprinovd)>0 or nvl(sts.NML,0)>0
      or (v.status='A' and ((v.basicprice<=v.mrate/100*v.refprice) or (v.calltype <> 'Theo gia' and  v.rtt<v.mrate) or v.prinovd + v.oprinovd>0 or nvl(sts.NML,0)>0 or v.FLAGTRIGGER = 'C'))
      or (v.callamt>0 or (v.calltype <> 'Theo gia' and  v.rtt<v.mrate) or v.FLAGTRIGGER = 'T'))) DTL
where od.via='W' and od.exectype='NS' and od.execqtty>0 and od.codeid=sb.codeid
and od.txdate=TO_DATE((select varvalue from sysvar where grname ='SYSTEM' and varname ='CURRDATE'),'DD/MM/RRRR')
and od.afacctno=af.acctno and af.custid=cf.custid and cf.custatcom = 'Y' AND OD.SEACCTNO = DTL.ACCTNO
)
/
