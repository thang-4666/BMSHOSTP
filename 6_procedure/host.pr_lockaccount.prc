SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_lockaccount(p_txmsg in tx.msg_rectype, p_err_code in out varchar2)
is
begin

    for rec in (
        select  distinct map.acfld, map.apptype
        from appmap map, apptx tx, tltx
        where map.apptxcd= tx.txcd and map.apptype = tx.apptype
        and fldtype ='N' and  map.tltxcd =p_txmsg.tltxcd
        and map.tltxcd = tltx.tltxcd and nvl(chksingle,'N') ='Y'
    )
    loop
        if length(nvl(p_txmsg.txfields(rec.acfld).value,''))>0 then
            insert into accupdate (acctno,updatetype,createdate)
            values (p_txmsg.txfields(rec.acfld).value, rec.apptype, SYSTIMESTAMP);
        end if;
    end loop;
exception when others then
    p_err_code:='-100200';
end;
 
 
 
 
/
