SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_toolparallel
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
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
    PROCEDURE sp_Tool_InitOneTime;
    PROCEDURE sp_Tool_Init_UpdateData;
    PROCEDURE sp_Tool_PlaceOrder;
    PROCEDURE sp_Tool_MatchOrder;
    PROCEDURE sp_Tool_ExternalTransfer;
    PROCEDURE sp_Tool_AdvancePayment;
    PROCEDURE sp_Tool_RightoffRegister;
    PROCEDURE sp_Tool_InternalTransfer;
    PROCEDURE sp_Hold_Balance (
       pv_acctno   IN   VARCHAR2,
       pv_amt      IN   NUMBER
    );
    PROCEDURE sp_UnHold_Balance (
       pv_acctno   IN   VARCHAR2,
       pv_amt      IN   NUMBER
    );
    PROCEDURE sp_Release_Balance(p_acctno varchar,p_amount number);
    PROCEDURE sp_Delete_Hold_Balance (
       p_txnum   IN   VARCHAR2,
       p_txdate      IN   date
    );
    PROCEDURE sp_Tool_InternalSecTransfer;
    PROCEDURE sp_Tool_T3Bank_Process;

    PROCEDURE sp_matching_order (
       order_number       IN   VARCHAR2,
       deal_volume        IN   NUMBER,
       deal_price         IN   NUMBER,
       confirm_number     IN   VARCHAR2
    );
    PROCEDURE sp_Tool_DepoPaid;
    PROCEDURE sp_cancel_normal_order (
   pv_orderid   IN   VARCHAR2,
   pv_qtty      IN   NUMBER
   );
   PROCEDURE sp_Tool_CashInterestReceive ;
   PROCEDURE   pr_LNAutoPayment ;

END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_toolparallel
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

-- initial LOG
PROCEDURE sp_Tool_InitOneTime
is
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_InitOneTime');
    --Backup du lieu Import vao Hist
    insert into par_orderbookcv_hist
    select * from par_orderbookcv;
    insert into par_iodbookcv_hist
    select * from par_iodbookcv;
    insert into par_extransfer_hist
    select * from par_extransfer;
    insert into par_inttransfer_hist
    select * from par_inttransfer;
    insert into par_advance_hist
    select * from par_advance ;
    insert into par_rightoff_hist
    select * from par_rightoff;
    insert into par_intsectransfer_hist
    select * from par_intsectransfer;
    insert into par_thanhtoant3_hist
    select * from par_thanhtoant3;
    insert into ss_phatvaymargin_hist
    select * from ss_phatvaymargin;
    insert into ss_phatvayt3_hist
    select * from ss_phatvayt3;
    --Xoa du lieu Import
    delete from par_orderbookcv;
    delete from par_iodbookcv;
    delete from par_extransfer;
    delete from par_inttransfer;
    delete from par_advance ;
    delete from par_rightoff;
    delete from par_intsectransfer;
    delete from par_thanhtoant3;
    delete from ss_phatvayt3;
    delete from ss_phatvaymargin;

    commit;
    plog.setendsection(pkgctx, 'sp_Tool_InitOneTime');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on sp_Tool_InitOneTime');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'sp_Tool_InitOneTime');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_InitOneTime;


PROCEDURE sp_Paid_DepoFee (
   pv_custodycd in varchar2,
   pv_acctno   IN   VARCHAR2,
   pv_amt      IN   NUMBER,
   PV_TODATE      IN VARCHAR2,
   PV_FRODATE     IN VARCHAR2 ,
   p_err_code       out varchar2,
   p_err_message    out varchar2
)
IS
   l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc     varchar2(1000);
      v_strEN_Desc  varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param   varchar2(300);
      l_MaxRow      NUMBER(20,0);
      v_strDay      varchar2(2);
      l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
      l_baldefovd apprules.field%TYPE;
      l_feeamt      number(20,4);
      l_isRate      number;
      v_currmonth   varchar2(6);
      v_nextmonth   varchar2(6);
      v_afacctno_temp   VARCHAR2(20);
      v_ftodate         VARCHAR2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'sp_Paid_DepoFee');
   SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1180';
     SELECT varvalue INTO v_strCURRDATE
     FROM sysvar
     WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

     SELECT varvalue INTO v_strNEXTDATE
     FROM sysvar
     WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';

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
    l_txmsg.batchname   := 'AUTO';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1180';
    plog.debug(pkgctx, 'Begin loop');

                       v_afacctno_temp:='0';


    if  pv_amt > 0 then
         SELECT systemnums.C_BATCH_PREFIXED
                                  || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                           INTO l_txmsg.txnum
                           FROM DUAL;
         l_txmsg.brid        := substr(pv_acctno,1,4);



         --Set cac field giao dich
         --03  ACCTNO      C
         l_txmsg.txfields ('03').defname   := 'ACCTNO';
         l_txmsg.txfields ('03').TYPE      := 'C';
         l_txmsg.txfields ('03').VALUE     := pv_acctno;
         --10  INTAMT      N
         l_txmsg.txfields ('10').defname   := 'FEEAMT';
         l_txmsg.txfields ('10').TYPE      := 'N';
         l_txmsg.txfields ('10').VALUE     := pv_amt;
            --06  TODATE      N
         l_txmsg.txfields ('06').defname   := 'TODATE';
         l_txmsg.txfields ('06').TYPE      := 'C';
         l_txmsg.txfields ('06').VALUE     := PV_TODATE;
            --07  FTODATE      N
         l_txmsg.txfields ('07').defname   := 'FTODATE';
         l_txmsg.txfields ('07').TYPE      := 'C';
         l_txmsg.txfields ('07').VALUE     := PV_FRODATE;
         --30    DESC        C
         l_txmsg.txfields ('30').defname   := 'DESC';
         l_txmsg.txfields ('30').TYPE      := 'C';
         l_txmsg.txfields ('30').VALUE     := v_strDesc || ' ' || PV_FRODATE;

         --90  CUSTNAME    C
         l_txmsg.txfields ('90').defname   := 'CUSTNAME';
         l_txmsg.txfields ('90').TYPE      := 'C';
         l_txmsg.txfields ('90').VALUE     := '';

         --88  CUSTODYCD   C
         l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
         l_txmsg.txfields ('88').TYPE      := 'C';
         l_txmsg.txfields ('88').VALUE     := pv_custodycd;

         BEGIN
             IF txpks_#1180.fn_batchtxprocess (l_txmsg,
                                              p_err_code,
                                              l_err_param
                ) <> systemnums.c_success
             THEN
                plog.error (pkgctx,
                                       'got error 1180: ' || p_err_code
                );
                p_err_message:=l_err_param;
                RETURN;
             END IF;
         END;


    end if;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_CIPayFeeDepositSeBo');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Paid_DepoFee'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Paid_DepoFee');
      RAISE errnums.E_SYSTEM_ERROR;

END sp_Paid_DepoFee;


PROCEDURE sp_Receive_Interest  (
   pv_acctno   IN   VARCHAR2,
   pv_amt      IN   NUMBER,
   p_err_code       out varchar2,
   p_err_message    out varchar2
)
IS
   l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      v_strDesc     varchar2(1000);
      v_strEN_Desc  varchar2(1000);
      v_blnVietnamese BOOLEAN;
      l_err_param   varchar2(300);
      l_MaxRow      NUMBER(20,0);
      v_strDay      varchar2(2);
      l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
      l_baldefovd apprules.field%TYPE;
      l_feeamt      number(20,4);
      l_isRate      number;
      v_currmonth   varchar2(6);
      v_nextmonth   varchar2(6);
      v_afacctno_temp   VARCHAR2(20);
      v_ftodate         VARCHAR2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'sp_Receive_Interest');
   SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1162';
     SELECT varvalue INTO v_strCURRDATE
     FROM sysvar
     WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

     SELECT varvalue INTO v_strNEXTDATE
     FROM sysvar
     WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';

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
    l_txmsg.batchname   := 'AUTO';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1162';
    plog.debug(pkgctx, 'Begin loop');

                       v_afacctno_temp:='0';


    if  pv_amt > 0 then
         SELECT systemnums.C_BATCH_PREFIXED
                                  || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                           INTO l_txmsg.txnum
                           FROM DUAL;
         l_txmsg.brid        := substr(pv_acctno,1,4);



         --03  ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := pv_acctno;
        --10  CRINTACR    N
        l_txmsg.txfields ('10').defname   := 'CRINTACR';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := pv_amt;
        --16  TASKCD      C
        l_txmsg.txfields ('16').defname   := 'TASKCD';
        l_txmsg.txfields ('16').TYPE      := 'C';
        l_txmsg.txfields ('16').VALUE     := '';
        --17  MICODE      C
        l_txmsg.txfields ('17').defname   := 'MICODE';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := '';
        --30  DESC        C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := v_strDesc;

        BEGIN
            IF txpks_#1162.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1162: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;


    end if;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'sp_Receive_Interest');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Receive_Interest'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Receive_Interest');
      RAISE errnums.E_SYSTEM_ERROR;

END sp_Receive_Interest;

PROCEDURE sp_Tool_Init_UpdateData
is
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_Init_UpdateData');
    /*delete from fomast;
    delete from odmast where txdate =getcurrdate and orderid like '80%';
    delete from ood where orgorderid like '80%';
    delete from tllog where txnum like '80%';
    delete from crbtxreq where trfcode='HOLD';
    delete from stctradeallocation;
    delete from tllog where txnum like '80%';
    delete from tllogfld where txnum like '80%';
    delete from iodqueue;
    delete from iod;
    delete from stschd where txdate =getcurrdate and orgorderid like '80%';
    delete from odtran where acctno like '80%';
    commit;
    update par_iodbookcv set errcode = null, errmessage=null, execdt=null;
    update par_orderbookcv set errcode = null, errmessage=null, execdt=null;
    commit;*/
    plog.setendsection(pkgctx, 'sp_Tool_Init_UpdateData');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on sp_Tool_Init_UpdateData');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'sp_Tool_Init_UpdateData');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_Init_UpdateData;

PROCEDURE sp_Tool_AutoAllocateMoney (p_acctno varchar2, p_amount number)
is
    p_err_code varchar2(100);
    p_err_message varchar2(1000);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_AutoAdvanceNS');
    update afmast set advanceline = advanceline + p_amount where acctno =p_acctno;
    commit;
    plog.setendsection(pkgctx, 'sp_Tool_AutoAdvanceNS');
EXCEPTION
  WHEN OTHERS
   THEN
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_AutoAllocateMoney');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_AutoAllocateMoney;

PROCEDURE sp_Tool_AutoReleaseMoney (p_acctno varchar2, p_amount number)
is
    p_err_code varchar2(100);
    p_err_message varchar2(1000);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_AutoReleaseMoney');
    update afmast set advanceline = advanceline - p_amount where acctno =p_acctno;
    commit;
    plog.setendsection(pkgctx, 'sp_Tool_AutoReleaseMoney');
EXCEPTION
  WHEN OTHERS
   THEN
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_AutoReleaseMoney');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_AutoReleaseMoney;

PROCEDURE sp_Hold_Balance (
   pv_acctno   IN   VARCHAR2,
   pv_amt      IN   NUMBER
)
IS
   v_tltxcd           VARCHAR2 (30);
   v_txnum            VARCHAR2 (30);
   v_txdate           VARCHAR2 (30);
   v_tlid             VARCHAR2 (30);
   v_brid             VARCHAR2 (30);
   v_ipaddress        VARCHAR2 (30);
   v_wsname           VARCHAR2 (30);
   v_HoldAmount         number(20,0);
   v_desc               varchar2(200);
   v_txtime             VARCHAR2 (30);
BEGIN
    plog.setbeginsection (pkgctx, 'sp_Hold_Balance');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_tltxcd:='6690';
   v_HoldAmount := pv_amt;
   v_desc:='Hold tien dat lenh';
   --Kiem tra thoa man dieu kien huy

      SELECT varvalue INTO v_txdate FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

      SELECT    '8080' || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL, LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5, 6)
        INTO v_txnum FROM DUAL;

      SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS') INTO v_txtime FROM DUAL;

      --1 them vao trong tllog
      INSERT INTO tllog
                  (autoid, txnum,
                   txdate, txtime, brid,
                   tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
                   tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
                   offtime, off_line, deltd, brdate,
                   busdate, msgsts, ovrsts, ipaddress,
                   wsname, batchname, txdesc
                  )
           VALUES (seq_tllog.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txtime, v_brid,
                   v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
                   '', '', '1', pv_acctno, v_HoldAmount, '',
                   '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
                   v_wsname, 'DAY', v_desc
                  );

         UPDATE cimast
            SET balance = balance + v_HoldAmount,
                holdbalance = holdbalance + v_HoldAmount
          WHERE acctno = pv_acctno;


         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),pv_acctno,
            '0012',v_HoldAmount,NULL,'','N','',seq_CITRAN.NEXTVAL,v_tltxcd,TO_DATE (v_txdate, 'DD/MM/YYYY'),'' || '' || '');
         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),pv_acctno,
            '0052',v_HoldAmount,NULL,'','N','',seq_CITRAN.NEXTVAL,v_tltxcd,TO_DATE (v_txdate, 'DD/MM/YYYY'),'' || '' || '');


   plog.setendsection (pkgctx, 'sp_Hold_Balance');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Hold_Balance'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Hold_Balance');
      RAISE errnums.E_SYSTEM_ERROR;

END sp_Hold_Balance;



PROCEDURE sp_Delete_Hold_Balance (
   p_txnum   IN   VARCHAR2,
   p_txdate      IN   date
)
IS
   v_acctno varchar2(20);
   v_HoldAmount number;
BEGIN
    plog.setbeginsection (pkgctx, 'sp_Delete_Hold_Balance');
    if p_txdate = getcurrdate then
        select msgacct, msgamt into v_acctno,v_HoldAmount from tllog where  txnum= p_txnum and txdate = p_txdate and tltxcd ='6690';
        update tllog set deltd ='Y' where txnum= p_txnum and txdate = p_txdate;
        update CITRAN set deltd ='Y' where txnum= p_txnum and txdate = p_txdate;
        UPDATE cimast
            SET balance = balance - v_HoldAmount,
                holdbalance = holdbalance - v_HoldAmount
          WHERE acctno = v_acctno;
    else
        select msgacct, msgamt into v_acctno,v_HoldAmount from tllogall where  txnum= p_txnum and txdate = p_txdate and tltxcd ='6690';
        update tllogall set deltd ='Y' where txnum= p_txnum and txdate = p_txdate;
        update CITRANA set deltd ='Y' where txnum= p_txnum and txdate = p_txdate;
        update CITRAN_GEN set deltd ='Y' where txnum= p_txnum and txdate = p_txdate;
        UPDATE cimast
            SET balance = balance - v_HoldAmount,
                holdbalance = holdbalance - v_HoldAmount
          WHERE acctno = v_acctno;
    end if;
    plog.setendsection (pkgctx, 'sp_Delete_Hold_Balance');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Delete_Hold_Balance'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Delete_Hold_Balance');
      RAISE errnums.E_SYSTEM_ERROR;
END sp_Delete_Hold_Balance;


PROCEDURE sp_Release_Balance(p_acctno varchar,p_amount number)
  IS

    l_txmsg tx.msg_rectype;
    l_CURRDATE varchar2(20);
    l_err_param varchar2(300);
    l_begindate varchar2(10);
    l_trfamt number(20,0);
    l_maxtrfamt number;
    p_err_code  varchar2(100);


  BEGIN
    plog.setbeginsection(pkgctx, 'sp_Release_Balance');
    /*SELECT VARVALUE INTO l_begindate
    FROM SYSVAR WHERE VARNAME='SYSTEMSTARTDATE';*/

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
            least(getbaldefovd(af.acctno)+ CEIL(CI.CIDEPOFEEACR), --Ngay 17/03/2017 NamTv bo phi luu ky cong don ra cong thuc chuyen tien ve tk ngan hang,
                       ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt
                       - ramt - ci.depofeeamt- nvl(trf.trfbuy_t3,0)) trfamt
       from cimast ci, afmast af ,cfmast cf,crbdefacct cra,crbdefbank crb,
       (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance group by afacctno) adv,
       (select * from vw_gettrfbuyamt_byDay where afacctno = p_acctno) trf
       where ci.acctno = af.acctno and af.custid= cf.custid
       and af.corebank ='N' and af.alternateacct='Y'
       and af.bankname=cra.refbank and cra.trfcode='TRFSUBTRER'
       and af.bankname=crb.bankcode
       and ci.acctno = adv.afacctno(+)
       and af.acctno = trf.afacctno(+)
       and af.acctno = p_acctno

    )
    loop -- rec
        BEGIN
            plog.error(pkgctx, 'Loop for account sp_Release_Balance: ' || rec.afacctno);
            l_trfamt := p_amount;
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
                l_txmsg.txfields ('02').defname   := 'CATXNUM';
                l_txmsg.txfields ('02').TYPE      := 'C';
                l_txmsg.txfields ('02').VALUE     := rec.afacctno;

                --30   C   DESC
                l_txmsg.txfields ('30').defname   := 'DESC';
                l_txmsg.txfields ('30').TYPE      := 'C';
                l_txmsg.txfields ('30').VALUE     := utf8nums.c_const_TLTX_TXDESC_6669_Inday;

                BEGIN
                    IF txpks_#6669.fn_batchtxprocess (l_txmsg,
                                                     p_err_code,
                                                     l_err_param
                       ) <> systemnums.c_success
                    THEN
                       plog.debug (pkgctx,
                                   'got error 6668: ' || p_err_code
                       );
                       plog.error (pkgctx,
                                   'got error 6668: p_err_code' || p_err_code
                       );
                       ROLLBACK;
                       RETURN;
                    END IF;
                END;
                --Neu giao dich chuyen tien trong ngay thi gen bang ke tu dong ngay.
                --Trong batch thi thuc hien gom chung vaof 1 bang ke
                /*if fopks_api.fn_is_ho_active then
                    cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(l_txmsg.txdate, 'dd/mm/rrrr'), l_txmsg.txnum,p_err_code);
                end if;*/


            end if;
        END;
    end loop; -- rec

    p_err_code:=0;
    plog.setendsection(pkgctx, 'sp_Release_Balance');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'sp_Release_Balance');
      RAISE errnums.E_SYSTEM_ERROR;
  END sp_Release_Balance;


PROCEDURE sp_UnHold_Balance (
   pv_acctno   IN   VARCHAR2,
   pv_amt      IN   NUMBER
)
IS
   v_tltxcd           VARCHAR2 (30);
   v_txnum            VARCHAR2 (30);
   v_txdate           VARCHAR2 (30);
   v_tlid             VARCHAR2 (30);
   v_brid             VARCHAR2 (30);
   v_ipaddress        VARCHAR2 (30);
   v_wsname           VARCHAR2 (30);
   v_HoldAmount         number(20,0);
   v_desc               varchar2(200);
   v_txtime             VARCHAR2 (30);
BEGIN
    plog.setbeginsection (pkgctx, 'sp_UnHold_Balance');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_tltxcd:='6691';
   v_HoldAmount := pv_amt;
   v_desc:='Hold tien dat lenh';
   --Kiem tra thoa man dieu kien huy

      SELECT varvalue INTO v_txdate FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

      SELECT    '8080' || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL, LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5, 6)
        INTO v_txnum FROM DUAL;

      SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS') INTO v_txtime FROM DUAL;

      --1 them vao trong tllog
      INSERT INTO tllog
                  (autoid, txnum,
                   txdate, txtime, brid,
                   tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
                   tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
                   offtime, off_line, deltd, brdate,
                   busdate, msgsts, ovrsts, ipaddress,
                   wsname, batchname, txdesc
                  )
           VALUES (seq_tllog.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txtime, v_brid,
                   v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
                   '', '', '1', pv_acctno, v_HoldAmount, '',
                   '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
                   v_wsname, 'DAY', v_desc
                  );



         UPDATE cimast
            SET balance = balance - v_HoldAmount,
                holdbalance = holdbalance - v_HoldAmount
          WHERE acctno = pv_acctno;


         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),pv_acctno,
            '0011',v_HoldAmount,NULL,'','N','',seq_CITRAN.NEXTVAL,v_tltxcd,TO_DATE (v_txdate, 'DD/MM/YYYY'),'' || '' || '');
         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),pv_acctno,
            '0051',v_HoldAmount,NULL,'','N','',seq_CITRAN.NEXTVAL,v_tltxcd,TO_DATE (v_txdate, 'DD/MM/YYYY'),'' || '' || '');


   plog.setendsection (pkgctx, 'sp_UnHold_Balance');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_UnHold_Balance'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_UnHold_Balance');
      RAISE errnums.E_SYSTEM_ERROR;

END sp_UnHold_Balance;



PROCEDURE sp_UnHold_AllBalance (
   pv_acctno   IN   VARCHAR2
)
IS
  l_UnholdBalance number;
BEGIN
    plog.setbeginsection (pkgctx, 'sp_UnHold_AllBalance');
    for rec in (
                SELECT          least(getbaldefovd(af.acctno),
                               ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt -
                               ci.dfintdebtamt - ramt - ci.depofeeamt- nvl(trf.trfbuy_t3,0)) AVLRELEASE,
                    CI.HOLDBALANCE HOLDAMT
                    FROM AFMAST AF,CFMAST CF,CIMAST CI,CRBDEFBANK CRB,
                    (select * from vw_gettrfbuyamt_byDay where afacctno = pv_acctno) trf
                    WHERE AF.CUSTID=CF.CUSTID AND CI.AFACCTNO=AF.ACCTNO
                    AND AF.BANKNAME=CRB.BANKCODE AND AF.ACCTNO=pv_acctno
                    and (af.corebank ='Y' or af.alternateacct='Y')
                    and af.acctno = trf.afacctno(+)
    )
    loop
        l_UnholdBalance:= least(rec.HOLDAMT, rec.AVLRELEASE);
        if l_UnholdBalance>0 then
            sp_UnHold_Balance(pv_acctno,l_UnholdBalance );
        end if;
    end loop;

   plog.setendsection (pkgctx, 'sp_UnHold_AllBalance');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_UnHold_AllBalance'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_UnHold_AllBalance');
      RAISE errnums.E_SYSTEM_ERROR;

END sp_UnHold_AllBalance;


PROCEDURE sp_Tool_AutoAllocateSecurities (p_acctno varchar2, p_symbol varchar2, p_qtty number)
is
    p_err_code varchar2(100);
    p_err_message varchar2(1000);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_AutoAllocateSecurities');
    for rec in (
        select cf.custodycd, af.acctno, '0001' userid, 'Cap han muc chung khoan tai khoan luu ky ben ngoai' description
        from cfmast cf, afmast af where cf.custid = af.custid and af.acctno =p_acctno
        and cf.custatcom ='N' --Chi cap chung khoan voi tai khoan luu ky ben ngoai
    )
    loop
        fopks_api.pr_AllocateStock3rdAccount
        (   rec.custodycd,
            rec.acctno,
            p_symbol,
            p_qtty,
            rec.userid,
            rec.description,
            p_err_code,
            p_err_message
        );
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_AutoAllocateSecurities');
EXCEPTION
  WHEN OTHERS
   THEN
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_AutoAllocateSecurities');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_AutoAllocateSecurities;




PROCEDURE sp_matching_order (
   order_number       IN   VARCHAR2,
   deal_volume        IN   NUMBER,
   deal_price         IN   NUMBER,
   confirm_number     IN   VARCHAR2
)
IS
   v_tltxcd             VARCHAR2 (30);
   v_txnum              VARCHAR2 (30);
   v_txdate             VARCHAR2 (30);
   v_tlid               VARCHAR2 (30);
   v_brid               VARCHAR2 (30);
   v_ipaddress          VARCHAR2 (30);
   v_wsname             VARCHAR2 (30);
   v_txtime             VARCHAR2 (30);
   mv_strorgorderid     VARCHAR2 (30);
   mv_strcodeid         VARCHAR2 (30);
   mv_strsymbol         VARCHAR2 (30);
   mv_strcustodycd      VARCHAR2 (30);
   mv_strbors           VARCHAR2 (30);
   mv_strnorp           VARCHAR2 (30);
   mv_straorn           VARCHAR2 (30);
   mv_strafacctno       VARCHAR2 (30);
   mv_strciacctno       VARCHAR2 (30);
   mv_strseacctno       VARCHAR2 (30);
   mv_reforderid        VARCHAR2 (30);
   mv_refcustcd         VARCHAR2 (30);
   mv_strclearcd        VARCHAR2 (30);
   mv_strexprice        NUMBER (10);
   mv_strexqtty         NUMBER (10);
   mv_strprice          NUMBER (10);
   mv_strqtty           NUMBER (10);
   mv_strremainqtty     NUMBER (10);
   mv_strclearday       NUMBER (10);
   mv_strsecuredratio   NUMBER (10,2);
   mv_strconfirm_no     VARCHAR2 (30);
   mv_strmatch_date     VARCHAR2 (30);
   mv_desc              VARCHAR2 (30);
   v_strduetype         VARCHAR (2);
   v_matched            NUMBER (10,2);
   v_ex                 EXCEPTION;
   v_err                VARCHAR2 (100);
   v_temp               NUMBER(10);
   v_refconfirmno       VARCHAR2 (30);
   v_order_number       VARCHAR2(30);
   mv_mtrfday                NUMBER(10);
   l_trfbuyext              number(10);
   mv_strtradeplace      VARCHAR2(3);
   v_ticksize           NUMBER(20,4);
   l_dblExecQtty        number(20,0);

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;


BEGIN
    plog.setbeginsection (pkgctx, 'sp_matching_order');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_tltxcd := '8804';

   mv_strtradeplace:='002';

   SELECT    '8080' || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                     LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,6)
     INTO v_txnum
     FROM DUAL;

   SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
     INTO v_txtime
     FROM DUAL;

   BEGIN
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
   EXCEPTION
      WHEN OTHERS
      THEN
         v_err := SUBSTR ('sysvar ' || SQLERRM, 1, 100);
         RAISE v_ex;
   END;
   mv_strorgorderid :=order_number;




    --TungNT modified - for T2 late send money
   BEGIN
      SELECT od.remainqtty, sb.codeid, sb.symbol, ood.custodycd,
             ood.bors, ood.norp, ood.aorn, od.afacctno,
             od.ciacctno, od.seacctno, '', '',
             od.clearcd, ood.price, ood.qtty, deal_price,
             deal_volume, od.clearday, od.bratio,
             confirm_number, v_txdate, '', typ.mtrfday,
             ss.tradeplace,
             od.execqtty
        INTO mv_strremainqtty, mv_strcodeid, mv_strsymbol, mv_strcustodycd,
             mv_strbors, mv_strnorp, mv_straorn, mv_strafacctno,
             mv_strciacctno, mv_strseacctno, mv_reforderid, mv_refcustcd,
             mv_strclearcd, mv_strexprice, mv_strexqtty, mv_strprice,
             mv_strqtty, mv_strclearday, mv_strsecuredratio,
             mv_strconfirm_no, mv_strmatch_date, mv_desc,mv_mtrfday,
             mv_strtradeplace,
             l_dblExecQtty
        FROM odmast od, ood, securities_info sb,odtype typ,afmast af,sbsecurities ss
       WHERE od.orderid = ood.orgorderid and od.actype = typ.actype
         AND od.afacctno=af.acctno and od.codeid=ss.codeid
         AND od.codeid = sb.codeid
         AND orderid = mv_strorgorderid;
   END;



  /* IF ( mv_strbors ='B' and mv_strexprice < deal_price) or
     ( mv_strbors ='S' and mv_strexprice > deal_price) Then
     Return;
   End if;*/


   --Day vao stctradebook, stctradeallocation de khong bi khop lai:
   v_refconfirmno :='VN'||mv_strbors||mv_strconfirm_no;


   INSERT INTO stctradeallocation
            (txdate, txnum, refconfirmnumber, orderid, bors, volume,
             price, deltd
            )
     VALUES (to_date(v_txdate,'dd/mm/yyyy'), v_txnum, v_refconfirmno, mv_strorgorderid, mv_strbors, mv_strqtty,
             mv_strprice, 'N'
            );


   mv_desc := 'Matching order';

   IF mv_strremainqtty >= mv_strqtty
   THEN
      --thuc hien khop voi ket qua tra ve

      --1 them vao trong tllog
      INSERT INTO tllog
                  (autoid, txnum,
                   txdate, txtime, brid,
                   tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
                   tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
                   offtime, off_line, deltd, brdate,
                   busdate, msgsts, ovrsts, ipaddress,
                   wsname, batchname, txdesc
                  )
           VALUES (seq_tllog.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txtime, v_brid,
                   v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
                   '', '', '1', mv_strorgorderid, mv_strqtty, '',
                   '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
                   v_wsname, 'DAY', mv_desc
                  );

      --tHEM VAO TRONG TLLOGFLD
      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue,
                   cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '03', 0,
                   mv_strorgorderid, NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '80', 0, mv_strcodeid,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '81', 0, mv_strsymbol,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue,
                   cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '82', 0,
                   mv_strcustodycd, NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '04', 0, mv_strafacctno,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '11', mv_strqtty, NULL,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '10', mv_strprice, NULL,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '30', 0, mv_desc, NULL
                  );
      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '05', 0, mv_strafacctno, NULL
                  );

      IF mv_strbors = 'B' THEN
          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '86', mv_strprice*mv_strqtty, NULL, NULL
                  );

          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '87', mv_strqtty, NULL, NULL
                  );
      ELSE
          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '86', 0, NULL, NULL
                  );

          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '87', 0, NULL, NULL
                  );
      END IF;


        INSERT INTO iodqueue (TXDATE,BORS,CONFIRM_NO,SYMBOL)
        VALUES(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strbors,mv_strconfirm_no,mv_strsymbol);


      --3 THEM VAO TRONG IOD
      INSERT INTO iod
                  (orgorderid, codeid, symbol,
                   custodycd, bors, norp,
                   txdate, txnum, aorn,
                   price, qtty, exorderid, refcustcd,
                   matchprice, matchqtty, confirm_no,txtime
                  )
           VALUES (mv_strorgorderid, mv_strcodeid, mv_strsymbol,
                   mv_strcustodycd, mv_strbors, mv_strnorp,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txnum, mv_straorn,
                   mv_strexprice, mv_strexqtty, mv_reforderid, mv_refcustcd,
                   mv_strprice, mv_strqtty, mv_strconfirm_no,to_char(sysdate,'hh24:mi:ss')
                  );

    ---- GHI NHAT VAO BANG TINH GIA VON CUA TUNG LAN KHOP.
    SECMAST_GENERATE(v_txnum, v_txdate, v_txdate, mv_strafacctno, mv_strcodeid, 'T', (CASE WHEN mv_strbors = 'B' THEN 'I' ELSE 'O' END), null, mv_strorgorderid, mv_strqtty, mv_strprice, 'Y');



            -- if instr('/NS/MS/SS/', :newval.exectype) > 0 then
            if mv_strbors = 'S' then
                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                -- Begin Danh sau tai san LINHLNB
                INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG,QTTY)
                VALUES( mv_strafacctno,mv_strcodeid ,mv_strprice * mv_strqtty ,v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),NULL,systimestamp,mv_strorgorderid,'M',mv_strqtty);
                -- End Danh dau tai san LINHLNB
            end if;

      --4 CAP NHAT STSCHD
      SELECT COUNT (*)
        INTO v_matched
        FROM stschd
       WHERE orgorderid = mv_strorgorderid AND deltd <> 'Y';
   BEGIN
      IF mv_strbors = 'B'
      THEN                                                          --Lenh mua
         --Tao lich thanh toan chung khoan
         v_strduetype := 'RS';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
             WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
         ELSE
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice,
                         CLEARDATE
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strseacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0,
                         getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,'000',mv_strclearday)
                        );
         END IF;

         --Tao lich thanh toan tien
        select case when mrt.mrtype <> 'N' and aft.istrfbuy <> 'N' then trfbuyext
            else 0 end into l_trfbuyext
        from afmast af, aftype aft, mrtype mrt
        where af.actype = aft.actype and aft.mrtype = mrt.actype and af.acctno = mv_strafacctno;

         v_strduetype := 'SM';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
             WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
         ELSE
            --TungNT modified , for late T2 send money
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice, cleardate
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strafacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), least(mv_mtrfday,l_trfbuyext),
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,'000',least(mv_mtrfday,l_trfbuyext))
                        );
            --Emd
         END IF;

      ELSE                                                          --Lenh ban
         --Tao lich thanh toan chung khoan
         v_strduetype := 'SS';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
             WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
         ELSE
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice, cleardate
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strseacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), 0,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,'000',0)
                        );
         END IF;

         --Tao lich thanh toan tien
         v_strduetype := 'RM';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
             WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
         ELSE
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice, cleardate
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strafacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,'000',mv_strclearday)
                        );
         END IF;
      END IF;
  EXCEPTION
      WHEN OTHERS
      THEN
         v_err :=
            SUBSTR (   'Loi insert vao stschd '
                    || mv_strorgorderid || ' DueType '||v_strduetype
                    || SQLERRM,
                    1,
                    100
                   );
         RAISE v_ex;
   END;

      --CAP NHAT TRAN VA MAST
            --BUY
      UPDATE OOD
      SET OODSTATUS = 'S', TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS')
      WHERE ORGORDERID = mv_strorgorderid AND OODSTATUS <> 'S';


       UPDATE odmast
         SET orstatus = '4',
             PORSTATUS = PORSTATUS||'4',
             execqtty = execqtty + mv_strqtty ,
             remainqtty = remainqtty - mv_strqtty,
             execamt = execamt + mv_strqtty * mv_strprice,
             matchamt = matchamt + mv_strqtty * mv_strprice
       WHERE orderid = mv_strorgorderid;
       UPDATE odmast
         SET HOSESESSION = (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
       WHERE orderid = mv_strorgorderid And HOSESESSION ='N';


      --Neu khop het va co lenh huy cua lenh da khop thi cap nhat thanh refuse
      IF mv_strremainqtty = mv_strqtty THEN
          UPDATE odmast
             SET ORSTATUS = '0'
           WHERE REFORDERID = mv_strorgorderid;
  Update ood set oodstatus ='N' where oodstatus ='B' and REFORDERID = mv_strorgorderid
           and orgorderid in (select orderid from odmast where orstatus ='0');
        Else
        -- hoac lenh sua ve khoi luong <= khoi luong khop cung refuse
          UPDATE odmast
             SET ORSTATUS = '0'
           WHERE exectype in ('AS','AB') And orderqtty <= l_dblExecQtty + mv_strqtty
           And REFORDERID = mv_strorgorderid;

           Update ood set oodstatus ='N' where oodstatus ='B' and REFORDERID = mv_strorgorderid
           and orgorderid in (select orderid from odmast where orstatus ='0');
        END IF;

      --Cap nhat tinh gia von

      IF mv_strbors = 'B' THEN
          UPDATE semast SET dcramt = dcramt + mv_strqtty*mv_strprice, dcrqtty = dcrqtty+mv_strqtty WHERE acctno = mv_strseacctno;
      END IF;

      INSERT INTO odtran
                  (txnum, txdate,
                   acctno, txcd, namt, camt, acctref, deltd,
                   REF, autoid
                  )
           VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   mv_strorgorderid, '0013', mv_strqtty, NULL, NULL, 'N',
                   NULL, seq_odtran.NEXTVAL
                  );

      INSERT INTO odtran
                  (txnum, txdate,
                   acctno, txcd, namt, camt, acctref, deltd,
                   REF, autoid
                  )
           VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   mv_strorgorderid, '0011', mv_strqtty, NULL, NULL, 'N',
                   NULL, seq_odtran.NEXTVAL
                  );

      INSERT INTO odtran
                  (txnum, txdate,
                   acctno, txcd, namt, camt,
                   acctref, deltd, REF, autoid
                  )
           VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   mv_strorgorderid, '0028', mv_strqtty * mv_strprice, NULL,
                   NULL, 'N', NULL, seq_odtran.NEXTVAL
                  );

      INSERT INTO odtran
                  (txnum, txdate,
                   acctno, txcd, namt, camt,
                   acctref, deltd, REF, autoid
                  )
           VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   mv_strorgorderid, '0034', mv_strqtty * mv_strprice, NULL,
                   NULL, 'N', NULL, seq_odtran.NEXTVAL
                  );

   END IF;
   --Cap nhat cho GTC
   OPEN C_ODMAST(MV_STRORGORDERID);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
         UPDATE FOMAST SET REMAINQTTY= REMAINQTTY - MV_STRQTTY
                            ,EXECQTTY= EXECQTTY + MV_STRQTTY
                            ,EXECAMT=  EXECAMT + MV_STRPRICE * MV_STRQTTY
          --WHERE ORGACCTNO= MV_STRORGORDERID;
          WHERE ACCTNO= VC_ODMAST.FOACCTNO;
    END IF;
   CLOSE C_ODMAST;

    plog.setendsection (pkgctx, 'sp_matching_order');
EXCEPTION when others then
    plog.error (pkgctx,'got error on sp_matching_order' || dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace || 'Order:' || mv_strorgorderid);
      plog.setendsection (pkgctx, 'sp_matching_order');
      RAISE errnums.E_SYSTEM_ERROR;
 END sp_matching_order;


 PROCEDURE sp_cancel_normal_order (
   pv_orderid   IN   VARCHAR2,
   pv_qtty      IN   NUMBER
)
IS
   v_edstatus         VARCHAR2 (30);
   v_tltxcd           VARCHAR2 (30);
   v_txnum            VARCHAR2 (30);
   v_txdate           VARCHAR2 (30);
   v_tlid             VARCHAR2 (30);
   v_brid             VARCHAR2 (30);
   v_ipaddress        VARCHAR2 (30);
   v_wsname           VARCHAR2 (30);
   v_symbol           VARCHAR2 (30);
   v_afaccount        VARCHAR2 (30);
   v_seacctno         VARCHAR2 (30);
   v_price            NUMBER (10,2);
   v_quantity         NUMBER (10,2);
   v_bratio           NUMBER (10,2);
   v_oldbratio        NUMBER (10,2);
   v_cancelqtty       NUMBER (10,2);
   v_amendmentqtty    NUMBER (10,2);
   v_amendmentprice   NUMBER (10,2);
   v_matchedqtty      NUMBER (10,2);
   v_advancedamount   NUMBER (10,2);
   v_execqtty         NUMBER (10,2);
   v_trExectype       VARCHAR2 (30);
   v_reforderid       VARCHAR2 (30);
   v_tradeunit        NUMBER (10,2);
   v_desc             VARCHAR2 (300);
   v_bors             VARCHAR2 (30);
   v_txtime           VARCHAR2 (30);
   v_Count_lenhhuy    Number(2);
   v_OrderQtty_Cur    Number(10);
   v_RemainQtty_Cur   Number(10);
   v_ExecQtty_Cur     Number(10);
   v_CancelQtty_Cur   Number(10);
   v_Orstatus_Cur     VARCHAR2(10);
   v_err              VARCHAR2(300);
   v_strCodeid        VARCHAR2(10);
   v_ex                 EXCEPTION;

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;


BEGIN
    plog.setbeginsection (pkgctx, 'sp_cancel_normal_order');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_cancelqtty := pv_qtty;
   --Kiem tra thoa man dieu kien huy
   BEGIN



    SELECT ORDERQTTY,REMAINQTTY,EXECQTTY,CANCELQTTY,ORSTATUS,Exectype
    INTO V_ORDERQTTY_CUR,V_REMAINQTTY_CUR,V_EXECQTTY_CUR,V_CANCELQTTY_CUR,V_ORSTATUS_CUR,v_trExectype
    FROM ODMAST WHERE ORDERID =PV_ORDERID;
   EXCEPTION WHEN OTHERS THEN
    v_err := SUBSTR ('WHERE ORDERID = ' || SQLERRM ||'  '||PV_ORDERID, 1, 100);
    raise v_ex;
   END;
   IF V_REMAINQTTY_CUR - V_CANCELQTTY < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR
                 OR V_CANCELQTTY = 0
   THEN
    Return;
   END IF;



            INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' confirm_cancel_normal_order ', 'here 1'
                  );

      COMMIT;



   SELECT (CASE
                      WHEN EXECTYPE LIKE '%B'
                         THEN '8808'
                      ELSE '8807'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.orderqtty - pv_qtty,
                  od.reforderid, sb.tradeunit, od.edstatus
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND orderid = pv_orderid;


   v_advancedamount := 0;


   SELECT bratio
     INTO v_oldbratio
     FROM odmast
    WHERE orderid = pv_orderid;

      --NEU CHAU BI HUY THI KHI NHAN DUOC MESSAGE TRA VE SE THUC HIEN HUY LENH
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

      SELECT    '8080'
             || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                        LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                        6
                       )
        INTO v_txnum
        FROM DUAL;

      SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
        INTO v_txtime
        FROM DUAL;

      --1 them vao trong tllog
      INSERT INTO tllog
                  (autoid, txnum,
                   txdate, txtime, brid,
                   tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
                   tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
                   offtime, off_line, deltd, brdate,
                   busdate, msgsts, ovrsts, ipaddress,
                   wsname, batchname, txdesc
                  )
           VALUES (seq_tllog.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txtime, v_brid,
                   v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
                   '', '', '1', pv_orderid, v_quantity, '',
                   '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
                   v_wsname, 'DAY', v_desc
                  );
      --them vao tllogfld
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'07',0,v_symbol,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'03',0,v_afaccount,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'04',0,pv_orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'06',0,v_seacctno,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'08',0,pv_orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'14',v_cancelqtty,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'11',v_price,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'12',v_quantity,NULL,NULL);



      --2 THEM VAO TRONG TLLOGFLD
      Update ODMAST set ORSTATUS ='5' , cancelstatus ='C' --Huy do san tra ve
        where Orderqtty =Remainqtty And Orderqtty=v_cancelqtty
        and ORDERID =pv_orderid;
      --3 CAP NHAT TRAN VA MAST
      IF v_tltxcd = '8890' OR v_tltxcd = '8808'
      THEN
         --BUY
         UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty
          WHERE orderid = pv_orderid;

        if v_tltxcd = '8890' OR v_tltxcd='8808' then
                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                -- Begin Danh sau tai san LINHLNB


                INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG,QTTY)
                VALUES( v_afaccount,v_strCodeid ,v_cancelqtty * v_price ,v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),NULL,systimestamp,pv_orderid,'C',v_cancelqtty);
                -- End Danh dau tai san LINHLNB
          end if ;



         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0014', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0011', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );


      ELSE                                                   --v_tltxcd='8891' , '8807'
         --SELL
         UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty
          WHERE orderid = pv_orderid;


         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0014', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0011', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

      END IF;

 --Cap nhat cho GTC
   OPEN C_ODMAST(pv_orderid);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
         UPDATE FOMAST SET   REMAINQTTY= REMAINQTTY - v_cancelqtty
                            ,cancelqtty= cancelqtty + v_cancelqtty
          --WHERE ORGACCTNO= pv_orderid;
          WHERE ACCTNO= VC_ODMAST.FOACCTNO;
    END IF;
   CLOSE C_ODMAST;


   plog.setendsection (pkgctx, 'sp_cancel_normal_order');
EXCEPTION
   WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_cancel_normal_order'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_cancel_normal_order');
      RAISE errnums.E_SYSTEM_ERROR;

END sp_cancel_normal_order;

PROCEDURE sp_Tool_MatchOrder
is
    --i number;
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_MatchOrder');
    --i:=0;
    for rec in (
        select orderseq, quantity,price*1000 price , od.orderid, io.confirmnumber
        from par_iodbookcv  io, odmast od , sbsecurities sb
        where io.orderseq = od.custid and od.codeid = sb.codeid
        and sb.symbol= io.symbol
        and (confirmnumber,io.exectype) not in (select confirm_no,'N' || bors from iod)
        -- and orderseq=4058
    )
    loop
        --i:=i+1;
        sp_matching_order(rec.orderid, rec.quantity,rec.price,rec.confirmnumber);
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_MatchOrder');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_MatchOrder'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_MatchOrder');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_MatchOrder;

PROCEDURE sp_Tool_ExternalTransfer
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
  l_cidepofeeacr number(20,4);
  l_depofeeamt number(20,4);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_ExternalTransfer');
    for rec in (
        SELECT
           mst.TRANNO,mst.TXDATE,mst.CUSTODYCD,mst.ACCOUNTTYPE,mst.BANKID,mst.BENEFBANK,
           mst.BENEFACCT,mst.BENEFCUSTNAME,mst.BENEFLICENCE,
           mst.AMOUNT,mst.FEEAMT,mst.VATAMT,mst.IOROFEE,mst.DESCRIPTION, AF.ACCTNO AFACCTNO
        FROM  par_extransfer mst,AFMAST AF,CFMAST CF, aftype aft, mrtype mrt
        WHERE 0=0  AND TO_DATE(mst.TXDATE,'DD/MM/YYYY')= getcurrdate
        AND mst.CUSTODYCD = CF.CUSTODYCD
        AND CF.CUSTID = AF.CUSTID
        and af.actype = aft.actype and aft.mrtype = mrt.actype
        --and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.ACCOUNTTYPE
        and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.mnemonic ='T3' then 'T' else 'M' end) end ) = mst.ACCOUNTTYPE
        and (mst.errcode is null or mst.errcode <> '0')
        ---and TRANNO='PZT02044129'
        --and TRANNO='8637'
        ORDER BY TRANNO
    )
    loop
        plog.error (pkgctx, 'acctno:' || rec.AFACCTNO || ',amount:' || rec.amount);
        plog.error (pkgctx, 'TRANNO:' || rec.TRANNO);
        select cidepofeeacr, depofeeamt  into l_cidepofeeacr, l_depofeeamt
        from cimast where acctno = rec.AFACCTNO;
        update cimast set cidepofeeacr = 0, depofeeamt = 0 where acctno = rec.AFACCTNO;
        COMMIT;
        BEgin
           fopks_api.pr_ExternalTransfer(rec.AFACCTNO,
                            rec.BANKID,
                            rec.BENEFBANK,
                            rec.BENEFACCT,
                            rec.BENEFCUSTNAME,
                            rec.BENEFLICENCE,
                            rec.AMOUNT,
                            rec.FEEAMT,
                            rec.VATAMT,
                            rec.IOROFEE,
                            rec.DESCRIPTION,
                            p_err_code,
                            p_err_message);
        EXCEPTION WHEN OTHERS THEN
                p_err_code:='-1';
                p_err_message:='lOI';
                update par_extransfer set ERRCODE='-1',
                                    ERRMESSAGE='lOI',
                                    EXECDT = SYSTIMESTAMP
                                where TRANNO= rec.TRANNO;
                plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
        End;

        update cimast set cidepofeeacr = cidepofeeacr+l_cidepofeeacr, depofeeamt = depofeeamt+l_depofeeamt
        where acctno = rec.AFACCTNO;

            if p_err_code <> '0' then
                update par_extransfer set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            else
                update par_extransfer set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            end if;
            commit;
        plog.error (pkgctx, 'acctno:' || rec.AFACCTNO || ',amount:' || rec.amount || ',p_err_code:' || p_err_code);

    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_ExternalTransfer');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_ExternalTransfer'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_ExternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_ExternalTransfer;


PROCEDURE sp_Tool_AdvancePayment
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_AdvancePayment');
    for rec in (
        SELECT
           mst.TRANNO,to_date(mst.TXDATE,'DD/MM/RRRR') txdate,mst.CUSTODYCD,mst.ACCOUNTTYPE,
           to_date(mst.DUEDATE,'DD/MM/RRRR')DUEDATE,mst.ADVAMT,mst.FEEAMT,
           'Ung truoc tien ban ngay hoan ung ' || mst.DUEDATE  DESCTIPTION,
           af.acctno afacctno, to_date(mst.DUEDATE,'DD/MM/RRRR') - to_date(mst.TXDATE,'DD/MM/RRRR') days,
           fn_get_nextdate(TO_DATE(mst.DUEDATE,'DD/MM/RRRR'), -3) matchdate
        FROM  par_advance mst,AFMAST AF,CFMAST CF, aftype aft, mrtype mrt
        WHERE 0=0  AND TO_DATE(mst.TXDATE,'DD/MM/YYYY')= getcurrdate
        AND mst.CUSTODYCD = CF.CUSTODYCD
        AND CF.CUSTID = AF.CUSTID AND AF.STATUS = 'A'
        and af.actype = aft.actype and aft.mrtype = mrt.actype
        --and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.ACCOUNTTYPE
        and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.mnemonic ='T3' then 'T' else 'MT' end) end ) = mst.ACCOUNTTYPE
        and (mst.errcode is null or mst.errcode <> '0')
--        AND AF.ACCTNO ='0001593266'
        --and TRANNO not in ('C827F436-66F2-4FD8-96F3-C725E6735EFF','2EFE575E-3445-405D-94F4-F3887E09C5B1','F6302055-8120-4F52-BD0A-79DAC15C7C07')
    )
    loop
           fopks_api.pr_AdvancePayment
                (   rec.afacctno,
                    rec.matchdate,
                    rec.duedate,
                    rec.ADVAMT + rec.FEEAMT,
                    rec.FEEAMT,
                    rec.days,
                    rec.ADVAMT + rec.FEEAMT,
                    rec.DESCTIPTION,
                    p_err_code,
                    p_err_message
                );
            if p_err_code <> '0' then
                update par_advance set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            else
                update par_advance set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            end if;
            commit;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_AdvancePayment');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_AdvancePayment'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_AdvancePayment');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_AdvancePayment;



PROCEDURE sp_Tool_RightoffRegister
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
  v_camastid varchar2(30);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_RightoffRegister');
    for rec in (
        SELECT
          mst.TRANNO,mst.TXDATE,mst.CUSTODYCD,mst.ACCOUNTTYPE,mst.QUANTITY,mst.SYMBOL,mst.REPORTDATE,
          'Dang ky quyen mua ma ' || symbol || ' ngay chot ' || REPORTDATE DESCRIPTION,
          af.acctno afacctno
        FROM  par_rightoff mst,AFMAST AF,CFMAST CF, aftype aft, mrtype mrt
        WHERE 0=0  AND TO_DATE(mst.TXDATE,'DD/MM/YYYY')= getcurrdate
        AND mst.CUSTODYCD = CF.CUSTODYCD
        AND CF.CUSTID = AF.CUSTID
        and af.actype = aft.actype and aft.mrtype = mrt.actype
        --and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.ACCOUNTTYPE
        and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.mnemonic ='T3' then 'T' else 'M' end) end ) = mst.ACCOUNTTYPE
        and (mst.errcode is null or mst.errcode <> '0')
        --and TRANNO='283399C3-8540-470C-9F46-41C28FE4F93E'
    )
    loop
        --Kiem tra xem co su kien nao thoa man
        begin
            select ca.camastid into v_camastid from camast ca, sbsecurities sb
            where   catype ='014' and REPORTDATE = to_date(rec.REPORTDATE,'DD/MM/RRRR')
            and ca.codeid = sb.codeid and sb.symbol = rec.SYMBOL;

           fopks_api.pr_RightoffRegiter2BO
                (v_camastid,
                rec.afacctno,
                rec.QUANTITY,
                rec.DESCRIPTION,
                p_err_code,
                p_err_message
                );
            if p_err_code <> '0' then
                update par_rightoff set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            else
                update par_rightoff set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            end if;
        exception when others then
            update par_rightoff set ERRCODE='-1',
                        ERRMESSAGE='Su kien quyen khong ton tai!',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
        end;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_RightoffRegister');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_RightoffRegister'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_RightoffRegister');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_RightoffRegister;

PROCEDURE pr_LNAutoPayment
  IS

    l_txmsg               tx.msg_rectype;
    l_CURRDATE varchar2(20);
    l_Desc varchar2(1000);
    l_EN_Desc varchar2(1000);
    l_OrgDesc varchar2(1000);
    l_EN_OrgDesc varchar2(1000);
    l_err_param varchar2(300);
    l_T0PRINDUE number(20,0);
    l_T0PRINNML number(20,0);
    l_T0PRINOVD number(20,0);
    l_AvlAmt    number(20,0);
    l_FEEOVD number(20,0);
    l_T0INTNMLOVD number(20,0);
    l_INTNMLOVD number(20,0);
    l_T0INTOVDACR number(20,0);
    l_INTOVDACR number(20,0);
    l_FEEDUE number(20,0);
    l_T0INTDUE number(20,0);
    l_INTDUE number(20,0);
    l_FEENML number(20,0);
    l_T0INTNMLACR number(20,0);
    l_INTNMLACR number(20,0);
    l_PRINOVD number(20,0);
    l_PRINDUE number(20,0);
    l_PRINNML number(20,0);
    l_FEEINTNMLOVD number(20,0);
    l_FEEINTNMLACR number(20,0);
    l_FEEINTOVDACR number(20,0);
    l_FEEINTDUE number(20,0);
    l_ADVPAYFEE number(20,0);

    l_maxdebtcf number(20,0);
    l_MinLoanAutoPayment number(20,0);
    p_err_code number(20,0);
    l_amt_goc number;
    l_amt_lai number;

  BEGIN

--UPDATE LAI THONG TIN
        FOR REC IN
        (SELECT  prl.*  , LNS.ACCTNO, LNS.autoid
        FROM LNMAST LN, CFMAST CF, afmast af, par_lnpaidalloc prl, LNSCHD LNS
        WHERE ln.trfacctno = af.acctno
        and cf.custid = af.custid
        and prl.custodycd = cf.custodycd
        and prl.accounttype ='MT'
        --and ln.acctno ='0101060115000037'
        AND LN.ACCTNO = LNS.ACCTNO
        AND LNS.rlsdate = PRL.RLSDATE )
        LOOP

        UPDATE par_lnpaidalloc SET lnschdid = REC.AUTOID, LNACCTNO = REC.ACCTNO
        WHERE RLSDATE= REC.RLSDATE AND CUSTODYCD = REC.CUSTODYCD ;

        END LOOP;
        COMMIT;

    SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='5567';
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
    l_txmsg.batchname   := 'LNPAYCV';
    l_txmsg.txdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(l_CURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='5567';

    select to_number(varvalue) into l_maxdebtcf from sysvar where varname = 'MAXDEBTCF';
    select to_number(varvalue) into l_MinLoanAutoPayment from sysvar where grname ='SYSTEM' and varname = 'LOANAUTOPAYAMT';

    plog.debug(pkgctx, 'Begin loop');


        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt_goc) amt_goc, sum(lp.amt_lai) amt_lai,

                sum(case when reftype = 'GP' then ls.intovd else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' and overduedate <> L_CURRDATE then ls.nml else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' and overduedate <> L_CURRDATE then ls.nml else 0 end) PRINNML

            from lnmast ln, par_lnpaidalloc lp, lnschd ls
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and instr(ls.reftype,'P') > 0
            and errcode is null
            group by ln.trfacctno, ln.acctno, ls.autoid
           order by ln.trfacctno
        )
        loop -- rec2
            l_ADVPAYFEE:=0;
            l_amt_goc :=  rec2.amt_goc;
            l_amt_lai :=  rec2.amt_lai;
            --So tien phai tra cho tung khoan
            -- Bao lanh
             --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_amt_goc > 0 Then
                l_T0PRINOVD := round(least(l_amt_goc, rec2.T0PRINOVD),0);
                l_amt_goc := l_amt_goc - l_T0PRINOVD;
            end if;
             --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_amt_goc > 0 Then
                l_T0PRINDUE := round(least(l_amt_goc, rec2.T0PRINDUE),0);
                l_amt_goc := l_amt_goc - l_T0PRINDUE;
            End If;

            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_amt_lai > 0 Then
                l_T0INTNMLOVD := round(least(l_amt_lai, rec2.T0INTNMLOVD),0);
                l_amt_lai := l_amt_lai - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_amt_lai > 0 Then
                l_T0INTOVDACR := round(least(l_amt_lai, rec2.T0INTOVDACR),0);
                l_amt_lai := l_amt_lai - l_T0INTOVDACR;
            End If;
           /* --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;*/
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_amt_lai > 0 Then
                 l_T0INTDUE := round(least(l_amt_lai, rec2.T0INTDUE),0);
                 l_amt_lai := l_amt_lai - l_T0INTDUE;
            End If;
           /* --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;*/
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_amt_lai > 0 Then
                l_T0INTNMLACR := round(least(l_amt_lai, rec2.T0INTNMLACR),0);
                l_amt_lai := l_amt_lai - l_T0INTNMLACR;
            End If;

             --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_amt_goc > 0 Then
                l_T0PRINNML := round(least(l_amt_goc, rec2.T0PRINNML),0);
                l_amt_goc := l_amt_goc - l_T0PRINNML;
            End If;
           /* --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;*/

            -- CL
            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_amt_goc > 0 Then
                l_PRINOVD := round(least(l_amt_goc, rec2.PRINOVD),0);
                l_amt_goc := l_amt_goc - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_amt_goc > 0 Then
               l_PRINDUE := round(least(l_amt_goc, rec2.PRINDUE),0);
               l_amt_goc := l_amt_goc - l_PRINDUE;
            End If;

            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_amt_lai > 0 Then
                l_FEEINTNMLOVD := round(least(l_amt_lai, rec2.FEEINTNMLOVD),0);
                l_amt_lai := l_amt_lai - l_FEEINTNMLOVD;
            End If;
            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_amt_lai > 0 Then
                l_INTNMLOVD := round(least(l_amt_lai, rec2.INTNMLOVD),0);
                l_amt_lai := l_amt_lai - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_amt_lai > 0 Then
                 l_INTOVDACR := round(least(l_amt_lai, rec2.INTOVDACR),0);
                 l_amt_lai := l_amt_lai - l_INTOVDACR;
            End If;
            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_amt_lai > 0 Then
                 l_FEEINTOVDACR := round(least(l_amt_lai, rec2.FEEINTOVDACR),0);
                 l_amt_lai := l_amt_lai - l_FEEINTOVDACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_amt_lai > 0 Then
                l_FEEOVD := round(least(l_amt_lai, rec2.FEEOVD),0);
                l_amt_lai := l_amt_lai - l_FEEOVD;
            End If;

            --13.INTDUE
            l_INTDUE := 0;
            If l_amt_lai > 0 Then
                 l_INTDUE := round(least(l_amt_lai, rec2.INTDUE),0);
                 l_amt_lai := l_amt_lai - l_INTDUE;
            End If;

            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_amt_lai > 0 Then
                 l_FEEINTDUE := round(least(l_amt_lai, rec2.FEEINTDUE),0);
                 l_amt_lai := l_amt_lai - l_FEEINTDUE;
            End If;

            --16.FEEDUE
            l_FEEDUE := 0;
            If l_amt_lai > 0 Then
                l_FEEDUE := round(least(l_amt_lai, rec2.FEEDUE),0);
                l_amt_lai := l_amt_lai - l_FEEDUE;
            End If;



            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_amt_lai > 0 Then
                l_FEEINTNMLACR := round(least(l_amt_lai, rec2.FEEINTNMLACR),0);
                l_amt_lai := l_amt_lai - l_FEEINTNMLACR;
            End If;


            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_amt_lai > 0 Then
                l_INTNMLACR := round(least(l_amt_lai, rec2.INTNMLACR),0);
                l_amt_lai := l_amt_lai - l_INTNMLACR;
            End If;



            --17.FEENML
            l_FEENML := 0;
            If l_amt_lai > 0 Then
                l_FEENML := round(least(l_amt_lai, rec2.FEENML),0);
                l_amt_lai := l_amt_lai - l_FEENML;
            End If;

            /*-- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;*/

            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_amt_goc > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_amt_goc ),0);
                     l_amt_goc := l_amt_goc - l_PRINNML;
                End If;
            end if;
        /*    --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;*/




            --set txnum
            SELECT systemnums.C_BATCH_PREFIXED
                                 || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                          INTO l_txmsg.txnum
                          FROM DUAL;
            l_txmsg.brid        := substr(rec2.trfacctno,1,4);


            --Set cac field giao dich
            --01   C   AUTOID
            l_txmsg.txfields ('01').defname   := 'AUTOID';
            l_txmsg.txfields ('01').TYPE      := 'C';
            l_txmsg.txfields ('01').VALUE     := rec2.lnschdid;

            --03   C   ACCTNO
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec2.acctno;

            --05   C   CIACCTNO
            l_txmsg.txfields ('05').defname   := 'CIACCTNO';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := rec2.TRFACCTNO;

            --09   N   T0ODAMT
            l_txmsg.txfields ('09').defname   := 'T0ODAMT';
            l_txmsg.txfields ('09').TYPE      := 'N';
            l_txmsg.txfields ('09').VALUE     := 0;

             --45   N   PRINAMT
            l_txmsg.txfields ('45').defname   := 'PRINAMT';
            l_txmsg.txfields ('45').TYPE      := 'N';
            l_txmsg.txfields ('45').VALUE     := l_T0PRINOVD + l_T0PRINNML + l_T0PRINDUE + l_PRINOVD + l_PRINDUE + l_PRINNML;
            --46   N   INTAMT
            l_txmsg.txfields ('46').defname   := 'INTAMT';
            l_txmsg.txfields ('46').TYPE      := 'N';
            l_txmsg.txfields ('46').VALUE     :=  l_FEEOVD + l_T0INTNMLOVD + l_INTNMLOVD + l_FEEINTNMLOVD+ l_FEEDUE + l_T0INTDUE + l_INTDUE + l_FEEINTDUE+ l_T0INTOVDACR + l_INTOVDACR + l_FEEINTOVDACR+ l_FEENML + l_T0INTNMLACR + l_INTNMLACR+l_FEEINTNMLACR ;

            --47   N   ADVFEE
            l_txmsg.txfields ('47').defname   := 'ADVFEE';
            l_txmsg.txfields ('47').TYPE      := 'N';
            l_txmsg.txfields ('47').VALUE     := round(rec2.ADVPAYFEE,0) * rec2.FINANCETYPE;

            --60   N   PT0PRINOVD
            l_txmsg.txfields ('60').defname   := 'PT0PRINOVD';
            l_txmsg.txfields ('60').TYPE      := 'N';
            l_txmsg.txfields ('60').VALUE     := l_T0PRINOVD;
            --61   N   PT0PRINDUE
            l_txmsg.txfields ('61').defname   := 'PT0PRINDUE';
            l_txmsg.txfields ('61').TYPE      := 'N';
            l_txmsg.txfields ('61').VALUE     := l_T0PRINDUE;
            --62   N   PT0PRINNML
            l_txmsg.txfields ('62').defname   := 'PT0PRINNML';
            l_txmsg.txfields ('62').TYPE      := 'N';
            l_txmsg.txfields ('62').VALUE     := l_T0PRINNML;
            --63   N   PPRINOVD
            l_txmsg.txfields ('63').defname   := 'PPRINOVD';
            l_txmsg.txfields ('63').TYPE      := 'N';
            l_txmsg.txfields ('63').VALUE     := l_PRINOVD;
            --64   N   PPRINDUE
            l_txmsg.txfields ('64').defname   := 'PPRINDUE';
            l_txmsg.txfields ('64').TYPE      := 'N';
            l_txmsg.txfields ('64').VALUE     := l_PRINDUE;
            --65   N   PPRINNML
            l_txmsg.txfields ('65').defname   := 'PT0PRINOVD';
            l_txmsg.txfields ('65').TYPE      := 'N';
            l_txmsg.txfields ('65').VALUE     := l_PRINNML;
            --70   N   PFEEOVD
            l_txmsg.txfields ('70').defname   := 'PFEEOVD';
            l_txmsg.txfields ('70').TYPE      := 'N';
            l_txmsg.txfields ('70').VALUE     := l_FEEOVD;
            --71   N   PT0INTNMLOVD
            l_txmsg.txfields ('71').defname   := 'PT0INTNMLOVD';
            l_txmsg.txfields ('71').TYPE      := 'N';
            l_txmsg.txfields ('71').VALUE     := l_T0INTNMLOVD;
            --72   N   PINTNMLOVD
            l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
            l_txmsg.txfields ('72').TYPE      := 'N';
            l_txmsg.txfields ('72').VALUE     := l_INTNMLOVD;
            --52   N   PFEEINTNMLOVD
            l_txmsg.txfields ('52').defname   := 'PFEEINTNMLOVD';
            l_txmsg.txfields ('52').TYPE      := 'N';
            l_txmsg.txfields ('52').VALUE     := l_FEEINTNMLOVD;
            --73   N   PT0INTOVDACR
            l_txmsg.txfields ('73').defname   := 'PT0INTOVDACR';
            l_txmsg.txfields ('73').TYPE      := 'N';
            l_txmsg.txfields ('73').VALUE     := l_T0INTOVDACR;
            --74   N   PINTOVDACR
            l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
            l_txmsg.txfields ('74').TYPE      := 'N';
            l_txmsg.txfields ('74').VALUE     := l_INTOVDACR;
            --54   N   PFEEINTOVDACR
            l_txmsg.txfields ('54').defname   := 'PFEEINTOVDACR';
            l_txmsg.txfields ('54').TYPE      := 'N';
            l_txmsg.txfields ('54').VALUE     := l_FEEINTOVDACR;
            --75   N   PFEEDUE
            l_txmsg.txfields ('75').defname   := 'PFEEDUE';
            l_txmsg.txfields ('75').TYPE      := 'N';
            l_txmsg.txfields ('75').VALUE     := l_FEEDUE;
            --76   N   PT0INTDUE
            l_txmsg.txfields ('76').defname   := 'PT0INTDUE';
            l_txmsg.txfields ('76').TYPE      := 'N';
            l_txmsg.txfields ('76').VALUE     := l_T0INTDUE;
            --77   N   PINTDUE
            l_txmsg.txfields ('77').defname   := 'PINTDUE';
            l_txmsg.txfields ('77').TYPE      := 'N';
            l_txmsg.txfields ('77').VALUE     := l_INTDUE;
            --57   N   PFEEINTDUE
            l_txmsg.txfields ('57').defname   := 'PFEEINTDUE';
            l_txmsg.txfields ('57').TYPE      := 'N';
            l_txmsg.txfields ('57').VALUE     := l_FEEINTDUE;
            --78   N   PFEE
            l_txmsg.txfields ('78').defname   := 'PFEE';
            l_txmsg.txfields ('78').TYPE      := 'N';
            l_txmsg.txfields ('78').VALUE     := l_FEENML;
            --79   N   PT0INTNMLACR
            l_txmsg.txfields ('79').defname   := 'PT0INTNMLACR';
            l_txmsg.txfields ('79').TYPE      := 'N';
            l_txmsg.txfields ('79').VALUE     := l_T0INTNMLACR;
            --80   N   PINTNMLACR
            l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
            l_txmsg.txfields ('80').TYPE      := 'N';
            l_txmsg.txfields ('80').VALUE     := l_INTNMLACR;
            --50   N   PFEEINTNMLACR
            l_txmsg.txfields ('50').defname   := 'PFEEINTNMLACR';
            l_txmsg.txfields ('50').TYPE      := 'N';
            l_txmsg.txfields ('50').VALUE     := l_FEEINTNMLACR;
            --81   N   ADVPAYAMT
            l_txmsg.txfields ('81').defname   := 'ADVPAYAMT';
            l_txmsg.txfields ('81').TYPE      := 'N';
            l_txmsg.txfields ('81').VALUE     := l_PRINNML;
            --82   N   FEEAMT
            l_txmsg.txfields ('82').defname   := 'FEEAMT';
            l_txmsg.txfields ('82').TYPE      := 'N';
            l_txmsg.txfields ('82').VALUE     := Round(l_ADVPAYFEE, 0);  --Round(l_PRINNML * REC2.ADVPAYFEE / 100, 0);
            --83   N   PAYAMT
            l_txmsg.txfields ('83').defname   := 'PAYAMT';
            l_txmsg.txfields ('83').TYPE      := 'N';
            l_txmsg.txfields ('83').VALUE     := l_ADVPAYFEE + l_T0PRINOVD + l_T0PRINNML + l_T0PRINDUE + l_PRINOVD + l_PRINDUE + l_PRINNML + l_FEEOVD + l_T0INTNMLOVD + l_INTNMLOVD + l_FEEINTNMLOVD+ l_FEEDUE + l_T0INTDUE + l_INTDUE + l_FEEINTDUE + l_T0INTOVDACR + l_INTOVDACR + l_FEEINTOVDACR + l_FEENML + l_T0INTNMLACR + l_INTNMLACR + l_FEEINTNMLACR;
            plog.debug(pkgctx, 'Balance check:' || l_txmsg.txfields ('83').VALUE);
            --20    N   FINANCETYPE
            l_txmsg.txfields ('20').defname   := 'FINANCETYPE';
            l_txmsg.txfields ('20').TYPE      := 'N';
            l_txmsg.txfields ('20').VALUE     := REC2.FINANCETYPE;

            --30   C   DESC
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE :=l_DESC;

            BEGIN
                IF txpks_#5567.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 5567: ' || p_err_code
                   );
                   ROLLBACK;
                   RETURN;
                   else
                   update Par_lnpaidalloc set  errcode =0,errmessage='good' where lnschdid = rec2.lnschdid;
                END IF;
            END;
        end loop; -- rec2
    commit;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_LNAutoPayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, dbms_utility.format_error_backtrace);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_LNAutoPayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_LNAutoPayment;


PROCEDURE sp_Tool_T3Bank_Process
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
  v_camastid varchar2(30);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_T3Bank_Process');
    --0. Hold them cho nhung tai khoan Corebank bi thieu ky quy
    begin
    for rec in (
        select a.acctno, a.balance, a.holdbalance, b.secured ,
        a.balance-b.secured  GAP
        from cimast a,
        (select afacctno, sum(execamt + feeacr) secured
            from odmast where txdate = getcurrdate and exectype in ('NB') and deltd <> 'Y'
            group by afacctno) b
        where corebank ='Y'
        and a.acctno = b.afacctno
        and a.balance-b.secured <0
    )
    LOOP
        cspks_toolparallel.sp_hold_balance(rec.acctno, -rec.GAP);
    end loop;
    end;
    --1. Unhold for all GAP Balance <> 0
    begin
    for rec in (
        select * from (
        select a.custodycd,af.acctno, a.amount, ci.balance, a.amount - ci.balance GAP, ci.holdbalance , ci.odamt
        from par_thanhtoant3 a, cfmast cf, afmast af, aftype aft , cimast ci
        where a.custodycd = cf.custodycd and cf.custid = af.custid
        and af.actype = aft.actype and aft.mnemonic ='T3' and af.acctno = ci.acctno
        and af.alternateacct ='Y'
        ) where GAP <> 0 and holdbalance>0
    )
    loop
        cspks_toolparallel.sp_UnHold_Balance(rec.acctno, rec.holdbalance);
    end loop;
    end;

    --Hold them tien cho nhung tai khoan co GAP>0
    begin
    for rec in (
        select * from (
        select a.custodycd,af.acctno, a.amount, ci.balance, a.amount - ci.balance GAP, ci.holdbalance , ci.odamt,alternateacct
        from par_thanhtoant3 a, cfmast cf, afmast af, aftype aft , cimast ci
        where a.custodycd = cf.custodycd and cf.custid = af.custid
        and af.actype = aft.actype and aft.mnemonic ='T3' and af.acctno = ci.acctno
        and af.alternateacct ='Y'
        ) where GAP > 0
    )
    loop
        cspks_toolparallel.sp_Hold_Balance(rec.acctno, rec.GAP);
    end loop;
    end;

    --Xu ly cho tai khoan co GAP <0 --> Gen bang ke cat chuyen tien thua sang ngan hang
    begin
    for rec in (
       select * from (
        select a.custodycd,af.acctno, a.amount, ci.balance, a.amount - ci.balance GAP, ci.holdbalance , ci.odamt, af.corebank, af.alternateacct
        from par_thanhtoant3 a, cfmast cf, afmast af, aftype aft , cimast ci
        where a.custodycd = cf.custodycd and cf.custid = af.custid
        and af.actype = aft.actype and aft.mnemonic ='T3' and af.acctno = ci.acctno
        and alternateacct ='Y'
        ) where GAP < 0
    )
    loop
         cspks_toolparallel.sp_Release_Balance(rec.acctno, -rec.GAP);
    end loop;
    end;
    plog.setendsection(pkgctx, 'sp_Tool_T3Bank_Process');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_T3Bank_Process'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_T3Bank_Process');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_T3Bank_Process;


/*PROCEDURE sp_Tool_InternalTransfer
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_InternalTransfer');
    for rec in (
        SELECT
           mst.TRANNO,to_date(mst.TXDATE,'DD/MM/RRRR') txdate,
           mst.FRCUSTODYCD, mst.FRACCOUNTTYPE,
           mst.TOCUSTODYCD, mst.TOACCOUNTTYPE,
           mst.AMOUNT,mst.DESCRIPTION,
           fraf.acctno frafacctno,
           toaf.acctno toafacctno
        FROM  PAR_INTTRANSFER mst,
            AFMAST FRAF,CFMAST FRCF, aftype FRaft, mrtype FRmrt,
            AFMAST TOAF,CFMAST TOCF, aftype TOaft, mrtype TOmrt
        WHERE 0=0 AND TO_DATE(mst.TXDATE,'DD/MM/YYYY')= getcurrdate
        AND mst.FRCUSTODYCD = FRCF.CUSTODYCD
        AND FRCF.CUSTID = FRAF.CUSTID
        and FRaf.actype = FRaft.actype and FRaft.mrtype = FRmrt.actype
        --and (case when FRmrt.mrtype not in  ('S','T') then 'C' else (case when FRaft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.FRACCOUNTTYPE
        and (case when FRmrt.mrtype not in  ('S','T') then 'C' else (case when FRaft.mnemonic ='T3' then 'T' else 'MT' end) end ) = mst.FRACCOUNTTYPE

        AND mst.TOCUSTODYCD = TOCF.CUSTODYCD
        AND TOCF.CUSTID = TOAF.CUSTID
        and TOaf.actype = TOaft.actype and TOaft.mrtype = TOmrt.actype
        --and (case when TOmrt.mrtype not in  ('S','T') then 'C' else (case when TOaft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.TOACCOUNTTYPE
        and (case when TOmrt.mrtype not in  ('S','T') then 'C' else (case when TOaft.mnemonic ='T3' then 'T' else 'MT' end) end ) = mst.TOACCOUNTTYPE


        and (mst.errcode is null or mst.errcode <> '0')
        --and TRANNO='5011D960-13DE-44AB-B258-3E09C6C705E7'
    )
    loop
           fopks_api.pr_InternalTransfer(rec.frafacctno,
                            rec.toafacctno,
                            rec.AMOUNT,
                            rec.DESCRIPTION,
                            p_err_code,
                            p_err_message);
            if p_err_code <> '0' then
                update PAR_INTTRANSFER set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            else
                update PAR_INTTRANSFER set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            end if;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_InternalTransfer');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_InternalTransfer'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_InternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_InternalTransfer;*/



PROCEDURE sp_Tool_InternalTransfer
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
  l_cidepofeeacr NUMBER(20,4);
  l_depofeeamt NUMBER(20,4);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_InternalTransfer');
    for rec in (
     SELECT
           mst.TRANNO,to_date(mst.TXDATE,'DD/MM/RRRR') txdate,
           mst.FRCUSTODYCD, mst.FRACCOUNTTYPE,
           mst.TOCUSTODYCD, mst.TOACCOUNTTYPE,
           mst.AMOUNT,mst.DESCRIPTION,
           fraf.acctno frafacctno,
           toaf.acctno toafacctno
        FROM  PAR_INTTRANSFER mst,
            AFMAST FRAF,CFMAST FRCF, aftype FRaft, mrtype FRmrt,
            AFMAST TOAF,CFMAST TOCF, aftype TOaft, mrtype TOmrt
        WHERE 0=0 AND TO_DATE(mst.TXDATE,'DD/MM/YYYY')= getcurrdate
        AND mst.FRCUSTODYCD = FRCF.CUSTODYCD
        AND FRCF.CUSTID = FRAF.CUSTID
        and FRaf.actype = FRaft.actype and FRaft.mrtype = FRmrt.actype
        --and (case when FRmrt.mrtype not in  ('S','T') then 'C' else (case when FRaft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.FRACCOUNTTYPE
        and (case when FRmrt.mrtype not in  ('S','T') then 'C' else (case when FRaft.mnemonic ='T3' then 'T' else 'MT' end) end ) = mst.FRACCOUNTTYPE

        AND mst.TOCUSTODYCD = TOCF.CUSTODYCD
        AND TOCF.CUSTID = TOAF.CUSTID
        and TOaf.actype = TOaft.actype and TOaft.mrtype = TOmrt.actype
        --and (case when TOmrt.mrtype not in  ('S','T') then 'C' else (case when TOaft.istrfbuy ='Y' then 'T' else 'M' end) end ) = mst.TOACCOUNTTYPE
        and (case when TOmrt.mrtype not in  ('S','T') then 'C' else (case when TOaft.mnemonic ='T3' then 'T' else 'MT' end) end ) = mst.TOACCOUNTTYPE


        and (mst.errcode is null or mst.errcode <> '0')
        ----and TRANNO<>'PZT02145130'
        ---AND TRANNO NOT IN ('PZT02499121','PZT02498987')
        ORDER BY TRANNO
    )
    loop

            select cidepofeeacr, depofeeamt  into l_cidepofeeacr, l_depofeeamt
        from cimast where acctno = rec.frafacctno;
        update cimast set cidepofeeacr = 0, depofeeamt = 0 where acctno = rec.frafacctno;
        COMMIT;
        BEGIN
               fopks_api.pr_InternalTransfer(rec.frafacctno,
                                rec.toafacctno,
                                rec.AMOUNT,
                                rec.DESCRIPTION,
                                p_err_code,
                                p_err_message);

         EXCEPTION WHEN OTHERS THEN
                p_err_code:='-1';
                p_err_message:='lOI';
                update PAR_INTTRANSFER set ERRCODE='-1',
                                    ERRMESSAGE='lOI',
                                    EXECDT = SYSTIMESTAMP
                                where TRANNO= rec.TRANNO;
                plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
         END ;
            update cimast set cidepofeeacr = cidepofeeacr+l_cidepofeeacr, depofeeamt = depofeeamt+l_depofeeamt
            where acctno = rec.frafacctno;

            if p_err_code <> '0' then
                update PAR_INTTRANSFER set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
              else

                update PAR_INTTRANSFER set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;

            end if;
            COMMIT;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_InternalTransfer');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_InternalTransfer'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_InternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_InternalTransfer;


PROCEDURE sp_Tool_InternalSecTransfer
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_InternalSecTransfer');

    for rec in (
        SELECT
           mst.TRANNO,to_date(mst.TXDATE,'DD/MM/RRRR') txdate,
           mst.FRCUSTODYCD, mst.FRACCOUNTTYPE,
           mst.TOCUSTODYCD, mst.TOACCOUNTTYPE,
           mst.QUANTITY,mst.DESCRIPTION, MST.SYMBOL,
           fraf.acctno frafacctno,
           toaf.acctno toafacctno
        FROM  par_intsectransfer mst,
            AFMAST FRAF,CFMAST FRCF, aftype FRaft, mrtype FRmrt,
            AFMAST TOAF,CFMAST TOCF, aftype TOaft, mrtype TOmrt,
            sbsecurities sb, semast se
        WHERE 0=0 AND TO_DATE(mst.TXDATE,'DD/MM/YYYY')= getcurrdate
        AND mst.FRCUSTODYCD = FRCF.CUSTODYCD
        AND FRCF.CUSTID = FRAF.CUSTID
        and FRaf.actype = FRaft.actype and FRaft.mrtype = FRmrt.actype
         and (case when FRmrt.mrtype not in  ('S','T') then 'C' else 'MT' end ) = TRIM(mst.FRACCOUNTTYPE)
        and sb.symbol = mst.symbol and sb.codeid = se.codeid
        and fraf.acctno = se.afacctno and se.trade >= mst.QUANTITY
        AND mst.TOCUSTODYCD = TOCF.CUSTODYCD
        AND TOCF.CUSTID = TOAF.CUSTID
        and TOaf.actype = TOaft.actype and TOaft.mrtype = TOmrt.actype
         and (case when TOmrt.mrtype not in  ('S','T') then 'C' else 'MT' end ) = TRIM(mst.TOACCOUNTTYPE)
        and (mst.errcode is null or mst.errcode <> '0')
        AND fraf.acctno||SB.CODEID IN (SELECT acctno FROM SEMAST)
        ----AND MST.TRANNO = 'ERT00027330'
         order by mst.TRANNO
    )
    loop
        plog.debug( pkgctx, 'Begin pr_Transfer_SE_account ' ||  rec.frafacctno || ' ' ||rec.toafacctno || ' ' ||  rec.symbol || ' ' || rec.quantity );
           fopks_api.pr_Transfer_SE_account(rec.frafacctno,
                            rec.toafacctno,
                            rec.symbol,
                            rec.quantity,
                            0,
                            0,
                            p_err_code,
                            p_err_message);

           plog.debug( pkgctx, 'END pr_Transfer_SE_account ' ||  rec.frafacctno || ' ' ||rec.toafacctno || ' ' ||  rec.symbol || ' ' || rec.quantity  );

            if p_err_code <> '0' then
                update PAR_INTSECTRANSFER set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            else
                update PAR_INTSECTRANSFER set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where TRANNO= rec.TRANNO;
            end if;
             plog.debug( pkgctx, 'END update pr_Transfer_SE_account ' || rec.TRANNO );
            commit;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_InternalSecTransfer');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_InternalSecTransfer'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_InternalSecTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_InternalSecTransfer;

PROCEDURE sp_Tool_PlaceOrder
IS
    l_txmsg               tx.msg_rectype;
    p_err_code varchar2(100);
    p_err_message varchar2(1000);
    ERROR NUMBER;
    ERRORMSG VARCHAR2 (2000);
    l_exectype varchar2(10);
    l_codeid varchar2(20);
    l_pp number;
    l_emkqtty number;
    l_custatcom char(1);
    l_trade number;
    l_mortage number;
    l_blocked number;
    l_status char(1);
    l_dfmortage number;

    p_holdamt number;
    p_strIn varchar2(100);
    v_strODACTYPE varchar2(10);
    l_deffeerate number;
    PV_REFCURSOR PKG_REPORT.REF_CURSOR;
Begin
    plog.setbeginsection(pkgctx, 'sp_Tool_PlaceOrder');
    FOR REC IN
    (
       select  TO_CHAR (TO_DATE(mst.TXDATE,'DD/MM/YYYY'),'DD/MM/YYYY')||LPAD(seq_fomast.NEXTVAL,10,0) ACCTNO,
           '8080'|| TO_CHAR (TO_DATE(mst.TXDATE,'DD/MM/YYYY'),'DDMMYYYY')||LPAD(seq_oDmast.NEXTVAL,6,0) ORDERID,
           mst.*
       from (
           SELECT

               AF.ACCTNO AFACCTNO,(case when od.pricetype='PT' then 'LO' else od.pricetype end) pricetype ,od.MATCHTYPE,
               SB.CODEID,SB.SYMBOL,OD.QUANTITY ,
               case when exectype ='NB' and pricetype in ('ATO','ATC','MTL','MOK','MAK') then inf.ceilingprice/1000 else
                   case when exectype ='NS' and pricetype in ('ATO','ATC','MTL','MOK','MAK') then inf.floorprice/1000 else
                   OD.PRICE end
               end PRICE,
               od.TXDATE,
               CF.CUSTID,OD.VIA,od.exectype, od.ACCOUNTTYPE ismargin, cf.custodycd,od.ORDERNO, od.ORDERSEQ,
               (case when af.corebank ='Y' then af.corebank else af.alternateacct end) corebank,
               od.matchqtty,
               od.cancelqtty, sb.tradeplace, af.actype , sb.sectype
            FROM  par_orderbookcv od,
            sbsecurities SB,AFMAST AF,CFMAST CF, aftype aft, mrtype mrt,securities_info inf
            WHERE TO_DATE(OD.TXDATE,'DD/MM/YYYY')= getcurrdate
            and OD.SYMBOL =SB.SYMBOL and sb.codeid = inf.codeid
            AND OD.CUSTODYCD = CF.CUSTODYCD
            AND CF.CUSTID = AF.CUSTID  and af.status = 'A'
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            --and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.mnemonic ='T3' then 'T' else 'M' end) end ) = od.ACCOUNTTYPE
            and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.mnemonic ='T3' then 'T' else 'MT' end) end ) = od.ACCOUNTTYPE
            and od.exectype in ('NB','NS')
            and od.matchtype in ('N','P') --'P', chi day lenh thuong, khong day lenh thoa thuan
            and od.pricetype in ('LO','ATO','ATC', 'PT','MP','MTL','MOK','MAK')
            and (od.errcode is null or od.errcode <> '0')
            and orderseq not in (
                    select custid from odmast where txdate = getcurrdate
                )
            and substr(od.CUSTODYCD,1,4) <> systemnums.C_DEALINGCUSTODYCD
            --and AF.ACCTNO='0101922564'
----            and orderseq in ('2367')
            ---AND orderseq <> 'MGB09412372'
            order by (orderseq)
        ) mst
    )
    LOOP

        plog.setbeginsection(pkgctx, 'sp_Tool_PlaceOrder');
        l_exectype:= rec.exectype;
        l_codeid:=rec.CODEID;
        l_status:='A';
        if l_exectype <> 'NB' then
            begin
                select a.trade - nvl(b.secureamt,0), a.mortage, a.blocked, a.emkqtty
                into l_trade, l_mortage, l_blocked, l_emkqtty
                        from semast a, v_getsellorderinfo b
                        where a.afacctno = rec.afacctno and a.codeid = rec.codeid
                        AND acctno = b.seacctno(+);

            exception when others then
                l_trade:=0;
                l_mortage:=0;
                l_blocked:=0;
                l_emkqtty:=0;
            end;
            if l_trade >= REC.QUANTITY then
                l_exectype:= 'NS';
            else
                l_status:='R';
                update par_orderbookcv set ERRCODE='-1',
                ERRMESSAGE='Thieu so du chung khoan ban (' ||
                    'Trade:' || l_trade || ' - ' ||
                    'Mortgage:'  || l_mortage || ' - '||
                    'Blocked:' || l_blocked || ' - '||
                    'Emkqtty:' || l_emkqtty || ')',
                EXECDT = SYSTIMESTAMP
                where ORDERSEQ= rec.ORDERSEQ;
                l_exectype:= 'NS';
            end if;
        end if;

         --Neu tai khoan luu ky ben ngoai thi voi lenh mua thieu tien --> cap bao lanh
        --Voi lenh ban thieu chung khoan thi cap them chung khoan
        select custatcom into l_custatcom from cfmast where custid = rec.custid;

        if l_custatcom ='N' then
            if l_exectype ='NB' THEN
                --Kiem tra va cao bao lanh tien
                sp_Tool_AutoAllocateMoney(rec.afacctno,1000000000000);
            else
                l_exectype:='NS'; --Tai khoan luu ky ben ngoai khong co lenh cam co
                --Kiem tra va cap bao lanh chung khoan
                if l_trade < REC.QUANTITY then
                    sp_Tool_AutoAllocateSecurities(rec.afacctno,rec.symbol, rec.QUANTITY );
                    l_status:='A';
                end if;
            end if;
        else
            if l_exectype ='NB' and rec.corebank='N' THEN
                plog.error(pkgctx, 'sp_Tool_AutoAllocateMoney : ' || rec.afacctno);
                --Kiem tra va cao bao lanh tien
                sp_Tool_AutoAllocateMoney(rec.afacctno,1000000000000);
            end if;
        end if;

        --Thuc hien hold them so du ben ngan hang de dat lenh
        if rec.corebank='Y' and l_exectype='NB' then --Tai khoan corebank
            --Tinh toan so du can Hold
            --Patten: NB|AFACCTNO|ACTYPE|SYMBOL|QTTY|PRICE[|Securatio]
            begin
                l_deffeerate:=0.25;
                v_strODACTYPE := fopks_api.fn_GetODACTYPE(REC.AFACCTNO, rec.SYMBOL, rec.CODEID, rec.tradeplace, l_exectype,
                                        REC.pricetype, 'T', rec.actype , rec.sectype , REC.VIA);

                select deffeerate into l_deffeerate from odtype where actype =  v_strODACTYPE;
            exception when others then
                l_deffeerate:=0.25;
            end;
            p_strIn:='NB' || '|' || REC.AFACCTNO || '|' || 'XXXX' || '|' || rec.SYMBOL || '|' || REC.QUANTITY || '|' || REC.PRICE*1000 || '|' ||  to_char(100+l_deffeerate);
            cspks_rmproc.pr_CaculateHoldAmount(p_strIn,p_holdamt,p_err_code);
            --update cimast set balance = balance + p_holdamt, holdbalance = holdbalance + p_holdamt where acctno =rec.afacctno;
            if p_holdamt is not null then
                if p_holdamt>0 then
                    sp_Hold_Balance(REC.AFACCTNO,p_holdamt);
                end if;
            end if;
        end if;
        if l_status='A' then
            --Dat lenh
            if rec.matchtype ='P' then
                --Cap nhat khong chan khoi luong toi da san HOSE
                update sysvar set varvalue =19990000 where varname ='HOSEBREAKSIZE';
                update sysvar set varvalue =19990000 where varname ='HOSE_MAX_QUANTITY';
                update  securities_info set tradelot=1  where symbol = REC.SYMBOL ;
            end if;
            update sysvar set varvalue =19999900 where varname ='HNX_MAX_QUANTITY';
            update sysvar set varvalue =100000000  where varname in('HOSE_MAX_QUANTITY','HOSEBREAKSIZE','HSX_MAXBREAKSIZE_QTTY');
            fopks_api.pr_placeorder ('PLACEORDER',
                                    rec.ORDERSEQ,--REC.CUSTID ,
                                    '' ,
                                    REC.AFACCTNO,
                                    l_exectype,
                                    REC.SYMBOL ,
                                    REC.QUANTITY ,
                                    REC.PRICE ,
                                    REC.pricetype ,
                                    'T' ,
                                    'A' ,
                                    REC.VIA ,
                                    '' ,
                                    'Y' ,
                                    '' ,
                                    '' ,
                                    '0001',
                                    0,
                                    0,
                                    p_err_code,
                                    p_err_message
                                    );
            if p_err_code <> '0' then
                if REC.exectype='NB' then
                    update par_orderbookcv set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where ORDERSEQ= rec.ORDERSEQ;
                else
                    update par_orderbookcv set ERRCODE=p_err_code,
                        ERRMESSAGE = p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where ORDERSEQ= rec.ORDERSEQ;
                end if;
            else
                update par_orderbookcv set ERRCODE=p_err_code, ERRMESSAGE='Lenh day OK',
                        EXECDT = SYSTIMESTAMP
                    where ORDERSEQ= rec.ORDERSEQ;
            end if;

            update sysvar set varvalue =19990  where varname in('HOSE_MAX_QUANTITY','HOSEBREAKSIZE','HSX_MAXBREAKSIZE_QTTY');

            update sysvar set varvalue =999900 where varname ='HNX_MAX_QUANTITY';
            if rec.matchtype ='P' then
                update  securities_info set tradelot=10  where symbol = REC.SYMBOL AND symbol in (select symbol from sbsecurities where tradeplace='001');
                update  securities_info set tradelot=100  where symbol = REC.SYMBOL AND symbol in (select symbol from sbsecurities where tradeplace IN ('002','005'));
                --Cap nhat lai chan khoi luong toi da san HOSE
                update sysvar set varvalue =19990 where varname ='HOSEBREAKSIZE';
                update sysvar set varvalue =19990 where varname ='HOSE_MAX_QUANTITY';

                --Cap nhat lai loai lenh thanh thoa thuan
                if p_err_code = '0' then
                    for rec_norp in (select orderid from odmast where custid = rec.orderseq and rec.matchtype ='P' and txdate = getcurrdate)
                    loop
                        update odmast set matchtype ='P' where orderid = rec_norp.orderid;
                        update ood set norp ='P' where orgorderid = rec_norp.orderid;
                    end loop;
                end if;

            end if;
            --Khop lenh
            if p_err_code = '0' then --Lenh dat thanh cong
                for rec_iod in (
                    select orderseq, io.quantity,io.price*1000 price , od.orderid, io.confirmnumber
                    from par_iodbookcv  io, odmast od , sbsecurities sb,fomast fo
                    where io.orderseq = fo.username and od.codeid = sb.codeid
                    and fo.orgacctno = od.orderid
                    and sb.symbol= io.symbol and od.txdate = getcurrdate
                    and (io.confirmnumber,io.exectype, io.symbol) not in (select nvl(confirm_no,'-'),'N' || bors, symbol from iod)
                    and io.orderseq=rec.ORDERSEQ
                )
                loop
                    --i:=i+1;
                    sp_matching_order(rec_iod.orderid, rec_iod.quantity,rec_iod.price,rec_iod.confirmnumber);
                end loop;
            end if;
            --Huy lenh
            if p_err_code = '0' then --Lenh dat thanh cong
                for rec_can in (
                    select mst.cancelqtty, od.orderid
                    from par_orderbookcv mst, odmast od , sbsecurities sb
                    where mst.orderseq = od.custid and od.codeid = sb.codeid
                    and od.txdate = getcurrdate
                    and sb.symbol= mst.symbol
                    and orderseq=rec.ORDERSEQ
                )
                loop
                    sp_cancel_normal_order(rec_can.orderid, rec_can.cancelqtty);
                end loop;
            end if;

            --Giai toa tien sang ngan hang voi tai khoan corebank
            if rec.corebank ='Y' then
                BEGIN
                    sp_UnHold_AllBalance(rec.afacctno);
                EXCEPTION WHEN OTHERS THEN
                    plog.error(pkgctx,'Error when gen unhold for cancel order : ' || rec.afacctno);
                    plog.error(pkgctx, SQLERRM);
                END;
            end if;
              --End

        end if;
        if l_custatcom ='Y' then
            if l_exectype ='NB' and rec.corebank='N' THEN
                --Kiem tra va thu hoi bao lanh tien
                sp_Tool_AutoReleaseMoney(rec.afacctno,1000000000000);
            end if;
        end if;
        plog.setendsection (pkgctx, 'sp_Tool_PlaceOrder');
    END LOOP;

    plog.setendsection (pkgctx, 'sp_Tool_PlaceOrder');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_PlaceOrder' || dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_PlaceOrder');
      RAISE errnums.E_SYSTEM_ERROR;
END sp_Tool_PlaceOrder;


PROCEDURE sp_Tool_DepoPaid
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
  v_camastid varchar2(30);
  l_baldevovd number;
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_DepoPaid');
    for rec in (
        select mst.custodycd, mst.afacctno, mst.amount, mst.dpmonth,mst.dpyear,
            mst.amount-dp.amount  GAP,
            --dp.custodycd,  dp.amount, dp.dpmonth,dp.dpyear,
            ci.balance,mst.alternateacct, mst.corebank,
            dp.autoid, dp.errcode, dp.errmessage, mst.TODATE, mst.FTODATE
            from (
                select cf.custodycd, fe.afacctno, fe.nmlamt- paidamt amount,
                    to_char(txdate,'MM') dpmonth, to_char(txdate,'RRRR')  dpyear, af.alternateacct, af.corebank,
                    fe.TODATE,to_Char(to_Date(fe.TODATE,'DD/MM/RRRR'),'MM/RRRR') FTODATE
                from cifeeschd fe, afmast af, cfmast cf
                where fe.feetype ='VSDDEP' --and fe.nmlamt-fe.paidamt>0 and fe.deltd <> 'Y'
                and fe.afacctno = af.acctno and af.custid = cf.custid
            ) mst, par_depo dp, cimast ci
            where mst.custodycd = upper(dp.custodycd)
                and mst.dpmonth = dp.dpmonth
                and mst.dpyear = dp.dpyear
                and mst.afacctno = ci.acctno
            and (dp.errcode is null or dp.errcode <> '0')
            --and autoid =14243
    )
    loop
        --Kiem tra xem co su kien nao thoa man
        begin
           /*if rec.alternateacct='Y' or rec.corebank ='Y' then
                --Thuc hien Hold them so tien con thieu
                if rec.balance < rec.amount then
                    sp_Hold_Balance(rec.afacctno, rec.amount);
                end if;

           end if;*/
           --update cimast set depofeeamt =  depofeeamt + rec.amount where acctno =rec.afacctno;
           sp_Paid_DepoFee (
               rec.custodycd,
               rec.afacctno,
               rec.amount,
               rec.TODATE,
               rec.FTODATE,
               p_err_code,
               p_err_message
            );
            if p_err_code <> '0' then
                update par_depo set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where AUTOID= rec.AUTOID;
            else
                update par_depo set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where AUTOID= rec.AUTOID;
            end if;
            commit;
        exception when others then
            update par_depo set ERRCODE='-1',
                        ERRMESSAGE='Su kien quyen khong ton tai!',
                        EXECDT = SYSTIMESTAMP
                    where AUTOID= rec.AUTOID;
        end;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_DepoPaid');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_DepoPaid'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_DepoPaid');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_DepoPaid;

PROCEDURE sp_Tool_CashInterestReceive
is
  p_err_code    varchar2(100);
  p_err_message  varchar2(500);
  v_camastid varchar2(30);
  l_baldevovd number;
begin
    plog.setbeginsection(pkgctx, 'sp_Tool_CashInterestReceive');
    for rec in (
        SELECT
          mst.autoid,mst.CUSTODYCD,mst.ACCOUNTTYPE,mst.amount,
          'Tra lai tien gui Thang 12' DESCRIPTION,
          af.acctno afacctno
        FROM  par_ciint mst,AFMAST AF,CFMAST CF, aftype aft, mrtype mrt
        WHERE 0=0
        AND mst.CUSTODYCD = CF.CUSTODYCD
        AND CF.CUSTID = AF.CUSTID
        and af.actype = aft.actype and aft.mrtype = mrt.actype
        and (case when mrt.mrtype not in  ('S','T') then 'C' else (case when aft.mnemonic ='T3' then 'T' else 'M' end) end ) = mst.ACCOUNTTYPE
        and (mst.errcode is null or mst.errcode <> '0')
        and af.status <> 'C'

    )
    loop
        --Kiem tra xem co su kien nao thoa man
        begin
            update cimast set CRINTACR = rec.amount where acctno = rec.afacctno;
            sp_Receive_Interest(
               rec.afacctno,
               rec.amount,
               p_err_code,
               p_err_message
            );
            if p_err_code <> '0' then
                update par_ciint set ERRCODE=p_err_code,
                        ERRMESSAGE=p_err_message,
                        EXECDT = SYSTIMESTAMP
                    where AUTOID= rec.AUTOID;
            else
                update par_ciint set ERRCODE=p_err_code, ERRMESSAGE='Giao dich day OK',
                        EXECDT = SYSTIMESTAMP
                    where AUTOID= rec.AUTOID;
            end if;
            commit;
        exception when others then
            update par_ciint set ERRCODE='-1',
                        ERRMESSAGE='Su kien quyen khong ton tai!',
                        EXECDT = SYSTIMESTAMP
                    where AUTOID= rec.AUTOID;
        end;
        commit;
    end loop;
    plog.setendsection(pkgctx, 'sp_Tool_CashInterestReceive');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on sp_Tool_CashInterestReceive'|| dbms_utility.format_error_backtrace);
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'sp_Tool_CashInterestReceive');
      RAISE errnums.E_SYSTEM_ERROR;
end sp_Tool_CashInterestReceive;

BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_ToolParallel',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
