SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0380ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0380EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/08/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0380ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_frdate           CONSTANT CHAR(2) := '05';
   c_todate           CONSTANT CHAR(2) := '06';
   c_amt              CONSTANT CHAR(2) := '10';
   c_orgreacctno      CONSTANT CHAR(2) := '31';
   c_reacctno         CONSTANT CHAR(2) := '08';
   c_recustname       CONSTANT CHAR(2) := '91';
   c_rerole           CONSTANT CHAR(2) := '09';
   c_reactype         CONSTANT CHAR(2) := '07';
   c_recustid         CONSTANT CHAR(2) := '02';
   c_t_desc           CONSTANT CHAR(2) := '30';
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

        -----------check neu da co moi gioi cung loai hinh thi khong cho phep gan
    /*SELECT COUNT(1) INTO v_count  FROM reaflnk l, remast r, retype rt , retype nrt, remast nr
    WHERE l.status = 'A' AND r.actype = rt.actype AND l.reacctno = r.acctno
        AND l.afacctno IN (SELECT custid FROM cfmast WHERE custodycd = P_TXMSG.TXFIELDS('88').VALUE )
    AND rt.retype = nrt.retype AND  nrt.actype = nr.actype AND nr.acctno =P_TXMSG.TXFIELDS(c_reacctno).VALUE
    AND l.todate >=  to_date(P_TXMSG.TXFIELDS(c_frdate).VALUE,'DD/MM/RRRR') AND  l.frdate <= to_date(P_TXMSG.TXFIELDS(c_todate).VALUE,'DD/MM/RRRR');*/

        ---khong cho phep gan trung moi gioi cugn loai hinh
    ---kh chi duoc phep co 1 tu van dau tu (CS) hoac phat trien khach hang (RM)

    --check neu khac khoang thoi gian thi van duoc gan
        SELECT COUNT (1) INTO v_count FROM remast m, reaflnk a, retype r, retype nr
        WHERE m.acctno = a.reacctno
        AND m.actype = r.actype AND a.status = 'A'
        AND a.afacctno IN (SELECT custid FROM cfmast WHERE custodycd = P_TXMSG.TXFIELDS('88').VALUE )
        AND nr.actype = P_TXMSG.TXFIELDS('07').VALUE
        AND  (nr.rerole = r.rerole OR ( nr.rerole IN ('CS','RM') AND r.rerole IN ('CS','RM') ) )
        AND a.todate >= to_date(P_TXMSG.TXFIELDS(c_frdate).VALUE,'DD/MM/RRRR')
        AND a.frdate <= to_date(P_TXMSG.TXFIELDS(c_todate).VALUE,'DD/MM/RRRR');

    if v_count <> 0 then
         p_err_code := '-561013';
        plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
    RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
        -----check khong cho phep gan vao loai hinh gian tiep
        SELECT COUNT(1) INTO v_count FROM retype WHERE actype =  P_TXMSG.TXFIELDS(c_reactype).VALUE AND retype = 'I';
        IF v_count <> 0 THEN
            p_err_code := '-561034';
        plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
        RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        --------------------------------------------------------------

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
v_strCustodycd                    NVARCHAR2(100);
v_strAFACCTNO                 NVARCHAR2(100);
v_strREOLDACCTNO           NVARCHAR2(100);
v_strTODATE                       DATE;
v_strFRDATE                        DATE;
v_strRECUSTID                    NVARCHAR2(20);
v_strREROLE                         NVARCHAR2(200);
v_strCustomerID                   NVARCHAR2(20);
v_countRemiser                    NUMBER(20);
V_STRREACCTNO              NVARCHAR2(20);
v_checkDuplicateRole         NUMBER(20);
v_checkTranfer2DG             NUMBER(20);
v_checkRETYPE                   NUMBER(20);
v_checkFutureRetype          NUMBER(20);
v_strREACTYPE                  NVARCHAR2(20);
v_strREOLDCUSTID           NVARCHAR2(20);
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


        --check remast

    plog.error (pkgctx, '<<END OF fn_txPreAppCheck08'||P_TXMSG.TXFIELDS('08').VALUE);
    plog.error (pkgctx, '<<END OF fn_txPreAppCheck07'||P_TXMSG.TXFIELDS('07').VALUE);


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

       V_STRCUSTODYCD := P_TXMSG.TXFIELDS('88').VALUE;
           v_strRECUSTID := P_TXMSG.TXFIELDS('02').VALUE;
          ---- v_strAFACCTNO := P_TXMSG.TXFIELDS('03').VALUE;
           v_strFRDATE := TO_DATE(P_TXMSG.TXFIELDS('05').VALUE,'DD/MM/RRRR');
           v_strTODATE := TO_DATE(P_TXMSG.TXFIELDS('06').VALUE,'DD/MM/RRRR');
           v_strREACTYPE := P_TXMSG.TXFIELDS('07').VALUE;
           v_strREROLE:= P_TXMSG.TXFIELDS('09').VALUE;
           V_STRREACCTNO:= P_TXMSG.TXFIELDS('08').VALUE;

                   --Kiem tra trang thai cua MG
                   SELECT status INTO v_status
                   FROM remast
                   WHERE ACCTNO = V_STRREACCTNO ;
                    IF  NOT ( v_status='A') THEN
                          p_err_code := '-560004';
                          plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
                          RETURN errnums.C_BIZ_RULE_INVALID;
                  END IF;

                      -- Lay  thong tin khach hang
                  SELECT CUSTID
                    INTO V_STRCUSTOMERID
                    FROM CFMAST CF
                   WHERE CF.CUSTODYCD = V_STRCUSTODYCD;
                  ---Ktra thong tin khong duoc khai bao trung
                  --Moi KH chi co 1 ng gioi thieu, , 01 BR hoac 01 AE & RM

                  SELECT COUNT(LNK.AUTOID)
                    INTO V_COUNTREMISER
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
                         AND RFMST.ACCTNO = V_STRREACCTNO
                         AND (  (LNK.FRDATE <= V_STRFRDATE  AND LNK.TODATE >= V_STRFRDATE)
                             OR (LNK.FRDATE <= v_strTODATE AND  lnk.todate >= v_strTODATE ) );

                   IF  ( V_COUNTREMISER > 0) THEN
                          p_err_code := '-561013';
                          plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
                          RETURN errnums.C_BIZ_RULE_INVALID;
                  END IF;

                    --Ktra khong cho phep vua la MG vua la cham soc ho
                   IF v_strREROLE='DG' THEN
                             select count(1)  INTO v_checkDuplicateRole
                             from reaflnk rl , retype rty , recflnk rcl
                              where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                                    and  rl.status='A' and rty.rerole <>'DG' and rl.afacctno= v_strCustomerID
                                    and rcl.custid = v_strRECUSTID;
                            IF  ( v_checkDuplicateRole > 0) THEN
                                p_err_code := '-561020';
                                plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
                                RETURN errnums.C_BIZ_RULE_INVALID;
                             END IF;
                       ELSE
                          select count(1)  INTO v_checkDuplicateRole
                          from reaflnk rl , retype rty , recflnk rcl
                           where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                          and rl.status='A' and rty.rerole ='DG' and rl.afacctno=  v_strCustomerID
                          and rcl.custid = v_strRECUSTID;
                                   IF  ( v_checkDuplicateRole > 0) THEN
                                      p_err_code := '-561020';
                                      plog.setendsection (pkgctx, ' fn_txAftAppCheck ');
                                      RETURN errnums.C_BIZ_RULE_INVALID;
                                   END IF;
                     END IF;



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
v_strCustodycd                    NVARCHAR2(100);
v_strAFACCTNO                 NVARCHAR2(100);
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
         v_strCustodycd := P_TXMSG.TXFIELDS('88').VALUE;
         v_strRECUSTID := P_TXMSG.TXFIELDS('02').VALUE;
        ----- v_strAFACCTNO := P_TXMSG.TXFIELDS('03').VALUE;
         v_strFRDATE :=To_date( P_TXMSG.TXFIELDS('05').VALUE,'DD/MM/RRRR');
         v_strTODATE := to_date(P_TXMSG.TXFIELDS('06').VALUE,'DD/MM/RRRR');
         v_strREACTYPE := P_TXMSG.TXFIELDS('07').VALUE;
         v_strREROLE:= P_TXMSG.TXFIELDS('09').VALUE;
         v_strREACCTNO:= P_TXMSG.TXFIELDS('08').VALUE;
         v_strORGREACCTNO:= P_TXMSG.TXFIELDS('31').VALUE;
         v_strFUREACTYPE:='';


    IF p_txmsg.deltd <> 'Y' THEN
           -- Lay  thong tin khach hang
                  SELECT CUSTID
                    INTO V_STRCUSTOMERID
                    FROM CFMAST CF
                   WHERE CF.CUSTODYCD = v_strCustodycd;
                        --Ktra tinh hop le cua du lieu theo luong NET
                        --Ktra ko duoc trung
                 SELECT COUNT(LNK.AUTOID) INTO V_checkbeforupdate
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
                        (RFTYP.REROLE IN ('BM', 'RM') AND
                        ORGTYP.REROLE IN ('BM', 'RM')))
                    AND RFMST.ACTYPE = RFTYP.ACTYPE
                    AND RFMST.ACCTNO = V_STRREACCTNO
                    AND (  (LNK.FRDATE <= V_STRFRDATE  AND LNK.TODATE >= V_STRFRDATE)
                          OR (LNK.FRDATE <=v_strTODATE AND  lnk.todate >= v_strTODATE  )  );

                           IF  ( V_checkbeforupdate > 0) THEN
                          p_err_code := '-561013';
                          plog.setendsection (pkgctx, ' fn_txAftAppUpdate ');
                          RETURN errnums.C_BIZ_RULE_INVALID;
                             END IF;
                                --Ktra khong cho phep vua la MG vua la cham soc ho
                   IF v_strREROLE='DG' THEN
                             select count(1)  INTO V_checkbeforupdate
                             from reaflnk rl , retype rty , recflnk rcl
                              where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                                    and  rl.status='A' and rty.rerole <>'DG' and rl.afacctno= v_strCustomerID
                                    and rcl.custid = v_strRECUSTID;
                            IF  ( V_checkbeforupdate > 0) THEN
                                p_err_code := '-561020';
                                plog.setendsection (pkgctx, ' fn_txAftAppUpdate ');
                                RETURN errnums.C_BIZ_RULE_INVALID;
                             END IF;
                       ELSE
                          select count(1)  INTO V_checkbeforupdate
                          from reaflnk rl , retype rty , recflnk rcl
                           where substr(rl.reacctno, 11, 4) = rty.actype And rl.refrecflnkid = rcl.autoid
                          and rl.status='A' and rty.rerole ='DG' and rl.afacctno=  v_strCustomerID
                          and rcl.custid = v_strRECUSTID;
                                   IF  ( V_checkbeforupdate > 0) THEN
                                      p_err_code := '-561020';
                                      plog.setendsection (pkgctx, ' fn_txAftAppUpdate ');
                                      RETURN errnums.C_BIZ_RULE_INVALID;
                                   END IF;
                     END IF;


                       If v_strREROLE = 'BM' THEN
                         ---chuyen giua 2 MG ????
                           -- Kiem tra trang thai khach hang co phu hop voi loai hinh moi goi hien tai ko
                                 SELECT count(1)  INTO V_checkbeforupdate
                                             FROM  retype ret, cfmast cf
                                             Where  ret.actype =  v_strREACTYPE
                                              and ret.afstatus = cf.afstatus
                                              and cf.custid =  v_strCustomerID ;
                                IF  ( V_checkbeforupdate = 0) THEN
                                      p_err_code := '-561017';
                                      plog.setendsection (pkgctx, ' fn_txAftAppUpdate ');
                                      RETURN errnums.C_BIZ_RULE_INVALID;
                                   END IF;
                                  --Kiem tra trang thai khach hang co phu hop voi loai hinh moi goi tuong lai ko
                                   SELECT count(1)  INTO V_checkbeforupdate
                                             FROM  retype ret, cfmast cf
                                             Where   ret.actype =  v_strFUREACTYPE
                                              and ret.afstatus <> cf.afstatus
                                              and ret.rerole =  v_strREROLE
                                              and cf.custid =  v_strCustomerID;
                                        IF  ( V_checkbeforupdate = 0) THEN
                                      p_err_code := '-561018';
                                      plog.setendsection (pkgctx, ' fn_txAftAppUpdate ');
                                      RETURN errnums.C_BIZ_RULE_INVALID;
                                   END IF;
                                   --  ' Neu la BRthi insert them thong tin tk moi gioi tuong lai
                                   INSERT INTO REAFLNK (AUTOID, TXDATE, TXNUM, REFRECFLNKID, REACCTNO, AFACCTNO, DELTD, STATUS, FRDATE, TODATE,FUREFRECFLNKID)
                                    SELECT SEQ_REAFLNK.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),  p_txmsg.txnum , r1.AUTOID,
                                       v_strREACCTNO , V_STRCUSTOMERID ,'N','A', TO_DATE( v_strFRDATE , systemnums.C_DATE_FORMAT), TO_DATE( v_strTODATE , systemnums.C_DATE_FORMAT), r2.AUTOID
                                       FROM RECFLNK r1 , RECFLNK r2 WHERE r1.CUSTID= v_strRECUSTID and r2.custid =  v_strFURECUSTID;
                       ELSE

                                           -- 'Neu la RM, RD,AE,DG thi fhi insert thong tin moi gioi hien tai
                                     INSERT INTO REAFLNK (AUTOID, TXDATE, TXNUM, REFRECFLNKID, REACCTNO, AFACCTNO, DELTD, STATUS, FRDATE, TODATE,ORGREACCTNO)
                                          SELECT SEQ_REAFLNK.NEXTVAL, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),  p_txmsg.txnum , RECFLNK.AUTOID,
                                          v_strREACCTNO  , V_STRCUSTOMERID ,'N','A', TO_DATE( v_strFRDATE , systemnums.C_DATE_FORMAT), TO_DATE( v_strTODATE , systemnums.C_DATE_FORMAT) ,  v_strORGREACCTNO
                                          FROM RECFLNK WHERE CUSTID= v_strRECUSTID;
                      END IF        ;
                                            --log
                                            INSERT INTO re_customerchange_log
                                            VALUES (seq_re_customerchange_log.nextval,V_STRCUSTOMERID,NULL, v_strREACCTNO,p_txmsg.txdate,p_txmsg.txnum,p_txmsg.tlid, p_txmsg.offid );
                                            --
            Else
                 UPDATE REAFLNK SET DELTD='Y' WHERE TXDATE=TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND TXNUM=  p_txmsg.txnum ;
                                 --del log
                                 DELETE FROM re_customerchange_log WHERE txdate = p_txmsg.txdate AND txnum = p_txmsg.txnum;
                                 --
            End IF;
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
         plog.init ('TXPKS_#0380EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0380EX;
/
