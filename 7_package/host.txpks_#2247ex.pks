SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#2247EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2247EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      11/06/2021     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2247ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '13';
   c_fullname         CONSTANT CHAR(2) := '12';
   c_qtty             CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_feeamt           CONSTANT CHAR(2) := '55';
   c_minval           CONSTANT CHAR(2) := '56';
   c_maxval           CONSTANT CHAR(2) := '57';
   c_receivname       CONSTANT CHAR(2) := '29';
   c_receivcustodycd   CONSTANT CHAR(2) := '28';
   c_bank             CONSTANT CHAR(2) := '27';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count NUMBER;
l_RIGHTQTTY NUMBER;
l_RIGHTOFFQTTY NUMBER;
l_CAQTTYRECEIV NUMBER;
l_CAQTTYDB NUMBER;
l_CAAMTRECEIV NUMBER;
l_afacctno VARCHAR2(10);
l_seacctno VARCHAR2(20);
l_TRADE NUMBER;
l_BLOCKED NUMBER;
    l_mrrate number;
    l_mrirate number;
    l_marginrate number;
v_count number;
l_custid varchar2(20);
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
    -- check xem co tieu khoang nao hoat dong khong
    l_afacctno:=REPLACE(p_txmsg.txfields('02').value,'.');
    l_seacctno:=REPLACE(p_txmsg.txfields('03').value,'.');
    if(p_txmsg.deltd <>'Y') THEN

        SELECT COUNT(*) INTO l_count
        FROM afmast
        WHERE custid =(SELECT custid FROM afmast WHERE acctno=p_txmsg.txfields('02').value)
        AND status not IN ('N','C');

        if l_count > 0 then
                    p_err_code:='-260161';
                    plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
        END if;

        --Check con tien tren cac tieu khoan

        SELECT COUNT(*) INTO l_count
        FROM cimast ci, cfmast cf, afmast af
        WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND cf.custodycd=p_txmsg.txfields('13').value
            AND ci.balance >0;

        IF l_count > 0 THEN
                    p_err_code:='-400026';
                    plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        --Check het lenh thanh toan bu tru
        SELECT COUNT(*) INTO l_count
        FROM stschd ci, cfmast cf, afmast af
        WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND cf.custodycd=p_txmsg.txfields('13').value AND ci.deltd <> 'Y';

        IF l_count > 0 THEN
                    p_err_code:='-400035';
                    plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        -- Neu chuyen khoan cung cty thi tai khoan phai la tk thuong
        if (p_txmsg.txfields('27').value = systemnums.C_COMPANYCD) or (substr(p_txmsg.txfields('27').value,1,3) = substr(p_txmsg.txfields('13').value,1,3) ) then
            select count(*) into l_count from afmast af, aftype aft, mrtype mr where af.actype = aft.actype and aft.mrtype = mr.actype and mr.mrtype in ('N') and af.acctno = p_txmsg.txfields('38').value;
            if l_count = 0 then
                    p_err_code:='-200120';
                    plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                    RETURN errnums.C_BIZ_RULE_INVALID;
            END if;
        end if;


    /*    -- check xem ck da don ve mot tieu khoan chua
        SELECT COUNT(*) INTO L_count
        FROM (
               SELECT SUM (trade+blocked+mortage+margin+abs(netting)+withdraw+deposit+receiving+senddeposit) QTTY,
               max(custid) custid, afacctno
               FROM semast
               GROUP BY afacctno
               )semast
        WHERE custid =(SELECT custid FROM afmast WHERE acctno=l_afacctno)
        AND qtty > 0;

        if l_count > 1 then
                  p_err_code:='-260162';
                  plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                  RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/
        -- check xem sl CA co dung voi sl thuc the khong
        BEGIN
        SELECT
        nvl(SCHD.RIGHTQTTY,0) RIGHTQTTY,nvl(SCHD.RIGHTOFFQTTY,0) RIGHTOFFQTTY,nvl(SCHD.CAQTTYRECEIV,0)CAQTTYRECEIV,
        NVL((CASE WHEN SCHD.ISDBSEALL=1 THEN SEMAST.TRADE ELSE SCHD.CAQTTYDB END),0) CAQTTYDB,
        nvl(schd.CAAMTRECEIV,0) CAAMTRECEIV, SEMAST.TRADE TRADE, SEMAST.BLOCKED BLOCKED
        INTO   l_RIGHTQTTY,l_RIGHTOFFQTTY,l_CAQTTYRECEIV,l_CAQTTYDB,l_CAAMTRECEIV, l_TRADE, l_BLOCKED
        FROM
            (SELECT max(codeid)codeid,max(afacctno) afacctno,max(ISDBSEALL) ISDBSEALL,max(schd.seacctno)seacctno,
            SUM(RIGHTOFFQTTY) RIGHTOFFQTTY,SUM(CAQTTYRECEIV) CAQTTYRECEIV,
            SUM(CAQTTYDB) CAQTTYDB,SUM(CAAMTRECEIV) CAAMTRECEIV,SUM(RIGHTQTTY) RIGHTQTTY
            FROM
            (SELECT
              schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
             (CASE WHEN (schd.catype='014' AND schd.castatus NOT IN ('A','P','N','C','O') AND schd.duedate >=GETCURRDATE )
                THEN schd.pbalance ELSE 0 END) RIGHTOFFQTTY,
             (CASE WHEN (schd.catype='014' AND schd.status IN ('M','S','I','G','O','W') AND isse='N' ) THEN schd.qtty
                 WHEN (schd.catype IN ('017','020','023') AND schd.status IN ('G','S','I','O','W')  AND isse='N'  AND istocodeid='Y') THEN schd.qtty
                 WHEN (schd.catype IN ('011','021') AND schd.status  IN ('G','S','I','O','W')  AND isse='N' ) THEN schd.qtty
                 ELSE 0 END) CAQTTYRECEIV,
             (CASE WHEN (schd.catype IN ('017','020','023','016') AND schd.status  IN ('G','S','I','O','W')  AND isse='N') THEN schd.aqtty
                   ELSE 0 END) CAQTTYDB,
             (CASE  WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','W') AND isse='N') THEN 1 ELSE 0 END) ISDBSEALL,
             (CASE WHEN  (schd.status  IN ('H','S','I','O','W') AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
                   WHEN  SCHD.STATUS = 'K' THEN SCHD.AMT*(1-SCHD.EXERATE/100)
                   ELSE 0 END) CAAMTRECEIV,
             (CASE WHEN (schd.catype IN ('005','006','022') AND schd.status IN ('H','G','S','I','J','O','W') and isse='N') THEN schd.rqtty ELSE 0 END) RIGHTQTTY
              FROM
                    (SELECT schd.rqtty,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                     camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                     schd.isci,schd.isexec ,'N' istocodeid, schd.isse,CAMAST.EXERATE
                     FROM caschd schd ,camast WHERE schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                     UNION ALL
                     SELECT schd.rqtty, schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                     '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                      schd.isci,schd.isexec  ,'Y' istocodeid, SCHD.ISSE,CAMAST.EXERATE
                     FROM caschd schd, camast
                     WHERE schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                     ) SCHD
                   ) schd GROUP BY (codeid, afacctno) ) schd,
                    (SELECT ACCTNO,ACTYPE,CODEID,AFACCTNO,OPNDATE,CLSDATE,LASTDATE,STATUS,PSTATUS,IRTIED,IRCD,COSTPRICE,TRADE,MORTAGE,MARGIN,
                    NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN,BLOCKED,RECEIVING,TRANSFER,PREVQTTY,DCRQTTY,DCRAMT,DEPOFEEACR,REPO,
                    PENDING,TBALDEPO,CUSTID,COSTDT,SECURED,ICCFCD,ICCFTIED,TBALDT,SENDDEPOSIT,SENDPENDING,DDROUTQTTY,DDROUTAMT,DTOCLOSE,
                    SDTOCLOSE,QTTY_TRANSFER,LAST_CHANGE,DEALINTPAID,WTRADE,GRPORDAMT
                    FROM SEMAST
                    UNION ALL
                    SELECT   distinct(afacctno||codeid) acctno,NULL,CODEID, AFACCTNO,NULL,NULL,NULL,'A',NULL,NULL,NULL,NULL,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    NULL,NULL,0,NULL,NULL,NULL,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL
                    FROM
                          (SELECT afacctno,codeid FROM caschd WHERE deltd='N'
                          UNION ALL
                          SELECT afacctno,tocodeid codeid FROM caschd, camast WHERE caschd.camastid=camast.camastid
                          AND caschd.deltd='N' AND catype IN ('017','020','023'))
                          WHERE (afacctno,codeid) NOT IN (SELECT afacctno,codeid FROM semast)
                    ) semast
            WHERE semast.acctno=schd.afacctno(+)||schd.codeid(+)
            AND semast.acctno=l_seacctno;
        EXCEPTION
            WHEN OTHERS
            THEN
              l_RIGHTQTTY :=0;
              l_RIGHTOFFQTTY :=0;
              l_CAQTTYRECEIV :=0;
              l_CAQTTYDB :=0;
              l_CAAMTRECEIV :=0;
              l_TRADE := 0;
              l_BLOCKED := 0;
            END ;
        if(l_TRADE <to_number(p_txmsg.txfields('10').value)) THEN
            p_err_code:='-900017';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;
        if(l_BLOCKED <to_number(p_txmsg.txfields('06').value)) THEN
            p_err_code:='-400036';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;
        if(l_RIGHTOFFQTTY <to_number(p_txmsg.txfields('14').value)) THEN
            p_err_code:='-269009';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;
        if(l_CAQTTYRECEIV <to_number(p_txmsg.txfields('15').value)) THEN
            p_err_code:='-269010';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;
         if(l_CAQTTYDB <to_number(p_txmsg.txfields('16').value)) THEN
            p_err_code:='-269011';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;
         if(l_CAAMTRECEIV <to_number(p_txmsg.txfields('17').value)) THEN
            p_err_code:='-269012';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;
         if(l_RIGHTQTTY <to_number(p_txmsg.txfields('18').value)) THEN
            p_err_code:='-269013';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;

        select count(1) into l_count
        from SEMAST SE, SBSECURITIES SEC
        where SE.CODEID =SEC.CODEID AND SE.ACCTNO = l_seacctno and SE.withdraw + SE.deposit +
        SE.senddeposit + SE.emkqtty + SE.blockwithdraw + SE.mortage > 0
        AND SEC.SECTYPE <> '004' ;
        if l_count > 0 THEN
            p_err_code:='-200410';
            plog.setendsection(pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;

        END IF;

        select nvl(max(rsk.mrratiorate * least(rsk.mrpricerate,se.margincallprice) / 100),0)
            into l_mrrate
        from afserisk rsk, afmast af, aftype aft, mrtype mrt, securities_info se
        where af.actype = rsk.actype and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T' and aft.istrfbuy = 'N'
        and af.acctno = p_txmsg.txfields('02').value and rsk.codeid = p_txmsg.txfields('01').value and rsk.codeid = se.codeid;

        if l_mrrate > 0 then -- check them khi chuyen chung khoan di, tai san con lai phai dam bao ty le.
            select round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt-CI.CIDEPOFEEACR-CI.DEPOFEEAMT>=0 then 100000
                   -- else least( greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0), af.mrcrlimitmax - dfodamt)
                   else  greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0)
                        / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt-CI.CIDEPOFEEACR-CI.DEPOFEEAMT) end),4) * 100 MARGINRATE,
                    af.mrirate
                        into l_marginrate, l_mrirate
            from afmast af, cimast ci, v_getsecmarginratio sec
            where af.acctno = ci.acctno and af.acctno = sec.afacctno(+)
            and af.acctno = p_txmsg.txfields('02').value;

            if l_marginrate < l_mrirate then
                p_err_code:='-180064';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;

        IF p_txmsg.txfields('27').value =systemnums.C_COMPANYCD THEN

                SELECT count(*) into v_count
                    FROM AFMAST AF, CFMAST CF, aftype aft
                WHERE AF.CUSTID = CF.CUSTID AND af.actype = aft.actype and aft.MNEMONIC not in ('T3','Margin')
                and CF.CUSTODYCD = p_txmsg.txfields(c_receivcustodycd).value;

            if v_count =0 then
                 p_err_code:='-900019';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;

        END IF;
          -- check khong co su kien quyen nao moi lam 3375 ma chua lam 3340

   SELECT custid into  l_custid FROM cfmast WHERE custodycd =p_txmsg.txfields('13').value;

   FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
    LOOP
           SELECT COUNT(*) INTO L_COUNT
          FROM CASCHD SCHD, AFMAST AF, CAMAST CA
          WHERE SCHD.AFACCTNO=AF.ACCTNO
          AND SCHD.DELTD <> 'Y'
          AND SCHD.STATUS IN ('A','P','N')
          AND CA.CAMASTID=SCHD.CAMASTID
          AND( (CASE WHEN CA.CATYPE ='014' THEN SCHD.PBALANCE ELSE 0 END )
              +(CASE WHEN CA.CATYPE IN ('017','020','023','011','021') THEN SCHD.QTTY ELSE 0 END)
              + SCHD.AMT+SCHD.RQTTY
              ) >0
           AND AF.ACCTNO=recall.acctno
           AND CA.CODEID=p_txmsg.txfields('01').value ;
         IF L_COUNT>0 THEN
                p_err_code:='-400051';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
         ENd IF;

     END LOOP;

     --HSX04: check ck chuyen: khong chuyen ck -> khong chuyen quyen
    IF to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value) + to_number(p_txmsg.txfields('16').value) + to_number(p_txmsg.txfields('17').value) + to_number(p_txmsg.txfields('18').value) > 0
    AND to_number(p_txmsg.txfields('10').value) + to_number(p_txmsg.txfields('06').value) <= 0 THEN
            p_err_code:='-260180';
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
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
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_RIGHTQTTY NUMBER;
l_RIGHTOFFQTTY NUMBER;
l_CAQTTYRECEIV NUMBER;
l_CAQTTYDB NUMBER;
l_CAAMTRECEIV NUMBER;
L_SEACCTNO VARCHAR2(20);
L_CODEIDWFT   VARCHAR2(6);
l_custid   VARCHAR2(60);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     -- ghi jam so luong CA cho ve theo thu tu uu tien
    l_RIGHTQTTY :=to_number(p_txmsg.txfields('18').value);
    l_RIGHTOFFQTTY :=to_number(p_txmsg.txfields('14').value);-- sl quyen mua chua dk
    l_CAQTTYRECEIV :=to_number(p_txmsg.txfields('15').value);
    l_CAQTTYDB :=to_number(p_txmsg.txfields('16').value);
    l_CAAMTRECEIV :=to_number(p_txmsg.txfields('17').value);
    if(p_txmsg.deltd <>'Y') THEN

       SELECT custid into  l_custid FROM cfmast WHERE custodycd =p_txmsg.txfields('13').value;

       FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
        loop

        FOR rec IN (

                      SELECT schd.status,autoid,camastid,reportdate,catype,
                      schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                      (CASE WHEN (schd.catype='014' AND schd.castatus NOT IN ('A','P','N','C') AND schd.duedate >=GETCURRDATE )
                      THEN schd.pbalance ELSE 0 END) RIGHTOFFQTTY,
                      (CASE WHEN (schd.catype='014' AND schd.status IN ('M','S','I','G','O','W') AND isse='N') THEN schd.qtty
                      WHEN (schd.catype IN ('017','020','023') AND schd.status IN ('G','S','I','O','W')  AND isse='N' AND istocodeid='Y') THEN schd.qtty
                      WHEN (schd.catype IN ('011','021') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN schd.qtty
                      ELSE 0 END) CAQTTYRECEIV,
                      (CASE WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN nvl(se.trade,0)
                            WHEN (schd.catype IN ('017','020','023') AND schd.status  IN ('G','S','I','O','W') AND isse='N') THEN schd.aqtty
                            ELSE 0 END) CAQTTYDB,
                      (CASE  WHEN (schd.catype IN ('016') AND schd.status  IN ('G','S','I','O','W') AND isse='N' ) THEN 1 ELSE 0 END) ISDBSEALL,
                      (CASE WHEN  (schd.status  IN ('H','S','I','O','W') AND isci='N' AND schd.isexec='Y') THEN SCHD.AMT
                            WHEN  SCHD.STATUS = 'K' THEN SCHD.AMT*(1-SCHD.EXERATE/100)
                            ELSE 0 END) CAAMTRECEIV,
                      (CASE WHEN (schd.catype IN ('005','006','022') AND schd.status IN ('H','G','S','I','J','O','W')) THEN schd.rqtty ELSE 0 END) RIGHTQTTY,

                      ISWFT,optcodeid,schd.trade
                      FROM
                            (SELECT schd.rqtty,schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                            camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                            schd.isci,schd.isexec,reportdate ,'N' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE
                            ,CAMAST.EXERATE,schd.trade
                            FROM caschd schd ,camast WHERE schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                            UNION ALL
                            SELECT schd.rqtty,schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                            '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                            schd.isci,schd.isexec ,reportdate ,'Y' istocodeid, NVL(ISWFT,'Y') ISWFT, camast.optcodeid, SCHD.ISSE
                            ,CAMAST.EXERATE,schd.trade
                            FROM caschd schd, camast
                            WHERE schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                            ) SCHD, semast se
                       WHERE schd.codeid=p_txmsg.txfields('01').value
                       AND  schd.afacctno=recall.acctno
                       AND se.acctno(+)=(schd.afacctno||schd.codeid)

                      ORDER BY reportdate
                   )
        LOOP
                 IF ( LEAST(rec.RIGHTQTTY,l_RIGHTQTTY)+LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)+
                      LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)+LEAST(rec.CAQTTYDB,l_CAQTTYDB)+
                      LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV)> 0) THEN

                    if(rec.catype <> '016') THEN
                         if(rec.status <> 'O' ) THEN
                             UPDATE caschd SET status='O',pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                               rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               aqtty=aqtty-least(rec.CAQTTYDB,l_CAQTTYDB),
                                               amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                               SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                               +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                               SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                               pstatus= pstatus||status

                              WHERE autoid=rec.autoid;
                          ELSE
                              UPDATE caschd SET pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                               rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               aqtty=aqtty-least(rec.CAQTTYDB,l_CAQTTYDB),
                                               amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                               SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                               +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                               SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV)


                              WHERE autoid=rec.autoid;
                          END IF;
                    ELSE -- su kien tra goc lai trai phieu: khong tru o aqtty
                        if(rec.status <> 'O' ) THEN
                             UPDATE caschd SET status='O',pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                               rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                               SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                               +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                               SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                               pstatus= pstatus||status

                              WHERE autoid=rec.autoid;
                          ELSE
                              UPDATE caschd SET pbalance=pbalance-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               qtty=qtty-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                               rqtty=rqtty-least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               amt=amt-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                               SENDPBALANCE=SENDPBALANCE+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                               SENDQTTY=SENDQTTY+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                               +least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                               SENDAQTTY=SENDAQTTY+least(rec.CAQTTYDB,l_CAQTTYDB),
                                               SENDAMT=SENDAMT+least(rec.CAAMTRECEIV,l_CAAMTRECEIV)


                              WHERE autoid=rec.autoid;
                          END IF;
                    END IF;
                     -- CAT RECEIVING TRONG SEMAST
                    IF(LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV) >0) THEN
                        IF(REC.ISWFT='Y') THEN
                           SELECT CODEID INTO L_CODEIDWFT FROM SBSECURITIES WHERE REFCODEID=REC.CODEID;
                           l_SEACCTNO:=REC.AFACCTNO||L_CODEIDWFT;
                        ELSE
                           l_SEACCTNO:=REC.AFACCTNO||REC.CODEID;
                        END IF;

                        UPDATE SEMAST SET RECEIVING=RECEIVING-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                        WHERE ACCTNO=l_SEACCTNO;

                         INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                         VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_SEACCTNO,
                         '0015',LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),NULL,NULL,p_txmsg.deltd,NULL,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

                    END IF;
                    -- neu la sk quyen mua: tru o semast cua ck quyen
                    if(rec.catype='014') THEN
                      UPDATE semast SET trade=trade-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)
                      WHERE acctno=rec.afacctno||rec.optcodeid;
                    END IF;

                    l_RIGHTQTTY :=l_RIGHTQTTY-LEAST(rec.RIGHTQTTY,l_RIGHTQTTY);
                    l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY);
                    l_CAQTTYRECEIV :=l_CAQTTYRECEIV-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV);
                    l_CAQTTYDB :=l_CAQTTYDB-LEAST(rec.CAQTTYDB,l_CAQTTYDB);
                    l_CAAMTRECEIV :=l_CAAMTRECEIV-LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV);

             INSERT INTO catrflog (AUTOID,TXDATE,TXNUM,CAMASTID,OPTSEACCTNOCR,OPTSEACCTNODR,CODEID,OPTCODEID,balance,AMT,qtty,CUSTODYCDCR,CUSTODYCDDR,STATUS)
             VALUES(seq_catrflog.NEXTVAL,TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum,rec.camastid,p_txmsg.txfields('38').value ||rec.codeid,rec.seacctno,rec.codeid,rec.codeid,
                      rec.trade,rec.CAAMTRECEIV,rec.RIGHTQTTY+rec.RIGHTOFFQTTY+rec.CAQTTYRECEIV,p_txmsg.txfields('28').value,p_txmsg.txfields('13').value,'N');


                    EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);
        END IF;

             END LOOP;

       END LOOP;

        insert into trfdtoclose(FRCUSTODYCD, TOCUSTODYCD, AFACCTNO, TOSTOCKID, DTOCLOSE, BLOCKED, TXNUM, TXDATE, DELTD, codeid,FRAFACCTNO)
            values(p_txmsg.txfields('13').value, p_txmsg.txfields('28').value, p_txmsg.txfields('38').value, p_txmsg.txfields('27').value, ROUND(p_txmsg.txfields('10').value,0),
                ROUND(p_txmsg.txfields('06').value,0),p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),'N',p_txmsg.txfields('01').value, p_txmsg.txfields('02').value);
    ELSE -- xoa jao dich
    FOR recall  IN (SELECT acctno FROM afmast WHERE custid = l_custid )
        LOOP


       FOR rec IN (
                 SELECT schd.autoid, schd.codeid, schd.afacctno,(schd.afacctno||schd.codeid) seacctno,
                 schd.SENDPBALANCE  RIGHTOFFQTTY,
                 schd.SENDAMT CAAMTRECEIV,
                 schd.SENDAQTTY CAQTTYDB,
                 (CASE WHEN (ca.catype IN ('005','006','022')) THEN schd.SENDQTTY ELSE 0 END) RIGHTQTTY,
                 (CASE WHEN (ca.catype NOT IN ('005','006','022'))THEN schd.SENDQTTY ELSE 0 END) CAQTTYRECEIV,
                 ca.catype,ISWFT,optcodeid
                FROM (
                SELECT schd.autoid,schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno,camast.codeid,
                camast.tocodeid, schd.camastid,schd.balance,schd.qtty,schd.aqtty,schd.amt,schd.aamt,schd.pbalance,schd.pqtty ,
                schd.isci,schd.isse ,SENDPBALANCE,SENDAMT,SENDAQTTY,
                (CASE WHEN (catype IN ('017','020','023')) THEN 0 ELSE SENDQTTY END )SENDQTTY

                FROM caschd schd ,camast WHERE schd.status='O' AND schd.camastid=camast.camastid AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'
                UNION ALL
                SELECT schd.autoid,  schd.status,camast.catype,camast.duedate,camast.status castatus,schd.afacctno, camast.tocodeid codeid,
                '',schd.camastid,0,schd.qtty,0,0,0,0,0,
                schd.isci,schd.isse  ,0,0,0,  SENDQTTY

                FROM caschd schd, camast
                WHERE schd.status='O' AND schd.camastid=camast.camastid AND camast.catype IN ('017','020','023')AND schd.deltd='N' AND camast.deltd='N' AND camast.status <> 'C'

                 ) schd, camast ca
                  WHERE schd.camastid=ca.camastid
                                    and schd.codeid=p_txmsg.txfields('01').value
                  AND  schd.afacctno=recall.acctno
                  ORDER BY reportdate
               )
            LOOP

            if(rec.catype <> '016') THEN
                  UPDATE caschd SET  status=SUBSTR(pstatus,LENGTH(pstatus)),
                                     pbalance=pbalance+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                     qtty=qtty+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                     rqtty=rqtty+ least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                     aqtty=aqtty+least(rec.CAQTTYDB,l_CAQTTYDB),
                                     amt=amt+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                     SENDPBALANCE=SENDPBALANCE-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                     SENDQTTY=SENDQTTY-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                     -least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                     SENDAQTTY=SENDAQTTY-least(rec.CAQTTYDB,l_CAQTTYDB),
                                     SENDAMT=SENDAMT-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                     pstatus=pstatus||status

                    WHERE autoid=rec.autoid;
              ELSE -- su kien tra goc lai trai phieu ko update o AQTTY
                     UPDATE caschd SET  status=SUBSTR(pstatus,LENGTH(pstatus)),
                                     pbalance=pbalance+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                     qtty=qtty+least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV),
                                     rqtty=rqtty+ least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                     amt=amt+least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                     SENDPBALANCE=SENDPBALANCE-least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY),
                                     SENDQTTY=SENDQTTY-least(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                                     -least(rec.RIGHTQTTY,l_RIGHTQTTY),
                                     SENDAQTTY=SENDAQTTY-least(rec.CAQTTYDB,l_CAQTTYDB),
                                     SENDAMT=SENDAMT-least(rec.CAAMTRECEIV,l_CAAMTRECEIV),
                                     pstatus=pstatus||status
                    WHERE autoid=rec.autoid;
              END IF;

               -- CONG RECEIVING TRONG SEMAST
                    IF(LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV) >0) THEN
                        IF(REC.ISWFT='Y') THEN
                           SELECT CODEID INTO L_CODEIDWFT FROM SBSECURITIES WHERE REFCODEID=REC.CODEID;
                           l_SEACCTNO:=REC.AFACCTNO||L_CODEIDWFT;
                        ELSE
                           l_SEACCTNO:=REC.AFACCTNO||REC.CODEID;
                        END IF;

                        UPDATE SEMAST SET RECEIVING=RECEIVING+LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV)
                        WHERE ACCTNO=l_SEACCTNO;

                    END IF;
                    if(rec.catype='014') THEN
                      UPDATE semast SET trade=trade+least(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY)
                      WHERE acctno=rec.afacctno || rec.optcodeid;
                    END IF;

                l_RIGHTQTTY :=l_RIGHTQTTY-LEAST(rec.RIGHTQTTY,l_RIGHTQTTY);
                l_RIGHTOFFQTTY :=l_RIGHTOFFQTTY-LEAST(rec.RIGHTOFFQTTY,l_RIGHTOFFQTTY);
                l_CAQTTYRECEIV :=l_CAQTTYRECEIV-LEAST(rec.CAQTTYRECEIV,l_CAQTTYRECEIV);
                l_CAQTTYDB :=l_CAQTTYDB-LEAST(rec.CAQTTYDB,l_CAQTTYDB);
                l_CAAMTRECEIV :=l_CAAMTRECEIV-LEAST(rec.CAAMTRECEIV,l_CAAMTRECEIV);
                EXIT WHEN (l_RIGHTQTTY+l_RIGHTOFFQTTY+l_CAQTTYRECEIV+l_CAQTTYDB+l_CAAMTRECEIV=0);
            END LOOP;
    END LOOP;
            update trfdtoclose set deltd = 'Y' where txnum = p_txmsg.txnum and txdate = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);

            DELETE FROM  catrflog WHERE TXNUM =p_txmsg.txnum AND TXDATE = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);

    END IF;
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
v_sesendclose  number;
l_seacctno VARCHAR2 (30);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_seacctno := p_txmsg.txfields('03').value;
    if p_txmsg.deltd <> 'Y' then
        IF CSPKS_SEPROC.fn_TransferDTOCLOSE(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
           plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
           RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        v_sesendclose := seq_sesendclose.NEXTVAL;
    INSERT INTO SESENDCLOSE (AUTOID,CODEID,AFACCTNO,ACCTNO,DEPOBLOCK,QTTY,PARVALUE,FULLNAME,CUSTODYCD,RIGHTOFFQTTY,CAQTTYRECEIV,CAQTTYDB,CAAMTRECEIV,RIGHTQTTY,BANK,RECEIVCUSTODYCD,SEDESC,VSDCODE,TXDATE,TXNUM)
    VALUES(v_sesendclose,p_txmsg.txfields(c_codeid).value,p_txmsg.txfields(c_afacctno).value,p_txmsg.txfields(c_acctno).value,p_txmsg.txfields('06').value,
    p_txmsg.txfields(c_qtty).value,p_txmsg.txfields(c_parvalue).value,p_txmsg.txfields(c_fullname).value,p_txmsg.txfields(c_custodycd).value,
    p_txmsg.txfields('14').value,p_txmsg.txfields('15').value,p_txmsg.txfields('16').value,p_txmsg.txfields('17').value,
    p_txmsg.txfields('18').value,p_txmsg.txfields(c_bank).value,p_txmsg.txfields(c_receivcustodycd).value,p_txmsg.txfields('30').value,p_txmsg.txfields('71').value,
    TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txnum);
    for rec in (
        select * from sepitlog where acctno = l_seacctno
        and deltd <> 'Y' and qtty - mapqtty >0 and pitrate > 0
        order by txdate
    )
    loop
        update sepitlog set mapqtty = mapqtty + rec.qtty - rec.mapqtty, status ='C' where autoid = rec.autoid;
        INSERT INTO se2244_log (sendoutid, codeid, camastid, afacctno, qtty, deltd, sepitid,tltxcd)
        VALUES (v_sesendclose, rec.codeid, rec.camastid, rec.afacctno, rec.qtty - rec.mapqtty, 'N', rec.autoid, p_txmsg.tltxcd);

    end loop;
ELSE
    for rec in (select lg.* from se2244_log lg, SESENDCLOSE mst
                where lg.sendoutid = mst.autoid and lg.tltxcd = p_txmsg.tltxcd
                    and mst.txdate = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) and mst.txnum = p_txmsg.txnum and mst.deltd <> 'Y'
                    and lg.deltd <> 'Y'
                    and mst.acctno = l_seacctno
                )
    loop
        update sepitlog set mapqtty = mapqtty - rec.qtty, status ='P' where autoid = rec.sepitid;
        update se2244_log set deltd = 'Y'
        where sendoutid = rec.sendoutid and sepitid = rec.sepitid and afacctno = rec.afacctno and tltxcd = p_txmsg.tltxcd;
    end loop;
    update SESENDCLOSE
    set deltd = 'Y'
    where txdate = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) and txnum = p_txmsg.txnum;
    end if;
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
         plog.init ('TXPKS_#2247EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2247EX;
/
