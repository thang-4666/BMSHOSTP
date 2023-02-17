SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_tdproc
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
FUNCTION fn_CheckTDWithdraw(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_TermDeposit2BuyingPower(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_OpenTermDeposit(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_CheckIfOverUnmortgage(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_tdproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------fn_CheckTDWithdraw-------------------------------------
FUNCTION fn_CheckTDWithdraw(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_tdacctno varchar2(30);
    v_txdate date;
    v_DD number;
    v_WW number;
    v_MM number;
    v_frdate date;
    v_todate date;
    v_termcd char(1);
    v_tdterm number;
    v_breakcd char(1);
    v_minbrterm number;
    v_rndno char(1);
    v_count number;
    v_crrterm number;
    V_STRACTYPE VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_CheckTDWithdraw');
    plog.debug (pkgctx, '<<BEGIN OF fn_CheckTDWithdraw');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    p_err_code:=0;
    l_tdacctno := p_txmsg.txfields('03').value;
    v_txdate := p_txmsg.txdate;
    v_blnREVERSAL := CASE WHEN p_txmsg.deltd ='Y' THEN TRUE ELSE FALSE END;
    v_count :=1;
   IF NOT v_blnREVERSAL THEN
       BEGIN
           SELECT TO_NUMBER(v_txdate - FRDATE) DD, FLOOR(v_txdate - FRDATE)/7 WW,
           FLOOR(MONTHS_BETWEEN(v_txdate ,FRDATE)) MM, FRDATE, TODATE, TERMCD,
           TDTERM, BREAKCD, MINBRTERM,RNDNO, actype
           INTO v_DD, v_WW, v_MM, v_frdate, v_todate, v_termcd,v_tdterm, v_breakcd, v_minbrterm, v_rndno, V_STRACTYPE
           FROM TDMAST
           WHERE ACCTNO=l_tdacctno;
       EXCEPTION
         WHEN OTHERS THEN
           v_count := 0;
       END;
       IF v_count > 0 THEN
          IF v_breakcd ='N' AND v_todate >= v_txdate AND v_rndno=0 THEN
             p_err_code:= '-570011';
             plog.setendsection (pkgctx, 'fn_CheckTDWithdraw');
             RETURN errnums.C_BIZ_RULE_INVALID;
          ELSIF v_breakcd='Y' THEN
             IF v_termcd = 'D' THEN
                v_crrterm := v_DD;
             ELSIF v_termcd ='M' THEN
                v_crrterm := v_MM;
             ELSIF v_termcd ='W' THEN
                v_crrterm :=v_WW;
             END IF;
             IF v_minbrterm > v_crrterm THEN
             --DOI VOI MON GUI TUONG LAI KHONG CHECK.
                IF v_frdate <= GETCURRDATE THEN
                    p_err_code :='-570011';
                    plog.setendsection (pkgctx, 'fn_CheckTDWithdraw');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
             END IF;
          END IF;
       END IF;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_CheckTDWithdraw');
    plog.setendsection (pkgctx, 'fn_CheckTDWithdraw');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckTDWithdraw');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_CheckTDWithdraw;
---------------------------fn_TermDeposit2BuyingPower-------------------------------------
FUNCTION fn_TermDeposit2BuyingPower(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_tdacctno varchar2(30);
    l_afacctno varchar2(30);
    l_amt number;
    l_ingramt number;
    v_DORC char(1);
    v_tltxcd varchar2(10);
    v_count number;
    v_gramt number;
    v_txdate date;
    v_txnum varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_TermDeposit2BuyingPower');
    plog.debug (pkgctx, '<<BEGIN OF fn_TermDeposit2BuyingPower');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    p_err_code:=0;
    l_tdacctno := p_txmsg.txfields('03').value;
    l_afacctno := p_txmsg.txfields('05').value;
    l_amt := p_txmsg.txfields('10').value;
    /*l_ingramt := p_txmsg.txfields('15').value;*/
    v_tltxcd := p_txmsg.tltxcd;
    v_txdate := p_txmsg.txdate;
    v_txnum :=p_txmsg.txnum;
    l_ingramt :=0;
    v_blnREVERSAL := CASE WHEN p_txmsg.deltd ='Y' THEN TRUE ELSE FALSE END;
    IF v_tltxcd ='1600' OR v_tltxcd='1620' THEN
       l_ingramt := p_txmsg.txfields('15').value;
    END IF;
    IF v_tltxcd ='1600' OR v_tltxcd='1620' OR v_tltxcd='1678' THEN
       v_DORC := 'D';
    ELSIF v_tltxcd ='1677' THEN
       v_DORC :='C';
    END IF;
    IF NOT v_blnREVERSAL THEN
    plog.debug(pkgctx,'v_DORC --->' || v_DORC);
           IF v_DORC = 'D' THEN
              IF v_tltxcd ='1678' THEN
                  v_count :=1;
                  BEGIN
                       SELECT NVL(SUM(CASE WHEN DORC='C' THEN AMT ELSE -AMT END),0) GRAMT
                       INTO v_gramt
                       FROM TDLINK WHERE DELTD<>'Y' AND ACCTNO=l_tdacctno AND AFACCTNO=l_afacctno;
                  EXCEPTION
                  WHEN OTHERS THEN
                       v_count := 0;
                  END;
                  plog.debug(pkgctx,'v_count --->' || v_count);
                  IF v_count =0 THEN
                     p_err_code:='-570007';
                     plog.setendsection (pkgctx, 'fn_TermDeposit2BuyingPower');
                     RETURN errnums.C_BIZ_RULE_INVALID;
                  END IF;
                  IF v_gramt < l_amt - l_ingramt THEN
                     p_err_code:='-570007';
                     plog.setendsection (pkgctx, 'fn_TermDeposit2BuyingPower');
                     RETURN errnums.C_BIZ_RULE_INVALID;
                  END IF;
              END IF;
           END IF;
           INSERT INTO TDLINK (TXDATE, TXNUM, AFACCTNO, ACCTNO, DORC, DELTD, AMT)
                  VALUES (v_txdate, v_txnum, l_afacctno, l_tdacctno, v_DORC,'N', l_amt - l_ingramt);
           IF v_DORC = 'C' THEN
              UPDATE AFMAST
              SET MRCRLIMIT = MRCRLIMIT + l_amt - l_ingramt
              WHERE ACCTNO = l_afacctno;
           END IF;
           IF v_DORC = 'D' THEN
              UPDATE AFMAST
              SET MRCRLIMIT = MRCRLIMIT - (l_amt - l_ingramt) WHERE ACCTNO = l_afacctno;
           END IF;
    ELSE
           UPDATE TDLINK SET DELTD='Y' WHERE TXDATE=v_txdate AND TXNUM=v_txnum;

           IF v_DORC = 'C' THEN
              UPDATE AFMAST
              SET MRCRLIMIT = MRCRLIMIT - (l_amt - l_ingramt)
              WHERE ACCTNO =l_afacctno;
           END IF;
           IF v_DORC = 'D' THEN
              UPDATE AFMAST
              SET MRCRLIMIT = MRCRLIMIT + l_amt - l_ingramt
              WHERE ACCTNO = l_afacctno;
           END IF;
    END IF;
    plog.debug (pkgctx, '<<END OF fn_TermDeposit2BuyingPower');
    plog.setendsection (pkgctx, 'fn_TermDeposit2BuyingPower');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_TermDeposit2BuyingPower');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_TermDeposit2BuyingPower;
---------------------------fn_OpenTermDeposit-------------------------------------
FUNCTION fn_OpenTermDeposit(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_afacctno varchar2(30);
    l_actype varchar2(4);
    l_amt number;
    l_mstrate number(20,4);
    l_mstterm number(20,4);
    l_desc varchar2(2000);
    v_count number;

    v_txnum varchar2(30);
    v_busdate date;
    v_txdate date;
    v_opdate date;
    v_frmdate date;
    v_todate date;
    v_fmdate varchar2(10);
    v_acctno varchar2(30);
    v_mortage number;
    v_tlid varchar2(10);
    v_offid varchar2(10);
    v_actype       tdtype.actype%TYPE;
    v_tdtype       tdtype.tdtype%TYPE;
    v_tdsrc        tdtype.tdsrc%TYPE;
    v_ciacctno     tdtype.ciacctno%TYPE;
    v_custid       tdtype.custid%TYPE;
    v_termcd       tdtype.termcd%TYPE;
    v_tdterm       tdtype.tdterm%TYPE;
    v_autopaid     tdtype.autopaid%TYPE;
    v_minamt       tdtype.minamt%TYPE;
    v_taxrate      tdtype.taxrate%TYPE;
    v_bonusrate    tdtype.bonusrate%TYPE;
    v_tpr          tdtype.tpr%TYPE;
    v_schdtype     tdtype.schdtype%TYPE;
    v_inttype      tdtype.inttype%TYPE;
    v_refintcd     tdtype.refintcd%TYPE;
    v_refintgap    tdtype.refintgap%TYPE;
    v_intrate      tdtype.intrate%TYPE;
    v_breakcd      tdtype.breakcd%TYPE;
    v_minbrterm    tdtype.minbrterm%TYPE;
    v_inttypbrcd   tdtype.inttypbrcd%TYPE;
    v_flintrate    tdtype.flintrate%TYPE;
    v_buyingpower  tdtype.buyingpower%TYPE;
    v_autornd      tdtype.autornd%TYPE;
    v_EXISTSVAL    NUMBER;
    v_intduecd     tdtype.intduecd%TYPE;

    v_odintrate    tdtype.odintrate%TYPE;
    v_odmaxmortgage tdtype.odmaxmortgage%TYPE;
    l_txdesc VARCHAR2(1000);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_OpenTermDeposit');
    plog.debug (pkgctx, '<<BEGIN OF fn_OpenTermDeposit');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    p_err_code:=0;
    v_blnREVERSAL := CASE WHEN p_txmsg.deltd ='Y' THEN TRUE ELSE FALSE END;
    l_afacctno := p_txmsg.txfields('03').value;
    l_actype := p_txmsg.txfields('81').value;
    l_amt := p_txmsg.txfields('10').value;
    l_mstrate := p_txmsg.txfields('11').value;
    l_mstterm := p_txmsg.txfields('12').value;
    l_desc := p_txmsg.txfields('30').value;
    v_busdate := p_txmsg.busdate;
    v_txdate := p_txmsg.txdate;
    v_txnum := p_txmsg.txnum;
    v_tlid := p_txmsg.tlid;
    v_offid := p_txmsg.offid;
      v_buyingpower:= p_txmsg.txfields('15').value;
    IF NOT v_blnREVERSAL THEN
       --Lay Thong Tin Loai Hinh
       v_count := 1;
       BEGIN
            SELECT TYP.ACTYPE, TYP.TDTYPE, TYP.TDSRC, TYP.CIACCTNO, TYP.CUSTID,
                   TYP.TERMCD, TYP.TDTERM, TYP.AUTOPAID, TYP.MINAMT, TYP.TAXRATE,
                   TYP.BONUSRATE, TYP.TPR, TYP.SCHDTYPE, TYP.INTTYPE, TYP.REFINTCD,
                   TYP.REFINTGAP, TYP.INTRATE, TYP.BREAKCD, TYP.MINBRTERM, TYP.INTTYPBRCD,
                   TYP.FLINTRATE,  TYP.AUTORND, typ.intduecd,
                   typ.odintrate, typ.odmaxmortgage
            INTO   v_actype, v_tdtype, v_tdsrc, v_ciacctno, v_custid, v_termcd, v_tdterm, v_autopaid,
                   v_minamt, v_taxrate, v_bonusrate, v_tpr, v_schdtype, v_inttype, v_refintcd, v_refintgap,
                   v_intrate, v_breakcd, v_minbrterm, v_inttypbrcd, v_flintrate, v_autornd,v_intduecd,
                   v_odintrate,v_odmaxmortgage
            FROM TDTYPE TYP
            WHERE TYP.ACTYPE=l_actype
                  AND TYP.EFFDATE<=v_busdate
                  AND TYP.EXPDATE>= v_busdate;
       EXCEPTION
         WHEN OTHERS THEN
            v_count := 0;
       END;
       IF v_count = 0 THEN
          p_err_code := '-570002';
          plog.setendsection (pkgctx, 'fn_OpenTermDeposit');
          RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;
       -- check neu ko cho rut tu truoc han thi ko duoc tu dong cong vao suc mua
       v_buyingpower:= p_txmsg.txfields('15').value;
       IF (v_buyingpower='Y' AND v_breakcd='N')THEN
          p_err_code := '-570013';
          plog.setendsection (pkgctx, 'fn_OpenTermDeposit');
          RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;
       --check so du toi thieu
       IF l_amt < v_minamt THEN
          p_err_code := '-570003';
          plog.setendsection (pkgctx, 'fn_OpenTermDeposit');
          RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;
       --end check
       v_fmdate := TO_CHAR(v_txdate,'DDMMYYYY');
       v_acctno := SUBSTR(l_afacctno,0,4) || SUBSTR(v_fmdate,0,4) || v_txnum;
       v_opdate := v_txdate;
       v_frmdate := v_busdate;

       IF v_termcd ='D' THEN
          v_todate := v_busdate + l_mstterm;
          plog.debug(pkgctx,'fn_OpenTermDeposit v_todate  -->' ||v_todate);
       ELSIF v_termcd ='W' THEN
          v_todate := v_busdate + l_mstterm * 7;
          plog.debug(pkgctx,'fn_OpenTermDeposit v_todate  -->' ||v_todate);
       ELSIF v_termcd ='M' THEN
          v_todate := TO_DATE(ADD_MONTHS(v_busdate, l_mstterm),'DD/MM/YYYY');
          plog.debug(pkgctx,'fn_OpenTermDeposit v_todate  -->' ||v_todate);
       END IF;
       --Luu bang phi bac thang
       IF v_schdtype <> 'F' THEN
          INSERT INTO TDMSTSCHM (REFAUTOID, ACCTNO, INTRATE, FRAMT, TOAMT, FRTERM, TOTERM)
                      SELECT AUTOID, v_acctno, INTRATE, FRAMT, TOAMT, FRTERM, TOTERM
                      FROM TDTYPSCHM WHERE ACTYPE=l_actype;
       END IF;
       plog.debug(pkgctx,'fn_OpenTermDeposit ManhTV01 ');
       --Bao dam tu dong tang suc mua thi cap nhat vao bang
       IF v_buyingpower = 'Y' THEN
          v_mortage := l_amt;
          INSERT INTO TDLINK (TXDATE, TXNUM, AFACCTNO, ACCTNO, DORC, DELTD, AMT)
                 VALUES (v_txdate, v_txnum,l_afacctno,v_acctno,'C','N',l_amt);

          UPDATE AFMAST
          SET MRCRLIMIT = MRCRLIMIT + l_amt
          WHERE ACCTNO = l_afacctno;
       ELSE
          v_mortage := 0;
       END IF;
       --Ghi vao TDMAST
       v_tdterm := l_mstterm;
       v_intrate := l_mstrate;
       INSERT INTO TDMAST (TXDATE, TXNUM, AFACCTNO, ACCTNO, ACTYPE, STATUS, CIACCTNO, CUSTBANK, TDSRC, TDTYPE, ORGAMT,
                           BALANCE, MORTGAGE, PRINTPAID, AUTOPAID, INTNMLACR, INTPAID, TAXRATE, BONUSRATE, TPR, SCHDTYPE,
                           INTRATE, TERMCD, TDTERM, BREAKCD, MINBRTERM, INTTYPBRCD, FLINTRATE, OPNDATE, FRDATE, TODATE,
                           DESCRIPTION, BUYINGPOWER, AUTORND, TLID, OFFID, DELTD,intduecd,
                           odintrate,odmaxmortgage)
              VALUES (v_txdate, v_txnum,l_afacctno,v_acctno,l_actype,'N',v_ciacctno, v_custid, v_tdsrc,v_tdtype,l_amt,l_amt,
                      v_mortage, 0,v_autopaid, 0, 0,v_taxrate,v_bonusrate, v_tpr, v_schdtype, v_intrate,v_termcd, v_tdterm,v_breakcd,
                      v_minbrterm,v_inttypbrcd, v_flintrate, v_opdate,v_frmdate,
                      v_todate, l_desc,v_buyingpower,v_autornd,v_tlid,v_offid,'N',v_intduecd,
                      v_odintrate,v_odmaxmortgage);
      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'1670','TD','0022','0001');
      INSERT INTO TDTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),v_acctno,'0022',l_amt,NULL,l_afacctno,p_txmsg.deltd,l_afacctno,seq_TDTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,l_txdesc);


    ELSE
      --Xu ly reverse
      UPDATE TDMAST SET DELTD='Y' WHERE TXDATE=v_txdate AND TXNUM=v_txnum;

      --Bao dam tu dong tang suc mua thi cap nhat vao bang
      IF v_buyingpower = 'Y' THEN
         UPDATE TDLINK
         SET DELTD='Y'
         WHERE TXDATE=v_txdate AND TXNUM=v_txnum;

         UPDATE AFMAST
         SET MRCRLIMIT = MRCRLIMIT - l_amt
         WHERE ACCTNO = l_afacctno;
      END IF;
    END IF;

    --Kiem tra ngay het hang CMND
    SELECT COUNT(*) INTO v_EXISTSVAL FROM cfmast cf, afmast af
    WHERE cf.custid = af.custid and af.acctno= l_afacctno
    AND  cf.idexpired <= (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE');

    IF v_EXISTSVAL > 0 THEN
          p_err_code := '-200205';
          plog.setendsection (pkgctx, 'fn_OpenTermDeposit');
          RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_OpenTermDeposit');
    plog.setendsection (pkgctx, 'fn_OpenTermDeposit');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckTDWithdraw');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_OpenTermDeposit;
---------------------------fn_CheckIfOverUnmortgage-------------------------------------
FUNCTION fn_CheckIfOverUnmortgage(p_txmsg in  tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_blnREVERSAL boolean;
    l_tdacctno varchar2(30);
    l_afacctno varchar2(30);
    l_amt number;
    v_gramt number;
    v_count number;

BEGIN
    plog.setbeginsection (pkgctx, 'fn_CheckIfOverUnmortgage');
    plog.debug (pkgctx, '<<BEGIN OF fn_CheckIfOverUnmortgage');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    p_err_code:=0;
    l_tdacctno := p_txmsg.txfields('03').value;
    l_afacctno := p_txmsg.txfields('05').value;
    l_amt := p_txmsg.txfields('10').value;
    v_count := 1;
    --Kiem tra xem lich co thoa man de ung truoc khong?
    BEGIN
         SELECT NVL(SUM(CASE WHEN DORC='C' THEN AMT ELSE -AMT END),0)
         INTO v_gramt
         FROM TDLINK
         WHERE DELTD<>'Y'
               AND ACCTNO=l_tdacctno
               AND AFACCTNO=l_afacctno;
    EXCEPTION
      WHEN OTHERS THEN
        v_count :=0;
    END;
    IF v_count = 0 THEN
       p_err_code := '-570007';
       plog.setendsection (pkgctx, 'fn_CheckIfOverUnmortgage');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    IF v_gramt < l_amt THEN
       p_err_code := '-570007';
       plog.setendsection (pkgctx, 'fn_CheckIfOverUnmortgage');
       RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    --end check
    plog.debug (pkgctx, '<<END OF fn_CheckIfOverUnmortgage');
    plog.setendsection (pkgctx, 'fn_CheckIfOverUnmortgage');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckIfOverUnmortgage');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_CheckIfOverUnmortgage;
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_tdproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;

/
