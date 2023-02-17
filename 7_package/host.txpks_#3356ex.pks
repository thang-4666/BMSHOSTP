SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3356ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3356EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      10/03/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3356ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catype           CONSTANT CHAR(2) := '05';
   c_contents         CONSTANT CHAR(2) := '13';
   c_trade            CONSTANT CHAR(2) := '10';
   c_blocked          CONSTANT CHAR(2) := '19';
   c_desc             CONSTANT CHAR(2) := '30';
   c_tradedate        CONSTANT CHAR(2) := '07';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count NUMBER(20);

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
    SELECT COUNT(*) INTO l_count from caschd WHERE deltd='N' AND CAMASTID=p_txmsg.txfields('03').value
    AND (status <> 'W' AND INSTR(nvl(pstatus,'A'),'W')=0) AND qtty > 0 AND isse='Y';
    if(l_count<=0) THEN
    p_err_code := '-300014';
    plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
    RETURN errnums.C_BIZ_RULE_INVALID;
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
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_codeid VARCHAR2(6);
      v_wftcodeid VARCHAR2(6);
      v_camastid varchar2(30);
      l_count NUMBER(20);
      l_custid afmast.custid%TYPE;
      l_afacctno afmast.acctno%TYPE;
      l_sectype semast.actype%TYPE;
      l_codeid varchar2(6);
      l_blocked_change NUMBER(20);
      V_afacctno varchar2(20);
      V_TRQTTY   number(20);
      V_QTTY   number(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if p_txmsg.deltd<>'Y' THEN
      SELECT varvalue
         INTO v_strCURRDATE
         FROM sysvar
         WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    begin
        plog.debug (pkgctx, 'p_txmsg.TLID' || p_txmsg.TLID);
        l_txmsg.tlid        := p_txmsg.TLID;
    exception when others then
        l_txmsg.tlid        := systemnums.c_system_userid;
    end;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname        := 'DAY';
    l_txmsg.busdate:= p_txmsg.busdate;

    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3355';
    l_txmsg.reftxnum := p_txmsg.txnum;

    --update trang thai trong CASCHD
    v_Camastid:= p_txmsg.txfields('03').VALUE;
    SELECT nvl(tocodeid,codeid) INTO v_codeid FROM camast WHERE camastid=v_Camastid;

    select codeid into v_wftcodeid  from sbsecurities where refcodeid = v_codeid ;

     for rec in
    (

        SELECT  camast.catype ,camast.camastid, camast.description, '001' type,
                camast.tradedate ,sb.parvalue, SE.costprice PRICE , CF.CUSTODYCD,CF.CUSTID, af.acctno AFACCTNO,SB.CODEID, cf.fullname,
                cf.idcode LICENSE,cf.address,sb.symbol,se.STATUS,
                AF.ACCTNO||SB.CODEID SEACCTNOCR,AF.ACCTNO||sbwft.CODEID SEACCTNODR,
                LEAST(ca.qtty,se.trade) TRADE , (case when (ca.qtty>se.trade) then LEAST((ca.qtty-se.trade),se.blocked) else 0 end) blocked,
                to_char(reportdate,'DD/MM/RRRR') reportdate
        From vw_camast_all camast ,
              vw_caschd_all ca,
                semast se ,afmast af,cfmast cf , sbsecurities sb ,sbsecurities sbwft, SECURITIES_INFO SEINFO
        where camast.camastid = ca.camastid
              and camast.ISWFT='Y'
              and  nvl(camast.tocodeid,camast.codeid) = sb.codeid and ca.afacctno= se.afacctno
              and se.afacctno = af.acctno and af.custid = cf.custid and sb.codeid = seinfo.codeid
              and se.codeid = sbwft.codeid and sbwft.refcodeid=sb.codeid
              AND ca.ISSE='Y' AND se.trade+se.blocked>0
              and sbwft.tradeplace='006' and camast.status in('I','C','S','G','H','J')
              AND instr(nvl(ca.pstatus,'A'),'W') <=0
              AND camast.CAMASTID=p_txmsg.txfields('03').value
    )
    loop
        V_TRQTTY := rec.TRADE + rec.BLOCKED;
        V_QTTY := V_TRQTTY;
        V_afacctno := REC.AFACCTNO;
        for rec1 in
        (
            select autoid, acctno, codeid, qtty, mapqtty, trqtty
            from secmast
            where deltd <> 'Y' and qtty-mapqtty > 0 and ptype = 'I'
                and codeid = v_wftcodeid and acctno =  V_afacctno
        )
        loop
            if (V_QTTY > 0 and V_QTTY >= rec1.qtty-rec1.mapqtty) then
                update secmast set qtty = qtty-mapqtty, trqtty = trqtty + (qtty-mapqtty), deltd = 'Y'
                where autoid = rec1.autoid;
                V_QTTY := V_QTTY-(rec1.qtty-rec1.mapqtty);
            -----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
                secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, V_afacctno,
                 v_codeid, 'D', 'I', p_txmsg.txfields('03').value, NULL, rec1.qtty-rec1.mapqtty, /*p_txmsg.txfields('09').value*/ rec.price, 'Y');
            ELSIF (V_QTTY > 0 and V_QTTY < rec1.qtty-rec1.mapqtty) then
                update secmast set qtty = qtty-V_QTTY, trqtty = trqtty + V_QTTY
                where autoid = rec1.autoid;
                -----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
                secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, V_afacctno,
                 v_codeid, 'D', 'I', p_txmsg.txfields('03').value, NULL, V_QTTY, /*p_txmsg.txfields('09').value*/ rec.price, 'Y');
                V_QTTY := 0;
            end if;
        end loop;

       /* --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --Set txtime
        select to_char(sysdate,'hh24:mi:ss') into l_txmsg.txtime from dual;
        --Set brid
        begin
            l_txmsg.brid        := p_txmsg.BRID;
        exception when others then
            l_txmsg.brid        := substr(rec.AFACCTNO,1,4);
        end;
        --Set ngay hach toan giao dich
        l_txmsg.busdate:= p_txmsg.busdate;
        --Set cac field giao dich
        --01  AUTOID      C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.CODEID;
        --02  AFACCTNO    C
        l_txmsg.txfields ('02').defname   := 'AFACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := rec.AFACCTNO;
        --03  SEACCTNODR    C
        l_txmsg.txfields ('03').defname   := 'SEACCTNODR';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.SEACCTNODR;
        --04  CUSTODYCD      C
        l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := rec.CUSTODYCD;
        --05  SEACCTNOCR      C
        l_txmsg.txfields ('05').defname   := 'SEACCTNOCR';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.SEACCTNOCR;
        --06  AUTOID  C
        l_txmsg.txfields ('06').defname   := 'AUTOID';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := '1'; -- lay ja tri bk de ko thieu truong trong 3355
        --07  TRADEDATE  C
        l_txmsg.txfields ('07').defname   := 'TRADEDATE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := to_char(rec.TRADEDATE,'dd/mm/rrrr');
        --08  TYPE    C
        l_txmsg.txfields ('08').defname   := 'TYPE';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := rec.TYPE;
        --09  PRICE  C
        l_txmsg.txfields ('09').defname   := 'PRICE';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := p_txmsg.txfields('09').value;
                --10  TYPE  C
        l_txmsg.txfields ('10').defname   := 'TRADE';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.TRADE;

        --11  PARVALUE        N
        l_txmsg.txfields ('11').defname   := 'PARVALUE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.PARVALUE;
        --19  BLOCKED          C
        l_txmsg.txfields ('19').defname   := 'BLOCKED';
        l_txmsg.txfields ('19').TYPE      := 'N';
        l_txmsg.txfields ('19').VALUE     := rec.BLOCKED;
        --20  DUTYAMT  N
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Chuy?n ch?ng kho?th?c hi?n quy?n th? giao d?ch';
        --21  CUSTNAME N
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;
        --22  ADDRESS     C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;
        --30  LICENSE C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := rec.LICENSE;*/

        BEGIN
          /*  IF txpks_#3355.fn_batchtxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 3355: ' || p_err_code
               );

            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;

            END IF;*/

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNODR,'0044',ROUND(rec.blocked,0),NULL,rec.SEACCTNODR,p_txmsg.deltd,rec.SEACCTNODR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNODR,'0067',ROUND(rec.TRADE*p_txmsg.txfields('09').value,0),NULL,rec.SEACCTNODR,p_txmsg.deltd,rec.SEACCTNODR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNODR,'0068',ROUND(rec.TRADE,0),NULL,rec.SEACCTNODR,p_txmsg.deltd,rec.SEACCTNODR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNODR,'0040',ROUND(rec.TRADE,0),NULL,rec.SEACCTNODR,p_txmsg.deltd,rec.SEACCTNODR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,UTF8NUMS.c_const_TLTX_TXDESC_3356 || rec.reportdate );

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0043',ROUND(rec.blocked,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

  /*          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0051',ROUND(rec.TRADE*p_txmsg.txfields('09').value,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0052',ROUND(rec.TRADE,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
*/
            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0045',ROUND(rec.TRADE,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,UTF8NUMS.c_const_TLTX_TXDESC_3356 || rec.reportdate);


      -- kiem tra xem ton tai tk jao dich chua

    SELECT count(*) INTO l_count
    FROM SEMAST
    WHERE ACCTNO= rec.SEACCTNOCR;

    IF l_count = 0 THEN
         l_afacctno := substr(rec.SEACCTNOCR,1,10);
         l_codeid := substr(rec.SEACCTNOCR,length(rec.SEACCTNOCR)-5, length(rec.SEACCTNOCR));
         BEGIN
             SELECT b.setype,a.custid
             INTO l_sectype,l_custid
             FROM AFMAST A, aftype B
             WHERE  A.actype= B.actype
             AND a.ACCTNO = l_afacctno;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
         END;
         INSERT INTO SEMAST
         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
         VALUES(
         l_sectype, l_custid, rec.SEACCTNOCR,l_codeid,l_afacctno,
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
    END IF;

      /*UPDATE SEMAST
         SET
           BLOCKED = BLOCKED + (ROUND(rec.blocked,0)),
           DCRQTTY = DCRQTTY + (ROUND(rec.TRADE,0)),
           DCRAMT = DCRAMT + (ROUND(rec.TRADE*p_txmsg.txfields('09').value,0)),
           TRADE = TRADE + (ROUND(rec.TRADE,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.SEACCTNOCR;*/
    if rec.catype in ('014','017','020','023','027') then
        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0051',ROUND(rec.TRADE*/*p_txmsg.txfields('09').value*/ rec.price,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0052',ROUND(rec.TRADE,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        UPDATE SEMAST --SONLT 20150330: Xu ly rieng voi quyen mua, thi tinh lai gia von doi voi luong CK tang
         SET
           BLOCKED = BLOCKED + (ROUND(rec.blocked,0)),
           DCRQTTY = DCRQTTY + (ROUND(rec.TRADE,0)),
           DCRAMT = DCRAMT + (ROUND(rec.TRADE*/*p_txmsg.txfields('09').value*/ rec.price,0)),
           TRADE = TRADE + (ROUND(rec.TRADE,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.SEACCTNOCR;

        --30/10/2018 DieuNDA Them log OTC
        INSERT INTO SEOTCTRANLOG (AUTOID,TXNUM,TXDATE,TLTXCD,SEACCTNO,TYPEPON,SHAREHOLDERSID,STATUS,AMOUNT,DELTD,TRADE,BLOCKED)
            SELECT seq_SEOTCTRANLOG.NEXTVAL AUTOID, p_txmsg.txnum TXNUM, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) TXDATE, p_txmsg.tltxcd TLTXCD,
                SE.ACCTNO SEACCTNO, 'CR' TYPEPON, SE.SHAREHOLDERSID, 'A' STATUS, (ROUND(rec.blocked,0))+(ROUND(rec.TRADE,0)) AMOUNT,'N' DELTD,
                (ROUND(rec.TRADE,0)) TRADE, (ROUND(rec.blocked,0))BLOCKED
            FROM SEMAST SE
            WHERE ACCTNO=rec.SEACCTNOCR AND LENGTH(TRIM(NVL(SHAREHOLDERSID,''))) > 0;
        --End 30/10/2018 DieuNDA Them log OTC

    else
        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0052',ROUND(rec.TRADE,0),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec.SEACCTNOCR,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        UPDATE SEMAST
         SET
           BLOCKED = BLOCKED + (ROUND(rec.blocked,0)),
           DCRQTTY = DCRQTTY + (ROUND(rec.TRADE,0)),
           DCRAMT = DCRAMT + 0,
           TRADE = TRADE + (ROUND(rec.TRADE,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.SEACCTNOCR;

        --30/10/2018 DieuNDA Them log OTC
        INSERT INTO SEOTCTRANLOG (AUTOID,TXNUM,TXDATE,TLTXCD,SEACCTNO,TYPEPON,SHAREHOLDERSID,STATUS,AMOUNT,DELTD,TRADE,BLOCKED)
            SELECT seq_SEOTCTRANLOG.NEXTVAL AUTOID, p_txmsg.txnum TXNUM, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) TXDATE, p_txmsg.tltxcd TLTXCD,
                SE.ACCTNO SEACCTNO, 'CR' TYPEPON, SE.SHAREHOLDERSID, 'A' STATUS, (ROUND(rec.blocked,0))+(ROUND(rec.TRADE,0)) AMOUNT,'N' DELTD,
                (ROUND(rec.TRADE,0)) TRADE, (ROUND(rec.blocked,0))BLOCKED
            FROM SEMAST SE
            WHERE ACCTNO=rec.SEACCTNOCR AND LENGTH(TRIM(NVL(SHAREHOLDERSID,''))) > 0;
        --End 30/10/2018 DieuNDA Them log OTC
    end if;


      UPDATE SEMAST
         SET
           BLOCKED = BLOCKED - (ROUND(rec.blocked,0)),
           DDROUTQTTY = DDROUTQTTY + (ROUND(rec.TRADE,0)),
           TRADE = TRADE - (ROUND(rec.TRADE,0)),
           DDROUTAMT = DDROUTAMT + (ROUND(rec.TRADE*/*p_txmsg.txfields('09').value*/ rec.price,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.SEACCTNODR;


       -- neu blocked > 0 thi update vao semastdtl
/*          if(rec.blocked > 0) THEN
              l_blocked_change:=0; -- so luong ck da chuyen sang jao dich trong semastdtl
              FOR rec_semastdtl IN
                           (SELECT * FROM semastdtl WHERE acctno= rec.seacctnodr
                            AND DELTD <> 'Y' AND status <> 'C' AND qttytype IN ('002','007')
                            ORDER BY autoid )
              LOOP
                if(l_blocked_change <rec.blocked) THEN -- neu van chua chuyen het
                     IF ((rec.blocked-l_blocked_change)>= rec_semastdtl.qtty) THEN --  neu sl chua chuyen lon hon record dang xet
                        update semastdtl set acctno = rec.seacctnocr where autoid = rec_semastdtl.autoid;
                        l_blocked_change:=l_blocked_change+rec_semastdtl.qtty;
                     ELSE -- chi update giam mot phan, ghi them mot dong cho chung khoan jao dich moi
                        UPDATE semastdtl SET qtty=qtty-(rec.blocked-l_blocked_change) WHERE autoid=rec_semastdtl.autoid;

                         INSERT INTO SEMASTDTL (ACCTNO,QTTY,QTTYTYPE,TXNUM,TXDATE,DELTD,DFQTTY,STATUS,AUTOID)
                         SELECT rec.seacctnocr,(rec.blocked-l_blocked_change),qttytype,txnum,txdate,deltd,0,status,sEQ_SEMASTDTL.NEXTVAL
                         FROM semastdtl WHERE autoid=rec_semastdtl.autoid;

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNODR,'0044',(rec.blocked-l_blocked_change),NULL,rec.SEACCTNODR,p_txmsg.deltd,rec_semastdtl.qttytype,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.SEACCTNOCR,'0043',(rec.blocked-l_blocked_change),NULL,rec.SEACCTNOCR,p_txmsg.deltd,rec_semastdtl.qttytype,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

                         l_blocked_change:=l_blocked_change+(rec.blocked-l_blocked_change);

                     END IF;

                END IF;
                 exit when l_blocked_change >=rec.blocked;

              END LOOP;

              INSERT INTO setran (TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,AUTOID,ACCTREF,TLTXCD,BKDATE,TRDESC)
              VALUES(p_txmsg.txnum,p_txmsg.txdate,rec.seacctnodr,'0082',0,rec.seacctnocr,NULL,'N',seq_setran.nextval,NULL,'3356',p_txmsg.txdate,NULL);

          END IF;*/
    END;

        -- update codeid trong sepitlog
    UPDATE SEPITLOG SET CODEID=v_codeid,acctno=rec.SEACCTNOCR WHERE CODEID=v_wftcodeid AND qtty>mapqtty

   /* AND status <> 'C'*/ AND camastid =v_camastid AND acctno=rec.seacctnodr;
    end loop;


    UPDATE CASCHD SET STATUS='W' WHERE camastid=v_camastid AND deltd='N' AND isse='Y';
    UPDATE CASCHDHIST SET STATUS='W' WHERE camastid=v_camastid AND deltd='N' AND isse='Y';
    UPDATE CAMAST SET ISCHANGEWFT='Y' WHERE   camastid=v_camastid ;


    p_err_code:=0;
    plog.setendsection(pkgctx, 'pck_3355 call');
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
         plog.init ('TXPKS_#3356EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3356EX;
/
