SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GROUPACOOUNTMARGINRATE
(GROUPLEADER, FULLNAME, ACTYPE, ACCTNO, CUSTID, 
 AFACCTNO, CCYCD, LASTDATE, EMAIL, MOBILE, 
 PHONE1, ADDRESS, CIPAMT, BALANCE, CRAMT, 
 DRAMT, AVRBAL, MDEBIT, MCREDIT, CRINTACR, 
 ODINTACR, ADINTACR, MINBAL, AAMT, RAMT, 
 BAMT, EMKAMT, ODLIMIT, MMARGINBAL, MARGINBAL, 
 ODAMT, RECEIVING, MBLOCK, DESC_STATUS, APMT, 
 ADVLIMIT, MRCRLIMITMAX, MRCRLIMIT, MRIRATE, MRMRATE, 
 MRLRATE, DUEAMT, OVAMT, PP, AVLLIMIT, 
 NAVACCOUNT, OUTSTANDING, MARGINRATE, AVLWITHDRAW, BALDEFOVD)
BEQUEATH DEFINER
AS 
(
SELECT GROUPLEADER,FULLNAME,ACTYPE,ACCTNO,CUSTID,AFACCTNO,CCYCD,LASTDATE,EMAIL,MOBILE,PHONE1,ADDRESS,CIPAMT,
BALANCE,CRAMT,DRAMT,AVRBAL,MDEBIT,MCREDIT,CRINTACR,ODINTACR,ADINTACR,MINBAL,AAMT,RAMT,
BAMT,EMKAMT,ODLIMIT,MMARGINBAL,MARGINBAL,ODAMT,RECEIVING,MBLOCK,DESC_STATUS,APMT,
ADVLIMIT,MRCRLIMITMAX,MRCRLIMIT,MRIRATE,MRMRATE,MRLRATE,DUEAMT,OVAMT,PP,
AVLLIMIT,NAVACCOUNT,OUTSTANDING,MARGINRATE,
TRUNC(GREATEST((CASE WHEN mstmrirate>0 THEN least(NAVACCOUNT*100/mstmrirate + OUTSTANDING,AVLLIMIT) ELSE NAVACCOUNT + OUTSTANDING  END),0),0) AVLWITHDRAW,
TRUNC((CASE WHEN mstmrirate>0  THEN GREATEST(LEAST((100* NAVACCOUNT + OUTSTANDING * mstmrirate)/mstmrirate,BALDEFOVD-MSTADVANCELINE,AVLLIMIT),0) ELSE BALDEFOVD-ADVLIMIT END),0) BALDEFOVD
FROM
(SELECT mst.fullname, aftype actype, mst.acctno,mst.custid, mst.afacctno, mst.ccycd, mst.lastdate,
            mst.email,mst.mobile,mst.phone1,mst.address,mst.desc_status,
            mst.mrirate,mst.mrmrate,mst.mrlrate,mst.mrirate mstmrirate,advanceline mstadvanceline, mst.dueamt, mst.ovamt, mst.groupleader,
           (mst.ramt - mst.aamt) cipamt,  TRUNC (mst.balance)-nvl(al.secureamt,0) balance,
           mst.cramt, mst.dramt, mst.avrbal, mst.mdebit, mst.mcredit,
           mst.crintacr, mst.odintacr, mst.adintacr, mst.minbal, mst.aamt,
           mst.ramt, nvl(al.secureamt,0) bamt, mst.emkamt, mst.odlimit, mst.mmarginbal,
           mst.marginbal, mst.odamt, mst.receiving, mst.mblock,
           NVL (se.receivingamt, 0) apmt,
           mst.advanceline advlimit,
           nvl(mst.mrcrlimitmax,0) mrcrlimitmax,mst.MRCRLIMIT,
           mst.balance - nvl(al.secureamt,0) - mst.odamt - NVL (al.advamt, 0) avlwithdraw ,
           greatest(balance- ovamt-dueamt - ramt,0) baldefovd,
           greatest(least((nvl(mst.mrcrlimit,0) + nvl(se.seamt,0)+
                        nvl(se.receivingamt,0))
                ,nvl(mst.mrcrlimitmax,0)+nvl(mst.mrcrlimit,0))
           + nvl(mst.advanceline,0) + mst.balance- mst.odamt -nvl(al.secureamt,0) - mst.ramt,0) pp,
           nvl(mst.mrcrlimitmax,0) +nvl(mst.mrcrlimit,0)
           +mst.balance- mst.odamt - nvl(al.secureamt,0) - mst.ramt avllimit,
           /* nvl(mst.MRCRLIMIT,0) +*/ nvl(se.SEASS,0)  NAVACCOUNT,
           nvl(se.receivingamt,0)+ mst.balance+LEAST(nvl(mst.mrcrlimit,0),nvl(al.secureamt,0))- mst.odamt - nvl(al.secureamt,0) - mst.ramt OUTSTANDING,
           round((case when mst.balance+LEAST(nvl(mst.mrcrlimit,0),nvl(al.secureamt,0))+ nvl(se.receivingamt,0)- mst.odamt - nvl(al.secureamt,0) - mst.ramt>=0 then 100000
           else (/*nvl(mst.MRCRLIMIT,0) +*/ nvl(se.SEASS,0))/ abs(mst.balance+LEAST(nvl(mst.mrcrlimit,0),nvl(al.secureamt,0))+ nvl(se.receivingamt,0)- mst.odamt - nvl(al.secureamt,0) - mst.ramt) end),4) * 100 MARGINRATE
      FROM
      (select mst.*,cd1.cdcontent desc_status,af.advanceline,af.mrirate,af.mrmrate,af.mrlrate,cf.fullname,af.MRCRLIMIT,af.MRCRLIMITMAX,af.actype aftype,
            CF.email,CF.mobilesms mobile,cf.mobile phone1,CF.address,af.groupleader
        from cimast mst,afmast af,cfmast cf, aftype aft, mrtype mrt,allcode cd1
      where af.actype=aft.actype and aft.mrtype =mrt.actype and mrt.mrtype IN ('S','T') and af.acctno = mst.afacctno  and af.custid=cf.custid
      and cd1.cdtype = 'CI' AND cd1.cdname = 'STATUS' and mst.status = cd1.cdval and length(nvl(af.groupleader,'_'))<>10) mst
      left join
           (select * from v_getbuyorderinfo
            ) al
            on mst.acctno = al.afacctno
        LEFT JOIN
           (select * from v_getsecmargininfo) SE
           on se.afacctno=MST.acctno
union
select cf.fullname, af.actype, af.acctno,cf.custid, mst.afacctno, mst.ccycd, mst.lastdate,
            cf.email,cf.mobile,cf.mobilesms phone1,cf.address,cd1.cdcontent desc_status,
            af.mrirate,af.mrmrate,af.mrlrate,
             m.*
from cimast mst,cfmast cf, afmast af, allcode cd1,
(SELECT SUM(CASE WHEN mst.ACCTNO <> mst.groupleader THEN 0 ELSE mst.MRIRATE END) MSTMRIRATE,
        SUM(CASE WHEN mst.ACCTNO <> mst.groupleader THEN 0 ELSE mst.ADVANCELINE END) MSTADVANCELINE ,
            sum(mst.dueamt) dueamt, sum(mst.ovamt) ovamt, groupleader,
           sum(mst.ramt - mst.aamt) cipamt,  sum(TRUNC (mst.balance)-nvl(al.secureamt,0)) balance,
           sum(mst.cramt) cramt, sum(mst.dramt) dramt, sum(mst.avrbal) avrbal, sum(mst.mdebit) mdebit, sum(mst.mcredit) mcredit,
           sum(mst.crintacr) crintacr, sum(mst.odintacr) odintacr, sum(mst.adintacr) adintacr, sum(mst.minbal) minbal, sum(mst.aamt) aamt,
           sum(mst.ramt) ramt, sum(nvl(al.secureamt,0)) bamt, sum(mst.emkamt) emkamt, sum(mst.odlimit) odlimit, sum(mst.mmarginbal) mmarginbal,
           sum(mst.marginbal) marginbal, sum(mst.odamt) odamt, sum(mst.receiving) receiving, sum(mst.mblock) mblock,
           sum(NVL (se.receivingamt, 0)) apmt,
           sum(mst.advanceline) advlimit,
           sum(nvl(mst.mrcrlimitmax,0)) mrcrlimitmax,sum(mst.MRCRLIMIT) MRCRLIMIT,
           sum(mst.balance - nvl(al.secureamt,0) - mst.odamt - NVL (al.advamt, 0)) avlwithdraw ,
           greatest(sum(balance- ovamt-dueamt - ramt),0) baldefovd,
           greatest(least(sum((nvl(mst.mrcrlimit,0) + nvl(se.seamt,0)+ nvl(se.receivingamt,0)))
                ,sum(nvl(mst.mrcrlimitmax,0)+nvl(al.secureamt,0)))
           + sum(nvl(mst.advanceline,0) + mst.balance- mst.odamt -nvl(al.secureamt,0) - mst.ramt),0) pp,
           sum(nvl(mst.mrcrlimitmax,0) +
           nvl(mst.advanceline,0) + mst.balance+nvl(mst.mrcrlimit,0)- mst.odamt - nvl(al.secureamt,0) - mst.ramt) avllimit,
           sum(/*nvl(mst.MRCRLIMIT,0) +*/ nvl(se.SEASS,0))  NAVACCOUNT,
           sum(nvl(se.receivingamt,0)+ mst.balance+LEAST(nvl(mst.mrcrlimit,0),nvl(al.secureamt,0))- mst.odamt - nvl(al.secureamt,0) - mst.ramt) OUTSTANDING,
           round((case when sum(mst.balance+LEAST(nvl(mst.MRCRLIMIT,0),nvl(al.secureamt,0))+ nvl(se.receivingamt,0)- mst.odamt - nvl(al.secureamt,0) - mst.ramt)>=0 then 100000
           else sum(/*nvl(mst.MRCRLIMIT,0) +*/ nvl(se.SEASS,0))/ abs(sum(mst.balance+LEAST(nvl(mst.MRCRLIMIT,0),nvl(al.secureamt,0))+ nvl(se.receivingamt,0)- mst.odamt - nvl(al.secureamt,0) - mst.ramt)) end),4) * 100 MARGINRATE
      FROM
      (select mst.*,af.groupleader,af.advanceline,af.mrirate,af.mrmrate,af.mrlrate,af.MRCRLIMIT,af.MRCRLIMITMAX
        from cimast mst,afmast af,aftype aft, mrtype mrt
      where af.actype=aft.actype and aft.mrtype =mrt.actype and mrt.mrtype IN ('S','T') and af.acctno = mst.afacctno
      and length(nvl(af.groupleader,'_'))=10) mst
      left join
           (select * from v_getbuyorderinfo
            ) al
            on mst.acctno = al.afacctno
      LEFT JOIN
           (select * from v_getsecmargininfo) SE
           on se.afacctno=MST.acctno
      group by  groupleader) M
where cd1.cdtype = 'CI' AND cd1.cdname = 'STATUS' and mst.status = cd1.cdval
and mst.afacctno =af.acctno and af.custid=cf.custid
and af.acctno=m.groupleader)
)
/
