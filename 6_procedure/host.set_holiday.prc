SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SET_HOLIDAY"
   ( p_Day IN VARCHAR2,
     p_IsHoliday IN VARCHAR2,
     p_CLDRType IN VARCHAR2
   )
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
BEGIN


    -- Set holiday
    UPDATE SBCLDR
    SET HOLIDAY = p_isHoliday
    WHERE SBDATE = to_date(p_Day, 'DD/MM/RRRR') AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);

    -- Set ngay dau tuan.
    -- xoa
    UPDATE SBCLDR SET SBBOW = 'N'
    WHERE to_char(sbdate,'WW') = to_char(to_date(p_Day,'DD/MM/RRRR'),'WW')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and SBBOW <> 'N';
    -- cap nhat lai
    UPDATE SBCLDR SET SBBOW = 'Y'
    WHERE SBDATE in (select min(SBDATE) from sbcldr
                    where to_char(sbdate,'WW') = to_char(to_date(p_Day,'DD/MM/RRRR'),'WW')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and holiday = 'N')
    AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);

    -- Set ngay dau thang.
    -- xoa
    UPDATE SBCLDR SET SBBOM = 'N'
    WHERE to_char(sbdate,'MM') = to_char(to_date(p_Day,'DD/MM/RRRR'),'MM')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and SBBOM <> 'N';
    -- cap nhat lai
    UPDATE SBCLDR SET SBBOM = 'Y'
    WHERE SBDATE in (select min(SBDATE) from sbcldr
                    where to_char(sbdate,'MM') = to_char(to_date(p_Day,'DD/MM/RRRR'),'MM')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and holiday = 'N')
    AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);

    -- Set ngay dau nam.
    -- xoa
    UPDATE SBCLDR SET SBBOY = 'N'
    WHERE to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and SBBOY <> 'N';
    -- cap nhat lai
    UPDATE SBCLDR SET SBBOY = 'Y'
    WHERE SBDATE in (select min(SBDATE) from sbcldr
                    where to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and holiday = 'N')
    AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);

    -- Set ngay cuoi tuan.
    -- xoa
    UPDATE SBCLDR SET SBEOW = 'N'
    WHERE to_char(sbdate,'WW') = to_char(to_date(p_Day,'DD/MM/RRRR'),'WW')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and SBEOW <> 'N';
    -- cap nhat lai
    UPDATE SBCLDR SET SBEOW = 'Y'
    WHERE SBDATE in (select max(SBDATE) from sbcldr
                    where to_char(sbdate,'WW') = to_char(to_date(p_Day,'DD/MM/RRRR'),'WW')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and holiday = 'N')
    AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);

    -- Set ngay cuoi thang.
    -- xoa
    UPDATE SBCLDR SET SBEOM = 'N'
    WHERE to_char(sbdate,'MM') = to_char(to_date(p_Day,'DD/MM/RRRR'),'MM')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and SBEOM <> 'N';
    -- cap nhat lai
    UPDATE SBCLDR SET SBEOM = 'Y'
    WHERE SBDATE in (select max(SBDATE) from sbcldr
                    where to_char(sbdate,'MM') = to_char(to_date(p_Day,'DD/MM/RRRR'),'MM')
                    and to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and holiday = 'N')
    AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);

    -- Set ngay cuoi nam.
    -- xoa
    UPDATE SBCLDR SET SBEOY = 'N'
    WHERE to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and SBEOY <> 'N';
    -- cap nhat lai
    UPDATE SBCLDR SET SBEOY = 'Y'
    WHERE SBDATE in (select max(SBDATE) from sbcldr
                    where to_char(sbdate,'RRRR') = to_char(to_date(p_Day,'DD/MM/RRRR'),'RRRR')
                    and CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE)
                    and holiday = 'N')
    AND CLDRTYPE = decode(p_CLDRTYPE,'999',CLDRTYPE,p_CLDRTYPE);


/*PROCEDURE SET_HOLIDAY
   ( p_Day IN VARCHAR2,
     p_isHoliday IN VARCHAR2,
     p_CLDRTYPE IN VARCHAR2
   )
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the procedure
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
   l_SBBOW VARCHAR2(1);
   l_SBBOM VARCHAR2(1);
   l_SBBOQ VARCHAR2(1);
   l_SBBOY VARCHAR2(1);
   l_SBEOW VARCHAR2(1);
   l_SBEOM VARCHAR2(1);
   l_SBEOQ VARCHAR2(1);
   l_SBEOY VARCHAR2(1);

   l_tempNum INT;


BEGIN
    l_SBBOW := 'N';
    l_SBBOM := 'N';
    l_SBBOQ := 'N';
    l_SBBOY := 'N';
    l_SBEOW := 'N';
    l_SBEOM := 'N';
    l_SBEOQ := 'N';
    l_SBEOY := 'N';
    select count(*) into l_tempNum from SBCLDR where SBDATE = to_date(p_Day,'dd/mm/yyyy') and CLDRTYPE = p_CLDRTYPE;

    if l_tempNum > 0 then

        select SBBOW , SBBOM , SBBOQ , SBBOY , SBEOW , SBEOM , SBEOQ , SBEOY
        into l_SBBOW, l_SBBOM, l_SBBOQ, l_SBBOY, l_SBEOW, l_SBEOM, l_SBEOQ, l_SBEOY
        from SBCLDR where SBDATE = to_date(p_Day,'dd/mm/yyyy') and CLDRTYPE = p_CLDRTYPE;

    end if;

    IF p_isHoliday = 'Y' THEN
        UPDATE SBCLDR
        SET HOLIDAY = 'Y', SBBOW = 'N', SBBOM = 'N', SBBOQ = 'N', SBBOY = 'N',
            SBEOW = 'N', SBEOM = 'N', SBEOQ = 'N', SBEOY = 'N'
        WHERE SBDATE = to_date(p_Day, 'dd/mm/yyyy') AND CLDRTYPE = p_CLDRTYPE;

        IF p_CLDRTYPE = '000' THEN
            UPDATE SBCLDR
            SET HOLIDAY = 'Y'
            WHERE SBDATE = to_date(p_Day, 'dd/mm/yyyy');
        END IF;

        UPDATE SBCLDR SET SBBOW = l_SBBOW
        WHERE SBDATE in (select min(SBDATE) from sbcldr
                        where sbdate > to_date(p_Day,'dd/mm/yyyy')
                        and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d'))
                        and SBDATE - to_date(p_Day,'dd/mm/yyyy') < 7
                        AND CLDRTYPE = p_CLDRTYPE
                        and holiday = 'N')
        AND CLDRTYPE = p_CLDRTYPE;


        UPDATE SBCLDR SET SBBOM = l_SBBOM, SBBOQ = l_SBBOQ
        WHERE SBDATE in (select min(SBDATE) from sbcldr
                        where sbdate > to_date(p_Day,'dd/mm/yyyy')
                        and to_char(sbdate,'mm') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'mm')
                        AND CLDRTYPE = p_CLDRTYPE
                        and holiday = 'N')
        AND CLDRTYPE = p_CLDRTYPE;


        UPDATE SBCLDR SET SBBOY = l_SBBOY
        WHERE SBDATE in (select min(SBDATE) from sbcldr
                        where sbdate > to_date(p_Day,'dd/mm/yyyy')
                        and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy')
                        AND CLDRTYPE = p_CLDRTYPE
                        and holiday = 'N')
        AND CLDRTYPE = p_CLDRTYPE
        and holiday = 'N';


        UPDATE SBCLDR SET SBEOW = l_SBEOW
        WHERE SBDATE in (select max(SBDATE) from sbcldr
                        where sbdate < to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d'))
                        and to_date(p_Day,'dd/mm/yyyy') - sbdate < 7
                        AND CLDRTYPE = p_CLDRTYPE)
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBEOM = l_SBEOM, SBEOQ = l_SBEOQ
        WHERE SBDATE in (select max(SBDATE) from sbcldr
                        where sbdate < to_date(p_Day,'dd/mm/yyyy')
                        and to_char(sbdate,'mm') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'mm')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE)
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBEOY = l_SBEOY
        WHERE SBDATE in (select max(SBDATE) from sbcldr
                        where sbdate < to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy')
                        AND CLDRTYPE = p_CLDRTYPE)
        AND CLDRTYPE = p_CLDRTYPE;


    ELSE
        select count(*) into l_tempNum
        from sbcldr
        WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                        WHERE SBDATE > to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d'))
                        and SBDATE - to_date(p_Day,'dd/mm/yyyy') < 7
                        AND CLDRTYPE = p_CLDRTYPE)
        AND CLDRTYPE = p_CLDRTYPE;

        if l_tempNum > 0 then
            SELECT SBBOW INTO l_SBBOW
            FROM SBCLDR
            WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                            WHERE SBDATE > to_date(p_Day,'dd/mm/yyyy')
                            and holiday = 'N'
                            and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d'))
                            and SBDATE - to_date(p_Day,'dd/mm/yyyy') < 7
                            AND CLDRTYPE = p_CLDRTYPE)
            AND CLDRTYPE = p_CLDRTYPE;
        else
            SELECT COUNT(*) INTO l_tempNum
            FROM SBCLDR
            WHERE to_date(p_Day,'dd/mm/yyyy') - SBDATE < 7
            AND SBDATE < to_date(p_Day,'dd/mm/yyyy')
            AND holiday = 'N'
            AND to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d'))
            AND CLDRTYPE = p_CLDRTYPE;

            if l_tempNum <= 0 then
                l_SBBOW := 'Y';
            end if;
        end if;

        dbms_output.put_line(concat('BOW',l_SBBOW));

        select count(*) into l_tempNum
        from sbcldr
        WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                        WHERE SBDATE > to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_char(SBDATE,'mm') = to_char(to_date(p_Day, 'dd/mm/yyyy'), 'mm'))
        AND CLDRTYPE = p_CLDRTYPE;

        if l_tempNum > 0 then

            SELECT SBBOM, SBBOQ
            INTO l_SBBOM, l_SBBOQ
            FROM SBCLDR
            WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                            WHERE SBDATE > to_date(p_Day,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = p_CLDRTYPE
                            and to_char(SBDATE,'mm') = to_char(to_date(p_Day, 'dd/mm/yyyy'), 'mm'))
            AND CLDRTYPE = p_CLDRTYPE;
        end if;
        dbms_output.put_line(concat('BOM',l_SBBOM));
        dbms_output.put_line(concat('BOQ',l_SBBOQ));

        select count(*) into l_tempNum
        from sbcldr
        WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                        WHERE SBDATE > to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy'))
        AND CLDRTYPE = p_CLDRTYPE;

        if l_tempNum > 0 then

            SELECT SBBOY INTO l_SBBOY
            FROM SBCLDR
            WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                            WHERE SBDATE > to_date(p_Day,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = p_CLDRTYPE
                            and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy'))
            AND CLDRTYPE = p_CLDRTYPE;
        end if;
        dbms_output.put_line(concat('BOY',l_SBBOY));

        select count(*) into l_tempNum
        from sbcldr
        WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                        WHERE SBDATE < to_date(p_Day,'dd/mm/yyyy') and holiday = 'N' AND CLDRTYPE = p_CLDRTYPE
                        and to_date(p_Day,'dd/mm/yyyy') - sbdate < 7
                        and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d')))
        AND CLDRTYPE = p_CLDRTYPE;

        if l_tempNum > 0 then

            SELECT SBEOW INTO l_SBEOW
            FROM SBCLDR
            WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                            WHERE SBDATE < to_date(p_Day,'dd/mm/yyyy') and holiday = 'N' AND CLDRTYPE = p_CLDRTYPE
                            and to_date(p_Day,'dd/mm/yyyy') - sbdate < 7
                            and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d')))
            AND CLDRTYPE = p_CLDRTYPE;
        else
            SELECT COUNT(*) INTO l_tempNum
            FROM SBCLDR
            WHERE SBDATE - to_date(p_Day,'dd/mm/yyyy') < 7
            AND SBDATE > to_date(p_Day,'dd/mm/yyyy')
            AND holiday = 'N'
            AND to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d'))
            AND CLDRTYPE = p_CLDRTYPE;

            if l_tempNum <= 0 then
                l_SBEOW := 'Y';
            end if;

        end if;
        dbms_output.put_line(concat('EOW',l_SBEOW));


        select count(*) into l_tempNum
        from sbcldr
        WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                        WHERE SBDATE < to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_char(SBDATE,'mm') = to_char(to_date(p_Day, 'dd/mm/yyyy'), 'mm'))
        AND CLDRTYPE = p_CLDRTYPE;

        if l_tempNum > 0 then

            SELECT SBEOM, SBEOQ
            INTO l_SBEOM, l_SBEOQ
            FROM SBCLDR
            WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                            WHERE SBDATE < to_date(p_Day,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = p_CLDRTYPE
                            and to_char(SBDATE,'mm') = to_char(to_date(p_Day, 'dd/mm/yyyy'), 'mm'))
            AND CLDRTYPE = p_CLDRTYPE;
        end if;
        dbms_output.put_line(concat('EOM',l_SBEOM));
        dbms_output.put_line(concat('EOQ',l_SBEOQ));

        select count(*) into l_tempNum
        from sbcldr
        WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                        WHERE SBDATE < to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy'))
        AND CLDRTYPE = p_CLDRTYPE;

        if l_tempNum > 0 then

            SELECT SBEOY INTO l_SBEOY
            FROM SBCLDR
            WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                            WHERE SBDATE < to_date(p_Day,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = p_CLDRTYPE
                            and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy'))
            AND CLDRTYPE = p_CLDRTYPE;
        end if;

        dbms_output.put_line(concat('EOY',l_SBEOY));

        UPDATE SBCLDR
        SET HOLIDAY = 'N', SBBOW = l_SBBOW, SBBOM = l_SBBOM, SBBOQ = l_SBBOQ, SBBOY = l_SBBOY,
            SBEOW = l_SBEOW, SBEOM = l_SBEOM, SBEOQ = l_SBEOQ, SBEOY = l_SBEOY
        WHERE SBDATE = to_date(p_Day, 'dd/mm/yyyy') AND CLDRTYPE = p_CLDRTYPE;

        IF p_CLDRTYPE = '000' THEN
            UPDATE SBCLDR
            SET HOLIDAY = 'N'
            WHERE SBDATE = to_date(p_Day, 'dd/mm/yyyy');
        END IF;

        UPDATE SBCLDR SET SBBOW = 'N'
        WHERE SBDATE in (select min(SBDATE) from sbcldr
                        where sbdate > to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d')))
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBBOM = 'N', SBBOQ = 'N'
        WHERE SBDATE in (select min(SBDATE) from sbcldr
                        where sbdate > to_date(p_Day,'dd/mm/yyyy')
                        and to_char(sbdate,'mm') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'mm')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE)
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBBOY = 'N'
        WHERE SBDATE in (select min(SBDATE) from sbcldr
                        where sbdate > to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy'))
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBEOW = 'N'
        WHERE SBDATE in (select max(SBDATE) from sbcldr
                        where sbdate < to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(p_Day,'dd/mm/yyyy'),'d')))
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBEOM = 'N', SBEOQ = 'N'
        WHERE SBDATE in (select max(SBDATE) from sbcldr
                        where sbdate < to_date(p_Day,'dd/mm/yyyy')
                        and to_char(sbdate,'mm') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'mm')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE)
        AND CLDRTYPE = p_CLDRTYPE;

        UPDATE SBCLDR SET SBEOY = 'N'
        WHERE SBDATE in (select max(SBDATE) from sbcldr
                        where sbdate < to_date(p_Day,'dd/mm/yyyy')
                        and holiday = 'N'
                        AND CLDRTYPE = p_CLDRTYPE
                        and to_char(sbdate,'yyyy') = to_char(to_date(p_Day,'dd/mm/yyyy'), 'yyyy'))
        AND CLDRTYPE = p_CLDRTYPE;



    END IF;

   -- commit;

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            rollback;
            raise;
            return;
        END;
END; -- Procedure




 */

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            rollback;
            raise;
            return;
        END;
END; -- Procedure

 
 
 
 
/
