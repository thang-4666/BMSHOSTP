SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_hogw IS
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
FUNCTION fn_caculate_hose_time
    RETURN VARCHAR2;
Procedure PRC_PROCESSMSG(V_MSGGROUP VARCHAR2);
Procedure PRC_PROCESS2B(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2C(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2E(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2G(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2D(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2I(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2L(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS2F(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS3B(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS3C(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSSC(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2);
Procedure PRC_PROCESSTR(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSGA(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSSU(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSSS(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSTC(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSTS(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2);
Procedure PRC_PROCESSBS(V_MSGXML VARCHAR2);
Procedure PRC_PROCESS3D(V_MSGXML VARCHAR2);
Procedure PRC_PROCESSAA(V_MSGXML VARCHAR2);
FUNCTION fn_xml2obj_2B(p_xmlmsg    VARCHAR2) RETURN tx.msg_2B;
FUNCTION fn_xml2obj_2C(p_xmlmsg    VARCHAR2) RETURN tx.msg_2C;
FUNCTION fn_xml2obj_2E(p_xmlmsg    VARCHAR2) RETURN tx.msg_2E;
FUNCTION fn_xml2obj_2G(p_xmlmsg    VARCHAR2) RETURN tx.msg_2G;
FUNCTION fn_xml2obj_2D(p_xmlmsg    VARCHAR2) RETURN tx.msg_2D;
FUNCTION fn_xml2obj_2I(p_xmlmsg    VARCHAR2) RETURN tx.msg_2I;
FUNCTION fn_xml2obj_2L(p_xmlmsg    VARCHAR2) RETURN tx.msg_2L;
FUNCTION fn_xml2obj_2F(p_xmlmsg    VARCHAR2) RETURN tx.msg_2F;
FUNCTION fn_xml2obj_3B(p_xmlmsg    VARCHAR2) RETURN tx.msg_3B;
FUNCTION fn_xml2obj_3C(p_xmlmsg    VARCHAR2) RETURN tx.msg_3C;
FUNCTION fn_xml2obj_SC(p_xmlmsg    VARCHAR2) RETURN tx.msg_SC;
FUNCTION fn_xml2obj_TR(p_xmlmsg    VARCHAR2) RETURN tx.msg_TR;
FUNCTION fn_xml2obj_GA(p_xmlmsg    VARCHAR2) RETURN tx.msg_GA;
FUNCTION fn_xml2obj_SU(p_xmlmsg    VARCHAR2) RETURN tx.msg_SU;
FUNCTION fn_xml2obj_SS(p_xmlmsg    VARCHAR2) RETURN tx.msg_SS;
FUNCTION fn_xml2obj_TC(p_xmlmsg    VARCHAR2) RETURN tx.msg_TC;
FUNCTION fn_xml2obj_TS(p_xmlmsg    VARCHAR2) RETURN tx.msg_TS;
FUNCTION fn_xml2obj_BS(p_xmlmsg    VARCHAR2) RETURN tx.msg_BS;
FUNCTION fn_xml2obj_3D(p_xmlmsg    VARCHAR2) RETURN tx.msg_3D;
FUNCTION fn_xml2obj_AA(p_xmlmsg    VARCHAR2) RETURN tx.msg_AA;

END;
/


CREATE OR REPLACE PACKAGE BODY pck_hogw
IS
    pkgctx plog.log_ctx;
    logrow tlogdebug%ROWTYPE;
    C_GW_MARKET CONSTANT CHAR(4) := 'HOGW';
    v_CheckProcess Boolean;
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
        FROM ho_6 WHERE status = 'N';

    UPDATE ho_6 SET status = 'Y', date_time = SYSDATE WHERE status = 'N';
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
        FROM ho_AJ WHERE status = 'N';

    UPDATE ho_AJ SET status = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
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
    UPDATE ho_d SET status = 'W' WHERE status = 'N';
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
    FROM ho_D h WHERE STATUS = 'W'
    ORDER BY h.ordertime;

    UPDATE ho_D SET STATUS = 'Y',DATE_TIME = SYSDATE WHERE STATUS = 'W';
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
    FROM ho_f WHERE STATUS = 'N';

    UPDATE ho_f SET STATUS = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
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
      SenderSubID,
      OpenCloseCode
   FROM ho_G WHERE STATUS = 'N';

   UPDATE ho_G SET STATUS = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
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
        FROM ho_K02 WHERE status = 'N';

    UPDATE ho_K02 SET status = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
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
   FROM HO_K10 WHERE process = 'N';

   UPDATE HO_K10 SET process = 'Y', processtime = SYSDATE WHERE process = 'N';
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
        FROM ho_S WHERE status = 'N';

    UPDATE ho_S SET status = 'Y', DATE_TIME = SYSDATE WHERE STATUS = 'N';
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
           AND s.tradeplace IN ('001')
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
       SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
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

        INSERT INTO ho_6(msgtype, ioiid, ioirefid, ioitranstype, symbol, side, ioiqty, price, contactno, status, delivertocompid, delivertosubid,sendersubid)
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
        AND sb.tradeplace IN ('001')
        AND hb.tradsesstatus <> 'AW8' -- Khong Day Trong Phien Nghi Trua
        AND (
                ((hb.board_t6 = 'AB1' OR hb.board_t4 = 'AB1') AND od.orderqtty <= sif.tradelot)
             OR ((hb.board_t3 = 'AB1' OR hb.board_t1 = 'AB1') AND od.orderqtty > sif.tradelot)
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
        AND sb.tradeplace IN ('001')
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
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
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
        INSERT INTO ho_aj(quoterespid, quoteid, quotemsgid, quoteresptype, memberid, traderid, symbol, side,
                    account, accounttype, bidpx, offerpx, bidsize, offersize, tradedate, ioiid, investcode,
                    forninvesttypecode, fornnegoclassfycode, delivertocompid, delivertosubid,sendersubid)
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
        INSERT INTO ho_aj(quoterespid, quoteid, quotemsgid, quoteresptype, memberid, traderid, symbol, side,
                    bidpx, offerpx, bidsize, offersize, tradedate, ioiid, delivertocompid, delivertosubid,sendersubid)
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
           CASE WHEN priceType IN ('LO')                         THEN '2' --limit
                WHEN priceType IN ('ATC','ATO','MTL','MAK','MOK') THEN '1' --market
                WHEN priceType IN ('SO>','SO<')                  THEN '3' --stop
                WHEN priceType IN ('SBO','OBO')                  THEN '4' --Stop limit
                WHEN priceType IN ('BO')                         THEN 'X' --Sameside best
                WHEN priceType IN ('')                           THEN 'Y' --Contraryside best
            END OrdType,
            CASE WHEN priceType IN ('LO')                        THEN '0' --day
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
            isbuyin
    FROM HO_SEND_ORDER ho
    WHERE FNC_CHECK_ROOM(SYMBOL,ORDERQTTY,CUSTODYCD,BORS)<>'0' AND ho.tradeplace = '001'
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
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
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
                                                             '');

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
              INSERT INTO ho_d (clordid, account, accounttype, handlinst, maxfloor, symbol, side, cashmargin,
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
    v_Order_Number    ho_d.clordid%TYPE;
    v_SenderSubID varchar2(10);

    CURSOR C_F IS
    SELECT * FROM SEND_CANCEL_ORDER_TO_HO WHERE tradeplace = '001';

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PUSH_F');
    BEGIN
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
    EXCEPTION
      WHEN OTHERS THEN
        v_SenderSubID:='000';
    END;

    FOR I IN C_F
    LOOP
      BEGIN
        SAVEPOINT sp#2;
        SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;
        INSERT INTO ho_f (Msgtype,text, clordid, origclordid, orderid, date_time, status,symbol,sendnum,DeliverToCompID, handlInst, DeliverToSubID,SenderSubID)
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
        SELECT * FROM send_amend_order_to_ho WHERE tradeplace = '001';
    v_Order_Number    ho_d.clordid%TYPE;
    v_SenderSubID varchar2(10);
  BEGIN
      plog.setbeginsection (pkgctx, 'PRC_PUSH_G');
      BEGIN
        SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
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
          INSERT INTO ho_g (msgtype, text, clordid, orderId, origclordid, handlinst, maxfloor, symbol,
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
        AND sb.tradeplace IN ('001')
      UNION ALL
      SELECT k.quotemsgid, '' orderid, '' codeid, '' quoteid, to_number(k.origquotemsgid) origquotemsgid,
             '' memberid, '' traderid, k.symbol,'' ioiid,
             k.delivertocompid, k.delivertosubid,k.isincode
      FROM ho_market k
      WHERE k.delivertocompid IN ('STO','BDO','RPO')
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
          SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
        EXCEPTION
          WHEN OTHERS THEN
            v_SenderSubID:='000';
        END;

        INSERT INTO ho_K02(quoteid, quotemsgid, origquotemsgid, memberid, traderid, symbol, ioiid, delivertocompid, delivertosubid,SenderSubID)
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
             sif.tradelot,sb.isincode
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
        AND sb.tradeplace IN ('001')
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
    l_controlcode     VARCHAR2(10);
    v_SenderSubID     varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'PRC_PUSH_S');
    v_currdate := getcurrdate;
    v_tradedate := to_char(v_currdate, 'RRRRMMDD');
    v_quoteidformat := '$FIRM$ $SEQ$/' || to_char(v_currdate, 'MMDDRRRR');
    SELECT sysvalue INTO v_firm from ordersys WHERE sysname ='FIRM';
    SELECT varvalue INTO l_isPostSession FROM sysvar WHERE varname = 'OPEN_POST_SESSION' AND grname = 'SYSTEM';
    BEGIN
      SELECT VARVALUE INTO v_SenderSubID FROM sysvar WHERE GRNAME ='SYSTEM' AND VARNAME ='COMPANYCD';
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
                                                  '');
        l_controlcode := pck_gw_common.fn_getHOSession(i.symbol, l_boardId);

        INSERT INTO ho_S(quoteid, quotemsgid, memberid, traderid, symbol, side, account, accounttype,
                    bidpx, offerpx, bidsize, offersize, tradedate, ioiid, investcode,
                    forninvesttypecode, fornnegoclassfycode, delivertocompid, delivertosubid,SenderSubID)
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
        UPDATE odmast SET boardid = l_boardId, hosesession= l_controlcode WHERE orderid = i.orderid;
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
        FROM MSGRECEIVETEMP
        WHERE PROCESS = 'N' ORDER BY ID
        )
        WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME = 'HOSERECEIVESIZE');

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

            UPDATE MSGRECEIVETEMP SET PROCESS = 'Y', PROCESSTIME=SYSDATE, PROCESSNUM = PROCESSNUM + 1
            WHERE ID =V_MSG_RECEIVE.ID;
            COMMIT;
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, C_GW_MARKET||'.PRC_PROCESS'||'exeption in process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            ROLLBACK;
            UPDATE MSGRECEIVETEMP SET PROCESS = 'E', PROCESSTIME=SYSDATE, PROCESSNUM = PROCESSNUM + 1
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
    (    SELECT * FROM Exec_8 WHERE Process = 'N'
         ORDER BY TO_NUMBER(MsgSeqNum)
    )
    WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME = 'HOSERECEIVESIZE');

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

          UPDATE Exec_8 SET Process = 'Y', processnum = processnum + 1, processtime = SYSDATE WHERE id = i.ID;
          COMMIT;
       EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          plog.error(pkgctx,C_GW_MARKET||'.PRC_PROCESSMSG '||'exeption: '|| v_err);
          ROLLBACK;
          UPDATE Exec_8 SET Process = 'E', processnum = processnum + 1, processtime = SYSDATE WHERE id = i.ID;
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
    SELECT id FROM Exec_8
    WHERE Process = 'Y'
      AND EXECTYPE = '3'
      AND side = '8'
      AND processnum < 5
      AND ORDSTATUS = '2'
      AND ORIGCLORDID IN (SELECT order_number FROM ordermap)
      AND NOT EXISTS (SELECT 1 FROM iod WHERE Exec_8.ORDERID = iod.confirm_no);

    v_IsProcess VARCHAR2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS_ERR');
    BEGIN
       SELECT SYSVALUE INTO v_IsProcess FROM Ordersys
       WHERE SYSNAME = 'ISPROCESS';
    EXCEPTION WHEN OTHERS THEN
       v_IsProcess := 'N';
    END;

    IF v_IsProcess = 'Y' THEN
       UPDATE msgreceivetemp SET process = 'N' WHERE PROCESS = 'E' AND PROCESSNUM < 5;
       COMMIT;

       DELETE Exec_8_queue e WHERE EXISTS (SELECT id FROM Exec_8 e8 WHERE e8.process= 'E' AND e8.processnum < 5 AND e8.id = e.id);
       UPDATE Exec_8 SET process = 'N' WHERE PROCESS = 'E' AND PROCESSNUM < 5;
       COMMIT;

       FOR vc IN c_Exec_8
       LOOP
          DELETE Exec_8_queue e WHERE id = vc.id;
          UPDATE Exec_8 SET process = 'N' WHERE id = vc.id;
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
    INSERT INTO Exec_8(clordid, transacttime, exectype, orderqty, orderid, side,
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

FUNCTION fn_caculate_hose_time

RETURN VARCHAR2 as
    l_delta_time  VARCHAR2(10);
    l_timesysdate   VARCHAR2(10);
    l_hosetime      INTEGER;
    l_returntime    VARCHAR2(10);

BEGIN
    SELECT sysvalue INTO l_delta_time FROM ordersys WHERE sysname = 'DELTATIME';
    SELECT TO_CHAR(systimestamp,'HH24MISS') INTO l_timesysdate FROM dual;

    IF l_delta_time = 9999 THEN
        RETURN TO_CHAR(systimestamp,'HH24MISS');
    END IF;

    SELECT l_delta_time
                + (
                    TO_NUMBER(SUBSTR(l_timesysdate,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timesysdate,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timesysdate,5,2))
                    )
           INTO l_hosetime FROM DUAL;

    SELECT TRIM(TO_CHAR(MOD(FLOOR(l_hosetime/3600),24),'09'))
                || TRIM(TO_CHAR(FLOOR(MOD(l_hosetime,3600)/60),'09'))
                || TRIM(TO_CHAR(MOD(MOD(l_hosetime,3600),60),'09'))
           INTO l_returntime FROM DUAL;
  RETURN l_returntime;
EXCEPTION
  WHEN OTHERS THEN
    RETURN TO_CHAR(systimestamp,'HH24MISS');
END fn_caculate_hose_time;

  --XU LY MESSAGE NHAN VE
Procedure PRC_PROCESSMSG(V_MSGGROUP VARCHAR2) is
    CURSOR C_MSG_RECEIVE IS
    Select * from
    (
    SELECT MSGTYPE,ID, REPLACE(MSGXML,'&',' ') MSGXML, PROCESS,MSG_DATE FROM MSGRECEIVETEMP WHERE MSGGROUP =V_MSGGROUP  AND PROCESS ='N' order by ID
    )
    where  ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='HOSERECEIVESIZE');
    V_MSG_RECEIVE C_MSG_RECEIVE%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSMSG');
    OPEN C_MSG_RECEIVE;
    LOOP
        FETCH C_MSG_RECEIVE INTO V_MSG_RECEIVE;
        EXIT WHEN C_MSG_RECEIVE%NOTFOUND;
        -- Gan gia tri xu ly msg thanh cong
        -- TH xu ly loi thi se khong cap nhat PROCESS = 'Y'
        Begin
            INSERT INTO HOMSGQUEUE(ID,LOGTIME) VALUES(V_MSG_RECEIVE.ID,SYSDATE);
            v_CheckProcess := TRUE;
            IF V_MSG_RECEIVE.MSGTYPE ='2B' THEN
              PRC_PROCESS2B(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2C' THEN
              PRC_PROCESS2C(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2E' THEN
              PRC_PROCESS2E(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2G' THEN
              PRC_PROCESS2G(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2D' THEN
              PRC_PROCESS2D(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2I' THEN
              PRC_PROCESS2I(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2L' THEN
              PRC_PROCESS2L(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='2F' THEN
              PRC_PROCESS2F(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3B' THEN
              PRC_PROCESS3B(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3C' THEN
              PRC_PROCESS3C(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='SC' THEN
              PRC_PROCESSSC(V_MSG_RECEIVE.MSGXML,TO_CHAR(V_MSG_RECEIVE.MSG_DATE,'HH24MISS'));
            ELSIF V_MSG_RECEIVE.MSGTYPE ='TR' THEN
              PRC_PROCESSTR(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='GA' THEN
              PRC_PROCESSGA(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='SU' THEN
              PRC_PROCESSSU(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='SS' THEN
              PRC_PROCESSSS(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='TC' THEN
              PRC_PROCESSTC(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='TS' THEN
              PRC_PROCESSTS(V_MSG_RECEIVE.MSGXML,TO_CHAR(V_MSG_RECEIVE.MSG_DATE,'HH24MISS'));
            ELSIF V_MSG_RECEIVE.MSGTYPE ='BS' THEN
              PRC_PROCESSBS(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3D' THEN
              PRC_PROCESS3D(V_MSG_RECEIVE.MSGXML);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='AA' THEN
              PRC_PROCESSAA(V_MSG_RECEIVE.MSGXML);
            END IF;
            -- Chi cap nhat trang thai neu xu ly thanh cong
            IF v_CheckProcess = TRUE THEN
                  UPDATE MSGRECEIVETEMP SET PROCESS ='Y',PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1 WHERE ID =V_MSG_RECEIVE.ID;
            Else
                  UPDATE MSGRECEIVETEMP SET PROCESS ='E',PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1 WHERE ID =V_MSG_RECEIVE.ID;
                  plog.error(pkgctx,'PRC_PROCESSMSG '||'Cant not process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            END IF;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            rollback;
            UPDATE MSGRECEIVETEMP SET PROCESS ='R',PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1 WHERE ID =V_MSG_RECEIVE.ID;
            plog.error(pkgctx,'PRC_PROCESSMSG '||'exeption in process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            commit;
         End;
    END LOOP;
    CLOSE C_MSG_RECEIVE;

plog.setendsection (pkgctx, 'PRC_PROCESSMSG');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESSMSG');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSMSG;

--PROCESS MSG 2b
Procedure PRC_PROCESS2B(V_MSGXML VARCHAR2) is
    V_TX2B   tx.msg_2B;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2B');

    V_TX2B:=fn_xml2obj_2B(V_MSGXML);

    --XU LY MESSAGE 2B.
    SELECT ORGORDERID
    INTO V_ORGORDERID
    FROM ORDERMAP
    WHERE ctci_order= TRIM(V_TX2B.ORDER_NUMBER);

    -- Cap nhat trang thai trong OOD va ODMAST
    UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_ORGORDERID and  OODSTATUS <> 'S';

    UPDATE ODMAST SET
        ORSTATUS = '2',
        HOSESESSION = (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
    WHERE ORDERID = V_ORGORDERID AND ORSTATUS IN( '8','11');

    plog.setendsection (pkgctx, 'PRC_PROCESS2B');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2B Khong tim so hieu lenh goc V_TX2B.ORDER_NUMBER: '||V_TX2B.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2B');
    ROLLBACK;
END PRC_PROCESS2B;

  --PROCESS MSG 2C
Procedure PRC_PROCESS2C(V_MSGXML VARCHAR2) is
    V_TX2C   tx.msg_2C;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2C');

    V_TX2C:=fn_xml2obj_2C(V_MSGXML);
    SELECT ORGORDERID
    INTO V_ORGORDERID FROM ORDERMAP
    WHERE ctci_order =TRIM(V_TX2C.order_number);
    CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID,V_TX2C.cancel_shares);

    plog.setendsection (pkgctx, 'PRC_PROCESS2C');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2C Khong tim so hieu lenh goc V_TX2C.ORDER_NUMBER: '||V_TX2C.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2C');
    ROLLBACK;
END PRC_PROCESS2C;

 --PROCESS MSG 2E
Procedure PRC_PROCESS2E(V_MSGXML VARCHAR2) is
    V_TX2E   tx.msg_2E;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2E');

    V_TX2E:=fn_xml2obj_2E(V_MSGXML);

    --XU LY MESSAGE 2E.
    --1.1 Lay so hieu lenh
    SELECT ORGORDERID INTO V_ORGORDERID FROM ORDERMAP
    WHERE ctci_order=TRIM(V_TX2E.order_number);
    --1.2 Cap nhat trang thai lenh thanh Sent: S
    UPDATE OOD SET
    OODSTATUS = 'S',
    TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
    SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_ORGORDERID and OODSTATUS <> 'S';

    --Goi thu tuc khop lenh
    MATCHING_NORMAL_ORDER (V_TX2E.firm,V_TX2E.order_number,V_TX2E.order_entry_date,
                            V_TX2E.side,V_TX2E.filler,V_TX2E.volume,
                            V_TX2E.price, V_TX2E.confirm_number);
    plog.setendsection (pkgctx, 'PRC_PROCESS2E');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2E Khong tim so hieu lenh goc V_TX2E.ORDER_NUMBER: '||V_TX2E.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2E');
    ROLLBACK;
END PRC_PROCESS2E;


--- process 2g
Procedure PRC_PROCESS2G(V_MSGXML VARCHAR2) is
    V_TX2G   tx.msg_2G;
    V_ORGORDERID VARCHAR2(20);
    v_msgReject varchar2(200);
    v_orderqtty number;
    v_codeid varchar2(10);
    v_contrafirm varchar2(10);
    v_custodycd varchar2(10);
    v_RefOrderID  varchar2(20);
    v_ptdeal      varchar2(20);
    v_qtty number;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2G');

    V_TX2G:=fn_xml2obj_2G(V_MSGXML);
    Insert into ctci_reject --Ghi log b? t? ch?i
        (firm,
        order_number,
        reject_reason_code,
        original_message_text,
        order_entry_date,
        msgtype)
    VALUES
        (V_TX2G.FIRM,
        V_TX2G.order_number,
        V_TX2G.reject_reason_code,
        V_TX2G.original_message_text,
        V_TX2G.order_entry_date,
        V_TX2G.msg_type);
    --XU LY MESSAGE 2G.
    If V_TX2G.msg_type='1G' then
         SELECT ORGORDERID
        INTO V_ORGORDERID
        FROM ORDERMAP
        WHERE ctci_order = TRIM(V_TX2G.deal_id);
    else
        SELECT ORGORDERID
        INTO V_ORGORDERID
        FROM ORDERMAP
        WHERE ctci_order = TRIM(V_TX2G.ORDER_NUMBER);
    end if;
    --Ly do tu choi
    Begin
        Select cdcontent  Into v_msgReject
        From allcode
        Where cdname = 'REJECT_REASON_CODE'
            and cdval =V_TX2G.reject_reason_code;
    Exception when OTHERS  then
        v_msgReject:=V_TX2G.reject_reason_code;
    End;

    If V_TX2G.msg_type='1I' then --Dat lenh thuong
        UPDATE OOD
        SET OODSTATUS = 'S',
            TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
            SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
            and OODSTATUS <> 'S';
        Select remainqtty into v_qtty
        From odmast Where Orderid = V_ORGORDERID;


        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID, v_qtty);
        Update odmast
        set
            EXECQTTY   = 0,
            ORSTATUS   = '6',--Bi tu choi boi so
            FEEDBACKMSG= v_msgReject
        Where Orderid = V_ORGORDERID;
     elsif V_TX2G.msg_type='1F' then --Thoa thuan cung cong ty (can huy lenh mua tuong ung)
        --Tim thong tin lenh mua doi ung
        select orderqtty, codeid, contrafirm, cf.custodycd, ptdeal
        into
        v_orderqtty,
        v_codeid,
        v_contrafirm,
        v_custodycd,
        v_ptdeal
        from odmast, cfmast cf
        where Orderid = V_ORGORDERID
        and odmast.custid = cf.custid;

        select orderid
        into v_RefOrderID
        from odmast
        where codeid = v_codeid
        and orderqtty = v_orderqtty
        and clientid = v_custodycd
        and contrafirm = (select sysvalue from ordersys where sysname='FIRM')
        and matchtype = 'P'
        and ptdeal =v_ptdeal ;

        CONFIRM_CANCEL_NORMAL_ORDER(v_RefOrderID,v_orderqtty);
        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID,v_orderqtty);

        UPDATE OOD
        SET OODSTATUS = 'S',
        TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
        SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID in ( v_RefOrderID,V_ORGORDERID)
        and OODSTATUS <> 'S';

        Update odmast
        set
        EXECQTTY   = 0,
        ORSTATUS   = '6',
        FEEDBACKMSG= v_msgReject
        Where Orderid  in (v_RefOrderID,V_ORGORDERID);
    elsif V_TX2G.msg_type='1G' then --Thoa thuan khac cong ty
        --Tim thong tin lenh ban goc
        select orderqtty
        into
        v_orderqtty
        from odmast
        where Orderid = V_ORGORDERID
        and matchtype = 'P' ;

        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID,v_orderqtty);

        UPDATE OOD
        SET OODSTATUS = 'S',
        TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
        SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
        and OODSTATUS <> 'S';

        Update odmast
        set
        EXECQTTY   = 0,
        ORSTATUS   = '6',
        FEEDBACKMSG= v_msgReject
        Where Orderid  in (V_ORGORDERID);
        --end add
    elsIf v_tx2g.msg_type='1C'  then --Tu chooi huy lenh

        --Tim orderid lenh yeu cau huy : v_RefOrderID
        --Cap nhat trang thai lenh yeu cau huy /suu
        Select orderid  Into v_RefOrderID
        From odmast
        Where reforderid  = V_ORGORDERID
            and exectype in ('CS','CB','AB','AS')
            and ORSTATUS <>'6' ; --huy ban/mua

        UPDATE OOD
        SET OODSTATUS = 'S',
            TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
            SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = v_RefOrderID
            and OODSTATUS <> 'S';

        Update odmast
        set
            EXECQTTY   = 0,
            MATCHAMT   = 0,
            Execamt    = 0,
            ORSTATUS   = '6',
            FEEDBACKMSG= v_msgReject
        Where Orderid = v_RefOrderID;
         --Xu ly cho phep dat lai lenh huy
        DELETE odchanging WHERE orderid =v_RefOrderID;

      update  fomast set status='R', feedbackmsg=v_msgReject
      WHERE orgacctno=v_RefOrderID;
    elsIf v_tx2g.msg_type='3C'  then --Tu choi huy lenh

        --Tim orderid lenh yeu cau huy : v_RefOrderID
        --Cap nhat trang thai lenh yeu cau huy /sua
        UPDATE CANCELORDERPTACK
        SET status='S' , isconfirm='Y'
        WHERE ordernumber= V_ORGORDERID
        AND SORR='S' AND MESSAGETYPE='3C'
        AND STATUS='S';

    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS2G');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2G V_TX2G.ORDER_NUMBER = '||V_TX2G.ORDER_NUMBER);
    plog.setendsection (pkgctx, 'PRC_PROCESS2G');
    rollback;
END PRC_PROCESS2G;


--PROCESS MSG 2D
Procedure PRC_PROCESS2D(V_MSGXML VARCHAR2) is
    V_TX2D   tx.msg_2D;
    V_ORGORDERID VARCHAR2(20);
    PV_ORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2D');

    V_TX2D:=fn_xml2obj_2D(V_MSGXML);

    -- Cap nhat lai gia qua msg 2D de giai toa
    Select Orgorderid into PV_ORDERID
    From Ordermap
    Where ctci_order =V_TX2D.ordernumber;

    UPDATE ODMAST
    Set quoteprice = V_TX2D.price *1000
    WHERE ORDERID =PV_ORDERID;

    --XU LY MESSAGE 2D.
    -- CONFIRM_REPLACE_NORMAL_ORDER(V_TX2D.ordernumber,V_TX2D.price);

    plog.setendsection (pkgctx, 'PRC_PROCESS2D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESS2D V_TX2D.ordernumber = ' || V_TX2D.ordernumber);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS2D');
    rollback;
END PRC_PROCESS2D;

--PROCESS MSG 2I
Procedure PRC_PROCESS2I(V_MSGXML VARCHAR2) is
    V_TX2I   tx.msg_2I;
    V_Buy_ORGORDERID VARCHAR2(20);
    V_Sell_ORGORDERID VARCHAR2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2I');

    V_TX2I:=fn_xml2obj_2I(V_MSGXML);
    -- Lay so hieu lenh goc truoc de trong TH chua update vao OrderMap
    -- do msg 2I ve qua' nhanh thi se bi exeption
    SELECT ORGORDERID
    INTO V_Buy_ORGORDERID
    FROM ORDERMAP
    WHERE ctci_order=TRIM(V_TX2I.order_number_buy);

    SELECT ORGORDERID
    INTO V_Sell_ORGORDERID
    FROM ORDERMAP
    WHERE ctci_order=TRIM(V_TX2I.order_number_sell);

    -- Cap nhat trang thai trong OOD
    UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_Buy_ORGORDERID and OODSTATUS <> 'S';

    UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_Sell_ORGORDERID and OODSTATUS <> 'S';

    --Goi thu thuc khop lenh voi lenh mua B
    MATCHING_NORMAL_ORDER (V_TX2I.firm,V_TX2I.order_number_buy,V_TX2I.order_entry_date_buy,
                            'B','',V_TX2I.volume,
                            V_TX2I.price, V_TX2I.confirm_number);

    --Goi thu thuc khop lenh voi lenh ban S
    MATCHING_NORMAL_ORDER (V_TX2I.firm,V_TX2I.order_number_sell,V_TX2I.order_entry_date_sell,
                            'S','',V_TX2I.volume,
                            V_TX2I.price, V_TX2I.confirm_number);
    plog.setendsection (pkgctx, 'PRC_PROCESS2I');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2I Khong tim so hieu lenh goc V_TX2I.order_number_buy: '||V_TX2I.order_number_buy);
    plog.error(pkgctx,'PRC_PROCESS2I Khong tim so hieu lenh goc V_TX2I.order_number_sell: '||V_TX2I.order_number_sell);
    plog.setendsection (pkgctx, 'PRC_PROCESS2I');
    rollback;
END;


--PROCESS MSG 2L
Procedure PRC_PROCESS2L(V_MSGXML VARCHAR2) is
    V_TX2L   tx.msg_2L;
    V_ORGORDERID VARCHAR2(20);
    v_strContraOrderId VARCHAR2(20);
    V_OneFirm Boolean;
    v_StrClientID Varchar2(20);
    v_strCUSTODYCD Varchar2(20);
    v_strBorS Varchar2(20);
    v_dblCTCI_order Varchar2(20);

   /* -- Cursor nay truoc day dat ten la C_TWOFIRM nhung sai ban chat nen doi ten lai thanh C_ONEFIRM
    CURSOR C_ONEFIRM(v_strORDERID Varchar2) IS
    SELECT OD.ORDERID ORDERID,od.CONTRAFIRM CONTRAFIRM,OD.TRADERID TRADERID,
        OD.CLIENTID CLIENTID,O1.CUSTODYCD CUSTODYCD,O1.BORS BORS,
        o2.orgorderid ContraOrderId
    FROM ORDERMAP MAP,ODMAST OD,OOD O1, OOD O2, odmast om2
    WHERE O1.ORGORDERID=OD.ORDERID AND TRIM(OD.CLIENTID) IS NOT NULL
        AND TRIM(OD.TRADERID) IS NOT NULL
        AND MAP.ORGORDERID=OD.orderid
        AND od.ORDERID=v_strORDERID
        and od.clientid = O2.custodycd
        and o1.bors <> o2.bors
        and o1.qtty = o2.qtty
        and o1.price = o2.price
        and o2.norp='P'
        and o2.oodstatus<>'S'
        and o2.Deltd <>'Y'
        and o2.orgorderid=om2.orderid
        and om2.exectype in ('NB','NS')
        and om2.remainqtty = o2.qtty;*/

    -- Check lenh onefirm bawng truong ptdeal
    CURSOR C_ONEFIRM(v_strORDERID Varchar2) IS
    SELECT OD.ORDERID ORDERID,od.CONTRAFIRM CONTRAFIRM,OD.TRADERID TRADERID,
        OD.CLIENTID CLIENTID,O1.CUSTODYCD CUSTODYCD,O1.BORS BORS,
        om2.orderid ContraOrderId
    FROM ORDERMAP MAP,ODMAST OD,OOD O1, odmast om2
    WHERE O1.ORGORDERID=OD.ORDERID
        AND TRIM(OD.CLIENTID) IS NOT NULL
        AND TRIM(OD.TRADERID) IS NOT NULL
        AND MAP.ORGORDERID=OD.orderid
        AND od.ORDERID=v_strORDERID
        and NVL(od.ptdeal,'XX') = NVL(om2.ptdeal,'YY')
        AND OD.EXECTYPE<>OM2.EXECTYPE
        AND OD.ORDERID<>OM2.ORDERID
        and om2.Deltd <>'Y'
        and od.matchtype = om2.matchtype
        and od.quoteprice = om2.quoteprice
        and od.orderqtty = om2.orderqtty;

    vc_ONEFIRM C_ONEFIRM%Rowtype;
    Cursor c_Ctci_Order(v_strORDERID Varchar2) is
    Select CTCI_ORDER
    From ORDERMAP
    WHERE Orgorderid=v_strORDERID;
    v_CTCI_order Varchar2(20);

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2L');

    V_TX2L:=fn_xml2obj_2L(V_MSGXML);

    --XU LY MESSAGE 2L.
    --Neu la lenh thoa thuan mua:
    If V_TX2L.side ='B' Then
        Select ORDERID Into V_ORGORDERID
        from Odmast
        WHERE   ORSTATUS  not like '%4%'
            AND trim(CONFIRM_NO)=trim(V_TX2L.confirm_number)
            and txdate = getcurrdate;
        v_strBORS:='B';

    Else --Thoa thuan ban, hoac Onefirm: Deal_ID chinh la so hieu lenh cty gui len
        Select ORGORDERID ORDERID  Into V_ORGORDERID
        From ORDERMAP
        WHERE CTCI_ORDER=trim(V_TX2L.deal_id);
        v_strBORS:='S';
    End if;
    --Lay so hieu lenh CTCI:
    OPEN c_Ctci_Order(V_ORGORDERID);
    Fetch c_Ctci_Order into v_CTCI_order;
    Close c_Ctci_Order;

    --Kiem tra xem day la lenh one-firm or two-firm put-through order

    Open C_ONEFIRM(V_ORGORDERID);
    Fetch C_ONEFIRM into vc_ONEFIRM;
    If C_ONEFIRM%notfound then
      V_OneFirm := false;
    Else  --OneFirm
      V_OneFirm := true;
      v_StrClientID  :=vc_ONEFIRM.CLIENTID;
      v_strCUSTODYCD :=vc_ONEFIRM.CUSTODYCD;
      v_strBORS      :=vc_ONEFIRM.BORS;
      v_strContraOrderId :=vc_ONEFIRM.ContraOrderId;
    End if;
    Close C_ONEFIRM;

    UPDATE OOD SET
      OODSTATUS = 'S',
      TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
      SENTTIME = SYSTIMESTAMP
    WHERE ORGORDERID = V_ORGORDERID and OODSTATUS <> 'S';

    --Khop lenh
    -- 1.1 Neu khop cung cong ty
    If V_OneFirm=True then
      plog.debug(pkgctx,'Khop lenh cung cong ty');
      --1.1.1 Khop lenh ban
            --Goi thu thuc khop lenh voi lenh ban S
      plog.debug(pkgctx,'Khop lenh ban '||V_TX2L.deal_id);
      MATCHING_NORMAL_ORDER (V_TX2L.firm,V_TX2L.deal_id,
                               '',
                               'S','',V_TX2L.volume,
                              V_TX2L.price, V_TX2L.confirm_number);

      If v_strContraOrderId is not null then
          --Lay so hieu lenh tu Ordermap de khop lenh.
          Select SEQ_ORDERMAP.NEXTVAL into v_dblCTCI_order from dual;
          INSERT INTO ORDERMAP(ctci_order,orgorderid)
          VALUES (v_dblCTCI_order ,v_strContraOrderId);

          UPDATE OOD SET
              OODSTATUS = 'S',
              TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
              SENTTIME = SYSTIMESTAMP
            WHERE ORGORDERID = v_strContraOrderId and OODSTATUS <> 'S';

          plog.debug(pkgctx,'Khop lenh doi ung '||v_dblCTCI_order);
          --Thuc hien khop
          MATCHING_NORMAL_ORDER (V_TX2L.firm,v_dblCTCI_order,
                               '',
                               'B','',V_TX2L.volume,
                              V_TX2L.price, V_TX2L.confirm_number);
      End if;

    Else --Neu khop khac cong ty.
          plog.debug(pkgctx,'Khop lenh khac cong ty: '||v_CTCI_order);
          MATCHING_NORMAL_ORDER (V_TX2L.firm,v_CTCI_order,
                               '',
                              v_strBORS,'',V_TX2L.volume,
                              V_TX2L.price, V_TX2L.confirm_number);
    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS2L');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS2L V_TX2L.confirm_number = '||V_TX2L.confirm_number);
    plog.error(pkgctx,'PRC_PROCESS2L V_TX2L.deal_id = '||V_TX2L.deal_id);
    plog.setendsection (pkgctx, 'PRC_PROCESS2L');
    rollback;
END PRC_PROCESS2L;


Procedure PRC_PROCESS2F(V_MSGXML VARCHAR2) is
    V_TX2F   tx.msg_2F;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS2F');

    V_TX2F:=fn_xml2obj_2F(V_MSGXML);

    --XU LY MESSAGE 2F.
    --1.1 Lay so hieu lenh
    INSERT INTO orderptack
          (TIMESTAMP, messagetype, firm, buyertradeid, side,
           sellercontrafirm, sellertradeid, securitysymbol, volume,
           price, board, confirmnumber, offset, status, issend,
           ordernumber, brid, tlid, txtime, ipaddress, trading_date,
           sclientid
          )
    VALUES (TO_CHAR(SYSDATE,'HH24MISS'), '', V_TX2F.firm_buy, V_TX2F.trader_id_buy, V_TX2F.side_b,
           V_TX2F.contra_firm_sell, V_TX2F.trader_id_contra_side_sell, trim(V_TX2F.security_symbol), V_TX2F.volume,
           V_TX2F.price, V_TX2F.board, TRIM(V_TX2F.confirm_number), '', 'N', 'N',
           '', '', '', '', '', TRUNC(SYSDATE),
           ''
          );

    plog.setendsection (pkgctx, 'PRC_PROCESS2F');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESS2F V_TX2F.confirm_number = ' || V_TX2F.confirm_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS2F');
    rollback;
END PRC_PROCESS2F;


-- Process msg 3B
Procedure PRC_PROCESS3B(V_MSGXML VARCHAR2) is
    V_TX3b   tx.msg_3B;
    V_ORGORDERID VARCHAR2(20);
    p_err_param varchar2(30);
    p_err_code varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3B');
    plog.debug(pkgctx,'BEGIN PRC_PROCESS3b');
    V_TX3b:=fn_xml2obj_3B(V_MSGXML);

    V_ORGORDERID:=null;
    --XU LY MESSAGE 3B.
    BEGIN
        SELECT ORGORDERID INTO V_ORGORDERID
        FROM ORDERMAP WHERE ctci_order= TRIM(V_TX3b.deal_id);
    EXCEPTION WHEN OTHERS THEN
        -- Chi xay ra trong truong hop tu choi lenh mua cua doi tac, truong hop nay ko phai xu lu gi
        plog.error(pkgctx,'PRC_PROCESS3b'||'Khong tim so hieu lenh goc V_TX3b.deal_id: '||V_TX3b.deal_id);
    END;
    IF V_ORGORDERID is not null Then
        UPDATE OOD SET
        OODSTATUS = 'S',
        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
        SENTTIME = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID and oodstatus <> 'S';

        IF V_TX3b.reply_code in ('C','S') THEN  -- Doi tac tu choi mua hoac HOSE khong chap nhan
          Update odmast
          Set deltd ='Y', CANCELQTTY =ORDERQTTY,
               REMAINQTTY=0,EXECQTTY =0 ,MATCHAMT =0,Execamt =0, ORSTATUS = '2'
          Where MATCHTYPE ='P'  And Orderid = V_ORGORDERID;
          ----Ducnv + hailt
          Update ood set  deltd ='Y' where orgorderid = V_ORGORDERID;

          -- Xu ly cho lenh thoa thuan nhom BVS
          For vc in (Select orderid
                    From odmast
                    Where grporder='Y' and  orderid= V_ORGORDERID)
          Loop
              cspks_seproc.pr_executeod9996(V_ORGORDERID,p_err_code,p_err_param);
          End loop;
         ----End of Ducnv
        END IF;

        Insert into orderptack( messagetype, firm, side,        confirmnumber,
            status, issend,        ordernumber,        trading_date )
        Values ('3B',V_TX3b.firm,'S',V_TX3b.confirm_number,
            V_TX3b.reply_code,'S',V_ORGORDERID,trunc(sysdate));
    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS3B');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.error(pkgctx,'PRC_PROCESS3B V_TX3b.deal_id = '||V_TX3b.deal_id);
    plog.setendsection (pkgctx, 'PRC_PROCESS3B');
    rollback;
END PRC_PROCESS3B;


--PROCESS MSG 3C
Procedure PRC_PROCESS3C(V_MSGXML VARCHAR2) is
    V_TX3C   tx.msg_3C;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3C');

    V_TX3C:=fn_xml2obj_3C(V_MSGXML);

    --XU LY MESSAGE 3C.
    --1.1 Lay so hieu lenh
    INSERT INTO Cancelorderptack
              (sorr, TIMESTAMP, messagetype, firm, contrafirm, tradeid,
               side, securitysymbol, confirmnumber, status, isconfirm,
               ordernumber, brid, tlid, txtime, ipaddress, trading_date
              )
       VALUES ('R', to_char(sysdate,'hh24miss'), '', V_TX3C.firm, V_TX3C.contra_firm, V_TX3C.trader_id,
               V_TX3C.side, V_TX3C.security_symbol, V_TX3C.confirm_number, 'N', 'N',
               '', '', '', '', '', trunc(sysdate)
              );

    plog.setendsection (pkgctx, 'PRC_PROCESS3C');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,'PRC_PROCESS3C '|| SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS3C');
    rollback;
END PRC_PROCESS3C;


--PROCESS MSG SC
Procedure PRC_PROCESSSC(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2) is
    V_TXSC   tx.msg_SC;
    V_ORGORDERID VARCHAR2(20);
    v_Controlcode VARCHAR2(20);
    V_DELTA_TIME number;
    l_timemsg       VARCHAR2(10);
    l_timeordersys  VARCHAR2(10);
    l_delta_time      INTEGER;
    l_TIMESTAMPO  VARCHAR2(20);
    p_err_code  VARCHAR2(300);
     p_err_message  VARCHAR2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSSC');

    V_TXSC:=fn_xml2obj_SC(V_MSGXML);

    --XU LY MESSAGE SC.

    BEGIN
        SELECT SYSVALUE INTO V_CONTROLCODE
        FROM  ORDERSYS
        WHERE SYSNAME='CONTROLCODE';
    EXCEPTION WHEN OTHERS THEN
        V_CONTROLCODE:='';
    END;
--ThangPV chinh sua lo le HSX 27-04-2022
--    IF V_CONTROLCODE ='O' AND V_TXSC.SYSTEM_CONTROL_CODE ='F' THEN
 --     NULL;
 --   ELSE
    IF V_TXSC.system_control_code IN ('E','L','M','S') THEN
      IF V_TXSC.system_control_code IN ('E','M') THEN
        UPDATE ORDERSYS SET SYSVALUE='E' WHERE SYSNAME='CONTROLCODE_ODD_LOT';
      ELSE
        UPDATE ORDERSYS SET SYSVALUE=V_TXSC.SYSTEM_CONTROL_CODE WHERE SYSNAME='CONTROLCODE_ODD_LOT';
      END IF;
    ELSE
    IF V_CONTROLCODE ='O' AND V_TXSC.SYSTEM_CONTROL_CODE ='F' THEN
        NULL;
      ELSE  --End ThangPV chinh sua lo le HSX 27-04-2022
        UPDATE ORDERSYS
        SET SYSVALUE=V_TXSC.SYSTEM_CONTROL_CODE
        WHERE SYSNAME='CONTROLCODE';

        UPDATE ORDERSYS
        SET SYSVALUE= LPAD(V_TXSC.TIMESTAMP,6,'0')
        WHERE SYSNAME='TIMESTAMP';
        COMMIT;
         --phuongntn tinh thoi gian chenh lech HO-Flex, cap nhat odersys
         l_timemsg:=NVL(V_MSG_DATE,TO_CHAR(SYSDATE,'HH24MISS'));
         l_timeordersys:=LPAD(V_TXSC.TIMESTAMP,6,'0');
         l_delta_time:=TO_NUMBER(SUBSTR(l_timeordersys,1,2)) * 3600
                    + TO_NUMBER(SUBSTR(l_timeordersys,3,2)) * 60
                    + TO_NUMBER(SUBSTR(l_timeordersys,5,2))
                - (
                    TO_NUMBER(SUBSTR(l_timemsg,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timemsg,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timemsg,5,2))
                    );

          UPDATE ORDERSYS SET SYSVALUE= tO_CHAR(l_delta_time) WHERE SYSNAME='DELTATIME';
        --phuongntn end
        If V_TXSC.SYSTEM_CONTROL_CODE ='O' then
              --phuongntn edit tho gio cua So lenh MP
              Begin
                  l_TIMESTAMPO:=to_char(to_date(LPAD(V_TXSC.TIMESTAMP,6,'0'),'hh24miss' )+ 10/3600/24,'hh24miss');
                  UPDATE ORDERSYS SET SYSVALUE= l_TIMESTAMPO WHERE SYSNAME='TIMESTAMPO';
              EXCEPTION WHEN OTHERS THEN
                  UPDATE ORDERSYS SET SYSVALUE= to_char(sysdate + 10/3600/24,'hh24miss') WHERE SYSNAME='TIMESTAMPO';
                  plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
              End;
              --end edit
              --ThangPV chinh sua lo le HSX 27-04-2022
              --VCBSDEPII-1159    1.0.2.11
              For vc in ( select od.orderid , od.afacctno, od.orderqtty
                      from odmast od , ood , sbsecurities s
                      where od.orderid = ood.orgorderid
                           and od.txdate = getcurrdate
                           and od.deltd <> 'Y'
                          and ood.oodstatus IN ('N','B')
                          and od.pricetype ='ATO'
                          and s.codeid = od.codeid
                          and s.tradeplace= '001')
              LOOP
                  CONFIRM_CANCEL_NORMAL_ORDER(vc.orderid, vc.orderqtty);
              End loop;
              --End ThangPV chinh sua lo le HSX 27-04-2022
        End if ;
         -- DUCNV sinh lenh huy cho lenh RP khi vao phien ATC
        If V_TXSC.SYSTEM_CONTROL_CODE ='A' then
            For vc in (Select
                       f.username,
                       o.orderid acctno,
                       f.afacctno,
                       f.exectype ,
                       f.symbol,
                       f.remainqtty quantity,
                       f.quoteprice,
                       f.pricetype,
                       f.timetype,
                       f.book,
                       f.via,
                      '' dealid,
                       f.direct,
                       f.effdate,
                       f.expdate,
                       f.tlid,
                       f.quoteqtty,
                       f.limitprice
                        From odmast o, fomast f, rootordermap R, sbsecurities s
                        Where
                               o.pricetype='LO'
                              and o.remainqtty>0
                              and o.orderid = r.orderid
                              and r.foacctno=f.acctno
                              and f.pricetype='RP'
                              and o.codeid=s.codeid
                              and s.tradeplace='001')
            LOOP

               fopks_api.pr_PlaceOrder('CANCELORDER',
                        vc.username,
                        vc.acctno ,
                        vc.afacctno ,
                        vc.exectype  ,
                        vc.symbol  ,
                        vc.quantity  ,
                        vc.quoteprice  ,
                        vc.pricetype ,
                        vc.timetype ,
                        vc.book ,
                        vc.via ,
                        vc.dealid ,
                        vc.direct ,
                        vc.effdate ,
                        vc.expdate ,
                        vc.tlid  ,
                        vc.quoteqtty ,
                        vc.limitprice ,
                        p_err_code ,
                        p_err_message
                        );
                 Insert into logrporder(txdate,orderid) values(getcurrdate,vc.acctno);
            End loop;

        End if;
        -- End of DUCNV ----------------
    End IF;
    END IF;

    plog.setendsection (pkgctx, 'PRC_PROCESSSC');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSSC V_TXSC.SYSTEM_CONTROL_CODE = ' || V_TXSC.SYSTEM_CONTROL_CODE);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSSC');
    rollback;
END PRC_PROCESSSC;


--PROCESS MSG TR
Procedure PRC_PROCESSTR(V_MSGXML VARCHAR2) is
    V_TXTR   tx.msg_TR;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSTR');

    V_TXTR:=fn_xml2obj_TR(V_MSGXML);

    --XU LY MESSAGE TR.
    UPDATE HO_SEC_INFO
    SET TRADING_DATE=trunc(SYSDATE), CURRENT_ROOM=V_TXTR.current_room,
      TOTAL_ROOM =V_TXTR.total_room
    WHERE FLOOR_CODE ='10' And STOCK_ID= V_TXTR.security_number;


    UPDATE SECURITIES_INFO
    SET    current_room=V_TXTR.current_room
    WHERE TRIM(SYMBOL) In (SELECT TRIM(CODE) From HO_SEC_INFO
                          Where TRIM(STOCK_ID) = TRIM(V_TXTR.security_number));

    plog.setendsection (pkgctx, 'PRC_PROCESSTR');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSTR V_TXTR.security_number = ' ||V_TXTR.security_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSTR');
    rollback;
END PRC_PROCESSTR;


--PROCESS MSG GA
Procedure PRC_PROCESSGA(V_MSGXML VARCHAR2) is
    V_TXGA   tx.msg_GA;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSGA');

    V_TXGA:=fn_xml2obj_GA(V_MSGXML);

    --XU LY MESSAGE GA.
    INSERT INTO ga
          (trading_date, msg_length, msg_text
          )
    VALUES (sysdate, V_TXGA.admin_message_length, V_TXGA.admin_message_text
          );

    plog.setendsection (pkgctx, 'PRC_PROCESSGA');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSGA V_TXGA.admin_message_text = ' ||V_TXGA.admin_message_text);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSGA');
    rollback;
END PRC_PROCESSGA;


--PROCESS MSG SU
Procedure PRC_PROCESSSU(V_MSGXML VARCHAR2) is
    V_TXSU   tx.msg_SU;
    V_ORGORDERID VARCHAR2(20);
    V_UpdatePrice Varchar2(10);
    v_Count Number(10);
    v_Halt  Varchar2(10);
    v_Security_Type Varchar2(10);
    v_strErrCode  Varchar2(20);
    v_strErrM Varchar2(200);
    l_CODEID    varchar2(100);
    v_odd_lot_halt  varchar2(2); --LoLeHSX

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSSU');

    V_TXSU:=fn_xml2obj_SU(V_MSGXML);


    --XU LY MESSAGE SU.

    SELECT count(1) Into v_Count
    FROM Ho_Sec_Info
    WHERE Floor_code ='10'
    And Stock_ID = Trim(V_TXSU.security_number_new);

    If V_TXSU.security_type ='S' Then
        v_Security_Type:=1; --COMMON_STOCK
    Elsif V_TXSU.security_type ='D' Then
        v_Security_Type:=2; --DEBENTURE
    Elsif V_TXSU.security_type in ('U','E') Then
        v_Security_Type:=3; --UNIT_TRUST
    --Ngay 07/03/2017 CW NamTv add them loai CK la chung quyen
    Elsif V_TXSU.security_type ='W' Then
     v_Security_Type:=4; --Covered Warrant
    --End NamTV
    End if;

    --Kiem tra trong bang HO_SEC_INFO,SECURITIES_INFO, SBSECURITIES,
    --Neu co roi thi Update, chua co thi Insert bang HO_SEC_INFO
    If v_Count >0 Then
        UPDATE Ho_Sec_info
        SET        Time  =  to_char(sysdate,'hh24miss'),
            halt_resume_flag =   V_TXSU.HALT_RESUME_FLAG,
            ceiling_price =      V_TXSU.CEILING_PRICE ,
            floor_price =        V_TXSU.FLOOR_PRICE ,
            basic_price =        V_TXSU.PRIOR_CLOSE_PRICE ,
            prior_close_price =  V_TXSU.PRIOR_CLOSE_PRICE ,
            lowest_price =       V_TXSU.LOWEST_PRICE ,
            highest_price =      V_TXSU.HIGHEST_PRICE ,
            match_price =        V_TXSU.LAST_SALE_PRICE ,
            open_price =         V_TXSU.OPEN_PRICE ,
            suspension =         V_TXSU.SUSPENSION,
            delist =             V_TXSU.DELIST,
             /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
             underlyingsymbol = V_TXSU.UNDERLYINGSYMBOL, /*Ma CK co so*/
             issuername       = V_TXSU.ISSUERNAME,   /*Ten TCPH CKSC*/
             coveredwarranttype  = V_TXSU.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
             maturitydate        = V_TXSU.MATURITYDATE,   /*Ngay het han chung quyen*/
             lasttradingdate     = V_TXSU.LASTTRADINGDATE,   /*Ngay giao dich cuoi cung*/
             exerciseprice      = V_TXSU.EXERCISEPRICE,   /*Gia thuc hien*/
             exerciseratio       = V_TXSU.EXERCISERATIO,    /*Ty le thuc hien*/
             /*--NamTV End*/
            security_number_new= v_txsu.security_number_new,
            security_number_old= v_txsu.security_number_old,
            code = trim(V_TXSU.SECURITY_SYMBOL),
            ODD_LOT_HALT_RESUME_FLAG = V_TXSU.odd_lot_halt_resume_flag --LoLeHSX
        Where FLOOR_CODE ='10'
            and STOCK_ID =  V_TXSU.security_number_new;
    Else
          INSERT INTO Ho_sec_info
             (floor_code, date_no, trading_date, TIME, stock_id, code,
             stock_type, trading_unit,
             highest_price, lowest_price, ceiling_price,
             floor_price,
             prior_close_price, PARVALUE ,
             halt_resume_flag , DELIST, SUSPENSION,
             /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
             underlyingsymbol, issuername, coveredwarranttype, maturitydate,
             lasttradingdate, exerciseprice, exerciseratio,
             /*--End NamTV*/
             security_number_new,security_number_old,
             ODD_LOT_HALT_RESUME_FLAG) --LoLeHSX
             VALUES ('10', '10',
             trunc(sysdate), to_char(sysdate,'hh24miss'), trim(V_TXSU.SECURITY_NUMBER_NEW) , trim(V_TXSU.SECURITY_SYMBOL),
             v_Security_Type, V_TXSU.BOARD_LOT ,
             V_TXSU.HIGHEST_PRICE , V_TXSU.LOWEST_PRICE , V_TXSU.CEILING_PRICE,
             V_TXSU.FLOOR_PRICE,
             V_TXSU.PRIOR_CLOSE_PRICE, V_TXSU.PAR_VALUE ,
             V_TXSU.HALT_RESUME_FLAG, V_TXSU.DELIST, V_TXSU.SUSPENSION,
             /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
             V_TXSU.UNDERLYINGSYMBOL, V_TXSU.ISSUERNAME, V_TXSU.COVEREDWARRANTTYPE, V_TXSU.MATURITYDATE,
             V_TXSU.LASTTRADINGDATE, V_TXSU.EXERCISEPRICE,  V_TXSU.EXERCISERATIO,
             /*--End NamTV*/
             v_txsu.security_number_new, v_txsu.security_number_old,
             V_TXSU.odd_lot_halt_resume_flag --LoLeHSX
             );

    End if;

    --Cap nhat thong tin HALT vao BO.
    If V_TXSU.HALT_RESUME_FLAG in ('H')  or V_TXSU.suspension ='S' or V_TXSU.delist ='D' Then
        v_Halt:='Y';
    Else
        v_Halt:='N';
    End if;
    --LoLeHSX Cap nhat thong tin halt lo le
    If V_TXSU.odd_lot_halt_resume_flag in ('H') Then
      v_odd_lot_halt := 'Y';
    Else
      v_odd_lot_halt := 'N';
    End if;
    --End LoLeHSX

    UPDATE SBSECURITIES
    SET HALT =  v_Halt,
        odd_lot_halt = v_odd_lot_halt --LoLeHSX
    WHERE SYMBOL=TRIM(V_TXSU.security_symbol);
    COMMIT;

    --Ngay 07/04/2017 CW NamTv cap nhat thong tin listedshare
    IF  v_Security_Type=4 THEN
      BEGIN
        UPDATE SECURITIES_INFO SET LISTINGQTTY=V_TXSU.LISTEDSHARE
            WHERE SYMBOL=TRIM(V_TXSU.security_symbol);

        UPDATE SBSECURITIES SET
            /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
            underlyingsymbol = V_TXSU.UNDERLYINGSYMBOL, /*Ma CK co so*/
            issuername       = V_TXSU.ISSUERNAME,   /*Ten TCPH CKSC*/
            coveredwarranttype  = V_TXSU.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
            maturitydate        = to_date(to_date(V_TXSU.MATURITYDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),  /*Ngay het han chung quyen*/
            lasttradingdate     = to_date(to_date(V_TXSU.LASTTRADINGDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),   /*Ngay giao dich cuoi cung*/
            exerciseprice      = TO_NUMBER(V_TXSU.EXERCISEPRICE) * 0.1,   /*Gia thuc hien*/
            exerciseratio       = to_char(TO_NUMBER(SUBSTR(V_TXSU.EXERCISERATIO,0,INSTR(V_TXSU.EXERCISERATIO,':') - 1)) * 10000) || '/' ||
                        to_char(TO_NUMBER(SUBSTR(V_TXSU.EXERCISERATIO,INSTR(V_TXSU.EXERCISERATIO,':')+1,LENGTH(V_TXSU.EXERCISERATIO))*10000)) /*Ty le thuc hien*/
            /*--NamTV End*/
            WHERE SYMBOL=TRIM(V_TXSU.security_symbol);
      EXCEPTION WHEN OTHERS THEN
           NULL;
      END;
        commit;
    END IF;
    --NamTv End

    --Cap nhat thong tin co phieu moi
    cspks_odproc.Pr_Update_SecInfo(TRIM(V_TXSU.security_symbol),nvl(V_TXSU.CEILING_PRICE*10,0),nvl(V_TXSU.FLOOR_PRICE*10,0),nvl(V_TXSU.PRIOR_CLOSE_PRICE*10,0),'001',v_Halt,v_strErrCode,'','','',TRIM(V_TXSU.security_symbol));
     commit;
    --Cap nhat thong tin ticksize
      select codeid into l_CODEID from securities_info where SYMBOL =TRIM(V_TXSU.security_symbol);
      DELETE FROM securities_ticksize WHERE codeid=l_CODEID;
      If V_TXSU.security_type in ('U','S') THEN --Co phieu, chung chi quy dong
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 10, 0, 9999, 'Y');

                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 50, 10000, 49999, 'Y');

                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 100, 50000, 100000000, 'Y');
      Elsif V_TXSU.security_type ='D' Then
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 1, 0, 100000000, 'Y');
      Elsif V_TXSU.security_type in ('E') Then
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 10, 0, 100000000, 'Y');
      Elsif V_TXSU.security_type in ('W') Then
                 INSERT INTO SECURITIES_TICKSIZE (AUTOID, CODEID, SYMBOL, TICKSIZE, FROMPRICE, TOPRICE, STATUS)
                 VALUES (SEQ_SECURITIES_TICKSIZE.NEXTVAL, l_CODEID, TRIM(V_TXSU.security_symbol), 10, 0, 100000000, 'Y');

      End if;
      commit;
      --End cap nhat thong tin ticksize
     -- Cap nhat gia cuoi ngay
    Pr_updatepricefromgw(TRIM(V_TXSU.security_symbol), nvl(V_TXSU.LAST_SALE_PRICE *10,0),nvl(V_TXSU.FLOOR_PRICE *10,0) ,nvl(V_TXSU.CEILING_PRICE *10,0),'CN',v_strErrCode,v_strErrM);

    plog.setendsection (pkgctx, 'PRC_PROCESSSU');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSSU V_TXSU.SECURITY_SYMBOL = ' || V_TXSU.SECURITY_SYMBOL);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSSU');
    rollback;
END PRC_PROCESSSU;


--PROCESS MSG SS
Procedure PRC_PROCESSSS(V_MSGXML VARCHAR2) is
    V_TXSS   tx.msg_SS;
    V_ORGORDERID VARCHAR2(20);
    v_Security_Type Varchar2(10);
    v_Halt  Varchar2(10);
    V_UpdatePrice  Varchar2(10);
    v_Symbol  Varchar2(20);
    v_strCodeID Varchar2(10);
    v_strErrCode Varchar2(20);
    v_strErrM Varchar2(200);
    v_odd_lot_halt  varchar2(2); --LoLeHSX
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSSS');

    V_TXSS:=fn_xml2obj_SS(V_MSGXML);

    If V_TXSS.security_type ='S' Then
        v_Security_Type:=1; --COMMON_STOCK
    Elsif V_TXSS.security_type ='D' Then
        v_Security_Type:=2; --DEBENTURE
    Elsif V_TXSS.security_type in ('U','E') Then
        v_Security_Type:=3; --UNIT_TRUST
    /*--Ngay 07/03/2017 CW NamTv add them loai CK la chung quyen*/
    Elsif V_TXSS.security_type ='W' Then
     v_Security_Type:=4; /*--Covered Warrant*/
    /*--End NamTV*/
    End if;

    --XU LY MESSAGE SS.

    UPDATE HO_sec_info
    SET  ceiling_price = V_TXSS.CEILING,
        floor_price =       V_TXSS.FLOOR_PRICE,
        halt_resume_flag =  V_TXSS.HALT_RESUME_FLAG,
        delist =            V_TXSS.DELIST,
        suspension =        V_TXSS.SUSPENSION,
        prior_close_price = V_TXSS.PRIOR_CLOSE_PRICE,
        --Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen
        underlyingsymbol = V_TXSS.UNDERLYINGSYMBOL, /*Ma CK co so*/
        issuername       = V_TXSS.ISSUERNAME,   /*Ten TCPH CKSC*/
        coveredwarranttype  = V_TXSS.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
        maturitydate        = V_TXSS.MATURITYDATE,   /*Ngay het han chung quyen*/
        lasttradingdate     = V_TXSS.LASTTRADINGDATE,   /*Ngay giao dich cuoi cung*/
        exerciseprice      = V_TXSS.EXERCISEPRICE,   /*Gia thuc hien*/
        exerciseratio       = V_TXSS.EXERCISERATIO,    /*Ty le thuc hien*/
        /*--NamTV End*/
        ODD_LOT_HALT_RESUME_FLAG = V_TXSS.odd_lot_halt_resume_flag --LoLeHSX
    Where FLOOR_CODE ='10' and STOCK_ID =  V_TXSS.security_number;

    commit;
    --Cap nhat thong tin HALT vao BO.
    If nvl(V_TXSS.halt_resume_flag,'-') in ('H')  or nvl(V_TXSS.suspension,'-') ='S'  or nvl(V_TXSS.delist,'-') ='D' Then
        v_Halt:='Y';
    Else
        v_Halt:='N';
    End if;

    --LoLeHSX Cap nhat thong tin halt lo le
    If V_TXSS.odd_lot_halt_resume_flag in ('H') Then
      v_odd_lot_halt := 'Y';
    Else
      v_odd_lot_halt := 'N';
    End if;
    --End LoLeHSX

    v_strCodeID:='xxxx';
    v_Symbol:='yyyy';
    For Vc in(SELECT s.symbol,s.codeid
              From HO_SEC_INFO H, Securities_info S
              Where H.code=S.symbol
                And H.STOCK_ID = TRIM(V_TXSS.security_number)
              )
    Loop
        v_strCodeID:=vc.codeid;
        v_Symbol:=vc.symbol;
    End loop;

    UPDATE SBSECURITIES
        SET HALT = v_Halt,
            odd_lot_halt = v_odd_lot_halt --LoLeHSX
       WHERE codeid=v_strCodeID;
    Commit;

    --Ngay 07/04/2017 CW NamTv cap nhat thong tin listedshare
    IF  v_Security_Type=4 THEN
      BEGIN
        UPDATE SECURITIES_INFO SET LISTINGQTTY=V_TXSS.LISTEDSHARE
            WHERE codeid=v_strCodeID;

        UPDATE SBSECURITIES SET
            /*--Ngay 07/03/2017 CW NamTV cap nhat thong tin chung quyen*/
            underlyingsymbol = V_TXSS.UNDERLYINGSYMBOL, /*Ma CK co so*/
            issuername       = V_TXSS.ISSUERNAME,   /*Ten TCPH CKSC*/
            coveredwarranttype  = V_TXSS.COVEREDWARRANTTYPE,   /*Loai chung quyen*/
            maturitydate        = to_date(to_date(V_TXSS.MATURITYDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),  /*Ngay het han chung quyen*/
            lasttradingdate     = to_date(to_date(V_TXSS.LASTTRADINGDATE,'RRRR/MM/DD'),'DD/MM/RRRR'),   /*Ngay giao dich cuoi cung*/
            exerciseprice      = TO_NUMBER(V_TXSS.EXERCISEPRICE) * 0.1,   /*Gia thuc hien*/
            exerciseratio       = to_char(TO_NUMBER(SUBSTR(V_TXSS.EXERCISERATIO,0,INSTR(V_TXSS.EXERCISERATIO,':') - 1))*10000) || '/' ||
                        to_char(TO_NUMBER(SUBSTR(V_TXSS.EXERCISERATIO,INSTR(V_TXSS.EXERCISERATIO,':')+1,LENGTH(V_TXSS.EXERCISERATIO))*10000)) /*Ty le thuc hien*/
            /*--NamTV End*/
            WHERE codeid=v_strCodeID;
        commit;
      EXCEPTION WHEN OTHERS THEN
           NULL;
      END;
    END IF;

    -- Cap nhat gia dau ngay
    Pr_updatepricefromgw(v_Symbol, nvl(V_TXSS.PRIOR_CLOSE_PRICE * 10,0), nvl(V_TXSS.FLOOR_PRICE *10,0) ,nvl(V_TXSS.CEILING *10,0),'DN',v_strErrCode,v_strErrM);
    --phuongnt add
    --case chuyen san, moi niem yet,giai toa lenh ko sai
   Cspks_odproc.Pr_Update_SecInfo(v_Symbol,nvl(V_TXSS.CEILING*10,0),nvl(V_TXSS.FLOOR_PRICE*10,0),nvl(V_TXSS.PRIOR_CLOSE_PRICE*10,0),'001',v_Halt,v_strErrCode,
                                    '','',
                                    '',
                                    v_Symbol
   );
    plog.setendsection (pkgctx, 'PRC_PROCESSSS');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSSS V_TXSS.security_number = ' || V_TXSS.security_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSSS');
    rollback;
END PRC_PROCESSSS;


--PROCESS MSG TC
Procedure PRC_PROCESSTC(V_MSGXML VARCHAR2) is
    V_TXTC   tx.msg_TC;
    V_ORGORDERID VARCHAR2(20);
    v_Count Number(10);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSTC');

    V_TXTC:=fn_xml2obj_TC(V_MSGXML);

    --XU LY MESSAGE TC.
    SELECT COUNT(1) Into v_Count
    FROM TRADERID
    WHERE TO_NUMBER(TRADERID) = TO_NUMBER(TRIM(V_TXTC.TRADER_ID))
        and to_number(firm)=to_number(TRIM(V_TXTC.firm));
    --Neu co thi Update, chua co thi Insert
    If v_Count >0 Then
        UPDATE TRADERID
        SET STATUS = TRIM(V_TXTC.TRADER_STATUS),
            TRADING_DATE = SYSDATE
        WHERE  TO_NUMBER(TRADERID) = TO_NUMBER(TRIM(V_TXTC.TRADER_ID))
        and to_number(firm)=to_number(TRIM(V_TXTC.firm));
    Else
        INSERT INTO TRADERID(FIRM, TRADERID,STATUS,TRADING_DATE)
        VALUES(TRIM(V_TXTC.FIRM), TRIM(V_TXTC.TRADER_ID),TRIM(V_TXTC.TRADER_STATUS),SYSDATE);
    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESSTC');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSTC V_TXTC.TRADER_ID = ' ||V_TXTC.TRADER_ID);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSTC');
    rollback;
END PRC_PROCESSTC;


--PROCESS MSG TS
Procedure PRC_PROCESSTS(V_MSGXML VARCHAR2,V_MSG_DATE VARCHAR2) is
    V_TXTS   tx.msg_TS;
    V_ORGORDERID VARCHAR2(20);
    V_DELTA_TIME number;
    l_timemsg       VARCHAR2(10);
    l_timeordersys  VARCHAR2(10);
    l_delta_time      INTEGER;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSTS');

    V_TXTS:=fn_xml2obj_TS(V_MSGXML);

    --XU LY MESSAGE TS.

    UPDATE ORDERSYS
    SET SYSVALUE= Lpad(V_TXTS.timestamp,6,'0')
    WHERE SYSNAME='TIMESTAMP';
   --phuongntn tinh thoi gian chenh lech HO-Flex, cap nhat odersys
         l_timemsg:=NVL(V_MSG_DATE,TO_CHAR(SYSDATE,'HH24MISS'));
         l_timeordersys:= Lpad(V_TXTS.timestamp,6,'0');
         l_delta_time:=TO_NUMBER(SUBSTR(l_timeordersys,1,2)) * 3600
                    + TO_NUMBER(SUBSTR(l_timeordersys,3,2)) * 60
                    + TO_NUMBER(SUBSTR(l_timeordersys,5,2))
                - (
                    TO_NUMBER(SUBSTR(l_timemsg,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timemsg,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timemsg,5,2))
                    );
   UPDATE ORDERSYS SET SYSVALUE= tO_CHAR(l_delta_time) WHERE SYSNAME='DELTATIME';

    --phuongntn end
    plog.setendsection (pkgctx, 'PRC_PROCESSTS');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSTS V_TXTS.timestamp= ' || V_TXTS.timestamp);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSTS');
    rollback;
END PRC_PROCESSTS;


--PROCESS MSG BS
Procedure PRC_PROCESSBS(V_MSGXML VARCHAR2) is
    V_TXBS   tx.msg_BS;

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSBS');
    V_TXBS:=fn_xml2obj_BS(V_MSGXML);

    --XU LY MESSAGE BS.
    UPDATE TRADERID
    SET AUTOMATCH_HALT = TRIM(V_TXBS.AUTOMATCH_HALT_FLAG)
        , PUTTHROUGH_HALT = TRIM(V_TXBS.PUT_THROUGH_HALT_FLAG)
        , TRADING_DATE = SYSDATE
    WHERE  TO_NUMBER(TRIM(V_TXBS.FIRM))= TO_NUMBER(FIRM) ;

    plog.setendsection (pkgctx, 'PRC_PROCESSBS');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSBS V_TXBS.FIRM = ' ||V_TXBS.FIRM);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSBS');
    rollback;
END PRC_PROCESSBS;


--PROCESS MSG 3D
Procedure PRC_PROCESS3D(V_MSGXML VARCHAR2) is
    V_TX3D   tx.msg_3D;
    V_ORGORDERID VARCHAR2(20);
    v_afaccount VARCHAR2(20);
    p_err_param varchar2(30);
    p_err_code varchar2(30);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3D');

    V_TX3D:=fn_xml2obj_3D(V_MSGXML);

    plog.debug (pkgctx, 'PRC_PROCESS3D Parse successful');

    --XU LY MESSAGE 3D.
    Insert into msg_3d(confirm_number,firm,reply_code)
       values(V_TX3D.CONFIRM_NUMBER ,V_TX3D.FIRM ,V_TX3D.REPLY_CODE);
    plog.debug (pkgctx, 'PRC_PROCESS3D Insert msg_3d successful');
    --Cap nhat trang thai

    If V_TX3D.REPLY_CODE = 'C' Then --Doi tac tu choi huy
      --THUC HIEN CAP NHAT YEU CAU HUY TRONG HE THONG KHONG THANH CONG
        UPDATE CANCELORDERPTACK
        SET STATUS='C', ISCONFIRM='Y'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=V_TX3D.CONFIRM_NUMBER;
        plog.debug (pkgctx, 'PRC_PROCESS3D Update CONTRA DISAPPROVE successful');
    ElsIf V_TX3D.REPLY_CODE = 'S' Then --HOSE tu choi huy
      --THUC HIEN CAP NHAT YEU CAU HUY TRONG HE THONG KHONG THANH CONG
        UPDATE CANCELORDERPTACK
        SET STATUS='S', ISCONFIRM='Y'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=V_TX3D.CONFIRM_NUMBER;
        plog.debug (pkgctx, 'PRC_PROCESS3D Update SYSTEM SET DISAPPROVE successful');
    ElsIf V_TX3D.REPLY_CODE = 'A' Then --DONG Y HUY
        --HUC HIEN CAP NHAT YEU CAU HUY TRONG HE THONG KHONG THANH CONG
        UPDATE CANCELORDERPTACK
        SET STATUS='A', ISCONFIRM='Y'
        WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=V_TX3D.CONFIRM_NUMBER;

        --Giai toa lenh thoa thuan da khop
        --Xu ly Odmast
        plog.debug (pkgctx, 'PRC_PROCESS3D Update CANCELORDERPTACK successful');

        For i in (Select orgorderid ,codeid,bors,matchprice,matchqtty,txnum,txdate ,custodycd
                    From iod
                    Where NorP ='P'
                    And trim(confirm_no) =trim(V_TX3D.CONFIRM_NUMBER))
        Loop

            Update odmast
            Set deltd ='Y', CANCELQTTY =ORDERQTTY,
                            REMAINQTTY=0,EXECQTTY =0 ,MATCHAMT =0,Execamt =0
            Where MATCHTYPE ='P'
                And Orderid = i.orgorderid;

            Update ood
            Set  deltd ='Y'
            Where orgorderid = i.orgorderid;

            Update stschd
            Set deltd = 'Y'
            Where  orgorderid = i.orgorderid;
            -- Xu ly cho lenh thoa thuan nhom BVS
            For vc in (Select orderid
                       From odmast
                       Where grporder='Y' and  orderid= i.orgorderid)
            Loop
                cspks_seproc.pr_executeod9996(i.orgorderid,p_err_code,p_err_param);
            End loop;


            If i.bors = 'B' then
                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                -- Begin Danh sau tai san LINHLNB

                Select  afacctno into v_afaccount  from ODMAST   Where MATCHTYPE ='P' And Orderid = i.orgorderid;

                INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG, QTTY)
                VALUES( v_afaccount,i.codeid ,i.matchprice * i.matchqtty,i.txnum, i.txdate,NULL,systimestamp,i.orgorderid,'C', i.matchqtty);
                -- End Danh dau tai san LINHLNB
            End if ;
        End Loop;
        plog.debug (pkgctx, 'PRC_PROCESS3D Update odmast  successful');

        --Xu ly IOD
        Update iod
        Set Deltd ='Y'
        Where NorP ='P'
            And trim(confirm_no) =trim(V_TX3D.CONFIRM_NUMBER);
    End if; --V_TX3D.REPLY_CODE = 'A'

    plog.setendsection (pkgctx, 'PRC_PROCESS3D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESS3D V_TX3D.CONFIRM_NUMBER = ' || V_TX3D.CONFIRM_NUMBER);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS3D');
    rollback;
END PRC_PROCESS3D;

--PROCESS MSG AA - Thong tin lenh quang cao tu HO
Procedure PRC_PROCESSAA(V_MSGXML VARCHAR2) is
    V_TXAA   tx.msg_AA;
    V_Symbol    VARCHAR2(20);
    V_UpdatePrice Varchar2(10);
    v_Count Number(10);
    v_Halt  Varchar2(10);
    v_Security_Type Varchar2(10);
    v_strErrCode  Varchar2(20);
    v_strErrM Varchar2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSAA');

    V_TXAA:=fn_xml2obj_AA(V_MSGXML);

    --XU LY MESSAGE AA.
    -- Lay ma CK
    SELECT hs.code
    INTO V_Symbol
    FROM ho_sec_info hs
    WHERE hs.stock_id = V_TXAA.security_number;

    -- Neu them moi lenh quang cao
    IF V_TXAA.add_cancel_flag = 'A' THEN
    -- Insert vao bang orderptadv
        INSERT INTO orderptadv (AUTOID,TIMESTAMP,MESSAGETYPE,FIRM,TRADEID,SECURITYSYMBOL,SIDE,VOLUME,PRICE,
                              BOARD,SENDTIME,STATUS,CONTACT,OFFSET,ISSEND,ISACTIVE,
                              DELETED,REFID,BRID,TLID,IPADDRESS,ADVDATE,TOCOMPID)
        VALUES(seq_ORDERPTADV.NEXTVAL,V_TXAA.time_od,'AA',V_TXAA.firm,V_TXAA.trader,V_Symbol,V_TXAA.side,V_TXAA.volume,trim(V_TXAA.price),
        V_TXAA.board,NULL,'A',V_TXAA.contact,NULL,NULL,'N',
        'N',0,NULL,NULL,NULL,getcurrdate,NULL);
    ELSIF V_TXAA.add_cancel_flag = 'C' THEN
    -- Cap nhat trang thai lenh quang cao
        UPDATE orderptadv
        SET status = 'C',
            DELETED='Y'
        WHERE trim(contact) = trim(V_TXAA.contact)
            AND SECURITYSYMBOL = V_Symbol
            AND FIRM = V_TXAA.firm
            AND TRADEID = V_TXAA.trader
            AND VOLUME = V_TXAA.volume
            AND PRICE = V_TXAA.price;
    END IF;
    plog.setendsection (pkgctx, 'PRC_PROCESSAA');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'PRC_PROCESSAA V_TXAA.security_number = ' ||V_TXAA.security_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSAA');
    rollback;
END PRC_PROCESSAA;


FUNCTION fn_xml2obj_2B(p_xmlmsg    VARCHAR2) RETURN tx.msg_2B IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2B;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := TRIM(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2B l_txmsg.order_number: '||l_txmsg.order_number||' l_txmsg.firm ='|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2B;


FUNCTION fn_xml2obj_2C(p_xmlmsg    VARCHAR2) RETURN tx.msg_2C IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2C;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := trim(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      Elsif v_Key ='cancel_shares' Then
        l_txmsg.cancel_shares := v_Value;
      Elsif v_Key ='order_cancel_status' Then
        l_txmsg.order_cancel_status := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2C l_txmsg.order_number: '||l_txmsg.order_number||
                        ' l_txmsg.firm ='|| l_txmsg.firm ||'l_txmsg.cancel_shares ='||l_txmsg.cancel_shares);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2C;


FUNCTION fn_xml2obj_2E(p_xmlmsg    VARCHAR2) RETURN tx.msg_2E IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2E;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2E');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := TRIM(v_Value);
      Elsif v_Key ='confirm_number' Then
        l_txmsg.confirm_number := TRIM(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := v_Value;
      Elsif v_Key ='side' Then
        l_txmsg.side := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      Elsif v_Key ='filler' Then
        l_txmsg.order_entry_date := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2E l_txmsg.order_number: '||l_txmsg.order_number||' l_txmsg.confirm_number ='|| l_txmsg.confirm_number);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2E');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2E');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2E;


FUNCTION fn_xml2obj_2G(p_xmlmsg    VARCHAR2) RETURN tx.msg_2G IS
 l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2G;
    v_Key Varchar2(100);
    v_Value Varchar2(500);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2G');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='order_number'  Then
        l_txmsg.order_number := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='order_entry_date' Then
        l_txmsg.order_entry_date := v_Value;
      Elsif v_Key ='reject_reason_code' Then
        l_txmsg.reject_reason_code := v_Value;
      Elsif v_Key ='original_message_text' Then
        l_txmsg.original_message_text := v_Value;
      ELSIF v_key='msg_type' then
        l_txmsg.msg_type:=v_Value;
      ELSIF v_key='deal_id' then
        l_txmsg.deal_id:=v_Value;
      End if;


      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2G l_txmsg.order_number: '||l_txmsg.order_number||' l_txmsg.firm ='|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
End   fn_xml2obj_2G;


FUNCTION fn_xml2obj_2D(p_xmlmsg    VARCHAR2) RETURN tx.msg_2D IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2D;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2D');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='ordernumber'  Then
        l_txmsg.ordernumber := Trim(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := Trim(v_Value);
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2D l_txmsg.order_number: '||l_txmsg.ordernumber
                    ||' l_txmsg.price'|| l_txmsg.price);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2D');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2D');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2D;


FUNCTION fn_xml2obj_2I(p_xmlmsg    VARCHAR2) RETURN tx.msg_2I IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2I;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2I');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := TRIM(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := v_Value;
      Elsif v_Key ='order_number_sell' Then
        l_txmsg.order_number_sell := TRIM(v_Value);
      Elsif v_Key ='order_entry_date_sell' Then
        l_txmsg.order_entry_date_sell := TRIM(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='order_number_buy' Then
        l_txmsg.order_number_buy := v_Value;
      Elsif v_Key ='order_entry_date_buy' Then
        l_txmsg.order_entry_date_buy := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2I l_txmsg.order_number_sell: '||l_txmsg.order_number_sell
                     ||' l_txmsg.order_number_buy: '||l_txmsg.order_number_buy
                     ||' l_txmsg.confirm_number: '||l_txmsg.confirm_number);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2I');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2I');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2I;


FUNCTION fn_xml2obj_2L(p_xmlmsg    VARCHAR2) RETURN tx.msg_2L IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2L;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2L');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='price' Then
       --Format v_Price 000066500000 value: 66.5
         --l_txmsg.price := Substr(v_Value,1,6)+ To_number('0.'||Substr(v_Value,7,6));
         l_txmsg.price := TO_NUMBER(v_Value)/1000000;

      Elsif v_Key ='side' Then
        l_txmsg.side := v_Value;
      Elsif v_Key ='contra_firm' Then
        l_txmsg.contra_firm := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='deal_id' Then
        l_txmsg.deal_id := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2L l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.firm'|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2L');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2L');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2L;

FUNCTION fn_xml2obj_2F(p_xmlmsg    VARCHAR2) RETURN tx.msg_2F IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_2F;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_2F');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='firm_buy' Then
        l_txmsg.firm_buy := v_Value;
      Elsif v_Key ='price' Then
        l_txmsg.price := v_Value;
      Elsif v_Key ='side_b' Then
        l_txmsg.side_b := v_Value;
      Elsif v_Key ='volume' Then
        l_txmsg.volume := v_Value;
      Elsif v_Key ='security_symbol' Then
        l_txmsg.security_symbol := v_Value;
      Elsif v_Key ='trader_id_buy' Then
        l_txmsg.trader_id_buy := v_Value;
      Elsif v_Key ='board' Then
        l_txmsg.board := v_Value;
      Elsif v_Key ='contra_firm_sell' Then
        l_txmsg.contra_firm_sell := v_Value;
      Elsif v_Key ='trader_id_contra_side_sell' Then
        l_txmsg.trader_id_contra_side_sell := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 2F l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.contra_firm_sell'|| l_txmsg.contra_firm_sell);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_2F');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_2F');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_2F;

FUNCTION fn_xml2obj_3B(p_xmlmsg    VARCHAR2) RETURN tx.msg_3B IS
 l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_3B;
    v_Key Varchar2(100);
    v_Value Varchar2(500);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_3b');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='confirm_number'  Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='deal_id' Then
        l_txmsg.deal_id := v_Value;
      Elsif v_Key ='client_id_buyer' Then
        l_txmsg.client_id_buyer := v_Value;
      Elsif v_Key ='reply_code' Then
        l_txmsg.reply_code := v_Value;
      End if;
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 3b l_txmsg.deal_id: '||l_txmsg.deal_id||' l_txmsg.firm ='|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj');
      RAISE errnums.E_SYSTEM_ERROR;
End   fn_xml2obj_3B;

FUNCTION fn_xml2obj_3C(p_xmlmsg    VARCHAR2) RETURN tx.msg_3C IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_3C;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_3C');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='contra_firm'  Then
        l_txmsg.contra_firm := v_Value;
      Elsif v_Key ='security_symbol' Then
        l_txmsg.security_symbol := v_Value;
      Elsif v_Key ='confirm_number' Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='firm' Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='side' Then
        l_txmsg.side := v_Value;
      Elsif v_Key ='trader_id' Then
        l_txmsg.trader_id := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 3C l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.contra_firm'|| l_txmsg.contra_firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_3C');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_3C');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_3C;

  FUNCTION fn_xml2obj_SC(p_xmlmsg    VARCHAR2) RETURN tx.msg_SC IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_SC;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_SC');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='timestamp'  Then
        l_txmsg.timestamp := v_Value;
      Elsif v_Key ='system_control_code' Then
        l_txmsg.system_control_code := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg SC l_txmsg.timestamp: '||l_txmsg.timestamp
                       ||'l_txmsg.system_control_code: '||l_txmsg.system_control_code);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_SC');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_SC');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_SC;

  FUNCTION fn_xml2obj_TR(p_xmlmsg    VARCHAR2) RETURN tx.msg_TR IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_TR;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_TR');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='current_room'  Then
        l_txmsg.current_room := v_Value;
      Elsif v_Key ='security_number' Then
        l_txmsg.security_number := v_Value;
      Elsif v_Key ='total_room' Then
        l_txmsg.total_room := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg TR l_txmsg.security_number: '||l_txmsg.security_number
                       ||'l_txmsg.current_room: '||l_txmsg.current_room);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_TR');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_TR');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_TR;

  FUNCTION fn_xml2obj_GA(p_xmlmsg    VARCHAR2) RETURN tx.msg_GA IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_GA;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_GA');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='admin_message_text'  Then
        l_txmsg.admin_message_text := v_Value;
      Elsif v_Key ='admin_message_length' Then
        l_txmsg.admin_message_length := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg GA l_txmsg.admin_message_text: '||l_txmsg.admin_message_text
                       ||'l_txmsg.admin_message_length: '||l_txmsg.admin_message_length);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_GA');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_GA');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_GA;

  FUNCTION fn_xml2obj_SU(p_xmlmsg    VARCHAR2) RETURN tx.msg_SU IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_SU;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_SU');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='floor_price'  Then
        l_txmsg.floor_price := trim(v_Value);
      Elsif v_Key ='benefit' Then
        l_txmsg.benefit := trim(v_Value);
      Elsif v_Key ='ceiling_price' Then
        l_txmsg.ceiling_price := trim(v_Value);
      Elsif v_Key ='open_price' Then
        l_txmsg.open_price := trim(v_Value);
      Elsif v_Key ='security_name' Then
        l_txmsg.security_name := trim(v_Value);
      Elsif v_Key ='security_number_new' Then
        l_txmsg.security_number_new := trim(v_Value);
      Elsif v_Key ='prior_close_price' Then
        l_txmsg.prior_close_price := trim(v_Value);
      Elsif v_Key ='halt_resume_flag' Then
        l_txmsg.halt_resume_flag := trim(v_Value);
      Elsif v_Key ='notice' Then
        l_txmsg.notice := trim(v_Value);
      Elsif v_Key ='delist' Then
        l_txmsg.delist := trim(v_Value);
      Elsif v_Key ='par_value' Then
        l_txmsg.par_value := trim(v_Value);
      Elsif v_Key ='total_shares_traded' Then
        l_txmsg.total_shares_traded := trim(v_Value);
      Elsif v_Key ='security_number_old' Then
        l_txmsg.security_number_old := trim(v_Value);
      Elsif v_Key ='board_lot' Then
        l_txmsg.board_lot := trim(v_Value);
      Elsif v_Key ='highest_price' Then
        l_txmsg.highest_price := trim(v_Value);
      Elsif v_Key ='suspension' Then
        l_txmsg.suspension := trim(v_Value);
      Elsif v_Key ='sector_number' Then
        l_txmsg.sector_number := trim(v_Value);
      Elsif v_Key ='client_id_required' Then
        l_txmsg.client_id_required := trim(v_Value);
      Elsif v_Key ='sdc_flag' Then
        l_txmsg.sdc_flag := trim(v_Value);
      Elsif v_Key ='prior_close_date' Then
        l_txmsg.prior_close_date := trim(v_Value);
      Elsif v_Key ='market_id' Then
        l_txmsg.market_id := trim(v_Value);
      Elsif v_Key ='meeting' Then
        l_txmsg.meeting := trim(v_Value);
      Elsif v_Key ='filler_5' Then
        l_txmsg.filler_5 := trim(v_Value);
      Elsif v_Key ='security_symbol' Then
        l_txmsg.security_symbol := trim(v_Value);
      Elsif v_Key ='split' Then
        l_txmsg.split := trim(v_Value);
      Elsif v_Key ='filler_4' Then
        l_txmsg.filler_4 := trim(v_Value);
      Elsif v_Key ='security_type' Then
        l_txmsg.security_type := trim(v_Value);
      Elsif v_Key ='filler_3' Then
        l_txmsg.filler_3 := trim(v_Value);
      Elsif v_Key ='lowest_price' Then
        l_txmsg.lowest_price := trim(v_Value);
      Elsif v_Key ='filler_2' Then
        l_txmsg.filler_2 := trim(v_Value);
      Elsif v_Key ='filler_1' Then
        l_txmsg.filler_1 := trim(v_Value);
      Elsif v_Key ='last_sale_price' Then
        l_txmsg.last_sale_price := trim(v_Value);
      /*--Ngay 10/04/2017 CW NamTV Them thong tin ma chung quyen*/
      Elsif v_Key ='underlying_symbol' Then
        l_txmsg.underlyingsymbol := v_Value;
      Elsif v_Key ='issuer_name' Then
        l_txmsg.issuername := v_Value;
      Elsif v_Key ='covered_warrant_type' Then
        l_txmsg.coveredwarranttype := v_Value;
      Elsif v_Key ='maturity_date' Then
        l_txmsg.maturitydate := v_Value;
      Elsif v_Key ='last_trading_date' Then
        l_txmsg.lasttradingdate := v_Value;
      Elsif v_Key ='exercise_price' Then
        l_txmsg.exerciseprice := v_Value;
      Elsif v_Key ='exercise_ratio' Then
        l_txmsg.exerciseratio := v_Value;
      Elsif v_Key ='listed_share' Then
        l_txmsg.listedshare := v_Value;
      /*--NamTV End*/
      --LoLeHSX
      Elsif v_Key = 'odd_lot_halt_resume_flag' Then
        l_txmsg.odd_lot_halt_resume_flag := v_Value;
      --End LoLeHSX
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg SU l_txmsg.security_symbol: '||l_txmsg.security_symbol
                       ||'l_txmsg.ceiling_price: '||l_txmsg.ceiling_price
                       ||'l_txmsg.floor_price: '||l_txmsg.floor_price);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_SU');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_SU');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_SU;

  FUNCTION fn_xml2obj_SS(p_xmlmsg    VARCHAR2) RETURN tx.msg_SS IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_SS;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_SS');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP

      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);

      If v_Key ='board_lot'  Then
        l_txmsg.board_lot := trim(v_Value);
      Elsif v_Key ='floor_price' Then
        l_txmsg.floor_price := trim(v_Value);
      Elsif v_Key ='benefit' Then
        l_txmsg.benefit := trim(v_Value);
      Elsif v_Key ='suspension' Then
        l_txmsg.suspension := trim(v_Value);
      Elsif v_Key ='sector_number' Then
        l_txmsg.sector_number := trim(v_Value);
      Elsif v_Key ='system_control_code' Then
        l_txmsg.system_control_code := trim(v_Value);
      Elsif v_Key ='ceiling' Then
        l_txmsg.ceiling := trim(v_Value);
      Elsif v_Key ='meeting' Then
        l_txmsg.meeting := trim(v_Value);
      Elsif v_Key ='security_number' Then
        l_txmsg.security_number := trim(v_Value);
      Elsif v_Key ='filler_6' Then
        l_txmsg.filler_6 := trim(v_Value);
      Elsif v_Key ='filler_5' Then
        l_txmsg.filler_5 := trim(v_Value);
      Elsif v_Key ='prior_close_price' Then
        l_txmsg.prior_close_price := trim(v_Value);
      Elsif v_Key ='halt_resume_flag' Then
        l_txmsg.halt_resume_flag := trim(v_Value);
      Elsif v_Key ='filler_4' Then
        l_txmsg.filler_4 := trim(v_Value);
      Elsif v_Key ='split' Then
        l_txmsg.split := trim(v_Value);
      Elsif v_Key ='security_type' Then
        l_txmsg.security_type := trim(v_Value);
      Elsif v_Key ='filler_3' Then
        l_txmsg.filler_3 := trim(v_Value);
      Elsif v_Key ='delist' Then
        l_txmsg.delist := trim(v_Value);
      Elsif v_Key ='filler_2' Then
        l_txmsg.filler_2 := trim(v_Value);
      Elsif v_Key ='notice' Then
        l_txmsg.notice := trim(v_Value);
      Elsif v_Key ='filler_1' Then
        l_txmsg.filler_1 := trim(v_Value);
      /*--Ngay 10/04/2017 CW NamTV Them thong tin ma chung quyen*/
      Elsif v_Key ='underlying_symbol' Then
        l_txmsg.underlyingsymbol := v_Value;
      Elsif v_Key ='issuer_name' Then
        l_txmsg.issuername := v_Value;
      Elsif v_Key ='covered_warrant_type' Then
        l_txmsg.coveredwarranttype := v_Value;
      Elsif v_Key ='maturity_date' Then
        l_txmsg.maturitydate := v_Value;
      Elsif v_Key ='last_trading_date' Then
        l_txmsg.lasttradingdate := v_Value;
      Elsif v_Key ='exercise_price' Then
        l_txmsg.exerciseprice := v_Value;
      Elsif v_Key ='exercise_ratio' Then
        l_txmsg.exerciseratio := v_Value;
      Elsif v_Key ='listed_share' Then
        l_txmsg.listedshare := v_Value;
      /*--NamTV End*/
      --LoLeHSX
      Elsif v_Key = 'odd_lot_halt_resume_flag' Then
        l_txmsg.odd_lot_halt_resume_flag := v_Value;
      --End LoLeHSX
      End if;
    END LOOP;


    plog.debug(pkgctx,'msg SU l_txmsg.security_number: '||l_txmsg.security_number
                       ||'l_txmsg.ceiling: '||l_txmsg.ceiling
                       ||'l_txmsg.floor_price: '||l_txmsg.floor_price);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_SS');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_SS');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_SS;

  FUNCTION fn_xml2obj_TC(p_xmlmsg    VARCHAR2) RETURN tx.msg_TC IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_TC;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_TC');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='firm'  Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='trader_id' Then
        l_txmsg.trader_id := v_Value;
      Elsif v_Key ='trader_status' Then
        l_txmsg.trader_status := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg TC l_txmsg.firm: '||l_txmsg.firm
                       ||'l_txmsg.trader_id: '||l_txmsg.trader_id
                       ||'l_txmsg.trader_status: '||l_txmsg.trader_status);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_TC');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_TC');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_TC;

FUNCTION fn_xml2obj_TS(p_xmlmsg    VARCHAR2) RETURN tx.msg_TS IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_TS;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_TS');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='timestamp'  Then
        l_txmsg.timestamp := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg TS l_txmsg.timestamp: '||l_txmsg.timestamp);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_TS');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_TS');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_TS;

  FUNCTION fn_xml2obj_BS(p_xmlmsg    VARCHAR2) RETURN tx.msg_BS IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_BS;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_BS');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='firm'  Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='automatch_halt_flag' Then
        l_txmsg.automatch_halt_flag := v_Value;
      Elsif v_Key ='put_through_halt_flag' Then
        l_txmsg.put_through_halt_flag := v_Value;
      End if;

    END LOOP;


    plog.debug(pkgctx,'msg BS l_txmsg.firm: '||l_txmsg.firm
                       ||'l_txmsg.automatch_halt_flag: '||l_txmsg.automatch_halt_flag
                       ||'l_txmsg.put_through_halt_flag: '||l_txmsg.put_through_halt_flag);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_BS');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_BS');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_BS;

FUNCTION fn_xml2obj_3D(p_xmlmsg    VARCHAR2) RETURN tx.msg_3D IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_3D;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_3D');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='firm'  Then
        l_txmsg.firm := v_Value;
      Elsif v_Key ='confirm_number' Then
        l_txmsg.confirm_number := v_Value;
      Elsif v_Key ='reply_code' Then
        l_txmsg.reply_code := v_Value;
      End if;

      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild(l_node));
      --v_Key:=xmldom.getnodevalue(xmldom.getfirstchild('key'));
    END LOOP;


    plog.debug(pkgctx,'msg 3D l_txmsg.confirm_number: '||l_txmsg.confirm_number
                    ||' l_txmsg.firm'|| l_txmsg.firm);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_3D');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_3D');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_3D;

FUNCTION fn_xml2obj_AA(p_xmlmsg    VARCHAR2) RETURN tx.msg_AA IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_AA;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_AA');

    plog.debug(pkgctx,'msg length: ' || length(p_xmlmsg));
    l_parser := xmlparser.newparser();
    plog.debug(pkgctx,'1');
    xmlparser.parseclob(l_parser, p_xmlmsg);
    plog.debug(pkgctx,'2');
    l_doc := xmlparser.getdocument(l_parser);
    plog.debug(pkgctx,'3');
    xmlparser.freeparser(l_parser);

    plog.debug(pkgctx,'Prepare to parse Message Fields');

    l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc),
                                           '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

    FOR i IN 0 .. xmldom.getlength(l_nodeList) - 1 LOOP
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='time'  Then
        l_txmsg.time_od := trim(v_Value);
      Elsif v_Key ='price' Then
        l_txmsg.price := trim(v_Value);
      Elsif v_Key ='side' Then
        l_txmsg.side := trim(v_Value);
      Elsif v_Key ='firm' Then
        l_txmsg.firm := trim(v_Value);
      Elsif v_Key ='security_number' Then
        l_txmsg.security_number := trim(v_Value);
      Elsif v_Key ='volume' Then
        l_txmsg.volume := trim(v_Value);
      Elsif v_Key ='trader' Then
        l_txmsg.trader := v_Value;
      Elsif v_Key ='board' Then
        l_txmsg.board := trim(v_Value);
      Elsif v_Key ='add_cancel_flag' Then
        l_txmsg.add_cancel_flag := trim(v_Value);
      Elsif v_Key ='contact' Then
        l_txmsg.contact := trim(v_Value);
      End if;

    END LOOP;


   /* plog.debug(pkgctx,'msg TR l_txmsg.security_number: '||l_txmsg.security_number
                       ||'l_txmsg.current_room: '||l_txmsg.current_room);
    plog.debug(pkgctx,'Free resources associated');*/

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_AA');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'fn_xml2obj_AA');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_AA;


BEGIN
FOR i IN (SELECT * FROM tlogdebug) LOOP
logrow.loglevel  := i.loglevel;
logrow.log4table := i.log4table;
logrow.log4alert := i.log4alert;
logrow.log4trace := i.log4trace;
END LOOP;

pkgctx := plog.init('pck_hogw',
          plevel => NVL(logrow.loglevel,30),
          plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
          palert => (logrow.log4alert = 'Y'),
          ptrace => (logrow.log4trace = 'Y'));

END;
/
