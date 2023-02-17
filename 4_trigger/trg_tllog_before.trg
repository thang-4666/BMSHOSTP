SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TLLOG_BEFORE 
 BEFORE
  INSERT OR UPDATE
 ON tllog
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
Declare
 cursor c_acc is select 1
                 from afmast af,cfmast cf
                 where af.custid =cf.custid
                 and af.acctno = :NEWVAL.MSGACCT
                 and cf.class = '004'
                 and rownum=1;
 v_vip number;
Begin

  IF :NEWVAL.tltxcd in ('8874','8875','8876','8877') then
     v_vip:=0;
     Open c_acc;
     Fetch c_acc into v_vip;
     Close c_acc;
     If v_vip = 1 then
      IF inserting then
            :NEWVAL.txtime:='07:00:00';
      End if;
      IF updating  and ( :OLDVAL.offtime  is null) then
             :NEWVAL.offtime:='07:00:00';
      End if;
     End if;
    End if;
End;
/
