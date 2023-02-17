SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_caltddeposits(PV_ACCTNO IN VARCHAR2, PV_IDATE IN DATE, PV_TXNUM IN varchar2)
RETURN NUMBER
IS
    tddeposits NUMBER;
BEGIN
    SELECT sum(CASE WHEN tx.txtype = 'C' THEN nvl(tran.namt, 0) ELSE -(nvl(tran.namt, 0)) END)
        INTO tddeposits
     from
    (SELECT * FROM tdtran UNION ALL SELECT * FROM tdtrana) tran,
    apptx tx
    WHERE tran.txcd = tx.txcd
    AND tx.apptype = 'TD'
    AND tx.field = 'BALANCE'
    AND txdate <= pv_idate
    AND acctno = PV_ACCTNO
    AND tran.txnum <= PV_TXNUM;
    RETURN tddeposits;
END;
 
 
 
 
/
