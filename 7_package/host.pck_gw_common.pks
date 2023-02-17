SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_gw_common IS

PROCEDURE prc_UpdateBoardSession (p_brdcode   VARCHAR2,
                                  p_boardId   VARCHAR2,
                                  p_grpCode   VARCHAR2,
                                  p_sessionId VARCHAR2);

FUNCTION fnc_GetBoardId (p_brdCode    VARCHAR2,
                        p_quantity    NUMBER,
                        p_tradeLot    NUMBER,
                        p_matchType   VARCHAR2, -- N: Normal, T: Put through
                        p_isBuyIn     VARCHAR2,
                        p_isOpenPost  VARCHAR2,
                        p_priceType   varchar2) RETURN VARCHAR2;    
FUNCTION fn_getSymbolByIsinCode(pv_isinCode VARCHAR2) RETURN VARCHAR2;
FUNCTION fn_getHOSession (p_symbol VARCHAR2, p_boardId VARCHAR2) RETURN VARCHAR2;

PROCEDURE CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum         IN VARCHAR2,
                                  pv_RefMsgType        IN VARCHAR2,
                                  pv_ClOrdID           IN VARCHAR2,
                                  pv_RejectCode        IN VARCHAR2,
                                  pv_RejectText        IN VARCHAR2,
                                  pv_QuoteMsgID        IN VARCHAR2 DEFAULT '',
                                  pv_IOIID             IN VARCHAR2 DEFAULT '');
PROCEDURE MATCHING_NORMAL_ORDER (
    pv_orderid            IN   VARCHAR2,
    pv_side               IN   VARCHAR2,
    pv_deal_volume        IN   NUMBER,
    pv_deal_price         IN   NUMBER,
    pv_confirm_number     IN   VARCHAR2,
    pv_CheckProcess       IN OUT BOOLEAN
);

PROCEDURE CONFIRM_CANCEL_NORMAL_ORDER (
   pv_orderid      IN   VARCHAR2,
   pv_qtty         IN   NUMBER,
   pv_CheckProcess IN OUT BOOLEAN
);

PROCEDURE CONFIRM_REPLACE_NORMAL_ORDER (
    PV_ORDERID      IN VARCHAR2,
    pv_qtty         IN NUMBER,
    pv_price        IN NUMBER,
    pv_LeavesQty    IN NUMBER,
    pv_cumqty       IN NUMBER,
    pv_ctci_order   IN VARCHAR,
    PV_CONFIRM_NUMBER  VARCHAR2,
    pv_CheckProcess IN OUT BOOLEAN
);

FUNCTION FNC_CHECK_ROOM (
   pv_Symbol      IN VARCHAR2,
   pv_Volumn      IN NUMBER,
   pv_Custodycd   IN VARCHAR2,
   pv_BorS        IN VARCHAR2
) RETURN  NUMBER;

--LAY MESSAGE DAY LEN GW.
/*PROCEDURE PRC_PUSHORDER(PV_MSGTYPE VARCHAR2, PV_TRADEPLACE VARCHAR2);*/
--XU LY MESSAGE NHAN VE
PROCEDURE PRC_PROCESS_ORDER(
    PV_MARKET            IN VARCHAR2,
    PV_CLORDID           IN VARCHAR2,
    PV_ORGCLORDID        IN VARCHAR2,
    PV_EXECTYPE          IN VARCHAR2,
    PV_ORDSTATUS         IN VARCHAR2,
    PV_SIDE              IN VARCHAR2,
    PV_OrderQty          IN VARCHAR2,
    PV_LASTQTY           IN NUMBER,
    PV_LASTPX            IN NUMBER,
    PV_LEAVESQTY         IN NUMBER,
    PV_CUMQTY            IN NUMBER,
    PV_CONFIRM_NUMBER    IN VARCHAR2,
    PV_EXECID            IN VARCHAR2,
    PV_QUOTEID           IN VARCHAR2,
    PV_ORDREJREASON      IN VARCHAR2,
    pv_OnBehalfOfCompID  IN VARCHAR2,
    pv_OnBehalfOfSubID   IN VARCHAR2,
    PV_ERR               OUT VARCHAR2
);
PROCEDURE PRC_PROCESS3(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESS9(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSAI(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSAJ(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSJ(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK03(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK04(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK05(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK06(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK07(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK08(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK09(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK11(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK15(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK16(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSK17(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
PROCEDURE PRC_PROCESSS(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2);
-- PARSER MESAGE NHAN VE
FUNCTION fn_xml2obj_3(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_3;
FUNCTION fn_xml2obj_8(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_8;
FUNCTION fn_xml2obj_9(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_9;
FUNCTION fn_xml2obj_j(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_j;
FUNCTION fn_xml2obj_AI(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_AI;
FUNCTION fn_xml2obj_AJ(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_AJ;
FUNCTION fn_xml2obj_K03(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K03;
FUNCTION fn_xml2obj_K04(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K04;
FUNCTION fn_xml2obj_K05(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K05;
FUNCTION fn_xml2obj_K06(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K06;
FUNCTION fn_xml2obj_K07(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K07;
FUNCTION fn_xml2obj_K08(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K08;
FUNCTION fn_xml2obj_K09(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K09;
FUNCTION fn_xml2obj_K11(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K11;
FUNCTION fn_xml2obj_K15(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K15;
FUNCTION fn_xml2obj_K16(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K16;
FUNCTION fn_xml2obj_K17(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K17;
FUNCTION fn_xml2obj_S(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_S;
END;
/


CREATE OR REPLACE PACKAGE BODY pck_gw_common
IS
    pkgctx plog.log_ctx;
    logrow tlogdebug%ROWTYPE;

PROCEDURE CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum         IN VARCHAR2,
                                  pv_RefMsgType        IN VARCHAR2,
                                  pv_ClOrdID           IN VARCHAR2,
                                  pv_RejectCode        IN VARCHAR2,
                                  pv_RejectText        IN VARCHAR2,
                                  pv_QuoteMsgID        IN VARCHAR2 DEFAULT '',
                                  pv_IOIID             IN VARCHAR2 DEFAULT '')
IS
  v_orgorderid     VARCHAR2(20);
  v_order_number   VARCHAR2(100);
  v_refOrgorderid  VARCHAR2(20);
  v_qtty           NUMBER;
  v_msgreject      VARCHAR2(500);
  v_refKey         VARCHAR2(200);
  v_checkProcess   BOOLEAN := TRUE;
BEGIN
  plog.setbeginsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
  v_msgreject := pv_RejectCode || '-' || pv_RejectText;
  IF pv_RefMsgType IN ('S', 'K02', 'AJ') THEN
     v_RefKey := pv_QuoteMsgID;
  ELSIF pv_RefMsgType IN ('6') THEN
     v_RefKey := pv_IOIID;
  ELSE
     v_RefKey := pv_ClOrdID;
  END IF;
  -- Ghi log message bi tu choi
  INSERT INTO msg_reject(refseqnum, refmsgtype, refkey, rejectreasoncode, rejectreasontext)
  VALUES(pv_RefSeqNum, pv_RefMsgType, v_refKey, pv_RejectCode, pv_RejectText);

  IF pv_RefMsgType NOT IN ('6') THEN
     BEGIN
        SELECT orgorderid, order_number INTO v_orgorderid, v_order_number
        FROM ordermap WHERE ctci_order = v_RefKey;
     EXCEPTION
       WHEN OTHERS THEN
         plog.error(pkgctx, 'Khong tim so hieu lenh goc v_refKey: ' || v_refKey ||', pv_RefMsgType: '|| pv_RefMsgType);
         plog.setbeginsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
         RAISE errnums.E_SYSTEM_ERROR;
     END;
  END IF;

  IF pv_RefMsgType IN ('D', 'S') THEN -- Tu choi lenh dat thong thuong, lenh thoa thuan
     UPDATE ood SET oodstatus = 'S',
                    txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                    senttime  = systimestamp
     WHERE orgorderid = v_orgorderid and oodstatus <> 'S';
     SELECT remainqtty INTO v_qtty FROM odmast WHERE orderid = v_orgorderid;
     --Giao toa tien /ck
     CONFIRM_CANCEL_NORMAL_ORDER(v_orgorderid, v_qtty, v_checkProcess);
     IF NOT v_checkProcess THEN
        plog.error(pkgctx, 'Giao toa tien /ck khong thanh cong v_orgorderid: ' || v_orgorderid ||', v_qtty: '|| v_qtty);
        plog.setbeginsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
        RAISE errnums.E_SYSTEM_ERROR;
     END IF;

     UPDATE odmast SET execqtty    = 0,
                       matchamt    = 0,
                       execamt     = 0,
                       orstatus    = '6',
                       porstatus   = porstatus || orstatus,
                       feedbackmsg = v_msgreject
     WHERE orderid = v_orgorderid;

     IF pv_RefMsgType = 'S' THEN
        -- Tu choi lenh mua doi ung cung cung ty(neu co)
        BEGIN
          SELECT odb.orderid INTO v_refOrgorderid
          FROM odmast ods, odmast odb, cfmast cfs, ordersys sys
          WHERE ods.orderid = v_orgorderid
          AND sys.sysname = 'FIRM'
          AND ods.custid = cfs.custid
          AND ods.codeid = odb.codeid
          AND ods.orderqtty = odb.orderqtty
          AND cfs.custodycd = odb.clientid
          AND ods.contrafirm = odb.contrafirm AND ods.contrafirm = sys.sysvalue
          AND ods.ptdeal = odb.ptdeal
          AND ods.matchtype = odb.matchtype AND ods.matchtype = 'P';

          UPDATE ood SET oodstatus = 'S',
                         txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                         senttime  = systimestamp
          WHERE orgorderid = v_refOrgorderid and oodstatus <> 'S';
          --Giao toa tien /ck
          CONFIRM_CANCEL_NORMAL_ORDER(v_refOrgorderid, v_qtty, v_checkProcess);
          IF NOT v_checkProcess THEN
             plog.error(pkgctx, 'Giao toa tien /ck khong thanh cong v_refOrgorderid: ' || v_refOrgorderid ||', v_qtty: '|| v_qtty);
             plog.setbeginsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
             RAISE errnums.E_SYSTEM_ERROR;
          END IF;
          UPDATE odmast SET execqtty    = 0,
                            matchamt    = 0,
                            execamt     = 0,
                            orstatus    = '6',
                            porstatus   = porstatus || orstatus,
                            feedbackmsg = v_msgreject
          WHERE orderid = v_refOrgorderid;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

     END IF;
  END IF;

  IF pv_RefMsgType IN ('F', 'K02') THEN -- Tu choi lenh huy
     UPDATE ood SET oodstatus = 'S',
                    txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                    senttime  = systimestamp
     WHERE orgorderid = v_orgorderid and oodstatus <> 'S';
     UPDATE odmast SET execqtty    = 0,
                       matchamt    = 0,
                       execamt     = 0,
                       orstatus    = '6',
                       porstatus   = porstatus || orstatus,
                       feedbackmsg = v_msgreject
     WHERE orderid = v_orgorderid ;
     --xu ly cho phep dat lai lenh huy
     DELETE odchanging WHERE orderid = v_orgorderid;
     UPDATE fomast set status = 'R', feedbackmsg = v_msgreject WHERE orgacctno = v_orgorderid;
  END IF;

  IF pv_RefMsgType = 'G' THEN -- Tu choi lenh sua thong thuong
     UPDATE ood SET oodstatus = 'S',
                    txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                    senttime  = systimestamp
     WHERE orgorderid = v_orgorderid AND oodstatus <> 'S';
     UPDATE odmast SET execqtty    = 0,
                       matchamt    = 0,
                       execamt     = 0,
                       orstatus    = '6',
                       porstatus   = porstatus || orstatus,
                       feedbackmsg = v_msgreject
     WHERE orderid = v_orgorderid;
     --xu ly cho phep dat lai lenh sua
     DELETE odchanging WHERE orderid = v_orgorderid;
     UPDATE fomast SET status = 'R', feedbackmsg = v_msgreject WHERE orgacctno = v_orgorderid;
  END IF;

  IF pv_RefMsgType = 'AJ' THEN -- Tu choi xac nhan (confirm/reject) lenh thoa thuan
     IF v_orgorderid IS NOT NULL THEN
        UPDATE ood SET oodstatus = 'S',
                       txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                       senttime  = systimestamp
        WHERE orgorderid = v_orgorderid and oodstatus <> 'S';
        SELECT remainqtty INTO v_qtty FROM odmast WHERE orderid = v_orgorderid;
        --Giai toa tien /ck
        CONFIRM_CANCEL_NORMAL_ORDER(v_orgorderid, v_qtty, v_checkProcess);
        IF NOT v_checkProcess THEN
           plog.error(pkgctx, 'Giai toa tien /ck khong thanh cong v_orgorderid: ' || v_orgorderid ||', v_qtty: '|| v_qtty);
           plog.setbeginsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
           RAISE errnums.E_SYSTEM_ERROR;
        END IF;
        UPDATE odmast SET execqtty    = 0,
                          matchamt    = 0,
                          execamt     = 0,
                          orstatus    = '6',
                          porstatus   = porstatus || orstatus,
                          feedbackmsg = v_msgreject
        WHERE orderid = v_orgorderid;
     END IF;
     -- Active lai thong bao lenh thoa thuan
     UPDATE orderptack SET status = 'N', issend = 'N' WHERE confirmnumber = v_order_number;
  END IF;

  IF pv_RefMsgType = '6' THEN -- Tu choi yeu cau(New/Cancel) lenh quang cao
     UPDATE orderptadv SET status = 'R', sendtime = to_char(SYSDATE, 'HH24MISS')
     WHERE ioiid = v_RefKey;
  END IF;
  plog.setendsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
EXCEPTION WHEN OTHERS THEN
  plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'CONFIRM_REJECT_MESSSAGE');
  RAISE errnums.E_SYSTEM_ERROR;
END;

PROCEDURE MATCHING_NORMAL_ORDER (
    pv_orderid            IN   VARCHAR2,
    pv_side               IN   VARCHAR2,
    pv_deal_volume        IN   NUMBER,
    pv_deal_price         IN   NUMBER,
    pv_confirm_number     IN   VARCHAR2,
    pv_CheckProcess       IN OUT BOOLEAN
)
AS
    v_tltxcd             VARCHAR2 (30);
    v_txnum              VARCHAR2 (30);
    v_txdate             VARCHAR2 (30);
    v_tlid               VARCHAR2 (30);
    v_brid               VARCHAR2 (30);
    v_ipaddress          VARCHAR2 (30);
    v_wsname             VARCHAR2 (30);
    v_txtime             VARCHAR2 (30);
    mv_strorgorderid     VARCHAR2 (30);
    mv_strcodeid         VARCHAR2 (30);
    mv_strsymbol         VARCHAR2 (30);
    mv_strcustodycd      VARCHAR2 (30);
    mv_strbors           VARCHAR2 (30);
    mv_strnorp           VARCHAR2 (30);
    mv_straorn           VARCHAR2 (30);
    mv_strafacctno       VARCHAR2 (30);
    mv_strciacctno       VARCHAR2 (30);
    mv_strseacctno       VARCHAR2 (30);
    mv_reforderid        VARCHAR2 (30);
    mv_refcustcd         VARCHAR2 (30);
    mv_strclearcd        VARCHAR2 (30);
    mv_strexprice        NUMBER (10);
    mv_strexqtty         NUMBER (10);
    mv_strprice          NUMBER (10);
    mv_strqtty           NUMBER (10);
    mv_strremainqtty     NUMBER (10);
    mv_strclearday       NUMBER (10);
    mv_strsecuredratio   NUMBER (10,2);
    mv_strconfirm_no     VARCHAR2 (30);
    mv_strmatch_date     VARCHAR2 (30);
    mv_desc              VARCHAR2 (30);
    v_strduetype         VARCHAR (2);
    v_matched            NUMBER (10,2);
    v_ex                 EXCEPTION;
    v_refconfirmno       VARCHAR2 (30);
    mv_mtrfday                NUMBER(10);
    mv_strtradeplace      VARCHAR2(3);
    mv_dbltrfbuyext      number(20,0);
    mv_dbltrfbuyrate      number(20,4);
    mv_strtrfstatus      VARCHAR2(1);
    mv_dblCancelQtty     NUMBER(30);
    v_strcorebank char(1);

    mv_dblBratio       odmast.bratio%TYPE;
    mv_dblOldAright    stschd.aright%TYPE;
    mv_dblNewAright    stschd.aright%TYPE;
    mv_dblAdvRate      NUMBER(20,4);
    mv_dblADVANCEDAYS  NUMBER;
    mv_dblVATRATE      NUMBER;
    mv_dblExecAmt      cimast.execbuyamt%TYPE;
    mv_dblFeeAmt       cimast.execfeevatsellamt%TYPE;
    mv_dblVatAmt       cimast.execfeevatsellamt%TYPE;
    mv_dblAdvFeeAmt    cimast.execfeevatsellamt%TYPE;
    mv_IsAdvAllow   CHAR(1) := 'Y';
    mv_dblGetDueDate Date;
    mv_AdvDays number;
    mv_dblIsbuyin odmast.isbuyin%type;
    mv_count number;
    mv_trExectype       VARCHAR2 (30);
    mv_dblWhTax      NUMBER;
    mv_cfVat cfmast.vat%type;
    mv_cfWhtax cfmast.whtax%type;

    Cursor c_Odmast(v_OrgOrderID Varchar2) Is
    SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
    FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
    vc_Odmast c_Odmast%Rowtype;
BEGIN
    plog.setbeginsection (pkgctx, 'MATCHING_NORMAL_ORDER');

    --0 lay cac tham so
    v_brid := '0000';
    v_tlid := '0000';
    v_ipaddress := 'HOST';
    v_wsname := 'HOST';
    v_tltxcd := '8804';
    --TungNT modified - for T2 late send money
    mv_strtradeplace:='001';
    mv_dbltrfbuyext:=0;
    mv_dbltrfbuyrate:=0;
    mv_strtrfstatus:='Y';
    --End
    IF pv_deal_price <= 0 OR pv_deal_volume <= 0 THEN
      pv_CheckProcess := FALSE;
      plog.error(pkgctx,'Thong Tin Khop Khong Hop Le orderid '||mv_strorgorderid || ',pv_confirm_number=' || pv_confirm_number);
      plog.setendsection (pkgctx, 'MATCHING_NORMAL_ORDER');
      RETURN;
    END IF;

    SELECT '8080'
           || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
               LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
               6
              )
    INTO v_txnum
    FROM DUAL;

    SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS') INTO v_txtime FROM DUAL;
    SELECT varvalue INTO v_txdate FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT varvalue INTO mv_dblADVANCEDAYS FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'ADVANCEDAYS';
    --mv_dblADVANCEDAYS:=360;
    SELECT varvalue INTO mv_dblVATRATE FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'ADVSELLDUTY';
    SELECT varvalue INTO mv_dblWhTax FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'WHTAX';

    --Lay thong tin lenh goc
    BEGIN
      SELECT od.remainqtty, od.cancelqtty + od.adjustqtty, sb.codeid, sb.symbol, ood.custodycd,
           ood.bors, ood.norp, ood.aorn, od.afacctno,
           od.ciacctno, od.seacctno, '', '',
           od.clearcd, ood.price, ood.qtty, pv_deal_price,
           pv_deal_volume, od.clearday, od.bratio,
           pv_confirm_number, v_txdate, '', typ.mtrfday,
           ss.tradeplace,0 /*af.*/mv_dblCancelQtty , 0 /*af.*/trfbuyrate, od.bratio,
           CASE WHEN CF.CUSTATCOM ='Y' and nvl(od.grporder,'N')<>'Y' THEN 'Y' ELSE 'N' END,
           od.isbuyin, od.exectype, od.feeacr, cf.vat , cf.whtax
        INTO mv_strremainqtty, mv_dblCancelQtty, mv_strcodeid, mv_strsymbol, mv_strcustodycd,
           mv_strbors, mv_strnorp, mv_straorn, mv_strafacctno,
           mv_strciacctno, mv_strseacctno, mv_reforderid, mv_refcustcd,
           mv_strclearcd, mv_strexprice, mv_strexqtty, mv_strprice,
           mv_strqtty, mv_strclearday, mv_strsecuredratio,
           mv_strconfirm_no, mv_strmatch_date, mv_desc,mv_mtrfday,
           mv_strtradeplace,mv_dbltrfbuyext, mv_dbltrfbuyrate, mv_dblBratio,
           mv_IsAdvAllow,mv_dblIsbuyin,mv_trExectype,mv_dblFeeAmt,mv_cfVat,mv_cfWhtax
        FROM odmast od, ood, securities_info sb,odtype typ,afmast af,sbsecurities ss, cfmast cf
        WHERE od.orderid = ood.orgorderid and od.actype = typ.actype
        AND od.codeid = sb.codeid and od.afacctno=af.acctno and od.codeid=ss.codeid
        AND af.custid = cf.custid
        AND orderid = pv_orderid;

      SELECT adt.advrate + adt.advbankrate
      INTO mv_dblAdvRate
      FROM afmast af, aftype aft, adtype adt
      WHERE af.actype = aft.actype AND aft.adtype = adt.actype
      AND af.acctno = mv_strafacctno;
    EXCEPTION
      WHEN OTHERS THEN
        pv_CheckProcess := FALSE;
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.error(pkgctx,'Matching Lay thong tin lenh goc orderid '||mv_strorgorderid);
        plog.setendsection (pkgctx, 'MATCHING_NORMAL_ORDER');
        RETURN;
    END;

    IF mv_dbltrfbuyext>0 THEN -- tra cham
      mv_strtrfstatus:='N';
    END IF;

    Begin
         INSERT INTO iodqueue (TXDATE,BORS,CONFIRM_NO,SYMBOL,NORP)
         VALUES(TO_DATE (v_txdate, 'DD/MM/RRRR'),mv_strbors,mv_strconfirm_no,mv_strsymbol,mv_strnorp);
    EXCEPTION
      WHEN OTHERS THEN
        pv_CheckProcess := FALSE;
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.setendsection (pkgctx, 'MATCHING_NORMAL_ORDER');
        RETURN;
    END;

    --Day vao stctradebook, stctradeallocation de khong bi khop lai:
    v_refconfirmno :='VS'||mv_strbors||mv_strconfirm_no;
    INSERT INTO stctradeallocation (txdate, txnum, refconfirmnumber, orderid, bors, volume, price, deltd )
    VALUES (to_date(v_txdate,'dd/mm/RRRR'), v_txnum, v_refconfirmno, mv_strorgorderid, mv_strbors, mv_strqtty, mv_strprice, 'N');

    mv_desc := 'Matching order';

    IF mv_strremainqtty >= mv_strqtty
    THEN
        --thuc hien khop voi ket qua tra ve

        --1 them vao trong tllog
        INSERT INTO tllog (autoid, txnum, txdate, txtime, brid,
            tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
            tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
            offtime, off_line, deltd, brdate,
            busdate, msgsts, ovrsts, ipaddress,
            wsname, batchname, txdesc
           )
        VALUES (seq_tllog.NEXTVAL, v_txnum,
            TO_DATE (v_txdate, 'DD/MM/RRRR'), v_txtime, v_brid,
            v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
            '', '', '1', pv_orderid, mv_strqtty, '',
            v_txtime, 'N', 'N', TO_DATE (v_txdate, 'DD/MM/RRRR'),
            TO_DATE (v_txdate, 'DD/MM/RRRR'), '', '', v_ipaddress,
            v_wsname, 'DAY', mv_desc
           );

        --tHEM VAO TRONG TLLOGFLD
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '03', 0, mv_strorgorderid, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '80', 0, mv_strcodeid, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '81', 0, mv_strsymbol, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '82', 0, mv_strcustodycd, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '04', 0, mv_strafacctno, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '11', mv_strqtty, NULL, NULL );
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '10', mv_strprice, NULL,NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '30', 0, mv_desc, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '05', 0, mv_strafacctno, NULL);
        INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '16', 0, TRIM(pv_CONFIRM_NUMBER), NULL);

        IF mv_strbors = 'B' THEN
            INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '86', mv_strprice*mv_strqtty, NULL, NULL);
            INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '87', mv_strqtty, NULL, NULL);
        ELSE
            INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '86', 0, NULL, NULL);
            INSERT INTO tllogfld (autoid, txnum, txdate, fldcd, nvalue, cvalue, txdesc) VALUES (seq_tllogfld.NEXTVAL, v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), '87', 0, NULL, NULL);
        END IF;

        --3 THEM VAO TRONG IOD
        INSERT INTO iod
           (orgorderid, codeid, symbol,
            custodycd, bors, norp,
            txdate, txnum, aorn,
            price, qtty, exorderid, refcustcd,
            matchprice, matchqtty, confirm_no,txtime
           )
        VALUES (pv_orderid, mv_strcodeid, mv_strsymbol,
            mv_strcustodycd, mv_strbors, mv_strnorp,
            TO_DATE (v_txdate, 'DD/MM/RRRR'), v_txnum, mv_straorn,
            mv_strexprice, mv_strexqtty, mv_reforderid, mv_refcustcd,
            mv_strprice, mv_strqtty, mv_strconfirm_no,to_char(sysdate,'hh24:mi:ss')
           );

    ---- GHI NHAT VAO BANG TINH GIA VON CUA TUNG LAN KHOP.
        --SECMAST_GENERATE(v_txnum, v_txdate, v_txdate, mv_strafacctno, mv_strcodeid, 'T', (CASE WHEN mv_strbors = 'B' THEN 'I' ELSE 'O' END), null, mv_strorgorderid, mv_strqtty, mv_strprice, 'Y');
        INSERT INTO SECMAST_GENERATE_LOG (TXNUM,TXDATE,BUSDATE,AFACCTNO,SYMBOL,SECTYPE,PTYPE,CAMASTID,ORDERID,QTTY,COSTPRICE,MAPAVL,STATUS,LOGTIME,APPLYTIME)
        VALUES(v_txnum,v_txdate,v_txdate,mv_strafacctno,mv_strcodeid,'T',(CASE WHEN mv_strbors = 'B' THEN 'I' ELSE 'O' END),NULL,mv_strorgorderid,mv_strqtty,mv_strprice,'Y','P',SYSTIMESTAMP,NULL);

        -- if instr('/NS/MS/SS/', :newval.exectype) > 0 then
        If mv_strbors = 'S' then
            -- quyet.kieu : Them cho LINHLNB 21/02/2012
            -- Begin Danh sau tai san LINHLNB
            INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG, QTTY)
            VALUES( mv_strafacctno,mv_strcodeid ,mv_strprice * mv_strqtty ,v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'),NULL,systimestamp,pv_orderid,'M',mv_strqtty);
            -- End Danh dau tai san LINHLNB
        End if;


        --4 CAP NHAT STSCHD
        SELECT COUNT (*), MAX(aright)
        INTO v_matched, mv_dblOldAright
        FROM stschd
        WHERE orgorderid = pv_orderid AND deltd <> 'Y';
        mv_dblGetDueDate := getduedate(TO_DATE (v_txdate, 'DD/MM/RRRR'),mv_strclearcd,'000',mv_strclearday);
        mv_AdvDays := case when  mv_dblGetDueDate - TO_DATE (v_txdate, 'DD/MM/RRRR') = 0 and to_number(mv_strclearday) > 0 then 1 else mv_dblGetDueDate - TO_DATE (v_txdate, 'DD/MM/RRRR') end;

        IF mv_strbors = 'B'
        THEN                                                          --Lenh mua
            --Tao lich thanh toan chung khoan
            v_strduetype := 'RS';

            IF v_matched > 0
            THEN
               UPDATE stschd
                  SET qtty = qtty + mv_strqtty,
                      amt = amt + mv_strprice * mv_strqtty
                WHERE orgorderid = pv_orderid AND duetype = v_strduetype;
            ELSE
               INSERT INTO stschd
                           (autoid, orgorderid, codeid,
                            duetype, afacctno, acctno,
                            reforderid, txnum,
                            txdate, clearday,
                            clearcd, amt, aamt,
                            qtty, aqtty, famt, status, deltd, costprice, cleardate
                           )
                    VALUES (seq_stschd.NEXTVAL, pv_orderid, mv_strcodeid,
                            v_strduetype, mv_strafacctno, mv_strseacctno,
                            mv_reforderid, v_txnum,
                            TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strclearday,
                            mv_strclearcd, mv_strprice * mv_strqtty, 0,
                            mv_strqtty, 0, 0, 'N', 'N', 0, mv_dblGetDueDate
                           );
            END IF;

            v_strduetype := 'SM';

            IF v_matched > 0
            THEN
               UPDATE stschd
                  SET qtty = qtty + mv_strqtty,
                      amt = amt + mv_strprice * mv_strqtty
                WHERE orgorderid = pv_orderid AND duetype = v_strduetype;
            ELSE
               INSERT INTO stschd

                      (autoid, orgorderid, codeid,
                       duetype, afacctno, acctno,
                       reforderid, txnum,
                       txdate, clearday,
                       clearcd, amt, aamt,
                       qtty, aqtty, famt, status, deltd, costprice, cleardate--,trfbuydt--,trfbuysts--, trfbuyrate--, trfbuyext

                      )
                VALUES (seq_stschd.NEXTVAL, pv_orderid, mv_strcodeid,
                       v_strduetype, mv_strafacctno, mv_strafacctno,
                       mv_reforderid, v_txnum,
                       TO_DATE (v_txdate, 'DD/MM/RRRR'), 0,
                       mv_strclearcd, mv_strprice * mv_strqtty, 0,
                       mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/RRRR'),mv_strclearcd,'000',least(mv_strclearday,greatest(mv_mtrfday,mv_dbltrfbuyext)))--,
                       --least(getduedate(TO_DATE (v_txdate, 'DD/MM/RRRR'),mv_strclearcd,'000',mv_dbltrfbuyext),getduedate(TO_DATE (v_txdate, 'DD/MM/RRRR'),mv_strclearcd,'000',mv_strclearday))--,mv_strtrfstatus--, mv_dbltrfbuyrate--, mv_dbltrfbuyext
                      );
            END IF;

        ELSE                                                          --Lenh ban
        --Tao lich thanh toan chung khoan
            v_strduetype := 'SS';

            IF v_matched > 0
            THEN
               UPDATE stschd
                  SET qtty = qtty + mv_strqtty,
                      amt = amt + mv_strprice * mv_strqtty
                WHERE orgorderid = pv_orderid AND duetype = v_strduetype;
            ELSE
               INSERT INTO stschd
                           (autoid, orgorderid, codeid,
                            duetype, afacctno, acctno,
                            reforderid, txnum,
                            txdate, clearday,
                            clearcd, amt, aamt,
                            qtty, aqtty, famt, status, deltd, costprice, cleardate
                           )
                    VALUES (seq_stschd.NEXTVAL, pv_orderid, mv_strcodeid,
                            v_strduetype, mv_strafacctno, mv_strseacctno,
                            mv_reforderid, v_txnum,
                            TO_DATE (v_txdate, 'DD/MM/RRRR'), 0,
                            mv_strclearcd, mv_strprice * mv_strqtty, 0,
                            mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/RRRR'),mv_strclearcd,'000',0)
                           );
            END IF;

            --Tao lich thanh toan tien
            v_strduetype := 'RM';

            IF v_matched > 0
            THEN
               UPDATE stschd
                  SET qtty = qtty + mv_strqtty,
                      amt = amt + mv_strprice * mv_strqtty
                WHERE orgorderid = pv_orderid AND duetype = v_strduetype
                RETURNING aright INTO mv_dblNewAright; -- New aright
            ELSE
               INSERT INTO stschd
                           (autoid, orgorderid, codeid,
                            duetype, afacctno, acctno,
                            reforderid, txnum,
                            txdate, clearday,
                            clearcd, amt, aamt,
                            qtty, aqtty, famt, status, deltd, costprice, cleardate
                           )
                    VALUES (seq_stschd.NEXTVAL, pv_orderid, mv_strcodeid,
                            v_strduetype, mv_strafacctno, mv_strafacctno,
                            mv_reforderid, v_txnum,
                            TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strclearday,
                            mv_strclearcd, mv_strprice * mv_strqtty, 0,
                            mv_strqtty, 0, 0, 'N', 'N', 0, mv_dblGetDueDate
                           )
               RETURNING aright INTO mv_dblNewAright;
            END IF;
        END IF;

        mv_dblExecAmt := mv_strqtty * mv_strprice;
        mv_dblFeeAmt  :=  case when mv_dblFeeAmt > 0 then  mv_dblFeeAmt else mv_dblExecAmt *  (mv_dblBratio - 100) end  / 100;
        UPDATE odmast
        SET orstatus = '4',
            PORSTATUS = PORSTATUS || orstatus,
            execqtty = execqtty + mv_strqtty,
            remainqtty = remainqtty - mv_strqtty,
            execamt = execamt + mv_dblExecAmt,
            matchamt = matchamt + mv_dblExecAmt
        WHERE orderid = pv_orderid;

        IF mv_strbors = 'B' THEN
            UPDATE semast se SET se.execbuyqtty = se.execbuyqtty + mv_strqtty
            WHERE acctno = mv_strseacctno;
            UPDATE cimast ci
            SET ci.execbuyamt = ci.execbuyamt + mv_dblExecAmt,
                ci.execfeebuyamt = ci.execfeebuyamt + mv_dblFeeAmt
            WHERE ci.acctno = mv_strafacctno;
        else
           select (decode(mv_cfVat,'Y',mv_dblVATRATE,'N',0)+decode(mv_cfWhtax,'Y',mv_dblWhTax,'N',0)) * mv_dblExecAmt/100  + (NVL(mv_dblNewAright, 0) - NVL(mv_dblOldAright, 0))
                 into mv_dblVatAmt from dual ;
            mv_dblAdvFeeAmt := (mv_dblExecAmt - mv_dblFeeAmt - mv_dblVatAmt) * mv_AdvDays * mv_dblAdvRate / 100  / ( mv_dblADVANCEDAYS + mv_AdvDays * (mv_dblAdvRate/100));

            UPDATE semast se
            SET se.execsellqtty = se.execsellqtty + case when (mv_trExectype = 'MS') then 0 else 1 end *  mv_strqtty,
                se.execmsqtty = se.execmsqtty +  case when (mv_trExectype = 'MS') then 1 else 0 end *  mv_strqtty
            WHERE acctno = mv_strseacctno;
            UPDATE cimast ci
              SET ci.execsellamt = ci.execsellamt + mv_dblExecAmt,
                  ci.execfeevatsellamt = ci.execfeevatsellamt + mv_dblFeeAmt
              WHERE ci.acctno = mv_strafacctno;

           IF mv_IsAdvAllow = 'Y' THEN
              MERGE INTO cimastext  ext
              USING ( SELECT mv_strafacctno afacctno,
               case when mv_AdvDays = 0 then mv_dblExecAmt - mv_dblFeeAmt - mv_dblVatAmt else 0 END advamtbuyin,
               case when mv_AdvDays = 0 then mv_dblAdvFeeAmt else 0 END advfeebuyin,
               case when mv_AdvDays = 1 then mv_dblExecAmt - mv_dblFeeAmt - mv_dblVatAmt else 0 END advamtt0,
               case when mv_AdvDays = 1 then mv_dblAdvFeeAmt else 0 END advfeet0,
               case when mv_AdvDays >1 and mv_strclearday = 1 then mv_dblExecAmt - mv_dblFeeAmt - mv_dblVatAmt  else 0 end advamtt1,
               case when mv_AdvDays >1 and mv_strclearday = 1 then mv_dblAdvFeeAmt else 0 end advfeet1,
               case when mv_AdvDays >1 and mv_strclearday = 2 then mv_dblExecAmt - mv_dblFeeAmt - mv_dblVatAmt  else 0 end advamtt2,
               case when mv_AdvDays >1 and mv_strclearday = 2 then mv_dblAdvFeeAmt else 0 end advfeet2,
               case when mv_AdvDays >1 and mv_strclearday > 2 then mv_dblExecAmt - mv_dblFeeAmt - mv_dblVatAmt else 0 end advamttn,
               case when mv_AdvDays >1 and mv_strclearday > 2 then mv_dblAdvFeeAmt else 0 end advfeetn
                FROM dual
                  ) ci ON (ext.afacctno = ci.afacctno)
               WHEN MATCHED THEN
              UPDATE SET ext.advamtbuyin = ext.advamtbuyin + ci.advamtbuyin,
                         ext.advfeebuyin = ext.advfeebuyin + ci.advfeebuyin,
                         ext.advamtt0 = ext.advamtt0 + ci.advamtt0,
                         ext.advfeet0 = ext.advfeet0 + ci.advfeet0,
                         ext.advamtt1 = ext.advamtt1 + ci.advamtt1,
                         ext.advfeet1 = ext.advfeet1 + ci.advfeet1,
                         ext.advamtt2 = ext.advamtt2 + ci.advamtt2,
                         ext.advfeet2 = ext.advfeet2 + ci.advfeet2,
                         ext.advamttn = ext.advamttn + ci.advamttn,
                         ext.advfeetn = ext.advfeetn + ci.advfeetn
              WHEN NOT MATCHED THEN
                INSERT (afacctno, advamtbuyin, advfeebuyin, advamtt0, advfeet0, advamtt1, advfeet1, advamtt2, advfeet2, advamttn, advfeetn)
                VALUES (ci.afacctno, ci.advamtbuyin, ci.advfeebuyin, ci.advamtt0, ci.advfeet0, ci.advamtt1, ci.advfeet1, ci.advamtt2, ci.advfeet2, ci.advamttn, ci.advfeetn);
           END IF;
        END IF;

        /*For v_Session in (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
        Loop
            UPDATE odmast
            SET HOSESESSION =v_Session.SYSVALUE
            WHERE orderid = pv_orderid And NVL(HOSESESSION,'N') ='N';
        End Loop;*/

        --Neu khop het va co lenh huy cua lenh da khop thi cap nhat thanh refuse
        IF mv_strremainqtty = mv_strqtty AND mv_dblCancelQtty = 0 THEN
            UPDATE odmast
            SET ORSTATUS = '0',
                porstatus = porstatus || orstatus
            WHERE REFORDERID = pv_orderid AND orstatus <> '6';
        END IF;

        --Cap nhat tinh gia von
        IF mv_strbors = 'B' THEN
            UPDATE semast
            SET dcramt = dcramt + mv_strqtty*mv_strprice, dcrqtty = dcrqtty+mv_strqtty
            WHERE acctno = mv_strseacctno;
        END IF;

        INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid) VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strorgorderid, '0013', mv_strqtty, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);
        INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid) VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strorgorderid, '0011', mv_strqtty, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);
        INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid) VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strorgorderid, '0028', mv_strqtty * mv_strprice, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);
        INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid) VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strorgorderid, '0034', mv_strqtty * mv_strprice, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);

        IF mv_strbors = 'B' THEN
            INSERT INTO setran (txnum, txdate, acctno, txcd, namt, camt, REF, deltd, autoid,TLTXCD) VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strseacctno, '0051', mv_strqtty * mv_strprice, NULL, NULL, 'N', seq_setran.NEXTVAL, v_tltxcd);
            INSERT INTO setran (txnum, txdate, acctno, txcd, namt, camt, REF, deltd, autoid,TLTXCD) VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), mv_strseacctno, '0052', mv_strqtty, NULL, NULL, 'N', seq_setran.NEXTVAL,'8804');
        END IF;

    END IF;
    --Cap nhat cho GTC
    OPEN C_ODMAST(pv_orderid);
    FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
        UPDATE FOMAST SET REMAINQTTY= REMAINQTTY - MV_STRQTTY
                          ,EXECQTTY= EXECQTTY + MV_STRQTTY
                          ,EXECAMT=  EXECAMT + MV_STRPRICE * MV_STRQTTY
        WHERE ACCTNO= VC_ODMAST.FOACCTNO;
    END IF;
    CLOSE C_ODMAST;

    plog.setendsection (pkgctx, 'MATCHING_NORMAL_ORDER');
EXCEPTION WHEN OTHERS THEN
    pv_CheckProcess := FALSE;
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'MATCHING_NORMAL_ORDER');
    ROLLBACK;
END;
PROCEDURE CONFIRM_CANCEL_NORMAL_ORDER (
    pv_orderid      IN VARCHAR2,
    pv_qtty         IN NUMBER,
    pv_CheckProcess IN OUT BOOLEAN
)
IS
    v_edstatus         VARCHAR2 (30);
    v_strCodeid        VARCHAR2 (30);
    v_tltxcd           VARCHAR2 (30);
    v_txnum            VARCHAR2 (30);
    v_txdate           VARCHAR2 (30);
    v_tlid             VARCHAR2 (30);
    v_brid             VARCHAR2 (30);
    v_ipaddress        VARCHAR2 (30);
    v_wsname           VARCHAR2 (30);
    v_symbol           VARCHAR2 (30);
    v_afaccount        VARCHAR2 (30);
    v_seacctno         VARCHAR2 (30);
    v_price            NUMBER (10,2);
    v_quantity         NUMBER (10,2);
    v_bratio           NUMBER (10,2);

    v_cancelqtty       NUMBER (10,2);
    v_amendmentqtty    NUMBER (10,2);
    v_amendmentprice   NUMBER (10,2);
    v_matchedqtty      NUMBER (10,2);
    v_execqtty         NUMBER (10,2);
    v_trExectype       VARCHAR2 (30);
    v_reforderid       VARCHAR2 (30);
    v_tradeunit        NUMBER (10,2);
    v_desc             VARCHAR2 (300);
    v_txtime           VARCHAR2 (30);
    v_Count_lenhhuy    Number(2);
    v_OrderQtty_Cur    Number(10);
    v_RemainQtty_Cur   Number(10);
    v_ExecQtty_Cur     Number(10);
    v_CancelQtty_Cur   Number(10);
    v_Orstatus_Cur     VARCHAR2(10);
    v_err              VARCHAR2(300);
    Cursor c_Odmast(v_OrgOrderID Varchar2) Is
    SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
    FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
    vc_Odmast c_Odmast%Rowtype;

BEGIN
    plog.setBEGINsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
    --0 lay cac tham so
    v_brid := '0000';
    v_tlid := '0000';
    v_ipaddress := 'HOST';
    v_wsname := 'HOST';
    v_cancelqtty := pv_qtty;
    --Kiem tra thoa man dieu kien huy
    BEGIN
        SELECT ORDERQTTY,REMAINQTTY,EXECQTTY,CANCELQTTY,ORSTATUS,Exectype
        INTO V_ORDERQTTY_CUR,V_REMAINQTTY_CUR,V_EXECQTTY_CUR,V_CANCELQTTY_CUR,V_ORSTATUS_CUR,v_trExectype
        FROM ODMAST
        WHERE ORDERID = PV_ORDERID;
    EXCEPTION
      WHEN OTHERS THEN
        pv_CheckProcess := FALSE;
        plog.error(pkgctx, 'CONFIRM_CANCEL: Error when trying get informations of original order PV_ORDERID='||PV_ORDERID);
        plog.setendsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
        RETURN;
    END;
    IF V_REMAINQTTY_CUR - v_cancelqtty < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR THEN
        pv_CheckProcess := FALSE;
        plog.error(pkgctx, 'CONFIRM_CANCEL: SAI DK SUA PV_ORDERID='||PV_ORDERID);
        plog.setendsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
        RETURN;
    END IF;

    --Lenh huy thong thuong: Co lenh huy 1C
    SELECT count(*) INTO v_Count_lenhhuy
    FROM odmast
    WHERE reforderid = pv_orderid
    AND exectype IN ('CB','CS') AND ORSTATUS<>'6';

    IF v_Count_lenhhuy >0 Then
        SELECT (CASE
                  WHEN exectype = 'CB'
                     THEN '8890'
                  ELSE '8891'
               END), sb.symbol,
              od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
              0, od.quoteprice, 0, od.orderqtty - pv_qtty,
              od.reforderid, sb.tradeunit, od.edstatus,od.codeid
         INTO v_tltxcd, v_symbol,
              v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
              v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
              v_reforderid, v_tradeunit, v_edstatus , v_strCodeid
         FROM odmast od, securities_info sb
        WHERE od.codeid = sb.codeid AND reforderid = pv_orderid
         AND OD.orstatus<>'6';
    ELSE
        --Giai toa
        SELECT (CASE
                  WHEN EXECTYPE LIKE '%B'
                     THEN '8808'
                  ELSE '8807'
               END), sb.symbol,
              od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
              0, od.quoteprice, 0, od.orderqtty - pv_qtty,
              od.reforderid, sb.tradeunit, od.edstatus
         INTO v_tltxcd, v_symbol,
              v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
              v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
              v_reforderid, v_tradeunit, v_edstatus
         FROM odmast od, securities_info sb
         WHERE od.codeid = sb.codeid AND orderid = pv_orderid
          AND OD.orstatus<>'6';
    END IF;

    --NEU CHUA BI HUY THI KHI NHAN DUOC MESSAGE TRA VE SE THUC HIEN HUY LENH
    SELECT varvalue INTO v_txdate FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    SELECT    '8080'
         || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                    LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                    6
                   )
    INTO v_txnum
    FROM DUAL;

    SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
    INTO v_txtime
    FROM DUAL;

    --1 them vao trong tllog
    INSERT INTO tllog
              (autoid, txnum,
               txdate, txtime, brid,
               tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
               tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
               offtime, off_line, deltd, brdate,
               busdate, msgsts, ovrsts, ipaddress,
               wsname, batchname, txdesc
              )
    VALUES (seq_tllog.NEXTVAL, v_txnum,
               TO_DATE (v_txdate, 'DD/MM/RRRR'), v_txtime, v_brid,
               v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
               '', '', '1', pv_orderid, v_quantity, '',
               v_txtime, 'N', 'N', TO_DATE (v_txdate, 'DD/MM/RRRR'),
               TO_DATE (v_txdate, 'DD/MM/RRRR'), '', '', v_ipaddress,
               v_wsname, 'DAY', v_desc
              );
    --them vao tllogfld
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'07',0,v_symbol,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'03',0,v_afaccount,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'04',0,pv_orderid,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'06',0,v_seacctno,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'08',0,pv_orderid,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'14',v_cancelqtty,NULL,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'11',v_price,NULL,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'12',v_quantity,NULL,NULL);

    --TungNT added , giai toa khi huy lenh
    BEGIN
        If (v_tltxcd = '8890' OR v_tltxcd = '8808') then
            cspks_odproc.pr_RM_UnholdCancelOD(pv_orderid, v_cancelqtty, v_err);
        End if;
    EXCEPTION WHEN OTHERS THEN
        plog.error(pkgctx,'pr_RM_UnholdCancelOD pv_orderid :' || pv_orderid || ' qtty : ' || v_cancelqtty);
    END;
    --End

    If v_Count_lenhhuy >0 then
        v_edstatus := 'W';
        UPDATE odmast
        SET edstatus = v_edstatus
        WHERE orderid = pv_orderid;

        UPDATE OOD SET OODSTATUS = 'S'
        WHERE   ORGORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid)
        and OODSTATUS <> 'S';
    Else
        Update OOD set OODSTATUS ='S' where ORGORDERID =pv_orderid And OODSTATUS ='B';
        Update ODMAST set ORSTATUS ='5' where Orderqtty =Remainqtty And ORDERID =pv_orderid;
    End if;
    --3 CAP NHAT TRAN VA MAST
    UPDATE odmast
    SET cancelqtty = cancelqtty + v_cancelqtty,
        remainqtty = remainqtty - v_cancelqtty
    WHERE orderid = pv_orderid;

    INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid)
    VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), pv_orderid, '0014', v_cancelqtty, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);

    INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid)
    VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), pv_orderid, '0011', v_cancelqtty, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);

    If v_tltxcd = '8890' OR v_tltxcd='8808' then
        -- Danh sau tai san LINHLNB
        INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG,QTTY)
        VALUES( v_afaccount,v_strCodeid ,v_cancelqtty * v_price ,v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'),NULL,systimestamp,pv_orderid,'C',v_cancelqtty);
    End if ;

    --Cap nhat cho GTC
    OPEN C_ODMAST(pv_orderid);
    FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND AND v_Count_lenhhuy >0  THEN --2013.08.12 Sua neu yeu cau huy thi moi cap nhat de backup sang hist.
        UPDATE FOMAST SET   REMAINQTTY= REMAINQTTY - v_cancelqtty
                        ,cancelqtty= cancelqtty + v_cancelqtty
        WHERE ACCTNO= VC_ODMAST.FOACCTNO;
    END IF;
    CLOSE C_ODMAST;

    plog.setendsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
EXCEPTION WHEN others THEN
    pv_CheckProcess := FALSE;
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'CONFIRM_CANCEL_NORMAL_ORDER PV_ORDERID='||PV_ORDERID);
    plog.setendsection (pkgctx, 'CONFIRM_CANCEL_NORMAL_ORDER');
    ROLLBACK;
END CONFIRM_CANCEL_NORMAL_ORDER;

PROCEDURE CONFIRM_REPLACE_NORMAL_ORDER (
    PV_ORDERID      IN VARCHAR2,
    pv_qtty         IN NUMBER,
    pv_price        IN NUMBER,
    pv_LeavesQty    IN NUMBER,
    pv_cumqty       IN NUMBER,
    pv_ctci_order   IN VARCHAR,
    PV_CONFIRM_NUMBER  VARCHAR2,
    pv_CheckProcess IN OUT BOOLEAN
)
IS
   v_edstatus         VARCHAR2 (30);
   v_tltxcd           VARCHAR2 (30);
   v_txnum            VARCHAR2 (30);
   v_txdate           VARCHAR2 (30);
   v_tlid             VARCHAR2 (30);
   v_brid             VARCHAR2 (30);
   v_ipaddress        VARCHAR2 (30);
   v_wsname           VARCHAR2 (30);
   v_symbol           VARCHAR2 (30);
   v_afaccount        VARCHAR2 (30);
   v_seacctno         VARCHAR2 (30);
   v_price            NUMBER (10,2);
   v_quantity         NUMBER (10,2);
   v_bratio           NUMBER (10,2);
   v_oldbratio        NUMBER (10,2);
   v_cancelqtty       NUMBER (10,2);
   v_amendmentqtty    NUMBER (10,2);
   v_amendmentprice   NUMBER (10,2);
   v_matchedqtty      NUMBER (10,2);
   v_execqtty         NUMBER (10,2);
   v_reforderid       VARCHAR2 (30);
   v_tradeunit        NUMBER (10,2);
   v_desc             VARCHAR2 (300);
   v_bors             VARCHAR2 (30);
   v_txtime           VARCHAR2 (30);
   v_OrderQtty_Cur    Number(10);
   v_RemainQtty_Cur   Number(10);
   v_ExecQtty_Cur     Number(10);
   v_ReplaceQtty_Cur   Number(10);
   v_cumqty_cur       NUMBER(10);
   v_Orstatus_Cur     VARCHAR2(10);
   v_CustID           VARCHAR2 (30);
   v_Actype           VARCHAR2 (30);
   v_CodeID           VARCHAR2 (30);
   v_TimeType         VARCHAR2 (30);
   v_ExecType         VARCHAR2 (30);
   v_NorK             VARCHAR2 (30);
   v_ClearDay         VARCHAR2 (30);
   v_MATCHTYPE        VARCHAR2 (30);
   v_Via              VARCHAR2 (30);
   v_CLEARCD          VARCHAR2 (30);
   v_PRICETYPE        VARCHAR2 (30);
   v_CUSTODYCD        VARCHAR2 (30);
   v_LIMITPRICE       Number(10,2);
   v_VOUCHER          VARCHAR2 (30);
   v_CONSULTANT       VARCHAR2 (30);
   v_OrderID          VARCHAR2 (30);
   v_replaceqtty      Number(10,2);
   v_ex                 EXCEPTION;
   v_DFACCTNO         varchar(20);
   v_ISDISPOSAL       varchar(20);

   v_retlid           varchar2(10);
   v_blorderid        varchar2(50);
   v_isblorder        varchar2(2);
   v_HOSESSION        odmast.hosesession%TYPE;

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;
BEGIN
    plog.setbeginsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_replaceqtty := pv_LeavesQty;

    SELECT ORDERQTTY,REMAINQTTY,EXECQTTY,CANCELQTTY,ORSTATUS,Exectype,
        TLID,blorderid,isblorder,via, cumqty, hosesession
    INTO V_ORDERQTTY_CUR,V_REMAINQTTY_CUR,V_EXECQTTY_CUR,V_REPLACEQTTY_CUR,V_ORSTATUS_CUR,v_Exectype,
        v_tlid,v_blorderid,v_isblorder,v_Via, v_cumqty_cur, v_HOSESSION
    FROM ODMAST
    WHERE ORDERID =PV_ORDERID;

    -- Neu lenh Bloomberg thi lay so hieu lenh moi trong bl_odmast
    IF v_blorderid IS NOT NULL THEN
        SELECT od.blorderid INTO v_blorderid
        FROM odmast od
        WHERE od.reforderid = PV_ORDERID AND edstatus = 'A';
    END IF;

    SELECT (CASE WHEN exectype = 'AB' THEN '8890'
                ELSE '8891' END), sb.symbol,
          od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
          0, od.quoteprice, 0, od.orderqtty - pv_qtty,
          od.reforderid, sb.tradeunit, od.edstatus,custid,actype,timetype,
          NorK,MATCHTYPE,Via,CLEARDAY,CLEARCD,PRICETYPE,CUSTODYCD,
          OD.LIMITPRICE,VOUCHER,CONSULTANT, od.codeid
    INTO v_tltxcd, v_symbol,
          v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
          v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
          v_reforderid, v_tradeunit, v_edstatus,v_custid,v_actype,v_timetype,
          v_NorK,v_MATCHTYPE,v_Via,v_CLEARDAY,v_CLEARCD,v_PRICETYPE,v_CUSTODYCD,
          v_LIMITPRICE,v_VOUCHER,v_CONSULTANT,v_codeid
    FROM odmast od, ood ,  securities_info sb
    WHERE od.codeid = sb.codeid AND od.orderid = ood.orgorderid AND od.reforderid = pv_orderid
    AND OD.orstatus<>'6' and od.exectype in('AB','AS');

    SELECT bratio, DFACCTNO, ISDISPOSAL
    INTO v_oldbratio, v_DFACCTNO,v_ISDISPOSAL
    FROM odmast
    WHERE orderid = pv_orderid;


    SELECT varvalue INTO v_txdate FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    Select '0001'||to_char(to_date(v_txdate,'dd/mm/RRRR'),'ddmmrr')||lpad(SEQ_ODMAST.NEXTVAL,6,'0')
    Into v_OrderID From dual;

    SELECT    '8080'
     || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                6
               )
    INTO v_txnum
    FROM DUAL;

    SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS') INTO v_txtime FROM DUAL;

    --1 them vao trong tllog
    INSERT INTO tllog
          (autoid, txnum,
           txdate, txtime, brid,
           tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
           tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
           offtime, off_line, deltd, brdate,
           busdate, msgsts, ovrsts, ipaddress,
           wsname, batchname, txdesc
          )
    VALUES (seq_tllog.NEXTVAL, v_txnum,
           TO_DATE (v_txdate, 'DD/MM/RRRR'), v_txtime, v_brid,
           v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
           '', '', '1', pv_orderid, v_quantity, '',
           '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/RRRR'),
           TO_DATE (v_txdate, 'DD/MM/RRRR'), '', '', v_ipaddress,
           v_wsname, 'DAY', v_desc
          );
    --them vao tllogfld
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'07',0,v_symbol,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'03',0,v_afaccount,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'04',0,pv_orderid,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'06',0,v_seacctno,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'08',0,pv_orderid,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'14',v_cancelqtty,NULL,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'11',v_price,NULL,NULL);
    INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
    VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/RRRR'),'12',v_quantity,NULL,NULL);
    --2 THEM VAO TRONG TLLOGFLD

    v_edstatus := 'S';
    UPDATE odmast SET edstatus = v_edstatus WHERE orderid = pv_orderid;
    --Cap nhat lenh sua thanh da Send.
    UPDATE OOD SET OODSTATUS = 'S'
    WHERE ORGORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid)
    AND OODSTATUS <> 'S';

    --'TheNN, 18-Dec-2013
    --Cap nhat lai trang thai da sua cho lenh trung gian
    UPDATE ODMAST
    SET EDSTATUS = v_edstatus,
        ADJUSTQTTY = v_replaceqtty
    WHERE ORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid);
    --Ket thuc: TheNN, 18-Dec-2013
    ------------

    --3 CAP NHAT TRAN VA MAST
    IF v_quantity - v_replaceqtty - v_ExecQtty_Cur < 0 THEN
        pv_CheckProcess := FALSE;
        plog.error(pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER: sai dk khoi luong con lai='|| pv_orderid);
        plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
        RETURN;
    end if;

    UPDATE odmast
    SET adjustqtty = v_replaceqtty,
        remainqtty = v_quantity - v_replaceqtty - v_ExecQtty_Cur
    WHERE orderid = pv_orderid;
    INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid)
    VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), pv_orderid, '0014', v_cancelqtty, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);

    INSERT INTO odtran (txnum, txdate, acctno, txcd, namt, camt, acctref, deltd, REF, autoid)
    VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/RRRR'), pv_orderid, '0011', v_cancelqtty, NULL, NULL, 'N', NULL, seq_odtran.NEXTVAL);
    IF v_tltxcd = '8890'  THEN
        v_BORS :='B';
    Else
        v_BORS :='S';
    End if;

    --4 Sinh lenh moi.
    INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO
         ,SEACCTNO,CIACCTNO,
         TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
         EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
         QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
         EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,REFORDERID,CORRECTIONNUMBER,TLID,DFACCTNO,ISDISPOSAL,Cumqty,
         blorderid,isblorder,Hosesession)
    VALUES ( v_ORDERID , v_CUSTID , v_ACTYPE , v_CODEID , v_afaccount
          ,v_SEACCTNO ,v_afaccount
          , v_TXNUM ,TO_DATE (v_txdate, 'DD/MM/RRRR'), v_TXTIME
          ,TO_DATE (v_txdate, 'DD/MM/RRRR'),v_BRATIO ,v_TIMETYPE
          ,v_EXECTYPE ,v_NORK ,v_MATCHTYPE ,v_VIA ,v_CLEARDAY , v_CLEARCD ,'2','2',v_PRICETYPE
          ,v_amendmentprice ,0,v_LIMITPRICE ,v_ReplaceQTTY,v_ReplaceQTTY ,v_amendmentprice ,v_ReplaceQTTY,0
          ,0,0,0,0,0,'001', v_VOUCHER , v_CONSULTANT , pv_orderid , 1, v_tlid, v_DFACCTNO,v_ISDISPOSAL, pv_cumqty,
          v_blorderid,v_isblorder, v_HOSESSION);

    --Ghi nhan vao so lenh day di
    INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
        BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,
        TXDATE,TXTIME,TXNUM,DELTD,BRID,REFORDERID)
    VALUES ( v_ORDERID , v_CODEID , v_Symbol ,Replace(v_CUSTODYCD,'.',''),
        v_BORS ,v_MATCHTYPE ,v_NORK ,v_amendmentprice ,v_ReplaceQTTY ,v_BRATIO ,'S' ,
        TO_DATE (v_txdate, 'DD/MM/RRRR'),  v_TXTIME , v_TXNUM ,'N',v_BRID , pv_orderid );

    --Tao ban ghi trong ODQUEUE,ODQUEUELOG xac nhan lenh da day len san
    INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID =  v_ORDERID;
    INSERT INTO ODQUEUELOG SELECT * FROM OOD WHERE ORGORDERID = v_ORDERID;

    UPDATE Ordermap SET rejectcode = orgorderid,
                        orgorderid = v_OrderID,
                        order_number = PV_CONFIRM_NUMBER
    WHERE ctci_order = pv_ctci_order; --update ordermap cho lenh moi



 --Cap nhat cho GTC
   OPEN C_ODMAST(pv_orderid);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
        --LENH YEU CAU GTO SE BI HUY, DO LENH CON TREN SAN DA THAY DOI
        UPDATE FOMAST SET DELTD='Y' WHERE ORGACCTNO= pv_orderid;

        INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                    TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL, CONFIRMEDVIA,
                    BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT,
                    CLEARDAY, QUANTITY, PRICE, QUOTEPRICE,
                    TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,TXDATE,TXNUM,
                    EFFDATE,EXPDATE,BRATIO,VIA,OUTPRICEALLOW,TLID)
             SELECT v_ORDERID,v_ORDERID,v_ACTYPE,v_afaccount,'A',EXECTYPE,v_PRICETYPE,
                    v_TIMETYPE,v_MATCHTYPE,v_NORK,CLEARCD,v_CODEID,v_Symbol,'N'
                    ,'A','',TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),
                    v_CLEARDAY ,v_ReplaceQTTY, v_amendmentprice/ v_tradeunit ,v_amendmentprice / v_tradeunit ,
                     0 , 0 , 0 ,v_ReplaceQTTY ,TO_DATE(v_txdate, 'dd/mm/rrrr'),v_TXNUM,
                    EFFDATE,EXPDATE,v_BRATIO,v_VIA,OUTPRICEALLOW,TLID
             FROM FOMAST WHERE ORGACCTNO= pv_orderid;

    END IF;
    CLOSE C_ODMAST;
    plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
EXCEPTION WHEN others THEN
    pv_CheckProcess := FALSE;
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
    ROLLBACK;
END CONFIRM_REPLACE_NORMAL_ORDER;

FUNCTION FNC_CHECK_ROOM (
   pv_Symbol      IN VARCHAR2,
   pv_Volumn      IN NUMBER,
   pv_Custodycd   IN VARCHAR2,
   pv_BorS        IN VARCHAR2
) RETURN  NUMBER IS
    Cursor c_SecInfo(vc_Symbol varchar2) is
         Select CURRENT_ROOM
         From ho_Sec_info
         Where  CODE =TRIM(vc_Symbol);
    v_CurrentRoom Number;
    v_Result Number;
BEGIN
    If pv_BorS ='B' and substr(pv_Custodycd,4,1) ='F' then
         Open c_SecInfo(pv_Symbol);
         Fetch c_SecInfo into v_CurrentRoom;
         If c_SecInfo%notfound  Or v_CurrentRoom < pv_Volumn Then
            v_Result :=0;
         Else
            v_Result :=1;
         End if;
         Close c_SecInfo;
    Else
         v_Result :=1;
    End if;
    RETURN v_Result;
END FNC_CHECK_ROOM;

PROCEDURE prc_UpdateBoardSession (p_brdcode   VARCHAR2,
                                  p_boardId   VARCHAR2,
                                  p_grpCode   VARCHAR2,
                                  p_sessionId VARCHAR2)
IS
BEGIN
  IF p_sessionId = 'AB1' AND p_boardId IN ('T3','T6') AND p_brdcode = 'STO' THEN -- Bat Dau Bang TT sau gio
    UPDATE sysvar SET varvalue = 'Y' WHERE varname = 'OPEN_POST_SESSION' AND grname = 'SYSTEM' AND NVL(varvalue,'N') = 'N';
  ELSIF p_sessionId = 'AB2' AND p_boardId IN ('T3','T6') AND p_brdcode = 'STO' THEN
    UPDATE sysvar SET varvalue = 'N' WHERE varname = 'OPEN_POST_SESSION' AND grname = 'SYSTEM' AND NVL(varvalue,'Y') = 'Y';
  END IF;

  IF p_grpCode IN ('4','15') AND p_boardId <> 'AL' THEN
    UPDATE ho_brd ho SET ho.board_g1 = decode(p_boardId, 'G1', p_sessionId, ho.board_g1),
                         ho.board_g4 = decode(p_boardId, 'G4', p_sessionId, ho.board_g4),
                         ho.board_g7 = decode(p_boardId, 'G7', p_sessionId, ho.board_g7),
                         ho.board_t1 = decode(p_boardId, 'T1', p_sessionId, ho.board_t1),
                         ho.board_t3 = decode(p_boardId, 'T3', p_sessionId, ho.board_t3),
                         ho.board_t4 = decode(p_boardId, 'T4', p_sessionId, ho.board_t4),
                         ho.board_t6 = decode(p_boardId, 'T6', p_sessionId, ho.board_t6)
    WHERE brd_code = p_brdcode;
  ELSIF p_grpCode = '15' AND p_boardId = 'AL' AND p_sessionId NOT IN ('AW8','AW9') THEN
    UPDATE ho_brd ho SET ho.board_g1 = p_sessionId,
                         ho.board_g4 = p_sessionId,
                         ho.board_g7 = p_sessionId,
                         ho.board_t1 = p_sessionId,
                         ho.board_t3 = p_sessionId,
                         ho.board_t4 = p_sessionId,
                         ho.board_t6 = p_sessionId
    WHERE brd_code = p_brdcode;
  ELSIF p_grpCode = '8' THEN
    UPDATE ho_sec_info ho SET ho.tradsesstatus = p_sessionId
    WHERE ho.statuscode = 'CTR' AND ho.brd_code = p_brdcode;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, 'p_brdcode=' || p_brdcode || ',p_boardId=' || p_boardId || ',p_grpCode=' || p_grpCode || ',p_sessionId=' || p_sessionId);
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
END;

FUNCTION fnc_GetBoardId (p_brdCode    VARCHAR2,
                        p_quantity    NUMBER,
                        p_tradeLot    NUMBER,
                        p_matchType   VARCHAR2, -- N: Normal, P: Put through
                        p_isBuyIn     VARCHAR2,
                        p_isOpenPost  VARCHAR2,
                        p_priceType   varchar2)
RETURN VARCHAR2
IS
v_boardId    VARCHAR2(10);
BEGIN
  -- Get BoardId
  IF p_isBuyIn = 'Y' THEN
      v_boardId := 'G7';
  ELSIF p_priceType = 'PLO' THEN
      v_boardId := 'G3';
  ELSIF p_matchType = 'N' AND (p_quantity >= p_tradeLot OR p_brdCode <> 'STO') THEN
      v_boardId := 'G1';
  ELSIF p_matchType = 'N' AND p_quantity < p_tradeLot AND p_brdCode = 'STO' THEN
      v_boardId := 'G4';
  ELSIF p_matchType = 'P' AND p_quantity >= p_tradeLot AND p_brdCode IN ('STO','STX') THEN
    IF p_isOpenPost = 'Y' THEN
      v_boardId := 'T3';
    ELSE
      v_boardId := 'T1';
    END IF;
  ELSIF p_matchType = 'P' AND p_quantity < p_tradeLot AND p_brdCode IN ('STO','STX') THEN
    IF p_isOpenPost = 'Y' THEN
      v_boardId := 'T6';
    ELSE
      v_boardId := 'T4';
    END IF;
  ELSIF p_matchType = 'P' AND p_brdCode = 'BDO' THEN
      v_boardId := 'T1';
  ELSIF p_matchType = 'P' AND p_brdCode = 'RPO' THEN
      v_boardId := 'R1';
  END IF;
  RETURN v_boardId;
END;

FUNCTION fn_getSymbolByIsinCode(pv_isinCode VARCHAR2) RETURN VARCHAR2
IS
v_symbol   sbsecurities.symbol%TYPE;
BEGIN
   SELECT symbol INTO v_symbol FROM sbsecurities s WHERE s.isincode = TRIM(pv_isinCode);
   RETURN v_symbol;
EXCEPTION
    WHEN OTHERS THEN
        plog.error(pkgctx, 'IsinCode Not Found::' || pv_isinCode);
        RETURN pv_isinCode;
END;
FUNCTION fn_getHOSession (p_symbol VARCHAR2, p_boardId VARCHAR2) RETURN VARCHAR2
IS
l_hoSession   VARCHAR2(100);
l_statusCode  VARCHAR2(100);
l_brdCode     VARCHAR2(100);
BEGIN
  SELECT ho.statuscode, ho.tradsesstatus, ho.brd_code
  INTO l_statusCode, l_hoSession, l_brdCode
  FROM ho_sec_info ho
  WHERE ho.code = p_symbol;

  IF l_statusCode = ho_tx.C_SYMBOL_STATUS_CONTROL AND l_hoSession IS NOT NULL THEN -- CK Kiem Soat --> return Phien Kiem Soat Cua Ma
    RETURN l_hoSession;
  END IF;

  SELECT DECODE(p_boardId, 'G1', brd.board_g1,
                          'G4', brd.board_g4,
                          'G7', brd.board_g7,
                          'T1', brd.board_t1,
                          'T3', brd.board_t3,
                          'T4', brd.board_t4,
                          'T6', brd.board_t6,
                          brd.board_g1)
  INTO l_hoSession
  FROM ho_brd brd
  WHERE brd.brd_code = l_brdCode;

  RETURN l_hoSession;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, 'Error On p_symbol=' || p_symbol || ' ' || SQLERRM || dbms_utility.format_error_backtrace);
    RETURN '';
END;

--LAY MESSAGE DAY LEN GW.
/*PROCEDURE PRC_PUSHORDER(PV_MSGTYPE VARCHAR2, PV_TRADEPLACE VARCHAR2) IS
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PUSHORDER');
    IF PV_TRADEPLACE IN ('001') THEN
       pck_hogw.PRC_PUSHORDER(PV_MSGTYPE);
    ELSIF PV_TRADEPLACE IN ('002','005') THEN
       pck_hagw.PRC_PUSHORDER(PV_MSGTYPE);
    END IF;
    plog.setendsection (pkgctx, 'PRC_PUSHORDER');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PUSHORDER');
    RAISE errnums.E_SYSTEM_ERROR;
END PRC_PUSHORDER;*/

PROCEDURE PRC_PROCESS_ORDER(
    PV_MARKET            IN VARCHAR2,
    PV_CLORDID           IN VARCHAR2,
    PV_ORGCLORDID        IN VARCHAR2,
    PV_EXECTYPE          IN VARCHAR2,
    PV_ORDSTATUS         IN VARCHAR2,
    PV_SIDE              IN VARCHAR2,
    PV_OrderQty          IN VARCHAR2,
    PV_LASTQTY           IN NUMBER,
    PV_LASTPX            IN NUMBER,
    PV_LEAVESQTY         IN NUMBER,
    PV_CUMQTY            IN NUMBER,
    PV_CONFIRM_NUMBER    IN VARCHAR2,
    PV_EXECID            IN VARCHAR2,
    PV_QUOTEID           IN VARCHAR2,
    PV_ORDREJREASON      IN VARCHAR2,
    pv_OnBehalfOfCompID  IN VARCHAR2,
    pv_OnBehalfOfSubID   IN VARCHAR2,
    PV_ERR               OUT VARCHAR2
)
IS
    v_exp             EXCEPTION;
    v_CheckProcess    BOOLEAN := TRUE;
    v_orderid         odmast.orderid%TYPE;
    v_qtty            odmast.remainqtty%TYPE;
    v_cancelqtty      odmast.remainqtty%TYPE;
    l_hoSession       odmast.hosesession%TYPE;
    l_symbol          sbsecurities.symbol%TYPE;

BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS_ORDER');
    pv_err :='Process Exec 8: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;

    -- Lenh vao san
    IF PV_EXECTYPE = '0' And PV_ORDSTATUS = '0' THEN
       BEGIN
         UPDATE ORDERMAP SET ORDER_NUMBER = PV_CONFIRM_NUMBER WHERE ctci_order = TRIM(PV_CLORDID)
         RETURNING orgorderid INTO v_orderid;
         IF v_orderid IS NULL THEN
           RAISE v_exp;
         END IF;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Lenh vao san, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;

       UPDATE OOD SET OODSTATUS = 'S',
                      TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                      SENTTIME = SYSTIMESTAMP
       WHERE ORGORDERID = v_orderid and OODSTATUS <> 'S'
       RETURNING symbol INTO l_symbol;

       l_hoSession := pck_gw_common.fn_getHOSession(l_symbol, pv_OnBehalfOfSubID);
       UPDATE ODMAST SET ORSTATUS = '2',
                         PORSTATUS = PORSTATUS || ORSTATUS,
                         HOSESESSION = l_hoSession
       WHERE ORDERID = v_orderid AND ORSTATUS = '8';
    -- Khop lenh
    ELSIF PV_EXECTYPE = 'F' THEN
       BEGIN
          SELECT ORGORDERID INTO v_orderid FROM ORDERMAP WHERE ctci_order = PV_CLORDID;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Khop lenh, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;
       -- Khop thoa thuan
       IF PV_QUOTEID IS NOT NULL THEN
          UPDATE OOD SET OODSTATUS = 'S',
                         TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                         SENTTIME = SYSTIMESTAMP
          WHERE ORGORDERID = v_orderid AND OODSTATUS <> 'S';

          UPDATE ODMAST SET ORSTATUS = '2', PORSTATUS = PORSTATUS || ORSTATUS
          WHERE ORDERID = v_orderid AND ORSTATUS = '8';

          UPDATE orderptack SET STATUS ='A' WHERE confirmnumber = pv_Quoteid;

          MATCHING_NORMAL_ORDER(v_orderid, PV_SIDE, PV_LASTQTY, PV_LASTPX, PV_EXECID, v_CheckProcess);
          IF NOT v_CheckProcess THEN
             pv_err :='Process Exec 8 Khop lenh, MATCHING_NORMAL_ORDER exception: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
             RAISE v_Exp;
          END IF;
       -- Khop thuong
       ELSE
          UPDATE OOD SET OODSTATUS = 'S',
                         TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                         SENTTIME = SYSTIMESTAMP
          WHERE ORGORDERID = v_orderid AND OODSTATUS <> 'S';

          MATCHING_NORMAL_ORDER(v_orderid, PV_SIDE, PV_LASTQTY, PV_LASTPX, PV_EXECID, v_CheckProcess);
          IF NOT v_CheckProcess THEN
             pv_err :='Process Exec 8 Khop lenh, MATCHING_NORMAL_ORDER exception: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
             RAISE v_Exp;
          END IF;
       END IF;
    -- Huy lenh thuong thanh cong
    ELSIF PV_EXECTYPE = '4' And PV_ORDSTATUS = '4' THEN
       IF PV_ORGCLORDID IS NOT NULL Then
       BEGIN
          SELECT ORGORDERID INTO v_orderid FROM ORDERMAP WHERE ctci_order = PV_ORGCLORDID;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Huy lenh thuong, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;

       UPDATE OOD SET OODSTATUS = 'S',
                      TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                      SENTTIME = SYSTIMESTAMP
       WHERE REFORDERID = v_orderid AND OODSTATUS <> 'S';
      ELSE
       -- lay ra so hieu lenh giai toa
       BEGIN
          SELECT ORGORDERID INTO v_orderid FROM ORDERMAP WHERE ctci_order = PV_CLORDID;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Giai toa lenh, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;
       ---
      END IF;

       --Lay ra khoi luong huy
       v_cancelqtty := PV_OrderQty - PV_CUMQTY - PV_LEAVESQTY;

       CONFIRM_CANCEL_NORMAL_ORDER(v_orderid, v_cancelqtty, v_CheckProcess);
       IF NOT v_CheckProcess THEN
          pv_err :='Process Exec 8 Huy lenh, CONFIRM_CANCEL_NORMAL_ORDER exception: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END IF;
    -- Lenh sua thanh cong
    ELSIF PV_EXECTYPE = '5' And PV_ORDSTATUS = '5' THEN
       BEGIN
          SELECT ORGORDERID INTO v_orderid FROM ORDERMAP WHERE ctci_order = PV_ORGCLORDID;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Sua lenh, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;

       UPDATE OOD SET OODSTATUS = 'S',
                      TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS'),
                      SENTTIME = SYSTIMESTAMP
       WHERE REFORDERID = v_orderid AND OODSTATUS <> 'S';

       CONFIRM_REPLACE_NORMAL_ORDER(v_orderid, PV_LASTQTY, PV_LASTPX, PV_LEAVESQTY, PV_CUMQTY, PV_CLORDID,PV_CONFIRM_NUMBER, v_CheckProcess);
       IF NOT v_CheckProcess THEN
          pv_err :='Process Exec 8 Sua lenh, CONFIRM_REPLACE_NORMAL_ORDER exception: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END IF;
    -- Msg giai toa lenh
    ELSIF PV_EXECTYPE = 'C' And PV_ORDSTATUS = 'C' THEN
       BEGIN
          SELECT ORGORDERID INTO v_orderid FROM ORDERMAP WHERE ctci_order = PV_CLORDID;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Giai toa lenh, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;

       --Lay ra khoi luong huy
       v_cancelqtty := PV_OrderQty - PV_CUMQTY - PV_LEAVESQTY;

       CONFIRM_CANCEL_NORMAL_ORDER(v_orderid, v_cancelqtty, v_CheckProcess);
       IF NOT v_CheckProcess THEN
          pv_err :='Process Exec 8 Giai toa lenh, CONFIRM_CANCEL_NORMAL_ORDER exception: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END IF;
    -- Msg tu choi lenh
    ELSIF PV_EXECTYPE = '8' And PV_ORDSTATUS = '8' THEN
       BEGIN
          SELECT ORGORDERID INTO v_orderid FROM ORDERMAP WHERE ctci_order = PV_CLORDID;
       EXCEPTION WHEN OTHERS THEN
          pv_err :='Process Exec 8 Tu choi lenh, khong tim thay lenh goc: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END;

       -- Ghi log bi tu choi
       INSERT INTO ctci_reject(firm, order_number, reject_reason_code,
                   original_message_text, order_entry_date, msgtype)
       VALUES ('', PV_CLORDID, PV_ORDREJREASON, '', to_char(getcurrdate,'DD/MM/RRRR'), 'D');

       UPDATE OOD SET OODSTATUS = 'S',
                      TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS'),
                      SENTTIME  = SYSTIMESTAMP
       WHERE ORGORDERID = v_orderid AND OODSTATUS <> 'S';

       --Lay ra khoi luong huy
       v_cancelqtty := PV_OrderQty - PV_CUMQTY - PV_LEAVESQTY;
       CONFIRM_CANCEL_NORMAL_ORDER(v_orderid, v_cancelqtty, v_CheckProcess);
       IF NOT v_CheckProcess THEN
          pv_err :='Process Exec 8 Tu choi lenh, CONFIRM_CANCEL_NORMAL_ORDER exception: PV_CLORDID=' || PV_CLORDID || ', PV_ORGCLORDID=' || PV_ORGCLORDID;
          RAISE v_Exp;
       END IF;

       UPDATE ODMAST SET EXECQTTY    = 0,
                         MATCHAMT    = 0,
                         EXECAMT     = 0,
                         ORSTATUS    = '6',
                         porstatus   = porstatus || orstatus,
                         FEEDBACKMSG = PV_ORDREJREASON
       WHERE ORDERID = v_orderid;
    END IF;
    plog.setendsection (pkgctx, 'PRC_PROCESS_ORDER');
EXCEPTION
  WHEN v_Exp THEN
    plog.error(pkgctx, PV_ERR);
    plog.setendsection (pkgctx, 'PRC_PROCESS_ORDER');
    RAISE errnums.E_SYSTEM_ERROR;
  WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS_ORDER');
    RAISE errnums.E_SYSTEM_ERROR;
END;

--Xu ly Message 3
PROCEDURE PRC_PROCESS3(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TX3    ho_tx.msg_3;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESS3');
   v_TX3 := fn_xml2obj_3(pv_msgxml);

   CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => v_TX3.RefSeqNum,
                           pv_RefMsgType => v_TX3.RefMsgType,
                           pv_clOrdID => v_TX3.ClOrdID,
                           pv_rejectCode => v_TX3.SessionRejectReason,
                           pv_rejectText => v_TX3.Text,
                           pv_quoteMsgID => v_TX3.QuoteMsgID,
                           pv_IOIID => v_TX3.IOIID
   );
   plog.setendsection (pkgctx, 'PRC_PROCESS3');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESS3');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESS3;

PROCEDURE PRC_PROCESS9(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TX9       ho_tx.msg_9;
   v_msgtype   VARCHAR2(1);
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESS9');
   v_TX9 := fn_xml2obj_9(pv_msgxml);
   IF v_TX9.CxlRejResponseTo = '1' THEN
      v_msgtype := 'F';
   ELSE
      v_msgtype := 'G';
   END IF;

   CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => '',
                           pv_RefMsgType => v_msgtype,
                           pv_ClOrdID => v_TX9.ClOrdID,
                           pv_RejectCode => v_TX9.CxlRejReason,
                           pv_RejectText => ''
   );
   plog.setendsection (pkgctx, 'PRC_PROCESS9');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESS9');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESS9;

PROCEDURE PRC_PROCESSAI(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXAI            ho_tx.msg_AI;
   v_orgorderid      VARCHAR2(100);
   v_buyOrderId      VARCHAR2(100);
   v_sellOrderId      VARCHAR2(100);
   v_confirm_no      VARCHAR2(100);
   v_grporder        VARCHAR2(1);
   v_count           NUMBER;

   v_err_param       VARCHAR2(30);
   v_err_code        VARCHAR2(30);
   l_msgtype         VARCHAR2(10);
   l_count_quoteRespId NUMBER;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSAI');
   v_TXAI := fn_xml2obj_AI(pv_msgxml);
   -- Xac dinh AI forward cho ben nao (Initiator/Respondent)
   SELECT COUNT(1), NVL(MAX(msgtype), 'x') INTO v_count, l_msgtype FROM ordermap WHERE ctci_order = v_TXAI.QuoteMsgID;
   SELECT COUNT(1) INTO l_count_quoteRespId FROM ordermap WHERE ctci_order = v_TXAI.QuoteRespID;
   IF v_count > 0 AND l_msgtype = 'S' THEN -- AI Response For Quotes
     BEGIN
       SELECT od.orderid, grporder INTO v_orgorderid, v_grporder
       FROM ordermap mp, odmast od
       WHERE mp.ctci_order = v_TXAI.QuoteMsgID
       AND od.orderid = mp.orgorderid;
     EXCEPTION
       WHEN OTHERS THEN
         plog.error(pkgctx,'PRC_PROCESSAI'||'Khong tim so hieu lenh goc v_TXAI.QuoteMsgID: '|| v_TXAI.QuoteMsgID);
         plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
         plog.setendsection (pkgctx, 'PRC_PROCESSAI');
         RAISE errnums.E_SYSTEM_ERROR;
     END;
     -- Xac dinh AI forward cho msg nao(S/K02)
     IF v_TXAI.QuoteRespID IS NULL THEN
       IF v_TXAI.QuoteStatus = '1' THEN -- AI Accepted Response For Quotes
            UPDATE ood SET oodstatus = 'S',
                           txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                           senttime  = systimestamp
            WHERE orgorderid = v_orgorderid AND oodstatus <> 'S';

            UPDATE odmast SET orstatus = '2',
                              porstatus = porstatus || orstatus
            WHERE orderid = v_orgorderid and orstatus = '8';
       ELSE -- AI Rejected Response For Quotes
            CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => '',
                                    pv_RefMsgType => 'S',
                                    pv_ClOrdID => '',
                                    pv_RejectCode => v_TXAI.QuoteRejectReason,
                                    pv_RejectText => '',
                                    pv_QuoteMsgID => v_TXAI.QuoteMsgID);
       END IF;
     END IF;
   ELSIF v_count > 0 AND l_msgtype = 'K02' THEN -- AI Response For K02
     BEGIN
       SELECT od.orderid, grporder INTO v_orgorderid, v_grporder
       FROM ordermap mp, odmast od
       WHERE mp.ctci_order = v_TXAI.QuoteMsgID
       AND od.orderid = mp.orgorderid;
     EXCEPTION
       WHEN OTHERS THEN
         plog.error(pkgctx,'PRC_PROCESSAI'||'Khong tim so hieu lenh goc v_TXAI.QuoteMsgID: '|| v_TXAI.QuoteMsgID);
         plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
         plog.setendsection (pkgctx, 'PRC_PROCESSAI');
         RAISE errnums.E_SYSTEM_ERROR;
     END;
     IF v_TXAI.QuoteStatus = '17' THEN
         --INSERT INTO Haptcancelled(securitysymbol, confirmnumber,status, volume, price)
         --VALUES (i.Symbol, i.OrderID, 'H', i.LeavesQty, i.Price);
         SELECT reforderid INTO v_sellOrderId FROM odmast WHERE orderid = v_orgorderid;
         UPDATE ood SET oodstatus = 'S',
                        txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                        senttime  = systimestamp
         WHERE oodstatus <> 'S' AND deltd <> 'Y' AND reforderid = v_orgorderid;
         -- Update lenh ve trang thai delete
         UPDATE odmast SET deltd = 'Y',
                           cancelqtty = orderqtty,
                           remainqtty = 0,
                           execqtty = 0,
                           matchamt = 0,
                           execamt = 0,
                           feedbackmsg = 'Da huy'
         WHERE orderid = v_orgorderid; -- Update Lenh Huy
         UPDATE odmast SET deltd = 'Y',
                           cancelqtty = orderqtty,
                           remainqtty = 0,
                           execqtty = 0,
                           matchamt = 0,
                           execamt = 0,
                           feedbackmsg = 'Da huy'
         WHERE orderid = v_sellOrderId
         AND deltd <> 'Y' AND remainqtty > 0; -- Update Lenh Goc
         UPDATE ood SET  deltd = 'Y' WHERE orgorderid = v_orgorderid;

         IF v_grporder = 'Y' THEN
             cspks_seproc.pr_executeod9996(v_orgorderid, v_err_code, v_err_param);
         END IF;

         -- Tu choi lenh mua doi ung cung cung ty(neu co)
         BEGIN
           SELECT odb.orderid, odb.grporder INTO v_buyOrderId, v_grporder
           FROM odmast ods, odmast odb, cfmast cfs, ordersys sys
           WHERE ods.orderid = v_sellOrderId
           AND sys.sysname = 'FIRM'
           AND ods.custid = cfs.custid
           AND ods.codeid = odb.codeid
           AND ods.orderqtty = odb.orderqtty
           AND cfs.custodycd = odb.clientid
           AND ods.contrafirm = odb.contrafirm AND ods.contrafirm = sys.sysvalue
           AND ods.ptdeal = odb.ptdeal
           AND ods.matchtype = odb.matchtype AND ods.matchtype = 'P';

           -- Update lenh ve trang thai delete
           UPDATE odmast SET deltd = 'Y',
                             cancelqtty = orderqtty,
                             remainqtty = 0,
                             execqtty = 0,
                             matchamt = 0,
                             execamt = 0,
                             orstatus = '6',
                             porstatus = porstatus || orstatus,
                             feedbackmsg = 'Ben ban huy lenh'
           WHERE orderid = v_buyOrderId;
           UPDATE ood SET  deltd = 'Y' WHERE orgorderid = v_buyOrderId;
           UPDATE orderptack SET status = 'C' WHERE confirmnumber = v_TXAI.QuoteID;

           IF v_grporder = 'Y' THEN
              cspks_seproc.pr_executeod9996(v_orgorderid, v_err_code, v_err_param);
           END IF;
         EXCEPTION
           WHEN OTHERS THEN
               NULL;
         END;

     ELSE
         CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => '',
                                 pv_RefMsgType => 'K02',
                                 pv_ClOrdID => '',
                                 pv_RejectCode => v_TXAI.QuoteRejectReason,
                                 pv_RejectText => '',
                                 pv_QuoteMsgID => v_TXAI.QuoteMsgID
                                );
     END IF;
   ELSIF v_count = 0 AND v_TXAI.QuoteStatus = '17' AND v_TXAI.QuoteRespID IS NULL THEN -- Initor Cancel Quotes And Exchange Send AI To Respondent
     UPDATE orderptack SET status = 'C' WHERE confirmnumber = v_TXAI.QuoteID;
   ELSIF l_count_quoteRespId > 0 THEN -- AI Response For AJ
       BEGIN
          SELECT mp.orgorderid INTO v_orgorderid
          FROM ordermap mp
          WHERE mp.ctci_order = v_TXAI.QuoteRespID;
       EXCEPTION
         WHEN OTHERS THEN
           plog.error(pkgctx,'PRC_PROCESSAI'||'Khong tim so hieu lenh goc v_TXAI.QuoteRespID: '|| v_TXAI.QuoteRespID);
           plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
           plog.setendsection (pkgctx, 'PRC_PROCESSAI');
           RAISE errnums.E_SYSTEM_ERROR;
       END;
       -- Xac dinh AI forward cho msg nao(AJ-CFO/AJ-CFN)
       IF v_orgorderid IS NOT NULL THEN -- AI For AJ QuoteRespType = Hit/Lift
          IF v_TXAI.QuoteStatus = '1' THEN
             UPDATE ood SET oodstatus = 'S',
                            txtime    = to_char(SYSDATE, 'HH24:MI:SS'),
                            senttime  = systimestamp
             WHERE orgorderid = v_orgorderid AND oodstatus <> 'S';

             UPDATE odmast SET orstatus = '2',
                               porstatus = porstatus || orstatus
             WHERE orderid = v_orgorderid and orstatus = '8';
          ELSE
             CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => '',
                                     pv_RefMsgType => 'AJ',
                                     pv_ClOrdID => '',
                                     pv_RejectCode => v_TXAI.QuoteRejectReason,
                                     pv_RejectText => '',
                                     pv_QuoteMsgID => v_TXAI.QuoteRespID
             );
          END IF;
       ELSE -- AI For AJ QuoteRespType = Counter
          IF v_TXAI.QuoteStatus = '5' THEN -- Exchange Ok
             -- Cap nhat trang thai da huy thanh cong
             UPDATE orderptack SET status = 'C' WHERE confirmnumber = v_TXAI.QuoteID;
          ELSE -- Exchange Not Ok
             CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => '',
                                     pv_RefMsgType => 'AJ',
                                     pv_ClOrdID => '',
                                     pv_RejectCode => v_TXAI.QuoteRejectReason,
                                     pv_RejectText => '',
                                     pv_QuoteMsgID => v_TXAI.QuoteRespID
             );
          END IF;
       END IF;
   ELSE
     plog.error(pkgctx, 'Process AI Not Success ID = []');
     plog.setendsection (pkgctx, 'PRC_PROCESSAI');
     RAISE errnums.E_SYSTEM_ERROR;
   END IF;
   plog.setendsection (pkgctx, 'PRC_PROCESSAI');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSAI');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSAI;

PROCEDURE PRC_PROCESSAJ(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXAJ          ho_tx.msg_AJ;
   v_orgorderid    VARCHAR2(20);
   v_grporder      VARCHAR2(1);

   v_err_param varchar2(30);
   v_err_code varchar2(30);
BEGIN
   plog.setbeginsection (pkgctx, 'PRC_PROCESSAJ');
   v_TXAJ := fn_xml2obj_AJ(pv_msgxml);
   BEGIN
      SELECT od.orderid INTO v_orgorderid
      FROM ordermap mp, odmast od
      WHERE mp.order_number = v_TXAJ.QuoteID
        AND mp.orgorderid = od.orderid
        AND od.exectype IN ('NB', 'NS');
   EXCEPTION WHEN OTHERS THEN
      plog.error(pkgctx,'PRC_PROCESSAJ'||'Khong tim so hieu lenh goc v_TXAJ.QuoteID: '|| v_TXAJ.QuoteID);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'PRC_PROCESSAJ');
      RAISE errnums.E_SYSTEM_ERROR;
   END;
   -- Update lenh ve trang thai delete
   UPDATE odmast SET deltd = 'Y',
                     cancelqtty = orderqtty,
                     remainqtty = 0,
                     execqtty = 0,
                     matchamt = 0,
                     execamt = 0,
                     feedbackmsg = 'DT tu choi'
   WHERE orderid = v_orgorderid
   RETURNING grporder INTO v_grporder;
   UPDATE ood SET  deltd = 'Y' WHERE orgorderid = v_orgorderid;

   IF v_grporder = 'Y' THEN
      cspks_seproc.pr_executeod9996(v_orgorderid, v_err_code, v_err_param);
   END IF;
   plog.setendsection (pkgctx, 'PRC_PROCESSAJ');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSAJ');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSAJ;

PROCEDURE PRC_PROCESSj(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXj    ho_tx.msg_j;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSj');
   v_TXj := fn_xml2obj_j(pv_msgxml);
   CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => v_TXj.RefSeqNum,
                           pv_RefMsgType => v_TXj.RefMsgType,
                           pv_ClOrdID => v_TXj.ClOrdID,
                           pv_RejectCode => v_TXj.SessionRejectReason,
                           pv_RejectText => v_TXj.Text,
                           pv_QuoteMsgID => v_TXj.QuoteMsgID,
                           pv_IOIID => v_TXj.IOIID
   );
   plog.setendsection (pkgctx, 'PRC_PROCESSj');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSj');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSj;

PROCEDURE PRC_PROCESSK03(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXK03    ho_tx.msg_K03;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK03');
   v_TXK03 := fn_xml2obj_K03(pv_msgxml);
   plog.setendsection (pkgctx, 'PRC_PROCESSK03');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK03');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSK03;

procedure PRC_PROCESSK04(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXK04    ho_tx.msg_K04;
   --l_Security_Type     VARCHAR2(10);
   l_productGrpId      VARCHAR2(100);
   l_timstamp          VARCHAR2(10);
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK04');
   v_TXK04 := fn_xml2obj_K04(pv_msgxml);
   -- Do some things
   /*IF v_TXK04.ProductGrpID = 'STO' THEN -- Chung khoang
     l_Security_Type := '1';
   ELSIF v_TXK04.ProductGrpID = 'BDO' THEN -- Co Phieu
     l_Security_Type := '2';
   ELSIF v_TXK04.ProductGrpID = 'RPO' THEN -- Repo
     l_Security_Type := '3';
   ELSIF v_TXK04.ProductGrpID = 'W' THEN -- CW: chua co thong tin
     l_Security_Type := '4';
   END IF;*/
   IF v_TXK04.BoardEvtID IN ('AA2','AJ5','AF4','AF5','AJ4','AX1') THEN
     plog.error(pkgctx, 'Skip Process Session ' || v_TXK04.BoardEvtID);
     plog.setendsection (pkgctx, 'PRC_PROCESSK04');
     RETURN;
   END IF;

   IF v_TXK04.Symbol IS NULL OR length(trim(v_TXK04.Symbol)) = 0 THEN
     pck_gw_common.prc_UpdateBoardSession(v_TXK04.ProductGrpID, v_TXK04.OnBehalfOfSubID, v_TXK04.BoardEvtAppGrpCode, v_TXK04.BoardEvtID);

     IF v_TXK04.OnBehalfOfSubID = 'AL' THEN
       UPDATE ho_brd ho SET ho.tradsesstatus = decode(v_TXK04.BoardEvtID, 'AW8', 'AW8', 'NORM') WHERE ho.brd_code = v_TXK04.ProductGrpID;
     END IF;

     IF v_TXK04.ProductGrpID = 'STO' AND v_TXK04.OnBehalfOfSubID = 'G1' THEN -- Phien co phieu, cap nhat them controlcode
       UPDATE ORDERSYS SET SYSVALUE = v_TXK04.BoardEvtID  WHERE SYSNAME='CONTROLCODE';
     END IF;
     /*IF v_TXK04.BoardEvtAppGrpCode = '15' THEN
       UPDATE ho_sec_info SET tradsesstatus = v_TXK04.BoardEvtID WHERE brd_code = v_TXK04.ProductGrpID;
     END IF;*/

   ELSIF v_TXK04.BoardEvtAppGrpCode = '0' AND length(trim(v_TXK04.Symbol)) > 0 THEN
     UPDATE ho_sec_info SET tradsesstatus = v_TXK04.BoardEvtID WHERE code = v_TXK04.Symbol;

   END IF;

   l_timstamp := substr(v_TXK04.BoardEvtStartTime,1,6);
   IF l_timstamp IS NOT NULL AND length(TRIM(l_timstamp)) > 0 THEN
     UPDATE ORDERSYS SET SYSVALUE= LPAD(l_timstamp,6,'0') WHERE SYSNAME='TIMESTAMP';
     UPDATE ORDERSYS SET SYSVALUE= to_char(sysdate + 10/3600/24,'hh24miss') WHERE SYSNAME='TIMESTAMPO';
   END IF;

   plog.setendsection (pkgctx, 'PRC_PROCESSK04');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK04');
   RAISE errnums.E_SYSTEM_ERROR;
END ;
procedure PRC_PROCESSK05(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXK05             ho_tx.msg_K05;
   v_strErrCode        VARCHAR2(100);
   v_strErrM           VARCHAR2(2000);
   v_strTradePlace     VARCHAR2(100) := '000';
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK05');
   v_TXK05 := fn_xml2obj_K05(pv_msgxml);
   -- Do some things
   /*
    611 = Reference price is changed
    612 = Evaluation price is changed
    631 = Number of listed shares is changed
    641 = Order quantify unit is changed
   */
   IF v_TXK05.OnBehalfOfCompID IN ('STO','BDO','RPO') THEN
     v_strTradePlace := '001';
   ELSIF v_TXK05.OnBehalfOfCompID IN ('STX','BDX','HCX') THEN
     v_strTradePlace := '002';
   ELSIF v_TXK05.OnBehalfOfCompID IN ('UPX') THEN
     v_strTradePlace := '005';
   END IF;
   IF v_TXK05.PreHourSymChxType = '611' THEN
     Pr_updatepricefromgw (v_TXK05.Symbol,
                          nvl(v_TXK05.ReferencePrice, 0),
                          nvl(v_TXK05.LowLimitPrice, 0),
                          nvl(v_TXK05.HighLimitPrice, 0),
                          'DN',
                          v_strErrCode,
                          v_strErrM);
     Cspks_odproc.Pr_Update_SecInfo (v_TXK05.Symbol,
                                    nvl(v_TXK05.HighLimitPrice, 0),
                                    nvl(v_TXK05.LowLimitPrice, 0),
                                    nvl(v_TXK05.ReferencePrice, 0),
                                    v_strTradePlace,
                                    'N',
                                    v_strErrCode,'','',
                                    '',
                                    v_TXK05.Symbol);


   ELSIF v_TXK05.PreHourSymChxType = '612' THEN
     NULL;
   ELSIF v_TXK05.PreHourSymChxType = '631' AND nvl(v_TXK05.ListedShares, 0) > 0 THEN
     UPDATE ho_sec_info ho SET ho.total_listing_qtty = NVL(v_TXK05.ListedShares, ho.total_listing_qtty)
     WHERE TRIM(ho.code) = TRIM(v_TXK05.Symbol);
   ELSIF v_TXK05.PreHourSymChxType = '641' AND NVL(v_TXK05.UnitOfMeasureQty, 0) > 0 THEN
     UPDATE securities_info SET tradelot = v_TXK05.UnitOfMeasureQty WHERE symbol = TRIM(v_TXK05.Symbol);
   END IF;

   plog.setendsection (pkgctx, 'PRC_PROCESSK05');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK05');
   RAISE errnums.E_SYSTEM_ERROR;
END ;

PROCEDURE PRC_PROCESSK06(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXK06        ho_tx.msg_K06;
   v_count        NUMBER;
   v_trscope      NUMBER;
   v_CheckProcess BOOLEAN;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK06');
   v_TXK06 := fn_xml2obj_K06(pv_msgxml);

   SELECT COUNT(1) INTO v_count
   FROM sysvar
   WHERE grname = 'SYSTEM' AND varname = 'COMPANYCD' AND varvalue = v_TXk06.MemberNo;

  IF v_count <> 0 THEN
    IF v_TXk06.Symbol IS NOT NULL THEN
       IF v_TXk06.PreHourChxActionType = '711' THEN -- Ngung giao dich
              -- Cap nhat trang thai
              UPDATE SBSECURITIES SET trscope = to_number(v_TXk06.MemberTRScope)
              WHERE symbol = v_TXk06.Symbol;
              -- Giai toa lenh
          FOR rec IN (
                SELECT od.orderid, sb.tradeplace,od.remainqtty
                FROM ODMAST od, securities_info seif, sbsecurities sb, ood ood
                WHERE od.CODEID = seif.CODEID
                  AND seif.codeid = sb.codeid
                  AND od.orderid = ood.orgorderid
                  AND ood.oodstatus = 'N'--Chua gui So
                  AND od.remainqtty > 0
                      AND od.ORSTATUS NOT IN ('6','5','7')--lenh da het hieu luc
                  AND sb.symbol = v_TXk06.Symbol
                      AND EXISTS (
                      SELECT 1 FROM hotrscopemap WHERE trscope = sb.trscope
                         AND side = substr(od.exectype,2,1)
                         AND accounttype = decode(substr(ood.custodycd,4,1), 'P', '3', '1')
                      )
          ) LOOP
             BEGIN
                confirm_cancel_normal_order(rec.orderid, rec.remainqtty, v_CheckProcess);
                --Cap nhat trang thai bi tu choi
                UPDATE odmast SET REMAINQTTY  = 0,
                                  ORSTATUS    = '6',
                                  PORSTATUS   = PORSTATUS || ORSTATUS,
                                  FEEDBACKMSG = FEEDBACKMSG || 'CK dung giao dich'
                WHERE orderid = rec.orderid;

                UPDATE ood SET OODSTATUS = 'E',
                               TXTIME    = TO_CHAR(SYSDATE, 'HH24:MI:SS')
                WHERE ORGORDERID =  rec.orderid AND OODSTATUS = 'N';
             EXCEPTION WHEN OTHERS THEN
                   plog.error(pkgctx,'Error when cancel order : ' || rec.ORDERID || ',' || SQLERRM || ' - Dong:' || dbms_utility.format_error_backtrace);
             END;
          END LOOP;
       ELSE -- Khoi phuc giao dich
              SELECT SUM(cur.trvalue) INTO v_trscope
              FROM sbsecurities sb, hotrscopemap cur, hotrscopemap upd
              WHERE sb.symbol = v_TXk06.Symbol
                AND cur.trscope = sb.trscope
                AND upd.trscope = v_TXk06.MemberTRScope
                AND cur.accounttype = upd.accounttype
                AND cur.side = upd.side;
              -- Cap nhat trang thai
              UPDATE SBSECURITIES SET trscope = trscope - nvl(v_trscope, 0) WHERE symbol = v_TXk06.Symbol;
       END IF;
     END IF;
   END IF;
   plog.setendsection (pkgctx, 'PRC_PROCESSK06');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK06');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSK06;

--Reference Price Determination
procedure PRC_PROCESSK07(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
     v_TXk07      ho_tx.msg_k07;
     v_strErrCode VARCHAR2(20);
     v_strErrM    VARCHAR2(200);
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK07');
   v_TXk07 := fn_xml2obj_k07(pv_msgxml);

   UPDATE ho_sec_info SET Time  =  to_char(sysdate,'hh24miss'),
                          ceiling_price = v_TXk07.HighLimitPrice ,
                          floor_price = v_TXk07.LowLimitPrice ,
                          basic_price = v_TXk07.ReferencePrice
   WHERE code = v_TXk07.Symbol;

   begin
      pr_updatepricefromgw(v_TXk07.Symbol,
                           v_TXk07.ReferencePrice,
                           v_TXk07.LowLimitPrice,
                           v_TXk07.HighLimitPrice,
                           'DN', -- Dau ngay
                           v_strErrCode,
                           v_strErrM);
   exception when others then
      null;
   end;
   COMMIT;
   plog.setendsection (pkgctx, 'PRC_PROCESSK07');
exception when others then
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK07');
   raise errnums.E_SYSTEM_ERROR;
end PRC_PROCESSK07;

--Symbol Closing Info
procedure PRC_PROCESSK08(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
     v_TXk08      ho_tx.msg_k08;
     v_ceiling_price number;
     v_floor_price   number;
     v_codeid   sbsecurities.codeid%TYPE;
     v_symbol   sbsecurities.symbol%TYPE;
     v_strErrCode  Varchar2(20);
     v_strErrM Varchar2(200);
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK08');
   v_TXk08 := fn_xml2obj_k08(pv_msgxml);
   v_symbol := fn_getSymbolByIsinCode(v_TXk08.Symbol);
   IF v_TXk08.OnBehalfOfSubID = 'G1' THEN
   BEGIN
     SELECT codeid INTO v_codeid FROM sbsecurities s WHERE s.isincode = v_TXk08.Symbol;
   EXCEPTION
     WHEN OTHERS THEN
       plog.error(pkgctx, 'Codeid Not Found::' || v_TXk08.Symbol);
   END;

   v_floor_price := fn_get_price_nextdate(v_codeid, nvl(v_TXk08.SymbolCloseInfoPx,0), 'F');
     v_ceiling_price := fn_get_price_nextdate(v_codeid, nvl(v_TXk08.SymbolCloseInfoPx,0), 'C');

   UPDATE ho_sec_info
   SET Time  =  to_char(sysdate,'hh24miss'),
       close_price = v_TXk08.SymbolCloseInfoPx
   WHERE code = v_symbol;

   pr_updatepricefromgw(v_symbol ,nvl(v_TXk08.SymbolCloseInfoPx,0) , nvl(v_floor_price,0) , nvl(v_ceiling_price,0) , 'CN' , v_strErrCode ,v_strErrM );
   END IF;
  /* UPDATE securities_info
   SET closeprice = v_TXk08.SymbolCloseInfoPx,
       newbasicprice = p_basic_price,
       newceilingprice = v_ceiling_price,
       newfloorprice   =  v_floor_price
   WHERE symbol = fn_getSymbolByIsinCode(v_TXk08.Symbol);*/

   plog.setendsection (pkgctx, 'PRC_PROCESSK08');
exception when others then
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK08');
   raise errnums.E_SYSTEM_ERROR;
end PRC_PROCESSK08;


--Volatility Interruption
procedure PRC_PROCESSK09(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
     v_TXk09      ho_tx.msg_k09;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK09');
   v_TXk09 := fn_xml2obj_k09(pv_msgxml);

   plog.setendsection (pkgctx, 'PRC_PROCESSK09');
exception when others then
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK09');
   raise errnums.E_SYSTEM_ERROR;
end PRC_PROCESSK09;

Procedure PRC_PROCESSK11(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
    V_TXK11   ho_tx.msg_K11;
    l_autoid  VARCHAR2(10);
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESSK11');

    V_TXK11:=fn_xml2obj_K11(pv_msgxml);

    --lay Request gui som hon
    SELECT autoid INTO l_autoid FROM (SELECT * FROM ho_k10 WHERE acceptconfirmYN IS NULL
    AND clordid = V_TXK11.clordid ORDER BY autoid) WHERE rownum = 1;

    UPDATE ho_k10 SET transacttime = V_TXK11.TransactTime, account = V_TXK11.Account,
    side = V_TXK11.Side, acceptconfirmYN = V_TXK11.AcceptConfirmYN
    WHERE autoid = l_autoid;

    plog.setendsection (pkgctx, 'PRC_PROCESSK11');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESSK11');
    ROLLBACK;
END PRC_PROCESSK11;

procedure PRC_PROCESSK15(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXK15    ho_tx.msg_K15;
   v_count    NUMBER;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK15');
   v_TXK15 := fn_xml2obj_K15(pv_msgxml);

   SELECT COUNT(1) INTO v_count FROM orderptadv WHERE ioiid = v_TXK15.IOIID;

   IF v_count > 0 THEN
      IF v_TXK15.OrdRejReason IS NULL THEN
         IF v_TXK15.IOITransType = 'N' THEN
            INSERT INTO hoput_ad(advside, text, quantity, symbol, price, advid, status, boardId, isincode)
            VALUES(decode(v_TXK15.Side, '1', 'B', 'S'), v_TXK15.ContactNo, v_TXK15.IOIQty, fn_getSymbolByIsinCode(v_TXK15.symbol), v_TXK15.price, v_TXK15.IOIID, '1', v_TXK15.OnBehalfOfSubID, v_TXK15.symbol);
         ELSIF v_TXK15.IOITransType = 'C' THEN
            UPDATE orderptadv SET status = 'C' WHERE ioiid = v_TXK15.IOIRefID;
         ELSE
            plog.error(pkgctx,'PRC_PROCESSK15 IOITransType invalid v_TXK15.IOITransType: '|| v_TXK15.IOITransType);
            plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
            plog.setendsection (pkgctx, 'PRC_PROCESSK15');
            RAISE errnums.E_SYSTEM_ERROR;
         END IF;

         UPDATE orderptadv SET status = 'S', sendtime = to_char(SYSDATE, 'HH24MISS') WHERE ioiid = v_TXK15.IOIID;
      ELSE
         CONFIRM_REJECT_MESSSAGE(pv_RefSeqNum => '',
                                 pv_RefMsgType => '6',
                                 pv_ClOrdID => '',
                                 pv_RejectCode => v_TXK15.OrdRejReason,
                                 pv_RejectText => '',
                                 pv_QuoteMsgID => '',
                                 pv_IOIID => v_TXK15.IOIID
         );
      END IF;
   ELSE
      IF v_TXK15.IOITransType = 'N' THEN
         INSERT INTO hoput_ad(advside, text, quantity, symbol, price, advid, status, boardid)
         VALUES(decode(v_TXK15.Side, '1', 'B', 'S'), v_TXK15.ContactNo, v_TXK15.IOIQty, v_TXK15.symbol, v_TXK15.price, v_TXK15.IOIID, '1', v_TXK15.OnBehalfOfSubID);
      ELSIF v_TXK15.IOITransType = 'C' THEN
         UPDATE hoput_ad SET status = '0' WHERE advid = v_TXK15.IOIRefID;
      ELSE
         plog.error(pkgctx,'PRC_PROCESSK15 IOITransType invalid v_TXK15.IOITransType: '|| v_TXK15.IOITransType);
         plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
         plog.setendsection (pkgctx, 'PRC_PROCESSK15');
         RAISE errnums.E_SYSTEM_ERROR;
      END IF;
   END IF;
   plog.setendsection (pkgctx, 'PRC_PROCESSK15');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK15');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSK15;

PROCEDURE PRC_PROCESSK16(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXK16    ho_tx.msg_K16;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK16');
   v_TXK16 := fn_xml2obj_K16(pv_msgxml);
   UPDATE hoput_ad SET status = v_TXK16.IOIStatusCode WHERE advid = v_TXK16.IOIID;
   plog.setendsection (pkgctx, 'PRC_PROCESSK16');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK16');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSK16;

procedure PRC_PROCESSK17(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
     v_TXK17    ho_tx.msg_K17;
     v_codeid  securities_info.codeid%TYPE;
begin
   plog.setbeginsection (pkgctx, 'PRC_PROCESSK17');
   v_TXK17 := fn_xml2obj_K17(pv_msgxml);

   select codeid into v_codeid from securities_info where symbol = v_TXK17.Symbol;

   update securities_info set current_room = nvl(current_room, 0) + to_number(v_TXK17.FornLimitIncDecQty)
   where codeid = v_codeid
      or codeid in (select codeid from sbsecurities where refcodeid = v_codeid);

   plog.setendsection (pkgctx, 'PRC_PROCESSK17');
exception when others then
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSK17');
   raise errnums.E_SYSTEM_ERROR;
end PRC_PROCESSK17;

PROCEDURE PRC_PROCESSS(PV_MSGXML VARCHAR2, PV_MARKET VARCHAR2) IS
   v_TXS                ho_tx.msg_S;
   v_orderid            VARCHAR2(20);
   v_side               orderptack.side%TYPE;
   v_price              orderptack.price%TYPE;
   v_volume             orderptack.volume%TYPE;
   v_sellercontrafirm   orderptack.sellercontrafirm%TYPE;
   v_sellertradeid      orderptack.sellertradeid%TYPE;
   v_buyercontrafirm    orderptack.firm%TYPE;
   v_buyertradeid         orderptack.buyertradeid%TYPE;
   v_firm               orderptack.firm%TYPE;
   v_status             orderptack.status%TYPE;
   v_sfirm              orderptack.firm%TYPE;
   v_stradeid           Orderptack.Buyertradeid%TYPE;
   v_bacctno            VARCHAR2(100);
   v_bfirm              orderptack.firm%TYPE;
   v_btradeid           Orderptack.Buyertradeid%TYPE;
   v_sacctno            VARCHAR2(100);
   v_symbol             SBSECURITIES.Symbol%TYPE;
BEGIN
   plog.setbeginsection (pkgctx, 'PRC_PROCESSS');
   v_TXS := fn_xml2obj_S(pv_msgxml);
   v_symbol:=fn_getSymbolByIsinCode(v_TXS.Symbol);
   -- Nhan thong bao lenh thoa thuan
   BEGIN
      SELECT sysvalue INTO v_firm from ordersys where sysname ='FIRM';
   EXCEPTION WHEN OTHERS THEN
      plog.error(pkgctx,'PRC_PROCESSS Chua khai bao ma cty trong ordersys');
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'PRC_PROCESSS');
      RAISE errnums.E_SYSTEM_ERROR;
   END;

   IF v_TXS.Side = '1' THEN
      v_side := 'B';
      v_price := v_TXS.BidPx;
      v_volume := v_TXS.BidSize;
      v_sfirm := v_firm;
      v_stradeid := v_firm || '1';
      v_bacctno := v_TXS.Account;
      IF v_TXS.s1PartyRole = 1 THEN
         v_bfirm := v_TXS.s1PartyID;
         v_btradeid := v_TXS.s2PartyID;
      ELSE
         v_bfirm := v_TXS.s2PartyID;
         v_btradeid := v_TXS.s1PartyID;
      END IF;
   ELSIF v_TXS.Side = '2' THEN
      v_side := 'S';
      v_price := v_TXS.OfferPx;
      v_volume := v_TXS.OfferSize;
      IF v_TXS.s1PartyRole = 1 THEN
         v_sfirm := v_TXS.s1PartyID;
         v_stradeid := v_TXS.s2PartyID;
      ELSE
         v_sfirm := v_TXS.s2PartyID;
         v_stradeid := v_TXS.s1PartyID;
      END IF;
      v_bfirm := v_firm;
      v_btradeid := v_firm || '1';
      v_sacctno := v_TXS.Account;
   ELSE
      plog.error(pkgctx,'PRC_PROCESSS Side invalid v_TXS.Side: '|| v_TXS.Side);
      plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'PRC_PROCESSS');
      RAISE errnums.E_SYSTEM_ERROR;
   END IF;


   -- Neu la lenh 1 firm thi cap nhat luon trang thai active, de boc lenh mua
   IF v_sfirm = v_bfirm THEN
      BEGIN
         SELECT odb.orderid INTO v_orderid
         FROM odmast ods, odmast odb, cfmast cfs, ordersys sys, ordermap mp
         WHERE mp.order_number = v_TXS.QuoteID
           AND ods.orderid = mp.orgorderid
           AND sys.sysname = 'FIRM'
           AND ods.custid = cfs.custid
           AND ods.codeid = odb.codeid
           AND ods.orderqtty = odb.orderqtty
           AND cfs.custodycd = odb.clientid
           AND ods.contrafirm = odb.contrafirm AND ods.contrafirm = sys.sysvalue
           AND ods.ptdeal = odb.ptdeal
           AND ods.matchtype = odb.matchtype AND ods.matchtype = 'P'
           AND ods.exectype IN ('NB', 'NS');
      EXCEPTION WHEN OTHERS THEN
         plog.error(pkgctx,'PRC_PROCESSS Khong tim thay lenh 1 firm doi ung v_TXS.QuoteID: ' || v_TXS.QuoteID);
         plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
         plog.setendsection (pkgctx, 'PRC_PROCESSS');
         RAISE errnums.E_SYSTEM_ERROR;
      END;
      UPDATE odmast SET confirm_no = v_TXS.QuoteID WHERE orderid = v_orderid;
      --UPDATE ood SET oodstatus = 'S', txtime = to_char(SYSDATE,'hh24:mi:ss') WHERE orgorderid = v_orderid;
      v_status := 'A';
   ELSE
      v_status := 'N';
   END IF;

   INSERT INTO orderptack (messagetype, confirmnumber, side, price, volume, quotemsgid,
                           sellercontrafirm, sellertradeid, firm, buyertradeid, securitysymbol,
                           advidref, trading_date, txtime, status, boardId)
   VALUES('S', v_TXS.QuoteID, v_side, v_price, v_volume, v_TXS.QuoteMsgID,
          v_sfirm, v_stradeid, v_bfirm, v_btradeid, v_symbol,
          v_TXS.IOIID, trunc(SYSDATE), to_char(SYSDATE, 'hh24:mi:ss'), v_status, v_TXS.OnBehalfOfSubID);

   plog.setendsection (pkgctx, 'PRC_PROCESSS');
EXCEPTION WHEN OTHERS THEN
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'PRC_PROCESSS');
   RAISE errnums.E_SYSTEM_ERROR;
END PRC_PROCESSS;

--phuongntn add xml msg reject
FUNCTION fn_xml2obj_3(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_3 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_3;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_3');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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
    If v_Key ='RefSeqNum'  Then
       l_txmsg.RefSeqNum := trim(v_Value);
    Elsif v_Key ='RefMsgType' Then
       l_txmsg.RefMsgType := trim(v_Value);
    Elsif v_Key ='SessionRejectReason' Then
       l_txmsg.SessionRejectReason := trim(v_Value);
    Elsif v_Key ='Text' Then
       l_txmsg.Text  := trim(v_Value);
    ElsIf v_Key ='ClOrdID'  Then
       l_txmsg.ClOrdID := v_Value;
    ELSIF v_Key ='QuoteMsgID'  Then
       l_txmsg.QuoteMsgID := v_Value;
    ELSIF v_Key ='IOIID'  Then
       l_txmsg.IOIID := v_Value;
    End if;
  END LOOP;
  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_3');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_3');
  RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_3;

FUNCTION fn_xml2obj_8(pv_xmlmsg    VARCHAR2) RETURN ho_tx.msg_8 IS
l_parser   xmlparser.parser;
l_doc      xmldom.domdocument;
l_nodeList xmldom.domnodelist;
l_node     xmldom.domnode;

l_txmsg   ho_tx.msg_8;
v_Key Varchar2(100);
v_Value Varchar2(100);


BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_8');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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
    Elsif v_Key ='OrdRejReason' Then
      l_txmsg.OrdRejReason := v_Value;
    Elsif v_Key ='MsgSeqNum' Then
      l_txmsg.MsgSeqNum := v_Value;
    ElsIf v_Key ='QuoteID'  Then
      l_txmsg.QuoteID := v_Value;
    ElsIf v_Key ='CumQty'  Then
      l_txmsg.CumQty := v_Value;
    ELSIF v_key = 'OnBehalfOfCompID' THEN
      l_txmsg.OnBehalfOfCompID := v_Value;
    ELSIF v_key = 'OnBehalfOfSubID' THEN
      l_txmsg.OnBehalfOfSubID := v_Value;
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
  -- dbms_lob.freetemporary(pv_xmlmsg);

  plog.setendsection(pkgctx, 'fn_xml2obj_8');
  RETURN l_txmsg;
EXCEPTION
  WHEN OTHERS THEN
    --dbms_lob.freetemporary(pv_xmlmsg);
    DBMS_XMLPARSER.freeparser(l_parser);
    DBMS_XMLDOM.freedocument(l_doc);
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'fn_xml2obj_8');
    RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_8;

FUNCTION fn_xml2obj_9(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_9 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_9;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_9');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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
    Elsif v_Key ='OrderID' Then
       l_txmsg.OrderID := v_Value;
    Elsif v_Key ='OrigClOrdID' Then
       l_txmsg.OrigClOrdID := v_Value;
    Elsif v_Key ='CxlRejResponseTo' Then
       l_txmsg.CxlRejResponseTo := v_Value;
    Elsif v_Key ='CxlRejReason' Then
       l_txmsg.CxlRejReason := v_Value;
    End if;
  END LOOP;
  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_9');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_9');
  RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_9;

FUNCTION fn_xml2obj_j(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_j IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_j;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);

BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_j');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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
    If v_Key ='RefSeqNum'  Then
       l_txmsg.RefSeqNum := trim(v_Value);
    Elsif v_Key ='RefMsgType' Then
       l_txmsg.RefMsgType := trim(v_Value);

    Elsif v_Key ='SessionRejectReason' Then
       l_txmsg.SessionRejectReason := trim(v_Value);

    Elsif v_Key ='Text' Then
       l_txmsg.Text  := trim(v_Value);

    ElsIf v_Key ='ClOrdID'  Then
       l_txmsg.ClOrdID := v_Value;

    ELSIF v_Key ='QuoteMsgID'  Then
       l_txmsg.QuoteMsgID := v_Value;

    ELSIF v_Key ='IOIID'  Then
       l_txmsg.IOIID := v_Value;
    End IF;

  END LOOP;

  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_j');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_j');
  RAISE errnums.E_SYSTEM_ERROR;

END fn_xml2obj_j;

FUNCTION fn_xml2obj_AI(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_AI IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_AI;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);

BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_AI');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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
    If v_Key ='QuoteID'  Then
       l_txmsg.QuoteID := v_Value;
    Elsif v_Key ='QuoteMsgID' Then
       l_txmsg.QuoteMsgID := v_Value;

    Elsif v_Key ='QuoteRespID' Then
       l_txmsg.QuoteRespID := v_Value;

    Elsif v_Key ='QuoteRespType' Then
       l_txmsg.QuoteRespType := v_Value;

    Elsif v_Key ='Symbol' Then
       l_txmsg.Symbol := v_Value;

    Elsif v_Key ='Side' Then
       l_txmsg.Side := v_Value;

    Elsif v_Key ='OrderQty' Then
       l_txmsg.OrderQty := v_Value;

    Elsif v_Key ='Account' Then
       l_txmsg.Account := v_Value;

    Elsif v_Key ='BidPx' Then
       l_txmsg.BidPx := v_Value;

    Elsif v_Key ='OfferPx' Then
       l_txmsg.OfferPx := v_Value;

    Elsif v_Key ='BidSize' Then
       l_txmsg.BidSize := v_Value;

    Elsif v_Key ='OfferSize' Then
       l_txmsg.OfferSize := v_Value;

    Elsif v_Key ='QuoteStatus' Then
       l_txmsg.QuoteStatus := v_Value;

    Elsif v_Key ='QuoteRejectReason' Then
       l_txmsg.QuoteRejectReason := v_Value;

    End if;

  END LOOP;

  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_AI');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_AI');
  RAISE errnums.E_SYSTEM_ERROR;

END fn_xml2obj_AI;

FUNCTION fn_xml2obj_AJ(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_AJ IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_fldname fldmaster.fldname%TYPE;
  l_txmsg   ho_tx.msg_AJ;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_AJ');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='QuoteRespID'  Then
      l_txmsg.QuoteRespID := v_Value;
    Elsif v_Key ='QuoteID' Then
      l_txmsg.QuoteID := v_Value;
    Elsif v_Key ='QuoteMsgID' Then
      l_txmsg.QuoteMsgID := v_Value;
    End if;

  END LOOP;
  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_AJ');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_AJ');
  RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_AJ;

FUNCTION fn_xml2obj_K03(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K03 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_K03;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K03');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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
    /*
    If v_Key ='IOIStatusCode'  Then
      l_txmsg.IOIStatusCode := v_Value;
    Elsif v_Key ='IOIID' Then
      l_txmsg.IOIID := v_Value;
    End if;
    */
  END LOOP;
  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_K03');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K03');
  RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_K03;

FUNCTION fn_xml2obj_K04(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_k04 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_k04;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K04');
  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='ProductGrpID'  Then
       l_txmsg.ProductGrpID := v_Value;
    Elsif v_Key ='BoardEvtID' Then
       l_txmsg.BoardEvtID := v_Value;
    Elsif v_Key ='BoardEvtStartTime' Then
       l_txmsg.BoardEvtStartTime := v_Value;
    Elsif v_Key ='BoardEvtAppGrpCode' Then
       l_txmsg.BoardEvtAppGrpCode := v_Value;
    Elsif v_Key ='SessOpenCloseCode' Then
       l_txmsg.SessOpenCloseCode := v_Value;
    Elsif v_Key ='TradingSessionID' Then
       l_txmsg.TradingSessionID := v_Value;
    Elsif v_Key ='Symbol' Then
       l_txmsg.Symbol := v_Value;
    Elsif v_Key ='ProductID' Then
       l_txmsg.ProductID := v_Value;
    Elsif v_Key ='TradingHaltReason' Then
       l_txmsg.TradingHaltReason := v_Value;
    Elsif v_Key ='TradingHaltOccType' Then
       l_txmsg.TradingHaltOccType := v_Value;
    Elsif v_Key ='OnBehalfOfSubID' Then
       l_txmsg.OnBehalfOfSubID := v_Value;
    End if;
  END LOOP;
  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_K04');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K04');
  RAISE errnums.E_SYSTEM_ERROR;
END ;

FUNCTION fn_xml2obj_K05(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_k05 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;


  l_txmsg   ho_tx.msg_k05;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K05');
  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='PreHourSymChxType'  Then
       l_txmsg.PreHourSymChxType := v_Value;
    Elsif v_Key ='Symbol' Then
       l_txmsg.Symbol := v_Value;
    Elsif v_Key ='OpenTime' Then
       l_txmsg.OpenTime := v_Value;
    Elsif v_Key ='ReferencePrice' Then
       l_txmsg.ReferencePrice := v_Value;
    Elsif v_Key ='HighLimitPrice' Then
       l_txmsg.HighLimitPrice := v_Value;
    Elsif v_Key ='LowLimitPrice' Then
       l_txmsg.LowLimitPrice := v_Value;
    Elsif v_Key ='EvaluationPrice' Then
       l_txmsg.EvaluationPrice := v_Value;
    Elsif v_Key ='HgstOrderPrice' Then
       l_txmsg.HgstOrderPrice := v_Value;
    Elsif v_Key ='LwstOrderPrice' Then
       l_txmsg.LwstOrderPrice := v_Value;
    Elsif v_Key ='OpnprcBasPrcYn' Then
       l_txmsg.OpnprcBasPrcYn := v_Value;
    Elsif v_Key ='ExClassType' Then
       l_txmsg.ExClassType := v_Value;
    Elsif v_Key ='UnitOfMeasureQty' Then
       l_txmsg.UnitOfMeasureQty := v_Value;
    Elsif v_Key ='ListedShares' Then
       l_txmsg.ListedShares := v_Value;
    ELSIF v_Key = 'OnBehalfOfCompID' THEN
       l_txmsg.OnBehalfOfCompID := v_Value;
    End if;
  END LOOP;
  -- Free any resources associat-ed with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_K05');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K05');
  RAISE errnums.E_SYSTEM_ERROR;
END ;

FUNCTION fn_xml2obj_K06(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K06 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_K06;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);

BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K06');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='PreHourChxActionType'  Then
      l_txmsg.PreHourChxActionType := v_Value;
    Elsif v_Key ='Symbol' Then
      l_txmsg.Symbol := v_Value;

    Elsif v_Key ='OpenTime' Then
      l_txmsg.OpenTime := v_Value;

    Elsif v_Key ='MemberNo' Then
      l_txmsg.MemberNo := v_Value;

    Elsif v_Key ='TrdrNo' Then
      l_txmsg.TrdrNo := v_Value;

    Elsif v_Key ='MemberTRScope' Then
      l_txmsg.MemberTRScope := v_Value;

    End if;

  END LOOP;

  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_K06');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K06');
  RAISE errnums.E_SYSTEM_ERROR;

END fn_xml2obj_K06;

function fn_xml2obj_k07(pv_xmlmsg varchar2) return ho_tx.msg_k07 is
   l_parser   xmlparser.parser;
   l_doc      xmldom.domdocument;
   l_nodeList xmldom.domnodelist;
   l_node     xmldom.domnode;

   l_txmsg   ho_tx.msg_k07;
   v_Key     varchar2(100);
   v_Value   varchar2(100);

begin
   plog.setbeginsection (pkgctx, 'fn_xml2obj_k07');
   plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
   l_parser := xmlparser.newparser();
   plog.debug(pkgctx,'1');
   xmlparser.parseclob(l_parser, pv_xmlmsg);
   plog.debug(pkgctx,'2');
   l_doc := xmlparser.getdocument(l_parser);
   plog.debug(pkgctx,'3');
   xmlparser.freeparser(l_parser);
   plog.debug(pkgctx,'Prepare to parse Message Fields');

   l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc), '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

   for i in 0 .. xmldom.getlength(l_nodeList) - 1 loop
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      if v_Key = 'Symbol' then
            l_txmsg.Symbol := v_Value;

      ELSIF v_Key = 'ReferencePrice' then
            l_txmsg.ReferencePrice := v_Value;

      ELSIF v_Key = 'HighLimitPrice' then
            l_txmsg.HighLimitPrice := v_Value;

      ELSIF v_Key = 'LowLimitPrice' then
            l_txmsg.LowLimitPrice := v_Value;

      end if;

   end loop;


   -- Free any resources associated with the document now it
   -- is no longer needed.
   DBMS_XMLDOM.freedocument(l_doc);
   -- Only used if variant is CLOB
   -- dbms_lob.freetemporary(pv_xmlmsg);
   plog.setendsection(pkgctx, 'fn_xml2obj_k07');
   return l_txmsg;
exception when others then
   DBMS_XMLPARSER.freeparser(l_parser);
   DBMS_XMLDOM.freedocument(l_doc);
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection(pkgctx, 'fn_xml2obj_k07');
   raise errnums.E_SYSTEM_ERROR;

end fn_xml2obj_k07;


function fn_xml2obj_k08(pv_xmlmsg varchar2) return ho_tx.msg_k08 is
   l_parser   xmlparser.parser;
   l_doc      xmldom.domdocument;
   l_nodeList xmldom.domnodelist;
   l_node     xmldom.domnode;

   l_txmsg   ho_tx.msg_k08;
   v_Key     varchar2(100);
   v_Value   varchar2(100);

begin
   plog.setbeginsection (pkgctx, 'fn_xml2obj_k08');
   plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
   l_parser := xmlparser.newparser();
   plog.debug(pkgctx,'1');
   xmlparser.parseclob(l_parser, pv_xmlmsg);
   plog.debug(pkgctx,'2');
   l_doc := xmlparser.getdocument(l_parser);
   plog.debug(pkgctx,'3');
   xmlparser.freeparser(l_parser);
   plog.debug(pkgctx,'Prepare to parse Message Fields');

   l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc), '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

   for i in 0 .. xmldom.getlength(l_nodeList) - 1 loop
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      IF v_Key = 'Symbol' then
            l_txmsg.Symbol := v_Value;

      ELSIF v_Key = 'SymbolCloseInfoPx' then
            l_txmsg.SymbolCloseInfoPx := v_Value;

      ELSIF v_Key = 'SymbolCloseInfoPxType' then
            l_txmsg.SymbolCloseInfoPxType := v_Value;

      end if;

   end loop;


   -- Free any resources associated with the document now it
   -- is no longer needed.
   DBMS_XMLDOM.freedocument(l_doc);
   -- Only used if variant is CLOB
   -- dbms_lob.freetemporary(pv_xmlmsg);
   plog.setendsection(pkgctx, 'fn_xml2obj_k08');
   return l_txmsg;
exception when others then
   DBMS_XMLPARSER.freeparser(l_parser);
   DBMS_XMLDOM.freedocument(l_doc);
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection(pkgctx, 'fn_xml2obj_k08');
   raise errnums.E_SYSTEM_ERROR;

end fn_xml2obj_k08;


function fn_xml2obj_k09(pv_xmlmsg varchar2) return ho_tx.msg_k09 is
   l_parser   xmlparser.parser;
   l_doc      xmldom.domdocument;
   l_nodeList xmldom.domnodelist;
   l_node     xmldom.domnode;

   l_txmsg   ho_tx.msg_k09;
   v_Key     varchar2(100);
   v_Value   varchar2(100);

begin
   plog.setbeginsection (pkgctx, 'fn_xml2obj_k09');
   plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
   l_parser := xmlparser.newparser();
   plog.debug(pkgctx,'1');
   xmlparser.parseclob(l_parser, pv_xmlmsg);
   plog.debug(pkgctx,'2');
   l_doc := xmlparser.getdocument(l_parser);
   plog.debug(pkgctx,'3');
   xmlparser.freeparser(l_parser);
   plog.debug(pkgctx,'Prepare to parse Message Fields');

   l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc), '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

   for i in 0 .. xmldom.getlength(l_nodeList) - 1 loop
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      IF v_Key = 'Symbol' then
            l_txmsg.Symbol := v_Value;

      ELSIF v_Key = 'VITypeCode' then
            l_txmsg.VITypeCode := v_Value;

      ELSIF v_Key = 'VIKindCode' then
            l_txmsg.VIKindCode := v_Value;

      ELSIF v_Key = 'StaticVIBasePrice' then
            l_txmsg.StaticVIBasePrice := v_Value;

      ELSIF v_Key = 'DynamicVIBasePrice' then
            l_txmsg.DynamicVIBasePrice := v_Value;

      ELSIF v_Key = 'VIPrice' then
            l_txmsg.VIPrice := v_Value;

      ELSIF v_Key = 'StaticVIDispartiyRatio' then
            l_txmsg.StaticVIDispartiyRatio := v_Value;

      ELSIF v_Key = 'DynamicVIDispartiyRatio' then
            l_txmsg.DynamicVIDispartiyRatio := v_Value;

      ELSIF v_Key = 'VIActivatedTime' then
            l_txmsg.VIActivatedTime := v_Value;

      ELSIF v_Key = 'VIReleaseTime' then
            l_txmsg.VIReleaseTime := v_Value;

      end if;

   end loop;


   -- Free any resources associated with the document now it
   -- is no longer needed.
   DBMS_XMLDOM.freedocument(l_doc);
   -- Only used if variant is CLOB
   -- dbms_lob.freetemporary(pv_xmlmsg);
   plog.setendsection(pkgctx, 'fn_xml2obj_k09');
   return l_txmsg;
exception when others then
   DBMS_XMLPARSER.freeparser(l_parser);
   DBMS_XMLDOM.freedocument(l_doc);
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection(pkgctx, 'fn_xml2obj_k09');
   raise errnums.E_SYSTEM_ERROR;

end fn_xml2obj_k09;

FUNCTION fn_xml2obj_K11(pv_xmlmsg    VARCHAR2) RETURN ho_tx.msg_K11 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;


  l_txmsg   ho_tx.msg_K11;
  v_Key Varchar2(100);
  v_Value Varchar2(100);


BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K11');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

  Elsif v_Key ='Side' Then
        l_txmsg.Side := v_Value;

  Elsif v_Key ='Symbol' Then
        l_txmsg.Symbol := v_Value;

  Elsif v_Key ='Account' Then
        l_txmsg.Account := v_Value;

  Elsif v_Key ='AcceptConfirmYN' Then
        l_txmsg.AcceptConfirmYN := v_Value;

  End if;

END LOOP;


      plog.debug(pkgctx,'msg K11 l_txmsg.ClOrdID: '||l_txmsg.ClOrdID);
      plog.debug(pkgctx,'Free resources associated');

-- Free any resources associated with the document now it
-- is no longer needed.
DBMS_XMLDOM.freedocument(l_doc);
-- Only used if variant is CLOB
-- dbms_lob.freetemporary(pv_xmlmsg);

plog.setendsection(pkgctx, 'fn_xml2obj_K11');
RETURN l_txmsg;
EXCEPTION
WHEN OTHERS THEN
  --dbms_lob.freetemporary(pv_xmlmsg);
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K11');
  RAISE errnums.E_SYSTEM_ERROR;

END fn_xml2obj_K11;

FUNCTION fn_xml2obj_K15(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K15 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_K15;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);

BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K15');
  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='IOIID' Then
       l_txmsg.IOIID := v_Value;
    Elsif v_Key ='IOIRefID' Then
       l_txmsg.IOIRefID := v_Value;
    Elsif v_Key ='IOITransType' Then
       l_txmsg.IOITransType := v_Value;
    Elsif v_Key ='Symbol' Then
       l_txmsg.Symbol := v_Value;
    Elsif v_Key ='Side' Then
       l_txmsg.Side := v_Value;
    Elsif v_Key ='OrdRejReason' Then
       l_txmsg.OrdRejReason := v_Value;
    Elsif v_Key ='IOIQty' Then
       l_txmsg.IOIQty := v_Value;
    Elsif v_Key ='Price' Then
       l_txmsg.Price := v_Value;
    Elsif v_Key ='ContactNo' Then
       l_txmsg.ContactNo := v_Value;
    Elsif v_Key ='TransactTime' Then
       l_txmsg.TransactTime := v_Value;
    Elsif v_Key ='OnBehalfOfSubID' Then
       l_txmsg.OnBehalfOfSubID := v_Value;
    End if;

  END LOOP;

  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_K15');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K15');
  RAISE errnums.E_SYSTEM_ERROR;

END fn_xml2obj_K15;


FUNCTION fn_xml2obj_K16(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_K16 IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_K16;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);

BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_K16');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='IOIStatusCode'  Then
      l_txmsg.IOIStatusCode := v_Value;
    Elsif v_Key ='IOIid' Then
      l_txmsg.IOIID := v_Value;

    End if;

  END LOOP;

  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_K16');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_K16');
  RAISE errnums.E_SYSTEM_ERROR;

END fn_xml2obj_K16;

function fn_xml2obj_K17(pv_xmlmsg varchar2) return ho_tx.msg_K17 is
   l_parser   xmlparser.parser;
   l_doc      xmldom.domdocument;
   l_nodeList xmldom.domnodelist;
   l_node     xmldom.domnode;

   l_txmsg   ho_tx.msg_K17;
   v_Key     varchar2(100);
   v_Value   varchar2(100);

begin
   plog.setbeginsection (pkgctx, 'fn_xml2obj_K17');
   plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
   l_parser := xmlparser.newparser();
   plog.debug(pkgctx,'1');
   xmlparser.parseclob(l_parser, pv_xmlmsg);
   plog.debug(pkgctx,'2');
   l_doc := xmlparser.getdocument(l_parser);
   plog.debug(pkgctx,'3');
   xmlparser.freeparser(l_parser);
   plog.debug(pkgctx,'Prepare to parse Message Fields');

   l_nodeList := xslprocessor.selectnodes(xmldom.makenode(l_doc), '/ArrayOfHoSEMessageEntry/hoSEMessageEntry');

   for i in 0 .. xmldom.getlength(l_nodeList) - 1 loop
      plog.debug(pkgctx,'parse fields: ' || i);
      l_node := xmldom.item(l_nodeList, i);
      dbms_xslprocessor.valueOf(l_node,'key',v_Key);
      dbms_xslprocessor.valueOf(l_node,'value',v_Value);
      If v_Key ='Symbol'  THEN
            l_txmsg.Symbol := v_Value;
      ELSIF v_Key = 'OpenTime' then
            l_txmsg.OpenTime := v_Value;
      ELSIF v_Key = 'FornLimitIncDecQty' then
            l_txmsg.FornLimitIncDecQty := v_Value;
      end IF;

   end loop;


   -- Free any resources associated with the document now it
   -- is no longer needed.
   DBMS_XMLDOM.freedocument(l_doc);
   -- Only used if variant is CLOB
   -- dbms_lob.freetemporary(pv_xmlmsg);
   plog.setendsection(pkgctx, 'fn_xml2obj_K17');
   return l_txmsg;
exception when others then
   DBMS_XMLPARSER.freeparser(l_parser);
   DBMS_XMLDOM.freedocument(l_doc);
   plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
   plog.setendsection(pkgctx, 'fn_xml2obj_K17');
   raise errnums.E_SYSTEM_ERROR;

end fn_xml2obj_K17;

FUNCTION fn_xml2obj_S(pv_xmlmsg VARCHAR2) RETURN ho_tx.msg_S IS
  l_parser   xmlparser.parser;
  l_doc      xmldom.domdocument;
  l_nodeList xmldom.domnodelist;
  l_node     xmldom.domnode;

  l_txmsg   ho_tx.msg_S;
  v_Key VARCHAR2(100);
  v_Value VARCHAR2(100);
BEGIN
  plog.setbeginsection (pkgctx, 'fn_xml2obj_S');

  plog.debug(pkgctx,'msg length: ' || length(pv_xmlmsg));
  l_parser := xmlparser.newparser();
  plog.debug(pkgctx,'1');
  xmlparser.parseclob(l_parser, pv_xmlmsg);
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

    If v_Key ='QuoteID'  Then
      l_txmsg.QuoteID := v_Value;
    Elsif v_Key ='QuoteMsgID' Then
      l_txmsg.QuoteMsgID := v_Value;
    Elsif v_Key ='s1PartyID' Then
      l_txmsg.s1PartyID := v_Value;
    Elsif v_Key ='s2PartyID' Then
      l_txmsg.s2PartyID := v_Value;
    Elsif v_Key ='s1PartyRole' Then
      l_txmsg.s1PartyRole := v_Value;
    Elsif v_Key ='s2PartyRole' Then
      l_txmsg.s2PartyRole := v_Value;
    Elsif v_Key ='Symbol' Then
      l_txmsg.Symbol := v_Value;
    Elsif v_Key ='Side' Then
      l_txmsg.Side := v_Value;
    Elsif v_Key ='Account' Then
      l_txmsg.Account := v_Value;
    Elsif v_Key ='CashMargin' Then
      l_txmsg.CashMargin := v_Value;
    Elsif v_Key ='BidPx' Then
      l_txmsg.BidPx := v_Value;
    Elsif v_Key ='OfferPx' Then
      l_txmsg.OfferPx := v_Value;
    Elsif v_Key ='BidSize' Then
      l_txmsg.BidSize := v_Value;
    Elsif v_Key ='OfferSize' Then
      l_txmsg.OfferSize := v_Value;
    Elsif v_Key ='TradeDate' Then
      l_txmsg.TradeDate := v_Value;
    Elsif v_Key ='IOIid' Then
      l_txmsg.IOIID := v_Value;
    Elsif v_Key ='OnBehalfOfSubID' Then
       l_txmsg.OnBehalfOfSubID := v_Value;
    End IF;
  END LOOP;
  -- Free any resources associated with the document now it
  -- is no longer needed.
  DBMS_XMLDOM.freedocument(l_doc);
  -- Only used if variant is CLOB
  -- dbms_lob.freetemporary(pv_xmlmsg);
  plog.setendsection(pkgctx, 'fn_xml2obj_S');
  RETURN l_txmsg;
EXCEPTION WHEN OTHERS THEN
  DBMS_XMLPARSER.freeparser(l_parser);
  DBMS_XMLDOM.freedocument(l_doc);
  plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
  plog.setendsection(pkgctx, 'fn_xml2obj_S');
  RAISE errnums.E_SYSTEM_ERROR;
END fn_xml2obj_S;

BEGIN
FOR i IN (SELECT * FROM tlogdebug) LOOP
logrow.loglevel  := i.loglevel;
logrow.log4table := i.log4table;
logrow.log4alert := i.log4alert;
logrow.log4trace := i.log4trace;
END LOOP;

pkgctx := plog.init('pck_gw_common',
          plevel => NVL(logrow.loglevel,30),
          plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
          palert => (logrow.log4alert = 'Y'),
          ptrace => (logrow.log4trace = 'Y'));

END;
/
