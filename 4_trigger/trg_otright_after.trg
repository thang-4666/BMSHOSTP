SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_OTRIGHT_AFTER 
 AFTER 
 INSERT OR UPDATE
 ON OTRIGHT
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
declare
  -- local variables here
  l_datasource varchar2(4000);
  l_email      varchar2(200);
  l_emailowner varchar2(200);
  l_custodycd  varchar2(10);
  l_account    varchar2(10);
  l_fullname   varchar2(50);
  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
begin

  -- Initialization
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('fopks_api',
                      plevel => nvl(logrow.loglevel, 30),
                      plogtable => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_OTRIGHT_AFTER');
  if :newval.DELTD = 'N' then
    select custodycd, :newval.cfcustid account, fullname, cf.email
      into l_custodycd, l_account, l_fullname, l_email
      from cfmast cf
     where cf.custid = :newval.authcustid;
  
    select cf.email
      into l_emailowner
      from cfmast cf
     where cf.custid = :newval.cfcustid;
  
    l_datasource := 'select ''' || l_custodycd || ''' custodycode, ''' ||
                    l_account || ''' account, ''' || l_fullname ||
                    ''' fullname, CollectionToString(cast(collect(a.cdcontent) as collection),''</li><li>'') rights
                        from otrightdtl otr,
                             (select cdcontent, cdval, lstodr
                                 from allcode
                                where cdname = ''OTFUNC'' and cdval not in (''SMARTALERT'',''MARKETALERT'',''COMPANYALERT'')
                                order by lstodr ) a
                       where a.cdval = otr.otmncode and instr(otright,''Y'')>0
                         and otr.deltd = ''N''
                         and cfcustid = ''' ||
                    :newval.cfcustid || ''' and authcustid = ''' ||
                    :newval.authcustid || '''';
  
    plog.debug(pkgctx, l_datasource);

/*    if nmpks_ems.CheckEmail(l_email) then
    
      insert into emaillog
        (autoid, email, templateid, datasource, status, createtime)
      values
        (seq_emaillog.nextval, l_email, '0211', l_datasource, 'A', sysdate);
    else
      insert into emaillog
        (autoid, email, templateid, datasource, status, createtime)
      values
        (seq_emaillog.nextval, l_email, '0211', l_datasource, 'R', sysdate);
    end if;*/

     ----------------------
    /*    if (Length(l_emailowner) > 0 or l_emailowner is not null) and l_emailowner <> l_email then
    
      insert into emaillog
        (autoid, email, templateid, datasource, status, createtime)
      values
        (seq_emaillog.nextval, l_emailowner, '0211', l_datasource, 'A', sysdate);
    
    end if; */
  end if;
  plog.setEndSection(pkgctx, 'TRG_OTRIGHT_AFTER');

exception
  when others then
    plog.error(pkgctx, sqlerrm);
    plog.setEndSection(pkgctx, 'TRG_OTRIGHT_AFTER');
end TRG_OTRIGHT_AFTER;
/
