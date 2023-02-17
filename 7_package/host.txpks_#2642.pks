SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2642
/** ----------------------------------------------------------------------------------------------------
 ** Module: TX
 ** Description: Deal payment
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      05/10/2011     Created
 ** (c) 2008 by Financial Software Solutions. JSC.
 ----------------------------------------------------------------------------------------------------*/
IS

FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
FUNCTION fn_BatchTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
FUNCTION fn_txrevert(p_txnum varchar2,p_txdate varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#2642
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

PROCEDURE pr_txlog(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
IS
BEGIN
plog.setbeginsection (pkgctx, 'pr_txlog');
   plog.debug(pkgctx, 'abt to insert into tllog, txnum: ' || p_txmsg.txnum);
   INSERT INTO tllog(autoid, txnum, txdate, txtime, brid, tlid,offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line, deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts, ovrsts, batchname, msgamt,msgacct, chktime, offtime)
       VALUES(
       seq_tllog.NEXTVAL,
       p_txmsg.txnum,
       TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
       p_txmsg.txtime,
       p_txmsg.brid,
       p_txmsg.tlid,
       p_txmsg.offid,
       p_txmsg.ovrrqd,
       p_txmsg.chid,
       p_txmsg.chkid,
       p_txmsg.tltxcd,
       p_txmsg.ibt,
       p_txmsg.brid2,
       p_txmsg.tlid2,
       p_txmsg.ccyusage,
       p_txmsg.off_line,
       p_txmsg.deltd,
       TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
       TO_DATE(p_txmsg.busdate, systemnums.C_DATE_FORMAT),
       NVL(p_txmsg.txfields('30').value,p_txmsg.txdesc),
       p_txmsg.ipaddress,
       p_txmsg.wsname,
       p_txmsg.txstatus,
       p_txmsg.msgsts,
       p_txmsg.ovrsts,
       p_txmsg.batchname,
       p_txmsg.txfields('45').value , 
       p_txmsg.txfields('02').value , 
       TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.chkid,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.chkid)),
       TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT) --decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.offtime))
       );


   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'02',0,p_txmsg.txfields('02').value,'Deal ID');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'88',0,p_txmsg.txfields('88').value,'Custody code');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'03',0,p_txmsg.txfields('03').value,'Loan account');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'05',0,p_txmsg.txfields('05').value,'Sub account');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'57',0,p_txmsg.txfields('57').value,'Fullname');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'58',0,p_txmsg.txfields('58').value,'Address');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'59',0,p_txmsg.txfields('59').value,'License');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'08',0,p_txmsg.txfields('08').value,'GL Bank account');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'01',0,p_txmsg.txfields('01').value,'Internal securities code');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'06',0,p_txmsg.txfields('06').value,'SE account');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'07',0,p_txmsg.txfields('07').value,'Loan type');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'14',TO_NUMBER(p_txmsg.txfields('14').value),NULL,'Principal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'16',TO_NUMBER(p_txmsg.txfields('16').value),NULL,'Paid Principal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'18',TO_NUMBER(p_txmsg.txfields('18').value),NULL,'Total Intererest');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'19',TO_NUMBER(p_txmsg.txfields('19').value),NULL,'Paid Intererest');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'45',TO_NUMBER(p_txmsg.txfields('45').value),NULL,'Paid amount for principal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'13',TO_NUMBER(p_txmsg.txfields('13').value),NULL,'Overdue principal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'15',TO_NUMBER(p_txmsg.txfields('15').value),NULL,'Indue principal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'23',TO_NUMBER(p_txmsg.txfields('23').value),NULL,'Int. overdue');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'26',TO_NUMBER(p_txmsg.txfields('26').value),NULL,'Int. on overdue principal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'31',TO_NUMBER(p_txmsg.txfields('31').value),NULL,'Int. maturity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'35',TO_NUMBER(p_txmsg.txfields('35').value),NULL,'Int. normal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'36',TO_NUMBER(p_txmsg.txfields('36').value),NULL,'Fee amount');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'37',TO_NUMBER(p_txmsg.txfields('37').value),NULL,'Available quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'38',TO_NUMBER(p_txmsg.txfields('38').value),NULL,'Receiving quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'39',TO_NUMBER(p_txmsg.txfields('39').value),NULL,'CA receiving quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'40',TO_NUMBER(p_txmsg.txfields('40').value),NULL,'Block quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'42',TO_NUMBER(p_txmsg.txfields('42').value),NULL,'Sell quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'43',TO_NUMBER(p_txmsg.txfields('43').value),NULL,'Seccured quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'50',TO_NUMBER(p_txmsg.txfields('50').value),NULL,'Released quantity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'51',TO_NUMBER(p_txmsg.txfields('51').value),NULL,'Released amount');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'53',TO_NUMBER(p_txmsg.txfields('53').value),NULL,'Deal total fee/interest');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'52',TO_NUMBER(p_txmsg.txfields('52').value),NULL,'Total release amount');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'90',TO_NUMBER(p_txmsg.txfields('90').value),NULL,'Fee amount');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'46',TO_NUMBER(p_txmsg.txfields('46').value),NULL,'Release QTTY');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'48',TO_NUMBER(p_txmsg.txfields('48').value),NULL,'Maximum release QTTY');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'47',TO_NUMBER(p_txmsg.txfields('47').value),NULL,'Trade lot');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'49',0,p_txmsg.txfields('49').value,'Release date');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'41',TO_NUMBER(p_txmsg.txfields('41').value),NULL,'Overdraft amount');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'63',TO_NUMBER(p_txmsg.txfields('63').value),NULL,'Paid for prin. overdue');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'65',TO_NUMBER(p_txmsg.txfields('65').value),NULL,'Paid for prin. undue');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'72',TO_NUMBER(p_txmsg.txfields('72').value),NULL,'Paid for int. overdue');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'74',TO_NUMBER(p_txmsg.txfields('74').value),NULL,'Paid for int. on prin. overdue');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'77',TO_NUMBER(p_txmsg.txfields('77').value),NULL,'Paid for int. maturity');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'80',TO_NUMBER(p_txmsg.txfields('80').value),NULL,'Paid for int. normal');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'91',TO_NUMBER(p_txmsg.txfields('91').value),NULL,'Release available qtty');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'92',TO_NUMBER(p_txmsg.txfields('92').value),NULL,'Release receiving qtty');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'93',TO_NUMBER(p_txmsg.txfields('93').value),NULL,'Release CA receiving qtty');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'94',TO_NUMBER(p_txmsg.txfields('94').value),NULL,'Release block qtty');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'29',0,p_txmsg.txfields('29').value,'Reference');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'95',0,p_txmsg.txfields('95').value,'Drawndown ID');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'96',0,p_txmsg.txfields('96').value,'Cash drawndown');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'99',0,p_txmsg.txfields('99').value,'Limit check');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'97',0,p_txmsg.txfields('97').value,'Bank drawndown');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'98',0,p_txmsg.txfields('98').value,'Company drawndown');
   plog.debug(pkgctx, 'abt to insert into tllogfld');
   INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
      VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'30',0,p_txmsg.txfields('30').value,'Description');
       plog.debug(pkgctx,'Check if neccessary to poplulate FEETRAN and VATTRAN');
   IF p_txmsg.txinfo.exists(txnums.C_TXINFO_VATTRAN) THEN
       plog.debug(pkgctx,'Abt to insert into VATTRAN');
       INSERT INTO VATTRAN (AUTOID,TXNUM,TXDATE,VOUCHERNO,VOUCHERTYPE,SERIENO,VOUCHERDATE,CUSTID,TAXCODE,CUSTNAME,ADDRESS,CONTENTS,QTTY, PRICE,AMT,VATRATE,VATAMT,DESCRIPTION,DELTD)
       VALUES (
           SEQ_VATTRAN.NEXTVAL,
           p_txmsg.txnum,
           TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERNO), -- voucherno
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERTYPE), -- vouchertype
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_SERIALNO), -- serieno
           TO_DATE(p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VOUCHERDATE),systemnums.C_DATE_FORMAT), --voucherdate
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CUSTID ), -- CUSTID
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_TAXCODE ), -- TAXCODE 
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CUSTNAME ), -- CUSTNAME 
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_ADDRESS ), -- ADDRESS 
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_CONTENTS ), -- CONTENTS 
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_QTTY ), -- QTTY
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_PRICE ), -- PRICE
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_AMT ), -- AMT
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VATRATE ), -- VATRATE
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_VATAMT ), -- VATAMT
           p_txmsg.txinfo(txnums.C_TXINFO_VATTRAN)(txnums.C_VATTRAN_DESCRIPTION ), -- DESCRIPTION
           txnums.C_DELTD_TXNORMAL);
   END IF;
       plog.debug(pkgctx,'Abt to insert into FEETRAN');
   IF p_txmsg.txinfo.exists(txnums.C_TXINFO_FEETRAN ) THEN
        INSERT INTO FEETRAN(AUTOID,TXDATE,TXNUM,DELTD,FEECD,GLACCTNO,FEEAMT,VATAMT,TXAMT,FEERATE,VATRATE)
        VALUES (
            SEQ_FEETRAN.NEXTVAL,
            TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
            p_txmsg.txnum, --TXNUM
            txnums.C_DELTD_TXNORMAL,
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN )(txnums.C_FEETRAN_FEECD),  --FEECD
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_GLACCTNO),  --GLACCTNO
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_FEEAMT),  --FEEAMT
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_VATAMT),  --VATAMT
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_TXAMT),  --TXAMT
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_FEERATE),  --FEERATE
            p_txmsg.txinfo(txnums.C_TXINFO_FEETRAN)(txnums.C_FEETRAN_VATRATE)); --VATRATE
   END IF;
   plog.setendsection (pkgctx, 'pr_txlog');
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'pr_txlog');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_txlog;-- 


PROCEDURE pr_PrintInfo(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
IS
   l_sectype  semast.actype%TYPE;
   l_codeid varchar2(6);
   l_acctno varchar2(30);
   l_custid afmast.custid%TYPE;
   l_afacctno afmast.acctno%TYPE;
   l_count NUMBER(10):= 0;
BEGIN
   plog.setbeginsection (pkgctx, 'pr_PrintInfo');


    --<<BEGIN OF PROCESS CIMAST>>
    l_acctno := p_txmsg.txfields('05').value;
    SELECT count(*) INTO l_count
    FROM CIMAST
    WHERE ACCTNO= l_acctno;

    IF l_count = 0 THEN
        p_err_code := errnums.C_PRINTINFO_ACCTNOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END IF;
    BEGIN
         SELECT FULLNAME CUSTNAME, ADDRESS, IDCODE LICENSE, CUSTODYCD
         INTO p_txmsg.txPrintInfo('05').custname,p_txmsg.txPrintInfo('05').address,p_txmsg.txPrintInfo('05').license,p_txmsg.txPrintInfo('05').custody
         FROM CFMAST A
         WHERE EXISTS (
             SELECT 1 FROM CIMAST
             WHERE CUSTID=A.CUSTID
             AND ACCTNO = l_acctno
         );
    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END;
    --<<END OF PROCESS CIMAST>>


    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN 
    --<<BEGIN OF PROCESS CIMAST>>
    l_acctno := p_txmsg.txfields('95').value;
    SELECT count(*) INTO l_count
    FROM CIMAST
    WHERE ACCTNO= l_acctno;

    IF l_count = 0 THEN
        p_err_code := errnums.C_PRINTINFO_ACCTNOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END IF;
    BEGIN
         SELECT FULLNAME CUSTNAME, ADDRESS, IDCODE LICENSE, CUSTODYCD
         INTO p_txmsg.txPrintInfo('95').custname,p_txmsg.txPrintInfo('95').address,p_txmsg.txPrintInfo('95').license,p_txmsg.txPrintInfo('95').custody
         FROM CFMAST A
         WHERE EXISTS (
             SELECT 1 FROM CIMAST
             WHERE CUSTID=A.CUSTID
             AND ACCTNO = l_acctno
         );
    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END;
    --<<END OF PROCESS CIMAST>>

    END IF;

    --<<BEGIN OF PROCESS LNMAST>>
    l_acctno := p_txmsg.txfields('03').value;
    SELECT count(*) INTO l_count
    FROM LNMAST
    WHERE ACCTNO= l_acctno;

    IF l_count = 0 THEN
        p_err_code := errnums.C_PRINTINFO_ACCTNOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END IF;
    BEGIN
         SELECT FULLNAME CUSTNAME, CFMAST.ADDRESS, CFMAST.IDCODE LICENSE, CFMAST.CUSTODYCD
         INTO p_txmsg.txPrintInfo('03').custname,p_txmsg.txPrintInfo('03').address,p_txmsg.txPrintInfo('03').license,p_txmsg.txPrintInfo('03').custody
         FROM CFMAST , AFMAST ,  LNMAST MST
         WHERE CFMAST.CUSTID = AFMAST.CUSTID
         AND AFMAST.ACCTNO=MST.TRFACCTNO
         AND MST.ACCTNO = l_acctno;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
        RAISE errnums.E_PRINTINFO_ACCTNOTFOUND;
    END;
    --<<END OF PROCESS LNMAST>>


    plog.setendsection (pkgctx, 'pr_PrintInfo');
END pr_PrintInfo;

FUNCTION fn_txAppAutoCheck(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2)
RETURN  NUMBER IS 
   l_allow         boolean;

    l_dftrading apprules.field%TYPE;
    l_status apprules.field%TYPE;
    l_prinnml apprules.field%TYPE;
    l_pp apprules.field%TYPE;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_dfmastcheck_arr txpks_check.dfmastcheck_arrtype;
    l_lnmastcheck_arr txpks_check.lnmastcheck_arrtype;
BEGIN
plog.setbeginsection (pkgctx, 'fn_txAppAutoCheck');
   IF p_txmsg.deltd = 'N' THEN

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('02').value,'DFMAST','02','2642')<>'TRUE' then 
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('03').value,'LNMAST','03','2642')<>'TRUE' then 
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('05').value,'CIMAST','05','2642')<>'TRUE' then 
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('95').value,'CIMAST','95','2642')<>'TRUE' then 
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     l_DFMASTcheck_arr := txpks_check.fn_DFMASTcheck(p_txmsg.txfields('02').value,'DFMAST','ACCTNO');

     l_DFTRADING := l_DFMASTcheck_arr(0).DFTRADING;
     l_STATUS := l_DFMASTcheck_arr(0).STATUS;
     l_STATUS := l_DFMASTcheck_arr(0).STATUS;

     IF NOT (to_number(l_DFTRADING) >= to_number(p_txmsg.txfields('91').value)) THEN
        p_err_code := '-269003';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
     IF NOT ( INSTR('A',l_STATUS) > 0) THEN
        p_err_code := '-400004';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
     IF NOT ( INSTR('A',l_STATUS) > 0) THEN
        p_err_code := '-400004';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN 

     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('95').value,'CIMAST','ACCTNO');

     l_STATUS := l_CIMASTcheck_arr(0).STATUS;

     IF NOT ( INSTR('ANT',l_STATUS) > 0) THEN
        p_err_code := '-400100';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
    END IF;

       SELECT  STATUS, PRINNML
      INTO l_STATUS,l_PRINNML
        FROM LNMAST
        WHERE ACCTNO = p_txmsg.txfields('03').value;

     IF NOT ( INSTR('NOSBL',l_STATUS) > 0) THEN
        p_err_code := '-540001';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
     IF NOT (to_number(l_PRINNML) >= to_number(p_txmsg.txfields('65').value)) THEN
        p_err_code := '-540002';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;


     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('05').value,'CIMAST','ACCTNO');

     l_STATUS := l_CIMASTcheck_arr(0).STATUS;
     l_PP := l_CIMASTcheck_arr(0).PP;

     IF NOT ( INSTR('A',l_STATUS) > 0) THEN
        p_err_code := '-400100';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
     IF NOT (to_number(l_PP) >= to_number(ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0))) THEN
        p_err_code := '-400116';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

    END IF;
   --plog.debug (pkgctx, 'Begin of checking pool and room');
   IF txpks_prchk.fn_txAutoCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        Return errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'End of checking pool and room');
   plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
  WHEN others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppAutoCheck;

FUNCTION fn_txAppAutoUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN  NUMBER
IS 
l_txdesc VARCHAR2(1000);
BEGIN
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction

      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2642','CI','0011');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2642','CI','0028');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0028',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0071',ROUND(p_txmsg.txfields('99').value*(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value),0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN 
      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2642','CI','0012');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('95').value,'0012',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
    END IF;
    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN 
      l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'2642','CI','0029');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('95').value,'0029',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
    END IF;
      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0043',ROUND(p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0045',ROUND(p_txmsg.txfields('93').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0011',ROUND(p_txmsg.txfields('91').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0023',ROUND(p_txmsg.txfields('90').value,4),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0041',ROUND(p_txmsg.txfields('92').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0020',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0028',ROUND(p_txmsg.txfields('90').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0016',ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0025',ROUND(p_txmsg.txfields('77').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0041',ROUND(p_txmsg.txfields('80').value,4),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0027',ROUND(p_txmsg.txfields('72').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0043',ROUND(p_txmsg.txfields('74').value,4),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0024',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0015',ROUND(p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0017',ROUND(p_txmsg.txfields('63').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0014',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('06').value,'0043',ROUND(p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('06').value,'0066',ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('94').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('06').value,'0012',ROUND(p_txmsg.txfields('91').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('05').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



      UPDATE DFMAST
         SET 
           INTAMTACR = INTAMTACR - (ROUND(p_txmsg.txfields('90').value,4)),
           BLOCKQTTY = BLOCKQTTY - (ROUND(p_txmsg.txfields('94').value,0)),
           CARCVQTTY = CARCVQTTY - (ROUND(p_txmsg.txfields('93').value,0)),
           RLSAMT = RLSAMT + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)),
           RCVQTTY = RCVQTTY - (ROUND(p_txmsg.txfields('92').value,0)),
           RLSFEEAMT = RLSFEEAMT + (ROUND(p_txmsg.txfields('90').value,0)),
           DFQTTY = DFQTTY - (ROUND(p_txmsg.txfields('91').value,0)),
           RLSQTTY = RLSQTTY + (ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('02').value;


      UPDATE SEMAST
         SET 
           BLOCKED = BLOCKED + (ROUND(p_txmsg.txfields('94').value,0)),
           TRADE = TRADE + (ROUND(p_txmsg.txfields('91').value,0)),
           MORTAGE = MORTAGE - (ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('94').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('06').value;

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN 

      UPDATE CIMAST
         SET 
           BALANCE = BALANCE + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('95').value;
    END IF;

      UPDATE LNMAST
         SET 
           PRINOVD = PRINOVD - (ROUND(p_txmsg.txfields('63').value,0)),
           INTNMLACR = INTNMLACR - (ROUND(p_txmsg.txfields('80').value,4)),
           INTDUE = INTDUE - (ROUND(p_txmsg.txfields('77').value,0)),
           PRINNML = PRINNML - (ROUND(p_txmsg.txfields('65').value,0)),
           INTNMLOVD = INTNMLOVD - (ROUND(p_txmsg.txfields('72').value,0)),
           INTPAID = INTPAID + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0)),
           INTOVDACR = INTOVDACR - (ROUND(p_txmsg.txfields('74').value,4)),
           PRINPAID = PRINPAID + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;


      UPDATE CIMAST
         SET 
           BALANCE = BALANCE - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) - (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)),
           DFODAMT = DFODAMT - (ROUND(p_txmsg.txfields('99').value*(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value),0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;

   ELSE -- Reversal
UPDATE TLLOG 
 SET DELTD = 'Y'
      WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE CITRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE LNTRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE DFTRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE SETRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);




      UPDATE DFMAST
      SET 
           INTAMTACR=INTAMTACR + (ROUND(p_txmsg.txfields('90').value,4)),
           BLOCKQTTY=BLOCKQTTY + (ROUND(p_txmsg.txfields('94').value,0)),
           CARCVQTTY=CARCVQTTY + (ROUND(p_txmsg.txfields('93').value,0)),
           RLSAMT=RLSAMT - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)),
           RCVQTTY=RCVQTTY + (ROUND(p_txmsg.txfields('92').value,0)),
           RLSFEEAMT=RLSFEEAMT - (ROUND(p_txmsg.txfields('90').value,0)),
           DFQTTY=DFQTTY + (ROUND(p_txmsg.txfields('91').value,0)),
           RLSQTTY=RLSQTTY - (ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('92').value+p_txmsg.txfields('93').value+p_txmsg.txfields('94').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('02').value;




      UPDATE SEMAST
      SET 
           BLOCKED=BLOCKED - (ROUND(p_txmsg.txfields('94').value,0)),
           TRADE=TRADE - (ROUND(p_txmsg.txfields('91').value,0)),
           MORTAGE=MORTAGE + (ROUND(p_txmsg.txfields('91').value+p_txmsg.txfields('94').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('06').value;

    IF to_char(p_txmsg.txfields('96').value) <> '0' THEN 



      UPDATE CIMAST
      SET 
           BALANCE=BALANCE - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) - (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('95').value;
    END IF;



      UPDATE LNMAST
      SET 
           PRINOVD=PRINOVD + (ROUND(p_txmsg.txfields('63').value,0)),
           INTNMLACR=INTNMLACR + (ROUND(p_txmsg.txfields('80').value,4)),
           INTDUE=INTDUE + (ROUND(p_txmsg.txfields('77').value,0)),
           PRINNML=PRINNML + (ROUND(p_txmsg.txfields('65').value,0)),
           INTNMLOVD=INTNMLOVD + (ROUND(p_txmsg.txfields('72').value,0)),
           INTPAID=INTPAID - (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0)),
           INTOVDACR=INTOVDACR + (ROUND(p_txmsg.txfields('74').value,4)),
           PRINPAID=PRINPAID - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;




      UPDATE CIMAST
      SET 
           BALANCE=BALANCE + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value,0)) + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('90').value,0)),
           DFODAMT=DFODAMT + (ROUND(p_txmsg.txfields('99').value*(p_txmsg.txfields('63').value+p_txmsg.txfields('65').value),0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;

   END IF;
   --plog.debug (pkgctx, 'Begin of updating pool and room');
   IF txpks_prchk.fn_txAutoUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAppAutoUpdate');
        Return errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'End of updating pool and room');
   RETURN systemnums.C_SUCCESS ;
EXCEPTION
  WHEN others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txAppAutoUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppAutoUpdate;

FUNCTION fn_txAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppUpdate');
-- Run Pre Update
   IF txpks_#2642EX.fn_txPreAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run Auto Update
   IF fn_txAppAutoUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run After Update
   IF txpks_#2642EX.fn_txAftAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   RETURN systemnums.C_SUCCESS;
   plog.setendsection (pkgctx, 'fn_txAppUpdate');
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppUpdate;

FUNCTION fn_txAppCheck(p_txmsg in out tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppCheck');
-- Run Pre check
   IF txpks_#2642EX.fn_txPreAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run Auto check
   IF fn_txAppAutoCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run After check
   IF txpks_#2642EX.fn_txAftAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   plog.setendsection (pkgctx, 'fn_txAppCheck');
   RETURN SYSTEMNUMS.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAppCheck');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txAppCheck;

FUNCTION fn_txProcess(p_xmlmsg in out varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;
   l_txmsg tx.msg_rectype;
   l_count NUMBER(3);
   l_approve BOOLEAN := FALSE;
   l_status VARCHAR2(1);
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txProcess');
   SELECT count(*) INTO l_count 
   FROM SYSVAR
   WHERE GRNAME='SYSTEM'
   AND VARNAME='HOSTATUS'
   AND VARVALUE= systemnums.C_OPERATION_ACTIVE;
   IF l_count = 0 THEN
       --RETURN errnums.C_HOST_OPERATION_ISINACTIVE;
       p_err_code := errnums.C_HOST_OPERATION_ISINACTIVE;
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   plog.debug(pkgctx, 'xml2obj');
   l_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg);
   l_count := 0; -- reset counter
   SELECT count(*) INTO l_count 
   FROM SYSVAR
   WHERE GRNAME='SYSTEM'
   AND VARNAME='CURRDATE'
   AND TO_DATE(VARVALUE,systemnums.C_DATE_FORMAT)= l_txmsg.txdate;
   IF l_count = 0 THEN
       RETURN errnums.C_BRANCHDATE_INVALID;
   END IF;
   plog.debug(pkgctx, 'l_txmsg.txaction: ' || l_txmsg.txaction);
   l_status:= l_txmsg.txstatus;
   -- <<BEGIN OF PROCESSING A TRANSACTION>>
   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txdeleting THEN
       txpks_txlog.pr_update_status(l_txmsg);
       IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND length(l_txmsg.ovrrqd)> 0 THEN
           IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
               p_err_code := errnums.C_CHECKER1_REQUIRED;
           ELSE
               p_err_code := errnums.C_CHECKER2_REQUIRED;
           END IF;
           RETURN l_return_code;
       END IF;
    END IF;
   IF l_txmsg.deltd = txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txcompleted THEN
       -- if Refuse a delete tx then update tx status
       txpks_txlog.pr_update_status(l_txmsg);
       RETURN l_return_code;
   END IF;
   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED THEN
       plog.debug(pkgctx, '<<BEGIN PROCESS NORMAL TX>>');
       plog.debug(pkgctx, 'l_txmsg.pretran: ' || l_txmsg.pretran);
       IF l_txmsg.pretran = 'Y' THEN
           IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
               RAISE errnums.E_BIZ_RULE_INVALID;
           END IF;
           pr_PrintInfo(l_txmsg, p_err_code);
           IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN
               IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
                   p_err_code := errnums.C_CHECKER1_REQUIRED;
               ELSE
                   p_err_code := errnums.C_CHECKER2_REQUIRED;
               END IF;
           END IF;
           IF Length(Trim(Replace(l_txmsg.ovrrqd, errnums.C_CHECKER_CONTROL, ''))) > 0 AND (NVL(l_txmsg.chkid,'$NULL$') = '$NULL$' OR Length(l_txmsg.chkid) = 0) Then
               p_err_code := errnums.C_CHECKER1_REQUIRED;
           ELSE
               IF InStr(l_txmsg.ovrrqd, errnums.OVRRQS_CHECKER_CONTROL) > 0 AND ( NVL(l_txmsg.offid,'$NULL$') = '$NULL$' OR length(l_txmsg.offid) = 0) THEN
                   p_err_code := errnums.C_CHECKER2_REQUIRED;
               ELSE
                   p_err_code := systemnums.C_SUCCESS;
               End IF;
           End IF;
       ELSE --pretran='N'
           plog.debug(pkgctx, 'l_txmsg.nosubmit: ' || l_txmsg.nosubmit); 
           IF l_txmsg.nosubmit = '1' THEN
               IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                   RAISE errnums.E_BIZ_RULE_INVALID;
               END IF;
               IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN
                   IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
                       p_err_code := errnums.C_CHECKER1_REQUIRED;
                   ELSE
                       p_err_code := errnums.C_CHECKER2_REQUIRED;
                   END IF;
               END IF;
               IF Length(Trim(Replace(l_txmsg.ovrrqd, errnums.C_CHECKER_CONTROL, ''))) > 0 AND (NVL(l_txmsg.chkid,'$NULL$')='$NULL$' OR Length(l_txmsg.chkid) = 0) THEN
                   p_err_code := errnums.C_CHECKER1_REQUIRED;
               ELSE
                   IF InStr(l_txmsg.ovrrqd, errnums.OVRRQS_CHECKER_CONTROL) > 0 AND (NVL(l_txmsg.offid,'$NULL$')='$NULL$' OR length(l_txmsg.offid) = 0) THEN
                       p_err_code := errnums.C_CHECKER2_REQUIRED;
                   ELSE
                       l_return_code := systemnums.C_SUCCESS;
                   END IF;
               END IF;
           END IF; -- END OF NOSUBMIT=1
           plog.debug(pkgctx, 'l_return_code: ' || l_return_code);
           IF l_return_code = systemnums.C_SUCCESS THEN
               IF NVL(l_txmsg.ovrrqd,'$X$')= '$X$' OR Length(l_txmsg.ovrrqd) = 0 OR (InStr(l_txmsg.ovrrqd, errnums.C_OFFID_REQUIRED) > 0 AND Length(l_txmsg.offid) > 0) OR (Length(Replace(l_txmsg.ovrrqd, errnums.C_OFFID_REQUIRED, '')) > 0 And Length(l_txmsg.chkid) > 0)  THEN
                  l_approve := TRUE;
               END IF;
               plog.debug(pkgctx, 'l_txmsg.ovrrqd: ' || NVL(l_txmsg.ovrrqd,'$NULL$'));
               plog.debug(pkgctx, 'l_approve,txstatus: ' ||  CASE WHEN l_approve=TRUE THEN 'TRUE' ELSE 'FALSE' END || ',' || l_txmsg.txstatus);
               IF l_approve = TRUE AND (l_txmsg.txstatus= txstatusnums.c_txlogged OR l_txmsg.txstatus= txstatusnums.c_txpending) THEN
                    IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                        RAISE errnums.E_BIZ_RULE_INVALID;
                    END IF;
                    IF NVL(l_txmsg.ovrrqd,'$NULL$')<> '$NULL$' AND LENGTH(l_txmsg.ovrrqd) > 0 THEN
                        IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
                            p_err_code := errnums.C_CHECKER1_REQUIRED;
                        ELSE
                            p_err_code := errnums.C_CHECKER2_REQUIRED;
                        END IF;
                    END IF;
                    l_txmsg.txstatus := txstatusnums.c_txcompleted;
                    IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                        RAISE errnums.E_BIZ_RULE_INVALID;
                    END IF;
                    pr_txlog(l_txmsg, p_err_code);
               End IF; -- END IF APPROVE=TRUE
            END IF; -- end of return_code
       END IF; --<<END OF PROCESS PRETRAN>>
   ELSE -- DELETING TX
   -- <<BEGIN OF DELETING A TRANSACTION>>
   -- This kind of tx has not yet updated mast table in the host
   -- Only need update tllog status
      IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
          RAISE errnums.E_BIZ_RULE_INVALID;
      END IF;
   -- <<END OF DELETING A TRANSACTION>>
   END IF;
   plog.debug(pkgctx, 'obj2xml');
   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
   plog.setendsection (pkgctx, 'fn_txProcess');
   RETURN l_return_code;
EXCEPTION
WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP 
           p_err_param := i.errdesc;
      END LOOP;      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value := p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_txProcess');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value :=  p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_txProcess');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txProcess;

FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_AutoTxProcess');
   IF fn_txAppCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF fn_txAppUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction
       pr_txlog(p_txmsg, p_err_code);
   ELSE    -- Delete transaction
       txpks_txlog.pr_txdellog(p_txmsg,p_err_code);
   END IF;
   plog.setendsection (pkgctx, 'fn_AutoTxProcess');
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP 
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_AutoTxProcess;

FUNCTION fn_BatchTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_BatchTxProcess');
   IF fn_txAppCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF fn_txAppUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
  /* IF fn_txAutoPostmap(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF; */
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction
       pr_txlog(p_txmsg, p_err_code);
   ELSE    -- Delete transaction
       txpks_txlog.pr_txdellog(p_txmsg,p_err_code);
   END IF;

   plog.setendsection (pkgctx, 'fn_BatchTxProcess');
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP 
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_BatchTxProcess');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_BatchTxProcess');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_BatchTxProcess;

FUNCTION fn_txrevert(p_txnum varchar2 ,p_txdate varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_txmsg               tx.msg_rectype;
   l_err_param           varchar2(300);
   l_tllog               tx.tllog_rectype;
   l_fldname             varchar2(100);
   l_defname             varchar2(100);
   l_fldtype             char(1);
   l_return              number(20,0);
   pv_refcursor            pkg_report.ref_cursor;
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txrevert');
   OPEN pv_refcursor FOR
   select * from tllog
   where txnum=p_txnum and txdate=to_date(p_txdate,systemnums.c_date_format);
   LOOP
       FETCH pv_refcursor
       INTO l_tllog;
       EXIT WHEN pv_refcursor%NOTFOUND;
       if l_tllog.deltd='Y' then
           p_err_code:=errnums.C_SA_CANNOT_DELETETRANSACTION;
           RETURN errnums.C_SYSTEM_ERROR;
       end if;
       l_txmsg.msgtype:='T';
       l_txmsg.local:='N';
       l_txmsg.tlid        := l_tllog.tlid;
       l_txmsg.off_line    := l_tllog.off_line;
       l_txmsg.deltd       := txnums.C_DELTD_TXDELETED;
       l_txmsg.txstatus    := txstatusnums.c_txcompleted;
       l_txmsg.msgsts      := '0';
       l_txmsg.ovrsts      := '0';
       l_txmsg.batchname   := 'DEL';
       l_txmsg.txdate:=to_date(l_tllog.txdate,systemnums.c_date_format);
       l_txmsg.busdate:=to_date(l_tllog.busdate,systemnums.c_date_format);
       l_txmsg.txnum:=l_tllog.txnum;
       l_txmsg.tltxcd:=l_tllog.tltxcd;
       l_txmsg.brid:=l_tllog.brid;
       for rec in
       (
           select * from tllogfld
           where txnum=p_txnum and txdate=to_date(p_txdate,systemnums.c_date_format)
       )
       loop
       begin
           select fldname, defname, fldtype
           into l_fldname, l_defname, l_fldtype
           from fldmaster
           where objname=l_tllog.tltxcd and FLDNAME=rec.FLDCD;

           l_txmsg.txfields (l_fldname).defname   := l_defname;
           l_txmsg.txfields (l_fldname).TYPE      := l_fldtype;

           if l_fldtype='C' then
               l_txmsg.txfields (l_fldname).VALUE     := rec.CVALUE;
           elsif   l_fldtype='N' then
               l_txmsg.txfields (l_fldname).VALUE     := rec.NVALUE;
           else
               l_txmsg.txfields (l_fldname).VALUE     := rec.CVALUE;
           end if;
           plog.debug (pkgctx,'field: ' || l_fldname || ' value:' || to_char(l_txmsg.txfields (l_fldname).VALUE));
       exception when others then
           l_err_param:=0;
       end;
       end loop;
       IF txpks_#2642.fn_AutoTxProcess (l_txmsg,
                                        p_err_code,
                                        p_err_param
          ) <> systemnums.c_success
       THEN
           plog.debug (pkgctx,
           'got error 2642: ' || p_err_code
           );
           ROLLBACK;
           RETURN errnums.C_SYSTEM_ERROR;
       END IF;
       p_err_code:=0;
       return 0;
       p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;
       RETURN errnums.C_SYSTEM_ERROR;
   END LOOP;
   p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;
   RETURN errnums.C_SYSTEM_ERROR;
   plog.setendsection (pkgctx, 'fn_txrevert');
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP 
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_txrevert');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txrevert');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txrevert;

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
         plog.init ('txpks_#2642',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END txpks_#2642; 

/
