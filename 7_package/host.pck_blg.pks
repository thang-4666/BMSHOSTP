SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_blg
  IS
  PROCEDURE Prc_Event
    ( eventname   varchar2,
      rcdkey      varchar2,
      orderid     varchar2,
      afacctno    varchar2);
  PROCEDURE Prc_Process_msg;

END; -- Package spec
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_blg
IS
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

  pkgctx        plog.log_ctx;
  logrow        tlogdebug%rowtype;
  ownerschema   varchar2(50);
  databaseCache boolean;


   PROCEDURE Prc_Event
    ( eventname   varchar2,
      rcdkey      varchar2,
      orderid     varchar2,
      afacctno    varchar2) is

   BEGIN

    INSERT INTO bl_event (id,
                          eventname,
                          rcdkey,
                          orderid,
                          afacctno,
                          process)
      VALUES   (bl_event_seq.nextval,
                 eventname,
                 rcdkey,
                 orderid,
                 afacctno,
                  'N');

   EXCEPTION
      WHEN Others THEN
          Null ;
   END;

   PROCEDURE Prc_Process_msg
   is
     l_refcursor      pkg_report.ref_cursor;
     l_array_msg SimpleStringArrayType := SimpleStringArrayType();
     l_notify boolean;
     tmp_text_message SYS.AQ$_JMS_TEXT_MESSAGE;
     eopt             DBMS_AQ.enqueue_options_t;
     mprop            DBMS_AQ.message_properties_t;
     tmp_encode_text  varchar2(32767);
     enq_msgid        raw(16);
     l_count    NUMBER;
     l_odmatchqtty  NUMBER;
     l_iodmatchqtty NUMBER;

     l_TARGETCOMPID     varchar2(20);
     l_SENDERCOMPID     varchar2(20);

   BEGIN
     plog.setbeginsection(pkgctx, 'Prc_Process_msg');

    SELECT VARVALUE INTO l_TARGETCOMPID FROM SYSVAR
    WHERE GRNAME = 'SYSTEM'
        AND VARNAME IN ('TARGETCOMPID');

    SELECT VARVALUE INTO l_SENDERCOMPID FROM SYSVAR
    WHERE GRNAME = 'SYSTEM'
        AND VARNAME IN ('SENDERCOMPID');

    For i in (Select * from bl_event where Process ='N' ORDER BY id)
     Loop
            plog.debug(pkgctx,
                    'The content: ' || i.Eventname || ' OrderID ' ||
                     i.OrderID||' Afacctno '||i.Afacctno);
            --l_notify := True;
            If  i.Eventname = 'FOMAST' Then
                INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 text,
                                 process,
                                 traderid)
                 SELECT   i.id,

                     '8' msgtype,
                     '0' avgpx,
                     FOREFID clordid,
                     ' ' commission,
                     '1' commtype,
                     0 cumqty,
                     ' ' currency,
                     FOREFID execid,
                     ' ' execrefid,
                     '0' exectranstype,
                     '8' exectype,
                     ' ' idsource,
                     '0'  lastpx,
                     '0' lastshares,
                     QUANTITY leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     FOREFID orderid,
                     QUANTITY orderqty,
                     '8' ordstatus,
                     ' ' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                     side,
                     symbol symbol,
                     ''  transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     afacctno afacctno,
                     CASE WHEN feedbackmsg LIKE '%[-400116]%'
                                            THEN 'Over purchasing power in sub-account'
                          WHEN feedbackmsg LIKE '%[-700069]%'
                                            THEN 'Banned securities in sub-account or sub-account type under policy of company'
                          WHEN feedbackmsg LIKE '%[-100113]%'
                                            THEN 'Invalid trading session.'
                          WHEN feedbackmsg LIKE '%[-700025]%'
                                            THEN 'Invalid order status.'
                          WHEN feedbackmsg LIKE '%[-670062]%'
                                            THEN 'Bank is disconnected.'
                          WHEN feedbackmsg LIKE '%[-701111]%'
                                            THEN 'Adjusted volume must be higher than matched volume.'
                          WHEN feedbackmsg LIKE '%[-900017]%'
                                            THEN 'Over securities balance in sub-account.'
                          WHEN feedbackmsg LIKE '%[-670040]%'
                                            THEN 'Not enough balance to be blocked.'
                          WHEN feedbackmsg LIKE '%[-670061]%'
                                            THEN 'Bank system error.'
                          WHEN feedbackmsg LIKE '%[-400117]%'
                                            THEN 'Over sub-account trading restrictions.'
                          WHEN feedbackmsg LIKE '%[-700012]%'
                                            THEN 'Price out of market range.'
                          WHEN feedbackmsg LIKE '%[-900020]%'
                                            THEN 'Not enough mortgaged balance.'
                          WHEN feedbackmsg LIKE '%[-700051]%'
                                            THEN 'Over room for foreign investor.'
                          WHEN feedbackmsg LIKE '%[-670029]%'
                                            THEN 'HoldID has been cancelled.'
                          WHEN feedbackmsg LIKE '%[-700016]%'
                                            THEN 'Waiting for corresponding order to be matched.'
                          WHEN feedbackmsg LIKE '%[-670071]%'
                                            THEN 'Account is not set up an authorization.'
                          WHEN feedbackmsg LIKE '%[-700030]%'
                                            THEN 'Order is under processing to the exchange.'
                          WHEN feedbackmsg LIKE '%[-300025]%'
                                            THEN 'Securities is suspended for trading.'
                          WHEN feedbackmsg LIKE '%[-100523]%'
                                            THEN 'Over securities trading room.'
                          WHEN feedbackmsg LIKE '%[-700014]%'
                                            THEN 'Invalid tick size.'
                          WHEN feedbackmsg LIKE '%[-700013]%'
                                            THEN 'Securities tick size has not been declared.'

                                ELSE 'Invalid Order'
                     END text,
                     'N',
                     traderid
              FROM   FOMAST
              WHERE  VIA ='L'
                 AND acctno =i.rcdkey;

       ElsIf  i.Eventname = 'FOMAST_CANCEL' Then

               INSERT INTO bl_ordercancelreject (Msgtype,
                                      orderid,
                                      secondaryorderid,
                                      clordid,
                                      origclordid,
                                      ordstatus,
                                      clientid,
                                      execbroker,
                                      listid,
                                      account,
                                      transacttime,
                                      cxlrejresponseto,
                                      cxlrejreason,
                                      text,
                                      encodedtextlen,
                                      encodedtext,
                                      process,
                                      traderid,
                                      autoid)
             Select     '9' Msgtype,
                    FOREFID orderid,
                    ' ' secondaryorderid,
                    FOREFID clordid,
                    ' ' origclordid,
                    ' ' ordstatus,
                    ' ' clientid,
                    ' ' execbroker,
                    ' ' listid,
                    ' ' account,
                    ' ' transacttime,
                    ' ' cxlrejresponseto,
                    ' ' cxlrejreason,
                    CASE WHEN feedbackmsg LIKE '%[-400116]%'
                                            THEN 'Over purchasing power in sub-account'
                          WHEN feedbackmsg LIKE '%[-700069]%'
                                            THEN 'Banned securities in sub-account or sub-account type under policy of company'
                          WHEN feedbackmsg LIKE '%[-100113]%'
                                            THEN 'Invalid trading session.'
                          WHEN feedbackmsg LIKE '%[-700025]%'
                                            THEN 'Invalid order status.'
                          WHEN feedbackmsg LIKE '%[-670062]%'
                                            THEN 'Bank is disconnected.'
                          WHEN feedbackmsg LIKE '%[-701111]%'
                                            THEN 'Adjusted volume must be higher than matched volume.'
                          WHEN feedbackmsg LIKE '%[-900017]%'
                                            THEN 'Over securities balance in sub-account.'
                          WHEN feedbackmsg LIKE '%[-670040]%'
                                            THEN 'Not enough balance to be blocked.'
                          WHEN feedbackmsg LIKE '%[-670061]%'
                                            THEN 'Bank system error.'
                          WHEN feedbackmsg LIKE '%[-400117]%'
                                            THEN 'Over sub-account trading restrictions.'
                          WHEN feedbackmsg LIKE '%[-700012]%'
                                            THEN 'Price out of market range.'
                          WHEN feedbackmsg LIKE '%[-900020]%'
                                            THEN 'Not enough mortgaged balance.'
                          WHEN feedbackmsg LIKE '%[-700051]%'
                                            THEN 'Over room for foreign investor.'
                          WHEN feedbackmsg LIKE '%[-670029]%'
                                            THEN 'HoldID has been cancelled.'
                          WHEN feedbackmsg LIKE '%[-700016]%'
                                            THEN 'Waiting for corresponding order to be matched.'
                          WHEN feedbackmsg LIKE '%[-670071]%'
                                            THEN 'Account is not set up an authorization.'
                          WHEN feedbackmsg LIKE '%[-700030]%'
                                            THEN 'Order is under processing to the exchange.'
                          WHEN feedbackmsg LIKE '%[-300025]%'
                                            THEN 'Securities is suspended for trading.'
                          WHEN feedbackmsg LIKE '%[-100523]%'
                                            THEN 'Over securities trading room.'
                          WHEN feedbackmsg LIKE '%[-700014]%'
                                            THEN 'Invalid tick size.'
                          WHEN feedbackmsg LIKE '%[-700013]%'
                                            THEN 'Securities tick size has not been declared.'

                                ELSE 'Invalid Order'
                     END text,
                    ' ' encodedtextlen,
                    ' ' encodedtext,
                    'N',
                    traderid,
                    bl_odreject_seq.NEXTVAL
                  FROM   FOMAST
                  WHERE  VIA ='L'
                  AND acctno =i.rcdkey;

    ElsIf  i.Eventname = 'CANCEL_FILLED' Then

               INSERT INTO bl_ordercancelreject (Msgtype,
                                      orderid,
                                      secondaryorderid,
                                      clordid,
                                      origclordid,
                                      ordstatus,
                                      clientid,
                                      execbroker,
                                      listid,
                                      account,
                                      transacttime,
                                      cxlrejresponseto,
                                      cxlrejreason,
                                      text,
                                      encodedtextlen,
                                      encodedtext,
                                      process,
                                      traderid,
                                      autoid)
             Select     '9' Msgtype,
                    FOREFID orderid,
                    ' ' secondaryorderid,
                    FOREFID clordid,
                    ' ' origclordid,
                    ' ' ordstatus,
                    ' ' clientid,
                    ' ' execbroker,
                    ' ' listid,
                    ' ' account,
                    ' ' transacttime,
                    ' ' cxlrejresponseto,
                    ' ' cxlrejreason,
                    'Too late to cancel' text,
                    ' ' encodedtextlen,
                    ' ' encodedtext,
                    'N',
                    fo.traderid,
                    bl_odreject_seq.NEXTVAL
                  FROM   FOMAST fo, odmast od
                  WHERE  fo.orgacctno(+) = od.orderid
                  AND    fo.VIA ='L'
                  AND od.orderid =i.rcdkey;

 ElsIf  i.Eventname = 'REPLACE_FILLED' Then

               INSERT INTO bl_ordercancelreject (Msgtype,
                                      orderid,
                                      secondaryorderid,
                                      clordid,
                                      origclordid,
                                      ordstatus,
                                      clientid,
                                      execbroker,
                                      listid,
                                      account,
                                      transacttime,
                                      cxlrejresponseto,
                                      cxlrejreason,
                                      text,
                                      encodedtextlen,
                                      encodedtext,
                                      process,
                                      traderid,
                                      autoid)
             Select     '9' Msgtype,
                    FOREFID orderid,
                    ' ' secondaryorderid,
                    FOREFID clordid,
                    ' ' origclordid,
                    ' ' ordstatus,
                    ' ' clientid,
                    ' ' execbroker,
                    ' ' listid,
                    ' ' account,
                    ' ' transacttime,
                    ' ' cxlrejresponseto,
                    ' ' cxlrejreason,
                    'Too late to amend' text,
                    ' ' encodedtextlen,
                    ' ' encodedtext,
                    'N',
                    fo.traderid,
                    bl_odreject_seq.NEXTVAL
                  FROM   FOMAST fo, odmast od
                  WHERE  fo.orgacctno(+) = od.orderid
                  AND    fo.VIA ='L'
                  AND od.orderid =i.rcdkey;
            Elsif i.Eventname = 'ODMAST' Then
                INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     0 cumqty,
                     sbc.shortcd currency,
                     od.txnum execid,
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     '0' exectype,                                          --lenh sua
                     '1' idsource,
                     '0' lastpx,
                     '0' lastshares,
                     NVL (od.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od.orderid orderid,
                     od.orderqtty orderqty,
                     '0' ordstatus,
                     CASE
                        WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo.traderid
              FROM   fomast fo,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od,
                     allcode a
             WHERE       fo.orgacctno(+) = od.orderid
                     AND od.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od.codeid = sb.codeid
                     AND od.orderid = i.rcdkey
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND fo.VIA ='L';

           Elsif i.Eventname = 'IOD_FILLED' Then --Khop toan bo
               INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     Round((NVL(m.execamt,0))/(NVL(m.execqtty,0)),2) avgpx,
                     NVL (m.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     '' currency,
                     iod.txnum execid,
                     ''  execrefid,
                     '0' exectranstype,
                     case when m.quantity - m.cancelqtty - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - m.cancelqtty - NVL(m.execqtty,0) = 0 then '2' end  exectype,
                     '1' idsource,
                     iod.matchprice lastpx,
                     iod.matchqtty lastshares,
                     m.quantity - m.cancelqtty - NVL(m.execqtty,0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     iod.orgorderid orderid,
                     --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                     m.quantity orderqty,
                     case when m.quantity - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - NVL(m.execqtty,0) = 0 then '2' end ordstatus,
                     '' ordtype,
                     bl_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     iod.symbol symbol,
                     NVL (m.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     m.traderid
              FROM   iod ,
                     --fomast fo,
                     odmast od,
                     bl_odmast m,
                     bl_odmast bl_org
             WHERE   --(fo.orgacctno = od.orderid Or fo.refacctno =od.reforderid OR od.foacctno = fo.acctno)
                     --AND
                     od.orderid = iod.orgorderid
                     AND m.blorderid =od.blorderid
                     AND m.rootorderid = bl_org.blorderid
                     AND m.VIA ='L'
                     AND m.execqtty > 0
                     AND iod.txnum = i.rcdkey;
                 /*SELECT   i.id,
                     '8' msgtype,
                     Round((od.execamt + NVL(m.execamt,0))/(od.execqtty + NVL(m.execqtty,0)),2) avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     od.execqtty + NVL(m.execqtty,0) cumqty,
                     '' currency,
                     iod.txnum execid,
                     ''  execrefid,
                     '0' exectranstype,
                     '2' exectype,                                          --lenh sua
                     '1' idsource,
                     iod.matchprice lastpx,
                     iod.qtty lastshares,
                     '0' leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     iod.orgorderid orderid,
                     --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                     m.quantity orderqty,
                     '2' ordstatus,
                     '' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     iod.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo.traderid
              FROM   iod ,
                     fomast fo,
                     odmast od,
                     bl_odmast m
             WHERE   (fo.orgacctno = od.orderid Or fo.refacctno =od.reforderid OR od.foacctno = fo.acctno)
                     AND od.orderid = iod.orgorderid
                     AND m.forefid(+) =fo.forefid
                     AND iod.txnum = i.rcdkey
                     AND fo.VIA ='L'
             UNION ALL
             SELECT   i.id,
                     '8' msgtype,
                     Round((od.execamt + NVL(m.execamt,0))/(od.execqtty + NVL(m.execqtty,0)),2) avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     od.execqtty + NVL(m.execqtty,0) cumqty,
                     '' currency,
                     iod.txnum execid,
                     ''  execrefid,
                     '0' exectranstype,
                     '2' exectype,                                          --lenh sua
                     '1' idsource,
                     iod.matchprice lastpx,
                     iod.qtty lastshares,
                     '0' leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     iod.orgorderid orderid,
                     --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                     m.quantity orderqty,
                     '2' ordstatus,
                     '' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     iod.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo.traderid
              FROM   iod ,
                     fomast fo,
                     odmast od,
                     bl_odmast m
             WHERE   fo.orgacctno <> od.orderid AND fo.orgacctno <> od.reforderid--and fo.refacctno <> od.reforderid
                    AND fo.orgacctno = fopks_api.fn_GetRootOrderID(od.orderid)
                     AND od.orderid = iod.orgorderid
                     AND m.forefid(+) =fo.forefid
                     AND iod.txnum = i.rcdkey
                     AND fo.VIA ='L';*/

             Elsif i.Eventname = 'IOD_PART_FILLED' Then --Khop mot phan
               INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     Round((NVL(m.execamt,0))/(NVL(m.execqtty,0)),2) avgpx,
                     NVL (m.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     '' currency,
                     iod.txnum execid,
                     ''  execrefid,
                     '0' exectranstype,
                     case when m.quantity - m.cancelqtty - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - m.cancelqtty - NVL(m.execqtty,0) = 0 then '2' end  exectype,                                          --lenh sua
                     '1' idsource,
                     iod.matchprice lastpx,
                     iod.matchqtty lastshares,
                     m.quantity - m.cancelqtty - m.execqtty leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     iod.orgorderid orderid,
                     --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                     m.quantity orderqty,
                     case when m.quantity - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - NVL(m.execqtty,0) = 0 then '2' end  ordstatus,
                     '' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     iod.symbol symbol,
                     NVL (m.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     m.traderid
              FROM   iod ,
                     --fomast fo,
                     odmast od,
                     bl_odmast m
             WHERE   --(fo.orgacctno = od.orderid Or fo.refacctno =od.reforderid OR od.foacctno = fo.acctno) --Lenh sua thi fomast chi co y/c sua
                     --AND
                     od.orderid = iod.orgorderid
                     AND iod.txnum = i.rcdkey
                     --and m.forefid(+) =fo.forefid
                     AND od.blorderid = m.blorderid
                     AND m.VIA ='L'
                     AND m.execqtty > 0;
                 /*SELECT   i.id,
                     '8' msgtype,
                     Round((od.execamt + NVL(m.execamt,0))/(od.execqtty + NVL(m.execqtty,0)),2) avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     '' currency,
                     iod.txnum execid,
                     ''  execrefid,
                     '0' exectranstype,
                     case when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) = 0 then '2' end  exectype,                                          --lenh sua
                     '1' idsource,
                     iod.matchprice lastpx,
                     iod.matchqtty lastshares,
                     od.remainqtty leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     iod.orgorderid orderid,
                     --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                     m.quantity orderqty,
                     case when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) = 0 then '2' end  ordstatus,
                     '' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     iod.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo.traderid
              FROM   iod ,
                     fomast fo,
                     odmast od,
                     bl_odmast m
             WHERE   (fo.orgacctno = od.orderid Or fo.refacctno =od.reforderid OR od.foacctno = fo.acctno) --Lenh sua thi fomast chi co y/c sua
                     AND od.orderid = iod.orgorderid
                     AND iod.txnum = i.rcdkey
                     and m.forefid(+) =fo.forefid
                     AND fo.VIA ='L'
             UNION ALL
             SELECT   i.id,
                     '8' msgtype,
                     Round((od.execamt + NVL(m.execamt,0))/(od.execqtty + NVL(m.execqtty,0)),2) avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     '' currency,
                     iod.txnum execid,
                     ''  execrefid,
                     '0' exectranstype,
                     case when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) = 0 then '2' end  exectype,                                          --lenh sua
                     '1' idsource,
                     iod.matchprice lastpx,
                     iod.matchqtty lastshares,
                     od.remainqtty leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     iod.orgorderid orderid,
                     --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                     m.quantity orderqty,
                     case when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) > 0 then '1'
                          when m.quantity - m.cancelqtty - m.ptbookqtty - NVL(m.execqtty,0) = 0 then '2' end  ordstatus,
                     '' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     iod.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo.traderid
              FROM   iod ,
                     fomast fo,
                     odmast od,
                     bl_odmast m
             WHERE   fo.orgacctno <> od.orderid AND fo.orgacctno <> od.reforderid--AND fo.refacctno <> od.reforderid
                    AND fo.orgacctno = fopks_api.fn_GetRootOrderID(od.orderid)
                     AND od.orderid = iod.orgorderid
                     AND iod.txnum = i.rcdkey
                     and m.forefid(+) =fo.forefid
                     AND fo.VIA ='L';*/

           Elsif i.Eventname = 'CANCEL_PENDING' Then --Yeu cau huy Pending
             --Yeu cau huy Pending
              INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     od_org.exqtty cumqty,
                     sbc.shortcd currency,
                     od.txnum execid,
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     '6' exectype,                                          --lenh sua
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     NVL (od.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     od_org.orderqtty orderqty,
                     '6' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,
                     odmast od,
                     allcode a,
                     fomast fo
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND od_org.orderid = od.reforderid
                     --AND fo_org.orgacctno(+) = od_org.orderid
                     AND (fo_org.orgacctno = od_org.orderid OR od_org.foacctno = fo_org.acctno)
                     AND fo.orgacctno = od.orderid
                     AND (fo_org.VIA ='L' or fo.VIA='L')
                     AND od.orderid = i.rcdkey;

           Elsif i.Eventname = 'CANCELLED' Then --Yeu cau huy thanh cong
             --Huy thanh cong
              INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 text,
                                 process,
                                 traderid)
                 SELECT   i.id,  --Huy lenh goc la lenh moi tu BL.
                     '8' msgtype,
                     '0' avgpx,
                     fo.forefid clordid, --Neu khong co - lay cua lenh goc.
                     ' ' commission,
                     '1' commtype,
                     od_org.exqtty cumqty,
                     sbc.shortcd currency,
                     od.txnum||od_org.edstatus execid,    --'0001000001W'
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     '4' exectype,
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     0 leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     od_org.orderqtty orderqty,
                     '4' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'Cancelled by Bloomberg' Text,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,
                     odmast od,
                     allcode a,
                     fomast fo
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND od_org.orderid = od.reforderid
                     --AND fo_org.orgacctno = od_org.orderid
                     AND (fo_org.orgacctno = od_org.orderid OR fo_org.acctno = od_org.foacctno)
                     AND fo.orgacctno = od.orderid
                     AND fo_org.VIA ='L'
                     AND fo.VIA='L'
                     AND od_org.orderid = i.rcdkey
           UNION
           --Huy lenh goc = VND, khong co lenh yeu cau huy trong fomast.
           SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     fo_org.forefid clordid, --Neu khong co - lay cua lenh goc.
                     ' ' commission,
                     '1' commtype,
                     od_org.exqtty cumqty,
                     sbc.shortcd currency,
                     od.txnum||od_org.edstatus execid,    --'0001000001W'
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     '4' exectype,
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     0 leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     od_org.orderqtty orderqty,
                     '4' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo_org.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'Cancelled by BMSC' Text,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,
                     odmast od,
                     allcode a
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND od_org.orderid = od.reforderid
                     AND not exists (select 1 from fomast fo where fo.orgacctno = od.orderid and fo.via ='L')
                     AND (fo_org.orgacctno = od_org.orderid OR od_org.foacctno = fo_org.acctno)
                     AND fo_org.VIA ='L'
                     AND od_org.orderid = i.rcdkey

         UNION
           --Huy lenh sua = Bloomberg.
           SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     fo.forefid clordid, --Neu khong co - lay cua lenh goc.
                     ' ' commission,
                     '1' commtype,
                     od_org.exqtty cumqty,
                     sbc.shortcd currency,
                     od_ychuy.txnum||od_org.edstatus execid,    --'0001000001W'
                     NVL (od_ychuy.reforderid, '') execrefid,
                     '0' exectranstype,
                     '4' exectype,
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     0 leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     od_org.orderqtty orderqty,
                     '4' ordstatus,
                     CASE
                         WHEN od_ychuy.pricetype IN ('LO', '2') THEN '2'
                         WHEN od_ychuy.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od_ychuy.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od_ychuy.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od_ychuy.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od_ychuy.afacctno,
                     'Cancelled (After Replaced) by Bloomberg' Text,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,  --Lenh huy (lenh duoc sinh ra tu lenh sua).
                     odmast od_ycsua,--Lenh y/c huy.
                     odmast od_ychuy,
                     allcode a,
                     fomast fo
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid

                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval

                     AND od_org.reforderid = od_ycsua.reforderid
                     AND od_ycsua.Exectype in ('AS','AB')
                     AND od_ychuy.reforderid = od_org.orderid

                     AND fo_org.orgacctno = od_ycsua.orderid
                     AND fo.orgacctno     = od_ychuy.orderid

                     AND fo_org.VIA ='L' AND fo.VIA='L'
                     AND od_org.orderid = i.rcdkey

         UNION
            --Huy lenh sua = VND.
           SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     fo_org.forefid clordid, --Neu khong co - lay cua lenh goc.
                     ' ' commission,
                     '1' commtype,
                     od_org.exqtty cumqty,
                     sbc.shortcd currency,
                     od_ychuy.txnum||od_org.edstatus execid,    --'0001000001W'
                     NVL (od_ychuy.reforderid, '') execrefid,
                     '0' exectranstype,
                     '4' exectype,
                     '1' idsource,
                     od_org.quoteprice lastpx,
                     0 lastshares,
                     0 leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     od_org.orderqtty orderqty,
                     '4' ordstatus,
                     CASE
                         WHEN od_ychuy.pricetype IN ('LO', '2') THEN '2'
                         WHEN od_ychuy.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od_ychuy.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od_ychuy.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od_ychuy.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo_org.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od_ychuy.afacctno,
                     'Cancelled (After Replaced) by BMSC' Text,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,  --Lenh huy (lenh duoc sinh ra tu lenh sua).
                     odmast od_ycsua,--Lenh y/c huy.
                     odmast od_ychuy,
                     allcode a
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid

                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval

                     AND od_org.reforderid = od_ycsua.reforderid
                     AND od_ycsua.Exectype in ('AS','AB')
                     AND od_ychuy.reforderid = od_org.orderid

                     AND fo_org.orgacctno = od_ycsua.orderid
                     AND NOT EXISTS (SELECT 1 From FOMAST fo Where fo.orgacctno  = od_ychuy.orderid and fo.VIA ='L')

                     AND fo_org.VIA ='L'
                     AND od_org.orderid = i.rcdkey
                     ;

         Elsif i.Eventname = 'REPLACE_PENDING' Then --Yeu cau sua Pending
             --Yeu cau sua Pending
              INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 price,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (m.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     sbc.shortcd currency,
                     od.txnum execid,
                     --NVL (od.reforderid, '') execrefid,
                     '' execrefid,
                     '0' exectranstype,
                     'E' exectype,                                          --lenh sua
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     NVL (od.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     bl_org.blorderid orderid,
                     m.quantity orderqty,
                     'E' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     od.quoteprice price,
                     bl_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN bl_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN bl_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (m.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     m.traderid
              FROM   sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od,
                     bl_odmast m,
                     bl_odmast bl_org
             WHERE   ci.afacctno = mst.acctno
                     AND od.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od.codeid = sb.codeid
                     AND od.blorderid = m.blorderid
                     AND m.rootorderid = bl_org.blorderid
                     AND m.via = 'L'
                     AND od.orderid = i.rcdkey;
                 /*SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     sbc.shortcd currency,
                     od.txnum execid,
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     'E' exectype,                                          --lenh sua
                     '1' idsource,
                     NVL (od.quoteprice, fo.quoteprice) lastpx,
                     NVL (od.execqtty, 0) lastshares,
                     NVL (od.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     od_org.orderqtty orderqty,
                     'E' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO', '1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                     END
                         ordtype,
                     od.quoteprice price,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,
                     odmast od,
                     allcode a,
                     fomast fo,
                     bl_msgseqnum_map m
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid

                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND od_org.orderid = od.reforderid
                     AND fo_org.orgacctno(+) = od_org.orderid
                     AND fo.orgacctno = od.orderid
                     AND (fo_org.VIA ='L' or fo.VIA='L')
                     AND m.clordid(+) =fo.forefid
                     AND od.orderid = i.rcdkey;*/

      Elsif i.Eventname = 'REPLACED' Then --Sua thanh cong
             --Sua thanh cong
               INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 price,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 text,
                                 process,
                                 traderid)
            SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (bl.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(bl.execqtty,0) cumqty,
                     sbc.shortcd currency,
                     od.txnum||odreq.edstatus execid,    --'0001000001S'
                     --NVL (odreq.reforderid, '') execrefid,
                     '' execrefid,
                     '0' exectranstype,
                     '5' exectype,                                          --lenh sua
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     NVL (bl.quantity, 0) - nvl(bl.execqtty,0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od.orderid orderid,
                     NVL (bl.quantity, 0) orderqty,--NVL (od.remainqtty, 0) orderqty,

                     '5' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     odreq.quoteprice price,
                     bl_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (bl.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     '' text,
                     'N',
                     bl.traderid
              FROM   sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od,
                     odmast odreq,
                      bl_odmast bl,
                      bl_odmast bl_org,
                      bl_odmastdtl bldtl
             WHERE   od.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od.codeid = sb.codeid
                     AND odreq.reforderid = od.orderid
                     AND odreq.exectype IN ('AB','AS')
                     AND odreq.blorderid = bl.blorderid
                     AND bl.rootorderid = bl_org.blorderid
                     AND bl.blorderid = bldtl.adorderid
                     AND bldtl.via = 'L'
                     AND bl.via = 'L'
                     and od.exectype in ('NB','NS','MS')
                     AND od.orderid = i.rcdkey
           UNION ALL
           --Sua lenh goc = BSC, khong co lenh yeu cau sua trong fomast.
           SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (bl.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(bl.execqtty,0) cumqty,
                     sbc.shortcd currency,
                     od.txnum||odreq.edstatus execid,    --'0001000001S'
                     NVL (odreq.reforderid, '') execrefid,
                     '0' exectranstype,
                     '5' exectype,                                          --lenh sua
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     NVL (bl.quantity, 0) - nvl(bl.execqtty,0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od.orderid orderid,
                     NVL (bl.quantity, 0) orderqty,--NVL (od.remainqtty, 0) orderqty,

                     '5' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     odreq.quoteprice price,
                     bl_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (bl.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'Replaced by BMSC' text,
                     'N',
                     bl.traderid
              FROM   sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od,
                     odmast odreq,
                      bl_odmast bl,
                      bl_odmast bl_org,
                      bl_odmastdtl bldtl
             WHERE   od.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od.codeid = sb.codeid
                     AND odreq.reforderid = od.orderid
                     AND odreq.exectype IN ('AB','AS')
                     AND odreq.blorderid = bl.blorderid
                     AND bl.rootorderid = bl_org.blorderid
                     AND bl.blorderid = bldtl.adorderid
                     AND bldtl.via <> 'L'
                     AND bl.via = 'L'
                     AND bl.blodtype = '1'
                     and od.exectype in ('NB','NS','MS')
                     AND od.orderid = i.rcdkey;
            /*SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (fo.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(m.execqtty,0) cumqty,
                     sbc.shortcd currency,
                     od.txnum||od_org.edstatus execid,    --'0001000001S'
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     '5' exectype,                                          --lenh sua
                     '1' idsource,
                     NVL (od_new.quoteprice, fo.quoteprice) lastpx,
                     NVL (od.execqtty, 0) lastshares,
                     NVL (od_new.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     NVL(m.quantity,0) orderqty,
                     '5' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO', '1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                     END
                         ordtype,
                     od_new.quoteprice price,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     '' text,
                     'N',
                     fo.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,    --Lenh goc
                     odmast od,        --Lenh yeu cau sua
                     odmast od_new,    --Lenh sua moi
                     allcode a,
                     fomast fo,
                     bl_odmast m
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid
                     AND od_org.orderid =od_new.reforderid
                     and od_new.exectype in ('NB','NS','MS')
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND od_org.orderid = od.reforderid
                     AND fo_org.orgacctno(+) = od_org.orderid
                     AND fo.orgacctno = od.orderid
                     AND (fo_org.VIA ='L' or fo.VIA='L')
                     AND m.forefid =fo.forefid
                     AND od_org.orderid = i.rcdkey
            UNION ALL
           --Sua lenh goc = BVS, khong co lenh yeu cau sua trong fomast.
           SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (fo_org.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     NVL(od_org.execqtty,0) cumqty,
                     sbc.shortcd currency,
                     od.txnum||od_org.edstatus execid,    --'0001000001S'
                     NVL (od.reforderid, '') execrefid,
                     '0' exectranstype,
                     '5' exectype,                                          --lenh sua
                     '1' idsource,
                     NVL (od.quoteprice, od_org.quoteprice) lastpx,
                     NVL (od.execqtty, 0) lastshares,
                     NVL (od.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     od_org.orderid orderid,
                     NVL (od.orderqtty, 0) orderqty,--NVL (od.remainqtty, 0) orderqty,

                     '5' ordstatus,
                     CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO', '1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                     END
                         ordtype,
                     od.quoteprice price,
                     fo_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN od_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     sb.symbol symbol,
                     NVL (fo_org.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     od.afacctno,
                     'Replaced by BSC' text,
                     'N',
                     fo_org.traderid
              FROM   fomast fo_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     odmast od_org,
                     odmast od,
                     allcode a,
                      odmast od_org1
             WHERE   od_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND od_org.codeid = sb.codeid
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND od_org.orderid = fopks_api.fn_GetRootOrderID(od.orderid)--od.reforderid
                     and od_org1.orderid = od.reforderid
                     and od.exectype in ('NB','NS','MS')
                     AND not exists (select 1 from fomast fo where fo.refacctno = od_org1.orderid and fo.via ='L' AND fo.status <> 'R')
                     AND fo_org.orgacctno = fopks_api.fn_GetRootOrderID(od.orderid)
                     AND fo_org.VIA ='L' AND fo_org.exectype IN ('NB','NS')
                     AND od_org1.orderid = i.rcdkey;*/

            Elsif i.Eventname = 'DONE4DAY' Then
                plog.debug(pkgctx,'Begin Done for day.'||i.rcdkey);
             Insert into bl_exec_rpt(id,msgtype,
                                 clordid,
                                 avgpx,
                                 cumqty,
                                 currency,
                                 execid,
                                 exectranstype,
                                 exectype,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 orderid,
                                 orderqty,
                                 PRICE,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 side,
                                 symbol,
                                 text,
                                 process,
                                 traderid)
             Select i.id,
                    '8' msgtype,
                    fo.forefid clordid,
                    '0' avgpx,
                    '0' cumqty,
                    'VND' currency,
                    to_char(fo.acctno) execid,
                    '0' exectranstype,
                    '3' exectype,
                    '0' lastpx,
                    '0' lastshares,
                    '0' leavesqty,
                    od.orderid orderid,
                    od.orderqtty orderqty,
                    fo.price,
                    '3' ordstatus,
                    CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END ordtype,
                    '' OrigClOrdID,
                    CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                    END side,
                    sb.symbol symbol,
                    'Done for Day' text,
                    'N' process,
                    fo.traderid
             from odmast od, fomast fo, sbsecurities sb
             where od.orderid = fo.orgacctno
             and od.codeid = sb.codeid
             and od.reforderid is null
             and od.orderid = i.rcdkey
             UNION ALL
             Select i.id,
                    '8' msgtype,
                    fo_ycsua.forefid clordid,-- lay so yeu cau huy
                    '0' avgpx,
                    '0' cumqty,
                    'VND' currency,
                    to_char(od.txnum) execid,
                    '0' exectranstype,
                    '3' exectype,
                    '0' lastpx,
                    '0' lastshares,
                    '0' leavesqty,
                    od.orderid orderid,
                    od.orderqtty orderqty,
                    od.quoteprice price,
                    '3' ordstatus,
                    CASE
                         WHEN od.pricetype IN ('LO', '2') THEN '2'
                         WHEN od.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN od.pricetype IN ('ATC', '5') THEN '5'
                         WHEN od.pricetype IN ('MTL', '7') THEN '7'
                         WHEN od.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END ordtype,
                    fo_ycsua.forefid OrigClOrdID,
                    CASE
                         WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                    END side, sb.symbol symbol,
                    'Done for Day' text, 'N' process, fo_ycsua.traderid
             from odmast od, sbsecurities sb, fomast fo_ycsua
             where --od.orderid = fo.orgacctno
              od.codeid = sb.codeid
             and od.reforderid is not null
             and od.reforderid = fo_ycsua.refacctno
             and fo_ycsua.exectype in ('AS','AB')
             and od.orderid = i.rcdkey;

         Elsif i.Eventname = 'BLODMAST' Then
                INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 price,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (bl.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     0 cumqty,
                     sbc.shortcd currency,
                     bl.blorderid execid,
                     NVL (bl.refblorderid, '') execrefid,
                     '0' exectranstype,
                     '0' exectype,                                          --lenh sua
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     NVL (bl.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     bl.blorderid orderid,
                     bl.quantity orderqty,
                     '0' ordstatus,
                     CASE
                         WHEN bl.pricetype IN ('LO', '2') THEN '2'
                         WHEN bl.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN bl.pricetype IN ('ATC', '5') THEN '5'
                         WHEN bl.pricetype IN ('MTL', '7') THEN '7'
                         WHEN bl.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     NVL (bl.price, 0)*1000 price,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN bl.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN bl.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     bl.symbol symbol,
                     NVL (bl.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     bl.afacctno,
                     'N',
                     bl.traderid
              FROM   bl_odmast bl,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     sbsecurities sb,
                     allcode a
             WHERE   bl.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND bl.codeid = sb.codeid
                     AND bl.blorderid = i.rcdkey
                     AND a.cdtype = 'SE'
                     AND a.cdname = 'TRADEPLACE'
                     AND sb.tradeplace = a.cdval
                     AND bl.VIA ='L';

         ELSIF  i.Eventname = 'BLODMAST_RJ' Then
                INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 text,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     FOREFID clordid,
                     ' ' commission,
                     '1' commtype,
                     0 cumqty,
                     ' ' currency,
                     FOREFID execid,
                     ' ' execrefid,
                     '0' exectranstype,
                     '8' exectype,
                     ' ' idsource,
                     '0'  lastpx,
                     '0' lastshares,
                     QUANTITY leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     FOREFID orderid,
                     QUANTITY orderqty,
                     '8' ordstatus,
                     ' ' ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                      side,
                     symbol symbol,
                     ''  transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     afacctno afacctno,
                     CASE WHEN feedbackmsg LIKE '%[-700012]%'
                                            THEN 'Invalid Price'
                          WHEN feedbackmsg LIKE '%[-700011] Sai lo giao dich%'
                                            THEN 'Invalid Trade lot'
                          WHEN feedbackmsg LIKE '%[-400116]%'
                                            THEN 'Balance not enough.'
                          WHEN feedbackmsg LIKE '%[-900017]%'
                                            THEN 'Trade not enough.'
                          WHEN feedbackmsg LIKE '%[-700014]%'
                                            THEN 'Ticksize incompliant.'
                          WHEN feedbackmsg LIKE '%[-700052]%'
                                            THEN 'HOSE trade place is not amend.'
                          WHEN feedbackmsg LIKE '%Cancelled by BMSC%'
                                            THEN 'Cancelled by BMSC.'
                                ELSE 'Invalid Order'
                     END text,
                     'N',
                     traderid
              FROM   bl_odmast
              WHERE  VIA ='L'
                 AND blorderid =i.rcdkey;

         Elsif i.Eventname = 'BLCANCEL_PD' Then --Yeu cau huy Pending
             --Yeu cau huy Pending
              INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                 SELECT   i.id,
                     '8' msgtype,
                     '0' avgpx,
                     NVL (bl.forefid, ' ') clordid,
                     ' ' commission,
                     '1' commtype,
                     bl_org.remainqtty cumqty,
                     sbc.shortcd currency,
                     bl.blorderid || 'CP' execid,
                     NVL (bl_org.refblorderid, '') execrefid,
                     '0' exectranstype,
                     '6' exectype,                                          --lenh sua
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     NVL (bl_org.remainqtty, 0) leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     bl_org.blorderid orderid,
                     bl_org.quantity orderqty,
                     '6' ordstatus,
                     CASE
                         WHEN bl_org.pricetype IN ('LO', '2') THEN '2'
                         WHEN bl_org.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN bl_org.pricetype IN ('ATC', '5') THEN '5'
                         WHEN bl_org.pricetype IN ('MTL', '7') THEN '7'
                         WHEN bl_org.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     BL_org.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN BL_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN BL_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     bl_org.symbol symbol,
                     NVL (bl.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     bl_org.afacctno,
                     'N',
                     bl_org.traderid
              FROM   bl_odmast bl_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     bl_odmastdtl bl
             WHERE   bl_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND bl_org.blorderid = bl.blorderid
                     AND (bl_org.VIA ='L' and bl.VIA='L')
                     AND bl.blorderid = i.rcdkey;

         Elsif i.Eventname = 'BLCANCEL' Then --Yeu cau huy thanh cong
             --Huy thanh cong
              INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 text,
                                 process,
                                 traderid)
                 SELECT   i.id,  --Huy lenh goc la lenh moi tu BL.
                     '8' msgtype,
                     '0' avgpx,
                     nvl(bl.forefid,bl_org.forefid) clordid, --Neu khong co - lay cua lenh goc.
                     ' ' commission,
                     '1' commtype,
                     bl_org.execqtty cumqty,
                     sbc.shortcd currency,
                     bl_org.blorderid||'C' execid,    --'0001000001W'
                     NVL (bl.adorderid, '') execrefid,
                     '0' exectranstype,
                     '4' exectype,
                     '1' idsource,
                     0 lastpx,
                     0 lastshares,
                     0 leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     bl_org.blorderid orderid,
                     bl_org.quantity orderqty,
                     '4' ordstatus,
                     CASE
                         WHEN bl_org.pricetype IN ('LO', '2') THEN '2'
                         WHEN bl_org.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN bl_org.pricetype IN ('ATC', '5') THEN '5'
                         WHEN bl_org.pricetype IN ('MTL', '7') THEN '7'
                         WHEN bl_org.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END
                         ordtype,
                     bl_ORG.forefid OrigClOrdID,
                     ' ' securityid,
                     CASE
                         WHEN bl_org.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN bl_org.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                     END
                         side,
                     bl_org.symbol symbol,
                     NVL (BL.createddt, ' ') transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     bl_org.afacctno,
                     CASE WHEN nvl(BL.VIA,'F') = 'L' THEN 'Cancelled by Bloomberg'
                            WHEN substr(bl_org.pstatus,length(bl_org.pstatus),1) = 'T' THEN 'Cancelled by BMSC, not enough cash or securities balance!'
                            ELSE 'Cancelled by BMSC' END Text,
                     'N',
                     bl_org.traderid
              FROM   bl_odmast bl_org,
                     sbcurrency sbc,
                     afmast mst,
                     cimast ci,
                     (SELECT max(via) via, max(createddt) createddt,max(adorderid) adorderid, max(forefid) forefid, blorderid
                     FROM bl_odmastdtl WHERE exectype IN ('CB','CS') AND status = 'C' GROUP BY blorderid) bl
             WHERE   bl_org.afacctno = mst.acctno
                     AND ci.afacctno = mst.acctno
                     AND sbc.ccycd = ci.ccycd
                     AND bl_org.blorderid = bl.blorderid (+)
                     --AND bl.exectype IN ('CB','CS')
                     AND bl_org.VIA ='L'
                     AND bl_org.blorderid = i.rcdkey
                     ;
         Elsif i.Eventname = 'MAPORDER' Then --Khop mot phan
            -- Lay SL khop tong cua lenh map vao
            SELECT execqtty
            INTO l_odmatchqtty
            FROM odmast
            WHERE orderid = i.rcdkey;
            l_iodmatchqtty := 0;
            -- Xu ly tung lenh khop cua lenh
            FOR riod IN
            (
                SELECT * FROM iod WHERE orgorderid = i.rcdkey
            )
            LOOP
                -- Neu chua co trong bang map lenh thi insert vao
                SELECT COUNT(*)
                INTO l_count
                FROM bl_maporder bl
                WHERE bl.blorderid = i.orderid AND bl.orderid = i.rcdkey AND bl.txnum = riod.txnum;
                IF l_count = 0 THEN
                    INSERT INTO bl_maporder (autoid,BLORDERID,ORDERID,TXNUM,TXDATE,STATUS,MAPTIME)
                    values(bl_maporder_seq.NEXTVAL,i.orderid,i.rcdkey,riod.txnum,riod.txdate,'M',SYSTIMESTAMP);
                ELSE
                    UPDATE bl_maporder SET
                        PSTATUS = PSTATUS || STATUS,
                        status = 'M',
                        MAPTIME = SYSTIMESTAMP
                    WHERE blorderid = i.orderid AND orderid = i.rcdkey AND txnum = riod.txnum;
                END IF;
                -- Day thong tin cho Bloomberg
                INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                     SELECT   i.id,
                         '8' msgtype,
                         Round(NVL(m.execamt,0)/NVL(m.execqtty,0),2) avgpx,
                         NVL (m.forefid, ' ') clordid,
                         ' ' commission,
                         '1' commtype,
                         GREATEST(NVL(m.execqtty,0)- nvl(l_odmatchqtty,0) + nvl(l_iodmatchqtty,0),0) + iod.matchqtty cumqty,
                         '' currency,
                         iod.txnum execid,
                         ''  execrefid,
                         '0' exectranstype,
                         case when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) > 0 then '1'
                              when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) = 0 then '2' ELSE '1' end  exectype,                                          --lenh sua
                         '1' idsource,
                         iod.matchprice lastpx,
                         iod.matchqtty lastshares,
                         m.quantity - m.cancelqtty - NVL(m.execqtty,0) leavesqty,
                         0 nomiscfees,
                         0 miscfeeamt,
                         m.blorderid orderid,
                         --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                         m.quantity orderqty,
                         case when m.quantity - NVL(m.execqtty,0) > 0 then '1'
                              when m.quantity - NVL(m.execqtty,0) = 0 then '2' end  ordstatus,
                         '' ordtype,
                         ' ' OrigClOrdID,
                         ' ' securityid,
                         CASE
                             WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                             WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                         END
                             side,
                         m.symbol symbol,
                         NVL (m.createddt, ' ') transactiontime,
                         ' ' securitytype,
                         'VN' securityexchange,
                         'OD' tblname,
                         od.afacctno,
                         'N',
                         m.traderid
                  FROM   iod ,
                         --fomast fo,
                         odmast od,
                         bl_odmast m
                 WHERE   od.blorderid = m.blorderid
                        AND iod.orgorderid = od.orderid AND iod.deltd = 'N'
                        AND iod.txnum = riod.txnum
                         AND m.VIA ='L'
                         AND od.orderid = i.rcdkey;
                 -- Tinh lai so luong khop
                 l_iodmatchqtty := l_iodmatchqtty + riod.matchqtty;
            END LOOP;


         Elsif i.Eventname = 'UNMAPORDER' Then --Khop mot phan
            -- Lay SL khop tong cua lenh map vao
            SELECT execqtty
            INTO l_odmatchqtty
            FROM odmast
            WHERE orderid = i.rcdkey;
            l_iodmatchqtty := 0;
            -- Xu ly tung lenh khop cua lenh
            FOR riod IN
            (
                SELECT * FROM iod WHERE orgorderid = i.rcdkey
            )
            LOOP
                -- Day ve huy khop cho Bloomberg
                INSERT INTO bl_exec_rpt (id,
                                 msgtype,
                                 avgpx,
                                 clordid,
                                 commission,
                                 commtype,
                                 cumqty,
                                 currency,
                                 execid,
                                 execrefid,
                                 exectranstype,
                                 exectype,
                                 idsource,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 nomiscfees,
                                 miscfeeamt,
                                 orderid,
                                 orderqty,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 securityid,
                                 side,
                                 symbol,
                                 transactiontime,
                                 securitytype,
                                 securityexchange,
                                 tblname,
                                 afacctno,
                                 process,
                                 traderid)
                     SELECT   i.id,
                         '8' msgtype,
                         CASE WHEN m.execqtty >0 THEN round(m.execamt/m.execqtty,2) ELSE 0 END  avgpx,
                         NVL (m.forefid, ' ') clordid,
                         ' ' commission,
                         '1' commtype,
                         greatest(nvl(m.execqtty,0) + nvl(l_odmatchqtty,0) - nvl(l_iodmatchqtty,0),0) - iod.matchqtty cumqty,
                         '' currency,
                         iod.txnum ||'U'  execid,
                         iod.txnum  execrefid,
                         '1' exectranstype,
                         case when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) > 0 AND m.execqtty >0 then '1'
                              when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) > 0 AND m.execqtty = 0 then '0'
                              when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) = 0 then '2' end  exectype,                                          --lenh sua
                         '1' idsource,
                         iod.matchprice lastpx,
                         iod.matchqtty lastshares,
                         m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) leavesqty,
                         0 nomiscfees,
                         0 miscfeeamt,
                         m.blorderid orderid,
                         --od.remainqtty + od.execqtty + NVL(m.execqtty,0) orderqty,
                         m.quantity orderqty,
                         case when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) > 0 AND m.execqtty > 0 then '1'
                              when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) > 0 AND m.execqtty = 0 then '0'
                              when m.quantity - m.cancelqtty - m.ptbookqtty + m.ptsentqtty - NVL(m.execqtty,0) = 0 then '2' end  ordstatus,
                         '' ordtype,
                         ' ' OrigClOrdID,
                         ' ' securityid,
                         CASE
                             WHEN od.exectype IN ('NB', 'BC', '1') THEN '1'
                             WHEN od.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                         END
                             side,
                         m.symbol symbol,
                         NVL (m.createddt, ' ') transactiontime,
                         ' ' securitytype,
                         'VN' securityexchange,
                         'OD' tblname,
                         od.afacctno,
                         'N',
                         m.traderid
                  FROM   iod ,
                         --fomast fo,
                         odmast od,
                         bl_odmast m
                 WHERE   --od.blorderid = m.blorderid
                        --AND
                        iod.orgorderid = od.orderid AND iod.deltd = 'N'
                        AND iod.txnum = riod.txnum
                         AND m.VIA ='L'
                         AND od.orderid = i.rcdkey
                         AND m.blorderid = i.orderid;

                -- Neu chua co trong bang map lenh thi insert vao
                SELECT COUNT(*)
                INTO l_count
                FROM bl_maporder bl
                WHERE bl.blorderid = i.orderid AND bl.orderid = i.rcdkey AND bl.txnum = riod.txnum;
                IF l_count = 0 THEN
                    INSERT INTO bl_maporder (autoid,BLORDERID,ORDERID,TXNUM,TXDATE,STATUS,UNMAPTIME)
                    values(bl_maporder_seq.NEXTVAL,i.orderid,i.rcdkey,riod.txnum,riod.txdate,'U',SYSTIMESTAMP);
                ELSE
                    UPDATE bl_maporder SET
                        PSTATUS = PSTATUS || STATUS,
                        status = 'U',
                        UNMAPTIME = SYSTIMESTAMP
                    WHERE blorderid = i.orderid AND orderid = i.rcdkey AND txnum = riod.txnum;
                END IF;
                l_iodmatchqtty := l_iodmatchqtty + riod.matchqtty;
            END LOOP;

        Elsif i.Eventname = 'BLDONE4DAY' Then
                plog.debug(pkgctx,'Begin Done for day.'||i.rcdkey);
             Insert into bl_exec_rpt(id,msgtype,
                                 clordid,
                                 avgpx,
                                 cumqty,
                                 currency,
                                 execid,
                                 exectranstype,
                                 exectype,
                                 lastpx,
                                 lastshares,
                                 leavesqty,
                                 orderid,
                                 orderqty,
                                 PRICE,
                                 ordstatus,
                                 ordtype,
                                 OrigClOrdID,
                                 side,
                                 symbol,
                                 text,
                                 process,
                                 traderid)
             Select i.id,
                '8' msgtype,
                fo.forefid clordid,
                '0' avgpx,
                '0' cumqty,
                'VND' currency,
                to_char(fo.blorderid)||'D' execid,
                '0' exectranstype,
                 '3' exectype,
                 '0' lastpx,
                 '0' lastshares,
                 '0' leavesqty,
                 fo.blorderid orderid,
                 fo.quantity orderqty,
                 fo.price,
                 '3' ordstatus,
                    CASE
                         WHEN fo.pricetype IN ('LO', '2') THEN '2'
                         WHEN fo.pricetype IN ('MO','MP','ATO' ,'MAK','MOK','1') THEN '1'
                         WHEN fo.pricetype IN ('ATC', '5') THEN '5'
                         WHEN fo.pricetype IN ('MTL', '7') THEN '7'
                         WHEN fo.pricetype IN ('SL', '4') THEN '4'
                         else '2'
                     END ordtype,
                    '' OrigClOrdID,
                    CASE
                         WHEN fo.exectype IN ('NB', 'BC', '1') THEN '1'
                         WHEN fo.exectype IN ('NS', 'SS', 'MS', '2') THEN '2'
                    END side,
                    fo.symbol symbol,
                    'Done for Day' text,
                    'N' process,
                    fo.traderid
                 from bl_odmast fo
                 where fo.status = 'E' AND fo.blodtype IN ('1','2','3') AND fo.via = 'L'
                    and fo.blorderid = i.rcdkey
                    AND NOT EXISTS (SELECT br.execid FROM bl_exec_rpt br WHERE br.execid = fo.blorderid || 'D');




           End if;
           Update bl_event Set Process ='Y' where ID =i.ID;
     End Loop;

     Open l_refcursor for
              Select msgtype,                --35
                     avgpx,                  --6
                     clordid,                --11
                     commission,             --
                     commtype,
                     cumqty,                 --14
                     currency,
                     execid,                 --17
                     execrefid,
                     exectranstype,          --20
                     idsource,
                     lastpx,
                     lastshares,
                     nomiscfees,
                     miscfeeamt,
                     orderid,               --37
                     orderqty,              --38
                     ordstatus,             --39
                     ordtype,
                     price,
                     OrigClOrdID,
                     securityid,
                     side,                  --54
                     symbol,                --55
                     exectype,              --150
                     leavesqty,             --151
                     transactiontime transacttime,
                     securitytype,
                     securityexchange,
                     text,
                     l_TARGETCOMPID TargetCompID,
                     l_SENDERCOMPID SenderCompID,
                     'FIX.4.2' BeginString,
                     traderid TargetSubID
                     From BL_EXEC_RPT
                     where process = 'N'
                     ORDER BY id;

                Begin
                        --tmp_encode_text := fo_fn_encodeRefToString(v_refcursor);
                        plog.debug(pkgctx, 'pr_encodeRefToStringArray');
                        pr_encodeRefToStringArray(PV_REFCURSOR => l_refcursor,
                                                  vReturnArray => l_array_msg,
                                                  maxRow       => 5,
                                                  maxPage      => 255);
                        plog.debug(pkgctx,
                                   'pr_encodeRefToStringArray::' || l_array_msg.COUNT);
                        for i in 1 .. l_array_msg.COUNT
                        loop
                          tmp_encode_text := l_array_msg(i);
                          if LENGTH(tmp_encode_text) > 1 then
                            tmp_text_message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
                            tmp_text_message.set_text(tmp_encode_text);
                            plog.debug(pkgctx, 'Message content: ' || tmp_encode_text);

                            DBMS_AQ.ENQUEUE(queue_name         => ownerschema ||
                                                                  '.TXAQS_BO2FO',
                                            enqueue_options    => eopt,
                                            message_properties => mprop,
                                            payload            => tmp_text_message,
                                            msgid              => enq_msgid);


                            plog.debug(pkgctx, 'Already sent!');
                          end if;

                        end loop;
                        Close l_refcursor;
                End;

            Update BL_EXEC_RPT Set Process ='Y' where Process ='N';
       Commit;

       -- Lenh Reject
       Open l_refcursor for
                select
                           msgtype,
                           refseqnum,
                           reftagid,
                           refmsgtype,
                           sessionrejectreason,
                           text,
                           encodedtextlen,
                           encodedtext,
                          l_TARGETCOMPID TargetCompID,
                          l_SENDERCOMPID SenderCompID,
                          'FIX.4.2' BeginString
                  from bl_reject
                  where process ='N';

                Begin
                        --tmp_encode_text := fo_fn_encodeRefToString(v_refcursor);
                        plog.debug(pkgctx, 'pr_encodeRefToStringArray');
                        pr_encodeRefToStringArray(PV_REFCURSOR => l_refcursor,
                                                  vReturnArray => l_array_msg,
                                                  maxRow       => 5,
                                                  maxPage      => 255);
                        plog.debug(pkgctx,
                                   'pr_encodeRefToStringArray::' || l_array_msg.COUNT);
                        for i in 1 .. l_array_msg.COUNT
                        loop
                          tmp_encode_text := l_array_msg(i);
                          if LENGTH(tmp_encode_text) > 1 then
                            tmp_text_message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
                            tmp_text_message.set_text(tmp_encode_text);
                            plog.debug(pkgctx, 'Message content: ' || tmp_encode_text);

                            DBMS_AQ.ENQUEUE(queue_name         => ownerschema ||
                                                                  '.TXAQS_BO2FO',
                                            enqueue_options    => eopt,
                                            message_properties => mprop,
                                            payload            => tmp_text_message,
                                            msgid              => enq_msgid);


                            plog.debug(pkgctx, 'Already sent!');
                          end if;

                        end loop;
                        Close l_refcursor;
                End;

              Update bl_reject Set Process ='Y' where Process ='N';
              commit;


-- Lenh Reject
       Open l_refcursor for
                select
                        Msgtype,
                        orderid,
                        secondaryorderid,
                        clordid,
                        origclordid,
                        ordstatus,
                        clientid,
                        execbroker,
                        listid,
                        account,
                        transacttime,
                        cxlrejresponseto,
                        cxlrejreason,
                        text,
                        encodedtextlen,
                        encodedtext,
                        ---process,
                          l_TARGETCOMPID TargetCompID,
                          l_SENDERCOMPID SenderCompID,
                          'FIX.4.2' BeginString,
                          traderid TargetSubID
                  from bl_ordercancelreject
                  where process ='N'
                  ORDER BY autoid;

                Begin
                        --tmp_encode_text := fo_fn_encodeRefToString(v_refcursor);
                        plog.debug(pkgctx, 'pr_encodeRefToStringArray 9');
                        pr_encodeRefToStringArray(PV_REFCURSOR => l_refcursor,
                                                  vReturnArray => l_array_msg,
                                                  maxRow       => 5,
                                                  maxPage      => 255);
                        plog.debug(pkgctx,
                                   'pr_encodeRefToStringArray::' || l_array_msg.COUNT);
                        for i in 1 .. l_array_msg.COUNT
                        loop
                          tmp_encode_text := l_array_msg(i);
                          if LENGTH(tmp_encode_text) > 1 then
                            tmp_text_message := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
                            tmp_text_message.set_text(tmp_encode_text);
                            plog.debug(pkgctx, 'Message content: ' || tmp_encode_text);

                            DBMS_AQ.ENQUEUE(queue_name         => ownerschema ||
                                                                  '.TXAQS_BO2FO',
                                            enqueue_options    => eopt,
                                            message_properties => mprop,
                                            payload            => tmp_text_message,
                                            msgid              => enq_msgid);


                            plog.debug(pkgctx, 'Already sent!');
                          end if;

                        end loop;
                        Close l_refcursor;
                End;

              Update bl_ordercancelreject Set Process ='Y' where Process ='N';
              commit;

      plog.setendsection(pkgctx, 'Prc_Process_msg');
   END;



  BEGIN
    --get current schema
  select sys_context('userenv', 'current_schema')
    into ownerschema
    from dual;

  databaseCache := false;

  FOR i IN (SELECT * FROM tlogdebug) LOOP
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  END LOOP;

  pkgctx := plog.init('txpks_msg',
                      plevel => NVL(logrow.loglevel,30),
                      plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
                      palert => (logrow.log4alert = 'Y'),
                      ptrace => (logrow.log4trace = 'Y'));

END;
/
