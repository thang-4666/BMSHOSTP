SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CIMAST_AFTER 
 AFTER
  INSERT OR UPDATE
 ON cimast
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
/*  l_custodycd  varchar2(10);
  l_smsmobile  varchar2(10);
  l_amount     number;
  l_templateid varchar2(6);
  l_datasource varchar2(1000);*/

  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
begin
  -- Initialization
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('TRG_CIMAST_AFTER',
                      plevel            => nvl(logrow.loglevel, 30),
                      plogtable         => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert            => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace            => (nvl(logrow.log4trace, 'N') = 'Y'));

  plog.setBeginSection(pkgctx, 'TRG_CIMAST_AFTER');

  if fopks_api.fn_is_ho_active then
    --Begin GianhVG Log trigger for buffer
    jbpks_auto.pr_trg_account_log(:newval.acctno, 'CI');
    --End Log trigger for buffer
  
/*    plog.debug(pkgctx,
               'Balance: ' || :newval.balance || ' , old balance: ' ||
               :oldval.balance);
  
    if UPDATING and :newval.balance <> :oldval.balance then
      begin
      
        select custodycd, af.fax1
          into l_custodycd, l_smsmobile
          from cfmast cf, afmast af
         where cf.custid = af.custid
           and af.acctno = :newval.afacctno;
      
        l_amount := abs(:newval.balance - :oldval.balance);
      
        if :newval.balance > :oldval.balance then
          l_templateid := '324A';
        
        elsif :newval.balance < :oldval.balance then
          l_templateid := '324B';
        
        else
          l_templateid := '';
        end if;
      
        l_datasource := 'select ''' || l_custodycd || ''' custodycode, ''' ||                        
                        to_char(getcurrdate, 'DD/MM/RRRR') ||
                        ''' txdate, ''' || :newval.balance ||
                        ''' balance, ''' || l_amount ||
                        ''' amount, '''' txdesc from dual';
      
        plog.debug(pkgctx, l_datasource);
      
        if l_smsmobile is not null and Length(l_smsmobile) > 0 and length(l_templateid) > 0 then
        
          insert into emaillog
            (autoid, email, templateid, datasource, status, createtime)
          values
            (seq_emaillog.nextval, l_smsmobile, l_templateid, l_datasource,
             'A', sysdate);
        
        end if;
      exception
        when others then
          plog.error(pkgctx, sqlerrm);
          plog.setEndSection(pkgctx, 'TRG_CIMAST_AFTER');
      end;
    end if;
  */
  end if;

  plog.setEndSection(pkgctx, 'TRG_CIMAST_AFTER');
end;
/
