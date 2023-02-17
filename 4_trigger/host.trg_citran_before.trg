SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CITRAN_BEFORE 
 BEFORE
  INSERT
 ON citran
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare

  l_corebank char(1);
begin
    l_corebank:='N';
    begin
        select nvl(corebank,'N') into l_corebank from cimast where acctno =:NEWVAL.acctno;
    exception
    when others then
        l_corebank:='N';
    end;
    :NEWVAL.corebank:= l_corebank;
END;
/
