SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SET_DOM_HOLIDAY"
   ( pv_strDay IN VARCHAR2,
     pv_strMonth IN VARCHAR2,
     pv_strYear IN VARCHAR2,
     pv_isHoliday IN VARCHAR2,
     pv_strCLDRTYPE IN VARCHAR2
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
   pv_strSBBOW VARCHAR2(1);
   pv_strSBBOM VARCHAR2(1);
   pv_strSBBOQ VARCHAR2(1);
   pv_strSBBOY VARCHAR2(1);
   pv_strSBEOW VARCHAR2(1);
   pv_strSBEOM VARCHAR2(1);
   pv_strSBEOQ VARCHAR2(1);
   pv_strSBEOY VARCHAR2(1);

   pv_iTmp INT;

   CURSOR curDate IS
            SELECT TO_CHAR(SBDATE,'DD/MM/YYYY') FROM SBCLDR
            WHERE TO_CHAR(SBDATE,'D') = pv_strDay AND
            TO_CHAR(SBDATE,'MM') = LPAD(pv_strMonth,2,'0')
            AND TO_CHAR(SBDATE,'YYYY') = pv_strYear
            AND CLDRTYPE = pv_strCLDRTYPE;
   pv_strDate VARCHAR2(10);
BEGIN
    OPEN curDate;
    LOOP
        FETCH curDate INTO pv_strDate;
        EXIT WHEN curDate%NOTFOUND;

        pv_strSBBOW := 'N';
        pv_strSBBOM := 'N';
        pv_strSBBOQ := 'N';
        pv_strSBBOY := 'N';
        pv_strSBEOW := 'N';
        pv_strSBEOM := 'N';
        pv_strSBEOQ := 'N';
        pv_strSBEOY := 'N';
        select count(*) into pv_iTmp from SBCLDR where SBDATE = to_date(pv_strDate,'dd/mm/yyyy') and CLDRTYPE = pv_strCLDRTYPE;

        if pv_iTmp > 0 then

            select SBBOW , SBBOM , SBBOQ , SBBOY , SBEOW , SBEOM , SBEOQ , SBEOY
            into pv_strSBBOW, pv_strSBBOM, pv_strSBBOQ, pv_strSBBOY, pv_strSBEOW, pv_strSBEOM, pv_strSBEOQ, pv_strSBEOY
            from SBCLDR where SBDATE = to_date(pv_strDate,'dd/mm/yyyy') and CLDRTYPE = pv_strCLDRTYPE;

        end if;

        IF pv_isHoliday = 'Y' THEN
            UPDATE SBCLDR
            SET HOLIDAY = 'Y', SBBOW = 'N', SBBOM = 'N', SBBOQ = 'N', SBBOY = 'N',
                SBEOW = 'N', SBEOM = 'N', SBEOQ = 'N', SBEOY = 'N'
            WHERE SBDATE = to_date(pv_strDate, 'dd/mm/yyyy') AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBBOW = pv_strSBBOW
            WHERE SBDATE in (select min(SBDATE) from sbcldr
                            where sbdate > to_date(pv_strDate,'dd/mm/yyyy')
                            and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d'))
                            and SBDATE - to_date(pv_strDate,'dd/mm/yyyy') < 7
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and holiday = 'N')
            AND CLDRTYPE = pv_strCLDRTYPE;


            UPDATE SBCLDR SET SBBOM = pv_strSBBOM, SBBOQ = pv_strSBBOQ
            WHERE SBDATE in (select min(SBDATE) from sbcldr
                            where sbdate > to_date(pv_strDate,'dd/mm/yyyy')
                            and to_char(sbdate,'mm') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'mm')
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and holiday = 'N')
            AND CLDRTYPE = pv_strCLDRTYPE;


            UPDATE SBCLDR SET SBBOY = pv_strSBBOY
            WHERE SBDATE in (select min(SBDATE) from sbcldr
                            where sbdate > to_date(pv_strDate,'dd/mm/yyyy')
                            and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy')
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and holiday = 'N')
            AND CLDRTYPE = pv_strCLDRTYPE
            and holiday = 'N';


            UPDATE SBCLDR SET SBEOW = pv_strSBEOW
            WHERE SBDATE in (select max(SBDATE) from sbcldr
                            where sbdate < to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d'))
                            and to_date(pv_strDate,'dd/mm/yyyy') - sbdate < 7
                            AND CLDRTYPE = pv_strCLDRTYPE)
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBEOM = pv_strSBEOM, SBEOQ = pv_strSBEOQ
            WHERE SBDATE in (select max(SBDATE) from sbcldr
                            where sbdate < to_date(pv_strDate,'dd/mm/yyyy')
                            and to_char(sbdate,'mm') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'mm')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE)
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBEOY = pv_strSBEOY
            WHERE SBDATE in (select max(SBDATE) from sbcldr
                            where sbdate < to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy')
                            AND CLDRTYPE = pv_strCLDRTYPE)
            AND CLDRTYPE = pv_strCLDRTYPE;


        ELSE
            select count(*) into pv_iTmp
            from sbcldr
            WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                            WHERE SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d'))
                            and SBDATE - to_date(pv_strDate,'dd/mm/yyyy') < 7
                            AND CLDRTYPE = pv_strCLDRTYPE)
            AND CLDRTYPE = pv_strCLDRTYPE;

            if pv_iTmp > 0 then
                SELECT SBBOW INTO pv_strSBBOW
                FROM SBCLDR
                WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                                WHERE SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                                and holiday = 'N'
                                and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d'))
                                and SBDATE - to_date(pv_strDate,'dd/mm/yyyy') < 7
                                AND CLDRTYPE = pv_strCLDRTYPE)
                AND CLDRTYPE = pv_strCLDRTYPE;
            else
                SELECT COUNT(*) INTO pv_iTmp
                FROM SBCLDR
                WHERE to_date(pv_strDate,'dd/mm/yyyy') - SBDATE < 7
                AND SBDATE < to_date(pv_strDate,'dd/mm/yyyy')
                AND holiday = 'N'
                AND to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d'))
                AND CLDRTYPE = pv_strCLDRTYPE;

                if pv_iTmp <= 0 then
                    pv_strSBBOW := 'Y';
                end if;
            end if;



            select count(*) into pv_iTmp
            from sbcldr
            WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                            WHERE SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_char(SBDATE,'mm') = to_char(to_date(pv_strDate, 'dd/mm/yyyy'), 'mm'))
            AND CLDRTYPE = pv_strCLDRTYPE;

            if pv_iTmp > 0 then

                SELECT SBBOM, SBBOQ
                INTO pv_strSBBOM, pv_strSBBOQ
                FROM SBCLDR
                WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                                WHERE SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                                and holiday = 'N'
                                AND CLDRTYPE = pv_strCLDRTYPE
                                and to_char(SBDATE,'mm') = to_char(to_date(pv_strDate, 'dd/mm/yyyy'), 'mm'))
                AND CLDRTYPE = pv_strCLDRTYPE;
            end if;


            select count(*) into pv_iTmp
            from sbcldr
            WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                            WHERE SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy'))
            AND CLDRTYPE = pv_strCLDRTYPE;

            if pv_iTmp > 0 then

                SELECT SBBOY INTO pv_strSBBOY
                FROM SBCLDR
                WHERE SBDATE in (SELECT min(SBDATE) FROM SBCLDR
                                WHERE SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                                and holiday = 'N'
                                AND CLDRTYPE = pv_strCLDRTYPE
                                and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy'))
                AND CLDRTYPE = pv_strCLDRTYPE;
            end if;


            select count(*) into pv_iTmp
            from sbcldr
            WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                            WHERE SBDATE < to_date(pv_strDate,'dd/mm/yyyy') and holiday = 'N' AND CLDRTYPE = pv_strCLDRTYPE
                            and to_date(pv_strDate,'dd/mm/yyyy') - sbdate < 7
                            and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d')))
            AND CLDRTYPE = pv_strCLDRTYPE;

            if pv_iTmp > 0 then

                SELECT SBEOW INTO pv_strSBEOW
                FROM SBCLDR
                WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                                WHERE SBDATE < to_date(pv_strDate,'dd/mm/yyyy') and holiday = 'N' AND CLDRTYPE = pv_strCLDRTYPE
                                and to_date(pv_strDate,'dd/mm/yyyy') - sbdate < 7
                                and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d')))
                AND CLDRTYPE = pv_strCLDRTYPE;
            else
                SELECT COUNT(*) INTO pv_iTmp
                FROM SBCLDR
                WHERE SBDATE - to_date(pv_strDate,'dd/mm/yyyy') < 7
                AND SBDATE > to_date(pv_strDate,'dd/mm/yyyy')
                AND holiday = 'N'
                AND to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d'))
                AND CLDRTYPE = pv_strCLDRTYPE;

                if pv_iTmp <= 0 then
                    pv_strSBEOW := 'Y';
                end if;

            end if;



            select count(*) into pv_iTmp
            from sbcldr
            WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                            WHERE SBDATE < to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_char(SBDATE,'mm') = to_char(to_date(pv_strDate, 'dd/mm/yyyy'), 'mm'))
            AND CLDRTYPE = pv_strCLDRTYPE;

            if pv_iTmp > 0 then

                SELECT SBEOM, SBEOQ
                INTO pv_strSBEOM, pv_strSBEOQ
                FROM SBCLDR
                WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                                WHERE SBDATE < to_date(pv_strDate,'dd/mm/yyyy')
                                and holiday = 'N'
                                AND CLDRTYPE = pv_strCLDRTYPE
                                and to_char(SBDATE,'mm') = to_char(to_date(pv_strDate, 'dd/mm/yyyy'), 'mm'))
                AND CLDRTYPE = pv_strCLDRTYPE;
            end if;


            select count(*) into pv_iTmp
            from sbcldr
            WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                            WHERE SBDATE < to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy'))
            AND CLDRTYPE = pv_strCLDRTYPE;

            if pv_iTmp > 0 then

                SELECT SBEOY INTO pv_strSBEOY
                FROM SBCLDR
                WHERE SBDATE in (SELECT max(SBDATE) FROM SBCLDR
                                WHERE SBDATE < to_date(pv_strDate,'dd/mm/yyyy')
                                and holiday = 'N'
                                AND CLDRTYPE = pv_strCLDRTYPE
                                and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy'))
                AND CLDRTYPE = pv_strCLDRTYPE;
            end if;


            UPDATE SBCLDR
            SET HOLIDAY = 'N', SBBOW = pv_strSBBOW, SBBOM = pv_strSBBOM, SBBOQ = pv_strSBBOQ, SBBOY = pv_strSBBOY,
                SBEOW = pv_strSBEOW, SBEOM = pv_strSBEOM, SBEOQ = pv_strSBEOQ, SBEOY = pv_strSBEOY
            WHERE SBDATE = to_date(pv_strDate, 'dd/mm/yyyy') AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBBOW = 'N'
            WHERE SBDATE in (select min(SBDATE) from sbcldr
                            where sbdate > to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_number(to_char(SBDATE,'d')) > to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d')))
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBBOM = 'N', SBBOQ = 'N'
            WHERE SBDATE in (select min(SBDATE) from sbcldr
                            where sbdate > to_date(pv_strDate,'dd/mm/yyyy')
                            and to_char(sbdate,'mm') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'mm')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE)
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBBOY = 'N'
            WHERE SBDATE in (select min(SBDATE) from sbcldr
                            where sbdate > to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy'))
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBEOW = 'N'
            WHERE SBDATE in (select max(SBDATE) from sbcldr
                            where sbdate < to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_number(to_char(SBDATE,'d')) < to_number(to_char(to_date(pv_strDate,'dd/mm/yyyy'),'d')))
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBEOM = 'N', SBEOQ = 'N'
            WHERE SBDATE in (select max(SBDATE) from sbcldr
                            where sbdate < to_date(pv_strDate,'dd/mm/yyyy')
                            and to_char(sbdate,'mm') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'mm')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE)
            AND CLDRTYPE = pv_strCLDRTYPE;

            UPDATE SBCLDR SET SBEOY = 'N'
            WHERE SBDATE in (select max(SBDATE) from sbcldr
                            where sbdate < to_date(pv_strDate,'dd/mm/yyyy')
                            and holiday = 'N'
                            AND CLDRTYPE = pv_strCLDRTYPE
                            and to_char(sbdate,'yyyy') = to_char(to_date(pv_strDate,'dd/mm/yyyy'), 'yyyy'))
            AND CLDRTYPE = pv_strCLDRTYPE;



        END IF;
    END LOOP;
    CLOSE curDate;
    --commit;
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            rollback;
            raise;
            return;
        END;
END; -- Procedure

 
 
 
 
/
