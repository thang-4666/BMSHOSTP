SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CFMAST_BEFORE 
 BEFORE 
 INSERT
 ON CFMAST
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
begin
if :oldval.last_mkid is null then
    :newval.last_mkid:=:newval.tlid;
end if;
exception when others then
null;
end;
/
