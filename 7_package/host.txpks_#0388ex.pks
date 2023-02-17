SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0388ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0388EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      07/10/2015     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0388ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_reoldacctno      CONSTANT CHAR(2) := '21';
   c_recustnameo      CONSTANT CHAR(2) := '25';
   c_oradesc          CONSTANT CHAR(2) := '92';
   c_rerole           CONSTANT CHAR(2) := '14';
   c_reacctno         CONSTANT CHAR(2) := '08';
   c_recustname       CONSTANT CHAR(2) := '91';
   c_recustid         CONSTANT CHAR(2) := '02';
   c_reactype         CONSTANT CHAR(2) := '07';
   c_radesc           CONSTANT CHAR(2) := '94';
   c_rerole           CONSTANT CHAR(2) := '09';
   c_frdate           CONSTANT CHAR(2) := '05';
   c_todate           CONSTANT CHAR(2) := '06';
   c_t_desc           CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
      v_strTODATE                       DATE;
      v_strFRDATE                        DATE;
      v_strREROLE                         NVARCHAR2(20);
      V_STRREACCTNO              NVARCHAR2(20);
      v_checkDuplicateRole         NUMBER(20);
      v_strREACTYPE                  NVARCHAR2(20);
      v_status                                 NVARCHAR2(20);
      v_count                  NUMBER(20);
      v_countnum                   NUMBER(20);
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

     select count(*) into v_count from remast where acctno = P_TXMSG.TXFIELDS('08').VALUE;
    if v_count = 0 then
        INSERT INTO REMAST (ACCTNO,CUSTID,ACTYPE,STATUS,PSTATUS,
            LAST_CHANGE,RATECOMM,BALANCE,DAMTACR,DAMTLASTDT,
            IAMTACR, IAMTLASTDT,DIRECTACR,INDIRECTACR,ODFEETYPE,ODFEERATE,COMMTYPE,LASTCOMMDATE)
        SELECT  P_TXMSG.TXFIELDS('08').VALUE ACCTNO ,P_TXMSG.TXFIELDS('02').VALUE CUSTID,P_TXMSG.TXFIELDS('07').VALUE ACTYPE, 'A' STATUS,'' PSTATUS,
            sysdate LAST_CHANGE,  RATECOMM, 0 BALANCE, 0 DAMTACR, TO_DATE(GETCURRDATE,'DD/MM/RRRR') DAMTLASTDT,
            0 IAMTACR , TO_DATE(GETCURRDATE,'DD/MM/RRRR') IAMTLASTDT , 0 DIRECTACR, 0 INDIRECTACR, ODFEETYPE,ODFEERATE,COMMTYPE,TO_DATE(GETCURRDATE,'DD/MM/RRRR')  LASTCOMMDATE
        FROM RETYPE WHERE ACTYPE=P_TXMSG.TXFIELDS('07').VALUE;
    end if;
    --end remast

    v_strREROLE:= P_TXMSG.TXFIELDS('09').VALUE;
    V_STRREACCTNO:= P_TXMSG.TXFIELDS('21').VALUE;

    --Kiem tra so luong khach hang moi gioi chuyen
      select count(*) into v_countnum from reaflnk where reacctno = P_TXMSG.TXFIELDS('21').VALUE AND STATUS='A';
    if v_countnum = 0 then
        p_err_code := '-560004';
        plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
    RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    --Kiem tra trang thai cua MG
    SELECT status INTO v_status
    FROM remast
    WHERE ACCTNO = V_STRREACCTNO ;
    IF  NOT ( v_status='A') THEN
        p_err_code := '-560004';
        plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
    RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    ---Ktra M?i?i chuy?n v?h?n ph?i c?ng vai tr?ac chuyen tu CS sang RM hoac RM sang CS

/*    Select count(rerole) into v_count from retype where rerole = v_strREROLE and actype = substr(P_TXMSG.TXFIELDS('21').VALUE,11,4);
    if v_count = 0 then
         p_err_code := '-561026';
        plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
    RETURN errnums.C_BIZ_RULE_INVALID;
    end if;*/
        SELECT COUNT(1)  into v_count FROM retype ot, retype nt
        WHERE (ot.rerole = nt.rerole OR ( ot.rerole IN ('CS','RM') AND nt.rerole IN ('CS','RM') ))
        AND nt.actype = SUBSTR(P_TXMSG.TXFIELDS('08').VALUE,11,4)
        AND ot.actype =  SUBSTR(P_TXMSG.TXFIELDS('21').VALUE,11,4);

     if v_count = 0 then
         p_err_code := '-561013';
        plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
    RETURN errnums.C_BIZ_RULE_INVALID;
    end if;


    --Ktra khong cho phep vua la MG vua la cham soc ho
    IF v_strREROLE='RD' THEN
        select count(1)  INTO v_checkDuplicateRole
        from reaflnk rl , retype rty
        where substr(rl.reacctno, 11, 4) = rty.actype
            and  rl.status='A' and rty.rerole <> 'RD' AND RL.AFACCTNO IN (SELECT AFACCTNO FROM reaflnk WHERE REACCTNO = V_STRREACCTNO AND STATUS = 'A');
        IF  ( v_checkDuplicateRole > 0) THEN
            p_err_code := '-561020';
            plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
        RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    ELSE
        select count(1)  INTO v_checkDuplicateRole
        from reaflnk rl , retype rty
        where substr(rl.reacctno, 11, 4) = rty.actype
            and  rl.status='A' and rty.rerole = 'RD' AND RL.AFACCTNO IN (SELECT AFACCTNO FROM reaflnk WHERE REACCTNO = V_STRREACCTNO AND STATUS = 'A');
        IF  ( v_checkDuplicateRole > 0) THEN
            p_err_code := '-561020';
            plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
        RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
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
    v_strTODATE                       DATE;
      v_strFRDATE                        DATE;
      v_strREROLE                         NVARCHAR2(20);
      V_STRREACCTNO              NVARCHAR2(20);
      v_checkDuplicateRole         NUMBER(20);
      v_strREACTYPE                  NVARCHAR2(20);
      v_status                                 NVARCHAR2(20);
      v_count                  NUMBER(20);
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


      v_strREOLDACCTNO         NVARCHAR2(100);
      v_strTODATE                       DATE;
      v_strFRDATE                        DATE;
      v_strRECUSTID                    NVARCHAR2(20);
      v_strREROLE                         NVARCHAR2(20);
      v_strCustomerID                   NVARCHAR2(20);
      v_countRemiser                    NUMBER(20);
      V_STRREACCTNO              NVARCHAR2(20);
      v_strREACTYPE                  NVARCHAR2(20);
      v_strREOLDCUSTID           NVARCHAR2(20);
      v_strFURECUSTID              NVARCHAR2(20);
      v_strORGREACCTNO         NVARCHAR2(20);
      V_checkbeforupdate         number;
      v_strFUREACTYPE               NVARCHAR2(20);
      v_count  NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    v_strRECUSTID := P_TXMSG.TXFIELDS('02').VALUE;
    v_strFRDATE :=To_date( P_TXMSG.TXFIELDS('05').VALUE,'DD/MM/RRRR');
    v_strTODATE := to_date(P_TXMSG.TXFIELDS('06').VALUE,'DD/MM/RRRR');
    v_strREACTYPE := P_TXMSG.TXFIELDS('07').VALUE;
    v_strREROLE:= P_TXMSG.TXFIELDS('09').VALUE;
    v_strREACCTNO:= P_TXMSG.TXFIELDS('08').VALUE;
    v_strFUREACTYPE:='';



FOR REC IN
  (
      SELECT AFACCTNO FROM REAFLNK  WHERE REACCTNO=P_TXMSG.TXFIELDS('21').VALUE AND STATUS='A'
  )
  LOOP


         IF p_txmsg.deltd <> 'Y' THEN



            If v_strREROLE = 'BM' THEN
            --  ' Neu la BRthi insert them thong tin tk moi gioi tuong lai
                INSERT INTO REAFLNK (AUTOID, TXDATE, TXNUM, REFRECFLNKID, REACCTNO, AFACCTNO, DELTD, STATUS, FRDATE, TODATE,FUREFRECFLNKID)
                SELECT SEQ_REAFLNK.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),  p_txmsg.txnum , r1.AUTOID,
                    v_strREACCTNO , REC.AFACCTNO ,'N','A', TO_DATE( v_strFRDATE , systemnums.C_DATE_FORMAT), TO_DATE( v_strTODATE , systemnums.C_DATE_FORMAT), r2.AUTOID
                FROM RECFLNK r1 , RECFLNK r2 WHERE r1.CUSTID= v_strRECUSTID and r2.custid =  v_strFURECUSTID;
            ELSE
            -- 'Neu la RM, RD,AE,DG thi fhi insert thong tin moi gioi hien tai
                INSERT INTO REAFLNK (AUTOID, TXDATE, TXNUM, REFRECFLNKID, REACCTNO, AFACCTNO, DELTD, STATUS, FRDATE, TODATE,ORGREACCTNO)
                SELECT SEQ_REAFLNK.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),  p_txmsg.txnum , RECFLNK.AUTOID,
                v_strREACCTNO  ,  REC.AFACCTNO ,'N','A', TO_DATE( v_strFRDATE , systemnums.C_DATE_FORMAT), TO_DATE( v_strTODATE , systemnums.C_DATE_FORMAT) ,  NULL
                FROM RECFLNK WHERE CUSTID= v_strRECUSTID;
            END IF;

            UPDATE REAFLNK SET STATUS='C', CLSTXDATE=TO_DATE( v_strFRDATE , systemnums.C_DATE_FORMAT), CLSTXNUM=p_txmsg.txnum
            WHERE STATUS = 'A' AND AFACCTNO =  REC.AFACCTNO AND REACCTNO = P_TXMSG.TXFIELDS('21').VALUE;

         INSERT INTO re_customerchange_log
         VALUES (seq_re_customerchange_log.nextval, REC.AFACCTNO,p_txmsg.txfields('21').value,
                 p_txmsg.txfields('08').value,p_txmsg.txdate,p_txmsg.txnum,p_txmsg.tlid, p_txmsg.offid );

        Else

            UPDATE REAFLNK SET DELTD='Y' WHERE TXDATE=TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND TXNUM=  p_txmsg.txnum ;
            UPDATE REAFLNK SET STATUS='A', CLSTXDATE=NULL, CLSTXNUM=NULL
            WHERE AFACCTNO=  REC.AFACCTNO AND REACCTNO=  P_TXMSG.TXFIELDS('21').VALUE;

            DELETE FROM re_customerchange_log WHERE txdate = p_txmsg.txdate AND txnum = p_txmsg.txnum;


        End IF;

END LOOP;

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
         plog.init ('TXPKS_#0388EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0388EX;
/
