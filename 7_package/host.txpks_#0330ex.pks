SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0330ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0330EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      22/08/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0330ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_fileid           CONSTANT CHAR(2) := '03';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_count number;
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
    -- Ktra co gd can duyet hay khong
    select count(*) into v_count
    from tblre0380 where fileid = p_txmsg.txfields(c_fileid).value ;
    if (v_count=0) then
         p_err_code := '-561031';
                          plog.setendsection (pkgctx, ' fn_txPreAppCheck ');
                          RETURN errnums.C_BIZ_RULE_INVALID;
      end if;
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
    v_strDesc varchar2(1000);
    v_strEN_Desc varchar2(1000);
    l_err_param varchar2(500);
    v_strCURRDATE varchar2(20);
    V_STRCUSTOMERID varchar2(20);
    V_check0380  NUMBER;
    l_txmsg               tx.msg_rectype;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
      if p_txmsg.deltd<>'Y' then
        SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='0380';
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
        l_txmsg.batchname   := 'AUTO';
        l_txmsg.reftxnum    := p_txmsg.txnum;
        l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.BUSDATE:=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd:='0380';

        FOR REC in (
                      SELECT * FROM tblRE0380 tbl
                      WHERE tbl.fileid= p_txmsg.txfields(c_fileid).value
                      AND    nvl(tbl.deltd,'N') <> 'Y' and nvl(tbl.status,'A') <> 'C'
                )
            loop
-----------------------------------------------
    plog.error (pkgctx, '0330   1');
            -----------------------------------------
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
                     --Check cac dk cua 0380
                    --Lay thong tin kh
                   SELECT CUSTID
                    INTO V_STRCUSTOMERID
                    FROM CFMAST CF
                   WHERE CF.CUSTODYCD = rec.custodycd;
                  --Ki?m tra kh?du?c khai b?tr?ng
                  --M?i customer ch? c?i da 1 ngu?i gi?i thi?u, 01 BR hoac 01 AE & RM

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
                           RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END;
                    end if;
                    update TBLRE0380 set status = 'Y' where autoid = rec.AUTOID;
            end loop;

        insert into TBLRE0380HIST select * from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
        delete from TBLRE0380 WHERE fileid = p_txmsg.txfields(c_fileid).value ;
    ELSE
        for rec in
        (
            select * from tllog where reftxnum = p_txmsg.txnum
        )
        loop
            if txpks_#0380.fn_txrevert(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                plog.error (pkgctx, 'Loi khi thuc hien xoa giao dich');
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                return errnums.C_SYSTEM_ERROR;
            end if;
        end loop;dbms_output.put_line('');
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
         plog.init ('TXPKS_#0330EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0330EX;

/
