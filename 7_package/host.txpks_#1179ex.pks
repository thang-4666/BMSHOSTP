SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#1179EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1179EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/01/2015     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#1179EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_isvsd            CONSTANT CHAR(2) := '60';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_advlist          CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '96';
   c_idplace          CONSTANT CHAR(2) := '97';
   c_actype           CONSTANT CHAR(2) := '89';
   c_corebank         CONSTANT CHAR(2) := '94';
   c_bankacct         CONSTANT CHAR(2) := '93';
   c_bankcode         CONSTANT CHAR(2) := '95';
   c_matchdate        CONSTANT CHAR(2) := '42';
   c_duedate          CONSTANT CHAR(2) := '08';
   c_days             CONSTANT CHAR(2) := '13';
   c_adtype           CONSTANT CHAR(2) := '06';
   c_maxamt           CONSTANT CHAR(2) := '20';
   c_advamt           CONSTANT CHAR(2) := '09';
   c_aminbal          CONSTANT CHAR(2) := '21';
   c_vat              CONSTANT CHAR(2) := '19';
   c_intrate          CONSTANT CHAR(2) := '12';
   c_bnkrate          CONSTANT CHAR(2) := '15';
   c_cmpminbal        CONSTANT CHAR(2) := '16';
   c_cmpmaxbal        CONSTANT CHAR(2) := '22';
   c_bnkminbal        CONSTANT CHAR(2) := '17';
   c_feeamt           CONSTANT CHAR(2) := '11';
   c_bnkfeeamt        CONSTANT CHAR(2) := '14';
   c_vatamt           CONSTANT CHAR(2) := '18';
   c_amt              CONSTANT CHAR(2) := '10';
   c_100              CONSTANT CHAR(2) := '41';
   c_36000            CONSTANT CHAR(2) := '40';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

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
l_txmsg       tx.msg_rectype;
L_ADVLIST VARCHAR2(5000);
L_COUNT   NUMBER(5);
L_I       NUMBER(5);
L_ADV_TEMP  VARCHAR2(5000);
V_STRMATCHDATE VARCHAR2(50);
v_strDuedate VARCHAR2(50);
v_strDays VARCHAR2(50);
v_strMaxAmt VARCHAR2(50);
v_strAdvAmt VARCHAR2(50);
v_strFeeAmt VARCHAR2(50);
v_strAmt VARCHAR2(50);
v_strVatAmt VARCHAR2(50);
v_strBNKFeeamt VARCHAR2(50);
V_STRDESC      VARCHAR2(500);
l_err_param varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    --v_strAdvList = v_strAdvList & v_strMatchdate & "!" & v_strDuedate & "!" & v_strDays & "!"
    --& v_strMaxAmt & "!" & v_strAdvAmt & "!" & v_strFeeAmt & "!" & v_strAmt & "!" & v_strVatAmt &
    -- "!" & v_strBNKFeeamt & "#"
    IF  P_TXMSG.DELTD <> 'Y' THEN
              L_ADVLIST:=p_txmsg.txfields('05').VALUE;
              L_COUNT:=REGEXP_COUNT(L_ADVLIST,'#');
              FOR i IN 1..L_COUNT
              LOOP
                  L_ADV_TEMP:=SUBSTR(L_ADVLIST,0,INSTR(L_ADVLIST,'#'));
                  L_ADVLIST:=SUBSTR(L_ADVLIST,INSTR(L_ADVLIST,'#')+1);
                  -- lay ra cac truong thong tin chi tiet
                  --matchdate
                  V_STRMATCHDATE:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                   --v_strDuedate
                  v_strDuedate:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                   --v_strDays
                  v_strDays:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                   --v_strMaxAmt
                  v_strMaxAmt:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                   --v_strAdvAmt
                  v_strAdvAmt:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                   --v_strFeeAmt
                  v_strFeeAmt:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                   --v_strAmt
                  v_strAmt:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                    --v_strVatAmt
                  v_strVatAmt:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'!')-1);
                  L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                    --v_strBNKFeeamt
                  v_strBNKFeeamt:=SUBSTR(L_ADV_TEMP,0,INSTR(L_ADV_TEMP,'#')-1);
                  --L_ADV_TEMP:=SUBSTR(L_ADV_TEMP,INSTR(L_ADV_TEMP,'!')+1);
                  --PLOG.error(pkgctx,v_strMatchdate || ',' || v_strDuedate || ',' || v_strDays || ',' || v_strMaxAmt || ',' || v_strAdvAmt || ',' || v_strFeeAmt || ',' || v_strAmt || ',' || V_STRVATAMT || ',' ||v_strBNKFeeamt );
                  -- truyen tham so cho giao dich 1153
                  SELECT SYSTEMNUMS.C_BATCH_PREFIXED|| LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                         INTO l_txmsg.txnum
                         FROM DUAL;
                  SELECT TXDESC into V_STRDESC FROM  TLTX WHERE TLTXCD='1153';
                  l_txmsg.msgtype:='T';
                  l_txmsg.local:='N';
                  l_txmsg.brid        := p_txmsg.BRID;
                  L_TXMSG.wsname:=P_TXMSG.WSNAME;
                  L_TXMSG.IPADDRESS:=P_TXMSG.IPADDRESS;
                  l_txmsg.off_line    := 'N';
                  l_txmsg.deltd       := P_TXMSG.DELTD;
                  l_txmsg.txstatus    := txstatusnums.c_txcompleted;
                  l_txmsg.msgsts      := '0';
                  l_txmsg.ovrsts      := '0';
                  l_txmsg.txdate:=P_TXMSG.TXDATE;
                  l_txmsg.busdate:=P_TXMSG.BUSDATE;
                  l_txmsg.tltxcd:='1153';
                  L_TXMSG.reftxnum:=P_TXMSG.TXNUM;
                  L_TXMSG.batchname:='DAY';
                  L_TXMSG.txtime:=P_TXMSG.TXTIME;
                  L_TXMSG.tlid:=P_TXMSG.TLID;
                  --Set cac field giao dich
                  l_txmsg.txfields ('60').defname   := 'ISVSD';
                  l_txmsg.txfields ('60').TYPE      := 'C';
                  l_txmsg.txfields ('60').VALUE     :=p_txmsg.txfields('60').VALUE;

                  --03   ACCTNO       C
                  l_txmsg.txfields ('03').defname   := 'ACCTNO';
                  l_txmsg.txfields ('03').TYPE      := 'C';
                  l_txmsg.txfields ('03').VALUE     := p_txmsg.txfields('03').VALUE;
                  --06    ADTYPE      C
                  l_txmsg.txfields ('06').defname   := 'ADTYPE';
                  l_txmsg.txfields ('06').TYPE      := 'C';
                  l_txmsg.txfields ('06').VALUE     := p_txmsg.txfields('06').VALUE;
                  --08    DUEDATE      C
                  l_txmsg.txfields ('08').defname   := 'DUEDATE';
                  l_txmsg.txfields ('08').TYPE      := 'C';
                  l_txmsg.txfields ('08').VALUE     := V_STRDUEDATE;
                   --09   ADVAMT          N
                  l_txmsg.txfields ('09').defname   := 'ADVAMT';
                  l_txmsg.txfields ('09').TYPE      := 'N';
                  l_txmsg.txfields ('09').VALUE     := TO_NUMBER(v_strAdvAmt);
                  --10    AMT         N
                  l_txmsg.txfields ('10').defname   := 'AMT';
                  l_txmsg.txfields ('10').TYPE      := 'N';
                  l_txmsg.txfields ('10').VALUE     := TO_NUMBER(v_strAmt);
                  --11    FEEAMT      N
                  l_txmsg.txfields ('11').defname   := 'FEEAMT';
                  l_txmsg.txfields ('11').TYPE      := 'N';
                  l_txmsg.txfields ('11').VALUE     := TO_NUMBER(v_strFeeAmt);

                  --12    INTRATE     N
                  l_txmsg.txfields ('12').defname   := 'INTRATE';
                  l_txmsg.txfields ('12').TYPE      := 'N';
                  l_txmsg.txfields ('12').VALUE     := TO_NUMBER(P_TXMSG.TXFIELDS('12').VALUE);
                  --13    DAYS        N
                  l_txmsg.txfields ('13').defname   := 'DAYS';
                  l_txmsg.txfields ('13').TYPE      := 'N';
                  l_txmsg.txfields ('13').VALUE     := TO_NUMBER(v_strDays);
                  --14    BNKFEEAMT   N
                  l_txmsg.txfields ('14').defname   := 'BNKFEEAMT';
                  l_txmsg.txfields ('14').TYPE      := 'N';
                  l_txmsg.txfields ('14').VALUE     := TO_NUMBER(v_strBNKFeeamt);
                  --15    BNKRATE     N
                  l_txmsg.txfields ('15').defname   := 'BNKRATE';
                  l_txmsg.txfields ('15').TYPE      := 'N';
                  l_txmsg.txfields ('15').VALUE     := TO_NUMBER(P_TXMSG.TXFIELDS('15').VALUE);
                  --16    CMPMINBAL   N
                  l_txmsg.txfields ('16').defname   := 'CMPMINBAL';
                  l_txmsg.txfields ('16').TYPE      := 'N';
                  l_txmsg.txfields ('16').VALUE     := TO_NUMBER(P_TXMSG.TXFIELDS('16').VALUE);
                  --17    BNKMINBAL   N
                  l_txmsg.txfields ('17').defname   := 'BNKMINBAL';
                  l_txmsg.txfields ('17').TYPE      := 'N';
                  l_txmsg.txfields ('17').VALUE     := TO_NUMBER(P_TXMSG.TXFIELDS('17').VALUE);
                  --18    VATAMT  N
                  l_txmsg.txfields ('18').defname   := 'VATAMT';
                  l_txmsg.txfields ('18').TYPE      := 'N';
                  l_txmsg.txfields ('18').VALUE     := TO_NUMBER(V_STRVATAMT);
                  --19    VAT     N
                  l_txmsg.txfields ('19').defname   := 'VAT';
                  l_txmsg.txfields ('19').TYPE      := 'N';
                  l_txmsg.txfields ('19').VALUE     :=  TO_NUMBER(P_TXMSG.TXFIELDS('19').VALUE);
                  --20    MAXAMT      N
                  l_txmsg.txfields ('20').defname   := 'MAXAMT';
                  l_txmsg.txfields ('20').TYPE      := 'N';
                  l_txmsg.txfields ('20').VALUE     := TO_NUMBER(v_strMaxAmt);
                  --21    AMINBAL      N
                  l_txmsg.txfields ('21').defname   := 'AMINBAL';
                  l_txmsg.txfields ('21').TYPE      := 'N';
                  l_txmsg.txfields ('21').VALUE     := TO_NUMBER(P_TXMSG.TXFIELDS('21').VALUE);
                  --22   ADVMAXFEE         N
                  l_txmsg.txfields ('22').defname   := 'ADVMAXFEE';
                  l_txmsg.txfields ('22').TYPE      := 'N';
                  l_txmsg.txfields ('22').VALUE     := TO_NUMBER(P_TXMSG.TXFIELDS('22').VALUE);
                  --30    DESC        C
                  l_txmsg.txfields ('30').defname   := 'DESC';
                  l_txmsg.txfields ('30').TYPE      := 'C';
                  l_txmsg.txfields ('30').VALUE     := UTF8NUMS.C_CONST_TLTX_TXDESC_1153 || V_STRMATCHDATE;
                  --40    3600        C
                  l_txmsg.txfields ('40').defname   := '3600';
                  l_txmsg.txfields ('40').TYPE      := 'C';
                  l_txmsg.txfields ('40').VALUE     := P_TXMSG.TXFIELDS('40').VALUE;
                  --41    100         C
                  l_txmsg.txfields ('41').defname   := '100';
                  l_txmsg.txfields ('41').TYPE      := 'C';
                  l_txmsg.txfields ('41').VALUE     := P_TXMSG.TXFIELDS('41').VALUE;
                  --42    MATCHDATE         C
                  l_txmsg.txfields ('42').defname   := 'MATCHDATE';
                  l_txmsg.txfields ('42').TYPE      := 'C';
                  l_txmsg.txfields ('42').VALUE     := TO_DATE(V_STRMATCHDATE,'DD/MM/RRRR');
                  --88    CUSTODYCD    C
                  l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                  l_txmsg.txfields ('88').TYPE      := 'C';
                  l_txmsg.txfields ('88').VALUE     := P_TXMSG.TXFIELDS('88').VALUE;
                  --89    ACTYPE    C
                  l_txmsg.txfields ('89').defname   := 'ACTYPE';
                  l_txmsg.txfields ('89').TYPE      := 'C';
                  l_txmsg.txfields ('89').VALUE     := P_TXMSG.TXFIELDS('89').VALUE;
                  --90    CUSTNAME    C
                  l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                  l_txmsg.txfields ('90').TYPE      := 'C';
                  l_txmsg.txfields ('90').VALUE     := P_TXMSG.TXFIELDS('90').VALUE;
                  --91    ADDRESS     C
                  l_txmsg.txfields ('91').defname   := 'ADDRESS';
                  l_txmsg.txfields ('91').TYPE      := 'C';
                  l_txmsg.txfields ('91').VALUE     := P_TXMSG.TXFIELDS('91').VALUE;
                  --92    LICENSE     C
                  l_txmsg.txfields ('92').defname   := 'LICENSE';
                  l_txmsg.txfields ('92').TYPE      := 'C';
                  l_txmsg.txfields ('92').VALUE     := P_TXMSG.TXFIELDS('92').VALUE;

                  --93    BANKACCT    C
                  l_txmsg.txfields ('93').defname   := 'BANKACCT';
                  l_txmsg.txfields ('93').TYPE      := 'C';
                  l_txmsg.txfields ('93').VALUE     := P_TXMSG.TXFIELDS('93').VALUE;
                  --94    COREBANK     C
                  l_txmsg.txfields ('94').defname   := 'COREBANK';
                  l_txmsg.txfields ('94').TYPE      := 'C';
                  l_txmsg.txfields ('94').VALUE     := P_TXMSG.TXFIELDS('94').VALUE;
                  --95    BANKCODE     C
                  l_txmsg.txfields ('95').defname   := 'BANKCODE';
                  l_txmsg.txfields ('95').TYPE      := 'C';
                  l_txmsg.txfields ('95').VALUE     :=P_TXMSG.TXFIELDS('95').VALUE;

                  --96    IDDATE     C
                  l_txmsg.txfields ('96').defname   := 'IDDATE';
                  l_txmsg.txfields ('96').TYPE      := 'C';
                  l_txmsg.txfields ('96').VALUE     := P_TXMSG.TXFIELDS('96').VALUE;

                  --97    IDPLACE     C
                  l_txmsg.txfields ('97').defname   := 'IDPLACE';
                  l_txmsg.txfields ('97').TYPE      := 'C';
                  l_txmsg.txfields ('97').VALUE     := P_TXMSG.TXFIELDS('97').VALUE;

                  BEGIN
                      IF txpks_#1153.fn_batchtxprocess (l_txmsg,
                                                       p_err_code,
                                                       l_err_param
                         ) <> systemnums.c_success
                      THEN
                         plog.debug (pkgctx,
                                     'got error 1153: ' || p_err_code
                         );
                         ROLLBACK;
                         RETURN errnums.C_BIZ_RULE_INVALID;
                      END IF;
                  END;
              EXIT WHEN NVL(L_ADVLIST,'a') ='a'        ;
              END LOOP;
     ELSE
         for rec in
        (
            select * from tllog where reftxnum =p_txmsg.txnum
        )
        loop
            if rec.tltxcd = '1153' then
                if TXPKS_#1153.FN_TXREVERT(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                    plog.error (pkgctx, '1179: Loi khi thuc hien xoa giao dich');
                    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                    return errnums.C_SYSTEM_ERROR;
                end if;
            end if;

        end loop;

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
         plog.init ('TXPKS_#1179EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1179EX;

/
