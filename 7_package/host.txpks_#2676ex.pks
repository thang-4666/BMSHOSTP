SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2676ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2676EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      23/08/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2676ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_groupid          CONSTANT CHAR(2) := '20';
   c_strdata          CONSTANT CHAR(2) := '06';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_ORGAMT number ;
l_DFODAMT number;
V_STRXML varchar2(3200);
l_AFACCTNODRD varchar2(20);
l_AFACCTNO varchar2(20);
l_ACTYPE varchar2(20);
l_mrcrlimitmax number;
L_LIMITCHK  varchar2(20);
l_status varchar2(1);
V_STRXMLItem varchar2(3200);
l_QTTYItem  number;
l_QTTYRemainItem  number;
l_DTYPEItem varchar2(10);
l_SYMBOLItem varchar2(20);
N number;
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
    plog.debug(pkgctx,'2676EX: ' || p_txmsg.txfields('06').VALUE );
    V_STRXML:= p_txmsg.txfields('06').VALUE;
    l_ORGAMT := substr(V_STRXML,instr(V_STRXML,'|',1,2)+1,instr(V_STRXML,'|',1,3)-instr(V_STRXML,'|',1,2)-1 ) ;
    l_AFACCTNODRD  := substr(V_STRXML,instr(V_STRXML,'|',1,24)+1,instr(V_STRXML,'|',1,25)-instr(V_STRXML,'|',1,24)-1 ) ;
    l_AFACCTNO := substr(V_STRXML,instr(V_STRXML,'|',1,13)+1,instr(V_STRXML,'|',1,14)-instr(V_STRXML,'|',1,13)-1 ) ;
    l_ACTYPE := substr(V_STRXML,0,instr(V_STRXML,'|')-1);

    plog.debug(pkgctx,l_AFACCTNODRD || '  ' || l_AFACCTNO );

    select LENGTH(V_STRXML) - LENGTH (REPLACE(V_STRXML,'$','')) into N from dual;

    for i in 1..N loop
        if i=1 then
            V_STRXMLItem:=substr( p_txmsg.txfields('06').VALUE,0,instr( p_txmsg.txfields('06').VALUE,'$')-1);
        else
            V_STRXMLItem :=  substr( p_txmsg.txfields('06').VALUE,instr( p_txmsg.txfields('06').VALUE,'$',1,i-1)+1,instr( p_txmsg.txfields('06').VALUE,'$',1,i)-instr( p_txmsg.txfields('06').VALUE,'$',1,i-1)-1 ) ;
        end  if ;
        l_DTYPEItem := substr(V_STRXMLItem,instr(V_STRXMLItem,'|',1,14)+1,instr(V_STRXMLItem,'|',1,15)-instr(V_STRXMLItem,'|',1,14)-1 ) ;
        l_SYMBOLItem := substr(V_STRXMLItem,instr(V_STRXMLItem,'|',1,15)+1,instr(V_STRXMLItem,'|',1,16)-instr(V_STRXMLItem,'|',1,15)-1 ) ;
        l_QTTYItem := substr(V_STRXMLItem,instr(V_STRXMLItem,'|',1,17)+1,instr(V_STRXMLItem,'|',1,18)-instr(V_STRXMLItem,'|',1,17)-1 ) ;

        begin
            select SUM( nvl(MST.QTTY,0)) into l_QTTYRemainItem
                from
                (SELECT '' AUTOID,'N' DTYPE, B.SYMBOL, A.TRADE-nvl(D.SECUREAMT,0)+nvl(D.SERECEIVING,0) QTTY
                    FROM SEMAST A, SBSECURITIES B,
                        (SELECT CODEID, DFRLSPRICE BASICPRICE, TXDATE
                            FROM SECURITIES_INFO) C,
                            v_getsellorderinfo D
                        WHERE A.CODEID = B.CODEID AND A.CODEID = C.CODEID (+) AND A.ACCTNO=D.SEACCTNO(+)
                        AND A.AFACCTNO = l_AFACCTNO
                        AND A.TRADE + A.MORTAGE-nvl(D.SECUREMTG,0)-nvl(D.SECUREAMT,0)+nvl(D.SERECEIVING,0) <> 0
                        AND  B.SECTYPE <>'004'
                union
                select AUTOID, DTYPE,SYMBOL, QTTY
                    from v_getCreateDeal v,
                        (SELECT CODEID, DFRLSPRICE BASICPRICE, TXDATE FROM SECURITIES_INFO) C
                    where v.codeid = c.codeid and v.AFACCTNO = l_AFACCTNO
                ) MST
                where MST.QTTY > 0
                    and MST.DTYPE = l_DTYPEItem and MST.SYMBOL = l_SYMBOLItem;
            if l_QTTYRemainItem < l_QTTYItem then
                p_err_code := '-900020'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        exception when others then
            select SUM(qtty) into l_QTTYRemainItem
            from
            (select AUTOID, DTYPE,SYMBOL, QTTY
                from v_getCreateDeal v,
            (SELECT CODEID, DFRLSPRICE BASICPRICE, TXDATE FROM SECURITIES_INFO ) C
            where v.codeid = c.codeid and v.status = 'W' and v.AFACCTNO = l_AFACCTNO ) MST where MST.QTTY > 0
             and MST.DTYPE = l_DTYPEItem and MST.SYMBOL = l_SYMBOLItem;
            if l_QTTYRemainItem < l_QTTYItem then
                p_err_code := '-900020'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end;
    end loop;


     select DFODAMT into l_DFODAMT from cimast where acctno = nvl(l_AFACCTNODRD,l_AFACCTNO) ;

   select mrcrlimitmax - l_DFODAMT , status into l_mrcrlimitmax, l_status from afmast  where acctno = nvl(l_AFACCTNODRD,l_AFACCTNO) ;

SELECT DFTYPE. LIMITCHK
into L_LIMITCHK
 FROM DFTYPE  where actype =l_ACTYPE ;

    plog.debug(pkgctx,l_mrcrlimitmax || '  ' || l_ORGAMT || ' : ' || L_LIMITCHK );

    IF (l_mrcrlimitmax < l_ORGAMT) and (L_LIMITCHK='Y') THEN
      p_err_code:= -400119;
      RETURN -400119;
    END IF;



    if l_status <> 'A' then
          p_err_code := '-900019';
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
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

l_ORGAMT number ;
V_STRXML varchar2(3200);
l_AFACCTNODRD varchar2(20);
l_AFACCTNO varchar2(20);
l_ACTYPE varchar2(20);
l_mrcrlimitmax number;
L_LIMITCHK  varchar2(20);
l_AUTODRAWNDOWN number;
l_ISAPPROVE  varchar2(20);
l_ISVSD varchar2(1);
l_marginrate number;
l_mrirate number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    --cspks_dfproc.pr_CREATEDFGRP( p_txmsg  ,p_err_code ) ;
     V_STRXML:= p_txmsg.txfields('06').VALUE;
     plog.debug (pkgctx, '2676Ex.fn_txAftAppUpdate ' || V_STRXML);
      -- insert vao dfgrplog, dfgrpdtllog
     cspks_dfproc.pr_Createdfgrplog(p_txmsg  ,p_err_code );
     IF p_err_code <> 0 THEN
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

   -- select autodrawndown,isapprove into l_AUTODRAWNDOWN, l_ISAPPROVE from dfgrplog where GROUPID = p_txmsg.txfields('20').VALUE;
    --Tao hop dong tong 2673
    --IF l_ISAPPROVE ='N' THEN
      cspks_dfproc.pr_Opentdfgroup(p_txmsg.txfields('20').VALUE ,p_err_code  );
     IF p_err_code <> 0 THEN
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

     -- Kiem tra xem loai hinh cam co co phai la cam co VSD hay khong, neu khong thi giai ngan.
     SELECT ISVSD INTO l_ISVSD FROM DFTYPE WHERE ACTYPE = p_txmsg.txfields('21').VALUE;

     IF l_ISVSD <> 'Y' THEN
        --Giai ngan hop dong tong 2674
          --IF l_AUTODRAWNDOWN = 1 THEN
          cspks_dfproc.pr_Drawndowndfgorup(p_txmsg.txfields('20').VALUE ,p_err_code  );
         IF p_err_code <> 0 THEN
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
          --END IF;


        --END IF;
        --Ghi nhan vao crbdrawndowndtl de len phu luc danh sach chung khoan giai ngan
        /*for rec in (
            select df.*, sb.symbol,sb.DFREFPRICE from dfmast df, securities_info sb
            where df.codeid = sb.codeid and groupid = p_txmsg.txfields('20').VALUE
        )
        loop
            insert into crbdrawndowndtl
              (trfcode, objkey, txdate,groupid, dfacctno, symbol, qtty,
               mktprice, ratio, price, mktamt, amt,DFREFPRICE)
            values
              ('DFDRAWNDOWN',p_txmsg.txnum, p_txmsg.txdate, rec.groupid, rec.acctno,rec.symbol,rec.dfqtty+rec.rcvqtty+rec.blockqtty+rec.carcvqtty,
              rec.refprice, rec.dfrate, rec.dfprice, rec.refprice * (rec.dfqtty+rec.rcvqtty+rec.blockqtty+rec.carcvqtty), rec.dfprice * (rec.dfqtty+rec.rcvqtty+rec.blockqtty+rec.carcvqtty),rec.DFREFPRICE
              );
        end loop;*/
    END IF;

/*    select marginrate, mrirate
        into l_marginrate, l_mrirate
    from v_getsecmarginratio
    where afacctno = p_txmsg.txfields('03').VALUE;
    if l_marginrate < l_mrirate then
        p_err_code:='-180064';
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;*/
    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    --RETURN systemnums.C_SUCCESS;
   RETURN p_err_code;
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
         plog.init ('TXPKS_#2676EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2676EX;
/
