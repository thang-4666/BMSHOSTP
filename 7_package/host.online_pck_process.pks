SET DEFINE OFF;
CREATE OR REPLACE PACKAGE online_pck_process
  IS
  PROCEDURE prc_recreate_job;

  PROCEDURE prc_update_PRS;

END; -- Package spec

 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY online_pck_process
IS
   PROCEDURE prc_recreate_job
       IS
          CURSOR c_job
          IS
              SELECT job, what, INTERVAL
              FROM user_jobs
              WHERE broken = 'Y';

          v_job     c_job%ROWTYPE;
          v_jobid   NUMBER;
       BEGIN
          FOR v_job IN c_job
          LOOP
             DBMS_JOB.remove (v_job.job);
             DBMS_JOB.submit (v_jobid, v_job.what, SYSDATE, v_job.INTERVAL);
          END LOOP;
          COMMIT;
       EXCEPTION
          WHEN OTHERS
          THEN
             ROLLBACK;
       END;
   PROCEDURE prc_update_PRS
    IS
    --Lay du lieu sec_info_temp
    CURSOR c_stock
    IS
     SELECT
      trim(S.SYMBOL) SYMBOL,S.BASICPRICE,S.FLOORPRICE,S.CEILINGPRICE,S.CURRENT_ROOM, SB.HALT
        FROM SECURITIES_INFO S, sbsecurities SB
        WHERE S.SYMBOL=SB.SYMBOL
        AND SB.TRADEPLACE  IN ('001','002','005')
        AND SB.SECTYPE IN('001','008');

    BEGIN

   FOR vc_stock IN c_stock
   LOOP
     UPDATE SECURITIES_INFO
       SET   BASICPRICE= vc_stock.BASICPRICE,
             CEILINGPRICE= vc_stock.CEILINGPRICE,
             FLOORPRICE= vc_stock.FLOORPRICE,
             DFREFPRICE=vc_stock.FLOORPRICE,
             CURRENT_ROOM=vc_stock.CURRENT_ROOM
       WHERE SYMBOL= vc_stock.SYMBOL
                and(  BASICPRICE<> vc_stock.BASICPRICE
                    or CEILINGPRICE<> vc_stock.CEILINGPRICE
                    or FLOORPRICE<>vc_stock.FLOORPRICE
                    or CURRENT_ROOM<>vc_stock.CURRENT_ROOM);

     UPDATE SBSECURITIES SET HALT =  vc_stock.HALT WHERE SYMBOL=vc_stock.SYMBOL;

   END LOOP;
   COMMIT;
   END;

  END;
/
