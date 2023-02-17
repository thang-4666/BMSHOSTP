SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_autoid_previous(pv_txdate in varchar2, pv_txnum in varchar2)
    RETURN VARCHAR2 IS
-- PURPOSE: PHI CHUYEN KHOAN CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   03/02/2012     CREATED
    V_RESULT VARCHAR2(100);
    V_TLTXCD VARCHAR2(20);

BEGIN

    if(LENGTH(pv_txdate) < 1 ) then
        V_RESULT:='E';
        RETURN V_RESULT;
    end if;
    if(LENGTH(pv_txnum) < 1 ) then
        V_RESULT:='E';
        RETURN V_RESULT;
    end if;

    V_TLTXCD := 'E';
    select max(tltxcd) into V_TLTXCD
    from vw_tllog_all
    where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr');
    if(V_TLTXCD = '0381') then
        /*select cvalue into V_RESULT from tllogfldall where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
        and fldcd = '08'; */
        select max(tore)|| max(ftxdate)|| max(ttxdate)  into V_RESULT
        from
        (
            select cvalue tore, null ftxdate, null ttxdate
            from tllogfldall where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
                and fldcd = '08'
            union all
            select cvalue tore, null ftxdate, null ttxdate
            from tllogfld where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
                and fldcd = '08'
            union all
            select null tore, cvalue ftxdate, null ttxdate
            from tllogfldall where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
                and fldcd = '05'
            union all
            select null tore, cvalue ftxdate, null ttxdate
            from tllogfld where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
                and fldcd = '05'
            union all
            select null tore, null ftxdate, cvalue ttxdate
            from tllogfldall where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
                and fldcd = '06'
            union all
            select null tore, null ftxdate, cvalue ttxdate
            from tllogfld where txnum = pv_txnum and txdate = to_date(pv_txdate,'dd/mm/rrrr')
                and fldcd = '06'
        );
    else
        V_RESULT := 'E';
    end if;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
 
 
 
 
 
 
 
/
