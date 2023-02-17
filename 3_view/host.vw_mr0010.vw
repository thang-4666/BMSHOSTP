SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0010
(CUSTODYCD, FULLNAME, AFACCTNO, ACTYPE, TYPENAME, 
 MOBILESMS, EMAIL, SECUREDT0, SECUREDT1, SECUREDT2, 
 SECUREDT3, SECUREDOVER, TOTALSECURED, MRCRLIMITMAX, SEASS, 
 BALANCE, BANKAVLBAL, MARGINRATE, GRPNAME, CAREBY, 
 MONEYPAY, DAYPAY, DEPOFEEAMT, RTNAMOUNTREF, OVDAMOUNTREF, 
 SELLLOSTASSREF, SELLAMOUNTREF, SELLINGAMOUNT, MRIRATE, MRMRATE, 
 RTNREMAINAMT, ADDAMOUNT, BANKHOLDAMT)
BEQUEATH DEFINER
AS 
select mst.CUSTODYCD, mst.FULLNAME, mst.AFACCTNO, mst.ACTYPE, mst.TYPENAME, mst.MOBILESMS, mst.EMAIL, mst.SECUREDT0,
mst.SECUREDT1, mst.SECUREDT2, mst.SECUREDT3, mst.SECUREDOVER, mst.TOTALSECURED, mst.MRCRLIMITMAX,
mst.SEASS, mst.BALANCE,mst.bankavlbal, mst.MARGINRATE, mst.GRPNAME, mst.CAREBY, mst.MONEYPAY, mst.DAYPAY,depofeeamt,
mst.RTNAMOUNTREF,
mst.OVDAMOUNTREF,
round(nvl(od.lostass,0),0) SELLLOSTASSREF,
round(nvl(od.rtnamount,0),0) SELLAMOUNTREF,
round(nvl(od.sellamount,0),0) SELLINGAMOUNT,
mst.MRIRATE, mst.MRMRATE,
greatest(mst.RTNAMOUNTREF,mst.OVDAMOUNTREF-round(nvl(od.lostass,0),0))-round(nvl(od.rtnamount,0),0) RTNREMAINAMT,
greatest(mst.RTNAMOUNTREF,mst.OVDAMOUNTREF,0) ADDAMOUNT,
greatest(least(greatest(mst.RTNAMOUNTREF,mst.OVDAMOUNTREF-round(nvl(od.lostass,0),0))-round(nvl(od.rtnamount,0),0),mst.bankavlbal),0) bankholdamt

from
(
  select cf.custodycd, max(cf.fullname) fullname, af.acctno afacctno, max(aft.actype) actype, max(aft.typename) typename,
      max(cf.mobilesms) mobilesms, max(cf.email) email,
      sum(case when od.txdate = to_date(sys.varvalue,'DD/MM/RRRR') then
          case when od.feeacr > 0 then
              od.matchamt + (od.remainqtty*od.quoteprice) + od.feeacr
          else (od.matchamt + (od.remainqtty*od.quoteprice)) * (1 + od.bratio / 100) end
      else 0 end) securedT0,
      sum(case when
        --to_date(sys.varvalue,'DD/MM/RRRR') = getduedate(od.txdate, 'B', '000', 1)
        od.txdate= (select sbdate from sbcurrdate where numday =-1 and sbtype ='B')
        then
          od.matchamt + od.feeacr
      else 0 end) securedT1,
      sum(case when
        --to_date(sys.varvalue,'DD/MM/RRRR') = getduedate(od.txdate, 'B', '000', 2)
        od.txdate= (select sbdate from sbcurrdate where numday =-2 and sbtype ='B')
        then
          od.matchamt + od.feeacr
      else 0 end) securedT2,
      sum(case when
        --to_date(sys.varvalue,'DD/MM/RRRR') = getduedate(od.txdate, 'B', '000', 3)
        od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')
        then
          od.matchamt + od.feeacr
      else 0 end) securedT3,
      nvl(max(ln.odamt),0) securedOver,
      sum(case when od.txdate = to_date(sys.varvalue,'DD/MM/RRRR') then
              case when od.feeacr > 0 then
                  od.matchamt + (od.remainqtty*od.quoteprice) + od.feeacr
              else (od.matchamt + (od.remainqtty*od.quoteprice)) * (1 + od.bratio / 100) end
          else od.matchamt + od.feeacr end) + nvl(max(ln.odamt),0)  totalsecured,
      max(af.mrcrlimitmax) mrcrlimitmax, nvl(max(sec.seass),0) seass, max(ci.balance + nvl(sec.avladvance,0)) balance,max(ci.bankavlbal) bankavlbal,
      nvl(max(sec.marginrate),0) marginrate,

      sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')  then
          od.matchamt + od.feeacr
      else 0 end) + nvl(max(ln.odamt),0) addamount,

      max(grp.grpname) grpname, max(af.careby) careby ,
      ltrim(to_char(sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')  then
          od.matchamt + od.feeacr
      else 0 end) + nvl(max(ln.odamt),0),'9,999,999,999')) moneypay, to_date(od.txdate,'DD/MM/RRRR') daypay,
      max(round(greatest(round((case when nvl(sec.marginrate,0) * af.mrirate =0 then - sec.outstanding else
                 greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrirate) end),0),0),0)) RTNAMOUNTREF,
      sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')  then
        od.matchamt + od.feeacr
            else 0 end) + nvl(max(ln.odamt) ,0) /*+ max(depofeeamt)*/ - max(ci.balance + nvl(sec.avladvance,0)) OVDAMOUNTREF,
      max(AF.MRIRATE) MRIRATE, max(AF.MRMRATE) MRMRATE,max(depofeeamt) depofeeamt
  from cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt, sysvar sys,
  (select od.afacctno, od.txdate, nvl(sts.cleardate,fn_get_nextdate(od.txdate, aft.trfbuyext) ) cleardate,
          od.matchamt, sts.amt, od.remainqtty, od.quoteprice, od.feeacr, od.bratio
      from afmast af, aftype aft, odmast od,
      (select sts.orgorderid, sts.afacctno, sts.txdate, sts.cleardate, sts.amt
          from stschd sts
          where duetype = 'SM' and sts.deltd <> 'Y') sts
  where af.acctno = od.afacctno and af.actype = aft.actype and od.orderid = sts.orgorderid(+) AND OD.exectype IN ('NB')
  ) od,
  (select trfacctno, sum(oprinnml+oprinovd) odamt from lnmast where ftype = 'AF' group by trfacctno) ln,
  buf_ci_account sec, (select * from tlgroups where grptype = 2) grp
  where cf.custid = af.custid and af.acctno = ci.acctno and af.actype = aft.actype
  and aft.mrtype = mrt.actype and af.acctno = od.afacctno(+)
  and sys.varname = 'CURRDATE' and sys.grname = 'SYSTEM'
  and af.acctno = ln.trfacctno(+) and af.acctno = sec.afacctno(+)
  and (aft.istrfbuy = 'Y' and mrt.mrtype = 'T'  and nvl(od.txdate,to_date(sys.varvalue,'DD/MM/RRRR')) = to_date(sys.varvalue,'DD/MM/RRRR')
      or od.txdate <> od.cleardate)
  --Chi lay ra nhung tai khoan ngan hang
  and (case when AF.corebank = 'Y' then AF.corebank else af.alternateacct end)='Y'
  and af.careby = grp.grpid(+)
  group by cf.custodycd, af.acctno , od.txdate
  having sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')  then
        od.matchamt + od.feeacr
    else 0 end)  > 0 --Chi lay tai khoan den han T3
)  mst,
(select od.afacctno,
    round(greatest(
            least(sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(rsk.advrate,0)*getnonworkingday(3)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
                    sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)-nvl(rsk.advminfee,0)/*Gia tri tien ve tinh theo phi UTTB toi thieu*/))
            ,0)
            ) sellamount,
    round(greatest(sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(rsk.mrirate,100) = 0 then 100 else nvl(rsk.mrirate,100) end) ),0)) lostass,
    round(greatest(
            least(sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(rsk.advrate,0)*getnonworkingday(3)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
                    sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)-nvl(rsk.advminfee,0)/*Gia tri tien ve tinh theo phi UTTB toi thieu*/))
            - sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(rsk.mrirate,100) = 0 then 100 else nvl(rsk.mrirate,100) end) )
            ,0)
            ) rtnamount
    from odmast od, odtype odt,
        (select af.acctno, af.mrirate, nvl(adt.advrate,0)/100 advrate,nvl(adt.advminfee,0) advminfee, rsk.*
            from afmast af, afserisk rsk, aftype aft, adtype adt
            where af.actype = rsk.actype(+)
            and af.actype = aft.actype and aft.adtype = adt.actype
            ) rsk,
        securities_info sec,
        sysvar sy
    where od.exectype in ('NS','MS') --and isdisposal = 'Y'
    and od.afacctno = rsk.acctno(+) and od.codeid = rsk.codeid(+)
    and od.codeid = sec.codeid
    and od.actype = odt.actype
    and sy.varname = 'ADVSELLDUTY'
    and od.remainqtty > 0
    group by afacctno
) od
where  mst.afacctno = od.afacctno(+)
/
