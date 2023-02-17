SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_hagw
  IS

  PROCEDURE matching_normal_order (
   firm               IN   VARCHAR2,
   order_number       IN   VARCHAR2,
   order_entry_date   IN   VARCHAR2,
   side_alph          IN   VARCHAR2,
   filler             IN   VARCHAR2,
   deal_volume        IN   NUMBER,
   deal_price         IN   NUMBER,
   confirm_number     IN   VARCHAR2
);
  PROCEDURE confirm_cancel_normal_order (
   pv_orderid   IN   VARCHAR2,
   pv_qtty      IN   NUMBER
);

  PROCEDURE CONFIRM_REPLACE_NORMAL_ORDER (
   pv_ordernumber   IN   VARCHAR2,
   pv_qtty       IN   NUMBER,
   pv_price      IN   NUMBER,
   pv_LeavesQty IN   NUMBER
);
  Procedure Prc_Update_Security;
  FUNCTION fnc_check_sec_ha
          ( v_Symbol IN varchar2)
         RETURN  number;
  Procedure Prc_ProcessMsg;
  Procedure Prc_ProcessMsg_ex;
  Procedure PRC_PROCESS;
  Procedure PRC_PROCESS_ERR;
  FUNCTION fn_xml2obj_8(p_xmlmsg    VARCHAR2) RETURN tx.msg_8;
  Procedure PRC_PROCESS8(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_D(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_s(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_G(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_F(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_7(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_e(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_g_TT(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_B(PV_REF IN OUT PKG_REPORT.REF_CURSOR) ;
  Procedure PRC_BE(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_GETORDER(PV_REF IN OUT PKG_REPORT.REF_CURSOR, v_MsgType VARCHAR2);
  FUNCTION fn_xml2obj_s(p_xmlmsg    VARCHAR2) RETURN tx.msg_s;
  FUNCTION fn_xml2obj_u(p_xmlmsg    VARCHAR2) RETURN tx.msg_u;
  FUNCTION fn_xml2obj_7(p_xmlmsg    VARCHAR2) RETURN tx.msg_7;
  FUNCTION fn_xml2obj_3(p_xmlmsg    VARCHAR2) RETURN tx.msg_3;
  FUNCTION fn_xml2obj_BF(p_xmlmsg    VARCHAR2) RETURN tx.msg_BF;
  FUNCTION fn_xml2obj_f(p_xmlmsg    VARCHAR2) RETURN tx.msg_f;
  FUNCTION fn_xml2obj_h(p_xmlmsg    VARCHAR2) RETURN tx.msg_h;
  FUNCTION fn_xml2obj_B(p_xmlmsg    VARCHAR2) RETURN tx.msg_B ;
  Procedure PRC_PROCESS7(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESS3(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSBF(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSf(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSs(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSh(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSu(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSB(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_PROCESSA(V_MSGXML VARCHAR2, v_ID Varchar2);
  Procedure PRC_u(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
  Procedure PRC_t(PV_REF IN OUT PKG_REPORT.REF_CURSOR);
END; -- Package spec
 
/


CREATE OR REPLACE PACKAGE BODY pck_hagw
IS
    pkgctx plog.log_ctx;
    logrow tlogdebug%ROWTYPE;
    v_CheckProcess Boolean;
--LAY MESSAGE DAY LEN GW.
Procedure PRC_GETORDER(PV_REF IN OUT PKG_REPORT.REF_CURSOR, v_MsgType VARCHAR2) is
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_GETORDER');
    IF v_MsgType ='D' THEN
        PRC_D(PV_REF);
    ELSIF v_MsgType ='G' THEN
        PRC_G(PV_REF);
    ELSIF v_MsgType ='F' THEN
        PRC_F(PV_REF);
    ELSIF v_MsgType ='e' THEN
        PRC_e(PV_REF);
    ELSIF v_MsgType ='7' THEN
        PRC_7(PV_REF);
    ELSIF v_MsgType ='g' THEN
        PRC_g_TT(PV_REF);
    ELSIF v_MsgType ='s' THEN
        PRC_s(PV_REF);
    ELSIF v_MsgType ='u' THEN
        PRC_u(PV_REF);
    ELSIF v_MsgType ='t' THEN
        PRC_t(PV_REF);
    ELSIF v_MsgType ='B' THEN
            PRC_B(PV_REF);
    ELSIF v_MsgType ='BE' THEN--HNX_update
        PRC_BE(PV_REF);
    Else--HNX_update
        Open PV_REF For
        Select  v_MsgType MSGTYPE, 'Hello' TEXT
        From  dual
        Where 1>2;
    END IF;
    plog.setendsection (pkgctx, 'PRC_GETORDER');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx, 'HAGW-PRC_GETORDER SQLERRM v_MsgType = '||v_MsgType);
    plog.setendsection (pkgctx, 'PRC_GETORDER');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_GETORDER;

--Day message lenh thong thuong D len Gw
Procedure PRC_D(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_Order_Number varchar2(10);
    v_Count_Order Number;


    CURSOR C_D IS
    SELECT  ORDERID ORDERID, 'New Single Order' Text,CUSTODYCD Account,
        CASE
        WHEN  SUBSTR(CUSTODYCD,4,1) = 'A' OR SUBSTR(CUSTODYCD,4,1) ='B' THEN '3'
        WHEN  SUBSTR(CUSTODYCD,4,1) ='E' OR SUBSTR(CUSTODYCD,4,1) ='F' THEN '4'
        WHEN  SUBSTR(CUSTODYCD,4,1) ='P' THEN '1'
        ELSE  '2' END AccountType,
        QUOTEPRICE Price,ORDERQTTY OrderQty,SYMBOL Symbol,
        decode(BORS,'B','1','S','2') Side,
        CASE
        WHEN  PriceType ='LO' THEN '2'
        WHEN  PriceType ='SO<' THEN '3'
        WHEN  PriceType ='SO>' THEN '4'
        WHEN  PriceType ='ATC' THEN '5'
        WHEN  PriceType ='ATO' THEN '6'
        WHEN  PriceType ='IO' THEN 'I'
        WHEN  PriceType ='MOK' THEN 'K'
        WHEN  PriceType ='MAK' THEN 'A'
        WHEN  PriceType ='SBO' THEN 'S'
        WHEN  PriceType ='OBO' THEN 'O'
        WHEN  PriceType ='MTL' THEN 'T'
        WHEN  PriceType ='OBO' THEN 'O'
        WHEN  PriceType ='PLO' THEN 'C'
        WHEN  PriceType ='PT' THEN 'P'
        END OrdType,
        CODEID,BORS,
        QUOTEQTTY OrderQty2,
        LimitPrice StopPx,
        Sendnum
    FROM    send_order_to_ha;
--    WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HASENDSIZE') ;


    Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2,v_strTRADEBUYSELLPT varchar2) is
                   SELECT ORGORDERID FROM ood o , odmast od
                   WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                         And o.bors <> v_BorS
                         And od.remainqtty >0
                         And od.deltd<>'Y'
                         AND od.EXECTYPE in ('NB','NS','MS')
                         And o.oodstatus in ('B','S')
                         AND NVL(od.hosesession,'N') IN ('CLOSE','CLOSE_BL')
                         and (v_strTRADEBUYSELLPT='N'
                                  or (v_strTRADEBUYSELLPT='Y' and od.matchtype <>'P'));
    Cursor C_Send_Size is SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HASENDSIZE';
    v_Send_Size  Number;
    l_controlcode varchar2(20);
    l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_D');
    --THEM
    Open C_Send_Size;
    Fetch C_Send_Size Into v_Send_Size;
    If C_Send_Size%notfound Then
     v_Send_Size:=100;
    End if;
    Close C_Send_Size;

    -- THEM
    v_Count_Order:=0;
    Begin
            Select VARVALUE into v_strSysCheckBuySell from sysvar where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
        Exception When OTHERS Then
            v_strSysCheckBuySell:='N';
    End;

    Begin
          Select VARVALUE Into l_strTRADEBUYSELLPT
          From sysvar
          Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELLPT' ;
    EXCEPTION when OTHERS Then
            l_strTRADEBUYSELLPT:='N';
    End;

    FOR I IN C_D
    LOOP
            BEGIN
                SAVEPOINT sp#2;

                --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
                v_Check:=False;
                l_controlcode:=fn_get_controlcode(i.SYMBOL);
                If v_strSysCheckBuySell ='N' and  l_controlcode  in ('CLOSE','CLOSE_BL')  Then
                    Open c_Check_Doiung(I.BORS, I.Account,I.CODEID,l_strTRADEBUYSELLPT);
                    Fetch c_Check_Doiung into v_Temp;
                       If c_Check_Doiung%found then
                        v_Check:=True;
                       End if;
                    Close c_Check_Doiung;
                End if;
                IF Not v_Check THEN
                    SELECT seq_ordermap.NEXTVAL Into v_Order_Number From dual;

                    INSERT INTO ha_d
                        (Msgtype,text, ACCOUNT, accounttype, symbol, orderqty, side,
                         clordid, ordtype, price, orderid, date_time, status,OrderQty2,StopPx,sendnum
                        )
                    VALUES ('D',I.text, I.ACCOUNT, I.accounttype, I.symbol, I.orderqty, I.side,
                         v_Order_Number, I.ordtype, I.price, I.orderid, Sysdate, 'N',I.OrderQty2,I.StopPx,I.sendnum
                        );
                    --XU LY LENH THUONG D
                    --1.1DAY VAO ORDERMAP.
                    INSERT INTO ORDERMAP_HA(ctci_order,orgorderid) VALUES (v_Order_Number,I.orderid);
                    --1.2 CAP NHAT OOD.
                    UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
                    UPDATE ODMAST SET hosesession= l_controlcode WHERE ORDERID=I.orderid;
                    --1.3 DAY LENH VAO ODQUEUE
                    INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;

                    v_Count_Order:=v_Count_Order+1;
                End If;
            EXCEPTION WHEN OTHERS THEN
                plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
                ROLLBACK TO SAVEPOINT sp#2;
            END;
            Exit WHEN v_Count_Order >= v_Send_Size;
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        MsgType,
        TEXT TEXT,
        ACCOUNT ACCOUNT,
        ACCOUNTTYPE ACCOUNTTYPE,
        SYMBOL SYMBOL,
        ORDERQTY ORDERQTY,
        SIDE SIDE,
        CLORDID CLORDID,
        ORDTYPE ORDTYPE,
        PRICE PRICE,
        OrderQty2,
        Stoppx,
        orderid||Sendnum BOorderID
    FROM ha_D WHERE STATUS ='N'
    Order by to_number(clordid);
    --Cap nhat trang thai bang tam ra GW.
    UPDATE HA_D SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';

    plog.setendsection (pkgctx, 'PRC_D');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_D');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_D;



--Day message lenh sua G len Gw
Procedure PRC_G(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is
    CURSOR C_G IS
    SELECT  seq_ordermap.NEXTVAL ClOrdID,
        ORDER_NUMBER OrigClOrdID,
        ORDERID,
        'Order Replace Request' Text,
        QUOTEPRICE Price,
        ORDERQTTY,
        CashOrderQty,
        OrderQty2,
        StopPx,
        Symbol,
        sendnum
    FROM
        (SELECT
            ODM.order_number,
            A.ORGORDERID ORDERID,
            A.SYMBOL ,
            E.QUOTEPRICE QUOTEPRICE,
            C.ORDERQTTY - C.EXECQTTY ORDERQTTY,
            E.orderqtty - C.EXECQTTY CashOrderQty,
            E.QUOTEQTTY OrderQty2,
            E.Limitprice StopPx,
            A.sendnum
        FROM
            OOD A,
            SBSECURITIES B,
            ODMAST C,-- LENH GOC
            ODMAST E, -- LENH SUA
            SECURITIES_INFO L,
            ORDERMAP_HA ODM
        WHERE
            A.CODEID = B.CODEID
            AND B.CODEID = L.CODEID
            AND B.tradeplace IN ('002','005')
            AND A.ORGORDERID = E.ORDERID
            AND E.REFORDERID=C.ORDERID
            AND E.REFORDERID=ODM.ORGORDERID
            AND E.quoteprice <= l.ceilingprice
            AND E.quoteprice >= l.floorprice
            AND A.OODSTATUS IN ('N')
            AND E.ORSTATUS NOT IN ('0')
            AND E.exectype IN ('AB','AS')
            AND C.ORSTATUS NOT IN ('3','0','6','8')
            AND C.MATCHTYPE ='N'
            AND C.REMAINQTTY >0
            AND C.DELTD <> 'Y'
            AND C.pricetype in ('LO','MTL')
            AND ODM.order_number is not null
            AND
            (
                (
                       B.TRADEPLACE='002'
                      AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='CONTROLCODE') ='1'
                      AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='TRADINGID') in ('CONT')
                 )
                  Or
                 (
                       B.TRADEPLACE='005'
                      AND (SELECT SYSVALUE FROM ORDERSYS_UPCOM WHERE SYSNAME='CONTROLCODE') ='1'
                      AND (SELECT SYSVALUE FROM ORDERSYS_UPCOM WHERE SYSNAME='TRADINGID') in ('CONTUP')
                 )
            )
        )
    WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HASENDSIZE');

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_G');
    FOR I IN C_G
    LOOP
        INSERT INTO ha_g
        (Msgtype, text, clordid, origclordid, price, orderid, date_time,
         status,CashOrderQty, OrderQty2, StopPx,Symbol, orderqty,sendnum
        )
        VALUES ('G',I.text, I.clordid, I.origclordid, I.price, I.orderid, sysdate,
         'N',I.CashOrderQty, I.OrderQty2, I.StopPx,I.Symbol, I.ORDERQTTY,i.sendnum
        );
        --XU LY LENH SUA G
        --1.1DAY VAO ORDERMAP.
        INSERT INTO ORDERMAP_HA(ctci_order,orgorderid) VALUES (I.clordid,I.orderid);
        --1.2 CAP NHAT OOD.
        UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
        --1.3 DAY LENH VAO ODQUEUE
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        Msgtype,
        TEXT TEXT,
        CLORDID CLORDID,
        ORIGCLORDID ORIGCLORDID,
        PRICE PRICE,
        decode(Orderqty,CashOrderQty,'',CashOrderQty) CashOrderQty,
        decode(Orderqty,CashOrderQty,'',Orderqty) Orderqty,
        '' OrderQty2,
        '' StopPx,
        Symbol,
        orderid||sendnum BOORDERID
    FROM ha_G WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ha_G SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_G');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_G');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_G;

Procedure PRC_B(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

  BEGIN
      plog.setbeginsection (pkgctx, 'PRC_B');
   --LAY DU LIEU RA GW.
   OPEN PV_REF FOR
        Select 'B' msgtype, Urgency, HeadLine, Text,LinesOfText --edit 20151007
        From HA_B
        Where status ='N' AND ptype = 'O'; --Edit 20151007

   --Cap nhat trang thai .
   UPDATE HA_B SET Status = 'S', SendingTime =  TO_CHAR(SYSDATE,'HH24:MM:SS') WHERE STATUS ='N';
   plog.setendsection (pkgctx, 'PRC_B');

  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_B');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_B;


--Day message lenh huy F len Gw
Procedure PRC_F(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is
    CURSOR C_F IS
    SELECT
        seq_ordermap.NEXTVAL ClOrdID,
        ORDER_NUMBER OrigClOrdID,
        ORDERID,
        'Order Cancel Request' Text,
        Symbol,
        sendnum
    FROM
        (SELECT
            A.ORGORDERID ORDERID,
            A.SYMBOL ,
            ODM.ORDER_NUMBER,
            a.sendnum
        FROM
            OOD A,
            SBSECURITIES B,
            ODMAST C,-- LENH GOC
            ODMAST E, -- LENH HUY
            ORDERMAP_HA ODM
        WHERE
            A.CODEID = B.CODEID
            AND A.ORGORDERID = E.ORDERID
            AND E.REFORDERID=C.ORDERID
            AND E.REFORDERID=ODM.ORGORDERID
            AND A.OODSTATUS = 'N'
            AND B.TRADEPLACE IN('002','005')
            AND E.ORSTATUS NOT IN ('0')
            AND E.EXECTYPE IN ('CB','CS')
            AND C.ORSTATUS NOT IN ('3','0','6','8')
            AND C.MATCHTYPE ='N'
            AND C.REMAINQTTY >0
            AND C.DELTD <> 'Y'
            AND C.pricetype in ('LO','MTL','ATC')
            AND ODM.order_number is not null
            AND
            (
                 (
                         B.TRADEPLACE='002'
                      AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='CONTROLCODE') ='1'
                      AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='TRADINGID') in ('CONT')
                 )
                 or
                 (
                        B.TRADEPLACE='005'
                      AND (SELECT SYSVALUE FROM ORDERSYS_UPCOM WHERE SYSNAME='CONTROLCODE') ='1'
                      AND (SELECT SYSVALUE FROM ORDERSYS_UPCOM WHERE SYSNAME='TRADINGID') in ('CONTUP')
                 )
            )
        )
    WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HASENDSIZE');

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_F');
    FOR I IN C_F
    LOOP
        INSERT INTO ha_f
            (Msgtype,text, clordid, origclordid, orderid, date_time, status,symbol,sendnum
            )
        VALUES ('F',I.text, I.clordid, I.origclordid, I.orderid, Sysdate, 'N',I.symbol,i.sendnum
            );
        --XU LY LENH HUY F
        --1.1DAY VAO ORDERMAP.
        INSERT INTO ORDERMAP_HA(ctci_order,orgorderid) VALUES (I.clordid,I.orderid);
        --1.2 CAP NHAT OOD.
        UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
        --1.3 DAY LENH VAO ODQUEUE
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        Msgtype,
        TEXT TEXT,
        CLORDID CLORDID,
        ORIGCLORDID ORIGCLORDID,
        Symbol,
        orderid||sendnum BOORDERID
    FROM ha_F WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ha_F SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_F');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_F');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_F;
-------------------------------------------
--Day message lenh thoa thuan len Gw
-------------------------------------------
Procedure PRC_s(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_dblCTCI_order VARCHAR2(30);
    v_DblODQUEUE NUMBER;

    CURSOR C_s IS
    SELECT
        Decode(CrossID,'0',to_char( seq_ordermap.NEXTVAL),CrossID) CrossID,
        ORDERID,
        CrossType CrossType,
        '2' NoSides,
        '2' SellSide,
        FIRM SellPartyID,
        SCLIENTID SellAccount,
        ORDERQTTY SellOrderQty,
        CASE WHEN  SCUSTODIAN = 'A' OR SCUSTODIAN ='B' THEN '3'
            WHEN  SCUSTODIAN ='E' OR SCUSTODIAN ='F' THEN '4'
            WHEN  SCUSTODIAN ='P' THEN '1'
            ELSE  '2'
        END SellAccountType,
        '1' BuySide,
        CONTRAFIRM BuyPartyID,
        BCLIENTID BuyAccount,
        ORDERQTTY BuyOrderQty,
        CASE WHEN  BCUSTODIAN = 'A' OR BCUSTODIAN ='B' THEN '3'
            WHEN  BCUSTODIAN ='E' OR BCUSTODIAN ='F' THEN '4'
            WHEN  BCUSTODIAN ='P' THEN '1'
            ELSE  '2'
        END BuyAccountType,
        SYMBOL Symbol,
        QUOTEPRICE Price,
        codeid,
        BORDERID,
        SENDNUM
    FROM
        (Select
            NVL(advidref,'0') CrossID,
            Decode(NVL(advidref,'0'),'0','1','8') CrossType,
            ORDERID,
            FIRM,
            SCLIENTID,
            ORDERQTTY,
            SCUSTODIAN,
            CONTRAFIRM,
            BCLIENTID,
            BCUSTODIAN,
            Symbol,
            QUOTEPRICE,
            codeid,
            '' BORDERID,
            sendnum
        From send_2firm_pt_order_to_ha
        UNION ALL
        Select
            NVL(advidref,'0') CrossID,
            Decode(NVL(advidref,'0'),'0','1','8') CrossType,
            ORDERID,
            FIRM,
            SCLIENTID,
            ORDERQTTY,
            SCUSTODIAN,
            FIRM CONTRAFIRM,
            BCLIENTID,
            BCUSTODIAN,
            SYMBOL,
            QUOTEPRICE,
            codeid,
            BORDERID,
            sendnum
        From send_putthrough_order_to_HA
        Union All
        SELECT
            confirmnumber CrossID,
            Decode(A.STATUS,'A','5','C','6') CrossType,
            ORDERID,
            SELLERCONTRAFIRM FIRM ,
            SCLIENTID,
            C.QTTY ORDERQTTY,
            Substr(SCLIENTID,4,1) SCUSTODIAN,
            FIRM CONTRAFIRM,
            C.CUSTODYCD BCLIENTID
            ,Substr(C.CUSTODYCD,4,1) BCUSTODIAN,
            securitysymbol SYMBOL,
            QUOTEPRICE,
            b.codeid,
            '' BORDERID,
            c.sendnum
        FROM
            ORDERPTACK A,
            ODMAST B,
            OOD C,
            SBSECURITIES S
        WHERE A.STATUS IN ('A') --('A','C') --23/12/2021: Tach boc xu ly tu choi lenh mua
        AND A.CONFIRMNUMBER=B.CONFIRM_NO AND B.ORDERID=C.ORGORDERID
        AND B.DELTD <>'Y' AND A.ISSEND <>'Y' AND C.symbol =s.symbol and s.tradeplace IN ('002','005')
        --23/12/2021: Tach boc xu ly tu choi lenh mua
        union all
        SELECT
            confirmnumber CrossID,
            Decode(A.STATUS,'A','5','C','6') CrossType,
            confirmnumber ORDERID,
            SELLERCONTRAFIRM FIRM ,
            SCLIENTID,
            to_number(volume) ORDERQTTY,
            Substr(SCLIENTID,4,1) SCUSTODIAN,
            FIRM CONTRAFIRM
            ,'' BCLIENTID
           ,'' BCUSTODIAN
           ,securitysymbol SYMBOL,
            to_number(price) QUOTEPRICE,
            s.codeid,
            '' BORDERID,
            0 sendnum
        FROM
            ORDERPTACK A,
            SBSECURITIES S
        WHERE A.STATUS IN ('C') and a.side = 'B' --tu choi lenh mua cua khach hang
        AND A.ISSEND <>'Y'
        AND a.securitysymbol = s.symbol
        and s.tradeplace IN ('002','005')
        --End 23/12/2021: Tach boc xu ly tu choi lenh mua
        )
    WHERE ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HASENDSIZE')
    --Begin HNX_update |iss 1641
        and  SYMBOL In (
                  Select hr.SYMBOL from  hasecurity_req HR,sbsecurities sb ,ha_brd hb
                       /*(
                        Select '002'||sysvalue sysvalue from ordersys_ha where sysname ='TRADINGID'
                        union all
                        Select '005'||sysvalue sysvalue from ordersys_upcom  where sysname ='TRADINGID'
                        )b*/
                        where hr.symbol=sb.symbol
                        AND hb.BRD_CODE = hr.tradingsessionsubid
                        --and   sb.tradeplace||a.TradingSessionID = b.sysvalue --HNX_update|iss 1641
                        AND( (HR.SECURITYTRADINGSTATUS in ('17','24','25','26','28')
                                      AND hb.TRADSESSTATUS ='1')
                              OR    --ma = 1, 27 theo co bang va co ma
                              (HR.SECURITYTRADINGSTATUS in ('1','27')
                                     AND hb.TRADSESSTATUS ='1'
                                      AND hr.TRADSESSTATUS ='1'
                                      AND hb.TRADINGSESSIONID= hr.TradingSessionID )
                             )
                        )

    --end  HNX_update |iss 1641

        and INSTR((select inperiod from msgmast_ha where msgtype ='s'),
         (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='CONTROLCODE')) >0;



    Cursor c_Check_Doiung(v_BorS Varchar2, v_Custodycd Varchar2,v_Codeid Varchar2) is
               SELECT ORGORDERID FROM ood o , odmast od
               WHERE o.orgorderid = od.orderid and o.custodycd =v_Custodycd and o.codeid=v_Codeid
                     And o.bors <> v_BorS
                     And od.remainqtty >0
                     AND od.EXECTYPE in ('NB','NS','MS')
                     And o.oodstatus in ('B','S');

    l_strTRADEBUYSELLPT  VARCHAR2(10); -- Y Thi cho phep dat lenh thoa thuan doi ung
    l_controlcode varchar2(20);
BEGIN

    plog.setbeginsection (pkgctx, 'PRC_s');
    Begin
        Select VARVALUE into v_strSysCheckBuySell
        From sysvar
        Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELL';
        Exception When OTHERS Then
            v_strSysCheckBuySell:='N';
    End;
    Begin
        Select VARVALUE Into l_strTRADEBUYSELLPT
        From sysvar
        Where GRNAME ='SYSTEM' and VARNAME ='TRADEBUYSELLPT' ;
        EXCEPTION when OTHERS Then
           l_strTRADEBUYSELLPT:='N';
    End;

    FOR I IN C_s
    LOOP

        --Kiem tra neu co lenh doi ung Block, Sent chua khop het thi khong day len GW.
        --Sysvar ko cho BuySell thi check doi ung.
        v_Check:=False;
        l_controlcode :=fn_get_controlcode(i.SYMBOL);

        If v_strSysCheckBuySell ='N' and  l_controlcode in ('CLOSE','CLOSE_BL') and l_strTRADEBUYSELLPT='N' Then
             Open c_Check_Doiung('S', I.SellAccount,I.CODEID);
             Fetch c_Check_Doiung into v_Temp;
               If c_Check_Doiung%found then
                v_Check:=True;
               End if;
             Close c_Check_Doiung;

             If Not v_Check Then
                 Open c_Check_Doiung('B', I.BuyAccount,I.CODEID);
                 Fetch c_Check_Doiung into v_Temp;
                   If c_Check_Doiung%found then
                    v_Check:=True;
                   End if;
                 Close c_Check_Doiung;
             End if;
        End if;



        IF Not v_Check  THEN

            INSERT INTO ha_s
                (msgtype,crossid, sellaccount, sellaccounttype, symbol,
                 sellorderqty, sellpartyid, price, crosstype, nosides,
                 sellside, buyside, buypartyid, buyaccount, buyorderqty,
                 buyaccounttype, orderid, date_time, status,sendnum
                )
            VALUES ('s',I.crossid, I.sellaccount, I.sellaccounttype, I.symbol,
                 I.sellorderqty, I.sellpartyid, I.price, I.crosstype, I.nosides,
                 I.sellside, I.buyside, I.buypartyid, NVL(I.buyaccount,I.buypartyid||'C000001'), I.buyorderqty,
                 I.buyaccounttype, I.orderid, sysdate, 'N',i.sendnum
                );

            --XU LY LENH THOA THUAN
            --1.1DAY VAO ORDERMAP.
            INSERT INTO ORDERMAP_HA(ctci_order,orgorderid, order_number) VALUES (I.crossid,I.orderid,I.crossid);
            --1.2 CAP NHAT OOD.
            UPDATE OOD SET OODSTATUS='B' WHERE ORGORDERID=I.orderid;
            UPDATE ODMAST SET hosesession= l_controlcode WHERE ORDERID=I.orderid;
            --1.3 DAY LENH VAO ODQUEUE
            INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID = I.orderid;
            --1.4 Cap nhat trang thai la da confirm
            UPDATE ORDERPTACK SET ISSEND='Y' WHERE  trim(CONFIRMNUMBER)=trim(I.crossid);

        END IF ;
        -- END IF;
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        '0' CrossPrioritization,
        '1' SettlType,
        crossid SellClOrdID,
        NVL(v_dblCTCI_order,crossid) BuyClOrdID,
        --'1' SellNoPartyIDs,
        '1|448|sellpartyid'  SellNoPartyIDs,
        SellPartyID sellpartyid_0PartyID,
        --'1' BuyNoPartyIDs,
        '1|448|buypartyid'  BuyNoPartyIDs,
        BuyPartyID buypartyid_0PartyID,
        CrossID CrossID,
        SellAccount SellAccount,
        SellAccountType SellAccountType,
        Symbol Symbol,
        SellOrderQty SellOrderQty,
        Price Price,
        CrossType CrossType,
        --NoSides NoSides,
        SellSide SellSide,
        BuySide BuySide,
        BuyAccount BuyAccount,
        BuyOrderQty BuyOrderQty,
        BuyAccountType BuyAccountType,
        Msgtype,
        orderid||sendnum BOORDERID
    FROM Ha_s WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE HA_s SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_s');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_s');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_s;



--Day message sua lenh thoa thuan len Gw
Procedure PRC_t(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);
    v_Temp VARCHAR2(30);
    v_Check BOOLEAN;
    v_strSysCheckBuySell VARCHAR2(30);
    v_dblCTCI_order VARCHAR2(30);


    CURSOR C_t IS

    Select a.confirmnumber crossid, i1.custodycd sellaccount,
    CASE WHEN  substr(i1.custodycd,4,1) = 'A' OR substr(i1.custodycd,4,1) ='B' THEN '3'
      WHEN  substr(i1.custodycd,4,1) = 'E' OR substr(i1.custodycd,4,1) ='F' THEN '4'
      WHEN  substr(i1.custodycd,4,1) = 'P' THEN '1'
      ELSE  '2' END SellAccountType, i1.symbol,  a.orderqty sellorderqty, a.contrafirm sellpartyid,
      a.price,  '1'  crosstype, '' nosides, '' sellside,  '' buyside,
      a.firm buypartyid, i2.custodycd buyaccount,
    CASE WHEN  substr(i2.custodycd,4,1) = 'A' OR substr(i2.custodycd,4,1) ='B' THEN '3'
      WHEN  substr(i2.custodycd,4,1) = 'E' OR substr(i2.custodycd,4,1) ='F' THEN '4'
      WHEN  substr(i2.custodycd,4,1) = 'P' THEN '1'
      ELSE  '2' END buyaccounttype, od.orderid orderid, sysdate,a.orderqty buyorderqty, 't', a.price  quoteprice, a.contrafirm ,
      a.firm, a.confirmnumber,'N' status , 't' msgtype
    from   adjustorderptack a, iod i1, iod i2, odmast od
    where A.ordernumber =i1.orgorderid
    and A.ordernumber =od.orderid
    and i1.bors ='S'
    and i2.bors(+) ='B'
    and a.confirmnumber =i2.confirm_no(+) and a.status ='N';-- and a.isconfirm ='Y';

BEGIN

    plog.setbeginsection (pkgctx, 'PRC_t');
    FOR i IN C_t
    LOOP
          INSERT INTO ha_t (clordid,crossid, sellaccount, sellaccounttype,  symbol,  sellorderqty, sellpartyid,
                      price,   crosstype,  nosides, sellside,  buyside,
                      buypartyid, buyaccount, buyorderqty, buyaccounttype,
                      orderid, date_time, msgtype, quoteprice,contrafirm,
                      firm, confirmnumber, status)
                VALUES (seq_ordermap.NEXTVAL , i.crossid,
                      i.sellaccount,
                      i.sellaccounttype,
                      i.symbol,
                      i.sellorderqty,
                      i.sellpartyid,
                      i.price,
                      i.crosstype,
                      i.nosides,
                      i.sellside,
                      i.buyside,
                      i.buypartyid,
                      i.buyaccount,
                      i.buyorderqty,
                      i.buyaccounttype,
                      i.orderid,
                      sysdate,
                      't',
                      i.quoteprice,
                      i.contrafirm,
                      i.firm,
                      i.confirmnumber,
                      i.status
                    );

        --1.4 Cap nhat trang thai la da confirm
        UPDATE Adjustorderptack SET STATUS='Y' WHERE  trim(CONFIRMNUMBER)=trim(I.crossid);
    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT  msgtype, clordid buyClOrdID, clordid sellClOrdID,orderid,CONFIRMNUMBER CrossID, CONFIRMNUMBER OrigCrossID ,
        '1' CrossType, '0' CrossPrioritization, --'2' NoSides, '2' NoPartyIDs,
        '1|448|sellpartyid'  SellNoPartyIDs,
        sellpartyid sellpartyid_0PartyID,
        '1|448|buypartyid'  BuyNoPartyIDs,
        buypartyid buypartyid_0PartyID,
        '2' SellSide,
        Sellaccount SellAccount,
        '2' SellAccountType,
        sellorderqty SellOrderQty,
        '1' BuySide,
        Buyaccount BuyAccount,
        Buyorderqty BuyOrderQty,
        '2'  BuyAccountType,
        SYMBOL Symbol,
        PRICE Price
    FROM    ha_t
    Where status ='N' ;
    --Cap nhat trang thai bang tam ra GW.
    UPDATE HA_t SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_t');

EXCEPTION WHEN OTHERS THEN
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection (pkgctx, 'PRC_t');
RAISE errnums.E_SYSTEM_ERROR;
END PRC_t;

--Day message huy lenh thoa thuan len Gw
Procedure PRC_u(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

    CURSOR C_u IS
    SELECT seq_ordermap.NEXTVAL CrossID,CrossType,OrigCrossID,SECURITYSYMBOL,SIDE
    FROM
    (
        SELECT '1' CrossType, CONFIRMNUMBER OrigCrossID,SECURITYSYMBOL SECURITYSYMBOL,SIDE SIDE
        FROM CANCELORDERPTACK c, Sbsecurities sb
        WHERE SORR='S'
            AND c.MESSAGETYPE='3C' AND c.STATUS='N' AND c.ISCONFIRM='N'
            and c.securitysymbol =sb.symbol and sb.tradeplace in ('002','005')
        Union all
        SELECT '7' CrossType, order_number OrigCrossID,to_char(symbol) SECURITYSYMBOL,bors SIDE
        FROM ordermap_ha o, ood
        where o.orgorderid =ood.orgorderid and ood.oodstatus ='B'
            and NORP ='P' and order_number is not null
            and o.rejectcode  ='N'
        Union all
        SELECT CrossType, OrigCrossID OrigCrossID,SECURITYSYMBOL SECURITYSYMBOL, SIDE
        From orderptack_delt where issend <> 'Y'
        Union all
        SELECT Decode(c.status,'A','5','6') CrossType, CONFIRMNUMBER OrigCrossID,SECURITYSYMBOL SECURITYSYMBOL,SIDE SIDE
        FROM CANCELORDERPTACK c, Sbsecurities sb
        WHERE SORR='R'
            AND c.MESSAGETYPE='u' AND c.status IN ('A','C') AND c.ISCONFIRM ='N'
            and c.securitysymbol =sb.symbol and sb.tradeplace in ('002','005')
    );

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_u');
    FOR I IN C_u
    LOOP
        INSERT INTO ha_u
        (msgtype,crossid, crosstype, origcrossid, date_time, status,symbol
        )
        VALUES ('u',i.crossid, i.crosstype, i.origcrossid, sysdate, 'N',i.securitysymbol
        );

        --XU LY LENH THOA THUAN
        UPDATE CANCELORDERPTACK SET ISCONFIRM='S' WHERE MESSAGETYPE='3C' AND SORR='S' AND CONFIRMNUMBER=i.OrigCrossID;
        UPDATE CANCELORDERPTACK SET ISCONFIRM='S' WHERE MESSAGETYPE='u' AND SORR='R' AND CONFIRMNUMBER=i.OrigCrossID;
        Update ordermap_ha set REJECTCODE ='Y' where order_number=i.OrigCrossID;

        --Temp_ xoa lenh thoa thuan tu xa chua thuc hien
        Update orderptack_delt set ISSEND ='Y' where ORIGCROSSID =i.OrigCrossID;


    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        Msgtype,
        CrossID CrossID,
        CrossType CrossType,
        OrigCrossID OrigCrossID,
        symbol symbol
    FROM Ha_u
    WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE Ha_u SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_u');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_u');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_u;


--Day message lenh quang cao len Gw
Procedure PRC_7(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

v_err VARCHAR2(200);

CURSOR C_7 IS
    Select AdvId,AdvRefId,
    AdvSide, Text,Quantity, AdvTransType,
    SYMBOL,DeliverToCompID,PRICE
    from (
        Select AutoID AdvId,ADVID AdvRefId,
            ADVSIDE AdvSide, Text Text,QUANTITY Quantity, 'C' AdvTransType,
            SYMBOL SYMBOL,DeliverToCompID DeliverToCompID,to_number(PRICE) PRICE
        From haput_ad_delt where issend <> 'Y'
        Union all
        SELECT A.AutoID AdvId, NVL(O.orDer_NUMBer,'') AdvRefId,
            A.SIDE AdvSide,
            A.CONTACT Text,A.VOLUME Quantity,
            Decode(A.STATUS,'A','N','C','C') AdvTransType,
            A.SECURITYSYMBOL Symbol,
            NVL(A.TOCOMPID,'0') DeliverToCompID,
            A.PRICE * se.TRADEUNIT Price
        from ORDERPTADV A,sbsecurities s,securities_info se,ORDERPTADV B, orDerMAP_HA O
        where Trim(a.securitysymbol) =Trim(se.SYMBOL)
            and s.codeid =se.codeid
            And s.tradeplace ='002'
            And A.DELETED <> 'Y' AND A.ISSEND='N' AND A.ISACTIVE='Y'
            And A.refid =B.autoid(+)
            AND O.ctci_order(+)  = TO_CHar(B.autoid)
    )
    Where PCK_HAGW.fnc_check_sec_ha(SYMBOL)  <> '0'
    and INSTR((select inperiod from msgmast_ha where msgtype ='7'),
    (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='CONTROLCODE')) >0;

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_7');
    FOR I IN C_7
    LOOP
        INSERT INTO ha_7
        (msgtype,text, advid, advside, quantity, advtranstype, symbol,
         delivertocompid, price, advrefid, date_time, status
        )
        VALUES ('7',I.text, I.advid, I.advside, I.quantity, I.advtranstype, I.symbol,
         I.delivertocompid, I.price, I.advrefid, Sysdate, 'N'
        );
        --XU LY LENH SUA 7
        --1.1
        UPDATE ORDERPTADV SET ISSEND='Y' WHERE AUTOID =I.advid;
        --1.2
        INSERT INTO ORDERMAP_HA(ctci_order,orgorderid) VALUES (I.advid,I.advid);

        --1.3Temp_ Them phan nay de xoa lenh thoa thuan tu xa
        UPDATE HAPUT_AD_DELT SET issend='Y' WHERE AUTOID =I.advid;

    END LOOP;
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    SELECT
        MSGTYPE MSGTYPE,
        TEXT TEXT,
        ADVID ADVID,
        ADVSIDE ADVSIDE,
        QUANTITY QUANTITY,
        ADVTRANSTYPE ADVTRANSTYPE,
        SYMBOL SYMBOL,
        DELIVERTOCOMPID DELIVERTOCOMPID,
        PRICE PRICE,
        ADVREFID ADVREFID
    FROM ha_7 WHERE STATUS ='N';
    --Cap nhat trang thai bang tam ra GW.
    UPDATE ha_7 SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
    plog.setendsection (pkgctx, 'PRC_7');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_7');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_7;

--Day message lenh Request CP len Gw
Procedure PRC_e(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is



BEGIN
    plog.setbeginsection (pkgctx, 'PRC_e');
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    Select 'e' msgtype,ID SecurityStatusReqID ,
       REQTYPE SubscriptionRequestType ,
       Decode(SYMBOL,'ALL',' ',SYMBOL) Symbol
    From HAStatusReq
    Where MarketOrSecuritity ='S' And status ='N';

    --Cap nhat trang thai .
    UPDATE HAStatusReq SET Status = 'S' WHERE STATUS ='N' And MarketOrSecuritity ='S';
    plog.setendsection (pkgctx, 'PRC_e');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_e');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_e;


--Day message lenh Request Thi truong len Gw
Procedure PRC_g_TT(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is

    v_err VARCHAR2(200);

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_g_TT');
    --LAY DU LIEU RA GW.
    OPEN PV_REF FOR
    Select 'g' msgtype,ID TradSesReqID ,REQTYPE SubscriptionRequestType
    From HAStatusReq
    Where MarketOrSecuritity ='M' and status ='N';

    --Cap nhat trang thai .
    UPDATE HAStatusReq SET Status = 'S' WHERE STATUS ='N' And MarketOrSecuritity ='M';
    plog.setendsection (pkgctx, 'PRC_g_TT');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_g_TT');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_g_TT;

--Begin HNX_update|doi mat khau GW
Procedure PRC_BE(PV_REF IN OUT PKG_REPORT.REF_CURSOR) is
        CURSOR C_BE IS
        SELECT  * FROM GWINFOR WHERE status ='N' AND txdate =getcurrdate;
  BEGIN
      plog.setbeginsection (pkgctx, 'PRC_BE');
      FOR I IN C_BE
      LOOP
        INSERT INTO ha_be
            (UserRequestID, UserRequestType, Username,  Password, NewPassword,
             msgtype,  sendnum
            )
         VALUES (i.userrequestid ,'3', I.Username, I.Password, I.NewPassword,
             'BE', 1
            );

        --1.2 CAP NHAT trang thai da gui
        UPDATE GWINFOR SET status='B' WHERE UserRequestID=i.userrequestid;
     END LOOP;
   --LAY DU LIEU RA GW.
   OPEN PV_REF FOR
   SELECT
        Msgtype,
        UserRequestID,
        UserRequestType,
        Username,
        Password,
        NewPassword,
        sendnum BOORDERID
   FROM ha_BE WHERE STATUS ='N';
   --Cap nhat trang thai bang tam ra GW.
   UPDATE ha_BE SET STATUS ='Y',DATE_TIME = SYSDATE WHERE STATUS ='N';
   plog.setendsection (pkgctx, 'PRC_BE');

  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_BE');
    RAISE errnums.E_SYSTEM_ERROR;
  END PRC_BE;
 --end HNX_update|doi mat khau GW

PROCEDURE matching_normal_order (
    firm               IN   VARCHAR2,
    order_number       IN   VARCHAR2,
    order_entry_date   IN   VARCHAR2,
    side_alph          IN   VARCHAR2,
    filler             IN   VARCHAR2,
    deal_volume        IN   NUMBER,
    deal_price         IN   NUMBER,
    confirm_number     IN   VARCHAR2
)
IS


BEGIN
    plog.setbeginsection (pkgctx, 'matching_normal_order');
     plog.error(pkgctx,'HAGW-matching_normal_order order_number='||order_number);
    pck_hagwex.matching_normal_order (
                                    firm,
                                    order_number,
                                    order_entry_date,
                                    side_alph,
                                    filler,
                                    deal_volume,
                                    deal_price,
                                    confirm_number,
                                    v_CheckProcess);
    plog.setendsection (pkgctx, 'matching_normal_order');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'HAGW-matching_normal_order order_number='||order_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'matching_normal_order');
    rollback;
END matching_normal_order;


--Thu tuc huy lenh

PROCEDURE confirm_cancel_normal_order (
    pv_orderid   IN   VARCHAR2,
    pv_qtty      IN   NUMBER
)
IS

BEGIN
    plog.setbeginsection (pkgctx, 'confirm_cancel_normal_order');
    pck_hagwex.confirm_cancel_normal_order (
                                            pv_orderid,
                                            pv_qtty,
                                            v_CheckProcess
                                            );
    plog.setendsection (pkgctx, 'confirm_cancel_normal_order');
EXCEPTION WHEN others THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'HAGW-CONFIRM_CANCEL_NORMAL_ORDER PV_ORDERID='||PV_ORDERID);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'confirm_cancel_normal_order');
    rollback;
END CONFIRM_CANCEL_NORMAL_ORDER;



PROCEDURE CONFIRM_REPLACE_NORMAL_ORDER (
    pv_ordernumber   IN   VARCHAR2,
    pv_qtty       IN   NUMBER,
    pv_price      IN   NUMBER,
    pv_LeavesQty IN   NUMBER
)
IS

BEGIN
    plog.setbeginsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
    pck_hagwex.CONFIRM_REPLACE_NORMAL_ORDER (
                                            pv_ordernumber,
                                            pv_qtty,
                                            pv_price,
                                            pv_LeavesQty,
                                            v_CheckProcess);
    plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
EXCEPTION WHEN others THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'CONFIRM_REPLACE_NORMAL_ORDER pv_ordernumber='||pv_ordernumber);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
    rollback;
END CONFIRM_REPLACE_NORMAL_ORDER;
Procedure Prc_Update_Security
is
    Cursor c_Stock Is
    Select SYMBOL,HIGHPX CEILING_PRICE, LOWPX FLOOR_PRICE, LASTPX BASIC_PRICE, BUYVOLUME current_room,
        CASE When (SECURITYTRADINGSTATUS in ('17','24','25','26','1','27','28')
          ) Then 'N'
          Else 'Y'
          End HALT_SUSP
    From  hasecurity_req;
Begin
    For vc_stock in c_Stock
    Loop
        UPDATE SECURITIES_INFO
        SET
            CEILINGPRICE= vc_stock.CEILING_PRICE,
            FLOORPRICE= vc_stock.FLOOR_PRICE,
            current_room=vc_stock.current_room,
            BASICPRICE=VC_STOCK.BASIC_PRICE,
            DFREFPRICE = vc_stock.FLOOR_PRICE
        WHERE SYMBOL= TRIM(vc_stock.SYMBOL)
              and( CEILINGPRICE<> vc_stock.CEILING_PRICE
                 or   FLOORPRICE<> vc_stock.FLOOR_PRICE
                 or  current_room<>vc_stock.current_room
                 OR BASICPRICE<> VC_STOCK.BASIC_PRICE)
                 ;
        UPDATE SBSECURITIES SET HALT =  vc_stock.HALT_SUSP WHERE SYMBOL=TRIM(vc_stock.SYMBOL);
        Commit;
    End Loop;
End;

Procedure Prc_ProcessMsg
is
    v_OrderID varchar2(20);
    v_Orgorderid varchar2(20);
    v_err  varchar2(150);
    v_strContraOrderId varchar2(30);
    v_strContraBorS varchar2(30);
    v_CICI_ORDER varchar2(30);
    v_Check number(1);
    v_afaccount varchar2(30);

    v_exp  Exception;
    p_err_param varchar2(30);
    p_err_code varchar2(30);


    Cursor c_Exec_8 is
    Select *
    From Exec_8
    Where Process  ='N'
        AND ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HARECEIVESIZE')
    Order by MsgSeqNum;
    --Order by Decode(EXECTYPE,'0',1,'5',2,'4',3) ,decode(ORDSTATUS,'0',1,'A',2,'D',2,'3',3);
    --Thu tu uu tien xu ly lenh: Lenh vao queue, vao core, lenh sua thanh cong, lenh huy thanh cong, lenh khop.

    v_Exec_8  c_Exec_8%rowtype;

    Cursor c_Ordermap_ha(v_ORDER_NUMBER varchar2) Is
    --DUCNV SELECT * FROM ORDERMAP_HA WHERE  NVL(ORDER_NUMBER,'0') = v_ORDER_NUMBER;
     SELECT * FROM ORDERMAP_HA WHERE ORDER_NUMBER IS NOT NULL AND ORDER_NUMBER = v_ORDER_NUMBER;
    v_Ordermap_ha c_Ordermap_ha%Rowtype;

    Cursor c_Onefirm(v_OrgOrderid varchar2)  is
    SELECT OM1.ORDERID,OM1.CONTRAFIRM,OM1.TRADERID,OM1.CLIENTID,
            o1.CUSTODYCD,o1.BORS, o1.QTTY QTTY, o1.PRICE PRICE,
            o2.orgorderid ContraOrderId , o2.bors ContraBorS
    FROM ORDERMAP_HA MAP,ODMAST OM1,OOD o1, ood o2, odmast om2
    WHERE o1.ORGORDERID=OM1.ORDERID
        AND MAP.ORGORDERID=om1.orderid
        AND OM1.ORDERID=v_OrgOrderid
        and OM1.clientid = O2.custodycd
        and o1.bors <> o2.bors
        and o1.qtty = o2.qtty
        and o1.price = o2.price
        and o2.norp='P'
        and o2.oodstatus<>'S'
        and o2.deltd <>'Y'
        and o2.orgorderid=om2.orderid
        and om2.exectype in ('NB','NS')
        and om2.remainqtty = o2.qtty
        and nvl(om1.ptdeal,'xx')=nvl(om2.ptdeal,'yy');

    Cursor c_Twofirm(v_OrgOrderid varchar2)  is
    SELECT OD.ORDERID,od.CONTRAFIRM,OD.TRADERID,OD.CLIENTID,OOD.CUSTODYCD,OOD.BORS, OOD.QTTY QTTY, OOD.PRICE PRICE
    FROM ORDERMAP_HA MAP,ODMAST OD,OOD
    WHERE OOD.ORGORDERID=OD.ORDERID AND MAP.ORGORDERID=OD.orderid
    AND ORDERID= v_OrgOrderid;
    v_Onefirm c_Onefirm%Rowtype;
    v_Twofirm c_Twofirm%Rowtype;
    --HNX_update
   Cursor c_Ordermap_ha_ctci(v_CTCI_NUMBER varchar2) Is
          SELECT * FROM ORDERMAP_HA WHERE NVL(ctci_order,'0') = v_CTCI_NUMBER;


Begin
    plog.setbeginsection (pkgctx, 'Prc_ProcessMsg');

    For i in c_Exec_8
    Loop
        BEGIN
            Insert into EXEC_8_queue(id,logtime) values (I.id,sysdate);
            v_err:='Process c_Exec_8 = CLORDID '||i.ORDERID|| ' EXECTYPE '||i.EXECTYPE ||' ORDSTATUS '||i.ORDSTATUS;
            v_CheckProcess := true;
            If i.ExecType = '0' And i.OrdStatus = '0' Then
            --Lenh vao Queue:
                UPDATE Ordermap_Ha
                SET ORDER_NUMBER = i.OrderID
                Where Trim(Ctci_Order) = Trim(i.ClOrdID);
            Elsif i.ExecType = '0' And i.OrdStatus = 'A' Then
                v_err:='Process c_Exec_8 = 0-A i.OrderID '||i.OrderID;
                --Lenh da vao Core
                --+ Kiem tra lenh vao Queue chua
                Open c_Ordermap_ha(i.OrderID);
                Fetch c_Ordermap_ha into v_Ordermap_ha;

                If c_Ordermap_ha%found then --Lenh da vao queue
                --v_err:=v_err || 'here';
                    UPDATE OOD
                    SET
                        OODSTATUS = 'S',
                        TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                        SENTTIME = SYSTIMESTAMP
                    WHERE ORGORDERID =v_Ordermap_ha.Orgorderid and OODSTATUS <> 'S';

                    UPDATE ODMAST SET ORSTATUS = '2', PORSTATUS =PORSTATUS||2
                    WHERE ORDERID = v_Ordermap_ha.Orgorderid AND ORSTATUS = '8';

                Else
                    v_CheckProcess := false;
                    v_err :='8-0-A : Chua tim thay lenh vao QUEUE: '||i.OrderID;
                    Raise v_exp;
                End if;
                Close c_Ordermap_ha;
            Elsif i.ExecType = '3' And i.OrdStatus = '2' Then
            --Lenh khop
            --1.1 Lenh khop thoa thuan
                If i.Side = '8' THEN
                    IF trim(i.clordid) is NOT NULL THEN
                        plog.debug(pkgctx,'prc_processmsg 1');
                        Begin
                            Select ORGORDERID Into v_OrderID  from ORDERMAP_HA
                            -- WHERE ORDER_NUMBER=trim(i.OrderID);
                            WHERE ctci_order=trim(i.clordid);
                            plog.debug(pkgctx,'prc_processmsg 2');
                        Exception when others then
                            INSERT INTO orderptdeal_delt(OrigCrossID,SECURITYSYMBOL, SIDE,Crosstype)
                            Values( i.OrigClOrdID ,i.Symbol ,'S','1');
                            Update  Exec_8 set Process ='Y' where id =i.ID;
                            commit;
                            v_err:='Lenh tu xa '||v_OrderID;
                            Raise v_exp;
                        End;
                        --Cap nhat thanh trang thai A tren Orderptack.
                        Update Orderptack set STATUS ='A' where  CONFIRMNUMBER = i.OrderID;

                        --Kiem tra xem day la lenh one-firm or two-firm put-through order
                        Open c_Onefirm(v_OrderID);
                        Fetch c_Onefirm into v_Onefirm;
                        Close c_Onefirm;

                        --Cap nhat trang thai lenh da sent thanh cong
                        UPDATE OOD
                        SET
                            OODSTATUS = 'S',
                            TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                            SENTTIME = SYSTIMESTAMP
                        WHERE ORGORDERID =v_OrderID and OODSTATUS <> 'S';

                        UPDATE ODMAST SET ORSTATUS = '2', PORSTATUS =PORSTATUS||2
                        --WHERE ORDERID = v_Ordermap_ha.Orgorderid AND ORSTATUS = '8';
                        WHERE ORDERID = v_OrderID AND ORSTATUS = '8';

                        plog.debug(pkgctx,'prc_processmsg 4');
                        -- Khop lenh cung cong ty
                        If  Trim(v_Onefirm.CLIENTID) is not null And Trim(v_Onefirm.CUSTODYCD) is not null
                        --  And Substr(v_Onefirm.CLIENTID,1, 3) =Substr(v_Onefirm.CUSTODYCD,1,3)
                        Then
                        --Khop ban
                            matching_normal_order('', trim(i.clordid), '', v_Onefirm.BorS, '', v_Onefirm.QTTY, v_Onefirm.PRICE, i.OrderID);
                            plog.debug(pkgctx,'prc_processmsg 6');

                            --Khop voi lenh doi ung
                            v_strContraOrderId :=v_Onefirm.ContraOrderId;
                            v_strContraBorS:=v_Onefirm.ContraBorS;
                            Select SEQ_ORDERMAP.NEXTVAL Into v_CICI_ORDER from dual;
                            --Dua vao Ordermap_HA de khop lenh tuong tu nhu lenh binh thuong:
                            INSERT INTO ORDERMAP_HA(ctci_order,orgorderid,order_number)
                            VALUES (v_CICI_ORDER ,v_strContraOrderId,v_CICI_ORDER);
                            plog.debug(pkgctx,'prc_processmsg 8');
                            Matching_normal_order('',v_CICI_ORDER, '', v_strContraBORS, '', v_Onefirm.QTTY, v_Onefirm.PRICE, i.OrderID);
                            plog.debug(pkgctx,'prc_processmsg 9');
                        Else
                            --Khop khac cong ty lenh ban cho doi tac
                            plog.debug(pkgctx,'prc_processmsg 10');
                            Open c_Twofirm(v_OrderID);
                            Fetch c_Twofirm into v_twofirm;
                            Close c_Twofirm;
                            Matching_normal_order('', i.OrigClOrdID, '', v_twofirm.BorS, '', v_twofirm.QTTY, v_twofirm.PRICE, i.OrderID);
                            plog.debug(pkgctx,'prc_processmsg 11');
                        End if;
                    Else -- i.clordid is NULL - Lenh mua cua dt khac
                        Matching_normal_order('', i.OrigClOrdID, '', 'B', '', i.LASTQTY, i.LASTPX, i.OrderID);
                    End if;

                Else --i.Side <> '8'
                    --1.2 Lenh khop thuong
                    plog.debug(pkgctx,'prc_processmsg 12');

                    --1.2.1 Lenh ban da co trong  Queue
                    v_Check:=0;
                    Open c_Ordermap_ha(i.OrigClOrdID);
                    Fetch c_Ordermap_ha into v_Ordermap_ha;
                    If c_Ordermap_ha%Found then
                        v_Check:=1;
                        -- DuongLH edit cho truong hop lenh tu xa:
                        IF (NVL(v_Ordermap_ha.Orgorderid,'XX')='XX') THEN
                            UPDATE exec_8 set process='E' , processnum=processnum+1, processtime=sysdate where id =i.ID;
                        Else
                        -- end of DuongLH
                            UPDATE OOD SET
                            OODSTATUS = 'S',
                            TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                            SENTTIME = SYSTIMESTAMP
                            WHERE
                            OODSTATUS <> 'S'
                            AND ORGORDERID = v_Ordermap_ha.Orgorderid;

                            Matching_normal_order('', i.OrigClOrdID, '', 'S', '', i.LASTQTY, i.LASTPX, i.OrderID);

                        END IF;
                    End if;
                    Close c_Ordermap_ha;

                    --1.2.2 Lenh mua da co trong  Queue

                    Open c_Ordermap_ha(i.SecondaryClOrdID);
                    Fetch c_Ordermap_ha into v_Ordermap_ha;
                    If c_Ordermap_ha%Found then
                        v_Check:=1;
                        IF (NVL(v_Ordermap_ha.Orgorderid,'XX')='XX') THEN
                            UPDATE exec_8 set process='E',processnum=processnum+1, processtime=sysdate where id =i.ID;
                        Else
                            UPDATE OOD SET
                            OODSTATUS = 'S',
                            TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                            SENTTIME = SYSTIMESTAMP
                            WHERE
                            OODSTATUS <> 'S'
                            AND ORGORDERID = v_Ordermap_ha.Orgorderid;
                            Matching_normal_order('', i.SecondaryClOrdID, '', 'B', '',  i.LASTQTY, i.LASTPX, i.OrderID);
                        End if;
                    End if;
                    Close c_Ordermap_ha;

                    If v_Check =0 then
                        v_err :='Process Exec 8 Khop lenh, khong tim thay lenh goc: i.OrigClOrdID='||i.OrigClOrdID ||'  i.SecondaryClOrdID ='||i.SecondaryClOrdID;
                        v_CheckProcess := false;
                        Raise v_Exp;
                    End if;
                End if; --i.Side = '8'

            Elsif i.ExecType = '4' And i.OrdStatus = 'D' Then
                --Lenh huy da vao he thong: Khong xu ly gi, chi xu ly khi huy thanh cong

                Update ood set OODSTATUS ='S'
                Where Reforderid in(select orgorderid from ordermap_ha
                                    where order_number =i.OrigClOrdID);

            Elsif i.ExecType = '4' And i.OrdStatus ='0' Then
                --Lenh sua vao Queue
                Null;
            Elsif i.ExecType = '4' And i.OrdStatus ='3' Then --Huy lenh thuong thanh cong

                If i.Side <> '8' Then --Huy lenh thuong
                    Open c_Ordermap_ha(i.OrigClOrdID);
                    Fetch c_Ordermap_ha into v_Ordermap_ha;
                    If c_Ordermap_ha%Found then
                        CONFIRM_CANCEL_NORMAL_ORDER(v_Ordermap_ha.Orgorderid,i.LeavesQty);
                    Else
                        Close c_Ordermap_ha;
                        v_err :='Khong tim thay lenh goc cua lenh huy:'||i.OrigClOrdID;
                        v_CheckProcess:=false;
                        Raise v_exp;
                    End if;
                    Close c_Ordermap_ha;
                Else --Huy lenh thoa thuan: chi ghi nhan, ko xu ly gi

                    INSERT INTO Haptcancelled(securitysymbol, confirmnumber,status, volume, price)
                           VALUES (i.Symbol ,i.OrderID  , 'H',i.LeavesQty,i.Price);
                    --Lay so hieu lenh goc:
                    Begin
                        Select Orgorderid into v_Orgorderid from Ordermap_ha where Order_number =trim(i.Orderid);
                        --Update lenh ve trang thai Delete

                        Update odmast set orstatus='3', deltd ='Y', CANCELQTTY =ORDERQTTY,REMAINQTTY=0,EXECQTTY =0 ,MATCHAMT =0,Execamt =0 where orderid = v_Orgorderid;
                        Update ood set  deltd ='Y', oodstatus = 'S' where orgorderid = v_Orgorderid;
                        Update iod set deltd ='Y' where Orgorderid = v_Orgorderid;
                        Update stschd set deltd='Y' where Orgorderid = v_Orgorderid;
                        For vc in (select orderid
                            From odmast where grporder='Y' and  orderid= V_ORGORDERID)
                        loop
                        cspks_seproc.pr_executeod9996(V_ORGORDERID,p_err_code,p_err_param);
                        End loop;

                        --Tim trong IOD so hieu lenh khop la i.Orderid de xoa lenh khop doi ung cung cong ty,
                        Begin

                            Select orgorderid into v_Orgorderid
                            from IOD
                            where confirm_no =trim(i.Orderid) and Deltd <>'Y';

                            Update odmast set deltd ='Y', CANCELQTTY =ORDERQTTY,REMAINQTTY=0 ,EXECQTTY =0,MATCHAMT =0,Execamt =0
                            where orderid = v_Orgorderid;
                            Update ood set  deltd ='Y' where orgorderid = v_Orgorderid;
                            Update iod set deltd ='Y' where Orgorderid = v_Orgorderid;
                            Update stschd set deltd='Y' where Orgorderid = v_Orgorderid;

                            For vc in (select orderid
                                From odmast where grporder='Y' and  orderid= V_ORGORDERID)
                            loop
                            cspks_seproc.pr_executeod9996(v_Orgorderid,p_err_code,p_err_param);
                            End loop;

                            -- quyet.kieu : Them cho LINHLNB 21/02/2012  -------------------------------------------
                            For j in (Select orgorderid ,codeid,bors,matchprice,matchqtty,txnum,txdate ,custodycd
                                   From iod
                                   Where NorP ='P'
                                    And confirm_no =trim(i.Orderid))
                            Loop
                             if j.bors = 'B' then
                                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                                -- Begin Danh sau tai san LINHLNB
                                 Select  afacctno into v_afaccount  from ODMAST   Where MATCHTYPE ='P' And Orderid = j.orgorderid;
                                 INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG,QTTY)
                                VALUES( v_afaccount,j.codeid ,j.matchprice * j.matchqtty,j.txnum, j.txdate,NULL,systimestamp,j.orgorderid,'C',j.matchqtty);
                               -- End Danh dau tai san LINHLNB
                               end if ;
                            End Loop;
                        -- End Them cho LINHLNB 21/02/2012  ------------------------------------------------------
                        Exception when others then
                        Null;
                        End;
                    Exception when others then
                        Null;
                    End;
                End if;

            ElsIf i.ExecType = '5' And i.OrdStatus = 'D' Then
                --Lenh sua da vao he thong: Khong xu ly gi, chi xu ly khi sua thanh cong
                Null;
            ElsIf i.ExecType = '5' And i.OrdStatus = '0' Then
                --Lenh sua da vao Queue khong lam gi
                Null;
            ElsIf i.ExecType = '5' And i.OrdStatus = '3' Then --Lenh sua thanh cong
                v_err :='Lenh sua:'||i.OrigClOrdID;
                Open c_Ordermap_ha(i.OrigClOrdID);
                Fetch c_Ordermap_ha into v_Ordermap_ha;
                If c_Ordermap_ha%Found then
                    CONFIRM_REPLACE_NORMAL_ORDER(i.OrigClOrdID,i.LastQty,i.LastPx, i.LeavesQty);
                Else
                    Close c_Ordermap_ha;
                    v_err :='Khong tim thay lenh goc cua lenh sua:'||i.OrigClOrdID;
                    v_CheckProcess:=false;
                    Raise v_exp;
                End if;
                Close c_Ordermap_ha;

            Elsif i.ExecType = '8' And i.OrdStatus ='8' Then --HNX gui msg giai toa lenh
                Open c_Ordermap_ha(i.OrderID);
                Fetch c_Ordermap_ha into v_Ordermap_ha;
                If c_Ordermap_ha%Found then
                   CONFIRM_CANCEL_NORMAL_ORDER(v_Ordermap_ha.Orgorderid,i.UnderlyingLastQty);
                ELSE
                   --begin HNX_update | sua 8-8-8 dat lenh bi tu choi
                   Open c_Ordermap_ha_ctci(i.clordid);
                   Fetch c_Ordermap_ha_ctci into v_Ordermap_ha;
                   If c_Ordermap_ha_ctci%Found THEN
                      CONFIRM_CANCEL_NORMAL_ORDER(v_Ordermap_ha.Orgorderid,i.UnderlyingLastQty);
                      UPDATE odmast od SET od.feedbackmsg=i.OrdRejReason WHERE orderid =v_Ordermap_ha.Orgorderid;
                   ELSE
                      Close c_Ordermap_ha;
                      Close c_Ordermap_ha_ctci;
                      v_err :='Khong tim thay lenh goc cua lenh huy:'||i.OrderID;
                      v_CheckProcess := false;
                      Raise v_exp;
                   END IF;
                   Close c_Ordermap_ha_ctci;
                   --end HNX_update
                End if;
                Close c_Ordermap_ha;

            End if;

            if v_CheckProcess = true then
                Update  Exec_8 set Process ='Y', processnum=processnum+1, processtime=sysdate where id =i.ID;
            else
                Update  Exec_8 set Process ='E', processnum=processnum+1, processtime=sysdate where id =i.ID;
                plog.error(pkgctx,'HAGW.Prc_ProcessMsg ID ='||i.ID||' ERR: '||v_err);
            end if;
            Commit;
        EXCEPTION
        WHEN v_exp then
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            plog.error(pkgctx,'HAGW.Prc_ProcessMsg'||'exeption in process EXEC_8 '||v_err);
            --plog.setendsection (pkgctx, 'PRC_ProcessMsg');
            Rollback;
            Update  Exec_8 set Process ='E', processnum=processnum+1, processtime=sysdate where id =i.ID;
            COMMIT;
        WHEN OTHERS then
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            plog.error(pkgctx,'HAGW.Prc_ProcessMsg'||'exeption in process EXEC_8 '||v_err);
           -- plog.setendsection (pkgctx, 'PRC_ProcessMsg');
            Rollback;
            Update  Exec_8 set Process ='E', processnum=processnum+1, processtime=sysdate where id =i.ID;
            COMMIT;
        END;
    End Loop;

    plog.setendsection (pkgctx, 'PRC_ProcessMsg');
EXCEPTION WHEN  Others THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_ProcessMsg');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
End;

Procedure Prc_ProcessMsg_ex
is
    v_OrderID varchar2(20);
    v_err  varchar2(150);
    v_strContraOrderId varchar2(30);
    v_strContraBorS varchar2(30);
    v_CICI_ORDER varchar2(30);
    v_Check number(1);
    v_IsProcess Varchar2(20);
    v_exp  Exception;
    Cursor c_Exec_8_1 is
    Select *
    From Exec_8
    Where Process  ='Y'and
        EXECTYPE ='3' and
        ORDSTATUS ='2'
        and ORIGCLORDID in (select order_number from ordermap_ha)
        And not exists (select 1 from iod where bors ='S' and Exec_8.ORDERID=iod.confirm_no);

    v_Exec_8  c_Exec_8_1%rowtype;

    Cursor c_Exec_8_2 is
    Select *
    From Exec_8
    Where Process  ='Y'and
        EXECTYPE ='3' and
        ORDSTATUS ='2'
        and SECONDARYCLORDID in (select order_number from ordermap_ha)
        And not exists (select 1 from iod where bors ='B' and Exec_8.ORDERID=iod.confirm_no);

    Cursor c_Ordermap_ha(v_ORDER_NUMBER varchar2) Is
    SELECT * FROM ORDERMAP_HA WHERE NVL(ORDER_NUMBER,'0') = v_ORDER_NUMBER;
    v_Ordermap_ha c_Ordermap_ha%Rowtype;
Begin
    plog.setbeginsection (pkgctx, 'Prc_ProcessMsg_ex');
    v_IsProcess:='N';
   /* Begin
        Select SYSVALUE Into v_IsProcess From Ordersys_ha
        Where SYSNAME ='ISPROCESS';
    Exception When others then
        v_IsProcess:='N';
    End;
    If v_IsProcess = 'N' then
        plog.setendsection (pkgctx, 'Prc_ProcessMsg_ex');
        Return;
    Else
        For i in
            (select * from exec_8
                where clordid is not null
                and EXECTYPE ='0'
                and ORDSTATUS ='0'
                and process ='Y'
                and CLORDID in (select ctci_order from ordermap_ha where order_number is null)
            )
        Loop
            Update ordermap_ha set order_number =i.ORDERID where CTCI_ORDER = i.clordid;
            commit;
        End loop;


        For i in c_Exec_8_1
        Loop
            Open c_Ordermap_ha(i.OrigClOrdID);
            Fetch c_Ordermap_ha into v_Ordermap_ha;
            If c_Ordermap_ha%Found then
                v_Check:=1;
                UPDATE OOD
                SET
                    OODSTATUS = 'S',
                    TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                    SENTTIME = SYSTIMESTAMP
                WHERE OODSTATUS <> 'S'
                    AND ORGORDERID = v_Ordermap_ha.Orgorderid;
                Matching_normal_order('', i.OrigClOrdID, '', 'S', '', i.LASTQTY, i.LASTPX, i.OrderID);
            End if;
            Close c_Ordermap_ha;
        End loop;

        For i in c_Exec_8_2
        Loop
            Open c_Ordermap_ha(i.SecondaryClOrdID);
            Fetch c_Ordermap_ha into v_Ordermap_ha;
            If c_Ordermap_ha%Found then
                v_Check:=1;
                UPDATE OOD SET
                    OODSTATUS = 'S',
                    TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                    SENTTIME = SYSTIMESTAMP
                WHERE  OODSTATUS <> 'S'
                    AND ORGORDERID = v_Ordermap_ha.Orgorderid;
                Matching_normal_order('', i.SecondaryClOrdID, '', 'B', '',  i.LASTQTY, i.LASTPX, i.OrderID);
            End if;
            Close c_Ordermap_ha;
        End loop;
    End if;
    COMMIT;*/
    plog.setendsection (pkgctx, 'Prc_ProcessMsg_ex');
EXCEPTION WHEN  Others THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'Prc_ProcessMsg_ex');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
End Prc_ProcessMsg_ex;

FUNCTION fnc_check_sec_ha
    ( v_Symbol IN varchar2)
RETURN  number IS

    Cursor c_SecInfo(vc_Symbol varchar2) is
    Select 1
    From hasecurity_req
    Where    symbol =vc_Symbol;
    v_Number Number(10);
    v_Result Number;
BEGIN
    Open c_SecInfo(v_Symbol);
    Fetch c_SecInfo into v_Number;
    If c_SecInfo%notfound  Then
      v_Result :=0;
    Else
     v_Result :=1;
    End if;
    Close c_SecInfo;
    RETURN v_Result;
END;


--XU LY MESSAGE NHAN VE
Procedure PRC_PROCESS is
    CURSOR C_MSG_RECEIVE IS
    select * from (
        SELECT MSGTYPE,ID, REPLACE(MSGXML,'&',' ') MSGXML, PROCESS
        FROM MSGRECEIVETEMP_HA
        WHERE PROCESS ='N' order by ID
        )
        where ROWNUM BETWEEN 0 AND (SELECT SYSVALUE FROM ORDERSYS_HA WHERE SYSNAME='HARECEIVESIZE');

    V_MSG_RECEIVE C_MSG_RECEIVE%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS');
    OPEN C_MSG_RECEIVE;
    LOOP
        FETCH C_MSG_RECEIVE INTO V_MSG_RECEIVE;
        EXIT WHEN C_MSG_RECEIVE%NOTFOUND;
        BEGIN
            v_CheckProcess := TRUE;
            IF V_MSG_RECEIVE.MSGTYPE ='8' THEN
                PRC_PROCESS8(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            --phuongntn add xu reject
            ELSIF V_MSG_RECEIVE.MSGTYPE ='3' THEN
                PRC_PROCESS3(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            --  end add
            ELSIF V_MSG_RECEIVE.MSGTYPE ='7' THEN
                PRC_PROCESS7(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='f' THEN
                PRC_PROCESSf(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='h' THEN
                PRC_PROCESSh(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='s' THEN
                PRC_PROCESSs(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='u' THEN
                PRC_PROCESSu(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='B' THEN --SONLT: Xu ly them khi nhan msg B
            PRC_PROCESSB(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='BF' THEN--HNX_update
            PRC_PROCESSBF(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            ELSIF V_MSG_RECEIVE.MSGTYPE ='A' THEN--HNX_update
            PRC_PROCESSA(V_MSG_RECEIVE.MSGXML,V_MSG_RECEIVE.ID);
            END IF;
            IF v_CheckProcess THEN
                UPDATE MSGRECEIVETEMP_HA
                SET PROCESS ='Y', PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1
                WHERE ID =V_MSG_RECEIVE.ID;
            ELSE
                UPDATE MSGRECEIVETEMP_HA
                SET PROCESS ='E' , PROCESSTIME=SYSDATE, PROCESSNUM=PROCESSNUM+1
                WHERE ID =V_MSG_RECEIVE.ID;
                plog.error(pkgctx,'HAGW.PRC_PROCESS '||'Cant not process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            END IF;
            COMMIT;
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            Rollback;
            UPDATE MSGRECEIVETEMP_HA SET PROCESS ='E' WHERE ID =V_MSG_RECEIVE.ID;
            plog.error(pkgctx,'HAGW.PRC_PROCESS'||'exeption in process MSG ID = '||V_MSG_RECEIVE.ID||' V_MSG_RECEIVE.MSGTYPE = '||V_MSG_RECEIVE.MSGTYPE);
            Commit;
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
Procedure PRC_PROCESS_ERR is
 Cursor c_Exec_8 is
        Select id
        From Exec_8
        Where Process  ='Y'and
            EXECTYPE ='3' and
            processnum<5 and
            side <>'8' and
            ORDSTATUS ='2' and
            (
             (ORIGCLORDID in (select order_number from ordermap_ha)
              And not exists (select 1 from iod where bors ='S' and Exec_8.ORDERID=iod.confirm_no)
             )
            or
             (
              SECONDARYCLORDID in (select order_number from ordermap_ha)
              And not exists (select 1 from iod where bors ='B' and Exec_8.ORDERID=iod.confirm_no)
              )
             )
          union all
          Select id
            From Exec_8
            Where Process  ='Y'and
                EXECTYPE ='3' and
                side ='8' and
                processnum<5 and
                ORDSTATUS ='2' and
                (
                 (ORIGCLORDID in (select order_number from ordermap_ha)
                  And not exists (select 1 from iod where Exec_8.ORDERID=iod.confirm_no)
                 )
                 )         ;
    v_IsProcess VARCHAR2(1);

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS_ERR');
    v_IsProcess:='N';
    Begin
       Select SYSVALUE Into v_IsProcess From Ordersys_HA
       Where SYSNAME ='ISPROCESS';
    Exception When others then
         v_IsProcess:='N';
    End;
    If v_IsProcess = 'Y' then
         Update msgreceivetemp_ha set process='N' WHERE PROCESS='E' AND PROCESSNUM < 5;
         COMMIT;
         delete exec_8_queue e where EXISTS (select id from  exec_8 e8 where e8.process='E' and e8.processnum <5 and e8.id=e.id);
         Update exec_8 set process='N' WHERE PROCESS='E' AND PROCESSNUM < 5;
         COMMIT;
         For vc in c_Exec_8 Loop
            Delete exec_8_queue e where id =vc.id;
            Update exec_8 set process='N' WHERE id=vc.id;
         End loop;
         Commit;
    End if;
    plog.setendsection (pkgctx, 'PRC_PROCESS_ERR');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS_ERR');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESS_ERR;

FUNCTION fn_xml2obj_8(p_xmlmsg    VARCHAR2) RETURN tx.msg_8 IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_8;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_8');

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
If v_Key ='ClOrdID'  Then
l_txmsg.ClOrdID := v_Value;
Elsif v_Key ='TransactTime' Then
l_txmsg.TransactTime := v_Value;
Elsif v_Key ='ExecType' Then
l_txmsg.ExecType := v_Value;
Elsif v_Key ='OrderQty' Then
l_txmsg.OrderQty := v_Value;
Elsif v_Key ='OrderID' Then
l_txmsg.OrderID := v_Value;
Elsif v_Key ='Side' Then
l_txmsg.Side := v_Value;
Elsif v_Key ='Symbol' Then
l_txmsg.Symbol := v_Value;
Elsif v_Key ='Price' Then
l_txmsg.Price := v_Value;
Elsif v_Key ='Account' Then
l_txmsg.Account := v_Value;
Elsif v_Key ='OrdStatus' Then
l_txmsg.OrdStatus := v_Value;
Elsif v_Key ='OrigClOrdID' Then
l_txmsg.OrigClOrdID := v_Value;
Elsif v_Key ='SecondaryClOrdID' Then
l_txmsg.SecondaryClOrdID := v_Value;
Elsif v_Key ='LastQty' Then
l_txmsg.LastQty := v_Value;
Elsif v_Key ='LastPx' Then
l_txmsg.LastPx := v_Value;
Elsif v_Key ='ExecID' Then
l_txmsg.ExecID := v_Value;
Elsif v_Key ='LeavesQty' Then
l_txmsg.LeavesQty := v_Value;
Elsif v_Key ='OrdType' Then
l_txmsg.OrdType := v_Value;
Elsif v_Key ='UnderlyingLastQty' Then
l_txmsg.UnderlyingLastQty := v_Value;
Elsif v_Key ='OrdRejReason' Then
l_txmsg.OrdRejReason := v_Value;
Elsif v_Key ='MsgSeqNum' Then
l_txmsg.MsgSeqNum := v_Value;
End if;
END LOOP;

plog.debug(pkgctx,'msg 8 l_txmsg.ORDERID: '||l_txmsg.ORDERID
 ||' l_txmsg.ExecType ='|| l_txmsg.ExecType
 ||' l_txmsg.OrdStatus ='|| l_txmsg.OrdStatus);
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_8');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_8');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_8;


FUNCTION fn_xml2obj_s(p_xmlmsg    VARCHAR2) RETURN tx.msg_s IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_s;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_s');

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
If v_Key ='CrossID'  Then
l_txmsg.CrossID := v_Value;
Elsif v_Key ='CrossType' Then
l_txmsg.CrossType := v_Value;
Elsif v_Key ='NoSides' Then
l_txmsg.NoSides := v_Value;
Elsif v_Key ='SellSide' Then
l_txmsg.SellSide := v_Value;
Elsif v_Key ='BuySide' Then
l_txmsg.BuySide := v_Value;
Elsif v_Key ='Symbol' Then
l_txmsg.Symbol := v_Value;
Elsif v_Key ='BuyPartyID' Then
l_txmsg.BuyPartyID := v_Value;
Elsif v_Key ='SellPartyID' Then
l_txmsg.SellPartyID := v_Value;
Elsif v_Key ='Price' Then
l_txmsg.Price := v_Value;
Elsif v_Key ='SellOrderQty' Then
l_txmsg.SellOrderQty := v_Value;
Elsif v_Key ='BuyOrderQty' Then
l_txmsg.BuyOrderQty := v_Value;
Elsif v_Key ='SellAccount' Then
l_txmsg.SellAccount := v_Value;
Elsif v_Key ='BuyAccount' Then
l_txmsg.BuyAccount := v_Value;
Elsif v_Key ='SellAccountType' Then
l_txmsg.SellAccountType := v_Value;
Elsif v_Key ='BuyAccountType' Then
l_txmsg.BuyAccountType := v_Value;
Elsif v_Key ='SellClOrdID' Then
l_txmsg.SellClOrdID := v_Value;
Elsif v_Key ='BuyClOrdID' Then
l_txmsg.BuyClOrdID := v_Value;
End if;
END LOOP;

plog.debug(pkgctx,'msg s l_txmsg.CrossID: '||l_txmsg.CrossID
 ||' l_txmsg.CrossType ='|| l_txmsg.CrossType
 ||' l_txmsg.Price ='|| l_txmsg.Price
 ||' l_txmsg.SellOrderQty ='|| l_txmsg.SellOrderQty
 ||' l_txmsg.BuyPartyID ='|| l_txmsg.BuyPartyID
 ||' l_txmsg.SellPartyID ='|| l_txmsg.SellPartyID
 ||' l_txmsg.SellClOrdID ='|| l_txmsg.SellClOrdID
 ||' l_txmsg.BuyClOrdID ='|| l_txmsg.BuyClOrdID
 );
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_s');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_s');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_s;

--Nhan Message B
  FUNCTION fn_xml2obj_B(p_xmlmsg    VARCHAR2) RETURN tx.msg_B IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_B;
    v_Key Varchar2(100);
    v_Value Varchar2(4000);


  BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_B');

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
      If v_Key ='Text'  Then
        l_txmsg.Text := v_Value;
      Elsif v_Key ='SendingTime' Then
        l_txmsg.SendingTime := v_Value;
      Elsif v_Key ='Urgency' Then
        l_txmsg.Urgency := v_Value;
      Elsif v_Key ='LinesOfText' Then --edit 20151007
        l_txmsg.LinesOfText := v_Value; --edit 20151007
      Elsif v_Key ='Headline' Then --edit 20151007
        l_txmsg.HeadLine := v_Value;
      End if;
    END LOOP;


    plog.debug(pkgctx,'msg s l_txmsg.Text: '||l_txmsg.Text
             ||' l_txmsg.SendingTime ='|| l_txmsg.SendingTime
             ||' l_txmsg.Urgency ='|| l_txmsg.Urgency
             ||' l_txmsg.LinesOfText ='|| l_txmsg.LinesOfText --edit 20151007
             ||' l_txmsg.HeadLine ='|| l_txmsg.HeadLine);
    plog.debug(pkgctx,'Free resources associated');

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_B');
    RETURN l_txmsg;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_lob.freetemporary(p_xmlmsg);
      DBMS_XMLPARSER.freeparser(l_parser);
      DBMS_XMLDOM.freedocument(l_doc);
      plog.error(pkgctx, SQLERRM);
      plog.setendsection(pkgctx, 'fn_xml2obj_B');
      RAISE errnums.E_SYSTEM_ERROR;
  END fn_xml2obj_B;


FUNCTION fn_xml2obj_u(p_xmlmsg    VARCHAR2) RETURN tx.msg_u IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_u;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_u');

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
If v_Key ='CrossID'  Then
l_txmsg.CrossID := v_Value;
Elsif v_Key ='OrigCrossID' Then
l_txmsg.OrigCrossID := v_Value;
Elsif v_Key ='CrossType' Then
l_txmsg.CrossType := v_Value;
Elsif v_Key ='SenderCompID' Then
l_txmsg.SenderCompID := v_Value;
Elsif v_Key ='TargetCompID' Then
l_txmsg.TargetCompID := v_Value;
Elsif v_Key ='TargetSubID' Then
l_txmsg.TargetSubID := v_Value;
End if;
END LOOP;

plog.debug(pkgctx,'msg s l_txmsg.CrossID: '||l_txmsg.CrossID
 ||' l_txmsg.CrossType ='|| l_txmsg.CrossType
 ||' l_txmsg.SenderCompID ='|| l_txmsg.SenderCompID
 ||' l_txmsg.TargetCompID ='|| l_txmsg.TargetCompID
 ||' l_txmsg.TargetSubID ='|| l_txmsg.TargetSubID);
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_u');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_u');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_u;

--phuongntn add xml msg reject
FUNCTION fn_xml2obj_3(p_xmlmsg    VARCHAR2) RETURN tx.msg_3 IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_3;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_3');

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
If v_Key ='SessionRejectReason'  Then
l_txmsg.SessionRejectReason := trim(v_Value);
Elsif v_Key ='RefMsgType' Then
l_txmsg.RefMsgType := trim(v_Value);
Elsif v_Key ='Text' Then
l_txmsg.Text := trim(v_Value);
Elsif v_Key ='ClOrdID' Then
l_txmsg.ClOrdID  := trim(v_Value);
Elsif v_Key ='CrossID' Then
l_txmsg.CrossID  := trim(v_Value);
Elsif v_Key ='RefSeqNum' Then
l_txmsg.RefSeqNum  := trim(v_Value);
Elsif v_Key ='UserRequestID' Then--HNX_update
l_txmsg.UserRequestID  := trim(v_Value);
End if;
END LOOP;

plog.debug(pkgctx,'msg s l_txmsg.SessionRejectReason: '||l_txmsg.SessionRejectReason
 ||' l_txmsg.RefMsgType ='|| l_txmsg.RefMsgType
 ||' l_txmsg.Text ='|| l_txmsg.Text
 ||' l_txmsg.RefSeqNum ='|| l_txmsg.RefSeqNum);
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_3');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_3');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_3;

-- HNX_update: Bo sung msg BF
FUNCTION fn_xml2obj_BF(p_xmlmsg    VARCHAR2) RETURN tx.msg_BF IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_BF;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


    BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_BF');

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
    If v_Key ='Username'  Then
    l_txmsg.Username := trim(v_Value);
    Elsif v_Key ='UserRequestID' Then
    l_txmsg.UserRequestID := trim(v_Value);
    Elsif v_Key ='UserStatus' Then
    l_txmsg.UserStatus := trim(v_Value);
    Elsif v_Key ='UserStatusText' Then
    l_txmsg.UserStatusText  := trim(v_Value);
    End if;
    END LOOP;

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_BF');
    RETURN l_txmsg;
EXCEPTION
    WHEN OTHERS THEN
    --dbms_lob.freetemporary(p_xmlmsg);
    DBMS_XMLPARSER.freeparser(l_parser);
    DBMS_XMLDOM.freedocument(l_doc);
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'fn_xml2obj_BF');
    RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_BF;
--End HNX_update: Bo sung msg BF

-- HNX_update: TruongLD Add Bo sung msg A
FUNCTION fn_xml2obj_A(p_xmlmsg    VARCHAR2) RETURN tx.msg_A IS
    l_parser   xmlparser.parser;
    l_doc      xmldom.domdocument;
    l_nodeList xmldom.domnodelist;
    l_node     xmldom.domnode;
    n     xmldom.domnode;

    l_fldname fldmaster.fldname%TYPE;
    l_txmsg   tx.msg_A;
    v_Key Varchar2(100);
    v_Value Varchar2(100);


    BEGIN
    plog.setbeginsection (pkgctx, 'fn_xml2obj_A');

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
    If v_Key ='Text'  Then
        l_txmsg.Text := trim(v_Value);
    End if;
    END LOOP;

    -- Free any resources associated with the document now it
    -- is no longer needed.
    DBMS_XMLDOM.freedocument(l_doc);
    -- Only used if variant is CLOB
    -- dbms_lob.freetemporary(p_xmlmsg);

    plog.setendsection(pkgctx, 'fn_xml2obj_A');
    RETURN l_txmsg;
EXCEPTION
    WHEN OTHERS THEN
    --dbms_lob.freetemporary(p_xmlmsg);
    DBMS_XMLPARSER.freeparser(l_parser);
    DBMS_XMLDOM.freedocument(l_doc);
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'fn_xml2obj_A');
    RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_A;
-- End HNX_update: TruongLD Add Bo sung msg A

FUNCTION fn_xml2obj_7(p_xmlmsg    VARCHAR2) RETURN tx.msg_7 IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_7;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_7');

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
If v_Key ='AdvSide'  Then
l_txmsg.AdvSide := v_Value;
Elsif v_Key ='Text' Then
l_txmsg.Text := v_Value;
Elsif v_Key ='Quantity' Then
l_txmsg.Quantity := v_Value;
Elsif v_Key ='AdvTransType' Then
l_txmsg.AdvTransType := v_Value;
Elsif v_Key ='Symbol' Then
l_txmsg.Symbol := v_Value;
Elsif v_Key ='DeliverToCompID' Then
l_txmsg.DeliverToCompID := v_Value;
Elsif v_Key ='Price' Then
l_txmsg.Price := v_Value;
Elsif v_Key ='AdvId' Then
l_txmsg.AdvId := v_Value;
Elsif v_Key ='SenderSubID' Then
l_txmsg.SenderSubID := v_Value;
Elsif v_Key ='AdvRefID' Then
l_txmsg.AdvRefID := v_Value;
End if;
END LOOP;

plog.debug(pkgctx,'msg s l_txmsg.AdvId: '||l_txmsg.AdvId
 ||' l_txmsg.AdvSide ='|| l_txmsg.AdvSide
 ||' l_txmsg.Quantity ='|| l_txmsg.Quantity
 ||' l_txmsg.Symbol ='|| l_txmsg.Symbol
 ||' l_txmsg.Price ='|| l_txmsg.Price);
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_7');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_7');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_7;

--Nhan Message f
FUNCTION fn_xml2obj_f(p_xmlmsg    VARCHAR2) RETURN tx.msg_f IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_f;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_f');

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
If v_Key ='Text'  Then
l_txmsg.Text := trim(v_Value);
Elsif v_Key ='SecurityStatusReqID' Then
l_txmsg.SecurityStatusReqID := trim(v_Value);
Elsif v_Key ='Symbol' Then
l_txmsg.Symbol := trim(v_Value);
Elsif v_Key ='SecurityType' Then
l_txmsg.SecurityType := trim(v_Value);
Elsif v_Key ='IssueDate' Then
l_txmsg.IssueDate := trim(v_Value);
Elsif v_Key ='Issuer' Then
l_txmsg.Issuer := trim(v_Value);
Elsif v_Key ='SecurityDesc' Then
l_txmsg.SecurityDesc := trim(v_Value);
Elsif v_Key ='HighPx' Then
l_txmsg.HighPx := trim(v_Value);
Elsif v_Key ='LowPx' Then
l_txmsg.LowPx := trim(v_Value);
Elsif v_Key ='LastPx' Then
l_txmsg.LastPx := trim(v_Value);
Elsif v_Key ='SecurityTradingStatus' Then
l_txmsg.SecurityTradingStatus := trim(v_Value);
Elsif v_Key ='BuyVolume' Then
l_txmsg.BuyVolume := trim(v_Value);
Elsif v_Key ='TradingSessionSubID' Then
l_txmsg.TradingSessionSubID := trim(v_Value);
Elsif v_Key ='ClientID' Then            --thangpv ROC_TPDN_HNX 11/07/2022 lay tu FNSHOSTWEB qua
l_txmsg.TotalListingQtty := v_Value;
End if;
END LOOP;


plog.debug(pkgctx,'msg s l_txmsg.SecurityStatusReqID: '||l_txmsg.SecurityStatusReqID
 ||' l_txmsg.Symbol ='|| l_txmsg.Symbol
 ||' l_txmsg.SecurityType ='|| l_txmsg.SecurityType
 ||' l_txmsg.HighPx ='|| l_txmsg.HighPx
 ||' l_txmsg.LowPx ='|| l_txmsg.LowPx);
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_f');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_f');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_f;


--Nhan Message h
FUNCTION fn_xml2obj_h(p_xmlmsg    VARCHAR2) RETURN tx.msg_h IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;
n     xmldom.domnode;

l_fldname fldmaster.fldname%TYPE;
l_txmsg   tx.msg_h;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
plog.setbeginsection (pkgctx, 'fn_xml2obj_h');

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
If v_Key ='TradingSessionID'  Then
l_txmsg.TradingSessionID := v_Value;
Elsif v_Key ='TradSesStartTime' Then
l_txmsg.TradSesStartTime := v_Value;
Elsif v_Key ='TradSesStatus' Then
l_txmsg.TradSesStatus := v_Value;
Elsif v_Key ='TradSesReqID' Then
l_txmsg.TradSesReqID := v_Value;
End if;
END LOOP;


plog.debug(pkgctx,'msg s l_txmsg.TradingSessionID: '||l_txmsg.TradingSessionID
 ||' l_txmsg.TradSesStartTime ='|| l_txmsg.TradSesStartTime
 ||' l_txmsg.TradSesStatus ='|| l_txmsg.TradSesStatus);
plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(p_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_h');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
--dbms_lob.freetemporary(p_xmlmsg);
DBMS_XMLPARSER.freeparser(l_parser);
DBMS_XMLDOM.freedocument(l_doc);
plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
plog.setendsection(pkgctx, 'fn_xml2obj_h');
RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_h;


--Xu ly Message 8
Procedure PRC_PROCESS8(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TX8   tx.msg_8;
    V_ORGORDERID VARCHAR2(20);
    v_Process     VARCHAR2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS8');

    V_TX8:=fn_xml2obj_8(V_MSGXML);

    --Neu msg vao Core thi cap nhat trang thai Sent luon.
    If V_TX8.ExecType = '0' And V_TX8.OrdStatus = 'A' Then
        BEGIN
            SELECT ORGORDERID INTO V_ORGORDERID
            FROM Ordermap_Ha WHERE ctci_order= TRIM(V_TX8.ClOrdID);

            UPDATE Ordermap_Ha SET ORDER_NUMBER = V_TX8.OrderID
            Where Ctci_OrdeR = Trim(V_TX8.ClOrdID);
            v_Process := 'Y';
            UPDATE OOD SET
                  OODSTATUS = 'S',
                  TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                  SENTTIME = SYSTIMESTAMP
            WHERE ORGORDERID = V_ORGORDERID and OODSTATUS <> 'S';

            UPDATE ODMAST SET ORSTATUS = '2',
            HOSESESSION = (SELECT SYSVALUE  FROM ORDERSYS_HA WHERE SYSNAME = 'TRADINGID')
            WHERE ORDERID = V_ORGORDERID AND ORSTATUS = '8';

        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx,'HAGW.PRC_PROCESS8'||'Khong tim so hieu lenh goc V_TX8.ClOrdID: '||V_TX8.ClOrdID);
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            v_CheckProcess := FALSE;
            plog.setendsection (pkgctx, 'PRC_PROCESS8');
            ROLLBACK;
            Return;
        END;

    Elsif V_TX8.ExecType = '0' And V_TX8.OrdStatus = 'M' Then --Lenh MTL khong khop het.
        BEGIN
            SELECT ORGORDERID INTO V_ORGORDERID
            FROM Ordermap_Ha
            WHERE TRIM(ctci_order)= TRIM(V_TX8.ClOrdID);
        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx,'HAGW.PRC_PROCESS8'||' Map lenh MTL khong tim so hieu lenh goc V_TX8.ClOrdID: '||V_TX8.ClOrdID);
        END;
        --Cap nhat lai gia cua lenh goc = gia cua lenh LO do San gui ve
        UPDATE ODMAST SET Quoteprice = V_TX8.PRICE, exprice =V_TX8.PRICE
        WHERE ORDERID = V_ORGORDERID;
        v_Process:='Y';
    ELSE
        v_Process:='N';
    End if;
    --XU LY MESSAGE 8.
    INSERT INTO Exec_8(clordid, transacttime, exectype, orderqty, orderid, side,
               symbol, price, ACCOUNT, ordstatus, origclordid,
               secondaryclordid, lastqty, lastpx, execid, leavesqty,receivetime,id,process,
               OrdType, UnderlyingLastQty,OrdRejReason,MsgSeqNum,PROCESSTIME,PROCESSNUM)
    VALUES ( V_TX8.ClOrdID , V_TX8.TransactTime , V_TX8.ExecType , V_TX8.OrderQty , V_TX8.OrderID , V_TX8.Side,
          V_TX8.Symbol , V_TX8.Price , V_TX8.Account , V_TX8.OrdStatus ,V_TX8.OrigClOrdID ,
          V_TX8.SecondaryClOrdID, V_TX8.LastQty , V_TX8.LastPx , V_TX8.ExecID ,V_TX8.LeavesQty ,sysdate,v_ID,v_Process,
          V_TX8.OrdType, V_TX8.UnderlyingLastQty,V_TX8.OrdRejReason,V_TX8.MsgSeqNum,DECODE(v_Process,'Y',SYSDATE,NULL),DECODE(v_Process,'Y',1,0));

    plog.setendsection (pkgctx, 'PRC_PROCESS8');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS8');
    ROLLBACK;
END PRC_PROCESS8;
--Xu ly Message 3
Procedure PRC_PROCESS3(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TX3   tx.msg_3;
    V_ORGORDERID VARCHAR2(20);
    v_msgReject  varchar2(200);
    v_check1Firm int;
    v_orderqtty number;
    v_codeid varchar2(10);
    v_contrafirm varchar2(10);
    v_custodycd varchar2(10);
    v_RefOrderID  varchar2(20);
    v_qtty number;
    v_ptdeal varchar2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS3');
    V_TX3:=fn_xml2obj_3(V_MSGXML);
    v_msgReject:=v_tx3.SessionRejectReason||'-'|| v_tx3.Text;
    Insert into ctci_reject --Ghi log b? t? ch?i
        (firm,
         order_number,
         reject_reason_code,
         original_message_text,
         order_entry_date,
         msgtype)
    VALUES
        ('',
         v_tx3.RefSeqNum,
         v_tx3.SessionRejectReason,
         '',
         to_char(getcurrdate,'DD/MM/RRRR'),
         v_tx3.RefMsgType);
    IF trim(v_tx3.SessionRejectReason)='-70013' THEN
    -- neu loi tran buffer size thi khong lam gi vi gateway se gui lai lenh
      RETURN;
    END IF;
    --XU LY MESSAGE 3.
    Begin
        if V_TX3.RefMsgType='s' then
            SELECT ORGORDERID --Lay thong tin so hieu lenh trong Flex
            INTO V_ORGORDERID
            FROM ORDERMAP_HA
           WHERE ctci_order = TRIM(V_TX3.CrossID);
        else
          SELECT ORGORDERID --Lay thong tin so hieu lenh trong Flex
            INTO V_ORGORDERID
            FROM ORDERMAP_HA
           WHERE ctci_order = TRIM(V_TX3.ClOrdID);
       end if;
      EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx, 'PRC_PROCESS3 ' || 'Khong tim so hieu lenh goc ORDER_NUMBER: ' || V_TX3.ClOrdID||'V_TX3.RefMsgType'||V_TX3.RefMsgType);
        --RAISE errnums.E_SYSTEM_ERROR;
    END;
    If V_TX3.RefMsgType='D' or V_TX3.RefMsgType='s'then --lenh moi thuong + thoa thuan
   -- If V_TX3.RefMsgType='D' then --lenh thuong
        UPDATE OOD
        SET OODSTATUS = 'S',
          TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
          SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
        and OODSTATUS <> 'S';
        Select REMAINQTTY into  v_qtty from odmast  Where Orderid = V_ORGORDERID;

        --Giao toa tien /ck
        CONFIRM_CANCEL_NORMAL_ORDER(V_ORGORDERID, v_qtty);
        Update odmast
        set
          EXECQTTY   = 0,
          MATCHAMT   = 0,
          Execamt    = 0,
          ORSTATUS   = '6',
          FEEDBACKMSG= v_msgReject
        Where Orderid = V_ORGORDERID;

        --Xu ly cho lenh mua doi dung
        select count(1)
        into v_check1Firm
        from odmast
        where Orderid = V_ORGORDERID
          and matchtype='P'
          and contrafirm=(select sysvalue from ordersys_ha where sysname='FIRM');
            plog.error(pkgctx, 'PRC_PROCESS3 1 '||V_ORGORDERID);
        If V_TX3.RefMsgType='s' and v_check1Firm>0 then --thao thuan cung cong ty
        --Tim thong tin lenh mua doi ung
          select  orderqtty, codeid, contrafirm, cf.custodycd, ptdeal
            into v_orderqtty,
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
                     AND ptdeal =v_ptdeal ;
         CONFIRM_CANCEL_NORMAL_ORDER(v_RefOrderID,v_orderqtty );
            plog.error(pkgctx, 'PRC_PROCESS3 2 '||v_RefOrderID);
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
        end if;

    End if;
    If V_TX3.RefMsgType='F' then --Tu choi lenh huy thuong

        UPDATE OOD
        SET OODSTATUS = 'S',
                 TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
                 SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
             and OODSTATUS <> 'S'
             ;

        Update odmast
        Set
                 EXECQTTY   = 0,
                 MATCHAMT   = 0,
                 Execamt    = 0,
                 ORSTATUS   = '6',
                 FEEDBACKMSG= v_msgReject
        Where Orderid = V_ORGORDERID ;
        --Xu ly cho phep dat lai lenh huy
        DELETE odchanging WHERE orderid =V_ORGORDERID;

        update  fomast set status= 'R',feedbackmsg=v_msgReject
        WHERE orgacctno=V_ORGORDERID;
      --end add
    End if;
    If V_TX3.RefMsgType='G' then --tu choi sua thuong
        UPDATE OOD
        SET OODSTATUS = 'S',
                TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
                SENTTIME  = SYSTIMESTAMP
        WHERE ORGORDERID = V_ORGORDERID
            and OODSTATUS <> 'S';

        Update odmast
        Set
                EXECQTTY   = 0,
                MATCHAMT   = 0,
                Execamt    = 0,
                ORSTATUS   = '6',
                FEEDBACKMSG= v_msgReject
        Where Orderid = V_ORGORDERID;
         --Xu ly cho phep dat lai lenh sua
        DELETE odchanging WHERE orderid =V_ORGORDERID;
        update  fomast set status='R',feedbackmsg=v_msgReject
        WHERE orgacctno=V_ORGORDERID;
    End if;
     If V_TX3.RefMsgType='u' then --tu choi huy thoa thuan

        UPDATE CANCELORDERPTACK
        SET status='S' , isconfirm='Y'
        WHERE ordernumber= V_ORGORDERID
        AND SORR='S' AND MESSAGETYPE='3C'
        ;

    End if;
    If V_TX3.RefMsgType='BE' then --tu choi yeu cau doi mat khau
         UPDATE GWinfor gw SET
           gw.status ='S',
           gw.asetstatus=7,
           gw.userstatustext=v_msgReject
         WHERE UserRequestID=V_TX3.UserRequestID;

    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESS3');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS3');
    v_CheckProcess := FALSE;
    rollback;
END PRC_PROCESS3;

--HNX_update: Xu ly Message BF
  Procedure PRC_PROCESSBF(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TXBF   tx.msg_BF;
    v_newpassword VARCHAR2(100);

  BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSBF');

    V_TXBF:=fn_xml2obj_BF(V_MSGXML);

    UPDATE GWinfor gw SET
           gw.status ='S',
           gw.asetstatus=V_TXBF.UserStatus,
           gw.userstatustext=V_TXBF.UserStatusText
    WHERE UserRequestID=V_TXBF.UserRequestID;
    IF V_TXBF.UserStatus ='5' THEN
      SELECT gw.newpassword INTO v_newpassword FROM GWinfor gw  WHERE gw.UserRequestID=V_TXBF.UserRequestID;
      UPDATE ordersys_ha SET
             sysvalue =v_newpassword
             WHERE  sysname ='GWPASSWORD';
    END IF;
    plog.setendsection (pkgctx, 'PRC_PROCESSBF');

  EXCEPTION WHEN OTHERS THEN
     plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSBF');
    ROLLBACK;
  END PRC_PROCESSBF;

  --HNX_update: TruongLD Add Xu ly Message A
  Procedure PRC_PROCESSA(V_MSGXML VARCHAR2, v_ID Varchar2) is
    v_txA   tx.msg_A;
    v_strSMS    Varchar2(100);
    v_strDatasource     varchar2(4000);
  BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSA');

    v_txA := fn_xml2obj_A(V_MSGXML);

    IF instr(upper(v_txA.Text), upper('password expires')) > 0  THEN
        Begin
            Select sysvalue into v_strSMS from ordersys_ha where sysname='NOTIFYSMS';
            v_strDatasource := 'select ''HAGW 7000: ' || v_txA.Text || ''' detail from dual';
            FOR rec IN
                (
                        SELECT * FROM
                            (select trim(regexp_substr(sysvalue,'[^,]+', 1, level)) phone
                            from (SELECT sysvalue from ordersys_ha where sysname='NOTIFYSMS' )
                            connect by regexp_substr(sysvalue, '[^,]+', 1, level) is not NULL) a
                )
            LOOP

                -- Sinh yeu cau gui SMS
                INSERT INTO emaillog (AUTOID,EMAIL,TEMPLATEID,DATASOURCE,STATUS,CREATETIME)
                VALUES(seq_emaillog.nextval, REC.PHONE,'0305' , v_strDatasource, 'A', sysdate);
            END LOOP;

        EXCEPTION WHEN OTHERS THEN
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            plog.setendsection (pkgctx, 'PRC_PROCESSA');
        End;
    END IF;
    plog.setendsection (pkgctx, 'PRC_PROCESSA');

  EXCEPTION WHEN OTHERS THEN
     plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSA');
    ROLLBACK;
  END PRC_PROCESSA;
  -- End HNX_update: TruongLD Add Xu ly Message A

--Xu ly Message 7
Procedure PRC_PROCESS7(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TX7   tx.msg_7;
    V_ORGORDERID VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS7');

    V_TX7:=fn_xml2obj_7(V_MSGXML);

    --XU LY MESSAGE 7.
    If V_TX7.AdvTransType = 'N' Then
    --Lenh dat HNX forward

        INSERT INTO haput_ad
                (advside, text, quantity, advtranstype,
                 symbol, delivertocompid, price, advid,
                 sendersubid
                )
         VALUES (v_tx7.advside, v_tx7.text, v_tx7.quantity, v_tx7.advtranstype,
                 v_tx7.symbol, v_tx7.delivertocompid, v_tx7.price, v_tx7.advid,
                 v_tx7.sendersubid
                );

        Update ordermap_ha O set order_number =v_tx7.advid
        where O.ctci_order =v_tx7.advrefid
        AND EXISTS (SELECT advid FROM HA_7 H WHERE h.advid=O.CTCI_ORDER AND h.symbol=v_tx7.symbol);

    Else --If v_CTCI_7.AdvTransType = "C" Then
    -- Lenh huy quang cao duoc HNX forward
        UPDATE haput_ad
        SET advtranstype = v_tx7.advtranstype
        WHERE advid = v_tx7.advid;
    End If;

    plog.setendsection (pkgctx, 'PRC_PROCESS7');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESS7');
    ROLLBACK;
END PRC_PROCESS7;



--Xu ly Message s
Procedure PRC_PROCESSs(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TXs   tx.msg_s;
    V_ORGORDERID VARCHAR2(20);
    v_Firm  VARCHAR2(20);
    v_Side  VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSs');

    V_TXs:=fn_xml2obj_s(V_MSGXML);

    --XU LY MESSAGE s.
    Begin
        Select SYSVALUE Into v_Firm
        From ordersys_ha
        Where SYSNAME ='FIRM';
    Exception When others then
        plog.error(pkgctx, 'Chua khai bao ma cty trong Ordersys_Ha');
        v_Firm:='0';
    End;

    If to_number(v_Firm) = to_number(V_TXs.BuyPartyID) Then
        v_Side := 'B';
    Else
        v_Side := 'S';
    End If;
    --Neu lenh confirm ban thi cap nhat vao ordermap_ha de khi khop map.
    If v_Firm <> V_TXs.BuyPartyID and v_Firm = V_TXs.SellPartyID Then
        Update ordermap_ha
        Set    ctci_order = V_TXs.CrossID,  order_number= V_TXs.CrossID, rejectcode = ctci_order
        Where ctci_order = V_TXs.SellClOrdID;
    End if;

    --Nhan message chao ban thoa thuan

    INSERT INTO orderptack
    (TIMESTAMP, messagetype, firm, buyertradeid,
     side, sellercontrafirm, sellertradeid, securitysymbol, volume,
     price, board, confirmnumber, offset, status, issend,
     ordernumber, brid, tlid,
     txtime, ipaddress, trading_date,
     sclientid
    )
    VALUES (TO_CHAR (SYSDATE, 'HH24MISS'), 's', v_txs.buypartyid, '',
     v_side, v_txs.sellpartyid, '', v_txs.symbol, v_txs.sellorderqty,
     v_txs.price, '', v_txs.crossid, '', 'N', 'N',
     '' , '', ''
     , TO_CHAR (SYSDATE, 'hh24miss'), '', TRUNC (SYSDATE),
     v_txs.sellaccount
    );
    plog.setendsection (pkgctx, 'PRC_PROCESSs');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSs');
    ROLLBACK;
END PRC_PROCESSs;



--Xu ly Message f
  Procedure PRC_PROCESSf(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TXf   tx.msg_f;
    V_ORGORDERID VARCHAR2(20);
    v_Count Number(10);
    v_CODEID VARCHAR2(20);
    v_strErrCode VARCHAR2(20);
    v_strErrM VARCHAR2(200);
    v_tradeplace VARCHAR2(20);
    v_tradeplaceBO VARCHAR2(20);
    v_haltflag varchar2(1);
    v_cellingprice number;
    v_floorprice number;
  BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSf');

    V_TXf:=fn_xml2obj_f(V_MSGXML);

    --XU LY MESSAGE f.

    Select count(*) Into v_Count
    From HASecurity_Req
    Where Symbol = V_TXf.Symbol;

    If v_Count >0 Then--Co yeu cau HNX gui thong tin trang thai CK

        UPDATE hasecurity_req
           SET securitystatusreqid = v_txf.securitystatusreqid,
               highpx = v_txf.highpx,
               lowpx = v_txf.lowpx,
               securitytradingstatus = v_txf.securitytradingstatus,
               TradingSessionSubID=v_txf.TradingSessionSubID,
               buyvolume = v_txf.buyvolume,
               securitytype = v_txf.securitytype,
               lastpx = v_txf.lastpx,
               text =
                     ' Update securities_info set  ceilingprice = '
                  || v_txf.highpx
                  || ' , floorprice = '
                  || v_txf.lowpx
                  || ' , DFREFPRICE = '
                  || v_txf.lowpx
                  || ' Where symbol = '''
                  || v_txf.symbol
                  || ''';'
         WHERE symbol = v_txf.symbol;

    Else

        INSERT INTO hasecurity_req
                    (securitystatusreqid, symbol, highpx,
                     lowpx, securitytradingstatus, buyvolume,
                     securitytype, lastpx,TradingSessionSubID,
                     text
                    )
             VALUES (v_txf.securitystatusreqid, v_txf.symbol, v_txf.highpx,
                     v_txf.lowpx, v_txf.securitytradingstatus, v_txf.buyvolume,
                     v_txf.securitytype, v_txf.lastpx,v_txf.TradingSessionSubID,
                        'Update securities_info set  ceilingprice = '
                     || v_txf.highpx
                     || ' , floorprice = '
                     || v_txf.lowpx
                     || ' , DFREFPRICE = '
                     || v_txf.lowpx
                     || ' where symbol = '''
                     || v_txf.symbol
                     || ''';'
                    );

    End if;

   commit;

    if v_txf.SECURITYTRADINGSTATUS in ('17','24','25','26','1','27','28') then
       v_haltflag:='N';
      UPDATE SBSECURITIES SET HALT =  'N' WHERE SYMBOL=v_txf.symbol;
    else
       v_haltflag:='Y';
     UPDATE SBSECURITIES SET HALT =  'Y' WHERE SYMBOL=v_txf.symbol;
    end if;

    commit;

    --Ngay 31/01/2019 NamTv chinh dap ung giao dich TPDN
    --09/04/2021 chi sua lay tran san theo tham so he thong cho TPDN
    v_cellingprice :=  v_txf.HIGHPX;
    v_floorprice  := v_txf.LOWPX;
    if (v_txf.securitytype = 'CORP') then
        if (v_txf.LOWPX = 0) then
            BEGIN
                SELECT to_number(a.varvalue) INTO v_floorprice FROM SYSVAR A WHERE A.GRNAME='SYSTEM' AND a.varname='TPDNFLOOR';
            EXCEPTION WHEN OTHERS THEN
                v_floorprice := 1;
            END;
          --v_floorprice := 1000;
        end if;

        if (v_txf.HIGHPX = 0) then
            BEGIN
                SELECT to_number(a.varvalue) INTO v_cellingprice FROM SYSVAR A WHERE A.GRNAME='SYSTEM' AND a.varname='TPDNCEIL';
            EXCEPTION WHEN OTHERS THEN
                v_cellingprice := 2000000000;
            END;
          --v_cellingprice := 10000000;
        end if;
    end if;

    Begin
              --pr_updatepricefromgw(v_txf.Symbol, nvl(v_txf.LASTPX,0),v_txf.LOWPX ,v_txf.HIGHPX,'DN',v_strErrCode,v_strErrM);
              pr_updatepricefromgw(v_txf.Symbol, nvl(v_txf.LASTPX,0),v_floorprice ,v_cellingprice,'DN',v_strErrCode,v_strErrM);
           Exception when others then
             null;
        End;

       Commit ;

    Begin
      v_CODEID:='';
      select codeid into v_CODEID from securities_info where SYMBOL =v_txf.symbol;
      update securities_info set
                CURRENT_ROOM=v_txf.BUYVOLUME
         where ( CODEID=v_CODEID
                 Or CODEID in (SELECT CODEID FROM SBSECURITIES WHERE REFCODEID=v_CODEID)
                   ) ;
    Exception when others then
       null;
    End;
    Commit ;
    --phuongntn add chuyen san, moi niem yet, sua gia, halk, buoc gia, san, huy lenh ko hop le
    if v_txf.TradingSessionSubID ='LIS_BRD_01'  then
             cspks_odproc.Pr_Update_SecInfo(v_txf.symbol, v_txf.highpx,v_txf.lowpx,v_txf.LastPx,'002',v_haltflag,v_strErrCode);
        Elsif  v_txf.TradingSessionSubID ='UPC_BRD_01' THEN
             cspks_odproc.Pr_Update_SecInfo(v_txf.symbol, v_txf.highpx,v_txf.lowpx,v_txf.LastPx,'005',v_haltflag, v_strErrCode);
        Elsif  v_txf.TradingSessionSubID ='LIS_BRD_BOND' THEN
         cspks_odproc.Pr_Update_SecInfo(v_txf.symbol, v_cellingprice,v_floorprice,v_txf.LastPx,'002',v_haltflag,v_strErrCode);
    end if ;
        Commit ;
    --end add
   plog.setendsection (pkgctx, 'PRC_PROCESSf');

--thangpv ROC_TPDN_HNX 11/07/2022 lay tu FNSHOSTWEB qua
         update securities_info set
/*                FLOORPRICE= v_txf.LOWPX,
                CEILINGPRICE= v_txf.HIGHPX,*/
                FLOORPRICE= v_floorprice,
                CEILINGPRICE= v_cellingprice,
                CURRENT_ROOM=v_txf.BUYVOLUME,
                BASICPRICE=nvl(v_txf.LASTPX,0),
                LISTINGQTTY=nvl(v_txf.TotalListingQtty,0) --Ngay 31/10/2022 NamTv them tag109
         where ( CODEID=v_CODEID
                 Or CODEID in (SELECT CODEID FROM SBSECURITIES WHERE REFCODEID=v_CODEID)
                   ) ;


  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'PRC_PROCESSf');
    RAISE errnums.E_SYSTEM_ERROR;

  END PRC_PROCESSf;



--Xu ly Message h
Procedure PRC_PROCESSh(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TXh   tx.msg_h;
    V_ORGORDERID VARCHAR2(20);
    v_TradingSessionID Varchar2(100):='';
    v_currdate date;
    p_err_code varchar2(100);
    p_err_message varchar2(1000);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSh');

    V_TXh:=fn_xml2obj_h(V_MSGXML);
    If V_TXh.TradingSessionID in ('LIS_CON_NML', 'LIS_CON_NEW', 'LIS_CON_LTD', 'LIS_CON_SPC','BON_CON_NML') Then --16/01/2019 DieuNDA: them BON_CON_NML
        v_TradingSessionID :='CONT';
    Elsif   V_TXh.TradingSessionID in ('LIS_AUC_C_NML',  'LIS_AUC_C_NEW', 'LIS_AUC_C_LTD',  'LIS_AUC_C_SPC','BON_AUC_C_NML'   ) Then --16/01/2019 DieuNDA: them BON_AUC_C_NML
        v_TradingSessionID :='CLOSE';
    Elsif   V_TXh.TradingSessionID in ('LIS_AUC_C_NML_LOC' ,  'LIS_AUC_C_NEW_LOC', 'LIS_AUC_C_LTD_LOC',  'LIS_AUC_C_SPC_LOC'   ) Then
        v_TradingSessionID :='CLOSE_BL';
    Elsif   V_TXh.TradingSessionID in ('LIS_PTH_P_NML','LIS_PLO_NEW','BON_PTH_P_NML'   ) Then --Them PLO --16/01/2019 DieuNDA: them BON_PTH_P_NML
        v_TradingSessionID :='PCLOSE';

    ElsIf V_TXh.TradingSessionID in ('UPC_CON_NML', 'UPC_CON_NEW', 'UPC_CON_LTD', 'UPC_CON_SPC') Then
        v_TradingSessionID :='CONTUP';
    Elsif   V_TXh.TradingSessionID in ('UPC_AUC_C_NML',  'UPC_AUC_C_NEW', 'UPC_AUC_C_LTD',  'UPC_AUC_C_SPC'   ) Then
        v_TradingSessionID :='CLOSE';
    Elsif   V_TXh.TradingSessionID in ('UPC_AUC_C_NML_LOC' ,  'UPC_AUC_C_NEW_LOC', 'UPC_AUC_C_LTD_LOC',  'UPC_AUC_C_SPC_LOC'   ) Then
        v_TradingSessionID :='CLOSE_BL';
    Elsif   V_TXh.TradingSessionID in ('UPC_PTH_P_NML') Then
        v_TradingSessionID :='PCLOSE';
    End if;

    -- If V_TXh.TradingSessionID like 'LIS%' Then
    If V_TXh.TradSesReqID ='LIS_BRD_01' Then
    --XU LY MESSAGE h.
        UPDATE ORDERSYS_HA SET SYSVALUE=V_TXh.TradSesStatus WHERE SYSNAME='CONTROLCODE';
        UPDATE ORDERSYS_HA SET SYSVALUE=v_TradingSessionID WHERE SYSNAME='TRADINGID';
        UPDATE ORDERSYS_HA SET SYSVALUE= V_TXh.TradSesStartTime WHERE SYSNAME='TIMESTAMP';
    Elsif V_TXh.TradSesReqID =  'UPC_BRD_01' Then
        UPDATE ORDERSYS_UPCOM SET SYSVALUE=V_TXh.TradSesStatus WHERE SYSNAME='CONTROLCODE';
        UPDATE ORDERSYS_UPCOM SET SYSVALUE=v_TradingSessionID WHERE SYSNAME='TRADINGID';
        UPDATE ORDERSYS_UPCOM SET SYSVALUE= V_TXh.TradSesStartTime WHERE SYSNAME='TIMESTAMP';
    End if;

    UPDATE HASECURITY_REQ SET
        TradingSessionID=v_TradingSessionID,
        TradSesStatus =V_TXh.TradSesStatus
    WHERE symbol=V_TXh.tradsesreqid;

    UPDATE HA_BRD set tradsesstatus=V_TXh.TradSesStatus, tradingsessionid =  v_TradingSessionID
    WHERE BRD_CODE = V_TXh.TradSesReqID;

    Commit;
    -- Ducnv sinh lenh huy cho lenh RP
    If v_TradingSessionID ='CLOSE' then
        v_currdate:=getcurrdate;
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
                        From odmast o, fomast f, rootordermap R,sbsecurities sb
                        Where
                               sb.symbol=V_TXh.tradsesreqid
                               and sb.tradeplace='002'
                               and sb.codeid=o.codeid
                               and o.txdate =v_currdate
                               and o.pricetype='LO'
                              and o.remainqtty>0
                              and o.orderid = r.orderid
                              and r.foacctno=f.acctno
                              and f.pricetype='RP'
                              )
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
                 Insert into logrporder(txdate,orderid) values(v_currdate,vc.acctno);
            End loop;
    End if;
    -- End of ducnv.
    plog.setendsection (pkgctx, 'PRC_PROCESSh');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSh');
    ROLLBACK;
END PRC_PROCESSh;


--Xu ly Message u
Procedure PRC_PROCESSu(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TXu   tx.msg_u;
    V_ORGORDERID VARCHAR2(20);
    v_Symbol  VARCHAR2(20);
    v_BorS  VARCHAR2(20);
    v_Firm  VARCHAR2(20);
    v_Contrafirm VARCHAR2(20);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSu');

    V_TXu:=fn_xml2obj_u(V_MSGXML);

    --XU LY MESSAGE u.
    If V_TXu.CrossType = '7' Then
        Update ORDERPTACK
        Set STATUS ='C'
        Where CONFIRMNUMBER =V_TXu.OrigCrossID;
    Else
        Begin

        SELECT symbol, orderid, od.bors bors Into v_Symbol, V_ORGORDERID, v_BorS
        FROM odmast o, ood od, ordermap_ha op
        WHERE o.orderid = od.orgorderid
        AND o.orderid = op.orgorderid
        AND op.order_number = v_txu.origcrossid;

        Exception when others then
        v_Symbol:=Null;
        V_ORGORDERID :=Null;
        v_BorS :=Null;
        End;

        If v_BorS = 'S' Then
            v_Firm := v_Contrafirm;
            v_Contrafirm := '';
        Else
            Begin
               Select SELLERCONTRAFIRM FIRM Into v_Contrafirm
               From orderptack Where CONFIRMNUMBER = V_TXu.OrigCrossID;
               v_Firm := '';
            Exception when others then
                plog.error(pkgctx,'PRC_PROCESSu Khong tim thay so hieu lenh: '||V_TXu.OrigCrossID);
            End;
    End If;
    --Day du lieu vao bang cancel:

    INSERT INTO cancelorderptack
            (sorr, firm, contrafirm, tradeid,
             TIMESTAMP, messagetype, securitysymbol, confirmnumber,
             ordernumber, status, isconfirm, trading_date
            )
     VALUES ('R', v_firm, v_contrafirm, v_bors,
             TO_CHAR (SYSDATE, 'HH24MISS'), 'u', v_symbol, v_txu.origcrossid,
             v_orgorderid, 'N', 'N', TRUNC (SYSDATE)
            );

    End if;

    plog.setendsection (pkgctx, 'PRC_PROCESSu');

EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'PRC_PROCESSu');
    ROLLBACK;
END PRC_PROCESSu;

 Procedure PRC_PROCESSB(V_MSGXML VARCHAR2, v_ID Varchar2) is
    V_TXB   tx.msg_B;
   v_string varchar2 (1000);
  BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSB');

    V_TXB:=fn_xml2obj_B(V_MSGXML);


    --XU LY MESSAGE B.
    INSERT INTO ha_B (autoid,sendingtime, urgency, headline, LinesOfText, text,Status,MsgType,ptype)
              values (seq_ha_b.nextval,V_TXB.sendingtime, V_TXB.urgency, V_TXB.headline, V_TXB.LinesOfText, V_TXB.text,'S','B','I'); --edit 20151007
     UPDATE ORDERSYS_HA SET SYSVALUE = TRIM(V_TXB.urgency) WHERE SYSNAME = 'HNXURGENCY';

     v_string:= 'select '''|| V_TXB.text || ''' detail from dual';
        FOR rec IN
                (
                        SELECT * FROM
                                                 (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                                 from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                                 connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                )
        LOOP

                nmpks_ems.InsertEmailLog(rec.phone , '0305', v_string,'');
        END LOOP;
   plog.setendsection (pkgctx, 'PRC_PROCESSB');

  EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    v_CheckProcess := FALSE;

    plog.setendsection (pkgctx, 'PRC_PROCESSB');
    RAISE errnums.E_SYSTEM_ERROR;

  END PRC_PROCESSB;

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
