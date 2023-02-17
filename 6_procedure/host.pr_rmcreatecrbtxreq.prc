SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_RMCreateCRBTXREQ (p_err_code OUT VARCHAR2)
IS
TYPE v_CurTyp  IS REF CURSOR;
v_OBJTYPE      VARCHAR2(50);
v_OBJNAME      VARCHAR2(50);
v_FLDTRFCODE    VARCHAR2(50);
v_FLDAFFECTDATE    VARCHAR2(100);
v_FLDBANK      VARCHAR2(50);
v_FLDACCTNO   VARCHAR2(50);
v_FLDBANKACCT    VARCHAR2(50);
v_FLDREFCODE    VARCHAR2(50);
v_FLDNOTES    VARCHAR2(50);
v_FLDAMTEXP    VARCHAR2(50);
v_AMTEXP      VARCHAR2(50);
v_TXNUM      VARCHAR2(20);
v_TXDATE      DATE;
v_CHARTXDATE   VARCHAR2(20);
v_TRFCODE      VARCHAR2(50);
v_REFCODE    VARCHAR2(50);
v_BANK      VARCHAR2(50);
v_AFFECTDATE    VARCHAR2(100);
v_BANKACCT    VARCHAR2(50);
v_AFACCTNO    VARCHAR2(10);
v_NOTES      VARCHAR2(3000);
v_VALUE      VARCHAR2(300);
v_REFAUTOID    NUMBER;
v_CURRDATE     varchar2(250);
v_extCMDSQL   VARCHAR2(5000);
c0        v_CurTyp;
BEGIN
  p_err_code:='0';

  SELECT VARVALUE INTO v_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

  --Lap lay ra cac tltx co khai bao ma phat sinh giao dich
  FOR rec IN (
    SELECT LG.TLTXCD,LG.TXNUM,LG.TXDATE,CRM.OBJTYPE,CRM.OBJNAME,
    CRM.TRFCODE,CRM.AFFECTDATE,CRM.FLDBANK,CRM.FLDACCTNO,CRM.FLDBANKACCT,
    CRM.FLDREFCODE,CRM.FLDNOTES,CRM.AMTEXP
    FROM TLLOG LG,CRBTXMAP CRM
    WHERE LG.TLTXCD=CRM.OBJNAME AND CRM.OBJTYPE='T'
    AND LG.TXSTATUS='1' AND LG.DELTD<>'Y' AND LG.TLTXCD NOT IN ('6600','6640') AND LG.TLTXCD IN ('6641','6643')
    AND NOT EXISTS (
        SELECT * FROM CRBTXREQ REQ WHERE REQ.OBJKEY=LG.TXNUM AND REQ.TXDATE=LG.TXDATE
        AND (REQ.TRFCODE = CRM.TRFCODE OR SUBSTR(CRM.TRFCODE,1,1)='$')
    )
  )
  LOOP
    BEGIN
        v_CHARTXDATE:=TO_CHAR(rec.TXDATE,'DD/MM/YYYY');

        IF rec.FLDREFCODE IS NULL THEN
            v_REFCODE:= v_CHARTXDATE || rec.TXNUM;
        ELSE
            v_REFCODE:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDREFCODE);
        END IF;

        --TAO YEU CAU LAP BANG KE: GHI VAO BANG CRBTXREQ/CRBTXREQDTL
        v_TRFCODE:=rec.TRFCODE;
        IF SUBSTR(v_TRFCODE,1,1)='$' THEN
        --LAY  TRFCODE THEO GIAO DICH
        v_TRFCODE:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, v_TRFCODE);
        END IF;

        IF rec.AFFECTDATE='<$TXDATE>' THEN
            v_AFFECTDATE:=v_CURRDATE;
        ELSE
            v_AFFECTDATE:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.AFFECTDATE);
        END IF;

        v_AFACCTNO := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDACCTNO);
        v_NOTES := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDNOTES);
        v_VALUE := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.AMTEXP);
        v_BANKACCT := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDBANKACCT);

        IF v_BANKACCT='0' THEN
        v_BANKACCT:=NULL;
        END IF;

        IF SUBSTR(v_FLDBANKACCT,1,1)='#' THEN
        --XAC DINH THONG TIN BO XUNG
        IF v_BANKACCT IS NOT NULL THEN
           v_BANKACCT:= FN_CRB_GETCFACCTBYTRFCODE(v_TRFCODE, v_BANKACCT);
        END IF;
        END IF;

        v_BANK:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDBANK);
        IF v_BANK='0' THEN
        v_BANK:=NULL;
        END IF;

        IF SUBSTR(rec.FLDBANK,1,1)='#' THEN
        --XAC DINH THONG TIN BO XUNG
        IF v_BANK IS NOT NULL THEN
           v_BANK:= FN_CRB_GETBANKCODEBYTRFCODE(v_TRFCODE, v_BANK);
        END IF;
        END IF;
        --Neu lay ra truong ko tim thay thi phai de null de khong sinh bang ke
        IF v_BANK='0' THEN
        v_BANK:=NULL;
        END IF;

        IF (NOT v_BANK IS NULL) AND (NOT v_BANKACCT IS NULL) AND (TO_NUMBER(v_VALUE)>0) THEN
            BEGIN
                v_REFAUTOID:=SEQ_CRBTXREQ.NEXTVAL;

                INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                VALUES (v_REFAUTOID, 'T', rec.TLTXCD, rec.TXNUM, v_TRFCODE, v_REFCODE, rec.TXDATE, TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), v_AFACCTNO, v_VALUE, v_BANK, v_BANKACCT, 'P', NULL, v_NOTES);

                FOR rc IN (
                    SELECT FLDNAME, FLDTYPE, AMTEXP, CMDSQL
                    FROM CRBTXMAPEXT MST WHERE MST.OBJTYPE ='T'
                    AND MST.OBJNAME = rec.TLTXCD AND TRFCODE=rec.TRFCODE
                )
                LOOP
                    BEGIN
                        IF NOT rc.AMTEXP IS NULL THEN
                          v_VALUE := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rc.AMTEXP);
                        END IF;
                        IF NOT rc.CMDSQL IS NULL THEN
                            BEGIN
                              v_extCMDSQL:=REPLACE(rc.CMDSQL,'<$FILTERID>',v_VALUE);
                              BEGIN
                                  OPEN c0 FOR v_extCMDSQL;
                                  FETCH c0 INTO v_VALUE;
                                  CLOSE c0;
                              EXCEPTION
                                WHEN OTHERS THEN
                                    v_VALUE:='0';
                              END;
                            END;
                        END IF;

                        INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                          SELECT SEQ_CRBTXREQDTL.NEXTVAL, v_REFAUTOID, rc.FLDNAME,
                          DECODE(rc.FLDTYPE, 'N', NULL, TO_CHAR(v_VALUE)),
                          DECODE(rc.FLDTYPE, 'N', v_VALUE, 0) FROM DUAL;
                    END;
                END LOOP;
            END;
        END IF;
    END;
  END LOOP;

  p_err_code:='0';
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
