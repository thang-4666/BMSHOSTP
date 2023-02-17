SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_trftxnum_trf(pv_trftxnum VARCHAR2) RETURN VARCHAR2
is
v_autoid varchar2(16);
v_currdate VARCHAR2(10);
v_temp VARCHAR2(30);
v_company VARCHAR2(10);
BEGIN
    v_autoid := pv_trftxnum;
    IF pv_trftxnum IS NULL THEN
      SELECT to_char(to_date(varvalue,'DD/MM/YYYY'),'DDMMYY') INTO v_currdate FROM sysvar s WHERE varname='CURRDATE' AND GRNAME='SYSTEM';
      SELECT seq_transfer.nextval INTO v_temp from dual;
      SELECT varvalue INTO v_company FROM sysvar WHERE varname='COMPANYSHORTNAME' AND GRNAME='SYSTEM';

      v_autoid := RPAD(v_company,4,'X') || v_currdate || lpad(v_temp,6,'0');
    END IF;
    return v_autoid;
exception when others then
       return '';
end;
/
