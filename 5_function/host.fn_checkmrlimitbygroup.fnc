SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkmrlimitbygroup (pv_afacctno varchar2, pv_amt number)
RETURN number
  IS

l_rerult number;
l_count number;
l_avllimit number;
l_UsedLimit number;
l_limitgroup number;
BEGIN
    l_rerult:= 0;
    select count(1) into l_count from AFMRLIMITGRP where afacctno =     pv_afacctno;
    if l_count <= 0 then
        return l_rerult;
    else
        for rec in ( select *  from AFMRLIMITGRP a where afacctno =     pv_afacctno)
        loop
            select nvl(sum(fn_getUsedMrLimit(afacctno)),0) amt
                into l_UsedLimit
            from afmrlimitgrp where refautoid = rec.autoid and afacctno <> pv_afacctno;

            select MRLIMIT into l_limitgroup from MRLIMITGRP where autoid = rec.refautoid;

            select l_limitgroup + nvl(adv.avladvance,0) +
                + mst.balance
                - nvl(secureamt,0)
                /*- mst.depofeeamt*/
                - mst.odamt
                - l_UsedLimit
                into l_avllimit
            from cimast mst
            left join (select * from v_getbuyorderinfo where afacctno = pv_afacctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = pv_afacctno group by afacctno) adv on adv.afacctno=MST.acctno
            where mst.acctno = pv_afacctno;

            if l_avllimit < pv_amt then
                return l_avllimit - pv_amt;
            end if;
        end loop;
    end if;
    return l_rerult;
EXCEPTION
    WHEN others THEN
        return 0;
END;

 
 
 
 
/
