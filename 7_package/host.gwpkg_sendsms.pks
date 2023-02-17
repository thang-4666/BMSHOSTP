SET DEFINE OFF;
CREATE OR REPLACE PACKAGE gwpkg_sendsms
IS
    FUNCTION fnc_sendsms (pin_phonenumber   IN     VARCHAR2,
                          pin_message       IN     VARCHAR2)
        RETURN CHAR;
    ----------------------- Main Procedure/Function ----------------------------
    PROCEDURE job_sendsms;
END;                                                           -- Package spec
 
 
 
/


CREATE OR REPLACE PACKAGE BODY gwpkg_sendsms
IS
    FUNCTION fnc_sendsms (pin_phonenumber   IN VARCHAR2,
                          pin_message       IN VARCHAR2)
        RETURN CHAR
    IS
        tmpmessage   VARCHAR2 (1000);
        tmp char(1);
    BEGIN
        --DBMS_OUTPUT.put_line (pin_phonenumber);
        tmp := 'S';
        tmp := fnc_sendsms@remotesmsdb(pin_phonenumber,pin_message,tmpmessage);


        RETURN tmp;
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line ('LOI:' || SQLERRM);
            ROLLBACK;
            RETURN 'E';
    END;                                           -- END FUNCTION fnc_sendsms

    ----------------------- Main Procedure/Function ----------------------------
    PROCEDURE job_sendsms
    IS
        cresult   CHAR;
    BEGIN

     pr_error('cresult: 0', cresult);

        FOR rec
        IN (
            SELECT   el.autoid,
                     TRIM(el.email) email,
                     '84' || SUBSTR(email, 2, LENGTH(TRIM(email))) emailsend,
                     el.msgbody,
                     ts.subject,
                     el.status
              FROM   templates ts, emaillog el
             WHERE       ts.code = el.templateid
                     AND el.status = 'O'
                     AND ts.TYPE = 'S'
                    -- AND TS.isactive ='Y' -- Chi gui nhung mau active
                    AND trim(el.msgbody) IS NOT NULL
                     AND TRIM(el.email) IS NOT NULL
                     AND instr(el.msgbody,'[')=0
                     AND instr(el.msgbody,']')=0
             )
        LOOP
            BEGIN

               pr_error('cresult: 1'||rec.emailsend , cresult);
                cresult := fnc_sendsms (rec.emailsend, rec.msgbody);
                pr_error('cresult: 2'||rec.emailsend, cresult);

                UPDATE   emaillog
                   SET   status = cresult,
                         senttime = sysdate
                 WHERE       autoid = rec.autoid
                       AND email = rec.email
                        AND status = 'O';
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.put_line ('LOI:' || SQLERRM);

                    UPDATE   emaillog
                       SET   status = 'E', senttime = SYSDATE
                     WHERE       autoid = rec.autoid
                             AND email = rec.email
                             AND status = 'A';
            END;

            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line ('LOI:' || SQLERRM);
            pr_error('cresult: ', dbms_utility.format_error_backtrace);
    END;
END;

/
