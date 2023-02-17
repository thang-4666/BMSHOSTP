SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_SBSECURITIES_AFTER 
 AFTER
   UPDATE OF tradeplace
 ON sbsecurities
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
    -- Private variable declarations
  pkgctx plog.log_ctx;
begin
    if nvl(:oldval.tradeplace,:newval.tradeplace) <> :newval.tradeplace then
        insert into log_changetradeplace (AUTOID, TXDATE, CODEID, SYMBOL, FRTRADEPLACE, TOTRADEPLACE, FRHALT, TOHALT)
        values (seq_log_changetradeplace.NEXTVAL, getcurrdate, :OLDVAL.CODEID, :OLDVAL.SYMBOL, :OLDVAL.TRADEPLACE, :NEWVAL.TRADEPLACE, :OLDVAL.HALT, :NEWVAL.HALT);
    end if;
exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_SBSECURITIES_AFTER');
end TRG_SECURITIES_AFTER;
/
