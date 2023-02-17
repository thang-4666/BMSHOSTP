SET DEFINE OFF;
CREATE OR REPLACE PACKAGE fwpks_toolkit
IS
     FUNCTION fn_gentransactpkg (p_tltxcd varchar2,
                                 p_genTLOGFLD CHAR,
                                 p_gen_autopkg char DEFAULT 'N',
                                 p_gen_impkg char DEFAULT 'N'
     )
        RETURN BOOLEAN;
   FUNCTION fn_genmultitransactpkg (p_multitltxcd varchar2,
                               p_genTLOGFLD CHAR,
                               p_gen_autopkg char DEFAULT 'N',
                               p_gen_impkg char DEFAULT 'N'
   )
      RETURN BOOLEAN;
  FUNCTION fn_genautopostmap (p_tltxcd varchar2,p_ibt varchar2)
      RETURN CLOB;
  PROCEDURE pr_genimppkg (p_tltxcd varchar2);
  FUNCTION fn_genBankRequest(p_tltxcd varchar2) RETURN VARCHAR2;
END;

 
/


CREATE OR REPLACE PACKAGE BODY fwpks_toolkit
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   PROCEDURE pr_execute(p_sql clob)
   is
        l_leng pls_integer := 0;
        l_stmt Varchar2(5000);
        l_stmt2 Varchar2(5000);
        l_stmt3 Varchar2(5000);
        l_stmt4 Varchar2(5000);
        l_stmt5 Varchar2(5000);
        l_lengstr number(10,0);
    Begin
        plog.setbeginsection (pkgctx, 'pr_execute');
        plog.debug(pkgctx, 'Begin execute!');
        l_lengstr:= 5000;
        l_leng := dbms_lob.getLength(p_sql);
        -- Read the whole clob but do not exceed 32767 limit.
        l_stmt := dbms_lob.substr(p_sql, l_lengstr, 1);
        If l_leng > l_lengstr
        Then
            l_stmt2 := dbms_lob.substr(p_sql,l_lengstr,l_lengstr+1);
        END IF;
        If l_leng > 2*l_lengstr
        Then
            l_stmt3 := dbms_lob.substr(p_sql,l_lengstr,2*l_lengstr+1);
        END IF;
        If l_leng > 3*l_lengstr
        Then
            l_stmt4 := dbms_lob.substr(p_sql,l_lengstr,3*l_lengstr+1);
        End If;
        If l_leng > 4*l_lengstr
        Then
            l_stmt5 := dbms_lob.substr(p_sql,l_lengstr,4*l_lengstr+1);
        End If;
        insert into tbl_postmap(datetime,tltxcd,postmap)
          values (to_char(sysdate),'1',l_stmt );
        insert into tbl_postmap(datetime,tltxcd,postmap)
          values (to_char(sysdate),'2',l_stmt2 );
        insert into tbl_postmap(datetime,tltxcd,postmap)
          values (to_char(sysdate),'3',l_stmt3 );
        insert into tbl_postmap(datetime,tltxcd,postmap)
          values (to_char(sysdate),'4',l_stmt4 );
        insert into tbl_postmap(datetime,tltxcd,postmap)
          values (to_char(sysdate),'5',l_stmt5 );
        Execute Immediate l_stmt || l_stmt2 || l_stmt3 || l_stmt4 || l_stmt4;
        plog.debug(pkgctx, 'End execute!');
        plog.setendsection (pkgctx, 'pr_execute');
    end;

   FUNCTION pr_parse_amtexp (p_amtexp varchar2)
      RETURN VARCHAR2
   IS
      l_exp   VARCHAR2 (1000);
      l_count   number;
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_parse_amtexp');

      IF INSTR (p_amtexp, '@') > 0
      THEN
         l_exp   := SUBSTR (p_amtexp, 2);
         --l_exp   := REGEXP_REPLACE (l_exp, '(.){1}', '''\1'',');
         plog.setendsection (pkgctx, 'pr_parse_amtexp');
         RETURN l_exp; --SUBSTR (l_exp, 1, LENGTH (l_exp) - 1);
      ELSIF substr(p_amtexp,1,1) = '$' or substr(p_amtexp,1,1) = '#'
      THEN
         l_exp   := SUBSTR (p_amtexp, 2);
         l_exp   := 'p_txmsg.txfields('''|| l_exp ||''').value';
         plog.setendsection (pkgctx, 'pr_parse_amtexp');
         RETURN l_exp; --SUBSTR (l_exp, 1, LENGTH (l_exp) - 1);
      ELSIF p_amtexp = '<$BUSDATE>'
      THEN
         plog.setendsection (pkgctx, 'pr_parse_amtexp');
         RETURN 'TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)';
      elsif instr(p_amtexp,'FORMAT:')>0 then
            l_count:=0;
            For l_id in  7 .. Length(p_amtexp) - 1 loop
                if l_count=0 then
                    If substr(p_amtexp,l_id+1,1) = '#' Then
                        l_exp := l_exp || ''' || p_txmsg.txfields (''' || substr(p_amtexp,l_id+2,2) || ''').VALUE || ''';
                        l_count:= 2;
                    Else
                        l_exp := l_exp || substr(p_amtexp,l_id+1,1);
                    End If;
                else
                    l_count:=l_count-1;
                end if;
            end loop;
            l_exp:='''' || l_exp || '''';
            RETURN l_exp;
      ELSE
         l_exp   := REPLACE (p_amtexp, '**', '*');
         l_exp   := REPLACE (l_exp, '//', '/');
         l_exp   := REPLACE (l_exp, '++', '+');
         l_exp   := REPLACE (l_exp, '--', '-');
         l_exp   := REPLACE (l_exp, '((', '(');
         l_exp   := REPLACE (l_exp, '))', ')');
         plog.setendsection (pkgctx, 'pr_parse_amtexp');
         RETURN REGEXP_REPLACE (l_exp,
                                '([[:digit:]]{1,2})',
                                'p_txmsg.txfields(''\1'').value'
                );
      END IF;

      plog.setendsection (pkgctx, 'pr_parse_amtexp');
   END pr_parse_amtexp;

   FUNCTION pr_parse_amtexp_rnd (p_amtexp varchar2,p_rnd varchar2)
      RETURN VARCHAR2
   IS
      l_exp   VARCHAR2 (1000);
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_parse_amtexp_rnd');

      IF INSTR (p_amtexp, '@') > 0
      THEN
         l_exp   := SUBSTR (p_amtexp, 2);
         --l_exp   := REGEXP_REPLACE (l_exp, '(.){1}', '''\1'',');
         plog.setendsection (pkgctx, 'pr_parse_amtexp_rnd');
         RETURN l_exp; --SUBSTR (l_exp, 1, LENGTH (l_exp) - 1);
      ELSIF p_amtexp = '<$BUSDATE>'
      THEN
         plog.setendsection (pkgctx, 'pr_parse_amtexp_rnd');
         RETURN 'TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT)';
      ELSE
         l_exp   := REPLACE (p_amtexp, '**', '*');
         l_exp   := REPLACE (l_exp, '//', '/');
         l_exp   := REPLACE (l_exp, '++', '+');
         l_exp   := REPLACE (l_exp, '--', '-');
         l_exp   := REPLACE (l_exp, '((', '(');
         l_exp   := REPLACE (l_exp, '))', ')');
         begin
            if p_rnd is null THEN

                plog.setendsection (pkgctx, 'pr_parse_amtexp_rnd');
                RETURN REGEXP_REPLACE (l_exp,
                                '([[:digit:]]{1,2})',
                                'p_txmsg.txfields(''\1'').value'
                );
            elsif to_number(p_rnd)<0 then
                plog.setendsection (pkgctx, 'pr_parse_amtexp_rnd');
                RETURN REGEXP_REPLACE (l_exp,
                                '([[:digit:]]{1,2})',
                                'p_txmsg.txfields(''\1'').value'
                );
            else
                plog.setendsection (pkgctx, 'pr_parse_amtexp_rnd');
               RETURN 'ROUND(' || REGEXP_REPLACE (l_exp,
                                '([[:digit:]]{1,2})',
                                'p_txmsg.txfields(''\1'').value'
                                                 )
                               || ',' || to_number (p_rnd) || ')';

            end if;
         exception when others then
            RETURN REGEXP_REPLACE (l_exp,
                                '([[:digit:]]{1,2})',
                                'p_txmsg.txfields(''\1'').value'
                );
         end;
      END IF;

      plog.setendsection (pkgctx, 'pr_parse_amtexp_rnd');
   END pr_parse_amtexp_rnd;

   PROCEDURE pr_genimppkg (p_tltxcd varchar2)
   IS
      l_source_proc      CLOB; --VARCHAR2 (32000);
      l_wrapped_proc     CLOB; --VARCHAR2 (32000);
      l_txpks_imp_name   VARCHAR2 (60);
      l_maxfield         NUMBER (3);
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_genimppkg');
      plog.debug(pkgctx,'Begin generate');
      l_txpks_imp_name   := 'TXPKS_#' || p_tltxcd || 'EX';
      plog.debug(pkgctx,'l_txpks_imp_name' || l_txpks_imp_name );
      l_source_proc      :=
         'CREATE OR REPLACE PACKAGE ' || l_txpks_imp_name || CHR (10)
         || '/**----------------------------------------------------------------------------------------------------'
         || CHR (10)
         || ' ** Package: ' || l_txpks_imp_name
         || CHR (10)
         || ' ** and is copyrighted by FSS.'
         || CHR (10)
         || ' **'
         || CHR (10)
         || ' **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,'
         || CHR (10)
         || ' **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,'
         || CHR (10)
         || ' **    graphic, optic recording or otherwise, translated in any language or computer language,'
         || CHR (10)
         || ' **    without the prior written permission of Financial Software Solutions. JSC.'
         || CHR (10)
         || ' **'
         || CHR (10)
         || ' **  MODIFICATION HISTORY'
         || CHR (10)
         || ' **  Person      Date           Comments'
         || CHR (10)
         || ' **  System      '
         || TO_CHAR (SYSDATE, 'DD/MM/RRRR')
         || '     Created'
         || CHR (10)
         || ' **  '
         || CHR (10)
         || ' ** (c) 2008 by Financial Software Solutions. JSC.'
         || CHR (10)
         || ' ** ----------------------------------------------------------------------------------------------------*/'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'END;';

      EXECUTE IMMEDIATE l_source_proc;

      l_source_proc      :=
            'CREATE OR REPLACE PACKAGE BODY '
         || l_txpks_imp_name
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   pkgctx   plog.log_ctx;'
         || CHR (10)
         || '   logrow   tlogdebug%ROWTYPE;'
         || CHR (10);

      SELECT MAX (LENGTH (defname))
      INTO l_maxfield
      FROM fldmaster
      WHERE objname = p_tltxcd;

      plog.debug (pkgctx, 'max length: ' || l_maxfield);

      FOR i IN (SELECT defname, fldname, fldtype
                FROM fldmaster
                WHERE objname = p_tltxcd
                ORDER BY odrnum)
      LOOP
         plog.debug (pkgctx, 'i.defname: ' || i.defname);

         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '   c_'
            || LOWER (i.defname)
            || LPAD ('    ', 13 - LENGTH (i.defname) + 1, ' ')
            || '   CONSTANT CHAR(2) := '''
            || i.fldname
            || ''';';
      END LOOP;

      l_source_proc      :=
         l_source_proc || CHR (10)
         || 'FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txPreAppCheck'');'
         || CHR (10)
         || '   plog.debug(pkgctx,''BEGIN OF fn_txPreAppCheck'');'
         || CHR (10)
         || '   /***************************************************************************************************'
         || CHR (10)
         || '    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:'
         || CHR (10)
         || '    * IF NOT <<YOUR BIZ CONDITION>> THEN'
         || CHR (10)
         || '    *    p_err_code := ''<<ERRNUM>>''; -- Pre-defined in DEFERROR table'
         || CHR (10)
         || '    *    plog.setendsection (pkgctx, ''fn_txPreAppCheck'');'
         || CHR (10)
         || '    *    RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '    * END IF;'
         || CHR (10)
         || '    ***************************************************************************************************/'
         || CHR (10)
         || '    plog.debug (pkgctx, ''<<END OF fn_txPreAppCheck'');'
         || CHR (10)
         || '    plog.setendsection (pkgctx, ''fn_txPreAppCheck'');'
         || CHR (10)
         || '    RETURN systemnums.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txPreAppCheck'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txPreAppCheck;'
         || CHR (10)
         || CHR (10)
         || 'FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txAftAppCheck'');'
         || CHR (10)
         || '   plog.debug (pkgctx, ''<<BEGIN OF fn_txAftAppCheck>>'');'
         || CHR (10)
         || '   /***************************************************************************************************'
         || CHR (10)
         || '    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:'
         || CHR (10)
         || '    * IF NOT <<YOUR BIZ CONDITION>> THEN'
         || CHR (10)
         || '    *    p_err_code := ''<<ERRNUM>>''; -- Pre-defined in DEFERROR table'
         || CHR (10)
         || '    *    plog.setendsection (pkgctx, ''fn_txAftAppCheck'');'
         || CHR (10)
         || '    *    RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '    * END IF;'
         || CHR (10)
         || '    ***************************************************************************************************/'
         || CHR (10)
         || '   plog.debug (pkgctx, ''<<END OF fn_txAftAppCheck>>'');'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txAftAppCheck'');'
         || CHR (10)
         || '   RETURN systemnums.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txAftAppCheck'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAftAppCheck;'
         || CHR (10)
         || CHR (10)
         || 'FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '    plog.setbeginsection (pkgctx, ''fn_txPreAppUpdate'');'
         || CHR (10)
         || '    plog.debug (pkgctx, ''<<BEGIN OF fn_txPreAppUpdate'');'
         || CHR (10)
         || '   /***************************************************************************************************'
         || CHR (10)
         || '    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT'
         || CHR (10)
         || '    ***************************************************************************************************/'
         || CHR (10)
         || '    plog.debug (pkgctx, ''<<END OF fn_txPreAppUpdate'');'
         || CHR (10)
         || '    plog.setendsection (pkgctx, ''fn_txPreAppUpdate'');'
         || CHR (10)
         || '    RETURN systemnums.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txPreAppUpdate'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txPreAppUpdate;'
         || CHR (10)
         || CHR (10)
         || 'FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '    plog.setbeginsection (pkgctx, ''fn_txAftAppUpdate'');'
         || CHR (10)
         || '    plog.debug (pkgctx, ''<<BEGIN OF fn_txAftAppUpdate'');'
         || CHR (10)
         || '   /***************************************************************************************************'
         || CHR (10)
         || '    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT'
         || CHR (10)
         || '    ***************************************************************************************************/'
         || CHR (10)
         || '    plog.debug (pkgctx, ''<<END OF fn_txAftAppUpdate'');'
         || CHR (10)
         || '    plog.setendsection (pkgctx, ''fn_txAftAppUpdate'');'
         || CHR (10)
         || '    RETURN systemnums.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txAftAppUpdate'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAftAppUpdate;'
         || CHR (10)
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '      FOR i IN (SELECT *'
         || CHR (10)
         || '                FROM tlogdebug)'
         || CHR (10)
         || '      LOOP'
         || CHR (10)
         || '         logrow.loglevel    := i.loglevel;'
         || CHR (10)
         || '         logrow.log4table   := i.log4table;'
         || CHR (10)
         || '         logrow.log4alert   := i.log4alert;'
         || CHR (10)
         || '         logrow.log4trace   := i.log4trace;'
         || CHR (10)
         || '      END LOOP;'
         || CHR (10)
         || '      pkgctx    :='
         || CHR (10)
         || '         plog.init ('''
         || l_txpks_imp_name
         || ''','
         || CHR (10)
         || '                    plevel => NVL(logrow.loglevel,30),'
         || CHR (10)
         || '                    plogtable => (NVL(logrow.log4table,''N'') = ''Y''),'
         || CHR (10)
         || '                    palert => (NVL(logrow.log4alert,''N'') = ''Y''),'
         || CHR (10)
         || '                    ptrace => (NVL(logrow.log4trace,''N'') = ''Y'')'
         || CHR (10)
         || '            );'
         || CHR (10)
         || 'END '
         || l_txpks_imp_name
         || ';';
      plog.debug (pkgctx, 'got obj name: ' || l_txpks_imp_name);

      INSERT INTO cstb_user_sources
     (
         object_name,
         archive_date,
         user_source
     )
      VALUES (
                l_txpks_imp_name,
                SYSDATE,
                DBMS_METADATA.get_ddl ('PACKAGE', l_txpks_imp_name)
             );

      EXECUTE IMMEDIATE l_source_proc;

      COMMIT;
      plog.setendsection (pkgctx, 'pr_genimppkg');
   END pr_genimppkg;

   PROCEDURE pr_genautopkg (p_tltxcd varchar2)
   IS
      l_source_proc      CLOB; --VARCHAR2 (32000);
      l_wrapped_proc     CLOB; --VARCHAR2 (32000);
      l_txpks_imp_name   VARCHAR2 (60);
      l_txpks_biz_name   VARCHAR2 (60);
   --l_sqlloop          VARCHAR2 (32000);
   --l_commit_freq      NUMBER (6);
   --l_cachesize        NUMBER (6);
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_genAutopkg');
      l_txpks_imp_name   := 'TXPKS_#' || p_tltxcd || 'AUTO';
      l_txpks_biz_name   := 'TXPKS_#' || p_tltxcd;

      FOR i IN (SELECT fldmap, cfreq, cachesize
                --INTO l_sqlloop, l_commit_freq, l_cachesize
                FROM txauto
                WHERE tltxcd = p_tltxcd)
      LOOP
         l_source_proc   :=
            'CREATE OR REPLACE PACKAGE ' || l_txpks_imp_name || CHR (10)
            || '/*----------------------------------------------------------------------------------------------------'
            || CHR (10)
            || ' ** Module: TX'
            || CHR (10)
            || ' ** and is copyrighted by FSS.'
            || CHR (10)
            || ' **'
            || CHR (10)
            || ' **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,'
            || CHR (10)
            || ' **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,'
            || CHR (10)
            || ' **    graphic, optic recording or otherwise, translated in any language or computer language,'
            || CHR (10)
            || ' **    without the prior written permission of Financial Software Solutions. JSC.'
            || CHR (10)
            || ' **'
            || CHR (10)
            || ' **  MODIFICATION HISTORY'
            || CHR (10)
            || ' **  Person      Date           Comments'
            || CHR (10)
            || ' **  System      '
            || TO_CHAR (SYSDATE, 'DD/MM/RRRR')
            || '     Created'
            || CHR (10)
            || ' **  '
            || CHR (10)
            || ' ** (c) 2008-'
            || TO_CHAR (SYSDATE, 'RRRR')
            || ' by Financial Software Solutions. JSC.'
            || CHR (10)
            || ' ----------------------------------------------------------------------------------------------------*/'
            || CHR (10)
            || 'IS'
            || CHR (10)
            || 'PROCEDURE pr_auto(p_autotype varchar2);'
            || CHR (10)
            || CHR (10)
            || '--FUNCTION fn_Batch(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
            || CHR (10)
            || '--RETURN NUMBER;'
            || CHR (10)
            || CHR (10)
            || 'END;';

         EXECUTE IMMEDIATE l_source_proc;

         -- Put get freq commit here
         l_source_proc   :=
               'CREATE OR REPLACE PACKAGE BODY '
            || l_txpks_imp_name
            || CHR (10)
            || 'IS'
            || CHR (10)
            || '   pkgctx   plog.log_ctx;'
            || CHR (10)
            || '   logrow   tlogdebug%ROWTYPE;'
            || CHR (10)
            || CHR (10)
            || 'PROCEDURE pr_auto(p_autotype varchar2)'
            || CHR (10)
            || 'IS'
            || CHR (10)
            || '   l_txmsg tx.msg_rectype;'
            || CHR (10)
            || '   l_orders_cache_size NUMBER(10) := 10000;'
            || CHR (10)
            || '   l_commit_freq       NUMBER(10) := 10;'
            || CHR (10)
            || '   l_count             NUMBER(10) := 0;'
            || CHR (10)
            || '   l_err_code deferror.errnum%TYPE;'
            || CHR (10)
            || '   l_err_param deferror.errdesc%TYPE;'
            || CHR (10)
            || '   CURSOR curs_build_msg'
            || CHR (10)
            || '       IS'
            || CHR (10)
            || '   '
            || i.fldmap
            || ';'
            || CHR (10)
            || '   TYPE build_msg_arrtype IS'
            || CHR (10)
            || '   TABLE OF curs_build_msg%ROWTYPE'
            || CHR (10)
            || '   INDEX BY PLS_INTEGER;'
            || CHR (10)
            || '   l_build_msg build_msg_arrtype;'
            || CHR (10)
            || 'BEGIN'
            || CHR (10)
            || '   plog.setbeginsection (pkgctx, ''pr_auto'');'
            || CHR (10)
            || '   plog.debug(pkgctx,''BEGIN OF pr_auto'');'
            || CHR (10)
            || '   /***************************************************************************************************'
            || CHR (10)
            || '    ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:'
            || CHR (10)
            || '    ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA'
            || CHR (10)
            || '   ****************************************************************************************************/'
            || CHR (10)
            || '    l_commit_freq := '
            || i.cfreq
            || ';'
            || CHR (10)
            || '    -- 1. Set common values'
            || CHR (10)
            || '    l_txmsg.tltxcd      := '''
            || p_tltxcd
            || ''';'
            || CHR (10)
            || '    l_txmsg.brid        := systemnums.C_HO_BRID;'
            || CHR (10)
            || '    l_txmsg.tlid        := systemnums.C_SYSTEM_USERID;'
            || CHR (10)
            || '    l_txmsg.off_line := ''N'';'
            || CHR (10)
            || '    l_txmsg.deltd := txnums.C_DELTD_TXNORMAL;'
            || CHR (10)
            || '    l_txmsg.txstatus := txstatusnums.c_txcompleted;'
            || CHR (10)
            || '    l_txmsg.msgsts := ''0'';'
            || CHR (10)
            || '    l_txmsg.ovrsts := ''0'';'
            || CHR (10)
            || '    l_txmsg.batchname := p_autotype;'
            || CHR (10)
            || '    select SYS_CONTEXT(''USERENV'',''HOST''),SYS_CONTEXT(''USERENV'', ''IP_ADDRESS'', 15)'
            || CHR (10)
            || '    INTO l_txmsg.wsname, l_txmsg.ipaddress'
            || CHR (10)
            || '    from dual;'
            || CHR (10)
            || '    -- 2. Set specific value for each transaction'
            || CHR (10)
            || '     OPEN curs_build_msg;'
            || CHR (10)
            || '     LOOP'
            || CHR (10)
            || '       FETCH curs_build_msg'
            || CHR (10)
            || '           BULK COLLECT INTO l_build_msg LIMIT '
            || i.cachesize
            || ';'
            || CHR (10)
            || '           EXIT WHEN l_build_msg.COUNT = 0;'
            || CHR (10)
            || '           FOR indx IN 1 .. l_build_msg.COUNT'
            || CHR (10)
            || '           LOOP'
            || CHR (10)
            || '               SAVEPOINT SP#1;'
            || CHR (10)
            || '               l_count := l_count + 1; -- increase the commit freq counter'
            || CHR (10)
            || '               --2.1 Set txnum'
            || CHR (10)
            || '               SELECT ''9000'' || LPAD (seq_generalviewtxnum.NEXTVAL, 6, ''0'')'
            || CHR (10)
            || '               INTO l_txmsg.txnum'
            || CHR (10)
            || '               FROM DUAL;'
            || CHR (10)
            || '               --2.2 Set txtime'
            || CHR (10)
            || '               SELECT TO_CHAR (SYSDATE, systemnums.C_TIME_FORMAT)'
            || CHR (10)
            || '               INTO l_txmsg.txtime'
            || CHR (10)
            || '               FROM DUAL;'
            || CHR (10)
            || '               l_txmsg.chktime := l_txmsg.txtime;'
            || CHR (10)
            || '               l_txmsg.offtime := l_txmsg.txtime;'
            || CHR (10)
            || '               --2.3 Set txdate'
            || CHR (10)
            || '               SELECT TO_DATE(varvalue,systemnums.C_DATE_FORMAT)'
            || CHR (10)
            || '               INTO l_txmsg.txdate'
            || CHR (10)
            || '               FROM sysvar'
            || CHR (10)
            || '               WHERE grname = ''SYSTEM'' AND varname = ''CURRDATE'';'
            || CHR (10)
            || '               l_txmsg.brdate := l_txmsg.txdate;'
            || CHR (10)
            || '               l_txmsg.busdate := l_txmsg.txdate;'
            || CHR (10)
            || '               --2.4 Set fld value'
            || CHR (10);

         FOR i IN (SELECT fldname, defname, fldtype, en_caption
                   FROM fldmaster
                   WHERE objname = p_tltxcd
                   ORDER BY odrnum)
         LOOP
            l_source_proc   :=
                  l_source_proc
               || '               l_txmsg.txfields ('''
               || i.fldname
               || ''').defname :='''
               || i.defname
               || ''';'
               || CHR (10)
               || '               l_txmsg.txfields ('''
               || i.fldname
               || ''').type :='''
               || i.fldtype
               || ''';'
               || CHR (10)
               || '               l_txmsg.txfields ('''
               || i.fldname
               || ''').value := l_build_msg(indx).fld'
               || i.fldname
               || '; --field: '
               || i.en_caption
               || CHR (10);
         END LOOP;

         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '               --2.4 Process'
            || CHR (10)
            || '               IF '
            || l_txpks_biz_name
            || '.fn_autotxprocess (l_txmsg, l_err_code, l_err_param) <>'
            || CHR (10)
            || '               systemnums.c_success'
            || CHR (10)
            || '               THEN'
            || CHR (10)
            || '                   plog.debug (pkgctx, ''got error'');'
            || CHR (10)
            || '                   --ONLY ROLLBACK FOR THIS MESSAGE'
            || CHR (10)
            || '                   ROLLBACK TO SAVEPOINT SP#1;'
            || CHR (10)
            || '                   --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR'
            || CHR (10)
            || '               END IF;'
            || CHR (10)
            || CHR (10)
            || '               IF l_count >= l_commit_freq THEN'
            || CHR (10)
            || '                   l_count := 0; -- reset the commit freq counter'
            || CHR (10)
            || '                   COMMIT;'
            || CHR (10)
            || '               END IF;'
            || CHR (10)
            || '           END LOOP;'
            || CHR (10)
            || '    END LOOP;'
            || CHR (10)
            || '    COMMIT; -- Commit the last trunk (if any)'
            || CHR (10)
            || '    /***************************************************************************************************'
            || CHR (10)
            || '    ** END;'
            || CHR (10)
            || '    ***************************************************************************************************/'
            || CHR (10)
            || '    plog.debug (pkgctx, ''<<END OF pr_auto'');'
            || CHR (10)
            || '    plog.setendsection (pkgctx, ''pr_auto'');'
            || CHR (10)
            || CHR (10)
            || 'EXCEPTION'
            || CHR (10)
            || 'WHEN OTHERS'
            || CHR (10)
            || '   THEN'
            || CHR (10)
            || '      ROLLBACK;'
            || CHR (10)
            || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
            || CHR (10)
            || '      plog.setendsection (pkgctx, ''pr_auto'');'
            || CHR (10)
            || 'END pr_auto;'
            || CHR (10)
            || CHR (10)
            || 'BEGIN'
            || CHR (10)
            || '      FOR i IN (SELECT *'
            || CHR (10)
            || '                FROM tlogdebug)'
            || CHR (10)
            || '      LOOP'
            || CHR (10)
            || '         logrow.loglevel    := i.loglevel;'
            || CHR (10)
            || '         logrow.log4table   := i.log4table;'
            || CHR (10)
            || '         logrow.log4alert   := i.log4alert;'
            || CHR (10)
            || '         logrow.log4trace   := i.log4trace;'
            || CHR (10)
            || '      END LOOP;'
            || CHR (10)
            || '      pkgctx    :='
            || CHR (10)
            || '         plog.init ('''
            || l_txpks_imp_name
            || ''','
            || CHR (10)
            || '                    plevel => NVL(logrow.loglevel,30),'
            || CHR (10)
            || '                    plogtable => (NVL(logrow.log4table,''N'') = ''Y''),'
            || CHR (10)
            || '                    palert => (NVL(logrow.log4alert,''N'') = ''Y''),'
            || CHR (10)
            || '                    ptrace => (NVL(logrow.log4trace,''N'') = ''Y'')'
            || CHR (10)
            || '            );'
            || CHR (10)
            || 'END '
            || l_txpks_imp_name
            || ';';
      END LOOP;

      plog.debug (pkgctx, 'Archive : ' || l_txpks_imp_name);

      INSERT INTO cstb_user_sources
     (
         object_name,
         archive_date,
         user_source
     )
      VALUES (
                l_txpks_imp_name,
                SYSDATE,
                DBMS_METADATA.get_ddl ('PACKAGE', l_txpks_imp_name)
             );
      l_wrapped_proc     := sys.DBMS_DDL.wrap (ddl => l_source_proc);
      plog.debug(pkgctx,'done');

      EXECUTE IMMEDIATE l_wrapped_proc;

      COMMIT;
      plog.setendsection (pkgctx, 'pr_genAutopkg');
   END pr_genautopkg;



-----------------------------------------------------------------------------------
FUNCTION fn_genbatchtxprocess
      RETURN CLOB --VARCHAR2
   IS
      l_source_proc   CLOB;--VARCHAR2 (32000);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genbatchtxprocess');
      l_source_proc   :=
         'FUNCTION fn_BatchTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;'
         || CHR (10)
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_BatchTxProcess'');'
         || CHR (10)
         || '   IF fn_txAppCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '        RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   IF fn_txAppUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '        RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '  /* IF fn_txAutoPostmap(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '        RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF; */'
         || CHR (10)
         || '   IF p_txmsg.deltd <> ''Y'' THEN -- Normal transaction'
         || CHR (10)
         || '       pr_txlog(p_txmsg, p_err_code);'
         || CHR (10)
         || '   ELSE    -- Delete transaction'
         || CHR (10)
         || '       txpks_txlog.pr_txdellog(p_txmsg,p_err_code);'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_BatchTxProcess'');'
         || CHR (10)
         || '   RETURN l_return_code;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || '   WHEN errnums.E_BIZ_RULE_INVALID'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      FOR I IN ('
         || CHR (10)
         || '           SELECT ERRDESC,EN_ERRDESC FROM deferror'
         || CHR (10)
         || '           WHERE ERRNUM= p_err_code'
         || CHR (10)
         || '      ) LOOP '
         || CHR (10)
         || '           p_err_param := i.errdesc;'
         || CHR (10)
         || '      END LOOP;'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_BatchTxProcess'');'
         || CHR (10)
         || '      RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      p_err_param := ''SYSTEM_ERROR'';'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_BatchTxProcess'');'
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_BatchTxProcess;';
      plog.setbeginsection (pkgctx, 'fn_genBatchTxProcess');
      RETURN l_source_proc;
   END fn_genBatchTxProcess;



-----------------------------------------------------------------------------------
FUNCTION fn_gentxrevert(p_tltxcd varchar2)
      RETURN VARCHAR2
   IS
      l_source_proc   VARCHAR2 (32000);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_gentxrevert');
      l_source_proc   :=
         'FUNCTION fn_txrevert(p_txnum varchar2 ,p_txdate varchar2,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   l_txmsg               tx.msg_rectype;'
         || CHR (10)
         || '   l_err_param           varchar2(300);'
         || CHR (10)
         || '   l_tllog               tx.tllog_rectype;'
         || CHR (10)
         || '   l_fldname             varchar2(100);'
         || CHR (10)
         || '   l_defname             varchar2(100);'
         || CHR (10)
         || '   l_fldtype             char(1);'
         || CHR (10)
         || '   l_return              number(20,0);'
         || CHR (10)
         || '   pv_refcursor            pkg_report.ref_cursor;'
         || CHR (10)
         || '   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '   OPEN pv_refcursor FOR'
         || CHR (10)
         || '   select * from tllog'
         || CHR (10)
         || '   where txnum=p_txnum and txdate=to_date(p_txdate,systemnums.c_date_format);'
         || CHR (10)
         || '   LOOP'
         || CHR (10)
         || '       FETCH pv_refcursor'
         || CHR (10)
         || '       INTO l_tllog;'
         || CHR (10)
         || '       EXIT WHEN pv_refcursor%NOTFOUND;'
         || CHR (10)
         || '       if l_tllog.deltd=''Y'' then'
         || CHR (10)
         || '           p_err_code:=errnums.C_SA_CANNOT_DELETETRANSACTION;'
         || CHR (10)
         || '           plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '           RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '       end if;'
         || CHR (10)
         || '       l_txmsg.msgtype:=''T'';'
         || CHR (10)
         || '       l_txmsg.local:=''N'';'
         || CHR (10)
         || '       l_txmsg.tlid        := l_tllog.tlid;'
         || CHR (10)
         || '       l_txmsg.off_line    := l_tllog.off_line;'
         || CHR (10)
         || '       l_txmsg.deltd       := txnums.C_DELTD_TXDELETED;'
         || CHR (10)
         || '       l_txmsg.txstatus    := txstatusnums.c_txcompleted;'
         || CHR (10)
         || '       l_txmsg.msgsts      := ''0'';'
         || CHR (10)
         || '       l_txmsg.ovrsts      := ''0'';'
         || CHR (10)
         || '       l_txmsg.batchname   := ''DEL'';'
         || CHR (10)
         || '       l_txmsg.txdate:=to_date(l_tllog.txdate,systemnums.c_date_format);'
         || CHR (10)
         || '       l_txmsg.busdate:=to_date(l_tllog.busdate,systemnums.c_date_format);'
         || CHR (10)
         || '       l_txmsg.txnum:=l_tllog.txnum;'
         || CHR (10)
         || '       l_txmsg.tltxcd:=l_tllog.tltxcd;'
         || CHR (10)
         || '       l_txmsg.brid:=l_tllog.brid;'
         || CHR (10)
         || '       for rec in'
         || CHR (10)
         || '       ('
         || CHR (10)
         || '           select * from tllogfld'
         || CHR (10)
         || '           where txnum=p_txnum and txdate=to_date(p_txdate,systemnums.c_date_format)'
         || CHR (10)
         || '       )'
         || CHR (10)
         || '       loop'
         || CHR (10)
         || '       begin'
         || CHR (10)
         || '           select fldname, defname, fldtype'
         || CHR (10)
         || '           into l_fldname, l_defname, l_fldtype'
         || CHR (10)
         || '           from fldmaster'
         || CHR (10)
         || '           where objname=l_tllog.tltxcd and FLDNAME=rec.FLDCD;'
         || CHR (10)
         || CHR (10)
         || '           l_txmsg.txfields (l_fldname).defname   := l_defname;'
         || CHR (10)
         || '           l_txmsg.txfields (l_fldname).TYPE      := l_fldtype;'
         || CHR (10)
         || CHR (10)
         || '           if l_fldtype=''C'' then'
         || CHR (10)
         || '               l_txmsg.txfields (l_fldname).VALUE     := rec.CVALUE;'
         || CHR (10)
         || '           elsif   l_fldtype=''N'' then'
         || CHR (10)
         || '               l_txmsg.txfields (l_fldname).VALUE     := rec.NVALUE;'
         || CHR (10)
         || '           else'
         || CHR (10)
         || '               l_txmsg.txfields (l_fldname).VALUE     := rec.CVALUE;'
         || CHR (10)
         || '           end if;'
         || CHR (10)
         || '           plog.debug (pkgctx,''field: '' || l_fldname || '' value:'' || to_char(l_txmsg.txfields (l_fldname).VALUE));'
         || CHR (10)
         || '       exception when others then'
         || CHR (10)
         || '           l_err_param:=0;'
         || CHR (10)
         || '       end;'
         || CHR (10)
         || '       end loop;'
         || CHR (10)
         || '       IF txpks_#'|| p_tltxcd ||'.fn_AutoTxProcess (l_txmsg,'
         || CHR (10)
         || '                                        p_err_code,'
         || CHR (10)
         || '                                        p_err_param'
         || CHR (10)
         || '          ) <> systemnums.c_success'
         || CHR (10)
         || '       THEN'
         || CHR (10)
         || '           plog.debug (pkgctx,'
         || CHR (10)
         || '           ''got error ' || p_tltxcd || ': '' || p_err_code'
         || CHR (10)
         || '           );'
         || CHR (10)
         || '           ROLLBACK;'
         || CHR (10)
         || '           plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '           RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '       END IF;'
         || CHR (10)
         || '       p_err_code:=0;'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '       return 0;'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '       p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;'
         || CHR (10)
         || '       RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '   END LOOP;'
         || CHR (10)
         || '   p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '   RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '   RETURN l_return_code;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || '   WHEN errnums.E_BIZ_RULE_INVALID'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      FOR I IN ('
         || CHR (10)
         || '           SELECT ERRDESC,EN_ERRDESC FROM deferror'
         || CHR (10)
         || '           WHERE ERRNUM= p_err_code'
         || CHR (10)
         || '      ) LOOP '
         || CHR (10)
         || '           p_err_param := i.errdesc;'
         || CHR (10)
         || '      END LOOP;'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '      RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      p_err_param := ''SYSTEM_ERROR'';'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txrevert'');'
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txrevert;';
      plog.setbeginsection (pkgctx, 'fn_gentxrevert');
      RETURN l_source_proc;
   END fn_gentxrevert;

FUNCTION fn_genBankRequest(p_tltxcd varchar2)
      RETURN VARCHAR2
   IS
      l_source_proc   VARCHAR2 (32000);
      v_refdorc char(1);
      v_refunhold char(1);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genBankRequest');
      l_source_proc   :=
         'FUNCTION fn_GenBankRequest(p_txmsg in tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   TYPE v_CurTyp  IS REF CURSOR;'
         || CHR (10)
         || '    c0        v_CurTyp;'
         || CHR (10)
         || '   v_blnREVERSAL boolean;'
         || CHR (10)
         || '   l_lngErrCode    number(20,0);'
         || CHR (10)
         || '   v_strOBJTYPE    varchar2(100);'
         || CHR (10)
         || '   v_strTRFCODE    varchar2(100);'
         || CHR (10)
         || '   v_strBANK    varchar2(200);'
         || CHR (10)
         || '   v_strAMTEXP    varchar2(200);'
         || CHR (10)
         || '   v_strAFACCTNO    varchar2(100);'
         || CHR (10)
         || '   v_strREFCODE    varchar2(100);'
         || CHR (10)
         || '   v_strBANKACCT    varchar2(100);'
         || CHR (10)
         || '   v_strFLDAFFECTDATE    varchar2(100);'
         || CHR (10)
         || '   v_strAFFECTDATE    varchar2(100);'
         || CHR (10)
         || '   v_strNOTES    varchar2(1000);'
         || CHR (10)
         || '   v_strVALUE     varchar2(1000);'
         || CHR (10)
         || '   v_strFLDNAME     varchar2(100);'
         || CHR (10)
         || '   v_strFLDTYPE     varchar2(100);'
         || CHR (10)
         || '   v_strREFAUTOID     number;'
         || CHR (10)
         || '   v_strSQL     varchar2(4000);'
         || CHR (10)
         || '   v_strStatus char(1);'
         || CHR (10)
         || '   v_strCOREBANK    char(1);'
         || CHR (10)
         || '   v_strafbankname varchar(100);'
         || CHR (10)
         || '   v_strafbankacctno    varchar2(100);'
         || CHR (10)
         || '   v_refdorc char(1);'
         || CHR (10)
         || '   v_refunhold char(1);'
         || CHR (10)
         || '   v_lngREQID number;'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '       plog.setbeginsection (pkgctx, ''fn_genBankRequest'');'
         || CHR (10)
         || '       plog.debug (pkgctx, ''<<BEGIN OF fn_GenBankRequest'');'
         || CHR (10)
         || '       v_blnREVERSAL:=case when p_txmsg.deltd =''Y'' then true else false end;'
         || CHR (10)
         || '       l_lngErrCode:=0;';



    for rec in(
        SELECT OBJTYPE, OBJNAME, TRFCODE, FLDBANK, FLDACCTNO, FLDBANKACCT, FLDREFCODE,AFFECTDATE, FLDNOTES, AMTEXP,SUBCOREBANK
             FROM CRBTXMAP MST WHERE MST.OBJTYPE = 'T' AND MST.OBJNAME = p_tltxcd
    )
    loop
        l_source_proc:=l_source_proc ||  CHR (10)
         || '       if not v_blnREVERSAL then'
         || CHR (10)
         || '           v_strAFACCTNO:=' || pr_parse_amtexp(rec.FLDACCTNO) || ';'
         || CHR (10)
         || '           --Kiem tra neu la TK corebank thi tiep tuc'
         || CHR (10)
         || '           select ' || case when rec.SUBCOREBANK='Y' then '(case when corebank =''Y'' then corebank else alternateacct end) corebank' else 'corebank' end || ',bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;'
         || CHR (10)
         || '           if v_strCOREBANK =''N'' then'
         || CHR (10)
         || '               return l_lngErrCode;'
         || CHR (10)
         || '           end if;'
         || CHR (10)
         || '           --Begin Gen yeu cau sang ngan hang ' || rec.OBJNAME || '-' || rec.TRFCODE
         || CHR (10)
         || '           v_strOBJTYPE:=''' || rec.OBJTYPE || ''';';


        if rec.FLDREFCODE is null or length(rec.FLDREFCODE)=0 then
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strREFCODE:= to_char(p_txmsg.txdate,''DD/MM/RRRR'') || p_txmsg.txnum;';
        else
        l_source_proc:=l_source_proc ||  CHR (10)
         || '           v_strREFCODE:=' || pr_parse_amtexp(rec.FLDREFCODE) || ';';
        end if;

        if rec.AFFECTDATE is null or length(rec.AFFECTDATE)=0 or rec.AFFECTDATE='<$TXDATE>' then
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strAFFECTDATE:= to_char(p_txmsg.txdate,''DD/MM/RRRR'');';
        else
        l_source_proc:=l_source_proc ||  CHR (10)
         || '           v_strAFFECTDATE:=' || pr_parse_amtexp(rec.AFFECTDATE) || ';';
        end if;

        if substr(rec.TRFCODE,1,1) ='$' then
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strTRFCODE:=' || pr_parse_amtexp(rec.TRFCODE) || ';';
        else
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strTRFCODE:=''' || rec.TRFCODE || '''; ';
        end if;
        if rec.FLDBANK is null or length(rec.FLDBANK)=0 then
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strBANK:=v_strafbankname;';
        else
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strBANK:=' || pr_parse_amtexp(rec.FLDBANK) || ';';
        end if;
        if substr(rec.FLDBANK,1,1) = '#' then
        l_source_proc:=l_source_proc || CHR (10)
         || '           SELECT FN_CRB_GETBANKCODEBYTRFCODE(v_strTRFCODE,v_strBANK) BANKCODE into v_strBANK FROM DUAL;';
        end if;
        if rec.FLDBANKACCT is null or length(rec.FLDBANKACCT)=0 then
        l_source_proc:=l_source_proc || CHR (10)
         || '           v_strBANKACCT:=v_strafbankacctno;';
        else
         l_source_proc:=l_source_proc || CHR (10)
         || '           v_strBANKACCT:=' || pr_parse_amtexp(rec.FLDBANKACCT) || ';';
        end if;
         l_source_proc:=l_source_proc || CHR (10)
         || '           v_strNOTES:=' || pr_parse_amtexp(rec.FLDNOTES) || ';';
         l_source_proc:=l_source_proc || CHR (10)
         || '           v_strVALUE:=' || pr_parse_amtexp(rec.AMTEXP) || ';';

         l_source_proc:=l_source_proc || CHR (10)
         || '           if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE > 0 then'
         || CHR (10)
         || '               --Ghi nhan vao CRBTXREQ'
         || CHR (10)
         || '               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;'
         || CHR (10)
         || '               INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)'
         || CHR (10)
         || '                   VALUES (v_strREFAUTOID, ''T'', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, ''dd/mm/rrrr''), TO_DATE(v_strAFFECTDATE , ''dd/mm/rrrr''),'
         || CHR (10)
         || '                           v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, ''P'', NULL,v_strNOTES);'  ;


         if substr(rec.TRFCODE,1,1) ='$' then
             l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               select max(refdorc), max(refunhold) into v_refdorc, v_refunhold from crbdefacct where trfcode = v_strTRFCODE;'
             || CHR (10)
             || '               if v_refdorc = ''D'' then'
             || CHR (10)
             || '                   --Dr Balance transfer amount'
             || CHR (10)
             || '                   update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
             || CHR (10)
             || '                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,''0011'',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,''' || ''');'
             || CHR (10)
             || '               elsif  v_refdorc = ''C'' and v_refunhold =''Y'' then'
             || CHR (10)
             || '                   --Dr HoldBalance transfer amount'
             || CHR (10)
             || '                   update cimast set holdbalance = holdbalance - v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
             || CHR (10)
             || '                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,''0051'',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,''' || ''');'
             || CHR (10)
             || '               elsif  v_refdorc = ''C'' and v_refunhold =''N'' then'
             || CHR (10)
             || '                   --Dr HoldBalance transfer amount'
             || CHR (10)
             || '                   update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '                   INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
             || CHR (10)
             || '                   VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,''0012'',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,''' || ''');'
             || CHR (10)
             || '               end if;';
         else
             select max(refdorc), max(refunhold) into v_refdorc,  v_refunhold from crbdefacct where trfcode = rec.TRFCODE;
             if v_refdorc = 'D' then
                l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               --Dr Balance transfer amount'
             || CHR (10)
             || '               update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '               INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
             || CHR (10)
             || '               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,''0011'',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,''' || ''');';

             elsif  v_refdorc = 'C' and v_refunhold ='Y' then
                l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               --Dr HoldBalance transfer amount'
             || CHR (10)
             || '               update cimast set holdbalance = holdbalance - v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '               INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
             || CHR (10)
             || '               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,''0051'',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,''' || ''');';

             elsif  v_refdorc = 'C' and v_refunhold ='N' then
                l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               --Dr HoldBalance transfer amount'
             || CHR (10)
             || '               update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '               INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
             || CHR (10)
             || '               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_strAFACCTNO,''0012'',v_strVALUE,NULL,v_strREFAUTOID,p_txmsg.deltd,v_strVALUE,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,''' || ''');';

             end if;
         end if;


         for rec1 in (
            SELECT OBJTYPE, OBJNAME, TRFCODE, FLDNAME, FLDTYPE, AMTEXP, CMDSQL
                   FROM CRBTXMAPEXT MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND TRFCODE=rec.TRFCODE
         )
         loop
         l_source_proc:=l_source_proc || CHR (10)
         || CHR (10)
         || '               --Gen detail request to bank' || rec1.FLDNAME
         || CHR (10)
         || '               v_strFLDNAME:=''' || rec1.FLDNAME || ''';'
         || CHR (10)
         || '               v_strFLDTYPE:=''' || rec1.FLDTYPE || ''';'
         || CHR (10)
         || '               v_strAMTEXP:=''' || rec1.AMTEXP || ''';'
         || CHR (10)
         || '               v_strSQL:=''' || replace(rec1.CMDSQL,'''','''''') || ''';';

         if length(rec1.AMTEXP) >0 then
            If substr(rec1.AMTEXP,1,1) ='@' Then
         l_source_proc:=l_source_proc || CHR (10)
         || '               v_strVALUE := substr(v_strAMTEXP, 2);'
         || CHR (10);
            elsIf substr(rec1.AMTEXP,1,1) ='$' Then
         l_source_proc:=l_source_proc || CHR (10)
         || '               v_strVALUE := substr(v_strAMTEXP, 2);'
         || CHR (10)
         || '               v_strVALUE := p_txmsg.txfields(v_strVALUE).value;'
         || CHR (10);
            elsIf rec1.AMTEXP = '<$BUSDATE>' Then
         l_source_proc:=l_source_proc || CHR (10)
         || '               v_strVALUE := to_char(p_txmsg.txdate,''DD/MM/RRRR'');'
         || CHR (10);
            elsIf Length(rec1.AMTEXP) > 0 Then
         l_source_proc:=l_source_proc || CHR (10)
         || '               v_strVALUE := ' || pr_parse_amtexp(rec1.amtexp) || ';'
         || CHR (10);
            end if;
         end if;

         if length(rec1.CMDSQL) >0 then
         l_source_proc:=l_source_proc || CHR (10)
         || CHR (10)
         || '               v_strSQL:= replace(v_strSQL,''<$FILTERID>'', v_strVALUE);'
         || CHR (10)

         || '               Begin'
         || CHR (10)
         || '                   OPEN c0 FOR v_strSQL;'
         || CHR (10)
         || '                   FETCH c0 INTO v_strVALUE;'
         || CHR (10)
         || '                   CLOSE c0;'
         || CHR (10)
         || '               EXCEPTION'
         || CHR (10)
         || '                   WHEN OTHERS THEN'
         || CHR (10)
         || '                       v_strVALUE:=''0'';'
         || CHR (10)
         || '                       plog.error(pkgctx,''Khong lay duoc gia tri tren cau lenh select dong : SQL-'' || v_strSQL);'
         || CHR (10)
         || '               END;';
         end if;
         l_source_proc:=l_source_proc || CHR (10)
         || '               INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)'
         || CHR (10)
         || '               select SEQ_CRBTXREQDTL.NEXTVAL,v_strREFAUTOID,v_strFLDNAME,'
         || CHR (10)
         || '                   case when v_strFLDTYPE=''N'' then '''' else to_char(v_strVALUE) end,'
         || CHR (10)
         || '                   case when v_strFLDTYPE<>''N'' then 0 else to_number(v_strVALUE) end '
         || CHR (10)
         || '                   from dual;'
         || CHR (10);
         end loop;

         l_source_proc:=l_source_proc || CHR (10)
         || '           End if;'  ;

         l_source_proc:=l_source_proc || CHR (10)
         || '       else'  ; --Cho revert

         if substr(rec.TRFCODE,1,1) ='$' then
         l_source_proc:=l_source_proc || CHR (10)
         || '           v_strTRFCODE:=' || pr_parse_amtexp(rec.TRFCODE) || ';';
         else
         l_source_proc:=l_source_proc || CHR (10)
         || '           v_strTRFCODE:=''' || rec.TRFCODE || '''; ';
         end if;
         l_source_proc:=l_source_proc || CHR (10)
         || '           v_strAFACCTNO:=' || pr_parse_amtexp(rec.FLDACCTNO) || ';'
         || CHR (10)
         || '           v_strVALUE:=' || pr_parse_amtexp(rec.AMTEXP) || ';'
         || CHR (10)
         || '           begin '
         || CHR (10)
         || '               SELECT STATUS,REQID into v_strStatus,v_lngREQID FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, ''DD/MM/RRRR'') and trfcode =v_strTRFCODE;'
         || CHR (10)
         || '               if  v_strStatus in (''P'',''D'') then'
         || CHR (10)
         || '                   update CRBTXREQ set status =''D'' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, ''DD/MM/RRRR'');';


         l_source_proc:=l_source_proc || CHR (10)
         || CHR (10)
         || '               else'
         || CHR (10)
         || '                   begin '
         || CHR (10)
         || '                       select mst.status into v_strStatus from crbtrflog mst, crbtrflogdtl dtl where refreqid = v_lngREQID'
         || CHR (10)
         || '                            and mst.refbank=dtl.bankcode and mst.trfcode=dtl.trfcode and mst.txdate=dtl.txdate '
         || CHR (10)
         || '                            and mst.version=dtl.version and mst.status not in  (''D'',''B'');'
         || CHR (10)
         || '                   exception when others then'
         || CHR (10)
         || '                       v_strStatus :=''X'';  '
         || CHR (10)
         || '                   end;'
         || CHR (10)
         || '                   if  v_strStatus =''P'' then'
         || CHR (10)
         || '                        p_err_code:=-670101;--Trang thai bang ke khong hop le'
         || CHR (10)
         || '                        plog.error (pkgctx, ''Error code:'' || p_err_code);'
         || CHR (10)
         || '                        plog.setendsection (pkgctx, ''fn_txAppUpdate'');'
         || CHR (10)
         || '                        Return errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '                   end if;'
         || CHR (10)
         || '               end if;  ';
         if substr(rec.TRFCODE,1,1) ='$' then
             l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               select max(refdorc), max(refunhold) into v_refdorc, v_refunhold from crbdefacct where trfcode = v_strTRFCODE;'
             || CHR (10)
             || '               if v_refdorc = ''D'' then'
             || CHR (10)
             || '                   --Revert Dr Balance transfer amount'
             || CHR (10)
             || '                   update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '               elsif  v_refdorc = ''C'' and v_refunhold =''Y'' then'
             || CHR (10)
             || '                   --Revert Dr HoldBalance transfer amount'
             || CHR (10)
             || '                   update cimast set holdbalance = holdbalance + v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '               elsif  v_refdorc = ''C'' and v_refunhold =''N'' then'
             || CHR (10)
             || '                   --Revert Cr Balance transfer amount'
             || CHR (10)
             || '                   update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;'
             || CHR (10)
             || '               end if;';

         else
             select max(refdorc), max(refunhold) into v_refdorc, v_refunhold from crbdefacct where trfcode = rec.TRFCODE;
             if v_refdorc = 'D' then
                l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               --Revert Dr Balance transfer amount'
             || CHR (10)
             || '               update cimast set balance = balance + v_strVALUE where acctno = v_strAFACCTNO;';


             elsif  v_refdorc = 'C' and v_refunhold ='Y' then
                l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               --Revert Dr HoldBalance transfer amount'
             || CHR (10)
             || '               update cimast set holdbalance = holdbalance + v_strVALUE where acctno = v_strAFACCTNO;';

             elsif  v_refdorc = 'C' and v_refunhold ='N' then
                l_source_proc:=l_source_proc || CHR (10)
             || CHR (10)
             || '               --Revert Cr Balance transfer amount'
             || CHR (10)
             || '               update cimast set balance = balance - v_strVALUE where acctno = v_strAFACCTNO;';

             end if;
         end if;
         l_source_proc:=l_source_proc || CHR (10)
         || '           exception when others then'
         || CHR (10)
         || '               null; --Khong co bang ke can xoa'
         || CHR (10)
         || '           end;'
         || CHR (10)
         || '       End if;'  ;



    end loop;
    for rec in(
        SELECT OBJTYPE, OBJNAME, TRFCODE, FLDBANK, FLDACCTNO, FLDBANKACCT, FLDREFCODE,AFFECTDATE, FLDNOTES, AMTEXP,SUBCOREBANK, AUTOGENRPT,GRPTRFCODE
             FROM CRBTXMAP MST WHERE MST.OBJTYPE = 'T' AND MST.OBJNAME = p_tltxcd
    )
    loop
        if  rec.GRPTRFCODE is not null then
 l_source_proc:=l_source_proc || CHR (10)
         || '   --Group bang ke'
         || CHR (10)
         || '   update crbtxreq set grpreqid= (select nvl(max(reqid),'''') from crbtxreq where objkey = p_txmsg.txnum and txdate =  TO_DATE(p_txmsg.txdate, ''dd/mm/rrrr'') and trfcode = ''' || rec.GRPTRFCODE || ''') '
         || CHR (10)
         || '   where objkey = p_txmsg.txnum and txdate =  TO_DATE(p_txmsg.txdate, ''dd/mm/rrrr'') and trfcode = ''' || rec.TRFCODE || ''';';

        end if;
        if rec.AUTOGENRPT ='Y' then
 l_source_proc:=l_source_proc || CHR (10)
         || '   ----Auto Gen request'
         || CHR (10)
         || '   cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, ''dd/mm/rrrr''), p_txmsg.txnum,p_err_code, p_txmsg.tlid);';

        end if;
    end loop;
 l_source_proc:=l_source_proc || CHR (10)
         || '   plog.debug (pkgctx, ''<<END OF fn_GenBankRequest'');'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_GenBankRequest'');'
         || CHR (10)
         || '   RETURN l_lngErrCode;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_GenBankRequest'');'
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_genBankRequest;';
      plog.setbeginsection (pkgctx, 'fn_genBankRequest');

/*insert into tbl_txpks(datetime,tltxcd,postmap)
      values (to_char(sysdate),p_tltxcd,l_source_proc);*/

      RETURN l_source_proc;
END fn_genBankRequest;

FUNCTION fn_genautopostmap (p_tltxcd varchar2,p_ibt varchar2)
      RETURN CLOB
   IS
      --l_source_proc      VARCHAR2 (32000);
      l_source_proc      clob;
      l_txnormal         clob;
   BEGIN
    plog.setbeginsection (pkgctx, 'fn_genautopostmap');

    --plog.debug (pkgctx,'Begin to gen postmap');
      l_source_proc      :=
            'Function fn_txAutoPostmap  (p_txmsg in tx.msg_rectype,p_err_code in out varchar2) RETURN  NUMBER '
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'EntrySUBTXNO varchar2(30);'
         || CHR (10)
         || 'EntryDORC    varchar2(30);'
         || CHR (10)
         || 'EntryCCYCD varchar2(30);'
         || CHR (10)
         || 'EntryDEC varchar2(30);'
         || CHR (10)
         || 'EntryDEC varchar2(30);'
         || CHR (10)
         || 'EntryGLGRP varchar2(30);'
         || CHR (10)
         || 'EntryBRID varchar2(30);'
         || CHR (10)
         || 'EntryAMOUNT varchar2(30);'
         || CHR (10)
         || 'EntryACCTNO  varchar2(30);'
         || CHR (10)
         || 'EntryCUSTID  varchar2(30);'
         || CHR (10)
         || 'EntryCUSTNAME varchar2(250);'
         || CHR (10)
         || 'EntryTASKCD  varchar2(50);'
         || CHR (10)
         || 'EntryDEPTCD  varchar2(50);'
         || CHR (10)
         || 'EntryMICD  varchar2(50);'
         || CHR (10)
         || 'v_sectype     varchar2(3);'
         || CHR (10)
         || 'v_strGLGRP varchar2(4);'
         || CHR (10)
         || 'v_strTRADEPLACE varchar2(3);'
         || CHR (10)
         || 'v_strSECTYPE varchar2(5);'
         || CHR (10)
         || 'v_strCATYPE varchar2(10);'
         || CHR (10)
         || 'v_strACCTNO varchar2(40);'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txAutoPostmap'');';
         --plog.debug (pkgctx,'Begin to loop1');
           for rec in
                (SELECT * FROM
                   (SELECT POSTMAP.*, REF.GLACCTNO ACCTNO, REF.FEECD FROM POSTMAP, FEEMASTER REF, FEEMAP WHERE POSTMAP.ACNAME='FEEMAST'
                     AND POSTMAP.TLTXCD=FEEMAP.TLTXCD AND FEEMAP.FEECD=REF.FEECD
                     AND POSTMAP.TLTXCD = p_tltxcd AND POSTMAP.IBT = p_ibt AND POSTMAP.FLDTYPE = 'F'
                     UNION ALL
                     SELECT POSTMAP.*, REF.ACCTNO, NULL FEECD FROM POSTMAP, GLREFCOM REF WHERE POSTMAP.ACNAME = REF.ACNAME AND POSTMAP.ACNAME<>'FEEMAST'
                     AND POSTMAP.TLTXCD = p_tltxcd AND POSTMAP.IBT = p_ibt AND POSTMAP.FLDTYPE = 'F'
                     UNION ALL
                     SELECT POSTMAP.*, NULL ACCTNO, NULL FEECD FROM POSTMAP WHERE 0=0
                     AND POSTMAP.TLTXCD = p_tltxcd AND POSTMAP.IBT = p_ibt AND POSTMAP.FLDTYPE = 'V') MAP
                     ORDER BY SUBTXNO, DORC DESC
                 )
           loop
                --Xu ly cho tung but toan D/C
                l_txnormal:= '   EntryAMOUNT := ' || pr_parse_amtexp (rec.AMTEXP) || ';'
         || CHR (10)
         || '    EntrySUBTXNO := ''' || rec.SUBTXNO || ''';'
         || CHR (10)
         || '    EntryDORC := ''' || rec.DORC || ''';'
         || CHR (10)
         || '    v_strACCTNO := p_txmsg.txfields(''' || rec.ACFLD ||  ''').value;'
         || CHR (10)
         || '    If length(v_strACCTNO) > 4 Then'
         || CHR (10)
         || '       EntryBRID := substr(v_strACCTNO,1,4);'
         || CHR (10)
         || '    else'
         || CHR (10)
         || '       EntryBRID:=v_strACCTNO;'
         || CHR (10)
         || '       EntryCCYCD:=''' || systemnums.C_VND_CCYCD || ''';'
         || CHR (10)
         || '    end if;';
         if length( rec.FLDCUSTID )>0 then
             l_txnormal:= l_txnormal || CHR (10)
         || '    EntryCUSTID := p_txmsg.txfields(''' || rec.FLDCUSTID ||  ''').value;';
         end if;
         if length( rec.FLDCUSTNAME )>0 then
             l_txnormal:= l_txnormal || CHR (10)
         || '    EntryCUSTNAME := p_txmsg.txfields(''' || rec.FLDCUSTNAME ||  ''').value;';
         end if;
         if length( rec.FLDTASKCD )>0 then
             l_txnormal:= l_txnormal || CHR (10)
         || '    EntryTASKCD := p_txmsg.txfields(''' || rec.FLDTASKCD ||  ''').value;';
         end if;
         if length( rec.FLDDEPTCD )>0 then
             l_txnormal:= l_txnormal || CHR (10)
         || '    EntryDEPTCD := p_txmsg.txfields(''' || rec.FLDDEPTCD ||  ''').value;';
         end if;
         if length( rec.FLDMICD )>0 then
             l_txnormal:= l_txnormal || CHR (10)
         || '    EntryMICD := p_txmsg.txfields(''' || rec.FLDMICD ||  ''').value;';
         end if;
         l_txnormal:= l_txnormal || CHR (10)
         || '    EntryACCTNO:= ''' || rec.ACCTNO || ''';';
         If Length(rec.ACCTNO) = 0 or rec.ACCTNO is null Then
                    If substr(rec.ACNAME ,length(rec.ACNAME )-1, 2) = 'CA' Then
                        l_txnormal:= l_txnormal || CHR (10)
         || '   SELECT CATYPE into v_strCATYPE from camast where camastid = v_strACCTNO;';
                    end if;

         If rec.acname = 'CINETMARKET' Or rec.acname = 'CINETMARKETRM'
                        Or rec.acname = 'CINETCLR' Or rec.acname = 'CINETCLRRM'
                        Or rec.acname = 'CIINVEST' Or rec.acname = 'CIINVESTRM'
                        Or rec.acname = 'CIINVESTRE' Or rec.acname = 'SEINVEBOCA' Then
                l_txnormal:= l_txnormal || CHR (10)
         || '    SELECT SBSECURITIES.SECTYPE, SBSECURITIES.TRADEPLACE, TYP.GLGRP'
         || CHR (10)
         || '        into v_strSECTYPE,v_strTRADEPLACE,v_strGLGRP'
         || CHR (10)
         || '    FROM SBSECURITIES, SETYPE TYP, SEMAST MST'
         || CHR (10)
         || '    WHERE MST.CODEID=SBSECURITIES.CODEID AND TYP.ACTYPE = MST.ACTYPE AND MST.ACCTNO = v_strACCTNO;'
         || CHR (10)
         || '    if to_number(v_strTRADEPLACE)>3 then'
         || CHR (10)
         || '        v_strTRADEPLACE:=3;'
         || CHR (10)
         || '    else'
         || CHR (10)
         || '       v_strTRADEPLACE:=to_char(to_number(v_strTRADEPLACE));'
         || CHR (10)
         || '    end if;'
         || CHR (10)
         || '    if v_strSECTYPE in (''001'',''002'') then'
         || CHR (10)
         || '        v_strSECTYPE := ''1'';'
         || CHR (10)
         || '    elsif v_strSECTYPE in (''003'',''006'') then'
         || CHR (10)
         || '        v_strSECTYPE := ''2'';'
         || CHR (10)
         || '    Else'
         || CHR (10)
         || '        v_strSECTYPE := ''3'';'
         || CHR (10)
         || '    end if;';
         else
                        If substr(rec.ACNAME,1, 2) = 'SE' Then
                             l_txnormal:= l_txnormal || CHR (10)
         || '    SELECT SBSECURITIES.SECTYPE, SBSECURITIES.TRADEPLACE, TYP.GLGRP'
         || CHR (10)
         || '        into v_strSECTYPE,v_strTRADEPLACE,v_strGLGRP'
         || CHR (10)
         || '    FROM SBSECURITIES, SETYPE TYP, SEMAST MST'
         || CHR (10)
         || '    WHERE MST.CODEID=SBSECURITIES.CODEID AND TYP.ACTYPE = MST.ACTYPE AND MST.ACCTNO = v_strACCTNO;'
         || CHR (10)
         || '    if to_number(v_strTRADEPLACE)>3 then'
         || CHR (10)
         || '        v_strTRADEPLACE:=3;'
         || CHR (10)
         || '     else'
         || CHR (10)
         || '         v_strTRADEPLACE:=to_char(to_number(v_strTRADEPLACE));'
         || CHR (10)
         || '     end if;'
         || CHR (10)
         || '     if v_strSECTYPE in (''001'',''002'') then'
         || CHR (10)
         || '         v_strSECTYPE := ''1'';'
         || CHR (10)
         || '     elsif v_strSECTYPE in (''003'',''006'') then'
         || CHR (10)
         || '         v_strSECTYPE := ''2'';'
         || CHR (10)
         || '     Else'
         || CHR (10)
         || '         v_strSECTYPE := ''3'';'
         || CHR (10)
         || '     end if;';
                        else
                            l_txnormal:= l_txnormal || CHR (10)
         || '     SELECT TYP.GLGRP into v_strGLGRP FROM CITYPE TYP, CIMAST MST'
         || CHR (10)
         || '     WHERE TYP.ACTYPE = MST.ACTYPE AND MST.ACCTNO =v_strACCTNO;';
                       end if;
         end if;
         l_txnormal:= l_txnormal || CHR (10)
         || '     EntryGLGRP := v_strGLGRP;'
         || CHR (10)
         || '     EntryACCTNO := substr(''' || rec.ACNAME || ''',1, 2) || v_strGLGRP || ''' || rec.acname || ''';'
         || CHR (10)
         || '     If length(EntryACCTNO) > 0 Then';
                       If substr(rec.ACNAME ,length(rec.ACNAME )-1, 2) = 'CA' Then
                           l_txnormal:= l_txnormal || CHR (10)
         || '         SELECT ACCTNO into EntryACCTNO FROM GLREF WHERE APPTYPE=substr(''' || rec.ACNAME || ''',1, 2) AND GLGRP=v_strGLGRP AND SUBSTR(ACNAME,4) = ''' || rec.acname || ''' AND SUBSTR(ACNAME ,1,3) = v_strCATYPE;';
                        Else
                        l_txnormal:= l_txnormal || CHR (10)
         || '         SELECT ACCTNO into EntryACCTNO FROM GLREF WHERE APPTYPE=substr(''' || rec.ACNAME || ''',1, 2) AND GLGRP=v_strGLGRP AND ACNAME=''' || rec.acname || ''';';
                        End If;
                l_txnormal:= l_txnormal || CHR (10)
         || '     end if;';
         end if;
         l_txnormal:= l_txnormal || CHR (10)
         || '     If p_txmsg.BRID <> systemnums.C_HO_BRID Then'
         || CHR (10)
         || '         EntryACCTNO := Replace(EntryACCTNO, ''____'', p_txmsg.BRID);   --BRID Lay theo chi nhanh'
         || CHR (10)
         || '     else'
         || CHR (10)
         || '         EntryACCTNO := Replace(EntryACCTNO, ''____'', EntryBRID);   --BRID Lay theo tai khoan'
         || CHR (10)
         || '     end if;'
         || CHR (10)
         || '     EntryACCTNO := Replace(EntryACCTNO, ''####'', EntryBRID);   --BRID Lay theo tai khoan'
         || CHR (10)
         || '     EntryACCTNO := Replace(EntryACCTNO, ''**'', EntryCCYCD);'
         || CHR (10)
         || '     EntryACCTNO := Replace(EntryACCTNO, ''^^'', EntryCCYCD);'
         || CHR (10)
         || '     EntryACCTNO := Replace(EntryACCTNO, ''@'', v_strTRADEPLACE);'
         || CHR (10)
         || '     EntryACCTNO := Replace(EntryACCTNO, ''$'', v_strSECTYPE);';
                If rec.acname = 'GLMAST' Then
                    l_txnormal:= l_txnormal || CHR (10)
         || '     EntryACCTNO := p_txmsg.txfields(''' || rec.ACFLD ||  ''').value;';
                end if;
                If rec.acname = 'CASH' Then
                    l_txnormal:= l_txnormal || CHR (10)
         || '     If EntryCCYCD = ''00'' Then'
         || CHR (10)
         || '        EntryACCTNO := Replace(EntryACCTNO, ''$'', ''1'');'
         || CHR (10)
         || '     Else'
         || CHR (10)
         || '       --Foreign currency'
         || CHR (10)
         || '         EntryACCTNO := Replace(EntryACCTNO, ''$'', ''3'');'
         || CHR (10)
         || '     End If;'
         || CHR (10)
         || '     If substr(EntryACCTNO,length(EntryACCTNO)-3, 4) = ''0000'' Then'
         || CHR (10)
         || '       --For HeadOffice'
         || CHR (10)
         || '         EntryACCTNO := Replace(EntryACCTNO, ''~'', ''1'');'
         || CHR (10)
         || '     Else'
         || CHR (10)
         || '       --For branch'
         || CHR (10)
         || '         EntryACCTNO := Replace(EntryACCTNO, ''~'', ''2'');'
         || CHR (10)
         || '     End If;';
                end if;

                if rec.NEGATIVECD='Z' then    --Reset ve 0'
                    l_txnormal:= l_txnormal || CHR (10)
         || CHR (10)
         || '     If to_number(EntryAMOUNT) < 0 Then'
         || CHR (10)
         || '         EntryAMOUNT := ''0'';'
         || CHR (10)
         || '     End If;';
                elsif rec.NEGATIVECD='R' then    --Revert'
                     l_txnormal:= l_txnormal || CHR (10)
         || '     If to_number(EntryAMOUNT) < 0 Then'
         || CHR (10)
         || '         If EntryDORC = ''D'' Then'
         || CHR (10)
         || '             EntryDORC := ''C'';'
         || CHR (10)
         || '         end if;'
         || CHR (10)
         || '         If EntryDORC = ''C'' Then'
         || CHR (10)
         || '             EntryDORC := ''D'';'
         || CHR (10)
         || '         end if;'
         || CHR (10)
         || '         EntryAMOUNT := to_char(-to_number(EntryAMOUNT));'
         || CHR (10)
         || '     End If;';
                end if;
         l_txnormal:= l_txnormal || CHR (10)
         || '   --Tao Mitran'
         || CHR (10)
         || '     If EntryAMOUNT <> 0 And EntryACCTNO > 0 And Length(EntryCUSTID) > 0'
         || CHR (10)
         || '         Or Length(EntryCUSTNAME) > 0 Or Length(EntryTASKCD) > 0 Or Length(EntryDEPTCD) > 0 Or Length(EntryMICD) > 0 Then'
         || CHR (10)
         || '        INSERT INTO MITRAN'
         || CHR (10)
         || '           (AUTOID,TXDATE,TXNUM,SUBTXNO,DORC,ACCTNO,'
         || CHR (10)
         || '            CUSTID,CUSTNAME,TASKCD,DEPTCD,MICD,DESCRIPTION,DELTD)'
         || CHR (10)
         || '        VALUES'
         || CHR (10)
         || '           (SEQ_MITRAN.NEXTVAL,TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,EntrySUBTXNO,EntryDORC,EntryACCTNO,EntryCUSTID,EntryCUSTNAME,EntryTASKCD,EntryDEPTCD,EntryMICD,p_txmsg.Txdesc,''N'');'
         || CHR (10)
         || '     end if;'
         || CHR (10)
         || '     if length(EntryACCTNO)>0 and EntryAMOUNT<>0 then'
         || CHR (10)
         || '       --Tao GLTRAN'
         || CHR (10)
         || '         INSERT INTO GLTRAN (AUTOID,ACCTNO, TXDATE, TXNUM, BKDATE, CCYCD, DORC, SUBTXNO, AMT, DELTD)'
         || CHR (10)
         || '         VALUES'
         || CHR (10)
         || '           (SEQ_GLTRAN.NEXTVAL,EntryACCTNO,TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum ,p_txmsg.busdate,EntryCCYCD,EntryDORC,EntrySUBTXNO,EntryAMOUNT,''N'');'
         || CHR (10)
         || '       --Cap nhat GLMAST'
         || CHR (10)
         || '           If EntryDORC = ''D'' Then'
         || CHR (10)
         || '               UPDATE GLMAST SET LSTDATE=TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), BALANCE=NVL(BALANCE,0)-(EntryAMOUNT),DDR=NVL(DDR,0)+(EntryAMOUNT),MDR=NVL(MDR,0)+(EntryAMOUNT),YDR=NVL(YDR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO;'
         || CHR (10)
         || '           ElsIf EntryDORC = ''C'' Then'
         || CHR (10)
         || '               UPDATE GLMAST SET LSTDATE=TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), BALANCE=NVL(BALANCE,0)+(EntryAMOUNT),DCR=NVL(DCR,0)+(EntryAMOUNT),MCR=NVL(MCR,0)+(EntryAMOUNT),YCR=NVL(YCR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO;'
         || CHR (10)
         || '           End If;'
         || CHR (10)
         || '           If p_txmsg.busdate <> TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) Then'
         || CHR (10)
         || '               INSERT INTO GLHIST (AUTOID,PERIOD,TXDATE,ACCTNO,BALANCE,AVGBAL,YEARBAL,DDR,DCR,MDR,MCR,YDR,YCR)'
         || CHR (10)
         || '                    SELECT SEQ_GLHIST.NEXTVAL,''EOD'',TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) + ID.Id,ACCTNO,0,0,0,0,0,0,0,0,0 FROM GLMAST,'
         || CHR (10)
         || '                   (select rownum Id from glhist where txdate >=TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) and txdate < (select min (txdate) from glhist where acctno=EntryACCTNO)) ID'
         || CHR (10)
         || '                   WHERE ACCTNO=EntryACCTNO;'
         || CHR (10)
         || '               If EntryDORC = ''D'' Then'
         || CHR (10)
         || '                   UPDATE GLHIST SET BALANCE=NVL(BALANCE,0)-(EntryAMOUNT),DDR=NVL(DDR,0)+(EntryAMOUNT),MDR=NVL(MDR,0)+(EntryAMOUNT),YDR=NVL(YDR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO AND TXDATE >= p_txmsg.busdate;'
         || CHR (10)
         || '               ElsIf EntryDORC = ''C'' Then'
         || CHR (10)
         || '                   UPDATE GLHIST SET BALANCE=NVL(BALANCE,0)+(EntryAMOUNT),DCR=NVL(DCR,0)+(EntryAMOUNT),MCR=NVL(MCR,0)+(EntryAMOUNT),YCR=NVL(YCR,0)+(EntryAMOUNT) WHERE ACCTNO=EntryACCTNO AND TXDATE >= p_txmsg.busdate;'
         || CHR (10)
         || '               End If;'
         || CHR (10)
         || '           end if;'
         || CHR (10)
         || '     end if;';
         l_source_proc      :=l_source_proc || CHR (10)  || l_txnormal;
         end loop;

        l_source_proc      :=
            l_source_proc
         || CHR (10)
         || '     plog.setendsection (pkgctx, ''fn_txautopostmap'');'
         || CHR (10)
         || '     RETURN systemnums.C_SUCCESS ;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || '  WHEN others THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txautopostmap'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAutoPostmap;';
        --Insert vao bang tbl_postmap
        insert into tbl_postmap(datetime,tltxcd,postmap)
              values (to_char(sysdate),p_tltxcd,l_source_proc);
        plog.setendsection (pkgctx, 'fn_genautopostmap');
        RETURN l_source_proc;
END fn_genautopostmap;

------------------------------------------------------------------------------------




FUNCTION fn_genprintinfo (p_tltxcd varchar2)
      RETURN CLOB --VARCHAR2
   IS
      l_source_proc   CLOB; --VARCHAR2 (32000);
      l_msgrqr        CHAR (1);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genprintinfo');
      l_source_proc   :=
         l_source_proc || CHR (10)
         || 'PROCEDURE pr_PrintInfo(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   l_sectype  semast.actype%TYPE;'
         || CHR (10)
         || '   l_codeid varchar2(6);'
         || CHR (10)
         || '   l_acctno varchar2(30);'
         || CHR (10)
         || '   l_custid afmast.custid%TYPE;'
         || CHR (10)
         || '   l_afacctno afmast.acctno%TYPE;'
         || CHR (10)
         || '   l_count NUMBER(10):= 0;'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''pr_PrintInfo'');'
         || CHR (10);

      FOR i
      IN (SELECT DISTINCT r.tblname tblname, c.fldkey fldkey, c.acfld acfld, c.isrun isrun
          FROM appchk c, apprules r
          WHERE     TRIM (c.apptype) = TRIM (r.apptype)
                AND TRIM (c.rulecd) = TRIM (r.rulecd)
                AND tltxcd = p_tltxcd and r.tblname not in ('SEWITHDRAW','DFMAST','RPMAST','SBGROUP','SBMAST','CAMAST','CRBTRFLOG','CRBDEFBANK'))
      LOOP
         plog.debug (pkgctx, 'tblname: ' || i.tblname);
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || (case when to_char(pr_parse_amtexp (i.isrun))<> '1' then
                 '    IF to_char(' || pr_parse_amtexp (i.isrun) || ') <> ''0'' THEN '
                 else
                 ''
                 end)
            || CHR (10)
            || '    --<<BEGIN OF PROCESS '
            || i.tblname
            || '>>'
            || CHR (10)
            || '    l_acctno := p_txmsg.txfields('''
            || i.acfld
            || ''').value;'
            || CHR (10)
            || '    SELECT count(*) INTO l_count'
            || CHR (10)
            || '    FROM '
            || i.tblname
            || CHR (10)
            || '    WHERE '
            || i.fldkey
            || '= l_acctno;'
            || CHR (10)
            || CHR (10)
            || '    IF l_count = 0 THEN';

         IF i.tblname = 'SEMAST'
         THEN
            l_source_proc   :=
                  l_source_proc
               || CHR (10)
               || '         l_afacctno := substr(p_txmsg.txfields('''
               || i.acfld
               || ''').value,1,8);'
               || CHR (10)
               || '         l_codeid := substr(p_txmsg.txfields('''
               || i.acfld
               || ''').value,length(p_txmsg.txfields('''
               || i.acfld
               || ''').value)-1, length(p_txmsg.txfields('''
               || i.acfld
               || ''').value));'
               || CHR (10)
               || '         BEGIN'
               || CHR (10)
               || '             SELECT b.setype,a.custid'
               || CHR (10)
               || '             INTO l_sectype,l_custid'
               || CHR (10)
               || '             FROM AFMAST A, aftype B'
               || CHR (10)
               || '             WHERE  A.actype= B.actype'
               || CHR (10)
               || '             AND a.ACCTNO = l_afacctno;'
               || CHR (10)
               || '         EXCEPTION'
               || CHR (10)
               || '             WHEN NO_DATA_FOUND THEN'
               || CHR (10)
               || '             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;'
               || CHR (10)
               || '             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;'
               || CHR (10)
               || '         END;'
               || CHR (10)
               || '         INSERT INTO SEMAST'
               || CHR (10)
               || '         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,'
               || CHR (10)
               || '         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)'
               || CHR (10)
               || '         VALUES('
               || CHR (10)
               || '         l_sectype, l_custid, l_acctno,l_codeid,l_afacctno, '
               || CHR (10)
               || '         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),'
               || CHR (10)
               || '         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),'
               || CHR (10)
               || '         ''A'',''Y'',''000'', 0,0,0,0,0,0,0,0,0);';
         ELSE
            l_source_proc   :=
                  l_source_proc
               || CHR (10)
               || '        p_err_code := errnums.C_PRINTINFO_ACCTNOTFOUND;'
               || CHR (10)
               || '        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;';
         END IF;

         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '    END IF;'
            || CHR (10)
            || '    BEGIN';

         IF i.tblname = 'AFMAST'
         THEN
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '         SELECT A.FULLNAME CUSTNAME, A.ADDRESS, A.IDCODE LICENSE, A.CUSTODYCD,B.BANKACCTNO,l_acctno'
               || CHR (10)
               || '         INTO p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custname,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').address,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').license,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custody,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').bankac,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').value'
               || CHR (10)
               || '         FROM CFMAST A, AFMAST  B '
               || CHR (10)
               || '         WHERE A.CUSTID = B.CUSTID '
               || CHR (10)
               || '         AND B.'
               || i.fldkey
               || '=l_acctno;';
         ELSIF i.tblname = 'LNMAST'
         THEN
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '         SELECT FULLNAME CUSTNAME, CFMAST.ADDRESS, CFMAST.IDCODE LICENSE, CFMAST.CUSTODYCD'
               || CHR (10)
               || '         INTO p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custname,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').address,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').license,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custody'
               || CHR (10)
               || '         FROM CFMAST , AFMAST ,  LNMAST MST'
               || CHR (10)
               || '         WHERE CFMAST.CUSTID = AFMAST.CUSTID'
               || CHR (10)
               || '         AND AFMAST.ACCTNO=MST.TRFACCTNO'
               || CHR (10)
               || '         AND MST.'
               || i.fldkey
               || ' = l_acctno;';
         ELSIF i.tblname IN ('LMMAST', 'CLMAST', 'GRMAST', 'LNAPPL')
         THEN
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '         SELECT FULLNAME CUSTNAME, ADDRESS, IDCODE LICENSE, CUSTODYCD'
               || CHR (10)
               || '         INTO p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custname,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').address,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').license,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custody'
               || CHR (10)
               || '         FROM CFMAST A'
               || CHR (10)
               || '         WHERE EXISTS ('
               || CHR (10)
               || '             SELECT 1 FROM '
               || i.tblname
               || CHR (10)
               || '             WHERE CUSTID=A.CUSTID'
               || CHR (10)
               || '             AND '
               || i.fldkey
               || ' = l_acctno'
               || CHR (10)
               || '         );';
         ELSIF i.tblname = 'CIMAST'
         THEN
            SELECT msqrqr
            INTO l_msgrqr
            FROM tltx
            WHERE tltxcd = p_tltxcd;

            l_source_proc   :=
               l_source_proc || CHR (10)
               || '         SELECT FULLNAME CUSTNAME, ADDRESS, IDCODE LICENSE, CUSTODYCD'
               || CHR (10)
               || '         INTO p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custname,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').address,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').license,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custody'
               || CHR (10)
               || '         FROM CFMAST A'
               || CHR (10)
               || '         WHERE EXISTS ('
               || CHR (10)
               || '             SELECT 1 FROM '
               || i.tblname
               || CHR (10)
               || '             WHERE CUSTID=A.CUSTID'
               || CHR (10)
               || '             AND '
               || i.fldkey
               || ' = l_acctno'
               || CHR (10)
               || '         );';

            IF l_msgrqr = 'Y'
            THEN
               l_source_proc   :=
                     l_source_proc
                  || CHR (10)
                  || '         FOR i IN ('
                  || CHR (10)
                  || '             SELECT CI.HOLDBALANCE HOLDAMT,AF.BANKACCTNO BANKACCT, (AF.bankname || '':'' || A1.CDCONTENT) BANKNAME,A2.CDCONTENT BANKQUE'
                  || CHR (10)
                  || '             FROM CIMAST CI, AFMAST AF, ALLCODE A1, ALLCODE A2'
                  || CHR (10)
                  || '                 WHERE CI.ACCTNO = AF.CIACCTNO And AF.bankname = A1.CDVAL'
                  || CHR (10)
                  || '                 AND A1.CDTYPE=''CF'' AND A1.CDNAME=''BANKCODE'''
                  || CHR (10)
                  || '                 AND AF.bankname=A2.CDVAL'
                  || CHR (10)
                  || '                 AND A2.CDTYPE=''SA'' AND A2.CDNAME=''BANKQUEUE'' AND CI.ACCTNO=l_acctno'
                  || CHR (10)
                  || '         ) LOOP'
                  || CHR (10)
                  || '               p_txmsg.txPrintInfo('''
                  || i.acfld
                  || ''').holdamt := i.holdamt;'
                  || CHR (10)
                  || '               p_txmsg.txPrintInfo('''
                  || i.acfld
                  || ''').bankacc := i.bankacct;'
                  || CHR (10)
                  || '               p_txmsg.txPrintInfo('''
                  || i.acfld
                  || ''').bankname := i.bankname;'
                  || CHR (10)
                  || '               p_txmsg.txPrintInfo('''
                  || i.acfld
                  || ''').bankque := i.bankque;'
                  || CHR (10)
                  || '         END LOOP;';
            END IF;
         ELSIF i.tblname = 'CFMAST'
         THEN
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '         SELECT A.FULLNAME CUSTNAME, A.ADDRESS, A.IDCODE LICENSE, A.CUSTODYCD,l_acctno'
               || CHR (10)
               || '         INTO p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custname,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').address,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').license,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custody,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').value'
               || CHR (10)
               || '         FROM CFMAST A'
               || CHR (10)
               || '         WHERE '
               || i.fldkey
               || '=l_acctno;';
         ELSE
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '         SELECT A.FULLNAME CUSTNAME, A.ADDRESS, A.IDCODE LICENSE, A.CUSTODYCD,B.BANKACCTNO,l_acctno'
               || CHR (10)
               || '         INTO p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custname,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').address,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').license,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').custody,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').bankac,'
               || 'p_txmsg.txPrintInfo('''
               || i.acfld
               || ''').value'
               || CHR (10)
               || '         FROM CFMAST A, AFMAST  B '
               || CHR (10)
               || '         WHERE A.CUSTID = B.CUSTID '
               || CHR (10)
               || '         AND EXISTS ('
               || CHR (10)
               || '             SELECT 1 FROM '
               || i.tblname
               || CHR (10)
               || '             WHERE afacctno = b.acctno'
               || CHR (10)
               || '             AND '
               || i.fldkey
               || '=l_acctno'
               || CHR (10)
               || '         );';
         END IF;

         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '    EXCEPTION WHEN NO_DATA_FOUND THEN'
            || CHR (10)
            || '        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;'
            || CHR (10)
            || '        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;'
            || CHR (10)
            || '    END;'
            || CHR (10)
            || '    --<<END OF PROCESS '
            || i.tblname
            || '>>'
            || CHR (10)
            ||  CHR (10)
            || (case when to_char(pr_parse_amtexp (i.isrun))<> '1' then
                '    END IF;'
                else
                ''
                end);

      END LOOP;

      l_source_proc   :=
            l_source_proc
         || CHR (10)
         || '    plog.setendsection (pkgctx, ''pr_PrintInfo'');'
         || CHR (10)
         || 'END pr_PrintInfo;';

      plog.setendsection (pkgctx, 'fn_genprintinfo');
      RETURN l_source_proc;
   END fn_genprintinfo;

   FUNCTION fn_gentxchk (p_tltxcd varchar2)
      RETURN CLOB --VARCHAR2
   IS
      l_source_proc     CLOB; --VARCHAR2 (32000);
      l_deltdchk_temp   CLOB; --VARCHAR2 (32000);
      l_chk_temp        CLOB; --VARCHAR2 (32000);
      l_chk_into        CLOB; --VARCHAR2 (32000);
      l_chk_cond        CLOB; --VARCHAR2 (32000);
      l_chk             CLOB; --VARCHAR2 (32000);
      l_deltdchk        CLOB; --VARCHAR2 (32000);
      l_count           NUMBER(5);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_gentxchk');
      l_source_proc     :=
            'FUNCTION fn_txAppAutoCheck'
         || '(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)'
         || CHR (10)
         || 'RETURN  NUMBER IS '
         || CHR (10)
         || '   l_allow         boolean;'
         || CHR (10);


      FOR i
      IN (SELECT DISTINCT b.field
          FROM appchk a, apprules b
          WHERE     a.rulecd = b.rulecd
                AND a.apptype = b.apptype                                   --
                AND a.apptype = b.apptype
                AND a.tltxcd = p_tltxcd
                AND NVL (a.deltdchk, 'N') = 'N')
      LOOP
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '    l_'
            || LOWER (i.field)
            || ' apprules.field%TYPE;';
      END LOOP;

      FOR i
      IN (SELECT DISTINCT b.tblname
          FROM appchk a, apprules b
          WHERE     a.rulecd = b.rulecd
                AND a.apptype = b.apptype                                   --
                AND a.apptype = b.apptype
                AND a.tltxcd = p_tltxcd
                AND NVL (a.deltdchk, 'N') = 'N'
                AND b.tblname not in ('TDMAST','CAMAST','CASCHD','CFMAST'))
      LOOP
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '    l_'
            || LOWER (i.tblname)
            || 'check_arr'
            || ' txpks_check.'
            || LOWER (i.tblname)
            || 'check_arrtype;';
      END LOOP;

      l_source_proc     :=
            l_source_proc
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txAppAutoCheck'');';

      l_chk:='';
      l_chk_temp        := '';
      --Kien tra cho tieu khoan khong duoc phep lam giao dich
      FOR i
      IN (SELECT distinct a.acfld, b.tblname
          FROM appchk a, apprules b
          WHERE     a.rulecd = b.rulecd
                AND a.apptype = b.apptype                                   --
                AND a.apptype = b.apptype
                AND a.tltxcd = p_tltxcd
                AND NVL (a.deltdchk, 'N') = 'N')
      LOOP
         IF i.tblname IN ('CIMAST','SEMAST','LNMAST','DFMAST','ODMAST','RPMAST','SBGROUP')
         THEN
            l_chk_temp   :=
                  l_chk_temp
               || CHR (10)
               || '     If txpks_check.fn_aftxmapcheck('
               || 'p_txmsg.txfields('''
               || i.acfld
               || ''').value,'''
               || i.tblname
               || ''','''
               || i.acfld
               || ''','''
               || p_tltxcd
               || ''')<>''TRUE'' then '
               || CHR (10)
               || '         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;'
               || CHR (10)
               || '         plog.setendsection (pkgctx, ''fn_txAppAutoCheck'');'
               || CHR (10)
               || '         RETURN errnums.C_BIZ_RULE_INVALID;'
               || CHR (10)
               || '     End if;';

         END IF;


         l_chk:= l_chk
                || CHR (10)
                || l_chk_temp;
         l_chk_temp:='';
      END LOOP;
      --Ket thuc kiem tra cho tieu khoan co duoc phep lam giao dich

      l_chk_temp        := '';
      FOR i
      IN (SELECT a.fldkey, a.acfld, b.tblname,a.isrun
          FROM appchk a, apprules b
          WHERE     a.rulecd = b.rulecd
                AND a.apptype = b.apptype                                   --
                AND a.apptype = b.apptype
                AND a.tltxcd = p_tltxcd
                AND NVL (a.deltdchk, 'N') = 'N'
          GROUP BY a.fldkey, a.acfld, b.tblname,a.isrun)
      LOOP
         l_chk_temp:='';
         l_chk_into:='';
         IF i.tblname IN ('CIMAST', 'SEMAST', 'AFMAST', 'SEWITHDRAW','DFMAST','RPMAST','SBGROUP')
         THEN
            l_chk_temp   :=
                  l_chk_temp
               || CHR (10)
               || '     l_'
               || i.tblname
               || 'check_arr := txpks_check.fn_'
               || i.tblname
               || 'check('
               || 'p_txmsg.txfields('''
               || i.acfld
               || ''').value,'''
               || i.tblname
               || ''','''
               || i.fldkey
               || ''');';
         ELSE
            l_chk_temp   := l_chk_temp || CHR (10) || '       SELECT ';
            l_chk_into   := '      INTO ';
         END IF;

         l_chk_cond := '';

         FOR j
         IN (SELECT a.fldkey,
                    a.acfld,
                    a.amtexp,
                    b.tblname,
                    b.field,
                    b.operand,
                    b.refid,
                    b.errnum,
                    b.errmsg,
                    b.fldrnd,
                    a.chklev --warningerror
             FROM appchk a, apprules b
             WHERE     a.rulecd = b.rulecd
                   AND a.apptype = b.apptype                                --
                   AND a.apptype = b.apptype
                   AND a.tltxcd = p_tltxcd
                   AND NVL (a.deltdchk, 'N') = 'N'
                   AND a.fldkey = i.fldkey
                   AND a.acfld = i.acfld
                   AND b.tblname = i.tblname
                   and a.isrun = i.isrun )
         LOOP
            IF i.tblname IN ('CIMAST', 'SEMAST', 'AFMAST', 'SEWITHDRAW','DFMAST','RPMAST','SBGROUP')
            THEN
               l_chk_into   :=
                     l_chk_into
                  || CHR (10)
                  || '     l_'
                  || j.field
                  || ' := l_'
                  || i.tblname
                  || 'check_arr(0).'
                  || j.field
                  || ';';
            ELSE
               l_chk_temp   := l_chk_temp || ' ' || j.field || ',';
               l_chk_into   := l_chk_into || 'l_' || j.field || ',';
            END IF;

            IF j.chklev = 0 THEN
            l_chk_cond   :=
               l_chk_cond || CHR (10)
                   || '     IF NOT ('
                   || CASE
                         WHEN j.operand = 'NI'
                         THEN
                               ' INSTR('''
                            || pr_parse_amtexp (j.amtexp)
                            || ''','
                            || 'l_'
                            || j.field
                            || ') = 0'
                         WHEN j.operand = 'IN'
                         THEN
                                  ' INSTR('''
                            || pr_parse_amtexp (j.amtexp)
                            || ''','
                            || 'l_'
                            || j.field
                            || ') > 0'
                         ELSE
                               'to_number(l_'
                            || j.field
                            || ') '
                            || (CASE WHEN j.operand = '==' THEN '=' WHEN j.operand = '>>' THEN '>' ELSE j.operand END)
                            || ' to_number('
                            || pr_parse_amtexp_rnd (j.amtexp,j.fldrnd)
                            || ')'
                      END
                   || ') THEN'
                   || CHR (10)
                   || '        p_err_code := '''
                   || j.errnum
                   || ''';'
                   || CHR (10)
                   || 'plog.setendsection (pkgctx, ''fn_txAppAutoCheck'');'
                   || CHR (10)
                   || '        RETURN errnums.C_BIZ_RULE_INVALID;'
                   || CHR (10)
                   || '     END IF;';
            ELSE -- warningerror
            l_chk_cond   :=
               l_chk_cond || CHR (10)
                   || '     IF NOT ('
                   || CASE
                         WHEN j.operand = 'NI'
                         THEN
                               ' INSTR('''
                            || pr_parse_amtexp (j.amtexp)
                            || ''','
                            || 'l_'
                            || j.field
                            || ') = 0'
                         WHEN j.operand = 'IN'
                         THEN
                                  ' INSTR('''
                            || pr_parse_amtexp (j.amtexp)
                            || ''','
                            || 'l_'
                            || j.field
                            || ') > 0'
                         ELSE
                               'to_number(l_'
                            || j.field
                            || ') '
                            || (CASE WHEN j.operand = '==' THEN '=' WHEN j.operand = '>>' THEN '>'  ELSE j.operand END)
                            || ' to_number('
                            || pr_parse_amtexp_rnd (j.amtexp,j.fldrnd)
                            || ')'
                      END
                   || ') THEN'
                   || CHR (10)
                   || '        p_txmsg.txWarningException('''
                   || j.errnum
                   || '' || j.chklev || ''').value:= cspks_system.fn_get_errmsg('''
                   || j.errnum || ''');'
                   || CHR (10)
                   || '        p_txmsg.txWarningException('''
                   || j.errnum
                   || '' || j.chklev || ''').errlev:= '''
                   || j.chklev || ''';'
                   || CHR (10)
                   || '     END IF;';


            END IF;
         END LOOP;

         IF i.tblname IN ('CIMAST', 'SEMAST', 'AFMAST', 'SEWITHDRAW','DFMAST','RPMAST','SBGROUP')
         THEN
            l_chk_temp   := l_chk_temp || CHR (10) || l_chk_into|| CHR (10) || l_chk_cond;
         ELSE
            l_chk_temp   :=
                  SUBSTR (l_chk_temp, 0, LENGTH (l_chk_temp) - 1)
               || CHR (10)
               || SUBSTR (l_chk_into, 0, LENGTH (l_chk_into) - 1)
               || CHR (10)
               || '        FROM '
               || i.tblname
               || CHR (10)
               || '        WHERE '
               || i.fldkey
               || ' = p_txmsg.txfields('''
               || i.acfld
               || ''').value;'
               || CHR (10) || l_chk_cond;
         END IF;

         l_chk_temp:=
                (case when to_char(pr_parse_amtexp (i.isrun))<> '1' then
                 '    IF to_char(' || pr_parse_amtexp (i.isrun) || ') <> ''0'' THEN '
                    || CHR (10)
                 else
                 ''
                 end)
                || l_chk_temp
                ||  CHR (10)
                || (case when to_char(pr_parse_amtexp (i.isrun))<> '1' then
                    '    END IF;'
                    else
                    ''
                    end);
         l_chk:= l_chk
                || CHR (10)
                || l_chk_temp;
         l_chk_temp:='';
      END LOOP;

      --l_chk_temp        := l_chk_temp || CHR (10) || l_chk_cond;

      l_deltdchk_temp   := '';
      l_chk_cond        := '';
      l_chk_into        := '';
      l_deltdchk        := '';
      FOR i
      IN (SELECT a.fldkey, a.acfld, b.tblname,a.isrun
          FROM appchk a, apprules b
          WHERE     a.rulecd = b.rulecd
                AND a.apptype = b.apptype                                   --
                AND a.apptype = b.apptype
                AND a.tltxcd = p_tltxcd
                AND NVL (a.deltdchk, 'N') = 'Y'
          GROUP BY a.fldkey, a.acfld, b.tblname,a.isrun)
      LOOP
         IF i.tblname IN ('CIMAST', 'SEMAST', 'AFMAST', 'SEWITHDRAW','DFMAST','RPMAST','SBGROUP')
         THEN
            l_deltdchk_temp   :=
                  l_deltdchk_temp
               || CHR (10)
               || '     l_'
               || i.tblname
               || 'check_arr := txpks_check.fn_'
               || i.tblname
               || 'check('
               || 'p_txmsg.txfields('''
               || i.acfld
               || ''').value,'''
               || i.tblname
               || ''','''
               || i.fldkey
               || ''');';
         ELSE
            l_deltdchk_temp   :=
               l_deltdchk_temp || CHR (10) || '       SELECT ';
            l_chk_into   := '      INTO ';
         END IF;

         l_chk_cond := '';

         FOR j
         IN (SELECT a.fldkey,
                    a.acfld,
                    a.amtexp,
                    b.tblname,
                    b.field,
                    b.operand,
                    b.refid,
                    b.errnum,
                    b.errmsg,
                    a.chklev --warningerror
             FROM appchk a, apprules b
             WHERE     a.rulecd = b.rulecd
                   AND a.apptype = b.apptype                                --
                   AND a.apptype = b.apptype
                   AND a.tltxcd = p_tltxcd
                   AND NVL (a.deltdchk, 'N') = 'N'
                   AND a.fldkey = i.fldkey
                   AND a.acfld = i.acfld
                   AND b.tblname = i.tblname)
         LOOP
            IF i.tblname IN ('CIMAST', 'SEMAST', 'AFMAST', 'SEWITHDRAW','DFMAST','RPMAST','SBGROUP')
            THEN
               l_chk_into   :=
                     l_chk_into
                  || CHR (10)
                  || '     l_'
                  || j.field
                  || ' := l_'
                  || i.tblname
                  || 'check_arr(0).'
                  || j.field
                  || ';';
            ELSE
               l_deltdchk_temp   := l_deltdchk_temp || ' ' || j.field || ',';
               l_chk_into        := l_chk_into || 'l_' || j.field || ',';
            END IF;
            IF j.chklev = 0 THEN
            l_chk_cond   :=
                  l_chk_cond
                   || CHR (10)
                   || '     IF NOT (l_'
                   || j.field
                   || ' '
                   || CASE WHEN j.operand = 'NI' THEN 'NOT IN' ELSE j.operand END
                   || ' ('
                   || pr_parse_amtexp (j.amtexp)
                   || ')) THEN'
                   || CHR (10)
                   || '        p_err_code := '''
                   || j.errnum
                   || ''';'
                   || CHR (10)
                   || '        plog.setendsection (pkgctx, ''fn_txAppAutoCheck'');'
                   || CHR (10)
                   || '        RETURN errnums.C_BIZ_RULE_INVALID;'
                   || CHR (10)
                   || '     END IF;';
            ELSE
            l_chk_cond   :=
                  l_chk_cond
                   || CHR (10)
                   || '     IF NOT (l_'
                   || j.field
                   || ' '
                   || CASE WHEN j.operand = 'NI' THEN 'NOT IN' ELSE j.operand END
                   || ' ('
                   || pr_parse_amtexp (j.amtexp)
                   || ')) THEN'
                   || CHR (10)
                   || '        p_txmsg.txWarningException('''
                   || j.errnum
                   || '' || j.chklev || ''').value:= cspks_system.fn_get_errmsg('''
                   || j.errnum || ''');'
                   || CHR (10)
                   || '        p_txmsg.txWarningException('''
                   || j.errnum
                   || '' || j.chklev || ''').errlev:= '''
                   || j.chklev || ''';'
                   || CHR (10)
                   || '     END IF;';
            END IF;

         END LOOP;

         IF i.tblname IN ('CIMAST', 'SEMAST', 'AFMAST', 'SEWITHDRAW','DFMAST','RPMAST','SBGROUP')
         THEN
            l_deltdchk_temp   := l_deltdchk_temp || CHR (10) || l_chk_into
            || l_chk_cond;
         ELSE
            l_deltdchk_temp   :=
                  SUBSTR (l_deltdchk_temp, 0, LENGTH (l_deltdchk_temp) - 1)
               || CHR (10)
               || SUBSTR (l_chk_into, 0, LENGTH (l_chk_into) - 1)
               || CHR (10)
               || '        FROM '
               || i.tblname
               || CHR (10)
               || '        WHERE '
               || i.fldkey
               || ' = p_txmsg.txfields('''
               || i.acfld
               || ''').value;'
               || chr(10)
               || l_chk_cond;
         END IF;

         l_deltdchk_temp:=
            (case when to_char(pr_parse_amtexp (i.isrun))<> '1' then
             '    IF to_char(' || pr_parse_amtexp (i.isrun) || ') <> ''0'' THEN '
                || CHR (10)
             else
             ''
             end)
            || l_deltdchk_temp
            ||  CHR (10)
            || (case when to_char(pr_parse_amtexp (i.isrun))<> '1' then
                '    END IF;'
                else
                ''
                end);
         l_deltdchk:= l_deltdchk
            || CHR (10)
            || l_deltdchk_temp;
         l_deltdchk_temp:='';
      END LOOP;

      IF LENGTH (l_chk) > 0
      THEN
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '   IF p_txmsg.deltd = ''N'' THEN'
            || l_chk;

         IF LENGTH (l_deltdchk) > 0
         THEN
            l_source_proc   :=
                  l_source_proc
               || CHR (10)
               || '    ELSE'
               || CHR (10)
               || l_deltdchk
               || CHR (10)
               || '    END IF;';
         ELSE
            l_source_proc   := l_source_proc || CHR (10) || '    END IF;';
         END IF;
      ELSIF LENGTH (l_deltdchk) > 0
      THEN
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '   IF p_txmsg.deltd = ''Y'' THEN'
            || CHR (10)
            || l_deltdchk
            || CHR (10)
            || '    END IF;';
      END IF;
      l_source_proc     :=
            l_source_proc
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txAppAutoCheck'');'
         || CHR (10)
         || '   RETURN systemnums.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || '  WHEN others THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txAppAutoCheck'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAppAutoCheck;';
      plog.setendsection (pkgctx, 'fn_gentxchk');
      RETURN l_source_proc;
   END fn_gentxchk;

   -- Refactored procedure pr_txlog
   FUNCTION fn_gen_txlog (p_tltxcd VARCHAR2, p_insertFLD CHAR)
      RETURN CLOB --VARCHAR2
   IS
      l_source_proc   CLOB; --VARCHAR2 (32000);
      l_msgamtind     VARCHAR2 (1000);
      l_msgacctind    VARCHAR2 (1000);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_gen_txlog');
      plog.debug(pkgctx,'1');
      -- get field which contains amt
      SELECT msg_amt, msg_acct
      INTO l_msgamtind, l_msgacctind
      FROM tltx
      WHERE tltxcd = p_tltxcd;


      l_source_proc   :=
            'PROCEDURE pr_txlog'
         || '(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   v_count number;'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || 'plog.setbeginsection (pkgctx, ''pr_txlog'');'
         || CHR (10)
         || '   plog.debug(pkgctx, ''abt to insert into tllog, txnum: '' || p_txmsg.txnum);'
         || CHR (10)
         || '   select count(1) into v_count from tllog where txnum = p_txmsg.txnum;'
         || CHR (10)
         || '   if v_count=0 then'
         || CHR (10)
         || '      INSERT INTO tllog(autoid, txnum, txdate, txtime, brid, tlid,offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line, deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts, ovrsts, batchname, msgamt,msgacct, chktime, offtime, reftxnum)'
         || CHR (10)
         || '          VALUES('
         || CHR (10)
         || '          seq_tllog.NEXTVAL,'
         || CHR (10)
         || '          p_txmsg.txnum,'
         || CHR (10)
         || '          TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'
         || CHR (10)
         || '          p_txmsg.txtime,'
         || CHR (10)
         || '          p_txmsg.brid,'
         || CHR (10)
         || '          p_txmsg.tlid,'
         || CHR (10)
         || '          p_txmsg.offid,'
         || CHR (10)
         || '          p_txmsg.ovrrqd,'
         || CHR (10)
         || '          p_txmsg.chid,'
         || CHR (10)
         || '          p_txmsg.chkid,'
         || CHR (10)
         || '          p_txmsg.tltxcd,'
         || CHR (10)
         || '          p_txmsg.ibt,'
         || CHR (10)
         || '          p_txmsg.brid2,'
         || CHR (10)
         || '          p_txmsg.tlid2,'
         || CHR (10)
         || '          p_txmsg.ccyusage,'
         || CHR (10)
         || '          p_txmsg.off_line,'
         || CHR (10)
         || '          p_txmsg.deltd,'
         || CHR (10)
         || '          TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'
         || CHR (10)
         || '          TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),'
         || CHR (10)
         || '          NVL(p_txmsg.txfields(''30'').value,p_txmsg.txdesc),'
         || CHR (10)
         || '          p_txmsg.ipaddress,'
         || CHR (10)
         || '          p_txmsg.wsname,'
         || CHR (10)
         || '          p_txmsg.txstatus,'
         || CHR (10)
         || '          p_txmsg.msgsts,'
         || CHR (10)
         || '          p_txmsg.ovrsts,'
         || CHR (10)
         || '          p_txmsg.batchname,'
         || CHR (10)
         || '          '
         || case when l_msgamtind is null then 'NULL' else pr_parse_amtexp (l_msgamtind) end
         || ' , '
         || CHR (10)
         || '          '
         || pr_parse_amtexp (l_msgacctind)
         || ' , '
         || CHR (10)
         -- save check time if a checker approve
         || '          TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.chkid,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.chkid)),'
         || CHR (10)
         -- save officer time if an officer approve
         || '          TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.offtime)),'
         || CHR (10)
         || '          p_txmsg.reftxnum);'
         || CHR (10);


      -- 2. Trace to tllogfld TABLE
      l_source_proc   := l_source_proc || CHR (10);

      FOR j IN (SELECT fldname, fldtype, en_caption
                FROM fldmaster
                WHERE objname = p_tltxcd
                AND p_insertFLD = 'Y'
                ORDER BY odrnum)
      LOOP
         l_source_proc   :=
            l_source_proc || CHR (10)
            || '       plog.debug(pkgctx, ''abt to insert into tllogfld'');'
            || CHR (10)
            || '       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)'
            || CHR (10)
            || '          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'
            || ''''
            || j.fldname
            || ''','
            || CASE j.fldtype
                  WHEN 'N'
                  THEN
                        'TO_NUMBER(p_txmsg.txfields(''' || j.fldname || ''').value),'
                        --'TO_NUMBER(cspks_system.fn_correct_field(p_txmsg,''' || j.fldname || ''',''N'')),'
                  ELSE
                     '0,'
               END
            || CASE j.fldtype
                  WHEN 'C'
                  THEN
                     'p_txmsg.txfields(''' || j.fldname || ''').value,'
                     --'cspks_system.fn_correct_field(p_txmsg,''' || j.fldname || ''',''C''),'
                  ELSE
                     'NULL,'
               END
            || ''''
            || j.en_caption
            || ''');';
      END LOOP;
plog.debug(pkgctx,'3');
      l_source_proc   :=
         l_source_proc || CHR (10)
         || '          plog.debug(pkgctx,''Check if neccessary to poplulate FEETRAN and VATTRAN'');'
         || CHR (10)
         || '      IF p_txmsg.txinfo.exists(txnums.C_TXINFO_VATTRAN) THEN'
         || CHR (10)
         || '          plog.debug(pkgctx,''Abt to insert into VATTRAN'');'
         || CHR (10)
         || '          INSERT INTO VATTRAN (AUTOID,TXNUM,TXDATE,VOUCHERNO,VOUCHERTYPE,SERIENO,VOUCHERDATE,CUSTID,TAXCODE,'
         || 'CUSTNAME,ADDRESS,CONTENTS,QTTY, PRICE,AMT,VATRATE,VATAMT,DESCRIPTION,DELTD)'
         || CHR (10)
         || '          VALUES ('
         || CHR (10)
         || '              SEQ_VATTRAN.NEXTVAL,'
         || CHR (10)
         || '              p_txmsg.txnum,'
         || CHR (10)
         || '              TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERNO), -- voucherno'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERTYPE), -- vouchertype'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_SERIALNO), -- serieno'
         || CHR (10)
         || '              TO_DATE(p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERDATE),systemnums.C_DATE_FORMAT), --voucherdate'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CUSTID ), -- CUSTID'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_TAXCODE ), -- TAXCODE '
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CUSTNAME ), -- CUSTNAME '
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_ADDRESS ), -- ADDRESS '
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CONTENTS ), -- CONTENTS '
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_QTTY ), -- QTTY'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_PRICE ), -- PRICE'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_AMT ), -- AMT'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VATRATE ), -- VATRATE'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VATAMT ), -- VATAMT'
         || CHR (10)
         || '              p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_DESCRIPTION ), -- DESCRIPTION'
         || CHR (10)
         || '              txnums.C_DELTD_TXNORMAL);'
         || CHR (10)
         || '      END IF;'
         || CHR (10)
         || '          plog.debug(pkgctx,''Abt to insert into FEETRAN'');'
         || CHR (10)
         || '      IF p_txmsg.txinfo.exists(txnums.C_TXINFO_FEETRAN ) THEN'
         || CHR (10)
         || '           INSERT INTO FEETRAN(AUTOID,TXDATE,TXNUM,DELTD,FEECD,GLACCTNO,FEEAMT,VATAMT,TXAMT,FEERATE,VATRATE)'
         || CHR (10)
         || '           VALUES ('
         || CHR (10)
         || '               SEQ_FEETRAN.NEXTVAL,'
         || CHR (10)
         || '               TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'
         || CHR (10)
         || '               p_txmsg.txnum, --TXNUM'
         || CHR (10)
         || '               txnums.C_DELTD_TXNORMAL,'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN )(txnums.C_FEETRAN_FEECD),  --FEECD'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_GLACCTNO),  --GLACCTNO'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_FEEAMT),  --FEEAMT'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_VATAMT),  --VATAMT'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_TXAMT),  --TXAMT'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_FEERATE),  --FEERATE'
         || CHR (10)
         || '               p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_VATRATE)); --VATRATE'
         || CHR (10)
         || '      END IF;'
         || CHR (10)
         || '   Else'
         || CHR (10)
         || '               txpks_txlog.pr_update_status(p_txmsg);'
         || CHR (10)
         || '   End if;'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''pr_txlog'');'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''pr_txlog'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END pr_txlog;';
plog.debug(pkgctx,'4');
      plog.setendsection (pkgctx, 'fn_gen_txlog');
      RETURN l_source_proc;
   END fn_gen_txlog;

   FUNCTION fn_genappupdate (p_tltxcd varchar2)
      RETURN CLOB
   IS
      l_source_proc      CLOB;--VARCHAR2 (32000);
      l_txnormal         CLOB; --VARCHAR2 (32000);
      l_txreversal       CLOB; --VARCHAR2 (32000);
      l_txupdate         VARCHAR2 (32000) := '';
      l_txupdateall      VARCHAR2 (32000) := '';
      l_txnormalheader   NUMBER (6);
      l_txdesc           VARCHAR2(1000);
      l_id                 NUMBER;
      l_count                 NUMBER;
      l_text             varchar2(1000);
      l_fldrnd           varchar2(5);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genappupdate');
      l_source_proc      :=
            'FUNCTION fn_txAppAutoUpdate'
         || '(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)'
         || CHR (10)
         || 'RETURN  NUMBER'
         || CHR (10)
         || 'IS '
         || CHR (10)
         || 'l_txdesc VARCHAR2(1000);'
         || CHR (10)
         || 'BEGIN';
      l_txnormal         :=
         '   IF p_txmsg.deltd <> ''Y'' THEN -- Normal transaction'
         || CHR (10);
      l_txnormalheader   := LENGTH (l_txnormal);

      -- << BEGIN TO GEN TRAN>>

      FOR t
      IN (SELECT a.apptxcd,
                 a.apptype,
                 a.acfld,
                 a.amtexp,
                 a.acfldref,
                 b.fldtype,
                 b.txupdate,
                 b.txtype,
                 b.field,
                 b.tblname,
                 b.tranf,
                 case when substr(a.isrun,1,1) ='!' then substr(a.isrun,2) else a.isrun end isrun,
                 case when substr(a.isrun,1,1) ='!' then '!' else 'X' end markisrun,

                 b.fldrnd,
                 a.trdesc
          FROM appmap a, apptx b
          WHERE     a.apptxcd = b.txcd
                AND a.apptype = b.apptype
                AND tltxcd = p_tltxcd
                AND NVL (tranf, 'XXX') <> 'XXX' -- GROUP BY FLDKEY,ACFLD,TBLNAME
          ORDER BY a.odrnum, a.APPTYPE, a.ACFLD, b.TBLNAME, b.FIELD, a.FLDKEY, a.APPTXCD
                                               )
      LOOP
         --Xac dinh truong dien giai cho phep toan
         l_txdesc:='';
         l_text:='';
         If t.trdesc Is null or length(t.trdesc) = 0 Then
            l_txdesc:=''' || '''' || ''';
         elsif t.trdesc = '##' Then
            l_txdesc:=''' || p_txmsg.txdesc || ''';
         elsif t.trdesc = 'EX' Then
            l_text :='l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,''' || p_tltxcd || ''',''' || t.apptype || ''',''' || t.apptxcd || ''');';
            l_txdesc:=''' || l_txdesc || ''';
         elsif substr(t.trdesc,1,7) = 'FORMAT:' then
            l_text := l_text || 'l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,''' || p_tltxcd || ''',''' || t.apptype || ''',''' || t.apptxcd || ''',''' || substr(t.trdesc,9,4) || ''');';
            l_txdesc:=''' || l_txdesc || ''';
         else
            l_count:=0;
            For l_id in  0 .. Length(t.trdesc) - 1 loop
                if l_count=0 then
                    If substr(t.trdesc,l_id+1,1) = '#' Then
                        l_txdesc := l_txdesc || ''' || p_txmsg.txfields (''' || substr(t.trdesc,l_id+2,2) || ''').VALUE || ''';
                        l_count:= 2;
                    Else
                        l_txdesc := l_txdesc || substr(t.trdesc,l_id+1,1);
                    End If;
                else
                    l_count:=l_count-1;
                end if;
            end loop;
         end if;
         --Ket thuc xac dinh dien giai cho giao dich

         l_txnormal   :=
             l_txnormal
            || CHR (10)
            || (case when to_char(pr_parse_amtexp (t.isrun))<> '1' then
                 '    IF to_char(' || pr_parse_amtexp (t.isrun) || ') <> ''' || (case when t.markisrun ='!' then '1' else '0' end ) || ''' THEN '
                    || CHR (10)
                 else
                 ''
                 end)
                || case when length(l_text)>0 then  '      ' || l_text || CHR (10) else '' end
                || '      INSERT INTO ' || t.tranf
                || '(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)'
                || CHR (10)
                || '            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),'
                || 'p_txmsg.txfields ('''
                || t.acfld
                || ''').value,'''
                || t.apptxcd
                || ''','                                                 --'0028',
                || CASE t.fldtype
                      WHEN 'N' THEN pr_parse_amtexp_rnd (t.amtexp,t.fldrnd) || ','
                      ELSE '0,'
                   END
                || CASE t.fldtype
                      WHEN 'C' THEN
                        (case when INSTR (t.amtexp, '@') > 0 then
                                  '''' || pr_parse_amtexp (t.amtexp) || ''','
                               else
                                    pr_parse_amtexp (t.amtexp) || ','
                               end)

                      ELSE 'NULL,'
                   END
                ||
                   CASE WHEN length(t.acfldref) = 2 THEN
                   'p_txmsg.txfields ('''
                || t.acfldref
                || ''').value,'
                        ELSE
                   ''''
                || t.acfldref
                || ''','
                   END
                || 'p_txmsg.deltd,'
                ||
                   CASE WHEN length(t.acfldref) = 2 THEN
                   'p_txmsg.txfields ('''
                || t.acfldref
                || ''').value,'
                        ELSE
                   ''''
                || t.acfldref
                || ''','
                   END
                || 'seq_'
                || t.tranf
                || '.NEXTVAL,'
                || 'p_txmsg.tltxcd,'
                || 'p_txmsg.busdate,'
                || ''''
                || l_txdesc
                || ''');'
                ||  CHR (10)
                || (case when to_char(pr_parse_amtexp (t.isrun))<> '1' then
                    '    END IF;'
                    else
                    ''
                    end);
      END LOOP;

      --<<END OF GEN TRAN>>

      --<<BEGIN OF GEN APPUPDATE FOR NORMAL TRANSACTION>>
      l_txupdate         := '';
      l_txupdateall      :='';
      FOR k
      IN (SELECT fldkey, acfld, tblname,
                --isrun
                case when substr(a.isrun,1,1) ='!' then substr(a.isrun,2) else a.isrun end isrun,
                case when substr(a.isrun,1,1) ='!' then '!' else 'X' end markisrun
          FROM appmap a, apptx b
          WHERE     a.apptxcd = b.txcd
                AND a.apptype = b.apptype
                AND tltxcd = p_tltxcd
          GROUP BY fldkey, acfld, tblname,isrun)
      LOOP

         l_txupdate   :=
               l_txupdate
            || CHR (10)
            || '      UPDATE '
            || k.tblname
            || CHR (10)
            || '         SET ';

         FOR k1
         IN (SELECT b.field
             FROM appmap a, apptx b
             WHERE     a.apptxcd = b.txcd
                   AND a.apptype = b.apptype
                   AND tltxcd = p_tltxcd
                   AND a.fldkey = k.fldkey
                   AND a.acfld = k.acfld
                   AND b.tblname = k.tblname
                   AND a.isrun = k.isrun
             GROUP BY b.field)
         LOOP
            l_txupdate   :=
                  l_txupdate
               || CHR (10)
               || '           '
               || k1.field
               || ' = '
               || k1.field;

            FOR k11
            IN (SELECT a.amtexp,
                       a.acfld,
                       a.fldkey,
                       b.field,
                       b.txtype,
                       b.tblname,
                       b.fldrnd,
                       b.fldtype
                FROM appmap a, apptx b
                WHERE     a.apptxcd = b.txcd
                      AND a.apptype = b.apptype
                      AND tltxcd = p_tltxcd
                      AND a.fldkey = k.fldkey
                      AND a.acfld = k.acfld
                      AND b.tblname = k.tblname
                      AND a.isrun = k.isrun
                      AND b.field = k1.field)
            LOOP
               l_txupdate   :=
                  CASE k11.txtype
                     WHEN 'U'
                     THEN
                        CASE WHEN k11.fldtype IN ('N') THEN
                             SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate) - LENGTH (k1.field)
                                  )
                                  || pr_parse_amtexp (k11.amtexp)
                        WHEN k11.fldtype IN ('D') THEN
                             SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate) - LENGTH (k1.field)
                                  )
                                  || 'to_date(' || pr_parse_amtexp (k11.amtexp) || ', ''DD/MM/RRRR'')'
                        ELSE
                            CASE
                               WHEN k11.field IN
                                          ('ORSTATUS',
                                           'STATUS',
                                           'ODSTS',
                                           'ISOTC',
                                           'EXORSTATUS')
                               THEN
                                    SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate)
                                          - LENGTH (k1.field || ' = ' || k1.field)
                                  )
                                  || 'P'
                                  || k1.field
                                  || '='
                                  || 'P'
                                  || k1.field
                                  || '||'
                                  || k1.field
                                  || ','
                                  || k1.field
                                  || '='
                                  || (case when INSTR (k11.amtexp, '@') > 0 then
                                       '''' || pr_parse_amtexp (k11.amtexp) || ''''
                                   else
                                       pr_parse_amtexp (k11.amtexp)
                                   end)
                               ELSE
                                  SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate) - LENGTH (k1.field)
                                  )
                               || (case when INSTR (k11.amtexp, '@') > 0 then
                                   '''' || pr_parse_amtexp (k11.amtexp) || ''''
                               else
                                   pr_parse_amtexp (k11.amtexp)
                               end)
                            END
                        END
                     WHEN 'D'
                     THEN
                        l_txupdate || ' - (' || pr_parse_amtexp_rnd (k11.amtexp,k11.fldrnd) || ')'
                     WHEN 'C'
                     THEN
                        l_txupdate || ' + (' || pr_parse_amtexp_rnd (k11.amtexp,k11.fldrnd) || ')'
                  END;
            END LOOP;

            l_txupdate   := l_txupdate || ',';
         END LOOP;
         if instr(k.tblname,'MAST')>0 then
            l_txupdate   := l_txupdate || ' LAST_CHANGE = SYSTIMESTAMP,';
         end if;
         l_txupdate   :=
             (case when to_char(pr_parse_amtexp (k.isrun))<> '1' then
                 '    IF to_char(' || pr_parse_amtexp (k.isrun) || ') <> ''' || (case when k.markisrun ='!' then '1' else '0' end ) || ''' THEN '
                    || CHR (10)
                 else
                 ''
                 end)
            ||   SUBSTR (l_txupdate, 1, LENGTH (l_txupdate) - 1)              --
            || CHR (10)
            || '        WHERE '
            || k.fldkey
            || '=p_txmsg.txfields('''
            || k.acfld
            || ''').value;'
            ||  CHR (10)
            || (case when to_char(pr_parse_amtexp (k.isrun))<> '1' then
                '    END IF;'
                else
                ''
                end);
         l_txupdateall:= l_txupdateall
         ||  CHR (10)
         || l_txupdate;
         l_txupdate:='';
      END LOOP;

      --plog.debug (pkgctx, 'l_txnormal: ' || l_txnormal);

      IF LENGTH (l_txnormal) = l_txnormalheader and (nvl(l_txupdateall,'XXX')='XXX' or LENGTH (l_txupdateall) <20)
      THEN
         l_txnormal   := '';
      ELSE
         l_txnormal   := l_txnormal || CHR (10) || l_txupdateall;
      END IF;

      l_source_proc      := l_source_proc || CHR (10) || l_txnormal;



      l_txreversal:= '      UPDATE TLLOG '
            || CHR (10)
            || '        SET DELTD = ''Y'''
            || CHR (10)
            || '        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);';

      FOR t
      IN (SELECT DISTINCT tranf
          FROM apptx a
          WHERE NVL (tranf, 'XXX') <> 'XXX'
                AND EXISTS
                      (SELECT 1
                       FROM appmap
                       WHERE     tltxcd = p_tltxcd
                             AND apptype = a.apptype
                             AND apptxcd = a.txcd))
      LOOP
         l_txreversal   :=
               l_txreversal
            || CHR (10)
            || '        UPDATE '
            || t.tranf
            || '        SET DELTD = ''Y'''
            || CHR (10)
            || '        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);';
      END LOOP;

      l_txupdate         := '';
      l_txupdateall      :='';

      FOR k
      IN (SELECT fldkey, acfld, tblname,
                --isrun
                case when substr(a.isrun,1,1) ='!' then substr(a.isrun,2) else a.isrun end isrun,
                case when substr(a.isrun,1,1) ='!' then '!' else 'X' end markisrun
          FROM appmap a, apptx b
          WHERE     a.apptxcd = b.txcd
                AND a.apptype = b.apptype
                AND tltxcd = p_tltxcd
          GROUP BY fldkey, acfld, tblname,isrun)
      LOOP
         l_txupdate   :=
               l_txupdate
            || CHR (10)
            || CHR (10)
            || '      UPDATE '
            || k.tblname
            || CHR (10)
            || '      SET ';

         FOR k1
         IN (SELECT b.field
             FROM appmap a, apptx b
             WHERE     a.apptxcd = b.txcd
                   AND a.apptype = b.apptype
                   AND tltxcd = p_tltxcd
                   AND a.fldkey = k.fldkey
                   AND a.acfld = k.acfld
                   AND b.tblname = k.tblname
                   and a.isrun=k.isrun
             GROUP BY b.field)
         LOOP
            l_txupdate   :=
                  l_txupdate
               || CHR (10)
               || '           '
               || k1.field
               || '='
               || k1.field;

            FOR k11
            IN (SELECT a.amtexp,
                       a.acfld,
                       a.fldkey,
                       b.field,
                       b.txtype,
                       b.tblname,
                       b.fldrnd,
                       b.fldtype
                FROM appmap a, apptx b
                WHERE     a.apptxcd = b.txcd
                      AND a.apptype = b.apptype
                      AND tltxcd = p_tltxcd
                      AND a.fldkey = k.fldkey
                      AND a.acfld = k.acfld
                      AND b.tblname = k.tblname
                      and a.isrun=k.isrun
                      AND b.field = k1.field)
            LOOP
               l_txupdate :=
                  CASE k11.txtype
                     WHEN 'U'
                     THEN
                        CASE WHEN k11.fldtype IN ('N') THEN
                             SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate) - LENGTH (k1.field)
                                  )
                                  || pr_parse_amtexp (k11.amtexp)
                        WHEN k11.fldtype IN ('D') THEN
                             SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate) - LENGTH (k1.field)
                                  )
                                  || 'to_date(' || pr_parse_amtexp (k11.amtexp) || ',''DD/MM/RRRR'')'
                        ELSE
                            CASE
                               WHEN k11.field IN
                                          ('STATUS',
                                           'ORSTATUS',
                                           'ODSTS',
                                           'ISOTC',
                                           'EXORSTATUS')
                               THEN
                                    SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate)
                                          - LENGTH (k1.field || ' = ' || k1.field)
                                  )
                                  || 'P'
                                  || k1.field
                                  || '='
                                  || 'P'
                                  || k1.field
                                  || '||'
                                  || k1.field
                                  || ','
                                  || k1.field
                                  || '='
                                  || 'substr(P'|| k11.field ||',length(P'|| k11.field ||'),1)'
                               ELSE
                                  SUBSTR (l_txupdate,
                                          0,
                                          LENGTH (l_txupdate) - LENGTH (k1.field)
                                  )
                                  || case when INSTR (k11.amtexp, '@') > 0 then
                                       '''' || pr_parse_amtexp (k11.amtexp) || ''''
                                   else
                                       pr_parse_amtexp (k11.amtexp)
                                   end
                                  --|| '''' || pr_parse_amtexp (k11.amtexp) || ''''
                            END
                        END
                     WHEN 'D'
                     THEN
                        l_txupdate || ' + (' || pr_parse_amtexp_rnd (k11.amtexp,k11.fldrnd) || ')'
                     WHEN 'C'
                     THEN
                        l_txupdate || ' - (' || pr_parse_amtexp_rnd (k11.amtexp,k11.fldrnd) || ')'
                  END;
            END LOOP;

            IF LENGTH (l_txupdate) > 0
            THEN
               l_txupdate   := l_txupdate || ',';
            END IF;
         END LOOP;
         if instr(k.tblname,'MAST')>0 then
            l_txupdate   := l_txupdate || ' LAST_CHANGE = SYSTIMESTAMP,';
         end if;
         IF LENGTH (l_txupdate) > 1
         THEN                                              -- only contain ','
            --l_txreversal   := l_txreversal
            l_txupdate :=(case when to_char(pr_parse_amtexp (k.isrun))<> '1' then
                 '    IF to_char(' || pr_parse_amtexp (k.isrun) || ') <> ''' || (case when k.markisrun ='!' then '1' else '0' end ) || ''' THEN '
                    || CHR (10)
                 else
                 ''
                 end)
               ||CHR (10)
               ||   SUBSTR (l_txupdate, 1, LENGTH (l_txupdate) - 1)           --
               || CHR (10)
               || '        WHERE '
               || k.fldkey
               || '=p_txmsg.txfields('''
               || k.acfld
               || ''').value;'
               ||  CHR (10)
               || (case when to_char(pr_parse_amtexp (k.isrun))<> '1' then
                '    END IF;'
                else
                ''
                end);
         END IF;
         l_txupdateall:= l_txupdateall
         ||  CHR (10)
         || l_txupdate;
         l_txupdate:='';
      END LOOP;

      IF nvl(l_txupdateall,'XXX')='XXX'  or  LENGTH (l_txupdateall)=0
      THEN
         l_txreversal   := '';
         l_txreversal:= '       UPDATE TLLOG '
            || CHR (10)
            || '        SET DELTD = ''Y'''
            || CHR (10)
            || '        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);';
      ELSE
         l_txreversal   := l_txreversal || CHR (10) || l_txupdateall;
      END IF;
      plog.debug (pkgctx, 'LENGTH(l_txreversal): ' || LENGTH (l_txreversal));

      IF NVL (l_txreversal, '$NULL$') <> '$NULL$'
         AND LENGTH (l_txreversal) > 0
      THEN
         --plog.debug (pkgctx, 'l_txnormal: ' || l_txreversal);
         l_source_proc   :=
            l_source_proc || CHR (10)
            || CASE
                  WHEN NVL (l_txnormal, '$NULL$') = '$NULL$'
                       OR LENGTH (l_txnormal) = 0
                  THEN
                     '   IF p_txmsg.deltd = ''Y'' THEN -- Reversal transaction'
                  ELSE
                     '   ELSE -- Reversal'
               END
            || CHR (10)
            || l_txreversal
            || CHR (10)
            || '   END IF;';
      ELSE
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || CASE WHEN LENGTH(l_txnormal) > 0 THEN '   END IF;' ELSE '' END;
      END IF;
      plog.debug (pkgctx, 'LENGTH(l_source_proc): ' || LENGTH (l_source_proc));
      l_source_proc      :=
            l_source_proc
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txAppAutoUpdate'');'
         || CHR (10)
         || '   RETURN systemnums.C_SUCCESS ;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || '  WHEN others THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txAppAutoUpdate'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAppAutoUpdate;';
      plog.debug (pkgctx, 'End fn_genappupdate LENGTH(l_source_proc): ' || LENGTH (l_source_proc));
      plog.setendsection (pkgctx, 'fn_genappupdate');
      RETURN l_source_proc;
   END fn_genappupdate;

   FUNCTION fn_gentx4gprocess (l_txtype IN char)
      RETURN CLOB
   IS
      l_source_proc   CLOB;--VARCHAR2 (32000);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_gentx4Gprocess');
      l_source_proc   :=
         'FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;'
         || CHR (10)
         || '   l_txmsg tx.msg_rectype;'
         || CHR (10)
         || '   l_count NUMBER(3);'
         || CHR (10)
         || '   l_approve BOOLEAN := FALSE;'
         || CHR (10)
         || '   l_status VARCHAR2(1);'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '   SELECT count(*) INTO l_count '
         || CHR (10)
         || '   FROM SYSVAR'
         || CHR (10)
         || '   WHERE GRNAME=''SYSTEM'''
         || CHR (10)
         || '   AND VARNAME=''HOSTATUS'''
         || CHR (10)
         || '   AND VARVALUE= systemnums.C_OPERATION_ACTIVE;'
         || CHR (10)
         || '   IF l_count = 0 THEN'
         || CHR (10)
         || '       p_err_code := errnums.C_HOST_OPERATION_ISINACTIVE;'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   plog.debug(pkgctx, ''xml2obj'');'
         || CHR (10)
         || '   l_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg);'
         || CHR (10)
         || '   l_count := 0; -- reset counter'
         || CHR (10)
         || '   SELECT count(*) INTO l_count '
         || CHR (10)
         || '   FROM SYSVAR'
         || CHR (10)
         || '   WHERE GRNAME=''SYSTEM'''
         || CHR (10)
         || '   AND VARNAME=''CURRDATE'''
         || CHR (10)
         || '   AND TO_DATE(VARVALUE,systemnums.C_DATE_FORMAT)= l_txmsg.txdate;'
         || CHR (10)
         || '   IF l_count = 0 THEN'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '       RETURN errnums.C_BRANCHDATE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   plog.debug(pkgctx, ''l_txmsg.txaction: '' || l_txmsg.txaction);'
         || CHR (10)
         || '   l_status:= l_txmsg.txstatus;'
         || CHR (10)
         || '   --GHI NHAN DE TRANH DOUBLE HACH TOAN GIAO DICH'
         || CHR (10)
         || '   pr_lockaccount(l_txmsg,p_err_code);'
         || CHR (10)
         || '   if p_err_code <> 0 then'
         || CHR (10)
         || '       pr_unlockaccount(l_txmsg);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '       RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '   end if;'
         || CHR (10)
         || '   -- <<BEGIN OF PROCESSING A TRANSACTION>>'
         || CHR (10)
         || '   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED AND '
         || 'l_txmsg.txstatus = txstatusnums.c_txdeleting THEN'
         || CHR (10)
         || '       txpks_txlog.pr_update_status(l_txmsg);'
         || CHR (10)
         || '       IF NVL(l_txmsg.ovrrqd,''$X$'')<> ''$X$'' AND length(l_txmsg.ovrrqd)> 0 THEN'
         || CHR (10)
         || '           IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN'
         || CHR (10)
         || '               p_err_code := errnums.C_CHECKER1_REQUIRED;'
         || CHR (10)
         || '           ELSE'
         || CHR (10)
         || '               p_err_code := errnums.C_CHECKER2_REQUIRED;'
         || CHR (10)
         || '           END IF;'
         || CHR (10)
         || '           plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '           pr_unlockaccount(l_txmsg);'
         || CHR (10)
         || '           RETURN l_return_code;'
         || CHR (10)
         || '       END IF;'
         || CHR (10)
         || '    END IF;'
         || CHR (10)
         || '   IF l_txmsg.deltd = txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txcompleted THEN'
         || CHR (10)
         || '       -- if Refuse a delete tx then update tx status'
         || CHR (10)
         || '       txpks_txlog.pr_update_status(l_txmsg);'
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '       pr_unlockaccount(l_txmsg);'
         || CHR (10)
         || '       RETURN l_return_code;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED THEN'
         || CHR (10)
         || '       plog.debug(pkgctx, ''<<BEGIN PROCESS NORMAL TX>>'');'
         || CHR (10)
         || '       plog.debug(pkgctx, ''l_txmsg.pretran: '' || l_txmsg.pretran);'
         || CHR (10)
         || '       IF l_txmsg.pretran = ''Y'' THEN'
         || CHR (10)
         || '           IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '               RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '           END IF;'
         || CHR (10)
         || '           pr_PrintInfo(l_txmsg, p_err_code);'
         || CHR (10)
         || '           IF NVL(l_txmsg.ovrrqd,''$X$'')<> ''$X$'' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN'
         || CHR (10)
         || '               IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN'
         || CHR (10)
         || '                   p_err_code := errnums.C_CHECKER1_REQUIRED;'
         || CHR (10)
         || '               ELSE'
         || CHR (10)
         || '                   p_err_code := errnums.C_CHECKER2_REQUIRED;'
         || CHR (10)
         || '               END IF;'
         || CHR (10)
         || '           END IF;'
         || CHR (10)
         || '           IF Length(Trim(Replace(l_txmsg.ovrrqd, errnums.C_CHECKER_CONTROL, ''''))) > 0 '
         || 'AND (NVL(l_txmsg.chkid,''$NULL$'') = ''$NULL$'' OR Length(l_txmsg.chkid) = 0) Then'
         || CHR (10)
         || '               p_err_code := errnums.C_CHECKER1_REQUIRED;'
         || CHR (10)
         || '           ELSE'
         || CHR (10)
         || '               IF InStr(l_txmsg.ovrrqd, errnums.OVRRQS_CHECKER_CONTROL) > 0 '
         || 'AND ( NVL(l_txmsg.offid,''$NULL$'') = ''$NULL$'' OR length(l_txmsg.offid) = 0) THEN'
         || CHR (10)
         || '                   p_err_code := errnums.C_CHECKER2_REQUIRED;'
         || CHR (10)
         || '               ELSE'
         || CHR (10)
         || '                   p_err_code := systemnums.C_SUCCESS;'
         || CHR (10)
         || '               End IF;'
         || CHR (10)
         || '           End IF;'
         || CHR (10)
         || '       ELSE --pretran=''N'''
         || CHR (10)
         || '           plog.debug(pkgctx, ''l_txmsg.nosubmit: '' || l_txmsg.nosubmit); '
         || CHR (10)
         || '           IF l_txmsg.nosubmit = ''1'' THEN'
         || CHR (10)
         || '               IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '                   RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '               END IF;'
         || CHR (10)
         || '               IF NVL(l_txmsg.ovrrqd,''$X$'')<> ''$X$'' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN'
         || CHR (10)
         || '                   IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN'
         || CHR (10)
         || '                       p_err_code := errnums.C_CHECKER1_REQUIRED;'
         || CHR (10)
         || '                   ELSE'
         || CHR (10)
         || '                       p_err_code := errnums.C_CHECKER2_REQUIRED;'
         || CHR (10)
         || '                   END IF;'
         || CHR (10)
         || '               END IF;'
         || CHR (10)
         || '               IF Length(Trim(Replace(l_txmsg.ovrrqd, errnums.C_CHECKER_CONTROL, ''''))) > 0 '
         || 'AND (NVL(l_txmsg.chkid,''$NULL$'')=''$NULL$'' OR Length(l_txmsg.chkid) = 0) THEN'
         || CHR (10)
         || '                   p_err_code := errnums.C_CHECKER1_REQUIRED;'
         || CHR (10)
         || '               ELSE'
         || CHR (10)
         || '                   IF InStr(l_txmsg.ovrrqd, errnums.OVRRQS_CHECKER_CONTROL) > 0 '
         || 'AND (NVL(l_txmsg.offid,''$NULL$'')=''$NULL$'' OR length(l_txmsg.offid) = 0) THEN'
         || CHR (10)
         || '                       p_err_code := errnums.C_CHECKER2_REQUIRED;'
         || CHR (10)
         || '                   ELSE'
         || CHR (10)
         || '                       l_return_code := systemnums.C_SUCCESS;'
         || CHR (10)
         || '                   END IF;'
         || CHR (10)
         || '               END IF;'
         || CHR (10)
         || '           END IF; -- END OF NOSUBMIT=1'
         || CHR (10)
         || '           plog.debug(pkgctx, ''l_return_code: '' || l_return_code);'
         || CHR (10)
         || '           IF l_return_code = systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '               IF NVL(l_txmsg.ovrrqd,''$X$'')= ''$X$'' OR Length(l_txmsg.ovrrqd) = 0 OR '
         || '(InStr(l_txmsg.ovrrqd, errnums.C_OFFID_REQUIRED) > 0 AND Length(l_txmsg.offid) > 0) OR '
         || '(Length(Replace(l_txmsg.ovrrqd, errnums.C_OFFID_REQUIRED, '''')) > 0 And Length(l_txmsg.chkid) > 0)  THEN'
         || CHR (10)
         || '                  l_approve := TRUE;'
         || CHR (10)
         || '               END IF;'
         || CHR (10)
         || '               plog.debug(pkgctx, ''l_txmsg.ovrrqd: '' || NVL(l_txmsg.ovrrqd,''$NULL$''));';

      IF    l_txtype = txnums.c_txtype_deposit
         OR l_txtype = txnums.c_txtype_transaction
         OR l_txtype = txnums.c_txtype_maintenance
      THEN
         IF l_txtype = txnums.c_txtype_deposit
         THEN
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '               IF l_approve = TRUE AND l_txmsg.txstatus= txstatusnums.c_txcashier  THEN';
         ELSE
            l_source_proc   :=
               l_source_proc || CHR (10)
               || '               plog.debug(pkgctx, ''l_approve,txstatus: '' ||  CASE WHEN l_approve=TRUE THEN ''TRUE'' ELSE ''FALSE'' END || '','' || l_txmsg.txstatus);'
               || CHR (10)
               || '               IF l_approve = TRUE AND '
               || '(l_txmsg.txstatus= txstatusnums.c_txlogged OR l_txmsg.txstatus= txstatusnums.c_txpending) THEN';
         END IF;

         l_source_proc   :=
            l_source_proc || CHR (10)
            || '                    IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                        RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '                    END IF;'
            || CHR (10)
            || '                    IF NVL(l_txmsg.ovrrqd,''$NULL$'')<> ''$NULL$'' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN'
            || CHR (10)
            || '                        IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN'
            || CHR (10)
            || '                            p_err_code := errnums.C_CHECKER1_REQUIRED;'
            || CHR (10)
            || '                        ELSE'
            || CHR (10)
            || '                            p_err_code := errnums.C_CHECKER2_REQUIRED;'
            || CHR (10)
            || '                        END IF;'
            || CHR (10)
            || '                    END IF;'
            || CHR (10)
            || '                    l_txmsg.txstatus := txstatusnums.c_txcompleted;'
            || CHR (10)
            || '                    IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                        RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '                    END IF;'
            || CHR (10)
            || '                    pr_txlog(l_txmsg, p_err_code);'
            || CHR (10)
            || '               End IF; -- END IF APPROVE=TRUE'
            || CHR (10)
            || '            END IF; -- end of return_code'
            || CHR (10)
            || '       END IF; --<<END OF PROCESS PRETRAN>>'
            || CHR (10)
            || '   ELSE -- DELETING TX'
            || CHR (10)
            || '   -- <<BEGIN OF DELETING A TRANSACTION>>'
            || CHR (10)
            || '   -- This kind of tx has not yet updated mast table in the host'
            || CHR (10)
            || '   -- Only need update tllog status'
            || CHR (10)
            || '      IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '          RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '      END IF;'
            || CHR (10)
            || '   -- <<END OF DELETING A TRANSACTION>>'
            || CHR (10)
            || '   END IF;';
      ELSE
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '                IF l_approve = TRUE THEN'
            || CHR (10)
            || '                    IF l_txmsg.txstatus= txstatusnums.c_txlogged THEN'
            || CHR (10)
            || '                        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                             RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '                        END IF;'
            || CHR (10)
            || '                    IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                        RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '                    END IF;'
            || CHR (10)
            || '                        pr_txlog(l_txmsg, p_err_code);'
            || CHR (10)
            || '                    ELSIF l_txmsg.txstatus= txstatusnums.c_txpending THEN'
            || CHR (10)
            || '                        l_txmsg.txstatus := '
            || CASE
                  WHEN l_txtype = txnums.c_txtype_remittance
                  THEN
                     'txstatusnums.c_txremittance;'
                  WHEN l_txtype = txnums.C_TXTYPE_ORDER
                  THEN
                     'txstatusnums.c_txcompleted;'
                  ELSE
                     'txstatusnums.c_txcashier;'
               END
            || CHR (10)
            || '                        txpks_txlog.pr_update_status(l_txmsg);'
            || CHR (10)
            || '                    END IF;'
            || CHR (10)
            || '               ELSE'
            || CHR (10)
            || '                    IF l_txmsg.txstatus= txstatusnums.c_txpending THEN'
            || CHR (10)
            || '                        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                             RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '                        END IF;'
            || CHR (10)
            || '                        IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                            RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '                        END IF;'
            || CHR (10)
            || '                        pr_txlog(l_txmsg, p_err_code);'
            || CHR (10)
            || '                    END IF;'
            || CHR (10)
            || '               End IF; --<<END OF PROCESS l_approve>>'
            || CHR (10)
            || CASE
                  WHEN l_txtype = txnums.c_txtype_witdrawal
                  THEN
                     '               IF l_status= txstatusnums.c_txcashier THEN'
                     || CHR (10)
                     || '                    --Cashier approve'
                     || CHR (10)
                     || '                    l_txmsg.txstatus := txstatusnums.c_txcompleted;'
                     || CHR (10)
                     || '                    txpks_txlog.pr_update_status(l_txmsg);'
                     || CHR (10)
                     || '               END IF;'
                     || CHR (10)
                     || '            END IF; -- END OF RETURN CODE=OK'
                     || CHR (10)
                     || '       END IF; --<<END OF PROCESS PRETRAN>>'
                  WHEN l_txtype = txnums.c_txtype_remittance
                  THEN
                     '               IF l_status= txstatusnums.c_txremittance THEN'
                     || CHR (10)
                     || '                    l_txmsg.txstatus := txstatusnums.c_txcompleted;'
                     || CHR (10)
                     || '                    txpks_txlog.pr_update_status(l_txmsg);'
                     || CHR (10)
                     || '               END IF;'
                     || CHR (10)
                     || '            END IF; -- end of return_code'
                     || CHR (10)
                     || '       END IF; --<<END OF PROCESS PRETRAN>>'
                  ELSE
                     '          End IF; '
                    || CHR (10)
                    || '     End IF;  '
                    || CHR (10)
               END
            || CHR (10)
            || '   ELSE -- PROCESS DELETING TX'
            || CHR (10)
            || '   -- <<BEGIN OF DELETING TRANSACTION>>'
            || CHR (10)
            || '        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '            RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '        END IF;'
            || CHR (10)
            || '      IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '          RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '      END IF;'
            || CHR (10)
            || '      txpks_txlog.pr_txdellog(l_txmsg, p_err_code);'
            || CHR (10)
            || '   -- <<END OF DELETING A TRANSACTION>>'
            || CHR (10)
            || '   END IF;';
      END IF;
      l_source_proc   :=
            l_source_proc
         || CHR (10)
         || '   plog.debug(pkgctx, ''obj2xml'');'
         || CHR (10)
         || '   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '   pr_unlockaccount(l_txmsg);'
         || CHR (10)
         || '   RETURN l_return_code;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN errnums.E_BIZ_RULE_INVALID'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      FOR I IN ('
         || CHR (10)
         || '           SELECT ERRDESC,EN_ERRDESC FROM deferror'
         || CHR (10)
         || '           WHERE ERRNUM= p_err_code'
         || CHR (10)
         || '      ) LOOP '
         || CHR (10)
         || '           p_err_param := i.errdesc;'
         || CHR (10)
         || '      END LOOP;'
         || '      l_txmsg.txException(''ERRSOURCE'').value := '''';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRSOURCE'').TYPE := ''System.String'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').value := p_err_code;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').TYPE := ''System.Int64'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').value := p_err_param;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').TYPE := ''System.String'';'
         || CHR (10)
         || '      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '      pr_unlockaccount(l_txmsg);'
         || CHR (10)
         || '      RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      p_err_param := ''SYSTEM_ERROR'';'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      l_txmsg.txException(''ERRSOURCE'').value := '''';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRSOURCE'').TYPE := ''System.String'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').value := p_err_code;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').TYPE := ''System.Int64'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').value :=  p_err_param;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').TYPE := ''System.String'';'
         || CHR (10)
         || '      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '      pr_unlockaccount(l_txmsg);'
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txProcess;';
         plog.error('LINH2:'||length(l_source_proc));
      plog.setbeginsection (pkgctx, 'fn_gentx4Gprocess');
      RETURN l_source_proc;

      EXCEPTION WHEN OTHERS THEN
         plog.error('LINH3:'||SQLERRM);

   END fn_gentx4gprocess;

   -- Refactored procedure fn_genTxProcess
   FUNCTION fn_gentxprocess (l_txtype IN char)
      RETURN CLOB
   IS
      l_source_proc  CLOB; -- VARCHAR2 (32000);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genTxProcess');
      l_source_proc   :=
         'FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;'
         || CHR (10)
         || '   l_txmsg tx.msg_rectype;'
         || CHR (10)
         || '   l_count NUMBER(3);'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '   SELECT count(*) INTO l_count '
         || CHR (10)
         || '   FROM SYSVAR'
         || CHR (10)
         || '   WHERE GRNAME=''SYSTEM'''
         || CHR (10)
         || '   AND VARNAME=''HOSTATUS'''
         || CHR (10)
         || '   AND VARVALUE= systemnums.C_OPERATION_ACTIVE;'
         || CHR (10)
         || '   IF l_count = 0 THEN'
         || CHR (10)
         || '       RETURN errnums.C_HOST_OPERATION_ISINACTIVE;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   plog.debug(pkgctx, ''xml2obj'');'
         || CHR (10)
         || '   l_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg, p_err_code);'
         || CHR (10)
         || '   plog.debug(pkgctx, ''l_txmsg.txaction: '' || l_txmsg.txaction);'
         || CHR (10)
         || '   IF l_txmsg.txaction = txnums.C_TXACTION_TRANSACT THEN'
         || CHR (10)
         || '   -- <<BEGIN OF PROCESSING A TRANSACTION>>'
         || CHR (10)
         || '       plog.debug(pkgctx, ''l_txmsg.txstatus: '' || l_txmsg.txstatus);'
         || CHR (10)
         || '       IF l_txmsg.txstatus = txstatusnums.c_txcompleted'
         || CHR (10)
         || '       -- if Refuse a delete tx then update tx status'
         || CHR (10)
         || '       THEN'
         || CHR (10)
         || '           txpks_txlog.pr_update_status(l_txmsg);'
         || CHR (10)
         || '           RETURN l_return_code;'
         || CHR (10)
         || '       END IF;'
         || CHR (10)
         || '       plog.debug(pkgctx, ''l_txmsg.pretran: '' || l_txmsg.pretran);'
         || CHR (10)
         || '       IF l_txmsg.pretran = ''Y'' THEN'
         || CHR (10)
         || '           IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '               RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '           END IF;'
         || CHR (10)
         || '           pr_PrintInfo(l_txmsg, p_err_code);'
         || CHR (10)
         || '           IF LENGTH(l_txmsg.ovrrqd) > 0 THEN'
         || CHR (10)
         || '               IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN'
         || CHR (10)
         || '                   l_return_code := errnums.C_CHECKER1_REQUIRED;'
         || CHR (10)
         || '               ELSE'
         || CHR (10)
         || '                   l_return_code := errnums.C_CHECKER2_REQUIRED;'
         || CHR (10)
         || '               END IF;'
         || CHR (10)
         || '           END IF;'
         || CHR (10)
         || '       ELSE'
         || CHR (10)
         || '           plog.debug(pkgctx, ''l_txmsg.nosubmit: '' || l_txmsg.nosubmit); '
         || CHR (10)
         || '           IF l_txmsg.nosubmit = ''1'' THEN'
         || CHR (10)
         || '               IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '                   RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '               END IF;';

      IF    l_txtype = txnums.c_txtype_deposit
         OR l_txtype = txnums.c_txtype_transaction
         OR l_txtype = txnums.c_txtype_maintenance
      THEN
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '           END IF;'
            || CHR (10)
            || '       END IF;'
            || CHR (10)
            || '   -- <<END OF PROCESSING A TRANSACTION>>'
            || CHR (10)
            || '   ELSIF l_txmsg.txaction = txnums.C_TXACTION_APPROVE THEN'
            || CHR (10)
            || '   -- <<BEGIN OF APPROVE A TRANSACTION>>'
            || CHR (10)
            || '        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '            RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '        END IF;'
            || CHR (10)
            || '        pr_txAppUpdate(l_txmsg, p_err_code);'
            || CHR (10)
            || '        pr_txlog(l_txmsg, p_err_code);'
            || CHR (10)
            || '   -- <<END OF APPROVE A TRANSACTION>>'
            || CHR (10)
            || '   ELSIF l_txmsg.txaction = txnums.C_TXACTION_DELETE THEN'
            || CHR (10)
            || '   -- <<BEGIN OF DELETING A TRANSACTION>>'
            || CHR (10)
            || '   -- This kind of tx has not yet updated mast table in the host'
            || CHR (10)
            || '   -- Only need update tllog status'
            || CHR (10)
            || '      pr_txAppUpdate(l_txmsg, p_err_code);'
            || CHR (10)
            || '   -- <<END OF DELETING A TRANSACTION>>'
            || CHR (10)
            || '   END IF;';
      ELSE
         l_source_proc   :=
               l_source_proc
            || CHR (10)
            || '        ELSE '
            || CHR (10)
            || '        --<<Update Mast table with W/R/O transact>>'
            || '            IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '                RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '             END IF;'
            || CHR (10)
            || '             pr_txAppUpdate(l_txmsg, p_err_code);'
            || CHR (10)
            || '             pr_txlog(l_txmsg, p_err_code);'
            || CHR (10)
            || '        END IF;'
            || CHR (10)
            || CHR (10)
            || '   -- <<END OF PROCESSING A TRANSACTION>>'
            || '   ELSIF l_txmsg.txaction = txnums.C_TXACTION_APPROVE THEN'
            || CHR (10)
            || '   -- <<BEGIN OF APPROVE A TRANSACTION>>'
            || CHR (10)
            || '       pr_txAppUpdate(l_txmsg, p_err_code);'
            || CHR (10)
            || '   -- <<END OF APPROVE A TRANSACTION>>'
            || CHR (10)
            || '   ELSIF l_txmsg.txaction = txnums.C_TXACTION_DELETE THEN'
            || CHR (10)
            || '   -- <<BEGIN OF DELETING TRANSACTION>>'
            || '        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '            RAISE errnums.E_BIZ_RULE_INVALID;'
            || CHR (10)
            || '        END IF;'
            || CHR (10)
            || '      pr_txAppUpdate(l_txmsg, p_err_code);'
            || CHR (10)
            || '      txpks_txlog.pr_txdellog(l_txmsg, p_err_code);'
            || CHR (10)
            || '   -- <<END OF DELETING A TRANSACTION>>'
            || CHR (10)
            || '   END IF;';
      END IF;


      l_source_proc   :=
            l_source_proc
         || CHR (10)
         || '   plog.debug(pkgctx, ''obj2xml'');'
         || CHR (10)
         || '   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg, p_err_code);'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '   RETURN l_return_code;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN errnums.E_BIZ_RULE_INVALID'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      FOR I IN ('
         || CHR (10)
         || '           SELECT ERRDESC,EN_ERRDESC FROM deferror'
         || CHR (10)
         || '           WHERE ERRNUM= p_err_code'
         || CHR (10)
         || '      ) LOOP '
         || CHR (10)
         || '           p_err_param := i.errdesc;'
         || CHR (10)
         || '      END LOOP;'
         || '      l_txmsg.txException(''ERRSOURCE'').value := '''';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRSOURCE'').TYPE := ''System.String'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').value := p_err_code;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').TYPE := ''System.Int64'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').value := p_err_param;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').TYPE := ''System.String'';'
         || CHR (10)
         || '      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg, p_err_code);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '      RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      p_err_param := ''SYSTEM_ERROR'';'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      l_txmsg.txException(''ERRSOURCE'').value := '''';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRSOURCE'').TYPE := ''System.String'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').value := p_err_code;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRCODE'').TYPE := ''System.Int64'';'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').value :=  p_err_param;'
         || CHR (10)
         || '      l_txmsg.txException(''ERRMSG'').TYPE := ''System.String'';'
         || CHR (10)
         || '      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg, p_err_code);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txProcess;';
      plog.setbeginsection (pkgctx, 'fn_genTxProcess');
      RETURN l_source_proc;
   END fn_gentxprocess;

   FUNCTION fn_genautotxprocess
      RETURN CLOB --VARCHAR2
   IS
      l_source_proc   CLOB; --VARCHAR2 (32000);
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genAutoTxProcess');
      l_source_proc   :=
         'FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;'
         || CHR (10)
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_AutoTxProcess'');'
         || CHR (10)
         || '   --GHI NHAN DE TRANH DOUBLE HACH TOAN GIAO DICH'
         || CHR (10)
         || '   pr_lockaccount(p_txmsg,p_err_code);'
         || CHR (10)
         || '   if p_err_code <> 0 then'
         || CHR (10)
         || '       pr_unlockaccount(p_txmsg); '
         || CHR (10)
         || '       plog.setendsection (pkgctx, ''fn_txProcess'');'
         || CHR (10)
         || '       RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '   end if;'
         || CHR (10)
         || '   IF fn_txAppCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '        RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   IF fn_txAppUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '        RAISE errnums.E_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   IF p_txmsg.deltd <> ''Y'' THEN -- Normal transaction'
         || CHR (10)
         || '       pr_txlog(p_txmsg, p_err_code);'
         || CHR (10)
         || '   ELSE    -- Delete transaction'
         || CHR (10)
         || '       txpks_txlog.pr_txdellog(p_txmsg,p_err_code);'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_AutoTxProcess'');'
         || CHR (10)
         || '   pr_unlockaccount(p_txmsg); '
         || CHR (10)
         || '   RETURN l_return_code;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || '   WHEN errnums.E_BIZ_RULE_INVALID'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      FOR I IN ('
         || CHR (10)
         || '           SELECT ERRDESC,EN_ERRDESC FROM deferror'
         || CHR (10)
         || '           WHERE ERRNUM= p_err_code'
         || CHR (10)
         || '      ) LOOP '
         || CHR (10)
         || '           p_err_param := i.errdesc;'
         || CHR (10)
         || '      END LOOP;'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_AutoTxProcess'');'
         || CHR (10)
         || '      pr_unlockaccount(p_txmsg); '
         || CHR (10)
         || '      RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      p_err_param := ''SYSTEM_ERROR'';'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_AutoTxProcess'');'
         || CHR (10)
         || '      pr_unlockaccount(p_txmsg); '
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_AutoTxProcess;';
      plog.setbeginsection (pkgctx, 'fn_genAutoTxProcess');
      RETURN l_source_proc;
   END fn_genautotxprocess;


   PROCEDURE pr_genbizpkg (p_tltxcd VARCHAR2,p_genTLOGFLD char)
   IS
      l_source_proc      clob; --VARCHAR2 (32000);--
      l_wrapped_proc     CLOB; --VARCHAR2 (32000);
      l_proc     clob;
      l_txtype           CHAR (1);
      l_txdesc           VARCHAR2 (250);
      l_txpks_name       VARCHAR2 (60);
      l_txpks_imp_name   VARCHAR2 (60);
      l_count number(20);
      l_isbanktran  boolean;
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_genbizpkg');
      plog.debug(pkgctx,'Inside pr_genbizpkg');
      l_txpks_name       := 'txpks_#' || p_tltxcd;
      l_txpks_imp_name   := 'txpks_#' || p_tltxcd || 'EX';

      select count(1) into l_count from crbtxmap where objtype ='T' and objname =p_tltxcd;
      if l_count> 0 then
        l_isbanktran:= true;
      else
        l_isbanktran:= false;
      end if;
      SELECT txtype, en_txdesc
      INTO l_txtype, l_txdesc
      FROM tltx
      WHERE tltxcd = p_tltxcd;

      l_source_proc      :=
         'CREATE OR REPLACE PACKAGE txpks_#' || p_tltxcd || CHR (10)
         || '/** ----------------------------------------------------------------------------------------------------'
         || CHR (10)
         || ' ** Module: TX'
         || CHR (10)
         || ' ** Description: '
         || l_txdesc
         || CHR (10)
         || ' ** and is copyrighted by FSS.'
         || CHR (10)
         || ' **'
         || CHR (10)
         || ' **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,'
         || CHR (10)
         || ' **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,'
         || CHR (10)
         || ' **    graphic, optic recording or otherwise, translated in any language or computer language,'
         || CHR (10)
         || ' **    without the prior written permission of Financial Software Solutions. JSC.'
         || CHR (10)
         || ' **'
         || CHR (10)
         || ' **  MODIFICATION HISTORY'
         || CHR (10)
         || ' **  Person      Date           Comments'
         || CHR (10)
         || ' **  System      '
         || TO_CHAR (SYSDATE, 'DD/MM/RRRR')
         || '     Created'
         || CHR (10)
         || ' ** (c) 2008 by Financial Software Solutions. JSC.'
         || CHR (10)
         || ' ----------------------------------------------------------------------------------------------------*/'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || CHR (10)
         || 'FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'FUNCTION fn_BatchTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'FUNCTION fn_txrevert(p_txnum varchar2,p_txdate varchar2,p_err_code in out varchar2,p_err_param out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER;'
         || CHR (10)
         || 'END;';

      plog.debug(pkgctx,'length(l_source_proc)1:'||length(l_source_proc));
      EXECUTE IMMEDIATE to_char(l_source_proc);
      l_source_proc      :=
            'CREATE OR REPLACE PACKAGE BODY '
         || l_txpks_name
         || CHR (10)
         || 'IS'
         || CHR (10)
         || '   pkgctx   plog.log_ctx;'
         || CHR (10)
         || '   logrow   tlogdebug%ROWTYPE;'
         || CHR (10)
         || CHR (10)
         || fn_gen_txlog (p_tltxcd,p_genTLOGFLD)
         || '-- '
         || CHR (10)
         || CHR (10)
         || fn_genprintinfo (p_tltxcd)
         || CHR (10)
         || CHR (10)
         || fn_gentxchk (p_tltxcd)
         || CHR (10)
         || CHR (10)
         /*|| fn_genautopostmap (p_tltxcd,'0')--Gianhvg them vao
         || CHR (10)
         || CHR (10)*/
         || fn_genappupdate (p_tltxcd)
         || CHR (10)
         || CHR (10);

         if    l_isbanktran then
         l_source_proc:= l_source_proc || CHR(10)
         || fn_genbankrequest(p_tltxcd)
         || CHR (10);
         end if;

         l_source_proc:= l_source_proc || CHR(10)
         || 'FUNCTION fn_txAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txAppUpdate'');'
         || CHR (10)
         || '-- Run Pre Update'
         || CHR (10)
         || '   IF '
         || l_txpks_imp_name
         || '.fn_txPreAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;';

         l_source_proc:= l_source_proc || CHR(10)
         || '-- Run Auto Update'
         || CHR (10)
         || '   IF fn_txAppAutoUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;';

         if    l_isbanktran then
         l_source_proc:= l_source_proc || CHR(10)
         || '-- Run send bank request'
         || CHR (10)
         || '   IF fn_GenBankRequest(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;';
         end if;
         l_source_proc:= l_source_proc || CHR(10)
         || '-- Run After Update'
         || CHR (10)
         || '   IF '
         || l_txpks_imp_name
         || '.fn_txAftAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;';

      --select count(1) into l_count from prchk where tltxcd =p_tltxcd;
      --if l_count>0 then
           l_source_proc:=l_source_proc
            || CHR (10)
            || '   --plog.debug (pkgctx, ''Begin of updating pool and room'');'
            || CHR (10)
            || '   IF txpks_prchk.fn_txAutoUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
            || CHR (10)
            || '       plog.setendsection (pkgctx, ''fn_txAppUpdate'');'
            || CHR (10)
            || '        Return errnums.C_BIZ_RULE_INVALID;'
            || CHR (10)
            || '   END IF;'
            || CHR (10)
            || '   --plog.debug (pkgctx, ''End of updating pool and room'');';
      --end if;
      l_source_proc:= l_source_proc
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txAppUpdate'');'
         || CHR (10)
         || '   RETURN systemnums.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txAppUpdate'');'
         || CHR (10)
         || '      RAISE errnums.E_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAppUpdate;'
         || CHR (10)
         || CHR (10)
         || 'FUNCTION fn_txAppCheck(p_txmsg in out tx.msg_rectype, p_err_code out varchar2)'
         || CHR (10)
         || 'RETURN NUMBER'
         || CHR (10)
         || 'IS'
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '   plog.setbeginsection (pkgctx, ''fn_txAppCheck'');'
         || CHR (10)
         || '-- Run Pre check'
         || CHR (10)
         || '   IF '
         || l_txpks_imp_name
         || '.fn_txPreAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '-- Run Auto check'
         || CHR (10)
         || '   IF fn_txAppAutoCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;'
         || CHR (10)
         || '-- Run After check'
         || CHR (10)
         || '   IF '
         || l_txpks_imp_name
         || '.fn_txAftAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN'
         || CHR (10)
         || '       RETURN errnums.C_BIZ_RULE_INVALID;'
         || CHR (10)
         || '   END IF;';

        --select count(1) into l_count from prchk where tltxcd =p_tltxcd;
        --if l_count>0 then
            l_source_proc:=l_source_proc
                || CHR (10)
                || '   --plog.debug (pkgctx, ''Begin of checking pool and room'');'
                || CHR (10)
                || '   IF txpks_prchk.fn_txAutoCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN'
                || CHR (10)
                || '       plog.setendsection (pkgctx, ''fn_txAppCheck'');'
                || CHR (10)
                || '        Return errnums.C_BIZ_RULE_INVALID;'
                || CHR (10)
                || '   END IF;'
                || CHR (10)
                || '   --plog.debug (pkgctx, ''End of checking pool and room'');';
        --end if;

         l_source_proc:= l_source_proc
         || CHR (10)
         || '   plog.setendsection (pkgctx, ''fn_txAppCheck'');'
         || CHR (10)
         || '   RETURN SYSTEMNUMS.C_SUCCESS;'
         || CHR (10)
         || 'EXCEPTION'
         || CHR (10)
         || 'WHEN OTHERS'
         || CHR (10)
         || '   THEN'
         || CHR (10)
         || '      p_err_code := errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || '      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);'
         || CHR (10)
         || '      plog.setendsection (pkgctx, ''fn_txAppCheck'');'
         || CHR (10)
         || '      RETURN errnums.C_SYSTEM_ERROR;'
         || CHR (10)
         || 'END fn_txAppCheck;'
         || CHR (10)
         || CHR (10)
         || fn_gentx4gprocess (l_txtype)
         || CHR (10)
         || CHR (10)
         || fn_genautotxprocess
         || CHR (10)
         || CHR (10)
         || fn_genbatchtxprocess
         || CHR (10)
         || CHR (10)
         || fn_gentxrevert(p_tltxcd)
         || CHR (10)
         || CHR (10)
         || 'BEGIN'
         || CHR (10)
         || '      FOR i IN (SELECT *'
         || CHR (10)
         || '                FROM tlogdebug)'
         || CHR (10)
         || '      LOOP'
         || CHR (10)
         || '         logrow.loglevel    := i.loglevel;'
         || CHR (10)
         || '         logrow.log4table   := i.log4table;'
         || CHR (10)
         || '         logrow.log4alert   := i.log4alert;'
         || CHR (10)
         || '         logrow.log4trace   := i.log4trace;'
         || CHR (10)
         || '      END LOOP;'
         || CHR (10)
         || '      pkgctx    :='
         || CHR (10)
         || '         plog.init ('''
         || l_txpks_name
         || ''','
         || CHR (10)
         || '                    plevel => NVL(logrow.loglevel,30),'
         || CHR (10)
         || '                    plogtable => (NVL(logrow.log4table,''N'') = ''Y''),'
         || CHR (10)
         || '                    palert => (NVL(logrow.log4alert,''N'') = ''Y''),'
         || CHR (10)
         || '                    ptrace => (NVL(logrow.log4trace,''N'') = ''Y'')'
         || CHR (10)
         || '            );'
         || CHR (10)
         || 'END '
         || l_txpks_name
         || ';';
      plog.debug(pkgctx,length(l_source_proc));
      --Gianhvg
      plog.debug(pkgctx,'123');
      l_proc:=fn_genautopostmap (p_tltxcd,'0');
      insert into tbl_postmap(datetime,tltxcd,postmap)
      values (to_char(sysdate),p_tltxcd,l_proc);
      insert into tbl_txpks(datetime,tltxcd,postmap)
      values (to_char(sysdate),p_tltxcd,l_source_proc);

      plog.debug(pkgctx,'456');
      --GianhVG*/
      --l_wrapped_proc     := sys.DBMS_DDL.wrap (ddl => l_source_proc);
      --l_wrapped_proc     := l_source_proc;
      --ENd GianhVG
      plog.debug(pkgctx,'done');

      --EXECUTE IMMEDIATE l_wrapped_proc;
      --EXECUTE IMMEDIATE l_source_proc;
      --pr_execute(l_source_proc);

      plog.setendsection (pkgctx, 'pr_genbizpkg');
   END pr_genbizpkg;

   FUNCTION fn_gentransactpkg (p_tltxcd varchar2,
                               p_genTLOGFLD CHAR,
                               p_gen_autopkg char DEFAULT 'N',
                               p_gen_impkg char DEFAULT 'N'
   )
      RETURN BOOLEAN
   IS
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genTransactpkg');

      IF p_gen_impkg = 'Y'
      THEN
         plog.debug (pkgctx, 'gen impkg');
         pr_genimppkg (p_tltxcd);
      END IF;

      IF p_gen_autopkg = 'Y'
      THEN
         plog.debug (pkgctx, 'gen autopkg');
         pr_genautopkg (p_tltxcd);
      END IF;

      pr_genbizpkg (p_tltxcd,p_genTLOGFLD);
      plog.setendsection (pkgctx, 'fn_genTransactpkg');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         plog.error (pkgctx, SQLERRM);
         plog.setendsection (pkgctx, 'fn_genTransactpkg');
         RETURN FALSE;
   END fn_gentransactpkg;

   FUNCTION fn_genmultitransactpkg (p_multitltxcd varchar2,
                               p_genTLOGFLD CHAR,
                               p_gen_autopkg char DEFAULT 'N',
                               p_gen_impkg char DEFAULT 'N'
   )
      RETURN BOOLEAN
   IS
        l_tltxcd varchar2(10);
        l_multitltxcd varchar2(4000);
        l_allpks clob;
        l_pks   clob;
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genmultitransactpkg');
      l_multitltxcd:=p_multitltxcd;
      l_allpks:='----------------Script generated by tool-------------------';
      if l_multitltxcd ='ALL' then
         for rec in (select tltxcd from tltx where  runmod ='DB' /*AND SUBSTR(TLTXCD,1,1) not IN ('0','1','2','3')*/  order by tltxcd)
          loop
              l_tltxcd:=rec.tltxcd;
              delete from tbl_txpks where tltxcd =l_tltxcd;
              plog.debug (pkgctx, 'Begin gen tltxcd:' || l_tltxcd);
              if length (l_tltxcd) >0 then
                  IF p_gen_impkg = 'Y'
                  THEN
                     plog.debug (pkgctx, 'gen impkg');
                     pr_genimppkg (l_tltxcd);
                  END IF;

                  IF p_gen_autopkg = 'Y'
                  THEN
                     plog.debug (pkgctx, 'gen autopkg');
                     pr_genautopkg (l_tltxcd);
                  END IF;

                  pr_genbizpkg (l_tltxcd,p_genTLOGFLD);
              end if;
              plog.debug (pkgctx, 'End gen tltxcd:' || l_tltxcd);
              select postmap into l_pks from tbl_txpks where tltxcd =l_tltxcd;
              l_allpks:=l_allpks || CHR(10) || l_pks  || CHR(10) || '/';
          end loop;
      else
          while length(l_multitltxcd)>0
          loop
              l_tltxcd:=substr(l_multitltxcd,1,4);
              delete from tbl_txpks where tltxcd =l_tltxcd;
              plog.debug (pkgctx, 'Begin gen tltxcd:' || l_tltxcd);
              l_multitltxcd:= substr(l_multitltxcd,6);
              if length (l_tltxcd) >0 then
                  IF p_gen_impkg = 'Y'
                  THEN
                     plog.debug (pkgctx, 'gen impkg');
                     pr_genimppkg (l_tltxcd);
                  END IF;

                  IF p_gen_autopkg = 'Y'
                  THEN
                     plog.debug (pkgctx, 'gen autopkg');
                     pr_genautopkg (l_tltxcd);
                  END IF;

                  pr_genbizpkg (l_tltxcd,p_genTLOGFLD);
              end if;
              plog.debug (pkgctx, 'End gen tltxcd:' || l_tltxcd);
              select postmap into l_pks from tbl_txpks where tltxcd =l_tltxcd;
              l_allpks:=l_allpks || CHR(10) || l_pks  || CHR(10) || '/';
          end loop;
      end if;

      l_allpks:=l_allpks || CHR(10)
                || '----------------End script generated by tool-------------------';
      insert into tbl_txpks(datetime,tltxcd,postmap)
      values (to_char(sysdate),'4ALL',l_allpks);
      plog.setendsection (pkgctx, 'fn_genmultitransactpkg');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         plog.error (pkgctx, SQLERRM);
         plog.setendsection (pkgctx, 'fn_genmultitransactpkg');
         RETURN FALSE;
   END fn_genmultitransactpkg;



   FUNCTION fn_genalltransactpkg (p_ovrride char DEFAULT 'N',p_genTLOGFLD CHAR)
      RETURN BOOLEAN
   IS
   BEGIN
      plog.setbeginsection (pkgctx, 'fn_genAllTransactpkg');

      FOR i IN (SELECT tltxcd
                FROM tltx)
      LOOP
         BEGIN
            IF p_ovrride = 'Y'
            THEN
               pr_genimppkg (i.tltxcd);
            END IF;

            pr_genbizpkg (i.tltxcd,p_genTLOGFLD);
         EXCEPTION
            WHEN OTHERS
            THEN
               plog.error (pkgctx, i.tltxcd || ': ' || SQLERRM);
         END;
      END LOOP;

      plog.setendsection (pkgctx, 'fn_genAllTransactpkg');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         plog.error (pkgctx, 'ERR: ' || SQLERRM);
         plog.setendsection (pkgctx, 'fn_genAllTransactpkg');
         RETURN FALSE;
   END fn_genalltransactpkg;
BEGIN
   FOR i IN (SELECT *
             FROM tlogdebug)
   LOOP
      logrow.loglevel    := i.loglevel;
      logrow.log4table   := i.log4table;
      logrow.log4alert   := i.log4alert;
      logrow.log4trace   := i.log4trace;
   END LOOP;
   dbms_output.put_line('level1: ' || logrow.loglevel);
   pkgctx    :=
      plog.init ('fwpks_toolkit',
                 plevel => 70,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
  dbms_output.put_line('level: ' || logrow.loglevel);
END fwpks_toolkit;

/
