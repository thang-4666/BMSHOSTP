SET DEFINE OFF;DELETE FROM DEFERROR WHERE 1 = 1 AND ERRNUM = -900104;Insert into DEFERROR   (ERRNUM, ERRDESC, EN_ERRDESC, MODCODE, CONFLVL) Values   (-900104, '[-900104]:Không được backdate về trước ngày chuyển hồ sơ rút lên VSD!', '[-900104]: Không được backdate về trước ngày chuyển hồ sơ rút lên VSD', 'SE', NULL);COMMIT;