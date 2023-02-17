SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0090ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0090EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      25/06/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
 IS
    FUNCTION FN_TXPREAPPCHECK(P_TXMSG    IN TX.MSG_RECTYPE,
                                                        P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
    FUNCTION FN_TXAFTAPPCHECK(P_TXMSG    IN TX.MSG_RECTYPE,
                                                        P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
    FUNCTION FN_TXPREAPPUPDATE(P_TXMSG    IN TX.MSG_RECTYPE,
                                                         P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
    FUNCTION FN_TXAFTAPPUPDATE(P_TXMSG    IN TX.MSG_RECTYPE,
                                                         P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#0090ex IS
    PKGCTX PLOG.LOG_CTX;
    LOGROW TLOGDEBUG%ROWTYPE;

    C_CUSTID     CONSTANT CHAR(2) := '03';
    C_CUSTODYCD  CONSTANT CHAR(2) := '88';
    C_USERNAME   CONSTANT CHAR(2) := '05';
    C_LOGINPWD   CONSTANT CHAR(2) := '10';
    C_ISMASTER   CONSTANT CHAR(2) := '14';
    C_AUTHTYPE   CONSTANT CHAR(2) := '11';
    C_TRADINGPWD CONSTANT CHAR(2) := '12';
    C_DAYS       CONSTANT CHAR(2) := '13';
    C_EMAIL      CONSTANT CHAR(2) := '06';
    C_TOKENID    CONSTANT CHAR(2) := '15';
    C_DESC       CONSTANT CHAR(2) := '30';
    FUNCTION FN_TXPREAPPCHECK(P_TXMSG    IN TX.MSG_RECTYPE,
                                                        P_ERR_CODE OUT VARCHAR2) RETURN NUMBER IS

    BEGIN
        PLOG.SETBEGINSECTION(PKGCTX, 'fn_txPreAppCheck');
        PLOG.DEBUG(PKGCTX, 'BEGIN OF fn_txPreAppCheck');
        /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
        PLOG.DEBUG(PKGCTX, '<<END OF fn_txPreAppCheck');
        PLOG.SETENDSECTION(PKGCTX, 'fn_txPreAppCheck');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR(PKGCTX, SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            PLOG.SETENDSECTION(PKGCTX, 'fn_txPreAppCheck');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXPREAPPCHECK;

    FUNCTION FN_TXAFTAPPCHECK(P_TXMSG    IN TX.MSG_RECTYPE,
                                                        P_ERR_CODE OUT VARCHAR2) RETURN NUMBER IS
        L_CUSTID       VARCHAR2(20);
        L_CUSTODYCD    VARCHAR2(20);
        L_USERNAME     VARCHAR2(100);
        L_USERNAME_OLD VARCHAR2(100);
        L_CFSTATUS     VARCHAR2(10);
        L_AFSTATUS     VARCHAR2(10);
        L_TRADEONLINE  VARCHAR2(10);
        L_RIGHTCOUNT   VARCHAR2(10);
        L_CURRDATE     VARCHAR2(10);
        L_COUNT        NUMBER(20, 0);
    BEGIN
        PLOG.SETBEGINSECTION(PKGCTX, 'fn_txAftAppCheck');
        PLOG.DEBUG(PKGCTX, '<<BEGIN OF fn_txAftAppCheck>>');

        L_CUSTID    := P_TXMSG.TXFIELDS(C_CUSTID).VALUE;
        L_USERNAME  := UPPER(P_TXMSG.TXFIELDS(C_USERNAME).VALUE);
        L_CUSTODYCD := UPPER(P_TXMSG.TXFIELDS(C_CUSTODYCD).VALUE);

        SELECT VARVALUE INTO L_CURRDATE FROM SYSVAR WHERE VARNAME = 'CURRDATE';

        --Kiem tra xem user nay da cap cho thang nao khac chua
        SELECT NVL(COUNT(*), 0)
            INTO L_COUNT
            FROM CFMAST
         WHERE USERNAME = L_USERNAME
             AND CUSTID <> L_CUSTID;
        IF L_COUNT > 0 THEN
            BEGIN
                P_ERR_CODE := ERRNUMS.C_CF_USERNAME_DUPLICATE;
                RETURN ERRNUMS.C_BIZ_RULE_INVALID;
            END;
        END IF;
        --Kiem tra trang thai thong tin khach hang (CF) la hoat dong
        BEGIN
            SELECT STATUS INTO L_CFSTATUS FROM CFMAST WHERE CUSTID = L_CUSTID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                P_ERR_CODE := ERRNUMS.C_CF_CUSTOM_NOTFOUND;
                RETURN ERRNUMS.C_BIZ_RULE_INVALID;
        END;

        PLOG.DEBUG(PKGCTX, 'cf status : ' || L_CFSTATUS);

        IF L_CFSTATUS <> 'A' THEN
            BEGIN
                P_ERR_CODE := ERRNUMS.C_CF_CFMAST_STAT_NOTVALID;
                RETURN ERRNUMS.C_BIZ_RULE_INVALID;
            END;
        END IF;
        --Kiem tra trang thai tieu khoan khach hang (AF) la hoat dong, truong TRADEONLINE cua AFMAST = Y
        --Co quyen con hieu luc trong bang OTRIGHT
        L_COUNT := 3;

        BEGIN
            FOR REC IN (SELECT CF.STATUS,
                                                 CF.TRADEONLINE,
                                                 NVL(OT.CFCUSTID, 'N/A') OTAFACCTNO
                                        FROM CFMAST CF,
                                                 (SELECT OT.CFCUSTID, OT.AUTHCUSTID
                                                        FROM OTRIGHT OT /*,(
                                                                                                                                                      SELECT CFCUSTID,COUNT(AUTHCUSTID) CNT FROM OTRIGHTDTL
                                                                                                                                                      WHERE AUTHCUSTID=l_custid
                                                                                                                                                      AND DELTD='N' AND OTRIGHT<>'NNNN'
                                                                                                                                                      GROUP BY CFCUSTID
                                                                                                                                                 ) OTL
                                                                                                                                                 WHERE OT.CFCUSTID=OTL.CFCUSTID */
                                                     WHERE OT.VALDATE <=
                                                                 TO_DATE(L_CURRDATE, 'DD/MM/RRRR')
                                                         AND OT.EXPDATE >=
                                                                 TO_DATE(L_CURRDATE, 'DD/MM/RRRR')
                                                         AND OT.AUTHCUSTID = L_CUSTID
                                                         AND DELTD = 'N'
                                                     GROUP BY OT.AUTHCUSTID, OT.CFCUSTID) OT
                                     WHERE CF.CUSTID = OT.CFCUSTID(+)
                                         AND CF.TRADEONLINE = 'Y'
                                         AND CF.CUSTID = L_CUSTID) LOOP
                BEGIN
                    PLOG.DEBUG(PKGCTX,
                                         'afstatus : ' || REC.STATUS || ' , tradeonline : ' ||
                                         REC.TRADEONLINE || ' , otacctno : ' || REC.OTAFACCTNO);

                    IF REC.STATUS <> 'A' THEN
                        L_COUNT := 1;
                    ELSIF REC.TRADEONLINE <> 'Y' THEN
                        L_COUNT := 2;
                    ELSIF REC.OTAFACCTNO = 'N/A' THEN
                        L_COUNT := 3;
                    ELSE
                        L_COUNT := 0;
                    END IF;

                    IF L_COUNT = 0 THEN
                        EXIT;
                    END IF;
                END;
            END LOOP;
        END;

        IF L_COUNT = 1 THEN
            P_ERR_CODE := ERRNUMS.C_CF_AFMAST_STATUS_INVALIDE;
            RETURN ERRNUMS.C_BIZ_RULE_INVALID;
        ELSIF L_COUNT = 2 THEN
            P_ERR_CODE := ERRNUMS.C_CF_AFMAST_NOTSIGNONLINE;
            RETURN ERRNUMS.C_BIZ_RULE_INVALID;
        ELSIF L_COUNT = 3 THEN
            P_ERR_CODE := ERRNUMS.C_CF_ONLINENOTHAVERIGHT;
            RETURN ERRNUMS.C_BIZ_RULE_INVALID;
        END IF;

        PLOG.DEBUG(PKGCTX, '<<END OF fn_txAftAppCheck>>');
        PLOG.SETENDSECTION(PKGCTX, 'fn_txAftAppCheck');

        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR(PKGCTX, SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            PLOG.SETENDSECTION(PKGCTX, 'fn_txAftAppCheck');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXAFTAPPCHECK;

    FUNCTION FN_TXPREAPPUPDATE(P_TXMSG    IN TX.MSG_RECTYPE,
                                                         P_ERR_CODE OUT VARCHAR2) RETURN NUMBER IS
    BEGIN
        PLOG.SETBEGINSECTION(PKGCTX, 'fn_txPreAppUpdate');
        PLOG.DEBUG(PKGCTX, '<<BEGIN OF fn_txPreAppUpdate');
        /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
        PLOG.DEBUG(PKGCTX, '<<END OF fn_txPreAppUpdate');
        PLOG.SETENDSECTION(PKGCTX, 'fn_txPreAppUpdate');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR(PKGCTX, SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            PLOG.SETENDSECTION(PKGCTX, 'fn_txPreAppUpdate');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXPREAPPUPDATE;

    FUNCTION FN_TXAFTAPPUPDATE(P_TXMSG    IN TX.MSG_RECTYPE,
                                                         P_ERR_CODE OUT VARCHAR2) RETURN NUMBER IS
        L_CUSTID        VARCHAR2(10);
        L_USERNAME      VARCHAR2(50);
        L_USERPASS      VARCHAR2(50);
        L_AUTHTYPE      VARCHAR2(10);
        L_TRADINGPASS   VARCHAR2(50);
        L_DAYS          VARCHAR2(10);
        L_EMAIL         VARCHAR2(250);
        L_ISMASTER      VARCHAR2(10);
        L_TOKENID       VARCHAR2(100);
        L_OLDUSERNAME   VARCHAR2(50);
        L_FULLNAME      VARCHAR2(250);
        L_CUSTODYCODE   VARCHAR2(50);
        L_TEMPLATEID    VARCHAR2(50);
        L_DATASOURCESQL VARCHAR2(400);
        L_COUNT         NUMBER(20, 0);
        L_TYPE          VARCHAR2(10);
        L_NEWPIN        VARCHAR2(50);
        L_TYPETRADE     VARCHAR2(1000);
        L_MOBILESMS     VARCHAR2(100);

        L_OLDLOGINPWD   VARCHAR2(1000);
        L_OLDTRADINGPWD VARCHAR2(1000);
    BEGIN
        PLOG.SETBEGINSECTION(PKGCTX, 'fn_txAftAppUpdate');
        PLOG.DEBUG(PKGCTX, '<<BEGIN OF fn_txAftAppUpdate');

        L_COUNT := 0;

        L_CUSTID      := P_TXMSG.TXFIELDS(C_CUSTID).VALUE;
        L_USERNAME    := UPPER(P_TXMSG.TXFIELDS(C_USERNAME).VALUE);
        L_USERPASS    := P_TXMSG.TXFIELDS(C_LOGINPWD).VALUE;
        L_TRADINGPASS := P_TXMSG.TXFIELDS(C_TRADINGPWD).VALUE;
        L_DAYS        := P_TXMSG.TXFIELDS(C_DAYS).VALUE;
        L_AUTHTYPE    := P_TXMSG.TXFIELDS(C_AUTHTYPE).VALUE;
        L_EMAIL       := P_TXMSG.TXFIELDS(C_EMAIL).VALUE;
        L_ISMASTER    := P_TXMSG.TXFIELDS(C_ISMASTER).VALUE;
        L_TOKENID     := P_TXMSG.TXFIELDS(C_TOKENID).VALUE;
        L_NEWPIN     := L_TRADINGPASS;

        BEGIN
            SELECT USERNAME, FULLNAME, CUSTODYCD
                INTO L_OLDUSERNAME, L_FULLNAME, L_CUSTODYCODE
                FROM CFMAST
             WHERE CUSTID = L_CUSTID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                P_ERR_CODE := ERRNUMS.C_CF_CUSTOM_NOTFOUND;
                RETURN ERRNUMS.C_CF_CUSTOM_NOTFOUND;
        END;

        IF L_USERNAME <> L_OLDUSERNAME THEN
            BEGIN
                --DELETE FROM USERLOGIN WHERE USERNAME = l_username;
                UPDATE USERLOGIN
                     SET USERNAME = L_USERNAME
                 WHERE USERNAME = L_OLDUSERNAME;
                UPDATE CFMAST
                     SET USERNAME = L_USERNAME
                 WHERE USERNAME = L_OLDUSERNAME;
            END;
        END IF;

       /* SELECT NVL(COUNT(*), 0)
            INTO L_COUNT
            FROM USERLOGIN
         WHERE USERNAME = L_USERNAME
             AND STATUS = 'A';*/
        SELECT AUTHTYPE
            INTO L_TYPE
            FROM USERLOGIN
         WHERE USERNAME = L_USERNAME
             AND STATUS = 'A';
        PLOG.ERROR(PKGCTX, 'l_username = ' || L_USERNAME);

        BEGIN
            SELECT MOBILESMS
                INTO L_MOBILESMS
                FROM VW_CFMAST_SMS
             WHERE CUSTID = L_CUSTID;
        EXCEPTION
            WHEN OTHERS THEN
                L_MOBILESMS := '';
        END;
        --- cap nhat vao bang USERLOGIN_CHANGE de kiem tra thoi gian thay doi pass.
        select count(*) into L_COUNT from userlogin_change where isprocess = 'N' and username = L_USERNAME;
        if L_COUNT > 0 then
            select max(OLDLOGINPWD), Max(OLDTRADINGPWD) into  L_OLDLOGINPWD, L_OLDTRADINGPWD
            from userlogin_change where isprocess = 'N' and username = L_USERNAME;
            update userlogin_change set isprocess = 'Y' where username = L_USERNAME and isprocess = 'N';
            insert into userlogin_change (ID,USERNAME,OLDLOGINPWD,OLDTRADINGPWD,NEWLOGINPWD,NEWTRADINGPWD,TIMECHANGE,ISPROCESS)
            VALUES (seq_userlogin_change.nextval,L_USERNAME,L_OLDLOGINPWD,L_OLDTRADINGPWD,GENENCRYPTPASSWORD(UPPER(L_USERPASS)), GENENCRYPTPASSWORD(UPPER(L_NEWPIN)),
                sysdate, 'N');
        else
            insert into userlogin_change (ID,USERNAME,OLDLOGINPWD,OLDTRADINGPWD,NEWLOGINPWD,NEWTRADINGPWD,TIMECHANGE,ISPROCESS)
            select seq_userlogin_change.nextval, USERNAME, LOGINPWD , TRADINGPWD,  GENENCRYPTPASSWORD(UPPER(L_USERPASS)), GENENCRYPTPASSWORD(UPPER(L_NEWPIN)),
                sysdate, 'N'
            from USERLOGIN where UPPER(USERNAME) = L_USERNAME and AUTHTYPE = '1';
        end if;
        --- End cap nhat vao bang USERLOGIN_CHANGE

        UPDATE USERLOGIN
                     SET ISRESET     = 'Y',
                             ISMASTER    = L_ISMASTER,
                             NUMBEROFDAY = L_DAYS,
                             LOGINPWD    = GENENCRYPTPASSWORD(UPPER(L_USERPASS)),
                             AUTHTYPE    = L_TYPE,
                             TRADINGPWD  = GENENCRYPTPASSWORD(UPPER(L_NEWPIN))
                 WHERE UPPER(USERNAME) = L_USERNAME;

        --chaunh: create sms
        BEGIN


            --IF SUBSTR(P_TXMSG.TXNUM, 0, 2) <> '68' THEN
            IF length(TRIM(l_mobilesms)) > 0 THEN
                L_DATASOURCESQL := 'select ''' || L_USERNAME || ''' username, ''' ||
                                                     L_USERPASS || ''' loginpwd, ''' || L_NEWPIN ||
                                                     ''' tradingpwd from dual';
                INSERT INTO EMAILLOG
                    (AUTOID, EMAIL, TEMPLATEID, DATASOURCE, STATUS, CREATETIME)
                VALUES
                    (SEQ_EMAILLOG.NEXTVAL,
                     L_MOBILESMS,
                     '304A',
                     L_DATASOURCESQL,
                     'A',
                     SYSDATE);
                        END IF;
           -- END IF;
            L_TEMPLATEID := '213B';
            L_DATASOURCESQL := 'select ''' || L_CUSTODYCODE || ''' custodycd, ''' ||
                                                 L_FULLNAME || ''' fullname, ''' || L_USERNAME ||
                                                 ''' username, ''' || L_USERPASS ||
                                                 ''' loginpwd, ''' || L_NEWPIN ||
                                                 ''' tradingpwd from dual';
            if nmpks_ems.CheckEmail(l_email) then
                  INSERT INTO EMAILLOG
                      (AUTOID, EMAIL, TEMPLATEID, DATASOURCE, STATUS, CREATETIME)
                  VALUES
                      (SEQ_EMAILLOG.NEXTVAL,
                       L_EMAIL,
                       L_TEMPLATEID,
                       L_DATASOURCESQL,
                       'A',
                       SYSDATE);
            end if;

        END;

        --end chaunh
        /*if l_type = '1' then
        begin
         l_templateid:='0212';
       --  select substr(sys_guid(),0,10) into l_newpin from dual;
         l_newpin:=  l_tradingpass;
         l_typetrade :='Mat khau dat lenh moi cua quy khach la';
         --
         UPDATE USERLOGIN SET ISRESET = 'Y', ISMASTER = l_ismaster,
            TOKENID = l_tokenid, LASTCHANGED=SYSDATE, NUMBEROFDAY=l_days, LOGINPWD=GENENCRYPTPASSWORD(UPPER(l_userpass)),AUTHTYPE=l_type,TRADINGPWD=GENENCRYPTPASSWORD(UPPER(l_newpin))
            WHERE UPPER(USERNAME)=l_username;

          --l_datasourcesql:='select ''' || l_username || ''' username, ''' || l_userpass || ''' loginpwd, ''' || l_newpin || ''' tradingpwd, ''' || l_typetrade || ''' typetrade, ''' ||
          --l_fullname || ''' fullname, '''' numberserial, ''' ||l_custodycode || ''' custodycode from dual';
          l_datasourcesql:='select ''' || l_username || ''' username, ''' || l_userpass || ''' loginpwd, ''' || l_newpin || ''' tradingpwd from dual';

          INSERT INTO emaillog (autoid, email, templateid, datasource, status, createtime)
          VALUES(seq_emaillog.nextval,l_email,l_templateid,l_datasourcesql,'A', SYSDATE);

          --nhan tin sms

          INSERT INTO emaillog (autoid, email, templateid, datasource, status, createtime)
          VALUES(seq_emaillog.nextval,l_mobilesms,'304A',l_datasourcesql,'A', SYSDATE);

        end;
      else
      IF l_count>0 THEN
        BEGIN
            l_templateid:='213B';
            UPDATE USERLOGIN SET ISRESET = 'Y', ISMASTER = l_ismaster,
            TOKENID = l_tokenid, LASTCHANGED=SYSDATE, NUMBEROFDAY=l_days, LOGINPWD=GENENCRYPTPASSWORD(UPPER(l_userpass))--,AUTHTYPE=l_authtype,TRADINGPWD=GENENCRYPTPASSWORD(UPPER(l_tradingpass))
            WHERE UPPER(USERNAME)=l_username;


        END;
      ELSE
        BEGIN
            l_templateid:='213A';

            INSERT INTO USERLOGIN (USERNAME, LOGINPWD--, AUTHTYPE, TRADINGPWD
            , STATUS, LASTLOGIN, LOGINSTATUS, LASTCHANGED, NUMBEROFDAY, ISMASTER, ISRESET
            --, TOKENID
            )
            SELECT l_username,GENENCRYPTPASSWORD(UPPER(l_userpass)),
            --l_authtype,GENENCRYPTPASSWORD(UPPER(l_tradingpass)),
            'A',SYSDATE,'O',SYSDATE,l_days,l_ismaster,'Y'--,l_tokenid
            FROM DUAL;

            UPDATE CFMAST SET USERNAME =l_username WHERE CUSTID = l_custid;
        END;
      end if;

      --update otright set AUTHTYPE=l_authtype,serialtoken = l_tokenid where cfcustid =l_custid;
      --l_datasourcesql:='select ''' || l_username || ''' username, ''' || l_userpass || ''' loginpwd, ''' || --l_tradingpass || ''' tradingpwd, ''' ||
      --l_fullname || ''' fullname, ''' || l_custodycode || ''' custodycode from dual';
      l_datasourcesql:='select ''' || l_username || ''' username, ''' || l_userpass || ''' loginpwd, ''' || l_tradingpass || ''' tradingpwd  from dual';

      INSERT INTO emaillog (autoid, email, templateid, datasource, status, createtime)
      VALUES(seq_emaillog.nextval,l_email,l_templateid,l_datasourcesql,'A', SYSDATE);

      INSERT INTO emaillog (autoid, email, templateid, datasource, status, createtime)
      VALUES(seq_emaillog.nextval,l_mobilesms,'304A',l_datasourcesql,'A', SYSDATE); --'304B'

    END IF;*/

        PLOG.DEBUG(PKGCTX, '<<END OF fn_txAftAppUpdate');
        PLOG.SETENDSECTION(PKGCTX, 'fn_txAftAppUpdate');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR(PKGCTX, SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            PLOG.SETENDSECTION(PKGCTX, 'fn_txAftAppUpdate');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXAFTAPPUPDATE;

BEGIN
    FOR I IN (SELECT * FROM TLOGDEBUG) LOOP
        LOGROW.LOGLEVEL  := I.LOGLEVEL;
        LOGROW.LOG4TABLE := I.LOG4TABLE;
        LOGROW.LOG4ALERT := I.LOG4ALERT;
        LOGROW.LOG4TRACE := I.LOG4TRACE;
    END LOOP;
    PKGCTX := PLOG.INIT('TXPKS_#0090EX',
                                            PLEVEL         => NVL(LOGROW.LOGLEVEL, 30),
                                            PLOGTABLE      => (NVL(LOGROW.LOG4TABLE, 'N') = 'Y'),
                                            PALERT         => (NVL(LOGROW.LOG4ALERT, 'N') = 'Y'),
                                            PTRACE         => (NVL(LOGROW.LOG4TRACE, 'N') = 'Y'));
END TXPKS_#0090EX;

/
