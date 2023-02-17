SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_seproc
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
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
FUNCTION fn_TransferDTOCLOSE(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
   RETURN NUMBER;

FUNCTION fn_GetAvailableTrade(p_afacctno in VARCHAR2 , p_CodeID in varchar2)
   RETURN NUMBER;

-- TruongLD Add 2011/11/02 - Margin 74
FUNCTION fn_getSEDeposit(p_codeid IN VARCHAR2,p_afacctno IN varchar2)
    RETURN NUMBER;

  PROCEDURE pr_ExecuteOD9996 (p_orderid in VARCHAR2, p_err_code out varchar2,p_err_param out varchar2);

  PROCEDURE pr_execute_trigger_log (p_afacctno in VARCHAR2, p_codeid varchar2, p_trade number, p_receiving number);

FUNCTION fn_AdjustCostprice_Online(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
   RETURN NUMBER; -- Cap nhat gia von online. TheNN, 19-Jan-2012
 -- ThanhNM Add 2012/02/23 - Lay so luong CK da cam co
FUNCTION fn_getSEMORTAGE(p_codeid IN VARCHAR2,p_afacctno IN varchar2)
    RETURN NUMBER;

 FUNCTION fn_getSEMargin(p_codeid IN VARCHAR2,p_afacctno IN varchar2)
    RETURN varchar2;

END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_seproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   FUNCTION fn_TransferDTOCLOSE(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
   RETURN NUMBER
   IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strPREVDATE varchar2(20);
      v_strNEXTDATE varchar2(20);
      l_err_param   varchar2(300);
      l_lngErrCode  number(20,0);
      v_blnREVERSAL boolean;
      l_count       number;
  BEGIN

    plog.setbeginsection (pkgctx, 'fn_TransferDTOCLOSE');
    plog.debug (pkgctx, '<<BEGIN OF fn_TransferDTOCLOSE');
    v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;

    l_lngErrCode:= errnums.C_BIZ_RULE_INVALID;
    p_err_code:=0;

    --</ Kiem tra co co trong chu ki thanh toan khong -- 'van con tien nhan tien
    Begin
        SELECT COUNT(*) INTO l_count  FROM STSCHD WHERE SUBSTR(ACCTNO,1,10)= p_txmsg.txfields('02').value AND STATUS<>'C' AND DELTD<>'Y' AND DUETYPE ='RM';
    EXCEPTION
        WHEN OTHERS THEN  l_count := 0;
    END;
    IF l_count > 0 THEN
        plog.error(pkgctx,'l_lngErrCode: ' || '-400024');
        p_err_code := -400024;
        return l_lngErrCode;
    END IF;
    -- />

    --</ Kiem tra co co trong chu ki thanh toan khong -- van con chung khoan cho ve
    BEGIN
        SELECT COUNT(*) INTO l_count FROM STSCHD WHERE SUBSTR(ACCTNO,1,10)= p_txmsg.txfields('02').value AND STATUS<>'C' AND DELTD<>'Y' AND DUETYPE ='RS';
    EXCEPTION
        WHEN OTHERS THEN  l_count := 0;
    END;
    IF l_count > 0 THEN
        plog.error(pkgctx,'l_lngErrCode: ' || '-400025');
        p_err_code := -400025;
        return l_lngErrCode;
    END IF;
    --/>

    --</ ERR_SE_TRADE_NOT_ENOUGHT
    IF p_txmsg.DELTD ='N' THEN
        BEGIN
            SELECT COUNT(*) INTO l_count FROM SEMAST WHERE AFACCTNO= p_txmsg.txfields('02').value AND ACCTNO= p_txmsg.txfields('02').value AND TRADE >= p_txmsg.txfields('10').value;
        EXCEPTION
            WHEN OTHERS THEN  l_count := 0;
        END;
        IF l_count > 0 THEN
            plog.error(pkgctx,'l_lngErrCode: ' || '-900017');
            p_err_code := -900017;
            return l_lngErrCode;
        END IF;
      --  UPDATE semastdtl SET status='F' WHERE status='N' AND qttytype IN ('002','007','011') AND acctno = p_txmsg.txfields('03').value;
     ELSE
        BEGIN
            SELECT COUNT(*) INTO l_count FROM SEMAST WHERE AFACCTNO= p_txmsg.txfields('02').value AND ACCTNO= p_txmsg.txfields('02').value AND DTOCLOSE >= p_txmsg.txfields('10').value;
        EXCEPTION
            WHEN OTHERS THEN  l_count := 0;
        END;
        IF l_count > 0 THEN
            plog.error(pkgctx,'l_lngErrCode: ' || '-900032');
            p_err_code := -900032;
            return l_lngErrCode;
        END IF;
      --   UPDATE semastdtl SET status='N' WHERE status='F' AND qttytype IN ('002','007','011') AND acctno = p_txmsg.txfields('03').value;
     END IF;
    --/>

    p_err_code:=0;
    plog.debug (pkgctx, '<<END OF fn_TransferDTOCLOSE');
    plog.setendsection (pkgctx, 'fn_TransferDTOCLOSE');
    RETURN systemnums.C_SUCCESS;

  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on release fn_TransferDTOCLOSE');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_TransferDTOCLOSE');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_TransferDTOCLOSE;


    FUNCTION fn_GetAvailableTrade(p_afacctno in VARCHAR2 , p_CodeID in varchar2)
   RETURN NUMBER
   IS
      l_Trading       number;
      l_afacctno    VARCHAR2(10);
      l_CodeID      VARCHAR2(6);
  BEGIN

    plog.setbeginsection (pkgctx, 'fn_GetAvailableTrade');
    plog.debug (pkgctx, '<<BEGIN OF fn_GetAvailableTrade');
    l_afacctno := p_afacctno;
    l_CodeID   := p_CodeID;
    l_Trading  := 0;



    Begin
        Select greatest(semast.trade - nvl(b.secureamt,0) + nvl(b.sereceiving,0),0) into l_Trading
        From SEMAST , v_getsellorderinfo b, (select codeid, tradelot from securities_info) seinfo,
                    (SELECT afacctno,codeid, sum(dfqtty) sumdfqtty FROM dfmast GROUP BY afacctno, codeid) df
        WHERE semast.afacctno = l_afacctno And semast.CodeID = l_CodeID AND semast.codeid = seinfo.codeid(+) AND ACCTNO = b.seacctno(+) AND df.afacctno(+) = semast.afacctno AND df.codeid(+) = semast.codeid;
    EXCEPTION
      WHEN OTHERS THEN l_Trading := 0;
    END;

    plog.debug (pkgctx,'l_CodeID:' || l_CodeID);
    plog.debug (pkgctx,'l_Trading:' || l_Trading);

    Return l_Trading;

    plog.setendsection (pkgctx, 'fn_GetAvailableTrade');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on release fn_GetAvailableTrade');
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_GetAvailableTrade');
      return 0;
  END fn_GetAvailableTrade;


    -- TruongLD Add 2011/11/02 - Margin 74
    ---------------------------------fn_getSEDeposit------------------------------------------------
    FUNCTION fn_getSEDeposit(p_codeid IN VARCHAR2,p_afacctno IN varchar2)
    RETURN NUMBER
    IS
    l_Ri NUMBER;
    l_Rtt NUMBER;
    l_MRAi NUMBER;
    l_TAV NUMBER;
    l_Pi NUMBER;
    l_Pimax NUMBER;
    l_actype VARCHAR2(5);
    l_sedeposit NUMBER;
    BEGIN
        plog.setendsection(pkgctx, 'fn_getSEDeposit');
        IF p_codeid IS NULL or length(trim(p_codeid)) = 0 THEN
            RETURN 0;
        ELSE
            begin
                select
                    round ((sec74.MRIRATIO/100 - nvl(sec74.MARGINRATE74,0))
                                    / (1-sec74.MRIRATIO/100) * (nvl(sec74.SEASS,0) + greatest(sec74.outstanding,0))

                    / least(nvl(sb.marginprice,0),nvl(rsk.mrpricerate,0)) ,0)
                into l_sedeposit

                from afmast af, aftype aft, mrtype mrt, afserisk rsk, securities_info sb, (select * from v_getsecmarginratio_74 where afacctno = p_afacctno) sec74
                where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
                and sb.codeid = p_codeid and rsk.codeid = sb.codeid and af.actype = rsk.actype(+)
                and af.acctno = sec74.afacctno(+)
                and af.acctno = p_afacctno;

            exception when others then
            dbms_output.put_line('AAA');
                return 0;
            end;
            RETURN round( greatest(l_sedeposit,0),4);
        END if;

    EXCEPTION
    WHEN OTHERS
    THEN
      plog.setendsection (pkgctx, 'fn_getSEDeposit');
      return 0;
    END fn_getSEDeposit;

 FUNCTION fn_getSEMORTAGE(p_codeid IN VARCHAR2,p_afacctno IN varchar2)
    RETURN NUMBER
    IS
    v_QTTY number;
    BEGIN
        v_QTTY:=0;

        IF p_codeid IS NULL or length(trim(p_codeid)) = 0 THEN
            RETURN 0;
        ELSE
            select nvl(mortage,0) into v_QTTY from semast where afacctno= p_afacctno and codeid= p_codeid;
            RETURN v_QTTY;

        END if;
    return v_QTTY;
    EXCEPTION
    WHEN OTHERS
    THEN
          return v_QTTY;
    END fn_getSEMORTAGE;


 FUNCTION fn_getSEMargin(p_codeid IN VARCHAR2,p_afacctno IN varchar2)
    RETURN varchar2
    IS
    v_return varchar2(100);
    BEGIN
        v_return:='Chung khoan khong margin';

        IF p_codeid IS NULL or length(trim(p_codeid)) = 0 THEN
            RETURN '';
        ELSE
            IF p_afacctno IS NULL or length(trim(p_afacctno)) = 0 THEN
                RETURN '';
            else
                begin
                    select nvl(max(case when afr.ismarginallow='Y' then 'Chung khoan margin ty le:' || afr.mrratiorate || '%' else 'Chung khoan khong margin'  end),'Chung khoan khong margin')
                        into v_return
                    from afserisk afr, afmast af
                    where af.actype = afr.actype and codeid =p_codeid and af.acctno =p_afacctno;
                exception when others then
                    return v_return;
                end;
            end if;

        END if;
        return v_return;
    EXCEPTION
    WHEN OTHERS
    THEN
          return '';
    END fn_getSEMargin;


PROCEDURE pr_execute_trigger_log (p_afacctno in VARCHAR2, p_codeid varchar2, p_trade number, p_receiving number)
IS
BEGIN
    plog.setbeginsection (pkgctx, 'pr_execute_trigger_log');
    plog.debug (pkgctx, '<<BEGIN OF pr_execute_trigger_log');
    insert into afseinfo_log (autoid,afacctno,codeid,trade,receiving,status)
    values (seq_afseinfo_log.nextval,p_afacctno,p_codeid,p_trade,p_receiving,'P' );
    plog.setendsection (pkgctx, 'pr_execute_trigger_log');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_execute_trigger_log');
    plog.setbeginsection(pkgctx, 'pr_execute_trigger_log');
END pr_execute_trigger_log;

PROCEDURE pr_ExecuteOD9996 (p_orderid in VARCHAR2, p_err_code out varchar2,p_err_param out varchar2)
IS
l_err_param varchar2(30);
l_err_code varchar2(30);
BEGIN

l_err_param:= 'SYSTEM_SUCCESS';
l_err_code:= systemnums.C_SUCCESS;
p_err_code:= systemnums.C_SUCCESS;

plog.setbeginsection (pkgctx, 'pr_ExecuteOD9996');
plog.debug (pkgctx, '<<BEGIN OF pr_ExecuteOD9996');

 UPDATE ODMAST SET DELTD='Y', EXECAMT=0, EXECQTTY=0, REMAINQTTY=0, CANCELQTTY= ORDERQTTY, ORSTATUS=2 WHERE ORDERID=p_orderid;
 UPDATE OOD SET DELTD='Y' WHERE ORGORDERID=p_orderid;
 UPDATE IOD SET DELTD='Y' WHERE ORGORDERID=p_orderid;
 UPDATE STSCHD SET DELTD='Y' WHERE ORGORDERID=p_orderid;

 for rec in (SELECT * FROM ODMAPEXT WHERE ORDERID=p_orderid AND DELTD<>'Y')
 LOOP
     if  rec.type IN ('S')  then
         UPDATE SEMAST SET TRADE=TRADE+rec.QTTY, GRPORDAMT=GRPORDAMT-rec.qtty where  acctno= rec.refid;
     END IF;
     if  rec.type IN ('O')  then
         UPDATE SEMAST SET TRADE=TRADE+rec.QTTY, GRPORDAMT=GRPORDAMT-rec.qtty where  acctno in( select seacctno from odmast where orderid = rec.refid);
     END IF;

     if rec.type IN ('D','M')  THEN
         UPDATE DFMAST SET DFQTTY=DFQTTY+rec.QTTY, GRPORDAMT=GRPORDAMT-rec.qtty where  acctno= rec.refid;
         UPDATE SEMAST SET MORTAGE = MORTAGE + rec.QTTY WHERE ACCTNO IN (SELECT AFACCTNO||CODEID FROM DFMAST WHERE ACCTNO=rec.refid);
     end if;

     UPDATE ODMAPEXT SET DELTD='Y' WHERE ORDERID=p_orderid and REFID = rec.refid and qtty = rec.qtty AND ORDERNUM=rec.ordernum;

 END LOOP;

plog.setendsection (pkgctx, 'pr_ExecuteOD9996');
EXCEPTION

WHEN OTHERS THEN
plog.error(SQLERRM);
   ROLLBACK;
   plog.debug (pkgctx,'got error on release pr_ExecuteOD9996');
    plog.setbeginsection(pkgctx, 'pr_ExecuteOD9996');
     p_err_code := errnums.C_SYSTEM_ERROR;
     p_err_param := 'SYSTEM_ERROR';

END pr_ExecuteOD9996;

-- Cap nhat gia von ONLINE
-- TheNN, 19-Jan-2012
FUNCTION fn_AdjustCostprice_Online(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
    RETURN NUMBER
    IS
        l_err_param   varchar2(300);
        l_lngErrCode  number(20,0);
        v_blnREVERSAL boolean;
        v_qtty NUMBER;
    BEGIN

        plog.setbeginsection (pkgctx, 'fn_AdjustCostprice_Online');
        plog.debug (pkgctx, '<<BEGIN OF fn_AdjustCostprice_Online');
        v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;

     /*SELECT  sum(trade+ standing +withdraw +blocked + dtoclose+ blockdtoclose+ blockwithdraw+ emkqtty + nvl(qtty,0) - nvl(tr.DCRQTTY,0)+ nvl(tr.DDROUTQTTY,0) ) INTO v_qtty
     FROM semast se,
        (SELECT sum(qtty) qtty, acctno  FROM stschd WHERE duetype ='RS' AND DELTD <>'Y' GROUP BY acctno   )sts,
        ( SELECT acctno,  SUM(CASE WHEN se.FIELD = 'DCRQTTY' THEN NVL(se.NAMT,0) * DECODE(se.TXTYPE, 'C', 1, -1)  ELSE 0 END) DCRQTTY,
                 SUM(CASE WHEN se.FIELD = 'DDROUTQTTY' THEN NVL(se.NAMT,0) * DECODE(se.TXTYPE, 'C', 1, -1)  ELSE 0 END) DDROUTQTTY
                 FROM  vw_setran_gen se WHERE txdate = getcurrdate ()
                 GROUP BY acctno ) tr
        WHERE se.acctno = sts.acctno (+)
        AND se.acctno = tr.acctno (+)
        AND se.afacctno =p_txmsg.txfields('02').value
        AND se.codeid IN (SELECT codeid FROM sbsecurities WHERE codeid = p_txmsg.txfields('01').value --OR refcodeid = p_txmsg.txfields('01').value
        );*/
        --Ngay 11/01/2016 NamTv chinh lai bo cap nhat lai prevqtty

        if not v_blnREVERSAL THEN
            -- Ghi nhan vao bang thong tin gia von
            -- Cap nhat gia von online chi cho phep khi gia von = 0
            INSERT INTO SECOSTPRICE (AUTOID, ACCTNO, TXDATE, COSTPRICE, PREVCOSTPRICE, DCRAMT, DCRQTTY, DELTD)
            SELECT SEQ_SECOSTPRICE.NEXTVAL, p_txmsg.txfields('03').value, getcurrdate,
                    round(p_txmsg.txfields('10').value,4), 0, round(p_txmsg.txfields('10').value,4), v_qtty, 'N'
            FROM dual;

            -- Cap nhat vao SEMAST
            UPDATE SEMAST SET COSTPRICE = round(p_txmsg.txfields('10').value,4)--,prevqtty = v_qtty
            WHERE ACCTNO= p_txmsg.txfields('03').value;
        ELSE
            -- Reversal
            -- update SEMAST
            UPDATE SEMAST SET COSTPRICE = 0 WHERE ACCTNO= p_txmsg.txfields('03').value;
            -- Update SECOSTPRICE
            UPDATE SECOSTPRICE SET DELTD = 'Y' WHERE ACCTNO = p_txmsg.txfields('03').value AND TXDATE = GETCURRDATE;
        END IF;

        p_err_code:=0;
        plog.debug (pkgctx, '<<END OF fn_AdjustCostprice_Online');
        plog.setendsection (pkgctx, 'fn_AdjustCostprice_Online');
        RETURN systemnums.C_SUCCESS;

    EXCEPTION
        WHEN OTHERS
        THEN
            plog.debug (pkgctx,'got error on release fn_AdjustCostprice_Online');
            ROLLBACK;
            p_err_code := errnums.C_SYSTEM_ERROR;
            plog.error (pkgctx, SQLERRM);
            plog.setendsection (pkgctx, 'fn_AdjustCostprice_Online');
            RAISE errnums.E_SYSTEM_ERROR;
    END fn_AdjustCostprice_Online;



-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_seproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
