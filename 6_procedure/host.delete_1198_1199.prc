SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DELETE_1198_1199"
   IS
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
    Cursor curTLLOG is
        SELECT TXDATE, TXNUM, MAX(TYPE) TYPE, MAX(ACCT) ACCTNO, SUM(AMT) AMT FROM (
            SELECT TXDATE, TXNUM, 1 TYPE, CVALUE ACCT, 0 AMT FROM TLLOGFLDALL
            WHERE TXNUM IN (SELECT TXNUM FROM TLLOGALL WHERE TLTXCD = '1198' AND DELTD = 'N' AND TXDATE = '09-APR-2007')
                AND TXDATE = '09-APR-2007' AND FLDCD = '03'
            UNION ALL
            SELECT TXDATE, TXNUM, 1 TYPE, CVALUE ACCT, NVALUE AMT FROM TLLOGFLDALL
            WHERE TXNUM IN (SELECT TXNUM FROM TLLOGALL WHERE TLTXCD = '1198' AND DELTD = 'N' AND TXDATE = '09-APR-2007')
                AND TXDATE = '09-APR-2007' AND FLDCD = '10'
        ) GROUP BY TXDATE, TXNUM -- 122 ROWS SELECTED
        UNION ALL
        SELECT TXDATE, TXNUM, MAX(TYPE) TYPE, MAX(ACCT) ACCTNO, SUM(AMT) AMT FROM (
            SELECT TXDATE, TXNUM, 2 TYPE, CVALUE ACCT, 0 AMT FROM TLLOGFLDALL
            WHERE TXNUM IN (SELECT TXNUM FROM TLLOGALL WHERE TLTXCD = '1199' AND DELTD = 'N' AND TXDATE = '09-APR-2007')
                AND TXDATE = '09-APR-2007' AND FLDCD = '03'
            UNION ALL
            SELECT TXDATE, TXNUM, 2 TYPE, CVALUE ACCT, NVALUE AMT FROM TLLOGFLDALL
            WHERE TXNUM IN (SELECT TXNUM FROM TLLOGALL WHERE TLTXCD = '1199' AND DELTD = 'N' AND TXDATE = '09-APR-2007')
                AND TXDATE = '09-APR-2007' AND FLDCD = '10'
        ) GROUP BY TXDATE, TXNUM; -- 247 ROWS SELECTED

    v_strTxdate             DATE;
    v_strTxnum              VARCHAR2(100);
    v_numType               NUMBER;
    v_strAcctno             VARCHAR2(100);
    v_numAmt                NUMBER;

    v_numD                  NUMBER;
    v_numW                  NUMBER;
   -- Declare program variables as shown above
BEGIN
    Set transaction read write;

    v_numD := 0;
    v_numW := 0;

    dbms_output.put_line('Begin reading 1198, 1199 transactions... ');
    Open curTLLOG;
    Loop
        Fetch curTLLOG into v_strTxdate, v_strTxnum, v_numType, v_strAcctno, v_numAmt;
        Exit when curTLLOG%NOTFOUND;

        If (v_numType = 1) then
            v_numD := v_numD + 1;
            dbms_output.put_line('Revert 1198 trans - row '||v_numD||'...');

            UPDATE CIMAST SET BALANCE = BALANCE - v_numAmt, CRAMT = CRAMT - v_numAmt WHERE ACCTNO = v_strAcctno;
        Else
            v_numW := v_numW + 1;
            dbms_output.put_line('Revert 1199 trans - row '||v_numW||'...');

            UPDATE CIMAST SET BALANCE = BALANCE + v_numAmt, DRAMT = DRAMT - v_numAmt WHERE ACCTNO = v_strAcctno;
        End if;
    End loop;
    Close curTLLOG;
    dbms_output.put_line('End reading 1198, 1199 transaction... ');

    dbms_output.put_line('Delete 1198, 1199 transactions in CITRANA... ');
    DELETE FROM CITRANA
    WHERE TXDATE = '09-APR-2007'
        AND TXNUM IN (SELECT TXNUM FROM TLLOGALL WHERE TLTXCD IN ('1198','1199') AND DELTD = 'N' AND TXDATE = '09-APR-2007');

    dbms_output.put_line('DELETE 1198, 1199 TRANSACTIONS FIELDS IN TLLOGFLDALL... ');
    DELETE FROM TLLOGFLDALL
    WHERE TXNUM IN (SELECT TXNUM FROM TLLOGALL WHERE TLTXCD IN ('1198','1199') AND DELTD = 'N' AND TXDATE = '09-APR-2007')
        AND TXDATE = '09-APR-2007';

    dbms_output.put_line('DELETE 1198, 1199 TRANSACTIONS IN TLLOGALL... ');
    DELETE FROM TLLOGALL WHERE TLTXCD IN ('1198','1199') AND DELTD = 'N' AND TXDATE = '09-APR-2007';

    Commit;
EXCEPTION
    WHEN OTHERS THEN
        Begin
            dbms_output.put_line('Why??? ');
            Rollback;
            Return;
        End;
END; -- Procedure

 
 
 
 
/
