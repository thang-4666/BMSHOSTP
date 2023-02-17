SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RPT001" (whr nvarchar2 := NULL)
   IS

    v_refCursor PKG_REPORT.ref_cursor;
   -- Declare program variables as shown above
BEGIN
    Open v_refCursor for
        'SELECT * from ALLCODE WHERE ' || NVL(whr, '1=1');

    dbms_output.put_line('Row count: '||v_refCursor%ROWCOUNT);

    Close v_refCursor;
EXCEPTION
    WHEN OTHERS THEN
        Return;
END; -- Procedure

 
 
 
 
/
