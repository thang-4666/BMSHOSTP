SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_hamsg
is
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
     **  Phuongntn    06/11/2014    Created
     ** (c) 2009 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
 Procedure PRC_8_0_A_N(v_orderid VARCHAR2,OrderID VARCHAR2);
 PROCEDURE PRC_8_3_2_N(v_orderid VARCHAR2, Side VARCHAR2,LastQty VARCHAR2,LastPx VARCHAR2,  OrderID VARCHAR2);
 Procedure PRC_8_3_2_P1(v_orderid VARCHAR2,OrderID VARCHAR2 ,LastQty VARCHAR2,LastPx VARCHAR2);
 Procedure PRC_8_3_2_P2(v_orderid VARCHAR2,OrderID VARCHAR2,LastQty VARCHAR2,LastPx VARCHAR2);
 Procedure PRC_8_4_3_N(v_orderid VARCHAR2, Side VARCHAR2,LeavesQty VARCHAR2 , Orderid VARCHAR2 );
 Procedure PRC_8_4_3_P2(v_orderid VARCHAR2);
 Procedure PRC_8_4_A_P2(v_orderid VARCHAR2);
 Procedure PRC_8_5_3_N(v_orderid VARCHAR2,LastQty VARCHAR2,LastPx VARCHAR2 ,LeavesQty VARCHAR2,Orderid VARCHAR2);
 Procedure PRC_7_N(AdvSide VARCHAR2,Text VARCHAR2,Quantity VARCHAR2 ,Symbol VARCHAR2,
   DeliverToCompID VARCHAR2, Price VARCHAR2,  AdvId VARCHAR2, SenderSubID VARCHAR2, advrefid VARCHAR2 );
 Procedure PRC_7( AdvId VARCHAR2, AdvTransType VARCHAR2);
 Procedure PRC_s(v_orderid VARCHAR2,  SellPartyID VARCHAR2, BuyPartyID VARCHAR2, CrossID VARCHAR2);
 Procedure PRC_f(Symbol VARCHAR2,  LastPx VARCHAR2, LowPx VARCHAR2, HighPx VARCHAR2,TradingSessionSubID VARCHAR2,SecurityTradingStatus VARCHAR2);
 Procedure PRC_3( v_orderid VARCHAR2, RefMsgType VARCHAR2);
 Procedure PRC_u(v_orderid VARCHAR2,  SellPartyID VARCHAR2, BuyPartyID VARCHAR2, CrossID VARCHAR2);
 Procedure PRC_h(TradingSessionID VARCHAR2,  TradSesStartTime VARCHAR2, TradSesStatus VARCHAR2, TradSesReqID VARCHAR2);
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_hamsg IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;
  v_CheckProcess Boolean;
    ----------------------------------------------
  --Thong tin chung khoan
  --SECURITYTRADINGSTATUS=  ('17','24','25','26','1','27','28') binh thuong

  ----------------------------------------------
 Procedure PRC_f(Symbol VARCHAR2,  LastPx VARCHAR2, LowPx VARCHAR2, HighPx VARCHAR2,TradingSessionSubID VARCHAR2,SecurityTradingStatus VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  SellClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_f');
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>LastPx</key><value>@LastPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>Issuer</key><value>C?ng ty C? ph?n Bia S?i G?n - Mi?n Trung</value></hoSEMessageEntry><hoSEMessageEntry><key>IssueDate</key><value>20100614-17:00:00</value></hoSEMessageEntry><hoSEMessageEntry><key>TradingSessionSubID</key><value>@TradingSessionSubID@</value></hoSEMessageEntry><hoSEMessageEntry><key>SecurityTradingStatus</key><value>@SecurityTradingStatus@</value></hoSEMessageEntry><hoSEMessageEntry><key>MaturityDate</key><value>17521231-17:00:00</value></hoSEMessageEntry><hoSEMessageEntry><key>SecurityStatusReqID</key><value>1374801125879</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>@Symbol@</value></hoSEMessageEntry><hoSEMessageEntry><key>HighPx</key><value>@HighPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyVolume</key><value>12732990</value></hoSEMessageEntry><hoSEMessageEntry><key>LowPx</key><value>@LowPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>SecurityType</key><value>CS</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@Symbol@',Symbol) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastPx@',LastPx) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LowPx@',LowPx) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@HighPx@',HighPx) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@TradingSessionSubID@',TradingSessionSubID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@SecurityTradingStatus@',SecurityTradingStatus) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', 'f', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_f');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_f');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_f;
    ----------------------------------------------
  --Yeu cau huy(xac nhan) thoa thuan  (chua co temp)
  --Hoan thong tin thoa thuan ben ban gui sang
  ----------------------------------------------
 Procedure PRC_u(v_orderid VARCHAR2,  SellPartyID VARCHAR2, BuyPartyID VARCHAR2, CrossID VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  SellClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_u');
  SELECT  TRIM(ctci_order)
        INTO  SellClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>BuyPartyID</key><value>@BuyPartyID@</value></hoSEMessageEntry><hoSEMessageEntry><key>SettlType</key><value></value></hoSEMessageEntry><hoSEMessageEntry><key>BuyAccountType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyOrderQty</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141119-11:09:22</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>QuoteID</key><value>ACB00002409</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>SellNoPartyIDs</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>s</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>12</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyAccount</key><value>075C000001</value></hoSEMessageEntry><hoSEMessageEntry><key>SellSide</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BuySide</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyNoPartyIDs</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>CrossType</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>CrossID</key><value>@CrossID@</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyClOrdID</key><value></value></hoSEMessageEntry><hoSEMessageEntry><key>SellAccountType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>SellClOrdID</key><value>@SellClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>NoSides</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141119-11:09:22</value></hoSEMessageEntry><hoSEMessageEntry><key>CrossPrioritization</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>SellPartyID</key><value>@SellPartyID@</value></hoSEMessageEntry><hoSEMessageEntry><key>SellAccount</key><value>002C108316</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ACB</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>15800</value></hoSEMessageEntry><hoSEMessageEntry><key>SellOrderQty</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>261</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1223</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@SellClOrdID@',SellClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@SellPartyID@',SellPartyID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@BuyPartyID@',BuyPartyID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@CrossID@',CrossID) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', 'u', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_u');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_u');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_u;
   ----------------------------------------------
  --Xac nhan thoa thuan
  --Hoan thong tin thoa thuan ben ban gui sang
  ----------------------------------------------
 Procedure PRC_s(v_orderid VARCHAR2,  SellPartyID VARCHAR2, BuyPartyID VARCHAR2, CrossID VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  SellClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_s');
/*  SELECT  TRIM(ctci_order)
        INTO  SellClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);*/
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>BuyPartyID</key><value>@BuyPartyID@</value></hoSEMessageEntry><hoSEMessageEntry><key>SettlType</key><value></value></hoSEMessageEntry><hoSEMessageEntry><key>BuyAccountType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyOrderQty</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141119-11:09:22</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>QuoteID</key><value>ACB00002409</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>SellNoPartyIDs</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>s</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>12</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyAccount</key><value>075C000001</value></hoSEMessageEntry><hoSEMessageEntry><key>SellSide</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BuySide</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyNoPartyIDs</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>CrossType</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>CrossID</key><value>@CrossID@</value></hoSEMessageEntry><hoSEMessageEntry><key>BuyClOrdID</key><value></value></hoSEMessageEntry><hoSEMessageEntry><key>SellAccountType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>SellClOrdID</key><value>@SellClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>NoSides</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141119-11:09:22</value></hoSEMessageEntry><hoSEMessageEntry><key>CrossPrioritization</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>SellPartyID</key><value>@SellPartyID@</value></hoSEMessageEntry><hoSEMessageEntry><key>SellAccount</key><value>002C108316</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ACB</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>15800</value></hoSEMessageEntry><hoSEMessageEntry><key>SellOrderQty</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>261</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1223</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@SellClOrdID@',SellClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@SellPartyID@',SellPartyID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@BuyPartyID@',BuyPartyID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@CrossID@',CrossID) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', 's', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_s');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_s');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_s;
  ----------------------------------------------
  --3 Tu choi
  --v_orderid: So hieu lenh trong flex
  --ClOrdID--So hieu lenh
  ----------------------------------------------
 Procedure PRC_3( v_orderid VARCHAR2, RefMsgType VARCHAR2)
  is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  ClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_3');
  IF  RefMsgType='F' OR  RefMsgType='G' THEN --huy lenh
   SELECT  TRIM(ctci_order)
        INTO  ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= (SELECT orderid from odmast WHERE reforderid = TRIM(v_orderid)AND exectype IN ('CB','CS','AB','AS') AND orstatus <>'6' );
  ELSE
    SELECT  TRIM(ctci_order)
        INTO  ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  END IF;
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>SessionRejectReason</key><value>-10001</value></hoSEMessageEntry><hoSEMessageEntry><key>HandlInst</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>001C502663</value></hoSEMessageEntry><hoSEMessageEntry><key>RefMsgType</key><value>@RefMsgType@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>@ClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20130605-03:08:00.644</value></hoSEMessageEntry><hoSEMessageEntry><key>Text</key><value>loi xu ly lenh</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderQty</key><value>20000</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>HAL</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>7200</value></hoSEMessageEntry><hoSEMessageEntry><key>RefSeqNum</key><value>7</value></hoSEMessageEntry><hoSEMessageEntry><key>AccountType</key><value>2</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@ClOrdID@',ClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@RefMsgType@',RefMsgType) into xmlTemp from dual;


  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '3', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_3');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_3');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_3;

   ----------------------------------------------
  --7 (C) H?y qu?ng cáo --chua co temp
  --AdvTransType (C-huy D- da khop, A- huy khop)
  --advside(B/S):  , text: thong tin lien he, quantity, symbol
  --delivertocompid (0- toan trhi truong/ ma thanh vien neu QC dich danh)
  -- price, advid( so hieu lenh quang cao ) , sendersubid (thanh viên t?o l?nh QC)
  ----------------------------------------------
 Procedure PRC_7( AdvId VARCHAR2, AdvTransType VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_7');

  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>Quantity</key><value>50000</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvRefID</key><value>9</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141119-10:56:40</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvId</key><value>@AdvId</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderSubID</key><value>002</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>7</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvSide</key><value>S</value></hoSEMessageEntry><hoSEMessageEntry><key>Text</key><value>123456</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvTransType</key><value>@AdvTransType</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>KLS</value></hoSEMessageEntry><hoSEMessageEntry><key>DeliverToCompID</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>28000</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>137</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1220</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@AdvId@',AdvId) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@AdvTransType@',AdvTransType) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '7', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_7');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_7');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_7;


----------------------------------------------
  --7 (N) dat quang cao
  --AdvTransType =N
  --advside(B/S):  , text: thong tin lien he, quantity, symbol
  --delivertocompid (0- toan trhi truong/ ma thanh vien neu QC dich danh)
  -- price, advid( so hieu lenh quang cao do So tra ve ) , sendersubid (thanh viên t?o l?nh QC)
  --advrefid So hieu lenh go do CTCK gui len.
  ----------------------------------------------
 Procedure PRC_7_N(AdvSide VARCHAR2,Text VARCHAR2,Quantity VARCHAR2 ,Symbol VARCHAR2,
   DeliverToCompID VARCHAR2, Price VARCHAR2,  AdvId VARCHAR2, SenderSubID VARCHAR2, advrefid VARCHAR2 )
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_7_N');

  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>Quantity</key><value>@Quantity@</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvRefID</key><value>@AdvRefID@</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141119-10:56:40</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvId</key><value>@AdvId@</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderSubID</key><value>@SenderSubID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>7</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvSide</key><value>@AdvSide@</value></hoSEMessageEntry><hoSEMessageEntry><key>Text</key><value>@Text@</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>10</value></hoSEMessageEntry><hoSEMessageEntry><key>AdvTransType</key><value>N</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>@Symbol@</value></hoSEMessageEntry><hoSEMessageEntry><key>DeliverToCompID</key><value>@DeliverToCompID@</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>@Price@</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>137</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1220</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@AdvSide@',AdvSide) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Text@',Text) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Quantity@',Quantity) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Symbol@',Symbol) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@DeliverToCompID@',DeliverToCompID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Price@',Price) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@AdvId@',AdvId) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@SenderSubID@',SenderSubID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@AdvRefID@',AdvRefID) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '7', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_7_N');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_7_N');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_7_N;


 ----------------------------------------------
  --8 Xác nh?n s?a l?nh thu?ng (8-5-3)
  --v_orderid : S? hi?u l?nh trong flex
  --LastQty: Kh?i lu?ng s?a
  --LastPx: Giá s?a
  --LeavesQty: Khoi luong s?a thành công
  --<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>LastQty</key><value>100</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderID</key><value>ACB00001300</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C106317</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141117-10:27:02</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>ACB00001299</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>LeavesQty</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141117-10:27:02</value></hoSEMessageEntry><hoSEMessageEntry><key>LastPx</key><value>17000</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>5</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>4</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ACB</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>181</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1083</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>
  ----------------------------------------------
 Procedure PRC_8_5_3_N(v_orderid VARCHAR2,LastQty VARCHAR2,LastPx VARCHAR2 ,LeavesQty VARCHAR2,Orderid VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  OrigClOrdID VARCHAR2(20);
  ClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_5_3_N');

   SELECT  ctci_order
        INTO   ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID=(SELECT orderid FROM odmast WHERE reforderid= TRIM(v_orderid) AND exectype IN ('AB','AS'));
   SELECT  order_number
        INTO   OrigClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID=TRIM(v_orderid);

  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>LastQty</key><value>@LastQty@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderID</key><value>@OrderID@</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C045545</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:10:10</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>@OrigClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>LeavesQty</key><value>@LeavesQty@</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:10:10</value></hoSEMessageEntry><hoSEMessageEntry><key>LastPx</key><value>@LastPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>@ClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>5</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>582</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>HNM</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>183</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1704</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@OrigClOrdID@',OrigClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@ClOrdID@',ClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Orderid@',Orderid) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastQty@',LastQty) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastPx@',LastPx) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LeavesQty@',LeavesQty) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_5_3_N');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_5_3_N');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_5_3_N;
---------------------------------------------- chua xong
----------------------------------------------
  --8 thoa thuan khac cong ty, ben mua dong y (8-4-A)
  --Cho kiem duyet cua HNX
  --v_orderid : S? hi?u l?nh trong flex
  --Side: 8 thoa thuan
  --LeavesQty: Khoi luong huy thanh cong
  ----------------------------------------------
 Procedure PRC_8_4_A_P2(v_orderid VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  Orderid VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_4_A_P2');
   SELECT  TRIM(order_number)
        INTO  Orderid
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>@Orderid@</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C138877</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:16:19</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>@OrigClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>LeavesQty</key><value>@LeavesQty@</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>1797</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:16:19</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>4</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>701</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>PVE</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>15100</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>179</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1859</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@Orderid@',Orderid) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_4_A_P2');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_4_A_P2');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_4_A_P2;
----------------------------------------------
  --8 thoa thuan khac cong ty, ben mua ko dong y, huy lenh chua thuc hien (8-4-3)
  --v_orderid : S? hi?u l?nh trong flex
  --Side: 8 thoa thuan
  ----------------------------------------------
 Procedure PRC_8_4_3_P2(v_orderid VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  Orderid VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_4_3_P2');
   SELECT  TRIM(Order_number)
        INTO  Orderid
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>@Orderid@</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C138877</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:16:19</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>@OrigClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>LeavesQty</key><value>30000</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>1797</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:16:19</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>4</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>701</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>PVE</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>15100</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>179</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1859</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@Orderid@',Orderid) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Orderid@',Orderid) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_4_3_P2');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_4_3_P2');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_4_3_P2;
 ----------------------------------------------
  --8 Xác nh?n h?y l?nh thu?ng (8-4-3)
  --v_orderid : S? hi?u l?nh trong flex
  --Side: 1-Buy, 2-Sell
  --LeavesQty: Khoi luong huy thanh cong
  --<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>ACB00001301</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C106317</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141117-10:34:09</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>ACB00001299</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>LeavesQty</key><value>100</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141117-10:34:09</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>4</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>5</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ACB</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>17000</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>176</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1084</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>
  ----------------------------------------------
 Procedure PRC_8_4_3_N(v_orderid VARCHAR2, Side VARCHAR2,LeavesQty VARCHAR2,Orderid VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  OrigClOrdID VARCHAR2(20);
  ClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_4_3_N');
   SELECT  ctci_order
        INTO   ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID=(SELECT orderid FROM odmast WHERE reforderid= TRIM(v_orderid) AND exectype IN ('CB','CS'));
   SELECT  order_number
        INTO   OrigClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID=TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>@Orderid@</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C138877</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:16:19</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>@OrigClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>LeavesQty</key><value>@LeavesQty@</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>@ClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:16:19</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>4</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>701</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>PVE</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>@Side@</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>15100</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>179</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1859</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@OrigClOrdID@',OrigClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Side@',Side) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LeavesQty@',LeavesQty) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_4_3_N');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_4_3_N');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_4_3_N;
    ----------------------------------------------
  --8 Xác nh?n kh?p l?nh thoa thuan 1 firm (8-3-2)
  --v_orderid : S? hi?u l?nh trong flex
  --Side: 8 GD thoa thuan
  --clordid:So hieu lenh cua CTCK
  --OrderID: So hieu lenh moi do HNX tra ve cua lenh thoa thuan
  ----------------------------------------------
 Procedure PRC_8_3_2_P1(v_orderid VARCHAR2,OrderID VARCHAR2 ,LastQty VARCHAR2,LastPx VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  ClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_3_2_P1');
   SELECT  TRIM(order_number)
        INTO  ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>ExecID</key><value>TNG00000093</value></hoSEMessageEntry><hoSEMessageEntry><key>LastQty</key><value>@LastQty@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderID</key><value>@OrderID@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:11:38</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>TNG00000093</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>@ClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>LastPx</key><value>@LastPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:11:38</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>612</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>TNG</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>189</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1739</value></hoSEMessageEntry><hoSEMessageEntry><key>SecondaryClOrdID</key><value>TNG00000093</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@ClOrdID@',ClOrdID) into xmlTemp from dual;
 select   REPLACE(xmlTemp,'@OrderID@',OrderID) into xmlTemp from dual;
   select   REPLACE(xmlTemp,'@LastQty@',LastQty) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastPx@',LastPx) into xmlTemp from dual;
  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_3_2_P1');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_3_2_P1');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_3_2_P1;

     ----------------------------------------------
  --8 Xác nh?n kh?p l?nh thoa thuan 2 firm (8-3-2)
  --v_orderid : S? hi?u l?nh trong flex
  --Side: 8 GD thoa thuan
  --clordid:So hieu lenh cua CTCK
  --OrderID: So hieu lenh moi do HNX tra ve cua lenh thoa thuan
  ----------------------------------------------
 Procedure PRC_8_3_2_P2(v_orderid VARCHAR2,OrderID VARCHAR2 ,LastQty VARCHAR2,LastPx VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  ClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_3_2_P2');
    SELECT  TRIM(ctci_order)
        INTO  ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>ExecID</key><value>TNG00000093</value></hoSEMessageEntry><hoSEMessageEntry><key>LastQty</key><value>@LastPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderID</key><value>@OrderID@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:11:38</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>@OrigClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>@ClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>LastPx</key><value>@LastPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:11:38</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>612</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>TNG</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>189</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1739</value></hoSEMessageEntry><hoSEMessageEntry><key>SecondaryClOrdID</key><value>TNG00000093</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@ClOrdID@',ClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@OrderID@',OrderID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastQty@',LastQty) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastPx@',LastPx) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@OrigClOrdID@',OrderID) into xmlTemp from dual;
  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_3_2_P2');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_3_2_P2');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_3_2_P2;

  ----------------------------------------------
  --8 Xác nh?n kh?p l?nh thu?ng (8-3-2)
  --v_orderid : S? hi?u l?nh trong flex
  --Side: 1-Buy, 2-Sell
  --OrigClOrdID:
  --<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>ACB00001302</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C106317</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>A</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141117-10:57:35</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>4</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141117-10:57:35</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderQty</key><value>600</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>6</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ACB</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>18000</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>160</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1085</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>
  ----------------------------------------------
 Procedure PRC_8_3_2_N(v_orderid VARCHAR2, Side VARCHAR2,LastQty VARCHAR2,LastPx VARCHAR2,  OrderID VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  OrigClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_3_2_N');
   SELECT  TRIM(order_number)
        INTO  OrigClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>ExecID</key><value>ASA00000004</value></hoSEMessageEntry><hoSEMessageEntry><key>LastQty</key><value>@LastQty@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderID</key><value>@OrderID@</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:00:05</value></hoSEMessageEntry><hoSEMessageEntry><key>OrigClOrdID</key><value>@OrigClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>LastPx</key><value>@LastPx@</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:00:05</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>158</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ASA</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>@Side@</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>183</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1158</value></hoSEMessageEntry><hoSEMessageEntry><key>SecondaryClOrdID</key><value>ASA00000061</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@OrderID@',OrderID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@Side@',Side) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@OrigClOrdID@',OrigClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastQty@',LastQty) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@LastPx@',LastPx) into xmlTemp from dual;
  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_3_2_N');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_3_2_N');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_3_2_N;

  ----------------------------------------------
  --8 Xac nhan lenh thuong vao Core  (8-0-A)
  --v_orderid : S? hi?u l?nh trong flex
  ----------------------------------------------
 Procedure PRC_8_0_A_N(v_orderid VARCHAR2,OrderID VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;
  ClOrdID VARCHAR2(20);
  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_8_0_A_N');
   SELECT  TRIM(ctci_order)
        INTO  ClOrdID
        FROM Ordermap_Ha
        WHERE ORGORDERID= TRIM(v_orderid);
        --<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>ACB00001299</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C106317</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>A</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141117-10:21:03</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002_GW_TEST</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141117-10:21:03</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderQty</key><value>100</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>3</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>ACB</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>16000</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>160</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1082</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>OrderID</key><value>@OrderID@</value></hoSEMessageEntry><hoSEMessageEntry><key>Account</key><value>002C136056</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdStatus</key><value>A</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20141110-02:00:07</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>8</value></hoSEMessageEntry><hoSEMessageEntry><key>OrdType</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>ClOrdID</key><value>@ClOrdID@</value></hoSEMessageEntry><hoSEMessageEntry><key>TransactTime</key><value>20141110-02:00:07</value></hoSEMessageEntry><hoSEMessageEntry><key>ExecType</key><value>0</value></hoSEMessageEntry><hoSEMessageEntry><key>OrderQty</key><value>3000</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>367</value></hoSEMessageEntry><hoSEMessageEntry><key>Symbol</key><value>VGS</value></hoSEMessageEntry><hoSEMessageEntry><key>Side</key><value>2</value></hoSEMessageEntry><hoSEMessageEntry><key>Price</key><value>8000</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>161</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>1360</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@ClOrdID@',ClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@OrigClOrdID@',ClOrdID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@OrderID@',OrderID) into xmlTemp from dual;

  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', '8', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_8_0_A_N');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_8_0_A_N');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_8_0_A_N;
  
    ----------------------------------------------
 Procedure PRC_h(TradingSessionID VARCHAR2,  TradSesStartTime VARCHAR2, TradSesStatus VARCHAR2, TradSesReqID VARCHAR2)
   is
  xmlTemp VARCHAR2(4000);
  v_id NUMBER;

  BEGIN
  plog.setbeginsection (pkgctx, 'PRC_h');
  
  xmlTemp:='<?xml version="1.0" encoding="utf-8"?><ArrayOfHoSEMessageEntry xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><hoSEMessageEntry><key>TradSesMode</key><value>1</value></hoSEMessageEntry><hoSEMessageEntry><key>BeginString</key><value>FIX.4.4</value></hoSEMessageEntry><hoSEMessageEntry><key>SendingTime</key><value>20160129-08:01:25</value></hoSEMessageEntry><hoSEMessageEntry><key>TargetCompID</key><value>002.01GW</value></hoSEMessageEntry><hoSEMessageEntry><key>SenderCompID</key><value>HNX</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgType</key><value>h</value></hoSEMessageEntry><hoSEMessageEntry><key>TradSesStatus</key><value>@TradSesStatus@</value></hoSEMessageEntry><hoSEMessageEntry><key>LastMsgSeqNumProcessed</key><value>1693</value></hoSEMessageEntry><hoSEMessageEntry><key>TradSesStartTime</key><value>@TradSesStartTime@</value></hoSEMessageEntry><hoSEMessageEntry><key>TradingSessionID</key><value>@TradingSessionID@</value></hoSEMessageEntry><hoSEMessageEntry><key>BodyLength</key><value>121</value></hoSEMessageEntry><hoSEMessageEntry><key>TradSesReqID</key><value>@TradSesReqID@</value></hoSEMessageEntry><hoSEMessageEntry><key>MsgSeqNum</key><value>7905</value></hoSEMessageEntry></ArrayOfHoSEMessageEntry>';
  select   REPLACE(xmlTemp,'@TradingSessionID@',TradingSessionID) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@TradSesStartTime@',TradSesStartTime) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@TradSesStatus@',TradSesStatus) into xmlTemp from dual;
  select   REPLACE(xmlTemp,'@TradSesReqID@',TradSesReqID) into xmlTemp from dual;
  SELECT  SEQ1_MSGID.nextval Into v_id From dual;
  insert into msgreceivetemp_ha (ID, MSG_DATE, MSGGROUP, MSGTYPE, MSGXML, PROCESS)
          values  (v_id , getcurrdate, 'CTCI', 'h', xmlTemp, 'N');
  COMMIT;
  plog.setendsection (pkgctx, 'PRC_h');
  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_h');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_h;
  
 END pck_hamsg;

/
