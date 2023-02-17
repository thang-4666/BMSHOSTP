SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETBUYORDERINFO
(OVERAMT, AFACCTNO, ADVAMT, SECUREAMT, EXECBUYAMT)
BEQUEATH DEFINER
AS 
select nvl(a.overamt,0) + nvl(aboveramt,0) overamt, af.acctno afacctno,
        case when hosts=0 then 0 else greatest(nvl(a.overamt,0) + nvl(aboveramt,0) - greatest(af.mrcrlimitmax-ci.dfodamt,0),0) end advamt,
        case when hosts=0 then nvl(A.execbuyamt,0) else nvl(a.secureamt,0) + nvl(b.absecured,0) end secureamt,
        nvl(A.execbuyamt,0) execbuyamt
    from
    /*(SELECT
            SUM (case when execamt > 0 and NVL(REPO.AMT2,0) > 0 then 0 else quoteprice * remainqtty * (1 + typ.deffeerate / 100-od.bratio/100)
                        + execamt* (1-(case when execqtty<=0 then 0 else dfqtty/execqtty end)) * (1 + typ.deffeerate / 100-od.bratio/100)  end ) overamt,
            round(SUM (    quoteprice* remainqtty* (od.bratio/100)
                        --+ execamt * (od.bratio/100)
                        + (case when od.feeacr>0 then execamt + od.feeacr else execamt * (od.bratio/100) end)
                        + execamt * (case when execqtty<=0 then 0 else dfqtty/execqtty end) * (1 + typ.deffeerate / 100 - od.bratio/100) ),0) secureamt,
            sum(od.execamt+case when od.feeacr>0 then od.feeacr else ( CASE WHEN NVL(REPO.AMT2,0) = 0 THEN od.execamt*typ.deffeerate/100 ELSE NVL(REPO.feeamt,0) END) end) execbuyamt,
            od.afacctno afacctno,
            to_number(nvl(max(sy_HOSTATUS.varvalue),0)) hosts
    FROM odmast od, odtype typ, sysvar sy_HOSTATUS, sysvar sy_CURRDATE,
        (
            select orderid, txdate, sum(AMT1) AMT2, sum(feeamt) feeamt
            from bondrepo BP , sysvar sy_CURRDATE WHERE sy_CURRDATE.grname='SYSTEM' and sy_CURRDATE.varname='CURRDATE'
                AND BP.TXDATE = to_date(sy_CURRDATE.VARVALUE,'DD/MM/RRRR') AND leg = 'V'
            group by orderid, txdate
        ) REPO
   WHERE od.actype = typ.actype
     AND od.txdate = to_date(sy_CURRDATE.VARVALUE,'DD/MM/RRRR')
     AND deltd <> 'Y'
     AND od.exectype IN ('NB', 'BC')
     and od.stsstatus <> 'C'
     AND OD.orderid = REPO.orderid(+)
     and sy_HOSTATUS.grname='SYSTEM' and sy_HOSTATUS.varname='HOSTATUS'
     and sy_CURRDATE.grname='SYSTEM' and sy_CURRDATE.varname='CURRDATE'
     group by od.afacctno) A,*/
     (SELECT nvl(od.overamt, 0) + nvl(od1.overamtexec,0) overamt,
       round(nvl(od.secureremainamt, 0) + nvl(od1.secureamt,0)  + ci.execbuyamt + ci.execfeebuyamt ,0) secureamt,
            ci.execbuyamt + ci.execfeebuyamt execbuyamt,
            ci.afacctno ,
            to_number(sy_HOSTATUS.varvalue) hosts
    FROM   cimast ci, sysvar sy_HOSTATUS,
         (select  od.afacctno, SUM (quoteprice* remainqtty* od.bratio/100) secureremainamt ,
                 SUM (case when execamt > 0 and NVL(REPO.AMT2,0) > 0 then 0 else quoteprice * remainqtty * (1 + typ.deffeerate / 100-od.bratio/100)end ) overamt
          from odmast od, odtype typ,  sysvar sy_CURRDATE,
            (
            select orderid, txdate, sum(AMT1) AMT2, sum(feeamt) feeamt
            from bondrepo BP , sysvar sy_CURRDATE WHERE sy_CURRDATE.grname='SYSTEM' and sy_CURRDATE.varname='CURRDATE'
                AND BP.TXDATE = to_date(sy_CURRDATE.VARVALUE,'DD/MM/RRRR') AND leg = 'V'
            group by orderid, txdate
        ) REPO
          where  od.actype = typ.actype
             AND od.txdate =  to_date(sy_CURRDATE.VARVALUE,'DD/MM/RRRR')
             AND od.remainqtty > 0
             AND deltd <> 'Y'
             AND od.exectype IN ('NB', 'BC')
             AND od.stsstatus <> 'C'
             AND od.orderid = REPO.orderid (+)
             AND sy_CURRDATE.grname='SYSTEM' and sy_CURRDATE.varname='CURRDATE'
             group by od.afacctno ) od,
       ( select od.afacctno, 
          sum(execamt* (1-(case when execqtty<=0 then 0 else dfqtty/execqtty end)) * (1 + odt.deffeerate / 100-od.bratio/100)) overamtexec,
                sum(execamt * (case when execqtty<=0 then 0 else dfqtty/execqtty end) * (1 + odt.deffeerate / 100 - od.bratio/100) ) secureamt
         from odmast od , odtype odt, sysvar sys
        where od.actype = odt.actype
           AND od.txdate =  to_date(sys.VARVALUE,'DD/MM/RRRR')
         and od.execamt > 0 
         AND deltd <> 'Y'
           AND od.exectype IN ('NB', 'BC')
           AND od.stsstatus <> 'C'
         AND sys.grname='SYSTEM' and sys.varname='CURRDATE'
         and  1 + odt.deffeerate/100 <> od.bratio/100
         group by od.afacctno)od1
   WHERE  od.afacctno(+) = ci.afacctno and od1.afacctno(+) = ci.afacctno
     and sy_HOSTATUS.grname='SYSTEM' and sy_HOSTATUS.varname='HOSTATUS'
     and  ci.execbuyamt + nvl(secureremainamt, 0) >0)A,
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
