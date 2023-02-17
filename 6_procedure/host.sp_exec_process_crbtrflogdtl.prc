SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_EXEC_PROCESS_CRBTRFLOGDTL" (p_err_code OUT VARCHAR2,
  p_txdate IN VARCHAR2, p_txnum IN VARCHAR2, p_tltxcd IN VARCHAR2,
  p_reqid  IN VARCHAR2, p_flagprocess IN VARCHAR2)
IS
v_DTLLOGID  NUMBER(20,0);
v_TRFCODE  VARCHAR2(20);
v_VERSION  VARCHAR2(50);
v_APPTXCD  VARCHAR2(20);
v_CHARVAL  VARCHAR2(50);
v_NUMVAL    NUMBER(20,0);
v_ACCTNO  VARCHAR2(50);
v_REFREQID  NUMBER(20,4);
v_DTLSTS   VARCHAR2(10);
v_OBJTYPE  VARCHAR2(50);
v_OBJNAME  VARCHAR2(50);
v_REFCODE  VARCHAR2(50);
v_ERRNUM   NUMBER(20,0);
v_ERRDESC  VARCHAR2(500);
BEGIN
    IF p_tltxcd='6613' THEN
        BEGIN
            SELECT MST.AUTOID, DTL.AUTOID, MST.TRFCODE, DTL.REFREQID, DTL.AFACCTNO, NVL(DTL.AMT,0), DTL.STATUS, RF.OBJTYPE, RF.OBJNAME, RF.REFCODE
            INTO v_VERSION, v_DTLLOGID, v_TRFCODE, v_REFREQID, v_ACCTNO, v_NUMVAL, v_DTLSTS, v_OBJTYPE, v_OBJNAME, v_REFCODE
            FROM CRBTRFLOGDTL DTL, CRBTRFLOG MST, CRBTXREQ RF
            WHERE MST.AUTOID=DTL.VERSION AND DTL.REFREQID=RF.REQID
            AND RF.REQID=to_number(p_reqid) AND DTL.DONESTS='P';

            IF p_flagprocess='Y' THEN
                BEGIN
                    v_APPTXCD:='0088';

                    UPDATE CIMAST SET DEPOFEEAMT=DEPOFEEAMT-v_NUMVAL WHERE ACCTNO=v_ACCTNO;

                    INSERT INTO CITRAN (AUTOID, TXNUM, TXDATE, ACCTNO, TXCD,
                    NAMT, CAMT, REF, DELTD, ACCTREF, TLTXCD, BKDATE, TRDESC)
                    SELECT SEQ_CITRAN.NEXTVAL, p_txnum, TO_DATE(p_txdate, 'DD/MM/RRRR'), v_ACCTNO, v_APPTXCD,
                    v_NUMVAL, NULL, NULL, 'N', v_ACCTNO, p_tltxcd, TO_DATE(p_txdate, 'DD/MM/RRRR'), NULL FROM DUAL;

                    UPDATE CIFEESCHD SET PAIDAMT=FLOATAMT, FLOATAMT=0
                    WHERE AFACCTNO=v_ACCTNO AND TODATE IN
                    (SELECT TO_DATE(CVAL,'DD/MM/RRRR')
                    FROM CRBTXREQDTL WHERE FLDNAME='TODATE' AND REQID=v_REFREQID);

                    UPDATE CRBTXREQ
                    SET STATUS='C', REFTXDATE=TO_DATE(p_txdate, 'DD/MM/RRRR'), REFTXNUM=p_txnum
                    WHERE REQID=v_REFREQID;
                    UPDATE CRBTRFLOGDTL SET DONESTS='C', REFTXDATE=TO_DATE(p_txdate, 'DD/MM/RRRR'), REFTXNUM=p_txnum
                    WHERE AUTOID=v_DTLLOGID;
                END;
            ELSE
                BEGIN
                    UPDATE CIFEESCHD SET FLOATAMT=0
                    WHERE AFACCTNO=v_ACCTNO AND TODATE IN
                    (SELECT TO_DATE(CVAL,'DD/MM/RRRR')
                    FROM CRBTXREQDTL WHERE FLDNAME='TODATE' AND REQID=v_REFREQID);

                    UPDATE CRBTXREQ SET STATUS='E', REFTXDATE=TO_DATE(p_txdate, 'DD/MM/RRRR'), REFTXNUM=p_txnum
                    WHERE REQID=v_REFREQID;

                    UPDATE CRBTRFLOGDTL SET DONESTS='E', REFTXDATE=TO_DATE(p_txdate, 'DD/MM/RRRR'), REFTXNUM=p_txnum
                    WHERE AUTOID=v_DTLLOGID;
                END;
            END IF;
        END;
    ELSIF p_tltxcd='6660' THEN
        BEGIN
            SELECT OBJTYPE,OBJNAME,REFCODE
            INTO v_OBJTYPE,v_OBJNAME,v_REFCODE
            FROM CRBTXREQ WHERE REQID=p_reqid;

            IF v_OBJTYPE='V' THEN
                IF v_OBJNAME='FOMAST' THEN
                    UPDATE FOMAST SET DIRECT='N',STATUS='P',FEEDBACKMSG='Complete Hold, Reqid:' || p_reqid
                    WHERE ACCTNO=v_REFCODE;

                    UPDATE CRBTXREQ SET STATUS='C' WHERE REQID=p_reqid;
                ELSIF v_OBJNAME='CAR' THEN
                    BEGIN
                        UPDATE BORQSLOG SET STATUS='H'
                        WHERE AUTOID=TO_NUMBER(v_REFCODE);

                        UPDATE CRBTXREQ SET STATUS='C' WHERE REQID=p_reqid;
                    END;
                END IF;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                plog.error('6660:No datafouned, ReqID:'||p_reqid);
        END;
    ELSIF p_tltxcd='6620' THEN
        BEGIN
            SELECT OBJTYPE,OBJNAME,REFCODE
            INTO v_OBJTYPE,v_OBJNAME,v_REFCODE
            FROM CRBTXREQ WHERE REQID=p_reqid;

            IF v_OBJTYPE='V' THEN
                IF v_OBJNAME='FOMAST' THEN
                    BEGIN
                        --Lay ma loi tra ve
                        BEGIN
                            SELECT ERR.ERRDESC INTO v_ERRDESC
                            FROM DEFERROR ERR,CRBTXREQ REQ
                            WHERE ERR.ERRNUM=TO_NUMBER(REQ.errorcode)
                            AND REQ.REQID=p_reqid;
                        EXCEPTION WHEN OTHERS THEN
                            --Truong hop khong co ma loi nao
                            v_ERRDESC:='Unknown Error';
                        END;

                        UPDATE FOMAST SET STATUS='R',FEEDBACKMSG= v_ERRDESC
                        WHERE ACCTNO=v_REFCODE;

                        UPDATE CRBTXREQ SET STATUS='E' WHERE REQID=p_reqid;
                    END;
                ELSIF v_OBJNAME='CAR' THEN
                    BEGIN
                        --Lay ma loi tra ve
                        BEGIN
                            SELECT ERR.ERRDESC INTO v_ERRDESC
                            FROM DEFERROR ERR,CRBTXREQ REQ
                            WHERE ERR.ERRNUM=TO_NUMBER(REQ.errorcode)
                            AND REQ.REQID=p_reqid;
                        EXCEPTION WHEN OTHERS THEN
                            --Truong hop khong co ma loi nao
                            v_ERRDESC:='Unknown Error';
                        END;

                        UPDATE BORQSLOG SET STATUS='R',FEEDBACKMSG=v_ERRDESC
                        WHERE AUTOID=TO_NUMBER(v_REFCODE);

                        UPDATE CRBTXREQ SET STATUS='E' WHERE REQID=p_reqid;
                    END;
                END IF;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                plog.error('6620:No datafouned, ReqID:'||p_reqid);
        END;
    ELSE
        BEGIN
            IF p_flagprocess='Y' THEN
                BEGIN
                    UPDATE CRBTXREQ SET STATUS='C' WHERE REQID=p_reqid;
                END;
            ELSE
                BEGIN
                    UPDATE CRBTXREQ SET STATUS='E' WHERE REQID=p_reqid;
                END;
            END IF;
        END;
    END IF;

    p_err_code :='0';
EXCEPTION
    WHEN OTHERS THEN
    plog.error('sp_exec_process_crbtrflogdtl:'||dbms_utility.format_error_backtrace);
    p_err_code :='-1';
END;

 
 
 
 
/
