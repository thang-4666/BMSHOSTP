SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_username(P_STRTLID VARCHAR2)
return VARCHAR2
is
    V_STRTLNAME   VARCHAR2(2000);
BEGIN
    -- HAM THUC HIEN LAY CHUOI TEN NSD
    -- DUNG CHO BAO CAO SA0007
    FOR REC IN
    (
        SELECT * FROM TLPROFILES WHERE instr(P_STRTLID,TLID) >0 ORDER BY TLID
    )
    LOOP
        IF LENGTH(V_STRTLNAME) > 0 THEN
            V_STRTLNAME := V_STRTLNAME || ', ' || REC.TLID || ': ' || REC.TLNAME;
        ELSE
            V_STRTLNAME := REC.TLID || ': ' || REC.TLNAME;
        END IF;
    END LOOP;

    return V_STRTLNAME;
exception when others then
return '';
end;

 
 
 
 
/
