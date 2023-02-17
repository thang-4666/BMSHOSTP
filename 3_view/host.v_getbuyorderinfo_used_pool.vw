SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETBUYORDERINFO_USED_POOL
(OVERAMT, AFACCTNO, ADVAMT, SECUREAMT, EXECBUYAMT)
BEQUEATH DEFINER
AS 
select nvl(a.overamt,0) + nvl(aboveramt,0) overamt, af.acctno afacctno,
        case when hosts=0 then 0 else greatest(nvl(a.overamt,0) + nvl(aboveramt,0) - greatest(af.mrcrlimitmax-ci.dfodamt,0),0) end advamt,
        case when hosts=0 then nvl(a.execbuyamt,0) else nvl(a.secureamt,0) + nvl(b.absecured,0) end secureamt,
        nvl(a.execbuyamt,0) execbuyamt
    from
    (SELECT
            SUM (  quoteprice * remainqtty * (1 + typ.deffeerate / 100-od.bratio/100)
                        + execamt* (1-(case when execqtty<=0 then 0 else dfqtty/execqtty end)) * (1 + typ.deffeerate / 100-od.bratio/100)   ) overamt,
            round(SUM (    quoteprice* remainqtty* (od.bratio/100)
                        + execamt * (od.bratio/100)
                        + execamt * (case when execqtty<=0 then 0 else dfqtty/execqtty end) * (1 + typ.deffeerate / 100 - od.bratio/100) ),0) secureamt,
            sum(od.execamt+case when od.feeacr>0 then od.feeacr else od.execamt*typ.deffeerate / 100 end) execbuyamt,
            od.afacctno afacctno,
            to_number(nvl(max(sy_HOSTATUS.varvalue),0)) hosts
    FROM odmast od, odtype typ, sysvar sy_HOSTATUS, sysvar sy_CURRDATE
   WHERE od.actype = typ.actype
     AND od.txdate = to_date(sy_CURRDATE.VARVALUE,'DD/MM/RRRR')
     AND deltd <> 'Y'
     AND od.exectype IN ('NB', 'BC')
     and od.stsstatus <> 'C'
     and sy_HOSTATUS.grname='SYSTEM' and sy_HOSTATUS.varname='HOSTATUS'
     and sy_CURRDATE.grname='SYSTEM' and sy_CURRDATE.varname='CURRDATE'
     AND EXISTS(SELECT TXNUM FROM PRINUSEDLOG LOG WHERE LOG.TXNUM=OD.TXNUM AND LOG.TXDATE=OD.TXDATE)
     group by od.afacctno) A,
     (select od.afacctno,
        sum(greatest((od.ORDERQTTY-org.execqtty) * od.BRATIO/100 * od.QUOTEPRICE - org.remainqtty * org.QUOTEPRICE * org.BRATIO/100  ,0)) absecured,
        sum(greatest((od.ORDERQTTY-org.execqtty)* (1 + typ.deffeerate / 100-od.BRATIO/100) * od.QUOTEPRICE - org.remainqtty * org.QUOTEPRICE * (1 + typ.deffeerate / 100-od.BRATIO/100)  ,0))  aboveramt
           from odmast od,odmast org, ood, odtype typ, odtype orgtyp
        where od.orderid=ood.orgorderid
            and od.REFORDERID=org.orderid
            and od.actype=typ.actype
            and org.actype=orgtyp.actype
            and OODSTATUS='N' and od.exectype ='AB'
            and od.deltd <> 'Y' and org.deltd <>'Y'
            group by od.afacctno
      ) B,
      afmast af, cimast ci
    where af.acctno = ci.afacctno
        and af.acctno = a.afacctno(+)
        and af.acctno = b.afacctno(+)
/
