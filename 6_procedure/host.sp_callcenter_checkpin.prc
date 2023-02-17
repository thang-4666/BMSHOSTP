SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_callcenter_checkpin (
  pv_afacctno in varchar2,
  pv_pin in varchar2,
  v_errcode out number) IS
  v_count number;
BEGIN
  v_count := 0;

  SELECT COUNT(1) INTO v_count
  FROM CFMAST CF, AFMAST AF
  WHERE CF.Custid = af.custid
       and cf.pin = trim(pv_pin) and af.acctno = trim(pv_afacctno);

  IF v_count=0 THEN
       v_errcode :=1; --Pin xac thuc sai
  ELSE
       v_errcode :=2; --Pin xac thuc dung
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errcode:= 9; --Loi khong xac dinh
END;
 
/
