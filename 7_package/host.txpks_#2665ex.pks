SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2665ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2665EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/02/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2665ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '57';
   c_address          CONSTANT CHAR(2) := '58';
   c_license          CONSTANT CHAR(2) := '59';
   c_groupid          CONSTANT CHAR(2) := '05';
   c_orgamt           CONSTANT CHAR(2) := '06';
   c_dfpaidamt        CONSTANT CHAR(2) := '07';
   c_curamt           CONSTANT CHAR(2) := '08';
   c_curint           CONSTANT CHAR(2) := '09';
   c_curfee           CONSTANT CHAR(2) := '10';
   c_intmin           CONSTANT CHAR(2) := '20';
   c_feemin           CONSTANT CHAR(2) := '21';
   c_tadf             CONSTANT CHAR(2) := '12';
   c_irate            CONSTANT CHAR(2) := '13';
   c_mrate            CONSTANT CHAR(2) := '14';
   c_lrate            CONSTANT CHAR(2) := '15';
   c_sumamt           CONSTANT CHAR(2) := '22';
   c_rttdf            CONSTANT CHAR(2) := '16';
   c_dfblockorg       CONSTANT CHAR(2) := '23';
   c_dfblockamt       CONSTANT CHAR(2) := '17';
   c_ciavlwithdraw    CONSTANT CHAR(2) := '18';
   c_trft0amt         CONSTANT CHAR(2) := '26';
   c_trtfpaid         CONSTANT CHAR(2) := '27';
   c_cipaid           CONSTANT CHAR(2) := '19';
   c_description      CONSTANT CHAR(2) := '30';
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



    --IF to_number(p_txmsg.txfields('17').value + p_txmsg.txfields('19').value + p_txmsg.txfields('27').value) <> to_number(p_txmsg.txfields('22').value) THEN
     IF to_number(p_txmsg.txfields('08').value) <= to_number(p_txmsg.txfields('17').value + p_txmsg.txfields('19').value + p_txmsg.txfields('27').value)
        and to_number(p_txmsg.txfields('17').value + p_txmsg.txfields('19').value + p_txmsg.txfields('27').value) < to_number(p_txmsg.txfields('22').value) THEN

       p_err_code := '-260018';
       plog.error('txfields(22).value' || p_txmsg.txfields('22').value) ;
       plog.error('txfields(17).value' || p_txmsg.txfields('17').value) ;
       plog.error('txfields(19).value' || p_txmsg.txfields('19').value) ;
       plog.error('txfields(27).value' || p_txmsg.txfields('27').value) ;
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
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
l_count number;
l_AMTPAID number;
l_INTPAID number;
l_FEEPAID number;
l_INTPENA number;
l_FEEPENA number;
l_amt   number;
l_INTPAIDMETHOD varchar2(1);
l_nTemp number;
v_strCURRDATE date;
v_strRLSDATE date;
v_groupid varchar2(30);

v_paid number;
v_nml NUMBER;
v_ovd NUMBER;
v_intnmlacr NUMBER;
v_INTOVDPRIN  NUMBER;
v_intovd  NUMBER;
v_intdue  NUMBER;
v_intpaid NUMBER;
v_FEEINTNMLOVD NUMBER;
v_FEEINTOVDACR NUMBER;
v_FEEINTNMLACR NUMBER;
v_FEEDUE NUMBER;
v_feeintpaid NUMBER;
v_LNACCTNO varchar2(20);
l_AFACCTNO varchar2(20);
l_limitchk varchar(20);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    l_amt:=p_txmsg.txfields('17').value + p_txmsg.txfields('19').value + p_txmsg.txfields('27').value;
    v_groupid:= p_txmsg.txfields('05').value ;
    l_AMTPAID:= fn_getamt4grpdeal(v_groupid,l_amt, 0);
    l_INTPAID:= fn_getamt4grpdeal(v_groupid,l_amt, 1);
    l_FEEPAID:= fn_getamt4grpdeal(v_groupid,l_amt, 2);
    l_INTPENA:= fn_getamt4grpdeal(v_groupid,l_amt, 3);
    l_FEEPENA:= fn_getamt4grpdeal(v_groupid,l_amt, 4);

    --- Cap nhap so tien tra goc, phi, lai vao cac bang du lieu
    --- Cap nhap tra no.
    cspks_dfproc.pr_DFPaidDeal(p_txmsg,v_groupid,l_AMTPAID,l_INTPAID,l_FEEPAID,l_INTPENA,l_FEEPENA,p_err_code);

    if p_err_code <> systemnums.C_SUCCESS then
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    SELECT limitchk into l_limitchk FROM DFTYPE WHERE ACTYPE IN (
            SELECT ACTYPE fROM DFGROUP WHERE GROUPID= p_txmsg.txfields('05').value);

    if l_limitchk = 'Y' then
         UPDATE CIMAST SET DFODAMT = DFODAMT - (ROUND(p_txmsg.txfields('34').value,0)) WHERE ACCTNO=p_txmsg.txfields('03').value;

         INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0071',ROUND(p_txmsg.txfields('34').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    end if;

/*
    SELECT INTPAIDMETHOD into l_INTPAIDMETHOD from lnmast where ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

    select ovd+nml into l_nTemp from lnschd where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

    INSERT INTO LNSCHDLOG (AUTOID, TXNUM, TXDATE, OVD, NML, PAID)
                SELECT AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), -least(ovd, l_amtpaid), -least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML),
                    - GREATEST(least(ovd, l_amtpaid), least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML)) from lnschd
                    where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

    ---- UPDATE LNSCHD VA LNMAST
    plog.debug (pkgctx,' HAILT_2648_1 l_AMTPAID: ' || l_AMTPAID || ' GROUPID: ' || v_groupid);
    update lnschd set ovd= ovd - least(ovd, l_amtpaid), nml=nml-least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML),
                    paid=paid+ GREATEST(least(ovd, l_amtpaid), least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML))
                where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

    plog.debug (pkgctx,' END UPDATE LNSCHD l_INTPAIDMETHOD = ' || l_INTPAIDMETHOD || ', l_intpena:   '|| l_intpena || ', l_feepena:  ' || l_feepena);

    if instr('I/P', l_INTPAIDMETHOD ) > 0 then
        plog.debug (pkgctx,' ADD 1');

        SELECT (case when INTOVDPRIN>0 then least((l_intpaid - l_intpena),INTOVDPRIN) else 0 end), (CASE WHEN INTOVD > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD) ELSE 0 END ),
               (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END ), (CASE WHEN INTNMLACR > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD - INTDUE, INTNMLACR ) ELSE 0 END ),
               (CASE WHEN FEEINTNMLOVD > 0 THEN least(l_feepaid - l_feepena,FEEINTNMLOVD ) ELSE 0 END ),(CASE WHEN FEEINTOVDACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD, FEEINTOVDACR ) ELSE 0 END ),
               (CASE WHEN FEEDUE > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR,FEEDUE ) ELSE 0 END ),(CASE WHEN FEEINTNMLACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR - FEEDUE, FEEINTNMLACR ) ELSE 0 END )
        INTO  v_INTOVDPRIN, v_INTOVD, v_INTDUE, v_INTNMLACR, v_FEEINTNMLOVD, v_FEEINTOVDACR, v_FEEDUE, v_FEEINTNMLACR
        FROM LNSCHD
            WHERE reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

        -- INSERT VAO LNSCHDLOG
        UPDATE LNSCHDLOG SET INTOVDPRIN = - v_INTOVDPRIN , INTOVD= -  v_INTOVD,
            INTDUE= - v_INTDUE, INTNMLACR= - v_INTNMLACR, INTPAID= l_intpaid,
            FEEINTOVD =  -  v_FEEINTOVDACR,
            FEEDUE =  - v_FEEDUE, FEEINTNMLACR =  - v_FEEINTNMLACR,
            feeintpaid =  l_feepaid
            WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
        FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid ) );

        update lnschd set
             OVD= OVD -  (CASE WHEN INTOVD > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD) ELSE 0 END ),
             NML= NML - (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END ),
             PAID = PAID + (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END )
       where reftype='I' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );


        update lnschd set INTOVDPRIN = INTOVDPRIN - (case when INTOVDPRIN>0 then least((l_intpaid - l_intpena),INTOVDPRIN) else 0 end) ,
            INTOVD=INTOVD -  (CASE WHEN INTOVD > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN,INTOVD) ELSE 0 END ),
            INTDUE=INTDUE- (CASE WHEN INTDUE > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD, INTDUE) ELSE 0 END ),
            INTNMLACR=INTNMLACR- (CASE WHEN INTNMLACR > 0 THEN least(l_intpaid - l_intpena - INTOVDPRIN - INTOVD - INTDUE, INTNMLACR ) ELSE 0 END ),
            INTPAID=INTPAID + l_intpaid,
            FEEINTNMLOVD = FEEINTNMLOVD - (CASE WHEN FEEINTNMLOVD > 0 THEN least(l_feepaid - l_feepena,FEEINTNMLOVD ) ELSE 0 END ),
            FEEINTOVDACR = FEEINTOVDACR -  (CASE WHEN FEEINTOVDACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD, FEEINTOVDACR ) ELSE 0 END ),
            FEEDUE = FEEDUE - (CASE WHEN FEEDUE > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR,FEEDUE ) ELSE 0 END ),
            FEEINTNMLACR = FEEINTNMLACR - (CASE WHEN FEEINTNMLACR > 0 THEN least(l_feepaid - l_feepena - FEEINTNMLOVD - FEEINTOVDACR - FEEDUE, FEEINTNMLACR ) ELSE 0 END ),
            feeintpaid =  feeintpaid + l_feepaid
        where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

    else
        if round(l_AMTPAID,0) < round(l_nTemp) then
            plog.debug (pkgctx,'l_INTPAIDMETHOD = L, l_intpena:   '|| l_intpena || ', l_feepena:  ' || l_feepena);

            SELECT TO_DATE (varvalue, systemnums.c_date_format)
                INTO v_strCURRDATE
                FROM sysvar
                WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

                select TO_DATE (rlsdate, systemnums.c_date_format) into v_strRLSDATE from lnschd   where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

                if v_strCURRDATE = v_strRLSDATE then

                    UPDATE LNSCHDLOG SET INTNMLACR = l_intpena, FEEINTNMLACR = l_feepena
                                WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                                    FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid ) );

                   -- update lnschd set INTNMLACR = INTNMLACR + l_intpena, FEEINTNMLACR = FEEINTNMLACR + l_feepena where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );
                else
                    select (CASE WHEN INTNMLACR>0 THEN l_intpena ELSE 0 END), (CASE WHEN INTDUE>0 THEN l_intpena ELSE 0 END),
                                   (CASE WHEN FEEINTNMLACR>0 THEN l_feepena ELSE 0 END), (CASE WHEN feedue>0 THEN l_feepena ELSE 0 END)
                            into v_INTNMLACR, v_INTDUE, v_FEEINTNMLACR, v_feedue
                            from lnschd where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );

                    -- INSERT VAO LNSCHDLOG
                     UPDATE LNSCHDLOG SET INTNMLACR = v_INTNMLACR, INTDUE =  v_INTDUE,
                         FEEINTNMLACR = v_FEEINTNMLACR, feedue = v_feedue
                        WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                            FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid ) );


                    --update lnschd set INTNMLACR = INTNMLACR + (CASE WHEN INTNMLACR>0 THEN l_intpena ELSE 0 END),
                    --     INTDUE =  INTDUE + (CASE WHEN INTDUE>0 THEN l_intpena ELSE 0 END),
                    --     FEEINTNMLACR = FEEINTNMLACR +  (CASE WHEN FEEINTNMLACR>0 THEN l_feepena ELSE 0 END),
                    --     feedue = feedue + (CASE WHEN feedue>0 THEN l_feepena ELSE 0 END)
                    --where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );


                end if;

        else
            plog.debug (pkgctx,' ADD 2');
                UPDATE LNSCHDLOG SET INTOVDPRIN = 0 ,
                    INTOVD= 0, INTDUE=0,INTNMLACR=0,INTPAID= l_intpaid,
                    FEEDUE =0,
                    FEEINTNMLACR =0, feeintpaid= l_feepaid
                WHERE (AUTOID, TXNUM, TXDATE) = (SELECT AUTOID, p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR')
                        FROM LNSCHD  where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid ) );

               update lnschd set INTOVDPRIN = 0 ,
                    INTOVD= 0, INTDUE=0,INTNMLACR=0,INTPAID=INTPAID + l_intpaid,
                    FEEINTNMLOVD = 0, FEEINTOVDACR = 0, FEEDUE =0,
                    FEEINTNMLACR =0, feeintpaid=feeintpaid+l_feepaid
                where reftype='P' and ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );
        end if;
    end if;

            SELECT acctno, nvl(paid,0) paid, nvl(nml,0) nml, nvl(ovd,0) ovd, nvl(intnmlacr,0) intnmlacr,
                nvl(INTOVDPRIN,0) INTOVDPRIN, nvl(intovd,0) intovd, nvl(intdue,0) intdue, nvl(intpaid,0) intpaid,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD,
                nvl(FEEINTOVDACR,0) FEEINTOVDACR , nvl(FEEINTNMLACR,0) FEEINTNMLACR, nvl(FEEDUE,0) FEEDUE, nvl(feeintpaid,0) feeintpaid
            into v_LNACCTNO,v_paid, v_nml, v_ovd, v_intnmlacr, v_INTOVDPRIN, v_intovd, v_intdue, v_intpaid, v_FEEINTNMLOVD, v_FEEINTOVDACR, v_FEEINTNMLACR, v_FEEDUE, v_feeintpaid
            FROM LNSCHD WHERE ACCTNO IN (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid ) AND REFTYPE='P' ;


            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0014',v_paid,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0015',v_nml,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0017',v_ovd,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0042',v_intnmlacr,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0043',v_INTOVDPRIN,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0027',v_intovd,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0025',v_intdue,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0023',v_intpaid,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0083',v_FEEINTNMLOVD,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0085',v_FEEINTOVDACR,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0078',v_FEEINTNMLACR,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0081',v_FEEDUE,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

            INSERT INTO LNTRAN (AUTOID,TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,TLTXCD,BKDATE,TRDESC)
            VALUES(SEQ_LNTRAN.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),v_LNACCTNO,'0089',v_feeintpaid,NULL,l_AFACCTNO,'N',l_AFACCTNO,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

    plog.debug (pkgctx,' UPDATE LNMAST ' || v_groupid);
    UPDATE LNMAST SET (prinpaid, prinnml, prinovd, intnmlacr, intovdacr, intnmlovd, intdue, intpaid, feeintnmlovd, feeintovdacr,
        feeintnmlacr, feeintdue, feeintpaid) = (SELECT nvl(paid,0) paid, nvl(nml,0) nml, nvl(ovd,0) ovd, nvl(intnmlacr,0) intnmlacr,
        nvl(INTOVDPRIN,0) INTOVDPRIN, nvl(intovd,0) intovd, nvl(intdue,0) intdue, nvl(intpaid,0) intpaid,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD,
        nvl(FEEINTOVDACR,0) FEEINTOVDACR , nvl(FEEINTNMLACR,0) FEEINTNMLACR, nvl(FEEDUE,0) feeintdue, nvl(feeintpaid,0) feeintpaid FROM LNSCHD WHERE LNMAST.ACCTNO=LNSCHD.ACCTNO AND LNSCHD.REFTYPE='P' ) WHERE LNMAST.ACCTNO IN
            (SELECT LNACCTNO FROM DFGROUP WHERE GROUPID= v_groupid );
*/

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
         plog.init ('TXPKS_#2665EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2665EX;

/
