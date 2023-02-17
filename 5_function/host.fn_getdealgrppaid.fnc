SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdealgrppaid(fv_acctno in varchar2)
  RETURN number IS
  v_Result number;
  v_values number;
  v_overdfqtty number;
  v_dfrlsqtty number;
  v_dfqtty number;
  v_strCURRDATE date;
  v_hostatus varchar2(10);
BEGIN
    SELECT TO_DATE (varvalue, 'DD/MM/RRRR')
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT varvalue
               INTO v_hostatus
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'HOSTATUS';
    v_Result:=0;
    --Neu dong cua hoi so thi khong tinh no.
    if v_hostatus ='0' THEN
        return v_Result;
    end if;
    v_Result:=0;
    select nvl(sum(VNDSELLDF),0) into v_Result from v_getgrpdealformular where  isvsd ='N' and afacctno =fv_acctno;
    return v_Result;
EXCEPTION when others then
    return 0;
END; 
 
 
 
 
 
 
 
 
 
 
 
/
