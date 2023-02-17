SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE get_Info_TD0025(PV_REFCURSOR       IN OUT   PKG_REPORT.REF_CURSOR)
IS

BEGIN
    OPEN PV_REFCURSOR
    FOR
    select tltxcd value, tltxcd VALUEcd, txdesc display, en_txdesc en_display, txdesc description from 
        (SELECT tltxcd, txdesc, en_txdesc, 1 lstodr from tltx WHERE tltxcd IN 
            (SELECT distinct tl.tltxcd  FROM tltx tl WHERE tl.tltxcd IN ('1600','1610','1620','1630','1670') ) 
         UNION ALL SELECT 'ALL' tltxcd,'ALL' txdesc , 'ALL' en_txdesc, -1 LSTODR FROM DUAL ORDER BY tltxcd) ORDER BY LSTODR;
 EXCEPTION WHEN OTHERS THEN
    RETURN;
END get_Info_TD0025;
 
 
 
 
/
