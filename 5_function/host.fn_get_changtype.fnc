SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_changtype(P_value VARCHAR2,P_type VARCHAR2)
return VARCHAR2
is
    V_STRTLNAME   VARCHAR2(2000);
BEGIN
    -- HAM THUC HIEN LAY CHUOI TEN VALUE
    -- DUNG CHO BAO CAO SA0007
    IF P_type IN ('M','G') THEN
          SELECT CMD1||CMD2||CMD3||CMD4||CMD5||CMD6||CMD7 INTO V_STRTLNAME
          FROM(
          SELECT (CASE WHEN SUBSTR(P_value,1,1)='Y' THEN 'Truy cập, ' ELSE '' END) CMD1,
                 (CASE WHEN SUBSTR(P_value,2,1)='Y' THEN 'Tìm kiếm, ' ELSE '' END) CMD2,
                 (CASE WHEN SUBSTR(P_value,3,1)='Y' THEN 'Thêm mới, ' ELSE '' END) CMD3,
                 (CASE WHEN SUBSTR(P_value,4,1)='Y' THEN 'Sửa, ' ELSE '' END) CMD4,
                 (CASE WHEN SUBSTR(P_value,5,1)='Y' THEN 'Xóa, ' ELSE '' END) CMD5,
                 (CASE WHEN SUBSTR(P_value,6,1)='Y' THEN 'Duyệt, ' ELSE '' END) CMD6,
                 (CASE WHEN SUBSTR(P_value,7,1)='A' THEN 'Toàn bộ, '
                       WHEN SUBSTR(P_value,7,1)='B' THEN 'Chi nhánh, '
                       WHEN SUBSTR(P_value,7,1)='C' THEN 'Nhóm Q.lý KH, '
                       WHEN SUBSTR(P_value,7,1)='S' THEN 'Phòng GD, '
                       WHEN SUBSTR(P_value,7,1)='R' THEN 'Khu vực, ' ELSE '' END) CMD7
          FROM DUAL
           );
    ELSIF P_type ='R' THEN

          SELECT CMD1||CMD2||CMD3||CMD4 INTO V_STRTLNAME
          FROM(
          SELECT (CASE WHEN SUBSTR(P_value,1,1)='Y' THEN 'Xem, ' ELSE '' END) CMD1,
                 (CASE WHEN SUBSTR(P_value,2,1)='Y' THEN 'In, ' ELSE '' END) CMD2,
                 (CASE WHEN SUBSTR(P_value,3,1)='Y' THEN 'Tạo báo cáo, ' ELSE '' END) CMD3,
                  (CASE WHEN SUBSTR(P_value,7,1)='A' THEN 'Toàn bộ, '
                       WHEN SUBSTR(P_value,7,1)='B' THEN 'Chi nhánh, '
                       WHEN SUBSTR(P_value,7,1)='C' THEN 'Nhóm Q.lý KH, '
                       WHEN SUBSTR(P_value,7,1)='S' THEN 'Phòng GD, '
                       WHEN SUBSTR(P_value,7,1)='R' THEN 'Khu vực, ' ELSE '' END) CMD4

          FROM DUAL
          );
    ELSE  --P_type ='T' THEN
      
    
          SELECT CMD1||CMD2||CMD3 INTO V_STRTLNAME
          FROM(
          SELECT (CASE WHEN SUBSTR(P_value,1,1)='Y' THEN 'Backdate, '
                       WHEN SUBSTR(P_value,1,1)='N' THEN ''
                       WHEN SUBSTR(P_value,1,1)='A' THEN 'Toàn bộ, '
                       WHEN SUBSTR(P_value,1,1)='B' THEN 'Chi nhánh, '
                       WHEN SUBSTR(P_value,1,1)='C' THEN 'Nhóm Q.lý KH, '
                       WHEN SUBSTR(P_value,1,1)='S' THEN 'Phòng GD, '
                       WHEN SUBSTR(P_value,1,1)='R' THEN 'Khu vực, '   ELSE P_value END) CMD1,
                 (CASE WHEN SUBSTR(P_value,2,1) in ('Y','N') THEN ''
                       WHEN SUBSTR(P_value,2,1)='A' THEN 'Toàn bộ, '
                       WHEN SUBSTR(P_value,2,1)='B' THEN 'Chi nhánh, '
                       WHEN SUBSTR(P_value,2,1)='C' THEN 'Nhóm Q.lý KH, '
                       WHEN SUBSTR(P_value,2,1)='S' THEN 'Phòng GD, '
                       WHEN SUBSTR(P_value,2,1)='R' THEN 'Khu vực, '  ELSE '' END) CMD2,
                  (CASE WHEN SUBSTR(P_value,3,1)='A' THEN 'Toàn bộ, '
                       WHEN SUBSTR(P_value,3,1)='B' THEN 'Chi nhánh, '
                       WHEN SUBSTR(P_value,3,1)='C' THEN 'Nhóm Q.lý KH, '
                       WHEN SUBSTR(P_value,3,1)='S' THEN 'Phòng GD, '
                       WHEN SUBSTR(P_value,3,1)='R' THEN 'Khu vực, ' ELSE '' END) CMD3

          FROM DUAL
          );
          
 --   ELSE V_STRTLNAME:=TO_CHAR(P_value);

    END IF;
    return V_STRTLNAME;
    
exception when others then
return '';
end;

 
 
 
 
/
