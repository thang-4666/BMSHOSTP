SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GETTRFBUYAMT_BYDAY
(AFACCTNO, TRFBUY_T0, TRFBUY_T1, TRFBUY_T2, TRFBUY_T3)
BEQUEATH DEFINER
AS 
select od.afacctno,
       sum(case when od.txdate = to_date(sys.varvalue,'DD/MM/RRRR') then
          case when od.feeacr > 0 then
              od.matchamt + (od.remainqtty*od.quoteprice) + od.feeacr
          else (od.matchamt + (od.remainqtty*od.quoteprice)) * (1 + od.bratio / 100) end
      else 0 end) trfbuy_t0,
      sum(case when
        --to_date(sys.varvalue,'DD/MM/RRRR') = getduedate(od.txdate, 'B', '000', 1)
        od.txdate= (select sbdate from sbcurrdate where numday =-1 and sbtype ='B')
        then
          od.matchamt + od.feeacr
      else 0 end) trfbuy_t1,
      sum(case when
        --to_date(sys.varvalue,'DD/MM/RRRR') = getduedate(od.txdate, 'B', '000', 2)
        od.txdate= (select sbdate from sbcurrdate where numday =-2 and sbtype ='B')
        then
          od.matchamt + od.feeacr
      else 0 end) trfbuy_t2,
      sum(case when
        --to_date(sys.varvalue,'DD/MM/RRRR') = getduedate(od.txdate, 'B', '000', 3)
        od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')
        then
          od.matchamt + od.feeacr
      else 0 end) trfbuy_t3
      from afmast af, aftype aft, odmast od, mrtype mrt,
      (select sts.orgorderid, sts.afacctno, sts.txdate, sts.cleardate, sts.amt
          from stschd sts
          where duetype = 'SM' and sts.deltd <> 'Y') sts,
      sysvar sys
  where af.acctno = od.afacctno and af.actype = aft.actype and od.orderid = sts.orgorderid(+) AND OD.exectype IN ('NB')
  and sys.varname ='CURRDATE' and sys.grname ='SYSTEM'
  and aft.mrtype =mrt.actype
  and (aft.istrfbuy = 'Y' and mrt.mrtype = 'T'  and nvl(od.txdate,to_date(sys.varvalue,'DD/MM/RRRR')) = to_date(sys.varvalue,'DD/MM/RRRR')
      or od.txdate <> nvl(sts.cleardate,fn_get_nextdate(od.txdate, aft.trfbuyext)))
  group by od.afacctno
/
