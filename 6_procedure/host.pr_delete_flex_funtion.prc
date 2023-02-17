SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_DELETE_FLEX_FUNTION" (pv_objname varchar2, pv_type char)
is
v_sql varchar2(1000);
v_count number;
BEGIN
    if pv_type ='T' and length(pv_objname) =4 then --Transact
        delete from tltx where tltxcd =pv_objname;
        delete from fldval where objname =pv_objname;
        delete from fldmaster where objname=pv_objname;
        delete from appchk where tltxcd =pv_objname;
        delete from appmap where tltxcd =pv_objname;
        delete from postmap where tltxcd =pv_objname;
        delete from aftxmap where tltxcd =pv_objname;
        delete from crbtxmap where objname =pv_objname;
        select count(1) into v_count from user_objects  where object_name='TXPKS_#' || pv_objname;
        if v_count > 0 then
            v_sql:='drop package ' || 'TXPKS_#' || pv_objname;
            EXECUTE IMMEDIATE v_sql;
        end if;

        --v_sql:='drop package body ' || 'TXPKS_#' || pv_objname;
        --EXECUTE IMMEDIATE v_sql;
        select count(1) into v_count from user_objects  where object_name='TXPKS_#' || pv_objname || 'EX';
        if v_count > 0 then
            v_sql:='drop package ' || 'TXPKS_#' || pv_objname || 'EX';
            EXECUTE IMMEDIATE v_sql;
        end if;

        --v_sql:='drop package body ' || 'TXPKS_#' || pv_objname || 'EX';
        --EXECUTE IMMEDIATE v_sql;
    end if;
    if pv_type ='O' then --Chuc nang
        delete from cmdmenu where cmdid =pv_objname;
    end if ;
    if pv_type ='R' and length(pv_objname) =6 then --Report
        delete from rptmaster where rptid =pv_objname;
        delete from rptfields where objname =pv_objname;
        select count(1) into v_count from user_objects  where object_name=pv_objname;
        if v_count > 0 then
            v_sql:='drop procedure ' || pv_objname;
            EXECUTE IMMEDIATE v_sql;
        end if;
    end if;
    if pv_type ='V' and length(pv_objname) =6 then --View
        delete from rptmaster where rptid =pv_objname;
        delete from search where searchcode=pv_objname;
        delete from searchfld where searchcode=pv_objname;
    end if;
    if pv_type ='S' then --man hinh search
        delete from rptmaster where rptid =pv_objname;
        delete from search where searchcode=pv_objname;
        delete from searchfld where searchcode=pv_objname;
    end if ;
end;

 
 
 
 
/
