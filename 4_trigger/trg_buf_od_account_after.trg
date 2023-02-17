SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_BUF_OD_ACCOUNT_AFTER 
 AFTER
  INSERT OR UPDATE
 ON buf_od_account
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    pv_ref pkg_report.ref_cursor;
    enq_msgid RAW(16);
begin
if fopks_api.fn_is_ho_active then
    OPEN pv_ref for 
        SELECT 'OD' EVENTTYPE, :newval.FOACCTNO AUTOID,:newval.ORDERID ACCTNO,:newval.CUSTODYCD CUSTODYCD,
            :newval.AFACCTNO AFACCTNO,:newval.TLNAME TLNAME,:newval.USERNAME USERNAME,
            :newval.ODTIMESTAMP LOGTIME, :newval.TXDATE APPLYTIME, :newval.SYMBOL SYMBOL,
            :newval.quoteqtty quoteqtty,:newval.quoteprice quoteprice,:newval.exectype exectype,
            :newval.execqtty execqtty,:newval.orstatusvalue orstatusvalue,
            :newval.ORSTATUS ORSTATUS,:newval.remainqtty remainqtty,
            :newval.pricetype pricetype, DECODE(:newval.pricetype,'LO',:newval.quoteprice,:newval.PRICETYPE) PRICE
        from DUAL;
    txpks_NOTIFY.PR_FLEX2FO_ENQUEUE(PV_REFCURSOR=>pv_ref, ENQ_MSGID=>enq_msgid, queue_name=>'txaqs_FLEX2FO');
end if;
end;
/
