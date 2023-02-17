SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_SYSVAR_AFTER 
 AFTER
  UPDATE
 ON sysvar
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
begin
    if updating and :oldval.VARNAME='TPDNCEIL' and :newval.VARVALUE <> :oldval.VARVALUE then
        update securities_ticksize set TOPRICE=to_number(:newval.VARVALUE)
            where codeid in (select codeid from sbsecurities where sectype='012' and tradeplace='002');
    end if;
end;
/
