SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6611ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6611EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      27/07/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6611ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_version          CONSTANT CHAR(2) := '03';
   c_versionlocal     CONSTANT CHAR(2) := '02';
   c_txdate           CONSTANT CHAR(2) := '04';
   c_trfcode          CONSTANT CHAR(2) := '06';
   c_bankname         CONSTANT CHAR(2) := '94';
   c_bankque          CONSTANT CHAR(2) := '95';
   c_status          CONSTANT CHAR(2) := '07';
   c_oldstatus      CONSTANT CHAR(2) := '08';
   c_itemcount      CONSTANT CHAR(2) := '09';
   c_description      CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
   l_acctno varchar2(30);
   l_count NUMBER(10):= 0;
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
    l_acctno := p_txmsg.txfields('01').value;
    SELECT count(*) INTO l_count
    FROM CRBTRFLOG
    WHERE AUTOID= l_acctno;

    IF l_count = 0 THEN
        p_err_code := errnums.C_PRINTINFO_ACCTNOTFOUND;
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
    l_AUTOID number(20,0);
    l_VERSION number(20,0);
    l_BANKCODE varchar2(20);
    l_TRFCODE varchar2(20);
    l_TXDATE varchar2(10);
    l_oldSTATUS varchar2(1);
    l_newSTATUS varchar2(1);
    l_txoldSTATUS varchar2(1);
    l_itemCount number(20,0);
    l_cnt number(20,0);
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAftAppCheck');
   plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');


    l_AUTOID:=p_txmsg.txfields (c_autoid).value;
    l_newSTATUS:=p_txmsg.txfields (c_status).value;
    l_txoldSTATUS:=p_txmsg.txfields (c_oldstatus).value;
    l_itemCount:=p_txmsg.txfields (c_itemcount).value;

    SELECT VERSION,REFBANK,TRFCODE,TO_CHAR(TXDATE,'DD/MM/RRRR') TXDATE,STATUS
    INTO l_VERSION,l_BANKCODE,l_TRFCODE,l_TXDATE,l_oldSTATUS
    FROM CRBTRFLOG WHERE AUTOID=l_AUTOID;

    IF p_txmsg.deltd <> 'Y' THEN
        BEGIN
            IF l_newSTATUS='D' THEN --Xoa bang ke, chi xoa nhung bang ke cho duyet, bang ke da gui,bang ke cho gui, bang ke loi
                BEGIN
                    IF INSTR('PASEFHR',l_oldSTATUS)=0 THEN
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='B' THEN --Huy bang ke loi de gui lai
                BEGIN
                    IF INSTR('E/H/F/A/P/R',l_oldSTATUS)=0 THEN --GianhVG them xu ly cho trang thai A-Cho gui
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='F' THEN --Chuyen bang ke tu trang thai cho xac nhan,dang gui,da gui sang trang thai hoan thanh
                BEGIN
                    IF INSTR('PASEDRH',l_oldSTATUS)=0 THEN
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='P' THEN --Chuyen trang thai bang ke ve cho xu ly, chi danh cho cac bang ke da gui,hoan thanh,loi
                BEGIN
                    IF INSTR('S,F,E,A,R',l_oldSTATUS)=0 THEN --GianhVG them xu ly cho trang thai A-Cho gui
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            END IF;

        END;
    ELSE
        BEGIN
            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID;

            IF l_cnt<>l_itemCount THEN
                BEGIN
                    p_err_code:='-670077';
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END;
            END IF;

            IF l_oldSTATUS<>l_newSTATUS THEN
                BEGIN
                    p_err_code:='-670078';
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END;
            END IF;

            --Thuc hien rollback
            IF l_newSTATUS='B' THEN --Neu la gui lai
                BEGIN
                    SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                    FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                    WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                    AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                    AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                    AND REQ.STATUS='P';

                    IF l_cnt<>l_itemCount THEN
                        BEGIN
                            p_err_code:='-670077';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='D' THEN
                BEGIN
                    --Trang thai duoc rollback PASEF
                    IF INSTR('PAS',l_txoldSTATUS)>0 THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='A';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                        END;
                    ELSIF l_txoldSTATUS='E' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='E';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;
                        END;
                    ELSIF l_txoldSTATUS='F' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='C';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            p_err_code:='-100017';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='F' THEN
                BEGIN
                    --Trang thai duoc rollback PASEF
                    IF INSTR('PAS',l_txoldSTATUS)>0 THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='C';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                        END;
                    ELSIF l_txoldSTATUS='E' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='C';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;
                        END;
                    ELSIF l_txoldSTATUS='D' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID;

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            p_err_code:='-100017';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            END IF;
            plog.debug (pkgctx, 'Rollback 6611');
        END;
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
    l_AUTOID number(20,0);
    l_VERSION number(20,0);
    l_BANKCODE varchar2(20);
    l_TRFCODE varchar2(20);
    l_TXDATE varchar2(10);
    l_oldSTATUS varchar2(1);
    l_newSTATUS varchar2(1);
    l_txoldSTATUS varchar2(1);
    l_itemCount number(20,0);
    l_cnt number(20,0);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    l_AUTOID:=p_txmsg.txfields (c_autoid).value;
    l_newSTATUS:=p_txmsg.txfields (c_status).value;
    l_txoldSTATUS:=p_txmsg.txfields (c_oldstatus).value;
    l_itemCount:=p_txmsg.txfields (c_itemcount).value;

    SELECT VERSION,REFBANK,TRFCODE,TO_CHAR(TXDATE,'DD/MM/RRRR') TXDATE,STATUS
    INTO l_VERSION,l_BANKCODE,l_TRFCODE,l_TXDATE,l_oldSTATUS
    FROM CRBTRFLOG WHERE AUTOID=l_AUTOID;

    IF p_txmsg.deltd <> 'Y' THEN
        BEGIN
            IF l_newSTATUS='D' THEN --Xoa bang ke, chi xoa nhung bang ke cho duyet, bang ke da gui,bang ke cho gui, bang ke loi
                BEGIN
                    IF INSTR('PASEFHR',l_oldSTATUS)=0 THEN
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;

                    UPDATE CRBTRFLOG SET STATUS='D',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                    UPDATE CRBTRFLOGDTL SET STATUS='D' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');

                    IF l_oldSTATUS<>'H' THEN
                        UPDATE CRBTXREQ SET STATUS = 'D' WHERE REQID IN (
                          SELECT REFREQID FROM CRBTRFLOGDTL
                          WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                          AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                        );
                    END IF;
                END;
            ELSIF l_newSTATUS='B' THEN --Huy bang ke loi de gui lai
                BEGIN
                    IF INSTR('E/H/F/A/P/R',l_oldSTATUS)=0 THEN --GianhVG them xu ly cho trang thai A-Cho gui
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;

                    IF l_oldSTATUS='E' or l_oldSTATUS='R' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='B',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='B' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'P' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            )  AND STATUS='E';
                        END;
                    ELSIF l_oldSTATUS='H' THEN --Neu bang ke hoan thanh 1 phan, thi chi gui lai nhung dong bang ke loi
                        BEGIN
                            UPDATE CRBTRFLOGDTL SET STATUS='B' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            AND STATUS='E';

                            UPDATE CRBTXREQ SET STATUS = 'P' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            ) AND STATUS='E';
                        END;
                    ELSE
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='B',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='B' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');

                            UPDATE CRBTXREQ SET STATUS = 'P' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='F' THEN --Chuyen bang ke tu trang thai cho xac nhan,dang gui,da gui sang trang thai hoan thanh
                BEGIN
                    IF INSTR('PASEDRH',l_oldSTATUS)=0 THEN
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;

                    UPDATE CRBTRFLOG SET STATUS='F',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                  IF INSTR('H',l_oldSTATUS)=0  THEN
                    UPDATE CRBTRFLOGDTL SET STATUS='C' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                    UPDATE CRBTXREQ SET STATUS = 'C' WHERE REQID IN (
                        SELECT REFREQID FROM CRBTRFLOGDTL
                        WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                        AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                       );
                   END IF;
                END;
            ELSIF l_newSTATUS='P' THEN --Chuyen trang thai bang ke ve cho xu ly, chi danh cho cac bang ke da gui,hoan thanh,loi
                BEGIN
                    IF INSTR('S,F,E,A,R',l_oldSTATUS)=0 THEN --GianhVG them xu ly cho trang thai A-Cho gui
                        BEGIN
                            p_err_code:='-660001';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;

                    UPDATE CRBTRFLOG SET STATUS='P',PSTATUS=PSTATUS||STATUS
                    WHERE AUTOID=l_AUTOID;
                    UPDATE CRBTRFLOGDTL SET STATUS='P' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                    UPDATE CRBTXREQ SET STATUS = 'A' WHERE REQID IN (
                        SELECT REFREQID FROM CRBTRFLOGDTL
                        WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                        AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                    );
                END;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID;

            IF l_cnt<>l_itemCount THEN
                BEGIN
                    p_err_code:='-670077';
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END;
            END IF;

            IF l_oldSTATUS<>l_newSTATUS THEN
                BEGIN
                    p_err_code:='-670078';
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END;
            END IF;

            --Thuc hien rollback
            IF l_newSTATUS='B' THEN --Neu la gui lai
                BEGIN
                    SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                    FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                    WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                    AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                    AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                    AND REQ.STATUS='P';

                    IF l_cnt<>l_itemCount THEN
                        BEGIN
                            p_err_code:='-670077';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                    ---Trang thai E/F/H, neu H,A thi ko cho xoa, E,F thi se chuyen lai
                    IF l_txoldSTATUS='E' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='E',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='E' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'E' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='R' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='R',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='R' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'R' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='F' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='F',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='C' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'C' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSE
                        BEGIN
                            p_err_code:='-100017';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='D' THEN
                BEGIN
                    --Trang thai duoc rollback PASEF
                    IF INSTR('PAS',l_txoldSTATUS)>0 THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='D';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            IF l_txoldSTATUS='P' THEN
                                BEGIN
                                    UPDATE CRBTRFLOG SET STATUS='P',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                                    UPDATE CRBTRFLOGDTL SET STATUS='P' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                                END;
                            ELSIF l_txoldSTATUS='A' THEN
                                BEGIN
                                    UPDATE CRBTRFLOG SET STATUS='A',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                                    UPDATE CRBTRFLOGDTL SET STATUS='P' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                                END;
                            ELSIF l_txoldSTATUS='S' THEN
                                BEGIN
                                    UPDATE CRBTRFLOG SET STATUS='S',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                                    UPDATE CRBTRFLOGDTL SET STATUS='S' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                                END;
                            END IF;

                            UPDATE CRBTXREQ SET STATUS = 'A' WHERE REQID IN (
                            SELECT REFREQID FROM CRBTRFLOGDTL
                            WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='E' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='D';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            UPDATE CRBTRFLOG SET STATUS='E',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='E' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'E' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='R' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='D';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            UPDATE CRBTRFLOG SET STATUS='R',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='R' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'R' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='F' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='D';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            UPDATE CRBTRFLOG SET STATUS='F',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='C' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'C' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSE
                        BEGIN
                            p_err_code:='-100017';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='P' THEN
                BEGIN
                    --Trang thai duoc rollback bao gom : A/S/F/E
                    IF l_txoldSTATUS='E' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='E',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='E' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'E' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='R' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='R',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='R' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'R' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='S' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='S',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='S' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'A' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='F' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='F',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='C' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'C' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='A' THEN
                        BEGIN
                            UPDATE CRBTRFLOG SET STATUS='A',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='P' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'A' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    END IF;
                END;
            ELSIF l_newSTATUS='F' THEN
                BEGIN
                    --Trang thai duoc rollback PASE
                    IF INSTR('PAS',l_txoldSTATUS)>0 THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='C';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            IF l_txoldSTATUS='P' THEN
                                BEGIN
                                    UPDATE CRBTRFLOG SET STATUS='P',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                                    UPDATE CRBTRFLOGDTL SET STATUS='P' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                                END;
                            ELSIF l_txoldSTATUS='A' THEN
                                BEGIN
                                    UPDATE CRBTRFLOG SET STATUS='A',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                                    UPDATE CRBTRFLOGDTL SET STATUS='P' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                                END;
                            ELSIF l_txoldSTATUS='S' THEN
                                BEGIN
                                    UPDATE CRBTRFLOG SET STATUS='S',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                                    UPDATE CRBTRFLOGDTL SET STATUS='S' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                    AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                                END;
                            END IF;

                            UPDATE CRBTXREQ SET STATUS = 'A' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='E' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='C';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            UPDATE CRBTRFLOG SET STATUS='E',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='E' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'E' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='R' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID
                            AND REQ.STATUS='C';

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            UPDATE CRBTRFLOG SET STATUS='R',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='R' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                            UPDATE CRBTXREQ SET STATUS = 'R' WHERE REQID IN (
                                SELECT REFREQID FROM CRBTRFLOGDTL
                                WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                                AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR')
                            );
                        END;
                    ELSIF l_txoldSTATUS='D' THEN
                        BEGIN
                            --Kiem tra xem cac req con o trang thai cu ko
                            SELECT COUNT(DTL.AUTOID) CNT INTO l_cnt
                            FROM CRBTRFLOGDTL DTL,CRBTRFLOG TRF,CRBTXREQ REQ
                            WHERE DTL.REFREQID=REQ.REQID AND DTL.VERSION=TRF.VERSION
                            AND DTL.TRFCODE=TRF.TRFCODE AND DTL.BANKCODE=TRF.REFBANK
                            AND DTL.TXDATE=TRF.TXDATE AND TRF.AUTOID=l_AUTOID;

                            IF l_cnt<>l_itemCount THEN
                                BEGIN
                                    p_err_code:='-670077';
                                    RETURN errnums.C_BIZ_RULE_INVALID;
                                END;
                            END IF;

                            UPDATE CRBTRFLOG SET STATUS='D',PSTATUS=PSTATUS||STATUS WHERE AUTOID=l_AUTOID;
                            UPDATE CRBTRFLOGDTL SET STATUS='D' WHERE VERSION=l_VERSION AND BANKCODE=l_BANKCODE
                            AND TRFCODE=l_TRFCODE AND TXDATE=TO_DATE(l_TXDATE,'DD/MM/RRRR');
                        END;
                    ELSE
                        BEGIN
                            p_err_code:='-100017';
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END;
                    END IF;
                END;
            END IF;
            plog.debug (pkgctx, 'Rollback 6611');
        END;
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
         plog.init ('TXPKS_#6611EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#6611EX;
/
