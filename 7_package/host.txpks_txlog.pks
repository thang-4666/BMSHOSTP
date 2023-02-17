SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_txlog
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
     **  TienPQ      09-JUNE-2009    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
 IS


     

    PROCEDURE pr_update_status(txmsg IN OUT tx.msg_rectype);

    PROCEDURE pr_txdellog(p_txmsg     IN tx.msg_rectype,
                          p_err_code  OUT varchar2);

    

END;
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_txlog IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;

  PROCEDURE pr_update_status(txmsg IN OUT tx.msg_rectype) IS
    l_cfcustodycd varchar2(50);
    l_cffullname varchar2(50);
  BEGIN
    select cfcustodycd, cffullname
        into l_cfcustodycd, l_cffullname
    from tltx where tltxcd = txmsg.tltxcd;
    --05/04/2016, TruongLD Add, xu ly cap nhat lai cfcustodycd & cffullname trong tllog doi voi GD ko qua code VB
    If length(l_cfcustodycd) > 0 and l_cfcustodycd <> '##' Then
        Update tllog
            set cfcustodycd = txmsg.txfields(l_cfcustodycd).value
        where txnum = txmsg.txnum and txdate = to_date(txmsg.txdate,systemnums.c_date_format);
    End If;

    If length(l_cffullname) > 0 and l_cffullname <> '##' Then
        Update tllog
            set cffullname = txmsg.txfields(l_cffullname).value
        where txnum = txmsg.txnum and txdate = to_date(txmsg.txdate,systemnums.c_date_format);
    End If;
    --End TruongLD

    UPDATE tllog
       SET txstatus = txmsg.txstatus,
           ovrrqs   = txmsg.ovrsts,
           offid    = txmsg.offid,
           chkid    = txmsg.chkid,
           chid     = txmsg.chid,
           chktime  = DECODE(txmsg.chkid,
                             NULL,
                             TO_CHAR(SYSDATE, systemnums.C_TIME_FORMAT),
                             txmsg.chkid),
           offtime  = DECODE(txmsg.chkid,
                             NULL,
                             TO_CHAR(SYSDATE, systemnums.C_TIME_FORMAT),
                             Decode(txmsg.offtime, NUll, TO_CHAR(SYSDATE, systemnums.C_TIME_FORMAT), txmsg.offtime))
     WHERE txnum = txmsg.txnum
       AND txdate = TO_DATE(txmsg.txdate, systemnums.C_DATE_FORMAT);
  END pr_update_status;

  PROCEDURE pr_txdellog(p_txmsg     IN tx.msg_rectype,
                        p_err_code  OUT varchar2) IS
    l_exists VARCHAR2(15);
  BEGIN
    plog.setendsection(pkgctx, 'pr_txdellog');
    UPDATE tllog
       SET deltd = 'Y'
     WHERE txnum = p_txmsg.txnum
       AND txdate = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) RETURNING
     deltd INTO l_exists;

    IF NVL(l_exists, '$$') = '$$' THEN
      p_err_code  := '-100100';
      RAISE errnums.E_HOST_VOUCHER_NOT_FOUND;
    END IF;

    UPDATE vattran
       SET deltd = 'Y'
     WHERE txnum = p_txmsg.txnum
       AND txdate = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);

    /*UPDATE MITRAN SET DELTD='Y'
    WHERE TXNUM=p_txmsg.txnum
    AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');*/

    UPDATE feetran
       SET deltd = 'Y'
     WHERE txnum = p_txmsg.txnum
       AND txdate = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);

    plog.setendsection(pkgctx, 'pr_txdellog');
  END pr_txdellog;

BEGIN
  FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;

  pkgctx := plog.init('txpks_txlog',
                      plevel => logrow.loglevel,
                      plogtable => (logrow.log4table = 'Y'),
                      palert => (logrow.log4alert = 'Y'),
                      ptrace => (logrow.log4trace = 'Y'));
END txpks_txlog;
/
