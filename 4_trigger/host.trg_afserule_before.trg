SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_AFSERULE_BEFORE 
 BEFORE
  INSERT
 ON afserule
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
begin
if length(nvl(:newval.refid,'')) > 4 then
    :newval.typormst := 'M';
else
    :newval.typormst := 'T';
end if;
end;
/
