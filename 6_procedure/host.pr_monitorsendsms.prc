SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_monitorsendsms (pv_detail IN varchar2, pv_source IN VARCHAR2)
   IS
  v_string VARCHAR2(1000);
  v_currhour VARCHAR2(2);
  v_currmin VARCHAR2(2);
BEGIN
  SELECT to_char(SYSDATE,'hh24') INTO v_currhour FROM dual;
  SELECT to_char(SYSDATE,'mi') INTO v_currmin FROM dual;
   v_string:= 'select '''|| pv_detail || ''' detail from dual';
        FOR rec IN
                (
                        /*SELECT * FROM (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                                 from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                                 connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a*/
                  SELECT DISTINCT mobile FROM SMSMonitorManager WHERE status = 'Y' AND smsid = pv_source
                  AND ( v_currhour > SUBSTR(fromtime,0,2)
                        OR (
                             v_currhour = SUBSTR(fromtime,0,2) AND v_currmin >= SUBSTR(fromtime,3,2)
                           )

                      )
                  AND ( v_currhour < SUBSTR(totime,0,2)
                        OR (
                             v_currhour = SUBSTR(totime,0,2) AND v_currmin <= SUBSTR(totime,3,2)
                           )

                      )
                )
        LOOP
                  plog.error( 'InsertEmailLog: ' ||rec.mobile|| v_string);
                 nmpks_ems.InsertEmailLog(rec.mobile , '0305', v_string,'');
        END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        return;
END;
 
 
 
 
/
