SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_af_actype(p_afacctno varchar2, p_txdate VARCHAR2)
return VARCHAR2
is
l_maxdebtcf number(20,0);
L_ACTYPE    VARCHAR2(10);
l_txdate date;
l_OLDACTYPE VARCHAR2(10);
L_MINTXDATE DATE;
L_MINTXTIME VARCHAR2(20);

begin
/*l_maxdebtcf:= to_number(cspks_system.fn_get_sysvar('MARGIN','MAXDEBTCF'));
select case when nvl(lnt.chksysctrl,'N') = 'Y' then least(af.mrcrlimitmax,l_maxdebtcf) else af.mrcrlimitmax end into l_mrcrlimitmax
from afmast af, aftype aft, lntype lnt
where af.actype = aft.actype and aft.lntype = lnt.actype(+) and af.acctno = p_afacctno;*/

    l_txdate := to_date(p_txdate,'dd/mm/rrrr');

    select max(ACTYPE) into L_ACTYPE from afmast where acctno = p_afacctno;


    select MIN(maker_dt) INTO L_MINTXDATE
    from maintain_log
    where table_name = 'CFMAST'
        and column_name = 'ACTYPE' and action_flag = 'EDIT'
        and child_table_name = 'AFMAST' AND child_record_key LIKE '%'|| p_afacctno || '%'
        and maker_dt >= l_txdate;

    IF(L_MINTXDATE IS NULL) THEN
        RETURN L_ACTYPE;
    END IF;

    select MIN(maker_time) INTO L_MINTXTIME
    from maintain_log
    where table_name = 'CFMAST'
        and column_name = 'ACTYPE' and action_flag = 'EDIT'
        and child_table_name = 'AFMAST' AND child_record_key LIKE '%'|| p_afacctno || '%'
        and maker_dt = L_MINTXDATE;

    IF(L_MINTXTIME IS NULL) THEN
        RETURN L_ACTYPE;
    END IF;

    select NVL(from_value,to_value) INTO l_OLDACTYPE
    from maintain_log
    where table_name = 'CFMAST'
        and column_name = 'ACTYPE' and action_flag = 'EDIT'
        and child_table_name = 'AFMAST' AND maker_time = L_MINTXTIME
        AND child_record_key LIKE '%'|| p_afacctno || '%'
        and maker_dt = to_date('02/04/2014','DD/mm/rrrr');

    return L_ACTYPE;
exception when others then
return 0;
end;

 
 
 
 
 
 
/
