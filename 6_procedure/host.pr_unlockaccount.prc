SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_unlockaccount(p_txmsg in tx.msg_rectype)
is
begin
    for rec in (
        select  distinct map.acfld, map.apptype
        from appmap map, apptx tx
        where map.apptxcd= tx.txcd and map.apptype = tx.apptype
        and fldtype ='N' and  tltxcd =p_txmsg.tltxcd
    )
    loop
        delete from accupdate where acctno= p_txmsg.txfields(rec.acfld).value and updatetype = rec.apptype;
    end loop;
exception when others then
    null;
end;

 
 
 
 
/
