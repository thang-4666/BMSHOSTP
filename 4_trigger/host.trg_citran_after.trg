SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CITRAN_AFTER 
 AFTER
  INSERT
 ON citran
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
  -- local variables here
  -- l_datasource varchar2(1000);
  l_msg_type varchar2(200);
  pkgctx     plog.log_ctx;
  logrow     tlogdebug%ROWTYPE;
begin

  FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;
  pkgctx := plog.init('trg_citran_after',
                      plevel           => NVL(logrow.loglevel, 30),
                      plogtable        => (NVL(logrow.log4table, 'N') = 'Y'),
                      palert           => (NVL(logrow.log4alert, 'N') = 'Y'),
                      ptrace           => (NVL(logrow.log4trace, 'N') = 'Y'));

  plog.setbeginsection(pkgctx, 'trg_citran_after');
  if fopks_api.fn_is_ho_active then
    if :NEWVAL.tltxcd in  ('1153','1120','1141', '1131', '1130','1137','1138','8878' )
        and :newval.txcd in ('0012','0077','0029') then
        insert into log_trf_transact(autoid,acctno,txnum,txdate,amt,status,logtime)
        values (seq_log_trf_transact.nextval,:NEWVAL.acctno, :NEWVAL.txnum, :NEWVAL.txdate, :NEWVAL.namt,'P', SYSTIMESTAMP);

    end if;
  end if;
exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'trg_citran_after');
end;
/
