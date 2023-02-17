SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_changtypeSA0011(P_value VARCHAR2,P_type VARCHAR2)
return VARCHAR2
is
    V_STRTLNAME   VARCHAR2(2000);
BEGIN
    -- HAM THUC HIEN LAY CHUOI TEN VALUE
    -- DUNG CHO BAO CAO SA0011
    IF P_type ='R' THEN
      SELECT CMD4 INTO V_STRTLNAME
      FROM(
      SELECT (CASE WHEN SUBSTR(P_value,5,1)='A' THEN 'Toàn bộ, '
                   WHEN SUBSTR(P_value,5,1)='B' THEN 'Chi nhánh, '
                   WHEN SUBSTR(P_value,5,1)='C' THEN 'Nhóm Q.lý KH, '
                   WHEN SUBSTR(P_value,5,1)='S' THEN 'Phòng GD, '
                   WHEN SUBSTR(P_value,5,1)='R' THEN 'Khu vực, ' ELSE '' END) CMD4

      FROM DUAL);
	elsif P_type = 'G' then
		SELECT CMD4 INTO V_STRTLNAME
      FROM(
      SELECT (CASE WHEN SUBSTR(P_value,2,1)='A' THEN 'Toàn bộ, '
                   WHEN SUBSTR(P_value,2,1)='B' THEN 'Chi nhánh, '
                   WHEN SUBSTR(P_value,2,1)='C' THEN 'Nhóm Q.lý KH, '
                   WHEN SUBSTR(P_value,2,1)='S' THEN 'Phòng GD, '
                   WHEN SUBSTR(P_value,2,1)='R' THEN 'Khu vực, ' ELSE '' END) CMD4
       FROM dual);
    END IF;
    return V_STRTLNAME;

exception when others then
return '';
end;
 
 
 
 
/
