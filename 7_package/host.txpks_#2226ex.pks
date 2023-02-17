SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2226ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2226EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      07/07/2021     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2226ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_reqid            CONSTANT CHAR(2) := '02';
   c_recustodycd      CONSTANT CHAR(2) := '88';
   c_custodycd        CONSTANT CHAR(2) := '87';
   c_afacctno         CONSTANT CHAR(2) := '04';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_amt              CONSTANT CHAR(2) := '10';
   c_depoblock        CONSTANT CHAR(2) := '06';
   c_des              CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_count NUMBER;
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
    SELECT COUNT(1) INTO v_count FROM vsdtxreq
    WHERE REQID = p_txmsg.txfields(c_reqid).value AND STATUS NOT IN ('C', 'E','W');

    IF v_count = 0 THEN
       p_err_code := '-300081'; -- Pre-defined in DEFERROR table
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_count NUMBER;
    v_cdate              DATE;
    v_qtty               number;
    v_trfdate            DATE;
    v_trftxnum           VARCHAR2(50);
    v_recustodycd        varchar2(20);
    v_codeid             varchar2(20);
    v_camastid           varchar2(50);
    v_reqid              number;
    v_reafacctno         varchar2(20);
    v_desc               VARCHAR2(1000);
    l_txmsg              tx.msg_rectype;
    l_err_param          VARCHAR2(1000);
    v_depolastdt         cimast.depolastdt%TYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_cdate  := getcurrdate;
    v_reqid  := p_txmsg.txfields('02').value;
    v_reafacctno := p_txmsg.txfields('04').value;

    IF p_txmsg.DELTD <> 'Y' THEN
      IF p_txmsg.txfields('87').value <> p_txmsg.txfields('88').value THEN
        SELECT COUNT(1) INTO v_count FROM sbsecurities sb WHERE codeid = p_txmsg.txfields('01').value AND instr(sb.isincode,'MIR') > 0 ;
        IF v_count > 0 THEN
           -- 3385
            SELECT NVL(se.trfdate,v_cdate) trfdate,se.trftxnum, ca.camastid, sb.codeid, se.trade + se.blocked qtty,se.recustodycd
            INTO v_trfdate, v_trftxnum, v_camastid, v_codeid, v_qtty, v_recustodycd
            FROM SERECEIVED se , sbsecurities sb, camast ca
            WHERE sb.codeid = p_txmsg.txfields('01').value
            AND se.symbol = sb.symbol
            AND sb.refcodeid is null
            AND ca.optcodeid = sb.codeid
            AND ca.catype = '014'
            AND CA.DELTD = 'N'
            AND CA.STATUS IN ('V','M')
            AND se.reqid = v_reqid
            AND se.status ='A';

           INSERT INTO catransfer(autoid, txdate, txnum, camastid, optseacctnocr, optseacctnodr,
                                  codeid, optcodeid, amt, status, inamt, retailbal, sendinamt, sendretailbal,
                                  toacctno, tomemcus, country2, custname2, address2,
                                  license2, iddate2, idplace2, caschdid, statusre, feeamt, /*taxamt,*/reqid)
           VALUES (seq_catransfer.nextval,nvl(v_trfdate,v_cdate),NVL(v_trftxnum,p_txmsg.TXNUM) ,v_camastid,p_txmsg.txfields('05').value,'-----'||v_codeid,
                   v_codeid,v_codeid,v_qtty,'P',0,0,0,0,
                   v_recustodycd,NULL,NULL,NULL,NULL,
                   NULL,NULL,NULL,null,'N',0,/*0,*/v_reqid);
           -- Lay mo ta giao dich
          BEGIN
             SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '3385';
          EXCEPTION WHEN OTHERS THEN
             v_desc := '';
          END;

          -- Khoi tao thong tin GD
          l_txmsg.tltxcd    := '3385';
          l_txmsg.msgtype   := 'T';
          l_txmsg.local     := 'N';
          l_txmsg.tlid      := systemnums.c_system_userid;
          l_txmsg.off_line  := 'N';
          l_txmsg.deltd     := txnums.c_deltd_txnormal;
          l_txmsg.txstatus  := txstatusnums.c_txcompleted;
          l_txmsg.msgsts    := '0';
          l_txmsg.ovrsts    := '0';
          l_txmsg.batchname := 'DAY';
          l_txmsg.busdate   := p_txmsg.BUSDATE;
          l_txmsg.txdate    := p_txmsg.TXDATE;
          l_txmsg.reftxnum  := p_txmsg.txnum;

          SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

          SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
          --Lay thong tin dien
          FOR rec IN (
               SELECT TO_CHAR(MST.TXDATE,'DDMMRRRR') || MST.TXNUM TXKEY, MST.CAMASTID, CAMAST.OPTCODEID, CAMAST.CODEID,
                      NVL(CAMAST.TOCODEID,CAMAST.CODEID) TOCODEID,
                      SYM.SYMBOL, SYM2.SYMBOL TOSYMBOL, MST.AMT,
                      UPPER(MST.TOACCTNO) CUSTODYCD, SUBSTR(MST.OPTSEACCTNOCR,1,10) TOAFACCTNO,
                      CF.FULLNAME TOFULLNAME, CF.IDCODE TOIDCODE, CF.IDDATE TOIDDATE, CF.IDPLACE TOIDPLACE,
                      CF.ADDRESS TOADDRESS, camast.isincode, CF.COUNTRY
                  FROM CATRANSFER MST, (SELECT * FROM CAMAST ORDER BY AUTOID DESC) CAMAST, SBSECURITIES SYM, AFMAST AF,
                      CFMAST CF, SBSECURITIES SYM2
                  WHERE MST.STATUSRE = 'N'-- AND  SUBSTR(MST.TOACCTNO,1,3) = '002'
                      AND MST.STATUS NOT IN ('Y','C')
                      AND MST.CAMASTID = CAMAST.CAMASTID
                      AND CAMAST.CODEID = SYM.CODEID
                      AND NVL(CAMAST.TOCODEID,CAMAST.CODEID)  = SYM2.CODEID
                      AND SUBSTR(OPTSEACCTNOCR,1,10) =  AF.ACCTNO
                      AND AF.CUSTID = CF.CUSTID
                      AND MST.REQID = V_REQID
          ) LOOP
              SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
              INTO l_txmsg.txnum FROM dual;

              l_txmsg.brid := p_txmsg.BRID;

              l_txmsg.txfields('01').defname := 'CODEID';
              l_txmsg.txfields('01').TYPE    := 'C';
              l_txmsg.txfields('01').value   := rec.OPTCODEID;

              l_txmsg.txfields('04').defname := 'AFACCT2';
              l_txmsg.txfields('04').TYPE    := 'C';
              l_txmsg.txfields('04').value   := rec.toafacctno;

              l_txmsg.txfields('05').defname := 'ACCT2';
              l_txmsg.txfields('05').TYPE    := 'C';
              l_txmsg.txfields('05').value   := rec.toafacctno||rec.OPTCODEID;

              l_txmsg.txfields('06').defname := 'CAMASTID';
              l_txmsg.txfields('06').TYPE    := 'C';
              l_txmsg.txfields('06').value   := rec.camastid;

              l_txmsg.txfields('11').defname := 'ORGCODEID';
              l_txmsg.txfields('11').TYPE    := 'C';
              l_txmsg.txfields('11').value   := rec.codeid;

              l_txmsg.txfields('12').defname := 'ORGSEACCTNO';
              l_txmsg.txfields('12').TYPE    := 'C';
              l_txmsg.txfields('12').value   := rec.toafacctno||rec.codeid;

              l_txmsg.txfields('21').defname := 'AMT';
              l_txmsg.txfields('21').TYPE    := 'N';
              l_txmsg.txfields('21').value   := rec.amt;

              l_txmsg.txfields('30').defname := 'DESC';
              l_txmsg.txfields('30').TYPE    := 'C';
              l_txmsg.txfields('30').value   := v_desc;

              l_txmsg.txfields('35').defname := 'SYMBOL';
              l_txmsg.txfields('35').TYPE    := 'C';
              l_txmsg.txfields('35').value   := rec.symbol;

              l_txmsg.txfields('40').defname := 'TOCODEID';
              l_txmsg.txfields('40').TYPE    := 'C';
              l_txmsg.txfields('40').value   := rec.tosymbol;

              l_txmsg.txfields('50').defname := 'TXKEY';
              l_txmsg.txfields('50').TYPE    := 'C';
              l_txmsg.txfields('50').value   := rec.txkey;

              l_txmsg.txfields('80').defname := 'COUNTRY';
              l_txmsg.txfields('80').TYPE    := 'C';
              l_txmsg.txfields('80').value   := rec.country;

              l_txmsg.txfields('88').defname := 'CUSTODYCD';
              l_txmsg.txfields('88').TYPE    := 'C';
              l_txmsg.txfields('88').value   := rec.custodycd;

              l_txmsg.txfields('90').defname := 'CUSTNAME';
              l_txmsg.txfields('90').TYPE    := 'C';
              l_txmsg.txfields('90').value   := rec.tofullname;

              l_txmsg.txfields('91').defname := 'ADDRESS';
              l_txmsg.txfields('91').TYPE    := 'C';
              l_txmsg.txfields('91').value   := rec.toaddress;

              l_txmsg.txfields('92').defname := 'LICENSE';
              l_txmsg.txfields('92').TYPE    := 'C';
              l_txmsg.txfields('92').value   := rec.toidcode;

              l_txmsg.txfields('93').defname := 'IDDATE';
              l_txmsg.txfields('93').TYPE    := 'C';
              l_txmsg.txfields('93').value   := rec.toiddate;

              l_txmsg.txfields('94').defname := 'IDPLACE';
              l_txmsg.txfields('94').TYPE    := 'C';
              l_txmsg.txfields('94').value   := rec.toidplace;
              savepoint bf_transaction_3385;

              BEGIN
                IF txpks_#3385.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
                   systemnums.c_success THEN
                  ROLLBACK to bf_transaction_3385;
                END IF;
              END;
            END LOOP;
        ELSE
          -- 2245
          l_txmsg.tltxcd    := '2245';
          l_txmsg.msgtype   := 'T';
          l_txmsg.local     := 'N';
          l_txmsg.tlid      := p_txmsg.tlid;
          l_txmsg.off_line  := 'N';
          l_txmsg.deltd     := txnums.c_deltd_txnormal;
          l_txmsg.txstatus  := txstatusnums.c_txcompleted;
          l_txmsg.msgsts    := '0';
          l_txmsg.ovrsts    := '0';
          l_txmsg.batchname := 'DAY';
          l_txmsg.busdate   := p_txmsg.BUSDATE;
          l_txmsg.txdate    := p_txmsg.TXDATE;
          l_txmsg.reftxnum  := p_txmsg.txnum;

          SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2245';

          SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

          SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;

          --Lay thong tin dien
          FOR rec IN
          (   SELECT re.autoid, re.reqid, re.recustodycd, sb.codeid, re.trade, re.blocked,
                     de.depositid, sb.parvalue, re.trftxnum, re.reseacctno, rq.brid,
                     cf.fullname, cf.idcode, cf.address, inf.basicprice, sb.refcodeid,
                     I.SHORTNAME||': '||I.FULLNAME ISSUERNAME,A.CDCONTENT TRADEPLACE, re.trfdate
              FROM sereceived re, sbsecurities sb, securities_info inf, cfmast cf,
                   deposit_member de, vsdtxreq rq, ISSUERS i, allcode a
              WHERE re.symbol = sb.symbol
                AND sb.codeid = inf.codeid
                AND re.recustodycd = cf.custodycd
                AND re.frbiccode = de.biccode
                AND re.reqid = rq.reqid
                AND i.issuerid = sb.issuerid
                AND re.status = 'A'
                AND A.CDTYPE = 'SA' AND A.CDNAME = 'TRADEPLACE' AND A.CDVAL= sb.tradeplace
                AND re.reqid = v_reqid

          ) LOOP
              SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
              INTO l_txmsg.txnum FROM dual;

              l_txmsg.brid := rec.brid;

              SELECT depolastdt INTO v_depolastdt FROM cimast WHERE acctno = v_reafacctno;

              l_txmsg.txfields('00').defname := 'FEETYPE';
              l_txmsg.txfields('00').type := 'C';
              l_txmsg.txfields('00').value := 'VSDDEP';

              l_txmsg.txfields('99').defname := 'AUTOID';
              l_txmsg.txfields('99').type := 'C';
              l_txmsg.txfields('99').value := '';

              l_txmsg.txfields('01').defname := 'CODEID';
              l_txmsg.txfields('01').type := 'C';
              l_txmsg.txfields('01').value := rec.codeid;

              l_txmsg.txfields('02').defname := 'REQID';
              l_txmsg.txfields('02').type := 'C';
              l_txmsg.txfields('02').value := rec.reqid;

              l_txmsg.txfields('03').defname := 'INWARD';
              l_txmsg.txfields('03').type := 'C';
              l_txmsg.txfields('03').value := rec.depositid;

              l_txmsg.txfields('88').defname := 'CUSTODYCD';
              l_txmsg.txfields('88').type := 'C';
              l_txmsg.txfields('88').value := rec.recustodycd;

              l_txmsg.txfields('04').defname := 'AFACCT2';
              l_txmsg.txfields('04').type := 'C';
              l_txmsg.txfields('04').value := v_reafacctno;

              /*l_txmsg.txfields('25').defname := 'ACCTNO_UPDATECOST';
              l_txmsg.txfields('25').type := 'C';
              l_txmsg.txfields('25').value := v_reafacctno || nvl(rec.refcodeid, rec.codeid);
              */

              l_txmsg.txfields('05').defname := 'ACCT2';
              l_txmsg.txfields('05').type := 'C';
              l_txmsg.txfields('05').value := v_reafacctno || rec.codeid;

              l_txmsg.txfields('90').defname := 'CUSTNAME';
              l_txmsg.txfields('90').type := 'C';
              l_txmsg.txfields('90').value := rec.fullname;

              l_txmsg.txfields('91').defname := 'ADDRESS';
              l_txmsg.txfields('91').type := 'C';
              l_txmsg.txfields('91').value := rec.address;

              l_txmsg.txfields('92').defname := 'LICENSE';
              l_txmsg.txfields('92').type := 'C';
              l_txmsg.txfields('92').value := rec.idcode;

              l_txmsg.txfields('09').defname := 'PRICE';
              l_txmsg.txfields('09').type := 'N';
              l_txmsg.txfields('09').value := rec.basicprice;

              l_txmsg.txfields('10').defname := 'AMT';
              l_txmsg.txfields('10').type := 'N';
              l_txmsg.txfields('10').value := rec.trade;

              l_txmsg.txfields('06').defname := 'DEPOBLOCK';
              l_txmsg.txfields('06').type := 'N';
              l_txmsg.txfields('06').value := rec.blocked;

              l_txmsg.txfields('12').defname := 'QTTY';
              l_txmsg.txfields('12').type := 'N';
              l_txmsg.txfields('12').value := rec.trade + rec.blocked;

              l_txmsg.txfields('11').defname := 'PARVALUE';
              l_txmsg.txfields('11').type := 'N';
              l_txmsg.txfields('11').value := rec.parvalue;

              l_txmsg.txfields('14').defname := 'QTTYTYPE';
              l_txmsg.txfields('14').type := 'C';
              l_txmsg.txfields('14').value := '002';

              l_txmsg.txfields('31').defname := 'TRTYPE';
              l_txmsg.txfields('31').type := 'C';
              l_txmsg.txfields('31').value := '002';

              l_txmsg.txfields('32').defname := 'DEPOLASTDT';
              l_txmsg.txfields('32').type := 'C';
              l_txmsg.txfields('32').value := to_char(v_depolastdt, 'DD/MM/RRRR');

              l_txmsg.txfields('15').defname := 'DEPOFEEAMT';
              l_txmsg.txfields('15').type := 'N';
              l_txmsg.txfields('15').value := FN_CIGETDEPOFEEAMT(v_reafacctno, rec.codeid, to_char(l_txmsg.busdate,'DD/MM/RRRR'), to_char(l_txmsg.txdate,'DD/MM/RRRR'), rec.trade + rec.blocked);

              l_txmsg.txfields('13').defname := 'DEPOFEEACR';
              l_txmsg.txfields('13').type := 'N';
              l_txmsg.txfields('13').value := FN_CIGETDEPOFEEACR(v_reafacctno, rec.codeid, to_char(l_txmsg.busdate,'DD/MM/RRRR'), to_char(l_txmsg.txdate,'DD/MM/RRRR'), rec.trade + rec.blocked);

              l_txmsg.txfields('30').defname := 'DESC';
              l_txmsg.txfields('30').type := 'C';
              l_txmsg.txfields('30').value := v_desc;

              /*l_txmsg.txfields('20').defname := 'ISSUERNAME';
              l_txmsg.txfields('20').type := 'C';
              l_txmsg.txfields('20').value := rec.ISSUERNAME;

              l_txmsg.txfields('21').defname := 'TRADEPLACE';
              l_txmsg.txfields('21').type := 'C';
              l_txmsg.txfields('21').value := rec.TRADEPLACE;*/

              l_txmsg.txfields('16').defname := 'DEPOTYPE';
              l_txmsg.txfields('16').type := 'C';
              l_txmsg.txfields('16').value := '';

              l_txmsg.txfields('33').defname := 'DRFEETYPE';
              l_txmsg.txfields('33').type := 'C';
              l_txmsg.txfields('33').value := '';

              l_txmsg.txfields('34').defname := 'CACULATETYPE';
              l_txmsg.txfields('34').type := 'C';
              l_txmsg.txfields('34').value := '';

              l_txmsg.txfields('45').defname := 'FEE';
              l_txmsg.txfields('45').type := 'N';
              l_txmsg.txfields('45').value := '';

              l_txmsg.txfields('55').defname := 'FEECOMP';
              l_txmsg.txfields('55').type := 'N';
              l_txmsg.txfields('55').value := '';

              l_txmsg.txfields('98').defname := 'Type';
              l_txmsg.txfields('98').type := 'C';
              l_txmsg.txfields('98').value := '';
              savepoint bf_transaction_2245;
              BEGIN
                IF txpks_#2245.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
                   systemnums.c_success THEN
                  ROLLBACK to bf_transaction_2245;
                END IF;
              END;
           END LOOP;
        END IF;
      ELSE
        IF  to_number(p_txmsg.txfields(c_amt).value) > 0 THEN
          --2221: HCNN -> TDCN
            l_txmsg.tltxcd    := '2221';
            l_txmsg.msgtype   := 'T';
            l_txmsg.local     := 'N';
            l_txmsg.tlid      := p_txmsg.tlid;
            l_txmsg.off_line  := 'N';
            l_txmsg.deltd     := txnums.c_deltd_txnormal;
            l_txmsg.txstatus  := txstatusnums.c_txcompleted;
            l_txmsg.msgsts    := '0';
            l_txmsg.ovrsts    := '0';
            l_txmsg.batchname := 'DAY';
            l_txmsg.busdate   := p_txmsg.BUSDATE;
            l_txmsg.txdate    := p_txmsg.TXDATE;
            l_txmsg.reftxnum  := p_txmsg.txnum;

            SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2221';

            SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
            INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

            SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
            FOR rec IN (
                  SELECT CF.CUSTODYCD,AF.ACCTNO AFACCTNO,SE.ACCTNO,DT.CODEID,
                         DT.SYMBOL,SE.BLOCKED,DT.PARVALUE,SE.BLOCKED REALBLOCKED,
                         DT.PRICE,CF.ADDRESS,CF.FULLNAME, CF.IDCODE LICENSE
                    FROM SERECEIVED RE, SEMAST SE,CFMAST CF,AFMAST AF,
                         (SELECT SB.SYMBOL,SB.CODEID,SB.PARVALUE,SEIN.BASICPRICE PRICE
                            FROM SECURITIES_INFO SEIN, SBSECURITIES SB
                           WHERE SB.CODEID = SEIN.CODEID) DT
                   WHERE AF.CUSTID = CF.CUSTID
                     AND SE.AFACCTNO = AF.ACCTNO
                     AND SE.CODEID = DT.CODEID
                     AND SE.BLOCKED > 0
                     AND RE.RECUSTODYCD = CF.CUSTODYCD
                     AND RE.SYMBOL = DT.SYMBOL
                     AND RE.STATUS = 'A'
                     AND RE.REQID = v_reqid
                     AND SE.ACCTNO = p_txmsg.txfields('05').value
                ) LOOP

                SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
                INTO l_txmsg.txnum FROM dual;

                  --CODEID
                  l_txmsg.txfields ('01').defname   := 'CODEID';
                  l_txmsg.txfields ('01').TYPE   := 'C';
                  l_txmsg.txfields ('01').VALUE   := REC.CODEID;
                  --ACCTNO
                  l_txmsg.txfields ('02').defname   := 'ACCTNO';
                  l_txmsg.txfields ('02').TYPE   := 'C';
                  l_txmsg.txfields ('02').VALUE   := REC.AFACCTNO;
                  --ACCTNO
                  l_txmsg.txfields ('03').defname   := 'ACCTNO';
                  l_txmsg.txfields ('03').TYPE   := 'C';
                  l_txmsg.txfields ('03').VALUE   := REC.ACCTNO;

                  --AUTOID2232
                  l_txmsg.txfields ('09').defname   := 'PRICE';
                  l_txmsg.txfields ('09').TYPE   := 'C';
                  l_txmsg.txfields ('09').VALUE   := rec.PRICE;

                  --QTTY
                  l_txmsg.txfields ('10').defname   := 'QTTY';
                  l_txmsg.txfields ('10').TYPE   := 'N';
                  l_txmsg.txfields ('10').VALUE   := least(rec.BLOCKED,to_number(p_txmsg.txfields(c_amt).value));

                  --QTTY
                  l_txmsg.txfields ('20').defname   := 'REALBLOCKED';
                  l_txmsg.txfields ('20').TYPE   := 'N';
                  l_txmsg.txfields ('20').VALUE   := rec.REALBLOCKED;

                  --PARVALUE
                  l_txmsg.txfields ('11').defname   := 'PARVALUE';
                  l_txmsg.txfields ('11').TYPE   := 'N';
                  l_txmsg.txfields ('11').VALUE   := REC.PARVALUE;

                  --DESC
                  l_txmsg.txfields ('30').defname   := 'DESC';
                  l_txmsg.txfields ('30').TYPE   := 'C';
                  l_txmsg.txfields ('30').VALUE   := v_desc;

                  --CUSTNAME
                  l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                  l_txmsg.txfields ('90').TYPE   := 'C';
                  l_txmsg.txfields ('90').VALUE   := REC.FULLNAME;

                  --ADDRESS
                  l_txmsg.txfields ('91').defname   := 'ADDRESS';
                  l_txmsg.txfields ('91').TYPE   := 'C';
                  l_txmsg.txfields ('91').VALUE   := REC.ADDRESS;

                  --LICENSE
                  l_txmsg.txfields ('92').defname   := 'LICENSE';
                  l_txmsg.txfields ('92').TYPE   := 'C';
                  l_txmsg.txfields ('92').VALUE   := REC.LICENSE;

                  savepoint bf_transaction_2221;
                  BEGIN
                    IF txpks_#2221.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>
                       systemnums.c_success THEN
                      ROLLBACK to bf_transaction_2221;
                    END IF;
                  END;
            END LOOP;
        ELSIF to_number(p_txmsg.txfields(c_depoblock).value) > 0 THEN
        --2220: TDCN -> HCCN
            l_txmsg.tltxcd    := '2202';
            l_txmsg.msgtype   := 'T';
            l_txmsg.local     := 'N';
            l_txmsg.tlid      := p_txmsg.tlid;
            l_txmsg.off_line  := 'N';
            l_txmsg.deltd     := txnums.c_deltd_txnormal;
            l_txmsg.txstatus  := txstatusnums.c_txcompleted;
            l_txmsg.msgsts    := '0';
            l_txmsg.ovrsts    := '0';
            l_txmsg.batchname := 'DAY';
            l_txmsg.busdate   := p_txmsg.BUSDATE;
            l_txmsg.txdate    := p_txmsg.TXDATE;
            l_txmsg.reftxnum  := p_txmsg.txnum;

            SELECT txdesc INTO v_desc FROM tltx WHERE tltxcd = '2202';

            SELECT sys_context('USERENV', 'HOST'), sys_context('USERENV', 'IP_ADDRESS', 15)
            INTO l_txmsg.wsname, l_txmsg.ipaddress FROM dual;

            SELECT to_char(SYSDATE, 'hh24:mi:ss') INTO l_txmsg.txtime FROM dual;
            FOR rec IN (
                  SELECT CF.CUSTODYCD,AF.ACCTNO AFACCTNO,SE.ACCTNO,DT.CODEID,
                         DT.SYMBOL,SE.BLOCKED,DT.PARVALUE,SE.BLOCKED REALBLOCKED,
                         DT.PRICE,CF.ADDRESS,CF.FULLNAME, CF.IDCODE LICENSE, DT.TRADELOT
                    FROM SERECEIVED RE, SEMAST SE,CFMAST CF,AFMAST AF,
                         (SELECT SB.SYMBOL,SB.CODEID,SB.PARVALUE,SEIN.BASICPRICE PRICE, SEIN.TRADELOT
                            FROM SECURITIES_INFO SEIN, SBSECURITIES SB
                           WHERE SB.CODEID = SEIN.CODEID) DT
                   WHERE AF.CUSTID = CF.CUSTID
                     AND SE.AFACCTNO = AF.ACCTNO
                     AND SE.CODEID = DT.CODEID
                     AND RE.RECUSTODYCD = CF.CUSTODYCD
                     AND RE.SYMBOL = DT.SYMBOL
                     AND RE.STATUS = 'A'
                     AND RE.REQID = v_reqid
                     AND SE.ACCTNO = p_txmsg.txfields('05').value
                ) LOOP

                  SELECT systemnums.c_batch_prefixed || lpad(seq_batchtxnum.nextval, 8, '0')
                  INTO l_txmsg.txnum FROM dual;
                  --AUTOID
                  l_txmsg.txfields ('01').defname   := 'AUTOID';
                  l_txmsg.txfields ('01').TYPE   := 'C';
                  l_txmsg.txfields ('01').VALUE   := '';
                  --CODEID
                  l_txmsg.txfields ('01').defname   := 'CODEID';
                  l_txmsg.txfields ('01').TYPE   := 'C';
                  l_txmsg.txfields ('01').VALUE   := REC.CODEID;
                  --ACCTNO
                  l_txmsg.txfields ('02').defname   := 'ACCTNO';
                  l_txmsg.txfields ('02').TYPE   := 'C';
                  l_txmsg.txfields ('02').VALUE   := REC.AFACCTNO;
                  --ACCTNO
                  l_txmsg.txfields ('03').defname   := 'ACCTNO';
                  l_txmsg.txfields ('03').TYPE   := 'C';
                  l_txmsg.txfields ('03').VALUE   := REC.ACCTNO;

                  --BLOCKTYPE
                  l_txmsg.txfields ('03').defname   := 'BLOCKTYPE';
                  l_txmsg.txfields ('03').TYPE   := 'C';
                  l_txmsg.txfields ('03').VALUE   := 'B';

                  --AUTOID2232
                  l_txmsg.txfields ('09').defname   := 'PRICE';
                  l_txmsg.txfields ('09').TYPE   := 'C';
                  l_txmsg.txfields ('09').VALUE   := rec.PRICE;

                  --QTTY
                  l_txmsg.txfields ('10').defname   := 'QTTY';
                  l_txmsg.txfields ('10').TYPE   := 'N';
                  l_txmsg.txfields ('10').VALUE   := p_txmsg.txfields(c_depoblock).value;

                  --QTTY
                  l_txmsg.txfields ('08').defname   := 'REALBLOCKED';
                  l_txmsg.txfields ('08').TYPE   := 'N';
                  l_txmsg.txfields ('08').VALUE   := fn_get_semast_avl_withdraw(REC.AFACCTNO,REC.CODEID);

                  --PARVALUE
                  l_txmsg.txfields ('11').defname   := 'PARVALUE';
                  l_txmsg.txfields ('11').TYPE   := 'N';
                  l_txmsg.txfields ('11').VALUE   := REC.PARVALUE;

                  --QTTYTYPE
                  l_txmsg.txfields ('12').defname   := 'QTTYTYPE';
                  l_txmsg.txfields ('12').TYPE   := 'C';
                  l_txmsg.txfields ('12').VALUE   := '002';

                  --DESC
                  l_txmsg.txfields ('30').defname   := 'DESC';
                  l_txmsg.txfields ('30').TYPE   := 'C';
                  l_txmsg.txfields ('30').VALUE   := v_desc;

                  --FEEAMT
                  l_txmsg.txfields ('41').defname   := 'FEEAMT';
                  l_txmsg.txfields ('41').TYPE   := 'N';
                  l_txmsg.txfields ('41').VALUE   := '0';

                  --TRADELOT
                  l_txmsg.txfields ('42').defname   := 'TRADELOT';
                  l_txmsg.txfields ('42').TYPE   := 'N';
                  l_txmsg.txfields ('42').VALUE   := REC.TRADELOT;

                  --MINVAL
                  l_txmsg.txfields ('43').defname   := 'MINVAL';
                  l_txmsg.txfields ('43').TYPE   := 'N';
                  l_txmsg.txfields ('43').VALUE   := '0';

                  --MAXVAL
                  l_txmsg.txfields ('44').defname   := 'MAXVAL';
                  l_txmsg.txfields ('44').TYPE   := 'N';
                  l_txmsg.txfields ('44').VALUE   := '0';

                  --NUMLOT
                  l_txmsg.txfields ('45').defname   := 'NUMLOT';
                  l_txmsg.txfields ('45').TYPE   := 'N';
                  l_txmsg.txfields ('45').VALUE   := '0';

                  --VAT
                  l_txmsg.txfields ('47').defname   := 'VAT';
                  l_txmsg.txfields ('47').TYPE   := 'N';
                  l_txmsg.txfields ('47').VALUE   := '0';

                  --INWARD
                  l_txmsg.txfields ('66').defname   := 'INWARD';
                  l_txmsg.txfields ('66').TYPE   := 'C';
                  l_txmsg.txfields ('66').VALUE   := '';

                  --CUSTODYCD
                  l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                  l_txmsg.txfields ('88').TYPE   := 'C';
                  l_txmsg.txfields ('88').VALUE   := REC.CUSTODYCD;

                  --CUSTNAME
                  l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                  l_txmsg.txfields ('90').TYPE   := 'C';
                  l_txmsg.txfields ('90').VALUE   := REC.FULLNAME;

                  --ADDRESS
                  l_txmsg.txfields ('91').defname   := 'ADDRESS';
                  l_txmsg.txfields ('91').TYPE   := 'C';
                  l_txmsg.txfields ('91').VALUE   := REC.ADDRESS;

                  --LICENSE
                  l_txmsg.txfields ('92').defname   := 'LICENSE';
                  l_txmsg.txfields ('92').TYPE   := 'C';
                  l_txmsg.txfields ('92').VALUE   := REC.LICENSE;

                  savepoint bf_transaction_2202;
                  BEGIN
                    IF txpks_#2202.fn_batchtxprocess(l_txmsg, p_err_code, l_err_param) <>systemnums.c_success THEN
                      ROLLBACK to bf_transaction_2202;
                    END IF;
                  END;
            END LOOP;
        END IF;
      END IF;

      IF p_txmsg.txfields('02').value IS NOT NULL THEN
        --Cap nhat trang thai dien gui ve
            UPDATE vsdtxreq
               SET status = 'C', msgstatus = 'F', objkey = p_txmsg.txnum,
                  txdate = p_txmsg.txdate, afacctno = p_txmsg.txfields('04').value, msgacct = p_txmsg.txfields('05').value
             WHERE reqid = p_txmsg.txfields(c_reqid).value;

           UPDATE vsdtrflog SET status = 'C', timeprocess = SYSTIMESTAMP
            WHERE referenceid = p_txmsg.txfields(c_reqid).value AND msgtype = '544' AND status = 'P';

           UPDATE sereceived SET status = 'C'
            WHERE reqid = p_txmsg.txfields(c_reqid).value;
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
         plog.init ('TXPKS_#2226EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2226EX;
/
