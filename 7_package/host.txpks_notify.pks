SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_NOTIFY
/** ----------------------------------------------------------------------------------------------------
 ** Module: NOTIFY
 ** Description: Function for Event Push notification
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  DuongLH      17/02/2016           Created
 **  System      05/10/2011     Created
 ** (c) 2016 by Financial Software Solutions. JSC.
 ----------------------------------------------------------------------------------------------------*/
IS
PROCEDURE pr_encodereftostringarray_db(
    pv_refcursor   IN            pkg_report.ref_cursor,
    maxrow         IN            NUMBER,
    maxpage        IN            NUMBER,
    vreturnarray      OUT        simplestringarraytype);
PROCEDURE PR_FLEX2FO_ENQUEUE (PV_REFCURSOR IN pkg_report.ref_cursor,
queue_name IN VARCHAR2,
enq_msgid IN OUT RAW);
PROCEDURE pr_InvokeEnqueueTest;

PROCEDURE PR_NOTIFYEVENT2FO(
    pv_refcursor   IN            pkg_report.ref_cursor,
    queue_name IN VARCHAR2 default 'txaqs_FLEX2FO');
-- Return valid afacctno list for this user pv_username
-- Filtered by pv_aflist
-- Switch result by pv_channel: O, H, M, A,...
PROCEDURE PR_VALIDATEAFLIST(
    pv_refcursor   IN OUT            pkg_report.ref_cursor,
    pv_username IN VARCHAR2,
    pv_aflist IN VARCHAR2,
    pv_channel IN VARCHAR2);
PROCEDURE PR_GETTLID2TLNAME(
    pv_refcursor   IN OUT            pkg_report.ref_cursor,
    pv_querySource IN VARCHAR2);
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_NOTIFY
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
   ownerschema VARCHAR2(100);
 PROCEDURE pr_encodereftostringarray_db(
    pv_refcursor   IN            pkg_report.ref_cursor,
    maxrow         IN            NUMBER,
    maxpage        IN            NUMBER,
    vreturnarray      OUT        simplestringarraytype)
IS
--  GEN FIX MESSAGE FROM REF CURSOR
-- ---------   ------  -------------------------------------------
    v_cursor_number NUMBER;
    v_columns NUMBER;
    v_desc_tab dbms_sql.desc_tab;
    v_refcursor pkg_report.ref_cursor;
    v_number_value NUMBER;
    v_varchar_value VARCHAR(200);
    v_date_value DATE;
    l_str_val VARCHAR2(4000);
    l_spliter CHAR(1):=CHR(1);
    l_prefix VARCHAR2(10):= '8=FIX..';
    l_str_header VARCHAR2(4000);
    l_arr_msg simplestringarraytype := simplestringarraytype(1);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_encodereftostringarray_db');
    plog.debug(pkgctx, 'abt to encode refcursor maxrow, maxpage: ' || maxrow||','||maxpage);

    --Call procedure to open cursor
    v_refcursor := pv_refcursor;
    --Convert cursor to DBMS_SQL CURSOR
    v_cursor_number := dbms_sql.to_cursor_number(v_refcursor);
    --Get information on the columns
    dbms_sql.describe_columns(v_cursor_number, v_columns, v_desc_tab);
    --Loop through all the columns, find columname position and TYPE
--Get columns
    l_str_header := l_prefix|| l_spliter;
    FOR i IN 1 .. v_desc_tab.COUNT LOOP
            IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
            --Number
            l_str_header :=  l_str_header  || v_desc_tab(i).col_name|| l_spliter ;
                dbms_sql.define_column(v_cursor_number, i, v_number_value);
            ELSIF v_desc_tab(i).col_type = dbms_types.typecode_varchar
                OR  v_desc_tab(i).col_type = dbms_types.typecode_char THEN
            --Varchar, char
                l_str_header :=  l_str_header  || v_desc_tab(i).col_name|| l_spliter ;
                dbms_sql.define_column(v_cursor_number, i, v_varchar_value,200);
            ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
            --Date,
               l_str_header :=  l_str_header  || v_desc_tab(i).col_name|| l_spliter ;
               dbms_sql.define_column(v_cursor_number, i, v_date_value);
            END IF;
    END LOOP;
--Get values
    WHILE dbms_sql.fetch_rows(v_cursor_number) > 0 LOOP
        l_str_val := l_prefix|| l_spliter;
     FOR i IN 1 .. v_desc_tab.COUNT LOOP
          IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
          --Number
                dbms_sql.column_value(v_cursor_number, i, v_number_value);
                l_str_val :=l_str_val|| nvl(v_number_value,0) || l_spliter;
          END IF;
          IF v_desc_tab(i).col_type = dbms_types.typecode_varchar
            OR  v_desc_tab(i).col_type = dbms_types.typecode_char
            THEN
          --Varchar, char
                dbms_sql.column_value(v_cursor_number, i, v_varchar_value);
                l_str_val :=l_str_val|| nvl(v_varchar_value,'null') || l_spliter;
          END IF;
          IF v_desc_tab(i).col_type = dbms_types.typecode_date
            THEN
          --Date
                dbms_sql.column_value(v_cursor_number, i, v_date_value);
                l_str_val :=l_str_val|| to_char(v_date_value,'yyyymmdd-hh:mm:ss') || l_spliter;
          END IF;
    END LOOP;
    l_str_header:=l_str_header||l_str_val;
    END LOOP;
    l_arr_msg(1):= l_str_header;
    vreturnarray := l_arr_msg;
    dbms_sql.close_cursor(v_cursor_number);
    plog.setendsection (pkgctx, 'pr_encodereftostringarray_db');
EXCEPTION WHEN OTHERS THEN
    l_arr_msg(1):= '';
    vreturnarray := l_arr_msg;
    plog.error (pkgctx, '[maxrow:' || maxrow || '],[maxpage:' || maxpage || ']' || SQLERRM);
    plog.error (pkgctx, '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
    plog.setendsection (pkgctx, 'pr_encodereftostringarray_db');
END pr_encodereftostringarray_db;

PROCEDURE PR_FLEX2FO_ENQUEUE (PV_REFCURSOR IN pkg_report.ref_cursor,
queue_name IN VARCHAR2,
enq_msgid IN OUT RAW)
IS
   tmp_text_message   SYS.AQ$_JMS_TEXT_MESSAGE;
   eopt               DBMS_AQ.enqueue_options_t;
   mprop              DBMS_AQ.message_properties_t;
   tmp_encode_text    VARCHAR2 (32767);
   l_array_msg SimpleStringArrayType := SimpleStringArrayType();
BEGIN
    plog.setbeginsection (pkgctx, 'PR_FLEX2FO_ENQUEUE');
    plog.debug(pkgctx, 'abt to PR_FLEX2FO_ENQUEUE refcursor queue_name, enq_msgid: ' || queue_name||','||enq_msgid);
    pr_encodereftostringarray_db(PV_REFCURSOR => PV_REFCURSOR,
                              vReturnArray => l_array_msg,
                              maxRow       => 5,
                              maxPage      => 255);

    for i in 1 .. l_array_msg.COUNT
    loop
      tmp_encode_text := l_array_msg(i);
      if LENGTH(tmp_encode_text) > 1 then
        tmp_text_message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
        tmp_text_message.set_text(tmp_encode_text);
        DBMS_AQ.ENQUEUE(queue_name         => ownerschema ||
                                              '.' || queue_name,
                        enqueue_options    => eopt,
                        message_properties => mprop,
                        payload            => tmp_text_message,
                        msgid              => enq_msgid);


      end if;
      --DBMS_OUTPUT.PUT_LINE('PL/SQL element ' || i || ' obtains the value "' || vArray(i) || '".');
    end loop;
    --COMMIT;
    plog.setendsection (pkgctx, 'PR_FLEX2FO_ENQUEUE');
EXCEPTION WHEN OTHERS THEN
    plog.error (pkgctx, '[queue_name:' || queue_name || '],[enq_msgid:' || enq_msgid || ']' || SQLERRM);
    plog.error (pkgctx, '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
    plog.setendsection (pkgctx, 'PR_FLEX2FO_ENQUEUE');
END PR_FLEX2FO_ENQUEUE;

PROCEDURE pr_InvokeEnqueueTest
IS
    rs VARCHAR2(4000);
    pv_ref pkg_report.ref_cursor;
    enq_msgid RAW(16);
begin
    plog.setbeginsection (pkgctx, 'pr_InvokeEnqueueTest');
    plog.debug(pkgctx, 'abt to pr_InvokeEnqueueTest refcursor');
    OPEN pv_ref for SELECT * from afmast where rownum <=3;
    PR_FLEX2FO_ENQUEUE(PV_REFCURSOR=>pv_ref, ENQ_MSGID=>enq_msgid, queue_name=>'txaqs_FLEX2FO');
    plog.debug(pkgctx, 'ID:'||enq_msgid);
    close pv_ref;
    commit;
    plog.setendsection (pkgctx, 'pr_InvokeEnqueueTest');
EXCEPTION WHEN OTHERS THEN
    plog.error (pkgctx, SQLERRM);
    plog.error (pkgctx, '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
    plog.setendsection (pkgctx, 'pr_InvokeEnqueueTest');
end pr_InvokeEnqueueTest;

PROCEDURE PR_NOTIFYEVENT2FO(
    pv_refcursor   IN            pkg_report.ref_cursor,
    queue_name IN VARCHAR2 default 'txaqs_FLEX2FO')
IS
    enq_msgid RAW(16);
BEGIN
    plog.setbeginsection (pkgctx, 'PR_NOTIFYEVENT2FO');
    plog.debug(pkgctx, 'abt to PR_NOTIFYEVENT refcursor');
    PR_FLEX2FO_ENQUEUE(PV_REFCURSOR=>pv_refcursor, ENQ_MSGID=>enq_msgid, queue_name=> queue_name);
    plog.debug(pkgctx, 'ENQUEUE ID:'||enq_msgid);
    plog.setendsection (pkgctx, 'PR_NOTIFYEVENT2FO');
EXCEPTION WHEN OTHERS THEN
    plog.error (pkgctx, SQLERRM);
    plog.error (pkgctx, '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
    plog.setendsection (pkgctx, 'PR_NOTIFYEVENT2FO');
END PR_NOTIFYEVENT2FO;
PROCEDURE PR_VALIDATEAFLIST(
    pv_refcursor   IN OUT            pkg_report.ref_cursor,
    pv_username IN VARCHAR2,
    pv_aflist IN VARCHAR2,
    pv_channel IN VARCHAR2)
IS
    v_strParams VARCHAR2(4000);
    vCOUNT INTEGER;
    v_strVia VARCHAR2(10);
BEGIN
    vCOUNT:=0;
    v_strParams := 'Input.:[pv_username='||pv_username||',pv_aflist='||pv_aflist||',pv_channel='||pv_channel||']';
    plog.setbeginsection (pkgctx, 'PR_VALIDATEAFLIST');
    SELECT COUNT(1) INTO vCOUNT FROM tlprofiles WHERE tlname = pv_username;
    v_strVia:=SUBSTR(pv_channel,1,1);
    plog.debug(pkgctx, 'BEGIN.:'||v_strParams);
    IF INSTR('O|M|K|H',v_strVia)>0 AND vCOUNT=0 THEN
        -- SELECT aflist by USERLOGIN table
        plog.debug(pkgctx, 'User Query.:'||v_strParams);
        OPEN pv_refcursor FOR 
            SELECT ACCTNO,OWNER,CUSTODYCD,FULLNAME 
            FROM (/*
            -- MSBS, BVS
              SELECT 1 OWNER,AF.ACCTNO,AF.Fax1,AF.Email,CF.CUSTODYCD,AF.CUSTID,CF.FULLNAME,'YYYYYYYYYY' LINKAUTH,AF.BANKACCTNO, 
              AF.BANKNAME,CI.COREBANK,AF.STATUS,'' TYPENAME, AFT.TYPENAME AFTYPE, 
              (CASE WHEN R.EXPDATE < TO_DATE(getcurrdate(), 'DD/MM/RRRR') THEN 'Y' ELSE 'N' END) EXPIRED, AF.TRADEONLINE
                FROM OTRIGHT R, AFMAST AF,CFMAST CF,CIMAST CI, AFTYPE AFT
                WHERE AF.CUSTID=CF.CUSTID
                AND AF.ACCTNO=CI.AFACCTNO 
                AND AF.ACTYPE=AFT.ACTYPE                
                AND R.AFACCTNO = AF.ACCTNO
                AND R.AUTHCUSTID = CF.CUSTID
                AND R.DELTD = 'N'
                AND CF.USERNAME=pv_username
                --AND AF.TRADEONLINE = 'Y'
                --AND TO_DATE(:TXDATE, 'DD/MM/RRRR') <= R.EXPDATE
        UNION ALL
         SELECT 0 OWNER,R.AFACCTNO,AF.Fax1,AF.Email,CF.CUSTODYCD,CF.CUSTID,CF.FULLNAME,'NNNNNNNNNN' LINKAUTH,AF.BANKACCTNO, 
                AF.BANKNAME,CI.COREBANK,AF.STATUS, '' TYPENAME, AFT.TYPENAME AFTYPE,
                (CASE WHEN R.EXPDATE < TO_DATE(getcurrdate(), 'DD/MM/RRRR') THEN 'Y' ELSE 'N' END) EXPIRED, AF.TRADEONLINE
                FROM OTRIGHT R, AFMAST AF, CFMAST CF, CIMAST CI, AFTYPE AFT, CFMAST CFUSER
                WHERE AF.CUSTID=CF.CUSTID
                AND AF.ACCTNO=CI.AFACCTNO 
                AND AF.ACTYPE=AFT.ACTYPE
                AND R.AFACCTNO = AF.ACCTNO
                AND R.AUTHCUSTID <> CF.CUSTID
                AND R.DELTD = 'N'
                AND R.AUTHCUSTID = CFUSER.CUSTID 
                AND CFUSER.USERNAME=pv_username
                --AND AF.TRADEONLINE = 'Y'
                --AND TO_DATE(:TXDATE, 'DD/MM/RRRR') <= R.EXPDATE
          ORDER BY OWNER DESC
          */
          -- BSC, VCBS,
              SELECT 1 OWNER,AF.ACCTNO,CF.Fax FAX1,CF.Email,CF.CUSTODYCD,AF.CUSTID,CF.FULLNAME,'YYYYYYYYYY' LINKAUTH,AF.BANKACCTNO, 
              AF.BANKNAME,(case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) COREBANK,AF.STATUS,AFT.MNEMONIC TYPENAME, AFT.AFTYPE
              --(CASE WHEN R.EXPDATE < TO_DATE(:TXDATE, 'DD/MM/RRRR') THEN 'Y' ELSE 'N' END) EXPIRED,CF.TRADEONLINE,AF.AUTOADV
                FROM OTRIGHT R, AFMAST AF,CFMAST CF,CIMAST CI, AFTYPE AFT
                WHERE AF.CUSTID=CF.CUSTID
                AND AF.ACCTNO=CI.AFACCTNO 
                AND AF.ACTYPE=AFT.ACTYPE                
                --AND R.AFACCTNO = AF.ACCTNO
                AND R.CFCUSTID=AF.custid
                AND R.AUTHCUSTID = CF.CUSTID
                AND R.DELTD = 'N'
                AND CF.USERNAME=pv_username
                AND AF.ISFIXACCOUNT='N'
                --AND AF.TRADEONLINE = 'Y'
                AND getcurrdate() <= R.EXPDATE
                UNION ALL
                SELECT 0 OWNER,AF.ACCTNO,CF.Fax FAX1,CF.Email,CF.CUSTODYCD,CF.CUSTID,CF.FULLNAME,'NNNNNNNNNN' LINKAUTH,AF.BANKACCTNO, 
                AF.BANKNAME,(case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) COREBANK,AF.STATUS, AFT.MNEMONIC TYPENAME,AFT.AFTYPE
                --(CASE WHEN R.EXPDATE < TO_DATE(:TXDATE, 'DD/MM/RRRR') THEN 'Y' ELSE 'N' END) EXPIRED,CF.TRADEONLINE
                FROM OTRIGHT R, AFMAST AF, CFMAST CF, CIMAST CI, AFTYPE AFT, CFMAST CFUSER
                WHERE AF.CUSTID=CF.CUSTID
                AND AF.ACCTNO=CI.AFACCTNO 
                AND AF.ACTYPE=AFT.ACTYPE
                --AND R.AFACCTNO = AF.ACCTNO
                AND R.CFCUSTID=AF.custid
                AND R.AUTHCUSTID <> CF.CUSTID
                AND R.DELTD = 'N'
                AND R.AUTHCUSTID = CFUSER.CUSTID 
                AND CFUSER.USERNAME=pv_username
                AND AF.ISFIXACCOUNT='N'
                --AND AF.TRADEONLINE = 'Y'
                AND getcurrdate() <= R.EXPDATE
              ORDER BY OWNER DESC 
          ) MSC
          WHERE pv_aflist is null OR INSTR(pv_aflist,ACCTNO)>0;
    ELSIF INSTR('H|F',v_strVia)>0 AND vCOUNT>0 THEN
        -- SELECT aflist by tlprofile table
        plog.debug(pkgctx, 'Broker Query.:'||v_strParams);
    ELSE 
        plog.info(pkgctx, 'ELSE.:Not handle channel.:'||v_strParams);
    END IF;
    plog.debug(pkgctx, 'END.:'||v_strParams);
    plog.setendsection (pkgctx, 'PR_VALIDATEAFLIST');
EXCEPTION WHEN OTHERS THEN
    plog.error (pkgctx,v_strParams|| SQLERRM);
    plog.error (pkgctx,v_strParams|| '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
    plog.setendsection (pkgctx, 'PR_VALIDATEAFLIST');
END PR_VALIDATEAFLIST;
PROCEDURE PR_GETTLID2TLNAME(
    pv_refcursor   IN OUT            pkg_report.ref_cursor,
    pv_querySource IN VARCHAR2)
IS
BEGIN
    plog.setbeginsection (pkgctx, 'PR_GETTLID2TLNAME');
    plog.debug(pkgctx, 'BEGIN.:'||pv_querySource);
    OPEN pv_refcursor FOR 
        SELECT TLID,TLNAME FROM TLPROFILES 
        WHERE pv_querySource IS NULL OR pv_querySource=TLID;
    plog.setendsection (pkgctx, 'PR_GETTLID2TLNAME');
EXCEPTION WHEN OTHERS THEN
    plog.error (pkgctx,pv_querySource|| SQLERRM);
    plog.error (pkgctx,pv_querySource|| '[Format_error_backtrace] ' || dbms_utility.format_error_backtrace); --Log trace
    plog.setendsection (pkgctx, 'PR_GETTLID2TLNAME');
END PR_GETTLID2TLNAME;

--Init the plog component
BEGIN
      FOR i IN (SELECT *
                FROM tlogdebug)
      LOOP
         logrow.loglevel    := i.loglevel;
         logrow.log4table   := i.log4table;
         logrow.log4alert   := i.log4alert;
         logrow.log4trace   := i.log4trace;
      END LOOP;
      pkgctx    :=
         plog.init ('txpks_NOTIFY',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
      select sys_context('USERENV', 'CURRENT_SCHEMA') INTO ownerschema from dual;
END txpks_NOTIFY;
/
