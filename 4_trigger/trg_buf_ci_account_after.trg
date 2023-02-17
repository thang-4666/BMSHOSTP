SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_BUF_CI_ACCOUNT_AFTER 
 AFTER
  INSERT OR UPDATE
 ON buf_ci_account
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    pv_ref pkg_report.ref_cursor;
    enq_msgid RAW(16);
begin
if fopks_api.fn_is_ho_active then
    OPEN pv_ref for 
        SELECT 'CI' EVENTTYPE, :newval.AFACCTNO AUTOID,:newval.AFACCTNO ACCTNO,
            :newval.AFACCTNO AFACCTNO,sysdate LOGTIME, :newval.LASTDATE APPLYTIME, 
            :newval.PPREF PPREF,:newval.PP PP,:newval.BALANCE BALANCE,:newval.BALDEFOVD BALDEFOVD,
            :newval.AVLWITHDRAW AVLWITHDRAW,:newval.AVLADVANCE AVLADVANCE
        from dual;
    txpks_NOTIFY.PR_FLEX2FO_ENQUEUE(PV_REFCURSOR=>pv_ref, ENQ_MSGID=>enq_msgid, queue_name=>'txaqs_FLEX2FO');
 end if;
    
end;
/
