SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3375ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3375EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/08/2010     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#3375ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_reportdate       CONSTANT CHAR(2) := '06';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_rate             CONSTANT CHAR(2) := '10';
   c_status           CONSTANT CHAR(2) := '20';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_camastid varchar2(30);
    l_catype varchar2(30);
    l_count NUMBER;
    l_reportdate DATE;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
    l_camastid:= p_txmsg.txfields('03').value;
    l_reportdate:= TO_DATE(p_txmsg.txfields('06').value,systemnums.C_DATE_FORMAT);

    IF p_txmsg.deltd <> 'Y' THEN -- Normal TRANSACTION
        If length(l_camastid) > 0 THEN
        --  LAY THONG TIN DOT THUC HIEN QUYEN
            begin
                SELECT catype INTO l_catype FROM camast WHERE camastid = l_camastid;
            exception when others then
                p_err_code := '-300043';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end;
            IF l_catype = '025' THEN
                SELECT count(1) INTO l_count FROM camast WHERE status = 'N' AND catype IN ('015');
                IF l_count > 0 THEN
                    p_err_code := '-300028';
                    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
            END IF;
        END IF;
    END IF;

    --Kiem tra ngay thuc hien GD phai nam trong khoang tu ngay REPORTDATE den ngay ACTIONDATE
    IF to_date(p_txmsg.txdate,systemnums.C_DATE_FORMAT) <= l_reportdate THEN
            p_err_code := '-300018';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAftAppCheck');
   plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_camastid varchar2(30);
    l_reportdate DATE;
    ---l_actiondate DATE;
    l_catype varchar2(30);
    l_qttyexp varchar2(2000);
    l_aqttyexp varchar2(2000);
    l_amtexp VARCHAR2 (2000);
    l_aamtexp varchar2(2000);
    l_reqttyexp varchar2(2000);
    l_reaqttyexp varchar2(2000);
    l_reamtexp VARCHAR2 (2000);
    l_reaamtexp varchar2(2000);
    l_devidentshares varchar2(50);
    l_left_devidentshares varchar2(50);
    l_right_devidentshares varchar2(50);
    l_exprice NUMBER;
    l_roundtype NUMBER;
    l_sql clob ;
    l_count NUMBER;
    l_devidentrate varchar2(50);
    l_splitrate varchar2(50);
    l_rightoffrate varchar2(50);
    l_left_rightoffrate varchar2(50);
    l_right_rightoffrate varchar2(50);
    l_left_exrate varchar2(50);
    l_right_exrate varchar2(50);
    l_interestrate varchar2(50);
    l_interestperiod varchar2(50);
    l_codeid varchar2(6);
    l_optcodeid varchar2(6);
    l_excodeid varchar2(6);
    l_exrate varchar2(50);
    l_optsymbol varchar2(50);
    l_tocodeid varchar2(6);
     l_intamtexp VARCHAR2 (2000);

    L_ISREFCODEID varchar2(6);
    l_iswft varchar2(6);
    v_strcodeid varchar2(6);
    l_devidentvalue NUMBER;
    l_rqttyexp VARCHAR2(2000);
    l_TYPERATE CHAR(1);

    l_cashround NUMBER ;
    l_ciroundtype NUMBER ;
    l_tradeSumByCustCD NUMBER;
    l_dbl_qttyexp NUMBER;
    l_dbl_aqttyexp NUMBER;
    l_dbl_amtexp NUMBER;
    l_dbl_aamtexp NUMBER;
    l_dbl_reqttyexp NUMBER;
    l_dbl_reaqttyexp NUMBER;
    l_dbl_reamtexp NUMBER;
    l_dbl_reaamtexp NUMBER;
    l_dbl_left_rightoffrate  NUMBER;
    l_dbl_right_rightoffrate NUMBER;
    l_dbl_left_devidentshares  NUMBER;
    l_dbl_right_devidentshares NUMBER;
    l_dbl_left_exrate NUMBER;
    l_dbl_right_exrate NUMBER;
    l_dbl_intamtexp NUMBER;
    l_dbl_rqttyexp NUMBER;
    l_parvalue NUMBER;
    l_round Varchar2(2000);
    l_count_temp NUMBER;
    l_dbl_retailbalexp NUMBER;
    l_afacctno VARCHAR2(10);
    l_balance NUMBER;
    l_pqtty NUMBER;
    L_FDATEOTC DATE;
    L_TDATEOTC DATE;
    L_DAYOFYEAR NUMBER;
    L_INTERESTRATE_OTC NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_camastid:= p_txmsg.txfields('03').value;
    l_reportdate:= TO_DATE(p_txmsg.txfields('06').value,systemnums.C_DATE_FORMAT);
    --- l_actiondate:= TO_DATE(p_txmsg.txfields('07').value,systemnums.C_DATE_FORMAT);
    IF p_txmsg.deltd <> 'Y' THEN -- NORMAL TRANSACTION
        -- update parvalue trong camast
        UPDATE camast SET parvalue=
          (SELECT se.parvalue FROM sbsecurities se, camast ca WHERE  camastid=l_camastid AND se.codeid=ca.codeid)
         WHERE camastid=l_camastid;
        -- Xoa du lieu cu.
        UPDATE caschd SET deltd = 'Y' WHERE camastid = l_camastid;
        -- Tao du lieu moi.
        IF length(l_camastid) > 0 THEN
            -- Lay thong tin dot thuc hien quyen.
            FOR camast_rec IN
            (
                SELECT * from camast WHERE camastid = l_camastid
            )
            LOOP
                -- Lay truong thong tin dot thuc hien quyen ve.
                l_catype:= camast_rec.catype;
                l_devidentshares:= camast_rec.DEVIDENTSHARES;
                l_left_devidentshares:= substr(l_devidentshares,0,instr(l_devidentshares,'/') - 1);
                l_right_devidentshares:= substr(l_devidentshares,instr(l_devidentshares,'/') + 1,length(l_devidentshares));
                l_exprice:=camast_rec.EXPRICE;
                l_devidentrate:= camast_rec.DEVIDENTRATE;
                l_splitrate:= camast_rec.SPLITRATE;
                l_rightoffrate := camast_rec.RIGHTOFFRATE;
                l_left_rightoffrate := substr(l_rightoffrate,0,instr(l_rightoffrate,'/') - 1);
                l_right_rightoffrate := substr(l_rightoffrate,instr(l_rightoffrate,'/') + 1,length(l_rightoffrate));
                l_exrate := camast_rec.EXRATE;
                l_left_exrate := substr(l_exrate,0,instr(l_exrate,'/') - 1);
                l_right_exrate := substr(l_exrate,instr(l_exrate,'/') + 1,length(l_exrate));
                l_interestrate:= camast_rec.INTERESTRATE;
                l_interestperiod:= camast_rec.INTERESTPERIOD;
                l_codeid:= camast_rec.codeid;
                l_excodeid:= camast_rec.excodeid;
                l_optsymbol:= camast_rec.OPTSYMBOL;
                l_tocodeid:= camast_rec.TOCODEID;
                l_roundtype:= nvl(camast_rec.ROUNDTYPE,0);
                l_ciroundtype:= nvl(camast_rec.CIROUNDTYPE,0);
                l_cashround:= nvl(camast_rec.CASHROUND,0);
                l_devidentvalue:= camast_rec.devidentvalue; -- PhuongHT add for the case in devident by value of ct bang tien
                l_TYPERATE:=camast_rec.typerate;
                l_dbl_left_devidentshares:= to_number(l_left_devidentshares);
                l_dbl_right_devidentshares:= to_number(l_right_devidentshares);

                l_dbl_left_rightoffrate:= to_number(l_left_rightoffrate);
                l_dbl_right_rightoffrate:= to_number(l_right_rightoffrate);

                l_dbl_left_exrate:= to_number(l_left_exrate);
                l_dbl_right_exrate:= to_number(l_right_exrate);
                l_parvalue:=camast_rec.parvalue;

                L_FDATEOTC := camast_rec.FDATEOTC;
                L_TDATEOTC := camast_rec.TDATEOTC;
                L_DAYOFYEAR := camast_rec.dayofyear;

                SELECT ( (tdateotc-fdateotc+1)*interestrate) INTO L_INTERESTRATE_OTC FROM CAMAST WHERE CAMASTID =camast_rec.CAMASTID;

                IF l_catype IN ( '014','011','021') THEN
                    SELECT '9' || lpad(MAX (nvl(odr,0)) + 1,5,'0') INTO l_optcodeid
                    FROM     (SELECT   ROWNUM odr, invacct
                                FROM   (  SELECT   invacct
                                            FROM   (  SELECT   codeid invacct
                                                        FROM sbsecurities
                                                        WHERE substr(codeid,1,1)=9
                                                        UNION ALL
                                                      SELECT '900001'
                                                        FROM dual)
                                        ORDER BY   invacct) dat
                    WHERE   substr(invacct,2,5) = ROWNUM) invtab;
                END IF;

                l_qttyexp:= '0';
                l_amtexp := '0';
                l_aqttyexp := '0';
                l_aamtexp := '0';
                l_reqttyexp := '0';
                l_reaqttyexp := '0';
                l_intamtexp := '0';
                l_rqttyexp:='0';
                L_ROUND:='0';

                l_dbl_qttyexp:= 0;
                l_dbl_amtexp := 0;
                l_dbl_aqttyexp := 0;
                l_dbl_aamtexp := 0;
                l_dbl_reqttyexp := 0;
                l_dbl_reaqttyexp := 0;
                l_dbl_intamtexp := 0;
                l_dbl_rqttyexp:= 0;
                l_dbl_retailbalexp:=0;

            -- Tinh gia tri chung khoan cho quyen ve.
                IF l_catype = '009' THEN --gc_CA_CATYPE_KIND_DIVIDEND  'Kind dividend
                    l_qttyexp := 'FLOOR(((SUM(MST.TRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ')/' || l_left_devidentshares || ')';
                    l_amtexp := '(' || l_exprice || '*MOD((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE +MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' ,' || l_left_devidentshares || '))/' || l_left_devidentshares;
                     L_ROUND:= ' (CASE WHEN ( MOD((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' ,' || l_left_devidentshares || '))> 0 THEN 1 ELSE 0 END) ';
                     ELSIF l_catype = '010' THEN --gc_CA_CATYPE_CASH_DIVIDEND 'Cash dividend(+QTTY,AMT)
                      if(l_TYPERATE= 'R') THEN
                    l_amtexp := '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/100*' || l_devidentrate;
                    ELSE
                      l_amtexp := '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_devidentvalue;
                      END IF;
                    l_roundtype :=0;
                      L_ROUND:= ' (CASE WHEN (FLOOR( '|| l_amtexp  || ' ) <> '|| l_amtexp || ' ) THEN 1 ELSE 0 END)';
                ELSIF l_catype = '024' THEN --gc_CA_CATYPE_PAYING_INTERREST_BOND
                    l_amtexp := '(SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/100*' || l_devidentrate;
                    l_roundtype := 0;
                ELSIF l_catype = '011' THEN --gc_CA_CATYPE_STOCK_DIVIDEND 'Stock dividend (+QTTY,AMT)
                    l_qttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ')/' || l_left_devidentshares || ')';
                    l_amtexp:= '(' || l_exprice || '* TRUNC( MOD((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' ,' || l_left_devidentshares || ')/' || l_left_devidentshares||',' || l_ciroundtype|| '))';
                      L_ROUND:= ' (CASE WHEN (((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' / ' || l_left_devidentshares || ')- '
                                || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' / ' || l_left_devidentshares || ', '||L_ROUNDTYPE ||' ))> 0 THEN 1 ELSE 0 END) ';
                ELSIF l_catype = '025' THEN --gc_CA_CATYPE_PRINCIPLE_BOND
                    l_amtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_exprice;
                    l_aamtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';

             ELSIF l_catype = '021' THEN --gc_CA_CATYPE_KIND_STOCK

                    l_qttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ')/' || l_left_exrate || ')';
                    l_amtexp:= '(' || l_exprice || ' * TRUNC( MOD((SUM(MST.TRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' ,' || l_left_exrate || ')/' || l_left_exrate||', '|| l_ciroundtype ||'))';
                       L_ROUND:= ' (CASE WHEN (((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ')- '
                                || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ', '||L_ROUNDTYPE ||' ))> 0 THEN 1 ELSE 0 END) ';

              ELSIF l_catype = '020' THEN --gc_CA_CATYPE_CONVERT_STOCK
                    l_qttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ')/' || l_left_devidentshares || ')';
                    l_aqttyexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';
                    l_amtexp:= '(' || l_exprice || '* TRUNC( MOD((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' ,' || l_left_devidentshares || ')/' || l_left_devidentshares||',' || l_ciroundtype|| '))';
                     L_ROUND:= ' (CASE WHEN (((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' / ' || l_left_devidentshares || ')- '
                                || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' / ' || l_left_devidentshares || ', '||L_ROUNDTYPE ||' ))> 0 THEN 1 ELSE 0 END) ';

                    ELSIF l_catype = '022' THEN --gc_CA_CATYPE_CASH_DIVIDEND 'Cash dividend(+QTTY,AMT)
                    l_qttyexp := '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';
                    L_ROUND:= ' (CASE WHEN ( MOD((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ' ,' || l_left_devidentshares || '))> 0 THEN 1 ELSE 0 END) ';

                l_rqttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ')/' || l_left_devidentshares || ')';
                ELSIF l_catype = '012' THEN --gc_CA_CATYPE_STOCK_SPLIT 'Stock Split(+ QTTY,AMT)
                    l_qttyexp:= 'TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) / (' || l_splitrate || ') - '
                                   || '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)), ' || l_roundtype || ')';
                    l_amtexp:= l_exprice || '*((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) / (' || l_splitrate || ') - '
                                             || '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) - '
                                             || l_qttyexp || ')';

                ELSIF l_catype = '013' THEN --gc_CA_CATYPE_STOCK_MERGE 'Stock Merge(-AQTTY,+AMT)
                    l_aqttyexp:='((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) - '
                                    || 'TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) / (' || l_splitrate || '), ' || l_roundtype || '))';
                    l_aamtexp:= l_exprice || '*( ' || l_aqttyexp || ' - ((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) - '
                                    || '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) / (' || l_splitrate || ')))';

                   -- PhuongHT edit
                    l_amtexp:= l_exprice || '*( ' || l_aqttyexp || ' - ((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) - '
                                    || '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT)) / (' || l_splitrate || ')))';

                   -- end of PhuongHT edit
                ELSIF l_catype = '014' THEN --gc_CA_CATYPE_STOCK_RIGHTOFF 'Stock Rightoff(+QTTY,-AAMT)
                    l_qttyexp:='FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_rightoffrate ||'*'|| l_right_exrate || ')/(' || l_left_rightoffrate || '*'|| l_left_exrate ||'))';
                    l_aamtexp:= l_exprice || ' * TRUNC( FLOOR((( SUM(MST.TRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_rightoffrate ||'*'|| l_right_exrate|| ')/(' || l_left_rightoffrate || '*'|| l_left_exrate ||')), ' || l_roundtype || ')';
                    L_ROUND:= ' (CASE WHEN (((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ')- '
                                || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate ||', '||L_ROUNDTYPE ||' ))> 0 THEN 1 ELSE 0 END) ';
               ELSIF l_catype = '023' THEN -- chuyen doi TP-CP dk nhan tien
                     -- sl CP dc nhan= dk nhan max: PQTTY
                    l_qttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ')/' || l_left_exrate || ')';
                    -- sl trai phieu bi cat o tk goc
                    l_aqttyexp:= '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';
                    -- sl tien du tinh nhan
                    l_amtexp:= '(' || l_parvalue || '* (1+ ' || l_interestrate||'/100) * (SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))) ';
                    -- co lam tron khong
                     L_ROUND:= ' (CASE WHEN (((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ')- '
                                || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ', '||L_ROUNDTYPE ||' ))> 0 THEN 1 ELSE 0 END) ';

                      -- PhuongHT: ghi nhan rieng phan lai
                      l_intamtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100)*' || l_interestrate ;

                ELSIF l_catype = '015' THEN --gc_CA_CATYPE_BOND_PAY_INTEREST 'Bond pay interest, Lai suat theo thang, chu ky theo nam (+AMT)
                    l_amtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100)*' || l_interestrate ;
                    l_roundtype := 0;
                     L_ROUND:= ' (CASE WHEN (FLOOR( '|| l_amtexp  || ') ) <> '|| l_amtexp || ' THEN 1 ELSE 0 END)';
                    -- amt=intamt
                    l_intamtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100)*' || l_interestrate ;

                ELSIF l_catype = '027' THEN --gc_CA_CATYPE_BOND_PAY_INTEREST 'Bond pay interest, Lai suat theo thang, chu ky theo nam (+AMT)
                    l_amtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100)*' || L_INTERESTRATE_OTC||'/' || L_DAYOFYEAR ;
                    l_roundtype := 0;
                     L_ROUND:= ' (CASE WHEN (FLOOR( '|| l_amtexp  || ') ) <> '|| l_amtexp || ' THEN 1 ELSE 0 END)';
                    -- amt=intamt
                    l_intamtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100)*' || L_INTERESTRATE_OTC || '/' || L_DAYOFYEAR ;

                ELSIF l_catype = '016' THEN -- gc_CA_CATYPE_BOND_PAY_INTEREST_PRINCIPAL 'Bond pay interest || prin, Lai suat theo thang, chu ky theo nam (+AMT)
                    l_amtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE) + '
                                    || '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100*12)*' || l_interestrate || '*' || l_interestperiod;

                    l_amtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE) * (1+ ' || l_interestrate || ' /100 ) ';
                     -- PhuongHT: ghi nhan rieng phan lai
                      l_intamtexp:='(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*MAX(SYM.PARVALUE)/(100)*' || l_interestrate ;

                        L_ROUND:= ' (CASE WHEN (FLOOR( '|| l_amtexp  || ') ) <> '|| l_amtexp || ' THEN 1 ELSE 0 END)';
                    l_roundtype:= 0 ;
                ELSIF l_catype = '017' THEN -- gc_CA_CATYPE_CONVERT_BOND_TO_SHARE 'Convert bond to share (+QTTY Share,-AQTTY Bound)
                     l_qttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ')/' || l_left_exrate || ')';
                    l_aqttyexp:= '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';

                    l_amtexp:= '(' || l_exprice || '* TRUNC( MOD((SUM(MST.TRADE + MST.MARGIN + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' ,' || l_left_exrate || ')/' || l_left_exrate||',' || l_ciroundtype|| '))';
                      L_ROUND:= ' (CASE WHEN (((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ')- '
                                || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_exrate || ' / ' || l_left_exrate || ', '||L_ROUNDTYPE ||' ))> 0 THEN 1 ELSE 0 END) ';


                ELSIF l_catype = '018' THEN -- gc_CA_CATYPE_CONVERT_RIGHT_TO_SHARE 'Convert Right to share (+QTTY Share, -AQTTY Right)
                    l_qttyexp:= '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';
                    l_aqttyexp:= '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))';
                    l_roundtype:= 0 ;
                ELSIF l_catype = '019' THEN -- gc_CA_CATYPE_CHANGE_TRADING_PLACE_STOCK 'Change trading place (+QTTY )
                    l_qttyexp:= '0';
                    l_amtexp:='0';
                 ELSIF  l_catype IN ( '005' , '006','022') THEN
                       l_rqttyexp:= 'FLOOR(((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_right_devidentshares || ')/' || l_left_devidentshares || ')';
               --T9/2019 CW_PhaseII
                ELSIF l_catype = '028' THEN --gc_CA_CATYPE_CASH_CW 'Chi tra loi tuc CW bang tien
                      if(l_TYPERATE= 'R') THEN
                    l_amtexp := '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*'||l_exprice||'/100*' || l_devidentrate;
                    ELSE
                      l_amtexp := '(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW)-SUM(TR.AMOUNT))*' || l_devidentvalue;
                      END IF;
                    --l_roundtype :=0;
                      L_ROUND:= ' (CASE WHEN ('|| l_amtexp || ' - TRUNC( '|| l_amtexp  || ','||l_roundtype||' ) > 0  ) THEN 1 ELSE 0 END)';
                      l_amtexp:= 'TRUNC( '|| l_amtexp  || ','||l_roundtype||' )';
                --End T9/2019 CW_PhaseII

                END IF;

                -- So chung khoan le.
                l_reqttyexp:= '(' || l_qttyexp || ' - TRUNC(' || l_qttyexp || ',' || l_roundtype || '))';
                IF l_catype = '017' OR l_catype = '020' OR l_catype='023' THEN
                    l_reaqttyexp:= '(' || l_aqttyexp || ' - TRUNC(' || l_aqttyexp || ' ,' || 0 || ' ))';
                ELSE
                    l_reaqttyexp:= '(' || l_aqttyexp || ' - TRUNC(' || l_aqttyexp || ' ,' || l_roundtype || ' ))';
                END IF;
                -- So chung khoan da lam tron.
                l_qttyexp:= 'TRUNC(' || l_qttyexp || ',' || l_roundtype || ')';
                IF l_catype = '017' OR l_catype = '020' OR l_catype='023' THEN
                    l_aqttyexp:= 'TRUNC(' || l_aqttyexp || ',' || 0 || ')';
                ELSE
                    l_aqttyexp:= 'TRUNC(' || l_aqttyexp || ',' || l_roundtype || ')';
                END IF;
                IF l_catype = '011' AND l_catype = '009' THEN
                    l_amtexp:= 'ROUND(' || l_amtexp || ' + ' || l_reqttyexp || ' * ' || l_exprice || ')';
                ELSIF l_catype='023' THEN
                    l_amtexp:='ROUND(' ||l_amtexp|| ')';
                ELSE
                    l_amtexp:= l_amtexp || ' + ' || l_reqttyexp || ' * ' || l_exprice;
                END IF;
                l_aamtexp:=l_aamtexp || ' + ' || l_reaqttyexp || '*' || l_exprice;

                l_reaqttyexp :=0;
                l_reqttyexp :=0;

                plog.debug (pkgctx, 'catype ' || l_catype || ' l_cashround  ' || l_cashround || ' l_amtexp ' || l_amtexp);

/*                IF l_catype in ('010', '011', '015', '016', '017', '020', '021') THEN
                    IF l_cashround = 0 THEN
                        l_amtexp:= ROUND(l_amtexp,0);
                    ELSIF l_cashround = 1 THEN
                        l_amtexp:= CEIL(l_amtexp);
                    ELSE
                        l_amtexp:= FLOOR(l_amtexp);
                    END IF;
                END IF;*/

                -- dung truong ROUND trong CASHDTEMP de phan biet tieu khoan do co bi chot le khong


                DELETE  FROM   CASCHDTEMP;

                IF l_catype = '014' THEN
                    l_sql := 'INSERT INTO CASCHDTEMP (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,PBALANCE, PQTTY,PAAMT,TRADE,ROUND)  '
                              || ' SELECT SEQ_CASCHD.NEXTVAL,DAT.* '
                              || ' FROM(SELECT MAX(CA.CAMASTID) CAMASTID, MST.AFACCTNO, ''' || l_codeid || ''' CODEID, ''' || nvl(l_optcodeid,'''''') || ''' EXCODEID, '
                              || ' 0 BALANCE, 0  QTTY, 0 AMT, 0 AQTTY, 0 AAMT, ''A'' STATUS,' || nvl(l_reqttyexp,'''''') || '  REQTTY,' || nvl(l_reaqttyexp,'''''') || '  REAQTTY '
                              || ' ,TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))*'||l_right_exrate||'/'|| l_left_exrate||') RETAILBAL,'
                              || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))*'||l_right_exrate||'/'||l_left_exrate||') PBALANCE, '
                              || nvl(l_qttyexp,'''''') || '  PQTTY,  ROUND(' || nvl(l_aamtexp,'''''') || ',0) PAAMT,'
                              || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE +  MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))) TRADE, '|| l_round ||' ROUND'
                              || ' FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,  '
                              || ' ( SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT FROM SEMAST MST LEFT JOIN '
                              || ' (select DTL.ACCTNO, sum(DTL.AMT) amt From '
                              || ' (SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                              || ' FROM APPTX TX, SETRAN TR ,TLLOG TL '
                              || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                              || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                              || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO  '
                              || ' UNION ALL'
                              || ' SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                              || ' FROM APPTX TX, SETRANA TR ,TLLOGALL TL  '
                              || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                              || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                              || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO)DTL group by DTL.acctno) DTL ON MST.ACCTNO=DTL.ACCTNO) TR '
                              || ' WHERE MST.CODEID=SYM.CODEID AND  CA.CODEID IN( SYM.CODEID , SYM.REFCODEID) AND ( SYM.CODEID = ''' || l_codeid || ''' OR  SYM.REFCODEID =''' || l_codeid || ''' ) AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID =''' || l_camastid || ''''
                              || ' GROUP BY MST.AFACCTNO) DAT WHERE DAT.TRADE>0';

                ELSIF l_catype = '022' THEN
                    l_sql := 'INSERT INTO CASCHDTEMP (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,RQTTY,round)  '
                             || ' SELECT SEQ_CASCHD.NEXTVAL,DAT.* '
                             || ' FROM(SELECT MAX(CA.CAMASTID) CAMASTID, MST.AFACCTNO, ''' || l_codeid || ''' CODEID, MAX(CA.EXCODEID) EXCODEID, '
                             || ' (SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT)) BALANCE, '
                             ||  ' 0  QTTY, ROUND(' || nvl(l_amtexp,'''''') || ',0) AMT, 0 AQTTY, ROUND(' || nvl(l_aamtexp,'''''') || ',0) AAMT, ''A'' STATUS,' || nvl(l_reqttyexp,'''''') || '  REQTTY,' || nvl(l_reaqttyexp,'''''') || '  REAQTTY '
                             || ' , 0  RETAILBAL,  '
                              || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))) TRADE, ROUND(' || nvl(l_rqttyexp,'''''') || ',0) RQTTY, '|| l_round ||' ROUND'
                             || ' FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,  '
                             || ' (SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT FROM SEMAST MST LEFT JOIN '
                             || ' (select DTL.ACCTNO, sum(DTL.AMT) amt From '
                             || ' (SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRAN TR ,TLLOG TL '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''MARGIN'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO  '
                             || ' UNION ALL  '
                             || ' SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRANA TR ,TLLOGALL TL  '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''MARGIN'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO) DTL group by DTL.acctno) DTL ON MST.ACCTNO=DTL.ACCTNO) TR '
                             || ' WHERE  MST.CODEID=SYM.CODEID AND CA.CODEID IN( SYM.CODEID , SYM.REFCODEID) AND ( SYM.CODEID = ''' || l_codeid || ''' OR  SYM.REFCODEID =''' || l_codeid || ''' ) AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID  =''' || l_camastid || ''''
                             || ' GROUP BY MST.AFACCTNO) DAT WHERE DAT.BALANCE>0';
                ELSIF l_catype = '020' THEN
                     l_sql := 'INSERT INTO CASCHDTEMP (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,ROUND)  '
                             || ' SELECT SEQ_CASCHD.NEXTVAL,DAT.* '
                             || ' FROM(SELECT MAX(CA.CAMASTID) CAMASTID, MST.AFACCTNO, ''' || l_codeid || ''' CODEID, MAX(CA.CODEID) EXCODEID, '
                             || ' (SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT)) BALANCE, '
                             || nvl(l_qttyexp,'''''') || '  QTTY,
                                case when ' || l_catype || ' in (''010'', ''011'', ''015'', ''016'', ''017'', ''020'', ''021'')  then
                                    case when ' || l_cashround || ' = 0 then ROUND(' || nvl(l_amtexp,'''''') || ',0)
                                         when ' || l_cashround || ' = 1 then CEIL(' || nvl(l_amtexp,'''''') || ')
                                         else FLOOR(' || nvl(l_amtexp,'''''') || ')
                                     end
                                else
                                    ROUND(' || nvl(l_amtexp,'''''') || ',0)
                                end
                             AMT, ' || nvl(l_aqttyexp,'''''') || ' AQTTY, ROUND(' || nvl(l_aamtexp,'''''') || ',0) AAMT, ''A'' STATUS,' || nvl(l_reqttyexp,'''''') || '  REQTTY,' || nvl(l_reaqttyexp,'''''') || '  REAQTTY '
                             || ' , 0  RETAILBAL,  '
                              || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))) TRADE, '|| l_round ||' ROUND'
                             || ' FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,  '
                             || ' (SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT FROM SEMAST MST LEFT JOIN '
                             || ' (select DTL.ACCTNO, sum(DTL.AMT) amt From '
                             || ' (SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRAN TR ,TLLOG TL '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''MARGIN'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO  '
                             || ' UNION ALL  '
                             || ' SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRANA TR ,TLLOGALL TL  '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''MARGIN'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO) DTL group by DTL.acctno) DTL ON MST.ACCTNO=DTL.ACCTNO) TR '
                             || ' WHERE  MST.CODEID=SYM.CODEID AND CA.CODEID IN( SYM.CODEID , SYM.REFCODEID) AND ( SYM.CODEID = ''' || l_codeid || ''' OR  SYM.REFCODEID =''' || l_codeid || ''' ) AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID  =''' || l_camastid || ''''
                             || ' GROUP BY MST.AFACCTNO) DAT WHERE DAT.BALANCE>0';
                ELSIF l_catype = '017' THEN
                    l_sql := 'INSERT INTO CASCHDTEMP (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,ROUND)  '
                             || ' SELECT SEQ_CASCHD.NEXTVAL,DAT.* '
                             || ' FROM(SELECT MAX(CA.CAMASTID) CAMASTID, MST.AFACCTNO, ''' || l_codeid || ''' CODEID, MAX(CA.CODEID) EXCODEID, '
                             || ' (SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT)) BALANCE, '
                             || nvl(l_qttyexp,'''''') || '  QTTY,
                                 case when ' || l_catype || ' in (''010'', ''011'', ''015'', ''016'', ''017'', ''020'', ''021'')  then
                                    case when ' || l_cashround || ' = 0 then ROUND(' || nvl(l_amtexp,'''''') || ',0)
                                         when ' || l_cashround || ' = 1 then CEIL(' || nvl(l_amtexp,'''''') || ')
                                         else FLOOR(' || nvl(l_amtexp,'''''') || ')
                                     end
                                 else
                                    ROUND(' || nvl(l_amtexp,'''''') || ',0)
                                 end
                             AMT, ' || nvl(l_aqttyexp,'''''') || ' AQTTY, ROUND(' || nvl(l_aamtexp,'''''') || ',0) AAMT, ''A'' STATUS,' || nvl(l_reqttyexp,'''''') || '  REQTTY,' || nvl(l_reaqttyexp,'''''') || '  REAQTTY '
                             || ' , 0  RETAILBAL , '
                              || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))) TRADE, '|| l_round ||' ROUND'
                             || ' FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,  '
                             || ' (SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT FROM SEMAST MST LEFT JOIN '
                             || ' (select DTL.ACCTNO, sum(DTL.AMT) amt From '
                             || ' (SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRAN TR ,TLLOG TL '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''WTRADE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO  '
                             || ' UNION ALL  '
                             || ' SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRANA TR ,TLLOGALL TL  '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''WTRADE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO) DTL group by DTL.acctno) DTL ON MST.ACCTNO=DTL.ACCTNO) TR '
                             || ' WHERE  MST.CODEID=SYM.CODEID AND  CA.CODEID IN( SYM.CODEID , SYM.REFCODEID) AND ( SYM.CODEID = ''' || l_codeid || ''' OR  SYM.REFCODEID =''' || l_codeid || ''' ) AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID  =''' || l_camastid || ''''
                             || ' GROUP BY MST.AFACCTNO) DAT WHERE DAT.BALANCE>0';
                  ELSIF l_catype = '023' THEN
                    l_sql := 'INSERT INTO CASCHDTEMP (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,ROUND,PQTTY,INTAMT)  '
                             || ' SELECT SEQ_CASCHD.NEXTVAL,DAT.* '
                             || ' FROM(SELECT MAX(CA.CAMASTID) CAMASTID, MST.AFACCTNO, ''' || l_codeid || ''' CODEID, MAX(CA.CODEID) EXCODEID, '
                             || ' (SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT)) BALANCE,
                              0  QTTY, ROUND(' || nvl(l_amtexp,'''''') || ',0) AMT, ' || nvl(l_aqttyexp,'''''') || ' AQTTY, ROUND(' || nvl(l_aamtexp,'''''') || ',0) AAMT, ''A'' STATUS,' || nvl(l_reqttyexp,'''''') || '  REQTTY,' || nvl(l_reaqttyexp,'''''') || '  REAQTTY '
                             || ' , 0  RETAILBAL , '
                             || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))) TRADE, '|| l_round ||' ROUND, ' || nvl(l_qttyexp,'''''') || ' PQTTY , '
                             || ' ROUND(' || nvl(l_intamtexp,'''''') || ',0) INTAMT '
                             || ' FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,  '
                             || ' (SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT FROM SEMAST MST LEFT JOIN '
                             || ' (select DTL.ACCTNO, sum(DTL.AMT) amt From '
                             || ' (SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRAN TR ,TLLOG TL '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''WTRADE'',''MORTAGE'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO  '
                             || ' UNION ALL  '
                             || ' SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRANA TR ,TLLOGALL TL  '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO) DTL group by DTL.acctno) DTL ON MST.ACCTNO=DTL.ACCTNO) TR '
                             || ' WHERE  MST.CODEID=SYM.CODEID AND  CA.CODEID IN( SYM.CODEID , SYM.REFCODEID) AND ( SYM.CODEID = ''' || l_codeid || ''' OR  SYM.REFCODEID =''' || l_codeid || ''' ) AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID  =''' || l_camastid || ''''
                             || ' GROUP BY MST.AFACCTNO) DAT WHERE DAT.BALANCE>0';

                ELSE
                    l_sql := 'INSERT INTO CASCHDTEMP (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,INTAMT,RQTTY,ROUND)  '
                             || ' SELECT SEQ_CASCHD.NEXTVAL,DAT.* '
                             || ' FROM(SELECT MAX(CA.CAMASTID) CAMASTID, MST.AFACCTNO,''' || l_codeid || ''' CODEID, MAX(CA.EXCODEID) EXCODEID, '
                             || ' (SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.MORTAGE + MST.BLOCKED + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT)) BALANCE, '
                             || nvl(l_qttyexp,'''''') || '  QTTY,
                                case when ' || l_catype || ' in (''010'', ''011'', ''015'', ''016'', ''017'', ''020'', ''021'')  then
                                    case when ' || l_cashround || ' = 0 then ROUND(' || nvl(l_amtexp,'''''') || ',0)
                                         when ' || l_cashround || ' = 1 then CEIL(' || nvl(l_amtexp,'''''') || ')
                                         else FLOOR(' || nvl(l_amtexp,'''''') || ')
                                     end
                                 else
                                    ROUND(' || nvl(l_amtexp,'''''') || ',0)
                                 end
                             AMT, ' || nvl(l_aqttyexp,'''''') || ' AQTTY, ROUND(' || nvl(l_aamtexp,'''''') || ',0) AAMT, ''A'' STATUS,' || nvl(l_reqttyexp,'''''') || '  REQTTY,' || nvl(l_reaqttyexp,'''''') || '  REAQTTY '
                             || ' , 0  RETAILBAL,  '
                              || ' TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.BLOCKED + MST.SECURED +MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))) TRADE, ROUND(' || nvl(l_intamtexp,'''''') || ',0) INTAMT, ROUND(' || nvl(l_rqttyexp,'''''') || ',0) RQTTY, '|| l_round ||' ROUND'
                             || ' FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,  '
                             || ' (SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT FROM SEMAST MST LEFT JOIN '
                             || ' (select DTL.ACCTNO, sum(DTL.AMT) amt From '
                             || ' (SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRAN TR ,TLLOG TL '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO  '
                             || ' UNION ALL  '
                             || ' SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE=''D'' THEN -TR.NAMT WHEN TX.TXTYPE=''C'' THEN TR.NAMT ELSE 0 END)) AMT  '
                             || ' FROM APPTX TX, SETRANA TR ,TLLOGALL TL  '
                             || ' WHERE TX.APPTYPE=''SE'' AND TRIM(TX.FIELD) IN (''TRADE'',''MARGIN'',''BLOCKWITHDRAW'',''EMKQTTY'',''BLOCKDTOCLOSE'',''WTRADE'',''MORTAGE'',''BLOCKED'',''SECURED'',''REPO'',''NETTING'',''DTOCLOSE'',''WITHDRAW'')  '
                             || ' AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN (''C'', ''D'') AND TL.DELTD <> ''Y'' '
                             || ' AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(''' || to_char(l_reportdate,systemnums.c_date_format) || ''', ''DD/MM/RRRR'') GROUP BY TR.ACCTNO) DTL group by DTL.acctno) DTL ON MST.ACCTNO=DTL.ACCTNO) TR '
                             || ' WHERE  MST.CODEID=SYM.CODEID AND  CA.CODEID IN( SYM.CODEID , SYM.REFCODEID) AND ( SYM.CODEID = ''' || l_codeid || ''' OR  SYM.REFCODEID =''' || l_codeid || ''' ) AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID  =''' || l_camastid || ''''
                             || ' GROUP BY MST.AFACCTNO) DAT WHERE DAT.BALANCE>0';
                END IF;
                --Tao du lieu cho caschd
             /*   plog.error (pkgctx,'3375EX: ' || substr(l_sql,0,1500) );
                plog.error (pkgctx,'3375EX: ' || substr(l_sql,1501,1500) );
                plog.error (pkgctx,'3375EX: ' || substr(l_sql,3002,LENGTH(l_sql)) );*/
                plog.error (pkgctx,'3375EX: ' ||LENGTH(l_sql) );

                EXECUTE IMMEDIATE l_sql;
                pr_error ('Gianhvg 3375ex','Insert vao caschdtemp');

                DELETE  FROM   caschdtempGRP;
                INSERT INTO caschdtempGRP (AUTOID,CAMASTID,BALANCE,QTTY,AMT,AQTTY,AAMT,STATUS,AFACCTNO,CODEID,EXCODEID,DELTD,PSTATUS,REFCAMASTID,RETAILSHARE,DEPOSIT,REQTTY,REAQTTY,RETAILBAL,PBALANCE,PQTTY,PAAMT,COREBANK,ISCISE,DFQTTY,ISCI,ISSE,ISRO,TQTTY,TRADE,INBALANCE,OUTBALANCE,PITRATEMETHOD,ISEXEC,NMQTTY,DFAMT,INTAMT,RQTTY,ROUND)
                SELECT MAX( AUTOID) AUTOID,CAMASTID,SUM(BALANCE) BALANCE,SUM(QTTY) QTTY,SUM(AMT) AMT,SUM(AQTTY) AQTTY,SUM(AAMT) AAMT,MAX(CA.STATUS) STATUS
                ,MAX(AF.ACCTNO) AFACCTNO--,MAX(AF1.AFACCTNO) AFACCTNO --TramNN 04/07/2021 CK o tieu khoan nao thi chot tren tieu khoan ay
                ,MAX(CODEID) CODEID,MAX(EXCODEID) EXCODEID, MAX(CA.DELTD) DELTD, MAX(CA.PSTATUS) PSTATUS, MAX(REFCAMASTID) REFCAMASTID,
                MAX(RETAILSHARE) RETAILSHARE,MAX(DEPOSIT) DEPOSIT,SUM(REQTTY) REQTTY,SUM(REAQTTY) REAQTTY,SUM(RETAILBAL) RETAILBAL,SUM(PBALANCE) PBALANCE
                ,SUM(PQTTY) PQTTY,SUM(PAAMT) PAAMT,MAX(CA.COREBANK) COREBANK, MAX(ISCISE) ISCISE,SUM(DFQTTY) DFQTTY ,MAX(ISCI) ISCI,MAX(ISSE) ISSE,MAX(ISRO) ISRO
                ,SUM(TQTTY) TQTTY,SUM(TRADE) TRADE,SUM(INBALANCE) INBALANCE,SUM(OUTBALANCE) OUTBALANCE,MAX(PITRATEMETHOD) PITRATEMETHOD,MAX(ISEXEC)ISEXEC
                ,SUM(NMQTTY) NMQTTY,SUM(DFAMT) DFAMT, SUM(INTAMT)INTAMT,SUM(RQTTY) RQTTY,MAX(ROUND)
                FROM CASCHDTEMP CA, AFMAST AF ,
                (SELECT MAX(ACCTNO) AFACCTNO, CUSTID FROM   AFMAST  AF,AFTYPE AFT, MRTYPE MR WHERE AF.ACTYPE = AFT.ACTYPE AND AFT.MRTYPE = MR.ACTYPE /*AND MR.MRTYPE ='N'*/ AND CUSTID <>'0001540677' AND af.status not in ('C','N') GROUP BY CUSTID) AF1
                WHERE  CA.AFACCTNO =AF.ACCTNO
                AND AF.CUSTID= AF1.CUSTID
                AND af.status not in ('C','N') --TramNN 23/02/2021 FLEXTCSC-753 khong lay tieu khoan dong
                GROUP BY CAMASTID,AF.ACCTNO; --AF.CUSTID --TramNN 04/07/2021 CK o tieu khoan nao thi chot tren tieu khoan ay

                --Insert nhung khach hang co mot tieu khoan
                insert into caschd (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,PBALANCE,PQTTY,PAAMT,INTAMT,RQTTY)
                select tmp.AUTOID, tmp.CAMASTID, tmp.AFACCTNO, tmp.CODEID, tmp.EXCODEID, tmp.BALANCE, tmp.QTTY, tmp.AMT,
                       tmp.AQTTY, tmp.AAMT, tmp.STATUS,tmp.REQTTY,tmp.REAQTTY,tmp.RETAILBAL,tmp.TRADE,tmp.PBALANCE,
                       tmp.PQTTY,tmp.PAAMT,tmp.INTAMT,tmp.RQTTY
                from caschdtempGRP tmp,
                    (select cf.custid, max(af.acctno) afacctno from afmast af, cfmast cf
                        where af.custid = cf.custid
                            AND cf.custatcom='Y'
                        group by cf.custid
                        having count(af.acctno)<=1
                    ) af
                where tmp.afacctno = af.afacctno
                AND tmp.camastid=l_camastid;
                --ADD by VuTN
                --insert log de phan biet ck thuong va ck hccn
                if l_catype = '014' then
                    insert into CASCHD_LOG(CAMASTID,CODEID,AFACCTNO,TRADE,PTRADE,BLOCKED,PBLOCKED)
                    SELECT DAT.CAMASTID, DAT.CODEID, AF1.AFACCTNO,
                    TRUNC(SUM(DAT.TRADE)*(l_right_exrate/ l_left_exrate)) TRADE,
                    TRUNC(SUM(DAT.TRADE)*(l_right_rightoffrate / l_left_rightoffrate)) PTRADE,
                    TRUNC(SUM(DAT.TRADE+DAT.BLOCKED)*(l_right_exrate/ l_left_exrate) - TRUNC(SUM(DAT.TRADE)*(l_right_exrate/ l_left_exrate))) BLOCKED,
                    TRUNC(SUM(DAT.TRADE+DAT.BLOCKED)*(l_right_rightoffrate / l_left_rightoffrate) - TRUNC(SUM(DAT.TRADE)*(l_right_rightoffrate / l_left_rightoffrate))) PBLOCKED
                     FROM(
                         SELECT MAX(CA.CAMASTID) CAMASTID,L_CODEID CODEID, MST.AFACCTNO,
                         TRUNC(SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.EMKQTTY + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT)) TRADE,
                         --TRUNC((SUM(MST.TRADE + MST.MARGIN + MST.WTRADE  + MST.MORTAGE + MST.EMKQTTY + MST.SECURED + MST.REPO+ MST.NETTING+ MST.DTOCLOSE+MST.WITHDRAW) - SUM(TR.AMOUNT))*(l_right_rightoffrate / l_left_rightoffrate)) PTRADE,
                         TRUNC(SUM(MST.BLOCKED + MST.BLOCKWITHDRAW + MST.BLOCKDTOCLOSE) - SUM(TR.BLOCKED)) BLOCKED
                         --TRUNC((SUM(MST.BLOCKED + MST.BLOCKWITHDRAW + MST.BLOCKDTOCLOSE) - SUM(TR.BLOCKED))*(l_right_rightoffrate / l_left_rightoffrate)) PBLOCKED
                         FROM SBSECURITIES SYM, CAMAST CA, SEMAST MST,
                         (
                             SELECT MST.ACCTNO, NVL(DTL.AMT,0) AMOUNT , NVL(DTL.BLO,0) BLOCKED
                             FROM SEMAST MST LEFT JOIN
                             (
                                 SELECT DTL.ACCTNO, SUM(DTL.AMT) AMT, SUM(DTL.BLO) BLO FROM
                                 (
                                    SELECT TR.ACCTNO,
                                    SUM((CASE WHEN TX.TXTYPE='D' THEN -TR.NAMT WHEN TX.TXTYPE='C' THEN TR.NAMT ELSE 0 END)) AMT, 0 BLO
                                    FROM APPTX TX, SETRAN TR ,TLLOG TL
                                    WHERE TX.APPTYPE='SE' AND TRIM(TX.FIELD) IN ('TRADE','MARGIN','EMKQTTY','WTRADE','MORTAGE','SECURED','REPO','NETTING','DTOCLOSE','WITHDRAW')
                                    AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN ('C', 'D') AND TL.DELTD <> 'Y'
                                    AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(L_REPORTDATE,SYSTEMNUMS.C_DATE_FORMAT)
                                    GROUP BY TR.ACCTNO
                                    UNION ALL
                                    SELECT TR.ACCTNO, 0 AMT,
                                    SUM((CASE WHEN TX.TXTYPE='D' THEN -TR.NAMT WHEN TX.TXTYPE='C' THEN TR.NAMT ELSE 0 END)) BLO
                                    FROM APPTX TX, SETRAN TR ,TLLOG TL
                                    WHERE TX.APPTYPE='SE' AND TRIM(TX.FIELD) IN ('BLOCKED','BLOCKWITHDRAW','BLOCKDTOCLOSE')
                                    AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN ('C', 'D') AND TL.DELTD <> 'Y'
                                    AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(L_REPORTDATE,SYSTEMNUMS.C_DATE_FORMAT)
                                    GROUP BY TR.ACCTNO
                                    UNION ALL
                                    SELECT TR.ACCTNO, SUM((CASE WHEN TX.TXTYPE='D' THEN -TR.NAMT WHEN TX.TXTYPE='C' THEN TR.NAMT ELSE 0 END)) AMT, 0 BLO
                                    FROM APPTX TX, SETRANA TR ,TLLOGALL TL
                                    WHERE TX.APPTYPE='SE' AND TRIM(TX.FIELD) IN ('TRADE','MARGIN','EMKQTTY','WTRADE','MORTAGE','SECURED','REPO','NETTING','DTOCLOSE','WITHDRAW')
                                    AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN ('C', 'D') AND TL.DELTD <> 'Y'
                                    AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(L_REPORTDATE,SYSTEMNUMS.C_DATE_FORMAT)
                                    GROUP BY TR.ACCTNO
                                    UNION ALL
                                    SELECT TR.ACCTNO, 0 AMT,
                                    SUM((CASE WHEN TX.TXTYPE='D' THEN -TR.NAMT WHEN TX.TXTYPE='C' THEN TR.NAMT ELSE 0 END)) BLO
                                    FROM APPTX TX, SETRANA TR ,TLLOGALL TL
                                    WHERE TX.APPTYPE='SE' AND TRIM(TX.FIELD) IN ('BLOCKED','BLOCKWITHDRAW','BLOCKDTOCLOSE')
                                    AND TR.TXDATE=TL.TXDATE AND TR.TXNUM=TL.TXNUM AND TX.TXTYPE IN ('C', 'D') AND TL.DELTD <> 'Y'
                                    AND TX.TXCD=TR.TXCD AND TL.BUSDATE > TO_DATE(L_REPORTDATE,SYSTEMNUMS.C_DATE_FORMAT)
                                    GROUP BY TR.ACCTNO
                                 )DTL GROUP BY DTL.ACCTNO
                             ) DTL ON MST.ACCTNO=DTL.ACCTNO
                         ) TR
                         WHERE MST.CODEID=SYM.CODEID
                         AND CA.CODEID IN( SYM.CODEID,SYM.REFCODEID)
                         AND ( SYM.CODEID = L_CODEID OR  SYM.REFCODEID = L_CODEID )
                         AND MST.ACCTNO = TR.ACCTNO  AND CA.CAMASTID = l_camastid
                         GROUP BY MST.AFACCTNO
                     ) DAT, AFMAST AF,
                     (SELECT MAX(ACCTNO) AFACCTNO, CUSTID FROM   AFMAST  AF,AFTYPE AFT, MRTYPE MR WHERE AF.ACTYPE = AFT.ACTYPE AND AFT.MRTYPE = MR.ACTYPE AND MR.MRTYPE ='N' GROUP BY CUSTID) AF1
                      WHERE DAT.TRADE + DAT.BLOCKED>0
                      AND DAT.AFACCTNO = AF.ACCTNO
                      AND AF.CUSTID = AF1.CUSTID
                      GROUP BY DAT.CAMASTID, DAT.CODEID, AF1.AFACCTNO;
                end if;
                --end ADD VuTN
                plog.debug (pkgctx,'after insert caschdtempGRP: ' );
                -- Tinh ra CK tong theo so luu ky
                FOR rec_trade IN (
                 /*  select mst.* from
                        (SELECT sum(dat.trade) tradesum, af.custid ,MAX(DAT.PARVALUE) PARVALUE
                       FROM   (SELECT SUM(MST.TRADE + MST.MARGIN + MST.WTRADE + MST.MORTAGE +
                                MST.BLOCKWITHDRAW + MST.EMKQTTY + MST.BLOCKDTOCLOSE +
                                  MST.BLOCKED + MST.SECURED + MST.REPO + MST.NETTING +
                                  MST.DTOCLOSE + MST.WITHDRAW) - SUM(TR.AMOUNT) trade,
                                  mst.afacctno,MAX(sym.parvalue) parvalue
                                  FROM semast mst,  camast ca,sbsecurities sym,
                                  (SELECT MST.ACCTNO, NVL(DTL.AMT, 0) AMOUNT
                                FROM SEMAST MST
                                LEFT JOIN (SELECT DTL.ACCTNO, SUM(DTL.AMT) amt
                                            FROM (SELECT TR.ACCTNO,
                                                          SUM((CASE
                                                                WHEN TX.TXTYPE = 'D' THEN
                                                                 -TR.NAMT
                                                                WHEN TX.TXTYPE = 'C' THEN
                                                                 TR.NAMT
                                                                ELSE
                                                                 0
                                                              END)) AMT
                                                     FROM APPTX TX, SETRAN TR, TLLOG TL
                                                    WHERE TX.APPTYPE = 'SE'
                                                      AND TRIM(TX.FIELD) IN
                                                          ('TRADE',
                                                           'MARGIN',
                                                           'WTRADE',
                                                           'MORTAGE',
                                                           'BLOCKED',
                                                           'SECURED',
                                                           'REPO',
                                                           'NETTING',
                                                           'DTOCLOSE',
                                                           'BLOCKWITHDRAW',
                                                           'EMKQTTY',
                                                           'BLOCKDTOCLOSE',
                                                           'WITHDRAW')
                                                      AND TR.TXDATE = TL.TXDATE
                                                      AND TR.TXNUM = TL.TXNUM
                                                      AND TX.TXTYPE IN ('C', 'D')
                                                      AND TL.DELTD <> 'Y'
                                                      AND TX.TXCD = TR.TXCD
                                                      AND TL.BUSDATE >
                                                         TO_DATE(l_reportdate,systemnums.c_date_format)
                                                    GROUP BY TR.ACCTNO
                                                   UNION ALL
                                                   SELECT TR.ACCTNO,
                                                          SUM((CASE
                                                                WHEN TX.TXTYPE = 'D' THEN
                                                                 -TR.NAMT
                                                                WHEN TX.TXTYPE = 'C' THEN
                                                                 TR.NAMT
                                                                ELSE
                                                                 0
                                                              END)) AMT
                                                     FROM APPTX TX, SETRANA TR, TLLOGALL TL
                                                    WHERE TX.APPTYPE = 'SE'
                                                      AND TRIM(TX.FIELD) IN
                                                          ('TRADE',
                                                           'MARGIN',
                                                           'WTRADE',
                                                           'MORTAGE',
                                                           'BLOCKED',
                                                           'SECURED',
                                                           'REPO',
                                                           'NETTING',
                                                           'DTOCLOSE',
                                                           'BLOCKWITHDRAW',
                                                           'EMKQTTY',
                                                           'BLOCKDTOCLOSE',
                                                           'WITHDRAW')
                                                      AND TR.TXDATE = TL.TXDATE
                                                      AND TR.TXNUM = TL.TXNUM
                                                      AND TX.TXTYPE IN ('C', 'D')
                                                      AND TL.DELTD <> 'Y'
                                                      AND TX.TXCD = TR.TXCD
                                                      AND TL.BUSDATE >
                                                          TO_DATE(l_reportdate,systemnums.c_date_format)
                                                    GROUP BY TR.ACCTNO) DTL
                                           GROUP BY DTL.acctno) DTL
                                  ON MST.ACCTNO = DTL.ACCTNO) TR
                                      WHERE MST.CODEID = SYM.CODEID
                                              AND CA.CODEID IN (SYM.CODEID, SYM.REFCODEID)
                                              AND (SYM.CODEID = l_codeid OR SYM.REFCODEID = l_codeid)
                                              AND MST.ACCTNO = TR.ACCTNO
                                              AND CA.CAMASTID = l_camastid
                                            GROUP BY MST.AFACCTNO) DAT, afmast af,cfmast cf
                                            WHERE dat.afacctno=af.acctno
                                             AND dat.trade>0
                                             AND af.custid=cf.custid
                                             AND cf.custatcom='Y'
                                             AND cf.status <> 'C'
                                            GROUP BY af.custid
                       ) mst,
                       (select cf.custid from afmast af, cfmast cf
                            where af.custid = cf.custid
                            group by cf.custid
                            having count(af.acctno)>1
                        ) cf
                       where mst.custid = cf.custid
                 */
                       SELECT SUM(MST.TRADE) TRADESUM, AFM.CUSTID, MAX(MST.PARVALUE) PARVALUE
                        FROM
                        (
                            SELECT MST.AFACCTNO, MST.TRADE TRADE, SB.PARVALUE
                            FROM caschdtempGRP MST, sbsecurities SB
                            WHERE MST.codeid = SB.codeid AND MST.camastid = l_camastid
                        ) MST, AFMAST AFM,
                        (
                            select cf.custid, max(af.acctno) afacctno from afmast af, cfmast cf
                            where af.custid = cf.custid
                            AND cf.custatcom='Y'
                            group by cf.custid
                            having count(af.acctno) > 1
                        )cf
                        WHERE MST.AFACCTNO = AFM.ACCTNO
                            AND AFM.CUSTID = CF.CUSTID
                        GROUP BY  AFM.CUSTID
                   )
                    LOOP

                      l_tradeSumByCustCD:=rec_trade.tradesum;
                      l_parvalue:=rec_trade.parvalue;
                      IF(l_tradeSumByCustCD >0) THEN
                    -- Tinh gia tri chung khoan cho quyen ve.
                                    IF l_catype = '009' THEN --gc_CA_CATYPE_KIND_DIVIDEND  'Kind dividend
                                        l_dbl_qttyexp := round(l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares,0 );
                                        l_dbl_amtexp := trunc(l_exprice * MOD(l_tradeSumByCustCD *l_dbl_right_devidentshares  , l_dbl_left_devidentshares )/ l_left_devidentshares);
                                    ELSIF l_catype = '010' THEN --gc_CA_CATYPE_CASH_DIVIDEND 'Cash dividend(+QTTY,AMT)
                                        if(l_TYPERATE= 'R') THEN
                                            --l_dbl_amtexp :=trunc( l_tradeSumByCustCD * l_parvalue /100* to_number(l_devidentrate),0);
                                            l_dbl_amtexp :=l_tradeSumByCustCD * l_parvalue /100* to_number(l_devidentrate);
                                        ELSE
                                            --l_dbl_amtexp := trunc( l_tradeSumByCustCD*to_number(l_devidentvalue),0);
                                            l_dbl_amtexp := l_tradeSumByCustCD*to_number(l_devidentvalue);
                                        END IF;
                                        l_roundtype :=0;
                                    ELSIF l_catype = '024' THEN --gc_CA_CATYPE_PAYING_INTERREST_BOND
                                        l_dbl_amtexp := trunc(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_devidentrate),0);
                                        l_roundtype := 0;
                                    ELSIF l_catype = '011' THEN --gc_CA_CATYPE_STOCK_DIVIDEND 'Stock dividend (+QTTY,AMT)
                                   -- plog.debug (pkgctx,'in case 011.2.1: '||  rec_trade.custid );

                                        l_dbl_qttyexp:=trunc (FLOOR( l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares ),l_roundtype);

                                        --l_dbl_amtexp:= trunc( l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares -l_dbl_qttyexp,l_ciroundtype),0);
                                        l_dbl_amtexp:= l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares -l_dbl_qttyexp,l_ciroundtype);
                                     plog.debug (pkgctx,'in case 011.2: ' ||l_dbl_qttyexp|| ' amtexp '||l_dbl_amtexp);
                                         ELSIF l_catype = '025' THEN --gc_CA_CATYPE_PRINCIPLE_BOND
                                        l_dbl_amtexp:= round (l_tradeSumByCustCD*l_exprice,0);
                                        l_dbl_aamtexp:= l_tradeSumByCustCD;
                                 ELSIF l_catype = '021' THEN --gc_CA_CATYPE_KIND_STOCK
                                        l_dbl_qttyexp:=trunc (FLOOR( l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate ),l_roundtype);
                                        plog.debug(pkgctx,rec_trade.custid||' 021so chuan: ' ||l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate|| ' so chia ' || l_dbl_qttyexp || ' round ' || l_ciroundtype);
                                        --l_dbl_amtexp:= trunc (l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate -l_dbl_qttyexp,l_ciroundtype),0);
                                        l_dbl_amtexp:= l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate -l_dbl_qttyexp,l_ciroundtype);
                                  plog.debug(pkgctx,rec_trade.custid||' 021amt: ' || l_dbl_amtexp );
                                   ELSIF l_catype = '020' THEN --gc_CA_CATYPE_CONVERT_STOCK
                                       l_dbl_aqttyexp:= l_tradeSumByCustCD;

                                  l_dbl_qttyexp:=trunc (FLOOR( l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares ),l_roundtype);
                                        --l_dbl_amtexp:= trunc( l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares -l_dbl_qttyexp,l_ciroundtype),0);
                                        l_dbl_amtexp:= l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_devidentshares / l_dbl_left_devidentshares -l_dbl_qttyexp,l_ciroundtype);

                                  ELSIF l_catype = '012' THEN --gc_CA_CATYPE_STOCK_SPLIT 'Stock Split(+ QTTY,AMT)
                                        l_dbl_qttyexp:= TRUNC( l_tradeSumByCustCD/  to_number(l_splitrate)  - l_tradeSumByCustCD, l_roundtype );
                                        l_dbl_amtexp:= trunc(l_exprice*( l_tradeSumByCustCD / to_number( l_splitrate) - l_tradeSumByCustCD -  l_dbl_qttyexp ),0);
                                    ELSIF l_catype = '013' THEN --gc_CA_CATYPE_STOCK_MERGE 'Stock Merge(-AQTTY,+AMT)
                                        l_dbl_aqttyexp:= l_tradeSumByCustCD - TRUNC( l_tradeSumByCustCD/ to_number(l_splitrate) ,  l_roundtype) ;

                                       -- PhuongHT edit
                                        l_dbl_amtexp:= trunc(l_exprice *( l_aqttyexp  - (l_tradeSumByCustCD - l_tradeSumByCustCD / to_number( l_splitrate ))));

                                       -- end of PhuongHT edit
                                    ELSIF l_catype = '014' THEN --gc_CA_CATYPE_STOCK_RIGHTOFF 'Stock Rightoff(+QTTY,-AAMT)
                                        l_dbl_qttyexp:=FLOOR((l_tradeSumByCustCD *l_dbl_right_rightoffrate * l_dbl_right_exrate )/( l_dbl_left_rightoffrate * l_dbl_left_exrate ));
                                        l_dbl_aamtexp:= round(l_exprice  * TRUNC( FLOOR((l_tradeSumByCustCD * l_dbl_right_rightoffrate * l_dbl_right_exrate)/( l_dbl_left_rightoffrate * l_dbl_left_exrate )),  l_roundtype ),0);
                                        l_dbl_RETAILBALEXP:= TRUNC(l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate);

                                    ELSIF l_catype = '015' THEN --gc_CA_CATYPE_BOND_PAY_INTEREST 'Bond pay interest, Lai suat theo thang, chu ky theo nam (+AMT)
                                        --l_dbl_amtexp:=round(l_tradeSumByCustCD * l_parvalue /100 * to_number(l_interestrate),0) ;
                                        l_dbl_amtexp:=l_tradeSumByCustCD * l_parvalue /100 * to_number(l_interestrate) ;
                                     --   l_dbl_intamtexp:=round(l_tradeSumByCustCD * l_parvalue /100 * to_number(l_interestrate),0) ;
                                        l_roundtype := 0;
                                        IF l_cashround = 0 THEN
                                            l_dbl_intamtexp:= round(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate),0) ;
                                        ELSIF l_cashround = 1 THEN
                                            l_dbl_intamtexp:= CEIL(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate)) ;
                                        ELSE
                                            l_dbl_intamtexp:= FLOOR(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate)) ;
                                        END IF;


                                    ELSIF l_catype = '027' THEN --gc_CA_CATYPE_BOND_PAY_INTEREST 'Bond pay interest, Lai suat theo thang, chu ky theo nam (+AMT)
                                        --l_dbl_amtexp:=round(l_tradeSumByCustCD * l_parvalue /100 * to_number(l_interestrate),0) ;
                                        l_dbl_amtexp:=l_tradeSumByCustCD * l_parvalue /100 * to_number( L_INTERESTRATE_OTC / L_DAYOFYEAR) ;
                                     --   l_dbl_intamtexp:=round(l_tradeSumByCustCD * l_parvalue /100 * to_number(l_interestrate),0) ;
                                        l_roundtype := 0;
                                        IF l_cashround = 0 THEN
                                            l_dbl_intamtexp:= round(l_tradeSumByCustCD * l_parvalue /100 *  to_number( L_INTERESTRATE_OTC / L_DAYOFYEAR),0) ;
                                        ELSIF l_cashround = 1 THEN
                                            l_dbl_intamtexp:= CEIL(l_tradeSumByCustCD * l_parvalue /100 *  to_number( L_INTERESTRATE_OTC / L_DAYOFYEAR)) ;
                                        ELSE
                                            l_dbl_intamtexp:= FLOOR(l_tradeSumByCustCD * l_parvalue /100 *  to_number( L_INTERESTRATE_OTC / L_DAYOFYEAR)) ;
                                        END IF;

                                    ELSIF l_catype = '016' THEN -- gc_CA_CATYPE_BOND_PAY_INTEREST_PRINCIPAL 'Bond pay interest || prin, Lai suat theo thang, chu ky theo nam (+AMT)

                                        --l_dbl_amtexp:=round ( l_tradeSumByCustCD *l_parvalue * (1+  to_number(l_interestrate)  /100 ),0) ;
                                        l_dbl_amtexp:=l_tradeSumByCustCD *l_parvalue * (1+  to_number(l_interestrate)  /100 ) ;
                                         -- PhuongHT: ghi nhan rieng phan lai
                                        --  l_dbl_intamtexp:= round(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate),0) ;

                                        IF l_cashround = 0 THEN
                                            l_dbl_intamtexp:= round(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate),0) ;
                                         ELSIF l_cashround = 1 THEN
                                            l_dbl_intamtexp:= CEIL(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate)) ;
                                         ELSE
                                            l_dbl_intamtexp:= FLOOR(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate)) ;
                                         END IF;
                                        l_roundtype:= 0 ;
                                    ELSIF l_catype = '017' THEN -- gc_CA_CATYPE_CONVERT_BOND_TO_SHARE 'Convert bond to share (+QTTY Share,-AQTTY Bound)
                                        l_dbl_aqttyexp:= l_tradeSumByCustCD;

                                        l_dbl_qttyexp:=trunc (FLOOR( l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate ),l_roundtype);
                                        --l_dbl_amtexp:= trunc( l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate -l_dbl_qttyexp,l_ciroundtype),0);
                                        l_dbl_amtexp:= l_exprice * trunc(l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate -l_dbl_qttyexp,l_ciroundtype);

                                    ELSIF l_catype = '023' THEN -- gc_CA_CATYPE_CONVERT_BOND_TO_SHARE 'Convert bond to share (+QTTY Share,-AQTTY Bound)
                                        l_dbl_aqttyexp:= l_tradeSumByCustCD;

                                        l_dbl_qttyexp:=trunc (FLOOR( l_tradeSumByCustCD * l_dbl_right_exrate / l_dbl_left_exrate ),l_roundtype);
                                        l_dbl_amtexp:= trunc( l_parvalue *(1+l_interestrate/100)* l_tradeSumByCustCD,0);
                                         -- PhuongHT: ghi nhan rieng phan lai
                                        l_dbl_intamtexp:= round(l_tradeSumByCustCD * l_parvalue /100 *  to_number(l_interestrate),0) ;


                                   ELSIF l_catype = '018' THEN -- gc_CA_CATYPE_CONVERT_RIGHT_TO_SHARE 'Convert Right to share (+QTTY Share, -AQTTY Right)
                                        l_dbl_qttyexp:= l_tradeSumByCustCD;
                                        l_dbl_aqttyexp:= l_tradeSumByCustCD;
                                        l_roundtype:= 0 ;
                                    ELSIF l_catype = '019' THEN -- gc_CA_CATYPE_CHANGE_TRADING_PLACE_STOCK 'Change trading place (+QTTY )
                                        l_dbl_qttyexp:= 0;
                                        l_dbl_amtexp:=0;
                                     ELSIF  l_catype IN ( '005' , '006','022') THEN
                                           l_dbl_rqttyexp:= FLOOR((l_tradeSumByCustCD* l_dbl_right_devidentshares )/ l_dbl_left_devidentshares );
                                    --T9/2019 CW_PhaseII
                                    ELSIF l_catype = '028' THEN --gc_CA_CATYPE_CASH_CW 'Chi tra loi tuc CW bang tien
                                        if(l_TYPERATE= 'R') THEN
                                            l_dbl_amtexp :=trunc( l_tradeSumByCustCD * l_EXPRICE /100* to_number(l_devidentrate),l_roundtype);
                                        ELSE
                                          l_dbl_amtexp := trunc( l_tradeSumByCustCD*to_number(l_devidentvalue),l_roundtype);
                                          END IF;
                                        --l_roundtype :=0;
                                    -- End T9/2019 CW_PhaseII

                                    END IF;

                                    -- So chung khoan le.
                                       l_dbl_reqttyexp:=  l_dbl_qttyexp - TRUNC( l_dbl_qttyexp , l_roundtype );

                                    IF l_catype = '017' OR l_catype = '020' THEN
                                       l_dbl_reaqttyexp:=(l_dbl_aqttyexp  - TRUNC( l_dbl_aqttyexp  , 0  ));

                                    ELSE
                                       l_dbl_reaqttyexp:=  l_dbl_aqttyexp  - TRUNC( l_dbl_aqttyexp  , l_roundtype );
                                    END IF;
                                    -- So chung khoan da lam tron.
                                       l_dbl_qttyexp:= TRUNC( l_dbl_qttyexp , l_roundtype );
                                    -- so CK jam
                                    IF l_catype = '017' OR l_catype = '020' OR l_catype='023' THEN
                                       l_dbl_aqttyexp:= TRUNC( l_dbl_aqttyexp , 0 );
                                    ELSE
                                       l_dbl_aqttyexp:= TRUNC( l_dbl_aqttyexp , l_roundtype );
                                    END IF;
                                    -- so tien dc nhan
                                    IF l_catype = '011' AND l_catype = '009' THEN
                                        --l_dbl_amtexp:= ROUND( l_dbl_amtexp  +  l_dbl_reqttyexp  *  l_exprice );
                                        l_dbl_amtexp:= ROUND( l_dbl_amtexp  +  l_dbl_reqttyexp  *  l_exprice );
                                    ELSIF l_catype='023' THEN
                                        l_dbl_amtexp:=l_dbl_amtexp;
                                    ELSE
                                        l_dbl_amtexp:= l_dbl_amtexp  +  l_dbl_reqttyexp  *  l_exprice;
                                    END IF;
                                    IF (l_catype <> '023') THEN
                                    l_dbl_aamtexp:=l_dbl_aamtexp  +  l_dbl_reaqttyexp * l_exprice;
                                    ELSE
                                    l_dbl_aamtexp:=l_dbl_aamtexp  +  l_dbl_reaqttyexp * l_parvalue;
                                    END IF;

                                    l_dbl_reaqttyexp :=0;
                                    l_dbl_reqttyexp :=0;

                                 plog.ERROR (pkgctx,'before tim trong temp: '||  rec_trade.custid );
                              SELECT COUNT(*) INTO l_count_temp FROM caschdtempGRP,afmast af
                                               WHERE caschdtempGRP.camastid = l_camastid and caschdtempGRP.afacctno=af.acctno
                                               and af.custid=rec_trade.custid ;

                                  -- dua vao du lieu trong bang caschdtemp de phan bo  co tuc  theo thu tu uu tien cho Kh,
                                  -- bot lai tieu khoan  cuoi cung
                                  plog.ERROR(pkgctx,'L_COUNT_TEMP: '|| l_count_temp||'l_dbl_AAMTexp: be4 caschd' || l_dbl_amtexp ||' trade '||l_tradeSumByCustCD);
                                  if(l_count_temp>0  )    THEN
                                        INSERT INTO CASCHD (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,PBALANCE,PQTTY,PAAMT,INTAMT,RQTTY,ORGPBALANCE)
                                      select * from  ( SELECT autoid,camastid,temp.afacctno afacctno,codeid,excodeid,balance,
                                        (CASE WHEN (round= 0 OR qtty=0 /*OR l_dbl_qttyexp=0*/ ) THEN qtty ELSE trunc(l_dbl_qttyexp*trade/l_tradeSumByCustCD,l_roundtype)END) QTTY,
                                        (CASE WHEN (round= 0 OR amt=0 /*OR l_dbl_amtexp =0*/ ) THEN amt
                                            ELSE
                                                case when l_catype in ('010', '011', '015', '016', '017', '020', '021') then
                                                    case when l_cashround = 0 then round( l_dbl_amtexp*trade/l_tradeSumByCustCD ,0)
                                                         when l_cashround = 1 then CEIL(l_dbl_amtexp*trade/l_tradeSumByCustCD)
                                                         else FLOOR(l_dbl_amtexp*trade/l_tradeSumByCustCD)
                                                    end
                                                else
                                                    round( l_dbl_amtexp*trade/l_tradeSumByCustCD ,0)
                                                end

                                            END)
                                            AMT,
                                         (CASE WHEN (round= 0 OR aqtty=0 /*OR l_dbl_aqttyexp =0*/ ) THEN aqtty ELSE round(l_dbl_aqttyexp*trade/l_tradeSumByCustCD,0)END) AQTTY,
                                          (CASE WHEN (round= 0 OR AAMT=0 /*OR l_dbl_AAMTexp =0*/ ) THEN AAMT ELSE round(l_dbl_AAMTexp*trade/l_tradeSumByCustCD,0)END) AAMT,
                                          temp.STATUS,REQTTY,REAQTTY,
                                            (CASE WHEN (round= 0 OR RETAILBAL=0 /*OR l_dbl_RETAILBALexp =0*/ ) THEN RETAILBAL ELSE round(l_dbl_RETAILBALexp*trade/l_tradeSumByCustCD,0)END) RETAILBAL,
                                            trade,
                                             (CASE WHEN (round= 0 OR RETAILBAL=0 /* OR l_dbl_RETAILBALexp =0*/) THEN RETAILBAL ELSE round(l_dbl_RETAILBALexp*trade/l_tradeSumByCustCD,0)END) PBALANCE,
                                             (CASE WHEN (round= 0 OR PQTTY=0 /*OR l_dbl_qttyexp=0*/) THEN PQTTY ELSE round(l_dbl_qttyexp*trade/l_tradeSumByCustCD,0)END) PQTTY,
                                              (CASE WHEN (round= 0 OR PAAMT=0 /*OR l_dbl_aamtexp=0*/ ) THEN PAAMT ELSE round(l_dbl_aamtexp*trade/l_tradeSumByCustCD,0)END) PAAMT,
                                              --  (CASE WHEN (round= 0 OR INTAMT=0  /*OR  l_dbl_INTAMTexp =0*/) THEN INTAMT ELSE round(l_dbl_INTAMTexp*trade/l_tradeSumByCustCD,0)END) INTAMT,
                                                (CASE WHEN (round= 0 OR INTAMT=0  /*OR  l_dbl_INTAMTexp =0*/) THEN INTAMT
                                                 ELSE
                                                                                        ( case when l_cashround = 0 then round( l_dbl_INTAMTexp*trade/l_tradeSumByCustCD ,0)
                                                                                         when l_cashround = 1 then CEIL(l_dbl_INTAMTexp*trade/l_tradeSumByCustCD)
                                                                                          else FLOOR(l_dbl_INTAMTexp*trade/l_tradeSumByCustCD)
                                                                                          END)
                                                  END) INTAMT,
                                                  (CASE WHEN (round= 0 OR RQTTY=0 /*OR l_dbl_RQTTYexp  =0*/) THEN RQTTY ELSE round(l_dbl_RQTTYexp*trade/l_tradeSumByCustCD,0)END) RQTTY,
                                               (CASE WHEN (round= 0 OR RETAILBAL=0 /*OR l_dbl_RETAILBALexp =0 */) THEN RETAILBAL ELSE round(l_dbl_RETAILBALexp*trade/l_tradeSumByCustCD,0)END) ORGPBALANCE
                                                  FROM caschdtempGRP temp, afmast af
                                                  WHERE temp.afacctno=af.acctno AND af.custid =rec_trade.custid
                                                  AND temp.camastid=l_camastid

                                                  ORDER BY round,trade,afacctno) where ROWNUM < l_count_temp;
                                             plog.ERROR (pkgctx,'before KH cuoi cung: '||  rec_trade.custid );
                                                  -- KH cuoi cung: insert gia tri con lai

                                                  INSERT INTO CASCHD (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,PBALANCE,PQTTY,PAAMT,INTAMT,RQTTY,ORGPBALANCE)
                                        SELECT autoid,temp.camastid, afacctno,codeid,excodeid,balance,
                                       --(CASE WHEN (temp.qtty=0 ) THEN temp.qtty ELSE (l_dbl_qttyexp-nvl(schdsum.qtty,0))END) QTTY,
                                     CASE WHEN l_catype not in ( '014','023') THEN    (l_dbl_qttyexp-nvl(schdsum.qtty,0)) ELSE 0 END  QTTY,
                                        (CASE WHEN ( temp.amt=0 ) THEN temp.amt ELSE

                                                case when l_catype in ('010', '011', '015', '016', '017', '020', '021','027') then
                                                    case when l_cashround = 0 then round(l_dbl_amtexp - nvl(schdsum.amt,0),0)
                                                         when l_cashround = 1 then CEIL(l_dbl_amtexp - nvl(schdsum.amt,0))
                                                         else FLOOR(l_dbl_amtexp - nvl(schdsum.amt,0))
                                                    end
                                                else
                                                    round(l_dbl_amtexp- nvl(schdsum.amt,0),0)
                                                end


                                            END
                                        ) AMT,
                                         --(CASE WHEN ( temp.aqtty=0 ) THEN temp.aqtty ELSE (l_dbl_aqttyexp-nvl(schdsum.aqtty,0))END) AQTTY,
                                         (l_dbl_aqttyexp-nvl(schdsum.aqtty,0)) AQTTY,
                                          --(CASE WHEN ( temp.AAMT=0 ) THEN temp.AAMT ELSE (l_dbl_AAMTexp -nvl(schdsum.aamt,0))END) AAMT,
                                          0 AAMT ,
                                          STATUS,REQTTY,REAQTTY,
                                           -- (CASE WHEN ( temp.RETAILBAL=0 ) THEN temp.RETAILBAL ELSE round(l_dbl_RETAILBALexp-nvl(schdsum.RETAILBAL,0))END) RETAILBAL,
                                            (CASE WHEN ( L_CATYPE <> '014' ) THEN 0 ELSE round(l_dbl_RETAILBALexp-nvl(schdsum.RETAILBAL,0))END) RETAILBAL,
                                            trade,
                                           --  (CASE WHEN ( temp.RETAILBAL=0 ) THEN temp.RETAILBAL ELSE round(l_dbl_RETAILBALexp-nvl(schdsum.RETAILBAL,0))END) PBALANCE,
                                             (CASE WHEN ( L_CATYPE <> '014' ) THEN 0 ELSE round(l_dbl_RETAILBALexp-nvl(schdsum.RETAILBAL,0))END) PBALANCE,
                                             --(CASE WHEN ( temp.PQTTY=0 ) THEN temp.PQTTY ELSE (l_dbl_qttyexp-nvl(schdsum.pqtty,0))END) PQTTY,
                                             CASE WHEN (L_CATYPE = '014' ) THEN (l_dbl_qttyexp-nvl(schdsum.pqtty,0)) ELSE temp.PQTTY END PQTTY,
                                              (CASE WHEN ( L_CATYPE<>'014' ) THEN 0 ELSE (l_dbl_aamtexp-nvl(schdsum.PAAMT,0))END) PAAMT,
                                                --(CASE WHEN (temp.INTAMT=0 ) THEN temp.INTAMT ELSE (l_dbl_INTAMTexp-nvl(schdsum.INTAMT,0))END) INTAMT,
                                                (l_dbl_INTAMTexp-nvl(schdsum.INTAMT,0)) INTAMT,
                                                 -- (CASE WHEN ( temp.RQTTY=0 ) THEN temp.RQTTY ELSE (l_dbl_RQTTYexp-nvl(schdsum.RQTTY,0))END) RQTTY,
                                                 (l_dbl_RQTTYexp-nvl(schdsum.RQTTY,0)) RQTTY ,
                                                  (CASE WHEN ( L_CATYPE <> '014') THEN 0 ELSE round(l_dbl_RETAILBALexp-nvl(schdsum.RETAILBAL,0))END) ORGPBALANCE
                                                  FROM (select * from (SELECT temp.* FROM caschdtempGRP temp,afmast
                                                        WHERE temp.afacctno=afmast.acctno AND afmast.custid=rec_trade.custid
                                                        ORDER BY round desc,trade desc,afacctno  desc) where  rownum=1 ) temp,
                                                        (SELECT SUM(QTTY) QTTY, SUM(amt) amt,SUM(AQTTY) AQTTY,SUM(AAMT) AAMT,
                                                                SUM(RETAILBAL) RETAILBAL,SUM(PBALANCE) PBALANCE, SUM(PQTTY) PQTTY,
                                                                SUM(PAAMT) PAAMT,SUM(INTAMT) INTAMT, SUM(RQTTY) RQTTY, camastid
                                                        FROM caschd, afmast
                                                        WHERE camastid=l_camastid AND afmast.acctno=caschd.afacctno
                                                        AND afmast.custid=rec_trade.custid AND DELTD='N'
                                                        GROUP BY camastid ) schdsum
                                                 WHERE      temp.camastid= schdsum.camastid(+);

                               /*   ELSE -- tai thoi diem dien tai nhung tk duoc huong quyen da close
                                   -- tim tk con hoat dong
                                   BEGIN
                                   SELECT acctno INTO l_afacctno FROM afmast
                                   WHERE custid=rec_trade.custid AND status <> 'C'
                                   AND rownum=1;
                                    -- insert vao cho tk dau tien co status <> 'C'
                                    if(l_catype='014') THEN
                                    L_BALANCE:=0;
                                    l_pqtty:=l_dbl_qttyexp;
                                    ELSE
                                    L_BALANCE:=l_tradeSumByCustCD;
                                    l_pqtty:=0;
                                    END IF;
                                    INSERT INTO CASCHD (AUTOID, CAMASTID, AFACCTNO, CODEID, EXCODEID, BALANCE, QTTY, AMT, AQTTY, AAMT, STATUS,REQTTY,REAQTTY,RETAILBAL,TRADE,PBALANCE,PQTTY,PAAMT,INTAMT,RQTTY)
                                    VALUES( SEQ_CASCHD.NEXTVAL,l_camastid, l_afacctno,l_codeid,L_excodeid,L_BALANCE,
                                    l_dbl_qttyexp ,
                                    l_dbl_amtexp ,
                                    l_dbl_aqttyexp ,
                                    l_dbl_AAMTexp ,
                                    'A',0,0,
                                    l_dbl_RETAILBALexp ,
                                    l_tradeSumByCustCD,
                                    l_dbl_RETAILBALexp ,
                                    l_pqtty ,
                                    l_dbl_aamtexp ,
                                    l_dbl_INTAMTexp ,
                                    l_dbl_RQTTYexp  );

                                    EXCEPTION
                                    WHEN OTHERS   THEN
                                    l_afacctno :=0;
                                    END;*/


                                  END IF ;

                            END IF; -- end of tradesumbycustcd >0
                  END LOOP;
                plog.debug (pkgctx,'Phan bo xong tu caschdtemp vao caschd: ');
                pr_error ('Gianhvg 3375ex','Phan bo xong tu caschdtemp vao caschd');
                 -- Neu khong co tk nao duoc chia co tuc: update trang thai camastid:
                 SELECT COUNT(*) INTO l_count FROM caschd WHERE camastid=l_camastid AND deltd='N';
                 IF(l_count=0) THEN
                   UPDATE camast SET status='B' WHERE camastid=l_camastid;
                 END IF;

                           SELECT (CASE
                             WHEN COUNT(*) = 1 THEN
                              'Y'
                             ELSE
                              'N'
                           END)
                      INTO L_ISREFCODEID
                      FROM sbsecurities
                     WHERE REFCODEID = l_codeid;

                    IF l_iswft = 'Y' AND L_ISREFCODEID = 'N' THEN
                      SELECT TO_CHAR(lpad(MAX(ODR) + 1, 6, 0))
                        INTO v_strcodeid
                        FROM (SELECT ROWNUM ODR, INVACCT
                                 FROM (SELECT CODEID INVACCT FROM SBSECURITIES ORDER BY CODEID) DAT
                                WHERE TO_NUMBER(INVACCT) = ROWNUM) INVTAB;

                      INSERT INTO sbsecurities (CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,
                            TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,
                            INTRATE,HALT,SBTYPE,CAREBY,CHKRATE,REFCODEID,ISSQTTY,BONDTYPE,MARKETTYPE,ALLOWSESSION,ISSEDEPOFEE)
                        SELECT TO_CHAR(v_strcodeid) CODEID, ISSUERID, SYMBOL || '_WFT' SYMBOL,
                               SECTYPE, INVESTMENTTYPE, RISKTYPE, PARVALUE, FOREIGNRATE, STATUS,
                               '006' TRADEPLACE, '002' DEPOSITORY, SECUREDRATIO, MORTAGERATIO,
                               REPORATIO, ISSUEDATE, EXPDATE, INTPERIOD, INTRATE, HALT, SBTYPE,
                               CAREBY, CHKRATE, l_codeid REFCODEID,'',bondtype,markettype,allowsession,
                               issedepofee
                          FROM sbsecurities
                         WHERE codeid = l_codeid;

                      INSERT INTO SECURITIES_INFO (AUTOID, CODEID,
                               SYMBOL, TXDATE, LISTINGQTTY, TRADEUNIT,
                               LISTINGSTATUS, ADJUSTQTTY, LISTTINGDATE, REFERENCESTATUS,
                               ADJUSTRATE, REFERENCERATE, REFERENCEDATE, STATUS, BASICPRICE,
                               OPENPRICE, PREVCLOSEPRICE, CURRPRICE, CLOSEPRICE, AVGPRICE,
                               CEILINGPRICE, FLOORPRICE, MTMPRICE, MTMPRICECD, INTERNALBIDPRICE,
                               INTERNALASKPRICE, PE, EPS, DIVYEILD, DAYRANGE, YEARRANGE,
                               TRADELOT, TRADEBUYSELL, TELELIMITMIN, TELELIMITMAX,
                               ONLINELIMITMIN, ONLINELIMITMAX, REPOLIMITMIN, REPOLIMITMAX,
                               ADVANCEDLIMITMIN, ADVANCEDLIMITMAX, MARGINLIMITMIN,
                               MARGINLIMITMAX, SECURERATIOTMIN, SECURERATIOMAX, DEPOFEEUNIT,
                               DEPOFEELOT, MORTAGERATIOMIN, MORTAGERATIOMAX, SECUREDRATIOMIN,
                               SECUREDRATIOMAX, CURRENT_ROOM, BMINAMT, SMINAMT, MARGINPRICE,MARGINREFPRICE)
                        SELECT SEQ_SECURITIES_INFO.NEXTVAL AUTOID, v_strcodeid CODEID,
                               SYMBOL || '_WFT' SYMBOL, TXDATE, LISTINGQTTY, TRADEUNIT,
                               LISTINGSTATUS, ADJUSTQTTY, LISTTINGDATE, REFERENCESTATUS,
                               ADJUSTRATE, REFERENCERATE, REFERENCEDATE, STATUS, BASICPRICE,
                               OPENPRICE, PREVCLOSEPRICE, CURRPRICE, CLOSEPRICE, AVGPRICE,
                               CEILINGPRICE, FLOORPRICE, MTMPRICE, MTMPRICECD, INTERNALBIDPRICE,
                               INTERNALASKPRICE, PE, EPS, DIVYEILD, DAYRANGE, YEARRANGE,
                               TRADELOT, TRADEBUYSELL, TELELIMITMIN, TELELIMITMAX,
                               ONLINELIMITMIN, ONLINELIMITMAX, REPOLIMITMIN, REPOLIMITMAX,
                               ADVANCEDLIMITMIN, ADVANCEDLIMITMAX, MARGINLIMITMIN,
                               MARGINLIMITMAX, SECURERATIOTMIN, SECURERATIOMAX, DEPOFEEUNIT,
                               DEPOFEELOT, MORTAGERATIOMIN, MORTAGERATIOMAX, SECUREDRATIOMIN,
                               SECUREDRATIOMAX, CURRENT_ROOM, BMINAMT, SMINAMT, MARGINPRICE,MARGINREFPRICE
                          FROM SECURITIES_INFO
                         WHERE codeid = l_codeid;

                         INSERT INTO securities_ticksize (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                         select seq_securities_ticksize .NEXTVAL AUTOID,
                                v_strcodeid CODEID,SYMBOL || '_WFT' SYMBOL,
                                TICKSIZE,FROMPRICE,TOPRICE,STATUS
                         from securities_ticksize
                         WHERE codeid = l_codeid;

                    END IF;

                    IF l_catype IN ( '014','011','021') THEN

                                   -- Mo tk ck phai sinh cho tai khoan DO.
                        UPDATE camast SET optcodeid = l_optcodeid
                        WHERE camastid = l_camastid;

                        Select Count(1) INTO l_count
                        from semast se,caschd chd,camast ca
                        Where SE.afacctno=CHD.afacctno AND SE.codeid=ca.optcodeid
                        AND CHD.camastid=CA.camastid AND CA.camastid=l_camastid;

                           -- IF l_count  = 0 THEN
                           DELETE FROM semast WHERE codeid =l_optcodeid;
                            insert into semast  (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,
                                   OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
                                   COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,
                                   STANDING,WITHDRAW,DEPOSIT,LOAN,QTTY_TRANSFER)
                            select '0000', af.CUSTID, af.acctno || ca.optcodeid,ca.optcodeid,af.acctno,
                                   getcurrdate,getcurrdate,getcurrdate, getcurrdate,
                                   'A','Y','000',
                                   --0,chd.PBALANCE,0,0,0,0,0,0,0,ABS(chd.qtty * CA.TRANSFERTIMES)
                                   0,0,0,0,0,0,0,0,0,0
                            from afmast  af,caschd chd,camast ca
                            where af.acctno=CHD.afacctno AND CHD.camastid=CA.camastid AND CA.camastid= l_camastid AND chd.deltd ='N';

                         -- END IF;
                          Select Count(1) INTO l_count from sbsecurities where CODEID= l_optcodeid  and SYMBOL= l_optsymbol ;
                               IF l_count = 0 THEN
                                INSERT INTO sbsecurities (CODEID,ISSUERID,SYMBOL,SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE)
                                        SELECT  l_optcodeid ,ISSUERID, l_optsymbol ,'004' SECTYPE,INVESTMENTTYPE,RISKTYPE,PARVALUE,FOREIGNRATE,STATUS,TRADEPLACE,DEPOSITORY,SECUREDRATIO,MORTAGERATIO,REPORATIO,ISSUEDATE,EXPDATE,INTPERIOD,INTRATE
                                        FROM SBSECURITIES WHERE CODEID= l_codeid;

                                INSERT INTO SECURITIES_INFO (AUTOID,CODEID,SYMBOL,TXDATE,LISTINGQTTY,TRADEUNIT,LISTINGSTATUS,ADJUSTQTTY,LISTTINGDATE,REFERENCESTATUS,ADJUSTRATE,REFERENCERATE,REFERENCEDATE,STATUS,BASICPRICE,OPENPRICE,PREVCLOSEPRICE,CURRPRICE, MARGINPRICE,AVGPRICE ,CEILINGPRICE,FLOORPRICE,MARGINREFPRICE,MARGINCALLPRICE,MARGINREFCALLPRICE)
                                        SELECT SEQ_SECURITIES_INFO.NEXTVAL, l_optcodeid,l_optsymbol,TXDATE,LISTINGQTTY,TRADEUNIT,LISTINGSTATUS,ADJUSTQTTY,LISTTINGDATE,REFERENCESTATUS,ADJUSTRATE,REFERENCERATE,REFERENCEDATE,STATUS,BASICPRICE,OPENPRICE,PREVCLOSEPRICE,CURRPRICE, MARGINPRICE,AVGPRICE ,CEILINGPRICE,FLOORPRICE,MARGINREFPRICE,MARGINCALLPRICE,MARGINREFCALLPRICE
                                        FROM SECURITIES_INFO WHERE CODEID= l_codeid;

                                INSERT INTO SECURITIES_TICKSIZE (AUTOID,CODEID,SYMBOL,TICKSIZE,FROMPRICE,TOPRICE,STATUS)
                                        SELECT SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_optcodeid , l_optsymbol,TICKSIZE,FROMPRICE,TOPRICE,STATUS
                                        FROM SECURITIES_TICKSIZE  WHERE CODEID= l_codeid ;

                               INSERT INTO securities_rate (AUTOID,CODEID,SYMBOL,FROMPRICE,TOPRICE,MRRATIORATE,MRRATIOLOAN,STATUS)
                               VALUES(seq_securities_rate.nextval,l_optcodeid,l_optsymbol,1,1000000,99,99,'Y');


                        END IF;
                    END IF;

            END LOOP;
        END IF;
    ELSE -- deltd TRANSACTION
        SELECT COUNT(1) INTO l_count FROM CASCHD WHERE CAMASTID= l_camastid AND STATUS IN ('S','C') AND DELTD = 'N';
        IF l_count > 0 THEN
            p_err_code := '-300005';
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        ELSE --xoa quyen.
            UPDATE caschd SET deltd = 'Y' WHERE camastid = l_camastid;
            UPDATE camast SET status='N' WHERE camastid =l_camastid;
            update caschd_log set deltd = 'Y' WHERE camastid = l_camastid;
            IF l_catype IN ( '014','011','021') THEN
                FOR camast_rec IN
                (
                    SELECT * from camast WHERE camastid = l_camastid
                )
                LOOP
                    -- Lay truong thong tin dot thuc hien quyen ve.
                    l_catype:= camast_rec.catype;
                    l_optsymbol:= camast_rec.OPTSYMBOL;
                    SELECT codeid INTO l_optcodeid FROM sbsecurities WHERE symbol = l_optsymbol;
                END LOOP;
                DELETE sbsecurities WHERE codeid = l_optcodeid;
                DELETE securities_info WHERE codeid = l_optcodeid;
                DELETE securities_ticksize WHERE codeid = l_optcodeid;
                DELETE securities_rate WHERE codeid = l_optcodeid;
                DELETE semast WHERE codeid = l_optcodeid;
                DELETE FROM securities_risk WHERE codeid =l_optcodeid;
            END IF;
        END IF;
    END IF;


    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppUpdate;

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
         plog.init ('TXPKS_#3375EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3375EX;
/
