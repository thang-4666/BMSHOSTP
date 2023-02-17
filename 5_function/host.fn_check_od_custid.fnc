SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_od_custid (pv_orderid IN VARCHAR2,pv_afacctno IN varchar)
RETURN NUMBER
  IS
  v_Result number;
  l_afacctno varchar2(10);
BEGIN
    v_Result:=1;
    --Lay tieu khoan cua lenh goc
    select distinct afacctno into l_afacctno
    from (select orderid, afacctno from odmast
            union all
          select acctno, afacctno from fomast) od
    where orderid=pv_orderid;
    --check dung tieu khoan chinh chu
    IF pv_afacctno = l_afacctno THEN
        v_Result:=0;
    END IF;
    RETURN v_Result;
EXCEPTION WHEN others THEN
    plog.error('fn_check_od_custid.Error: '||SQLERRM ||'-'||dbms_utility.format_error_backtrace);
    return  -1;
END;
 
/
