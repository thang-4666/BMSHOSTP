SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_fo_bl
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
     **  TienPQ      09-JUNE-2009    Created
     ** (c) 2009 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/
 FUNCTION sp_getppse_bl (
    afacctno in VARCHAR2,
    symbol in VARCHAR2,
    price in float
      ) Return Number;

 PROCEDURE  sp_focoreplaceorder_bl (
    pv_blacctno     in VARCHAR2,
    pv_traderid     IN  VARCHAR2,
    pv_exectype     in VARCHAR2,
    pv_symbol       in VARCHAR2,
    pv_orderqtty    in float,
    pv_price        in float,
    pv_pricetype    in VARCHAR2,
    pv_timeinforce  in VARCHAR,
    pv_MAKETIME     in VARCHAR,
    pv_FOREFID      in VARCHAR,
    pv_EXPDATE      in VARCHAR,
    pv_msgseqnum    in VARCHAR2,
    pv_HandlInst    IN  VARCHAR2,
    pv_BLInstruction    IN  VARCHAR2,
    pv_SecExchange  IN  VARCHAR2
      );
PROCEDURE PRC_PLACEORDER_BL(
    pv_blacctno     IN  VARCHAR2,
    pv_Afacctno     IN  varchar2,
    pv_Symbol       IN  varchar2,
    pv_Exectype     IN  varchar2,
    pv_OrderQtty    IN  varchar2,
    pv_Price        IN  varchar2,
    pv_PriceType    IN  varchar2,
    pv_TimeType     IN  VARCHAR2,
    pv_TimeInForce  IN  varchar2,
    pv_MakeTime     IN  varchar2,
    pv_forefid      IN  varchar2,
    pv_Expdate      IN  varchar2,
    msgseqnum       in  VARCHAR2,
    pv_traderid     IN  VARCHAR2,
    pv_HandlInst    IN  VARCHAR2,
    pv_BLInstruction    IN  VARCHAR2
    );

    PROCEDURE PRC_CANCELORDER_BL(
        pv_Afacctno IN varchar2,
        pv_OrderID IN varchar2,
        pv_ClOrdID  in VARCHAR2,
        pv_Username IN varchar2,
        pv_Password IN varchar2,
        pv_msgseqnum in VARCHAR2,
        pv_traderid IN  VARCHAR2,
        pv_OrgBlorderid IN  varchar2
    );

  PROCEDURE SP_FOCORECANCELORDER_BL (
      pv_ORDERID in VARCHAR2,
      pv_ClOrdID  in VARCHAR2,
      pv_USERNAME in VARCHAR2,
      pv_PASSWORD in VARCHAR2,
      pv_msgseqnum in varchar2
  );

  PROCEDURE SP_FOCOREMODIFYORDER_BL (
      pv_ORDERID in VARCHAR2,
      pv_ClOrdID  in VARCHAR2,
      pv_PRICE  in VARCHAR2,
      pv_OrderQty in VARCHAR2,
      pv_timeinforce in VARCHAR2,
      pv_USERNAME in VARCHAR2,
      pv_PASSWORD in VARCHAR2,
      pv_msgseqnum in varchar2
  );
    PROCEDURE PRC_FOCOREAMENDORDER_BL(
        pv_Afacctno IN varchar2,
        pv_OrgOrderID IN varchar2 ,
        pv_ClOrdID  in VARCHAR2,
        pv_Price IN Varchar2,
        pv_Quantity IN  VARCHAR2,
        pv_Username IN varchar2,
        pv_Password IN varchar2,
        pv_BLOrgOrderid IN varchar2,
        pv_msgseqnum in VARCHAR2,
        pv_traderid IN  VARCHAR2,
        pv_adblorderid  IN  VARCHAR2,
        pv_OrgBLOrderid IN  varchar2
    );

    PROCEDURE bl_getaccountinfo
    (
        PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
        AFACCTNO IN VARCHAR2,
        INDATE IN VARCHAR2
    );

    PROCEDURE bl_getbloombergorder (
       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
       pv_TRADEPLACE       IN       VARCHAR2,
       pv_STATUS           IN       VARCHAR2,
       pv_ACCOUNT           IN      VARCHAR2,
       pv_SYMBOL           IN      VARCHAR2,
       pv_TLID              IN      VARCHAR2,
       pv_CMDID             IN      VARCHAR2
    );

    PROCEDURE bl_getblremngorder_asd (
       PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
       pv_STATUS            IN       VARCHAR2,
       pv_ACCOUNT           IN      VARCHAR2,
       pv_SYMBOL            IN      VARCHAR2,
       pv_WAITTIME          IN      VARCHAR2,
       pv_TLID              IN      VARCHAR2,
       pv_CMID              IN      VARCHAR2
    );

    PROCEDURE bl_getblremngorder_new (
       PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
       pv_TRADEPLACE        IN       VARCHAR2,
       pv_ACCOUNT           IN      VARCHAR2,
       pv_SYMBOL            IN      VARCHAR2,
       pv_EXECTYPE          IN      VARCHAR2,
       pv_WAITTIME          IN      VARCHAR2,
       pv_TLID              IN      VARCHAR2
    );

    PROCEDURE BL_MNGAssign (
       --pv_BLORDERID       IN      VARCHAR2,
       --pv_recustid        IN      VARCHAR2,
       pv_strassign       IN      VARCHAR2,
       pv_tlid            IN      VARCHAR2
    );

    PROCEDURE bl_mngcomment (
       pv_BLORDERID       IN      VARCHAR2,
       pv_MNGCOMMENT    IN      VARCHAR2,
       pv_tlid          IN      VARCHAR2
    );

    PROCEDURE BL_MNGPTBook (
      pv_BLORDERID     IN      VARCHAR2,
      pv_ptbook        IN      VARCHAR2,
      pv_tlid          IN      VARCHAR2,
      pv_err_code      IN OUT  varchar2,
      p_err_message    IN OUT  varchar2
    ); --RETURN NUMBER;

 FUNCTION fnc_check_blb_placeOrder
  (p_blOrderid IN Varchar2,
  p_dblQtty in number,
  p_strExectype in varchar2,
  p_orderprice in number,
  p_dblExecQtty  in number default 0, -- tham so dung cho TH map lenh: KL da khop cua lenh can map
  p_dblExecAmt   in number default 0,
  p_strMatchtype in varchar2 default 'N')
  RETURN  number;
FUNCTION fnc_check_blb_AmendmentOrder
 (p_blOrderid IN Varchar2,
  p_dblQtty in number,-- Kl cua lenh con
  p_strExectype in varchar2,
  p_orderprice in number,
  p_acctno in varchar2,
  p_functioname in VARCHAR2,
  p_AmendVia    in  varchar2 )
  return number;

  FUNCTION BL_getretlid (
       pv_BLORDERID     IN      VARCHAR2
    ) RETURN VARCHAR2;

 PROCEDURE BL_MapOrder (
     pv_BLORDERID     IN      VARCHAR2,
     pv_Orderid       IN      VARCHAR2,
     pv_tlid          IN      VARCHAR2,
     pv_err_code      IN OUT  varchar2,
     p_err_message    IN OUT  varchar2
     ) ;

 PROCEDURE BL_UnMapOrder (
     pv_BLORDERID     IN      VARCHAR2,
     pv_Orderid       IN      VARCHAR2,
     pv_tlid          IN      VARCHAR2,
     pv_err_code      IN OUT  varchar2,
     p_err_message    IN OUT  varchar2
     ) ;

    PROCEDURE bl_mngneworder(
    pv_Afacctno     IN  varchar2,
    pv_Symbol       IN  varchar2,
    pv_Exectype     IN  varchar2,
    pv_OrderQtty    IN  varchar2,
    pv_Price        IN  varchar2,
    pv_via          IN  varchar2,
    pv_Desc         IN  VARCHAR2,
    pv_tlid         IN  varchar2,
    pv_blodtype     IN  varchar2,
    pv_err_code     IN out VARCHAR2,
    p_err_message   IN OUT VARCHAR2
    );

     PROCEDURE BL_Getback_Order (
       pv_BLORDERID     IN      VARCHAR2,
       pv_newretlid     IN      VARCHAR2,
       pv_tlid          IN      VARCHAR2,
       pv_err_code      IN OUT  varchar2
    );
    PROCEDURE BL_MNGReject (
       pv_strreject       IN      VARCHAR2,
       pv_tlid            IN      VARCHAR2,
       pv_err_code      IN OUT  varchar2
    );
PROCEDURE pr_bl_mainPlaceOrder(
    pv_functionName     in varchar2,
    pv_CustodyCd     IN  VARCHAR2,
    pv_Afacctno     IN  varchar2,
    pv_Quantity       IN  varchar2,
    pv_Price     IN  varchar2,
    pv_Via    IN  varchar2,
    pv_ExecType       IN  varchar2,
    pv_PriceType    IN  varchar2,
    pv_Symbol in varchar2,
    pv_Tlid     IN  VARCHAR2,
    p_err_code out varchar2,
    p_err_message out VARCHAR2
    );
PROCEDURE pr_CommentBlbOrder
    (   p_blOrderid varchar,
        p_Comment varchar,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    );
PROCEDURE pr_bl_Check
 (p_ActionFlag IN Varchar2,
  p_blOrderid in varchar2,-- Kl cua lenh con
  p_quantity in varchar2,
  p_side  in varchar2,
  p_price   in varchar2,
  p_CurrentOrderId    in varchar2,
  p_Via     in  varchar2,
  p_err_code out varchar2,
  p_err_message out VARCHAR2);
Procedure bl_odmast_CancelOrder
(p_blOrderid      in  varchar2,
 p_cancelqtty     in  number,
 p_OrderID        in  varchar2,
 p_OrStatus       in  VARCHAR2,
 p_EDStatus       IN    VARCHAR2);
Procedure bl_odmast_AmendOrder(p_blOrderid varchar2,p_adjustqtty number,p_orderqtty number,p_execqtty number);
Procedure bl_odmast_MatchOrder(p_blOrderid varchar2,p_execqtty number,p_execamt number);
PROCEDURE BL_Process_AnyOrder;
PROCEDURE bl_rejectfo (
   pv_BLORDERID       IN      VARCHAR2,
   pv_FOACCTNO      IN      VARCHAR2,
   pv_Status        IN      VARCHAR2,
   pv_FEEDBACKMSG   IN      VARCHAR2,
   pv_Exectype      IN      varchar2
);
Procedure bl_Update_AmendOrder(
    p_FOAcctno IN VARCHAR2,
    p_blorderid IN  VARCHAR2,
    p_adjustqtty IN NUMBER,
    p_adjustprice IN  NUMBER
    );
Procedure bl_Place_AmendOrder(
    p_FOAcctno IN VARCHAR2
    );
    PROCEDURE bl_getbloombergorderdtl (
       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
       pv_TRADEPLACE       IN       VARCHAR2,
       pv_STATUS           IN       VARCHAR2,
       pv_ACCOUNT           IN      VARCHAR2,
       pv_SYMBOL           IN      VARCHAR2,
       pv_TLID              IN      VARCHAR2,
       pv_CMDID             IN      VARCHAR2
    );
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_fo_bl IS
  pkgctx plog.log_ctx;
  logrow tlogdebug%ROWTYPE;


FUNCTION sp_getppse_bl (
afacctno in VARCHAR2,
symbol in VARCHAR2,
price in float
  ) Return Number IS
   PV_REFCURSOR   PKG_REPORT.REF_CURSOR;
   v_PPSe Number(20,2);
BEGIN

  pr_GETPPSE(PV_REFCURSOR,afacctno,symbol,price/1000);
  --Open PV_REFCURSOR;
  Fetch PV_REFCURSOR INTO v_PPSe;
  Close PV_REFCURSOR;
  If v_PPSe is null then
    v_PPSe:=0;
  End if;
  Return v_PPSe;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;

/*
pck_fo_bl.sp_focoreplaceorder_bl (
afacctno in VARCHAR2,   --Truyen Custodycd vao
exectype in VARCHAR2,   --Loai lenh mua/ban 2:NS 1:NB
symbol in VARCHAR2,     --Ma CK VD: VND, FPT
orderqtty in float,     --Khoi luong.
price in float,         --Gia: 16500
pricetype in VARCHAR2,  --2: LO, ATO, ATC: BL chi co LO
timeinforce in VARCHAR, --0: Lenh trong ngay, 1. GTC  BL chi dung  0.
MAKETIME in VARCHAR,    --Thoi gian dat lenh HH24:MI:SS
FOREFID in VARCHAR,     --ID cua BL truyen vao.
EXPDATE in VARCHAR)     --Thoi gian het hieu luc cua lenh GTC, BL se khong dung.
*/


--------------Bloomberg chanel----------------------
PROCEDURE sp_focoreplaceorder_bl (
    pv_blacctno     in VARCHAR2,
    pv_traderid     IN  VARCHAR2,
    pv_exectype     in VARCHAR2,
    pv_symbol       in VARCHAR2,
    pv_orderqtty    in float,
    pv_price        in float,
    pv_pricetype    in VARCHAR2,
    pv_timeinforce  in VARCHAR,
    pv_MAKETIME     in VARCHAR,
    pv_FOREFID      in VARCHAR,
    pv_EXPDATE      in VARCHAR,
    pv_msgseqnum    in VARCHAR2,
    pv_HandlInst    IN  VARCHAR2,
    pv_BLInstruction    IN  VARCHAR2,
    pv_SecExchange  IN  VARCHAR2
  ) IS
  V_ERRCODE INTEGER;
  v_strExectype varchar2(10);
  v_strTimeinforce varchar2(10);
  v_strPricetype varchar2(10);
  v_check boolean;
  v_strError Varchar2(500);
  v_exp Exception;
  v_Count Number(20);
  v_Symbol varchar2(100);
  v_tradeplace VARCHAR2(10);
  v_dblqtty number(20);
  V_TimeType    varchar2(1);
  v_afacctno    varchar2(20);
  v_tradelot    NUMBER;
  l_hnxTRADINGID        varchar2(20);
  v_securitytradingSTS varchar2(3);
  v_strMarketStatus varchar2(10);
  v_floorprice  NUMBER;
  v_ceilingprice    NUMBER;
  v_ticksize    NUMBER;
  v_halt        varchar2(10);
BEGIN
    V_ERRCODE:=0;
    v_check :=True;
    v_Symbol := pv_symbol;
    v_dblqtty := pv_orderqtty;
    plog.error(pkgctx,'sp_focoreplaceorder_bl v_Afacctno '||pv_blacctno
                                                          ||' exectype '||pv_exectype
                                                          ||' symbol '|| pv_symbol
                                                          ||' orderqtty '||pv_orderqtty
                                                          ||' price '||pv_price
                                                          ||' pricetype '||pv_pricetype
                                                          ||' timeinforce '||pv_timeinforce
                                                          ||'  MAKETIME '||pv_MAKETIME
                                                          ||'  FOREFID '||pv_FOREFID
                                                          ||'  EXPDATE '||pv_EXPDATE
                                                          ||'  msgseqnum '||pv_msgseqnum
                      );

    /* Validate du lieu, neu loi tra ve ma loi tuong ung */

    /*If fopks_api.fn_is_ho_active =false then
      v_check:= False;
      v_strError:='Exchange Closed';
      Raise v_exp;
    End if;*/

    -- Kiem tra CK co thuoc thi truong VN hay ko
    If pv_SecExchange <> 'VN'  Then
      v_check:= False;
      v_strError:='Order security is not security of Vietnam Exchange!';
      Raise v_exp;
    End if;
    --Kiem tra ds afacctno, neu khong co trong ds dat lenh cua Bloomberg thi bao loi

    Select Count(1) into v_Count
    from bl_register
    where TRIM(blacctno) = TRIM(pv_blacctno) AND status = 'A';
    If v_Count =0  Then
      v_check:= False;
      v_strError:='Unknown Account No';
      Raise v_exp;
    End if;

    -- Kiem tra loai lenh dc dat
    Select Count(1) into v_Count
    from bl_register bl
    where blacctno = pv_blacctno AND status = 'A' AND instr(bl.blodtype,pv_HandlInst) > 0;
    If v_Count =0  Then
      v_check:= False;
      v_strError:='Account is not allowed to order with this Handle Instruction!';
      Raise v_exp;
    End if;

    -- Kiem tra TraderID
    Select Count(1) into v_Count
    from bl_traderef
    where blacctno = pv_blacctno AND traderid = pv_traderid AND status = 'A';
    If v_Count =0  Then
      v_check:= False;
      v_strError:='Unknown Account No';
      Raise v_exp;
    End if;

    If   pv_pricetype not in ('1', '2', '5', '7')  Then --Chi lay lenh LO
      v_check:= False;
      v_strError:='Unsupported Order Type';
      Raise v_exp;

    ElsIf  pv_exectype not in ('1','2') Then  --<> 'NB,NS'

      v_check:= False;
      v_strError:='Invalid Side';
      Raise v_exp;

    ElsIf  pv_timeinforce NOT in  ('0','1','7','2','3','4') Then  --<> 'T'

      v_check:= False;
      v_strError:='Invalid TimeInForce';
      Raise v_exp;
    End if;

    --Check ma chung khoan co tren san giao dich.
    v_Count :=1;
    Begin
      Select s.tradeplace, i.tradelot, i.floorprice, i.ceilingprice, s.halt
      into v_tradeplace, v_tradelot, v_floorprice, v_ceilingprice, v_halt
      from securities_info i, sbsecurities s
      where i.symbol =v_Symbol
            and i.codeid = s.codeid;
    Exception when others then
      v_Count := 0;
    End;
    If v_Count =0 Then
       v_check:= False;
       v_strError:='Unknown Symbol';
       Raise v_exp;
    End if;
    -- Kiem tra gia tran san
    IF pv_price < v_floorprice OR pv_price > v_ceilingprice THEN
        v_check:= False;
        v_strError:='Order price is not between floor price and ceiling price.';
        Raise v_exp;
    END IF;
    -- Kiem tra khoi luong phai dung lo GD
    If pv_orderqtty Mod v_tradelot <> 0 Then
        v_check:= False;
        v_strError:='Invalid Trade lot';
        Raise v_exp;
    End If;
    -- Kiem tra CK phai khong o trang thai tam ngung GD
    If v_halt = 'Y' Then
        v_check:= False;
        v_strError:='Securities is suspended for trading';
        Raise v_exp;
    End If;

    /*If v_tradeplace = '001' Then
       if v_dblqtty >= 20000 then
       v_check :=FALSE;
       v_strError := 'Over order qtty with HOSE tradeplace(less than 20000 per 1 order)';
       Raise v_exp;
       end if;
    Els*/
    if v_tradeplace ='002' Then
       if v_dblqtty > 1000000 Then
          v_check :=FALSE;
          v_strError := 'Over order qtty with HNX tradeplace(less than 1,000,000 per 1 order)';
          Raise v_exp;
       end if;
    End if;

    v_strExectype := case when pv_exectype='1' then 'NB'
                          when pv_exectype='2' then 'NS'
                          else pv_exectype end;

    /*v_strPricetype := case when pv_pricetype ='2' then 'LO'
                           when pv_pricetype ='1' then 'MO'
                           when pv_pricetype ='5' then 'ATC'
                           else pv_pricetype end;*/

    v_strPricetype := case when pv_pricetype ='2' AND pv_timeinforce = '0' then 'LO'
                           when pv_pricetype ='5' AND pv_timeinforce = '0' then 'ATC'
                           when pv_pricetype ='2' AND pv_timeinforce = '1' then 'LO'
                           when pv_pricetype ='1' AND pv_timeinforce = '0' then 'MP'
                           when pv_pricetype ='1' AND pv_timeinforce = '2' then 'ATO'
                           when pv_pricetype ='1' AND pv_timeinforce = '4' then 'MOK'
                           when pv_pricetype ='1' AND pv_timeinforce = '3' then 'MAK'
                           when pv_pricetype ='7' AND pv_timeinforce = '0' then 'MTL'
                           when pv_pricetype ='5' AND pv_timeinforce = '7' then 'ATC'
                           else 'ERR' end;

    IF v_strPricetype = 'ERR' THEN
        v_check :=FALSE;
        v_strError := 'Invalid OrderType or TimeInForce!';
        Raise v_exp;
    END IF;

    --Kiem tra gia dat phai thoa man ticksize.
    IF v_strPricetype IN ('LO') THEN
        SELECT count(1) into v_Count
        FROM SECURITIES_TICKSIZE
        WHERE symbol=v_Symbol AND STATUS='Y'
            AND TOPRICE>= pv_price AND FROMPRICE<=pv_price;
         if v_Count<=0 then
             --Chua dinh nghia TICKSIZE
             v_check:= False;
             v_strError:=  'Ticksize undefined';
             Raise v_exp;
         else
             SELECT mod(pv_price, ticksize)
             INTO v_ticksize
             FROM SECURITIES_TICKSIZE
             WHERE symbol=v_Symbol AND STATUS='Y'
                AND TOPRICE>= pv_price AND FROMPRICE<=pv_price;
             If v_ticksize <> 0  Then
                 v_check:= False;
                 v_strError:=  'Ticksize incompliant';
                 Raise v_exp;
             End If;
         end if;
    END IF;

   V_TimeType := CASE WHEN pv_pricetype ='2' AND pv_timeinforce = '1' then 'G'
                        ELSE 'T' END;

    -- Check lenh phu hop voi san GD
    IF v_strPricetype in ('MOK','MAK','MTL') AND v_tradeplace ='001' THEN
        v_check :=FALSE;
        v_strError := v_strPricetype || ' order is not supported in this exchange';
        Raise v_exp;
    ELSIF v_strPricetype in ('MP','ATO') AND v_tradeplace in ('002','005') THEN
        v_check :=FALSE;
        v_strError := v_strPricetype || ' order is not supported in this exchange';
        Raise v_exp;
    END IF;

    -- Kiem tra lenh phai phu hop voi phien dat lenh
    If v_strPricetype = 'ATO' AND v_tradeplace = '001' THEN
        select sysvalue into v_strMarketStatus  from ordersys where sysname='CONTROLCODE';
          If v_strMarketStatus not in ('P','J')/* or v_strMarketStatus = 'O' Or v_strMarketStatus = 'A'*/ Then
            v_check :=FALSE;
            v_strError := v_strPricetype || ' order is not allowed in this session of stock exchange';
            Raise v_exp;
          End If;
      End If;

    If v_strPricetype = 'MP' AND v_tradeplace = '001' THEN
        select sysvalue into v_strMarketStatus  from ordersys where sysname='CONTROLCODE';
          If v_strMarketStatus NOT IN ('I','O','P') Then
            v_check :=FALSE;
            v_strError := v_strPricetype || ' order is not allowed in this session of stock exchange';
            Raise v_exp;
          End If;
      End If;

    SELECT sysvalue
     INTO l_hnxTRADINGID
     FROM ordersys_ha
     WHERE sysname = 'TRADINGID';

    IF v_strPricetype IN ('MTL','MOK','MAK') AND l_hnxTRADINGID IN ('CLOSE','CLOSE_BL') AND v_tradeplace in ('002','005') THEN
        v_check :=FALSE;
        v_strError := v_strPricetype || ' order is not allowed in this session of stock exchange';
        Raise v_exp;
    END IF;

    IF l_hnxTRADINGID = 'PCLOSE' AND v_tradeplace in ('002','005') THEN
        v_check :=FALSE;
        v_strError := v_strPricetype || ' order is not allowed in this session of stock exchange';
        Raise v_exp;
    END IF;

      -- end of  PhuongHT: PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
  -- PhuongHT: check chung khoan moi niem yet, dac biet: khong dc dat lo le
  --ThangPV chinh sua lo le HSX 27-04-2022
    --if v_tradeplace in ('002','005') then
    IF (v_tradeplace ='001' AND pv_orderqtty>v_tradelot) OR (v_tradeplace in ('002','005') AND pv_orderqtty>v_tradelot) then
    --End ThangPV chinh sua lo le HSX 27-04-2022
         begin
              select nvl(securitytradingstatus,'17')
              into v_securitytradingSTS
              from hasecurity_req
              where symbol=v_Symbol;
         exception when others then
           v_securitytradingSTS:='17';
         end;
           if v_securitytradingSTS in ('1','27') and pv_orderqtty < 100  then
                v_check :=FALSE;
                v_strError := v_strPricetype || ' order is not allowed in this session of stock exchange';
                Raise v_exp;
           end if ;
     end if;


    /*v_strTimeinforce := case when timeinforce ='0' then 'T'
                             when timeinforce ='1' then 'GTC'
                             when timeinforce ='3' then 'I'
                             else timeinforce end;*/

    -- Lay so tieu khoan dat lenh
    SELECT afacctno
    INTO v_afacctno
    FROM bl_register
    WHERE blacctno = pv_blacctno AND status = 'A';

    PRC_PLACEORDER_BL(pv_blacctno, v_afacctno, pv_symbol,v_strExectype,
        pv_orderqtty, pv_price, v_strPricetype,V_TimeType, v_strTimeinforce,
        pv_MAKETIME,pv_FOREFID,pv_EXPDATE,pv_msgseqnum, pv_traderid, pv_HandlInst,pv_BLInstruction);
EXCEPTION WHEN v_exp THEN
  --Tra ve msg Reject tuong ung
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
                                 price,
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
                 SELECT  bl_event_seq.nextval,
                     '8' msgtype,
                     '0' avgpx,
                     pv_FOREFID clordid,
                     ' ' commission,
                     '1' commtype,
                     0 cumqty,
                     ' ',
                     pv_FOREFID execid,
                     ' ' execrefid,
                     '0' exectranstype,
                     '8' exectype,                                          --lenh sua
                     ' ' idsource,
                     '0'  lastpx,
                     '0' lastshares,
                     pv_orderqtty leavesqty,
                     0 nomiscfees,
                     0 miscfeeamt,
                     pv_FOREFID orderid,
                     pv_orderqtty orderqty,
                     pv_price price,
                     '8' ordstatus,
                     pv_pricetype ordtype,
                     ' ' OrigClOrdID,
                     ' ' securityid,
                     pv_exectype side,
                     pv_symbol symbol,
                     pv_MAKETIME transactiontime,
                     ' ' securitytype,
                     'VN' securityexchange,
                     'OD' tblname,
                     pv_blacctno afacctno,
                     v_strError,
                     'N',
                     pv_traderid
              FROM   DUAL;


     Commit;

END;


PROCEDURE PRC_PLACEORDER_BL(
    pv_blacctno     IN  VARCHAR2,
    pv_Afacctno     IN  varchar2,
    pv_Symbol       IN  varchar2,
    pv_Exectype     IN  varchar2,
    pv_OrderQtty    IN  varchar2,
    pv_Price        IN  varchar2,
    pv_PriceType    IN  varchar2,
    pv_TimeType     IN  VARCHAR2,
    pv_TimeInForce  IN  varchar2,
    pv_MakeTime     IN  varchar2,
    pv_forefid      IN  varchar2,
    pv_Expdate      IN  varchar2,
    msgseqnum       in  VARCHAR2,
    pv_traderid     IN  VARCHAR2,
    pv_HandlInst    IN  VARCHAR2,
    pv_BLInstruction    IN  VARCHAR2
    )
 IS
    v_strVIA          Varchar2(1);
    v_strACTYPE       Varchar2(10);
    v_strACCTNO       Varchar2(20);
    v_strCLEARCD      Varchar2(20);
    v_strMATCHTYPE    Varchar2(10);
    v_strSTATUS       Varchar2(10);
    v_strCONFIRMEDVIA Varchar2(10);
    v_strNORK         Varchar2(10);
    v_dblQUANTITY     Number(20,2);
    v_dblPRICE        Varchar2(20);
    v_dblQUOTEPRICE   Number(20,2);
    v_dblTRIGGERPRICE Number(20,2);
    v_dblEXECQTTY     Number(20,2);
    v_dblEXECAMT      Number(20,2);
    v_dblREMAINQTTY   Number(20,2);
    v_dblCLEARDAY     Number(20,2);
    v_strBOOK         Varchar2(10);


    v_strCURRDATE Date;
    v_strCodeID Varchar2(20);
    v_strTimeType Varchar2(20);

    v_strORDERID varchar2(20);
    v_BatchSEQ   varchar2(20);
    v_strFEEDBACKMSG varchar2(200);
    v_Username varchar2(100):='BPS';
    v_Password varchar2(100):='';
    v_strExpiredate Date;
    v_msgseqnum varchar2(30);
    v_strtradeplace varchar2(10);
    v_strAFACTYPE   varchar2(10);
    v_sectype       varchar2(10);
    v_deffeerate    NUMBER;
    v_ppse          NUMBER;
    v_SeTrade       NUMBER;
    v_CeilingPrice  NUMBER;
    v_CustAtCom     varchar2(10);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    v_BL_OdmastSEQ  varchar2(50);
    v_BLORDERID     varchar2(20);
    v_Custodycd     varchar2(10);
    v_BLODSTATUS    varchar2(1);
    v_GetRETLID     varchar2(10);
    v_RETLID        varchar2(10);
    v_ISREASD       varchar2(1);

 Begin
    plog.setbeginsection(pkgctx, 'PRC_PLACEORDER_BL');

   plog.error(pkgctx,'SP_FOCOREPLACEORDER_BL v_Afacctno '||pv_Afacctno ||' v_Symbol '||pv_Symbol ||' v_Exectype '|| pv_Exectype
                     ||' v_OrderQtty '||pv_OrderQtty ||' v_Price '||pv_Price ||' v_forefid '||pv_forefid||' v_Expdate '||pv_Expdate );

    v_strVIA :='L';
    v_strACTYPE:='';
    v_strACCTNO :='';
    v_strCLEARCD   :=   'B';
    v_strMATCHTYPE :=   'N';
    v_strSTATUS     :=  'P';
    v_strCONFIRMEDVIA  :='N';
    v_strNORK          :='N';
    v_strBOOK           :='A';
    v_BLODSTATUS    := 'P';
    v_strSTATUS     := 'P';

    v_dblQUANTITY     :=0;
    v_dblPRICE        :=0;
    v_dblQUOTEPRICE   :=0;
    v_dblTRIGGERPRICE :=0;
    v_dblEXECQTTY     :=0;
    v_dblEXECAMT      :=0;
    v_dblREMAINQTTY   :=0;
      --T2-NAMNT
    --    v_dblCLEARDAY    :=3;
    -- Mac dinh lay chu ky thanh toan tren sysvar
    select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
    --End T2-NAMNT
    v_msgseqnum := to_char(msgseqnum);

    --Lay ngay hien tai:
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strCURRDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

    Begin
       Select af.acctno, af.actype, cf.custatcom, cf.custodycd
       into v_strACCTNO, v_strAFACTYPE, v_CustAtCom, v_Custodycd
       From afmast af, cfmast cf
       WHERE af.custid = cf.custid AND  af.acctno = pv_Afacctno;
       v_strVIA:='L';
    Exception when others then
       v_strACCTNO:=pv_Afacctno;
    end;
    plog.error(pkgctx,'v_strACCTNO--->'||v_strACCTNO);

    v_dblQUANTITY:=pv_OrderQtty;
    v_dblPRICE:=pv_Price/1000;
    v_dblREMAINQTTY:=pv_OrderQtty;
    v_dblQUOTEPRICE :=pv_Price/1000;

    /*If v_TimeInForce <> '0' Then
       v_strTimeType:='G';
       v_strExpiredate:= to_date(v_Expdate,'yyyymmdd');
    Else
       v_strTimeType:='T';
       v_strExpiredate:=v_strCURRDATE;
    End if;*/

    If pv_TimeType = 'G' Then
       v_strTimeType:='G';
       --v_strExpiredate:= to_date(v_Expdate,'yyyymmdd');
       v_strExpiredate:=v_strCURRDATE;
    Else
       v_strTimeType:='T';
       v_strExpiredate:=v_strCURRDATE;
    End if;

    --Lay CODEID theo SYMBOL
    BEGIN
      SELECT CODEID, tradeplace, sectype
      Into v_strCodeID, v_strtradeplace,v_sectype
      FROM Sbsecurities where symbol =pv_Symbol;
    Exception when others then
      plog.error(pkgctx,'SP_FOCOREPLACEORDER Get CodeID from Symbol '||sqlerrm);
    End;

    --Kiem tra loai hinh co phu hop hay khong
    BEGIN
        -- Lay gia tri loai hinh lenh
        v_strACTYPE := fopks_api.fn_GetODACTYPE(v_strACCTNO, pv_Symbol, v_strCodeID, v_strtradeplace, pv_Exectype,
                                    pv_PriceType, v_strTimeType, v_strAFACTYPE, v_sectype, v_strVIA);
    Exception when others then
        plog.error(pkgctx,' SP_FOCOREPLACEORDER Get ACTYPE '||sqlerrm);
    END;

    v_strFEEDBACKMSG := 'Order is received and pending to process';
    -- Check so du tien/ CK truoc khi day lenh
    IF pv_Exectype = 'NB' THEN
        SELECT ot.deffeerate
        INTO v_deffeerate
        FROM odtype ot WHERE actype = v_strACTYPE;
        IF pv_PriceType IN ('ATO','ATC','MP','MOK','MAK','MTL') THEN
            SELECT s.ceilingprice
            INTO v_CeilingPrice
            FROM securities_info s WHERE s.symbol = pv_Symbol;
            v_dblPRICE := v_CeilingPrice/1000;
        END IF;
        -- Lay suc mua hien tai

        v_ppse := fn_getppse(v_strACCTNO, pv_Symbol, v_dblPRICE, 'O');

        -- Kiem tra voi gia tri dat lenh
        IF v_ppse < CEIL((1+v_deffeerate/100) * v_dblPRICE * v_dblQUANTITY * 1000) THEN
            IF v_CustAtCom = 'Y' THEN
                v_BLODSTATUS := 'R';
                v_strSTATUS := 'R';
            ELSE
                v_BLODSTATUS := 'T';
                v_strSTATUS := 'T';
            END IF;
            SELECT d.errdesc
            INTO v_strFEEDBACKMSG
            FROM deferror d WHERE d.errnum = '-400116';
        END IF;
    ELSIF pv_Exectype = 'NS' THEN
        IF pv_PriceType IN ('ATO','ATC','MP','MOK','MAK','MTL') THEN
            SELECT s.floorprice
            INTO v_CeilingPrice
            FROM securities_info s WHERE s.symbol = pv_Symbol;
            v_dblPRICE := v_CeilingPrice/1000;
        END IF;

        l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(v_strACCTNO || v_strCodeID,'SEMAST','ACCTNO');
        v_SeTrade := l_SEMASTcheck_arr(0).TRADE;
        -- Kiem tra voi so CK dat
        IF v_SeTrade < v_dblQUANTITY THEN
            IF v_CustAtCom = 'Y' THEN
                v_BLODSTATUS := 'R';
                v_strSTATUS := 'R';
            ELSE
                v_BLODSTATUS := 'T';
                v_strSTATUS := 'T';
            END IF;
            SELECT d.errdesc
            INTO v_strFEEDBACKMSG
            FROM deferror d WHERE d.errnum = '-900017';
        END IF;
    END IF;

    -- Ghi nhan vao bang lenh Bloomberg
    Select blorderid_seq.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
    v_BLORDERID := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');

    INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                            PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                            CANCELQTTY,AMENDQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                            TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                            PRETLID,ASSIGNTIME,EXECTIME,FOREFID,BLINSTRUCTION,ORGQUANTITY,ORGPRICE,ROOTORDERID)
    VALUES (bl_odmast_seq.NEXTVAL,v_BLORDERID,pv_blacctno,pv_Afacctno,v_Custodycd,pv_traderid,v_BLODSTATUS,pv_HandlInst,pv_Exectype,
            pv_PriceType,pv_TimeType,v_strCodeID,pv_Symbol,v_dblQUANTITY,v_dblPRICE,0,0,v_dblQUANTITY,
            0,0,'',v_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_strCURRDATE,
            '',v_strCURRDATE,v_strExpiredate,v_strVIA,'N',v_Username, 'N', '6868','','','','',pv_forefid,pv_BLInstruction,v_dblQUANTITY,v_dblPRICE,v_BLORDERID);

    -- Tu dong lay thong tin moi gioi de gan cho lenh
    IF v_BLODSTATUS <> 'R' THEN
        v_GetRETLID := BL_GetRETLID(v_BLORDERID);
        --plog.error(pkgctx,'MG--->'||v_GetRETLID);
        IF instr(v_GetRETLID,'|') >0 THEN
            v_RETLID := substr(v_GetRETLID,1,instr(v_GetRETLID,'|')-1);
            v_ISREASD := substr(v_GetRETLID,instr(v_GetRETLID,'|')+1);
        ELSE
            v_RETLID := '';-- Khong gan cho MG nao
            v_ISREASD := 'N';
        END IF;
        --plog.error(pkgctx,'MG 1 --->'||v_RETLID || v_ISREASD);
        -- Cap nhat lai vao bang lenh Bloomberg
        IF LENGTH(v_RETLID) > 0 THEN
            UPDATE bl_odmast SET
                pstatus = pstatus || status,
                status = CASE WHEN v_BLODSTATUS = 'T'/* AND pv_HandlInst = '1'*/ THEN 'T' ELSE 'A' END,
                retlid = v_RETLID,
                isreasd = v_ISREASD,
                ASSIGNTIME = SYSTIMESTAMP,
                last_change = SYSTIMESTAMP
            WHERE blorderid = v_BLORDERID;
        END IF;
    END IF;


    -- Kiem tra neu lenh truc tiep thi day vao Flex
    -- Neu lenh gian tiep thi de lai de MG xu ly
    -- 10-Dec-2013: Sua lai, neu lenh Manual/Any LO thi moi cho MG xu ly,
    -- Cac loai lenh khac day thang vao san
    IF (pv_HandlInst = '1' OR pv_PriceType IN ('ATO','ATC','MP','MOK','MAK','MTL')) AND v_BLODSTATUS NOT IN ('R','T') THEN
        -- Lenh truc tiep, day thang vao Flex

        /*--Kiem tra loai hinh co phu hop hay khong
        BEGIN
            -- Lay gia tri loai hinh lenh
            v_strACTYPE := fopks_api.fn_GetODACTYPE(v_strACCTNO, pv_Symbol, v_strCodeID, v_strtradeplace, pv_Exectype,
                                        pv_PriceType, v_strTimeType, v_strAFACTYPE, v_sectype, v_strVIA);
        Exception when others then
            plog.debug(pkgctx,' SP_FOCOREPLACEORDER Get ACTYPE '||sqlerrm);
        END;*/

        -- v_strFEEDBACKMSG := 'Order is received and pending to process';
        -- Check so du tien/ CK truoc khi day lenh
        /*IF pv_Exectype = 'NB' THEN
            SELECT ot.deffeerate
            INTO v_deffeerate
            FROM odtype ot WHERE actype = v_strACTYPE;
            IF pv_PriceType IN ('ATO','ATC') THEN
                SELECT s.ceilingprice
                INTO v_CeilingPrice
                FROM securities_info s WHERE s.symbol = pv_Symbol;
                v_dblQUOTEPRICE := v_CeilingPrice/1000;
            END IF;
            -- Lay suc mua hien tai
            v_ppse := fn_getppse(v_strACCTNO, pv_Symbol, v_dblQUOTEPRICE, 'O');
            -- Kiem tra voi gia tri dat lenh
            IF v_ppse < CEIL((1+v_deffeerate) * v_dblQUOTEPRICE * v_dblQUANTITY * 1000) THEN
                IF v_CustAtCom = 'Y' THEN
                    v_strSTATUS := 'R';
                ELSE
                    v_strSTATUS := 'T';
                END IF;
                SELECT d.errdesc
                INTO v_strFEEDBACKMSG
                FROM deferror d WHERE d.errnum = '-400116';
            END IF;
        ELSIF pv_Exectype = 'NS' THEN
            l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(v_strACCTNO || v_strCodeID,'SEMAST','ACCTNO');
            v_SeTrade := l_SEMASTcheck_arr(0).TRADE;
            -- Kiem tra voi so CK dat
            IF v_SeTrade < v_dblQUANTITY THEN
                IF v_CustAtCom = 'Y' THEN
                    v_strSTATUS := 'R';
                ELSE
                    v_strSTATUS := 'T';
                END IF;
                SELECT d.errdesc
                INTO v_strFEEDBACKMSG
                FROM deferror d WHERE d.errnum = '-900017';
            END IF;
        END IF;*/

        --Tao so hieu lenh: format dd/mm/yyyyNNNNNNNNNN vd:  09/05/20110000002941
       Select SEQ_FOMAST.NEXTVAL Into v_BatchSEQ from DUAL;
       v_strORDERID:=to_char(v_strCURRDATE,'dd/mm/yyyy')||LPAD(v_BatchSEQ,10,'0');
/*
        -- Ghi nhan vao FOMAST
       INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                           TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                           CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY,
                           QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY,
                           EXECAMT, REMAINQTTY,VIA,
                           EFFDATE,EXPDATE,USERNAME,FOREFID,DIRECT,TLID,TRADERID,BLORDERID)
       VALUES ( v_strORDERID , v_strORDERID, v_strACTYPE, v_strACCTNO,v_strSTATUS, pv_EXECTYPE, pv_PRICETYPE,
                v_strTIMETYPE , v_strMATCHTYPE , v_strNORK ,  v_strCLEARCD , v_strCODEID  ,  pv_SYMBOL,
                v_strCONFIRMEDVIA  , v_strBOOK,  v_strFEEDBACKMSG  , TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), v_dblCLEARDAY,
                v_dblQUANTITY ,  v_dblPRICE , v_dblQUOTEPRICE , v_dblTRIGGERPRICE , v_dblEXECQTTY ,
                v_dblEXECAMT , v_dblREMAINQTTY , v_strVIA,
                v_strCURRDATE, v_strExpiredate,v_Username,pv_forefid,'N','6868', pv_traderid,v_BLORDERID);
*/
--T2-NAMNT
   -- Ghi nhan vao FOMAST
       INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                           TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                           CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY,
                           QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY,
                           EXECAMT, REMAINQTTY,VIA,
                           EFFDATE,EXPDATE,USERNAME,/*ACTIVATEDTIME,*/ FOREFID,DIRECT,TLID,TRADERID,BLORDERID)
       VALUES ( v_strORDERID , v_strORDERID, v_strACTYPE, v_strACCTNO,v_strSTATUS, pv_EXECTYPE, pv_PRICETYPE,
                v_strTIMETYPE , v_strMATCHTYPE , v_strNORK ,  v_strCLEARCD , v_strCODEID  ,  pv_SYMBOL,
                v_strCONFIRMEDVIA  , v_strBOOK,  v_strFEEDBACKMSG  , TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), v_dblCLEARDAY,
                v_dblQUANTITY ,  v_dblPRICE , v_dblQUOTEPRICE , v_dblTRIGGERPRICE , v_dblEXECQTTY ,
                v_dblEXECAMT , v_dblREMAINQTTY , v_strVIA,
                v_strCURRDATE, v_strExpiredate,v_Username,/*sysdate,*/pv_forefid,'N','6868', pv_traderid,v_BLORDERID);

 --END T2-NAMNT
       --insert msgseqnum

        plog.debug(pkgctx,'v_msgseqnum-->'||v_msgseqnum);
        Insert into bl_msgseqnum_map(msgseqnum,acctno,ClOrdID,Orderqtty) values(v_msgseqnum,v_strORDERID,pv_forefid,v_dblQUANTITY);

        -- Cap nhat lai lenh trong bl_odmast la da day vao Flex
        IF v_strSTATUS NOT IN ('R','T') THEN
            v_strFEEDBACKMSG := 'Order is sent to Flex: ' || v_strORDERID;
        END IF;

        UPDATE bl_odmast SET
            pstatus = pstatus || status,
            status = decode(v_strSTATUS,'R','R','T','T','F'),
            FEEDBACKMSG = v_strFEEDBACKMSG,
            last_change = SYSTIMESTAMP
        WHERE blorderid = v_BLORDERID;
    END IF;
    plog.setendsection(pkgctx, 'PRC_PLACEORDER_BL');

Exception when others then
        plog.error(pkgctx,' PRC_PLACEORDER_BL '||sqlerrm);
 End;

-- PHuongHT: dat lenh tong BloomBerg
-- objEntryVia, objEntrySide, objEntryPriceType, objEntryTlid, objEntryErrorCode, objEntryErrorMessage
PROCEDURE pr_bl_mainPlaceOrder(
    pv_functionName     in varchar2,
    pv_CustodyCd     IN  VARCHAR2,
    pv_Afacctno     IN  varchar2,
    pv_Quantity       IN  varchar2,
    pv_Price     IN  varchar2,
    pv_Via    IN  varchar2,
    pv_ExecType       IN  varchar2,
    pv_PriceType    IN  varchar2,
    pv_Symbol in varchar2,
    pv_Tlid     IN  VARCHAR2,
    p_err_code out varchar2,
    p_err_message out VARCHAR2
    )
 IS
    v_dtCURRDATE Date;
    v_strCodeID Varchar2(20);
    v_strORDERID varchar2(20);
    v_blacctno varchar2(50);
    v_traderid varchar2(50);
    v_BLODSTATUS varchar2(3);
    v_HandlInst varchar2(3);
    v_dblquantity number(20,0);
    v_dblprice    number(20,3);
    v_strFEEDBACKMSG varchar2(500);
    v_strVIA         varchar2(2);
    v_Username       varchar2(30);
    v_BL_OdmastSEQ   number(20,0);
    v_BLORDERID      varchar2(30);
    l_SEMASTcheck_arr txpks_check.semastcheck_arrtype;
    v_SeTrade         number(20,0);
    v_strAFACTYPE   varchar2(10);
    v_sectype       varchar2(10);
    v_deffeerate    NUMBER;
    v_ppse          NUMBER;

    v_CeilingPrice  NUMBER;
    v_CustAtCom     varchar2(1);
    v_strACTYPE     varchar2(10);
    v_strACCTNO     varchar2(10);
    v_strtradeplace varchar2(10);
    v_strTimeType   varchar2(5);

    v_strSTATUS     varchar2(5);
    v_blAutoid      varchar2(30);
    v_CurrRetlid    varchar2(10);
 Begin
   plog.setbeginsection(pkgctx, 'pr_bl_mainPlaceOrder');
    p_err_code := systemnums.C_SUCCESS;
    v_blacctno:='';
    v_traderid:='';
    v_BLODSTATUS:='A';
    v_HandlInst:='5';
    v_dblquantity:=to_number(pv_quantity);
    v_dblPRICE:=to_number(pv_price)/1000;
    v_strVIA:=pv_Via;
    v_Username:='';
    v_strTimeType:='T';

   --Lay ngay hien tai:
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_dtCURRDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';
    Begin
       Select af.acctno, af.actype, cf.custatcom
       into v_strACCTNO, v_strAFACTYPE, v_CustAtCom
       From afmast af, cfmast cf
       WHERE af.custid = cf.custid AND  af.acctno = pv_Afacctno;
    Exception when others then
       v_strACCTNO:=pv_Afacctno;
    end;
    -- lay ra so tk BloomBerg
    Begin
    select blacctno into v_blacctno
    from bl_register where afacctno=pv_Afacctno;
     Exception when others then
       v_blacctno:='';
    end;
   --Lay CODEID theo SYMBOL
      SELECT CODEID,tradeplace,sectype
      Into v_strCodeID,v_strtradeplace,v_sectype
      FROM Sbsecurities where symbol =pv_Symbol;
       --Kiem tra loai hinh co phu hop hay khong

    BEGIN
        -- Lay gia tri loai hinh lenh
        v_strACTYPE := fopks_api.fn_GetODACTYPE(v_strACCTNO, pv_Symbol, v_strCodeID, v_strtradeplace, pv_Exectype,
                                    pv_PriceType, v_strTimeType, v_strAFACTYPE, v_sectype, v_strVIA);
    Exception when others then
        plog.error(pkgctx,' pr_bl_mainPlaceOrder.SP_FOCOREPLACEORDER Get ACTYPE '||sqlerrm);
    END;
    -- neu la dat lenh tong
    if (pv_functionName='BLBMAINPLACEORDER') then
              -- Check so du tien/ CK truoc khi day lenh
          if (v_CustAtCom='Y') then
              IF pv_Exectype = 'NB' THEN
                  SELECT ot.deffeerate
                  INTO v_deffeerate
                  FROM odtype ot WHERE actype = v_strACTYPE;
                  IF pv_PriceType IN ('ATO','ATC') THEN
                      SELECT s.ceilingprice
                      INTO v_CeilingPrice
                      FROM securities_info s WHERE s.symbol = pv_Symbol;
                      v_dblPRICE := v_CeilingPrice/1000;
                  END IF;
                  -- Lay suc mua hien tai
                  v_ppse := fn_getppse(v_strACCTNO, pv_Symbol, v_dblPRICE, 'O');
                 -- plog.error (pkgctx,'pr_bl_mainPlaceOrder: ' || v_ppse);
                  -- Kiem tra voi gia tri dat lenh
                  plog.error(pkgctx,'dat lenh tong'||v_deffeerate ||','|| v_dblPRICE || ','|| v_dblQUANTITY);
                  IF v_ppse < CEIL((1+v_deffeerate/100) * v_dblPRICE * v_dblQUANTITY * 1000) THEN
                       p_err_code:=-400116;
                       p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                       v_strFEEDBACKMSG:=p_err_message;
                       plog.error(pkgctx, 'Error:'  || p_err_message);
                       plog.setendsection(pkgctx, 'pr_placeorder');
                       return;
                  end if;
              ELSIF pv_Exectype = 'NS' THEN
                  l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(pv_Afacctno || v_strCodeID,'SEMAST','ACCTNO');
                  v_SeTrade := l_SEMASTcheck_arr(0).TRADE;
                  -- Kiem tra voi so CK dat
                  IF v_SeTrade < v_dblQUANTITY THEN
                       p_err_code:=-900017;
                       p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                       v_strFEEDBACKMSG:=p_err_message;
                       plog.error(pkgctx, 'Error:'  || p_err_message);
                       plog.setendsection(pkgctx, 'pr_placeorder');
                       return;
                  END IF;
              END IF;
          end if;

          -- Ghi nhan vao bang lenh Bloomberg
          Select blorderid_seq.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
          v_BLORDERID:= to_char(v_DTCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');
          v_strFEEDBACKMSG := 'Order is received and pending to process';

          INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                                  PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                                  CANCELQTTY,AMENDQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                                  TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                                  PRETLID,ASSIGNTIME,EXECTIME,FOREFID,BLINSTRUCTION,LAST_CHANGE,ORGQUANTITY,ORGPRICE,ROOTORDERID)
          VALUES (bl_odmast_seq.NEXTVAL,v_BLORDERID,v_blacctno,pv_Afacctno,pv_Custodycd,v_traderid,v_BLODSTATUS,v_HandlInst,pv_ExecType,
                  pv_PriceType,v_strTimeType,v_strCodeID,pv_Symbol,v_dblQUANTITY,v_dblPRICE,0,0,v_dblquantity,
                  0,0,'',v_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_dtCURRDATE,
                  '',v_dtCURRDATE,v_dtCURRDATE,v_strVIA,'N',v_Username, 'N', pv_Tlid,pv_Tlid,'',SYSTIMESTAMP,'','','',SYSTIMESTAMP,v_dblquantity,v_dblprice,v_BLORDERID);
    elsif (pv_functionName='BLBMAINCANCELORDER') then -- huy lenh tong
    -- Huy lenh tong: tham so thu 2 truyen vao la blorderid cua lenh can huy
          v_BLORDERID:=pv_CustodyCd;
          select autoid,retlid into v_blAutoid,v_CurrRetlid from bl_odmast where blorderid=v_BLORDERID;
          if nvl(v_CurrRetlid,'a') <> pv_Tlid then
                       p_err_code:=-700124;
                       p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                       v_strFEEDBACKMSG:=p_err_message;
                       plog.error(pkgctx, 'Error:'  || p_err_message);
                       plog.setendsection(pkgctx, 'pr_placeorder');
                       return;
          end if;
          -- goi ham huy lenh BloomBerg
          BL_MNGReject(v_blAutoid,pv_Tlid,p_err_code);
    end if;
    if p_err_message is null then
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    end if;

    plog.setendsection(pkgctx, 'pr_bl_mainPlaceOrder');

Exception when others then
        plog.error(pkgctx,' pr_bl_mainPlaceOrder '||sqlerrm);
        p_err_code:=-1;
        plog.setendsection(pkgctx, 'pr_bl_mainPlaceOrder');
End;

/*
PROCEDURE SP_FOCORECANCELORDER_BL (
    pv_ORDERID in VARCHAR2,
    pv_ClOrdID  in VARCHAR2,
    pv_USERNAME in VARCHAR2,
    pv_PASSWORD in VARCHAR2,
    pv_msgseqnum in varchar2
  ) IS
  V_ERRCODE INTEGER;
  v_strError varchar2(200);
  v_check boolean;
  v_exp Exception;
  v_Count Number(20);
  v_Symbol varchar2(100);
  v_OrderID varchar2(100);
  v_ClOrdID varchar2(100);
  v_exectype  varchar2(100);
  v_custodycd   varchar2(10);
  v_traderid    varchar2(50);
  v_tradeplace  varchar2(10);
BEGIN
    V_ERRCODE:=0;
    plog.debug(pkgctx,'SP_FOCORECANCELORDER_BL '
                                                          ||' ORDERID '||pv_ORDERID
                                                          ||'  msgseqnum '||pv_msgseqnum
                      );
    If fopks_api.fn_is_ho_active =false then
      v_check:= False;
      v_strError:='Exchange Closed';
      Raise v_exp;
    End if;


    --Check co lenh tren san.
    Begin
      Select f.ORGACCTNO , f.exectype, cf.custodycd, f.traderid
      into v_OrderID ,v_exectype, v_custodycd, v_traderid
      from fomast f, bl_msgseqnum_map m, cfmast cf, afmast af
      Where f.forefid = m.clordid
        AND cf.custid = af.custid AND af.acctno = f.afacctno
        And m.ClOrdID =pv_ORDERID;

      If v_exectype in ('AS','AB') Then --Neu yeu cau huy cua lenh da sua thi tim lenh goc.

        Select orderid Into v_OrderID
        from odmast where reforderid in (select reforderid from odmast
                                          where exectype in ('AS','AB')
                                          and orderid =v_OrderID
                                          ) and exectype not in ('AS','AB');
      End if;

    Exception When Others then
          v_check:= False;
          v_strError:='Unknown Order';
          Raise v_exp;
    End;
    -- Neu lenh HOSE thi check xem co chia lenh hay ko
    -- Neu chia lenh thi huy tung lenh
    SELECT sb.tradeplace
    INTO v_tradeplace
    FROM odmast od, sbsecurities SB
    WHERE od.codeid = sb.codeid AND od.orderid = v_OrderID;

    IF v_tradeplace = '001' THEN
        FOR rec IN
        (
            SELECT od.orderid
            FROM odmast od, fomast fo
            WHERE od.foacctno = fo.acctno AND od.remainqtty > 0 AND od.orstatus IN ('8','4','2')
                AND fo.forefid = pv_ORDERID
        )
        LOOP
            PRC_CANCELORDER_BL(v_custodycd, rec.orderid,pv_ClOrdID,pv_USERNAME,pv_PASSWORD,pv_msgseqnum,v_traderid);
        END LOOP;
    ELSE
        PRC_CANCELORDER_BL(v_custodycd, v_OrderID,pv_ClOrdID,pv_USERNAME,pv_PASSWORD,pv_msgseqnum,v_traderid);
    END IF;

EXCEPTION WHEN v_exp THEN
  --Tra ve msg Reject tuong ung
/*
  INSERT INTO bl_reject (id,
                           msgtype,
                           refseqnum,
                           reftagid,
                           refmsgtype,
                           sessionrejectreason,
                           text,
                           encodedtextlen,
                           encodedtext,
                           process)
      VALUES   (bl_reject_seq.nextval,
                '3',
                msgseqnum,
                '',
                'D',
                '',
                v_strError,
                '',
                '',
                'N');

*/

/*
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
                                      traderid)
             Select     '9' Msgtype,
                    pv_ClOrdID orderid,
                    ' ' secondaryorderid,
                    pv_ClOrdID clordid,
                    ' ' origclordid,
                    ' ' ordstatus,
                    ' ' clientid,
                    ' ' execbroker,
                    ' ' listid,
                    ' ' account,
                    ' ' transacttime,
                    ' ' cxlrejresponseto,
                    ' ' cxlrejreason,
                    v_strError text,
                    ' ' encodedtextlen,
                    ' ' encodedtext,
                    'N',
                    v_traderid
                  FROM   DUAL;


     Commit;
END;

*/

PROCEDURE SP_FOCORECANCELORDER_BL (
    pv_ORDERID in VARCHAR2,
    pv_ClOrdID  in VARCHAR2,
    pv_USERNAME in VARCHAR2,
    pv_PASSWORD in VARCHAR2,
    pv_msgseqnum in varchar2
  ) IS
  V_ERRCODE INTEGER;
  v_strError varchar2(200);
  v_check boolean;
  v_exp Exception;
  v_Count Number(20);
  v_Symbol varchar2(100);
  v_OrderID varchar2(100);
  v_ClOrdID varchar2(100);
  v_exectype  varchar2(100);
  v_custodycd   varchar2(10);
  v_traderid    varchar2(50);
  v_tradeplace  varchar2(10);
  v_blorderid   varchar2(20);
  v_blodtype    varchar2(5);
  v_blstatus    varchar2(5);
  v_BL_OdmastSEQ    varchar2(50);
  v_Cancel_orderid  varchar2(20);
  v_strCURRDATE  DATE;
  v_blautoid    varchar2(50);
  v_pricetype   varchar2(10);
  l_hnxTRADINGID        varchar2(20);
  v_securitytradingSTS varchar2(3);
  v_strMarketStatus varchar2(10);
  v_EDStatus        varchar2(10);
  v_HOSession       varchar2(10);

BEGIN
    V_ERRCODE:=0;
    plog.error(pkgctx,'SP_FOCORECANCELORDER_BL '
                                                          ||' ORDERID '||pv_ORDERID
                                                          ||'  pv_ClOrdID '||pv_ClOrdID
                      );
    If fopks_api.fn_is_ho_active =false then
      v_check:= False;
      v_strError:='Exchange Closed';
      Raise v_exp;
    End if;


    --Check co lenh tren san.
    Begin
      /*Select f.ORGACCTNO , f.exectype, cf.custodycd, f.traderid
      into v_OrderID ,v_exectype, v_custodycd, v_traderid
      from fomast f, bl_msgseqnum_map m, cfmast cf, afmast af
      Where f.forefid = m.clordid
        AND cf.custid = af.custid AND af.acctno = f.afacctno
        And m.ClOrdID =pv_ORDERID;*/
        v_Count:= 0;
        Select count(bl.blorderid)
        into v_count
        from bl_odmast bl
        Where bl.forefid = pv_ORDERID;

        IF v_Count =0 THEN
            v_check:= False;
            v_strError:='Unknown Order';
            Raise v_exp;
        END IF;

      /*If v_exectype in ('AS','AB') Then --Neu yeu cau huy cua lenh da sua thi tim lenh goc.

        Select orderid Into v_OrderID
        from odmast where reforderid in (select reforderid from odmast
                                          where exectype in ('AS','AB')
                                          and orderid =v_OrderID
                                          ) and exectype not in ('AS','AB');
      End if;*/

    Exception When Others then
          v_check:= False;
          v_strError:='Unknown Order';
          Raise v_exp;
    End;

    -- Lay thong tin lenh goc
    begin
        SELECT bl.blorderid, bl.blodtype, bl.status, bl.autoid, bl.traderid, sb.tradeplace, bl.custodycd, bl.pricetype, bl.edstatus
        INTO v_blorderid, v_blodtype, v_blstatus, v_blautoid, v_traderid, v_tradeplace, v_custodycd, v_pricetype, v_EDStatus
        FROM bl_odmast bl, sbsecurities sb
        WHERE bl.codeid = sb.codeid and bl.forefid = pv_ORDERID AND bl.status NOT IN ('N');
    Exception When Others THEN
        v_check:= False;
        v_strError:='Unknown Order';
        Raise v_exp;
    END;

    IF v_EDStatus IN ('A','C') THEN
        v_check:= False;
        v_strError:='This Order is in cancel or amendment progress!';
        Raise v_exp;
    END IF;

    IF v_blstatus IN ('C','R') THEN
        v_check:= False;
        v_strError:='This Order was cancelled!';
        Raise v_exp;
    END IF;

    --
    -- Kiem tra lenh phai phu hop voi phien dat lenh

    If /*v_pricetype IN ('ATO','ATC') AND */v_tradeplace = '001' THEN
        select sysvalue into v_strMarketStatus  from ordersys where sysname='CONTROLCODE';
            If v_strMarketStatus = 'A' THEN
                IF v_pricetype = 'ATC' then
                    v_check :=FALSE;
                    v_strError := v_pricetype || ' order is not allowed to cancel in this session of stock exchange';
                    Raise v_exp;
                ELSIF v_pricetype = 'LO' THEN
                    -- Lay thong tin phien day lenh
                    SELECT min(hosesession)
                    INTO v_HOSession
                    FROM odmast od
                    WHERE od.remainqtty > 0 AND od.orstatus IN ('8','4','2') AND od.blorderid = v_blorderid;
                    IF v_HOSession = 'A' THEN
                        v_check :=FALSE;
                        v_strError := 'This order is not allowed to cancel in this session of stock exchange';
                        Raise v_exp;
                    END IF;
                End If;
            END IF;
          If v_strMarketStatus = 'P' then --and v_pricetype = 'ATO' Then
            v_check :=FALSE;
            v_strError := v_pricetype || ' order is not allowed to cancel in this session of stock exchange';
            Raise v_exp;
          End If;
      End If;

    IF   v_tradeplace = '002' THEN
        SELECT sysvalue
        INTO l_hnxTRADINGID
        FROM ordersys_ha
        WHERE sysname = 'TRADINGID';

        IF  l_hnxTRADINGID IN ('CLOSE_BL')THEN
            v_check :=FALSE;
            v_strError := v_pricetype || ' order is not allowed to cancel in this session of stock exchange';
            Raise v_exp;
        END IF;
    END IF;

    /*plog.error(pkgctx,'SP_FOCORECANCELORDER_BL '
                                                          ||' v_blodtype '||v_blodtype
                                                          ||'  v_blstatus '||v_blstatus
                      );*/
    -- Ghi nhan vao BL_ODMAST
   /* v_strCURRDATE := getcurrdate;
    Select seq_blorderid.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
    v_Cancel_orderid := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');*/

    /*INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                            PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                            CANCELQTTY,AMENDQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                            TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                            PRETLID,ASSIGNTIME,EXECTIME,FOREFID,REFFOREFID,ORGQUANTITY,ORGPRICE,ROOTORDERID)
    SELECT seq_bl_odmast.NEXTVAL, v_Cancel_orderid,bl.BLACCTNO,bl.AFACCTNO,bl.CUSTODYCD,bl.TRADERID,'P' STATUS,bl.BLODTYPE,CASE WHEN bl.exectype = 'NB' THEN 'CB' WHEN bl.exectype = 'NS' THEN 'CS' ELSE 'CC' END EXECTYPE,
                            bl.PRICETYPE,bl.TIMETYPE,bl.CODEID,bl.SYMBOL,bl.QUANTITY,bl.PRICE,bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,
                            bl.CANCELQTTY,bl.AMENDQTTY,bl.blorderid REFBLORDERID,'Received cancel request' FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_strCURRDATE,
                            '' TXNUM,v_strCURRDATE,v_strCURRDATE,bl.VIA,'N' DELTD,pv_USERNAME,bl.DIRECT,bl.TLID,bl.RETLID,
                            PRETLID,'' ASSIGNTIME,'' EXECTIME,pv_ClOrdID FOREFID,pv_ORDERID REFFOREFID,bl.ORGQUANTITY,bl.ORGPRICE,bl.ROOTORDERID
    FROM bl_odmast bl
    WHERE bl.blorderid = v_blorderid;*/

    -- Ghi nhan vao bang chi tiet sua lenh BL_ODMASTDTL
    -- Lay thong tin gia lenh goc

    INSERT INTO bl_odmastdtl (AUTOID,ROOTORDERID,BLORDERID,ADORDERID,FOREFID,STATUS,EXECTYPE,VIA,CODEID,SYMBOL,
                            CURQUANTITY,CURPRICE,ORGQUANTITY,ORGPRICE,NEWQUANTITY,NEWPRICE,
                            EXECQTTY,EXECAMT,REMAINQTTY,CANCELQTTY,AMENDQTTY,
                            FEEDBACKMSG,DELTD,USERNAME,DIRECT,TLID,
                            CREATEDDT,ORDERTIME)
    SELECT BL_ODMASTDTL_seq.NEXTVAL, bl.rootorderid,bl.blorderid, bl.blorderid,pv_ClOrdID FOREFID,'N' STATUS,CASE WHEN bl.exectype = 'NB' THEN 'CB' WHEN bl.exectype = 'NS' THEN 'CS' ELSE 'CC' END EXECTYPE,bl.VIA,bl.CODEID,bl.SYMBOL,
                            bl.quantity,bl.price,bl.ORGQUANTITY,bl.ORGPRICE, bl.quantity,bl.price,
                            bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,bl.CANCELQTTY,bl.AMENDQTTY,
                            'Received cancel request' FEEDBACKMSG,'N' DELTD,nvl(pv_USERNAME,'BL'),bl.DIRECT,bl.TLID,
                            TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),SYSTIMESTAMP ORDERTIME
    FROM bl_odmast bl
    WHERE bl.blorderid = v_blorderid;

    /*plog.error(pkgctx,'SP_FOCORECANCELORDER_BL '
                                                          ||' v_Cancel_orderid '||v_Cancel_orderid);
*/


    -- Neu lenh truc tiep thi goi ham huy nhu luong cu
    -- Neu lenh gian tiep thi goi ham huy lenh tong
    IF v_blodtype = '1' OR v_PriceType IN ('ATO','ATC','MP','MOK','MAK','MTL') THEN
        if  v_blstatus IN ('A','F','M') then
            -- Neu lenh HOSE thi check xem co chia lenh hay ko
            -- Neu chia lenh thi huy tung lenh
            /*SELECT sb.tradeplace
            INTO v_tradeplace
            FROM odmast od, sbsecurities SB
            WHERE od.codeid = sb.codeid AND od.orderid = v_OrderID;*/

            IF v_tradeplace = '001' THEN
                FOR rec IN
                (
                    SELECT od.orderid
                    FROM odmast od, fomast fo
                    WHERE od.foacctno = fo.acctno AND od.remainqtty > 0 AND od.orstatus IN ('8','4','2')
                        AND fo.forefid = pv_ORDERID
                )
                LOOP
                    PRC_CANCELORDER_BL(v_custodycd, rec.orderid,pv_ClOrdID,pv_USERNAME,pv_PASSWORD,pv_msgseqnum,v_traderid,v_blorderid);
                END LOOP;
            ELSE
                -- Tim so hieu lenh goc
                Select f.ORGACCTNO , f.exectype
                into v_OrderID ,v_exectype
                from fomast f
                Where f.forefid = pv_ORDERID;
                If v_exectype in ('AS','AB') Then --Neu yeu cau huy cua lenh da sua thi tim lenh goc.
                    Select orderid Into v_OrderID
                    from odmast where reforderid in (select reforderid from odmast
                                                      where exectype in ('AS','AB')
                                                      and orderid =v_OrderID
                                                      ) and exectype not in ('AS','AB');
                  End if;
                PRC_CANCELORDER_BL(v_custodycd, v_OrderID,pv_ClOrdID,pv_USERNAME,pv_PASSWORD,pv_msgseqnum,v_traderid,v_blorderid);
            END IF;
        ELSIF v_blstatus IN ('P','T') THEN
            -- Neu lenh truc tiep 1 xu ly day lenh thi huy luon
            UPDATE bl_odmast SET
                pstatus = pstatus || status,
                status = 'C',
                cancelqtty = cancelqtty + remainqtty,
                remainqtty = 0,
                last_change = SYSTIMESTAMP
            WHERE blorderid = v_blorderid;

            UPDATE bl_odmastdtl SET
                pstatus = pstatus || status,
                status = 'C',
                last_change = SYSTIMESTAMP
            WHERE blorderid = v_blorderid AND exectype IN ('CB','CS');
        end if;

    ELSIF v_blodtype IN ('2','3') AND v_blstatus IN ('A','F') THEN
        -- Lenh gian tiep da day vao san thi goi ham huy lenh tong
        BL_MNGReject (
           pv_strreject   => v_blautoid,
           pv_tlid        => '6868',
           pv_err_code    => V_ERRCODE
        );
    ELSIF v_blodtype IN ('2','3') AND v_blstatus IN ('P','T') THEN
        -- Lenh gian tiep chua day vao san thi huy luon
        UPDATE bl_odmast SET
            pstatus = pstatus || status,
            status = 'C',
            cancelqtty = cancelqtty + remainqtty,
            remainqtty = 0,
            last_change = SYSTIMESTAMP
        WHERE blorderid = v_blorderid;

        UPDATE bl_odmastdtl SET
            pstatus = pstatus || status,
            status = 'C',
            last_change = SYSTIMESTAMP
        WHERE blorderid = v_blorderid AND exectype IN ('CB','CS');
    END IF;

EXCEPTION WHEN v_exp THEN
  --Tra ve msg Reject tuong ung
/*
  INSERT INTO bl_reject (id,
                           msgtype,
                           refseqnum,
                           reftagid,
                           refmsgtype,
                           sessionrejectreason,
                           text,
                           encodedtextlen,
                           encodedtext,
                           process)
      VALUES   (bl_reject_seq.nextval,
                '3',
                msgseqnum,
                '',
                'D',
                '',
                v_strError,
                '',
                '',
                'N');

*/
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
                    pv_ORDERID orderid,
                    ' ' secondaryorderid,
                    pv_ClOrdID clordid,
                    ' ' origclordid,
                    ' ' ordstatus,
                    ' ' clientid,
                    ' ' execbroker,
                    ' ' listid,
                    ' ' account,
                    ' ' transacttime,
                    ' ' cxlrejresponseto,
                    ' ' cxlrejreason,
                    v_strError text,
                    ' ' encodedtextlen,
                    ' ' encodedtext,
                    'N',
                    v_traderid,
                    BL_ODREJECT_seq.nextval
                  FROM   DUAL;


     Commit;
END;


PROCEDURE PRC_CANCELORDER_BL(
        pv_Afacctno IN varchar2,
        pv_OrderID IN varchar2,
        pv_ClOrdID  in VARCHAR2,
        pv_Username IN varchar2,
        pv_Password IN varchar2,
        pv_msgseqnum in VARCHAR2,
        pv_traderid IN  VARCHAR2,
        pv_OrgBlorderid IN  varchar2
    )

Is
 v_strSTATUS Varchar2(10);
 v_strFEEDBACKMSG Varchar2(200);
 v_blnOK Boolean;
 v_BatchSEQ varchar2(20);
 v_strORDERID varchar2(20);
 v_strVIA VARCHAR2(10):='L';
 v_strCURRDATE DATE;
 v_strTimeType varchar2(20);
 v_strCUSTODYCD varchar2(10);
 v_strACCTNO varchar2(10);
 v_msgseqnum varchar2(30);
BEGIN


 v_strCUSTODYCD := pv_Afacctno;
 BEGIN
    select af.acctno into v_strACCTNO
        from afmast af, cfmast cf where af.custid = cf.custid and cf.custodycd = v_strCUSTODYCD;
 EXCEPTION WHEN OTHERS THEN
    v_strACCTNO := v_strCUSTODYCD;
 END;
 plog.error(pkgctx,'SP_FOCORECANCELORDER_BL v_strACCTNO '||v_strACCTNO ||' v_OrderID '||pv_OrderID );
      --Lay ngay hien tai:
 SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strCURRDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

  BEGIN
      SELECT STATUS, TIMETYPE Into v_strSTATUS,v_strTimeType FROM FOMAST WHERE ORGACCTNO= pv_OrderID  AND EXECTYPE IN ('NB','NS');
  Exception When Others then
      plog.debug(pkgctx,'SP_FOCORECANCELORDER_BL Get STATUS lenh khong trong he thong');
      --LENH o trong he thong
      v_blnOK := True;
  END;

  --Lenh chua duoc huy lan nao
  --Kiem tra trang thai cua lenh, Neu la P thi xoa luon

  If v_strSTATUS = 'P' Then
      v_strFEEDBACKMSG := 'Order is cancelled when processing';
      UPDATE FOMAST SET STATUS='R',FEEDBACKMSG= v_strFEEDBACKMSG WHERE BOOK ='A' AND ACCTNO= pv_OrderID AND STATUS='P';
/*
      If v_strTimeType <> 'G' Then
         UPDATE FOMAST SET STATUS='R',FEEDBACKMSG= v_strFEEDBACKMSG WHERE BOOK ='A' AND ACCTNO= v_OrderID AND STATUS='P';
      Else
         UPDATE FOMAST SET STATUS='R',FEEDBACKMSG= v_strFEEDBACKMSG, DELTD ='Y' WHERE BOOK ='A' AND ACCTNO= v_OrderID AND STATUS='P';
      End if;
*/
  ElsIf v_strSTATUS = 'A' Then
      --Neu la A tuc la lenh da day vao he thong thi sinh lenh huy
      v_blnOK := True;
  Else
      v_strFEEDBACKMSG := 'Order can not be cancelled';
  End If;


  If v_blnOK Then

     Select SEQ_FOMAST.NEXTVAL Into v_BatchSEQ from DUAL;

     v_strORDERID:=to_char(v_strCURRDATE,'dd/mm/yyyy')||LPAD(v_BatchSEQ,10,'0');

     v_strFEEDBACKMSG := 'Cancel request is received and pending to process';
     INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                         TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                         CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY,
                         QUANTITY, PRICE,
                         QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
                         REFACCTNO,  REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,
                         EFFDATE,EXPDATE,USERNAME,forefid,DIRECT,TLID,TRADERID)

     SELECT  v_strORDERID , od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
       (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR od.EXECTYPE='AB' THEN 'CB' ELSE 'CS' END) CANCEL_EXECTYPE,od.PRICETYPE,
       od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
       'O' CONFIRMEDVIA, 'A' BOOK,  v_strFEEDBACKMSG , TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
       od.CLEARDAY,od.exqtty QUANTITY,(od.exprice/1000) PRICE,
      (od.QUOTEPRICE/1000) QUOTEPRICE, 0 TRIGGERPRICE, od.EXECQTTY, od.EXECAMT,
       od.REMAINQTTY, od.orderid REFACCTNO, 0 REFQUANTITY, 0 REFPRICE, (od.QUOTEPRICE/1000) REFQUOTEPRICE, v_strVIA  VIA,
       TO_DATE( v_strCURRDATE ,'DD/MM/RRRR') EFFDATE,TO_DATE( v_strCURRDATE ,'DD/MM/RRRR')  EXPDATE, pv_USERNAME  USERNAME ,
       pv_ClOrdID,'N' DIRECT, '6868' TLID,pv_traderid
   FROM ODMAST od, sbsecurities sb
   WHERE orstatus IN ('1','2','4','8') AND orderid=pv_OrderID and sb.codeid = od.codeid
   and orderid not in (select REFACCTNO from fomast WHERE EXECTYPE IN ('CB','CS') AND STATUS <>'R');

   -- Cap nhat lai FOACCTNO trong DTL
    UPDATE bl_odmastdtl SET
        foacctno = v_strORDERID,
        last_change = SYSTIMESTAMP
    WHERE blorderid = pv_OrgBlorderid AND exectype IN ('CB','CS');

    -- Cap nhat trang thai dang huy
    UPDATE bl_odmast SET
        edstatus = 'C',
        last_change = SYSTIMESTAMP
    WHERE blorderid = pv_OrgBlorderid;

    --insert msgseqnum
    v_msgseqnum := pv_msgseqnum;
    plog.debug(pkgctx,'v_msgseqnum-->'||v_msgseqnum);
    Insert into bl_msgseqnum_map(msgseqnum,acctno) values(v_msgseqnum,v_strORDERID);
 End If;
END;

PROCEDURE SP_FOCOREMODIFYORDER_BL (
    pv_ORDERID in VARCHAR2,
    pv_ClOrdID  in VARCHAR2,
    pv_PRICE  in VARCHAR2,
    pv_OrderQty in VARCHAR2,
    pv_timeinforce in VARCHAR2,
    pv_USERNAME in VARCHAR2,
    pv_PASSWORD in VARCHAR2,
    pv_msgseqnum in varchar2
  ) IS
    V_ERRCODE INTEGER;
    v_strError varchar2(200);
    v_check boolean;
    v_exp Exception;
    v_Count Number(20);
    v_Symbol varchar2(100);
    v_OrderID varchar2(100);
    v_CodeID varchar2(100);
    v_ClOrdID varchar2(100);
    v_quantity  Number(20);
    v_exectype  varchar2(100);
    v_FromPrice Number(20,4);
    v_ToPrice Number(20,4);
    l_count  Number(20,4);
    l_dblTickSize Number(20,4);
    v_custodycd   varchar2(10);
    v_OrderStatus varchar2(2);
    v_traderid    varchar2(50);
    v_tradeplace  varchar2(10);
    v_pricetype   varchar2(10);
    v_timetype    varchar2(10);
    v_blodtype    varchar2(2);
    v_BL_OdmastSEQ    varchar2(50);
    v_Amend_orderid  varchar2(20);
    v_strCURRDATE  DATE;
    v_blorderid   varchar2(50);
    v_BLExecqtty   number;
    v_ODExecqtty   number;
    v_AmendQtty    number;
    v_EDStatus      varchar2(10);
    l_hnxTRADINGID  varchar2(20);
    L_MaxHNXQtty    number;
    l_oodstatus   varchar2(10);

BEGIN
    V_ERRCODE:=0;

    plog.debug(pkgctx,'SP_FOCOREMODIFYORDER_BL v_Afacctno '
                                                          ||' ORDERID '||pv_ORDERID
                                                          ||' ClOrdID '||pv_ClOrdID
                                                          ||' PRICE '||pv_PRICE
                                                          ||' OrderQty '||pv_OrderQty
                                                          ||'  msgseqnum '||pv_msgseqnum
                      );

    If fopks_api.fn_is_ho_active =false then
      v_check:= False;
      v_strError:='Exchange Closed';
      Raise v_exp;
    End if;

    -- Kiem tra chi cho phep sua lenh direct
    begin
        select max(bl.blodtype), max(bl.traderid)
        INTO v_blodtype, v_traderid
        FROM bl_odmast bl
        WHERE bl.forefid = pv_ORDERID;
        plog.error(pkgctx,'SP_FOCOREMODIFYORDER_BL v_blodtype '|| v_blodtype);
    Exception When Others then
        v_check:= False;
        v_strError:='Can not amend this order!';
        Raise v_exp;
    end;

    IF v_blodtype <> '1' then
        v_check:= False;
        v_strError:='Can not amend order with Hander Instruction is ' || CASE WHEN v_blodtype= '2' THEN 'ANY' WHEN v_blodtype = '3' THEN 'MANUAL' END;
        Raise v_exp;
    END IF;

    --Check co lenh tren san.
    Begin
        /*Select f.ORGACCTNO ,m.quantity, f.exectype , f.codeid, cf.custodycd, f.traderid, sb.tradeplace,f.pricetype, f.timetype, m.blorderid
        into v_OrderID,v_quantity, v_exectype , v_CodeID, v_custodycd, v_traderid, v_tradeplace, v_pricetype, v_timetype, v_blorderid
        from fomast f, bl_odmast m, cfmast cf, afmast af, sbsecurities sb
        Where f.forefid = m.forefid
            AND cf.custid = af.custid AND af.acctno = f.afacctno
            AND f.codeid = sb.codeid
            And m.forefid =pv_ORDERID
            and m.exectype in ('NB','NS') and m.status not in ('C','R');*/


            Select f.orderid ,m.quantity, m.exectype , m.codeid, cf.custodycd, m.traderid, sb.tradeplace,m.pricetype, m.timetype, m.blorderid, f.edstatus,
                od.oodstatus
            into v_OrderID,v_quantity, v_exectype , v_CodeID, v_custodycd, v_traderid, v_tradeplace, v_pricetype, v_timetype, v_blorderid, v_EDStatus, l_oodstatus
            from odmast f, bl_odmast m, cfmast cf, afmast af, sbsecurities sb, ood od
            Where f.blorderid = m.blorderid
                and f.orderid = od.orgorderid
                AND cf.custid = af.custid AND af.acctno = m.afacctno
                AND m.codeid = sb.codeid
                And m.forefid = pv_ORDERID
                and m.exectype in ('NB','NS') and m.status not in ('C','R')
                AND f.orstatus IN ('2','4') AND f.exectype IN ('NB','NS') AND f.remainqtty >0;


      If v_exectype in ('AS','AB') Then --Neu yeu cau sua cua lenh da sua thi tim lenh goc.
        Select orderid  Into v_OrderID
        from odmast where reforderid in (select reforderid from odmast
                                          where exectype in ('AS','AB')
                                          and orderid =v_OrderID
                                          ) and exectype not in ('AS','AB');
      End if;
    Exception When Others then
          v_check:= False;
          v_strError:='Order is sending to exchange, can not amend!';
          Raise v_exp;
    End;
    -- Lenh dang huy/sua thi ko cho phep sua nua
    BEGIN
        SELECT count(1)
        INTO v_Count
        FROM odmast od
        WHERE od.reforderid = v_OrderID AND od.edstatus IN ('A','C');
    Exception When Others THEN
        plog.error(pkgctx,'SP_FOCOREMODIFYORDER_BL v_OrderID: ' || v_OrderID || ' v_Count '|| v_Count);
          v_check:= False;
          v_strError:='Can not amend this order!!';
          Raise v_exp;
    END;

    IF v_Count > 0 THEN
        v_check:= False;
        v_strError:='This order is in amendment progress!';
        Raise v_exp;
    END IF;

    -- Khong cho sua lenh HO
    If  v_tradeplace = '001' Then
          v_check:= False;
          v_strError:='Security of HOSE stock exchange does not allow amendment!';
          Raise v_exp;
    End if;

    -- Khong cho sua lenh GTC
    If  v_timetype = 'G' Then
          v_check:= False;
          v_strError:='GTC order does not allow amendment!';
          Raise v_exp;
    End if;

    -- Khong cho sua lenh gia ATC, MOK, MAK, MTL
    IF v_pricetype IN ('ATO','ATC','MOK') THEN
        v_check:= False;
        v_strError:= v_pricetype || ' order does not allow amendment!';
        Raise v_exp;
    END IF;

    if v_pricetype in ('MAK','MTL') and l_oodstatus <> 'S' then
        v_check:= False;
        v_strError:= v_pricetype || ' order does not allow amendment!';
        Raise v_exp;
    end if;

    --Neu sua khoi luong thi thong bao ko cho sua.
    /*If  v_quantity <> pv_OrderQty Then
          v_check:= False;
          v_strError:='Order quantity is non-replaceble';
          Raise v_exp;
    End if;*/

    -- Khong cho phep sua loai gia dat lenh
    if v_pricetype not in ('MAK','MTL') then
    IF v_pricetype <> CASE WHEN pv_timeinforce IN ('0','1') THEN 'LO' WHEN pv_timeinforce IN ('7') THEN 'ATC' ELSE 'AA' END THEN
        v_check:= False;
        v_strError:='Time in force does not allow amendment';
        Raise v_exp;
    END IF;
    end if;


    SELECT sysvalue
     INTO l_hnxTRADINGID
     FROM ordersys_ha
     WHERE sysname = 'TRADINGID';
     -- lay ra gia tri max HNX cua 1 lenh
     select to_number(varvalue)
     into L_MaxHNXQtty
     from sysvar
     where varname = 'HNX_MAX_QUANTITY';

     -- Chan huy sua cuoi phien
    IF  l_hnxTRADINGID IN ('CLOSE_BL') AND v_tradeplace in ('002','005') THEN
        v_check:= False;
        v_strError:= v_pricetype || ' order is not allowed to amend in this session of stock exchange!';
        Raise v_exp;
    END IF;

    --chan khong sua lenh HNX lon hon max KL HNX
    IF pv_OrderQty > L_MaxHNXQtty AND v_tradeplace in ( '002','005') THEN
        v_check:= False;
        v_strError:= 'Amendment quantity is larger than max quantity of this exchange!';
        Raise v_exp;
    END IF;

    -- Kiem tra lenh phai gui len san roi moi cho sua
    BEGIN
        SELECT orstatus
        INTO v_OrderStatus
        FROM odmast
        WHERE orderid = v_OrderID;
    Exception When Others then
          v_check:= False;
          v_strError:='Unknown Order';
          Raise v_exp;
    END;
    IF v_OrderStatus IN ('8') THEN
        v_check:= False;
        v_strError:='Order is not sent to exchange. Please cancel this order and order another!';
        Raise v_exp;
    END IF;

    --Kiem tra gia sua phai trong khoang tran san.
    Begin
      Select floorprice, ceilingprice Into v_FromPrice, v_ToPrice
      from securities_info where codeid =v_CodeID;
      If pv_PRICE > v_ToPrice or pv_PRICE < v_FromPrice THEN
          v_check:= False;
          v_strError:=  'Invalid Price';
          Raise v_exp;
      End if;
    Exception When Others Then
          v_check:= False;
          v_strError:=  'Invalid Price';
          Raise v_exp;
    End;

    --Kiem tra gia sua phai thoa man ticksize.

    SELECT count(1) into l_count
    FROM SECURITIES_TICKSIZE WHERE CODEID=v_CodeID  AND STATUS='Y'
            AND TOPRICE>= pv_PRICE AND FROMPRICE<=pv_PRICE;
     if l_count<=0 then
         --Chua dinh nghia TICKSIZE
         v_check:= False;
         v_strError:=  'Ticksize undefined.';
         Raise v_exp;
     else
         SELECT FROMPRICE, TICKSIZE into v_FromPrice,l_dblTickSize
         FROM SECURITIES_TICKSIZE WHERE CODEID=v_CodeID  AND STATUS='Y'
            AND TOPRICE>= pv_PRICE AND FROMPRICE<=pv_PRICE;
         If (pv_PRICE - v_FromPrice) Mod l_dblTickSize <> 0  Then
             v_check:= False;
             v_strError:=  'Ticksize incompliant.';
             Raise v_exp;
         End If;
     end if;

     -- Lay thong tin lenh goc de dat lenh sua vao Flex
    -- Cong thuc: Qtty_A = BLQtty_A - BLExeqtty_A + ExeQtty
    begin
        select od.execqtty
        into v_ODExecqtty
        from odmast od
        where od.orderid = v_OrderID;
    exception when others then
        v_ODExecqtty := 0;
    end;
    begin
        select bl.execqtty
        into v_BLExecqtty
        from bl_odmast bl
        where bl.blorderid = v_blorderid;
    exception when others then
        v_BLExecqtty := 0;
    end;

    v_AmendQtty := pv_OrderQty - v_BLExecqtty + v_ODExecqtty;
    if v_AmendQtty<=0 then
         --Vuot qua SL co the sua
         v_check:= False;
         v_strError:=  'Amend volume request is smaller than filled volume';
         Raise v_exp;
     end if;

      -- Ghi nhan vao BL_ODMAST
    v_strCURRDATE := getcurrdate;
    Select blorderid_seq.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
    v_Amend_orderid := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');

    INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                            PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                            CANCELQTTY,AMENDQTTY,sentqtty,PTBOOKQTTY,PTSENTQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                            TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                            PRETLID,ASSIGNTIME,EXECTIME,FOREFID,REFFOREFID,ORGQUANTITY,ORGPRICE,
                            EDSTATUS,EDEXECTYPE,ROOTORDERID)
    SELECT bl_odmast_seq.NEXTVAL, v_Amend_orderid,bl.BLACCTNO,bl.AFACCTNO,bl.CUSTODYCD,bl.TRADERID,'N' STATUS,bl.BLODTYPE,bl.EXECTYPE,
                            bl.PRICETYPE,bl.TIMETYPE,bl.CODEID,bl.SYMBOL,pv_OrderQty,pv_PRICE/1000,bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,
                            bl.CANCELQTTY,bl.AMENDQTTY,bl.sentqtty,bl.PTBOOKQTTY,bl.PTSENTQTTY,bl.blorderid REFBLORDERID,'Received amend request' FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_strCURRDATE,
                            '' TXNUM,v_strCURRDATE,v_strCURRDATE,bl.VIA,'N' DELTD,pv_USERNAME,bl.DIRECT,bl.TLID,bl.RETLID,
                            PRETLID,'' ASSIGNTIME,'' EXECTIME,pv_ClOrdID FOREFID,pv_ORDERID REFFOREFID,bl.ORGQUANTITY,bl.ORGPRICE,
                            'A' EDSTATUS,CASE WHEN bl.exectype = 'NB' THEN 'AB' WHEN bl.exectype = 'NS' THEN 'AS' ELSE 'AA' END EDEXECTYPE,BL.ROOTORDERID
    FROM bl_odmast bl
    WHERE bl.blorderid = v_blorderid;

    -- Ghi nhan vao bang chi tiet sua lenh BL_ODMASTDTL
    -- Lay thong tin gia lenh goc

    INSERT INTO bl_odmastdtl (AUTOID,ROOTORDERID,BLORDERID,ADORDERID,FOREFID,STATUS,EXECTYPE,VIA,CODEID,SYMBOL,
                            CURQUANTITY,CURPRICE,ORGQUANTITY,ORGPRICE,NEWQUANTITY,NEWPRICE,
                            EXECQTTY,EXECAMT,REMAINQTTY,CANCELQTTY,AMENDQTTY,
                            FEEDBACKMSG,DELTD,USERNAME,DIRECT,TLID,
                            CREATEDDT,ORDERTIME)
    SELECT BL_ODMASTDTL_seq.NEXTVAL, bl.rootorderid,bl.blorderid, v_Amend_orderid,pv_ClOrdID FOREFID,'N' STATUS,CASE WHEN bl.exectype = 'NB' THEN 'AB' WHEN bl.exectype = 'NS' THEN 'AS' ELSE 'AA' END EXECTYPE,bl.VIA,bl.CODEID,bl.SYMBOL,
                            bl.quantity,bl.price,bl.ORGQUANTITY,bl.ORGPRICE, pv_OrderQty,pv_PRICE/1000,
                            bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,bl.CANCELQTTY,bl.AMENDQTTY,
                            'Received amend request' FEEDBACKMSG,'N' DELTD,pv_USERNAME,bl.DIRECT,bl.TLID,
                            TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),SYSTIMESTAMP ORDERTIME
    FROM bl_odmast bl
    WHERE bl.blorderid = v_blorderid;

    -- Cap nhat trang thai lenh goc la dang sua
    UPDATE bl_odmast SET
        edstatus = 'A',
        last_change = SYSTIMESTAMP
    WHERE blorderid = v_blorderid;

    PRC_FOCOREAMENDORDER_BL(v_custodycd, v_OrderID,pv_ClOrdID,pv_PRICE, v_AmendQtty,
                            nvl(pv_USERNAME,'BL'),pv_PASSWORD,pv_Orderid,pv_msgseqnum,v_traderid,v_Amend_orderid, v_blorderid);

EXCEPTION WHEN v_exp THEN
  --Tra ve msg Reject tuong ung

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
                    pv_Orderid orderid,
                    ' ' secondaryorderid,
                    pv_ClOrdID clordid,
                    ' ' origclordid,
                    ' ' ordstatus,
                    ' ' clientid,
                    ' ' execbroker,
                    ' ' listid,
                    ' ' account,
                    ' ' transacttime,
                    ' ' cxlrejresponseto,
                    ' ' cxlrejreason,
                    v_strError text,
                    ' ' encodedtextlen,
                    ' ' encodedtext,
                    'N',
                    v_traderid,
                    bl_odreject_seq.NEXTVAL
                  FROM   DUAL;

     Commit;
END;

PROCEDURE PRC_FOCOREAMENDORDER_BL(
        pv_Afacctno IN varchar2,
        pv_OrgOrderID IN varchar2 ,
        pv_ClOrdID  in VARCHAR2,
        pv_Price IN Varchar2,
        pv_Quantity IN  VARCHAR2,
        pv_Username IN varchar2,
        pv_Password IN varchar2,
        pv_BLOrgOrderid IN varchar2,
        pv_msgseqnum in VARCHAR2,
        pv_traderid IN  VARCHAR2,
        pv_adblorderid  IN  VARCHAR2,
        pv_OrgBLOrderid IN  varchar2
    )
IS


v_strSTATUS Varchar2(10);
 v_strFEEDBACKMSG Varchar2(200);
 v_blnOK Boolean;
 v_BatchSEQ varchar2(20);
 v_strORDERID varchar2(20);
 v_strVIA VARCHAR2(10):='L';
 v_strCURRDATE DATE;
 v_dblQUANTITY Number(20);
 v_dblQUOTEPRICE  Number(20,2);
 v_dblPRICE   Number(20,2);
 v_strCUSTODYCD varchar2(10);
 v_strACCTNO varchar2(10);
 v_msgseqnum varchar2(30);
 v_ExecAmt_org Number(20,2);
 v_ExecQtty_org Number(20,2);
 v_ExecAmt  Number(20,2);
 v_ExecQtty Number(20,2);
 v_Orderqtty Number(20,2);

BEGIN

 v_strCUSTODYCD := pv_Afacctno;
 BEGIN
    select af.acctno into v_strACCTNO
        from afmast af, cfmast cf where af.custid = cf.custid and cf.custodycd = v_strCUSTODYCD;
 EXCEPTION WHEN OTHERS THEN
    v_strACCTNO := v_strcustodycd;
 END;
 plog.debug(pkgctx,'SP_FOCOREAMENDORDER_BL v_strACCTNO '||v_strACCTNO ||' v_OrderID '||pv_OrgOrderID ||' v_Price '||pv_Price);
      --Lay ngay hien tai:
 SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strCURRDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

 v_dblQUOTEPRICE:=pv_Price/1000;
 v_dblPRICE :=pv_Price/1000;
  BEGIN
      SELECT STATUS Into v_strSTATUS FROM FOMAST WHERE ORGACCTNO= pv_OrgOrderID  AND EXECTYPE IN ('NB','NS');
  Exception When Others then
      plog.error(pkgctx,'SP_FOCOREAMENDORDER_BL Get STATUS lenh khong trong he thong');
      --LENH o trong he thong
      v_blnOK := True;
  END;

  --Lenh chua duoc huy lan nao
  --Kiem tra trang thai cua lenh, Neu la P thi xoa luon

  If v_strSTATUS = 'P' Then
      v_strFEEDBACKMSG := 'Order is Amended when processing';
      UPDATE FOMAST SET PRICE= pv_Price,FEEDBACKMSG= v_strFEEDBACKMSG WHERE BOOK ='A' AND ACCTNO= pv_OrgOrderID AND STATUS='P';

  ElsIf v_strSTATUS = 'A' Then
      --Neu la A tuc la lenh da day vao he thong thi sinh lenh sua
      v_blnOK := True;
  Else
      v_strFEEDBACKMSG := 'Order cant be amended';
  End If;


  If v_blnOK Then

     Select seq_fomast.NEXTVAL Into v_BatchSEQ from DUAL;

     v_strORDERID:=to_char(v_strCURRDATE,'dd/mm/yyyy')||LPAD(v_BatchSEQ,10,'0');

     v_strFEEDBACKMSG := 'Admendment order is received and pending to process';

    INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                         TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                         CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY,
                         QUANTITY, PRICE,
                         QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
                         REFACCTNO,  REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,
                         EFFDATE,EXPDATE,USERNAME,forefid,DIRECT,TLID,TRADERID, blorderid )

              SELECT  v_strORDERID, od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
             (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR EXECTYPE='AB' THEN 'AB' ELSE 'AS' END) CANCEL_EXECTYPE,
             od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
             'O' CONFIRMEDVIA, 'A' BOOK,  v_strFEEDBACKMSG  FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ACTIVATEDT,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') CREATEDDT, od.CLEARDAY,
             pv_Quantity QUANTITY ,  v_dblPRICE, v_dblQUOTEPRICE,0 TRIGGERPRICE, 0 EXECQTTY, 0 EXECAMT, remainqtty  REMAINQTTY,
             od.orderid REFACCTNO, ORDERQTTY REFQUANTITY, QUOTEPRICE REFPRICE, QUOTEPRICE REFQUOTEPRICE,v_strVIA  VIA ,
             TO_DATE( v_strCURRDATE ,'dd/mm/rrrr') EFFDATE,TO_DATE( v_strCURRDATE ,'dd/mm/rrrr') EXPDATE, pv_USERNAME  USERNAME,pv_ClOrdID,
             'N' DIRECT, '6868' TLID, pv_traderid,pv_adblorderid BLORDERID
           FROM ODMAST od, sbsecurities sb
           WHERE orstatus IN ('1','2','4','8') AND orderid= pv_OrgOrderID
           And sb.codeid = od.codeid
           and orderid not in (select REFACCTNO from fomast WHERE EXECTYPE IN ('CB','CS','AB','AS') AND STATUS <>'R' );

           --insert msgseqnum
           v_msgseqnum := pv_msgseqnum;
           plog.debug(pkgctx,'v_msgseqnum-->'||v_msgseqnum);

        -- Cap nhat lai lenh sua chi tiet
        UPDATE bl_odmastdtl SET
            foacctno = v_strORDERID,
            last_change = SYSTIMESTAMP
        WHERE forefid = pv_ClOrdID;

      --Lay thong tin khop lenh goc
      Begin
        Select NVL(execamt,0), NVL(execqtty,0) Into v_ExecAmt_org, v_ExecQtty_org
        From bl_msgseqnum_map where ClOrdID = pv_BLOrgOrderid;
      Exception when others then
        v_ExecAmt_org:=0;
        v_ExecQtty_org:=0;
      End;
      --Lay thong tin khop lenh khop hien tai:
      Begin
        Select NVL(execamt,0), NVL(execqtty,0)  Into v_ExecAmt, v_ExecQtty
        From odmast o  where ORDERID = pv_OrgOrderID;
      Exception when others then
        v_ExecAmt  :=0;
        v_ExecQtty :=0;
      End;

      --Lay khoi luong tu lenh goc;
      Begin
        Select NVL(Orderqtty,0)  Into v_Orderqtty
        From bl_msgseqnum_map m  where clordid = pv_BLOrgOrderid;
      Exception when others then
        v_Orderqtty :=0;
      End;


      Insert into bl_msgseqnum_map(msgseqnum,acctno,ClOrdID,OrigClOrdID,ExecAmt,ExecQtty,Orderqtty)
      values(v_msgseqnum,v_strORDERID,pv_ClOrdID,pv_BLOrgOrderid,v_ExecAmt+v_ExecAmt_org,v_ExecQtty+v_ExecQtty_org,v_Orderqtty);

 End If;
END;


PROCEDURE bl_getaccountinfo
(
    PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    AFACCTNO IN VARCHAR2,
    INDATE IN VARCHAR2
)
  IS

  V_AFACCTNO VARCHAR2(10);
  V_INDATE VARCHAR2(20);
  v_margintype char(1);
  v_margindesc VARCHAR2(200);
  v_actype varchar2(4);
  v_groupleader varchar2(10);
  v_aamt number(20,0);
  v_pp number(20,0);
  v_avllimit number(20,0);
  v_total   number(20,0);
  v_isPPUsed    number(20,0);
BEGIN

    V_AFACCTNO:=AFACCTNO;
    V_INDATE:=INDATE;
    SELECT MR.MRTYPE,af.actype,mst.groupleader,MR.isppused into v_margintype,v_actype,v_groupleader,v_isPPUsed from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=V_AFACCTNO;
    SELECT CDCONTENT INTO v_margindesc FROM ALLCODE  WHERE  CDTYPE='SA' AND  CDNAME='MARGINTYPE' AND CDVAL=v_margintype;

    if v_margintype='N' or v_margintype='L' then
        --Tai khoan binh thuong khong Margin
        OPEN PV_REFCURSOR FOR
          SELECT v_margintype MRTYPE,v_isPPUsed ISPPUSED,ACCTNO,LICENSE,CUSTID,CUSTODYCD,FULLNAME,ADDRESS,/*CONTRACTCHK,*/v_margindesc TERM,COREBANK,
          BALANCE- ODAMT-NVL(ADVAMT,0)-NVL(SECUREAMT,0) BALANCE,BRATIO,ACTYPE,nvl(adv.avladvance,0) AAMT,TOTAL-NVL(SECUREAMT,0) TOTAL,NVL(ADVAMT,0) ADVAMT,
          greatest(NVL(ADV.AVLADVANCE,0) +nvl(A.mrcrlimit,0)+ A.ADVANCELINE + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT,0) PP,
          NVL(ADV.AVLADVANCE,0) + A.ADVANCELINE + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (OVERAMT, 0)-NVL(SECUREAMT,0) - RAMT AVLLIMIT, a.blacctno
        FROM
            (
                SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME, CF.ADDRESS,CI.COREBANK,
                    CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt, AF.BRATIO,AF.ACTYPE,
                    NVL(AP.AAMT,0) AAMT , CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,
                    AF.MRCRLIMIT,/*AF.MRCLAMT,*/AF.MRCRLIMITMAX, /*CF.CONTRACTCHK,*/ nvl(bl.blacctno,'') blacctno
                FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID
                INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
                LEFT JOIN
                (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT
                    FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y' AND AFACCTNO = V_AFACCTNO
                    GROUP BY AFACCTNO) AP ON TRIM(AF.ACCTNO) = TRIM(AP.ACCTNO)
                LEFT JOIN
                (SELECT blacctno, afacctno
                    FROM bl_register WHERE status = 'A' AND AFACCTNO = V_AFACCTNO) bl
                ON af.acctno = bl.afacctno
                WHERE AF.ACCTNO=V_AFACCTNO

             ) A
         left join
         (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) B
            on A.ACCTNO=B.AFACCTNO
         LEFT JOIN
         (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
            on se.afacctno=a.acctno
         LEFT JOIN
        (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = V_AFACCTNO group by afacctno) adv
           on adv.afacctno=a.acctno ;
    elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or v_groupleader is null) then
        --Tai khoan margin khong tham gia group
        OPEN PV_REFCURSOR FOR
          SELECT v_margintype MRTYPE,v_isPPUsed ISPPUSED,ACCTNO,LICENSE,CUSTID,CUSTODYCD,FULLNAME,ADDRESS,/*CONTRACTCHK,*/v_margindesc TERM,COREBANK,
          BALANCE- ODAMT-NVL(ADVAMT,0)-NVL(SECUREAMT,0) BALANCE,BRATIO,ACTYPE,nvl(adv.avladvance,0) AAMT,TOTAL-NVL(SECUREAMT,0) TOTAL,NVL(ADVAMT,0) ADVAMT,
/*          GREATEST( LEAST((NVL(A.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                            NVL(SE.RECEIVINGAMT,0)) + nvl(se.trfamt,0)
                    ,NVL(ADV.AVLADVANCE,0) + greatest(NVL(A.MRCRLIMITMAX,0)-DFODAMT,0))
               + A.ADVANCELINE + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL(SECUREAMT,0) - RAMT,0) PP,*/
          -- nvl(a.balance - nvl(secureamt,0) + nvl(adv.avladvance,0) + a.advanceline + least(nvl(a.mrcrlimitmax,0),nvl(a.mrcrlimit,0) + nvl(se.seamt,0)+nvl(se.trfamt,0)) - nvl(a.odamt,0) - a.dfdebtamt - a.dfintdebtamt,0) pp,
          nvl(a.balance - nvl(secureamt,0) + nvl(adv.avladvance,0) + a.advanceline + least(nvl(a.mrcrlimitmax,0)+nvl(a.mrcrlimit,0),nvl(a.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(a.odamt,0) - a.dfdebtamt - a.dfintdebtamt,0) pp,
          NVL(ADV.AVLADVANCE,0) + A.ADVANCELINE + NVL(A.MRCRLIMITMAX,0)+nvl(a.mrcrlimit,0)- DFODAMT + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (OVERAMT, 0)-NVL(SECUREAMT,0) - RAMT AVLLIMIT, a.blacctno
           FROM
        (SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,CF.ADDRESS,CI.COREBANK,CI.RAMT,
            CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt, CI.DFODAMT, AF.BRATIO,AF.ACTYPE,
            NVL(AP.AAMT,0) AAMT , CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,
            /*AF.MRCLAMT,*/AF.MRCRLIMITMAX, /*CF.CONTRACTCHK,*/ nvl(bl.blacctno,'') blacctno
         FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID
         INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
         LEFT JOIN
         (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y' AND AFACCTNO = V_AFACCTNO GROUP BY AFACCTNO) AP ON TRIM(AF.ACCTNO) = TRIM(AP.ACCTNO)
         LEFT JOIN
                (SELECT blacctno, afacctno
                    FROM bl_register WHERE status = 'A' AND AFACCTNO = V_AFACCTNO) bl
                ON af.acctno = bl.afacctno
         WHERE AF.ACCTNO=V_AFACCTNO) A
         left join
         (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) B
        on A.ACCTNO=B.AFACCTNO
        LEFT JOIN
        (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
        on se.afacctno=a.acctno
        LEFT JOIN
        (select sum(aamt) aamt,sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = V_AFACCTNO group by afacctno) adv
           on adv.afacctno=a.acctno ;
    else
        --Tai khoan margin join theo group
        SELECT sum(nvl(adv.avladvance,0)) AAMT,sum(TOTAL-NVL(SECUREAMT,0)) TOTAL,
                  LEAST(SUM((NVL(A.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(adv.avladvance,0)))
                            ,sum(NVL(ADV.AVLADVANCE,0) + greatest(NVL(A.MRCRLIMITMAX,0)+NVL(A.MRCRLIMIT,0)-DFODAMT,0)))
                       + sum(BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) PP,
                  sum(NVL(ADV.AVLADVANCE,0) + NVL(A.MRCRLIMITMAX,0)+NVL(A.MRCRLIMIT,0)-DFODAMT + BALANCE- ODAMT - dfdebtamt - dfintdebtamt- NVL (OVERAMT, 0)-NVL(SECUREAMT,0) - RAMT) AVLLIMIT
            into v_aamt, v_total, v_pp,v_AVLLIMIT
        FROM
            (SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME, CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt,CI.DFODAMT, AF.BRATIO,AF.ACTYPE,
             CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,/*AF.MRCLAMT,*/AF.MRCRLIMITMAX
             FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID and af.groupleader=v_groupleader
             INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
             LEFT JOIN (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT
                            FROM STSCHD
                            WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y'
                            GROUP BY AFACCTNO) AP ON AF.ACCTNO = AP.ACCTNO
             ) A
             left join
             (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) B
            on A.ACCTNO=B.AFACCTNO
            LEFT JOIN
            (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
            on se.afacctno=a.acctno
            LEFT JOIN
           (select sum(aamt) aamt,sum(depoamt) avladvance,V_AFACCTNO afacctno from v_getAccountAvlAdvance b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader group by v_groupleader) adv
            on adv.afacctno=a.acctno ;

        OPEN PV_REFCURSOR FOR
        SELECT v_margintype MRTYPE,v_isPPUsed ISPPUSED,ACCTNO,LICENSE,CUSTID,CUSTODYCD,FULLNAME,ADDRESS,/*CONTRACTCHK,*/v_margindesc TERM,COREBANK,
          BALANCE- ODAMT-NVL(ADVAMT,0)-NVL(SECUREAMT,0) BALANCE,BRATIO,ACTYPE,
          v_aamt aamt, v_total total, greatest(A.ADVANCELINE + v_pp,0) pp,A.ADVANCELINE +  v_AVLLIMIT AVLLIMIT
           FROM
        (SELECT AF.ACCTNO,CF.IDCODE LICENSE,CF.CUSTID, CF.CUSTODYCD, CF.FULLNAME,CF.ADDRESS,CI.COREBANK, CI.RAMT, CI.BALANCE, CI.ODAMT,ci.dfdebtamt, ci.dfintdebtamt, AF.BRATIO,AF.ACTYPE, NVL(AP.AAMT,0) AAMT , CI.BALANCE - CI.ODAMT + NVL(AP.AAMT,0) TOTAL,AF.ADVANCELINE,AF.MRCRLIMIT,/*AF.MRCLAMT,*/AF.MRCRLIMITMAX/*,CF.CONTRACTCHK*/
         FROM CFMAST CF INNER JOIN AFMAST AF ON CF.CUSTID=AF.CUSTID
         INNER JOIN CIMAST CI ON AF.ACCTNO=CI.AFACCTNO
         LEFT JOIN (SELECT AFACCTNO ACCTNO, SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) AAMT FROM STSCHD WHERE DUETYPE = 'RM' AND STATUS='N' AND DELTD <> 'Y' AND AFACCTNO = V_AFACCTNO GROUP BY AFACCTNO) AP ON TRIM(AF.ACCTNO) = TRIM(AP.ACCTNO)
         WHERE AF.ACCTNO=V_AFACCTNO) A
         left join
         (select * from v_getbuyorderinfo where afacctno = V_AFACCTNO) B
        on A.ACCTNO=B.AFACCTNO

        LEFT JOIN
        (select * from v_getsecmargininfo where afacctno = V_AFACCTNO) SE
        on se.afacctno=a.acctno;
    end if;

EXCEPTION
    WHEN others THEN
        return;
END;


PROCEDURE bl_getbloombergorder (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_TRADEPLACE       IN       VARCHAR2,
   pv_STATUS           IN       VARCHAR2,
   pv_ACCOUNT           IN      VARCHAR2,
   pv_SYMBOL           IN      VARCHAR2,
   pv_TLID              IN      VARCHAR2,
   pv_CMDID             IN      VARCHAR2
)
IS
--
-- PURPOSE: LAY THONG TIN LENH BLOOMBERG
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   04-July-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_TradePlace    varchar2(10);
    v_Status        varchar2(10);
    v_Account       varchar2(100);
    v_Symbol        varchar2(100);
BEGIN
    IF pv_TRADEPLACE = 'ALL' THEN
        v_TradePlace := '%%';
    ELSE
        v_TradePlace := pv_TRADEPLACE;
    END IF;

    IF pv_STATUS = 'ALL' THEN
        v_Status := '%%';
    ELSE
        v_Status := pv_STATUS;
    END IF;

    IF pv_ACCOUNT = 'ALL' THEN
        v_Account := '%%';
    ELSE
        v_Account := '%' || pv_ACCOUNT || '%';
    END IF;

    IF pv_SYMBOL = 'ALL' THEN
        v_Symbol := '%%';
    ELSE
        v_Symbol := '%' || pv_SYMBOL || '%';
    END IF;

    -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
    FOR
        SELECT * FROM
            (
                SELECT mst.traderid, mst.blacctno, mst.custodycd, mst.afacctno, MST.AUTOID, MST.BLORDERID ORDERID, mst.exectype,
                    mst.pricetype, A2.CDCONTENT EXECTYPEDESC, mst.symbol, mst.quantity ORDERQTTY, mst.price*1000 QUOTEPRICE,
                    CASE WHEN mst.status = 'A' and MST.sentqtty + mst.ptsentqtty = 0 THEN 'PD' -- CHO XU LY
                                    WHEN mst.status = 'T' THEN 'TT' -- CHO XU LY LOI THIEU SO DU
                                    WHEN mst.status = 'F' AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptbookqtty=0 AND MST.execqtty=0 THEN 'SF' -- DANG GUI VAO FLEX
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty < MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'PS' -- GUI 1 PHAN
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty = MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'AS' -- GUI HET
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty < MST.quantity AND MST.execqtty>0 THEN 'PF' -- KHOP 1 PHAN
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty = MST.quantity AND MST.execqtty>0 THEN 'AF' -- KHOP HET
                                    WHEN mst.status = 'F' AND mst.edstatus = 'A' THEN 'PA' -- DANG SUA
                                    WHEN mst.status = 'F' AND mst.edstatus = 'C' THEN 'PC' -- DANG HUY
                                    WHEN MST.status = 'R' THEN 'CC' -- DA HUY
                                    WHEN MST.status = 'C' THEN 'CC' -- DA HUY
                                    WHEN MST.STATUS = 'E' THEN 'EE' -- HET HIEU LUC
                                    END STATUS,
                    mst.status ORSTATUSVALUE, A3.cdcontent DESC_STATUS, a4.CDCONTENT DESC_PRICETYPE,
                    mst.execqtty, mst.execamt, (case when mst.execqtty = 0 then 0 else round(mst.execamt/mst.execqtty,0) end) EXECPRICE, mst.remainqtty,
                    mst.cancelqtty, mst.amendqtty ADJUSTQTTY, a5.cdcontent timetype, nvl(fo.feedbackmsg,mst.feedbackmsg) ERR_DESC,
                    mst.last_change, TO_CHAR(MST.ORDERTIME,'HH24:MI:SS') SENTTIME, mst.retlid, tlp.tlfullname REFULLNAME,
                    sb.tradeplace TRADEPLACEVL, a6.cdcontent tradeplace

                FROM BL_ODMAST MST, ALLCODE A1, ALLCODE A2,ALLCODE A3, ALLCODE A4,ALLCODE A5, ALLCODE A6,
                    SBSECURITIES SB, afmast af, tlprofiles tlp, cfmast cf,
                    (select max(fo.feedbackmsg) feedbackmsg, fo.blorderid from fomast fo where fo.blorderid is not null group by fo.blorderid) fo
                WHERE MST.CODEID = SB.CODEID
                    AND MST.blodtype = 1/*) or (mst.retlid is null and mst.status in ('R','E','C')))*/
                    --AND MST.status IN ('P','D') AND mst.retlid IS NOT NULL
                    --AND mst.remainqtty + mst.ptbookqtty - mst.ptsentqtty > 0
                    AND af.acctno = mst.afacctno and af.custid = cf.custid
                    AND mst.retlid = tlp.tlid(+)
                    AND mst.blorderid = fo.blorderid (+)
                    AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'BLODTYPE' AND A1.CDVAL = MST.BLODTYPE
                    AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'EXECTYPE' AND A2.CDVAL = MST.EXECTYPE
                    AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'BLSTATUS'
                    AND A3.CDVAL = CASE WHEN mst.status = 'A' and MST.sentqtty + mst.ptsentqtty = 0 THEN 'PD' -- CHO XU LY
                                        WHEN mst.status = 'T' THEN 'TT' -- CHO XU LY LOI THIEU SO DU
                                        WHEN mst.status = 'F' AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptbookqtty=0 AND MST.execqtty=0 THEN 'SF' -- DANG GUI VAO FLEX
                                        WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty < MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'PS' -- GUI 1 PHAN
                                        WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty = MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'AS' -- GUI HET
                                        WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty < MST.quantity AND MST.execqtty>0 THEN 'PF' -- KHOP 1 PHAN
                                        WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty = MST.quantity AND MST.execqtty>0 THEN 'AF' -- KHOP HET
                                        WHEN mst.status = 'F' AND mst.edstatus = 'A' THEN 'PA' -- DANG SUA
                                        WHEN mst.status = 'F' AND mst.edstatus = 'C' THEN 'PC' -- DANG HUY
                                        WHEN MST.status = 'R' THEN 'CC' -- DA HUY
                                        WHEN MST.status = 'C' THEN 'CC' -- DA HUY
                                        WHEN MST.STATUS = 'E' THEN 'EE' -- HET HIEU LUC
                                        END
                    AND a5.CDTYPE ='OD' AND a5.CDNAME='TIMETYPE' AND a5.CDVAL=MST.TIMETYPE
                    AND a6.CDTYPE ='OD' AND a6.CDNAME='TRADEPLACE' AND a6.CDVAL=SB.TRADEPLACE
                    AND a4.CDTYPE ='OD' AND a4.CDNAME='PRICETYPE' AND a4.CDVAL=MST.PRICETYPE
                    AND cf.CUSTODYCD IN (SELECT CUSTODYCD FROM
                                (SELECT TL.TLID, TL.BRID TLBRID, (select to_char( listagg ( grpid,'|') within group(order by tlid)) odr from tlgrpusers
                                where tlid = pv_TLID) TLGRPID, FNC_CHECK_CMDID_SCOPE(pv_CMDID,'M', pv_TLID) CHKSCOPE,
                                    CF.CUSTID, CF.CUSTODYCD, CF.CAREBY, CF.BRID, INSTR((select to_char( listagg ( grpid,'|') within group(order by tlid)) odr from tlgrpusers
                                where tlid = pv_TLID), CF.CAREBY) IDXGRP,
                                    (CASE WHEN TL.BRID=FNC_GET_REGIONID(CF.BRID) THEN 1 ELSE 0 END) IDXREGION,
                                    (CASE WHEN TL.BRID=CF.BRID THEN 1 ELSE 0 END) IDXSUBBR,
                                    (CASE WHEN TL.BRID=SUBSTR(CF.BRID,1,2) || '01' THEN 1 ELSE 0 END) IDXBR
                                    FROM TLPROFILES TL, CFMAST CF WHERE TL.TLID=pv_TLID) D
                                WHERE D.CHKSCOPE <> 'N'
                                    AND (CASE WHEN D.CHKSCOPE='C' THEN IDXGRP ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='S' THEN IDXSUBBR ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='B' THEN IDXBR ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='R' THEN IDXREGION ELSE 1 END) > 0)
            )
            WHERE TRADEPLACEVL LIKE v_TradePlace
                AND STATUS LIKE v_Status
                AND (BLACCTNO LIKE v_Account OR CUSTODYCD LIKE v_Account OR AFACCTNO LIKE v_Account)
                AND symbol LIKE v_Symbol
            ORDER BY last_change DESC;
EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('bl_getbloombergorder:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;


PROCEDURE bl_getblremngorder_asd (
   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
   pv_STATUS            IN       VARCHAR2,
   pv_ACCOUNT           IN      VARCHAR2,
   pv_SYMBOL            IN      VARCHAR2,
   pv_WAITTIME          IN      VARCHAR2,
   pv_TLID              IN      VARCHAR2,
   pv_CMID              IN      VARCHAR2
)
IS
--
-- PURPOSE: LAY THONG TIN LENH BLOOMBERG DA GAN CHO MG
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   03-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_Status    varchar2(10);
    v_Account       varchar2(100);
    v_Symbol        varchar2(100);
    v_RETLID        varchar2(10);
    v_SWaitTime     NUMBER;
    v_LWaitTime     NUMBER;
BEGIN
    IF pv_STATUS = 'ALL' THEN
        v_Status := '%%';
    ELSE
        v_Status := pv_STATUS;
    END IF;

    IF pv_ACCOUNT = 'ALL' THEN
        v_Account := '%%';
    ELSE
        v_Account := '%' || pv_ACCOUNT || '%';
    END IF;

    IF pv_SYMBOL = 'ALL' THEN
        v_Symbol := '%%';
    ELSE
        v_Symbol := '%' || upper(pv_SYMBOL) || '%';
    END IF;

    IF pv_WAITTIME = 'A' THEN
        v_SWaitTime := 100*365*24*60; -- 100 nam
        v_LWaitTime := 0;
    ELSIF pv_WAITTIME = 'O' THEN
        v_SWaitTime := 100*365*24*60; -- 100 nam
        v_LWaitTime := 11;
    ELSE
        v_SWaitTime := to_number(pv_WAITTIME);
        v_LWaitTime := 0;
    END IF;

    -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
    FOR
        SELECT *
        FROM
        (
            SELECT MST.AUTOID, MST.BLORDERID, MST.BLODTYPE, A1.CDCONTENT BLODTYPEDESC, MST.TRADERID, MST.BLACCTNO, MST.AFACCTNO, MST.CUSTODYCD,
                MST.EXECTYPE, A2.CDCONTENT EXECTYPEDESC, MST.SYMBOL,
                MST.QUANTITY ORDERQTTY, MST.PRICE*1000 QUOTEPRICE, MST.PRICETYPE, MST.EXECQTTY, MST.EXECAMT,
                NVL(OD.CANCELQTTY,MST.CANCELQTTY) CANCELQTTY,
                MST.PTBOOKQTTY, MST.QUANTITY - MST.PTBOOKQTTY PCQTTY, MST.SENTQTTY, MST.REMAINQTTY,MST.PTSENTQTTY,
                CASE WHEN MST.execqtty>0 THEN ROUND(MST.execamt/MST.execqtty) ELSE 0 END AVGPRICE,
                A3.cdcontent DESC_STATUS, TO_CHAR(MST.ORDERTIME,'HH24:MI:SS') ORDERTIME, MST.ORDERTIME ORDERTIMEVL,
                MST.BLINSTRUCTION, MST.REMNGCOMMENT, MST.reexecomment, mst.retlid, --TO_CHAR(SYSTIMESTAMP - MST.ORDERTIME) WAITTIME
                TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,1,INSTR(SYSTIMESTAMP - ORDERTIME,' ')))*24*60 -- WTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+1,2))*60 -- HWTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+4,2)) WAITTIME,
                TO_NUMBER(SUBSTR(SYSTIMESTAMP - mst.assigntime,1,INSTR(SYSTIMESTAMP - mst.assigntime,' ')))*24*60 -- WTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - mst.assigntime,INSTR(SYSTIMESTAMP - mst.assigntime,' ')+1,2))*60 -- HWTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - mst.assigntime,INSTR(SYSTIMESTAMP - mst.assigntime,' ')+4,2)) ASSIGNEDTIME,
                CASE WHEN mst.status in ('A','P','D') and MST.sentqtty + mst.ptsentqtty = 0 THEN 'PD' -- CHO XU LY
                      WHEN mst.status = 'T' THEN 'TT' -- CHO XU LY LOI THIEU SO DU
                      WHEN mst.status = 'F' AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptbookqtty=0 AND MST.execqtty=0 THEN 'SF' -- DANG GUI VAO FLEX
                      WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty < MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'PS' -- GUI 1 PHAN
                      WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty = MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'AS' -- GUI HET
                      WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty < MST.quantity AND MST.execqtty>0 THEN 'PF' -- KHOP 1 PHAN
                      WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty = MST.quantity AND MST.execqtty>0 THEN 'AF' -- KHOP HET
                      WHEN mst.status = 'F' AND mst.edstatus = 'A' THEN 'PA' -- DANG SUA
                      WHEN mst.status = 'F' AND mst.edstatus = 'C' THEN 'PC' -- DANG HUY
                      WHEN MST.status = 'R' THEN 'CC' -- DA HUY
                      WHEN MST.status = 'C' THEN 'CC' -- DA HUY
                      WHEN MST.STATUS = 'E' THEN 'EE' -- HET HIEU LUC
                      END BLSTATUSVL,
                    CASE WHEN nvl(blr.afacctno,' ') <> ' ' THEN 'Y' ELSE 'N' END isblacct,
                    nvl(mst.asdtlid,'') asdtlid,  a4.cdcontent DESC_VIA
            FROM BL_ODMAST MST, ALLCODE A1, ALLCODE A2, allcode a3, allcode a4, afmast af,
                (SELECT * FROM bl_register blr WHERE status = 'A') blr, cfmast cf,
                (SELECT BLORDERID, SUM(CANCELQTTY) CANCELQTTY  FROM ODMAST WHERE NVL(BLORDERID,'0000') <> '0000' GROUP BY BLORDERID) OD
            WHERE MST.APP_STATUS = 'A' AND MST.blodtype <> 1 ---AND MST.status not in ('P','D')
                AND MST.BLORDERID = OD.BLORDERID(+)
                AND af.acctno = mst.afacctno and af.custid = cf.custid
                AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'BLODTYPE' AND A1.CDVAL = MST.BLODTYPE
                AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'EXECTYPE' AND A2.CDVAL = MST.EXECTYPE
                AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'BLSTATUS'
                AND A3.CDVAL = CASE WHEN mst.status IN ('A','P','D') THEN 'PD' -- CHO XU LY
                                    WHEN mst.status = 'T' THEN 'TT' -- CHO XU LY LOI THIEU SO DU
                                    WHEN mst.status = 'F' AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptbookqtty=0 AND MST.execqtty=0 THEN 'SF' -- DANG GUI VAO FLEX
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty < MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'PS' -- GUI 1 PHAN
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty = MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'AS' -- GUI HET
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty < MST.quantity AND MST.execqtty>0 THEN 'PF' -- KHOP 1 PHAN
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty = MST.quantity AND MST.execqtty>0 THEN 'AF' -- KHOP HET
                                    WHEN mst.status = 'F' AND mst.edstatus = 'A' THEN 'PA' -- DANG SUA
                                    WHEN mst.status = 'F' AND mst.edstatus = 'C' THEN 'PC' -- DANG HUY
                                    WHEN MST.status = 'R' THEN 'CC' -- DA HUY
                                    WHEN MST.status = 'C' THEN 'CC' -- DA HUY
                                    WHEN MST.STATUS = 'E' THEN 'EE' -- HET HIEU LUC
                                    END
                AND A4.CDTYPE = 'OD' AND A4.CDNAME = 'VIA' AND A4.CDVAL = MST.via
                AND (MST.BLACCTNO LIKE v_Account OR MST.CUSTODYCD LIKE v_Account OR MST.AFACCTNO LIKE v_Account)
                AND MST.SYMBOL LIKE v_Symbol
                AND cf.CUSTODYCD IN (SELECT CUSTODYCD FROM
                                (SELECT TL.TLID, TL.BRID TLBRID, (select to_char( listagg ( grpid,'|') within group(order by tlid)) odr from tlgrpusers
                                where tlid = pv_TLID) TLGRPID, FNC_CHECK_CMDID_SCOPE(pv_CMID,'M', pv_TLID) CHKSCOPE,
                                    CF.CUSTID, CF.CUSTODYCD, CF.CAREBY, CF.BRID, INSTR((select to_char( listagg ( grpid,'|') within group(order by tlid)) odr from tlgrpusers
                                where tlid = pv_TLID), CF.CAREBY) IDXGRP,
                                    (CASE WHEN TL.BRID=FNC_GET_REGIONID(CF.BRID) THEN 1 ELSE 0 END) IDXREGION,
                                    (CASE WHEN TL.BRID=CF.BRID THEN 1 ELSE 0 END) IDXSUBBR,
                                    (CASE WHEN TL.BRID=SUBSTR(CF.BRID,1,2) || '01' THEN 1 ELSE 0 END) IDXBR
                                    FROM TLPROFILES TL, CFMAST CF WHERE TL.TLID=pv_TLID) D
                                WHERE D.CHKSCOPE <> 'N'
                                    AND (CASE WHEN D.CHKSCOPE='C' THEN IDXGRP ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='S' THEN IDXSUBBR ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='B' THEN IDXBR ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='R' THEN IDXREGION ELSE 1 END) > 0)
                AND mst.afacctno = blr.afacctno (+)
        ) MST
        WHERE MST.BLSTATUSVL LIKE v_Status
            ---AND MST.ASSIGNEDTIME >= v_LWaitTime AND MST.ASSIGNEDTIME <= v_SWaitTime
        ORDER BY MST.ORDERTIMEVL desc
    ;

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('bl_getblremngorder_new:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;


PROCEDURE bl_getblremngorder_new (
   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
   pv_TRADEPLACE        IN       VARCHAR2,
   pv_ACCOUNT           IN      VARCHAR2,
   pv_SYMBOL            IN      VARCHAR2,
   pv_EXECTYPE          IN      VARCHAR2,
   pv_WAITTIME          IN      VARCHAR2,
   pv_TLID              IN      VARCHAR2
)
IS
--
-- PURPOSE: LAY THONG TIN LENH BLOOMBERG CHUA GAN DE GAN CHO MG
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   03-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_TradePlace    varchar2(10);
    v_Account       varchar2(100);
    v_Symbol        varchar2(100);
    v_ExecType      varchar2(10);
    v_SWaitTime     NUMBER;
    v_LWaitTime     NUMBER;
BEGIN
    IF pv_TRADEPLACE = 'ALL' THEN
        v_TradePlace := '%%';
    ELSE
        v_TradePlace := pv_TRADEPLACE;
    END IF;

    IF pv_ACCOUNT = 'ALL' THEN
        v_Account := '%%';
    ELSE
        v_Account := '%' || pv_ACCOUNT || '%';
    END IF;

    IF pv_SYMBOL = 'ALL' THEN
        v_Symbol := '%%';
    ELSE
        v_Symbol := '%' || UPPER(pv_SYMBOL) || '%';
    END IF;

    IF pv_EXECTYPE = 'ALL' THEN
        v_ExecType := '%%';
    ELSE
        v_ExecType := pv_EXECTYPE;
    END IF;

    IF pv_WAITTIME = 'A' THEN
        v_SWaitTime := 100*365*24*60; -- 100 nam
        v_LWaitTime := 0;
    ELSIF pv_WAITTIME = 'O' THEN
        v_SWaitTime := 100*365*24*60; -- 100 nam
        v_LWaitTime := 11;
    ELSE
        v_SWaitTime := to_number(pv_WAITTIME);
        v_LWaitTime := 0;
    END IF;

    -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
    FOR
        SELECT *
        FROM
        (
            SELECT MST.AUTOID, MST.BLORDERID, MST.BLODTYPE, A1.CDCONTENT BLODTYPEDESC, MST.TRADERID, MST.BLACCTNO, MST.AFACCTNO, MST.CUSTODYCD,
                MST.EXECTYPE, A2.CDCONTENT EXECTYPEDESC, MST.SYMBOL, MST.QUANTITY ORDERQTTY, MST.PRICE*1000 QUOTEPRICE,MST.REMAINQTTY,
                MST.PTBOOKQTTY, MST.QUANTITY - MST.PTBOOKQTTY PCQTTY, MST.SENTQTTY, MST.PTSENTQTTY, MST.PRICETYPE,
                TO_CHAR(MST.ORDERTIME,'HH24:MI:SS') ORDERTIME, MST.ORDERTIME ORDERTIMEVL,
                MST.BLINSTRUCTION, MST.REMNGCOMMENT, --'0001' RETLID, tl.tlfullname REFULLNAME,
                TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,1,INSTR(SYSTIMESTAMP - ORDERTIME,' ')))*24*60 -- WTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+1,2))*60 -- HWTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+4,2)) WAITTIME,
                A3.cdcontent DESC_STATUS, a4.cdcontent DESC_VIA
            FROM BL_ODMAST MST, ALLCODE A1, ALLCODE A2, ALLCODE A3, ALLCODE A4, SBSECURITIES SB, afmast af --, tlprofiles tl
            WHERE MST.CODEID = SB.CODEID
                AND MST.blodtype <> 1
                AND MST.status IN ('P','D') and mst.retlid IS NOT NULL
                AND mst.remainqtty + mst.ptbookqtty - mst.ptsentqtty > 0
                AND af.acctno = mst.afacctno
                AND mst.exectype NOT IN ('CB','CS','AB','AS')
                --AND tl.tlid = '0001'
                AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'BLODTYPE' AND A1.CDVAL = MST.BLODTYPE
                AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'EXECTYPE' AND A2.CDVAL = MST.EXECTYPE
                AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'BLSTATUS'
                AND A3.CDVAL = CASE WHEN mst.status IN ('A','P','D') THEN 'PD' -- CHO XU LY
                                    WHEN mst.status = 'T' THEN 'TT' -- CHO XU LY LOI THIEU SO DU
                                    WHEN mst.status = 'F' AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptbookqtty=0 AND MST.execqtty=0 THEN 'SF' -- DANG GUI VAO FLEX
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty < MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'PS' -- GUI 1 PHAN
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty = MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'AS' -- GUI HET
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty < MST.quantity AND MST.execqtty>0 THEN 'PF' -- KHOP 1 PHAN
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty = MST.quantity AND MST.execqtty>0 THEN 'AF' -- KHOP HET
                                    WHEN mst.status = 'F' AND mst.edstatus = 'A' THEN 'PA' -- DANG SUA
                                    WHEN mst.status = 'F' AND mst.edstatus = 'C' THEN 'PC' -- DANG HUY
                                    WHEN MST.status = 'R' THEN 'CC' -- DA HUY
                                    WHEN MST.status = 'C' THEN 'CC' -- DA HUY
                                    WHEN MST.STATUS = 'E' THEN 'EE' -- HET HIEU LUC
                                    END
                AND A4.CDTYPE = 'OD' AND A4.CDNAME = 'VIA' AND A4.CDVAL = MST.via
                AND SB.TRADEPLACE LIKE v_TradePlace
                AND (MST.BLACCTNO LIKE v_Account OR MST.CUSTODYCD LIKE v_Account OR MST.AFACCTNO LIKE v_Account)
                AND MST.SYMBOL LIKE v_Symbol
                AND MST.blodtype LIKE v_ExecType
                AND EXISTS (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = pv_TLID AND tlgrp.grpid = af.careby)
            UNION ALL
            -- Phan lay len lenh chua gan MG
            SELECT MST.AUTOID, MST.BLORDERID, MST.BLODTYPE, A1.CDCONTENT BLODTYPEDESC, MST.TRADERID, MST.BLACCTNO, MST.AFACCTNO, MST.CUSTODYCD,
                MST.EXECTYPE, A2.CDCONTENT EXECTYPEDESC, MST.SYMBOL, MST.QUANTITY ORDERQTTY, MST.PRICE QUOTEPRICE,MST.REMAINQTTY,
                MST.PTBOOKQTTY, MST.QUANTITY - MST.PTBOOKQTTY PCQTTY, MST.SENTQTTY, MST.PTSENTQTTY, MST.PRICETYPE,
                TO_CHAR(MST.ORDERTIME,'HH24:MI:SS') ORDERTIME, MST.ORDERTIME ORDERTIMEVL,
                MST.BLINSTRUCTION, MST.REMNGCOMMENT, --'0001' RETLID, tl.tlfullname REFULLNAME,
                TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,1,INSTR(SYSTIMESTAMP - ORDERTIME,' ')))*24*60 -- WTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+1,2))*60 -- HWTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+4,2)) WAITTIME,
                A3.cdcontent DESC_STATUS, a4.cdcontent DESC_VIA
            FROM BL_ODMAST MST, ALLCODE A1, ALLCODE A2, ALLCODE A3, ALLCODE A4, SBSECURITIES SB, afmast af --, tlprofiles tl
            WHERE MST.CODEID = SB.CODEID
                --AND MST.blodtype <> 1
                AND MST.status NOT IN ('R','E','C') and mst.retlid IS NULL
                --AND mst.remainqtty + mst.ptbookqtty - mst.ptsentqtty > 0
                AND af.acctno = mst.afacctno
                AND mst.exectype NOT IN ('CB','CS','AB','AS')
                AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'BLODTYPE' AND A1.CDVAL = MST.BLODTYPE
                AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'EXECTYPE' AND A2.CDVAL = MST.EXECTYPE
                AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'BLSTATUS'
                AND A3.CDVAL = CASE WHEN mst.status IN ('A','P','D') THEN 'PD' -- CHO XU LY
                                    WHEN mst.status = 'T' THEN 'TT' -- CHO XU LY LOI THIEU SO DU
                                    WHEN mst.status = 'F' AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptbookqtty=0 AND MST.execqtty=0 THEN 'SF' -- DANG GUI VAO FLEX
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty < MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'PS' -- GUI 1 PHAN
                                    WHEN mst.status in ('F','A') AND mst.edstatus = 'N' AND MST.sentqtty + mst.ptsentqtty = MST.quantity-MST.cancelqtty AND MST.execqtty=0 THEN 'AS' -- GUI HET
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty < MST.quantity AND MST.execqtty>0 THEN 'PF' -- KHOP 1 PHAN
                                    WHEN mst.status in ('F','C','M') AND mst.edstatus in ('N','W','S') AND MST.execqtty = MST.quantity AND MST.execqtty>0 THEN 'AF' -- KHOP HET
                                    WHEN mst.status = 'F' AND mst.edstatus = 'A' THEN 'PA' -- DANG SUA
                                    WHEN mst.status = 'F' AND mst.edstatus = 'C' THEN 'PC' -- DANG HUY
                                    WHEN MST.status = 'R' THEN 'CC' -- DA HUY
                                    WHEN MST.status = 'C' THEN 'CC' -- DA HUY
                                    WHEN MST.STATUS = 'E' THEN 'EE' -- HET HIEU LUC
                                    END
                AND A4.CDTYPE = 'OD' AND A4.CDNAME = 'VIA' AND A4.CDVAL = MST.via
                AND SB.TRADEPLACE LIKE v_TradePlace
                AND (MST.BLACCTNO LIKE v_Account OR MST.CUSTODYCD LIKE v_Account OR MST.AFACCTNO LIKE v_Account)
                AND MST.SYMBOL LIKE v_Symbol
                AND MST.blodtype LIKE v_ExecType
                AND EXISTS (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = pv_TLID AND tlgrp.grpid = af.careby)
        ) MST
        WHERE MST.WAITTIME >= v_LWaitTime AND MST.WAITTIME <= v_SWaitTime
        ORDER BY MST.ORDERTIMEVL desc
    ;

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('bl_getblremngorder_new:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;


PROCEDURE BL_MNGAssign (
   --pv_BLORDERID       IN      VARCHAR2,
   --pv_recustid        IN      VARCHAR2,
   pv_strassign       IN      VARCHAR2,
   pv_tlid            IN      VARCHAR2
)
IS
--
-- PURPOSE: GAN MOI GIOI XU LY LENH
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_REMAINQTTY        NUMBER;
    v_PRETLID           varchar2(10);
    v_strAssign         varchar2(50);
    v_BLAUTOID          varchar2(20);
    v_RETLID            varchar2(10);
    v_BLORDERID         VARCHAR2(20);
BEGIN
    -- Lay thong tin hien tai
    /*SELECT bl.remainqtty, bl.retlid
    INTO v_REMAINQTTY, v_PRETLID
    FROM bl_odmast bl
    WHERE autoid = pv_BLORDERID;

    -- Cap nhat vao bang lenh Bloomberg

    UPDATE bl_odmast SET
        PRETLID = PRETLID || RETLID,
        RETLID = pv_recustid,
        ASSIGNTIME = SYSTIMESTAMP,
        pstatus = pstatus || status,
        status = 'A'
    WHERE autoid = pv_BLORDERID;
    -- Ghi vao bang log

    INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
    VALUES (SEQ_BL_LOG.NEXTVAL,pv_BLORDERID,'REASSIGN',v_PRETLID,pv_recustid,v_REMAINQTTY,SYSTIMESTAMP,pv_tlid);
*/

    -- Cat string truyen vao de gan
    FOR rec IN
    (
        SELECT regexp_substr(pv_strassign,'[^$]+',1,level) str_assign FROM dual
            connect by regexp_substr(pv_strassign,'[^$]+',1,level) is not null
    )
    LOOP
        v_strAssign := rec.str_assign;
        -- Voi moi chuoi lai lay ra so hieu lenh va moi gioi gan
        v_BLAUTOID := substr(v_strAssign,1,instr(v_strAssign,'#')-1);
        v_RETLID := substr(v_strAssign,instr(v_strAssign,'#')+1);

        -- Lay thong tin hien tai
        SELECT bl.remainqtty, bl.retlid, BL.BLORDERID
        INTO v_REMAINQTTY, v_PRETLID, v_BLORDERID
        FROM bl_odmast bl
        WHERE autoid = v_BLAUTOID;

        -- Cap nhat vao bang lenh Bloomberg

        UPDATE bl_odmast SET
            PRETLID = PRETLID || RETLID,
            RETLID = v_RETLID,
            PASDTLID = PASDTLID || ASDTLID,
            ASDTLID = pv_tlid,
            ASSIGNTIME = SYSTIMESTAMP,
            pstatus = pstatus || status,
            status = CASE WHEN STATUS in ('F','T') THEN STATUS ELSE 'A' END,
            LAST_CHANGE = SYSTIMESTAMP
        WHERE autoid = v_BLAUTOID;

        -- Cap nhat ODMAST va FOMAST neu lenh thu hoi va gan lai cho MG khac
        /*UPDATE FOMAST SET
            PRETLID = PRETLID || RETLID,
            LAST_CHANGE = SYSTIMESTAMP
        WHERE BLORDERID = v_BLORDERID;*/

        /*UPDATE ODMAST SET
            RETLID = v_RETLID,
            LAST_CHANGE = SYSTIMESTAMP
        WHERE BLORDERID = v_BLORDERID;*/
        -- Ghi vao bang log

        INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
        VALUES (BL_LOG_seq.NEXTVAL,v_BLAUTOID,'REASSIGN',v_PRETLID,v_RETLID,v_REMAINQTTY,SYSTIMESTAMP,pv_tlid);

    END LOOP;
    COMMIT;

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('BL_MNGAssign:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;

PROCEDURE BL_MNGReject (
   pv_strreject       IN      VARCHAR2,
   pv_tlid            IN      VARCHAR2,
   pv_err_code      IN OUT  varchar2
)
IS
--
-- PURPOSE: HUY LENH BLOOMBERG
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_REMAINQTTY        NUMBER;
    v_PTREMAINQTTY      NUMBER;
    v_STATUS            varchar2(10);
    v_BLAUTOID          varchar2(20);
    v_SENTQTTY          NUMBER;
    v_blorderid         varchar2(20);
    v_err_code          varchar2(50);
    v_err_msg           varchar2(500);
    v_strCURRDATE       date;
    v_BL_OdmastSEQ      varchar2(50);
    v_Cancel_orderid    varchar2(50);
    v_CancelVia         varchar2(10);
    v_BLOdtype          varchar2(10);
    v_PriceType         varchar2(10);
    v_Quantity          number;
    v_CancelQtty        number;
    v_ExecQtty          number;
BEGIN
    plog.setbeginsection(pkgctx, 'BL_MNGReject');
    pv_err_code := systemnums.C_SUCCESS;
    -- Lay thong tin hien tai

    -- Cat string truyen vao de gan
    FOR rec IN
    (
        SELECT regexp_substr(pv_strreject,'[^$]+',1,level) blautoid FROM dual
            connect by regexp_substr(pv_strreject,'[^$]+',1,level) is not null
    )
    LOOP
        v_BLAUTOID := rec.blautoid;

        -- Lay thong tin hien tai
        SELECT bl.remainqtty, bl.ptbookqtty - bl.ptsentqtty, bl.status, bl.sentqtty + bl.ptsentqtty,
            bl.blorderid, bl.blodtype, bl.pricetype, bl.quantity, bl.cancelqtty, bl.execqtty
        INTO v_REMAINQTTY, v_PTREMAINQTTY, v_STATUS, v_SENTQTTY,
            v_blorderid, v_BLOdtype, v_PriceType, v_Quantity, v_CancelQtty, v_ExecQtty
        FROM bl_odmast bl
        WHERE autoid = v_BLAUTOID;

        -- Neu lenh huy tu Flex thi ghi nhan vao BL_ODMAST
        -- Nhan biet bang user truyen xuong 6868: Tu Bloomberg
        -- TheNN, 25-Dec-2013: Bo phan sinh lenh y/c huy vao bl_odmast vi se sinh ra khi dat lenh vao fomast
        /*if pv_tlid <> '6868' then

            v_strCURRDATE := getcurrdate;
            Select seq_blorderid.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
            v_Cancel_orderid := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');

            INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                                    PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                                    CANCELQTTY,AMENDQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                                    TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                                    PRETLID,ASSIGNTIME,EXECTIME,FOREFID,REFFOREFID,ORGQUANTITY,ORGPRICE,ROOTORDERID,edstatus,edexectype)
            SELECT seq_bl_odmast.NEXTVAL, v_Cancel_orderid,bl.BLACCTNO,bl.AFACCTNO,bl.CUSTODYCD,bl.TRADERID,'P' STATUS,bl.BLODTYPE,bl.EXECTYPE,
                                    bl.PRICETYPE,bl.TIMETYPE,bl.CODEID,bl.SYMBOL,bl.QUANTITY,bl.PRICE,bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,
                                    bl.CANCELQTTY,bl.AMENDQTTY,bl.blorderid REFBLORDERID,'Received cancel request' FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_strCURRDATE,
                                    '' TXNUM,v_strCURRDATE,v_strCURRDATE,'F' VIA,'N' DELTD,'' ,bl.DIRECT,pv_tlid,bl.RETLID,
                                    PRETLID,'' ASSIGNTIME,'' EXECTIME,'' FOREFID,'' REFFOREFID,bl.ORGQUANTITY,bl.ORGPRICE,bl.ROOTORDERID,
                                    'C' edstatus, CASE WHEN bl.exectype = 'NB' THEN 'CB' WHEN bl.exectype = 'NS' THEN 'CS' ELSE 'CC' END edexectype
            FROM bl_odmast bl
            WHERE bl.blorderid = v_blorderid;


        end if;*/

        -- TheNN, 27-Feb-2014
        -- Neu lenh thi truong hoac lenh Auto chua day vao ODMAST thi ko cho phep huy
        if ((v_BLOdtype = '1') or (v_BLOdtype in ('2','3') and v_PriceType <> 'LO')) and (v_PTREMAINQTTY + v_SENTQTTY = 0 and v_STATUS <> 'T') then
            pv_err_code := '-700132';
            plog.error(pkgctx, 'Error:'  || pv_err_code
            );
            plog.setendsection(pkgctx, 'BL_MNGReject');
            RETURN;-- to_number(pv_err_code);
        end if;
        -- Ket thuc: TheNN, 27-Feb-2014
        if (v_BLOdtype in ('2','3')  and v_STATUS = 'C') then
            pv_err_code := '-700134';
            plog.error(pkgctx, 'Error:'  || pv_err_code
            );
            plog.setendsection(pkgctx, 'BL_MNGReject');
            RETURN;-- to_number(pv_err_code);
        end if;
        -- Neu lenh da xu ly het thi huy lenh con
        -- Huy tai F2: Lenh Manual hoac Any chua day het vao Flex thi ko huy phan chua day nay, cho phep dat tiep
        if not (v_BLOdtype in ('2','3','4','5') and pv_tlid <> '6868' and v_STATUS <> 'T') then
            IF v_REMAINQTTY + v_PTREMAINQTTY > 0 THEN
               /* pv_err_code := '-700117';
                plog.error(pkgctx, 'Error:'  || pv_err_code);
                plog.setendsection(pkgctx, 'BL_MNGPTBook');
                RETURN;-- to_number(pv_err_code);*/

                -- Neu lenh huy het thi cap nhat trong bl_odmastdtl
                if v_Quantity - (v_CancelQtty + v_REMAINQTTY + v_PTREMAINQTTY + v_ExecQtty) = 0 then
                    UPDATE bl_odmastdtl SET
                        pstatus = pstatus || status,
                        status = 'C',
                        cancelqtty = cancelqtty + v_REMAINQTTY + v_PTREMAINQTTY,
                        last_change = SYSTIMESTAMP
                    WHERE blorderid = v_blorderid AND exectype IN ('CB','CS');
                end if;

                -- Cap nhat vao bl_odmast
                UPDATE bl_odmast SET
                    pstatus = case when quantity - (cancelqtty + v_REMAINQTTY + v_PTREMAINQTTY + execqtty) = 0 then pstatus || status else pstatus end,
                    status = case when quantity - (cancelqtty + v_REMAINQTTY + v_PTREMAINQTTY + execqtty) = 0 then 'C' else status end,
                    cancelqtty = cancelqtty + v_REMAINQTTY + v_PTREMAINQTTY,
                    remainqtty = remainqtty - v_REMAINQTTY,
                    ptbookqtty = ptbookqtty - v_PTREMAINQTTY,
                    LAST_CHANGE = SYSTIMESTAMP
                WHERE autoid = v_BLAUTOID;


            END IF;
        end if;
        if v_STATUS = 'P' and v_BLOdtype = '3' Then
                UPDATE bl_odmast SET
                    pstatus = pstatus || status ,
                    status = 'C',
                    feedbackmsg = 'Cancelled by BMSC',
                    LAST_CHANGE = SYSTIMESTAMP
                WHERE autoid = v_BLAUTOID;
                pck_blg.Prc_Event('BLODMAST_RJ', v_blorderid, v_blorderid, null);
        end if;
        -- Cap nhat vao bang lenh Bloomberg
        --IF v_STATUS IN ('P','A') OR v_SENTQTTY = 0 THEN
            -- Lenh chua gan hoac chua xu ly thi huy bo het
            -- 05/11/2013: TheNN sua lai, cap nhat trang thai la C - Cancelled
           /* UPDATE bl_odmast SET
                pstatus = pstatus || status,
                status = 'C',
                cancelqtty = cancelqtty + v_REMAINQTTY + v_PTREMAINQTTY,
                remainqtty = remainqtty - v_REMAINQTTY,
                ptbookqtty = ptbookqtty - v_PTREMAINQTTY,
                LAST_CHANGE = SYSTIMESTAMP
            WHERE autoid = v_BLAUTOID;*/
        /*ELSE
            -- Lenh da xu ly thi huy bo phan con lai, ko cap nhat trang thai
            UPDATE bl_odmast SET
                cancelqtty = cancelqtty + v_REMAINQTTY + v_PTREMAINQTTY,
                remainqtty = remainqtty - v_REMAINQTTY,
                ptbookqtty = ptbookqtty - v_PTREMAINQTTY,
                LAST_CHANGE = SYSTIMESTAMP
            WHERE autoid = v_BLAUTOID;
        END IF;*/

        -- Ghi vao bang log

        INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
        VALUES (BL_LOG_SEQ.NEXTVAL,v_BLAUTOID,'REJECT','','',v_REMAINQTTY + v_PTREMAINQTTY,SYSTIMESTAMP,pv_tlid);

        -- Lay thong tin lenh y/c huy
        begin
           SELECT min(bt.via)
            INTO v_CancelVia
            FROM bl_odmastdtl bt
            WHERE bt.blorderid = v_blorderid AND bt.exectype IN ('CB','CS') AND bt.deltd = 'N';
        EXCEPTION
           WHEN OTHERS
             THEN
                v_CancelVia := 'F';
                plog.error (pkgctx, SQLERRM);
        end;

        -- Day y/c huy tung lenh con cua lenh tong da dat
        FOR ccrec IN
        (
            SELECT od.ORDERID,od.AFACCTNO,SE.SYMBOL,od.EXECTYPE,od.VIA, od.ORSTATUS, od.ORDERQTTY, od.REMAINQTTY, od.blorderid
            FROM ODMAST od, SBSECURITIES SE
            WHERE od.DELTD<>'Y' AND od.ORSTATUS IN ('8','2','4') AND od.ADJUSTQTTY=0 AND od.CANCELQTTY=0 AND  od.REMAINQTTY>0
                AND SE.CODEID = od.CODEID AND od.exectype NOT IN ('CB','CS','AB','AS')
                and case when od.PRICETYPE IN ('ATO','ATC') and se.tradeplace = '001' then 0 else 1 end = 1
                AND od.ORDERID NOT IN (SELECT REFORDERID FROM ODMAST WHERE REFORDERID IS NOT NULL AND orstatus NOT IN ('0','5'))
                AND od.blorderid = v_blorderid
        )
        LOOP
            -- Goi ham huy lenh, huy tung lenh con
            fopks_api.pr_PlaceOrder(P_FUNCTIONNAME=>'BLBCANCELORDER',
                                    P_USERNAME=>'',
                                    P_ACCTNO=>ccrec.orderid,
                                    P_AFACCTNO=>ccrec.afacctno,
                                    P_EXECTYPE=>'',
                                    P_SYMBOL=>'',
                                    P_QUANTITY=>0,
                                    P_QUOTEPRICE=>0,
                                    P_PRICETYPE=>'',
                                    P_TIMETYPE=>'',
                                    P_BOOK=>'A',
                                    P_VIA=>v_CancelVia,--'F',
                                    P_DEALID=>'',
                                    P_DIRECT=>'Y',
                                    P_EFFDATE=>'',
                                    P_EXPDATE=>'',
                                    P_TLID=>pv_tlid,
                                    P_QUOTEQTTY=>0,
                                    P_LIMITPRICE=>0,
                                    P_ERR_CODE=>v_err_code,
                                    P_ERR_MESSAGE=> v_err_msg,
                                    P_BLORDERID=>ccrec.blorderid);
            -- Log lai huy lenh
            INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
            VALUES (BL_LOG_seq.NEXTVAL,v_BLAUTOID,'CANCEL_OD',ccrec.orderid,v_err_code,0,SYSTIMESTAMP,pv_tlid);

        END LOOP;

    END LOOP;
    plog.setendsection(pkgctx, 'BL_MNGReject');

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('BL_MNGReject:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;


PROCEDURE bl_mngcomment (
   pv_BLORDERID       IN      VARCHAR2,
   pv_MNGCOMMENT    IN      VARCHAR2,
   pv_tlid          IN      VARCHAR2
)
IS
--
-- PURPOSE: CAP NHAT GHI CHU LENH
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_OldComment        varchar2(500);
BEGIN
    -- Lay thong tin cu
    SELECT bl.remngcomment
    INTO v_OldComment
    FROM bl_odmast bl
    WHERE autoid = pv_BLORDERID;
    -- Cap nhat vao bang lenh Bloomberg

    UPDATE bl_odmast SET
        REMNGCOMMENT = pv_MNGCOMMENT,
        LAST_CHANGE = SYSTIMESTAMP
    WHERE autoid = pv_BLORDERID;

    -- Ghi vao bang log

    INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
    VALUES (BL_LOG_seq.NEXTVAL,pv_BLORDERID,'MNGCOMMENT',v_OldComment,pv_MNGCOMMENT,0,SYSTIMESTAMP,pv_tlid);

    COMMIT;

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('bl_mngcomment:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;


PROCEDURE BL_MNGPTBook (
   pv_BLORDERID     IN      VARCHAR2,
   pv_ptbook        IN      VARCHAR2,
   pv_tlid          IN      VARCHAR2,
   pv_err_code      IN OUT  varchar2,
   p_err_message    IN OUT  varchar2
) --RETURN NUMBER
IS
--
-- PURPOSE: BOOK KHOI LUONG THOA THUAN
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_CurrPTBOOKQTTY    NUMBER;
    v_CurrPTSENTQTTY    NUMBER;
    v_QUANTITY          NUMBER;
    v_SENTQTTY          NUMBER;
    v_BLAUTOID          NUMBER;
    v_CANCELQTTY        NUMBER;
    v_REMAINQTTY        NUMBER;
    v_BLODTYPE          varchar2(2);
    v_PriceType         varchar2(10);
BEGIN
     --plog.error(pkgctx, 'Phuong_test' || pv_BLORDERID || '|' || pv_ptbook || '|' || pv_tlid);
    -- Lay du lieu hien tai
    plog.setbeginsection(pkgctx, 'BL_MNGPTBook');
    pv_err_code := systemnums.C_SUCCESS;
    SELECT bl.ptbookqtty, bl.ptsentqtty, bl.quantity, bl.sentqtty, BL.autoid, bl.cancelqtty, bl.remainqtty, bl.blodtype, bl.pricetype
    INTO v_CurrPTBOOKQTTY, v_CurrPTSENTQTTY, v_QUANTITY, v_SENTQTTY, v_BLAUTOID, v_CANCELQTTY, v_REMAINQTTY, v_BLODTYPE, v_PriceType
    FROM bl_odmast bl
    WHERE BLORDERID = pv_BLORDERID;

    -- TheNN, 27-Feb-2014
    -- Neu lenh thi truong hoac lenh Auto chua day vao ODMAST thi ko cho phep book TT
    if (v_BLOdtype = '1') or (v_BLODTYPE in ('2','3') and v_PriceType <> 'LO') then
        pv_err_code := '-700133';
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || pv_err_code);
        plog.setendsection(pkgctx, 'BL_MNGPTBook');
        RETURN;-- to_number(pv_err_code);
    end if;
    -- Ket thuc: TheNN, 27-Feb-2014

    -- Kiem tra xem SL moi update co phu hop hay khong
    -- SL book moi ko dc nho hon SL da dat TT
    IF v_CurrPTSENTQTTY > to_number(pv_ptbook) THEN
        pv_err_code := '-700113';
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_MNGPTBook');
        RETURN;-- to_number(pv_err_code);
    END IF;

    -- SL book moi ko dc vuot qua SL con lai cua lenh
    IF v_QUANTITY - v_SENTQTTY - v_CANCELQTTY < to_number(pv_ptbook) THEN
        pv_err_code := '-700114';
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_MNGPTBook');
        RETURN;-- to_number(pv_err_code);
    END IF;

    -- Neu lenh Any da chuyen sang Direct thi ko cho phep thay doi nua
    IF v_BLODTYPE = '2' AND v_REMAINQTTY = 0 THEN
        pv_err_code := '-700123';
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_MNGPTBook');
        RETURN;-- to_number(pv_err_code);
    END IF;

    -- Cap nhat vao bang lenh Bloomberg

    /*UPDATE bl_odmast SET
        PTBOOKQTTY = PTBOOKQTTY + to_number(pv_ptbook),
        remainqtty = remainqtty - to_number(pv_ptbook),
        LAST_CHANGE = SYSTIMESTAMP
    WHERE autoid = pv_BLORDERID;*/

    UPDATE bl_odmast SET
        remainqtty = remainqtty - (to_number(pv_ptbook) - v_CurrPTBOOKQTTY),
        PTBOOKQTTY = to_number(pv_ptbook),
        LAST_CHANGE = SYSTIMESTAMP
    WHERE BLORDERID = pv_BLORDERID;

    -- Ghi vao bang log

    INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
    VALUES (BL_LOG_seq.NEXTVAL,v_BLAUTOID,'PTBOOK',to_char(v_CurrPTBOOKQTTY),pv_ptbook,to_number(pv_ptbook)- v_CurrPTBOOKQTTY,SYSTIMESTAMP,pv_tlid);

    --COMMIT;

    --RETURN systemnums.C_SUCCESS;
     if p_err_message is null then
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
    end if;
    plog.setendsection(pkgctx, 'BL_MNGPTBook');

EXCEPTION
   WHEN OTHERS
   THEN
      pv_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'BL_MNGPTBook');
      dbms_output.put_line('BL_MNGPTBook:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);

END;

FUNCTION fnc_check_blb_placeOrder
 (p_blOrderid IN Varchar2,
  p_dblQtty in number,-- Kl cua lenh con
  p_strExectype in varchar2,
  p_orderprice in  number,
  p_dblExecQtty  in number default 0, -- tham so dung cho TH map lenh: KL da khop cua lenh can map
  p_dblExecAmt   in number default 0,-- tham so dung cho TH map lenh: Amount da khop cua lenh can map
  p_strMatchtype in varchar2 default 'N')
RETURN  number IS
    v_Return number;
    v_strBlOrderid    varchar2(30);
    v_dblQtty      number(20,0);
    v_strExectype  varchar2(5);
    v_dblPrice     number(20,4);
    v_dblExecqtty  number(20,0);
    v_dblExecamt   number(20,0);
    v_dblRemainqtty number(20,0);
    l_dblTradeUnit  number(20,0);
    l_dblorderprice number(20,4);
    l_codeid        varchar2(6);
    v_dbl_Od_ExecAmt number(20,0);
    v_dbl_Od_ExecQtty number(20,0);
    l_matchtype       varchar2(3);
    l_ptBookQtty      number(20,0);
    l_ptSentQtty      number(20,0);
    l_avgPrice        number(20,3);
    l_BlPriceType     varchar2(10);
    l_odSumRemainQtty  number;
    l_odSumAdExecAmt     number;
    L_AMT_PLACEORDER NUMBER(20,0);
    L_AMT_CHECK NUMBER(20,0);
    L_BLODTYPE  VARCHAR2(5);
    l_Status    varchar2(10);
BEGIN
       v_strBlOrderid:=p_blOrderid;
       v_dblQtty:=p_dblQtty;
       v_strExectype:=p_strExectype;
       -- tham so dung cho map lenh
       v_dbl_Od_ExecAmt:=p_dblExecAmt;
       v_dbl_Od_ExecQtty:=p_dblExecQtty;
       l_matchtype:=p_strMatchtype;
       l_dblTradeUnit:=1000;
       -- end of tham so dung cho map lenh
       -- lay ra cac thong tin cua lenh tong BloomBerg
       select price,execqtty,execamt,remainqtty,codeid,ptbookqtty,ptsentqtty,pricetype,BLODTYPE,status
       into v_dblPrice,v_dblExecqtty,v_dblExecamt,v_dblRemainqtty,l_codeid,l_ptBookQtty,l_ptSentQtty,l_BlPriceType,L_BLODTYPE, l_Status
       from bl_odmast od where od.blorderid=v_strBlOrderid;
       --PhuongHT edit: 27.02.2014: lenh thi truong tu tren BloomBerg xuong thi ko duoc dat tu F2
       IF (L_BLODTYPE IN ('1','2','3') AND l_BlPriceType <> 'LO' and l_Status <> 'T') THEN
                   v_Return:=-700131;
                   Return v_Return;
       END IF;
       -- end of PhuongHT edit: 27.02.2014: lenh thi truong tu tren BloomBerg xuong thi ko duoc dat tu F2
       -- end if;
       --select tradeunit into l_dblTradeUnit from securities_info where codeid=l_codeid;
       -- gia dat de tinh gia trung binh:
       --NB:max(giact,gia dat)
       --sell: min(gia ct,gia dat)
       if v_strExectype ='NB' then
         l_dblorderprice := greatest(p_orderprice,v_dblPrice) ;
       else
         l_dblorderprice := least(p_orderprice,v_dblPrice) ;
       end if;
           -- lay ra gia tri con lai cua lenh chua khop
        begin
            select nvl(sum(remainqtty),0) ,
            nvl(sum(remainqtty *
                (case when exectype ='NB' then greatest(quoteprice,v_dblPrice*l_dblTradeUnit)
                 else least(quoteprice,v_dblPrice*l_dblTradeUnit) end)),0)
            into l_odSumRemainQtty,l_odSumAdExecAmt
            from odmast
            where exectype not in ('AB','AS','CB','CS')
            and nvl(blorderid,'a') =v_strBlOrderid;
        exception
        when others then
             l_odSumRemainQtty:=0;
             l_odSumAdExecAmt:=0;
        end;

       -- check khoi luong con lai cua lenh tong
       /*if ((p_dblQtty >v_dblRemainqtty and l_matchtype='N') or (p_dblQtty >(l_ptBookQtty-l_ptSentQtty) and l_matchtype='P'))  then
          v_Return:=-700112;
           Return v_Return;
       end if;*/
       -- check gia trung binh: ban: gia >=gia chi thi
                          --  mua: gia <=gia chi thi

           --l_avgPrice:=round((v_dblPrice *(p_dblQtty+v_dblExecqtty)- v_dblExecamt/l_dblTradeUnit-v_dbl_Od_ExecAmt/l_dblTradeUnit)/( p_dblQtty-v_dbl_Od_ExecQtty),3 );
          -- su dung bien L_AMT_PLACEORDER,L_AMT_CHECK check de tranh sai so
          -- l_avgPrice:=round(((v_dblExecamt+v_dbl_Od_ExecAmt+l_odSumAdExecAmt+l_dblorderprice*l_dblTradeUnit*(p_dblQtty-v_dbl_Od_ExecQtty))/((v_dblExecqtty+p_dblQtty+l_odSumRemainQtty)*l_dblTradeUnit)),3);
           L_AMT_PLACEORDER:=(v_dblExecamt+v_dbl_Od_ExecAmt+l_odSumAdExecAmt+l_dblorderprice*l_dblTradeUnit*(p_dblQtty-v_dbl_Od_ExecQtty));
           L_AMT_CHECK:=v_dblPrice*((v_dblExecqtty+p_dblQtty+l_odSumRemainQtty)*l_dblTradeUnit);
           --plog.error(pkgctx,'Map lenh: ' ||v_dblExecamt||',l_odSumAdExecAmt:' || l_odSumAdExecAmt||',l_dblorderprice:' || l_dblorderprice|| ',' || v_dblExecqtty || ',' || p_dblQtty  || ',' || l_odSumRemainQtty );
           /*if  (v_strExectype ='NB')  then
              -- if  v_dblPrice < l_avgPrice then
               if  L_AMT_CHECK < L_AMT_PLACEORDER then
                   v_Return:=-700110;
                   Return v_Return;
               end if;
           elsif (v_strExectype in  ('NS','MS')) then
              --if v_dblPrice > l_avgPrice THEN
              if  L_AMT_CHECK > L_AMT_PLACEORDER then
                   v_Return:=-700111;
                   Return v_Return;
               end if;
           end if;*/


Return v_Return;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

-- Ham check chung truoc khi dat hoac sua lenh BloomBerg
PROCEDURE pr_bl_Check
 (p_ActionFlag IN Varchar2,
  p_blOrderid in varchar2,-- Kl cua lenh con
  p_quantity in varchar2,
  p_side  in varchar2,
  p_price   in varchar2,
  p_CurrentOrderId    in varchar2,
  p_Via     in  varchar2,
  p_err_code out varchar2,
  p_err_message out VARCHAR2)
IS
v_price number(20,3);
p_str_err_code number;
v_dblQuantity  number;
BEGIN
        plog.setbeginsection(pkgctx, 'pr_bl_Check');
        p_err_code := systemnums.C_SUCCESS;
        v_price:=round(to_number(p_price)/1000,3);
        v_dblQuantity:=to_number(p_quantity);
        if (p_ActionFlag='BLBPLACEORDER') then
              p_err_code:= fnc_check_blb_placeOrder(p_blOrderid,p_quantity,p_side,v_price);
        elsif (p_ActionFlag='BLBAMENDMENTORDER') then
              p_str_err_code:= fnc_check_blb_AmendmentOrder
              (p_blOrderid,
              v_dblQuantity,
              p_side,
              v_price,
              p_CurrentOrderId,
              p_ActionFlag,
              p_Via);
              p_err_code:=to_char(p_str_err_code);
        end if;

        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.setendsection(pkgctx, 'pr_bl_Check');
EXCEPTION
   WHEN OTHERS THEN
    PLOG.ERROR(pkgctx,'CHECK BL: exception: ' || p_blOrderid ||' , '|| v_dblQuantity ||','|| p_sidE|| ',' ||v_price ||',' ||p_CurrentOrderId || ',' ||p_ActionFlag);
    plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    p_err_code:=-1;
    plog.setendsection(pkgctx, 'pr_bl_Check');
END;

FUNCTION fnc_check_blb_AmendmentOrder
 (p_blOrderid IN Varchar2,
  p_dblQtty in number,-- Kl cua lenh con
  p_strExectype in varchar2,
  p_orderprice in number,
  p_acctno in varchar2,
  p_functioname in varchar2,
  p_AmendVia    in  varchar2)
RETURN  number IS
    v_Return number;
    v_strBlOrderid    varchar2(30);
    v_dblQtty      number(20,0);
    v_strExectype  varchar2(5);
    v_dblPrice     number(20,4);
    v_dblExecqtty  number(20,0);
    v_dblExecamt   number(20,0);
    v_dblRemainqtty number(20,0);
    l_dblTradeUnit  number(20,0);
    l_dblorderprice number(20,4);
    l_codeid        varchar2(6);

    l_matchtype       varchar2(3);
    l_ptBookQtty      number(20,0);
    l_ptSentQtty      number(20,0);
    l_avgPrice        number(20,3);
    v_dbl_Od_ExecAmt  number;
    v_dbl_Od_ExecQtty number;
    v_old_orderqtty   number;
    l_odSumRemainQtty  number;
    l_odSumAdExecAmt     number;
    l_blodtype      varchar2(10);
    l_isnotBLauto      NUMBER := 0;
    L_AMT_PLACEORDER NUMBER(20,0);
    L_AMT_CHECK NUMBER(20,0);
BEGIN

       plog.setbeginsection(pkgctx, 'fnc_check_blb_AmendmentOrder');
       v_Return:=systemnums.C_SUCCESS;
        --PLOG.ERROR(pkgctx,'CHECK BL:call ham con: ');
       v_strBlOrderid:=p_blOrderid;
       v_dblQtty:=p_dblQtty;
       l_dblTradeUnit:=1000;
       --v_strExectype:=p_strExectype;

       -- end of tham so dung cho map lenh
       -- lay ra cac thong tin cua lenh tong BloomBerg

       select price,execqtty,execamt,remainqtty,codeid,ptbookqtty,ptsentqtty,od.blodtype, decode(od.blodtype,'1',0,1)
       into v_dblPrice,v_dblExecqtty,v_dblExecamt,v_dblRemainqtty,l_codeid,l_ptBookQtty,l_ptSentQtty,l_blodtype,l_isnotBLauto
       from bl_odmast od where od.blorderid=v_strBlOrderid;

       -- Lenh auto va sua tu Bloomberg thi ko check
       IF l_blodtype = '1' and p_AmendVia = 'L'  THEN
            Return v_Return;
       else
            --select tradeunit into l_dblTradeUnit from securities_info where codeid=l_codeid;
           select orderqtty,execqtty,execamt,exectype
           into v_old_orderqtty,v_dbl_Od_ExecQtty,v_dbl_Od_ExecAmt,v_strExectype
           from odmast where orderid=p_acctno;
           -- gia dat de tinh gia trung binh:
           --NB:max(giact,gia dat)
           --sell: min(gia ct,gia dat)
           if v_strExectype ='NB' then
             l_dblorderprice := greatest(p_orderprice,v_dblPrice) ;
           else
             l_dblorderprice := least(p_orderprice,v_dblPrice) ;
           end if;
           -- check khoi luong con lai cua lenh tong

           /*if ((p_dblQtty - v_old_orderqtty)>v_dblRemainqtty )  then
              v_Return:=-700112;
               Return v_Return;
           end if;*/
            -- lay ra gia tri con lai cua lenh chua khop: khong bao gom lenh dang sua

           begin
                 select nvl(sum(remainqtty),0),
                 nvl(sum(remainqtty *
                    (case when exectype ='NB' then greatest(quoteprice,v_dblPrice*l_dblTradeUnit)
                     else least(quoteprice,v_dblPrice*l_dblTradeUnit) end)),0)
                 into l_odSumRemainQtty,l_odSumAdExecAmt
                 from odmast
                 where exectype not in ('AB','AS','CB','CS')
                 and nvl(blorderid,'a') =v_strBlOrderid
                 and orderid <> p_acctno;
            exception
            when others then
                 l_odSumRemainQtty:=0;
                 l_odSumAdExecAmt:=0;
            end;
           -- check gia trung binh: ban: gia >=gia chi thi
                              --  mua: gia <=gia chi thi

               l_avgPrice:=round(((v_dblExecamt*l_isnotBLauto+l_odSumAdExecAmt+l_dblorderprice*l_dblTradeUnit*(p_dblQtty-v_dbl_Od_ExecQtty))/((v_dblExecqtty*l_isnotBLauto+l_odSumRemainQtty+p_dblQtty-v_dbl_Od_ExecQtty)*l_dblTradeUnit)),3);
               -- su dung bien L_AMT_PLACEORDER,l_amt_check de tranh sai so
               L_AMT_PLACEORDER:=(v_dblExecamt*l_isnotBLauto+l_odSumAdExecAmt+l_dblorderprice*l_dblTradeUnit*(p_dblQtty-v_dbl_Od_ExecQtty));
               L_AMT_CHECK:=v_dblPrice*((v_dblExecqtty*l_isnotBLauto+l_odSumRemainQtty+p_dblQtty-v_dbl_Od_ExecQtty)*l_dblTradeUnit);
               /*if  (v_strExectype ='NB')  then
                   --if  v_dblPrice < l_avgPrice THEN
                   if  L_AMT_CHECK < L_AMT_PLACEORDER then
                       v_Return:=-700110;
                       Return v_Return;
                   end if;
               elsif (v_strExectype in ('NS','MS')) then
                  --if v_dblPrice > l_avgPrice then
                   if  L_AMT_CHECK > L_AMT_PLACEORDER then
                       v_Return:=-700111;
                       Return v_Return;
                   end if;
               end if;*/
       --ELSE
       --     Return v_Return;
       END IF;

       plog.setendsection(pkgctx, 'fnc_check_blb_AmendmentOrder');

Return v_Return;
EXCEPTION
   WHEN OTHERS THEN
    plog.setendsection(pkgctx, 'fnc_check_blb_AmendmentOrder');
    RETURN 0;

END;

FUNCTION BL_GetRETLID (
   pv_BLORDERID     IN      VARCHAR2
) RETURN VARCHAR2
IS
--
-- PURPOSE: LAY MOI GIOI GAN CHO LENH
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   18-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_CurrPTBOOKQTTY    NUMBER;
    v_Afacctno      varchar2(10);
    v_Blodtype      varchar2(1);
    v_Symbol        varchar2(20);
    v_Exectype      varchar2(5);
    v_Pricetype     varchar2(5);
    v_Quantity      NUMBER;
    v_Txdate        DATE;
    v_Count         NUMBER;
    v_RuleCheck     NUMBER;
    v_ReCheck       NUMBER;
    v_SecCount      NUMBER;
    v_RETLID        varchar2(10);
    v_RENonRule     varchar2(100);
    v_CurrPCQTTY    NUMBER;
BEGIN
    -- Lay thong tin lenh
    SELECT od.afacctno, od.blodtype, od.symbol, od.exectype, od.pricetype, od.quantity, od.txdate
    INTO v_Afacctno, v_Blodtype, v_Symbol, v_Exectype, v_Pricetype, v_Quantity, v_Txdate
    FROM bl_odmast od
    WHERE od.blorderid = pv_BLORDERID;

    -- Tinh toan de lay ra ma moi gioi phu hop nhat
    -- Thu tu uu tien:
    -- 1. So thu tu uu tien cua cac moi gioi gan cho khach hang
    -- 2. Kiem tra cac luat dinh tuyen dc gan cho moi gioi
    -- 3. Neu ko thoa man moi gioi  dinh tuyen thi gan cho MG ma hien tai co SL xu ly trong ngay it nhat
    ------------------------------------------------

    -- Lay danh sach moi gioi co the xu ly lenh cho tieu khoan nay
    -- Xem co MG nao dc gan xu ly lenh cho tieu khoan nay hay khong
    return '';
    /*SELECT COUNT(*)
    INTO v_Count
    FROM bl_recustref cff
    WHERE cff.afacctno = v_Afacctno;

    IF v_Count > 0 THEN
        v_RENonRule := '';
        -- Lay danh sach moi gioi co the xu ly lenh cho tieu khoan nay
        <<re_loop>>
        FOR rec IN
        (
            SELECT cff.retlid, cff.priority
            FROM bl_recustref cff
            WHERE cff.afacctno = v_Afacctno AND cff.status = 'A'
            ORDER BY cff.priority
        )
        LOOP

            v_RETLID := rec.retlid;
            -- Kiem tra luat dinh tuyen dc gan cho MG
            v_Count := 0;
            SELECT COUNT(*)
            INTO v_Count
            FROM bl_reruleref rlf
            WHERE rlf.retlid = rec.retlid;
            IF v_Count >0 THEN
                -- Lay thong tin luat dinh tuyen de check
                <<rule_loop>>
                FOR rl IN
                (
                    SELECT rl.ruleid, rl.exectype, rl.pricetype, rl.securities, rl.odqttymax
                    FROM bl_rerule rl, bl_reruleref rlf
                    WHERE rl.ruleid = rlf.reruleid AND rlf.retlid = rec.retlid
                    ORDER BY rlf.priority
                )
                LOOP
                    -- Check luat
                    -- Check Loai lenh
                    IF instr(rl.exectype, v_Exectype) > 0 THEN
                        -- Check CK
                        IF rl.securities = 'ALL' THEN
                            v_RuleCheck := 1;
                        ELSE
                            SELECT count(bs.symbol)
                            INTO v_SecCount
                            FROM bl_resec bs
                            WHERE bs.symbol = v_Symbol AND bs.reruleid = rl.ruleid;
                            IF v_SecCount >0 THEN
                                v_RuleCheck := 1;
                            ELSE
                                v_RuleCheck := 0;
                            END IF;
                        END IF;
                        -- Check KL xu ly trong ngay
                        IF v_RuleCheck = 1 THEN
                            SELECT nvl(sum(od.quantity),0)
                            INTO v_CurrPCQTTY
                            FROM bl_odmast od
                            WHERE od.txdate = v_Txdate AND od.retlid = v_RETLID AND od.blodtype IN ('2','3');
                            IF v_CurrPCQTTY + v_Quantity <= rl.odqttymax THEN
                                v_RuleCheck := 1;
                            ELSE
                                v_RuleCheck := 0;
                            END IF;
                        END IF;
                    ELSE
                        v_RuleCheck := 0;
                    END IF;
                    -- Neu match luat thi dung lai
                    IF v_RuleCheck = 1 THEN
                        v_ReCheck := 1;
                        EXIT rule_loop;
                    ELSE
                        v_ReCheck := 0;
                    END IF;
                END LOOP rule_loop;

                -- Neu match luat check thi thoat vong lap
                IF v_ReCheck = 1 THEN
                    EXIT re_loop;
                END IF;
            ELSE*/
                -- Neu ko gan luat thi chuyen sang MG tiep theo
                /*if LENGTH(v_RENonRule) > 0 then
                    v_RENonRule := v_RENonRule || '|' || v_RETLID;
                else
                    v_RENonRule := v_RETLID;
                end if;
                v_ReCheck := 2;*/
                -- Sua lai: Neu ko gan luat thi lay MG do
               /* RETURN v_RETLID || '|Y';
            END IF;
        END LOOP re_loop;
        -- Neu match luat check va co rule thi lay MG do
        IF v_ReCheck = 1 THEN
            RETURN v_RETLID || '|Y';
        ELSE -- Neu ko match ma co MG ko gan luat thi lay MG ko gan luat co uu tien cao nhat
            IF LENGTH(v_RENonRule) > 0 AND instr(v_RENonRule,'|') > 0 THEN
                RETURN substr(v_RENonRule,1,instr(v_RENonRule,'|')-1) || '|Y';
            ELSIF LENGTH(v_RENonRule) > 0 THEN
                RETURN v_RENonRule || '|Y';
            ELSE
                -- Neu ko match rule nao thi gan cho MG hien tai co SL xu ly trong ngay it nhat
                SELECT nvl(re.retlid,'0001')
                INTO v_RETLID
                FROM
                    (
                    SELECT re.retlid, nvl(od.pcqtty,0)
                    FROM
                        (
                        SELECT cff.retlid FROM bl_recustref cff
                        WHERE cff.afacctno = v_Afacctno AND cff.status = 'A'
                        ) re
                    LEFT JOIN
                        (
                        SELECT od.retlid, sum(od.quantity) PCQTTY
                        FROM bl_odmast od
                        WHERE od.txdate = v_Txdate AND od.blodtype IN ('2','3')
                        GROUP BY od.retlid
                    ) od
                    ON re.retlid = od.retlid
                    ORDER BY nvl(od.pcqtty,0), re.retlid
                    ) re
                WHERE ROWNUM = 1;

                RETURN v_RETLID || '|N';
            END IF;
        END IF;
    ELSE
        -- Neu khong co thi de trong de MG quan ly tu gan
        RETURN '';
    END IF;*/

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('BL_getretlid:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN '';
END;


PROCEDURE BL_MapOrder (
   pv_BLORDERID     IN      VARCHAR2,
   pv_Orderid       IN      VARCHAR2,
   pv_tlid          IN      VARCHAR2,
   pv_err_code      IN OUT  varchar2,
   p_err_message    IN OUT  varchar2
) --RETURN NUMBER
IS
l_execqtty number(20,0);
l_execamt number(20,0);
l_orderqtty number(20,0);
l_blOrderid varchar2(30);
l_exectype varchar2(5);
l_orderprice       number(20,3);
l_tradeunit        number(20,0);
l_codeid           varchar2(6);
l_orderid          varchar2(30);
l_blStatus         varchar2(5);
l_matchType        varchar2(1);
l_OdBlOrderid      varchar2(30);
l_blAutoid         number(20);
l_odPricetype      varchar2(5);
l_blPricetype      varchar2(5);
L_ODREMAINQTTY     number(20,0);
v_buf_edstatus     varchar2(2);
v_buf_remainqtty   number(20,0);
v_bl_status        varchar2(2);
l_count             NUMBER;
v_BLOdtype          VARCHAR2(10);

--
-- PURPOSE: Map lenh thuong vao lenh BloomBerg
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- PhuongHT   20-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
    plog.setbeginsection(pkgctx, 'BL_MapOrder');
    pv_err_code := systemnums.C_SUCCESS;
    l_orderid:=pv_Orderid;
    l_blOrderid:=pv_BLORDERID;
    select autoid,pricetype ,status, blodtype
    into l_blAutoid,l_blPricetype,v_bl_status, v_BLOdtype
    from bl_odmast where blorderid=l_blOrderid;

    -- TheNN, 27-Feb-2014
    -- Neu lenh thi truong hoac lenh Auto chua day vao ODMAST thi ko cho phep map
    if (v_BLOdtype = '1') or (v_BLODTYPE in ('2','3') and l_blPricetype <> 'LO') then
        pv_err_code := '-700133';
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || pv_err_code);
        plog.setendsection(pkgctx, 'BL_MNGPTBook');
        RETURN;-- to_number(pv_err_code);
    end if;
    -- Ket thuc: TheNN, 27-Feb-2014

    -- Lay du lieu cua lenh can map
    select execqtty,execamt,orderqtty ,exectype,codeid,quoteprice,matchtype,blorderid,pricetype,REMAINQTTY
    into l_execqtty,l_execamt,l_orderqtty,l_exectype,l_codeid,l_orderprice,l_matchtype,l_OdBlOrderid,l_odPricetype,L_ODREMAINQTTY
    from odmast where orderid=l_orderid;
    select edstatus,remainqtty
    into v_buf_edstatus,v_buf_remainqtty
    from buf_od_account
    where orderid=l_orderid;
    select tradeunit into l_tradeunit from securities_info where codeid=l_codeid;
    l_orderprice:=round(l_orderprice/l_tradeunit,3);

    -- Check lenh map va lenh tong phai cung pricetype
     if  (l_blPricetype <> l_odPricetype and l_blPricetype <> 'LO')  then
            pv_err_code:='-700121';
            p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
         end if;
     -- check lenh can map khong duoc trong trang thai dang sua,dang huy
     if  (v_buf_remainqtty >0 and v_buf_edstatus in ('A','C'))  then
            pv_err_code:=-700125;
            p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
     end if;
     -- khong map/huy map voi cac lenh tong da huy
     if  (v_bl_status='C')  then
            pv_err_code:=-700126;
            p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
     end if;
    -- Check Lenh phai chua map voi lenh nao
    if nvl(l_OdBlOrderid,'a') <> 'a' then
        pv_err_code:=-700115;
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_MapOrder');
        RETURN;-- to_number(pv_err_code);
    end if;
    -- Kiem tra xem SL moi update co phu hop hay khong
    pv_err_code:=fnc_check_blb_placeOrder(l_blOrderid,l_orderqtty,l_exectype,l_orderprice,l_execqtty,l_execamt,l_matchType);
    IF  pv_err_code<> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_MapOrder');
        RETURN;-- to_number(pv_err_code);
    END IF;
    -- Kiem tra neu lenh da map/huy map ma co khop lenh thi ko cho phep map nua
    SELECT count(*)
    INTO l_count
    FROM BL_MapOrder bl
    WHERE bl.blorderid = l_blOrderid AND bl.orderid = l_orderid;
    IF l_count >0 THEN
        pv_err_code:='-700130';
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_MapOrder');
        RETURN;-- to_number(pv_err_code);
    END IF;

    -- Map lenh trong odmast,fomast voi lenh trong bl_odmast
    update odmast set blorderid=l_blOrderid where orderid=l_orderid;
    update fomast set blorderid=l_blOrderid where orgacctno=l_orderid;
    --fopks_api.pr_gen_buf_od_account(l_orderid);
    --update buf_od_account set blorderid=l_blOrderid where orderid=l_orderid;
    select status into l_blstatus from bl_odmast where blorderid=l_blOrderid;
    -- update trang thai neu la lenh ODMAST status='A'
    if l_blStatus='A' then
       update bl_odmast set pstatus=pstatus||status,status='F' where blorderid=l_blOrderid;
    end if;
    -- neu la lenh thuong
    if(l_matchType='N') then
        update bl_odmast set
            execqtty=execqtty+l_execqtty,
            execamt=execamt+l_execamt,
            remainqtty=remainqtty-L_ODREMAINQTTY-l_execqtty,
            sentqtty=sentqtty+L_ODREMAINQTTY+l_execqtty,
            last_change=systimestamp,
            pstatus = case when status in ('T') then pstatus || status else pstatus end,
            status = case when status in ('T') then 'F' else status end
        where blorderid=l_blOrderid;
    else-- lenh thoa thuan
        update bl_odmast set
            execqtty=execqtty+l_execqtty,
            execamt=execamt+l_execamt,
            ptsentqtty=ptsentqtty+L_ODREMAINQTTY+l_execqtty,
            last_change=systimestamp,
            pstatus = case when status in ('T') then pstatus || status else pstatus end,
            status = case when status in ('T') then 'F' else status end
        where blorderid=l_blOrderid;
    end if;
  -- Ghi vao bang log
        INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
        VALUES (BL_LOG_seq.NEXTVAL,l_blAutoid,'MAPORDER','',to_char(l_execamt),l_orderqtty,SYSTIMESTAMP,pv_tlid);


    --RETURN systemnums.C_SUCCESS;
     if p_err_message is null then
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
    end if;
    plog.setendsection(pkgctx, 'BL_MapOrder');

EXCEPTION
   WHEN OTHERS
   THEN
      pv_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'BL_MapOrder');
      dbms_output.put_line('BL_MapOrder:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);

END;

PROCEDURE BL_UnMapOrder (
   pv_BLORDERID     IN      VARCHAR2,
   pv_Orderid       IN      VARCHAR2,
   pv_tlid          IN      VARCHAR2,
   pv_err_code      IN OUT  varchar2,
   p_err_message    IN OUT  varchar2
) --RETURN NUMBER
IS
l_execqtty number(20,0);
l_execamt number(20,0);
l_orderqtty number(20,0);
l_blOrderid varchar2(30);
l_exectype varchar2(5);
l_orderprice       number(20,3);
l_tradeunit        number(20,0);
l_codeid           varchar2(6);
l_orderid          varchar2(30);
l_blStatus         varchar2(5);
l_matchType        varchar2(1);
l_OdBlOrderid      varchar2(30);
l_sentqtty       number(20,0);
l_ptsentqtty     number(20,0);
l_avgprice       number(20,3);
l_blprice        number(20,3);
l_blexecqty      number(20,0);
l_blexecamt      number(20,0);
l_blAutoid      number(20);
l_isBlorder     varchar2(1);
l_count         number;
l_odSumRemainQtty  number;
l_odSumAdExecAmt     number;
l_remainqtty         number(20);
v_buf_edstatus     varchar2(2);
v_buf_remainqtty   number(20,0);
v_bl_status        varchar2(2);
--
-- PURPOSE: Huy Map lenh thuong, thoa thuan cua lenh BloomBerg
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- PhuongHT   20-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
    plog.setbeginsection(pkgctx, 'BL_UnMapOrder');
    pv_err_code := systemnums.C_SUCCESS;
    l_orderid:=pv_Orderid;
    l_blOrderid:=pv_BLORDERID;
    l_count:=0;
    -- Lay du lieu cua lenh can huy map ODMAST
    select execqtty,execamt,orderqtty ,exectype,codeid,quoteprice,matchtype,blorderid,nvl(isblorder,'a'),remainqtty
    into l_execqtty,l_execamt,l_orderqtty,l_exectype,l_codeid,l_orderprice,l_matchtype,l_OdBlOrderid,l_isblorder,l_remainqtty
    from odmast where orderid=l_orderid;
    select tradeunit into l_tradeunit from securities_info where codeid=l_codeid;
    -- buf_od_account
    select edstatus,remainqtty
    into v_buf_edstatus,v_buf_remainqtty
    from buf_od_account
    where orderid=l_orderid;
    l_orderprice:=round(l_orderprice/l_tradeunit,3);
    -- lay thong tin ve lenh tong BL_ODMAST
    select price,execqtty,execamt,autoid,status
    into l_blprice,l_blexecqty,l_blexecamt,l_blAutoid,v_bl_status
    from bl_odmast
    where blorderid=l_blOrderid;
    -- Check Lenh phai chua map voi lenh nao
    if nvl(l_OdBlOrderid,'a') <> l_blOrderid then
        pv_err_code:=-700119;
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_UnMapOrder');
        RETURN;-- to_number(pv_err_code);
    end if;
        -- Check Lenh phai la lenh khong pai lenh con dat truc tiep
    if l_isblorder = 'Y' then
        pv_err_code:=-700120;
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'BL_UnMapOrder');
        RETURN;-- to_number(pv_err_code);
    end if;
      -- khong map/huy map voi cac lenh tong da huy
     if  (v_bl_status='C')  then
            pv_err_code:=-700126;
            p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
     end if;
       -- check lenh can map khong duoc trong trang thai dang sua,dang huy
     if  (v_buf_remainqtty >0 and v_buf_edstatus in ('A','C'))  then
            pv_err_code:=-700125;
            p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
     end if;

     -- lay ra gia tri con lai cua lenh chua khop
    begin
          select nvl(sum(remainqtty),0) ,
          nvl(sum(remainqtty *
            (case when exectype ='NB' then greatest(quoteprice,l_blprice*1000)
             else least(quoteprice,l_blprice*1000) end)),0)
          into l_odSumRemainQtty,l_odSumAdExecAmt
          from odmast
          where exectype not in ('AB','AS','CB','CS')
          and nvl(blorderid,'a') =l_blOrderid
          and  orderid <> l_orderid;
    exception
    when others then
         l_odSumRemainQtty:=0;
         l_odSumAdExecAmt:=0;
    end;


    -- Kiem tra xem sau khi huy map thi gia trung binh co con hop le khong
    if (l_blexecqty-l_execqtty > 0) then
          l_avgPrice:=round(((l_odSumAdExecAmt+l_blexecamt-l_execamt)/((l_odSumRemainQtty+l_blexecqty-l_execqtty)*1000)),3);
               /*if  (l_exectype ='NB')  then
                   if  l_blPrice < l_avgPrice then
                       pv_err_code:=-700110;
                   end if;
               elsif (l_exectype in ('NS','MS')) then
                  if l_blPrice > l_avgPrice then
                       pv_err_code:=-700111;
                   end if;
               end if;*/

    else --
         if  (l_exectype ='NB')  then
             select count(*) into l_count from odmast where blorderid=l_blOrderid and quoteprice > l_blPrice*1000
             and orderid <> l_orderid;
             /*if l_count > 0 then
                pv_err_code:=-700110;
             end if;*/
         elsif  (l_exectype in ('NS','MS')) then
             select count(*) into l_count from odmast where blorderid=l_blOrderid and quoteprice < l_blPrice*1000
              and orderid <> l_orderid;
             /*if l_count > 0 then
                pv_err_code:=-700111;
             end if;*/
         end if;

    end if;
        IF  pv_err_code<> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'BL_UnMapOrder');
            RETURN;-- to_number(pv_err_code);
        END IF;


    -- Huy Map lenh trong odmast,fomast voi lenh trong bl_odmast
    update odmast set blorderid='' where orderid=l_orderid;
    update fomast set blorderid='' where orgacctno=l_orderid;
    --fopks_api.pr_gen_buf_od_account(l_orderid);
    --update buf_od_account set blorderid='' where orderid=l_orderid;

    -- neu la lenh thuong
    if(l_matchType='N') then
        update bl_odmast set
        execqtty=execqtty-l_execqtty,
        execamt=execamt-l_execamt,
        remainqtty=remainqtty+l_remainqtty+l_execqtty,
        sentqtty=sentqtty-l_remainqtty-l_execqtty,
        last_change=systimestamp
        where blorderid=l_blOrderid;
    else-- lenh thoa thuan
        update bl_odmast set
        execqtty=execqtty-l_execqtty,
        execamt=execamt-l_execamt,
        ptsentqtty=ptsentqtty-l_remainqtty-l_execqtty,
        last_change=systimestamp
        where blorderid=l_blOrderid;
    end if;
    -- lay thong tin ve lenh tong BL_ODMAST
    select sentqtty,ptsentqtty
    into l_sentqtty,l_ptsentqtty from bl_odmast
    where blorderid=l_blOrderid;
     -- Revert lai trang thai neu sau khi huy map: KL da dat =0
    if l_sentqtty=0 and l_ptsentqtty=0 then
       update bl_odmast set pstatus=pstatus||status,status='A' where blorderid=l_blOrderid;
    end if;

 -- Ghi vao bang log
        INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
        VALUES (BL_LOG_seq.NEXTVAL,l_blAutoid,'UNMAPORDER','',to_char(l_execamt),l_orderqtty,SYSTIMESTAMP,pv_tlid);

    --RETURN systemnums.C_SUCCESS;
     if p_err_message is null then
        p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
    end if;
    plog.setendsection(pkgctx, 'BL_UnMapOrder');

EXCEPTION
   WHEN OTHERS
   THEN
      pv_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(pv_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'BL_UnMapOrder');
      dbms_output.put_line('BL_UnMapOrder:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);

END;


PROCEDURE bl_mngneworder(
    pv_Afacctno     IN  varchar2,
    pv_Symbol       IN  varchar2,
    pv_Exectype     IN  varchar2,
    pv_OrderQtty    IN  varchar2,
    pv_Price        IN  varchar2,
    pv_via          IN  varchar2,
    pv_Desc         IN  VARCHAR2,
    pv_tlid         IN  varchar2,
    pv_blodtype     IN  varchar2,
    pv_err_code     IN out VARCHAR2,
    p_err_message   IN OUT VARCHAR2
    )
 IS
--
-- PURPOSE: THEM LENH MOI
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_strVIA          Varchar2(1);
    v_strACTYPE       Varchar2(10);
    v_strACCTNO       Varchar2(20);
    v_strCLEARCD      Varchar2(20);
    v_strMATCHTYPE    Varchar2(10);
    v_strSTATUS       Varchar2(10);
    v_strCONFIRMEDVIA Varchar2(10);
    v_strNORK         Varchar2(10);
    v_dblQUANTITY     Number(20,2);
    v_dblPRICE        Varchar2(20);
    v_dblQUOTEPRICE   Number(20,2);
    v_dblTRIGGERPRICE Number(20,2);
    v_dblEXECQTTY     Number(20,2);
    v_dblEXECAMT      Number(20,2);
    v_dblREMAINQTTY   Number(20,2);
    v_dblCLEARDAY     Number(20,2);
    v_strBOOK         Varchar2(10);

    v_strCURRDATE Date;
    v_strCodeID Varchar2(20);
    v_strTimeType Varchar2(20);

    v_strORDERID varchar2(20);
    v_BatchSEQ   varchar2(20);
    v_strFEEDBACKMSG varchar2(200);
    v_Username varchar2(100):='BPS';
    v_Password varchar2(100):='';
    v_strExpiredate Date;
    v_msgseqnum varchar2(30);
    v_strtradeplace varchar2(10);
    v_strAFACTYPE   varchar2(10);
    v_sectype       varchar2(10);
    v_deffeerate    NUMBER;
    v_ppse          NUMBER;
    v_SeTrade       NUMBER;
    v_CeilingPrice  NUMBER;
    v_CustAtCom     varchar2(10);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    v_BL_OdmastSEQ  varchar2(50);
    v_BLORDERID     varchar2(20);
    v_Custodycd     varchar2(10);
    v_BLAcctno      varchar2(50);
    v_HandlInst     varchar2(1);
    v_AutoID        number;
    v_RETLID        varchar2(10);
 Begin

    plog.setbeginsection(pkgctx, 'bl_mngneworder');
    pv_err_code := systemnums.C_SUCCESS;
    p_err_message := '';

     v_strVIA :='L';
    v_strACTYPE:='';
    v_strACCTNO :='';
    v_strCLEARCD   :=   'B';
    v_strMATCHTYPE :=   'N';
    v_strSTATUS := CASE WHEN pv_blodtype = '4' THEN 'P' -- MG quan ly thi cho phep gan lai
                             WHEN pv_blodtype = '5' THEN 'A' -- MG xy ly thi mac dinh gan cho MG do luon
                             ELSE 'P' END;
    v_RETLID := CASE WHEN pv_blodtype = '4' THEN '' -- MG quan ly thi cho phep gan lai
                         WHEN pv_blodtype = '5' THEN pv_tlid -- MG xy ly thi mac dinh gan cho MG do luon
                         ELSE '' END;
    v_strCONFIRMEDVIA  :='N';
    v_strNORK          :='N';
    v_strBOOK           :='A';

    v_dblQUANTITY     :=0;
    v_dblPRICE        :=0;
    v_dblQUOTEPRICE   :=0;
    v_dblTRIGGERPRICE :=0;
    v_dblEXECQTTY     :=0;
    v_dblEXECAMT      :=0;
    v_dblREMAINQTTY   :=0;
    --T2-NAMNT
    --    v_dblCLEARDAY    :=3;
    -- Mac dinh lay chu ky thanh toan tren sysvar
    select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
    --End T2-NAMNT
    v_HandlInst      := 4; -- lenh dat tu Flex
    --v_msgseqnum := to_char(msgseqnum);


    --Lay ngay hien tai:
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strCURRDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

    Begin
       Select af.acctno, af.actype, cf.custatcom, cf.custodycd, nvl(bl.blacctno,'')
       into v_strACCTNO, v_strAFACTYPE, v_CustAtCom, v_Custodycd, v_BLAcctno
       From afmast af, cfmast cf, (SELECT * FROM bl_register bl WHERE status = 'A') bl
       WHERE af.custid = cf.custid
            AND af.acctno = bl.afacctno (+)
            AND  af.acctno = pv_Afacctno;

    Exception when others then
       v_strACCTNO:=pv_Afacctno;
    end;
    --plog.debug(pkgctx,'v_strACCTNO--->'||v_strACCTNO);

    v_strVIA := pv_via;
    v_dblQUANTITY:=pv_OrderQtty;
    v_dblPRICE:=pv_Price/1000;
    v_dblREMAINQTTY:=pv_OrderQtty;
    v_dblQUOTEPRICE :=pv_Price/1000;

    /*If v_TimeInForce <> '0' Then
       v_strTimeType:='G';
       v_strExpiredate:= to_date(v_Expdate,'yyyymmdd');
    Else
       v_strTimeType:='T';
       v_strExpiredate:=v_strCURRDATE;
    End if;*/

    /*If pv_TimeType = 'G' Then
       v_strTimeType:='G';
       --v_strExpiredate:= to_date(v_Expdate,'yyyymmdd');
       v_strExpiredate:=v_strCURRDATE;
    Else*/
       v_strTimeType:='T';
       v_strExpiredate:=v_strCURRDATE;
    --End if;

    --Lay CODEID theo SYMBOL
    BEGIN
      SELECT CODEID, tradeplace, sectype
      Into v_strCodeID, v_strtradeplace,v_sectype
      FROM Sbsecurities where symbol =pv_Symbol;
    --Exception when others then
      --plog.debug(pkgctx,'SP_FOCOREPLACEORDER Get CodeID from Symbol '||sqlerrm);
    End;

    -- Ghi nhan vao bang lenh Bloomberg
    select bl_odmast_seq.NEXTVAL into v_AutoID from dual;
    Select blorderid_seq.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
    v_BLORDERID := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');
    v_strFEEDBACKMSG := 'Order is received and pending to process';

    INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                            PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                            CANCELQTTY,AMENDQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                            TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                            PRETLID,ASSIGNTIME,EXECTIME,FOREFID,BLINSTRUCTION,ORGQUANTITY,ORGPRICE,ROOTORDERID)
    VALUES (v_AutoID,v_BLORDERID,v_BLAcctno,pv_Afacctno,v_Custodycd,'','P',v_HandlInst,pv_Exectype,
            'LO',v_strTimeType,v_strCodeID,pv_Symbol,v_dblQUANTITY,v_dblPRICE,0,0,v_dblQUANTITY,
            0,0,'',v_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_strCURRDATE,
            '',v_strCURRDATE,v_strExpiredate,v_strVIA,'N',v_Username, 'Y', pv_tlid,v_RETLID,'','','','',pv_Desc,v_dblQUANTITY,v_dblPRICE,v_BLORDERID);

    -- Ghi vao bang log

    INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
    VALUES (BL_LOG_seq.NEXTVAL,v_AutoID,'NEWORDER','',v_BLORDERID,v_dblQUANTITY,SYSTIMESTAMP,pv_tlid);

    plog.setendsection(pkgctx, 'bl_mngneworder');

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('bl_mngneworder:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
 End;


 PROCEDURE BL_Getback_Order (
   pv_BLORDERID     IN      VARCHAR2,
   pv_newretlid     IN      VARCHAR2,
   pv_tlid          IN      VARCHAR2,
   pv_err_code      IN OUT  varchar2
)
IS
--
-- PURPOSE: THU HOI VA GAN LENH CHO MG KHAC
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_OldRETLID        varchar2(500);
    v_AutoID            number;
    v_RemainQTTY        number;
    v_SentQTTY          number;
    v_STATUS            varchar2(1);
    v_AssgnTime         TIMESTAMP;
    v_BLStatus          varchar2(10);
BEGIN
    --plog.error(pkgctx, 'order: ' || pv_BLORDERID  );
    plog.setbeginsection(pkgctx, 'BL_Getback_Order');
    pv_err_code := systemnums.C_SUCCESS;
    -- Lay thong tin cu
    SELECT bl.retlid, bl.autoid, bl.QUANTITY - bl.PTBOOKQTTY - bl.sentqtty, bl.sentqtty, bl.assigntime, bl.status
    INTO v_OldRETLID, v_AutoID, v_RemainQTTY, v_SentQTTY, v_AssgnTime, v_BLStatus
    FROM bl_odmast bl
    WHERE bl.blorderid = pv_BLORDERID;
    -- Cap nhat vao bang lenh Bloomberg

    -- Lenh da xu ly het thi ko cho phep thu hoi
    if v_RemainQTTY = 0 then
        pv_err_code:='-700116';
        plog.setendsection(pkgctx, 'BL_Getback_Order');
        RETURN;
    end if;

    -- TheNN, 27-Feb-2014
    -- Lenh chua cap so du thi thu hoi ko doi trang thai

    --if pv_newretlid IS NULL OR pv_newretlid = '' then
    if v_BLStatus = 'T' then
        v_STATUS := 'T';
    elsif pv_newretlid IS NULL OR pv_newretlid = '' then
        v_STATUS := 'D';
    ELSIF v_SentQTTY = 0 then
        v_status := 'A';
        v_AssgnTime := SYSTIMESTAMP;
    else
        v_STATUS := 'F';
        v_AssgnTime := SYSTIMESTAMP;
    end if;

    UPDATE bl_odmast SET
        PRETLID = PRETLID || RETLID,
        RETLID = pv_newretlid,
        pasdtlid = pasdtlid || asdtlid,
        asdtlid = pv_tlid,
        PSTATUS = PSTATUS || STATUS,
        STATUS = v_STATUS,
        LAST_CHANGE = SYSTIMESTAMP,
        assigntime = v_AssgnTime
    WHERE blorderid = pv_BLORDERID;

    -- Cap nhat cac lenh da xu ly ve MG moi dc gan
    /*IF pv_newretlid IS NOT NULL OR pv_newretlid <> '' THEN
        -- Cap nhat FOMAST
        UPDATE fomast SET
            PRETLID = PRETLID || RETLID,
            RETLID = pv_newretlid,
            last_change = SYSTIMESTAMP
        WHERE blorderid = pv_BLORDERID;

        -- Cap nhat ODMAST
        UPDATE odmast SET
            RETLID = pv_newretlid,
            last_change = SYSTIMESTAMP
        WHERE blorderid = pv_BLORDERID;
    END IF;*/

    -- Ghi vao bang log

    INSERT INTO BL_LOG(AUTOID,BLODAUTOID,ACTION,OLDVALUE,NEWVALUE,QUANTITY,LOGTIME,TLID)
    VALUES (BL_LOG_seq.NEXTVAL,v_AutoID,'GETBACK',v_OldRETLID,pv_newretlid,v_RemainQTTY,SYSTIMESTAMP,pv_tlid);

    plog.setendsection(pkgctx, 'BL_Getback_Order');

EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('BL_Getback_Order:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;
-- comment lenh
PROCEDURE pr_CommentBlbOrder
    (   p_blOrderid varchar,
        p_Comment varchar,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        v_strBLOrderId   varchar2(30);
        v_strComment     varchar2(500);

    BEGIN
        p_err_code := 0;
        p_err_message := '';
        v_strBLOrderId := p_blOrderid;
        v_strComment:=p_Comment;
        update bl_odmast set reexecomment=v_strComment,last_change=SYSTIMESTAMP
        where blorderid=v_strBLOrderId;

        p_err_code:=0;

    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             RAISE errnums.E_SYSTEM_ERROR;
    END ;

-- created by PhuongHT
--Purpose: update cac truong trong bl_odmast khi co confirm huy lenh trong odmast
Procedure bl_odmast_CancelOrder
(p_blOrderid      in  varchar2,
 p_cancelqtty     in  number,
 p_OrderID        in  varchar2,
 p_OrStatus       in  VARCHAR2,
 p_EDStatus       IN    VARCHAR2)
  IS
  v_FOAcctno      varchar2(20);
  v_blodtype    varchar2(10);
  v_pricetype   varchar2(10);
  v_quantity    NUMBER;
  v_CancelVia   varchar2(10);
  v_OrgQuantity NUMBER;
  v_OrgCancelQtty   NUMBER;
  v_OrgPtsentqtty   NUMBER;
  v_OrgExecQtty     NUMBER;


  BEGIN
    plog.setbeginsection(pkgctx, 'bl_odmast_CancelOrder');
    plog.error (pkgctx, 'p_blOrderid: ' || p_blOrderid ||
                        ' p_cancelqtty: ' || p_cancelqtty ||
                        ' p_OrderID: ' || p_OrderID ||
                        ' p_OrStatus: ' || p_OrStatus ||
                        ' p_EDStatus: ' || p_EDStatus);
    -- Lay thong tin lenh goc
    SELECT bl.blodtype, bl.pricetype, bl.quantity, bl.cancelqtty, bl.ptsentqtty, bl.execqtty
    INTO v_blodtype, v_pricetype, v_OrgQuantity, v_OrgCancelQtty, v_OrgPtsentqtty, v_OrgExecQtty
    FROM bl_odmast bl
    WHERE bl.blorderid = p_blOrderid;

    -- Cap nhat tuy theo loai lenh
    IF p_EDStatus = 'W' THEN
        -- Neu la lenh huy, cap nhat lai lenh trong bl_odmast
        -- Lay thong tin lenh y/c huy trong dtl
        BEGIN
            SELECT max(bt.via)
            INTO v_CancelVia
            FROM bl_odmastdtl bt
            WHERE bt.blorderid = p_blOrderid AND bt.exectype IN ('CB','CS') AND bt.deltd = 'N';
        EXCEPTION
           WHEN OTHERS
             THEN
                v_CancelVia := 'F';
                plog.error (pkgctx, SQLERRM);
        end;
        plog.error (pkgctx, 'v_CancelVia: ' || v_CancelVia || ' v_blodtype: ' || v_blodtype || ' v_pricetype: ' || v_pricetype);

        IF v_blodtype = '1' or v_pricetype in ('ATO','ATC','MP','MOK','MAK','MTL') THEN
            -- Lenh auto hoac lenh thi truong thi huy luon va tra ve cho Bloomberg
            -- Cap nhat lenh goc
            update bl_odmast set
                sentqtty=sentqtty - p_cancelqtty,
                cancelqtty = cancelqtty + p_cancelqtty,
                pstatus= case when quantity - (cancelqtty + p_cancelqtty + execqtty) = 0 then pstatus|| status else pstatus end,
                status= case when quantity - (cancelqtty + p_cancelqtty + execqtty) = 0 then 'C' -- Cancel
                             else status end,
                edstatus = case when quantity - (cancelqtty + p_cancelqtty + execqtty) = 0 then 'W' else 'N' end, -- edstatus end,
                last_change= systimestamp
            where blorderid = p_blOrderid;

            -- Cap nhat trong bl_odmastdtl
            if v_CancelVia = 'L' then
                  update bl_odmastdtl set
                      pstatus = case when v_OrgQuantity - (v_OrgCancelQtty + p_cancelqtty + v_OrgExecQtty) = 0 then pstatus|| status else pstatus end,
                      status = case when v_OrgQuantity - (v_OrgCancelQtty + p_cancelqtty + v_OrgExecQtty) = 0 then 'C' else status end,
                      --pstatus = pstatus || status,
                      --status = 'C',
                      cancelqtty = cancelqtty + p_cancelqtty,
                      last_change = SYSTIMESTAMP
                  where blorderid = p_blOrderid and exectype in ('CB','CS') and status <> 'C';
            else
                -- Lay so hieu lenh trong FOMAST lenh y/c huy
                  begin
                   select max(od.acctno)
                   into v_FOAcctno
                   from fomast od
                   where od.refacctno = p_OrderID and od.exectype in ('CB','CS');
                 EXCEPTION
                 WHEN OTHERS
                   THEN
                      v_FOAcctno := '';
                      plog.error (pkgctx, SQLERRM);
                 end;
                 plog.error (pkgctx, 'v_FOAcctno: ' || v_FOAcctno);
                 update bl_odmastdtl set
                      --pstatus = case when v_OrgQuantity - (v_OrgCancelQtty + p_cancelqtty + v_OrgExecQtty) = 0 then pstatus|| status else pstatus end,
                      --status = case when v_OrgQuantity - (v_OrgCancelQtty + p_cancelqtty + v_OrgExecQtty) = 0 then 'C' else status end,
                      pstatus = pstatus || status,
                      status = 'C',
                      cancelqtty = cancelqtty + p_cancelqtty,
                      last_change = SYSTIMESTAMP
                  where blorderid = p_blOrderid and exectype in ('CB','CS') and foacctno = v_FOAcctno;
            end if;
        ELSIF v_blodtype IN ('2','3','4','5') THEN
            -- Neu huy tai san thi khong tra ve Bloomberg
            -- Neu huy tu BLB thi huy het moi tra ve Bloomberg
            IF v_CancelVia = 'L' THEN
                -- Cap nhat lenh goc
                update bl_odmast set
                    sentqtty=sentqtty - p_cancelqtty,
                    cancelqtty = cancelqtty + p_cancelqtty,
                    pstatus= case when quantity - (cancelqtty + p_cancelqtty + execqtty) = 0 then pstatus|| status else pstatus end,
                    status= case when quantity - (cancelqtty + p_cancelqtty + execqtty) = 0 then 'C' -- Cancel
                                 else status end,
                    edstatus = case when quantity - (cancelqtty + p_cancelqtty + execqtty) = 0 then 'W' else edstatus end,
                    last_change= systimestamp
                where blorderid = p_blOrderid;

                -- Cap nhat trong bl_odmastdtl
                update bl_odmastdtl set
                    pstatus = case when v_OrgQuantity - (v_OrgCancelQtty + p_cancelqtty + v_OrgExecQtty) = 0 then pstatus|| status else pstatus end,
                    status = case when v_OrgQuantity - (v_OrgCancelQtty + p_cancelqtty + v_OrgExecQtty) = 0 then 'C' else status end,
                    cancelqtty = cancelqtty + p_cancelqtty,
                    last_change = SYSTIMESTAMP
                where blorderid = p_blOrderid and exectype in ('CB','CS') AND status <> 'C';
            ELSE
                -- Cap nhat lenh goc
                update bl_odmast set
                    remainqtty=remainqtty + p_cancelqtty,
                    sentqtty=sentqtty - p_cancelqtty,
                    last_change= systimestamp
                where blorderid = p_blOrderid;

                -- Cap nhat trong bl_odmastdtl
                if p_OrStatus <> '5' then
                    -- Lay so hieu lenh trong FOMAST lenh y/c huy
                    begin
                     select nvl(od.acctno,'')
                     into v_FOAcctno
                     from fomast od
                     where od.refacctno = p_OrderID and od.exectype in ('CB','CS');
                   EXCEPTION
                   WHEN OTHERS
                     THEN
                        v_FOAcctno := '';
                        plog.error (pkgctx, SQLERRM);
                   end;

                   update bl_odmastdtl set
                        pstatus = pstatus || status,
                        status = 'C',
                        cancelqtty = cancelqtty + p_cancelqtty,
                        last_change = SYSTIMESTAMP
                    where blorderid = p_blOrderid and exectype in ('CB','CS') and foacctno = v_FOAcctno;
                end if;
            END IF;
        END IF;


        /*-- Cap nhat lenh goc
        update bl_odmast set
            remainqtty=remainqtty + CASE WHEN (status = 'C' or blodtype='1' or pricetype in ('ATO','ATC','MP','MOK','MAK','MTL')) THEN 0 ELSE p_cancelqtty end,
            sentqtty=sentqtty - p_cancelqtty,
            cancelqtty = cancelqtty + CASE WHEN (status = 'C' or blodtype='1' or pricetype in ('ATO','ATC','MP','MOK','MAK','MTL')) THEN p_cancelqtty ELSE 0 END,
            pstatus= case when blodtype ='1' or pricetype in ('ATO','ATC','MP','MOK','MAK','MTL') then pstatus|| status else pstatus end,
            status= case when blodtype ='1' or pricetype in ('ATO','ATC','MP','MOK','MAK','MTL') then 'C' -- Cancel
                         else status end,
            edstatus = case when blodtype ='1' or pricetype in ('ATO','ATC','MP','MOK','MAK','MTL') then 'W' else edstatus end,
            last_change= systimestamp
        where blorderid = p_blOrderid;

        -- Cap nhat trong bl_odmastdtl
        if p_OrStatus <> '5' then
            -- Lay so hieu lenh trong FOMAST lenh y/c huy
            begin
             select nvl(od.acctno,'')
             into v_FOAcctno
             from fomast od
             where od.refacctno = p_OrderID and od.exectype in ('CB','CS');
           EXCEPTION
           WHEN OTHERS
             THEN
                v_FOAcctno := '';
                plog.error (pkgctx, SQLERRM);
           end;

           update bl_odmastdtl set
                pstatus = pstatus || status,
                status = 'C',
                cancelqtty = cancelqtty + p_cancelqtty,
                last_change = SYSTIMESTAMP
            where blorderid = p_blOrderid and exectype in ('CB','CS') and foacctno = v_FOAcctno;
        end if;*/
    ELSIF p_EDStatus = 'N' THEN
        -- Lenh giai toa, done for day
        IF v_blodtype ='1' or v_pricetype in ('ATO','ATC','MP','MOK','MAK','MTL') THEN
            -- Cap nhat lenh goc
            update bl_odmast set
                remainqtty = 0,
                sentqtty = sentqtty - p_cancelqtty,
                cancelqtty = cancelqtty + p_cancelqtty,
                pstatus = pstatus|| status,
                status= 'E', -- Done for day
                last_change= systimestamp
            where blorderid = p_blOrderid;
        ELSE
            -- Cap nhat lenh goc
            update bl_odmast set
                remainqtty=remainqtty + CASE WHEN (status = 'C') THEN 0 ELSE p_cancelqtty end,
                sentqtty=sentqtty - p_cancelqtty,
                cancelqtty = cancelqtty + CASE WHEN (status = 'C') THEN p_cancelqtty ELSE 0 END,
                last_change= systimestamp
            where blorderid = p_blOrderid;
        END IF;
    END IF;

    -- Cap nhat lenh y/c huy
    /*update bl_odmast set
        pstatus = pstatus || status,
        status = 'C',
        edstatus = 'W',
        last_change = SYSTIMESTAMP
    where refblorderid = p_blOrderid and edexectype in ('CB','CS') and edstatus = 'C';*/


    plog.setendsection(pkgctx, 'bl_odmast_CancelOrder');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'bl_odmast_CancelOrder');
      RAISE errnums.E_SYSTEM_ERROR;
  END bl_odmast_CancelOrder;

-- created by PhuongHT
--Purpose: update cac truong trong bl_odmast khi co confirm sua lenh trong odmast
Procedure bl_odmast_AmendOrder(p_blOrderid varchar2,p_adjustqtty number,p_orderqtty number,p_execqtty number)
  IS
    l_count number;
    l_blodtype varchar2(20);
    l_pricetype  varchar2(10);
  BEGIN
    plog.setbeginsection(pkgctx, 'bl_odmast_AmendOrder');
    -- Cap nhat thong tin lenh goc trong bl_odmast
    -- Sua giam khoi luong
    SELECT bl.blodtype, bl.pricetype
    INTO l_blodtype, l_pricetype
    FROM bl_odmast bl
    WHERE bl.blorderid = p_blOrderid;

    plog.error(pkgctx, 'bl_odmast_AmendOrder: l_blodtype: ' || l_blodtype || ' l_pricetype: ' || l_pricetype
                        || ' p_blOrderid: ' || p_blOrderid || ' p_adjustqtty: ' || p_adjustqtty || ' p_orderqtty: ' || p_orderqtty || ' p_execqtty: ' || p_execqtty);

    IF p_adjustqtty < p_orderqtty - p_execqtty THEN
        IF l_blodtype <> '1' and l_pricetype = 'LO' THEN
            update bl_odmast set
                remainqtty=remainqtty - ( p_adjustqtty  -  p_orderqtty  +  p_execqtty ),
                sentqtty=sentqtty + ( p_adjustqtty  -  p_orderqtty  +  p_execqtty ),
                last_change= systimestamp
             where blorderid =p_blOrderid;
        --ELSE
            /*update bl_odmast set
                sentqtty=sentqtty + ( p_adjustqtty  -  p_orderqtty  +  p_execqtty ),
                last_change= systimestamp
             where blorderid =p_blOrderid;*/
        END IF;
    END IF;

    /*
    --Cap nhat thong tin SL sua va gia sua
    -- Lay thong tin lenh de nghi sua
    SELECT bl.blorderid, bl.quantity, bl.price
    INTO l_adorderid, l_newquantity, l_newprice
    FROM odmast od, fomast fo, bl_odmast bl
    WHERE od.foacctno = fo.acctno AND fo.forefid = bl.forefid
        AND od.reforderid = p_OrgOrderid;
    -- Cap nhat thong tin vao bl_odmast
    UPDATE bl_odmast SET
        quantity = l_newquantity,
        price = l_newprice,
        last_change = SYSTIMESTAMP
    WHERE blorderid = p_blOrderid;
    -- Cap nhat lenh y/c sua
    UPDATE bl_odmast SET
        pstatus = pstatus || status,
        status = 'M',
        AMENDQTTY = p_adjustqtty,
        last_change = SYSTIMESTAMP
    WHERE blorderid = l_adorderid;
    -- Cap nhat chi tiet lenh sua
    UPDATE bl_odmastdtl SET
        pstatus = pstatus || status,
        status = 'M',
        AMENDQTTY = p_adjustqtty,
        last_change = SYSTIMESTAMP
    WHERE BLORDERID = p_blOrderid AND ADORDERID = l_adorderid;
*/
    plog.setendsection(pkgctx, 'bl_odmast_AmendOrder');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'bl_odmast_AmendOrder');
      RAISE errnums.E_SYSTEM_ERROR;
  END bl_odmast_AmendOrder;

-- created by PhuongHT
--Purpose: update cac truong trong bl_odmast khi co confirm khop lenh trong odmast
Procedure bl_odmast_MatchOrder(p_blOrderid varchar2,p_execqtty number,p_execamt number)
  IS
    l_count number;
  BEGIN
    plog.setbeginsection(pkgctx, 'bl_odmast_MatchOrder');
    update bl_odmast set
        execqtty=execqtty + p_execqtty,
        execamt=execamt + p_execamt,
        pstatus = case when quantity - (cancelqtty + execqtty + p_execqtty) = 0 and cancelqtty > 0 then pstatus || status else pstatus end,
        status = case when quantity - (cancelqtty + execqtty + p_execqtty) = 0 and cancelqtty > 0 then 'C' else status end,
        edstatus = case when quantity - (cancelqtty + execqtty + p_execqtty) = 0 and cancelqtty > 0 then 'W' else edstatus end,
        last_change= systimestamp
     where blorderid =p_blOrderid;

    plog.setendsection(pkgctx, 'bl_odmast_MatchOrder');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'bl_odmast_MatchOrder');
      RAISE errnums.E_SYSTEM_ERROR;
  END bl_odmast_MatchOrder;

-- Cap nhat lenh sua tu Bloomberg
Procedure bl_Update_AmendOrder(
    p_FOAcctno IN VARCHAR2,
    p_blorderid IN  VARCHAR2,
    p_adjustqtty IN NUMBER,
    p_adjustprice IN  NUMBER
    )
  IS
    l_count number;
    l_adorderid varchar2(20);
    l_newquantity   NUMBER;
    l_newprice      NUMBER;
    l_orgblorderid  varchar2(20);
    l_orgstatus     varchar2(2);
    l_currexecqtty  NUMBER;
    l_currexecamt   NUMBER;
    l_blodtype      varchar2(10);

  BEGIN
    plog.setbeginsection(pkgctx, 'bl_Update_AmendOrder');

    plog.error(pkgctx, 'bl_Update_AmendOrder: p_FOAcctno: ' || p_FOAcctno || ' p_blorderid ' || p_blorderid);

    --Cap nhat thong tin SL sua va gia sua
    -- Lay thong tin lenh de nghi sua
    SELECT nvl(bl.blorderid,''), nvl(bl.quantity,p_adjustqtty), nvl(bl.price,p_adjustprice/1000), nvl(bl.REFBLORDERID,bl.blorderid), bl.blodtype
    INTO l_adorderid, l_newquantity, l_newprice, l_orgblorderid, l_blodtype
    FROM fomast fo,
        (SELECT bl.*, bdt.foacctno
        FROM bl_odmast bl, bl_odmastdtl bdt
        WHERE bl.blorderid = bdt.adorderid
        ) bl
    WHERE fo.acctno = p_FOAcctno
        --AND fo.forefid = bl.forefid(+)
        AND fo.acctno = bl.foacctno (+);

    SELECT nvl(bl.status,'F'),nvl(bl.execqtty,0),nvl(bl.execamt,0)
    INTO l_orgstatus, l_currexecqtty, l_currexecamt
    FROM bl_odmast bl
    WHERE bl.blorderid = l_orgblorderid;

    IF l_blodtype = '1' THEN -- Chi cap nhat lenh Direct
        -- Cap nhat thong tin vao bl_odmast
        UPDATE bl_odmast SET
            AMENDQTTY = p_adjustqtty,
            remainqtty = 0,
            edstatus = 'S',
            pstatus = pstatus || status,
            status = 'M', -- M = Modified
            last_change = SYSTIMESTAMP
        WHERE blorderid = l_orgblorderid;
        -- Cap nhat lenh y/c sua thanh lenh moi
        UPDATE bl_odmast SET
            pstatus = pstatus || status,
            status = l_orgstatus,
            edstatus = 'N', -- Lenh binh thuong
            execqtty = l_currexecqtty,
            execamt = l_currexecamt,
            sentqtty = quantity,
            --AMENDQTTY = p_adjustqtty,
            last_change = SYSTIMESTAMP
        WHERE blorderid = l_adorderid;
    END IF;
    -- Cap nhat chi tiet lenh sua
    UPDATE bl_odmastdtl SET
        pstatus = pstatus || status,
        status = 'M',
        AMENDQTTY = p_adjustqtty,
        last_change = SYSTIMESTAMP
    WHERE BLORDERID = l_orgblorderid AND ADORDERID = l_adorderid AND foacctno = p_FOAcctno;

    plog.setendsection(pkgctx, 'bl_Update_AmendOrder');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'bl_Update_AmendOrder');
      RAISE errnums.E_SYSTEM_ERROR;
  END bl_Update_AmendOrder;

-- Sinh lenh trung gian huy/sua neu lenh huy/sua tu kenh <> Bloomberg
Procedure bl_Place_AmendOrder(
    p_FOAcctno IN VARCHAR2
    )
  IS
    v_BL_OdmastSEQ    varchar2(50);
    v_Amend_orderid  varchar2(20);
    v_strCURRDATE  DATE;
    v_orgblorderid  varchar2(20);
    v_exectype      varchar2(2);
    v_orgorderid    varchar2(20);
    v_orgqtty       NUMBER;
    v_blodtype      varchar2(10);
    v_Via           varchar2(10);
    v_EDStatus      varchar2(10);
    v_CancelQtty    NUMBER;
    v_dtlautoid     NUMBER;
 BEGIN
    plog.setbeginsection(pkgctx, 'bl_Place_AmendOrder');

    -- Lay thong tin lenh goc
    begin
        SELECT bl.blorderid, fo.exectype, fo.REFACCTNO, od.orderqtty, bl.blodtype, fo.via
        INTO v_orgblorderid, v_exectype, v_orgorderid, v_orgqtty, v_blodtype, v_Via
        from  bl_odmast bl, fomast fo, odmast od
        WHERE bl.blorderid = fo.blorderid AND fo.refacctno = od.orderid and fo.acctno = p_FOAcctno;

    EXCEPTION
    WHEN OTHERS
    THEN
        v_orgblorderid := '';
        v_orgqtty := 0;

    END;


    -- Ghi nhan vao BL_ODMAST
    IF v_exectype IN ('AB','AS') AND v_blodtype = '1' THEN
        -- Chi lenh sua moi sinh lenh trong bl_odmast
        v_strCURRDATE := getcurrdate;
        Select blorderid_seq.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
        v_Amend_orderid := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');

        INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                                PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                                CANCELQTTY,AMENDQTTY,sentqtty,PTBOOKQTTY,PTSENTQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                                TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                                PRETLID,ASSIGNTIME,EXECTIME,FOREFID,REFFOREFID,ORGQUANTITY,ORGPRICE,EDSTATUS,EDEXECTYPE,ROOTORDERID)
        SELECT bl_odmast_seq.NEXTVAL, v_Amend_orderid,bl.BLACCTNO,bl.AFACCTNO,bl.CUSTODYCD,bl.TRADERID,'N' STATUS,bl.BLODTYPE,bl.exectype EXECTYPE,
                                bl.PRICETYPE,bl.TIMETYPE,bl.CODEID,bl.SYMBOL,bl.quantity - (v_orgqtty - fo.quantity),fo.price,bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,
                                bl.CANCELQTTY,bl.AMENDQTTY,bl.sentqtty,bl.PTBOOKQTTY,bl.PTSENTQTTY,bl.blorderid REFBLORDERID,CASE WHEN fo.exectype in ('AB','AS') THEN 'Received amend request' ELSE 'Received cancel request' END FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),v_strCURRDATE,
                                '' TXNUM,v_strCURRDATE,v_strCURRDATE,bl.VIA,'N' DELTD,'Flex' USERNAME,bl.DIRECT,fo.TLID,bl.RETLID,
                                '' PRETLID,'' ASSIGNTIME,'' EXECTIME,bl.FOREFID FOREFID,bl.FOREFID REFFOREFID,bl.ORGQUANTITY,bl.ORGPRICE,
                                case when fo.exectype in ('AB','AS') then 'A' else 'C' end EDSTATUS,fo.exectype EDEXECTYPE,BL.ROOTORDERID
        FROM bl_odmast bl, fomast fo
        WHERE bl.blorderid = fo.blorderid and fo.acctno = p_FOAcctno;
    END IF;

    -- Ghi nhan vao bang chi tiet sua lenh BL_ODMASTDTL
    -- Lay thong tin gia lenh goc
    -- Neu lenh huy tu Bloomberg thi ko them lenh vao dtl nua
    if not (v_Via = 'L' and v_exectype IN ('CB','CS')) then
        SELECT bl_odmastdtl_seq.NEXTVAL INTO v_dtlautoid FROM dual;

        INSERT INTO bl_odmastdtl (AUTOID,ROOTORDERID,BLORDERID,ADORDERID,FOREFID,FOACCTNO,
                                STATUS,EXECTYPE,VIA,CODEID,SYMBOL,
                                CURQUANTITY,CURPRICE,ORGQUANTITY,ORGPRICE,NEWQUANTITY,NEWPRICE,
                                EXECQTTY,EXECAMT,REMAINQTTY,CANCELQTTY,AMENDQTTY,
                                FEEDBACKMSG,DELTD,USERNAME,DIRECT,TLID,
                                CREATEDDT,ORDERTIME)
        SELECT v_dtlautoid, bl.ROOTORDERID, bl.blorderid, CASE WHEN fo.exectype in ('AB','AS') THEN nvl(v_Amend_orderid,bl.blorderid) ELSE bl.blorderid END ,bl.FOREFID FOREFID,fo.acctno,
                                'N' STATUS,fo.exectype EXECTYPE,fo.VIA,bl.CODEID,bl.SYMBOL,
                                case when fo.exectype in ('AB','AS') then bl.quantity else fo.quantity end,bl.price,bl.ORGQUANTITY,bl.ORGPRICE, case when fo.exectype in ('AB','AS') then bl.quantity - (v_orgqtty - fo.quantity) else fo.quantity end,fo.price,
                                bl.EXECQTTY,bl.EXECAMT,bl.REMAINQTTY,bl.CANCELQTTY,bl.AMENDQTTY,
                                CASE WHEN fo.exectype in ('AB','AS') THEN 'Received amend request' ELSE 'Received cancel request' END FEEDBACKMSG,'N' DELTD,'Flex',bl.DIRECT,fo.TLID,
                                TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),SYSTIMESTAMP ORDERTIME
        FROM bl_odmast bl, fomast fo
        WHERE bl.blorderid = fo.blorderid and fo.acctno = p_FOAcctno;
    end if;

    IF v_blodtype = '1' THEN -- Chi cap nhat voi lenh Direct
        -- Cap nhat trang thai lenh goc la dang sua/huy
        UPDATE bl_odmast SET
            edstatus = case when v_exectype in ('AB','AS') then 'A' ELSE 'C' end,
            last_change = SYSTIMESTAMP
        WHERE blorderid = v_orgblorderid;

        -- Cap nhat lai FOMAST va ODMAST
        UPDATE fomast SET
            blorderid = case when v_exectype in ('AB','AS') THEN nvl(v_Amend_orderid,v_orgblorderid) ELSE v_orgblorderid END,
            last_change = SYSTIMESTAMP
        WHERE acctno = p_FOAcctno;

        UPDATE odmast SET
            blorderid = case when v_exectype in ('AB','AS') THEN nvl(v_Amend_orderid,v_orgblorderid) ELSE v_orgblorderid END,
            last_change = SYSTIMESTAMP
        WHERE foacctno = p_FOAcctno;

        -- Neu lenh huy lenh chua gui len san thi cap nhat lai trang thai cac lenh
        BEGIN
            SELECT od.cancelqtty, od.edstatus
            INTO v_CancelQtty, v_EDStatus
            FROM odmast od, fomast fo
            WHERE od.orderid = fo.refacctno AND fo.acctno = p_FOAcctno;
            IF v_CancelQtty > 0 AND v_EDStatus = 'W' THEN
                -- Update bl_odmast
                UPDATE bl_odmast SET
                    pstatus = CASE WHEN status <> 'C' AND quantity - (cancelqtty + execqtty) = 0 THEN pstatus || status ELSE pstatus END,
                    status = CASE WHEN status <> 'C' AND quantity - (cancelqtty + execqtty) = 0 THEN 'C' ELSE status END,
                    edstatus = CASE WHEN quantity - (cancelqtty + execqtty) = 0 THEN 'W' ELSE 'N' end,
                    last_change = SYSTIMESTAMP
                WHERE blorderid = v_orgblorderid;

                -- Update bl_odmastdtl
                UPDATE bl_odmastdtl SET
                    pstatus = pstatus || status,
                    status = 'C'
                WHERE autoid = v_dtlautoid;
            END IF;
        EXCEPTION
          WHEN OTHERS
           THEN
              plog.error (pkgctx, SQLERRM);
              v_CancelQtty:= 0;
              v_EDStatus := '';
        END;
    END IF;

    plog.setendsection(pkgctx, 'bl_Place_AmendOrder');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'bl_Place_AmendOrder');
      RAISE errnums.E_SYSTEM_ERROR;
  END bl_Place_AmendOrder;


PROCEDURE BL_Process_AnyOrder
IS
--
-- PURPOSE: XU LY LENH ANY
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   10-Sep-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_OldRETLID        varchar2(500);
    v_AutoID            number;
    v_RemainQTTY        number;
    v_SentQTTY          number;
    v_strSTATUS            varchar2(1);
    v_BLODSTATUS        varchar2(2);
    v_AssgnTime         TIMESTAMP;
    v_AnyTimeCfg        NUMBER;
    v_BL_OdmastSEQ      NUMBER;
    v_BLORDERID         varchar2(50);
    v_strFEEDBACKMSG    varchar2(200);
    v_BatchSEQ          NUMBER;
    v_strORDERID        varchar2(50);
    v_strACTYPE         varchar2(10);
    v_strtradeplace varchar2(10);
    v_strAFACTYPE   varchar2(10);
    v_sectype       varchar2(10);
    v_deffeerate    NUMBER;
    v_ppse          NUMBER;
    v_SeTrade       NUMBER;
    v_CeilingPrice  NUMBER;
    v_CustAtCom     varchar2(10);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    v_dblQUOTEPRICE NUMBER;
    v_strCURRDATE   date;
    v_dblCLEARDAY  NUMBER;
BEGIN

      --T2-NAMNT
    --    v_dblCLEARDAY    :=3;
    -- Mac dinh lay chu ky thanh toan tren sysvar
    select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
    --End T2-NAMNT

    plog.setbeginsection(pkgctx, 'BL_Process_AnyOrder');

    SELECT to_number(varvalue) INTO v_AnyTimeCfg FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'BLANYODTIME';
    --Lay ngay hien tai:
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strCURRDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

    -- Lay cac lenh Any can xu ly
    FOR rec IN
    (
        SELECT bl.*
        FROM bl_odmast BL
        WHERE BL.blodtype = '2' AND BL.remainqtty > 0
            AND bl.status IN ('P','A','F','D')
            AND TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,1,INSTR(SYSTIMESTAMP - ORDERTIME,' ')))*24*60 -- WTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+1,2))*60 -- HWTIME,
                + TO_NUMBER(SUBSTR(SYSTIMESTAMP - ORDERTIME,INSTR(SYSTIMESTAMP - ORDERTIME,' ')+4,2)) > v_AnyTimeCfg
            AND NOT EXISTS (SELECT fo.blorderid FROM fomast fo WHERE fo.tlid = '6868' AND fo.blorderid = bl.blorderid)
        ORDER BY BL.autoid
    )
    LOOP

        Begin
           Select af.actype, cf.custatcom
           into v_strAFACTYPE, v_CustAtCom
           From afmast af, cfmast cf
           WHERE af.custid = cf.custid AND  af.acctno = rec.afacctno;
        Exception when others then
           plog.debug(pkgctx,'SP_FOCOREPLACEORDER Get CodeID from Symbol '||sqlerrm);
        end;

        --Lay CODEID theo SYMBOL
        BEGIN
          SELECT tradeplace, sectype
          Into v_strtradeplace,v_sectype
          FROM Sbsecurities where symbol =rec.symbol;
        Exception when others then
          plog.debug(pkgctx,'SP_FOCOREPLACEORDER Get CodeID from Symbol '||sqlerrm);
        End;
        --Kiem tra loai hinh co phu hop hay khong
        BEGIN
            -- Lay gia tri loai hinh lenh
            v_strACTYPE := fopks_api.fn_GetODACTYPE(rec.afacctno, rec.symbol, rec.codeid, v_strtradeplace, rec.exectype,
                                        rec.pricetype, rec.timetype, v_strAFACTYPE, v_sectype, rec.via);
        Exception when others then
            plog.debug(pkgctx,' SP_FOCOREPLACEORDER Get ACTYPE '||sqlerrm);
        END;

        v_strFEEDBACKMSG := 'Order is changed from any to direct and pending to process';
        v_strSTATUS := 'P';
        if nvl(rec.retlid,'') <> '' then
            v_BLODSTATUS := 'A';
        else
            v_BLODSTATUS := 'P';
        end if;

        -- Check so du tien/ CK truoc khi day lenh
        IF rec.exectype = 'NB' THEN
            SELECT ot.deffeerate
            INTO v_deffeerate
            FROM odtype ot WHERE actype = v_strACTYPE;
            IF rec.pricetype IN ('ATO','ATC') THEN
                SELECT s.ceilingprice
                INTO v_CeilingPrice
                FROM securities_info s WHERE s.symbol = rec.symbol;
                v_dblQUOTEPRICE := v_CeilingPrice/1000;
            ELSE
                v_dblQUOTEPRICE := rec.price;
            END IF;
            -- Lay suc mua hien tai
            v_ppse := fn_getppse(rec.afacctno, rec.symbol, v_dblQUOTEPRICE, 'O');
            -- Kiem tra voi gia tri dat lenh
            IF v_ppse < CEIL((1+v_deffeerate/100) * v_dblQUOTEPRICE * rec.remainqtty * 1000) THEN
                IF v_CustAtCom = 'Y' THEN
                    v_BLODSTATUS := 'R';
                    v_strSTATUS := 'R';
                ELSE
                    v_BLODSTATUS := 'R';--'T';
                    v_strSTATUS := 'R';--'T';
                END IF;
                SELECT d.errdesc
                INTO v_strFEEDBACKMSG
                FROM deferror d WHERE d.errnum = '-400116';
            END IF;
        ELSIF rec.exectype = 'NS' THEN
            l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(rec.afacctno || rec.codeid,'SEMAST','ACCTNO');
            v_SeTrade := l_SEMASTcheck_arr(0).TRADE;
            -- Kiem tra voi so CK dat
            IF v_SeTrade < rec.remainqtty THEN
                IF v_CustAtCom = 'Y' THEN
                    v_BLODSTATUS := 'R';
                    v_strSTATUS := 'R';
                ELSE
                    v_BLODSTATUS := 'R';--'T';
                    v_strSTATUS := 'R';--'T';
                END IF;
                SELECT d.errdesc
                INTO v_strFEEDBACKMSG
                FROM deferror d WHERE d.errnum = '-900017';
            END IF;
        END IF;
        -- Sinh ra lenh direct tu phan con lai cua lenh
        /*Select seq_blorderid.NEXTVAL Into v_BL_OdmastSEQ from DUAL;
        v_BLORDERID := to_char(v_strCURRDATE,'yyyymmdd')||LPAD(v_BL_OdmastSEQ,10,'0');

        INSERT INTO bl_odmast (AUTOID,BLORDERID,BLACCTNO,AFACCTNO,CUSTODYCD,TRADERID,STATUS,BLODTYPE,EXECTYPE,
                                PRICETYPE,TIMETYPE,CODEID,SYMBOL,QUANTITY,PRICE,EXECQTTY,EXECAMT,REMAINQTTY,
                                CANCELQTTY,AMENDQTTY,REFBLORDERID,FEEDBACKMSG,ACTIVATEDT,CREATEDDT,TXDATE,
                                TXNUM,EFFDATE,EXPDATE,VIA,DELTD,USERNAME,DIRECT,TLID,RETLID,
                                PRETLID,ASSIGNTIME,EXECTIME,FOREFID,BLINSTRUCTION)
        VALUES (seq_bl_odmast.NEXTVAL,v_BLORDERID,rec.BLACCTNO,rec.AFACCTNO,rec.CUSTODYCD,rec.TRADERID,v_BLODSTATUS,'1',rec.EXECTYPE,
                rec.PRICETYPE,rec.TIMETYPE,rec.CODEID,rec.SYMBOL,rec.remainqtty,rec.PRICE,0,0,rec.REMAINQTTY,
                0,0,rec.blorderid,v_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),rec.txdate,
                '',rec.effdate,rec.expdate,rec.via,'N',rec.username, 'N', '6868',rec.retlid,
                '',SYSTIMESTAMP,'',rec.forefid,rec.blinstruction);*/

        -- Day vao Flex
        IF v_BLODSTATUS <> 'R' THEN
            v_strFEEDBACKMSG := 'Order is received and pending to process';

            --Tao so hieu lenh: format dd/mm/yyyyNNNNNNNNNN vd:  09/05/20110000002941
           Select SEQ_FOMAST.NEXTVAL Into v_BatchSEQ from DUAL;
           v_strORDERID:=to_char(v_strCURRDATE,'dd/mm/yyyy')||LPAD(v_BatchSEQ,10,'0');

            -- Ghi nhan vao FOMAST
        /*
          INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                               TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                               CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY,
                               QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY,
                               EXECAMT, REMAINQTTY,VIA,
                               EFFDATE,EXPDATE,USERNAME,FOREFID,DIRECT,TLID,TRADERID,BLORDERID)
           VALUES ( v_strORDERID , v_strORDERID, v_strACTYPE, rec.afacctno,v_strSTATUS, rec.exectype, rec.pricetype,
                    rec.timetype , 'N', 'N', 'B', rec.codeid, rec.symbol,
                    'N'  , 'A', v_strFEEDBACKMSG, TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), 3,
                    rec.remainqtty, rec.price, rec.price, 0, 0,
                    0, rec.remainqtty, rec.via,
                    rec.effdate, rec.expdate,rec.username,rec.forefid,'N','6868', rec.traderid,rec.blorderid);
                  */
      INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                               TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                               CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY,
                               QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY,
                               EXECAMT, REMAINQTTY,VIA,
                               EFFDATE,EXPDATE,USERNAME,FOREFID,DIRECT,TLID,TRADERID,BLORDERID)
           VALUES ( v_strORDERID , v_strORDERID, v_strACTYPE, rec.afacctno,v_strSTATUS, rec.exectype, rec.pricetype,
                    rec.timetype , 'N', 'N', 'B', rec.codeid, rec.symbol,
                    'N'  , 'A', v_strFEEDBACKMSG, TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), v_dblCLEARDAY,
                    rec.remainqtty, rec.price, rec.price, 0, 0,
                    0, rec.remainqtty, rec.via,
                    rec.effdate, rec.expdate,rec.username,/*sysdate,*/rec.forefid,'N','6868', rec.traderid,rec.blorderid);
           --insert msgseqnum

            --plog.debug(pkgctx,'v_msgseqnum-->'||v_msgseqnum);
            --Insert into bl_msgseqnum_map(msgseqnum,acctno,ClOrdID,Orderqtty) values(v_msgseqnum,v_strORDERID,pv_forefid,v_dblQUANTITY);

            -- Cap nhat lai lenh trong bl_odmast la da day vao Flex
            /*IF v_strSTATUS NOT IN ('R','T') THEN
                v_strFEEDBACKMSG := 'Order is sent to Flex: ' || v_strORDERID;
            END IF;

            UPDATE bl_odmast SET
                status = decode(v_strSTATUS,'R','R','T','T','F'),
                FEEDBACKMSG = v_strFEEDBACKMSG,
                last_change = SYSTIMESTAMP
            WHERE blorderid = v_BLORDERID;*/
        ELSE
            -- Cap nhat lai lenh Any goc
            UPDATE bl_odmast SET
                cancelqtty = cancelqtty + remainqtty,
                remainqtty = 0,
                pstatus = pstatus || status,
                status = CASE WHEN sentqtty + ptbookqtty > 0 THEN status ELSE 'R' END,
                FEEDBACKMSG = v_strFEEDBACKMSG,
                last_change = SYSTIMESTAMP
            WHERE blorderid = rec.blorderid;
        END IF;

        -- Cap nhat lai lenh Any goc
        /*UPDATE bl_odmast SET
            cancelqtty = cancelqtty + remainqtty,
            remainqtty = 0,
            pstatus = pstatus || status,
            status = CASE WHEN sentqtty + ptbookqtty > 0 THEN status ELSE 'R' END,
            last_change = SYSTIMESTAMP
        WHERE blorderid = rec.blorderid;*/

    END LOOP;

    plog.setendsection(pkgctx, 'BL_Process_AnyOrder');

EXCEPTION
   WHEN OTHERS
   THEN
        plog.error(pkgctx, 'Exeption BL_Process_AnyOrder: ' || SQLERRM);
        RETURN;
END;

PROCEDURE bl_rejectfo (
   pv_BLORDERID       IN      VARCHAR2,
   pv_FOACCTNO      IN      VARCHAR2,
   pv_Status        IN      VARCHAR2,
   pv_FEEDBACKMSG   IN      VARCHAR2,
   pv_Exectype      IN      varchar2
)
IS
--
-- PURPOSE: CAP NHAT LENH TRUC TIEP KHI BI REJECT
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   15-Nov-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    --v_exectype  varchar2(2);
    v_orgblorderid  varchar2(20);
BEGIN
    plog.setbeginsection(pkgctx, 'bl_rejectfo');
    -- Lay thong tin lenh
    /*SELECT fo.exectype
    INTO v_exectype
    FROM fomast fo
    WHERE fo.acctno = pv_FOACCTNO;*/

    plog.error(pkgctx, 'bl_rejectfo: pv_BLORDERID: ' || pv_BLORDERID || ' pv_FOACCTNO: ' || pv_FOACCTNO || ' v_exectype ' || pv_Exectype);

    if pv_Status = 'R' then
        IF pv_Exectype IN ('NB','NS') THEN
            UPDATE bl_odmast SET
                cancelqtty = remainqtty,
                remainqtty = 0,
                pstatus = pstatus || status,
                status = 'R',
                FEEDBACKMSG = pv_FEEDBACKMSG,
                LAST_CHANGE = SYSTIMESTAMP
            WHERE blorderid = pv_BLORDERID;
        ELSIF pv_Exectype IN ('AB','AS') THEN
            UPDATE bl_odmast SET
                pstatus = pstatus || status,
                status = 'R',
                FEEDBACKMSG = pv_FEEDBACKMSG,
                LAST_CHANGE = SYSTIMESTAMP
            WHERE blorderid = pv_BLORDERID;
            -- Lay thong tin lenh goc
            SELECT bl.refblorderid
            INTO v_orgblorderid
            FROM bl_odmast bl
            WHERE bl.blorderid = pv_BLORDERID;
            -- Cap nhat lenh goc
            UPDATE bl_odmast SET
                edstatus = 'N',
                LAST_CHANGE = SYSTIMESTAMP
            WHERE blorderid = v_orgblorderid;
            -- Cap nhat lenh y/c sua
            UPDATE bl_odmastdtl SET
                pstatus = pstatus || status,
                status = 'R',
                FEEDBACKMSG = pv_FEEDBACKMSG,
                LAST_CHANGE = SYSTIMESTAMP
            WHERE blorderid = v_orgblorderid AND adorderid = pv_BLORDERID;
        ELSIF pv_Exectype IN ('CB','CS') THEN
            -- Cap nhat lenh goc
            UPDATE bl_odmast SET
                edstatus = 'N',
                LAST_CHANGE = SYSTIMESTAMP
            WHERE blorderid = pv_BLORDERID;
            -- Cap nhat lenh y/c huy
            UPDATE bl_odmastdtl SET
                pstatus = pstatus || status,
                status = 'R',
                FEEDBACKMSG = pv_FEEDBACKMSG,
                LAST_CHANGE = SYSTIMESTAMP
            WHERE blorderid = pv_BLORDERID AND exectype IN ('CB','CS');
        END IF;
    end if;
    plog.setendsection(pkgctx, 'bl_rejectfo');

EXCEPTION
   WHEN OTHERS
   THEN
        plog.error(pkgctx, 'Exeption bl_rejectfo: ' || SQLERRM);
        dbms_output.put_line('bl_rejectfo:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;

PROCEDURE bl_getbloombergorderdtl (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_TRADEPLACE       IN       VARCHAR2,
   pv_STATUS           IN       VARCHAR2,
   pv_ACCOUNT           IN      VARCHAR2,
   pv_SYMBOL           IN      VARCHAR2,
   pv_TLID              IN      VARCHAR2,
   pv_CMDID             IN      VARCHAR2
)
IS
--
-- PURPOSE: LAY THONG TIN LENH BLOOMBERG
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THENN   04-July-2013  CREATED
-- ---------   ------  -------------------------------------------

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    v_TradePlace    varchar2(10);
    v_Status        varchar2(10);
    v_Account       varchar2(100);
    v_Symbol        varchar2(100);
BEGIN
    IF pv_TRADEPLACE = 'ALL' THEN
        v_TradePlace := '%%';
    ELSE
        v_TradePlace := pv_TRADEPLACE;
    END IF;

    IF pv_STATUS = 'ALL' THEN
        v_Status := '%%';
    ELSE
        v_Status := pv_STATUS;
    END IF;

    IF pv_ACCOUNT = 'ALL' THEN
        v_Account := '%%';
    ELSE
        v_Account := '%' || pv_ACCOUNT || '%';
    END IF;

    IF pv_SYMBOL = 'ALL' THEN
        v_Symbol := '%%';
    ELSE
        v_Symbol := '%' || pv_SYMBOL || '%';
    END IF;

    -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
    FOR
        SELECT * FROM
            (
               SELECT mst.blorderid, F.TRADERID, BL.BLACCTNO, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, MST.ORDERID, MST.EXECTYPE,
                MST.PRICETYPE, CD2.CDCONTENT DESC_EXECTYPE, TO_CHAR(SB.SYMBOL) SYMBOL,
                MST.ORDERQTTY,MST.QUOTEPRICE, MST.ORSTATUS STATUS, CD1.CDCONTENT DESC_STATUS,
                CD7.CDCONTENT DESC_PRICETYPE, MST.EXECQTTY,
                (CASE WHEN MST.EXECQTTY = 0 THEN 0 ELSE ROUND(MST.EXECAMT/MST.EXECQTTY,0) END) EXECPRICE,
                MST.EXECAMT, MST.REMAINQTTY, MST.CANCELQTTY, MST.ADJUSTQTTY,
                (CASE WHEN MST.CANCELQTTY>0 THEN 'CANCELLED'  WHEN MST.EDITSTATUS='C' THEN 'CANCELLING' ELSE '----' END) CANCELSTATUS,
                (CASE WHEN MST.ADJUSTQTTY>0 THEN 'AMENDED'  WHEN MST.EDITSTATUS='A' THEN 'AMENDING' ELSE '----' END) AMENDSTATUS,
                CD10.CDCONTENT TRADEPLACE,MST.EDITSTATUS EDSTATUS,CD4.CDCONTENT TIMETYPE,
                MST.ORSTATUSVALUE,MST.TIMETYPE TIMETYPEVALUE, MST.MATCHTYPE MATCHTYPEVALUE,
            CASE WHEN MST.ORDERID = F.ORGACCTNO THEN F.ACCTNO ELSE MST.ORDERID END FOACCTNO, '' ERR_DESC, SB.TRADEPLACE TRADEPLACEVL,
                MST.TXTIME
            FROM CFMAST CF, AFMAST AF, (SELECT * FROM OOD UNION SELECT * FROM OODHIST) OOD,
                (SELECT MST.*,
                    (CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C'
                    WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A'
                    WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 THEN '5'
                    WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3'
                    WHEN MST.REMAINQTTY = 0 AND MST.ADJUSTQTTY>0 THEN '10'
                    WHEN MST.REMAINQTTY = 0 AND MST.EXECQTTY>0 AND MST.ORSTATUS = '4' THEN '12' ELSE MST.ORSTATUS END) ORSTATUSVALUE
                FROM
                    (SELECT OD1.*,OD2.EDSTATUS EDITSTATUS
                    FROM ODMAST OD1,(SELECT * FROM ODMAST WHERE EDSTATUS IN ('C','A')) OD2
                    WHERE OD1.ORDERID=OD2.REFORDERID(+) AND SUBSTR(OD1.EXECTYPE,1,1) <> 'C'
                        AND SUBSTR(OD1.EXECTYPE,1,1) <> 'A'
                        AND OD1.VIA = 'L'
                    ) MST
                ) MST,
                SBSECURITIES SB, ALLCODE CD1,ALLCODE CD2, ALLCODE CD4, ALLCODE CD7, ALLCODE CD10,FOMAST F, BL_TRADEREF BL, bl_odmast blo
            WHERE MST.ORSTATUS <> '7' AND AF.ACCTNO=MST.AFACCTNO
                AND MST.ORDERID=OOD.ORGORDERID(+)
                AND BL.AFACCTNO = AF.ACCTNO AND BL.TRADERID = F.TRADERID AND BL.STATUS = 'A'
                AND CF.CUSTID=AF.CUSTID AND SB.CODEID = MST.CODEID
                AND CD1.CDTYPE ='OD' AND CD1.CDNAME='ORSTATUS'
                AND CD1.CDVAL= MST.ORSTATUSVALUE
                AND CD2.CDTYPE ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                AND CD4.CDTYPE ='OD' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                AND CD10.CDTYPE ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=SB.TRADEPLACE
                AND CD7.CDTYPE ='OD' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
               AND MST.ORDERID = F.ORGACCTNO(+) AND MST.EXECTYPE = F.EXECTYPE(+)
               and mst.blorderid = blo.blorderid and blo.blodtype = '3'
               AND cf.CUSTODYCD IN (SELECT CUSTODYCD FROM
                                (SELECT TL.TLID, TL.BRID TLBRID, (select to_char( listagg ( grpid,'|') within group(order by tlid)) odr from tlgrpusers
                                where tlid = pv_TLID) TLGRPID, FNC_CHECK_CMDID_SCOPE(pv_CMDID,'M', pv_TLID) CHKSCOPE,
                                    CF.CUSTID, CF.CUSTODYCD, CF.CAREBY, CF.BRID, INSTR((select to_char( listagg ( grpid,'|') within group(order by tlid)) odr from tlgrpusers
                                where tlid = pv_TLID), CF.CAREBY) IDXGRP,
                                    (CASE WHEN TL.BRID=FNC_GET_REGIONID(CF.BRID) THEN 1 ELSE 0 END) IDXREGION,
                                    (CASE WHEN TL.BRID=CF.BRID THEN 1 ELSE 0 END) IDXSUBBR,
                                    (CASE WHEN TL.BRID=SUBSTR(CF.BRID,1,2) || '01' THEN 1 ELSE 0 END) IDXBR
                                    FROM TLPROFILES TL, CFMAST CF WHERE TL.TLID=pv_TLID) D
                                WHERE D.CHKSCOPE <> 'N'
                                    AND (CASE WHEN D.CHKSCOPE='C' THEN IDXGRP ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='S' THEN IDXSUBBR ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='B' THEN IDXBR ELSE 1 END) > 0
                                    AND (CASE WHEN D.CHKSCOPE='R' THEN IDXREGION ELSE 1 END) > 0)
            )
            WHERE (BLACCTNO LIKE v_Account OR CUSTODYCD LIKE v_Account OR AFACCTNO LIKE v_Account)
                AND symbol LIKE v_Symbol
            ORDER BY blorderid DESC;
EXCEPTION
   WHEN OTHERS
   THEN
        dbms_output.put_line('bl_getbloombergorder:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;


BEGIN
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
END pck_fo_bl;
/
