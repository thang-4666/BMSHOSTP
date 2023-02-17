SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_filemaster
IS

    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  TienPQ      09-JUNE-2009    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/


  PROCEDURE CAL_DF_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_DF_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE CAL_MARGIN_LIMIT (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE CAL_SEC_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_SEC_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE CAL_SECURITIES_RISK (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_SECURITIES_RISK (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE CAL_COP_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE pr_CashDepositUpload(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);
  PROCEDURE pr_CFSEUpload(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);
  PROCEDURE pr_Guarantee(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);
  PROCEDURE pr_TRFSTOCK(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);
  PROCEDURE CAL_OTHERCIACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE CAL_OTHERSEACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_OTHERCIACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_OTHERSEACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE PR_PRSYSTEM_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE PR_PRSYSTEM_UPLOAD (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE pr_T0Limit_Import(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);

  PROCEDURE pr_T0AFLimit_Import(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);

  PROCEDURE PR_ROOM_MARGIN_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE PR_ROOM_SYSTEM_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE PR_PRICE_MARGIN_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE PR_PRICE_CL_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE PR_FILE_TBLCFAF (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_CFOTHERACC (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLSE2240 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLSE2245 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLSE2202 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLCAI039 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLSE2244 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCI1141 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCI1137(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCI1138(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCI1101 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCI1187 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCI1135 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCF0037(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
     PROCEDURE PR_FILE_TBLCI1180 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLSE2287 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLSE2203 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_CADTLIMP (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLCA3343 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_tmpSEMASTVSD (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_tmpTOTALSEVSD(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  --ThangNV: Procedure Import Tu doanh --
  PROCEDURE CAL_DL_TRADER(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);
  PROCEDURE FILLTER_DL_TRADER(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);
  PROCEDURE FILLTER_FILE_TBLCFAF(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);
  PROCEDURE CAL_DL_SECURITY(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);
  PROCEDURE FILLTER_DL_SECURITY(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);

  PROCEDURE CAL_DL_ALERT(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);
  PROCEDURE FILLTER_DL_ALERT(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);
  PROCEDURE FILLTER_TBLCHANGEAFTYPE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLCHANGEAFTYPE(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_TBLCHANGECFTYPE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLCHANGECFTYPE(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLRE0384 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_TBLRE0380 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_APR_FILE_TBLRE0380 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE FILLTER_ODPROBRKAFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_MRPRMLIMITCFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_ADPRMFEECFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_LNPRMINTCFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE FILLTER_CFCHANGEBRID(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_ODPROBRKAFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_LNPRMINTCFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_ADPRMFEECFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_MRPRMLIMITCFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);

  PROCEDURE FILLTER_CIFEEDEF_EXTLNK(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
  PROCEDURE PR_FILE_CIFEEDEF_EXTLNK(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE FILLTER_TBLCHANGECAREBY (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_TBLCHANGECAREBY(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE PR_FILE_CFCHANGEBRID(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
PROCEDURE PR_FILE_TBLRE_0384(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) ;
PROCEDURE PR_APR_FILE_TBLRE_0384(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) ;
PROCEDURE PR_FILE_TBLRE_0381(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) ;
PROCEDURE PR_APR_FILE_TBLRE_0381(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) ;
PROCEDURE PR_FILE_BONDIPO(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) ;
PROCEDURE PR_APR_FILE_BONDIPO(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) ;



PROCEDURE FILLTER_FILE_HNXI(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2);

END;
 
/


CREATE OR REPLACE PACKAGE BODY cspks_filemaster
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

PROCEDURE CAL_SEC_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
BEGIN
    p_err_code := 0;
    -- Kiem tra neu trung khoa secbaskettemp; Tra ve loi
    BEGIN
    SELECT basketid,symbol, count(1) INTO v_basketid,v_symbol,v_count FROM secbaskettemp
    HAVING count(1) <> 1
    GROUP BY  basketid,symbol;
        -- co 1 truong hop bi trung khoa
        p_err_code := -100407;
        p_err_message:= 'Dupplicate key of secbaskettemp!';
        RETURN;
    EXCEPTION
    WHEN no_data_found THEN
        NULL; -- OK khong bi trung khoa
    WHEN OTHERS THEN
        p_err_code := -100407;
        p_err_message:= 'Dupplicate key of secbaskettemp!';
        RETURN;
    END;

    -- Kiem tra bracketID da duoc khai bao hay chua?
    SELECT count(1)
        INTO v_count
    FROM secbaskettemp
    WHERE NOT EXISTS (SELECT basketid FROM basket WHERE basket.basketid = secbaskettemp.basketid);
    IF v_count > 0 THEN
        p_err_code := -100406;
        p_err_message:= 'Chua khai bao backetid!';
        RETURN;
    END IF;

    --backup old secbasket
    insert into secbaskethist
    (autoid,basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, mrmaxqtty,description, backupdt,importdt, makerid, action,ISCATEGORY)
    select autoid,basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, mrmaxqtty,description, to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') backupdt,importdt, makerid, 'IMPORT',ISCATEGORY
    from secbasket where basketid  in (select basketid from secbaskettemp);
    delete from secbasket where basketid in (select basketid from secbaskettemp);
    insert into secbasket
    (autoid,basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, mrmaxqtty,description,importdt,makerid,ISCATEGORY)
    select seq_secbasket.nextval,basketid, symbol, mrratiorate, mrratioloan,
       mrpricerate, mrpriceloan, mrmaxqtty,description, to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') importdt, tellerid,ISCATEGORY
    from secbaskettemp where status <> 'N';

    update secbaskettemp set STATUS = 'C', approved='Y', aprid=p_tlid;

    --Apply ngay sau khi duyet import.
    if cspks_saproc.fn_ApplySystemParam(p_err_code) <> 0 then
        p_err_code:= errnums.C_SYSTEM_ERROR; --Loi he thong
        return;
    end if;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';


exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END CAL_SEC_BASKET;

/*****************************************/
-------- ThangNV: Import Tu Doanh ---------
/*****************************************/
PROCEDURE cal_dl_trader (p_tlid          IN     VARCHAR2,
                         p_err_code         OUT VARCHAR2,
                         p_err_message      OUT VARCHAR2)
IS
    v_count       NUMBER;
    v_busdate     DATE;
    v_timestamp   VARCHAR2 (100);
BEGIN
    p_err_code := 0;

    ----LEVELCD is not formated -------
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   levelcd <> 'U';

    IF v_count > 0
    THEN
        p_err_code := '-100820';
        p_err_message := 'LEVELCD is not formated';
        RETURN;
    END IF;

    ----- MAXNAV is not numberic -----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   isnumber (maxnav) = 'N';

    IF v_count > 0
    THEN
        p_err_code := '-100822';
        p_err_message := 'MAXNAV is not numberic';
        RETURN;
    END IF;

    ----- FRDATE and TODATE are not formated of date ----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   isdate (frdate) = 'N' OR isdate (todate) = 'N';

    IF v_count > 0
    THEN
        p_err_code := '-100823';
        p_err_message := 'FRDATE and TODATE are not formated of date';
        RETURN;
    END IF;

    ----- FRDATE is less than TODATE -----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   TO_DATE (frdate,systemnums.C_DATE_FORMAT) - TO_DATE (todate,systemnums.C_DATE_FORMAT) >
                 0;

    IF v_count > 0
    THEN
        p_err_code := '-100824';
        p_err_message := 'FRDATE is less than TODATE';
        RETURN;
    END IF;

    ----- Duplicate TRADERNAME  -----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   tradername IN (  SELECT   tradername
                                FROM   dl_tradertemp
                            GROUP BY   tradername
                              HAVING   COUNT ( * ) > 1);

    IF v_count > 1
    THEN
        p_err_code := '-100860';
        p_err_message := 'Duplicate TRADERNAME';
        RETURN;
    END IF;

    ----- TRADERNAME does not exist ----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   UPPER (tradername) NOT IN (SELECT   UPPER(tlname) FROM tlprofiles);

    IF v_count > 0
    THEN
        p_err_code := '-100861';
        p_err_message := 'TRADERNAME does not exist';
        RETURN;
    END IF;

    -- FRDATE is greater than current date
    SELECT  COUNT(1)
        INTO    v_count
        FROM    dl_tradertemp
    WHERE to_date(frdate, systemnums.C_DATE_FORMAT) < getcurrdate;

    IF v_count > 0
    THEN
        p_err_code := '-100827';
        p_err_message := 'FRDATE is greater than current date';
        RETURN;
    END IF;
    -- Duplicate time of validity ----
    SELECT  COUNT(*) INTO v_count
    FROM    dl_tradertemp dl, tlprofiles tl
    WHERE   UPPER(dl.tradername) = UPPER(tl.tlname)
            AND (
                 EXISTS(SELECT * FROM cftrdpolicy cf
                          WHERE cf.refid = tl.tlid
                                  AND TO_DATE(dl.frdate,systemnums.C_DATE_FORMAT) <= TO_DATE(cf.todate,systemnums.C_DATE_FORMAT)
                                  AND cf.levelcd = 'U'
                          )
                 ) ;
    IF v_count > 0
    THEN
        p_err_code := '-100888';
        p_err_message := 'Duplicate time of validity';
        RETURN;
    END IF;

    /****** Inserting dataset *******/

    INSERT INTO cftrdpolicy (autoid,
                             levelcd,
                             refid,
                             maxnav,
                             frdate,
                             todate,
                             notes)
        SELECT   seq_cftrdpolicy.NEXTVAL,
                 dl.levelcd,
                 tl.tlid,
                 TO_NUMBER (dl.maxnav),
                 TO_DATE (dl.frdate,systemnums.C_DATE_FORMAT),
                 TO_DATE (dl.todate,systemnums.C_DATE_FORMAT),
                 dl.notes
          FROM   dl_tradertemp dl, tlprofiles tl
         WHERE   UPPER (dl.tradername) = UPPER(tl.tlname);


    /****** Inserting to MAINTAIN_LOG *******/
    -- get CURRDATE
    SELECT   TO_DATE (varvalue, 'DD/MM/RRRR')
      INTO   v_busdate
      FROM   sysvar
     WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM';

    -- get CURRTIME
    SELECT   TO_CHAR (SYSDATE, 'HH24:MI:SS') INTO v_timestamp FROM DUAL;

    -- execute alternately
    FOR rec
    IN (SELECT   *
          FROM   cftrdpolicy
         WHERE   status = 'P'
                 AND LEVELCD = 'U'
                 AND refid IN
                            (SELECT   tl.tlid
                               FROM   tlprofiles tl, dl_tradertemp dl
                              WHERE   UPPER (dl.tradername) =
                                          UPPER (tl.tlname)))
    LOOP
        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'AUTOID',
                    '',
                    TO_CHAR (rec.autoid),
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);

        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'LEVELCD',
                    '',
                    rec.levelcd,
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);

        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'REFID',
                    '',
                    rec.refid,
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);

        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'MAXNAV',
                    '',
                    TO_CHAR (rec.maxnav),
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);

        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'FRDATE',
                    '',
                    TO_CHAR (rec.frdate, 'DD/MM/RRRR'),
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);

        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'TODATE',
                    '',
                    TO_CHAR (rec.todate, 'DD/MM/RRRR'),
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);

        INSERT INTO maintain_log (table_name,
                                  record_key,
                                  maker_id,
                                  maker_dt,
                                  approve_rqd,
                                  approve_id,
                                  approve_dt,
                                  mod_num,
                                  column_name,
                                  from_value,
                                  to_value,
                                  action_flag,
                                  child_table_name,
                                  child_record_key,
                                  maker_time)
          VALUES   ('CFTRDPOLICY',
                    'AUTOID = ''' || rec.autoid || '''',
                    p_tlid,
                    v_busdate,
                    'Y',
                    NULL,
                    v_busdate,
                    0,
                    'NOTES',
                    '',
                    rec.notes,
                    'ADD',
                    NULL,
                    NULL,
                    v_timestamp);
    END LOOP;

    RETURN;
END cal_dl_trader;

-------------------------------------------------------

PROCEDURE fillter_dl_trader (p_tlid          IN     VARCHAR2,
                             p_err_code         OUT VARCHAR2,
                             p_err_message      OUT VARCHAR2)
IS
    v_count   NUMBER;
BEGIN
    p_err_code := 0;

    /***** Validating dataset *****/
    ----LEVELCD is not formated -------
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   levelcd <> 'U';

    IF v_count > 0
    THEN
        p_err_code := '-100820';
        p_err_message := 'LEVELCD is not formated';
        RETURN;
    END IF;

    ----- MAXNAV is not numberic -----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   isnumber (maxnav) = 'N';

    IF v_count > 0
    THEN
        p_err_code := '-100822';
        p_err_message := 'MAXNAV is not numberic';
        RETURN;
    END IF;

    ----- FRDATE and TODATE are not formated of date ----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   isdate (frdate) = 'N' OR isdate (todate) = 'N';

    IF v_count > 0
    THEN
        p_err_code := '-100823';
        p_err_message := 'FRDATE and TODATE are not formated of date';
        RETURN;
    END IF;

    ----- FRDATE is less than TODATE -----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   TO_DATE (frdate,systemnums.C_DATE_FORMAT) - TO_DATE (todate,systemnums.C_DATE_FORMAT) >
                 0;

    IF v_count > 0
    THEN
        p_err_code := '-100824';
        p_err_message := 'FRDATE is less than TODATE';
        RETURN;
    END IF;

    ----- Duplicate TRADERNAME  -----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   tradername IN (  SELECT   tradername
                                FROM   dl_tradertemp
                            GROUP BY   tradername
                              HAVING   COUNT ( * ) > 1);

    IF v_count > 1
    THEN
        p_err_code := '-100860';
        p_err_message := 'Duplicate TRADERNAME';
        RETURN;
    END IF;

    ----- TRADERNAME does not exist ----
    SELECT   COUNT (1)
      INTO   v_count
      FROM   dl_tradertemp
     WHERE   UPPER (tradername) NOT IN (SELECT   UPPER(tlname) FROM tlprofiles);

    IF v_count > 0
    THEN
        p_err_code := '-100861';
        p_err_message := 'TRADERNAME does not exist';
        RETURN;
    END IF;

    -- FRDATE is greater than current date
    SELECT  COUNT(1)
        INTO    v_count
        FROM    dl_tradertemp
    WHERE to_date(frdate, systemnums.C_DATE_FORMAT) < getcurrdate;

    IF v_count > 0
    THEN
        p_err_code := '-100827';
        p_err_message := 'FRDATE is greater than current date';
        RETURN;
    END IF;
    SELECT  COUNT(*) INTO v_count
    FROM    dl_tradertemp dl, tlprofiles tl
    WHERE   UPPER(dl.tradername) = UPPER(tl.tlname)
            AND (
                 EXISTS(SELECT * FROM cftrdpolicy cf
                          WHERE cf.refid = tl.tlid
                          AND TO_DATE(dl.frdate,systemnums.C_DATE_FORMAT) <= TO_DATE(cf.todate,systemnums.C_DATE_FORMAT)
                          AND cf.levelcd = 'U'
                          )
                 ) ;
    IF v_count > 0
    THEN
        p_err_code := '-100888';
        p_err_message := 'Duplicate time of validity';
        RETURN;
    END IF;

    p_err_code := 0;
    p_err_message := 'Sucessfull!';
EXCEPTION
    WHEN OTHERS
    THEN
        ROLLBACK;
        p_err_code := -100800;             --File du lieu dau vao khong hop le
        p_err_message := 'System error. Invalid file format';
        RETURN;
END fillter_dl_trader;
-------------------------------------------------------

PROCEDURE CAL_DL_SECURITY (p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2)
IS
  v_count number;
  v_busdate date;
  v_timestamp varchar2(100);
BEGIN
  p_err_code := 0;
  /***** Validating dataset *****/
  ----LEVELCD is not formated -------
  select count(1) into v_count from DL_SECURITYTEMP where LEVELCD <> 'I';
  if v_count > 0 then
    p_err_code := '-100820';
    p_err_message := 'LEVELCD is not formated';
  return;
  end if;
  --- Some fields are not numberic ---
  select count(1) into v_count from DL_SECURITYTEMP where ISNUMBER(MAXAVLBAL) = 'N' or ISNUMBER(MINAVLBAL) = 'N' or ISNUMBER(MAXBPRICE) = 'N' or ISNUMBER(MINSPRICE) = 'N' or ISNUMBER(DELTABPRC) = 'N' or ISNUMBER(DELTASPRC) = 'N' or ISNUMBER(MAXALLBUY) = 'N' or ISNUMBER(MAXALLSELL) = 'N';
  if v_count > 0 then
    p_err_code := '-100831';
    p_err_message := 'Some fields are not numberic';
  return;
  end if;
  ----- FRDATE and TODATE are not formated of date ----
  select count(1) into v_count from DL_SECURITYTEMP where ISDATE(FRDATE) = 'N' or ISDATE(TODATE) = 'N';
  if v_count > 0 then
  p_err_code := '-100823';
  p_err_message := 'FRDATE and TODATE are not formated of date';
  return;
  end if;
    ----- FRDATE is less than TODATE -----
  select count(1) into v_count from DL_SECURITYTEMP where to_date(FRDATE,systemnums.C_DATE_FORMAT) - to_date(TODATE,systemnums.C_DATE_FORMAT) > 0;
  if v_count > 0 then
  p_err_code := '-100824';
  p_err_message := 'FRDATE is less than TODATE';
  return;
  end if;
  -- FRDATE is greater than current date
  SELECT  COUNT(1)
    INTO    v_count
        FROM    DL_SECURITYTEMP
    WHERE to_date(frdate, systemnums.C_DATE_FORMAT) < getcurrdate;

    IF v_count > 0
    THEN
        p_err_code := '-100827';
        p_err_message := 'FRDATE is greater than current date';
        RETURN;
    END IF;
  -- Duplicate time of validity
  SELECT count(*) into v_count  FROM dl_securitytemp dl, tlprofiles tl, sbsecurities sec
    WHERE UPPER(dl.tradername) = UPPER(tl.tlname)
          AND dl.symbol = sec.symbol
          AND (
               EXISTS(SELECT * FROM cftrdpolicy cf
                        WHERE cf.refid = sec.codeid
                              AND TO_DATE(dl.frdate,systemnums.C_DATE_FORMAT) <= TO_DATE(cf.todate,systemnums.C_DATE_FORMAT)
                              AND cf.levelcd = 'I'
                        )
               ) ;
  if v_count > 0 then
      p_err_code := '-100888';
      p_err_message := 'Duplicate time of validity';
      return;
  end if;
  /***** Inserting dataset *****/

  Insert into CFTRDPOLICY(AUTOID,LEVELCD,REFID,MAXAVLBAL,MINAVLBAL,MAXBPRICE,MINSPRICE,DELTABPRC,DELTASPRC,MAXALLBUY,MAXALLSELL,TRADERID,FRDATE,TODATE,NOTES)
  select seq_cftrdpolicy.nextval,dl.LEVELCD, sb.CODEID,to_number(dl.MAXAVLBAL),to_number(dl.MINAVLBAL),to_number(dl.MAXBPRICE),to_number(dl.MINSPRICE),to_number(dl.DELTABPRC),to_number(dl.DELTASPRC),to_number(dl.MAXALLBUY),to_number(dl.MAXALLSELL),tl.TLID,to_date(dl.FRDATE,systemnums.C_DATE_FORMAT),to_date(dl.TODATE,systemnums.C_DATE_FORMAT),dl.NOTES
    from DL_SECURITYTEMP dl,SBSECURITIES sb, TLPROFILES tl where dl.SYMBOL = sb.SYMBOL and UPPER(dl.TRADERNAME) = UPPER(tl.TLNAME);

  /****** Inserting to MAINTAIN_LOG *******/
  -- get CURRDATE
    SELECT to_date(varvalue,systemnums.C_DATE_FORMAT) INTO v_busdate
      FROM sysvar
        WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
  -- get CURRTIME
  select to_char(sysdate,'HH24:MI:SS') INTO v_timestamp
      from dual;
  -- execute alternately
  FOR rec IN(
    SELECT * FROM CFTRDPOLICY
    where STATUS = 'P' AND LEVELCD = 'I'
          AND refid IN
                            (SELECT   sec.codeid
                               FROM   tlprofiles tl, DL_SECURITYTEMP dl, sbsecurities sec
                              WHERE   UPPER (dl.tradername) =
                                          UPPER (tl.tlname)
                                      AND dl.symbol = sec.symbol)

  )
  LOOP
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'AUTOID','',to_char(rec.autoid),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'LEVELCD','',rec.LEVELCD,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'REFID','',rec.REFID,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'MAXAVLBAL','',to_char(rec.MAXAVLBAL),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'MINAVLBAL','',to_char(rec.MINAVLBAL),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'MAXBPRICE','',to_char(rec.MAXBPRICE),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'MINSPRICE','',to_char(rec.MINSPRICE),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'DELTABPRC','',to_char(rec.DELTABPRC),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'DELTASPRC','',to_char(rec.DELTASPRC),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'MAXALLBUY','',to_char(rec.MAXALLBUY),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'MAXALLSELL','',to_char(rec.MAXALLSELL),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'TRADERID','',rec.TRADERID,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'FRDATE','',to_char(rec.FRDATE,systemnums.C_DATE_FORMAT),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'TODATE','',to_char(rec.TODATE,systemnums.C_DATE_FORMAT),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFTRDPOLICY','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'NOTES','',rec.NOTES,'ADD',null,null,v_timestamp);
  END LOOP;
RETURN;
END CAL_DL_SECURITY;

-------------------------------------------------------
PROCEDURE FILLTER_DL_SECURITY (p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2)
IS
  v_count number;
BEGIN
  p_err_code := 0;
  /***** Validating dataset *****/
  ----LEVELCD is not formated -------
  select count(1) into v_count from DL_SECURITYTEMP where LEVELCD <> 'I';
  if v_count > 0 then
    p_err_code := '-100820';
    p_err_message := 'LEVELCD is not formated';
  return;
  end if;
  --- Some fields are not numberic ---
  select count(1) into v_count from DL_SECURITYTEMP where ISNUMBER(MAXAVLBAL) = 'N' or ISNUMBER(MINAVLBAL) = 'N' or ISNUMBER(MAXBPRICE) = 'N' or ISNUMBER(MINSPRICE) = 'N' or ISNUMBER(DELTABPRC) = 'N' or ISNUMBER(DELTASPRC) = 'N' or ISNUMBER(MAXALLBUY) = 'N' or ISNUMBER(MAXALLSELL) = 'N';
  if v_count > 0 then
    p_err_code := '-100831';
    p_err_message := 'Some fields are not numberic';
  return;
  end if;
  ----- FRDATE and TODATE are not formated of date ----
  select count(1) into v_count from DL_SECURITYTEMP where ISDATE(FRDATE) = 'N' or ISDATE(TODATE) = 'N';
  if v_count > 0 then
  p_err_code := '-100823';
  p_err_message := 'FRDATE and TODATE are not formated of date';
  return;
  end if;
  ----- FRDATE is less than TODATE -----
  select count(1) into v_count from DL_SECURITYTEMP where to_date(FRDATE,systemnums.C_DATE_FORMAT) - to_date(TODATE,systemnums.C_DATE_FORMAT) > 0;
  if v_count > 0 then
  p_err_code := '-100824';
  p_err_message := 'FRDATE is less than TODATE';
  return;
  end if;
    -- FRDATE is greater than current date
  SELECT  COUNT(1)
      INTO    v_count
      FROM    DL_SECURITYTEMP
  WHERE to_date(frdate, systemnums.C_DATE_FORMAT) < getcurrdate;

  IF v_count > 0
  THEN
      p_err_code := '-100827';
      p_err_message := 'FRDATE is greater than current date';
      RETURN;
  END IF;
  -- Duplicate time of validity
  SELECT count(*) into v_count  FROM dl_securitytemp dl, tlprofiles tl, sbsecurities sec
    WHERE UPPER(dl.tradername) = UPPER(tl.tlname)
          AND dl.symbol = sec.symbol
          AND (
               EXISTS(SELECT * FROM cftrdpolicy cf
                        WHERE cf.refid = sec.codeid
                              AND TO_DATE(dl.frdate,systemnums.C_DATE_FORMAT) <= TO_DATE(cf.todate,systemnums.C_DATE_FORMAT)
                              AND cf.levelcd = 'I'
                        )
               ) ;
  if v_count > 0 then
      p_err_code := '-100888';
      p_err_message := 'FRDATE is less than TODATE';
      return;
  end if;

  p_err_code := 0;
  p_err_message:= 'Sucessfull!';

exception
when others then
  rollback;
  p_err_code := -100800; --File du lieu dau vao khong hop le
  p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_DL_SECURITY;
-------------------------------------------------------
PROCEDURE CAL_DL_ALERT(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2)
IS
  v_count number;
  v_busdate date;
  v_timestamp varchar2(100);
BEGIN
  p_err_code := 0;
  /******** Validating dataset *********/
  ------ OPERATOR is not formated -------
  select count(1) into v_count from DL_ALERTTEMP where OPERATORCD not in ('>','>=','<','<=','==','<>');
  if v_count > 0 then
  p_err_code := '-100840';
  p_err_message := 'OPERATORCD is not formated';
  return;
  end if;
  ----- FRDATE and TODATE are not formated of date ----
  select count(1) into v_count from DL_ALERTTEMP where ISDATE(FRDATE) = 'N' or ISDATE(TODATE) = 'N';
  if v_count > 0 then
  p_err_code := '-100823';
  p_err_message := 'FRDATE and TODATE are not formated of date';
  return;
  end if;
  ----- FRDATE is less than TODATE -----
  select count(1) into v_count from DL_ALERTTEMP where to_date(FRDATE,systemnums.C_DATE_FORMAT) - to_date(TODATE,systemnums.C_DATE_FORMAT) > 0;
  if v_count > 0 then
  p_err_code := '-100824';
  p_err_message := 'FRDATE is less than TODATE';
  return;
  end if;
  ----- TRGVAL is not numberic -----
  select count(1) into v_count from DL_ALERTTEMP where ISNUMBER(TRGVAL) = 'N';
  if v_count > 0 then
  p_err_code := '-100826';
  p_err_message := 'TRGVAL is not numberic';
  return;
  end if;
  -- FRDATE is greater than current date
  SELECT  COUNT(1)
        INTO    v_count
        FROM    DL_ALERTTEMP
  WHERE to_date(frdate, systemnums.C_DATE_FORMAT) < getcurrdate;

  IF v_count > 0
  THEN
        p_err_code := '-100827';
        p_err_message := 'FRDATE is greater than current date';
        RETURN;
  END IF;
  -- Duplicate time of validity
  SELECT COUNT(*) INTO v_count FROM dl_alerttemp dl, sbsecurities sec
     WHERE dl.symbol = sec.symbol
           AND EXISTS(SELECT * FROM cfaftrdalert cf
                         WHERE cf.codeid = sec.codeid AND cf.alertcd = dl.alertcd
                               AND (
                                    to_date(dl.frdate,systemnums.C_DATE_FORMAT) <= to_date(cf.todate,systemnums.C_DATE_FORMAT)
                                   )
                         );


  if v_count > 0 then
      p_err_code := '-100888';
      p_err_message := 'TRGVAL is not numberic';
      return;
  end if;

  /***** Inserting dataset *****/

  Insert into CFAFTRDALERT(AUTOID,CODEID,ALERTTYP,ALERTCD,OPERATORCD,TRGVAL,SRCREFFIELD,FRDATE,TODATE,NOTES)
  select seq_cfaftrdalert.nextval,sb.CODEID, dl.ALERTTYP,dl.ALERTCD,dl.OPERATORCD,dl.TRGVAL,dl.SRCREFFIELD,to_date(dl.FRDATE,systemnums.C_DATE_FORMAT),to_date(dl.TODATE,systemnums.C_DATE_FORMAT),dl.NOTES
    from DL_ALERTTEMP dl,SBSECURITIES sb where dl.SYMBOL = sb.SYMBOL;


  /****** Inserting to MAINTAIN_LOG *******/
  -- get CURRDATE
    SELECT to_date(varvalue,systemnums.C_DATE_FORMAT) INTO v_busdate
      FROM sysvar
        WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
  -- get CURRTIME
  select to_char(sysdate,'HH24:MI:SS') INTO v_timestamp
      from dual;
  -- execute alternately
  FOR rec IN(
    SELECT * FROM CFAFTRDALERT
        where STATUS = 'P' AND codeid IN
                                (SELECT sec.codeid
                                    FROM dl_alerttemp dl, sbsecurities sec, allcode a
                                    WHERE dl.symbol = sec.symbol and a.cdval = dl.alertcd)
  )
  LOOP
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'AUTOID','',to_char(rec.AUTOID),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'CODEID','',rec.CODEID,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'ALERTTYP','',rec.ALERTTYP,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'ALERTCD','',rec.ALERTCD,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'OPERATORCD','',rec.OPERATORCD,'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'TRGVAL','',to_char(rec.TRGVAL),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'SRCREFFIELD','',rec.SRCREFFIELD,'ADD',null,null,v_timestamp);
    INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'FRDATE','',to_char(rec.FRDATE,systemnums.C_DATE_FORMAT),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'TODATE','',to_char(rec.TODATE,systemnums.C_DATE_FORMAT),'ADD',null,null,v_timestamp);
  INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
    VALUES('CFAFTRDALERT','AUTOID = ''' || rec.autoid || '''',p_tlid,v_busdate,'Y',null,v_busdate,0,'NOTES','',rec.NOTES,'ADD',null,null,v_timestamp);
  END LOOP;
RETURN;
END CAL_DL_ALERT;

----------------------------------------------------
PROCEDURE FILLTER_DL_ALERT(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2)
IS
  v_count number;
BEGIN
  p_err_code := 0;
  /******** Validating dataset *********/
  ------ OPERATOR is not formated -------
  select count(1) into v_count from DL_ALERTTEMP where OPERATORCD not in ('>','>=','<','<=','==','<>');
  if v_count > 0 then
  p_err_code := '-100840';
  p_err_message := 'OPERATORCD is not formated';
  return;
  end if;
  ----- FRDATE and TODATE are not formated of date ----
  select count(1) into v_count from DL_ALERTTEMP where ISDATE(FRDATE) = 'N' or ISDATE(TODATE) = 'N';
  if v_count > 0 then
  p_err_code := '-100823';
  p_err_message := 'FRDATE and TODATE are not formated of date';
  return;
  end if;
  ----- FRDATE is less than TODATE -----
  select count(1) into v_count from DL_ALERTTEMP where to_date(FRDATE,systemnums.C_DATE_FORMAT) - to_date(TODATE,systemnums.C_DATE_FORMAT) > 0;
  if v_count > 0 then
  p_err_code := '-100824';
  p_err_message := 'FRDATE is less than TODATE';
  return;
  end if;
  ----- TRGVAL is not numberic -----
  select count(1) into v_count from DL_ALERTTEMP where ISNUMBER(TRGVAL) = 'N';
  if v_count > 0 then
  p_err_code := '-100826';
  p_err_message := 'TRGVAL is not numberic';
  return;
  end if;
  -- FRDATE is greater than current date
  SELECT  COUNT(1)
        INTO    v_count
        FROM    DL_ALERTTEMP
  WHERE to_date(frdate, systemnums.C_DATE_FORMAT) < getcurrdate;

  IF v_count > 0
  THEN
        p_err_code := '-100827';
        p_err_message := 'FRDATE is greater than current date';
        RETURN;
  END IF;
  -- Duplicate time of validity
  SELECT COUNT(*) INTO v_count FROM dl_alerttemp dl, sbsecurities sec
     WHERE dl.symbol = sec.symbol
           AND EXISTS(SELECT * FROM cfaftrdalert cf
                         WHERE cf.codeid = sec.codeid AND cf.alertcd = dl.alertcd
                               AND (
                                    to_date(dl.frdate,systemnums.C_DATE_FORMAT) <= to_date(cf.todate,systemnums.C_DATE_FORMAT)
                                   )
                         );


  if v_count > 0 then
      p_err_code := '-100888';
      p_err_message := 'Duplicate time of validity';
      return;
  end if;

  p_err_code := 0;
  p_err_message:= 'Sucessfull!';

exception
when others then
  rollback;
  p_err_code := -100800; --File du lieu dau vao khong hop le
  p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_DL_ALERT;
----------------------------------------------------

PROCEDURE  PR_FILE_CADTLIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
  IS
  CAMASTID VARCHAR(30);

  l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param varchar2(300);
      l_MaxRow NUMBER(20,0);
      N NUMBER ;
V_DUEDATE        DATE;
V_BEGINDATE       DATE;
V_CAMASTID        varchar2(300);
V_SYMBOL          varchar2(300);
V_CATYPE         varchar2(300);
V_REPORTDATE       DATE;
V_ACTIONDATE      DATE;
V_CATYPEVAL       varchar2(300);
V_RATE           varchar2(300);
V_RIGHTOFFRATE    varchar2(300);
V_FRDATETRANSFER   DATE;
V_TODATETRANSFER   DATE;
V_ROPRICE          NUMBER;
V_TVPRICE        NUMBER;
V_STATUS          varchar2(300);
V_DESC            varchar2(300);
l_count          NUMBER;
l_strSETYPE      varchar2(300);
V_CURRDATE  DATE ;
  BEGIN

BEGIN
FOR REC in (
SELECT  camast.camastid ,camast.codeid,cf.custodycd,af.acctno afacctno,CF.CUSTID,af.description
FROM cadtlimp ca,  camast, cfmast cf,afmast af
where  camast.camastid = ca.camastid and UPPER(ca.custodycd) = UPPER(af.description) and af.custid = cf.custid
 )
loop

update cadtlimp set acctno = rec.afacctno||rec.codeid , codeid = rec.codeid,custid= rec.custid,afacctno = rec.afacctno,
custodycd = UPPER(rec.description)
where UPPER(custodycd) = UPPER(rec.description) and camastid = rec.camastid ;

l_count:=0;
     SELECT count(1) into l_count FROM SEMAST WHERE ACCTNO=rec.afacctno||rec.codeid ;

        if l_count <=0 then
          --Neu khong co thi tu dong mo tai khoan
            select to_date(varvalue,'DD/MM/YYYY') INTO V_CURRDATE  from sysvar  where varname ='CURRDATE';
          SELECT TYP.SETYPE into l_strSETYPE FROM AFMAST AF, AFTYPE TYP WHERE AF.ACTYPE=TYP.ACTYPE AND AF.ACCTNO= rec.afacctno;
          INSERT INTO SEMAST (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,
                            OPNDATE,LASTDATE,STATUS,IRTIED,IRCD,
                            COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,
                            STANDING,WITHDRAW,DEPOSIT,LOAN)
                      VALUES (l_strSETYPE, rec.custid, rec.afacctno||rec.codeid , rec.codeid , rec.afacctno ,
                    V_CURRDATE ,V_CURRDATE ,'A','Y','001',
                      0,0,0,0,0,0,0,0,0);
        end IF;

end loop;
END ;
commit;
--


 SELECT CAMAST.CAMASTID  ,SYM.SYMBOL ,
 A1.CDCONTENT  ,REPORTDATE , DUEDATE ,ACTIONDATE ,BEGINDATE  ,  RIGHTOFFRATE ,
DESCRIPTION , A2.CDCONTENT  ,
nvl( (case when CAMAST.CATYPE='014' then CAMAST.EXPRICE end),0) ROPRICE ,
nvl( (case when CAMAST.CATYPE='011' then CAMAST.EXPRICE end),0) TVPRICE ,
(CASE WHEN EXRATE IS NOT NULL THEN EXRATE ELSE (CASE WHEN RIGHTOFFRATE IS NOT NULL
       THEN RIGHTOFFRATE ELSE (CASE WHEN DEVIDENTRATE IS NOT NULL THEN DEVIDENTRATE  ELSE
       (CASE WHEN SPLITRATE IS NOT NULL THEN SPLITRATE ELSE (CASE WHEN INTERESTRATE IS NOT NULL
       THEN INTERESTRATE ELSE
       (CASE WHEN DEVIDENTSHARES IS NOT NULL THEN DEVIDENTSHARES ELSE '0' END)END)END)END) END)END) RATE ,
       CAMAST.CATYPE,FRDATETRANSFER
  INTO V_CAMASTID, V_SYMBOL, V_CATYPE, V_REPORTDATE, V_DUEDATE , V_ACTIONDATE , V_BEGINDATE , V_RIGHTOFFRATE , V_DESC
       , V_STATUS , V_ROPRICE, V_TVPRICE , V_RATE  , V_CATYPE , V_FRDATETRANSFER
 FROM  CAMAST, SBSECURITIES SYM, ALLCODE A1, ALLCODE A2, ALLCODE A3,
      (select sum(case when schd.isci= 'Y' then schd.amt else 0 end) amt,
         sum( case when schd.isse ='Y' then schd.qtty else 0 end) qtty,
         sum(mst.pitrate *
                       ( CASE WHEN
                              (CASE WHEN schd.pitratemethod='##' THEN mst.pitratemethod ELSE schd.pitratemethod END) ='SC'
                         THEN 1 ELSE 0 END)
                        *(case when schd.isci= 'Y' then (case when  mst.catype='016' then schd.intamt else schd.amt end)
                               else 0 end) /100
            )taxamt,
       sum(mst.pitrate
                         * ( CASE WHEN
                              (CASE WHEN schd.pitratemethod='##' THEN mst.pitratemethod ELSE schd.pitratemethod END) ='SC'
                         THEN 0 ELSE 1 END)
             *(case when schd.isci= 'Y' then (case when  mst.catype='016' then schd.intamt else schd.amt end)
                               else 0 end) /100
            )realtaxamt,
         schd.camastid
          from caschd schd,camast mst
          where schd.deltd='N'
          and mst.deltd='N'
          AND mst.camastid=schd.camastid
          group by schd.camastid) SCHD
 WHERE CAMAST.CODEID=SYM.CODEID AND A1.CDTYPE = 'CA'
 AND A1.CDNAME = 'CATYPE' AND A1.CDVAL=CATYPE
 and A3.CDTYPE='CA' AND A3.CDNAME='PITRATEMETHOD' AND CAMAST.PITRATEMETHOD =A3.CDVAL
 AND A2.CDTYPE = 'CA' AND A2.CDNAME = 'CASTATUS'
 AND CAMAST.STATUS=A2.CDVAL AND CAMAST.DELTD ='N'
 and camast.camastid=schd.camastid(+)
 AND CAMAST.camastid  IN(SELECT MAX(CAMASTID) FROM cadtlimp );

 -----

    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='3325';
     SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=v_strCURRDATE;
    l_txmsg.BUSDATE:=v_strCURRDATE;
    l_txmsg.tltxcd:='3325';


        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := '0001';
        --Xac dinh xem nha day tu trong nuoc hay nuoc ngoai



       --Set cac field giao dich
        --01   N   DUEDATE
        l_txmsg.txfields ('01').defname   := 'DUEDATE';
        l_txmsg.txfields ('01').TYPE      := 'D';
        l_txmsg.txfields ('01').VALUE     := V_DUEDATE ;
             --02   N   BEGINDATE
        l_txmsg.txfields ('02').defname   := 'BEGINDATE';
        l_txmsg.txfields ('02').TYPE      := 'D';
        l_txmsg.txfields ('02').VALUE     := V_BEGINDATE ;
            --03   N   CAMASTID
        l_txmsg.txfields ('03').defname   := 'CAMASTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := V_CAMASTID ;
            --04   N   SYMBOL
        l_txmsg.txfields ('04').defname   := 'SYMBOL';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := V_SYMBOL ;
            --05   N   CATYPE
        l_txmsg.txfields ('05').defname   := 'CATYPE';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := V_CATYPE ;
          --06   N   REPORTDATE
        l_txmsg.txfields ('06').defname   := 'REPORTDATE';
        l_txmsg.txfields ('06').TYPE      := 'D';
        l_txmsg.txfields ('06').VALUE     := V_REPORTDATE ;
            --07   N   ACTIONDATE
        l_txmsg.txfields ('07').defname   := 'ACTIONDATE';
        l_txmsg.txfields ('07').TYPE      := 'D';
        l_txmsg.txfields ('07').VALUE     := V_ACTIONDATE ;
            --09   C   CATYPEVAL
        l_txmsg.txfields ('09').defname   := 'CATYPEVAL';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := V_CATYPEVAL ;
            --10   N   RATE
        l_txmsg.txfields ('10').defname   := 'RATE';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := V_RATE ;
           --11   N   RIGHTOFFRATE
        l_txmsg.txfields ('11').defname   := 'RIGHTOFFRATE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := V_RIGHTOFFRATE ;
                    --12   N   FRDATETRANSFER
        l_txmsg.txfields ('12').defname   := 'FRDATETRANSFER';
        l_txmsg.txfields ('12').TYPE      := 'D';
        l_txmsg.txfields ('12').VALUE     := V_FRDATETRANSFER ;
                    --13   N   TODATETRANSFER
        l_txmsg.txfields ('13').defname   := 'TODATETRANSFER';
        l_txmsg.txfields ('13').TYPE      := 'D';
        l_txmsg.txfields ('13').VALUE     := V_TODATETRANSFER ;
             --14   N   ROPRICE
        l_txmsg.txfields ('14').defname   := 'ROPRICE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := V_ROPRICE ;
             --15   N   TVPRICE
        l_txmsg.txfields ('15').defname   := 'TVPRICE';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := V_TVPRICE ;
                 --20   N   STATUS
        l_txmsg.txfields ('20').defname   := 'STATUS';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := V_STATUS ;
                 --30   N   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := V_DESC ;

       BEGIN
          IF txpks_#3325.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN

   plog.error('locpt:'||  p_err_code);

               ROLLBACK;
             update   cadtlimp set status = 'E' ;
               RETURN;
            END IF;
        END;


    p_err_code:=0;

  EXCEPTION
  WHEN OTHERS
   THEN

      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error('Row:'||dbms_utility.format_error_backtrace);
      plog.error(SQLERRM);


      RAISE errnums.E_SYSTEM_ERROR;
  END PR_FILE_CADTLIMP;

 PROCEDURE PR_FILE_TBLCA3343 (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    -- cap nhat autoid
    UPDATE tblca3343 SET autoid = seq_tblca3343.NEXTVAL;
--- check du lieu trong file
FOR REC IN
    (SELECT * FROM TBLCA3343 )
LOOP
    IF rec.custodycd IS NOT NULL THEN
        v_count := 0;
        --- check so luu ky co ton tai hay khong?
        SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
        IF v_count = 0 THEN
            UPDATE TBLCA3343 SET deltd = 'Y' , errmsg = errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
        END IF;
        --Check so tieu
        SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno;
        IF v_count = 0 THEN
            UPDATE TBLCA3343 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
        END IF;
        --Check  tieu khoan co phai thuoc so Luu ky
        SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
            AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
        IF v_count = 0 THEN
            UPDATE TBLCA3343 SET deltd = 'Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
        END IF;
        --Check su kien quyen
        SELECT count(camastid) INTO v_count from caschd
        where camastid = replace(rec.camastid,'.','') and afacctno = rec.afacctno;
        IF v_count = 0 THEN
            UPDATE TBLCA3343 SET deltd = 'Y' , errmsg = errmsg ||'Error: camastid invalid!' WHERE autoid = rec.autoid;
        END IF;
    ELSE
        UPDATE TBLCA3343 SET deltd = 'Y' , errmsg =errmsg ||'Error: Custody code invalid!'
        WHERE autoid = rec.autoid;
    END IF ;
END LOOP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
    RETURN;
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCA3343;

PROCEDURE FILLTER_SEC_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    -- Kiem tra neu trung khoa secbaskettemp; Tra ve loi
    BEGIN
    SELECT basketid,symbol, count(1) INTO v_basketid,v_symbol,v_count FROM secbaskettemp
    HAVING count(1) <> 1
    GROUP BY  basketid,symbol;
        -- co 1 truong hop bi trung khoa
        p_err_code := -100407;
        p_err_message:= 'Dupplicate key of secbaskettemp!';
        DELETE FROM SECBASKETTEMP;
        RETURN;
    EXCEPTION
    WHEN no_data_found THEN
        NULL; -- OK khong bi trung khoa
    WHEN OTHERS THEN
        p_err_code := -100407;
        p_err_message:= 'Dupplicate key of secbaskettemp!';
        DELETE FROM SECBASKETTEMP;
        RETURN;
    END;

    -- Kiem tra bracketID da duoc khai bao hay chua?
    SELECT count(1)
        INTO v_count
    FROM secbaskettemp
    WHERE NOT EXISTS (SELECT basketid FROM basket WHERE basket.basketid = secbaskettemp.basketid);
    IF v_count > 0 THEN
        p_err_code := -100406;
        p_err_message:= 'Chua khai bao backetid!';
        DELETE FROM SECBASKETTEMP;
        RETURN;
    END IF;

    SELECT count(1)
        INTO v_count
    FROM secbaskettemp
    WHERE mrratiorate * mrpricerate < mrratioloan * mrpriceloan;
    IF v_count > 0 THEN
        p_err_code := -100435;
        p_err_message:= 'Ti le * Gia vay tinh tai san phai lon hon hoac bang Ti le * Gia vay tinh suc mua!';
        DELETE FROM SECBASKETTEMP;
        RETURN;
    END IF;
     -- Kiem tra ti le vay tren ro nhap vao khong duoc vuot qua ti le toi da cua UBCK
    /*begin
    SELECT count(*)
        INTO v_count
    FROM secbaskettemp;
    end;
    IF v_count > 0 THEN
        SELECT VARVALUE INTO v_IRATIO FROM SYSVAR WHERE GRNAME = 'MARGIN' AND VARNAME = 'IRATIO';
        FOR i IN (SELECT * FROM SECBASKETTEMP)
        LOOP
            IF 100 - i.mrratioloan < v_IRATIO THEN
                p_err_code := -100410;
                p_err_message:= 'Ty le ky quy Margin khong duoc thap hon ty le ky quy cua UBCK!';
                DELETE FROM SECBASKETTEMP;
                RETURN;
            END IF;
        END LOOP;
    END IF;*/
    --Cap nhat thong tin ve nguoi
    UPDATE secbaskettemp SET TellerID=p_tlid;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_SEC_BASKET;

PROCEDURE FILLTER_TBLCHANGEAFTYPE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    --Kiem tra xem so luu ky va tai khoan co ton tai hay khong
    update TBLCHANGEAFTYPE set status ='E', errmsg ='So Luu Ky khong ton tai hoac da dong!' where custodycd not in (select custodycd from cfmast where status <> 'C');
    update TBLCHANGEAFTYPE set status ='E', errmsg ='So Tieu khoan khong ton tai hoac da dong!' where acctno not in (select acctno from afmast where status <> 'C');
    update TBLCHANGEAFTYPE set status ='E', errmsg ='So tieu khoan va ma loai hinh khong dong nhat trong he thong hien tai!'
        where (acctno,oldaftype) not in (select acctno, actype from afmast where status <> 'C');
    update TBLCHANGEAFTYPE set status ='E', errmsg ='Ma loai hinh moi khong hop le!' where newaftype not in (select actype from aftype where status = 'Y' and approvecd ='A');
    UPDATE TBLCHANGEAFTYPE SET tlid=p_tlid, importdt = SYSTIMESTAMP;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_TBLCHANGEAFTYPE;

PROCEDURE CAL_MARGIN_LIMIT (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
BEGIN
RETURN;
END CAL_MARGIN_LIMIT;

PROCEDURE CAL_COP_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_camastid varchar2(30);
v_codeid varchar2(30);
v_symbol varchar2(30);
v_CATYPE VARCHAR2(30) ;
v_RIGHTOFRATE  VARCHAR2(30) ;
v_LEFTOFRATE  VARCHAR2(30) ;
v_OPTCODEID VARCHAR2(30) ;

BEGIN
select  symbol ,TYPE  into v_symbol , v_CATYPE  from  caschd_temp GROUP BY SYMBOL , TYPE  ;

select codeid into v_codeid  from  sbsecurities where symbol =v_symbol;



CASE

--CO TUC BANG TIEN

WHEN v_CATYPE ='010' THEN
v_camastid := '0001'||v_codeid||'000999'  ;
UPDATE CASCHD_TEMP SET CODEID =v_codeid;

FOR REC IN ( select DISTINCT camastid, CODEID , symbol,rate ,to_date(reportdate,'dd/mm/yyyy') reportdate
, to_date(actiondate,'dd/mm/yyyy') actiondate from CASCHD_TEMP)
loop
insert into CAMAST (AUTOID, CODEID, CATYPE, REPORTDATE, DUEDATE, ACTIONDATE, EXPRICE, PRICE, EXRATE, RIGHTOFFRATE, DEVIDENTRATE, DEVIDENTSHARES, SPLITRATE, INTERESTRATE, INTERESTPERIOD, STATUS, CAMASTID, DESCRIPTION, EXCODEID, PSTATUS, RATE, DELTD, TRFLIMIT, PARVALUE, ROUNDTYPE, OPTSYMBOL, OPTCODEID, TRADEDATE, LASTDATE, RETAILSHARE, RETAILDATE, FRDATERETAIL, TODATERETAIL, FRTRADEPLACE, TOTRADEPLACE, TRANSFERTIMES, FRDATETRANSFER, TODATETRANSFER, TASKCD, TOCODEID, LAST_CHANGE)
values (seq_camast.NEXTVAL, rec.codeid, '010', rec.reportdate , to_date('31-05-2010', 'dd-mm-yyyy'), rec.actiondate, 0, 0, '', '', rec.rate, '', '', '', 0, 'A',v_camastid, 'Chia co tuc bang tien,'|| rec.symbol||', ngay chot:'|| rec.reportdate||',  tyle:'||rec.rate||'%', rec.codeid, 'PN', 0, 'N', 'Y', 10000, '0', rec.symbol, '', to_date('31-05-2010', 'dd-mm-yyyy'), null, 'N', to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), '001', '001', '1', to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), '', rec.codeid, '01-JUN-10 05.27.45.437000 PM');
end loop;

FOR REC IN
(
select ca.* ,  af.acctno acctno
from CASCHD_TEMP ca , cfmast cf , afmast af
where ca.afacctno = cf.custodycd and  cf.custid = af.custid
 )
loop

insert into caschd (AUTOID, CAMASTID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS, AFACCTNO, CODEID, EXCODEID, DELTD, PSTATUS, REFCAMASTID, RETAILSHARE, DEPOSIT, REQTTY, REAQTTY, RETAILBAL, PBALANCE, PQTTY, PAAMT, COREBANK, ISCISE, DFQTTY, ISCI, ISSE, ISRO, TQTTY)
values (seq_caschd.nextval, v_camastid, rec.balance, 0, rec.amt, 0, 0, 'A', rec.acctno, rec.codeid, rec.codeid, 'N', '', 0, '', '', 0, 0, 0, 0, 0, 0, 'N', '', 0, 'N', 'N', 'N', 0.00);
end loop;

-- CO TUC BANG CO PHIEU

WHEN v_CATYPE ='011' THEN
v_camastid := '0001'||v_codeid||'000788'  ;
UPDATE CASCHD_TEMP SET CODEID =v_codeid;

FOR REC IN ( select DISTINCT camastid, CODEID , symbol,rate ,to_date(reportdate,'dd/mm/yyyy') reportdate
, to_date(actiondate,'dd/mm/yyyy') actiondate from CASCHD_TEMP)
loop
insert into CAMAST (AUTOID, CODEID, CATYPE, REPORTDATE, DUEDATE, ACTIONDATE, EXPRICE, PRICE, EXRATE, RIGHTOFFRATE, DEVIDENTRATE, DEVIDENTSHARES, SPLITRATE, INTERESTRATE, INTERESTPERIOD, STATUS, CAMASTID, DESCRIPTION, EXCODEID, PSTATUS, RATE, DELTD, TRFLIMIT, PARVALUE, ROUNDTYPE, OPTSYMBOL, OPTCODEID, TRADEDATE, LASTDATE, RETAILSHARE, RETAILDATE, FRDATERETAIL, TODATERETAIL, FRTRADEPLACE, TOTRADEPLACE, TRANSFERTIMES, FRDATETRANSFER, TODATETRANSFER, TASKCD, TOCODEID, LAST_CHANGE)
values (seq_camast.NEXTVAL, rec.codeid, '011', rec.reportdate , to_date('31-05-2010', 'dd-mm-yyyy'), rec.actiondate, 0, 0, '', '','' , rec.rate, '', '', 0, 'A', v_camastid, 'Chia co tuc bang co phieu,'|| rec.symbol||', ngay chot:'|| rec.reportdate||',  ti le'||rec.rate||'%', rec.codeid, 'PN', 0, 'N', 'Y', 10000, '0', rec.symbol, '', to_date('31-05-2010', 'dd-mm-yyyy'), null, 'N', to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), '001', '001', '1', to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), '', rec.codeid, '01-JUN-10 05.27.45.437000 PM');
end loop;

begin
for rec in
(
select ca.* ,  af.acctno acctno
from CASCHD_TEMP ca , cfmast cf , afmast af
where ca.afacctno = cf.custodycd and  cf.custid = af.custid

 )
loop

insert into caschd (AUTOID, CAMASTID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS, AFACCTNO, CODEID, EXCODEID, DELTD, PSTATUS, REFCAMASTID, RETAILSHARE, DEPOSIT, REQTTY, REAQTTY, RETAILBAL, PBALANCE, PQTTY, PAAMT, COREBANK, ISCISE, DFQTTY, ISCI, ISSE, ISRO, TQTTY)
values (seq_caschd.nextval, v_camastid, rec.balance,rec.qtty, rec.amt, 0, 0, 'A', rec.acctno, rec.codeid, rec.codeid, 'N', '', 0, '', '', 0, 0, 0, 0, 0, 0, 'N', '', 0, 'N', 'N', 'N', 0.00);

end loop;
end ;

--CO PHIEU THUONG

WHEN v_CATYPE ='021' THEN

v_camastid := '0001'||v_codeid||'000666'  ;
UPDATE CASCHD_TEMP SET CODEID =v_codeid;

BEGIN
FOR REC IN ( select DISTINCT camastid, CODEID , symbol,rate ,to_date(reportdate,'dd/mm/yyyy') reportdate
, to_date(actiondate,'dd/mm/yyyy') actiondate from CASCHD_TEMP)
loop
insert into CAMAST (AUTOID, CODEID, CATYPE, REPORTDATE, DUEDATE, ACTIONDATE, EXPRICE, PRICE, EXRATE, RIGHTOFFRATE, DEVIDENTRATE, DEVIDENTSHARES, SPLITRATE, INTERESTRATE, INTERESTPERIOD, STATUS, CAMASTID, DESCRIPTION, EXCODEID, PSTATUS, RATE, DELTD, TRFLIMIT, PARVALUE, ROUNDTYPE, OPTSYMBOL, OPTCODEID, TRADEDATE, LASTDATE, RETAILSHARE, RETAILDATE, FRDATERETAIL, TODATERETAIL, FRTRADEPLACE, TOTRADEPLACE, TRANSFERTIMES, FRDATETRANSFER, TODATETRANSFER, TASKCD, TOCODEID, LAST_CHANGE)
values (seq_camast.NEXTVAL, rec.codeid, '021', rec.reportdate , to_date('31-05-2010', 'dd-mm-yyyy'), rec.actiondate, 0, 0, '', '','' , rec.rate, '', '', 0, 'A', v_camastid, 'Co phieu thuong,'|| rec.symbol||', ngay chot:'|| rec.reportdate||',  ti le'||rec.rate||'%', rec.codeid, 'PN', 0, 'N', 'Y', 10000, '0', rec.symbol, '', to_date('31-05-2010', 'dd-mm-yyyy'), null, 'N', to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), '001', '001', '1', to_date('31-05-2010', 'dd-mm-yyyy'), to_date('31-05-2010', 'dd-mm-yyyy'), '', rec.codeid, '01-JUN-10 05.27.45.437000 PM');
end loop;
end;


begin
for rec in
(
select ca.* ,  af.acctno acctno
from CASCHD_TEMP ca , cfmast cf , afmast af
where ca.afacctno = cf.custodycd and  cf.custid = af.custid

 )
loop
insert into caschd (AUTOID, CAMASTID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS, AFACCTNO, CODEID, EXCODEID, DELTD, PSTATUS, REFCAMASTID, RETAILSHARE, DEPOSIT, REQTTY, REAQTTY, RETAILBAL, PBALANCE, PQTTY, PAAMT, COREBANK, ISCISE, DFQTTY, ISCI, ISSE, ISRO, TQTTY)
values (seq_caschd.nextval, v_camastid, rec.balance,rec.qtty,rec.amt , 0, 0, 'A', rec.acctno, rec.codeid, rec.codeid, 'N', '', 0, '', '', 0, 0, 0, 0, 0, 0, 'N', '', 0, 'N', 'N', 'N', 0.00);
end loop;
end ;


-- QUYEN MUA

 WHEN v_CATYPE ='014' THEN
 update CASCHD_TEMP set status ='Y';

 v_camastid := '0001'||v_codeid||'000777'  ;
UPDATE CASCHD_TEMP SET CODEID =v_codeid;
v_OPTCODEID:='99'||substr(v_codeid,3);
UPDATE CASCHD_TEMP SET optCODEID = '99'||substr(v_codeid,3);
---CAMAST
UPDATE CASCHD_TEMP SET OPTCODEID =v_OPTCODEID;
SELECT   SUBSTR( RATE,INSTR(RATE,'/')+1 ) , SUBSTR( RATE,1 ,INSTR(RATE,'/')-1 )  INTO v_RIGHTOFRATE,v_LEFTOFRATE  FROM CASCHD_TEMP GROUP BY RATE;

BEGIN

FOR REC IN ( SELECT DISTINCT CAMASTID,to_date(reportdate,'dd/mm/yyyy') reportdate
, to_date(actiondate,'dd/mm/yyyy') actiondate,SYMBOL,RATE,CODEID,OPTCODEID,EXPRICE FROM CASCHD_TEMP  )
LOOP
INSERT INTO camast
(AUTOID,CODEID,CATYPE,REPORTDATE,DUEDATE,ACTIONDATE,EXPRICE,PRICE,EXRATE,RIGHTOFFRATE,DEVIDENTRATE,DEVIDENTSHARES,SPLITRATE,INTERESTRATE,INTERESTPERIOD,STATUS,CAMASTID,DESCRIPTION,EXCODEID,PSTATUS,RATE,DELTD,TRFLIMIT,PARVALUE,ROUNDTYPE,OPTSYMBOL,OPTCODEID,TRADEDATE,LASTDATE,RETAILSHARE,RETAILDATE,FRDATERETAIL,TODATERETAIL,FRTRADEPLACE,TOTRADEPLACE,TRANSFERTIMES,FRDATETRANSFER,TODATETRANSFER,TASKCD,TOCODEID,LAST_CHANGE)
VALUES
(seq_camast.NEXTVAL,rec.codeid,'014',rec.REPORTDATE,rec.ACTIONDATE,rec.ACTIONDATE,rec.EXPRICE,0,NULL,rec.rate,NULL,NULL,NULL,NULL,0,'M',v_camastid,'Quyen mua co phieu '|| rec.symbol||'DKCC '|| rec.actiondate||'Ty le '|| rec.rate|| ' gia '||rec.EXPRICE,rec.codeid,rec.symbol,0,'N','Y',10000,'0',v_symbol||'_q',rec.OPTCODEID,to_date('10/06/2010','DD/MM/RRRR'),to_date('10/06/2010','DD/MM/RRRR'),'N',to_date('10/06/2010','DD/MM/RRRR'),to_date('10/06/2010','DD/MM/RRRR'),to_date('10/06/2010','DD/MM/RRRR'),'002','001','1',to_date('10/06/2010','DD/MM/RRRR'),to_date('10/06/2010','DD/MM/RRRR'),NULL,rec.codeid,null);

END LOOP;
END;


begin
for rec in
(
select ca.*,af.acctno
from  caschd_temp ca, afmast af , cfmast cf
where ca.afacctno = cf.custodycd
and cf.custid = af.custid
and rightoffqtty =0
)
loop
INSERT INTO caschd
(AUTOID,CAMASTID,BALANCE,QTTY,AMT,AQTTY,AAMT,STATUS,AFACCTNO,CODEID,EXCODEID,DELTD,PSTATUS,REFCAMASTID,RETAILSHARE,DEPOSIT,REQTTY,REAQTTY,RETAILBAL,PBALANCE,PQTTY,PAAMT,COREBANK,ISCISE,DFQTTY,ISCI,ISSE,ISRO,TQTTY)
VALUES
(seq_caschd.nextval,v_camastid,0,0,0,0,0,'A',rec.acctno,rec.codeid,rec.optcodeid,'N',NULL,0,NULL,NULL,0,0,0,rec.balance,rec.qtty,rec.qtty*rec.EXPRICE,'N',NULL,0,'N','N','N',0);

end loop;
end;


begin
for rec in
(
select ca.*,af.acctno
from  caschd_temp ca, afmast af , cfmast cf
where ca.afacctno = cf.custodycd
and cf.custid = af.custid
and rightoffqtty >0)
loop

INSERT INTO caschd
(AUTOID,CAMASTID,BALANCE,QTTY,AMT,AQTTY,AAMT,STATUS,AFACCTNO,CODEID,EXCODEID,DELTD,PSTATUS,REFCAMASTID,RETAILSHARE,DEPOSIT,REQTTY,REAQTTY,RETAILBAL,PBALANCE,PQTTY,PAAMT,COREBANK,ISCISE,DFQTTY,ISCI,ISSE,ISRO,TQTTY)
VALUES
(seq_caschd.nextval,v_camastid,round(rec.rightoffqtty* to_number(v_LEFTOFRATE)/to_number(v_RIGHTOFRATE)),rec.rightoffqtty,0,0,rec.aamt,'M',rec.acctno,rec.codeid,rec.optcodeid,'N',NULL,0,NULL,NULL,0,0,rec.qtty+rec.rightoffqtty,rec.balance-round(rec.rightoffqtty* to_number(v_LEFTOFRATE)/to_number(v_RIGHTOFRATE)),rec.qtty-rec.rightoffqtty,(rec.qtty-rec.rightoffqtty)*rec.exprice,'N',NULL,0,'N','N','N',REC.rightoffqtty);


end loop;
end;

/*
INSERT INTO sbsecurities
(CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE,HALT,SBTYPE,CAREBY,CHKRATE)
VALUES
('99'||substr(v_codeid,3),'0000'||'99'||substr(v_codeid,3),v_symbol||'_q','004','002','001',10000,49,'Y','001','001',0,0,0,NULL,NULL,0,0,'N','001','0001',0);

insert into semast
select '0001',AFACCTNO||EXCODEID,EXCODEID,afacctno,to_date('21/05/2010','DD/MM/RRRR'),NULL,to_date('21/05/2010','DD/MM/RRRR'),'A',NULL,'Y','001',0,4,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,'0001005344',to_date('21/05/2010','DD/MM/RRRR'),0,NULL,'Y',to_date('21/05/2010','DD/MM/RRRR'),0,0,0,0,0,NULL,0,null,0,0,0,0
from caschd where camastid =v_camastid;
*/

END CASE;
update CASCHD_TEMP set status ='C';

exception
when others then
    rollback;
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_message:= 'System error. Invalid file format';

RETURN;
END;


PROCEDURE CAL_SECURITIES_RISK (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
BEGIN
    --backup old secbasket
    insert into SECURITIES_RISKHIST
    (CODEID,MRMAXQTTY,MRRATIORATE,MRRATIOLOAN,MRPRICERATE,MRPRICELOAN,backupdt, ISMARGINALLOW,AFMAXAMT,AFMAXAMTT3,opendate,makerid,action)
    select CODEID,MRMAXQTTY,MRRATIORATE,MRRATIOLOAN,MRPRICERATE,MRPRICELOAN, to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') backupdt, ISMARGINALLOW,AFMAXAMT,AFMAXAMTT3,opendate,makerid,'IMPORT' action
    from SECURITIES_RISK;
    delete from SECURITIES_RISK;
    insert into SECURITIES_RISK
    (CODEID,MRMAXQTTY,MRRATIORATE,MRRATIOLOAN,MRPRICERATE,MRPRICELOAN, ISMARGINALLOW,AFMAXAMT,AFMAXAMTT3,opendate,makerid,status)
    select B.CODEID,MRMAXQTTY,0,0,MRPRICERATE,MRPRICELOAN, ISMARGINALLOW, 99999999999999999,99999999999999999, SYSDATE TXDATE,p_tlid makerid,'A'
    from SECURITIES_RISKTEMP A, SBSECURITIES B WHERE trim(A.SYMBOL)=B.SYMBOL and a.status <>'N';

    update SECURITIES_RISKTEMP set STATUS = 'C', approved='Y', aprid=p_tlid;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END;


PROCEDURE FILLTER_SECURITIES_RISK (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
BEGIN
    --Cap nhat thong tin ve nguoi import
    UPDATE securities_risktemp SET TellerID=p_tlid;
    update securities_risktemp set status ='N', errmsg = '[SYMBOL] DOESN''T EXIST ', deltd = 'Y' where trim(symbol) not in (select symbol from sbsecurities);

    update securities_risktemp set status ='N', errmsg = '[ISMARGINALLOW] IS INVALID ', deltd = 'Y' where nvl(ismarginallow,'A') not in ('N','Y');

    for rec in
    (
        select symbol from securities_risktemp where status <> 'N'  group by symbol having count(1) > 1
    )
    loop
        update securities_risktemp set status = 'N', errmsg = '[CUSTODYCD] IS DUPLICATE ', deltd = 'Y' where symbol=rec.symbol;
    end loop;


    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END;

PROCEDURE CAL_DF_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
BEGIN

    -- Kiem tra bracketID da duoc khai bao hay chua?
    SELECT count(1)
        INTO v_count
    FROM dfbaskettemp
    WHERE NOT EXISTS (SELECT basketid FROM basket WHERE basket.basketid = dfbaskettemp.basketid);
    IF v_count > 0 THEN
        p_err_code := -100406;
        p_err_message:= 'Chua khai bao backetid!';
        RETURN;
    END IF;
    --Xoa di cac dong du lieu khong hop le
     --Sua lai dfrate phai >0
     SELECT count(1)
        INTO v_count
    FROM dfbaskettemp where nvl(refprice,-1) <0 or  nvl(dfprice,-1) <0 or  nvl(triggerprice,-1) <0 or
    nvl(dfrate,-1)<=0  or nvl(irate,-1) <0 or  nvl(mrate,-1)<0 or nvl(lrate,-1)<0;
    IF v_count > 0 THEN
        p_err_code := -100800;
        p_err_message:= 'File du lieu khong hop le!';
        RETURN;
    END IF;

    /* delete from dfbaskettemp where
    nvl(refprice,-1) <0 or  nvl(dfprice,-1) <0 or  nvl(triggerprice,-1) <0 or
    nvl(dfrate,-1)<=0  or nvl(irate,-1) <0 or  nvl(mrate,-1)<0 or nvl(lrate,-1)<0;*/

     --backup old secbasket
    insert into dfbaskethist
    (autoid,basketid, symbol, refprice, dfprice, triggerprice,
       dfrate, irate, mrate, lrate,calltype, importdt,backupdt,DEALTYPE)
    select autoid,basketid, symbol, refprice, dfprice, triggerprice,
       dfrate, irate, mrate, lrate,calltype, importdt,to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') backupdt,DEALTYPE
    from dfbasket where basketid  in (select basketid from dfbaskettemp);

    delete from dfbasket where basketid in (select basketid from dfbaskettemp);

    insert into dfbasket
    (autoid,basketid, symbol, refprice, dfprice, triggerprice,
       dfrate, irate, mrate, lrate,calltype, importdt,DEALTYPE, DFMAXQTTY)
    select SEQ_DFBASKET.NEXTVAL,temp.* from
    (select  basketid, symbol, round(avg(refprice),0), round(avg(dfprice),0), round(avg(triggerprice),0),
           round(avg(dfrate),2), round(avg(irate),2), round(avg(mrate),2), round(avg(lrate),2),max(calltype), to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') importdt,'N' DEALTYPE,MAX(DFMAXQTTY)DFMAXQTTY
        from dfbaskettemp where status <>'N'
    group by basketid, symbol) temp;

        insert into dfbasket
    (autoid,basketid, symbol, refprice, dfprice, triggerprice,
       dfrate, irate, mrate, lrate,calltype, importdt,DEALTYPE, DFMAXQTTY)
    select SEQ_DFBASKET.NEXTVAL,temp.* from
    (select  basketid, symbol, round(avg(refprice),0), round(avg(dfprice),0), round(avg(triggerprice),0),
           round(avg(dfrate),2), round(avg(irate),2), round(avg(mrate),2), round(avg(lrate),2),max(calltype), to_char(sysdate,'DD/MM/YYYY:HH:MI:SS') importdt,'R' DEALTYPE,MAX(DFMAXQTTY)DFMAXQTTY
        from dfbaskettemp where status <>'N'
    group by basketid, symbol) temp;


    update dfbaskettemp set STATUS = 'C', approved='Y', aprid=p_tlid;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END CAL_DF_BASKET;


PROCEDURE FILLTER_DF_BASKET (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
BEGIN

    -- Kiem tra brasketID da duoc khai bao hay chua?
    SELECT count(1)
        INTO v_count
    FROM dfbaskettemp
    WHERE NOT EXISTS (SELECT basketid FROM basket WHERE basket.basketid = dfbaskettemp.basketid);
    IF v_count > 0 THEN
        p_err_code := -100406;
        p_err_message:= 'Chua khai bao basketid!';
        delete from dfbaskettemp;
        RETURN;
    END IF;

    --Danh dau cac dong du lieu khong hop le
    --Sua lai dfrate phai >0
    update dfbaskettemp set status='N',errmsg = 'Ty le khong hop le!' where
    nvl(refprice,-1) <0 or  nvl(dfprice,-1) <0 or  nvl(triggerprice,-1) <0 or
    nvl(dfrate,-1)<=0  or nvl(irate,-1) <0 or  nvl(mrate,-1)<0 or nvl(lrate,-1)<0;

    update dfbaskettemp set errmsg = 'Ty le khong hop le! dfrate phai > 0' where nvl(dfrate,-1)<=0 ;
     --Sua lai dfrate phai >0
    SELECT count(1)
        INTO v_count
    FROM dfbaskettemp where nvl(refprice,-1) <0 or  nvl(dfprice,-1) <0 or  nvl(triggerprice,-1) <0 or
    nvl(dfrate,-1)<=0  or nvl(irate,-1) <0 or  nvl(mrate,-1)<0 or nvl(lrate,-1)<0;
    IF v_count > 0 THEN
        p_err_code := -100800;
        p_err_message:= 'File du lieu khong hop le!';
        RETURN;
    END IF;


    --Cap nhat thong tin ve nguoi import
    UPDATE dfbaskettemp SET TellerID=p_tlid;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_DF_BASKET;


PROCEDURE pr_CashDepositUpload(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2)
 IS
   -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 l_txmsg               tx.msg_rectype;
 l_err_code varchar2(30);
 l_fileid varchar2(100);

BEGIN
      plog.setbeginsection(pkgctx, 'pr_CashDepositUpload');
    l_err_code:= systemnums.C_SUCCESS;
    p_err_code:= systemnums.C_SUCCESS;

    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    -- Lay ra FILE ID
    SELECT max(fileid) INTO l_fileid
    FROM tblcashdeposit
    WHERE autoid IS NULL;

    UPDATE tblcashdeposit
    SET autoid = seq_tblcashdeposit.NEXTVAL, txdate = v_busdate, tltxcd = '1195'
    WHERE fileid = l_fileid;

     -- Huy bo refnum trung lap:
     FOR rec_duplicate IN
     (
        SELECT busdate, bankid, refnum FROM (
            SELECT * FROM tblcashdeposit WHERE deltd <> 'Y'
            UNION ALL
            SELECT th.* FROM tblcashdeposithist th
            --, sysvar s
            WHERE busdate = v_busdate AND deltd <> 'Y'
            --AND s.grname = 'SYSTEM' AND s.varname = 'CURRDATE'
            --AND th.txdate = to_date (s.varvalue,systemnums.c_date_format)
            )
        GROUP BY busdate, bankid, refnum
        HAVING count(1) > 1
     )
     loop
         UPDATE tblcashdeposit
         SET deltd = 'Y',ERRORDESC = '[refnum] HAS BEEN DUPLICATED'
         WHERE busdate = v_busdate AND bankid = rec_duplicate.bankid AND refnum = rec_duplicate.refnum AND status <> 'C'
         and fileid = l_fileid;
     END loop;

     -- kiem tra cac truong mandatory va CHECK gia tri so tien.
     UPDATE tblcashdeposit
     SET deltd = 'Y', errordesc = 'data missing: ' || CASE WHEN bankid IS NULL OR bankid = '' THEN ' [bankid] IS NULL '
                                                         WHEN description IS NULL OR description = '' THEN ' [description] IS NULL '
                                                         WHEN fileid IS NULL OR fileid = '' THEN ' [fileid] IS NULL '
                                                         WHEN busdate IS NULL THEN ' [busdate] IS NULL '
                                                         WHEN amt <= 0 THEN ' [amt] < 0 '
                                                         WHEN busdate <> v_busdate THEN ' [busdate] IS NOT SYSTEM DATE'
                                                         ELSE 'UNKNOWN!' END
     WHERE (bankid IS NULL OR bankid = ''
     OR description IS NULL OR description = ''
     OR fileid IS NULL OR fileid = ''
     OR busdate IS NULL
     OR amt <= 0
     OR busdate <> v_busdate)
     AND fileid = l_fileid;

     -- Kiem tra DELETE het cac dong ko co trong glmast
     UPDATE tblcashdeposit a
     SET deltd = 'Y', errordesc = '[glmast] DOES NOT EXISTS IN SYSTEM'
     WHERE NOT EXISTS (SELECT 1 FROM glmast g,banknostro b WHERE g.acctno = trim(b.glaccount) AND g.actype = 'B' AND a.bankid = b.shortname)
     AND fileid = l_fileid;

     -- xu ly tuan tu
     FOR rec  IN
     (
         SELECT *  FROM tblcashdeposit WHERE fileid = l_fileid AND DELTD<>'Y'
     )
     LOOP

         SELECT count(1) INTO v_count FROM afmast af, cfmast cf
             WHERE cf.custid = af.custid AND cf.custodycd = rec.custodycd and af.status='A' and af.corebank='N';

         IF v_count = 0 then
             UPDATE tblcashdeposit SET deltd = 'Y', errordesc = 'data missing: afacctno not found!'
                    WHERE autoid = rec.autoid;
         ELSE
            UPDATE tblcashdeposit t1
             SET acctno = (  SELECT nvl(  af.acctno,null)
                             FROM afmast af, cfmast cf
                             WHERE cf.custid = af.custid
                             AND cf.custodycd = rec.custodycd
                             AND af.status = 'A'
                             and ROWNUM = 1)
             WHERE autoid = rec.autoid;
         END IF;
/*
         IF rec.acctno IS NULL then
             UPDATE tblcashdeposit  t1
             SET acctno = (  SELECT nvl(  af.acctno,null)
                             FROM afmast af, cfmast cf , tblcashdeposit t2
                             WHERE cf.custid = af.custid
                             AND cf.custodycd = t2.custodycd
                             AND t1.refnum = t2.refnum
                             AND af.status = 'A'
                             and ROWNUM = 1)
             WHERE autoid = rec.autoid
             and acctno is null or acctno = '';
         END IF;
*/




     END LOOP;

    -- Check trung FileID va Refnum

    select count(1) into v_count from (
    select distinct fileid from tblcashdeposit);
    if v_count>1 then
        UPDATE tblcashdeposit SET deltd = 'Y', errordesc = 'fileid: MUST BE UNIQUE';
    end if;

    COMMIT;
     --RETURN systemnums.C_SUCCESS;

     --RUN CHECK.
    FOR rec IN
    (
        SELECT t.*,b.glaccount glmast from tblcashdeposit t, banknostro b
        WHERE t.bankid = b.shortname AND t.deltd <> 'Y' AND t.status <> 'C' AND t.fileid = l_fileid
    )
    LOOP
        -- 1. Set common values
        l_txmsg.brid        := systemnums.c_ho_brid;
        l_txmsg.tlid        := systemnums.c_system_userid;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'AUTO';
        l_txmsg.busdate     := rec.busdate;
        l_txmsg.txdate      := rec.txdate;

        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
        SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
        INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.txfields ('02').VALUE := rec.bankid;
        l_txmsg.txfields ('03').VALUE := rec.acctno;
        l_txmsg.txfields ('06').VALUE := rec.glmast;
        l_txmsg.txfields ('10').VALUE := rec.amt;
        l_txmsg.txfields ('30').VALUE := rec.description;
        l_txmsg.txfields ('31').VALUE := rec.refnum;
        l_txmsg.txfields ('82').VALUE := rec.custodycd;
        l_txmsg.txfields ('99').VALUE := rec.autoid;
        BEGIN
             IF txpks_#1195.fn_txAppCheck(P_TXMSG=>l_txmsg, P_ERR_CODE=>l_err_code) <> systemnums.C_SUCCESS THEN
                 UPDATE tblcashdeposit
                 SET status = 'E',errordesc = l_err_code
                 WHERE autoid = rec.autoid;
                 p_err_code:= errnums.C_SYSTEM_ERROR;
             ELSE
                 UPDATE tblcashdeposit
                 SET status = 'A',errordesc = null
                 WHERE autoid = rec.autoid;
             END IF;
        EXCEPTION
        WHEN OTHERS THEN
            UPDATE tblcashdeposit
            SET status = 'E',errordesc = 'Error in process!'
            WHERE autoid = rec.autoid;
            p_err_code := errnums.C_SYSTEM_ERROR;
        END;


    END LOOP;

EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM);
       ROLLBACK;
        plog.setbeginsection(pkgctx, 'pr_CashDepositUpload');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_param := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;
END pr_CashDepositUpload;





PROCEDURE pr_CFSEUpload (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_param  OUT varchar2)
IS
  -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 l_txmsg               tx.msg_rectype;
 l_err_code varchar2(30);
 l_err_param varchar2(30);
 l_custodycd varchar(10);
 l_tmpcustodycd varchar(10);
 l_custid varchar(10);
 l_afacctno varchar(10);
 l_aftype varchar(3);
 l_citype varchar(4);
BEGIN
      plog.setbeginsection(pkgctx, 'pr_CFSEUpload');

    l_err_code:= systemnums.C_SUCCESS;
    l_err_param:= 'SYSTEM_SUCCESS';
    p_err_code:= systemnums.C_SUCCESS;

    plog.debug(pkgctx, 'BAT DAU CHAY STORE ');

    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    plog.debug(pkgctx, 'BAT DAU UPDATE TBLCFSE ');

    UPDATE tblcfse
    SET autoid = seq_tblcfse.NEXTVAL;

/*
     -- Huy bo refnum trung lap:
     FOR rec_duplicate IN
     (
        SELECT IDCODE FROM (
            SELECT * FROM tblcfse WHERE deltd <> 'Y'
            UNION ALL
            SELECT * FROM tblcfsehist WHERE deltd <> 'Y'
            )
        GROUP BY IDCODE
        HAVING count(1) > 1
     )
     loop
         UPDATE tblcfse
         SET deltd = 'Y',ERRORDESC = '[refnum] HAS BEEN DUPLICATED'
         WHERE IDCODE = rec_duplicate.IDCODE;
     END loop;
*/
       plog.debug(pkgctx, 'BAT DAU UPDATE THONG BAO LOI ');

     -- kiem tra cac truong mandatory va CHECK gia tri so chung khoan.
     UPDATE tblcfse
     SET deltd = 'Y', errordesc = 'data missing: ' ||
        CASE
            WHEN fullname IS NULL OR fullname = '' THEN ' [FULLNAME] IS NULL '
            WHEN idcode IS NULL OR idcode = '' THEN ' [IDCODE] IS NULL '
            WHEN fileid IS NULL OR fileid = '' THEN ' [FILEID] IS NULL '
            WHEN iddate IS NULL OR iddate = '' THEN ' [IDDATE] IS NULL '
            WHEN IDPLACE IS NULL OR IDPLACE = '' THEN ' [IDPLACE] IS NULL '
            WHEN IDTYPE IS NULL OR IDTYPE = '' THEN ' [IDTYPE] IS NULL '
            WHEN COUNTRY IS NULL OR COUNTRY = '' THEN ' [COUNTRY] IS NULL '
            WHEN ADDRESS IS NULL OR ADDRESS = '' THEN ' [ADDRESS] IS NULL '
            WHEN IDTYPE = '005' AND (TAXCODE IS NULL OR TAXCODE = '') THEN ' [TAXCODE] IS NULL '
            WHEN AFTYPE IS NULL OR AFTYPE = '' THEN ' [AFTYPE] IS NULL '
            WHEN BRANCH IS NULL OR AFTYPE = '' THEN ' [BRANCH] IS NULL '
            WHEN CAREBY IS NULL OR CAREBY = '' THEN ' [CAREBY] IS NULL '
            WHEN SEX IS NULL OR SEX = '' THEN ' [SEX] IS NULL '
            WHEN (EXTRACT(YEAR FROM v_busdate)- EXTRACT(YEAR FROM to_date(BIRTHDAY,'DD/MM/RRRR')) < 18) AND (IDTYPE <>'005') THEN '[BIRTHDAY] IS INVALID'
            WHEN QTTY < 0 THEN ' [amt] < 0 '
            WHEN BLOCKQTTY < 0 THEN ' [amt] < 0 '
            WHEN idtype NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='IDTYPE') THEN ' [IDTYPE] DOESN''T EXIST '
            WHEN SEX NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='SEX') THEN ' [SEX] DOESN''T EXIST '
            WHEN COUNTRY NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='COUNTRY') THEN ' [COUNTRY] DOESN''T EXIST '
            WHEN BANKNAME IS NULL OR BANKNAME <>'' OR BANKNAME NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='BANKNAME') THEN ' [BANKNAME] IS INVALID '
            --WHEN QTTYTYPE IS NULL OR QTTYTYPE <>'' OR QTTYType NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='QTTYTYPE') THEN ' [QTTYTYPE] IS INVALID '
            WHEN COUNTRY = '234' AND IDTYPE = '002' THEN ' IDTYPE IS INVALID '
            --WHEN idcode in (SELECT IDCODE FROM CFMAST WHERE CUSTID NOT IN (SELECT CUSTID FROM AFMAST WHERE STATUS NOT IN ('C','N'))) THEN ' CLOSE SUB ACCOUNT FIRST! '
            WHEN TRIM(SYMBOL) NOT IN (SELECT TRIM(SYMBOL) FROM SBSECURITIES) THEN ' [SYMBOL] IS INVALID'
            WHEN TRIM(CAREBY) NOT IN (SELECT GRPID FROM TLGRPUSERS) THEN ' [CAREBY] IS INVALID'
            WHEN TRIM(FILEID) IN (SELECT FILEID FROM TBLCFSEHIST) THEN ' [FILEID] IS INVALID'
            WHEN TRIM(AFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM AFTYPE) THEN ' [AFTYPE] IS INVALID '
            WHEN TRIM(AFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM AFTYPE WHERE STATUS='Y') THEN ' [AFTYPE] IS INVALID '
            WHEN TRIM(AFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM AFTYPE WHERE APPRV_STS='A') THEN ' [AFTYPE] IS INVALID '
            WHEN TRIM(BRANCH) NOT IN (SELECT TRIM(BRID) FROM BRGRP WHERE STATUS='A') THEN ' [BRANCH] IS INVALID '
            WHEN OPNDATE IS NULL OR OPNDATE = '' THEN ' [OPNDATE] IS NULL '
            WHEN TRIM(OPNDATE) NOT IN (SELECT TRIM(SBDATE) FROM SBCLDR WHERE HOLIDAY='N' AND CLDRTYPE='000') THEN ' [OPNDATE] IS A HOLIDAY '
            WHEN TO_DATE(TRIM(OPNDATE),'DD/MM/RRRR') > TO_DATE(v_busdate,'DD/MM/RRRR') THEN ' [OPNDATE] IS IN FUTURE '
            ELSE 'UNKNOWN!'
        END
     WHERE
     idtype IS NULL OR idtype = ''
     OR fullname IS NULL OR fullname = ''
     OR idCODE IS NULL OR idCODE = ''
     OR fileid IS NULL OR fileid = ''
     OR iddate IS NULL OR iddate = ''
     OR IDPLACE IS NULL OR IDPLACE = ''
     OR SEX IS NULL OR SEX = ''
     or COUNTRY IS NULL OR COUNTRY = ''
     or ADDRESS IS NULL OR IDTYPE = ''
     OR (IDTYPE = '005' AND (TAXCODE IS NULL OR TAXCODE = ''))
     or AFTYPE IS NULL OR AFTYPE = ''
     or BRANCH IS NULL OR AFTYPE = ''
     or CAREBY IS NULL OR CAREBY = ''
     OR ((EXTRACT( YEAR FROM v_busdate)- EXTRACT( YEAR FROM to_date(BIRTHDAY,'DD/MM/RRRR')) < 18) AND IDTYPE <>'005')
     OR idtype NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='IDTYPE')
     OR COUNTRY NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='COUNTRY')
     OR (BANKNAME  IS NULL OR BANKNAME <>'' OR BANKNAME NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='BANKNAME'))
     or SEX NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='SEX')
     --OR (QTTYTYPE IS NULL OR QTTYTYPE <>'' OR QTTYType NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='QTTYTYPE') )
     OR (COUNTRY = '234') AND (IDTYPE = '002')
     --OR idcode in (SELECT IDCODE FROM CFMAST WHERE CUSTID NOT IN (SELECT CUSTID FROM AFMAST WHERE STATUS NOT IN ('C','N')))
     OR TRIM(SYMBOL) NOT IN (SELECT TRIM(SYMBOL) FROM SBSECURITIES)
     OR TRIM(CAREBY) NOT IN (SELECT GRPID FROM TLGRPUSERS)
     OR TRIM(FILEID) IN (SELECT FILEID FROM TBLCFSEHIST)
     OR TRIM(AFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM AFTYPE)
     OR TRIM(AFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM AFTYPE WHERE STATUS='Y')
     OR TRIM(AFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM AFTYPE WHERE APPRV_STS='A')
     OR TRIM(BRANCH) NOT IN (SELECT TRIM(BRID) FROM BRGRP WHERE STATUS='A')
     OR OPNDATE IS NULL OR OPNDATE = ''
     OR TRIM(OPNDATE) NOT IN (SELECT TRIM(SBDATE) FROM SBCLDR WHERE HOLIDAY='N' AND CLDRTYPE='000')
     OR TO_DATE(TRIM(OPNDATE),'DD/MM/RRRR') > TO_DATE(v_busdate,'DD/MM/RRRR')
     or QTTY < 0 or BLOCKQTTY < 0
     ;

     select count(1) into v_count from TBLCFSE where DELTD='Y';

     IF V_COUNT>0 THEN
        p_err_code := -100800; --File du lieu dau vao khong hop le
        p_err_param := 'SYSTEM_ERROR';
        RETURN;
     END IF;

     -- xu ly tuan tu
     FOR rec  IN
     (
         SELECT * FROM TBLCFSE WHERE STATUS='P' AND DELTD<>'Y'
     )
     LOOP


         ---- Kiem tra IDCODE xem co trung khong, neu trung chi lam luu ky chu ko sinh trong CFMAST nua
         select count(1) into v_count from cfmast where IDCODE=trim(rec.IDCODE) and status='A';


 --- SINH SO CUSTODYCD
          SELECT decode (rec.country,'234',SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')),'') into l_custodycd FROM
                      (
                      SELECT ROWNUM ODR, INVACCT
                      FROM (SELECT CUSTODYCD INVACCT FROM CFMAST
                      WHERE SUBSTR(CUSTODYCD,1,4)= (SELECT VARVALUE FROM SYSVAR WHERE VARNAME='COMPANYCD'AND GRNAME='SYSTEM') || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                      ORDER BY CUSTODYCD) DAT
                      WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM
                      ) INVTAB
                      GROUP BY SUBSTR(INVACCT,1,4);

            plog.debug(pkgctx, 'Sinh SO LUUKY, CUSTID ' || l_custodycd );

         if v_count=0 then

            ---- SINH SO CUSTID
            SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000'))  into l_custid FROM
                    (SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= trim(rec.branch) ORDER BY CUSTID) DAT
                    WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                    GROUP BY SUBSTR(INVACCT,1,4);


            plog.debug(pkgctx, 'Sinh tai khoan CFMAST');

            --- MO TAI KHOAN
            INSERT INTO CFMAST (CUSTID, CUSTODYCD, FULLNAME, IDCODE, IDDATE, IDPLACE, IDTYPE, COUNTRY, ADDRESS, MOBILE, EMAIL, DESCRIPTION, TAXCODE, OPNDATE,
            CAREBY, BRID, STATUS, PROVINCE, CLASS, GRINVESTOR, INVESTRANGE, POSITION, TIMETOJOIN, STAFF, SEX, SECTOR, FOCUSTYPE ,BUSINESSTYPE,
            INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, LANGUAGE, BANKCODE, MARRIED, ISBANKING, DATEOFBIRTH,CUSTTYPE,OPENVIA)
                    VALUES (l_custid, decode(rec.country,'234',l_custodycd,''), rec.fullname, rec.idcode, rec.iddate, rec.idplace, rec.idtype, rec.country, rec.address,
                    rec.mobile, rec.email, rec.description, rec.taxcode, rec.opndate, rec.careby,rec.branch,'A','--','001','001','001','001','001','005',rec.sex
                    ,'001','001','001','001','001','001','001','001','001','001','N',TO_DATE(rec.birthday,'DD/MM/RRRR'),'I','I');


            -- INSERT VAO MAINTAIN_LOG CFMAST
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID','',l_custid ,'ADD',NULL,NULL);

           INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTODYCD','',l_custodycd ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'FULLNAME','',rec.fullname ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDCODE','',rec.idcode ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDDATE','',rec.iddate ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDPLACE','',rec.idplace ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDTYPE','',rec.idtype ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'COUNTRY','',rec.country,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ADDRESS','',rec.ADDRESS ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MOBILE','',rec.MOBILE ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EMAIL','',rec.EMAIL ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'DESCRIPTION','',rec.DESCRIPTION || '''','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TAXCODE','',rec.TAXCODE ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CAREBY','',rec.CAREBY ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'PROVINCE','','--','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CLASS','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'GRINVESTOR','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'INVESTRANGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'POSITION','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TIMETOJOIN','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TIMETOJOIN','','005','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'SEX','',rec.SEX ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'SECTOR','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'SECTOR','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'FOCUSTYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BUSINESSTYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'INVESTTYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EXPERIENCETYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'INCOMERANGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ASSETRANGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'LANGUAGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKCODE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MARRIED','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ISBANKING','','N','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'DATEOFBIRTH','',to_date(rec.birthday,'DD/MM/RRRR'),'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTTYPE','','I','ADD',NULL,NULL);

            --Update da sinh CFMAST
            UPDATE TBLCFSE SET GENCFMAST='Y' WHERE IDCODE=REC.IDCODE;

         end if;     --- Sinh CFMAST

            plog.debug(pkgctx, 'SINH CFMAST, MAINTAINT_LOG XONG ');

         -- Neu la khach nuoc ngoai thi chi sinh thong tin khach hang (doi xin CUSTODYCD), khong luu ky
         -- Trong truong hop co so luu ky roi thi lam tiep
         if rec.country <> '234' then
             select custodycd into l_tmpcustodycd from cfmast where idcode=trim(rec.idcode) and status='A';
             plog.debug (pkgctx, 'Kiem tra doi voi kh nuoc ngoai: ' || nvl(l_tmpcustodycd,'a'));
             exit when trim(nvl(l_tmpcustodycd,'a'))='a';
         end if;

         ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid in (select custid from cfmast where idcode=trim(rec.IDCODE) and status='A') AND STATUS='A';

         if v_count =0 then

             SELECT AFTYPE INTO l_aftype FROM AFTYPE WHERE ACTYPE= rec.aftype;
             select custid INTO l_custid from cfmast where idcode=trim(rec.IDCODE);

             FOR recMRTYPE  IN
              (
                 SELECT * FROM MRTYPE WHERE ACTYPE IN(SELECT MRTYPE FROM AFTYPE WHERE ACTYPE= rec.aftype  )
              )
              LOOP

                ---- SINH SO AFMAST
                SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')) into l_afacctno FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= trim(rec.branch) ORDER BY ACCTNO) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT,1,4);

                 --- SINH TAI KHOAN AFMAST
                 INSERT INTO AFMAST (ACTYPE,CUSTID,ACCTNO,AFTYPE,
                 BANKACCTNO,BANKNAME,STATUS,
                 ADVANCELINE,DESCRIPTION,
                 ISOTC,PISOTC,OPNDATE,
                 MRIRATE,MRMRATE,MRLRATE,MRCRLIMIT,MRCRLIMITMAX,T0AMT,BRID,CAREBY,AUTOADV,TLID)
                 VALUES(rec.aftype,l_custid,l_afacctno,l_aftype, rec.bankacctno ,rec.bankname,
                 'A',0,rec.description,'N','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),
                 recMRTYPE.MRIRATE,recMRTYPE.MRMRATE,recMRTYPE.MRLRATE,recMRTYPE.MRCRLIMIT,
                 recMRTYPE.MRLMMAX,0,rec.branch, rec.careby,'N', p_tlid);

                    plog.debug(pkgctx, 'Sinh tai khoan AFMAST' || l_afacctno );

                 -- INSERT VAO MAINTAIN_LOG AFMAST
                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACTYPE','',rec.aftype,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID','',l_custid,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACCTNO','',l_afacctno,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CIACCTNO','',l_afacctno,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'AFTYPE','',l_aftype,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEFLOOR','','Y','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADETELEPHONE','','Y','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEONLINE','','Y','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'LANGUAGE','','001','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEPHONE','',rec.mobile,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKACCTNO','',rec.bankacctno,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKNAME','', rec.bankname,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EMAIL','',Rec.email,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ADDRESS','',rec.address,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CAREBY','',rec.careby,'ADD',NULL,NULL);

                ----Update CUSTODYCD cho khach hang
                UPDATE CFMAST SET CUSTODYCD=l_custodycd WHERE IDCODE=rec.idcode and status='A';

                --- lay CITYPE de sinh tai khoan CI
               SELECT CITYPE into l_citype FROM AFTYPE WHERE ACTYPE = rec.aftype ;

                plog.debug(pkgctx,'Insert vao CIMAST: ' || l_afacctno);

                --- Sinh tai khoan CI
                 INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR)
                 VALUES(l_citype,l_afacctno,'00',l_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,'N',0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0);

                --Update da sinh AFMAST
                UPDATE TBLCFSE SET GENAFMAST='Y' WHERE IDCODE=REC.IDCODE;

             END LOOP;
         end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh

         ---- Sinh giao dich luu ky
        select custid INTO l_custid from cfmast where idcode=trim(rec.IDCODE) and status='A';

        FOR rec2240 IN
        (
        SELECT CF.CUSTODYCD CUSTODYCD_CF , AF.ACCTNO, SB.CODEID, A.*  FROM
               CFMAST CF, (
                        SELECT * FROM (
                        SELECT AF.* FROM AFMAST AF, AFTYPE AFT, MRTYPE MR WHERE CUSTID= l_custid AND AF.ACTYPE=AFT.ACTYPE AND
                         AFT.MRTYPE=MR.ACTYPE AND MR.MRTYPE='N'  AND AF.STATUS='A'
                        union

                        SELECT AF.* FROM AFMAST AF, AFTYPE AFT, MRTYPE MR WHERE CUSTID= l_custid AND AF.ACTYPE=AFT.ACTYPE AND
                         AFT.MRTYPE=MR.ACTYPE AND MR.MRTYPE='T'  AND AF.STATUS='A'
                        union

                        SELECT AF.* FROM AFMAST AF, AFTYPE AFT, MRTYPE MR WHERE CUSTID= l_custid AND AF.ACTYPE=AFT.ACTYPE AND
                         AFT.MRTYPE=MR.ACTYPE AND MR.MRTYPE='L'  AND AF.STATUS='A' ) B
                        WHERE ROWNUM=1
                           ) AF,
               TBLCFSE A LEFT JOIN  SBSECURITIES SB ON A.SYMBOL=SB.SYMBOL WHERE
                        A.STATUS='P' AND A.DELTD<>'Y' AND  A.IDCODE=CF.IDCODE AND CF.CUSTID=AF.CUSTID

        )
        LOOP
        plog.debug(pkgctx, 'Sinh gd luu ky'|| rec2240.ACCTNO);
             -- 1. Set common values
             l_txmsg.brid        := substr(rec2240.ACCTNO,1,4);
             l_txmsg.tlid        := systemnums.c_system_userid;
             l_txmsg.off_line    := 'N';
             l_txmsg.deltd       := txnums.c_deltd_txnormal;
             l_txmsg.txstatus    := txstatusnums.c_txcompleted;
             l_txmsg.msgsts      := '0';
             l_txmsg.ovrsts      := '0';
             l_txmsg.batchname   := 'AUTO';
             l_txmsg.busdate     := v_busdate;
             l_txmsg.txdate      := v_busdate;
             l_txmsg.tltxcd      := '2240';

            SELECT systemnums.C_BATCH_PREFIXED || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;

             SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
             INTO l_txmsg.wsname, l_txmsg.ipaddress
             FROM DUAL;

             l_txmsg.txfields ('01').VALUE := rec2240.CODEID;
             l_txmsg.txfields ('88').VALUE := rec2240.CUSTODYCD_CF;
             l_txmsg.txfields ('02').VALUE := rec2240.ACCTNO;
             l_txmsg.txfields ('06').VALUE := rec2240.QTTY;
             l_txmsg.txfields ('07').VALUE := rec2240.BLOCKQTTY;
             IF rec2240.BLOCKQTTY >0 THEN
                l_txmsg.txfields ('08').VALUE := '002';
             ELSE
                l_txmsg.txfields ('08').VALUE := '';
             END IF;

             l_txmsg.txfields ('13').VALUE := rec2240.DATETRADE;
             l_txmsg.txfields ('03').VALUE := rec2240.ACCTNO||rec2240.CODEID;
             l_txmsg.txfields ('04').VALUE := '';
             l_txmsg.txfields ('05').VALUE := '';
             l_txmsg.txfields ('09').VALUE := 0;
             l_txmsg.txfields ('10').VALUE := to_number(rec2240.QTTY) + to_number(rec2240.BLOCKQTTY);
             l_txmsg.txfields ('11').VALUE := 0;
             l_txmsg.txfields ('12').VALUE := '';
             l_txmsg.txfields ('14').VALUE := 0;
             l_txmsg.txfields ('30').VALUE := '';
             l_txmsg.txfields ('66').VALUE := 'Gui luu ky chung khoan';
             l_txmsg.txfields ('82').VALUE := '';
             l_txmsg.txfields ('83').VALUE := '';
             l_txmsg.txfields ('84').VALUE := '';
             l_txmsg.txfields ('89').VALUE := '';
             l_txmsg.txfields ('90').VALUE := '';
             l_txmsg.txfields ('92').VALUE := rec.idcode;
             l_txmsg.txfields ('93').VALUE := '';
             l_txmsg.txfields ('95').VALUE := rec.iddate;
             l_txmsg.txfields ('96').VALUE := rec.idplace;

            plog.debug (pkgctx, 'insert 2240 qtty ' || rec2240.QTTY);

             BEGIN
                --FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)
                  IF txpks_#2240.fn_AutoTxProcess(P_TXMSG=>l_txmsg, p_err_code=>l_err_code,p_err_param=>l_err_param) <> systemnums.C_SUCCESS THEN
                          plog.debug(pkgctx, 'update tblcfse'|| rec2240.ACCTNO);
                      UPDATE TBLCFSE
                      SET status = 'E', custid = l_custid, custodycd = rec2240.CUSTODYCD_CF, afacctno = rec2240.ACCTNO, errordesc = l_err_code
                      WHERE IDCODE = rec2240.IDCODE;
                      p_err_code:= errnums.C_SYSTEM_ERROR;
                  ELSE
                          plog.debug(pkgctx, 'update tblcfse'|| rec2240.ACCTNO);
                      UPDATE TBLCFSE
                      SET status = 'A', custid = l_custid, custodycd = rec2240.CUSTODYCD_CF, afacctno = rec2240.ACCTNO, errordesc = null
                      WHERE IDCODE = rec2240.IDCODE;
                      UPDATE TBLCFSE SET GENSEMAST='Y' WHERE IDCODE=rec2240.IDCODE;
                  END IF;
             EXCEPTION
             WHEN OTHERS THEN
                 UPDATE TBLCFSE
                 SET status = 'E',errordesc = 'Error in process!'
                 WHERE IDCODE = rec2240.IDCODE;
                 p_err_code := errnums.C_SYSTEM_ERROR;
             END;
        END LOOP;

        UPDATE TBLCFSE SET STATUS='A', DELTD='Y' WHERE IDCODE=REC.IDCODE;

    END LOOP;
    plog.debug(pkgctx, 'insert tblcfsehist');
    INSERT INTO TBLCFSEHIST SELECT * FROM TBLCFSE;

    COMMIT;

EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM);
       ROLLBACK;
          plog.setendsection(pkgctx, 'pr_CFSEUpload');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_param := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;
END pr_CFSEUpload;


PROCEDURE pr_Guarantee(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2)
 IS
   -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 v_T0 NUMBER;
 v_USERTYPE varchar2(20);
 l_txmsg tx.msg_rectype;
 l_err_param varchar2(30);
 l_err_code varchar2(30);
 l_fileid varchar2(100);
 v_active varchar2(1);

BEGIN
    plog.setbeginsection(pkgctx, 'pr_Guarantee');
    plog.debug(pkgctx, 'Bat dau vao pr_Guarantee');

    l_err_param:= 'SYSTEM_SUCCESS';
    l_err_code:= systemnums.C_SUCCESS;
    p_err_code:= systemnums.C_SUCCESS;

    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';


    -- Lay ra FILE ID
    SELECT max(fileid) INTO l_fileid
    FROM tblguar
    WHERE autoid IS NULL;

    plog.debug(pkgctx, 'Lay ra file id ' || l_fileid);

    UPDATE tblguar
    SET autoid = seq_tblguar.NEXTVAL;

        -- KIEM TRA CAC TRUONG MANDATORY VA CHECK GIA TRI SO TIEN.
     UPDATE TBLGUAR
     SET DELTD = 'Y', ERRORDESC = 'Data missing: ' || CASE WHEN TLID IS NULL OR TLID = '' THEN ' [TLID] IS NULL '
                                                         WHEN DESCRIPTION IS NULL OR DESCRIPTION = '' THEN ' [DESCRIPTION] IS NULL '
                                                         WHEN FILEID IS NULL OR FILEID = '' THEN ' [FILEID] IS NULL '
                                                         WHEN FILEID IN (SELECT FILEID FROM TBLGUARHIST) THEN ' [FILEID] IS INVALID '
                                                         WHEN TLID NOT IN (SELECT TLID FROM TLPROFILES) THEN ' [TLID] IS INVALID '
                                                         WHEN T0 <= 0 THEN ' [T0] < 0 '
                                                         WHEN T0MAX <= 0 THEN ' [T0MAX] < 0 '
                                                         ELSE 'UNKNOWN!' END
     WHERE (
     DESCRIPTION IS NULL OR DESCRIPTION = ''
     OR FILEID IS NULL OR FILEID = ''
     OR FILEID IN (SELECT FILEID FROM TBLGUARHIST)
     OR TLID NOT IN (SELECT TLID FROM TLPROFILES)
     OR T0 <= 0
     OR T0MAX <= 0
          )
     AND FILEID = L_FILEID;


     select count(1) into v_count from tblguar where DELTD='Y';

     IF V_COUNT>0 THEN
        p_err_code := -100800; --File du lieu dau vao khong hop le
        p_err_param := 'SYSTEM_ERROR';
        RETURN;
     END IF;


    plog.debug(pkgctx, 'Bat dau vong FOR');
     -- xu ly tuan tu
     FOR rec  IN
     (
         SELECT t.autoid,t.fileid,t.tlid,t.username tlusername, t.T0 T0_NEW, T.T0MAX T0MAX_NEW, t.deltd, t.errordesc, t.description, v.*  FROM tblguar t, v_userlimit v
                    WHERE t.fileid = L_FILEID AND nvl(t.DELTD,'N')<>'Y' and v.tliduser=t.tlid
         --select * from tblguar where fileid = l_fileid
     )
     LOOP

        SELECT ACTIVE into v_active  FROM TLPROFILES WHERE TLID = rec.tlid;
          if v_active <> 'Y' then
                UPDATE tblguar SET ERRORDESC = 'Data missing: [ACTIVE] is invalid' where FILEID = L_FILEID AND TLID=rec.tlid;
                exit;
          end if;

        if rec.usertype<>'BO' then

            SELECT NVL(SUM(T0),0) into v_count FROM USERLIMIT,TLPROFILES TL WHERE TLIDUSER(+) = TLID AND TL.idcode in
                (SELECT cf.idcode  idcode FROM CFMAST CF WHERE cf.username = rec.tlid);

            if v_count > 0 then
                UPDATE tblguar SET ERRORDESC = 'Invalid: ERR_CF_USER_BO_ALREADY_ALLOCATE_LIMIT' where FILEID = L_FILEID AND TLID=rec.tlid;
                exit;
            end if;

            SELECT NVL(SUM(ALLOCATELIMMIT),0) into v_count FROM USERLIMIT,TLPROFILES TL WHERE TLIDUSER(+) = TLID AND TL.idcode in
                (SELECT cf.idcode  idcode FROM CFMAST CF WHERE cf.username = rec.tlid);

            if v_count > 0 then
                UPDATE tblguar SET ERRORDESC = 'Invalid: ERR_CF_USER_BO_ALREADY_ALLOCATE_LIMIT' where FILEID = L_FILEID AND TLID=rec.tlid;
                exit;
            end if;

        end if;
/*
        plog.debug(pkgctx, 'Sinh gd 0015');
         -- 1. Set common values
         l_txmsg.brid        := substr(rec.brid,1,4);
         l_txmsg.tlid        := systemnums.c_system_userid;
         l_txmsg.off_line    := 'N';
         l_txmsg.deltd       := txnums.c_deltd_txnormal;
         l_txmsg.txstatus    := txstatusnums.c_txcompleted;
         l_txmsg.msgsts      := '0';
         l_txmsg.ovrsts      := '0';
         l_txmsg.batchname   := 'AUTO';
         l_txmsg.busdate     := v_busdate;
         l_txmsg.txdate      := v_busdate;
         l_txmsg.tltxcd      := '0015';

        SELECT systemnums.C_BATCH_PREFIXED || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

         SELECT SYS_CONTEXT ('USERENV', 'HOST'),
         SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
         INTO l_txmsg.wsname, l_txmsg.ipaddress
         FROM DUAL;

         l_txmsg.txfields ('03').VALUE := rec.tlid;
         l_txmsg.txfields ('04').VALUE := rec.username;
         l_txmsg.txfields ('16').VALUE := rec.T0_NEW;
         l_txmsg.txfields ('17').VALUE := rec.T0;
         l_txmsg.txfields ('18').VALUE := rec.T0MAX_NEW;
         l_txmsg.txfields ('25').VALUE := rec.usertype;
         l_txmsg.txfields ('30').VALUE := rec.description;

        BEGIN
            --FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)
              IF txpks_#0015.fn_AutoTxProcess(P_TXMSG=>l_txmsg, p_err_code=>l_err_code,p_err_param=>l_err_param) <> systemnums.C_SUCCESS THEN
                plog.debug(pkgctx, 'update tblcfse fail');
                  UPDATE TBLGUAR SET STATUS='E',  errordesc = l_err_code WHERE fileid = L_FILEID AND DELTD<>'Y' and tlid=rec.tlid;
                  p_err_code:= errnums.C_SYSTEM_ERROR;
              ELSE
                     plog.debug(pkgctx, 'update tblcfse success');
                     UPDATE TBLGUAR SET STATUS='A',  errordesc = '' WHERE fileid = L_FILEID AND DELTD<>'Y' and tlid=rec.tlid;
              END IF;
         EXCEPTION
         WHEN OTHERS THEN
             UPDATE TBLGUAR SET STATUS='E',  errordesc = 'Error in process!' WHERE fileid = L_FILEID AND DELTD<>'Y' and tlid=rec.tlid;
             p_err_code := errnums.C_SYSTEM_ERROR;
         END;
*/

     END LOOP;


    COMMIT;
     --RETURN systemnums.C_SUCCESS;


EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM);
       ROLLBACK;
        plog.setbeginsection(pkgctx, 'pr_Guarantee');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_param := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;
END pr_Guarantee;

PROCEDURE pr_T0Limit_Import(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2)
is
l_advanceline number(20,0);
begin
    p_err_param:= 'SYSTEM_SUCCESS';
    p_err_code:= systemnums.C_SUCCESS;

    update t0limit_import
    set autoid= seq_t0limit_import.nextval;

    -- Cap nhat gia tri T0limit hien tai vao ban t0limit_import
    update t0limit_import
    set (status, errmsg) = (select case when status <> 'A' then  'E' else 'P' end,case when status <> 'A' then  'CF Status is not valid!' else null end  from cfmast where t0limit_import.custid = cfmast.custid)
    where exists (select 1 from cfmast where t0limit_import.custid = cfmast.custid);
    -- Tong han muc bao lanh da cap cho tieu khoan.
    for rec in
    (
        select * from t0limit_import where status = 'P'
    )
    loop
        update t0limit_import
        set status ='E' , errmsg = 'Contract was not found!'
        where not exists (select 1 from cfmast where cfmast.custid = t0limit_import.custid);

        select sum(advanceline) into l_advanceline from afmast where custid = rec.custid;
        if l_advanceline > rec.t0limit then
            update t0limit_import
            set status ='E' , errmsg = 'Over total AF limited!'
            where autoid = rec.autoid;
        end if;
    end loop;
    update t0limit_import
    set status = 'A'
    where status = 'P';

exception when others then
   plog.error(SQLERRM);
       ROLLBACK;
        plog.setbeginsection(pkgctx, 'pr_Guarantee');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_param := 'SYSTEM_ERROR';
end pr_T0Limit_Import;


PROCEDURE pr_T0AFLimit_Import(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2)
is
l_advanceline number(20,0);
l_t0loanlimit number(20,0);
begin
    p_err_param:= 'SYSTEM_SUCCESS';
    p_err_code:= systemnums.C_SUCCESS;

    update t0aflimit_import
    set autoid= seq_t0aflimit_import.nextval;

    -- Cap nhat gia tri T0limit hien tai vao ban t0limit_import
    update t0aflimit_import
    set (status, errmsg) = (select case when status <> 'A' then  'E' else 'P' end,case when status <> 'A' then  'CF Status is not valid!' else null end  from afmast where t0aflimit_import.AFACCTNO = afmast.acctno)
    where exists (select 1 from afmast where t0aflimit_import.afacctno = afmast.acctno);
    -- Tong han muc bao lanh da cap cho tieu khoan.
    for rec in
    (
        select * from t0aflimit_import where status = 'P'
    )
    loop
        update t0aflimit_import
        set status ='E' , errmsg = 'Contract was not found!'
        where not exists (select 1 from afmast where afmast.acctno = t0aflimit_import.afacctno);

        select max(t0loanlimit), sum(advanceline) into l_t0loanlimit, l_advanceline from afmast af, cfmast cf where af.custid = cf.custid
        and cf.custid in (select custid from afmast where acctno = rec.afacctno)
        group by cf.custid;

        if l_t0loanlimit < l_advanceline + rec.t0limit then
            update t0aflimit_import
            set status ='E' , errmsg = 'Over total AF limited!'
            where autoid = rec.autoid;
        end if;
    end loop;
    update t0aflimit_import
    set status = 'A'
    where status = 'P';

exception when others then
   plog.error(SQLERRM);
       ROLLBACK;
        plog.setbeginsection(pkgctx, 'pr_Guarantee');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_param := 'SYSTEM_ERROR';
end pr_T0AFLimit_Import;



PROCEDURE pr_trfstock(p_tlid IN VARCHAR2, p_err_code out varchar2,p_err_param out varchar2)
 IS
   -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 v_codeid varchar2(6);
 l_txmsg tx.msg_rectype;
 l_err_param varchar2(30);
 l_err_code varchar2(30);
 l_fileid varchar2(100);


BEGIN
    plog.setbeginsection(pkgctx, 'pr_trfstock');
    plog.debug(pkgctx, 'Bat dau vao pr_trfstock');

    l_err_param:= 'SYSTEM_SUCCESS';
    l_err_code:= systemnums.C_SUCCESS;
    p_err_code:= systemnums.C_SUCCESS;

    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';


    -- Lay ra FILE ID
    SELECT max(fileid) INTO l_fileid
    FROM TBLTRFSTOCK
    WHERE autoid IS NULL;

    plog.debug(pkgctx, 'Lay ra file id ' || l_fileid);

    UPDATE TBLTRFSTOCK
    SET autoid = seq_TBLTRFSTOCK.NEXTVAL;

        -- KIEM TRA CAC TRUONG MANDATORY VA CHECK GIA TRI SO TIEN.
     UPDATE TBLTRFSTOCK
     SET DELTD = 'Y', ERRORDESC = 'Data missing: ' || CASE WHEN DESCRIPTION IS NULL OR DESCRIPTION = '' THEN ' [DESCRIPTION] IS NULL '
                                                         WHEN AFACCTNO IS NULL OR AFACCTNO = '' THEN ' [AFACCTNO] IS NULL '
                                                         WHEN AFACCTNO2 IS NULL OR AFACCTNO2 = '' THEN ' [AFACCTNO2] IS NULL '
                                                         WHEN AFACCTNO = AFACCTNO2 THEN ' [AFACCTNO] AND [AFACCTNO2] IS SAME ACCOUNT '
                                                         WHEN AFACCTNO NOT IN (SELECT ACCTNO FROM AFMAST WHERE STATUS IN ('A','N')) THEN ' [AFACCTNO] IS INVALID '
                                                         WHEN AFACCTNO2 NOT IN (SELECT ACCTNO FROM AFMAST WHERE STATUS IN ('A','N')) THEN ' [AFACCTNO2] IS INVALID '
                                                         WHEN SYMBOL NOT IN (SELECT SYMBOL FROM SECURITIES_INFO) THEN '[SYMBOL] IS INVALID'
                                                         WHEN FILEID IS NULL OR FILEID = '' THEN ' [FILEID] IS NULL '
                                                         WHEN FILEID IN (SELECT FILEID FROM TBLTRFSTOCKHIST) THEN ' [FILEID] IS INVALID '
                                                         WHEN QTTY <= 0 THEN ' [QTTY] MUST BE > 0 '
                                                         ELSE 'UNKNOWN!' END
     WHERE (
     DESCRIPTION IS NULL OR DESCRIPTION = ''
     OR FILEID IS NULL OR FILEID = ''
     OR FILEID IN (SELECT FILEID FROM TBLTRFSTOCKHIST)
     OR AFACCTNO IS NULL OR AFACCTNO = ''
     OR AFACCTNO = AFACCTNO2
     OR SYMBOL NOT IN (SELECT SYMBOL FROM SECURITIES_INFO)
     OR AFACCTNO2 IS NULL OR AFACCTNO2 = ''
     OR AFACCTNO NOT IN (SELECT ACCTNO FROM AFMAST WHERE STATUS IN ('A','N'))
     OR AFACCTNO2 NOT IN (SELECT ACCTNO FROM AFMAST WHERE STATUS IN ('A','N'))
     OR QTTY <= 0
          )
     AND FILEID = L_FILEID;



    UPDATE TBLTRFSTOCK SET DELTD = 'Y', ERRORDESC = 'Data missing: ' || '[AFACCTNO] MUST BE SAME CUSTOMER '
     WHERE (AFACCTNO,AFACCTNO2,SYMBOL ) IN (
        SELECT AFACCTNO,AFACCTNO2,SYMBOL FROM (
             SELECT TBL.*, AF.CUSTID FROM TBLTRFSTOCK TBL, AFMAST AF
             WHERE NVL(DELTD,'N')<>'Y' AND FILEID=l_fileid
                AND TBL.AFACCTNO = AF.ACCTNO
             ) TBL, AFMAST AF
        WHERE  TBL.AFACCTNO2 = AF.ACCTNO  AND TBL.CUSTID <> AF.CUSTID );


    UPDATE TBLTRFSTOCK SET DELTD = 'Y', ERRORDESC = 'Data missing: ' || '[SYMBOL] IS INVALID '
    WHERE  NVL(DELTD,'N') <> 'Y' AND  (AFACCTNO,AFACCTNO2,SYMBOL) NOT IN
        (
        SELECT TBL.AFACCTNO,TBL.AFACCTNO2,TBL.SYMBOL FROM TBLTRFSTOCK TBL, SBSECURITIES SB, SEMAST SE
            WHERE TBL.SYMBOL = SB.SYMBOL AND SE.CODEID = SB.CODEID AND  TBL.AFACCTNO = SE.AFACCTNO

         );

 UPDATE TBLTRFSTOCK SET DELTD = 'Y', ERRORDESC = 'Data missing: ' || '[QTTY] IS INVALID '
    WHERE  NVL(DELTD,'N') <> 'Y' AND  (AFACCTNO,AFACCTNO2,SYMBOL) IN
        (
        SELECT TBL.AFACCTNO,TBL.AFACCTNO2,TBL.SYMBOL FROM TBLTRFSTOCK TBL, SBSECURITIES SB, SEMAST SE
            WHERE TBL.SYMBOL = SB.SYMBOL AND SE.CODEID = SB.CODEID AND  TBL.AFACCTNO = SE.AFACCTNO
                AND TBL.QTTY > SE.TRADE
        );


    COMMIT;
     select count(1) into v_count from TBLTRFSTOCK where DELTD='Y';

     IF V_COUNT>0 THEN
        p_err_code := -100800; --File du lieu dau vao khong hop le
        p_err_param := 'SYSTEM_ERROR';
        RETURN;
     END IF;

     --RETURN systemnums.C_SUCCESS;


EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM);
       ROLLBACK;
        plog.setbeginsection(pkgctx, 'pr_trfstock');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_param := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;
END pr_trfstock;






PROCEDURE CAL_OTHERCIACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_COMPANYCD varchar2(100);
v_symbol varchar2(100);
BEGIN
    v_COMPANYCD:=cspks_system.fn_get_sysvar ('SYSTEM', 'COMPANYCD');
    select count(1) into v_count from OTHERCIACCTNO_TEMP where substr(custodycd,1,3) =v_COMPANYCD;
    if v_count>0 then
        p_err_code := -100804;
        p_err_message:= 'Cac tai khoan phai luu ky noi khac!';
        delete from OTHERCIACCTNO_TEMP;
    end if;
    select count(1) into v_count from OTHERCIACCTNO_TEMP where custodycd not in (select custodycd from cfmast where status ='A');
    if v_count>0 then
        p_err_code := -100805;
        p_err_message:= 'Cac tai khoan import phai active trong he thong!';
        delete from OTHERCIACCTNO_TEMP;
    end if;
    for rec in
    (
        select ci.acctno, t.amount
        from OTHERCIACCTNO_TEMP t, cfmast cf, cimast ci
        where t.custodycd= cf.custodycd and cf.custid = ci.custid
    )
    loop
        update afmast set advanceline = rec.amount where acctno = rec.acctno;

    end loop;
    UPDATE OTHERCIACCTNO_TEMP SET STATUS = 'C';
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END CAL_OTHERCIACCTNO_ACTION;

PROCEDURE CAL_OTHERSEACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_COMPANYCD varchar2(100);
v_symbol varchar2(100);
v_currdate date;
BEGIN
    v_COMPANYCD:=cspks_system.fn_get_sysvar ('SYSTEM', 'COMPANYCD');
    v_currdate:= to_date (cspks_system.fn_get_sysvar ('SYSTEM', 'CURRDATE'), 'dd/mm/yyyy');
    select count(1) into v_count from OTHERSEACCTNO_TEMP where substr(custodycd,1,3) =v_COMPANYCD;
    if v_count>0 then
        p_err_code := -100804;
        p_err_message:= 'Cac tai khoan phai luu ky noi khac!';
        delete from OTHERSEACCTNO_TEMP;
    end if;
    select count(1) into v_count from OTHERSEACCTNO_TEMP where custodycd not in (select custodycd from cfmast where status ='A');
    if v_count>0 then
        p_err_code := -100805;
        p_err_message:= 'Cac tai khoan import phai active trong he thong!';
        delete from OTHERSEACCTNO_TEMP;
    end if;
    select count(1) into v_count from OTHERSEACCTNO_TEMP where symbol not in (select symbol from sbsecurities);
    if v_count>0 then
        p_err_code := -100806;
        p_err_message:= 'Ma chung khoan phai ton tai trong he thong!';
        delete from OTHERSEACCTNO_TEMP;
    end if;

    for rec in
    (
        select af.acctno, sb.codeid, t.quantity , typ.setype , cf.custid
        from OTHERSEACCTNO_TEMP t, cfmast cf, afmast af,sbsecurities sb , aftype typ
        where t.custodycd= cf.custodycd and cf.custid = af.custid
            and sb.symbol = t.symbol and af.actype = typ.actype
    )
    loop
        --Kiem tra neu khong co tai khoan chung khoan thi tu dong mo
        select count(1) into v_count from semast where afacctno= rec.acctno and codeid = rec.codeid;
        if v_count <=0 then
            --Mo tai khoan chung khoan
            INSERT INTO semast
                     (actype, custid, acctno,
                      codeid,
                      afacctno, opndate, lastdate,
                      costdt, tbaldt, status, irtied, ircd, costprice, trade,
                      mortage, margin, netting, standing, withdraw, deposit,
                      loan
                     )
              VALUES (rec.setype, rec.custid, rec.acctno || rec.codeid,
                      rec.codeid,
                      rec.acctno, v_currdate, v_currdate,
                      v_currdate, v_currdate, 'A', 'Y', '000', 0, 0,
                      0, 0, 0, 0, 0, 0,
                      0
                     );
        end if;
        update semast set trade = rec.quantity where afacctno = rec.acctno and codeid = rec.codeid;
    end loop;
    UPDATE OTHERSEACCTNO_TEMP SET STATUS = 'C';
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END CAL_OTHERSEACCTNO_ACTION;


PROCEDURE FILLTER_OTHERCIACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_COMPANYCD varchar2(100);
v_symbol varchar2(100);
BEGIN
    v_COMPANYCD:=cspks_system.fn_get_sysvar ('SYSTEM', 'COMPANYCD');
    select count(1) into v_count from OTHERCIACCTNO_TEMP where substr(custodycd,1,3) =v_COMPANYCD;
    if v_count>0 then
        p_err_code := -100804;
        p_err_message:= 'Cac tai khoan phai luu ky noi khac!';
        delete from OTHERCIACCTNO_TEMP;
        return;
    end if;
    select count(1) into v_count from OTHERCIACCTNO_TEMP where custodycd not in (select custodycd from cfmast where status ='A');
    if v_count>0 then
        p_err_code := -100805;
        p_err_message:= 'Cac tai khoan import phai active trong he thong!';
        delete from OTHERCIACCTNO_TEMP;
        return;
    end if;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_OTHERCIACCTNO_ACTION;

PROCEDURE FILLTER_OTHERSEACCTNO_ACTION (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_COMPANYCD varchar2(100);
v_symbol varchar2(100);
v_currdate date;
BEGIN
    v_COMPANYCD:=cspks_system.fn_get_sysvar ('SYSTEM', 'COMPANYCD');
    v_currdate:= to_date (cspks_system.fn_get_sysvar ('SYSTEM', 'CURRDATE'), 'dd/mm/yyyy');
    select count(1) into v_count from OTHERSEACCTNO_TEMP where substr(custodycd,1,3) =v_COMPANYCD;
    if v_count>0 then
        p_err_code := -100804;
        p_err_message:= 'Cac tai khoan phai luu ky noi khac!';
        delete from OTHERSEACCTNO_TEMP;
        return;
    end if;
    select count(1) into v_count from OTHERSEACCTNO_TEMP where custodycd not in (select custodycd from cfmast where status ='A');
    if v_count>0 then
        p_err_code := -100805;
        p_err_message:= 'Cac tai khoan import phai active trong he thong!';
        delete from OTHERSEACCTNO_TEMP;
        return;
    end if;
    select count(1) into v_count from OTHERSEACCTNO_TEMP where symbol not in (select symbol from sbsecurities);
    if v_count>0 then
        p_err_code := -100806;
        p_err_message:= 'Ma chung khoan phai ton tai trong he thong!';
        delete from OTHERSEACCTNO_TEMP;
        return;
    end if;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_OTHERSEACCTNO_ACTION;



PROCEDURE PR_PRSYSTEM_UPLOAD (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
BEGIN
    update prmaster_temp
    set  codeid = (select codeid from sbsecurities where trim(sbsecurities.symbol) = trim(prmaster_temp.symbol)), status = 'P'
    where exists (select 1 from sbsecurities where trim(sbsecurities.symbol) = trim(prmaster_temp.symbol));

    update prmaster_temp
    set  status = 'E',errmsg = 'Stock symbol can not found!'
    where not exists (select 1 from sbsecurities where trim(sbsecurities.symbol) = trim(prmaster_temp.symbol));

    update prmaster_temp
    set  status = 'E',errmsg = 'PrCode and Codeid system is not match!'
    where not exists (select 1 from prmaster where prmaster.prcode = prmaster_temp.prcode and prmaster.codeid = prmaster_temp.codeid);

    update prmaster_temp
    set  status = 'E',errmsg = 'PrCode has invalid format!'
    where length(trim(prcode)) <> 4;

    update prmaster_temp
    set  status = 'E',errmsg = 'PoolRoom type is invalid!'
    where prtyp <> 'R';

    update prmaster_temp
    set status = 'E', errmsg = 'PrCode is duplicated!'
    where exists (select 1 from prmaster_temp having count(1) > 1 group by prcode);

    update prmaster_temp
    set status = 'E', errmsg = 'Symbol is duplicated!'
    where exists (select 1 from prmaster_temp having count(1) > 1 group by symbol);

    update prmaster_temp
    set tlid = p_tlid;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_PRSYSTEM_UPLOAD;

PROCEDURE PR_PRSYSTEM_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
l_count NUMBER;
BEGIN

    for rec in
    (
        select * from prmaster_temp where status = 'P'
    )
    loop
        select count(1) into l_count from prmaster where codeid = rec.codeid;
        if l_count <= 0 then
            insert into prmaster (PRCODE,PRNAME,PRTYP,CODEID,PRLIMIT,PRINUSED,EXPIREDDT,PRSTATUS)
            values( trim(rec.prcode), trim(rec.prname), trim(rec.prtyp), trim(rec.codeid), to_number(rec.prlimit), 0, null, trim(rec.PRSTATUS));
        else
            update prmaster
            set prlimit = to_number(rec.prlimit)
            where codeid = trim(rec.codeid);
        end if;

        update prmaster_temp
        set status  = 'A'
        where prcode = rec.prcode
        and codeid = rec.codeid;
    end loop;

    update prmaster_temp
    set ofid = p_tlid;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_PRSYSTEM_APPROVE;



PROCEDURE PR_ROOM_SYSTEM_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
l_count NUMBER;
v_prinused number;
BEGIN

    -- Kiem tra trung SYMBOL.
    begin
        select count(1)
            into l_count
        from securities_info_import
        having count(1) > 1
        group by trim(symbol);
    exception when others then
        null;
    end;
    if l_count > 0 then
        -- Raise Error Duplicate SYMBOL.
        p_err_code:= '-100436';
        p_err_message:= 'Raise Error Duplicate SYMBOL!';
        delete securities_info_import;
        return;
    end if;

    -- Kiem tra xem co ma chung khoan nao khong ton tai tren het thong khong?
    update securities_info_import
    set status = 'E', errmsg = 'Symbol is not exists on system!'
    where not exists (select 1 from securities_info where trim(securities_info.symbol) = trim(securities_info_import.symbol));

    -- Cap nhat. Day la nguon he thong --> Cac ma khong co trong excel -> reset ve 0
    update securities_info
    set syroomlimit_set = 0
    where  0=0;

    /*Update securities_info
    set syroomlimit = (select roomlimit from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol))
    where exists (select 1 from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol));*/

    for rec in (
        select se.symbol, se.codeid, imp.roomlimit from securities_info_import imp, securities_info se
        where upper(trim(imp.symbol))= trim(se.symbol)
    )
    loop
        begin
            select nvl(afpr.prinused,0) + sb.syroomused into v_prinused
                from securities_info sb,
                       (select codeid, sum(prinused) prinused from vw_afpralloc_all where restype = 'S' group by codeid) afpr
                where sb.codeid = afpr.codeid(+)
                and sb.codeid = rec.codeid;
        exception when others then
            v_prinused:=0;
        end;
         update securities_info
        set syroomlimit = greatest(rec.roomlimit,v_prinused),
            syroomlimit_set = rec.roomlimit
        where codeid = rec.codeid;
    end loop;

    update securities_info_import
    set tlid = p_tlid, status = 'A';

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= dbms_utility.format_error_backtrace || 'System error. Invalid file format';
RETURN;
END PR_ROOM_SYSTEM_APPROVE;


PROCEDURE PR_ROOM_MARGIN_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
l_count NUMBER;
v_prinused number;
BEGIN

    -- Kiem tra trung SYMBOL.
    begin
        select count(1)
            into l_count
        from securities_info_import
        having count(1) > 1
        group by trim(symbol);
    exception when others then
        null;
    end;
    if l_count > 0 then
        -- Raise Error Duplicate SYMBOL.
        p_err_code:= '-100436';
        p_err_message:= 'Raise Error Duplicate SYMBOL!';
        delete securities_info_import;
        return;
    end if;

    -- Kiem tra xem co ma chung khoan nao khong ton tai tren het thong khong?
    update securities_info_import
    set status = 'E', errmsg = 'Symbol is not exists on system!'
    where not exists (select 1 from securities_info where trim(securities_info.symbol) = trim(securities_info_import.symbol));

    -- Cap nhat. Day la nguon margin --> Cac ma khong co trong excel -> giu nguyen
    /*Update securities_info
    set roomlimitmax = (select roomlimit from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol))
    where exists (select 1 from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol));*/

    for rec in (
        select se.symbol, se.codeid, imp.roomlimit from securities_info_import imp, securities_info se
        where upper(trim(imp.symbol))= trim(se.symbol)
    )
    loop
        begin
            select nvl(sum(prinused),0) into v_prinused from vw_afpralloc_all
            where restype = 'M'
            and codeid = rec.codeid;
        exception when others then
            v_prinused:=0;
        end;
        update securities_info
        set roomlimitmax = GREATEST(rec.roomlimit,v_prinused),
            roomlimitmax_set = rec.roomlimit
        where codeid = rec.codeid;
    end loop;

    update securities_info_import
    set tlid = p_tlid, status = 'A';

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_ROOM_MARGIN_APPROVE;



PROCEDURE PR_PRICE_CL_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
l_count NUMBER;
BEGIN

    -- Kiem tra trung SYMBOL.
    begin
        select count(1)
            into l_count
        from securities_info_import
        having count(1) > 1
        group by trim(symbol);
    exception when others then
        null;
    end;
    if l_count > 0 then
        -- Raise Error Duplicate SYMBOL.
        p_err_code:= '-100436';
        p_err_message:= 'Raise Error Duplicate SYMBOL!';
        delete securities_info_import;
        return;
    end if;

    -- Kiem tra xem co ma chung khoan nao khong ton tai tren het thong khong?
    update securities_info_import
    set status = 'E', errmsg = 'Symbol is not exists on system!'
    where not exists (select 1 from securities_info where trim(securities_info.symbol) = trim(securities_info_import.symbol));

    Update securities_info
    set (marginprice,margincallprice) = (select marginprice,margincallprice from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol))
    where exists (select 1 from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol));

    update securities_info_import
    set tlid = p_tlid, status = 'A';

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= dbms_utility.format_error_backtrace || 'System error. Invalid file format';
RETURN;
END PR_PRICE_CL_APPROVE;


PROCEDURE PR_PRICE_MARGIN_APPROVE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
l_count NUMBER;
BEGIN

    -- Kiem tra trung SYMBOL.
    begin
        select count(1)
            into l_count
        from securities_info_import
        having count(1) > 1
        group by trim(symbol);
    exception when others then
        null;
    end;
    if l_count > 0 then
        -- Raise Error Duplicate SYMBOL.
        p_err_code:= '-100436';
        p_err_message:= 'Raise Error Duplicate SYMBOL!';
        delete securities_info_import;
        return;
    end if;

    -- Kiem tra xem co ma chung khoan nao khong ton tai tren het thong khong?
    update securities_info_import
    set status = 'E', errmsg = 'Symbol is not exists on system!'
    where not exists (select 1 from securities_info where trim(securities_info.symbol) = trim(securities_info_import.symbol));

    -- Cap nhat. Day la nguon margin --> Cac ma khong co trong excel -> giu nguyen
    Update securities_info
    set (marginrefprice,marginrefcallprice) = (select marginprice,margincallprice from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol))
    where exists (select 1 from securities_info_import where trim(securities_info.symbol) = trim(securities_info_import.symbol));

    update securities_info_import
    set tlid = p_tlid, status = 'A';

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_PRICE_MARGIN_APPROVE;



/*===IMPORT DU LIEU TU FILE=====
1.TBLCFAF: MO THONG TIN KHACH HANG
2.TBLSE2240: LUU KY CHUNG KHOAN 2240
3.TBLSE2245: NHAN CHUYEN KHOAN CHUNG KHOAN
4.TBLCI1141: NHAN CHUYEN KHOAN TIEN
5.TBLCI1101: CHUYEN TIEN RA NGAN HANG
6.TBLCI1187: CAP NHAT TIEN CHO TK THUOC THANH VIEN LK KHAC
7.TBLSE2287: CAP NHAT CK CHO TK THUOC THANH VIEN LK KHAC
8.TBLSE2203: GIAI TOA CHUNG KHOAN 2203
==============================*/


--1.
PROCEDURE FILLTER_FILE_TBLCFAF(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2)
IS
  -- Enter the procedure variables here. As shown below
   l_tlid varchar2(30);

   v_busdate DATE;
 v_count NUMBER;
 l_err_code varchar2(30);
 l_err_param varchar2(30);
 p_err_param varchar2(30);
 l_custodycd varchar(10);
 l_tmpcustodycd varchar(10);
 l_custid varchar(10);
 l_afacctno varchar(10);
 l_aftype varchar(3);
 l_citype varchar(4);
 l_corebank varchar(1);
 l_autoadv varchar(1);
 L_STRPASS VARCHAR2(20);
 L_STRPASS2 VARCHAR2(20);
 L_STRidcode VARCHAR2(20);
 l_STRtradingcode VARCHAR2(20);
 v_strCFOTHERACCid number(20);

BEGIN
    l_tlid := p_tlid;
    UPDATE tblcfaf SET tlid = p_tlid;
    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    plog.debug(pkgctx, 'BAT DAU UPDATE TBLCFAF ');

    UPDATE tblcfaf
    SET autoid = seq_tblcfaf.NEXTVAL;
    COMMIT;

    plog.debug(pkgctx, 'BAT DAU UPDATE THONG BAO LOI ');

     -- kiem tra cac truong mandatory va CHECK gia tri so chung khoan.
     UPDATE tblcfaf
     SET deltd = 'Y', errmsg = 'data missing: ' ||
        CASE
            WHEN fullname IS NULL OR fullname = '' THEN ' [FULLNAME] IS NULL '
            WHEN idcode IS NULL OR idcode = '' THEN ' [IDCODE] IS NULL '
            WHEN fileid IS NULL OR fileid = '' THEN ' [FILEID] IS NULL '
            WHEN iddate IS NULL OR iddate = '' THEN ' [IDDATE] IS NULL '
            WHEN IDPLACE IS NULL OR IDPLACE = '' THEN ' [IDPLACE] IS NULL '
            WHEN IDTYPE IS NULL OR IDTYPE = '' THEN ' [IDTYPE] IS NULL '
            WHEN COUNTRY IS NULL OR COUNTRY = '' THEN ' [COUNTRY] IS NULL '
            WHEN ADDRESS IS NULL OR ADDRESS = '' THEN ' [ADDRESS] IS NULL '
            WHEN IDTYPE = '005' AND (TAXCODE IS NULL OR TAXCODE = '') THEN ' [TAXCODE] IS NULL '
            WHEN CFTYPE IS NULL OR CFTYPE = '' THEN ' [CFTYPE] IS NULL '
            WHEN BRANCH IS NULL OR BRANCH = '' THEN ' [BRANCH] IS NULL '
            WHEN CAREBY IS NULL OR CAREBY = '' THEN ' [CAREBY] IS NULL '
            WHEN SEX IS NULL OR SEX = '' THEN ' [SEX] IS NULL '
            --WHEN (EXTRACT(YEAR FROM v_busdate)- EXTRACT(YEAR FROM to_date(BIRTHDAY,'DD/MM/RRRR')) < 18) AND (IDTYPE <>'005') THEN '[BIRTHDAY] IS INVALID'
            WHEN idtype NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='IDTYPE') THEN ' [IDTYPE] DOESN''T EXIST '
            WHEN SEX NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='SEX') THEN ' [SEX] DOESN''T EXIST '
            WHEN COUNTRY NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='COUNTRY') THEN ' [COUNTRY] DOESN''T EXIST '
            --WHEN BANKNAME IS NULL OR BANKNAME <>'' OR BANKNAME NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='BANKNAME') THEN ' [BANKNAME] IS INVALID '
            --WHEN QTTYTYPE IS NULL OR QTTYTYPE <>'' OR QTTYType NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='QTTYTYPE') THEN ' [QTTYTYPE] IS INVALID '
            WHEN COUNTRY = '234' AND IDTYPE = '002' THEN ' IDTYPE IS INVALID '
            --WHEN idcode in (SELECT IDCODE FROM CFMAST WHERE CUSTID NOT IN (SELECT CUSTID FROM AFMAST WHERE STATUS NOT IN ('C','N'))) THEN ' CLOSE SUB ACCOUNT FIRST! '
            WHEN TRIM(CAREBY) NOT IN (SELECT GRPID FROM TLGRPUSERS) THEN ' [CAREBY] IS INVALID'
            --WHEN TRIM(FILEID) IN (SELECT FILEID FROM tblcfafHIST) THEN ' [FILEID] IS INVALID'
            WHEN TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE) THEN ' [CFTYPE] IS INVALID '
            WHEN TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE WHERE STATUS='Y') THEN ' [CFTYPE] IS INVALID '
            WHEN TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM cFTYPE WHERE APPRV_STS='A') THEN ' [CFTYPE] IS INVALID '
            WHEN TRIM(BRANCH) NOT IN (SELECT TRIM(BRID) FROM BRGRP ) THEN ' [BRANCH] IS INVALID '
            WHEN TRIM(CUSTODYCD) IN (SELECT CUSTODYCD FROM CFMAST WHERE CUSTODYCD IS NOT NULL) THEN ' [CUSTODYCD] IS EXIST '

             WHEN BIRTHDAY IS NULL OR BRANCH = '' THEN ' [BIRTHDAY] IS NULL '
             WHEN MOBILE IS NULL OR BRANCH = '' THEN ' [MOBILE] IS NULL '
             WHEN OPNDATE IS NULL OR BRANCH = '' THEN ' [OPNDATE] IS NULL '
             WHEN ISONLINE IS NULL OR BRANCH = '' THEN ' [ISONLINE] IS NULL '
             WHEN CUSTTYPE IS NULL OR BRANCH = '' THEN ' [CUSTTYPE] IS NULL '
             WHEN MARGINALLOW IS NULL THEN  ' [MARGINALLOW] IS NULL '
            --WHEN OPNDATE IS NULL OR OPNDATE = '' THEN ' [OPNDATE] IS NULL '
            --WHEN TRIM(OPNDATE) NOT IN (SELECT TRIM(SBDATE) FROM SBCLDR WHERE HOLIDAY='N' AND CLDRTYPE='000') THEN ' [OPNDATE] IS A HOLIDAY '
            --WHEN TO_DATE(TRIM(OPNDATE),'DD/MM/RRRR') > TO_DATE(v_busdate,'DD/MM/RRRR') THEN ' [OPNDATE] IS IN FUTURE '
            ELSE 'UNKNOWN!'
        END
     WHERE
     idtype IS NULL OR idtype = ''
     OR fullname IS NULL OR fullname = ''
     OR idCODE IS NULL OR idCODE = ''
     OR fileid IS NULL OR fileid = ''
     OR iddate IS NULL OR iddate = ''
     OR IDPLACE IS NULL OR IDPLACE = ''
     OR SEX IS NULL OR SEX = ''
     or COUNTRY IS NULL OR COUNTRY = ''
     or ADDRESS IS NULL OR IDTYPE = ''
     OR (IDTYPE = '005' AND (TAXCODE IS NULL OR TAXCODE = ''))
     or CFTYPE IS NULL OR CFTYPE = ''
     or BRANCH IS NULL OR BRANCH = ''
     or CAREBY IS NULL OR CAREBY = ''
     OR idtype NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='IDTYPE')
     OR COUNTRY NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='COUNTRY')
     or SEX NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='SEX')
     OR (COUNTRY = '234') AND (IDTYPE = '002')
     OR TRIM(CAREBY) NOT IN (SELECT GRPID FROM TLGRPUSERS)
     OR TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE)
     OR TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE WHERE STATUS='Y')
     OR TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE WHERE APPRV_STS='A')
     OR TRIM(BRANCH) NOT IN (SELECT TRIM(BRID) FROM BRGRP)
     or TRIM(CUSTODYCD) IN (SELECT CUSTODYCD FROM CFMAST WHERE CUSTODYCD IS NOT NULL)
     OR TRIM(BIRTHDAY) IS NULL OR TRIM(MOBILE) IS NULL  OR TRIM(OPNDATE) IS NULL
     OR TRIM(ISONLINE) IS NULL OR TRIM(CUSTTYPE) IS NULL or TRIM(MARGINALLOW) IS NULL
     /*BIRTHDAY
    MOBILE
    OPNDATE
    ISONLINE
    CUSTTYPE*/
     ;

    for rec in (select * from TBLCFAF )
    loop
        select count(1) into v_count
        from TBLCFAF cfaf where rec.custodycd = cfaf.custodycd and cfaf.autoid <> rec.autoid;
        if v_count > 0 then
            UPDATE tblcfaf SET deltd = 'Y', errmsg = ' [CUSTODYCD] IS DUPLICATE ';
        end if;
    end loop;

    COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM || dbms_utility.format_error_backtrace);
       ROLLBACK;
         plog.setendsection(pkgctx, 'FILLTER_FILE_TBLCFAF');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_message := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;

END FILLTER_FILE_TBLCFAF;

PROCEDURE PR_FILE_TBLCFAF(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
  -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 l_err_code varchar2(30);
 l_err_param varchar2(30);
 p_err_param varchar2(30);
 l_custodycd varchar(10);
 l_tmpcustodycd varchar(10);
 l_custid varchar(10);
 l_afacctno varchar(10);
 l_aftype varchar(3);
 l_citype varchar(4);
 l_corebank varchar(1);
 l_autoadv varchar(1);
 L_STRPASS VARCHAR2(20);
 L_STRPASS2 VARCHAR2(20);
 L_STRidcode VARCHAR2(20);
 l_STRtradingcode VARCHAR2(20);
 v_strCFOTHERACCid number(20);
BEGIN

    l_err_code:= systemnums.C_SUCCESS;
    l_err_param:= 'SYSTEM_SUCCESS';
    p_err_param:='SYSTEM_SUCCESS';
    p_err_code:= systemnums.C_SUCCESS;

    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    plog.debug(pkgctx, 'BAT DAU UPDATE TBLCFAF ');

    UPDATE tblcfaf
    SET autoid = seq_tblcfaf.NEXTVAL;
    COMMIT;

    plog.debug(pkgctx, 'BAT DAU UPDATE THONG BAO LOI ');

     -- kiem tra cac truong mandatory va CHECK gia tri so chung khoan.
     UPDATE tblcfaf
     SET deltd = 'Y', errmsg = 'data missing: ' ||
        CASE
            WHEN fullname IS NULL OR fullname = '' THEN ' [FULLNAME] IS NULL '
            WHEN idcode IS NULL OR idcode = '' THEN ' [IDCODE] IS NULL '
            WHEN fileid IS NULL OR fileid = '' THEN ' [FILEID] IS NULL '
            WHEN iddate IS NULL OR iddate = '' THEN ' [IDDATE] IS NULL '
            WHEN IDPLACE IS NULL OR IDPLACE = '' THEN ' [IDPLACE] IS NULL '
            WHEN IDTYPE IS NULL OR IDTYPE = '' THEN ' [IDTYPE] IS NULL '
            WHEN COUNTRY IS NULL OR COUNTRY = '' THEN ' [COUNTRY] IS NULL '
            WHEN ADDRESS IS NULL OR ADDRESS = '' THEN ' [ADDRESS] IS NULL '
            WHEN IDTYPE = '005' AND (TAXCODE IS NULL OR TAXCODE = '') THEN ' [TAXCODE] IS NULL '
            WHEN CFTYPE IS NULL OR CFTYPE = '' THEN ' [CFTYPE] IS NULL '
            WHEN BRANCH IS NULL OR BRANCH = '' THEN ' [BRANCH] IS NULL '
            WHEN CAREBY IS NULL OR CAREBY = '' THEN ' [CAREBY] IS NULL '
            WHEN SEX IS NULL OR SEX = '' THEN ' [SEX] IS NULL '
            --WHEN (EXTRACT(YEAR FROM v_busdate)- EXTRACT(YEAR FROM to_date(BIRTHDAY,'DD/MM/RRRR')) < 18) AND (IDTYPE <>'005') THEN '[BIRTHDAY] IS INVALID'
            WHEN idtype NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='IDTYPE') THEN ' [IDTYPE] DOESN''T EXIST '
            WHEN SEX NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='SEX') THEN ' [SEX] DOESN''T EXIST '
            WHEN COUNTRY NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='COUNTRY') THEN ' [COUNTRY] DOESN''T EXIST '
            --WHEN BANKNAME IS NULL OR BANKNAME <>'' OR BANKNAME NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='BANKNAME') THEN ' [BANKNAME] IS INVALID '
            --WHEN QTTYTYPE IS NULL OR QTTYTYPE <>'' OR QTTYType NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='QTTYTYPE') THEN ' [QTTYTYPE] IS INVALID '
            WHEN COUNTRY = '234' AND IDTYPE = '002' THEN ' IDTYPE IS INVALID '
            --WHEN idcode in (SELECT IDCODE FROM CFMAST WHERE CUSTID NOT IN (SELECT CUSTID FROM AFMAST WHERE STATUS NOT IN ('C','N'))) THEN ' CLOSE SUB ACCOUNT FIRST! '
            WHEN TRIM(CAREBY) NOT IN (SELECT GRPID FROM TLGROUPS WHERE GRPTYPE = '2') THEN ' [CAREBY] IS INVALID'
            --WHEN TRIM(FILEID) IN (SELECT FILEID FROM tblcfafHIST) THEN ' [FILEID] IS INVALID'
            WHEN TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE) THEN ' [CFTYPE] IS INVALID '
            WHEN TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE WHERE STATUS='Y') THEN ' [CFTYPE] IS INVALID '
            WHEN TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM cFTYPE WHERE APPRV_STS='A') THEN ' [CFTYPE] IS INVALID '
            WHEN TRIM(BRANCH) NOT IN (SELECT TRIM(BRID) FROM BRGRP ) THEN ' [BRANCH] IS INVALID '
            WHEN TRIM(CUSTODYCD) IN (SELECT CUSTODYCD FROM CFMAST WHERE CUSTODYCD IS NOT NULL) THEN ' [CUSTODYCD] IS EXIST '

             WHEN BIRTHDAY IS NULL OR BRANCH = '' THEN ' [BIRTHDAY] IS NULL '
             WHEN MOBILE IS NULL OR BRANCH = '' THEN ' [MOBILE] IS NULL '
             WHEN OPNDATE IS NULL OR BRANCH = '' THEN ' [OPNDATE] IS NULL '
             WHEN ISONLINE IS NULL OR BRANCH = '' THEN ' [ISONLINE] IS NULL '
             WHEN CUSTTYPE IS NULL OR BRANCH = '' THEN ' [CUSTTYPE] IS NULL '
             WHEN MARGINALLOW IS NULL THEN  ' [MARGINALLOW] IS NULL '
            --WHEN OPNDATE IS NULL OR OPNDATE = '' THEN ' [OPNDATE] IS NULL '
            --WHEN TRIM(OPNDATE) NOT IN (SELECT TRIM(SBDATE) FROM SBCLDR WHERE HOLIDAY='N' AND CLDRTYPE='000') THEN ' [OPNDATE] IS A HOLIDAY '
            --WHEN TO_DATE(TRIM(OPNDATE),'DD/MM/RRRR') > TO_DATE(v_busdate,'DD/MM/RRRR') THEN ' [OPNDATE] IS IN FUTURE '
            ELSE 'UNKNOWN!'
        END
     WHERE deltd <> 'Y' AND
     (idtype IS NULL OR idtype = ''
     OR fullname IS NULL OR fullname = ''
     OR idCODE IS NULL OR idCODE = ''
     OR fileid IS NULL OR fileid = ''
     OR iddate IS NULL OR iddate = ''
     OR IDPLACE IS NULL OR IDPLACE = ''
     OR SEX IS NULL OR SEX = ''
     or COUNTRY IS NULL OR COUNTRY = ''
     or ADDRESS IS NULL OR IDTYPE = ''
     OR (IDTYPE = '005' AND (TAXCODE IS NULL OR TAXCODE = ''))
     or CFTYPE IS NULL OR CFTYPE = ''
     or BRANCH IS NULL OR BRANCH = ''
     or CAREBY IS NULL OR CAREBY = ''
     OR idtype NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='IDTYPE')
     OR COUNTRY NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='COUNTRY')
     or SEX NOT IN (SELECT CDVAL FROM ALLCODE WHERE CDNAME='SEX')
     OR (COUNTRY = '234') AND (IDTYPE = '002')
     OR TRIM(CAREBY) NOT IN (SELECT GRPID FROM TLGROUPS WHERE GRPTYPE = '2')
     OR TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE)
     OR TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE WHERE STATUS='Y')
     OR TRIM(CFTYPE) NOT IN (SELECT TRIM(ACTYPE) FROM CFTYPE WHERE APPRV_STS='A')
     OR TRIM(BRANCH) NOT IN (SELECT TRIM(BRID) FROM BRGRP)
     or TRIM(CUSTODYCD) IN (SELECT CUSTODYCD FROM CFMAST WHERE CUSTODYCD IS NOT NULL)
     OR TRIM(BIRTHDAY) IS NULL OR TRIM(MOBILE) IS NULL  OR TRIM(OPNDATE) IS NULL
     OR TRIM(ISONLINE) IS NULL OR TRIM(CUSTTYPE) IS NULL or TRIM(MARGINALLOW) IS NULL)
     ;

    for rec in (select * from TBLCFAF where DELTD<>'Y' )
    loop
        select count(1) into v_count
        from TBLCFAF cfaf where rec.custodycd = cfaf.custodycd and cfaf.autoid <> rec.autoid;
        if v_count > 0 then
            UPDATE tblcfaf SET deltd = 'Y', errmsg = ' [CUSTODYCD] IS DUPLICATE ';
        end if;
    end loop;

     /*select count(1) into v_count from tblcfaf where DELTD='Y';

     IF V_COUNT>0 THEN
        p_err_code := -100800; --File du lieu dau vao khong hop le
        p_err_message := 'SYSTEM_ERROR';
        RETURN;
     END IF;*/

     -- xu ly tuan tu
     FOR rec  IN
     (
         SELECT * FROM tblcfaf WHERE STATUS='P' AND DELTD<>'Y'
     )
     LOOP

        ---- Kiem tra IDCODE xem co trung khong, neu trung chi lam luu ky chu ko sinh trong CFMAST nua
         select count(1) into v_count from cfmast where IDCODE=trim(rec.IDCODE) and status <> 'C';

         if v_count=0 then
                 --- SINH SO CUSTODYCD
                 IF NOT(LENGTH(REC.custodycd) = 10) THEN
                     SELECT decode (rec.country,'234',SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')),'') into l_custodycd FROM
                      (
                      SELECT ROWNUM ODR, INVACCT
                      FROM (SELECT CUSTODYCD INVACCT FROM CFMAST
                      WHERE SUBSTR(CUSTODYCD,1,4)= (SELECT VARVALUE FROM SYSVAR WHERE VARNAME='COMPANYCD'AND GRNAME='SYSTEM') || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                      ORDER BY CUSTODYCD) DAT
                      WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM
                      ) INVTAB
                      GROUP BY SUBSTR(INVACCT,1,4);
                 ELSE
                    l_custodycd := UPPER(REC.custodycd);
                 END IF;


            plog.debug(pkgctx, 'Sinh SO LUUKY, CUSTID ' || l_custodycd );
            ---- SINH SO CUSTID
            SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000'))  into l_custid FROM
                    (SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= trim(rec.branch)
                    UNION ALL
                    SELECT  trim(rec.branch)  || '000001' INVACCT FROM DUAL
                         ORDER BY INVACCT) DAT
                    WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                    GROUP BY SUBSTR(INVACCT,1,4);
            plog.debug(pkgctx, 'Sinh tai khoan CFMAST');

            IF rec.country <> '234' THEN
                L_STRidcode := '';
                l_STRtradingcode := rec.idcode;
            ELSE
                L_STRidcode :=  rec.idcode;
                l_STRtradingcode := '';
            END IF;

            --- MO TAI KHOAN
            INSERT INTO CFMAST (CUSTID, CUSTODYCD, FULLNAME, IDCODE, IDDATE, IDPLACE,IDEXPIRED, IDTYPE, COUNTRY, ADDRESS, mobilesms, EMAIL, DESCRIPTION, TAXCODE, OPNDATE,
            CAREBY, BRID, STATUS, PROVINCE, CLASS, GRINVESTOR, INVESTRANGE, POSITION, TIMETOJOIN, STAFF, SEX, SECTOR, FOCUSTYPE ,BUSINESSTYPE,
            INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, LANGUAGE, BANKCODE, MARRIED, ISBANKING, DATEOFBIRTH,CUSTTYPE,CUSTATCOM,
            mnemonic,valudadded,occupation,education,experiencecd,tlid,risklevel,marginallow,t0loanlimit,commrate,mrloanlimit, ACTYPE, tradingcode,USERNAME, LAST_OFID,APPROVEID, TRADEONLINE,tradingcodedt,OPENVIA, TRADETELEPHONE,PIN)
                    VALUES (l_custid, l_custodycd, rec.fullname, L_STRidcode, rec.iddate, rec.idplace, /*to_date(to_char(rec.iddate,'dd/mm') || to_char(EXTRACT (YEAR from  rec.iddate) + 15),'dd/mm/rrrr') */ ADD_MONTHS(rec.iddate,180), rec.idtype, rec.country, rec.address,
                    rec.mobile, rec.email, rec.description, rec.taxcode, v_busdate, rec.careby,rec.branch,'A','HN','001','000','000','000','000','000',rec.sex
                    ,'000','000','009','000','000','000','000','001','000','004','N',rec.birthday,rec.CUSTTYPE,'Y',
                    nmpks_ems.fn_convert_to_vn(rec.fullname),'000','001','000','00000',rec.tlid,'M',REC.marginallow,10000000000000,100,10000000000000,REC.CFTYPE,l_STRtradingcode,l_custodycd,p_tlid,p_tlid,REC.isonline,rec.iddate,'I',rec.tradetelephone,rec.pin);
            -- INSERT VAO MAINTAIN_LOG CFMAST
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''',rec.tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID','',l_custid ,'ADD',NULL,NULL);

           INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTODYCD','',l_custodycd ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'FULLNAME','',rec.fullname ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDCODE','',rec.idcode ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDDATE','',rec.iddate ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDPLACE','',rec.idplace ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'IDTYPE','',rec.idtype ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'COUNTRY','',rec.country,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ADDRESS','',rec.ADDRESS ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MOBILESMS','',rec.MOBILE ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EMAIL','',rec.EMAIL ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'DESCRIPTION','',rec.DESCRIPTION || '''','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TAXCODE','',rec.TAXCODE ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CAREBY','',rec.CAREBY ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'PROVINCE','','--','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CLASS','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'GRINVESTOR','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'INVESTRANGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'POSITION','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TIMETOJOIN','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TIMETOJOIN','','005','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'SEX','',rec.SEX ,'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'SECTOR','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'SECTOR','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'FOCUSTYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BUSINESSTYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'INVESTTYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EXPERIENCETYPE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'INCOMERANGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ASSETRANGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'LANGUAGE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKCODE','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MARRIED','','001','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ISBANKING','','N','ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'DATEOFBIRTH','',to_date(rec.birthday,'DD/MM/RRRR'),'ADD',NULL,NULL);

            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTTYPE','',rec.CUSTTYPE,'ADD',NULL,NULL);

            --MNEMONIC,
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MNEMONIC','','','ADD',NULL,NULL);
            --VALUDADDED='000'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'VALUDADDED','','000','ADD',NULL,NULL);

            --OCCUPATION='001'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'OCCUPATION','','001','ADD',NULL,NULL);

            --EDUCATION='000'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EDUCATION','','000','ADD',NULL,NULL);

            --EXPERIENCECD='00000'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EXPERIENCECD','','00000','ADD',NULL,NULL);

            --TLID='0001'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TLID','','0001','ADD',NULL,NULL);

            --RISKLEVEL='O'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'RISKLEVEL','','O','ADD',NULL,NULL);

            --MARGINALLOW='Y'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MARGINALLOW','','Y','ADD',NULL,NULL);

            --T0LOANLIMIT=10000000000000
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'T0LOANLIMIT','','10000000000000','ADD',NULL,NULL);

            --COMMRATE=100
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'COMMRATE','','100','ADD',NULL,NULL);

            --T0LOANLIMIT=10000000000000
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'MRLOANLIMIT','','10000000000000','ADD',NULL,NULL);

             --TRADETELEPHONE='N'
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADETELEPHONE','','N','ADD',NULL,NULL);

              --TRADEONLINE
            INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', rec.tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEONLINE','',REC.isonline,'ADD',NULL,NULL);

            --Update da sinh CFMAST
            --UPDATE tblcfaf SET GENCFMAST='Y' WHERE IDCODE=REC.IDCODE;
         else
            UPDATE tblcfaf set errmsg = errmsg ||'Trung so CMND', deltd ='Y' where autoid = rec.autoid;
         end if;     --- Sinh CFMAST

            plog.debug(pkgctx, 'SINH CFMAST, MAINTAINT_LOG XONG ');

         -- Neu la khach nuoc ngoai thi chi sinh thong tin khach hang (doi xin CUSTODYCD), khong luu ky
         -- Trong truong hop co so luu ky roi thi lam tiep
        /* if rec.country <> '234' then
             select custodycd into l_tmpcustodycd from cfmast where idcode=trim(rec.idcode) and status <> 'C';
             plog.debug (pkgctx, 'Kiem tra doi voi kh nuoc ngoai: ' || nvl(l_tmpcustodycd,'a'));
             exit when trim(nvl(l_tmpcustodycd,'a'))='a';
         end if;*/

         ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid = l_custid;

         if v_count =0 then
           cspks_cfproc.pr_AutoOpenNormalAccount(l_custid,'Y',p_err_code);
         END IF;
         if rec.FATCA = 'Y'  THEN
             INSERT INTO FATCA (CUSTID,ISUSCITIZEN,ISUSPLACEOFBIRTH,ISUSMAIL,ISUSPHONE,ISUSTRANFER,ISAUTHRIGH,ISSOLEADDRESS,OPNDATE,ISDISAGREE,ISOPPOSITION,ISUSSIGN,REOPNDATE,W9ORW8BEN,FULLNAME,ROOMNUMBER,CITY,STATE,NATIONAL,ZIPCODE,ISSSN,ISIRS,OTHER,W8MAILROOMNUMBER,W8MAILCITY,W8MAILSTATE,W8MAILNATIONAL,W8MAILZIPCODE,IDENUMTAX,FOREIGNTAX,REF,FIRSTCALL,FIRSTNOTE,SECONDCALL,SECONDNOTE,THIRTHCALL,THIRTHNOTE,ISUS,SIGNDATE,NOTE)
             VALUES(l_custid,'N','N','N','N','N','N','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'N','N','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'W8',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,TO_DATE( v_busdate ,'DD/MM/RRRR'),NULL,TO_DATE( v_busdate ,'DD/MM/RRRR'),NULL,TO_DATE( v_busdate ,'DD/MM/RRRR'),NULL,'N',TO_DATE( v_busdate ,'DD/MM/RRRR'),NULL);
         end if;

         SELECT COUNT(1) INTO v_count FROM USERLOGIN WHERE USERNAME = l_custodycd AND STATUS = 'A';
         if v_count = 0 AND REC.isonline = 'Y' then
           select cspks_system.fn_passwordgenerator(6)  , cspks_system.fn_passwordgenerator(6) INTO
             L_STRPASS, L_STRPASS2
           from dual;

           INSERT INTO USERLOGIN (USERNAME, LOGINPWD, AUTHTYPE, TRADINGPWD, STATUS,
            LASTLOGIN, LOGINSTATUS, LASTCHANGED, NUMBEROFDAY, ISMASTER, ISRESET, TOKENID)
            SELECT l_custodycd, GENENCRYPTPASSWORD(L_STRPASS),'1', GENENCRYPTPASSWORD(L_STRPASS2),
            'A',SYSDATE,'O',SYSDATE,30,'N','Y',' ' TOKENID FROM CFMAST where custid = l_custid;

            INSERT INTO OTRIGHT (AUTOID, CFCUSTID, AUTHCUSTID, AUTHTYPE, VALDATE, EXPDATE, DELTD, LASTCHANGE, SERIALTOKEN)
            (SELECT SEQ_OTRIGHT.NEXTVAL, l_custid, l_custid,
            1, getcurrdate, TO_DATE(getcurrdate + 7300,'DD/MM/RRRR'), 'N', getcurrdate, ' ' FROM DUAL);

            INSERT INTO OTRIGHTMEMO (AUTOID, CFCUSTID, AUTHCUSTID, AUTHTYPE, VALDATE, EXPDATE, DELTD, LASTCHANGE, SERIALTOKEN)
            (SELECT SEQ_OTRIGHT.NEXTVAL, l_custid, l_custid,
            1, getcurrdate, TO_DATE(getcurrdate + 7300,'DD/MM/RRRR'), 'N', getcurrdate, ' ' FROM DUAL);

            INSERT INTO emaillog (autoid, email, templateid, datasource, status,afacctno ,createtime)
            VALUES(seq_emaillog.nextval,rec.email,'0212',
            'select ''' || l_custodycd || ''' username, ''' || L_STRPASS || ''' loginpwd ,''' || L_STRPASS2 || ''' tradingpwd from dual',
            'A', l_custodycd ,SYSDATE);

          /*  INSERT INTO emaillog (autoid, email, templateid, datasource, status,afacctno ,createtime)
            VALUES(seq_emaillog.nextval,rec.mobile,'304B',
            'select ''' || l_custodycd || ''' username, ''' || L_STRPASS || ''' loginpwd ,''' || L_STRPASS2 || ''' tradingpwd from dual','A',l_custodycd,SYSDATE);*/
         END IF;
         if nvl(length(trim(rec.person)),0) > 0 then
            INSERT INTO cfcontact (AUTOID,CUSTID,TYPE,PERSON,ADDRESS,PHONE,FAX,EMAIL,DESCRIPTION)
            VALUES(seq_cfcontact.nextval,l_custid,'001',trim(rec.person),trim(rec.personadd),trim(rec.phone),NULL,NULL,'Tai khoan mo tu importfile');
         end if;
         if nvl(length(trim(rec.bankacc)),0) > 0 then
            select seq_cfotheracc.NEXTVAL into v_strCFOTHERACCid from dual;
            INSERT INTO CFOTHERACC (AUTOID,CFCUSTID,CIACCOUNT,CINAME,CUSTID,BANKACC,BANKACNAME,BANKNAME,TYPE,ACNIDCODE,ACNIDDATE,ACNIDPLACE,FEECD,CITYEF,CITYBANK,BANKCODE)
            VALUES(v_strCFOTHERACCid,l_custid,NULL,NULL,NULL,trim(rec.bankacc),rec.fullname,trim(rec.bankname),'1',rec.idcode,rec.iddate,rec.idplace,NULL,trim(rec.cityef),trim(rec.citybank),trim(rec.bankcode));

            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
            values ('CFMAST', 'CUSTID = '''||l_custid||'''',rec.tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 'Y', p_tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 0, 'CFCUSTID', null, l_custid, 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
            values ('CFMAST', 'CUSTID = '''||l_custid||'''',rec.tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 'Y', p_tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 0, 'BANKACC', null, trim(rec.bankacc), 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
            values ('CFMAST', 'CUSTID = '''||l_custid||'''',rec.tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 'Y', p_tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 0, 'BANKNAME', null, trim(rec.bankname), 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
            values ('CFMAST', 'CUSTID = '''||l_custid||'''',rec.tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 'Y', p_tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 0, 'CITYBANK', null, trim(rec.citybank), 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
            values ('CFMAST', 'CUSTID = '''||l_custid||'''',rec.tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 'Y', p_tlid, TO_DATE( v_busdate ,'DD/MM/RRRR'), 0, 'BANKCODE', null, trim(rec.bankcode), 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

         end if;
/*
             l_corebank:='N';
             l_autoadv:='N';*/

             /*SELECT AFTYPE INTO l_aftype FROM AFTYPE WHERE ACTYPE= rec.aftype;
             SELECT corebank into  l_corebank FROM AFTYPE WHERE ACTYPE= rec.aftype;
             SELECT autoadv into  l_autoadv FROM AFTYPE WHERE ACTYPE= rec.aftype;*/

             /*select custid INTO l_custid from cfmast where idcode=trim(rec.IDCODE);

             FOR recMRTYPE  IN
              (
                 SELECT * FROM MRTYPE WHERE ACTYPE IN(SELECT MRTYPE FROM AFTYPE WHERE ACTYPE= rec.aftype  )
               )
              LOOP

                ---- SINH SO AFMAST
                  SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000')) into l_afacctno FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= trim(rec.branch) ORDER BY ACCTNO) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT,1,4);

                 --- SINH TAI KHOAN AFMAST
                 INSERT INTO AFMAST (ACTYPE,CUSTID,ACCTNO,AFTYPE,
                 BANKACCTNO,BANKNAME,STATUS,
                 ADVANCELINE,DESCRIPTION,ISOTC,PISOTC,OPNDATE,VIA,
                 MRIRATE,MRMRATE,MRLRATE,MRCRLIMIT,MRCRLIMITMAX,T0AMT,BRID,CAREBY,corebank,AUTOADV,TLID,TERMOFUSE)
                 VALUES(rec.aftype,l_custid,l_afacctno,l_aftype, rec.bankacctno ,'---', 'P',0,rec.description,'N','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'F',
                 recMRTYPE.MRIRATE,recMRTYPE.MRMRATE,recMRTYPE.MRLRATE,recMRTYPE.MRCRLIMIT,
                 recMRTYPE.MRLMMAX,0,rec.branch, rec.careby,l_corebank,l_AUTOADV, p_tlid,'001');

                 plog.debug(pkgctx, 'Sinh tai khoan AFMAST' || l_afacctno );

                 -- INSERT VAO MAINTAIN_LOG AFMAST
                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACTYPE','',rec.aftype,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID','',l_custid,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACCTNO','',l_afacctno,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CIACCTNO','',l_afacctno,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'AFTYPE','',l_aftype,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEFLOOR','','Y','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADETELEPHONE','','Y','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEONLINE','','Y','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'LANGUAGE','','001','ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TRADEPHONE','',rec.mobile,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKACCTNO','',rec.bankacctno,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKNAME','', rec.bankname,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'EMAIL','',Rec.email,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ADDRESS','',rec.address,'ADD',NULL,NULL);

                 INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,
                 FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
                 VALUES('AFMAST','ACCTNO = ''' || l_afacctno || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
                  p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CAREBY','',rec.careby,'ADD',NULL,NULL);

                ----Update CUSTODYCD cho khach hang
                UPDATE CFMAST SET CUSTODYCD=l_custodycd WHERE IDCODE=rec.idcode and status='A';

                --- lay CITYPE de sinh tai khoan CI
               SELECT CITYPE into l_citype FROM AFTYPE WHERE ACTYPE = rec.aftype ;

                plog.debug(pkgctx,'Insert vao CIMAST: ' || l_afacctno);
*/
                --- Sinh tai khoan CI
                --- INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR)
                --- VALUES(l_citype,l_afacctno,'00',l_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,l_corebank,0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0);

                --Update da sinh AFMAST
               -- UPDATE tblcfaf SET GENAFMAST='Y' WHERE IDCODE=REC.IDCODE;

             /*END LOOP;
         end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh*/


        --UPDATE tblcfaf SET STATUS='A', DELTD='Y' WHERE IDCODE=REC.IDCODE;
        UPDATE tblcfaf SET STATUS='A' WHERE AUTOID = REC.AUTOID;
        INSERT INTO tblcfafHIST SELECT * FROM tblcfaf where STATUS='A' and deltd ='N' and autoid =  REC.AUTOID ;

    END LOOP;
    plog.debug(pkgctx, 'insert tblcfafhist');

    COMMIT;

EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM || dbms_utility.format_error_backtrace);
       ROLLBACK;
         plog.setendsection(pkgctx, 'PR_FILE_TBLCFAF');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_message := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;

END PR_FILE_TBLCFAF;

PROCEDURE PR_FILE_CFOTHERACC(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
  -- Enter the procedure variables here. As shown below
 v_busdate DATE;
 v_count NUMBER;
 l_err_code varchar2(30);
 l_err_param varchar2(30);
 p_err_param varchar2(30);
 l_custodycd varchar(10);
 l_tmpcustodycd varchar(10);
 l_custid varchar(10);
 l_afacctno varchar(10);
 l_aftype varchar(3);
 l_citype varchar(4);
 l_corebank varchar(1);
 l_autoadv varchar(1);
 L_STRPASS VARCHAR2(20);
 L_STRPASS2 VARCHAR2(20);
 L_STRidcode VARCHAR2(20);
 l_STRtradingcode VARCHAR2(20);
 L_AUTOID       VARCHAR2(20);
BEGIN

    l_err_code:= systemnums.C_SUCCESS;
    l_err_param:= 'SYSTEM_SUCCESS';
    p_err_param:='SYSTEM_SUCCESS';
    p_err_code:= systemnums.C_SUCCESS;

    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    UPDATE TBL_CFOTHERACC
    SET autoid = SEQ_TBL_CFOTHERACC.NEXTVAL, custodycd = trim(custodycd), bankacc = trim(bankacc), bankcode = trim(bankcode);
    COMMIT;

     -- kiem tra cac truong mandatory va CHECK gia tri so chung khoan.
    --- DOESN''T EXIST
    for rec in (select * from TBL_CFOTHERACC )
    loop
        select count(1) into v_count
        from TBL_CFOTHERACC cfaf where rec.custodycd = cfaf.custodycd and cfaf.autoid <> rec.autoid;
        if v_count > 0 then
            UPDATE TBL_CFOTHERACC SET deltd = 'Y', errmsg = errmsg || ' [CUSTODYCD] IS DUPLICATE ';
        end if;

        select count(1) into v_count
        from CFMAST CF where CF.CUSTODYCD = REC.custodycd ;
        IF v_count < 1 THEN
            UPDATE TBL_CFOTHERACC SET deltd = 'Y', errmsg = errmsg || ' [CUSTODYCD] NOT EXIST ';
        END IF;

        IF REC.BANKACC IS NULL THEN
            UPDATE TBL_CFOTHERACC SET deltd = 'Y', errmsg = errmsg || ' [BANKACC] IS NULL ';
        END IF;


            IF REC.BANKCODE IS NULL THEN
                IF REC.BANKNAME IS NULL THEN
                    UPDATE TBL_CFOTHERACC SET deltd = 'Y', errmsg = errmsg || ' [BANKCODE] AND [BANKNAME] IS NULL ';
                END IF;
            ELSE
                SELECT COUNT(1) INTO V_COUNT FROM CRBBANKLIST WHERE BANKCODE = REC.BANKCODE;
                IF V_COUNT < 1 THEN
                    UPDATE TBL_CFOTHERACC SET deltd = 'Y', errmsg = errmsg || ' [BANKCODE] IS INVALID ';
                END IF;
            END IF;


        SELECT COUNT(1) INTO V_COUNT FROM CFOTHERACC CFOT, CFMAST CF
        WHERE CFOT.CFCUSTID = CF.CUSTID AND CF.CUSTODYCD = REC.CUSTODYCD AND CFOT.BANKACC = REC.BANKACC;
        IF V_COUNT > 0 THEN
            UPDATE TBL_CFOTHERACC SET DELTD = 'Y', ERRMSG = ERRMSG || ' CFOTHERACC IS EXIST ';
        END IF;

    end loop;

     -- xu ly tuan tu
     FOR rec  IN
     (
         ---SELECT * FROM TBL_CFOTHERACC WHERE STATUS = 'P' AND DELTD <> 'Y'
        SELECT CF.CUSTID CUSTID, CFOT.BANKACC BANKACC, NVL(CRB.BANKNAME,CFOT.BANKNAME) BANKNAME, CF.IDCODE IDCODE, CF.IDDATE IDDATE,
            CF.IDPLACE IDPLACE, CFOT.CITYEF CITYEF, CFOT.CITYBANK CITYBANK, CFOT.AUTOID AUTOID, CF.FULLNAME FULLNAME, CFOT.BANKCODE BANKCODE
        FROM TBL_CFOTHERACC CFOT, CFMAST CF, CRBBANKLIST CRB
        WHERE CFOT.CUSTODYCD = CF.CUSTODYCD
            AND NVL(CFOT.STATUS,'P') = 'P' AND NVL(CFOT.DELTD,'N') <> 'Y'
            AND CFOT.BANKCODE = CRB.BANKCODE(+)
     )
     LOOP
        --- MO TAI KHOAN
        L_AUTOID := SEQ_CFOTHERACC.NEXTVAL;
        INSERT INTO CFOTHERACC (AUTOID,CFCUSTID,CIACCOUNT,CINAME,CUSTID,BANKACC,BANKACNAME,BANKNAME,TYPE,ACNIDCODE,ACNIDDATE,ACNIDPLACE,FEECD,CITYEF,CITYBANK,BANKCODE)
        VALUES(L_AUTOID,REC.CUSTID,NULL,NULL,REC.CUSTID,REC.BANKACC,REC.FULLNAME,REC.BANKNAME,'1',REC.IDCODE,REC.IDDATE,REC.IDPLACE,NULL,REC.CITYEF,REC.CITYBANK,REC.BANKCODE);

        /*
        INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
            VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
             p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'COMMRATE','','100','ADD',NULL,NULL);
        */
        --- INSERT VAO MAINTAIN_LOG CFMAST
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CFCUSTID',NULL,REC.CUSTID,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CUSTID',NULL,REC.CUSTID,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'TYPE',NULL,'1','ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKACC',NULL,REC.BANKACC,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKCODE',NULL,REC.BANKCODE,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKACNAME',NULL,REC.FULLNAME,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CITYEF',NULL,REC.CITYEF,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'CITYBANK',NULL,REC.CITYBANK,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'BANKNAME',NULL,REC.BANKNAME,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACNIDCODE',NULL,REC.IDCODE,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACNIDPLACE',NULL,REC.IDPLACE,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CFMAST','CUSTID = ''' || REC.CUSTID || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),0,'ACNIDDATE',NULL,REC.IDDATE,'ADD','CFOTHERACC','AUTOID = ''' || L_AUTOID || '''',NULL,NULL);
        --- BACKUP
        UPDATE TBL_CFOTHERACC SET STATUS='A' WHERE AUTOID = REC.AUTOID;
        INSERT INTO TBL_CFOTHERACCHIST (SELECT * FROM TBL_CFOTHERACC WHERE AUTOID = REC.AUTOID);
    END LOOP;
    COMMIT;

EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM || dbms_utility.format_error_backtrace);
       ROLLBACK;
         plog.setendsection(pkgctx, 'PR_FILE_CFOTHERACC');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_message := 'SYSTEM_ERROR';
END PR_FILE_CFOTHERACC;


--2.
PROCEDURE PR_FILE_TBLSE2240(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid varchar2(10);
v_acctno varchar2(20);
v_qtty NUMBER;
BEGIN
v_codeid:= '';
v_count:=0;
--Cap nhat autoid
UPDATE tblse2240 SET autoid = seq_tblse2240.NEXTVAL;
-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLSE2240 )
    LOOP
    IF rec.symbol IS NOT NULL THEN
        select count(codeid) into v_count from sbsecurities WHERE symbol = rec.symbol;
        IF v_count = 0 THEN
          UPDATE TBLSE2240 SET deltd='Y' , errmsg =errmsg||'Error: Symbol not found!' WHERE autoid = rec.autoid;
          --RETURN;
        else
            SELECT codeid INTO v_codeid  FROM sbsecurities WHERE symbol = rec.symbol;

            IF length(v_codeid) > 0 THEN
        --Cap nhat codeid
                UPDATE TBLSE2240 SET codeid= v_codeid, acctno = afacctno || v_codeid  WHERE autoid = rec.autoid;
            ELSE
                UPDATE TBLSE2240 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
            END IF;

        END IF;
    ELSE
          UPDATE TBLSE2240 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
    END IF;
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          p_err_code := -100800; --File du lieu dau vao khong hop le
          p_err_message:= 'System error. Invalid file format';
          UPDATE TBLSE2240 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno;
     IF v_count = 0 THEN
          p_err_code := -100800; --File du lieu dau vao khong hop le
          p_err_message:= 'System error. Invalid file format';
          UPDATE TBLSE2240 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
     IF v_count = 0 THEN
          p_err_code := -100800; --File du lieu dau vao khong hop le
          p_err_message:= 'System error. Invalid file format';
          UPDATE TBLSE2240 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
          p_err_code := -100800; --File du lieu dau vao khong hop le
          p_err_message:= 'System error. Invalid file format';
          UPDATE TBLSE2240 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;

    END LOOP;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLSE2240;


--3.
PROCEDURE PR_FILE_TBLSE2245(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid VARCHAR2(20);
BEGIN

v_codeid:= '';
v_count:=0;
--Cap nhat autoid
UPDATE tblse2245 SET autoid = seq_tblse2245.NEXTVAL;
-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLSE2245 )
    LOOP
    IF rec.symbol IS NOT NULL THEN
        select count(codeid) into v_count from sbsecurities WHERE symbol = rec.symbol;
        IF v_count = 0 THEN
          UPDATE TBLSE2245 SET deltd='Y' , errmsg =errmsg||'Error: Symbol not found!' WHERE autoid = rec.autoid;
          --RETURN;
        else
            SELECT codeid INTO v_codeid  FROM sbsecurities WHERE symbol = rec.symbol;

            IF length(v_codeid) > 0 THEN
        --Cap nhat codeid
                UPDATE tblse2245 SET codeid= v_codeid, acctno = afacctno || v_codeid  WHERE autoid = rec.autoid;
            ELSE
                UPDATE TBLSE2245 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
            END IF;

        END IF;
    ELSE
          UPDATE TBLSE2245 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
    END IF;
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd AND status = 'A';
     IF v_count = 0 THEN
          UPDATE TBLSE2245 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno AND status = 'A';
     IF v_count = 0 THEN
          UPDATE TBLSE2245 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLSE2245 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
        UPDATE TBLSE2245 SET deltd='Y' , errmsg = errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;

IF rec.amt + rec.depoblock <= 0 THEN
    UPDATE TBLSE2245 SET deltd='Y' , errmsg = errmsg ||'Error: Quantity invalid!' WHERE autoid = rec.autoid;
END IF;


END LOOP;


    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLSE2245;



PROCEDURE PR_FILE_TBLCAI039(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid VARCHAR2(20);
v_amt number;
v_strDesc VARCHAR2(100);
v_strEN_Desc VARCHAR2(100);
v_strCURRDATE varchar2(10);
l_txmsg tx.msg_rectype;
l_err_param varchar2(300);
v_status varchar2(1);

BEGIN

v_codeid:= '';
v_count:=0;
      plog.setbeginsection(pkgctx, 'PR_FILE_TBLCAI039');

-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLCAI039 )
    LOOP

      -- Check CAMASTID
        select count(*) into v_count from camast where camastid = rec.camastid and status = 'A';
        if v_count=0 then
            UPDATE TBLCAI039 SET deltd='Y' , errmsg =errmsg ||'Error: CAMASTID is invalid!' where camastid = rec.camastid;
            p_err_code := -100800; --File du lieu dau vao khong hop le
            p_err_message:= 'System error. Invalid file format';
            return;
        end if;


        select status into v_status from camast where camastid = rec.camastid ;
        if v_status <> 'A' then
             UPDATE TBLCAI039 SET deltd='Y' , errmsg =errmsg ||'Error: CA_STATUS is invalid!'  where camastid = rec.camastid;
        end if;

/*        -- CHECK CAMASTID
        select count(*) into v_count from TBLCAI039 where camastid = rec.camastid group by camastid;
        if v_count>0 then
            UPDATE TBLCAI039 SET deltd='Y' , errmsg =errmsg ||'Error: CAMASTID is invalid!'  where camastid = rec.camastid;
        end if;*/

        plog.debug(pkgctx,'vong for check so luu ky');
        --Check so luu ky
        IF rec.custodycd IS NOT NULL THEN

            -- Neu nhieu hon 1 nghia la bi trung CUSTODYCD
            select count(*) into v_count from TBLCAI039 where CUSTODYCD = rec.CUSTODYCD group by CUSTODYCD;
            if v_count>1 then
                UPDATE TBLCAI039 SET deltd='Y' , errmsg =errmsg ||'Error: CUSTODYCD is invalid!'  where CUSTODYCD = rec.CUSTODYCD;
            end if;

             SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd AND status = 'A';
             IF v_count = 0 THEN
                  UPDATE TBLCAI039 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE custodycd = rec.custodycd;
                  --RETURN;
             END IF;
        ELSE
                UPDATE TBLCAI039 SET deltd='Y' , errmsg = errmsg ||'Error: Custody code invalid!' WHERE  custodycd = rec.custodycd;
                  --RETURN;
        END IF ;


    END LOOP;



    FOR REC IN (
        SELECT * FROM tblcai039 WHERE NVL(DELTD,'N') <> 'Y'
    )
    LOOP

        FOR RECCI IN (
            select ca.autoid, ca.camastid, ca.amt,af.acctno afacctno from caschd ca, afmast af, cfmast cf where af.custid =cf.custid
                and ca.afacctno = af.acctno and ca.deltd <> 'Y' and
                camastid = rec.camastid and cf.custodycd = rec.custodycd order by ca.balance desc
        )
        LOOP

            select nvl(sum(amt),0) into v_amt from caschd ca, afmast af, cfmast cf where af.custid =cf.custid
                and ca.afacctno = af.acctno and ca.deltd <> 'Y' and
                camastid = rec.camastid and cf.custodycd = rec.custodycd and ca.autoid <> recci.autoid;

            if v_amt = 0 then
                UPDATE caschd SET amt = rec.amt WHERE autoid = recci.autoid;
            elsif rec.amt >= v_amt then
                UPDATE caschd SET amt = rec.amt - v_amt WHERE autoid = recci.autoid;
            else
                 UPDATE TBLCAI039 SET deltd='Y' , errmsg = errmsg ||'Error: AMT is invalid!' WHERE  custodycd = rec.custodycd;
            end if;
            EXIT;

        END LOOP;

    END LOOP;




     plog.setendsection(pkgctx, 'PR_FILE_TBLCAI039');

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    plog.setendsection(pkgctx, 'PR_FILE_TBLCAI039');
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCAI039;

--3.
PROCEDURE PR_FILE_TBLSE2202(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid VARCHAR2(20);
v_trade number;
v_strDesc VARCHAR2(250);
v_strEN_Desc VARCHAR2(250);
v_strCURRDATE varchar2(15);
l_txmsg tx.msg_rectype;
l_err_param varchar2(300);
v_count1 number;

BEGIN

v_codeid:= '';
v_count:=0;
      plog.setbeginsection(pkgctx, 'PR_FILE_TBLSE2202');
      select count(*) into v_count1 from TBLSE2202;

      --update TBLSE2202 SET deltd='Y' , errmsg = 'Error: Quantity invalid!' WHERE   nvl(qtty,-9999) <=0 ;
-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLSE2202 )
    LOOP
        /*plog.error('I038 TBLSE2202: rec.symbol:'|| rec.symbol
                                || ', rec.custodycd:'|| rec.custodycd
                                || ', rec.qtty:'|| rec.qtty
                                || ', rec.AFACCTNO:'|| rec.AFACCTNO
                                || ', rec.SETYPE:'|| rec.SETYPE
        );*/
        IF rec.symbol IS NOT NULL THEN
            select count(codeid) into v_count from sbsecurities WHERE symbol = rec.symbol;
            IF v_count = 0 THEN
              UPDATE TBLSE2202 SET deltd='Y' , errmsg =errmsg||'Error: Symbol not found!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
              --RETURN;
            else
                SELECT codeid INTO v_codeid  FROM sbsecurities WHERE symbol = rec.symbol;

            END IF;
        ELSE

              UPDATE TBLSE2202 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
              --RETURN;
        END IF;



        --Check so luu ky
        IF rec.custodycd IS NOT NULL THEN
             SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd AND status = 'A';
             IF v_count = 0 THEN
                  UPDATE TBLSE2202 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
                  --RETURN;
             END IF;
             --Check so tieu
             SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno AND status = 'A';
             IF v_count = 0 THEN
                  UPDATE TBLSE2202 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
                  --RETURN;
             END IF;
             --Check  tieu khoan co phai thuoc so Luu ky
             SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
             AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
             IF v_count = 0 THEN
                  UPDATE TBLSE2202 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
                  --RETURN;
             END IF;

        ELSE
                UPDATE TBLSE2202 SET deltd='Y' , errmsg = errmsg ||'Error: Custody code invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
                  --RETURN;
        END IF ;


        select count(acctno) INTO v_count from semast where acctno =rec.afacctno||v_codeid;

        if v_count>0 then

            select nvl(trade,0) into v_trade from semast where acctno =rec.afacctno||v_codeid;

            IF v_trade - rec.qtty < 0 THEN
                UPDATE TBLSE2202 SET deltd='Y' , errmsg = errmsg ||'Error: Quantity invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
            END IF;

        else
             UPDATE TBLSE2202 SET deltd='Y' , errmsg = errmsg ||'Error: Quantity invalid!' WHERE AFACCTNO = rec.AFACCTNO AND SYMBOL = rec.symbol;
        end if;

    END LOOP;

    ---- Sinh giao dich 2202 cho cac dong voi deltd <> 'Y'


        /*SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='2202';
         SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_strCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.c_system_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate:=v_strCURRDATE;
        l_txmsg.BUSDATE:=v_strCURRDATE;
        l_txmsg.tltxcd:='2202';

    plog.debug(pkgctx, 'Chuan bi sinh 2202');

    for rec in (

        SELECT cf.custodycd, sb.codeid, sb.symbol, tbl.afacctno, tbl.afacctno||sb.codeid acctno, cf.fullname, cf.address, cf.idcode,
            fn_get_semast_avl_withdraw(tbl.afacctno,sb.codeid) tamt, tbl.setype, tbl.qtty, sb.parvalue, sbinf.basicprice
        FROM tblse2202 tbl, cfmast cf, sbsecurities sb, securities_info sbinf
        WHERE NVL(DELTD,'N') <> 'Y' and
        tbl.custodycd = cf.custodycd and tbl.symbol = sb.symbol
            and sb.symbol = sbinf.symbol
    )
    loop

        plog.debug(pkgctx, 'Sinh voi TK: ' || rec.acctno);

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := '0001';

        --Set cac field giao dich
        --88  CUSTODYCD   C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := rec.custodycd ;

        --01  CODEID      C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.CODEID ;

        --02  AFACCTNO    C
        l_txmsg.txfields ('02').defname   := 'AFACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.AFACCTNO ;

        --03  ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.ACCTNO ;

        --90  CUSTNAME    C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.fullname ;

        --91  ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS ;

        --92  LICENSE     C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.idcode ;

        --12  QTTYTYPE    C
        l_txmsg.txfields ('12').defname   := 'QTTYTYPE';
        l_txmsg.txfields ('12').TYPE      := 'C';
        l_txmsg.txfields ('12').VALUE     := rec.setype ;

        --08  TAMT        N
        l_txmsg.txfields ('08').defname   := 'TAMT';
        l_txmsg.txfields ('08').TYPE      := 'N';
        l_txmsg.txfields ('08').VALUE     := rec.TAMT ;

        --10  AMT         N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.qtty ;

        --11  PARVALUE    N
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.PARVALUE ;

        --09  PRICE       N
        l_txmsg.txfields ('09').defname   := 'PRICE';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.basicPRICE ;

        --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := v_strDesc ;


       BEGIN
          IF txpks_#2202.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               ROLLBACK;
               RETURN;
            END IF;
        END;


    end loop;*/

     plog.setendsection(pkgctx, 'PR_FILE_TBLSE2202');

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    plog.setendsection(pkgctx, 'PR_FILE_TBLSE2202');
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
    PLOG.ERROR('PR_FILE_TBLSE2202: '|| SQLERRM);
RETURN;
END PR_FILE_TBLSE2202;



PROCEDURE PR_FILE_TBLSE2244(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid VARCHAR2(20);
BEGIN

v_codeid:= '';
v_count:=0;
--Cap nhat autoid
UPDATE tblse2244 SET autoid = seq_tblse2244.NEXTVAL;
-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLSE2244 )
    LOOP
    IF rec.symbol IS NOT NULL THEN
        select count(codeid) into v_count from sbsecurities WHERE symbol = rec.symbol;
        IF v_count = 0 THEN
          UPDATE TBLSE2244 SET deltd='Y' , errmsg =errmsg||'Error: Symbol not found!' WHERE autoid = rec.autoid;
          --RETURN;
        else
            SELECT codeid INTO v_codeid  FROM sbsecurities WHERE symbol = rec.symbol;

            IF length(v_codeid) > 0 THEN
        --Cap nhat codeid
                UPDATE tblse2244 SET codeid= v_codeid, acctno = afacctno || v_codeid  WHERE autoid = rec.autoid;
            ELSE
                UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
            END IF;

        END IF;
    ELSE
          UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
    END IF;
    IF rec.trade + rec.blocked + rec.caqtty <= 0 THEN
        UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg || 'Error: Total quantity must be greater than zero!' WHERE autoid = rec.autoid;
    END IF;
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLSE2244 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     -- Check ma chung khoan phai co trong danh muc ck cua tieu khoan
     SELECT count(*) INTO v_count FROM semast
        WHERE afacctno = rec.afacctno AND codeid = (SELECT codeid FROM securities_info WHERE symbol = rec.symbol);
     IF v_count <= 0 THEN
        UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg ||'Error: SeAccount does not exist!' WHERE autoid = rec.autoid;
     ELSE
        SELECT count(*) INTO v_count
        FROM semast mst,
             (
                    select acctno,sum(qtty-mapqtty) qtty
                    from sepitlog where deltd <> 'Y' and qtty-mapqtty>0
                    group by acctno
                ) pit
        WHERE mst.afacctno = rec.afacctno AND mst.codeid = (SELECT codeid FROM securities_info WHERE symbol = rec.symbol)
              AND mst.trade >= rec.trade AND mst.blocked >= rec.blocked
              AND mst.acctno = pit.acctno (+)
              AND nvl(pit.qtty,0) >= rec.caqtty;
        IF v_count <= 0 THEN
            UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg ||'Error: Quantity Not Enough!' WHERE autoid = rec.autoid;
        END IF;

     END IF;
     ---------------Vu them
     --Check  tieu khoan 2 co phai thuoc so Luu ky
     IF substr(rec.custodycd2,1,3) = '002' THEN
        --Neu cung cong ty thi check so tieu khoan 2
        SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
            AND cf.custodycd = rec.custodycd2 AND af.acctno = rec.afacctno2;
        IF v_count <= 0 THEN
            UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
        END IF;
     END IF;

ELSE
        UPDATE TBLSE2244 SET deltd='Y' , errmsg = errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


END LOOP;


    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLSE2244;


--4.
PROCEDURE PR_FILE_TBLCI1141(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_bankacctno varchar2(20);
v_glaccount varchar2(30);
BEGIN
v_bankacctno :='';
v_glaccount :='';
v_count:=0;
--Cap nhat autoid
UPDATE tblci1141 SET autoid = seq_tblci1141.NEXTVAL;
-- CHECK MA BANK
    FOR REC IN
    (SELECT * FROM TBLCI1141 )
    LOOP
    IF rec.bankid IS NOT NULL THEN
        SELECT count(shortname)  INTO v_count  FROM banknostro WHERE shortname = rec.bankid;
        IF v_count > 0 THEN
        --Cap nhat bankacc,glacc
            SELECT bankacctno INTO v_bankacctno FROM banknostro WHERE shortname = rec.bankid;
            SELECT glaccount INTO v_glaccount FROM banknostro WHERE shortname = rec.bankid;
            UPDATE TBLCI1141 SET bankacctno = v_bankacctno,  glmast = v_glaccount WHERE autoid = rec.autoid;

        ELSE
          UPDATE TBLCI1141 SET deltd='Y' , errmsg =errmsg ||'Error: Bank code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
        END IF;
     ELSE
          UPDATE TBLCI1141 SET deltd='Y' , errmsg =errmsg ||'Error: Bank code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLCI1141 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1141 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1141 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
        UPDATE TBLCI1141 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


END LOOP;


    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1141;

PROCEDURE PR_FILE_tmpSEMASTVSD(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_CUSTODYCD varchar2(10);
v_PRICE    number;
v_QTTY number;
errmsg varchar2(50);
BEGIN
       v_count:=0;
       UPDATE tmpSEMASTVSD SET autoid = seq_tmpSEMASTVSD.NEXTVAL;
       FOR REC IN
            (
                SELECT * FROM tmpSEMASTVSD
            )
       LOOP
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE tmpSEMASTVSD SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
ELSE
        UPDATE tmpSEMASTVSD SET deltd='Y' , errmsg = errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;
    END LOOP;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_tmpSEMASTVSD;

PROCEDURE PR_FILE_tmpTOTALSEVSD(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_QTTY number;
errmsg varchar2(50);
BEGIN

       UPDATE tmpTOTALSEVSD SET autoid = seq_tmpTOTALSEVSD.NEXTVAL;
             UPDATE tmpTOTALSEVSD  set deltd = 'Y' ,status = 'E', errmsg = 'Duplicate Symbol'
             WHERE autoid IN (SELECT MAX(autoid)  FROM tmpTOTALSEVSD GROUP BY symbol,actype HAVING COUNT(1) > 1);
             UPDATE tmpTOTALSEVSD SET deltd = 'Y', status = 'E', errmsg = 'Symbol invalid'
             WHERE symbol NOT IN (SELECT symbol FROM sbsecurities);
             UPDATE tmptotalsevsd SET status = 'A', deltd = 'N' WHERE deltd <> 'Y' ;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_tmpTOTALSEVSD;

PROCEDURE PR_FILE_TBLCI1137(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_fileid varchar2(20);

BEGIN
    v_count:=0;
    --Cap nhat autoid
    UPDATE tblci1137 SET autoid = seq_tblci1137.NEXTVAL;

    -- Cap nhap fileid
    select count(*) into v_count from tblci1137hist where substr(fileid,1,8) =  to_char(getcurrdate,'ddmmrrrr');

    if v_count = 0 then
        UPDATE tblci1137 set fileid = to_char(getcurrdate,'ddmmrrrr') || '000001';
    else
        select to_char(to_number(max(substr(fileid,9,6))) + 1,'000000') into v_fileid from TBLCI1137hist where substr(fileid,1,8) =  to_char(getcurrdate,'ddmmrrrr');
        UPDATE tblci1137 set fileid = to_char(getcurrdate,'ddmmrrrr') || ltrim(v_fileid);
    end if;


-- CHECK MA BANK
    FOR REC IN
    (SELECT * FROM TBLCI1137 )
    LOOP
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLCI1137 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.acctno and status ='A';
     IF v_count = 0 THEN
          UPDATE TBLCI1137 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1137 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
        UPDATE TBLCI1137 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


END LOOP;


    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1137;


PROCEDURE PR_FILE_TBLCI1138(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_fileid varchar2(20);

BEGIN
    v_count:=0;
    --Cap nhat autoid
    UPDATE tblci1138 SET autoid = seq_tblci1138.NEXTVAL;

    -- Cap nhap fileid
    select count(*) into v_count from tblci1138hist where substr(fileid,1,8) =  to_char(getcurrdate,'ddmmrrrr');

    if v_count = 0 then
        UPDATE tblci1138 set fileid = to_char(getcurrdate,'ddmmrrrr') || '000001';
    else
        select to_char(to_number(max(substr(fileid,9,6))) + 1,'000000') into v_fileid from tblci1138hist where substr(fileid,1,8) =  to_char(getcurrdate,'ddmmrrrr');
        UPDATE tblci1138 set fileid = to_char(getcurrdate,'ddmmrrrr') || ltrim(v_fileid);
    end if;


-- CHECK MA BANK
    FOR REC IN
    (SELECT * FROM TBLCI1138 )
    LOOP
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLCI1138 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.acctno and status = 'A';
     IF v_count = 0 THEN
          UPDATE TBLCI1138 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1138 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
        UPDATE TBLCI1138 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


END LOOP;


    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1138;


--select * from tblci1101
--5.
PROCEDURE PR_FILE_TBLCI1101(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
BEGIN
v_count:=0;
--Cap nhat autoid
UPDATE tblci1101 SET autoid = seq_tblci1101.NEXTVAL;
--Check so luu ky
FOR REC IN
    (SELECT * FROM TBLCI1101 )
LOOP
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLCI1101 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu khoan
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1101 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1101 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
        UPDATE TBLCI1101 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;
END LOOP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1101;


--select * from tblci1187
--6.
PROCEDURE PR_FILE_TBLCI1187(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_CUSTODIANTYP varchar2(1);
BEGIN

   v_count:=0;
   v_CUSTODIANTYP :='';
--Cap nhat autoid
UPDATE tblci1187 SET autoid = seq_tblci1187.NEXTVAL;
--Check so luu ky
FOR REC IN
    (SELECT * FROM TBLCI1187 )
LOOP
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLCI1187 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu khoan
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1187 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.acctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1187 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

     --check tai khoan co thuoc thanh vien khac hay khong
     select count(CUSTATCOM) into v_count from cfmast  where  CUSTATCOM ='Y' and custodycd = rec.custodycd;

     if v_count > 0 then
            UPDATE TBLCI1187 SET deltd='Y' , errmsg ='Error: Noi luu ky khong hop le!' WHERE autoid = rec.autoid;
     end if;

ELSE
        UPDATE TBLCI1187 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


END LOOP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1187;



PROCEDURE PR_FILE_TBLCF0037(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_CUSTODIANTYP varchar2(1);
v_CUSTODYCD varchar2(10);
v_CUSTID    varchar2(10);
v_CFFULLNAME varchar2(100);
v_brid  varchar2(4);


BEGIN
      plog.setbeginsection(pkgctx, 'pr_CFSEUpload');

   v_count:=0;

    --check du lieu
    FOR REC IN
        (
           SELECT * FROM TBLCF0037
        )
    LOOP

        SELECT count(*) into v_count FROM CFMAST WHERE IDCODE = REC.IDCODE;
        if v_count > 0 then
            UPDATE tblCF0037 SET deltd='Y', status='E', errmsg =errmsg ||'Error: IDCODE exist in cfmast!' WHERE idcode = rec.idcode;
        end if;

        SELECT count(*) into v_count FROM CFMASTTEMP WHERE IDCODE = REC.IDCODE;
        if v_count > 0 then
            UPDATE tblCF0037 SET deltd='Y', status='E', errmsg =errmsg ||'Error: IDCODE Exist in cfmasttemp' WHERE idcode = rec.idcode;
        end if;


    END LOOP;

    SELECT BRID INTO v_brid FROM TLPROFILES WHERE TLID =p_tlid;


    INSERT INTO cfmasttemp (CUSTTYPE, GRINVESTOR, FULLNAME, SEX, DATEOFBIRTH,
       BIRTHPLACE, IDCODE, IDDATE, IDPLACE, ADDRESS,
       RECEIVEADDRESS, PHONE, MOBILE, EMAIL, STATUS,
       VCBACCOUNT, TAXNUMBER, ISONLTRADE, ISTELTRADE,
       ISMATCHSMS, ISOTHERSMS, ISNEWSEMAIL, ISMARGINTRF, VIA,
       TLID, BRANCH, OPNDATE, NOTES)
   SELECT CUSTTYPE, GRINVESTOR, FULLNAME, SEX, DATEOFBIRTH,
       BIRTHPLACE, IDCODE, IDDATE, IDPLACE, ADDRESS,
       RECEIVEADDRESS, PHONE, MOBILE, EMAIL, 'P' STATUS,
       VCBACCOUNT, TAXNUMBER, ISONLTRADE, ISTELTRADE,
       ISMATCHSMS, ISOTHERSMS, ISNEWSEMAIL, ISMARGINTRF, 'F' VIA,
       p_tlid TLID, v_brid BRANCH, GETCURRDATE OPNDATE,  DESCRIPTION
   FROM tblCF0037 WHERE nvl(DELTD,'N') <> 'Y';

    plog.setendsection(pkgctx, 'pr_CFSEUpload');
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    plog.setendsection(pkgctx, 'pr_CFSEUpload');
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCF0037;

--select * from tblci1135
--6.
PROCEDURE PR_FILE_TBLCI1135(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_CUSTODIANTYP varchar2(1);
v_CUSTODYCD varchar2(10);
v_CUSTID    varchar2(10);
v_CFFULLNAME varchar2(100);
v_DESBANKNAME varchar2(100);
v_DESBANKACCT varchar2(30);
v_DESGLACCT varchar2(30);
v_FEEAMT    number;
v_VATAMT    number;
v_TRFAMT    number;


BEGIN

   v_count:=0;
   v_CUSTODIANTYP :='';

   UPDATE TBLCI1135 SET autoid = seq_TBLCI1135.NEXTVAL;

    FOR REC IN
        (
            SELECT TB.*, NVL(CF.CUSTODYCD,'') CUSTODYCD, NVL(CF.CUSTID,'') CUSTID, NVL(CF.FULLNAME,'') FULLNAME,
                B.FULLNAME DESBANKNAME, B.BANKACCTNO DESBANKACCT, NVL(B.GLACCOUNT,'') DESGLACCT,
                FN_GETTRANSACT_FEE(TB.FEECD,TB.AMT) FEEAMT,
                FN_GETTRANSACT_VATFEE(TB.FEECD,TB.AMT) VATAMT,
                TB.AMT + FN_GETTRANSACT_FEE(TB.FEECD,TB.AMT) * TB.IORO + FN_GETTRANSACT_VATFEE(TB.FEECD,TB.AMT) * TB.IORO TRFAMT
            FROM TBLCI1135 TB, CFMAST CF, BANKNOSTRO B
            WHERE TB.IDCODE=CF.IDCODE(+)
                AND TB.BANKID = B.SHORTNAME(+)
        )
    LOOP

        if length(rec.DESBANKNAME) = 0 or  length(rec.DESBANKACCT) = 0 then
            UPDATE tblci1135 SET deltd='Y', status='E', errmsg =errmsg ||'Error: BANKID invalid!' WHERE autoid = rec.autoid;
        end if;

        SELECT count(*) into v_count FROM FEEMASTER WHERE FEECD IN (SELECT DISTINCT FEECD FROM FEEMAP WHERE TLTXCD='1135')
            and feecd = rec.feecd;
        if v_count = 0 then
            UPDATE tblci1135 SET deltd='Y', status='E', errmsg =errmsg ||'Error: FEECD invalid!' WHERE autoid = rec.autoid;
        end if;

    END LOOP;



    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1135;

PROCEDURE PR_FILE_TBLCI1180(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_CUSTODYCD varchar2(10);

v_AMT    number;


BEGIN

   v_count:=0;


   UPDATE TBLCI1180 SET autoid = seq_TBLCI1180.NEXTVAL;

    FOR REC IN
        (
            SELECT * FROM TBLCI1180
        )
    LOOP
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLCI1180 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1180 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLCI1180 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

ELSE
        UPDATE TBLCI1180 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


    END LOOP;



    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCI1180;
--select * from tblse2287
--7.
PROCEDURE PR_FILE_TBLSE2287(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid varchar2(10);
BEGIN
v_codeid:= '';
v_count:=0;
--Cap nhat autoid
UPDATE tblse2287 SET autoid = seq_tblse2287.NEXTVAL;
-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLSE2287 )
    LOOP
    IF rec.symbol IS NOT NULL THEN
        select count(codeid) into v_count from sbsecurities WHERE symbol = rec.symbol;
        IF v_count = 0 THEN
          UPDATE TBLSE2287 SET deltd='Y' , errmsg =errmsg||'Error: Symbol not found!' WHERE autoid = rec.autoid;
          --RETURN;
        else
            SELECT codeid INTO v_codeid  FROM sbsecurities WHERE symbol = rec.symbol;

            IF length(v_codeid) > 0 THEN
        --Cap nhat codeid
                UPDATE TBLSE2287 SET codeid= v_codeid, acctno = afacctno || v_codeid  WHERE autoid = rec.autoid;
            ELSE
                UPDATE TBLSE2287 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
            END IF;

        END IF;
    ELSE
          UPDATE TBLSE2287 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
    END IF;
--Check so luu ky
IF rec.custodycd IS NOT NULL THEN
     SELECT count(custodycd) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
     IF v_count = 0 THEN
          UPDATE TBLSE2287 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check so tieu
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLSE2287 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
     --Check  tieu khoan co phai thuoc so Luu ky
     SELECT count(acctno) INTO v_count FROM afmast af, cfmast cf WHERE  af.custid = cf.custid
     AND cf.custodycd = rec.custodycd AND af.acctno = rec.afacctno;
     IF v_count = 0 THEN
          UPDATE TBLSE2287 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
      --check tai khoan co thuoc thanh vien khac hay khong
     select count(CUSTATCOM) into v_count from cfmast  where  CUSTATCOM ='Y' and custodycd = rec.custodycd;

     if v_count > 0 then
            UPDATE TBLSE2287 SET deltd='Y' , errmsg ='Error: Noi luu ky khong hop le!' WHERE autoid = rec.autoid;
     end if;


ELSE
        UPDATE TBLSE2287 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
END IF ;


END LOOP;

    -- KIEM TRA KHACH HANG DO DA TON TAI TRONG HE THONG CHUA

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLSE2287;

--select * from tblse2203
--8.
PROCEDURE PR_FILE_TBLSE2203(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_codeid varchar2(20);
V_QTTY NUMBER;
v_EMKQTTY NUMBER;
v_BLOCKED NUMBER;
BEGIN
v_codeid:= '';
v_count:=0;
V_QTTY:=0;

--Cap nhat autoid
UPDATE TBLSE2203 SET autoid = seq_tblse2203.NEXTVAL;

-- CHECK MA CK
    FOR REC IN
    (SELECT * FROM TBLSE2203 )
    LOOP

    IF rec.symbol IS NOT NULL THEN
        select count(codeid) into v_count from sbsecurities WHERE symbol = rec.symbol;
        IF v_count = 0 THEN
          v_codeid:=' ';
          UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg||'Error: Symbol not found!' WHERE autoid = rec.autoid;
          --RETURN;
        else
            SELECT codeid INTO v_codeid  FROM sbsecurities WHERE symbol = rec.symbol;

            IF length(v_codeid) > 0 THEN
        --Cap nhat codeid
                UPDATE TBLSE2203 SET codeid= v_codeid, acctno = afacctno || v_codeid  WHERE autoid = rec.autoid;
            ELSE
                v_codeid:=' ';
                UPDATE TBLSE2203 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
            END IF;

        END IF;
     ELSE
          v_codeid:=' ';
          UPDATE TBLSE2203 SET deltd='Y' , errmsg = errmsg || 'Error: Symbol invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;

--Check so luu ky
   IF rec.afacctno IS NOT NULL THEN
     SELECT count(acctno) INTO v_count FROM afmast WHERE acctno = rec.afacctno;
     IF v_count = 0 THEN
        UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg ||'Error: afacctno invalid!' WHERE autoid = rec.autoid;
          --RETURN;
     END IF;
   ELSE
        UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg ||'Error: Custody code invalid!' WHERE autoid = rec.autoid;
          --RETURN;
   END IF ;

  --Moi TK, CK chi co mot dong
    select count(afacctno) into v_count from TBLSE2203 where afacctno = rec.afacctno
    and symbol = rec.symbol and qttytype = rec.qttytype and fileid = rec.fileid;
    IF v_count > 1 THEN
      UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg ||'Error: Afacctno,symbol,qtty type  is duplicate!' WHERE afacctno = rec.afacctno
      and symbol = rec.symbol and qttytype = rec.qttytype and fileid = rec.fileid;
      --RETURN
    end if;
    --plog.error( pkgctx, ' BEGIN invalid so luong chung khoan giai toa ' || rec.afacctno ||v_codeid  );

    if length(nvl(v_codeid,' ')) > 1 then
        -- KTra so luong chung khoan giai toa
         --plog.error( pkgctx, ' BEGIN invalid v_codeid' ||v_codeid || ';' || rec.QTTYTYPE || ';'|| rec.TRADEAMT );
         begin
            select nvl(EMKQTTY,0), nvl(BLOCKED,0) into v_EMKQTTY, v_BLOCKED from semast where acctno = REC.AFACCTNO ||v_codeid;
         exception
         when others then
            v_EMKQTTY := 0;
            v_BLOCKED := 0;
         end;
        -- Neu la CK han che chuyen nhuong
        if rec.QTTYTYPE = '002' then
            if rec.TRADEAMT > v_BLOCKED THEN
                --plog.error( pkgctx, ' BEGIN invalid v_BLOCKED ' || v_BLOCKED || ' ' || rec.afacctno ||v_codeid  );
                UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg ||'Error: Invalid quantity!' WHERE afacctno = rec.afacctno
                    and symbol = rec.symbol and qttytype = rec.qttytype and fileid = rec.fileid;
                --plog.error( pkgctx, ' END invalid v_BLOCKED ' || v_BLOCKED || ' ' || rec.afacctno ||v_codeid  );

            END IF;
        else
            if rec.TRADEAMT > v_EMKQTTY THEN
                --plog.error( pkgctx, ' invalid v_EMKQTTY ' || v_EMKQTTY || ' ' || rec.afacctno ||v_codeid  );
                UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg ||'Error: Invalid quantity!' WHERE afacctno = rec.afacctno
                    and symbol = rec.symbol and qttytype = rec.qttytype and fileid = rec.fileid;
            END IF;
        end if;
    end if;

  --SO LUONG CK GIAI TOA
/*
   V_QTTY:=0;
   SELECT NVL(SUM(QTTY),0)  INTO V_QTTY FROM SEMASTDTL WHERE DELTD='N' AND STATUS='N'
   AND QTTYTYPE = REC.qttytype AND   ACCTNO = REC.AFACCTNO ||v_codeid ;

   IF REC.TRADEAMT > V_QTTY THEN
        UPDATE TBLSE2203 SET deltd='Y' , errmsg =errmsg ||'Error: Quantty  invalid!' WHERE autoid = rec.autoid;
        --RETURN
   END IF;*/



END LOOP;
    plog.debug( pkgctx, ' finish ');
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLSE2203;

--Duyet Import doi loai hinh hop dong.
PROCEDURE PR_FILE_TBLCHANGEAFTYPE(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_strcustid varchar2(10);

v_strCoreBank varchar2(10);
v_strCIACTYPE   varchar2(10);
v_strSEACTYPE   varchar2(10);
v_strLNACTYPE   varchar2(10);
v_strMRTYPE varchar2(10);
v_strAUTOADV CHAR(1);
v_dblMRIRATE number;
v_dblMRMRATE number;
v_dblMRLRATE number;
v_blnUpdate BOOLEAN;
v_strOldcorebank    varchar2(10);
v_strOldautoadv CHAR(1);
v_dblOldmrirate number;
v_dblOldmrmrate number;
v_dblOldmrlrate number;
v_busdate   varchar2(20);
BEGIN
    --Cap nhat autoid
    UPDATE TBLCHANGEAFTYPE SET autoid = seq_TBLCHANGEAFTYPE.NEXTVAL;
    for rec in (
        select * from TBLCHANGEAFTYPE where status = 'P'
    )
    loop
        --Thuc hien thay doi loai h? hop dong
        v_blnUpdate:= true;
        SELECT count(1) into v_count FROM AFTYPE WHERE ACTYPE = rec.newaftype AND APPRV_STS = 'A';
        if v_count <> 1 then
            UPDATE TBLCHANGEAFTYPE SET deltd='Y' , errmsg =errmsg ||'Error: New aftype Invalid!' WHERE autoid = rec.autoid;
            v_blnUpdate:= false;
        end if;
        --Goi thu tuc check
        cspks_cfproc.pr_AFMAST_ChangeTypeCheck(rec.acctno,rec.newaftype,p_err_code);
        if p_err_code <> 0 then
            UPDATE TBLCHANGEAFTYPE SET deltd='Y' , errmsg =errmsg || 'Error:' || cspks_system.fn_get_errmsg(p_err_code) WHERE autoid = rec.autoid;
            v_blnUpdate:= false;
        end if;

        SELECT count(1) into v_count FROM AFMAST WHERE ACCTNO = rec.acctno AND STATUS NOT IN ('B','N','C');
        if v_count <> 1 then
            UPDATE TBLCHANGEAFTYPE SET deltd='Y' , errmsg =errmsg || 'Error:' || cspks_system.fn_get_errmsg('-200010') WHERE autoid = rec.autoid;
            v_blnUpdate:= false;
        end if;
        if v_blnUpdate = true then
            SELECT custid, corebank, autoadv, mrirate, mrmrate, mrlrate
                into v_strcustid,v_strOldcorebank, v_strOldautoadv, v_dblOldmrirate, v_dblOldmrmrate, v_dblOldmrlrate
            FROM AFMAST WHERE ACCTNO = rec.acctno;
            SELECT AF.CITYPE, AF.SETYPE, AF.LNTYPE, AF.COREBANK , MR.MRTYPE,MR.MRIRATE, MR.MRMRATE, MR.MRLRATE
                into v_strCIACTYPE,v_strSEACTYPE,v_strLNACTYPE,v_strCoreBank, v_strMRTYPE, v_dblMRIRATE,v_dblMRMRATE,v_dblMRLRATE
            FROM AFTYPE AF, MRTYPE MR WHERE AF.MRTYPE= MR.ACTYPE AND AF.ACTYPE = rec.newaftype;
            v_busdate:= to_char(getcurrdate,'DD/MM/RRRR');
            --Cap nhat thong tin thay doi AFMAST
            if v_strMRTYPE in ('S','T') then
                v_strAUTOADV:='Y';
                update afmast
                    set autoadv ='Y',
                        actype = rec.newaftype,
                        corebank = v_strCoreBank,
                        MRIRATE = v_dblMRIRATE,
                        MRMRATE = v_dblMRMRATE,
                        MRLRATE = v_dblMRLRATE
                where acctno = rec.acctno;
            else
                if v_strCoreBank ='Y' then
                    v_strAUTOADV:='N';
                    update afmast
                        set autoadv ='N',
                            actype = rec.newaftype,
                            corebank = v_strCoreBank,
                            MRIRATE = v_dblMRIRATE,
                            MRMRATE = v_dblMRMRATE,
                            MRLRATE = v_dblMRLRATE
                    where acctno = rec.acctno;
                else
                    update afmast
                        set autoadv ='Y',
                            corebank = v_strCoreBank,
                            MRIRATE = v_dblMRIRATE,
                            MRMRATE = v_dblMRMRATE,
                            MRLRATE = v_dblMRLRATE
                    where acctno = rec.acctno;
                end if;
            end if;
            --Cap nhat thong tin thay doi CIMAST
            UPDATE CIMAST SET ACTYPE = v_strCIACTYPE, COREBANK =v_strCoreBank WHERE AFACCTNO = rec.acctno;
            UPDATE SEMAST SET ACTYPE = v_strSEACTYPE WHERE AFACCTNO = rec.acctno;

            --THem thong tin vao trong Maintain_log trang thai da duyet de ghi nhan la Co thay doi loai hinh hop dong
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,
                    MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('CFMAST','CUSTID = ''' || v_strcustid  || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR')
                    ,1,'ACTYPE',rec.oldaftype,rec.newaftype,'EDIT','AFMAST','ACCTNO = ''' || rec.acctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            --v_strcustid,v_strOldcorebank, v_strOldautoadv, v_strOldmrirate, v_strOldmrmrate, v_strOldmrlrate
            if v_strOldcorebank <> v_strCoreBank then
                INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,
                        MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
                VALUES('CFMAST','CUSTID = ''' || v_strcustid  || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR')
                        ,1,'COREBANK',v_strOldcorebank,v_strCoreBank,'EDIT','AFMAST','ACCTNO = ''' || rec.acctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            end if;
            if v_strOldautoadv <> v_strAUTOADV then
                INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,
                        MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
                VALUES('CFMAST','CUSTID = ''' || v_strcustid  || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR')
                        ,1,'AUTOADV',v_strOldautoadv,v_strAUTOADV,'EDIT','AFMAST','ACCTNO = ''' || rec.acctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            end if;
            if v_dblOldmrirate <> v_dblMRIRATE then
                INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,
                        MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
                VALUES('CFMAST','CUSTID = ''' || v_strcustid  || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR')
                        ,1,'MRIRATE',v_dblOldmrirate,v_dblMRIRATE,'EDIT','AFMAST','ACCTNO = ''' || rec.acctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            end if;
            if v_dblOldmrlrate <> v_dblMRLRATE then
                INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,
                        MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
                VALUES('CFMAST','CUSTID = ''' || v_strcustid  || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR')
                        ,1,'MRLRATE',v_dblOldmrlrate,v_dblMRLRATE,'EDIT','AFMAST','ACCTNO = ''' || rec.acctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            end if;
            if v_dblOldmrmrate <> v_dblMRMRATE then
                INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,
                        MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
                VALUES('CFMAST','CUSTID = ''' || v_strcustid  || '''',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',p_tlid,TO_DATE( v_busdate ,'DD/MM/RRRR')
                        ,1,'MRMRATE',v_dblOldmrmrate,v_dblMRmRATE,'EDIT','AFMAST','ACCTNO = ''' || rec.acctno || '''',to_char(sysdate,'hh24:mi:ss'),to_char(sysdate,'hh24:mi:ss'));

            end if;
            UPDATE TBLCHANGEAFTYPE SET status ='A' , errmsg ='Thanh cong' WHERE autoid = rec.autoid;


        end if;
    end loop;
    --Backup luu lai lich su
    insert into TBLCHANGEAFTYPE_HIST (CUSTODYCD,ACCTNO,FULLNAME,OLDAFTYPE,NEWAFTYPE,DELTD,STATUS,ERRMSG,DESCRIPTION,TLID,IMPORTDT,AUTOID,APPROVEDT)
    select CUSTODYCD,ACCTNO,FULLNAME,OLDAFTYPE,NEWAFTYPE,DELTD,STATUS,ERRMSG,DESCRIPTION,TLID,IMPORTDT,AUTOID, SYSTIMESTAMP from  TBLCHANGEAFTYPE;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCHANGEAFTYPE;
PROCEDURE FILLTER_TBLCHANGECFTYPE (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    --Kiem tra xem so luu ky va tai khoan co ton tai hay khong
    update TBLCHANGECFTYPE set status ='E', errmsg ='So Luu Ky khong ton tai hoac da dong!' where custodycd not in (select custodycd from cfmast where status <> 'C');
    update TBLCHANGECFTYPE set status ='E', errmsg ='So Luu Ky va ma loai hinh khong dong nhat trong he thong hien tai!'
        where (custodycd,oldCftype) not in (select CUSTODYCD, actype from CFmast where status <> 'C');
    update TBLCHANGECFTYPE set status ='E', errmsg ='Ma loai hinh moi khong hop le!' where newCftype not in (select actype from cftype where status = 'Y' );
    UPDATE TBLCHANGECFTYPE SET tlid=p_tlid, importdt = SYSTIMESTAMP;
     UPDATE TBLCHANGECFTYPE T SET CUSTID = (SELECT CUSTID FROM CFMAST C WHERE C.CUSTODYCD=T.CUSTODYCD);
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_TBLCHANGECFTYPE;
------------------------------------------------change careby
---------------------------------------------------------------------------filter
PROCEDURE FILLTER_TBLCHANGECAREBY (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_fullname VARCHAR2(100);
BEGIN
  --cap nhap autoid
    UPDATE tblchangecareby SET autoid = seq_tblchangecareby.nextval;
    --check trung custodycd
    FOR rec IN
        (
          SELECT MAX(autoid) autoid FROM tblchangecareby GROUP BY custodycd HAVING COUNT(1) > 1
        )
    LOOP
        UPDATE tblchangecareby SET deltd = 'Y', errmsg = 'duplicate cusotodycd in file', status = 'E' WHERE autoid = rec.autoid;
    END LOOP;

    ---check chuyen trung careby
    UPDATE tblchangecareby SET  deltd = 'Y', errmsg = 'old and new careby are same', status = 'E' WHERE oldcareby = newcareby;
    ----------------

   FOR rec IN
         (
           SELECT * FROM tblchangecareby WHERE deltd <> 'Y'
         )
    LOOP
       --check ton tai so tai khoan
         SELECT COUNT(1) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd;
         IF v_count <> 0 THEN
             --check ton tai oldcareby
             SELECT COUNT(1) INTO v_count FROM cfmast WHERE custodycd = rec.custodycd AND careby = rec.oldcareby;
             IF v_count <> 0 THEN
                 --check ton tai newcareby
                 SELECT COUNT(1) INTO v_count FROM tlgroups WHERE grpid = rec.newcareby AND grptype = '2';
                 IF v_count  <> 0 THEN
                     UPDATE tblchangecareby SET tlid = p_tlid, importdt = systimestamp  WHERE autoid = rec.autoid;
                     SELECT fullname INTO v_fullname FROM cfmast WHERE custodycd = rec.custodycd;
                     UPDATE tblchangecareby SET fullname = v_fullname WHERE autoid = rec.autoid;
                 ELSE
                     UPDATE tblchangecareby SET deltd = 'Y', errmsg = 'new careby not available', status = 'E' WHERE autoid = rec.autoid;
                 END IF;
             ELSE
                 UPDATE tblchangecareby SET deltd = 'Y', errmsg = 'old careby not right', status = 'E' WHERE autoid = rec.autoid;
             END IF;
         ELSE
             UPDATE tblchangecareby SET deltd = 'Y', errmsg = 'Custodycd not available!', status = 'E' WHERE autoid = rec.autoid;
        END IF;
    END LOOP;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_TBLCHANGECAREBY;
--------------------------------------------------------------------------end filter

--------------------------------------------------------------------------update
PROCEDURE PR_FILE_TBLCHANGECAREBY(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_custid VARCHAR2(10);

BEGIN
    FOR rec IN
            (
              SELECT * FROM tblchangecareby WHERE status = 'P'
            )
        LOOP
            --update cfmast, afmast
            UPDATE cfmast SET careby = rec.newcareby WHERE custodycd = rec.custodycd;
            SELECT custid INTO v_custid FROM cfmast WHERE custodycd = rec.custodycd;
            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
      values ('CFMAST', 'CUSTID = ''' ||v_custid ||'''', rec.tlid, to_char(rec.importdt, 'dd-mm-yyyy'), 'Y', p_tlid, to_date(getcurrdate, 'dd-mm-yyyy'), 0, 'CAREBY',rec.oldcareby,rec.newcareby, 'EDIT', null, null,  to_char(rec.importdt,'hh24:mm:ss'),to_char(SYSTIMESTAMP,'hh24:mm:ss'));
      FOR r IN
                (
                  SELECT * FROM afmast WHERE custid = v_custid
                )
            LOOP
                UPDATE afmast SET careby = rec.newcareby WHERE acctno = r.acctno;
                insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = ''' ||v_custid ||'''', rec.tlid, to_char(rec.importdt, 'dd-mm-yyyy'), 'Y', p_tlid, to_date(getcurrdate, 'dd-mm-yyyy'), 1, 'CAREBY',rec.oldcareby,rec.newcareby, 'EDIT', 'AFMAST',  'ACCTNO = '''|| r.acctno || '''',  to_char(rec.importdt,'hh24:mm:ss'),to_char(SYSTIMESTAMP,'hh24:mm:ss'));
            END LOOP;
          --update tblchangecareby
            UPDATE tblchangecareby SET status = 'A' WHERE autoid = rec.autoid;
    END LOOP;
        --back up
        INSERT INTO tblchangecareby_hist
        SELECT * FROM tblchangecareby;
        ---------------
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCHANGECAREBY;

PROCEDURE PR_FILE_CFCHANGEBRID(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_custid VARCHAR2(10);
v_oldbrid VARCHAR2(10);

BEGIN
    plog.error( pkgctx, ' Start ');
    FOR rec IN
            (
              SELECT * FROM CFCHANGEBRIDIMP WHERE status = 'P'
            )
        LOOP
            --update cfmast, afmast
            SELECT custid,brid INTO v_custid,v_oldbrid FROM cfmast WHERE custodycd = rec.custodycd;
            UPDATE cfmast SET brid = rec.brid WHERE custodycd = rec.custodycd;
            SELECT custid INTO v_custid FROM cfmast WHERE custodycd = rec.custodycd;
            insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
            values ('CFMAST', 'CUSTID = ''' ||v_custid ||'''', rec.tlid, getcurrdate, 'Y', p_tlid, getcurrdate, 0, 'CAREBY',v_oldbrid,rec.brid, 'EDIT', null, null,  TO_CHAR(SYSDATE, 'HH24:MI:SS'),null);


        --update CFCHANGEBRIDIMP
            UPDATE CFCHANGEBRIDIMP SET status = 'A' WHERE autoid = rec.autoid;
    END LOOP;
        --back up
        INSERT INTO CFCHANGEBRIDIMP_hist
        SELECT * FROM CFCHANGEBRIDIMP;
        ---------------
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others THEN
 plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_CFCHANGEBRID;
-------------------------------------------------------------------------end update

------------------------------------------------end change careby



PROCEDURE PR_FILE_TBLCHANGECFTYPE(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_strcustid varchar2(10);

v_strCoreBank varchar2(10);
v_strCIACTYPE   varchar2(10);
v_strSEACTYPE   varchar2(10);
v_strLNACTYPE   varchar2(10);
v_strMRTYPE varchar2(10);
v_strAUTOADV CHAR(1);
v_dblMRIRATE number;
v_dblMRMRATE number;
v_dblMRLRATE number;
v_blnUpdate BOOLEAN;
v_strOldcorebank    varchar2(10);
v_strOldautoadv CHAR(1);
v_dblOldmrirate number;
v_dblOldmrmrate number;
v_dblOldmrlrate number;
v_busdate   varchar2(20);
v_oldactype  VARCHAR2(10);
BEGIN
    --Cap nhat autoid
    UPDATE TBLCHANGECFTYPE SET autoid = seq_TBLCHANGECFTYPE.NEXTVAL;
    for rec in (
        select * from TBLCHANGECFTYPE TBL  where status = 'P'
    )
    loop
        --Thuc hien thay doi loai h? hop dong
        v_blnUpdate:= true;

        --Goi thu tuc check
        cspks_cfproc.pr_CFMAST_ChangeTypeCheck(rec.custid,rec.newcftype,p_err_code);
        if p_err_code <> 0 then
            UPDATE TBLCHANGECFTYPE SET deltd='Y' , errmsg =errmsg || 'Error:' || cspks_system.fn_get_errmsg(p_err_code) WHERE autoid = rec.autoid;
            v_blnUpdate:= false;
        end if;


        if v_blnUpdate = true then
            cspks_cfproc.pr_ChangeCFType(rec.custid,rec.newcftype,p_err_code);
            if p_err_code <> 0 then
                UPDATE TBLCHANGECFTYPE SET deltd='Y' , errmsg =errmsg || 'Error:' || cspks_system.fn_get_errmsg(p_err_code) WHERE autoid = rec.autoid;
                v_blnUpdate:= false;
            ELSE

                UPDATE CFMAST SET ACTYPE=REC.NEWCFTYPE WHERE CUSTID=REC.CUSTID;
                UPDATE TBLCHANGECFTYPE SET status ='A' , errmsg ='Thanh cong' WHERE autoid = rec.autoid;

                INSERT INTO changecftype_log (autoid,custid,txdate, txnums, oldactype, Newactype, makerid, checkerid, deltd)
                VALUES (seq_changecftype_log.nextval,rec.custid ,trunc (rec.importdt), 'IMPORTS', rec.oldcftype,rec.newcftype, rec.tlid, p_tlid,'N');
                FOR rec2 IN (
                    SELECT AF.ACCTNO, MAX(MST.AMT) AMT, max(AFT.MRCRLIMITMAX) AFTMRCRLIMITMAX
                    FROM MRPRMLIMITCF MRCF, MRPRMLIMITMST MST, AFMAST AF, AFTYPE AFT, MRTYPE MRT
                    WHERE MRCF.PROMOTIONID = MST.AUTOID
                        AND MRCF.AFACCTNO = AF.ACCTNO AND AF.ACTYPE = AFT.ACTYPE
                        AND AFT.MRTYPE = MRT.ACTYPE AND MRT.MRTYPE IN ('T','S')
                        AND Getcurrdate BETWEEN MRCF.VALDATE AND MRCF.EXPDATE
                        AND MRCF.STATUS = 'A' and MRCF.CUSTID = rec.custid
                    GROUP BY AF.ACCTNO
                ) LOOP
                    UPDATE AFMAST AF
                    SET AF.MRCRLIMITMAX = GREATEST(AF.MRCRLIMITMAX,NVL(rec2.AMT,0), NVL(rec2.AFTMRCRLIMITMAX,0))
                    WHERE AF.ACCTNO = rec2.ACCTNO;
                END LOOP;
             end if;
        end if;
    end loop;
    --Backup luu lai lich su
    insert into TBLCHANGECFTYPE_HIST (CUSTID,CUSTODYCD,FULLNAME,OLDCFTYPE,NEWCFTYPE,DELTD,STATUS,ERRMSG,DESCRIPTION,TLID,IMPORTDT,AUTOID,APPROVEDT)
    select CUSTID,CUSTODYCD,FULLNAME,OLDCFTYPE,NEWCFTYPE,DELTD,STATUS,ERRMSG,DESCRIPTION,TLID,IMPORTDT,AUTOID, SYSTIMESTAMP from  TBLCHANGECFTYPE;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLCHANGECFTYPE;

---IMPORT GAN KHACH HANG CHO MOI GIOI
PROCEDURE PR_FILE_TBLRE0384(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
    v_count     NUMBER;
    v_cfstatus  varchar2(1);
    v_restatus  varchar2(1);
    v_afacctno  varchar2(10);
    v_custid    varchar2(10);
    v_cusname   varchar2(500);
    v_recustid  varchar2(30);
    v_reactype  varchar2(10);
BEGIN
v_count := 0;
--Cap nhat autoid
UPDATE TBLRE0384 SET autoid = seq_TBLRE0384.NEXTVAL;
--CHECK DU LIEU.
FOR REC IN
    (SELECT autoid, custodycd, afacctno, custname, recustid,
       reacctno, reactype, amt, deltd, status, errmsg,
       des, fileid FROM TBLRE0384 )
LOOP

    IF REC.reacctno is null OR rec.custodycd IS NULL THEN
        UPDATE TBLRE0384 SET deltd = 'Y' , errmsg = errmsg ||'Error: REACCTNO OR CUSTODYCD is null!'
        WHERE autoid = rec.autoid;
    ELSE
        select count(1) into v_count
        from TBLRE0384 where custodycd = rec.custodycd;
        IF NVL(v_count,0) > 1 THEN
            UPDATE TBLRE0384 SET deltd='Y' , errmsg = errmsg ||'Error: CUSTODYCD is duplicate!' WHERE custodycd = rec.custodycd;
        end if;
        begin
            select status, custid into v_cfstatus, v_custid from cfmast where custodycd = rec.custodycd;
            select status, custid, actype into v_restatus, v_recustid, v_reactype
            from remast where acctno = rec.reacctno;
        exception when others then
            v_cfstatus := 'C';
            v_restatus := 'C';
        end ;
        if (v_cfstatus <> 'A' or v_restatus <> 'A') then
            UPDATE TBLRE0384 SET deltd='Y' , errmsg = errmsg ||'Error: status Invalid!'
            WHERE autoid = rec.autoid;
        end if;

        select count(1) into v_count from reaflnk
        where status = 'A' and clstxdate is null and deltd  <> 'Y'
            and reacctno = rec.reacctno and afacctno = v_custid;
        if (nvl(v_count,0) = 1) then
            select max(af.acctno), max(cf.fullname) into v_afacctno, v_cusname
            from afmast af, cfmast cf
            where af.custid = cf.custid and af.status = 'A';
            UPDATE TBLRE0384 SET afacctno = v_afacctno, custname = v_cusname,
                recustid = v_recustid, reactype = v_reactype
            WHERE autoid = rec.autoid;
        else
            UPDATE TBLRE0384 SET deltd = 'Y' , errmsg = errmsg ||'Error: reaflnk Invalid !'
            WHERE autoid = rec.autoid;
        end if;
    END IF;

END LOOP;
    plog.debug( pkgctx, ' finish ');
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_TBLRE0384;
PROCEDURE PR_FILE_TBLRE0380(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
  V_COUNT      NUMBER;
  V_CFSTATUS   VARCHAR2(1);
  V_RESTATUS   VARCHAR2(1);
  V_AFACCTNO   VARCHAR2(10);
  V_CUSTID     VARCHAR2(10);
  V_CUSNAME    VARCHAR2(500);
  V_RECUSTID   VARCHAR2(30);
  V_REACTYPE   VARCHAR2(10);
  V_REFULLNAME VARCHAR2(100);
  V_REROLE VARCHAR2(10);
  V_STRCUSTOMERID VARCHAR2(10);
  V_check0380 NUMBER;
BEGIN

  V_COUNT := 0;
  --Cap nhat autoid
  UPDATE TBLRE0380 SET AUTOID = SEQ_TBLRE0380.NEXTVAL;
  --CHECK DU LIEU.
  FOR REC IN (SELECT AUTOID,
                     CUSTODYCD,
                     CUSTNAME,
                     FROMDATE,
                     TODATE,
                     AMT,
                     REACCTNO,
                     RECUSTNAME,
                     REROLE,
                     ORGREACCTNO,
                     REACTYPE,
                     DELTD,
                     STATUS,
                     ERRMSG,
                     DES,
                     FILEID
                FROM TBLRE0380) LOOP

                                -----check khong cho phep gan vao loai hinh gian tiep
        SELECT COUNT(1) INTO v_count FROM retype WHERE actype = SUBSTR(rec.reacctno,11,4) AND retype = 'I';
        IF v_count <> 0 THEN
            UPDATE TBLRE0380 SET deltd = 'Y', errmsg = 'khong duoc gan khach hang vao loai hinh gian tiep' WHERE autoid = rec.autoid;
        END IF;
        ----bao loi neu khach hang da co moi gioi cung loai
        SELECT COUNT(1) INTO v_count  FROM reaflnk l, remast r, retype rt , retype nrt, remast nr
        WHERE l.status = 'A' AND r.actype = rt.actype AND l.reacctno = r.acctno
            AND l.afacctno IN (SELECT custid FROM cfmast WHERE custodycd = rec.custodycd )
            AND rt.retype = nrt.retype AND  nrt.actype = nr.actype
            AND nr.acctno = rec.reacctno
            AND (nrt.rerole = rt.rerole OR ( nrt.rerole IN ('CS','RM') AND rt.rerole IN ('CS','RM') ) )
    --check neu khac khoang thoi gian thi van duoc gan
            AND l.todate >=  to_date(rec.fromdate,'DD/MM/RRRR') AND  l.frdate <= to_date(rec.todate,'DD/MM/RRRR');
    if v_count <> 0 then
        UPDATE TBLRE0380 SET deltd = 'Y', errmsg = 'Tai khoan da co moi gioi quan ly' WHERE autoid = rec.autoid;
    end if;
                --------------------------------

     -- Ktra ngay bat dau phai nho hon ngay ket thuc va ngay bat dau phai lon hoan bang ngya hien tai
                Select count(*) into V_COUNT
                from dual where rec.fromdate<rec.todate and rec.fromdate>=getcurrdate;
                if V_COUNT=0 then
                    UPDATE TBLRE0380
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Gia tri ngay khong hop le!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;
                  end if;
                  --Ktra gia tri tien phi phai lon =0
                  Select count(*) into V_COUNT
                from dual where rec.amt>=0 ;
                if V_COUNT=0 then
                    UPDATE TBLRE0380
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Gia tri tien phai lon hon 0!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;
                  end if;
    --Ktra ma MG, ma KH co ton tai ko

    IF REC.REACCTNO IS NULL OR REC.CUSTODYCD IS NULL THEN
      UPDATE TBLRE0380
         SET DELTD  = 'Y',
             ERRMSG = ERRMSG || 'Error: Ma moi gioi hoac so luu ky khong duoc de trong!'
       WHERE AUTOID = REC.AUTOID;
    ELSE
      --Ktra co khai bao trung kh trong file khong

      SELECT COUNT(1)
        INTO V_COUNT
        FROM TBLRE0380
       WHERE CUSTODYCD = REC.CUSTODYCD;
      IF NVL(V_COUNT, 0) > 1 THEN
        UPDATE TBLRE0380
           SET DELTD  = 'Y',
               ERRMSG = ERRMSG || 'Error: So luu ky trung trong file!'
         WHERE CUSTODYCD = REC.CUSTODYCD;
      END IF;

      BEGIN
        --Ktra trang thai Kh va MG co hop le khong  (trang thai hop le la A)

        SELECT STATUS, CUSTID, ACTYPE
          INTO V_RESTATUS, V_RECUSTID, V_REACTYPE
          FROM REMAST
         WHERE ACCTNO = REC.REACCTNO;
      EXCEPTION
        WHEN OTHERS THEN
          V_RESTATUS := 'C';
      END;

      BEGIN
        --Ktra trang thai Kh va MG co hop le khong  (trang thai hop le la A)

        SELECT STATUS, CUSTID
          INTO V_CFSTATUS, V_CUSTID
          FROM CFMAST
         WHERE CUSTODYCD = REC.CUSTODYCD;
    EXCEPTION
        WHEN OTHERS THEN
          V_CFSTATUS := 'C';
      END;

      IF (V_CFSTATUS <> 'A' OR V_RESTATUS <> 'A') THEN
        UPDATE TBLRE0380
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Trang thai khach hang hoac trang thai moi gioi khong hop le!'
         WHERE AUTOID = REC.AUTOID;
      END IF;
        --Thong tin kh

        SELECT MAX(AF.ACCTNO), MAX(CF.FULLNAME)
          INTO V_AFACCTNO, V_CUSNAME
          FROM AFMAST AF, CFMAST CF
         WHERE AF.CUSTID = CF.CUSTID
           AND AF.STATUS = 'A'
           AND CF.CUSTODYCD=REC.CUSTODYCD;
        --Thong tin MG
        if(V_CUSNAME is null) then
            UPDATE TBLRE0380
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Chua khai bao tieu khoan cho khach hang!'
         WHERE AUTOID = REC.AUTOID;
        end if;

        BEGIN
            SELECT CFMAST.FULLNAME, TYP.REROLE
              INTO V_REFULLNAME, V_REROLE
              FROM RECFDEF RF,
                   RETYPE  TYP,
                   RECFLNK CF,
                   CFMAST
         WHERE
           RF.REACTYPE = TYP.ACTYPE
           AND RF.REFRECFLNKID = CF.AUTOID
           AND CF.CUSTID = CFMAST.CUSTID
           AND TYP.REROLE <> 'DG'
           AND CF.CUSTID||RF.REACTYPE=rec.REACCTNO;
        EXCEPTION
        WHEN OTHERS THEN
          V_REFULLNAME := 'X';
          V_REROLE := 'X';
        END;
      IF V_REFULLNAME = 'X' AND V_REROLE = 'X' THEN
        UPDATE TBLRE0380
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Khong tim thay thong tin moi gioi!'
         WHERE AUTOID = REC.AUTOID;
      END IF;
      --Check cac dk cua 0380

                  --Ki?m tra kh?du?c khai b?tr?ng
                  --M?i customer ch? c?i da 1 ngu?i gi?i thi?u, 01 BR hoac 01 AE

                  SELECT COUNT(LNK.AUTOID)
                    INTO V_check0380
                    FROM REAFLNK LNK,
                             REMAST  ORGMST,
                             RETYPE  ORGTYP,
                             REMAST  RFMST,
                             RETYPE  RFTYP
                   WHERE LNK.STATUS = 'A'
                         AND ORGMST.ACTYPE = ORGTYP.ACTYPE
                         AND LNK.REACCTNO = ORGMST.ACCTNO
                         AND LNK.AFACCTNO = V_CUSTID
                         AND (RFTYP.REROLE = ORGTYP.REROLE OR
                             (RFTYP.REROLE IN ('BM', 'RM') AND ORGTYP.REROLE IN ('BM', 'RM')))
                         AND RFMST.ACTYPE = RFTYP.ACTYPE
                         AND RFMST.ACCTNO = rec.reacctno
                         AND (   (LNK.FRDATE <= rec.fromdate  AND LNK.TODATE >= rec.fromdate)
                             OR (LNK.FRDATE <= rec.todate AND  lnk.todate >= rec.todate ) );

                   IF  ( V_check0380 > 0) THEN
                          UPDATE TBLRE0380
                             SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Dang ky trung vai tro moi gioi!'
                           WHERE AUTOID = REC.AUTOID;
                  END IF;

                    --Ki?m tra kh?cho ph?v?a l??i?i v?a l?ham s??
                   IF REC.REROLE='DG' THEN
                             select count(1)  INTO V_check0380
                             from reaflnk rl , retype rty , recflnk rcl
                              where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                                    and  rl.status='A' and rty.rerole <>'DG' and rl.afacctno= V_CUSTID
                                    and rcl.custid =V_RECUSTID;
                            IF  ( V_check0380 > 0) THEN
                                UPDATE TBLRE0380
                                 SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Not have include RM, DG!'
                               WHERE AUTOID = REC.AUTOID;
                             END IF;
                       ELSE
                          select count(1)  INTO V_check0380
                          from reaflnk rl , retype rty , recflnk rcl
                           where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                          and rl.status='A' and rty.rerole ='DG' and rl.afacctno=  V_CUSTID
                          and rcl.custid = V_RECUSTID;
                                   IF  ( V_check0380 > 0) THEN
                                     UPDATE TBLRE0380
                                       SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Not have include RM, DG!'
                                     WHERE AUTOID = REC.AUTOID;
                                   END IF;
                     END IF;


           --fill thong tin vao TBLRE0380

        UPDATE TBLRE0380
           SET CUSTNAME = V_CUSNAME,
               RECUSTID = V_RECUSTID,
               REACTYPE = V_REACTYPE,
               RECUSTNAME= V_REFULLNAME,
               REROLE=V_REROLE
         WHERE AUTOID = REC.AUTOID;


    END IF;

  END LOOP;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    plog.error ('PR_FILE_TBLRE0380: ' || SQLERRM || dbms_utility.format_error_backtrace);
    RETURN;
END PR_FILE_TBLRE0380;










PROCEDURE PR_APR_FILE_TBLRE0380(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
    v_strDesc       varchar2(1000);
    v_strEN_Desc    varchar2(1000);
    l_err_param     varchar2(500);
    v_strCURRDATE   varchar2(20);
    V_STRCUSTOMERID varchar2(20);
    L_txnum         VARCHAR2(20);
    V_check0380     NUMBER;
    l_txmsg         tx.msg_rectype;
BEGIN

  SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='0380';
        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_strCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO L_txnum
              FROM DUAL;
        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := P_TLID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'AUTO';
        l_txmsg.reftxnum    := L_txnum;
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='0380';

        FOR REC in (
                      SELECT * FROM tblRE0380 tbl
                      WHERE nvl(tbl.deltd,'N') <> 'Y' and nvl(tbl.status,'A') <> 'C'
                )
            loop
                SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
                    -- Tao giao dich 0380
                        --06    ?n ng?  C
                             l_txmsg.txfields ('06').defname   := 'TODATE';
                             l_txmsg.txfields ('06').TYPE      := 'C';
                             l_txmsg.txfields ('06').value      := rec.TODATE;
                        --30    Di?n gi?i   C
                             l_txmsg.txfields ('30').defname   := 'T_DESC';
                             l_txmsg.txfields ('30').TYPE      := 'C';
                             l_txmsg.txfields ('30').value      :=  NVL(REC.DES,v_strDesc);
                        --88    S? TK luu k?   C
                             l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                             l_txmsg.txfields ('88').TYPE      := 'C';
                             l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
                        --31    TKMG g?c nh? cham s? C
                             l_txmsg.txfields ('31').defname   := 'ORGREACCTNO';
                             l_txmsg.txfields ('31').TYPE      := 'C';
                             l_txmsg.txfields ('31').value      := '';
                        --02    Tham chi?u m?i?i    C
                             l_txmsg.txfields ('02').defname   := 'RECUSTID';
                             l_txmsg.txfields ('02').TYPE      := 'C';
                             l_txmsg.txfields ('02').value      := rec.RECUSTID;
                        --10    Gi?r? di?u ch?nh hoa h?ng   N
                             l_txmsg.txfields ('10').defname   := 'AMT';
                             l_txmsg.txfields ('10').TYPE      := 'N';
                             l_txmsg.txfields ('10').value      := rec.AMT;
                        --08    T?kho?n m?i?i   C
                             l_txmsg.txfields ('08').defname   := 'REACCTNO';
                             l_txmsg.txfields ('08').TYPE      := 'C';
                             l_txmsg.txfields ('08').value      := rec.REACCTNO;
                        --07    Lo?i h? m?i?i   C
                             l_txmsg.txfields ('07').defname   := 'REACTYPE';
                             l_txmsg.txfields ('07').TYPE      := 'C';
                             l_txmsg.txfields ('07').value      := rec.REACCTNO;
                        --09    Vai tr?C
                             l_txmsg.txfields ('09').defname   := 'REROLE';
                             l_txmsg.txfields ('09').TYPE      := 'C';
                             l_txmsg.txfields ('09').value      := rec.REROLE;
                        --05    T? ng?  C
                             l_txmsg.txfields ('05').defname   := 'FRDATE';
                             l_txmsg.txfields ('05').TYPE      := 'C';
                             l_txmsg.txfields ('05').value      := rec.FROMDATE;
                        --90    T?ch? t?kho?n   C
                             l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                             l_txmsg.txfields ('90').TYPE      := 'C';
                             l_txmsg.txfields ('90').value      := rec.CUSTNAME;
                        --91    T?m?i?i   C
                             l_txmsg.txfields ('91').defname   := 'RECUSTNAME';
                             l_txmsg.txfields ('91').TYPE      := 'C';
                             l_txmsg.txfields ('91').value      := rec.RECUSTNAME;
                        --11    REROLEDESC   C
                             l_txmsg.txfields ('11').defname   := 'REROLEDESC';
                             l_txmsg.txfields ('11').TYPE      := 'C';
                             l_txmsg.txfields ('11').value      := rec.REROLE;
                        --12    REROLE  C
                             l_txmsg.txfields ('12').defname   := 'REROLE';
                             l_txmsg.txfields ('12').TYPE      := 'C';
                             l_txmsg.txfields ('12').value      := rec.REROLE;
                     --Check cac dk cua 0380
                    --Lay thong tin kh
                   SELECT CUSTID
                    INTO V_STRCUSTOMERID
                    FROM CFMAST CF
                   WHERE CF.CUSTODYCD = rec.custodycd;
                  --Ki?m tra kh?du?c khai b?tr?ng
                  --M?i customer ch? c?i da 1 ngu?i gi?i thi?u, 01 BR hoac 01 AE
                  SELECT COUNT(LNK.AUTOID)
                    INTO V_check0380
                    FROM REAFLNK LNK,
                             REMAST  ORGMST,
                             RETYPE  ORGTYP,
                             REMAST  RFMST,
                             RETYPE  RFTYP
                   WHERE LNK.STATUS = 'A'
                         AND ORGMST.ACTYPE = ORGTYP.ACTYPE
                         AND LNK.REACCTNO = ORGMST.ACCTNO
                         AND LNK.AFACCTNO = V_STRCUSTOMERID
                         AND (RFTYP.REROLE = ORGTYP.REROLE OR
                             (RFTYP.REROLE IN ('BM', 'RM') AND ORGTYP.REROLE IN ('BM', 'RM')))
                         AND RFMST.ACTYPE = RFTYP.ACTYPE
                         AND RFMST.ACCTNO = rec.reacctno
                                AND (  (LNK.FRDATE <=rec.fromdate  AND LNK.TODATE >= rec.fromdate)
                             OR (LNK.FRDATE <= rec.todate AND  lnk.todate >= rec.todate  ) );
                   IF  ( V_check0380 > 0) THEN
                           UPDATE TBLRE0380
                             SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Dubplicate setup!'
                           WHERE AUTOID = REC.AUTOID;
                  END IF;
                    --Ki?m tra kh?cho ph?v?a l??i?i v?a l?ham s??
                   IF REC.REROLE='DG' THEN
                             select count(1)  INTO V_check0380
                             from reaflnk rl , retype rty , recflnk rcl
                              where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                                    and  rl.status='A' and rty.rerole <>'DG' and rl.afacctno= v_strCustomerID
                                    and rcl.custid =rec.RECUSTID;
                            IF  ( V_check0380 > 0) THEN
                                UPDATE TBLRE0380
                                 SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Not have include RM, DG!'
                               WHERE AUTOID = REC.AUTOID;
                             END IF;
                       ELSE
                          select count(1)  INTO V_check0380
                          from reaflnk rl , retype rty , recflnk rcl
                           where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                          and rl.status='A' and rty.rerole ='DG' and rl.afacctno=  v_strCustomerID
                          and rcl.custid = rec.RECUSTID;
                                   IF  ( V_check0380 > 0) THEN
                                     UPDATE TBLRE0380
                                       SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Not have include RM, DG!'
                                     WHERE AUTOID = REC.AUTOID;
                                   END IF;
                     END IF;
                         -----end check dk 0380-------
                          SELECT COUNT(1)  INTO V_check0380
                           FROM  tblRE0380 tbl
                      WHERE AUTOID = REC.AUTOID AND  nvl(deltd,'N') <> 'Y' ;
                      IF (V_check0380>0) then
                    BEGIN
                        IF txpks_#0380.fn_batchtxprocess (l_txmsg,p_err_code,l_err_param) <> systemnums.c_success
                        THEN
                           plog.debug(pkgctx,'got error 0380: ' || p_err_code);
                           ROLLBACK;
                       ELSE
                            update TBLRE0380 set status = 'C' where autoid = rec.AUTOID;
                            insert into TBLRE0380HIST (select * from TBLRE0380 WHERE autoid = rec.AUTOID);
                        END IF;
                    END;
                    end if;
            end loop;
        ---insert into TBLRE0380HIST select * from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
        ---delete from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    plog.error ('PR_APR_FILE_TBLRE0380: ' || SQLERRM || dbms_utility.format_error_backtrace);
    RETURN;
END PR_APR_FILE_TBLRE0380;

-- BEGIN BINHVT
PROCEDURE PR_FILE_TBLRE_0384(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
  V_COUNT      NUMBER;
  V_CFSTATUS   VARCHAR2(1);
  V_RESTATUS   VARCHAR2(1);
  V_AFACCTNO   VARCHAR2(10);
  V_CUSTID     VARCHAR2(10);
  V_CUSNAME    VARCHAR2(500);
  V_RECUSTID   VARCHAR2(30);
  V_REACTYPE   VARCHAR2(10);
  V_REFULLNAME VARCHAR2(100);
  V_REROLE VARCHAR2(10);
  V_STRCUSTOMERID VARCHAR2(10);
  V_check0380 NUMBER;
BEGIN

  V_COUNT := 0;
  --Cap nhat autoid
  UPDATE TBLRE_0384 SET AUTOID = SEQ_TBLRE_0384.NEXTVAL;
  --CHECK DU LIEU.
  FOR REC IN (SELECT *
                FROM TBLRE_0384) LOOP

                --------------------------------

                  --Ktra gia tri tien phi phai lon =0
                  Select count(*) into V_COUNT
                from dual where rec.amt>=0 ;
                if V_COUNT=0 then
                    UPDATE TBLRE_0384
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Gia tri tien phai lon hon 0!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;
                  end if;
    --Ktra ma MG, ma KH co ton tai ko

    IF REC.REACCTNO IS NULL OR REC.CUSTODYCD IS NULL THEN
      UPDATE TBLRE_0384
         SET DELTD  = 'Y',
             ERRMSG = ERRMSG || 'Error: Ma moi gioi hoac so luu ky khong duoc de trong!'
       WHERE AUTOID = REC.AUTOID;
    ELSE
      --Ktra co khai bao trung kh trong file khong

      SELECT COUNT(1)
        INTO V_COUNT
        FROM TBLRE_0384
       WHERE CUSTODYCD = REC.CUSTODYCD;
      IF NVL(V_COUNT, 0) > 1 THEN
        UPDATE TBLRE_0384
           SET DELTD  = 'Y',
               ERRMSG = ERRMSG || 'Error: So luu ky trung trong file!'
         WHERE CUSTODYCD = REC.CUSTODYCD;
      END IF;
      BEGIN
        --Ktra trang thai Kh va MG co hop le khong  (trang thai hop le la A)

        SELECT STATUS, CUSTID
          INTO V_CFSTATUS, V_CUSTID
          FROM CFMAST
         WHERE CUSTODYCD = REC.CUSTODYCD;
        SELECT STATUS, CUSTID, ACTYPE
          INTO V_RESTATUS, V_RECUSTID, V_REACTYPE
          FROM REMAST
         WHERE ACCTNO = REC.REACCTNO;
      EXCEPTION
        WHEN OTHERS THEN
          V_CFSTATUS := 'C';
      END;

      Begin
        SELECT STATUS, CUSTID, ACTYPE
          INTO V_RESTATUS, V_RECUSTID, V_REACTYPE
          FROM REMAST
         WHERE ACCTNO = REC.REACCTNO;
      EXCEPTION
        WHEN OTHERS THEN
          V_RESTATUS := 'C';
      End;

      IF (V_CFSTATUS <> 'A' OR V_RESTATUS <> 'A') THEN
        UPDATE TBLRE_0384
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Trang thai khach hang hoac trang thai moi gioi khong hop le!'
         WHERE AUTOID = REC.AUTOID;
      END IF;
        --Thong tin kh

        SELECT MAX(AF.ACCTNO), MAX(CF.FULLNAME)
          INTO V_AFACCTNO, V_CUSNAME
          FROM AFMAST AF, CFMAST CF
         WHERE AF.CUSTID = CF.CUSTID
           AND AF.STATUS = 'A'
           AND CF.CUSTODYCD=REC.CUSTODYCD;
        --Thong tin MG
        if(V_CUSNAME is null) then
            UPDATE TBLRE_0384
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Chua khai bao tieu khoan cho khach hang!'
         WHERE AUTOID = REC.AUTOID;
        end if;

        BEGIN
            SELECT CFMAST.FULLNAME, TYP.REROLE
              INTO V_REFULLNAME, V_REROLE
              FROM RECFDEF RF,
                   RETYPE  TYP,
                   RECFLNK CF,
                   CFMAST
         WHERE
           RF.REACTYPE = TYP.ACTYPE
           AND RF.REFRECFLNKID = CF.AUTOID
           AND CF.CUSTID = CFMAST.CUSTID
           AND TYP.REROLE <> 'DG'
           AND CF.CUSTID||RF.REACTYPE=rec.REACCTNO;
        EXCEPTION
        WHEN OTHERS THEN
          V_REFULLNAME := 'X';
          V_REROLE := 'X';
        END;
      IF V_REFULLNAME = 'X' AND V_REROLE = 'X' THEN
        UPDATE TBLRE_0384
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Khong tim thay thong tin moi gioi!'
         WHERE AUTOID = REC.AUTOID;
      END IF;


      --- kiem tra khach hang da duoc gan cho mg chua
      BEGIN
          select count(1) into V_COUNT from    REAFLNK re ,afmast af, cfmast cf
     where af.custid = cf.custid
     and re.afacctno = cf.custid
     and re.reacctno = rec.reacctno
     and re.status = 'A'
     and cf.custodycd = rec.custodycd ;
        EXCEPTION
        WHEN OTHERS THEN
          V_COUNT := 0;
        END;
      IF V_COUNT = 0 THEN
        UPDATE TBLRE_0384
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: tai khoan chua duoc gan cho moi gioi!'
         WHERE AUTOID = REC.AUTOID;
      END IF;


    END IF;

  END LOOP;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    RETURN;
END PR_FILE_TBLRE_0384;
PROCEDURE PR_APR_FILE_TBLRE_0384(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
    v_strDesc       varchar2(1000);
    v_strEN_Desc    varchar2(1000);
    l_err_param     varchar2(500);
    v_strCURRDATE   varchar2(20);
    V_STRCUSTOMERID varchar2(20);
    L_txnum         VARCHAR2(20);
    V_check0380     NUMBER;
    l_txmsg         tx.msg_rectype;
BEGIN

  SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='0384';
        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_strCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO L_txnum
              FROM DUAL;
        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := P_TLID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'AUTO';
        l_txmsg.reftxnum    := L_txnum;
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='0384';

        FOR REC in (
                      SELECT tbl.*,cf.custid FROM tblRE_0384 tbl,cfmast cf
                      WHERE nvl(tbl.deltd,'N') <> 'Y' and nvl(tbl.status,'A') <> 'C'
                      and tbl.custodycd = cf.custodycd
                )
            loop
                SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
                    -- Tao giao dich 0380

                        --30    Di?n gi?i   C
                             l_txmsg.txfields ('30').defname   := 'T_DESC';
                             l_txmsg.txfields ('30').TYPE      := 'C';
                             l_txmsg.txfields ('30').value      :=  NVL(REC.DES,v_strDesc);
                        --88    S? TK luu k?   C
                             l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                             l_txmsg.txfields ('88').TYPE      := 'C';
                             l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
                      --03    S? TK luu k?   C
                             l_txmsg.txfields ('03').defname   := 'ACCTNO';
                             l_txmsg.txfields ('03').TYPE      := 'C';
                             l_txmsg.txfields ('03').value      := rec.custid;

                        --02    Tham chi?u m?i?i    C
                             l_txmsg.txfields ('20').defname   := 'RECUSTID';
                             l_txmsg.txfields ('20').TYPE      := 'C';
                         --    l_txmsg.txfields ('20').value      := rec.RECUSTID;
                        --10    Gi?r? di?u ch?nh hoa h?ng   N
                             l_txmsg.txfields ('10').defname   := 'AMT';
                             l_txmsg.txfields ('10').TYPE      := 'N';
                             l_txmsg.txfields ('10').value      := rec.AMT;
                        --08    T?kho?n m?i?i   C
                             l_txmsg.txfields ('21').defname   := 'REACCTNO';
                             l_txmsg.txfields ('21').TYPE      := 'C';
                             l_txmsg.txfields ('21').value      := rec.REACCTNO;
                        --07    Lo?i h? m?i?i   C
                             l_txmsg.txfields ('07').defname   := 'REACTYPE';
                             l_txmsg.txfields ('07').TYPE      := 'C';
                          --   l_txmsg.txfields ('07').value      := rec.retype;

                        --90    T?ch? t?kho?n   C
                             l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                             l_txmsg.txfields ('90').TYPE      := 'C';
                        --     l_txmsg.txfields ('90').value      := rec.CUSTNAME;
                        --91    T?m?i?i   C
                             l_txmsg.txfields ('23').defname   := 'RECUSTNAME';
                             l_txmsg.txfields ('23').TYPE      := 'C';
                         --    l_txmsg.txfields ('23').value      := rec.--RECUSTNAME;

                    BEGIN
                        IF txpks_#0384.fn_batchtxprocess (l_txmsg,p_err_code,l_err_param) <> systemnums.c_success
                        THEN
                           plog.debug(pkgctx,'got error 0384: ' || p_err_code);
                           ROLLBACK;
                       ELSE
                            update TBLRE_0384 set status = 'C' where autoid = rec.AUTOID;
                            insert into TBLRE_0384HIST (select * from TBLRE_0384 WHERE autoid = rec.AUTOID);
                        END IF;
                    END;
            end loop;
        ---insert into TBLRE0380HIST select * from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
        ---delete from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    RETURN;
END PR_APR_FILE_TBLRE_0384;

PROCEDURE PR_FILE_BONDIPO(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
  V_COUNT      NUMBER;

BEGIN

  V_COUNT := 0;
  --Cap nhat autoid
  UPDATE TBLBONDIPO SET AUTOID = SEQ_TBLBONDIPO.NEXTVAL;
  --CHECK DU LIEU.
  FOR REC IN (SELECT *
                FROM TBLBONDIPO) LOOP

                --------------------------------

                  --Ktra gia tri tien phi phai lon =0
                  Select count(*) into V_COUNT
                from dual where rec.parvalue <0
                or rec.Period <0
                or rec.WININTEREST <0
                or rec.COUPON >=0
                or rec.LOWESTINTEREST <0
                or rec.HIGHESTINTERVEST <0
                or rec.Offeringamount <0
                or rec.WINAMOUNT <0
                or rec.PARVALUE <0
                or rec.BIDDER <0
                or rec.OFFERAMOUNT <0
                or rec.REGISAMOUNT <0
                or rec.WINAMOUNT  <0
                or rec.PAYAMOUNTEXTRA <0
                or rec.BIDDEREXTRA <0
                or rec.TOTALWINAMOUNT <0
                or rec.TOTALOFFERAMOUNT <0
                or rec.TOTALPAYMOUNT <0
                or rec.TOTALREGISAMOUNT <0  ;
                if V_COUNT=0 then
                    UPDATE TBLBONDIPO
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Gia tri phai lon hon 0!'
                     WHERE autoid  = REC.autoid;
                  end if;
    --Ktra xem ma tp co trong danh muc khong
      /*Select count(*) into V_COUNT from sbsecurities b
      where  b.symbol = rec.bondcode;
      if V_COUNT  = 0 then
       UPDATE TBLBONDIPO
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Ma tp khong ton tai 0!'
                     WHERE autoid  = REC.autoid;
       end if;*/

      --Ktra co khai bao trung kh trong file khong

      /*SELECT COUNT(1)
        INTO V_COUNT
        FROM TBLBONDIPO
       WHERE bondcode = REC.bondcode;
      IF NVL(V_COUNT, 0) > 1 THEN
        UPDATE TBLBONDIPO
           SET DELTD  = 'Y',
               ERRMSG = ERRMSG || 'Error: Ma tp trung trong file!'
         WHERE autoid = REC.autoid;*/
      --END IF;

  END LOOP;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    RETURN;
END PR_FILE_BONDIPO;

PROCEDURE PR_APR_FILE_BONDIPO(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS

BEGIN

   for v_rec in (SELECT * FROM TBLBONDIPO tbl
        WHERE nvl(tbl.deltd,'N') <> 'Y' and nvl(tbl.status,'A') <> 'C') loop
   insert into BONDIPO(autoid   ,
  custid          ,
  txdate          ,
  issdate         ,
  expdate         ,
  codeid          ,
  bidqtty         ,
  winqtty         ,
  bidblkratio     ,
  ownamt          ,
  cfamt           ,
  notes           ,
  bondtype        ,
  bondissuer      ,
  term            ,
  bidothfee       ,
  bidblk          ,
  vouchfee        ,
  bondmethod     ,
  period          ,
  guarantees      ,
  prizeinterest   ,
  mininterest     ,
  coupon          ,
  sharerate       ,
  bidinterest     ,
  grbidrate       ,
  releasemod      ,
  ccycd           ,
  grnumber        ,
  bidnumber       ,
  treasurybill    ,
  listingqtty     ,
  isstmpdate     ,
  isspaydate      ,
  benecomp       ,
  beneaccount     ,
  beneaddress     ,
  maxinterest     ,
  totalqtty       ,
  bondid          ,
  ipotype        ,
  isstmp          ,
  winrate         ,
  bidrate         ,
  wininterest    ,
  status         ,
  pstatus         ,
  parvalue        ,
  bidder          ,
  payment         ,
  offeramount     ,
  regisamount     ,
  winamount      ,
  payamount      ,
  bidderextra    ,
  toalwinamount  ,
  toalofferamount ,
  toalpaymount    ,
  toalregisamount )  values(seq_BONDIPO.Nextval,
                            null          ,
  getcurrdate          ,
  TO_DATE(v_rec.issuedate,'MM/dd/rrrr')         ,
  to_date(v_rec.Maturitydate,'MM/dd/rrrr')         ,
  v_rec.bondcode          ,
  v_rec.biddingamount         ,
  v_rec.WINAMOUNT         ,
  null     ,
  0          ,
  0           ,
  v_rec.note           ,
  v_rec.Bondtype        ,
  v_rec.Issuer      ,
  v_rec.Period            ,
  null       ,
   null          ,
   null        ,
  null     ,
  null          ,
  null      ,
  null   ,
  v_rec.LOWESTINTEREST     ,
  v_rec.coupon          ,
  null       ,
  null     ,
  null       ,
  null      ,
  v_rec.currency           ,
  null        ,
  v_Rec.Bidder       ,
  v_rec.bondtype ,
  null     ,
  to_date(v_rec.Auctiondate,'MM/dd/rrrr')     ,
  to_date(v_rec.Settlementdate,'MM/dd/rrrr')      ,
  null       ,
  null     ,
  null     ,
  v_rec.HIGHESTINTERVEST     ,
  v_rec.Offeringamount       ,
  TO_CHAR(getcurrdate,'ddMMrrrr')||v_Rec.bondcode||v_rec.period ,
  null        ,
  v_rec.issuer   ,
  FN_GETBONDRATE_EX(nvl(v_Rec.Winamount,0),nvl(v_Rec.Offeringamount,0),nvl(v_Rec.OFFERAMOUNT,0)) ,
  FN_GETBONDRATE_EX(nvl(v_Rec.Biddingamount,0),nvl(v_Rec.Offeringamount,0),nvl(v_Rec.OFFERAMOUNT,0)),
  v_Rec.wininterest    ,
  'A'         ,
  'P'         ,
  v_rec.parvalue        ,
  v_Rec.bidder          ,
  V_rEC.PAYMENTVOLUME         ,
  v_rec.offeramount     ,
  v_rec.regisamount     ,
  v_rec.winamountextra      ,
  v_Rec.PAYAMOUNTEXTRA      ,
  V_REC.bidderextra    ,
  v_Rec.totalwinamount  ,
  v_Rec.totalofferamount ,
  V_REC.TOTALPAYMOUNT    ,
  v_Rec.TOTALREGISAMOUNT )  ;
   update TBLBONDIPO set status = 'C' where autoid = V_rec.AUTOID;
                            insert into Tblbondipohist (select * from TBLBONDIPO WHERE autoid = v_rec.AUTOID);
   end loop;


  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    RETURN;
END PR_APR_FILE_BONDIPO;

PROCEDURE PR_FILE_TBLRE_0381(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
  V_COUNT      NUMBER;
  V_COUNT1      NUMBER;
  V_CFSTATUS   VARCHAR2(1);
  V_RESTATUS   VARCHAR2(1);
  V_AFACCTNO   VARCHAR2(10);
  V_CUSTID     VARCHAR2(10);
  V_CUSNAME    VARCHAR2(500);
  V_RECUSTID   VARCHAR2(30);
  V_REACTYPE   VARCHAR2(10);
  V_REFULLNAME VARCHAR2(100);
  V_REROLE VARCHAR2(10);
  V_STRCUSTOMERID VARCHAR2(10);
  V_check0380 NUMBER;
BEGIN

  V_COUNT := 0;
  V_COUNT1 := 0;
  --Cap nhat autoid
  UPDATE TBLRE0381 SET AUTOID = SEQ_TBLRE0381.NEXTVAL;
  --CHECK DU LIEU.
  FOR REC IN (SELECT *
                FROM TBLRE0381 tbl) LOOP


     -- Ktra ngay bat dau phai nho hon ngay ket thuc va ngay bat dau phai lon hoan bang ngya hien tai
                Select count(*) into V_COUNT
                from dual where rec.frdate<rec.todate /*and to_date(rec.frdate,'dd/MM/yyyy')>= to_date(getcurrdate,'dd/MM/yyyy')*/;
                if V_COUNT=0 then
                    UPDATE TBLRE0381
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Gia tri ngay khong hop le!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;
                  end if;
   -- KIEM tra xem frdate phai lon hon ngay hien tai
   if to_date(rec.frdate,'dd/MM/rrrr') < to_date(getcurrdate,'dd/MM/rrrr') then
     UPDATE TBLRE0381
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Gia tri ngay frdate khong hop le!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;
   end if;
   -- chuyen trung moi gioi
   if rec.reacctno = rec.reoldacctno then
     UPDATE TBLRE0381
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: chuyen trung moi gioi!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;

   end if;
   --
    --Ktra ma MG, ma KH co ton tai ko
    SELECT COUNT(1)  into v_count FROM retype ot, retype nt
        WHERE (ot.rerole = nt.rerole OR ( ot.rerole IN ('CS','RM') AND nt.rerole IN ('CS','RM') ))
        AND nt.actype = SUBSTR(rec.reacctno,11,4)
        AND ot.actype =  SUBSTR(rec.reoldacctno,11,4);

     if v_count = 0 then
         UPDATE TBLRE0381
                       SET DELTD  = 'Y',
                           ERRMSG = ERRMSG || 'Error: Dang ky trung vai tro cua moi gioi cho tieu khoan KH!'
                     WHERE CUSTODYCD = REC.CUSTODYCD;
    end if;

    IF REC.REACCTNO IS NULL OR REC.CUSTODYCD is null or REC.reoldacctno IS NULL THEN
      UPDATE TBLRE0381
         SET DELTD  = 'Y',
             ERRMSG = ERRMSG || 'Error: Ma moi gioi hoac so luu ky khong duoc de trong!'
       WHERE AUTOID = REC.AUTOID;
    ELSE
      --Ktra co khai bao trung kh trong file khong

      SELECT COUNT(1)
        INTO V_COUNT
        FROM TBLRE0381
       WHERE CUSTODYCD = REC.CUSTODYCD;
      IF NVL(V_COUNT, 0) > 1 THEN
        UPDATE TBLRE0381
           SET DELTD  = 'Y',
               ERRMSG = ERRMSG || 'Error: So luu ky trung trong file!'
         WHERE CUSTODYCD = REC.CUSTODYCD;
      END IF;
      BEGIN
        --Ktra trang thai Kh va MG co hop le khong  (trang thai hop le la A)

        SELECT STATUS, CUSTID
          INTO V_CFSTATUS, V_CUSTID
          FROM CFMAST
         WHERE CUSTODYCD = REC.CUSTODYCD;
        SELECT STATUS, CUSTID, ACTYPE
          INTO V_RESTATUS, V_RECUSTID, V_REACTYPE
          FROM REMAST
         WHERE ACCTNO = REC.REACCTNO;
      EXCEPTION
        WHEN OTHERS THEN
          V_CFSTATUS := 'C';
          V_RESTATUS := 'C';
      END;
      IF (V_CFSTATUS <> 'A' OR V_RESTATUS <> 'A') THEN
        UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Trang thai khach hang hoac trang thai moi gioi khong hop le!'
         WHERE AUTOID = REC.AUTOID;
      END IF;
        --Thong tin kh

        SELECT MAX(AF.ACCTNO), MAX(CF.FULLNAME),max(cf.custid)
          INTO V_AFACCTNO, V_CUSNAME,v_custid
          FROM AFMAST AF, CFMAST CF
         WHERE AF.CUSTID = CF.CUSTID
           AND AF.STATUS = 'A'
           AND CF.CUSTODYCD=REC.CUSTODYCD;
        --Thong tin MG
        if(V_CUSNAME is null) then
            UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Chua khai bao tieu khoan cho khach hang!'
         WHERE AUTOID = REC.AUTOID;
        end if;

        BEGIN
            SELECT CFMAST.FULLNAME, TYP.REROLE
              INTO V_REFULLNAME, V_REROLE
              FROM RECFDEF RF,
                   RETYPE  TYP,
                   RECFLNK CF,
                   CFMAST
         WHERE
           RF.REACTYPE = TYP.ACTYPE
           AND RF.REFRECFLNKID = CF.AUTOID
           AND CF.CUSTID = CFMAST.CUSTID
           AND TYP.REROLE <> 'DG'
           AND CF.CUSTID||RF.REACTYPE=rec.REACCTNO;
        EXCEPTION
        WHEN OTHERS THEN
          V_REFULLNAME := 'X';
          V_REROLE := 'X';
        END;
      IF V_REFULLNAME = 'X' AND V_REROLE = 'X' THEN
        UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Khong tim thay thong tin moi gioi!'
         WHERE AUTOID = REC.AUTOID;
      END IF;
      end if;
       --
        V_COUNT1 := 0;
     for v_rec1 in (SELECT  LNK.REACCTNO, LNK.AFACCTNO,LNK.FRDATE, LNK.TODATE, MST.ACTYPE, LNK.AFACCTNO CUSTID, TYP.REROLE, TYP.RETYPE,
 CFAFREF.CUSTODYCD
FROM REMAST MST, RETYPE TYP, REAFLNK LNK, CFMAST CFREREF, CFMAST CFAFREF, ALLCODE A0, ALLCODE A1, RECFLNK RF, RETYPE FTYP
WHERE TYP.ACTYPE=MST.ACTYPE AND MST.ACCTNO=LNK.REACCTNO AND CFREREF.CUSTID=MST.CUSTID
AND LNK.AFACCTNO=CFAFREF.CUSTID AND LNK.STATUS='A'
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
AND A1.CDTYPE='RE' AND A1.CDNAME='RETYPE' AND A1.CDVAL=TYP.RETYPE
AND MST.CUSTID = RF.CUSTID --AND (<$BRID> ='0001' or RF.BRID = <$BRID>)
AND SUBSTR(LNK.FUREACCTNO,11,4) = FTYP.actype(+) and LNK.Reacctno = rec.reoldacctno
and CFAFREF.CUSTODYCD = rec.custodycd) loop
  v_count1 :=1;
 SELECT COUNT(LNK.AUTOID) into v_count FROM REAFLNK LNK, REMAST ORGMST, RETYPE ORGTYP, REMAST RFMST, RETYPE RFTYP
        WHERE LNK.STATUS='A' AND ORGMST.ACTYPE=ORGTYP.ACTYPE AND LNK.REACCTNO=ORGMST.ACCTNO AND LNK.AFACCTNO = V_STRCUSTOMERID
            AND (RFTYP.REROLE=ORGTYP.REROLE or (RFTYP.REROLE in ('BM','RM') AND ORGTYP.REROLE in ('BM','RM') ))
            AND RFMST.ACTYPE=RFTYP.ACTYPE AND RFMST.ACCTNO=rec.reacctno AND LNK.REACCTNO <> rec.reoldacctno
            And ( ( lnk.frdate <=  v_rec1.frdate and lnk.todate >= v_rec1.frdate  )
            or   ( lnk.frdate <= v_rec1.todate and lnk.todate >= v_rec1.todate));
    IF  ( v_count > 0) THEN

         UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Dang ky trung vai tro cua moi gioi cho tieu khoan KH!'
         WHERE AUTOID = REC.AUTOID;
      END IF;
 SELECT COUNT(1) INTO v_count FROM retype WHERE actype in (SELECT  TYP.Actype
            FROM RECFDEF RF, RETYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, RECFLNK CF, CFMAST
              WHERE A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
                    AND A2.CDTYPE = 'RE' AND A2.CDNAME = 'AFSTATUS' AND A2.CDVAL = TYP.AFSTATUS
                    AND A1.CDTYPE='RE' AND A1.CDNAME='RETYPE' AND A1.CDVAL=TYP.RETYPE
                    AND RF.REACTYPE=TYP.ACTYPE
                    AND RF.REFRECFLNKID = CF.AUTOID
                    AND CF.CUSTID = CFMAST.CUSTID
                    and  (CF.CUSTID||RF.REACTYPE) =rec.reacctno) AND retype = 'I';
        IF v_count <> 0 THEN
        UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Khong duoc phep gan khach hang vao loai hinh moi gioi gan tiep!'
         WHERE AUTOID = REC.AUTOID;
        END IF;
    select count(1)  INTO V_COUNT
        from reaflnk rl , retype rty , recflnk rcl
        where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
            and  rl.status='A' and rty.rerole <>'DG' and rl.afacctno= v_custid
            and rcl.custid in  (SELECT  CF.CUSTID
            FROM RECFDEF RF, RETYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, RECFLNK CF, CFMAST
              WHERE A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
                    AND A2.CDTYPE = 'RE' AND A2.CDNAME = 'AFSTATUS' AND A2.CDVAL = TYP.AFSTATUS
                    AND A1.CDTYPE='RE' AND A1.CDNAME='RETYPE' AND A1.CDVAL=TYP.RETYPE
                    AND RF.REACTYPE=TYP.ACTYPE
                    AND RF.REFRECFLNKID = CF.AUTOID
                    AND CF.CUSTID = CFMAST.CUSTID
                    and  (CF.CUSTID||RF.REACTYPE) =rec.reacctno);

        IF  ( V_COUNT > 0) THEN
            UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG || 'Error: Trung vai tro moi gioi - cham soc ho!'
         WHERE AUTOID = REC.AUTOID;
        END IF;

end loop;
--
 IF  ( V_COUNT1 = 0) THEN
            UPDATE TBLRE0381
           SET DELTD = 'Y', ERRMSG = ERRMSG||'Error: Trung vai tro moi gioi !'
         WHERE AUTOID = REC.AUTOID;
        END IF;

  END LOOP;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    plog.error ('PR_FILE_TBLRE_0381: ' || SQLERRM || dbms_utility.format_error_backtrace);
    RETURN;
END PR_FILE_TBLRE_0381;
PROCEDURE PR_APR_FILE_TBLRE_0381(P_TLID        IN VARCHAR2,
                            P_ERR_CODE    OUT VARCHAR2,
                            P_ERR_MESSAGE OUT VARCHAR2) IS
    v_strDesc       varchar2(1000);
    v_strEN_Desc    varchar2(1000);
    l_err_param     varchar2(500);
    v_strCURRDATE   varchar2(20);
    V_STRCUSTOMERID varchar2(20);
    L_txnum         VARCHAR2(20);
    V_check0380     NUMBER;
    l_txmsg         tx.msg_rectype;
    v_custid_new         VARCHAR2(20);
    v_actype_new         VARCHAR2(20);

BEGIN
 v_custid_new :=  ' ';
 v_actype_new :=  ' ';
  SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='0381';
        SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO v_strCURRDATE
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO L_txnum
              FROM DUAL;
        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := P_TLID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'AUTO';
        l_txmsg.reftxnum    := L_txnum;
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='0381';

        FOR REC in (
                      SELECT tbl.*,cf.custid FROM tblRE0381 tbl, cfmast cf
                      WHERE nvl(tbl.deltd,'N') <> 'Y' and nvl(tbl.status,'A') <> 'C'
                            and tbl.custodycd = cf.custodycd
                )
            loop
                SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
                    -- Tao giao dich 0380
                         for v_rec1 in (SELECT  LNK.REACCTNO, LNK.AFACCTNO,LNK.FRDATE, LNK.TODATE, MST.ACTYPE, LNK.AFACCTNO CUSTID, TYP.REROLE, TYP.RETYPE,
 CFAFREF.CUSTODYCD
FROM REMAST MST, RETYPE TYP, REAFLNK LNK, CFMAST CFREREF, CFMAST CFAFREF, ALLCODE A0, ALLCODE A1, RECFLNK RF, RETYPE FTYP
WHERE TYP.ACTYPE=MST.ACTYPE AND MST.ACCTNO=LNK.REACCTNO AND CFREREF.CUSTID=MST.CUSTID
AND LNK.AFACCTNO=CFAFREF.CUSTID AND LNK.STATUS='A'
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
AND A1.CDTYPE='RE' AND A1.CDNAME='RETYPE' AND A1.CDVAL=TYP.RETYPE
AND MST.CUSTID = RF.CUSTID --AND (<$BRID> ='0001' or RF.BRID = <$BRID>)
AND SUBSTR(LNK.FUREACCTNO,11,4) = FTYP.actype(+) and LNK.Reacctno = rec.reoldacctno
and CFAFREF.CUSTODYCD = rec.custodycd) loop

  FOR v_rec2 in   (SELECT  CF.CUSTID,TYP.Actype
            FROM RECFDEF RF, RETYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, RECFLNK CF, CFMAST
              WHERE A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
                    AND A2.CDTYPE = 'RE' AND A2.CDNAME = 'AFSTATUS' AND A2.CDVAL = TYP.AFSTATUS
                    AND A1.CDTYPE='RE' AND A1.CDNAME='RETYPE' AND A1.CDVAL=TYP.RETYPE
                    AND RF.REACTYPE=TYP.ACTYPE
                    AND RF.REFRECFLNKID = CF.AUTOID
                    AND CF.CUSTID = CFMAST.CUSTID
                    and  (CF.CUSTID||RF.REACTYPE) =rec.reacctno) loop

           v_custid_new := v_rec2.custid;
           v_actype_new := v_rec2.actype;
      end loop;


                        --30    Di?n gi?i   C
                             l_txmsg.txfields ('30').defname   := 'T_DESC';
                             l_txmsg.txfields ('30').TYPE      := 'C';
                             l_txmsg.txfields ('30').value      :=  NVL(REC.DES,v_strDesc);
                        --88    S? TK luu k?   C
                             l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                             l_txmsg.txfields ('88').TYPE      := 'C';
                             l_txmsg.txfields ('88').value      := rec.CUSTODYCD;
                      --03    S? TK luu k?   C
                             l_txmsg.txfields ('03').defname   := 'ACCTNO';
                             l_txmsg.txfields ('03').TYPE      := 'C';
                             l_txmsg.txfields ('03').value      := rec.custid;
                      --02    Tham chi?u m?i?i    C
                             l_txmsg.txfields ('20').defname   := 'REOLDCUSTID';
                             l_txmsg.txfields ('20').TYPE      := 'C';
                             l_txmsg.txfields ('20').value      := v_rec1.custid;
                             --02    Tham chi?u m?i?i    C
                             l_txmsg.txfields ('21').defname   := 'REOLDACCTNO';
                             l_txmsg.txfields ('21').TYPE      := 'C';
                             l_txmsg.txfields ('21').value      := rec.REOLDACCTNO;
                              --02    Tham chi?u m?i?i    C
                             l_txmsg.txfields ('92').defname   := 'ORADESC';
                             l_txmsg.txfields ('92').TYPE      := 'C';
                             l_txmsg.txfields ('92').value      := 'Nguyen Duc Huy';

                              l_txmsg.txfields ('91').defname   := 'RECUSTNAME';
                             l_txmsg.txfields ('91').TYPE      := 'C';
                             l_txmsg.txfields ('91').value      := 'Nguyen Duc Huy';
                              l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                             l_txmsg.txfields ('90').TYPE      := 'C';
                             l_txmsg.txfields ('90').value      := 'Nguyen Duc Huy';
                        --02    Tham chi?u m?i?i    C
                             l_txmsg.txfields ('02').defname   := 'RECUSTID';
                             l_txmsg.txfields ('02').TYPE      := 'C';
                             l_txmsg.txfields ('02').value      := v_custid_new;
                        --10    Gi?r? di?u ch?nh hoa h?ng   N
                             l_txmsg.txfields ('10').defname   := 'AMT';
                             l_txmsg.txfields ('10').TYPE      := 'N';
                             l_txmsg.txfields ('10').value      := 0;
                        --08    T?kho?n m?i?i   C
                             l_txmsg.txfields ('08').defname   := 'REACCTNO';
                             l_txmsg.txfields ('08').TYPE      := 'C';
                             l_txmsg.txfields ('08').value      := rec.REACCTNO;
                        --07    Lo?i h? m?i?i   C
                             l_txmsg.txfields ('07').defname   := 'REACTYPE';
                             l_txmsg.txfields ('07').TYPE      := 'C';
                             l_txmsg.txfields ('07').value      := v_actype_new;

                        --90    T?ch? t?kho?n   C
                             l_txmsg.txfields ('94').defname   := 'RADESC';
                             l_txmsg.txfields ('94').TYPE      := 'C';
                             l_txmsg.txfields ('94').value      := '252';
                        --91    T?m?i?i   C
                             l_txmsg.txfields ('05').defname   := 'FRDATE';
                             l_txmsg.txfields ('05').TYPE      := 'D';
                             l_txmsg.txfields ('05').value      := rec.FRDATE;
                              l_txmsg.txfields ('06').defname   := 'TODATE';
                             l_txmsg.txfields ('06').TYPE      := 'D';
                             l_txmsg.txfields ('06').value      := rec.TODATE;
                             --90    T?ch? t?kho?n   C
                             l_txmsg.txfields ('09').defname   := 'REROLE';
                             l_txmsg.txfields ('09').TYPE      := 'C';
                             l_txmsg.txfields ('09').value      := v_rec1.rerole;
                               --90    T?ch? t?kho?n   C
                             l_txmsg.txfields ('12').defname   := 'REROLE';
                             l_txmsg.txfields ('12').TYPE      := 'C';
                             l_txmsg.txfields ('12').value      := v_rec1.rerole;
                               --90    T?ch? t?kho?n   C
                             l_txmsg.txfields ('14').defname   := 'REROLE';
                             l_txmsg.txfields ('14').TYPE      := 'C';
                             l_txmsg.txfields ('14').value      := v_rec1.rerole;

                    BEGIN
                        IF txpks_#0381.fn_batchtxprocess (l_txmsg,p_err_code,l_err_param) <> systemnums.c_success
                        THEN
                           plog.debug(pkgctx,'got error 0381: ' || p_err_code);
                           ROLLBACK;
                       ELSE
                            update TBLRE0381 set status = 'C' where autoid = rec.AUTOID;
                            insert into TBLRE0381HIST (select * from TBLRE0381 WHERE autoid = rec.AUTOID);
                        END IF;
                    END;
                    end loop;
            end loop;
        ---insert into TBLRE0380HIST select * from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
        ---delete from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
  PLOG.DEBUG(PKGCTX, ' finish ');
  P_ERR_CODE    := 0;
  P_ERR_MESSAGE := 'Sucessfull!';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_ERR_CODE    := -100800; --File du lieu dau vao khong hop le
    P_ERR_MESSAGE := 'System error. Invalid file format';
    plog.error ('PR_APR_FILE_TBLRE_0381: ' || SQLERRM || dbms_utility.format_error_backtrace);
    RETURN;
END PR_APR_FILE_TBLRE_0381;
-- END BINHVT

PROCEDURE FILLTER_LNPRMINTCFIMP (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    UPDATE LNPRMINTCFIMP SET AUTOID = SEQ_LNPRMINTCFIMP.NEXTVAL, status = 'P', IMPORTDT = SYSTIMESTAMP, DELTD ='N', tlid = p_tlid;

    update LNPRMINTCFIMP LNP set CUSTID  = (SELECT CUSTID FROM CFMAST WHERE CUSTODYCD =LNP.CUSTODYCD )   ;

     update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'So tieu khoan khong ton tai hoac da dong! '
    where NVL(custid,'X') not in (select custid from cfmast where status <> 'C');

    update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Ma chinh sach khong ton tai! '
    where PROMOTIONID not in (select autoid from LNPRMINMAST where getcurrdate between opendate and closedate);

    update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang da duoc gan chinh sach nay! '
    where (promotionid,afacctno)
        in (
        select mst.refid, mst.afacctno from LNPRMINTCF mst
        where status <> 'C'
        );

    for rec in (
        SELECT AFACCTNO, CUSTID, autoid, promotionid FROM LNPRMINTCFIMP
    )loop
        select count(1) into v_count from afmast
        where acctno = rec.AFACCTNO and CUSTID = rec.CUSTID AND STATUS <> 'C' AND  INSTR(STATUS||PSTATUS,'A') > 0;
        if v_count = 0 then
            update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'So tieu khoan khong ton tai hoac da dong! '
            where autoid = rec.autoid;
        end if;

        select count(1) into v_count from LNPRMINTCF
        where status <> 'C'
            and afacctno = rec.AFACCTNO and refid = rec.promotionid;
        if v_count > 0 then
            update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang da duoc gan chinh sach nay! '
            where autoid = rec.autoid;
        end if;

        select count(1) into v_count from LNPRMINTCFIMP
        where AFACCTNO = rec.AFACCTNO and promotionid = rec.promotionid and autoid <> rec.autoid;
        if v_count > 0 then
            update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khai bao trung so tieu khoan! '
            where autoid = rec.autoid;
        end if;
        v_count := 0;
    end loop;

   update LNPRMINTCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Chinh sach da het han! '
    where promotionid   IN ( SELECT AUTOID FROM lnprminmast LNM WHERE LNM.opendate > getcurrdate OR LNM.closedate < getcurrdate  );

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_LNPRMINTCFIMP;
PROCEDURE FILLTER_CFCHANGEBRID (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    UPDATE CFCHANGEBRIDIMP SET AUTOID = SEQ_CFCHANGEBRIDIMP.NEXTVAL, status = 'P', IMPORTDT = SYSTIMESTAMP, DELTD ='N', tlid = p_tlid;


     update CFCHANGEBRIDIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'So tieu khoan khong ton tai hoac da dong! '
    where NVL(CUSTODYCD,'X') not in (select  NVL(CUSTODYCD,'Y') from cfmast );

     update CFCHANGEBRIDIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khong ton tai ma chi nhanh! '
    where NVL(BRID,'X') not in (select  NVL(BRID,'Y') from brgrp );

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_CFCHANGEBRID;

PROCEDURE FILLTER_ODPROBRKAFIMP (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    UPDATE ODPROBRKAFIMP SET AUTOID = SEQ_ODPROBRKAFIMP.NEXTVAL, status = 'P', IMPORTDT = SYSTIMESTAMP, DELTD ='N', tlid = p_tlid;

    --Kiem tra xem so luu ky va tai khoan co ton tai hay khong
    update ODPROBRKAFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'So tieu khoan khong ton tai hoac da dong! '
    where afacctno not in (select ACCTNO from afmast where status <> 'C');

    update ODPROBRKAFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Ma chinh sach khong ton tai! '
    where PROMOTIONID not in (select autoid from ODPROBRKMST);

    update ODPROBRKAFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang da ton duoc gan chinh sach nay! '
    where (promotionid,afacctno)
        in (
        select refautoid,afacctno from odprobrkaf
        where nvl(expdate, to_date('01/01/2014','dd/mm/rrrr')) >= getcurrdate
        );

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_ODPROBRKAFIMP;

PROCEDURE PR_FILE_ODPROBRKAFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_strcustid varchar2(10);

v_strCoreBank varchar2(10);
v_strCIACTYPE   varchar2(10);
v_strSEACTYPE   varchar2(10);
v_strLNACTYPE   varchar2(10);
v_strMRTYPE varchar2(10);
v_strAUTOADV CHAR(1);
v_dblMRIRATE number;
v_dblMRMRATE number;
v_dblMRLRATE number;
v_blnUpdate BOOLEAN;
v_strOldcorebank    varchar2(10);
v_strOldautoadv CHAR(1);
v_dblOldmrirate number;
v_dblOldmrmrate number;
v_dblOldmrlrate number;
v_autoid    number;
v_busdate   varchar2(20);
BEGIN
    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, A.AFACCTNO, A.DESCRIPTION, A.IMPORTDT,
       A.STATUS, A.DELTD, A.ERRMSG, B.valday, B.VALDATE, B.EXPDATE, B.DATETYPE, a.tlid
        FROM ODPROBRKAFIMP A, ODPROBRKMST B
        WHERE A.PROMOTIONID = B.AUTOID
            AND A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        v_autoid := seq_odprobrkaf.NEXTVAL;
        IF REC.DATETYPE = 'F' THEN
            INSERT INTO ODPROBRKAF (AUTOID,REFAUTOID,AFACCTNO,OPNDATE,VALDATE,EXPDATE,STATUS)
            VALUES(v_autoid,REC.promotionid,REC.afacctno,GETCURRDATE,GETCURRDATE,GETCURRDATE+REC.valday,'A');

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,GETCURRDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,GETCURRDATE+REC.valday,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);
        ELSE
            INSERT INTO ODPROBRKAF (AUTOID,REFAUTOID,AFACCTNO,OPNDATE,VALDATE,EXPDATE,STATUS)
            VALUES(v_autoid,REC.promotionid,REC.afacctno,GETCURRDATE,REC.VALDATE,REC.EXPDATE,'A');

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,REC.VALDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,REC.EXPDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);
        END IF;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'AFACCTNO',NULL,REC.afacctno,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'OPNDATE',NULL,getcurrdate,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ODPROBRKAF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'REFAUTOID',NULL,REC.promotionid,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        UPDATE ODPROBRKAFIMP SET STATUS = 'A' WHERE AUTOID = REC.AUTOID;
    end loop;



    --Backup luu lai lich su
    insert into ODPROBRKAFIMP_HIST (AUTOID,PROMOTIONID,AFACCTNO,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID)
    select AUTOID,PROMOTIONID,AFACCTNO,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID from ODPROBRKAFIMP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_ODPROBRKAFIMP;


PROCEDURE PR_FILE_LNPRMINTCFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_strcustid varchar2(10);

v_strCoreBank varchar2(10);
v_strCIACTYPE   varchar2(10);
v_strSEACTYPE   varchar2(10);
v_strLNACTYPE   varchar2(10);
v_strMRTYPE varchar2(10);
v_strAUTOADV CHAR(1);
v_dblMRIRATE number;
v_dblMRMRATE number;
v_dblMRLRATE number;
v_blnUpdate BOOLEAN;
v_strOldcorebank    varchar2(10);
v_strOldautoadv CHAR(1);
v_dblOldmrirate number;
v_dblOldmrmrate number;
v_dblOldmrlrate number;
v_autoid    number;
v_busdate   varchar2(20);
BEGIN
    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, A.CUSTID, A.DESCRIPTION, A.IMPORTDT,
       A.STATUS, A.DELTD, A.ERRMSG, B.valday, B.VALDATE, B.EXPDATE, B.DATETYPE, a.tlid, a.afacctno
        FROM LNPRMINTCFIMP A, LNPRMINMAST B
        WHERE A.PROMOTIONID = B.AUTOID
            AND A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        v_autoid := seq_LNPRMINTCF.NEXTVAL;
        IF REC.DATETYPE = 'F' THEN
            INSERT INTO LNPRMINTCF (AUTOID,REFID,custid,OPNDATE,VALDATE,EXPDATE,STATUS,AFACCTNO)
            VALUES(v_autoid,REC.promotionid,REC.custid,GETCURRDATE,GETCURRDATE,GETCURRDATE+REC.valday,'A',rec.afacctno);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,GETCURRDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,GETCURRDATE+REC.valday,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);
        ELSE
            INSERT INTO LNPRMINTCF (AUTOID,REFID,custid,OPNDATE,VALDATE,EXPDATE,STATUS,AFACCTNO)
            VALUES(v_autoid,REC.promotionid,REC.custid,GETCURRDATE,REC.VALDATE,REC.EXPDATE,'A',rec.afacctno);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,REC.VALDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,REC.EXPDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);
        END IF;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'CUSTID',NULL,REC.custid,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'AFACCTNO',NULL,REC.afacctno,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'OPNDATE',NULL,getcurrdate,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('LNPRMINTCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'REFAUTOID',NULL,REC.promotionid,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        UPDATE LNPRMINTCFIMP SET STATUS = 'A' WHERE AUTOID = REC.AUTOID;
    end loop;

    --Backup luu lai lich su
    insert into LNPRMINTCFIMP_HIST (AUTOID,PROMOTIONID,CUSTID,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID, afacctno)
    select AUTOID,PROMOTIONID,CUSTID,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID, afacctno from LNPRMINTCFIMP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_LNPRMINTCFIMP;

PROCEDURE FILLTER_CIFEEDEF_EXTLNK (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    UPDATE CIFEEDEF_EXTLNKIMP SET AUTOID = SEQ_CIFEEDEF_EXTLNKIMP.NEXTVAL, status = 'P', IMPORTDT = SYSTIMESTAMP, DELTD ='N', TLID  = p_tlid;

    --Kiem tra xem so luu ky va tai khoan co ton tai hay khong
    update CIFEEDEF_EXTLNKIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'So tieu khoan khong ton tai hoac da dong! '
    where afacctno not in (select ACCTNO from afmast where status <> 'C');

    update CIFEEDEF_EXTLNKIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Ma chinh sach khong ton tai! '
    where PROMOTIONID not in (select actype from CIFEEDEF_EXT);

    update CIFEEDEF_EXTLNKIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang da ton duoc gan chinh sach nay! '
    where (promotionid,afacctno)
        in (
        select ACTYPE,afacctno from cifeedef_extlnk
        where DELTD <>  'Y'
        );

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_CIFEEDEF_EXTLNK;

PROCEDURE PR_FILE_CIFEEDEF_EXTLNK(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_strcustid varchar2(10);

v_strCoreBank varchar2(10);
v_strCIACTYPE   varchar2(10);
v_strSEACTYPE   varchar2(10);
v_strLNACTYPE   varchar2(10);
v_strMRTYPE varchar2(10);
v_strAUTOADV CHAR(1);
v_dblMRIRATE number;
v_dblMRMRATE number;
v_dblMRLRATE number;
v_blnUpdate BOOLEAN;
v_strOldcorebank    varchar2(10);
v_strOldautoadv CHAR(1);
v_dblOldmrirate number;
v_dblOldmrmrate number;
v_dblOldmrlrate number;
V_AUTOID NUMBER;
v_busdate   varchar2(20);
BEGIN
    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, A.AFACCTNO, A.DESCRIPTION, A.IMPORTDT,
       A.STATUS, A.DELTD, A.ERRMSG, A.TLID
        FROM CIFEEDEF_EXTLNKIMP A
        WHERE A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        V_AUTOID := seq_cifeedef_extlnk.NEXTVAL;
        INSERT INTO CIFEEDEF_EXTLNK (ACTYPE,AFACCTNO,DELTD,STATUS,AUTOID)
        VALUES(REC.promotionid,REC.afacctno,'N','A',V_AUTOID);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CIFEEDEF_EXTLNK','AUTOID = ''' || V_AUTOID || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'ACTYPE',NULL,REC.promotionid,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('CIFEEDEF_EXTLNK','AUTOID = ''' || V_AUTOID || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'AFACCTNO',NULL,REC.afacctno,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),NULL);

        UPDATE CIFEEDEF_EXTLNKIMP SET STATUS = 'A' WHERE AUTOID = REC.AUTOID;
    end loop;
    --Backup luu lai lich su
    insert into CIFEEDEF_EXTLNKIMP_HIST (AUTOID,PROMOTIONID,AFACCTNO,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG)
    select AUTOID,PROMOTIONID,AFACCTNO,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG from CIFEEDEF_EXTLNKIMP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_CIFEEDEF_EXTLNK;

PROCEDURE FILLTER_ADPRMFEECFIMP (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    UPDATE ADPRMFEECFIMP SET AUTOID = seq_ADPRMFEECFIMP.NEXTVAL, status = 'P', IMPORTDT = SYSTIMESTAMP,
        DELTD ='N', tlid = p_tlid;

    --Kiem tra xem so luu ky va tai khoan co ton tai hay khong
    update ADPRMFEECFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang khong ton tai hoac da dong! '
    where custodycd not in (select nvl(custodycd,'ACB') from cfmast where status <> 'C');

    update ADPRMFEECFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Ma chinh sach khong ton tai hoac ngoai khoang khai bao! '
    where PROMOTIONID not in (select autoid from ADPRMFEEMST where getcurrdate BETWEEN opendate and closedate);

    update ADPRMFEECFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang da duoc gan chinh sach nay! '
    where (promotionid,AFACCTNO)
        in (
        select mst.PROMOTIONID, mst.AFACCTNO from ADPRMFEECF mst
        where status <> 'C'
        );

    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, A.custodycd, A.AFACCTNO
        FROM ADPRMFEECFIMP A
        WHERE A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        v_count := 0;
        select count(*) into v_count from ADPRMFEECFIMP mst where mst.promotionid = rec.PROMOTIONID
            and mst.AFACCTNO = rec.AFACCTNO and mst.autoid <> rec.autoid;
        if v_count > 0 then
            update ADPRMFEECFIMP mst set mst.status ='E', mst.DELTD = 'Y', mst.errmsg = mst.errmsg || ' Khai bao trung so tieu khoan! '
            where mst.PROMOTIONID = rec.PROMOTIONID and mst.custodycd =  rec.custodycd;
        end if;

        v_count := 0;
        select count(*) into v_count from cfmast cf, afmast af
            where cf.custid = af.custid and af.acctno = rec.afacctno
            and cf.custodycd = rec.custodycd and af.STATUS <> 'C' AND  INSTR(af.STATUS||af.PSTATUS,'A') > 0;
        if v_count = 0 then
            update ADPRMFEECFIMP mst set mst.status ='E', mst.DELTD = 'Y', mst.errmsg = mst.errmsg || ' Khach hang khong ton tai hoac da dong! '
            where mst.AUTOID = rec.AUTOID ;
        end if;

    end loop;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_ADPRMFEECFIMP;

PROCEDURE PR_FILE_ADPRMFEECFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count     NUMBER;
v_autoid    number;
BEGIN
    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, CF.CUSTID, A.DESCRIPTION, A.IMPORTDT,
       A.STATUS, A.DELTD, A.ERRMSG, B.valday, B.VALDATE, B.EXPDATE, B.DATETYPE, A.TLID, A.AFACCTNO
        FROM ADPRMFEECFIMP A, ADPRMFEEMST B, CFMAST CF
        WHERE A.PROMOTIONID = B.AUTOID AND A.CUSTODYCD = CF.CUSTODYCD
            AND A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        v_autoid := seq_adprmfeecf.NEXTVAL;
        IF REC.DATETYPE = 'F' THEN
            INSERT INTO ADPRMFEECF (AUTOID,PROMOTIONID,CUSTID,OPENDATE,VALDATE,EXPDATE,STATUS,PSTATUS,AFACCTNO)
            VALUES(v_autoid,REC.promotionid,REC.CUSTID,GETCURRDATE,GETCURRDATE,GETCURRDATE+REC.valday,'A','P',rec.AFACCTNO);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,GETCURRDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,GETCURRDATE+REC.valday,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));
        ELSE
            INSERT INTO ADPRMFEECF (AUTOID,PROMOTIONID,CUSTID,OPENDATE,VALDATE,EXPDATE,STATUS,PSTATUS,AFACCTNO)
            VALUES(v_autoid,REC.promotionid,REC.CUSTID,GETCURRDATE,REC.VALDATE,REC.EXPDATE,'A','P',rec.AFACCTNO);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,REC.VALDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,REC.EXPDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));
        END IF;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'CUSTID',NULL,REC.CUSTID,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'AFACCTNO',NULL,REC.AFACCTNO,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'OPNDATE',NULL,getcurrdate,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('ADPRMFEECF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'PROMOTIONID',NULL,REC.promotionid,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        UPDATE ADPRMFEECFIMP SET STATUS = 'A' WHERE AUTOID = REC.AUTOID;
    end loop;

    --Backup luu lai lich su
    insert into ADPRMFEECFIMP_HIST (AUTOID,PROMOTIONID,CUSTODYCD,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID,AFACCTNO)
    select AUTOID,PROMOTIONID,CUSTODYCD,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID, AFACCTNO from ADPRMFEECFIMP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_ADPRMFEECFIMP;

PROCEDURE FILLTER_MRPRMLIMITCFIMP (p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
v_count NUMBER;
v_basketid varchar2(100);
v_symbol varchar2(100);
v_IRATIO varchar2(50);
BEGIN
    UPDATE MRPRMLIMITCFIMP SET AUTOID = seq_MRPRMLIMITCFIMP.NEXTVAL, status = 'P', IMPORTDT = SYSTIMESTAMP,
        DELTD ='N', tlid = p_tlid;

    --Kiem tra xem so luu ky va tai khoan co ton tai hay khong
    update MRPRMLIMITCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang khong ton tai hoac da dong! '
    where custodycd not in (select nvl(custodycd,'ACB') from cfmast where status <> 'C');

    update MRPRMLIMITCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Ma chinh sach khong ton tai hoac ngoai khoang khai bao! '
    where PROMOTIONID not in (select autoid from MRPRMLIMITMST where getcurrdate BETWEEN opendate and closedate);

    update MRPRMLIMITCFIMP set status ='E', DELTD = 'Y', errmsg = errmsg || 'Khach hang da duoc gan chinh sach nay! '
    where (promotionid,afacctno)
        in (
        select mst.PROMOTIONID, mst.afacctno from MRPRMLIMITCF mst
        where status <> 'C'
        );

    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, A.custodycd, A.afacctno
        FROM MRPRMLIMITCFIMP A
        WHERE A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        v_count := 0;
        select count(*) into v_count from MRPRMLIMITCFIMP mst where mst.promotionid = rec.PROMOTIONID
            and mst.afacctno = rec.afacctno and mst.autoid <> rec.autoid;
        if v_count > 0 then
            update MRPRMLIMITCFIMP mst set mst.status ='E', mst.DELTD = 'Y', mst.errmsg = mst.errmsg || ' Khai bao trung so tieu khoan! '
            where mst.PROMOTIONID = rec.PROMOTIONID and mst.custodycd =  rec.custodycd;
        end if;

        v_count := 0;
        select count(*) into v_count from afmast af, cfmast cf
        where cf.custid = af.custid and cf.status <> 'C'
            and af.acctno = rec.afacctno and cf.custodycd = rec.custodycd and af.STATUS <> 'C' AND  INSTR(af.STATUS||af.PSTATUS,'A') > 0;
        if v_count = 0 then
            update MRPRMLIMITCFIMP mst set mst.status ='E', mst.DELTD = 'Y', mst.errmsg = mst.errmsg || ' Khach hang khong ton tai hoac da dong!  '
            where mst.AUTOID = rec.AUTOID;
        end if;

    end loop;
    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END FILLTER_MRPRMLIMITCFIMP;

PROCEDURE PR_FILE_MRPRMLIMITCFIMP(p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
    v_count     NUMBER;
    v_autoid    number;
    v_EXPDATE   date;
BEGIN
    for rec in (
        SELECT A.AUTOID, A.PROMOTIONID, CF.CUSTID, A.DESCRIPTION, A.IMPORTDT,
       A.STATUS, A.DELTD, A.ERRMSG, B.VALDAY, B.VALDATE, B.EXPDATE, B.DATETYPE, A.TLID, A.AFACCTNO
        FROM MRPRMLIMITCFIMP A, MRPRMLIMITMST B, CFMAST CF
        WHERE A.PROMOTIONID = B.AUTOID AND A.CUSTODYCD = CF.CUSTODYCD
            AND A.STATUS = 'P' AND A.DELTD <> 'Y'
    )
    loop
        v_autoid := seq_MRPRMLIMITCF.NEXTVAL;
        IF REC.DATETYPE = 'F' THEN
            --v_EXPDATE
            select min(sbdate) into v_EXPDATE from sbcldr
            where sbdate >= to_date(GETCURRDATE+REC.valday,'dd/mm/rrrr')
            and holiday = 'N' and cldrtype='000';  --ngoc.vu-Jira561

            INSERT INTO MRPRMLIMITCF (AUTOID,PROMOTIONID,CUSTID,OPENDATE,VALDATE,EXPDATE,STATUS,PSTATUS,AFACCTNO)
            VALUES(v_autoid,REC.promotionid,REC.CUSTID,GETCURRDATE,GETCURRDATE,v_EXPDATE,'A','P',rec.AFACCTNO);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,GETCURRDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,GETCURRDATE+REC.valday,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));
        ELSE
            --v_EXPDATE
            select min(sbdate) into v_EXPDATE from sbcldr
            where sbdate >= REC.EXPDATE and holiday = 'N' and cldrtype='000'; --ngoc.vu-Jira561
            INSERT INTO MRPRMLIMITCF (AUTOID,PROMOTIONID,CUSTID,OPENDATE,VALDATE,EXPDATE,STATUS,PSTATUS,AFACCTNO)
            VALUES(v_autoid,REC.promotionid,REC.CUSTID,GETCURRDATE,REC.VALDATE,v_EXPDATE,'A','P',rec.AFACCTNO);

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'VALDATE',NULL,REC.VALDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
            VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'EXPDATE',NULL,REC.EXPDATE,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));
        END IF;

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'CUSTID',NULL,REC.CUSTID,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'AFACCTNO',NULL,REC.AFACCTNO,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'OPNDATE',NULL,getcurrdate,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME,APPROVE_TIME)
        VALUES('MRPRMLIMITCF','AUTOID = ''' || v_autoid || '''',rec.tlid,getcurrdate,'Y',p_tlid,getcurrdate,0,'PROMOTIONID',NULL,REC.promotionid,'ADD',NULL,NULL,TO_CHAR(SYSDATE, 'HH24:MI:SS'),TO_CHAR(SYSDATE, 'HH24:MI:SS'));

        UPDATE MRPRMLIMITCFIMP SET STATUS = 'A' WHERE AUTOID = REC.AUTOID;
    end loop;

    --Backup luu lai lich su
    insert into MRPRMLIMITCFIMP_HIST (AUTOID,PROMOTIONID,CUSTODYCD,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID,afacctno)
    select AUTOID,PROMOTIONID,CUSTODYCD,DESCRIPTION,IMPORTDT,STATUS,DELTD,ERRMSG, TLID, afacctno from MRPRMLIMITCFIMP;

    p_err_code := 0;
    p_err_message:= 'Sucessfull!';
exception
when others then
    rollback;
    p_err_code := -100800; --File du lieu dau vao khong hop le
    p_err_message:= 'System error. Invalid file format';
RETURN;
END PR_FILE_MRPRMLIMITCFIMP;


PROCEDURE FILLTER_FILE_HNXI(p_tlid in varchar2, p_err_code OUT varchar2, p_err_message OUT varchar2)
IS
  -- Enter the procedure variables here. As shown below
   l_tlid varchar2(30);

   v_busdate DATE;
 v_count NUMBER;
 l_err_code varchar2(30);
 l_err_param varchar2(30);
 p_err_param varchar2(30);
 l_custodycd varchar(10);
 l_tmpcustodycd varchar(10);
 l_custid varchar(10);
 l_afacctno varchar(10);


BEGIN
    l_tlid := p_tlid;
    UPDATE TBLHNXI SET tlid = p_tlid;
    -- get CURRDATE
    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';



     -- kiem tra cac truong mandatory va CHECK gia tri so chung khoan.
     UPDATE TBLHNXI
     SET deltd = 'Y',status = 'E', errmsg = 'data missing: ' ||
        CASE
            WHEN ORDER_DATE IS NULL OR ORDER_DATE = '' THEN ' [ORDER_DATE] IS NULL '
            WHEN SYMBOL IS NULL OR SYMBOL = '' THEN ' [SYMBOL] IS NULL '
            WHEN ORDER_NO IS NULL OR ORDER_NO = '' THEN ' [ORDER_NO] IS NULL '
            WHEN BACCOUNT_NO IS NULL OR BACCOUNT_NO = '' THEN ' [BACCOUNT_NO] IS NULL '
            WHEN SACCOUNT_NO IS NULL OR SACCOUNT_NO = '' THEN ' [SACCOUNT_NO] IS NULL '
            WHEN ORDER_QTTY IS NULL OR ORDER_QTTY = '' THEN ' [ORDER_QTTY] IS NULL '
            WHEN ORDER_PRICE IS NULL OR ORDER_PRICE = '' THEN ' [ORDER_PRICE] IS NULL '
                      ELSE 'UNKNOWN!'
        END
     WHERE
     ORDER_DATE IS NULL OR ORDER_DATE = ''
OR             SYMBOL IS NULL OR SYMBOL = ''
 OR            ORDER_NO IS NULL OR ORDER_NO = ''
 OR            BACCOUNT_NO IS NULL OR BACCOUNT_NO = ''
 OR            SACCOUNT_NO IS NULL OR SACCOUNT_NO = ''
 OR            ORDER_QTTY IS NULL OR ORDER_QTTY = ''
           or  ORDER_PRICE IS NULL OR ORDER_PRICE = ''
     ;
    --Check so luu ky tren he thong
    for rec in
    (
        select * from TBLHNXI
        where SUBSTR(baccount_no,1,3)='086' and baccount_no not in (select custodycd from cfmast where status='A' and custodycd is not null)
        union all
        select * from TBLHNXI
        where SUBSTR(saccount_no,1,3)='086' and saccount_no not in (select custodycd from cfmast where status='A' and custodycd is not null)
        union all
        select * from TBLHNXI
        where SUBSTR(saccount_no,1,3)<>'086' and SUBSTR(baccount_no,1,3)<>'086'
    )
    LOOP
        update TBLHNXI
             SET deltd = 'Y',status = 'E', errmsg = 'data missing: ' || 'Error Custodycd '
             where autoid=rec.autoid;
    end loop;

    for rec1 in
    (
        select * from  TBLHNXI where order_date <> getcurrdate
    )
    loop
        update TBLHNXI
             SET deltd = 'Y',status = 'E', errmsg = 'data missing: ' || 'Error Date '
             where autoid=rec1.autoid;
    end loop;

    delete from  sts_orders_upcom;
    insert into  sts_orders_upcom(ORDER_ID,priority,stock_id,order_type, ORDER_DATE,ORDER_TIME , ACCOUNT_NO,co_account_no,  ORDER_NO,  ORDER_PRICE,   ORDER_QTTY, OORB,NORP,  NORC,STATUS,MEMBER_ID,co_member_id,FLOOR_CODE)
    select seq_TBLHNXI.nextval,1,b.codeid,0,ORDER_DATE, to_char(SYSTIMESTAMP,'HH:MM:SS SSSS') , SACCOUNT_NO,BACCOUNT_NO,ORDER_NO, ORDER_PRICE,ORDER_QTTY,2,3,5,0, 48,48,'002'
    from TBLHNXI X,sbsecurities b where x.status = 'P' and x.deltd <> 'Y'
      and x.symbol = b.symbol ;


    COMMIT;
EXCEPTION
   WHEN OTHERS THEN
   plog.error(SQLERRM || dbms_utility.format_error_backtrace);
       ROLLBACK;
         plog.setendsection(pkgctx, 'FILLTER_FILE_HNXI');
         p_err_code := errnums.C_SYSTEM_ERROR;
         p_err_message := 'SYSTEM_ERROR';
       --RETURN errnums.C_SYSTEM_ERROR;

END FILLTER_FILE_HNXI;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_filemaster',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
