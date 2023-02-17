SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_rmproc
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
     **  Fsser      04-may-2011    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

    --Utils methods
    TYPE str_array IS TABLE OF VARCHAR2(50)
    INDEX BY BINARY_INTEGER;

    FUNCTION Split(p_in_string VARCHAR2, p_delim VARCHAR2) RETURN str_array;
    FUNCTION is_number(p_input IN VARCHAR2) RETURN number;
    --End

    PROCEDURE pr_CreateCompleteHoldTransact(p_reqid in number,p_err_code out varchar2);
    PROCEDURE pr_CreateRevertHoldTransact(p_reqid in number,p_err_code out varchar2);

    PROCEDURE pr_CreateHoldRqsFor3384(p_reqid in number,p_err_code out varchar2);

    PROCEDURE pr_RollbackCITRAN(p_txnum in varchar2,p_txdate in varchar2,p_err_code out varchar2);
     PROCEDURE pr_PreCaculateHoldAmount(p_strIn in varchar2, p_musthold out number,p_err_code out varchar2);
    PROCEDURE pr_CaculateHoldAmount(p_strIn in varchar2,p_holdamt out number,p_err_code out varchar2);

    PROCEDURE pr_GetBankRef(p_bankcode in varchar2,p_txdate in varchar2,p_refcode out varchar2,p_err_code out varchar2);

    PROCEDURE sp_exec_create_crbtrflog (p_err_code OUT VARCHAR2, p_txdate IN VARCHAR2,
      p_tlid IN VARCHAR2, p_brid IN VARCHAR2,p_trfcode  IN VARCHAR2, p_lreqid IN VARCHAR2);

    PROCEDURE sp_DeleteTxReq (p_err_code OUT VARCHAR2, p_txdate IN VARCHAR2,
      p_tlid IN VARCHAR2, p_brid IN VARCHAR2,p_lreqid IN VARCHAR2,p_ltxdesc  IN VARCHAR2);

    PROCEDURE pr_CreateCRBTXREQ(p_err_code OUT VARCHAR2);

    PROCEDURE sp_exec_create_crbtxreq_tltxcd (p_err_code OUT VARCHAR2, p_tltxcd IN VARCHAR2, p_txdate IN VARCHAR2);

    PROCEDURE pr_RunningRMBatch(p_batchname in varchar2,p_err_code out varchar2);

    PROCEDURE pr_ExecBankRequest(p_xmlmsg in varchar2,p_err_code out varchar2);

    PROCEDURE pr_ExecBankResult(p_xmlmsg in clob,p_err_code out varchar2);

    PROCEDURE pr_ChangeWorkingDate(p_err_code out varchar2);

    PROCEDURE sp_exec_create_crbtxreq_txnum (p_err_code OUT VARCHAR2, p_tltxcd IN VARCHAR2, p_txdate IN VARCHAR2, p_txnum IN VARCHAR2);

    PROCEDURE pr_CreateAdvTransferTransact(p_txmsg in tx.msg_rectype,p_err_code out varchar2);
    PROCEDURE pr_RM_UnholdAccount( pv_strACCTNO varchar2,pv_strErrorCode in out varchar2);
    PROCEDURE pr_RM_UnholdAccountEOD( pv_strACCTNO varchar2,pv_strErrorCode in out varchar2);
    PROCEDURE pr_rmGroupRequest(p_TRFCODE in varchar2,p_err_code out varchar2);
    PROCEDURE sp_exec_create_crbtrflog_auto (p_txdate IN VARCHAR2,p_txnum in varchar2,p_err_code OUT VARCHAR2, p_tlid varchar2 default '0000');
    PROCEDURE sp_exec_create_crbtrflog_multi (pv_trfcode varchar2,p_err_code OUT VARCHAR2);
    PROCEDURE pr_rmSUBReleaseBalance(p_acctno varchar,p_maxamt number, p_bchmdl varchar2, p_err_code  OUT varchar2);
    PROCEDURE pr_rmSUBBAMTTRFByAccount(p_afacctno varchar2,p_txnum varchar2, p_bchmdl varchar, p_err_code  OUT varchar2);
    PROCEDURE FILLTER_CRB_OFFLINE_SYNC(p_BankCode in varchar2, p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2);
    PROCEDURE APPROVE_CRB_OFFLINE_SYNC (p_BankCode in varchar2, p_tlid in varchar2, p_err_code  OUT varchar2, p_err_message  OUT varchar2);
    PROCEDURE UNHOLD_BF_CRB_ONLINE_SYNC(p_BankCode in varchar2, p_tlid in varchar2, p_err_code  OUT varchar2, p_err_message  OUT varchar2);
    PROCEDURE fn_CreateAndGetBatchID(pv_txdate IN VARCHAR2, pv_BankCode IN VARCHAR2, pv_msgid IN VARCHAR2, pv_BathcID Out VARCHAR2, p_err_code out varchar2);
END;
 
/


CREATE OR REPLACE PACKAGE BODY cspks_rmproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   FUNCTION Split (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN str_array
   IS
    i       number :=0;
    pos     number :=0;
    lv_str  varchar2(100) := p_in_string;
    strings str_array;
BEGIN
   -- determine first chuck of string
   pos := instr(lv_str,p_delim,1,1);
   -- while there are chunks left, loop
   WHILE ( pos != 0) LOOP
      -- increment counter
      i := i + 1;
      -- create array element for chuck of string
      strings(i) := substr(lv_str,1,pos-1);
      -- remove chunk from string
      lv_str := substr(lv_str,pos+1,length(lv_str));
      -- determine next chunk
      pos := instr(lv_str,p_delim,1,1);
      -- no last chunk, add to array
      IF pos = 0 THEN
         strings(i+1) := lv_str;
      END IF;
   END LOOP;
   -- return array
   RETURN strings;
END Split;

FUNCTION is_number(p_input IN VARCHAR2)
RETURN number
AS
  v_return_number NUMBER;
BEGIN
  v_return_number := TO_NUMBER( p_input);  RETURN 1;
EXCEPTION
  WHEN OTHERS THEN  RETURN 0;
END is_number;

PROCEDURE pr_CreateCompleteHoldTransact(p_reqid in number,p_err_code out varchar2)
IS
    l_txmsg tx.msg_rectype;
    l_tltx  varchar2(4);
    l_txnum varchar2(20);
    l_currdate varchar2(10);
    l_txdesc    varchar2(250);
    l_err_param varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CreateCompleteHoldTransact');
    plog.debug (pkgctx, '<<BEGIN OF pr_CreateCompleteHoldTransact');

    SELECT DECODE(REQ.TRFCODE,'HOLD','6660','UNHOLD','6661') TLTX
    INTO l_tltx
    FROM CRBTXREQ REQ WHERE REQID=p_reqid;

    SELECT TXDESC into l_txdesc FROM  TLTX WHERE TLTXCD=l_tltx;

    SELECT varvalue
    INTO l_currdate
    FROM sysvar
    WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'BANK';
    l_txmsg.txdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.tltxcd:=l_tltx;
    plog.debug(pkgctx, 'Begin loop');

    FOR rec IN
    (
        SELECT REQ.REQID,REQ.TRFCODE,REQ.OBJKEY TXNUM,REQ.OBJNAME TLTX,REQ.TXDATE,REQ.BANKCODE,REQ.AFACCTNO,
        CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,REQ.BANKACCT BANKACCTNO,CRB.BANKCODE || ':' || CRB.BANKNAME BANKNAME,
        REQ.TXAMT,REQ.STATUS,CI.HOLDBALANCE
        FROM CRBTXREQ REQ,AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB
        WHERE REQ.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
        AND AF.ACCTNO=CI.AFACCTNO AND (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) ='Y' AND REQ.BANKCODE=CRB.BANKCODE
        AND REQ.TRFCODE IN ('HOLD','UNHOLD') AND REQ.STATUS='P' AND REQ.REQID=p_reqid
        AND NOT EXISTS (
            SELECT * FROM TLLOGFLD FLD,TLLOG TL
            WHERE FLD.TXNUM=TL.TXNUM AND FLD.FLDCD='22'
            AND TL.TLTXCD=l_tltx AND FLD.CVALUE = TO_CHAR(REQ.REQID)
        )
    )
    LOOP
        plog.debug(pkgctx, 'Loop for reqid:' || rec.REQID);
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

        --03   SECACCOUNT     C
        l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90   CUSTNAME     C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --91   ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92   LICENSE     C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

        --93   BANACCOUNT     C
        l_txmsg.txfields ('93').defname   := 'BANACCOUNT';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

        --94   BANKNAME     C
        l_txmsg.txfields ('94').defname   := 'BANKNAME';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

        --95   BANKQUEUE     C
        l_txmsg.txfields ('95').defname   := 'BANKQUEUE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

        --96   HOLDAMT     N
        l_txmsg.txfields ('96').defname   := 'HOLDAMT';
        l_txmsg.txfields ('96').TYPE      := 'N';
        l_txmsg.txfields ('96').VALUE     := rec.HOLDBALANCE;

        --10   AMOUNT     N
        l_txmsg.txfields ('10').defname   := 'AMOUNT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.TXAMT;

        --20   TXDATE     D
        l_txmsg.txfields ('20').defname   := 'TXDATE';
        l_txmsg.txfields ('20').TYPE      := 'D';
        l_txmsg.txfields ('20').VALUE     := rec.TXDATE;

        --21   TXNUM     C
        l_txmsg.txfields ('21').defname   := 'TXNUM';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := rec.TXNUM;

        --22   REQID     C
        l_txmsg.txfields ('22').defname   := 'REQID';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := TO_CHAR(rec.REQID);

        --30   DESC     C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        IF l_tltx='6660' THEN
            l_txmsg.txfields ('30').VALUE     := 'Hoan tat phong toa , TXNUM:' || rec.TXNUM;
        ELSE
            l_txmsg.txfields ('30').VALUE     := 'Hoan tat giai toa , TXNUM:' || rec.TXNUM;
        END IF;


        BEGIN
            IF l_tltx='6660' THEN
                IF txpks_#6660.fn_autotxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 6660: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            ELSE
                IF txpks_#6661.fn_autotxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 6661: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END IF;
        END;
    END LOOP;

    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_CreateCompleteHoldTransact');
    plog.setendsection (pkgctx, 'pr_CreateCompleteHoldTransact');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CreateCompleteHoldTransact');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_CreateCompleteHoldTransact;

PROCEDURE pr_CreateAdvTransferTransact(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
IS
    l_txmsg tx.msg_rectype;
    l_tltx  varchar2(4);
    l_txnum varchar2(20);
    l_currdate varchar2(10);
    l_txdesc    varchar2(250);
    l_err_param varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CreateAdvTransferTransact');
    plog.debug (pkgctx, '<<BEGIN OF pr_CreateAdvTransferTransact');

    l_tltx:='6646';


    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    begin
        l_txmsg.batchname        := p_txmsg.txnum;
        plog.debug (pkgctx, 'p_txmsg.txnum' || p_txmsg.txnum);
    exception when others then
        l_txmsg.batchname        := 'DAY';
    end;
    l_txmsg.txdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:=l_tltx;
    l_txmsg.reftxnum := p_txmsg.txnum;
    plog.debug(pkgctx, 'Begin loop');

    for rec in
    (
        SELECT CRA.TRFCODE TRFTYPE,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,CF.FULLNAME,
        CF.ADDRESS,CF.IDCODE LICENSE,
        AF.BANKACCTNO,CRA.REFACCTNO DESACCTNO,CRA.REFACCTNAME DESACCTNAME,CRB.BANKCODE,
        (CRB.BANKCODE || ':' || CRB.BANKNAME) BANKNAME
        FROM
        AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFACCT CRA,CRBDEFBANK CRB
        WHERE AF.ACCTNO = p_txmsg.txfields ('03').VALUE  --Account
        AND CI.AFACCTNO = AF.ACCTNO AND AF.CUSTID=CF.CUSTID
        AND AF.BANKNAME=CRA.REFBANK AND CRA.TRFCODE='TRFADVAMT'
        AND AF.BANKNAME=CRB.BANKCODE
        AND CI.corebank='Y'
    )
    loop -- rec
        plog.debug(pkgctx, 'Loop for txnum : ' || p_txmsg.txnum);
        --set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

        --Set cac field giao dich
        --06   C   TRFTYPE
        l_txmsg.txfields ('06').defname   := 'TRFTYPE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := rec.TRFTYPE;

        --03  SECACCOUNT
        l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90  CUSTNAME
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --91  ADDRESS
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92  LICENSE
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

        --93  BANKACCTNO
        l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

        --05  DESACCTNO
        l_txmsg.txfields ('05').defname   := 'DESACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.DESACCTNO;

        --07  DESACCTNAME
        l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.DESACCTNAME;

        --94  BANKNAME
        l_txmsg.txfields ('94').defname   := 'BANKNAME';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

        --95  BANKQUE
        l_txmsg.txfields ('95').defname   := 'BANKQUE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

        --10  AMOUNT
        l_txmsg.txfields ('10').defname   := 'AMOUNT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := to_number(p_txmsg.txfields ('10').VALUE) - to_number(p_txmsg.txfields ('10').VALUE)*to_number(p_txmsg.txfields ('60').VALUE);

        --02  CATXNUM
        l_txmsg.txfields ('02').defname   := 'CATXNUM';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := p_txmsg.TXNUM;

        --30   C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE :=  utf8nums.c_const_TLTX_TXDESC_6646 || rec.CUSTODYCD || ' ' || utf8nums.c_const_TLTX_TXDESC_6646_amt || to_number(p_txmsg.txfields ('10').VALUE) || ' ' || utf8nums.c_const_TLTX_TXDESC_6646_fee || to_number(p_txmsg.txfields ('11').VALUE);

        BEGIN
            IF txpks_#6646.fn_Autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 6646: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    --Thuc hien Gen bang ke de chuyen ra ngan hang.
    cspks_rmproc.sp_exec_create_crbtxreq_txnum (p_err_code, l_tltx, l_CURRDATE, l_txmsg.txnum) ;
    cspks_rmproc.sp_exec_create_crbtrflog_auto(to_date(l_CURRDATE,systemnums.c_date_format),l_txmsg.txnum,p_err_code);
    if p_err_code <> systemnums.C_SUCCESS then
        plog.setendsection (pkgctx, 'pr_CreateAdvTransferTransact');
        rollback;
        RETURN;
    END IF;
    end loop;

    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_CreateAdvTransferTransact');
    plog.setendsection (pkgctx, 'pr_CreateAdvTransferTransact');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CreateAdvTransferTransact');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_CreateAdvTransferTransact;

PROCEDURE pr_CreateRevertHoldTransact(p_reqid in number,p_err_code out varchar2)
IS
    l_txmsg tx.msg_rectype;
    l_tltx  varchar2(4);
    l_txnum varchar2(20);
    l_currdate varchar2(10);
    l_txdesc    varchar2(250);
    l_err_param varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CreateRevertHoldTransact');
    plog.debug (pkgctx, '<<BEGIN OF pr_CreateRevertHoldTransact');

    SELECT DECODE(REQ.TRFCODE,'HOLD','6620','UNHOLD','6621') TLTX
    INTO l_tltx
    FROM CRBTXREQ REQ WHERE REQID=p_reqid;

    SELECT TXDESC into l_txdesc FROM  TLTX WHERE TLTXCD=l_tltx;

    SELECT varvalue
    INTO l_currdate
    FROM sysvar
    WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'BANK';
    l_txmsg.txdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.tltxcd:=l_tltx;
    plog.debug(pkgctx, 'Begin loop');

    FOR rec IN
    (
        SELECT REQ.REQID,REQ.TRFCODE,REQ.OBJKEY TXNUM,REQ.OBJNAME TLTX,to_char(REQ.TXDATE,'DD/MM/RRRR') TXDATE,REQ.BANKCODE,REQ.AFACCTNO,
        CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,REQ.BANKACCT BANKACCTNO,CRB.BANKCODE || ':' || CRB.BANKNAME BANKNAME,
        REQ.TXAMT,REQ.STATUS,CI.HOLDBALANCE
        FROM CRBTXREQ REQ,AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB
        WHERE REQ.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
        AND AF.ACCTNO=CI.AFACCTNO AND (CI.COREBANK='Y' or af.alternateacct='Y') AND REQ.BANKCODE=CRB.BANKCODE
        AND REQ.TRFCODE IN ('HOLD','UNHOLD') AND REQ.STATUS='P' AND REQ.REQID=p_reqid
        AND NOT EXISTS (
            SELECT * FROM TLLOGFLD FLD,TLLOG TL
            WHERE FLD.TXNUM=TL.TXNUM AND FLD.FLDCD='22'
            AND TL.TLTXCD=l_tltx AND FLD.CVALUE = TO_CHAR(REQ.REQID)
        )
    )
    LOOP
        plog.debug(pkgctx, 'Loop for reqid:' || rec.REQID);
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

        --03   SECACCOUNT     C
        l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

        --90   CUSTNAME     C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

        --91   ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

        --92   LICENSE     C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

        --93   BANACCOUNT     C
        l_txmsg.txfields ('93').defname   := 'BANACCOUNT';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

        --94   BANKNAME     C
        l_txmsg.txfields ('94').defname   := 'BANKNAME';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

        --95   BANKQUEUE     C
        l_txmsg.txfields ('95').defname   := 'BANKQUEUE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

        --96   HOLDAMT     N
        l_txmsg.txfields ('96').defname   := 'HOLDAMT';
        l_txmsg.txfields ('96').TYPE      := 'N';
        l_txmsg.txfields ('96').VALUE     := rec.HOLDBALANCE;

        --10   AMOUNT     N
        l_txmsg.txfields ('10').defname   := 'AMOUNT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.TXAMT;

        --20   TXDATE     D
        l_txmsg.txfields ('20').defname   := 'TXDATE';
        l_txmsg.txfields ('20').TYPE      := 'D';
        l_txmsg.txfields ('20').VALUE     := rec.TXDATE;

        --21   TXNUM     C
        l_txmsg.txfields ('21').defname   := 'TXNUM';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := rec.TXNUM;

        --22   REQID     C
        l_txmsg.txfields ('22').defname   := 'REQID';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := TO_CHAR(rec.REQID);

        --30   DESC     C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        IF l_tltx='6620' THEN
            l_txmsg.txfields ('30').VALUE     := 'Revert phong toa , TXNUM:' || rec.TXNUM;
        ELSE
            l_txmsg.txfields ('30').VALUE     := 'Revert giai toa , TXNUM:' || rec.TXNUM;
        END IF;


        BEGIN
            IF l_tltx='6620' THEN
                IF txpks_#6620.fn_autotxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 6620: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            ELSE
                IF txpks_#6621.fn_autotxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 6621: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END IF;
        END;
    END LOOP;

    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_CreateRevertHoldTransact');
    plog.setendsection (pkgctx, 'pr_CreateRevertHoldTransact');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CreateRevertHoldTransact');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_CreateRevertHoldTransact;

PROCEDURE pr_CreateHoldRqsFor3384(p_reqid in number,p_err_code out varchar2)
IS
    l_txmsg tx.msg_rectype;
    l_afacctno  varchar2(20);
    l_holdamt   number(20,0);
    l_tltx  varchar2(4);
    l_txnum varchar2(20);
    l_currdate varchar2(10);
    l_txdesc    varchar2(250);
    l_err_param varchar2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CreateHoldRqsFor3384');
    plog.debug (pkgctx, '<<BEGIN OF pr_CreateHoldRqsFor3384');
    l_tltx:='6640';

    SELECT varvalue
    INTO l_currdate
    FROM sysvar
    WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    --Lay thong tin TXAMT,AFACCTNO tu BORQSLOG
    SELECT RQS.MSGACCT,RQS.MSGAMT
    INTO l_afacctno,l_holdamt
    FROM BORQSLOG RQS
    WHERE RQS.AUTOID=p_reqid
    AND RQS.TXDATE=TO_DATE(l_currdate,systemnums.C_DATE_FORMAT)
    AND NOT EXISTS (
      SELECT * FROM CRBTXREQ REQ
      WHERE REQ.TXDATE=TO_DATE(l_currdate,'DD/MM/RRRR') AND REQ.REFCODE=RQS.AUTOID
      AND REQ.OBJTYPE='V' AND REQ.OBJNAME='CAR'
    );

    --Tao giao dich

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'BANK';
    l_txmsg.txdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.tltxcd:=l_tltx;
    plog.debug(pkgctx, 'Begin loop');

    FOR rec IN
    (
        --Tinh so du thuc te can hold, chinh = l_holdamt - max(PP-hold pending,0)
        SELECT CF.CUSTODYCD,CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,CF.CAREBY,
        AF.BANKACCTNO,CRB.BANKCODE,CRB.BANKCODE||':'||CRB.BANKNAME BANKNAME,CI.HOLDBALANCE,
        GETAVLPP(l_afacctno) AVLRELEASE,
        l_holdamt - GREATEST(GETAVLPP(l_afacctno)-NVL(HM.HLDAMT,0),0)+ GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0) HOLDAMT
        FROM CIMAST CI,AFMAST AF,CFMAST CF,CRBDEFBANK CRB,
        (
            SELECT NVL(SUM(A.HLDAMT),0) HLDAMT,A.AFACCTNO FROM
            (
                SELECT NVL(SUM(REQ.TXAMT),0) HLDAMT,REQ.AFACCTNO
                FROM crbtxreq REQ
                WHERE REQ.TRFCODE='HOLD' AND REQ.STATUS='P'
                GROUP BY REQ.AFACCTNO
                UNION ALL
                SELECT NVL(SUM(RQ.MSGAMT),0) HLDAMT,RQ.MSGACCT AFACCTNO
                FROM BORQSLOG RQ WHERE RQ.STATUS='H'
                GROUP BY MSGACCT
            ) A GROUP BY A.AFACCTNO
        ) HM
        WHERE CI.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
        AND CI.AFACCTNO = HM.AFACCTNO(+) AND CI.COREBANK='Y'
        AND AF.BANKNAME=CRB.BANKCODE AND CI.AFACCTNO = l_afacctno
    )
    LOOP
        BEGIN
            IF rec.HOLDAMT>0 THEN
                BEGIN
                    --Set txnum
                    SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                    l_txmsg.brid        := substr(l_afacctno,1,4);

                    L_TXMSG.TXFIELDS ('88').DEFNAME := 'CUSTODYCD';
                    L_TXMSG.TXFIELDS ('88').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('88').VALUE := REC.CUSTODYCD;

                    L_TXMSG.TXFIELDS ('03').DEFNAME := 'SECACCOUNT';
                    L_TXMSG.TXFIELDS ('03').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('03').VALUE := l_afacctno;

                    L_TXMSG.TXFIELDS ('90').DEFNAME := 'CUSTNAME';
                    L_TXMSG.TXFIELDS ('90').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('90').VALUE := REC.FULLNAME;

                    L_TXMSG.TXFIELDS ('91').DEFNAME := 'ADDRESS';
                    L_TXMSG.TXFIELDS ('91').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('91').VALUE := REC.ADDRESS;

                    L_TXMSG.TXFIELDS ('92').DEFNAME := 'LICENSE';
                    L_TXMSG.TXFIELDS ('92').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('92').VALUE := REC.LICENSE;

                    L_TXMSG.TXFIELDS ('97').DEFNAME := 'CAREBY';
                    L_TXMSG.TXFIELDS ('97').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('97').VALUE := REC.CAREBY;

                    L_TXMSG.TXFIELDS ('93').DEFNAME := 'BANKACCT';
                    L_TXMSG.TXFIELDS ('93').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('93').VALUE := REC.BANKACCTNO;

                    L_TXMSG.TXFIELDS ('95').DEFNAME := 'BANKNAME';
                    L_TXMSG.TXFIELDS ('95').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('95').VALUE := REC.BANKNAME;

                    L_TXMSG.TXFIELDS ('11').DEFNAME := 'BANKAVAIL';
                    L_TXMSG.TXFIELDS ('11').TYPE := 'N';
                    L_TXMSG.TXFIELDS ('11').VALUE := 0;

                    L_TXMSG.TXFIELDS ('12').DEFNAME := 'BANKHOLDED';
                    L_TXMSG.TXFIELDS ('12').TYPE := 'N';
                    L_TXMSG.TXFIELDS ('12').VALUE := REC.HOLDBALANCE;

                    L_TXMSG.TXFIELDS ('13').DEFNAME := 'AVLRELEASE';
                    L_TXMSG.TXFIELDS ('13').TYPE := 'N';
                    L_TXMSG.TXFIELDS ('13').VALUE := REC.AVLRELEASE;

                    L_TXMSG.TXFIELDS ('96').DEFNAME := 'HOLDAMT';
                    L_TXMSG.TXFIELDS ('96').TYPE := 'N';
                    L_TXMSG.TXFIELDS ('96').VALUE := REC.AVLRELEASE;

                    L_TXMSG.TXFIELDS ('10').DEFNAME := 'AMOUNT';
                    L_TXMSG.TXFIELDS ('10').TYPE := 'N';
                    L_TXMSG.TXFIELDS ('10').VALUE := rec.HOLDAMT;

                    L_TXMSG.TXFIELDS ('30').DEFNAME := 'DESC';
                    L_TXMSG.TXFIELDS ('30').TYPE := 'C';
                    L_TXMSG.TXFIELDS ('30').VALUE := 'Yeu cau phong toa thuc hien quyen mua , requestid:' || p_reqid;

                    BEGIN
                        IF txpks_#6640.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 6640: ' || p_err_code
                           );
                           ROLLBACK;
                           RETURN;
                        END IF;
                    END;

                    --Insert req
                    INSERT INTO CRBTXREQ(REQID,OBJTYPE,OBJNAME,TRFCODE,REFCODE,OBJKEY,TXDATE,
                    BANKCODE,BANKACCT,AFACCTNO,TXAMT,STATUS,REFTXNUM,REFTXDATE,REFVAL,NOTES)
                    VALUES(SEQ_CRBTXREQ.NEXTVAL,'V','CAR','HOLD',p_reqid,l_txmsg.txnum,
                    to_date(l_currdate,systemnums.C_DATE_FORMAT),rec.BANKCODE,rec.BANKACCTNO,
                    l_afacctno,rec.HOLDAMT,'P',null,null,null,L_TXMSG.TXFIELDS ('30').VALUE);
                END;
            ELSE
                BEGIN
                    UPDATE BORQSLOG SET STATUS='H' WHERE AUTOID=p_reqid;
                END;
            END IF;
        END;
    END LOOP;

    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_CreateHoldRqsFor3384');
    plog.setendsection (pkgctx, 'pr_CreateHoldRqsFor3384');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CreateHoldRqsFor3384');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_CreateHoldRqsFor3384;

PROCEDURE pr_RollbackCITRAN(p_txnum in varchar2,p_txdate in varchar2,p_err_code out varchar2)
IS
    l_sql   varchar2(500);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_RollbackCITRAN');
    plog.debug (pkgctx, '<<BEGIN OF pr_RollbackCITRAN');

    FOR rec IN (
        SELECT CT.AUTOID,CT.TXNUM,CT.TXDATE,CT.ACCTNO,CT.TXCD,TX.FIELD FLDNAME,
        DECODE(TX.TXTYPE,'C','-','D','+') TXTYPE,TX.TBLNAME,CT.NAMT AMOUNT
        FROM CITRANA CT,APPTX TX
        WHERE CT.TXCD=TX.TXCD AND TX.APPTYPE='CI'
        AND CT.DELTD='N' AND CT.TXNUM=p_txnum
        AND CT.TXDATE = TO_DATE(p_txdate,'DD/MM/RRRR')
    )
    LOOP
        BEGIN
            l_sql:='UPDATE ' || rec.TBLNAME || ' SET ' || rec.FLDNAME || '=' ||
                   rec.FLDNAME || rec.TXTYPE || TO_CHAR(rec.AMOUNT) ||
                   ' WHERE ACCTNO=' || rec.ACCTNO;
            execute IMMEDIATE l_sql;

            UPDATE CITRANA SET DELTD='Y' WHERE AUTOID=rec.AUTOID;

            COMMIT;

        EXCEPTION
            WHEN OTHERS
            THEN
                p_err_code := errnums.C_SYSTEM_ERROR;
                plog.error(pkgctx,'exec sql error : ' || l_sql);
        END;
    END LOOP;

    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_RollbackCITRAN');
    plog.setendsection (pkgctx, 'pr_RollbackCITRAN');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RollbackCITRAN');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_RollbackCITRAN;
PROCEDURE pr_PreCaculateHoldAmount(p_strIn in varchar2, p_musthold out number,p_err_code out varchar2)
IS
    /*
    - Doi voi tai khoan ca nhan (corebank) --> kiem tra PP truoc khi get so du tu BIDV
    p_strIn : Tham so truyen vao
        --Patten: NB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE[|Securatio]
        --Patten: AB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE|ORGORDERID[|Securatio]
        --Patten: HL|AFACCTNO|AMOUNT
    p_musthold: 0: Ko goi sang BIDV
                1: Goi sang BIDV
    */
    l_caltype varchar2(20);
    l_holdamount number(20,0);
    l_actype varchar2(4);
    l_afacctno varchar2(10);
    l_qtty number(20,0);
    l_price number(20,0);
    l_secubratio number(20,4);
    l_orgorderid varchar2(50);
    l_symbol varchar2(50);
    l_clearday number(4,0);
    l_bratio number(10,0);
    l_minfeeamt number(20,0);
    l_deffeerate number(20,4);
    l_odvalue number(20,0);
    l_arr str_array;
    l_musthold number(20,4);

    v_CIMASTcheck_arr txpks_check.cimastcheck_arrtype;
    l_PP number(20,0);
    l_AVLLIMIT number(20,0);
    l_BALDEFOVD number(20,0);
    L_diff number;
    --v_AVLLIMIT number(20,0);
    l_margintype char(1);
    l_codeid varchar2(20);
    l_BANKAVLBAL number(20,0);
    l_BALANCE number(30,0);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_PreCaculateHoldAmount');
    plog.debug (pkgctx, '<<BEGIN OF pr_PreCaculateHoldAmount');
    --Patten: NB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE[|Securatio]
    --Patten: AB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE|ORGORDERID[|Securatio]
    --Patten: HL|AFACCTNO|AMOUNT
    plog.error('pr_PreCaculateHoldAmount: Beigin');
    l_arr:=Split(p_strIn, '|');
    l_caltype:=l_arr(1);
    l_afacctno:=l_arr(2);

    v_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(l_afacctno,'CIMAST','ACCTNO');

    l_PP := v_CIMASTcheck_arr(0).PP;
    l_AVLLIMIT := v_CIMASTcheck_arr(0).AVLLIMIT;
    l_BALDEFOVD:=v_CIMASTcheck_arr(0).BALDEFOVD;
    l_BALANCE:=v_CIMASTcheck_arr(0).BALANCE;
    l_margintype := v_CIMASTcheck_arr(0).mrtype;

    l_BANKAVLBAL := v_CIMASTcheck_arr(0).BANKAVLBAL;

    p_musthold := 0;

    IF l_caltype='NB' OR l_caltype='AB' THEN
        BEGIN
            l_actype:=l_arr(3);
            l_symbol:=l_arr(4);
            l_qtty:=TO_NUMBER(l_arr(5));
            l_price:=TO_NUMBER(l_arr(6));

            if l_actype<>'XXXX' then
                --Lay ra thong tin ODTYPE tu ACTYPE
                BEGIN
                    SELECT CLEARDAY,BRATIO,MINFEEAMT,DEFFEERATE
                    INTO l_clearday,l_bratio,l_minfeeamt,l_deffeerate
                    FROM ODTYPE WHERE ACTYPE=l_actype;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    plog.error (pkgctx, 'Khong tim thay loai hinh san pham');
                    RAISE errnums.E_SYSTEM_ERROR;
                END;

                IF l_caltype='AB' THEN
                    l_orgorderid:=l_arr(7);
                ELSE
                    l_orgorderid:='';
                END IF;
            else
                IF l_caltype='AB' THEN
                    l_orgorderid:=l_arr(7);
                    l_secubratio:=to_number(l_arr(8));
                ELSE
                    l_orgorderid:='';
                    l_secubratio:=to_number(l_arr(7));
                END IF;
                l_deffeerate:= l_secubratio-100;
                l_minfeeamt:=0;
                l_clearday:=3;
                l_bratio:=100;
            end if;

            l_odvalue:=l_price*l_qtty*l_bratio/100;

            If nvl(l_BALANCE,0) < nvl(l_odvalue,0) then --05/07/2017 Ko so sanh voi PP nua, ma so sanh voi so tien co the rut do muon bo di so tien ung truoc
                p_musthold := 1;
            End If;
        END;
    END IF;
    plog.error('pr_PreCaculateHoldAmount: End p_musthold = '|| p_musthold);
    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_PreCaculateHoldAmount');
    plog.setendsection (pkgctx, 'pr_PreCaculateHoldAmount');
EXCEPTION
    WHEN OTHERS
    THEN
      p_musthold := 0;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_PreCaculateHoldAmount');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_PreCaculateHoldAmount;
PROCEDURE pr_CaculateHoldAmount(p_strIn in varchar2,p_holdamt out number,p_err_code out varchar2)
IS
    l_caltype varchar2(20);
    l_holdamount number(20,0);
    l_actype varchar2(4);
    l_afacctno varchar2(10);
    l_qtty number(20,0);
    l_price number(20,0);
    l_secubratio number(20,4);
    l_orgorderid varchar2(50);
    l_symbol varchar2(50);
    l_clearday number(4,0);
    l_bratio number(10,0);
    l_minfeeamt number(20,0);
    l_deffeerate number(20,4);
    l_odvalue number(20,0);
    l_arr str_array;
    l_musthold number(20,4);

    v_CIMASTcheck_arr txpks_check.cimastcheck_arrtype;
    l_PP number(20,0);
    l_AVLLIMIT number(20,0);
    l_BALDEFOVD number(20,0);
    L_diff number;
    --v_AVLLIMIT number(20,0);
    l_margintype char(1);
    l_codeid varchar2(20);
    l_ORGQTTY number(20,0);
    l_marginrefprice number(20,4);
    l_marginprice number(20,4);
    l_mrpriceloan number(20,4);
    l_mrratiorate number(20,4);
    l_chksysctrl varchar2(1);
    l_ismarginallow varchar2(1);

    l_remainamt number;
    l_istrfbuy char(1);
    l_seclimit number;
    l_BANKAVLBAL number(20);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_CaculateHoldAmount');
    plog.debug (pkgctx, '<<BEGIN OF pr_CaculateHoldAmount');
    --Patten: NB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE[|Securatio]
    --Patten: AB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE|ORGORDERID[|Securatio]
    --Patten: HL|AFACCTNO|AMOUNT
 plog.error('pr_CaculateHoldAmount: Beigin p_strIn = '|| p_strIn||', p_holdamt'||p_holdamt);
    l_remainamt:=0;
    l_musthold:=0;

    l_arr:=Split(p_strIn, '|');
    l_caltype:=l_arr(1);
    l_afacctno:=l_arr(2);

    v_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(l_afacctno,'CIMAST','ACCTNO');

    l_PP := v_CIMASTcheck_arr(0).PP;
    l_AVLLIMIT := v_CIMASTcheck_arr(0).AVLLIMIT;
    l_BALDEFOVD:=v_CIMASTcheck_arr(0).BALDEFOVD;
    l_margintype := v_CIMASTcheck_arr(0).mrtype;
    l_BANKAVLBAL := v_CIMASTcheck_arr(0).BANKAVLBAL;
    IF l_caltype='NB' OR l_caltype='AB' THEN
        BEGIN
            l_actype:=l_arr(3);
            l_symbol:=l_arr(4);
            l_qtty:=TO_NUMBER(l_arr(5));
            l_price:=TO_NUMBER(l_arr(6));

            if l_actype<>'XXXX' then
                --Lay ra thong tin ODTYPE tu ACTYPE
                BEGIN
                    SELECT CLEARDAY,BRATIO,MINFEEAMT,DEFFEERATE
                    INTO l_clearday,l_bratio,l_minfeeamt,l_deffeerate
                    FROM ODTYPE WHERE ACTYPE=l_actype;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    plog.error (pkgctx, 'Khong tim thay loai hinh san pham');
                    RAISE errnums.E_SYSTEM_ERROR;
                END;

                IF l_caltype='AB' THEN
                    l_orgorderid:=l_arr(7);
                ELSE
                    l_orgorderid:='';
                END IF;
            else
                IF l_caltype='AB' THEN
                    l_orgorderid:=l_arr(7);
                    l_secubratio:=to_number(l_arr(8));
                ELSE
                    l_orgorderid:='';
                    l_secubratio:=to_number(l_arr(7));
                END IF;
                l_deffeerate:= l_secubratio-100;
                l_minfeeamt:=0;
                l_clearday:=3;
                l_bratio:=100;
            end if;
            l_odvalue:=l_price*l_qtty*l_bratio/100;


            IF l_caltype='NB' THEN --Lenh dat
               p_holdamt:=ceil(l_BANKAVLBAL);
                p_err_code:=0;
                plog.debug (pkgctx, '<<END OF pr_CaculateHoldAmount');
                plog.setendsection (pkgctx, 'pr_CaculateHoldAmount');
                RETURN;

                --locpt hold luon so max (toan bo tien ngan hang, cuoi ngay khong xai het thi unhold)


                BEGIN
                    if l_margintype not in ('S','T') then

                        --Lenh dat moi
                        SELECT GREATEST(l_odvalue - l_PP +
                                        CASE WHEN l_minfeeamt>l_odvalue*l_deffeerate/100 THEN l_minfeeamt ELSE l_odvalue*l_deffeerate/100 END
                                       ,0)
                                       --+ GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0)
                                       MUSTHOLDAMT
                               INTO l_musthold
                        FROM AFMAST AF,CIMAST CI
                        WHERE AF.ACCTNO=CI.AFACCTNO AND AF.ACCTNO=l_afacctno
                        and l_caltype='NB';
                    else
                        --Lay thong tin Margin
                        select marginrefprice, marginprice, codeid
                        into l_marginrefprice, l_marginprice,l_codeid
                        from securities_info
                        where SYMBOL = UPPER(TRIM(l_symbol));

                        select nvl(rsk.mrratioloan,0),nvl(rsk.mrpriceloan,0),
                               nvl(lnt.chksysctrl,'N'), nvl(rsk.ismarginallow,'N'), aft.istrfbuy
                        into l_mrratiorate,l_mrpriceloan,
                            l_chksysctrl, l_ismarginallow,l_istrfbuy
                        from afmast af, aftype aft, lntype lnt,
                            (select * from afserisk where codeid = l_codeid) rsk
                        where af.actype = aft.actype
                        and aft.lntype = lnt.actype(+)
                        and af.actype = rsk.actype(+)
                        and af.acctno = l_afacctno;

                        /*--Begin Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua
                        BEGIN
                            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)/(case when inf.basicprice<=0 then 1 else inf.basicprice end) - nvl(aclm.seqtty,0)
                            into l_remainamt
                            from securities_risk rsk, securities_info inf,
                                (select * from afselimit where afacctno = l_afacctno) selm,
                                (select * from v_getaccountseclimit where afacctno = l_afacctno) aclm
                            where rsk.codeid = selm.codeid(+) and rsk.codeid = aclm.codeid(+)
                            and rsk.codeid= inf.codeid
                            and rsk.codeid = l_codeid;
                        exception when others then
                            l_remainamt := 0;
                        END;
                        l_remainamt:= greatest(l_remainamt,0);
                        --End Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua*/

                        --Begin Lay thong tin Ham muc chung khoan con lai
                        begin
                            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end) into l_seclimit
                            from securities_risk rsk,
                                (select * from afselimit where afacctno = l_afacctno) selm
                            where rsk.codeid = selm.codeid(+)
                            and rsk.codeid = l_codeid;
                        exception when others then
                            l_seclimit:=0;
                        end;
                        if l_seclimit>0 then
                            begin
                                select l_seclimit - nvl(aclm.seqtty,0)*  l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) into l_remainamt
                                from v_getaccountseclimit aclm where afacctno = l_afacctno and codeid = l_codeid;
                            exception when others then
                                l_remainamt:=l_seclimit;
                            end;
                        end if;
                        l_remainamt:= greatest(l_remainamt,0);

                        --End Lay thong tin Ham muc chung khoan con lai
                        --

                        select  greatest(
                                        ceil(GREATEST(
                                                        l_price*l_qtty*(1+l_deffeerate/100) - least(l_qtty*l_mrratiorate/100 * least(l_marginrefprice, l_marginprice),l_remainamt) - l_PP
                                                    ,0)), --So voi PPSE

                                        ceil(l_price*l_qtty*(1+l_deffeerate/100) - l_AVLLIMIT) --So voi han muc
                                        )
                                --+ GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0)
                               INTO l_musthold
                        FROM AFMAST AF,CIMAST CI
                        WHERE AF.ACCTNO=CI.AFACCTNO AND AF.ACCTNO=l_afacctno
                        and l_caltype='NB';
                    end if;
                EXCEPTION
                    WHEN OTHERS THEN
                        plog.error (pkgctx, 'Khong tim thay ket qua/lenh trung ,loai lenh: '
                                    ||l_caltype||' afacctno:'||l_afacctno||',ck:'||l_symbol||',sl:'||l_qtty||',gia:'||l_price);
                        RAISE errnums.E_SYSTEM_ERROR;
                END;
            else --Lenh sua
                p_holdamt := ceil(l_BANKAVLBAL);
                p_err_code:=0;
                plog.debug (pkgctx, '<<END OF pr_CaculateHoldAmount');
                plog.setendsection (pkgctx, 'pr_CaculateHoldAmount');
                RETURN;

                 --locpt hold luon so max (toan bo tien ngan hang, cuoi ngay khong xai het thi unhold)

                select (l_price*l_qtty - remainqtty * quoteprice - execamt) * bratio/100 diff, codeid,remainqtty+execqtty orgqtty into L_diff, l_codeid,l_ORGQTTY from odmast where orderid =l_orgorderid;
                if l_margintype not in ('S','T') then
                    IF NOT (round(to_number(l_PP),0) >= ceil(L_diff)) THEN
                        l_musthold:=ceil(L_diff) - round(to_number(l_PP),0);
                    else
                        l_musthold:=0;
                    END IF;
                else
                    select marginrefprice, marginprice
                    into l_marginrefprice, l_marginprice
                    from securities_info
                    where codeid = l_codeid;
                    select nvl(rsk.mrratioloan,0),nvl(rsk.mrpriceloan,0),
                           nvl(lnt.chksysctrl,'N'), nvl(rsk.ismarginallow,'N'),aft.istrfbuy
                    into l_mrratiorate,l_mrpriceloan,
                        l_chksysctrl, l_ismarginallow,l_istrfbuy
                    from afmast af, aftype aft, lntype lnt,
                        (select * from afserisk where codeid = l_codeid) rsk
                    where af.actype = aft.actype
                    and aft.lntype = lnt.actype(+)
                    and af.actype = rsk.actype(+)
                    and af.acctno = l_afacctno;

                    /*--Begin Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua
                    BEGIN
                        select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)/(case when inf.basicprice<=0 then 1 else inf.basicprice end) - nvl(aclm.seqtty,0)
                        into l_remainamt
                        from securities_risk rsk, securities_info inf,
                            (select * from afselimit where afacctno = l_afacctno) selm,
                            (select * from v_getaccountseclimit where afacctno = l_afacctno) aclm
                        where rsk.codeid = selm.codeid(+) and rsk.codeid = aclm.codeid(+)
                        and rsk.codeid= inf.codeid
                        and rsk.codeid = l_codeid;
                    exception when others then
                        l_remainamt := 0;
                    END;
                    l_remainamt:= greatest(l_remainamt,0);
                    --End Lay ra so luong chung khoan toi da mua cho ve duoc phep cong vao suc mua*/
                    --
                    --Begin Lay thong tin Ham muc chung khoan con lai
                    begin
                        select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end) into l_seclimit
                        from securities_risk rsk,
                            (select * from afselimit where afacctno = l_afacctno) selm
                        where rsk.codeid = selm.codeid(+)
                        and rsk.codeid = l_codeid;
                    exception when others then
                        l_seclimit:=0;
                    end;
                    if l_seclimit>0 then
                        begin
                            select l_seclimit - nvl(aclm.seqtty,0)*  l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan) into l_remainamt
                            from v_getaccountseclimit aclm where afacctno = l_afacctno and codeid = l_codeid;
                        exception when others then
                            l_remainamt:=l_seclimit;
                        end;
                    end if;
                    l_remainamt:= greatest(l_remainamt,0);

                    --End Lay thong tin Ham muc chung khoan con lai

                    if (l_chksysctrl = 'Y' and l_ismarginallow = 'N') then
                        l_musthold:=greatest(ceil(l_diff)-l_PP,0);
                    ELSE
                        -- tinh ra gia tri chung khoan tinh lai cho PPse
                        --l_qtty_ppse:=l_qtty- l_ORGQTTY;
                        if l_chksysctrl = 'Y' then
                            l_musthold:=greatest(ceil(l_diff-least((l_qtty- l_ORGQTTY)*l_mrratiorate/100 * least(l_marginrefprice, l_mrpriceloan),l_remainamt))-l_PP,0);
                        else
                            l_musthold:=greatest(ceil(l_diff -least((l_qtty- l_ORGQTTY)*l_mrratiorate/100 * least(l_marginprice, l_mrpriceloan),l_remainamt))-l_PP,0);
                        end if;
                    end if;
                end if;
            end if;


            /*IF l_caltype='AB' THEN
                l_orgorderid:=l_arr(7);
            ELSE
                l_orgorderid:='';
            END IF;*/
            --Tinh toan so du can hold
            /*BEGIN
                SELECT MST.MUSTHOLDAMT
                INTO l_musthold
                FROM
                (
                    SELECT GREATEST(l_odvalue - GREATEST(GETAVLPP(l_afacctno)-NVL(HM.HLDAMT,0),0) +
                        CASE WHEN l_minfeeamt>l_odvalue*l_deffeerate/100
                        THEN l_minfeeamt ELSE l_odvalue*l_deffeerate/100 END,0) +
                        GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0)
                    MUSTHOLDAMT
                    FROM AFMAST AF,CIMAST CI,
                    (
                        SELECT NVL(SUM(A.HLDAMT),0) HLDAMT,A.AFACCTNO FROM
                        (
                            SELECT NVL(SUM(REQ.TXAMT),0) HLDAMT,REQ.AFACCTNO
                            FROM crbtxreq REQ
                            WHERE REQ.TRFCODE='HOLD' AND REQ.STATUS='P'
                            GROUP BY REQ.AFACCTNO
                            UNION ALL
                            SELECT NVL(SUM(RQ.MSGAMT),0) HLDAMT,RQ.MSGACCT AFACCTNO
                            FROM BORQSLOG RQ WHERE RQ.STATUS='H'
                            GROUP BY MSGACCT
                        ) A GROUP BY A.AFACCTNO
                    ) HM
                    WHERE AF.ACCTNO=CI.AFACCTNO AND AF.ACCTNO=HM.AFACCTNO(+) AND AF.ACCTNO=l_afacctno
                    UNION ALL
                    SELECT GREATEST(l_odvalue - GREATEST(GETAVLPP(l_afacctno)-NVL(HM.HLDAMT,0),0) - TL.MSGAMT +
                        CASE WHEN l_minfeeamt>l_odvalue*l_deffeerate/100
                        THEN l_minfeeamt ELSE l_odvalue*l_deffeerate/100 END,0) +
                        GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0)
                    MUSTHOLDAMT
                    FROM AFMAST AF,CIMAST CI,ODMAST OD,TLLOG TL,
                    (
                        SELECT NVL(SUM(A.HLDAMT),0) HLDAMT,A.AFACCTNO FROM
                        (
                            SELECT NVL(SUM(REQ.TXAMT),0) HLDAMT,REQ.AFACCTNO
                            FROM crbtxreq REQ
                            WHERE REQ.TRFCODE='HOLD' AND REQ.STATUS='P'
                            GROUP BY REQ.AFACCTNO
                            UNION ALL
                            SELECT NVL(SUM(RQ.MSGAMT),0) HLDAMT,RQ.MSGACCT AFACCTNO
                            FROM BORQSLOG RQ WHERE RQ.STATUS='H'
                            GROUP BY MSGACCT
                        ) A GROUP BY A.AFACCTNO
                    ) HM
                    WHERE OD.AFACCTNO=AF.ACCTNO AND AF.ACCTNO=CI.AFACCTNO
                    AND OD.DELTD<>'Y' AND OD.ORDERID=l_orgorderid
                    AND OD.TXNUM=TL.TXNUM AND AF.ACCTNO=HM.AFACCTNO(+) AND AF.ACCTNO=l_afacctno
                ) MST;
            EXCEPTION
                WHEN OTHERS THEN
                    plog.error (pkgctx, 'Khong tim thay ket qua/lenh trung ,loai lenh: '
                                ||l_caltype||' afacctno:'||l_afacctno||',ck:'||l_symbol||',sl:'||l_qtty||',gia:'||l_price);
                    RAISE errnums.E_SYSTEM_ERROR;
            END;*/

        END;
    ELSE
        l_holdamount:=TO_NUMBER(l_arr(3));
        if l_caltype='HA' then --Hold Advance Transaction
 --12/10/2015 TruongLD Add, doi voi GD chuyen tien noi no & ra ngoai --> khong hold truc tiep tu Bank
            --> Return cho nay
            --> Truong hop sau nay neu can hold khi thuc hien GD chuyen tien ra ngoai va noi bo --> chinh lai doan nay
            l_musthold := 0;
 --Trong phan Hold Advance Transaction, Se uu tien dung tien Hold truoc tien UTTB
            /*
            BEGIN

                SELECT GREATEST(GREATEST(l_holdamount-l_pp,l_holdamount-l_BALDEFOVD,0),least(l_holdamount - ci.balance, ci.bankavlbal)) MUSTHOLDAMT
                INTO l_musthold
                FROM AFMAST AF,CIMAST CI
                WHERE AF.ACCTNO=CI.AFACCTNO AND AF.ACCTNO=l_afacctno;

            EXCEPTION
                WHEN OTHERS THEN
                plog.error (pkgctx, 'Khong tim thay thong tin hold '
                                    ||l_caltype||' afacctno:'||l_afacctno||',hold:'||l_holdamount);
                RAISE errnums.E_SYSTEM_ERROR;
            END;
            */
            --End TruongLD


        else --Hold Normal Transaction
            BEGIN
                SELECT GREATEST(l_holdamount-l_pp,l_holdamount-l_BALDEFOVD,0) MUSTHOLDAMT
                INTO l_musthold
                FROM AFMAST AF,CIMAST CI
                WHERE AF.ACCTNO=CI.AFACCTNO AND AF.ACCTNO=l_afacctno;
            EXCEPTION
                WHEN OTHERS THEN
                plog.error (pkgctx, 'Khong tim thay thong tin hold '
                                    ||l_caltype||' afacctno:'||l_afacctno||',hold:'||l_holdamount);
                RAISE errnums.E_SYSTEM_ERROR;
            END;
        end if;
    END IF;
    p_holdamt:=ceil(l_musthold);
    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_CaculateHoldAmount');
    plog.setendsection (pkgctx, 'pr_CaculateHoldAmount');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_CaculateHoldAmount');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_CaculateHoldAmount;



PROCEDURE pr_GetBankRef(p_bankcode in varchar2,p_txdate in varchar2,p_refcode out varchar2,p_err_code out varchar2)
IS
    TYPE v_CurTyp  IS REF CURSOR;
    l_strsql varchar2(1000);
    l_refcode varchar2(200);
    c1  v_CurTyp;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_GetBankRef');
    plog.debug (pkgctx, '<<BEGIN OF pr_GetBankRef');

    l_strsql :=
           'SELECT TO_CHAR(TO_DATE('''
        || p_txdate
        || ''',''DD/MM/RRRR''),''YYMMDD'') || LPAD(SEQ_BANKREF'
        || p_bankcode
        || '.NEXTVAL,6,0) REF FROM DUAL';
    OPEN c1 FOR l_strsql;
    LOOP
        FETCH c1 INTO l_refcode;
        EXIT WHEN c1%NOTFOUND;
    END LOOP;

    IF l_refcode=NULL THEN p_refcode:=l_refcode; ELSE p_refcode:=''; END IF;
    p_err_code:='0';

    plog.debug (pkgctx, '<<END OF pr_GetBankRef');
    plog.setendsection (pkgctx, 'pr_GetBankRef');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_GetBankRef');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_GetBankRef;

PROCEDURE sp_exec_create_crbtrflog (p_err_code OUT VARCHAR2, p_txdate IN VARCHAR2,
  p_tlid IN VARCHAR2, p_brid IN VARCHAR2,p_trfcode  IN VARCHAR2, p_lreqid IN VARCHAR2)
IS
TYPE v_CurTyp  IS REF CURSOR;
v_BANKCODE  VARCHAR2(20);
v_TRFCODE   VARCHAR2(20);
v_AFFECTDATE VARCHAR2(10);
v_REFCODE   VARCHAR2(100);
v_TRFLOGID  NUMBER(20,0);
v_VERSION  VARCHAR2(20);
c1        v_CurTyp;
c2        v_CurTyp;
c3        v_CurTyp;
c4        v_CurTyp;
v_stmt_str      VARCHAR2(5000);
v_count NUMBER(20,0);
BEGIN
  plog.setbeginsection (pkgctx, 'sp_exec_create_crbtrflog');
  plog.debug (pkgctx, '<<BEGIN OF sp_exec_create_crbtrflog');

  p_err_code:='0';
  -- Dynamic SQL statement with placeholder:
  v_stmt_str := 'SELECT DISTINCT BANKCODE FROM CRBTXREQ WHERE REQID IN (' || p_lreqid || ')';
  OPEN c1 FOR v_stmt_str;
  --Luot qua danh sach bankcode cua bang ke
  LOOP
    FETCH c1 INTO v_BANKCODE;
    EXIT WHEN c1%NOTFOUND;

    --Luot qua danh sach cac TRFCODE cua bang ke
    IF p_trfcode IS NULL THEN
        v_stmt_str := 'SELECT DISTINCT TRFCODE FROM CRBTXREQ WHERE BANKCODE=''' || v_BANKCODE || ''' AND REQID IN (' || p_lreqid || ') AND STATUS=''P''';
    ELSE
        v_stmt_str := 'SELECT DISTINCT TRFCODE FROM CRBTXREQ WHERE BANKCODE=''' || v_BANKCODE || ''' AND REQID IN (' || p_lreqid || ') AND STATUS=''P'' AND TRFCODE='''|| p_trfcode ||'''';
    END IF;

    OPEN c2 FOR v_stmt_str;
    LOOP
       BEGIN
           --Voi moi TRFCODE , sinh 1 ma bang ke tuong ung
           FETCH c2 INTO v_TRFCODE;
           EXIT WHEN c2%NOTFOUND;
           --Loc ra cac bang ke voi ngay affectdate khac nhau
           v_stmt_str := 'SELECT DISTINCT TO_CHAR(AFFECTDATE,''DD/MM/RRRR'') FROM CRBTXREQ WHERE BANKCODE=''' || v_BANKCODE || ''' AND TRFCODE=''' || v_TRFCODE || ''' AND REQID IN (' || p_lreqid || ')';
           OPEN c3 FOR  v_stmt_str;
           LOOP
               BEGIN
                   FETCH c3 INTO v_AFFECTDATE;
                   EXIT WHEN c3%NOTFOUND;

                   --Voi mot so ma,can gom bang ke theo ref
                   IF v_TRFCODE='SEREJECTDEPOSIT' OR v_TRFCODE='SESENDDEPOSIT'
                    OR v_TRFCODE='SESENDWITHDRAW' OR v_TRFCODE='SEREJECTWITHDRAW' THEN
                        BEGIN
                            v_stmt_str := 'SELECT DISTINCT REFCODE FROM CRBTXREQ WHERE BANKCODE=''' || v_BANKCODE || ''' AND TRFCODE=''' || v_TRFCODE || ''' AND AFFECTDATE=TO_DATE(''' || v_AFFECTDATE || ''',''DD/MM/RRRR'') AND REQID IN (' || p_lreqid || ')';
                            OPEN c4 FOR  v_stmt_str;
                            LOOP
                                BEGIN
                                    FETCH c4 INTO v_REFCODE;
                                    EXIT WHEN c4%NOTFOUND;

                                    --Neu la cap nhat vao bang cu thi phai detect xem da co ban ghi cu o trang thai cho duyet chua
                                    --Neu co roi thi cap nhat, chua co thi sinh moi, co roi thi cap nhat vao
                                    BEGIN
                                      SELECT VERSION,AUTOID INTO v_VERSION,v_TRFLOGID
                                      FROM CRBTRFLOG
                                      WHERE AUTOID IN (
                                          SELECT MAX(CRB.AUTOID) FROM CRBTRFLOG CRB
                                          WHERE REFBANK=v_BANKCODE AND TRFCODE=v_TRFCODE
                                          AND AFFECTDATE=TO_DATE(v_AFFECTDATE,'DD/MM/RRRR') AND STATUS='P'
                                          AND EXISTS (
                                            SELECT DTL.* FROM CRBTRFLOGDTL DTL,CRBTXREQ RQ
                                            WHERE DTL.REFREQID=RQ.REQID AND DTL.VERSION=CRB.VERSION
                                            AND DTL.BANKCODE=CRB.REFBANK AND DTL.TXDATE=CRB.TXDATE
                                            AND DTL.TRFCODE=CRB.TRFCODE AND RQ.REFCODE=v_REFCODE
                                          )
                                      );
                                    EXCEPTION WHEN NO_DATA_FOUND THEN
                                      v_TRFLOGID:=NULL;
                                      v_VERSION:=NULL;
                                    END;

                                    IF v_TRFLOGID IS NULL THEN
                                      BEGIN
                                            --Lay ID cua CRBTRFLOG
                                            SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

                                            SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
                                            (SELECT ROWNUM ODR, INVACCT
                                            FROM (SELECT VERSION INVACCT
                                            FROM CRBTRFLOG WHERE TXDATE=TO_DATE(p_txdate,'DD/MM/RRRR') AND TRFCODE=v_TRFCODE
                                            ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

                                            --Log voi CRBTRFLOG: STATUS = PENDING. S? d?ng tru?ng FeedBack d? c?p nh?t b?ng chi ti?t
                                            INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
                                            SELECT v_TRFLOGID, v_VERSION, TO_DATE(p_txdate,'DD/MM/RRRR'), TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), p_tlid,
                                            SYSTIMESTAMP, v_BANKCODE, v_TRFCODE, 'P','N', TO_CHAR(p_lreqid) FROM DUAL;
                                      END;
                                    ELSE
                                      BEGIN
                                          UPDATE CRBTRFLOG SET FEEDBACK=TO_CHAR(p_lreqid) WHERE AUTOID=v_TRFLOGID;
                                      END;
                                    END IF;

                                    INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                                    FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                                    SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'VERSION',
                                    NULL, TO_CHAR(v_TRFLOGID), 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                                    INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                                    FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                                    SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'REFBANK',
                                    NULL, v_BANKCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                                    INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                                    FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                                    SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'TRFCODE',
                                    NULL, v_TRFCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;

                                    --Cap nhat CRBTRFLOGDTL
                                    FOR rec IN
                                    (
                                        SELECT REQID,OBJTYPE,OBJNAME,TRFCODE,REFCODE,OBJKEY,TXDATE,AFFECTDATE,BANKCODE,BANKACCT,AFACCTNO,TXAMT,STATUS,NOTES
                                        FROM CRBTXREQ
                                        WHERE BANKCODE=v_BANKCODE AND TRFCODE=v_TRFCODE AND AFFECTDATE = TO_DATE(v_AFFECTDATE,'DD/MM/RRRR') and via ='RPT'
                                        AND REFCODE=v_REFCODE AND INSTR(p_lreqid || ',',TO_CHAR(REQID) || ',',1)>0
                                    )
                                    LOOP
                                        BEGIN
                                            INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS)
                                            VALUES(SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,rec.BANKCODE,rec.TRFCODE,TO_DATE(p_txdate,'DD/MM/RRRR'),rec.REQID,rec.AFACCTNO,rec.TXAMT,rec.NOTES,'P');

                                            UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=rec.REQID AND STATUS='P';
                                        END;
                                    END LOOP;
                                END;
                            END LOOP;
                        END;
                   ELSE
                        BEGIN
                            --Neu la cap nhat vao bang cu thi phai detect xem da co ban ghi cu o trang thai cho duyet chua
                            --Neu co roi thi cap nhat, chua co thi sinh moi, co roi thi cap nhat vao
                            /*BEGIN
                                 SELECT VERSION,AUTOID INTO v_VERSION,v_TRFLOGID FROM CRBTRFLOG
                                 WHERE AUTOID IN (
                                     SELECT MAX(AUTOID) FROM CRBTRFLOG
                                     WHERE REFBANK=v_BANKCODE AND TRFCODE=v_TRFCODE
                                     AND AFFECTDATE=TO_DATE(v_AFFECTDATE,'DD/MM/RRRR') AND STATUS='P'
                                     and txdate = TO_DATE(p_txdate,'DD/MM/RRRR')
                                 );
                            EXCEPTION WHEN NO_DATA_FOUND THEN
                                 v_TRFLOGID:=NULL;
                                 v_VERSION:=NULL;
                            END;

                           IF v_TRFLOGID IS NULL THEN
                                BEGIN
                                   --Lay ID cua CRBTRFLOG
                                   SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

                                   SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
                                     (SELECT ROWNUM ODR, INVACCT
                                     FROM (SELECT VERSION INVACCT
                                       FROM CRBTRFLOG WHERE TXDATE=TO_DATE(p_txdate,'DD/MM/RRRR') AND TRFCODE=v_TRFCODE
                                       ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

                                   --Log voi CRBTRFLOG: STATUS = PENDING. S? d?ng tru?ng FeedBack d? c?p nh?t b?ng chi ti?t
                                   INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
                                   SELECT v_TRFLOGID, v_VERSION, TO_DATE(p_txdate,'DD/MM/RRRR'), TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), p_tlid,
                                     SYSTIMESTAMP, v_BANKCODE, v_TRFCODE, 'P','N', TO_CHAR(p_lreqid) FROM DUAL;
                                END;
                           ELSE
                                BEGIN
                                    UPDATE CRBTRFLOG SET FEEDBACK=TO_CHAR(p_lreqid) WHERE AUTOID=v_TRFLOGID;
                                END;
                           END IF;*/
                           --Chinh lai moi lan gom bang ke thi sinh ra bang ke moi, khong gom vao bang ke cu nua.
                           BEGIN
                               --Lay ID cua CRBTRFLOG
                               SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

                               SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
                                 (SELECT ROWNUM ODR, INVACCT
                                 FROM (SELECT VERSION INVACCT
                                   FROM CRBTRFLOG WHERE TXDATE=TO_DATE(p_txdate,'DD/MM/RRRR') AND TRFCODE=v_TRFCODE
                                   ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

                               --Log voi CRBTRFLOG: STATUS = PENDING. S? d?ng tru?ng FeedBack d? c?p nh?t b?ng chi ti?t
                               INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
                               SELECT v_TRFLOGID, v_VERSION, TO_DATE(p_txdate,'DD/MM/RRRR'), TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), p_tlid,
                                 SYSTIMESTAMP, v_BANKCODE, v_TRFCODE, 'P','N', TO_CHAR(p_lreqid) FROM DUAL;
                           END;

                           INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                             FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                           SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'VERSION',
                             NULL, TO_CHAR(v_TRFLOGID), 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                           INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                             FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                           SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'REFBANK',
                             NULL, v_BANKCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
                           INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
                             FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
                           SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, p_tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'TRFCODE',
                             NULL, v_TRFCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;

                           --Cap nhat CRBTRFLOGDTL
                           FOR rec IN
                           (
                               SELECT REQID,OBJTYPE,OBJNAME,TRFCODE,REFCODE,OBJKEY,TXDATE,
                               AFFECTDATE,BANKCODE,BANKACCT,AFACCTNO,TXAMT,STATUS,NOTES,REFVAL,grpreqid
                               FROM CRBTXREQ
                               WHERE BANKCODE=v_BANKCODE AND TRFCODE=v_TRFCODE
                               AND AFFECTDATE = TO_DATE(v_AFFECTDATE,'DD/MM/RRRR') and via ='RPT'
                               AND INSTR(',' || p_lreqid || ',',',' || TO_CHAR(REQID) || ',',1)>0
                           )
                           LOOP

                               BEGIN
                                   INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS,REFHOLDID)
                                   VALUES(SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,rec.BANKCODE,rec.TRFCODE,TO_DATE(p_txdate,'DD/MM/RRRR'),
                                            rec.REQID,rec.AFACCTNO,rec.TXAMT,rec.NOTES,'P',rec.REFVAL);

                                   UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=rec.REQID AND STATUS='P';
                               END;
                               if length(rec.grpreqid)>0 then
                                   --Bang ke  CRBTRFLOGDTL join voi CRBTRFLOG theo txdate, version, trfcode

                                   INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS,REFHOLDID)
                                   select SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,mst.BANKCODE,rec.TRFCODE,TO_DATE(p_txdate,'DD/MM/RRRR'),
                                            mst.REQID,mst.AFACCTNO,mst.TXAMT,mst.NOTES,'P',mst.REFVAL
                                   from CRBTXREQ mst where grpreqid = rec.grpreqid and reqid <> rec.grpreqid;

                                   UPDATE CRBTXREQ SET STATUS='A' WHERE REQID<>rec.grpreqid and grpreqid = rec.grpreqid AND STATUS='P';
                               end if;

                           END LOOP;
                        END;
                   END IF;
               END;
           END LOOP;
       END;
    END LOOP;
    CLOSE c2;
  END LOOP;
  CLOSE c1;

  COMMIT;

  plog.debug (pkgctx, '<<END OF sp_exec_create_crbtrflog');
  plog.setendsection (pkgctx, 'sp_exec_create_crbtrflog');

  RETURN;
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code:=  '-670102'; --Loi gen bang ke
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_exec_create_crbtrflog');
END sp_exec_create_crbtrflog;


PROCEDURE sp_exec_create_crbtrflog_auto (p_txdate IN VARCHAR2,p_txnum in varchar2,p_err_code OUT VARCHAR2, p_tlid varchar2 default '0000')
IS

v_AFFECTDATE VARCHAR2(10);
v_TRFLOGID  NUMBER(20,0);
v_VERSION  VARCHAR2(20);
v_count NUMBER(20,0);
v_PLID VARCHAR2(50);
BEGIN
    plog.setbeginsection (pkgctx, 'sp_exec_create_crbtrflog_auto');
    plog.debug (pkgctx, '<<BEGIN OF sp_exec_create_crbtrflog_auto');

    --p_err_code:='0';
    v_PLID := p_tlid;
    --plog.error (pkgctx, 'p_txdate:' || p_txdate);
    --plog.error (pkgctx, 'p_txnum:' || p_txnum);
    if v_PLID = '0000' then
        begin
            select tlid into v_PLID  from tllog4dr where txnum = p_txnum and txdate = to_date(p_txdate,'DD/MM/RRRR');
        exception when others then
            --plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
            v_PLID :='0000';
        end;
    end if;
    --plog.error (pkgctx, 'v_PLID:' || v_PLID);
    BEGIN

        for rec in (
            select req.*, '' tlid from crbtxreq req
            where req.objkey = p_txnum and req.txdate = to_date(p_txdate,'DD/MM/RRRR') and status ='P'
            and (grpreqid is null or grpreqid = reqid) and req.via ='RPT'
            and trfcode not in ('UNHOLD','HOLD')
        )
        loop
            SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

            SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
              (SELECT ROWNUM ODR, INVACCT
              FROM (SELECT VERSION INVACCT
                FROM CRBTRFLOG WHERE TXDATE=TO_DATE(p_txdate,'DD/MM/RRRR') AND TRFCODE=rec.TRFCODE
                ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

            --Log voi CRBTRFLOG: STATUS = PENDING. S? d?ng tru?ng FeedBack d? c?p nh?t b?ng chi ti?t
            INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
            SELECT v_TRFLOGID, v_VERSION, TO_DATE(p_txdate,'DD/MM/RRRR'), rec.AFFECTDATE, v_PLID,
              SYSTIMESTAMP, rec.BANKCODE, rec.TRFCODE, 'P','N', TO_CHAR(rec.reqid) FROM DUAL;

            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, rec.tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'VERSION',
              NULL, TO_CHAR(v_TRFLOGID), 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, rec.tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'REFBANK',
              NULL, rec.BANKCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, rec.tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'TRFCODE',
              NULL, rec.TRFCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;

            --Cap nhat CRBTRFLOGDTL
            BEGIN
                INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS,REFHOLDID)
                VALUES(SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,rec.BANKCODE,rec.TRFCODE,TO_DATE(p_txdate,'DD/MM/RRRR'),
                       rec.REQID,rec.AFACCTNO,rec.TXAMT,rec.NOTES,'P',rec.REFVAL);

                UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=rec.REQID AND STATUS='P';
            END;
            if length(rec.grpreqid)>0 then
                --Bang ke  CRBTRFLOGDTL join voi CRBTRFLOG theo txdate, version, trfcode

                INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS,REFHOLDID)
                select SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,mst.BANKCODE,rec.TRFCODE,TO_DATE(p_txdate,'DD/MM/RRRR'),
                      mst.REQID,mst.AFACCTNO,mst.TXAMT,mst.NOTES,'P',mst.REFVAL
                from CRBTXREQ mst where grpreqid = rec.grpreqid and reqid <> rec.grpreqid;

                UPDATE CRBTXREQ SET STATUS='A' WHERE REQID<>rec.grpreqid and grpreqid = rec.grpreqid AND STATUS='P';
            end if;
        end loop;

    END;


    plog.debug (pkgctx, '<<END OF sp_exec_create_crbtrflog_auto');
    plog.setendsection (pkgctx, 'sp_exec_create_crbtrflog_auto');

    RETURN;
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code:=  '-670102'; --Loi gen bang ke
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_exec_create_crbtrflog_auto');
END sp_exec_create_crbtrflog_auto;

PROCEDURE sp_exec_create_crbtrflog_multi (pv_trfcode varchar2,p_err_code OUT VARCHAR2)
IS

v_AFFECTDATE VARCHAR2(10);
v_TRFLOGID  NUMBER(20,0);
v_VERSION  VARCHAR2(20);
v_count NUMBER(20,0);
v_trfcode varchar2(50);
BEGIN
    plog.setbeginsection (pkgctx, 'sp_exec_create_crbtrflog_multi');
    plog.debug (pkgctx, '<<BEGIN OF sp_exec_create_crbtrflog_multi');
    if pv_trfcode ='ALL' or pv_trfcode='' or pv_trfcode=null then
        v_trfcode:='%%';
    else
        v_trfcode:= pv_trfcode;
    end if;
    --p_err_code:='0';
    BEGIN

        for recmst in (
            select trfcode,bankcode,txdate,affectdate from crbtxreq req
            where trfcode like v_trfcode and status ='P'
            and (grpreqid is null or grpreqid = reqid) and req.via ='RPT'
            and trfcode not in ('UNHOLD','HOLD')
            and not (txamt>100000000000 and trfcode='TRFODBUY')
            group by trfcode,bankcode,txdate,affectdate
        )
        loop
            --Group bang ke theo tieu tri trfcode,bankcode,txdate,affectdate
            SELECT SEQ_CRBTRFLOG.NEXTVAL INTO v_TRFLOGID FROM DUAL;

            SELECT  NVL(MAX(ODR)+1,1) INTO v_VERSION FROM
              (SELECT ROWNUM ODR, INVACCT
              FROM (SELECT VERSION INVACCT
                FROM CRBTRFLOG WHERE TXDATE=recmst.txdate AND TRFCODE=recmst.TRFCODE
                ORDER BY TO_NUMBER(VERSION)) WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

            --Log voi CRBTRFLOG: STATUS = PENDING. S? d?ng tru?ng FeedBack d? c?p nh?t b?ng chi ti?t
            INSERT INTO CRBTRFLOG (AUTOID, VERSION, TXDATE, AFFECTDATE, TLID, CREATETST, REFBANK, TRFCODE, STATUS,ERRSTS, FEEDBACK)
            SELECT v_TRFLOGID, v_VERSION, recmst.txdate, recmst.AFFECTDATE, '',
              SYSTIMESTAMP, recmst.BANKCODE, recmst.TRFCODE, 'P','N', 'Auto Generate' FROM DUAL;

            /*INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, rec.tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'VERSION',
              NULL, TO_CHAR(v_TRFLOGID), 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, rec.tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'REFBANK',
              NULL, rec.BANKCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;
            INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,
              FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME)
            SELECT 'CRBTRFLOG', 'AUTOID = ' || v_TRFLOGID, rec.tlid, TO_DATE(p_txdate,'DD/MM/RRRR'), 'N', 'TRFCODE',
              NULL, rec.TRFCODE, 0, 'ADD', NULL, NULL, to_char(SYStimestamp,'hh24:mi:ss') FROM DUAL;*/

            for rec in (
                select req.*, '' tlid from crbtxreq req
                where trfcode=recmst.trfcode and bankcode =recmst.bankcode and txdate = recmst.txdate and affectdate=recmst.affectdate
                and status ='P' and req.via ='RPT'
                and (grpreqid is null or grpreqid = reqid)
                and not (txamt>100000000000 and trfcode='TRFODBUY')
            )
            loop
                --Cap nhat CRBTRFLOGDTL
                BEGIN
                    INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS,REFHOLDID)
                    VALUES(SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,rec.BANKCODE,rec.TRFCODE,rec.txdate,
                           rec.REQID,rec.AFACCTNO,rec.TXAMT,rec.NOTES,'P',rec.REFVAL);

                    UPDATE CRBTXREQ SET STATUS='A' WHERE REQID=rec.REQID AND STATUS='P';
                END;
                if length(rec.grpreqid)>0 then
                    --Bang ke  CRBTRFLOGDTL join voi CRBTRFLOG theo txdate, version, trfcode

                    INSERT INTO CRBTRFLOGDTL (AUTOID, VERSION,BANKCODE,TRFCODE,TXDATE, REFREQID, AFACCTNO, AMT, REFNOTES, STATUS,REFHOLDID)
                    select SEQ_CRBTRFLOGDTL.NEXTVAL,v_VERSION,mst.BANKCODE,rec.TRFCODE,rec.txdate,
                          mst.REQID,mst.AFACCTNO,mst.TXAMT,mst.NOTES,'P',mst.REFVAL
                    from CRBTXREQ mst where grpreqid = rec.grpreqid and reqid <> rec.grpreqid;

                    UPDATE CRBTXREQ SET STATUS='A' WHERE REQID<>rec.grpreqid and grpreqid = rec.grpreqid AND STATUS='P';
                end if;
            end loop;
        end loop;

    END;

    plog.debug (pkgctx, '<<END OF sp_exec_create_crbtrflog_multi');
    plog.setendsection (pkgctx, 'sp_exec_create_crbtrflog_multi');

    RETURN;
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code:=  '-670102'; --Loi gen bang ke
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_exec_create_crbtrflog_multi');
END sp_exec_create_crbtrflog_multi;

PROCEDURE pr_CreateCRBTXREQ (p_err_code OUT VARCHAR2)
IS
TYPE v_CurTyp  IS REF CURSOR;
v_OBJTYPE      VARCHAR2(50);
v_OBJNAME      VARCHAR2(50);
v_FLDTRFCODE    VARCHAR2(50);
v_FLDAFFECTDATE    VARCHAR2(100);
v_FLDBANK      VARCHAR2(50);
v_FLDACCTNO   VARCHAR2(50);
v_FLDBANKACCT    VARCHAR2(50);
v_FLDREFCODE    VARCHAR2(50);
v_FLDNOTES    VARCHAR2(50);
v_FLDAMTEXP    VARCHAR2(50);
v_AMTEXP      VARCHAR2(50);
v_TXNUM      VARCHAR2(20);
v_TXDATE      DATE;
v_CHARTXDATE   VARCHAR2(20);
v_TRFCODE      VARCHAR2(50);
v_REFCODE    VARCHAR2(50);
v_BANK      VARCHAR2(50);
v_AFFECTDATE    VARCHAR2(100);
v_BANKACCT    VARCHAR2(50);
v_AFACCTNO    VARCHAR2(10);
v_NOTES      VARCHAR2(3000);
v_VALUE      VARCHAR2(300);
v_REFAUTOID    NUMBER;
v_CURRDATE     varchar2(250);
v_extCMDSQL   VARCHAR2(5000);
c0        v_CurTyp;
BEGIN
  plog.setbeginsection (pkgctx, 'pr_CreateCRBTXREQ');
  plog.debug (pkgctx, '<<BEGIN OF pr_CreateCRBTXREQ');
  p_err_code:='0';

  SELECT VARVALUE INTO v_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';

  --Lap lay ra cac tltx co khai bao ma phat sinh giao dich
  FOR rec IN (
    SELECT LG.TLTXCD,LG.TXNUM,LG.TXDATE,CRM.OBJTYPE,CRM.OBJNAME,
    CRM.TRFCODE,CRM.AFFECTDATE,CRM.FLDBANK,CRM.FLDACCTNO,CRM.FLDBANKACCT,
    CRM.FLDREFCODE,CRM.FLDNOTES,CRM.AMTEXP
    FROM TLLOG LG,CRBTXMAP CRM
    WHERE LG.TLTXCD=CRM.OBJNAME AND CRM.OBJTYPE='T'
    AND LG.TXSTATUS='1' AND LG.DELTD<>'Y' AND LG.TLTXCD NOT IN ('6600','6640')
    AND NOT EXISTS (
        SELECT * FROM CRBTXREQ REQ WHERE REQ.OBJKEY=LG.TXNUM AND REQ.TXDATE=LG.TXDATE
        AND (REQ.TRFCODE = CRM.TRFCODE OR SUBSTR(CRM.TRFCODE,1,1)='$')
    )
  )
  LOOP
    BEGIN
        v_CHARTXDATE:=TO_CHAR(rec.TXDATE,'DD/MM/YYYY');

        IF rec.FLDREFCODE IS NULL THEN
            v_REFCODE:= v_CHARTXDATE || rec.TXNUM;
        ELSE
            v_REFCODE:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDREFCODE);
        END IF;

        --TAO YEU CAU LAP BANG KE: GHI VAO BANG CRBTXREQ/CRBTXREQDTL
        v_TRFCODE:=rec.TRFCODE;
        IF SUBSTR(v_TRFCODE,1,1)='$' THEN
        --LAY  TRFCODE THEO GIAO DICH
        v_TRFCODE:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, v_TRFCODE);
        END IF;

        IF rec.AFFECTDATE='<$TXDATE>' THEN
            v_AFFECTDATE:=v_CURRDATE;
        ELSE
            v_AFFECTDATE:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.AFFECTDATE);
        END IF;

        v_AFACCTNO := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDACCTNO);
        v_NOTES := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDNOTES);
        v_VALUE := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.AMTEXP);
        v_BANKACCT := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDBANKACCT);

        IF v_BANKACCT='0' THEN
        v_BANKACCT:=NULL;
        END IF;

        IF SUBSTR(v_FLDBANKACCT,1,1)='#' THEN
        --XAC DINH THONG TIN BO XUNG
        IF v_BANKACCT IS NOT NULL THEN
           v_BANKACCT:= FN_CRB_GETCFACCTBYTRFCODE(v_TRFCODE, v_BANKACCT);
        END IF;
        END IF;

        v_BANK:= FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rec.FLDBANK);
        IF v_BANK='0' THEN
        v_BANK:=NULL;
        END IF;

        IF SUBSTR(rec.FLDBANK,1,1)='#' THEN
        --XAC DINH THONG TIN BO XUNG
        IF v_BANK IS NOT NULL THEN
           v_BANK:= FN_CRB_GETBANKCODEBYTRFCODE(v_TRFCODE, v_BANK);
        END IF;
        END IF;
        --Neu lay ra truong ko tim thay thi phai de null de khong sinh bang ke
        IF v_BANK='0' THEN
        v_BANK:=NULL;
        END IF;

        IF (NOT v_BANK IS NULL) AND (NOT v_BANKACCT IS NULL) AND (TO_NUMBER(v_VALUE)>0) THEN
            BEGIN
                v_REFAUTOID:=SEQ_CRBTXREQ.NEXTVAL;

                INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                VALUES (v_REFAUTOID, 'T', rec.TLTXCD, rec.TXNUM, v_TRFCODE, v_REFCODE, rec.TXDATE, TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), v_AFACCTNO, v_VALUE, v_BANK, v_BANKACCT, 'P', NULL, v_NOTES);

                FOR rc IN (
                    SELECT FLDNAME, FLDTYPE, AMTEXP, CMDSQL
                    FROM CRBTXMAPEXT MST WHERE MST.OBJTYPE ='T'
                    AND MST.OBJNAME = rec.TLTXCD AND TRFCODE=rec.TRFCODE
                )
                LOOP
                    BEGIN
                        IF NOT rc.AMTEXP IS NULL THEN
                          v_VALUE := FN_EVAL_AMTEXP(rec.TXNUM, v_CHARTXDATE, rc.AMTEXP);
                        END IF;
                        IF NOT rc.CMDSQL IS NULL THEN
                            BEGIN
                              v_extCMDSQL:=REPLACE(rc.CMDSQL,'<$FILTERID>',v_VALUE);
                              BEGIN
                                  OPEN c0 FOR v_extCMDSQL;
                                  FETCH c0 INTO v_VALUE;
                                  CLOSE c0;
                              EXCEPTION
                                WHEN OTHERS THEN
                                    v_VALUE:='0';
                                    plog.error(pkgctx,'Khong lay duoc gia tri tren cau lenh select dong : SQL-' || v_extCMDSQL);
                              END;
                            END;
                        END IF;

                        INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                          SELECT SEQ_CRBTXREQDTL.NEXTVAL, v_REFAUTOID, rc.FLDNAME,
                          DECODE(rc.FLDTYPE, 'N', NULL, TO_CHAR(v_VALUE)),
                          DECODE(rc.FLDTYPE, 'N', v_VALUE, 0) FROM DUAL;
                    END;
                END LOOP;
            END;
        END IF;
    END;
  END LOOP;

  p_err_code:='0';
  plog.debug (pkgctx, '<<END OF pr_CreateCRBTXREQ');
  plog.setendsection (pkgctx, 'pr_CreateCRBTXREQ');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CreateCRBTXREQ');
END pr_CreateCRBTXREQ;

PROCEDURE sp_exec_create_crbtxreq_tltxcd (p_err_code OUT VARCHAR2, p_tltxcd IN VARCHAR2, p_txdate IN VARCHAR2)
IS
TYPE v_CurTyp  IS REF CURSOR;
v_OBJTYPE      VARCHAR2(50);
v_OBJNAME      VARCHAR2(50);
v_FLDTRFCODE    VARCHAR2(50);
v_FLDAFFECTDATE    VARCHAR2(100);
v_FLDBANK      VARCHAR2(50);
v_FLDACCTNO   VARCHAR2(50);
v_FLDBANKACCT    VARCHAR2(50);
v_FLDREFCODE    VARCHAR2(50);
v_FLDNOTES    VARCHAR2(50);
v_FLDAMTEXP    VARCHAR2(50);
v_AMTEXP      VARCHAR2(50);
v_TXNUM      VARCHAR2(20);
v_TXDATE      DATE;
v_CHARTXDATE   VARCHAR2(20);
v_TRFCODE      VARCHAR2(50);
v_REFCODE    VARCHAR2(50);
v_BANK      VARCHAR2(50);
v_AFFECTDATE    VARCHAR2(100);
v_BANKACCT    VARCHAR2(50);
v_AFACCTNO    VARCHAR2(10);
v_NOTES      VARCHAR2(3000);
v_VALUE      VARCHAR2(300);
v_REFAUTOID    NUMBER;
v_COUNT      NUMBER;
v_CURRDATE     varchar2(250);
v_extFLDNAME  VARCHAR2(30);
v_extFLDTYPE  VARCHAR2(30);
v_extAMTEXP    VARCHAR2(200);
v_extCMDSQL   VARCHAR2(5000);
c0        v_CurTyp;
c1        v_CurTyp;
c2        v_CurTyp;
c3        v_CurTyp;
BEGIN
  plog.setbeginsection (pkgctx, 'sp_exec_create_crbtxreq_tltxcd');
  plog.debug (pkgctx, '<<BEGIN OF sp_exec_create_crbtxreq_tltxcd');
  v_COUNT:=0;
  p_err_code:='0';

  plog.debug (pkgctx, 'Begin generate crbtxreq for : tltx;' || p_tltxcd || ' ,txdate:' || NVL(p_txdate,''));

  --Kiem tra co khai bao tao bang ke khong
  BEGIN
    SELECT COUNT(TRFCODE) INTO v_COUNT FROM CRBTXMAP MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND MST.OBJNAME NOT IN ('6600','6640');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        --Neu khong co thi khong can bao loi
        v_COUNT:=0;
        p_err_code:='0';
    WHEN OTHERS THEN
        p_err_code:=errnums.C_SYSTEM_ERROR;
        plog.error(pkgctx,'Select trfcode for tltx:' || p_tltxcd || ' error : ' || SQLERRM);
  END;

  IF v_COUNT > 0 THEN
      BEGIN
          SELECT VARVALUE INTO v_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';
          -- Dynamic SQL statement with placeholder:
          OPEN c1 FOR SELECT OBJTYPE, OBJNAME, TRFCODE, AFFECTDATE, FLDBANK, FLDACCTNO, FLDBANKACCT, FLDREFCODE, FLDNOTES, AMTEXP
          FROM CRBTXMAP MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND MST.OBJNAME NOT IN ('6600','6640');
          --Luot qua danh sach bankcode cua bang ke
          LOOP
            FETCH c1 INTO v_OBJTYPE, v_OBJNAME, v_FLDTRFCODE, v_FLDAFFECTDATE, v_FLDBANK, v_FLDACCTNO, v_FLDBANKACCT,
            v_FLDREFCODE, v_FLDNOTES, v_FLDAMTEXP;
            EXIT WHEN c1%NOTFOUND;
            --DUYET CAC GIAO DICH TLLOG CHUA CO YEU CAU BANG KE
            IF p_txdate = v_CURRDATE OR p_txdate IS NULL THEN
              OPEN c2 FOR SELECT TXNUM, TXDATE
                FROM TLLOG LG WHERE LG.TLTXCD= p_tltxcd AND LG.DELTD='N'
                MINUS SELECT OBJKEY TXNUM, TXDATE
                FROM CRBTXREQ WHERE (TRFCODE=v_FLDTRFCODE OR SUBSTR(v_FLDTRFCODE,1,1)='$') AND OBJNAME=p_tltxcd AND OBJTYPE='T';
            ELSE
              OPEN c2 FOR SELECT TXNUM, TXDATE
                FROM TLLOGALL LG WHERE LG.TLTXCD= p_tltxcd AND LG.DELTD='N' AND TXDATE=TO_DATE(p_txdate,'DD/MM/YYYY')
                MINUS SELECT OBJKEY TXNUM, TXDATE
                FROM CRBTXREQ WHERE (TRFCODE=v_FLDTRFCODE OR SUBSTR(v_FLDTRFCODE,1,1)='$') AND OBJNAME=p_tltxcd AND OBJTYPE='T';
            END IF;
            LOOP
              FETCH c2 INTO v_TXNUM, v_TXDATE;
              EXIT WHEN c2%NOTFOUND;
              v_CHARTXDATE:=TO_CHAR(v_TXDATE,'DD/MM/YYYY');

              IF v_FLDREFCODE IS NULL THEN
                v_REFCODE:= v_CHARTXDATE || v_TXNUM;
              ELSE
                v_REFCODE:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDREFCODE);
              END IF;

              --TAO YEU CAU LAP BANG KE: GHI VAO BANG CRBTXREQ/CRBTXREQDTL
              v_TRFCODE:=v_FLDTRFCODE;
              IF SUBSTR(v_TRFCODE,1,1)='$' THEN
                --LAY  TRFCODE THEO GIAO DICH
                v_TRFCODE:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_TRFCODE);
              END IF;

              IF v_FLDAFFECTDATE='<$TXDATE>' THEN
                v_AFFECTDATE:=v_CURRDATE;
              ELSE
                v_AFFECTDATE:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDAFFECTDATE);
              END IF;

              v_AFACCTNO := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDACCTNO);
              v_NOTES := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDNOTES);
              v_VALUE := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDAMTEXP);
              v_BANKACCT := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDBANKACCT);

              IF v_BANKACCT='0' THEN
                v_BANKACCT:=NULL;
              END IF;

              IF SUBSTR(v_FLDBANKACCT,1,1)='#' THEN
                --XAC DINH THONG TIN BO XUNG
                IF v_BANKACCT IS NOT NULL THEN
                    v_BANKACCT:= FN_CRB_GETCFACCTBYTRFCODE(v_TRFCODE, v_BANKACCT);
                END IF;
              END IF;

              v_BANK:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDBANK);
              IF v_BANK='0' THEN
              v_BANK:=NULL;
              END IF;

              IF SUBSTR(v_FLDBANK,1,1)='#' THEN
                --XAC DINH THONG TIN BO XUNG
                IF v_BANK IS NOT NULL THEN
                    v_BANK:= FN_CRB_GETBANKCODEBYTRFCODE(v_TRFCODE, v_BANK);
                END IF;
              END IF;
              --Neu lay ra truong ko tim thay thi phai de null de khong sinh bang ke
              IF v_BANK='0' THEN
                v_BANK:=NULL;
              END IF;

              plog.debug(pkgctx,'Get bank code and bank account for txnum :' || v_TXNUM || ' - Bankcode: ' || NVL(v_BANK,' ') || ' ,BankAcct:' || NVL(v_BANKACCT,' '));

              --Chi thuc hien neu chi ro ngan hang va tk tai ngan hang
              IF (NOT v_BANK IS NULL) AND (NOT v_BANKACCT IS NULL) AND (TO_NUMBER(v_VALUE)>0) THEN
                BEGIN
                  v_REFAUTOID:=SEQ_CRBTXREQ.NEXTVAL;
                  INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                  VALUES (v_REFAUTOID, 'T', p_tltxcd, v_TXNUM, v_TRFCODE, v_REFCODE, v_TXDATE, TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), v_AFACCTNO, v_VALUE, v_BANK, v_BANKACCT, 'P', NULL, v_NOTES);
                  --GHI NHAN VAO BANG CRBTXREQDTL
                  OPEN c3 FOR SELECT FLDNAME, FLDTYPE, AMTEXP, CMDSQL
                                FROM CRBTXMAPEXT MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND TRFCODE=v_FLDTRFCODE;
                  LOOP
                    FETCH c3 INTO v_extFLDNAME, v_extFLDTYPE, v_extAMTEXP, v_extCMDSQL;
                    EXIT WHEN c3%NOTFOUND;
                    IF NOT v_extAMTEXP IS NULL THEN
                      v_VALUE := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_extAMTEXP);
                    END IF;
                    IF NOT v_extCMDSQL IS NULL THEN
                      v_extCMDSQL:=REPLACE(v_extCMDSQL,'<$FILTERID>',v_VALUE);
                      OPEN c0 FOR v_extCMDSQL;
                      FETCH c0 INTO v_VALUE;
                      CLOSE c0;
                    END IF;
                    INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                    SELECT SEQ_CRBTXREQDTL.NEXTVAL, v_REFAUTOID, v_extFLDNAME,
                      DECODE(v_extFLDTYPE, 'N', NULL, TO_CHAR(v_VALUE)),
                      DECODE(v_extFLDTYPE, 'N', v_VALUE, 0) FROM DUAL;
                  END LOOP;
                  CLOSE c3;
                END;
              END IF;
            END LOOP;
            CLOSE c2;
            COMMIT;
          END LOOP;
          CLOSE c1;
      END;
  END IF;

  p_err_code:='0';
  plog.debug (pkgctx, '<<END OF sp_exec_create_crbtxreq_tltxcd');
  plog.setendsection (pkgctx, 'sp_exec_create_crbtxreq_tltxcd');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'sp_exec_create_crbtxreq_tltxcd');
END sp_exec_create_crbtxreq_tltxcd;


--Ham goi gen thong tin bang ke cho rieng tung giao dich
PROCEDURE sp_exec_create_crbtxreq_txnum (p_err_code OUT VARCHAR2, p_tltxcd IN VARCHAR2, p_txdate IN VARCHAR2, p_txnum IN VARCHAR2)
IS
TYPE v_CurTyp  IS REF CURSOR;
v_OBJTYPE      VARCHAR2(50);
v_OBJNAME      VARCHAR2(50);
v_FLDTRFCODE    VARCHAR2(50);
v_FLDAFFECTDATE    VARCHAR2(100);
v_FLDBANK      VARCHAR2(50);
v_FLDACCTNO   VARCHAR2(50);
v_FLDBANKACCT    VARCHAR2(50);
v_FLDREFCODE    VARCHAR2(50);
v_FLDNOTES    VARCHAR2(50);
v_FLDAMTEXP    VARCHAR2(50);
v_AMTEXP      VARCHAR2(50);
v_TXNUM      VARCHAR2(20);
v_TXDATE      DATE;
v_CHARTXDATE   VARCHAR2(20);
v_TRFCODE      VARCHAR2(50);
v_REFCODE    VARCHAR2(50);
v_BANK      VARCHAR2(50);
v_AFFECTDATE    VARCHAR2(100);
v_BANKACCT    VARCHAR2(50);
v_AFACCTNO    VARCHAR2(10);
v_NOTES      VARCHAR2(3000);
v_VALUE      VARCHAR2(300);
v_REFAUTOID    NUMBER;
v_COUNT      NUMBER;
v_CURRDATE     varchar2(250);
v_extFLDNAME  VARCHAR2(30);
v_extFLDTYPE  VARCHAR2(30);
v_extAMTEXP    VARCHAR2(200);
v_extCMDSQL   VARCHAR2(5000);
c0        v_CurTyp;
c1        v_CurTyp;
c2        v_CurTyp;
c3        v_CurTyp;
BEGIN
  plog.setbeginsection (pkgctx, 'sp_exec_create_crbtxreq_txnum');
  plog.debug (pkgctx, '<<BEGIN OF sp_exec_create_crbtxreq_txnum');
  v_COUNT:=0;
  p_err_code:='0';

  plog.debug (pkgctx, 'Begin generate crbtxreq for : tltx;' || p_tltxcd || ' ,txdate:' || NVL(p_txdate,''));

  --Kiem tra co khai bao tao bang ke khong
  BEGIN
    SELECT COUNT(TRFCODE) INTO v_COUNT FROM CRBTXMAP MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND MST.OBJNAME NOT IN ('6600','6640');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        --Neu khong co thi khong can bao loi
        v_COUNT:=0;
        p_err_code:='0';
    WHEN OTHERS THEN
        p_err_code:=errnums.C_SYSTEM_ERROR;
        plog.error(pkgctx,'Select trfcode for tltx:' || p_tltxcd || ' error : ' || SQLERRM);
  END;

  IF v_COUNT > 0 THEN
      BEGIN
          SELECT VARVALUE INTO v_CURRDATE FROM SYSVAR WHERE VARNAME='CURRDATE';
          -- Dynamic SQL statement with placeholder:
          OPEN c1 FOR SELECT OBJTYPE, OBJNAME, TRFCODE, AFFECTDATE, FLDBANK, FLDACCTNO, FLDBANKACCT, FLDREFCODE, FLDNOTES, AMTEXP
          FROM CRBTXMAP MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND MST.OBJNAME NOT IN ('6600','6640');
          --Luot qua danh sach bankcode cua bang ke
          LOOP
            FETCH c1 INTO v_OBJTYPE, v_OBJNAME, v_FLDTRFCODE, v_FLDAFFECTDATE, v_FLDBANK, v_FLDACCTNO, v_FLDBANKACCT,
            v_FLDREFCODE, v_FLDNOTES, v_FLDAMTEXP;
            EXIT WHEN c1%NOTFOUND;
            --DUYET CAC GIAO DICH TLLOG CHUA CO YEU CAU BANG KE
            IF p_txdate = v_CURRDATE OR p_txdate IS NULL THEN
              OPEN c2 FOR SELECT TXNUM, TXDATE
                FROM TLLOG LG WHERE LG.TLTXCD= p_tltxcd AND LG.DELTD='N' and txnum = p_txnum
                MINUS SELECT OBJKEY TXNUM, TXDATE
                FROM CRBTXREQ WHERE (TRFCODE=v_FLDTRFCODE OR SUBSTR(v_FLDTRFCODE,1,1)='$') AND OBJNAME=p_tltxcd AND OBJTYPE='T';
            ELSE
              OPEN c2 FOR SELECT TXNUM, TXDATE
                FROM TLLOGALL LG WHERE LG.TLTXCD= p_tltxcd AND LG.DELTD='N' AND TXDATE=TO_DATE(p_txdate,'DD/MM/YYYY') and txnum = p_txnum
                MINUS SELECT OBJKEY TXNUM, TXDATE
                FROM CRBTXREQ WHERE (TRFCODE=v_FLDTRFCODE OR SUBSTR(v_FLDTRFCODE,1,1)='$') AND OBJNAME=p_tltxcd AND OBJTYPE='T';
            END IF;
            LOOP
              FETCH c2 INTO v_TXNUM, v_TXDATE;
              EXIT WHEN c2%NOTFOUND;
              v_CHARTXDATE:=TO_CHAR(v_TXDATE,'DD/MM/YYYY');

              IF v_FLDREFCODE IS NULL THEN
                v_REFCODE:= v_CHARTXDATE || v_TXNUM;
              ELSE
                v_REFCODE:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDREFCODE);
              END IF;

              --TAO YEU CAU LAP BANG KE: GHI VAO BANG CRBTXREQ/CRBTXREQDTL
              v_TRFCODE:=v_FLDTRFCODE;
              IF SUBSTR(v_TRFCODE,1,1)='$' THEN
                --LAY  TRFCODE THEO GIAO DICH
                v_TRFCODE:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_TRFCODE);
              END IF;

              IF v_FLDAFFECTDATE='<$TXDATE>' THEN
                v_AFFECTDATE:=v_CURRDATE;
              ELSE
                v_AFFECTDATE:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDAFFECTDATE);
              END IF;

              v_AFACCTNO := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDACCTNO);
              v_NOTES := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDNOTES);
              v_VALUE := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDAMTEXP);
              v_BANKACCT := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDBANKACCT);

              IF v_BANKACCT='0' THEN
                v_BANKACCT:=NULL;
              END IF;

              IF SUBSTR(v_FLDBANKACCT,1,1)='#' THEN
                --XAC DINH THONG TIN BO XUNG
                IF v_BANKACCT IS NOT NULL THEN
                    v_BANKACCT:= FN_CRB_GETCFACCTBYTRFCODE(v_TRFCODE, v_BANKACCT);
                END IF;
              END IF;

              v_BANK:= FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_FLDBANK);
              IF v_BANK='0' THEN
              v_BANK:=NULL;
              END IF;

              IF SUBSTR(v_FLDBANK,1,1)='#' THEN
                --XAC DINH THONG TIN BO XUNG
                IF v_BANK IS NOT NULL THEN
                    v_BANK:= FN_CRB_GETBANKCODEBYTRFCODE(v_TRFCODE, v_BANK);
                END IF;
              END IF;
              --Neu lay ra truong ko tim thay thi phai de null de khong sinh bang ke
              IF v_BANK='0' THEN
                v_BANK:=NULL;
              END IF;

              plog.debug(pkgctx,'Get bank code and bank account for txnum :' || v_TXNUM || ' - Bankcode: ' || NVL(v_BANK,' ') || ' ,BankAcct:' || NVL(v_BANKACCT,' '));

              --Chi thuc hien neu chi ro ngan hang va tk tai ngan hang
              IF (NOT v_BANK IS NULL) AND (NOT v_BANKACCT IS NULL) AND (TO_NUMBER(v_VALUE)>0) THEN
                BEGIN
                  v_REFAUTOID:=SEQ_CRBTXREQ.NEXTVAL;
                  INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                  VALUES (v_REFAUTOID, 'T', p_tltxcd, v_TXNUM, v_TRFCODE, v_REFCODE, v_TXDATE, TO_DATE(v_AFFECTDATE,'DD/MM/RRRR'), v_AFACCTNO, v_VALUE, v_BANK, v_BANKACCT, 'P', NULL, v_NOTES);
                  --GHI NHAN VAO BANG CRBTXREQDTL
                  OPEN c3 FOR SELECT FLDNAME, FLDTYPE, AMTEXP, CMDSQL
                                FROM CRBTXMAPEXT MST WHERE MST.OBJTYPE ='T' AND MST.OBJNAME = p_tltxcd AND TRFCODE=v_FLDTRFCODE;
                  LOOP
                    FETCH c3 INTO v_extFLDNAME, v_extFLDTYPE, v_extAMTEXP, v_extCMDSQL;
                    EXIT WHEN c3%NOTFOUND;
                    IF NOT v_extAMTEXP IS NULL THEN
                      v_VALUE := FN_EVAL_AMTEXP(v_TXNUM, v_CHARTXDATE, v_extAMTEXP);
                    END IF;
                    IF NOT v_extCMDSQL IS NULL THEN
                      v_extCMDSQL:=REPLACE(v_extCMDSQL,'<$FILTERID>',v_VALUE);
                      OPEN c0 FOR v_extCMDSQL;
                      FETCH c0 INTO v_VALUE;
                      CLOSE c0;
                    END IF;
                    INSERT INTO CRBTXREQDTL (AUTOID, REQID, FLDNAME, CVAL, NVAL)
                    SELECT SEQ_CRBTXREQDTL.NEXTVAL, v_REFAUTOID, v_extFLDNAME,
                      DECODE(v_extFLDTYPE, 'N', NULL, TO_CHAR(v_VALUE)),
                      DECODE(v_extFLDTYPE, 'N', v_VALUE, 0) FROM DUAL;
                  END LOOP;
                  CLOSE c3;
                END;
              END IF;
            END LOOP;
            CLOSE c2;
          END LOOP;
          CLOSE c1;
      END;
  END IF;

  p_err_code:='0';
  plog.debug (pkgctx, '<<END OF sp_exec_create_crbtxreq_txnum');
  plog.setendsection (pkgctx, 'sp_exec_create_crbtxreq_txnum');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_exec_create_crbtxreq_txnum');
END sp_exec_create_crbtxreq_txnum;

PROCEDURE sp_DeleteTxReq (p_err_code OUT VARCHAR2, p_txdate IN VARCHAR2,
    p_tlid IN VARCHAR2, p_brid IN VARCHAR2,p_lreqid IN VARCHAR2,p_ltxdesc  IN VARCHAR2)
IS
    TYPE v_CurTyp  IS REF CURSOR;
    v_REQID NUMBER(20,0);
    v_OBJNAME VARCHAR2(20);
    v_OBJKEY VARCHAR2(20);
    v_BANKCODE  VARCHAR2(20);
    v_BANKACCT  VARCHAR2(50);
    v_AFACCTNO  VARCHAR2(10);
    v_TRFCODE   VARCHAR2(20);
    v_TXDATE VARCHAR2(10);
    v_AFFECTDATE VARCHAR2(10);
    v_REFCODE   VARCHAR2(100);
    v_TRFLOGID  NUMBER(20,0);
    v_VERSION  VARCHAR2(20);
    v_TXAMT NUMBER(20,0);
    v_NOTES VARCHAR2(250);
    l_txmsg tx.msg_rectype;
    l_tltx VARCHAR2(4);
    l_txdesc VARCHAR2(250);
    l_currdate VARCHAR2(10);
    l_err_param VARCHAR2(300);
    c1        v_CurTyp;
    v_stmt_str      VARCHAR2(5000);
    v_count NUMBER(20,0);
BEGIN
    plog.setbeginsection (pkgctx, 'sp_DeleteTxReq');
    plog.debug (pkgctx, '<<BEGIN OF sp_DeleteTxReq');
    l_tltx:='6612';
    p_err_code:='0';

    SELECT varvalue
    INTO l_currdate
    FROM sysvar
    WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'BANK';
    l_txmsg.txdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_currdate,systemnums.c_date_format);
    l_txmsg.tltxcd:=l_tltx;
    plog.debug(pkgctx, 'Begin loop');

    -- Dynamic SQL statement with placeholder:
    v_stmt_str := 'SELECT REQID,OBJNAME,TRFCODE,REFCODE,OBJKEY,TO_CHAR(TXDATE,''DD/MM/RRRR'') TXDATE,TO_CHAR(AFFECTDATE,''DD/MM/RRRR'') AFFECTDATE,BANKCODE,BANKACCT,AFACCTNO,TXAMT,NOTES FROM CRBTXREQ WHERE REQID IN (' || p_lreqid || ') AND STATUS=''P''';
    OPEN c1 FOR v_stmt_str;
    --Luot qua danh sach bankcode cua bang ke
    LOOP
        FETCH c1 INTO v_REQID,v_OBJNAME,v_TRFCODE,v_REFCODE,v_OBJKEY,v_TXDATE,v_AFFECTDATE,v_BANKCODE,v_BANKACCT,v_AFACCTNO,v_TXAMT,v_NOTES;
        EXIT WHEN c1%NOTFOUND;

        BEGIN
            --Set txnum
            SELECT systemnums.C_COREBANK_PREFIXED
                             || LPAD (SEQ_COREBANKTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            l_txmsg.brid        := substr(v_AFACCTNO,1,4);

            l_txmsg.txfields ('01').defname := 'REQID';
            l_txmsg.txfields ('01').type := 'N';
            l_txmsg.txfields ('01').value := v_REQID;

            l_txmsg.txfields ('02').defname := 'OBJNAME';
            l_txmsg.txfields ('02').type := 'C';
            l_txmsg.txfields ('02').value := v_OBJNAME;

            l_txmsg.txfields ('03').defname := 'TRFCODE';
            l_txmsg.txfields ('03').type := 'C';
            l_txmsg.txfields ('03').value := v_TRFCODE;

            l_txmsg.txfields ('04').defname := 'REFCODE';
            l_txmsg.txfields ('04').type := 'C';
            l_txmsg.txfields ('04').value := v_REFCODE;

            l_txmsg.txfields ('05').defname := 'TXDATE';
            l_txmsg.txfields ('05').type := 'D';
            l_txmsg.txfields ('05').value := v_TXDATE;

            l_txmsg.txfields ('06').defname := 'AFFECTDATE';
            l_txmsg.txfields ('06').type := 'D';
            l_txmsg.txfields ('06').value := v_AFFECTDATE;

            l_txmsg.txfields ('07').defname := 'BANKCODE';
            l_txmsg.txfields ('07').type := 'C';
            l_txmsg.txfields ('07').value := v_BANKCODE;

            l_txmsg.txfields ('08').defname := 'BANKACCT';
            l_txmsg.txfields ('08').type := 'C';
            l_txmsg.txfields ('08').value := v_BANKACCT;

            l_txmsg.txfields ('09').defname := 'AFACCTNO';
            l_txmsg.txfields ('09').type := 'C';
            l_txmsg.txfields ('09').value := v_AFACCTNO;

            l_txmsg.txfields ('11').defname := 'TXAMT';
            l_txmsg.txfields ('11').type := 'N';
            l_txmsg.txfields ('11').value := v_TXAMT;

            l_txmsg.txfields ('12').defname := 'NOTES';
            l_txmsg.txfields ('12').type := 'C';
            l_txmsg.txfields ('12').value := v_NOTES;

            l_txmsg.txfields ('30').defname := 'DESCRIPTION';
            l_txmsg.txfields ('30').type := 'C';
            l_txmsg.txfields ('30').value :=  p_ltxdesc || ' - reqid : ' || TO_CHAR(v_REQID);

            BEGIN
                IF txpks_#6612.fn_autotxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 6612: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                END IF;
            END;
        END;
    END LOOP;
    CLOSE c1;

    COMMIT;

    plog.debug (pkgctx, '<<END OF sp_DeleteTxReq');
    plog.setendsection (pkgctx, 'sp_DeleteTxReq');

    RETURN;
EXCEPTION
    WHEN OTHERS
    THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'sp_DeleteTxReq');
END sp_DeleteTxReq;

PROCEDURE pr_RunningRMBatch(p_batchname in varchar2,p_err_code out varchar2)
IS
    l_fromRow number(20,0);
    l_toRow number(20,0);
    l_lastRun varchar2(100);
BEGIN
    p_err_code:='0';
    l_fromRow:=0;
    l_toRow:=100000;

    plog.setbeginsection (pkgctx, 'pr_RunningRMBatch');
    plog.debug (pkgctx, '<<BEGIN OF pr_RunningRMBatch');

    IF p_batchname ='BAMTTRF' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_ODSettlementtransferMoney('ODRCVM', p_err_code, l_fromRow, l_toRow, l_lastRun);
            END IF;
/*            IF p_err_code='0' THEN
                txpks_batch.pr_CILateSendMoney('CILATESENDMONEY', p_err_code);
            END IF;
            IF p_err_code='0' THEN
                txpks_batch.pr_CIT0SendMoney('CIT0SENDMONEY', p_err_code);
            END IF;*/
            IF p_err_code='0' THEN
                txpks_batch.pr_rmBAMTTRF('BAMTTRF', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='BFEETRF' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_ODFeeCalculate('ODFEECAL',p_err_code,l_fromRow ,l_toRow , l_lastRun);
            END IF;
            IF p_err_code='0' THEN
                txpks_batch.pr_rmBFEETRF('BFEETRF', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEXCA3384' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEXCA3384('RMEXCA3384', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEXCA3386' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEXCA3386('RMEXCA3386', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEXCA3350' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEXCA3350('RMEXCA3350', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEXCA3350DF' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEXCA3350DF('RMEXCA3350DF', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEX8879' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEX8879('RMEX8879', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEX8879DF' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEX8879DF('RMEX8879DF', p_err_code);
            END IF;
        END;
    ELSIF p_batchname ='RMEXSEDPFEE' then
        BEGIN
            IF p_err_code='0' THEN
                txpks_batch.pr_rmRMEXSEDPFEE('RMEXSEDPFEE', p_err_code);
            END IF;
        END;
    END IF;

    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6663',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6664',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6665',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6666',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6682',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6641',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6642',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6643',null);
    sp_exec_create_crbtxreq_tltxcd(p_err_code,'6644',null);

    p_err_code:=0;

    plog.debug (pkgctx, '<<END OF pr_RunningRMBatch');
    plog.setendsection (pkgctx, 'pr_RunningRMBatch');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RunningRMBatch');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_RunningRMBatch;

PROCEDURE pr_ExecBankRequest(p_xmlmsg in varchar2,p_err_code out varchar2)
IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_fieldList xmldom.domnodelist;
    l_node     xmldom.domnode;

    l_bankcode varchar2(100);
    l_version varchar2(100);
    l_trfcode varchar2(100);
    l_txdate varchar2(100);

    l_errcode varchar2(100);
    l_errdesc varchar2(400);

    l_batchstatus varchar2(1);
    l_itemerrcode varchar2(100);
    l_itemstatus varchar2(100);

    l_itemtrancode varchar2(100);
    l_itemerrdesc varchar2(400);
    l_fieldname varchar2(100);
    l_refreqid number(20,0);
    l_refreqtxdate varchar2(100);
    l_objkey varchar2(100);
    l_objname varchar2(100);
    l_refholdid varchar2(100);
    l_flagproccess varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_ExecBankRequest');
    plog.debug (pkgctx, '<<BEGIN OF pr_ExecBankRequest');

    p_err_code:='0';

    l_parser := xmlparser.newparser();
    xmlparser.parseclob(l_parser, p_xmlmsg);
    l_doc := xmlparser.getdocument(l_parser);
    xmlparser.freeparser(l_parser);

    l_node := xslprocessor.selectsinglenode(xmldom.makenode(l_doc),'/ObjectMessage/Output/Error');
    l_errcode := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'Code'));
    IF l_errcode='-670001' OR l_errcode='-670002' OR l_errcode='-670003' THEN
        BEGIN
            l_batchstatus:='S';
            l_itemstatus:='S';
            l_flagproccess:='Y';
        END;
    ELSIF l_errcode='-670005' OR l_errcode='-670004' OR l_errcode='0' THEN
        BEGIN
            l_batchstatus:='F';
            l_itemstatus:='C';
            l_flagproccess:='Y';
        END;
    ELSIF l_errcode='-670006' THEN
        BEGIN
            l_batchstatus:='R';
            l_itemstatus:='R';
            l_flagproccess:='N';
        END;
    ELSE
        BEGIN
            l_batchstatus:='E';
            l_itemstatus:='E';
            l_flagproccess:='N';
        END;
    END IF;

    l_node := xslprocessor.selectsinglenode(xmldom.makenode(l_doc),'/ObjectMessage/Function');
    l_bankcode := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'BANKCODE'));

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),'/ObjectMessage/Input/Param');
    IF xmldom.getlength(l_nodeList)>0 THEN
        FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
            BEGIN
                l_node := xmldom.item(l_nodeList, i);
                l_fieldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'NAME'));

                IF l_fieldname='VERSION' THEN
                    l_version := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                ELSIF l_fieldname='TRFCODE' THEN
                    l_trfcode := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                ELSIF l_fieldname='TXDATE' THEN
                    l_txdate := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                END IF;
            END;
        END LOOP;
    END IF;

    BEGIN
        SELECT ERRDESC INTO l_errdesc FROM DEFERROR WHERE TO_CHAR(ERRNUM)=l_errcode;
    EXCEPTION
        WHEN OTHERS THEN
        l_errdesc:=l_errcode || ': Unknown error!';
    END;

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),'/ObjectMessage/Output/ReturnData/Row');
    IF xmldom.getlength(l_nodeList)>0 THEN
        BEGIN
            FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
                BEGIN
                    l_fieldList := xslprocessor.selectnodes(xmldom.item(l_nodeList, i),'field');
                    FOR j IN 0 .. xmldom.getlength(l_fieldList) - 1 LOOP
                        BEGIN
                            l_node := xmldom.item(l_fieldList, j);
                            l_fieldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'name'));

                            IF UPPER(l_fieldname)='ITEMTRANCODE' THEN
                                l_itemtrancode := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                            ELSIF UPPER(l_fieldname)='STATUS' THEN
                                l_itemerrcode := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                            ELSIF UPPER(l_fieldname)='STATUSDESC' THEN
                                l_itemerrdesc := xmldom.getnodevalue(xmldom.getfirstchild(l_node));

                                IF LENGTH(l_itemerrdesc)<=0 THEN
                                    BEGIN
                                        SELECT ERRDESC INTO l_itemerrdesc FROM DEFERROR WHERE ERRNUM=TO_NUMBER(l_itemerrcode);
                                    EXCEPTION WHEN OTHERS THEN
                                        l_itemerrdesc:=l_itemerrcode || ':' || 'Unknown error!';
                                    END;
                                END IF;
                            END IF;
                        END;
                    END LOOP;

                    IF l_itemerrcode='0' THEN
                        l_itemstatus := 'C';
                        l_flagproccess := 'Y';
                    ELSE
                        BEGIN
                            l_itemstatus := 'E';
                            l_flagproccess:='N';
                            IF l_batchstatus='F' THEN l_batchstatus:='H'; END IF;
                        END;
                    END IF;

                    --Lay thong tin cua request
                    l_refreqid:=0;
                    BEGIN
                        SELECT REQ.OBJKEY,REQ.OBJNAME,REQ.REQID,
                        TO_CHAR(REQ.TXDATE,'DD/MM/RRRR') TXDATE,NVL(REFHOLDID,'N/A') REFHOLDID
                        INTO l_objkey,l_objname,l_refreqid,l_refreqtxdate,l_refholdid
                        FROM CRBTXREQ REQ,CRBTRFLOGDTL DTL
                        WHERE REQ.REQID=DTL.REFREQID AND DTL.ITEMTRANCODE=l_itemtrancode
                        AND DTL.VERSION = l_version AND DTL.BANKCODE=l_bankcode
                        AND DTL.TRFCODE=l_trfcode AND DTL.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');
                    EXCEPTION
                        WHEN OTHERS THEN
                            --Truong hop khong tim thay thong tin request
                            l_refreqid:=-1;
                    END;

                    --Cap nhat lai trang thai
                    IF l_refreqid>0 THEN
                        BEGIN
                            --Cap nhat lai crbtrflogdtl
                            UPDATE CRBTRFLOGDTL SET STATUS=l_itemstatus,ERRNUM=TO_NUMBER(l_itemerrcode),
                            ERRMSG=l_itemerrdesc
                            WHERE ITEMTRANCODE=l_itemtrancode AND VERSION=l_version
                            AND TRFCODE=l_trfcode AND BANKCODE=l_bankcode
                            AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');

                            IF l_refholdid<>'N/A' AND l_itemstatus='C' THEN
                                UPDATE CRBHOLDLIST SET STATUS='C',LASTDATE=SYSDATE
                                WHERE REFNO=l_refholdid AND BANKCODE=l_bankcode;
                            END IF;
                            IF l_itemstatus='C' OR l_itemstatus='R' OR l_itemstatus='E' THEN
                                BEGIN
                                    UPDATE CRBTXREQ SET ERRORCODE=l_itemerrcode WHERE REQID=l_refreqid;

                                    SP_EXEC_PROCESS_CRBTRFLOGDTL(p_err_code, l_txdate, l_objkey, l_objname, l_refreqid, l_flagproccess);
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END LOOP;
        END;
    ELSE
        --Truong hop tra ve khong co item cu the, thi cap nhat het thanh status tong
        BEGIN
            FOR rec IN
            (
                SELECT DTL.AUTOID,REQ.OBJKEY,REQ.OBJNAME,REQ.REQID,
                TO_CHAR(REQ.TXDATE,'DD/MM/RRRR') TXDATE,NVL(REFHOLDID,'N/A') REFHOLDID
                FROM CRBTXREQ REQ,CRBTRFLOGDTL DTL
                WHERE REQ.REQID=DTL.REFREQID
                AND DTL.VERSION = l_version AND DTL.BANKCODE=l_bankcode
                AND DTL.TRFCODE=l_trfcode AND DTL.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR')
            )
            LOOP
                UPDATE CRBTRFLOGDTL SET STATUS=l_itemstatus,ERRNUM=TO_NUMBER(l_errcode),
                ERRMSG=l_errdesc
                WHERE AUTOID=rec.AUTOID AND VERSION=l_version
                AND TRFCODE=l_trfcode AND BANKCODE=l_bankcode
                AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');

                IF l_refholdid<>'N/A' AND l_itemstatus='C' THEN
                    UPDATE CRBHOLDLIST SET STATUS='C',LASTDATE=SYSDATE
                    WHERE REFNO=l_refholdid AND BANKCODE=l_bankcode;
                END IF;
                IF l_itemstatus='C' OR l_itemstatus='R' OR l_itemstatus='E' THEN
                    BEGIN
                        UPDATE CRBTXREQ SET ERRORCODE=l_errcode WHERE REQID=rec.REQID;

                        SP_EXEC_PROCESS_CRBTRFLOGDTL(p_err_code, l_txdate, rec.OBJKEY, rec.OBJNAME, rec.REQID, l_flagproccess);
                    END;
                END IF;
            END LOOP;
        END;
    END IF;

    plog.debug (pkgctx, '<<END OF pr_ExecBankRequest');
    plog.setendsection (pkgctx, 'pr_ExecBankRequest');

    commit;
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ExecBankRequest');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_ExecBankRequest;

PROCEDURE pr_ExecBankResult(p_xmlmsg in clob,p_err_code out varchar2)
IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_fieldList xmldom.domnodelist;
    l_node     xmldom.domnode;

    l_bankcode varchar2(100);
    l_version varchar2(100);
    l_versionlocal varchar2(100);
    l_trfcode varchar2(100);
    l_txdate varchar2(100);

    l_errcode varchar2(100);
    l_errdesc varchar2(400);

    l_batchstatus varchar2(1);
    l_itemerrcode varchar2(100);
    l_itemstatus varchar2(100);

    l_itemtrancode varchar2(100);
    l_itemerrdesc varchar2(400);
    l_fieldname varchar2(100);
    l_refreqid number(20,0);
    l_refreqtxdate varchar2(100);
    l_objkey varchar2(100);
    l_objname varchar2(100);
    l_refholdid varchar2(100);
    l_flagproccess varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_ExecBankResult');
    plog.debug (pkgctx, '<<BEGIN OF pr_ExecBankResult');

    p_err_code:='0';

    l_parser := xmlparser.newparser();
    xmlparser.parseclob(l_parser, p_xmlmsg);
    l_doc := xmlparser.getdocument(l_parser);
    xmlparser.freeparser(l_parser);

    l_node := xslprocessor.selectsinglenode(xmldom.makenode(l_doc),'/ObjectMessage/Output/Error');
    l_errcode := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'Code'));
    IF l_errcode='-670001' OR l_errcode='-670002' OR l_errcode='-670003' OR l_errcode='-1' OR l_errcode='1' OR l_errcode='-670062' THEN
        BEGIN
            l_batchstatus:='S';
            l_itemstatus:='S';
            l_flagproccess:='Y';
        END;
    ELSIF l_errcode='-670005' OR l_errcode='-670004' OR l_errcode='0' THEN
        BEGIN
            l_batchstatus:='F';
            l_itemstatus:='C';
            l_flagproccess:='Y';
        END;
    ELSIF l_errcode='-670006' THEN
        BEGIN
            l_batchstatus:='R';
            l_itemstatus:='R';
            l_flagproccess:='N';
        END;
    ELSE
        BEGIN
            l_batchstatus:='E';
            l_itemstatus:='E';
            l_flagproccess:='N';
        END;
    END IF;

    l_node := xslprocessor.selectsinglenode(xmldom.makenode(l_doc),'/ObjectMessage/Function');
    l_bankcode := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'BANKCODE'));

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),'/ObjectMessage/Input/Param');
    IF xmldom.getlength(l_nodeList)>0 THEN
        FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
            BEGIN
                l_node := xmldom.item(l_nodeList, i);
                l_fieldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'NAME'));

                IF l_fieldname='VERSION' THEN
                    l_version := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                ELSIF l_fieldname='LOCALVERSION' THEN
                    l_versionlocal := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                ELSIF l_fieldname='TRFCODE' THEN
                    l_trfcode := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                ELSIF l_fieldname='TXDATE' THEN
                    l_txdate := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                END IF;
            END;
        END LOOP;
    END IF;

    BEGIN
        SELECT ERRDESC INTO l_errdesc FROM DEFERROR WHERE TO_CHAR(ERRNUM)=l_errcode;
    EXCEPTION
        WHEN OTHERS THEN
        l_errdesc:=l_errcode || ': Unknown error!';
    END;

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),'/ObjectMessage/Output/ReturnData/Row');
    IF xmldom.getlength(l_nodeList)>0 THEN
        BEGIN
            FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
                BEGIN
                    l_fieldList := xslprocessor.selectnodes(xmldom.item(l_nodeList, i),'field');
                    FOR j IN 0 .. xmldom.getlength(l_fieldList) - 1 LOOP
                        BEGIN
                            l_node := xmldom.item(l_fieldList, j);
                            l_fieldname := xmldom.getvalue(xmldom.getattributenode(xmldom.makeelement(l_node),'name'));

                            IF UPPER(l_fieldname)='ITEMTRANCODE' THEN
                                l_itemtrancode := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                            ELSIF UPPER(l_fieldname)='STATUS' THEN
                                l_itemerrcode := xmldom.getnodevalue(xmldom.getfirstchild(l_node));
                            ELSIF UPPER(l_fieldname)='STATUSDESC' THEN
                                l_itemerrdesc := xmldom.getnodevalue(xmldom.getfirstchild(l_node));

                                IF LENGTH(l_itemerrdesc)<=0 THEN
                                    BEGIN
                                        SELECT ERRDESC INTO l_itemerrdesc FROM DEFERROR WHERE ERRNUM=TO_NUMBER(l_itemerrcode);
                                    EXCEPTION WHEN OTHERS THEN
                                        l_itemerrdesc:=l_itemerrcode || ':' || 'Unknown error!';
                                    END;
                                END IF;
                            END IF;
                        END;
                    END LOOP;

                    IF l_itemerrcode='0' THEN
                        l_itemstatus := 'C';
                        l_flagproccess := 'Y';
                    ELSE
                        BEGIN
                            l_itemstatus := 'E';
                            l_flagproccess:='N';
                            IF l_batchstatus='F' THEN l_batchstatus:='H'; END IF;
                        END;
                    END IF;

                    --Lay thong tin cua request
                    l_refreqid:=0;
                    BEGIN
                        SELECT REQ.OBJKEY,REQ.OBJNAME,REQ.REQID,
                        TO_CHAR(REQ.TXDATE,'DD/MM/RRRR') TXDATE,NVL(REFHOLDID,'N/A') REFHOLDID
                        INTO l_objkey,l_objname,l_refreqid,l_refreqtxdate,l_refholdid
                        FROM CRBTXREQ REQ,CRBTRFLOGDTL DTL
                        WHERE REQ.REQID=DTL.REFREQID AND DTL.ITEMTRANCODE=l_itemtrancode
                        AND DTL.VERSION = l_version AND DTL.BANKCODE=l_bankcode
                        AND DTL.TRFCODE=l_trfcode AND DTL.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');
                    EXCEPTION
                        WHEN OTHERS THEN
                            --Truong hop khong tim thay thong tin request
                            l_refreqid:=-1;
                    END;

                    --Cap nhat lai trang thai
                    IF l_refreqid>0 THEN
                        BEGIN
                            --Cap nhat lai crbtrflogdtl
                            UPDATE CRBTRFLOGDTL SET STATUS=l_itemstatus,ERRNUM=TO_NUMBER(l_itemerrcode),
                            ERRMSG=l_itemerrdesc
                            WHERE ITEMTRANCODE=l_itemtrancode AND VERSION=l_version
                            AND TRFCODE=l_trfcode AND BANKCODE=l_bankcode
                            AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');

                            IF l_refholdid<>'N/A' AND l_itemstatus='C' THEN
                                UPDATE CRBHOLDLIST SET STATUS='C',LASTDATE=SYSDATE
                                WHERE REFNO=l_refholdid AND BANKCODE=l_bankcode;
                            END IF;
                            IF l_itemstatus='C' OR l_itemstatus='R' OR l_itemstatus='E' THEN
                                BEGIN
                                    UPDATE CRBTXREQ SET ERRORCODE=l_itemerrcode WHERE REQID=l_refreqid;

                                    SP_EXEC_PROCESS_CRBTRFLOGDTL(p_err_code, l_txdate, l_objkey, l_objname, l_refreqid, l_flagproccess);
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END LOOP;
        END;
    ELSE
        --Truong hop tra ve khong co item cu the, thi cap nhat het thanh status tong
        BEGIN
            FOR rec IN
            (
                SELECT DTL.AUTOID,REQ.OBJKEY,REQ.OBJNAME,REQ.REQID,
                TO_CHAR(REQ.TXDATE,'DD/MM/RRRR') TXDATE,NVL(REFHOLDID,'N/A') REFHOLDID
                FROM CRBTXREQ REQ,CRBTRFLOGDTL DTL
                WHERE REQ.REQID=DTL.REFREQID
                AND DTL.VERSION = l_version AND DTL.BANKCODE=l_bankcode
                AND DTL.TRFCODE=l_trfcode AND DTL.TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR')
            )
            LOOP
                UPDATE CRBTRFLOGDTL SET STATUS=l_itemstatus,ERRNUM=TO_NUMBER(l_errcode),
                ERRMSG=l_errdesc
                WHERE AUTOID=rec.AUTOID AND VERSION=l_version
                AND TRFCODE=l_trfcode AND BANKCODE=l_bankcode
                AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');

                IF l_refholdid<>'N/A' AND l_itemstatus='C' THEN
                    UPDATE CRBHOLDLIST SET STATUS='C',LASTDATE=SYSDATE
                    WHERE REFNO=l_refholdid AND BANKCODE=l_bankcode;
                END IF;
                IF l_itemstatus='C' OR l_itemstatus='R' OR l_itemstatus='E' THEN
                    BEGIN
                        UPDATE CRBTXREQ SET ERRORCODE=l_errcode WHERE REQID=rec.REQID;

                        SP_EXEC_PROCESS_CRBTRFLOGDTL(p_err_code, l_txdate, rec.OBJKEY, rec.OBJNAME, rec.REQID, l_flagproccess);
                    END;
                END IF;
            END LOOP;
        END;
    END IF;

    UPDATE CRBTRFLOG SET STATUS=l_batchstatus,ERRCODE=l_errcode,ERRSTS='N',FEEDBACK=l_errdesc
    WHERE VERSION=l_version AND VERSIONLOCAL=l_versionlocal AND REFBANK=l_bankcode
    AND TRFCODE=l_trfcode AND TXDATE=TO_DATE(l_txdate,'DD/MM/RRRR');

    plog.debug (pkgctx, '<<END OF pr_ExecBankResult');
    plog.setendsection (pkgctx, 'pr_ExecBankResult');

    commit;
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ExecBankResult');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_ExecBankResult;

PROCEDURE pr_ChangeWorkingDate(p_err_code out varchar2)
IS
    l_execstr varchar2(2000);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_ChangeWorkingDate');
    plog.debug (pkgctx, '<<BEGIN OF pr_ChangeWorkingDate');

    /*l_execstr:='DROP SEQUENCE seq_bankrefbidv';
    EXECUTE IMMEDIATE l_execstr;

    l_execstr:='CREATE SEQUENCE seq_bankrefbidv
    INCREMENT BY 1
    START WITH 5500
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    NOCYCLE
    NOORDER
    CACHE 20';
    EXECUTE IMMEDIATE l_execstr;*/

    RESET_SEQUENCE(SEQ_NAME => 'seq_bankrefbidv', STARTVALUE => 1);
    COMMIT;

    /*l_execstr:='DROP SEQUENCE seq_bankrefbvb';
    EXECUTE IMMEDIATE l_execstr;

    l_execstr:='CREATE SEQUENCE seq_bankrefbvb
    INCREMENT BY 1
    START WITH 5500
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    NOCYCLE
    NOORDER
    CACHE 20';
    EXECUTE IMMEDIATE l_execstr;*/

    RESET_SEQUENCE(SEQ_NAME => 'seq_bankrefbvb', STARTVALUE => 1);
    COMMIT;

    /*l_execstr:='DROP SEQUENCE seq_bankrefdab';
    EXECUTE IMMEDIATE l_execstr;

    l_execstr:='CREATE SEQUENCE seq_bankrefdab
    INCREMENT BY 1
    START WITH 5500
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    NOCYCLE
    NOORDER
    CACHE 20';
    EXECUTE IMMEDIATE l_execstr;*/
    RESET_SEQUENCE(SEQ_NAME => 'seq_bankrefdab', STARTVALUE => 1);
    COMMIT;

    /*l_execstr:='DROP SEQUENCE seq_bankbatchno_bidv';
    EXECUTE IMMEDIATE l_execstr;

    l_execstr:='CREATE SEQUENCE seq_bankbatchno_bidv
    INCREMENT BY 1
    START WITH 55
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    NOCYCLE
    NOORDER
    NOCACHE';
    EXECUTE IMMEDIATE l_execstr;*/
    RESET_SEQUENCE(SEQ_NAME => 'seq_bankbatchno_bidv', STARTVALUE => 1);
    COMMIT;

    /*l_execstr:='DROP SEQUENCE seq_bankbatchno_bvb';
    EXECUTE IMMEDIATE l_execstr;

    l_execstr:='CREATE SEQUENCE seq_bankbatchno_bvb
    INCREMENT BY 1
    START WITH 55
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    NOCYCLE
    NOORDER
    NOCACHE';
    EXECUTE IMMEDIATE l_execstr;*/
    RESET_SEQUENCE(SEQ_NAME => 'seq_bankbatchno_bvb', STARTVALUE => 1);
    COMMIT;

    /*l_execstr:='DROP SEQUENCE seq_bankbatchno_dab';
    EXECUTE IMMEDIATE l_execstr;

    l_execstr:='CREATE SEQUENCE seq_bankbatchno_dab
    INCREMENT BY 1
    START WITH 55
    MINVALUE 1
    MAXVALUE 9999999999999999999999999999
    NOCYCLE
    NOORDER
    NOCACHE';
    EXECUTE IMMEDIATE l_execstr;*/
    RESET_SEQUENCE(SEQ_NAME => 'seq_bankbatchno_dab', STARTVALUE => 1);
    COMMIT;

    --bakup lai cac bang crbtxreq,crbtxreqdtl,crbtrflog,crbtrflogdtl
    --Chi backup lai cac giao dich qua 30 ngay, cac giao dich 30 ngay van giu nguyen, ke ca truong hop loi
    --GianhVG: Chi giu lai cac giao dich trong chu ky T3, ngoai T3 thi chi giu lai cac giao dich bi loi hoac chua thanh toan
    INSERT INTO CRBTXREQHIST
    SELECT * FROM CRBTXREQ WHERE TXDATE<= (
        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') + getnonworkingday(-3) FROM SYSVAR
        WHERE VARNAME='CURRDATE'
    ) AND STATUS NOT IN ('P','E','A');

    DELETE FROM CRBTXREQ WHERE TXDATE<= (
        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') + getnonworkingday(-3) FROM SYSVAR
        WHERE VARNAME='CURRDATE'
    ) AND STATUS NOT IN ('P','E','A');

    INSERT INTO CRBTXREQDTLHIST
    SELECT * FROM CRBTXREQDTL WHERE REQID IN (
        SELECT REQID FROM CRBTXREQ WHERE TXDATE<= (
            SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') + getnonworkingday(-3) FROM SYSVAR
            WHERE VARNAME='CURRDATE'
        ) AND STATUS NOT IN ('P','E','A')
    );

    DELETE FROM CRBTXREQDTL WHERE REQID IN (
        SELECT REQID FROM CRBTXREQ WHERE TXDATE<= (
            SELECT TO_DATE(VARVALUE,'DD/MM/RRRR')+ getnonworkingday(-3) FROM SYSVAR
            WHERE VARNAME='CURRDATE'
        ) AND STATUS NOT IN ('P','E','A')
    );

    INSERT INTO CRBTRFLOGHIST
    SELECT * FROM CRBTRFLOG WHERE TXDATE<= (
        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR')+ getnonworkingday(-3) FROM SYSVAR
        WHERE VARNAME='CURRDATE'
    ) AND STATUS NOT IN ('S','A','E');

    DELETE FROM CRBTRFLOG WHERE TXDATE<= (
        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR')+ getnonworkingday(-3) FROM SYSVAR
        WHERE VARNAME='CURRDATE'
    ) AND STATUS NOT IN ('S','A','E');

    INSERT INTO CRBTRFLOGDTLHIST
    SELECT * FROM CRBTRFLOGDTL WHERE TXDATE<= (
        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR')+ getnonworkingday(-3) FROM SYSVAR
        WHERE VARNAME='CURRDATE'
    ) AND STATUS NOT IN ('S','P');

    DELETE FROM CRBTRFLOGDTL WHERE TXDATE<= (
        SELECT TO_DATE(VARVALUE,'DD/MM/RRRR')+ getnonworkingday(-3) FROM SYSVAR
        WHERE VARNAME='CURRDATE'
    ) AND STATUS NOT IN ('S','P');

    COMMIT;
    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_ChangeWorkingDate');
    plog.setendsection (pkgctx, 'pr_ChangeWorkingDate');
    --End
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ChangeWorkingDate');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_ChangeWorkingDate;

PROCEDURE pr_RM_UnholdAccount( pv_strACCTNO varchar2,pv_strErrorCode in out varchar2)
IS
   l_txmsg tx.msg_rectype;
   v_dblCount NUMBER(20,0);
   v_strCOREBANK VARCHAR2(10);
   v_straltenateacct VARCHAR2(10);
   v_strBANKCODE  VARCHAR2(10);
   v_dblRemainHold NUMBER(20,0);
   v_dblUnholdBalance NUMBER(20,0);
   v_tltxcd VARCHAR2(4);
   v_strDesc VARCHAR2(250);
   v_strEN_Desc VARCHAR2(250);
   v_strNotes VARCHAR2(250);
   v_strCURRDATE VARCHAR2(10);
   l_err_param VARCHAR2(200);
   l_UnHoldRealTime VARCHAR2(10);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_RM_UnholdCancelOD');
    v_dblUnholdBalance:=0;

    --12/01/2017, NamTv Add, BMS se khong thuc hien UnHold khi huy/sua lenh
    --> Return luon, sau nay, cac ban khac neu dung --> bo doan nay.
    Begin
        Select varvalue into l_UnHoldRealTime from sysvar where sysvar.varname ='UNHOLDREALTIME' and GRNAME='SYSTEM';
    EXCEPTION
        WHEN OTHERS THEN l_UnHoldRealTime := 'N';
    END;

    If  l_UnHoldRealTime ='N' then
        pv_strErrorCode := systemnums.C_SUCCESS;
        RETURN;
    End If;
    --End NamTv

    --Neu tk la corebank thi tinh gia tri can huy
    plog.debug(pkgctx, 'Afacctno: ' || pv_strACCTNO || ' - Corebank: ' || v_strCOREBANK);
    FOR rec IN
    (
        SELECT CF.CUSTODYCD,CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,AF.CAREBY,
        AF.BANKACCTNO,AF.BANKNAME BANKNAME,0 BANKAVAIL,
        CI.HOLDBALANCE BANKHOLDED,
        --getbaldefovd(AF.ACCTNO) AVLRELEASE,
        least(getbaldefovd(af.acctno),
                   ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt -
                   ci.dfintdebtamt - ramt - ci.depofeeamt- nvl(trf.trfbuy_t3,0)) AVLRELEASE,
        CI.HOLDBALANCE HOLDAMT
        FROM AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB,
        (select * from vw_gettrfbuyamt_byDay where afacctno = pv_strACCTNO) trf
        WHERE AF.CUSTID=CF.CUSTID AND CI.AFACCTNO=AF.ACCTNO
        AND AF.BANKNAME=CRB.BANKCODE AND AF.ACCTNO=pv_strACCTNO
        and (af.corebank ='Y' or af.alternateacct='Y')
        and af.acctno = trf.afacctno(+)

    )
    LOOP
        v_dblUnholdBalance:= least(rec.BANKHOLDED, rec.AVLRELEASE);
        IF v_dblUnholdBalance>0 THEN
            v_tltxcd:='6600';
            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;
            v_strNotes:= v_strDesc;
            SELECT varvalue
            INTO v_strCURRDATE
            FROM sysvar
            WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

            SELECT systemnums.C_BATCH_PREFIXED
            || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;

            l_txmsg.brid := substr(pv_strACCTNO,1,4);

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
            l_txmsg.batchname   := 'BANK';
            l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.tltxcd:=v_tltxcd;


            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

            l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := pv_strACCTNO;

            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

            l_txmsg.txfields ('97').defname   := 'CAREBY';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

            l_txmsg.txfields ('93').defname   := 'BANKACCT';
            l_txmsg.txfields ('93').TYPE      := 'C';
            l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

            l_txmsg.txfields ('95').defname   := 'BANKNAME';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE     := rec.BANKNAME;

            l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := rec.BANKAVAIL;

            l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := rec.BANKHOLDED;

            l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := rec.AVLRELEASE;

            l_txmsg.txfields ('96').defname   := 'HOLDAMT';
            l_txmsg.txfields ('96').TYPE      := 'N';
            l_txmsg.txfields ('96').VALUE     := rec.HOLDAMT;

            l_txmsg.txfields ('10').defname   := 'AMOUNT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := v_dblUnholdBalance;

            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := v_strNotes;

            plog.debug(pkgctx,'Begin call 6600');
            BEGIN
                IF txpks_#6600.fn_AutoTxProcess (l_txmsg,
                                                 pv_strErrorCode,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   BEGIN
                       plog.error(pkgctx,'Error when call 6600 , Error code : ' || pv_strErrorCode);
                       ROLLBACK;
                       plog.setendsection (pkgctx, 'pr_RM_UnholdCancelOD');
                       RETURN;
                   END;
                END IF;
            END;
            plog.debug(pkgctx,'End call 6600 , Error code : ' || pv_strErrorCode);
        end if;
    end loop;

    pv_strErrorCode:=0;
    plog.setendsection (pkgctx, 'pr_RM_UnholdCancelOD');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_RM_UnholdCancelOD');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_RM_UnholdAccount;

PROCEDURE pr_RM_UnholdAccountEOD( pv_strACCTNO varchar2,pv_strErrorCode in out varchar2)
IS
   l_txmsg tx.msg_rectype;
   v_dblCount NUMBER(20,0);
   v_strCOREBANK VARCHAR2(10);
   v_straltenateacct VARCHAR2(10);
   v_strBANKCODE  VARCHAR2(10);
   v_dblRemainHold NUMBER(20,0);
   v_dblUnholdBalance NUMBER(20,0);
   v_tltxcd VARCHAR2(4);
   v_strDesc VARCHAR2(250);
   v_strEN_Desc VARCHAR2(250);
   v_strNotes VARCHAR2(250);
   v_strCURRDATE VARCHAR2(10);
   l_err_param VARCHAR2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_RM_UnholdAccountEOD');
    v_dblUnholdBalance:=0;

    --Neu tk la corebank thi tinh gia tri can huy
    plog.debug(pkgctx, 'Afacctno: ' || pv_strACCTNO || ' - Corebank: ' || v_strCOREBANK);
    FOR rec IN
    (
        SELECT CF.CUSTODYCD,CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,AF.CAREBY,
        AF.BANKACCTNO,AF.BANKNAME BANKNAME,0 BANKAVAIL,
        CI.HOLDBALANCE BANKHOLDED,
        --getbaldefovd(AF.ACCTNO) AVLRELEASE,
        least(getbaldefovd(af.acctno),
                   ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt -
                   ci.dfintdebtamt - ramt - ci.depofeeamt- nvl(trf.trfbuy_t3,0)) AVLRELEASE,
        CI.HOLDBALANCE HOLDAMT
        FROM AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB,
        (select * from vw_gettrfbuyamt_byDay where afacctno = pv_strACCTNO) trf
        WHERE AF.CUSTID=CF.CUSTID AND CI.AFACCTNO=AF.ACCTNO
        AND AF.BANKNAME=CRB.BANKCODE AND AF.ACCTNO=pv_strACCTNO
        and (af.corebank ='Y' or af.alternateacct='Y')
        and af.acctno = trf.afacctno(+)

    )
    LOOP
        v_dblUnholdBalance:= least(rec.BANKHOLDED, rec.AVLRELEASE);
        IF v_dblUnholdBalance>0 THEN
            v_tltxcd:='6600';
            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;
            v_strNotes:= v_strDesc;
            SELECT varvalue
            INTO v_strCURRDATE
            FROM sysvar
            WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

            SELECT systemnums.C_BATCH_PREFIXED
            || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;

            l_txmsg.brid := substr(pv_strACCTNO,1,4);

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
            l_txmsg.batchname   := 'BANK';
            l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.tltxcd:=v_tltxcd;


            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

            l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := pv_strACCTNO;

            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

            l_txmsg.txfields ('97').defname   := 'CAREBY';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

            l_txmsg.txfields ('93').defname   := 'BANKACCT';
            l_txmsg.txfields ('93').TYPE      := 'C';
            l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

            l_txmsg.txfields ('95').defname   := 'BANKNAME';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE     := rec.BANKNAME;

            l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := rec.BANKAVAIL;

            l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := rec.BANKHOLDED;

            l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := rec.AVLRELEASE;

            l_txmsg.txfields ('96').defname   := 'HOLDAMT';
            l_txmsg.txfields ('96').TYPE      := 'N';
            l_txmsg.txfields ('96').VALUE     := rec.HOLDAMT;

            l_txmsg.txfields ('10').defname   := 'AMOUNT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := v_dblUnholdBalance;

            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := v_strNotes;

            plog.debug(pkgctx,'Begin call 6600');
            BEGIN
                IF txpks_#6600.fn_AutoTxProcess (l_txmsg,
                                                 pv_strErrorCode,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   BEGIN
                       plog.error(pkgctx,'Error when call 6600 , Error code : ' || pv_strErrorCode);
                       ROLLBACK;
                       plog.setendsection (pkgctx, 'pr_RM_UnholdAccountEOD');
                       RETURN;
                   END;
                END IF;
            END;
            plog.debug(pkgctx,'End call 6600 , Error code : ' || pv_strErrorCode);
        end if;
    end loop;

    pv_strErrorCode:=0;
    plog.setendsection (pkgctx, 'pr_RM_UnholdAccountEOD');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_RM_UnholdAccountEOD');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_RM_UnholdAccountEOD;

PROCEDURE pr_rmSUBBAMTTRFByAccount(p_afacctno varchar2,p_txnum varchar2, p_bchmdl varchar, p_err_code  OUT varchar2)
  IS

    l_txmsg tx.msg_rectype;
    l_CURRDATE varchar2(20);
    l_err_param varchar2(300);
    l_begindate varchar2(10);
    l_trfamt number(20,0);
    l_unholdamt number(20,0);


  BEGIN
    plog.setbeginsection(pkgctx, 'pr_rmSUBBAMTTRFByAccount');
    /*SELECT VARVALUE INTO l_begindate
    FROM SYSVAR WHERE VARNAME='SYSTEMSTARTDATE';*/

    SELECT varvalue
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_begindate:=l_CURRDATE;
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := p_bchmdl;
    l_txmsg.reftxnum     := p_txnum;
    l_txmsg.txdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_CURRDATE,systemnums.c_date_format);

    plog.debug(pkgctx, 'Begin loop');

    for rec in
    (
       select getavlpp(af.acctno) - af.advanceline pp,
            ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt
                       - ramt - ci.depofeeamt- nvl(trf.trfinday,0) remaindaytrf,
            ci.holdbalance,cra.trfcode trftype,cf.custodycd,
            cf.fullname,cf.address,cf.idcode license,
            af.acctno afacctno,af.bankacctno,cra.refacctno desacctno,cra.refacctname desacctname,
            af.bankname bankcode,af.bankname || ':' || crb.bankname bankname , af.careby,
            0 bankavail,ci.holdbalance bankholded,getavlpp(af.acctno) avlrelease,ci.holdbalance holdamt
       from cimast ci, afmast af ,cfmast cf,crbdefacct cra,crbdefbank crb,
       --(select * from vw_gettrfbuyamt_byDay) trf
        (SELECT MST.AFACCTNO, sum(MST.AMT + od.feeacr) trfinday
            FROM STSCHD MST, SBSECURITIES SEC, ODMAST OD
            WHERE MST.CODEID=SEC.CODEID AND SEC.TRADEPLACE  <> '003'
            AND MST.DUETYPE='SM' AND MST.STATUS='N' AND MST.DELTD<>'Y'
            AND MST.ORGORDERID = OD.ORDERID
            and MST.CLEARDATE <= getcurrdate
            group by mst.afacctno) trf
       where ci.acctno = af.acctno and af.custid= cf.custid
       and af.corebank ='N' and af.alternateacct='Y'
       and ci.holdbalance>0
       and af.bankname=cra.refbank and cra.trfcode='TRFCICAMT'
       and af.bankname=crb.bankcode
       and af.acctno = trf.afacctno(+)
       and af.acctno = p_afacctno
    )
    loop -- rec
        BEGIN
            plog.debug(pkgctx, 'Loop for account : ' || rec.afacctno);

            if rec.pp >= rec.holdbalance then
                l_unholdamt := greatest(least(rec.holdbalance,rec.remaindaytrf),0);
                l_trfamt := rec.holdbalance-l_unholdamt;
            else
                --l_trfamt:= least(rec.holdbalance-rec.pp,rec.holdbalance);
                --l_unholdamt:=rec.holdbalance-l_trfamt;
                l_unholdamt:=greatest(least(rec.pp,rec.remaindaytrf),0);
                l_trfamt := rec.holdbalance-l_unholdamt;
            end if;
            --Chuyen bang ke Ho tro thanh toan tien cho tai khoan chinh
            if l_trfamt>0 then
                l_txmsg.tltxcd:='6668';

                --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

                --Set cac field giao dich
                --06   C   TRFTYPE
                l_txmsg.txfields ('06').defname   := 'TRFTYPE';
                l_txmsg.txfields ('06').TYPE      := 'C';
                l_txmsg.txfields ('06').VALUE     := rec.TRFTYPE;
                --88  CUSTODYCD
                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;
                --03  SECACCOUNT
                l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

                --90  CUSTNAME
                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                l_txmsg.txfields ('90').TYPE      := 'C';
                l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

                --91  ADDRESS
                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                l_txmsg.txfields ('91').TYPE      := 'C';
                l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

                --92  LICENSE
                l_txmsg.txfields ('92').defname   := 'LICENSE';
                l_txmsg.txfields ('92').TYPE      := 'C';
                l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

                --93  BANKACCTNO
                l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
                l_txmsg.txfields ('93').TYPE      := 'C';
                l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

                --05  DESACCTNO
                l_txmsg.txfields ('05').defname   := 'DESACCTNO';
                l_txmsg.txfields ('05').TYPE      := 'C';
                l_txmsg.txfields ('05').VALUE     := rec.DESACCTNO;

                --07  DESACCTNAME
                l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
                l_txmsg.txfields ('07').TYPE      := 'C';
                l_txmsg.txfields ('07').VALUE     := rec.DESACCTNAME;

                --94  BANKNAME
                l_txmsg.txfields ('94').defname   := 'BANKNAME';
                l_txmsg.txfields ('94').TYPE      := 'C';
                l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

                --95  BANKQUE
                l_txmsg.txfields ('95').defname   := 'BANKQUE';
                l_txmsg.txfields ('95').TYPE      := 'C';
                l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

                --10  AMOUNT
                l_txmsg.txfields ('10').defname   := 'AMOUNT';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := l_trfamt;

                --02  CATXNUM
                l_txmsg.txfields ('02').defname   := 'CATXNUM';
                l_txmsg.txfields ('02').TYPE      := 'C';
                l_txmsg.txfields ('02').VALUE     := rec.afacctno;

                --30   C   DESC
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := ' TK:' || rec.custodycd ||' ' || utf8nums.c_const_TLTX_TXDESC_6668 ; --|| l_CURRDATE;

                BEGIN
                    IF txpks_#6668.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 6668: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN;
                    END IF;
                END;

                --Gom bang ke tu dong luon
                ----Auto Gen request
                cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(l_txmsg.txdate, 'dd/mm/rrrr'), l_txmsg.txnum,p_err_code);
            end if;
            --Goi giao dich thuc hien Unhold phan con du
            /*if l_unholdamt>0 then
                l_txmsg.tltxcd:='6600';
                --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

                l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                l_txmsg.txfields ('90').TYPE      := 'C';
                l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                l_txmsg.txfields ('91').TYPE      := 'C';
                l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

                l_txmsg.txfields ('92').defname   := 'LICENSE';
                l_txmsg.txfields ('92').TYPE      := 'C';
                l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

                l_txmsg.txfields ('97').defname   := 'CAREBY';
                l_txmsg.txfields ('97').TYPE      := 'C';
                l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

                l_txmsg.txfields ('93').defname   := 'BANKACCT';
                l_txmsg.txfields ('93').TYPE      := 'C';
                l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

                l_txmsg.txfields ('95').defname   := 'BANKNAME';
                l_txmsg.txfields ('95').TYPE      := 'C';
                l_txmsg.txfields ('95').VALUE     := rec.bankcode;

                l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
                l_txmsg.txfields ('11').TYPE      := 'N';
                l_txmsg.txfields ('11').VALUE     := rec.BANKAVAIL;

                l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
                l_txmsg.txfields ('12').TYPE      := 'N';
                l_txmsg.txfields ('12').VALUE     := rec.BANKHOLDED;

                l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
                l_txmsg.txfields ('13').TYPE      := 'N';
                l_txmsg.txfields ('13').VALUE     := rec.AVLRELEASE;

                l_txmsg.txfields ('96').defname   := 'HOLDAMT';
                l_txmsg.txfields ('96').TYPE      := 'N';
                l_txmsg.txfields ('96').VALUE     := rec.HOLDAMT;

                l_txmsg.txfields ('10').defname   := 'AMOUNT';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := l_unholdamt;

                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := 'Unhold tien ho tro suc mua tai khoan chinh';

                BEGIN
                    IF txpks_#6600.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 6600: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN;
                    END IF;
                END;
            end if;*/
        END;
    end loop; -- rec

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_rmSUBBAMTTRFByAccount');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_rmSUBBAMTTRFByAccount');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_rmSUBBAMTTRFByAccount;

PROCEDURE pr_rmSUBReleaseBalance(p_acctno varchar,p_maxamt number, p_bchmdl varchar2, p_err_code  OUT varchar2)
  IS

    l_txmsg tx.msg_rectype;
    l_CURRDATE varchar2(20);
    l_err_param varchar2(300);
    l_begindate varchar2(10);
    l_trfamt number(20,0);
    l_maxtrfamt number;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_rmSUBReleaseBalance');
    /*SELECT VARVALUE INTO l_begindate
    FROM SYSVAR WHERE VARNAME='SYSTEMSTARTDATE';*/
    if p_maxamt <=0 then
        l_maxtrfamt:=1000000000000;
    else
        l_maxtrfamt:= p_maxamt;
    end if;
    SELECT varvalue INTO l_CURRDATE FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_begindate:=l_CURRDATE;
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   :='BANK';
    l_txmsg.txdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_CURRDATE,systemnums.c_date_format);

    plog.debug(pkgctx, 'Begin loop');

    for rec in
    (
       select cra.trfcode trftype,cf.custodycd,
            cf.fullname,cf.address,cf.idcode license,
            af.acctno afacctno,af.bankacctno,cra.refacctno desacctno,cra.refacctname desacctname,
            af.bankname bankcode,af.bankname || ':' || crb.bankname bankname , af.careby,
            least(getbaldefovd(af.acctno) + CEIL(CI.CIDEPOFEEACR), --Ngay 17/03/2017 NamTv bo phi luu ky cong don ra cong thuc chuyen tien ve tk ngan hang
                       ci.balance - ci.holdbalance - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt
                       - ramt - ci.depofeeamt- nvl(trf.trfbuy_t3,0)) trfamt,ci.balance,nvl(tl.rm_amt,0) rm_amt,ci.holdbalance
       from cimast ci, afmast af ,cfmast cf,crbdefacct cra,crbdefbank crb,
       (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance group by afacctno) adv,
       (select * from vw_gettrfbuyamt_byDay where afacctno = p_acctno) trf,
       (SELECT sum(msgamt) rm_amt,msgacct afacctno    FROM tllog
        WHERE tltxcd ='8866' AND deltd <>'Y'
        GROUP BY msgacct) tl
       where ci.acctno = af.acctno and af.custid= cf.custid
       AND ci.acctno = tl.afacctno(+)
       and af.corebank ='N' and af.alternateacct='Y'
       and af.autotrf ='Y' --Cho cho chuyen voi tai khoan co dang ky chuyen tu dong. Neu khong dang ky muon chuyen phai dung giao dich chuyen tien
       and af.bankname=cra.refbank and cra.trfcode='TRFSUBTRER'
       and af.bankname=crb.bankcode
       and ci.acctno = adv.afacctno(+)
       and af.acctno = trf.afacctno(+)
       and af.acctno = p_acctno

    )
    loop -- rec
        BEGIN
            plog.error(pkgctx, 'pr_rmSUBReleaseBalance Loop for account : ' || rec.afacctno);
            l_trfamt := rec.trfamt;
            l_trfamt:= least(l_trfamt,l_maxtrfamt);
            --Chuyen bang ke Ho tro thanh toan tien cho tai khoan chinh
            if l_trfamt>0 then
                l_txmsg.tltxcd:='6669';

                --set txnum
                SELECT systemnums.C_BATCH_PREFIXED
                                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                              INTO l_txmsg.txnum
                              FROM DUAL;
                l_txmsg.brid        := substr(rec.AFACCTNO,1,4);

                --Set cac field giao dich
                --06   C   TRFTYPE
                l_txmsg.txfields ('06').defname   := 'TRFTYPE';
                l_txmsg.txfields ('06').TYPE      := 'C';
                l_txmsg.txfields ('06').VALUE     := rec.TRFTYPE;
                --88  CUSTODYCD
                l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
                l_txmsg.txfields ('88').TYPE      := 'C';
                l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;
                --03  SECACCOUNT
                l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
                l_txmsg.txfields ('03').TYPE      := 'C';
                l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

                --90  CUSTNAME
                l_txmsg.txfields ('90').defname   := 'CUSTNAME';
                l_txmsg.txfields ('90').TYPE      := 'C';
                l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

                --91  ADDRESS
                l_txmsg.txfields ('91').defname   := 'ADDRESS';
                l_txmsg.txfields ('91').TYPE      := 'C';
                l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

                --92  LICENSE
                l_txmsg.txfields ('92').defname   := 'LICENSE';
                l_txmsg.txfields ('92').TYPE      := 'C';
                l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

                --93  BANKACCTNO
                l_txmsg.txfields ('93').defname   := 'BANKACCTNO';
                l_txmsg.txfields ('93').TYPE      := 'C';
                l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

                --05  DESACCTNO
                l_txmsg.txfields ('05').defname   := 'DESACCTNO';
                l_txmsg.txfields ('05').TYPE      := 'C';
                l_txmsg.txfields ('05').VALUE     := rec.DESACCTNO;

                --07  DESACCTNAME
                l_txmsg.txfields ('07').defname   := 'DESACCTNAME';
                l_txmsg.txfields ('07').TYPE      := 'C';
                l_txmsg.txfields ('07').VALUE     := rec.DESACCTNAME;

                --94  BANKNAME
                l_txmsg.txfields ('94').defname   := 'BANKNAME';
                l_txmsg.txfields ('94').TYPE      := 'C';
                l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

                --95  BANKQUE
                l_txmsg.txfields ('95').defname   := 'BANKQUE';
                l_txmsg.txfields ('95').TYPE      := 'C';
                l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

                --10  AMOUNT
                l_txmsg.txfields ('10').defname   := 'AMOUNT';
                l_txmsg.txfields ('10').TYPE      := 'N';
                l_txmsg.txfields ('10').VALUE     := l_trfamt;

                --02  CATXNUM
                IF   substr(nvl(p_bchmdl,'XXXXXX'),1,6) in ('3350@@','3354@@')  THEN

                l_txmsg.txfields ('02').defname   := 'CATXNUM';
                l_txmsg.txfields ('02').TYPE      := 'C';
                l_txmsg.txfields ('02').VALUE     := substr(nvl(p_bchmdl,'XXXX'),1,4);

                ELSE
                l_txmsg.txfields ('02').defname   := 'CATXNUM';
                l_txmsg.txfields ('02').TYPE      := 'C';
                l_txmsg.txfields ('02').VALUE     := rec.afacctno;

                END IF;

                --30   C   DESC
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';

                 if substr(nvl(p_bchmdl,'XXXXXX'),1,6) in ('1120@@','1130@@','1131@@','1141@@','1153@@','1137@@','1138@@','3350@@','3354@@','8878@@') then
                    l_txmsg.txfields ('30').VALUE := UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF4||  substr(p_bchmdl,7) || ' ' || UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF2  || CASE WHEN rec.trfamt<>rec.balance THEN UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF3   ELSE '' END ;
                 elsif p_bchmdl='SAMTTRF' then
                    --l_txmsg.txfields ('30').VALUE:= UTF8NUMS.c_const_TLTX_TXDESC_6669_RM || UTF8NUMS.c_const_TLTX_TXDESC_6669_RM2;
                    IF rec.rm_amt>0 THEN
                     l_txmsg.txfields ('30').VALUE:=UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF|| rec.CUSTODYCD||UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF_D|| to_char(get_t_date(getcurrdate,3),'dd/mm/yyyy') ||UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF2 ||
                     CASE WHEN rec.trfamt<>rec.balance - rec.holdbalance THEN UTF8NUMS.c_const_TLTX_TXDESC_SAMTTRF3 ELSE '' END ;
                     ELSE
                     l_txmsg.txfields ('30').VALUE:= UTF8NUMS.c_const_TLTX_TXDESC_6669_RM || UTF8NUMS.c_const_TLTX_TXDESC_6669_RM2;
                     END IF ;
           /*     elsif substr(nvl(p_bchmdl,'XXXXXX'),1,6) in ('3350@@','3354@@')  THEN
                    l_txmsg.txfields ('30').VALUE     := substr(p_bchmdl,7); --Cho nhan quyen ve 3350, 3354*/
                else
                    --l_txmsg.txfields ('30').VALUE     := utf8nums.c_const_TLTX_TXDESC_6669_Inday || l_CURRDATE;
                    l_txmsg.txfields ('30').VALUE:= UTF8NUMS.c_const_TLTX_TXDESC_6669_RM || UTF8NUMS.c_const_TLTX_TXDESC_6669_RM2;
                end if;

                BEGIN
                    IF txpks_#6669.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 6668: ' || p_err_code
                       );
                       ROLLBACK;
                       RETURN;
                    END IF;
                END;
                --Neu giao dich chuyen tien trong ngay thi gen bang ke tu dong ngay.
                --Trong batch thi thuc hien gom chung vaof 1 bang ke
                if fopks_api.fn_is_ho_active and substr(nvl(p_bchmdl,'XXXXXX'),1,6) <> '3350@@'  and substr(nvl(p_bchmdl,'XXXXXX'),1,6) <> '3354@@' then
                    cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(l_txmsg.txdate, 'dd/mm/rrrr'), l_txmsg.txnum,p_err_code);
                end if;


            end if;
        END;
    end loop; -- rec

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_rmSUBReleaseBalance');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_rmSUBReleaseBalance');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_rmSUBReleaseBalance;

PROCEDURE pr_rmGroupRequest(p_TRFCODE in varchar2,p_err_code out varchar2)
IS
    l_CURRDATE date;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_rmGroupRequest');
    plog.debug (pkgctx, '<<BEGIN OF pr_rmGroupRequest');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    --Chi group cho nhung bang ke co trang thai ='P'
    if p_TRFCODE ='TRFODSELL' then
        --Nhom cac bang ke 'TRFODSELL','TRFODSFEE','TRFAUTOADPAID','TRFODTAX' thanh loai bang ke khac voi bang ke mater la TRFODSELL
        for rec in (
            select afacctno, reqid from crbtxreq where trfcode='TRFODSELL' and txdate = l_CURRDATE
        )
        loop
            update crbtxreq set grpreqid = rec.reqid where afacctno=rec.afacctno and trfcode in ('TRFODSELL','TRFODSFEE','TRFAUTOADPAID','TRFODTAX') and txdate =l_CURRDATE;
        end loop;
    end if;


    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF pr_rmGroupRequest');
    plog.setendsection (pkgctx, 'pr_rmGroupRequest');
EXCEPTION
    WHEN OTHERS
    THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_rmGroupRequest');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_rmGroupRequest;


PROCEDURE FILLTER_CRB_OFFLINE_SYNC(p_BankCode in varchar2, p_tlid in varchar2,p_err_code  OUT varchar2,p_err_message  OUT varchar2)
IS
  v_count NUMBER;
  v_CurrDate Date;
  v_BankCode VARCHAR2(20);
  v_SynID number;
BEGIN

    /*
    13/11/2013 - TRUONGLD ADD
    GHI NHAN VAO DB DU LIEU IMPORT DUOC TU FILE DAU NGAY
    */

    plog.setbeginsection (pkgctx, 'FILLTER_CRB_OFFLINE_SYNC');
    plog.debug (pkgctx, '<<BEGIN OF FILLTER_CRB_OFFLINE_SYNC');

    v_CurrDate := getcurrdate();

    v_BankCode := '';
    v_SynID := SEQ_CRB_OFFLINE_BODSYNC.NEXTVAL;
    -- BACKUP LAI DU LIEU CU
    INSERT INTO CRB_OFFLINE_BODSYNCLOG(AUTOID, CUSTODYCD, AFACCTNO, BANKCODE, BANKNAME, ACCOUNTTYPE, BANKACCOUNT, BALANCE, AVLBALANCE, CUSTOMERNAME,
                                    IDNUMBER, CREATEDATE, MAKERID, APPROVEID, STATUS, PSTATUS, FEEDBACKMSG, REFAUTOID, TXNUM)
    SELECT AUTOID, CUSTODYCD, AFACCTNO, BANKCODE, BANKNAME, ACCOUNTTYPE, BANKACCOUNT, BALANCE, AVLBALANCE, CUSTOMERNAME,
                                    v_SynID, CREATEDATE, MAKERID, APPROVEID, STATUS, PSTATUS, FEEDBACKMSG, REFAUTOID,TXNUM
    FROM CRB_OFFLINE_BODSYNC WHERE BANKCODE LIKE '%' || v_BankCode || '%' or BANKCODE is null;

    -- XOA DU LIEU CU DI
    DELETE FROM CRB_OFFLINE_BODSYNC WHERE BANKCODE LIKE '%' || v_BankCode || '%' or BANKCODE is null;

    -- GHI NHAN DU LIEU MOI VAO HE THONG
     INSERT INTO CRB_OFFLINE_BODSYNC(AUTOID, CUSTODYCD, AFACCTNO, BANKCODE, BANKNAME, ACCOUNTTYPE, BANKACCOUNT, BALANCE, AVLBALANCE, CUSTOMERNAME,
                                    IDNUMBER, CREATEDATE, MAKERID, APPROVEID, STATUS, PSTATUS, FEEDBACKMSG, REFAUTOID)
    SELECT SEQ_CRB_OFFLINE_BODSYNC.NEXTVAL AUTOID, nvl(af.CUSTODYCD, mst.CUSTODYCD) CUSTODYCD, AF.ACCTNO AFACCTNO, nvl(AF.BANKNAME, MST.BANKCODE) BANKCODE,
           NVL(A1.CDCONTENT, MST.BANKNAME) BANKNAME, 'P' ACCOUNTTYPE, NVL(AF.BANKACCTNO, MST.BANKACCOUNT) BANKACCOUNT, MST.BALANCE, MST.AVLBALANCE,
           NVL(af.FULLNAME, MST.CUSTOMERNAME) CUSTOMERNAME, MST.IDNUMBER, MST.CREATEDATE CREATEDATE,  P_TLID MAKERID, '' APPROVEID,
         CASE WHEN nvl(af.CUSTODYCD, mst.CUSTODYCD) is null or nvl(DB.STATUS, 'A') = 'A' or length(nvl(af.CUSTODYCD, mst.CUSTODYCD)) = 0 or AF.STATUS ='C' THEN 'E' ELSE 'N' END STATUS,'' PSTATUS,
         CASE WHEN nvl(af.CUSTODYCD, mst.CUSTODYCD) is null or nvl(DB.STATUS, 'A') = 'A' or length(nvl(af.CUSTODYCD, mst.CUSTODYCD)) = 0 or AF.STATUS ='C' THEN 'Du lieu bi loi'
         ELSE '' END FEEDBACKMSG, MST.AUTOID REFAUTOID
    FROM vw_afmast_custodycd af, (SELECT * FROM ALLCODE WHERE CDNAME ='BANKNAME') A1, T_CRB_OFFLINE_BODSYNC MST, crbdefbank db
    WHERE --af.CUSTID = AF.CUSTID
--          AND AF.COREBANK ='Y'  phs ko quan tam core bank
          --AF.ALTERNATEACCT='Y'   --tieu khoan chinh phu
          --nvl(AF.BANKNAME, MST.BANKCODE) = A1.CDVAL(+)
           MST.BANKCODE = A1.CDVAL(+)
          and trim(MST.BANKCODE) = DB.BANKCODE(+)
          AND trim(MST.BANKACCOUNT) = AF.BANKACCTNO(+)
          AND trim(MST.BANKCODE) = AF.BANKNAME(+);
    --AnTB commented 02/02/2015 ghi nhan luon ca du lieu khong ton tai trong he thong
    /*SELECT SEQ_CRB_OFFLINE_BODSYNC.NEXTVAL AUTOID, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, AF.BANKNAME BANKCODE,
           A1.CDCONTENT BANKNAME, 'P' ACCOUNTTYPE, AF.BANKACCTNO BANKACCOUNT, MST.BALANCE, MST.AVLBALANCE, CF.FULLNAME CUSTOMERNAME,
           MST.IDNUMBER, MST.CREATEDATE CREATEDATE, P_TLID MAKERID, '' APPROVEID, 'N' STATUS, '' PSTATUS, '' FEEDBACKMSG, MST.AUTOID REFAUTOID
    FROM CFMAST CF, AFMAST AF, ALLCODE A1, T_CRB_OFFLINE_BODSYNC MST
    WHERE CF.CUSTID = AF.CUSTID
--          AND AF.COREBANK ='Y'  phs ko quan tam core bank
          AND AF.ALTERNATEACCT='Y'   --tieu khoan chinh phu
          AND AF.BANKNAME = A1.CDVAL
          AND A1.CDNAME ='BANKNAME'
          AND MST.BANKACCOUNT = AF.BANKACCTNO
          AND MST.BANKCODE = AF.BANKNAME;*/

    -- CAP NHAT TRANG THAI --> DA GHI DU LIEU VAO HE THONG
    UPDATE T_CRB_OFFLINE_BODSYNC SET MAKERID = p_tlid; --, CREATEDATE = v_CurrDate; khong cho cap nhat lai ngay vi co dau vao ngay trong file import
     -- cap nhat trang thai loi voi dong du lieu co ngay ko dung
      UPDATE CRB_OFFLINE_BODSYNC SET STATUS='E' , FEEDBACKMSG ='Du lieu bi loi' where  CREATEDATE <> v_CurrDate;

    -- ANTB 23/11/2013
    -- BEGIN GHI NHAN DU LIEU TAI KHOAN NGAN HANG KHONG DONG BO DUOC
    IF p_BankCode = '01' THEN
       v_BankCode := 'PNB';
    ELSE
       v_BankCode := '%' || '' || '%';
    END IF;
    /*
    INSERT INTO CRB_OFFLINE_UNSYNCED (CUSTODYCD, BANKCODE, BANKNAME, ACCOUNTTYPE, BANKACCOUNT, BALANCE, AVLBALANCE, CUSTOMERNAME, IDNUMBER, CREATEDATE, MAKERID, STATUS, PSTATUS, REFAUTOID)
    SELECT MST.CUSTODYCD, v_BankCode BANKCODE, NVL(MST.BANKNAME, A1.BANKNAME) BANKNAME, MST.ACCOUNTTYPE, MST.BANKACCOUNT, MST.BALANCE, MST.AVLBALANCE,
           MST.CUSTOMERNAME, MST.IDNUMBER, MST.CREATEDATE, MST.MAKERID, MST.STATUS, MST.PSTATUS, MST.AUTOID REFAUTOID
    FROM T_CRB_OFFLINE_BODSYNC MST, CRBDEFBANK A1
    WHERE A1.ROOTCODE = v_BankCode
          AND NOT EXISTS (SELECT *
                            FROM CRB_OFFLINE_BODSYNC CRB
                            WHERE CRB.BANKACCOUNT = MST.BANKACCOUNT
                                  AND CRB.CREATEDATE = MST.CREATEDATE
                                  AND CRB.REFAdbms_output.put_line('');UTOID = MST.AUTOID);
    */
    DELETE FROM CRB_OFFLINE_UNSYNCED WHERE CREATEDATE = getcurrdate;
    INSERT INTO CRB_OFFLINE_UNSYNCED (CUSTODYCD, BANKCODE, BANKNAME, ACCOUNTTYPE, BANKACCOUNT, BALANCE, AVLBALANCE, CUSTOMERNAME, IDNUMBER, CREATEDATE, MAKERID, STATUS, PSTATUS, REFAUTOID)
    SELECT MST.CUSTODYCD, MST.BANKCODE, MST.BANKNAME BANKNAME, MST.ACCOUNTTYPE, MST.BANKACCOUNT, MST.BALANCE, MST.AVLBALANCE,
           MST.CUSTOMERNAME, MST.IDNUMBER, MST.CREATEDATE, MST.MAKERID, MST.STATUS, MST.PSTATUS, MST.AUTOID REFAUTOID
    FROM T_CRB_OFFLINE_BODSYNC MST
    WHERE EXISTS ( SELECT * FROM
                     (
                        SELECT T.BANKACCOUNT, T.BALANCE, T.CREATEDATE, T.BANKCODE
                        FROM T_CRB_OFFLINE_BODSYNC T
                        --WHERE BANKCODE LIKE v_BankCode
                        MINUS
                        SELECT T.BANKACCOUNT, T.BALANCE, T.CREATEDATE,T.BANKCODE
                        FROM CRB_OFFLINE_BODSYNC T
                      --  WHERE BANKCODE LIKE  '%' || v_BankCode || '%'
                     ) T
                 WHERE T.BANKACCOUNT = MST.BANKACCOUNT AND T.BALANCE = MST.BALANCE AND T.CREATEDATE = MST.CREATEDATE
                );
    -- END GHI NHAN DU LIEU TAI KHOAN NGAN HANG KHONG DONG BO DUOC

    p_err_code := 0;
    p_err_message := 'Successful!';
    COMMIT;
    plog.setendsection (pkgctx, 'cspks_mrproc.FILLTER_CRB_OFFLINE_SYNC');
    RETURN;
EXCEPTION
    WHEN OTHERS
    THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'cspks_mrproc.FILLTER_CRB_OFFLINE_SYNC');
      ROLLBACK;
      RETURN ;
END FILLTER_CRB_OFFLINE_SYNC;


PROCEDURE APPROVE_CRB_OFFLINE_SYNC (p_BankCode in varchar2, p_tlid in varchar2, p_err_code  OUT varchar2, p_err_message  OUT varchar2)
IS
    v_count NUMBER;
      v_CurrDate Date;
    v_BankCode VARCHAR2(20);
    l_txmsg               tx.msg_rectype;
    l_err_param varchar2(300);
BEGIN


     UNHOLD_BF_CRB_ONLINE_SYNC(p_BankCode, p_tlid , p_err_code , p_err_message );

     IF p_err_code <> systemnums.c_success
        THEN
            plog.debug (pkgctx,
                 'got error 6674: ' || p_err_message
             );
     end if;
    /*
    13/11/2013 - TRUONGLD ADD
    SINH GD CAP NHAT SO DU IMPORT DAU NGAY TU NH
    */

    plog.setbeginsection(pkgctx, 'cspks_mrproc.APPROVE_CRB_OFFLINE_SYNC');

    v_CurrDate := getcurrdate();
    v_BankCode := '';

    l_txmsg.msgtype :='T';
    l_txmsg.local   :='N';
    l_txmsg.tlid    := p_tlid;

    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
         SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
        INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;

    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';

    l_txmsg.batchname   := 'IMPOFF';
    l_txmsg.busdate     := v_CurrDate;
    l_txmsg.txdate      := v_CurrDate;


    BEGIN




        FOR REC IN
        (

           SELECT CRB.AUTOID, CRB.CUSTODYCD, CRB.AFACCTNO, CRB.BANKCODE, CRB.BANKNAME, CRB.ACCOUNTTYPE, CRB.BANKACCOUNT,
                    -- 16/01/2013 - TRUONGLD ADD
                    -- DO BEN NH ACB QUY DINH SO DU TOI THIEU 100K
                    -- NEU NEU DONG BO SO DU D/V NH ACB --> TRU DI 100K TRUOC KHI DONG BO VAO HE THONG.
                   --(CRB.BALANCE + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) - CI.HOLDBALANCE - BD.MINAMOUNTI)  BALANCE, --AnTB 24/03/2015 add + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) de tang tien ban nhan cho ve
                   --AnTB 24/03/2015 add + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) de tang tien ban nhan cho ve
                   --23/03/2016, TruongLD Add, truoc khi Hold da Unhold roi --> khong can - CI.HOLDBALANCE nua.
                   (CRB.BALANCE + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) - BD.MINAMOUNTI)  BALANCE,
                   -- END TRUONGLD
                   --CRB.BALANCE,
                   CRB.CUSTOMERNAME, CRB.IDNUMBER, CRB.CREATEDATE, CRB.MAKERID, CRB.APPROVEID, CRB.STATUS, CRB.PSTATUS, CF.ADDRESS,
                   CF.IDCODE, CF.CAREBY, 'PHONG TOA SO DU TK: ' || CRB.CUSTODYCD || ' TAI NGAN HANG' DESCRIPTION
            FROM CRB_OFFLINE_BODSYNC CRB, CFMAST CF, CIMAST CI, AFMAST AF, VW_CIMAST_CRBINFO INFO, CRBDEFBANK BD
            WHERE CRB.CUSTODYCD = CF.CUSTODYCD
                  AND CRB.AFACCTNO = CI.ACCTNO
                  and af.acctno = ci.acctno
                  AND AF.ACCTNO = INFO.ACCTNO
                  AND AF.ALTERNATEACCT = 'Y'
                  AND CRB.BANKCODE = BD.BANKCODE
                  AND CRB.STATUS = 'N'
                  --AND (CRB.BALANCE + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) - CI.HOLDBALANCE - BD.MINAMOUNTI) > 0
                  AND (CRB.BALANCE + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) - BD.MINAMOUNTI) > 0
                  AND CRB.CREATEDATE = v_CurrDate
               --   AND CRB.BANKCODE LIKE '%' || v_BankCode || '%'

        )LOOP

            l_txmsg.tltxcd:='6692'; -- Phong toa so du offline
            --Set txnum
            SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                INTO l_txmsg.txnum
            FROM DUAL;
            --Set txtime
            select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
            --Set brid
            l_txmsg.brid        := '0001';
            --Set cac field giao dich
            --88  CUSTODYCD      C
            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

            --03  AFACCTNO      C
            l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

            --90  CUSTNAME      C
            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.CUSTOMERNAME;

            --91  ADDRESS      C
            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

            --92  LICENSE      C
            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.IDCODE;

            --97  CAREBY      C
            l_txmsg.txfields ('97').defname   := 'CAREBY';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

            --93  BANKACCT      C
            l_txmsg.txfields ('93').defname   := 'BANKACCT';
            l_txmsg.txfields ('93').TYPE      := 'C';
            l_txmsg.txfields ('93').VALUE     := rec.BANKACCOUNT;

            --94  BANKNAME      C
            l_txmsg.txfields ('94').defname   := 'BANKNAME';
            l_txmsg.txfields ('94').TYPE      := 'C';
            l_txmsg.txfields ('94').VALUE     := rec.BANKNAME;

            --95  BANKQUE      C
            l_txmsg.txfields ('95').defname   := 'BANKQUE';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

            --10  AMOUNT     N
            l_txmsg.txfields ('10').defname   := 'AMOUNT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := rec.BALANCE;

            --11  BANKAVAIL     N
            l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
            l_txmsg.txfields ('11').TYPE      := 'C';
            l_txmsg.txfields ('11').VALUE     := rec.BALANCE;

            --12  BANKHOLDED     N
            l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
            l_txmsg.txfields ('12').TYPE      := 'C';
            l_txmsg.txfields ('12').VALUE     := 0;

            --12  AVLRELEASE     N
            l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
            l_txmsg.txfields ('13').TYPE      := 'C';
            l_txmsg.txfields ('13').VALUE     := 0;

            --96  HOLDAMT     N
            l_txmsg.txfields ('96').defname   := 'HOLDAMT';
            l_txmsg.txfields ('96').TYPE      := 'C';
            l_txmsg.txfields ('96').VALUE     := 0;

            l_txmsg.txfields ('98').defname   := 'REFTXNUM';
            l_txmsg.txfields ('98').TYPE      := 'C';
            l_txmsg.txfields ('98').VALUE     := '';

            l_txmsg.txfields ('99').defname   := 'AUTO';
            l_txmsg.txfields ('99').TYPE      := 'C';
            l_txmsg.txfields ('99').VALUE     := 'N';

            --30  AMOUNT     C
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := rec.DESCRIPTION;

            BEGIN



                IF txpks_#6692.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 6692: ' || 6692
                   );
                   --ROLLBACK;

                   UPDATE CRB_OFFLINE_BODSYNC
                        SET STATUS ='E', PSTATUS = PSTATUS || STATUS,
                            APPROVEID = p_tlid,
                            FEEDBACKMSG = 'That bai'
                   WHERE AUTOID = REC.AUTOID;
                END IF;

                UPDATE CRB_OFFLINE_BODSYNC
                    SET STATUS ='Y', PSTATUS = PSTATUS || STATUS,TXNUM =l_txmsg.txnum,
                        APPROVEID = p_tlid,
                        FEEDBACKMSG = 'Thanh cong'
                WHERE AUTOID = REC.AUTOID;
            END;
        END LOOP;
    END;
    --BEGIN ANTB 26/11/2013 lay so tai khoan cap nhat thanh cong
    SELECT COUNT(*) INTO v_count FROM CRB_OFFLINE_BODSYNC WHERE STATUS ='Y';-- AND BANKCODE LIKE '%' || v_BankCode || '%';
    -- END ANTB 26/11/2013 lay so tai khoan cap nhat thanh cong

    -- Cap nhat thong tin ve nguoi import
    --UPDATE CRB_OFFLINE_SYN SET MAKERID = p_tlid;
    p_err_code := 0;
    p_err_message := v_count;
    plog.setendsection (pkgctx, 'cspks_mrproc.APPROVE_CRB_OFFLINE_SYNC');
    COMMIT;
    RETURN;
EXCEPTION
    WHEN OTHERS
    THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'cspks_mrproc.APPROVE_CRB_OFFLINE_SYNC');
      ROLLBACK;
      RETURN ;
END APPROVE_CRB_OFFLINE_SYNC;



PROCEDURE UNHOLD_BF_CRB_ONLINE_SYNC(p_BankCode in varchar2, p_tlid in varchar2, p_err_code  OUT varchar2, p_err_message  OUT varchar2)
IS
   l_txmsg tx.msg_rectype;
   v_dblCount NUMBER(20,0);
   v_strCOREBANK VARCHAR2(10);
   v_straltenateacct VARCHAR2(10);
   v_strBANKCODE  VARCHAR2(10);
   v_dblRemainHold NUMBER(20,0);
   v_dblUnholdBalance NUMBER(20,0);
   v_tltxcd VARCHAR2(4);
   v_strDesc VARCHAR2(250);
   v_strEN_Desc VARCHAR2(250);
   v_strNotes VARCHAR2(250);
   v_strCURRDATE VARCHAR2(10);
   l_err_param VARCHAR2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'UNHOLD_BF_CRB_ONLINE_SYNC');
    v_dblUnholdBalance:=0;

     SELECT varvalue
            INTO v_strCURRDATE
            FROM sysvar
            WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    --Neu tk la corebank thi tinh gia tri can huy
    plog.debug(pkgctx, 'Bankcode: ' || p_BankCode || ' - TLID: ' || p_tlid);
    FOR rec IN
    (



   SELECT CF.CUSTODYCD,CF.FULLNAME,CF.ADDRESS,CF.IDCODE LICENSE,
        AF.ACCTNO AFACCTNO, AF.CAREBY, AF.BANKACCTNO,AF.BANKNAME BANKNAME,
        --13/07/2015, TruongLD Add,
        --getbaldefovd(AF.ACCTNO) BANKAVAIL,
         least(getbaldefovd(af.acctno),
                   ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt -
                   ci.dfintdebtamt - ci.ramt - ci.depofeeamt- nvl(trf.trfbuy_t3,0)) BANKAVAIL,
       -- getrmbaldefavl(AF.ACCTNO) BANKAVAIL,
        -- End TruongLD
       --    (CRB.BALANCE + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0)  - BD.MINAMOUNTI)  BANKHOLDED,
       CI.HOLDBALANCE BANKHOLDED,
        --UNHOLD HET SO TIEN TRONG BALANCE
        CI.BALANCE AVLRELEASE,
        CI.HOLDBALANCE HOLDAMT
            FROM
               CRB_OFFLINE_BODSYNC CRB,(select * from vw_gettrfbuyamt_byDay ) trf,
                 CFMAST CF, CIMAST CI, AFMAST AF, VW_CIMAST_CRBINFO INFO--, CRBDEFBANK BD
            WHERE CRB.CUSTODYCD = CF.CUSTODYCD
                  AND CRB.AFACCTNO = CI.ACCTNO
                  and  af.acctno = ci.acctno
                   and cf.custid =  af.custid
                  AND AF.ACCTNO = INFO.ACCTNO
                  and af.alternateacct = 'Y'
                  AND CRB.BANKCODE = AF.BANKNAME
                  AND AF.BANKACCTNO = CRB.bankaccount
                  and af.acctno = trf.afacctno(+)
                  and af.status <> 'C'
                 -- AND (CRB.BALANCE + DECODE(AF.AUTOTRF, 'Y', INFO.AVLBALANCE,0) - BD.MINAMOUNTI ) > 0
                  and CI.HOLDBALANCE > 0

    )
    LOOP
        v_dblUnholdBalance:= rec.BANKHOLDED;
        IF v_dblUnholdBalance>0 THEN
            v_tltxcd:='6674';
            SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc
            FROM  TLTX WHERE TLTXCD=v_tltxcd;
            v_strNotes:= v_strDesc;


            SELECT systemnums.C_BATCH_PREFIXED
            || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;

            l_txmsg.brid := substr(rec.afacctno,1,4);

            l_txmsg.msgtype:='T';
            l_txmsg.local:='N';
            l_txmsg.tlid        := p_tlid;
            SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                     SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
              INTO l_txmsg.wsname, l_txmsg.ipaddress
            FROM DUAL;
            l_txmsg.off_line    := 'N';
            l_txmsg.deltd       := txnums.c_deltd_txnormal;
            l_txmsg.txstatus    := txstatusnums.c_txcompleted;
            l_txmsg.msgsts      := '0';
            l_txmsg.ovrsts      := '0';
            l_txmsg.batchname   := 'BANK';
            l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
            l_txmsg.tltxcd:=v_tltxcd;


            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;

            l_txmsg.txfields ('03').defname   := 'SECACCOUNT';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.AFACCTNO;

            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;

            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;

            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

            l_txmsg.txfields ('97').defname   := 'CAREBY';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE     := rec.CAREBY;

            l_txmsg.txfields ('93').defname   := 'BANKACCT';
            l_txmsg.txfields ('93').TYPE      := 'C';
            l_txmsg.txfields ('93').VALUE     := rec.BANKACCTNO;

            l_txmsg.txfields ('95').defname   := 'BANKNAME';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE     := rec.BANKNAME;

            l_txmsg.txfields ('11').defname   := 'BANKAVAIL';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := rec.BANKAVAIL;

            l_txmsg.txfields ('12').defname   := 'BANKHOLDED';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := rec.BANKHOLDED;

            l_txmsg.txfields ('13').defname   := 'AVLRELEASE';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := rec.AVLRELEASE;

            l_txmsg.txfields ('96').defname   := 'HOLDAMT';
            l_txmsg.txfields ('96').TYPE      := 'N';
            l_txmsg.txfields ('96').VALUE     := rec.HOLDAMT;

            l_txmsg.txfields ('10').defname   := 'AMOUNT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := v_dblUnholdBalance;

            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := v_strNotes;

            plog.debug(pkgctx,'Begin call 6674');
            BEGIN
                IF txpks_#6674.fn_AutoTxProcess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   BEGIN
                       plog.error(pkgctx,'Error when call 6674 , Error code : ' || p_err_code);
                       ROLLBACK;
                       plog.setendsection (pkgctx, 'UNHOLD_BF_CRB_ONLINE_SYNC');
                       RETURN;
                   END;
                END IF;
            END;
            plog.debug(pkgctx,'End call 6674 , Error code : ' || p_err_code);
        end if;
    end loop;

    p_err_code:=0;
    plog.setendsection (pkgctx, 'UNHOLD_BF_CRB_ONLINE_SYNC');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'UNHOLD_BF_CRB_ONLINE_SYNC');
      RAISE errnums.E_SYSTEM_ERROR;
END UNHOLD_BF_CRB_ONLINE_SYNC;

PROCEDURE fn_CreateAndGetBatchID(pv_txdate IN VARCHAR2, pv_BankCode IN VARCHAR2, pv_msgid IN VARCHAR2, pv_BathcID Out VARCHAR2, p_err_code out varchar2)
IS
    v_Result        VARCHAR2(50);
    v_msgid         VARCHAR2(10);
    v_BankCode      VARCHAR2(10);
    v_strSCID       VARCHAR2(10);
    v_strBATCHID    VARCHAR2(50);
    v_txdate        DATE;
    v_SQL           VARCHAR2(4000);
    v_Inc           Number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_CreateAndGetBatchID');
    p_err_code  := systemnums.C_SUCCESS;
    v_msgid     := pv_msgid;
    v_BankCode  := pv_BankCode;
    v_txdate    := to_date(pv_txdate,'dd/MM/rrrr');

    --BatchID theo format
    -- 09300130913110406
    -- 09300 + yymmdd + MSGID + $$
    -- Trong do
            -- MSGID : 1100/1101/1102/1103/1104
            -- $$ : So tu tang

    SELECT USERIDKEY INTO  v_strSCID
    FROM CRBDEFBANK WHERE bankcode = v_BankCode;
    BEGIN
        SELECT NVL(MAX(BATCHID),' ') into v_strBATCHID
        FROM GWBATCHSEQOFFLINEINFO
        WHERE BANKCODE= v_BankCode
              AND DATECREATED=TO_DATE(v_txdate,'DD/MM/RRRR')
              AND STATUS='P'
              And msgid = v_strSCID;
    EXCEPTION
        WHEN OTHERS THEN
            v_strBATCHID := NULL;
    END;

    plog.error(pkgctx, 'fn_CreateAndGetBatchID.v_strBATCHID:=' || v_strBATCHID);
    IF LENGTH(v_strBATCHID) = 0 Or v_strBATCHID = NULL Or INSTR(v_strBATCHID, v_strSCID) = 0 THEN
        BEGIN
            SELECT NVL(MAX(SUBSTR(BATCHID, 16,2)),0) into v_Inc
            FROM GWBATCHSEQOFFLINEINFO
            WHERE BANKCODE= v_BankCode
                  AND DATECREATED=TO_DATE(v_txdate,'DD/MM/RRRR')
                  And msgid = v_strSCID;
        EXCEPTION
           WHEN OTHERS THEN
                v_Inc := 0;
        END;

        v_Inc := v_Inc + 1;

        plog.error(pkgctx, 'fn_CreateAndGetBatchID.v_Inc:=' || v_Inc);
        SELECT v_strSCID ||  TO_CHAR(v_txdate,'yymmdd') || v_msgid ||  LPAD(v_Inc,2,'0')
            INTO v_strBATCHID
        FROM DUAL;

        plog.error(pkgctx, 'fn_CreateAndGetBatchID.v_strBATCHID:=' || v_strBATCHID);

        INSERT INTO GWBATCHSEQOFFLINEINFO(BATCHID,DATECREATED,STATUS,BANKCODE, MSGID)
        VALUES(v_strBATCHID, TO_DATE(v_txdate,'DD/MM/RRRR'),'P',v_BankCode, v_msgid);
        COMMIT;
    END IF;

    pv_BathcID := v_strBATCHID;
    plog.setendsection (pkgctx, 'fn_CreateAndGetBatchID');
    RETURN ;
EXCEPTION
   WHEN OTHERS THEN
        p_err_code  := errnums.C_SYSTEM_ERROR;
        pv_BathcID := '';
        plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
        plog.setendsection (pkgctx, 'fn_CreateAndGetBatchID');
        RETURN ;
END fn_CreateAndGetBatchID;

BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_rmproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
