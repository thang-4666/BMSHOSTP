SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_idexpired (
   pv_IDEXPIRED IN VARCHAR2) RETURN  NUMBER
IS
BEGIN
   -- Check ngay het han phai lon hon ngay hien tai
   -- Ngay het han khong bat buoc nhap
   IF pv_IDEXPIRED IS NULL THEN
      RETURN 0;
   END IF;

   IF to_date(pv_IDEXPIRED, 'DD/MM/RRRR') > getcurrdate THEN
      RETURN 0;
   END IF;

   RETURN -1;
EXCEPTION WHEN OTHERS THEN
   RETURN -1;
END;
/
