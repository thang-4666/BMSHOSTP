SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2652ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2652EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      17/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2652ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_groupid          CONSTANT CHAR(2) := '20';
   c_lnacctno         CONSTANT CHAR(2) := '21';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '57';
   c_address          CONSTANT CHAR(2) := '58';
   c_license          CONSTANT CHAR(2) := '59';
   c_trade            CONSTANT CHAR(2) := '13';
   c_blocked          CONSTANT CHAR(2) := '23';
   c_qttytype         CONSTANT CHAR(2) := '19';
   c_limitcheck       CONSTANT CHAR(2) := '99';
   c_rrtype           CONSTANT CHAR(2) := '15';
   c_actype           CONSTANT CHAR(2) := '04';
   c_dftype           CONSTANT CHAR(2) := '06';
   c_irate            CONSTANT CHAR(2) := '14';
   c_mrate            CONSTANT CHAR(2) := '08';
   c_lrate            CONSTANT CHAR(2) := '09';
   c_rlsamt           CONSTANT CHAR(2) := '18';
   c_calltype         CONSTANT CHAR(2) := '17';
   c_autodrawndown    CONSTANT CHAR(2) := '16';
   c_cidrawndown      CONSTANT CHAR(2) := '51';
   c_bankdrawndown    CONSTANT CHAR(2) := '52';
   c_cmpdrawndown     CONSTANT CHAR(2) := '53';
   c_rrid             CONSTANT CHAR(2) := '50';
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
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_qtty number;
i number;
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
 v_blnREVERSAL boolean;
    l_lngErrCode    number(20,0);
    l_count number;
    v_strgroupid  varchar2(30);
    v_stractype varchar2(10);
    v_strAFACCTNO varchar2(10);
    v_strAUTODRAWNDOWN number;
    v_strAUTOPAID varchar2(10);
    v_strLIMITCHECK varchar2(10);
    v_strRRTYPE varchar2(10);
    v_strDFTYPE varchar2(10);
    v_strCODEID varchar2(10);
    v_strSEACCTNO varchar2(20);
    v_tmpDFACCTNO varchar2(20);
    v_strDEALTYPE varchar2(1);
    v_dblIRATE number;
    v_dblMRATE number;
    v_dblLRATE number;
    v_dblARATE number;
    v_dblALRATE number;
    v_dbDFRATE NUMBER;
    v_dblORGAMT number;
    v_dblDFRATE number;
    v_dblDFPRICE number;
    v_dblBASICPRICE number;
    v_dblAMT number;
    v_strRRID varchar2(20);
    v_strSTATUS varchar2(2) ;
    v_strACCTNO varchar2(20);
    v_strdec varchar(500);
    v_DBLCOUNTdfgropid  varchar2(20);
    v_strLNACCTNO  varchar2(20);
    v_strLNTYPE varchar2(20);
    v_strORDERID varchar2(20);
    v_dblCISVRFEE number;
    v_dblAMTMIN number;
    v_dblTAX number;
    v_dblFEEMIN number;
    v_dblFEE number;
    v_dblQTTY number;
    v_dblCARCVQTTY number;
    v_dblCACASHQTTY number;
    v_dblRCVQTTY number;
    v_dblBLOCKQTTY number;
    v_dblAVLQTTY NUMBER;
    v_strCUSTBANK varchar2(20);
    v_strREFID varchar2(50);
    v_strCIACCTNO varchar2(20);
    v_dblRemainRCVQTTY number(20,4);
    v_dblExecRCVQTTY number(20,4);
    v_dblReleaseAMT number(20,4);
    v_dbltriggerprice number(20,4);
    v_strcalltype varchar2(20);
    v_dbldtlirate  number(20,4);
    v_dbldtlmrate  number(20,4);
    v_dbldtllrate  number(20,4);
    v_strAFACCTNODRD varchar2(20);
    v_strDFREF varchar2(50);
/*
01  2652    CODEID
03  2652    AFACCTNO
04  2652    ACTYPE
05  2652    ACCTNO
06  2652    DFTYPE
08  2652    MRATE
09  2652    LRATE
12  2652    TRADE
14  2652    IRATE
15  2652    RRTYPE
16  2652    AUTODRAWNDOWN
17  2652    CALLTYPE
18  2652    RLSAMT
19  2652    QTTYTYPE
20  2652    GROUPID
21  2652    LNACCTNO
22  2652    BLOCKED
30  2652    DESC
50  2652    RRID
51  2652    CIDRAWNDOWN
52  2652    BANKDRAWNDOWN
53  2652    CMPDRAWNDOWN
57  2652    CUSTNAME
58  2652    ADDRESS
59  2652    LICENSE
88  2652    CUSTODYC
*/
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

v_strAFACCTNO:= p_txmsg.txfields('03').VALUE;
v_strLNACCTNO:= p_txmsg.txfields('21').VALUE;
v_stractype:= p_txmsg.txfields('04').VALUE;
v_strRRTYPE:= p_txmsg.txfields('15').VALUE;
v_strDFTYPE:= p_txmsg.txfields('06').VALUE;
v_strCODEID:=p_txmsg.txfields('01').value;
v_strSEACCTNO:=p_txmsg.txfields('05').value;
v_dblIRATE:=p_txmsg.txfields('14').value;
v_dblMRATE:=p_txmsg.txfields('08').value;
v_dblLRATE:=p_txmsg.txfields('09').value;
v_dbDFRATE:=p_txmsg.txfields('10').value;
v_dblAVLQTTY:=p_txmsg.txfields('12').value;
v_dblRCVQTTY :=0;
v_dblBLOCKQTTY:=p_txmsg.txfields('22').value;
v_dblDFPRICE :=0;
v_strgroupid:=p_txmsg.txfields('20').value;

v_strDEALTYPE:=p_txmsg.txfields('55').value;
v_dblQTTY:=p_txmsg.txfields('75').value;
    plog.debug (pkgctx, '<<2652 1' || v_dblQTTY);

v_dblCARCVQTTY:=0;
v_dblRCVQTTY:=0;
v_dblAVLQTTY:=0;
v_dblBLOCKQTTY:=0;
v_dblCACASHQTTY:=0;

if v_strDEALTYPE='N'then
    v_dblAVLQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='T'then
    v_dblCACASHQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='B' then
    v_dblBLOCKQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='R' then
    v_dblRCVQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='P' then
    v_dblCARCVQTTY:=v_dblQTTY;
end if;

        IF LENGTH(NVL(p_txmsg.txfields('56').value,''))> 0 THEN
            v_strDFREF:=p_txmsg.txfields('56').value;
        else
            v_strDFREF:='A';
        end if;

        SELECT COUNT(*) into l_count FROM DFMAST WHERE nvl(DFREF,'A') = v_strDFREF AND DFRATE = v_dbDFRATE and groupid=p_txmsg.txfields('20').value AND CODEID =p_txmsg.txfields('01').value;

        plog.debug (pkgctx, '<<2652 1 v_strDFREF' || v_strDFREF );

        if l_count >0 then
            SELECT MAX(ACCTNO) INTO v_tmpDFACCTNO FROM DFMAST WHERE nvl(DFREF,'A') = v_strDFREF AND DFRATE = v_dbDFRATE and groupid=p_txmsg.txfields('20').value AND CODEID =p_txmsg.txfields('01').value;

            plog.debug (pkgctx, '<<2652 1 v_tmpDFACCTNO' || v_tmpDFACCTNO );

            UPDATE DFMAST SET DFQTTY=DFQTTY+ v_dblAVLQTTY, RCVQTTY = RCVQTTY + v_dblRCVQTTY, BLOCKQTTY = BLOCKQTTY + v_dblBLOCKQTTY,
                CARCVQTTY = CARCVQTTY + v_dblCARCVQTTY, CACASHQTTY = CACASHQTTY + v_dblCACASHQTTY  WHERE acctno = v_tmpDFACCTNO;

            update dfmast set ADDASSETQTTY =  ADDASSETQTTY + v_dblQTTY where acctno = v_tmpDFACCTNO;

        else

            SELECT RRTYPE,DFTYPE,CUSTBANK,CIACCTNO,LNTYPE,FEE,FEEMIN,TAX,AMTMIN,CISVRFEE, ARATE, ALRATE
                    into    v_strRRTYPE,v_strDFTYPE,v_strCUSTBANK,v_strCIACCTNO,v_strLNTYPE,v_dblFEE,v_dblFEEMIN,v_dblTAX,v_dblAMTMIN,v_dblCISVRFEE,v_dblARATE, v_dblALRATE
                    FROM DFTYPE WHERE ACTYPE =p_txmsg.txfields('04').value;

            SELECT SEQ_DFMAST.NEXTVAL DFACCTNO
                    into v_strACCTNO
                FROM DUAL;

            -- LAY SO TAI KHOAN DF
            v_strACCTNO:=substr('000000' || v_strACCTNO,length('000000' || v_strACCTNO)-5,6);
            v_strACCTNO:=substr(v_strSEACCTNO,1,4) || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),1,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),4,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),9,2)
                                  || v_strACCTNO;

            plog.debug (pkgctx, '<<2652 2 SEQ_DFMAST' || v_strACCTNO );

            SELECT sec.DFREFPRICE BASICPRICE, SEC.DFREFPRICE * DFB.DFRATE/100, DFB.DFRATE into v_dblBASICPRICE, v_dblDFPRICE, v_dblDFRATE FROM
                securities_info SEC, DFBASKET DFB , dftype df WHERE SEC.CODEID=v_strCODEID AND DF.BASKETID=DFB.BASKETID AND DF.ACTYPE=v_stractype AND
                    SEC.SYMBOL=DFB.SYMBOL AND DFB.DEALTYPE=v_strDEALTYPE;

            INSERT INTO DFMAST (
                 ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                 ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                 FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                 TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE,
                 DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                 INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,CISVRFEE,GROUPID,CALLTYPE,LIMITCHK,DEALTYPE,CACASHQTTY,ADDASSETQTTY, ARATE, ALRATE)
            VALUES
                 ( v_strACCTNO ,v_strAFACCTNO, v_strLNACCTNO, to_date(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, p_txmsg.txtime,
                  v_stractype, v_strRRTYPE, v_strDFTYPE, v_strCUSTBANK,v_strCIACCTNO, v_strLNTYPE,  v_dblFEE ,
                  v_dblFEEMIN ,  v_dblTAX ,  v_dblAMTMIN ,v_strCODEID,  v_dblBASICPRICE ,  v_dblDFPRICE ,
                 0  , v_dblDFRATE  , v_dblIRATE ,v_dblmrate   ,  v_dblLRATE ,
                  v_dblAVLQTTY ,0, v_dblRCVQTTY , v_dblBLOCKQTTY , v_dblCARCVQTTY, 0, 0, 0, p_txmsg.txfields('71').value * (v_dblAVLQTTY + v_dblRCVQTTY + v_dblBLOCKQTTY + v_dblCARCVQTTY + v_dblCACASHQTTY )  ,
                 0, 0, 0, 'A', p_txmsg.txfields('56').value,p_txmsg.txfields('30').value,v_dblCISVRFEE,v_strgroupid,p_txmsg.txfields('17').value,p_txmsg.txfields('99').value,v_strDEALTYPE,v_dblCACASHQTTY,v_dblQTTY,v_dblARATE, v_dblALRATE);

        end if;



        plog.debug (pkgctx, '2652HAILT: ' || p_txmsg.txfields('56').value || ' v_dblExecRCVQTTY: ' || v_dblExecRCVQTTY );

        --- Chung khoan cho ve
        IF v_dblRCVQTTY >0 then
            v_dblRemainRCVQTTY:= v_dblRCVQTTY;
            v_dblExecRCVQTTY:=0;
            v_dblReleaseAMT:=0;
            FOR rec_rcvdf IN
            (
                SELECT * FROM stschd
                WHERE qtty - aqtty > 0 and (to_char(txdate,'DD/MM/YYYY') || afacctno || codeid || to_char(clearday)) = p_txmsg.txfields('56').value
                    AND DUETYPE='RS' and status <> 'C' AND deltd <> 'Y'
                order BY autoid
            )
            LOOP
                v_dblExecRCVQTTY:= least(v_dblRemainRCVQTTY, rec_rcvdf.QTTY - rec_rcvdf.AQTTY);

                update odmast set dfqtty = dfqtty + v_dblExecRCVQTTY where orderid = rec_rcvdf.ORGORDERID;
                update stschd set aqtty = aqtty + v_dblExecRCVQTTY where autoid = rec_rcvdf.autoid;

                INSERT INTO stdfmap (stschdid, dfacctno, dfqtty, rlsamt,status, deltd, txdate,adfqtty)
                     VALUES(rec_rcvdf.AUTOID,v_strACCTNO,v_dblExecRCVQTTY,
                     0,'A','N',to_date(p_txmsg.txdate,'DD/MM/RRRR'),v_dblExecRCVQTTY);

                v_dblReleaseAMT:= 0;
                v_dblRemainRCVQTTY:= v_dblRemainRCVQTTY - v_dblExecRCVQTTY;
                If v_dblRemainRCVQTTY = 0 Then
                    EXIT;
                End IF;
            END LOOP;
        end if;
            plog.debug (pkgctx, 'AUTOID: ' || p_txmsg.txfields('56').value || ' v_dblCARCVQTTY: ' || v_dblCARCVQTTY );
        -- Chung khoan quyen cho ve
        If v_dblCARCVQTTY > 0 Then
            UPDATE CASCHD SET DFQTTY= DFQTTY + v_dblCARCVQTTY WHERE autoid=p_txmsg.txfields('56').value;
        End If;

        plog.debug (pkgctx, 'HaiLT TEST01 receiving:  ' || v_dblCARCVQTTY || ' ' || v_strAFACCTNO);

        If v_dblCACASHQTTY > 0 Then
            UPDATE caschd set dfamt= dfamt + v_dblCACASHQTTY where autoid=p_txmsg.txfields('56').value;
            UPDATE CIMAST set receiving= receiving - v_dblCACASHQTTY where ACCTNO=v_strAFACCTNO;
        END IF;


    plog.debug (pkgctx, 'NAMTEST04');
    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.debug(pkgctx,'2652# fn_txPreAppUpdate: ' || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_txdesc VARCHAR2(1000);
v_strDEALTYPE  VARCHAR2(1);
v_dblQTTY number;
v_dblAVLQTTY number;
v_dblBLOCKQTTY number;
v_dblRCVQTTY number;
v_dblCARCVQTTY number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/


v_strDEALTYPE:=p_txmsg.txfields('55').value;
v_dblQTTY:=p_txmsg.txfields('75').value;
    plog.debug (pkgctx, '<<2652 1');

v_dblAVLQTTY:= 0;
v_dblBLOCKQTTY := 0;
v_dblRCVQTTY:= 0;
v_dblCARCVQTTY:= 0;

if v_strDEALTYPE='N'then
    v_dblAVLQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='B' then
    v_dblBLOCKQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='R' then
    v_dblRCVQTTY:=v_dblQTTY;
end if;
if v_strDEALTYPE='P' then
    v_dblCARCVQTTY:=v_dblQTTY;
end if;


   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(v_dblAVLQTTY,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0044',ROUND(v_dblBLOCKQTTY,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0065',ROUND(v_dblAVLQTTY+v_dblBLOCKQTTY,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



      UPDATE SEMAST
         SET
           BLOCKED = BLOCKED - (ROUND(v_dblBLOCKQTTY,0)),
           MORTAGE = MORTAGE + (ROUND(v_dblAVLQTTY+v_dblBLOCKQTTY,0)),
           TRADE = TRADE - (ROUND(v_dblAVLQTTY,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;



   ELSE -- Reversal

      UPDATE SETRAN SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);

      UPDATE SEMAST
      SET

           BLOCKED = BLOCKED + (ROUND(v_dblBLOCKQTTY,0)),
           MORTAGE = MORTAGE - (ROUND(v_dblAVLQTTY+v_dblBLOCKQTTY,0)),
           TRADE = TRADE + (ROUND(v_dblAVLQTTY,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;


   END IF;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
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
         plog.init ('TXPKS_#2652EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2652EX;

/
