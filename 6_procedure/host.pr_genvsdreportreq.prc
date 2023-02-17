SET DEFINE OFF;
CREATE OR REPLACE procedure pr_GenVSDReportReq(
pv_brid        in varchar2,
pv_tlid        in varchar2,
pv_rptid       in varchar2,
pv_rptinput    in varchar2,
p_errcode      out varchar2
) is
    v_txnum    varchar2(10);
    v_txdate   date;
begin
    v_txnum  := 5||lpad(seq_vsdreportreq_txnum.nextval,9,'0');
    v_txdate := getcurrdate;
    insert into vsdreportreq_log(id, txnum, txdate, brid, tlid, rptid, rptinput, createddt)
    values(seq_vsdreportreq_log.nextval, v_txnum, v_txdate, pv_brid, pv_tlid, pv_rptid, pv_rptinput, sysdate);
    insert into vsd_process_log(autoid, trfcode, tltxcd, txnum, txdate, process, time, msgacct, brid, tlid)
    values(seq_vsd_process_log.nextval, '595.STPR', '6630', v_txnum, v_txdate, 'N', sysdate, null, pv_brid, pv_tlid);
    p_errcode := SYSTEMNUMS.C_SUCCESS;
exception
  when others then
      ROLLBACK;
      p_errcode := errnums.C_SYSTEM_ERROR;
      plog.error(SQLERRM || dbms_utility.format_error_backtrace);
end;
/
