SET DEFINE OFF;
CREATE OR REPLACE function fn_getusedmrlimit (p_acctno IN VARCHAR2)
RETURN NUMBER
  IS
l_amt number;
BEGIN
    select -least(nvl(adv.avladvance,0)
                + mst.balance
                - nvl(secureamt,0)
                /*- mst.depofeeamt*/
                ,0)
        into l_amt
    from cimast mst
    left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
    left join (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.acctno
    where mst.acctno = p_acctno;
    return l_amt;
EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
/
