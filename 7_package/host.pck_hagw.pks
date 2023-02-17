SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_hagw IS
--LAY MESSAGE DAY LEN GW.
PROCEDURE PRC_GETORDER(PV_REF IN OUT PKG_REPORT.REF_CURSOR, PV_MsgType VARCHAR2);
PROCEDURE PRC_6(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_AJ(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_D(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_F(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_G(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_K01(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_K02(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_K10(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
PROCEDURE PRC_S(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
--DAY MESSAGE VAO BANG BOC LENH GW
PROCEDURE PRC_PUSHORDER(PV_MSGTYPE VARCHAR2);
PROCEDURE PRC_PUSH_6;
PROCEDURE PRC_PUSH_AJ;
PROCEDURE PRC_PUSH_D;
PROCEDURE PRC_PUSH_F;
PROCEDURE PRC_PUSH_G;
PROCEDURE PRC_PUSH_K01;
PROCEDURE PRC_PUSH_K02;
PROCEDURE PRC_PUSH_K10;
PROCEDURE PRC_PUSH_S;
--XU LY MESSAGE NHAN VE
PROCEDURE PRC_PROCESS;
PROCEDURE PRC_PROCESSMSG;
PROCEDURE PRC_PROCESS_ERR;
PROCEDURE PRC_PROCESS8(PV_MSGXML VARCHAR2, PV_ID VARCHAR2);
END;
/


CREATE OR REPLACE PACKAGE BODY pck_hagw
IS
    pkgctx plog.log_ctx;
    logrow tlogdebug%ROWTYPE;
    C_GW_MARKET CONSTANT CHAR(4) := 'HAGW';
PROCEDURE PRC_GETORDER(PV_REF IN OUT PKG_REPORT.REF_CURSOR, PV_MsgType VARCHAR2) IS
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_GETORDER');
    CASE PV_MsgType
         WHEN 'D'   THEN PRC_D(PV_REF);
         WHEN 'G'   THEN PRC_G(PV_REF);
         WHEN 'F'   THEN PRC_F(PV_REF);
         WHEN '6'   THEN PRC_6(PV_REF);
         WHEN 'S'   THEN PRC_S(PV_REF);
         WHEN 'AJ'  THEN PRC_AJ(PV_REF);
         WHEN 'K01' THEN PRC_K01(PV_REF);
         WHEN 'K02' THEN PRC_K02(PV_REF);
         WHEN 'K10' THEN PRC_K10(PV_REF);
         ELSE NULL;
    END CASE;
    plog.setendsection (pkgctx, 'PRC_GETORDER');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, C_GW_MARKET||'-PRC_GETORDER SQLERRM v_MsgType = '||PV_MsgType);
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_GETORDER');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_GETORDER;

PROCEDURE PRC_6(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_6');
    PRC_PUSH_6();
    --
    OPEN PV_REF FOR
        SELECT ioiid,
               ioirefid,
               ioitranstype,
               symbol,
               side,
               ioiqty,
               price,
               contactno,
               repohaircutratio,
               collateralvalue,
               msgtype,
               delivertocompid,
               delivertosubid,
               SenderSubID
        FROM ha_6 WHERE status = 'N';

    UPDATE ha_6 SET status = 'Y', date_time = SYSDATE WHERE status = 'N';
    plog.setendsection (pkgctx, 'PRC_6');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_6');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_6;

PROCEDURE PRC_AJ(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_AJ');
    PRC_PUSH_AJ();
    --
    OPEN PV_REF FOR
        SELECT msgtype,
               quoterespid,
               quoteid,
               quotemsgid,
               quoteresptype,
               quotetype,
               nopartyids,
               memberid "buyPARTYID.0",
               membersource "buyPARTYIDSOURCE.1",
               memberrole "buyPARTYROLE.2",
               traderid "sellPARTYID.0",
               tradersource "sellPARTYIDSOURCE.1",
               traderrole "sellPARTYROLE.2",
               symbol,
               side,
               orderqty,
               account,
               accounttype,
               bidpx,
               offerpx,
               bidsize,
               offersize,
               ordtype,
               tradedate,
               country,
               cashmargin,
               ioiid,
               investcode,
               forninvesttypecode,
               repohaircutratio,
               collateralvalue,
               custodianid,
               openclosecode,
               fornnegoclassfycode,
               delivertocompid,
               delivertosubid,
               SenderSubID
        FROM ha_AJ WHERE status = 'N';

    UPDATE ha_AJ SET status = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
    plog.setendsection (pkgctx, 'PRC_AJ');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_AJ');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_AJ;

--Dat lenh thuong
PROCEDURE PRC_D(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_D');
    PRC_PUSH_D();
    --
    UPDATE ha_d SET status = 'W' WHERE status = 'N';
    OPEN PV_REF FOR
    SELECT
        h.msgtype,
        h.clordid,
        h.account,
        h.accounttype,
        h.handlinst,
        h.maxfloor,
        h.symbol,
        h.side,
        h.cashmargin,
        h.orderqty,
        h.ordtype,
        h.price,
        h.stoppx,
        h.timeinforce,
        h.tradedate,
        h.country,
        h.investcode,
        h.forninvesttypecode,
        h.custodianid,
        h.openclosecode,
        h.delivertocompid,
        h.DeliverToSubID,
        h.SenderSubID
    FROM ha_D h WHERE STATUS = 'W'
    ORDER BY h.ordertime;

    UPDATE ha_D SET STATUS = 'Y',DATE_TIME = SYSDATE WHERE STATUS = 'W';
    plog.setendsection (pkgctx, 'PRC_D');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_D');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_D;

  --Day message lenh huy F len Gw
PROCEDURE PRC_F(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_F');
    PRC_PUSH_F();
    --
    OPEN PV_REF FOR
    SELECT
        Msgtype,
        CLORDID CLORDID,
        ORIGCLORDID ORIGCLORDID,
        Symbol,
        orderid||sendnum BOORDERID,
        handlInst,
        DeliverToCompID,
        DeliverToSubID,
        SenderSubID
    FROM ha_f WHERE STATUS = 'N';

    UPDATE ha_f SET STATUS = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
    plog.setendsection (pkgctx, 'PRC_F');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_F');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_F;

--Day message lenh sua G len Gw
PROCEDURE PRC_G(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is
BEGIN
   plog.setbeginsection (pkgctx, 'PRC_G');
   PRC_PUSH_G();
   --
   OPEN PV_REF FOR
   SELECT
      Msgtype,
      CLORDID         ClOrdId,
      ORIGCLORDID     OrigClOrdId,
      handlInst       HandlInst,
      maxFloor        MaxFloor,
      symbol          Symbol,
      side            Side,
      orderqty        OrderQty,
      ordType         OrdType,
      price           Price,
      timeInForce     TimeInForce,
      DeliverToCompID DeliverToCompID,
      DeliverToSubID  DeliverToSubID,
      sendersubid,
      OpenCloseCode
   FROM ha_G WHERE STATUS = 'N';

   UPDATE ha_G SET STATUS = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
   plog.setendsection (pkgctx, 'PRC_G');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_G');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_G;

PROCEDURE PRC_K01(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_K01');
    PRC_PUSH_K01();
    --
    OPEN PV_REF FOR
        SELECT '' A FROM dual WHERE 0 <> 0;

    plog.setendsection (pkgctx, 'PRC_K01');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_K01');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_K01;

PROCEDURE PRC_K02(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_K02');
    PRC_PUSH_K02();
    --
    OPEN PV_REF FOR
        SELECT msgtype,
               quoteid,
               quotemsgid,
               origquotemsgid,
               quotecanceltype,
               nopartyids,
               memberid "buyPARTYID.0",
               membersource "buyPARTYIDSOURCE.1",
               memberrole "buyPARTYROLE.2",
               traderid "sellPARTYID.0",
               tradersource "sellPARTYIDSOURCE.1",
               traderrole "sellPARTYROLE.2",
               symbol,
               ioiid,
               delivertocompid,
               delivertosubid,
               SenderSubID
        FROM ha_K02 WHERE status = 'N';

    UPDATE ha_K02 SET status = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
    plog.setendsection (pkgctx, 'PRC_K02');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_K02');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_K02;

PROCEDURE PRC_K10(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
   plog.setbeginsection (pkgctx, 'PRC_K10');
   PRC_PUSH_K10();
   --
   OPEN PV_REF FOR
   SELECT
      Msgtype,
      CLORDID             ClOrdId,
      symbol              Symbol,
      delivertocompid     delivertocompid,
      DeliverToSubID      DeliverToSubID
   FROM ha_K10 WHERE process = 'N';

   UPDATE ha_K10 SET process = 'Y', processtime = SYSDATE WHERE process = 'N';
   plog.setendsection (pkgctx, 'PRC_K10');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_K10');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_K10;

PROCEDURE PRC_S(PV_REF IN OUT PKG_REPORT.REF_CURSOR) IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_S');
    PRC_PUSH_S();
    --
    OPEN PV_REF FOR
        SELECT msgtype,
               quoteid,
               quotemsgid,
               quotetype,
               privatequote,
               nopartyids,
               memberid "buyPARTYID.0",
               membersource "buyPARTYIDSOURCE.1",
               memberrole "buyPARTYROLE.2",
               traderid "sellPARTYID.0",
               tradersource "sellPARTYIDSOURCE.1",
               traderrole "sellPARTYROLE.2",
               symbol,
               side,
               account,
               accounttype,
               cashmargin,
               bidpx,
               offerpx,
               bidsize,
               offersize,
               ordtype,
               tradedate,
               country,
               ioiid,
               investcode,
               forninvesttypecode,
               repohaircutratio,
               collateralvalue,
               custodianid,
               openclosecode,
               fornnegoclassfycode,
               delivertocompid,
               delivertosubid,
               SenderSubID
        FROM ha_S WHERE status = 'N';

    UPDATE ha_S SET status = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
    plog.setendsection (pkgctx, 'PRC_S');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_S');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_S;

--DAY MESSAGE VAO BANG BOC LENH GW
PROCEDURE PRC_PUSHORDER(PV_MSGTYPE VARCHAR2) IS
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PUSHORDER');
    CASE PV_MSGTYPE
         WHEN 'D'   THEN PRC_PUSH_D;
         WHEN 'G'   THEN PRC_PUSH_G;
         WHEN 'F'   THEN PRC_PUSH_F;
         WHEN '6'   THEN PRC_PUSH_6;
         WHEN 'S'   THEN PRC_PUSH_S;
         WHEN 'AJ'  THEN PRC_PUSH_AJ;
         WHEN 'K01' THEN PRC_PUSH_K01;
         WHEN 'K02' THEN PRC_PUSH_K02;
         WHEN 'K10' THEN PRC_PUSH_K10;
         ELSE NULL;
    END CASE;
    plog.setendsection (pkgctx, 'PRC_PUSHORDER');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSHORDER');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSHORDER;

PROCEDURE PRC_PUSH_6
IS
    CURSOR C_6 IS
    SELECT autoid, firm, ioirefid, advside, text, quantity, advtranstype, symbol, price, tradelot,
           delivertocompid,isincode
    FROM (
         SELECT a.autoid, s.sysvalue firm, b.ioiid ioirefid,
                CASE WHEN a.side = 'B' THEN 1 ELSE 2 END advside,
                a.contact text, a.volume quantity,
                a.messagetype advtranstype,
                a.securitysymbol symbol, a.price * se.tradeunit price,
                hb.brd_code delivertocompid,
                se.tradelot,s.isincode
         FROM orderptadv a, orderptadv b, sbsecurities s, securities_info se, ordersys s,
              ho_sec_info h, ho_brd hb
         WHERE a.securitysymbol = se.symbol
           AND s.codeid = se.codeid
           AND se.symbol = h.code
           AND h.brd_code = hb.brd_code
           AND s.tradeplace IN ('002','005')
           AND a.deleted <> 'Y' AND a.issend = 'N' AND a.isactive = 'Y'
           AND a.refid = b.autoid(+)
           AND s.sysname = 'FIRM'
           AND a.status = 'N'
           AND hb.tradsesstatus <> 'AW8'
           AND (
                  ((hb.board_t6 = 'AB1' OR hb.board_t4 = 'AB1') AND a.volume <= se.tradelot)
               OR ((hb.board_t3 = 'AB1' OR hb.board_t1 = 'AB1') AND a.volume > se.tradelot)
               )
    );
    -- Variable
    v_ioiid           VARCHAR2(100);
    v_ioiidformat     VARCHAR2(100);
    l_checkIOIID      VARCHAR2(100);
    l_delivertosubid  VARCHAR2(10);
    l_isPostSession   VARCHAR2(10);
    v_SenderSubID     varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_PUSH_6');
    v_ioiidformat := to_char(getcurrdate, 'MMDDRRRR') || '$SEQ$XX$FIRM$';
    SELECT varvalue INTO l_isPostSession FROM sysvar WHERE varname = 'OPEN_POST_SESSION' AND grname = 'SYSTEM';
    BEGIN
       SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCDHNX';
    EXCEPTION
      WHEN OTHERS THEN 
       v_SenderSubID:='000';
    END;
    
    FOR I IN C_6
    LOOP
      BEGIN
        SAVEPOINT sp;
        v_ioiid := REPLACE(v_ioiidformat, '$FIRM$', i.firm);
        v_ioiid := REPLACE(v_ioiid, '$SEQ$', lpad(MOD(i.autoid,10000),4,'0'));
        l_delivertosubid := pck_gw_common.fnc_GetBoardId(i.delivertocompid, i.quantity, i.tradelot, 'P', 'N', l_isPostSession,'');

        INSERT INTO ha_6(msgtype, ioiid, ioirefid, ioitranstype, symbol, side, ioiqty, price, contactno, status, delivertocompid, delivertosubid,SenderSubID)
        VALUES('6', v_ioiid, i.ioirefid, i.advtranstype, i.isincode, i.advside, i.quantity, i.price, i.text, 'N', i.delivertocompid, l_delivertosubid,v_SenderSubID);

        UPDATE orderptadv SET ioiid = v_ioiid, issend = 'Y', boardid = l_delivertosubid WHERE autoid = i.autoid AND issend = 'N' AND isactive = 'Y'
        RETURNING ioiid INTO l_checkIOIID;

        IF l_checkIOIID IS NULL THEN
          plog.error(pkgctx, 'Trang Thai Lenh Quang Cao Ko Hop Le autoid=' || i.autoid);
          ROLLBACK TO sp;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM ||  '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO sp;
      END;
    END LOOP;
    plog.setendsection (pkgctx, 'PRC_PUSH_6');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_6');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_6;

PROCEDURE PRC_PUSH_AJ
IS
    CURSOR C_AJ IS
      SELECT od.resptype, od.orderid, od.confirmnumber, od.quotemsgid, od.custodycd account,
             sb.symbol, sif.tradelot,
             decode(od.bors, 'S', od.firm, od.sellercontrafirm) memberid,
             decode(od.bors, 'S', od.buyertradeid, od.sellertradeid) traderid,
             decode(od.bors, 'B', '1', '2') side,
             decode(substr(od.custodycd,4,1), 'P', '3', '1') accounttype,
             decode(od.bors, 'B', od.quoteprice, '') bidpx,
             decode(od.bors, 'S', od.quoteprice, '') offerpx,
             decode(od.bors, 'B', od.orderqtty, '') bidsize,
             decode(od.bors, 'S', od.orderqtty, '') offersize,
             decode(od.advidref, '0', '', od.advidref) ioiid,
             decode(substr(od.custodycd,4,1), 'F', '10', '00') forninvesttypecode,
             '8000' investcode, '0' fornnegoclassfycode,
             hb.brd_code delivertocompid, od.boardid delivertosubid,sb.isincode
      FROM (
          SELECT '1' resptype, c.orderid, c.codeid, pt.confirmnumber, pt.quotemsgid,
                 pt.firm, pt.sellercontrafirm, pt.buyertradeid, pt.sellertradeid,
                 a.bors, a.custodycd, c.quoteprice, c.orderqtty, pt.advidref, pt.boardid
          FROM ood a, odmast c, orderptack pt
          WHERE a.orgorderid = c.orderid
            AND c.confirm_no = pt.confirmnumber
            AND a.bors IN ('S', 'B') and a.oodstatus = 'N'
            AND c.orstatus IN ('8')
            AND c.deltd <> 'Y'
            AND c.matchtype = 'P'
            AND pt.status = 'A' AND pt.issend = 'N'
      ) od, sbsecurities sb, securities_info sif, ho_sec_info h, ho_brd hb
      WHERE od.codeid = sb.codeid AND sb.codeid = sif.codeid
        AND sb.symbol = h.code
        AND h.brd_code = hb.brd_code
        AND sb.tradeplace IN ('002','005')
        AND hb.tradsesstatus <> 'AW8' -- Khong Day Trong Phien Nghi Trua
        AND (
                ((hb.board_t1 = 'AB1' OR hb.board_t4 = 'AB1') AND od.orderqtty <= sif.tradelot)
             OR ((hb.board_t3 = 'AB1' OR hb.board_t6 = 'AB1') AND od.orderqtty > sif.tradelot)
             )
        AND od.quoteprice BETWEEN sif.floorprice AND sif.ceilingprice;

    CURSOR C_AJ_REJECT IS
      SELECT od.resptype, od.confirmnumber, od.quotemsgid, sb.symbol, sif.tradelot,
             decode(od.bors, 'S', od.firm, od.sellercontrafirm) memberid,
             decode(od.bors, 'S', od.buyertradeid, od.sellertradeid) traderid,
             decode(od.bors, 'B', '1', '2') side,
             decode(od.bors, 'B', od.quoteprice, '') bidpx,
             decode(od.bors, 'S', od.quoteprice, '') offerpx,
             decode(od.bors, 'B', od.orderqtty, '') bidsize,
             decode(od.bors, 'S', od.orderqtty, '') offersize,
             od.advidref ioiid,
             hb.brd_code delivertocompid, od.boardid delivertosubid,sb.isincode
      FROM (
          SELECT '2' resptype, pt.securitysymbol, pt.confirmnumber, pt.quotemsgid,
                 pt.firm, pt.sellercontrafirm, pt.buyertradeid, pt.sellertradeid,
                 pt.side bors, pt.volume orderqtty, pt.price quoteprice, pt.advidref, pt.boardid
          FROM orderptack pt
          WHERE pt.status = 'B' AND pt.issend = 'N'
      ) od, sbsecurities sb, securities_info sif, ho_sec_info h, ho_brd hb
      WHERE od.securitysymbol = sb.symbol AND sb.codeid = sif.codeid
        AND sb.symbol = h.code
        AND h.brd_code = hb.brd_code
        AND sb.tradeplace IN ('002','005')
        AND hb.tradsesstatus <> 'AW8' -- Khong Day Trong Phien Nghi Trua
        AND (
                (od.boardid = 'T1' AND hb.Board_T1 = 'AB1')
             OR (od.boardid = 'T3' AND hb.Board_T3 = 'AB1')
             OR (od.boardid = 'T4' AND hb.Board_T4 = 'AB1')
             OR (od.boardid = 'T6' AND hb.Board_T6 = 'AB1')
             );
    -- Variable
    v_quoterespid      VARCHAR2(20);
    v_tradedate       VARCHAR2(10);
    v_currdate        DATE;
    l_controlCode     VARCHAR2(100);
    l_delivertosubid  VARCHAR2(10);
    l_isPostSession   VARCHAR2(10);
    v_SenderSubID     varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_PUSH_AJ');
    v_currdate := getcurrdate;
    v_tradedate := to_char(v_currdate, 'RRRRMMDD');
    SELECT varvalue INTO l_isPostSession FROM sysvar WHERE varname = 'OPEN_POST_SESSION' AND grname = 'SYSTEM';
    BEGIN
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCDHNX';
    EXCEPTION
      WHEN OTHERS THEN 
        v_SenderSubID:='000';
    END;
    
    FOR I IN C_AJ
    LOOP
      BEGIN
        SAVEPOINT sp#2;
        IF i.delivertosubid IS NOT NULL THEN
          l_delivertosubid := i.delivertosubid;
        ELSE
          l_delivertosubid := pck_gw_common.fnc_GetBoardId(i.delivertocompid, NVL(i.bidsize, i.offersize), i.tradelot, 'T', 'N', l_isPostSession,'');
        END IF;
        l_controlCode := pck_gw_common.fn_getHOSession (i.symbol, l_delivertosubid);

        v_quoterespid := seq_ordermap.nextval;
        INSERT INTO ha_aj(quoterespid, quoteid, quotemsgid, quoteresptype, memberid, traderid, symbol, side,
                    account, accounttype, bidpx, offerpx, bidsize, offersize, tradedate, ioiid, investcode,
                    forninvesttypecode, fornnegoclassfycode, delivertocompid, delivertosubid, SenderSubID)
        VALUES(v_quoterespid, i.confirmnumber, v_quoterespid, i.resptype, i.memberid, i.traderid, i.isincode, i.side,
               i.account, i.accounttype, i.bidpx, i.offerpx, i.bidsize, i.offersize, v_tradedate, i.ioiid, i.investcode,
               i.forninvesttypecode, i.fornnegoclassfycode, i.delivertocompid, l_delivertosubid,v_SenderSubID);
        --1.1 DAY VAO ORDERMAP.
        INSERT INTO ordermap(ctci_order, orgorderid, order_number, msgtype) VALUES (v_quoterespid, i.orderid, i.confirmnumber, 'AJ');
        --1.2 CAP NHAT PHIEN BOC LENH
        --UPDATE odmast SET hosesession = l_controlcode WHERE orderid = i.orderid;
        --1.3 CAP NHAT OOD.
        UPDATE ood SET oodstatus = 'B' WHERE orgorderid = i.orderid;
        UPDATE odmast SET hosesession = l_controlCode, boardId = l_delivertosubid WHERE orderid = i.orderid;
        --1.4 DAY LENH VAO ODQUEUE
        INSERT INTO odqueue SELECT * FROM ood WHERE orgorderid = i.orderid;
        --1.5 CAP NHAT TRANG THAI DA GUI
        UPDATE orderptack SET issend = 'Y', boardId = l_delivertosubid WHERE confirmnumber = i.confirmnumber;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, 'Exception On Orderid='|| i.orderid || ' ' || SQLERRM || '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO SAVEPOINT sp#2;
      END;
    END LOOP;

    FOR I IN C_AJ_REJECT
    LOOP
      BEGIN
        SAVEPOINT sp#2;
        l_controlCode := pck_gw_common.fn_getHOSession (i.symbol, i.delivertosubid);

        v_quoterespid := seq_ordermap.nextval;
        INSERT INTO ha_aj(quoterespid, quoteid, quotemsgid, quoteresptype, memberid, traderid, symbol, side,
                    bidpx, offerpx, bidsize, offersize, tradedate, ioiid, delivertocompid, delivertosubid, SenderSubID)
        VALUES(v_quoterespid, i.confirmnumber, i.quotemsgid, i.resptype, i.memberid, i.traderid, i.isincode, i.side,
               i.bidpx, i.offerpx, i.bidsize, i.offersize, v_tradedate, i.ioiid, i.delivertocompid, i.delivertosubid,v_SenderSubID);
        --1.1 DAY VAO ORDERMAP.
        INSERT INTO ordermap(ctci_order, orgorderid, order_number, msgtype) VALUES (v_quoterespid, '', i.confirmnumber, 'AJ');
        --1.5 CAP NHAT TRANG THAI DA GUI
        UPDATE orderptack SET issend = 'Y' WHERE confirmnumber = i.confirmnumber;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO SAVEPOINT sp#2;
      END;
    END LOOP;
    plog.setendsection (pkgctx, 'PRC_PUSH_AJ');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_AJ');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_AJ;

--Dat lenh thuong
PROCEDURE PRC_PUSH_D
IS
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_Order_Number varchar2(10);
    v_tradeDate   VARCHAR2(10) := TO_CHAR(getcurrdate,'YYYYMMDD');
    v_SenderSubID varchar2(10);
    CURSOR C_D IS
    SELECT ho.orderid, 'New Single Order' Text,CUSTODYCD Account,
           CASE WHEN  SUBSTR(CUSTODYCD,4,1) = 'P' THEN '3' --House
                ELSE  '1' --Customer
           END AccountType,
           QUOTEPRICE Price,ORDERQTTY OrderQty,SYMBOL Symbol,
           decode(BORS,'B','1','S','2','5') Side, -- 5 = Sell short (cache)
           CASE WHEN priceType IN ('LO','PLO')                         THEN '2' --limit
                WHEN priceType IN ('ATC','ATO','MTL','MAK','MOK') THEN '1' --market
                WHEN priceType IN ('SO>','SO<')                  THEN '3' --stop
                WHEN priceType IN ('SBO','OBO')                  THEN '4' --Stop limit
                WHEN priceType IN ('BO')                         THEN 'X' --Sameside best
                WHEN priceType IN ('')                           THEN 'Y' --Contraryside best
            END OrdType,
            CASE WHEN priceType IN ('LO','PLO')                        THEN '0' --day
                 WHEN priceType IN ('ATO')                       THEN '2' --At the Opening (OPG)
                 WHEN priceType IN ('ATC')                       THEN '7' --At the Close
                 WHEN priceType IN ('MAK')                       THEN '3' --Fill and Kill
                 WHEN priceType IN ('MOK')                       THEN '4' --Fill or Kill
                 WHEN priceType IN ('MTL')                       THEN '9' --Market to Limit
                 WHEN priceType IN ('')                          THEN '1' --Good Till Cancel (GTC)
                 ELSE '0'
            END TimeInForce,
            CASE WHEN SUBSTR(CUSTODYCD,4,1) = 'F' THEN '10' ELSE '00' END forninvesttypecode,
            CODEID,BORS,
            LimitPrice StopPx,
            Sendnum, DeliverToCompID, tradelot, isincode,
            country,
            isbuyin,
            priceType
    FROM HO_SEND_ORDER ho
    WHERE FNC_CHECK_ROOM(SYMBOL,ORDERQTTY,CUSTODYCD,BORS)<>'0' AND ho.tradeplace IN ('002','005')
        ;
    Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2, v_controlcode VARCHAR2, v_strTRADEBUYSELLPT varchar2 ) is
                       SELECT ORGORDERID FROM ood o, odmast od
                       WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                             And o.bors <> v_BorS
                             And od.remainqtty >0
                             and od.deltd<>'Y'
                             AND od.EXECTYPE in ('NB','NS','MS')
                             And o.oodstatus in ('B','S')
                             AND NVL(od.hosesession,'N') = v_controlcode
                             and (v_strTRADEBUYSELLPT='N'
                                  or (v_strTRADEBUYSELLPT='Y' and od.matchtype <>'P'));
   Cursor C_Send_Size is SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSESENDSIZE';
   v_Send_Size  Number;
   v_Count_Order varchar2(10);
   l_controlcode varchar2(10);
   l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung
   l_DeliverToSubID VARCHAR2(10);

  BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PUSH_D');
    BEGIN
      SELECT VARVALUE INTO v_strSysCheckBuySell FROM sysvar WHERE GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
    EXCEPTION
      WHEN OTHERS THEN
        v_strSysCheckBuySell:='N';
    End;

    BEGIN
      SELECT VARVALUE INTO l_strTRADEBUYSELLPT FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='TRADEBUYSELLPT';
    EXCEPTION
      WHEN OTHERS THEN
        l_strTRADEBUYSELLPT:='N';
    END;
    
    BEGIN
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCDHNX';
    EXCEPTION
      WHEN OTHERS THEN 
        v_SenderSubID:='000';
    END;

    Open C_Send_Size;
    Fetch C_Send_Size Into v_Send_Size;
    If C_Send_Size%notfound Then
      v_Send_Size:=100;
    End if;
    Close C_Send_Size;

    v_Count_Order := 0;

    FOR I IN C_D
    LOOP
        BEGIN
            SAVEPOINT sp#2;
            -- Lay Bang Giao Dich Theo Loai Lenh
            l_DeliverToSubID := pck_gw_common.fnc_GetBoardId(i.Delivertocompid,
                                                             i.orderqty, --Quantity
                                                             i.tradelot, --TradeLot
                                                             'N',        --MatchType
                                                             i.isbuyin,  --BuyIn
                                                             'N', --Is Post Order
                                                             i.pricetype);  

            --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
            --Sysvar ko cho BuySell thi check doi ung.
            v_Check := FALSE;
            l_controlcode := pck_gw_common.fn_getHOSession(i.symbol, l_DeliverToSubID);
            -- Khong Dat Lenh Nguoc Chieu Trong Phien Dinh Ky
            IF v_strSysCheckBuySell ='N' AND l_controlcode IN ('GT1','AA1','BC1','AC2','AQ2') THEN
                 Open c_Check_Doiung(I.bors, I.ACCOUNT,I.CODEID,l_controlcode,l_strTRADEBUYSELLPT);
                 Fetch c_Check_Doiung into v_Temp;
                 If c_Check_Doiung%found then
                   v_Check:=True;
                 End if;
                 Close c_Check_Doiung;
            End if;

            --Kiem tra lenh goc da huy sua:
            IF (Not v_Check)   THEN

              SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
              INSERT INTO ha_d (clordid, account, accounttype, handlinst, maxfloor, symbol, side, cashmargin,
                               orderqty, ordtype, price, stoppx, timeinforce, tradedate, country, investcode,
                               forninvesttypecode, custodianid, openclosecode, text, orderid, status,DeliverToCompID, DeliverToSubID,SenderSubID)
              VALUES (v_Order_Number, i.account, i.accounttype, '1', '', i.isincode, i.side, '1',
                     i.orderqty, i.ordtype, i.price, i.stoppx, i.timeinforce, v_tradeDate, i.country, '1000',
                     i.forninvesttypecode, '', '0', i.text, i.orderid, 'N',i.Delivertocompid,l_DeliverToSubID,v_SenderSubID);
              --XU LY LENH D
                --1.1DAY VAO ORDERMAP.
                INSERT INTO ORDERMAP(ctci_order,orgorderid,Msgtype) VALUES (v_Order_Number,I.orderid,'D');
                --1.2 CAP NHAT OOD.
                UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID = I.orderid;
                UPDATE ODMAST SET hosesession= l_controlcode, boardid = l_DeliverToSubID WHERE ORDERID=I.orderid;
                --1.3 DAY LENH VAO ODQUEUE
                INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
                v_Count_Order := v_Count_Order + 1;
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            plog.error(pkgctx, 'Exception On OrderId=' || i.orderid || SQLERRM || '--' || dbms_utility.format_error_backtrace);
            ROLLBACK TO SAVEPOINT sp#2;
        END;
        Exit WHEN v_Count_Order >= v_Send_Size;
    END LOOP;
    plog.setendsection (pkgctx, 'PRC_PUSH_D');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_D');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_D;

  --Day message lenh huy F len Gw
PROCEDURE PRC_PUSH_F
IS
    v_Order_Number    ha_d.clordid%TYPE;
    v_SenderSubID varchar2(10);
    
    CURSOR C_F IS
    SELECT * FROM SEND_CANCEL_ORDER_TO_HO WHERE tradeplace IN ('002','005');

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PUSH_F');

    FOR I IN C_F
    LOOP
      BEGIN
        SAVEPOINT sp#2;
        SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
        INSERT INTO ha_f (Msgtype,text, clordid, origclordid, orderid, date_time, status,symbol,sendnum,DeliverToCompID, handlInst, DeliverToSubID, SenderSubID)
        VALUES ('F',I.text, v_Order_Number, I.ctci_order, I.orderid, Sysdate, 'N',I.Isincode,i.sendnum, i.DeliverToCompID, '1', i.boardid,v_SenderSubID);

        --XU LY LENH HUY F
        --1.1DAY VAO ORDERMAP.
        INSERT INTO ordermap(ctci_order,orgorderid,msgtype) VALUES (v_Order_Number,I.orderid,'F');
        --1.2 CAP NHAT OOD.
        UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
        --1.3 DAY LENH VAO ODQUEUE
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
        UPDATE odmast SET boardid = i.boardid WHERE orderid = i.orderid;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO SAVEPOINT sp#2;
      END;
    END LOOP;
    plog.setendsection (pkgctx, 'PRC_PUSH_F');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_F');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_F;

--Day message lenh sua G len Gw
PROCEDURE PRC_PUSH_G
IS

    CURSOR C_G IS
        SELECT * FROM send_amend_order_to_ho WHERE tradeplace IN ('002','005');
    v_Order_Number    ha_d.clordid%TYPE;
    v_SenderSubID varchar2(10);
  BEGIN
      plog.setbeginsection (pkgctx, 'PRC_PUSH_G');
      BEGIN
        SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCDHNX';
      EXCEPTION
        WHEN OTHERS THEN 
        v_SenderSubID:='000';
      END;
      --l_DeliverToSubID := 'G1';

      FOR I IN C_G
      LOOP
        BEGIN
          SAVEPOINT sp#2;

          SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
          INSERT INTO ha_g (msgtype, text, clordid, orderId, origclordid, handlinst, maxfloor, symbol,
                           side, orderqty, ordtype, price, timeinforce, date_time, status, DeliverToCompID,DeliverToSubID,SenderSubID,OpenCloseCode)
          VALUES ('G',I.text, v_Order_Number, i.orderId, I.ORIGCLORDID, i.handlInst, i.maxFloor, I.Isincode,
              i.side, I.OrderQty, i.ordType, I.price, i.timeInForce, sysdate, 'N', i.DeliverToCompID,i.boardId,v_SenderSubID,'0'
              );
          --XU LY LENH SUA G
          --1.1DAY VAO ORDERMAP.
          INSERT INTO ORDERMAP(ctci_order, orgorderid, Msgtype) VALUES (v_Order_Number, I.orgOrderId, 'G');
          --1.2 CAP NHAT OOD.
          UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orgOrderId;
          --1.3 DAY LENH VAO ODQUEUE
          INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orgOrderId;
          UPDATE odmast SET boardId = i.boardid WHERE orderid = i.orgorderid;
        EXCEPTION
          WHEN OTHERS THEN
            plog.error(pkgctx, 'Exception On Orderid=' || i.orgorderid || SQLERRM || '--' || dbms_utility.format_error_backtrace);
            ROLLBACK TO SAVEPOINT sp#2;
        END;
      END LOOP;
   plog.setendsection (pkgctx, 'PRC_PUSH_G');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_G');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_G;

PROCEDURE PRC_PUSH_K01
IS
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_PUSH_K01');
    plog.setendsection (pkgctx, 'PRC_PUSH_K01');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_K01');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_K01;

PROCEDURE PRC_PUSH_K02
IS
    CURSOR C_K02 IS
      SELECT '' quotemsgid,od.orderid, od.codeid, od.quoteid, od.origquotemsgid,
             od.memberid, od.traderid, sb.symbol,
             decode(od.advidref, '0', '', od.advidref) ioiid,
             hb.brd_code delivertocompid, decode(hb.brd_code, 'RPO', 'R1', 'T1') delivertosubid,sb.isincode
      FROM (
          -- Thoa thuan 1firm
          SELECT c.orderid, c.codeid, mp.order_number quoteid, mp.ctci_order origquotemsgid,
                 cc.contrafirm memberid, cc.traderid, cc.advidref
          FROM ood a, ood aa, ood aaa, odmast c, odmast cc, odmast ccc, ordersys s, ordermap mp
          WHERE cc.orderid = aa.orgorderid AND cc.matchtype = 'P' AND cc.deltd <> 'Y' AND aa.oodstatus = 'S' AND aa.bors = 'S'
            AND ccc.orderid = aaa.orgorderid AND ccc.matchtype = 'P' AND ccc.deltd <> 'Y' AND aaa.bors = 'B'
            AND nvl(cc.ptdeal, 'xx') = nvl(ccc.ptdeal, 'yy') AND cc.clientid = aaa.custodycd AND aa.qtty = aaa.qtty AND aa.price = aaa.price
            AND c.orderid = a.orgorderid AND c.deltd <> 'Y' AND a.oodstatus = 'N' AND a.bors = 'E'
            AND c.reforderid = cc.orderid
            AND cc.orderid = mp.orgorderid
            AND s.sysname = 'FIRM'
          UNION ALL
          -- Thoa thuan 2firm
          SELECT c.orderid, c.codeid, mp.order_number quoteid, mp.ctci_order origquotemsgid,
                 cc.contrafirm memberid, cc.traderid, cc.advidref
          FROM ood a, ood aa, odmast c, odmast cc, ordersys s, ordermap mp
          WHERE a.orgorderid = c.orderid
            AND cc.orderid = aa.orgorderid
            AND c.reforderid = cc.orderid
            AND cc.orderid = mp.orgorderid
            AND length(TRIM(translate(cc.contrafirm, ' +-.0123456789',' '))) IS NULL
            AND to_number(cc.contrafirm) <> to_number(s.sysvalue)
            AND cc.matchtype = 'P'
            AND s.sysname = 'FIRM'
            AND a.bors IN ('E', 'D')
            AND a.oodstatus = 'N'
            AND aa.oodstatus = 'S'
            AND c.orstatus IN ('7')
            AND c.deltd <> 'Y' AND cc.deltd <> 'Y'
      ) od, sbsecurities sb, ho_sec_info h, ho_brd hb
      WHERE od.codeid = sb.codeid
        AND TRIM(sb.symbol) = TRIM(h.code)
        AND h.stock_type = hb.brd_map_code
        AND sb.tradeplace IN ('002','005')
      UNION ALL
      SELECT k.quotemsgid, '' orderid, '' codeid, '' quoteid, to_number(k.origquotemsgid) origquotemsgid,
             '' memberid, '' traderid, k.symbol,'' ioiid,
             k.delivertocompid, k.delivertosubid,k.isincode
      FROM ho_market k
      WHERE k.delivertocompid IN ('STX','UPX','BDX')
      AND status = 'C';
    -- Variable
    v_quotemsgid      VARCHAR2(20);
    v_SenderSubID     varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_PUSH_K02');
    FOR I IN C_K02
    LOOP
      BEGIN
        SAVEPOINT sp;
        -- ...
        v_quotemsgid := seq_ordermap.nextval;
        BEGIN
          SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCDHNX';
        EXCEPTION
          WHEN OTHERS THEN 
            v_SenderSubID:='000';
        END;

        INSERT INTO ha_K02(quoteid, quotemsgid, origquotemsgid, memberid, traderid, symbol, ioiid, delivertocompid, delivertosubid, SenderSubID)
        VALUES(i.quoteid, v_quotemsgid, i.origquotemsgid, i.memberid, i.traderid, i.isincode, i.ioiid, i.delivertocompid, i.delivertosubid,v_SenderSubID);
        --XU LY LENH THOA THUAN
        --1.1 DAY VAO ORDERMAP.
        INSERT INTO ordermap(ctci_order, orgorderid, order_number, msgtype) VALUES (v_quotemsgid, i.orderid, i.quoteid, 'K02');
        --1.2 CAP NHAT PHIEN BOC LENH
        --UPDATE odmast SET hosesession = l_controlcode WHERE orderid = i.orderid;
        --1.3 CAP NHAT OOD.
        UPDATE ood SET oodstatus = 'B' WHERE orgorderid = i.orderid;
        --1.4 DAY LENH VAO ODQUEUE
        INSERT INTO odqueue SELECT * FROM ood WHERE orgorderid = i.orderid;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO sp;
      END;
    END LOOP;
    plog.setendsection (pkgctx, 'PRC_PUSH_K02');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_K02');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_K02;

PROCEDURE PRC_PUSH_K10
IS
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PUSH_K10');
    plog.setendsection (pkgctx, 'PRC_PUSH_K10');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_K10');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_K10;

PROCEDURE PRC_PUSH_S
IS
    CURSOR C_S IS
      SELECT od.orderid, od.firm, od.memberid, od.traderid, sb.symbol, od.custodycd account,
             decode(od.bors, 'B', '1', '2') side,
             decode(substr(od.custodycd,4,1), 'P', '3', '1') accounttype,
             decode(od.bors, 'B', od.quoteprice, '') bidpx,
             decode(od.bors, 'S', od.quoteprice, '') offerpx,
             decode(od.bors, 'B', od.orderqtty, '') bidsize,
             decode(od.bors, 'S', od.orderqtty, '') offersize,
             decode(od.advidref, '0', '', od.advidref) ioiid,
             decode(substr(od.custodycd,4,1), 'F', '10', '00') forninvesttypecode,
             CASE WHEN substr(od.custodycd,4,1) = 'P' THEN '1000'
                  WHEN cf.custtype = 'I' THEN '8000'
                  ELSE '7100'
             END investcode, '0' fornnegoclassfycode,
             hb.brd_code delivertocompid, decode(hb.brd_code, 'RPO', 'R1', 'T1') delivertosubid,
             sif.tradelot, sb.isincode
      FROM (
          -- Thoa thuan 1firm
          SELECT c.orderid, c.codeid, s.sysvalue firm, s.sysvalue memberid, c.traderid, a.bors,
                 a.custodycd, c.quoteprice, c.orderqtty, c.advidref
          FROM ood a, ood aa, odmast c, odmast cc, ordersys s
          WHERE a.orgorderid = c.orderid AND c.matchtype = 'P' AND c.deltd <> 'Y' AND a.oodstatus = 'N' AND c.orstatus IN ('8') AND a.bors = 'S'
            AND cc.orderid = aa.orgorderid AND cc.matchtype = 'P' AND cc.deltd <> 'Y' AND aa.oodstatus = 'N' AND cc.orstatus IN ('8') AND aa.bors = 'B'
            AND nvl(c.ptdeal, 'xx') = nvl(cc.ptdeal, 'yy') AND c.clientid = aa.custodycd AND a.qtty = aa.qtty AND a.price = aa.price
            AND s.sysname = 'FIRM'
          UNION ALL
          -- thoa thuan 2firm
          SELECT c.orderid, c.codeid, s.sysvalue firm, c.contrafirm memberid, c.traderid, a.bors,
                 a.custodycd, c.quoteprice, c.orderqtty, c.advidref
          FROM ood a, odmast c, ordersys s
          WHERE a.orgorderid = c.orderid
            AND length(TRIM(translate(c.contrafirm, ' +-.0123456789',' '))) IS NULL
            AND to_number(c.contrafirm) <> to_number(s.sysvalue)
            AND c.orstatus IN ('8')
            AND a.bors IN ('S', 'B')
            AND a.oodstatus = 'N'
            AND c.deltd <> 'Y'
            AND c.matchtype = 'P'
            AND s.sysname = 'FIRM'
            AND NOT EXISTS (SELECT 1 FROM orderptack WHERE confirmnumber = c.confirm_no)
      ) od, cfmast cf, sbsecurities sb, securities_info sif, ho_sec_info h, ho_brd hb
      WHERE od.custodycd = cf.custodycd
        AND od.codeid = sb.codeid AND sb.codeid = sif.codeid
        AND TRIM(sb.symbol) = TRIM(h.code)
        AND h.stock_type = hb.brd_map_code
        AND sb.tradeplace IN ('002','005')
        AND od.quoteprice BETWEEN sif.floorprice AND sif.ceilingprice;
    -- Variable
    v_quoteid         VARCHAR2(100);
    v_quotemsgid      VARCHAR2(20);
    v_tradedate       VARCHAR2(10);
    v_quoteidformat   VARCHAR2(100);
    v_currdate        DATE;
    v_firm            VARCHAR2(10);
    l_boardId         VARCHAR2(10);
    l_isPostSession   VARCHAR2(10);
    v_SenderSubID     varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_PUSH_S');
    v_currdate := getcurrdate;
    v_tradedate := to_char(v_currdate, 'RRRRMMDD');
    v_quoteidformat := '$FIRM$ $SEQ$/' || to_char(v_currdate, 'MMDDRRRR');
    SELECT sysvalue INTO v_firm from ordersys WHERE sysname ='FIRM';
    SELECT varvalue INTO l_isPostSession FROM sysvar WHERE varname = 'OPEN_POST_SESSION' AND grname = 'SYSTEM';
    BEGIN
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCDHNX';
    EXCEPTION
      WHEN OTHERS THEN 
      v_SenderSubID:='000';
    END;
    
    FOR I IN C_S
    LOOP
      BEGIN
        SAVEPOINT sp;
        -- Check doi ung
        -- ...
        v_quotemsgid := seq_ordermap.nextval;
        v_quoteid := REPLACE(v_quoteidformat, '$FIRM$', v_firm);
        v_quoteid := REPLACE(v_quoteid, '$SEQ$', lpad(seq_quoteid.nextval,4,'0'));
        l_boardId := pck_gw_common.fnc_GetBoardId(i.Delivertocompid,
                                                  nvl(i.bidsize, i.offersize),
                                                  i.tradelot,
                                                  'P',
                                                  'N',
                                                  l_isPostSession,
                                                  '' );
        INSERT INTO ho_S(quoteid, quotemsgid, memberid, traderid, symbol, side, account, accounttype,
                    bidpx, offerpx, bidsize, offersize, tradedate, ioiid, investcode,
                    forninvesttypecode, fornnegoclassfycode, delivertocompid, delivertosubid, SenderSubID)
        VALUES(v_quoteid, v_quotemsgid, i.memberid, i.traderid, i.isincode, i.side, i.account, i.accounttype,
          i.bidpx, i.offerpx, i.bidsize, i.offersize, v_tradedate, i.ioiid, i.investcode,
          i.forninvesttypecode, i.fornnegoclassfycode, i.delivertocompid, l_boardId,v_SenderSubID);
        --XU LY LENH THOA THUAN
        --1.1 DAY VAO ORDERMAP.
        INSERT INTO ordermap(ctci_order, orgorderid, order_number, msgtype) VALUES (v_quotemsgid, i.orderid, v_quoteid, 'S');
        --1.2 CAP NHAT PHIEN BOC LENH
        --UPDATE odmast SET hosesession = l_controlcode WHERE orderid = i.orderid;
        --1.3 CAP NHAT OOD.
        UPDATE ood SET oodstatus = 'B' WHERE orgorderid = i.orderid;
        --1.4 DAY LENH VAO ODQUEUE
        INSERT INTO odqueue SELECT * FROM ood WHERE orgorderid = i.orderid;
        UPDATE odmast SET boardid = l_boardId WHERE orderid = i.orderid;
      EXCEPTION
        WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          ROLLBACK TO sp;
      END;
    END LOOP;
    plog.setendsection (pkgctx, 'PRC_PUSH_S');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSH_S');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSH_S;

--XU LY MESSAGE NHAN VE
Procedure PRC_PROCESS IS
    CURSOR C_MSG_RECEIVE IS
      SELECT MSGTYPE,ID, REPLACE(MSGXML,'&',' ') MSGXML, PROCESS FROM (
          SELECT MSGTYPE,ID, MSGXML, PROCESS
          FROM MSGRECEIVETEMP_HA
          WHERE PROCESS = 'N' ORDER BY ID
       )
       WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME = 'HARECEIVESIZE');

    V_MSG_RECEIVE C_MSG_RECEIVE%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS');
    OPEN C_MSG_RECEIVE;
    LOOP
        FETCH C_MSG_RECEIVE INTO V_MSG_RECEIVE;
        EXIT WHEN C_MSG_RECEIVE%NOTFOUND;
        BEGIN
            CASE V_MSG_RECEIVE.MSGTYPE
               WHEN '8'   THEN PRC_PROCESS8(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
               WHEN '3'   THEN PCK_GW_COMMON.PRC_PROCESS3(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN '9'   THEN PCK_GW_COMMON.PRC_PROCESS9(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'AI'  THEN PCK_GW_COMMON.PRC_PROCESSAI(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'AJ'  THEN PCK_GW_COMMON.PRC_PROCESSAJ(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'j'   THEN PCK_GW_COMMON.PRC_PROCESSj(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K03' THEN PCK_GW_COMMON.PRC_PROCESSK03(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K04' THEN PCK_GW_COMMON.PRC_PROCESSK04(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K05' THEN PCK_GW_COMMON.PRC_PROCESSK05(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K06' THEN PCK_GW_COMMON.PRC_PROCESSK06(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K07' THEN PCK_GW_COMMON.PRC_PROCESSK07(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K08' THEN PCK_GW_COMMON.PRC_PROCESSK08(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K09' THEN PCK_GW_COMMON.PRC_PROCESSK09(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K11' THEN PCK_GW_COMMON.PRC_PROCESSK11(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K15' THEN PCK_GW_COMMON.PRC_PROCESSK15(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K16' THEN PCK_GW_COMMON.PRC_PROCESSK16(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'K17' THEN PCK_GW_COMMON.PRC_PROCESSK17(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               WHEN 'S'   THEN PCK_GW_COMMON.PRC_PROCESSS(V_MSG_RECEIVE.MSGXML,C_GW_MARKET);
               ELSE NULL;
            END CASE;

            UPDATE MSGRECEIVETEMP_HA SET PROCESS = 'Y', PROCESSTIME=SYSDATE, PROCESSNUM = PROCESSNUM + 1
            WHERE ID =V_MSG_RECEIVE.ID;
            COMMIT;
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, C_GW_MARKET||'.PRC_PROCESS'||'exeption in process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            ROLLBACK;
            UPDATE MSGRECEIVETEMP_HA SET PROCESS = 'E', PROCESSTIME=SYSDATE, PROCESSNUM = PROCESSNUM + 1
            WHERE ID = V_MSG_RECEIVE.ID;
            COMMIT;
        END;
    END LOOP;
    CLOSE C_MSG_RECEIVE;
    plog.setendsection (pkgctx, 'PRC_PROCESS');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESS;

PROCEDURE PRC_PROCESSMSG
IS
    CURSOR c_Exec_8 IS
    SELECT * FROM
    (    SELECT * FROM Exec_8_Ha WHERE Process = 'N'
         ORDER BY MsgSeqNum
    )
    WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME = 'HARECEIVESIZE');

    v_err          VARCHAR2(1000);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSMSG');
    FOR i IN c_Exec_8
    LOOP
       INSERT INTO EXEC_8_queue(id,logtime) VALUES (I.id, SYSDATE);
       BEGIN
          PCK_GW_COMMON.PRC_PROCESS_ORDER(
                 PV_MARKET => C_GW_MARKET,
                 PV_CLORDID => I.CLORDID,
                 PV_ORGCLORDID => I.ORIGCLORDID,
                 PV_EXECTYPE => I.EXECTYPE,
                 PV_ORDSTATUS => I.ORDSTATUS,
                 PV_SIDE => i.side,
                 PV_OrderQty => i.orderqty,
                 PV_LASTQTY => I.LASTQTY,
                 PV_LASTPX => I.LASTPX,
                 PV_LEAVESQTY => I.LEAVESQTY,
                 PV_CUMQTY => I.CUMQTY,
                 PV_CONFIRM_NUMBER => I.ORDERID,
                 PV_EXECID => i.execid,
                 PV_QUOTEID => I.QUOTEID,
                 PV_ORDREJREASON => I.ORDREJREASON,
                 PV_OnBehalfOfCompID => i.OnBehalfOfCompID,
                 PV_OnBehalfOfSubID => i.OnBehalfOfSubID,
                 PV_ERR => V_ERR
          );

          UPDATE Exec_8_ha SET Process = 'Y', processnum = processnum + 1, processtime = SYSDATE WHERE id = i.ID;
          COMMIT;
       EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          plog.error(pkgctx,C_GW_MARKET||'.PRC_PROCESSMSG '||'exeption: '|| v_err);
          ROLLBACK;
          UPDATE Exec_8_ha SET Process = 'E', processnum = processnum + 1, processtime = SYSDATE WHERE id = i.ID;
          COMMIT;
       END;
    END LOOP;

    plog.setendsection (pkgctx, 'PRC_PROCESSMSG');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESSMSG');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END;

PROCEDURE PRC_PROCESS_ERR IS
    CURSOR c_Exec_8 IS
    SELECT id FROM Exec_8_ha
    WHERE Process = 'Y'
      AND EXECTYPE = '3'
      AND side = '8'
      AND processnum < 5
      AND ORDSTATUS = '2'
      AND ORIGCLORDID IN (SELECT order_number FROM ordermap)
      AND NOT EXISTS (SELECT 1 FROM iod WHERE Exec_8_ha.ORDERID = iod.confirm_no);

    v_IsProcess VARCHAR2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS_ERR');
    BEGIN
       SELECT SYSVALUE INTO v_IsProcess FROM Ordersys_Ha
       WHERE SYSNAME = 'ISPROCESS';
    EXCEPTION WHEN OTHERS THEN
       v_IsProcess := 'N';
    END;

    IF v_IsProcess = 'Y' THEN
       UPDATE msgreceivetemp_ha SET process = 'N' WHERE PROCESS = 'E' AND PROCESSNUM < 5;
       COMMIT;

       DELETE Exec_8_queue e WHERE EXISTS (SELECT id FROM Exec_8 e8 WHERE e8.process= 'E' AND e8.processnum < 5 AND e8.id = e.id);
       UPDATE Exec_8_ha SET process = 'N' WHERE PROCESS = 'E' AND PROCESSNUM < 5;
       COMMIT;

       FOR vc IN c_Exec_8
       LOOP
          DELETE Exec_8_queue e WHERE id = vc.id;
          UPDATE Exec_8_ha SET process = 'N' WHERE id = vc.id;
       END LOOP;
       COMMIT;
    END IF;
    plog.setendsection (pkgctx, 'PRC_PROCESS_ERR');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS_ERR');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESS_ERR;
--Xu ly Message 8
Procedure PRC_PROCESS8(PV_MSGXML VARCHAR2, PV_ID VARCHAR2) IS
    V_TX8         ho_tx.msg_8;
    v_Process     VARCHAR2(1);
    v_err         VARCHAR2(1000);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS8');
    V_TX8 := PCK_GW_COMMON.fn_xml2obj_8(PV_MSGXML);
    -- Lenh vao san
    If V_TX8.ExecType = '0' And V_TX8.OrdStatus = '0' Then
        BEGIN
            PCK_GW_COMMON.PRC_PROCESS_ORDER(
                 PV_MARKET => C_GW_MARKET,
                 PV_CLORDID => V_TX8.ClOrdID,
                 PV_ORGCLORDID => '',
                 PV_EXECTYPE => V_TX8.ExecType,
                 PV_ORDSTATUS => V_TX8.OrdStatus,
                 PV_SIDE => V_TX8.Side,
                 PV_OrderQty => V_TX8.OrderQty,
                 PV_LASTQTY => 0,
                 PV_LASTPX => 0,
                 PV_LEAVESQTY => 0,
                 PV_CUMQTY => 0,
                 PV_CONFIRM_NUMBER => V_TX8.OrderID,
                 PV_EXECID => V_TX8.ExecID,
                 PV_QUOTEID => '',
                 PV_ORDREJREASON => '',
                 PV_OnBehalfOfCompID => V_TX8.OnBehalfOfCompID,
                 PV_OnBehalfOfSubID => V_TX8.OnBehalfOfSubID,
                 PV_ERR => V_ERR
            );
            v_Process := 'Y';
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            plog.error(pkgctx,C_GW_MARKET||'.PRC_PROCESSMSG '||'exeption: '|| v_err);
            plog.setendsection (pkgctx, 'PRC_PROCESS8');
            ROLLBACK;
            RETURN;
        END;
    ELSE
        v_Process := 'N';
    END IF;
    --XU LY MESSAGE 8.
    INSERT INTO Exec_8_Ha(clordid, transacttime, exectype, orderqty, orderid, side,
               symbol, price, ACCOUNT, ordstatus, origclordid,
               lastqty, lastpx, execid, leavesqty,receivetime,id,process,
               OrdType, OrdRejReason,MsgSeqNum,PROCESSTIME,PROCESSNUM,QuoteID,Cumqty)
    VALUES ( V_TX8.ClOrdID , V_TX8.TransactTime , V_TX8.ExecType , V_TX8.OrderQty , V_TX8.OrderID , V_TX8.Side,
          V_TX8.Symbol , V_TX8.Price , V_TX8.Account , V_TX8.OrdStatus ,V_TX8.OrigClOrdID ,
          V_TX8.LastQty , V_TX8.LastPx , V_TX8.ExecID ,V_TX8.LeavesQty ,sysdate,PV_ID,v_Process,
          V_TX8.OrdType, V_TX8.OrdRejReason,V_TX8.MsgSeqNum,DECODE(v_Process,'Y',SYSDATE,NULL),
          DECODE(v_Process,'Y',1,0),V_TX8.QuoteID,v_tx8.CumQty);
    plog.setendsection (pkgctx, 'PRC_PROCESS8');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS8');
    ROLLBACK;
END PRC_PROCESS8;

BEGIN
FOR i IN (SELECT * FROM tlogdebug) LOOP
logrow.loglevel  := i.loglevel;
logrow.log4table := i.log4table;
logrow.log4alert := i.log4alert;
logrow.log4trace := i.log4trace;
END LOOP;

pkgctx := plog.init('pck_hagw',
          plevel => NVL(logrow.loglevel,30),
          plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
          palert => (logrow.log4alert = 'Y'),
          ptrace => (logrow.log4trace = 'Y'));

END;
/
