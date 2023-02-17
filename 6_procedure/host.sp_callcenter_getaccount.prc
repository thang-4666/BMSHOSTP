SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_callcenter_getaccount (
  pv_phone in varchar2,
  pv_afacctno in varchar2,
  pv_pin in varchar2,
  v_errcode out number,
  v_balance out number) IS
  v_count number;
BEGIN
  v_count := 0;
  v_balance:= 0;

  --dk kiem tra: (pv_afacctno v�v_phone) hoac (pv_afacctno v�v_pin)
  SELECT COUNT(1) INTO v_count
  FROM CFMAST CF, afmast af
  WHERE cf.custid = af.custid
       and ((af.acctno = trim(pv_afacctno) and cf.phone = trim(pv_phone))
           or (af.acctno = trim(pv_afacctno) and cf.pin = trim(pv_pin))) ;
  IF v_count=0 THEN
       v_errcode :=1; --Pin xac thuc sai
  ELSE
       select round(getbaldefovd(trim(pv_afacctno)))  into v_balance
       from dual;
       v_errcode :=2; --Pin xac thuc dung
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errcode:= 9; --Loi khong xac dinh
  v_balance:= 0;
END;
 
/
