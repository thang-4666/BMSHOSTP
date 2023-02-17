SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_vsd AS
  procedure sp_auto_gen_vsd_req;
  procedure sp_gen_vsd_req(pv_autoid number);
  procedure sp_auto_create_message;
  procedure sp_create_message(f_reqid in number);
  function  fn_get_vsd_request(f_reqid in number) return varchar;

  procedure sp_receive_message(f_msgcontent in clob);
  procedure sp_parse_message(f_reqid in number);

  procedure pr_auto_process_message;
  procedure auto_complete_confirm_msg(pv_reqid number, pv_cftltxcd varchar2, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_process_inf_msg(pv_autoid number, pv_funcname varchar2, pv_reqid number, p_err_code out varchar2);
  procedure auto_complete_inf_msg(pv_autoid number, pv_funcname varchar2, pv_reqid number, p_err_code out varchar2);

  procedure pr_receive_par_by_xml(pv_filename in varchar2, pv_filecontent in clob);
  procedure pr_receive_csv_by_xml(pv_filename in varchar2, pv_filecontent in clob);

  PROCEDURE auto_call_txpks_2231(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2246(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2201(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2294(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);

  PROCEDURE auto_call_txpks_2265(pv_reqid    NUMBER, pv_vsdtrfid NUMBER, p_err_code  OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2266(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2245(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2226(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2276(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2248(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  procedure auto_call_txpks_0059_2(pv_reqid number,pv_custodycd varchar2, pv_SENDTOVSD varchar2, pv_reftxnum varchar2,p_err_code out varchar2);
  PROCEDURE auto_call_txpks_2290(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_3355(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);

  --HSX04
  procedure auto_call_func_0035(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_txpks_0012(pv_reqid number, pv_vsdtrfid number, p_err_code out VARCHAR2);
  procedure auto_call_func_cfrej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_txpks_0004(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_txpks_0018(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_txpks_0103(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2, p_confirm varchar2);
  procedure auto_call_func_0059(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_0060(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure pr_process_mt598_539 (p_funcname IN VARCHAR2, p_reqid IN NUMBER, p_trflogid IN NUMBER);
  --END HSX04

  procedure auto_call_func_pending(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_complete(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);

  --cam co
  PROCEDURE auto_call_txpks_2236(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2251(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2257(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_2253(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);

  PROCEDURE auto_call_txpks_3313(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  procedure auto_call_func_567(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_3335_rej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  PROCEDURE auto_call_txpks_3340(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  PROCEDURE auto_call_txpks_3370(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  procedure auto_call_func_3357_rej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_3357_conf(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_3358_rej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_3358_conf(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  PROCEDURE auto_call_txpks_3328(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  procedure auto_call_func_3360(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  PROCEDURE auto_call_func_3385(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2);
  procedure pr_process_mt998_539 (p_funcname IN VARCHAR2, p_reqid IN NUMBER, p_trflogid IN NUMBER);
  --procedure auto_call_txpks_3311(pv_reqid    number, pv_vsdtrfid number,p_err_code  out varchar2);
  procedure auto_call_func_3370(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_txpks_3353(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_func_3358(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2);
  procedure auto_call_txpks_0067(pv_reqid number, pv_vsdtrfid number);
  procedure auto_call_txpks_8816(pv_reqid number, pv_vsdtrfid number);

end cspks_vsd;
/


CREATE OR REPLACE PACKAGE BODY cspks_vsd as

  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  procedure sp_auto_gen_vsd_req as
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
    l_vsdmode            varchar2(10);
    l_vsdtxreq           number;
    v_dt_txdate          date;
    v_notes              varchar2(1000);
    v_afacctno_field     varchar2(100);
    v_afacctno           varchar2(10);
    v_txamt_field        varchar2(100);
    v_txamt              number(20, 4);
    v_value              varchar2(1000);
    v_chartxdate         varchar2(50);
    v_extcmdsql          varchar2(2000);
    v_notes_field        varchar2(10);
    c0                   v_curtyp;
    v_log_msgacct        varchar2(50);
    v_fldrefcode_field   varchar2(50);
    v_refcode            varchar2(100);
    v_brid               varchar2(4);
    v_tlid               varchar2(4);
    l_vsdbiccode         varchar2(11);
    l_biccode            varchar2(11);
    v_objtype            VARCHAR2(1);
    v_fldkeysend         VARCHAR2(50);
    l_valuesend          VARCHAR2(50);
    v_currdate           DATE;
    v_vsdmt              varchar2(4);
    v_trftype            varchar2(2);
  begin
    plog.setbeginsection(pkgctx, 'sp_gen_vsd_req');
    l_vsdmode := cspks_system.fn_get_sysvar('SYSTEM', 'VSDMOD');
    v_currdate := getcurrdate;

    select vsd.trfcode, vsd.tltxcd, vsd.txnum, vsd.txdate, vsd.msgacct, vsd.brid, vsd.tlid,vc.vsdmt,vc.trftype
      into v_trfcode,
           v_tltxcd,
           v_txnum,
           v_dt_txdate,
           v_log_msgacct,
           v_brid,
           v_tlid,
           v_vsdmt,
           v_trftype
      from vsd_process_log vsd, vsdtrfcode vc
     where vsd.trfcode = vc.trfcode
       AND vsd.tltxcd = vc.tltxcd
       AND vc.Type ='REQ'
       AND autoid = pv_autoid;

    select biccode, vsdbiccode
      into l_biccode, l_vsdbiccode
      from vsdbiccode
     WHERE trftype = v_trftype;

    if l_vsdmode = 'A' then
      -- ket noi tu dong
      v_chartxdate := to_char(v_dt_txdate, 'DD/MM/RRRR');
      -- lay du lieu trong vsdtxmap
      BEGIN
        select map.fldacctno,
               map.amtexp,
               map.fldnotes,
               nvl(map.fldrefcode, 'a'),
               map.objtype,
               map.fldkeysend,
               map.valuesend
          into v_afacctno_field,
               v_txamt_field,
               v_notes_field,
               v_fldrefcode_field,
               v_objtype,
               v_fldkeysend,
               l_valuesend
          from vsdtxmap map
         where map.objname = v_tltxcd
           and map.trfcode = v_trfcode;
      exception
        when no_data_found then
          plog.error(pkgctx,
                    'TLTXCD:' || v_tltxcd || '::TRFCODE:' || v_trfcode ||
                    ':: not found in VSDTXMAP');
          plog.setendsection(pkgctx, 'sp_gen_vsd_req');
          return;
      end;

      --Giao dich co lua chon khong sinh dien
      IF NOT instr(fn_eval_amtexp(v_txnum, v_chartxdate, v_fldkeysend),l_valuesend) > 0 THEN
         plog.error(pkgctx, 'Khong sinh dien gui VSD. v_txnum='||v_txnum||', v_chartxdate='||v_chartxdate||', v_fldkeysend='||v_fldkeysend||', l_valuesend='||l_valuesend);
         plog.setendsection(pkgctx, 'sp_gen_vsd_req');
         RETURN;
      END IF;

      --Dien ko can check khoi luong khai bao vsdtxmap.objtype = I
      if v_objtype = 'T' then
        v_txamt := fn_eval_amtexp(v_txnum,
                                  v_chartxdate,
                                  v_txamt_field);
        if v_txamt = 0 then
          -- neu so luong bang 0, khong sinh request len VSD
          plog.error(pkgctx,
                    'txnum:' || v_txnum || '::txdate:' || v_chartxdate ||
                    '::txamt_field:' || v_txamt_field || '::txamt = ' ||
                    v_txamt || ':: not gen msg request to VSD');
          plog.setendsection(pkgctx, 'sp_gen_vsd_req');
          return;
        end if;
      end if;
      v_afacctno := fn_eval_amtexp(v_txnum,
                                   v_chartxdate,
                                   v_afacctno_field);
      v_txamt    := fn_eval_amtexp(v_txnum,
                                   v_chartxdate,
                                   v_txamt_field);
      v_notes    := fn_eval_amtexp(v_txnum,
                                   v_chartxdate,
                                   v_notes_field);
      if v_fldrefcode_field = 'a' then
        v_refcode := v_chartxdate || v_txnum;
      else
        v_refcode := fn_eval_amtexp(v_txnum,
                                    v_chartxdate,
                                    v_fldrefcode_field);
      end if;

      -- insert vao VSDTXREQ
      --select seq_vsdtxreq.nextval into l_vsdtxreq from dual;
      select to_number(to_char(v_currdate,'RRRRMMDD')||seq_vsdtxreq.nextval) into l_vsdtxreq from dual;
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
         msgstatus,
         notes,
         rqtype,
         status,
         msgacct,
         process_id,
         brid,
         tlid)
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
         'P',
         v_notes,
         'A',
         'P',
         v_log_msgacct,
         pv_autoid,
         v_brid,
         v_tlid);

      -- insert vao VSDTXREQDTL
      -- Header
      -- Biccode
      insert into vsdtxreqdtl
        (autoid, reqid, fldname, cval, nval, convert, maxlength)
      values
        (seq_crbtxreqdtl.nextval,
         l_vsdtxreq,
         'BICCODE',
         l_biccode,
         0,
         null,
         null);
      -- VSD Biccode
      insert into vsdtxreqdtl
        (autoid, reqid, fldname, cval, nval, convert, maxlength)
      values
        (seq_crbtxreqdtl.nextval,
         l_vsdtxreq,
         'VSDCODE',
         l_vsdbiccode,
         0,
         null,
         null);

      -- Detail
      for rc in (select fldname, fldtype, amtexp, cmdsql, convert, decode (fldtype,'C',maxlength,null) maxlength
                   from vsdtxmapext mst
                  where mst.objname = v_tltxcd
                    and trfcode = v_trfcode) loop
        begin
          if not rc.amtexp is null then
            v_value := fn_eval_amtexp(v_txnum,
                                      v_chartxdate,
                                      rc.amtexp,
                                      rc.fldtype);
          end if;
          if not rc.cmdsql is null then
            begin
              v_extcmdsql := replace(rc.cmdsql, '<$FILTERID>', v_value);
              begin
                open c0 for v_extcmdsql;
                fetch c0
                  into v_value;
                close c0;
              exception
                when others then
                  v_value := '0';
              end;
            end;
          end if;

          if rc.fldtype = 'D' then
             v_value := to_char(to_date(v_value, 'DD/MM/RRRR'), 'YYYYMMDD');
          ELSIF rc.fldtype = 'N' THEN -- Format so theo quy dinh cua VSD
             v_value := CASE WHEN MOD(v_value, 1) = 0 THEN v_value || ','
                             ELSE v_value END;
         ELSIF rc.fldtype = 'F' THEN -- lay ngay theo dinh dang YYMMDD
             v_value := to_char(to_date(v_value, 'DD/MM/RRRR'), 'YYMMDD');
          end if;

          insert into vsdtxreqdtl
            (autoid, reqid, fldname, cval, nval, convert, maxlength)
            select seq_crbtxreqdtl.nextval,
                   l_vsdtxreq,
                   rc.fldname,
                   v_value,
                   0,
                   rc.convert,
                   rc.maxlength
              from dual;
        end;
      end loop;
      --HSX04
      IF v_tltxcd IN ('0035','0017') THEN
        UPDATE cfmast SET nsdstatus = 'S' WHERE custodycd=v_log_msgacct;
      ELSIF v_tltxcd IN ('2275') THEN
        UPDATE sereceived SET reqid = l_vsdtxreq WHERE autoid = v_refcode;
      ELSIF v_tltxcd IN ('2235','2238') AND v_vsdmt IN ('540','542') THEN -- dien cam co
        UPDATE SEMORTAGE SET REQID = l_vsdtxreq WHERE autoid = v_refcode;
      ELSIF v_tltxcd IN ('2235','2238') AND v_vsdmt IN ('504','505') THEN -- dien cam co
        UPDATE SEMORTAGE SET REQID2ND = l_vsdtxreq WHERE autoid = v_refcode;
      END IF;
      --END HSX04

    end if;
    plog.setendsection(pkgctx, 'sp_gen_vsd_req');
  exception
    when others then
      plog.error(pkgctx, 'pv_autoid='||pv_autoid||'. Error: '||sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'sp_gen_vsd_req');
  end sp_gen_vsd_req;

  procedure sp_auto_create_message as
    cursor v_cursor is
      select reqid, objname, trfcode,OBJKEY,TXDATE
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

  procedure sp_create_message(f_reqid in number) as
    v_request   varchar2(5000);
    v_count     number;
    l_sqlerrnum varchar2(200);
  begin
    --Neu message da tao hoac khoi luong bang 0 (ngoai tru msg mo tai khoan th?o tao message)
    select count(*)
      into v_count
      from vsdtxreq
     where reqid = f_reqid
       and msgstatus = 'P';

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
      l_sqlerrnum := substr(sqlerrm|| dbms_utility.format_error_backtrace, 200);
      insert into log_err
        (id, date_log, position, text)
      values
        (seq_log_err.nextval, sysdate, 'sp_create_message', l_sqlerrnum);
  end sp_create_message;

  function fn_get_vsd_request(f_reqid in number) return varchar as
    v_trfcode varchar2(60);
    v_field   varchar2(1180);
    v_request varchar2(4000);
    v_reqtime VARCHAR2(20);

    cursor v_cursor is
      select fldname,
             (case
               when (nval <> 0) THEN
                to_char(nval)
               else
                translate(cval, 'A$', 'A')
             end) fldval,
             XMLElement("fldval",(case
               when (nval <> 0) then
                to_char(nval)
               else
                translate(cval, 'A$', 'A')
             end)).getstringval() xmlval,
             convert,maxlength
        from vsdtxreqdtl
       where reqid = f_reqid;
    v_row v_cursor%rowtype;
  begin
    plog.setbeginsection(pkgctx, 'fn_get_vsd_request');
    --read header
    select trfcode into v_trfcode from vsdtxreq where reqid = f_reqid;
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
        end;
      else
        /*v_field := '<field><fldname convert="' || v_row.convert || '">' ||
                   v_row.fldname || '</fldname>' || v_row.xmlval ||
                   '</field>';*/
       if (v_row.maxlength is null ) then
          v_field := '<field><fldname convert="' || v_row.convert || '">' ||
                   v_row.fldname || '</fldname>' || v_row.xmlval ||
                   '</field>';
        else
          v_field := '<field><fldname convert="' || v_row.convert ||'" maxlength="'||v_row.maxlength ||'">' ||
                   v_row.fldname || '</fldname>' || v_row.xmlval ||
                   '</field>';
        end if;
      end if;
      v_request := v_request || v_field;
    end loop;

    -- Gen req id
    v_request := v_request || '<field><fldname convert="">REQID</fldname><fldval>' || f_reqid || '</fldval></field>';

    -- Gen req time
    SELECT to_char(SYSDATE, 'RRRRMMDDHH24MISS') INTO v_reqtime FROM dual;
    v_request := v_request || '<field><fldname convert="">REQTIME</fldname><fldval>' || v_reqtime || '</fldval></field>';

    v_request := '<root><txcode funcname="' || v_trfcode || '" referenceid="' || f_reqid || '"><detail>' || v_request || '</detail></txcode></root>';
    plog.setendsection(pkgctx, 'fn_get_vsd_request');
    return v_request;
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_get_vsd_request');
      return '';
  end fn_get_vsd_request;

  procedure sp_receive_message(f_msgcontent in clob) as
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
    v_funcname         varchar2(60);
    v_sender           varchar2(60);
    v_msgtype          varchar2(60);
    v_vsdmsgid         varchar2(60);
    v_referenceid      varchar2(80);
    v_vsdfinfile       varchar2(60);
    v_errdesc          varchar2(1000);
    v_msgfields        varchar2(5000);
    v_msgbody          varchar2(5000);
    v_trflogid         number;
    v_count            number;
    v_autoconf         varchar2(1);
    l_count            number;
    v_currdate         date;
  begin
    plog.setbeginsection(pkgctx, 'sp_parse_message');
    v_currdate  := getcurrdate;
    select count(autoid)
      into v_count
      from vsdmsglog
     where autoid = f_reqid
       and status = 'P';
    if v_count > 0 then
      begin
        --Get message header information
        v_trflogid := seq_vsdtrflog.nextval;
          select trim(x.msgbody.extract('//root/txcode/@funcname').getstringval())
              into v_funcname
          from vsdmsglog x
          where autoid = f_reqid;

        select trim(x.msgbody.extract('//root/txcode/@funcname').getstringval()),
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
          into v_funcname, v_sender, v_msgtype, v_vsdmsgid, v_referenceid,
               v_vsdfinfile, v_msgfields, v_msgbody, v_errdesc
          from vsdmsglog x
         where autoid = f_reqid;
        -- PhuongHT edit
        if instr(v_funcname, '.NAK') > 0 or instr(v_funcname, '.ACK') > 0 or instr(v_funcname, '596.') > 0 or instr(v_funcname, '996.') > 0 or instr(v_funcname, '548.') > 0  then

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
               set /*msgstatus = 'N',*/ vsd_err_msg = v_errdesc
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
          elsif l_count = 0 then
            -- chua dung den
            v_autoconf := 'N';
          else
            -- su dung chung cho hai nghiep vu: can link voi VSDTXREQ de biet loai yeu cau
            BEGIN
               select trf.autoconf
                into v_autoconf
                from vsdtrfcode trf, vsdtxreq req
               where req.reqid = v_referenceid
                 and trf.trfcode = v_funcname
                 and trf.status = 'Y'
                 and trf.type in ('CFO', 'CFN','INFO')
                 and req.objname = trf.reqtltxcd;
             EXCEPTION WHEN OTHERS THEN
                SELECT AUTOCONF
                  INTO V_AUTOCONF
                  FROM VSDTRFCODE
                 WHERE STATUS = 'Y'
                   AND TRFCODE = V_FUNCNAME
                   AND TYPE = 'INF';
             END;
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
          select seq_vsdtrflogdtl.nextval, v_trflogid, xt.fldname,
                 replace(xt.fldval, ','), xt.flddesc
            from (select * from vsdmsglog where autoid = f_reqid) mst,
                 xmltable('root/txcode/detail/field' passing mst.msgbody
                           columns fldname varchar2(200) path 'fldname',
                           fldval varchar2(4000) path 'fldval',
                           flddesc varchar2(1000) path 'flddesc') xt
            where xt.fldname not in ('DETAIL598');

        if v_funcname IN ('598.539..') THEN
          pr_process_mt598_539(v_funcname, f_reqid, v_trflogid);
        end if;

        IF v_funcname IN ('998.539') THEN
           pr_process_mt998_539(v_funcname, f_reqid, v_trflogid);
        END IF;

        insert into vsdtrflog
          (autoid, sender, msgtype, funcname, refmsgid, referenceid,
           finfilename, timecreated, timeprocess, status, autoconf, errdesc)
          select v_trflogid, v_sender, v_msgtype, v_funcname, v_vsdmsgid,
                 v_referenceid, v_vsdfinfile, systimestamp, null, 'P',
                 v_autoconf, v_errdesc
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

  PROCEDURE pr_auto_process_message
  IS
    l_count       NUMBER;
    l_err_code    VARCHAR2(50);
    l_cf_msgtype  VARCHAR2(5);
    v_tltxcd      VARCHAR2(20);
    v_rejtltxcd   VARCHAR2(20);
    v_reqid       NUMBER;
    v_curdate     DATE;
    v_condition   VARCHAR2(20);
    v_isprocess   BOOLEAN;
    l_autoconf    VARCHAR2(100);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_auto_process_message');
    IF cspks_system.fn_get_sysvar('SYSTEM', 'VSDMOD') <> 'A' THEN
       plog.setendsection(pkgctx, 'pr_auto_process_message');
       RETURN; -- not connect
    end if;

    IF cspks_system.fn_get_sysvar('SYSTEM', 'HOSTATUS') = '0' THEN
      plog.setendsection(pkgctx, 'pr_auto_process_message');
      RETURN; -- host inactive
    END IF;

    FOR rec IN (select * from vsdtrflog WHERE status = 'P' ORDER BY autoid) LOOP
       l_err_code  := '0';
       v_isprocess := TRUE;
       l_cf_msgtype := '';
       l_autoconf:='Y';
       BEGIN
          SELECT COUNT(*) INTO l_count FROM vsdtxreq WHERE reqid = rec.referenceid;
          IF l_count > 0 THEN
             -- Uu tien xy ly function duoc khai bao nghiep vu
             SAVEPOINT bf_multi_transaction;

             FOR rec0 IN (
               SELECT trf.* FROM vsdtrfcode trf, vsdtxreq req
               WHERE req.reqid = rec.referenceid
                 AND trf.trfcode = rec.funcname
                 AND trf.status = 'Y'
                 AND trf.type in ('CFO','CFN','INF','ACK','NAK','INFO')
                 AND nvl(req.objname, 'a') = nvl(trf.reqtltxcd, 'a')
             ) LOOP
                l_count := 0;
                l_cf_msgtype := rec0.type;
                l_autoconf := rec.autoconf;
                -- Dien CFO, CFN, ACK, NAK xu ly theo tltxcd
                IF rec0.type IN ('CFO', 'CFN','ACK','NAK') AND rec0.tltxcd IS NOT NULL AND l_autoconf = 'Y' THEN
                   auto_complete_confirm_msg(rec.referenceid,
                                             rec0.tltxcd,
                                             rec.autoid,
                                             l_err_code
                   );

                -- Dien thong bao xu ly theo function
                ELSIF rec0.type = 'INFO' THEN
                   auto_process_inf_msg(rec.autoid,
                                      rec.funcname,
                                      rec.referenceid,
                                      l_err_code);


                   IF nvl(l_err_code, '0') = '0'  AND l_autoconf = 'Y' THEN
                    auto_complete_inf_msg(rec.autoid,
                                          rec.funcname,
                                          rec.referenceid,
                                          l_err_code
                    );

                    EXIT;
                   END IF;
                ELSIF rec0.type = 'INF' AND l_autoconf = 'Y' THEN
                   auto_complete_inf_msg(rec.autoid,
                                          rec.funcname,
                                          rec.referenceid,
                                          l_err_code);

                    EXIT;
                END IF;
                -- Cap nhat xu ly loi neu co nghiep vu nao do k thuc hien dc
                IF l_err_code <> '0' THEN
                   EXIT;
                END IF;
             END LOOP;
             -- Neu nghiep vu duoc khai bao da dc xy ly thi cap nhat trang thai
             IF l_count = '0' THEN
                IF nvl(l_err_code, '0') <> '0' THEN
                   ROLLBACK TO bf_multi_transaction;
                   UPDATE vsdtxreq SET msgstatus = 'E', status = 'E', boprocess_err = l_err_code
                   WHERE reqid = rec.referenceid;

                   v_isprocess := FALSE;
                ELSIF l_autoconf = 'N' THEN
                   UPDATE vsdtxreq SET msgstatus = 'C' WHERE reqid = rec.referenceid
                   AND msgstatus IN ('A','P');
                ELSIF l_cf_msgtype = 'NAK' THEN
                   UPDATE vsdtxreq SET msgstatus = 'N', status = 'R', vsd_err_msg = rec.errdesc
                   WHERE reqid = rec.referenceid;

                ELSIF l_cf_msgtype = 'CFO' THEN
                   UPDATE vsdtxreq SET msgstatus = 'F', status = 'C'
                   WHERE reqid = rec.referenceid;

                ELSIF l_cf_msgtype = 'CFN' THEN
                   UPDATE vsdtxreq SET msgstatus = 'R', status = 'R', vsd_err_msg = rec.errdesc
                   WHERE reqid = rec.referenceid;

                ELSIF l_cf_msgtype = 'ACK' THEN
                  UPDATE vsdtxreq SET msgstatus = 'A', vsd_err_msg = rec.errdesc
                  WHERE reqid = rec.referenceid AND msgstatus = 'S';
                END IF;
             ELSE -- Xu ly them cac function dac biet
                SELECT trf.tltxcd, trf.rejtltxcd INTO v_tltxcd, v_rejtltxcd
                FROM vsdtxreq req, vsdtrfcode trf
                WHERE req.reqid = rec.referenceid
                  AND req.trfcode = trf.trfcode
                  AND trf.tltxcd = req.objname;


                IF rec.funcname LIKE '%.ACK' THEN
                  UPDATE vsdtxreq SET msgstatus = 'A', vsd_err_msg = rec.errdesc
                  WHERE reqid = rec.referenceid AND msgstatus = 'S';

                ELSIF rec.funcname LIKE '%.NAK' THEN
                  UPDATE vsdtxreq SET msgstatus = 'N', status = 'R', vsd_err_msg = rec.errdesc
                  WHERE reqid = rec.referenceid;

                ELSIF rec.funcname = '596.' THEN
                   SELECT fldval INTO v_condition FROM vsdtrflogdtl
                   WHERE refautoid = rec.autoid AND fldname = 'MSGTYPE';

                   IF ( v_condition LIKE '%ERRC%' or  v_condition LIKE '%CANC%') AND v_rejtltxcd IS NOT NULL THEN
                      auto_complete_confirm_msg(rec.referenceid,
                                                v_rejtltxcd,
                                                rec.autoid,
                                                l_err_code
                      );

                   ELSIF v_condition LIKE '%OK%'  AND v_tltxcd IS NOT NULL THEN
                      auto_complete_confirm_msg(rec.referenceid,
                                                v_tltxcd,
                                                rec.autoid,
                                                l_err_code
                      );
                   END IF;

                   IF nvl(l_err_code, '0') <> '0' THEN
                      UPDATE vsdtxreq SET msgstatus = 'E', status = 'E', boprocess_err = l_err_code
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition LIKE '%ERRC%' THEN
                      UPDATE vsdtxreq SET msgstatus = 'R', status = 'R', vsd_err_msg = rec.errdesc
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition LIKE '%CANC%' THEN
                      UPDATE vsdtxreq SET msgstatus = 'R', status = 'R', vsd_err_msg = rec.errdesc
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition LIKE '%OK%' THEN
                      UPDATE vsdtxreq SET msgstatus = 'F', status = 'C'
                      WHERE reqid = rec.referenceid;

                   ELSE
                      v_isprocess := FALSE;
                   END IF;

                ELSIF rec.funcname = '548.' THEN
                   SELECT fldval INTO v_condition FROM vsdtrflogdtl
                   WHERE refautoid = rec.autoid AND fldname = 'STATUS';

                   IF v_condition IN ('REJT', 'PENF','NMAT','DEND') AND v_rejtltxcd IS NOT NULL THEN
                      auto_complete_confirm_msg(rec.referenceid,
                                                v_rejtltxcd,
                                                rec.autoid,
                                                l_err_code
                      );
                   END IF;

                   IF nvl(l_err_code, '0') <> '0' THEN
                      UPDATE vsdtxreq SET msgstatus = 'E', status = 'E', boprocess_err = l_err_code
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition IN ('REJT', 'PENF','NMAT','DEND') THEN
                      UPDATE vsdtxreq SET msgstatus = 'R', status = 'R', vsd_err_msg = rec.errdesc
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition IN ('PEND','PPRC') THEN
                      UPDATE vsdtxreq SET msgstatus = 'A', vsd_err_msg = rec.errdesc
                      WHERE reqid = rec.referenceid AND msgstatus = 'S';
                   ELSE
                      v_isprocess := FALSE;
                   END IF;
                ELSE
                   v_isprocess := FALSE;
                END IF;
             END IF;
          ELSIF rec.funcname = '548.' THEN
                   SELECT fldval INTO v_condition FROM vsdtrflogdtl
                   WHERE refautoid = rec.autoid AND fldname = 'STATUS';

                   IF v_condition IN ('REJT', 'PENF','NMAT','DEND') AND v_rejtltxcd IS NOT NULL THEN
                      auto_complete_confirm_msg(rec.referenceid,
                                                v_rejtltxcd,
                                                rec.autoid,
                                                l_err_code
                      );
                   END IF;

                   IF nvl(l_err_code, '0') <> '0' THEN
                      UPDATE vsdtxreq SET msgstatus = 'E', status = 'E', boprocess_err = l_err_code
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition IN ('REJT', 'PENF','NMAT','DEND') THEN
                      UPDATE vsdtxreq SET msgstatus = 'R', status = 'R', vsd_err_msg = rec.errdesc
                      WHERE reqid = rec.referenceid;

                   ELSIF v_condition IN ('PEND','PPRC') THEN
                      UPDATE vsdtxreq SET msgstatus = 'A', vsd_err_msg = rec.errdesc
                      WHERE reqid = rec.referenceid AND msgstatus = 'S';
                   ELSE
                      v_isprocess := FALSE;
                   END IF;
          ELSE -- Xu ly dien info
             l_cf_msgtype := 'INF';

             SELECT COUNT(*) INTO l_count FROM vsdtrfcode
             WHERE status = 'Y' AND TYPE = 'INF' AND trfcode = rec.funcname;

             IF l_count > 0 THEN
                SELECT tltxcd INTO v_tltxcd FROM vsdtrfcode
                WHERE TYPE = 'INF' AND status = 'Y' AND trfcode = rec.funcname;
                v_reqid   := seq_vsdtxreq.nextval;
                v_curdate := getcurrdate;

                -- sinh du lieu vao bang request
                INSERT INTO vsdtxreq (reqid, objtype, objname, objkey, trfcode, refcode, txdate,
                       affectdate,createdate, afacctno, txamt, bankcode, bankacct, msgstatus,
                       notes, rqtype, status, msgacct, process_id, brid, tlid)
                VALUES (v_reqid, 'T', v_tltxcd, '', rec.funcname, NULL, v_curdate,
                       v_curdate,SYSDATE, NULL, 0, 'VSD', cspks_system.fn_get_sysvar('SYSTEM', 'COMPANYNAME'), 'C',
                       'Message received from VSD', 'A', 'P', NULL, NULL, '0000', '0000');

                 -- cap nhat referenceid trong bang VSDTRFLOG
                 UPDATE vsdtrflog SET referenceid = v_reqid WHERE autoid = rec.autoid;

                 -- cap nhat thong tin dien vao bang trung gian neu can
                 auto_process_inf_msg(rec.autoid,
                                      rec.funcname,
                                      v_reqid,
                                      l_err_code
                 );
                 -- dien tu dong xac nhan thi g?i ham hoan tat luon
                 IF nvl(l_err_code, '0') = '0' AND rec.autoconf = 'Y' THEN
                    auto_complete_inf_msg(rec.autoid,
                                          rec.funcname,
                                          v_reqid,
                                          l_err_code
                    );
                 END IF;

                 IF nvl(l_err_code, '0') <> '0' THEN
                    UPDATE vsdtxreq SET msgstatus = 'E', status = 'E', boprocess_err = l_err_code
                    WHERE reqid = v_reqid;

                    v_isprocess := FALSE;
                 END IF;
             ELSE
                v_isprocess := FALSE;
             END IF;
          END IF;
          -- Cap nhat trang thai da xu ly
          IF NOT v_isprocess THEN
             UPDATE vsdtrflog SET status = 'E', timeprocess = systimestamp,
                                  errdesc = 'Khong xu ly duoc nghiep vu'
             WHERE autoid = rec.autoid AND status = 'P';

          ELSIF nvl(l_cf_msgtype,'x') <> 'INF' AND l_autoconf = 'Y' THEN
             UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp
             WHERE autoid = rec.autoid AND status = 'P';

          END IF;
       EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
          plog.setendsection(pkgctx, 'pr_auto_process_message');
          ROLLBACK;
          -- Cap nhat trang thai loi
          UPDATE vsdtrflog SET status = 'E', errdesc = 'Loi he thong', timeprocess = systimestamp
          WHERE autoid = rec.autoid;
       END;
       COMMIT;
    END LOOP;

    plog.setendsection(pkgctx, 'pr_auto_process_message');
  EXCEPTION WHEN OTHERS THEN
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_auto_process_message');
  END pr_auto_process_message;

  procedure auto_complete_confirm_msg(pv_reqid number, pv_cftltxcd varchar2, pv_vsdtrfid number, p_err_code out varchar2) as
    v_catype varchar2(5);
    l_countcf number;
    l_countsymbol number;
    l_count number;
    l_msgstatus VARCHAR2(50);
    l_refcode VARCHAR2(50);
    l_msgacct VARCHAR2(50);
    l_catype varchar2(10);
  begin
    plog.setbeginsection(pkgctx, 'auto_complete_confirm_msg');
    plog.info(pkgctx, '::req Id:' || pv_reqid || '::confirm tltxcd:' || pv_cftltxcd || '::vsd confirm Id:' || pv_vsdtrfid);
    CASE pv_cftltxcd
       -- Luu ky
       WHEN '2231' THEN auto_call_txpks_2231(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2246' THEN auto_call_txpks_2246(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2294' THEN auto_call_txpks_2294(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2201' THEN auto_call_txpks_2201(pv_reqid, pv_vsdtrfid, p_err_code);
       -- End Luu ky
       -- Chuyen khoan
       WHEN '2265' THEN auto_call_txpks_2265(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2266' THEN auto_call_txpks_2266(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2276' THEN auto_call_txpks_2276 (pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2226' THEN auto_call_txpks_2226 (pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2248' THEN auto_call_txpks_2248 (pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '2290' THEN auto_call_txpks_2290 (pv_reqid, pv_vsdtrfid, p_err_code);
       -- End Chuyen khoan
       --cam co - giai toa cam co
       when '2236' then auto_call_txpks_2236(pv_reqid, pv_vsdtrfid, p_err_code);
       when '2251' then auto_call_txpks_2251(pv_reqid, pv_vsdtrfid, p_err_code);
       when '2257' then auto_call_txpks_2257(pv_reqid, pv_vsdtrfid, p_err_code);
       when '2253' then auto_call_txpks_2253(pv_reqid, pv_vsdtrfid, p_err_code);

       --xac nhan danh sach phan bo
       WHEN '3335NAK' THEN auto_call_func_3335_rej(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '3335ACK' THEN
        begin
                select max(ca.catype) into v_catype from camast ca, vsdtxreq rq where ca.camastid = rq.msgacct and rq.reqid = pv_reqid;
            exception when others then
                v_catype := 'x';
        end;
        if v_catype in ('014') then
            auto_call_txpks_3370(pv_reqid, pv_vsdtrfid, p_err_code);
        elsif v_catype not in ('028') then
            auto_call_txpks_3340(pv_reqid, pv_vsdtrfid, p_err_code);
        end if;

       --Dang ky quyen mua
       WHEN '3357NAK' THEN auto_call_func_3357_rej(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '3357ACK' THEN auto_call_func_3357_conf(pv_reqid, pv_vsdtrfid, p_err_code);

       --Chuyen nhuong quyen mua
       WHEN '3358NAK' THEN auto_call_func_3358_rej(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '3358ACK' THEN auto_call_func_3358_conf(pv_reqid, pv_vsdtrfid, p_err_code);

       --huy nhan CP tu TP
       WHEN '3328' THEN auto_call_txpks_3328(pv_reqid, pv_vsdtrfid, p_err_code);
       --huy dang ky thanh toan cw
       WHEN '3360' THEN auto_call_func_3360(pv_reqid, pv_vsdtrfid, p_err_code);
       --Nhan chuyen nhuong quyen mua
       WHEN '3385' THEN auto_call_func_3385 (pv_reqid, pv_vsdtrfid, p_err_code);


       --HSX04
       --mo tai khoan
       WHEN '0035' THEN auto_call_func_0035(pv_reqid , pv_vsdtrfid, p_err_code);
       WHEN '0012' THEN auto_call_txpks_0012(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN 'CFREJ' THEN auto_call_func_cfrej(pv_reqid, pv_vsdtrfid, p_err_code);
       --thay doi thong tin khach hang
       WHEN '0004' THEN auto_call_txpks_0004(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '0018' THEN auto_call_txpks_0018(pv_reqid, pv_vsdtrfid, p_err_code);
       --lien ket tai khoan
       WHEN '0102' THEN auto_call_txpks_0103(pv_reqid, pv_vsdtrfid, p_err_code,'C');
       WHEN '0103' THEN auto_call_txpks_0103(pv_reqid, pv_vsdtrfid, p_err_code,'R');
       --dong tai khoan
       WHEN '0059' THEN auto_call_func_0059(pv_reqid, pv_vsdtrfid, p_err_code);
       WHEN '0060' THEN auto_call_func_0060(pv_reqid, pv_vsdtrfid, p_err_code);

       -- huy dang ky cp phat hanh them
        --WHEN '3311' THEN  auto_call_txpks_3311(pv_reqid, pv_vsdtrfid, p_err_code);
        --huy danh sach phan bo
        WHEN '3370' THEN auto_call_func_3370(pv_reqid, pv_vsdtrfid, p_err_code);
        --huy nhan CP tu TP
        WHEN '3328' THEN auto_call_txpks_3328(pv_reqid, pv_vsdtrfid, p_err_code);
        --huy dang ky thanh toan cw
        WHEN '3360' THEN auto_call_func_3360(pv_reqid, pv_vsdtrfid, p_err_code);
        --chuyen nhuong chung khoan quyen
        when '3353' then auto_call_txpks_3353(pv_reqid, pv_vsdtrfid, p_err_code);
        when '3358' then auto_call_func_3358(pv_reqid, pv_vsdtrfid, p_err_code);

       --END HSX04
       ELSE NULL;
    END CASE;

    if pv_cftltxcd = '0067' then
      -- XAC NHAN KICH HOAT LAI TAI KHOAN
      auto_call_txpks_0067(pv_reqid, pv_vsdtrfid);
    --elsif pv_cftltxcd = '8894' then
      -- XAC NHAN CK RA NGOAI THANH CONG
      --auto_call_txpks_8879(pv_reqid, pv_vsdtrfid);
      --auto_call_txpks_8894(pv_reqid, pv_vsdtrfid);
    elsif pv_cftltxcd = '2265' then
      -- XAC NHAN TU CHOI CK RA NGOAI
      select count(1) into l_count from vsdtrflog where autoid = pv_vsdtrfid and funcname like '%TWAC%';
      if l_count = 0 then
        auto_call_txpks_2265(pv_reqid, pv_vsdtrfid,p_err_code);
      end if;
    elsif pv_cftltxcd = '2236' then
      -- TU CHOI PHONG TOA CHUNG KHOAN
      auto_call_txpks_2236(pv_reqid, pv_vsdtrfid,p_err_code);
    elsif pv_cftltxcd = '2257' then
      -- TU CHOI GIAI TOA CHUNG KHOAN
      auto_call_txpks_2257(pv_reqid, pv_vsdtrfid,p_err_code);
    elsif pv_cftltxcd = '2251' then
      -- CHAP NHAN PHONG TOA CHUNG KHOAN
      auto_call_txpks_2251(pv_reqid, pv_vsdtrfid,p_err_code);
    elsif pv_cftltxcd = '2253' then
      -- CHAP NHAN GIAI TOA CHUNG KHOAN
      auto_call_txpks_2253(pv_reqid, pv_vsdtrfid,p_err_code);
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
            auto_call_txpks_3370(pv_reqid, pv_vsdtrfid,p_err_code);
        else
            auto_call_txpks_3340(pv_reqid, pv_vsdtrfid,p_err_code);
            /*update vsdtxreq
            set status = 'C', msgstatus = 'C' --boprocess = 'Y'
            where reqid = pv_reqid;
            return;*/
        end if;
    end if;

    plog.setendsection(pkgctx, 'auto_complete_confirm_msg');
  exception
    when others then
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_complete_confirm_msg');
  end auto_complete_confirm_msg;

  procedure auto_process_inf_msg(pv_autoid number, pv_funcname varchar2, pv_reqid number, p_err_code out varchar2)
  AS
    v_cdate              DATE;
     v_vsdmsgid           varchar2(50);
     v_isincode           varchar2(50);
     v_qtty               number;
     v_contractno         varchar2(50);
     v_txdate             varchar2(20);
     v_symbol             varchar2(50);
     v_custodycd          varchar2(20);
     v_refmsgid           varchar2(50);
     v_vsdmsgdate         DATE;
     v_trfdate            DATE;
     v_trftxnum           VARCHAR2(50);
     v_frbiccode          VARCHAR2(20);
     v_recustodycd        varchar2(20);
     v_transtype          VARCHAR2(10);
     v_count              NUMBER;
     v_tradeplace         VARCHAR2(50);
     v_type501            VARCHAR2(4);
     v_type607            VARCHAR2(50);
     v_buyintype          VARCHAR2(50);
     v_cmbicode           VARCHAR2(50);
     v_traddate           VARCHAR2(50);
     v_txdate607          VARCHAR2(50);
     v_excode             VARCHAR2(50);
     v_afacctno           VARCHAR2(50);
  begin
    plog.setbeginsection(pkgctx, 'auto_process_inf_msg');
    plog.info(pkgctx, 'process auto id:' || pv_autoid || '::function:' || pv_funcname || '::reqId:' || pv_reqid);
    CASE pv_funcname
       -- Phong toa chung khoan
       WHEN '540.NEWM.SETR//RVPO.OK' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'CONTRACTNO' THEN fldval ELSE '' END) contractno,
                 MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END) custodycd,
                 MAX(CASE WHEN fldname = 'ISINCODE' THEN substr(fldval,6) ELSE '' END) isincode,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) qtty,
                 MAX(CASE WHEN fldname = 'TXDATE' THEN substr(fldval,1,8) ELSE '' END) txdate
          INTO v_vsdmsgid, v_contractno, v_custodycd, v_isincode, v_qtty, v_txdate
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          SELECT CASE WHEN v_custodycd LIKE '%PTA' THEN symbol||'_WFT' ELSE symbol END
          INTO v_symbol
          FROM sbsecurities
          WHERE isincode = v_isincode AND symbol NOT LIKE '%_WFT';

          INSERT INTO seblockeddtl(autoid, txdate, contract_no, custodycd, symbol, blockedqtty, vsdmsgid, reqid)
          VALUES(seq_seblockeddtl.nextval,
                 CASE WHEN v_txdate IS NULL THEN getcurrdate ELSE to_date(v_txdate,'RRRRMMDD') END,
                 v_contractno,
                 CASE WHEN v_custodycd like '%PTA' THEN substr(v_custodycd,1,length(v_custodycd) - 3) ELSE v_custodycd END,
                 v_symbol,
                 0,
                 v_vsdmsgid,
                 pv_reqid
          );
       WHEN '504.NEWM.LINK//540.OK' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'CONTRACTNO' THEN fldval ELSE '' END) contractno,
                 MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END) custodycd,
                 MAX(CASE WHEN fldname = 'ISINCODE' THEN substr(fldval,6) ELSE '' END) isincode,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) qtty,
                 MAX(CASE WHEN fldname = 'TXDATE' THEN substr(fldval,1,8) ELSE '' END) txdate,
                 MAX(CASE WHEN fldname = 'REFID' THEN fldval ELSE '' END) REFID
          INTO v_vsdmsgid, v_contractno, v_custodycd, v_isincode, v_qtty, v_txdate, v_refmsgid
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          UPDATE seblockeddtl SET blockedqtty = v_qtty WHERE REQID = v_refmsgid;
        WHEN '544.NEWM.LINK//540.SETR//RVPO.OK' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'QTTY' then to_number(fldval) ELSE 0 END) QTTY,
                 MAX(CASE WHEN fldname = 'REFID' then fldval ELSE '' END) REFID
          INTO v_vsdmsgid, v_qtty, v_refmsgid
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          UPDATE seblockeddtl SET confirmqtty = v_qtty WHERE vsdmsgid = v_refmsgid AND blockedqtty > 0;
         -- Giai toa chung khoan 1 phan
       WHEN '542.NEWM.SETR//RVPO.STCO//PART' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN substr(fldval,1,8) ELSE '' END) VSDMSGDATE,
                 MAX(CASE WHEN fldname = 'CONTRACTNO' THEN fldval ELSE '' END) CONTRACTNO,
                 MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END) CUSTODYCD,
                 MAX(CASE WHEN fldname = 'ISINCODE' THEN substr(fldval, 6) ELSE '' END) ISINCODE,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) QTTY
          INTO v_vsdmsgid, v_txdate, v_contractno, v_custodycd, v_isincode, v_qtty
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          SELECT CASE WHEN v_custodycd LIKE '%PTA' THEN symbol||'_WFT' ELSE symbol END
          INTO v_symbol
          FROM sbsecurities
          WHERE isincode = v_isincode AND symbol NOT LIKE '%_WFT';

          INSERT INTO seblockeddtl(autoid, txdate, contract_no, custodycd, symbol, releaseqtty, vsdmsgid, reqid)
          VALUES(seq_seblockeddtl.nextval,
                 CASE WHEN v_txdate IS NULL THEN getcurrdate ELSE to_date(v_txdate,'RRRRMMDD') END,
                 v_contractno,
                 CASE WHEN v_custodycd like '%PTA' THEN substr(v_custodycd,1,length(v_custodycd) - 3) ELSE v_custodycd END,
                 v_symbol,
                 0,
                 v_vsdmsgid,
                 pv_reqid
          );
       WHEN '503.NEWM.LINK//542' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN substr(fldval,1,8) ELSE '' END) VSDMSGDATE,
                 MAX(CASE WHEN fldname = 'CONTRACTNO' THEN fldval ELSE '' END) CONTRACTNO,
                 MAX(CASE WHEN fldname = 'ISINCODE' THEN substr(fldval, 6) ELSE '' END) ISINCODE,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) QTTY,
                 MAX(CASE WHEN fldname = 'REFID' then fldval ELSE '' END) REFID
          INTO v_vsdmsgid, v_txdate, v_contractno, v_isincode, v_qtty, v_refmsgid
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          UPDATE seblockeddtl SET releaseqtty = v_qtty WHERE vsdmsgid = v_refmsgid;
       WHEN '546.NEWM.LINK//542.SETR//RVPO.STCO//PART' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'REFID' THEN fldval ELSE '' END) REFID,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) QTTY
          INTO v_vsdmsgid, v_refmsgid, v_qtty
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          UPDATE seblockeddtl SET confirmqtty = v_qtty WHERE vsdmsgid = v_refmsgid AND releaseqtty > 0;
       -- Giai toa chung khoan toan phan
       WHEN '542.NEWM.SETR//RVPO.' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN substr(fldval,1,8) ELSE '' END) VSDMSGDATE,
                 MAX(CASE WHEN fldname = 'CONTRACTNO' THEN fldval ELSE '' END) CONTRACTNO,
                 MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END) CUSTODYCD,
                 MAX(CASE WHEN fldname = 'ISINCODE' THEN substr(fldval, 6) ELSE '' END) ISINCODE,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) QTTY
          INTO v_vsdmsgid, v_txdate, v_contractno, v_custodycd,v_isincode, v_qtty
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          SELECT CASE WHEN v_custodycd LIKE '%PTA' THEN symbol||'_WFT' ELSE symbol END
          INTO v_symbol
          FROM sbsecurities
          WHERE isincode = v_isincode AND symbol NOT LIKE '%_WFT';

          FOR rec IN
          (  SELECT symbol, NVL(SUM(blockedqtty),0) blockedqtty, NVL(SUM(releaseqtty),0) releaseqtty
             FROM seblockeddtl
             WHERE contract_no = v_contractno AND symbol=v_symbol
             AND custodycd = CASE WHEN v_custodycd like '%PTA' THEN substr(v_custodycd,1,length(v_custodycd) - 3) ELSE v_custodycd END
             GROUP BY symbol
             HAVING SUM(blockedqtty) - SUM(releaseqtty) > 0
          )
          LOOP
             INSERT INTO seblockeddtl(autoid, txdate, contract_no, custodycd, symbol, releaseqtty, vsdmsgid, reqid)
             VALUES(seq_seblockeddtl.nextval,
                    CASE WHEN v_txdate IS NULL THEN getcurrdate ELSE to_date(v_txdate,'RRRRMMDD') END,
                    v_contractno,
                    CASE WHEN v_custodycd like '%PTA' THEN substr(v_custodycd,1,length(v_custodycd) - 3) ELSE v_custodycd END,
                    rec.symbol,
                    rec.blockedqtty - rec.releaseqtty,
                    v_vsdmsgid,
                    pv_reqid
             );
          END LOOP;
       WHEN '546.NEWM.LINK//542.SETR//RVPO.' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                 MAX(CASE WHEN fldname = 'REFID' THEN fldval ELSE '' END) REFID,
                 MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END) QTTY
          INTO v_vsdmsgid, v_refmsgid, v_qtty
          FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

          UPDATE seblockeddtl SET confirmqtty = releaseqtty WHERE vsdmsgid = v_refmsgid AND releaseqtty > 0;
        ---END Phong toa giai toa
                -- Chuyen khoan
       WHEN '578.NEWM.SETR//TRAD.REDE//RECE' THEN
         SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END),
                MAX(CASE WHEN fldname = 'VSDEFFDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'TRDTXNUM' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'FRBICCODE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'RECUSTODYCD' THEN fldval ELSE '' end),
                MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END),
                MAX(CASE WHEN fldname = 'TRANSTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END)
         INTO v_vsdmsgid, v_vsdmsgdate, v_trfdate, v_trftxnum, v_frbiccode, v_custodycd,
              v_recustodycd, v_isincode, v_transtype, v_qtty
         FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

         SELECT symbol INTO v_symbol FROM sbsecurities
         WHERE isincode = v_isincode AND refcodeid IS NULL;

         INSERT INTO SERECEIVED(autoid,vsdmsgid,vsdmsgdate,trfdate,trftxnum,frbiccode,
                                custodycd,recustodycd,symbol,trade,blocked)
         SELECT seq_SERECEIVED.nextval, v_vsdmsgid, nvl(v_vsdmsgdate,v_cdate), nvl(v_trfdate,v_cdate),
                v_trftxnum, v_frbiccode,
                CASE WHEN v_custodycd LIKE '%PTA' THEN substr(v_custodycd,1,length(v_custodycd)-3)
                     ELSE v_custodycd END,
                CASE WHEN v_recustodycd LIKE '%PTA' THEN substr(v_recustodycd,1,length(v_recustodycd)-3)
                     ELSE v_recustodycd END,
                CASE WHEN v_custodycd LIKE '%PTA' THEN v_symbol || '_WFT'
                     ELSE v_symbol END,
                CASE WHEN v_transtype = 'AVAI' THEN v_qtty
                     ELSE 0 END,
                CASE WHEN v_transtype = 'NAVL' THEN v_qtty
                     ELSE 0 END
         FROM dual;
       WHEN '544.NEWM.LINK//542.SETR//TRAD' THEN
         SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END),
                MAX(CASE WHEN fldname = 'VSDEFFDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'TRDTXNUM' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'FRBICCODE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'RECUSTODYCD' THEN fldval ELSE '' end),
                MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END),
                MAX(CASE WHEN fldname = 'TRANSTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END)
         INTO v_vsdmsgid, v_vsdmsgdate, v_trfdate, v_trftxnum, v_frbiccode, v_custodycd,
              v_recustodycd, v_isincode, v_transtype, v_qtty
         FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

         SELECT symbol INTO v_symbol FROM sbsecurities
         WHERE isincode = v_isincode AND refcodeid IS NULL;

         INSERT INTO SERECEIVED(autoid,vsdmsgid,vsdmsgdate,trfdate,trftxnum,frbiccode,
                                custodycd,recustodycd,symbol,trade,blocked,reqid,status)
         SELECT seq_SERECEIVED.nextval, v_vsdmsgid, nvl(v_vsdmsgdate,v_cdate), nvl(v_trfdate,v_cdate),
                v_trftxnum, v_frbiccode,
                CASE WHEN v_custodycd LIKE '%PTA' THEN substr(v_custodycd,1,length(v_custodycd)-3)
                     ELSE v_custodycd END,
                CASE WHEN v_recustodycd LIKE '%PTA' THEN substr(v_recustodycd,1,length(v_recustodycd)-3)
                     ELSE v_recustodycd END,
                CASE WHEN v_custodycd LIKE '%PTA' THEN v_symbol || '_WFT'
                     ELSE v_symbol END,
                CASE WHEN v_transtype = 'AVAI' THEN v_qtty
                     ELSE 0 END,
                CASE WHEN v_transtype = 'NAVL' THEN v_qtty
                     ELSE 0 END,
                pv_reqid, 'A'
         FROM dual;
        --end
        -- Quyen
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/STTRAD' THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype, msgstatus, timecreate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, 'STTRAD', 'C', systimestamp
             FROM dual;
          END LOOP;
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/ENTRAD' THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype, msgstatus, timecreate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, 'ENTRAD', 'C', systimestamp
             FROM dual;
          END LOOP;
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/STINST' THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype, msgstatus, timecreate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, 'STINST', 'C', systimestamp
             FROM dual;
          END LOOP;
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/ENINST' THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype, msgstatus, timecreate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, 'ENINST', 'C', systimestamp
             FROM dual;
          END LOOP;
       WHEN '567.INST.EPRC//COMP.REAS//AUTH/AUCD/FIN' THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype, msgstatus, timecreate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, 'FIN', 'C', systimestamp
             FROM dual;
          END LOOP;
       WHEN '566.NEWM.LINK//564' THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDDHH') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype, actiondate, msgstatus, timecreate,msgtype)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, 'PROC', rec.actiondate, 'C', systimestamp,'566'
             FROM dual;
          END LOOP;
       WHEN '540.NEWM.SETR//TRAD' THEN
          SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END),
                MAX(CASE WHEN fldname = 'VSDEFFDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval,6) ELSE '' END),
                MAX(CASE WHEN fldname = 'TRANSTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END)
         INTO v_vsdmsgid, v_vsdmsgdate, v_trfdate,
              v_recustodycd, v_isincode, v_transtype, v_qtty
         FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

         SELECT symbol INTO v_symbol FROM sbsecurities
         WHERE isincode = v_isincode AND refcodeid IS NULL;

         INSERT INTO SERECEIVED(autoid,vsdmsgid,vsdmsgdate,trfdate,
                                recustodycd,symbol,trade,blocked,reqid,status)
         SELECT seq_SERECEIVED.nextval, v_vsdmsgid, nvl(v_vsdmsgdate,v_cdate), nvl(v_trfdate,v_cdate),
                v_recustodycd,v_symbol,
                CASE WHEN v_transtype = 'AVAI' THEN v_qtty
                     ELSE 0 END,
                CASE WHEN v_transtype = 'NAVL' THEN v_qtty
                     ELSE 0 END,
                pv_reqid, 'A'
         FROM dual;
       -- END Quyen
        ELSE NULL;
    END CASE;
    -- Cac function xu ly chung
    -- Quyen
    CASE
       WHEN pv_funcname IN ('564.NEWM.CAEV//RHDI', '564.REPL.CAEV//RHDI', '564.CANC.CAEV//RHDI') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'NUMERATOR' THEN fldval ELSE '' END) NUMERATOR,
                    MAX(CASE WHEN fldname = 'DENOMINATOR' THEN fldval ELSE '' END) DENOMINATOR,
                    MAX(CASE WHEN fldname = 'TOSYMBOL' THEN substr(fldval, 6) ELSE '' END) TOSYMBOL,
                    MAX(CASE WHEN fldname = 'PRICE' THEN substr(fldval, 4) ELSE '' END) PRICE,
                    MAX(CASE WHEN fldname = 'EXPRICE' THEN substr(fldval, 4) ELSE '' END) EXPRICE,
                    MAX(CASE WHEN fldname = 'TRFTYPE' THEN substr(fldval, 4) ELSE '' END) TRFTYPE,
                    MAX(CASE WHEN fldname = 'BEGINDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) BEGINDATE,
                    MAX(CASE WHEN fldname = 'DUEDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) DUEDATE,
                    MAX(CASE WHEN fldname = 'FRDATETRANSFER' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) FRDATETRANSFER,
                    MAX(CASE WHEN fldname = 'TODATETRANSFER' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) TODATETRANSFER,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate, toisincode, price, exprice, trftype,actiondate,begindate,duedate,frdatetransfer,Todatetransfer)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '014', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.numerator || '/' || rec.denominator, rec.tosymbol, rec.price, rec.exprice, rec.trftype,
                    rec.actiondate,rec.begindate, rec.duedate, rec.frdatetransfer, rec.TODATETRANSFER
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//EXWA', '564.REPL.CAEV//EXWA', '564.CANC.CAEV//EXWA') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'ACTIONTYPE' THEN fldval ELSE '' END) ACTIONTYPE,
                    MAX(CASE WHEN fldname = 'ACTIONRATE' THEN fldval ELSE '' END) ACTIONRATE,
                    MAX(CASE WHEN fldname = 'ACTIONVALUE' THEN substr(fldval, 4) ELSE '' END) ACTIONVALUE,
                    MAX(CASE WHEN fldname = 'TOSYMBOL' THEN substr(fldval, 6) ELSE '' END) TOSYMBOL,
                    MAX(CASE WHEN fldname = 'EXPRICE' THEN substr(fldval, 4) ELSE '' END) EXPRICE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate, actionvalue, toisincode, exprice,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '028', rec.symbol, rec.reportdate, 'C', systimestamp,
                    decode(rec.actiontype, 'OFFR/ACTU', rec.actionrate, ''),
                    decode(rec.actiontype, 'OFFR/ACTU', '', rec.actionvalue),
                    rec.tosymbol, rec.exprice, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//MEET', '564.REPL.CAEV//MEET', '564.CANC.CAEV//MEET') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'NUMERATOR' THEN fldval ELSE '' END) NUMERATOR,
                    MAX(CASE WHEN fldname = 'DENOMINATOR' THEN fldval ELSE '' END) DENOMINATOR,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '005', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.numerator || '/' || rec.denominator, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//DVCA', '564.REPL.CAEV//DVCA', '564.CANC.CAEV//DVCA') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'ACTIONRATE' THEN fldval ELSE '' END) ACTIONRATE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '010', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.actionrate,rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//BONU', '564.REPL.CAEV//BONU', '564.CANC.CAEV//BONU') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'NUMERATOR' THEN fldval ELSE '' END) NUMERATOR,
                    MAX(CASE WHEN fldname = 'DENOMINATOR' THEN fldval ELSE '' END) DENOMINATOR,
                    MAX(CASE WHEN fldname = 'EXPRICE' THEN substr(fldval, 4) ELSE '' END) EXPRICE,
                    MAX(CASE WHEN fldname = 'CIROUNDTYPE' THEN fldval ELSE '' END) CIROUNDTYPE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate, exprice,ciroundtype, cashround,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '021', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.numerator || '/' || rec.denominator, rec.exprice,
                    decode(rec.ciroundtype, 'CINL', 2, 0),
                    CASE WHEN rec.ciroundtype IN ('CINL', 'RDDN') THEN 2
                         WHEN rec.ciroundtype = 'RDUP' THEN 1
                         ELSE 0
                    END, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//DVSE', '564.REPL.CAEV//DVSE', '564.CANC.CAEV//DVSE') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'NUMERATOR' THEN fldval ELSE '' END) NUMERATOR,
                    MAX(CASE WHEN fldname = 'DENOMINATOR' THEN fldval ELSE '' END) DENOMINATOR,
                    MAX(CASE WHEN fldname = 'EXPRICE' THEN substr(fldval, 4) ELSE '' END) EXPRICE,
                    MAX(CASE WHEN fldname = 'CIROUNDTYPE' THEN fldval ELSE '' END) CIROUNDTYPE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate, exprice, ciroundtype, cashround, actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '011', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.numerator || '/' || rec.denominator, rec.exprice,
                    decode(rec.ciroundtype, 'CINL', 2, 0),
                    CASE WHEN rec.ciroundtype IN ('CINL', 'RDDN') THEN 2
                         WHEN rec.ciroundtype = 'RDUP' THEN 1
                         ELSE 0
                    END, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//INTR', '564.REPL.CAEV//INTR', '564.CANC.CAEV//INTR') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'ACTIONRATE' THEN fldval ELSE '' END) ACTIONRATE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '015', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.actionrate, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//REDM', '564.REPL.CAEV//REDM', '564.CANC.CAEV//REDM') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'ACTIONRATE' THEN fldval ELSE '' END) ACTIONRATE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '016', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.actionrate, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//MRGR', '564.REPL.CAEV//MRGR', '564.CANC.CAEV//MRGR') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'NUMERATOR' THEN fldval ELSE '' END) NUMERATOR,
                    MAX(CASE WHEN fldname = 'DENOMINATOR' THEN fldval ELSE '' END) DENOMINATOR,
                    MAX(CASE WHEN fldname = 'TOSYMBOL' THEN substr(fldval, 6) ELSE '' END) TOSYMBOL,
                    MAX(CASE WHEN fldname = 'EXPRICE' THEN substr(fldval, 4) ELSE '' END) EXPRICE,
                    MAX(CASE WHEN fldname = 'CIROUNDTYPE' THEN fldval ELSE '' END) CIROUNDTYPE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate, toisincode, exprice, ciroundtype, cashround,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    '020', rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.numerator || '/' || rec.denominator, rec.tosymbol, rec.exprice,
                    decode(rec.ciroundtype, 'CINL', 2, 0),
                    CASE WHEN rec.ciroundtype IN ('CINL', 'RDDN') THEN 2
                         WHEN rec.ciroundtype = 'RDUP' THEN 1
                         ELSE 0
                    END, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname IN ('564.NEWM.CAEV//CONV', '564.REPL.CAEV//CONV', '564.CANC.CAEV//CONV') THEN
          FOR rec IN (
             SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END) VSDMSGID,
                    MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END) VSDMSGDATE,
                    MAX(CASE WHEN fldname = 'VSDCAID' THEN fldval ELSE '' END) VSDCAID,
                    MAX(CASE WHEN fldname = 'REQTYPE' THEN fldval ELSE '' END) REQTYPE,
                    MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END) SYMBOL,
                    MAX(CASE WHEN fldname = 'REPORTDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) REPORTDATE,
                    MAX(CASE WHEN fldname = 'CATYPE' THEN fldval ELSE '' END) CATYPE,
                    MAX(CASE WHEN fldname = 'NUMERATOR' THEN fldval ELSE '' END) NUMERATOR,
                    MAX(CASE WHEN fldname = 'DENOMINATOR' THEN fldval ELSE '' END) DENOMINATOR,
                    MAX(CASE WHEN fldname = 'TOSYMBOL' THEN substr(fldval, 6) ELSE '' END) TOSYMBOL,
                    MAX(CASE WHEN fldname = 'EXPRICE' THEN substr(fldval, 4) ELSE '' END) EXPRICE,
                    MAX(CASE WHEN fldname = 'REEXPRICE' THEN substr(fldval, 4) ELSE '' END) REEXPRICE,
                    MAX(CASE WHEN fldname = 'CIROUNDTYPE' THEN fldval ELSE '' END) CIROUNDTYPE,
                    MAX(CASE WHEN fldname = 'INTERESTRATE' THEN fldval ELSE '' END) INTERESTRATE,
                    MAX(CASE WHEN fldname = 'ACTIONDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END) ACTIONDATE
             FROM vsdtrflogdtl WHERE refautoid = pv_autoid
          ) LOOP
             INSERT INTO msgcareceived(autoid, reqid, txdate, vsdcaid, reqtype,
                    catype, isincode, reportdate, msgstatus, timecreate,
                    actionrate, toisincode, exprice, ciroundtype, interestrate, cashround,actiondate)
             SELECT seq_msgcareceived.nextval, pv_reqid, rec.vsdmsgdate, rec.vsdcaid, rec.reqtype,
                    decode(rec.catype, 'SECU', '017', '023'),
                    rec.symbol, rec.reportdate, 'C', systimestamp,
                    rec.numerator || '/' || rec.denominator, rec.tosymbol,
                    decode(rec.catype, 'SECU', rec.exprice, rec.reexprice),
                    decode(rec.ciroundtype, 'CINL', 2, 0), rec.interestrate,
                    CASE WHEN rec.ciroundtype IN ('CINL', 'RDDN') THEN 2
                         WHEN rec.ciroundtype = 'RDUP' THEN 1
                         ELSE 0
                    END, rec.actiondate
             FROM dual;
          END LOOP;
       WHEN pv_funcname ='501.NEWM/COPY.INST' THEN
         SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END),
                MAX(CASE WHEN fldname = 'ACKTIVEDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval,6,12) ELSE '' END),
                MAX(CASE WHEN fldname = 'TRANSTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END),
                MAX(CASE WHEN fldname = 'TRADEPLACE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'SETYPE' THEN fldval ELSE '' END)
         INTO v_vsdmsgid, v_vsdmsgdate, v_trfdate, v_isincode, v_transtype, v_qtty, v_tradeplace,v_type501
         FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

         SELECT max(symbol) INTO v_symbol FROM sbsecurities
         WHERE isincode = v_isincode AND refcodeid IS NULL;

         INSERT INTO NEWSTOCKREGISTER (AUTOID,TRFCODE,VSDMSGID,VSDMSGDATE,REPORTDATE,SYMBOL,ISINCODE,TRADEPLACE,TRANSTYPE,TRADE,TYPE)
         SELECT SEQ_NEWSTOCKREGISTER.Nextval,pv_funcname,v_vsdmsgid,to_date(v_vsdmsgdate,'DD/MM/RRRR'),to_date(v_trfdate,'DD/MM/RRRR'),
                v_symbol,v_isincode,CASE WHEN v_tradeplace = 'UPX' THEN '005'
                                         WHEN v_tradeplace = 'DEPOX' THEN '009'
                                         WHEN SUBSTR(v_tradeplace,3) ='X' THEN '002'
                                         WHEN SUBSTR(v_tradeplace,3) = 'O' THEN '001' END,v_transtype,v_qtty,v_type501 FROM dual;
       -- doi chieu SID
       WHEN pv_funcname ='598.539..' THEN
         SELECT fldval INTO  v_vsdmsgid
           FROM vsdtrflogdtl
          WHERE fldname = 'VSDMSGID' AND refautoid=pv_autoid;

         INSERT INTO comparesid (custodycd,vsdmsgid,pcod,altc,lnam1,lnam2,idty1,idty2,idsn1,idsn2,idid1,idid2,bird1,bird2,cour1,cour2,taxn1,taxn2,icat1,icat2,hldc1,hldc2)
             SELECT CF.CUSTODYCD,v_vsdmsgid vsdmsgid,A.PCOD,ALTC,
                     REGEXP_SUBSTR(LNAM, '[^/]+', 1, 1) LNAM1,
                     REGEXP_SUBSTR(LNAM, '[^/]+', 1, 2) LNAM2,
                     REGEXP_SUBSTR(IDTY, '[^/]+', 1, 1) IDTY1,
                     REGEXP_SUBSTR(IDTY, '[^/]+', 1, 2) IDTY2,
                     REGEXP_SUBSTR(IDSN, '[^/]+', 1, 1) IDSN1,
                     REGEXP_SUBSTR(IDSN, '[^/]+', 1, 2) IDSN2,
                     to_date(REGEXP_SUBSTR(IDID, '[^/]+', 1, 1), 'RRRRMMDD') IDID1,
                     to_date(REGEXP_SUBSTR(IDID, '[^/]+', 1, 2), 'RRRRMMDD') IDID2,
                     to_date(REGEXP_SUBSTR(BIRD, '[^/]+', 1, 1), 'RRRRMMDD') BIRD1,
                     to_date(REGEXP_SUBSTR(BIRD, '[^/]+', 1, 2), 'RRRRMMDD') BIRD2,
                     REGEXP_SUBSTR(COUR, '[^/]+', 1, 1) COUR1,
                     REGEXP_SUBSTR(COUR, '[^/]+', 1, 2) COUR2,
                     REGEXP_SUBSTR(TAXN, '[^/]+', 1, 1) TAXN1,
                     REGEXP_SUBSTR(TAXN, '[^/]+', 1, 2) TAXN2,
                     REGEXP_SUBSTR(ICAT, '[^/]+', 1, 1) ICAT1,
                     REGEXP_SUBSTR(ICAT, '[^/]+', 1, 2) ICAT2,
                     REGEXP_SUBSTR(HLDC, '[^/]+', 1, 1) HLDC1,
                     REGEXP_SUBSTR(HLDC, '[^/]+', 1, 2) HLDC2
              FROM (
              SELECT regexp_replace(regexp_substr(DETAIL,'(^/PCOD/|'||chr(10)||'/PCOD/)[^'||chr(10)||']+'),'(^/PCOD/|'||chr(10)||'/PCOD/)','') PCOD,
                     regexp_replace(regexp_substr(DETAIL,'(^/ALTC/|'||chr(10)||'/ALTC/)[^'||chr(10)||']+'),'(^/ALTC/|'||chr(10)||'/ALTC/)','') ALTC,
                     regexp_replace(regexp_substr(DETAIL,'(^/LNAM/|'||chr(10)||'/LNAM/)[^'||chr(10)||']+'),'(^/LNAM/|'||chr(10)||'/LNAM/)','') LNAM,
                     regexp_replace(regexp_substr(DETAIL,'(^/IDTY/|'||chr(10)||'/IDTY/)[^'||chr(10)||']+'),'(^/IDTY/|'||chr(10)||'/IDTY/)','') IDTY,
                     regexp_replace(regexp_substr(DETAIL,'(^/IDSN/|'||chr(10)||'/IDSN/)[^'||chr(10)||']+'),'(^/IDSN/|'||chr(10)||'/IDSN/)','') IDSN,
                     regexp_replace(regexp_substr(DETAIL,'(^/IDID/|'||chr(10)||'/IDID/)[^'||chr(10)||']+'),'(^/IDID/|'||chr(10)||'/IDID/)','') IDID,
                     regexp_replace(regexp_substr(DETAIL,'(^/BIRD/|'||chr(10)||'/BIRD/)[^'||chr(10)||']+'),'(^/BIRD/|'||chr(10)||'/BIRD/)','') BIRD,
                     regexp_replace(regexp_substr(DETAIL,'(^/COUR/|'||chr(10)||'/COUR/)[^'||chr(10)||']+'),'(^/COUR/|'||chr(10)||'/COUR/)','') COUR,
                     regexp_replace(regexp_substr(DETAIL,'(^/TAXN/|'||chr(10)||'/TAXN/)[^'||chr(10)||']+'),'(^/TAXN/|'||chr(10)||'/TAXN/)','') TAXN,
                     regexp_replace(regexp_substr(DETAIL,'(^/ICAT/|'||chr(10)||'/ICAT/)[^'||chr(10)||']+'),'(^/ICAT/|'||chr(10)||'/ICAT/)','') ICAT,
                     regexp_replace(regexp_substr(DETAIL,'(^/HLDC/|'||chr(10)||'/HLDC/)[^'||chr(10)||']+'),'(^/HLDC/|'||chr(10)||'/HLDC/)','') HLDC
              FROM (SELECT fldval DETAIL
                FROM vsdtrflogdtl
               WHERE fldname <> 'VSDMSGID' AND refautoid=pv_autoid
              )) A, cfmast cf
              WHERE cf.pcod = A.pcod;
       -- Buy-in
       WHEN pv_funcname = '598.607..' THEN
         SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'BUYINTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END),
                MAX(CASE WHEN fldname = 'CMBICODE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'TRADDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'TXDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'EXCODE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval,6,12) ELSE '' END),
                MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END),
                MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END)
         INTO v_vsdmsgid, v_type607, v_buyintype, v_vsdmsgdate, v_cmbicode, v_traddate, v_txdate607, v_excode, v_isincode, v_qtty, v_afacctno
         FROM vsdtrflogdtl WHERE refautoid = pv_autoid;

         INSERT INTO odbuyin(autoid, trfcode, vsdmsgid, vsdmsgtype, buyintype, vsdmsgdate, cmbicode, traddate, txdate, excode, isincode, qtty, custodycd)
         VALUES(seq_odbuyin.nextval, pv_funcname, v_vsdmsgid, v_type607, v_buyintype, v_vsdmsgdate, v_cmbicode, v_traddate, v_txdate607, v_excode, v_isincode, v_qtty, v_afacctno);

       ELSE NULL;
       -- END Quyen
       end case;

    plog.setendsection(pkgctx, 'auto_process_inf_msg');
  exception when others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_process_inf_msg');
  end auto_process_inf_msg;

  procedure auto_complete_inf_msg(pv_autoid number, pv_funcname varchar2, pv_reqid number, p_err_code out varchar2) as
  begin
    plog.setbeginsection(pkgctx, 'auto_complete_inf_msg');
    plog.info(pkgctx, 'process auto id:' || pv_autoid || '::function:' || pv_funcname || '::reqId:' || pv_reqid);

    CASE pv_funcname
       WHEN '504.NEWM.LINK//540.OK' THEN auto_call_func_complete(pv_reqid, pv_autoid, p_err_code);
       WHEN '503.NEWM.LINK//542'    THEN auto_call_func_complete(pv_reqid, pv_autoid, p_err_code);
       WHEN '546.NEWM.LINK//542.SETR//RVPO.STCO//PART' THEN auto_call_func_complete(pv_reqid, pv_autoid, p_err_code);
       WHEN '546.NEWM.LINK//542.SETR//RVPO.' THEN auto_call_func_complete(pv_reqid, pv_autoid, p_err_code);
       WHEN '544.NEWM.LINK//542.SETR//TRAD' THEN auto_call_txpks_2226(pv_reqid, pv_autoid, p_err_code);
       --quyen
       WHEN '564.NEWM.CAEV//RHDI' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//EXWA' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//MEET' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//DVCA' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//DVSE' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//INTR' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//REDM' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//BONU' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//MRGR' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '564.NEWM.CAEV//CONV' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/STTRAD' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/ENTRAD' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/STINST' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '567.INST.EPRC//PEND.REAS//AUTH/AUCD/ENINST' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '540.NEWM.SETR//TRAD' THEN auto_call_txpks_3355(pv_reqid, pv_autoid, p_err_code);
       WHEN '566.NEWM.LINK//564' THEN auto_call_txpks_3313(pv_reqid, pv_autoid, p_err_code);
       WHEN '567.INST.EPRC//COMP.REAS//AUTH/AUCD/FIN' THEN auto_call_func_567(pv_reqid, pv_autoid, p_err_code);
       WHEN '544.NEWM.LINK//540.SETR//RVPO.OK' THEN auto_call_func_complete(pv_reqid, pv_autoid, p_err_code);
       WHEN '546.NEWM.LINK//503.SETR//RVPO.STCO//PART' THEN auto_call_func_complete(pv_reqid, pv_autoid, p_err_code);
       ELSE auto_call_func_pending(pv_reqid, pv_autoid, p_err_code);
    END CASE;

    UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE referenceid = pv_reqid;
    plog.setendsection(pkgctx, 'auto_complete_inf_msg');
  exception when others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_complete_inf_msg');
  end auto_complete_inf_msg;

  PROCEDURE pr_receive_par_by_xml(pv_filename IN VARCHAR2, pv_filecontent IN clob)
  IS
  BEGIN
      plog.setbeginsection(pkgctx, 'pr_receive_par_by_xml');
      -- Do some thing
      plog.setendsection(pkgctx, 'pr_receive_par_by_xml');
  EXCEPTION WHEN OTHERS THEN
      plog.error(pkgctx, sqlerrm||DBMS_UTILITY.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_receive_par_by_xml');

  END;
  PROCEDURE pr_receive_csv_by_xml(pv_filename IN VARCHAR2, pv_filecontent IN CLOB)
  IS
  BEGIN
      plog.setbeginsection(pkgctx, 'pr_receive_csv_by_xml');
      -- Do some thing
      plog.setendsection(pkgctx, 'pr_receive_csv_by_xml');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm||DBMS_UTILITY.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_receive_csv_by_xml');
  END;

PROCEDURE auto_call_txpks_2231(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_desc        VARCHAR2(1000);
    v_cdate       DATE;

    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2231');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
       p_err_code := '-905555';
       plog.setendsection(pkgctx, 'auto_call_txpks_2231');
       RETURN;
    END IF;

    -- Lay mo ta tu choi luu ky
    /*BEGIN
       SELECT utf8nums.C_CONST_TLTX_TXDESC_2231_NAK
       INTO v_desc
       FROM vsdtrflog
       WHERE autoid = pv_vsdtrfid AND funcname = '542.NEWM.SETR//REAL..NAK';
    EXCEPTION WHEN OTHERS THEN
       v_desc := utf8nums.C_CONST_TLTX_TXDESC_2231;
    END;*/

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2231';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;


    select txdesc into v_desc from tltx where tltxcd = l_txmsg.tltxcd;
    --Lay thong tin dien
    FOR rec IN (
       SELECT rq.brid, se.codeid, se.afacctno, se.acctno,
              dp.depoblock, dp.autoid, dp.depotrade, dp.senddepodate pdate,
              dp.typedepoblock qttytype, dp.depositprice price, sym.parvalue,
              cf.fullname custname, cf.address, cf.idcode license
       FROM semast se, cfmast cf, sbsecurities sym, vsdtxreq rq, sedeposit dp
       WHERE se.custid = cf.custid
         AND sym.codeid = se.codeid
         AND dp.acctno = se.acctno
         AND rq.refcode = dp.autoid
         AND dp.status = 'S'
         AND dp.deltd <> 'Y'
         AND rq.reqid = pv_reqid
         AND se.senddeposit > 0
    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;
        -- Ma chung khoan
        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;
        -- So tieu khoan
        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.afacctno;
        -- So tai khoan SE
        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.acctno;
        -- So luong CK HCCN
        l_txmsg.txfields('04').defname := 'DEPOBLOCK';
        l_txmsg.txfields('04').type := 'N';
        l_txmsg.txfields('04').value := rec.depoblock;
        -- Ma tu tang
        l_txmsg.txfields('05').defname := 'AUTOID';
        l_txmsg.txfields('05').type := 'N';
        l_txmsg.txfields('05').value := rec.autoid;
        -- So luong CK TDCN
        l_txmsg.txfields('06').defname := 'DEPOTRADE';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.depotrade;
        -- Ngay yeu cau
        l_txmsg.txfields('07').defname := 'PDATE';
        l_txmsg.txfields('07').type := 'C';
        l_txmsg.txfields('07').value := rec.pdate;
        -- Loai dieu kien
        l_txmsg.txfields('08').defname := 'QTTYTYPE';
        l_txmsg.txfields('08').type := 'C';
        l_txmsg.txfields('08').value := rec.qttytype;
        -- Gia
        l_txmsg.txfields('09').defname := 'PRICE';
        l_txmsg.txfields('09').type := 'N';
        l_txmsg.txfields('09').value := rec.price;
        -- Tong so luong
        l_txmsg.txfields('10').defname := 'QTTY';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.depoblock + rec.depotrade;
        -- Menh gia
        l_txmsg.txfields('11').defname := 'PARVALUE';
        l_txmsg.txfields('11').type := 'N';
        l_txmsg.txfields('11').value := rec.parvalue;
        -- Mo ta
        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := v_desc;
        -- Ho ten
        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.custname;
        -- Dia chi
        l_txmsg.txfields('91').defname := 'ADDRESS';
        l_txmsg.txfields('91').type := 'C';
        l_txmsg.txfields('91').value := rec.address;
        --92      CMND/GPKD               C
        l_txmsg.txfields('92').defname := 'LICENSE';
        l_txmsg.txfields('92').type := 'C';
        l_txmsg.txfields('92').value := rec.license;

        savepoint bf_transaction;
        BEGIN
          IF txpks_#2231.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2231');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2231');
END auto_call_txpks_2231;
PROCEDURE auto_call_txpks_2246(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;
    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2246');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');
    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2246');
        RETURN;
    END IF;
    -- Lay mo ta giao dich
    BEGIN
       SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2246';
    EXCEPTION WHEN OTHERS THEN
       v_desc := '';
    END;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;
    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2246';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
    --Lay thong tin dien
    FOR rec IN (
       SELECT rq.brid, se.codeid, se.afacctno, se.acctno,
              dp.depoblock, dp.autoid, dp.depotrade, dp.senddepodate pdate,
              dp.typedepoblock qttytype, dp.depositprice price, sym.parvalue,
              cf.fullname custname, cf.address, cf.idcode license,
              dp.depositqtty senddeposit, dp.rdate, dp.wtrade, dp.vsdcode,
              ci.depolastdt, cf.custodycd
       FROM semast se, cfmast cf, sbsecurities sym, vsdtxreq rq, sedeposit dp, cimast ci
       WHERE se.custid = cf.custid
         AND sym.codeid = se.codeid
         AND dp.acctno = se.acctno
         AND rq.refcode = dp.autoid
         AND ci.afacctno = se.afacctno
         AND dp.status = 'S'
         AND dp.deltd <> 'Y'
         AND rq.reqid = pv_reqid
         AND se.senddeposit > 0
    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;
        -- Ma chung khoan
        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;
        -- So tieu khoan
        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.afacctno;
        -- So tai khoan SE
        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.acctno;
        -- So luong CK HCCN
        l_txmsg.txfields('04').defname := 'DEPOBLOCK';
        l_txmsg.txfields('04').type := 'N';
        l_txmsg.txfields('04').value := rec.depoblock;
        -- Ma tu tang
        l_txmsg.txfields('05').defname := 'AUTOID';
        l_txmsg.txfields('05').type := 'N';
        l_txmsg.txfields('05').value := rec.autoid;
        -- So luong CK TDCN
        l_txmsg.txfields('06').defname := 'DEPOTRADE';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.depotrade;
        -- Ngay yeu cau
        l_txmsg.txfields('07').defname := 'PDATE';
        l_txmsg.txfields('07').type := 'C';
        l_txmsg.txfields('07').value := rec.pdate;
        -- Loai dieu kien
        l_txmsg.txfields('08').defname := 'QTTYTYPE';
        l_txmsg.txfields('08').type := 'C';
        l_txmsg.txfields('08').value := rec.qttytype;
        -- Gia
        l_txmsg.txfields('09').defname := 'PRICE';
        l_txmsg.txfields('09').type := 'N';
        l_txmsg.txfields('09').value := rec.price;
        -- So luong
        l_txmsg.txfields('10').defname := 'QTTY';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.senddeposit;
        -- Menh gia
        l_txmsg.txfields('11').defname := 'PARVALUE';
        l_txmsg.txfields('11').type := 'N';
        l_txmsg.txfields('11').value := rec.parvalue;
        -- Tong so luong
        l_txmsg.txfields('12').defname := 'SQTTY';
        l_txmsg.txfields('12').type := 'N';
        l_txmsg.txfields('12').value := rec.depoblock + rec.depotrade;
        -- Ngay GD tro lai
        l_txmsg.txfields('13').defname := 'RDATE';
        l_txmsg.txfields('13').type := 'D';
        l_txmsg.txfields('13').value := rec.rdate;
        -- CK cho GD
        l_txmsg.txfields('14').defname := 'WTRADE';
        l_txmsg.txfields('14').type := 'N';
        l_txmsg.txfields('14').value := rec.wtrade;
        -- Phi luu ky den han
        l_txmsg.txfields('15').defname := 'CIDFPOFEEACR';
        l_txmsg.txfields('15').type := 'N';
        l_txmsg.txfields('15').value := FN_CIGETDEPOFEEAMT(rec.afacctno,rec.codeid,l_effect_date,getcurrdate,rec.depoblock + rec.depotrade);
        -- So TKCK update gia von
        l_txmsg.txfields ('22').defname   := 'VSDCODE';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').value      := rec.vsdcode;
        -- Dien giai
        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := v_desc;
        -- Ngay chuyen ph luu ky den han gan nhat
        l_txmsg.txfields('32').defname := 'DEPOLASTDT';
        l_txmsg.txfields('32').type := 'C';
        l_txmsg.txfields('32').value := rec.depolastdt;
        -- Phi luu ky cong don
        l_txmsg.txfields('33').defname := 'CIDFPOFEEACR';
        l_txmsg.txfields('33').type := 'N';
        l_txmsg.txfields('33').value := FN_CIGETDEPOFEEACR(rec.afacctno,rec.codeid,l_effect_date,getcurrdate,rec.depoblock + rec.depotrade);
        -- So TKLK
        l_txmsg.txfields('88').defname := 'CUSTODYCD';
        l_txmsg.txfields('88').type := 'C';
        l_txmsg.txfields('88').value := rec.custodycd;
        -- Ho ten
        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.custname;
        -- Dia chi
        l_txmsg.txfields('91').defname := 'ADDRESS';
        l_txmsg.txfields('91').type := 'C';
        l_txmsg.txfields('91').value := rec.address;
        -- CMND/GPKD
        l_txmsg.txfields('92').defname := 'LICENSE';
        l_txmsg.txfields('92').type := 'C';
        l_txmsg.txfields('92').value := rec.license;

        savepoint bf_transaction;
        BEGIN
          IF txpks_#2246.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2246');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2246');
END auto_call_txpks_2246;
PROCEDURE auto_call_txpks_2201(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2201');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2201');
        RETURN;
    END IF;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2201';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2201';

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
       SELECT DISTINCT sewd.txdate, sewd.txnum, sewd.txdatetxnum, sewd.withdraw, sewd.blockwithdraw, rq.brid,
              sym.symbol, cf.fullname, se.afacctno, se.acctno, cf.idcode, cf.iddate, cf.address,
              se.codeid, sewd.price, sym.parvalue, iss.fullname issfullname, cf.idplace,
              se.afacctno acctno_updatecost
       FROM semast se, sbsecurities sym, cfmast cf, sewithdrawdtl sewd, vsdtxreq rq, issuers iss
       WHERE rq.reqid = pv_reqid
         AND cf.custid = se.custid
         AND sym.codeid = se.codeid
         AND rq.refcode = sewd.txdatetxnum
         AND se.acctno = sewd.acctno
         AND sym.issuerid = iss.issuerid(+)
         AND se.withdraw + se.blockwithdraw > 0
         AND sewd.status = 'A'
    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;
        -- Ma chung khoan
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').value     := rec.codeid;
        -- So tieu khoan
        l_txmsg.txfields ('02').defname   := 'AFACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').value     := rec.afacctno;
        -- So tai khoan SE
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').value     := rec.acctno;
        -- So tai khoan gia von
        l_txmsg.txfields ('12').defname   := 'ACCTNO_UPDATECOST';
        l_txmsg.txfields ('12').TYPE      := 'C';
        l_txmsg.txfields ('12').value     := rec.acctno_updatecost;
        -- Ten KH
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').value     := rec.fullname;
        -- Dia chi
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').value     := rec.address;
        -- So CMND
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').value     := rec.idcode;
        -- Ngay cap
        l_txmsg.txfields ('95').defname   := 'LICENSEDATE';
        l_txmsg.txfields ('95').TYPE      := 'D';
        l_txmsg.txfields ('95').value     := rec.iddate;
        -- Noi cap
        l_txmsg.txfields ('96').defname   := 'LICENSEPLACE';
        l_txmsg.txfields ('96').TYPE      := 'C';
        l_txmsg.txfields ('96').value     := rec.idplace;
        -- So luong TDGD xin rut
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').value     := rec.withdraw;
        -- Gia luong HCCN xin rut
        l_txmsg.txfields ('14').defname   := 'BLOCKWITHDRAW';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').value     := rec.blockwithdraw;
        -- Tong so luong xin rut
        l_txmsg.txfields ('55').defname   := 'SUMQTTY';
        l_txmsg.txfields ('55').TYPE      := 'N';
        l_txmsg.txfields ('55').value     := rec.withdraw + rec.blockwithdraw;
        -- Menh gia
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').value     := rec.parvalue;
        -- Gia
        l_txmsg.txfields ('09').defname   := 'PRICE';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').value     := rec.price;
        -- Ngay gui yeu cau
        l_txmsg.txfields ('05').defname   := 'TXDATE';
        l_txmsg.txfields ('05').TYPE      := 'D';
        l_txmsg.txfields ('05').value     := rec.txdate;
        -- So chung tu
        l_txmsg.txfields ('06').defname   := 'TXNUM';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').value     := rec.txnum;
        -- Key
        l_txmsg.txfields ('07').defname   := 'TXDATETXNUM';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').value     := rec.txdatetxnum;
        -- Mo ta GD
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').value     := v_desc;
        -- So so co dong
        l_txmsg.txfields ('29').defname   := 'SSCD';
        l_txmsg.txfields ('29').TYPE      := 'C';
        l_txmsg.txfields ('29').value     := null;
        -- T?ngu?i d?t l?nh
        l_txmsg.txfields ('35').defname   := 'TLFULLNAME';
        l_txmsg.txfields ('35').TYPE      := 'C';
        l_txmsg.txfields ('35').value     := null;
        -- Chi nhanh
        l_txmsg.txfields ('36').defname   := 'BRNAME';
        l_txmsg.txfields ('36').TYPE      := 'C';
        l_txmsg.txfields ('36').value     := null;
          -- Ten cong ty
        l_txmsg.txfields ('37').defname   := 'ISSUERSNAME';
        l_txmsg.txfields ('37').TYPE      := 'C';
        l_txmsg.txfields ('37').value     := null;
        savepoint bf_transaction;
        BEGIN
          IF txpks_#2201.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2201');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2201');
  END auto_call_txpks_2201;

  PROCEDURE auto_call_txpks_2294(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);

    v_cdate       DATE;
    v_exist       VARCHAR2(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2294');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2294');
        RETURN;
    END IF;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2294';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
       SELECT DISTINCT sewd.txdate, sewd.txnum, sewd.txdatetxnum, sewd.withdraw, sewd.blockwithdraw, rq.brid,
              sym.symbol, cf.fullname, se.afacctno, se.acctno, cf.idcode, cf.iddate, cf.address
       FROM semast se, sbsecurities sym, cfmast cf, sewithdrawdtl sewd, vsdtxreq rq
       WHERE rq.reqid = pv_reqid
         AND cf.custid = se.custid
         AND sym.codeid = se.codeid
         AND rq.refcode = sewd.txdatetxnum
         AND se.acctno = sewd.acctno
         AND se.withdraw + se.blockwithdraw > 0
         AND sewd.status = 'A'
    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;
        -- So tieu khoan
        l_txmsg.txfields ('02').defname   := 'AFACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').value     := rec.afacctno;
        -- So tai khoan SE
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').value     := rec.acctno;
        -- Ma CK
        l_txmsg.txfields ('04').defname   := 'SYMBOL';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').value     := rec.symbol;
        -- Ngay lam yeu cau
        l_txmsg.txfields ('05').defname   := 'TXDATE';
        l_txmsg.txfields ('05').TYPE      := 'D';
        l_txmsg.txfields ('05').value     := rec.txdate;
        -- So chung tu yeu cau
        l_txmsg.txfields ('06').defname   := 'TXNUM';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').value     := rec.txnum;
        -- Key yeu cau
        l_txmsg.txfields ('07').defname   := 'TXDATETXNUM';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').value     := rec.txdatetxnum;
        -- So luong GD xin rut
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').value     := rec.withdraw;
        -- So luong HCCN xin rut
        l_txmsg.txfields ('14').defname   := 'BLOCKWITHDRAW';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').value     := rec.blockwithdraw;
        -- Tong cong
        l_txmsg.txfields ('55').defname   := 'SUMQTTY';
        l_txmsg.txfields ('55').TYPE      := 'N';
        l_txmsg.txfields ('55').value     := rec.withdraw + rec.blockwithdraw;
        -- Ten KH
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').value     := rec.fullname;
        -- So CMND
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').value     := rec.idcode;
        -- Ngay cap
        l_txmsg.txfields ('95').defname   := 'LICENSEDATE';
        l_txmsg.txfields ('95').TYPE      := 'D';
        l_txmsg.txfields ('95').value     := rec.iddate;
        -- Dia chi
        l_txmsg.txfields ('97').defname   := 'ADDRESS';
        l_txmsg.txfields ('97').TYPE      := 'C';
        l_txmsg.txfields ('97').value     := rec.address;
        -- Mo ta
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').value     := 'VSD tu choi ho so rut CK';

        savepoint bf_transaction;
        BEGIN
          IF txpks_#2294.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to savepoint bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2294');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2294');
  END auto_call_txpks_2294;
  -- Chuyen - Nhan ck
PROCEDURE auto_call_txpks_2265(pv_reqid    NUMBER, pv_vsdtrfid NUMBER, p_err_code  OUT VARCHAR2) AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc  VARCHAR2(1000);
    v_cdate DATE;
    v_exist VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2265');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2294');
        RETURN;
    END IF;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2265';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
     select seo.*, cf.fullname, cf.custodycd, af.acctno afacctno,sec.symbol, se.costprice, rq.brid
       from sesendout seo, cfmast cf, afmast af,sbsecurities sec, semast se, vsdtxreq rq
       where substr(seo.acctno, 0, 10) = af.acctno
         and af.custid = cf.custid
         and sec.codeid = seo.codeid
         and se.acctno = seo.acctno
         and seo.strade + seo.sblocked + seo.scaqtty /*+ seo.srightoffqtty + seo.scaqttyreceiv + seo.scaqttydb + seo.scaamtreceiv + seo.srightqtty*/ > 0
         and deltd = 'N'
         and rq.refcode = to_char(seo.autoid)
         and rq.reqid = pv_reqid

    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;

        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.afacctno;

        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.acctno;

        l_txmsg.txfields('05').defname := 'CUSTODYCD';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := rec.custodycd;

        l_txmsg.txfields('06').defname := 'BLOCKED';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.sblocked;

        l_txmsg.txfields('07').defname := 'SYMBOL';
        l_txmsg.txfields('07').type := 'C';
        l_txmsg.txfields('07').value := rec.symbol;

        l_txmsg.txfields('10').defname := 'TRADE';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.strade;

        l_txmsg.txfields('12').defname := 'QTTY';
        l_txmsg.txfields('12').type := 'N';
        l_txmsg.txfields('12').value := rec.strade + rec.sblocked;

        l_txmsg.txfields('13').defname := 'CAQTTY';
        l_txmsg.txfields('13').type := 'N';
        l_txmsg.txfields('13').value := rec.scaqtty;

        l_txmsg.txfields('18').defname := 'AUTOID';
        l_txmsg.txfields('18').type := 'N';
        l_txmsg.txfields('18').value := rec.autoid;

        l_txmsg.txfields('23').defname := 'RECUSTODYCD';
        l_txmsg.txfields('23').type := 'C';
        l_txmsg.txfields('23').value := rec.recustodycd;

        l_txmsg.txfields('24').defname := 'RECUSTNAME';
        l_txmsg.txfields('24').type := 'C';
        l_txmsg.txfields('24').value := rec.recustname;

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := 'VSD tu choi';

        l_txmsg.txfields('55').defname := 'REAFACCTNO';
        l_txmsg.txfields('55').type := 'C';
        l_txmsg.txfields('55').value := '';

        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.fullname;

       /*  --RIGHTOFFQTTY
        l_txmsg.txfields ('14').defname   := 'RIGHTOFFQTTY';
        l_txmsg.txfields ('14').TYPE   := 'N';
        l_txmsg.txfields ('14').VALUE   := REC.SRIGHTOFFQTTY;
        --CAQTTYRECEIV
        l_txmsg.txfields ('15').defname   := 'CAQTTYRECEIV';
        l_txmsg.txfields ('15').TYPE   := 'N';
        l_txmsg.txfields ('15').VALUE   := REC.SCAQTTYRECEIV;
        --CAQTTYDB
        l_txmsg.txfields ('16').defname   := 'CAQTTYDB';
        l_txmsg.txfields ('16').TYPE   := 'N';
        l_txmsg.txfields ('16').VALUE   := REC.SCAQTTYDB;
        --CAAMTRECEIV
        l_txmsg.txfields ('17').defname   := 'CAAMTRECEIV';
        l_txmsg.txfields ('17').TYPE   := 'N';
        l_txmsg.txfields ('17').VALUE   := REC.SCAAMTRECEIV;

        --RIGHTQTTY
        l_txmsg.txfields ('19').defname   := 'RIGHTQTTY';
        l_txmsg.txfields ('19').TYPE   := 'N';
        l_txmsg.txfields ('19').VALUE   := REC.SRIGHTQTTY;
         --VSDMESSAGETYPE
        l_txmsg.txfields ('97').defname   := 'VSDMESSAGETYPE';
        l_txmsg.txfields ('97').TYPE   := 'C';
        l_txmsg.txfields ('97').VALUE   := REC.VSDMESSAGETYPE;*/
        savepoint bf_transaction;
        BEGIN
          IF txpks_#2265.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2265');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2265');
  END auto_call_txpks_2265;
  PROCEDURE auto_call_txpks_2266(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2266');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2201');
        RETURN;
    END IF;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2266';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2201';

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
       select seo.*, cf.fullname, cf.custodycd, af.acctno afacctno,
              sec.symbol, se.costprice, af.acctno acctno_updatecost, rq.brid
       from sesendout seo, cfmast cf, afmast af,
            sbsecurities sec, semast se, vsdtxreq rq
       where substr(seo.acctno, 0, 10) = af.acctno
         and af.custid = cf.custid
         and sec.codeid = seo.codeid
         and se.acctno = seo.acctno
         and seo.strade + seo.sblocked + seo.scaqtty /*+ seo.srightoffqtty + seo.scaqttyreceiv + seo.scaqttydb + seo.scaamtreceiv + seo.srightqtty*/ >0
         and deltd = 'N'
         and rq.txdate||rq.objkey = seo.ID2255
         and rq.reqid = pv_reqid
         and seo.vsdmessagetype = '542'

    ) LOOP

        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

       /* l_txmsg.txfields('15').defname := 'ACCTNO_UPDATECOST';
        l_txmsg.txfields('15').type := 'C';
        l_txmsg.txfields('15').value := rec.acctno_updatecost;

        l_txmsg.txfields('16').defname := 'PRICE';
        l_txmsg.txfields('16').type := 'N';
        l_txmsg.txfields('16').value := rec.price;*/

        l_txmsg.txfields('18').defname := 'AUTOID';
        l_txmsg.txfields('18').type := 'N';
        l_txmsg.txfields('18').value := rec.autoid;

        l_txmsg.txfields('05').defname := 'CUSTODYCD';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := rec.custodycd;

        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.afacctno;

        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.acctno;

        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.fullname;

        l_txmsg.txfields('07').defname := 'SYMBOL';
        l_txmsg.txfields('07').type := 'C';
        l_txmsg.txfields('07').value := rec.symbol;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;

        l_txmsg.txfields('10').defname := 'TRADE';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.strade;

        l_txmsg.txfields('06').defname := 'BLOCKED';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.sblocked;

        l_txmsg.txfields('13').defname := 'CAQTTY';
        l_txmsg.txfields('13').type := 'N';
        l_txmsg.txfields('13').value := rec.scaqtty;

        l_txmsg.txfields('23').defname := 'RECUSTODYCD';
        l_txmsg.txfields('23').type := 'C';
        l_txmsg.txfields('23').value := rec.recustodycd;

        l_txmsg.txfields('24').defname := 'RECUSTNAME';
        l_txmsg.txfields('24').type := 'C';
        l_txmsg.txfields('24').value := rec.recustname;

        l_txmsg.txfields('12').defname := 'QTTY';
        l_txmsg.txfields('12').type := 'N';
        l_txmsg.txfields('12').value := rec.sblocked + rec.strade;

        l_txmsg.txfields('14').defname := 'QTTYTYPE';
        l_txmsg.txfields('14').type := 'C';
        l_txmsg.txfields('14').value := '002';

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := 'VSD chap thuan rut CK';

        l_txmsg.txfields('08').defname := 'PRODUCTTYPE';
        l_txmsg.txfields('08').type := 'C';
        l_txmsg.txfields('08').value := '';

        l_txmsg.txfields('09').defname := 'PRICE';
        l_txmsg.txfields('09').type := 'N';
        l_txmsg.txfields('09').value := '';

        l_txmsg.txfields('26').defname := 'FEEAMT';
        l_txmsg.txfields('26').type := 'N';
        l_txmsg.txfields('26').value := '';

        l_txmsg.txfields('27').defname := 'FEEAMT';
        l_txmsg.txfields('27').type := 'N';
        l_txmsg.txfields('27').value := '';

        l_txmsg.txfields('28').defname := 'FEEAMTSV';
        l_txmsg.txfields('28').type := 'N';
        l_txmsg.txfields('28').value := '';

        l_txmsg.txfields('55').defname := 'REAFACCTNO';
        l_txmsg.txfields('55').type := 'C';
        l_txmsg.txfields('55').value := '';

        l_txmsg.txfields('98').defname := 'PRODUCTTYPECR';
        l_txmsg.txfields('98').type := 'C';
        l_txmsg.txfields('98').value := '';
      /*  l_txmsg.txfields ('19').defname   := 'RIGHTQTTY';
        l_txmsg.txfields ('19').TYPE   := 'N';
        l_txmsg.txfields ('19').VALUE   := REC.SRIGHTQTTY;

        l_txmsg.txfields ('20').defname   := 'RIGHTOFFQTTY';
        l_txmsg.txfields ('20').TYPE   := 'N';
        l_txmsg.txfields ('20').VALUE   := REC.SRIGHTOFFQTTY;

        l_txmsg.txfields ('21').defname   := 'CAQTTYRECEIV';
        l_txmsg.txfields ('21').TYPE   := 'N';
        l_txmsg.txfields ('21').VALUE   := REC.SCAQTTYRECEIV;

        l_txmsg.txfields ('22').defname   := 'CAQTTYDB';
        l_txmsg.txfields ('22').TYPE   := 'N';
        l_txmsg.txfields ('22').VALUE   := REC.SCAQTTYDB;

        l_txmsg.txfields ('17').defname   := 'CAAMTRECEIV';
        l_txmsg.txfields ('17').TYPE   := 'N';
        l_txmsg.txfields ('17').VALUE   := REC.SCAAMTRECEIV;

        l_txmsg.txfields ('97').defname   := 'VSDMESSAGETYPE';
        l_txmsg.txfields ('97').TYPE   := 'C';
        l_txmsg.txfields ('97').VALUE   := REC.VSDMESSAGETYPE;
*/
        savepoint bf_transaction;
        BEGIN
          IF txpks_#2266.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2266');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2266');
  END auto_call_txpks_2266;

  PROCEDURE auto_call_txpks_2245(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);

    v_reafacctno  VARCHAR2(10);
    v_depolastdt  DATE;
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2245');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist
    FROM vsdtxreq req, vsdtrfcode trf
    WHERE req.reqid = pv_reqid AND req.trfcode = trf.trfcode
      AND (req.msgstatus in ('A', 'S') OR (trf.type = 'INF' AND req.msgstatus IN ('C')));

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2245');
        RETURN;
    END IF;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2245';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2245';

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN
    (   SELECT re.autoid, re.reqid, re.recustodycd, sb.codeid, re.trade, re.blocked,
               de.depositid, sb.parvalue, re.trftxnum, re.reseacctno, rq.brid,
               cf.fullname, cf.idcode, cf.address, inf.basicprice, sb.refcodeid,
               I.SHORTNAME||': '||I.FULLNAME ISSUERNAME,A.CDCONTENT TRADEPLACE
        FROM sereceived re, sbsecurities sb, securities_info inf, cfmast cf,
             deposit_member de, vsdtxreq rq, ISSUERS i, allcode a
        WHERE re.symbol = sb.symbol
          AND sb.codeid = inf.codeid
          AND re.recustodycd = cf.custodycd
          AND re.frbiccode = de.biccode
          AND re.reqid = rq.reqid
          AND i.issuerid = sb.issuerid
          AND re.status = 'A'
          AND A.CDTYPE = 'SA' AND A.CDNAME = 'TRADEPLACE' AND A.CDVAL= sb.tradeplace
          AND re.reqid = pv_reqid

    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        IF rec.reseacctno IS NULL THEN
           SELECT af.acctno INTO v_reafacctno FROM afmast af, cfmast cf
           WHERE cf.custid = af.custid
             AND af.status = 'A'
             AND cf.custodycd = rec.recustodycd
             AND rownum = 1;
        ELSE
           v_reafacctno := substr(rec.reseacctno,0,10);
        END IF;

        SELECT depolastdt INTO v_depolastdt FROM cimast WHERE acctno = v_reafacctno;

        l_txmsg.txfields('00').defname := 'FEETYPE';
        l_txmsg.txfields('00').type := 'C';
        l_txmsg.txfields('00').value := 'VSDDEP';

        l_txmsg.txfields('99').defname := 'AUTOID';
        l_txmsg.txfields('99').type := 'C';
        l_txmsg.txfields('99').value := '';

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;

        l_txmsg.txfields('02').defname := 'REQID';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.reqid;

        l_txmsg.txfields('03').defname := 'INWARD';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.depositid;

        l_txmsg.txfields('88').defname := 'CUSTODYCD';
        l_txmsg.txfields('88').type := 'C';
        l_txmsg.txfields('88').value := rec.recustodycd;

        l_txmsg.txfields('04').defname := 'AFACCT2';
        l_txmsg.txfields('04').type := 'C';
        l_txmsg.txfields('04').value := v_reafacctno;

        /*l_txmsg.txfields('25').defname := 'ACCTNO_UPDATECOST';
        l_txmsg.txfields('25').type := 'C';
        l_txmsg.txfields('25').value := v_reafacctno || nvl(rec.refcodeid, rec.codeid);
        */

        l_txmsg.txfields('05').defname := 'ACCT2';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := v_reafacctno || rec.codeid;

        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.fullname;

        l_txmsg.txfields('91').defname := 'ADDRESS';
        l_txmsg.txfields('91').type := 'C';
        l_txmsg.txfields('91').value := rec.address;

        l_txmsg.txfields('92').defname := 'LICENSE';
        l_txmsg.txfields('92').type := 'C';
        l_txmsg.txfields('92').value := rec.idcode;

        l_txmsg.txfields('09').defname := 'PRICE';
        l_txmsg.txfields('09').type := 'N';
        l_txmsg.txfields('09').value := rec.basicprice;

        l_txmsg.txfields('10').defname := 'AMT';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.trade;

        l_txmsg.txfields('06').defname := 'DEPOBLOCK';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.blocked;

        l_txmsg.txfields('12').defname := 'QTTY';
        l_txmsg.txfields('12').type := 'N';
        l_txmsg.txfields('12').value := rec.trade + rec.blocked;

        l_txmsg.txfields('11').defname := 'PARVALUE';
        l_txmsg.txfields('11').type := 'N';
        l_txmsg.txfields('11').value := rec.parvalue;

        l_txmsg.txfields('14').defname := 'QTTYTYPE';
        l_txmsg.txfields('14').type := 'C';
        l_txmsg.txfields('14').value := '002';

        l_txmsg.txfields('31').defname := 'TRTYPE';
        l_txmsg.txfields('31').type := 'C';
        l_txmsg.txfields('31').value := '002';

        l_txmsg.txfields('32').defname := 'DEPOLASTDT';
        l_txmsg.txfields('32').type := 'C';
        l_txmsg.txfields('32').value := to_char(v_depolastdt, 'DD/MM/RRRR');

        l_txmsg.txfields('15').defname := 'DEPOFEEAMT';
        l_txmsg.txfields('15').type := 'N';
        l_txmsg.txfields('15').value := FN_CIGETDEPOFEEAMT(v_reafacctno, rec.codeid, to_char(l_txmsg.busdate,'DD/MM/RRRR'), to_char(l_txmsg.txdate,'DD/MM/RRRR'), rec.trade + rec.blocked);

        l_txmsg.txfields('13').defname := 'DEPOFEEACR';
        l_txmsg.txfields('13').type := 'N';
        l_txmsg.txfields('13').value := FN_CIGETDEPOFEEACR(v_reafacctno, rec.codeid, to_char(l_txmsg.busdate,'DD/MM/RRRR'), to_char(l_txmsg.txdate,'DD/MM/RRRR'), rec.trade + rec.blocked);

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := v_desc;

        /*l_txmsg.txfields('20').defname := 'ISSUERNAME';
        l_txmsg.txfields('20').type := 'C';
        l_txmsg.txfields('20').value := rec.ISSUERNAME;

        l_txmsg.txfields('21').defname := 'TRADEPLACE';
        l_txmsg.txfields('21').type := 'C';
        l_txmsg.txfields('21').value := rec.TRADEPLACE;*/

        l_txmsg.txfields('16').defname := 'DEPOTYPE';
        l_txmsg.txfields('16').type := 'C';
        l_txmsg.txfields('16').value := '';

        l_txmsg.txfields('33').defname := 'DRFEETYPE';
        l_txmsg.txfields('33').type := 'C';
        l_txmsg.txfields('33').value := '';

        l_txmsg.txfields('34').defname := 'CACULATETYPE';
        l_txmsg.txfields('34').type := 'C';
        l_txmsg.txfields('34').value := '';

        l_txmsg.txfields('45').defname := 'FEE';
        l_txmsg.txfields('45').type := 'N';
        l_txmsg.txfields('45').value := '';

        l_txmsg.txfields('55').defname := 'FEECOMP';
        l_txmsg.txfields('55').type := 'N';
        l_txmsg.txfields('55').value := '';

        l_txmsg.txfields('98').defname := 'Type';
        l_txmsg.txfields('98').type := 'C';
        l_txmsg.txfields('98').value := '';
        savepoint bf_transaction;
        BEGIN
          IF txpks_#2245.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2245');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2245');
  END auto_call_txpks_2245;

  -- nhan ckck khac tv
  PROCEDURE auto_call_txpks_2226(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);

    v_reafacctno  VARCHAR2(10);
    v_depolastdt  DATE;
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2226');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist
    FROM vsdtxreq req, vsdtrfcode trf
    WHERE req.reqid = pv_reqid AND req.trfcode = trf.trfcode
      AND (req.msgstatus in ('A', 'S') OR (trf.type = 'INF' AND req.msgstatus IN ('C')));

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2226');
        RETURN;
    END IF;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2226';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2245';

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN
    (   SELECT re.autoid, re.reqid,re.custodycd, re.recustodycd, sb.codeid, re.trade, re.blocked,
               de.depositid, sb.parvalue, re.trftxnum, re.reseacctno, rq.brid, sb.refcodeid
        FROM sereceived re, sbsecurities sb, cfmast cf, deposit_member de, vsdtxreq rq
        WHERE re.symbol = sb.symbol
          AND re.recustodycd = cf.custodycd
          AND re.frbiccode = de.biccode
          AND re.reqid = rq.reqid
          AND re.status = 'A'
          AND re.reqid = pv_reqid

    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        IF rec.reseacctno IS NULL THEN
           SELECT af.acctno INTO v_reafacctno FROM afmast af, cfmast cf
           WHERE cf.custid = af.custid
             AND af.status = 'A'
             AND cf.custodycd = rec.recustodycd
             AND rownum = 1;
        ELSE
           v_reafacctno := substr(rec.reseacctno,0,10);
        END IF;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;

        l_txmsg.txfields('02').defname := 'REQID';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.reqid;

        l_txmsg.txfields('87').defname := 'CUSTODYCD';
        l_txmsg.txfields('87').type := 'C';
        l_txmsg.txfields('87').value := rec.custodycd;

        l_txmsg.txfields('88').defname := 'RECUSTODYCD';
        l_txmsg.txfields('88').type := 'C';
        l_txmsg.txfields('88').value := rec.recustodycd;

        l_txmsg.txfields('04').defname := 'AFACCTNO';
        l_txmsg.txfields('04').type := 'C';
        l_txmsg.txfields('04').value := v_reafacctno;

        l_txmsg.txfields('05').defname := 'ACCTNO';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := v_reafacctno || rec.codeid;

        l_txmsg.txfields('10').defname := 'AMT';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.trade;

        l_txmsg.txfields('06').defname := 'DEPOBLOCK';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.blocked;

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := v_desc;

        savepoint bf_transaction;
        BEGIN
          IF txpks_#2226.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2226');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2226');
  END auto_call_txpks_2226;
  --
  PROCEDURE auto_call_txpks_2276(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_cdate       DATE;

    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2276');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
       p_err_code := '-905555';
       plog.setendsection(pkgctx, 'auto_call_txpks_2276');
       RETURN;
    END IF;

    -- Khong goi GD neu cau truc dien khong hop le(nak, 596err)
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtrflog
    WHERE autoid = pv_vsdtrfid
    AND funcname IN ('540.NEWM.SETR//TRAD.NAK', '596.');

    IF v_exist <> 'N' THEN
       UPDATE sereceived SET reseacctno = '', status = 'P'
       WHERE autoid IN (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid);
       plog.setendsection(pkgctx, 'auto_call_txpks_2284');
       RETURN;
    END IF;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2276';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
       SELECT re.autoid, re.recustodycd, re.custodycd, re.symbol,
              sb.codeid, re.trade, re.blocked, re.reseacctno, req.brid,
              cf.fullname custname, SUBSTR(re.reseacctno, 1, 10) reafacctno
       FROM sereceived re, sbsecurities sb, cfmast cf, vsdtxreq req
       WHERE re.symbol = sb.symbol
         AND re.recustodycd = cf.custodycd
         AND re.autoid = req.refcode
         AND re.status = 'A' AND re.deltd <> 'Y'
         AND req.reqid = pv_reqid
    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        -- So TKLK nhan
        l_txmsg.txfields('02').defname := 'CUSTODYCD';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.recustodycd;

        -- So tieu khoan nhan
        l_txmsg.txfields('03').defname := 'AFACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.reafacctno;

        -- So tieu khoan SE nhan
        l_txmsg.txfields('04').defname := 'ACCTNO';
        l_txmsg.txfields('04').type := 'C';
        l_txmsg.txfields('04').value := rec.reseacctno;

        -- Ho ten nguoi nhan
        l_txmsg.txfields('05').defname := 'CUSTNAME';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := rec.custname;

        -- So TKLK chuyen khoan
        l_txmsg.txfields('09').defname := 'DECUSTODYCD';
        l_txmsg.txfields('09').type := 'C';
        l_txmsg.txfields('09').value := rec.custodycd;

        -- Ma chung khoan
        l_txmsg.txfields('10').defname := 'CODEID';
        l_txmsg.txfields('10').type := 'C';
        l_txmsg.txfields('10').value := rec.codeid;

        -- Ma chung khoan
        l_txmsg.txfields('11').defname := 'BLOCK';
        l_txmsg.txfields('11').type := 'N';
        l_txmsg.txfields('11').value := rec.blocked;

        -- So luong CK HCCN
        l_txmsg.txfields('12').defname := 'TRADE';
        l_txmsg.txfields('12').type := 'N';
        l_txmsg.txfields('12').value := rec.trade;

        -- Ma dinh danh
        l_txmsg.txfields('15').defname := 'AUTOID';
        l_txmsg.txfields('15').type := 'C';
        l_txmsg.txfields('15').value := rec.autoid;

        -- Dien giai
        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := '';

        savepoint bf_transaction;
        BEGIN
          IF txpks_#2276.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2276');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2276');
  END auto_call_txpks_2276;
  PROCEDURE auto_call_txpks_2248(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;
    v_desc          VARCHAR(200);
    v_cdate       DATE;
    v_exist       VARCHAR(1);
    l_count2248   number;
    l_count2247   number;
    l_custid      varchar2(30);
    l_custotycd   varchar2(30);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2248');
    v_cdate  := getcurrdate;
     SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2248';
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2248');
        RETURN;
    END IF;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2248';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
       SELECT FN_GET_LOCATION(SUBSTR(A.AFACCTNO, 1, 4)) LOCATION, AF.CUSTID,
              REPLACE(A.ACCTNO, '.', '') ACCTNO, A.SYMBOL,
              REPLACE(A.AFACCTNO, '.', '') AFACCTNO, A.DTOCLOSE, A.CODEID, A.PARVALUE,
              A.SELASTDATE, A.AFLASTDATE, A.LASTDATE, A.CUSTODYCD, A.BLOCKDTOCLOSE,
              A.FULLNAME, A.IDCODE, A.TYPENAME, A.TRADEPLACE, A.tocustodycd, A.TOAFACCTNO,
              A.SENDPBALANCE, A.SENDAMT, A.SENDAQTTY, A.RIGHTQTTY, A.QTTY, RQ.BRID
       FROM V_SE2248 A, VSDTXREQ RQ, CFMAST CF, AFMAST AF
       WHERE CF.CUSTID = AF.CUSTID
         AND RQ.REFCODE = REPLACE(A.ACCTNO, '.', '')
         and af.acctno =  REPLACE(A.AFACCTNO, '.', '')
         AND A.CUSTODYCD = CF.CUSTODYCD
         AND RQ.REQID = PV_REQID
         AND rq.objkey = a.txnum
    ) LOOP
        l_custid    := rec.custid;
        l_custotycd := rec.custodycd;
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        l_txmsg.txfields('09').defname := 'BLOCKDTOCLOSE';
        l_txmsg.txfields('09').type := 'N';
        l_txmsg.txfields('09').value := rec.BLOCKDTOCLOSE;

        l_txmsg.txfields('33').defname := 'CUSTNAMER';
        l_txmsg.txfields('33').type := 'C';
        l_txmsg.txfields('33').value := '';

        l_txmsg.txfields('14').defname := 'RIGHTOFFQTTY';
        l_txmsg.txfields('14').type := 'N';
        l_txmsg.txfields('14').value := rec.sendpbalance;

        l_txmsg.txfields('16').defname := 'CAQTTYDB';
        l_txmsg.txfields('16').type := 'N';
        l_txmsg.txfields('16').value := rec.sendaqtty;

        l_txmsg.txfields('17').defname := 'CAAMTRECEIV';
        l_txmsg.txfields('17').type := 'N';
        l_txmsg.txfields('17').value := rec.sendamt;

        l_txmsg.txfields('18').defname := 'RIGHTQTTY';
        l_txmsg.txfields('18').type := 'N';
        l_txmsg.txfields('18').value := rec.rightqtty;

        l_txmsg.txfields('15').defname := 'CAQTTYRECEIV';
        l_txmsg.txfields('15').type := 'N';
        l_txmsg.txfields('15').value := rec.qtty;

        l_txmsg.txfields('11').defname := 'PARVALUE';
        l_txmsg.txfields('11').type := 'N';
        l_txmsg.txfields('11').value := rec.parvalue;

        l_txmsg.txfields('08').defname := 'DTOCLOSE';
        l_txmsg.txfields('08').type := 'N';
        l_txmsg.txfields('08').value := rec.DTOCLOSE;

        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.fullname;

        l_txmsg.txfields('10').defname := 'QTTY';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.dtoclose;

        l_txmsg.txfields('88').defname := 'CUSTODYCD';
        l_txmsg.txfields('88').type := 'C';
        l_txmsg.txfields('88').value := rec.custodycd;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.codeid;

        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.afacctno;

        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.acctno;

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := v_desc;

        l_txmsg.txfields('92').defname := 'AFACCTNO';
        l_txmsg.txfields('92').type := 'C';
        l_txmsg.txfields('92').value := rec.TOAFACCTNO;

        l_txmsg.txfields('98').defname := 'CUSTODYCD';
        l_txmsg.txfields('98').type := 'C';
        l_txmsg.txfields('98').value := rec.tocustodycd;
        savepoint bf_transaction;
        BEGIN
          IF txpks_#2248.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;

      if p_err_code = systemnums.c_success and LENGTH(nvl(l_custid,'')) > 0 then
        select count(*) into l_count2248
        from v_se2248 se, afmast af
        where se.afacctno = af.acctno and af.custid = l_custid;

        select count(*) into l_count2247
        from v_se2247 se, afmast af
        where se.afacctno = af.acctno and af.custid = l_custid;

        IF l_count2248 = 0 and l_count2247 = 0 THEN
            savepoint bf_transaction_0059;
            BEGIN
                auto_call_txpks_0059_2(pv_reqid,l_custotycd, 'Y', l_txmsg.reftxnum, p_err_code );
                IF p_err_code <> systemnums.c_success THEN
                    ROLLBACK to bf_transaction_0059;
                    ROLLBACK to bf_transaction;
                END IF;
            END;
        end if;
      END IF;
    plog.setendsection(pkgctx, 'auto_call_txpks_2248');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2248');
  END auto_call_txpks_2248;
  PROCEDURE auto_call_txpks_2290(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_cdate       DATE;
    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2290');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_2294');
        RETURN;
    END IF;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '2290';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN (
       SELECT a.*, rq.brid from v_se2290 a, vsdtxreq rq
        WHERE rq.refcode = a.ACCTNO
          AND rq.reqid = pv_reqid
    ) LOOP
        SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.afacctno;

        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.acctno;

        l_txmsg.txfields('04').defname := 'SYMBOL';
        l_txmsg.txfields('04').type := 'C';
        l_txmsg.txfields('04').value := rec.symbol;

        l_txmsg.txfields('05').defname := 'STATUS';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := rec.status;

        l_txmsg.txfields('06').defname := 'TRADE';
        l_txmsg.txfields('06').type := 'N';
        l_txmsg.txfields('06').value := rec.trade;

        l_txmsg.txfields('10').defname := 'DTOCLOSE';
        l_txmsg.txfields('10').type := 'N';
        l_txmsg.txfields('10').value := rec.dtoclose;

        l_txmsg.txfields('11').defname := 'DTBLOCKED';
        l_txmsg.txfields('11').type := 'N';
        l_txmsg.txfields('11').value := rec.BLOCKDTOCLOSE;

        l_txmsg.txfields('14').defname := 'RIGHTOFFQTTY';
        l_txmsg.txfields('14').type := 'N';
        l_txmsg.txfields('14').value := rec.sendpbalance;

        l_txmsg.txfields('15').defname := 'CAQTTYRECEIV';
        l_txmsg.txfields('15').type := 'N';
        l_txmsg.txfields('15').value := rec.qtty;

        l_txmsg.txfields('17').defname := 'CAAMTRECEIV';
        l_txmsg.txfields('17').type := 'N';
        l_txmsg.txfields('17').value := rec.sendamt;

        l_txmsg.txfields('18').defname := 'RIGHTQTTY';
        l_txmsg.txfields('18').type := 'N';
        l_txmsg.txfields('18').value := rec.rightqtty;

        l_txmsg.txfields('16').defname := 'CAQTTYDB';
        l_txmsg.txfields('16').type := 'N';
        l_txmsg.txfields('16').value := rec.sendaqtty;

        l_txmsg.txfields('30').defname := 'DESCRIPTION';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := '';

        savepoint bf_transaction;
        BEGIN
          IF txpks_#2290.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_2290');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2290');
  END auto_call_txpks_2290;

--HSX04
procedure auto_call_func_0035(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
    v_custodycd    varchar2(10);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_0035');

    select msgacct into v_custodycd from vsdtxreq where reqid = pv_reqid;
    update cfmast set NSDSTATUS = 'A' where custodycd = v_custodycd;

    plog.setendsection(pkgctx, 'auto_call_func_0035');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_0035');
END auto_call_func_0035;

procedure auto_call_txpks_0012(pv_reqid    number,
                               pv_vsdtrfid number,
                               p_err_code  out VARCHAR2) as
  v_custodycd     VARCHAR2(10);
  v_DEPO          VARCHAR2(100);
  v_DPPD          VARCHAR2(100);
  v_CASHVI        VARCHAR2(100);
  v_PCOD          VARCHAR2(100);
  v_SIDC          VARCHAR2(1000);
  v_TRCD          VARCHAR2(100);
  begin
  plog.setbeginsection(pkgctx, 'auto_call_txpks_0012');

  BEGIN
    select msgacct into v_custodycd from vsdtxreq where reqid = pv_reqid;
    SELECT max(CASE WHEN fldname = 'DEPO' THEN replace(fldval,CHR(10),'') ELSE '' END) DEPO,
         max(CASE WHEN fldname = 'DPPD' THEN replace(fldval,CHR(10),'') ELSE '' END) DPPD,
         max(CASE WHEN fldname = 'CASHVI' THEN replace(fldval,CHR(10),'') ELSE '' END) CASHVI,
         max(CASE WHEN fldname = 'PCOD' THEN replace(fldval,CHR(10),'') ELSE '' END) PCOD,
         max(CASE WHEN fldname = 'SIDC' THEN replace(fldval,CHR(10),'') ELSE '' END) SIDC,
         max(CASE WHEN fldname = 'TRCD' THEN replace(fldval,CHR(10),'') ELSE '' END) TRCD
    INTO v_DEPO, v_DPPD, v_CASHVI, v_PCOD, v_SIDC,v_TRCD
    FROM vsdtrflog vsd, vsdtrflogdtl dtl
    WHERE vsd.referenceid = pv_reqid AND vsd.autoid = dtl.refautoid;
  EXCEPTION WHEN no_data_found THEN
    v_custodycd := '';
    v_DEPO := '';
    v_DPPD := '';
    v_CASHVI := '';
    v_PCOD := '';
    v_SIDC := '';
    v_TRCD := '';
  END;

  update cfmast set nsdstatus = 'C', activests = 'Y', DEPO = v_DEPO, dppd = v_dppd,
         cashvi = v_cashvi, pcod = v_pcod, sidc = v_sidc, TRCD = v_TRCD
  where custodycd = v_custodycd;

  plog.setendsection(pkgctx, 'auto_call_txpks_0012');

  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_0012');
end auto_call_txpks_0012;

procedure auto_call_func_cfrej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
    v_custodycd    varchar2(10);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_cfrej');

    select msgacct into v_custodycd from vsdtxreq where reqid = pv_reqid;
    update cfmast set NSDSTATUS = 'R' where custodycd = v_custodycd;

    plog.setendsection(pkgctx, 'auto_call_func_cfrej');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_cfrej');
  END auto_call_func_cfrej;

procedure auto_call_txpks_0004(pv_reqid    number,
                                 pv_vsdtrfid number,
                                 p_err_code  out varchar2) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
  begin
    plog.setbeginsection(pkgctx, 'auto_call_txpks_0029');
    --Lay thong tin dien tu choi
    for rec0 in (select req.*
                   from vsdtxreq req
                  WHERE req.reqid = pv_reqid) loop

      l_tltxcd       := '0004';
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

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;
      plog.info(pkgctx, 'process req id:' || pv_reqid); -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

      for rec in
        (SELECT REQ.REQID,
                         REQ.OBJNAME,
                         REQ.AFACCTNO,
                         REQ.TRFCODE,
                         CFL.CUSTID,
                         CFL.OFULLNAME,
                         CFL.NFULLNAME,
                         CFL.OADDRESS,
                         CFL.NADDRESS,
                         CFL.OIDCODE,
                         CFL.NIDCODE,
                         CFL.OIDDATE,
                         CFL.NIDDATE,
                         OTRADINGCODE,
                         NTRADINGCODE,
                         CFL.TXDATE,
                         CFL.TXNUM,
                         CFL.CONFIRMTXDATE,
                         CFL.CONFIRMTXNUM,
                         CFL.OCUSTTYPE,
                         CFL.NCUSTTYPE,
                         CFL.OCOUNTRY,
                         CFL.NCOUNTRY,
                         CFL.DELTD,
                         CF.CUSTODYCD,
                         cfl.oidexpired,
                         cfl.nidexpired
                         --,CF.ACTIVESTS

                    FROM VSDTXREQ REQ, CFVSDLOG CFL, CFMAST CF
                   WHERE REQ.OBJKEY = CFL.TXNUM
                     AND CFL.DELTD <> 'Y'
                     and CFL.CONFIRMTXDATE is null
                     and CFL.CONFIRMTXNUM is null
                     AND CF.CUSTID = CFL.CUSTID
                     AND REQ.Reqid = pv_reqid) loop
        select systemnums.C_VSD_PREFIXED ||
               lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        --03      Ma khach hang         C
        l_txmsg.txfields('03').defname := 'CUSTID';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.custid;
        --04      TXDATE         C
        l_txmsg.txfields('04').defname := 'TXDATE';
        l_txmsg.txfields('04').type := 'C';
        l_txmsg.txfields('04').value := rec.TXDATE;
        --05      TXNUM         C
        l_txmsg.txfields('05').defname := 'TXNUM';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := rec.txnum;
        --15      ACTIVESTS         C
        l_txmsg.txfields('15').defname := 'ACTIVESTS';
        l_txmsg.txfields('15').type := 'C';
        l_txmsg.txfields('15').value := '';
        --21      IDCODE         C
        l_txmsg.txfields('21').defname := 'IDCODE';
        l_txmsg.txfields('21').type := 'C';
        l_txmsg.txfields('21').value := rec.oidcode;
        --22      IDDATE         D
        l_txmsg.txfields('22').defname := 'IDDATE';
        l_txmsg.txfields('22').type := 'D';
        l_txmsg.txfields('22').value := rec.oiddate;
        --23      IDEXPIRED         D
        l_txmsg.txfields('23').defname := 'IDEXPIRED';
        l_txmsg.txfields('23').type := 'D';
        l_txmsg.txfields('23').value := rec.oidexpired;
        --24      IDPLACE         D
        l_txmsg.txfields('24').defname := 'IDPLACE';
        l_txmsg.txfields('24').type := 'C';
        l_txmsg.txfields('24').value := '';
        --25      TRADINGCODE         C
        l_txmsg.txfields('25').defname := 'TRADINGCODE';
        l_txmsg.txfields('25').type := 'C';
        l_txmsg.txfields('25').value := rec.otradingcode;
        --26      TRADINGCODEDT
        l_txmsg.txfields('26').defname := 'TRADINGCODEDT';
        l_txmsg.txfields('26').type := 'D';
        l_txmsg.txfields('26').value := GETCURRDATE;
        --27      ADDRESS         C
        l_txmsg.txfields('27').defname := 'ADDRESS';
        l_txmsg.txfields('27').type := 'C';
        l_txmsg.txfields('27').value := rec.oaddress;
        --28      FULLNAME         C
        l_txmsg.txfields('28').defname := 'FULLNAME';
        l_txmsg.txfields('28').type := 'C';
        l_txmsg.txfields('28').value := rec.ofullname;
        --30      DESC         C
        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := '';
        --31      NIDCODE         C
        l_txmsg.txfields('31').defname := 'NIDCODE';
        l_txmsg.txfields('31').type := 'C';
        l_txmsg.txfields('31').value := rec.nidcode;
        --32      NIDDATE         D
        l_txmsg.txfields('32').defname := 'NIDDATE';
        l_txmsg.txfields('32').type := 'D';
        l_txmsg.txfields('32').value := rec.niddate;
        --33      NIDEXPIRED         D
        l_txmsg.txfields('33').defname := 'NIDEXPIRED';
        l_txmsg.txfields('33').type := 'D';
        l_txmsg.txfields('33').value := rec.nidexpired;
        --34      NIDPLACE
        l_txmsg.txfields('34').defname := 'NIDPLACE';
        l_txmsg.txfields('34').type := 'C';
        l_txmsg.txfields('34').value := '';
        --35      NTRADINGCODE         C
        l_txmsg.txfields('35').defname := 'NTRADINGCODE';
        l_txmsg.txfields('35').type := 'C';
        l_txmsg.txfields('35').value := rec.ntradingcode;
        --36      NTRADINGCODEDT
        l_txmsg.txfields('36').defname := 'NTRADINGCODEDT';
        l_txmsg.txfields('36').type := 'D';
        l_txmsg.txfields('36').value := GETCURRDATE;
        --37      NADDRESS         C
        l_txmsg.txfields('37').defname := 'NADDRESS';
        l_txmsg.txfields('37').type := 'C';
        l_txmsg.txfields('37').value := rec.NADDRESS;
        --38      NFULLNAME         C
        l_txmsg.txfields('38').defname := 'NFULLNAME';
        l_txmsg.txfields('38').type := 'C';
        l_txmsg.txfields('38').value := rec.NFULLNAME;
        --45      CUSTTYPE         C
        l_txmsg.txfields('45').defname := 'CUSTTYPE';
        l_txmsg.txfields('45').type := 'C';
        l_txmsg.txfields('45').value := rec.OCUSTTYPE;
        --46      NCUSTTYPE         C
        l_txmsg.txfields('46').defname := 'NCUSTTYPE';
        l_txmsg.txfields('46').type := 'C';
        l_txmsg.txfields('46').value := rec.NCUSTTYPE;
        --87      COUNTRY         C
        l_txmsg.txfields('87').defname := 'COUNTRY';
        l_txmsg.txfields('87').type := 'C';
        l_txmsg.txfields('87').value := rec.OCOUNTRY;
        --88      CUSTODYCD         C
        l_txmsg.txfields('88').defname := 'CUSTODYCD';
        l_txmsg.txfields('88').type := 'C';
        l_txmsg.txfields('88').value := rec.CUSTODYCD;
        --89      NCOUNTRY         C
        l_txmsg.txfields('89').defname := 'NCOUNTRY';
        l_txmsg.txfields('89').type := 'C';
        l_txmsg.txfields('89').value := rec.NCOUNTRY;

        update cfmast set NSDSTATUS = 'R' where custodycd = rec.CUSTODYCD;

        savepoint bf_transaction;
        begin
          if txpks_#0004.fn_BatchTxProcess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback to bf_transaction;
          end if;
        END;
      end LOOP;
    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_0004');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_0004');
end auto_call_txpks_0004;

procedure auto_call_txpks_0018(pv_reqid    number,
                                 pv_vsdtrfid number,
                                 p_err_code  out varchar2) as
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
  begin
    plog.setbeginsection(pkgctx, 'auto_call_txpks_0012');
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  WHERE req.reqid = pv_reqid) loop

      l_tltxcd       := '0018';
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

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;
      plog.info(pkgctx, 'process req id:' || pv_reqid); -- can sua lai them brid trong vsdtxreq de fill lai gt vao day

      for rec in
        (SELECT REQ.REQID,
                REQ.OBJNAME,
                REQ.AFACCTNO,
                REQ.TRFCODE,
                cfv.txnum || to_char(cfv.txdate,'DD/MM/RRRR') txkey, cf.custodycd, cfv.*,
                cfv.ofullname vofullname,
                case when cfv.ofullname <> NVL(cfv.nfullname,cfv.ofullname) then cfv.nfullname else null end vnfullname,
                cfv.oaddress voaddress,
                case when cfv.oaddress <> NVL(cfv.naddress,cfv.oaddress) then cfv.naddress else null end vnaddress,
                cfv.oidcode voidcode,
                case when cfv.oidcode <> NVL(cfv.nidcode,cfv.oidcode) then cfv.nidcode else null end vnidcode,
                cfv.oiddate voiddate,
                case when cfv.oiddate <> NVL(cfv.niddate,cfv.oiddate) then cfv.niddate else null end vniddate,
                cfv.otradingcode votradingcode,
                case when cfv.otradingcode <> nvl(cfv.ntradingcode,cfv.otradingcode) then cfv.ntradingcode else null end vntradingcode,
                cfv.ocountry vocountry,
                case when cfv.ocountry <> nvl(cfv.ncountry,cfv.ocountry) then cfv.ncountry else null end vncountry
          FROM VSDTXREQ REQ, cfvsdlog cfv, cfmast cf
          WHERE  REQ.OBJKEY = cfv.TXNUM
                 AND REQ.Reqid = pv_reqid
                 AND cfv.custid = cf.custid
                 and confirmtxdate is NULL
                 and confirmtxnum is null
                 and cfv.deltd <>'Y'
        ) loop
        select systemnums.C_VSD_PREFIXED ||
               lpad(seq_batchtxnum.nextval, 8, '0')
          into l_txmsg.txnum
          from dual;
        --03      Ma khach hang         C
        l_txmsg.txfields('03').defname := 'CUSTID';
        l_txmsg.txfields('03').type := 'C';
        l_txmsg.txfields('03').value := rec.custid;
        --18      TXNUM         C
        l_txmsg.txfields('18').defname := 'TXNUM';
        l_txmsg.txfields('18').type := 'C';
        l_txmsg.txfields('18').value := rec.txnum;
        --19      TXDATE         D
        l_txmsg.txfields('19').defname := 'TXDATE';
        l_txmsg.txfields('19').type := 'D';
        l_txmsg.txfields('19').value := rec.txdate;
        --21      IDCODE         C
        l_txmsg.txfields('21').defname := 'IDCODE';
        l_txmsg.txfields('21').type := 'C';
        l_txmsg.txfields('21').value := rec.oidcode;
        --22      IDDATE         D
        l_txmsg.txfields('22').defname := 'IDDATE';
        l_txmsg.txfields('22').type := 'D';
        l_txmsg.txfields('22').value := rec.oiddate;
        --23      IDEXPIRED         D
        l_txmsg.txfields('22').defname := 'IDEXPIRED';
        l_txmsg.txfields('22').type := 'D';
        l_txmsg.txfields('22').value := rec.oidexpired;
        --24      IDPLACE         C
        l_txmsg.txfields('24').defname := 'IDPLACE';
        l_txmsg.txfields('24').type := 'C';
        l_txmsg.txfields('24').value := '';
        --25      TRADINGCODE         C
        l_txmsg.txfields('25').defname := 'TRADINGCODE';
        l_txmsg.txfields('25').type := 'C';
        l_txmsg.txfields('25').value := rec.otradingcode;
        --26      TRADINGCODEDT
        l_txmsg.txfields('26').defname := 'TRADINGCODEDT';
        l_txmsg.txfields('26').type := 'D';
        l_txmsg.txfields('26').value := getcurrdate;
        --27      ADDRESS         C
        l_txmsg.txfields('27').defname := 'ADDRESS';
        l_txmsg.txfields('27').type := 'C';
        l_txmsg.txfields('27').value := rec.oaddress;
        --28      FULLNAME         C
        l_txmsg.txfields('28').defname := 'FULLNAME';
        l_txmsg.txfields('28').type := 'C';
        l_txmsg.txfields('28').value := rec.ofullname;
        --30      DESC         C
        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := '';
        --31      NIDCODE         C
        l_txmsg.txfields('31').defname := 'NIDCODE';
        l_txmsg.txfields('31').type := 'C';
        l_txmsg.txfields('31').value := rec.nidcode;
        --32      NIDDATE         D
        l_txmsg.txfields('32').defname := 'NIDDATE';
        l_txmsg.txfields('32').type := 'D';
        l_txmsg.txfields('32').value := rec.niddate;
        --33      NIDEXPIRED         D
        l_txmsg.txfields('33').defname := 'NIDEXPIRED';
        l_txmsg.txfields('33').type := 'D';
        l_txmsg.txfields('33').value := rec.nidexpired;
        --34      NIDPLACE
        l_txmsg.txfields('34').defname := 'NIDPLACE';
        l_txmsg.txfields('34').type := 'C';
        l_txmsg.txfields('34').value := rec.nidplace;
        --35      NTRADINGCODE         C
        l_txmsg.txfields('35').defname := 'NTRADINGCODE';
        l_txmsg.txfields('35').type := 'C';
        l_txmsg.txfields('35').value := rec.ntradingcode;
        --36      NTRADINGCODEDT
        l_txmsg.txfields('36').defname := 'NTRADINGCODEDT';
        l_txmsg.txfields('36').type := 'D';
        l_txmsg.txfields('36').value := rec.ntradingcodedt;
        --37      NADDRESS         C
        l_txmsg.txfields('37').defname := 'NADDRESS';
        l_txmsg.txfields('37').type := 'C';
        l_txmsg.txfields('37').value := rec.NADDRESS;
        --38      NFULLNAME         C
        l_txmsg.txfields('38').defname := 'NFULLNAME';
        l_txmsg.txfields('38').type := 'C';
        l_txmsg.txfields('38').value := rec.NFULLNAME;
        --45      CUSTTYPE         C
        l_txmsg.txfields('45').defname := 'CUSTTYPE';
        l_txmsg.txfields('45').type := 'C';
        l_txmsg.txfields('45').value := rec.OCUSTTYPE;
        --46      NCUSTTYPE         C
        l_txmsg.txfields('46').defname := 'NCUSTTYPE';
        l_txmsg.txfields('46').type := 'C';
        l_txmsg.txfields('46').value := rec.NCUSTTYPE;
        --87      COUNTRY         C
        l_txmsg.txfields('87').defname := 'COUNTRY';
        l_txmsg.txfields('87').type := 'C';
        l_txmsg.txfields('87').value := rec.OCOUNTRY;
        --88      CUSTODYCD         C
        l_txmsg.txfields('88').defname := 'CUSTODYCD';
        l_txmsg.txfields('88').type := 'C';
        l_txmsg.txfields('88').value := rec.CUSTODYCD;
        --89      NCOUNTRY         C
        l_txmsg.txfields('89').defname := 'NCOUNTRY';
        l_txmsg.txfields('89').type := 'C';
        l_txmsg.txfields('89').value := rec.NCOUNTRY;

        update cfmast set NSDSTATUS = 'C' where custodycd = rec.CUSTODYCD;

        savepoint bf_transaction;
        begin
          if txpks_#0018.fn_BatchTxProcess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback to bf_transaction;
          end if;
        END;

      end loop;

    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_0018');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_0018');
end auto_call_txpks_0018;

procedure auto_call_txpks_0103(pv_reqid    number,
                                pv_vsdtrfid number,
                                p_err_code  out varchar2,
                                p_confirm   varchar2) as
  l_txmsg       tx.msg_rectype;
  l_err_param   VARCHAR2(1000);
  begin
  plog.setbeginsection(pkgctx, 'auto_call_txpks_0103');
    select txdesc into l_txmsg.txdesc from tltx where tltxcd = '0103';
    l_txmsg.tltxcd    := '0103';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := getcurrdate;
    l_txmsg.txdate    := getcurrdate;
  for rec in(
      select max(case when dtl.fldname = 'CUSTODYCD' then dtl.cval else '' end) CUSTODYCD,
             max(case when dtl.fldname = 'REGIONPAYMENT' then dtl.cval else '' end) REGIONPAYMENT,
             max(case when dtl.fldname = 'ACCLINKTYPE' then dtl.cval else '' end) ACCLINKTYPE,
             max(cf.fullname) fullname
      from vsdtxreqdtl dtl, vsdtxreq req, cfmast cf
      where req.reqid = pv_reqid
            and req.reqid = dtl.reqid
            and req.msgacct = cf.custodycd
            and req.msgstatus in ('A','S')
  )loop
       SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
       INTO l_txmsg.txnum FROM dual;

        l_txmsg.txfields('04').defname := 'CUSTODYCD';
        l_txmsg.txfields('04').type := 'C';
        l_txmsg.txfields('04').value := rec.custodycd;

        l_txmsg.txfields('89').defname := 'CUSTODYCDTRF';
        l_txmsg.txfields('89').type := 'C';
        l_txmsg.txfields('89').value := rec.custodycd;

        l_txmsg.txfields('90').defname := 'CUSTODYCDPAY';
        l_txmsg.txfields('90').type := 'C';
        l_txmsg.txfields('90').value := rec.custodycd;

        l_txmsg.txfields('05').defname := 'FULLNAME';
        l_txmsg.txfields('05').type := 'C';
        l_txmsg.txfields('05').value := rec.fullname;

        l_txmsg.txfields('91').defname := 'REGIONPAYMENT';
        l_txmsg.txfields('91').type := 'C';
        l_txmsg.txfields('91').value := rec.REGIONPAYMENT;

        l_txmsg.txfields('92').defname := 'ACCLINKTYPE';
        l_txmsg.txfields('92').type := 'C';
        l_txmsg.txfields('92').value := rec.ACCLINKTYPE;

        l_txmsg.txfields('93').defname := 'CONFIRM';
        l_txmsg.txfields('93').type := 'C';
        l_txmsg.txfields('93').value := p_confirm;

         --30      DESC         C
        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := '';

        plog.error('MAI:'||rec.ACCLINKTYPE||'-'||rec.REGIONPAYMENT||'-'||rec.custodycd);
        savepoint bf_transaction;
        BEGIN
          IF txpks_#0103.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <> systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
        --cap nhat trang thai trong Cfmast
        /*IF p_confirm = 'R' THEN
          update cfmast set NSDSTATUS = 'R' where custodycd = rec.custodycd;
        ELSE
          update cfmast set NSDSTATUS = 'W' where custodycd = rec.custodycd;
        END IF;*/
  end loop;
  plog.setendsection(pkgctx, 'auto_call_txpks_0103');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_0103');
end auto_call_txpks_0103;

procedure auto_call_func_0059(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
    v_custodycd    varchar2(10);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_0059');

    select msgacct into v_custodycd from vsdtxreq where reqid = pv_reqid;
    update cfmast set status = 'C', nsdstatus = 'K' where custid = v_custodycd;

    plog.setendsection(pkgctx, 'auto_call_func_0059');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_0059');
END auto_call_func_0059;

procedure auto_call_func_0060(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
    v_custodycd    varchar2(10);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_0060');

    select msgacct into v_custodycd from vsdtxreq where reqid = pv_reqid;
    update cfmast set PSTATUS=PSTATUS||STATUS,STATUS=substr(PSTATUS,length(PSTATUS),1),NSDSTATUS='C'
    where custid = v_custodycd;

    plog.setendsection(pkgctx, 'auto_call_func_0060');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_0047');
END auto_call_func_0060;

PROCEDURE pr_process_mt598_539(p_funcname IN VARCHAR2, p_reqid IN NUMBER, p_trflogid IN NUMBER) IS
  v_detail598        varchar2(5000);
  v_subdetail598     varchar2(1000);
  v_count_598_539    number;--bien dung de thoat vong lap
  v_count_detail     number;--bien de log vao vsdtrflogdtl
BEGIN
  plog.setBeginSection(pkgctx,'pr_process_mt539_598');
  if p_funcname = '598.539..' THEN
    select MAX(DECODE(fldname,'DETAIL598',fldval,''))
    into   v_detail598
    from (select * from vsdmsglog where autoid = p_reqid) mst,
          xmltable('root/txcode/detail/field' passing mst.msgbody
                    columns fldname varchar2(200) path 'fldname',
                    fldval varchar2(4000) path 'fldval',
                    flddesc varchar2(1000) path 'flddesc') xt
    where xt.fldname IN ('DETAIL598');

    v_count_598_539 := 1;
    v_count_detail := 1;
    Loop
        v_subdetail598 := substr(v_detail598,1,instr(v_detail598,';') - 1);
        IF NVL(v_subdetail598,'x') = 'x' THEN
          EXIT;
        END IF;
        insert into vsdtrflogdtl(autoid, refautoid, fldname, fldval)
        values (seq_vsdtrflogdtl.nextval, p_trflogid,'DETAIL'||v_count_detail,v_subdetail598);
        SAVEPOINT before_insert_mt598;

        v_count_detail := v_count_detail + 1;
        v_detail598    := substr(v_detail598,instr(v_detail598,';') + 1);
        if v_detail598 is null then
            v_count_598_539 := 0;
        end if;
        Exit When v_count_598_539 = 0;
    End Loop;
  end if;
  plog.setEndSection(pkgctx,'pr_process_mt598_539');
EXCEPTION
  WHEN OTHERS THEN
    plog.setEndSection(pkgctx,'pr_process_mt598_539');
END pr_process_mt598_539;
--END HSX04

PROCEDURE auto_call_txpks_3355(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);

    v_reafacctno  VARCHAR2(10);
    v_depolastdt  DATE;

    v_vsdtrade    NUMBER;
    v_vsdblocked  NUMBER;
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3355');
    plog.error(pkgctx,'vao ko phuongnt');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist
    FROM vsdtxreq req, vsdtrfcode trf
    WHERE req.reqid = pv_reqid AND req.trfcode = trf.trfcode
      AND (req.msgstatus in ('A', 'S') OR (trf.type = 'INF' AND req.msgstatus IN ('C')));

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_3355');
        RETURN;
    END IF;

    SELECT trade, blocked INTO v_vsdtrade,v_vsdblocked FROM sereceived WHERE status = 'A' AND reqid = pv_reqid;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3355';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '3355';

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

    --Lay thong tin dien
    FOR rec IN
    (  SELECT NVL(ca.autoid,0) autoid,'001' type,
               NVL(ca.tradedate,v_cdate) tradedate ,sb.parvalue, SE.costprice PRICE, CF.CUSTODYCD, af.acctno AFACCTNO,SB.CODEID, cf.fullname,cf.idcode,cf.address,sb.symbol,
               AF.ACCTNO||SB.CODEID SEACCTNOCR,AF.ACCTNO||sbwft.CODEID SEACCTNODR,
               CASE WHEN ca.qtty IS NULL THEN se.trade ELSE least(ca.qtty,se.trade) END  TRADE ,
               CASE WHEN ca.qtty IS NULL THEN se.blocked ELSE (case when (ca.qtty>se.trade) then least((ca.qtty-se.trade),se.blocked) else 0 end) END blocked,
               ca.qtty CAQTTY,(least(ca.qtty,se.trade)  + (case when (ca.qtty>se.trade) then least((ca.qtty-se.trade),se.blocked) else 0 end)) realqtty,
               ( se.TRADE + se.MORTAGE + se.STANDING+se.WITHDRAW+se.DEPOSIT+se.BLOCKED+se.SENDDEPOSIT+se.DTOCLOSE) qtty,
               (( se.TRADE + se.MORTAGE + se.STANDING+se.WITHDRAW+se.DEPOSIT+se.BLOCKED+se.SENDDEPOSIT+se.DTOCLOSE)- (least(ca.qtty,se.trade) +  (case when (ca.qtty>se.trade) then least((ca.qtty-se.trade),se.blocked) else 0 end)) ) DIFFQTTY,
               re.trade VSDTRADE, re.blocked VSDBLOCKED, rq.brid, cf.idcode LICENSE
               FROM sereceived re,vsdtxreq rq,
               (SELECT nvl(camast.tocodeid,camast.codeid) codeid , ca.afacctno ,ca.qtty,ca.autoid,camast.tradedate
                  FROM vw_camast_all camast , vw_caschd_all ca
                 WHERE camast.camastid = ca.camastid
                   AND camast.ISWFT='Y' and ca.ISSE='Y'
                   AND ca.status in('C','S','G','H','J')
                   AND instr(nvl(ca.pstatus,'A'),'W') <=0
                 ) ca ,semast se ,afmast af,cfmast cf , sbsecurities sb ,sbsecurities sbwft, SECURITIES_INFO SEINFO
               WHERE re.recustodycd = cf.custodycd
               AND sb.symbol = re.symbol
               and ca.afacctno (+) = se.afacctno
               AND ca.codeid (+) = se.codeid
               AND se.afacctno = af.acctno
               and af.custid = cf.custid
               and sb.codeid = seinfo.codeid
               AND se.trade+se.blocked>0
               AND se.codeid = sbwft.codeid
               and sbwft.refcodeid=sb.codeid
               AND sbwft.tradeplace='006'
               AND re.status = 'A'
               AND re.reqid = rq.reqid
               AND re.reqid = pv_reqid

    ) LOOP

      IF v_vsdtrade + v_vsdblocked > 0 THEN
           --Set txnum
        SELECT systemnums.C_VSD_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --Set txtime
        select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
        --Set brid
        begin
            l_txmsg.brid        := rec.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;
        --Set cac field giao dich
        --01  AUTOID      C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.CODEID;
        --02  AFACCTNO    C
        l_txmsg.txfields ('02').defname   := 'AFACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.AFACCTNO;
        --03  SEACCTNODR    C
        l_txmsg.txfields ('03').defname   := 'SEACCTNODR';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.SEACCTNODR;
        --04  CUSTODYCD      C
        l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.CUSTODYCD;
        --05  SEACCTNOCR      C
        l_txmsg.txfields ('05').defname   := 'SEACCTNOCR';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.SEACCTNOCR;
        --06  AUTOID  C
        l_txmsg.txfields ('06').defname   := 'AUTOID';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.autoid;
        --07  TRADEDATE  C
        l_txmsg.txfields ('07').defname   := 'TRADEDATE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := to_char(rec.TRADEDATE,'dd/mm/rrrr');
        --08  TYPE    C
        l_txmsg.txfields ('08').defname   := 'TYPE';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.TYPE;
        --09  PRICE  C
        l_txmsg.txfields ('09').defname   := 'PRICE';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.price;
                --10  TYPE  C
        l_txmsg.txfields ('10').defname   := 'TRADE';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := least(rec.TRADE,v_vsdtrade);

        --11  PARVALUE        N
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.PARVALUE;
        --19  BLOCKED          C
        l_txmsg.txfields ('19').defname   := 'BLOCKED';
        l_txmsg.txfields ('19').TYPE      := 'N';
        l_txmsg.txfields ('19').VALUE     := least(rec.BLOCKED,v_vsdblocked);
        --20  DUTYAMT  N
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := v_desc;
        --21  CUSTNAME N
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;
        --22  ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;
        --30  LICENSE C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

        l_txmsg.txfields ('20').defname   := 'REALQTTY';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := rec.realqtty;

        l_txmsg.txfields ('21').defname   := 'CAQTTY';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := rec.caqtty;

        l_txmsg.txfields ('22').defname   := 'QTTY';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := rec.qtty;

        l_txmsg.txfields ('23').defname   := 'DIFFQTTY';
        l_txmsg.txfields ('23').TYPE      := 'N';
        l_txmsg.txfields ('23').VALUE     := rec.diffqtty;
        savepoint bf_transaction;
           BEGIN
             IF txpks_#3355.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <> systemnums.c_success THEN
                ROLLBACK to bf_transaction;
             ELSE
               v_vsdtrade:= v_vsdtrade - least(rec.trade,v_vsdtrade);
               v_vsdblocked := v_vsdblocked - least(rec.BLOCKED,v_vsdtrade);
             END IF;
           END;
         END IF;
       EXIT WHEN v_vsdtrade + v_vsdblocked <=0;
      END LOOP;

      IF p_err_code = systemnums.c_success THEN
         UPDATE sereceived SET status = 'C' WHERE reqid = pv_reqid;
      ELSE
         UPDATE sereceived SET status = 'E' WHERE reqid = pv_reqid;
      END IF;

    plog.setendsection(pkgctx, 'auto_call_txpks_3355');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3355');
  END auto_call_txpks_3355;

procedure auto_call_txpks_0059_2(pv_reqid number,pv_custodycd varchar2, pv_SENDTOVSD varchar2, pv_reftxnum varchar2, p_err_code out varchar2) as
    l_txmsg       tx.msg_rectype;
    v_currdate date;
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_effect_date date;
  begin
    -- Lay ngay hieu luc hach toan TRADDET.98A.ESET tu dien xac nhan cua VSD
    -- FLDNAME la VSDEFFDATE
    plog.setbeginsection(pkgctx, 'auto_call_txpks_0059_2');
    v_currdate   := getcurrdate;
    for rec0 in (select req.*
                   from vsdtxreq req
                  where req.msgstatus in ('C', 'W','A')
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
      l_txmsg.busdate   := v_currdate;
      l_txmsg.txdate    := v_currdate;
      l_txmsg.reftxnum  := pv_reftxnum;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;

        select systemnums.C_VSD_PREFIXED ||
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
     l_txmsg.txfields ('08').value     := pv_SENDTOVSD;

        begin
          savepoint bf_transaction;
          if txpks_#0059.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            rollback to bf_transaction;
            --RETURN;
          end if;
        end;

      end loop;

    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_0059_2');
  exception
    when others then
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_0059_2');
  end auto_call_txpks_0059_2;

procedure auto_call_func_pending(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_pending');
    UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE autoid = pv_vsdtrfid;
    plog.setendsection(pkgctx, 'auto_call_func_pending');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_pending');
  END auto_call_func_pending;
procedure auto_call_func_complete(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_complete');
    UPDATE vsdtxreq SET msgstatus = 'F', status = 'C' WHERE reqid = pv_reqid;
    UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE autoid = pv_vsdtrfid;
    plog.setendsection(pkgctx, 'auto_call_func_complete');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_complete');
  END auto_call_func_complete;

--cam co
  PROCEDURE auto_call_txpks_2236(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_sqlerrnum   varchar2(200);

  begin
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2236');
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  WHERE req.reqid = pv_reqid) loop

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
      l_txmsg.busdate   := getcurrdate;
      l_txmsg.txdate    := getcurrdate;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;
      FOR rec IN (
         SELECT SB.CODEID,SB.SYMBOL, SE.AFACCTNO , SE.ACCTNO , SE.AUTOID, SE.SENDQTTY , SB.PARVALUE,
          SE.NUM_MG MTNUM, SE.MDATE MTDATE, SE.CRFULLNAME CRFULLNAME, VSD.REQID,
          CF.FULLNAME CUSTNAME, CF.ADDRESS, CF.IDCODE LICENSE, SE.TXNUM, SE.TXDATE, CF.CUSTODYCD
          FROM VSDTXREQ VSD, SEMORTAGE SE, SBSECURITIES SB,AFMAST AF, CFMAST CF
          WHERE VSD.REQID = PV_REQID
            AND VSD.REFCODE = SE.AUTOID
            AND SUBSTR(SE.ACCTNO,11) = SB.CODEID
            AND AF.CUSTID = CF.CUSTID
            AND AF.ACCTNO = SE.AFACCTNO
            AND SE.STATUS = 'N' AND SE.DELTD <> 'Y'
        ) LOOP
        select systemnums.C_VSD_PREFIXED ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        --CODEID
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE   := 'C';
        l_txmsg.txfields ('01').VALUE   := REC.CODEID;
        --ACCTNO
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE   := 'C';
        l_txmsg.txfields ('03').VALUE   := REC.ACCTNO;
        --ACCTNO
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE   := 'C';
        l_txmsg.txfields ('02').VALUE   := REC.AFACCTNO;
        --AUTOID2232
        l_txmsg.txfields ('04').defname   := 'AUTOID2232';
        l_txmsg.txfields ('04').TYPE   := 'C';
        l_txmsg.txfields ('04').VALUE   := REC.AUTOID;

        --QTTY
        l_txmsg.txfields ('10').defname   := 'QTTY';
        l_txmsg.txfields ('10').TYPE   := 'N';
        l_txmsg.txfields ('10').VALUE   := REC.SENDQTTY;

        --PARVALUE
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE   := 'N';
        l_txmsg.txfields ('11').VALUE   := REC.PARVALUE;

        --DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE   := 'C';
        l_txmsg.txfields ('30').VALUE   := l_strdesc;

        --CUSTNAME
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE   := 'C';
        l_txmsg.txfields ('90').VALUE   := REC.CUSTNAME;

        --ADDRESS
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE   := 'C';
        l_txmsg.txfields ('91').VALUE   := REC.ADDRESS;

        --LICENSE
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE   := 'C';
        l_txmsg.txfields ('92').VALUE   := REC.LICENSE;

        savepoint bf_transaction_2236;
        begin
          if txpks_#2236.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            plog.setendsection(pkgctx, 'auto_call_txpks_2236');
            rollback to bf_transaction_2236;
          end if;
        end;
      end loop;
      plog.info(pkgctx, 'pp_err_code:' || p_err_code);
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'R'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', msgstatus = 'E'
              , boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_2236');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3336');
  END auto_call_txpks_2236;

  PROCEDURE auto_call_txpks_2251(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_autoid       NUMBER;
    l_vsdreqid      varchar2(20);
  begin
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2251');
    plog.info(pkgctx, 'process req id:' || pv_reqid);

    SELECT refmsgid INTO l_vsdreqid FROM vsdtrflog WHERE autoid=pv_vsdtrfid;
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  WHERE req.reqid = pv_reqid) loop

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
      l_txmsg.busdate   := getcurrdate;
      l_txmsg.txdate    := getcurrdate;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;
      FOR rec IN (
           SELECT SB.CODEID,SB.SYMBOL, SE.AFACCTNO , SE.ACCTNO , SE.QTTY , SB.PARVALUE,
            SE.NUM_MG MTNUM, SE.MDATE MTDATE, SE.CRFULLNAME CRFULLNAME,VSD.REQID,
            CF.FULLNAME CUSTNAME, CF.ADDRESS, CF.IDCODE LICENSE, SE.AUTOID M_AUTOID,SE.FEEAMT
            FROM VSDTXREQ VSD, SEMORTAGE SE, SBSECURITIES SB,AFMAST AF, CFMAST CF, tllog tl
            WHERE VSD.REQID = PV_REQID
              AND VSD.REFCODE = SE.AUTOID
              AND SUBSTR(SE.ACCTNO,11) = SB.CODEID
              AND AF.CUSTID = CF.CUSTID
              AND AF.ACCTNO = SE.AFACCTNO
              AND SE.STATUS='N' AND SE.DELTD<>'Y'
              AND SE.TXNUM = TL.TXNUM
              AND SE.TXDATE = TL.TXDATE
              AND TL.TLTXCD = '2232'
              AND SE.SENDQTTY > 0
        ) LOOP
        select systemnums.C_VSD_PREFIXED ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        l_autoid := rec.M_AUTOID;
        --CODEID
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE   := 'C';
        l_txmsg.txfields ('01').VALUE   := REC.CODEID;
        --ACCTNO
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE   := 'C';
        l_txmsg.txfields ('03').VALUE   := REC.ACCTNO;
        --ACCTNO
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE   := 'C';
        l_txmsg.txfields ('02').VALUE   := REC.AFACCTNO;
        --AUTOID2232
        l_txmsg.txfields ('04').defname   := 'AUTOID2232';
        l_txmsg.txfields ('04').TYPE   := 'C';
        l_txmsg.txfields ('04').VALUE   := l_autoid;

        --QTTY
        l_txmsg.txfields ('10').defname   := 'QTTY';
        l_txmsg.txfields ('10').TYPE   := 'N';
        l_txmsg.txfields ('10').VALUE   := REC.QTTY;

        --PARVALUE
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE   := 'N';
        l_txmsg.txfields ('11').VALUE   := REC.PARVALUE;

        --FEEAMT
        l_txmsg.txfields ('12').defname   := 'FEEAMT';
        l_txmsg.txfields ('12').TYPE   := 'N';
        l_txmsg.txfields ('12').VALUE   := REC.FEEAMT;

        --DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE   := 'C';
        l_txmsg.txfields ('30').VALUE   := l_strdesc;

        --CUSTNAME
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE   := 'C';
        l_txmsg.txfields ('90').VALUE   := REC.CUSTNAME;

        --ADDRESS
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE   := 'C';
        l_txmsg.txfields ('91').VALUE   := REC.ADDRESS;

        --LICENSE
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE   := 'C';
        l_txmsg.txfields ('92').VALUE   := REC.LICENSE;

        savepoint bf_transaction_2251;
        begin
          if txpks_#2251.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            ROLLBACK TO bf_transaction_2251;
            plog.setendsection(pkgctx, 'auto_call_txpks_2251');
          end if;
        end;
      end loop;
      plog.info(pkgctx, 'pp_err_code:' || p_err_code);
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'F', msgstatus = 'F'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;

        UPDATE semortage se SET se.refidvsd = l_vsdreqid  WHERE se.autoid = l_autoid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', msgstatus = 'E'
              , boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_2251');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3355');
  END auto_call_txpks_2251;
  -- giai toa cam co
  PROCEDURE auto_call_txpks_2257(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_sqlerrnum   varchar2(200);

  begin
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2257');
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  WHERE req.reqid = pv_reqid) loop

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
      l_txmsg.busdate   := getcurrdate;
      l_txmsg.txdate    := getcurrdate;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;
      FOR rec IN (
           SELECT SB.CODEID,SB.SYMBOL, SE.AFACCTNO , SE.ACCTNO , SE.AUTOID, SE.SENDQTTY QTTY , SB.PARVALUE,
            SE.NUM_MG MTNUM, SE.MDATE MTDATE, SE.CRFULLNAME CRFULLNAME, VSD.REQID,
            CF.FULLNAME CUSTNAME, CF.ADDRESS, CF.IDCODE LICENSE, SE.TXNUM, SE.TXDATE, CF.CUSTODYCD
            FROM VSDTXREQ VSD, SEMORTAGE SE, SBSECURITIES SB,AFMAST AF, CFMAST CF
            WHERE VSD.REQID = PV_REQID
              AND VSD.REFCODE = SE.AUTOID
              AND SUBSTR(SE.ACCTNO,11) = SB.CODEID
              AND AF.CUSTID = CF.CUSTID
              AND AF.ACCTNO = SE.AFACCTNO
              AND SE.STATUS = 'N' AND SE.DELTD <> 'Y'
        ) LOOP
        select systemnums.C_VSD_PREFIXED ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        --CODEID
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE   := 'C';
        l_txmsg.txfields ('01').VALUE   := REC.CODEID;
        --ACCTNO
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE   := 'C';
        l_txmsg.txfields ('03').VALUE   := REC.ACCTNO;
        --ACCTNO
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE   := 'C';
        l_txmsg.txfields ('02').VALUE   := REC.AFACCTNO;
        --AUTOID2232
        l_txmsg.txfields ('04').defname   := 'AUTOID2233';
        l_txmsg.txfields ('04').TYPE   := 'C';
        l_txmsg.txfields ('04').VALUE   := rec.autoid;

        --QTTY
        l_txmsg.txfields ('10').defname   := 'QTTY';
        l_txmsg.txfields ('10').TYPE   := 'N';
        l_txmsg.txfields ('10').VALUE   := REC.QTTY;

        --PARVALUE
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE   := 'N';
        l_txmsg.txfields ('11').VALUE   := REC.PARVALUE;

        --CUSTODYCD
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE   := 'C';
        l_txmsg.txfields ('88').VALUE   := REC.CUSTODYCD;

        --DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE   := 'C';
        l_txmsg.txfields ('30').VALUE   := l_strdesc;

        --CUSTNAME
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE   := 'C';
        l_txmsg.txfields ('90').VALUE   := REC.CUSTNAME;

        --ADDRESS
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE   := 'C';
        l_txmsg.txfields ('91').VALUE   := REC.ADDRESS;

        --LICENSE
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE   := 'C';
        l_txmsg.txfields ('92').VALUE   := REC.LICENSE;

        savepoint bf_transaction_2257;
        begin
          if txpks_#2257.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success then
            plog.setendsection(pkgctx, 'auto_call_txpks_2257');
            ROLLBACK TO bf_transaction_2257;
          end if;
        end;
      end loop;
      plog.info(pkgctx, 'pp_err_code:' || p_err_code);
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'R'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', msgstatus = 'E'
               --boprocess = 'E'
              , boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_2257');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2257');
  END auto_call_txpks_2257;

  PROCEDURE auto_call_txpks_2253(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    v_strcurrdate varchar2(20);
    l_strdesc     varchar2(400);
    l_tltxcd      varchar2(4);
    l_err_param   varchar2(1000);
    l_sqlerrnum   varchar2(200);
    l_autoid       NUMBER;
    l_vsdreqid      varchar2(20);
  begin
    plog.setbeginsection(pkgctx, 'auto_call_txpks_2253');
    plog.info(pkgctx, 'process req id:' || pv_reqid);

    SELECT refmsgid INTO l_vsdreqid FROM vsdtrflog WHERE autoid=pv_vsdtrfid;
    --Lay thong tin dien confirm
    for rec0 in (select req.*
                   from vsdtxreq req
                  WHERE req.reqid = pv_reqid) loop

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
      l_txmsg.busdate   := getcurrdate;
      l_txmsg.txdate    := getcurrdate;

      select to_char(sysdate, 'hh24:mi:ss') into l_txmsg.txtime from dual;
      l_txmsg.brid := rec0.brid;
      FOR rec IN (
         SELECT SB.CODEID,SB.SYMBOL, SE.AFACCTNO , SE.ACCTNO , SE.QTTY , SB.PARVALUE,
          SE.NUM_MG MTNUM, SE.MDATE MTDATE, SE.CRFULLNAME CRFULLNAME,VSD.REQID,
          CF.FULLNAME CUSTNAME, CF.ADDRESS, CF.IDCODE LICENSE, SE.AUTOID M_AUTOID, CF.CUSTODYCD
          FROM VSDTXREQ VSD, SEMORTAGE SE, SBSECURITIES SB,AFMAST AF, CFMAST CF, tllog tl
          WHERE VSD.REQID = PV_REQID
            AND VSD.REFCODE = SE.AUTOID
            AND SUBSTR(SE.ACCTNO,11) = SB.CODEID
            AND AF.CUSTID = CF.CUSTID
            AND AF.ACCTNO = SE.AFACCTNO
            AND SE.STATUS='N' AND SE.DELTD<>'Y'
            AND SE.TXNUM = TL.TXNUM
            AND SE.TXDATE = TL.TXDATE
            AND TL.TLTXCD = '2233'
            AND SE.SENDQTTY > 0
        ) LOOP
        select systemnums.C_VSD_PREFIXED ||
              lpad(seq_batchtxnum.nextval, 8, '0')
        into l_txmsg.txnum
        from dual;

        l_autoid := rec.M_AUTOID;
        --CODEID
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE   := 'C';
        l_txmsg.txfields ('01').VALUE   := REC.CODEID;
        --ACCTNO
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE   := 'C';
        l_txmsg.txfields ('03').VALUE   := REC.ACCTNO;
        --ACCTNO
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE   := 'C';
        l_txmsg.txfields ('02').VALUE   := REC.AFACCTNO;
        --AUTOID2232
        l_txmsg.txfields ('04').defname   := 'AUTOID2232';
        l_txmsg.txfields ('04').TYPE   := 'C';
        l_txmsg.txfields ('04').VALUE   := l_autoid;

        --QTTY
        l_txmsg.txfields ('10').defname   := 'QTTY';
        l_txmsg.txfields ('10').TYPE   := 'N';
        l_txmsg.txfields ('10').VALUE   := REC.QTTY;

        --PARVALUE
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE   := 'N';
        l_txmsg.txfields ('11').VALUE   := REC.PARVALUE;

        --DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE   := 'C';
        l_txmsg.txfields ('30').VALUE   := l_strdesc;

         --CUSTODYCD
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE   := 'C';
        l_txmsg.txfields ('88').VALUE   := REC.CUSTODYCD;
        --CUSTNAME
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE   := 'C';
        l_txmsg.txfields ('90').VALUE   := REC.CUSTNAME;

        --ADDRESS
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE   := 'C';
        l_txmsg.txfields ('91').VALUE   := REC.ADDRESS;

        --LICENSE
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE   := 'C';
        l_txmsg.txfields ('92').VALUE   := REC.LICENSE;
        savepoint bf_transaction_2253;
        begin
          if txpks_#2253.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
             plog.setendsection(pkgctx, 'auto_call_txpks_2253');
             ROLLBACK TO bf_transaction_2253;
          end if;
        end;
      end loop;
      plog.info(pkgctx, 'pp_err_code:' || p_err_code);
      if nvl(p_err_code, 0) = 0 then
        update vsdtxreq
           set status = 'F', msgstatus = 'F'
         where reqid = pv_reqid;

        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;

        UPDATE semortage se SET se.refidvsd = l_vsdreqid  WHERE se.autoid = l_autoid;
      else
        -- neu giao dich loi: danh danh trang thai loi de lam lai bang tay
        update vsdtxreq
           set status = 'E', msgstatus = 'E'
              , boprocess_err = p_err_code
         where reqid = pv_reqid;
        -- Tr?ng th?VSDTRFLOG
        update vsdtrflog
           set status = 'C', timeprocess = systimestamp
         where autoid = pv_vsdtrfid;
      end if;

    end loop;
    plog.setendsection(pkgctx, 'auto_call_txpks_2253');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_2253');
  END auto_call_txpks_2253;
  -- end
PROCEDURE auto_call_txpks_3313(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_cdate       DATE;
    v_desc        VARCHAR2(1000);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3313');
    v_cdate  := getcurrdate;
    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3313';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;
    l_txmsg.brid      := systemnums.C_BATCH_BRID;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = l_txmsg.tltxcd;
    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;
    FOR rec IN (
       SELECT re.catype, re.vsdcaid, re.reportdate, re.msgstatus, re.reqtype
       FROM msgcareceived re, sbsecurities sb, sbsecurities sb1
       WHERE re.isincode = sb.isincode AND sb.refcodeid IS NULL
         AND re.toisincode = sb1.isincode(+) AND sb1.refcodeid IS NULL
         AND re.reqtype IN ('NEWM', 'REPL', 'CANC')
         AND re.reqid = pv_reqid
       UNION ALL
       SELECT nvl(re.catype, ref.catype), re.vsdcaid, nvl(re.reportdate, ref.reportdate), re.msgstatus, re.reqtype
       FROM msgcareceived re, (SELECT vsdcaid,max(reportdate) reportdate,catype FROM msgcareceived WHERE reqtype = 'NEWM' group by vsdcaid,catype) ref
       WHERE re.vsdcaid = ref.vsdcaid(+)
         AND re.reqtype NOT IN ('NEWM', 'REPL', 'CANC')
         AND re.reqid = pv_reqid
    ) LOOP
       SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

       SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
            INTO l_txmsg.txnum FROM dual;
       --Lay thong tin dien
       l_txmsg.txfields('06').defname := 'REQID';
       l_txmsg.txfields('06').TYPE    := 'C';
       l_txmsg.txfields('06').value   := pv_reqid;

       l_txmsg.txfields('02').defname := 'CATYPE';
       l_txmsg.txfields('02').TYPE    := 'C';
       l_txmsg.txfields('02').value   := rec.catype;

       l_txmsg.txfields('03').defname := 'VSDCAID';
       l_txmsg.txfields('03').TYPE    := 'C';
       l_txmsg.txfields('03').value   := rec.vsdcaid;

       l_txmsg.txfields('05').defname := 'REPORTDATE';
       l_txmsg.txfields('05').TYPE    := 'D';
       l_txmsg.txfields('05').value   := rec.reportdate;

       l_txmsg.txfields('09').defname := 'STATUS';
       l_txmsg.txfields('09').TYPE    := 'C';
       l_txmsg.txfields('09').value   := rec.msgstatus;

       l_txmsg.txfields('08').defname := 'REQTYPE';
       l_txmsg.txfields('08').TYPE    := 'C';
       l_txmsg.txfields('08').value   := rec.reqtype;

       l_txmsg.txfields('30').defname := 'DESC';
       l_txmsg.txfields('30').TYPE    := 'C';
       l_txmsg.txfields('30').value   := v_desc;
       plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
       SAVEPOINT bf_transaction;
       BEGIN
          IF txpks_#3313.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
             plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
             ROLLBACK to bf_transaction;
          ELSE
          -- Update trang thai vsdtxreq
          -- Voi dien 566: lam xong 3390 -> hoan tat
            IF rec.reqtype <> 'PROC' THEN
              UPDATE vsdtxreq SET status = 'C', msgstatus = 'F' WHERE reqid =  pv_reqid;
              UPDATE msgcareceived SET msgstatus = 'F' WHERE reqid = pv_reqid;
              UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE referenceid = pv_reqid;
            ELSE
              UPDATE vsdtxreq SET status = 'W', msgstatus = 'W' WHERE reqid =  pv_reqid;
              UPDATE msgcareceived SET msgstatus = 'F' WHERE reqid = pv_reqid;
              UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE referenceid = pv_reqid;
            END IF;
          END IF;
       END;
    END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_3313');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3313');
  END auto_call_txpks_3313;

procedure auto_call_func_567(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_567');

    UPDATE vsdtxreq SET msgstatus = 'W', status = 'W' WHERE reqid = pv_reqid;
    UPDATE vsdtrflog SET status = 'C', timeprocess = systimestamp WHERE autoid = pv_vsdtrfid;

    plog.setendsection(pkgctx, 'auto_call_func_567');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_567');
  END auto_call_func_567;
procedure auto_call_func_3335_rej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3335_rej');

    update msgcareceived set msgstatus = 'F'
    where reqid = (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid);
    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'auto_call_func_3335_rej');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3335_rej');
  END auto_call_func_3335_rej;

PROCEDURE auto_call_txpks_3340(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_cdate       DATE;
    v_desc        VARCHAR2(1000);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3340');
    v_cdate  := getcurrdate;
    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3340';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;
    l_txmsg.brid      := systemnums.C_BATCH_BRID;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = l_txmsg.tltxcd;
    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;
    FOR rec IN (
       SELECT *
       FROM (SELECT A.CAMASTID, A.VSDID,MAX(A.AUTOID) AUTOID, A.DESCRIPTION, B.SYMBOL, A.ACTIONDATE, CD.CDCONTENT CATYPE,
                    MAX(CHD.CODEID) CODEID, SUM(NVL(CHD.QTTY,0)) QTTYDIS
                    FROM CAMAST A, SBSECURITIES B, ALLCODE CD, CASCHD CHD, VSDTXREQ REQ
                WHERE A.CODEID = B.CODEID AND ((CHD.STATUS IN('V','M') AND A.CATYPE IN ('014','023'))
                    OR(CHD.STATUS IN('A') AND A.CATYPE<>'014' AND A.CATYPE<>'023')) AND A.DELTD='N'
                    AND A.CAMASTID= CHD.CAMASTID AND CHD.DELTD <> 'Y'
                    AND CD.CDNAME ='CATYPE' AND CD.CDTYPE ='CA' AND CD.CDVAL = A.CATYPE
                    AND A.CATYPE NOT IN ('019')
                    AND A.CAMASTID = REQ.MSGACCT
                    AND REQ.REQID = pv_reqid
                GROUP BY A.CAMASTID, A.VSDID, A.DESCRIPTION, B.SYMBOL, A.ACTIONDATE, CD.CDCONTENT
            ) WHERE 0=0
    ) LOOP
       SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

       SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
            INTO l_txmsg.txnum FROM dual;
       --Lay thong tin dien
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
                 l_txmsg.txfields ('30').value      := v_desc;
            --40    M? ch?ng kho?  C
                 l_txmsg.txfields ('40').defname   := 'CODEID';
                 l_txmsg.txfields ('40').TYPE      := 'C';
                 l_txmsg.txfields ('40').value      := rec.CODEID;
       --plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
       SAVEPOINT bf_transaction;
       BEGIN
          IF txpks_#3340.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
             plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
             ROLLBACK to bf_transaction;
          ELSE
          -- Update trang thai vsdtxreq
            UPDATE msgcareceived SET msgstatus = 'C' WHERE vsdcaid = rec.vsdid;
          END IF;
       END;
    END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_3340');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3340');
  END auto_call_txpks_3340;

PROCEDURE auto_call_txpks_3370(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    v_cdate       DATE;
    v_desc        VARCHAR2(1000);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3370');
    v_cdate  := getcurrdate;
    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3370';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := v_cdate;
    l_txmsg.txdate    := v_cdate;
    l_txmsg.brid      := systemnums.C_BATCH_BRID;

    SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = l_txmsg.tltxcd;
    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;
    FOR rec IN (
       SELECT *
       FROM (select ca.DUEDATE,ca.BEGINDATE,ca.CAMASTID,ca.SYMBOL,ca.CATYPE,ca.REPORTDATE,ca.ACTIONDATE,
                    ca.CATYPEVAL,ca.RATE,ca.RIGHTOFFRATE,ca.FRDATETRANSFER,ca.ROPRICE,ca.TVPRICE,ca.CODEID,ca.STATUS,
                    ca.TRADE,ca.TODATETRANSFER,ca.tocodeid, ca.vsdid
                    from v_camast ca, vsdtxreq req
                    where REPLACE(ca.camastid,'.') = req.msgacct
                    and req.reqid = pv_reqid
            ) WHERE 0=0
    ) LOOP
       SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

       SELECT systemnums.C_VSD_PREFIXED || lpad(seq_batchtxnum.nextval, 8, '0')
            INTO l_txmsg.txnum FROM dual;
       --Lay thong tin dien
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
                 l_txmsg.txfields ('30').value      := v_desc;
            --40    M? ch?ng kho?  C
                 l_txmsg.txfields ('40').defname   := 'TOCODEID';
                 l_txmsg.txfields ('40').TYPE      := 'C';
                 l_txmsg.txfields ('40').value      := rec.TOCODEID;
       --plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
       SAVEPOINT bf_transaction;
       BEGIN
          IF txpks_#3370.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
             plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
             ROLLBACK to bf_transaction;
          ELSE
          -- Update trang thai vsdtxreq
            UPDATE msgcareceived SET msgstatus = 'C' WHERE vsdcaid = rec.vsdid;
          END IF;
       END;
    END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_3370');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3370');
  END auto_call_txpks_3370;

  procedure auto_call_func_3357_rej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3357_rej');

    update caregister set msgstatus = 'R'
    where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid);
    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'auto_call_func_3357_rej');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3357_rej');
  END auto_call_func_3357_rej;

  procedure auto_call_func_3357_conf(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3357_conf');

    update caregister set msgstatus = 'C'
    where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid);
    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'auto_call_func_3357_conf');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3357_conf');
  END auto_call_func_3357_conf;

  procedure auto_call_func_3358_rej(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3358_rej');

    update catransfer set msgstatus = 'R'
    where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid);
    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'auto_call_func_3358_rej');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3358_rej');
  END auto_call_func_3358_rej;

  procedure auto_call_func_3358_conf(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3358_conf');

    update catransfer set msgstatus = 'C'
    where TO_CHAR(TXDATE,'DD/MM/YYYY')||TXNUM = (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid);
    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'auto_call_func_3358_conf');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3358_conf');
  END auto_call_func_3358_conf;

  PROCEDURE auto_call_txpks_3328(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3328');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_3328');
        RETURN;
    END IF;

    -- Lay mo ta giao dich
    BEGIN
       SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '3328';
    EXCEPTION WHEN OTHERS THEN
       v_desc := '';
    END;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3328';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
    plog.error(pkgctx, 'D :' ||pv_reqid);
    --Lay thong tin dien
    FOR rec IN (
      SELECT req.reqid, req.brid, schd.autoid,ca.camastid,cf.custodycd,af.acctno afacctno,sec1.codeid,sec2.codeid tocodeid,
      sec1.symbol,sec2.symbol tosymbol,
      ca.reportdate,schd.pqtty,schd.trade,(schd.pqtty+schd.qtty) maxqtty,
      schd.qtty sumqtty, substr(dtl.cval, 0, LENGTH(dtl.cval)-1) qtty, ca.begindate,ca.duedate ,af.acctno,cf.fullname, ca.isincode
      FROM vsdtxreq req, vsdtxreqdtl dtl,
       camast ca, caschd schd,cfmast cf, afmast af,sbsecurities sec1, sbsecurities sec2
      WHERE req.refcode = schd.autoid
      and ca.camastid=schd.camastid
      AND schd.afacctno=af.acctno AND af.custid=cf.custid
      AND ca.codeid=sec1.codeid AND ca.tocodeid=sec2.codeid
      AND to_date(ca.begindate,'DD/MM/YYYY') <= to_date(GETCURRDATE,'DD/MM/YYYY')
      AND to_date(nvl(ca.duedate, GETCURRDATE),'DD/MM/YYYY') >= to_date(GETCURRDATE,'DD/MM/YYYY')
      AND ca.catype='023' AND schd.status='V'
      AND schd.qtty>0
      AND schd.deltd='N'
      and req.reqid = dtl.reqid and dtl.fldname = 'QTTY'
      and req.reqid = pv_reqid

    ) LOOP
        SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        l_txmsg.txfields('01').defname := 'AUTOID';
        l_txmsg.txfields('01').TYPE    := 'C';
        l_txmsg.txfields('01').value   := rec.autoid;

        l_txmsg.txfields('02').defname := 'CAMASTID';
        l_txmsg.txfields('02').TYPE    := 'C';
        l_txmsg.txfields('02').value   := rec.camastid;

        l_txmsg.txfields('03').defname := 'AFACCTNO';
        l_txmsg.txfields('03').TYPE    := 'C';
        l_txmsg.txfields('03').value   := rec.afacctno;

        l_txmsg.txfields('04').defname := 'SYMBOL';
        l_txmsg.txfields('04').TYPE    := 'C';
        l_txmsg.txfields('04').value   := rec.symbol;

        l_txmsg.txfields('05').defname := 'TOSYMBOL';
        l_txmsg.txfields('05').TYPE    := 'C';
        l_txmsg.txfields('05').value   := rec.TOSYMBOL;

        l_txmsg.txfields('08').defname := 'FULLNAME';
        l_txmsg.txfields('08').TYPE    := 'C';
        l_txmsg.txfields('08').value   := rec.fullname;

        l_txmsg.txfields('10').defname := 'QTTY';
        l_txmsg.txfields('10').TYPE    := 'N';
        l_txmsg.txfields('10').value   := rec.QTTY;

        l_txmsg.txfields('21').defname := 'TOCODEID';
        l_txmsg.txfields('21').TYPE    := 'C';
        l_txmsg.txfields('21').value   := rec.TOCODEID;

        l_txmsg.txfields('24').defname := 'CODEID';
        l_txmsg.txfields('24').TYPE    := 'N';
        l_txmsg.txfields('24').value   := rec.CODEID;

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').TYPE    := 'C';
        l_txmsg.txfields('30').value   := v_desc || ' do loi dien';

        l_txmsg.txfields('96').defname := 'CUSTODYCD';
        l_txmsg.txfields('96').TYPE    := 'N';
        l_txmsg.txfields('96').value   := rec.CUSTODYCD;
        savepoint bf_transaction;
        plog.error(pkgctx, 'D :' || rec.autoid ||' & ' || rec.camastid);
        BEGIN
          IF txpks_#3328.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_3328');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3328');
  END auto_call_txpks_3328;

  procedure auto_call_func_3360(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3360');

    UPDATE camast SET pstatus = pstatus||status, status = 'V', last_change = systimestamp
    WHERE camastid IN (SELECT msgacct FROM vsdtxreq WHERE reqid = pv_reqid);

    plog.setendsection(pkgctx, 'auto_call_func_3360');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3360');
  END auto_call_func_3360;

  PROCEDURE auto_call_func_3385(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
     v_cdate              DATE;
     v_exist              VARCHAR(1);
     v_vsdmsgid           varchar2(50);
     v_isincode           varchar2(50);
     v_qtty               number;
     v_contractno         varchar2(50);
     v_txdate             varchar2(20);
     v_symbol             varchar2(50);
     v_custodycd          varchar2(20);
     v_refmsgid           varchar2(50);
     v_vsdmsgdate         DATE;
     v_trfdate            DATE;
     v_trftxnum           VARCHAR2(50);
     v_frbiccode          VARCHAR2(20);
     v_recustodycd        varchar2(20);
     v_transtype          VARCHAR2(10);
     v_codeid             varchar2(20);
     v_camastid           varchar2(50);
     v_reqid              number;
     --v_cashchdid          number;
     v_optseacctnocr      varchar2(50);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3385');

    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_func_3385');
        RETURN;
    END IF;

         SELECT MAX(CASE WHEN fldname = 'VSDMSGID' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'VSDMSGDATE' THEN to_date(fldval, 'RRRRMMDDHH24MISS') ELSE NULL END),
                MAX(CASE WHEN fldname = 'VSDEFFDATE' THEN to_date(fldval, 'RRRRMMDD') ELSE NULL END),
                MAX(CASE WHEN fldname = 'TRDTXNUM' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'FRBICCODE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'CUSTODYCD' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'RECUSTODYCD' THEN fldval ELSE '' end),
                MAX(CASE WHEN fldname = 'SYMBOL' THEN substr(fldval, 6) ELSE '' END),
                MAX(CASE WHEN fldname = 'TRANSTYPE' THEN fldval ELSE '' END),
                MAX(CASE WHEN fldname = 'QTTY' THEN to_number(fldval) ELSE 0 END),
                max(CASE WHEN fldname = 'REQID' THEN to_number(fldval) ELSE 0 END)
         INTO v_vsdmsgid, v_vsdmsgdate, v_trfdate, v_trftxnum, v_frbiccode, v_custodycd,
              v_recustodycd, v_isincode, v_transtype, v_qtty, v_reqid
         FROM vsdtrflogdtl WHERE refautoid = pv_vsdtrfid;
 plog.error(pkgctx,'tesst1'||pv_vsdtrfid);
         select  sb.codeid, ca.camastid, v.msgacct--, cas.autoid
         into  v_codeid, v_camastid,v_optseacctnocr--, v_cashchdid
         from sbsecurities sb, camast ca, vsdtxreq v--, caschd cas
         where  sb.isincode = v_isincode
         and sb.refcodeid is null
         and ca.optcodeid = sb.codeid
         and ca.catype = '014'
         AND CA.DELTD = 'N'
         AND CA.STATUS = 'V'
         and reqid=v_reqid;

         insert into catransfer(autoid, txdate, txnum, camastid, optseacctnocr, optseacctnodr,
                                codeid, optcodeid, amt, status, inamt, retailbal, sendinamt, sendretailbal,
                                toacctno, tomemcus, country2, custname2, address2,
                                license2, iddate2, idplace2, caschdid, statusre /*, feeamt, taxamt*/)
         values (seq_catransfer.nextval,nvl(v_trfdate,v_cdate),v_trftxnum,v_camastid,v_optseacctnocr,'-----'||v_codeid,
                 v_codeid,v_codeid,v_qtty,'P',0,0,0,0,
                 v_recustodycd,NULL,NULL,NULL,NULL,
                 NULL,NULL,NULL,null,'N'/*,0,0*/);

    /*-- Lay mo ta giao dich
    BEGIN
       SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '3353';
    EXCEPTION WHEN OTHERS THEN
       v_desc := '';
    END;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3385';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT CODEID INTO l_codeid from camast where camastid = (select refcode from vsdtxreq where reqid=pv_reqid);

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
    plog.error(pkgctx, 'D :' ||pv_reqid);
    --Lay thong tin dien
    FOR rec IN (
      SELECT TO_CHAR(MST.TXDATE,'DDMMRRRR') || MST.TXNUM TXKEY, MST.CAMASTID, CAMAST.OPTCODEID, CAMAST.CODEID,
             NVL(CAMAST.TOCODEID,CAMAST.CODEID) TOCODEID,
             SYM.SYMBOL, SYM2.SYMBOL TOSYMBOL, MST.AMT,
             UPPER(MST.TOACCTNO) TOCUSTODYCD, SUBSTR(MST.OPTSEACCTNOCR,1,10) TOAFACCTNO,
             CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME, CF.IDCODE, CF.IDDATE, CF.IDPLACE, A1.CDCONTENT COUNTRY,
             CF2.FULLNAME TOFULLNAME, CF2.IDCODE TOIDCODE, CF2.IDDATE TOIDDATE, CF2.IDPLACE TOIDPLACE, A2.CDCONTENT TOCOUNTRY,
             CF2.ADDRESS TOADDRESS, camast.isincode,re.brid
      FROM CATRANSFER MST, (SELECT * FROM CAMAST ORDER BY AUTOID DESC) CAMAST, SBSECURITIES SYM, AFMAST AF,
           CFMAST CF, SBSECURITIES SYM2, ALLCODE A1, AFMAST AF2, CFMAST CF2, ALLCODE A2, vsdtxreq re
      WHERE MST.STATUSRE = 'N' AND  SUBSTR(MST.TOACCTNO,1,3) = '002'
      AND MST.STATUS NOT IN ('Y','C')
      AND MST.CAMASTID = CAMAST.CAMASTID
      AND CAMAST.CODEID = SYM.CODEID
      AND NVL(CAMAST.TOCODEID,CAMAST.CODEID)  = SYM2.CODEID
      AND SUBSTR(OPTSEACCTNODR,1,10) =  AF.ACCTNO
      AND AF.CUSTID = CF.CUSTID
      AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'COUNTRY' AND CF.COUNTRY = A1.CDVAL(+)
      AND SUBSTR(OPTSEACCTNOCR,1,10) =  AF2.ACCTNO
      AND AF2.CUSTID = CF2.CUSTID
      AND A2.CDTYPE = 'CF' AND A2.CDNAME = 'COUNTRY' AND CF2.COUNTRY = A2.CDVAL(+)
      and re.refcode = mst.camastid
      and re.reqid = pv_reqid
    ) LOOP
        SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').TYPE    := 'C';
        l_txmsg.txfields('01').value   := rec.codeid;

        l_txmsg.txfields('04').defname := 'AFACCT2';
        l_txmsg.txfields('04').TYPE    := 'C';
        l_txmsg.txfields('04').value   := rec.toafacctno;

        l_txmsg.txfields('05').defname := 'ACCT2';
        l_txmsg.txfields('05').TYPE    := 'C';
        l_txmsg.txfields('05').value   := rec.toafacctno||rec.codeid;

        l_txmsg.txfields('06').defname := 'CAMASTID';
        l_txmsg.txfields('06').TYPE    := 'C';
        l_txmsg.txfields('06').value   := rec.camastid;

        l_txmsg.txfields('11').defname := 'ORGCODEID';
        l_txmsg.txfields('11').TYPE    := 'C';
        l_txmsg.txfields('11').value   := l_codeid;

        l_txmsg.txfields('12').defname := 'ORGSEACCTNO';
        l_txmsg.txfields('12').TYPE    := 'C';
        l_txmsg.txfields('12').value   := rec.codeid;

        l_txmsg.txfields('21').defname := 'AMT';
        l_txmsg.txfields('21').TYPE    := 'N';
        l_txmsg.txfields('21').value   := rec.amt;

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').TYPE    := 'C';
        l_txmsg.txfields('30').value   := v_desc;

        l_txmsg.txfields('35').defname := 'SYMBOL';
        l_txmsg.txfields('35').TYPE    := 'C';
        l_txmsg.txfields('35').value   := rec.symbol;

        l_txmsg.txfields('40').defname := 'TOCODEID';
        l_txmsg.txfields('40').TYPE    := 'C';
        l_txmsg.txfields('40').value   := rec.tosymbol;

        l_txmsg.txfields('50').defname := 'TXKEY';
        l_txmsg.txfields('50').TYPE    := 'C';
        l_txmsg.txfields('50').value   := rec.txkey;

        l_txmsg.txfields('80').defname := 'COUNTRY';
        l_txmsg.txfields('80').TYPE    := 'C';
        l_txmsg.txfields('80').value   := rec.country;

        l_txmsg.txfields('88').defname := 'CUSTODYCD';
        l_txmsg.txfields('88').TYPE    := 'C';
        l_txmsg.txfields('88').value   := rec.custodycd;

        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').TYPE    := 'C';
        l_txmsg.txfields('90').value   := rec.tofullname;

        l_txmsg.txfields('91').defname := 'ADDRESS';
        l_txmsg.txfields('91').TYPE    := 'C';
        l_txmsg.txfields('91').value   := rec.toaddress;

        l_txmsg.txfields('92').defname := 'LICENSE';
        l_txmsg.txfields('92').TYPE    := 'C';
        l_txmsg.txfields('92').value   := rec.toidcode;

        l_txmsg.txfields('93').defname := 'IDDATE';
        l_txmsg.txfields('93').TYPE    := 'C';
        l_txmsg.txfields('93').value   := rec.toiddate;

        l_txmsg.txfields('94').defname := 'IDPLACE';
        l_txmsg.txfields('94').TYPE    := 'C';
        l_txmsg.txfields('94').value   := rec.toidplace;


        savepoint bf_transaction;
        plog.error(pkgctx, 'D :' || rec.camastid);
        BEGIN
          IF txpks_#3385.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;*/
    plog.setendsection(pkgctx, 'auto_call_func_3385');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3385');
  END auto_call_func_3385;


  PROCEDURE pr_process_mt998_539(p_funcname IN VARCHAR2, p_reqid IN NUMBER, p_trflogid IN NUMBER) IS
  v_detail598        varchar2(5000);
  v_subdetail598     varchar2(1000);
  v_count_598_539    number;--bien dung de thoat vong lap
  v_count_detail     number;--bien de log vao vsdtrflogdtl
BEGIN
  plog.setBeginSection(pkgctx,'pr_process_mt539_598');
  if p_funcname = '998.539' THEN
    v_count_detail := 1;
    for rec in (select trim (regexp_substr (mt998.fldval, '[^;]+',1, levels.column_value)) DETAIL
                from (select xt.*
                      from (select * from vsdmsglog where autoid = p_reqid) mst,
                            xmltable('root/txcode/detail/field' passing mst.msgbody
                                      columns fldname varchar2(200) path 'fldname',
                                      fldval clob path 'fldval',
                                      flddesc varchar2(1000) path 'flddesc') xt
                      where xt.fldname IN ('DETAIL598')
                      )mt998 ,
                      table (cast(multiset (select level from dual connect by  level <= length (regexp_replace(mt998.fldval, '[^;]+')) +1)as sys.OdciNumberList )) levels
     )loop
      if (rec.DETAIL is not null and length (rec.DETAIL) >0 ) then
        insert into vsdtrflogdtl(autoid, refautoid, fldname, fldval)
        values (seq_vsdtrflogdtl.nextval, p_trflogid,'DETAIL'||v_count_detail,rec.detail);
        --SAVEPOINT before_insert_mt598;
        v_count_detail := v_count_detail + 1;

      end if;

    end loop;
     insert into vsdtrflogdtl
          (autoid, refautoid, fldname, fldval, caption)
          select seq_vsdtrflogdtl.nextval, p_trflogid, xt.fldname,
                 replace(xt.fldval, ','), xt.flddesc
            from (select * from vsdmsglog where autoid = p_reqid) mst,
                 xmltable('root/txcode/detail/field' passing mst.msgbody
                           columns fldname varchar2(200) path 'fldname',
                           fldval varchar2(4000) path 'fldval',
                           flddesc varchar2(1000) path 'flddesc') xt
            where xt.fldname not in ('DETAIL598');

  end if;
  plog.setEndSection(pkgctx,'pr_process_mt598_539');
EXCEPTION
  WHEN OTHERS THEN
    plog.setEndSection(pkgctx,'pr_process_mt598_539');
END pr_process_mt998_539;
/*
procedure auto_call_txpks_3311 (pv_reqid    number,
                                pv_vsdtrfid number,
                                p_err_code  out varchar2) as
  l_txmsg       tx.msg_rectype;
  l_err_param   VARCHAR2(1000);
  begin
  plog.setbeginsection(pkgctx, 'auto_call_txpks_3311');
    select txdesc into l_txmsg.txdesc from tltx where tltxcd = '3311';
    l_txmsg.tltxcd    := '3311';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := getcurrdate;
    l_txmsg.txdate    := getcurrdate;
  for rec in(
      select CAL.autoid,CAL.CAMASTID,CAL.CUSTODYCD, CA.CODEID,req.txamt QTTY
      from CAREGISTERLOG CAL, CAMAST CA, VSDTXREQ req
      where  req.reqid = pv_reqid
        and req.trfcode = cal.autoid
        and CAL.CAMASTID = CA.CAMASTID
        and CAL.Vsdqtty > 0
        and CAL.Deltd ='N'
  )loop
       SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
       INTO l_txmsg.txnum FROM dual;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').type := 'C';
        l_txmsg.txfields('01').value := rec.CODEID;

        l_txmsg.txfields('02').defname := 'CAMASTID';
        l_txmsg.txfields('02').type := 'C';
        l_txmsg.txfields('02').value := rec.CAMASTID;

        l_txmsg.txfields('04').defname := 'AUTOID';
        l_txmsg.txfields('04').type := 'N';
        l_txmsg.txfields('04').value := rec.AUTOID;

        l_txmsg.txfields('21').defname := 'QTTY';
        l_txmsg.txfields('21').type := 'N';
        l_txmsg.txfields('21').value := rec.QTTY;

        l_txmsg.txfields('96').defname := 'CUSTODYCD';
        l_txmsg.txfields('96').type := 'C';
        l_txmsg.txfields('96').value := REC.CUSTODYCD;

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').type := 'C';
        l_txmsg.txfields('30').value := '';

        savepoint bf_transaction;
        BEGIN
          IF txpks_#3311.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <> systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;

  end loop;
  plog.setendsection(pkgctx, 'auto_call_txpks_3311');
  exception
    when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3311');
 end auto_call_txpks_3311;
*/
 procedure auto_call_func_3370(pv_reqid number, pv_vsdtrfid number, p_err_code out varchar2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3370');

    update camast set pstatus = pstatus||status, status = 'A', last_change = systimestamp
    where camastid = (SELECT msgacct FROM vsdtxreq WHERE reqid = pv_reqid)and status ='V';
    UPDATE caschd SET status='A'
    WHERE camastid = (SELECT msgacct FROM vsdtxreq WHERE reqid = pv_reqid) AND deltd='N' and status ='V';

    plog.setendsection(pkgctx, 'auto_call_func_3370');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_func_3370');
  END auto_call_func_3370;

  PROCEDURE auto_call_txpks_3353(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
    l_txmsg       tx.msg_rectype;
    l_err_param   VARCHAR2(1000);
    l_effect_date DATE;

    v_desc        VARCHAR2(1000);
    v_cdate       DATE;
    v_exist       VARCHAR(1);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3353');
    v_cdate  := getcurrdate;
    -- Kiem tra trang thai REQ
    SELECT decode(count(1), 1, 'Y', 'N') INTO v_exist FROM vsdtxreq req
    WHERE req.reqid = pv_reqid
      AND req.msgstatus in ('A', 'S');

    IF v_exist <> 'Y' THEN
        p_err_code := '-905555';
        plog.setendsection(pkgctx, 'auto_call_txpks_3328');
        RETURN;
    END IF;

    -- Lay mo ta giao dich
    BEGIN
       SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '3353';
    EXCEPTION WHEN OTHERS THEN
       v_desc := '';
    END;

    -- Lay ngay hieu luc hach toan
    BEGIN
       SELECT to_date(substr(fldval,0,8), 'YYYYMMDD')
       INTO l_effect_date
       FROM vsdtrflogdtl
       WHERE refautoid = pv_vsdtrfid and fldname = 'VSDEFFDATE';
    EXCEPTION WHEN OTHERS THEN
        l_effect_date := v_cdate;
    END;

    -- Khoi tao thong tin GD
    l_txmsg.tltxcd    := '3353';
    l_txmsg.msgtype   := 'T';
    l_txmsg.local     := 'N';
    l_txmsg.tlid      := systemnums.c_system_userid;
    l_txmsg.off_line  := 'N';
    l_txmsg.deltd     := txnums.c_deltd_txnormal;
    l_txmsg.txstatus  := txstatusnums.c_txcompleted;
    l_txmsg.msgsts    := '0';
    l_txmsg.ovrsts    := '0';
    l_txmsg.batchname := 'DAY';
    l_txmsg.busdate   := l_effect_date;
    l_txmsg.txdate    := v_cdate;

    SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

    SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
    plog.error(pkgctx, 'D :' ||pv_reqid||SQLERRM || dbms_utility.format_error_backtrace);
    --Lay thong tin dien
    FOR rec IN (
      select catrf.TXNUM, catrf.TXDATE ,cas.afacctno , catrf.camastid, catrf.amt qtty,
             ca.optcodeid codeid,sb.symbol ISSNAME, cf.custodycd,cf.idcode LICENSE,cf.iddate,cf.idplace,
             cf.fullname CUSTNAME,CF.ADDRESS,
             catrf.autoid refid,catrf.CUSTNAME2,catrf.LICENSE2,
             catrf.ADDRESS2, catrf.IDDATE2,catrf.IDPLACE2,catrf.COUNTRY2,
             catrf.TOACCTNO,catrf.TOMEMCUS,cas.autoid, nvl(ca.tocodeid,ca.codeid) tocodeid,
             sb_org.symbol SYMBOL_ORG,
             ca.codeid codeid_org, ca.isincode,
             catrf.feeamt--,catrf.taxamt
             ,re.brid
     from catransfer catrf,camast ca, caschd cas,cfmast cf ,afmast af ,sbsecurities sb,sbsecurities sb_org,VSDTXREQ RE
     wherE CAS.STATUS IN ('V','M') and cas.outbalance>0
     and ca.camastid = cas.camastid  and nvl(ca.tocodeid,ca.codeid) = sb.codeid
     and cas.afacctno = af.acctno
     and af.custid = cf.custid
     and cas.autoid=catrf.caschdid
     AND catrf.status='P'
     and catrf.txnum = re.objkey
     and ca.codeid=sb_org.codeid
     and re.refcode = ca.camastid
     AND RE.REQID = pv_reqid
    ) LOOP
        SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
        INTO l_txmsg.txnum FROM dual;

        l_txmsg.brid := rec.brid;

        l_txmsg.txfields('01').defname := 'CODEID';
        l_txmsg.txfields('01').TYPE    := 'C';
        l_txmsg.txfields('01').value   := rec.codeid;

        l_txmsg.txfields('02').defname := 'AFACCTNO';
        l_txmsg.txfields('02').TYPE    := 'C';
        l_txmsg.txfields('02').value   := rec.afacctno;

        l_txmsg.txfields('03').defname := 'ACCTNO';
        l_txmsg.txfields('03').TYPE    := 'C';
        l_txmsg.txfields('03').value   := rec.afacctno;

        l_txmsg.txfields('06').defname := 'CAMASTID';
        l_txmsg.txfields('06').TYPE    := 'C';
        l_txmsg.txfields('06').value   := rec.camastid;

        l_txmsg.txfields('07').defname := 'TOACCTNO';
        l_txmsg.txfields('07').TYPE    := 'C';
        l_txmsg.txfields('07').value   := rec.toacctno;

        l_txmsg.txfields('08').defname := 'TOMEMCUS';
        l_txmsg.txfields('08').TYPE    := 'C';
        l_txmsg.txfields('08').value   := rec.tomemcus;

        l_txmsg.txfields('09').defname := 'AUTOID';
        l_txmsg.txfields('09').TYPE    := 'N';
        l_txmsg.txfields('09').value   := rec.autoid;

        l_txmsg.txfields('21').defname := 'AMT';
        l_txmsg.txfields('21').TYPE    := 'N';
        l_txmsg.txfields('21').value   := rec.Qtty;

        l_txmsg.txfields('22').defname := 'FEEAMT';
        l_txmsg.txfields('22').TYPE    := 'N';
        l_txmsg.txfields('22').value   := rec.Feeamt;
        /*
        l_txmsg.txfields('23').defname := 'TAXAMT';
        l_txmsg.txfields('23').TYPE    := 'N';
        l_txmsg.txfields('23').value   := rec.Taxamt;*/

        l_txmsg.txfields('30').defname := 'DESC';
        l_txmsg.txfields('30').TYPE    := 'C';
        l_txmsg.txfields('30').value   := v_desc;

        l_txmsg.txfields('31').defname := 'REFID';
        l_txmsg.txfields('31').TYPE    := 'C';
        l_txmsg.txfields('31').value   := rec.refid;

        l_txmsg.txfields('35').defname := 'SYMBOL';
        l_txmsg.txfields('35').TYPE    := 'C';
        l_txmsg.txfields('35').value   := rec.issname;

        l_txmsg.txfields('36').defname := 'CUSTODYCD';
        l_txmsg.txfields('36').TYPE    := 'C';
        l_txmsg.txfields('36').value   := rec.custodycd;

        l_txmsg.txfields('38').defname := 'ISSNAME';
        l_txmsg.txfields('38').TYPE    := 'C';
        l_txmsg.txfields('38').value   := rec.issname;

        l_txmsg.txfields('62').defname := 'TOCODEID';
        l_txmsg.txfields('62').TYPE    := 'C';
        l_txmsg.txfields('62').value   := rec.tocodeid;

        l_txmsg.txfields('71').defname := 'SYMBOL_ORG';
        l_txmsg.txfields('71').TYPE    := 'C';
        l_txmsg.txfields('71').value   := rec.symbol_org;

        l_txmsg.txfields('72').defname := 'CODEID_ORG';
        l_txmsg.txfields('72').TYPE    := 'C';
        l_txmsg.txfields('72').value   := rec.codeid_org;

        l_txmsg.txfields('81').defname := 'COUNTRY2';
        l_txmsg.txfields('81').TYPE    := 'N';
        l_txmsg.txfields('81').value   := rec.country2;

        l_txmsg.txfields('90').defname := 'CUSTNAME';
        l_txmsg.txfields('90').TYPE    := 'C';
        l_txmsg.txfields('90').value   := rec.custname;

        l_txmsg.txfields('91').defname := 'ADDRESS';
        l_txmsg.txfields('91').TYPE    := 'C';
        l_txmsg.txfields('91').value   := rec.address;

        l_txmsg.txfields('92').defname := 'LICENSE';
        l_txmsg.txfields('92').TYPE    := 'C';
        l_txmsg.txfields('92').value   := rec.LICENSE;

        l_txmsg.txfields('93').defname := 'IDDATE';
        l_txmsg.txfields('93').TYPE    := 'C';
        l_txmsg.txfields('93').value   := rec.iddate;

        l_txmsg.txfields('94').defname := 'IDPLACE';
        l_txmsg.txfields('94').TYPE    := 'C';
        l_txmsg.txfields('94').value   := rec.idplace;

        l_txmsg.txfields('95').defname := 'CUSTNAME2';
        l_txmsg.txfields('95').TYPE    := 'C';
        l_txmsg.txfields('95').value   := rec.custname2;

        l_txmsg.txfields('96').defname := 'ADDRESS2';
        l_txmsg.txfields('96').TYPE    := 'C';
        l_txmsg.txfields('96').value   := rec.address2;

        l_txmsg.txfields('97').defname := 'LICENSE2';
        l_txmsg.txfields('97').TYPE    := 'C';
        l_txmsg.txfields('97').value   := rec.license2;

        l_txmsg.txfields('98').defname := 'IDDATE2';
        l_txmsg.txfields('98').TYPE    := 'C';
        l_txmsg.txfields('98').value   := rec.iddate2;

        l_txmsg.txfields('99').defname := 'IDPLACE2';
        l_txmsg.txfields('99').TYPE    := 'C';
        l_txmsg.txfields('99').value   := rec.idplace2;
        savepoint bf_transaction;
        plog.error(pkgctx, 'D :' || rec.autoid ||' & ' || rec.camastid);
        plog.error(pkgctx, 'D.huynh ok :' ||rec.refid);
        BEGIN
          IF txpks_#3353.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
             systemnums.c_success THEN
            ROLLBACK to bf_transaction;
          END IF;
        END;
      END LOOP;
    plog.setendsection(pkgctx, 'auto_call_txpks_3353');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3353');
  END auto_call_txpks_3353;

  PROCEDURE auto_call_func_3358(pv_reqid NUMBER, pv_vsdtrfid NUMBER, p_err_code OUT VARCHAR2)
  AS
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_func_3358');

    --update camast set pstatus = pstatus||status, status = 'A', last_change = systimestamp
    --where camastid = (SELECT msgacct FROM vsdtxreq WHERE reqid = pv_reqid);

    update catransfer set status ='C'
    where camastid = (SELECT refcode FROM vsdtxreq WHERE reqid = pv_reqid)
    AND TXNUM = (SELECT OBJKEY FROM vsdtxreq WHERE reqid = pv_reqid);

    plog.setendsection(pkgctx, 'auto_call_func_3358');
  EXCEPTION WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'auto_call_txpks_3358');
  END auto_call_func_3358;

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
