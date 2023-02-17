SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_MO_AM_TIEN
(NGAY_VAY, TK_LUU_KY, HO_TEN, GOC_VAY, GOC_DA_TRA, 
 DU_NO)
BEQUEATH DEFINER
AS 
select ln.opndate Ngay_Vay, cf.custodycd TK_LUU_KY, cf.fullname HO_TEN, sum(ln.orlsamt) Goc_Vay, 
    sum(ln.oprinpaid - nvl(lntr.OPRINPAID,0)) Goc_Da_Tra, 
    sum(ln.orlsamt) - sum(ln.oprinpaid - nvl(lntr.OPRINPAID,0)) DU_NO
from 
    (
        select opndate, acctno, trfacctno, sum(orlsamt) orlsamt, sum(oprinpaid) oprinpaid,
                    round(sum(OINTNMLOVD + OINTOVDACR + OINTNMLACR + OINTDUE),0) interest
        from vw_lnmast_all
        where ftype = 'AF' 
            and orlsamt > 0
        group by opndate, acctno, trfacctno
    ) ln,
    (
        select lntr.ACCTNO, 
            sum(case when tx.field = 'OPRINPAID' then lntr.namt else 0 end) OPRINPAID,
            sum(case when tx.field = 'OINTPAID' then lntr.namt else 0 end) OINTPAID
        from lntran lntr, apptx tx
        where lntr.txcd = tx.txcd
            and tx.field in ('OPRINPAID','OINTPAID')
            and tx.txtype = 'C'
            and tx.apptype = 'LN'
        group by lntr.ACCTNO
    ) lntr,
    afmast af, cfmast cf            
where ln.trfacctno = af.acctno
    and af.custid = cf.custid
    and ln.orlsamt <> 0
    and ln.acctno = lntr.acctno(+)        
--    and ln.opndate between to_date('01/01/2010','DD/MM/YYYY') and to_date('09/06/2010','DD/MM/YYYY')
group by ln.opndate, cf.custodycd, cf.fullname
having sum(ln.orlsamt) - sum(ln.oprinpaid - nvl(lntr.OPRINPAID,0)) <> 0
order by ln.opndate, cf.custodycd
/
