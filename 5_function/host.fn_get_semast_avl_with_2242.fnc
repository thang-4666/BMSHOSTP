SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_semast_avl_with_2242(pv_afacctno In VARCHAR2, pv_codeid IN VARCHAR2)
    RETURN number IS

    l_AVLSEWITHDRAW NUMBER(20,2);
    l_trade NUMBER(20,2);
    l_sewithdrawcheck_arr txpks_check.sewithdrawcheck_arrtype;
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    l_pending number ;
BEGIN
     l_sewithdrawcheck_arr := txpks_check.fn_sewithdrawcheck(pv_afacctno || pv_codeid ,'SEWITHDRAW','ACCTNO');
     l_semastcheck_arr := txpks_check.fn_semastcheck(pv_afacctno || pv_codeid ,'SEMAST','ACCTNO');
     l_AVLSEWITHDRAW := l_sewithdrawcheck_arr(0).AVLSEWITHDRAW;
     l_trade:=l_semastcheck_arr(0).trade;
     l_pending:=0;

-- ck dang duyet
begin

select  sum(nvl(trade,0)) into l_pending
from
(select  max(decode (tlfld.fldcd,'03', cvalue,'')) seacctno, max( decode (tlfld.fldcd,'10', nvalue,0)) trade, max( decode (tlfld.fldcd,'06', nvalue,0)) blocked
    from tllog tl,tllogfld tlfld
    where tltxcd ='2242' and txstatus ='4'
    and tl.txnum = tlfld.txnum and deltd<>'Y'
    group by tl.txnum)
    where seacctno = pv_afacctno||pv_codeid
group by  seacctno ;

exception when others then
l_pending:=0;
end ;

    RETURN least(l_AVLSEWITHDRAW-l_pending,l_trade-l_pending);
exception when others then
    return 0;
END;

 
 
 
 
/
