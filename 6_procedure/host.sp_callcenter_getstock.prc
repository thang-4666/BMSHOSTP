SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_callcenter_getstock(
  pv_phone in varchar2,
  pv_afacctno in varchar2,
  pv_pin in varchar2,
  v_errcode out number,
  PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR) IS
  v_count number;
BEGIN
  v_count := 0;

  --dk kiem tra: (pv_afacctno v?v_phone) hoac (pv_afacctno v?v_pin)
  SELECT COUNT(1) INTO v_count
  FROM CFMAST CF, afmast af
  WHERE cf.custid = af.custid
       and ((af.acctno = trim(pv_afacctno) and cf.phone = trim(pv_phone))
           or (af.acctno = trim(pv_afacctno) and cf.pin = trim(pv_pin))) ;

  IF v_count=0 THEN
       v_errcode :=1; --Pin xac thuc sai
  ELSE
       v_errcode :=2; --Pin xac thuc dung
  END IF;
  open PV_REFCURSOR for
      select afacctno, symbol, max(trade) tradeqtty, max(mortage) dealqtty, max(blocked) blocked,
              sum(securities_receiving_t0 + securities_receiving_t1 + securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn) receivingqtty,
              sum(securities_sending_t0 + securities_sending_t1 + securities_sending_t2 + securities_sending_t3 + securities_sending_tn) sendingqtty
      from buf_se_account
      where afacctno = trim(pv_afacctno)
      and v_errcode = 2
       group by afacctno, symbol
       having sum(trade+mortage+blocked+securities_receiving_t0 + securities_receiving_t1 + securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn+securities_sending_t0 + securities_sending_t1 + securities_sending_t2 + securities_sending_t3 + securities_sending_tn) <> 0;

EXCEPTION
WHEN OTHERS THEN
  v_errcode:= 9; --Loi khong xac dinh
END;
 
/
