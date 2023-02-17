SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2655ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2655EX
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


CREATE OR REPLACE PACKAGE BODY txpks_#2655ex
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
v_strDFTYPE varchar2(10);
v_strDEALTYPE varchar2(1);
v_strgroupid  varchar2(30);
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

/*
01  2655    CODEID
03  2655    AFACCTNO
04  2655    ACTYPE
05  2655    ACCTNO
06  2655    DFTYPE
08  2655    MRATE
09  2655    LRATE
12  2655    TRADE
14  2655    IRATE
15  2655    RRTYPE
16  2655    AUTODRAWNDOWN
17  2655    CALLTYPE
18  2655    RLSAMT
19  2655    DEALTYPE
20  2655    GROUPID
21  2655    LNACCTNO
22  2655    BLOCKED
30  2655    DESC
50  2655    RRID
51  2655    CIDRAWNDOWN
52  2655    BANKDRAWNDOWN
53  2655    CMPDRAWNDOWN
57  2655    CUSTNAME
58  2655    ADDRESS
59  2655    LICENSE
88  2655    CUSTODYCD
*/

    v_strDFTYPE:= p_txmsg.txfields('06').VALUE;
    v_strgroupid:=p_txmsg.txfields('20').value;
    v_strDEALTYPE:=p_txmsg.txfields('19').value;

    if v_strDFTYPE <> 'A' then
        if v_strDEALTYPE ='B' AND v_strDFTYPE <>'B'  THEN
            p_err_code := 'Invalid DFTYPE';
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        if (v_strDEALTYPE ='N' or v_strDEALTYPE ='R') AND v_strDFTYPE <>'F'  THEN
            p_err_code := 'Invalid DFTYPE';
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;

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
 v_blnREVERSAL boolean;
    l_lngErrCode    number(20,0);
    v_strgroupid  varchar2(30);
    v_stractype varchar2(10);
    v_strAFACCTNO varchar2(10);
    v_strDEALTYPE varchar2(4);
    v_strAUTODRAWNDOWN number;
    v_strAUTOPAID varchar2(10);
    v_strLIMITCHECK varchar2(10);
    v_strRRTYPE varchar2(10);
    v_strDFTYPE varchar2(10);
    v_strCODEID varchar2(10);
    v_strSEACCTNO varchar2(20);
    v_dblIRATE number;
    v_dblMRATE number;
    v_dblLRATE number;
    v_dblARATE number;
    v_dblALRATE number;
    v_dblORGAMT number;
    v_dblQTTY number;
    v_dblDFRATE number;
    v_dblDFPRICE number;
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
    v_dblRCVQTTY number;
    v_dblBLOCKQTTY number;
    v_dblAVLQTTY NUMBER;
    v_strCUSTBANK varchar2(20);
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
/*
01  2655    CODEID
03  2655    AFACCTNO
04  2655    ACTYPE
05  2655    ACCTNO
06  2655    DFTYPE
08  2655    MRATE
09  2655    LRATE
12  2655    TRADE
14  2655    IRATE
15  2655    RRTYPE
16  2655    AUTODRAWNDOWN
17  2655    CALLTYPE
18  2655    RLSAMT
19  2655    QTTYTYPE
20  2655    GROUPID
21  2655    LNACCTNO
22  2655    BLOCKED
30  2655    DESC
50  2655    RRID
51  2655    CIDRAWNDOWN
52  2655    BANKDRAWNDOWN
53  2655    CMPDRAWNDOWN
57  2655    CUSTNAME
58  2655    ADDRESS
59  2655    LICENSE
88  2655    CUSTODYCD
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
v_dblAVLQTTY:=p_txmsg.txfields('12').value;
--v_dblRCVQTTY :=p_txmsg.txfields('13').value;
v_dblBLOCKQTTY:=p_txmsg.txfields('22').value;
v_strDEALTYPE:=p_txmsg.txfields('19').value;
v_dblDFPRICE :=0;
v_strgroupid:=p_txmsg.txfields('20').value;

          SELECT LNT.RRTYPE,DFT.DFTYPE,LNT.CUSTBANK,LNT.CIACCTNO,DFT.LNTYPE,DFT.FEE,DFT.FEEMIN,DFT.TAX,DFT.AMTMIN,DFT.CISVRFEE, DFT.ARATE, DFT.ALRATE
            into    v_strRRTYPE,v_strDFTYPE,v_strCUSTBANK,v_strCIACCTNO,v_strLNTYPE,v_dblFEE,v_dblFEEMIN,v_dblTAX,v_dblAMTMIN,v_dblCISVRFEE, v_dblARATE, v_dblALRATE
            FROM DFTYPE DFT, LNTYPE LNT WHERE DFT.LNTYPE = LNT.ACTYPE AND DFT.ACTYPE =p_txmsg.txfields('04').value;

   -- LAY SO TAI KHOAN DF
        SELECT SEQ_DFMAST.NEXTVAL DFACCTNO
            into v_strACCTNO
        FROM DUAL;
      v_strACCTNO:=substr('000000' || v_strACCTNO,length('000000' || v_strACCTNO)-5,6);
            v_strACCTNO:=p_txmsg.brid || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),1,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),4,2)
                                  || substr(to_char(p_txmsg.txdate,systemnums.c_date_format),9,2)
                                  || v_strACCTNO;

         plog.debug (pkgctx,'Insert vao cac bien tham so' || v_strDEALTYPE );

        SELECT  DFB.triggerprice ,DFB.calltype,DFB.irate, DFB.mrate,dfb.lrate,dfb.dfprice, DFB.dfrate
            into v_dbltriggerprice ,v_strcalltype ,v_dbldtlirate,v_dbldtlmrate,v_dbldtllrate, v_dblDFPRICE, v_dblDFRATE
        FROM DFTYPE DF,dfbasket dfb,sbsecurities SB
        WHERE DF.basketid = dfb.basketid and df.actype= v_stractype AND  dfb.symbol=SB.symbol AND SB.CODEID =v_strCODEID AND DFB.DEALTYPE=v_strDEALTYPE ;

        --3. Open DFMAST


         plog.debug (pkgctx,'insert vao DFMAST ');

        INSERT INTO DFMAST (
                     ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                     ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                     FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                     TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                     DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                     INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,GROUPID,DEALTYPE,ARATE, ALRATE)
              VALUES
                     ( v_strACCTNO ,v_strAFACCTNO, v_strLNACCTNO, to_date(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, p_txmsg.txtime,
                      v_stractype, v_strRRTYPE, v_strDFTYPE, v_strCUSTBANK,v_strCIACCTNO, v_strLNTYPE,  v_dblFEE ,
                      v_dblFEEMIN ,  v_dblTAX ,  v_dblAMTMIN ,v_strCODEID,  round(v_dblDFPRICE*100/v_dblDFRATE,0) ,  v_dblDFPRICE ,
                      round(v_dblDFPRICE*v_dbldtllrate/v_dblDFRATE,0)  , v_dblDFRATE  , v_dbldtlirate ,v_dbldtlmrate   ,  v_dbldtllrate ,v_strcalltype,
                      v_dblAVLQTTY ,0, v_dblRCVQTTY , v_dblBLOCKQTTY , 0, 0, 0, 0,  v_dblAVLQTTY+v_dblBLOCKQTTY ,
                     0, 0, 0, 'A', '',p_txmsg.txfields('30').value,v_strLIMITCHECK,v_dblCISVRFEE,v_strgroupid,v_strDEALTYPE,v_dblARATE, v_dblALRATE);

/*
           INSERT INTO DFMAST (
                     ACCTNO, AFACCTNO, LNACCTNO, TXDATE, TXNUM, TXTIME,
                     ACTYPE, RRTYPE, DFTYPE, CUSTBANK,CIACCTNO, LNTYPE, FEE,
                     FEEMIN, TAX, AMTMIN, CODEID, REFPRICE, DFPRICE,
                     TRIGGERPRICE, DFRATE, IRATE, MRATE, LRATE, CALLTYPE,
                     DFQTTY, BQTTY,RCVQTTY,BLOCKQTTY,CARCVQTTY, RLSQTTY, DFAMT, RLSAMT, AMT,
                     INTAMTACR, FEEAMT, RLSFEEAMT, STATUS, DFREF,DESCRIPTION,LIMITCHK,CISVRFEE,GROUPID,DEALTYPE)
              VALUES
                     ( v_strACCTNO ,v_strAFACCTNO, v_strLNACCTNO, to_date(p_txmsg.txdate,systemnums.c_date_format), p_txmsg.txnum, p_txmsg.txtime,
                      v_stractype, v_strRRTYPE, v_strDFTYPE, v_strCUSTBANK,v_strCIACCTNO, v_strLNTYPE,  v_dblFEE ,
                      v_dblFEEMIN ,  v_dblTAX ,  v_dblAMTMIN ,v_strCODEID,  0 ,  0 ,
                     0  , 0  , v_dblIRATE ,v_dblmrate   ,  v_dblLRATE ,v_strcalltype,
                      v_dblAVLQTTY ,0, v_dblRCVQTTY , v_dblBLOCKQTTY , 0, 0, 0, 0,  0 ,
                     0, 0, 0, 'A', '',p_txmsg.txfields('30').value,v_strLIMITCHECK,v_dblCISVRFEE,v_strgroupid,v_strDEALTYPE);

*/
             plog.debug (pkgctx,'UPDATE DFGROUP ');

    UPDATE DFGROUP SET ORGAMT=v_dblDFPRICE * (v_dblAVLQTTY+v_dblBLOCKQTTY) WHERE GROUPID=v_strgroupid;

    IF v_strDEALTYPE='N' then
        UPDATE SEMAST SET TRADE = TRADE-(v_dblAVLQTTY+v_dblBLOCKQTTY), MORTAGE=MORTAGE+(v_dblAVLQTTY+v_dblBLOCKQTTY) WHERE ACCTNO=v_strSEACCTNO;
    elsif v_strDEALTYPE='B' then
        UPDATE SEMAST SET BLOCKED = BLOCKED-(v_dblAVLQTTY+v_dblBLOCKQTTY), MORTAGE=MORTAGE+(v_dblAVLQTTY+v_dblBLOCKQTTY) WHERE ACCTNO=v_strSEACCTNO;
    elsif v_strDEALTYPE='R' then
        UPDATE DFMAST SET RCVQTTY = RCVQTTY + (v_dblAVLQTTY+v_dblBLOCKQTTY) WHERE ACCTNO=v_strACCTNO AND GROUPID=v_strgroupid;
    elsif v_strDEALTYPE='P' then
        UPDATE DFMAST SET CARCVQTTY = CARCVQTTY + (v_dblAVLQTTY+v_dblBLOCKQTTY) WHERE ACCTNO=v_strACCTNO  AND GROUPID=v_strgroupid;
    end if;

    update securities_info
    set syroomused = syroomused + (v_dblAVLQTTY+v_dblBLOCKQTTY)
    where codeid = v_strCODEID;


    plog.debug (pkgctx, 'NAMTEST04');
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
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
         plog.init ('TXPKS_#2655EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2655EX;

/
