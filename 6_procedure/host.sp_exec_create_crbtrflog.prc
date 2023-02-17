SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_EXEC_CREATE_CRBTRFLOG" (p_err_code OUT VARCHAR2, p_txdate IN VARCHAR2,
  p_tlid IN VARCHAR2, p_brid IN VARCHAR2,p_trfcode  IN VARCHAR2, p_lreqid IN VARCHAR2)
IS
TYPE v_CurTyp  IS REF CURSOR;
v_BANKCODE  VARCHAR2(20);
v_TRFCODE   VARCHAR2(20);
v_AFFECTDATE VARCHAR2(10);
v_TRFLOGID  NUMBER(20,0);
v_VERSION  VARCHAR2(20);
c1        v_CurTyp;
c2        v_CurTyp;
c3        v_CurTyp;
v_stmt_str      VARCHAR2(200);
BEGIN
  p_err_code:='0';
  -- Dynamic SQL statement with placeholder:
  v_stmt_str := 'SELECT DISTINCT BANKCODE FROM CRBTXREQ WHERE REQID IN (' || p_lreqid || ')';
  OPEN c1 FOR v_stmt_str;
  --Luot qua danh sach bankcode cua bang ke
  LOOP
    FETCH c1 INTO v_BANKCODE;
    EXIT WHEN c1%NOTFOUND;
    IF p_trfcode IS NULL THEN
        BEGIN
            --Luot qua danh sach cac TRFCODE cua bang ke
            v_stmt_str := 'SELECT DISTINCT TRFCODE FROM CRBTXREQ WHERE BANKCODE=''' || v_BANKCODE || ''' AND REQID IN (' || p_lreqid || ') AND STATUS=''P''';
            OPEN c2 FOR v_stmt_str;
            LOOP
                BEGIN
                    --Voi moi TRFCODE , sinh 1 ma bang ke tuong ung
                    FETCH c2 INTO v_TRFCODE;
                    EXIT WHEN c2%NOTFOUND;
                    --Loc ra cac bang ke voi ngay affectdate khac nhau
                    v_stmt_str := 'SELECT DISTINCT TO_CHAR(AFFECTDATE,''DD/MM/RRRR'') FROM CRBTXREQ WHERE BANKCODE=''' || v_BANKCODE || ''' AND TRFCODE=''' || v_TRFCODE || ''' AND REQID IN (' || p_lreqid || ')';
                    OPEN c3 FOR  v_stmt_str;
                    LOOP
                        BEGIN
                            FETCH c3 INTO v_AFFECTDATE;
                            EXIT WHEN c3%NOTFOUND;

                            --Lay ID cua CRBTRFLOG
                            SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

                            SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
                              (SELECT ROWNUM ODR, INVACCT
                              FROM (SELECT VERSION INVACCT
                                FROM CRBTRFLOG WHERE TXDATE=TO_DATE(p_txdate,'DD/MM/RRRR') AND TRFCODE=v_TRFCODE
                                ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

                            --Log v?CRBTRFLOG: STATUS = PENDING. S? d?ng tru?ng FeedBack d? c?p nh?t b?ng chi ti?t
                            INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
                            SELECT v_TRFLOGID, v_VERSION, TO_DATE(p_txdate,'DD/MM/RRRR'), TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), p_tlid,
                              SYSTIMESTAMP, v_BANKCODE, v_TRFCODE, 'P','N', TO_CHAR(p_lreqid) FROM DUAL;

                            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'VERSION',
                              NULL, TO_CHAR(v_TRFLOGID), 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'REFBANK',
                              NULL, v_BANKCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'TRFCODE',
                              NULL, v_TRFCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                        END;
                    END LOOP;
                END;
            END LOOP;
            CLOSE c2;
        END;
    ELSE
        BEGIN
            --Lay ID cua CRBTRFLOG
            SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

            SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
              (SELECT ROWNUM ODR, INVACCT
              FROM (SELECT VERSION INVACCT
                FROM CRBTRFLOG WHERE TXDATE=TO_DATE(p_txdate,'DD/MM/RRRR') AND TRFCODE=p_trfcode
                ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

            INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS, ERRSTS, FEEDBACK)
            SELECT v_TRFLOGID, v_VERSION, TO_DATE(p_txdate,'DD/MM/RRRR'), TO_DATE(p_txdate,'DD/MM/RRRR'), p_tlid,
              SYSTIMESTAMP, v_BANKCODE, p_trfcode, 'P', 'N', TO_CHAR(p_lreqid) FROM DUAL;

            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'VERSION',
              NULL, TO_CHAR(v_TRFLOGID), 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'REFBANK',
              NULL, v_BANKCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'TRFCODE',
              NULL, p_trfcode, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
        END;
    END IF;
  END LOOP;
  CLOSE c1;
  --Log vao CRBTRFLOGDTL
  INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS)
  SELECT SEQ_CRBTRFLOGDTL.NEXTVAL AUTOID, RF.VERSION,DTL.TRFCODE, RF.TXDATE, DTL.REQID, DTL.AFACCTNO, DTL.TXAMT, DTL.NOTES, 'P'
  FROM CRBTXREQ DTL, CRBTRFLOG RF WHERE DTL.BANKCODE=RF.REFBANK AND DTL.TRFCODE=RF.TRFCODE AND DTL.AFFECTDATE=RF.AFFECTDATE
  AND RF.FEEDBACK=p_lreqid AND INSTR(TO_CHAR(RF.FEEDBACK) || ',',TO_CHAR(DTL.REQID) || ',',1)>0
  AND DTL.STATUS='P';
  --C?p nhat lai trang thai cua CRBTXREQ la da tao bang ke
  UPDATE CRBTXREQ SET STATUS='A' WHERE INSTR(p_lreqid || ',',TO_CHAR(REQID) || ',',1)>0 AND STATUS='P';
  --Reset lai Feedback
  UPDATE CRBTRFLOG SET FEEDBACK=NULL WHERE FEEDBACK=p_lreqid;

  COMMIT;
  RETURN;
END;

 
 
 
 
/
