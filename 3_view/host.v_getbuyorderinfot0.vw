SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETBUYORDERINFOT0
(OVERAMT, AFACCTNO, ADVAMT, SECUREAMT, EXECBUYAMT, 
 EXECBUYAMTFEE, EXECBUYAMT_FEE)
BEQUEATH DEFINER
AS 
(select a.overamt + nvl(aboveramt,0) overamt, a.afacctno,
        case when hosts=0 then 0 else greatest(a.overamt + nvl(aboveramt,0) - greatest(af.mrcrlimitmax-ci.dfodamt,0),0) end advamt,
        case when hosts=0 then execbuyamt else a.secureamt + nvl(b.absecured,0) end secureamt,
        execbuyamt, execbuyamtfee,execbuyamt_fee from
    (SELECT
            SUM (  quoteprice * remainqtty * (1 + typ.deffeerate / 100-od.bratio/100)
                        + execamt* (1-(case when execqtty<=0 then 0 else dfqtty/execqtty end)) * (1 + typ.deffeerate / 100-od.bratio/100)   ) overamt,
            round(SUM (    quoteprice* remainqtty* (od.bratio/100)
                        + execamt * (od.bratio/100)
                        + execamt * (case when execqtty<=0 then 0 else dfqtty/execqtty end) * (1 + typ.deffeerate / 100 - od.bratio/100) ),0) secureamt,
            sum(od.execamt+od.feeacr) execbuyamt,
            sum(od.feeacr) execbuyamtfee,
             sum(od.execamt * (1 + typ.deffeerate / 100) ) execbuyamt_fee,
            od.afacctno afacctno,
            to_number(nvl(max(varvalue),0)) hosts
    FROM odmast od, odtype typ, sysvar sy
   WHERE od.actype = typ.actype
     AND od.txdate = (select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
     AND deltd <> 'Y'
     AND od.exectype IN ('NB', 'BC')
     --and od.stsstatus <> 'C'
     and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
     group by od.afacctno) A,
     (select od.afacctno,
        sum(greatest(od.QUOTEPRICE* od.ORDERQTTY * od.BRATIO/100 - org.QUOTEPRICE* org.ORDERQTTY * org.BRATIO/100,0)) absecured,
        sum(greatest(od.QUOTEPRICE* od.ORDERQTTY * (1 + typ.deffeerate / 100-od.BRATIO/100) - org.QUOTEPRICE* org.ORDERQTTY * (1 + orgtyp.deffeerate / 100-org.BRATIO/100),0)) aboveramt
         from odmast od,odmast org, ood, odtype typ, odtype orgtyp
        where od.orderid=ood.orgorderid
            and od.REFORDERID=org.orderid
            and od.actype=typ.actype
            and org.actype=orgtyp.actype
            and OODSTATUS='N' and od.exectype ='AB'
            and od.deltd <> 'Y' and org.deltd <>'Y'
            group by od.afacctno
      ) B,
      cimast ci,afmast af
    where  a.afacctno =b.afacctno (+)  and a.afacctno = af.acctno and af.acctno = ci.acctno
)
/
