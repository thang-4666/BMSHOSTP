SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_callcenter_checkcustomer (
  pv_phonenumber in varchar2,
  pv_afacctno in varchar2,
  v_errcode out number) IS
  v_count number;
  v_count2 number;
  v_count3 number;
BEGIN
  v_count := 0;
  v_count2 := 0;
  v_count3 := 0;

  SELECT COUNT(1) INTO v_count
  FROM CFMAST CF, AFMAST AF
  WHERE CF.custid = af.custid and af.acctno = trim(pv_afacctno);

  IF v_count=0 THEN
        SELECT COUNT(*) INTO v_count2
        FROM CFMAST
        WHERE PHONE = trim(pv_phonenumber);
        if v_count2 = 0 then
           v_errcode :=1; --So dien thoai va tieu khoan deu khong co trong DB
        else
           v_errcode := 3; --So dien thoai dung, tieu khoan sai
        end if;
  ELSE
        SELECT COUNT(*) INTO v_count2
        FROM CFMAST
        WHERE PHONE = trim(pv_phonenumber);
        if v_count2 = 0 then
           v_errcode := 2; --So dien thoai sai, tieu khoan dung
        else
            SELECT COUNT(*) INTO v_count3
            FROM CFMAST CF, AFMAST AF
            WHERE cf.custid = af.custid
                  and af.acctno  = trim(pv_afacctno)
                  and cf.PHONE = trim(pv_phonenumber);
            if v_count3 = 0 then
               v_errcode := 5; --So dien thoai va khach hang khong map voi nhau
            else
               v_errcode := 4; -- Thanh cong
            end if;
        end if;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  v_errcode:= 9; --Loi khong xac dinh
END;
 
/
