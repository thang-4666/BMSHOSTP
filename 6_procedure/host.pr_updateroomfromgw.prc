SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_updateroomfromgw(
     p_Isincode IN VARCHAR2,
     p_TotalRoom   IN NUMBER,
     p_CurentRoom   IN NUMBER,
     p_err_code      OUT VARCHAR2,
     p_err_message   OUT VARCHAR2)
IS
  v_CodeID sbsecurities.codeid%Type;
  pkgctx plog.log_ctx;
BEGIN
  plog.setbeginsection (pkgctx, 'pr_updateroomfromgw');
  p_err_code := '0';
  p_err_code := 'Cap nhat room thanh cong';

  SELECT codeid INTO v_CodeID
  FROM sbsecurities
  WHERE isincode = p_Isincode;

  UPDATE securities_info SET
         current_room = p_CurentRoom
  WHERE CODEID = v_CodeID;

  plog.setendsection (pkgctx, 'pr_updateroomfromgw');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_err_code    := '-100010';
    p_err_message := 'Khong tim thay ma chung khoan';
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'pr_updateroomfromgw p_Isincode = ' || p_Isincode);
    plog.setendsection (pkgctx, 'pr_updateroomfromgw');
    ROLLBACK;
  WHEN OTHERS THEN
    p_err_code    := '-1';
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'pr_updateroomfromgw p_Isincode = ' || p_Isincode);
    plog.setendsection (pkgctx, 'pr_updateroomfromgw');
    ROLLBACK;
END;
/
