SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_groupname(P_STRGRPID VARCHAR2)
return VARCHAR2
is
    V_STRGRPNAME   VARCHAR2(2000);
BEGIN
    -- HAM THUC HIEN LAY CHUOI TEN NHOM QUYEN
    -- DUNG CHO BAO CAO SA0007
    FOR REC IN
    (
        SELECT * FROM tlgroups WHERE instr(P_STRGRPID,grpid) >0 AND GRPTYPE='1' ORDER BY grpid
    )
    LOOP
        IF LENGTH(V_STRGRPNAME) > 0 THEN
            V_STRGRPNAME := V_STRGRPNAME || ', ' || REC.grpid || ': ' || REC.grpname;
        ELSE
            V_STRGRPNAME := REC.grpid || ': ' || REC.grpname;
        END IF;
    END LOOP;

    return V_STRGRPNAME;
exception when others then
return '';
end;
 
 
 
 
/
