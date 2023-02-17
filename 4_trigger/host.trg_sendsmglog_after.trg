SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_SENDSMGLOG_AFTER
 AFTER 
 INSERT
 ON SENDMSGLOG
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
declare
  l_datasource   varchar2(1000);
  l_custody_code cfmast.custodycd%type;
  l_fullname     cfmast.fullname%type;
  /*
  l_acctno       afmast.acctno%type;
  l_rlsdate      lnmast.rlsdate%type;
  l_SECAMOUNT    V_GETGRPDEALFORMULAR.TADF%type;
  l_LOANAMT    V_GETGRPDEALFORMULAR.DDF%type;
  l_CURRLNRATE   V_GETGRPDEALFORMULAR.RTTDF%type;
  l_LNRATE       DFGROUP.MRATE%type;
  l_ADDAMOUNT    V_GETGRPDEALFORMULAR.ODSELLDF%type;
  l_LOANTYPE     varchar2(10);
  */
  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
begin
  -- Initialization
  plog.error('TRG_SENDSMGLOG_AFTER'||l_custody_code);
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('TRG_SENDSMGLOG_AFTER',
                      plevel                => nvl(logrow.loglevel, 30),
                      plogtable             => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert                => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace                => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_SENDSMGLOG_AFTER');
-- call sms mr0002
  if :new.searchcode = 'MR0002' and :new.sendvia = 'S' then

    l_datasource := '' || :new.msgbody || '';

    nmpks_ems.InsertEmailLog(:new.toaddr,
                             '327A',
                             l_datasource,
                             :new.acctno);
-- call sms mr0003
  else if :new.searchcode in ('MR0002','MR0102') and :new.sendvia = 'E' then

    select custodycd, fullname
      into l_custody_code, l_fullname
      from cfmast cf, afmast af
     where cf.custid = af.custid
       and af.acctno = :new.acctno;

     l_datasource := '' || :new.msgbody || '';
     --l_datasource := 'select ''' || l_custody_code || ''' custodycode, ''' ||
     --               :new.acctno || ''' account, ''' ||
     --              l_fullname || ''' fullname from dual';

     nmpks_ems.InsertEmailLog(:new.toaddr,
                             '0218',
                             l_datasource,
                             :new.acctno);

  else if :new.searchcode ='MR0008' and :new.sendvia = 'E' then

    l_datasource := '' || :new.msgbody || '';

    nmpks_ems.InsertEmailLog(:new.toaddr,
                             '0220',
                             l_datasource,
                             :new.acctno);

  else if :new.searchcode ='MR0008' and :new.sendvia = 'S' then

    l_datasource := '' || :new.msgbody || '';

    nmpks_ems.InsertEmailLog(:new.toaddr,
                             '0331',
                             l_datasource,
                             :new.acctno);

   else if :new.searchcode ='MR0003' and :new.sendvia = 'S' then

    l_datasource := '' || :new.msgbody || '';

    nmpks_ems.InsertEmailLog(:new.toaddr,
                             '327B',
                             l_datasource,
                             :new.acctno);
   else if :new.searchcode ='MR0106' and :new.sendvia = 'E' then

    l_datasource := '' || :new.msgbody || '';

    nmpks_ems.InsertEmailLog(:new.toaddr,
                             '0221',
                             l_datasource,
                             :new.acctno);

   else if :new.searchcode ='MR0106' and :new.sendvia = 'S' then

    l_datasource := '' || :new.msgbody || '';

    nmpks_ems.InsertEmailLog(:new.toaddr,
                             '0325',
                             l_datasource,
                             :new.acctno);


  END IF;
  end if;
  end if;
  end if;
  end if;
  end if;
  end if;
  /*  if :new.toaddr is not null then

    l_datasource := 'select ''' || :new.msgbody || ''' msgbody from dual';

    insert into emaillog
      (autoid, email, templateid, datasource, status, createtime)
    values
      (seq_emaillog.nextval, :new.toaddr, '327A', l_datasource, 'A',
       sysdate);

  end if;*/

  plog.setEndSection(pkgctx, 'TRG_SENDSMGLOG_AFTER');
exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_SENDSMGLOG_AFTER');
end TRG_SENDSMGLOG_AFTER;
/
