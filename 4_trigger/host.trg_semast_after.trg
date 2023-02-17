SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_SEMAST_AFTER 
 AFTER
  INSERT OR UPDATE
 ON semast
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
  --v_afacctno varchar2(20);
  --v_errmsg varchar2(3000);
  l_symbol     varchar2(30);
  l_amount     number;
  l_custodycd  varchar2(10);
  l_smsmobile  varchar2(15);
  l_templateid varchar2(10);
  l_datasource varchar2(1000);
  v_count number;
  pkgctx     plog.log_ctx;
  p_err_code varchar2(300);
begin
  if fopks_api.fn_is_ho_active then
    /*v_afacctno := :newval.afacctno;
    msgpks_system.sp_notification_obj('SEMAST',
                                  :newval.acctno,
                                  v_afacctno);*/
    --Begin GianhVG Log trigger for buffer
    jbpks_auto.pr_trg_account_log(:newval.acctno, 'SE');
    if :newval.trade <> :oldval.trade then
      jbpks_auto.pr_trg_account_log(:newval.afacctno, 'CI');
    end if;
    --End Log trigger for buffer
    if :oldval.trade is null or :newval.trade <> :oldval.trade then
      cspks_seproc.pr_execute_trigger_log(:newval.afacctno, :newval.codeid, :newval.trade, 0);
    end if;
    --Cap nhat RoomUsed cho tai khoan Margin tuan thu Uy ban
    if :newval.trade <> nvl(:oldval.trade,0) then
        begin
            select count(1) into v_count
            from afmast af, aftype aft, mrtype mrt,lntype lnt,
                afserisk rsk1,securities_info sb
            where :newval.afacctno = af.acctno and af.actype = aft.actype
                and aft.mrtype = mrt.actype  and aft.lntype = lnt.actype
                and mrt.mrtype ='T' and aft.istrfbuy <> 'Y' and lnt.chksysctrl ='Y'
                and af.actype =rsk1.actype and :newval.codeid=rsk1.codeid
                and :newval.codeid=sb.codeid;
        exception when others then
            v_count:=0;
        end;
        if v_count>0 AND :newval.roomchk ='Y'   then
            update securities_info set roomused= roomused + :newval.trade - nvl(:oldval.trade,0) where codeid =:newval.codeid;
        end if;
    end if;
    
        if  :newval.roomchk  <> :oldval.roomchk and :newval.roomchk ='Y'   then
            update securities_info set roomused= roomused + :newval.trade  where codeid =:newval.codeid;
        end if;

        if  :newval.roomchk  <> :oldval.roomchk and :newval.roomchk ='N'   then
            update securities_info set roomused= roomused - :newval.trade  where codeid =:newval.codeid;
        end if;

   if UPDATING and :newval.trade > 0 then
      begin
      
        select custodycd, cf.mobilesms
          into l_custodycd, l_smsmobile
          from cfmast cf, afmast af
         where cf.custid = af.custid
           and af.acctno = :newval.afacctno;
      
        select symbol into l_symbol from sbsecurities where codeid = :newval.codeid;
      
        l_amount := abs(:newval.trade - :oldval.trade);
      
        /*if :newval.trade > :oldval.trade then
          l_templateid := '325E';
        elsif :newval.trade < :oldval.trade then
          l_templateid := '325F';
        else
          l_templateid := '';
        end if;
      
        l_datasource := 'select ''' || l_custodycd || ''' custodycode, ''' ||
                        to_char(getcurrdate, 'DD/MM/RRRR') || ''' txdate, ''' || :newval.trade ||
                        ''' trade, ''' || l_amount || ''' amount, ''' || l_symbol || ''' symbol, '''' txdesc from dual';
      
        if l_smsmobile is not null and Length(l_smsmobile) > 0 and length(l_templateid) > 0 then
        
          insert into emaillog
            (autoid, email, templateid, datasource, status, createtime)
          values
            (seq_emaillog.nextval, l_smsmobile, l_templateid, l_datasource, 'A', sysdate);

        end if;
        */
      end;
    end if;
  
  end if;
end;
/
