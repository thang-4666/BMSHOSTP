SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5540
/** ----------------------------------------------------------------------------------------------------
 ** Module: TX
 ** Description: Loan payment
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      04/09/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#5540
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

PROCEDURE pr_txlog(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
IS
   v_count number;
BEGIN
plog.setbeginsection (pkgctx, 'pr_txlog');
   plog.debug(pkgctx, 'abt to insert into tllog, txnum: ' || p_txmsg.txnum);
   select count(1) into v_count from tllog where txnum = p_txmsg.txnum;
   if v_count=0 then
      INSERT INTO tllog(autoid, txnum, txdate, txtime, brid, tlid,offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2, ccyusage,off_line, deltd, brdate, busdate, txdesc, ipaddress,wsname, txstatus, msgsts, ovrsts, batchname, msgamt,msgacct, chktime, offtime, reftxnum)
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
          p_txmsg.txfields('83').value ,
          p_txmsg.txfields('05').value ,
          TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.chkid,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.chkid)),
          TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT), --decode(p_txmsg.offtime,NULL,TO_CHAR(SYSDATE,systemnums.C_TIME_FORMAT,p_txmsg.offtime)),
          p_txmsg.reftxnum);


       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'01',TO_NUMBER(p_txmsg.txfields('01').value),NULL,'LN scheduler id');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'03',0,p_txmsg.txfields('03').value,'Loan account');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'09',TO_NUMBER(p_txmsg.txfields('09').value),NULL,'T+0 principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'10',TO_NUMBER(p_txmsg.txfields('10').value),NULL,'T+0 overdue principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'12',TO_NUMBER(p_txmsg.txfields('12').value),NULL,'T+0 normal principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'11',TO_NUMBER(p_txmsg.txfields('11').value),NULL,'T+0 maturity principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'13',TO_NUMBER(p_txmsg.txfields('13').value),NULL,'Overdue margin principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'14',TO_NUMBER(p_txmsg.txfields('14').value),NULL,'Maturity margin principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'15',TO_NUMBER(p_txmsg.txfields('15').value),NULL,'Undue margin principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'20',TO_NUMBER(p_txmsg.txfields('20').value),NULL,'Fee overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'21',TO_NUMBER(p_txmsg.txfields('21').value),NULL,'Int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'22',TO_NUMBER(p_txmsg.txfields('22').value),NULL,'T+0 Int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'23',TO_NUMBER(p_txmsg.txfields('23').value),NULL,'Margin Int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'93',TO_NUMBER(p_txmsg.txfields('93').value),NULL,'Margin Fee int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'24',TO_NUMBER(p_txmsg.txfields('24').value),NULL,'Int. on overdue principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'25',TO_NUMBER(p_txmsg.txfields('25').value),NULL,'Int. on T+0 overdue principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'26',TO_NUMBER(p_txmsg.txfields('26').value),NULL,'Int. on margin overdue principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'96',TO_NUMBER(p_txmsg.txfields('96').value),NULL,'Int. on margin overdue principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'27',TO_NUMBER(p_txmsg.txfields('27').value),NULL,'Fee due');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'28',TO_NUMBER(p_txmsg.txfields('28').value),NULL,'Int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'29',TO_NUMBER(p_txmsg.txfields('29').value),NULL,'T+0 Int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'91',TO_NUMBER(p_txmsg.txfields('91').value),NULL,'Margin Int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'31',TO_NUMBER(p_txmsg.txfields('31').value),NULL,'Margin Int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'32',TO_NUMBER(p_txmsg.txfields('32').value),NULL,'Fee undue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'33',TO_NUMBER(p_txmsg.txfields('33').value),NULL,'Int. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'34',TO_NUMBER(p_txmsg.txfields('34').value),NULL,'T+0 Int. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'35',TO_NUMBER(p_txmsg.txfields('35').value),NULL,'Margin Int. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'95',TO_NUMBER(p_txmsg.txfields('95').value),NULL,'Margin Int. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'05',0,p_txmsg.txfields('05').value,'Saving account number');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'40',TO_NUMBER(p_txmsg.txfields('40').value),NULL,'Loan amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'41',TO_NUMBER(p_txmsg.txfields('41').value),NULL,'Principal loan amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'42',TO_NUMBER(p_txmsg.txfields('42').value),NULL,'Undue principal amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'43',TO_NUMBER(p_txmsg.txfields('43').value),NULL,'Int. loan amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'44',TO_NUMBER(p_txmsg.txfields('44').value),NULL,'Undue int. amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'07',0,p_txmsg.txfields('07').value,'Loan type');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'99',TO_NUMBER(p_txmsg.txfields('99').value),NULL,'Available balance');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'45',TO_NUMBER(p_txmsg.txfields('45').value),NULL,'Paid amount for principal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'46',TO_NUMBER(p_txmsg.txfields('46').value),NULL,'Paid amount for int.');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'47',TO_NUMBER(p_txmsg.txfields('47').value),NULL,'Fee(%)');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'81',TO_NUMBER(p_txmsg.txfields('81').value),NULL,'Adv. pay amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'50',TO_NUMBER(p_txmsg.txfields('50').value),NULL,'Percentage');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'82',TO_NUMBER(p_txmsg.txfields('82').value),NULL,'Fee must be paid');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'83',TO_NUMBER(p_txmsg.txfields('83').value),NULL,'Pay amount');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'52',TO_NUMBER(p_txmsg.txfields('52').value),NULL,'Min term');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'51',TO_NUMBER(p_txmsg.txfields('51').value),NULL,'Others int paid');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'60',TO_NUMBER(p_txmsg.txfields('60').value),NULL,'Paid for T+0 prin. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'61',TO_NUMBER(p_txmsg.txfields('61').value),NULL,'Paid for T+0 prin. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'62',TO_NUMBER(p_txmsg.txfields('62').value),NULL,'Paid for T+0 prin. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'63',TO_NUMBER(p_txmsg.txfields('63').value),NULL,'Paid for prin. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'64',TO_NUMBER(p_txmsg.txfields('64').value),NULL,'Paid for prin. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'65',TO_NUMBER(p_txmsg.txfields('65').value),NULL,'Paid for prin. undue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'70',TO_NUMBER(p_txmsg.txfields('70').value),NULL,'Paid for overdue fee');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'71',TO_NUMBER(p_txmsg.txfields('71').value),NULL,'Paid for T+0 int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'72',TO_NUMBER(p_txmsg.txfields('72').value),NULL,'Paid for int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'92',TO_NUMBER(p_txmsg.txfields('92').value),NULL,'Paid for int. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'73',TO_NUMBER(p_txmsg.txfields('73').value),NULL,'Paid for int. on T+0 prin. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'74',TO_NUMBER(p_txmsg.txfields('74').value),NULL,'Paid for int. on prin. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'84',TO_NUMBER(p_txmsg.txfields('84').value),NULL,'Paid for int. on prin. overdue');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'75',TO_NUMBER(p_txmsg.txfields('75').value),NULL,'Paid for due fee');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'76',TO_NUMBER(p_txmsg.txfields('76').value),NULL,'Paid for T+0 int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'77',TO_NUMBER(p_txmsg.txfields('77').value),NULL,'Paid for int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'97',TO_NUMBER(p_txmsg.txfields('97').value),NULL,'Paid for int. maturity');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'78',TO_NUMBER(p_txmsg.txfields('78').value),NULL,'Paid  for undue fee');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'79',TO_NUMBER(p_txmsg.txfields('79').value),NULL,'Paid for T+0 int. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'80',TO_NUMBER(p_txmsg.txfields('80').value),NULL,'Paid for int. normal');
       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
          VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'90',TO_NUMBER(p_txmsg.txfields('90').value),NULL,'Paid for int. normal');

       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
       VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'85',TO_NUMBER(p_txmsg.txfields('85').value),NULL,'');

       plog.debug(pkgctx, 'abt to insert into tllogfld');
       INSERT INTO tllogfld(AUTOID, TXNUM, TXDATE, FLDCD, NVALUE, CVALUE, TXDESC)
       VALUES( seq_tllogfld.NEXTVAL, p_txmsg.txnum, TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),'86',TO_NUMBER(p_txmsg.txfields('86').value),NULL,'');

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
   Else
               txpks_txlog.pr_update_status(p_txmsg);
   End if;
   plog.setendsection (pkgctx, 'pr_txlog');
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
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

    l_status apprules.field%TYPE;
    l_avlbal apprules.field%TYPE;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_lnmastcheck_arr txpks_check.lnmastcheck_arrtype;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppAutoCheck');
   IF p_txmsg.deltd = 'N' THEN

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('03').value,'LNMAST','03','5540')<>'TRUE' then
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

     If txpks_check.fn_aftxmapcheck(p_txmsg.txfields('05').value,'CIMAST','05','5540')<>'TRUE' then
         p_err_code := errnums.C_SA_TLTX_NOT_ALLOW_BY_ACCTNO;
         plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
     End if;

       SELECT  STATUS
      INTO l_STATUS
        FROM LNMAST
        WHERE ACCTNO = p_txmsg.txfields('03').value;

     IF NOT ( INSTR('NOSBL',l_STATUS) > 0) THEN
        p_err_code := '-540001';
plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;


     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('05').value,'CIMAST','ACCTNO');

     l_AVLBAL := l_CIMASTcheck_arr(0).AVLBAL;
     l_STATUS := l_CIMASTcheck_arr(0).STATUS;

     IF NOT (to_number(l_AVLBAL) >= to_number(p_txmsg.txfields('83').value)) THEN
        p_err_code := '-400101';
plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
     IF NOT ( INSTR('A',l_STATUS) > 0) THEN
        p_err_code := '-400100';
plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

    END IF;
   plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
  WHEN others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppAutoCheck;

FUNCTION fn_txAppAutoUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN  NUMBER
IS
l_txdesc VARCHAR2(1000);
BEGIN
   IF p_txmsg.deltd <> 'Y' THEN -- Normal transaction

      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'5540','CI','0011','0002');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('76').value+p_txmsg.txfields('79').value+p_txmsg.txfields('71').value+p_txmsg.txfields('73').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'5540','CI','0011','0001');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'5540','CI','0011','0007');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('90').value+p_txmsg.txfields('92').value+p_txmsg.txfields('97').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'5540','CI','0011','0006');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('82').value+p_txmsg.txfields('70').value+p_txmsg.txfields('75').value+p_txmsg.txfields('78').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('72').value+p_txmsg.txfields('74').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'5540','CI','0011','0005');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      l_txdesc:= cspks_system.fn_DBgen_trandesc_with_format(p_txmsg,'5540','CI','0011','0008');
      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('84').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0062',ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value+p_txmsg.txfields('63').value+p_txmsg.txfields('70').value+p_txmsg.txfields('71').value+p_txmsg.txfields('72').value+p_txmsg.txfields('73').value+p_txmsg.txfields('74').value+p_txmsg.txfields('79').value+p_txmsg.txfields('84').value+p_txmsg.txfields('92').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0064',ROUND(p_txmsg.txfields('64').value+p_txmsg.txfields('75').value+p_txmsg.txfields('76').value+p_txmsg.txfields('77').value+p_txmsg.txfields('97').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0011',ROUND(p_txmsg.txfields('51').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'Tra lai khac');

      INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0034',ROUND(p_txmsg.txfields('83').value-p_txmsg.txfields('82').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO AFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0021',ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_AFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0070',ROUND(p_txmsg.txfields('78').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0068',ROUND(p_txmsg.txfields('75').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0081',ROUND(p_txmsg.txfields('97').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0078',ROUND(p_txmsg.txfields('90').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0083',ROUND(p_txmsg.txfields('92').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0085',ROUND(p_txmsg.txfields('84').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0090',ROUND(p_txmsg.txfields('92').value+p_txmsg.txfields('84').value+p_txmsg.txfields('97').value+p_txmsg.txfields('90').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0066',ROUND(p_txmsg.txfields('70').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0073',ROUND(p_txmsg.txfields('70').value+p_txmsg.txfields('75').value+p_txmsg.txfields('78').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0076',ROUND(p_txmsg.txfields('82').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0025',ROUND(p_txmsg.txfields('77').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0041',ROUND(p_txmsg.txfields('80').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0027',ROUND(p_txmsg.txfields('72').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0043',ROUND(p_txmsg.txfields('74').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0024',ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0056',ROUND(p_txmsg.txfields('76').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0054',ROUND(p_txmsg.txfields('79').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0058',ROUND(p_txmsg.txfields('71').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0062',ROUND(p_txmsg.txfields('73').value,4),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0075',ROUND(p_txmsg.txfields('71').value+p_txmsg.txfields('73').value+p_txmsg.txfields('76').value+p_txmsg.txfields('79').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0052',ROUND(p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0060',ROUND(p_txmsg.txfields('60').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0065',ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0015',ROUND(p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0017',ROUND(p_txmsg.txfields('63').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

      INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0014',ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0),NULL,p_txmsg.txfields ('01').value,p_txmsg.deltd,p_txmsg.txfields ('01').value,seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');



      UPDATE AFMAST
         SET  LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;


      UPDATE LNMAST
         SET
           PRINOVD = PRINOVD - (ROUND(p_txmsg.txfields('63').value,0)),
           FEEPAID2 = FEEPAID2 + (ROUND(p_txmsg.txfields('82').value,0)),
           INTNMLACR = INTNMLACR - (ROUND(p_txmsg.txfields('80').value,4)),
           OPRINOVD = OPRINOVD - (ROUND(p_txmsg.txfields('60').value,0)),
           INTDUE = INTDUE - (ROUND(p_txmsg.txfields('77').value,0)),
           PRINNML = PRINNML - (ROUND(p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0)),
           FEEDUE = FEEDUE - (ROUND(p_txmsg.txfields('75').value,0)),
           INTNMLOVD = INTNMLOVD - (ROUND(p_txmsg.txfields('72').value,0)),
           FEEINTPAID = FEEINTPAID + (ROUND(p_txmsg.txfields('92').value+p_txmsg.txfields('84').value+p_txmsg.txfields('97').value+p_txmsg.txfields('90').value,4)),
           FEEINTNMLOVD = FEEINTNMLOVD - (ROUND(p_txmsg.txfields('92').value,4)),
           INTPAID = INTPAID + (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0)),
           OINTOVDACR = OINTOVDACR - (ROUND(p_txmsg.txfields('73').value,4)),
           OINTNMLOVD = OINTNMLOVD - (ROUND(p_txmsg.txfields('71').value,0)),
           INTOVDACR = INTOVDACR - (ROUND(p_txmsg.txfields('74').value,4)),
           OINTNMLACR = OINTNMLACR - (ROUND(p_txmsg.txfields('79').value,4)),
           OINTDUE = OINTDUE - (ROUND(p_txmsg.txfields('76').value,0)),
           FEEPAID = FEEPAID + (ROUND(p_txmsg.txfields('70').value+p_txmsg.txfields('75').value+p_txmsg.txfields('78').value,0)),
           OPRINPAID = OPRINPAID + (ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0)),
           FEEINTOVDACR = FEEINTOVDACR - (ROUND(p_txmsg.txfields('84').value,4)),
           OPRINNML = OPRINNML - (ROUND(p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0)),
           FEEOVD = FEEOVD - (ROUND(p_txmsg.txfields('70').value,0)),
           FEEINTNMLACR = FEEINTNMLACR - (ROUND(p_txmsg.txfields('90').value,4)),
           FEEINTDUE = FEEINTDUE - (ROUND(p_txmsg.txfields('97').value,4)),
           PRINPAID = PRINPAID + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0)),
           FEE = FEE - (ROUND(p_txmsg.txfields('78').value,0)),
           OINTPAID = OINTPAID + (ROUND(p_txmsg.txfields('71').value+p_txmsg.txfields('73').value+p_txmsg.txfields('76').value+p_txmsg.txfields('79').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;


      UPDATE CIMAST
         SET
           ODAMT = ODAMT - (ROUND(p_txmsg.txfields('83').value-p_txmsg.txfields('82').value,0)),
           BALANCE = BALANCE - (ROUND(p_txmsg.txfields('76').value+p_txmsg.txfields('79').value+p_txmsg.txfields('71').value+p_txmsg.txfields('73').value,0)) - (ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0)) - (ROUND(p_txmsg.txfields('90').value+p_txmsg.txfields('92').value+p_txmsg.txfields('97').value,0)) - (ROUND(p_txmsg.txfields('82').value+p_txmsg.txfields('70').value+p_txmsg.txfields('75').value+p_txmsg.txfields('78').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('72').value+p_txmsg.txfields('74').value,0)) - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0)) - (ROUND(p_txmsg.txfields('84').value,0)) - (ROUND(p_txmsg.txfields('51').value,0)),
           DUEAMT = DUEAMT - (ROUND(p_txmsg.txfields('64').value+p_txmsg.txfields('75').value+p_txmsg.txfields('76').value+p_txmsg.txfields('77').value+p_txmsg.txfields('97').value,0)),
           OVAMT = OVAMT - (ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value+p_txmsg.txfields('63').value+p_txmsg.txfields('70').value+p_txmsg.txfields('71').value+p_txmsg.txfields('72').value+p_txmsg.txfields('73').value+p_txmsg.txfields('74').value+p_txmsg.txfields('79').value+p_txmsg.txfields('84').value+p_txmsg.txfields('92').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;

   ELSE -- Reversal
      UPDATE TLLOG
        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE CITRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE LNTRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
        UPDATE AFTRAN        SET DELTD = 'Y'
        WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);




      UPDATE AFMAST
      SET  LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;




      UPDATE LNMAST
      SET
           PRINOVD=PRINOVD + (ROUND(p_txmsg.txfields('63').value,0)),
           FEEPAID2=FEEPAID2 - (ROUND(p_txmsg.txfields('82').value,0)),
           INTNMLACR=INTNMLACR + (ROUND(p_txmsg.txfields('80').value,4)),
           OPRINOVD=OPRINOVD + (ROUND(p_txmsg.txfields('60').value,0)),
           INTDUE=INTDUE + (ROUND(p_txmsg.txfields('77').value,0)),
           PRINNML=PRINNML + (ROUND(p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0)),
           FEEDUE=FEEDUE + (ROUND(p_txmsg.txfields('75').value,0)),
           INTNMLOVD=INTNMLOVD + (ROUND(p_txmsg.txfields('72').value,0)),
           FEEINTPAID=FEEINTPAID - (ROUND(p_txmsg.txfields('92').value+p_txmsg.txfields('84').value+p_txmsg.txfields('97').value+p_txmsg.txfields('90').value,4)),
           FEEINTNMLOVD=FEEINTNMLOVD + (ROUND(p_txmsg.txfields('92').value,4)),
           INTPAID=INTPAID - (ROUND(p_txmsg.txfields('72').value+p_txmsg.txfields('74').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value,0)),
           OINTOVDACR=OINTOVDACR + (ROUND(p_txmsg.txfields('73').value,4)),
           OINTNMLOVD=OINTNMLOVD + (ROUND(p_txmsg.txfields('71').value,0)),
           INTOVDACR=INTOVDACR + (ROUND(p_txmsg.txfields('74').value,4)),
           OINTNMLACR=OINTNMLACR + (ROUND(p_txmsg.txfields('79').value,4)),
           OINTDUE=OINTDUE + (ROUND(p_txmsg.txfields('76').value,0)),
           FEEPAID=FEEPAID - (ROUND(p_txmsg.txfields('70').value+p_txmsg.txfields('75').value+p_txmsg.txfields('78').value,0)),
           OPRINPAID=OPRINPAID - (ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0)),
           FEEINTOVDACR=FEEINTOVDACR + (ROUND(p_txmsg.txfields('84').value,4)),
           OPRINNML=OPRINNML + (ROUND(p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0)),
           FEEOVD=FEEOVD + (ROUND(p_txmsg.txfields('70').value,0)),
           FEEINTNMLACR=FEEINTNMLACR + (ROUND(p_txmsg.txfields('90').value,4)),
           FEEINTDUE=FEEINTDUE + (ROUND(p_txmsg.txfields('97').value,4)),
           PRINPAID=PRINPAID - (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0)),
           FEE=FEE + (ROUND(p_txmsg.txfields('78').value,0)),
           OINTPAID=OINTPAID - (ROUND(p_txmsg.txfields('71').value+p_txmsg.txfields('73').value+p_txmsg.txfields('76').value+p_txmsg.txfields('79').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('03').value;




      UPDATE CIMAST
      SET
           ODAMT=ODAMT + (ROUND(p_txmsg.txfields('83').value-p_txmsg.txfields('82').value,0)),
           BALANCE=BALANCE + (ROUND(p_txmsg.txfields('76').value+p_txmsg.txfields('79').value+p_txmsg.txfields('71').value+p_txmsg.txfields('73').value,0)) + (ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value,0)) + (ROUND(p_txmsg.txfields('90').value+p_txmsg.txfields('92').value+p_txmsg.txfields('97').value,0)) + (ROUND(p_txmsg.txfields('82').value+p_txmsg.txfields('70').value+p_txmsg.txfields('75').value+p_txmsg.txfields('78').value+p_txmsg.txfields('77').value+p_txmsg.txfields('80').value+p_txmsg.txfields('72').value+p_txmsg.txfields('74').value,0)) + (ROUND(p_txmsg.txfields('63').value+p_txmsg.txfields('64').value+p_txmsg.txfields('65').value,0)) + (ROUND(p_txmsg.txfields('84').value,0)) + (ROUND(p_txmsg.txfields('51').value,0)),
           DUEAMT=DUEAMT + (ROUND(p_txmsg.txfields('64').value+p_txmsg.txfields('75').value+p_txmsg.txfields('76').value+p_txmsg.txfields('77').value+p_txmsg.txfields('97').value,0)),
           OVAMT=OVAMT + (ROUND(p_txmsg.txfields('60').value+p_txmsg.txfields('61').value+p_txmsg.txfields('62').value+p_txmsg.txfields('63').value+p_txmsg.txfields('70').value+p_txmsg.txfields('71').value+p_txmsg.txfields('72').value+p_txmsg.txfields('73').value+p_txmsg.txfields('74').value+p_txmsg.txfields('79').value+p_txmsg.txfields('84').value+p_txmsg.txfields('92').value,0)), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=p_txmsg.txfields('05').value;

   END IF;
   plog.setendsection (pkgctx, 'fn_txAppAutoUpdate');
   RETURN systemnums.C_SUCCESS ;
EXCEPTION
  WHEN others THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAppAutoUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppAutoUpdate;


FUNCTION fn_txAppUpdate(p_txmsg in tx.msg_rectype,p_err_code in out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppUpdate');
-- Run Pre Update
   IF txpks_#5540EX.fn_txPreAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run Auto Update
   IF fn_txAppAutoUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run After Update
   IF txpks_#5540EX.fn_txAftAppUpdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'Begin of updating pool and room');
   IF txpks_prchk.fn_txAutoUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAppUpdate');
        Return errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'End of updating pool and room');
   plog.setendsection (pkgctx, 'fn_txAppUpdate');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAppUpdate;

FUNCTION fn_txAppCheck(p_txmsg in out tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAppCheck');
-- Run Pre check
   IF txpks_#5540EX.fn_txPreAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run Auto check
   IF fn_txAppAutoCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
-- Run After check
   IF txpks_#5540EX.fn_txAftAppCheck(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
       RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'Begin of checking pool and room');
   IF txpks_prchk.fn_txAutoCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
       plog.setendsection (pkgctx, 'fn_txAppCheck');
        Return errnums.C_BIZ_RULE_INVALID;
   END IF;
   --plog.debug (pkgctx, 'End of checking pool and room');
   plog.setendsection (pkgctx, 'fn_txAppCheck');
   RETURN SYSTEMNUMS.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
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
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_BRANCHDATE_INVALID;
   END IF;
   plog.debug(pkgctx, 'l_txmsg.txaction: ' || l_txmsg.txaction);
   l_status:= l_txmsg.txstatus;
   --GHI NHAN DE TRANH DOUBLE HACH TOAN GIAO DICH
   pr_lockaccount(l_txmsg,p_err_code);
   if p_err_code <> 0 then
       pr_unlockaccount(l_txmsg);
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_SYSTEM_ERROR;
   end if;
   -- <<BEGIN OF PROCESSING A TRANSACTION>>
   IF l_txmsg.deltd <> txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txdeleting THEN
       txpks_txlog.pr_update_status(l_txmsg);
       IF NVL(l_txmsg.ovrrqd,'$X$')<> '$X$' AND length(l_txmsg.ovrrqd)> 0 THEN
           IF l_txmsg.ovrrqd <> errnums.C_CHECKER_CONTROL THEN
               p_err_code := errnums.C_CHECKER1_REQUIRED;
           ELSE
               p_err_code := errnums.C_CHECKER2_REQUIRED;
           END IF;
           plog.setendsection (pkgctx, 'fn_txProcess');
           pr_unlockaccount(l_txmsg);
           RETURN l_return_code;
       END IF;
    END IF;
   IF l_txmsg.deltd = txnums.C_DELTD_TXDELETED AND l_txmsg.txstatus = txstatusnums.c_txcompleted THEN
       -- if Refuse a delete tx then update tx status
       txpks_txlog.pr_update_status(l_txmsg);
       plog.setendsection (pkgctx, 'fn_txProcess');
       pr_unlockaccount(l_txmsg);
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
                IF l_approve = TRUE THEN
                    IF l_txmsg.txstatus= txstatusnums.c_txlogged THEN
                        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                             RAISE errnums.E_BIZ_RULE_INVALID;
                        END IF;
                    IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                        RAISE errnums.E_BIZ_RULE_INVALID;
                    END IF;
                        pr_txlog(l_txmsg, p_err_code);
                    ELSIF l_txmsg.txstatus= txstatusnums.c_txpending THEN
                        l_txmsg.txstatus := txstatusnums.c_txcompleted;
                        txpks_txlog.pr_update_status(l_txmsg);
                    END IF;
               ELSE
                    IF l_txmsg.txstatus= txstatusnums.c_txpending THEN
                        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                             RAISE errnums.E_BIZ_RULE_INVALID;
                        END IF;
                        IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
                            RAISE errnums.E_BIZ_RULE_INVALID;
                        END IF;
                        pr_txlog(l_txmsg, p_err_code);
                    END IF;
               End IF; --<<END OF PROCESS l_approve>>
          End IF;
     End IF;

   ELSE -- PROCESS DELETING TX
   -- <<BEGIN OF DELETING TRANSACTION>>
        IF fn_txAppCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
            RAISE errnums.E_BIZ_RULE_INVALID;
        END IF;
      IF fn_txAppUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
          RAISE errnums.E_BIZ_RULE_INVALID;
      END IF;
      txpks_txlog.pr_txdellog(l_txmsg, p_err_code);
   -- <<END OF DELETING A TRANSACTION>>
   END IF;
   plog.debug(pkgctx, 'obj2xml');
   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
   plog.setendsection (pkgctx, 'fn_txProcess');
   pr_unlockaccount(l_txmsg);
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
      pr_unlockaccount(l_txmsg);
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value :=  p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_txProcess');
      pr_unlockaccount(l_txmsg);
      RETURN errnums.C_SYSTEM_ERROR;
END fn_txProcess;

FUNCTION fn_AutoTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_AutoTxProcess');
   --GHI NHAN DE TRANH DOUBLE HACH TOAN GIAO DICH
   pr_lockaccount(p_txmsg,p_err_code);
   if p_err_code <> 0 then
       pr_unlockaccount(p_txmsg);
       plog.setendsection (pkgctx, 'fn_txProcess');
       RETURN errnums.C_SYSTEM_ERROR;
   end if;
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
   pr_unlockaccount(p_txmsg);
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
      pr_unlockaccount(p_txmsg);
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      pr_unlockaccount(p_txmsg);
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
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
           plog.setendsection (pkgctx, 'fn_txrevert');
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
       IF txpks_#5540.fn_AutoTxProcess (l_txmsg,
                                        p_err_code,
                                        p_err_param
          ) <> systemnums.c_success
       THEN
           plog.debug (pkgctx,
           'got error 5540: ' || p_err_code
           );
           ROLLBACK;
           plog.setendsection (pkgctx, 'fn_txrevert');
           RETURN errnums.C_SYSTEM_ERROR;
       END IF;
       p_err_code:=0;
       plog.setendsection (pkgctx, 'fn_txrevert');
       return 0;
       plog.setendsection (pkgctx, 'fn_txrevert');
       p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;
       RETURN errnums.C_SYSTEM_ERROR;
   END LOOP;
   p_err_code:=errnums.C_HOST_VOUCHER_NOT_FOUND;
   plog.setendsection (pkgctx, 'fn_txrevert');
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
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
         plog.init ('txpks_#5540',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END txpks_#5540;
/
