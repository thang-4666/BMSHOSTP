SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "ADD_YEAR1"
   ( pv_strNewYear IN VARCHAR2, pv_strHoliday IN VARCHAR2)
IS
/* pv_strNewYear: nam can them (vi du: '2010'
      pv_strHoliday: danh sach cac ngay nghi trong tuan, phan cach bang dau # (vi du: '#1#7#')
    */

-- Purpose: Add a new year
--
-- MODIFICATION HISTORY
-- Person      Date        Comments
-- VanNT     05/06/2008
-- ---------   ------  -------------------------------------------
   FIRST_DAY_MONTH CONSTANT VARCHAR2(11) := '01-Jan-';
   MONTH_COUNT CONSTANT INT := 12;
   v_dCurDate Date;
   v_dCurMonth Int;
   v_strSBBUSDAY VARCHAR2(1);
   v_strSBEOW VARCHAR2(1);
   v_strSBEOM VARCHAR2(1);
   v_strSBEOQ VARCHAR2(1);
   v_strSBEOY VARCHAR2(1);
   v_strSBBOW VARCHAR2(1);
   v_strSBBOM VARCHAR2(1);
   v_strSBBOQ VARCHAR2(1);
   v_strSBBOY VARCHAR2(1);
   v_strHOLIDAY VARCHAR2(1);

   v_strFirstDayOfWeek VARCHAR2(1);
   v_strLastDayOfWeek VARCHAR2(1);
   v_iTmp Int;
   v_bCheck Boolean;
   v_bTmp Boolean;
   v_bCheckFirstDayOfWeek Boolean;

   v_strYearHoliday  VARCHAR2(100);

   CURSOR curCLDRTYPE IS
         SELECT CDVAL FROM ALLCODE WHERE CDTYPE = 'SA' AND CDNAME = 'TRADEPLACE' AND CDVAL <> 'ALL';
   v_strCLDRTYPE VARCHAR2(3);
   -- Declare program variables as shown above
BEGIN
    Set transaction read write;

    SELECT COUNT(*) INTO v_iTmp FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'HOLIDAY';

    if v_iTmp > 0 then
        SELECT VARVALUE INTO v_strYearHoliday FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'HOLIDAY';
    else
        v_strYearHoliday := '';
    end if;


    -- Xac dinh ngay dau tuan
    v_iTmp := 1;
    v_bCheck := false;
    WHILE v_bCheck = false
    LOOP
        IF INSTR(pv_strHoliday, to_char(v_iTmp)) > 0 THEN
            v_iTmp := v_iTmp + 1;
        ELSE
            v_bCheck := true;
            v_strFirstDayOfWeek := to_char(v_iTmp);
        END IF;
    END LOOP;

    -- Xac dinh ngay cuoi tuan
    v_iTmp := 7;
    v_bCheck := false;
    WHILE v_bCheck = false
    LOOP
        IF INSTR(pv_strHoliday, to_char(v_iTmp)) > 0 THEN
            v_iTmp := v_iTmp - 1;
        ELSE
            v_bCheck := true;
            v_strLastDayOfWeek := to_char(v_iTmp);
        END IF;
    END LOOP;

    OPEN curCLDRTYPE;
    LOOP
        FETCH curCLDRTYPE INTO v_strCLDRTYPE;
        EXIT WHEN curCLDRTYPE%NOTFOUND;

        -- Khoi tao ngay dau cua nam 01/01
        v_dCurDate := to_date(concat(FIRST_DAY_MONTH,pv_strNewYear),'dd/mm/yyyy');

        SELECT COUNT(*) INTO v_iTmp FROM SBCLDR
        WHERE to_number(to_char(SBDATE,'d')) < to_number(to_char(v_dCurDate,'d'))
        AND SBDATE < v_dCurDate
        AND v_dCurDate - SBDATE <= 6 AND HOLIDAY = 'N' AND CLDRTYPE = v_strCLDRTYPE;

        dbms_output.put_line(v_iTmp);

        IF v_iTmp > 0 THEN
            v_bCheckFirstDayOfWeek := true;
        ELSE
            v_bCheckFirstDayOfWeek := false;
        END IF;

        FOR v_dCurMonth IN 1..MONTH_COUNT
        LOOP
            -- Da xac dinh duoc ngay dau thang
            v_bCheck := false;
            WHILE to_char(v_dCurDate, 'mm') = replace(to_char(v_dCurMonth,'09'),' ','')
            LOOP
                SELECT COUNT(*) INTO v_iTmp FROM SBCLDR
                WHERE CLDRTYPE = v_strCLDRTYPE
                AND SBDATE = v_dCurDate;

                IF v_iTmp <= 0 THEN
                    v_strSBBUSDAY := 'N';
                    v_strSBBOW := 'N';
                    v_strSBBOM := 'N';
                    v_strSBBOQ := 'N';
                    v_strSBBOY := 'N';
                    v_strSBEOW := 'N';
                    v_strSBEOM := 'N';
                    v_strSBEOQ := 'N';
                    v_strSBEOY := 'N';
                    v_strHOLIDAY := 'N';

                    -- Co phai ngay nghi khong
                    IF INSTR(v_strYearHoliday, CONCAT(CONCAT('#',to_char(v_dCurDate, 'dd/mm')),'#')) > 0 THEN
                        v_strHOLIDAY := 'Y';
                    END IF;

                    -- Co phai la ngay dau tuan hay cuoi tuan khong
                    IF to_char(v_dCurDate,'d') = v_strFirstDayOfWeek THEN
                        IF v_strHOLIDAY = 'N' THEN
                            v_strSBBOW := 'Y';
                            v_bCheckFirstDayOfWeek := true;
                        END IF;
                    ELSIF to_char(v_dCurDate, 'd') = v_strLastDayOfWeek THEN
                        v_bCheckFirstDayOfWeek := false;
                        IF v_strHOLIDAY = 'N' THEN
                            v_strSBEOW := 'Y';
                        ELSE
                            UPDATE SBCLDR SET SBEOW = 'Y'
                            WHERE HOLIDAY = 'N'
                            AND (v_dCurDate - SBDATE) = (SELECT min(v_dCurDate - SBDATE) FROM SBCLDR
                                                        WHERE to_number(to_char(SBDATE,'d')) < to_number(v_strLastDayOfWeek))
                            AND CLDRTYPE = v_strCLDRTYPE;
                        END IF;
                    -- Neu khong thi co phai ngay nghi khong
                    ELSIF INSTR(pv_strHoliday, to_char(v_dCurDate,'d')) > 0 THEN
                        v_strHOLIDAY := 'Y';
                    ELSIF v_bCheckFirstDayOfWeek = false THEN
                        v_strSBBOW := 'Y';
                    END IF;



                    -- Ngay dau thang
                    IF v_bCheck = false THEN
                        IF v_strHOLIDAY = 'N' THEN
                            v_strSBBOM := 'Y';
                            v_bCheck := true;
                        END IF;
                    END IF;

                    -- Ngay cuoi thang
                    IF v_strHOLIDAY = 'N' THEN
                        IF v_dCurDate = LAST_DAY(v_dCurDate) THEN
                            v_strSBEOM := 'Y';
                        ELSE
                            --IF to_char(v_dCurDate + 1, 'dd') = '1' THEN
                            IF v_dCurDate + 1 = LAST_DAY(v_dCurDate) + 1 THEN
                                v_strSBEOM := 'Y';
                            ELSE
                                v_bTmp := false;
                                v_iTmp := 1;
                                WHILE v_bTmp = false
                                LOOP
                                    IF INSTR(pv_strHoliday, to_char(v_dCurDate + v_iTmp, 'd')) > 0 THEN
                                        v_iTmp := v_iTmp + 1;
                                    ELSIF to_number(to_char(v_dCurDate + v_iTmp,'dd')) < to_number(to_char(v_dCurDate,'dd')) THEN
                                        v_bTmp := true;
                                        v_strSBEOM := 'Y';
                                    ELSIF INSTR(v_strYearHoliday, to_char(v_dCurDate + v_iTmp,'dd/mm')) > 0 THEN
                                        v_iTmp := v_iTmp + 1;
                                    ELSE
                                        v_bTmp := true;
                                    END IF;
                                END LOOP;
                            END IF;
                        END IF;
                    END IF;


                    -- Ngay dau quy, dau nam
                    IF v_strSBBOM = 'Y' THEN
                        IF v_dCurMonth = 4 or v_dCurMonth = 7 or v_dCurMonth = 10 THEN
                            v_strSBBOQ := 'Y';
                        ELSIF v_dCurMonth = 1 THEN
                            v_strSBBOQ := 'Y';
                            v_strSBBOY := 'Y';
                        END IF;
                    END IF;

                    IF v_strSBEOM = 'Y' THEN
                        IF v_dCurMonth = 3 or v_dCurMonth = 6 or v_dCurMonth = 9 THEN
                            v_strSBEOQ := 'Y';
                        ELSIF v_dCurMonth = 12 THEN
                            v_strSBEOQ := 'Y';
                            v_strSBEOY := 'Y';
                        END IF;
                    END IF;

                    INSERT INTO SBCLDR (Autoid,SBDATE,SBBUSDAY,SBBOW,SBBOM,SBBOQ,SBBOY,SBEOW,SBEOM,SBEOQ,SBEOY,HOLIDAY,CLDRTYPE)
                    VALUES (seq_SBCLDR.NEXTVAL,v_dCurDate,v_strSBBUSDAY,v_strSBBOW,v_strSBBOM,v_strSBBOQ,v_strSBBOY,v_strSBEOW,v_strSBEOM,v_strSBEOQ,v_strSBEOY,v_strHOLIDAY,v_strCLDRTYPE);

                END IF;

               -- SELECT COUNT(*) INTO v_iTmp FROM GXCALENDAR
                --WHERE TXDATE = TO_CHAR(v_dCurDate,'dd/mm/yyyy');

               -- If v_iTmp <= 0 then
                  --  INSERT INTO gxcalendar("TXDATE","BUSDAY","HOLIDAY","CLEARDAY","SCHEDULE_TYPE")
                    --VALUES(TO_CHAR(v_dCurDate,'dd/mm/yyyy'),'N',v_strHoliday,NULL,'WKD');
               -- End If;

                v_dCurDate := v_dCurDate + 1;

            END LOOP;
        END LOOP;

    END LOOP;
    CLOSE curCLDRTYPE;

    commit;
    dbms_output.put_line('Successful... ');
EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            rollback;
            raise;
            return;
        END;
END;

 
 
 
 
/
