SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getpravllimit(p_CODEID_TO IN VARCHAR2)
RETURN NUMBER
IS

    l_pravllimit NUMBER(20,0);

BEGIN
    if p_CODEID_TO is null or length(trim(p_CODEID_TO))  = 0 then
        return 0;
    end if;
    SELECT nvl(pravllimit,0) pravllimit
        INTO l_pravllimit
    From
        (select codeid, min(pravllimit) pravllimit
            from
                (select pr.codeid,
                            max(pr.roomlimit) - sum(nvl(afpr.prinused,0)) pravllimit
                                from (select * from vw_afpralloc_all where restype = 'M') afpr, vw_marginroomsystem pr
                                where afpr.codeid(+) = pr.codeid
                                group by pr.codeid)
            group by codeid
            ) pr
    WHERE PR.codeid = p_CODEID_TO;


    RETURN l_pravllimit;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 1000000000;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
