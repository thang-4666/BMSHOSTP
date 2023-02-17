SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_eval_amtexp(p_txnum IN VARCHAR2, p_txdate IN VARCHAR2, p_REFVAL IN VARCHAR2,p_FLDTYPE IN VARCHAR DEFAULT '')
  RETURN  varchar2
  IS
  TYPE v_CurTyp  IS REF CURSOR;
  c1        v_CurTyp;
  v_RETURN   varchar2(500);
  v_RETURN2   varchar2(500);
  v_EXPRESSION varchar2(250);
  v_CURRDATE varchar2(10);
BEGIN
  v_RETURN:='0';
  IF NOT p_REFVAL IS NULL THEN
    BEGIN
      IF SUBSTR(p_REFVAL,1,1)='@' THEN
        --LAY TRUC TIEP GIA TRI
        v_RETURN := SUBSTR(p_REFVAL,2);
      ELSIF SUBSTR(p_REFVAL,1,1) IN ('$', '#') THEN
        BEGIN
          --LAY THEO MOT TRUONG TREEN MAN HINH
          v_EXPRESSION := SUBSTR(p_REFVAL,2, 2);  --LAY MA TRUONG DU LIEU
          SELECT VARVALUE INTO v_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';
          IF v_CURRDATE=p_txdate THEN
            SELECT CASE WHEN p_FLDTYPE IS NULL THEN NVL(CVALUE, TO_CHAR(NVALUE))
                        WHEN p_FLDTYPE IN ('N') THEN TO_CHAR(NVALUE)
                        ELSE CVALUE
                   END INTO v_RETURN
            FROM TLLOGFLD WHERE TXNUM=p_txnum AND TXDATE=TO_DATE(p_txdate,'DD/MM/YYYY') AND FLDCD=v_EXPRESSION;
          ELSE
            SELECT CASE WHEN p_FLDTYPE IS NULL THEN NVL(CVALUE, TO_CHAR(NVALUE))
                        WHEN p_FLDTYPE IN ('N') THEN TO_CHAR(NVALUE)
                        ELSE CVALUE
                   END INTO v_RETURN
            FROM TLLOGFLDALL WHERE TXNUM=p_txnum AND TXDATE=TO_DATE(p_txdate,'DD/MM/YYYY') AND FLDCD=v_EXPRESSION;
          END IF;
        END;
      ELSIF p_REFVAL = '<$BUSDATE>' THEN
        --BIEN HE THONG
        SELECT VARVALUE INTO v_RETURN FROM SYSVAR WHERE GRNAME='SYSTEM' AND VARNAME='CURRDATE';
      ELSIF p_REFVAL = '<$TXNUM>' THEN
        --BIEN HE THONG
        SELECT p_txnum INTO v_RETURN FROM dual;

      ELSIF p_REFVAL = '<$COMPANYNAME>' THEN
        --BIEN HE THONG
        SELECT VARVALUE INTO v_RETURN FROM SYSVAR WHERE GRNAME='SYSTEM' AND VARNAME='COMPANYNAME';
      ELSE
        BEGIN
          --BIEU THUC TINH TOAN SO HOC
          v_EXPRESSION := FN_CRB_BUILDAMTEXP(p_REFVAL, p_txnum, p_txdate);
          OPEN c1 FOR 'SELECT TO_CHAR(' || v_EXPRESSION || ') AS RETVAL FROM DUAL';
          FETCH c1 INTO v_RETURN;
          CLOSE c1;
        END;
      END IF;
      IF SUBSTR(p_REFVAL,4,1) IN ('+') THEN
        BEGIN
          --LAY THEO MOT TRUONG TREEN MAN HINH
          v_EXPRESSION := SUBSTR(p_REFVAL,6, 2);  --LAY MA TRUONG DU LIEU
          SELECT VARVALUE INTO v_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';
          IF v_CURRDATE=p_txdate THEN
            SELECT (CASE WHEN CVALUE IS NULL THEN TO_CHAR(NVALUE) ELSE CVALUE END) INTO v_RETURN2
            FROM TLLOGFLD WHERE TXNUM=p_txnum AND TXDATE=TO_DATE(p_txdate,'DD/MM/YYYY') AND FLDCD=v_EXPRESSION;
          ELSE
            SELECT (CASE WHEN CVALUE IS NULL THEN TO_CHAR(NVALUE) ELSE CVALUE END) INTO v_RETURN2
            FROM TLLOGFLDALL WHERE TXNUM=p_txnum AND TXDATE=TO_DATE(p_txdate,'DD/MM/YYYY') AND FLDCD=v_EXPRESSION;
          END IF;
          v_RETURN:=v_RETURN||v_RETURN2;
        END;
      END IF;
    END;

  END IF;
  RETURN v_RETURN;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '0';
END;
/
