SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -100722;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-100722, '[-100722]: Hệ thống còn tồn tại lệnh bán thỏa thuận tổng chưa phân bổ, phải thực hiện phân bổ trước xử lý cuối ngày!', '[-100722]: Hệ thống còn tồn tại lệnh bán thỏa thuận tổng chưa phân bổ, phải thực hiện phân bổ trước xử lý cuối ngày!', 'SA', NULL);COMMIT;