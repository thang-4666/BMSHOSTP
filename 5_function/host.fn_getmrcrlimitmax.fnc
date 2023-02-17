SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getmrcrlimitmax(p_afacctno varchar2, p_txdate VARCHAR2)
return number
is
l_maxdebtcf number(20,0);
l_mrcrlimitmax number(20,0);
l_txdate date;
l_namt number ;
begin
/*l_maxdebtcf:= to_number(cspks_system.fn_get_sysvar('MARGIN','MAXDEBTCF'));
select case when nvl(lnt.chksysctrl,'N') = 'Y' then least(af.mrcrlimitmax,l_maxdebtcf) else af.mrcrlimitmax end into l_mrcrlimitmax
from afmast af, aftype aft, lntype lnt
where af.actype = aft.actype and aft.lntype = lnt.actype(+) and af.acctno = p_afacctno;*/

    l_txdate := to_date(p_txdate,'dd/mm/rrrr');

    select max(mrcrlimitmax) into l_mrcrlimitmax from afmast where acctno = p_afacctno;

    select sum(nvl(namt,0)) into l_namt
    from
    (
        select acctno,
            sum(case when txtype = 'C' then namt else -namt end) namt
        from aftran tr, v_appmap_by_tltxcd ap
        where tr.tltxcd = ap.tltxcd and tr.txcd = ap.apptxcd
            and ap.field = 'MRCRLIMITMAX'
            and ap.apptype = 'CF' and tr.txdate > l_txdate
            and tr.acctno = p_afacctno
        group by acctno
        union all
        select acctno,
            sum(case when txtype = 'C' then namt else -namt end) namt
        from aftrana tr, v_appmap_by_tltxcd ap
        where tr.tltxcd = ap.tltxcd and tr.txcd = ap.apptxcd
            and ap.field = 'MRCRLIMITMAX'
            and ap.apptype = 'CF' and tr.txdate > l_txdate
            and tr.acctno = p_afacctno
        group by acctno
        union all
        select substr(child_record_key,11,10)  acctno,
            sum(to_value-nvl(from_value,0)) namt
        from maintain_log
        where action_flag = 'EDIT' and child_table_name = 'AFMAST'
            and column_name = 'MRCRLIMITMAX' and maker_dt > l_txdate
            and child_record_key like '%'|| p_afacctno || '%'
        group by substr(child_record_key,11,10)
    )
    where acctno = p_afacctno;

l_mrcrlimitmax := l_mrcrlimitmax-nvl(l_namt,0);

return l_mrcrlimitmax;
exception when others then
return 0;
end;

 
 
 
 
 
 
/
