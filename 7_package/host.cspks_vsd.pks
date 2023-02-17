SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_vsd AS
  FUNCTION FN_GET_VSD_REQUEST(F_REQID IN NUMBER) RETURN VARCHAR; --??c th?ng tin c?a y?u c?u dua th?nh XML thu vi?n
  PROCEDURE SP_AUTO_CREATE_MESSAGE; --Th? t?c t?o di?n MT t? d?ng
  PROCEDURE SP_MESSAGE_TOFILE(F_MSGCONTENT IN VARCHAR, F_REQID IN NUMBER); --Th? t?c dua message t? Queue ra file
  PROCEDURE SP_CREATE_MESSAGE(F_REQID IN NUMBER); --T?o XML message dua ra VSD Gateway
  PROCEDURE SP_RECEIVE_MESSAGE(F_MSGCONTENT IN VARCHAR); --Nh?n message
  PROCEDURE SP_PARSE_MESSAGE(F_REQID IN NUMBER); --X? l? XML message d?u v?o
  PROCEDURE PR_OPENCUSTODYACCOUNT(P_ERR_CODE IN OUT VARCHAR,
                                  --Ghi log m? t?i kho?n luu k? c?a Core
                                  P_CUSTODYCD VARCHAR,
                                  P_TELLERID  VARCHAR,
                                  P_CHECKERID VARCHAR,
                                  P_NOTES     VARCHAR);
  --PROCEDURE PR_AUTO_PROCESS_MESSAGE;
  PROCEDURE SP_AUTO_GEN_VSD_REQ;
  procedure auto_process_inf_message(pv_autoid   number,
                                     pv_funcname varchar2,
                                     pv_autoconf varchar2,
                                     pv_reqid    number);
  PROCEDURE SP_GEN_VSD_REQ(PV_AUTOID NUMBER);
  PROCEDURE AUTO_COMPLETE_CONFIRM_MSG(PV_REQID    NUMBER,
                                      PV_CFTLTXCD VARCHAR2,
                                      PV_VSDTRFID NUMBER);
  procedure pr_auto_process_message;
  PROCEDURE pr_xml_2_csvTBL(pv_autoid NUMBER);
  PROCEDURE pr_receive_csv_by_xml(pv_filename IN VARCHAR2, pv_filecontent IN CLOB);
  PROCEDURE pr_receive_par_by_xml(pv_filename IN VARCHAR2, pv_filecontent IN clob);
  PROCEDURE splitstring(pv_string in varchar2,pv_outstring out varchar2);
  procedure auto_call_txpks_0012(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_0067(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2246(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2231(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2201(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2294(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2266(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_22662(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2265(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_8879(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_8894(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_8816(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2290NAK(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2265NAK(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2245(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_3320(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2236(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2257(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2251(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2253(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2248(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_22482(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_2290(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_3385(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_0059(pv_reqid number,pv_custodycd varchar2);
  procedure auto_call_txpks_3370(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_3340(pv_reqid number, pv_vsdtrfid number);
  PROCEDURE create_new_CA(pv_reqid IN NUMBER, pv_vsdtrfid IN NUMBER, pv_catype IN varchar2);
  PROCEDURE edit_CA(pv_reqid IN NUMBER, pv_vsdtrfid IN number, pv_catype IN varchar2);
  PROCEDURE cancel_CA(pv_reqid IN NUMBER, pv_vsdtrfid IN number);
  PROCEDURE prc_update_vsdid(v_csvfilename IN VARCHAR2, v_vsdid IN varchar2);
END cspks_vsd;
 

/


CREATE OR REPLACE PACKAGE BODY cspks_vsd as

  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  procedure pr_opencustodyaccount(p_err_code  in out varchar,
                                  p_custodycd varchar,
                                  p_tellerid  varchar,
                                  p_checkerid varchar,
                                  p_notes     varchar) as
    v_txdate   date;
    v_trflogid number;
  begin
    select to_date(varvalue, 'DD/MM/RRRR')
      into v_txdate
      from sysvar
     where grname = 'SYSTEM'
       and varname = 'CURRDATE';
    select seq_crbtxreq.nextval into v_trflogid from dual;

    insert into crbtxreq
      (reqid,
       objtype,
       objname,
       objkey,
       trfcode,
       refcode,
       txdate,
       afacctno,
       bankcode,
       bankacct,
       txamt,
       status,
       refval,
       reftxdate,
       reftxnum)
      select v_trflogid,
             'V',
             'CFMAST',
             p_custodycd,
             '598.NEWM/AOPN',
             null,
             v_txdate,
             p_custodycd,
             'VSD',
             p_custodycd,
             0,
             'P',
             null,
             null,
             null
        from dual;

    insert into crbtxreqdtl
      (autoid, reqid, fldname, cval, nval)
      select seq_crbtxreqdtl.nextval,
             v_trflogid,
             'CUSTODYCD',
             p_custodycd,
             0
        from dual;

    insert into crbtxreqdtl
      (autoid, reqid, fldname, cval, nval)
      select seq_crbtxreqdtl.nextval, v_trflogid, 'NOTES', p_notes, 0
        from dual;

    insert into crbtxreqdtl
      (autoid, reqid, fldname, cval, nval)
      select seq_crbtxreqdtl.nextval, v_trflogid, 'TELLERID', p_tellerid, 0
        from dual;

    insert into crbtxreqdtl
      (autoid, reqid, fldname, cval, nval)
      select seq_crbtxreqdtl.nextval, v_trflogid, 'OFFID', p_checkerid, 0
        from dual;

    insert into crbtxreqdtl
      (autoid, reqid, fldname, cval, nval)
      select seq_crbtxreqdtl.nextval,
             v_trflogid,
             'TXDATE',
             to_char(v_txdate, 'DD/MM/RRRR'),
             0
        from dual;
  end pr_opencustodyaccount;

  procedure sp_receive_message(f_msgcontent in varchar) as
    v_trflogid number;
  begin
    plog.setbeginsection(pkgctx, 'sp_receive_message');
    --Ghi nhan Log
    select seq_vsdmsglog.nextval into v_trflogid from dual;
    insert into vsdmsglog
      (autoid, timecreated, timeprocess, status, msgbody)
      select v_trflogid, systimestamp, null, 'P', xmltype(f_msgcontent)
        from dual;
    --Parse message XML
    sp_parse_message(v_trflogid);

    plog.setendsection(pkgctx, 'sp_receive_message');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'sp_receive_message');
  end sp_receive_message;

  procedure sp_parse_message(f_reqid in number) as
    v_funcname         varchar2(80);
    v_sender           varchar2(60);
    v_msgtype          varchar2(60);
    v_vsdmsgid         varchar2(60);
    v_referenceid      varchar2(80);
    v_vsdfinfile       varchar2(1000);
    v_errdesc          varchar2(1000);
    v_msgfields        varchar2(5000);
    v_msgbody          varchar2(5000);
    v_trflogid         number;
    v_count            number;
    v_autoconf         varchar2(1);
    l_symbol           varchar2(50);
    l_symbol2           varchar2(50);
    l_quantity         number;
    l_symbol_class     varchar2(20);
    l_ref_custody_code varchar2(20);
    l_rec_custodycd    varchar2(20);
    l_vsdeffdate       varchar2(10);
    l_count            number;
    l_count2            number;
    v_currdate      date;
    l_newreferenceid    varchar2(20);
  begin
    plog.setbeginsection(pkgctx, 'sp_parse_message');

    v_currdate := getcurrdate;

    select count(autoid)
      into v_count
      from vsdmsglog
     where autoid = f_reqid
       and status = 'P';
    if v_count > 0 then
      begin
        --Get message header information
        select x.msgbody.extract('//root/txcode/@funcname').getstringval(),
               x.msgbody.extract('//root/txcode/@sender').getstringval(),
               x.msgbody.extract('//root/txcode/@msgtype').getstringval(),
               x.msgbody.extract('//root/txcode/@msgid').getstringval(),
               x.msgbody.extract('//root/txcode/@referenceid')
               .getstringval(),
               x.msgbody.extract('//root/txcode/@finfile').getstringval(),
               x.msgbody.extract('/root/txcode/detail').getstringval(),
               x.msgbody.extract('/root/txcode/msgbody/message')
               .getstringval(),
               x.msgbody.extract('//root/txcode/@errdesc').getstringval()
          into v_funcname,
               v_sender,
               v_msgtype,
               v_vsdmsgid,
               v_referenceid,
               v_vsdfinfile,
               v_msgfields,
               v_msgbody,
               v_errdesc
          from vsdmsglog x
         where autoid = f_reqid;
        -- PhuongHT edit
        if instr(v_funcname, '.NAK') > 0 or instr(v_funcname, '.ACK') > 0 then

          begin
            select trf.autoconf
              into v_autoconf
              from vsdtrfcode trf, vsdtxreq req
             where req.reqid = v_referenceid
               and trf.trfcode = v_funcname
               and trf.status = 'Y'
               and trf.type in ('CFN')
               and req.objname = trf.reqtltxcd;

            update vsdtxreq
               set msgstatus = 'N', vsd_err_msg =  fn_converttelextoutf8(v_errdesc)
             where reqid = v_referenceid;
          exception
            when no_data_found then
              v_autoconf := 'Y';
          end;
        else
            select count(*)
            into l_count
            from vsdtrfcode
            where status = 'Y'
            and trfcode = v_funcname;
          if l_count = 1 then
            -- chi dung cho mot loai nghiep vu
            select autoconf
              into v_autoconf
              from vsdtrfcode
             where status = 'Y'
               and trfcode = v_funcname;
          elsif l_count = 2 then
            -- su dung chung cho hai nghiep vu: can link voi VSDTXREQ de biet loai yeu cau
            begin
                select trf.autoconf
                  into v_autoconf
                  from vsdtrfcode trf, vsdtxreq req
                 where req.reqid = v_referenceid
                   and trf.trfcode = v_funcname
                   and trf.status = 'Y'
                   and trf.type in ('CFO', 'CFN')
                   and req.objname = trf.reqtltxcd;
            exception
                when others then
                --gianh cho gd Giao toa, so hieu tham chieu gui ve la so hieu cua VSD (v_referenceid)
                select trf.autoconf
                  into v_autoconf
                  from vsdtrfcode trf
                 where trf.trfcode = v_funcname
                   and trf.status = 'Y'
                   and trf.type in ('CFO', 'CFN')
                   and rownum<=1;
            end;
          else
            -- chua dung den
            v_autoconf := 'N';
          end if;
        end if;
        -- end of PhuongHT edit

        --Write to VSDTRFLOG
        v_trflogid := seq_vsdtrflog.nextval;
        v_trflogid := TO_NUMBER(TO_CHAR(v_currdate,'RRRRMMDD')||v_trflogid);
        /*insert into vsdtrflog
        (autoid, sender, msgtype, funcname, refmsgid, referenceid,
         finfilename, timecreated, timeprocess, status, autoconf, errdesc)
        select v_trflogid, v_sender, v_msgtype, v_funcname, v_vsdmsgid,
               v_referenceid, v_vsdfinfile, systimestamp, null, 'P',
               v_autoconf, v_errdesc
          from dual;*/
        insert into vsdtrflogdtl
          (autoid, refautoid, fldname, fldval, caption)
          select seq_vsdtrflogdtl.nextval,
                 v_trflogid,
                 xt.fldname,
                 --case ra tru 598 vi 598 dang xu ly rieng cho chr(10)
                 case when instr(v_funcname,'598') >0 then replace(xt.fldval, ',')
                      else replace(replace(xt.fldval, ','),chr(10),' ') end fldval ,

                 xt.flddesc
            from (select * from vsdmsglog where autoid = f_reqid) mst,
                 xmltable('root/txcode/detail/field' passing mst.msgbody
                          columns fldname varchar2(200) path 'fldname',
                          fldval varchar2(500) path 'fldval',
                          flddesc varchar2(1000) path 'flddesc') xt;

        select *
          into l_symbol,
               l_symbol2,
               l_quantity,
               l_symbol_class,
               l_ref_custody_code,
               l_rec_custodycd,
               l_vsdeffdate
          from (select fldval, fldname
                  from vsdtrflogdtl
                 where refautoid = v_trflogid) pivot(max(nvl(fldval, 0)) as f for(fldname) in('SYMBOL' as symbol,
                                                                                              'SYMBOL2' as symbol2,
                                                                                              'QTTY' as qtty,
                                                                                              'CLASS' as class,
                                                                                              'REFCUSTODYCD' as refcustodycd,
                                                                                              'CUSTODYCD' as reccustodycd,
                                                                                              'VSDEFFDATE' vsdeffdate));


        if  LENGTH(l_vsdeffdate) <> 8 then
            l_vsdeffdate := TO_CHAR(v_currdate,'RRRRMMDD');
        end if;
        if  l_symbol = 'RHTS' THEN
            l_symbol:= l_symbol2;
            if INSTR(v_funcname,'OK') > 0 then
                v_funcname:=REPLACE(v_funcname,'OK','RHTS');
            elsif INSTR(v_funcname,'NAK') > 0 then
                v_funcname:=REPLACE(v_funcname,'NAK','RHTS.NAK');
            elsif INSTR(v_funcname,'NOK') > 0 then
                v_funcname:=REPLACE(v_funcname,'NOK','RHTS');
            end if;
        else
            if INSTR(v_funcname,'NOK') > 0 then
                v_funcname:=REPLACE(v_funcname,'NOK','OK');
            end if;
        end if;

        --tu choi giai toa so hieu tham chieu la so hieu vsd
        if v_funcname in ('548.INST.LINK//524.SETR//COLO.') then
            begin
                select req.reqid into l_newreferenceid
                from semortage se1, semortage se2, vsdtxreq req
                where to_char(se1.autoid) = req.refcode
                and SE1.REFID = se2.autoid
                and se2.refidvsd = v_referenceid
                and req.txamt = se1.qtty
                and req.msgstatus = 'A'
                and se1.qtty = l_quantity
                and rownum <= 1;

                v_referenceid:=l_newreferenceid;
            exception
                when others then
                    l_newreferenceid:='';
            end;
        end if;

        insert into vsdtrflog
          (autoid,
           sender,
           msgtype,
           funcname,
           refmsgid,
           referenceid,
           finfilename,
           timecreated,
           timeprocess,
           status,
           autoconf,
           errdesc,
           symbol,
           reclas,
           reqtty,
           refcustodycd,
           reccustodycd,
           vsdeffdate)
          select v_trflogid,
                 v_sender,
                 v_msgtype,
                 v_funcname,
                 v_vsdmsgid,
                 v_referenceid,
                 v_vsdfinfile,
                 systimestamp,
                 null,
                 'P',
                 v_autoconf,
                 v_errdesc,
                 l_symbol,
                 l_symbol_class,
                 l_quantity,
                 l_ref_custody_code,
                 l_rec_custodycd,
                 nvl(to_date(l_vsdeffdate, 'RRRRMMDD'),null)
            from dual;

        --Update status
        update vsdmsglog
           set status = 'A', timeprocess = systimestamp
         where autoid = f_reqid
           and status = 'P';
      end;
    end if;
    plog.setendsection(pkgctx, 'sp_parse_message');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'sp_parse_message');
  end sp_parse_message;

  procedure pr_auto_process_message
  --Process message receved VSD
   is
    l_sqlerrnum  varchar2(200);
    l_count      integer;
    l_vsdmode    varchar2(20);
    l_msgacct    varchar2(50);
    l_status     varchar2(10);
    l_cf_tltxcd  varchar2(10);
    l_cf_msgtype varchar2(5);
    l_reject_msg varchar2(500);
    l_req_tltxcd varchar2(10);
    v_tltxcd     varchar2(4);
    v_dt_txdate  date;
    v_reqid      number;
    l_CUSTODYCODE varchar2(20);
    l_tltxcd_trfcode varchar2(20);
    l_countsymbol number;
    l_countcf2 number;
    l_countcf number;
    l_countcf3 number;
    l_value     varchar2(50);
    l_refcode   varchar2(50);
    l_custodycd varchar2(20);

  begin
    /*   IF NOT fopks_api.fn_is_ho_active THEN
        RETURN;
    END IF;*/
    plog.setbeginsection(pkgctx, 'pr_auto_process_message');
    IF cspks_system.fn_get_sysvar('SYSTEM', 'HOSTATUS') = '0' THEN
      RETURN; -- host inactive
    END IF;

    l_vsdmode   := cspks_system.fn_get_sysvar('SYSTEM', 'VSDMOD');
IF l_vsdmode <>'A' THEN-- khong ket noi
    RETURN;
ELSE-- ket noi
    --Duyet bang VSDTRFLOG
    for rec in (select * from vsdtrflog where status = 'P' order by autoid) loop

        l_cf_tltxcd := 'b';

        select count(*)
        into l_count
        from vsdtxreq
        where reqid = rec.referenceid;
        plog.error(pkgctx,
            'count :' || l_count ||' funcname:' || rec.funcname || '::vsdtrflog.referenceid: ' ||
            rec.referenceid || '::autoconf:' || rec.autoconf);
    if l_count > 0 then
        -- Cu la Y

        plog.error(pkgctx,
            ' funcname:' || rec.funcname || '1st  l_cf_tltxcd :' || l_cf_tltxcd );

        begin
            select log.msgacct,req.refcode
            into l_msgacct,l_refcode
            from vsdtxreq req, vsd_process_log log
            where req.reqid = rec.referenceid
            and req.process_id = log.autoid;
        exception
          when others then
            begin
                select msgacct,refcode into l_msgacct,l_refcode from vsdtxreq where reqid = rec.referenceid;
            exception
            when others then
                l_msgacct := '';
            end;
        end;

        if instr(rec.funcname, '.ACK') > 0 then

            plog.error(pkgctx,'ACK :' || l_count ||' funcname:' || rec.funcname );
            --cap nhat trang thai cho CFMAST
            if rec.funcname = '598.001.ACCT//AOPN.ACK' or rec.funcname = '598.001.ACCT//ACLS.ACK' then
                update cfmast set nsdstatus = 'A' where custodycd = l_msgacct;
            end if;

            update vsdtxreq
            set msgstatus = 'A', vsd_err_msg = fn_converttelextoutf8(rec.errdesc)
            where reqid = rec.referenceid;
            update vsdtrflog set status = 'C' where autoid = rec.autoid;

          --tam thoi hardcode cho nay de chuyen thang trang thai ve la vsd xac nhan de lam tiep quy trinh huy
            if rec.funcname = '598.005..ACK' then
                select cval into l_value from vsdtxreqdtl where reqid = rec.referenceid and fldname = 'CONFIRMSTATUS';
                if l_value = 'CONF' then
                   l_cf_tltxcd := '3335';
                   auto_complete_confirm_msg(rec.referenceid,l_cf_tltxcd,rec.autoid);
                else
                   update vsd_mt564_inf set msgstatus = 'C' where vsdmsgid = l_refcode;
                end if;

                update vsdtxreq
                set msgstatus = 'C', vsd_err_msg = fn_converttelextoutf8(rec.errdesc)
                where reqid = rec.referenceid and msgstatus <> 'E';
            elsif rec.funcname = '598.003..ACK' then
                update vsdtxreq
                set msgstatus = 'C', status = 'C'
                where reqid = rec.referenceid;
            end if;

            update vsdtrflog
            set status = 'C', timeprocess = systimestamp
            where autoid = rec.autoid;

            RETURN;
          --commit;
        elsif instr(rec.funcname, '.NAK') > 0 then
            --cap nhat trang thai cho CFMAST
            if rec.funcname = '598.001.ACCT//AOPN.NAK' then
                update cfmast set nsdstatus = 'N' where custodycd = l_msgacct;
            elsif rec.funcname = '598.001.ACCT//ACLS.NAK' then
                update cfmast set nsdstatus = 'N', status = 'A', activests = 'Y' where custodycd = l_msgacct;
            elsif rec.funcname = '598.005..NAK' then
                update vsd_mt564_inf set msgstatus = 'N' where vsdmsgid = l_refcode;
            end if;

            --swprocess -- P: pending, N nack, A ask
          --msgstatus: P pending, R reject, E error, C complete
            update vsdtxreq
            set msgstatus = 'N', status = 'R', vsd_err_msg = fn_converttelextoutf8(rec.errdesc)
            where reqid = rec.referenceid;

          --Revert NAK bussiness
            begin
                select tltxcd
                into l_cf_tltxcd
                from vsdtrfcode
                where trfcode = rec.funcname
                and type = 'CFN'
                and status = 'Y';

                if rec.funcname = '598.001.ACCT//TWAC.NAK' then
                    auto_call_txpks_2265NAK(rec.referenceid,rec.autoid);
                elsif rec.funcname = '598.001.ACCT//TBAC.NAK' then
                    auto_call_txpks_2290NAK(rec.referenceid,rec.autoid);
                elsif l_cf_tltxcd is not null then
                    auto_complete_confirm_msg(rec.referenceid,l_cf_tltxcd,rec.autoid);
                end if;

            exception
                when no_data_found then
                plog.warn(pkgctx, 'Dont have processing defined!');
                when others then
                plog.error(pkgctx,sqlerrm || dbms_utility.format_error_backtrace);

            end;

            update vsdtrflog set status = 'C', timeprocess = systimestamp where autoid = rec.autoid; -- la stauts A

            RETURN;
          --commit;
        elsif (rec.funcname = '598.002.ACCT//AOPN' or rec.funcname = '598.002.ACCT//ACLS') then
            plog.debug(pkgctx, 'confirm: ' || rec.referenceid);
          -- Confirm Mo tk
            begin
                select fldval
                into l_status
                from vsdtrflogdtl
                where refautoid = rec.autoid
                and fldname = 'STATUS';

            /*          if l_count > 0 then*/
            /*            select fldval
             into l_status
             from vsdtrflogdtl
            where refautoid = rec.autoid
              and fldname = 'STATUS';*/
                if l_status = 'PACK' then
                ---Dong y
                    if rec.funcname = '598.002.ACCT//AOPN' or rec.funcname = '598.002.ACCT//REAOPN' then
                    --mo va kich hoat sai chung
                        select objname into l_tltxcd_trfcode from vsdtxreq where reqid = rec.referenceid;

                        if l_tltxcd_trfcode = '0035' then
                            l_cf_tltxcd := '0012';
                        else
                            l_cf_tltxcd := '0067';
                        end if;

                        auto_complete_confirm_msg(rec.referenceid,l_cf_tltxcd,rec.autoid);

                        update cfmast
                        set nsdstatus = 'C'
                        where custodycd = l_msgacct;

                    else

                        update cfmast
                        set activests = 'N', status = 'C', pstatus = pstatus||status, nsdstatus = 'C'
                        where custodycd = l_msgacct;
                        --Update trang thai dien
                        UPDATE vsdtxreq SET status = 'C', msgstatus = 'C' WHERE reqid = rec.referenceid;

                        update vsdtrflog
                        set status = 'C', timeprocess = systimestamp
                        where autoid = rec.autoid;

                    end if;
                    plog.debug(pkgctx, rec.referenceid || ' accepted');
                else
                --Tu choi
                    begin
                /*select count(*)
                 into l_count
                 from vsdtrflogdtl
                where refautoid = rec.autoid
                  and fldname = 'NOTES';*/

                  /*if l_count > 0 then*/
                        select fldval
                        into l_reject_msg
                        from vsdtrflogdtl
                        where refautoid = rec.autoid
                        and fldname = 'REAS';
                /*              end if;*/
                    exception
                        when no_data_found then
                        l_reject_msg := 'NO EXISTS FIELD 70D';
                    end;

                    update vsdtxreq
                    set msgstatus = 'R',status = 'C', vsd_err_msg = fn_converttelextoutf8(l_reject_msg)
                    where reqid = rec.referenceid;

                    update vsdtrflog set status = 'C', timeprocess = systimestamp where autoid = rec.autoid;

                    if rec.funcname = '598.002.ACCT//ACLS' then
                        update cfmast
                        set nsdstatus = 'R', status = 'A', activests = 'Y'
                        where custodycd = l_msgacct;
                    ELSE
                        update cfmast
                        set nsdstatus = 'R'
                        where custodycd = l_msgacct;
                    end if;

                    plog.debug(pkgctx, rec.referenceid || ' rejected with reason: ' || l_reject_msg);

                end if;
              exception
              when no_data_found then
                   update vsdtxreq
                   set msgstatus = 'R'
                   where reqid = rec.referenceid;
                   update vsdtrflog set status = 'A' where autoid = rec.autoid;
              end;
          /*          end if;*/
          /*commit;*/
        else
          -- confirm cua cac loai khac co phan biet duoc tu choi va thanh cong
          /*    SELECT COUNT(*) INTO L_COUNT FROM VSDTRFCODE
          WHERE STATUS='Y' AND TYPE IN ('CFO','CFN') AND TRFCODE=REC.FUNCNAME;*/
            select count(*)
            into l_count
            from vsdtrfcode trf, vsdtxreq req
            where req.reqid = rec.referenceid
            and trf.trfcode = rec.funcname
            and trf.status = 'Y'
            and trf.type in ('CFO', 'CFN', 'INF')
            and nvl(req.objname, 'a') = nvl(trf.reqtltxcd, 'a');
            if l_count = 1 then
                select trf.type, nvl(trf.tltxcd, 'a'), trf.reqtltxcd
                into l_cf_msgtype, l_cf_tltxcd, l_req_tltxcd
                from vsdtrfcode trf, vsdtxreq req
                where req.reqid = rec.referenceid
                and trf.trfcode = rec.funcname
                and trf.status = 'Y'
                and trf.type in ('CFO', 'CFN', 'INF')
                and nvl(req.objname, 'a') = nvl(trf.reqtltxcd, 'a');
                if l_cf_msgtype = 'CFO' then
              -- dong y
                    if l_req_tltxcd not in('2247','2255') then
                        update vsdtxreq
                        set msgstatus = 'C'
                        where reqid = rec.referenceid
                        and status = 'S';
                    end if;
                    update vsdtrflog set status = 'A' where autoid = rec.autoid;

                    l_reject_msg := ' ';
                    for v_ref in (select fldval
                                  from vsdtrflogdtl
                                  where refautoid = rec.autoid
                                  and fldname = 'REAS')loop
                                  l_reject_msg := v_ref.fldval;
                              end loop;
                    update vsdtxreq
                    set vsd_err_msg = fn_converttelextoutf8(l_reject_msg)
                    where reqid = rec.referenceid;

                    /*IF NVL(l_cf_tltxcd,'---') IN ('2251','2253') THEN
                        auto_complete_confirm_msg(rec.referenceid,l_cf_tltxcd,rec.autoid);
                   END IF;*/

                elsif l_cf_msgtype = 'CFN' then

                    l_reject_msg := ' ';
                    for v_ref in (select fldval
                                  from vsdtrflogdtl
                                  where refautoid = rec.autoid
                                  and fldname = 'REAS') loop
                                  l_reject_msg := v_ref.fldval;
                             end loop;
                   update vsdtxreq
                   set msgstatus = 'R', vsd_err_msg = fn_converttelextoutf8(l_reject_msg)
                   where reqid = rec.referenceid;

                   update vsdtrflog set status = 'A' where autoid = rec.autoid;

                   if l_req_tltxcd = '2247' then
                        auto_call_txpks_2290NAK(rec.referenceid,rec.autoid);
                        update vsdtrflog set status = 'C' where autoid = rec.autoid;
                        return;
                    elsif l_req_tltxcd = '2255' and rec.funcname = '548.INST.LINK//598.SETR//TWAC.STCO//DLWM' then
                        auto_call_txpks_2265NAK(rec.referenceid,rec.autoid);
                        update vsdtrflog set status = 'C' where autoid = rec.autoid;
                        return;
                    end if;

                   /*IF NVL(l_cf_tltxcd,'---') IN ('2236','2257') THEN
                        auto_complete_confirm_msg(rec.referenceid,l_cf_tltxcd,rec.autoid);
                   END IF;*/

                elsif l_cf_msgtype = 'INF' then
                    select count(1) into l_count from vsdtrflog where autoid = rec.autoid and SUBSTR(refcustodycd,1,3) = SUBSTR(reccustodycd,1,3);
                    --if l_count = 0 then
                        /*v_dt_txdate := getcurrdate;
                        v_reqid     := seq_vsdtxreq.nextval;

                        insert into vsdtxreq
                       (reqid, objtype, objname, objkey, trfcode, refcode, txdate,
                       affectdate, afacctno, txamt, bankcode, bankacct, msgstatus,
                       notes, rqtype, status,
                       msgacct, process_id, brid, tlid)
                       values
                       (v_reqid, 'T', v_tltxcd, '', rec.funcname, null, v_dt_txdate,
                       v_dt_txdate, null, 0, 'VSD',
                       cspks_system.fn_get_sysvar('SYSTEM', 'COMPANYNAME'), 'C',
                       'Message received from VSD', 'A', 'S', null,
                       null, '0000', '0000');

                       update vsdtrflog
                       set referenceid = v_reqid
                       where autoid = rec.autoid;
                    else
                        v_reqid:=rec.referenceid;
                    end if;*/
              -- thong tin
                    auto_process_inf_message(rec.autoid,rec.funcname,rec.autoconf,rec.referenceid);
                    return;
                end if;
              elsif l_count = 0 then
                    --truong hop dien thong bao ve bi trung key
                    select trf.type, nvl(trf.tltxcd, 'a'), trf.reqtltxcd
                    into l_cf_msgtype, l_cf_tltxcd, l_req_tltxcd
                    from vsdtrfcode trf
                    where trf.trfcode = rec.funcname
                    and trf.status = 'Y'
                    and trf.type in ('INF');

                    if l_cf_tltxcd is not null then
                       /*v_dt_txdate := getcurrdate;
                       v_reqid     := seq_vsdtxreq.nextval;

                       insert into vsdtxreq
                       (reqid, objtype, objname, objkey, trfcode, refcode, txdate,
                       affectdate, afacctno, txamt, bankcode, bankacct, msgstatus,
                       notes, rqtype, status,
                       msgacct, process_id, brid, tlid)
                       values
                       (v_reqid, 'T', l_cf_tltxcd, '', rec.funcname, null, v_dt_txdate,
                       v_dt_txdate, null, 0, 'VSD',
                       cspks_system.fn_get_sysvar('SYSTEM', 'COMPANYNAME'), 'C',
                       'Message received from VSD', 'A', 'S', null,
                       null, '0000', '0000');

                       update vsdtrflog
                       set referenceid = v_reqid
                       where autoid = rec.autoid;*/

                       auto_process_inf_message(rec.autoid,rec.funcname,rec.autoconf,rec.referenceid);
                       return;
                    end if;
            end if;
        end if;

       plog.error(pkgctx,
                 ' funcname:' || rec.funcname || '2nd  l_cf_tltxcd :' || l_cf_tltxcd );

    -- thay khuc nay xu ly info thua nen comment
        -- xu ly thanh cong cho tung nghiep vu rieng
        if l_cf_tltxcd <> 'a' and l_cf_tltxcd <> 'b' then
          auto_complete_confirm_msg(rec.referenceid,
                                      l_cf_tltxcd,
                                      rec.autoid);
        elsif l_cf_tltxcd = 'a' then
          -- message khong can giao dich CONF-> xu ly luon thanh complete
          update vsdtxreq
             set status = 'C' -- boprocess = 'Y'
           where reqid = rec.referenceid;
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = rec.autoid;
        /*else
          -- xu ly cac msg INF da sinh VSDTXREQ va da duoc duyet
          auto_process_inf_message(rec.autoid,
                                   rec.funcname,
                                   rec.autoconf,
                                   rec.referenceid);*/
        end if;

  elsif l_count = 0 then -- khong co req
        -- xu ly cho cac msg INF moi ve va chua sinh VSDTXREQ
    select count(*)
    into l_count
    from vsdtrfcode
    where status = 'Y'
    and type = 'INF'
    and trfcode = rec.funcname;
    if l_count > 0 then
        -- UPDATE VSDTRFLOG SET STATUS='A' WHERE autoid = rec.autoid;
        select tltxcd
        into v_tltxcd
        from vsdtrfcode
        where type = 'INF'
        and status = 'Y'
        and trfcode = rec.funcname;
        v_dt_txdate := getcurrdate;
        v_reqid     := seq_vsdtxreq.nextval;
        -- chi sinh du lieu vao bang request doi voi cai dien INF co sinh gd
        if nvl(v_tltxcd, 'a') <> 'a' then
            auto_process_inf_message(rec.autoid,rec.funcname,rec.autoconf,rec.referenceid);
        else
            -- message khong can giao dich CONF-> xu ly luon thanh complete
            auto_process_inf_message(rec.autoid,rec.funcname,rec.autoconf,rec.referenceid);
            update vsdtrflog
            set status = 'C', timeprocess = systimestamp
            where autoid = rec.autoid;
         end if;
    else
        auto_process_inf_message(rec.autoid,rec.funcname,rec.autoconf,rec.referenceid);
        update vsdtrflog
        set status = 'C', timeprocess = systimestamp
        where autoid = rec.autoid;
    end if;
  end if;
end loop;
 END IF;
    plog.setendsection(pkgctx, 'pr_auto_process_message');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_auto_process_message');
  end pr_auto_process_message;
  procedure auto_process_inf_message(pv_autoid   number,
                                     pv_funcname varchar2,
                                     pv_autoconf varchar2,
                                     pv_reqid    number) as
    v_tltxcd          varchar2(4);
    v_dt_txdate       date;
    v_reqid           number;
    v_vsdmsgid        VARCHAR2(50);
    v_VSDPROMSG       VARCHAR2(20);
    v_VSDPROMSG_value VARCHAR2(50);
    v_symbol          VARCHAR2(100);
    v_symbol2          VARCHAR2(100);
    v_rhts          VARCHAR2(100);
    v_vsdmsgdate      VARCHAR2(10);
    v_vsdmsgdate_eff  VARCHAR2(10);
    v_vsdmsgtype      VARCHAR2(10);
    v_CUSTODYCD       VARCHAR2(10);
    v_refCUSTODYCD    VARCHAR2(10);
    v_qtty            VARCHAR2(20);
    v_datetype        VARCHAR2(10);
    v_adress          VARCHAR2(200);
    v_rate            VARCHAR2(20);
    v_price           VARCHAR2(20);
    v_RIGHTOFFRATE    VARCHAR2(20);
    v_BEGINDATE       VARCHAR2(50);
    v_EXPRICE         VARCHAR2(100);
    v_FRDATETRANSFER  VARCHAR2(50);
    v_FromSE          varchar2(20);
    v_ToSE            varchar2(20);
    v_vsdReqID        varchar2(60);
    v_Sectype         varchar2(10);
    v_VSDSectype      varchar2(200);
    v_Unit            varchar2(15);
    v_tradingdate     varchar2(15);
    v_detail          varchar2(2000) DEFAULT '';
    v_detail1         varchar2(200) DEFAULT '';
    v_detail2         varchar2(200) DEFAULT '';
    v_detail3         varchar2(1000) DEFAULT '';
    v_index           number;
    v_currdate        date;
    v_link            VARCHAR2(50);
    v_trfcode         VARCHAR2(50);
    v_PlaceID         varchar2(30);
    v_PlaceID2         varchar2(30);
    v_notes           varchar2(1000);
    v_postdate        varchar2(15);
    v_round           varchar2(50);
    v_enddate         varchar2(15);
    v_TODATETRANSFER  varchar2(15);
    v_exrate          VARCHAR2(20);
    v_tax             VARCHAR2(50);
    v_QUANTITY        VARCHAR2(50);
    v_VND             VARCHAR2(50);
    v_VSDEFFDATE      VARCHAR2(50);
    l_reqid           VARCHAR2(200);
    l_countcuscd      number;
    l_VSDPROMSGID     VARCHAR2(500);
    l_number          number;
    l_custodycd       VARCHAR2(50);
    --TTBT T+1.5
    l_clearauto       varchar2(5);
    l_err_code        varchar2(100);
    v_strdt_txdate    varchar2(20);
    --End TTBT T+1.5
    --TTBT T+1.5 TP
    l_cleartype       varchar2(4000);
    --End TTBT T+1.5 TP
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_process_inf_message');

    plog.error(pkgctx,
              'process auto id:' || pv_autoid || '::function:' ||
              pv_funcname || '::auto confirm:' || pv_autoconf || '::reqId:' ||
              pv_reqid);

    v_currdate := getcurrdate;

    SELECT nvl(tltxcd,'0')
      INTO v_tltxcd
      FROM vsdtrfcode
     WHERE trfcode = pv_funcname;
    --Neu message la tu dong xu ly (cu la Y)

    if pv_autoconf = 'Y' then
      update vsdtrflog set status = 'A' where autoid = pv_autoid;

      if v_tltxcd = '2245' then
        if INSTR(pv_funcname, 'TBAC') > 0 then

            select count(1) into l_countcuscd from vsdtrflog where autoid = pv_autoid and SUBSTR(refcustodycd,1,3) = SUBSTR(reccustodycd,1,3);
            if l_countcuscd > 0 then
                plog.error('Before call 2248. l_custodycd='||l_custodycd||', pv_autoid='||pv_autoid||', l_countcuscd='||l_countcuscd);
                select fldval into l_reqid from vsdtrflogdtl where fldname = 'REQID' and refautoid = pv_autoid;
                select msgacct into l_custodycd from vsdtxreq where reqid = l_reqid;
                auto_call_txpks_22482(l_reqid, pv_autoid);
                auto_call_txpks_0059(l_reqid,l_custodycd);
            else
                auto_call_txpks_2245(pv_reqid, pv_autoid);
            end if;
        elsif INSTR(pv_funcname, 'TWAC') > 0 or INSTR(pv_funcname, 'OWNI') > 0 then

            select count(1) into l_countcuscd from vsdtrflog where autoid = pv_autoid and SUBSTR(refcustodycd,1,3) = SUBSTR(reccustodycd,1,3);

            if l_countcuscd > 0 then
                select fldval into l_reqid from vsdtrflogdtl where fldname = 'REQID' and refautoid = pv_autoid;
                auto_call_txpks_2266(l_reqid, pv_autoid);
            else
                auto_call_txpks_2245(pv_reqid, pv_autoid);
            end if;
        else

            auto_call_txpks_2245(pv_reqid, pv_autoid);
        end if;
      ELSIF v_tltxcd = '3320' then
        auto_call_txpks_3320(pv_reqid, pv_autoid);
      ELSIF v_tltxcd = '8894' then
        auto_call_txpks_8879(pv_reqid, pv_autoid);
        auto_call_txpks_8894(pv_reqid, pv_autoid);
      ELSIF v_tltxcd = '2266' then
        auto_call_txpks_2266(pv_reqid, pv_autoid);
      ELSIF v_tltxcd = '2248' then
        auto_call_txpks_2248(pv_reqid, pv_autoid);
      ELSIF v_tltxcd = '3385' then
        auto_call_txpks_3385(pv_reqid, pv_autoid);
      end if;
    else
        update vsdtrflog
        set status = 'C', timeprocess = systimestamp
        where autoid = pv_autoid;
    end if;

      IF pv_funcname like '508.%' then
        BEGIN
            SELECT *
            INTO v_vsdmsgid,
                 v_vsdReqID,
                 v_vsdmsgdate,
                 v_vsdmsgtype,
                 v_CUSTODYCD,
                 v_symbol,
                 v_FromSE,
                 v_ToSE,
                 v_Qtty,
                 v_Sectype,
                 v_VSDSectype,
                 v_Unit,
                 v_notes,
                 v_VSDEFFDATE
            FROM (SELECT fldname, fldval
                    FROM vsdtrflogdtl
                   WHERE REFAUTOID = pv_autoid) PIVOT(MAX(fldval) as F for(fldname) IN('VSDMSGID',
                                                                                        'REQID',
                                                                                        'VSDMSGDATE',
                                                                                        'VSDFUNCNAME',
                                                                                        'CUSTODYCD',
                                                                                        'SYMBOL',
                                                                                        'FROMSE',
                                                                                        'TOSE',
                                                                                        'QTTY',
                                                                                        'SECTYPE',
                                                                                        'VSDSECTYPE',
                                                                                        'UNIT',
                                                                                        'NOTES',
                                                                                        'VSDEFFDATE'
                                                                                        ));

              --Insert thong tin vao bang VSD_MT508_INF

              INSERT INTO vsd_mt508_inf(autoid, vsdmsgid,VSDPROMSG, vsdreqid, vsdmsgdate , vsdmsgtype, custodycd, symbol, fromse, tose, qtty, sectype, vsdsectype, unit,description,VSDEFFDATE)
              select seq_vsd_mt508_inf.nextval autoid, pv_autoid,pv_funcname, v_vsdmsgid,
              (case when length(trim(v_vsdmsgdate)) > 0 then to_date(v_vsdmsgdate, 'RRRRMMDD') else null end), v_vsdmsgtype, v_CUSTODYCD, v_symbol, v_FromSE, v_ToSE, v_Qtty, v_Sectype,
              v_VSDSectype, v_Unit,v_notes,
              (case when length(trim(v_VSDEFFDATE)) > 0 then to_date(v_VSDEFFDATE, 'RRRRMMDD') else null end)
              from dual;
        END;

      ELSIF pv_funcname like '598.007%' then
        BEGIN

          SELECT *
            INTO v_vsdmsgid,
                 v_VSDPROMSG,
                 v_vsdmsgtype,
                 v_symbol,
                 v_vsdmsgdate,
                 v_vsdmsgdate_eff,
                 v_qtty,
                 v_tradingdate,
                 v_VSDPROMSG_value,
                 v_detail,
                 v_PlaceID,
                 v_rate,
                 l_VSDPROMSGID,
                 l_cleartype --TTBT T+1.5 TP
            FROM (SELECT fldname, decode(fldname,'DETAIL',replace(fldval,chr(10),'|'),fldval) fldval
                    FROM vsdtrflogdtl
                   WHERE REFAUTOID = pv_autoid) PIVOT(MAX(fldval) as F for(fldname) IN('VSDMSGID',
                                                                                       'VSDPROMSG',
                                                                                       'VSDMSGTYPE',
                                                                                       'SYMBOL',
                                                                                       'CRDATE',
                                                                                       'VSDEFFDATE',
                                                                                       'QTTY',
                                                                                       'TRADINGDATE',
                                                                                       'CLASS',
                                                                                       'NOTES',
                                                                                       'PLACEID',
                                                                                       'RATE',
                                                                                       'VSDPROMSGID',
                                                                                       'FULLNOTES' --TTBT T+1.5 TP
                                                                                       ));


          if length(v_detail) > 0 and v_VSDPROMSG = 'ESET' then
              select SUBSTR(v_detail,1,INSTR(v_detail,'|',1)-1), INSTR(v_detail,'|',1)  into v_detail1, v_index from dual;
              v_detail := REPLACE(v_detail,v_detail1||'|','');
              select SUBSTR(v_detail,1,INSTR(v_detail,'|',1)-1), INSTR(v_detail,'|',1)  into v_detail2, v_index from dual;
              v_detail := REPLACE(v_detail,v_detail2||'|','');
              v_detail3 := v_detail;

          ELSE
            v_detail1 := null;
            v_detail2 := null;
            v_detail3 := null;

          end if;


          /*if v_vsdmsgdate is null then
            v_vsdmsgdate := to_char(v_currdate,'RRRRMMDD');
          end if;*/

          if length(v_PlaceID) > 0 then
            select cdcontent into v_PlaceID2 from allcode a where a.cdname = 'PLACEID' and a.cdval = v_PlaceID;
          end if;


          if INSTR(v_tradingdate,'TRAD') > 0 then
            v_tradingdate:= SUBSTR(v_tradingdate,6);
          else
            v_tradingdate:='';
          end if;


          --Insert thong tin vao bang VSD_MT598_INF
          INSERT INTO vsd_mt598_inf
            (AUTOID, VSDMSGID, vsdsubmsgtype, VSDPROMSG, vsdpromsg_value, SYMBOL, VSDMSGDATE, VSDMSGDATEEFF, VSDMSGTYPE, QTTY, TRADINGDATE, paymentcycle, description, PLACEID,ROOM,VSDPROMSGID)
          VALUES
            (seq_vsd_mt598_inf.nextval,
             pv_autoid,
             v_VSDPROMSG_value,
             pv_funcname||v_VSDPROMSG||'.',
             v_VSDPROMSG,
             v_symbol,
             case when LENGTH(trim(v_vsdmsgdate)) > 0 then to_date(v_vsdmsgdate, 'RRRRMMDD') else null end,
             case when LENGTH(trim(v_vsdmsgdate_eff)) > 0 then to_date(v_vsdmsgdate_eff, 'RRRRMMDD') else null end,
             v_vsdmsgtype,
             v_qtty,
             nvl(v_detail1,v_tradingdate),v_detail2,
             decode(v_VSDPROMSG,'ESET',v_detail3,v_detail),
             v_PlaceID2,
             v_rate,l_VSDPROMSGID
             );
          END;

          --TTBT T+1.5
        IF v_VSDPROMSG = 'ESET' THEN -- dien thong bao ttbt
            --TTBT T+1.5 TP : Tach co TTBT CP va TP ra rieng
            l_cleartype := substr(l_cleartype,instr(l_cleartype,chr(10))+1,1);
            if l_cleartype = '2' then
                l_clearauto := upper(cspks_system.fn_get_sysvar('SYSTEM','BONDCLEARINGAUTO'));
            else
                l_clearauto := upper(cspks_system.fn_get_sysvar('SYSTEM','CLEARINGAUTO'));
            end if;
            --End TTBT T+1.5 TP
            IF l_clearauto ='A' THEN
                v_strdt_txdate := TO_CHAR(case when length(trim(v_vsdmsgdate))>0 then to_date(v_vsdmsgdate, 'RRRRMMDD') else null end, systemnums.C_DATE_FORMAT);
                -- goi ham xu ly thanh toan bu tru
                pck_auto_settlement.pr_create_job_process(p_trade_date => v_strdt_txdate,p_action => l_clearauto,p_cleartype => l_cleartype,p_err_code => l_err_code); --TTBT T+1.5 TP them l_cleartype
            ELSE
                -- sinh sms thong bao lam thanh toan bu tru khi nhan dien ma action dang la manual
                pck_auto_settlement.pr_create_send_smsemail('M',0,'',l_cleartype); --TTBT T+1.5 TP them l_cleartype
            END IF;

            IF nvl(l_err_code,0) <> systemnums.c_success THEN
               UPDATE vsdtrflog SET status = 'E', timeprocess = systimestamp,
                                    errdesc = 'Khong xu ly duoc nghiep vu -'||l_err_code
                 WHERE autoid = pv_autoid AND status = 'P';

            /*ELSE
               UPDATE vsdtrflog
                  SET status = 'C', timeprocess = systimestamp
                WHERE autoid = pv_autoid;*/
            END IF;
         END IF;
            --End TTBT T+1.5
      ELSIF pv_funcname like '544.%' then
        BEGIN
            SELECT *
            INTO v_vsdmsgid,
                 v_vsdReqID,
                 v_vsdmsgdate,
                 v_vsdmsgtype,
                 v_CUSTODYCD,
                 v_symbol,
                 v_symbol2,
                 v_FromSE,
                 v_ToSE,
                 v_Qtty,
                 v_Sectype,
                 v_VSDSectype,
                 v_Unit,
                 v_link,
                 v_refcustodycd,
                 v_notes,
                 v_VSDEFFDATE
            FROM (SELECT fldname, fldval
                    FROM vsdtrflogdtl
                   WHERE REFAUTOID = pv_autoid) PIVOT(MAX(fldval) as F for(fldname) IN('VSDMSGID',
                                                                                        'REQID',
                                                                                        'VSDMSGDATE',
                                                                                        'VSDFUNCNAME',
                                                                                        'CUSTODYCD',
                                                                                        'SYMBOL',
                                                                                        'SYMBOL2',
                                                                                        'SETR',
                                                                                        'STCO',
                                                                                        'QTTY',
                                                                                        'SECTYPE',
                                                                                        'VSDSECTYPE',
                                                                                        'UNIT','LINK','REFCUSTODYCD',
                                                                                        'NOTES','VSDEFFDATE'));

                --Xu ly cho dien 544
                v_rhts:= v_symbol;
                if v_FromSE is not null then
                    v_FromSE:= 'SETR//'||v_FromSE;
                end if;
                if v_ToSE is not null then
                    if INSTR(v_FromSE,v_ToSE) <= 0 then
                        v_ToSE:= 'STCO//'||v_ToSE;
                    else
                        v_ToSE:= '';
                    end if;
                end if;

                if v_link is not null then
                    v_link:= 'LINK//'||v_link;
                end if;

                if INSTR(v_rhts,'RHTS')>0 then
                    v_symbol:=v_symbol2;
                    v_trfcode:= '544.'||v_vsdmsgtype||'.'||v_link||'.'||v_FromSE||'.'||v_ToSE||'.RHTS';
                else
                    v_trfcode:= '544.'||v_vsdmsgtype||'.'||v_link||'.'||v_FromSE||'.'||v_ToSE||'.OK';
                end if;

                begin
                    v_VSDSectype:=TO_NUMBER(v_VSDSectype);
                exception
                    when others then
                    v_notes:=v_VSDSectype;
                    v_VSDSectype:='0';
                end;

              --Insert thong tin vao bang VSD_MT508_INF

              INSERT INTO vsd_mt508_inf(autoid, vsdmsgid,VSDPROMSG, vsdreqid, vsdmsgdate , vsdmsgtype, custodycd, symbol, fromse, tose, qtty, sectype, vsdsectype, unit,refcustodycd,description,VSDEFFDATE)
              select seq_vsd_mt508_inf.nextval autoid, pv_autoid,v_trfcode, v_vsdmsgid,
              (case when LENGTH(trim(v_vsdmsgdate)) > 0 then to_date(v_vsdmsgdate, 'RRRRMMDD') else null end), v_vsdmsgtype, v_CUSTODYCD, v_symbol, v_FromSE, v_ToSE, v_Qtty, v_Sectype, v_VSDSectype,
              v_Unit,v_refcustodycd,v_notes,
              (case when LENGTH(trim(v_VSDEFFDATE)) > 0 then to_date(v_VSDEFFDATE, 'RRRRMMDD') else null end)
              from dual;
        END;
      ELSIF pv_funcname like '546.%' then
        BEGIN
            SELECT *
            INTO v_vsdmsgid,
                 v_vsdReqID,
                 v_vsdmsgdate,
                 v_vsdmsgtype,
                 v_CUSTODYCD,
                 v_symbol,
                 v_FromSE,
                 v_ToSE,
                 v_Qtty,
                 v_Sectype,
                 v_VSDSectype,
                 v_Unit,
                 v_notes,
                 v_VSDEFFDATE
            FROM (SELECT fldname, fldval
                    FROM vsdtrflogdtl
                   WHERE REFAUTOID = pv_autoid) PIVOT(MAX(fldval) as F for(fldname) IN('VSDMSGID',
                                                                                        'REQID',
                                                                                        'VSDMSGDATE',
                                                                                        'VSDFUNCNAME',
                                                                                        'CUSTODYCD',
                                                                                        'SYMBOL',
                                                                                        'FROMSE',
                                                                                        'TOSE',
                                                                                        'QTTY',
                                                                                        'SECTYPE',
                                                                                        'VSDSECTYPE',
                                                                                        'UNIT','NOTES','VSDEFFDATE'));

              --Insert thong tin vao bang VSD_MT508_INF

              INSERT INTO vsd_mt508_inf(autoid, vsdmsgid,VSDPROMSG, vsdreqid, vsdmsgdate , vsdmsgtype, custodycd, symbol, fromse, tose, qtty, sectype, vsdsectype, unit, description,VSDEFFDATE)
              select seq_vsd_mt508_inf.nextval autoid, pv_autoid,pv_funcname, v_vsdmsgid,
              (case when length(trim(v_vsdmsgdate)) > 0 then to_date(v_vsdmsgdate, 'RRRRMMDD') else null end), v_vsdmsgtype, v_CUSTODYCD, v_symbol, v_FromSE, v_ToSE, v_Qtty, v_Sectype,
              v_VSDSectype, v_Unit, v_notes,
              (case when length(trim(v_VSDEFFDATE)) > 0 then to_date(v_VSDEFFDATE, 'RRRRMMDD') else null end)
              from dual;
        END;
      ELSIF pv_funcname like '564.%' then
        --elsif v_tltxcd = '2245' then
        --  NULL;
        --auto_call_txpks_2245(pv_reqid, pv_autoid);
        --ELSIF INSTR(pv_funcname,'564') > 0 or INSTR(pv_funcname,'544') >0 THEN
        BEGIN
          SELECT *
            INTO v_vsdmsgid,
                 v_VSDPROMSG,
                 v_VSDPROMSG_value,
                 v_symbol,
                 v_vsdmsgdate,
                 v_vsdmsgdate_eff,
                 v_vsdmsgtype,
                 v_qtty,
                 v_CUSTODYCD,
                 v_refCUSTODYCD,
                 v_datetype,
                 v_adress,
                 v_rate,
                 v_price,
                 v_BEGINDATE,
                 v_EXPRICE,
                 v_FRDATETRANSFER,v_TODATETRANSFER,
                 v_symbol2,v_postdate, v_round,
                 v_enddate,v_notes,v_QUANTITY
            FROM (SELECT fldname, fldval
                    FROM vsdtrflogdtl
                   WHERE REFAUTOID = pv_autoid) PIVOT(MAX(fldval) as F for(fldname) IN('VSDMSGID',
                                                                                       'VSDPROMSG',
                                                                                       'VSDPROMSGDTL',
                                                                                       'SYMBOL',
                                                                                       'TXDATE',
                                                                                       'VSDEFFDATE',
                                                                                       'CATYPE',
                                                                                       'QTTY',
                                                                                       'CUSTODYCD',
                                                                                       'REFCUSTODYCD',
                                                                                       'DATETYPE',
                                                                                       'ADDRESSMEET',
                                                                                       'EXRATE',
                                                                                       'PRICE',
                                                                                       'BEGINDATE',
                                                                                       'EXPRICE',
                                                                                       'FRDATE','TODATE','REFSYMBOL','POSTDATE','ROUND',
                                                                                       'ENDDATE','NOTES','QUANTITY'));

          --Insert thong tin vao bang VSD_MT598_INF
          /*if INSTR(pv_funcname, '544') > 0 then
            v_vsdmsgtype := 'DLWM';
          end if;*/
          if v_RIGHTOFFRATE is not null then
            v_RIGHTOFFRATE:= SUBSTR(v_RIGHTOFFRATE,6);
          end if;

          --92A
          if v_rate is not null then
            v_exrate:= SUBSTR(v_rate,6);
            v_tax:=SUBSTR(v_rate,1,4);
            if INSTR(v_exrate,'/')>0 then
                v_exrate:=SUBSTR(v_exrate,1,INSTR(v_exrate,'/')-1);
            end if;

            if INSTR(v_exrate,'%')>0 then
                v_RIGHTOFFRATE:= replace(v_exrate,'%');
                v_exrate:='100/'||REPLACE(v_exrate,'%');
            elsif INSTR(v_exrate,':')>0 then
                v_exrate:=REPLACE(v_exrate,':','/');
                v_RIGHTOFFRATE:=ROUND(SUBSTR(v_exrate,1,INSTR(v_exrate,'/') -1) / SUBSTR(v_exrate,INSTR(v_exrate,'/') + 1) *100,4);
            end if;

            if v_exrate is null then
                v_tax:='';
            end if;

          end if;

          if v_BEGINDATE is not null then
            v_enddate:=SUBSTR(v_BEGINDATE,15);
            v_BEGINDATE:=SUBSTR(v_BEGINDATE,6,8);
          end if;
          if v_FRDATETRANSFER is not null then
            v_TODATETRANSFER:=SUBSTR(v_FRDATETRANSFER,15);
            v_FRDATETRANSFER:=SUBSTR(v_FRDATETRANSFER,6,8);
          end if;
          if v_EXPRICE is not null then
            v_VND:=SUBSTR(v_EXPRICE,1,3);
            v_EXPRICE:=SUBSTR(v_EXPRICE,4);
          end if;

          --so luong
          if v_QUANTITY is null then
             v_QUANTITY:=v_qtty;
          end if;
          --price
          v_price:=REPLACE(
                        SUBSTR(v_price,1, (
                                          case when INSTR(v_price,' ') > 0 then INSTR(v_price,' ') -1
                                               else LENGTH(v_price) end
                                          )
                        ),'.');

          if v_symbol2 is null then
            v_symbol2:=v_symbol;
          end if;

          select count(1) into l_number from vsd_mt564_inf where vsdreference = v_vsdmsgid;
          if l_number > 0 then
            update vsd_mt564_inf set msgstatus = 'C' where vsdreference = v_vsdmsgid;
          end if;

          INSERT INTO vsd_mt564_inf
            (autoid,
             VSDMSGID,
             VSDPROMSG,
             VSDPROMSG_VALUE,
             SYMBOL,
             VSDMSGDATE,
             VSDMSGDATEEFF,
             VSDMSGTYPE,
             QTTY,
             custodycd,
             refcustodycd,
             datetype,
             adress,
             exrate,
             price,
             RIGHTOFFRATE,
             BEGINDATE,
             ENDDATE,
             EXPRICE,
             FRDATETRANSFER,REFSYMBOL,POSTDATE,ROUND,
             TODATETRANSFER,DESCRIPTION,TAX,EXPRICETYPE, VSDREFERENCE
             )
          VALUES
            (seq_vsd_mt564_inf.nextval,
             pv_autoid,
             pv_funcname,
             v_VSDPROMSG_value,
             v_symbol,
             (case when length(trim(v_vsdmsgdate)) > 0 then to_date(v_vsdmsgdate, 'RRRRMMDD') else null end),
             (case when length(trim(v_vsdmsgdate_eff)) > 0 then to_date(v_vsdmsgdate_eff, 'RRRRMMDD') else null end),
             v_vsdmsgtype,
             to_number(v_QUANTITY),
             v_CUSTODYCD,
             v_refCUSTODYCD,
             (case when length(trim(v_datetype)) > 0 then to_date(v_datetype, 'RRRRMMDD') else null end),
             v_adress,
             v_exrate,
             to_number(v_price),
             v_RIGHTOFFRATE,
             (case when length(trim(v_BEGINDATE)) > 0 then to_date(v_BEGINDATE, 'RRRRMMDD') else null end),
             (case when length(trim(v_enddate)) > 0 then to_date(v_enddate, 'RRRRMMDD') else null end),
             v_EXPRICE,
             (case when length(trim(v_FRDATETRANSFER)) > 0 then to_date(v_FRDATETRANSFER, 'RRRRMMDD') else null end),v_symbol2,
             (case when length(trim(v_postdate)) > 0 then to_date(v_postdate, 'RRRRMMDD') else null end),
             v_round,
             (case when length(trim(v_TODATETRANSFER)) > 0 then to_date(v_TODATETRANSFER, 'RRRRMMDD') else null end),
             v_notes,v_tax,v_VND, v_vsdmsgid
             );
          ---case de goi phan xu ly tuong ung, v_VSDPROMSG_value
            IF v_VSDPROMSG_value = 'NEWM' THEN
                create_new_ca(pv_reqid, pv_autoid, v_vsdmsgtype);
            ELSIF v_VSDPROMSG_value = 'REPL' THEN
                edit_CA(pv_reqid, pv_autoid, v_vsdmsgtype);
            ELSIF v_VSDPROMSG_value = 'CANC' THEN
                cancel_CA(pv_reqid, pv_autoid);
            end if;
        END;

      end if;
    plog.setendsection(pkgctx, 'auto_process_inf_message');
  exception
    when no_data_found then
      plog.warn(pkgctx, 'Chua khai bao ' || pv_funcname);
      UPDATE vsdtrflog SET status = 'E' WHERE autoid = pv_autoid;
      plog.setendsection(pkgctx, 'auto_process_inf_message');
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_process_inf_message');
  end auto_process_inf_message;
  procedure sp_auto_create_message as
    v_trflogid number;
    cursor v_cursor is
      select reqid
        from vsdtxreq
       where status = 'P'
            --and adtxprocess = 'N'
         and trfcode in (select trfcode
                           from vsdtrfcode
                          where status = 'Y'
                            and type IN ('REQ', 'EXREQ'));
    v_row v_cursor%rowtype;
  begin

    open v_cursor;
    loop
      fetch v_cursor
        into v_row;
      exit when v_cursor%notfound;

      --Create message
      sp_create_message(v_row.reqid);
    end loop;
  end sp_auto_create_message;

  procedure sp_message_tofile(f_msgcontent in varchar, f_reqid in number) as
    v_filename varchar2(100);
    l_line     varchar2(255);
    l_done     number;
    l_file     utl_file.file_type;
  begin
    --Send to VSD Gateway
    v_filename := f_reqid || '.xml';
    l_file     := utl_file.fopen('DIR_VSD_OUTPUT', v_filename, 'A');
    loop
      exit when l_done = 1;
      dbms_output.get_line(l_line, l_done);
      utl_file.put_line(l_file, f_msgcontent);
    end loop;
    utl_file.fflush(l_file);
    utl_file.fclose(l_file);
  end sp_message_tofile;

  procedure sp_create_message(f_reqid in number) as
    v_request   varchar2(4000);
    v_count     number;
    l_sqlerrnum varchar2(2000);
  begin
    --Neu message da tao hoac khoi luong bang 0 (ngoai tru msg mo tai khoan th? ko tao message)
    select count(*)
      into v_count
      from vsdtxreq
     where reqid = f_reqid
       and msgstatus = 'P'
       and (case
             when trfcode in
                  ('598.NEWM/AOPN','598.NEWM/REAOPN','598.NEWM/003', '598.NEWM/ACLS', '598.NEWM.ACCT//TBAC','598.NEWM.ACCT//TWAC','598.005.BALANCE','598.006.BALANCE','598.006.CAINFO','598.005.CAINFO','598.005.TRADE','598.006.TRADE'
                  ) then
              1
             else
              nvl(txamt, 0)
           end) > 0;

    if v_count = 0 then
      return;
    end if;

    --Get message
    v_request := fn_get_vsd_request(f_reqid);

    --Enqueue
    --sp_message_tofile(v_request, f_reqid);
    cspks_esb.sp_set_message_queue(v_request, 'txaqs_flex2vsd');

    insert into vsdmsgfromflex
      (reqid, msgbody, status)
    values
      (f_reqid, v_request, 'P');

    --Update status
    update vsdtxreq
       set status = 'S', msgstatus = 'S' --, adtxprocess = 'Y'
     where reqid = f_reqid
       and status = 'P';

  exception
    when others then
      l_sqlerrnum := substr(sqlerrm || dbms_utility.format_error_backtrace,1,3000);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'sp_create_message', l_sqlerrnum);
  end sp_create_message;

  function fn_get_vsd_request(f_reqid in number) return varchar as
    v_trfcode varchar2(60);
    v_sympend char(1);
    v_refval  varchar2(180);
    v_field   varchar2(1180);
    v_request varchar2(30000);
    v_sysbol  varchar2(20);
    cursor v_cursor is
      select fldname,
             (case
               when (nval <> 0) then
                to_char(nval)
               else
                translate(cval, 'A$', 'A')
             end) fldval,
             xmlelement("fldval",(case
               when (nval <> 0) then
                to_char(nval)
               else
                translate(cval, 'A$', 'A')
             end)).getstringval() xmlval
        from vsdtxreqdtl
       where reqid = f_reqid;
    v_row v_cursor%rowtype;
  begin
    plog.setbeginsection(pkgctx, 'fn_get_vsd_request');
    --read header
    select trfcode into v_trfcode from vsdtxreq where reqid = f_reqid;
    v_sympend := 'N';
    --read body
    open v_cursor;
    loop
      fetch v_cursor
        into v_row;
      exit when v_cursor%notfound;
      if v_row.fldname = 'SYMBOL' then
        begin

          v_field := '<field><fldname convert="">' || v_row.fldname ||
                     '</fldname><fldval>' ||
                     replace(v_row.fldval, '_WFT', '') ||
                     '</fldval></field>';
          /* select nvl(codeid, '')
            into v_refval
            from sbsecurities
           where symbol = v_row.fldval;
          v_field := v_field ||
                     '<field><fldname>REFCORPID</fldname><fldval>' ||
                     v_refval || '</fldval></field>';*/ -- tam thoi bo doan nay di
          if (instr(v_row.fldval, '_WFT') > 0) then
            v_sympend := 'Y';
          end if;
        end;
      else
        if (instr(v_row.fldname, 'DATE') > 0) then
          begin
            --Convert date value
            select to_char(to_date(v_row.fldval, 'DD/MM/RRRR'), 'YYYYMMDD')
              into v_refval
              from dual;
            v_field := '<field><fldname convert="">' || v_row.fldname ||
                       '</fldname><fldval>' || v_refval ||
                       '</fldval></field>';
          end;
        else
          if instr(v_row.fldname, 'FULLNAME') > 0 or
             instr(v_row.fldname, 'ADDRESS') > 0 or
             instr(v_row.fldname, 'NOTES') > 0 or
             instr(v_row.fldname, 'DESC') > 0 or
             instr(v_row.fldname, 'IDCODE') > 0 or
             instr(v_row.fldname, 'IDPLACE') > 0 then
            v_field := '<field><fldname convert="F">' || v_row.fldname ||
                       '</fldname>' || v_row.xmlval || '</field>';

          else
            v_field := '<field><fldname convert="">' || v_row.fldname ||
                       '</fldname>' || v_row.xmlval || '</field>';
          end if;
        end if;
      end if;
      v_request := v_request || v_field;
      plog.setendsection(pkgctx, 'fn_get_vsd_request');
    end loop;
    v_request := v_request ||
                 '<field><fldname convert="">REQID</fldname><fldval>' ||
                 f_reqid || '</fldval></field>';
    if (v_sympend = 'Y' and v_trfcode = '500.INST//REGI.NORM') then
      return '<root><txcode funcname="500.INST//REGI.PEND" referenceid="' || f_reqid || '"><detail>' || v_request || '</detail></txcode></root>';
    else
      return '<root><txcode funcname="' || v_trfcode || '" referenceid="' || f_reqid || '"><detail>' || v_request || '</detail></txcode></root>';
    end if;
    plog.setendsection(pkgctx, 'fn_get_vsd_request');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_get_vsd_request');
      return '';
  end fn_get_vsd_request;

  procedure sp_auto_gen_vsd_req as
    v_trflogid number;
    cursor v_cursor is
      select autoid
        from vsd_process_log
       where process = 'N'
         and trfcode in (select trfcode
                           from vsdtrfcode
                          where status = 'Y'
                            and type IN ('REQ', 'EXREQ'));
    v_row v_cursor%rowtype;
  begin
    plog.setbeginsection(pkgctx, 'sp_auto_gen_vsd_req');
    --Sinh request vao vsdtxreq
    open v_cursor;
    loop
      fetch v_cursor
        into v_row;
      exit when v_cursor%notfound;

      --sinh vao VSDTXREQ, vsdtxreqdtl
      sp_gen_vsd_req(v_row.autoid);

      update vsd_process_log set process = 'Y' where autoid = v_row.autoid;
    end loop;

    -- goi ham tu dong gen message day len VSD
    sp_auto_create_message;
    plog.setendsection(pkgctx, 'sp_auto_gen_vsd_req');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'sp_auto_gen_vsd_req');
  end sp_auto_gen_vsd_req;

  procedure sp_gen_vsd_req(pv_autoid number) as
    type v_curtyp is ref cursor;
    v_trfcode            varchar2(100);
    v_tltxcd             varchar2(50);
    v_txnum              varchar2(10);
    v_custid             varchar2(10);
    l_vsdmode            varchar2(10);
    l_vsdtxreq           number;
    v_dt_txdate          date;
    v_notes              varchar2(1000);
    v_afacctno_field     varchar2(100);
    v_afacctno           varchar2(10);
    v_txamt_field        varchar2(100);
    v_txamt              number(20, 4);
    v_custodycd          varchar2(10);
    v_value              varchar2(1000);
    v_ovalue              varchar2(1000);
    v_chartxdate         varchar2(50);
    v_extcmdsql          varchar2(2000);
    v_notes_field        varchar2(10);
    v_msgacct_field      varchar2(10);
    v_msgacct            varchar2(30);
    c0                   v_curtyp;
    l_sqlerrnum          varchar2(200);
    v_log_msgacct        varchar2(50);
    v_fldrefcode_field   varchar2(50);
    v_refcode            varchar2(100);
    v_brid               varchar2(4);
    v_tlid               varchar2(4);
    l_vsdbiccode         varchar2(11);
    l_biccode            varchar2(11);
    l_count2247          number;
    l_custodycd2247      varchar2(10);
    l_count2255          number;
    l_custodycd2255      varchar2(10);
    l_count_vsdrxreq     NUMBER;
    l_count_vsdtxreq2255 NUMBER;
    l_vsdmessage_type    VARCHAR2(10);
    l_sendtovsd0059      VARCHAR2(1);
  begin
    plog.setbeginsection(pkgctx, 'sp_gen_vsd_req');
    l_vsdmode := cspks_system.fn_get_sysvar('SYSTEM', 'VSDMOD');


    select trfcode, tltxcd, txnum, txdate, msgacct, brid, tlid
      into v_trfcode,
           v_tltxcd,
           v_txnum,
           v_dt_txdate,
           v_log_msgacct,
           v_brid,
           v_tlid
      from vsd_process_log
     where autoid = pv_autoid;




    select biccode, vsdbiccode
      into l_biccode, l_vsdbiccode
      from vsdbiccode
     where brid = v_brid;



    if l_vsdmode = 'A' then
      -- ket noi tu dong
      v_chartxdate := to_char(v_dt_txdate, 'DD/MM/RRRR');

      begin
        select nvl(map.fldacctno,'a'),
               map.amtexp,
               map.fldnotes,
               nvl(map.fldrefcode, 'a')
          into v_afacctno_field,
               v_txamt_field,
               v_notes_field,
               v_fldrefcode_field
          from vsdtxmap map
         where map.objname = v_tltxcd
           and map.trfcode = v_trfcode;
      exception
        when no_data_found then
          plog.warn(pkgctx,
                    'TLTXCD:' || v_tltxcd || '::TRFCODE:' || v_trfcode ||
                    ':: not found in VSDTXMAP');
          plog.setendsection(pkgctx, 'sp_gen_vsd_req');
          return;
      end;
     /* v_txamt := fn_eval_amtexp(v_txnum, v_chartxdate, v_txamt_field);

      if v_txamt = 0 and v_trfcode <> '598.NEWM/AOPN' and
         v_trfcode <> '598.NEWM/ACLS' and
         v_trfcode <> '598.NEWM.ACCT//TBAC' and
         v_trfcode <> '598.005.BALANCE' and
         v_trfcode <> '598.006.BALANCE' and
         v_trfcode <> '598.005.CAINFO' and
         v_trfcode <> '598.006.CAINFO' then
        -- neu so luong bang 0, khong sinh request len VSD
        plog.warn(pkgctx,
                  'txnum:' || v_txnum || '::txdate:' || v_chartxdate ||
                  '::txamt_field:' || v_txamt_field || '::txamt = ' ||
                  v_txamt || ':: not gen msg request to VSD');
        plog.setendsection(pkgctx, 'sp_gen_vsd_req');
        return;
      end if;*/

      if v_afacctno_field <> 'a' then
       v_afacctno := fn_eval_amtexp(v_txnum, v_chartxdate, v_afacctno_field);
       else
        v_afacctno := '';
      end if;


      v_txamt    := fn_eval_amtexp(v_txnum, v_chartxdate, v_txamt_field);
      v_notes    := fn_eval_amtexp(v_txnum, v_chartxdate, v_notes_field);
      if v_fldrefcode_field = 'a' then
        v_refcode := v_chartxdate || v_txnum;
      else
        v_refcode := fn_eval_amtexp(v_txnum,
                                    v_chartxdate,
                                    v_fldrefcode_field);
      end if;

      -- insert vao VSDTXREQ\
      select to_number(to_char(getcurrdate,'RRRRMMDD')||seq_vsdtxreq.nextval) into l_vsdtxreq from dual;
      insert into vsdtxreq
        (reqid,
         objtype,
         objname,
         objkey,
         trfcode,
         refcode,
         txdate,
         affectdate,
         afacctno,
         txamt,
         bankcode,
         bankacct,
         msgstatus,
         notes,
         /*swprocess, boprocess, adtxprocess,*/
         rqtype,
         status,
         msgacct,
         process_id,
         brid,
         tlid,CREATEDATE)
      values
        (l_vsdtxreq,
         'T',
         v_tltxcd,
         v_txnum,
         v_trfcode,
         v_refcode,
         v_dt_txdate,
         v_dt_txdate,
         v_afacctno,
         v_txamt,
         'VSD',
         cspks_system.fn_get_sysvar('SYSTEM', 'COMPANYNAME'),
         'P',
         v_notes,
         /*'P', 'N', 'N',*/
         'A',
         'P',
         v_log_msgacct,
         pv_autoid,
         v_brid,
         v_tlid, sysdate);

      -- insert vao VSDTXREQDTL
      -- Header
      -- Biccode
      insert into vsdtxreqdtl
        (autoid, reqid, fldname, cval, nval)
      values
        (seq_crbtxreqdtl.nextval, l_vsdtxreq, 'BICCODE', l_biccode, 0);
      -- VSD Biccode
      insert into vsdtxreqdtl
        (autoid, reqid, fldname, cval, nval)
      values
        (seq_crbtxreqdtl.nextval, l_vsdtxreq, 'VSDCODE', l_vsdbiccode, 0);

      -- Detail
      plog.error(pkgctx,
                 'detail gen tltxcd:' || v_tltxcd || '::trfcode:' || v_trfcode);
      for rc in (select fldname, fldtype, amtexp, cmdsql, SPLIT
                   from vsdtxmapext mst
                  where mst.objtype = 'T'
                    and mst.objname = v_tltxcd
                    and trfcode = v_trfcode) loop
        begin

          if not rc.amtexp is null then
            v_value := fn_eval_amtexp(v_txnum, v_chartxdate, rc.amtexp);
            plog.error(pkgctx,
                       'txnum:' || v_txnum || '::txdate:' || v_chartxdate ||
                       '::value:' || v_value);
          end if;
          if not rc.cmdsql is null then
            begin
              v_extcmdsql := replace(rc.cmdsql, '<$FILTERID>', v_value);
              begin
                open c0 for v_extcmdsql;
                fetch c0
                  into v_value;
                close c0;

                plog.error(pkgctx,
                           'cmdsql:' || v_extcmdsql || '::value:' ||
                           v_value);

              exception
                when others then
                  v_value := '0';
                  plog.warn(pkgctx,
                            'Khong lay duoc gia tri tren cau lenh select dong : SQL-' ||
                            v_extcmdsql);
              end;
            end;
          end if;

        v_ovalue:=v_value;
       --- split chuoi theo do dai toi da cua dien MT
       -- neu split thi phai convert sang tieng viet kieu telex truoc khi split

       if rc.fldtype = 'C' and rc.fldname <> 'ALTERNATEID' then
          v_value:=fn_convertutf8totelex(v_value);
       end if;
       if rc.split = 'Y' then
          splitstring(v_value,v_value);
       end if;

       if( rc.fldname = 'VSDCODE') then
            update vsdtxreqdtl set cval = v_value,ocval=v_ovalue
            where reqid = l_vsdtxreq and fldname = rc.fldname;
       else

            insert into vsdtxreqdtl
            (autoid, reqid, fldname, cval, nval,OCVAL)
            select seq_crbtxreqdtl.nextval,
                   l_vsdtxreq,
                   rc.fldname,
                   --locpt do hien tai neu la char null thi ham build gia tri tra ve la  0
                   decode(rc.fldtype, 'N', null,case when to_char(v_value)='0' then null else to_char(v_value) end),
                   decode(rc.fldtype, 'N', v_value, 0),
                   decode(rc.fldtype, 'N', null,case when to_char(v_ovalue)='0' then null else to_char(v_ovalue) end)
              from dual;
       end if;
     end;
    end loop;


  end if;
    plog.setendsection(pkgctx, 'sp_gen_vsd_req');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'sp_gen_vsd_req');
  end sp_gen_vsd_req;

  procedure auto_complete_confirm_msg(pv_reqid    number,
                                      pv_cftltxcd varchar2,
                                      pv_vsdtrfid number) as
    l_CUSTODYCD varchar2(50);
    l_REFCUSTODYCD varchar2(50);
    l_count number;
    l_countsymbol number;
    l_countcf number;
    l_CUSTODYCODE VARCHAR2(50);
    l_msgstatus VARCHAR2(50);
    l_refcode VARCHAR2(50);
    l_msgacct VARCHAR2(50);
    l_catype varchar2(10);
  begin
    PLOG.ERROR(pkgctx, 'BEGIN pv_reqid:'||pv_reqid||', pv_vsdtrfid:'||pv_vsdtrfid||', pv_cftltxcd:'||pv_cftltxcd);

    if pv_cftltxcd in ('2248','2266') then
        select msgacct into l_CUSTODYCODE from vsdtxreq where reqid = pv_reqid;
        if pv_cftltxcd = '2248' then
            select count(1) into l_countsymbol
            from V_SE2248
            where custodycd = l_CUSTODYCODE;
        else
            select count(1) into l_countsymbol
            from semast se, cfmast cf, afmast af, SESENDOUT SEO
            where se.afacctno = af.acctno
            and cf.custid = af.custid
            and cf.custodycd = l_CUSTODYCODE
            and SE.acctno = SEO.acctno
            and SEO.STRADE+SEO.SBLOCKED+SEO.SCAQTTY>0
            and SEO.deltd = 'N' and SEO.STATUS = 'S';
        end if;
        select count(1) into l_countcf
        FROM
        (
            select *
            from vsdtrflog
            where referenceid = pv_reqid
            and INSTR(funcname,'ACK') = 0
            and msgtype = '546'
            and reqtty > 0
        );
    end if;
    if pv_cftltxcd = '0012' then
      -- XAC NHAN THANH CONG CUA MO tai khoan
      auto_call_txpks_0012(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '0067' then
      -- XAC NHAN KICH HOAT LAI TAI KHOAN
      auto_call_txpks_0067(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2246' then
      -- XAC NHAN YEU CAU KY GUI CHUNG KHOAN
      auto_call_txpks_2246(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2231' then
      -- TU CHOI YEU CAU KY GUI CHUNG KHOAN
      auto_call_txpks_2231(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2201' then
      -- XAC NHAN THANH CONG RUT CK
      auto_call_txpks_2201(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2294' then
      -- XAC NHAN TU CHOI RUT CK
      auto_call_txpks_2294(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2266' then
      -- XAC NHAN CK RA NGOAI THANH CONG
      select count(1) into l_count from vsdtrflog where autoid = pv_vsdtrfid and funcname like '%TWAC%';
      if l_count > 0 then
        select fldval into l_CUSTODYCD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'CUSTODYCD';
        select fldval into l_REFCUSTODYCD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'REFCUSTODYCD';
        if SUBSTR(l_CUSTODYCD,1,3) <> SUBSTR(l_REFCUSTODYCD,1,3) then
            if l_countcf >= l_countsymbol then
                auto_call_txpks_22662(pv_reqid, pv_vsdtrfid);
            end if;
            update vsdtrflog
            set status = 'C', timeprocess = systimestamp
            where autoid = pv_vsdtrfid;
        end if;
      else
        select count(1) into l_count from vsdtrflog where autoid = pv_vsdtrfid and funcname like '%OWNI%';
        if l_count = 0 then
            auto_call_txpks_2266(pv_reqid, pv_vsdtrfid);
            /*
            select fldval into l_CUSTODYCD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'CUSTODYCD';
            select fldval into l_REFCUSTODYCD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'REFCUSTODYCD';
            if SUBSTR(l_CUSTODYCD,1,3) <> SUBSTR(l_REFCUSTODYCD,1,3) then
                auto_call_txpks_2266(pv_reqid, pv_vsdtrfid);
            end if;*/
        else

            update vsdtxreq
            set msgstatus = 'C' -- boprocess = 'Y'
            where reqid = pv_reqid;

        end if;
        update vsdtrflog
        set status = 'C', timeprocess = systimestamp
        where autoid = pv_vsdtrfid;
      end if;
    elsif pv_cftltxcd = '2265' then
      -- XAC NHAN TU CHOI CK RA NGOAI
      select count(1) into l_count from vsdtrflog where autoid = pv_vsdtrfid and funcname like '%TWAC%';
      if l_count = 0 then
        auto_call_txpks_2265(pv_reqid, pv_vsdtrfid);
      end if;
    --elsif pv_cftltxcd = '8894' then
      -- XAC NHAN CK RA NGOAI THANH CONG
      --auto_call_txpks_8879(pv_reqid, pv_vsdtrfid);
      --auto_call_txpks_8894(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '8816' then
      -- XAC NHAN TU CHOI CK RA NGOAI
      auto_call_txpks_8816(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2236' then
      -- TU CHOI PHONG TOA CHUNG KHOAN
      auto_call_txpks_2236(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2257' then
      -- TU CHOI GIAI TOA CHUNG KHOAN
      auto_call_txpks_2257(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2251' then
      -- CHAP NHAN PHONG TOA CHUNG KHOAN
      auto_call_txpks_2251(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2253' then
      -- CHAP NHAN GIAI TOA CHUNG KHOAN
      auto_call_txpks_2253(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2248' then
      -- XAC NHAN CK DONG TK

      --select fldval into l_CUSTODYCD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'CUSTODYCD';
      --select fldval into l_REFCUSTODYCD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'REFCUSTODYCD';
      SELECT RECCUSTODYCD,REFCUSTODYCD INTO L_CUSTODYCD,L_REFCUSTODYCD FROM VSDTRFLOG WHERE AUTOID = PV_VSDTRFID;
      if SUBSTR(l_CUSTODYCD,1,3) <> SUBSTR(l_REFCUSTODYCD,1,3) then
        if l_countcf >= l_countsymbol  then
            plog.error('Before call 2248. l_custodycd='||l_custodycd||', PV_VSDTRFID='||PV_VSDTRFID||', L_REFCUSTODYCD='||L_REFCUSTODYCD||',l_countcf='||l_countcf||',l_countsymbol='||l_countsymbol||',pv_reqid='||pv_reqid);
            auto_call_txpks_22482(pv_reqid, pv_vsdtrfid);
            auto_call_txpks_0059(pv_reqid,l_CUSTODYCD);
        end if;
      end if;
      update vsdtrflog
      set status = 'C', timeprocess = systimestamp
      where autoid = pv_vsdtrfid;
    elsif pv_cftltxcd = '3358' then
        select msgstatus,refcode into l_msgstatus,l_refcode from vsdtxreq where reqid = pv_reqid;

        if l_msgstatus <> 'N' then

            update catransfer set MSGSTATUS = l_msgstatus where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = l_refcode;

            update vsdtxreq
            set status = 'C' -- boprocess = 'Y'
            where reqid = pv_reqid;

            update vsdtrflog
            set status = 'C', timeprocess = systimestamp
            where autoid = pv_vsdtrfid;

        else
            update catransfer set MSGSTATUS = 'R' where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = l_refcode;
        end if;
    elsif pv_cftltxcd = '3357' then
        select msgstatus,refcode into l_msgstatus,l_refcode from vsdtxreq where reqid = pv_reqid;
        if l_msgstatus <> 'N' then

            update caregister set MSGSTATUS = l_msgstatus where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = l_refcode;

            update vsdtxreq
            set status = 'C' -- boprocess = 'Y'
            where reqid = pv_reqid;

            update vsdtrflog
            set status = 'C', timeprocess = systimestamp
            where autoid = pv_vsdtrfid;

        else
            update caregister set MSGSTATUS = 'R' where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = l_refcode;
        end if;
    elsif pv_cftltxcd = '3335' then
        select msgacct,refcode into l_msgacct,l_refcode from vsdtxreq where reqid = pv_reqid;
        select catype into l_catype from camast where camastid = l_msgacct;

        update vsd_mt564_inf set msgstatus = 'C' where vsdmsgid = l_refcode;

        if l_catype = '014' then
            auto_call_txpks_3370(pv_reqid, pv_vsdtrfid);
        else
            auto_call_txpks_3340(pv_reqid, pv_vsdtrfid);
            /*update vsdtxreq
            set status = 'C', msgstatus = 'C' --boprocess = 'Y'
            where reqid = pv_reqid;
            return;*/
        end if;
    end if;
    plog.setendsection(pkgctx, 'auto_complete_confirm_msg');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_complete_confirm_msg');
  end auto_complete_confirm_msg;

  procedure auto_call_txpks_3370(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_messagetype VARCHAR2(10);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_3370');
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm

        -- nap giao dich de xu ly
        l_tltxcd       := '3370';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := '0000'; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

        for rec in (select ca.DUEDATE,ca.BEGINDATE,ca.CAMASTID,ca.SYMBOL,ca.CATYPE,ca.REPORTDATE,ca.ACTIONDATE,
                    ca.CATYPEVAL,ca.RATE,ca.RIGHTOFFRATE,ca.FRDATETRANSFER,ca.ROPRICE,ca.TVPRICE,ca.CODEID,ca.STATUS,
                    ca.TRADE,ca.TODATETRANSFER,ca.tocodeid
                    from v_camast ca, vsdtxreq req
                    where REPLACE(ca.camastid,'.') = req.msgacct
                    and req.reqid = pv_reqid
                    ) LOOP

            --01    Ng?KT ?KQM/nh?n CP chuy?n ??i   C
                 l_txmsg.txfields ('01').defname   := 'DUEDATE';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.DUEDATE;
            --02    Ng?B? ?KQM/nh?n CP chuy?n ??i   C
                 l_txmsg.txfields ('02').defname   := 'BEGINDATE';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.BEGINDATE;
            --03    M? s? ki?n   C
                 l_txmsg.txfields ('03').defname   := 'CAMASTID';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := REPLACE(rec.CAMASTID,'.');
            --04    M? ch?ng kho?  C
                 l_txmsg.txfields ('04').defname   := 'SYMBOL';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.SYMBOL;
            --05    Lo?i th?c hi?n quy?n   C
                 l_txmsg.txfields ('05').defname   := 'CATYPE';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.CATYPE;
            --06    Ng???ng k? cu?i c?ng   C
                 l_txmsg.txfields ('06').defname   := 'REPORTDATE';
                 l_txmsg.txfields ('06').TYPE      := 'C';
                 l_txmsg.txfields ('06').value      := rec.REPORTDATE;
            --07    Ng?th?c hi?n quy?n DK   C
                 l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.ACTIONDATE;
            --09    Lo?i th?c hi?n quy?n   C
                 l_txmsg.txfields ('09').defname   := 'CATYPEVAL';
                 l_txmsg.txfields ('09').TYPE      := 'C';
                 l_txmsg.txfields ('09').value      := rec.CATYPEVAL;
            --10    T? l?   C
                 l_txmsg.txfields ('10').defname   := 'RATE';
                 l_txmsg.txfields ('10').TYPE      := 'C';
                 l_txmsg.txfields ('10').value      := rec.RATE;
            --11    T? l? quy?n/CP ???c mua   T
                 l_txmsg.txfields ('11').defname   := 'RIGHTOFFRATE';
                 l_txmsg.txfields ('11').TYPE      := 'T';
                 l_txmsg.txfields ('11').value      := rec.RIGHTOFFRATE;
            --12    Ng?b?t ??u chuy?n nh??ng   D
                 l_txmsg.txfields ('12').defname   := 'FRDATETRANSFER';
                 l_txmsg.txfields ('12').TYPE      := 'D';
                 l_txmsg.txfields ('12').value      := rec.FRDATETRANSFER;
            --13    Ng?KT chuy?n nh??ng   D
                 l_txmsg.txfields ('13').defname   := 'TODATETRANSFER';
                 l_txmsg.txfields ('13').TYPE      := 'D';
                 l_txmsg.txfields ('13').value      := rec.TODATETRANSFER;
            --14    Gi?ua   T
                 l_txmsg.txfields ('14').defname   := 'ROPRICE';
                 l_txmsg.txfields ('14').TYPE      := 'T';
                 l_txmsg.txfields ('14').value      := rec.ROPRICE;
            --15    Gi?ui ??i cho c? phi?u l?   T
                 l_txmsg.txfields ('15').defname   := 'TVPRICE';
                 l_txmsg.txfields ('15').TYPE      := 'T';
                 l_txmsg.txfields ('15').value      := rec.TVPRICE;
            --16    M? ch?ng kho?  C
                 l_txmsg.txfields ('16').defname   := 'CODEID';
                 l_txmsg.txfields ('16').TYPE      := 'C';
                 l_txmsg.txfields ('16').value      := rec.CODEID;
            --20    Tr?ng th?  C
                 l_txmsg.txfields ('20').defname   := 'STATUS';
                 l_txmsg.txfields ('20').TYPE      := 'C';
                 l_txmsg.txfields ('20').value      := rec.STATUS;
            --21    S? l??ng CK s? h?u   N
                 l_txmsg.txfields ('21').defname   := 'TRADE';
                 l_txmsg.txfields ('21').TYPE      := 'N';
                 l_txmsg.txfields ('21').value      := rec.TRADE;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --40    M? ch?ng kho?  C
                 l_txmsg.txfields ('40').defname   := 'TOCODEID';
                 l_txmsg.txfields ('40').TYPE      := 'C';
                 l_txmsg.txfields ('40').value      := rec.TOCODEID;

          begin
            if txpks_#3370.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;
    plog.setendsection(pkgctx, 'auto_call_txpks_3370');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_3370');
    end auto_call_txpks_3370;

    procedure auto_call_txpks_3340(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_messagetype VARCHAR2(10);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_3340');
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm

        -- nap giao dich de xu ly
        l_tltxcd       := '3340';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := '0000'; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

        for rec in (SELECT * FROM (SELECT A.CAMASTID,MAX(A.AUTOID) AUTOID, A.DESCRIPTION, B.SYMBOL, A.ACTIONDATE, CD.CDCONTENT CATYPE,
                    MAX(CHD.CODEID) CODEID, SUM(NVL(CHD.QTTY,0)) QTTYDIS
                    FROM CAMAST A, SBSECURITIES B, ALLCODE CD, CASCHD CHD, VSDTXREQ REQ
                    WHERE A.CODEID = B.CODEID AND ((CHD.STATUS IN('V','M') AND A.CATYPE IN ('014','023'))
                    OR(CHD.STATUS IN('A') AND A.CATYPE<>'014' AND A.CATYPE<>'023')) AND A.DELTD='N'
                    AND A.CAMASTID= CHD.CAMASTID AND CHD.DELTD <> 'Y'
                    AND CD.CDNAME ='CATYPE' AND CD.CDTYPE ='CA' AND CD.CDVAL = A.CATYPE
                    AND A.CATYPE NOT IN ('019')
                    AND A.CAMASTID = REQ.MSGACCT
                    AND REQ.REQID = pv_reqid
                    GROUP BY A.CAMASTID, A.DESCRIPTION, B.SYMBOL, A.ACTIONDATE, CD.CDCONTENT) WHERE 0=0
                    ) LOOP

            --03    M? s? ki?n   C
                 l_txmsg.txfields ('03').defname   := 'CAMASTID';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.CAMASTID;
            --04    M? ch?ng kho?  C
                 l_txmsg.txfields ('04').defname   := 'SYMBOL';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.SYMBOL;
            --05    Lo?i th?c hi?n quy?n   C
                 l_txmsg.txfields ('05').defname   := 'CATYPE';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.CATYPE;
            --07    Ng?th?c hi?n quy?n   C
                 l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.ACTIONDATE;
            --13    N?i dung th?c hi?n quy?n   C
                 l_txmsg.txfields ('13').defname   := 'CONTENTS';
                 l_txmsg.txfields ('13').TYPE      := 'C';
                 l_txmsg.txfields ('13').value      := FN_GET_ADVDESC(rec.CAMASTID,'N');
            --21    S? l??ng hi?n th?   N
                 l_txmsg.txfields ('21').defname   := 'TRADE';
                 l_txmsg.txfields ('21').TYPE      := 'N';
                 l_txmsg.txfields ('21').value      := rec.QTTYDIS;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --40    M? ch?ng kho?  C
                 l_txmsg.txfields ('40').defname   := 'CODEID';
                 l_txmsg.txfields ('40').TYPE      := 'C';
                 l_txmsg.txfields ('40').value      := rec.CODEID;

          begin
            if txpks_#3340.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;
    plog.setendsection(pkgctx, 'auto_call_txpks_3340');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_3340');
    end auto_call_txpks_3340;

PROCEDURE pr_receive_csv_by_xml(pv_filename IN VARCHAR2, pv_filecontent IN CLOB)
IS
    v_contentlog_id NUMBER;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_receive_csv_by_xml');
  BEGIN
    SELECT NVL(autoid,-1)
    INTO v_contentlog_id
    FROM vsd_csvcontent_log
    WHERE fileName = pv_filename;
  EXCEPTION WHEN OTHERS THEN
    v_contentlog_id := -1;
  END;
  IF v_contentlog_id >= 0 THEN
    UPDATE vsd_csvcontent_log
    SET msgbody = xmltype(pv_filecontent),
        status='P'
    WHERE autoid = v_contentlog_id;

  ELSE
    select seq_vsd_csvcontent_log.nextval into v_contentlog_id from dual;
    insert into vsd_csvcontent_log (autoid, filename, timecreated, timeprocess, status, msgbody,txdate)
      select v_contentlog_id, pv_filename, systimestamp, null, 'P', xmltype(pv_filecontent), getcurrdate
        from dual;
  END IF;
    pr_xml_2_csvTBL(v_contentlog_id);

    plog.setendsection(pkgctx, 'pr_receive_csv_by_xml');
EXCEPTION WHEN OTHERS THEN
  plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_receive_csv_by_xml');
END;


PROCEDURE pr_receive_par_by_xml(pv_filename IN VARCHAR2, pv_filecontent IN clob)
IS
    v_contentlog_id NUMBER;
    v_vsdid         varchar2(100);
    v_csvfilename   varchar2(500);
    v_creationtime  varchar2(20);
    v_RequestRef    varchar2(100);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_receive_par_by_xml');
  BEGIN
    SELECT NVL(autoid,-1)
    INTO v_contentlog_id
    FROM vsd_parcontent_log
    WHERE fileName = pv_filename;
  EXCEPTION WHEN OTHERS THEN
    v_contentlog_id := -1;
  END;
  IF v_contentlog_id >= 0 THEN
    UPDATE vsd_parcontent_log
    SET msgbody = xmltype(pv_filecontent)
    WHERE autoid = v_contentlog_id;
  ELSE
    select seq_vsd_parcontent_log.nextval into v_contentlog_id from dual;
    insert into vsd_parcontent_log (autoid, filename, timecreated, timeprocess, status, msgbody,txdate)
      select v_contentlog_id, pv_filename, TO_DATE(TO_CHAR(SYSTIMESTAMP,systemnums.C_DATE_FORMAT),systemnums.C_DATE_FORMAT),
             TO_CHAR(systimestamp,systemnums.C_TIME_FORMAT), 'P', xmltype(pv_filecontent), getcurrdate
      from dual;
  END IF;

        SELECT xt.vsdid, xt.csvfilename,creationtime,RequestRef
            INTO v_vsdid, v_csvfilename,v_creationtime,v_RequestRef
        FROM (SELECT * FROM vsd_parcontent_log WHERE autoid = v_contentlog_id) mst,
             xmltable('XMLCreators/par' passing mst.msgbody
                      columns vsdid            varchar2(100)    path 'OrigTransferRef',
                              csvfilename      varchar2(500)    path 'LogicalName',
                              creationtime     varchar2(20)     path 'Creationtime',
                              RequestRef       varchar2(100)    path 'RequestRef') xt
        WHERE 0 = 0;--xt.vsdid is not NULL;

    UPDATE vsd_parcontent_log
    SET vsdid = v_vsdid,
        csvfilename = v_csvfilename,
        txdate = to_date(substr(v_creationtime,1,8),'RRRRMMdd'),
        reqid = v_RequestRef
    WHERE autoid = v_contentlog_id;

    if length(trim(v_vsdid)) > 0 then
        prc_update_vsdid(v_csvfilename, v_vsdid);
    end if;

    plog.setendsection(pkgctx, 'pr_receive_par_by_xml');
EXCEPTION WHEN OTHERS THEN
  plog.error(pkgctx, sqlerrm||DBMS_UTILITY.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_receive_par_by_xml');
END;



PROCEDURE prc_update_vsdid(v_csvfilename IN VARCHAR2, v_vsdid IN varchar2)
IS
    v_symbol            varchar2(20);
    v_reportdate        DATE;
    v_rptid             varchar2(10);
    v_codeid            varchar2(20);
    l_MOD_NUM           number;
    l_currdate          date;
BEGIN
    plog.setbeginsection(pkgctx, 'prc_update_vsdid');
    begin
        v_rptid := substr(v_csvfilename, INSTR(v_csvfilename,'''',1,1)+1,5);
        if v_rptid = 'CA095' then
            v_reportdate := to_date(substr(v_csvfilename,INSTR(v_csvfilename,'+',1,3)+1,8),'DD/MM/RRRR');
        else
            v_reportdate := to_date(substr(v_csvfilename,INSTR(v_csvfilename,'+',1,4)+1,8),'DD/MM/RRRR');
        end if;
        v_symbol := substr(substr(v_csvfilename, instr(v_csvfilename,'-')+4),1, instr(substr(v_csvfilename, instr(v_csvfilename,'-')+4), '-')-1);
        SELECT codeid INTO v_codeid FROM sbsecurities WHERE symbol = v_symbol;
    EXCEPTION WHEN OTHERS THEN
        v_rptid := '';
        v_reportdate := '';
        v_symbol := '';
        v_codeid := '';
    end;
    for rec in(
        select * from camast
        where reportdate = v_reportdate
            AND codeid = v_codeid
            AND INSTR((CASE WHEN v_rptid = 'CA001' THEN '005'
                                 WHEN v_rptid = 'CA005' THEN '014'
                                 WHEN v_rptid = 'CA009' THEN '010'
                                 WHEN v_rptid = 'CA012' THEN '021'
                                 WHEN v_rptid = 'CA014' THEN '011'
                                 WHEN v_rptid = 'CA095' THEN '028' --Bo sung them doi chieu chung quyen
                                 WHEN v_rptid = 'CA029' THEN '/016/015/'
                             ELSE '' END),catype)>0
    )
    loop
        select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || REC.CAMASTID || '''';
        L_MOD_NUM := L_MOD_NUM+1;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                 COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
             SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,'0000' APPROVE_ID,
                 l_currdate APPROVE_DT, L_MOD_NUM MOD_NUM,'VSDID' COLUMN_NAME , rec.VSDID FROM_VALUE, v_vsdid TO_VALUE,'EDIT' ACTION_FLAG,
                 NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME, to_char(sysdate,'hh24:mm:ss') APPROVE_TIME
             FROM DUAL;

        UPDATE camast SET vsdid = v_vsdid WHERE camastid = rec.CAMASTID;

        update vsd_mt564_inf SET vsdreference = v_vsdid where vsdreference = rec.vsdid;

    end loop;
    plog.setendsection(pkgctx, 'prc_update_vsdid');
EXCEPTION WHEN OTHERS THEN
  plog.error(pkgctx, sqlerrm||DBMS_UTILITY.format_error_backtrace);
  plog.setendsection(pkgctx, 'prc_update_vsdid');
END;

PROCEDURE pr_xml_2_csvTBL(pv_autoid NUMBER)
IS
l_funcName  VARCHAR2(30);
l_filename  varchar2(500);
v_insert_sql varchar2(32000);
v_select_sql varchar2(32000);
v_table_name varchar2(10);
v_fieldcheck varchar2(100);
BEGIN
  plog.setbeginsection(pkgctx, 'pr_xml_2_csvTBL');

  BEGIN
    SELECT csv.funcname,csv.filename, f.filecode
    INTO l_funcName,l_filename,v_table_name
    FROM vsd_csvcontent_log csv, filemaster f
    WHERE f.eori ='C' and csv.autoid = pv_autoid and instr(csv.filename,f.filecode)>0;
  EXCEPTION WHEN OTHERS THEN
    l_funcName := null;
    l_filename := null;
    v_table_name:=null;
  END;

 if(v_table_name is not null)  then


        v_insert_sql :='BEGIN INSERT INTO '  || v_table_name || '(autoid, ';

        v_select_sql := 'SELECT xt.* FROM '
                  ||     ' (   select mst.autoid,xt.*   from (select * from vsd_csvcontent_log  where status =''P'' and autoid = ' ||pv_autoid || ') mst,'
                  ||     ' xmltable(''XMLCreators/row'' passing mst.msgbody'
                  ||     '        columns  ';
        for rec in (  SELECT * FROM filemap WHERE filecode = v_table_name order by lstodr
                   ) loop
                        if  v_fieldcheck is null then
                         v_fieldcheck:=rec.tblrowname;
                        end if;
                        v_insert_sql:=v_insert_sql || rec.tblrowname || ',';
                        v_select_sql:=v_select_sql|| rec.tblrowname || '  varchar2(1000) path ''' ||rec.filerowname|| ''',';
            end loop;
            --remove dau , o cuoi
            v_insert_sql:=substr(v_insert_sql,0,length(v_insert_sql)-1)||') ';
            v_select_sql:=substr(v_select_sql,0,length(v_select_sql)-1);

            v_select_sql:=v_insert_sql || v_select_sql || '    ) xt       ) xt       WHERE  ' || v_fieldcheck || ' is not null; update  vsd_csvcontent_log set status =''C'' where autoid = '|| pv_autoid ||  '; END;';

        --plog.error(pkgctx, 'pr_xml_2_csvTBL=' || v_select_sql);
        begin
            execute immediate v_select_sql;
        EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, 'l_funcName=' || l_funcName || 'v_table_name=' || v_table_name ||' doesn''t support');
        END;
  else
    plog.error(pkgctx, 'l_funcName=' || l_funcName || 'v_table_name=' || v_table_name ||' doesn''t support');
  end if;



 /* CASE
    WHEN l_funcName = '598.621.POSITION' THEN
      DELETE csv_position WHERE 1 = 1;
      INSERT INTO csv_POSITION(Id, Account, Code, Deliver, Receive, Net, Wasp, Wapb, Im, Vm, Due)
      SELECT xt.* FROM
      (
        select xt.*
        from (select * from vsd_csvcontent_log where autoid = pv_autoid) mst,
             xmltable('XMLCreators/row' passing mst.msgbody
                      columns id NUMBER path 'id',
                              account varchar2(10) path 'account',
                              symbol varchar2(30) path 'code',
                              deliver NUMBER path 'deliver',
                              receive NUMBER path 'receive',
                              net NUMBER path 'net',
                              wasp NUMBER path 'wasp',
                              wapb NUMBER path 'wapb',
                              IM NUMBER path 'IM',
                              VM NUMBER path 'VM',
                              due varchar2(30) path 'due') xt
      ) xt
      WHERE xt.account is not null;

    ELSE*/

  -- END CASE;
  plog.setendsection(pkgctx, 'pr_xml_2_csvTBL');
EXCEPTION WHEN OTHERS THEN
  plog.error(pkgctx, sqlerrm);
  plog.setendsection(pkgctx, 'pr_xml_2_csvTBL');
END pr_xml_2_csvTBL;

PROCEDURE splitstring(pv_string in varchar2,pv_outstring out varchar2)
IS
   l_in_string varchar2(2000);
   l_out_string varchar2(2000);
begin
  l_in_string:=pv_string;
   while length(l_in_string) > errnums.C_MAX_CHAR_PER_ROW loop
      l_out_string := l_out_string || substr(l_in_string, 1, errnums.C_MAX_CHAR_PER_ROW) || CHR(10);
      l_in_string := substr(l_in_string, errnums.C_MAX_CHAR_PER_ROW+1);
   end loop;
   l_out_string := l_out_string || l_in_string;
   pv_outstring:=l_out_string;

EXCEPTION WHEN OTHERS THEN
  plog.error(pkgctx, sqlerrm);
  plog.setendsection(pkgctx, 'splitstring');
END splitstring;

procedure auto_call_txpks_0012(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);

  begin
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C', 'W','A')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '0012';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := getcurrdate;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (SELECT CF.CUSTID, CF.FULLNAME CUSTNAME, CF.CUSTODYCD, CF.IDCODE, CF.ADDRESS, CF.OPNDATE
                    FROM CFMAST CF, VSDTXREQ REQ
                    WHERE CF.ACTIVESTS = 'N' AND CF.ISBANKING = 'N'
                    AND(CF.NSDSTATUS = 'A' OR (CF.NSDSTATUS <>'C' AND INSTR(CF.PSTATUS,'A') <> 0))
                    AND CF.CUSTODYCD IS NOT NULL
                    AND SUBSTR(CF.CUSTODYCD,1,3) IN (SELECT VARVALUE FROM SYSVAR WHERE VARNAME = 'COMPANYCD' AND GRNAME = 'SYSTEM')
                    AND REQ.OBJNAME = '0035' AND REQ.MSGACCT = CF.CUSTODYCD
                    AND REQ.REQID = PV_REQID) loop
        --03    M? kh? h?   C
             l_txmsg.txfields ('03').defname   := 'CUSTID';
             l_txmsg.txfields ('03').TYPE      := 'C';
             l_txmsg.txfields ('03').value      := rec.CUSTID;
        --04    S? TK l?u k?   C
             l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
             l_txmsg.txfields ('04').TYPE      := 'C';
             l_txmsg.txfields ('04').value      := rec.CUSTODYCD;
        --05    H? t?  C
             l_txmsg.txfields ('05').defname   := 'CUSTNAME';
             l_txmsg.txfields ('05').TYPE      := 'C';
             l_txmsg.txfields ('05').value      := rec.CUSTNAME;
        --06    CMND/GPKD   C
             l_txmsg.txfields ('06').defname   := 'IDCODE';
             l_txmsg.txfields ('06').TYPE      := 'C';
             l_txmsg.txfields ('06').value      := rec.IDCODE;
        --07    ??a ch?   C
             l_txmsg.txfields ('07').defname   := 'ADDRESS';
             l_txmsg.txfields ('07').TYPE      := 'C';
             l_txmsg.txfields ('07').value      := rec.ADDRESS;
        --30    Di?n gi?i   C
             l_txmsg.txfields ('30').defname   := 'DESC';
             l_txmsg.txfields ('30').TYPE      := 'C';
             l_txmsg.txfields ('30').value      := l_strdesc;

        begin

          if txpks_#0012.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'C' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_0012',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_0012;

procedure auto_call_txpks_0067(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);

  begin
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C', 'W','A')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '0067';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := getcurrdate;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (SELECT MST.CUSTID, MST.CUSTODYCD, MST.ACTYPE
                    FROM CFMAST MST, VSDTXREQ REQ
                    WHERE REQ.MSGACCT = MST.CUSTODYCD
                    AND MST.STATUS = 'C' AND MST.ACTIVESTS = 'N'
                    AND MST.CUSTODYCD IS NOT NULL
                    AND REQ.REQID = PV_REQID) loop
            --05    S? ti?u kho?n   C
                 l_txmsg.txfields ('05').defname   := 'ACCTNO';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := '';
            --46    Lo?i h?nh kh? h? m?i   C
                 l_txmsg.txfields ('46').defname   := 'NACTYPE';
                 l_txmsg.txfields ('46').TYPE      := 'C';
                 l_txmsg.txfields ('46').value      := '<NULL>';
            --45    Lo?i h?nh kh? h? hi?n t?i   C
                 l_txmsg.txfields ('45').defname   := 'ACTYPE';
                 l_txmsg.txfields ('45').TYPE      := 'C';
                 l_txmsg.txfields ('45').value      := rec.ACTYPE;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --08    C?ch ho?t VSD kh?  C
                 l_txmsg.txfields ('08').defname   := 'ACTIVESTS';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := 'Y';
            --03    M? kh? h?   C
                 l_txmsg.txfields ('03').defname   := 'CUSTID';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.CUSTID;
            --88    S? TK l?u k?   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;

        begin

          if txpks_#0067.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'C' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;


      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_0067',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_0067;

procedure auto_call_txpks_2246(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;
  begin
    --Lay thong tin dien confirm
    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C', 'W','A')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '2246';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (SELECT DISTINCT SEDEPOSIT.AUTOID AUTOID,CF.CUSTODYCD, SE.AFACCTNO, SYM.SYMBOL, SE.CODEID, SE.ACCTNO,CF.FULLNAME CUSTNAME, CF.ADDRESS, CF.IDCODE, SYM.PARVALUE, SEDEPOSIT.DEPOSITPRICE DEPOSITPRICE,
                                SEDEPOSIT.DEPOSITQTTY QTTY, SEDEPOSIT.DEPOBLOCK,SEDEPOSIT.VSDCODE, SEDEPOSIT.RDATE, SEDEPOSIT.Senddepodate PDATE, CI.DEPOLASTDT,
                                SEDEPOSIT.TYPEDEPOBLOCK QTTYTYPE, SEDEPOSIT.WTRADE WTRADE, (SEDEPOSIT.DEPOSITQTTY + SEDEPOSIT.DEPOBLOCK) SQTTY, SEDEPOSIT.DEPOTRADE,
                                SEDEPOSIT.DESCRIPTION DESCRIPTION
                      FROM SEMAST SE, CFMAST CF, SBSECURITIES SYM,CIMAST CI,
                           (
                               SELECT *
                               FROM SEDEPOSIT
                               WHERE STATUS = 'S'
                               AND DELTD <> 'Y'
                           ) SEDEPOSIT, VSDTXREQ REQ
                      WHERE SE.SENDDEPOSIT > 0
                       AND SE.CUSTID = CF.CUSTID
                       AND SYM.CODEID = SE.CODEID
                       AND SEDEPOSIT.ACCTNO = SE.ACCTNO
                       AND SE.AFACCTNO=CI.ACCTNO
                       --AND SE.ACCTNO = REQ.MSGACCT
                       AND to_char(SEDEPOSIT.AUTOID) = REQ.REFCODE
                       AND REQ.REQID = PV_REQID) loop
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --15    Ph?K ??n h?n   N
                 l_txmsg.txfields ('15').defname   := 'CIDFPOFEEACR';
                 l_txmsg.txfields ('15').TYPE      := 'N';
                 l_txmsg.txfields ('15').value      := FN_CIGETDEPOFEEAMT(rec.AFACCTNO,rec.CODEID,getcurrdate,getcurrdate,rec.SQTTY);
            --12    T?ng s? l??ng   N
                 l_txmsg.txfields ('12').defname   := 'SQTTY';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.SQTTY;
            --05    S? t? t?ng   N
                 l_txmsg.txfields ('05').defname   := 'AUTOID';
                 l_txmsg.txfields ('05').TYPE      := 'N';
                 l_txmsg.txfields ('05').value      := rec.AUTOID;
            --14    Ch? giao d?ch   N
                 l_txmsg.txfields ('14').defname   := 'WTRADE';
                 l_txmsg.txfields ('14').TYPE      := 'N';
                 l_txmsg.txfields ('14').value      := rec.WTRADE;
            --09    Gi??u k?   N
                 l_txmsg.txfields ('09').defname   := 'PRICE';
                 l_txmsg.txfields ('09').TYPE      := 'N';
                 l_txmsg.txfields ('09').value      := rec.DEPOSITPRICE;
            --10    S? l??ng   N
                 l_txmsg.txfields ('10').defname   := 'QTTY';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --91    ??a ch?   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --08    Lo?i ?i?u ki?n   C
                 l_txmsg.txfields ('08').defname   := 'QTTYTYPE';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := rec.QTTYTYPE;
            --32    Ng?chuy?n ph?K ??n h?n g?n nh?t   C
                 l_txmsg.txfields ('32').defname   := 'DEPOLASTDT';
                 l_txmsg.txfields ('32').TYPE      := 'C';
                 l_txmsg.txfields ('32').value      := rec.DEPOLASTDT;
            --04    S? CK h?n ch? CN   N
                 l_txmsg.txfields ('04').defname   := 'DEPOBLOCK';
                 l_txmsg.txfields ('04').TYPE      := 'N';
                 l_txmsg.txfields ('04').value      := rec.DEPOBLOCK;
            --03    S? ti?u kho?n CK   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.IDCODE;
            --02    S? ti?u kho?n   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --88    S? TK l?u k?   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --13    Ng?giao d?ch tr? l?i   D
                 l_txmsg.txfields ('13').defname   := 'RDATE';
                 l_txmsg.txfields ('13').TYPE      := 'D';
                 l_txmsg.txfields ('13').value      := rec.RDATE;
            --22    M? VSD   C
                 l_txmsg.txfields ('22').defname   := 'VSDCODE';
                 l_txmsg.txfields ('22').TYPE      := 'C';
                 l_txmsg.txfields ('22').value      := rec.VSDCODE;
            --33    Ph?K c?ng d?n   N
                 l_txmsg.txfields ('33').defname   := 'CIDFPOFEEACR';
                 l_txmsg.txfields ('33').TYPE      := 'N';
                 l_txmsg.txfields ('33').value      := FN_CIGETDEPOFEEACR(rec.AFACCTNO,rec.CODEID,getcurrdate,getcurrdate,rec.SQTTY);
            --07    Ng?chuy?n   C
                 l_txmsg.txfields ('07').defname   := 'PDATE';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.PDATE;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --06    S? CK t? do CN   N
                 l_txmsg.txfields ('06').defname   := 'DEPOTRADE';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.DEPOTRADE;
            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --11    M?nh gi? N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;

        begin

          if txpks_#2246.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'C' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2246',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2246;

procedure auto_call_txpks_2231(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;

  begin

    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C','N','R')
                    and req.reqid = pv_reqid) loop
      -- nap giao dich de xu ly
      l_tltxcd       := '2231';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (SELECT DISTINCT SEDEPOSIT.AUTOID AUTOID,CF.CUSTODYCD, SE.AFACCTNO, SYM.SYMBOL, SE.CODEID, SE.ACCTNO,CF.FULLNAME CUSTNAME, CF.ADDRESS, CF.IDCODE, SYM.PARVALUE, SEDEPOSIT.DEPOSITPRICE DEPOSITPRICE,
                                  SEDEPOSIT.DEPOSITQTTY QTTY, SEDEPOSIT.DEPOBLOCK,SEDEPOSIT.VSDCODE, SEDEPOSIT.RDATE, SEDEPOSIT.SENDDEPODATE PDATE,
                                  SEDEPOSIT.TYPEDEPOBLOCK QTTYTYPE, SEDEPOSIT.WTRADE WTRADE, (SEDEPOSIT.DEPOSITQTTY + SEDEPOSIT.DEPOBLOCK) SQTTY, SEDEPOSIT.DEPOTRADE,
                                  SEDEPOSIT.DESCRIPTION DESCRIPTION
                  FROM SEMAST SE,CFMAST CF,SBSECURITIES SYM,
                  (SELECT * FROM SEDEPOSIT WHERE STATUS='S' AND DELTD <> 'Y') SEDEPOSIT, VSDTXREQ REQ
                  WHERE SE.SENDDEPOSIT>0
                  AND SE.CUSTID=CF.CUSTID
                  AND SYM.CODEID = SE.CODEID
                  AND SEDEPOSIT.ACCTNO=SE.ACCTNO
                  AND to_char(SEDEPOSIT.AUTOID) = REQ.refcode
                  AND REQ.REQID = pv_reqid) loop
            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    S? Ti?u kho?n   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    S? t?kho?n   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    S? CK HCCN   N
                 l_txmsg.txfields ('04').defname   := 'DEPOBLOCK';
                 l_txmsg.txfields ('04').TYPE      := 'N';
                 l_txmsg.txfields ('04').value      := rec.DEPOBLOCK;
            --05    S? t? t?ng   N
                 l_txmsg.txfields ('05').defname   := 'AUTOID';
                 l_txmsg.txfields ('05').TYPE      := 'N';
                 l_txmsg.txfields ('05').value      := rec.AUTOID;
            --06    S? CK TDCN   N
                 l_txmsg.txfields ('06').defname   := 'DEPOTRADE';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.DEPOTRADE;
            --07    Posted date   C
                 l_txmsg.txfields ('07').defname   := 'PDATE';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.PDATE;
            --08    Lo?i ?i?u ki?n   C
                 l_txmsg.txfields ('08').defname   := 'QTTYTYPE';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := rec.QTTYTYPE;
            --09    Gi??n   N
                 l_txmsg.txfields ('09').defname   := 'PRICE';
                 l_txmsg.txfields ('09').TYPE      := 'N';
                 l_txmsg.txfields ('09').value      := rec.DEPOSITPRICE;
            --10    S? l??ng   N
                 l_txmsg.txfields ('10').defname   := 'QTTY';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    M?nh gi? N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --91    ??a ch?   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.IDCODE;

        begin

          if txpks_#2231.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;

      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'R' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2231',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2231;

  procedure auto_call_txpks_2201(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin

      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W', 'A')
                      --and req.status <> 'C'
                      --and req.boprocess = 'N'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2201';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT SEMAST.ACCTNO, SYM.SYMBOL, SEMAST.AFACCTNO,SEWD.WITHDRAW  WITHDRAW,SEWD.BLOCKWITHDRAW ,SEMAST.CODEID,SYM.PARVALUE,SEWD.PRICE PRICE,
                    CF.FULLNAME, CF.IDCODE LICENSE, CF.IDDATE,CF.IDPLACE,CF.ADDRESS ,SEMAST.LASTDATE SELASTDATE,
                    AF.LASTDATE AFLASTDATE, CONFIRMTXDATE LASTDATE,CF.CUSTODYCD,SEWD.TXDATETXNUM, SEWD.TXDATE, SEWD.TXNUM,
                    SEWD.WITHDRAW+SEWD.BLOCKWITHDRAW SUMQTTY, ISSU.FULLNAME ISSFULLNAME,  TLP.TLFULLNAME, BR.BRID BRNAME
                    FROM SEMAST,SBSECURITIES SYM,AFMAST AF,CFMAST CF, SECURITIES_INFO SEINFO, SEWITHDRAWDTL SEWD,
                        ISSUERS ISSU, TLPROFILES TLP, BRGRP BR, VSDTXREQ RQ
                    WHERE SYM.CODEID=SEINFO.CODEID
                    AND BR.BRID = rec0.brid AND TLP.TLID = rec0.tlid
                    AND CF.CUSTID =AF.CUSTID AND SYM.ISSUERID = ISSU.ISSUERID(+)
                    AND SYM.CODEID = SEMAST.CODEID
                    AND SEMAST.AFACCTNO= AF.ACCTNO
                    AND SEMAST.WITHDRAW +SEMAST.BLOCKWITHDRAW>0
                    AND SEMAST.ACCTNO = SEWD.ACCTNO
                    AND SEWD.STATUS = 'A'
                    AND RQ.OBJKEY = SEWD.CONFIRMTXNUM
                    AND RQ.TXDATE = SEWD.CONFIRMTXDATE
                    AND RQ.REQID = PV_REQID
                    AND NOT EXISTS (
                            SELECT FLD.CVALUE  FROM TLLOG4DR TL, TLLOGFLD4DR FLD
                            WHERE TL.TLTXCD ='2201'
                            AND TL.TXNUM = FLD.TXNUM AND TL.TXDATE = FLD.TXDATE AND FLD.FLDCD ='07'
                            AND TL.DELTD <> 'Y' AND TL.TXSTATUS ='4'
                            AND FLD.CVALUE = TO_CHAR(SEWD.TXDATE,'DD/MM/RRRR') || SEWD.TXNUM
                            AND NOT  EXISTS (SELECT 1 FROM TLLOG T WHERE T.TXNUM = TL.TXNUM AND T.DELTD='Y' AND TXSTATUS ='1')
                         )) loop

                --01    M? ch?ng kho?  C
                     l_txmsg.txfields ('01').defname   := 'CODEID';
                     l_txmsg.txfields ('01').TYPE      := 'C';
                     l_txmsg.txfields ('01').value      := rec.CODEID;
                --02    S? Ti?u kho?n   C
                     l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                     l_txmsg.txfields ('02').TYPE      := 'C';
                     l_txmsg.txfields ('02').value      := rec.AFACCTNO;
                --03    S? ti?u kho?n ch?ng kho?  C
                     l_txmsg.txfields ('03').defname   := 'ACCTNO';
                     l_txmsg.txfields ('03').TYPE      := 'C';
                     l_txmsg.txfields ('03').value      := rec.ACCTNO;
                --05    Ng?TH GD xin r?t   D
                     l_txmsg.txfields ('05').defname   := 'TXDATE';
                     l_txmsg.txfields ('05').TYPE      := 'D';
                     l_txmsg.txfields ('05').value      := rec.TXDATE;
                --06    S? CT c?a GD xin r?t   C
                     l_txmsg.txfields ('06').defname   := 'TXNUM';
                     l_txmsg.txfields ('06').TYPE      := 'C';
                     l_txmsg.txfields ('06').value      := rec.TXNUM;
                --07    Key   C
                     l_txmsg.txfields ('07').defname   := 'TXDATETXNUM';
                     l_txmsg.txfields ('07').TYPE      := 'C';
                     l_txmsg.txfields ('07').value      := rec.TXDATETXNUM;
                --09    Gi? N
                     l_txmsg.txfields ('09').defname   := 'PRICE';
                     l_txmsg.txfields ('09').TYPE      := 'N';
                     l_txmsg.txfields ('09').value      := rec.PRICE;
                --10    S? l??ng   N
                     l_txmsg.txfields ('10').defname   := 'AMT';
                     l_txmsg.txfields ('10').TYPE      := 'N';
                     l_txmsg.txfields ('10').value      := rec.withdraw;
                --11    M?nh gi? N
                     l_txmsg.txfields ('11').defname   := 'PARVALUE';
                     l_txmsg.txfields ('11').TYPE      := 'N';
                     l_txmsg.txfields ('11').value      := rec.PARVALUE;
                --14    S? l??ng r?t HCCN    N
                     l_txmsg.txfields ('14').defname   := 'BLOCKWITHDRAW';
                     l_txmsg.txfields ('14').TYPE      := 'N';
                     l_txmsg.txfields ('14').value      := rec.BLOCKWITHDRAW;
                --29    S? s? c? ??  C
                     l_txmsg.txfields ('29').defname   := 'SSCD';
                     l_txmsg.txfields ('29').TYPE      := 'C';
                     l_txmsg.txfields ('29').value      := '';
                --30    Di?n gi?i   C
                     l_txmsg.txfields ('30').defname   := 'DESC';
                     l_txmsg.txfields ('30').TYPE      := 'C';
                     l_txmsg.txfields ('30').value      := l_strdesc;
                --35    T?ng??i ??t l?nh   C
                     l_txmsg.txfields ('35').defname   := 'TLFULLNAME';
                     l_txmsg.txfields ('35').TYPE      := 'C';
                     l_txmsg.txfields ('35').value      := rec.TLFULLNAME;
                --36    Chi nh?   C
                     l_txmsg.txfields ('36').defname   := 'BRNAME';
                     l_txmsg.txfields ('36').TYPE      := 'C';
                     l_txmsg.txfields ('36').value      := rec.BRNAME;
                --37    T?c?ty   C
                     l_txmsg.txfields ('37').defname   := 'ISSUERSNAME';
                     l_txmsg.txfields ('37').TYPE      := 'C';
                     l_txmsg.txfields ('37').value      := rec.ISSFULLNAME;
                --55    T?ng KL ch?ng kho?xin r?t   N
                     l_txmsg.txfields ('55').defname   := 'SUMQTTY';
                     l_txmsg.txfields ('55').TYPE      := 'N';
                     l_txmsg.txfields ('55').value      := rec.SUMQTTY;
                --90    H? t?  C
                     l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                     l_txmsg.txfields ('90').TYPE      := 'C';
                     l_txmsg.txfields ('90').value      := rec.FULLNAME;
                --91    ??a ch?   C
                     l_txmsg.txfields ('91').defname   := 'ADDRESS';
                     l_txmsg.txfields ('91').TYPE      := 'C';
                     l_txmsg.txfields ('91').value      := rec.ADDRESS;
                --92    CMND/GPKD   C
                     l_txmsg.txfields ('92').defname   := 'LICENSE';
                     l_txmsg.txfields ('92').TYPE      := 'C';
                     l_txmsg.txfields ('92').value      := rec.LICENSE;
                --95    Ng?c?p   D
                     l_txmsg.txfields ('95').defname   := 'LICENSEDATE';
                     l_txmsg.txfields ('95').TYPE      := 'D';
                     l_txmsg.txfields ('95').value      := rec.IDDATE;
                --96    N?i c?p   C
                     l_txmsg.txfields ('96').defname   := 'LICENSEPLACE';
                     l_txmsg.txfields ('96').TYPE      := 'C';
                     l_txmsg.txfields ('96').value      := rec.IDPLACE;
          begin
            if txpks_#2201.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2201', l_sqlerrnum);
    end auto_call_txpks_2201;

    procedure auto_call_txpks_2294(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    varchar2(20);
      l_err_param   varchar2(20);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2294');

      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('N', 'R', 'W')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2294';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT SEMAST.ACCTNO, SYM.SYMBOL, SEMAST.AFACCTNO,SEWD.WITHDRAW  WITHDRAW,SEWD.BLOCKWITHDRAW,SEMAST.CODEID,SYM.PARVALUE,SEINFO.BASICPRICE  PRICE,
                        CF.IDCODE LICENSE, CF.IDPLACE LICENSEPLACE,IDDATE LICENSEDATE,CF.ADDRESS,SEMAST.LASTDATE SELASTDATE,AF.LASTDATE AFLASTDATE,NVL(SEMAST.LASTDATE,AF.LASTDATE) LASTDATE,
                        CF.CUSTODYCD,CF.FULLNAME CUSTNAME, SEWD.TXDATE, SEWD.TXNUM, SEWD.TXDATETXNUM,SEWD.WITHDRAW+SEWD.BLOCKWITHDRAW SUMQTTY
                    FROM SEMAST,SBSECURITIES SYM,AFMAST AF,CFMAST CF
                        ,SECURITIES_INFO SEINFO, SEWITHDRAWDTL SEWD, VSDTXREQ RQ
                    WHERE SYM.CODEID=SEINFO.CODEID
                    AND CF.CUSTID =AF.CUSTID
                    AND SYM.CODEID = SEMAST.CODEID
                    AND SEMAST.AFACCTNO= AF.ACCTNO
                    AND SEWD.WITHDRAW + SEWD.BLOCKWITHDRAW>0
                    AND SEMAST.ACCTNO = SEWD.ACCTNO
                    AND SEWD.STATUS = 'A'
                    AND RQ.OBJKEY = SEWD.CONFIRMTXNUM
                    AND RQ.TXDATE = SEWD.CONFIRMTXDATE
                    AND RQ.REQID = PV_REQID) loop
            --02    S? Ti?u kho?n   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    T?kho?n ch?ng kho?  C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    M? ch?ng kho?  C
                 l_txmsg.txfields ('04').defname   := 'SYMBOL';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.CODEID;
            --05    Ng?TH GD xin r?t   D
                 l_txmsg.txfields ('05').defname   := 'TXDATE';
                 l_txmsg.txfields ('05').TYPE      := 'D';
                 l_txmsg.txfields ('05').value      := rec.TXDATE;
            --06    S? CT c?a GD xin r?t   C
                 l_txmsg.txfields ('06').defname   := 'TXNUM';
                 l_txmsg.txfields ('06').TYPE      := 'C';
                 l_txmsg.txfields ('06').value      := rec.TXNUM;
            --07    Key   C
                 l_txmsg.txfields ('07').defname   := 'TXDATETXNUM';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.TXDATETXNUM;
            --10    KL ch?ng kho?xin r?t   N
                 l_txmsg.txfields ('10').defname   := 'AMT';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.WITHDRAW;
            --14    KL ch?ng kho?hccn xin r?t   N
                 l_txmsg.txfields ('14').defname   := 'BLOCKWITHDRAW';
                 l_txmsg.txfields ('14').TYPE      := 'N';
                 l_txmsg.txfields ('14').value      := rec.BLOCKWITHDRAW;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --55    T?ng KL ch?ng kho?xin r?t   N
                 l_txmsg.txfields ('55').defname   := 'SUMQTTY';
                 l_txmsg.txfields ('55').TYPE      := 'N';
                 l_txmsg.txfields ('55').value      := rec.SUMQTTY;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;
            --95    Ng?c?p   D
                 l_txmsg.txfields ('95').defname   := 'LICENSEDATE';
                 l_txmsg.txfields ('95').TYPE      := 'D';
                 l_txmsg.txfields ('95').value      := rec.LICENSEDATE;
            --97    ?a ch?   C
                 l_txmsg.txfields ('97').defname   := 'ADDRESS';
                 l_txmsg.txfields ('97').TYPE      := 'C';
                 l_txmsg.txfields ('97').value      := rec.ADDRESS;

          begin
            if txpks_#2294.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'R' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid; -- l_txmsg.txfields('09').value;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2294');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_2294');
    end auto_call_txpks_2294;

    procedure auto_call_txpks_2266(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_messagetype VARCHAR2(10);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2266');
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      plog.error(pkgctx, 'auto_call_txpks_2266');
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W','A')
                        --and req.status <> 'C'
                        --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2266';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

        for rec in (SELECT SEO.*, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,SEC.SYMBOL, SE.COSTPRICE, AL.CDCONTENT PRODUCTTYPE,AL1.CDCONTENT PRODUCTTYPECR
                    FROM SESENDOUT SEO, CFMAST CF, AFMAST AF, SBSECURITIES SEC,SEMAST SE,ALLCODE AL,ALLCODE AL1,
                         AFTYPE AFT, AFMAST AF1, VSDTXREQ REQ
                    WHERE SUBSTR(SEO.ACCTNO,0,10)=AF.ACCTNO
                    AND AF.CUSTID=CF.CUSTID
                    AND SEC.CODEID=SEO.CODEID
                    AND SE.ACCTNO=SEO.ACCTNO
                    AND AF.ACTYPE =AFT.ACTYPE
                    AND SEO.REAFACCTNO = AF1.ACCTNO (+)
                    AND SEO.STRADE+SEO.SBLOCKED+SEO.SCAQTTY>0
                    AND DELTD='N'
                    AND AL.CDNAME='PRODUCTTYPE'
                    AND AFT.PRODUCTTYPE = AL.CDVAL(+)
                    AND NVL( AL1.CDNAME,'PRODUCTTYPE')='PRODUCTTYPE'
                    AND AF1.PRODUCTTYPE = AL1.CDVAL (+)
                    AND to_char(SEO.AUTOID) = REQ.REFCODE
                    and REQ.REQID = pv_reqid
                    ) LOOP

            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    S? TK ghi N?   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    S? TK CK ghi N?   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --05    S? LK   C
                 l_txmsg.txfields ('05').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.CUSTODYCD;
            --06    S? l??ng CK phong t?a   N
                 l_txmsg.txfields ('06').defname   := 'BLOCKED';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.SBLOCKED;
            --07    Ch?ng kho?  C
                 l_txmsg.txfields ('07').defname   := 'SYMBOL';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.SYMBOL;
            --08    Lo?i ti?u kho?n   C
                 l_txmsg.txfields ('08').defname   := 'PRODUCTTYPE';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := rec.PRODUCTTYPE;
            --09    Gi? N
                 l_txmsg.txfields ('09').defname   := 'PRICE';
                 l_txmsg.txfields ('09').TYPE      := 'N';
                 l_txmsg.txfields ('09').value      := rec.COSTPRICE;
            --10    S? l??ng giao d?ch   N
                 l_txmsg.txfields ('10').defname   := 'TRADE';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.STRADE;
            --12    T?ng s? l??ng   N
                 l_txmsg.txfields ('12').defname   := 'QTTY';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.SBLOCKED + rec.STRADE;
            --13    S? l??ng CK CA   N
                 l_txmsg.txfields ('13').defname   := 'CAQTTY';
                 l_txmsg.txfields ('13').TYPE      := 'N';
                 l_txmsg.txfields ('13').value      := rec.CAQTTY;
            --14    Lo?i ? ki?n   C
                 l_txmsg.txfields ('14').defname   := 'QTTYTYPE';
                 l_txmsg.txfields ('14').TYPE      := 'C';
                 l_txmsg.txfields ('14').value      := rec.QTTYTYPE;
            --18    AUTOID   N
                 l_txmsg.txfields ('18').defname   := 'AUTOID';
                 l_txmsg.txfields ('18').TYPE      := 'N';
                 l_txmsg.txfields ('18').value      := rec.AUTOID;
            --23    S? LK ng??i nh?n   C
                 l_txmsg.txfields ('23').defname   := 'RECUSTODYCD';
                 l_txmsg.txfields ('23').TYPE      := 'C';
                 l_txmsg.txfields ('23').value      := rec.RECUSTODYCD;
            --24    T?ng??i nh?n   C
                 l_txmsg.txfields ('24').defname   := 'RECUSTNAME';
                 l_txmsg.txfields ('24').TYPE      := 'C';
                 l_txmsg.txfields ('24').value      := rec.RECUSTNAME;
            --26    Ti?n ph? N
                 l_txmsg.txfields ('26').defname   := 'FEEAMT';
                 l_txmsg.txfields ('26').TYPE      := 'N';
                 l_txmsg.txfields ('26').value      := rec.FEE;
            --27    Ti?n thu?   N
                 l_txmsg.txfields ('27').defname   := 'FEEAMT';
                 l_txmsg.txfields ('27').TYPE      := 'N';
                 l_txmsg.txfields ('27').value      := rec.TAX;
            --28    Ti?n ph??nh?n   N
                 l_txmsg.txfields ('28').defname   := 'FEEAMTSV';
                 l_txmsg.txfields ('28').TYPE      := 'N';
                 l_txmsg.txfields ('28').value      := rec.FEESV;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --55    S? ti?u kho?n ng??i nh?n   C
                 l_txmsg.txfields ('55').defname   := 'REAFACCTNO';
                 l_txmsg.txfields ('55').TYPE      := 'C';
                 l_txmsg.txfields ('55').value      := rec.REAFACCTNO;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.FULLNAME;
            --98    Lo?i ti?u kho?n ng??i nh?n   C
                 l_txmsg.txfields ('98').defname   := 'PRODUCTTYPECR';
                 l_txmsg.txfields ('98').TYPE      := 'C';
                 l_txmsg.txfields ('98').value      := rec.PRODUCTTYPECR;

          begin
            if txpks_#2266.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2266');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_2266');
    end auto_call_txpks_2266;

    procedure auto_call_txpks_22662(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_messagetype VARCHAR2(10);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2266');
      plog.error(pkgctx, 'auto_call_txpks_22662');
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W','A')
                        --and req.status <> 'C'
                        --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2266';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

        for rec in (SELECT SEO.*, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,SEC.SYMBOL, SE.COSTPRICE, AL.CDCONTENT PRODUCTTYPE,AL1.CDCONTENT PRODUCTTYPECR
                    FROM SESENDOUT SEO, CFMAST CF, AFMAST AF, SBSECURITIES SEC,SEMAST SE,ALLCODE AL,ALLCODE AL1,
                         AFTYPE AFT, AFMAST AF1, VSDTXREQ REQ
                    WHERE SUBSTR(SEO.ACCTNO,0,10)=AF.ACCTNO
                    AND AF.CUSTID=CF.CUSTID
                    AND SEC.CODEID=SEO.CODEID
                    AND SE.ACCTNO=SEO.ACCTNO
                    AND AF.ACTYPE =AFT.ACTYPE
                    AND SEO.REAFACCTNO = AF1.ACCTNO (+)
                    AND SEO.STRADE+SEO.SBLOCKED+SEO.SCAQTTY>0
                    AND DELTD='N'
                    AND AL.CDNAME='PRODUCTTYPE'
                    AND AFT.PRODUCTTYPE = AL.CDVAL(+)
                    AND NVL( AL1.CDNAME,'PRODUCTTYPE')='PRODUCTTYPE'
                    AND AF1.PRODUCTTYPE = AL1.CDVAL (+)
                    AND REQ.MSGACCT = CF.CUSTODYCD
                    and REQ.REQID = pv_reqid
                    ) LOOP

            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    S? TK ghi N?   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    S? TK CK ghi N?   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --05    S? LK   C
                 l_txmsg.txfields ('05').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.CUSTODYCD;
            --06    S? l??ng CK phong t?a   N
                 l_txmsg.txfields ('06').defname   := 'BLOCKED';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.SBLOCKED;
            --07    Ch?ng kho?  C
                 l_txmsg.txfields ('07').defname   := 'SYMBOL';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.SYMBOL;
            --08    Lo?i ti?u kho?n   C
                 l_txmsg.txfields ('08').defname   := 'PRODUCTTYPE';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := rec.PRODUCTTYPE;
            --09    Gi? N
                 l_txmsg.txfields ('09').defname   := 'PRICE';
                 l_txmsg.txfields ('09').TYPE      := 'N';
                 l_txmsg.txfields ('09').value      := rec.COSTPRICE;
            --10    S? l??ng giao d?ch   N
                 l_txmsg.txfields ('10').defname   := 'TRADE';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.STRADE;
            --12    T?ng s? l??ng   N
                 l_txmsg.txfields ('12').defname   := 'QTTY';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.SBLOCKED + rec.STRADE;
            --13    S? l??ng CK CA   N
                 l_txmsg.txfields ('13').defname   := 'CAQTTY';
                 l_txmsg.txfields ('13').TYPE      := 'N';
                 l_txmsg.txfields ('13').value      := rec.CAQTTY;
            --14    Lo?i ? ki?n   C
                 l_txmsg.txfields ('14').defname   := 'QTTYTYPE';
                 l_txmsg.txfields ('14').TYPE      := 'C';
                 l_txmsg.txfields ('14').value      := rec.QTTYTYPE;
            --18    AUTOID   N
                 l_txmsg.txfields ('18').defname   := 'AUTOID';
                 l_txmsg.txfields ('18').TYPE      := 'N';
                 l_txmsg.txfields ('18').value      := rec.AUTOID;
            --23    S? LK ng??i nh?n   C
                 l_txmsg.txfields ('23').defname   := 'RECUSTODYCD';
                 l_txmsg.txfields ('23').TYPE      := 'C';
                 l_txmsg.txfields ('23').value      := rec.RECUSTODYCD;
            --24    T?ng??i nh?n   C
                 l_txmsg.txfields ('24').defname   := 'RECUSTNAME';
                 l_txmsg.txfields ('24').TYPE      := 'C';
                 l_txmsg.txfields ('24').value      := rec.RECUSTNAME;
            --26    Ti?n ph? N
                 l_txmsg.txfields ('26').defname   := 'FEEAMT';
                 l_txmsg.txfields ('26').TYPE      := 'N';
                 l_txmsg.txfields ('26').value      := rec.FEE;
            --27    Ti?n thu?   N
                 l_txmsg.txfields ('27').defname   := 'FEEAMT';
                 l_txmsg.txfields ('27').TYPE      := 'N';
                 l_txmsg.txfields ('27').value      := rec.TAX;
            --28    Ti?n ph??nh?n   N
                 l_txmsg.txfields ('28').defname   := 'FEEAMTSV';
                 l_txmsg.txfields ('28').TYPE      := 'N';
                 l_txmsg.txfields ('28').value      := rec.FEESV;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --55    S? ti?u kho?n ng??i nh?n   C
                 l_txmsg.txfields ('55').defname   := 'REAFACCTNO';
                 l_txmsg.txfields ('55').TYPE      := 'C';
                 l_txmsg.txfields ('55').value      := rec.REAFACCTNO;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.FULLNAME;
            --98    Lo?i ti?u kho?n ng??i nh?n   C
                 l_txmsg.txfields ('98').defname   := 'PRODUCTTYPECR';
                 l_txmsg.txfields ('98').TYPE      := 'C';
                 l_txmsg.txfields ('98').value      := rec.PRODUCTTYPECR;

          begin
            if txpks_#2266.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2266');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_2266');
    end auto_call_txpks_22662;

    procedure auto_call_txpks_2265(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_messagetype VARCHAR2(10);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2265');
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W','R','N')
                        --and req.status <> 'C'
                        --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2265';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

        for rec in (SELECT SEO.*, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,
                           SEC.SYMBOL, SE.COSTPRICE
                    FROM SESENDOUT SEO, CFMAST CF, AFMAST AF, SBSECURITIES SEC,SEMAST SE,
                    VSDTXREQ REQ
                    WHERE SUBSTR(SEO.ACCTNO,0,10)=AF.ACCTNO
                    AND AF.CUSTID=CF.CUSTID
                    AND SEC.CODEID=SEO.CODEID
                    AND SE.ACCTNO=SEO.ACCTNO
                    AND SEO.STRADE+SEO.SBLOCKED+SEO.SCAQTTY>0
                    AND DELTD='N'
                    AND to_char(SEO.AUTOID) = REQ.REFCODE
                    and REQ.REQID = PV_REQID
                    ) LOOP

                --01    M? ch?ng kho?  C
                     l_txmsg.txfields ('01').defname   := 'CODEID';
                     l_txmsg.txfields ('01').TYPE      := 'C';
                     l_txmsg.txfields ('01').value      := rec.CODEID;
                --02    S? TK ghi N?   C
                     l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                     l_txmsg.txfields ('02').TYPE      := 'C';
                     l_txmsg.txfields ('02').value      := rec.AFACCTNO;
                --03    S? TK CK ghi N?   C
                     l_txmsg.txfields ('03').defname   := 'ACCTNO';
                     l_txmsg.txfields ('03').TYPE      := 'C';
                     l_txmsg.txfields ('03').value      := rec.ACCTNO;
                --05    S? LK   C
                     l_txmsg.txfields ('05').defname   := 'CUSTODYCD';
                     l_txmsg.txfields ('05').TYPE      := 'C';
                     l_txmsg.txfields ('05').value      := rec.CUSTODYCD;
                --06    S? l??ng CK phong t?a   N
                     l_txmsg.txfields ('06').defname   := 'BLOCKED';
                     l_txmsg.txfields ('06').TYPE      := 'N';
                     l_txmsg.txfields ('06').value      := rec.SBLOCKED;
                --07    Ch?ng kho?  C
                     l_txmsg.txfields ('07').defname   := 'SYMBOL';
                     l_txmsg.txfields ('07').TYPE      := 'C';
                     l_txmsg.txfields ('07').value      := rec.SYMBOL;
                --10    S? l??ng giao d?ch   N
                     l_txmsg.txfields ('10').defname   := 'TRADE';
                     l_txmsg.txfields ('10').TYPE      := 'N';
                     l_txmsg.txfields ('10').value      := rec.STRADE;
                --12    T?ng s? l??ng   N
                     l_txmsg.txfields ('12').defname   := 'QTTY';
                     l_txmsg.txfields ('12').TYPE      := 'N';
                     l_txmsg.txfields ('12').value      := rec.SBLOCKED + rec.STRADE;
                --13    S? l??ng CK CA   N
                     l_txmsg.txfields ('13').defname   := 'CAQTTY';
                     l_txmsg.txfields ('13').TYPE      := 'N';
                     l_txmsg.txfields ('13').value      := rec.SCAQTTY;
                --18    AUTOID   N
                     l_txmsg.txfields ('18').defname   := 'AUTOID';
                     l_txmsg.txfields ('18').TYPE      := 'N';
                     l_txmsg.txfields ('18').value      := rec.AUTOID;
                --23    S? LK ng??i nh?n   C
                     l_txmsg.txfields ('23').defname   := 'RECUSTODYCD';
                     l_txmsg.txfields ('23').TYPE      := 'C';
                     l_txmsg.txfields ('23').value      := rec.RECUSTODYCD;
                --24    T?ng??i nh?n   C
                     l_txmsg.txfields ('24').defname   := 'RECUSTNAME';
                     l_txmsg.txfields ('24').TYPE      := 'C';
                     l_txmsg.txfields ('24').value      := rec.RECUSTNAME;
                --30    Di?n gi?i   C
                     l_txmsg.txfields ('30').defname   := 'DESC';
                     l_txmsg.txfields ('30').TYPE      := 'C';
                     l_txmsg.txfields ('30').value      := l_strdesc;
                --55    S? ti?u kho?n ng??i nh?n   C
                     l_txmsg.txfields ('55').defname   := 'REAFACCTNO';
                     l_txmsg.txfields ('55').TYPE      := 'C';
                     l_txmsg.txfields ('55').value      := rec.REAFACCTNO;
                --90    H? t?  C
                     l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                     l_txmsg.txfields ('90').TYPE      := 'C';
                     l_txmsg.txfields ('90').value      := rec.FULLNAME;

          begin
            if txpks_#2265.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'R' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2265');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_2265');
    end auto_call_txpks_2265;

    procedure auto_call_txpks_8879(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_reqid       varchar2(20);
      l_effect_date date;
    begin
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      select fldval into l_reqid from vsdtrflogdtl where fldname = 'REQID' and refautoid = pv_vsdtrfid;
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W','A')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = l_reqid) loop
        -- nap giao dich de xu ly
        l_tltxcd       := '8879';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT DA.* FROM VSDTXREQ REQ,
                    (
                        SELECT CF.CUSTODYCD, B.DESACCTNO AFDDI , C.CODEID, C.SYMBOL, C.PARVALUE, A.AFACCTNO,
                        TO_CHAR(B.TXDATE,'DD/MM/YYYY') TXDATE,B.TXNUM,B.ACCTNO,B.PRICE,B.QTTY,B.STATUS,B.DESACCTNO,B.FEEAMT,B.TAXAMT,B.SDATE,B.VDATE,
                        CF.IDCODE ,A4.CDCONTENT TRADEPLACE,CASE WHEN CI.COREBANK='Y' THEN 0 ELSE 1 END ISCOREBANK,B.TAXAMT TAX,
                        CI.DEPOLASTDT, 0 PITQTTY,0 PITAMT,CF.FULLNAME,
                        TO_CHAR(B.TXDATE,'DD/MM/YYYY') || B.TXNUM ACCREF
                        FROM SEMAST A, SERETAIL B, SBSECURITIES C ,AFMAST AF , CFMAST CF ,ALLCODE A4,AFTYPE AFTY,CIMAST CI
                        WHERE A.ACCTNO = B.ACCTNO
                        AND A.CODEID = C.CODEID
                        AND B.QTTY > 0 AND B.STATUS='S'
                        AND AF.ACCTNO =A.AFACCTNO AND AF.CUSTID =CF.CUSTID
                        AND A4.CDTYPE = 'SE' AND A4.CDNAME = 'TRADEPLACE'
                        AND A4.CDVAL = C.TRADEPLACE
                        AND AF.ACTYPE=AFTY.ACTYPE AND AF.ACCTNO=CI.ACCTNO
                    ) DA
                    WHERE to_char(DA.TXDATE,'DDMMRRRR')||DA.TXNUM = REQ.REFCODE
                    AND REQ.MSGSTATUS = 'C'
                    AND REQ.STATUS = 'C'
                    AND REQ.REQID = L_REQID) loop

            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    S? TK b?  C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    S? TK SE  b?  C
                 l_txmsg.txfields ('03').defname   := 'SEACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    Ng?l?p Ti?u kho?n   C
                 l_txmsg.txfields ('04').defname   := 'TXDATE';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.TXDATE;
            --05    S? ch?ng t?   C
                 l_txmsg.txfields ('05').defname   := 'TXNUM';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.TXNUM;
            --06    S? tham chi?u   C
                 l_txmsg.txfields ('06').defname   := 'ACCREF';
                 l_txmsg.txfields ('06').TYPE      := 'C';
                 l_txmsg.txfields ('06').value      := rec.ACCREF;
            --07    S? TK mua   C
                 l_txmsg.txfields ('07').defname   := 'AFACCTNO2';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := SUBSTR(rec.AFDDI,1,10);
            --08    S?TK SE  mua   C
                 l_txmsg.txfields ('08').defname   := 'SEACCTNO2';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := rec.AFDDI + rec.CODEID;
            --10    Kh?i l??ng   N
                 l_txmsg.txfields ('10').defname   := 'ORDERQTTY';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Gi? N
                 l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PRICE;
            --12    M?nh gi? N
                 l_txmsg.txfields ('12').defname   := 'PARVALUE';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.PARVALUE;
            --14    Thu? chuy?n nh??ng   N
                 l_txmsg.txfields ('14').defname   := 'TAX';
                 l_txmsg.txfields ('14').TYPE      := 'N';
                 l_txmsg.txfields ('14').value      := rec.TAX;
            --15    Thu? TNCN   N
                 l_txmsg.txfields ('15').defname   := 'TAXAMT';
                 l_txmsg.txfields ('15').TYPE      := 'N';
                 l_txmsg.txfields ('15').value      := rec.TAXAMT;
            --16    Ph?K ch?a ??n h?n   N
                 l_txmsg.txfields ('16').defname   := 'DEPOFEEACR';
                 l_txmsg.txfields ('16').TYPE      := 'N';
                 l_txmsg.txfields ('16').value      := FN_CIGETDEPOFEEACR(rec.AFDDI,rec.CODEID,getcurrdate,getcurrdate,rec.QTTY);
            --17    Ph?K ??n h?n   N
                 l_txmsg.txfields ('17').defname   := 'DEPOFEEAMT';
                 l_txmsg.txfields ('17').TYPE      := 'N';
                 l_txmsg.txfields ('17').value      := FN_CIGETDEPOFEEAMT(rec.AFDDI,rec.CODEID,getcurrdate,getcurrdate,rec.QTTY);
            --18    CK quy?n   N
                 l_txmsg.txfields ('18').defname   := 'PITQTTY';
                 l_txmsg.txfields ('18').TYPE      := 'N';
                 l_txmsg.txfields ('18').value      := rec.PITQTTY;
            --19    Thu? ??u t? v?n   N
                 l_txmsg.txfields ('19').defname   := 'PITAMT';
                 l_txmsg.txfields ('19').TYPE      := 'N';
                 l_txmsg.txfields ('19').value      := rec.PITAMT;
            --22    Ph?D l?   N
                 l_txmsg.txfields ('22').defname   := 'FEEAMT';
                 l_txmsg.txfields ('22').TYPE      := 'N';
                 l_txmsg.txfields ('22').value      := rec.FEEAMT;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --32    Ng?chuy?n ph?K ??n h?n g?n nh?t   D
                 l_txmsg.txfields ('32').defname   := 'DEPOLASTDT';
                 l_txmsg.txfields ('32').TYPE      := 'D';
                 l_txmsg.txfields ('32').value      := rec.DEPOLASTDT;
            --60    L?K ng?h?   N
                 l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
                 l_txmsg.txfields ('60').TYPE      := 'N';
                 l_txmsg.txfields ('60').value      := rec.ISCOREBANK;
            --88    S? TK l?u k? b?  C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.FULLNAME;
          begin
            if txpks_#8879.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          --update vsdtxreq
          --   set status = 'C', msgstatus = 'F' --boprocess = 'Y'
          -- where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set boprocess = 'E', boprocess_err = p_err_code
           where reqid = L_REQID;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp, ERRDESC = ERRDESC || ' | ERROR FLEX 8879 ERRNUM: ' || p_err_code
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_8879',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_8879;

    procedure auto_call_txpks_8894(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_reqid       varchar2(20);
    begin
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

      select fldval into l_reqid from vsdtrflogdtl where fldname = 'REQID' and refautoid = pv_vsdtrfid;

      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W','A')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = l_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '8894';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT DA.* FROM VSDTXREQ REQ,
                    (
                        SELECT CF.CUSTODYCD, substr(B.DESACCTNO,1,10) AFDDI , C.CODEID, C.SYMBOL, C.PARVALUE, A.AFACCTNO,
                        B.TXDATE,B.TXNUM,B.ACCTNO,B.PRICE,B.QTTY,B.STATUS,B.DESACCTNO,B.FEEAMT,B.TAXAMT,B.SDATE,B.VDATE,
                        CF.IDCODE ,A4.CDCONTENT TRADEPLACE,CASE WHEN CI.COREBANK='Y' THEN 0 ELSE 1 END ISCOREBANK,
                        B.TAXAMT TAX,CI.DEPOLASTDT, CF.FULLNAME,TO_CHAR(B.TXDATE,'DD/MM/YYYY') || B.TXNUM ACCREF, B.PRICE*B.QTTY EXECAMT
                        FROM SEMAST A, SERETAIL B, SBSECURITIES C ,AFMAST AF , CFMAST CF ,ALLCODE A4,AFTYPE AFTY,CIMAST CI
                        WHERE A.ACCTNO = B.ACCTNO AND A.CODEID = C.CODEID AND B.QTTY > 0 AND B.STATUS='I' AND AF.ACCTNO =A.AFACCTNO AND AF.CUSTID =CF.CUSTID
                        AND A4.CDTYPE = 'SE' AND A4.CDNAME = 'TRADEPLACE'  AND A4.CDVAL = C.TRADEPLACE
                        AND AF.ACTYPE=AFTY.ACTYPE AND AF.ACCTNO=CI.ACCTNO
                    )DA
                    WHERE to_char(DA.TXDATE,'DDMMRRRR')||DA.TXNUM = REQ.REFCODE
                    AND REQ.MSGSTATUS = 'C'
                    AND REQ.STATUS = 'C'
                    AND REQ.REQID = l_reqid) loop
            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    S? TK b?  C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    S? TK SE  b?  C
                 l_txmsg.txfields ('03').defname   := 'SEACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    Ng?l?p Ti?u kho?n   C
                 l_txmsg.txfields ('04').defname   := 'TXDATE';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.TXDATE;
            --05    S? ch?ng t?   C
                 l_txmsg.txfields ('05').defname   := 'TXNUM';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.TXNUM;
            --06    S? tham chi?u   C
                 l_txmsg.txfields ('06').defname   := 'ACCREF';
                 l_txmsg.txfields ('06').TYPE      := 'C';
                 l_txmsg.txfields ('06').value      := rec.ACCREF;
            --07    S? TK mua   C
                 l_txmsg.txfields ('07').defname   := 'AFACCTNO2';
                 l_txmsg.txfields ('07').TYPE      := 'C';
                 l_txmsg.txfields ('07').value      := rec.AFDDI;
            --08    S?TK SE  mua   C
                 l_txmsg.txfields ('08').defname   := 'SEACCTNO2';
                 l_txmsg.txfields ('08').TYPE      := 'C';
                 l_txmsg.txfields ('08').value      := rec.AFDDI + rec.CODEID ;
            --10    Kh?i l??ng   N
                 l_txmsg.txfields ('10').defname   := 'ORDERQTTY';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Gi? N
                 l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PRICE;
            --12    M?nh gi? N
                 l_txmsg.txfields ('12').defname   := 'PARVALUE';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.PARVALUE;
            --14    Thu?   N
                 l_txmsg.txfields ('14').defname   := 'TAX';
                 l_txmsg.txfields ('14').TYPE      := 'N';
                 l_txmsg.txfields ('14').value      := rec.TAX;
            --15    Thu? TNCN   N
                 l_txmsg.txfields ('15').defname   := 'TAXAMT';
                 l_txmsg.txfields ('15').TYPE      := 'N';
                 l_txmsg.txfields ('15').value      := rec.TAXAMT;
            --16    Gi?r?   N
                 l_txmsg.txfields ('16').defname   := 'EXECAMT';
                 l_txmsg.txfields ('16').TYPE      := 'N';
                 l_txmsg.txfields ('16').value      := rec.EXECAMT;
            --18    CK quy?n   N
                 l_txmsg.txfields ('18').defname   := 'PITQTTY';
                 l_txmsg.txfields ('18').TYPE      := 'N';
                 l_txmsg.txfields ('18').value      := 0;
            --19    Thu? b?CK quy?n   N
                 l_txmsg.txfields ('19').defname   := 'PITAMT';
                 l_txmsg.txfields ('19').TYPE      := 'N';
                 l_txmsg.txfields ('19').value      := 0;
            --22    Ph?D l?   N
                 l_txmsg.txfields ('22').defname   := 'FEEAMT';
                 l_txmsg.txfields ('22').TYPE      := 'N';
                 l_txmsg.txfields ('22').value      := rec.FEEAMT;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --60    L?K ng?h?   N
                 l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
                 l_txmsg.txfields ('60').TYPE      := 'N';
                 l_txmsg.txfields ('60').value      := rec.ISCOREBANK;
            --88    S? TK l?u k? b?  C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.FULLNAME;
          begin
            if txpks_#8894.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'F' --boprocess = 'Y'
           where reqid = l_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = l_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp, ERRDESC = ERRDESC || ' | ERROR FLEX 8894 ERRNUM: ' || p_err_code
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_8894',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_8894;

    procedure auto_call_txpks_8816(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin

       begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('N', 'R', 'W')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '8816';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (select DA.* from VSDTXREQ REQ,
                    (
                        SELECT CF.CUSTODYCD, C.CODEID, C.SYMBOL, C.PARVALUE, A.AFACCTNO, B.* , CF.IDCODE ,A4.CDCONTENT TRADEPLACE
                        FROM SEMAST A, SERETAIL B, SBSECURITIES C ,AFMAST AF , CFMAST CF ,ALLCODE A4
                        WHERE A.ACCTNO = B.ACCTNO AND A.CODEID = C.CODEID AND B.QTTY > 0 AND B.status ='S' AND AF.ACCTNO =A.AFACCTNO AND AF.CUSTID =CF.CUSTID
                        AND A4.CDTYPE = 'SE' AND A4.CDNAME = 'TRADEPLACE'  AND A4.CDVAL = C.TRADEPLACE
                    )DA
                    where to_char(DA.TXDATE,'DDMMRRRR')||DA.TXNUM = REQ.REFCODE
                    AND REQ.REQID = PV_REQID ) loop
            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    S? Ti?u kho?n b?  C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    S? t?kho?n SE   C
                 l_txmsg.txfields ('03').defname   := 'SEACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    Ng?l?p Ti?u kho?n   D
                 l_txmsg.txfields ('04').defname   := 'TXDATE';
                 l_txmsg.txfields ('04').TYPE      := 'D';
                 l_txmsg.txfields ('04').value      := rec.TXDATE;
            --05    S? giao d?ch   C
                 l_txmsg.txfields ('05').defname   := 'TXNUM';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.TXNUM;
            --10    Kh?i l??ng   N
                 l_txmsg.txfields ('10').defname   := 'ORDERQTTY';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Gi? N
                 l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PRICE;
            --12    M?nh gi? N
                 l_txmsg.txfields ('12').defname   := 'PARVALUE';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.PARVALUE;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;

          begin
            if txpks_#8816.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'R' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_8816',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_8816;

procedure auto_call_txpks_2236(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;

  begin
    /*select req.msgstatus into l_msgstatus
                   from vsdtxreq req
                  where  req.reqid = pv_reqid;

    PLOG.ERROR(pkgctx, 'BEGIN pv_reqid:'||pv_reqid||', pv_vsdtrfid:'||pv_vsdtrfid||', l_msgstatus:'||l_msgstatus);*/

    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('R','N')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '2236';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (
                    SELECT SE.AUTOID,SE.TXDATE, AF.ACCTNO AFACCTNO,SE.ACCTNO,CF.FULLNAME CUSTNAME,CF.CUSTODYCD,SB.SYMBOL,SB.PARVALUE,
                        SE.SENDQTTY QTTY  ,SB.CODEID,CF.ADDRESS , CF.IDCODE  LICENSE
                    FROM SEMORTAGE SE, AFMAST AF ,CFMAST CF,SBSECURITIES SB, VSDTXREQ REQ
                    WHERE SUBSTR(SE.ACCTNO,1,10)= AF.ACCTNO
                        AND AF.CUSTID= CF.CUSTID
                        AND TO_CHAR(SE.AUTOID) = REQ.REFCODE
                        AND SE.STATUS='N' AND SE.DELTD<>'Y'
                        AND SUBSTR(SE.ACCTNO,11)= SB.CODEID AND SE.TLTXCD = '2232' AND SE.SENDQTTY> 0
                        AND REQ.REQID = PV_REQID
                        AND ROWNUM <= 1
                    ) loop
            --10    So luong   N
                 l_txmsg.txfields ('10').defname   := 'AMT';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Menh gia   N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;
            --90    Ho ten   C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --02    So tieu khoan   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --04    So tu tang   C
                 l_txmsg.txfields ('04').defname   := 'AUTOID';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.AUTOID;
            --91    Dia chi   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --03    So tieu khoan chung khoan   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;
            --30    Mo ta   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --01    Ma chung khoan   C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;


        begin

          if txpks_#2236.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'R' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2236',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2236;

    procedure auto_call_txpks_2248(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    varchar2(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2248');
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W', 'A')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop
        -- nap giao dich de xu ly
        l_tltxcd       := '2248';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT SE.*
                    FROM V_SE2248 SE, VSDTRFLOG LOG, VSDTXREQ REQ
                    WHERE REQ.REQID = LOG.REFERENCEID
                    AND SE.SYMBOL = LOG.SYMBOL
                    AND SE.CUSTODYCD = REQ.MSGACCT
                    AND REQ.REQID = pv_reqid) loop
          plog.info(pkgctx,'::req Id call v_se2248:' || pv_reqid );
          select systemnums.c_batch_prefixed ||
                  lpad(seq_batchtxnum.nextval, 8, '0')
            into l_txmsg.txnum
             from dual;

             --01    M? ch?ng kho?  C
                  l_txmsg.txfields ('01').defname   := 'CODEID';
                  l_txmsg.txfields ('01').TYPE      := 'C';
                  l_txmsg.txfields ('01').value      := rec.CODEID;
             --02    S? Ti?u kho?n   C
                  l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                  l_txmsg.txfields ('02').TYPE      := 'C';
                  l_txmsg.txfields ('02').value      := REPLACE(rec.AFACCTNO,'.');
             --03    S? t?kho?n   C
                  l_txmsg.txfields ('03').defname   := 'ACCTNO';
                  l_txmsg.txfields ('03').TYPE      := 'C';
                  l_txmsg.txfields ('03').value      := REPLACE(rec.ACCTNO,'.');
             --08    S? l??ng CK giao d?ch   N
                  l_txmsg.txfields ('08').defname   := 'DTOCLOSE';
                  l_txmsg.txfields ('08').TYPE      := 'N';
                  l_txmsg.txfields ('08').value      := rec.DTOCLOSE;
             --09    S? l??ng CK HCCN   N
                  l_txmsg.txfields ('09').defname   := 'BLOCKDTOCLOSE';
                  l_txmsg.txfields ('09').TYPE      := 'N';
                  l_txmsg.txfields ('09').value      := rec.BLOCKDTOCLOSE;
             --10    S? l??ng   N
                  l_txmsg.txfields ('10').defname   := 'QTTY';
                  l_txmsg.txfields ('10').TYPE      := 'N';
                  l_txmsg.txfields ('10').value      := rec.SEQTTY;
             --11    M?nh gi? N
                  l_txmsg.txfields ('11').defname   := 'PARVALUE';
                  l_txmsg.txfields ('11').TYPE      := 'N';
                  l_txmsg.txfields ('11').value      := rec.PARVALUE;
             --14    SL Quy?n mua ch?a ?K   N
                  l_txmsg.txfields ('14').defname   := 'RIGHTOFFQTTY';
                  l_txmsg.txfields ('14').TYPE      := 'N';
                  l_txmsg.txfields ('14').value      := rec.SENDPBALANCE;
             --15    SL Ch?ng kho?CA   N
                  l_txmsg.txfields ('15').defname   := 'CAQTTYRECEIV';
                  l_txmsg.txfields ('15').TYPE      := 'N';
                  l_txmsg.txfields ('15').value      := rec.QTTY;
             --16    SLCK CA ghi gi?m   N
                  l_txmsg.txfields ('16').defname   := 'CAQTTYDB';
                  l_txmsg.txfields ('16').TYPE      := 'N';
                  l_txmsg.txfields ('16').value      := rec.SENDAQTTY;
             --17    S? ti?n CA   N
                  l_txmsg.txfields ('17').defname   := 'CAAMTRECEIV';
                  l_txmsg.txfields ('17').TYPE      := 'N';
                  l_txmsg.txfields ('17').value      := rec.SENDAMT;
             --18    S? quy?n bi?u quy?t   N
                  l_txmsg.txfields ('18').defname   := 'RIGHTQTTY';
                  l_txmsg.txfields ('18').TYPE      := 'N';
                  l_txmsg.txfields ('18').value      := rec.RIGHTQTTY;
             --30    M?   C
                  l_txmsg.txfields ('30').defname   := 'DESC';
                  l_txmsg.txfields ('30').TYPE      := 'C';
                  l_txmsg.txfields ('30').value      := l_strdesc;
             --33    H? t?kh? h? nh?n   C
                  l_txmsg.txfields ('33').defname   := 'CUSTNAMER';
                  l_txmsg.txfields ('33').TYPE      := 'C';
                  l_txmsg.txfields ('33').value      := rec.TOFULLNAME;
             --88    S? TK l?u k? b?  C
                  l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                  l_txmsg.txfields ('88').TYPE      := 'C';
                  l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
             --90    H? t?  C
                  l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                  l_txmsg.txfields ('90').TYPE      := 'C';
                  l_txmsg.txfields ('90').value      := rec.FULLNAME;
             --92    S? Ti?u kho?n nh?n   C
                  l_txmsg.txfields ('92').defname   := 'AFACCTNO';
                  l_txmsg.txfields ('92').TYPE      := 'C';
                  l_txmsg.txfields ('92').value      := rec.TOAFACCTNO;
             --98    S? TK l?u k? nh?n    C
                  l_txmsg.txfields ('98').defname   := 'CUSTODYCD';
                  l_txmsg.txfields ('98').TYPE      := 'C';
                  l_txmsg.txfields ('98').value      := rec.TOCUSTODYCD;
          begin

            if txpks_#2248.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
              --RETURN;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set msgstatus = 'A'
          where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
            update vsdtxreq
             set status = 'E', boprocess = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'E', timeprocess = systimestamp, ERRDESC = ERRDESC || ' | ERROR FLEX 2248 ERRNUM: ' || p_err_code
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2248');
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2248',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_2248;

    procedure auto_call_txpks_22482(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    varchar2(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2248');
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C', 'W', 'A')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop
        -- nap giao dich de xu ly
        l_tltxcd       := '2248';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT SE.*
                    FROM V_SE2248 SE,VSDTXREQ REQ
                    WHERE SE.CUSTODYCD = REQ.MSGACCT
                    AND REQ.REQID = pv_reqid) loop
          plog.info(pkgctx,'::req Id call v_se2248:' || pv_reqid );
          select systemnums.c_batch_prefixed ||
                  lpad(seq_batchtxnum.nextval, 8, '0')
            into l_txmsg.txnum
             from dual;

             --01    M? ch?ng kho?  C
                  l_txmsg.txfields ('01').defname   := 'CODEID';
                  l_txmsg.txfields ('01').TYPE      := 'C';
                  l_txmsg.txfields ('01').value      := rec.CODEID;
             --02    S? Ti?u kho?n   C
                  l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                  l_txmsg.txfields ('02').TYPE      := 'C';
                  l_txmsg.txfields ('02').value      := REPLACE(rec.AFACCTNO,'.');
             --03    S? t?kho?n   C
                  l_txmsg.txfields ('03').defname   := 'ACCTNO';
                  l_txmsg.txfields ('03').TYPE      := 'C';
                  l_txmsg.txfields ('03').value      := REPLACE(rec.ACCTNO,'.');
             --08    S? l??ng CK giao d?ch   N
                  l_txmsg.txfields ('08').defname   := 'DTOCLOSE';
                  l_txmsg.txfields ('08').TYPE      := 'N';
                  l_txmsg.txfields ('08').value      := rec.DTOCLOSE;
             --09    S? l??ng CK HCCN   N
                  l_txmsg.txfields ('09').defname   := 'BLOCKDTOCLOSE';
                  l_txmsg.txfields ('09').TYPE      := 'N';
                  l_txmsg.txfields ('09').value      := rec.BLOCKDTOCLOSE;
             --10    S? l??ng   N
                  l_txmsg.txfields ('10').defname   := 'QTTY';
                  l_txmsg.txfields ('10').TYPE      := 'N';
                  l_txmsg.txfields ('10').value      := rec.SEQTTY;
             --11    M?nh gi? N
                  l_txmsg.txfields ('11').defname   := 'PARVALUE';
                  l_txmsg.txfields ('11').TYPE      := 'N';
                  l_txmsg.txfields ('11').value      := rec.PARVALUE;
             --14    SL Quy?n mua ch?a ?K   N
                  l_txmsg.txfields ('14').defname   := 'RIGHTOFFQTTY';
                  l_txmsg.txfields ('14').TYPE      := 'N';
                  l_txmsg.txfields ('14').value      := rec.SENDPBALANCE;
             --15    SL Ch?ng kho?CA   N
                  l_txmsg.txfields ('15').defname   := 'CAQTTYRECEIV';
                  l_txmsg.txfields ('15').TYPE      := 'N';
                  l_txmsg.txfields ('15').value      := rec.QTTY;
             --16    SLCK CA ghi gi?m   N
                  l_txmsg.txfields ('16').defname   := 'CAQTTYDB';
                  l_txmsg.txfields ('16').TYPE      := 'N';
                  l_txmsg.txfields ('16').value      := rec.SENDAQTTY;
             --17    S? ti?n CA   N
                  l_txmsg.txfields ('17').defname   := 'CAAMTRECEIV';
                  l_txmsg.txfields ('17').TYPE      := 'N';
                  l_txmsg.txfields ('17').value      := rec.SENDAMT;
             --18    S? quy?n bi?u quy?t   N
                  l_txmsg.txfields ('18').defname   := 'RIGHTQTTY';
                  l_txmsg.txfields ('18').TYPE      := 'N';
                  l_txmsg.txfields ('18').value      := rec.RIGHTQTTY;
             --30    M?   C
                  l_txmsg.txfields ('30').defname   := 'DESC';
                  l_txmsg.txfields ('30').TYPE      := 'C';
                  l_txmsg.txfields ('30').value      := l_strdesc;
             --33    H? t?kh? h? nh?n   C
                  l_txmsg.txfields ('33').defname   := 'CUSTNAMER';
                  l_txmsg.txfields ('33').TYPE      := 'C';
                  l_txmsg.txfields ('33').value      := rec.TOFULLNAME;
             --88    S? TK l?u k? b?  C
                  l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                  l_txmsg.txfields ('88').TYPE      := 'C';
                  l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
             --90    H? t?  C
                  l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                  l_txmsg.txfields ('90').TYPE      := 'C';
                  l_txmsg.txfields ('90').value      := rec.FULLNAME;
             --92    S? Ti?u kho?n nh?n   C
                  l_txmsg.txfields ('92').defname   := 'AFACCTNO';
                  l_txmsg.txfields ('92').TYPE      := 'C';
                  l_txmsg.txfields ('92').value      := rec.TOAFACCTNO;
             --98    S? TK l?u k? nh?n    C
                  l_txmsg.txfields ('98').defname   := 'CUSTODYCD';
                  l_txmsg.txfields ('98').TYPE      := 'C';
                  l_txmsg.txfields ('98').value      := rec.TOCUSTODYCD;
          begin

            if txpks_#2248.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
              --RETURN;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set msgstatus = 'C', status = 'C'
          where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
            update vsdtxreq
             set status = 'E', boprocess = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'E', timeprocess = systimestamp, ERRDESC = ERRDESC || ' | ERROR FLEX 2248 ERRNUM: ' || p_err_code
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2248');
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2248',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_22482;

    procedure auto_call_txpks_2290(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_mserror     varchar2(1000);
      l_effect_date date;
    begin

      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('N', 'R', 'W','A')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2290';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT SE.*
                    FROM V_SE2290 SE, VSDTRFLOG LOG, VSDTXREQ REQ
                    WHERE REQ.REQID = LOG.REFERENCEID
                    AND SE.SYMBOL = LOG.SYMBOL
                    AND SE.CUSTODYCD = REQ.MSGACCT
                    AND REQ.REQID = PV_REQID) LOOP

          select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;

            --02    S? Ti?u kho?n   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    T?kho?n ch?ng kho?  C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    M? ch?ng kho?  C
                 l_txmsg.txfields ('04').defname   := 'SYMBOL';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.SYMBOL;
            --05    Tr?ng th?  C
                 l_txmsg.txfields ('05').defname   := 'STATUS';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.STATUS;
            --06    S? d? ch?ng kho?  N
                 l_txmsg.txfields ('06').defname   := 'TRADE';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.TRADE;
            --10    SL CK  ch? ??giao d?ch   N
                 l_txmsg.txfields ('10').defname   := 'DTOCLOSE';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.DTOCLOSE;
            --11    SL CK HCCN ch? ??  N
                 l_txmsg.txfields ('11').defname   := 'BLOCKDTOCLOSE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.BLOCKDTOCLOSE;
            --14    SL Quy?n mua ch?a ?K   N
                 l_txmsg.txfields ('14').defname   := 'RIGHTOFFQTTY';
                 l_txmsg.txfields ('14').TYPE      := 'N';
                 l_txmsg.txfields ('14').value      := rec.SENDPBALANCE;
            --15    SL Ch?ng kho?CA   N
                 l_txmsg.txfields ('15').defname   := 'CAQTTYRECEIV';
                 l_txmsg.txfields ('15').TYPE      := 'N';
                 l_txmsg.txfields ('15').value      := rec.QTTY;
            --16    SLCK CA ghi gi?m   N
                 l_txmsg.txfields ('16').defname   := 'CAQTTYDB';
                 l_txmsg.txfields ('16').TYPE      := 'N';
                 l_txmsg.txfields ('16').value      := rec.SENDAQTTY;
            --17    S? ti?n CA   N
                 l_txmsg.txfields ('17').defname   := 'CAAMTRECEIV';
                 l_txmsg.txfields ('17').TYPE      := 'N';
                 l_txmsg.txfields ('17').value      := rec.SENDAMT;
            --18    S? quy?n bi?u quy?t   N
                 l_txmsg.txfields ('18').defname   := 'RIGHTQTTY';
                 l_txmsg.txfields ('18').TYPE      := 'N';
                 l_txmsg.txfields ('18').value      := rec.RIGHTQTTY;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
          begin
            if txpks_#2290.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          --update vsdtxreq
          --   set msgstatus = 'A'
          -- where reqid = pv_reqid;

          -- Trang thai VSDTRFLOG

          select fldval into l_mserror
          from vsdtrflogdtl
          where refautoid = pv_vsdtrfid
          and fldname = 'REAS';

          update vsdtrflog
             set status = 'C', timeprocess = systimestamp, errdesc = l_mserror
           where autoid = pv_vsdtrfid; --l_txmsg.txfields('09').value;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          --update vsdtxreq
          --   set status = 'E', boprocess = 'E', boprocess_err = p_err_code
          --where reqid = pv_reqid;
          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'E', timeprocess = systimestamp, ERRDESC = ERRDESC || ' | ERROR FLEX 2290 ERRNUM: ' || p_err_code
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2290',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_2290;

procedure auto_call_txpks_2257(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;
  begin

    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('R','N')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '2257';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (
                    SELECT SE.AUTOID,SE.TXDATE, AF.ACCTNO AFACCTNO,SE.ACCTNO,CF.FULLNAME CUSTNAME,CF.CUSTODYCD,SB.SYMBOL,
                        SB.PARVALUE,SE.QTTY,SB.CODEID,CF.ADDRESS, CF.IDCODE LICENSE
                    FROM SEMORTAGE SE, AFMAST AF ,CFMAST CF,SBSECURITIES SB, VSDTXREQ REQ
                    WHERE SUBSTR(SE.ACCTNO,1,10)= AF.ACCTNO
                        AND AF.CUSTID= CF.CUSTID AND SE.DELTD <> 'Y'
                        AND SUBSTR(SE.ACCTNO,11) = SB.CODEID
                        AND TO_CHAR(SE.AUTOID) = REQ.REFCODE
                        AND SE.STATUS = 'N' AND SE.TLTXCD = '2233' AND SE.SENDQTTY > 0
                        AND REQ.REQID = PV_REQID
                        AND ROWNUM <= 1
                    ) loop
            --01    Ma chung khoan   C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    So tieu khoan   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    So tieu khoan CK   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    So tu tang   C
                 l_txmsg.txfields ('04').defname   := 'AUTOID';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.AUTOID;
            --10    So luong CK   N
                 l_txmsg.txfields ('10').defname   := 'AMT';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Menh gia   N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;
            --30    Dien giai   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --88    So TK luu ky   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --90    Ho ten   C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --91    Dia chi   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;


        begin

          if txpks_#2257.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'R' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2257',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2257;

procedure auto_call_txpks_2251(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_REFIDVSD    varchar2(50);
    l_effect_date date;
  begin

    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '2251';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

      --lay so hieu phong toa cua vsd de lam giai toa

      select fldval into l_REFIDVSD from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'VSDMSGID';


      for rec in (
                    SELECT SE.AUTOID,SE.TXDATE, AF.ACCTNO AFACCTNO,SE.ACCTNO,CF.FULLNAME CUSTNAME,CF.CUSTODYCD,SB.SYMBOL,
                        SB.PARVALUE,SE.QTTY,SB.CODEID,CF.ADDRESS , CF.IDCODE  LICENSE, FEEAMT
                    FROM SEMORTAGE SE, AFMAST AF ,CFMAST CF,SBSECURITIES SB, VSDTXREQ REQ
                    WHERE SUBSTR(SE.ACCTNO,1,10)= AF.ACCTNO
                        AND TO_CHAR(SE.AUTOID) = REQ.REFCODE
                        AND AF.CUSTID= CF.CUSTID AND SE.STATUS='N' AND SE.DELTD<>'Y'
                        AND SUBSTR(SE.ACCTNO,11)= SB.CODEID
                        AND SE.TLTXCD = '2232' AND SE.SENDQTTY> 0
                        AND REQ.REQID = PV_REQID
                        AND ROWNUM <= 1
                    ) loop
            --01    Ma chung khoan   C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    So tieu khoan   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    So tieu khoan CK   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    So tu tang   C
                 l_txmsg.txfields ('04').defname   := 'AUTOID';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.AUTOID;
            --10    So luong   N
                 l_txmsg.txfields ('10').defname   := 'AMT';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Menh gia   N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;
            --12    Gia tri phi   N
                 l_txmsg.txfields ('12').defname   := 'FEEAMT';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.FEEAMT;
            --30    Mo ta   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --90    Ho ten   C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --91    Dia chi   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;


        begin
          if txpks_#2251.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
             rollback;
            --RETURN;
          end if;
          update semortage set REFIDVSD = l_REFIDVSD where autoid = rec.AUTOID;
        end;
      end loop;

      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'C' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2251',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2251;

  procedure auto_call_txpks_2253(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;
  begin

    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop

      -- nap giao dich de xu ly
      l_tltxcd       := '2253';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;
      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
      for rec in (
                    SELECT SE.AUTOID,SE.TXDATE, AF.ACCTNO AFACCTNO,SE.ACCTNO,CF.FULLNAME CUSTNAME,CF.CUSTODYCD,
                        SB.SYMBOL,SB.PARVALUE,SE.QTTY,SB.CODEID,CF.ADDRESS, CF.IDCODE  LICENSE
                    FROM SEMORTAGE SE, AFMAST AF ,CFMAST CF,SBSECURITIES SB, VSDTXREQ REQ
                    WHERE SUBSTR(SE.ACCTNO,1,10)= AF.ACCTNO
                        AND TO_CHAR(SE.AUTOID) = REQ.REFCODE
                        AND AF.CUSTID= CF.CUSTID AND SE.DELTD <> 'Y'
                        AND SUBSTR(SE.ACCTNO,11)= SB.CODEID
                        AND SE.STATUS = 'N' AND SE.TLTXCD = '2233' AND SE.SENDQTTY > 0
                        AND REQ.REQID = PV_REQID
                        AND ROWNUM <= 1
                    ) loop
            --01    Ma CK   C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --02    So tieu khoan   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    So tieu khoan CK   C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    So tu tang   C
                 l_txmsg.txfields ('04').defname   := 'AUTOID';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.AUTOID;
            --10    So luong CK   N
                 l_txmsg.txfields ('10').defname   := 'AMT';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.QTTY;
            --11    Menh gia   N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;
            --30    Dien giai   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --88    So TK luu ky   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --90    Ho ten   C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --91    Dia chi   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;


        begin

          if txpks_#2253.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'C', msgstatus = 'C' --boprocess = 'Y'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2253',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2253;

  procedure auto_call_txpks_2245(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      n_codeid      varchar2(6);
      pv_funcname   varchar2(50);
      l_acctno      varchar2(10);
      l_symbol      varchar2(20);
      l_symboltype  varchar2(4);
      l_symbolclas  varchar2(1);
      l_VSDSECTYPE  varchar2(4);
      l_SECTYPE     varchar2(10);
      l_BLOCKEDQTTY number;
      l_TRADEQTTY   number;
      L_COUNT       number;
      l_FEE         number;
      l_effect_date date;
      l_codeid      varchar2(50);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2245');
      plog.info(pkgctx, 'process req id:' || pv_reqid);
      p_err_code:=0;
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

      --Lay thong tin dien confirm
        -- nap giao dich de xu ly
        l_tltxcd       := '2245';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := '0000'; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        select tr.funcname
          into pv_funcname
          from vsdtrflog tr
         where to_char(tr.autoid) = pv_vsdtrfid;


        SELECT COUNT(*) INTO L_COUNT
         FROM VSDTRFLOG LOG, SBSECURITIES SB, CFMAST CF, AFMAST AF, SEMAST SE
         WHERE LOG.SYMBOL = SB.SYMBOL
         AND CF.CUSTID = AF.CUSTID
         AND CF.CUSTODYCD = LOG.RECCUSTODYCD
         AND AF.ACCTNO||SB.CODEID = SE.ACCTNO
         and to_char(LOG.AUTOID) = PV_VSDTRFID;
         --neu co 1 tk ck cua ck nhan
         if l_count = 1 then
            SELECT SE.AFACCTNO INTO L_ACCTNO
            FROM VSDTRFLOG LOG, SBSECURITIES SB, CFMAST CF, AFMAST AF, SEMAST SE
            WHERE LOG.SYMBOL = SB.SYMBOL
            AND CF.CUSTID = AF.CUSTID
            AND CF.CUSTODYCD = LOG.RECCUSTODYCD
            AND AF.ACCTNO||SB.CODEID = SE.ACCTNO
            and to_char(LOG.AUTOID) = PV_VSDTRFID;
         else
            SELECT DT.ACCTNO INTO l_acctno
            FROM
            (
                SELECT AF.*
                FROM VSDTRFLOG LOG, CFMAST CF, AFMAST AF
                WHERE CF.CUSTID = AF.CUSTID
                AND CF.CUSTODYCD = LOG.RECCUSTODYCD
                and to_char(LOG.AUTOID) = PV_VSDTRFID
                ORDER BY AF.ACTYPE
            )DT
            WHERE ROWNUM = 1;
         end if;
        for rec in (select 'VSDDEP' FEETYPE, 0 AUTOID, sb.codeid,sb.symbol, SUBSTR(log.refcustodycd,1,3) INWARD, log.reccustodycd custodycd,
                    af.acctno AFACCT2, af.acctno||sb.codeid ACCT2, cf.FULLNAME CUSTNAME, cf.ADDRESS, cf.idcode LICENSE,SEINFO.BASICPRICE PRICE,
                    (case when logf.VSDSECTYPE = '1' then log.reqtty else 0 end) AMT, (case when logf.VSDSECTYPE = '2' then log.reqtty else 0 end) DEPOBLOCK,
                    log.reqtty QTTY,sb.PARVALUE, '' TRTYPE, CI.DEPOLASTDT, FN_CIGETDEPOFEEAMT(af.acctno,sb.codeid,getcurrdate,getcurrdate,log.reqtty) DEPOFEEAMT,
                    FN_CIGETDEPOFEEACR(af.acctno,sb.codeid,getcurrdate,getcurrdate,log.reqtty) DEPOFEEACR, '002' QTTYTYPE
                    from vsdtrflog log, sbsecurities sb, afmast af, cfmast cf, SECURITIES_INFO SEINFO,cimast ci,
                    (
                        select refautoid,
                               MAX(case when fldname = 'VSDSECTYPE' then fldval end) VSDSECTYPE
                        from vsdtrflogdtl
                        GROUP by refautoid
                    )logf
                    where log.symbol = sb.symbol
                    and af.custid = cf.custid
                    and cf.custodycd = log.reccustodycd
                    and Sb.CODEID=SEINFO.CODEID
                    and ci.acctno = af.acctno
                    and log.autoid = logf.refautoid
                    and to_char(log.autoid) = pv_vsdtrfid
                    and af.acctno like l_acctno) loop

                select fldval into l_SECTYPE from vsdtrflogdtl where refautoid = pv_vsdtrfid and fldname = 'SECTYPE';

                if l_SECTYPE = 'PEND' then
                    select codeid into l_codeid from sbsecurities WHERE symbol = rec.symbol||'_WFT';
                else
                    l_codeid:=rec.CODEID;
                end if;

            --00    Lo?i ph? C
                 l_txmsg.txfields ('00').defname   := 'FEETYPE';
                 l_txmsg.txfields ('00').TYPE      := 'C';
                 l_txmsg.txfields ('00').value      := rec.FEETYPE;
            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := l_codeid;
            --02    M? ?i?n   C
                 l_txmsg.txfields ('02').defname   := 'REQID';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := pv_vsdtrfid;
            --03    Chuy?n t?   C
                 l_txmsg.txfields ('03').defname   := 'INWARD';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := REC.INWARD;
            --04    S? ti?u kho?n ghi c?C
                 l_txmsg.txfields ('04').defname   := 'AFACCT2';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.AFACCT2;
            --05    Ti?u kho?n ck ghi c?C
                 l_txmsg.txfields ('05').defname   := 'ACCT2';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.AFACCT2||l_codeid;
            --06    S? CK HCCN   N
                 l_txmsg.txfields ('06').defname   := 'DEPOBLOCK';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.DEPOBLOCK;
            --09    Gi?huy?n kho?n   N
                 l_txmsg.txfields ('09').defname   := 'PRICE';
                 l_txmsg.txfields ('09').TYPE      := 'N';
                 l_txmsg.txfields ('09').value      := rec.PRICE;
            --10    S? CK TDCN   N
                 l_txmsg.txfields ('10').defname   := 'AMT';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.AMT;
            --11    M?nh gi? N
                 l_txmsg.txfields ('11').defname   := 'PARVALUE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.PARVALUE;
            --12    T?ng s? l??ng   N
                 l_txmsg.txfields ('12').defname   := 'QTTY';
                 l_txmsg.txfields ('12').TYPE      := 'N';
                 l_txmsg.txfields ('12').value      := rec.AMT + rec.DEPOBLOCK;
            --13    Ph?K ch?a ??n h?n   N
                 l_txmsg.txfields ('13').defname   := 'DEPOFEEACR';
                 l_txmsg.txfields ('13').TYPE      := 'N';
                 l_txmsg.txfields ('13').value      := rec.DEPOFEEACR;
            --14    Lo?i ?i?u ki?n   C
                 l_txmsg.txfields ('14').defname   := 'QTTYTYPE';
                 l_txmsg.txfields ('14').TYPE      := 'C';
                 l_txmsg.txfields ('14').value      := rec.QTTYTYPE;
            --15    Ph?K ??n h?n   N
                 l_txmsg.txfields ('15').defname   := 'DEPOFEEAMT';
                 l_txmsg.txfields ('15').TYPE      := 'N';
                 l_txmsg.txfields ('15').value      := rec.DEPOFEEAMT;
            --16    Lo?i l?u k?   C
                 l_txmsg.txfields ('16').defname   := 'DEPOTYPE';
                 l_txmsg.txfields ('16').TYPE      := 'C';
                 l_txmsg.txfields ('16').value      := '000';
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DES';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --31    Lo?i chuy?n kho?n   C
                 l_txmsg.txfields ('31').defname   := 'TRTYPE';
                 l_txmsg.txfields ('31').TYPE      := 'C';
                 l_txmsg.txfields ('31').value      := rec.TRTYPE;
            --32    Ng?chuy?n ph?K ??n h?n g?n nh?t   C
                 l_txmsg.txfields ('32').defname   := 'DEPOLASTDT';
                 l_txmsg.txfields ('32').TYPE      := 'C';
                 l_txmsg.txfields ('32').value      := rec.DEPOLASTDT;
            --33    Bi?u ph? C
                 l_txmsg.txfields ('33').defname   := 'DRFEETYPE';
                 l_txmsg.txfields ('33').TYPE      := 'C';
                 l_txmsg.txfields ('33').value      := '';
            --34    T? ??ng   C
                 l_txmsg.txfields ('34').defname   := 'CACULATETYPE';
                 l_txmsg.txfields ('34').TYPE      := 'C';
                 l_txmsg.txfields ('34').value      := '02';
            --45    Ph?huy?n nh??ng   N

                 l_txmsg.txfields ('45').defname   := 'FEE';
                 l_txmsg.txfields ('45').TYPE      := 'N';
                 l_txmsg.txfields ('45').value      := fn_get_se_fee_2245(l_FEE,'02','',l_TRADEQTTY + l_BLOCKEDQTTY,rec.PRICE);
            --55    Ph?iao d?ch   N
                 l_txmsg.txfields ('55').defname   := 'FEECOMP';
                 l_txmsg.txfields ('55').TYPE      := 'N';
                 l_txmsg.txfields ('55').value      := 0;
            --88    S? tk l?u k?   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --91    ??a ch?   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;
            --98    Lo?i chuy?n kho?n   C
                 l_txmsg.txfields ('98').defname   := 'Type';
                 l_txmsg.txfields ('98').TYPE      := 'C';
                 l_txmsg.txfields ('98').value      := '001';
            --99    S? t? sinh   C
                 l_txmsg.txfields ('99').defname   := 'AUTOID';
                 l_txmsg.txfields ('99').TYPE      := 'C';
                 l_txmsg.txfields ('99').value      := '';

        begin

            if rec.AMT + rec.DEPOBLOCK > 0 then
              if txpks_#2245.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
                 systemnums.c_success then
                rollback;
                --RETURN;
              end if;
            end if;
        end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          /*update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;*/

          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          /*update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;*/
          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'E', timeprocess = systimestamp, errdesc = p_err_code
           where autoid = pv_vsdtrfid;
        end if;
    exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2245',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_2245;

  procedure auto_call_txpks_3320(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      pv_funcname   varchar2(50);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_3320');
      plog.info(pkgctx, 'process req id:' || pv_reqid);

      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
        -- nap giao dich de xu ly
        l_tltxcd       := '3320';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;
        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := '0000'; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        select tr.funcname
          into pv_funcname
          from vsdtrflog tr
         where to_char(tr.autoid) = pv_vsdtrfid;
        for rec in (SELECT SB.CODEID, LOG.REQTTY QUANTITY, LOG.RECCUSTODYCD CUSTODYCDCODE
                    FROM VSDTRFLOG LOG, SBSECURITIES SB
                    WHERE SB.SYMBOL = LOG.SYMBOL
                    AND to_char(LOG.AUTOID) = pv_vsdtrfid) loop
            --01    M? ch?ng kho?  C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --07    S? CK s? h?u   N
                 l_txmsg.txfields ('07').defname   := 'QUANTITY';
                 l_txmsg.txfields ('07').TYPE      := 'N';
                 l_txmsg.txfields ('07').value      := rec.QUANTITY;
            --30    Di?n gi?i   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_tltxcd;
            --88    S? TK l?u k?   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCDCODE';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCDCODE;

        begin

          if txpks_#3320.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          /*else
            update vsdtxreq
            set objkey = l_txmsg.txnum,txdate = l_txmsg.txdate, msgacct = rec.CUSTODYCD, txamt = rec.QUANTITY
            where reqid = pv_reqid;*/
          end if;
        end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          /*update vsdtxreq
             set status = 'C', msgstatus = 'C' --boprocess = 'Y'
           where reqid = pv_reqid;*/

          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          /*update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;*/
          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;
    exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_3320',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_3320;

  procedure auto_call_txpks_2265NAK(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
      l_messagetype VARCHAR2(10);
    begin
      plog.setbeginsection(pkgctx, 'auto_call_txpks_2265');
      -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
      -- FLDNAME la VSDEFFDATE
      begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;

      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('C','R','N','A')
                        --and req.status <> 'C'
                        --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2265';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

        for rec in (SELECT SEO.*, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,
                      SEC.SYMBOL, SE.COSTPRICE
                      FROM SESENDOUT SEO, CFMAST CF, AFMAST AF, SBSECURITIES SEC,SEMAST SE, vsdtxreq req
                      WHERE SUBSTR(SEO.ACCTNO,0,10)=AF.ACCTNO
                      AND AF.CUSTID=CF.CUSTID
                      AND SEC.CODEID=SEO.CODEID
                      AND SE.ACCTNO=SEO.ACCTNO
                      and seo.strade+seo.sblocked+seo.scaqtty>0
                      and deltd='N' and SEO.TRTYPE = '014' and SEO.ISTRFCA = 'Y'
                      and CF.CUSTODYCD = req.msgacct
                      and req.reqid = PV_REQID
                    ) LOOP

                --01    M? ch?ng kho?  C
                     l_txmsg.txfields ('01').defname   := 'CODEID';
                     l_txmsg.txfields ('01').TYPE      := 'C';
                     l_txmsg.txfields ('01').value      := rec.CODEID;
                --02    S? TK ghi N?   C
                     l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                     l_txmsg.txfields ('02').TYPE      := 'C';
                     l_txmsg.txfields ('02').value      := rec.AFACCTNO;
                --03    S? TK CK ghi N?   C
                     l_txmsg.txfields ('03').defname   := 'ACCTNO';
                     l_txmsg.txfields ('03').TYPE      := 'C';
                     l_txmsg.txfields ('03').value      := rec.ACCTNO;
                --05    S? LK   C
                     l_txmsg.txfields ('05').defname   := 'CUSTODYCD';
                     l_txmsg.txfields ('05').TYPE      := 'C';
                     l_txmsg.txfields ('05').value      := rec.CUSTODYCD;
                --06    S? l??ng CK phong t?a   N
                     l_txmsg.txfields ('06').defname   := 'BLOCKED';
                     l_txmsg.txfields ('06').TYPE      := 'N';
                     l_txmsg.txfields ('06').value      := rec.SBLOCKED;
                --07    Ch?ng kho?  C
                     l_txmsg.txfields ('07').defname   := 'SYMBOL';
                     l_txmsg.txfields ('07').TYPE      := 'C';
                     l_txmsg.txfields ('07').value      := rec.SYMBOL;
                --10    S? l??ng giao d?ch   N
                     l_txmsg.txfields ('10').defname   := 'TRADE';
                     l_txmsg.txfields ('10').TYPE      := 'N';
                     l_txmsg.txfields ('10').value      := rec.STRADE;
                --12    T?ng s? l??ng   N
                     l_txmsg.txfields ('12').defname   := 'QTTY';
                     l_txmsg.txfields ('12').TYPE      := 'N';
                     l_txmsg.txfields ('12').value      := rec.SBLOCKED + rec.STRADE;
                --13    S? l??ng CK CA   N
                     l_txmsg.txfields ('13').defname   := 'CAQTTY';
                     l_txmsg.txfields ('13').TYPE      := 'N';
                     l_txmsg.txfields ('13').value      := rec.SCAQTTY;
                --18    AUTOID   N
                     l_txmsg.txfields ('18').defname   := 'AUTOID';
                     l_txmsg.txfields ('18').TYPE      := 'N';
                     l_txmsg.txfields ('18').value      := rec.AUTOID;
                --23    S? LK ng??i nh?n   C
                     l_txmsg.txfields ('23').defname   := 'RECUSTODYCD';
                     l_txmsg.txfields ('23').TYPE      := 'C';
                     l_txmsg.txfields ('23').value      := rec.RECUSTODYCD;
                --24    T?ng??i nh?n   C
                     l_txmsg.txfields ('24').defname   := 'RECUSTNAME';
                     l_txmsg.txfields ('24').TYPE      := 'C';
                     l_txmsg.txfields ('24').value      := rec.RECUSTNAME;
                --30    Di?n gi?i   C
                     l_txmsg.txfields ('30').defname   := 'DESC';
                     l_txmsg.txfields ('30').TYPE      := 'C';
                     l_txmsg.txfields ('30').value      := l_strdesc;
                --55    S? ti?u kho?n ng??i nh?n   C
                     l_txmsg.txfields ('55').defname   := 'REAFACCTNO';
                     l_txmsg.txfields ('55').TYPE      := 'C';
                     l_txmsg.txfields ('55').value      := rec.REAFACCTNO;
                --90    H? t?  C
                     l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                     l_txmsg.txfields ('90').TYPE      := 'C';
                     l_txmsg.txfields ('90').value      := rec.FULLNAME;

          begin
            if txpks_#2265.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;

        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set status = 'C', msgstatus = 'R' --boprocess = 'Y'
           where reqid = pv_reqid;

          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where referenceid = pv_reqid;

        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          update vsdtxreq
             set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
           where reqid = pv_reqid;
          -- Tr?ng th?i VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
      plog.setendsection(pkgctx, 'auto_call_txpks_2265NAK');
    exception
      when others then
        plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'auto_call_txpks_2265NAK');
    end auto_call_txpks_2265NAK;

    procedure auto_call_txpks_2290NAK(pv_reqid number, pv_vsdtrfid number) as
      l_txmsg       tx.msg_rectype;
      v_strcurrdate varchar2(20);
      l_strdesc     varchar2(400);
      l_tltxcd      varchar2(4);
      p_err_code    number(20);
      l_err_param   varchar2(1000);
      l_sqlerrnum   varchar2(200);
      l_effect_date date;
    begin

       begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
      --Lay thong tin dien confirm
      for rec0 in (select req.*
                     from vsdtxreq req
                    where req.msgstatus in ('N', 'R', 'W','A')
                         --and req.status <> 'C'
                         --and req.msgstatus = 'W'
                      and req.reqid = pv_reqid) loop

        -- nap giao dich de xu ly
        l_tltxcd       := '2290';
        l_txmsg.tltxcd := l_tltxcd;
        select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
        l_txmsg.msgtype := 'T';
        l_txmsg.local   := 'N';
        l_txmsg.tlid    := systemnums.c_system_userid;
        select sys_context('USERENV', 'HOST'),
               sys_context('USERENV', 'IP_ADDRESS', 15)
          into l_txmsg.wsname, l_txmsg.ipaddress
          from dual;
        l_txmsg.off_line  := 'N';
        l_txmsg.deltd     := txnums.c_deltd_txnormal;
        l_txmsg.txstatus  := txstatusnums.c_txcompleted;
        l_txmsg.msgsts    := '0';
        l_txmsg.ovrsts    := '0';
        l_txmsg.batchname := 'DAY';
        l_txmsg.busdate   := l_effect_date;
        l_txmsg.txdate    := getcurrdate;

        select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
        l_txmsg.brid := rec0.brid; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day
        for rec in (SELECT SE.*
                    FROM V_SE2290 SE, VSDTXREQ REQ
                    WHERE SE.CUSTODYCD = REQ.msgacct
                    AND REQ.REQID = PV_REQID) LOOP

          select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;

            --02    S? Ti?u kho?n   C
                 l_txmsg.txfields ('02').defname   := 'AFACCTNO';
                 l_txmsg.txfields ('02').TYPE      := 'C';
                 l_txmsg.txfields ('02').value      := rec.AFACCTNO;
            --03    T?kho?n ch?ng kho?  C
                 l_txmsg.txfields ('03').defname   := 'ACCTNO';
                 l_txmsg.txfields ('03').TYPE      := 'C';
                 l_txmsg.txfields ('03').value      := rec.ACCTNO;
            --04    M? ch?ng kho?  C
                 l_txmsg.txfields ('04').defname   := 'SYMBOL';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.SYMBOL;
            --05    Tr?ng th?  C
                 l_txmsg.txfields ('05').defname   := 'STATUS';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.STATUS;
            --06    S? d? ch?ng kho?  N
                 l_txmsg.txfields ('06').defname   := 'TRADE';
                 l_txmsg.txfields ('06').TYPE      := 'N';
                 l_txmsg.txfields ('06').value      := rec.TRADE;
            --10    SL CK  ch? ??giao d?ch   N
                 l_txmsg.txfields ('10').defname   := 'DTOCLOSE';
                 l_txmsg.txfields ('10').TYPE      := 'N';
                 l_txmsg.txfields ('10').value      := rec.DTOCLOSE;
            --11    SL CK HCCN ch? ??  N
                 l_txmsg.txfields ('11').defname   := 'BLOCKDTOCLOSE';
                 l_txmsg.txfields ('11').TYPE      := 'N';
                 l_txmsg.txfields ('11').value      := rec.BLOCKDTOCLOSE;
            --14    SL Quy?n mua ch?a ?K   N
                 l_txmsg.txfields ('14').defname   := 'RIGHTOFFQTTY';
                 l_txmsg.txfields ('14').TYPE      := 'N';
                 l_txmsg.txfields ('14').value      := rec.SENDPBALANCE;
            --15    SL Ch?ng kho?CA   N
                 l_txmsg.txfields ('15').defname   := 'CAQTTYRECEIV';
                 l_txmsg.txfields ('15').TYPE      := 'N';
                 l_txmsg.txfields ('15').value      := rec.QTTY;
            --16    SLCK CA ghi gi?m   N
                 l_txmsg.txfields ('16').defname   := 'CAQTTYDB';
                 l_txmsg.txfields ('16').TYPE      := 'N';
                 l_txmsg.txfields ('16').value      := rec.SENDAQTTY;
            --17    S? ti?n CA   N
                 l_txmsg.txfields ('17').defname   := 'CAAMTRECEIV';
                 l_txmsg.txfields ('17').TYPE      := 'N';
                 l_txmsg.txfields ('17').value      := rec.SENDAMT;
            --18    S? quy?n bi?u quy?t   N
                 l_txmsg.txfields ('18').defname   := 'RIGHTQTTY';
                 l_txmsg.txfields ('18').TYPE      := 'N';
                 l_txmsg.txfields ('18').value      := rec.RIGHTQTTY;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
          begin
            if txpks_#2290.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
               systemnums.c_success then
              rollback;
            end if;
          end;
        end loop;
        if nvl(p_err_code, 0) = 0 then
          update vsdtxreq
             set msgstatus = 'R',status = 'C'
           where reqid = pv_reqid;

          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'C', timeprocess = systimestamp
           where referenceid = pv_reqid; --l_txmsg.txfields('09').value;
        else
          -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
          --update vsdtxreq
          --   set status = 'E', boprocess = 'E', boprocess_err = p_err_code
          --where reqid = pv_reqid;
          -- Trang thai VSDTRFLOG
          update vsdtrflog
             set status = 'E', timeprocess = systimestamp, ERRDESC = ERRDESC || ' | ERROR FLEX 2290 ERRNUM: ' || p_err_code
           where autoid = pv_vsdtrfid;
        end if;

      end loop;
    exception
      when others then
        l_sqlerrnum := substr(sqlerrm, 200);
        insert into log_err
          (id, date_log, position, text)
        values
          (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2290NAK',
           l_sqlerrnum || dbms_utility.format_error_backtrace);
    end auto_call_txpks_2290NAK;

    procedure auto_call_txpks_3385(pv_reqid number, pv_vsdtrfid number) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_count       number;
    l_actype      VARCHAR2(50);
    l_acctno      varchar2(20);
    l_effect_date date;
  begin
    begin
        select to_date(fldval, 'YYYYMMDD')
          into l_effect_date
          from vsdtrflogdtl
         where refautoid = pv_vsdtrfid
           and fldname = 'VSDEFFDATE';
      exception
        when others then
          l_effect_date := getcurrdate;
      end;
    --Lay thong tin dien confirm
      -- nap giao dich de xu ly
      l_tltxcd       := '3385';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;
      select systemnums.c_batch_prefixed ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

      SELECT COUNT(1) into l_count
      FROM CAMAST CAM,CASCHD CA,SBSECURITIES SB,VSDTRFLOG LOG,
      CFMAST CF, AFMAST AF
      WHERE CA.CAMASTID = CAM.CAMASTID
      AND CAM.CODEID = SB.CODEID AND LOG.SYMBOL = SB.SYMBOL
      AND CF.CUSTODYCD = LOG.RECCUSTODYCD AND CF.CUSTID = AF.CUSTID
      AND CAM.STATUS NOT IN ('D','R','C') AND CAM.CATYPE = '014'
      AND AF.ACCTNO = CA.AFACCTNO
      AND CA.DELTD <> 'Y'
      AND to_char(LOG.AUTOID) = PV_VSDTRFID;

      --neu co tk ck quyen cua ck nhan
         if l_count >= 1 then
            select DA.ACCTNO into L_ACCTNO
            from
            (
                SELECT AF.ACCTNO
                FROM CAMAST CAM,CASCHD CA,SBSECURITIES SB,VSDTRFLOG LOG,
                CFMAST CF, AFMAST AF
                WHERE CA.CAMASTID = CAM.CAMASTID
                AND CAM.CODEID = SB.CODEID AND LOG.SYMBOL = SB.SYMBOL
                AND CF.CUSTODYCD = LOG.RECCUSTODYCD AND CF.CUSTID = AF.CUSTID
                AND AF.ACCTNO = CA.AFACCTNO
                AND CAM.STATUS NOT IN ('D','R','C') AND CAM.CATYPE = '014'
                AND CA.DELTD <> 'Y'
                AND to_char(LOG.AUTOID) = PV_VSDTRFID
                ORDER BY CA.AUTOID DESC
            )DA
            WHERE ROWNUM <= 1;
         else
            SELECT DT.ACCTNO INTO l_acctno
            FROM
            (
                SELECT AF.*
                FROM VSDTRFLOG LOG, CFMAST CF, AFMAST AF
                WHERE CF.CUSTID = AF.CUSTID
                AND CF.CUSTODYCD = LOG.RECCUSTODYCD
                AND to_char(LOG.AUTOID) = PV_VSDTRFID
                ORDER BY AF.ACTYPE
            )DT
            WHERE ROWNUM = 1;
         end if;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := '0000'; -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

      for rec in (SELECT * FROM
                    (
                        SELECT CA.OPTCODEID CODEID,CF.ACCTNO AFACCT2, CF.ACCTNO||CA.OPTCODEID ACCT2, CA.CAMASTID,
                        CA.CODEID ORGCODEID, CF.ACCTNO||CA.CODEID ORGSEACCTNO, LOG.REQTTY AMT, SB.SYMBOL,CA.CODEID TOCODEID,
                        CF.COUNTRY, LOG.RECCUSTODYCD CUSTODYCD, CF.CUSTNAME, CF.ADDRESS,CF.LICENSE, CF.IDDATE, CF.IDPLACE,
                        LOGF.FLDVAL VSDSECTYPE, LOG.REFCUSTODYCD TRANTO
                        FROM CAMAST CA, SBSECURITIES SB,VSDTRFLOG LOG, VSDTRFLOGDTL LOGF,
                        (
                            SELECT CFM.CUSTODYCD, CFM.COUNTRY,CFM.FULLNAME CUSTNAME, CFM.ADDRESS,CFM.IDCODE LICENSE, CFM.IDDATE, CFM.IDPLACE, AF.ACCTNO
                            FROM CFMAST CFM, AFMAST AF
                            WHERE CFM.CUSTID = AF.CUSTID AND AF.ACCTNO LIKE l_acctno
                        ) CF
                        WHERE CA.CODEID = SB.CODEID
                        AND SB.SYMBOL = LOG.SYMBOL
                        AND LOG.RECCUSTODYCD = CF.CUSTODYCD
                        AND to_char(LOG.AUTOID) = LOGF.REFAUTOID
                        AND CA.STATUS NOT IN ('D','R','C')
                        AND CA.CATYPE = '014'
                        AND LOGF.FLDNAME = 'VSDSECTYPE'
                        AND to_char(LOG.AUTOID) = PV_VSDTRFID
                        ORDER BY CA.AUTOID DESC
                    )DA
                    WHERE ROWNUM <= 1) loop
              --01    M? ch?ng kho?quy?n   C
                 l_txmsg.txfields ('01').defname   := 'CODEID';
                 l_txmsg.txfields ('01').TYPE      := 'C';
                 l_txmsg.txfields ('01').value      := rec.CODEID;
            --04    S? Ti?u kho?n ghi c?C
                 l_txmsg.txfields ('04').defname   := 'AFACCT2';
                 l_txmsg.txfields ('04').TYPE      := 'C';
                 l_txmsg.txfields ('04').value      := rec.AFACCT2;
            --05    S? t?kho?n ghi C?C
                 l_txmsg.txfields ('05').defname   := 'ACCT2';
                 l_txmsg.txfields ('05').TYPE      := 'C';
                 l_txmsg.txfields ('05').value      := rec.ACCT2;
            --06    M? s? ki?n   C
                 l_txmsg.txfields ('06').defname   := 'CAMASTID';
                 l_txmsg.txfields ('06').TYPE      := 'C';
                 l_txmsg.txfields ('06').value      := rec.CAMASTID;
            --11    M? ch?ng kho?  C
                 l_txmsg.txfields ('11').defname   := 'ORGCODEID';
                 l_txmsg.txfields ('11').TYPE      := 'C';
                 l_txmsg.txfields ('11').value      := rec.ORGCODEID;
            --12    M? ch?ng kho?  C
                 l_txmsg.txfields ('12').defname   := 'ORGSEACCTNO';
                 l_txmsg.txfields ('12').TYPE      := 'C';
                 l_txmsg.txfields ('12').value      := rec.ORGSEACCTNO;
            --21    S? l??ng quy?n   N
                 l_txmsg.txfields ('21').defname   := 'AMT';
                 l_txmsg.txfields ('21').TYPE      := 'N';
                 l_txmsg.txfields ('21').value      := rec.AMT;
            --30    M?   C
                 l_txmsg.txfields ('30').defname   := 'DESC';
                 l_txmsg.txfields ('30').TYPE      := 'C';
                 l_txmsg.txfields ('30').value      := l_strdesc;
            --35    M? CK ch?t SH   C
                 l_txmsg.txfields ('35').defname   := 'SYMBOL';
                 l_txmsg.txfields ('35').TYPE      := 'C';
                 l_txmsg.txfields ('35').value      := rec.SYMBOL;
            --40    M? CK nh?n   C
                 l_txmsg.txfields ('40').defname   := 'TOCODEID';
                 l_txmsg.txfields ('40').TYPE      := 'C';
                 l_txmsg.txfields ('40').value      := rec.TOCODEID;
            --50    Key   C
                 l_txmsg.txfields ('50').defname   := 'TXKEY';
                 l_txmsg.txfields ('50').TYPE      := 'C';
                 l_txmsg.txfields ('50').value      := '';
            --80    Qu?c t?ch   C
                 l_txmsg.txfields ('80').defname   := 'COUNTRY';
                 l_txmsg.txfields ('80').TYPE      := 'C';
                 l_txmsg.txfields ('80').value      := rec.COUNTRY;
            --88    S? TK luu k?   C
                 l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                 l_txmsg.txfields ('88').TYPE      := 'C';
                 l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
            --90    H? t?  C
                 l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                 l_txmsg.txfields ('90').TYPE      := 'C';
                 l_txmsg.txfields ('90').value      := rec.CUSTNAME;
            --91    ??a ch?   C
                 l_txmsg.txfields ('91').defname   := 'ADDRESS';
                 l_txmsg.txfields ('91').TYPE      := 'C';
                 l_txmsg.txfields ('91').value      := rec.ADDRESS;
            --92    CMND/GPKD   C
                 l_txmsg.txfields ('92').defname   := 'LICENSE';
                 l_txmsg.txfields ('92').TYPE      := 'C';
                 l_txmsg.txfields ('92').value      := rec.LICENSE;
            --93    Ng?c?p   C
                 l_txmsg.txfields ('93').defname   := 'IDDATE';
                 l_txmsg.txfields ('93').TYPE      := 'C';
                 l_txmsg.txfields ('93').value      := rec.IDDATE;
            --94    N?i c?p   C
                 l_txmsg.txfields ('94').defname   := 'IDPLACE';
                 l_txmsg.txfields ('94').TYPE      := 'C';
                 l_txmsg.txfields ('94').value      := rec.IDPLACE;
            --78    VSDSECTYPE   C
                 l_txmsg.txfields ('78').defname   := 'VSDSECTYPE';
                 l_txmsg.txfields ('78').TYPE      := 'C';
                 l_txmsg.txfields ('78').value      := rec.VSDSECTYPE;

        begin

          if txpks_#3385.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          /*else
            update vsdtxreq
            set objkey = l_txmsg.txnum,txdate = l_txmsg.txdate, msgacct = rec.CUSTODYCD, afacctno = rec.AFACCT2,
            txamt = rec.AMT
            where reqid = pv_reqid;*/
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        /*update vsdtxreq
           set status = 'C', msgstatus = 'C' --boprocess = 'Y'
         where reqid = pv_reqid;
        */
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        /*update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;*/
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_3385',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_3385;

  procedure auto_call_txpks_0059(pv_reqid number,pv_custodycd varchar2) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    p_err_code    number(20);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;
  begin
    -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
    -- FLDNAME la VSDEFFDATE

    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C', 'W','A')
                       --and req.status <> 'C'
                       --and req.msgstatus = 'W'
                    and req.reqid = pv_reqid) loop


      -- nap giao dich de xu ly
      l_tltxcd       := '0059';
      l_txmsg.tltxcd := l_tltxcd;
      select txdesc into l_strdesc from tltx where tltxcd = l_tltxcd;
      l_txmsg.msgtype := 'T';
      l_txmsg.local   := 'N';
      l_txmsg.tlid    := systemnums.c_system_userid;
      select sys_context('USERENV', 'HOST'),
             sys_context('USERENV', 'IP_ADDRESS', 15)
        into l_txmsg.wsname, l_txmsg.ipaddress
        from dual;
      l_txmsg.off_line  := 'N';
      l_txmsg.deltd     := txnums.c_deltd_txnormal;
      l_txmsg.txstatus  := txstatusnums.c_txcompleted;
      l_txmsg.msgsts    := '0';
      l_txmsg.ovrsts    := '0';
      l_txmsg.batchname := 'DAY';
      l_txmsg.busdate   := l_effect_date;
      l_txmsg.txdate    := getcurrdate;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;

        select systemnums.c_batch_prefixed ||
                lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
    for rec in (select * from cfmast where custodycd = pv_custodycd and status <> 'C') loop
     --88    S? TK luu k??C
     l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
     l_txmsg.txfields ('88').TYPE      := 'C';
     l_txmsg.txfields ('88').value      := rec.custodycd;
     --30    Di?n gi?i   C
     l_txmsg.txfields ('30').defname   := 'DESC';
     l_txmsg.txfields ('30').TYPE      := 'C';
     l_txmsg.txfields ('30').value      := l_strdesc;
     --03    M?h? h?   C
     l_txmsg.txfields ('03').defname   := 'CUSTID';
     l_txmsg.txfields ('03').TYPE      := 'C';
     l_txmsg.txfields ('03').value      := rec.custid;
     --99    M?h? h?   C
     l_txmsg.txfields ('08').defname   := 'SENDTOVSD';
     l_txmsg.txfields ('08').TYPE      := 'C';
     l_txmsg.txfields ('08').value     := 'N';

        begin

          if txpks_#0059.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback;
            --RETURN;
          end if;
        end;
      end loop;
      if nvl(p_err_code, 0) = 0 then
        update cfmast
        set status = 'C', nsdstatus = 'C', activests = 'N'
        where custodycd = pv_custodycd;
      else
        update vsdtxreq
           set status = 'E', boprocess = 'E', msgstatus = 'E', boprocess_err = p_err_code
         where reqid = pv_reqid;
      end if;
    end loop;
  exception
    when others then
      l_sqlerrnum := substr(sqlerrm, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'AUTO_CALL_TXPKS_2249',
         l_sqlerrnum || dbms_utility.format_error_backtrace);
  end auto_call_txpks_0059;

PROCEDURE create_new_CA(pv_reqid IN NUMBER, pv_vsdtrfid IN NUMBER, pv_catype IN varchar2)
IS
    l_symbol            varchar2(20);
    l_codeid            varchar2(20);
    l_devintrate        varchar2(20);
    l_devidentshares    varchar2(20);
    l_splitrate         varchar2(20);
    l_interestrate      varchar2(20);
    l_exprice           NUMBER;
    l_vsdid             varchar2(100);
    l_actiondate        DATE;
    l_camastid          varchar2(20);
    l_parvalue          NUMBER;
    l_roundtype         varchar2(2);
    l_pitratemethod     varchar2(4);
    l_catype            varchar2(10);
    l_sectype           varchar2(10);
    l_reportdate        DATE;
    l_cadesc            varchar2(4000);
    l_rightoffrate       VARCHAR2(10);
    l_iswft             varchar2(4);
    l_optsymbol         varchar2(20);
    l_addinfo           varchar2(4000);
    l_duedate           DATE;
    l_totransfer        DATE;
    l_tosymbol          varchar2(20);
    l_tocodeid          varchar2(20);
    l_trflimit          varchar2(4);
    l_transfertimes       varchar2(4);
    l_exrate            varchar2(20);
    l_price             number;
    l_typerate          varchar2(5);
    l_devidentvalue     number;
    l_currdate          date;

BEGIN
    plog.setbeginsection (pkgctx, 'create_new_CA');

    l_exrate:='';
    l_typerate:='';
    l_transfertimes := '0';
    l_currdate  :=  getcurrdate;
    -- exrate = ti le 1/1, rightoffrate ti le 100%
    SELECT symbol,refsymbol tosymbol, exrate , rightoffrate, rightoffrate splitrate, null interestrate,
        vsdreference vsdid, EXPRICE,PRICE,
        null effdate,
        CASE WHEN tax = 'GRSS' THEN 'SC'
            WHEN tax = 'NETT' THEN 'IS' ELSE 'NO' END pitratemethod,
        nvl(begindate,datetype) reportdate, DESCRIPTION addinfo,'N' trflimit
    INTO l_symbol, l_tosymbol,l_exrate,l_rightoffrate, l_splitrate, l_interestrate, l_vsdid, l_exprice,l_price, l_actiondate,
        l_pitratemethod, l_reportdate, l_addinfo, l_trflimit
    FROM vsd_mt564_inf WHERE vsdmsgid = pv_vsdtrfid and isgen = 'N';

    SELECT codeid, parvalue, sectype INTO l_codeid, l_parvalue, l_sectype
    FROM sbsecurities WHERE symbol = l_symbol;

    IF l_tosymbol IS NOT NULL then
        SELECT codeid INTO l_tocodeid
        FROM sbsecurities WHERE symbol = l_tosymbol;
    ELSE
        l_tosymbol := '';
    END IF;

    SELECT '0001' || l_codeid || LPAD(seq_camast.nextval, 6, '0')
        INTO l_camastid
    from dual;

    l_iswft := fn_getiswft(l_codeid);
    l_optsymbol := l_symbol;
    IF pv_catype = 'DVCA' THEN
        l_catype := '010';
        l_devintrate:= l_rightoffrate;
        l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_devintrate);
        l_rightoffrate:='';
        l_typerate:='R';
        l_price:=0;
        l_exrate:='';
        l_devidentvalue:=0;
    ELSIF pv_catype = 'DVSE' THEN
        l_catype := '011';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_rightoffrate);
        l_optsymbol := FN_GEN_OPTSYMBOL(l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'),null);
        l_devidentshares:=l_exrate;
        l_rightoffrate:='';
        l_exrate:='';
    ELSIF pv_catype = 'MEET' THEN
        l_catype := '005';
        --l_cadesc := FN_GET_CADESC_NOT_RIGHT_RATE(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'));
        l_price:=0;
        l_devidentshares:=l_exrate;
        l_exrate:='';
        l_rightoffrate:='';
    ELSIF pv_catype = 'XMET' THEN
        l_catype := '005';
        --l_cadesc := FN_GET_CADESC_025(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'));
        l_price:=0;
        l_devidentshares:=l_exrate;
        l_exrate:='';
        l_rightoffrate:='';
    ELSIF pv_catype = 'RHTS' THEN
        l_catype := '014';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_rightoffrate);
        l_optsymbol := FN_GEN_OPTSYMBOL(l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'),null);
        --l_totransfer := to_date(replace(substr(l_addinfo,14 ,14 ), '?_?', '/'), 'DD/MM/RRRR');
        --l_duedate := to_date(replace(substr(l_addinfo,43 ,14 ), '?_?', '/'), 'DD/MM/RRRR');
        l_trflimit:='Y';
        l_transfertimes := '1';
        l_rightoffrate:=l_exrate;
        l_exrate :='1/1';
    ELSIF pv_catype = 'CONV' AND l_sectype = '003' THEN
        l_catype := '017';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_devidentshares);
        l_rightoffrate:='';
    ELSIF pv_catype = 'CONV' AND l_sectype not in ('003','006','222') THEN
        l_catype := '020';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_rightoffrate);
        l_devidentshares:=l_exrate;
        l_rightoffrate:='';
        l_exrate :='';
    elsif pv_catype = 'OTHR' then
        l_catype := '020';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_rightoffrate);
        l_devidentshares:=l_exrate;
        l_rightoffrate:='';
        l_exrate :='';
    ELSIF pv_catype = 'BONU' THEN
        l_catype := '021';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_rightoffrate);
        l_optsymbol := FN_GEN_OPTSYMBOL(l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'),null);
        l_rightoffrate:='';
    elsif pv_catype = 'INTR' THEN
        l_catype := '015';
        --l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_rightoffrate);
        l_interestrate:=l_rightoffrate;
        l_rightoffrate:='';
        l_exrate:='';
        l_price:=0;
    elsif pv_catype = 'PRII' then
        l_catype := '016';
        l_interestrate:=l_rightoffrate;
        l_rightoffrate:='';
        l_exrate:='';
        l_price:=0;
    elsif pv_catype = 'REDM' then
        l_interestrate:='0';
        l_catype := '016';
        l_rightoffrate:='';
        l_exrate:='';
        l_price:=0;
    --T9/2019 CW_PhaseII
    elsif pv_catype = 'DETI' and l_sectype = '011' then
        l_catype := '028';
        l_devintrate:= l_rightoffrate;
        l_rightoffrate:='';
        l_typerate:='R';
        l_devidentvalue:= l_price;
        l_price:=0;
        l_exrate:='';
        l_cadesc := FN_GET_CADESC(l_catype, l_codeid, to_char(l_reportdate, 'DD/MM/RRRR'), l_devintrate);
    --End T9/2019 CW_PhaseII
    END IF;

    BEGIN

    --catype
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'CATYPE' COLUMN_NAME , '' FROM_VALUE, l_catype TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
            --status
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'STATUS' COLUMN_NAME , '' FROM_VALUE, 'P' TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
            --VSDSTATUS
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'VSDSTATUS' COLUMN_NAME , '' FROM_VALUE, 'N' TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        --reportdate
        IF l_reportdate IS NOT NULL THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'REPORTDATE' COLUMN_NAME , '' FROM_VALUE, TO_CHAR(l_reportdate,'DD/MM/RRRR') TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --actiondate
        IF l_actiondate IS NOT NULL THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'ACTIONDATE' COLUMN_NAME , '' FROM_VALUE, TO_CHAR(l_actiondate,'DD/MM/RRRR') TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --price
        IF l_price is not null and l_price <> 0 THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'EXPRICE' COLUMN_NAME , '' FROM_VALUE, l_price TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --devintrate
        IF l_devintrate is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'DEVIDENTRATE' COLUMN_NAME , '' FROM_VALUE, l_devintrate TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --devidentshares
        IF l_devidentshares is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'DEVIDENTSHARES' COLUMN_NAME , '' FROM_VALUE, l_devidentshares TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --rightoffrate
        IF l_rightoffrate is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'RIGHTOFFRATE' COLUMN_NAME , '' FROM_VALUE, l_rightoffrate TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --pitratemethod
        IF l_pitratemethod is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'PITRATEMETHOD' COLUMN_NAME , '' FROM_VALUE, l_pitratemethod TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --EXCODEID + CODEID
        IF l_codeid is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'EXCODEID' COLUMN_NAME , '' FROM_VALUE, l_codeid TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;

            --codeid
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'CODEID' COLUMN_NAME , '' FROM_VALUE,l_codeid TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --vsdid
        IF l_vsdid is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'VSDID' COLUMN_NAME , '' FROM_VALUE, l_vsdid TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --DESCRIPTION
        IF l_cadesc is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'DESCRIPTION' COLUMN_NAME , '' FROM_VALUE, l_cadesc TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --parvalue
        IF l_parvalue is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'PARVALUE' COLUMN_NAME , '' FROM_VALUE, l_parvalue TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --optsymbol
        IF l_optsymbol is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'OPTSYMBOL' COLUMN_NAME , '' FROM_VALUE, l_optsymbol TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --iswft
        IF l_iswft is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
           SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
           null APPROVE_DT, 0 MOD_NUM,'ISWFT' COLUMN_NAME , '' FROM_VALUE, l_iswft TO_VALUE,'ADD' ACTION_FLAG,
           NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
           FROM DUAL;
        END IF;
        --duedate
        IF l_duedate is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'DUEDATE' COLUMN_NAME , '' FROM_VALUE, TO_CHAR(l_duedate,'DD/MM/RRRR') TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --totransfer
        IF l_totransfer is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'TODATETRANSFER' COLUMN_NAME , '' FROM_VALUE, l_totransfer TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --tocodeid
        IF l_tocodeid is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'TOCODEID' COLUMN_NAME , '' FROM_VALUE, l_tocodeid TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --trflimit
        IF l_trflimit is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'TRFLIMIT' COLUMN_NAME , '' FROM_VALUE, l_trflimit TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --transfertimes
        IF l_transfertimes is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'TRANSFERTIMES' COLUMN_NAME , '' FROM_VALUE, l_transfertimes TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --exrate
        IF l_exrate is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'EXRATE' COLUMN_NAME , '' FROM_VALUE, l_exrate TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --typerate
        IF l_typerate is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'TYPERATE' COLUMN_NAME , '' FROM_VALUE, l_typerate TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --interestrate
        IF l_interestrate is not null  THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'INTERESTRATE' COLUMN_NAME , '' FROM_VALUE, l_interestrate TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;
        --devidentvalue
        IF l_devidentvalue is not null and l_devidentvalue <> 0 THEN
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || l_camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, 0 MOD_NUM,'DEVIDENTVALUE' COLUMN_NAME , '' FROM_VALUE, l_devidentvalue TO_VALUE,'ADD' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;
        END IF;

        INSERT INTO camast(autoid, codeid, catype, reportdate, actiondate, exprice, devidentrate, devidentshares, rightoffrate, pitratemethod, status, pstatus,
        camastid, excodeid, vsdid, description, parvalue, optsymbol, iswft, duedate, todatetransfer, tocodeid, vsdstatus, trflimit, transfertimes,exrate,typerate,interestrate,
        devidentvalue)
        SELECT seq_camast.NEXTVAL, l_codeid, l_catype, l_reportdate, l_actiondate, l_price, l_devintrate, l_devidentshares, l_rightoffrate, l_pitratemethod,
        'P', '', l_camastid, l_codeid, l_vsdid, l_cadesc, l_parvalue, l_optsymbol, l_iswft, l_duedate, l_totransfer, l_tocodeid, 'N', l_trflimit, l_transfertimes, l_exrate,l_typerate,l_interestrate,
        l_devidentvalue FROM dual;

        update vsd_mt564_inf set isgen = 'Y' where vsdmsgid = pv_vsdtrfid and isgen = 'N';
        -- Tr?ng th?VSDTRFLOG
        UPDATE vsdtrflog
        SET status = 'C', timeprocess = SYSTIMESTAMP
        WHERE autoid = pv_vsdtrfid;
        plog.error (pkgctx, SQLERRM || DBMS_UTILITY.format_error_backtrace);
        plog.setendsection (pkgctx, 'create_new_CA');
     END;

    plog.setendsection (pkgctx, 'create_new_CA');
    EXCEPTION
    WHEN OTHERS
    THEN
        plog.error (pkgctx, SQLERRM || DBMS_UTILITY.format_error_backtrace);
        plog.setendsection (pkgctx, 'create_new_CA');
END create_new_CA;



PROCEDURE edit_CA(pv_reqid IN NUMBER, pv_vsdtrfid IN number,pv_catype IN varchar2)
IS
    l_symbol            varchar2(20);
    l_codeid            varchar2(20);
    l_devintrate        varchar2(20);
    l_devidentshares    varchar2(20);
    l_splitrate         varchar2(20);
    l_interestrate      varchar2(20);
    l_exprice           NUMBER;
    l_vsdid             varchar2(100);
    l_actiondate        DATE;
    l_camastid          varchar2(20);
    l_parvalue          NUMBER;
    l_roundtype         varchar2(2);
    l_pitratemethod     varchar2(4);
    l_catype            varchar2(10);
    l_sectype           varchar2(10);
    l_reportdate        DATE;
    l_cadesc            varchar2(4000);
    l_rightoffrate       VARCHAR2(10);
    l_iswft             varchar2(4);
    l_status            varchar2(4);
    l_optsymbol         varchar2(20);
    l_addinfo           varchar2(4000);
    l_duedate           DATE;
    l_totransfer        DATE;
    l_tosymbol          varchar2(20);
    l_tocodeid          varchar2(20);
    l_trflimit          varchar2(4);
    l_transfertimes     varchar2(4);
    l_price             number;
    l_exrate            varchar2(20);
    l_MOD_NUM           number;
    l_currdate          date;
BEGIN
    plog.setbeginsection(pkgctx, 'edit_CA');

    l_currdate := getcurrdate;

    SELECT symbol,refsymbol tosymbol, exrate , rightoffrate, rightoffrate splitrate, null interestrate,
        vsdreference vsdid, EXPRICE,PRICE,
        null effdate,
        CASE WHEN tax = 'GRSS' THEN 'SC'
            WHEN tax = 'NETT' THEN 'IS' ELSE 'NO' END pitratemethod,
        nvl(begindate,datetype) reportdate, DESCRIPTION addinfo,'N' trflimit
    INTO l_symbol, l_tosymbol,l_exrate,l_rightoffrate, l_splitrate, l_interestrate, l_vsdid, l_exprice,l_price, l_actiondate,
        l_pitratemethod, l_reportdate, l_addinfo, l_trflimit
    FROM vsd_mt564_inf WHERE vsdmsgid = pv_vsdtrfid and isgen = 'N';

    SELECT codeid, parvalue, sectype INTO l_codeid, l_parvalue, l_sectype
    FROM sbsecurities WHERE symbol = l_symbol;

    IF l_tosymbol IS NOT NULL then
        SELECT codeid INTO l_tocodeid
        FROM sbsecurities WHERE symbol = l_tosymbol;
    ELSE
        l_tocodeid := '';
    END IF;
    --Neu trang thai CA <> Pending, New th?ao loi
    SELECT status
        INTO l_status
    FROM camast WHERE vsdid = l_vsdid;

    SELECT catype
        INTO l_catype
    FROM camast WHERE vsdid = l_vsdid;

    IF l_actiondate IS NULL THEN
        SELECT actiondate INTO l_actiondate FROM camast WHERE vsdid = l_vsdid;
    END IF;

    IF l_trflimit IS NULL THEN
        SELECT trflimit INTO l_trflimit FROM camast WHERE vsdid = l_vsdid;
    END IF;

    if l_status in ('N','P') then
        for rec in(
            select ca.*, DECODE(ca.catype, '010','DVCA','011','DVSE','005','MEET/XMET','014','RHTS','017','CONV','020','CONV/OTHR',
                                   '021','BONU','015','INTR','016','PRII/REDM','028','DETI','---'
                                ) vsdcatype
            from camast ca where vsdid = l_vsdid
        ) loop
            if instr(rec.vsdcatype,pv_catype) = 0 or pv_catype is null then
                    -- Trang thai VSDTRFLOG
                    UPDATE vsdtrflog
                    set status = 'E', errdesc='Loai SKQ khong phu hop voi he thong: STP='||pv_catype||', Flex='||rec.vsdcatype, timeprocess = SYSTIMESTAMP
                    WHERE autoid = pv_vsdtrfid;

                    RETURN;
            end if;

            select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || REC.CAMASTID || '''';
            L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

            --Update nhung thong tin chung

            IF rec.reportdate <> l_reportdate THEN
               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
               SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
               null APPROVE_DT, L_MOD_NUM MOD_NUM,'REPORTDATE' COLUMN_NAME , TO_CHAR(REC.reportdate,'DD/MM/RRRR') FROM_VALUE, TO_CHAR(l_reportdate,'DD/MM/RRRR') TO_VALUE,'EDIT' ACTION_FLAG,
               NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
               FROM DUAL;
            END IF;

            IF rec.codeid <> l_codeid THEN
               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'CODEID' COLUMN_NAME , rec.codeid FROM_VALUE, l_codeid TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                FROM DUAL;
            END IF;

            IF rec.pitratemethod <> l_pitratemethod THEN
               INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
               COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                null APPROVE_DT, L_MOD_NUM MOD_NUM,'PITRATEMETHOD' COLUMN_NAME , rec.pitratemethod FROM_VALUE, l_pitratemethod TO_VALUE,'EDIT' ACTION_FLAG,
                NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                FROM DUAL;
            END IF;

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, L_MOD_NUM MOD_NUM,'VSDSTATUS' COLUMN_NAME , rec.vsdstatus FROM_VALUE, 'E' TO_VALUE,'EDIT' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
            null APPROVE_DT, L_MOD_NUM MOD_NUM,'STATUS' COLUMN_NAME , rec.status FROM_VALUE, 'P' TO_VALUE,'EDIT' ACTION_FLAG,
            NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
            FROM DUAL;

            update camast
            set reportdate = l_reportdate, codeid = l_codeid, pitratemethod = l_pitratemethod,
            vsdstatus = 'E', pstatus = pstatus || status, status = 'P'
            where camastid = rec.camastid;

            IF pv_catype in ('DVCA','DETI') THEN
                l_devintrate:= l_rightoffrate;
                IF rec.devidentrate <> l_devintrate THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'DEVIDENTRATE' COLUMN_NAME , rec.devidentrate FROM_VALUE, l_devintrate TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET devidentrate = l_devintrate
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'DVSE' THEN
                l_devidentshares:=l_exrate;
                IF rec.devidentshares <> l_devidentshares THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'DEVIDENTSHARES' COLUMN_NAME , rec.devidentshares FROM_VALUE, l_devidentshares TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                IF rec.exprice <> l_price THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXPRICE' COLUMN_NAME , rec.exprice FROM_VALUE, l_price TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET devidentshares = l_devidentshares, exprice = l_price
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'MEET' THEN
                l_devidentshares:=l_exrate;
                IF rec.devidentshares <> l_devidentshares THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'DEVIDENTSHARES' COLUMN_NAME , rec.devidentshares FROM_VALUE, l_devidentshares TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET devidentshares = l_devidentshares
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'XMET' THEN
                l_devidentshares:=l_exrate;
                IF rec.devidentshares <> l_devidentshares THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'DEVIDENTSHARES' COLUMN_NAME , rec.devidentshares FROM_VALUE, l_devidentshares TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET devidentshares = l_devidentshares
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'RHTS' THEN
                l_rightoffrate:=l_exrate;
                IF rec.rightoffrate <> l_rightoffrate THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'RIGHTOFFRATE' COLUMN_NAME , rec.rightoffrate FROM_VALUE, l_rightoffrate TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

               IF rec.exprice <> l_price THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXPRICE' COLUMN_NAME , rec.exprice FROM_VALUE, l_price TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET rightoffrate = l_rightoffrate, exprice = l_price
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'CONV' AND l_sectype = '003' THEN
                IF rec.exprice <> l_price THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXPRICE' COLUMN_NAME , rec.exprice FROM_VALUE, l_price TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

               IF rec.exrate <> l_exrate THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXRATE' COLUMN_NAME , rec.exrate FROM_VALUE, l_exrate TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET exprice = l_price, exrate = l_exrate
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'CONV' AND l_sectype not in ('003','006','222') THEN
                l_devidentshares:=l_exrate;
                IF rec.devidentshares <> l_devidentshares THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'DEVIDENTSHARES' COLUMN_NAME , rec.devidentshares FROM_VALUE, l_devidentshares TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

               IF rec.exprice <> l_price THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXPRICE' COLUMN_NAME , rec.exprice FROM_VALUE, l_price TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET devidentshares = l_devidentshares, exprice = l_price
                WHERE vsdid = l_vsdid;
            elsif pv_catype = 'OTHR' then
                l_devidentshares:=l_exrate;
                IF rec.devidentshares <> l_devidentshares THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'DEVIDENTSHARES' COLUMN_NAME , rec.devidentshares FROM_VALUE, l_devidentshares TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

               IF rec.exprice <> l_price THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXPRICE' COLUMN_NAME , rec.exprice FROM_VALUE, l_price TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET devidentshares = l_devidentshares, exprice = l_price
                WHERE vsdid = l_vsdid;
            ELSIF pv_catype = 'BONU' THEN
                IF rec.exprice <> l_price THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXPRICE' COLUMN_NAME , rec.exprice FROM_VALUE, l_price TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

               IF rec.exrate <> l_exrate THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'EXRATE' COLUMN_NAME , rec.exrate FROM_VALUE, l_exrate TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET exprice = l_price, exrate = l_exrate
                WHERE vsdid = l_vsdid;
            elsif pv_catype = 'INTR' THEN
                l_interestrate:=l_rightoffrate;
                IF rec.interestrate <> l_interestrate THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'INTERESTRATE' COLUMN_NAME , rec.interestrate FROM_VALUE, l_interestrate TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET interestrate=l_interestrate
                WHERE vsdid = l_vsdid;
            elsif pv_catype = 'PRII' then
                l_interestrate:=l_rightoffrate;
                IF rec.interestrate <> l_interestrate THEN
                    INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                    COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
                    SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
                    null APPROVE_DT, L_MOD_NUM MOD_NUM,'INTERESTRATE' COLUMN_NAME , rec.interestrate FROM_VALUE, l_interestrate TO_VALUE,'EDIT' ACTION_FLAG,
                    NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
                    FROM DUAL;
                END IF;

                UPDATE camast
                SET interestrate=l_interestrate
                WHERE vsdid = l_vsdid;
            /*elsif pv_catype = 'REDM' then
                UPDATE camast
                SET reportdate = l_reportdate, codeid = l_codeid, vsdstatus = 'E', pitratemethod = l_pitratemethod
                WHERE vsdid = l_vsdid;*/
            END IF;
        END LOOP;
    else
        UPDATE vsdtrflog
        SET status = 'E', errdesc='Trang thai SKQ khong hop le! Status SKQ dang la '|| l_status, timeprocess = SYSTIMESTAMP
        WHERE autoid = pv_vsdtrfid;

        RETURN;
    end if;

    -- Trang thai VSDTRFLOG
    UPDATE vsdtrflog
    SET status = 'C', timeprocess = SYSTIMESTAMP
    WHERE autoid = pv_vsdtrfid;

    update vsd_mt564_inf set isgen = 'Y' where vsdmsgid = pv_vsdtrfid and isgen = 'N';

    plog.setendsection (pkgctx, 'edit_CA');
    EXCEPTION
    WHEN OTHERS
    THEN
        plog.error (pkgctx, SQLERRM || DBMS_UTILITY.format_error_backtrace);
        plog.setendsection (pkgctx, 'edit_CA');
END edit_CA;


PROCEDURE cancel_CA(pv_reqid IN NUMBER, pv_vsdtrfid IN number)
IS
    l_vsdid             varchar2(100);
    l_status            varchar2(10);
    l_count number;
    L_MOD_NUM           number;
    l_currdate          date;
BEGIN
    plog.setbeginsection (pkgctx, 'cancel_CA');

        l_currdate:= getcurrdate;

        SELECT vsdmsgid
        INTO l_vsdid
        FROM vsd_mt564_inf WHERE vsdmsgid = pv_vsdtrfid and isgen = 'N';
    --Neu trang thai CA <> Pending, New th?ao loi
    SELECT status
        INTO l_status
    FROM camast WHERE vsdid = l_vsdid;

    IF l_status NOT IN ('P', 'N') then

        -- Trang thai VSDTRFLOG
        UPDATE vsdtrflog
        SET status = 'E', errdesc='Trang thai SKQ khong hop le! Status SKQ dang la '|| l_status, timeprocess = SYSTIMESTAMP
        WHERE autoid = pv_vsdtrfid;

        RETURN;
    END IF;

    for rec in(
            select * from camast where vsdid = l_vsdid
        ) loop


        select MAX(MOD_NUM) INTO L_MOD_NUM from maintain_log where TABLE_NAME = 'CAMAST' and RECORD_KEY = 'CAMASTID = ''' || REC.CAMASTID || '''';
        L_MOD_NUM:= nvl(L_MOD_NUM,-1) + 1;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
        COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
        null APPROVE_DT, L_MOD_NUM MOD_NUM,'STATUS' COLUMN_NAME , rec.status FROM_VALUE, 'R' TO_VALUE,'EDIT' ACTION_FLAG,
        NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
        FROM DUAL;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
        COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        SELECT 'CAMAST' TABLE_NAME,'CAMASTID = ''' || rec.camastid || '''' RECORD_KEY,'0000' MAKER_ID,l_currdate MAKER_DT,'Y' APPROVE_RQD,null APPROVE_ID,
        null APPROVE_DT, L_MOD_NUM MOD_NUM,'VSDSTATUS' COLUMN_NAME , rec.vsdstatus FROM_VALUE, 'D' TO_VALUE,'EDIT' ACTION_FLAG,
        NULL CHILD_TABLE_NAME,NULL CHILD_RECORD_KEY,to_char(sysdate,'hh24:mm:ss') MAKER_TIME
        FROM DUAL;

        UPDATE camast SET pstatus = pstatus || status, status = 'R', vsdstatus = 'D'
        WHERE camastid = rec.camastid;

    end loop;


    update vsd_mt564_inf set isgen = 'Y' where vsdmsgid = pv_vsdtrfid and isgen = 'N';

    -- Trang thai VSDTRFLOG
    UPDATE vsdtrflog
    SET status = 'C', timeprocess = SYSTIMESTAMP
    WHERE autoid = pv_vsdtrfid;

    plog.setendsection (pkgctx, 'cancel_CA');
    EXCEPTION
    WHEN OTHERS
    THEN
        plog.error (pkgctx, SQLERRM || DBMS_UTILITY.format_error_backtrace);
        plog.setendsection (pkgctx, 'cancel_CA');
END cancel_CA;


begin
  -- Initialization
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('cspks_vsd',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));
end cspks_vsd;
/
