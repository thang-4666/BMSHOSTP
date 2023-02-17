SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRGR_USERLOGIN_AFTER 
 AFTER 
 INSERT OR UPDATE
 ON USERLOGIN
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
declare
  -- local variables here
  l_datasource varchar2(4000);
  l_email      varchar2(200);

  -- l_emailowner varchar2(200);
  l_custodycd varchar2(10);

  l_tokenid       varchar2(50);
  l_mobile_number varchar2(50);
------------------------------------
  l_username varchar2(50);
  l_userpass varchar2(50);
  l_tradingpass varchar2(50);  
  l_fullname varchar2(250);   
  l_custodycode varchar2(50);
  l_templateid varchar2(50);
  l_datasourcesql varchar2(400);
  l_count number(20,0);
  
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
begin

  -- Initialization
  -- <Statement>;
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('NMPKS_EMS',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRGR_USERLOGIN_AFTER');

  plog.debug(pkgctx, 'old Token Id: ' || :oldval.tokenid);
  plog.debug(pkgctx, 'new Token Id: ' || :newval.tokenid);

  if (:OLDVAL.TOKENID <> :newval.TOKENID) then

    l_tokenid := :newval.TOKENID;

    l_mobile_number := SUBSTR(l_tokenid,
                              instr(l_tokenid, '{', 1, 2) + 1,
                              instr(l_tokenid, '}', 1, 1) -
                              instr(l_tokenid, '{', 1, 2) - 1);

    begin
      select custodycd
        into l_custodycd
        from cfmast
       where username = :newval.username;
    exception
      when others then
        l_custodycd := :newval.username;
    end;

    if length(l_mobile_number) > 3 then

      l_datasource := 'select''' || l_custodycd || ''' custodycode, ''' ||
                      l_mobile_number || ''' tokenid from dual';

      nmpks_ems.InsertEmailLog(l_mobile_number, '328A', l_datasource, '');
    end if;
    /*  insert into emaillog
     (autoid, email, templateid, datasource, status,createtime)
    values
     (seq_emaillog.nextval, l_tokenid, 'T328A', l_datasource, 'S', sysdate);*/

  end if;


exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRGR_USERLOGIN_AFTER');
end TRG_OTRIGHT_AFTER;
/
