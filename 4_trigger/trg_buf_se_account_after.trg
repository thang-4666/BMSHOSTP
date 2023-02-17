SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_BUF_SE_ACCOUNT_AFTER 
 AFTER
  INSERT OR UPDATE
 ON buf_se_account
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    pv_ref pkg_report.ref_cursor;
    enq_msgid RAW(16);
begin
if fopks_api.fn_is_ho_active then
    OPEN pv_ref for 
        SELECT 'SE' EVENTTYPE, :newval.ACCTNO AUTOID,:newval.ACCTNO ACCTNO,
            :newval.AFACCTNO AFACCTNO,sysdate LOGTIME, 
            :newval.LASTDATE APPLYTIME,:newval.SYMBOL SYMBOL,:newval.STATUS STATUS,
            :newval.TRADE TRADE,:newval.TOTAL_QTTY TOTAL_QTTY, :newval.MORTAGE MORTAGE,
            :newval.AVLWITHDRAW AVLWITHDRAW,:newval.MRRATIORATE MRRATIORATE
        from DUAL;
    txpks_NOTIFY.PR_FLEX2FO_ENQUEUE(PV_REFCURSOR=>pv_ref, ENQ_MSGID=>enq_msgid, queue_name=>'txaqs_FLEX2FO');
end if;
end;
/
