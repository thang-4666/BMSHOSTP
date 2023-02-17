SET DEFINE OFF;
CREATE OR REPLACE PACKAGE fopks_api IS

  /** ----------------------------------------------------------------------------------------------------
  ** Module: FO - API
  ** Description: FO API
  ** and is copyrighted by FSS.
  **
  **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
  **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
  **    graphic, optic recording or otherwise, translated in any language or computer language,
  **    without the prior written permission of Financial Software Solutions. JSC.
  **
  **  MODIFICATION HISTORY
  **  Person      Date           Comments
  **  ThongPM     14/04/2011     Created
  ** (c) 2008 by Financial Software Solutions. JSC.
  ----------------------------------------------------------------------------------------------------*/

  procedure sp_login(p_username      varchar2,
                     p_password      varchar2,
                     p_customer_id   in out varchar2,
                     p_customer_info in out varchar2,
                     p_err_code      in out varchar2,
                     p_err_param     in out varchar2,
                     --Log thong tin thiet bi
                     p_ipaddress          IN  VARCHAR2,
                     p_via                IN  VARCHAR2,
                     p_validationtype     IN  VARCHAR2,
                     p_devicetype         IN  VARCHAR2,
                     p_device             IN  VARCHAR2);
                     --End;

  procedure sp_focore_login(USERNAME     varchar2,
                            PASSWORD     varchar2,
                            SenderCompID varchar2);

  function fn_logout(p_username  varchar2,
                     p_err_code  in out varchar2,
                     p_err_param out varchar2) return number;

  function fn_check_password_trading(p_username  varchar2,
                                     p_tpassword varchar2,
                                     p_err_code  in out varchar2,
                                     p_err_param out varchar2) return number;

  function fn_get_members(p_customer_id varchar2,
                          p_err_code    in out varchar2,
                          p_err_param   out varchar2) return number;

  procedure sp_audit_log(p_key varchar2, p_text varchar2);

  procedure sp_audit_authenticate(p_key  varchar2,
                                  p_type char,
                                  p_channel varchar2,
                                  p_text varchar2);

  function fn_is_ho_active return boolean;
  --procedure pr_gen_buf_ci_account(p_acctno varchar2 default null);
  --procedure pr_gen_buf_se_account(p_acctno varchar2 default null);
procedure pr_get_ciacount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2);

PROCEDURE PR_OPENACCT_CheckIdcode --Buoc 5: Check so CMND
    (p_idcode IN VARCHAR2, --So CMND
    --p_iddate      IN VARCHAR2,--Ngay cap format DD/MM/YYYY
    --p_idplace      IN VARCHAR2, --Noi cap
    p_err_code IN OUT VARCHAR2,
    p_errparm  IN OUT VARCHAR2);

PROCEDURE PR_OPENACCT_view
    (
        p_refcursor in out pkg_report.ref_cursor,
        p_key in VARCHAR2
    );
procedure PR_OPENACCT_view_clob
    (p_key in VARCHAR2,
     p_result in out clob);
PROCEDURE pr_GetListCaschd
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     CATYPE         IN  VARCHAR2,
     F_DATE          IN  VARCHAR2,
     T_DATE          IN  VARCHAR2
     );
PROCEDURE pr_GetListOrderNtoT
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN VARCHAR2
     ) ;

procedure pr_get_ciSummaryAcount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2);

procedure pr_get_ciSummaryAcountNew
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2);

PROCEDURE pr_DealLoanPayment_by_autoid
  (p_autoid IN VARCHAR2,
   p_prinAmount in  number ,
   p_intAmount in  number ,
   p_fee in  number ,
   p_err_code  OUT varchar2,
   p_err_message  OUT varchar2
  );


procedure pr_get_seacount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2);
--PROCEDURE pr_gen_buf_od_account(p_acctno varchar2 default null);
PROCEDURE pr_CheckCashTransfer(p_account varchar, --- so tieu khoan chuyen
                            p_type varchar2, --- loai chuyen khoan (0 : chuyen khoan noi bo, 1 : chuyen khoan ra ngan hang)
                            p_amount number,--- so tien chuyen khoan
                            p_toaccount varchar2, -- so tieu khoan nhan or so tai khoan ngan hang.
                            p_feecd     varchar2, --- bieu phi.
                            p_feetype   varchar2, --- kieu phi (0 : phi trong, 1 : phi ngoai)
                            p_refamt  OUT  number, --- so tien ben nhan duoc huong.
                            p_feeamt OUT number, --- so phi
                            p_vatamt OUT number,  ---- so thue
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2);
  PROCEDURE pr_InternalTransfer(p_account varchar,
                            p_toaccount  varchar2,
                            p_amount number,
                            p_desc varchar2,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2);
 PROCEDURE pr_ExternalTransfer(p_account varchar,
                            p_bankid varchar2,
                            p_benefbank varchar2,
                            p_benefacct varchar2,
                            p_benefcustname varchar2,
                            p_beneflicense varchar2,
                            p_amount number,
                            p_feeamt number,
                            p_vatamt number,
                            p_iorofee number,
                            p_desc varchar2,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2,
                            p_ipaddress VARCHAR2 DEFAULT '',
                            p_via VARCHAR2 DEFAULT '',
                            p_validationtype VARCHAR2 DEFAULT '',
                            p_devicetype VARCHAR2 DEFAULT '',
                            p_device VARCHAR2 DEFAULT '');
 procedure pr_PlaceOrder(p_functionname in varchar2,
                        p_username in varchar2,
                        p_acctno in varchar2,
                        p_afacctno in varchar2,
                        p_exectype in varchar2,
                        p_symbol in varchar2,
                        p_quantity in number,
                        p_quoteprice in number,
                        p_pricetype in varchar2,
                        p_timetype in varchar2,
                        p_book in varchar2,
                        p_via in varchar2,
                        p_dealid in varchar2,
                        p_direct in varchar2,
                        p_effdate in varchar2,
                        p_expdate in varchar2,
                        p_tlid  IN  VARCHAR2,
                        p_quoteqtty in number,
                        p_limitprice in number,
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2,
                        p_refOrderId in varchar2 DEFAULT '',
                        p_blOrderid   in varchar2 default '',
                        P_NOTE        IN VARCHAR2 DEFAULT '',
                        p_ipaddress in  varchar2 default '',--2.1.3.0: tt 134
                        p_validationtype in varchar2 default '',
                        p_orderdata in varchar2 default '',
                        p_macaddress in varchar2 default '',
                        --28/09/2022 log ip thiet bi
                        p_devicetype IN varchar2 default '',
                        p_device  IN varchar2 default '',
                        p_model in varchar2 default '',
                        p_versionDevice in varchar2 default '',
                        p_versionCode in varchar2 default '',
                        --End 28/09/2022
                        p_isBuyIn        IN VARCHAR2 DEFAULT 'N'
                        );
procedure pr_get_rightofflist(p_refcursor in out pkg_report.ref_cursor,p_custodycd IN varchar2 ,p_afacctno in VARCHAR2, p_symbol IN VARCHAR2);
procedure pr_get_rightofflistsimple(p_refcursor in out pkg_report.ref_cursor,p_custodycd IN varchar2 ,p_afacctno in VARCHAR2, p_symbol IN VARCHAR2);

--PROCEDURE pr_trg_account_log (p_acctno in VARCHAR2, p_mod varchar2);
procedure pr_get_Portfolio(p_refcursor in out pkg_report.ref_cursor,
                             CUSTODYCD    IN VARCHAR2,
                             AFACCTNO       IN  VARCHAR2,
                             F_DATE         IN  VARCHAR2,
                             T_DATE         IN  VARCHAR2,
                             SYMBOL         IN  VARCHAR2,
                             GETTYPE        IN  VARCHAR2
                            ); -- Lay len danh muc dau tu cua khach hang
procedure pr_fo_fobannk2od(p_foorderid in varchar2);--dong bo lenh cua khach hang
PROCEDURE pr_GetOrder
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     STATUS         IN  VARCHAR2,
     P_TLID         IN  VARCHAR2 DEFAULT 'ALL'
     ); -- Lay thong tin lenh giao dich
PROCEDURE pr_GetGTCOrder
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     STATUS         IN  VARCHAR2);
PROCEDURE pr_GetTradeDiary
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2); -- Lay thong tin nhat ky giao dich
PROCEDURE pr_GetMatchOrder
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     P_TLID       IN  VARCHAR2 DEFAULT 'ALL'
     ); -- Lay thong tin lenh khop
PROCEDURE pr_RightoffRegiter
    (p_camastid IN   varchar,
    p_account   IN   varchar,
    p_qtty      IN   number,
    P_AMOUNT    IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2,
    p_ipaddress        IN     VARCHAR2 DEFAULT '',
    p_via              IN     VARCHAR2 DEFAULT '',
    p_validationtype   IN     VARCHAR2 DEFAULT '',
    p_devicetype       IN     VARCHAR2 DEFAULT '',
    p_device           IN     VARCHAR2 DEFAULT ''
    );
PROCEDURE pr_GetInfor4AdvancePayment
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2
    ); -- LAY THONG TIN DE LAM DE NGHI UTTB
PROCEDURE pr_GetCashStatement
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN       VARCHAR2,
     T_DATE         IN       VARCHAR2
    ); -- Sao ke tien
PROCEDURE pr_GetSecuritiesStatement
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN       VARCHAR2,
     T_DATE         IN       VARCHAR2,
     SYMBOL         IN  VARCHAR2
    ); -- Sao ke chung khoan
PROCEDURE pr_GetCashTransfer
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     STATUS         IN  VARCHAR2
     );    -- Lay thong tin chuyen khoan tien
PROCEDURE pr_GetRightOffInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     ); -- LAY THONG TIN GD QUYEN MUA
PROCEDURE pr_AdvancePayment
    (p_afacctno varchar,
     p_txdate date,
     p_duedate DATE,
     p_advamt number,
     p_feeamt NUMBER,
     p_advdays NUMBER,
     p_maxamt    NUMBER,
     p_desc varchar2,
     p_err_code  OUT varchar2,
     p_err_message  OUT VARCHAR2
    ); -- HAM THUC HIEN UNG TRUOC TIEN BAN
PROCEDURE pr_AdjustCostprice_Online
    (   p_afacctno varchar,
        p_symbol    VARCHAR2,
        p_newcostprice  number,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN DIEU CHINH GIA VON ONLINE
PROCEDURE pr_GetAdvancedPayment
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN VARCHAR2,
     T_DATE         IN VARCHAR2,
     STATUS         IN VARCHAR2,
     ADVPLACE       IN VARCHAR2
    ); -- LAY THONG TIN HOP DONG UNG TRUOC DA THUC HIEN
PROCEDURE pr_Allocate_Guarantee_BD
    (   p_custodycd VARCHAR,
        p_afacctno varchar,
        p_amount  number,
        p_userid    varchar,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- Thuc hien cap han muc bao lanh tien mua tren MHMG
PROCEDURE pr_GetSecureRatio
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2,
     PRICETYPE      IN  VARCHAR2,
     TIMETYPE       IN  VARCHAR2,
     QUOTEPRICE     IN  NUMBER,
     ORDERQTTY      IN  NUMBER,
     VIA            IN  VARCHAR2 DEFAULT 'F'
    ); -- HAM LAY TY LE KY Q
    PROCEDURE Pr_Change_Pass_Online
    (   p_username      varchar2,
        p_fullname      varchar2,
        p_idcode        varchar2,
        P_IDDATE        VARCHAR2 DEFAULT NULL,
        P_DATEOFBIRTH   VARCHAR2 DEFAULT NULL,
        P_MOBILESMS     VARCHAR2 DEFAULT NULL,
        p_err_code      OUT varchar2,
        p_err_message   OUT varchar2,
        --Log thong tin thiet bi
        p_ipaddress      in varchar2 default '', --vcb.2021.04.0.01
        p_via            in varchar2 default '',
        p_validationtype in varchar2 default '',
        p_devicetype     IN varchar2 default '',
        p_device         IN varchar2 default ''
        --End
    );
PROCEDURE pr_OnlineUpdateCustomerInfor
    (   p_custodycd VARCHAR,
        p_custid varchar,
        p_address   VARCHAR2,
        p_phone     VARCHAR2,
        p_mobile    VARCHAR2,
        p_mobilesms    VARCHAR2,
        p_coaddress    VARCHAR2,
        p_cophone  VARCHAR2,
        p_email     VARCHAR2,
        p_sex      VARCHAR2,
        p_birthdate VARCHAR2,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN CAP NHAT THONG TIN KHACH HANG ONLINE
PROCEDURE pr_UpdateCustomerInfor
    (   p_custodycd VARCHAR,
        p_custid varchar,
        p_fldname   VARCHAR2,
        p_fldval    VARCHAR2,
        p_desc      varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2,
        --Log thong tin thiet bi
        p_ipaddress         VARCHAR2,
        p_via               VARCHAR2,
        p_validationtype    VARCHAR2,
        p_devicetype        VARCHAR2,
        p_device            VARCHAR2
        --End
    ); -- HAM THUC HIEN CAP NHAT THONG TIN KHACH HANG ONLINE
PROCEDURE pr_UpdateSubAcctnoInfor
    (   p_custodycd VARCHAR,
        p_custid    varchar,
        p_afacctno  varchar,
        p_fldname   VARCHAR2, -- AUTOTRF
        p_fldval    VARCHAR2,
        p_desc      varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN CAP NHAT THONG TIN TIEU KHOAN ONLINE


/*PROCEDURE pr_CashTransferWithIDCode
    (   p_afacctno varchar,
        p_BENEFCUSTNAME   VARCHAR2,
        p_RECEIVLICENSE     VARCHAR2,
        p_RECEIVIDDATE    VARCHAR2,
        p_RECEIVIDPLACE  VARCHAR2,
        p_BANKNAME     VARCHAR2,
        p_CITYBANK     VARCHAR2,
        p_CITYEF     VARCHAR2,
        p_AMT           NUMBER,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN CHUYEN KHOAN RA NGOAI VOI CMND*/
FUNCTION fn_GetODACTYPE
    (AFACCTNO       IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     CODEID         IN  VARCHAR2,
     TRADEPLACE     IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2,
     PRICETYPE      IN  VARCHAR2,
     TIMETYPE       IN  VARCHAR2,
     AFTYPE         IN  VARCHAR2,
     SECTYPE        IN  VARCHAR2,
     VIA            IN  VARCHAR2
    ) RETURN VARCHAR2; -- LAY THONG TIN LOAI HINH LENH
PROCEDURE pr_GetGroupDFInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2
     ); -- LAY THONG TIN KHOAN VAY DF TONG CHUA THANH TOAN
PROCEDURE pr_GetDetailDFInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     GROUPDFID      IN  VARCHAR2
     ); -- LAY THONG TIN KHOAN VAY DF CHI TIET
PROCEDURE pr_PaidDealOnline
    (   p_afacctno varchar,
        p_groupdealid    VARCHAR2,
        p_paidamt  number,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN THANH TOAN DEAL VAY
function fn_CheckActiveSystem
    return NUMBER; -- Check host 1 active or inactive
PROCEDURE pr_GetDFTransHistory
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    CUSTODYCD       IN VARCHAR2,
    AFACCTNO       IN  VARCHAR2,
    F_DATE         IN VARCHAR2,
    T_DATE         IN VARCHAR2,
    GROUPDFID      IN VARCHAR2,
    SYMBOL         IN   VARCHAR2
    ); -- Lay thong tin lich su giao dich cam co
PROCEDURE pr_AllocateAVDL3rdAccount
    (   p_custodycd VARCHAR,
        p_afacctno varchar,
        p_amount  number,
        p_userid    varchar,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN CAP HAN MUC BAO LANH CHO TK LUU KY TAI NOI KHAC
PROCEDURE pr_AllocateStock3rdAccount
    (   p_custodycd VARCHAR,
        p_afacctno varchar,
        p_symbol    VARCHAR,
        p_qtty  number,
        p_userid    varchar,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN CAP THEM SO DU CK CHO TK LUU KY TAI NOI KHAC
PROCEDURE pr_RightoffRegiter2BO
    (p_camastid IN   varchar,
    p_account   IN   varchar,
    p_qtty      IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
    ); -- HAM THUC HIEN GD DANG KY QUYEN MUA
PROCEDURE pr_RORSyn2BO;
PROCEDURE pr_RORSynBank2BO
    (
    p_RQLogID   IN   NUMBER
    ); -- HAM THUC HIEN GOI GD DANG KY QUYEN MUA TH KET NOI NH
PROCEDURE pr_ROR2BO
    (
    p_RQLogID   IN   NUMBER,
    p_err_code  OUT  NUMBER,
    p_err_message   OUT  varchar2
    ); -- HAM THUC HIEN DANG KY QUYEN MUA CHO KHACH HANG KO KET NOI NH
/*FUNCTION fn_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2; -- HAM THUC HIEN LAY SO HIEU LENH GOC CUA LENH*/
PROCEDURE pr_get_gtcorder_root_hist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTID    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     STATUS         IN  VARCHAR2); -- LAY LENH GOC CUA LENH GTC
PROCEDURE pr_GetDFPaidHistory
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    pv_RowCount    IN OUT  NUMBER,
    pv_PageSize    IN  NUMBER,
    pv_PageIndex   IN  NUMBER,
    AFACCTNO       IN  VARCHAR2,
    GROUPDFID      IN VARCHAR2,
    F_DATE         IN VARCHAR2,
    T_DATE         IN VARCHAR2
    ); -- LAY THONG TIN THANH TOAN KHOAN VAY DF
PROCEDURE pr_GetGroupDFInforAll
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     pv_RowCount    IN OUT  NUMBER,
     pv_PageSize    IN  NUMBER,
     pv_PageIndex   IN  NUMBER,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     ); -- LAY THONG TIN KHOAN VAY DF
PROCEDURE pr_GetDetailDFInforAll
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     --pv_RowCount    IN OUT  NUMBER,
     --pv_PageSize    IN  NUMBER,
     --pv_PageIndex   IN  NUMBER,
     AFACCTNO       IN  VARCHAR2,
     GROUPDFID      IN  VARCHAR2
     --F_DATE         IN  VARCHAR2,
     --T_DATE         IN  VARCHAR2
     ); -- LAY THONG TIN KHOAN VAY DF CHI TIET
PROCEDURE pr_GetDFPaidDetail
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    pv_TXDATE       IN  VARCHAR2,
    pv_TXNUM      IN VARCHAR2
    ); -- LAY CHI TIET SO CK GIAI TOA (GD 2246 ONLY)
PROCEDURE pr_RefreshCIAccount
    (   p_afacctno varchar,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    ); -- HAM THUC HIEN CAP NHAT THONG TIN SUC MUA
procedure pr_get_rightinfo
    (p_refcursor in out pkg_report.ref_cursor,
    F_DATE in VARCHAR2,
    T_DATE  IN  varchar2,
    PV_CUSTODYCD  IN  VARCHAR2,
    PV_AFACCTNO  IN  VARCHAR2,
    ISCOM             IN       VARCHAR2);--Ham tra cuu su kien quyen
PROCEDURE pr_GetBonds2SharesList
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2
     ); -- HAM LAY DANH SACH THQ CHUYEN TRAI PHIEU --> CO PHIEU
PROCEDURE pr_Bonds2SharesRegister
    (p_caschdautoid IN   varchar,
    p_afacctno   IN   varchar,
    p_qtty      IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
    ); -- HAM THUC HIEN DANG KY CHUYEN TRAI PHIEU --> CO PHIEU
PROCEDURE pr_LoanHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     );--HAM TRA CUU DU NO

PROCEDURE pr_TermDepositWithdraw
    (p_afacctno     IN  varchar,
    p_tdacctno      IN  VARCHAR,
    p_withdrawamt   IN  number,
    p_desc          IN  varchar2,
    p_err_code      OUT varchar2,
    p_err_message   OUT varchar2
    ); -- HAM THUC HIEN GIAO DICH RUT TIEN TIET KIEM
PROCEDURE pr_OnlineRegister(
       p_CustomerType IN VARCHAR2,
       p_CustomerName IN VARCHAR2,
       p_CustomerBirth IN VARCHAR2,
       p_IDType IN VARCHAR2,
       p_IDCode IN VARCHAR2,
       p_Iddate IN VARCHAR2,
       p_Idplace IN VARCHAR2,
       p_Expiredate IN VARCHAR2,
       p_Address IN VARCHAR2,
       p_Taxcode IN VARCHAR2,
       p_PrivatePhone IN VARCHAR2,
       p_Mobile IN VARCHAR2,
       p_Fax IN VARCHAR2,
       p_Email IN VARCHAR2,
       p_Office IN VARCHAR2,
       p_Position IN VARCHAR2,
       p_Country IN VARCHAR2,
       p_CustomerCity IN VARCHAR2,
       p_TKTGTT IN VARCHAR2,
       p_TradingOther IN VARCHAR2,
       p_OtherAccount1 IN VARCHAR2,
       p_OtherCompany1 IN VARCHAR2,
       p_OtherAccount2 IN VARCHAR2,
       p_OtherCompany2 IN VARCHAR2,
       p_OtherAccount3 IN VARCHAR2,
       p_OtherCompany3 IN VARCHAR2,
       p_OtherAccount4 IN VARCHAR2,
       p_OtherCompany4 IN VARCHAR2,
       p_OtherAccount5 IN VARCHAR2,
       p_OtherCompany5 IN VARCHAR2,
       p_OtherAccount6 IN VARCHAR2,
       p_OtherCompany6 IN VARCHAR2,
       p_OtherAccount7 IN VARCHAR2,
       p_OtherCompany7 IN VARCHAR2,
       p_PlaceOrderPhone IN VARCHAR2,
       p_MatchedOrderReportSms IN VARCHAR2,
       p_PlaceOrderOnline IN VARCHAR2,
       p_MatchedOrderReportEmail IN VARCHAR2,
       p_CashinadvanceOnline IN VARCHAR2,
       p_StatementOnline IN VARCHAR2,
       p_CashinadvanceAuto IN VARCHAR2,
       p_OrderTableReportEmail IN VARCHAR2,
       p_CashtransferOnline IN VARCHAR2,
       p_NewsBVSCemail IN VARCHAR2,
       p_AdditionalSharesOnline IN VARCHAR2,
       p_SearchOnline IN VARCHAR2,
       p_BankAccountName1 IN VARCHAR2,
       p_BankIDCode1 IN VARCHAR2,
       p_BankIDDate1 IN VARCHAR2,
       p_BankIDPlace1 IN VARCHAR2,
       p_BankAccountNumber1 IN VARCHAR2,
       p_BankName1 IN VARCHAR2,
       p_Branch1 IN VARCHAR2,
       p_BankCity1 IN VARCHAR2,
       p_BankAccountName2 IN VARCHAR2,
       p_BankIDCode2 IN VARCHAR2,
       p_BankIDDate2 IN VARCHAR2,
       p_BankIDPlace2 IN VARCHAR2,
       p_BankAccountNumber2 IN VARCHAR2,
       p_BankName2 IN VARCHAR2,
       p_Branch2 IN VARCHAR2,
       p_BankCity2 IN VARCHAR2,
       p_BankAccountName3 IN VARCHAR2,
       p_BankIDCode3 IN VARCHAR2,
       p_BankIDDate3 IN VARCHAR2,
       p_BankIDPlace3 IN VARCHAR2,
       p_BankAccountNumber3 IN VARCHAR2,
       p_BankName3 IN VARCHAR2,
       p_Branch3 IN VARCHAR2,
       p_BankCity3 IN VARCHAR2,
       p_SMSorCard IN VARCHAR2,
       p_SMSPhoneNumber IN VARCHAR2,
       p_err_code  OUT varchar2,
       p_err_message  OUT varchar2
    );--Ham dang ky online
  PROCEDURE pr_GetTDhist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     );--Ham tra cuu tiet kiem
PROCEDURE pr_GetNetAsset
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     );--Ham tra cuu tong tai san

PROCEDURE pr_GetConvertBondHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     );--Ham tra cuu chuyen doi trai phieu thanh co phieu
PROCEDURE pr_GetRePaymentHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     );--Ham tra cuu thong tin tra no
PROCEDURE pr_GetConfirmOrderHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2
     );--Ham tra cuu lenh xac nhan
FUNCTION fn_GetSECostPrice
    (ACCTNO       IN  VARCHAR2
    ) RETURN NUMBER; -- LAY THONG TIN GIA VON CHUNG KHOAN
-- Lay phi chuyen khoan ra ngoai
function fn_getExTransferMoneyFee(p_amount number,
                                  p_feecd varchar2
                                ) return number;
-- lay phi chuyen khoan noi bo
function fn_getInTransferMoneyFee(p_account varchar,
                                  p_toaccount  varchar2,
                                  p_amount number
                                ) return number ;

PROCEDURE pr_GetMobileAdvInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     );
PROCEDURE pr_GetMobileAdvFee
    (p_AFACCTNO     IN VARCHAR2,
     p_type         in varchar2,
     p_amount       in number,
     p_fee          out number,
     p_err_code     OUT varchar2,
     p_err_message  OUT varchar2
     );
PROCEDURE pr_MobilleAdvancePayment
    (p_AFACCTNO     IN VARCHAR2,
     p_amount       in number,
     p_fee          in number,
     p_err_code     OUT varchar2,
     p_err_message  OUT varchar2,
     --log thong tin thiet bi
     p_ipaddress        IN     VARCHAR2 DEFAULT '',                 --1.0.6.0
     p_via              IN     VARCHAR2 DEFAULT '',
     p_validationtype   IN     VARCHAR2 DEFAULT '',
     p_devicetype       IN     VARCHAR2 DEFAULT '',
     p_device           IN     VARCHAR2 DEFAULT ''
     --End
     );
PROCEDURE pr_Transfer_SE_account(p_trfafacctno varchar2,
                                p_rcvafacctno varchar2,
                                p_symbol    VARCHAR2,
                                p_quantity varchar2,
                                p_blockedqtty varchar2,
                                p_price     in number DEFAULT 0,
                                p_err_code  OUT varchar2,
                                p_err_message out varchar2);
PROCEDURE pr_get_info_2239(p_afacctno in varchar2,
                                p_symbol  in  VARCHAR2,
                                p_MrRate OUT number ,
                                p_MrPrice OUT number ,
                                p_avlpp  OUT number );

PROCEDURE pr_Transfer_SE_account_2239(p_trfafacctno in varchar2,
                                p_rcvafacctno in varchar2,
                                p_symbol  in  VARCHAR2,
                                p_quantity in number,
                                p_AMT     in number DEFAULT 0,
                                p_err_code  OUT varchar2,
                                p_err_message out varchar2);
PROCEDURE pr_GetSeInternalTransferInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     );
procedure pr_get_PNL_executed
    (p_refcursor    in out pkg_report.ref_cursor,
    p_custodycd     in VARCHAR2,
    p_afacctno      IN  varchar2,
    SYMBOL          IN  VARCHAR2,
    F_DATE         IN VARCHAR2,
    T_DATE         IN VARCHAR2
    );
procedure pr_get_MarginT3Indue
    (p_refcursor    in out pkg_report.ref_cursor,
        p_tlid     in VARCHAR2
    );
procedure pr_get_OD_info
    (p_refcursor    in out pkg_report.ref_cursor,
    pv_custodycd     in VARCHAR2,
    pv_afacctno      IN  varchar2,
    pv_FDATE         IN VARCHAR2,
    pv_TDATE         IN VARCHAR2
    ); --- tra cuu lenh tong hop
PROCEDURE pr_updatepassonline
    (p_username varchar,
    P_pwtype   varchar2,
    P_password   varchar2,
    p_err_code  OUT varchar2,
    p_err_message out varchar2
    );

PROCEDURE pr_updatepassonline_web
  (p_username varchar,
  P_pwtype   varchar2,
  P_old_loginpass   varchar2,
  P_new_loginpass   varchar2,
  P_old_tradingpass   varchar2,
  P_new_tradingpass   varchar2,
  p_err_code  OUT varchar2,
  p_err_message out varchar2
  );

procedure pr_EmailSMSRegister
    (
    pv_custodycd     in VARCHAR2,
    pv_code     in VARCHAR2,
    pv_register in varchar2,
    p_err_code  OUT varchar2,
    p_err_message out varchar2
    ) ;
procedure pr_getEmailSMSRegister
    (
    p_refcursor    in out pkg_report.ref_cursor,
    pv_custodycd     in VARCHAR2
    );
PROCEDURE pr_Tradelot_Retail
    (   p_sellafacctno varchar2,
        p_symbol    VARCHAR2,
        p_quantity varchar2,
        p_quoteprice varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    );  --- dang ky ban chung khoan lo le.

PROCEDURE pr_Cancel_Tradelot_Retail
    (
        p_sellafacctno varchar2,
        p_symbol    VARCHAR2,
        p_txnum varchar2,
        p_txdate varchar2,
        p_err_code  OUT varchar2,
        p_err_message out varchar2
    ); --Huy dang ky ban lo le.
PROCEDURE pr_place_order_1_firm
(
    p_sell_afaccount    IN VARCHAR2,
    p_sell_exectype     IN VARCHAR2,
    p_buy_afaccount     IN VARCHAR2,
    p_buy_exectype      IN VARCHAR2,
    p_symbol            IN VARCHAR2,
    p_orderqtty         IN NUMBER,
    p_clearday          IN NUMBER,
    p_orderprice        IN NUMBER,
    p_via               IN VARCHAR2,
    p_wsname            IN VARCHAR2,
    p_ip_address        IN VARCHAR2,
    p_tlid              IN VARCHAR2,
    p_err_code          OUT VARCHAR2,
    p_err_message       OUT VARCHAR2

); -- Dat lenh thoa thuan cung firm

PROCEDURE pr_CreateDFGroup
(
    p_custodycd         IN VARCHAR2,
    p_afacctno          IN VARCHAR2,
    p_dftype            IN VARCHAR2,
    p_RlsAmount         IN NUMBER,
    p_codeid            IN VARCHAR2,
    p_qtty              IN NUMBER,
    p_symboltype        IN VARCHAR2,
    p_REF               IN VARCHAR2,
    p_err_code          OUT VARCHAR2,
    p_err_message       OUT VARCHAR2

); -- Dat lenh thoa thuan cung firm

PROCEDURE pr_getAcountInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTODYCD    IN VARCHAR2
     );
PROCEDURE pr_ca_rightoff
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_SYMBOL    IN VARCHAR2, --- MA CK CHOT.
     P_FRDATE    IN VARCHAR2, --- LOC THEO NGAY DANG KY CUOI CUNG.
     P_TODATE    IN VARCHAR2,
     P_TELLERID  IN VARCHAR2 --- MA USER DANG NHAP.
     );

PROCEDURE pr_Allocate_AdvPayment(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2, pv_lngTOTALAMT IN NUMBER);
PROCEDURE pr_GetInfo4Margin(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2);
PROCEDURE pr_GetCash4t3(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2);

PROCEDURE pr_GetSecbasket(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strBASKETID IN VARCHAR2);
PROCEDURE pr_GetSecbasket_AF(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2);
PROCEDURE pr_getAFAcountInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_AFACCTNO  IN VARCHAR2
     );
FUNCTION fn_get_hose_time RETURN VARCHAR2;
procedure pr_get_ci_transfer_amount
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2,
    p_type in varchar2);
 procedure pr_get_ci_transfer_amount_1107
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2,
    p_type in varchar2);
PROCEDURE pr_GetRegisterOnlineServices
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTID       IN  VARCHAR2
     );
PROCEDURE pr_GetOTFUNCService
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR
     );
PROCEDURE pr_RegisterOnlineServices
    (P_CUSTID       IN  VARCHAR2,
     P_OTFUNCID     IN  VARCHAR2,
     P_ISREGIS      IN   VARCHAR2,
     P_via          IN  VARCHAR2,--Ngay 04/09/2018 NamTv them chinh sua chu ky so
     p_err_code out varchar2,
     p_err_message out VARCHAR2
     );
PROCEDURE pr_ExtendMarginDeal
  (p_autoid IN VARCHAR2,
  p_todate IN VARCHAR2,
  p_feetype IN VARCHAR2,
  p_err_code  OUT varchar2,
  p_err_message  OUT varchar2
  );
PROCEDURE pr_OpenContract
    (ID /*P_ID*/ IN NUMBER,
Area /*P_AREA*/ IN VARCHAR2,
AccountName /*P_FULLNAME*/ IN VARCHAR2,
Sex /*P_SEX*/ IN VARCHAR2,
DateOfBirth /*P_DATEOFBIRTH*/ IN VARCHAR2,
PlaceOfBirth /*P_BIRTHPLACE*/ IN VARCHAR2,
RegistrationNumber /*P_IDCODE*/ IN VARCHAR2,
DateOfIssue  /*P_IDDATE*/ IN VARCHAR2,
PlaceOfIssue /*P_IDPLACE*/ IN VARCHAR2,
PermanentAddress /*P_ADDRESS*/ IN VARCHAR2,
MailingAddress /*P_RECEIVEADDRESS*/ IN VARCHAR2,
PhoneNo /*P_PHONE*/ IN VARCHAR2,
Email  /*P_EMAIL*/ IN VARCHAR2,
VcbAccountNo  /*P_VCBACCOUNT*/ IN VARCHAR2,
TaxNo /*P_TAXNUMBER*/ IN VARCHAR2,
CompanyInfo /*P_PLACEOFWORK*/ IN VARCHAR2,
Position /*P_POSITION*/ IN VARCHAR2,
Industry /*P_TYPEOFWORK*/ IN VARCHAR2,
SpouseName /*P_PARTNERNAME*/ IN VARCHAR2,
SpousePosition /*P_PARTNERPOS*/ IN VARCHAR2,
SpouseIndustry /*P_PARTNERWORK*/ IN VARCHAR2,
SpouseMobileNo /*P_PARTNERPHONE*/ IN VARCHAR2,
Reg_Internet /*P_ISONLTRADE*/ IN VARCHAR2,
Reg_Phone /*P_ISTELTRADE*/ IN VARCHAR2,
Reg_Sms /*P_ISMATCHSMS*/ IN VARCHAR2,
Reg_Info /*P_ISOTHERSMS*/ IN VARCHAR2,
Reg_Email /*P_ISNEWSEMAIL*/ IN VARCHAR2,
Target_Income /*P_INCOMECUST*/ IN NUMBER,
Target_LongGrowth /*P_LONGTERM*/ IN NUMBER,
Target_MediumGrowth /*P_MIDTERM*/ IN NUMBER,
Target_ShortGrowth /*P_SHORTTERM*/ IN NUMBER,
Risk_Low /*P_LOWRISK*/ IN NUMBER,
Risk_Average /*P_MIDRISK*/ IN NUMBER,
Risk_High /*P_HIGHRISK*/ IN NUMBER,
Asset_Income /*P_INVINCOME*/ IN NUMBER,
Asset_Spouse  /*P_INCOMEPARTNER*/ IN NUMBER,
Invest_Knowledge /*P_INVESTKNOW*/ IN NUMBER,
Invest_Experience /*P_SECINV*/ IN VARCHAR2,
CompanyNameOfManager /*P_COMPCUSTMAN*/ IN VARCHAR2,
CompanyNameOfHolding5Percent /*P_COMPCUSTCAP*/ IN VARCHAR2,
CommissionAccount /*P_ISAUTHACC*/ IN NUMBER,
CommissionName /*P_AUTHNAME*/ IN VARCHAR2,
CommissionMobile /*P_AUTHTEL*/ IN VARCHAR2,
OtherSecuritiesAccountNo /*P_OTHERACCOUNT*/ IN VARCHAR2,
VCBSRelation /*P_RELATIVE*/ IN VARCHAR2,
CreatedBy /*P_TLID*/ IN VARCHAR2,
CreatedDate /*P_OPNDATE*/ IN VARCHAR2,
UpdatedBy /*P_UPDATEBY*/ IN VARCHAR2,
UpdatedDate /*P_UPDATEDATE*/ IN VARCHAR2,
IsDeleted /*P_ISDELETED*/ IN VARCHAR2,
DeletedBy /*P_DELETEDBY*/ IN VARCHAR2,
DeletedDate /*P_DELETEDDATE*/ IN VARCHAR2,
FATCA_Answers /*P_FATCAANS*/ IN VARCHAR2,
Reg_GdMuKyQuyCnTienBanCK  /*P_ISMARGINTRF*/ IN VARCHAR2,
FolderNo /*p_FolderNo*/ in varchar2,
MobileNo /*P_MOBILE*/ IN VARCHAR2,
     p_err_code out varchar2,
     p_err_message out VARCHAR2
     );
PROCEDURE pr_UpdateContract
    (ID /*P_ID*/ IN NUMBER,
Area /*P_AREA*/ IN VARCHAR2,
AccountName /*P_FULLNAME*/ IN VARCHAR2,
Sex /*P_SEX*/ IN VARCHAR2,
DateOfBirth /*P_DATEOFBIRTH*/ IN VARCHAR2,
PlaceOfBirth /*P_BIRTHPLACE*/ IN VARCHAR2,
RegistrationNumber /*P_IDCODE*/ IN VARCHAR2,
DateOfIssue  /*P_IDDATE*/ IN VARCHAR2,
PlaceOfIssue /*P_IDPLACE*/ IN VARCHAR2,
PermanentAddress /*P_ADDRESS*/ IN VARCHAR2,
MailingAddress /*P_RECEIVEADDRESS*/ IN VARCHAR2,
PhoneNo /*P_PHONE*/ IN VARCHAR2,
Email  /*P_EMAIL*/ IN VARCHAR2,
VcbAccountNo  /*P_VCBACCOUNT*/ IN VARCHAR2,
TaxNo /*P_TAXNUMBER*/ IN VARCHAR2,
CompanyInfo /*P_PLACEOFWORK*/ IN VARCHAR2,
Position /*P_POSITION*/ IN VARCHAR2,
Industry /*P_TYPEOFWORK*/ IN VARCHAR2,
SpouseName /*P_PARTNERNAME*/ IN VARCHAR2,
SpousePosition /*P_PARTNERPOS*/ IN VARCHAR2,
SpouseIndustry /*P_PARTNERWORK*/ IN VARCHAR2,
SpouseMobileNo /*P_PARTNERPHONE*/ IN VARCHAR2,
Reg_Internet /*P_ISONLTRADE*/ IN VARCHAR2,
Reg_Phone /*P_ISTELTRADE*/ IN VARCHAR2,
Reg_Sms /*P_ISMATCHSMS*/ IN VARCHAR2,
Reg_Info /*P_ISOTHERSMS*/ IN VARCHAR2,
Reg_Email /*P_ISNEWSEMAIL*/ IN VARCHAR2,
Target_Income /*P_INCOMECUST*/ IN NUMBER,
Target_LongGrowth /*P_LONGTERM*/ IN NUMBER,
Target_MediumGrowth /*P_MIDTERM*/ IN NUMBER,
Target_ShortGrowth /*P_SHORTTERM*/ IN NUMBER,
Risk_Low /*P_LOWRISK*/ IN NUMBER,
Risk_Average /*P_MIDRISK*/ IN NUMBER,
Risk_High /*P_HIGHRISK*/ IN NUMBER,
Asset_Income /*P_INVINCOME*/ IN NUMBER,
Asset_Spouse  /*P_INCOMEPARTNER*/ IN NUMBER,
Invest_Knowledge /*P_INVESTKNOW*/ IN NUMBER,
Invest_Experience /*P_SECINV*/ IN VARCHAR2,
CompanyNameOfManager /*P_COMPCUSTMAN*/ IN VARCHAR2,
CompanyNameOfHolding5Percent /*P_COMPCUSTCAP*/ IN VARCHAR2,
CommissionAccount /*P_ISAUTHACC*/ IN NUMBER,
CommissionName /*P_AUTHNAME*/ IN VARCHAR2,
CommissionMobile /*P_AUTHTEL*/ IN VARCHAR2,
OtherSecuritiesAccountNo /*P_OTHERACCOUNT*/ IN VARCHAR2,
VCBSRelation /*P_RELATIVE*/ IN VARCHAR2,
CreatedBy /*P_TLID*/ IN VARCHAR2,
CreatedDate /*P_OPNDATE*/ IN VARCHAR2,
UpdatedBy /*P_UPDATEBY*/ IN VARCHAR2,
UpdatedDate /*P_UPDATEDATE*/ IN VARCHAR2,
IsDeleted /*P_ISDELETED*/ IN VARCHAR2,
DeletedBy /*P_DELETEDBY*/ IN VARCHAR2,
DeletedDate /*P_DELETEDDATE*/ IN VARCHAR2,
FATCA_Answers /*P_FATCAANS*/ IN VARCHAR2,
Reg_GdMuKyQuyCnTienBanCK  /*P_ISMARGINTRF*/ IN VARCHAR2,
FolderNo /*p_FolderNo*/ in varchar2,
MobileNo /*P_MOBILE*/ IN VARCHAR2,
     p_err_code out varchar2,
     p_err_message out VARCHAR2
     );
PROCEDURE pr_GetContract
  (p_REF_CURSOR IN OUT PKG_REPORT.REF_CURSOR,
    FolderNo IN VARCHAR2,
  MobileNo IN VARCHAR2);
PROCEDURE pr_CheckContract
  (FolderNo IN VARCHAR2,
  MobileNo IN VARCHAR2,
  p_err_code out varchar2,
  p_err_message out VARCHAR2
  );

PROCEDURE pr_CFAFTRDLNK_Update
  (p_afacctno IN VARCHAR2,
  p_adminid IN CHAR,
  p_leaderid IN CHAR,
  p_traderid IN CHAR,
  p_isDelete IN VARCHAR2,
  p_err_code out varchar2,
  p_err_message out VARCHAR2
  );
  PROCEDURE pr_blbPlaceOrder_update (p_functionname   in varchar2,
                                   p_acctno        in varchar2,
                                   p_ORDERID       IN  VARCHAR2,
                                   p_BLORDERID     IN  VARCHAR2,
                                   p_QUANTITY      IN  NUMBER,
                                   p_tlid          in varchar2,
                                   p_newOrderid    in varchar2 default '');

PROCEDURE pr_change_order_ntot  (p_orderid IN VARCHAR2,
  p_toafacctno IN VARCHAR2,
  p_err_code  OUT varchar2,
  p_err_message  OUT varchar2,
  --Log thong tin thiet bi
  p_ipaddress        IN     VARCHAR2 DEFAULT '',                 --1.0.6.0
  p_via              IN     VARCHAR2 DEFAULT '',
  p_validationtype   IN     VARCHAR2 DEFAULT '',
  p_devicetype       IN     VARCHAR2 DEFAULT '',
  p_device           IN     VARCHAR2 DEFAULT ''
  --End
  );
  PROCEDURE pr_CancelOrderAfterDay (p_orderid IN VARCHAR2,
  p_err_code  OUT varchar2,
  p_err_message  OUT varchar2
  );
  PROCEDURE pr_GetListODPROBRKAF
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTODYCD      IN VARCHAR2 DEFAULT 'ALL',
     P_TLID          IN VARCHAR2
     );
     PROCEDURE pr_GetListCFOTHERACC
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTODYCD      IN VARCHAR2 ,
     p_TLID         IN VARCHAR2
     );
procedure pr_PlaceOrderMemo(p_tltid in varchar2,
                p_custodycd in varchar2,
                p_afacctno  in varchar2,
                p_symbol in varchar2,
                p_exectype in varchar2,
                p_quantity in number,
                p_quoteprice in number,
                p_err_code out varchar2,
                p_err_message out VARCHAR2
                );
procedure pr_PushOrderMemo(p_orderid  in varchar2,
                p_str_message in varchar2,
                p_err_code out varchar2,
                p_err_message out VARCHAR2
                );
procedure pr_CancelOrderMemo(p_orderid  in varchar2,
                p_err_code out varchar2,
                p_err_message out VARCHAR2
                );
--Hien thi so du Voucher
PROCEDURE pr_get_Voucher_balance(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                  pv_custodycd IN VARCHAR2);
--Bao cao chi tiet lai tiet kiem
PROCEDURE pr_Details_saving_rate(PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
                                   F_DATE         IN       VARCHAR2,
                                   T_DATE         IN       VARCHAR2,
                                   CUSTODYCD       IN       VARCHAR2,
                                   TLTXCD         IN       VARCHAR2,
                                   ACCTNO         IN       VARCHAR2
                                   );
 procedure pr_PlaceOrder_bl(p_functionname in varchar2,
                        p_username in varchar2,
                        p_acctno in varchar2,
                        p_afacctno in varchar2,
                        p_exectype in varchar2,
                        p_symbol in varchar2,
                        p_quantity in number,
                        p_quoteprice in number,
                        p_pricetype in varchar2,
                        p_timetype in varchar2,
                        p_book in varchar2,
                        p_via in varchar2,
                        p_dealid in varchar2,
                        p_direct in varchar2,
                        p_effdate in varchar2,
                        p_expdate in varchar2,
                        p_tlid  IN  VARCHAR2,
                        p_quoteqtty in number,
                        p_limitprice in number,
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2,
                        p_refOrderId in varchar2 DEFAULT '',
                        p_blOrderid   in varchar2 default '',
                        P_NOTE        IN VARCHAR2 DEFAULT ''
                        );
procedure pr_get_symbollist (p_refcursor in out pkg_report.ref_cursor);
PROCEDURE PR_GEN_OTPSMSEMAIL(
                    p_username      IN varchar2,
                    p_afacctno      IN varchar2,
                    p_amt           IN VARCHAR2,
                    p_err_code       in out varchar2,
                    p_err_param      in out varchar2);
PROCEDURE PR_VALIDATE_OTP
        (p_username IN VARCHAR2,
         p_otp      IN VARCHAR2,
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2);
PROCEDURE PR_VALIDATE_PIN
        (p_username IN VARCHAR2,
         p_LoginCustID IN VARCHAR2,
         p_pin      IN VARCHAR2,
         p_via      IN VARCHAR2,
         p_savesms  IN VARCHAR2,
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2);

PROCEDURE GET_MODULE_PERMISSION(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strCUSTID IN VARCHAR2, pv_strVIA IN VARCHAR2 DEFAULT 'A');

PROCEDURE auto_call_txpks_3384
    (p_camastid IN   varchar,
    p_account   IN   varchar,
    p_qtty      IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
    );
function FN_CHECK_SERIAL_CA  (P_CUSTID in varchar2,  P_VIA in VARCHAR2,   P_SERIAL in varchar2   )return number;
PROCEDURE PR_GEN_OTPSMSEMAILWEB(
                    p_username      IN varchar2,
                    p_afacctno      IN varchar2,
                    p_otauthtype    IN VARCHAR2,
                    p_via           IN VARCHAR2,
                    p_err_code       in out varchar2,
                    p_err_param      in out varchar2);
PROCEDURE PR_REGISTERONLINEAUTHTYPE(
    p_afacctno      IN  varchar2,
    p_via           IN  varchar2,
    p_authtype      IN  OUT varchar2,
    p_serialnumber  IN  varchar2,
    p_idcode        IN  varchar2,
    p_username      IN  varchar2,
    p_err_code      in OUT varchar2,
    p_err_param   in OUT varchar2);
PROCEDURE PR_CANCELONLINEAUTHTYPE(
    p_afacctno      IN  varchar2,
    p_via           IN  varchar2,
    p_authtype      IN  varchar2,
    p_serialnumber  IN  varchar2,
    p_username      IN  varchar2,
    p_err_code      in OUT varchar2,
    p_err_param   in OUT varchar2);
/*PROCEDURE pr_GetBankList (p_REF_CURSOR IN OUT PKG_REPORT.REF_CURSOR, p_bankcode IN varchar2);
procedure PR_Get_Cfotheracc(
    p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_cfotheraccid in VARCHAR2
    );
PROCEDURE PR_Change_cfotheracc
        (
         p_custodycd IN VARCHAR2,
         p_action   IN varchar2,
         p_bankacc in varchar2,
         p_bankacname in varchar2,
         p_bankcode in varchar2,
         p_cityef in varchar2,
         p_citybank in varchar2,
         p_cfo_id   in varchar2,
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2);*/

procedure sp_audit_authenticate_ip(p_key     varchar2,
                                          p_type    char,
                                          p_channel varchar2,
                                          p_text    varchar2,
                                          p_ipaddress      in varchar2 default '', --vcb.2021.04.0.01
                                          p_via            in varchar2 default '',
                                          p_validationtype in varchar2 default '',
                                          p_devicetype     IN varchar2 default '',
                                          p_device         IN varchar2 default '');

END fopks_api;
/


CREATE OR REPLACE PACKAGE BODY fopks_api is

  -- Private type declarations

  -- Private constant declarations
  C_FO_LOGIN  constant char := 'I';
  C_FO_LOGOUT constant char := 'O';
  C_FO_LOG    constant char := 'L';

  C_FO_USER_DOES_NOT_EXISTED   constant number := -107;
  C_FO_NO_CONTRACT_IN_LIST     constant number := -108;
  C_FO_CUSTOMER_STATUS_INVALID constant number := -109;

  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  procedure sp_focore_login(USERNAME     varchar2,
                            PASSWORD     varchar2,
                            SenderCompID varchar2) as
    l_username  varchar2(5);
    l_status    char(1);
    l_err_code  varchar2(10);
    l_err_param varchar2(10);
  begin
    plog.setBeginSection(pkgctx, 'sp_login_via');

    l_err_code  := systemnums.C_SUCCESS;
    l_err_param := 'SUCCESS';

    sp_audit_authenticate(USERNAME,
                          C_FO_LOGIN,
                          SenderCompID, 'Login successful');

    plog.setEndSection(pkgctx, 'sp_login_via');
  exception
    when errnums.E_BIZ_RULE_INVALID then
      for i in (select errdesc, en_errdesc
                  from deferror
                 where errnum = l_err_code)
      loop
        l_err_param := i.errdesc;

        sp_audit_authenticate(USERNAME, C_FO_LOG, '', l_err_param);
      end loop;
      plog.setEndSection(pkgctx, 'sp_login_via');
    when others then
      l_err_code := errnums.C_SYSTEM_ERROR;
      plog.setEndSection(pkgctx, 'sp_login_via');
  end;

  -- Function and procedure implementations
  procedure sp_login(p_username      varchar2,
                     p_password      varchar2,
                     p_customer_id   in out varchar2,
                     p_customer_info in out varchar2,
                     p_err_code      in out varchar2,
                     p_err_param     in out varchar2,
                     --Log thong tin thiet bi
                     p_ipaddress          IN  VARCHAR2,
                     p_via                IN  VARCHAR2,
                     p_validationtype     IN  VARCHAR2,
                     p_devicetype         IN  VARCHAR2,
                     p_device             IN  VARCHAR2)
                     --End
   as

    l_username varchar2(50);
    l_status   char(1);
    l_loginfail number;
    l_loginfailmax number;
  begin

    plog.setBeginSection(pkgctx, 'sp_login');
    p_err_code  := systemnums.C_SUCCESS;
    p_err_param := 'SUCCESS';
    -- 20221006 Tho.Dinh check login fail
    select varvalue into l_loginfailmax from sysvar where varname='USERLOGINFALSE';
    begin
        select loginfail into l_loginfail from userlogin where username= UPPER(p_username);
        exception
        when NO_DATA_FOUND then
            p_err_code := C_FO_USER_DOES_NOT_EXISTED;
            plog.error(pkgctx, 'Can not find user: '|| p_username);
            raise errnums.E_BIZ_RULE_INVALID;
    end;
    if l_loginfail >= l_loginfailmax then
        p_err_code:= '131';
        plog.error(pkgctx, 'has been locked due to wrong entry more than 5 times');
        return;
    end if;
    -- end 20221006
    begin
      select u.username,
             c.custid,
             c.fullname || ' - Addr. : ' || c.address || ' - ID: ' ||
             c.idcode,
             c.status
        into l_username, p_customer_id, p_customer_info, l_status
        from userlogin u, cfmast c
       where u.username = c.username
         and upper(u.username) = upper(p_username)
         and u.loginpwd = genencryptpassword(p_password) and u.status <> 'E';

      if nvl(l_status, 'X') <> 'A' then
        p_err_code := C_FO_CUSTOMER_STATUS_INVALID;
        raise errnums.E_BIZ_RULE_INVALID;
      end if;

    exception
      when NO_DATA_FOUND then
        p_err_code := C_FO_USER_DOES_NOT_EXISTED;
        raise errnums.E_BIZ_RULE_INVALID;
    end;
    -- neu dang nhap thanh cong set lai so lan login fail = 0
    UPDATE USERLOGIN SET LOGINFAIL = 0
    WHERE USERNAME=UPPER(p_username);
    sp_audit_authenticate_ip(p_username, C_FO_LOGIN, '', 'Login successful',p_ipaddress,p_via,p_validationtype,p_devicetype,p_device);
    plog.setEndSection(pkgctx, 'sp_login');
  exception
    when errnums.E_BIZ_RULE_INVALID then
      for i in (select errdesc, en_errdesc
                  from deferror
                 where errnum = p_err_code)
      loop
        p_err_param := i.errdesc;

        --sp_audit_authenticate(p_username, C_FO_LOG, '', p_err_param);
        sp_audit_authenticate_ip(p_username,
                                   C_FO_LOGIN,
                                   'Login fail',
                                   p_err_param,p_ipaddress,p_via,p_validationtype,p_devicetype,p_device);
      end loop;
      -- update so lan loginfail+1
        UPDATE USERLOGIN SET
        LOGINFAIL = LOGINFAIL + 1,
        LASTLOGINFAIL = (SELECT SYSDATE FROM DUAL)
        WHERE USERNAME=UPPER(p_username);
      if l_loginfail= l_loginfailmax-1 then
        p_err_code:='131';
      end if;
      plog.setEndSection(pkgctx, 'sp_login');
    when others then
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.setEndSection(pkgctx, 'sp_login');
  end;

  -- Logout function
  function fn_logout(p_username  varchar2,
                     p_err_code  in out varchar2,
                     p_err_param out varchar2) return number as
  begin
    -- TO DO
    return systemnums.C_SUCCESS;
  exception
    when others then
      return errnums.C_SYSTEM_ERROR;
  end;

  -- Check trading password when user place order, transfer...
  function fn_check_password_trading(p_username  varchar2,
                                     p_tpassword varchar2,
                                     p_err_code  in out varchar2,
                                     p_err_param out varchar2) return number as
  begin
    -- TO DO
    return systemnums.C_SUCCESS;
  exception
    when others then
      return errnums.C_SYSTEM_ERROR;
  end;

  -- Get all member of customer
  function fn_get_members(p_customer_id varchar2,
                          p_err_code    in out varchar2,
                          p_err_param   out varchar2) return number as
  begin
    -- TO DO
    return systemnums.C_SUCCESS;
  exception
    when others then
      return errnums.C_SYSTEM_ERROR;
  end;

  -- Get all member of customer
  function fn_is_ho_active return boolean as
    l_status char(1);
  begin
    -- TO DO
    l_status := cspks_system.fn_get_sysvar('SYSTEM', 'HOSTATUS');

    if nvl(l_status, '0') = '0' then
      return false;
    end if;

    return true;
  exception
    when others then
      return false;
  end;
--14/15/2021:ghep tu hdbs qua
PROCEDURE PR_OPENACCT_CheckIdcode
        (p_idcode IN VARCHAR2, --So CMND
         --p_iddate      IN VARCHAR2 , --Ngay cap
         --p_idplace      IN VARCHAR2 , --Noi cap
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2)
 IS --Check so CMND
    l_count number;
begin
    plog.setbeginsection(pkgctx, 'PR_OPENACCT_CheckIdcode');
    select count(*) into l_count
    from (
        select idcode from cfmast where  upper(trim(idcode)) = upper(trim(p_idcode))
    )
    ;
    if l_count > 0 then
        p_err_code  := '-200020';
        plog.error(pkgctx, 'p_err_code:'||p_err_code||', p_idcode='||p_idcode);
        plog.setendsection(pkgctx, 'PR_OPENACCT_CheckIdcode');
        return;
    end if;


    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'PR_OPENACCT_CheckIdcode');
exception when others then
      plog.error(pkgctx, 'Error: '||sqlerrm|| dbms_utility.format_error_backtrace||', p_idcode='||p_idcode);
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.setendsection(pkgctx, 'PR_OPENACCT_CheckIdcode');
end PR_OPENACCT_CheckIdcode;

procedure PR_OPENACCT_view
    (p_refcursor in out pkg_report.ref_cursor,
    p_key in VARCHAR2)
IS
    v_tlname varchar2(300);
    v_acctno varchar2(10);
    v_custid varchar2(10);
    v_rerole varchar2(500);
    v_reacctno varchar2(30);
    v_strCFRELATION varchar2(4000);
    v_strCFOTHERACC varchar2(4000);

begin
    plog.setbeginsection(pkgctx, 'PR_OPENACCT_view');

    Begin
        select max(custid) into v_custid from cfmast where trim(idcode) = trim(p_key);
    exception when others then
        v_custid := '';
    End;

    v_strCFOTHERACC := '';
    for rec in (
        select *
        from CFOTHERACC acc
        where acc.cfcustid = v_custid
    ) loop
        v_strCFOTHERACC := v_strCFOTHERACC||'<BANKITEM>';
        v_strCFOTHERACC := v_strCFOTHERACC ||'<BANKACCTNO>'||rec.bankacc||'</BANKACCTNO>';
        v_strCFOTHERACC := v_strCFOTHERACC ||'<BANKNAME>'||rec.bankname||'</BANKNAME>';
        v_strCFOTHERACC := v_strCFOTHERACC ||'</BANKITEM>';
    end loop;

    v_strCFRELATION := '';
    for rec in (
        select cfr.fullname,cfr.licenseno,cfr.lniddate,cfr.lnplace,cfr.address,cfr.telephone,al.cdcontent relptype
        from CFRELATION cfr, allcode al
        where trim(cfr.custid) = v_custid and cfr.actives = 'Y'
        and al.cdname ='RETYPE' and al.cdtype='CF' and al.cduser='Y' and cfr.retype(+) = al.cdval
    ) loop
        v_strCFRELATION := v_strCFRELATION||'<RELATIONITEM>';
        v_strCFRELATION := v_strCFRELATION ||'<FULLNAME>'||rec.fullname||'</FULLNAME>';
        v_strCFRELATION := v_strCFRELATION ||'<LICENSENO>'||rec.licenseno||'</LICENSENO>';
        v_strCFRELATION := v_strCFRELATION ||'<LICENSEDATE>'||to_char(rec.lniddate,'DD/MM/RRRR')||'</LICENSEDATE>';
        v_strCFRELATION := v_strCFRELATION ||'<LICENSEPLACE>'||rec.lnplace||'</LICENSEPLACE>';
        v_strCFRELATION := v_strCFRELATION ||'<ADDRESS>'||rec.address||'</ADDRESS>';
        v_strCFRELATION := v_strCFRELATION ||'<TELEPHONE>'||rec.telephone||'</TELEPHONE>';
        v_strCFRELATION := v_strCFRELATION ||'<RELPTYPE>'||rec.relptype||'</RELPTYPE>';
        v_strCFRELATION := v_strCFRELATION ||'</RELATIONITEM>';
    end loop;

    Open p_refcursor for

        select cf.custodycd, CF.fullname,CF.idcode, al3.cdcontent IDTYPE, to_char(CF.iddate,'DD/MM/RRRR') iddate,  CF.idplace,
            al.CDCONTENT CUSTTYPE, al2.CDCONTENT SEX, CF.mobilesms, CF.email,  to_char(CF.dateofbirth,'DD/MM/RRRR') dateofbirth,
            CF.address, to_char(CF.opndate,'DD/MM/RRRR') opndate, nvl(MG.FULLNAME,null) BROKERNAME, nvl(MG.REACCTNO,null) BROKERID,
            nvl(MG.REROLE,null) BROKERROLE, v_strCFOTHERACC BANKTRANSFERLIST, v_strCFRELATION RELATIONLIST
        from cfmast cf, allcode al , allcode al2, allcode al3,
        (
            select ra.afacctno custid, A0.CDCONTENT REROLE, cf.fullname, ra.reacctno
            from reaflnk ra, recflnk rc, cfmast cf, retype typ, allcode a0
            where ra.refrecflnkid = rc.autoid
                and substr(ra.reacctno,11) = typ.actype
                and rc.custid = cf.custid
                and A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
                and ra.status = 'A'
        ) MG
        where al.cdval(+) = cf.custtype and al.cdname ='CUSTTYPE' and al.cdtype='CF'
            and al2.CDVAL(+) = cf.SEX and al2.cdname='SEX' and al2.cdtype='CF'
            and al3.cdval(+) = cf.idtype and al3.cdname='IDTYPE' and al3.cdtype='CF'
            and mg.custid(+) = cf.custid
            and cf.custid = v_custid;

    /*Open p_refcursor for
        select CF.opndate,CF.fullname,CF.idcode,cf.custodycd,nvl(MG.FULLNAME,null) TLNAME, nvl(MG.REACCTNO,null) REACCTNO,nvl(MG.DESC_REROLE,null) REROLE,
        al.CDCONTENT CUSTTYPE, al2.CDCONTENT STAFF, CF.iddate, CF.idplace, CF.sex, CF.dateofbirth, CF.address, al4.cdcontent RELPTYPE,
        CF.mobilesms, CF.email, acc.bankacc bankacctno, CF.status,CF.last_change,CF.province, acc.bankname,
        al3.cdcontent IDTYPE, cfr.fullname relationship,cfr.address,cfr.telephone,cfr.licenseno,cfr.lniddate,cfr.lnplace
        from cfmast cf, tlprofiles tl , allcode al , allcode al2, allcode al3, allcode al4,cfotheracc acc, CFRELATION cfr,REAFLNK reaf,
        (
            SELECT (CF.CUSTID||RF.REACTYPE) REACCTNO,A0.CDCONTENT DESC_REROLE, CFMAST.FULLNAME,CFMAST.CUSTID
            FROM RECFDEF RF, RETYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, RECFLNK CF, CFMAST
            WHERE A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
                AND A2.CDTYPE = 'RE' AND A2.CDNAME = 'AFSTATUS' AND A2.CDVAL = TYP.AFSTATUS
                AND A1.CDTYPE='RE' AND A1.CDNAME='RETYPE' AND A1.CDVAL=TYP.RETYPE
                AND RF.REACTYPE=TYP.ACTYPE
                AND RF.REFRECFLNKID = CF.AUTOID
                AND CF.CUSTID = CFMAST.CUSTID
        ) MG
        where cf.brid = tl.tlid and al.cdval(+) = cf.custtype and al2.CDVAL(+) = cf.STAFF and al4.cdval(+) = cfr.retype
            and al3.cdval(+) = cf.idtype and acc.cfcustid(+) = cf.custid and cf.custid = trim(cfr.custid(+))
            and al.cdname ='CUSTTYPE' and al.cdtype='CF' and al.cduser='Y' and reaf.status <> 'C'
            and al2.cdname='STAFF' and al2.cdtype='CF' and al2.cduser='Y' and cfr.actives = 'Y'
            and al3.cdname='IDTYPE' and al3.cdtype='CF' and al3.cduser='Y'
            and al4.cdname ='RETYPE' and al4.cdtype='CF' and al4.cduser='Y'
            and reaf.afacctno(+) = cf.custid and trim(substr(reaf.reacctno,1,10))=MG.CUSTID(+)
            and cf.idcode= trim(p_key);*/

    plog.setendsection(pkgctx, 'PR_OPENACCT_view');
exception when others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'PR_OPENACCT_view');
end PR_OPENACCT_view;

procedure PR_OPENACCT_view_clob
    (p_key in VARCHAR2,
     p_result in out clob)
IS


begin
    plog.setbeginsection(pkgctx, 'PR_OPENACCT_view_clob');
    p_result := '';
    for rec in (
        select cf.custid, cf.custodycd, CF.fullname,CF.idcode, al3.cdcontent IDTYPE, to_char(CF.iddate,'DD/MM/RRRR') iddate,  CF.idplace,
            al.CDCONTENT CUSTTYPE, al2.CDCONTENT SEX, CF.mobilesms, CF.email,  to_char(CF.dateofbirth,'DD/MM/RRRR') dateofbirth, CF.address, CF.opndate,
            nvl(MG.FULLNAME,null) BROKERNAME, nvl(MG.REACCTNO,null) BROKERID, nvl(MG.REROLE,null) BROKERROLE
        from cfmast cf, allcode al , allcode al2, allcode al3,
        (
            select ra.afacctno custid, A0.CDCONTENT REROLE, cf.fullname, ra.reacctno
            from reaflnk ra, recflnk rc, cfmast cf, retype typ, allcode a0
            where ra.refrecflnkid = rc.autoid
                and substr(ra.reacctno,11) = typ.actype
                and rc.custid = cf.custid
                and A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
                and ra.status = 'A'
        ) MG
        where al.cdval(+) = cf.custtype and al.cdname ='CUSTTYPE' and al.cdtype='CF'
            and al2.CDVAL(+) = cf.SEX and al2.cdname='SEX' and al2.cdtype='CF'
            and al3.cdval(+) = cf.idtype and al3.cdname='IDTYPE' and al3.cdtype='CF'
            and mg.custid(+) = cf.custid
            and trim(idcode) = trim(p_key)
    ) loop
        p_result := p_result|| '<CUST_INFO>';
        p_result := p_result|| '<CUSTODYCD>'||rec.custodycd||'</CUSTODYCD>';
        p_result := p_result|| '<FULLNAME>'||rec.fullname||'</FULLNAME>';
        p_result := p_result|| '<IDCODE>'||rec.idcode||'</IDCODE>';

        p_result := p_result|| '<BANKTRANSFERLIST>';
        for rec_cfo in (select * from CFOTHERACC acc where acc.cfcustid = rec.custid) loop
            p_result := p_result||'<BANKITEM>';
            p_result := p_result ||'<BANKACCTNO>'||rec_cfo.bankacc||'</BANKACCTNO>';
            p_result := p_result ||'<BANKNAME>'||rec_cfo.bankname||'</BANKNAME>';
            p_result := p_result ||'</BANKITEM>';
        end loop;
        p_result := p_result|| '/<BANKTRANSFERLIST>';

        p_result := p_result|| '<RELATIONLIST>';
        for rec_relation in (
            select *
            from CFRELATION acc
            where trim(acc.custid) = rec.custid and actives = 'Y'
        ) loop
            p_result := p_result||'<RELATIONITEM>';
            p_result := p_result ||'<FULLNAME>'||rec_relation.fullname||'</FULLNAME>';
            p_result := p_result ||'<LICENSENO>'||rec_relation.licenseno||'</LICENSENO>';
            p_result := p_result ||'<LICENSEDATE>'||to_char(rec_relation.lniddate,'DD/MM/RRRR')||'</LICENSEDATE>';
            p_result := p_result ||'<LICENSEPLACE>'||rec_relation.lnplace||'</LICENSEPLACE>';
            p_result := p_result ||'</RELATIONITEM>';
        end loop;
        p_result := p_result|| '</RELATIONLIST>';

        p_result := p_result|| '</CUST_INFO>';
    end loop;


    plog.setendsection(pkgctx, 'PR_OPENACCT_view_clob');
exception when others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'PR_OPENACCT_view_clob');
end PR_OPENACCT_view_clob;
--14/15/2021:end.
  -- Audit log
  procedure sp_audit_log(p_key varchar2, p_text varchar2) as
  begin
    plog.setbeginsection(pkgctx, 'sp_audit_log');
    --Ghi log xu ly
    insert into fo_audit_logs
      (action_date, username, action_desc)
    values
      (sysdate, p_key, p_text);

    plog.debug(pkgctx, p_text);
    plog.setendsection(pkgctx, 'sp_audit_log');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_audit_log');
  end;

  -- Audit login/ logout
  procedure sp_audit_authenticate(p_key  varchar2,
                                  p_type char,
                                  p_channel varchar2,
                                  p_text varchar2) as
    l_text varchar2(200);
  begin
    plog.setbeginsection(pkgctx, 'sp_audit_authenticate');

    plog.debug(pkgctx, l_text);

    l_text := p_key || ' - ' || p_text;
    --Ghi log xu ly
    insert into fo_audit_logs
      (action_date, username, channel, action_type, action_desc)
    values
      (sysdate, p_key, p_channel, p_type, l_text);

    plog.setendsection(pkgctx, 'sp_audit_authenticate');
    commit;
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_audit_authenticate');
  end;

  -- Log thong tin dang nhap
  procedure sp_audit_authenticate_ip(p_key     varchar2,
                                            p_type    char,
                                            p_channel varchar2,
                                            p_text    varchar2,
                                            p_ipaddress      in varchar2 default '', --vcb.2021.04.0.01
                                            p_via            in varchar2 default '',
                                            p_validationtype in varchar2 default '',
                                            p_devicetype     IN varchar2 default '',
                                            p_device         IN varchar2 default '')
  as
    l_text varchar2(200);
  begin
    plog.setbeginsection(pkgctx, 'sp_audit_authenticate_ip');

    plog.debug(pkgctx, l_text);

    l_text := p_key || ' - ' || p_text;
    --Ghi log xu ly
    insert into fo_audit_logs
      (action_date, username, channel, action_type, action_desc,IPADDRESS,VIA,OTAUTHTYPE,DEVICETYPE,DEVICE)
    values
      (sysdate, p_key, p_channel, p_type, l_text,substr(p_ipaddress,1,200),p_via,p_validationtype,p_devicetype,p_device);

    plog.setendsection(pkgctx, 'sp_audit_authenticate_ip');
    commit;
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_audit_authenticate_ip');
  end;

-- thu tuc dat lenh thoa thuan 1 firm --
PROCEDURE pr_place_order_1_firm
(
    p_sell_afaccount    IN VARCHAR2,
    p_sell_exectype     IN VARCHAR2,
    p_buy_afaccount     IN VARCHAR2,
    p_buy_exectype      IN VARCHAR2,
    p_symbol            IN VARCHAR2,
    p_orderqtty         IN NUMBER,
    p_clearday          IN NUMBER,
    p_orderprice        IN NUMBER,
    p_via               IN VARCHAR2,
    p_wsname            IN VARCHAR2,
    p_ip_address        IN VARCHAR2,
    p_tlid              IN VARCHAR2,
    p_err_code          OUT VARCHAR2,
    p_err_message       OUT VARCHAR2

)
IS
    l_txmsg             tx.msg_rectype;
    l_reset_txmsg       tx.msg_rectype;
    l_sell_tltxcd       tltx.tltxcd%TYPE;
    l_buy_tltxcd        tltx.tltxcd%TYPE;
    l_err_code          VARCHAR2(20);
    l_err_param         VARCHAR2(200);
    l_currdate          DATE;
    l_symbol            securities_info.symbol%TYPE;
    l_tradeunit         securities_info.tradeunit%TYPE;
    l_parvalue          sbsecurities.parvalue%TYPE;
    l_tradeplace        sbsecurities.tradeplace%TYPE;
    l_sectype           sbsecurities.sectype%TYPE;
    l_defaultClientID   VARCHAR2(20);
    l_sell_odactype     odtype.actype%TYPE;
    l_buy_odactype      odtype.actype%TYPE;
    l_strsellaftype     aftype.actype%TYPE;
    l_strbuyaftype      aftype.actype%TYPE;
    l_mrratioloan       afserisk.mrratioloan%TYPE;
    l_mrpriceloan       afserisk.mrpriceloan%TYPE;
    l_ismarginallow     afserisk.ismarginallow%TYPE;
    l_chksysctrl        lntype.chksysctrl%TYPE;
    l_mrtype            mrtype.mrtype%TYPE;
    l_isppused          mrtype.isppused%TYPE;
    p_codeid            VARCHAR2(20);
    l_BuyCustodycd            VARCHAR2(20);
    l_SellCustodycd            VARCHAR2(20);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_place_order_1_firm');
    p_err_code := systemnums.C_SUCCESS;
    l_sell_tltxcd := '8877';
    l_buy_tltxcd := '8876';

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_currdate
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    BEGIN
        SELECT symbol, tradeunit, codeid INTO l_symbol, l_tradeunit, p_codeid FROM securities_info WHERE symbol = p_symbol;
    EXCEPTION WHEN OTHERS THEN
        l_symbol := '';
        l_tradeunit := 1000;
    END;

    BEGIN
        SELECT parvalue, tradeplace, sectype INTO l_parvalue, l_tradeplace, l_sectype FROM sbsecurities WHERE codeid = p_codeid;
    EXCEPTION WHEN OTHERS THEN
        l_parvalue    := 10000;
        l_tradeplace  := '000';
        l_sectype     := '';
    END;

    BEGIN
        SELECT actype INTO l_strsellaftype FROM afmast WHERE acctno = p_sell_afaccount;
        SELECT actype INTO l_strbuyaftype FROM afmast WHERE acctno = p_buy_afaccount;
        select cf.custodycd into l_BuyCustodycd from cfmast cf, afmast af where af.custid = cf.custid and af.acctno = p_buy_afaccount;
        select cf.custodycd into l_SellCustodycd from cfmast cf, afmast af where af.custid = cf.custid and af.acctno = p_sell_afaccount;

    EXCEPTION WHEN OTHERS THEN
        l_strsellaftype := '';
        l_strbuyaftype  := '';
    END;
    l_defaultClientID := '002C000001';

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_place_order_1_firm');
        RETURN;
    END IF;
    -- End: Check host 1 active or inactive

    -- Dat lenh ban
    BEGIN
        l_txmsg             := l_reset_txmsg; -- reset thong tin giao dich
        SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.tltxcd      := l_sell_tltxcd;
        l_txmsg.brid        := SUBSTR(p_sell_afaccount,1,4);
        l_txmsg.tlid        := p_tlid;--systemnums.c_system_userid;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := '';
        l_txmsg.wsname      := p_wsname;
        l_txmsg.ipaddress   := p_ip_address;

        l_txmsg.txdate      := l_currdate;
        l_txmsg.brdate      := l_currdate;
        l_txmsg.busdate     := l_currdate;

        l_txmsg.txtime      := TO_CHAR (SYSDATE, systemnums.c_time_format);
        l_txmsg.chktime     := l_txmsg.txtime;
        l_txmsg.offtime     := l_txmsg.txtime;


        plog.debug(pkgctx,'lay loai hinh dat lenh: ' || p_sell_afaccount || ' ' || l_symbol|| ' ' || p_codeid || ' ' || p_sell_exectype);

        -- Lay gia tri loai hinh lenh
        l_sell_odactype := fopks_api.fn_GetODACTYPE(p_sell_afaccount, l_symbol, p_codeid, l_tradeplace, p_sell_exectype,
                                    'LO', 'T', l_strsellaftype, l_sectype, p_via);

        plog.debug(pkgctx,'Loai hinh dat lenh: ' || l_sell_odactype);

        -- txfields
        --01    CODEID     C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').value     := p_codeid;
        --02    ACTYPE     C
        l_txmsg.txfields ('02').defname   := 'ACTYPE';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').value     := l_sell_odactype;
        --03    AFACCTNO     C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').value     := p_sell_afaccount;
        --08    CUSTODYCD     C
        l_txmsg.txfields ('08').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').value     := l_SellCustodycd;

        --04    ORDERID     C
        l_txmsg.txfields ('04').defname   := 'ORDERID';
        l_txmsg.txfields ('04').TYPE      := 'C';
        SELECT    systemnums.c_ol_prefixed
                         || '00'
                         || TO_CHAR(TO_DATE (varvalue, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM sysvar WHERE varname ='CURRDATE' AND grname='SYSTEM';

        --06    SEACCTNO     C
        l_txmsg.txfields ('06').defname   := 'SEACCTNO';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').value     := p_sell_afaccount || p_codeid;
        --10    CLEARDAY     N
        l_txmsg.txfields ('10').defname   := 'CLEARDAY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').value     := p_clearday;
        --11    QUOTEPRICE     N
        l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').value     := p_orderprice;
        --12    ORDERQTTY     N
        l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').value     := p_orderqtty;
        --13    BRATIO     N
        l_txmsg.txfields ('13').defname   := 'BRATIO';
        l_txmsg.txfields ('13').TYPE      := 'N';
        BEGIN
            SELECT bratio + deffeerate INTO l_txmsg.txfields ('13').value FROM odtype WHERE actype = l_sell_odactype;
        EXCEPTION WHEN OTHERS THEN
            l_txmsg.txfields ('13').value     := 100;
        END;
        --14    LIMITPRICE     N
        l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').value     := p_orderprice;
        --15    PARVALUE     N
        l_txmsg.txfields ('15').defname   := 'PARVALUE';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').value     := l_parvalue;
        --19    EFFDATE     D
        l_txmsg.txfields ('19').defname   := 'EFFDATE';
        l_txmsg.txfields ('19').TYPE      := 'D';
        l_txmsg.txfields ('19').value     := to_char(l_currdate,systemnums.C_DATE_FORMAT);
        --20    TIMETYPE     C
        l_txmsg.txfields ('20').defname   := 'TIMETYPE';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').value     := 'T';
        --21    EXPDATE     D
        l_txmsg.txfields ('21').defname   := 'EXPDATE';
        l_txmsg.txfields ('21').TYPE      := 'D';
        l_txmsg.txfields ('21').value     := to_char(l_currdate,systemnums.C_DATE_FORMAT);
        --22    EXECTYPE     C
        l_txmsg.txfields ('22').defname   := 'EXECTYPE';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').value     := p_sell_exectype;
        --23    NORK     C
        l_txmsg.txfields ('23').defname   := 'NORK';
        l_txmsg.txfields ('23').TYPE      := 'C';
        l_txmsg.txfields ('23').value     := 'N';
        --24    MATCHTYPE     C
        l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
        l_txmsg.txfields ('24').TYPE      := 'C';
        l_txmsg.txfields ('24').value     := 'P';
        --25    VIA     C
        l_txmsg.txfields ('25').defname   := 'VIA';
        l_txmsg.txfields ('25').TYPE      := 'C';
        l_txmsg.txfields ('25').value     := p_via;
        --26    CLEARCD     C
        l_txmsg.txfields ('26').defname   := 'CLEARCD';
        l_txmsg.txfields ('26').TYPE      := 'C';
        l_txmsg.txfields ('26').value     := 'B';
        --27    PRICETYPE     C
        l_txmsg.txfields ('27').defname   := 'PRICETYPE';
        l_txmsg.txfields ('27').TYPE      := 'C';
        l_txmsg.txfields ('27').value     := 'LO';
        --28    VOUCHER     C
        l_txmsg.txfields ('28').defname   := 'VOUCHER';
        l_txmsg.txfields ('28').TYPE      := 'C';
        l_txmsg.txfields ('28').value     := '';
        --29    CONSULTANT     C
        l_txmsg.txfields ('29').defname   := 'CONSULTANT';
        l_txmsg.txfields ('29').TYPE      := 'C';
        l_txmsg.txfields ('29').value     := '';
        --30    DESC     C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').value     := p_sell_afaccount || ' Sell Order Putthough: ' || l_symbol || ' quantity: '|| p_orderqtty || ' price: ' || p_orderprice;
        --31    CONTRAFIRM     C
        l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
        l_txmsg.txfields ('31').TYPE      := 'C';
        l_txmsg.txfields ('31').value     := '002';
        --32    TRADERID     C
        l_txmsg.txfields ('32').defname   := 'TRADERID';
        l_txmsg.txfields ('32').TYPE      := 'C';
        l_txmsg.txfields ('32').value     := '0021';
        --33    CLIENTID     C
        l_txmsg.txfields ('33').defname   := 'CLIENTID';
        l_txmsg.txfields ('33').TYPE      := 'C';
        l_txmsg.txfields ('33').value     := l_BuyCustodycd;
        --34    OUTPRICEALLOW     C
        l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
        l_txmsg.txfields ('34').TYPE      := 'C';
        l_txmsg.txfields ('34').value     := 'N';
        --35    ADVIDREF     C
        l_txmsg.txfields ('35').defname   := 'ADVIDREF';
        l_txmsg.txfields ('35').TYPE      := 'C';
        l_txmsg.txfields ('35').value     := '';
        --40    FEEAMT     N
        l_txmsg.txfields ('40').defname   := 'FEEAMT';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').value     := 0;
        --50    CUSTNAME     C
        l_txmsg.txfields ('50').defname   := 'CUSTNAME';
        l_txmsg.txfields ('50').TYPE      := 'C';
        l_txmsg.txfields ('50').value     := '';
        --55    GRPORDER     C
        l_txmsg.txfields ('55').defname   := 'GRPORDER';
        l_txmsg.txfields ('55').TYPE      := 'C';
        l_txmsg.txfields ('55').value     := 'N';
        --60    ISMORTAGE     N
        l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').value     := 0;
        --71    CONTRACUS     C
        l_txmsg.txfields ('71').defname   := 'CONTRACUS';
        l_txmsg.txfields ('71').TYPE      := 'C';
        l_txmsg.txfields ('71').value     := '';
        --72    PUTTYPE     C
        l_txmsg.txfields ('72').defname   := 'PUTTYPE';
        l_txmsg.txfields ('72').TYPE      := 'C';
        l_txmsg.txfields ('72').value     := 'O';
        --73    CONTRAFIRM     C
        l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
        l_txmsg.txfields ('73').TYPE      := 'C';
        l_txmsg.txfields ('73').value     := '002';
        --74    ISDISPOSAL     C
        l_txmsg.txfields ('74').defname   := 'ISDISPOSAL';
        l_txmsg.txfields ('74').TYPE      := 'C';
        l_txmsg.txfields ('74').value     := 'N';
        --80    QUOTEQTTY     N
        l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').value     := p_orderqtty;
        --81    PTDEAL     C
        l_txmsg.txfields ('81').defname   := 'PTDEAL';
        l_txmsg.txfields ('81').TYPE      := 'C';
        l_txmsg.txfields ('81').value     := '';
        --94    SSAFACCTNO     C
        l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').value     := '';
        --90    TRADESTATUS     N
        l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
        l_txmsg.txfields ('90').TYPE      := 'N';
        l_txmsg.txfields ('90').value     := 0;
        --95    DEALID     C
        l_txmsg.txfields ('95').defname   := 'DEALID';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').value     := '';
        --96    TRADEUNIT     N
        l_txmsg.txfields ('96').defname   := 'NOT_GTC';
        l_txmsg.txfields ('96').TYPE      := 'N';
        l_txmsg.txfields ('96').value     := 1;
        --97    MODE     C
        l_txmsg.txfields ('97').defname   := 'MODE';
        l_txmsg.txfields ('97').TYPE      := 'C';
        l_txmsg.txfields ('97').value     := '';
        --98    TRADEUNIT     N
        l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
        l_txmsg.txfields ('98').TYPE      := 'N';
        l_txmsg.txfields ('98').value     := l_tradeunit;
        --99    HUNDRED     N
        l_txmsg.txfields ('99').defname   := 'HUNDRED';   -- ti le don bay
        l_txmsg.txfields ('99').TYPE      := 'N';
        l_txmsg.txfields ('99').value     := 100;

        --85    ISBONDTRANSACT     C
        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
        l_txmsg.txfields ('85').TYPE      := 'C';
        l_txmsg.txfields ('85').value     := 'N';
        --86    BONDINFO     C
        l_txmsg.txfields ('86').defname   := 'BONDINFO';
        l_txmsg.txfields ('86').TYPE      := 'C';
        l_txmsg.txfields ('86').value     := null;

        plog.debug(pkgctx,'Call 8877: ');

        IF txpks_#8877.fn_autotxprocess (l_txmsg, l_err_code, l_err_param) <> systemnums.c_success THEN
            p_err_code      := l_err_code;
            p_err_message   :=cspks_system.fn_get_errmsg(p_err_code);
            plog.debug(pkgctx,'Call 8877 fail : p_err_code: ' || p_err_code || ' ' || p_err_message );
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_place_order_1_firm');
            RETURN;
        END IF;
    END;
    plog.debug(pkgctx, 'phunh debug 1');
    -- Dat lenh mua
    BEGIN
        l_txmsg             := l_reset_txmsg; -- reset thong tin giao dich
        SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.tltxcd      := l_buy_tltxcd;
        l_txmsg.brid        := SUBSTR(p_buy_afaccount,1,4);
        l_txmsg.tlid        := p_tlid;--systemnums.c_system_userid;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := '';
        l_txmsg.wsname      := p_wsname;
        l_txmsg.ipaddress   := p_ip_address;

        l_txmsg.txdate      := l_currdate;
        l_txmsg.brdate      := l_currdate;
        l_txmsg.busdate     := l_currdate;

        l_txmsg.txtime      := TO_CHAR (SYSDATE, systemnums.c_time_format);
        l_txmsg.chktime     := l_txmsg.txtime;
        l_txmsg.offtime     := l_txmsg.txtime;

        -- Lay gia tri loai hinh lenh
        l_buy_odactype := fopks_api.fn_GetODACTYPE(p_buy_afaccount, l_symbol, p_codeid, l_tradeplace, p_buy_exectype,
                                    'LO', 'T', l_strbuyaftype, l_sectype, p_via);

        --01    CODEID     C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').value     := p_codeid;
        --02    ACTYPE     C
        l_txmsg.txfields ('02').defname   := 'ACTYPE';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').value     := l_buy_odactype;
        --03    AFACCTNO     C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').value     := p_buy_afaccount;
        --08    CUSTODYCD     C
        l_txmsg.txfields ('08').defname   := 'AFACCTNO';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').value     := l_BuyCustodycd;
        --04    ORDERID     C
        l_txmsg.txfields ('04').defname   := 'ORDERID';
        l_txmsg.txfields ('04').TYPE      := 'C';
        SELECT    systemnums.c_ol_prefixed
                         || '00'
                         || TO_CHAR(TO_DATE (varvalue, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM sysvar WHERE varname ='CURRDATE' AND grname='SYSTEM';
        --10    CLEARDAY     N
        l_txmsg.txfields ('10').defname   := 'CLEARDAY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').value     := p_clearday;
        --11    QUOTEPRICE     N
        l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').value     := p_orderprice;
        --12    ORDERQTTY     N
        l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').value     := p_orderqtty;
        --13    BRATIO     N
        l_txmsg.txfields ('13').defname   := 'BRATIO';
        l_txmsg.txfields ('13').TYPE      := 'N';
        BEGIN
            SELECT bratio + deffeerate INTO l_txmsg.txfields ('13').value FROM odtype WHERE actype = l_buy_odactype;
        EXCEPTION WHEN OTHERS THEN
            l_txmsg.txfields ('13').value     := 100;
        END;
        --14    LIMITPRICE     N
        l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').value     := p_orderprice;
        --19    EFFDATE     C
        l_txmsg.txfields ('19').defname   := 'EFFDATE';
        l_txmsg.txfields ('19').TYPE      := 'C';
        l_txmsg.txfields ('19').value     := to_char(l_currdate,systemnums.C_DATE_FORMAT);
        --20    TIMETYPE     C
        l_txmsg.txfields ('20').defname   := 'TIMETYPE';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').value     := 'T';
        --21    EXPDATE     C
        l_txmsg.txfields ('21').defname   := 'EXPDATE';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').value     := to_char(l_currdate,systemnums.C_DATE_FORMAT);
        --22    EXECTYPE     C
        l_txmsg.txfields ('22').defname   := 'EXECTYPE';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').value     := p_buy_exectype;
        --23    NORK     C
        l_txmsg.txfields ('23').defname   := 'NORK';
        l_txmsg.txfields ('23').TYPE      := 'C';
        l_txmsg.txfields ('23').value     := 'N';
        --24    MATCHTYPE     C
        l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
        l_txmsg.txfields ('24').TYPE      := 'C';
        l_txmsg.txfields ('24').value     := 'P';
        --25    VIA     C
        l_txmsg.txfields ('25').defname   := 'VIA';
        l_txmsg.txfields ('25').TYPE      := 'C';
        l_txmsg.txfields ('25').value     := p_via;
        --26    CLEARCD     C
        l_txmsg.txfields ('26').defname   := 'CLEARCD';
        l_txmsg.txfields ('26').TYPE      := 'C';
        l_txmsg.txfields ('26').value     := 'B';
        --27    PRICETYPE     C
        l_txmsg.txfields ('27').defname   := 'PRICETYPE';
        l_txmsg.txfields ('27').TYPE      := 'C';
        l_txmsg.txfields ('27').value     := 'LO';
        --28    VOUCHER     C
        l_txmsg.txfields ('28').defname   := 'VOUCHER';
        l_txmsg.txfields ('28').TYPE      := 'C';
        l_txmsg.txfields ('28').value     := '';
        --29    CONSULTANT     C
        l_txmsg.txfields ('29').defname   := 'CONSULTANT';
        l_txmsg.txfields ('29').TYPE      := 'C';
        l_txmsg.txfields ('29').value     := '';
        --30    DESC     C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').value     := p_buy_afaccount || ' Buy Order Putthough: ' || l_symbol || ' quantity: '|| p_orderqtty || ' price: ' || p_orderprice;
        --31    CONTRAFIRM     C
        l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
        l_txmsg.txfields ('31').TYPE      := 'C';
        l_txmsg.txfields ('31').value     := '002';
        --32    TRADERID     C
        l_txmsg.txfields ('32').defname   := 'TRADERID';
        l_txmsg.txfields ('32').TYPE      := 'C';
        l_txmsg.txfields ('32').value     := '0021';
        --33    CLIENTID     C
        l_txmsg.txfields ('33').defname   := 'CLIENTID';
        l_txmsg.txfields ('33').TYPE      := 'C';
        l_txmsg.txfields ('33').value     := l_SellCustodycd;
        --34    OUTPRICEALLOW     C
        l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
        l_txmsg.txfields ('34').TYPE      := 'C';
        l_txmsg.txfields ('34').value     := 'N';
        --40    FEEAMT     N
        l_txmsg.txfields ('40').defname   := 'FEEAMT';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').value     := 0;
        --50    CUSTNAME     C
        l_txmsg.txfields ('50').defname   := 'CUSTNAME';
        l_txmsg.txfields ('50').TYPE      := 'C';
        l_txmsg.txfields ('50').value     := '';
        --71    CONTRACUS     C
        l_txmsg.txfields ('71').defname   := 'CONTRACUS';
        l_txmsg.txfields ('71').TYPE      := 'C';
        l_txmsg.txfields ('71').value     := '';
        --72    PUTTYPE     C
        l_txmsg.txfields ('72').defname   := 'PUTTYPE';
        l_txmsg.txfields ('72').TYPE      := 'C';
        l_txmsg.txfields ('72').value     := 'O';
        --73    CONTRAFIRM     C
        l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
        l_txmsg.txfields ('73').TYPE      := 'C';
        l_txmsg.txfields ('73').value     := '002';
        --74    ISDISPOSAL     C
        l_txmsg.txfields ('74').defname   := 'ISDISPOSAL';
        l_txmsg.txfields ('74').TYPE      := 'C';
        l_txmsg.txfields ('74').value     := 'N';
        --80    QUOTEQTTY     N
        l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').value     := p_orderqtty;
        --81    PTDEAL     C
        l_txmsg.txfields ('81').defname   := 'PTDEAL';
        l_txmsg.txfields ('81').TYPE      := 'C';
        l_txmsg.txfields ('81').value     := '';
        --90    TRADESTATUS N TuanNH add
        l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
        l_txmsg.txfields ('90').TYPE      := 'N';
        l_txmsg.txfields ('90').value     := 0;
        --94    SSAFACCTNO     C
        l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').value     := p_buy_afaccount || p_codeid;
        --95    DEALID     C
        l_txmsg.txfields ('95').defname   := 'DEALID';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').value     := '';
        --96    TRADEUNIT     N
        l_txmsg.txfields ('96').defname   := 'NOT_GTC';
        l_txmsg.txfields ('96').TYPE      := 'N';
        l_txmsg.txfields ('96').value     := 1;
        --97    MODE     C
        l_txmsg.txfields ('97').defname   := 'MODE';
        l_txmsg.txfields ('97').TYPE      := 'C';
        l_txmsg.txfields ('97').value     := '';
        --98    TRADEUNIT     N
        l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
        l_txmsg.txfields ('98').TYPE      := 'N';
        l_txmsg.txfields ('98').value     := l_tradeunit;
        --99    HUNDRED     N
        l_txmsg.txfields ('99').defname   := 'HUNDRED';    -- ti le ki quy
        l_txmsg.txfields ('99').TYPE      := 'N';
        l_txmsg.txfields ('99').value     := 100;

        --85    ISBONDTRANSACT     C
        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
        l_txmsg.txfields ('85').TYPE      := 'C';
        l_txmsg.txfields ('85').value     := 'N';
        --86    BONDINFO     C
        l_txmsg.txfields ('86').defname   := 'BONDINFO';
        l_txmsg.txfields ('86').TYPE      := 'C';
        l_txmsg.txfields ('86').value     := null;

        BEGIN
            SELECT mr.mrtype, mr.isppused, lnt.chksysctrl INTO l_mrtype, l_isppused, l_chksysctrl
            FROM aftype af, mrtype mr, lntype lnt
                WHERE af.mrtype = mr.actype AND af.actype = l_strbuyaftype
                      AND af.lntype = lnt.actype;
            IF l_mrtype <> 'N' THEN
                IF l_isppused = 1 THEN
                    BEGIN
                        SELECT rsk.mrratioloan, least(rsk.mrpriceloan, sec.marginprice), rsk.ismarginallow
                                INTO l_mrratioloan, l_mrpriceloan, l_ismarginallow
                            FROM afserisk rsk, securities_info sec
                            WHERE actype = l_strbuyaftype AND rsk.codeid = p_codeid
                                  AND rsk.codeid = sec.codeid;
                    EXCEPTION WHEN OTHERS THEN
                        l_mrratioloan := 0;
                        l_mrpriceloan := 0;
                    END;

                    IF l_ismarginallow = 'N' AND l_chksysctrl = 'Y' THEN
                        l_mrratioloan := 0;
                        l_mrpriceloan := 0;
                    END IF;
                    l_txmsg.txfields ('99').VALUE     := to_char(100 / (1 - l_mrratioloan / 100 * l_mrpriceloan / p_orderprice / l_tradeunit));

                ELSE
                    l_txmsg.txfields ('99').value     := 100;
                END IF;
            ELSE
                l_txmsg.txfields ('99').value     := 100;
            END IF;

        EXCEPTION WHEN OTHERS THEN
            l_txmsg.txfields ('99').value     := 100;
        END;

        IF txpks_#8876.fn_autotxprocess (l_txmsg, l_err_code, l_err_param) <> systemnums.c_success THEN
            p_err_code      := l_err_code;
            p_err_message   :=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_place_order_1_firm');
            RETURN;
        END IF;
        plog.debug(pkgctx, 'phunh debug 2');
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_place_order_1_firm');
EXCEPTION WHEN OTHERS THEN
    p_err_code := '1';
    plog.error(pkgctx, 'Loi xay ra p_err_code:' || p_err_code || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_place_order_1_firm');
END  pr_place_order_1_firm;





PROCEDURE pr_CreateDFGroup
(
    p_custodycd         IN VARCHAR2,
    p_afacctno          IN VARCHAR2,
    p_dftype            IN VARCHAR2,
    p_RlsAmount         IN NUMBER,
    p_codeid            IN VARCHAR2,
    p_qtty              IN NUMBER,
    p_symboltype        IN VARCHAR2,
    p_REF               IN VARCHAR2,
    p_err_code          OUT VARCHAR2,
    p_err_message       OUT VARCHAR2

)
IS
    l_txmsg             tx.msg_rectype;
    l_reset_txmsg       tx.msg_rectype;
    l_sell_tltxcd       tltx.tltxcd%TYPE;
    l_buy_tltxcd        tltx.tltxcd%TYPE;
    l_err_code          VARCHAR2(20);
    l_err_param         VARCHAR2(200);
    l_currdate          DATE;
    l_RlsAmount         number(20,0);  -- So tien can giai ngan.
    l_OrgDesc varchar2(1000);
    l_EN_OrgDesc varchar2(1000);

    l_DFGroupID varchar2(30);
    l_StringData varchar2(4000);

BEGIN
    plog.setbeginsection(pkgctx, 'pr_CreateDFGroup');
    p_err_code := systemnums.C_SUCCESS;


    SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='2676';
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    plog.debug(pkgctx, 'l_txmsg.tlid' || l_txmsg.tlid);
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := '';
    l_txmsg.txdate:=l_CURRDATE;
    l_txmsg.busdate:=l_CURRDATE;
    l_txmsg.tltxcd:='2676';



    for rec in (

        SELECT a.BASKETID,a.SYMBOL,     (case when a.REFPRICE<=0 then inf.DFRLSPRICE else a.REFPRICE end) REFPRICE,
        (
            case when a.DFPRICE <=0 then round((case when a.REFPRICE<=0 then inf.DFRLSPRICE else a.REFPRICE end)* a.dfrate/100,0) else a.DFPRICE end
        ) DFPRICE ,
        (
            case when a.TRIGGERPRICE<=0 then round((case when a.REFPRICE<=0 then inf.DFRLSPRICE else a.REFPRICE end)* a.lrate/100,0)
                else a.TRIGGERPRICE end
        ) TRIGGERPRICE ,     a.DFRATE,     b.IRATE,     b.MRATE,     b.LRATE,     a.CALLTYPE,     lnt.RRTYPE, b.OPTPRICE, b.LIMITCHK,
        lnt.CUSTBANK, lnt.CIACCTNO,     a.IMPORTDT, B.TYPENAME, B.DFTYPE,B.AUTODRAWNDOWN ,B.isapprove,CD.CDCONTENT DFNAME,
        CD3.CDCONTENT CALLTYPENAME, B.ISVSD

        FROM DFBASKET A, DFTYPE B, LNTYPE lnt, securities_info inf ,ALLCODE CD, ALLCODE CD3

        WHERE A.BASKETID = B.BASKETID AND B.ACTYPE = p_dftype AND B.STATUS <>'N' AND inf.codeid = p_codeid
            AND CD.CDTYPE ='DF' AND CD.CDNAME ='DFTYPE'
            AND CD.CDVAL =B.DFTYPE  AND CD3.CDTYPE ='DF' AND CD3.CDNAME ='CALLTYPE' AND CD3.CDVAL =a.CALLTYPE
            and a.symbol = inf.symbol and b.lntype = lnt.actype and rownum=1
    )

    loop

       select systemnums.C_HO_HOID
       || to_char(l_currdate,'DDMMYY')
       || LPAD(seq_dfmast.nextval,6,'0') into l_DFGroupID from dual;


         l_StringData:= l_StringData || p_dftype || '|'; --ACTYPE cua DFTYPE
         l_StringData:= l_StringData || rec.dftype || '|'; --DFTYPE cua DFTYPE
         l_StringData:= l_StringData || p_RlsAmount || '|'; --ORGAMT  so tien tong
         l_StringData:= l_StringData || to_char(sysdate,'HH24:MI:SS') || '|'; --TXTIME
         l_StringData:= l_StringData || to_char(l_currdate,'DD/MM/RRRR') || '|'; --TXDATE
         l_StringData:= l_StringData || '9900000000' || '|'; --TXNUM
         l_StringData:= l_StringData || systemnums.C_ONLINE_USERID || '|'; --MAKER
         l_StringData:= l_StringData || rec.irate || '|'; --IRATE
         l_StringData:= l_StringData || rec.mrate || '|'; --MRATE
         l_StringData:= l_StringData || rec.lrate || '|'; --LRATE
         l_StringData:= l_StringData || '1' || '|'; --AUTODRAWNDOWN
         l_StringData:= l_StringData || 'Y' || '|'; --ISAPPROVE = Y: luon giai ngan
         l_StringData:= l_StringData || l_OrgDesc || '|'; --DESCRIPTION
         l_StringData:= l_StringData || p_afacctno || '|'; --AFACCTNO
         l_StringData:= l_StringData || p_symboltype || '|'; --DTYPE - 'N','R' CHUNG KHOAN GIAO DICH, CHUNG KHOAN CHO VE
         l_StringData:= l_StringData || rec.Symbol || '|'; --SYMBOL
         l_StringData:= l_StringData || p_codeid || '|'; --CODEID
         l_StringData:= l_StringData || p_Qtty || '|'; --QTTY
         l_StringData:= l_StringData || rec.DFPrice || '|'; --DFPRICE
         l_StringData:= l_StringData || rec.dfrate || '|'; --DFRATE - ti le vay
         l_StringData:= l_StringData || p_RlsAmount || '|'; -- so tien cua tung ma chung khoan
         l_StringData:= l_StringData || l_DFGroupID || '|'; --GROUPID
         l_StringData:= l_StringData || '1' || '|'; --AUTODRAWNDOWN
         l_StringData:= l_StringData || 'Y' || '|'; --ISAPPROVE = Y: luon giai ngan
         l_StringData:= l_StringData || p_afacctno || '|'; --AFACCTNODRD    so tieu khoan giai ngan
         l_StringData:= l_StringData || p_REF; --REF
         l_StringData:= l_StringData || '$'; --$

        --set txnum
            SELECT systemnums.C_BATCH_PREFIXED
                              || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                       INTO l_txmsg.txnum
                       FROM DUAL;
            l_txmsg.brid        := substr(p_afacctno,1,4);

            --Set cac field giao dich
            --03   C   So tieu khoan
            l_txmsg.txfields ('03').defname   := 'AFACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := p_afacctno;

            --06   C   Chuoi du lieu
            l_txmsg.txfields ('06').defname   := 'STRDATA';
            l_txmsg.txfields ('06').TYPE      := 'C';
            l_txmsg.txfields ('06').VALUE     := l_StringData;

            --10   N   So tien giai ngan
            l_txmsg.txfields ('10').defname   := 'AMOUNT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := p_RlsAmount;

            --20   C   Tieu khoan DFGROUP
            l_txmsg.txfields ('20').defname   := 'GROUPID';
            l_txmsg.txfields ('20').TYPE      := 'C';
            l_txmsg.txfields ('20').VALUE     := l_DFGroupID;

            --21   C   Loai hinh DF
            l_txmsg.txfields ('21').defname   := 'DFTYPE';
            l_txmsg.txfields ('21').TYPE      := 'C';
            l_txmsg.txfields ('21').VALUE     := p_dftype;

            --30   C   Dien Giai
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := l_OrgDesc;



            BEGIN
                IF txpks_#2676.fn_batchtxprocess (l_txmsg,
                                              p_err_code,
                                              l_err_param
                ) <> systemnums.c_success
                THEN
                    plog.debug (pkgctx,
                                'got error 2676: ' || p_err_code
                    );
                    ROLLBACK;
                    RETURN;
                END IF;
            END;


    end loop;


    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_CreateDFGroup');
EXCEPTION WHEN OTHERS THEN
    p_err_code := '1';
    plog.error(pkgctx, 'Loi xay ra p_err_code:' || p_err_code || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_CreateDFGroup');
END  pr_CreateDFGroup;








--Bat dau Ham xu ly dat lenh vao FOMAST--
--Thucnt - p_refOrderId de luu OrderId de gui sang PM
procedure pr_PlaceOrder(p_functionname in varchar2,
                        p_username in varchar2,
                        p_acctno in varchar2,
                        p_afacctno in varchar2,
                        p_exectype in varchar2,
                        p_symbol in varchar2,
                        p_quantity in number,
                        p_quoteprice in number,
                        p_pricetype in varchar2,
                        p_timetype in varchar2,
                        p_book in varchar2,
                        p_via in varchar2,
                        p_dealid in varchar2,
                        p_direct in varchar2,
                        p_effdate in varchar2,
                        p_expdate in varchar2,
                        p_tlid  IN  VARCHAR2,
                        p_quoteqtty in number,
                        p_limitprice in number,
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2,
                        p_refOrderId in varchar2 DEFAULT '',
                        p_blOrderid   in varchar2 default '',
                        P_NOTE        IN VARCHAR2 DEFAULT '',
                        p_ipaddress in  varchar2 default '',--2.1.3.0: tt 134
                        p_validationtype in varchar2 default '',
                        p_orderdata in varchar2 default '',
                        p_macaddress in varchar2 default '',
                        --28/09/2022 log ip thiet bi
                        p_devicetype IN varchar2 default '',
                        p_device  IN varchar2 default '',
                        p_model in varchar2 default '',
                        p_versionDevice in varchar2 default '',
                        p_versionCode in varchar2 default '',
                        --End 28/09/2022
                        p_isBuyIn        IN VARCHAR2 DEFAULT 'N'
                        )
  is
    v_strACCTNO varchar2(50);
    v_strAFACCTNO  varchar2(10);
    v_strACTYPE  varchar2(4);
    v_strCLEARCD  varchar2(10);
    v_strMATCHTYPE  varchar2(10);
    v_dblQUANTITY  number(20,0);
    v_dblPRICE  number(20,4);
    v_dblQUOTEPRICE  number(20,4);
    v_dblTRIGGERPRICE  number(20,4);
    v_dblCLEARDAY  number(20,0);
    v_strDIRECT  varchar2(10);
    v_strSPLITOPTION  varchar2(10);
    v_dblSPLITVALUE  number(20,0);
    v_strBOOK  varchar2(10);
    v_strVIA  varchar2(10);
    v_strEXECTYPE  varchar2(10);
    v_strPRICETYPE  varchar2(10);
    v_strTIMETYPE  varchar2(10);
    v_strNORK varchar2(10);
    v_strSYMBOL varchar2(50);
    v_strCODEID varchar2(20);
    v_sectype   varchar2(3);
    v_strODACTYPE  varchar2(4);
    v_strDEALID varchar2(100);
    v_strtradeplace varchar2(10);
    v_strATCStartTime varchar2(20);
    v_strMarketStatus varchar2(10);
    v_strFEEDBACKMSG varchar2(500);
    v_strUSERNAME varchar2(200);
    v_blnOK boolean;
    v_strSystemTime varchar2(20);
    v_count number(20,0);
    v_strORDERID varchar2(50);
    v_strBUSDATE varchar2(20);
    v_strSPLITVALUE number(20,0);
    v_strFOStatus char(1);
    v_strExpdate varchar2(20);
    v_strEffdate varchar2(20);
    v_strSTATUS char(1);
    v_strOrderStatus char(2);
    v_strTLID   varchar2(4);
    v_dblQUOTEQTTY  number(20,0);
    v_dblLIMITPRICE  number(20,4);
    l_hnxTRADINGID        varchar2(20);
    l_hoseTRADINGID        varchar2(20);
    l_isMortage           VARCHAR2(10);
    v_securitytradingSTS varchar2(3);
    V_STRISDISPOSAL      VARCHAR2(1);
    V_STRFUNCTIONAME     VARCHAR2(50);
  --Phuonght check khoi luong ban ko vuot qua kl trong semast
    l_trade NUMBER(20,0);
    l_dfmortage NUMBER(20,0);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    l_exectype VARCHAR2(10);
    l_oldOrderqtty NUMBER(20,0);
    L_MaxHNXQtty number(20,0);
    l_HoldDirect char(1);

    l_dblRoom  number(20,0);
    v_strcustodycd varchar2(20);
    ---DungNH 02-Nov-2015 them xu ly lenh bloomberg
    v_blOrderid varchar2(30);
    v_OdBlOrderid  varchar2(30);
    v_Odreltid       varchar2(10);
    V_NOTE           VARCHAR2(2000);
    --- end DungNH
    V_ORDER_END_SESSION varchar2(10);
    V_STR_SESSION_TIME  number(10);
    V_END_SESSION_TIME  number(10);
    V_CURRTIME          number(10);
    v_strholiday        varchar2(1);
    v_sessionavai   number;
    V_COUNTSTATUS       number;
    l_dblTradeLot    number; --HOSE chinh sua Lo tu 10 -> 100
    v_custodycd     varchar2(10);
    l_activests     varchar2(10);
    l_dblTraderID  number(30,4);
  begin
    plog.setbeginsection(pkgctx, 'pr_placeorder');
    p_err_code := systemnums.C_SUCCESS;
    plog.error('day la log pr_PlaceOrder');
    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
    END IF;


    -- End: Check host 1 active or inactive
    V_STRISDISPOSAL:='N';
    IF p_functionname='PLACEORDERDISPOSAL' THEN
       V_STRFUNCTIONAME:='PLACEORDER';
       V_STRISDISPOSAL:='Y';
    ELSE
       V_STRFUNCTIONAME:=P_FUNCTIONNAME;
    END IF;
    v_blOrderid:=p_blOrderid;
    v_strDIRECT:=nvl(p_direct,'N');
    v_strSPLITOPTION:='N';
    v_dblSPLITVALUE:=0;
    v_strAFACCTNO:=p_afacctno;
    --plog.debug(pkgctx, 'p_book:' || p_book);
    v_strBOOK:=nvl(p_book,'A');
    --plog.debug(pkgctx, 'v_strVIA:' || v_strVIA);
    v_strVIA:=nvl(p_via,'F');
    v_strEXECTYPE:=p_exectype;
    v_strPRICETYPE:=p_pricetype;
    v_strTIMETYPE:= p_timetype;
    v_strMATCHTYPE:='N';
    v_strCLEARCD:='B';
    v_strNORK:='N';
    v_strSYMBOL:= p_symbol;
    v_strCODEID:='';
 --T2-NAMNT
  -- v_dblCLEARDAY:=3;
--     select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
 --END-T2-NAMNT


    v_dblQUANTITY:=p_quantity;
    v_dblQUOTEPRICE:=p_quoteprice;
    v_dblPRICE:=p_quoteprice;
    v_strDEALID:=nvl(p_dealid,'');
    v_strACCTNO:=p_acctno;
    v_strExpdate:=p_expdate;
    v_strEffdate:=p_effdate;
    v_strBUSDATE:=cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
    l_HoldDirect:=cspks_system.fn_get_sysvar('BROKERDESK','DIRECT_HOLD_TO_BANK');
    v_strSTATUS:='P';
    ---DungNH 02-Nov-2015 Bloomberg
    v_Odreltid:='';
    v_OdBlOrderid:='';
    V_NOTE:=P_NOTE;
    --- end DungNH

    if v_strTIMETYPE ='T' then
        v_strExpdate:=v_strBUSDATE;
        v_strEffdate:=v_strBUSDATE;
    end if;
    IF p_Username IS NULL THEN
        SELECT CUSTID INTO v_strUSERNAME FROM AFMAST WHERE ACCTNO = p_afacctno;
    ELSE
        v_strUSERNAME:=p_Username;
    END IF;

    SELECT CUSTODYCD INTO v_custodycd FROM CFMAST WHERE CUSTID = v_strUSERNAME;

    plog.debug(pkgctx, 'TLID: ' || p_tlid);
    IF p_tlid IS NULL OR p_via = 'O' THEN
        v_strTLID := systemnums.C_ONLINE_USERID;
    ELSE
        v_strTLID := p_tlid;
    END IF;
      v_dblQUOTEQTTY  :=p_quoteqtty;
    v_dblLIMITPRICE := p_limitprice;
    --HSX04
     /*SELECT sysvalue
     INTO l_hnxTRADINGID
     FROM ordersys_ha
     WHERE sysname = 'TRADINGID';
     SELECT sysvalue
     INTO l_hoseTRADINGID
     FROM ordersys
     WHERE sysname = 'CONTROLCODE';*/

     -- lay ra gia tri max HNX cua 1 lenh
     select to_number(varvalue)
     into L_MaxHNXQtty
     from sysvar
     where varname = 'HNX_MAX_QUANTITY';

    --Lay ra codeid theo symbol
    begin
        --plog.debug(pkgctx, 'Xac dinh ma CK');
        if V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','CANCELGTCORDER','BLBAMENDMENTORDER','BLBCANCELORDER') then
            --Ngay 07/01/2022 NamTv kiem tra lai sua dung tai khoan chinh chu  --> 25/11/2022: tam thoi comment do BMS chua cap nhat phan nay
            /*IF fn_check_od_custid(v_strACCTNO, v_strAFACCTNO)<>0 THEN
                p_err_code:= errnums.C_CF_AFMAST_NOTFOUND;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:' || p_err_message||', orderid = '||v_strACCTNO||', afacctno = '||v_strAFACCTNO);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
            END IF;*/
            --NamTv End;
            select codeid, tradeplace, sectype,blorderid,exectype, symbol, PRICETYPE
            into v_strcodeid, v_strtradeplace, v_sectype,v_OdBlOrderid,l_exectype, v_strsymbol, v_strPRICETYPE
            from (
                (select sb.codeid, sb.tradeplace, sb.sectype,od.blorderid,od.exectype,sb.symbol, od.PRICETYPE
                from odmast od, sbsecurities sb
                where od.codeid = sb.codeid and OD.orderid = p_acctno)
                 union all
                (select sb.codeid, sb.tradeplace, sb.sectype,od.blorderid,od.exectype,sb.symbol, od.PRICETYPE
                from fomast od, sbsecurities sb
                where od.codeid = sb.codeid and OD.acctno = p_acctno)
            );
        else
            select SB.CODEID, SB.tradeplace, SB.sectype
            into v_strcodeid, v_strtradeplace, v_sectype
            from sbsecurities SB
            where SB.symbol =v_strsymbol;
        end if;
        --plog.debug(pkgctx, 'v_strcodeid:' || v_strcodeid);
    exception when others then
        p_err_code:=errnums.C_OD_SECURITIES_INFO_UNDEFINED;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
    end;

    begin
        select se.tradelot
            into l_dblTradeLot --HOSE chinh sua Lo tu 10 -> 100
        from securities_info se
        where se.codeid = v_strcodeid;
    exception when others then
        p_err_code:=errnums.C_OD_SECURITIES_INFO_UNDEFINED;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:securities_info '  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
    end;

    --13/02/2019 DieuNDA: Chinh sua TPDN
    IF v_sectype = '012' /*AND v_strtradeplace = '002'*/ THEN -- TPDN --TTBT T+1.5 TP: chinh sua bo case dieu kien chi san HNX All san deu dung sectype nay
         select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY_TPDN_HNX' and rownum<=1;
     ELSE
         select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
     END IF;
    --End  DieuNDA: Chinh sua TPDN

    --KRX04 Neu lenh BuyIn chu ky thanh toan = 0
    if p_isBuyIn = 'Y' then
        v_dblCLEARDAY := 0;
    end if;
    --End KRX04

    BEGIN
        SELECT VARVALUE INTO V_ORDER_END_SESSION FROM SYSVAR WHERE VARNAME = 'ORDER_END_SESSION' AND GRNAME = 'SYSTEM';
    EXCEPTION WHEN OTHERS THEN
        V_ORDER_END_SESSION := 'N';
    END;
    BEGIN
        SELECT VARVALUE INTO V_STR_SESSION_TIME FROM SYSVAR WHERE VARNAME = 'STR_SESSION_TIME' AND GRNAME = 'SYSTEM';
        SELECT VARVALUE INTO V_END_SESSION_TIME FROM SYSVAR WHERE VARNAME = 'END_SESSION_TIME' AND GRNAME = 'SYSTEM';
    EXCEPTION WHEN OTHERS THEN
        V_STR_SESSION_TIME := 140000;
        V_END_SESSION_TIME := 210000;
    END;
    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO V_CURRTIME FROM DUAL;
    select nvl(max(holiday),'N') into v_strholiday from sbcldr
    where sbdate = to_date(sysdate,'dd/mm/rrrr') and cldrtype = '000';

    --HSX04
    /*if V_STRFUNCTIONAME = 'PLACEORDER' AND P_VIA <> 'F' AND V_ORDER_END_SESSION = 'Y' AND v_strholiday = 'N' AND V_CURRTIME > V_STR_SESSION_TIME and V_CURRTIME < V_END_SESSION_TIME THEN
        if v_strtradeplace = '001' then
            if l_hoseTRADINGID in ('J','K') then
                p_err_code := '-700111';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                return;
            end if;
        else
          -- 1.0.5.7: VCBSDEPII-1397
            SELECT COUNT(1) INTO V_COUNT FROM HA_BRD HB, HASECURITY_REQ HR
            WHERE HB.BRD_CODE = HR.TRADINGSESSIONSUBID
                AND HR.SYMBOL = v_strsymbol
                AND HR.SECURITYTRADINGSTATUS IN ('17','24','25','26','1','27','28')
                AND HB.TRADSESSTATUS = '1'
                AND (CASE WHEN HB.TRADINGSESSIONID ='CLOSE' AND v_strPRICETYPE IN ('ATC','LO','PLO') THEN 1
                    WHEN HB.TRADINGSESSIONID ='PCLOSE' AND v_strPRICETYPE IN ('PLO') THEN 1
                    ELSE 0 END ) > 0 ;
            if V_COUNT < 1 then
                p_err_code := '-700111';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                return;
            end if;
        end if;
    end if;
    IF V_STRFUNCTIONAME = 'PLACEORDER' AND P_VIA <> 'F' AND V_ORDER_END_SESSION = 'Y' AND TO_DATE(V_STRBUSDATE,'DD/MM/RRRR') = TO_DATE(SYSDATE,'DD/MM/RRRR') THEN
        if ( V_CURRTIME > V_STR_SESSION_TIME) then
            if v_strtradeplace = '001' then
                if l_hoseTRADINGID in ('J','K') then
                    p_err_code := '-700111';
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    return;
                end if;
            else
            -- 1.0.5.7: VCBSDEPII-1397
            SELECT COUNT(1) INTO V_COUNT FROM HA_BRD HB, HASECURITY_REQ HR
            WHERE HB.BRD_CODE = HR.TRADINGSESSIONSUBID
                AND HR.SYMBOL = v_strsymbol
                AND HR.SECURITYTRADINGSTATUS IN ('17','24','25','26','1','27','28')
                AND HB.TRADSESSTATUS = '1'
                AND (CASE WHEN HB.TRADINGSESSIONID ='CLOSE' AND v_strPRICETYPE IN ('ATC','LO','PLO') THEN 1
                    WHEN HB.TRADINGSESSIONID ='PCLOSE' AND v_strPRICETYPE IN ('PLO') THEN 1
                    ELSE 0 END ) > 0 ;
                if V_COUNT < 1 then
                    p_err_code := '-700111';
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    return;
                end if;
            end if;
        end if;
    END IF;*/


    v_strATCStartTime:=cspks_system.fn_get_sysvar('SYSTEM','ATCSTARTTIME');
    select sysvalue into v_strMarketStatus  from ordersys where sysname='CONTROLCODE';
    SELECT TO_CHAR(SYSDATE,'HH24MISS') into v_strSystemTime FROM DUAL;
    --v_strMarketStatus=P: 8h30-->9h00 phien 1 ATO
    --v_strMarketStatus=O: 9h00-->10h15 phien 2 MP
    --v_strMarketStatus=A: 10h15-->10h30 phien 3 ATC
    --If v_strPRICETYPE <> 'LO' And V_STRFUNCTIONAME ='PLACEORDER' And v_strBOOK = 'A' and v_strTIMETYPE='T' Then
   /* If v_strPRICETYPE <> 'LO' And V_STRFUNCTIONAME in ('PLACEORDER','BLBPLACEORDER') And v_strBOOK = 'A' and v_strTIMETYPE='T' Then
      If v_strPRICETYPE = 'ATO' Then
          --If v_strMarketStatus = 'O' Or v_strMarketStatus = 'A' Then
          IF INSTR('BB1/AW8/AW9/BC1', v_strMarketStatus) > 0 THEN --HSX04: UPdate check phien
            p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            return;
          End If;
      End If;
    if v_strPRICETYPE = 'MP' and V_STRFUNCTIONAME = 'PLACEORDER' then
        if v_strtradeplace = '001' then
            if l_hoseTRADINGID in ('P','A') then
                p_err_code := -100113;--ERR_SA_INVALID_SECSSION
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                return;
            end if;
        else
            SELECT COUNT(1) INTO V_COUNT FROM HA_BRD HB, HASECURITY_REQ HR
            WHERE HB.TRADINGSESSIONID = HR.TRADINGSESSIONID
                AND HR.SYMBOL = v_strsymbol
                AND HR.SECURITYTRADINGSTATUS IN ('17','24','25','26','1','27','28')
                AND HB.BRD_CODE = HR.TRADINGSESSIONSUBID
                ---AND HB.TRADSESSTATUS = '1'
                AND HR.TRADSESSTATUS = '3';
            if V_COUNT >= 1 then
                p_err_code := -100113;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                return;
            end if;
        end if;
    end if;

      /*If v_strPRICETYPE = 'ATC' Then
          If v_strMarketStatus = 'A' Then
            v_strPRICETYPE := 'ATC'; --Do nothing
          ElsIf v_strMarketStatus = 'O' And v_strSystemTime >= v_strATCStartTime Then
            v_strPRICETYPE := 'ATC'; --Do nothing
          Else
            p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            return;
          End If;
      End If;*/

      /*If v_strPRICETYPE = 'MO' Then
          If v_strMarketStatus <> 'O' Then
            p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
          End If;
      End If;
    End If;*/



      --LOCPT 20170215 Check khi het phien thi ko cho dat lenh, theo y/c tu BMS
    v_sessionavai :=  fn_fo_check_ordersys(v_strtradeplace);
    IF v_sessionavai <> 0  and v_strPRICETYPE <> 'PLO'  then
        p_err_code := '-701414';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
    end if;

    --HNX_update: Chan huy lenh PLO da duoc gui len So
     If p_functionname in ('CANCELORDER','BLBCANCELORDER') THEN
       SELECT COUNT(*) INTO V_COUNTSTATUS FROM ood , ODMAST OD
              WHERE OOD.orgorderid =p_acctno AND OOD.ORGORDERID=OD.ORDERID
                    AND OD.PRICETYPE='PLO' AND OOD.OODSTATUS IN ('B','S') ;
       IF V_COUNTSTATUS > 0 THEN
            p_err_code:=-700030;--C_OD_ORDER_SENDING
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.setendsection(pkgctx, 'pr_placeorder');
            return;
         END IF;
       END IF;
    --- Chan huy/sua phien 3 theo thong tu 203
        /*If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','BLBAMENDMENTORDER','BLBCANCELORDER')
         --and fn_get_controlcode(v_strSYMBOL) in ('A','CLOSE','CLOSE_BL') and v_strPRICETYPE NOT IN ('PLO') then
           and fn_get_controlcode(v_strSYMBOL) in ('AA1','BC1') and v_strPRICETYPE NOT IN ('PLO') THEN --HSX04: UPdate check phien
               p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.setendsection(pkgctx, 'pr_placeorder');
             return;
        end if;*/

     --TT203 Namtv end
     --Ngay 07/3/2017 CW NamTv them check chung quyen dao han
     If p_functionname ='PLACEORDER' THEN
        if fn_check_cwsecurities(v_strsymbol) <> 0 then
            p_err_code:=-100128;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error pr_placeorder.p_functionname:= '  || p_functionname
                            || ', v_strACCTNO:' || v_strACCTNO
                            || ', v_strsymbol:' || v_strsymbol
                            );
            plog.setendsection(pkgctx, 'pr_placeorder');
            return;
        end if;
     end if;
     --End NamTv


         -- Ngay 26/12/2022 NamTv check traderid cho lenh huy/sua
      if v_strtradeplace = errnums.gc_TRADEPLACE_HCMCSTC and V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER') then
           If (l_exectype in ('NS','NB','CB','CS','AB','AS')) Then
                  --Tham so ham Check TraderID
                  SELECT FNC_CHECK_TRADERID(v_strMATCHTYPE,substr(l_exectype ,2,1),case when v_strVIA  in ('O','M') then  'O' else v_strVia  end )  into l_dblTraderID FROM DUAL;
                  If l_dblTraderID = 0 Then
                      p_err_code :=errnums.C_OD_TRADERID_NOT_INVALID;
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.setendsection (pkgctx, 'fopks_api.placeorder');
                      return;
                  End If;
           End If;
     end if;
    --NamTv end

    --------
    ---If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER') And v_strTradePlace = '001' Then
    If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','BLBAMENDMENTORDER','BLBCANCELORDER') And v_strTradePlace = '001' Then
        --plog.debug(pkgctx, 'Kiem tra phien giao dich :' || v_strMarketStatus);
        -- Kiem tra neu lenh da day vao ODMAST ma chua day len san thi ko check trang thai phien GD
        /*BEGIN
            SELECT orstatus, PRICETYPE INTO v_strOrderStatus, v_strPRICETYPE
            FROM odmast od WHERE od.orderid = v_strACCTNO;
        EXCEPTION WHEN OTHERS THEN
            v_strOrderStatus := null;
        END;
        plog.debug(pkgctx, 'v_strOrderStatus :' || v_strOrderStatus);
        IF v_strOrderStatus IS NOT NULL THEN
            IF trim(v_strOrderStatus) NOT IN ('8','11','5','9') THEN
                --If v_strMarketStatus = 'P' Then
                IF v_strMarketStatus = 'AA1' THEN --HSX04: UPdate check phien
                    p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    RETURN;
                End If;
                --If v_strMarketStatus = 'A' Then
                If v_strMarketStatus = 'BC1' THEN  --HSX04: UPdate check phien
                    SELECT count(orderid) into v_count FROM odmast WHERE orderid = v_strACCTNO AND hosesession = 'A';
                     If v_count > 0 Then
                         p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                         plog.error(pkgctx, 'Error:'  || p_err_message);
                         plog.setendsection(pkgctx, 'pr_placeorder');
                         RETURN;
                     End If;
                     -- Neu lenh ATC da day len san thi ko cho phep huy
                     IF v_strPRICETYPE = 'ATC' THEN
                         p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                         plog.error(pkgctx, 'Error:'  || p_err_message);
                         plog.setendsection(pkgctx, 'pr_placeorder');
                         RETURN;
                     END IF;
                End If;


            END IF;
        END IF;*/
        NULL;
    End If;

    p_err_code:=FN_CHECKTRADSESSTATUS(v_strSYMBOL,v_dblQUANTITY,p_functionname,v_strPRICETYPE, 'N', p_isBuyIn, v_strTIMETYPE, v_strOrderStatus);
    If p_err_code <> systemnums.C_SUCCESS THEN
       p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
       plog.setendsection(pkgctx, 'pr_PlaceOrder_new');
       RETURN;
    END IF;


    --HSX04|iss:103 check market domain
        IF NOT fn_checkdomain(v_strAFACCTNO, v_strSYMBOL, true) THEN
            plog.error('day la log fn_checkdomain');
            p_err_code := -701117;--ERR_SA_INVALID_SECSSION
            p_err_message := cspks_system.fn_get_errmsg(p_err_code);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
        end IF;

    If V_STRFUNCTIONAME in ( 'PLACEORDER','BLBPLACEORDER') Then
        --HSX04: Chan KH, moi gioi dat lenh F2 neu bi gioi han giao dich
           IF fn_check_restrction_allow(p_symbol, p_afacctno, substr(p_exectype,2,1)) <> 'Y' THEN
              p_err_code := '-700150';
              p_err_message := cspks_system.fn_get_errmsg(p_err_code);
              plog.setendsection(pkgctx, 'pr_PlaceOrder_new');
              Return;
           END IF;
         select actype, (case when corebank='Y' AND p_exectype IN ('NB') then 'W' else 'P' end) into v_strACTYPE, v_strSTATUS from afmast where acctno = v_strafacctno;
          if l_HoldDirect='Y' then
            v_strSTATUS:='P';
          end if;
          -- PhuongHT:  -- PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
         /*IF v_strPRICETYPE IN ('MTL','MOK','MAK') AND l_hnxTRADINGID IN ('CLOSE','CLOSE_BL') AND v_strtradeplace = '002' THEN
           p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_placeorder');
           RETURN;
         END IF;*/
          -- end of  PhuongHT: PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
         /* --PhuongHT edit: tieu khoan Margin trang thai CALL : ko duoc dat lenh ban thuong
         IF V_STRISDISPOSAL <> 'Y' THEN
          IF v_strEXECTYPE='NS' THEN
             SELECT COUNT(*) INTO v_COUNT FROM VW_MR0003_ALL WHERE ACCTNO=P_AFACCTNO;
             IF v_COUNT>0 THEN
                 p_err_code:= -180067;--ERR_SA_INVALID_SECSSION
                 p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                 plog.error(pkgctx, 'Error:'  || p_err_message);
                 plog.setendsection(pkgctx, 'pr_placeorder');
                 RETURN;
             END IF;
           ELSIF v_strEXECTYPE='NB' THEN
              SELECT COUNT(*) INTO v_COUNT
              FROM CIMAST CI,BUF_CI_ACCOUNT BUFF
              WHERE CI.AFACCTNO=P_AFACCTNO
              AND BUFF.AFACCTNO=CI.Afacctno
              AND CI.OVAMT-GREATEST(0,CI.BALANCE+NVL(BUFF.AVLADVANCE,0)- CI.BUYSECAMT) >0;
              IF v_COUNT>0 THEN
                 p_err_code:= -180068;--ERR_SA_INVALID_SECSSION
                 p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                 plog.error(pkgctx, 'Error:'  || p_err_message);
                 plog.setendsection(pkgctx, 'pr_placeorder');
                 RETURN;
               END IF;
           END IF;
          END IF;
          -- end of PhuongHT*/
         /*IF v_strPRICETYPE IN ('ATO') AND l_hoseTRADINGID IN ('I','F','A') AND v_strtradeplace = '001' THEN
               p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, 'Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_placeorder');
               RETURN;
         END IF;
          -- PhuongHT: check chung khoan moi niem yet, dac biet: khong dc dat lo le
        if v_strtradeplace in ('002','005') then
             begin
                  select nvl(securitytradingstatus,'17')
                  into v_securitytradingSTS
                  from hasecurity_req
                  where symbol=v_strSYMBOL;
             exception when others then
               v_securitytradingSTS:='17';
             end;
               if v_securitytradingSTS in ('1','27') and v_dblQUANTITY < l_dblTradeLot  then
                     p_err_code := -100113;
                     p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                     plog.error(pkgctx, 'Error:'  || p_err_message);
                     plog.setendsection(pkgctx, 'pr_placeorder');
                     RETURN;
               end if ;
         end if;*/
      -- Lay gia tri loai hinh lenh
      v_strODACTYPE := fopks_api.fn_GetODACTYPE(v_strAFACCTNO, p_symbol, v_strCODEID, v_strtradeplace, p_exectype,
                                    p_pricetype, p_timetype, v_strACTYPE, v_sectype, v_strVIA);
      select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
      v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_RECEIVED';

      -- Kiem tra mua ban cung ngay
     /* IF (fnc_check_buy_sell(v_strAFACCTNO,TO_DATE(v_strBUSDATE,'DD/MM/YYYY'), v_strCODEID, v_strEXECTYPE, v_strPRICETYPE, v_strMATCHTYPE, v_strtradeplace) = false AND p_timetype <> 'G') THEN
            p_err_code:=-700016;--Ko duoc mua ban CK cung ngay
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
      END IF;*/
   v_strFEEDBACKMSG := 'Order is received and pending to process';

/*      \* Dua su kien vao queue *\
      if p_direct='N' then
        CSPKS_ESB.sp_notify_order(v_strORDERID,v_strAFACCTNO);
      end if;
      \* Ket thuc Dua su kien vao queue *\*/
      INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
          CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
          VIA, DIRECT, SPLOPT, SPLVAL, EFFDATE, EXPDATE, USERNAME, DFACCTNO,SSAFACCTNO, TLID,QUOTEQTTY, LIMITPRICE,Isdisposal,REFORDERID,ROOTQTTY,ISBUYIN)
          VALUES (v_strORDERID,v_strORDERID,v_strODACTYPE,v_strAFACCTNO,v_strSTATUS,
          v_strEXECTYPE,v_strPRICETYPE,v_strTIMETYPE,v_strMATCHTYPE,
          v_strNORK,v_strCLEARCD,v_strCODEID,v_strSYMBOL,
          'N',v_strBOOK,v_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
          v_dblCLEARDAY ,v_dblQUANTITY ,v_dblPRICE ,v_dblQUOTEPRICE ,v_dblTRIGGERPRICE ,0 ,0 ,v_dblQUANTITY ,
          v_strVIA,v_strDIRECT,v_strSPLITOPTION,v_strSPLITVALUE , TO_DATE(v_streffdate,'DD/MM/RRRR'),TO_DATE(v_strexpdate,'DD/MM/RRRR'),
          v_strUSERNAME,v_strDEALID,'', v_strTLID, v_dblQUOTEQTTY, v_dblLIMITPRICE,V_STRISDISPOSAL, p_refOrderId,v_dblQUANTITY,p_isBuyIn);

      p_err_code := systemnums.C_SUCCESS;
        plog.error('day la log v_strDIRECT: '||v_strDIRECT||' v_strBOOK: '||v_strBOOK||' v_strSTATUS: '||v_strSTATUS||' v_strTIMETYPE:'||v_strTIMETYPE);
      --Day lenh vao ODMAST luon neu la lenh Direct
      If v_strDIRECT='Y' and v_strBOOK='A' and v_strTIMETYPE ='T' and v_strSTATUS='P' Then
          --Goi thu tuc day ca lenh vao ODMAST
          TXPKS_AUTO.pr_fo2odsyn(v_strORDERID,p_err_code,v_strTIMETYPE);

          -- Neu lenh thieu suc mua thi dong bo lai ci
          IF nvl(p_err_code,'0') = '-400116' THEN
                jbpks_auto.pr_trg_account_log(v_strAFACCTNO, 'CI');
          END IF;

          If nvl(p_err_code,'0') <> '0' Then
              --Xoa luon lenh o FOMAST neu o mode direct
              UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=v_strORDERID;
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'pr_placeorder');
              Return;
          End If;
      End If;

      --19/12/2022 TrungNQ CHECK THEM DIEU KIEN KICH HOAT VSD
      BEGIN
        SELECT cf.activests
            INTO l_activests
        FROM cfmast cf, afmast mst
        WHERE cf.custid = mst.custid
            AND mst.acctno = v_strAFACCTNO;
      EXCEPTION WHEN others THEN
        l_activests := 'Y';
      END;

      if l_activests <> 'Y' then
        p_err_code := '-100139';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);

        UPDATE fomast SET
        status = 'R',
        feedbackmsg   = '[' || p_err_code || '] ' || p_err_message
        WHERE acctno = v_strORDERID;

        INSERT INTO rootordermap(foacctno, orderid, status, MESSAGE, id)
        VALUES (v_strORDERID, '', 'R', '[' || p_err_code || '] ' || p_err_message, '1');

        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        Return;
      End If;
    --End 19/12/2022

    --Ngay 20/07/2018 NamTv them log chu ky so, otp
    pr_insert_odauth_log(v_strORDERID, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress,
                         p_orderdata, p_macaddress, P_ERR_CODE, P_ERR_MESSAGE);

    --Ngay 20/07/2018 NamTv End;
    --TrungNQ 06/06/2022 : Log them thong tin thiet bi dat lenh
    BEGIN
        pr_insertlogplaceorder( v_strORDERID,  getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device, v_custodycd, p_afacctno,'',
                                p_model,p_versionDevice,p_versionCode,'PLACEORDER');
    EXCEPTION WHEN others THEN
        /*Neu ham ghi log loi ==> van cho thuc hien tiep */
        plog.error(pkgctx, 'ORDERID:' || nvl(v_strORDERID,'')
                   || ', username:' || nvl(p_username,'')
                   || ', afacctno:' || nvl(p_afacctno,''));
        plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
        plog.setEndSection(pkgctx, 'pr_PlaceOrder');
    END;
    --End TrungNQ 06/06/2022
  ElsIf V_STRFUNCTIONAME = 'ACTIVATEORDER' Then
      UPDATE FOMAST SET BOOK='A',ACTIVATEDT=TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') WHERE BOOK='I' AND ACCTNO=v_strACCTNO;
      v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_ACTIVATED';
      p_err_code := systemnums.C_SUCCESS;
      --Day lenh vao ODMAST luon
      If v_strDIRECT='Y' and v_strSTATUS='P' Then
          --Goi thu tuc day ca lenh vao ODMAST
          TXPKS_AUTO.pr_fo2odsyn(v_strORDERID,p_err_code);
          If nvl(p_err_code,'0') <> '0' Then
              --Cap nhat trang thai tu choi
              UPDATE FOMAST SET STATUS='R' WHERE ACCTNO=v_strACCTNO;
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'pr_placeorder');
              Return;
          End If;

        --Ngay 20/07/2018 NamTv them log chu ky so, otp
        pr_insert_odauth_log(v_strORDERID, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress,
                             p_orderdata, p_macaddress, P_ERR_CODE, P_ERR_MESSAGE);
        --Ngay 20/07/2018 NamTv End;
        --TrungNQ 06/06/2022 : Log them thong tin thiet bi dat lenh
        BEGIN
            pr_insertlogplaceorder( v_strORDERID,  getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device, v_custodycd, p_afacctno,'',
                                        p_model,p_versionDevice,p_versionCode,'PLACEORDER');
        EXCEPTION WHEN others THEN
            /*Neu ham ghi log loi ==> van cho thuc hien tiep */
            plog.error(pkgctx, 'ORDERID:' || nvl(v_strORDERID,'')
                       || ', username:' || nvl(p_username,'')
                       || ', afacctno:' || nvl(p_afacctno,''));
            plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
            plog.setEndSection(pkgctx, 'pr_PlaceOrder');
        END;
        --End TrungNQ 06/06/2022
      End If;
  ElsIf V_STRFUNCTIONAME = 'CANCELGTCORDER' Then
      begin
            SELECT status into v_strFOStatus FROM fomast WHERE acctno = v_strACCTNO and TIMETYPE='G' and deltd <> 'Y';
            if v_strFOStatus='P' or v_strFOStatus='R'  or v_strFOStatus='W' THEN
                SELECT CDCONTENT
                INTO v_strFEEDBACKMSG
                FROM ALLCODE WHERE CDTYPE = 'OD' AND CDNAME = 'ORSTATUS' AND CDVAL = 'R';
                update fomast set
                    --deltd='Y',
                    CANCELQTTY = REMAINQTTY,
                    REMAINQTTY = 0,
                    STATUS = 'R',
                    FEEDBACKMSG = v_strFEEDBACKMSG
                where acctno = v_strACCTNO;

                --Ngay 20/07/2018 NamTv them log chu ky so, otp
                pr_insert_odauth_log(v_strACCTNO, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress,
                                     p_orderdata, p_macaddress, P_ERR_CODE, P_ERR_MESSAGE);
                --Ngay 20/07/2018 NamTv End;

                --TrungNQ 06/06/2022 : Log them thong tin thiet bi dat lenh
                BEGIN
                    pr_insertlogplaceorder( p_acctno, getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device, v_custodycd, p_afacctno,'',
                                p_model,p_versionDevice,p_versionCode,'CANCELORDER');
                EXCEPTION WHEN others THEN
                    /*Neu ham ghi log loi ==> van cho thuc hien tiep */
                    plog.error(pkgctx, 'ORDERID:' || nvl(v_strORDERID,'')
                               || ', username:' || nvl(p_username,'')
                               || ', afacctno:' || nvl(p_afacctno,''));
                    plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
                    plog.setEndSection(pkgctx, 'pr_PlaceOrder');
                END;
                --End TrungNQ 06/06/2022

                p_err_code := systemnums.C_SUCCESS;
            ELSIF v_strFOStatus = 'A' THEN
                If v_strBOOK = 'A' Then
                  --Kiem tra da ton tai lenh huy hay chua - return message loi.
                  SELECT count(1) into v_count FROM fomast WHERE refacctno = v_strACCTNO AND substr(exectype,1,1) = 'C' and status <> 'R';
                  If v_count = 0 Then
                      -- Lenh da thuc hien huy tren OD?
                      -- Ducnv FF Gateway
                      SELECT count(1) into v_count FROM odmast WHERE reforderid = v_strACCTNO  AND substr(exectype,1,1) = 'C' and orstatus<>'6';
                      -- End Ducnv FF Gateway
                      If v_count = 0 Then
                          -- Kiem tra xem con khoi luong chua khop hay khong.
                          SELECT count(1) into v_count FROM odmast WHERE orderid = v_strACCTNO  AND remainqtty > 0;
                          If v_count=0 Then
                              p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                              plog.error(pkgctx, 'Error:'  || p_err_message);
                              plog.setendsection(pkgctx, 'pr_placeorder');
                              return;
                          End If;
                      Else
                          p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                          p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                          plog.error(pkgctx, 'Error:'  || p_err_message);
                          plog.setendsection(pkgctx, 'pr_placeorder');
                          return;
                      End If;
                  Else
                      p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.error(pkgctx, 'Error:'  || p_err_message);
                      plog.setendsection(pkgctx, 'pr_placeorder');
                      return;
                  End If;

                      --Generate OrderID
                      select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
                      v_strFEEDBACKMSG := 'MSG_CANCEL_ORDER_IS_RECEIVED';
                        -- SInh lenh huy
                   /*   \* Dua su kien vao queue *\
                      if p_direct='N' then
                        CSPKS_ESB.sp_notify_order(v_strORDERID,v_strAFACCTNO);
                      end if;
                      \* Ket thuc Dua su kien vao queue *\*/
                      INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                          CONFIRMEDVIA, DIRECT, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
                          REFACCTNO, REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE,EXPDATE,USERNAME, TLID,QUOTEQTTY, LIMITPRICE,ISDISPOSAL,ROOTQTTY)
                      SELECT v_strORDERID,od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
                         (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR od.EXECTYPE='AB' THEN 'CB' ELSE 'CS' END) CANCEL_EXECTYPE,
                         od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
                         'O' CONFIRMEDVIA,v_strDIRECT ,'A' BOOK, v_strFEEDBACKMSG ,
                         TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
                         od.CLEARDAY,od.exqtty QUANTITY,(od.exprice/1000) PRICE, (od.QUOTEPRICE/1000) QUOTEPRICE, 0 TRIGGERPRICE, od.EXECQTTY, od.EXECAMT,
                         od.REMAINQTTY, od.orderid REFACCTNO, 0 REFQUANTITY, 0 REFPRICE, (od.QUOTEPRICE/1000) REFQUOTEPRICE,
                         v_strVIA VIA,OD.TXDATE EFFDATE,OD.EXPDATE EXPDATE,
                         v_strUSERNAME USERNAME, v_strTLID TLID,v_dblQUOTEQTTY , v_dblLIMITPRICE,V_STRISDISPOSAL, v_dblQUANTITY
                         FROM ODMAST od, sbsecurities sb
                         WHERE orstatus IN ('1','2','4','8') AND orderid=v_strACCTNO and sb.codeid = od.codeid
                            and orderid not in (select REFACCTNO
                                                    from fomast
                                                    WHERE EXECTYPE IN ('CB','CS') AND STATUS <>'R'
                                               );
                    --Ngay 20/07/2018 NamTv them log chu ky so, otp
                       pr_insert_odauth_log(v_strORDERID, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress,
                                             p_orderdata, p_macaddress, P_ERR_CODE, P_ERR_MESSAGE);
                    --Ngay 20/07/2018 NamTv End;
                    --TrungNQ 06/06/2022 : Log them thong tin thiet bi dat lenh
                      BEGIN
                        pr_insertlogplaceorder( v_strORDERID, getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device, v_custodycd, p_afacctno,'',
                                                p_model,p_versionDevice,p_versionCode,'CANCELORDER');
                      EXCEPTION WHEN others THEN
                        /*Neu ham ghi log loi ==> van cho thuc hien tiep */
                        plog.error(pkgctx, 'ORDERID:' || nvl(v_strORDERID,'')
                                   || ', username:' || nvl(p_username,'')
                                   || ', afacctno:' || nvl(p_afacctno,''));
                        plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
                        plog.setEndSection(pkgctx, 'pr_PlaceOrder');
                      END;
                      --End TrungNQ 06/06/2022
                      p_err_code := systemnums.C_SUCCESS;
              Else
                  DELETE FROM FOMAST WHERE BOOK='I' AND ORGACCTNO=v_strACCTNO;
                  v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_CANCALLED';
              End If;
            ELSE

             p_err_code:=errnums.c_od_order_sending;
             p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
             plog.error(pkgctx, 'Error:'  || p_err_message);
             plog.setendsection(pkgctx, 'pr_placeorder');
             return;
          end if;
      exception when others then
        p_err_code:=errnums.c_od_order_not_found;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
      end;
  ----ElsIf V_STRFUNCTIONAME = 'CANCELORDER' THEN
  ElsIf V_STRFUNCTIONAME in ( 'CANCELORDER','BLBCANCELORDER') THEN
   -- PhuongHT:  -- Chan huy sua cuoi phien
       /*IF  l_hnxTRADINGID IN ('CLOSE_BL') AND v_strtradeplace = '002' and v_strPRICETYPE NOT IN ('PLO') THEN
         p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
         plog.error(pkgctx, 'Error:'  || p_err_message);
         plog.setendsection(pkgctx, 'pr_placeorder');
         RETURN;
       END IF;*/
      -- end of  PhuongHT:  Chan huy sua cuoi phien
      If v_strBOOK = 'A' Then
          --Kiem tra da ton tai lenh huy hay chua - return message loi.
          SELECT count(1) into v_count FROM fomast WHERE refacctno = v_strACCTNO AND substr(exectype,1,1) = 'C' and status <> 'R';
          If v_count = 0 Then
              -- Lenh da thuc hien huy tren OD?
            -- Ducnv FF Gateway
              SELECT count(1) into v_count FROM odmast WHERE reforderid = v_strACCTNO  AND substr(exectype,1,1) = 'C' and orstatus<>'6';
              -- End Ducnv FF Gateway
              If v_count = 0 Then
                  -- Kiem tra xem con khoi luong chua khop hay khong.
                  SELECT count(1) into v_count FROM odmast WHERE orderid = v_strACCTNO  AND remainqtty > 0;
                  If v_count=0 Then
                      p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.error(pkgctx, 'Error:'  || p_err_message);
                      plog.setendsection(pkgctx, 'pr_placeorder');
                      return;
                  End If;
              Else
                  p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                  p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                  plog.error(pkgctx, 'Error:'  || p_err_message);
                  plog.setendsection(pkgctx, 'pr_placeorder');
                  return;
              End If;
          Else
              p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'pr_placeorder');
              return;
          End If;

          --Kiem tra trang thai cua lenh
          SELECT count(STATUS) into v_count FROM FOMAST WHERE ORGACCTNO=v_strACCTNO  AND EXECTYPE IN ('NB','NS');
          If v_count > 0 Then
              --Lenh chua duoc huy lan nao
              --Kiem tra trang thai cua lenh, Neu la P thi xoa luon
              SELECT max(STATUS) into v_strFOStatus FROM FOMAST WHERE ORGACCTNO=v_strACCTNO  AND EXECTYPE IN ('NB','NS');
              If v_strFOStatus = 'P' Then
                  v_strFEEDBACKMSG := 'Order is cancelled when processing';
                  UPDATE FOMAST SET STATUS='R',FEEDBACKMSG=v_strFEEDBACKMSG  WHERE BOOK='A' AND ACCTNO=v_strACCTNO AND STATUS='P';
              ElsIf v_strFOStatus = 'A' Then
                  --Neu la A tuc la lenh da day vao he thong thi sinh lenh huy
                  v_blnOK := True;
              Else
                  v_strFEEDBACKMSG := 'MSG_REJECT_CANCEL_ORDER';
              End If;
          Else
              --LENH o trong he thong
              v_blnOK := True;
          End If;
          /*if P_VIA <> 'F' AND v_strtradeplace = '001' AND l_hoseTRADINGID in ('J','K') /*and PCK_HOGW.fn_caculate_hose_time > 150000*/ /*AND TO_DATE(V_STRBUSDATE,'DD/MM/RRRR') = TO_DATE(SYSDATE,'DD/MM/RRRR') then
                pr_CancelOrderAfterDay(v_strACCTNO, p_err_code, p_err_message);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
          els*/if v_blnOK Then
              --Generate OrderID
              select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
              v_strFEEDBACKMSG := 'MSG_CANCEL_ORDER_IS_RECEIVED';
              -- Lay thong tin timetype
              SELECT od.timetype INTO v_strTIMETYPE FROM odmast od where od.orderid=v_strACCTNO;
/*
              \* Dua su kien vao queue *\
              if p_direct='N' then
                CSPKS_ESB.sp_notify_order(v_strORDERID,v_strAFACCTNO);
              end if;
              \* Ket thuc Dua su kien vao queue *\*/
              INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                  CONFIRMEDVIA, DIRECT, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
                  REFACCTNO, REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE,EXPDATE,USERNAME, TLID,QUOTEQTTY, LIMITPRICE,ISDISPOSAL,Isbuyin)
              SELECT v_strORDERID,od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
                 (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR od.EXECTYPE='AB' THEN 'CB' ELSE 'CS' END) CANCEL_EXECTYPE,
                 od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
                 'O' CONFIRMEDVIA,v_strDIRECT ,'A' BOOK, v_strFEEDBACKMSG ,
                 TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
                 od.CLEARDAY,od.exqtty QUANTITY,(od.exprice/1000) PRICE, (od.QUOTEPRICE/1000) QUOTEPRICE, 0 TRIGGERPRICE, od.EXECQTTY, od.EXECAMT,
                 od.REMAINQTTY, od.orderid REFACCTNO, 0 REFQUANTITY, 0 REFPRICE, (od.QUOTEPRICE/1000) REFQUOTEPRICE,
                 v_strVIA VIA,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EFFDATE,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EXPDATE,
                 v_strUSERNAME USERNAME, v_strTLID TLID, v_dblQUOTEQTTY , v_dblLIMITPRICE,V_STRISDISPOSAL,od.isbuyin
                 FROM ODMAST od, sbsecurities sb
                 WHERE orstatus IN ('1','2','4','8') AND orderid=v_strACCTNO and sb.codeid = od.codeid
                    and orderid not in (select REFACCTNO
                                            from fomast
                                            WHERE EXECTYPE IN ('CB','CS') AND STATUS <>'R'
                                       );
              p_err_code := systemnums.C_SUCCESS;
              --Day lenh vao ODMAST luon
              If v_strDIRECT='Y' Then
                  --Goi thu tuc day ca lenh vao ODMAST
                  TXPKS_AUTO.pr_fo2odsyn(v_strORDERID,p_err_code,v_strTIMETYPE);
                  If nvl(p_err_code,'0') <> '0' Then
                      --Cap nhat trang thai tu choi
                      UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=v_strACCTNO;
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.error(pkgctx, 'Error:'  || p_err_message);
                      plog.setendsection(pkgctx, 'pr_placeorder');
                      Return;
                  End If;
              End If;

            --Ngay 20/07/2018 NamTv them log chu ky so, otp
               pr_insert_odauth_log(v_strORDERID, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress,
                                     p_orderdata, p_macaddress, P_ERR_CODE, P_ERR_MESSAGE);
            --Ngay 20/07/2018 NamTv End;

            --TrungNQ 06/06/2022 : Log them thong tin thiet bi dat lenh
            BEGIN
                pr_insertlogplaceorder( v_strORDERID, getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device,v_custodycd, p_afacctno,'',
                                        p_model,p_versionDevice,p_versionCode,'CANCELORDER');
            EXCEPTION WHEN others THEN
                /*Neu ham ghi log loi ==> van cho thuc hien tiep */
                plog.error(pkgctx, 'ORDERID:' || nvl(v_strORDERID,'')
                           || ', username:' || nvl(p_username,'')
                           || ', afacctno:' || nvl(p_afacctno,''));
                plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
                plog.setEndSection(pkgctx, 'pr_PlaceOrder');
            END;
            --End TrungNQ 06/06/2022

          End If;
      Else
          DELETE FROM FOMAST WHERE BOOK='I' AND ACCTNO=v_strACCTNO;
          v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_CANCALLED';
      End If;

  ---ElsIf V_STRFUNCTIONAME = 'AMENDMENTORDER' Then
  ElsIf V_STRFUNCTIONAME in ( 'AMENDMENTORDER','BLBAMENDMENTORDER') Then
      plog.debug(pkgctx, 'V_STRFUNCTIONAME:'  || V_STRFUNCTIONAME);
      -- PhuongHT:  -- Chan huy sua cuoi phien
       IF  l_hnxTRADINGID IN ('CLOSE_BL') AND v_strtradeplace = '002' THEN
         p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
         plog.error(pkgctx, 'Error:'  || p_err_message);
         plog.setendsection(pkgctx, 'pr_placeorder');
         RETURN;
       END IF;

       ---DungNH : check room nuoc ngoai
        SELECT max(CURRENT_ROOM)
        into l_dblRoom
        FROM SECURITIES_INFO INF WHERE INF.CODEID= v_strcodeid;
        l_dblRoom :=  nvl(l_dblRoom,0);
        select max(custodycd) into v_strcustodycd
        from cfmast cf, afmast af
        where cf.custid = af.custid and af.acctno = p_afacctno;
        ----v_strcodeid, v_strtradeplace
        if(v_strtradeplace = '002' and SUBSTR(v_strcustodycd,4,1) = 'F')then
            if l_dblRoom < p_quantity then
                p_err_code := '-700051';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
            end if;
        end if;
       --- end DungNH

      -- end of  PhuongHT:  Chan huy sua cuoi phien
      --PhuongHT add: chan khong sua lenh HNX lon hon max KL HNX
       IF v_dblQUANTITY > L_MaxHNXQtty AND v_strtradeplace in ( '002','005') THEN
         p_err_code:= -700109;--ERR_SA_INVALID_SECSSION
         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
         plog.error(pkgctx, 'Error:'  || p_err_message);
         plog.setendsection(pkgctx, 'pr_placeorder');
         RETURN;
       END IF;
      --PhuongHT: check khoi luong chung khoan khi sua lenh ban

        --begin check kl
            SELECT exectype,orderqtty, pricetype
            INTO l_exectype ,l_oldOrderqtty, v_strPricetype
            FROM odmast
            WHERE orderid=v_strACCTNO;
            -- chan lenh PLO khong duoc sua
            IF v_strPricetype='PLO' THEN
              p_err_code:=-700030;--C_OD_ORDER_SENDING
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.setendsection(pkgctx, 'pr_placeorder');
              return;
            END IF;
            --End chan lenh PLO khong duoc sua
            IF (l_exectype IN ('NS','MS')) THEN
             l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(v_strAFACCTNO||v_strCODEID,'SEMAST','ACCTNO');
             l_TRADE := l_SEMASTcheck_arr(0).TRADE;
             l_dfmortage := l_SEMASTcheck_arr(0).DFMORTAGE;
                    -- neu la ban thuong
              IF l_exectype= 'NS' THEN
                IF NOT (to_number(l_TRADE) >= (p_quantity-l_oldOrderqtty)) THEN
                p_err_code := '-900017';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
                END IF;

              ELSE -- ban cam co
                IF NOT (to_number(l_dfmortage) >= (p_quantity-l_oldOrderqtty)) THEN
                 p_err_code := '-900017';
                 p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                 plog.error(pkgctx, 'Error:'  || p_err_message);
                 plog.setendsection(pkgctx, 'pr_placeorder');
                 RETURN;
                END IF;
              END IF;

            END IF;
            --TPDN: check so du chung khoan lo le
              IF v_strtradeplace ='002' and v_dblQUANTITY < l_dblTradeLot and l_dblTradeLot>0 and p_exectype IN ('NS','MS') Then
                 if v_dblQUANTITY - l_oldOrderqtty > fn_GetCKLL(v_strcustodycd,v_strcodeid) then
                    p_err_code := '-201183'; -- Vuot qua so luong chung khoan le cua tai khoan
                     p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:' || p_err_message);
                    plog.setendsection (pkgctx, 'pr_placeorder');
                    RETURN;
                 end if;
                 if v_dblQUANTITY - l_oldOrderqtty > fn_GetCKLL_AF(v_strACCTNO,v_strcodeid) then
                    p_err_code := '-201186'; -- Vuot qua so luong chung khoan le cua tieu khoan
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:' || p_err_message);
                    plog.setendsection (pkgctx, 'pr_placeorder');
                    RETURN;
                 end if;
             end if;
            --End TPDN

        -- NEU LA SUA LENH Bloomberg theo luong bt
        if V_STRFUNCTIONAME='AMENDMENTORDER'  then
          -- plog.error (pkgctx,'ham check Bloom: v_OdBlOrderid: ' || v_OdBlOrderid || 'p_Quantity:'||p_Quantity  || 'p_exectype:'||l_exectype|| 'p_acctno:'||p_acctno  || 'p_quoteprice:'||p_quoteprice);
           if v_OdBlOrderid is not null then
               p_err_code:=pck_fo_bl.fnc_check_blb_AMENDMENTOrder(v_OdBlOrderid,p_Quantity,l_exectype,p_quoteprice,p_acctno,p_functionname,v_strVIA);
             if p_err_code<>systemnums.C_SUCCESS then
                 p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                 plog.error(pkgctx, 'Error:'  || p_err_message);
                 plog.setendsection(pkgctx, 'pr_placeorder');
                 RETURN;
             end if;
           end if;
        end if;

      -- end of PhuongHT: check khoi luong chung khoan sua lenh ban
      If v_strBOOK = 'A' Then
          --SELECT STATUS FROM FOMAST WHERE ORGACCTNO=v_strACCTNO AND EXECTYPE IN ('NB','NS');
          SELECT count(STATUS) into v_count FROM FOMAST WHERE ORGACCTNO=v_strACCTNO AND EXECTYPE IN ('NB','NS');
          If v_count > 0 Then
              --Lenh chua duoc sua lan nao
              --Kiem tra trang thai cua lenh, Neu la P thi xoa luon
              SELECT max(STATUS) into v_strFOStatus FROM FOMAST WHERE ORGACCTNO=v_strACCTNO AND EXECTYPE IN ('NB','NS');
              If v_strFOStatus = 'P' Then
                  v_strFEEDBACKMSG := 'Order is cancelled when processing';
                  UPDATE FOMAST SET STATUS='R',FEEDBACKMSG=v_strFEEDBACKMSG WHERE BOOK='A' AND ACCTNO=v_strACCTNO AND STATUS='P';
                  v_blnOK := True;
              ElsIf v_strFOStatus = 'A' Then
                  --Neu la A tuc la lenh da day vao he thong thi sinh lenh huy
                  v_blnOK := True;
              Else
                  v_strFEEDBACKMSG := 'MSG_REJECT_CANCEL_ORDER';
              End If;
          Else
              --LENH o trong he thong
              v_blnOK := True;
          End If;

          --Generate OrderID
          select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
          v_strFEEDBACKMSG := 'MSG_ADMENT_ORDER_RECEIVED';
          plog.debug(pkgctx, 'Amend Orderid:'  || v_strORDERID);

          select (case when AF.corebank='Y' AND OD.exectype IN ('NB')  then 'W' else 'P' end) status, od.timetype
          into v_strSTATUS, v_strTIMETYPE
          from afmast AF, ODMAST OD
          WHERE OD.AFACCTNO = AF.ACCTNO AND OD.ORDERID = v_strACCTNO;

          if l_HoldDirect='Y' then
            v_strSTATUS:='P';
          end if;
          plog.debug(pkgctx, 'v_strSTATUS: '  || v_strSTATUS);
          /* Dua su kien vao queue */
           /* CSPKS_ESB.sp_notify_order(v_strORDERID,v_strAFACCTNO);*/
          /* Ket thuc Dua su kien vao queue */
            -- quyet.kieu Sua
          INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
              CONFIRMEDVIA,DIRECT, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
              REFACCTNO, REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE,EXPDATE,USERNAME, TLID, Quoteqtty,limitprice,ISDISPOSAL,BLORDERID)
          SELECT v_strORDERID,od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, v_strSTATUS,
              (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR EXECTYPE='AB' THEN 'AB' ELSE 'AS' END) CANCEL_EXECTYPE,
              od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
              'O' CONFIRMEDVIA, v_strDIRECT,'A' BOOK, v_strFEEDBACKMSG  FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ACTIVATEDT,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') CREATEDDT, od.CLEARDAY,
               v_dblQUANTITY , v_dblPRICE , v_dblQUOTEPRICE ,0 TRIGGERPRICE, 0 EXECQTTY, 0 EXECAMT,v_dblQUANTITY  REMAINQTTY,
              od.orderid REFACCTNO, ORDERQTTY REFQUANTITY, round(QUOTEPRICE/SIF.TRADEUNIT,2) REFPRICE, round(QUOTEPRICE/SIF.TRADEUNIT,2) REFQUOTEPRICE,
              v_strVIA  VIA ,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EFFDATE,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EXPDATE,
              v_strUSERNAME USERNAME, v_strTLID TLID,  v_dblQUOTEQTTY,v_dblLIMITPRICE,V_STRISDISPOSAL, v_OdBlOrderid
           FROM ODMAST od, sbsecurities sb, securities_info SIF
           WHERE orstatus IN ('1','2','4','8') AND orderid=v_strACCTNO and sb.codeid = od.codeid AND SIF.CODEID = OD.CODEID
              and orderid not in (select REFACCTNO from fomast WHERE EXECTYPE IN ('CB','CS','AB','AS') AND STATUS <>'R' );
          --plog.debug(pkgctx, 'v_strDIRECT:'  || v_strDIRECT);
          p_err_code := systemnums.C_SUCCESS;
          --Day lenh vao ODMAST luon
           If v_strDIRECT='Y' Then
               --Goi thu tuc day ca lenh vao ODMAST
               TXPKS_AUTO.pr_fo2odsyn(v_strORDERID,p_err_code,v_strTIMETYPE);
               If nvl(p_err_code,'0') <> '0' Then
                   --Cap nhat trang thai tu choi
                   UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=v_strACCTNO;
                   p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                   plog.error(pkgctx, 'Error:'  || p_err_message);
                   plog.setendsection(pkgctx, 'pr_placeorder');
                   Return;
               End If;
           End If;
            --Ngay 20/07/2018 NamTv them log chu ky so, otp
               pr_insert_odauth_log(v_strORDERID, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress,
                                     p_orderdata, p_macaddress, P_ERR_CODE, P_ERR_MESSAGE);
            --Ngay 20/07/2018 NamTv End;

            --TrungNQ 06/06/2022 : Log them thong tin thiet bi dat lenh
               BEGIN
                pr_insertlogplaceorder( v_strORDERID, getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device,v_custodycd, p_afacctno,'',
                                        p_model,p_versionDevice,p_versionCode,'PUTORDER');
               EXCEPTION WHEN others THEN
                /*Neu ham ghi log loi ==> van cho thuc hien tiep */
                plog.error(pkgctx, 'ORDERID:' || nvl(v_strORDERID,'')
                           || ', username:' || nvl(p_username,'')
                           || ', afacctno:' || nvl(p_afacctno,''));
                plog.error(pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
                plog.setEndSection(pkgctx, 'pr_PlaceOrder');
               END;
            --End TrungNQ 06/06/2022
      Else
          UPDATE FOMAST SET
          QUANTITY=v_dblQUANTITY ,
          PRICE=v_dblPRICE /1000,
          QUOTEPRICE=v_dblQUOTEPRICE /1000,
          Quoteqtty= v_dblQUOTEQTTY,
          Limitprice= v_dblLIMITPRICE
               WHERE BOOK='I' AND ACCTNO=v_strACCTNO;
          v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_ADMANMENT';
      End If;
  End If;

    -- neu la dat lenh Bloomberg
    If p_functionname in ('BLBPLACEORDER','BLBAMENDMENTORDER','BLBCANCELORDER') Then
        --plog.error(pkgctx,'goi ham update bloom:p_functionname: ' || p_functionname ||',p_acctno:'|| p_acctno ||',v_strORDERID:'|| v_strORDERID ||',v_blorderid:'|| v_blorderid ||',v_dblQUANTITY:'|| v_dblQUANTITY ||',p_tlid:'|| p_tlid);
        fopks_api.pr_blbPlaceOrder_update(p_functionname,p_acctno,v_strORDERID, v_blorderid,v_dblQUANTITY,p_tlid);
    end if;
  -- neu la huy/sua lenh BloomBerg qua cac man hinh binh thuong
    if (p_functionname in ('AMENDMENTORDER','CANCELORDER') and v_strDIRECT='Y') then
       if v_OdBlOrderid IS NOT NULL then
          fopks_api.pr_blbPlaceOrder_update(p_functionname,p_acctno,v_strORDERID, v_OdBlOrderid,v_dblQUANTITY,p_tlid);
       end if;
    end if;
    -- TheNN, 20-Dec-2013
    -- Ghi nhan lenh huy/sua tu cac kenh khac nhau neu lenh goc la lenh Bloomberg
    IF (p_functionname in ('AMENDMENTORDER','CANCELORDER','BLBAMENDMENTORDER','BLBCANCELORDER') and v_strDIRECT='Y' AND v_OdBlOrderid IS NOT NULL) THEN
        pck_fo_bl.bl_Place_AmendOrder(P_FOACCTNO=>v_strORDERID);
    END IF;
    -- End of: TheNN, 20-Dec-2013

    IF p_err_code IS NULL  OR LENGTH(p_err_code)=0 THEN
        p_err_code := systemnums.C_SUCCESS;
    END IF;
    if p_err_message is null then
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    end if;
    plog.setendsection(pkgctx, 'pr_placeorder');
    --Ngay 30/08/2018 thunt them log chu ky so
    --if p_validationtype ='4' then
       --insert into odauth_log(orderid, acctno, codeid, otauthtype, ipaddress, orderdata)
       --select v_strORDERID, v_strAFACCTNO, v_strCODEID, p_validationtype, p_ipaddress, p_orderdata
       --from dual;
    --end if;
    --end--30/08/2018
  exception
    when others then
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_placeorder');

  end pr_placeorder;


  --Ket thuc Ham xu ly dat lenh vao FOMAST--

PROCEDURE pr_blbPlaceOrder_update (p_functionname   in varchar2,
                                   p_acctno        in varchar2, --huy/sua lenh thi day la orderid lenh goc
                                   p_ORDERID       IN  VARCHAR2,-- foacctno
                                   p_BLORDERID     IN  VARCHAR2,-- BlOrderid lenh tong
                                   p_QUANTITY      IN  NUMBER,
                                   p_tlid          in varchar2,
                                   p_newOrderid    in varchar2 default '')-- Orderid cua lenh NB moi:sua lenh qua duong asyn
IS
    v_BLORDERID    VARCHAR2(30);
    v_ORDERID    VARCHAR2(30);
    v_Quantity   number;
    v_status varchar(2);
    v_oldOrderqtty number;
    v_oldQuotePrice  number;
    v_OD_remainqtty   number;
    v_isBlOrder       varchar2(1);
    v_exectype        varchar2(10);
    l_count number;
    l_orderidtest varchar2(40);
    v_execqtty    number(20,0);
    v_odStatus  varchar2(5);
    v_oldvia       varchar2(2);
    v_via          varchar2(2);
    v_forefid       varchar2(50);
    v_traderid      varchar2(50);
    v_refforefid    varchar2(50);
    v_refblorderid  varchar2(50);
    v_blodtype      varchar2(10);
BEGIN


    -- do gia tri orderid truyen vao txpks_auto.fo2odsyn la acctno trong fomast
    -- nen can link den fomast de update BLORDERID cho lenh ODMAST
    v_ORDERID:=p_ORDERID;
    v_BLORDERID:=p_BLORDERID;
    v_Quantity:=p_QUANTITY;

    if (p_functionname='BLBPLACEORDER') then  -- dat lenh moi
      select status,via, bl.forefid, bl.traderid
      into v_status ,v_via,v_forefid, v_traderid
      from bl_odmast bl where blorderid=v_BLORDERID;

      update fomast set
            blorderid=v_BLORDERID,via=v_via,
            forefid = v_forefid,
            traderid = v_traderid
      where acctno=v_ORDERID ;

      update odmast set
            blorderid=v_BLORDERID,isblorder='Y',via=v_via
      where foacctno=v_ORDERID;

      update bl_odmast set remainqtty=remainqtty-v_Quantity,sentqtty=sentqtty+v_Quantity,
      last_change=systimestamp
      where blorderid=v_BLORDERID;
      -- lenh odmast dat dau tien cho bl_odmast
      if v_status in ('A','T') then
         update bl_odmast set pstatus=pstatus||status,
         status='F',exectime=systimestamp
         where blorderid=v_BLORDERID;
      end if;
    elsif ( p_functionname='BLBAMENDMENTORDER') then -- sua lenh

      -- update lai gia tri cho lenh tong Bloomberg
       select remainQtty, QuotePrice,isblorder,exectype,execqtty,via
       into v_oldOrderqtty,v_oldQuotePrice,v_isblorder,v_exectype,v_execqtty,v_oldvia
       from odmast where orderid=p_acctno;
        -- Lay so hieu lenh sua
        /*select bl.forefid, bl.traderid
        into v_forefid, v_traderid
        from bl_odmast bl where bl.refblorderid=v_BLORDERID;*/
      -- So hieu lenh goc
        select bl.blorderid, bl.forefid, bl.blodtype
        into v_refblorderid, v_refforefid,v_blodtype
        from bl_odmast bl where bl.blorderid = v_BLORDERID;
         -- map voi lenh moi sinh ra
       update fomast set
            blorderid=v_BLORDERID--,
            ---retlid=p_tlid,
            --via=v_oldvia--,
            --forefid = v_forefid,
            --traderid = v_traderid
       where acctno=v_ORDERID ;
       --update lenh trung gian trong ODMAST
       UPDATE odmast SET
            blorderid=v_BLORDERID
        WHERE foacctno = v_ORDERID;

       if (p_newOrderid is not null) then -- neu la lenh asyn
          update odmast set blorderid=v_BLORDERID,isblorder=v_isblorder--,via=v_oldvia
           where orderid =p_newOrderid;
       else-- lenh direct
         update odmast set blorderid=v_BLORDERID,isblorder=v_isblorder--,via=v_oldvia
         where orderid=(select orgacctno from fomast where acctno=v_ORDERID );
       end if;
       -- plog.error (pkgctx,'Sua lenh: ' || v_Quantity ||' , '||v_oldOrderqtty )  ;
       -- sua tang KL thi moi update BLODMAST  luon
       if (( v_Quantity - v_oldOrderqtty-v_execqtty)) > 0 THEN
            IF v_blodtype <> '1' THEN
                update bl_odmast set
                    remainqtty=remainqtty-(v_Quantity-v_oldOrderqtty-v_execqtty),
                    sentqtty=sentqtty+(v_Quantity-v_oldOrderqtty-v_execqtty),
                    last_change=systimestamp
                where blorderid=v_BLORDERID;
            ELSE
                update bl_odmast set
                    sentqtty=sentqtty+(v_Quantity-v_oldOrderqtty-v_execqtty),
                    last_change=systimestamp
                where blorderid=v_BLORDERID;
            END IF;
       end if;

      -- Huy lenh khi xac nhan moi cap nhat trong BL_ODMAST
    elsif ( p_functionname='BLBCANCELORDER') then -- huy lenh
         select isblorder,orstatus,orderqtty,via
         into v_isblorder,v_odStatus,v_oldOrderqtty,v_oldvia
         from odmast where orderid=p_acctno;
        if (p_newOrderid is not null) then -- neu la lenh gian tiep (online...)
           update odmast set blorderid=v_BLORDERID,isblorder=v_isblorder--,via=v_oldvia
           where orderid=p_newOrderid;
        else -- lenh direct
           update odmast set blorderid=v_BLORDERID,isblorder=v_isblorder--,via=v_oldvia
           where orderid=(select orgacctno from fomast where acctno=v_ORDERID );
        end if;

        -- Lay so hieu lenh huy tu BLB
        /*select bl.forefid, bl.traderid
        into v_forefid, v_traderid
        from bl_odmast bl where bl.refblorderid=v_BLORDERID;*/
        -- So hieu lenh goc
        select bl.blorderid, bl.forefid
        into v_refblorderid, v_refforefid
        from bl_odmast bl where bl.blorderid = v_BLORDERID;

        update fomast set
                blorderid=v_refblorderid--,
                ---retlid=p_tlid,
                --via=v_oldvia  ,
                --forefid = v_forefid,
                --traderid = v_traderid
        where acctno=v_ORDERID ;
        /*-- neu la huy lenh cho gui: revert lai trong bl_odmast luon
        if v_odStatus= '8' then
           plog.error(pkgctx,'Huy lenh cho gui v_BLORDERID: ' || v_BLORDERID || ',v_oldOrderqtty:' || v_oldOrderqtty);
          -- TheNN, 05/11/2013: Neu lenh tong da huy thi update so luong huy, ko update remainqtty
            update bl_odmast set
                remainqtty= remainqtty + CASE WHEN status = 'C' THEN 0 ELSE v_oldOrderqtty END ,
                sentqtty=sentqtty - v_oldOrderqtty,
                cancelqtty = cancelqtty + CASE WHEN status = 'C' THEN v_oldOrderqtty ELSE 0 END,
                last_change=systimestamp
           where blorderid=v_BLORDERID;
        end if;*/

    end if;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_blbPlaceOrder_update');
END pr_blbPlaceOrder_update;

---------------------------------pr_InternalTransfer------------------------------------------------
------------------------------Bat dau Chuyen tien boi bo--------------------------------------------
 PROCEDURE pr_CheckCashTransfer(p_account varchar,
                            p_type      varchar2,
                            p_amount    number,
                            p_toaccount varchar2,
                            p_feecd     varchar2,
                            p_feetype   varchar2,
                            p_refamt  OUT  number,
                            p_feeamt  OUT  number,
                            p_vatamt  OUT  number,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2
                            )
  IS
      p_trfcount        number;
      v_keyMinAmt varchar2(50);
      v_keyMaxAmt varchar2(50);
      v_keyCNT varchar2(50);
      v_keyRemain varchar2(50);
      v_keyTransferName varchar2(50);
      l_totalamt    number;
      v_isCHKONLINE     varchar2(1);
      p_totalamt1120    number;
      v_custodycd VARCHAR2(10);
      v_corebank char(1);
      v_tocorebank char(1);
      v_tocustodycd VARCHAR2(10);

      l_cimastcheck_arr     txpks_check.cimastcheck_arrtype;
      l_baldefovd           apprules.field%TYPE;
      l_vatamt      number;
      l_feeamt      number;
      p_RemainAmt   number;
      l_refamt      number;
      p_afamt       number;
      L_STARTTIME   number;
      L_ENDTIME     number;
      L_CURRTIME    number;
      l_custtype    varchar2(10);

BEGIN
   IF (p_type = '0')--Chuyen khoan noi bo
   THEN
   v_keyMinAmt:='ONLINEMINTRF1120_AMT';
   v_keyMaxAmt:='ONLINEMAXTRF1120_AMT';
   v_keyCNT:='ONLINEMAXTRF1120_CNT';
   v_keyRemain:='ONLINEMINREMAINTRF1120_AMT';
   v_keyTransferName:='1120';
   ELSIF  (p_type = '1')--Chuyen khoan ra ngan hang
   THEN
   v_keyMinAmt:='ONLINEMINTRF1101_AMT';
   v_keyMaxAmt:='ONLINEMAXTRF1101_AMT';
   v_keyCNT:='ONLINEMAXTRF1101_CNT';
   v_keyRemain:='ONLINEMINREMAINTRF1101_AMT';
   v_keyTransferName:='1101';
   ELSE--Chuyen khoan ra ben ngoai voi CMT
   v_keyMinAmt:='ONLINEMINTRF1133_AMT';
   v_keyMaxAmt:='ONLINEMAXTRF1133_AMT';
   v_keyCNT:='ONLINEMAXTRF1133_CNT';
   v_keyRemain:='ONLINEMINREMAINTRF1133_AMT';
   v_keyTransferName:='1133';
   END IF;

    select cf.custtype into l_custtype from cfmast cf, afmast af
    where cf.custid = af.custid and af.acctno = p_account;

    /*if nvl(l_custtype,'I') = 'B' then
        p_err_code := '-200422'; --khach hang to chuc khong duoc thuc hien chuc nang nay.
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
        return;
    end if;*/

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTART_TRF_TIME';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEEND_TRF_TIME';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;
    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    IF(L_CURRTIME < L_STARTTIME OR L_CURRTIME > L_ENDTIME)THEN
        begin
            select corebank into v_corebank from afmast where acctno = p_account;
        EXCEPTION WHEN OTHERS THEN
            v_corebank := 'Y';
        END ;
        begin
            select corebank into v_tocorebank from afmast where acctno = p_toaccount;
        EXCEPTION WHEN OTHERS THEN
            v_tocorebank := 'Y';
        end ;
        IF (v_corebank = 'Y' or v_tocorebank = 'Y') then
            p_err_code := '-670043'; --Ngoai gio giao dich
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
    end if;

    /*IF(p_type = '0')THEN
        select corebank into v_corebank from afmast where acctno = p_account;
        select corebank into v_tocorebank from afmast where acctno = p_toaccount;
        IF (v_corebank = 'Y' or v_tocorebank = 'Y') and (L_CURRTIME < L_STARTTIME OR L_CURRTIME > L_ENDTIME) THEN
            p_err_code := '-670043'; --Ngoai gio giao dich
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
        END IF;
    ELSE
        IF(L_CURRTIME < L_STARTTIME OR L_CURRTIME > L_ENDTIME)THEN
            p_err_code := '-670043'; --Ngoai gio giao dich
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
        END IF;
    END IF;*/


   IF (p_type = '0') then
        --Chuyen khoan noi bo thi check them dieu kien khong duoc chuyen cung tai khoan corebank
        select corebank into v_corebank from afmast where acctno = p_account;
        select corebank into v_tocorebank from afmast where acctno = p_toaccount;
        if v_corebank = 'Y' and v_tocorebank = 'Y' then
            p_err_code := '-670404'; --Loi Chuyen tien cung tai khoan corebank cho nhau
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
   end if;

   IF (p_type = '1') then
        --Chuyen khoan ra ngan hang thi check them dieu kien khong duoc chuyen tu tai khoan corebank
        select corebank into v_corebank from afmast where acctno = p_account;
        if v_corebank = 'Y' then
            p_err_code := '-670405';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
   end if;

    begin
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_account,'CIMAST','ACCTNO');
        l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
    EXCEPTION WHEN OTHERS THEN
        l_BALDEFOVD := 0;
    END;

    IF (p_type = '0') then
        l_vatamt := 0;
        l_feeamt := 0;
    ELSE
        begin
            l_vatamt := fn_gettransact_vatfee(p_feecd, p_amount);
            l_feeamt := fn_gettransact_fee(p_feecd, p_amount);
        EXCEPTION WHEN OTHERS THEN
            l_vatamt := 0;
            l_feeamt := 0;
        END;
    end if;

    p_feeamt := nvl(l_feeamt,0);
    p_vatamt := nvl(l_vatamt,0);
    l_refamt := p_amount;

    if(nvl(p_feetype,'1') = '0') then
        l_feeamt := 0;
        l_vatamt := 0;
        l_refamt := l_refamt - p_feeamt-p_vatamt;
    end if;

    p_RemainAmt := l_BALDEFOVD-(p_amount+l_feeamt+l_vatamt);
    p_refamt := l_refamt;
    SELECT  ischkonlimit, CUSTODYCD, cf.onlinelimit
    INTO v_isCHKONLINE, v_custodycd, p_afamt
    FROM CFMAST CF, AFMAST AF
    WHERE CF.custid = AF.custid AND AF.acctno = p_account;

    BEGIN
        SELECT CUSTODYCD
        INTO v_tocustodycd
        FROM CFMAST CF, AFMAST AF
        WHERE CF.custid = AF.custid AND AF.acctno = p_toaccount;
    EXCEPTION WHEN OTHERS THEN
        v_tocustodycd := 'ABC';
    END;

   BEGIN
        if(v_tocustodycd <> v_custodycd) then
        select sum(tl.msgamt) into p_totalamt1120
            from tllog tl, cfmast cf, afmast af,
            (
            select ci.autoid, cf.custodycd, cf.custid,
                ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                ci.camt, ci.ref, nvl(ci.deltd,'N') deltd, ci.acctref,
                tl.tltxcd, tl.busdate,
                case when tl.tlid ='6868' then trim(tl.txdesc) || ' (Online)' else tl.txdesc end txdesc,
                tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                ''  dfacctno,
                ''  old_dfacctno,
                app.txtype, app.field, tl.autoid tllog_autoid,
                case when ci.trdesc is not null
                        then (case when tl.tlid ='6868' then trim(ci.trdesc) || ' (Online)' else ci.trdesc end)
                        else ci.trdesc end trdesc, ci.corebank
            from citran ci, tllog tl, cfmast cf, afmast af, apptx app
            where ci.txdate = tl.txdate and ci.txnum = tl.txnum
                and cf.custid = af.custid
                and ci.acctno = af.acctno
                and ci.txcd = app.txcd and app.apptype = 'CI' and app.txtype in ('D','C')
                and tl.deltd <> 'Y'
                and ci.namt <> 0
        ) tr, CFMAST CF1, AFMAST AF1
            where tl.tltxcd = '1120' and tl.tlid =systemnums.C_ONLINE_USERID and tl.deltd <> 'Y'
                and tl.txnum = tr.txnum and tl.txdate = tr.txdate
                and tr.acctno = af.acctno and af.custid = cf.custid
                AND TR.field = 'BALANCE' AND TR.txtype = 'C'
                and cf.custodycd <> v_custodycd
                and tl.txstatus = '1' and tl.msgacct = AF1.ACCTNO AND AF1.CUSTID = CF1.CUSTID AND CF1.CUSTODYCD = v_custodycd;
            p_totalamt1120 := nvl(p_totalamt1120,0);
            select sum(tl.msgamt) into l_totalamt
            from tllog tl, CFMAST CF, AFMAST AF
            where tl.tltxcd = '1101' and tl.tlid =systemnums.C_ONLINE_USERID and tl.deltd <> 'Y'
                AND TL.msgacct = AF.acctno AND CF.CUSTID = AF.CUSTID AND CF.CUSTODYCD = v_custodycd
                and tl.txstatus = '1' ;
            l_totalamt := NVL(l_totalamt,0);
            l_totalamt:= p_totalamt1120+l_totalamt;
        else
            l_totalamt := 0;
        end if;

   EXCEPTION WHEN OTHERS THEN
        l_totalamt := 0;
   END;
if(v_tocustodycd <> v_custodycd) then
    if v_isCHKONLINE = 'N' and (p_amount+l_feeamt+l_vatamt) > nvl(p_afamt,0) - (l_totalamt) then
        p_err_code:='-100131';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExternalTransfer');
        return;
    end if;
    if l_refamt < 0 then
        p_err_code:='-670406';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExternalTransfer');
        return;
    end if;

    IF (p_type = '0') then
        begin
            if v_isCHKONLINE = 'Y' AND to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1120_AMT')) < (p_amount+l_feeamt+l_vatamt)+l_totalamt then
                p_err_code:='-100135';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_ExternalTransfer');
                return;
            end if;
        exception when others then
            plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi da qua kenh Online');
        end;
    end if;

    IF (p_type = '1') then
    begin
        if v_isCHKONLINE = 'Y' AND to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1101_AMT')) < (p_amount+l_feeamt+l_vatamt)+l_totalamt then
            p_err_code:='-100131';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExternalTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi da qua kenh Online');
    end;
    end if;


/*BEGIN
  if to_number(cspks_system.fn_get_sysvar('SYSTEM',v_keyRemain)) > p_RemainAmt then
            p_err_code:='-400110';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan con lai toi thieu da qua kenh Online');
    end;*/
  BEGIN
  if to_number(cspks_system.fn_get_sysvar('SYSTEM',v_keyMinAmt)) > (p_amount+l_feeamt+l_vatamt)  then
            p_err_code:='-100137';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi thieu qua kenh Online');
    end;
    BEGIN
   if v_isCHKONLINE = 'Y' AND to_number(cspks_system.fn_get_sysvar('SYSTEM',v_keyMaxAmt)) < (p_amount+l_feeamt+l_vatamt) + l_totalamt then
            p_err_code:='-100135';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi da qua kenh Online');
    end;
    --Kiem tra so lan chuyen khoan toi da
    BEGIN
        select count(1) into p_trfcount from tllog where tltxcd =v_keyTransferName and tlid =systemnums.C_ONLINE_USERID and deltd <> 'Y' and txstatus ='1' and msgacct = p_account;
        if to_number(cspks_system.fn_get_sysvar('SYSTEM',v_keyCNT)) <= p_trfcount then
            p_err_code:='-100136';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao so lan chuyen khoan toi da trong mot ngay qua kenh Online');
    end;
END IF;
 p_err_code:='0';
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_CheckCashTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CheckCashTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CheckCashTransfer;

 PROCEDURE pr_InternalTransfer(p_account varchar,
                            p_toaccount  varchar2,
                            p_amount number,
                            p_desc varchar2,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_recvcustodycd   varchar2(10);
      v_recvCUSTNAME    varchar2(200);
      v_recvLICENSE    varchar2(200);
      p_trfcount        number;
      p_totalamt        number;
      p_afamt           number;

      v_isCHKONLINE     varchar2(1);
      v_custodycd   varchar2(10);
      p_totalamt1120    number;
      L_STARTTIME number(10);
    L_ENDTIME number(10);
    L_CURRTIME number(10);
    v_holiday   varchar2(10);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_InternalTransfer');

    -- Lay thong tin khach hang
    SELECT CF.custodycd, CF.fullname, CF.idcode
    INTO v_recvcustodycd, v_recvCUSTNAME, v_recvLICENSE
    FROM CFMAST CF, AFMAST AF
    WHERE CF.custid = AF.custid AND AF.acctno = p_toaccount;

    SELECT CF.custodycd, onlinelimit, ischkonlimit
    INTO v_custodycd, p_afamt, v_isCHKONLINE
    FROM CFMAST CF, AFMAST AF
    WHERE CF.custid = AF.custid AND AF.acctno = p_account;

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_InternalTransfer');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    --BMSSUP-82 chan chuyen tien ngay nghi 03/11/2021
    select holiday INTO v_holiday from sbcldr where sbdate = trunc(sysdate) and cldrtype = '000';
    if v_holiday = 'Y' then
        p_err_code := '-100088';
        p_err_message := cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExternalTransfer');
        return;
    end if;
    --END BMSSUP-82 chan chuyen tien ngay nghi 03/11/2021

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTINTERNALTRF';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDINTERNALTRF';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 160000;
    END ;

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    if ( NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
        p_err_code := '-994461';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_AdvancePayment');
        return;
    end if;

    --Them buoc chan theo quy dinh chong rua tien
    --Doi voi giao dich qua kenh giao dich truc tuyen
    --Kiem tra so tien chuyen khoan toi da
    if(v_recvcustodycd <> v_custodycd) then
    begin
        if v_isCHKONLINE = 'Y' AND to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1120_AMT')) < p_amount then
            p_err_code:='-100135';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExternalTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi da qua kenh Online');
    end;
    --Kiem tra so lan chuyen khoan toi da
    begin
        select count(1) into p_trfcount from tllog where tltxcd ='1120' and tlid =systemnums.C_ONLINE_USERID and deltd <> 'Y' and txstatus ='1' and msgacct = p_account;

        if to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1120_CNT')) <= p_trfcount then
            p_err_code:='-100136';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExternalTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao so lan chuyen khoan toi da trong mot ngay qua kenh Online');
    end;
end if;
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1120';


    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

    begin
        if (v_recvcustodycd <> v_custodycd) then
            /*select sum(tl.msgamt) into p_totalamt1120
            from tllog tl, cfmast cf, afmast af, vw_citran_gen tr, CFMAST CF1, AFMAST AF1
            where tl.tltxcd = '1120' and tl.tlid =systemnums.C_ONLINE_USERID and tl.deltd <> 'Y'
                and tl.txnum = tr.txnum and tl.txdate = tr.txdate
                and tr.acctno = af.acctno and af.custid = cf.custid
                and cf.custodycd <> v_custodycd
                AND TR.field = 'BALANCE' AND TR.txtype = 'C'
                and tl.txstatus = '1' and tl.msgacct = AF1.ACCTNO AND AF1.CUSTID = CF1.CUSTID AND CF1.CUSTODYCD = v_custodycd;*/
            p_totalamt1120 := 0;  --- nvl(p_totalamt1120,0);
            select sum(tl.msgamt) into p_totalamt
            from tllog tl, CFMAST CF, AFMAST AF
            where tl.tltxcd = '1101' and tl.tlid =systemnums.C_ONLINE_USERID and tl.deltd <> 'Y'
                AND TL.msgacct = AF.acctno AND CF.CUSTID = AF.CUSTID AND CF.CUSTODYCD = v_custodycd
                and tl.txstatus = '1' ;
            p_totalamt := NVL(p_totalamt,0);

            if v_isCHKONLINE = 'N' and p_amount > nvl(p_afamt,0) - (p_totalamt+p_totalamt1120) then
                p_err_code:='-100131';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_ExternalTransfer');
                return;
            end if;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao gia tri chuyen khoan toi da trong mot ngay qua kenh Online');
    end;


    --p_txnum:=l_txmsg.txnum;
    --p_txdate:=l_txmsg.txdate;
    --Set cac field giao dich
    --03   DACCTNO     C
    l_txmsg.txfields ('03').defname   := 'DACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --05   CACCTNO     C
    l_txmsg.txfields ('05').defname   := 'CACCTNO';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_toaccount;
    --10   AMT         N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(p_amount,0);
    --14   BANKBALANCE             N
    l_txmsg.txfields ('14').defname   := 'BANKBALANCE';
    l_txmsg.txfields ('14').TYPE      := 'N';
    l_txmsg.txfields ('14').VALUE     := 0;
    --15   BANKAVLBAL             N
    l_txmsg.txfields ('15').defname   := 'BANKAVLBAL';
    l_txmsg.txfields ('15').TYPE      := 'N';
    l_txmsg.txfields ('15').VALUE     := 0;
    --30   DESC        C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := UTF8NUMS.c_const_TXDESC_1120_OL || p_desc;
    --31   FULLNAME            C
    l_txmsg.txfields ('31').defname   := 'FULLNAME';
    l_txmsg.txfields ('31').TYPE      := 'C';
    l_txmsg.txfields ('31').VALUE :='';
    --87   AVLCASH     N
    l_txmsg.txfields ('87').defname   := 'AVLCASH';
    l_txmsg.txfields ('87').TYPE      := 'N';
    l_txmsg.txfields ('87').VALUE     := 0;
    --88   CUSTODYCD   C
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE     := v_custodycd;
    --89   CUSTODYCD   C
    l_txmsg.txfields ('89').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('89').TYPE      := 'C';
    l_txmsg.txfields ('89').VALUE     := v_recvcustodycd;
    --90   CUSTNAME    C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE :='';
    --91   ADDRESS     C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE :='';
    --92   LICENSE     C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE :='';
    --93   CUSTNAME2   C
    l_txmsg.txfields ('93').defname   := 'CUSTNAME2';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE     := v_recvCUSTNAME;
    --94   ADDRESS2    C
    l_txmsg.txfields ('94').defname   := 'ADDRESS2';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE :='';
    --95   LICENSE2    C
    l_txmsg.txfields ('95').defname   := 'LICENSE2';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE     := v_recvLICENSE;
    --96   IDDATE      C
    l_txmsg.txfields ('96').defname   := 'IDDATE';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE :='';
    --97   IDPLACE     C
    l_txmsg.txfields ('97').defname   := 'IDPLACE';
    l_txmsg.txfields ('97').TYPE      := 'C';
    l_txmsg.txfields ('97').VALUE :='';
    --98   IDDATE2     C
    l_txmsg.txfields ('98').defname   := 'IDDATE2';
    l_txmsg.txfields ('98').TYPE      := 'C';
    l_txmsg.txfields ('98').VALUE :='';
    --99   IDPLACE2    C
    l_txmsg.txfields ('99').defname   := 'IDPLACE2';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE :='';
    --79   REFID    C
    l_txmsg.txfields ('79').defname   := 'REFID';
    l_txmsg.txfields ('79').TYPE      := 'C';
    l_txmsg.txfields ('79').VALUE :='';
       --50   REFID    C
    l_txmsg.txfields ('50').defname   := 'CUSTODYCD3';
    l_txmsg.txfields ('50').TYPE      := 'C';
    l_txmsg.txfields ('50').VALUE :='';
       --52   REFID    C
    l_txmsg.txfields ('52').defname   := 'FULLNAME3';
    l_txmsg.txfields ('52').TYPE      := 'C';
    l_txmsg.txfields ('52').VALUE :='';

        --54   REFID    C
    l_txmsg.txfields ('54').defname   := 'ADDRES3S';
    l_txmsg.txfields ('54').TYPE      := 'C';
    l_txmsg.txfields ('54').VALUE :='';
            --52   REFID    C
    l_txmsg.txfields ('55').defname   := 'LICENSE3';
    l_txmsg.txfields ('55').TYPE      := 'C';
    l_txmsg.txfields ('55').VALUE :='';
          --52   REFID    C
    l_txmsg.txfields ('56').defname   := 'IDDATE3';
    l_txmsg.txfields ('56').TYPE      := 'D';
    l_txmsg.txfields ('56').VALUE :='';
          --52   REFID    C
    l_txmsg.txfields ('57').defname   := 'IDPLACE3';
    l_txmsg.txfields ('57').TYPE      := 'C';
    l_txmsg.txfields ('57').VALUE :='';

           --52   REFID    C
    l_txmsg.txfields ('63').defname   := 'PHONE';
    l_txmsg.txfields ('63').TYPE      := 'C';
    l_txmsg.txfields ('63').VALUE :='';

    --35   DESC        C
    l_txmsg.txfields ('35').defname   := 'DESC';
    l_txmsg.txfields ('35').TYPE      := 'C';
    l_txmsg.txfields ('35').VALUE     := UTF8NUMS.c_const_TXDESC_1120_OL || p_desc;
    BEGIN
        IF txpks_#1120.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1120: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_InternalTransfer');
           RETURN;
        END IF;
    END;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_InternalTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_InternalTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_InternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_InternalTransfer;

---------------------------------pr_ExternalTransfer------------------------------------------------
  PROCEDURE pr_ExternalTransfer(p_account varchar,
                            p_bankid varchar2,
                            p_benefbank varchar2,
                            p_benefacct varchar2,
                            p_benefcustname varchar2,
                            p_beneflicense varchar2,
                            p_amount number,
                            p_feeamt number,
                            p_vatamt number,
                            p_iorofee number,
                            p_desc varchar2,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2,
                            --30/09/2022 Tho.Dinh Log thet bi
                            p_ipaddress VARCHAR2 DEFAULT '',
                            p_via VARCHAR2 DEFAULT '',
                            p_validationtype VARCHAR2 DEFAULT '',
                            p_devicetype VARCHAR2 DEFAULT '',
                            p_device VARCHAR2 DEFAULT '')
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_idcode varchar2(50);
      v_iddate  varchar2(20);
      v_idplace varchar2(200);
      v_citybank    varchar2(200);
      v_CITYEF      varchar2(200);
      v_custodycd   varchar2(200);
      v_fullname    varchar2(1000);
      p_trfcount    number; --So lan chuyen khoan trong ngay.
      p_totalamt    number; --tong gia tri chuyen khoan trong ngay.
      p_afamt       number; --han muc chuyen khoan trong ngay cua tieu khoan.
      v_isCHKONLINE varchar2(1);
      p_totalamt1120 number;
      v_bkacc       varchar2(50);
      v_count       number;
      l_custtype    varchar2(10);
      v_holiday     varchar2(10);
      v_refcursor      pkg_report.ref_cursor;
      l_input          VARCHAR2 (2500);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_ExternalTransfer');

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExternalTransfer');
        return;
    END IF;
    -- End: Check host 1 active or inactive
    --BMSSUP-82 chan chuyen tien ngay nghi 03/11/2021
    select holiday INTO v_holiday from sbcldr where sbdate = trunc(sysdate) and cldrtype = '000';
    if v_holiday = 'Y' then
        p_err_code := '-100088';
        p_err_message := cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExternalTransfer');
        return;
    end if;
    --END BMSSUP-82 chan chuyen tien ngay nghi 03/11/2021
    -- Lay thong tin khach hang
    SELECT CF.idcode, TO_CHAR(CF.iddate,'DD/MM/YYYY'), CF.idplace, cf.custodycd, cf.fullname, onlinelimit, ischkonlimit
    INTO v_idcode, v_iddate, v_idplace, v_custodycd, v_fullname , p_afamt, v_isCHKONLINE
    FROM CFMAST CF, AFMAST AF
    WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = p_account;
    -- Lay thong tin ngan hang

    SELECT count(1) into v_count
    FROM cfotheracc CFO, afmast af
    WHERE CFO.cfcustid = af.custid and AF.acctno = p_account AND CFO.bankacc = p_benefacct;
    if v_count>0 then
        SELECT max(CFO.citybank), max(CFO.cityef), max(CFO.bankcode)
        INTO v_citybank, v_CITYEF, v_bkacc
        FROM cfotheracc CFO, afmast af
        WHERE CFO.cfcustid = af.custid and AF.acctno = p_account AND CFO.bankacc = p_benefacct;
    else

        select ls.regional, ls.regional, ls.bankcode
        INTO v_citybank, v_CITYEF, v_bkacc
        from crbbanklist ls, crbbankmap map where ls.bankcode= map.bankcode and map.bankid= substr(p_benefacct,1,3);

    end if;

    /*SELECT max(bankcode) into v_bkacc FROM cfotheracc cfo, afmast af
    WHERE cfo.CFCUSTID = af.custid and af.acctno = p_account and bankacc = p_benefacct;*/

    --Them buoc chan theo quy dinh chong rua tien
    --Doi voi giao dich qua kenh giao dich truc tuyen
    --Kiem tra khach hang to chuc khong duoc chuyen khoan ra ngoai
    /*select cf.custtype into l_custtype from cfmast cf, afmast af
    where cf.custid = af.custid and af.acctno = p_account;
     if nvl(l_custtype,'I') = 'B' then
        p_err_code := '-200422'; --khach hang to chuc khong duoc thuc hien chuc nang nay.
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExternalTransfer');
        return;
    end if;*/
    --end Kiem tra khach hang to chuc khong duoc chuyen khoan ra ngoai
    --Kiem tra so lan chuyen khoan toi da
    begin
        select count(1) into p_trfcount from tllog where tltxcd ='1101' and tlid =systemnums.C_ONLINE_USERID and deltd <> 'Y' and txstatus ='1' and msgacct = p_account;

        if v_isCHKONLINE = 'Y' AND to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1101_CNT')) <= p_trfcount then
            p_err_code:='-100132';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExternalTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao so lan chuyen khoan toi da trong mot ngay qua kenh Online');
    end;

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1101';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

     begin
        p_afamt := nvl(p_afamt,0);
        v_isCHKONLINE := nvl(v_isCHKONLINE,'Y');

        /*select sum(tl.msgamt) into p_totalamt1120
        from tllog tl, cfmast cf, afmast af, vw_citran_gen tr, CFMAST CF1, AFMAST AF1
        where tl.tltxcd = '1120' and tl.tlid =systemnums.C_ONLINE_USERID and tl.deltd <> 'Y'
            and tl.txnum = tr.txnum and tl.txdate = tr.txdate
            and tr.acctno = af.acctno and af.custid = cf.custid
            and cf.custodycd <> v_custodycd
            AND TR.field = 'BALANCE' AND TR.txtype = 'C'
            and tl.txstatus = '1' and tl.msgacct = AF1.ACCTNO AND CF1.CUSTID = AF1.CUSTID AND CF1.CUSTODYCD = v_custodycd;*/
        p_totalamt1120 := 0 ; ---nvl(p_totalamt1120,0);
        select sum(tl.msgamt) into p_totalamt
        from tllog tl, CFMAST CF, AFMAST AF
        where tl.tltxcd = '1101' and tl.tlid = systemnums.C_ONLINE_USERID and tl.deltd <> 'Y'
            and tl.txstatus = '1' and tl.msgacct = AF.ACCTNO AND AF.CUSTID = CF.CUSTID AND CF.CUSTODYCD = v_custodycd;
        p_totalamt := NVL(p_totalamt,0);

        if v_isCHKONLINE = 'N' and p_amount > nvl(p_afamt,0) - (p_totalamt+p_totalamt1120) then
            p_err_code:='-100131';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExternalTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao gia tri chuyen khoan toi da trong mot ngay qua kenh Online');
    end;

    --Kiem tra so tien chuyen khoan toi da
    begin
        if v_isCHKONLINE = 'Y' AND to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1101_AMT')) < p_amount+p_totalamt+p_totalamt1120 then
            p_err_code:='-100131';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExternalTransfer');
            return;
        end if;
    exception when others then
        plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi da qua kenh Online');
    end;

  --p_txnum:=l_txmsg.txnum;
  --p_txdate:=l_txmsg.txdate;
  --Set cac field giao dich
    --03   ACCTNO          C
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --05   BANKID          C
    l_txmsg.txfields ('05').defname   := 'BANKID';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := v_bkacc;
    --09   IORO            C
    l_txmsg.txfields ('09').defname   := 'IORO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     := p_iorofee;
    --10   TRFAMT          N
    l_txmsg.txfields ('10').defname   := 'TRFAMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(p_amount,0)-(round(p_feeamt,0) + round(p_vatamt,0)) * p_iorofee;
    --11   FEEAMT          N
    l_txmsg.txfields ('11').defname   := 'FEEAMT';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := round(p_feeamt,0);
    --12   VATAMT          N
    l_txmsg.txfields ('12').defname   := 'VATAMT';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := round(p_vatamt,0);
    --13   AMT             N
    l_txmsg.txfields ('13').defname   := 'AMT';
    l_txmsg.txfields ('13').TYPE      := 'N';
    l_txmsg.txfields ('13').VALUE     := round(p_amount,0);
    --14   BANKBALANCE             N
    l_txmsg.txfields ('14').defname   := 'BANKBALANCE';
    l_txmsg.txfields ('14').TYPE      := 'N';
    l_txmsg.txfields ('14').VALUE     := 0;
    --15   BANKAVLBAL             N
    l_txmsg.txfields ('15').defname   := 'BANKAVLBAL';
    l_txmsg.txfields ('15').TYPE      := 'N';
    l_txmsg.txfields ('15').VALUE     := 0;
    --30   DESC            C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := UTF8NUMS.c_const_TXDESC_1101_OL || '/ ' || v_fullname || '/ ' || v_custodycd;

    --64   FULLNAME        C
    l_txmsg.txfields ('64').defname   := 'FULLNAME';
    l_txmsg.txfields ('64').TYPE      := 'C';
    l_txmsg.txfields ('64').VALUE     := v_fullname;
    --65   ADDRESS        C
    l_txmsg.txfields ('65').defname   := 'ADDRESS';
    l_txmsg.txfields ('65').TYPE      := 'C';
    l_txmsg.txfields ('65').VALUE :='';
    --67   IDDATE        C
    l_txmsg.txfields ('67').defname   := 'IDDATE';
    l_txmsg.txfields ('67').TYPE      := 'C';
    l_txmsg.txfields ('67').VALUE     := v_iddate;
    --68   IDPLACE        C
    l_txmsg.txfields ('68').defname   := 'IDPLACE';
    l_txmsg.txfields ('68').TYPE      := 'C';
    l_txmsg.txfields ('68').VALUE     := v_idplace;
    --69   LICENSE        C
    l_txmsg.txfields ('69').defname   := 'LICENSE';
    l_txmsg.txfields ('69').TYPE      := 'C';
    l_txmsg.txfields ('69').VALUE     := v_idcode;
    --80   BENEFBANK       C --Ten ngan hang thu huong
    l_txmsg.txfields ('80').defname   := 'BENEFBANK';
    l_txmsg.txfields ('80').TYPE      := 'C';
    l_txmsg.txfields ('80').VALUE :=p_benefbank;
    --81   BENEFACCT       C --So tai khoan thu huong
    l_txmsg.txfields ('81').defname   := 'BENEFACCT';
    l_txmsg.txfields ('81').TYPE      := 'C';
    l_txmsg.txfields ('81').VALUE :=p_benefacct;
    --82   BENEFCUSTNAME   C
    l_txmsg.txfields ('82').defname   := 'BENEFCUSTNAME';
    l_txmsg.txfields ('82').TYPE      := 'C';
    l_txmsg.txfields ('82').VALUE :=p_benefcustname;
    --83   BENEFLICENSE    C
    l_txmsg.txfields ('83').defname   := 'BENEFLICENSE';
    l_txmsg.txfields ('83').TYPE      := 'C';
    l_txmsg.txfields ('83').VALUE :=p_beneflicense;
    --84   CITYBANK    C
    l_txmsg.txfields ('84').defname   := 'CITYBANK';
    l_txmsg.txfields ('84').TYPE      := 'C';
    l_txmsg.txfields ('84').VALUE     := v_citybank;
    --85   CITYEF    C
    l_txmsg.txfields ('85').defname   := 'CITYEF';
    l_txmsg.txfields ('85').TYPE      := 'C';
    l_txmsg.txfields ('85').VALUE     := v_CITYEF;
    --88   CUSTODYCD   C
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE      := v_custodycd;
    --89   AVLCASH         N
    l_txmsg.txfields ('89').defname   := 'AVLCASH';
    l_txmsg.txfields ('89').TYPE      := 'N';
    l_txmsg.txfields ('89').VALUE :=0;
    --90   CUSTNAME        C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     :=  v_fullname;
    /*--91   ADDRESS         C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE :='';
    --92   LICENSE         C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE :='';
    --93   IDDATE          C
    l_txmsg.txfields ('93').defname   := 'IDDATE';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE :='';
    --94   IDPLACE         C
    l_txmsg.txfields ('94').defname   := 'IDPLACE';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE :='';*/
    --95   BENEFIDDATE     C
    l_txmsg.txfields ('95').defname   := 'BENEFIDDATE';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE :='';
    --96   BENEFIDPLACE    C
    l_txmsg.txfields ('96').defname   := 'BENEFIDPLACE';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE :='';
    /*--97   LICENSE    C
    l_txmsg.txfields ('97').defname   := 'LICENSE';
    l_txmsg.txfields ('97').TYPE      := 'C';
    l_txmsg.txfields ('97').VALUE :='';
    --98   IDDATE    C
    l_txmsg.txfields ('98').defname   := 'IDDATE';
    l_txmsg.txfields ('98').TYPE      := 'C';
    l_txmsg.txfields ('98').VALUE :='';
    --99   IDPLACE    C
    l_txmsg.txfields ('99').defname   := 'IDPLACE';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE :='';*/
    --66   FEECD    C
    l_txmsg.txfields ('66').defname   := '$FEECD';
    l_txmsg.txfields ('66').TYPE      := 'C';
    l_txmsg.txfields ('66').VALUE :='';
    --79   REFID    C
    l_txmsg.txfields ('79').defname   := 'REFID';
    l_txmsg.txfields ('79').TYPE      := 'C';
    l_txmsg.txfields ('79').VALUE :='';
    --00   AUTOID    C
    l_txmsg.txfields ('00').defname   := 'AUTOID';
    l_txmsg.txfields ('00').TYPE      := 'C';
    l_txmsg.txfields ('00').VALUE     :='';

    BEGIN
        IF txpks_#1101.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1101: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_ExternalTransfer');
           RETURN;
        END IF;
    END;

    l_input := FN_GETINPUT (v_refcursor);
    pr_insertiplog (l_txmsg.txnum,
                    l_txmsg.txdate,
                    p_ipaddress,
                    p_via,
                    p_validationtype,
                    p_devicetype,
                    p_device,
                    NULL,
                    l_input);
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_ExternalTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error(pkgctx,'got error on pr_ExternalTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.error(pkgctx,'got error on pr_ExternalTransfer'||dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_ExternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ExternalTransfer;

---------------------------------pr_InternalTransfer------------------------------------------------
  PROCEDURE pr_RevertTransfer(p_tltxcd IN VARCHAR2,
                            p_txdate IN  varchar2,
                            p_txnum IN  VARCHAR2,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2)
  IS
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_RevertTransfer');

    BEGIN
        IF p_tltxcd = '1120' THEN
            IF txpks_#1120.fn_txrevert(p_txnum, p_txdate, p_err_code, l_err_param) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1120 revert: ' || p_err_code
               );
               ROLLBACK;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, 'Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_placeorder');
               RETURN;
            END IF;
        ELSE
            IF txpks_#1101.fn_txrevert(p_txnum, p_txdate, p_err_code, l_err_param) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1101 revert: ' || p_err_code
               );
               ROLLBACK;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, 'Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_placeorder');
               RETURN;
            END IF;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_InternalTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_InternalTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_InternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RevertTransfer;

---------------------------------pr_RightoffRegiter------------------------------------------------
PROCEDURE pr_RightoffRegiter
    (p_camastid IN   varchar,
    p_account   IN   varchar,
    p_qtty      IN   number,
    P_AMOUNT    IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2,
    --30/09/2022 Tho.Dinh log thong  tin thiet bi
    p_ipaddress        IN     VARCHAR2 DEFAULT '',
    p_via              IN     VARCHAR2 DEFAULT '',
    p_validationtype   IN     VARCHAR2 DEFAULT '',
    p_devicetype       IN     VARCHAR2 DEFAULT '',
    p_device           IN     VARCHAR2 DEFAULT '')
    IS
        l_exprice number;
        l_iscorebank  varchar(1);
        l_maxqtty NUMBER;
        l_camastid      varchar2(50);
        l_RGAmount  NUMBER;
        l_REQUESTID varchar2(50);
        l_RQLogAutoID   NUMBER;
        L_STARTTIME number(10);
        L_ENDTIME number(10);
        L_CURRTIME number(10);
        v_refcursor     pkg_report.ref_cursor;
        l_input         VARCHAR2 (2500);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_RightoffRegiter');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_RightoffRegiter');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTRIGHTOFF';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDRIGHTOFF';
        EXCEPTION WHEN OTHERS THEN
            L_STARTTIME := 80000;
            L_ENDTIME := 160000;
        END ;

        SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
        FROM DUAL;

        if ( NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
            p_err_code := '-994461';
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AdvancePayment');
            return;
        end if;

        -- Lay thong tin tieu khoan va dot thuc hien quyen
        SELECT A.exprice, A.pqtty - NVL(RQ.MSGQTTY,0), A.corebank, A.camastid
        INTO  l_exprice, l_maxqtty, l_iscorebank, l_camastid
        FROM
            (select CA.AFACCTNO, CA.camastid,a.exprice,ca.pqtty,af.corebank
                from camast a, caschd ca, afmast af
                where ca.camastid=a.camastid
                    AND af.acctno = ca.afacctno
                    and ca.afacctno=p_account
                    AND ca.camastid = p_camastid
                    and ca.deltd <> 'Y'
            ) A
            LEFT JOIN
            (
                SELECT msgacct, keyvalue, sum(NVL(MSGQTTY,0)) MSGQTTY FROM borqslog
                WHERE RQSTYP = 'CAR' AND STATUS IN ('W','P','H') AND KEYVALUE = p_camastid
                GROUP BY msgacct, keyvalue
            ) RQ
            ON A.camastid = RQ.keyvalue AND A.afacctno = RQ.msgacct ;

        --plog.debug(pkgctx, 'l_maxqtty:'  || l_maxqtty);

        -- Kiem tra so luong dang ky quyen mua co vuot qua so dang ky toi da hay ko
        IF l_maxqtty < p_qtty THEN
            p_err_code := -300021; -- Vuot qua so CK duoc phep mua
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_RightoffRegiter');
            return;
        END IF;

        l_RGAmount := p_qtty * l_exprice;

        -- GHI NHAN VAO BANG BORQSLOG DE XU LY
        SELECT 'CAR' || replace(replace(replace(to_char(SYSDATE,'RRRR-MM-DD HH24:MI:SS'),'-',''),':',''),' ','') INTO l_REQUESTID FROM dual;
        SELECT SEQ_BORQSLOG.NEXTVAL INTO l_RQLogAutoID FROM dual;
        INSERT INTO BORQSLOG (AUTOID, CREATEDDT, RQSSRC, RQSTYP, REQUESTID, STATUS, TXDATE,
            TXNUM, ERRNUM, ERRMSG,MSGACCT,MSGAMT,DESCRIPTION,KEYVALUE,MSGQTTY)
        SELECT l_RQLogAutoID, SYSDATE, 'ONL' RQSSRC, 'CAR' RQSTYP, l_REQUESTID REQUESTID, /*decode(l_iscorebank,'Y','W','P')*/ 'P' STATUS, getcurrdate TXDATE,
            '' TXNUM, 0 ERRNUM, '' ERRMSG, p_account  MSGACCT, l_RGAmount MSGAMT, p_desc, l_camastid, p_qtty
        FROM DUAL;

        COMMIT;

        -- Neu ko ket noi NH thi thuc hien GD dang ky quyen mua ngay
        /*IF l_iscorebank = 'N' THEN
            pr_ROR2BO(l_RQLogAutoID, p_err_code, p_err_message);
            IF p_err_code <> systemnums.C_SUCCESS THEN
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_RightoffRegiter');
                return;
            END IF;
        END IF;*/
        pr_ROR2BO(l_RQLogAutoID, p_err_code, p_err_message);
        IF p_err_code <> systemnums.C_SUCCESS THEN
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_RightoffRegiter');
            return;
        END IF;

        BEGIN
         OPEN v_refcursor FOR
            SELECT p_account accountid,
                   p_camastid camastid,
                   p_qtty qtty,
                   p_desc description,
                   p_ipaddress ipaddress,
                   p_via via,
                   p_validationtype validationtype,
                   p_devicetype devicetype,
                   p_device device
              FROM DUAL;

         l_input := FN_GETINPUT (v_refcursor);
         pr_insertiplog (p_camastid,
                         getcurrdate,
                         p_ipaddress,
                         p_via,
                         p_validationtype,
                         p_devicetype,
                         p_device,
                         NULL,
                         l_input);
      EXCEPTION
         WHEN OTHERS
         THEN
            plog.error (
               pkgctx,
               SQLERRM || ' AT ' || DBMS_UTILITY.format_error_backtrace);
      END;

        p_err_code:=systemnums.C_SUCCESS;
        plog.setendsection(pkgctx, 'pr_RightoffRegiter');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_RightoffRegiter');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RightoffRegiter');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RightoffRegiter;


PROCEDURE pr_RORSyn2BO
    IS
        v_err_code      NUMBER;
        v_err_message   varchar2(2000);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_RORSyn2BO');
        v_err_code := 0;

       -- Lay len danh sach cac lenh dang ky quyen mua da thuc hien hold du tien de thuc hien GD 3384
        FOR rec IN
        (
            SELECT RQ.AUTOID, RQ.MSGACCT,RQ.MSGAMT,RQ.DESCRIPTION,RQ.KEYVALUE,RQ.MSGQTTY
            FROM borqslog RQ
            WHERE RQ.STATUS IN ('P','H') AND RQ.RQSTYP = 'CAR'
            ORDER BY RQ.AUTOID
        )
        LOOP
            pr_RightoffRegiter2BO(rec.KEYVALUE, rec.MSGACCT, rec.MSGQTTY, rec.DESCRIPTION, v_err_code, v_err_message);
            IF v_err_code = systemnums.C_SUCCESS THEN
                -- CAP NHAT TRANG THAI TRONG BORQSLOG
                UPDATE borqslog SET
                    STATUS = 'A'
                WHERE AUTOID = rec.AUTOID;
                COMMIT;
            ELSE
                plog.error(pkgctx, 'Error: '  || v_err_code || v_err_message);
                plog.setendsection(pkgctx, 'pr_RORSyn2BO');
            END IF;
        END LOOP;
        plog.setendsection(pkgctx, 'pr_RORSyn2BO');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_RORSyn2BO');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RORSyn2BO');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RORSyn2BO;


PROCEDURE pr_RORSynBank2BO
    (
    p_RQLogID   IN   NUMBER
    )
    IS
        v_err_code      NUMBER;
        v_err_message   varchar2(2000);
        v_afacctno      varchar2(10);
        v_amount        NUMBER;
        v_desc          varchar2(2000);
        v_camastid      varchar2(50);
        v_qtty          NUMBER;

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_RORSynBank2BO');
        v_err_code := 0;

        plog.debug(pkgctx, 'BEGIN pr_RORSynBank2BO');
        plog.debug(pkgctx, 'p_RQLogID: ' || p_RQLogID);

        -- Lay len danh sach cac lenh dang ky quyen mua da thuc hien hold du tien de thuc hien GD 3384

        SELECT RQ.MSGACCT,RQ.MSGAMT,RQ.DESCRIPTION,RQ.KEYVALUE,RQ.MSGQTTY
        INTO v_afacctno, v_amount, v_desc, v_camastid, v_qtty
        FROM borqslog RQ
        WHERE RQ.STATUS = 'W' AND RQ.RQSTYP = 'CAR' AND RQ.AUTOID = p_RQLogID;

        plog.debug(pkgctx, v_afacctno || ' | ' || v_amount|| ' | ' || v_desc || ' | ' || v_camastid || ' | ' || v_qtty);

        pr_RightoffRegiter2BO(v_camastid, v_afacctno, v_qtty, v_desc, v_err_code, v_err_message);
        IF v_err_code = systemnums.C_SUCCESS THEN
            -- CAP NHAT TRANG THAI TRONG BORQSLOG
            UPDATE borqslog SET
                STATUS = 'A'
            WHERE AUTOID = p_RQLogID;
            COMMIT;
        ELSE
            -- CAP NHAT TRANG THAI TRONG BORQSLOG
            UPDATE borqslog SET
                STATUS = 'R'
            WHERE AUTOID = p_RQLogID;
            COMMIT;
            plog.error(pkgctx, 'Error: '  || v_err_code || v_err_message);
            plog.setendsection(pkgctx, 'pr_RORSynBank2BO');
        END IF;
        plog.setendsection(pkgctx, 'pr_RORSynBank2BO');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_RORSynBank2BO');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RORSynBank2BO');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RORSynBank2BO;

PROCEDURE pr_ROR2BO
    (
    p_RQLogID   IN   NUMBER,
    p_err_code  OUT  NUMBER,
    p_err_message   OUT  varchar2
    )
    IS
        v_afacctno      varchar2(10);
        v_amount        NUMBER;
        v_desc          varchar2(2000);
        v_camastid      varchar2(50);
        v_qtty          NUMBER;

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_ROR2BO');
        p_err_code := 0;

        plog.debug(pkgctx, 'BEGIN pr_ROR2BO');
        plog.debug(pkgctx, 'p_RQLogID: ' || p_RQLogID);

        -- Lay len danh sach cac lenh dang ky quyen mua da thuc hien hold du tien de thuc hien GD 3384

        SELECT RQ.MSGACCT,RQ.MSGAMT,RQ.DESCRIPTION,RQ.KEYVALUE,RQ.MSGQTTY
        INTO v_afacctno, v_amount, v_desc, v_camastid, v_qtty
        FROM borqslog RQ
        WHERE RQ.STATUS = 'P' AND RQ.RQSTYP = 'CAR' AND RQ.AUTOID = p_RQLogID;

        plog.debug(pkgctx, v_afacctno || ' | ' || v_amount|| ' | ' || v_desc || ' | ' || v_camastid || ' | ' || v_qtty);

        pr_RightoffRegiter2BO(v_camastid, v_afacctno, v_qtty, v_desc, p_err_code, p_err_message);
        IF p_err_code = systemnums.C_SUCCESS THEN
            -- CAP NHAT TRANG THAI TRONG BORQSLOG
            UPDATE borqslog SET
                STATUS = 'A'
            WHERE AUTOID = p_RQLogID;
            COMMIT;
        ELSE
            -- CAP NHAT TRANG THAI TRONG BORQSLOG
            UPDATE borqslog SET
                STATUS = 'R'
            WHERE AUTOID = p_RQLogID;
            COMMIT;
            plog.error(pkgctx, 'Error: '  || p_err_code || p_err_message);
            plog.setendsection(pkgctx, 'pr_ROR2BO');
        END IF;
        plog.setendsection(pkgctx, 'pr_ROR2BO');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_ROR2BO');
      ROLLBACK;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ROR2BO');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ROR2BO;


PROCEDURE pr_RightoffRegiter2BO
    (p_camastid IN   varchar,
    p_account   IN   varchar,
    p_qtty      IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
    )
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      l_symbol  varchar2(20);
      l_tocodeid   varchar2(20);
      l_exprice number;
      l_optcodeid varchar2(20);
      l_iscorebank  number;
      l_bankacctno varchar2(100);
      l_bankname varchar2(100);
      l_balance number;
      l_caschdautoid NUMBER;
      l_maxqtty NUMBER;
      l_parvalue NUMBER;
      l_cashbalance NUMBER;
      l_sebalance   NUMBER;
      l_fullname    varchar2(100);
      l_idcode      varchar2(20);
      l_iddate      varchar2(20);
      l_idplace     varchar2(200);
      l_reportdate  varchar2(20);
      l_custodycd   varchar2(10);
      l_phone       varchar2(50);
      l_avlqtty     number;
      l_buyqtty     number;
      l_isalloc     NUMBER(10);
      l_begindate   varchar(20);
      l_duedate     varchar(20);
      l_custtype    varchar(10);
l_ptrade       number;
      l_pblock       number;
      l_qtty        number;
      l_pcodeid     varchar2(50);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_RightoffRegiter2BO');

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_RightoffRegiter2BO');
        return;
    END IF;
    -- End: Check host 1 active or inactive


    select cf.custtype into l_custtype from cfmast cf, afmast af
    where cf.custid = af.custid and af.acctno = p_account;

    if nvl(l_custtype,'I') = 'B' then
        p_err_code := '-200422'; --khach hang to chuc khong duoc thuc hien chuc nang nay.
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_CheckCashTransfer');
        return;
    end if;

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3384';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

    --p_txnum:=l_txmsg.txnum;
    --p_txdate:=l_txmsg.txdate;

    select ca.autoid, b.SYMBOL,a.exprice,decode(a.iswft,'Y',nvl(b2.codeid,'000000'),nvl(a.tocodeid,a.codeid)) codeid,optcodeid,CA.balance + CA.pbalance balance, ca.pqtty,a.parvalue,
        (case when ci.corebank ='Y' then 0 else 1 end) iscorebank,af.bankacctno,af.bankname, ci.balance, ca.trade, cf.fullname, cf.idcode,
        to_char(cf.iddate,'DD/MM/YYYY') iddate, cf.idplace, to_char(a.reportdate,'DD/MM/YYYY') reportdate,
        cf.custodycd, cf.phone, CA.PQTTY AVLQTTY, CA.QTTY SUQTTY, (CASE WHEN  nvl(a.isalloc,'Y') = 'Y' THEN 1 ELSE 0 END),
        a.begindate, a.duedate
    into l_caschdautoid,l_symbol,l_exprice , l_tocodeid,l_optcodeid,l_balance,l_maxqtty, l_parvalue,l_iscorebank,
      l_bankacctno,l_bankname,
        l_cashbalance, l_sebalance, l_fullname, l_idcode , l_iddate, l_idplace, l_reportdate, l_custodycd, l_phone,
        l_avlqtty, l_buyqtty, l_isalloc, l_begindate, l_duedate
    from camast a, caschd ca, sbsecurities b,cimast ci, cfmast cf, afmast af, sbsecurities b2
    where a.tocodeid = b.codeid and a.camastid=p_camastid and ca.camastid=a.camastid
        AND cf.custid = af.custid AND af.acctno = ca.afacctno
        and ca.afacctno=p_account
        and ci.acctno=ca.afacctno
        and ca.deltd <> 'Y'
        and nvl(a.tocodeid,a.codeid) = b2.refcodeid (+);

 select codeid into l_pcodeid from sbsecurities where symbol = l_symbol;

    l_ptrade:=fn_get_ptrade(p_camastid,l_pcodeid,p_account);
    l_pblock:=fn_get_pblocked(p_camastid,l_pcodeid,p_account);

    if l_ptrade = -1 and l_pblock = -1 then
        l_qtty:=p_qtty;
        l_ptrade:=0;
        l_pblock:=0;
    else
        if p_qtty > (l_ptrade+l_pblock) then
           l_qtty:=l_ptrade;
           auto_call_txpks_3384(p_camastid,p_account,p_qtty-l_ptrade,p_desc,p_err_code,p_err_message);
        ELSE
            if p_qtty > l_ptrade then
                l_qtty:=l_ptrade;
                auto_call_txpks_3384(p_camastid,p_account,p_qtty-l_ptrade,p_desc,p_err_code,p_err_message);
            else
                l_qtty:=p_qtty;
            end if;
        end if;
    end if;

    --Set cac field giao dich
    --01   AUTOID      C
    l_txmsg.txfields ('01').defname   := 'AUTOID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := to_char(nvl(l_caschdautoid,''));
    --02   CAMASTID      C
    l_txmsg.txfields ('02').defname   := 'CAMASTID';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := p_camastid;
    --03   AFACCTNO      C
    l_txmsg.txfields ('03').defname   := 'AFACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --04   SYMBOL        C
    l_txmsg.txfields ('04').defname   := 'SYMBOL';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := l_symbol;
    --05   EXPRICE       N
    l_txmsg.txfields ('05').defname   := 'EXPRICE';
    l_txmsg.txfields ('05').TYPE      := 'N';
    l_txmsg.txfields ('05').VALUE     := l_exprice;
    --06   SEACCTNO      C
    l_txmsg.txfields ('06').defname   := 'SEACCTNO';
    l_txmsg.txfields ('06').TYPE      := 'C';
    l_txmsg.txfields ('06').VALUE     := p_account || l_tocodeid;
    --07   SE BALANCE       N
    l_txmsg.txfields ('07').defname   := 'BALANCE';
    l_txmsg.txfields ('07').TYPE      := 'N';
    l_txmsg.txfields ('07').VALUE     := l_sebalance;
    --08   FULLNAME      C
    l_txmsg.txfields ('08').defname   := 'FULLNAME';
    l_txmsg.txfields ('08').TYPE      := 'C';
    l_txmsg.txfields ('08').VALUE     := l_fullname;
    --09   OPTSEACCTNO   C
    l_txmsg.txfields ('09').defname   := 'OPTSEACCTNO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     := p_account || l_optcodeid;
    --10   AMT          N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(nvl(p_qtty,0) * nvl(l_exprice,0),0);
    --11   CI BALANCE          N
    l_txmsg.txfields ('11').defname   := 'CIBALANCE';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := l_cashbalance;
    --12   CI BALANCE          N
    l_txmsg.txfields ('12').defname   := 'BALANCE';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := l_cashbalance;
    --16   TASKCD        C
    l_txmsg.txfields ('16').defname   := 'TASKCD';
    l_txmsg.txfields ('16').TYPE      := 'C';
    l_txmsg.txfields ('16').VALUE     := '';
    --18   BEGINDATE        C
    l_txmsg.txfields ('18').defname   := 'BEGINDATE';
    l_txmsg.txfields ('18').TYPE      := 'C';
    l_txmsg.txfields ('18').VALUE     := l_begindate;
    --19   DUEDATE        C
    l_txmsg.txfields ('19').defname   := 'DUEDATE';
    l_txmsg.txfields ('19').TYPE      := 'C';
    l_txmsg.txfields ('19').VALUE     := l_duedate;
    --20   MAXQTTY          N
    l_txmsg.txfields ('20').defname   := 'MAXQTTY';
    l_txmsg.txfields ('20').TYPE      := 'N';
    l_txmsg.txfields ('20').VALUE     := l_maxqtty;
    --21   QTTY          N
    l_txmsg.txfields ('21').defname   := 'QTTY';
    l_txmsg.txfields ('21').TYPE      := 'N';
    l_txmsg.txfields ('21').VALUE     := l_qtty;
    --22   PARVALUE          N
    l_txmsg.txfields ('22').defname   := 'PARVALUE';
    l_txmsg.txfields ('22').TYPE      := 'N';
    l_txmsg.txfields ('22').VALUE     := l_parvalue;
    --23   REPORTDATE          N
    l_txmsg.txfields ('23').defname   := 'REPORTDATE';
    l_txmsg.txfields ('23').TYPE      := 'C';
    l_txmsg.txfields ('23').VALUE     := l_reportdate;
    --24   CODEID          C
    l_txmsg.txfields ('24').defname   := 'CODEID';
    l_txmsg.txfields ('24').TYPE      := 'C';
    l_txmsg.txfields ('24').VALUE     := l_pcodeid;
    --25   AVLQTTY          N
    l_txmsg.txfields ('25').defname   := 'AVLQTTY';
    l_txmsg.txfields ('25').TYPE      := 'N';
    l_txmsg.txfields ('25').VALUE     := l_avlqtty;
    --26   BUYQTTY          N
    l_txmsg.txfields ('26').defname   := 'BUYQTTY';
    l_txmsg.txfields ('26').TYPE      := 'N';
    l_txmsg.txfields ('26').VALUE     := l_buyqtty;
    --30   DESCRIPTION   C
    l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := p_desc;
    --40   STATUS        C
    l_txmsg.txfields ('40').defname   := 'STATUS';
    l_txmsg.txfields ('40').TYPE      := 'C';
    l_txmsg.txfields ('40').VALUE     := 'M';
    --60   ISCOREBANK        N
    l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
    l_txmsg.txfields ('60').TYPE      := 'N';
    l_txmsg.txfields ('60').VALUE     := l_iscorebank;
    --61   BANKACCTNO        C
    l_txmsg.txfields ('61').defname   := 'BANKACCTNO';
    l_txmsg.txfields ('61').TYPE      := 'C';
    l_txmsg.txfields ('61').VALUE     := l_bankacctno;
    --62   BANKNAME        C
    l_txmsg.txfields ('62').defname   := 'BANKNAME';
    l_txmsg.txfields ('62').TYPE      := 'C';
    l_txmsg.txfields ('62').VALUE     := l_bankname;
    --70   PHONE    C
    l_txmsg.txfields ('70').defname   := 'PHONE';
    l_txmsg.txfields ('70').TYPE      := 'C';
    l_txmsg.txfields ('70').VALUE     := l_phone;
    --71   SYMBOL_ORG    C
    l_txmsg.txfields ('71').defname   := 'SYMBOL_ORG';
    l_txmsg.txfields ('71').TYPE      := 'C';
    l_txmsg.txfields ('71').VALUE     := l_optcodeid;
    --90   CUSTNAME    C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     := l_fullname;
    --91   ADDRESS     C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE     := '';
    --92   LICENSE     C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE     := l_idcode;
    --93   IDDATE    C
    l_txmsg.txfields ('93').defname   := 'IDDATE';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE     := l_iddate;
    --94   IDPLACE    C
    l_txmsg.txfields ('94').defname   := 'IDPLACE';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE     := l_idplace;
    --95   ISSNAME    C
    l_txmsg.txfields ('95').defname   := 'ISSNAME';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE     :='';
    --96   CUSTODYCD    C
    l_txmsg.txfields ('96').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE     := l_custodycd;
    --65   ISALLOC    N
    l_txmsg.txfields ('65').defname   := 'ALLOC';
    l_txmsg.txfields ('65').TYPE      := 'N';
    l_txmsg.txfields ('65').VALUE     := l_isalloc;
  --VuTN them moi de di dien, phan biet quyen cua tung loai ck
    /*--50    SL CK GD ? ?ua t?i ? N
     l_txmsg.txfields ('50').defname   := 'TRADE';
     l_txmsg.txfields ('50').TYPE      := 'N';
     l_txmsg.txfields ('50').value      := l_ptrade;
    --51    SL CK GD ? k? mua   N
     l_txmsg.txfields ('51').defname   := 'OUTPTRADE';
     l_txmsg.txfields ('51').TYPE      := 'N';
     l_txmsg.txfields ('51').value      := l_qtty;
    --52    SL CK HCCN ? ?ua t?i ? N
     l_txmsg.txfields ('52').defname   := 'PBLOCKED';
     l_txmsg.txfields ('52').TYPE      := 'N';
     l_txmsg.txfields ('52').value      := l_pblock;
    --53    SL CK HCCN ? k? mua   N
     l_txmsg.txfields ('53').defname   := 'OUTPBLOCKED';
     l_txmsg.txfields ('53').TYPE      := 'N';
     l_txmsg.txfields ('53').value      := 0;*/

    BEGIN
        if l_qtty > 0 then
        IF txpks_#3384.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 3384: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_RightoffRegiter2BO');
           RETURN;
        END IF;
end if;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_RightoffRegiter2BO');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_RightoffRegiter2BO');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RightoffRegiter2BO');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RightoffRegiter2BO;


PROCEDURE auto_call_txpks_3384
    (p_camastid IN   varchar,
    p_account   IN   varchar,
    p_qtty      IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
    )
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      l_symbol  varchar2(20);
      l_tocodeid   varchar2(20);
      l_exprice number;
      l_optcodeid varchar2(20);
      l_iscorebank  number;
      l_bankacctno varchar2(100);
      l_bankname varchar2(100);
      l_balance number;
      l_caschdautoid NUMBER;
      l_maxqtty NUMBER;
      l_parvalue NUMBER;
      l_cashbalance NUMBER;
      l_sebalance   NUMBER;
      l_fullname    varchar2(100);
      l_idcode      varchar2(20);
      l_iddate      varchar2(20);
      l_idplace     varchar2(200);
      l_reportdate  varchar2(20);
      l_custodycd   varchar2(10);
      l_phone       varchar2(50);
      l_avlqtty     number;
      l_buyqtty     number;
      l_isalloc     NUMBER(10);
      l_begindate   varchar(20);
      l_duedate     varchar(20);
      l_custtype    varchar(10);
      l_ptrade       number;
      l_pblock       number;
      l_pcodeid     varchar2(50);
  BEGIN
    plog.setbeginsection(pkgctx, 'auto_call_txpks_3384');

    -- Check host branch active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'auto_call_txpks_3384');
        return;
    END IF;
    -- End: Check host branch active or inactive

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3384';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

    --p_txnum:=l_txmsg.txnum;
    --p_txdate:=l_txmsg.txdate;

    select ca.autoid, b.SYMBOL,a.exprice,decode(a.iswft,'Y',nvl(b2.codeid,'000000'),nvl(a.tocodeid,a.codeid)) codeid,optcodeid,CA.balance + CA.pbalance balance, ca.pqtty,a.parvalue,
        (case when ci.corebank ='Y' then 0 else 1 end) iscorebank,af.bankacctno,af.bankname, ci.balance, ca.trade, cf.fullname, cf.idcode,
        to_char(cf.iddate,'DD/MM/YYYY') iddate, cf.idplace, to_char(a.reportdate,'DD/MM/YYYY') reportdate,
        cf.custodycd, cf.phone, CA.PQTTY AVLQTTY, CA.QTTY SUQTTY, (CASE WHEN  nvl(a.isalloc,'Y') = 'Y' THEN 1 ELSE 0 END),
        a.begindate, a.duedate
    into l_caschdautoid,l_symbol,l_exprice , l_tocodeid,l_optcodeid,l_balance,l_maxqtty, l_parvalue,l_iscorebank,
      l_bankacctno,l_bankname,
        l_cashbalance, l_sebalance, l_fullname, l_idcode , l_iddate, l_idplace, l_reportdate, l_custodycd, l_phone,
        l_avlqtty, l_buyqtty, l_isalloc, l_begindate, l_duedate
    from camast a, caschd ca, sbsecurities b,cimast ci, cfmast cf, afmast af, sbsecurities b2
    where a.tocodeid = b.codeid and a.camastid=p_camastid and ca.camastid=a.camastid
        AND cf.custid = af.custid AND af.acctno = ca.afacctno
        and ca.afacctno=p_account
        and ci.acctno=ca.afacctno
        and ca.deltd <> 'Y'
        and nvl(a.tocodeid,a.codeid) = b2.refcodeid (+);

    select codeid into l_pcodeid from sbsecurities where symbol = l_symbol;

    l_ptrade:=fn_get_ptrade(p_camastid,l_pcodeid,p_account);
    l_pblock:=fn_get_pblocked(p_camastid,l_pcodeid,p_account);

    --Set cac field giao dich
    --01   AUTOID      C
    l_txmsg.txfields ('01').defname   := 'AUTOID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := to_char(nvl(l_caschdautoid,''));
    --02   CAMASTID      C
    l_txmsg.txfields ('02').defname   := 'CAMASTID';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := p_camastid;
    --03   AFACCTNO      C
    l_txmsg.txfields ('03').defname   := 'AFACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --04   SYMBOL        C
    l_txmsg.txfields ('04').defname   := 'SYMBOL';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := l_symbol;
    --05   EXPRICE       N
    l_txmsg.txfields ('05').defname   := 'EXPRICE';
    l_txmsg.txfields ('05').TYPE      := 'N';
    l_txmsg.txfields ('05').VALUE     := l_exprice;
    --06   SEACCTNO      C
    l_txmsg.txfields ('06').defname   := 'SEACCTNO';
    l_txmsg.txfields ('06').TYPE      := 'C';
    l_txmsg.txfields ('06').VALUE     := p_account || l_tocodeid;
    --07   SE BALANCE       N
    l_txmsg.txfields ('07').defname   := 'BALANCE';
    l_txmsg.txfields ('07').TYPE      := 'N';
    l_txmsg.txfields ('07').VALUE     := l_sebalance;
    --08   FULLNAME      C
    l_txmsg.txfields ('08').defname   := 'FULLNAME';
    l_txmsg.txfields ('08').TYPE      := 'C';
    l_txmsg.txfields ('08').VALUE     := l_fullname;
    --09   OPTSEACCTNO   C
    l_txmsg.txfields ('09').defname   := 'OPTSEACCTNO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     := p_account || l_optcodeid;
    --10   AMT          N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(nvl(p_qtty,0) * nvl(l_exprice,0),0);
    --11   CI BALANCE          N
    l_txmsg.txfields ('11').defname   := 'CIBALANCE';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := l_cashbalance;
    --12   CI BALANCE          N
    l_txmsg.txfields ('12').defname   := 'BALANCE';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := l_cashbalance;
    --16   TASKCD        C
    l_txmsg.txfields ('16').defname   := 'TASKCD';
    l_txmsg.txfields ('16').TYPE      := 'C';
    l_txmsg.txfields ('16').VALUE     := '';
    --18   BEGINDATE        C
    l_txmsg.txfields ('18').defname   := 'BEGINDATE';
    l_txmsg.txfields ('18').TYPE      := 'C';
    l_txmsg.txfields ('18').VALUE     := l_begindate;
    --19   DUEDATE        C
    l_txmsg.txfields ('19').defname   := 'DUEDATE';
    l_txmsg.txfields ('19').TYPE      := 'C';
    l_txmsg.txfields ('19').VALUE     := l_duedate;
    --20   MAXQTTY          N
    l_txmsg.txfields ('20').defname   := 'MAXQTTY';
    l_txmsg.txfields ('20').TYPE      := 'N';
    l_txmsg.txfields ('20').VALUE     := l_maxqtty;
    --21   QTTY          N
    l_txmsg.txfields ('21').defname   := 'QTTY';
    l_txmsg.txfields ('21').TYPE      := 'N';
    l_txmsg.txfields ('21').VALUE     := p_qtty;
    --22   PARVALUE          N
    l_txmsg.txfields ('22').defname   := 'PARVALUE';
    l_txmsg.txfields ('22').TYPE      := 'N';
    l_txmsg.txfields ('22').VALUE     := l_parvalue;
    --23   REPORTDATE          N
    l_txmsg.txfields ('23').defname   := 'REPORTDATE';
    l_txmsg.txfields ('23').TYPE      := 'C';
    l_txmsg.txfields ('23').VALUE     := l_reportdate;
    --24   CODEID          C
    l_txmsg.txfields ('24').defname   := 'CODEID';
    l_txmsg.txfields ('24').TYPE      := 'C';
    l_txmsg.txfields ('24').VALUE     := l_pcodeid;
    --25   AVLQTTY          N
    l_txmsg.txfields ('25').defname   := 'AVLQTTY';
    l_txmsg.txfields ('25').TYPE      := 'N';
    l_txmsg.txfields ('25').VALUE     := l_avlqtty;
    --26   BUYQTTY          N
    l_txmsg.txfields ('26').defname   := 'BUYQTTY';
    l_txmsg.txfields ('26').TYPE      := 'N';
    l_txmsg.txfields ('26').VALUE     := l_buyqtty;
    --30   DESCRIPTION   C
    l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := p_desc;
    --40   STATUS        C
    l_txmsg.txfields ('40').defname   := 'STATUS';
    l_txmsg.txfields ('40').TYPE      := 'C';
    l_txmsg.txfields ('40').VALUE     := 'M';
    --60   ISCOREBANK        N
    l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
    l_txmsg.txfields ('60').TYPE      := 'N';
    l_txmsg.txfields ('60').VALUE     := l_iscorebank;
    --61   BANKACCTNO        C
    l_txmsg.txfields ('61').defname   := 'BANKACCTNO';
    l_txmsg.txfields ('61').TYPE      := 'C';
    l_txmsg.txfields ('61').VALUE     := l_bankacctno;
    --62   BANKNAME        C
    l_txmsg.txfields ('62').defname   := 'BANKNAME';
    l_txmsg.txfields ('62').TYPE      := 'C';
    l_txmsg.txfields ('62').VALUE     := l_bankname;
    --70   PHONE    C
    l_txmsg.txfields ('70').defname   := 'PHONE';
    l_txmsg.txfields ('70').TYPE      := 'C';
    l_txmsg.txfields ('70').VALUE     := l_phone;
    --71   SYMBOL_ORG    C
    l_txmsg.txfields ('71').defname   := 'SYMBOL_ORG';
    l_txmsg.txfields ('71').TYPE      := 'C';
    l_txmsg.txfields ('71').VALUE     := l_optcodeid;
    --90   CUSTNAME    C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     := l_fullname;
    --91   ADDRESS     C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE     := '';
    --92   LICENSE     C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE     := l_idcode;
    --93   IDDATE    C
    l_txmsg.txfields ('93').defname   := 'IDDATE';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE     := l_iddate;
    --94   IDPLACE    C
    l_txmsg.txfields ('94').defname   := 'IDPLACE';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE     := l_idplace;
    --95   ISSNAME    C
    l_txmsg.txfields ('95').defname   := 'ISSNAME';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE     :='';
    --96   CUSTODYCD    C
    l_txmsg.txfields ('96').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE     := l_custodycd;
    --65   ISALLOC    N
    l_txmsg.txfields ('65').defname   := 'ALLOC';
    l_txmsg.txfields ('65').TYPE      := 'N';
    l_txmsg.txfields ('65').VALUE     := l_isalloc;
     --VuTN them moi de di dien, phan biet quyen cua tung loai ck
    --50    SL CK GD ? ?ua t?i ? N
     l_txmsg.txfields ('50').defname   := 'TRADE';
     l_txmsg.txfields ('50').TYPE      := 'N';
     l_txmsg.txfields ('50').value      := l_ptrade;
    --51    SL CK GD ? k? mua   N
     l_txmsg.txfields ('51').defname   := 'OUTPTRADE';
     l_txmsg.txfields ('51').TYPE      := 'N';
     l_txmsg.txfields ('51').value      := 0;
    --52    SL CK HCCN ? ?ua t?i ? N
     l_txmsg.txfields ('52').defname   := 'PBLOCKED';
     l_txmsg.txfields ('52').TYPE      := 'N';
     l_txmsg.txfields ('52').value      := l_pblock;
    --53    SL CK HCCN ? k? mua   N
     l_txmsg.txfields ('53').defname   := 'OUTPBLOCKED';
     l_txmsg.txfields ('53').TYPE      := 'N';
     l_txmsg.txfields ('53').value      := p_qtty;

    BEGIN
        IF txpks_#3384.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 3384: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'auto_call_txpks_3384');
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'auto_call_txpks_3384');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on auto_call_txpks_3384');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'auto_call_txpks_3384');
      RAISE errnums.E_SYSTEM_ERROR;
  END auto_call_txpks_3384;


procedure pr_get_rightofflist(p_refcursor in out pkg_report.ref_cursor,p_custodycd IN varchar2 ,p_afacctno in VARCHAR2, p_symbol IN VARCHAR2 )
is
    v_strCustid afmast.custid%TYPE;
    v_strCUSTODYCD  varchar2(10);
    v_strAfacctno  varchar2(10);
    v_strSymbol     varchar2(50);
begin
    plog.setbeginsection(pkgctx, 'pr_get_rightofflist');

    IF (p_custodycd <> 'ALL')
   THEN
      v_strCUSTODYCD := p_custodycd;
   ELSE
      v_strCUSTODYCD := '%%';
   END IF;

   IF (p_afacctno <> 'ALL')
   THEN
      v_strafacctno := p_afacctno;
   ELSE
      v_strafacctno := '%%';
   END IF;

      IF (p_symbol <> 'ALL')
   THEN
      v_strsymbol := p_symbol;
   ELSE
      v_strsymbol := '%%';
   END IF;

Open p_refcursor FOR
        SELECT CA.*, CA.PENDINGQTTY - NVL(RQ.MSGQTTY,0) pqtty
        FROM
        (
           select CA.AFACCTNO, sb.symbol,SB2.SYMBOL ORGSYMBOL,CA.TRADE,ca.RETAILBAL,ca.pbalance pbalance, cfm.custodycd,
            CASE WHEN ca.balance - ca.inbalance + ca.outbalance >0 THEN ca.balance - ca.inbalance + ca.outbalance ELSE 0 end orgbalance,
                ca.orgpbalance,ca.balance,
               ca.qtty regqtty, mst.exprice,mst.description,ca.pqtty*mst.exprice amt,sb.parvalue  ,
               to_date(varvalue,'dd/mm/rrrr') currdate,
               mst.camastid, cd.cdcontent sectype, mst.duedate,mst.reportdate, mst.rightoffrate,mst.exrate, mst.frdatetransfer,
               mst.todatetransfer,mst.begindate, ca.pbalance + ca.balance allbalance, ca.pqtty PENDINGQTTY,
               ca.inbalance, ca.outbalance, case when CA.AFACCTNO like v_strAfacctno THEN 'Y' ELSE 'N' END isrqaccount/*,car.daterightoff*/
           from caschd ca, sbsecurities sb, allcode cd, camast mst,sysvar sy, afmast af,
           (select ot.cfcustid custid from cfmast cf, otright ot where cf.custid= ot.authcustid and cf.custodycd like v_strcustodycd AND ot.deltd='N' union
            select cf.custid from cfmast cf where  cf.custodycd like v_strcustodycd)cf,
                   /*(SELECT max(txdate)daterightoff, ca.camastid,ca.afacctno
                    FROM CITRAN_GEN CI, caschd CA WHERE TLTXCD ='3384' AND FIELD ='BALANCE'
                    AND ci.REF = ca.autoid
                    GROUP BY  ca.camastid,ca.afacctno)car,*/
                    SBSECURITIES SB2, cfmast cfm
           where mst.tocodeid = sb.codeid and ca.camastid = mst.camastid
               and cd.cdname ='SECTYPE' and cd.cdtype ='SA' and cd.cdval=sb.sectype
               AND ca.status IN( 'V','M') AND ca.status <>'Y' AND ca.deltd <> 'Y'
               AND mst.catype='014' --and ca.pbalance > 0 and ca.pqtty > 0
               --AND sb.sectype NOT IN ('004','009') -- Ko lay len cac CK quyen mua cho giao dich
               and sy.grname = 'SYSTEM' AND sy.varname = 'CURRDATE'
               and ca.afacctno = af.acctno
               /*AND ca.afacctno = car.afacctno (+)*/
               /*AND ca.camastid = car.camastid (+)*/
               AND MST.CODEID=SB2.CODEID
               AND AF.CUSTID = CF.custid
             --  AND cf.custodycd like v_strcustodycd
               AND af.acctno like v_strAfacctno
               AND sb.symbol like v_strSymbol
               AND cfm.custid = cf.custid
               order by mst.begindate
        ) CA
        LEFT JOIN
        (
           SELECT msgacct, keyvalue, sum(NVL(MSGQTTY,0)) MSGQTTY FROM borqslog
               WHERE RQSTYP = 'CAR' AND STATUS IN ('W','P','H') AND msgacct like v_strAfacctno
               GROUP BY msgacct, keyvalue
        ) RQ
        ON CA.camastid = RQ.keyvalue AND CA.afacctno = RQ.msgacct;
    plog.setendsection(pkgctx, 'pr_get_rightofflist');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_rightofflist');
end pr_get_rightofflist;


procedure pr_get_rightofflistsimple(p_refcursor in out pkg_report.ref_cursor,p_custodycd IN varchar2 ,p_afacctno in VARCHAR2, p_symbol IN VARCHAR2 )
is
    v_strCustid afmast.custid%TYPE;
    v_strCUSTODYCD  varchar2(10);
    v_strAfacctno  varchar2(10);
    v_strSymbol     varchar2(50);
begin
    plog.setbeginsection(pkgctx, 'pr_get_rightofflistsimple');

    IF (p_custodycd <> 'ALL')
   THEN
      v_strCUSTODYCD := p_custodycd;
   ELSE
      v_strCUSTODYCD := '%%';
   END IF;

   IF (p_afacctno <> 'ALL')
   THEN
      v_strafacctno := p_afacctno;
   ELSE
      v_strafacctno := '%%';
   END IF;

      IF (p_symbol <> 'ALL')
   THEN
      v_strsymbol := p_symbol;
   ELSE
      v_strsymbol := '%%';
   END IF;

Open p_refcursor FOR
        SELECT CA.*, CA.PENDINGQTTY - NVL(RQ.MSGQTTY,0) pqtty
        FROM
        (
           select cf.custodycd,  CA.AFACCTNO, sb.symbol,ca.trade,ca.RETAILBAL,ca.pbalance pbalance,
            CASE WHEN ca.balance - ca.inbalance + ca.outbalance >0 THEN ca.balance - ca.inbalance + ca.outbalance ELSE 0 end orgbalance,
                ca.orgpbalance,ca.balance,
               ca.qtty regqtty, mst.exprice,mst.description,ca.pqtty*mst.exprice amt,sb.parvalue  ,
               to_date(varvalue,'dd/mm/rrrr') currdate,
               mst.camastid, cd.cdcontent sectype, mst.duedate,mst.reportdate, mst.rightoffrate,mst.exrate, mst.frdatetransfer,
               mst.todatetransfer,mst.begindate, ca.pbalance + ca.balance allbalance, ca.pqtty PENDINGQTTY,
               ca.inbalance, ca.outbalance, case when CA.AFACCTNO like v_strAfacctno THEN 'Y' ELSE 'N' END isrqaccount,
               REFULLNAME,RECUSTID
           from caschd ca, sbsecurities sb, allcode cd, camast mst,sysvar sy, afmast af, cfmast cf,
           (SELECT RE.AFACCTNO, MAX( CF.FULLNAME) REFULLNAME ,MAX(CF.CUSTID) reCUSTID
                    FROM reaflnk re, retype ret,cfmast cf
                    WHERE substr( re.reacctno,11) = ret.actype
                    AND substr(re.reacctno,1,10) = cf.custid
                    AND ret.rerole IN ('RM','CS')
                    AND RE.status ='A'
                    GROUP BY AFACCTNO) re
           where mst.tocodeid = sb.codeid and ca.camastid = mst.camastid
               and cd.cdname ='SECTYPE' and cd.cdtype ='SA' and cd.cdval=sb.sectype
               AND ca.status IN( 'V','M') AND ca.status <>'Y' AND ca.deltd <> 'Y'
               AND mst.catype='014' --and ca.pbalance > 0 and ca.pqtty > 0
               --AND sb.sectype NOT IN ('004','009') -- Ko lay len cac CK quyen mua cho giao dich
               and sy.grname = 'SYSTEM' AND sy.varname = 'CURRDATE'
               and ca.afacctno = af.acctno
               and af.custid = cf.custid
               AND cf.custid = re.afacctno (+)
               AND cf.custodycd like v_strcustodycd
               AND af.acctno like v_strAfacctno
               AND sb.symbol like v_strSymbol
               order by mst.begindate
        ) CA
        LEFT JOIN
        (
           SELECT msgacct, keyvalue, sum(NVL(MSGQTTY,0)) MSGQTTY FROM borqslog
               WHERE RQSTYP = 'CAR' AND STATUS IN ('W','P','H') AND msgacct like v_strAfacctno
               GROUP BY msgacct, keyvalue
        ) RQ
        ON CA.camastid = RQ.keyvalue AND CA.afacctno = RQ.msgacct;
    plog.setendsection(pkgctx, 'pr_get_rightofflistsimple');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_rightofflistsimple');
end pr_get_rightofflistsimple;


    --Bat dau Ham xu ly dat lenh vao FOMAST--
/*  procedure pr_InternalTransfer()
  begin
    plog.setbeginsection(pkgctx, 'pr_placeorder');


    plog.debug(pkgctx, p_text);
    plog.setendsection(pkgctx, 'pr_placeorder');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_placeorder');
  end pr_InternalTransfer;*/
  --Ket thuc Ham xu ly dat lenh vao pr_InternalTransfer--

/*
procedure pr_get_ciacount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2)
IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
begin
    plog.setbeginsection(pkgctx, 'pr_get_ciacount');

    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '%%';
    ELSE
        V_CUSTODYCD := p_custodycd;
    END IF;

    IF p_afacctno = 'ALL' OR p_afacctno IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := p_afacctno;
    END IF;

    Open p_refcursor for
        SELECT CI.*, NVL(CA.AMT, 0) careceiving
            FROM
                (
                    select afacctno,desc_status,pp,balance,advanceline,baldefovd,
                        AVLADV_T3+AVLADV_T1+AVLADV_T2 avladvance,aamt,bamt,odamt,dealpaidamt,
                        CASE WHEN outstanding < 0 THEN abs(outstanding) ELSE 0 END outstanding,
                        --receiving-cash_receiving_t0-cash_receiving_t1-cash_receiving_t2-cash_receiving_tn careceiving,
                        floatamt,receiving,netting,cash_receiving_t0,cash_receiving_t1,cash_receiving_t2,cash_receiving_t3,cash_receiving_tn,cash_sending_t0,
                        cash_sending_t1,cash_sending_t2,cash_sending_t3,cash_sending_tn,CASH_PENDWITHDRAW,CASH_PENDTRANSFER,
                        AVLADV_T3, AVLADV_T1, AVLADV_T2,
                        --bamt+cash_sending_t1+cash_sending_t2+cash_sending_t3+cash_sending_tn+CASH_PENDWITHDRAW+CASH_PENDTRANSFER cash_pending_send
                        --bamt+cash_sending_t0+cash_sending_t1+cash_sending_t3+cash_sending_tn+CASH_PENDWITHDRAW+CASH_PENDTRANSFER cash_pending_send
                        cash_pending_send
                    from buf_ci_account
                    where custodycd like V_CUSTODYCD
                        AND afacctno LIKE V_AFACCTNO
                ) CI
                LEFT JOIN
                (
                    SELECT CA.AFACCTNO, SUM(NVL(CA.AMT,0)) AMT
                    FROM CAMAST CAM, CASCHD CA
                    WHERE CA.CAMASTID = CAM.CAMASTID AND CAM.CATYPE IN ('010','015','016')
                        AND CA.STATUS = 'S'
                        AND CA.AFACCTNO LIKE V_AFACCTNO
                    GROUP BY CA.AFACCTNO
                ) CA
                ON CI.AFACCTNO = CA.AFACCTNO
    order by CI.afacctno;
    plog.setendsection(pkgctx, 'pr_get_ciacount');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_ciacount');
end pr_get_ciacount;
*/


procedure pr_get_ciSummaryAcount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2)
IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
    V_CURRDATE      DATE;
    --V_EXECTIME      VARCHAR2(10);
begin
    plog.setbeginsection(pkgctx, 'pr_get_ciSummaryAcount');

    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '';
    ELSE
        V_CUSTODYCD := p_custodycd;
    END IF;

    IF p_afacctno = 'ALL' OR p_afacctno IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := p_afacctno;
        SELECT CF.CUSTODYCD INTO V_CUSTODYCD
        FROM AFMAST AF, CFMAST CF
        WHERE AF.custid = CF.custid AND AF.ACCTNO = p_afacctno;
    END IF;
    --V_EXECTIME := fn_get_hose_time;
    -- GET CURRENT DATE
    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;
    Open p_refcursor for
         /*SELECT
            --1. Tai san thuc co
            1000000 NETASSVAL,
            --2. Ty le ky quy
            100 MARGINRATE,
            --3. Tien mat kha dung
            500000 BALDEFOVD,
            --4. Call Margin: No T3 va call margin
            200000 CALLAMT,
            --5. Phai nop trong ngay: s? ti?n d?n h?n ng?T3 v??t th?i h?n 2 ng?k? t? ng?call margin
            300000 ADDAMT,
            --Gio hose
            V_EXECTIME exctime
         from buf_ci_account ci
         where ci.custodycd = V_CUSTODYCD
             AND ci.afacctno LIKE V_AFACCTNO
         order by CI.afacctno;*/
         select
                   balance - holdbalance + totalseamt - totalodamt NETASSVAL,


                   --8. Ty le ky quy hien tai
                   --case when (MRQTTYAMT) +  CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt) < 0 then 0 else
                   --   case when (MRQTTYAMT)=0 then 100 else
                   --             round(((MRQTTYAMT) +  least(CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt),0))/(MRQTTYAMT),3)*100
                   --     end
                   MARGINRATE MRRATE,
                   case when ACCOUNTTYPE = 'B' then bankavlbal when subcorebank ='Y' then baldefovd + bankavlbal else baldefovd end baldefovd,
                   callamt,
                   addamt,/*,
                   V_EXECTIME exctime*/
                   bankbalance,
                   bankavlbal,
                   to_char(bankinqirydt,'hh24:MI:ss') bankinqirydt, callday, mst.advanceline, mst.avladvance,
                   CIMBALANCE
            from
            (
                select
                        --1.Tien tren tieu khoan
                        round(ci.balance + ci.bamt  + ci.rcvamt + ci.tdbalance + ci.crintacr + ci.tdintamt ) BALANCE, --Tien tren tieu khoan
                            --1.1 --Tien khong ky han
                            ci.balance + ci.bamt CIBALANCE,
                            --1.2 Tien co ky han
                            ci.tdbalance TDBALANCE,
                            --1.3 Tien cho ve
                            ci.rcvamt RCVAMT, -- Tien ban cho nhan ve
                            --1.4 Lai tien gui chua thanh toan
                            round(ci.crintacr + ci.tdintamt) INTBALANCE,
                        /*--2.Tong gia tri chung khoan
                        nvl(sec.mrqttyamt,0) + nvl(sec.nonmrqttyamt,0) + nvl(sec.dfqttyamt,0) TOTALSEAMT,
                            --2.1 Chung khoan duoc phep ky quy
                            nvl(sec.mrqttyamt,0) MRQTTYAMT,
                            --2.2 Chung khoan khong duoc phep ky quy
                            nvl(sec.NONMRQTTYAMT,0) NONMRQTTYAMT,
                            --2.1 Chung khoan cam co
                            nvl(sec.DFQTTYAMT,0) DFQTTYAMT,*/
                         --2.Tong gia tri chung khoan
                         nvl(sec.mrqttyamt_curr,0) + nvl(sec.nonmrqttyamt_curr,0) + nvl(sec.dfqttyamt_curr,0) TOTALSEAMT,

                            --2.1 Chung khoan duoc phep ky quy
                            nvl(sec.mrqttyamt_curr,0) MRQTTYAMT_curr,
                            nvl(sec.mrqttyamt,0) MRQTTYAMT,
                            --2.2 Chung khoan khong duoc phep ky quy
                            nvl(sec.NONMRQTTYAMT_curr,0) NONMRQTTYAMT_curr,
                            nvl(sec.NONMRQTTYAMT,0) NONMRQTTYAMT,
                            --2.1 Chung khoan cam co
                            nvl(sec.DFQTTYAMT_curr,0) DFQTTYAMT_curr,
                            nvl(sec.DFQTTYAMT,0) DFQTTYAMT,
                        --3.Tong phai tra
                            ci.dfodamt + ci.t0odamt + ci.mrodamt
                                + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + TDODAMT TOTALODAMT, --Tong phai tra
                            --3.1 No T3
                            ci.trfbuyamt,
                            --3.2 No bao lanh
                            ci.t0odamt T0AMT, --No bao lanh
                            ----3.3 No ky quy
                            --ci.bamt-ci.trfbuyamt  secureamt, --No ky quy
                            ci.execbuyamt secureamt, --No ky quy da khop
                            --3.3 No vay margin
                            ci.mrodamt MRAMT, --No Margin
                            --3.4 No vay ung truoc
                            ci.rcvadvamt,
                            --3.5 No vay cam co chung khoan
                            ci.dfodamt,
                            --3.6 Vay cam co tien gui
                            ci.TDODAMT,
                            --3.7 No vay phi luu ky
                            ci.ovdcidepofee DEPOFEEAMT, --No phi luu ky

                        --4. Tai san thuc co = 1+2-3
                        --5. Ky quy yeu cau
                        nvl(MRQTTYAMT,0)  - nvl(MR_QTTYAMT,0) + (ci.bamt-ci.trfbuyamt-ci.execbuyamt) - nvl(MR_QTTYAMT_BUY,0)  SESECURED,
                            --5.1 CHung khoan hien co
                            nvl(MRQTTYAMT,0)  - nvl(MR_QTTYAMT,0) SESECURED_AVL,
                            --5.2 CHung khoan cho ve
                            --nvl(MRQTTYAMT_BUY,0)  - nvl(MR_QTTYAMT_BUY,0) SESECURED_BUY,
                            (ci.bamt-ci.trfbuyamt-ci.execbuyamt) - nvl(MR_QTTYAMT_BUY,0) SESECURED_BUY,
                        --6. Ky quy hien co
                            --6.1 CHung khoan duoc phep ky quy
                            nvl(MRQTTYAMT,0) /*+ NONMRQTTYAMT*/ /*+ nvl(MRQTTYAMT_BUY,0)*/ /*+ NONMRQTTYAMT_BUY*/ QTTYAMT,
                            --6.2 Tien khong ky han
                            --BALANCE ,
                            --6.3 Tien gui co ky han ky quy
                            ci.mrcrlimit,
                            --6.4 SO du kha dung tai ngan hang
                            ci.BANKAVLBAL,
                            --No phai tra
                        --7. Thang du tai san
                            --Ky quy hien co - Ky quy yeu cau
                        --8. Ty le ky quy hien tai
                            --Ky quy hien co / Chung khoan duoc phep ky quy
                            least(ci.baldefovd,ci.balance + ci.bamt) baldefovd,
                            ci.callamt,
                            ci.addamt,
                            cim.bankbalance,
                            ci.ACCOUNTTYPE,
                            ci.bankinqirydt,
                            ci.subcorebank,
                            --to_char(cim.bankinqirydt,'hh24:MI:ss') bankinqirydt,
                            cim.holdbalance, af.callday,
                            ci.advanceline, ci.marginrate MARGINRATE,
                            ci.avladvance, cim.BALANCE CIMBALANCE
                    from buf_ci_account ci, cimast cim, afmast af,
                        /*(select afacctno,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE else 0 end) MRQTTYAMT,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT,
                            sum(case when mrratioloan>0 then  0 else QTTY*BASICPRICE end) NONMRQTTYAMT,
                            sum(DFQTTY * BASICPRICE) DFQTTYAMT,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE else 0 end) MRQTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  0 else buyingqtty*BASICPRICE end) NONMRQTTYAMT_BUY
                         from (
                                select afacctno,mrratioloan,basicprice,
                                        trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                                        securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn --+ buyingqtty
                                        - securities_sending_t3 qtty,
                                        deal_qtty dfqtty,
                                        buyingqtty
                                        from buf_se_account se
                                where se.custodycd = V_CUSTODYCD
                                  AND se.afacctno LIKE V_AFACCTNO
                            ) SE group by afacctno

                        ) sec*/
                        (select afacctno,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE else 0 end) MRQTTYAMT,
                            sum(case when mrratioloan>0 then  QTTY*currprice else 0 end) MRQTTYAMT_CURR,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT,
                            sum(case when mrratioloan>0 then  0 else QTTY*BASICPRICE end) NONMRQTTYAMT,
                            sum(case when mrratioloan>0 then  0 else QTTY*currprice end) NONMRQTTYAMT_CURR,
                            sum(DFQTTY * BASICPRICE) DFQTTYAMT,
                            sum(DFQTTY * currprice) DFQTTYAMT_CURR,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE else 0 end) MRQTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  0 else buyingqtty*BASICPRICE end) NONMRQTTYAMT_BUY

                         from (
                                select afacctno,mrratioloan,basicprice,nvl(st.closeprice,basicprice) currprice,
                                         AVLMRQTTY qtty,AVLDFQTTY dfqtty,
                                         buyingqtty
                                         from buf_se_account se, sbsecurities sb ,stockinfor st
                                         where afacctno = p_afacctno and se.codeid= sb.codeid and sb.symbol = st.symbol(+)
                                /*select afacctno,mrratioloan,basicprice,
                                        AVLMRQTTY qtty,AVLDFQTTY dfqtty,
                                        buyingqtty
                                        from buf_se_account se where afacctno =p_afacctno*/
                            ) SE group by afacctno

                        ) sec
                    where ci.afacctno = cim.acctno
                        and ci.custodycd = V_CUSTODYCD
                        AND ci.afacctno LIKE V_AFACCTNO
                        and ci.afacctno = af.acctno and af.acctno LIKE V_AFACCTNO
                        and  ci.afacctno = sec.afacctno(+)
            ) MST;
    plog.setendsection(pkgctx, 'pr_get_ciSummaryAcount');
exception when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_get_ciSummaryAcount');
end pr_get_ciSummaryAcount;

procedure pr_get_ciSummaryAcountNew
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2)
IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
    V_CURRDATE      DATE;
    V_MRTYPE       VARCHAR2(10);
    --V_EXECTIME      VARCHAR2(10);
begin
    plog.setbeginsection(pkgctx, 'pr_get_ciSummaryAcountNew');

    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '';
    ELSE
        V_CUSTODYCD := p_custodycd;
    END IF;

    IF p_afacctno = 'ALL' OR p_afacctno IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := p_afacctno;
        SELECT CF.CUSTODYCD, MRT.mrtype INTO V_CUSTODYCD,V_MRTYPE
        FROM AFMAST AF, CFMAST CF,AFTYPE AFT, MRTYPE MRT
        WHERE AF.custid = CF.custid AND AF.ACCTNO = p_afacctno
        AND AF.actype = AFT.actype
        AND AFT.mrtype = MRT.actype
        ;
    END IF;
    --V_EXECTIME := fn_get_hose_time;
    -- GET CURRENT DATE
    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;
    Open p_refcursor for
         /*SELECT
            --1. Tai san thuc co
            1000000 NETASSVAL,
            --2. Ty le ky quy
            100 MARGINRATE,
            --3. Tien mat kha dung
            500000 BALDEFOVD,
            --4. Call Margin: No T3 va call margin
            200000 CALLAMT,
            --5. Phai nop trong ngay: s? ti?n d?n h?n ng?T3 v??t th?i h?n 2 ng?k? t? ng?call margin
            300000 ADDAMT,
            --Gio hose
            V_EXECTIME exctime
         from buf_ci_account ci
         where ci.custodycd = V_CUSTODYCD
             AND ci.afacctno LIKE V_AFACCTNO
         order by CI.afacctno;*/
         select V_MRTYPE MRTYPE,
                   balance - holdbalance + totalseamt - totalodamt NETASSVAL,
                   --8. Ty le ky quy hien tai
                   --case when (MRQTTYAMT) +  CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt) < 0 then 0 else
                   --   case when (MRQTTYAMT)=0 then 100 else
                   --             round(((MRQTTYAMT) +  least(CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt),0))/(MRQTTYAMT),3)*100
                   --     end
                   MARGINRATE MRRATE,
                   case when ACCOUNTTYPE = 'B' then bankavlbal when subcorebank ='Y' then baldefovd + bankavlbal else baldefovd end baldefovd,
                   callamt,
                   addamt,/*,
                   V_EXECTIME exctime*/
                   bankbalance,
                   bankavlbal,
                   to_char(bankinqirydt,'hh24:MI:ss') bankinqirydt, callday, mst.advanceline, mst.avladvance,
                   CIMBALANCE,
                   BAMT,
                   RCVAMT,
                   TOTALAMT TOTALAMTSE,
                   TOTALBUYAMT,
                   TOTALAVLQTTY

            from
            (
                select
                        --1.Tien tren tieu khoan
                        round(ci.balance + ci.bamt  + ci.rcvamt + ci.tdbalance + ci.crintacr + ci.tdintamt ) BALANCE, --Tien tren tieu khoan
                            --1.1 --Tien khong ky han
                            ci.balance + ci.bamt CIBALANCE,
                            --1.2 Tien co ky han
                            ci.tdbalance TDBALANCE,
                            --1.3 Tien cho ve
                            ci.rcvamt RCVAMT, -- Tien ban cho nhan ve
                            --1.4 Lai tien gui chua thanh toan
                            round(ci.crintacr + ci.tdintamt) INTBALANCE,
                        /*--2.Tong gia tri chung khoan
                        nvl(sec.mrqttyamt,0) + nvl(sec.nonmrqttyamt,0) + nvl(sec.dfqttyamt,0) TOTALSEAMT,
                            --2.1 Chung khoan duoc phep ky quy
                            nvl(sec.mrqttyamt,0) MRQTTYAMT,
                            --2.2 Chung khoan khong duoc phep ky quy
                            nvl(sec.NONMRQTTYAMT,0) NONMRQTTYAMT,
                            --2.1 Chung khoan cam co
                            nvl(sec.DFQTTYAMT,0) DFQTTYAMT,*/
                        --2.Tong gia tri chung khoan
                         nvl(sec.mrqttyamt_curr,0) + nvl(sec.nonmrqttyamt_curr,0) + nvl(sec.dfqttyamt_curr,0) TOTALSEAMT,
                            --2.1 Chung khoan duoc phep ky quy
                            nvl(sec.mrqttyamt_curr,0) MRQTTYAMT_curr,
                            nvl(sec.mrqttyamt,0) MRQTTYAMT,
                            --2.2 Chung khoan khong duoc phep ky quy
                            nvl(sec.NONMRQTTYAMT_curr,0) NONMRQTTYAMT_curr,
                            nvl(sec.NONMRQTTYAMT,0) NONMRQTTYAMT,
                            --2.1 Chung khoan cam co
                            nvl(sec.DFQTTYAMT_curr,0) DFQTTYAMT_curr,
                            nvl(sec.DFQTTYAMT,0) DFQTTYAMT,
                            nvl (totalamt,0) totalamt,
                            nvl(totalbuyamt,0)totalbuyamt,
                            nvl(totalavlqtty,0) totalavlqtty,

                        --3.Tong phai tra
                            ci.dfodamt + ci.t0odamt + ci.mrodamt
                                + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + TDODAMT TOTALODAMT, --Tong phai tra
                            --3.1 No T3
                            ci.trfbuyamt,
                            --3.2 No bao lanh
                            ci.t0odamt T0AMT, --No bao lanh
                            ----3.3 No ky quy
                            --ci.bamt-ci.trfbuyamt  secureamt, --No ky quy
                            ci.execbuyamt secureamt, --No ky quy da khop
                            --3.3 No vay margin
                            ci.mrodamt MRAMT, --No Margin
                            --3.4 No vay ung truoc
                            ci.rcvadvamt,
                            --3.5 No vay cam co chung khoan
                            ci.dfodamt,
                            --3.6 Vay cam co tien gui
                            ci.TDODAMT,
                            --3.7 No vay phi luu ky
                            ci.ovdcidepofee DEPOFEEAMT, --No phi luu ky

                        --4. Tai san thuc co = 1+2-3
                        --5. Ky quy yeu cau
                        nvl(MRQTTYAMT,0)  - nvl(MR_QTTYAMT,0) + (ci.bamt-ci.trfbuyamt-ci.execbuyamt) - nvl(MR_QTTYAMT_BUY,0)  SESECURED,
                            --5.1 CHung khoan hien co
                            nvl(MRQTTYAMT,0)  - nvl(MR_QTTYAMT,0) SESECURED_AVL,
                            --5.2 CHung khoan cho ve
                            --nvl(MRQTTYAMT_BUY,0)  - nvl(MR_QTTYAMT_BUY,0) SESECURED_BUY,
                            (ci.bamt-ci.trfbuyamt-ci.execbuyamt) - nvl(MR_QTTYAMT_BUY,0) SESECURED_BUY,
                        --6. Ky quy hien co
                            --6.1 CHung khoan duoc phep ky quy
                            nvl(MRQTTYAMT,0) /*+ NONMRQTTYAMT*/ /*+ nvl(MRQTTYAMT_BUY,0)*/ /*+ NONMRQTTYAMT_BUY*/ QTTYAMT,
                            --6.2 Tien khong ky han
                            --BALANCE ,
                            --6.3 Tien gui co ky han ky quy
                            ci.mrcrlimit,
                            --6.4 SO du kha dung tai ngan hang
                            ci.BANKAVLBAL,
                            --No phai tra
                        --7. Thang du tai san
                            --Ky quy hien co - Ky quy yeu cau
                        --8. Ty le ky quy hien tai
                            --Ky quy hien co / Chung khoan duoc phep ky quy
                            least(ci.baldefovd,ci.balance + ci.bamt) baldefovd,
                            ci.callamt,
                            ci.addamt,
                            cim.bankbalance,
                            ci.ACCOUNTTYPE,
                            ci.bankinqirydt,
                            ci.subcorebank,
                            --to_char(cim.bankinqirydt,'hh24:MI:ss') bankinqirydt,
                            cim.holdbalance, af.callday,
                            ci.advanceline, ci.marginrate MARGINRATE,
                            ci.avladvance, cim.BALANCE CIMBALANCE,
                            CI.BAMT


                    from buf_ci_account ci, cimast cim, afmast af,
                        /*(select afacctno,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE else 0 end) MRQTTYAMT,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT,
                            sum(case when mrratioloan>0 then  0 else QTTY*BASICPRICE end) NONMRQTTYAMT,
                            sum(DFQTTY * BASICPRICE) DFQTTYAMT,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE else 0 end) MRQTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  0 else buyingqtty*BASICPRICE end) NONMRQTTYAMT_BUY
                         from (
                                select afacctno,mrratioloan,basicprice,
                                        trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                                        securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn --+ buyingqtty
                                        - securities_sending_t3 qtty,
                                        deal_qtty dfqtty,
                                        buyingqtty
                                        from buf_se_account se
                                where se.custodycd = V_CUSTODYCD
                                  AND se.afacctno LIKE V_AFACCTNO
                            ) SE group by afacctno

                        ) sec*/
                        (select afacctno,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE else 0 end) MRQTTYAMT,
                            sum(case when mrratioloan>0 then  QTTY*currprice else 0 end) MRQTTYAMT_CURR,
                            sum(case when mrratioloan>0 then  QTTY*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT,
                            sum(case when mrratioloan>0 then  0 else QTTY*BASICPRICE end) NONMRQTTYAMT,
                            sum(case when mrratioloan>0 then  0 else QTTY*currprice end) NONMRQTTYAMT_CURR,
                            sum(DFQTTY * BASICPRICE) DFQTTYAMT,
                            sum(DFQTTY * currprice) DFQTTYAMT_CURR,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE else 0 end) MRQTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT_BUY,
                            sum(case when mrratioloan>0 then  0 else buyingqtty*BASICPRICE end) NONMRQTTYAMT_BUY,
                            sum (totalamt) totalamt,
                            sum(totalbuyamt)totalbuyamt,
                            sum(totalavlqtty) totalavlqtty

                         from (
                                select afacctno,mrratioloan,basicprice,nvl(st.closeprice,basicprice) currprice,
                                         AVLMRQTTY qtty,AVLDFQTTY dfqtty,
                                         buyingqtty,
                                         (buyqtty+receiving-buyingqtty)*basicprice totalbuyamt,
                                         (buyqtty-buyingqtty+trade+mortage+receiving+BLOCKed+RESTRICTQTTY+ABSTANDING+Remainqtty)
                                          *basicprice totalamt,
                                         (trade+mortage+BLOCKed+RESTRICTQTTY+ABSTANDING+Remainqtty)
                                          *basicprice totalavlqtty
                                         from buf_se_account se, sbsecurities sb ,stockinfor st
                                         where afacctno = p_afacctno and se.codeid= sb.codeid and sb.symbol = st.symbol(+)
                                /*select afacctno,mrratioloan,basicprice,
                                        AVLMRQTTY qtty,AVLDFQTTY dfqtty,
                                        buyingqtty
                                        from buf_se_account se where afacctno =p_afacctno*/
                            ) SE group by afacctno

                        ) sec
                    where ci.afacctno = cim.acctno
                        and ci.custodycd = V_CUSTODYCD
                        AND ci.afacctno LIKE V_AFACCTNO
                        and ci.afacctno = af.acctno and af.acctno LIKE V_AFACCTNO
                        and  ci.afacctno = sec.afacctno(+)
            ) MST;
    plog.setendsection(pkgctx, 'pr_get_ciSummaryAcountNew');
exception when others then
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_get_ciSummaryAcountNew');
end pr_get_ciSummaryAcountNew;

procedure pr_get_ciacount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2)
IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
    V_CURRDATE      DATE;
    V_EXECTIME      VARCHAR2(10);
begin
    plog.setbeginsection(pkgctx, 'pr_get_ciacount');

    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '';
    ELSE
        V_CUSTODYCD := p_custodycd;
    END IF;

    IF p_afacctno = 'ALL' OR p_afacctno IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := p_afacctno;
        SELECT CF.CUSTODYCD INTO V_CUSTODYCD
        FROM AFMAST AF, CFMAST CF
        WHERE AF.custid = CF.custid AND AF.ACCTNO = p_afacctno;
    END IF;
    V_EXECTIME := fn_get_hose_time;
    -- GET CURRENT DATE
    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;
    Open p_refcursor for
         SELECT CI.*, NVL(CA.AMT, 0) careceiving, nvl(LN.TOTALLOAN,0) TOTALLOAN,
                -- tai san rong
                ci.BALANCE -- tien mat - secured - trf
                    + ci.cash_receiving_t0 + ci.cash_receiving_t1 + ci.cash_receiving_t2 + ci.cash_receiving_t3 + ci.cash_receiving_tn  --tien cho ve
                    + ROUND(NVL(se.sevalue,0))  -- chung khoan: san co + cho ve
                    - NVL(LN.TOTALLOAN,0) -- tong no vay
                    - NVL(odadv.odadv,0)  -- ung truoc df
                NETASSVAL,
                -- Lai lo
                NVL(se.pnlamt,0) pnlamt,
                -- ky quy yeu cau
                ROUND(NVL(se.sevalue,0)) - LEAST(ci.advlimit, ci.seamt) SESECURED,
                V_EXECTIME exctime
            FROM
                (
                    SELECT ci.afacctno,desc_status,ROUND(pp) PP,ROUND(balance) BALANCE,ROUND(advanceline) advanceline,
                        ROUND(baldefovd) baldefovd, ROUND(bankavlbal) bankavlbal, ROUND(bankbalance) bankbalance,
                        --ROUND(AVLADV_T3+AVLADV_T1+AVLADV_T2) avladvance,
                        avladvance,
                        ROUND(aamt) AAMT,ROUND(bamt) BAMT,
                        ROUND(odamt+DFODAMT) ODAMT,ROUND(dealpaidamt) dealpaidamt,
                        CASE WHEN outstanding < 0 THEN ROUND(abs(outstanding)) ELSE 0 END outstanding,
                        --receiving-cash_receiving_t0-cash_receiving_t1-cash_receiving_t2-cash_receiving_tn careceiving,
                        ROUND(floatamt) FLOATAMT,ROUND(receiving) receiving,ROUND(netting) netting,
                        ROUND(cash_receiving_t0) cash_receiving_t0,ROUND(cash_receiving_t1) cash_receiving_t1,
                        ROUND(cash_receiving_t2) cash_receiving_t2,ROUND(cash_receiving_t3) cash_receiving_t3,
                        ROUND(cash_receiving_tn) cash_receiving_tn,ROUND(cash_sending_t0) cash_sending_t0,
                        ROUND(cash_sending_t1) cash_sending_t1,ROUND(cash_sending_t2) cash_sending_t2,
                        ROUND(cash_sending_t3) cash_sending_t3,ROUND(cash_sending_tn) cash_sending_tn,
                        ROUND(CASH_PENDWITHDRAW) CASH_PENDWITHDRAW,ROUND(CASH_PENDTRANSFER) CASH_PENDTRANSFER,
                        --ROUND(AVLADV_T3) AVLADV_T3, ROUND(AVLADV_T1) AVLADV_T1, ROUND(AVLADV_T2) AVLADV_T2,
                        ROUND(nvl(avlreceiving_t3,0)) AVLADV_T3, ROUND(nvl(avlreceiving_t1,0)) AVLADV_T1, ROUND(nvl(avlreceiving_t2,0)) AVLADV_T2,
                        ROUND(cash_pending_send) cash_pending_send,
                        ROUND(casht2_sending_t0+casht2_sending_t1+casht2_sending_t2) casht2sending, marginrate,AVLWITHDRAW,
                        ROUND(ppref) ppref,
                        ROUND(greatest(advlimit - DFODAMT,0)) advlimit,
                        round(seamt) seamt
                    from buf_ci_account ci         ,
                  (select afacctno,
                       sum(case when st.duetype='RM' and st.rday=1 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t1,
                       sum(case when st.duetype='RM' and st.rday=2 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t2,
                       sum(case when st.duetype='RM' and st.rday=3 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t3--,
                   from   vw_bd_pending_settlement st
                    where (duetype='RM' or duetype='SM' or duetype = 'RS')
                    group by afacctno) st
                    where ci.custodycd = V_CUSTODYCD
                    AND ci.afacctno =st.afacctno (+)
                        AND ci.afacctno LIKE V_AFACCTNO

                        /*AND EXISTS (SELECT cf.custodycd, af.acctno afacctno
                                    FROM afmast af, otright ot, cfmast cf
                                    WHERE CI.AFACCTNO = AF.ACCTNO AND af.custid = cf.custid
                                        AND cf.custid = ot.cfcustid AND cf.custid = ot.authcustid
                                        AND af.status IN ('A','B') AND ot.deltd = 'N'
                                        AND ot.valdate <= V_CURRDATE AND ot.expdate >= V_CURRDATE
                                        AND CF.custodycd = V_CUSTODYCD
                                        AND AF.acctno LIKE V_AFACCTNO)*/
                ) CI
                LEFT JOIN
                (
                    SELECT CA.AFACCTNO, SUM(NVL(CA.AMT,0)) AMT
                    FROM CAMAST CAM, CASCHD CA
                    WHERE CA.CAMASTID = CAM.CAMASTID AND CAM.CATYPE IN ('010','015','016')
                        AND CA.STATUS = 'S'
                        AND CA.AFACCTNO LIKE V_AFACCTNO
                    GROUP BY CA.AFACCTNO
                ) CA
                ON CI.AFACCTNO = CA.AFACCTNO
                LEFT JOIN
                (
                SELECT A.ACCTNO,sum(A.TOTALLOAN) TOTALLOAN from
                (
                SELECT AF.ACCTNO,ROUND(SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR+SCHD.INTNMLACR  + SCHD.INTOVD + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTNMLOVD+SCHD.NML + SCHD.OVD) TOTALLOAN
                FROM  (SELECT LNSCHD.*
                                     FROM LNSCHD
                                     WHERE REFTYPE IN ('GP', 'P')
                                     AND DUENO = 0) SCHD,LNMAST LN, CFMAST CF, AFMAST AF
                WHERE SCHD.ACCTNO = LN.ACCTNO
                AND LN.TRFACCTNO like V_AFACCTNO
                AND CF.CUSTODYCD like V_CUSTODYCD
                AND AF.CUSTID=CF.CUSTID
                AND LN.TRFACCTNO=AF.ACCTNO) A
                GROUP BY ACCTNO
                ) LN
                 ON LN.ACCTNO=CI.AFACCTNO
                LEFT JOIN
                (
                    SELECT afacctno,
                           SUM((buf.trade -- trading
                                + buf.securities_receiving_t0
                                + buf.securities_receiving_t1
                                + buf.securities_receiving_t2  -- mua cho ve
                                + (buf.secured - buf.securities_sending_t3) -- ban chua khop
                                ) * buf.basicprice) sevalue,
                           SUM((buf.trade
                                + buf.dftrading
                                + buf.abstanding
                                + buf.restrictqtty
                                + buf.blocked
                                + buf.receiving  + buf.securities_receiving_t0
                                + (buf.secured - buf.securities_sending_t3 )
                                ) * (buf.basicprice-buf.fifocostprice)
                                ) pnlamt
                    FROM buf_se_account buf
                    WHERE afacctno = V_AFACCTNO
                    GROUP BY buf.afacctno
                ) SE ON ci.afacctno = se.afacctno
                LEFT JOIN
                (
                    SELECT acctno, sum(amt + feeamt) odadv,sum(amt) rcvadv
                    FROM adschd WHERE acctno = V_AFACCTNO and status <> 'C' GROUP BY acctno
                ) odadv  ON ci.afacctno = odadv.acctno
        order by CI.afacctno;
    plog.setendsection(pkgctx, 'pr_get_ciacount');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_ciacount');
end pr_get_ciacount;

procedure pr_get_ci_transfer_amount
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2,
    p_type in varchar2)
IS
    V_AFACCTNO      varchar2(10);

    L_STARTTIME   number;
    L_ENDTIME     number;
    L_CURRTIME    number;

begin
    plog.setbeginsection(pkgctx, 'pr_get_ci_transfer_amount');

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTART_TRF_TIME';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEEND_TRF_TIME';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;
    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    V_AFACCTNO := p_afacctno;

    IF(L_CURRTIME < L_STARTTIME OR L_CURRTIME > L_ENDTIME)THEN
        Open p_refcursor for
        SELECT greatest(buf.BALDEFOVD - ci.HOLDBALANCE,0) TRFAMOUNT from buf_ci_account buf, cimast ci
            where buf.afacctno = ci.acctno and buf.afacctno =V_AFACCTNO;
    else
        if p_type ='0' then
            Open p_refcursor for
                 SELECT BALDEFOVD + BANKAVLBAL TRFAMOUNT from buf_ci_account where afacctno =V_AFACCTNO;
        else
            Open p_refcursor for
                 SELECT greatest(buf.BALDEFOVD - ci.HOLDBALANCE,0) TRFAMOUNT from buf_ci_account buf, cimast ci
                    where buf.afacctno = ci.acctno and buf.afacctno =V_AFACCTNO;
        end if;
    end if;


    plog.setendsection(pkgctx, 'pr_get_ci_transfer_amount');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_ci_transfer_amount');
end pr_get_ci_transfer_amount;

procedure pr_get_ci_transfer_amount_1107
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2,
    p_type in varchar2)
IS
    V_AFACCTNO      varchar2(10);

    L_STARTTIME   number;
    L_ENDTIME     number;
    L_CURRTIME    number;
    l_baldefovd_released_adv  number;

begin
    plog.setbeginsection(pkgctx, 'pr_get_ci_transfer_amount_1107');

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTART_TRF_TIME';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEEND_TRF_TIME';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;
    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    V_AFACCTNO := p_afacctno;

    BEGIN
    SELECT BALDEFOVD_RELEASED_ADV(V_AFACCTNO) INTO  L_BALDEFOVD_RELEASED_ADV FROM DUAL ;
    EXCEPTION WHEN OTHERS THEN
        L_BALDEFOVD_RELEASED_ADV := 0;
    END ;


    IF(L_CURRTIME < L_STARTTIME OR L_CURRTIME > L_ENDTIME)THEN
        Open p_refcursor for
        SELECT greatest(L_BALDEFOVD_RELEASED_ADV - ci.HOLDBALANCE,0) TRFAMOUNT from  cimast ci
            where ci.afacctno =V_AFACCTNO;
    else
        if p_type ='0' then
            Open p_refcursor for
                 SELECT L_BALDEFOVD_RELEASED_ADV + BANKAVLBAL TRFAMOUNT from buf_ci_account where afacctno =V_AFACCTNO;
        else
            Open p_refcursor for
                 SELECT greatest(L_BALDEFOVD_RELEASED_ADV - ci.HOLDBALANCE,0) TRFAMOUNT
                 from  cimast ci
                 where ci.afacctno =V_AFACCTNO;
        end if;
    end if;


    plog.setendsection(pkgctx, 'pr_get_ci_transfer_amount_1107');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_ci_transfer_amount_1107');
end pr_get_ci_transfer_amount_1107;


procedure pr_get_seacount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2)
IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
    V_CURRDATE      DATE;
begin
    plog.setbeginsection(pkgctx, 'pr_get_seacount');
    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '';
    ELSE
        V_CUSTODYCD := p_custodycd;
    END IF;

    IF p_afacctno = 'ALL' OR p_afacctno IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := p_afacctno;
        SELECT CF.CUSTODYCD INTO V_CUSTODYCD
        FROM AFMAST AF, CFMAST CF
        WHERE AF.custid = CF.custid AND AF.ACCTNO = p_afacctno;
    END IF;
    -- GET CURRENT DATE
    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;

    Open p_refcursor for
        select afacctno,SE.symbol,nvl(total_qtty,0) total_qtty,nvl(trade,0) trade, nvl(netting + SECURED,0) netting,nvl(deal_qtty,0) deal_qtty,nvl(abstanding,0) abstanding,
            nvl(blocked,0) blocked,nvl(MORTAGE,0)MORTAGE,
            nvl(securities_receiving_t0,0) securities_receiving_t0, nvl(securities_receiving_t1,0) securities_receiving_t1,
            nvl(securities_receiving_t2,0)securities_receiving_t2,nvl(securities_receiving_t3,0) securities_receiving_t3,
            nvl(securities_sending_t0,0) securities_sending_t0,nvl(securities_sending_t1,0) securities_sending_t1,
            nvl(securities_sending_t2,0) securities_sending_t2,nvl(securities_sending_t3,0) securities_sending_t3,
            nvl(RESTRICTQTTY,0) RESTRICTQTTY,nvl(dftrading,0) dftrading,
            nvl(trade+netting+SECURED+MORTAGE+RESTRICTQTTY+blocked,0) /*+securities_sending_t1+securities_sending_t2+securities_sending_t0+securities_sending_t3*/ avlqtty,
            se.fifocostprice, se.basicprice,
            se.mrratioloan,
            se.secured - securities_sending_t0 matchingamt,
            se.receiving - nvl(securities_receiving_t0,0)+
                nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)
                +nvl(securities_receiving_t3,0) careceiving,
            se.deposit + se.senddeposit deposit
        from buf_se_account se, sbsecurities sb
        where se.codeid = sb.codeid --AND sb.sectype IN ('001','006','007')
            AND se.custodycd = V_CUSTODYCD
            AND se.afacctno LIKE V_AFACCTNO
            AND nvl(total_qtty,0)+nvl(deal_qtty,0)+nvl(abstanding,0)+nvl(securities_receiving_t0,0)+
                nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)
                +nvl(securities_receiving_t3,0)+nvl(securities_sending_t0,0)+nvl(securities_sending_t1,0)+nvl(securities_sending_t2,0)+nvl(securities_sending_t3,0)+nvl(RESTRICTQTTY,0)+nvl(dftrading,0) <> 0
            /*AND EXISTS(SELECT cf.custodycd, af.acctno afacctno
                        FROM afmast af, otright ot, cfmast cf
                        WHERE se.AFACCTNO = AF.ACCTNO AND af.custid = cf.custid
                            AND af.acctno = ot.afacctno AND af.custid = ot.authcustid
                            AND af.status = 'A' AND ot.deltd = 'N'
                            AND ot.valdate <= V_CURRDATE AND ot.expdate >= V_CURRDATE
                            AND CF.custodycd = V_CUSTODYCD
                            AND AF.acctno LIKE V_AFACCTNO)*/
        order by afacctno,symbol;
    plog.setendsection(pkgctx, 'pr_get_seacount');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_seacount');
end pr_get_seacount;


procedure pr_get_rpt1002(p_refcursor in out pkg_report.ref_cursor,
                        p_custodycd in varchar2,
                        p_afcctno in varchar2,
                        p_frdate in varchar2,
                        p_todate in varchar2)
is
begin
    plog.setbeginsection(pkgctx, 'pr_get_rpt1002');
    cf1002 (
       p_refcursor,
       'A',
       '',
       '',
       '',
       p_frdate,
       p_todate,
       p_custodycd,
       p_afcctno,
       '0001'
    );
    plog.setendsection(pkgctx, 'pr_get_rpt1002');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_rpt1002');
end pr_get_rpt1002;

/*PROCEDURE pr_trg_account_log (p_acctno in VARCHAR2, p_mod varchar2)
IS
BEGIN
    plog.setbeginsection (pkgctx, 'pr_trg_account_log');
    if p_mod = 'SE' THEN
        plog.debug (pkgctx, 'log_se_account: ' || p_acctno);
        insert into log_se_account (autoid,acctno,status, logtime, applytime)
        values (seq_log_se_account.nextval,p_acctno,'P', SYSTIMESTAMP,NULL);
    elsif p_mod = 'CI' THEN
        plog.debug (pkgctx, 'log_ci_account: ' || p_acctno);
        insert into log_ci_account (autoid,acctno,status, logtime, applytime)
        values (seq_log_ci_account.nextval,p_acctno,'P', SYSTIMESTAMP,NULL);
    elsif p_mod = 'OD' THEN
        plog.debug (pkgctx, 'log_of_account: ' || p_acctno);
        insert into log_od_account (autoid,acctno,status, logtime, applytime)
        values (seq_log_od_account.nextval,p_acctno,'P', SYSTIMESTAMP,NULL);
    end if;
    plog.setendsection (pkgctx, 'pr_trg_account_log');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    plog.debug (pkgctx,'got error on release pr_trg_account_log');
    plog.setbeginsection(pkgctx, 'pr_trg_account_log');
END pr_trg_account_log;*/


-- Lay danh muc dau tu cua khach hang
-- TheNN, 05-Jan-2012
PROCEDURE pr_get_Portfolio
    (p_refcursor in out pkg_report.ref_cursor,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     GETTYPE        IN  VARCHAR2)
    IS

  V_CUSTODYCD   VARCHAR2(10);
  V_AFACCTNO    VARCHAR2(10);
  V_SYMBOL      VARCHAR2(20);
  V_CUSTID      VARCHAR2(10);

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;


    IF SYMBOL = 'ALL'  OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF AFACCTNO = 'ALL'  OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;

    -- LAY THONG TIN DANH MUC DAU TU
    IF GETTYPE = '001' THEN -- CP DANG NAM GIU
        OPEN p_refcursor FOR
            SELECT cf.CUSTODYCD, af.CUSTID, AF.ACCTNO AFACCTNO, SE.ACCTNO SEACCTNO, SE.CODEID, SB.SYMBOL,
                NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/ SEQTTY, NVL(SEC.COSTPRICE,0) costprice, SB.BASICPRICE,
                (NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/) * NVL(SEC.COSTPRICE,0)  VAL,
                (NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/) * SB.BASICPRICE CURVAL,
                (NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/) * (SB.BASICPRICE-SE.COSTPRICE) PROFITANDLOSS,
                CASE WHEN NVL(SEC.COSTPRICE,0)>0 THEN round((SB.BASICPRICE-NVL(SEC.COSTPRICE,0))/NVL(SEC.COSTPRICE,0) * 100,4) ELSE 0 END PCPROFITANDLOSS,
                CASE WHEN datediff('MONTH', SE.OPNDATE,sysdate) <=6 AND sbs.refcodeid IS NULL THEN 'Y' ELSE 'N' END EDITABLE,
                SBS.SECTYPE, al.cdcontent Sectypename
            FROM SEMAST SE, AFMAST AF, SECURITIES_INFO SB, SBSECURITIES SBS, cfmast cf, allcode al,
                (
                   select mst.acctno, mst.codeid, mst.acctno || mst.codeid seacctno,
                        round((sum((mst.qtty-mst.mapqtty)*mst.costprice))/sum(mst.qtty-mst.mapqtty),0) costprice
                    from secmast mst
                    where mst.ptype = 'I' and mst.qtty <> 0
                        and mst.status = 'P'
                        and mst.deltd <> 'Y'
                    group by mst. acctno, mst.codeid
                ) sec
            WHERE SE.AFACCTNO = AF.ACCTNO
                AND SE.CODEID = SB.CODEID
                AND SB.CODEID = SBS.CODEID
                AND SE.acctno = sec.seacctno (+)
                AND af.custid = cf.custid
                --AND NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) + NVL(SE.NETTING,0) >0
                AND NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) >0 --Khong lay ra neu da ban het CK.
                AND SBS.SECTYPE NOT IN ('004','009') -- Ko lay len cac CK quyen mua cho giao dich
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                AND al.cdtype = 'SA' AND al.cdname = 'SECTYPE' AND SBS.SECTYPE = al.cdval
            ORDER BY SB.SYMBOL, AF.ACCTNO, SB.SYMBOL;
    ELSIF GETTYPE = '002' THEN -- CP DA BAN
        OPEN p_refcursor FOR
            SELECT STS.SEACCTNO, STS.AFACCTNO, SUM(STS.AMT) AMT, SUM(STS.QTTY) QTTY, STS.CODEID,
                MAX(STS.SYMBOL) SYMBOL, round(SUM(STS.AMT)/SUM(STS.QTTY),4) SELLPRICE,
                --ROUND(SUM(STS.COSTPRICE * STS.QTTY)/SUM(STS.QTTY),4) COSTPRICE,
                fn_GetSECostPrice(STS.SEACCTNO) COSTPRICE,
                SUM(STS.AMT) - SUM(STS.COSTPRICE*STS.QTTY) PROFITANDLOSS,
                CASE WHEN SUM(STS.COSTPRICE*STS.QTTY)/SUM(STS.QTTY) > 0
                        THEN ROUND(100*(SUM(STS.AMT) - SUM(STS.COSTPRICE*STS.QTTY))/SUM(STS.COSTPRICE*STS.QTTY),4)
                        ELSE 0 END PCPROFITANDLOSS,
                max(sts.sectype) sectype, max(sts.sectypename) sectypename
            FROM
                (
                    SELECT STS.TXDATE, STS.ACCTNO SEACCTNO, STS.AFACCTNO, STS.AMT AMT, STS.QTTY QTTY, STS.CODEID,
                        SB.SYMBOL SYMBOL, CASE WHEN STS.txdate = getcurrdate THEN NVL(SE.costprice,0) ELSE STS.costprice END costprice,
                        sb.sectype, al.cdcontent sectypename
                    FROM VW_STSCHD_ALL STS, SBSECURITIES SB, AFMAST AF,
                         (
                               select mst.acctno, mst.codeid, mst.acctno || mst.codeid seacctno,
                                    round((sum((mst.qtty-mst.mapqtty)*mst.costprice))/sum(mst.qtty-mst.mapqtty),0) costprice
                                from secmast mst
                                where mst.ptype = 'I' and mst.qtty <> 0
                                    and mst.status = 'P'
                                    and mst.deltd <> 'Y'
                                group by mst. acctno, mst.codeid
                            ) SE, allcode al
                    WHERE STS.DUETYPE= 'SS' AND SB.CODEID = STS.CODEID
                        AND AF.ACCTNO = STS.AFACCTNO
                        AND STS.acctno = SE.acctno (+)
                        AND SB.SECTYPE NOT IN ('004','009') -- Ko lay len cac CK quyen mua cho giao dich
                        AND AF.CUSTID LIKE V_CUSTID
                        AND STS.AFACCTNO LIKE V_AFACCTNO
                        AND SB.SYMBOL LIKE V_SYMBOL
                        AND al.cdtype = 'SA' AND al.cdname = 'SECTYPE' AND SB.SECTYPE = al.cdval
                        --AND STS.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                        --AND STS.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                ) STS
            GROUP BY STS.SEACCTNO, STS.AFACCTNO, STS.CODEID
            ORDER BY MAX(STS.SYMBOL), STS.AFACCTNO, STS.SEACCTNO
            ;
    ELSIF GETTYPE = '003' THEN -- TOAN BO CP
        OPEN p_refcursor FOR
            SELECT STS.*
            FROM
            (
                SELECT STS.AFACCTNO, STS.SEACCTNO, STS.SYMBOL, STS.CODEID, STS.SEQTTY,
                    /*CASE WHEN STS.SEQTTY = 0 THEN NVL(B_STS.B_COSTPRICE,0) ELSE STS.COSTPRICE END COSTPRICE,*/
                    STS.COSTPRICE, STS.BASICPRICE, STS.VAL, STS.CURVAL,
                    STS.SEQTTY * (STS.BASICPRICE-STS.COSTPRICE) PROFITANDLOSS,
                    CASE WHEN STS.COSTPRICE>0 THEN round((STS.BASICPRICE-STS.COSTPRICE)/(STS.COSTPRICE) * 100,4) ELSE 0 END PCPROFITANDLOSS,
                    NVL(B_STS.AMT,0) BUYAMT, NVL(B_STS.QTTY,0) BUYQTTY,
                    NVL(S_STS.AMT,0) SELLAMT, NVL(S_STS.QTTY,0) SELLQTTY, NVL(S_STS.SELLPRICE,0) SELLPRICE, NVL(S_STS.PROFITANDLOSS,0) RPROFITANDLOSS,
                    NVL(S_STS.PCPROFITANDLOSS,0) RPCPROFITANDLOSS, STS.SECTYPE, STS.SECTYPENAME
                FROM
                    (
                        SELECT AF.ACCTNO AFACCTNO, SE.ACCTNO SEACCTNO, SE.CODEID, SB.SYMBOL,
                            NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/ SEQTTY, fn_GetSECostPrice(SE.ACCTNO) COSTPRICE /*SE.COSTPRICE*/, SB.BASICPRICE,
                            (NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/) * SE.COSTPRICE VAL,
                            (NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/) * SB.BASICPRICE CURVAL,
                            SBS.SECTYPE, AL.cdcontent SECTYPENAME
                            --(NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) /*+ NVL(SE.NETTING,0)*/) * (SB.BASICPRICE-SE.COSTPRICE) PROFITANDLOSS,
                            --CASE WHEN SE.COSTPRICE>0 THEN round((SB.BASICPRICE-SE.COSTPRICE)/(SE.COSTPRICE) * 100,4) ELSE 0 END PCPROFITANDLOSS
                        FROM SEMAST SE, AFMAST AF, SECURITIES_INFO SB, SBSECURITIES SBS, ALLCODE AL
                        WHERE SE.AFACCTNO = AF.ACCTNO
                            AND SE.CODEID = SB.CODEID
                            AND SBS.CODEID = SB.CODEID
                            AND SBS.SECTYPE NOT IN ('004','009') -- Ko lay len cac CK quyen mua cho giao dich
                            AND AF.CUSTID LIKE V_CUSTID
                            AND AF.ACCTNO LIKE V_AFACCTNO
                            AND SB.SYMBOL LIKE V_SYMBOL
                            AND al.cdtype = 'SA' AND al.cdname = 'SECTYPE' AND SBS.SECTYPE = al.cdval
                    ) STS,
                    (
                        SELECT STS.ACCTNO SEACCTNO, STS.AFACCTNO, SUM(STS.AMT) AMT, SUM(STS.QTTY) QTTY, STS.CODEID,
                            round(SUM(STS.AMT + (CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100 ELSE OD.FEEACR END))/SUM(STS.QTTY),4) B_COSTPRICE
                        FROM VW_STSCHD_ALL STS, AFMAST AF, SBSECURITIES SB, vw_odmast_all OD, ODTYPE ODT
                        WHERE STS.DUETYPE= 'RS' AND STS.CODEID = SB.CODEID
                            AND AF.ACCTNO = STS.AFACCTNO
                            AND STS.orgorderid = OD.orderid
                            AND OD.actype = ODT.actype
                            AND AF.CUSTID LIKE V_CUSTID
                            AND STS.AFACCTNO LIKE V_AFACCTNO
                            AND SB.SYMBOL LIKE V_SYMBOL
                            --AND STS.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                            --AND STS.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                        GROUP BY STS.ACCTNO, STS.AFACCTNO, STS.CODEID
                    ) B_STS,
                    (
                        SELECT STS.SEACCTNO, STS.AFACCTNO, SUM(STS.AMT) AMT, SUM(STS.QTTY) QTTY, STS.CODEID,
                            MAX(STS.SYMBOL) SYMBOL, round(SUM(STS.AMT)/SUM(STS.QTTY),4) SELLPRICE,
                            ROUND(SUM(STS.COSTPRICE * STS.QTTY)/SUM(STS.QTTY),4) COSTPRICE,
                            SUM(STS.AMT) - SUM(STS.COSTPRICE*STS.QTTY) PROFITANDLOSS,
                            CASE WHEN SUM(STS.COSTPRICE*STS.QTTY)/SUM(STS.QTTY) > 0
                                    THEN ROUND(100*(SUM(STS.AMT) - SUM(STS.COSTPRICE*STS.QTTY))/SUM(STS.COSTPRICE*STS.QTTY),4)
                                    ELSE 0 END PCPROFITANDLOSS
                        FROM
                            (
                                SELECT STS.TXDATE, STS.ACCTNO SEACCTNO, STS.AFACCTNO, STS.AMT AMT, STS.QTTY QTTY, STS.CODEID,
                                    SB.SYMBOL SYMBOL, CASE WHEN STS.txdate = getcurrdate THEN NVL(SE.costprice,0) ELSE STS.costprice END costprice
                                FROM VW_STSCHD_ALL STS, SBSECURITIES SB, AFMAST AF,
                                     (
                                           select mst.acctno, mst.codeid, mst.acctno || mst.codeid seacctno,
                                                round((sum((mst.qtty-mst.mapqtty)*mst.costprice))/sum(mst.qtty-mst.mapqtty),0) costprice
                                            from secmast mst
                                            where mst.ptype = 'I' and mst.qtty <> 0
                                                and mst.status = 'P'
                                                and mst.deltd <> 'Y'
                                            group by mst. acctno, mst.codeid
                                        ) SE
                                WHERE STS.DUETYPE= 'SS' AND SB.CODEID = STS.CODEID
                                    AND AF.ACCTNO = STS.AFACCTNO
                                    AND STS.acctno = SE.acctno (+)
                                    AND SB.SECTYPE NOT IN ('004','009') -- Ko lay len cac CK quyen mua cho giao dich
                                    AND AF.CUSTID LIKE V_CUSTID
                                    AND STS.AFACCTNO LIKE V_AFACCTNO
                                    AND SB.SYMBOL LIKE V_SYMBOL
                                    --AND STS.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                                    --AND STS.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            ) STS
                        GROUP BY STS.SEACCTNO, STS.AFACCTNO, STS.CODEID
                    ) S_STS
                WHERE STS.SEACCTNO = B_STS.SEACCTNO(+)
                    AND STS.SEACCTNO = S_STS.SEACCTNO(+)
            ) STS
            WHERE STS.SEQTTY + STS.BUYQTTY + STS.SELLQTTY>0
            ORDER BY STS.SYMBOL,STS.AFACCTNO, STS.SEACCTNO;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_Portfolio');
END pr_get_Portfolio;

PROCEDURE PR_FO_FOBANNK2OD (p_FOORDERID IN VARCHAR2)
    IS
        L_TXMSG         TX.MSG_RECTYPE;
        V_TLTXCD        VARCHAR2 (4);
        V_ORDERID       VARCHAR2 (50);
        V_TXDATE        DATE;
        V_AFACCTNO      VARCHAR2 (50);
        V_EXECTYPE      VARCHAR2 (50);
        V_PRICETYPE     VARCHAR2 (50);
        V_SYMBOL        VARCHAR2 (50);
        V_BANKACCT      VARCHAR2 (50);
        V_BANKCODE      VARCHAR2 (50);
        V_NOTES         VARCHAR2 (250);
        V_QTTY          NUMBER (20);
        V_PRICE         NUMBER (20, 4);
        V_AVLBAL        NUMBER (20);
        V_HOLDAMT       NUMBER (20);
        V_ACTYPE        VARCHAR2 (50);
        V_CLEARDAY      NUMBER (5);
        V_BRATIO        NUMBER (10, 4);
        V_MINFEEAMT     NUMBER (10);
        V_DEFFEERATE    NUMBER (10, 4);
        V_STRCURRDATE   VARCHAR2 (10);
        V_STRDESC       VARCHAR2 (250);
        V_STREN_DESC    VARCHAR2 (250);
        L_ERR_CODE      VARCHAR2 (50);
        P_ERR_CODE      VARCHAR2 (50);
        L_ERR_PARAM     VARCHAR2 (300);
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'pr_fo_fobannk2od');

        --Lay thong so lenh can sync
        /*SELECT   ACTYPE,CLEARDAY,BRATIO,MINFEEAMT,DEFFEERATE
          INTO   V_ACTYPE,V_CLEARDAY,V_BRATIO,V_MINFEEAMT,V_DEFFEERATE
          FROM   (  SELECT   A.ACTYPE,A.CLEARDAY,A.BRATIO,A.MINFEEAMT,A.DEFFEERATE,B.ODRNUM
                      FROM   ODTYPE A,AFIDTYPE B,FOMAST F,SBSECURITIES S,AFMAST AF
                     WHERE       A.STATUS = 'Y'
                             AND F.CODEID = S.CODEID
                             AND F.AFACCTNO = AF.ACCTNO
                             AND (A.VIA = F.VIA OR A.VIA = 'A')          --VIA
                             AND A.CLEARCD = F.CLEARCD               --CLEARCD
                             AND (A.EXECTYPE = F.EXECTYPE  --l_build_msg.fld22
                                                         OR A.EXECTYPE = 'AA') --EXECTYPE
                             AND (A.TIMETYPE = F.TIMETYPE OR A.TIMETYPE = 'A') --TIMETYPE
                             AND (A.PRICETYPE = F.PRICETYPE
                                  OR A.PRICETYPE = 'AA')           --PRICETYPE
                             AND (A.MATCHTYPE = F.MATCHTYPE
                                  OR A.MATCHTYPE = 'A')            --MATCHTYPE
                             AND (A.TRADEPLACE = S.TRADEPLACE
                                  OR A.TRADEPLACE = '000')
                             AND (INSTR (
                                      CASE
                                          WHEN S.SECTYPE IN ('001', '002')
                                          THEN
                                              S.SECTYPE || ',' || '111,333'
                                          WHEN S.SECTYPE IN ('003', '006')
                                          THEN
                                              S.SECTYPE || ',' || '222,333,444'
                                          WHEN S.SECTYPE IN ('008')
                                          THEN
                                              S.SECTYPE || ',' || '111,444'
                                          ELSE
                                              S.SECTYPE
                                      END,
                                      A.SECTYPE) > 0
                                  OR A.SECTYPE = '000')
                             AND (A.NORK = F.NORK OR A.NORK = 'A')      --NORK
                             AND (CASE
                                      WHEN A.CODEID IS NULL THEN F.CODEID
                                      ELSE A.CODEID
                                  END) = F.CODEID
                             AND A.ACTYPE = B.ACTYPE
                             AND B.AFTYPE = AF.ACTYPE
                             AND B.OBJNAME = 'OD.ODTYPE'
                             AND F.ACCTNO = p_FOORDERID
                  ORDER BY   B.ODRNUM DESC)
         WHERE   ROWNUM <= 1;*/

        --plog.debug(PKGCTX,'p_FOORDERID: ' || p_FOORDERID);
         --Lay thong so lenh can sync
        SELECT   A.ACTYPE,A.CLEARDAY,A.BRATIO,A.MINFEEAMT,A.DEFFEERATE
        INTO   V_ACTYPE,V_CLEARDAY,V_BRATIO,V_MINFEEAMT,V_DEFFEERATE
        FROM ODTYPE A, FOMAST F
        WHERE A.ACTYPE = F.ACTYPE
            AND F.ACCTNO = p_FOORDERID;

        --plog.debug(PKGCTX,'V_ACTYPE: ' || V_ACTYPE);

        --tinh toan so du can hold
        SELECT   FO.ACCTNO ORDERID,
                 TO_DATE (SUBSTR (FO.ACCTNO, 1, 10), 'DD/MM/RRRR'),
                 AF.BANKACCTNO,
                 AF.BANKNAME,
                 FO.AFACCTNO,
                 FO.QUOTEPRICE * 1000 * FO.QUANTITY * V_BRATIO / 100
                 - GREATEST(GETAVLPP(AF.ACCTNO)-NVL(HM.HLDAMT,0),0)
                 + (CASE
                        WHEN V_MINFEEAMT >
                                 (  FO.QUOTEPRICE
                                  * 1000
                                  * FO.QUANTITY
                                  * V_DEFFEERATE
                                  / 100)
                        THEN
                            V_MINFEEAMT
                        ELSE
                            (  FO.QUOTEPRICE
                             * 1000
                             * FO.QUANTITY
                             * V_DEFFEERATE
                             / 100)
                    END)
                 + GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0)
                 HOLDAMT,
                 FO.EXECTYPE
                 || '.'
                 || FO.SYMBOL
                 || ': '
                 || TO_CHAR (FO.QUANTITY)
                 || '@'
                 || DECODE (FO.PRICETYPE,
                            'LO', TO_CHAR (FO.QUOTEPRICE),
                            FO.PRICETYPE)
          INTO   V_ORDERID,
                 V_TXDATE,
                 V_BANKACCT,
                 V_BANKCODE,
                 V_AFACCTNO,
                 V_HOLDAMT,
                 V_NOTES
          FROM   FOMAST FO, AFMAST AF, CIMAST CI,
          (
            SELECT NVL(SUM(A.HLDAMT),0) HLDAMT,A.AFACCTNO FROM
            (
                SELECT NVL(SUM(REQ.TXAMT),0) HLDAMT,REQ.AFACCTNO
                FROM crbtxreq REQ
                WHERE REQ.TRFCODE='HOLD' AND REQ.STATUS='P'
                GROUP BY REQ.AFACCTNO
                UNION ALL
                SELECT NVL(SUM(RQ.MSGAMT),0) HLDAMT,RQ.MSGACCT AFACCTNO
                FROM BORQSLOG RQ WHERE RQ.STATUS='H'
                GROUP BY MSGACCT
            ) A GROUP BY A.AFACCTNO
          ) HM
         WHERE   FO.ACCTNO = p_FOORDERID
                 AND FO.AFACCTNO = AF.ACCTNO
                 AND CI.AFACCTNO = AF.ACCTNO
                 AND FO.EXECTYPE IN ('NB')
                 --AND FO.TIMETYPE <> 'G'
                 AND FO.AFACCTNO=HM.AFACCTNO(+)
        UNION ALL --Neu la lenh sua, tinh xem can phai hold them hay ko, hold bao nhieu
        SELECT   FO.ACCTNO ORDERID,
                 TO_DATE (SUBSTR (FO.ACCTNO, 1, 10), 'DD/MM/RRRR'),
                 AF.BANKACCTNO,
                 AF.BANKNAME,
                 FO.AFACCTNO,
                 CASE WHEN fo.price < fo.refprice THEN 0 else
                 GREATEST (
                     FO.QUOTEPRICE * 1000 * FO.QUANTITY * V_BRATIO / 100
                     + (CASE
                            WHEN V_MINFEEAMT >
                                     (  FO.QUOTEPRICE
                                      * 1000
                                      * FO.QUANTITY
                                      * V_DEFFEERATE
                                      / 100)
                            THEN
                                V_MINFEEAMT
                            ELSE
                                (  FO.QUOTEPRICE
                                 * 1000
                                 * FO.QUANTITY
                                 * V_DEFFEERATE
                                 / 100)
                        END)
                     - OD.ORDERQTTY * OD.QUOTEPRICE * OD.BRATIO/100--TL.MSGAMTTL.MSGAMT
                     - GREATEST(GETAVLPP(AF.ACCTNO)-NVL(HM.HLDAMT,0),0)
                     + GREATEST(CI.DEPOFEEAMT-CI.HOLDBALANCE,0),
                     0) end
                     HOLDAMT,
                    FO.EXECTYPE
                 || '.'
                 || FO.SYMBOL
                 || ': '
                 || TO_CHAR (FO.QUANTITY)
                 || '@'
                 || DECODE (FO.PRICETYPE,
                            'LO', TO_CHAR (FO.QUOTEPRICE),
                            FO.PRICETYPE)
          FROM   FOMAST FO,
                 AFMAST AF,
                 CIMAST CI,
                 ODMAST OD,
                 TLLOG TL,
                (
                    SELECT NVL(SUM(A.HLDAMT),0) HLDAMT,A.AFACCTNO FROM
                    (
                        SELECT NVL(SUM(REQ.TXAMT),0) HLDAMT,REQ.AFACCTNO
                        FROM crbtxreq REQ
                        WHERE REQ.TRFCODE='HOLD' AND REQ.STATUS='P'
                        GROUP BY REQ.AFACCTNO
                        UNION ALL
                        SELECT NVL(SUM(RQ.MSGAMT),0) HLDAMT,RQ.MSGACCT AFACCTNO
                        FROM BORQSLOG RQ WHERE RQ.STATUS='H'
                        GROUP BY MSGACCT
                    ) A GROUP BY A.AFACCTNO
                  ) HM
         WHERE       FO.ACCTNO = p_FOORDERID
                 AND FO.AFACCTNO = AF.ACCTNO
                 AND CI.AFACCTNO = AF.ACCTNO
                 AND FO.REFACCTNO = OD.ORDERID
                 AND OD.TXNUM = TL.TXNUM
                 AND OD.DELTD <> 'Y'
                 AND FO.EXECTYPE IN ('AB')
                 --AND FO.TIMETYPE <> 'G'
                 AND FO.AFACCTNO=HM.AFACCTNO(+);

        --in vao bang crbtxreq
        IF V_HOLDAMT > 0
        THEN
            --Lam giao dich 6640
            PLOG.DEBUG (PKGCTX, 'Begin transaction 6640');
            V_TLTXCD := '6640';

            SELECT   TXDESC, EN_TXDESC
              INTO   V_STRDESC, V_STREN_DESC
              FROM   TLTX
             WHERE   TLTXCD = V_TLTXCD;

            SELECT   VARVALUE
              INTO   V_STRCURRDATE
              FROM   SYSVAR
             WHERE   GRNAME = 'SYSTEM' AND VARNAME = 'CURRDATE';

            SELECT   SYSTEMNUMS.C_BATCH_PREFIXED
                     || LPAD (SEQ_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO   L_TXMSG.TXNUM
              FROM   DUAL;

            PLOG.DEBUG (PKGCTX, 'Msg 6640 txNum:' || L_TXMSG.TXNUM);

            L_TXMSG.BRID := SUBSTR (V_AFACCTNO, 1, 4);

            L_TXMSG.MSGTYPE := 'T';
            L_TXMSG.LOCAL := 'N';
            L_TXMSG.TLID := SYSTEMNUMS.C_SYSTEM_USERID;

            SELECT   SYS_CONTEXT ('USERENV', 'HOST'),
                     SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
              INTO   L_TXMSG.WSNAME, L_TXMSG.IPADDRESS
              FROM   DUAL;

            L_TXMSG.OFF_LINE := 'N';
            L_TXMSG.DELTD := TXNUMS.C_DELTD_TXNORMAL;
            L_TXMSG.TXSTATUS := TXSTATUSNUMS.C_TXCOMPLETED;
            L_TXMSG.MSGSTS := '0';
            L_TXMSG.OVRSTS := '0';
            L_TXMSG.BATCHNAME := 'BANK';
            L_TXMSG.TXDATE :=
                TO_DATE (V_STRCURRDATE, SYSTEMNUMS.C_DATE_FORMAT);
            L_TXMSG.BUSDATE :=
                TO_DATE (V_STRCURRDATE, SYSTEMNUMS.C_DATE_FORMAT);
            L_TXMSG.TLTXCD := V_TLTXCD;

            SELECT   TXDESC, EN_TXDESC
              INTO   V_STRDESC, V_STREN_DESC
              FROM   TLTX
             WHERE   TLTXCD = V_TLTXCD;

            FOR REC
            IN (SELECT   CF.CUSTODYCD,
                         CF.FULLNAME,
                         CF.ADDRESS,
                         CF.IDCODE LICENSE,
                         AF.CAREBY,
                         AF.BANKACCTNO,
                         AF.BANKNAME || ':' || CRB.BANKNAME BANKNAME,
                         0 BANKAVAIL,
                         CI.HOLDBALANCE BANKHOLDED,
                         GETAVLPP (AF.ACCTNO) AVLRELEASE,
                         CI.HOLDBALANCE HOLDAMT
                  FROM   AFMAST AF,
                         CFMAST CF,
                         CIMAST CI,
                         CRBDEFBANK CRB
                 WHERE       AF.CUSTID = CF.CUSTID
                         AND CI.AFACCTNO = AF.ACCTNO
                         AND AF.BANKNAME = CRB.BANKCODE
                         AND AF.ACCTNO = V_AFACCTNO)
            LOOP
                L_TXMSG.TXFIELDS ('88').DEFNAME := 'CUSTODYCD';
                L_TXMSG.TXFIELDS ('88').TYPE := 'C';
                L_TXMSG.TXFIELDS ('88').VALUE := REC.CUSTODYCD;

                L_TXMSG.TXFIELDS ('03').DEFNAME := 'SECACCOUNT';
                L_TXMSG.TXFIELDS ('03').TYPE := 'C';
                L_TXMSG.TXFIELDS ('03').VALUE := V_AFACCTNO;

                L_TXMSG.TXFIELDS ('90').DEFNAME := 'CUSTNAME';
                L_TXMSG.TXFIELDS ('90').TYPE := 'C';
                L_TXMSG.TXFIELDS ('90').VALUE := REC.FULLNAME;

                L_TXMSG.TXFIELDS ('91').DEFNAME := 'ADDRESS';
                L_TXMSG.TXFIELDS ('91').TYPE := 'C';
                L_TXMSG.TXFIELDS ('91').VALUE := REC.ADDRESS;

                L_TXMSG.TXFIELDS ('92').DEFNAME := 'LICENSE';
                L_TXMSG.TXFIELDS ('92').TYPE := 'C';
                L_TXMSG.TXFIELDS ('92').VALUE := REC.LICENSE;

                L_TXMSG.TXFIELDS ('97').DEFNAME := 'CAREBY';
                L_TXMSG.TXFIELDS ('97').TYPE := 'C';
                L_TXMSG.TXFIELDS ('97').VALUE := REC.CAREBY;

                L_TXMSG.TXFIELDS ('93').DEFNAME := 'BANKACCT';
                L_TXMSG.TXFIELDS ('93').TYPE := 'C';
                L_TXMSG.TXFIELDS ('93').VALUE := REC.BANKACCTNO;

                L_TXMSG.TXFIELDS ('95').DEFNAME := 'BANKNAME';
                L_TXMSG.TXFIELDS ('95').TYPE := 'C';
                L_TXMSG.TXFIELDS ('95').VALUE := REC.BANKNAME;

                L_TXMSG.TXFIELDS ('11').DEFNAME := 'BANKAVAIL';
                L_TXMSG.TXFIELDS ('11').TYPE := 'N';
                L_TXMSG.TXFIELDS ('11').VALUE := REC.BANKAVAIL;

                L_TXMSG.TXFIELDS ('12').DEFNAME := 'BANKHOLDED';
                L_TXMSG.TXFIELDS ('12').TYPE := 'N';
                L_TXMSG.TXFIELDS ('12').VALUE := REC.BANKHOLDED;

                L_TXMSG.TXFIELDS ('13').DEFNAME := 'AVLRELEASE';
                L_TXMSG.TXFIELDS ('13').TYPE := 'N';
                L_TXMSG.TXFIELDS ('13').VALUE := REC.AVLRELEASE;

                L_TXMSG.TXFIELDS ('96').DEFNAME := 'HOLDAMT';
                L_TXMSG.TXFIELDS ('96').TYPE := 'N';
                L_TXMSG.TXFIELDS ('96').VALUE := REC.HOLDAMT;

                L_TXMSG.TXFIELDS ('10').DEFNAME := 'AMOUNT';
                L_TXMSG.TXFIELDS ('10').TYPE := 'N';
                L_TXMSG.TXFIELDS ('10').VALUE := V_HOLDAMT;

                L_TXMSG.TXFIELDS ('30').DEFNAME := 'DESC';
                L_TXMSG.TXFIELDS ('30').TYPE := 'C';
                L_TXMSG.TXFIELDS ('30').VALUE := V_STRDESC;
            END LOOP;



            BEGIN
                IF TXPKS_#6640.FN_BATCHTXPROCESS (L_TXMSG,
                                                  P_ERR_CODE,
                                                  L_ERR_PARAM) <>
                       SYSTEMNUMS.C_SUCCESS
                THEN
                    PLOG.DEBUG (PKGCTX, 'got error 6640: ' || P_ERR_CODE);
                    ROLLBACK;
                    RETURN;
                END IF;
            END;

            --T?o y?c?u HOLD g?i sang Bank. REFCODE=ORDERID
            INSERT INTO CRBTXREQ (REQID,
                                  OBJTYPE,
                                  OBJNAME,
                                  TRFCODE,
                                  REFCODE,
                                  OBJKEY,
                                  TXDATE,
                                  AFFECTDATE,
                                  BANKCODE,
                                  BANKACCT,
                                  AFACCTNO,
                                  TXAMT,
                                  STATUS,
                                  REFTXNUM,
                                  REFTXDATE,
                                  REFVAL,
                                  NOTES)
                SELECT   SEQ_CRBTXREQ.NEXTVAL,
                         'V',
                         'FOMAST',
                         'HOLD',
                         V_ORDERID,
                         V_ORDERID,
                         V_TXDATE,
                         V_TXDATE,
                         V_BANKCODE,
                         V_BANKACCT,
                         V_AFACCTNO,
                         V_HOLDAMT,
                         'P',
                         NULL,
                         NULL,
                         NULL,
                         V_NOTES
                  FROM   DUAL;
        ELSE
            --cap nhat trang thai thanh P
            UPDATE   FOMAST
               SET   STATUS = 'P', DIRECT = 'N'
             WHERE   ACCTNO = V_ORDERID;
        END IF;

        COMMIT;
        PLOG.SETENDSECTION (PKGCTX, 'pr_fo_fobannk2od');
    --okie
    EXCEPTION
        WHEN OTHERS
        THEN
            PLOG.ERROR (PKGCTX, SQLERRM);
            PLOG.SETENDSECTION (PKGCTX, 'pr_fo_fobannk2od');
    END PR_FO_FOBANNK2OD;

-- Lay thong tin lenh giao dich
-- TheNN, 06-Jan-2012
PROCEDURE pr_GetOrder
    (p_REFCURSOR    IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN  VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2,
     STATUS         IN  VARCHAR2,
     P_TLID         IN  VARCHAR2 DEFAULT 'ALL'
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_SYMBOL      VARCHAR2(20);
    V_CUSTID      VARCHAR2(10);
    V_STATUS      VARCHAR2(2);
    V_EXECTYPE    VARCHAR2(2);
    V_STRTLID     VARCHAR2(10);

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;
    PLOG.SETBEGINSECTION (PKGCTX, 'pr_GetOrder');

    /*PLOG.Error (PKGCTX, 'Input Param CUSTODYCD:' || CUSTODYCD);
    PLOG.Error (PKGCTX, 'Input Param AFACCTNO:' || AFACCTNO);
    PLOG.Error (PKGCTX, 'Input Param F_DATE:' || F_DATE);
    PLOG.Error (PKGCTX, 'Input Param T_DATE:' || T_DATE);
    PLOG.Error (PKGCTX, 'Input Param SYMBOL:' || SYMBOL);
    PLOG.Error (PKGCTX, 'Input Param EXECTYPE:' || EXECTYPE);
    PLOG.Error (PKGCTX, 'Input Param STATUS:' || STATUS);
    PLOG.Error (PKGCTX, 'Input Param P_TLID:' || P_TLID);*/

    IF SYMBOL = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF EXECTYPE = 'ALL' OR EXECTYPE IS NULL THEN
        V_EXECTYPE := '%%';
    ELSE
        V_EXECTYPE := EXECTYPE;
    END IF;

    IF STATUS = 'ALL' OR STATUS IS NULL THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;

    IF (P_TLID IS NULL OR UPPER(P_TLID) = 'ALL') THEN
        V_STRTLID := '%';
    ELSE
        V_STRTLID := P_TLID;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;


    /*PLOG.Error (PKGCTX, 'Input Param V_SYMBOL:' || V_SYMBOL);
    PLOG.Error (PKGCTX, 'Input Param V_AFACCTNO:' || V_AFACCTNO);
    PLOG.Error (PKGCTX, 'Input Param V_EXECTYPE:' || V_EXECTYPE);
    PLOG.Error (PKGCTX, 'Input Param V_STATUS:' || V_STATUS);
    PLOG.Error (PKGCTX, 'Input Param V_STRTLID:' || V_STRTLID);
    PLOG.Error (PKGCTX, 'Input Param EXECTYPE:' || EXECTYPE);
    PLOG.Error (PKGCTX, 'Input Param V_CUSTID:' || V_CUSTID);*/
    IF V_CUSTID = '%%' and V_AFACCTNO = '%%' THEN
        -- LAY THONG TIN DANH MUC DAU TU
        OPEN p_REFCURSOR FOR
            SELECT CF.CUSTODYCD,OD.AFACCTNO, OD.ORDERID, OD.TXDATE, SB.SYMBOL, A1.CDCONTENT TRADEPLACE, A2.CDCONTENT VIA,
                OD.EXECTYPE, OD.ORDERQTTY, (CASE WHEN OD.PRICETYPE IN ('ATO','ATC','MP','MTL','MOK','MAK','SBO','OBO') THEN TO_CHAR(OD.PRICETYPE) ELSE TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE,
                OD.EXECQTTY, CASE WHEN OD.EXECQTTY>0 THEN ROUND(OD.EXECAMT/OD.EXECQTTY) ELSE 0 END EXECPRICE, OD.EXECAMT,
                A3.CDCONTENT ORSTATUS,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100
                    WHEN OD.EXECAMT >0 AND OD.FEEACR >0 THEN OD.FEEACR
                    ELSE (OD.REMAINQTTY*OD.QUOTEPRICE + OD.EXECAMT)*ODT.DEFFEERATE/100 END FEEACR,
                '' CMSFEE, CASE WHEN OD.EXECAMT >0 AND INSTR(OD.EXECTYPE,'S')>0 AND OD.STSSTATUS = 'N'
                                THEN ROUND(OD.EXECAMT*TO_NUMBER(SYS.VARVALUE)/100) ELSE ROUND(OD.EXECAMT*OD.TAXRATE/100) END SELLTAXAMT,
                round(CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN ODT.DEFFEERATE
                    WHEN OD.EXECAMT >0 AND OD.FEEACR >0 THEN OD.FEEACR/OD.EXECAMT*100 ELSE ODT.DEFFEERATE END,4) FEERATE ,OD.QUOTEQTTY,OD.CONFIRMED
              , TL.TLNAME MAKER_NAME,RECUSTID, REFULLNAME
          FROM
                (SELECT MST.*,
                       (CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C'
                            WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A'
                            WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 THEN '5'
                            WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3'
                            when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 AND mst.pricetype = 'MP' then '4'
                            when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10'
                            WHEN MST.REMAINQTTY = 0 AND MST.EXECQTTY=MST.ORDERQTTY AND MST.ORSTATUS = '4' THEN '12' ELSE MST.ORSTATUS END) ORSTATUSVALUE

                  FROM
                        (SELECT OD1.*,'' EDITSTATUS
                         from vw_odmast_all OD1/*,(SELECT * FROM vw_odmast_all WHERE EDSTATUS IN ('C','A')) OD2*/
                         WHERE /*OD1.ORDERID=OD2.REFORDERID(+) AND */substr(OD1.EXECTYPE,1,1) <> 'C'
                         AND substr(OD1.EXECTYPE,1,1) <> 'A' AND od1.edstatus NOT IN ('C','A') --AND OD1.ORSTATUS <>'7'
                         AND OD1.TXDATE = TO_DATE(F_DATE,'DD/MM/YYYY')
                       ) MST
                    ) OD, SBSECURITIES SB, AFMAST AF, ALLCODE A1,TLPROFILES TL, ALLCODE A2, ALLCODE A3, SYSVAR SYS, ODTYPE ODT, CFMAST CF,
                   (SELECT RE.AFACCTNO, MAX( CF.FULLNAME) REFULLNAME ,MAX(CF.CUSTID) reCUSTID
                    FROM reaflnk re, retype ret,cfmast cf
                    WHERE substr( re.reacctno,11) = ret.actype
                    AND substr(re.reacctno,1,10) = cf.custid
                    AND ret.rerole IN ('RM','CS')
                    AND RE.status ='A'
                    GROUP BY AFACCTNO) re
            WHERE OD.CODEID=SB.CODEID AND AF.ACCTNO = OD.AFACCTNO AND AF.CUSTID= CF.CUSTID
                AND OD.ACTYPE = ODT.ACTYPE AND OD.TLID=TL.TLID
                AND A1.CDTYPE = 'SE' AND A1.CDNAME = 'TRADEPLACE' AND A1.CDVAL = SB.TRADEPLACE
                AND A2.CDTYPE = 'SA' AND A2.CDNAME = 'VIA' AND A2.CDVAL = OD.VIA
                AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'ORSTATUS' AND A3.CDVAL = OD.ORSTATUSVALUE
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND AF.custid = RE.AFACCTNO(+)
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                -- Change from ORSTATUS to ORSTATUSVALUE
                AND OD.ORSTATUSVALUE LIKE V_STATUS
                AND OD.EXECTYPE LIKE V_EXECTYPE
                AND OD.TXDATE = TO_DATE(F_DATE,'DD/MM/YYYY')
                --AND OD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                AND EXISTS(SELECT *
                                FROM tlgrpusers tl, tlgroups gr
                                WHERE AF.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE V_STRTLID
                                )
            ORDER BY OD.TXDATE DESC, SUBSTR(OD.ORDERID,11,6) DESC;
    else
        -- LAY THONG TIN DANH MUC DAU TU
        OPEN p_REFCURSOR FOR
            SELECT CF.CUSTODYCD,OD.AFACCTNO, OD.ORDERID, OD.TXDATE, SB.SYMBOL, A1.CDCONTENT TRADEPLACE, A2.CDCONTENT VIA,
                OD.EXECTYPE, OD.ORDERQTTY, (CASE WHEN OD.PRICETYPE IN ('ATO','ATC','MP','MTL','MOK','MAK','SBO','OBO') THEN TO_CHAR(OD.PRICETYPE) ELSE TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE,
                OD.EXECQTTY, CASE WHEN OD.EXECQTTY>0 THEN ROUND(OD.EXECAMT/OD.EXECQTTY) ELSE 0 END EXECPRICE, OD.EXECAMT,
                A3.CDCONTENT ORSTATUS,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100
                    WHEN OD.EXECAMT >0 AND OD.FEEACR >0 THEN OD.FEEACR
                    ELSE (OD.REMAINQTTY*OD.QUOTEPRICE + OD.EXECAMT)*ODT.DEFFEERATE/100 END FEEACR,
                '' CMSFEE, CASE WHEN OD.EXECAMT >0 AND INSTR(OD.EXECTYPE,'S')>0 AND OD.STSSTATUS = 'N'
                                THEN ROUND(OD.EXECAMT*TO_NUMBER(SYS.VARVALUE)/100) ELSE ROUND(OD.EXECAMT*OD.TAXRATE/100) END SELLTAXAMT,
                round(CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN ODT.DEFFEERATE
                    WHEN OD.EXECAMT >0 AND OD.FEEACR >0 THEN OD.FEEACR/OD.EXECAMT*100 ELSE ODT.DEFFEERATE END,4) FEERATE ,OD.QUOTEQTTY,OD.CONFIRMED
           , TL.TLNAME MAKER_NAME,RECUSTID, REFULLNAME
         FROM
                (SELECT MST.*,
                       (CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C'
                            WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A'
                            WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 THEN '5'
                            WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3'
                            when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 AND mst.pricetype = 'MP' then '4'
                            when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10'
                            WHEN MST.REMAINQTTY = 0 AND MST.EXECQTTY=MST.ORDERQTTY AND MST.ORSTATUS = '4' THEN '12' ELSE MST.ORSTATUS END) ORSTATUSVALUE
                    FROM
                        (SELECT OD1.*,OD2.EDSTATUS EDITSTATUS
                         from vw_odmast_all OD1,(SELECT * FROM vw_odmast_all WHERE EDSTATUS IN ('C','A')) OD2
                         WHERE OD1.ORDERID=OD2.REFORDERID(+) AND substr(OD1.EXECTYPE,1,1) <> 'C'
                         AND substr(OD1.EXECTYPE,1,1) <> 'A' AND od1.edstatus NOT IN ('C','A') --AND OD1.ORSTATUS <>'7'
                       ) MST
                    ) OD, SBSECURITIES SB, AFMAST AF, ALLCODE A1,TLPROFILES TL, ALLCODE A2, ALLCODE A3, SYSVAR SYS, ODTYPE ODT, CFMAST CF,
                      (SELECT RE.AFACCTNO, MAX( CF.FULLNAME) REFULLNAME ,MAX(CF.CUSTID) reCUSTID
                    FROM reaflnk re, retype ret,cfmast cf
                    WHERE substr( re.reacctno,11) = ret.actype
                    AND substr(re.reacctno,1,10) = cf.custid
                    AND ret.rerole IN ('RM','CS')
                    AND RE.status ='A'
                    GROUP BY AFACCTNO) re,
                    (
                        SELECT DISTINCT tl.grpid careby FROM tlgrpusers tl, tlgroups gr
                        WHERE  tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE V_STRTLID
                    ) cb
            WHERE OD.CODEID=SB.CODEID AND AF.ACCTNO = OD.AFACCTNO AND AF.CUSTID= CF.CUSTID
                AND OD.ACTYPE = ODT.ACTYPE AND OD.TLID=TL.TLID
                AND A1.CDTYPE = 'SE' AND A1.CDNAME = 'TRADEPLACE' AND A1.CDVAL = SB.TRADEPLACE
                AND A2.CDTYPE = 'SA' AND A2.CDNAME = 'VIA' AND A2.CDVAL = OD.VIA
                AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'ORSTATUS' AND A3.CDVAL = OD.ORSTATUSVALUE
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND AF.custid = RE.AFACCTNO(+)
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                -- Change from ORSTATUS to ORSTATUSVALUE
                AND OD.ORSTATUSVALUE LIKE V_STATUS
                AND OD.EXECTYPE LIKE V_EXECTYPE
                AND OD.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND OD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                and AF.careby = cb.careby
                /*AND EXISTS(SELECT *
                                FROM tlgrpusers tl, tlgroups gr
                                WHERE AF.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE V_STRTLID
                                )*/
            ORDER BY OD.TXDATE DESC, SUBSTR(OD.ORDERID,11,6) DESC;
    end if;
    PLOG.SETENDSECTION (PKGCTX, 'pr_GetOrder');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetOrder');
END pr_GetOrder;

-- Lay thong tin lenh dieu kien
-- TheNN, 11-Jan-2012
PROCEDURE pr_GetGTCOrder
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     STATUS         IN  VARCHAR2)
    IS

    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_SYMBOL      VARCHAR2(20);
    V_CUSTID      VARCHAR2(10);
    V_STATUS      VARCHAR2(2);
    V_EXECTYPE    VARCHAR2(2);

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;

    IF SYMBOL = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF EXECTYPE = 'ALL' OR EXECTYPE IS NULL THEN
        V_EXECTYPE := '%%';
    ELSE
        V_EXECTYPE := EXECTYPE;
    END IF;

    IF STATUS = 'ALL' OR STATUS IS NULL THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;

    -- LAY THONG TIN LENH
    OPEN p_REFCURSOR FOR
        SELECT OD.AFACCTNO, OD.ORDERID, OD.TXDATE, SB.SYMBOL, A1.CDCONTENT TRADEPLACE, A2.CDCONTENT VIA,
            OD.EXECTYPE, OD.ORDERQTTY, (CASE WHEN OD.PRICETYPE IN ('ATO','ATC','MP','MTL','MOK','MAK','SBO','OBO') THEN TO_CHAR(OD.PRICETYPE) ELSE TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE,
            OD.EXECQTTY, CASE WHEN OD.EXECQTTY>0 THEN ROUND(OD.EXECAMT/OD.EXECQTTY) ELSE 0 END EXECPRICE, OD.EXECAMT,
            A3.CDCONTENT ORSTATUS, CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100 ELSE OD.FEEACR END FEEACR,
            '' CMSFEE, CASE WHEN OD.EXECAMT >0 AND INSTR(OD.EXECTYPE,'S')>0 AND OD.STSSTATUS = 'N'
                            THEN ROUND(OD.EXECAMT*TO_NUMBER(SYS.VARVALUE)/100) ELSE ROUND(OD.EXECAMT*OD.TAXRATE/100) END SELLTAXAMT,
            OD.STOPPRICE, OD.LIMITPRICE, OD.EXPRICE, OD.EXPDATE, OD.EXQTTY, OD.REMAINQTTY, OD.CANCELQTTY, OD.ORSTATUSVALUE ,OD.QUOTEQTTY,OD.CONFIRMED
        FROM
            (SELECT MST.*,
                   (CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C'
                        WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A'
                        WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 THEN '5'
                        WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3'
                        when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10'
                        WHEN MST.REMAINQTTY = 0 AND MST.EXECQTTY>0 AND MST.ORSTATUS = '4' THEN '12' ELSE MST.ORSTATUS END) ORSTATUSVALUE
                FROM
                    (SELECT OD1.*,OD2.EDSTATUS EDITSTATUS
                     from vw_odmast_all OD1,(SELECT * FROM vw_odmast_all WHERE EDSTATUS IN ('C','A')) OD2
                     WHERE OD1.ORDERID=OD2.REFORDERID(+) AND substr(OD1.EXECTYPE,1,1) <> 'C'
                     AND substr(OD1.EXECTYPE,1,1) <> 'A' AND OD1.ORSTATUS <>'7' AND OD1.TIMETYPE = 'G'
                   ) MST
            ) OD, SBSECURITIES SB, AFMAST AF, ALLCODE A1, ALLCODE A2, ALLCODE A3, SYSVAR SYS, ODTYPE ODT
        WHERE OD.CODEID=SB.CODEID AND AF.ACCTNO = OD.AFACCTNO
            --AND OD.TIMETYPE = 'G'
            AND OD.ACTYPE = ODT.ACTYPE
            AND A1.CDTYPE = 'SE' AND A1.CDNAME = 'TRADEPLACE' AND A1.CDVAL = SB.TRADEPLACE
            AND A2.CDTYPE = 'SA' AND A2.CDNAME = 'VIA' AND A2.CDVAL = OD.VIA
            AND A3.CDTYPE = 'OD' AND A3.CDNAME = 'ORSTATUS' AND A3.CDVAL = OD.ORSTATUSVALUE
            AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
            AND AF.CUSTID LIKE V_CUSTID
            AND AF.ACCTNO LIKE V_AFACCTNO
            AND SB.SYMBOL LIKE V_SYMBOL
            AND OD.ORSTATUS LIKE V_STATUS
            AND OD.EXECTYPE LIKE V_EXECTYPE
            AND OD.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
            AND OD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
        ORDER BY OD.TXDATE DESC, substr(OD.ORDERID,11,6) DESC;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetGTCOrder');
END pr_GetGTCOrder;

-- Lay thong tin nhat ky giao dich
-- TheNN, 07-Jan-2012
PROCEDURE pr_GetTradeDiary
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2)
    IS

  V_CUSTODYCD   VARCHAR2(10);
  V_AFACCTNO    VARCHAR2(10);
  V_SYMBOL      VARCHAR2(20);
  V_CUSTID      VARCHAR2(10);
  V_EXECTYPE    VARCHAR2(2);
  V_CURRDATE    DATE;

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;

    IF SYMBOL = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF EXECTYPE = 'ALL' OR EXECTYPE IS NULL THEN
        V_EXECTYPE := '%%';
    ELSE
        V_EXECTYPE := EXECTYPE;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;

    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;

    -- LAY THONG TIN NHAT KY GIAO DICH
    OPEN p_REFCURSOR FOR
        SELECT STS.TXDATE, A1.CDCONTENT EXECTYPE, STS.AFACCTNO, STS.ORDERID, STS.CODEID, STS.SYMBOL,
            STS.EXECAMT, STS.EXECQTTY, STS.EXECPRICE, STS.FEEACR, STS.PROFITANDLOSS, STS.COSTPRICE
        FROM
        (
            SELECT OD.TXDATE, OD.EXECTYPE, OD.AFACCTNO, OD.ORDERID, OD.CODEID, SB.SYMBOL, OD.EXECAMT, OD.EXECQTTY,
                ROUND(OD.EXECAMT/OD.EXECQTTY) EXECPRICE,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100 ELSE OD.FEEACR END FEEACR,
                0 PROFITANDLOSS, ROUND(OD.EXECAMT/OD.EXECQTTY) COSTPRICE
            FROM VW_ODMAST_ALL OD, SBSECURITIES SB, AFMAST AF, ODTYPE ODT
            WHERE OD.CODEID = SB.CODEID AND AF.ACCTNO = OD.AFACCTNO
                AND OD.ORSTATUS IN ('4','5','7','12') AND OD.EXECQTTY>0 AND INSTR(OD.EXECTYPE,'B') >0
                AND OD.ACTYPE = ODT.ACTYPE
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                AND OD.EXECTYPE LIKE V_EXECTYPE
                AND OD.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND OD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
            UNION ALL
            SELECT OD.TXDATE, OD.EXECTYPE, OD.AFACCTNO, OD.ORDERID, OD.CODEID, SB.SYMBOL, OD.EXECAMT, OD.EXECQTTY,
                ROUND(OD.EXECAMT/OD.EXECQTTY) EXECPRICE,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100 ELSE OD.FEEACR END FEEACR,
                (STS.AMT - STS.QTTY * (CASE WHEN STS.TXDATE = V_CURRDATE THEN SE.COSTPRICE ELSE STS.COSTPRICE END)) PROFITANDLOSS,
                CASE WHEN STS.TXDATE = V_CURRDATE THEN SE.COSTPRICE ELSE STS.COSTPRICE END COSTPRICE
            FROM VW_STSCHD_ALL STS, SBSECURITIES SB, AFMAST AF, SEMAST SE, VW_ODMAST_ALL OD, ODTYPE ODT
            WHERE OD.CODEID = SB.CODEID AND AF.ACCTNO = OD.AFACCTNO
                AND OD.ORSTATUS IN ('4','5','7','12') AND OD.EXECQTTY>0 AND INSTR(OD.EXECTYPE,'S') >0
                AND OD.ACTYPE = ODT.ACTYPE
                and STS.DUETYPE= 'SS'
                AND STS.acctno = SE.acctno
                AND OD.orderid = STS.orgorderid
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                AND OD.EXECTYPE LIKE V_EXECTYPE
                AND OD.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND OD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
        ) STS, ALLCODE A1
        WHERE A1.CDTYPE = 'OD' AND A1.CDNAME = 'EXECTYPE' AND A1.CDVAL = STS.EXECTYPE
        ORDER BY STS.TXDATE, SUBSTR(STS.ORDERID,11,6) DESC, STS.AFACCTNO, STS.EXECTYPE, STS.SYMBOL;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetTradeDiary');
END pr_GetTradeDiary;

-- Lay thong tin lenh khop
-- TheNN, 07-Jan-2012
PROCEDURE pr_GetMatchOrder
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     P_TLID       IN  VARCHAR2 DEFAULT 'ALL'
     )
    IS

  V_CUSTODYCD   VARCHAR2(10);
  V_AFACCTNO    VARCHAR2(10);
  V_SYMBOL      VARCHAR2(20);
  V_CUSTID      VARCHAR2(10);
  V_EXECTYPE    VARCHAR2(2);
  V_STRTLID     VARCHAR2(10);

BEGIN
    V_CUSTODYCD := CUSTODYCD;

    IF SYMBOL = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF EXECTYPE = 'ALL' OR EXECTYPE IS NULL THEN
        V_EXECTYPE := '%%';
    ELSE
        V_EXECTYPE := EXECTYPE;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;

    IF (P_TLID IS NULL OR UPPER(P_TLID) = 'ALL')THEN
        V_STRTLID := '%';
    ELSE
        V_STRTLID := P_TLID;
    END IF;

    -- LAY THONG TIN LENH KHOP
    OPEN p_REFCURSOR FOR
        SELECT OD.CUSTODYCD,OD.TXDATE, OD.EXECTYPE EXECTYPE, OD.AFACCTNO, OD.ORDERID, OD.CODEID, OD.SYMBOL,
            IOD.MATCHQTTY, IOD.MATCHPRICE, IOD.MATCHQTTY*IOD.MATCHPRICE MATCHAMT,
            ROUND(IOD.MATCHQTTY*IOD.MATCHPRICE*OD.FEERATE) FEEAMT,OD.FEERATE,
            CASE WHEN INSTR(OD.EXECTYPE,'S')>0 and (od.vat ='Y' OR OD.WHTAX = 'Y')  THEN IOD.MATCHQTTY*IOD.MATCHPRICE*OD.TAXRATE ELSE 0 END SELLTAXAMT,
            CASE WHEN INSTR(OD.EXECTYPE,'B')>0 THEN IOD.MATCHQTTY ELSE 0 END RECVQTTY,
            CASE WHEN INSTR(OD.EXECTYPE,'S')>0 THEN IOD.MATCHQTTY ELSE 0 END TRANFQTTY,
            CASE WHEN INSTR(OD.EXECTYPE,'B')>0 THEN IOD.MATCHQTTY*IOD.MATCHPRICE
             + ROUND(IOD.MATCHQTTY*IOD.MATCHPRICE*OD.FEERATE) ELSE 0 END TRANFAMT,
            CASE WHEN INSTR(OD.EXECTYPE,'B')>0 THEN IOD.MATCHQTTY*IOD.MATCHPRICE
                + ROUND(IOD.MATCHQTTY*IOD.MATCHPRICE*OD.FEERATE)
                WHEN INSTR(OD.EXECTYPE,'S')>0 THEN IOD.MATCHQTTY*IOD.MATCHPRICE
                - ROUND(IOD.MATCHQTTY*IOD.MATCHPRICE*OD.FEERATE) - IOD.MATCHQTTY*IOD.MATCHPRICE*OD.TAXRATE ELSE 0 END RECVAMT
        , TL.TLNAME MAKER_NAME,       REFULLNAME , RECUSTID, A1.CDVAL TIMETYPE, A2.CDVAL VIA
        FROM
        (
            SELECT CF.CUSTODYCD,OD.TXDATE, OD.EXECTYPE, OD.AFACCTNO, OD.ORDERID, OD.CODEID, SB.SYMBOL, OD.EXECAMT, OD.EXECQTTY,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN ROUND(ODT.DEFFEERATE/100,5) ELSE ROUND(OD.FEEACR/OD.EXECAMT,5) END FEERATE,
                CASE WHEN OD.EXECAMT >0 AND INSTR(OD.EXECTYPE,'S')>0 AND OD.STSSTATUS = 'N'
                            THEN ROUND(TO_NUMBER( decode(cf.vat,'Y',SYS.VARVALUE,'N',0)+ decode(cf.whtax,'Y',SYS1.VARVALUE,'N',0) )/100,5) ELSE OD.TAXRATE/100 END TAXRATE, cf.vat, cf.whtax , OD.TLID,
                             REFULLNAME , RECUSTID, OD.TIMETYPE, OD.VIA
            FROM VW_ODMAST_ALL OD, SBSECURITIES SB, AFMAST AF, SYSVAR SYS, ODTYPE ODT, cfmast cf, SYSVAR SYS1,
            (SELECT RE.AFACCTNO, MAX( CF.FULLNAME) REFULLNAME ,MAX(CF.CUSTID) reCUSTID
                    FROM reaflnk re, retype ret,cfmast cf
                    WHERE substr( re.reacctno,11) = ret.actype
                    AND substr(re.reacctno,1,10) = cf.custid
                    AND ret.rerole IN ('RM','CS')
                    AND RE.status ='A'
                    GROUP BY AFACCTNO) re
            WHERE OD.CODEID = SB.CODEID AND AF.ACCTNO = OD.AFACCTNO and af.custid = cf.custid
                AND OD.ORSTATUS IN ('4','5','7','12') AND OD.EXECQTTY>0
                AND OD.ACTYPE = ODT.ACTYPE
                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                AND SYS1.GRNAME = 'SYSTEM' AND SYS1.VARNAME = 'WHTAX'
                AND AF.custid = RE.AFACCTNO(+)
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                AND OD.EXECTYPE LIKE V_EXECTYPE
                AND OD.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND OD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                AND EXISTS(
                            SELECT *
                            FROM tlgrpusers tl, tlgroups gr
                            WHERE AF.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE V_STRTLID
                            )
        ) OD, VW_IODS IOD, ALLCODE A1, TLPROFILES TL, ALLCODE A2
        WHERE OD.ORDERID = IOD.ORGORDERID AND OD.TLID=TL.TLID
            AND A1.CDTYPE = 'OD' AND A1.CDNAME = 'TIMETYPE' AND A1.CDVAL = OD.TIMETYPE
            AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'VIA' AND A2.CDVAL = OD.VIA
        ORDER BY OD.TXDATE DESC, SUBSTR(OD.ORDERID,11,6) DESC,OD.AFACCTNO, OD.EXECTYPE, OD.SYMBOL;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetMatchOrder');
END pr_GetMatchOrder;


-- Lay thong tin de lam de nghi UTTB
-- TheNN, 11-Jan-2012
PROCEDURE pr_GetInfor4AdvancePayment
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2
    )
    IS

  V_AFACCTNO    VARCHAR2(10);
  V_CURRDATE    DATE;
  V_AUTOADV     VARCHAR(1);
v_dblCLEARDAY NUMBER;
BEGIN
    V_AFACCTNO := AFACCTNO;

    -- LAY THONG TIN NGAY HIEN TAI
    SELECT GETCURRDATE INTO V_CURRDATE FROM DUAL;
    -- LAY THONG TIN TIEU KHOAN CO TU DONG UT HAY KO
    SELECT AUTOADV INTO V_AUTOADV FROM AFMAST WHERE ACCTNO = V_AFACCTNO;

     --T2-NAMNT
  -- v_dblCLEARDAY:=3;
     select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
 --END-T2-NAMNT

    -- LAY THONG TIN CHO UTTB
    -- NEU TU DONG UT THI LAY LEN THONG TIN TRONG
    /*IF V_AUTOADV = 'Y' THEN
        OPEN p_REFCURSOR FOR
            SELECT STS.*, STS.DUEDATE - GETCURRDATE DAYS, STS.AMT-STS.AAMT-STS.FAMT MAXAAMT, 0 PDAAMT,
                0 MINFEEAMT, 0 MAXFEEAMT, 0.00 FEERATE, 0 ADVMINAMT, 0 ADVMAXAMT
            FROM
            (
                SELECT STS.TXDATE, STS.AFACCTNO, (STS.AMT-STS.FEEACR-STS.TAXSELLAMT) AMT, (AAMT) AAMT, (FAMT) FAMT,
                    STS.CLEARDAY, STS.CLEARCD, GETDUEDATE(STS.TXDATE, STS.CLEARCD, '001', STS.CLEARDAY) DUEDATE
                FROM
                (
                    SELECT V_CURRDATE TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR, 0 TAXSELLAMT, 3 CLEARDAY, 'B' CLEARCD
                    FROM DUAL
                    UNION ALL
                    SELECT fn_get_prevdate(V_CURRDATE,1) TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR, 0 TAXSELLAMT, 3 CLEARDAY, 'B' CLEARCD
                    FROM DUAL
                    UNION ALL
                    SELECT fn_get_prevdate(V_CURRDATE,2) TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR, 0 TAXSELLAMT, 3 CLEARDAY, 'B' CLEARCD
                    FROM DUAL
                ) STS
            ) STS
            ORDER BY STS.TXDATE, STS.AFACCTNO;
    ELSE*/
        OPEN p_REFCURSOR FOR
            SELECT STS.*, STS.DUEDATE - GETCURRDATE DAYS, STS.AMT-STS.AAMT-STS.FAMT MAXAAMT, 0 PDAAMT,
                AD.ADVMINFEE MINFEEAMT, AD.ADVMAXFEE MAXFEEAMT , AD.ADVRATE FEERATE, AD.ADVMINAMT, AD.ADVMAXAMT ADVMAXAMT, V_AUTOADV AUTOADV
            FROM
            (   --ngoc.vu-Jira561
                SELECT STS.TXDATE, STS.AFACCTNO, SUM(STS.EXECAMT-STS.FEEACR-STS.TAXSELLAMT-STS.RIGHTTAX) AMT, SUM(AAMT) AAMT, SUM(FAMT) FAMT,
                    STS.CLEARDAY, STS.CLEARCD, GETDUEDATE(STS.TXDATE, STS.CLEARCD, /* '001'*/max(sts.tradeplace), STS.CLEARDAY) DUEDATE, SUM(GREATEST(MAXAVLAMT-ROUND(DEALPAID,0),0)) MAXAVLAMT
                FROM
                (
                    SELECT STS.TXDATE, STS.ACCTNO AFACCTNO,STS.AMT, STS.AAMT, STS.FAMT,STS.EXECAMT, STS.RIGHTTAX, STS.brkfeeamt FEEACR, STS.incometaxamt TAXSELLAMT, STS.CLEARDAY, STS.CLEARCD,STS.MAXAVLAMT,
                    (CASE WHEN STS.TXDATE =TO_DATE(SYS.VARVALUE,'DD/MM/RRRR') THEN fn_getdealgrppaid(STS.ACCTNO) ELSE 0 END)*
                    (1+ADT.ADVRATE/100/360*STS.days) DEALPAID, STS.TRADEPLACE
                    FROM vw_advanceschedule STS,AFMAST AF, AFTYPE AFT ,ADTYPE ADT, SYSVAR SYS
                    WHERE STS.ACCTNO = V_AFACCTNO
                    AND AF.ACCTNO=STS.ACCTNO
                    AND STS.ISVSD='N'
                    AND SYS.GRNAME='SYSTEM'
                    AND SYS.VARNAME ='CURRDATE'
                    AND AF.ACTYPE=AFT.ACTYPE
                    AND AFT.ADTYPE=ADT.ACTYPE
                    /*WHERE STS.
                    FROM STSCHD STS,
                        (
                           SELECT OD.ORDERID,
                                CASE WHEN OD.FEEACR >0 THEN OD.FEEACR ELSE OD.EXECAMT*(OD.BRATIO-100)/100 END FEEACR,
                                CASE WHEN OD.TAXSELLAMT >0 THEN OD.TAXSELLAMT ELSE OD.EXECAMT*TO_NUMBER(SYS.VARVALUE)/100 END TAXSELLAMT
                            FROM ODMAST OD, SYSVAR SYS,
                            (SELECT DISTINCT OD.ORDERID, od.ISVSD FROM ODMAPEXT OD where OD.ISVSD='N'
                            UNION all
                            SELECT DISTINCT od.ORDERID, od.ISVSD FROM ODMAPEXTHIST OD where OD.ISVSD='N') ODMAP
                            WHERE INSTR(OD.EXECTYPE,'S')>0 AND OD.EXECAMT >0 --AND OD.MATCHTYPE <> 'P'
                                AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                                AND ODMAP.ORDERID=OD.ORDERID
                        ) OD
                    WHERE STS.ORGORDERID = OD.ORDERID
                        AND STS.DUETYPE = 'RM' AND STS.STATUS = 'N'
                        AND STS.AFACCTNO = V_AFACCTNO*/
                  /*  UNION ALL
                    SELECT V_CURRDATE TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, 3 CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID
                    FROM DUAL
                    UNION ALL
                    SELECT fn_get_prevdate(V_CURRDATE,1) TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, 3 CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID
                    FROM DUAL
                    UNION ALL
                    SELECT fn_get_prevdate(V_CURRDATE,2) TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, 3 CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID
                    FROM DUAL
                    UNION ALL
                    SELECT V_CURRDATE TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, 1 CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID
                    FROM DUAL*/

                    UNION ALL
                    SELECT V_CURRDATE TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, v_dblCLEARDAY CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID, '001' TRADEPLACE
                    FROM DUAL
                    UNION ALL
                    SELECT fn_get_prevdate(V_CURRDATE,1) TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, v_dblCLEARDAY CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID, '001' TRADEPLACE
                    FROM DUAL
                    /*UNION ALL
                    SELECT V_CURRDATE TXDATE, V_AFACCTNO AFACCTNO, 0 AMT, 0 AAMT, 0 FAMT, 0 FEEACR,0 EXECAMT,0 RIGHTTAX, 0 TAXSELLAMT, 1 CLEARDAY, 'B' CLEARCD,0 MAXAVLAMT,0 DEALPAID, '001' TRADEPLACE
                    FROM DUAL*/
                ) STS
                GROUP BY STS.TXDATE, STS.AFACCTNO, STS.CLEARDAY, STS.CLEARCD

            ) STS,
            (
                SELECT AF.ACCTNO, AF.ACTYPE AFTYPE, AD.ACTYPE ADTYPE, AD.ADVMINFEE, AD.ADVMAXFEE, AD.ADVRATE, AD.ADVMINAMT, AD.ADVMAXAMT
                FROM AFTYPE AFT, AFMAST AF, ADTYPE AD
                WHERE AFT.ACTYPE = AF.ACTYPE AND AFT.ADTYPE = AD.ACTYPE
                    AND AF.ACCTNO = V_AFACCTNO
            ) AD
            WHERE STS.AFACCTNO = AD.ACCTNO
             ORDER BY STS.TXDATE, STS.CLEARDAY DESC, STS.AFACCTNO;
    --END IF;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetInfor4AdvancePayment');
END pr_GetInfor4AdvancePayment;

-- Lay thong tin sao ke tien
-- TheNN, 11-Jan-2012
PROCEDURE pr_GetCashStatement
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN       VARCHAR2,
     T_DATE         IN       VARCHAR2
    )
    IS
    -- Tam thoi lay giong het bao cao CF1002
    v_FromDate date;
    v_ToDate date;
    v_CurrDate date;
    v_AFAcctno varchar2(20);
    v_maxciautoid number;
BEGIN
    v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
    v_ToDate:= to_date(T_DATE,'DD/MM/RRRR');
    v_AFAcctno:= upper(replace(AFACCTNO,'.',''));
    BEGIN
        SELECT MAX(autoid) INTO v_maxciautoid FROM citran;
    EXCEPTION WHEN OTHERS THEN
        v_maxciautoid := 999999999999999;
    END;
    select getcurrdate into v_CurrDate from dual;

    OPEN p_REFCURSOR FOR
        select a.autoid, a.afacctno, a.busdate, a.txnum, a.tltxcd,
               case when a.autoid = -1 then 0 else a.ci_credit_amt end ci_credit_amt,
               case when a.autoid = -1 then 0 else a.ci_debit_amt end ci_debit_amt,
               a.txdesc, a.dfaccno, a.ci_begin_bal, a.ci_receiving_bal,
               a.ci_EMKAMT_bal, a.ci_DFDEBTAMT_bal, a.od_buy_secu, a.ci_end_bal,
               case when a.autoid = -1 then a.ci_credit_amt - a.ci_debit_amt
                    else sum(a.ci_credit_amt) over(order by a.odrnum, a.busdate, a.txorder, a.autoid, a.txtype,a.txnum asc)
                            - sum(a.ci_debit_amt) over(order by a.odrnum, a.busdate, a.txorder, a.autoid, a.txtype,a.txnum asc)
                    end ci_avail_bal
        from
        (SELECT 0 odrnum, -1 autoid, ci.acctno afacctno, null busdate, null txnum, null tltxcd,
            case when  ci.balance + nvl(tr.total_period_amt,0) >=0 then  ci.balance + nvl(tr.total_period_amt,0) else 0 end ci_credit_amt,
            case when  ci.balance + nvl(tr.total_period_amt,0) <0 then  ci.balance + nvl(tr.total_period_amt,0) else 0 end ci_debit_amt,
            utf8nums.C_FOPKS_API_begin txdesc, '' dfaccno,
            0 ci_begin_bal,
            0 ci_receiving_bal,
            0 ci_EMKAMT_bal,
            0 ci_DFDEBTAMT_bal,
            0 od_buy_secu,
            0 ci_end_bal,
            0 txorder,
            '' txtype
        from cimast ci, afmast af,
          (select tci.acctno,
                        sum(case when tci.txtype = 'D' then +tci.namt else -tci.namt end) total_period_amt
                    from vw_CITRAN_gen tci
                    where  tci.busdate >= v_FromDate
                       and tci.acctno = v_AFAcctno
                       and tci.field = 'BALANCE'
                    GROUP BY tci.acctno) tr
        where ci.acctno = tr.acctno (+) and ci.acctno =  v_AFAcctno and ci.acctno = af.acctno and af.acctno = v_AFAcctno
            and af.corebank <> 'Y'
        union
        select 1 odrnum, tr.autoid, tr.afacctno, tr.busdate,tr.txnum,tr.tltxcd,
                    ROUND(nvl(ci_credit_amt,0)) ci_credit_amt, ROUND(nvl(ci_debit_amt,0)) ci_debit_amt,
                    case when tr.tltxcd = '1143' and tr.txcd = '0077' then 'So tien den han phai thanh toan'
                         when tr.tltxcd in ('1143','1153') and tr.txcd = '0011' and tr.trdesc is null then 'Phi ung truoc'
                         else to_char(tr.txdesc)
                    end txdesc,
                    case when tr.tltxcd in ('2641','2642','2643','2660','2678','2670') then
                            (case when trim(description) is not null
                                    then nvl(tr.description, ' ')
                                else
                                    tr.dealno
                             end
                            )
                    end dfaccno,
                    ROUND(ci.ci_balance - nvl(ci_move_fromdt.ci_total_move_frdt_amt,0))  ci_begin_bal,
                    ROUND(CI_RECEIVING - nvl(ci_RECEIVING_move,0)) ci_receiving_bal,
                    ROUND(CI_EMKAMT - nvl(ci_EMKAMT_move,0)) ci_EMKAMT_bal,
                    ROUND(CI_DFDEBTAMT - nvl(ci_DFDEBTAMT_move,0)) ci_DFDEBTAMT_bal,
                    ROUND(nvl(secu.od_buy_secu,0)) od_buy_secu,
                    ROUND(ci.ci_balance - nvl(ci_move_fromdt.ci_total_move_frdt_amt,0) + nvl(tr_period.total_period_amt,0)) ci_end_bal,
                    tr.txorder,
                    tr.txtype
                from
                (
                    -- Tong so du CI hien tai group by TK luu ky
                    select ci.afacctno, ci.intbalance ci_balance,
                        ci.RECEIVING CI_RECEIVING,
                        ci.EMKAMT CI_EMKAMT,
                        ci.DFDEBTAMT CI_DFDEBTAMT
                    from buf_ci_account ci, afmast af
                    where ci.afacctno = v_AFAcctno and ci.afacctno = af.acctno and af.acctno = v_AFAcctno
                    and af.corebank <> 'Y'
                ) ci

                left join
                (
                    -- Danh sach giao dich CI: tu From Date den ToDate
                       select tci.autoid orderid, tci.custid, tci.custodycd, tci.acctno afacctno, tci.tllog_autoid autoid,
                        tci.txtype, tci.busdate, nvl(tci.trdesc,tci.txdesc) txdesc,
                        '' symbol, 0 se_credit_amt, 0 se_debit_amt,
                        case when tci.txtype = 'C' then namt else 0 end ci_credit_amt,
                        case when tci.txtype = 'D' then namt else 0 end ci_debit_amt,
                        tci.txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, tci.dfacctno dealno,
                        tci.old_dfacctno description, tci.trdesc, tci.bkdate,
                        CASE WHEN EXISTS(SELECT app.tltxcd FROM appmap app WHERE app.tltxcd = tci.tltxcd and apptype = 'CI' AND apptxcd IN ('0012','0029'))
                            THEN 0 ELSE 1 END txorder
                    from   (
                            select ci.autoid, cf.custodycd, cf.custid,
                            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
                            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                            ci.ref dfacctno,
                            ' ' old_dfacctno,
                            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate
                            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                                    VW_TLLOG_ALL TL, cfmast cf, afmast af, apptx app
                            where   ci.txdate       =    tl.txdate
                            and     ci.txnum        =    tl.txnum
                            and     cf.custid       =    af.custid
                            and     ci.acctno       =    af.acctno
                            and     ci.txcd         =    app.txcd
                            and CI.corebank <> 'Y'
                            and     app.apptype     =    'CI'
                            and     app.txtype      in   ('D','C')
                            and     tl.deltd        <>  'Y'
                            and     ci.deltd        <>  'Y'
                            and     ci.namt         <>  0
                            and tl.tltxcd not in ('6690','6691','6621','6660','6600','6601','6602')
                            UNION ALL
                            SELECT 0 AUTOID, CF.custodycd, cf.custid, TL.txnum, TL.txdate, TL.MSGacct acctno,'D' txcd,
                            (case when TL.TLTXCD = '6668' then tl.msgamt else 0 end) namt,
                            '' camt, '' ref, nvl(TL.deltd, 'N') deltd, TL.MSGacct acctref,
                            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                            '' dfacctno,' ' old_dfacctno,
                            (case when TL.TLTXCD = '6668' then 'C' else 'D' end) txtype, 'BALANCE' field,
                             tl.autoid+1 tllog_autoid,
                            '' trdesc, TL.txdate bkdate
                            FROM VW_TLLOG_ALL TL, cfmast cf, afmast af
                            where   cf.custid       =    af.custid
                            and     TL.MSGacct       =    af.acctno
                            and     tl.deltd        <>  'Y'
                             AND TL.TLTXCD in ('3324','6668')
                            ) tci
                    where  tci.bkdate between v_FromDate and v_ToDate
                       and tci.acctno = v_AFAcctno
                       and tci.field = 'BALANCE'
                       AND TCI.TLTXCD NOT IN ('8855','8865','8856','8866','0066','1144','1145','8889')
                       union all
                       -------Tach giao dich mua ban
                       select  max(tci.autoid) orderid, tci.custid, tci.custodycd, tci.acctno afacctno, max(tci.tllog_autoid) autoid, tci.txtype,
                        tci.busdate, case when TCI.TLTXCD = '8865' then 'Tra tien mua CK ngay' || to_char(max(tci.oddate),'dd/mm/rrrr')
                                        when TCI.TLTXCD = '8889' then 'Tra tien mua CK ngay' || to_char(max(tci.oddate),'dd/mm/rrrr')
                                        when TCI.TLTXCD = '8856' then 'Tra phi ban CK ngay' || to_char(max(tci.oddate),'dd/mm/rrrr')
                                        when TCI.TLTXCD = '8866' then 'Nhan tien ban CK ngay' || to_char(max(tci.oddate),'dd/mm/rrrr')
                                        else  'Tra phi mua CK ngay' || to_char(max(tci.oddate),'dd/mm/rrrr')
                                        end TXDESC,
                         '' symbol, 0 se_credit_amt, 0 se_debit_amt,
                        SUM(case when tci.txtype = 'C' then namt else 0 end) ci_credit_amt,
                        SUM(case when tci.txtype = 'D' then namt else 0 end) ci_debit_amt,
                        '' txnum, '' tltx_name, tci.tltxcd,  tci.txdate, tci.txcd, '' dealno,
                        '' description, '' trdesc, tci.bkdate,
                        CASE WHEN EXISTS(SELECT app.tltxcd FROM appmap app WHERE app.tltxcd = tci.tltxcd and apptype = 'CI' AND apptxcd IN ('0012','0029'))
                            THEN 0 ELSE 1 END txorder
                    from   (select ci.autoid, cf.custodycd, cf.custid,
                            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
                            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                            ci.ref dfacctno,
                            ' ' old_dfacctno,
                            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate, od.txdate oddate
                            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                                    vw_odmast_all od,
                                    VW_TLLOG_ALL TL, cfmast cf, afmast af, apptx app --, VW_DFMAST_ALL df
                            where   ci.txdate       =    tl.txdate
                            and     ci.txnum        =    tl.txnum
                            and     cf.custid       =    af.custid
                            and     ci.acctno       =    af.acctno
                            and     ci.txcd         =    app.txcd
                            and     app.apptype     =    'CI'
                            and CI.corebank <> 'Y'
                            and     app.txtype      in   ('D','C')
                            and     tl.deltd        <>  'Y'
                            and     ci.deltd        <>  'Y'
                            and     ci.ref= od.orderid
                            and     ci.namt         <>  0) tci
                    where  tci.bkdate between v_FromDate and v_ToDate
                       and tci.acctno = v_AFAcctno
                       and tci.field = 'BALANCE'
                         AND TCI.TLTXCD IN ('8855','8865','8856','8866','8889')
                         GROUP BY tci.custid, tci.custodycd, tci.acctno ,  tci.txtype, tci.busdate, tci.tltxcd, tci.txcd,tci.txdate,tci.bkdate

                      union all
                       -----Thue TNCN:
                     SELECT max(tci.autoid) orderid,  tci.custid, tci.custodycd, tci.acctno afacctno, max(tci.tllog_autoid) autoid, tci.txtype,
                        tci.busdate, tci.description TXDESC,
                         '' symbol, 0 se_credit_amt, 0 se_debit_amt,
                        SUM(case when tci.txtype = 'C' then namt else 0 end) ci_credit_amt,
                        SUM(case when tci.txtype = 'D' then namt else 0 end) ci_debit_amt,
                        '' txnum, '' tltx_name, tci.tltxcd, tci.txdate, tci.txcd, '' dealno,
                        '' description, '' trdesc, tci.bkdate,
                        CASE WHEN EXISTS(SELECT app.tltxcd FROM appmap app WHERE app.tltxcd = tci.tltxcd and apptype = 'CI' AND apptxcd IN ('0012','0029'))
                            THEN 0 ELSE 1 END txorder
                    from   (
                           select ci.autoid, cf.custodycd, cf.custid,
                            ci.txnum, ci.txdate, ci.acctno, ci.txcd, ci.namt,
                            ci.camt, ci.ref, nvl(ci.deltd, 'N') deltd, ci.acctref,
                            tl.tltxcd, tl.busdate, tl.txdesc, tl.txtime, tl.brid, tl.tlid, tl.offid, tl.chid,
                            ci.ref dfacctno,
                            ' ' old_dfacctno,
                            app.txtype, app.field, tl.autoid tllog_autoid, ci.trdesc, nvl(ci.bkdate, ci.txdate) bkdate,
                            CASE WHEN ci.txcd = '0011' THEN tl.txdesc
                                 WHEN ci.txcd = '0028' THEN ci.trdesc || ' Ngay' || substr(tl.txdesc, length(tl.txdesc) -10, 10)
                                 END description
                            from    (SELECT * FROM CITRAN UNION ALL SELECT * FROM CITRANA) CI,
                                    VW_TLLOG_ALL TL, cfmast cf, afmast af, apptx app
                            where   ci.txdate       =    tl.txdate
                            and     ci.txnum        =    tl.txnum
                            and     cf.custid       =    af.custid
                            and     ci.acctno       =    af.acctno
                            and     ci.txcd         =    app.txcd
                            and     app.apptype     =    'CI'
                            and     app.txtype      in   ('D','C')
                            and CI.corebank <> 'Y'
                            and     tl.deltd        <>  'Y'
                            and     ci.deltd        <>  'Y'
                            and     ci.namt         <>  0
                            ) tci
                    where  tci.bkdate between v_FromDate and v_ToDate
                       and tci.acctno = v_AFAcctno
                       and tci.field = 'BALANCE'
                       AND TCI.TLTXCD IN ('0066')
                       GROUP BY tci.custid, tci.custodycd, tci.acctno ,  tci.txtype, tci.busdate, tci.tltxcd,
                       tci.txcd,tci.txdate,tci.bkdate, tci.description
                ) tr on ci.afacctno = tr.afacctno
                left join
                (
                    -- Tong phat sinh tang giam CI: tu From Date den ToDate
                    select tci.acctno,
                        sum(case when tci.txtype = 'D' then -tci.namt else tci.namt end) total_period_amt
                    from vw_CITRAN_gen tci
                    where  tci.busdate between v_FromDate and v_ToDate
                       and tci.acctno = v_AFAcctno
                       and tci.field = 'BALANCE'
                    GROUP BY tci.acctno
                ) tr_period on ci.afacctno = tr_period.acctno

                left join
                (
                    -- Tong phat sinh CI tu From date den ngay hom nay
                    select tr.acctno,
                        sum(case when tr.txtype = 'D' then -tr.namt else tr.namt end) ci_total_move_frdt_amt
                    from vw_CITRAN_gen tr
                    where
                        tr.busdate >= v_FromDate and tr.busdate <= v_CurrDate
                        and tr.acctno = v_AFAcctno
                        and tr.field in ('BALANCE')
                    group by tr.acctno
                ) ci_move_fromdt on ci.afacctno = ci_move_fromdt.acctno

                left join
                (
                    -- Tong phat sinh CI.RECEIVING tu Todate + 1 den ngay hom nay
                    select tr.acctno,
                        sum(
                            case when field = 'RECEIVING' then
                                case when tr.txtype = 'D' then -tr.namt else tr.namt end
                            else 0
                            end
                            ) ci_RECEIVING_move,
                        sum(
                            case when field IN ('EMKAMT') then
                                case when tr.txtype = 'D' then -tr.namt else tr.namt end
                            else 0
                            end
                            ) ci_EMKAMT_move,
                        sum(
                            case when field = 'DFDEBTAMT' then
                                case when tr.txtype = 'D' then -tr.namt else tr.namt end
                            else 0
                            end
                            ) ci_DFDEBTAMT_move
                    from vw_citran_gen tr
                    where
                        tr.busdate > v_ToDate and tr.busdate <= v_CurrDate
                        and tr.acctno = v_AFAcctno
                        and tr.field in ('RECEIVING','EMKAMT','DFDEBTAMT')
                    group by tr.acctno
                ) ci_RECEIV on ci.afacctno = ci_RECEIV.acctno

                left join
                (
                    select v.afacctno,
                        case when v_CurrDate = v_ToDate then secureamt + advamt else 0 end od_buy_secu
                    from v_getbuyorderinfo V
                    where v.afacctno like v_AFAcctno
                ) secu on ci.afacctno = secu.afacctno
        UNION
        SELECT 2 odrnum, (v_maxciautoid + 1)  autoid, v_AFAcctno afaccnto, null busdate, null txnum, null tltxcd,
                0 ci_credit_amt,
                0 ci_debit_amt,
                utf8nums.C_FOPKS_API_END txdesc, '' dfaccno,
                0 ci_begin_bal,
                0 ci_receiving_bal,
                0 ci_EMKAMT_bal,
                0 ci_DFDEBTAMT_bal,
                0 od_buy_secu,
                0 ci_end_bal,
                0 txorder,
                '' txtype
            from dual ) a
        order by a.odrnum desc, a.busdate desc, a.txorder desc, a.autoid desc, a.txtype desc, a.txnum desc;      -- Chu y: Khong thay doi thu tu Order by

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetCashStatement');
END pr_GetCashStatement;


-- Lay thong tin sao ke chung khoan
-- TheNN, 11-Jan-2012
PROCEDURE pr_GetSecuritiesStatement
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2
    )
    IS
    -- Tam thoi lay giong het bao cao CF1000
    v_FromDate date;
    v_ToDate date;
    v_CurrDate date;
    v_AFAcctno varchar2(20);
    V_SYMBOL    VARCHAR2(20);
    V_BEBAL     NUMBER;
    V_ENDBAL    NUMBER;

BEGIN
    v_FromDate:= to_date(F_DATE,'DD/MM/RRRR');
    v_ToDate:= to_date(T_DATE,'DD/MM/RRRR');
    v_AFAcctno:= upper(replace(AFACCTNO,'.',''));
    V_SYMBOL := UPPER(SYMBOL);
    V_BEBAL := 0;
    V_ENDBAL := 0;
    select getcurrdate into v_CurrDate from dual;

    -- NEU 1 MA CK THI LAY SO DU DAU KY VA SO DU CUOI KY
    IF V_SYMBOL = 'ALL'
            OR V_SYMBOL IS NULL
            OR  V_SYMBOL = '%%'
    THEN
        V_SYMBOL := '%%';
    ELSE
        SELECT se.trade - nvl(se_be.se_totalmov_amt,0) be_bal,
            se.trade - nvl(se_be.se_totalmov_amt,0) + nvl(se_period_amt,0) end_bal
        INTO V_BEBAL, V_ENDBAL
        FROM
        (
            SELECT se.afacctno, se.codeid, se.acctno, se.trade + se.mortage + se.blocked + se.secured trade
            FROM semast se, sbsecurities sb
            WHERE se.codeid = sb.codeid
                and se.afacctno = v_AFAcctno
                AND sb.symbol = V_SYMBOL
        ) se
        LEFT JOIN
        (
            select tse.custid, tse.custodycd, tse.afacctno, tse.codeid,to_char(max(tse.symbol)) symbol,
                sum(case when tse.txtype = 'C' then tse.namt else -tse.namt end) se_totalmov_amt
            from vw_setran_gen tse
            where tse.busdate between v_FromDate and v_CurrDate
                and tse.afacctno = v_AFAcctno
                and tse.field in ('TRADE','MORTAGE','BLOCKED')
                and sectype <> '004'
                AND tse.symbol = V_SYMBOL
            group by tse.custid, tse.custodycd, tse.afacctno, tse.codeid
            having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0
        ) se_be
        ON se.afacctno = se_be.afacctno AND se.codeid = se_be.codeid
        LEFT JOIN
        (
            select tse.custid, tse.custodycd, tse.afacctno, tse.codeid,to_char(max(tse.symbol)) symbol,
                sum(case when tse.txtype = 'C' then tse.namt else -tse.namt end) se_period_amt
            from vw_setran_gen tse
            where tse.busdate between v_FromDate and v_ToDate
                and tse.afacctno = v_AFAcctno
                and tse.field in ('TRADE','MORTAGE','BLOCKED')
                and sectype <> '004'
                AND tse.symbol = V_SYMBOL
            group by tse.custid, tse.custodycd, tse.afacctno, tse.codeid
            having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0
        ) se_tr
        ON se.afacctno = se_tr.afacctno AND se.codeid = se_tr.codeid;
    END IF;

    OPEN p_REFCURSOR FOR
    SELECT afaccnto, autoid, busdate, tran_symbol,
           case when odrnum = 2 then se_credit_amt else 0 end se_credit_amt,
           se_debit_amt, txdesc, be_bal, end_bal,
           sum(se_credit_amt) over(order by odrnum, autoid asc)
            - sum(se_debit_amt) over(order by odrnum, autoid asc) avl_bal
    FROM
    (   SELECT 1 odrnum, v_AFAcctno afaccnto, -1 autoid, null busdate, '' tran_symbol, V_BEBAL se_credit_amt,
               0 se_debit_amt, UTF8NUMS.C_FOPKS_API_BEGIN txdesc, V_BEBAL be_bal, V_ENDBAL end_bal, '' txtype, 0 avl_bal
        FROM securities_info
        WHERE SYMBOL = V_SYMBOL
        UNION
        select 2 odrnum, AF.ACCTNO AFACCTNO,
            tr.autoid, tr.busdate, nvl(tr.symbol,' ') tran_symbol,
            nvl(se_credit_amt,0) se_credit_amt, nvl(se_debit_amt,0) se_debit_amt,
            to_char(tr.txdesc) txdesc, V_BEBAL BE_BAL, V_ENDBAL END_BAL, tr.txtype, 0 avl_bal
        from (SELECT * from afmast af WHERE af.acctno = v_AFAcctno) af
        left join
        (
            -- Toan bo phat sinh CK tu FromDate den Todate
            select tse.custid, tse.custodycd, tse.afacctno, max(tse.tllog_autoid) autoid, max(tse.txtype) txtype, max(tse.txcd) txcd ,
                tse.busdate, max(nvl(tse.trdesc,tse.txdesc)) txdesc, to_char(max(tse.symbol)) symbol,
                sum(case when tse.txtype = 'C' then tse.namt else 0 end) se_credit_amt,
                sum(case when tse.txtype = 'D' then tse.namt else 0 end) se_debit_amt,
                0 ci_credit_amt, 0 ci_debit_amt,
                max(tse.tltxcd) tltxcd, max(tse.trdesc) trdesc
            from vw_setran_gen tse
            where tse.busdate between v_FromDate and v_ToDate
                and tse.afacctno = v_AFAcctno
                and tse.field in ('TRADE','MORTAGE','BLOCKED')
                and sectype <> '004'
                AND TSE.symbol LIKE V_SYMBOL
            group by tse.custid, tse.custodycd, tse.afacctno, tse.busdate, to_char(tse.symbol), tse.txdate, tse.txnum
            having sum(case when tse.txtype = 'D' then -tse.namt else tse.namt end) <> 0
        ) tr on af.acctno = tr.afacctno
        UNION
        SELECT 3 odrnum, v_AFAcctno afaccnto, -1 autoid, null busdate, '' tran_symbol, V_BEBAL se_credit_amt,
               0 se_debit_amt, UTF8NUMS.C_FOPKS_API_END txdesc, V_BEBAL be_bal, V_ENDBAL end_bal, '' txtype, 0 avl_bal
        FROM securities_info
        WHERE SYMBOL = V_SYMBOL
    )
    order by odrnum desc, busdate desc, autoid desc, txtype desc;      -- Chu y: Khong thay doi thu tu Order by

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetSecuritiesStatement');
END pr_GetSecuritiesStatement;


-- Lay thong tin giao dich chuyen khoan
-- TheNN, 11-Jan-2012
PROCEDURE pr_GetCashTransfer
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     STATUS         IN  VARCHAR2)
    IS

    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_CUSTID      VARCHAR2(10);
    V_STATUS      VARCHAR2(2);

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF STATUS = 'ALL' OR STATUS IS NULL THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF V_CUSTODYCD = 'ALL' OR V_CUSTODYCD IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;


    -- LAY THONG TIN GD CHUYEN KHOAN
    OPEN p_REFCURSOR FOR
        SELECT *
        FROM
        (
            -- CHUYEN KHOAN RA NGOAI
            SELECT TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.MSGACCT AFACCTNO, TLG.TLTXCD, TLG.MSGAMT TRFAMT, A1.CDCONTENT STATUS,
                TL.TXDESC TRFTYPE, DECODE(TLG.TLTXCD, '1120', '','1130','' ,CIR.BENEFBANK) BENEFBANK, CIR.BENEFCUSTNAME RECVFULLNAME, CF.CUSTODYCD TRFCUSTODYCD, CIR.BENEFACCT RECVAFACCTNO,
                A2.CDCONTENT TRFPLACE, TLG.TXDESC, CIR.BENEFLICENSE, CIR.CITYBANK, CIR.CITYEF, CIR.RMSTATUS,
                CASE WHEN TLG.TLTXCD IN ('1120','1130') THEN '1'
                     WHEN TLG.TLTXCD IN ('1101','1108') THEN '2'
                     ELSE '1' END TRFTYPEVALUE, DECODE(TLG.TLTXCD, '1120', CIR.BENEFBANK, '') RECVCUSTODYCD,
                TLG.AUTOID
            FROM VW_TLLOG_ALL TLG, ALLCODE A1, CFMAST CF, AFMAST AF, CIREMITTANCE CIR, TLTX TL, ALLCODE A2
            WHERE TLG.TXDATE = CIR.TXDATE AND TLG.TXNUM = CIR.TXNUM
                AND CF.CUSTID = AF.CUSTID
                AND TL.TLTXCD = TLG.TLTXCD
                AND A1.CDTYPE = 'CI' AND A1.CDNAME = 'RMSTATUS' AND A1.CDVAL = CIR.RMSTATUS
                AND A2.CDTYPE = 'SA' AND A2.CDNAME = 'VIA' AND A2.CDVAL = DECODE(SUBSTR(TLG.TXNUM,1,2),systemnums.C_OL_PREFIXED,'O','F')
                AND TLG.TLTXCD IN ('1101','1108','1120','1130')
                AND TLG.MSGACCT = AF.ACCTNO
                AND CF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND CIR.RMSTATUS LIKE V_STATUS
                AND TLG.BUSDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND TLG.BUSDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
            /*UNION ALL
            -- CHUYEN KHOAN NOI BO
            SELECT TLG.TXDATE, TLG.BUSDATE, TLG.MSGACCT AFACCTNO, TLG.TLTXCD, TLG.MSGAMT TRFAMT, A1.CDCONTENT STATUS,
                '1' TRFTYPE, '' BENEFBANK, CIR.BENEFCUSTNAME RECVFULLNAME, CIR.BENEFACCT RECVAFACCTNO,
                DECODE(SUBSTR(TLG.TXNUM,1,4),systemnums.C_OL_PREFIXED,'O','F') TRFPLACE
            FROM VW_TLLOG_ALL TLG, ALLCODE A1, AFMAST AF, CIREMITTANCE CIR
            WHERE TLG.TXDATE = CIR.TXDATE AND TLG.TXNUM = CIR.TXNUM
                AND A1.CDTYPE = 'CI' AND A1.CDNAME = 'RMSTATUS' AND A1.CDVAL = CIR.RMSTATUS
                AND TLG.TLTXCD = '1120'
                AND AF.ACCTNO = TLG.MSGACCT
                AND AF.CUSTID LIKE V_CUSTID
                AND TLG.MSGACCT LIKE V_AFACCTNO
                AND CIR.RMSTATUS LIKE V_STATUS
                AND TLG.BUSDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND TLG.BUSDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')*/

        ) TLG
        ORDER BY TLG.TXDATE DESC, TLG.AUTOID DESC, SUBSTR(TLG.TXNUM,5,6) DESC;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetCashTransfer');
END pr_GetCashTransfer;


-- Lay thong tin cac giao dich quyen mua
-- TheNN, 12-Jan-2012
PROCEDURE pr_GetRightOffInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_CUSTID      VARCHAR2(10);

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF V_CUSTODYCD IS NULL OR V_CUSTODYCD = 'ALL' THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;


    -- LAY THONG TIN GD QUYEN MUA
    OPEN p_REFCURSOR FOR
        SELECT * FROM
        (
            -- GD DANG KY QUYEN MUA DANG CHO THUC HIEN
            SELECT RQ.TXDATE, RQ.TXDATE BUSDATE, RQ.TXNUM, '3384' TLTXCD, RQ.MSGACCT, RQ.KEYVALUE, SB.SYMBOL, RQ.MSGQTTY EXECQTTY,
                A2.CDCONTENT TXSTATUS, 'Dang ky quyen mua' EXECTYPE, RQ.AUTOID TLLOG_AUTOID
            FROM BORQSLOG RQ, ALLCODE A2, CAMAST CA, SBSECURITIES SB, AFMAST AF
            WHERE RQ.STATUS IN ('P','W','H')
                AND CA.CAMASTID = RQ.KEYVALUE AND CA.TOCODEID = SB.CODEID
                AND RQ.MSGACCT = AF.ACCTNO
                AND A2.CDTYPE = 'SA' AND A2.CDNAME = 'BORQSLOGSTS' AND A2.CDVAL = RQ.STATUS
                AND RQ.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                AND RQ.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                AND AF.CUSTID LIKE V_CUSTID
                AND RQ.MSGACCT LIKE V_AFACCTNO

            UNION ALL
            -- CAC GD DA THUC HIEN
            SELECT CA.TXDATE, CA.BUSDATE, CA.TXNUM, CA.TLTXCD, CA.AFACCTNO, CA.CAMASTID, SB.SYMBOL, CA.EXECQTTY,
                A1.CDCONTENT TXSTATUS, CA.EXECTYPE, CA.TLLOG_AUTOID
            FROM
            (

                -- GD DANG KY QUYEN MUA
                SELECT CA.TOCODEID,TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.TLTXCD, TLG.ACCTNO AFACCTNO, CA.CAMASTID, CA.CODEID, TLG.NAMT/CA.EXPRICE EXECQTTY,
                    '1' TXSTATUS, 'Dang ky quyen mua' EXECTYPE, TLG.TLLOG_AUTOID
                FROM
                    (SELECT * FROM VW_CITRAN_GEN TLG
                        WHERE TLG.TLTXCD = '3384' AND TLG.DELTD = 'N' AND TLG.TXCD = '0028'
                            AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    ) TLG, CAMAST CA,CASCHD CAS
                WHERE CAS.AUTOID = TLG.ACCTREF
                    AND TLG.CUSTID LIKE V_CUSTID
                    AND TLG.ACCTNO LIKE V_AFACCTNO
                    AND CAS.CAMASTID=CA.CAMASTID
                UNION ALL
                -- GD NHAN CHUYEN NHUONG QUYEN MUA
                SELECT CA.TOCODEID,TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.TLTXCD, SUBSTR(TLG.ACCTNO,1,10) AFACCTNO, CA.CAMASTID, CA.CODEID, TLG.NAMT EXECQTTY,
                    '1' TXSTATUS, 'Nhan chuyen nhuong quyen mua' EXECTYPE, TLG.TLLOG_AUTOID
                FROM
                    (SELECT * FROM VW_SETRAN_GEN TLG
                        WHERE TLG.TLTXCD IN ('3385','3382') AND TLG.DELTD = 'N' AND TLG.TXCD = '0045'
                            AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    ) TLG, CAMAST CA, AFMAST AF
                WHERE CA.CAMASTID = TLG.REF
                    AND AF.ACCTNO = SUBSTR(TLG.ACCTNO,1,10)
                    AND AF.CUSTID LIKE V_CUSTID
                    AND AF.ACCTNO LIKE V_AFACCTNO

                UNION ALL
                -- GD CHUYEN NHUONG QUYEN RA NGOAI
                SELECT CA.TOCODEID,TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.TLTXCD, SUBSTR(TLG.ACCTNO,1,10) AFACCTNO, CA.CAMASTID, CA.CODEID, TLG.NAMT EXECQTTY,
                    '1' TXSTATUS, 'Chuyen nhuong quyen mua ra ngoai' EXECTYPE, TLG.TLLOG_AUTOID
                FROM
                    (SELECT * FROM VW_SETRAN_GEN TLG
                        WHERE TLG.TLTXCD IN ('3383','3382') AND TLG.DELTD = 'N' AND TLG.TXCD = '0040'
                            AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    ) TLG, CAMAST CA, AFMAST AF
                WHERE CA.CAMASTID = TLG.REF
                    AND AF.ACCTNO = SUBSTR(TLG.ACCTNO,1,10)
                    AND AF.CUSTID LIKE V_CUSTID
                    AND AF.ACCTNO LIKE V_AFACCTNO

                UNION ALL
                -- GD HUY DANG KY QUYEN MUA
                SELECT CA.TOCODEID,TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.TLTXCD, SUBSTR(TLG.ACCTNO,1,10) AFACCTNO, CA.CAMASTID, CA.CODEID, TLG.NAMT EXECQTTY,
                    '1' TXSTATUS, 'Huy dang ky quyen mua' EXECTYPE, TLG.TLLOG_AUTOID
                FROM
                    (SELECT * FROM VW_SETRAN_GEN TLG
                        WHERE TLG.TLTXCD IN ('3386') AND TLG.DELTD = 'N' AND TLG.TXCD = '0045'
                            AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    ) TLG, CAMAST CA, AFMAST AF
                WHERE CA.CAMASTID = TLG.REF
                    AND AF.ACCTNO = SUBSTR(TLG.ACCTNO,1,10)
                    AND AF.CUSTID LIKE V_CUSTID
                    AND AF.ACCTNO LIKE V_AFACCTNO
                UNION ALL
                -- GD DK MUA CP PHAT HANH THEM KO CAT CI
                SELECT CA.TOCODEID,TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.TLTXCD, SUBSTR(TLG.ACCTNO,1,10) AFACCTNO, CA.CAMASTID, CA.CODEID, TLG.NAMT EXECQTTY,
                    '1' TXSTATUS, 'DK mua CP phat hanh them khong cat CI' EXECTYPE, TLG.TLLOG_AUTOID
                FROM
                    (SELECT * FROM VW_SETRAN_GEN TLG
                        WHERE TLG.TLTXCD IN ('3324') AND TLG.DELTD = 'N' AND TLG.TXCD = '0016'
                            AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    ) TLG, CAMAST CA, AFMAST AF, caschd cas
                WHERE CAs.autoid = TLG.REF
                    AND ca.camastid = cas.camastid AND af.acctno = cas.afacctno
                    AND AF.ACCTNO = SUBSTR(TLG.ACCTNO,1,10)
                    AND AF.CUSTID LIKE V_CUSTID
                    AND AF.ACCTNO LIKE V_AFACCTNO
                UNION ALL
                -- GD HUY DK MUA CP PHAT HANH THEM KO CAT CI
                SELECT CA.TOCODEID,TLG.TXDATE, TLG.BUSDATE, TLG.TXNUM, TLG.TLTXCD, SUBSTR(TLG.ACCTNO,1,10) AFACCTNO, CA.CAMASTID, CA.CODEID, TLG.NAMT EXECQTTY,
                    '1' TXSTATUS, 'Huy DK mua CP phat hanh them khong cat CI' EXECTYPE, TLG.TLLOG_AUTOID
                FROM
                    (SELECT * FROM VW_SETRAN_GEN TLG
                        WHERE TLG.TLTXCD IN ('3326') AND TLG.DELTD = 'N' AND TLG.TXCD = '0015'
                            AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                            AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    ) TLG, CAMAST CA, AFMAST AF, caschd cas
                WHERE CAs.autoid = TLG.REF
                    AND ca.camastid = cas.camastid AND af.acctno = cas.afacctno
                    AND AF.ACCTNO = SUBSTR(TLG.ACCTNO,1,10)
                    AND AF.CUSTID LIKE V_CUSTID
                    AND AF.ACCTNO LIKE V_AFACCTNO
            ) CA, ALLCODE A1, SBSECURITIES SB
            WHERE CA.TOCODEID = SB.CODEID
                AND A1.CDTYPE = 'SY' AND A1.CDNAME = 'TXSTATUS' AND A1.CDVAL = CA.TXSTATUS
        ) A
        ORDER BY A.BUSDATE DESC, A.TLLOG_AUTOID DESC, SUBSTR(A.TXNUM,5,6) DESC;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetRightOffInfor');
END pr_GetRightOffInfor;


---------------------------------------------------------------
-- Ham thuc hien ung truoc tien ban cho khach hang
-- Dau vao: - p_afacctno: So tieu khoan
--          - p_txdate: Ngay khop lenh
--          - p_duedate: Ngay thanh toan
--          - p_advamt: So tien ung truoc
--          - p_feeamt: So phi ung truoc
--          - p_advdays: So ngay ung truoc
--          - p_maxamt: So tien co the ung truoc toi da
--          - p_desc: Mo ta GD ung truoc
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 18-Jan-2011
---------------------------------------------------------------
PROCEDURE pr_AdvancePayment
    (   p_afacctno varchar,
        p_txdate date,
        p_duedate DATE,
        p_advamt number,
        p_feeamt NUMBER,
        p_advdays NUMBER,
        p_maxamt    NUMBER,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg       tx.msg_rectype;
        v_strCURRDATE varchar2(20);
        l_err_param   varchar2(300);
        l_custodycd   varchar2(20);
        l_ACTYPE      varchar(4);
        l_CUSTNAME    varchar2(100);
        l_ADDRESS     varchar2(200);
        l_LICENSE     varchar2(20);
        l_COREBANK    varchar2(100);
        l_BANKACCT    varchar2(50);
        l_BANKCODE    varchar2(50);
        l_DUEDATE     varchar2(20);
        l_MATCHDATE   varchar2(20);
        l_MAXAMT      NUMBER;
        l_ADTYPE      varchar(4);
        l_AMINBAL     NUMBER;
        l_VAT         NUMBER;
        l_INTRATE     NUMBER;
        l_BNKRATE     NUMBER;
        l_CMPMINBAL   NUMBER;
        l_BNKMINBAL   NUMBER;
        l_ADVAMT      NUMBER;
        l_FEEAMT      NUMBER;
        l_BNKFEEAMT   NUMBER;
        l_VATAMT      NUMBER;
        l_AMT         NUMBER;
        l_ADVMAXFEE     NUMBER;
        l_IDDATE      date;
        l_IDPLACE     varchar2(2000);
        l_ISVSD       varchar(1 );
        L_STARTTIME number(10);
    L_ENDTIME number(10);
    L_CURRTIME number(10);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_AdvancePayment');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AdvancePayment');
            return;
        END IF;
        -- End: Check host 1 active or inactive

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTADVPAYMENT';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDADVPAYMENT';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    if ( NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
        p_err_code := '-994460';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_AdvancePayment');
        return;
    end if;

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='1153';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        --LAY THONG TIN KHACH HANG
        SELECT AF.ACTYPE AFTYPE, AD.ACTYPE ADTYPE, CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE, CF.ADDRESS, AF.BANKACCTNO, AF.BANKNAME,
            AD.ADVMINAMT, AD.VATRATE, AD.ADVRATE, AD.ADVBANKRATE, AD.ADVMINFEE, AD.ADVMINFEEBANK, ad.advmaxfee, cf.iddate, cf.idplace,
            (case when af.corebank ='Y' then 1 else 0 end) corebank
        INTO l_ACTYPE, l_ADTYPE,l_custodycd, l_CUSTNAME, l_LICENSE, l_ADDRESS, l_BANKACCT, l_BANKCODE,
            l_AMINBAL, l_VAT, l_INTRATE, l_BNKRATE, l_CMPMINBAL, l_BNKFEEAMT, l_ADVMAXFEE, l_IDDATE, l_IDPLACE, l_COREBANK
        FROM CFMAST CF, AFMAST AF, AFTYPE AFT, ADTYPE AD
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACTYPE = AFT.ACTYPE AND AFT.ADTYPE = AD.ACTYPE
            AND AF.ACCTNO = p_afacctno;

        --Set cac field giao dich
        l_DUEDATE := TO_CHAR(p_duedate,'DD/MM/YYYY');
        l_MATCHDATE := TO_CHAR(p_txdate,'DD/MM/YYYY');

        --03   ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := to_char(nvl(p_afacctno,''));
        --88   CUSTODYCD      C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := l_custodycd;
        --89   ACTYPE      C
        l_txmsg.txfields ('89').defname   := 'ACTYPE';
        l_txmsg.txfields ('89').TYPE      := 'C';
        l_txmsg.txfields ('89').VALUE     := l_ACTYPE;
        --90   CUSTNAME        C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := l_CUSTNAME;
        --91   ADDRESS      C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := l_ADDRESS;
        --92   LICENSE      C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := l_LICENSE;
        --94   COREBANK      C
        l_txmsg.txfields ('94').defname   := 'COREBANK';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := l_COREBANK;
        --93   BANKACCT      C
        l_txmsg.txfields ('93').defname   := 'BANKACCT';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := l_BANKACCT;
        --95   BANKCODE   C
        l_txmsg.txfields ('95').defname   := 'BANKCODE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := l_BANKCODE;
        --96   IDDATE    D
        l_txmsg.txfields ('96').defname   := 'IDDATE';
        l_txmsg.txfields ('96').TYPE      := 'D';
        l_txmsg.txfields ('96').VALUE     := l_IDDATE;
        --97   IDPLACE   C
        l_txmsg.txfields ('97').defname   := 'IDPLACE';
        l_txmsg.txfields ('97').TYPE      := 'C';
        l_txmsg.txfields ('97').VALUE     := l_IDPLACE;
        --08   DUEDATE          C
        l_txmsg.txfields ('08').defname   := 'DUEDATE';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := l_DUEDATE;
        --42   MATCHDATE         C
        l_txmsg.txfields ('42').defname   := 'MATCHDATE';
        l_txmsg.txfields ('42').TYPE      := 'C';
        l_txmsg.txfields ('42').VALUE     := l_MATCHDATE;
        --13   DAYS       N
        l_txmsg.txfields ('13').defname   := 'DAYS';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := p_advdays;
        --20   MAXAMT          N
        l_txmsg.txfields ('20').defname   := 'MAXAMT';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := p_maxamt;
        --06   ADTYPE         C
        l_txmsg.txfields ('06').defname   := 'ADTYPE';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := l_ADTYPE;
        --21   AMINBAL         N
        l_txmsg.txfields ('21').defname   := 'AMINBAL';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := l_AMINBAL;
        --22   ADVMAXFEE         N
        l_txmsg.txfields ('22').defname   := 'ADVMAXFEE';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := l_ADVMAXFEE;
        --19   VAT          N
        l_txmsg.txfields ('19').defname   := 'VAT';
        l_txmsg.txfields ('19').TYPE      := 'N';
        l_txmsg.txfields ('19').VALUE     := l_VAT;
        --12   INTRATE   N
        l_txmsg.txfields ('12').defname   := 'INTRATE';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := l_INTRATE;
        --15   BNKRATE       N
        l_txmsg.txfields ('15').defname   := 'BNKRATE';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := l_BNKRATE;
        --16   CMPMINBAL        N
        l_txmsg.txfields ('16').defname   := 'CMPMINBAL';
        l_txmsg.txfields ('16').TYPE      := 'N';
        l_txmsg.txfields ('16').VALUE     := l_CMPMINBAL;
        --17   BNKMINBAL        N
        l_txmsg.txfields ('17').defname   := 'BNKMINBAL';
        l_txmsg.txfields ('17').TYPE      := 'N';
        l_txmsg.txfields ('17').VALUE     := l_BNKMINBAL;
        --09   ADVAMT        N
        l_txmsg.txfields ('09').defname   := 'ADVAMT';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := p_advamt;
        --11   FEEAMT        N
        l_txmsg.txfields ('11').defname   := 'FEEAMT';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := p_feeamt;
        --14   BNKFEEAMT        N
        l_txmsg.txfields ('14').defname   := 'BNKFEEAMT';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := p_advamt*p_advdays*l_BNKRATE/36000;
        --18   VATAMT        N
        l_txmsg.txfields ('18').defname   := 'VATAMT';
        l_txmsg.txfields ('18').TYPE      := 'N';
        l_txmsg.txfields ('18').VALUE     := p_feeamt*l_VAT/100;
        --10   AMT        N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_advamt-p_feeamt;
        --41   100        N
        l_txmsg.txfields ('41').defname   := '100';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := 100;
        --40   36000        N
        l_txmsg.txfields ('40').defname   := '36000';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').VALUE     := 36000;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := p_desc;
        --60 ISVSD C
        l_txmsg.txfields ('60').defname   := 'ISVSD';
        l_txmsg.txfields ('60').TYPE      := 'C';
        l_txmsg.txfields ('60').VALUE     := '0';


    BEGIN
        IF txpks_#1153.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1153: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_AdvancePayment');
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_AdvancePayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_AdvancePayment');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_AdvancePayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_AdvancePayment;

---------------------------------------------------------------
-- Ham thuc hien cap nhat gia von online
-- Dau vao: - p_afacctno: So tieu khoan
--          - p_symbol: Ma CK
--          - p_newcostprice: Gia von cap nhat
--          - p_desc: Mo ta GD
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 19-Jan-2011
---------------------------------------------------------------
PROCEDURE pr_AdjustCostprice_Online
    (   p_afacctno varchar,
        p_symbol    VARCHAR2,
        p_newcostprice  number,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);
        l_CODEID        VARCHAR2(20);
        l_SEACCTNO      VARCHAR2(20);
        l_ADJQTTY       NUMBER;
        l_COSTPRICE     NUMBER;
        l_PREVQTTY      NUMBER;

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_AdjustCostprice_Online');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AdjustCostprice_Online');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        IF p_newcostprice IS NULL THEN
            p_err_code := '-222241';
            p_err_message := cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AdjustCostprice_Online');
            return;
        END IF;

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='2224';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        --LAY THONG TIN CHUNG KHOAN
        SELECT CODEID
        INTO l_CODEID
        FROM SBSECURITIES
        WHERE SYMBOL = p_symbol;

        l_SEACCTNO := TRIM(p_afacctno) || TRIM(l_CODEID);

        -- LAY THONG TIN TK CK
        SELECT TRADE+BLOCKED+MORTAGE VOL, COSTPRICE, PREVQTTY
        INTO l_ADJQTTY, l_COSTPRICE, l_PREVQTTY
        FROM SEMAST
        WHERE ACCTNO = l_SEACCTNO;

        -- CHECK TRUOC KHI THUC HIEN GD
        /*IF l_PREVQTTY <=0 THEN
            -- CHI CHO PHEP THAY DOI GIA VON ONLINE NEU SL NGAY HOM TRUOC >0
            p_err_code := ERRNUMS.C_SE_CANNOT_ADJUST_COSTPRICE;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AdjustCostprice_Online');
            RETURN;*/
        /*ELSIF l_COSTPRICE <> 0 THEN
            -- CHI CHO PHEP THAY DOI GIA VON ONLINE NEU GIA VON = 0
            p_err_code := ERRNUMS.C_SE_CANNOT_ADJUST_COSTPRICE;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AdjustCostprice_Online');
            RETURN;*/
        --ELSE
            --Set cac field giao dich
            --01   CODEID      C
            l_txmsg.txfields ('01').defname   := 'CODEID';
            l_txmsg.txfields ('01').TYPE      := 'C';
            l_txmsg.txfields ('01').VALUE     := l_CODEID;
            --02   AFACCTNO      C
            l_txmsg.txfields ('02').defname   := 'AFACCTNO';
            l_txmsg.txfields ('02').TYPE      := 'C';
            l_txmsg.txfields ('02').VALUE     := p_afacctno;
            --03   SEACCTNO      C
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := l_SEACCTNO;
            --10   COSTPRICE        N
            l_txmsg.txfields ('10').defname   := 'COSTPRICE';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := p_newcostprice;
            --11   ADJQTTY        N
            l_txmsg.txfields ('11').defname   := 'ADJQTTY';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := l_ADJQTTY;
            --30   DESC    C
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := p_desc;

            BEGIN
                IF txpks_#2224.fn_autotxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.debug (pkgctx,
                               'got error 2224: ' || p_err_code
                   );
                   ROLLBACK;
                   p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                   plog.error(pkgctx, 'Error:'  || p_err_message);
                   plog.setendsection(pkgctx, 'pr_AdjustCostprice_Online');
                   RETURN;
                END IF;
            END;
            p_err_code:=0;
            plog.setendsection(pkgctx, 'pr_AdjustCostprice_Online');
        --END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_AdjustCostprice_Online');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_AdjustCostprice_Online');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_AdjustCostprice_Online;

-- LAY THONG TIN UNG TRUOC DA THUC HIEN
PROCEDURE pr_GetAdvancedPayment
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN VARCHAR2,
     T_DATE         IN VARCHAR2,
     STATUS         IN VARCHAR2,
     ADVPLACE       IN VARCHAR2
    )
    IS

  V_AFACCTNO    VARCHAR2(10);
  V_FROMDATE    DATE;
  V_TODATE      DATE;
  V_STATUS      VARCHAR2(10);
  V_ADVPLACE    VARCHAR2(10);

BEGIN
    --V_AFACCTNO := AFACCTNO;
    V_FROMDATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_TODATE := TO_DATE(T_DATE,'DD/MM/YYYY');

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF STATUS = 'ALL' OR STATUS IS NULL THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;

    IF ADVPLACE = 'ALL' OR ADVPLACE IS NULL THEN
        V_ADVPLACE := '%%';
    ELSIF ADVPLACE = 'O' THEN
        V_ADVPLACE := '68%';
    ELSIF ADVPLACE = 'F' THEN
        V_ADVPLACE := SUBSTR(AFACCTNO,1,2)||'%';
    END IF;

    -- LAY THONG TIN UT DA THUC HIEN
    OPEN p_REFCURSOR FOR
        SELECT AD.ODDATE, AD.TXDATE, AD.TXDATE EXECDATE, AD.CLEARDT, STS.AMT, AD.AMT+AD.FEEAMT AAMT,
            AD.FEEAMT, AD.AMT RECVAMT, AD.CLEARDT-AD.TXDATE ADVDAYS, A1.CDCONTENT STATUS, A2.CDCONTENT ADVPLACE,
            AD.AUTOID TLLOG_AUTOID
        FROM
        (
            SELECT STS.TXDATE, STS.AFACCTNO, SUM(STS.AMT-STS.FEEACR-STS.TAXSELLAMT) AMT, SUM(AAMT) AAMT, SUM(FAMT) FAMT, STS.CLEARDATE
            FROM
            (
                SELECT STS.TXDATE, STS.AFACCTNO, STS.AMT, STS.AAMT, STS.FAMT, OD.FEEACR, OD.TAXSELLAMT, STS.CLEARDAY, STS.CLEARCD, STS.CLEARDATE
                FROM (SELECT * FROM STSCHD WHERE deltd <> 'Y' AND duetype = 'RM') STS,
                    (
                        SELECT OD.ORDERID,
                         CASE WHEN OD.FEEACR >0 THEN OD.FEEACR ELSE OD.EXECAMT*ODT.DEFFEERATE/100 END FEEACR,
                         CASE WHEN OD.TAXSELLAMT >0 THEN OD.TAXSELLAMT ELSE OD.EXECAMT*TO_NUMBER(SYS.VARVALUE)/100 END TAXSELLAMT
                         FROM VW_ODMAST_ALL OD, SYSVAR SYS, ODTYPE ODT
                          WHERE INSTR(OD.EXECTYPE,'S')>0 AND OD.EXECAMT >0
                             AND OD.ACTYPE = ODT.ACTYPE
                             AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                    ) OD
                WHERE STS.ORGORDERID = OD.ORDERID
                    AND STS.DUETYPE = 'RM' AND STS.DELTD = 'N'
                    AND STS.AFACCTNO LIKE V_AFACCTNO
            ) STS
            GROUP BY STS.TXDATE, STS.AFACCTNO, STS.CLEARDAY, STS.CLEARCD, STS.CLEARDATE
        ) STS
        INNER JOIN
            VW_ADSCHD_ALL AD
        ON AD.ACCTNO = STS.AFACCTNO AND AD.ODDATE = STS.TXDATE AND AD.CLEARDT = STS.CLEARDATE
            AND AD.STATUS||AD.DELTD LIKE V_STATUS
            AND AD.TXNUM LIKE V_ADVPLACE
            AND AD.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
            AND AD.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
        INNER JOIN
            ALLCODE A1
        ON A1.CDTYPE = 'AD' AND A1.CDNAME = 'ADSTATUS' AND A1.CDVAL = AD.STATUS||AD.DELTD
        INNER JOIN
            ALLCODE A2
        ON A2.CDTYPE = 'SA' AND A2.CDNAME = 'VIA' AND A2.CDVAL = DECODE(SUBSTR(AD.TXNUM,1,2),systemnums.C_OL_PREFIXED,'O','F')
---        INNER JOIN VW_CITRAN_GEN CI
---        ON AD.TXDATE = CI.TXDATE AND AD.TXNUM = CI.TXNUM AND CI.TXCD = '0012'
        ORDER BY AD.ODDATE DESC, AD.AUTOID DESC, substr(AD.TXNUM,5,6) DESC
       /* SELECT AD.ODDATE, AD.TXDATE, AD.TXDATE EXECDATE, AD.CLEARDT, STS.AMT, AD.AMT+AD.FEEAMT AAMT,
        AD.FEEAMT, AD.AMT RECVAMT, AD.CLEARDT-AD.TXDATE ADVDAYS , A1.CDCONTENT STATUS, A2.CDCONTENT ADVPLACE,
        AD.AUTOID TLLOG_AUTOID
    FROM
    (
      SELECT STS.TXDATE, STS.AFACCTNO, SUM(STS.AMT-STS.FEEACR-STS.TAXSELLAMT) AMT, SUM(AAMT) AAMT, SUM(FAMT) FAMT, STS.CLEARDATE
      FROM
      (
        SELECT STS.TXDATE, STS.AFACCTNO, STS.AMT, STS.AAMT, STS.FAMT, OD.FEEACR, OD.TAXSELLAMT, STS.CLEARDAY, STS.CLEARCD, STS.CLEARDATE
        FROM VW_STSCHD_ALL STS,
          (
              SELECT OD.ORDERID,
               CASE WHEN OD.FEEACR >0 THEN OD.FEEACR ELSE OD.EXECAMT*ODT.DEFFEERATE/100 END FEEACR,
               CASE WHEN OD.TAXSELLAMT >0 THEN OD.TAXSELLAMT ELSE OD.EXECAMT*TO_NUMBER(SYS.VARVALUE)/100 END TAXSELLAMT
               FROM VW_ODMAST_ALL OD, SYSVAR SYS, ODTYPE ODT
                WHERE INSTR(OD.EXECTYPE,'S')>0 AND OD.EXECAMT >0
                   AND OD.ACTYPE = ODT.ACTYPE
                   AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
          ) OD
        WHERE STS.ORGORDERID = OD.ORDERID
            AND STS.DUETYPE = 'RM' AND STS.DELTD = 'N'
            AND STS.AFACCTNO LIKE '0001000059'
      ) STS
      GROUP BY STS.TXDATE, STS.AFACCTNO, STS.CLEARDAY, STS.CLEARCD, STS.CLEARDATE
    ) STS
    INNER JOIN AFMAST AF ON STS.AFACCTNO = AF.ACCTNO
    INNER JOIN CFMAST CF ON AF.CUSTID = CF.CUSTID AND CF.CUSTODYCD = '002C008019'
    INNER JOIN VW_ADSCHD_ALL AD
    ON AD.ACCTNO = STS.AFACCTNO AND AD.ODDATE = STS.TXDATE AND AD.CLEARDT = STS.CLEARDATE
        AND AD.STATUS||AD.DELTD LIKE '%'
        AND AD.TXDATE >= TO_DATE('19/12/2013','DD/MM/YYYY')
        AND AD.TXDATE <= TO_DATE('19/12/2013','DD/MM/YYYY')
    INNER JOIN ALLCODE A1 ON A1.CDTYPE = 'AD' AND A1.CDNAME = 'ADSTATUS' AND A1.CDVAL = AD.STATUS||AD.DELTD
    INNER JOIN ALLCODE A2 ON A2.CDTYPE = 'SA' AND A2.CDNAME = 'VIA' AND A2.CDVAL = DECODE(SUBSTR(AD.TXNUM,1,2),'68','O','F')
    AND A2.CDVAL LIKE '%'
    ORDER BY AD.ODDATE DESC, AD.AUTOID DESC, substr(AD.TXNUM,5,6) DESC
    */;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetAdvancedPayment');
END pr_GetAdvancedPayment;


---------------------------------------------------------------
-- Ham thuc hien cap han muc bao lanh tren man hinh MG
-- Dau vao: - p_custodycd: So TK luu ky
--          - p_afacctno: So tieu khoan
--          - p_amount: Han muc cap
--          - p_userid: Ma NSD
--          - p_desc: Mo ta GD
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 29-Jan-2011
---------------------------------------------------------------
PROCEDURE pr_Allocate_Guarantee_BD
    (   p_custodycd VARCHAR,
        p_afacctno varchar,
        p_amount  number,
        p_userid    varchar,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_Allocate_Guarantee_BD');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_Allocate_Guarantee_BD');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := p_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='1812';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        --Set cac field giao dich
        --88   CUSTODYCD      C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := p_custodycd;
        --02   USERTYPE      C
        l_txmsg.txfields ('02').defname   := 'USERTYPE';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := 'Flex'; -- De mac dinh la Flex
        --01   USERID      C
        l_txmsg.txfields ('01').defname   := 'USERID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := p_userid;
         --03   ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno;
        --10   TOAMT        N
        l_txmsg.txfields ('10').defname   := 'TOAMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_amount;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := p_desc;

        BEGIN
            IF txpks_#1812.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 1812: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_Allocate_Guarantee_BD');
                RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_Allocate_Guarantee_BD');
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_Allocate_Guarantee_BD');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_Allocate_Guarantee_BD');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_Allocate_Guarantee_BD;

-- LAY THONG TIN TY LE KY QUY
PROCEDURE pr_GetSecureRatio
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2,
     PRICETYPE      IN  VARCHAR2,
     TIMETYPE       IN  VARCHAR2,
     QUOTEPRICE     IN  NUMBER,
     ORDERQTTY      IN  NUMBER,
     VIA            IN  VARCHAR2 DEFAULT 'F'
    )
IS

    V_AFACCTNO        VARCHAR2(10);
    V_SYMBOL          VARCHAR2(50);
    V_EXECTYPE        VARCHAR(10);
    V_PRICETYPE       VARCHAR(10);
    V_TIMETYPE        VARCHAR(10);
    V_AFTYPE          VARCHAR(4);
    V_TRADEPLACE      VARCHAR(3);
    V_SECTYPE         VARCHAR(3);
    V_CODEID          VARCHAR(6);
    V_MARGINTYPE      VARCHAR(1);
    V_AFBRATIO        NUMBER;
    V_TYPEBRATIO      NUMBER;
    V_FEEAMOUNTMIN    NUMBER;
    V_FEESECURERATIOMIN   NUMBER;
    V_FEERATE         NUMBER;
    V_SECURERATIO     NUMBER;
    V_QUOTEPRICE      NUMBER;
    V_ORDERQTTY       NUMBER;
    V_SECUREDRATIOMIN NUMBER;
    V_SECUREDRATIOMAX NUMBER;
    V_VATRATE         NUMBER;
    V_MAXFEERATE      NUMBER;
    V_FEERATIO        NUMBER;
    V_ACTYPE        VARCHAR2(10);
    V_VIA           VARCHAR2(1);

BEGIN
    V_AFACCTNO := AFACCTNO;
    V_SYMBOL := SYMBOL;
    V_EXECTYPE := EXECTYPE;
    V_PRICETYPE := PRICETYPE;
    V_TIMETYPE := TIMETYPE;
    V_QUOTEPRICE := QUOTEPRICE;
    V_ORDERQTTY := ORDERQTTY;
    IF VIA IS NULL THEN
        V_VIA := 'F';
    ELSE
        V_VIA := VIA;
    END IF;

    -- LAY THONG TIN CHUNG KHOAN
    SELECT SE.TRADEPLACE, SE.SECTYPE, SE.CODEID, SIF.securedratiomin, SIF.securedratiomax
    INTO V_TRADEPLACE, V_SECTYPE, V_CODEID, V_SECUREDRATIOMIN, V_SECUREDRATIOMAX
    FROM SBSECURITIES SE, SECURITIES_INFO SIF
    WHERE SE.CODEID = SIF.CODEID AND SE.SYMBOL = V_SYMBOL;

    -- LAY THONG TIN TIEU KHOAN
    SELECT MST.ACTYPE,MRT.MRTYPE, MST.BRATIO
    INTO V_AFTYPE, V_MARGINTYPE, V_AFBRATIO
    FROM AFMAST MST, AFTYPE AFT, MRTYPE MRT
    WHERE MST.ACCTNO= V_AFACCTNO
    and mst.actype =aft.actype and aft.mrtype = mrt.actype;

    --Ngay 04/04/2017 NamTv Gan cho truong hop khong co ODTYPE
    BEGIN
    -- LAY THONG TIN DE TINH TY LE KY QUY
    SELECT ACTYPE,bratio, minfeeamt, deffeerate, VATRATE
    INTO V_ACTYPE, V_TYPEBRATIO,
        V_FEEAMOUNTMIN,
        V_FEERATE,
        V_VATRATE
    FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM, A.VATRATE
    FROM odtype a, afidtype b
    WHERE a.status = 'Y'
         AND (a.via = V_VIA OR a.via = 'A') --VIA
         AND a.clearcd = 'B'       --CLEARCD
         AND (a.exectype = V_EXECTYPE           --l_build_msg.fld22
              OR a.exectype = 'AA')                    --EXECTYPE
         AND (a.timetype = V_TIMETYPE
              OR a.timetype = 'A')                     --TIMETYPE
         AND (a.pricetype = V_PRICETYPE
              OR a.pricetype = 'AA')                  --PRICETYPE
         AND (a.matchtype = 'N'
              OR a.matchtype = 'A')                   --MATCHTYPE
         AND (a.tradeplace = V_TRADEPLACE
              OR a.tradeplace = '000')
         AND (instr(case when V_SECTYPE in ('001','002') then V_SECTYPE || ',' || '111,333'
                        when V_SECTYPE in ('003','006') then V_SECTYPE || ',' || '222,333,444'
                        when V_SECTYPE in ('008') then V_SECTYPE || ',' || '111,444'
                        else V_SECTYPE end, a.sectype)>0 OR a.sectype = '000')
         AND (a.nork = 'A') --NORK
         AND (CASE WHEN A.CODEID IS NULL THEN V_CODEID ELSE A.CODEID END)= V_CODEID
         AND a.actype = b.actype and b.aftype = V_AFTYPE and b.objname='OD.ODTYPE'
    --order by b.odrnum DESC, A.deffeerate DESC
    --ORDER BY a.deffeerate DESC, B.ACTYPE DESC -- Lay gia tri ky quy lon nhat
    ORDER BY a.deffeerate, B.ACTYPE DESC -- Lay gia tri ky quy nho nhat
    ) where rownum<=1;
    EXCEPTION
    WHEN OTHERS THEN
        V_ACTYPE := '';
        V_TYPEBRATIO := 0;
        V_FEEAMOUNTMIN := 0;
        V_FEERATE := 0;
        V_VATRATE := 0;
    END ;

    -- TINH TY LE KY QUY
    if V_MARGINTYPE='S' or V_MARGINTYPE='T' or V_MARGINTYPE='N' then
        --Tai khoan margin va tai khoan binh thuong ky quy 100%
        V_SECURERATIO:=100;
    elsif V_MARGINTYPE='L' then --Cho tai khoan margin loan
        begin
            select (case when nvl(dfprice,0)>0 then least(nvl(dfrate,0),round(nvl(dfprice,0)/ V_QUOTEPRICE/1000 * 100,4)) else nvl(dfrate,0) end ) dfrate
            into V_SECURERATIO
            from (select * from dfbasket where symbol = V_SYMBOL) bk, aftype aft, dftype dft, afmast af
            where af.actype = aft.actype and aft.dftype = dft.actype and dft.basketid = bk.basketid (+)
            and af.acctno = V_AFACCTNO;
            V_SECURERATIO:=greatest (100-V_SECURERATIO,0);
        exception
            when others then
                V_SECURERATIO:=100;
        end;
    else
        V_SECURERATIO := GREATEST (LEAST (V_TYPEBRATIO + V_AFBRATIO, 100), V_SECUREDRATIOMIN);
        V_SECURERATIO := CASE WHEN V_SECURERATIO > V_SECUREDRATIOMAX
                                THEN V_SECUREDRATIOMIN
                                ELSE V_SECURERATIO END;
    end if;
    IF V_ORDERQTTY > 0 THEN
    V_FEESECURERATIOMIN := V_FEEAMOUNTMIN * 100
                            / (TO_NUMBER(V_ORDERQTTY)         --quantity
                            * TO_NUMBER(V_QUOTEPRICE)       --quoteprice
                            * 1000);      --tradeunit
    ELSE
        V_FEESECURERATIOMIN := 0;
    END IF;

    IF V_FEESECURERATIOMIN > V_FEERATE
    THEN
        V_SECURERATIO := V_SECURERATIO + V_FEESECURERATIOMIN;
        V_FEERATIO := V_FEESECURERATIOMIN;
    ELSE
        V_SECURERATIO := V_SECURERATIO + V_FEERATE;
        V_FEERATIO := V_FEERATE;
    END IF;

    V_MAXFEERATE := GREATEST(V_FEERATE, V_FEESECURERATIOMIN, V_AFBRATIO);

    OPEN p_REFCURSOR FOR
        SELECT V_AFACCTNO AFACCTNO, V_SECURERATIO SECURERATIO, V_VATRATE VATRATE, V_MAXFEERATE MAXFEERATE, V_FEERATIO FEERATIO
        FROM DUAL;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm || '-format_error_backtrace:' ||  dbms_utility.format_error_backtrace );
    plog.setendsection(pkgctx, 'pr_GetSecureRatio');
END pr_GetSecureRatio;

---------------------------------------------------------------
-- Ham thuc hien cap nhat thong tin khach hang tren OnlineTrading
-- Dau vao: - p_custodycd: So TK luu ky
--          - p_custid: Ma khach hang
--          - p_address: Dia chi thay doi
--          - p_phone: Dien thoai thay doi
--          - p_coaddress: Dia chi cong ty thay doi
--          - p_cophone: Dien thoai cong ty thay doi
--          - p_email: Email thay doi
--          - p_desc: Mo ta. Neu ko co thi de trong
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 31-Jan-2012
---------------------------------------------------------------
PROCEDURE pr_OnlineUpdateCustomerInfor
    (   p_custodycd VARCHAR,
        p_custid varchar,
        p_address   VARCHAR2,
        p_phone     VARCHAR2,
        p_mobile     VARCHAR2,
        p_mobilesms     VARCHAR2,
        p_coaddress    VARCHAR2,
        p_cophone  VARCHAR2,
        p_email     VARCHAR2,
        p_sex       VARCHAR2,
        p_birthdate VARCHAR2,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);
        v_mobile        varchar(50);
        v_desc          varchar2(200);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_OnlineUpdateCustomerInfor');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_OnlineUpdateCustomerInfor');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='0099';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_custid,1,4);

        --Set cac field giao dich
        SELECT MOBILE
        INTO v_mobile
        FROM CFMAST
        WHERE CUSTID = p_custid;
        IF length(p_desc) =0 THEN
            SELECT TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '0099';
        ELSE
            v_desc := p_desc;
        END IF;

        --03   CUSTID      C
        l_txmsg.txfields ('03').defname   := 'CUSTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_custid;
        --04   CUSTODYCD      C
        l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := p_custodycd;
        --20   ADDRESS      C
        l_txmsg.txfields ('20').defname   := 'ADDRESS';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := p_address;
        --21   PHONE      C
        l_txmsg.txfields ('21').defname   := 'PHONE';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := p_phone;
        --22   MOBILE      C
        l_txmsg.txfields ('22').defname   := 'MOBILE';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := p_mobile;
        --26   MOBILE      C
        l_txmsg.txfields ('26').defname   := 'MOBILESMS';
        l_txmsg.txfields ('26').TYPE      := 'C';
        l_txmsg.txfields ('26').VALUE     := p_mobilesms;
        --23   COADDRESS      C
        l_txmsg.txfields ('23').defname   := 'COADDRESS';
        l_txmsg.txfields ('23').TYPE      := 'C';
        l_txmsg.txfields ('23').VALUE     := p_coaddress;
        --24   COPHONE      C
        l_txmsg.txfields ('24').defname   := 'COPHONE';
        l_txmsg.txfields ('24').TYPE      := 'C';
        l_txmsg.txfields ('24').VALUE     := p_cophone;
        --25   EMAIL      C
        l_txmsg.txfields ('25').defname   := 'EMAIL';
        l_txmsg.txfields ('25').TYPE      := 'C';
        l_txmsg.txfields ('25').VALUE     := p_email;
        --27   SEX      C
        l_txmsg.txfields ('27').defname   := 'SEX';
        l_txmsg.txfields ('27').TYPE      := 'C';
        l_txmsg.txfields ('27').VALUE     := p_sex;
        --28   BIRTHDATE      C
        l_txmsg.txfields ('28').defname   := 'BIRTHDATE';
        l_txmsg.txfields ('28').TYPE      := 'C';
        l_txmsg.txfields ('28').VALUE     := p_birthdate;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := v_desc;

        BEGIN
            IF txpks_#0099.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 1812: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_OnlineUpdateCustomerInfor');
                RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_OnlineUpdateCustomerInfor');
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_OnlineUpdateCustomerInfor');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_OnlineUpdateCustomerInfor');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_OnlineUpdateCustomerInfor;


PROCEDURE pr_UpdateCustomerInfor
(
    p_custodycd VARCHAR,
    p_custid varchar,
    p_fldname   VARCHAR2,
    p_fldval    VARCHAR2,
    p_desc      varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2,
    --Log thong tin thiet bi
    p_ipaddress         VARCHAR2,
    p_via               VARCHAR2,
    p_validationtype    VARCHAR2,
    p_devicetype        VARCHAR2,
    p_device            VARCHAR2
    --End
) -- HAM THUC HIEN CAP NHAT THONG TIN KHACH HANG ONLINE
IS
    l_txmsg         tx.msg_rectype;
    v_strCURRDATE   varchar2(20);
    l_err_param     varchar2(300);
    v_mobile        varchar(50);
    v_desc          varchar2(200);
    l_custtype      varchar2(10);
    l_IDDATE        date;
    l_count         number(10);
    l_country      varchar2(10);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_UpdateCustomerInfor');
    -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_OnlineUpdateCustomerInfor');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        select cf.custtype, cf.idexpired,cf.country into l_custtype, l_IDDATE,l_country from cfmast cf
        where cf.custodycd = p_custodycd;
        if l_country != '234' then
            p_err_code := '-994462'; --khach hang khong duoc thay doi dia chi.
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_UpdateCustomerInfor');
            return;
        end if;
        if nvl(l_custtype,'I') = 'B' then
            p_err_code := '-200422'; --khach hang to chuc khong duoc thuc hien chuc nang nay.
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_UpdateCustomerInfor');
            return;
        end if;

        if l_IDDATE < getcurrdate and p_fldname = 'ADDRESS' then
            p_err_code := '-200424'; --chung minh thu het han.
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_UpdateCustomerInfor');
            return;
        end if;
        if p_fldname = 'ADDRESS' then
            SELECT count(*) into l_count FROM CFVSDLOG
            WHERE OADDRESS <> NVL(NADDRESS,OADDRESS) AND CONFIRMTXNUM IS NULL AND CUSTID = p_custid and deltd <> 'Y';
            if l_count > 0 then
                p_err_code := '-100242'; --chung minh thu het han.
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_UpdateCustomerInfor');
                return;
            end if;
        end if;



        SELECT TO_CHAR(getcurrdate) INTO v_strCURRDATE FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='0029';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_custid,1,4);

        --Set cac field giao dich
        IF length(p_desc) =0 THEN
            SELECT TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '0029';
        ELSE
            v_desc := p_desc;
        END IF;

        --03   CUSTID      C
        l_txmsg.txfields ('03').defname   := 'CUSTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_custid;
        --04   CUSTODYCD      C
        l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := p_custodycd;
        --20   FLDKEY      C
        l_txmsg.txfields ('20').defname   := 'ADDRESS';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := p_fldname;
        --21   FLDVAL      C
        l_txmsg.txfields ('21').defname   := 'PHONE';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := p_fldval;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := v_desc;

        BEGIN
            IF txpks_#0029.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 1812: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_UpdateCustomerInfor');
                RETURN;
            END IF;
        END;
        pr_insertiplog (l_txmsg.txnum,
                            l_txmsg.txdate,
                            p_ipaddress,
                            p_via,
                            p_validationtype,
                            p_devicetype,
                            p_device,
                            NULL);

        p_err_code:=0;
    plog.setendsection (pkgctx, 'pr_UpdateCustomerInfor');
EXCEPTION
WHEN OTHERS
THEN
    plog.debug (pkgctx,'got error on pr_UpdateCustomerInfor');
ROLLBACK;
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.error (pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'pr_UpdateCustomerInfor');
    RAISE errnums.E_SYSTEM_ERROR;
END pr_UpdateCustomerInfor;

PROCEDURE pr_UpdateSubAcctnoInfor
(
    p_custodycd VARCHAR,
    p_custid    varchar,
    p_afacctno  varchar,
    p_fldname   VARCHAR2,
    p_fldval    VARCHAR2,
    p_desc      varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
) -- HAM THUC HIEN CAP NHAT THONG TIN KHACH HANG ONLINE
IS
    l_txmsg         tx.msg_rectype;
    v_strCURRDATE   varchar2(20);
    l_err_param     varchar2(300);
    v_desc          varchar2(200);

BEGIN
    plog.setbeginsection(pkgctx, 'pr_UpdateSubAcctnoInfor');
    -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_UpdateSubAcctnoInfor');
            return;
        END IF;
        -- End: Check host 1 active or inactive
        SELECT TO_CHAR(getcurrdate) INTO v_strCURRDATE FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='0028';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_custid,1,4);

        --Set cac field giao dich
        IF length(p_desc) =0 THEN
            SELECT TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '0028';
        ELSE
            v_desc := p_desc;
        END IF;

        --03   CUSTID      C
        l_txmsg.txfields ('03').defname   := 'CUSTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_custid;
        --04   CUSTODYCD      C
        l_txmsg.txfields ('04').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := p_custodycd;
        --05   AFACCTNO      C
        l_txmsg.txfields ('05').defname   := 'AFACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := p_afacctno;
        --20   FLDKEY      C
        l_txmsg.txfields ('20').defname   := 'ADDRESS';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := p_fldname;
        --21   FLDVAL      C
        l_txmsg.txfields ('21').defname   := 'PHONE';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := p_fldval;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := v_desc;

        BEGIN
            IF txpks_#0028.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 1812: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_UpdateSubAcctnoInfor');
                RETURN;
            END IF;
        END;
        p_err_code:=0;
    plog.setendsection (pkgctx, 'pr_UpdateSubAcctnoInfor');
EXCEPTION
WHEN OTHERS
THEN
    plog.debug (pkgctx,'got error on pr_UpdateSubAcctnoInfor');
ROLLBACK;
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.error (pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'pr_UpdateSubAcctnoInfor');
    RAISE errnums.E_SYSTEM_ERROR;
END pr_UpdateSubAcctnoInfor;

---------------------------------------------------------------
-- Ham thuc hien cap nhat thong tin khach hang tren OnlineTrading
-- Dau vao: - p_afacctno: Ma tieu khoan
--          - p_BENEFCUSTNAME: Ten nguoi thu huong
--          - p_RECEIVLICENSE: CMND nguoi thu huong
--          - p_RECEIVIDDATE: Ngay cap
--          - p_RECEIVIDPLACE: Noi cap
--          - p_BANKNAME: Ten ngan hang chuyen den
--          - p_CITYBANK: Chi nhanh
--          - p_CITYEF: Tinh/ thanh pho
--          - p_AMT: So tien chuyen khoan
--          - p_desc: Mo ta. Neu ko co thi de trong
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 01-Feb-2012
---------------------------------------------------------------
/*PROCEDURE pr_CashTransferWithIDCode
    (   p_afacctno varchar,
        p_BENEFCUSTNAME   VARCHAR2,
        p_RECEIVLICENSE     VARCHAR2,
        p_RECEIVIDDATE    VARCHAR2,
        p_RECEIVIDPLACE  VARCHAR2,
        p_BANKNAME     VARCHAR2,
        p_CITYBANK     VARCHAR2,
        p_CITYEF     VARCHAR2,
        p_AMT           NUMBER,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);
        v_CUSTNAME      varchar2(100);
        v_FULLNAME      varchar2(200);
        v_ADDRESS       varchar2(250);
        v_LICENSE       varchar2(50);
        v_IDDATE        varchar2(20);
        v_IDPLACE       varchar2(200);
        v_CASHBAL       NUMBER;
        v_FEEAMT        NUMBER;
        v_VATAMT        NUMBER;
        v_TRFAMT        NUMBER;
        v_CUSTODYCD     VARCHAR2(10);

        p_trfcount      number;

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_CashTransferWithIDCode');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CashTransferWithIDCode');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        --Them buoc chan theo quy dinh chong rua tien
        --Doi voi giao dich qua kenh giao dich truc tuyen
        --Kiem tra so tien chuyen khoan toi da
        begin
            if to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1133_AMT')) < p_AMT then
                p_err_code:='-100133';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_ExternalTransfer');
                return;
            end if;
        exception when others then
            plog.error(pkgctx, 'Error: Chua khai bao han muc chuyen khoan tien toi da qua kenh Online');
        end;
        --Kiem tra so lan chuyen khoan toi da
        begin
            select count(1) into p_trfcount from tllog where tltxcd ='1133' and tlid =systemnums.C_ONLINE_USERID and deltd <> 'Y' and txstatus ='1' and msgacct=p_afacctno;

            if to_number(cspks_system.fn_get_sysvar('SYSTEM','ONLINEMAXTRF1133_CNT')) <= p_trfcount then
                p_err_code:='-100134';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_ExternalTransfer');
                return;
            end if;
        exception when others then
            plog.error(pkgctx, 'Error: Chua khai bao so lan chuyen khoan toi da trong mot ngay qua kenh Online');
        end;


        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'INT';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='1133';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        -- Lay thong tin de thuc hien GD
        -- Lay thong tin khach hang
        SELECT CF.custodycd, CF.fullname, CF.fullname, CF.address, CF.idcode, TO_CHAR(CF.iddate,'DD/MM/YYYY'), CF.idplace, getbaldefovd(p_afacctno)
        INTO v_CUSTODYCD, v_CUSTNAME, v_FULLNAME, v_ADDRESS, v_LICENSE, v_IDDATE, v_IDPLACE, v_CASHBAL
        FROM CFMAST CF, AFMAST AF
        WHERE CF.CUSTID = AF.CUSTID AND AF.ACCTNO = p_afacctno;

        -- Lay thong tin phi, bieu phi, thue
        -- Tam thoi de phi, thue = 0
        v_FEEAMT := 0;
        v_VATAMT := 0;
        v_TRFAMT := p_AMT + v_FEEAMT + v_VATAMT;

        -- Kiem tra so tien chuyen khoan
        IF v_TRFAMT > v_CASHBAL THEN
            p_err_code := ERRNUMS.c_CI_CIMAST_BALANCE_NOTENOUGHT;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_CashTransferWithIDCode');
            RETURN;
        END IF;

        --Set cac field giao dich

        --88   CUSTODYCD      C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := v_CUSTODYCD;
        --03   ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno;
        --90   CUSTNAME      C
        --l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        --l_txmsg.txfields ('90').TYPE      := 'C';
        --l_txmsg.txfields ('90').VALUE     := v_CUSTNAME;
        --64   FULLNAME      C
        l_txmsg.txfields ('64').defname   := 'FULLNAME';
        l_txmsg.txfields ('64').TYPE      := 'C';
        l_txmsg.txfields ('64').VALUE     := v_FULLNAME;
        --65   ADDRESS      C
        l_txmsg.txfields ('65').defname   := 'ADDRESS';
        l_txmsg.txfields ('65').TYPE      := 'C';
        l_txmsg.txfields ('65').VALUE     := v_ADDRESS;
        --69   LICENSE      C
        l_txmsg.txfields ('69').defname   := 'LICENSE';
        l_txmsg.txfields ('69').TYPE      := 'C';
        l_txmsg.txfields ('69').VALUE     := v_LICENSE;
        --67   IDDATE      C
        l_txmsg.txfields ('67').defname   := 'IDDATE';
        l_txmsg.txfields ('67').TYPE      := 'C';
        l_txmsg.txfields ('67').VALUE     := v_IDDATE;
        --68   IDPLACE      C
        l_txmsg.txfields ('68').defname   := 'IDPLACE';
        l_txmsg.txfields ('68').TYPE      := 'C';
        l_txmsg.txfields ('68').VALUE     := v_IDPLACE;
        --89   CASTBAL      N
        l_txmsg.txfields ('89').defname   := 'CASTBAL';
        l_txmsg.txfields ('89').TYPE      := 'N';
        l_txmsg.txfields ('89').VALUE     := v_CASHBAL;
        --82   BENEFCUSTNAME      C
        l_txmsg.txfields ('82').defname   := 'BENEFCUSTNAME';
        l_txmsg.txfields ('82').TYPE      := 'C';
        l_txmsg.txfields ('82').VALUE     := p_BENEFCUSTNAME;
        --83   RECEIVLICENSE      C
        l_txmsg.txfields ('83').defname   := 'RECEIVLICENSE';
        l_txmsg.txfields ('83').TYPE      := 'C';
        l_txmsg.txfields ('83').VALUE     := p_RECEIVLICENSE;
        --95   RECEIVIDDATE      C
        l_txmsg.txfields ('95').defname   := 'RECEIVIDDATE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := p_RECEIVIDDATE;
        --96   RECEIVIDPLACE      C
        l_txmsg.txfields ('96').defname   := 'RECEIVIDPLACE';
        l_txmsg.txfields ('96').TYPE      := 'C';
        l_txmsg.txfields ('96').VALUE     := p_RECEIVIDPLACE;
        --05   BANKID      C
        l_txmsg.txfields ('05').defname   := 'BANKID';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := '';
        --80   BANKNAME      C
        --l_txmsg.txfields ('80').defname   := 'BANKNAME';
        --l_txmsg.txfields ('80').TYPE      := 'C';
        --l_txmsg.txfields ('80').VALUE     := p_BANKNAME;
        --81   BENEFBANK      C
        l_txmsg.txfields ('81').defname   := 'BENEFBANK';
        l_txmsg.txfields ('81').TYPE      := 'C';
        l_txmsg.txfields ('81').VALUE     := p_BANKNAME;
        --84   CITYBANK      C
        l_txmsg.txfields ('84').defname   := 'CITYBANK';
        l_txmsg.txfields ('84').TYPE      := 'C';
        l_txmsg.txfields ('84').VALUE     := p_CITYBANK;
        --85   CITYEF      C
        l_txmsg.txfields ('85').defname   := 'CITYEF';
        l_txmsg.txfields ('85').TYPE      := 'C';
        l_txmsg.txfields ('85').VALUE     := p_CITYEF;
        --09   IORO      C
        l_txmsg.txfields ('09').defname   := 'IORO';
        l_txmsg.txfields ('09').TYPE      := 'C';
        l_txmsg.txfields ('09').VALUE     := '0';
        --66   $FEECD      C
        l_txmsg.txfields ('66').defname   := '$FEECD';
        l_txmsg.txfields ('66').TYPE      := 'C';
        l_txmsg.txfields ('66').VALUE     := '';
        --10   AMT      N
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_AMT;
        --11   FEEAMT      N
        l_txmsg.txfields ('11').defname   := 'FEEAMT';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := v_FEEAMT;
        --12   VATAMT      N
        l_txmsg.txfields ('12').defname   := 'VATAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := v_VATAMT;
        --13   TRFAMT      N
        l_txmsg.txfields ('13').defname   := 'TRFAMT';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := v_TRFAMT;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := UTF8NUMS.c_const_TXDESC_1133_OL || '/ ' || v_FULLNAME || '/ ' || v_CUSTODYCD;

        BEGIN
            IF txpks_#1133.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 1812: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_CashTransferWithIDCode');
                RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_CashTransferWithIDCode');
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_CashTransferWithIDCode');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_CashTransferWithIDCode');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_CashTransferWithIDCode;*/

-- LAY THONG TIN LOAI HINH LENH
FUNCTION fn_GetODACTYPE
    (AFACCTNO       IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     CODEID         IN  VARCHAR2,
     TRADEPLACE     IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2,
     PRICETYPE      IN  VARCHAR2,
     TIMETYPE       IN  VARCHAR2,
     AFTYPE         IN  VARCHAR2,
     SECTYPE        IN  VARCHAR2,
     VIA            IN  VARCHAR2
    ) RETURN VARCHAR2
AS

    V_AFACCTNO        VARCHAR2(10);
    V_SYMBOL          VARCHAR2(50);
    V_EXECTYPE        VARCHAR(10);
    V_PRICETYPE       VARCHAR(10);
    V_TIMETYPE        VARCHAR(10);
    V_AFTYPE          VARCHAR(4);
    V_TRADEPLACE      VARCHAR(3);
    V_ODACTYPE          VARCHAR2(4);
    V_SECTYPE         VARCHAR(3);
    V_CODEID          VARCHAR(6);
    V_VIA             VARCHAR2(1);

BEGIN
    V_AFACCTNO := AFACCTNO;
    V_SYMBOL := SYMBOL;
    V_EXECTYPE := EXECTYPE;
    V_PRICETYPE := PRICETYPE;
    V_TIMETYPE := TIMETYPE;
    V_AFTYPE := AFTYPE;
    V_TRADEPLACE := TRADEPLACE;
    V_SECTYPE := SECTYPE;
    V_CODEID := CODEID;
    V_VIA := VIA;

    -- LAY THONG TIN LOAI HINH LENH
    SELECT actype
    INTO V_ODACTYPE
    FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM, A.VATRATE
    FROM odtype a, afidtype b
    WHERE a.status = 'Y'
         AND (a.via = V_VIA OR a.via = 'A') --VIA
         AND a.clearcd = 'B'       --CLEARCD
         AND (a.exectype = V_EXECTYPE           --l_build_msg.fld22
              OR a.exectype = 'AA')                    --EXECTYPE
         AND (a.timetype = V_TIMETYPE
              OR a.timetype = 'A')                     --TIMETYPE
         AND (a.pricetype = V_PRICETYPE
              OR a.pricetype = 'AA')                  --PRICETYPE
         AND (a.matchtype = 'N'
              OR a.matchtype = 'A')                   --MATCHTYPE
         AND (a.tradeplace = V_TRADEPLACE
              OR a.tradeplace = '000')
         AND (instr(case when V_SECTYPE in ('001','002') then V_SECTYPE || ',' || '111,333'
                        when V_SECTYPE in ('003','006') then V_SECTYPE || ',' || '222,333,444'
                        when V_SECTYPE in ('008') then V_SECTYPE || ',' || '111,444'
                        else V_SECTYPE end, a.sectype)>0 OR a.sectype = '000')
         AND (a.nork = 'A') --NORK
         AND (CASE WHEN A.CODEID IS NULL THEN V_CODEID ELSE A.CODEID END)= V_CODEID
         AND a.actype = b.actype and b.aftype = V_AFTYPE and b.objname='OD.ODTYPE'
    --order by b.odrnum DESC, A.deffeerate DESC
    --ORDER BY a.deffeerate DESC, B.ACTYPE DESC -- Lay gia tri ky quy lon nhat
    ORDER BY a.deffeerate, B.ACTYPE DESC -- Lay gia tri ky quy nho nhat
    ) where rownum<=1;

    RETURN V_ODACTYPE;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'fn_GetODACTYPE');
    RETURN '0000';
END;

-- Lay thong tin khoan vay DF tong chua thanh toan
-- TheNN, 06-Feb-2012
PROCEDURE pr_GetGroupDFInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2
     )
    IS

    V_AFACCTNO    VARCHAR2(10);
    V_CURRDATE      DATE;

BEGIN
    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;

    -- LAY THONG TIN KHOAN VAY DF TONG CHUA THANH TOAN
    OPEN p_REFCURSOR FOR
        select DF.GROUPID,DFT.ISVSD,DF.LNACCTNO,CF.CUSTODYCD,CF.fullname,DF.AFACCTNO AFACCTNO,lns.rlsdate, lns.overduedate,lns.autoid,
            DF.ORGAMT, LNS.PAID, V.CURAMT, V.CURINT, V.CURFEE, ln.INTPAID + ln.feeintpaid INTPAID, lns.INTNMLACR, lns.INTOVD,
            GREATEST((V.INTMIN + V.FEEMIN), (V.CURINT + V.CURFEE)) tempint,
            lns.intovdprin+lns.feeintnmlovd tempintovd,
            CASE WHEN V.INTMIN+V.FEEMIN < V.CURINT+V.CURFEE
                THEN ROUND(V.CURAMT +
                     (V.CURAMT * LN.RATE1 * GREATEST (least(LN.MINTERM,LN.PRINFRQ) - TO_NUMBER(V_CURRDATE - TO_DATE(LNS.RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + V.CURAMT * LN.RATE2 * GREATEST (GREATEST(LN.MINTERM-LN.PRINFRQ,0)-GREATEST(V_CURRDATE - TO_DATE(LNS.DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360)
                    + (V.CURAMT * LN.CFRATE1 * GREATEST (least(LN.MINTERM,LN.PRINFRQ) - TO_NUMBER(V_CURRDATE - TO_DATE(LNS.RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + V.CURAMT * LN.CFRATE2 *  GREATEST (GREATEST(LN.MINTERM-LN.PRINFRQ,0)-GREATEST(V_CURRDATE - TO_DATE(LNS.DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360)
                     + V.CURINT + V.CURFEE)
                ELSE ROUND(V.CURAMT + GREATEST((V.INTMIN + V.FEEMIN), (V.CURINT + V.CURFEE))) END SUMAMT,
            DF.DESCRIPTION
        from dfgroup df,dftype dft, lnmast ln, lnschd lns, cfmast cf, afmast af,
            (
            SELECT lnacctno, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE,
                CASE WHEN V_CURRDATE - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURINT ELSE
                     ROUND((CURAMT * (LEAST(Minterm, PRINFRQ)*RATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * RATE2) ) /100/360) END INTMIN,
                CASE WHEN V_CURRDATE - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURFEE ELSE
                      ROUND((CURAMT *   (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * CFRATE2) ) /100/360)  END FEEMIN
            FROM (
                SELECT acctno lnacctno, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, LEAST(MINTERM, TO_NUMBER( TO_DATE(OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')) )  MINTERM, PRINFRQ, RLSDATE, DUEDATE
                FROM (
                        SELECT ln.acctno, ROUND(LNS.NML) + ROUND(LNS.OVD) CURAMT,
                                ROUND(LNS.INTNMLACR) + ROUND(LNS.intdue) + ROUND(LNS.intovd) + ROUND(LNS.intovdprin) CURINT,
                                ROUND(LNS.FEEINTNMLACR) + ROUND(LNS.FEEINTOVDACR) + ROUND(LNS.FEEINTDUE) + ROUND(LNS.FEEINTNMLOVD) CURFEE, LN.INTPAIDMETHOD,
                            LNS.RATE1, LNS.RATE2, LNS.CFRATE1, LNS.CFRATE2, LN.MINTERM, TO_DATE(lns.DUEDATE,'DD/MM/RRRR') -  TO_DATE(lns.RLSDATE,'DD/MM/RRRR') PRINFRQ, LN.RLSDATE,LNS.DUEDATE,lns.OVERDUEDATE
                            FROM (SELECT * FROM lnschd UNION SELECT * FROM lnschdhist) LNS, LNMAST LN, LNTYPE LNT
                        WHERE LN.ACCTNO=LNS.ACCTNO
                            AND LN.ACTYPE=LNT.ACTYPE
                            and REFTYPE='P'
                            and LN.TRFACCTNO LIKE V_AFACCTNO
                    )
                )
            )
            /*(SELECT V.GROUPID,V.CURAMT, V.CURINT, V.CURFEE,
                CASE WHEN V_CURRDATE - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURINT ELSE
                 ROUND((CURAMT * (LEAST(Minterm, PRINFRQ)*RATE1 + GREATEST (0, MINTERM - PRINFRQ) * RATE2)) /100/360,4) END INTMIN,
                CASE WHEN V_CURRDATE - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURFEE ELSE
                  ROUND((CURAMT * (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST(0, MINTERM - PRINFRQ) * CFRATE2))/100/360,4) END FEEMIN
            FROM v_getgrpdealformular v
            WHERE V.afacctno LIKE V_AFACCTNO
            )*/ v
        where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and lns.reftype='P'
            and df.afacctno= af.acctno and af.custid= cf.custid
            AND DF.lnacctno=V.lnacctno
            AND LN.TRFACCTNO LIKE V_AFACCTNO
            AND DFT.ACTYPE=DF.ACTYPE
        ORDER BY LN.ACCTNO;
        /*
        select DF.GROUPID,DF.LNACCTNO,CF.CUSTODYCD,DF.AFACCTNO AFACCTNO,lns.rlsdate, lns.overduedate,
            DF.ORGAMT, LNS.PAID, V.CURAMT, V.CURINT, V.CURFEE, ln.INTPAID + ln.feeintpaid INTPAID, lns.INTNMLACR, lns.INTOVD,
            lns.intnmlacr+lns.intovd+lns.feeintnmlacr+lns.feeintnmlovd tempint,
            lns.intovdprin+lns.feeintnmlovd tempintovd,
            CASE WHEN V.INTMIN+V.FEEMIN < V.CURINT+V.CURFEE
                THEN ROUND(V.CURAMT +
                    ROUND (V.CURAMT * LN.RATE1 * GREATEST (least(LN.MINTERM,LN.PRINFRQ) - TO_NUMBER(V_CURRDATE - TO_DATE(LNS.RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + V.CURAMT * LN.RATE2 * GREATEST (GREATEST(LN.MINTERM-LN.PRINFRQ,0)-GREATEST(V_CURRDATE - TO_DATE(LNS.DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360,4)
                    + ROUND(V.CURAMT * LN.CFRATE1 * GREATEST (least(LN.MINTERM,LN.PRINFRQ) - TO_NUMBER(V_CURRDATE - TO_DATE(LNS.RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + V.CURAMT * LN.CFRATE2 *  GREATEST (GREATEST(LN.MINTERM-LN.PRINFRQ,0)-GREATEST(V_CURRDATE - TO_DATE(LNS.DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360,4)
                     + V.CURINT + V.CURFEE)
                ELSE ROUND(V.CURAMT + GREATEST((V.INTMIN + V.FEEMIN), (V.CURINT + V.CURFEE))) END SUMAMT,
            DF.DESCRIPTION
        from dfgroup df, lnmast ln, lnschd lns, cfmast cf, afmast af, v_getgrpdealformular v
        where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and lns.reftype='P'
            and df.afacctno= af.acctno and af.custid= cf.custid
            AND DF.GROUPID=V.GROUPID
            AND LN.TRFACCTNO LIKE V_AFACCTNO
        ORDER BY LN.ACCTNO;*/

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetGroupDFInfor');
END pr_GetGroupDFInfor;


-- Lay thong tin khoan vay DF chi tiet chua thanh toan
-- TheNN, 06-Feb-2012
PROCEDURE pr_GetDetailDFInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     GROUPDFID      IN  VARCHAR2
     )
    IS

    V_AFACCTNO    VARCHAR2(10);
    V_GROUPDFID   VARCHAR2(50);

BEGIN
    IF AFACCTNO = 'ALL' THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF GROUPDFID = 'ALL' THEN
        V_GROUPDFID := '%%';
    ELSE
        V_GROUPDFID := GROUPDFID;
    END IF;

    -- LAY THONG TIN KHOAN VAY DF TONG CHUA THANH TOAN
    OPEN p_REFCURSOR FOR
        SELECT ceil(TADF-DDF*(IRATE/100)) MINAMTRLS, A.*,
            FLOOR(GREATEST(floor(least (VReleaseDF / ( DFREFPRICE * DFRATE/100), QTTY )),0) / LOT) * LOT MAXRELEASE,
            0 QTTYRELEASE, QTTY *(DFREFPRICE * DFRATE/100) AMTRELEASEALL,
            CASE WHEN A.DEALTYPE = 'N' AND A.dftrading > 0 THEN 'Y' ELSE 'N' END SELLABLE
        FROM
            (
                select DF.LNACCTNO,DF.GROUPID, DF.AFACCTNO||DF.CODEID SEACCTNO, DF.ACCTNO  DFACCTNO,
                    CASE WHEN DF.DEALTYPE='T' THEN 1 ELSE df.TRADELOT END LOT, V.IRATE, V.TADF, V.DDF,
                    V.TADF - (V.IRATE*(DDF)/100 ) VReleaseDF, DF.DFRATE,
                    CASE WHEN DEALTYPE='T' THEN 1 ELSE SEC.DFREFPRICE END dfrefprice, DF.DEALTYPE, sec.symbol,
                    A1.CDCONTENT DEALTYPE_DESC,
                    CASE WHEN DF.DEALTYPE IN('N') THEN DF.DFQTTY - NVL(V1.SECUREAMT,0)
                         WHEN DF.DEALTYPE='B' THEN DF.BLOCKQTTY
                         WHEN DF.DEALTYPE='R' THEN DF.RCVQTTY
                         WHEN DF.DEALTYPE='T' THEN DF.CACASHQTTY
                         ELSE DF.CARCVQTTY END QTTY, df.dftrading
                from v_getdealinfo DF, v_getgrpdealformular v, v_getdealsellorderinfo v1, securities_info sec, ALLCODE A1
                where DF.groupid=v.groupid AND df.codeid=sec.codeid
                    AND DF.DEALTYPE=A1.CDVAL AND A1.CDNAME='DEALTYPE' and DF.ACCTNO=V1.DFACCTNO(+)
                    AND DF.GROUPID LIKE V_GROUPDFID
                    AND DF.AFACCTNO LIKE V_AFACCTNO
            ) A
        ORDER BY A.DFACCTNO;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetDetailDFInfor');
END pr_GetDetailDFInfor;

-- Lay thong tin khoan vay DF tong
-- TheNN, 29-Feb-2012
PROCEDURE pr_GetGroupDFInforAll
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     pv_RowCount    IN OUT  NUMBER,
     pv_PageSize    IN  NUMBER,
     pv_PageIndex   IN  NUMBER,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS

    V_AFACCTNO    VARCHAR2(10);
    v_RowCount    NUMBER;
    v_FromRow     NUMBER;
    v_ToRow       NUMBER;
    V_CURRDATE      date;

BEGIN
    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    SELECT getcurrdate INTO V_CURRDATE FROM dual;

    -- LAY THONG TIN TONG SO DONG DU LIEU LAY RA DE PHAN TRANG
    /*IF pv_RowCount = 0 THEN
        SELECT COUNT(1)
        INTO v_RowCount
        FROM vw_lnmast_all ln
        WHERE LN.TRFACCTNO LIKE V_AFACCTNO
            AND LN.RLSDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
            AND LN.RLSDATE <= TO_DATE(T_DATE,'DD/MM/YYYY');
        pv_RowCount := v_RowCount;
    ELSE
        v_RowCount := pv_RowCount;
    END IF;

    IF pv_PageSize >0 AND pv_PageIndex >0 THEN
        v_FromRow := pv_PageSize*(pv_PageIndex - 1) +1;
        v_ToRow := v_FromRow + pv_PageSize - 1;
    ELSE
        v_FromRow := 1;
        v_ToRow := pv_PageSize;
    END IF;*/

    -- LAY THONG TIN KHOAN VAY DF TONG CHUA THANH TOAN
    OPEN p_REFCURSOR FOR
        /*SELECT A.*
        FROM
            (
            SELECT ROWNUM ROWNUMBER, A.* FROM
                (*/
                SELECT CF.CUSTODYCD, AF.ACCTNO AFACCTNO, LN.ACCTNO LNACCTNO, DF.GROUPID GROUPID, LNS.RLSDATE, LNS.OVERDUEDATE,
                    DF.ORGAMT, LNS.PAID, LNS.NML + LNS.OVD CURAMT,
                    NVL(V.CURINT,0) CURINT, NVL(V.CURFEE,0) CURFEE,ln.INTPAID + ln.feeintpaid INTPAID, LNS.INTNMLACR, LNS.INTOVD,
                    LNS.INTNMLACR+LNS.INTOVD+LNS.FEEINTNMLACR+LNS.FEEINTNMLOVD TEMPINT,
                    LNS.INTOVDPRIN+LNS.FEEINTNMLOVD TEMPINTOVD,
                    CASE WHEN NVL(V.INTMIN,0)+NVL(V.FEEMIN,0) < NVL(V.CURINT,0)+NVL(V.CURFEE,0)
                        THEN ROUND(NVL(V.CURAMT,0) +
                            ROUND (NVL(V.CURAMT,0) * LN.RATE1 * GREATEST (least(LN.MINTERM,LN.PRINFRQ) - TO_NUMBER(V_CURRDATE - TO_DATE(LNS.RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                                + nvl(V.CURAMT,0) * LN.RATE2 * GREATEST (GREATEST(LN.MINTERM-LN.PRINFRQ,0)-GREATEST(V_CURRDATE - TO_DATE(LNS.DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360,4)
                            + ROUND(nvl(V.CURAMT,0) * LN.CFRATE1 * GREATEST (least(LN.MINTERM,LN.PRINFRQ) - TO_NUMBER(V_CURRDATE - TO_DATE(LNS.RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                                + NVL(V.CURAMT,0) * LN.CFRATE2 *  GREATEST (GREATEST(LN.MINTERM-LN.PRINFRQ,0)-GREATEST(V_CURRDATE - TO_DATE(LNS.DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360,4)
                             + NVL(V.CURINT,0) + NVL(V.CURFEE,0))
                        ELSE ROUND(NVL(V.CURAMT,0) + GREATEST((NVL(V.INTMIN,0) + NVL(V.FEEMIN,0)), (NVL(V.CURINT,0) + NVL(V.CURFEE,0)))) END SUMAMT
                FROM DFGROUP DF, VW_LNMAST_ALL LN, VW_LNSCHD_ALL LNS, AFMAST AF , CFMAST CF, LNTYPE LNT, --V_GETGRPDEALFORMULAR V
                    (SELECT V.GROUPID,V.CURAMT, V.CURINT, V.CURFEE,
                        CASE WHEN V_CURRDATE - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURINT ELSE
                         ROUND((CURAMT * (LEAST(Minterm, PRINFRQ)*RATE1 + GREATEST (0, MINTERM - PRINFRQ) * RATE2)) /100/360,4) END INTMIN,
                        CASE WHEN V_CURRDATE - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURFEE ELSE
                          ROUND((CURAMT * (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST(0, MINTERM - PRINFRQ) * CFRATE2))/100/360,4) END FEEMIN
                    FROM v_getgrpdealformular v
                    WHERE V.afacctno LIKE V_AFACCTNO
                    ) v
                WHERE DF.LNACCTNO= LN.ACCTNO AND LN.ACCTNO=LNS.ACCTNO AND LNS.REFTYPE='P'
                    AND DF.AFACCTNO= AF.ACCTNO AND AF.CUSTID= CF.CUSTID
                    AND LNT.ACTYPE = LN.ACTYPE
                    AND DF.GROUPID=V.GROUPID(+)
                    AND LN.TRFACCTNO LIKE V_AFACCTNO
                    AND LN.RLSDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                    AND LN.RLSDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                ORDER BY LN.RLSDATE DESC, LN.ACCTNO;
                /*) A
            ) A
        WHERE A.ROWNUMBER BETWEEN v_FromRow AND v_ToRow;*/


EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetGroupDFInforAll');
END pr_GetGroupDFInforAll;

-- Lay thong tin khoan vay DF chi tiet
-- TheNN, 01-Mar-2012
PROCEDURE pr_GetDetailDFInforAll
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     --pv_RowCount    IN OUT  NUMBER,
     --pv_PageSize    IN  NUMBER,
     --pv_PageIndex   IN  NUMBER,
     AFACCTNO       IN  VARCHAR2,
     GROUPDFID      IN  VARCHAR2
     --F_DATE         IN  VARCHAR2,
     --T_DATE         IN  VARCHAR2
     )
    IS

    V_AFACCTNO    VARCHAR2(10);
    V_GROUPDFID   VARCHAR2(50);
    v_RowCount    NUMBER;
    v_FromRow     NUMBER;
    v_ToRow       NUMBER;

BEGIN
    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF GROUPDFID = 'ALL' OR GROUPDFID IS NULL THEN
        V_GROUPDFID := '%%';
    ELSE
        V_GROUPDFID := GROUPDFID;
    END IF;

    -- LAY THONG TIN TONG SO DONG DU LIEU LAY RA DE PHAN TRANG
    /*IF pv_RowCount = 0 THEN
        SELECT COUNT(1)
        INTO v_RowCount
        FROM VW_DFMAST_ALL DF
        WHERE DF.GROUPID LIKE V_GROUPDFID
            AND DF.AFACCTNO LIKE V_AFACCTNO
            AND DF.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
            AND DF.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY');
        pv_RowCount := v_RowCount;
    ELSE
        v_RowCount := pv_RowCount;
    END IF;

    IF pv_PageSize >0 AND pv_PageIndex >0 THEN
        v_FromRow := pv_PageSize*(pv_PageIndex - 1) +1;
        v_ToRow := v_FromRow + pv_PageSize - 1;
    ELSE
        v_FromRow := 1;
        v_ToRow := pv_PageSize;
    END IF;*/

    -- LAY THONG TIN KHOAN VAY DF CHI TIET
    OPEN p_REFCURSOR FOR
        /*SELECT A.*
        FROM
            (
            SELECT ROWNUM ROWNUMBER, A.* FROM
                (*/
                SELECT DF.GROUPID GROUPID, DF.ACCTNO DFACCTNO, DF.AFACCTNO, DF.TXDATE, SIF.SYMBOL,
                    CASE WHEN DEALTYPE='T' THEN 1 ELSE SIF.DFREFPRICE END dfrefprice,
                    CASE WHEN DF.DEALTYPE IN('N') THEN DF.DFQTTY - NVL(V1.SECUREAMT,0)
                         WHEN DF.DEALTYPE='B' THEN DF.BLOCKQTTY
                         WHEN DF.DEALTYPE='R' THEN DF.RCVQTTY
                         WHEN DF.DEALTYPE='T' THEN DF.CACASHQTTY
                         ELSE DF.CARCVQTTY END QTTY, A1.CDCONTENT DFSTATUS, A2.CDCONTENT DEALTYPE_DESC, DF.DEALTYPE
                FROM VW_DFMAST_ALL DF, SECURITIES_INFO SIF, v_getdealsellorderinfo v1, ALLCODE A1, ALLCODE A2
                WHERE DF.CODEID = SIF.CODEID
                    AND DF.ACCTNO=V1.DFACCTNO(+)
                    AND A1.CDTYPE = 'DF' AND A1.CDNAME = 'DEALSTATUS' AND A1.CDVAL = DF.STATUS
                    AND A2.CDTYPE = 'DF' AND A2.CDNAME='DEALTYPE' AND A2.CDVAL = DF.DEALTYPE
                    AND DF.GROUPID LIKE V_GROUPDFID
                    AND DF.AFACCTNO LIKE V_AFACCTNO
                    --AND DF.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                    --AND DF.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                ORDER BY DF.TXDATE DESC, DF.AFACCTNO, DF.GROUPID, DF.ACCTNO;
                /*) A
            ) A
        WHERE A.ROWNUMBER BETWEEN v_FromRow AND v_ToRow;*/

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetDetailDFInforAll');
END pr_GetDetailDFInforAll;


---------------------------------------------------------------
-- Ham thuc hien thanh toan no cam co online
-- Dau vao: - p_afacctno: So tieu khoan
--          - p_groupdealid: Ma tieu khoan deal tong
--          - p_paidamt: So tien thanh toan
--          - p_desc: Mo ta GD
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 07-Feb-2012
---------------------------------------------------------------
PROCEDURE pr_PaidDealOnline
    (   p_afacctno varchar,
        p_groupdealid    VARCHAR2,
        p_paidamt  number,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);
        v_AMTPAID   NUMBER;
        v_INTPAID   NUMBER;
        v_FEEPAID   NUMBER;
        v_INTPENA   NUMBER;
        v_FEEPENA   NUMBER;
        v_RATEX   NUMBER;
        v_RATEY   NUMBER;
        v_INTMIN   NUMBER;
        v_FEEMIN   NUMBER;
        v_CURAMT   NUMBER;
        v_CURINT   NUMBER;
        v_CURFEE   NUMBER;
        v_INTPAIDMETHOD   varchar2(10);
        v_RATE1   NUMBER;
        v_RATE2   NUMBER;
        v_CFRATE1   NUMBER;
        v_CFRATE2   NUMBER;
        v_MINTERM   NUMBER;
        v_PRINFRQ   NUMBER;
        v_RLSDATE   DATE;
        v_DUEDATE   DATE;
        v_tmppaidamt    NUMBER;
        v_STRDATA   VARCHAR2(5000);
        v_QTTYRELEASE   NUMBER;
        v_TempRLSQTTY   NUMBER;
        v_MINAMTRLS     NUMBER;
        v_IsOK      BOOLEAN;
        V_DESC      VARCHAR2(2000);
        V_SUMAMT    NUMBER;
        V_TMPAMT    NUMBER;

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_PaidDealOnline');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_PaidDealOnline');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        BEGIN
            -- Lay thong tin deal vay tong
            SELECT A.AMTPAID, A.INTPAID, A.FEEPAID, A.INTPENA, A.FEEPENA, A.RATEX, A.RATEY, A.INTMIN, A.FEEMIN,
                A.CURAMT, A.CURINT, A.CURFEE, A.INTPAIDMETHOD, A.RATE1, A.RATE2, A.CFRATE1, A.CFRATE2, A.MINTERM,
                A.PRINFRQ, A.RLSDATE, A.DUEDATE,
                CASE WHEN INTMIN+FEEMIN < CURINT+CURFEE THEN ROUND(CURAMT + INTPENA_CUR + FEEPENA_CUR + CURINT + CURFEE)
                    ELSE ROUND(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE))) END SUMAMT
            INTO v_AMTPAID, v_INTPAID, v_FEEPAID, v_INTPENA, v_FEEPENA, v_RATEX, v_RATEY, v_INTMIN, v_FEEMIN,
                v_CURAMT, v_CURINT, v_CURFEE, v_INTPAIDMETHOD, v_RATE1, v_RATE2, v_CFRATE1, v_CFRATE2, v_MINTERM,
                v_PRINFRQ, v_RLSDATE, v_DUEDATE,V_SUMAMT
            FROM
            (
                SELECT AMTPAID,INTPAID,FEEPAID, ROUND (AMTPAID * RATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + AMTPAID * RATE2 * GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360,0) INTPENA,

                       ROUND(AMTPAID * CFRATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + AMTPAID * CFRATE2 *  GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360,0) FEEPENA,
                       RATEX, RATEY, INTMIN,FEEMIN, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE, INTPENA_CUR, FEEPENA_CUR
                FROM
                (
                    SELECT
                       CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                          CASE WHEN    GREATEST (INTMIN+FEEMIN, CURINT+CURFEE)=0 THEN p_paidamt ELSE ROUND(p_paidamt * (CURAMT/ GREATEST( CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1))) END  ELSE
                            CASE WHEN  round(p_paidamt,0) =round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)) + INTPENA_CUR + FEEPENA_CUR,0) THEN CURAMT ELSE
                             CASE WHEN p_paidamt < CURAMT THEN p_paidamt ELSE case when round(p_paidamt,0) = round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),0) then CURAMT ELSE CURAMT END  END END  END AMTPAID,

                          CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                           CASE WHEN    GREATEST ( INTMIN, CURINT) = 0 THEN 0 ELSE ROUND(p_paidamt * GREATEST(INTMIN, CURINT) / GREATEST( CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1)) END ELSE
                            CASE WHEN  round(p_paidamt,0) =round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)) + INTPENA_CUR + FEEPENA_CUR,0) THEN ROUND(GREATEST ( INTMIN,CURINT ) + INTPENA_CUR,0) ELSE
                                    case when round(p_paidamt,0) = round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),0) then INTMIN ELSE 0 END  END  END INTPAID,

                           CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                             CASE WHEN GREATEST ( FEEMIN, CURFEE) = 0 THEN 0 ELSE ROUND(p_paidamt - ROUND(p_paidamt * (CURAMT/ GREATEST( CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1))) - ROUND(p_paidamt * GREATEST(INTMIN, CURINT) / GREATEST( CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1)) ) END ELSE
                                    CASE WHEN  round(p_paidamt,0) =round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)) + INTPENA_CUR + FEEPENA_CUR,0) THEN ROUND(GREATEST ( FEEMIN,CURFEE ) + FEEPENA_CUR,0) ELSE
                                    case when round(p_paidamt,0) = round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),0) then  FEEMIN ELSE 0 END
                                    END  END FEEPAID,
                        INTPENA_CUR, FEEPENA_CUR,
                        RATEX, RATEY, INTMIN,FEEMIN, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE

                    FROM (

                        SELECT ROUND(CURAMT/ GREATEST( CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1),20) RATEX,  ROUND(GREATEST(INTMIN, CURINT) / GREATEST( CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1),20) RATEY,
                        INTMIN,FEEMIN, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE,

                            ROUND (CURAMT * RATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + CURAMT * RATE2 * GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360) INTPENA_CUR,

                     ROUND(CURAMT * CFRATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                        + CURAMT * CFRATE2 *  GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360) FEEPENA_CUR

                        FROM (
                            SELECT  CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE,

                            CASE WHEN TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURINT ELSE
                             ROUND((CURAMT *   (LEAST(Minterm, PRINFRQ)*RATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * RATE2) ) /100/360) END INTMIN,

                            CASE WHEN TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURFEE ELSE
                              ROUND((CURAMT *   (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * CFRATE2) ) /100/360)  END FEEMIN

                            FROM (
                                SELECT  CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, LEAST(MINTERM, TO_NUMBER( TO_DATE(OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')) )  MINTERM, PRINFRQ, RLSDATE, DUEDATE
                                FROM (
                                        SELECT ROUND(LNS.NML) + ROUND(LNS.OVD) CURAMT,
                                                ROUND(LNS.INTNMLACR) + ROUND(LNS.intdue) + ROUND(LNS.intovd) + ROUND(LNS.intovdprin) CURINT,
                                                ROUND(LNS.FEEINTNMLACR) + ROUND(LNS.FEEINTOVDACR) + ROUND(LNS.FEEINTDUE) + ROUND(LNS.FEEINTNMLOVD) CURFEE, LN.INTPAIDMETHOD,
                                            LNS.RATE1, LNS.RATE2, LNS.CFRATE1, LNS.CFRATE2, LN.MINTERM, TO_DATE(lns.DUEDATE,'DD/MM/RRRR') -  TO_DATE(lns.RLSDATE,'DD/MM/RRRR') PRINFRQ, LN.RLSDATE,LNS.DUEDATE,lns.OVERDUEDATE
                                            FROM (SELECT * FROM lnschd UNION SELECT * FROM lnschdhist) LNS, LNMAST LN, LNTYPE LNT
                                        WHERE LN.ACCTNO in (select lnacctno from dfgroup where groupid= p_groupdealid) AND LN.ACCTNO=LNS.ACCTNO
                                            AND LN.ACTYPE=LNT.ACTYPE
                                            and REFTYPE='P'
                                    )
                                )
                        )
                    )
                )
            ) A;

            -- So sanh gia tri thanh toan voi gia tri toi da con no
            -- Neu so tien nhap vao lon hon so tien can thanh toan toi da thi bao loi
            IF v_CURAMT + ROUND(GREATEST(v_CURFEE+v_CURINT,v_INTMIN+v_FEEMIN)) < p_paidamt THEN
                p_err_code := -260005; -- vuot qua so tien phai thanh toan cho deal
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_PaidDealOnline');
                return;
            END IF;

            -- Lay thong tin chi tiet cac deal vay
            if V_SUMAMT = 0 then
                V_TMPAMT := 10000000000000000;
            else
                V_TMPAMT := to_number(p_paidamt);
            end if;

            --SELECT ceil(TADF-DDF*(IRATE/100)) MINAMTRLS
            SELECT floor(LEAST (TADF- (DDF - V_TMPAMT ) *(IRATE/100), V_TMPAMT *
                    (TA0DF / case when (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE V_SUMAMT END ) =0
                                then 1 else (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE V_SUMAMT END ) end ) )) MINAMTRLS
            INTO v_MINAMTRLS
            FROM v_getgrpdealformular V
            WHERE V.GROUPID = p_groupdealid;

            --v_tmppaidamt := round(p_paidamt + v_MINAMTRLS);
            v_tmppaidamt := round(v_MINAMTRLS);
            v_TempRLSQTTY := 0;
            v_IsOK := TRUE;

            --plog.debug(pkgctx, 'MINAMTRLS: '  || v_MINAMTRLS);
            --plog.debug(pkgctx, 'v_tmppaidamt: '  || v_tmppaidamt);
            FOR rec IN
                (
                    SELECT floor(LEAST (TADF- (DDF - V_TMPAMT ) *(IRATE/100), V_TMPAMT * (TA0DF / case when (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE V_SUMAMT END ) =0 then 1 else (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE V_SUMAMT END ) end ) )) MINAMTRLS, A.*,
                        FLOOR(GREATEST(floor(least (floor(LEAST (TADF- (DDF - V_TMPAMT ) *(IRATE/100), V_TMPAMT * (TA0DF / case when (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE V_SUMAMT END ) =0 then 1 else (CASE WHEN intpaidmethod = 'L' THEN CURAMT ELSE V_SUMAMT END ) end ) )) / ( DFREFPRICE * DFRATE/100), QTTY )),0) / LOT) * LOT MAXRELEASE ,  0 QTTYRELEASE,
                        QTTY * (DFREFPRICE * DFRATE/100) AMTRELEASEALL
                    FROM
                        (
                        select DF.AFACCTNO||DF.CODEID SEACCTNO, DF.ACCTNO,  LN.intpaidmethod,
                        CASE WHEN DF.DEALTYPE='T' THEN 1 ELSE df.TRADELOT END LOT, V.TA0DF , V.CURAMT, V.IRATE, V.TADF, V.DDF, V.TADF - (V.IRATE*(DDF- 0 )/100 ) VReleaseDF, DF.DFRATE,
                         CASE WHEN DEALTYPE='T' THEN 1 ELSE SEC.DFREFPRICE END dfrefprice, DF.DEALTYPE, sec.symbol,A1.CDCONTENT CONTENT,
                         CASE WHEN DF.DEALTYPE IN('N') THEN DF.DFQTTY - NVL(V1.SECUREAMT,0)ELSE  CASE WHEN DF.DEALTYPE='B' THEN DF.BLOCKQTTY
                         ELSE CASE WHEN DF.DEALTYPE='R' THEN DF.RCVQTTY  ELSE CASE WHEN DF.DEALTYPE='T' THEN DF.CACASHQTTY
                         ELSE DF.CARCVQTTY END END END END QTTY, 0 AMTRELEASE
                         from v_getdealinfo DF, v_getgrpdealformular v, v_getdealsellorderinfo v1, securities_info sec , ALLCODE A1 , LNMAST LN
                         where DF.GROUPID= p_groupdealid and DF.groupid=v.groupid AND df.codeid=sec.codeid  AND DF.DEALTYPE=A1.CDVAL AND A1.CDNAME='DEALTYPE'
                         AND V.LNACCTNO = LN.ACCTNO and  DF.ACCTNO=V1.DFACCTNO(+)

                        ) A
                    /*SELECT ceil(TADF-DDF*(IRATE/100)) MINAMTRLS, A.*,
                        FLOOR(GREATEST(floor(least (VReleaseDF / ( DFREFPRICE * DFRATE/100), QTTY )),0) / LOT) * LOT MAXRELEASE,
                        0 QTTYRELEASE, QTTY * (DFREFPRICE * DFRATE/100) AMTRELEASEALL
                    FROM
                        (
                            select DF.AFACCTNO||DF.CODEID SEACCTNO, DF.ACCTNO,
                                CASE WHEN DF.DEALTYPE='T' THEN 1 ELSE df.TRADELOT END LOT, V.IRATE, V.TADF, V.DDF,
                                V.TADF - (V.IRATE*(DDF- p_paidamt)/100 ) VReleaseDF, DF.DFRATE,
                                CASE WHEN DEALTYPE='T' THEN 1 ELSE SEC.DFREFPRICE END dfrefprice, DF.DEALTYPE, sec.symbol,
                                A1.CDCONTENT CONTENT,
                                CASE WHEN DF.DEALTYPE IN('N') THEN DF.DFQTTY - NVL(V1.SECUREAMT,0)
                                    WHEN DF.DEALTYPE='B' THEN DF.BLOCKQTTY
                                    WHEN DF.DEALTYPE='R' THEN DF.RCVQTTY
                                    WHEN DF.DEALTYPE='T' THEN DF.CACASHQTTY
                                    ELSE DF.CARCVQTTY END QTTY, 0 AMTRELEASE
                            from v_getdealinfo DF, v_getgrpdealformular v, v_getdealsellorderinfo v1, securities_info sec, ALLCODE A1
                            where DF.groupid=v.groupid AND df.codeid=sec.codeid
                                AND DF.DEALTYPE=A1.CDVAL AND A1.CDNAME='DEALTYPE' and DF.ACCTNO=V1.DFACCTNO(+)
                                AND DF.GROUPID = p_groupdealid
                                AND DF.AFACCTNO = p_afacctno
                        ) A*/
                )
                LOOP
                    -- Lay thong tin tung deal chi tiet, tinh toan va ghep thanh string
                    v_QTTYRELEASE := 0;
                    v_TempRLSQTTY := 0;
                    --plog.debug(pkgctx, 'v_tmppaidamt: '  || v_tmppaidamt);
                    --plog.debug(pkgctx, 'rec.AMTRELEASEALL: '  || rec.AMTRELEASEALL);
                    IF v_tmppaidamt >= rec.AMTRELEASEALL AND v_IsOK = TRUE THEN
                        v_QTTYRELEASE := round(rec.QTTY);
                        v_tmppaidamt := round(v_tmppaidamt - rec.AMTRELEASEALL);
                        v_IsOK := TRUE;
                        -- Ghep chuoi du lieu
                        v_STRDATA := v_STRDATA || p_groupdealid || '|' || rec.ACCTNO || '|' || rec.AMTRELEASE || '|'
                                    || v_QTTYRELEASE || '|' || v_AMTPAID || '|' || v_INTPAID || '|' || v_FEEPAID || '|'
                                    || v_INTPENA || '|' || v_FEEPENA || '|' || rec.DEALTYPE || '|' || p_paidamt || '@';
                    ELSIF v_IsOK = TRUE THEN
                        IF v_tmppaidamt > 0 THEN
                            v_TempRLSQTTY := v_tmppaidamt/(rec.DFREFPRICE*(rec.DFRATE/100));
                            v_QTTYRELEASE := floor(GREATEST(LEAST(v_TempRLSQTTY,rec.MAXRELEASE),0)/rec.LOT)*rec.LOT;
                            v_tmppaidamt := 0;
                            v_IsOK := FALSE;
                        ELSE
                            v_QTTYRELEASE := 0;
                            v_tmppaidamt := 0;
                            v_IsOK := FALSE;
                        END IF;
                        -- Ghep chuoi du lieu
                        --IF v_QTTYRELEASE >0 then
                            v_STRDATA := v_STRDATA || p_groupdealid || '|' || rec.ACCTNO || '|' || rec.AMTRELEASE || '|'
                                        || v_QTTYRELEASE || '|' || v_AMTPAID || '|' || v_INTPAID || '|' || v_FEEPAID || '|'
                                        || v_INTPENA || '|' || v_FEEPENA || '|' || rec.DEALTYPE || '|' || p_paidamt || '|0|0|0@';
                        --END IF;
                    END IF;
                END LOOP;
        END;

        plog.debug(pkgctx, 'v_STRDATA: '  || v_STRDATA);

        -- Thuc hien GD
        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='2646';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        IF p_desc IS NULL THEN
            SELECT TL.TXDESC
            INTO V_DESC
            FROM TLTX TL WHERE TLTXCD = '2646';
        ELSE
            V_DESC := p_desc;
        END IF;

        --Set cac field giao dich
        --03   AFACCTNO      C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno;
        --20   GROUPID      C
        l_txmsg.txfields ('20').defname   := 'GROUPID';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := p_groupdealid;
        --06   STRDATA      C
        l_txmsg.txfields ('06').defname   := 'STRDATA';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := v_STRDATA;
        --26   SUMPAID      C
        l_txmsg.txfields ('26').defname   := 'SUMPAID';
        l_txmsg.txfields ('26').TYPE      := 'N';
        l_txmsg.txfields ('26').VALUE     := p_paidamt;
        --34   AMTPAID      C
        l_txmsg.txfields ('34').defname   := 'AMTPAID';
        l_txmsg.txfields ('34').TYPE      := 'N';
        l_txmsg.txfields ('34').VALUE     := v_AMTPAID;
        --35   INTPAID      C
        l_txmsg.txfields ('35').defname   := 'INTPAID';
        l_txmsg.txfields ('35').TYPE      := 'N';
        l_txmsg.txfields ('35').VALUE     := v_INTPAID;
        --36   FEEPAID      C
        l_txmsg.txfields ('36').defname   := 'FEEPAID';
        l_txmsg.txfields ('36').TYPE      := 'N';
        l_txmsg.txfields ('36').VALUE     := v_FEEPAID;

        l_txmsg.txfields ('44').defname   := 'ALLOCPRIN';
        l_txmsg.txfields ('44').TYPE      := 'N';
        l_txmsg.txfields ('44').VALUE     := v_AMTPAID;
        --35   INTPAID      N
        l_txmsg.txfields ('45').defname   := 'ALLOCINT';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := v_INTPAID;
        --36   FEEPAID      N
        l_txmsg.txfields ('46').defname   := 'ALLOCFEE';
        l_txmsg.txfields ('46').TYPE      := 'N';
        l_txmsg.txfields ('46').VALUE     := v_FEEPAID;




        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := V_DESC;

        BEGIN
            IF txpks_#2646.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2646: ' || p_err_code
               );
               ROLLBACK;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, 'Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_OnlinePaidDeal');
               RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_OnlinePaidDeal');

    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_PaidDealOnline');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_PaidDealOnline');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_PaidDealOnline;



/*
PROCEDURE pr_PaidDealOnline
    (   p_afacctno varchar,
        p_groupdealid    VARCHAR2,
        p_paidamt  number,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);
        v_AMTPAID   NUMBER;
        v_INTPAID   NUMBER;
        v_FEEPAID   NUMBER;
        v_INTPENA   NUMBER;
        v_FEEPENA   NUMBER;
        v_RATEX   NUMBER;
        v_RATEY   NUMBER;
        v_INTMIN   NUMBER;
        v_FEEMIN   NUMBER;
        v_CURAMT   NUMBER;
        v_CURINT   NUMBER;
        v_CURFEE   NUMBER;
        v_INTPAIDMETHOD   varchar2(10);
        v_RATE1   NUMBER;
        v_RATE2   NUMBER;
        v_CFRATE1   NUMBER;
        v_CFRATE2   NUMBER;
        v_MINTERM   NUMBER;
        v_PRINFRQ   NUMBER;
        v_RLSDATE   DATE;
        v_DUEDATE   DATE;
        v_tmppaidamt    NUMBER;
        v_STRDATA   VARCHAR2(5000);
        v_QTTYRELEASE   NUMBER;
        v_TempRLSQTTY   NUMBER;
        v_MINAMTRLS     NUMBER;
        v_IsOK      BOOLEAN;
        V_DESC      VARCHAR2(2000);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_PaidDealOnline');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_PaidDealOnline');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        BEGIN
            -- Lay thong tin deal vay tong
            SELECT ROUND(AMTPAID) AMTPAID, ROUND(INTPAID) INTPAID, ROUND(FEEPAID) FEEPAID,
                    ROUND (AMTPAID * RATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                    + AMTPAID * RATE2 * GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360) INTPENA,
                 ROUND(AMTPAID * CFRATE1 * GREATEST (least(MINTERM,PRINFRQ) - TO_NUMBER(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')),0 ) /100/360
                    + AMTPAID * CFRATE2 *  GREATEST (GREATEST(MINTERM-PRINFRQ,0)-GREATEST(TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(DUEDATE,'DD/MM/RRRR'),0 ),0) /100/360) FEEPENA,
                   RATEX, RATEY, INTMIN,FEEMIN, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE
            INTO v_AMTPAID, v_INTPAID, v_FEEPAID, v_INTPENA, v_FEEPENA, v_RATEX, v_RATEY, v_INTMIN, v_FEEMIN,
                v_CURAMT, v_CURINT, v_CURFEE, v_INTPAIDMETHOD, v_RATE1, v_RATE2, v_CFRATE1, v_CFRATE2, v_MINTERM, v_PRINFRQ, v_RLSDATE, v_DUEDATE
            FROM
                (
                SELECT
                    CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                      CASE WHEN    GREATEST (INTMIN+FEEMIN, CURINT+CURFEE)=0 THEN p_paidamt ELSE ROUND((p_paidamt * RATEX) /( 1+ RATEX ),4) END  ELSE
                        CASE WHEN  round(p_paidamt,0) = round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),0) THEN CURAMT ELSE
                         CASE WHEN p_paidamt < CURAMT THEN p_paidamt ELSE 0 END END  END AMTPAID,

                      CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                       CASE WHEN    GREATEST ( INTMIN, CURINT) = 0 THEN 0 ELSE ROUND(p_paidamt/( ( 1+ RATEX ) * (1+RATEY) ),4) END ELSE
                        CASE WHEN  round(p_paidamt,0) = round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),0) THEN ROUND(GREATEST ( INTMIN,CURINT ),4) ELSE
                                0 END  END INTPAID,

                       CASE WHEN INTPAIDMETHOD IN ('I','P') THEN
                         CASE WHEN GREATEST ( FEEMIN, CURFEE) = 0 THEN 0 ELSE ROUND((p_paidamt*RATEY)/( ( 1+ RATEX ) * (1+RATEY) ),4) END ELSE
                                CASE WHEN  round(p_paidamt,0) = round(CURAMT + GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),0) THEN ROUND(GREATEST ( FEEMIN,CURFEE ),4) ELSE 0 END  END FEEPAID,
                    RATEX, RATEY, INTMIN,FEEMIN, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE

                FROM (

                    SELECT ROUND(CURAMT/ GREATEST( GREATEST((INTMIN + FEEMIN), (CURINT + CURFEE)),1),4) RATEX,  ROUND(GREATEST(FEEMIN, CURFEE) / GREATEST(GREATEST(INTMIN, CURINT),1),4) RATEY,
                    INTMIN,FEEMIN, CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE

                    FROM (
                        SELECT  CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, MINTERM, PRINFRQ, RLSDATE, DUEDATE,

                        CASE WHEN TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURINT ELSE
                         ROUND((CURAMT *   (LEAST(Minterm, PRINFRQ)*RATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * RATE2) ) /100/360,4) END INTMIN,

                        CASE WHEN TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR') >= MINTERM THEN CURFEE ELSE
                          ROUND((CURAMT *   (LEAST(Minterm, PRINFRQ)* CFRATE1 + GREATEST ( 0 , MINTERM - PRINFRQ) * CFRATE2) ) /100/360,4)  END FEEMIN

                        FROM (
                            SELECT  CURAMT, CURINT, CURFEE, INTPAIDMETHOD, RATE1, RATE2,CFRATE1, CFRATE2, LEAST(MINTERM, TO_NUMBER( TO_DATE(OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(RLSDATE,'DD/MM/RRRR')) )  MINTERM, PRINFRQ, RLSDATE, DUEDATE
                            FROM (SELECT LNS.NML + LNS.OVD CURAMT, LNS.INTNMLACR+LNS.intdue+LNS.intovd + LNS.intovdprin CURINT,
                                    LNS.FEEINTNMLACR + LNS.FEEINTOVDACR + LNS.FEEINTDUE + LNS.FEEINTNMLOVD CURFEE, LN.INTPAIDMETHOD,
                                    LNS.RATE1, LNS.RATE2, LNS.CFRATE1, LNS.CFRATE2, LN.MINTERM, TO_DATE(lns.DUEDATE,'DD/MM/RRRR') -  TO_DATE(lns.RLSDATE,'DD/MM/RRRR') PRINFRQ, LN.RLSDATE,LNS.DUEDATE,lns.OVERDUEDATE
                                    FROM LNSCHD LNS, LNMAST LN
                                WHERE LN.ACCTNO in (select lnacctno from dfgroup where groupid=p_groupdealid) AND LN.ACCTNO=LNS.ACCTNO and REFTYPE='P'
                                )
                            )
                    )
                )
            );

            -- So sanh gia tri thanh toan voi gia tri toi da con no
            -- Neu so tien nhap vao lon hon so tien can thanh toan toi da thi bao loi
            IF v_CURAMT + ROUND(GREATEST(v_CURFEE+v_CURINT,v_INTMIN+v_FEEMIN)) < p_paidamt THEN
                p_err_code := -260005; -- vuot qua so tien phai thanh toan cho deal
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_PaidDealOnline');
                return;
            END IF;

            -- Lay thong tin chi tiet cac deal vay
            SELECT ceil(TADF-DDF*(IRATE/100)) MINAMTRLS
            INTO v_MINAMTRLS
            FROM v_getgrpdealformular V
            WHERE V.GROUPID = p_groupdealid;

            v_tmppaidamt := round(p_paidamt + v_MINAMTRLS);
            v_TempRLSQTTY := 0;
            v_IsOK := TRUE;
            plog.debug(pkgctx, 'MINAMTRLS: '  || v_MINAMTRLS);
            plog.debug(pkgctx, 'v_tmppaidamt: '  || v_tmppaidamt);
            FOR rec IN
                (
                    SELECT ceil(TADF-DDF*(IRATE/100)) MINAMTRLS, A.*,
                        FLOOR(GREATEST(floor(least (VReleaseDF / ( DFREFPRICE * DFRATE/100), QTTY )),0) / LOT) * LOT MAXRELEASE,
                        0 QTTYRELEASE, QTTY *(DFREFPRICE * DFRATE/100) AMTRELEASEALL
                    FROM
                        (
                            select DF.LNACCTNO,DF.GROUPID, DF.AFACCTNO||DF.CODEID SEACCTNO, DF.ACCTNO,
                                CASE WHEN DF.DEALTYPE='T' THEN 1 ELSE df.TRADELOT END LOT, V.IRATE, V.TADF, V.DDF,
                                V.TADF - (V.IRATE*(DDF-p_paidamt)/100 ) VReleaseDF, DF.DFRATE,
                                CASE WHEN DEALTYPE='T' THEN 1 ELSE SEC.DFREFPRICE END dfrefprice, DF.DEALTYPE, sec.symbol,
                                A1.CDCONTENT CONTENT,
                                CASE WHEN DF.DEALTYPE IN('N') THEN DF.DFQTTY - NVL(V1.SECUREAMT,0)
                                    ELSE CASE WHEN DF.DEALTYPE='B' THEN DF.BLOCKQTTY
                                            ELSE CASE WHEN DF.DEALTYPE='R' THEN DF.RCVQTTY
                                                ELSE CASE WHEN DF.DEALTYPE='T' THEN DF.CACASHQTTY
                                                    ELSE DF.CARCVQTTY END END END END QTTY, 0 AMTRELEASE
                            from v_getdealinfo DF, v_getgrpdealformular v, v_getdealsellorderinfo v1, securities_info sec, ALLCODE A1
                            where DF.groupid=v.groupid AND df.codeid=sec.codeid
                                AND DF.DEALTYPE=A1.CDVAL AND A1.CDNAME='DEALTYPE' and DF.ACCTNO=V1.DFACCTNO(+)
                                AND DF.GROUPID = p_groupdealid
                                AND DF.AFACCTNO = p_afacctno
                        ) A
                )
                LOOP
                    -- Lay thong tin tung deal chi tiet, tinh toan va ghep thanh string
                    v_QTTYRELEASE := 0;
                    v_TempRLSQTTY := 0;
                    plog.debug(pkgctx, 'v_tmppaidamt: '  || v_tmppaidamt);
                    plog.debug(pkgctx, 'rec.AMTRELEASEALL: '  || rec.AMTRELEASEALL);
                    IF v_tmppaidamt >= rec.AMTRELEASEALL AND v_IsOK = TRUE THEN
                        v_QTTYRELEASE := round(rec.QTTY);
                        v_tmppaidamt := round(v_tmppaidamt - rec.AMTRELEASEALL);
                        v_IsOK := TRUE;
                        -- Ghep chuoi du lieu
                        v_STRDATA := v_STRDATA || p_groupdealid || '|' || rec.ACCTNO || '|' || rec.AMTRELEASE || '|'
                                    || v_QTTYRELEASE || '|' || v_AMTPAID || '|' || v_INTPAID || '|' || v_FEEPAID || '|'
                                    || v_INTPENA || '|' || v_FEEPENA || '|' || rec.DEALTYPE || '|' || p_paidamt || '@';
                    ELSIF v_IsOK = TRUE THEN
                        IF v_tmppaidamt > 0 THEN
                            v_TempRLSQTTY := v_tmppaidamt/(rec.DFREFPRICE*(rec.DFRATE/100));
                            v_QTTYRELEASE := floor(GREATEST(LEAST(v_TempRLSQTTY,rec.MAXRELEASE),0)/rec.LOT)*rec.LOT;
                            v_tmppaidamt := 0;
                            v_IsOK := FALSE;
                        ELSE
                            v_QTTYRELEASE := 0;
                            v_tmppaidamt := 0;
                            v_IsOK := FALSE;
                        END IF;
                        -- Ghep chuoi du lieu
                        --IF v_QTTYRELEASE >0 then
                            v_STRDATA := v_STRDATA || p_groupdealid || '|' || rec.ACCTNO || '|' || rec.AMTRELEASE || '|'
                                        || v_QTTYRELEASE || '|' || v_AMTPAID || '|' || v_INTPAID || '|' || v_FEEPAID || '|'
                                        || v_INTPENA || '|' || v_FEEPENA || '|' || rec.DEALTYPE || '|' || p_paidamt || '@';
                        --END IF;
                    END IF;
                END LOOP;
        END;

        plog.debug(pkgctx, 'v_STRDATA: '  || v_STRDATA);

        -- Thuc hien GD
        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='2646';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        IF p_desc IS NULL THEN
            SELECT TL.TXDESC
            INTO V_DESC
            FROM TLTX TL WHERE TLTXCD = '2646';
        ELSE
            V_DESC := p_desc;
        END IF;

        --Set cac field giao dich
        --03   AFACCTNO      C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno;
        --20   GROUPID      C
        l_txmsg.txfields ('20').defname   := 'GROUPID';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := p_groupdealid;
        --06   STRDATA      C
        l_txmsg.txfields ('06').defname   := 'STRDATA';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := v_STRDATA;
        --26   SUMPAID      C
        l_txmsg.txfields ('26').defname   := 'SUMPAID';
        l_txmsg.txfields ('26').TYPE      := 'N';
        l_txmsg.txfields ('26').VALUE     := p_paidamt;
        --34   AMTPAID      C
        l_txmsg.txfields ('34').defname   := 'AMTPAID';
        l_txmsg.txfields ('34').TYPE      := 'N';
        l_txmsg.txfields ('34').VALUE     := v_AMTPAID;
        --35   INTPAID      C
        l_txmsg.txfields ('35').defname   := 'INTPAID';
        l_txmsg.txfields ('35').TYPE      := 'N';
        l_txmsg.txfields ('35').VALUE     := v_INTPAID;
        --36   FEEPAID      C
        l_txmsg.txfields ('36').defname   := 'FEEPAID';
        l_txmsg.txfields ('36').TYPE      := 'N';
        l_txmsg.txfields ('36').VALUE     := v_FEEPAID;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := V_DESC;

        BEGIN
            IF txpks_#2646.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2646: ' || p_err_code
               );
               ROLLBACK;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, 'Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_OnlinePaidDeal');
               RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_OnlinePaidDeal');

    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_PaidDealOnline');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_PaidDealOnline');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_PaidDealOnline;
*/

-- Check active host 1
function fn_CheckActiveSystem
    return number
as
    l_status char(1);
    v_HOBRID    VARCHAR(4);
    v_HOSTATUS  VARCHAR(1);
    v_BRSTATUS  VARCHAR(1);
    v_err_code  NUMBER;

BEGIN
    v_err_code := systemnums.C_SUCCESS;
    -- Kiem tra chi nhanh/ hoi so hien tai co active hay ko
    -- Neu bi dong thi ko cho phep dat lenh
    -- LAY MA CHI NHANH HOI SO
    /*SELECT VARVALUE
    INTO v_HOBRID
    FROM SYSVAR
    WHERE GRNAME = 'SYSTEM' AND VARNAME = 'HOBRID';
    -- LAY TRANG THAI CUA CHI NHANH
    SELECT BR.status
    INTO v_BRSTATUS
    FROM BRGRP BR
    WHERE BR.brid = v_HOBRID;
    -- NEU CHI NHANH DONG CUA THI BAO LOI
    IF v_BRSTATUS <> 'A' THEN
        v_err_code:=errnums.C_SA_BDS_OPERATION_ISINACTIVE;
        RETURN v_err_code;
    END IF;*/
    -- LAY TRANG THAI HOI SO
    SELECT VARVALUE
    INTO v_HOSTATUS
    FROM SYSVAR
    WHERE GRNAME = 'SYSTEM' AND VARNAME = 'HOSTATUS';
     -- NEU HOI SO DONG CUA THI BAO LOI
    IF v_HOSTATUS = '0' THEN
        v_err_code:=errnums.C_SA_HOST_OPERATION_ISINACTIVE;
        RETURN v_err_code;
    END IF;
    RETURN v_err_code;
exception
    when others then
        return errnums.C_SYSTEM_ERROR;
end;

-- LAY THONG TIN UNG TRUOC DA THUC HIEN
-- TheNN, 09-Feb-2012
PROCEDURE pr_GetDFTransHistory
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    CUSTODYCD       IN VARCHAR2,
    AFACCTNO       IN  VARCHAR2,
    F_DATE         IN VARCHAR2,
    T_DATE         IN VARCHAR2,
    GROUPDFID      IN VARCHAR2,
    SYMBOL         IN   VARCHAR2
    )
    IS
    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_FROMDATE    DATE;
    V_TODATE      DATE;
    V_GROUPDFID   VARCHAR2(50);
    V_SYMBOL      VARCHAR2(50);

BEGIN
    V_FROMDATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_TODATE := TO_DATE(T_DATE,'DD/MM/YYYY');

    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTODYCD := '%%';
    ELSE
        V_CUSTODYCD := CUSTODYCD;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF GROUPDFID = 'ALL' OR GROUPDFID IS NULL THEN
        V_GROUPDFID := '%%';
    ELSE
        V_GROUPDFID := GROUPDFID;
    END IF;

    IF SYMBOL = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    -- LAY THONG TIN KHOAN VAY DA THUC HIEN
    OPEN p_REFCURSOR FOR
        SELECT A.* FROM
            (
                -- GIAO DICH TAO DEAL CAM CO (CHI TIET)
                SELECT TLG.TXDATE, TLG.TXNUM, TLG.TLTXCD, CF.CUSTODYCD, DFM.AFACCTNO, SE.SYMBOL, DFM.ACCTNO, DFM.GROUPID, DFM.LNACCTNO,
                    DFM.DFQTTY+DFM.RCVQTTY+DFM.BLOCKQTTY+DFM.CARCVQTTY+DFM.BQTTY+DFM.CACASHQTTY DFQTTY, DFM.RLSAMT+DFM.AMT DFAMT,
                    A1.CDCONTENT DFTYPE, DFM.DESCRIPTION
                FROM VW_TLLOG_ALL TLG, VW_DFMAST_ALL DFM, SBSECURITIES SE, AFMAST AF, CFMAST CF, ALLCODE A1
                WHERE TLG.TXDATE = DFM.TXDATE AND TLG.TXNUM = DFM.TXNUM AND DFM.CODEID = SE.CODEID
                    AND AF.CUSTID = CF.CUSTID AND AF.ACCTNO = DFM.AFACCTNO
                    AND TLG.TLTXCD IN ('2673')
                    AND A1.CDTYPE = 'DF' AND A1.CDNAME = 'DEALTYPE' AND A1.CDVAL = DFM.DEALTYPE
                    AND DFM.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                    AND DFM.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    AND CF.CUSTODYCD LIKE V_CUSTODYCD
                    AND DFM.AFACCTNO LIKE V_AFACCTNO
                    AND DFM.GROUPID LIKE V_GROUPDFID
                -- GIAO DICH THANH TOAN DEAL CAM CO (CHI TIET)
                -- CHUA CO LUONG GHI VAO TRAN TRONG BO NEN SE UPDATE SAU
            ) A
        ORDER BY A.TXDATE DESC, SUBSTR(A.TXNUM,5,6) DESC;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetDFTransHistory');
END pr_GetDFTransHistory;


---------------------------------------------------------------
-- Ham thuc hien cap han muc bao lanh tren man hinh MG cho TK luu ky noi khac
-- Dau vao: - p_custodycd: So TK luu ky
--          - p_afacctno: So tieu khoan
--          - p_amount: Han muc cap
--          - p_userid: Ma NSD
--          - p_desc: Mo ta GD
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 16-Feb-2012
---------------------------------------------------------------
PROCEDURE pr_AllocateAVDL3rdAccount
    (   p_custodycd VARCHAR,
        p_afacctno varchar,
        p_amount  number,
        p_userid    varchar,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_AllocateAVDL3rdAccount');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AllocateAVDL3rdAccount');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := p_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='1186';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        --Set cac field giao dich
        --88   CUSTODYCD      C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := p_custodycd;
         --03   ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno;
         --90   CUSTNAME      C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := '';
         --95   FULLNAME      C
        l_txmsg.txfields ('95').defname   := 'FULLNAME';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := '';
         --91   ADDRESS      C
        l_txmsg.txfields ('91').defname   := 'ADDRESS';
        l_txmsg.txfields ('91').TYPE      := 'C';
        l_txmsg.txfields ('91').VALUE     := '';
         --92   LICENSE      C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := '';
         --93   IDDATE      C
        l_txmsg.txfields ('93').defname   := 'IDDATE';
        l_txmsg.txfields ('93').TYPE      := 'C';
        l_txmsg.txfields ('93').VALUE     := '';
         --94   IDPLACE      C
        l_txmsg.txfields ('94').defname   := 'IDPLACE';
        l_txmsg.txfields ('94').TYPE      := 'C';
        l_txmsg.txfields ('94').VALUE     := '';
        --10   TOAMT        N
        l_txmsg.txfields ('10').defname   := 'TOAMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_amount;
        --09   PP0        N
        l_txmsg.txfields ('09').defname   := 'PP0';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := 0;
        --11  NEWPP0        N
        l_txmsg.txfields ('11').defname   := 'NEWPP0';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := 0;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := p_desc;

        BEGIN
            IF txpks_#1186.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 1186: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_AllocateAVDL3rdAccount');
                RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_AllocateAVDL3rdAccount');
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_AllocateAVDL3rdAccount');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_AllocateAVDL3rdAccount');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_AllocateAVDL3rdAccount;

---------------------------------------------------------------
-- Ham thuc hien cap so du CK tren man hinh MG cho TK luu ky noi khac
-- Dau vao: - p_custodycd: So TK luu ky
--          - p_afacctno: So tieu khoan
--          - p_codeid: Ma quy uoc CK
--          - p_qtty: So CK cap them
--          - p_userid: Ma NSD
--          - p_desc: Mo ta GD
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 16-Feb-2012
---------------------------------------------------------------
PROCEDURE pr_AllocateStock3rdAccount
    (   p_custodycd VARCHAR,
        p_afacctno varchar,
        p_symbol    VARCHAR,
        p_qtty  number,
        p_userid    varchar,
        p_desc varchar2,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        l_txmsg         tx.msg_rectype;
        v_strCURRDATE   varchar2(20);
        l_err_param     varchar2(300);
        v_CodeID        varchar2(20);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_AllocateStock3rdAccount');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_AllocateStock3rdAccount');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := p_userid;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='2286';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_afacctno,1,4);

        -- Lay thong tin CK
        SELECT CODEID
        INTO v_CodeID
        FROM SBSECURITIES WHERE SYMBOL = p_symbol;

        --Set cac field giao dich
        --88   CUSTODYCD      C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := p_custodycd;
         --02   AFACCTNO      C
        l_txmsg.txfields ('02').defname   := 'AFACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := p_afacctno;
         --03   ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno||v_CodeID;
         --01   CODEID      C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := v_CodeID;
         --90   CUSTNAME      C
        l_txmsg.txfields ('90').defname   := 'CUSTNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := '';
         --92   LICENSE      C
        l_txmsg.txfields ('92').defname   := 'LICENSE';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := '';
         --95   LICENSEDATE      C
        l_txmsg.txfields ('95').defname   := 'LICENSEDATE';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := '';
         --96   LICENSEPLACE      C
        l_txmsg.txfields ('96').defname   := 'LICENSEPLACE';
        l_txmsg.txfields ('96').TYPE      := 'C';
        l_txmsg.txfields ('96').VALUE     := '';
        --10   QTTY        N
        l_txmsg.txfields ('10').defname   := 'QTTY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_qtty;
        --09   CURRQTTY        N
        l_txmsg.txfields ('09').defname   := 'CURRQTTY';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := 0;
        --11  NEWQTTY        N
        l_txmsg.txfields ('11').defname   := 'NEWQTTY';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := 0;
        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := p_desc;

        BEGIN
            IF txpks_#2286.fn_autotxprocess (l_txmsg,
                                          p_err_code,
                                          l_err_param
                ) <> systemnums.c_success
            THEN
                plog.debug (pkgctx,
                            'got error 2286: ' || p_err_code
                );
                ROLLBACK;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_AllocateStock3rdAccount');
                RETURN;
            END IF;
        END;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_AllocateStock3rdAccount');
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_AllocateStock3rdAccount');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_AllocateStock3rdAccount');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_AllocateStock3rdAccount;

/*FUNCTION fn_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2
AS
    v_Found     BOOLEAN;
    v_TempOrderid   varchar2(20);
    v_TempRootOrderID varchar2(20);

BEGIN
    v_Found := FALSE;
    v_TempOrderid := p_OrderID;

    WHILE v_Found = FALSE
    LOOP
        SELECT NVL(OD.REFORDERID, '0000')
        INTO v_TempRootOrderID
        FROM ODMAST OD WHERE OD.ORDERID = v_TempOrderid;
        IF v_TempRootOrderID <> '0000' THEN
            v_TempOrderid := v_TempRootOrderID;
            v_Found := FALSE;
        ELSE
            v_Found := TRUE;
        END IF;
    END LOOP;

    RETURN v_TempOrderid;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'fn_GetRootOrderID');
    RETURN '0000';
END;*/


PROCEDURE pr_get_gtcorder_root_hist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTID    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     STATUS         IN  VARCHAR2)
    IS

    V_AFACCTNO    VARCHAR2(10);
    V_SYMBOL      VARCHAR2(20);
    V_CUSTID      VARCHAR2(10);
    V_STATUS      VARCHAR2(2);
    V_EXECTYPE    VARCHAR2(2);
--Lay thong tin lenh dieu kien goc
--History
--Date          Who         Comment
--20120225      Loctx       add
BEGIN
    --V_CUSTID := CUSTID;
    --V_AFACCTNO := AFACCTNO;

    IF CUSTID = 'ALL' OR CUSTID IS NULL THEN
        V_CUSTID := '%%';
    ELSE
        V_CUSTID := CUSTID;
    END IF;

    IF SYMBOL = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF EXECTYPE = 'ALL' OR EXECTYPE IS NULL THEN
        V_EXECTYPE := '%%';
    ELSE
        V_EXECTYPE := EXECTYPE;
    END IF;

    IF STATUS = 'ALL' OR STATUS IS NULL THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;

    -- LAY THONG TIN LENH
    OPEN p_REFCURSOR FOR

        SELECT OD.AFACCTNO, OD.ORDERID, OD.TXDATE TXDATE, OD.EXECTYPE,--, A2.CDCONTENT EXECTYPE,
        OD.ORDERQTTY, OD.EXECQTTY, OD.CANCELQTTY, OD.REMAINQTTY,
        OD.QUOTEPRICE, OD.EXPDATE EXPDATE,
        A1.CDCONTENT ORSTATUS, OD.SYMBOL
        FROM
        (
            SELECT OD.AFACCTNO,
                    (CASE
                        WHEN OD.STATUS = 'A' THEN OD.ORGACCTNO
                        ELSE OD.ACCTNO
                    END
                    )ORDERID,
                    OD.EFFDATE TXDATE, OD.EXECTYPE, SB.SYMBOL,
                    OD.QUANTITY ORDERQTTY, OD.EXECQTTY, OD.CANCELQTTY, OD.REMAINQTTY,
                    OD.QUOTEPRICE * 1000 QUOTEPRICE, OD.EXPDATE,
                    /*(CASE
                        WHEN OD.REMAINQTTY > 0 AND OD.STATUS='A' AND OD.EXECQTTY>0 THEN '4'
                        WHEN OD.REMAINQTTY > 0 AND OD.STATUS='A' AND OD.EXECQTTY = 0 THEN '2'
                        WHEN OD.QUANTITY = OD.EXECQTTY AND OD.STATUS='A' THEN '12'
                        ELSE OD.STATUS
                    END
                    )STATUS*/
                    OD.STATUS
            FROM VW_FOMAST_ALL OD, AFMAST AF, SBSECURITIES SB
            WHERE OD.AFACCTNO = AF.ACCTNO
                AND OD.CODEID = SB.CODEID
                AND OD.TIMETYPE ='G'
                AND SUBSTR(OD.EXECTYPE,1,1) <> 'C'
                AND AF.CUSTID LIKE V_CUSTID
                AND AF.ACCTNO LIKE V_AFACCTNO
                AND SB.SYMBOL LIKE V_SYMBOL
                AND OD.STATUS LIKE V_STATUS
                AND OD.EXECTYPE LIKE V_EXECTYPE
                AND OD.EFFDATE >= TO_DATE(F_DATE, SYSTEMNUMS.C_DATE_FORMAT)
                AND OD.EFFDATE <= TO_DATE(T_DATE, SYSTEMNUMS.C_DATE_FORMAT)
        )OD, ALLCODE A1--, ALLCODE A2
        WHERE OD.STATUS = A1.CDVAL
        AND A1.CDTYPE ='FO'
        AND A1.CDNAME = 'STATUS'
        --AND OD.EXECTYPE = A2.CDVAL
        --AND A2.CDTYPE = 'FO'
        --AND A2.CDNAME = 'EXECTYPE'
        ORDER BY OD.AFACCTNO DESC;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
    --plog.error(pkgctx, sqlerrm);
    --plog.setendsection(pkgctx, 'PR_GET_GTCORDER_ROOT_HIST');
END PR_GET_GTCORDER_ROOT_HIST;

-- TRA CUU THONG TIN GIAO DICH THANH TOAN CAM CO
PROCEDURE pr_GetDFPaidHistory
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    pv_RowCount    IN OUT  NUMBER,
    pv_PageSize    IN  NUMBER,
    pv_PageIndex   IN  NUMBER,
    AFACCTNO       IN  VARCHAR2,
    GROUPDFID      IN VARCHAR2,
    F_DATE         IN VARCHAR2,
    T_DATE         IN VARCHAR2
    )
    IS
    V_AFACCTNO    VARCHAR2(10);
    V_FROMDATE    DATE;
    V_TODATE      DATE;
    V_GROUPDFID   VARCHAR2(50);
    v_RowCount    NUMBER;
    v_FromRow     NUMBER;
    v_ToRow       NUMBER;

BEGIN
    V_FROMDATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_TODATE := TO_DATE(T_DATE,'DD/MM/YYYY');

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF GROUPDFID = 'ALL' OR GROUPDFID IS NULL THEN
        V_GROUPDFID := '%%';
    ELSE
        V_GROUPDFID := GROUPDFID;
    END IF;

    -- LAY THONG TIN TONG SO DONG DU LIEU LAY RA DE PHAN TRANG
    /*IF pv_RowCount = 0 THEN
        SELECT COUNT(1)
        INTO v_RowCount
        FROM VW_DFTRAN_ALL DFT
        WHERE DFT.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
            AND DFT.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
            AND DFT.ACCTREF LIKE V_AFACCTNO
            AND DFT.ACCTNO LIKE V_GROUPDFID;
        pv_RowCount := v_RowCount;
    ELSE
        v_RowCount := pv_RowCount;
    END IF;

    IF pv_PageSize >0 AND pv_PageIndex >0 THEN
        v_FromRow := pv_PageSize*(pv_PageIndex - 1) +1;
        v_ToRow := v_FromRow + pv_PageSize - 1;
    ELSE
        v_FromRow := 1;
        v_ToRow := pv_PageSize;
    END IF;*/

    -- LAY THONG TIN KHOAN VAY DA THANH TOAN
    OPEN p_REFCURSOR FOR
        /*SELECT A.*
        FROM
            (
            SELECT ROWNUM ROWNUMBER, A.* FROM
                (*/
                SELECT TLG.TXDATE, TLG.TXNUM, TLG.TLTXCD, CF.CUSTODYCD, DFG.AFACCTNO AFACCTNO, DFG.GROUPID GROUPID, DFG.LNACCTNO LNACCTNO,
                    DFG.ORGAMT RLSAMT, TLG.MSGAMT PAIDAMT, TLG.TXDESC DESCRIPTION, DECODE(SUBSTR(TLG.TXNUM,1,2), '99','MS','PC') METHOD
                FROM (SELECT * FROM VW_TLLOG_ALL WHERE TLTXCD IN ('2646','2648')) TLG,
                    DFGROUP DFG, AFMAST AF, CFMAST CF
                WHERE AF.CUSTID = CF.CUSTID AND AF.ACCTNO = DFG.AFACCTNO
                    AND DFG.GROUPID =  TLG.MSGACCT
                    AND TLG.BUSDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                    AND TLG.BUSDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    AND DFG.AFACCTNO LIKE V_AFACCTNO
                    AND DFG.GROUPID LIKE V_GROUPDFID
                ORDER BY TLG.TXDATE DESC, TLG.AUTOID DESC;
                /*
                SELECT TLG.TXDATE, TLG.TXNUM, TLG.TLTXCD, CF.CUSTODYCD, DFG.AFACCTNO AFACCTNO, DFG.GROUPID GROUPID, DFG.LNACCTNO LNACCTNO,
                    DFG.ORGAMT RLSAMT, DFT.NAMT PAIDAMT, TLG.TXDESC DESCRIPTION
                FROM (SELECT * FROM VW_TLLOG_ALL WHERE TLTXCD IN ('2646','2648')) TLG,
                    DFGROUP DFG, VW_DFTRAN_ALL DFT, AFMAST AF, CFMAST CF
                WHERE TLG.TXDATE = DFT.TXDATE AND TLG.TXNUM = DFT.TXNUM
                    AND AF.CUSTID = CF.CUSTID AND AF.ACCTNO = DFG.AFACCTNO
                    AND DFG.GROUPID =  DFT.ACCTNO
                    AND TLG.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                    AND TLG.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    AND DFG.AFACCTNO LIKE V_AFACCTNO
                    AND DFG.GROUPID LIKE V_GROUPDFID
                ORDER BY TLG.TXDATE DESC, TLG.AUTOID DESC, SUBSTR(TLG.TXNUM,5,6) DESC*/
                /*) A
            ) A
        WHERE A.ROWNUMBER BETWEEN v_FromRow AND v_ToRow;*/
                -- GIAO DICH THANH TOAN DEAL CAM CO (CHI TIET)
                -- CHUA CO LUONG GHI VAO TRAN TRONG BO NEN SE UPDATE SAU

                /*
                -- GIAO DICH TAO DEAL CAM CO (CHI TIET)
                SELECT TLG.TXDATE, TLG.TXNUM, TLG.TLTXCD, CF.CUSTODYCD, DFM.AFACCTNO, SE.SYMBOL, DFM.ACCTNO, DFM.GROUPID, DFM.LNACCTNO,
                    DFM.DFQTTY+DFM.RCVQTTY+DFM.BLOCKQTTY+DFM.CARCVQTTY+DFM.BQTTY+DFM.CACASHQTTY DFQTTY, DFM.RLSAMT+DFM.AMT DFAMT,
                    A1.CDCONTENT DFTYPE, DFM.DESCRIPTION
                FROM VW_TLLOG_ALL TLG, VW_DFMAST_ALL DFM, SBSECURITIES SE, AFMAST AF, CFMAST CF, ALLCODE A1
                WHERE TLG.TXDATE = DFM.TXDATE AND TLG.TXNUM = DFM.TXNUM AND DFM.CODEID = SE.CODEID
                    AND AF.CUSTID = CF.CUSTID AND AF.ACCTNO = DFM.AFACCTNO
                    AND TLG.TLTXCD IN ('2673')
                    AND A1.CDTYPE = 'DF' AND A1.CDNAME = 'DEALTYPE' AND A1.CDVAL = DFM.DEALTYPE
                    AND DFM.TXDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
                    AND DFM.TXDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
                    AND CF.CUSTODYCD LIKE V_CUSTODYCD
                    AND DFM.AFACCTNO LIKE V_AFACCTNO
                    AND DFM.GROUPID LIKE V_GROUPDFID
                -- GIAO DICH THANH TOAN DEAL CAM CO (CHI TIET)
                -- CHUA CO LUONG GHI VAO TRAN TRONG BO NEN SE UPDATE SAU
                */
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetDFPaidHistory');
END pr_GetDFPaidHistory;

-- LAY CHI TIET SO CK GIAI TOA (GD 2246 ONLY)
-- THENN, 04-MAR-2012
PROCEDURE pr_GetDFPaidDetail
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    pv_TXDATE       IN  VARCHAR2,
    pv_TXNUM      IN VARCHAR2
    )
    IS

BEGIN

    -- LAY THONG TIN KHOAN VAY DA THANH TOAN
    OPEN p_REFCURSOR FOR
        SELECT DFT.TXDATE, DFT.TXNUM, DFT.TLTXCD, DF.AFACCTNO AFACCTNO, DF.GROUPID GROUPID, DF.LNACCTNO LNACCTNO,
            SB.SYMBOL, DFT.NAMT PAIDQTTY
        FROM DFMAST DF, AFMAST AF, sbsecurities SB,
            (SELECT * FROM vw_dftran_all
            WHERE TLTXCD = '2646'
                AND TXDATE = TO_DATE(pv_TXDATE,'DD/MM/YYYY')
                AND TXNUM = pv_TXNUM
                AND TXCD ='0011'
                ) DFT
        WHERE AF.ACCTNO = DF.AFACCTNO
            AND DF.acctno = DFT.ACCTNO
            AND DF.codeid = SB.codeid
        ORDER BY DFT.TXDATE DESC, DFT.AUTOID DESC;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetDFPaidDetail');
END pr_GetDFPaidDetail;

---------------------------------------------------------------
-- Ham thuc hien cap nhat suc mua cho man hinh moi gioi
-- Dau vao: - p_afacctno: So tieu khoan
-- Dau ra:  - p_err_code: Ma loi tra ve. =0: thanh cong. <>0: Loi
--          - p_err_message: thong bao loi neu ma loi <>0
-- Created by: TheNN     Date: 30-Mar-2012
---------------------------------------------------------------
PROCEDURE pr_RefreshCIAccount
    (   p_afacctno varchar,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2
    )
    IS
        v_strAFACCTNO   varchar2(20);

    BEGIN
        plog.setbeginsection(pkgctx, 'pr_RefreshCIAccount');
        p_err_code := 0;
        p_err_message := '';

        IF p_afacctno IS NULL OR p_afacctno = '' THEN
            plog.setendsection(pkgctx, 'pr_RefreshCIAccount');
            RETURN;
        ELSE
            v_strAFACCTNO := p_afacctno;
            jbpks_auto.pr_gen_buf_ci_account(v_strAFACCTNO);
        END IF;
        p_err_code:=0;
        plog.setendsection(pkgctx, 'pr_RefreshCIAccount');
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_RefreshCIAccount');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_RefreshCIAccount');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_RefreshCIAccount;
--Binhpt tra cuu c?su kien quyen kh? h?
--F_DATE tu ngay
--T_DATE den ngay
--PV_CUSTODYCD so luu ky
--PV_AFACCTNO so tieu khoan
--V_STRISCOM Da phan bo hay chua
procedure pr_get_rightinfo
    (p_refcursor in out pkg_report.ref_cursor,
    F_DATE in VARCHAR2,
    T_DATE  IN  varchar2,
    PV_CUSTODYCD  IN  VARCHAR2,
    PV_AFACCTNO  IN  VARCHAR2,
    ISCOM             IN       VARCHAR2)
IS
    V_STRACCTNO    VARCHAR2 (20);
    V_STRCUSTODYCD     VARCHAR2 (20);
    V_STRISCOM   VARCHAR2 (40);
begin
    plog.setbeginsection(pkgctx, 'pr_get_rightinfo');
    IF (ISCOM = 'Y')
   THEN
   V_STRISCOM := 'JC';
   ELSIF  (ISCOM = 'N')
   THEN
   V_STRISCOM := 'MAIPNSDRGHVBEW';
   ELSE
   V_STRISCOM := 'MAIPNSCDRGHJVBEW';
   END IF;

    IF PV_CUSTODYCD = 'ALL' OR PV_CUSTODYCD is NULL THEN
        V_STRCUSTODYCD := '%%';
    ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
    END IF;

    IF PV_AFACCTNO = 'ALL' OR PV_AFACCTNO IS NULL THEN
        V_STRACCTNO := '%%';
    ELSE
        V_STRACCTNO := PV_AFACCTNO;
    END IF;
    Open p_refcursor for
          SELECT ca.acctno, ca.custodycd, ca.fullname, ca.mobile, ca.idcode,
        ca.trade SLCKSH,TYLE,CATYPE,  STATUS, Ca.CAMASTID, CA.AMT,SYMBOL,
        TOSYMBOL, TOCODEID, REPORTDATE, SLCKCV, STCV, ACTIONDATE, ca.CODEID, CASTATUS
FROM
(SELECT AF.ACCTNO, CF.CUSTODYCD, CF.FULLNAME, CF.MOBILE, CF.IDCODE, CAS.BALANCE ,
            (DECODE(CAM.CATYPE, '001',DEVIDENTRATE,
                                '010',(case when devidentvalue = 0 and DEVIDENTRATE <> '0' then DEVIDENTRATE || '%' else to_char(devidentvalue) end),
                                '002',DEVIDENTSHARES,
                                '011',DEVIDENTSHARES,
                                '003',RIGHTOFFRATE,
                                '014',RIGHTOFFRATE,
                                '004',SPLITRATE,
                                '012',SPLITRATE,
                                '006',DEVIDENTSHARES,
                                '005',devidentshares,
                                '022',DEVIDENTSHARES,
                                '021',EXRATE,
                                '023',EXRATE,
                                '007',INTERESTRATE,
                                '008',EXRATE,
                                '017',EXRATE,
                                '015',interestrate || '%',
                                '016',interestrate || '%',
                                '020',devidentshares
                                )
                ) TYLE,
            A0.CDCONTENT CATYPE,  A1.CDCONTENT STATUS, CAM.CAMASTID, CAS.AMT
            , SE.SYMBOL, CAM.REPORTDATE,  CAS.QTTY SLCKCV, CAS.AMT STCV, CAM.ACTIONDATE,
            SE.CODEID CODEID, NVL(SB2.SYMBOL,se.symbol) TOSYMBOL, NVL(CAM.TOCODEID,CAM.CODEID) TOCODEID,
            CAM.STATUS CASTATUS, cas.trade, cam.catype typeca
        FROM CASCHD CAS, SBSECURITIES SE, CAMAST CAM, AFMAST AF, CFMAST CF, ALLCODE A0, ALLCODE A1, SBSECURITIES SB2
        WHERE CAS.CODEID = SE.CODEID
        AND NVL(TOCODEID,CAM.codeid) = SB2.CODEID
        AND CAM.CAMASTID = CAS.CAMASTID
        AND CAS.AFACCTNO = AF.ACCTNO
        AND AF.CUSTID = CF.CUSTID
        AND A0.CDTYPE = 'CA' AND A0.CDNAME = 'CATYPE' AND A0.CDVAL = CAM.CATYPE
        AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = CAS.STATUS
        AND CAM.CATYPE NOT IN ('002','019')
        AND CAS.AFACCTNO  LIKE V_STRACCTNO
        and cas.deltd <>'Y'
        and cam.deltd <>'Y'
) CA
WHERE (( CA.CASTATUS NOT IN ('A','N','P'))OR (CA.CASTATUS IN ('S','W','I','C','J','I','H')))
AND INSTR(V_STRISCOM, CA.CASTATUS )> 0
AND CA.REPORTDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND CA.REPORTDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
ORDER  BY SUBSTR(CA.CAMASTID,11,6) DESC;
    plog.setendsection(pkgctx, 'pr_get_rightinfo');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_rightinfo');
end pr_get_rightinfo;

-- Lay danh sach chuyen doi trai phieu thanh co phieu
-- TheNN, 16-Jul-2012
PROCEDURE pr_GetBonds2SharesList
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_CUSTID      VARCHAR2(10);

BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF V_CUSTODYCD IS NULL OR V_CUSTODYCD = 'ALL' THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;


    -- LAY THONG TIN GD QUYEN MUA
    OPEN p_REFCURSOR FOR
        SELECT CA.CAMASTID,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,SEC1.SYMBOL,SEC2.SYMBOL TOSYMBOL,
            CA.REPORTDATE,SCHD.PQTTY,SCHD.TRADE,(SCHD.PQTTY+SCHD.QTTY) MAXQTTY,
            SCHD.QTTY,CA.BEGINDATE,CA.DUEDATE,SCHD.AUTOID,SEC1.CODEID,SEC2.CODEID TOCODEID,CA.EXRATE
        FROM CAMAST CA, CASCHD SCHD,CFMAST CF, AFMAST AF,SBSECURITIES SEC1, SBSECURITIES SEC2
        WHERE CA.CAMASTID=SCHD.CAMASTID
            AND SCHD.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
            AND CA.CODEID=SEC1.CODEID AND CA.TOCODEID=SEC2.CODEID
            AND TO_DATE(CA.BEGINDATE,'DD/MM/YYYY') <= TO_DATE(GETCURRDATE,'DD/MM/YYYY')
            AND TO_DATE(CA.DUEDATE,'DD/MM/YYYY') >= TO_DATE(GETCURRDATE,'DD/MM/YYYY')
            AND CA.CATYPE='023' AND SCHD.STATUS='V'
            AND SCHD.PQTTY>=1
            AND SCHD.DELTD='N'
            AND CF.CUSTID LIKE V_CUSTID
            AND AF.ACCTNO LIKE V_AFACCTNO
        ORDER BY CA.CAMASTID;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetBonds2SharesList');
END pr_GetBonds2SharesList;

-- Lay danh sach thuc hien quyen

PROCEDURE pr_GetListCaschd
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     CATYPE         IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_CUSTID      VARCHAR2(10);
    V_SYMBOL      VARCHAR2(100);
    V_CATYPE      VARCHAR2(10);
    V_FDATE       VARCHAR2(100);
    V_TDATE       VARCHAR2(100);
BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    -- LAY THONG TIN MA KHACH HANG
    IF V_CUSTODYCD IS NULL OR V_CUSTODYCD = 'ALL' THEN
        V_CUSTID := '%%';
    ELSE
        SELECT CUSTID INTO V_CUSTID FROM CFMAST WHERE CUSTODYCD = V_CUSTODYCD;
    END IF;

    IF  upper(SYMBOL) = 'ALL' OR SYMBOL IS NULL THEN
        V_SYMBOL := '%%';
    ELSE
        V_SYMBOL := SYMBOL;
    END IF;

    IF upper(CATYPE) = 'ALL' OR CATYPE IS NULL THEN
        V_CATYPE := '%%';
    ELSE
        V_CATYPE := CATYPE;
    END IF;

   IF F_DATE IS NULL THEN
       V_FDATE := '01/01/2000';
       ELSE
       V_FDATE := F_DATE;
    END IF;

   IF T_DATE IS NULL THEN
       V_TDATE := '01/01/3000';
       ELSE
       V_TDATE := T_DATE;
    END IF;


    -- LAY THONG TIN GD QUYEN MUA
  OPEN p_REFCURSOR FOR
       SELECT getprevdate(REPORTDATE,3) KHQDATE, SB.symbol,AL.cdcontent CATYPE , AL.en_cdcontent EN_CATYPE ,CA.reportdate,CA.duedate,CA.actiondate,SUM(CAS.trade) TRADE,
(CASE WHEN EXRATE IS NOT NULL THEN EXRATE ELSE (CASE WHEN RIGHTOFFRATE IS NOT NULL
       THEN RIGHTOFFRATE ELSE (CASE WHEN DEVIDENTRATE IS NOT NULL THEN DEVIDENTRATE  ELSE
       (CASE WHEN SPLITRATE IS NOT NULL THEN SPLITRATE ELSE (CASE WHEN INTERESTRATE IS NOT NULL
       THEN INTERESTRATE ELSE
       (CASE WHEN DEVIDENTSHARES IS NOT NULL THEN DEVIDENTSHARES ELSE '0' END)END)END)END) END)END) RATE,SUM (QTTY) QTTY,SUM(AMT) AMT
       ,AL1.cdcontent CASTATUS ,al1.en_cdcontent EN_CASTATUS
FROM CASCHD CAS, CAMAST CA, sbsecurities SB, ALLCODE AL, allcode AL1, afmast  af
WHERE CAS.camastid = CA.camastid
and CAS.afacctno = AF.acctno
AND CAS.deltd <> 'Y'
AND CAS.codeid = SB.codeid
AND CA.catype = AL.cdval
AND AL.cdname ='CATYPE'
AND AL1.cdname ='CAONLSTATUS'
AND CASE WHEN  CAS.status IN ('C','J') THEN 'C' ELSE 'P' END  = AL1.cdval
AND AF.CUSTID = V_CUSTID
AND ca.catype like V_CATYPE
and sb.symbol like V_SYMBOL
AND  CA.reportdate  BETWEEN TO_DATE( V_FDATE,'DD/MM/YYYY') AND TO_DATE( V_TDATE,'DD/MM/YYYY')
GROUP BY SB.symbol,AL.cdcontent ,CA.reportdate,CA.duedate,CA.actiondate,CAS.camastid ,EXRATE,RIGHTOFFRATE,SPLITRATE,INTERESTRATE,
 DEVIDENTSHARES ,DEVIDENTRATE,AL1.cdcontent,af.custid,AL.en_cdcontent,AL1.en_cdcontent
ORDER BY CAS.CAMASTID;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetListCaschd');
END pr_GetListCaschd;

PROCEDURE pr_GetListOrderNtoT
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN VARCHAR2
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
 BEGIN
    V_CUSTODYCD := CUSTODYCD;
    --V_AFACCTNO := AFACCTNO;


    -- LAY THONG TIN GD QUYEN MUA
  OPEN p_REFCURSOR FOR
  SELECT  cf.custodycd,cf.custid, af.acctno afacctno,cf.fullname, cf.idcode,sts.amt MATCHAMT, sts.qtty MATCHQTTY, sts.txdate,sts1.cleardate,
sb.symbol ,od.orderid,sts.codeid,od.ORDERQTTY,od.QUOTEPRICE,STS1.ACCTNO SEACCTNO
FROM stschd sts, stschd sts1,afmast af, cfmast cf,sbsecurities sb,
     odmast od , aftype aft,mrtype mr
where sts.orgorderid = sts1.orgorderid
and sts.afacctno = af.acctno
and af.custid = cf.custid
and sts.codeid = sb.codeid
and af.actype = aft.actype
and aft.mrtype = mr.actype
AND sts.duetype='SM' AND sts.deltd<>'Y' AND STS.STATUS ='C'
AND sts1.duetype='RS' AND sts1.deltd<>'Y' AND STS1.STATUS ='N'
and mr.mrtype = 'N'
and od.orderid = sts.orgorderid
and cf.custodycd = V_CUSTODYCD
;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetListOrderNtoT');
END pr_GetListOrderNtoT;

PROCEDURE pr_GetListODPROBRKAF
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTODYCD      IN VARCHAR2 DEFAULT 'ALL',
     p_TLID         IN VARCHAR2
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
 BEGIN


   IF (UPPER(P_CUSTODYCD) <> 'ALL')
   THEN
      V_CUSTODYCD := P_CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%';
   END IF;

    --V_AFACCTNO := AFACCTNO;


 OPEN p_REFCURSOR FOR
SELECT RF.AUTOID, RF.REFAUTOID, RF.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TYP.TYPENAME, RF.VALDATE, RF.EXPDATE, A1.CDCONTENT STATUS,
   MST.FULLNAME ODPRONAME, MST.AUTOID ODPROID,RECUSTID,REFULLNAME,cftype.typename cftypename
FROM ODPROBRKAF RF, CFMAST CF, AFMAST AF, AFTYPE TYP, ALLCODE A1, ODPROBRKMST MST,cftype ,
(SELECT RE.AFACCTNO, MAX( CF.FULLNAME) REFULLNAME ,MAX(CF.CUSTID) reCUSTID
                    FROM reaflnk re, retype ret,cfmast cf
                    WHERE substr( re.reacctno,11) = ret.actype
                    AND substr(re.reacctno,1,10) = cf.custid
                    AND ret.rerole IN ('RM','CS')
                    AND RE.status ='A'
                    GROUP BY AFACCTNO) re

WHERE RF.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND AF.ACTYPE=TYP.ACTYPE
AND A1.CDTYPE = 'SA' AND A1.CDNAME = 'STATUS' AND RF.STATUS = A1.CDVAL
AND RF.REFAUTOID = MST.AUTOID
AND rf.status ='A'
AND CF.custodycd LIKE V_CUSTODYCD
AND cf.actype = cftype.actype
AND AF.CUSTID = RE.AFACCTNO(+)
AND EXISTS(SELECT *
                                FROM tlgrpusers tl, tlgroups gr
                                WHERE AF.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE p_TLID
                                )
ORDER BY CF.CUSTODYCD, RF.AFACCTNO
;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetListODPROBRKAF');
END pr_GetListODPROBRKAF;

PROCEDURE pr_GetListCFOTHERACC
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTODYCD      IN VARCHAR2 ,
     p_TLID         IN VARCHAR2
     )
    IS

    V_CUSTODYCD   VARCHAR2(10);
 BEGIN



      V_CUSTODYCD := P_CUSTODYCD;


    --V_AFACCTNO := AFACCTNO;


 OPEN p_REFCURSOR FOR
SELECT CFO.* FROM CFOTHERACC CFO, CFMAST CF
WHERE TYPE =1
AND CFO.cfcustid = CF.CUSTID
AND CF.custodycd = V_CUSTODYCD
AND EXISTS(SELECT *
                                FROM tlgrpusers tl, tlgroups gr
                                WHERE CF.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE p_TLID
                                )
ORDER BY CF.CUSTODYCD
;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetListCFOTHERACC');
END pr_GetListCFOTHERACC;



-- Ham thuc hien dang ky chuyen doi trai phieu thanh co phieu
-- TheNN, 16-Jul-2012
PROCEDURE pr_Bonds2SharesRegister
    (p_caschdautoid IN   varchar,
    p_afacctno   IN   varchar,
    p_qtty      IN   number,
    p_desc      IN   varchar2,
    p_err_code  OUT varchar2,
    p_err_message  OUT varchar2
    )
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      l_symbol  varchar2(20);
      l_tosymbol    varchar2(20);
      l_codeid   varchar2(20);
      l_tocodeid    varchar2(20);
      l_camastid varchar2(20);
      l_fullname    varchar2(100);
      l_custodycd   varchar2(10);
      l_PQTTY   NUMBER;

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_Bonds2SharesRegister');

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Bonds2SharesRegister');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3327';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_afacctno,1,4);

    --p_txnum:=l_txmsg.txnum;
    --p_txdate:=l_txmsg.txdate;

    SELECT CA.CAMASTID,CF.CUSTODYCD,SEC1.SYMBOL,SEC2.SYMBOL TOSYMBOL,
        SEC1.CODEID,SEC2.CODEID TOCODEID,SCHD.PQTTY
    INTO l_camastid, l_custodycd, l_symbol, l_tosymbol, l_codeid, l_tocodeid, l_PQTTY
    FROM CAMAST CA, CASCHD SCHD,CFMAST CF, AFMAST AF,SBSECURITIES SEC1, SBSECURITIES SEC2
    WHERE CA.CAMASTID=SCHD.CAMASTID
        AND SCHD.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
        AND CA.CODEID=SEC1.CODEID AND CA.TOCODEID=SEC2.CODEID
        AND CA.CATYPE='023' AND SCHD.STATUS='V'
        AND SCHD.PQTTY>=1
        AND SCHD.DELTD='N'
        AND schd.autoid = p_caschdautoid;

    -- Kiem tra SL dang ky khong duoc vuot qua SL con co the dang ky
    IF p_qtty > l_PQTTY THEN
        p_err_code := -300021; -- Vuot qua so CK duoc phep mua
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Bonds2SharesRegister');
        return;
    END IF;


    --Set cac field giao dich
    --01   AUTOID      C
    l_txmsg.txfields ('01').defname   := 'AUTOID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := p_caschdautoid;
    --02   CAMASTID      C
    l_txmsg.txfields ('02').defname   := 'CAMASTID';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := l_camastid;
    --03   AFACCTNO      C
    l_txmsg.txfields ('03').defname   := 'AFACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_afacctno;
    --04   SYMBOL        C
    l_txmsg.txfields ('04').defname   := 'SYMBOL';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := l_symbol;
    --05   TOSYMBOL        C
    l_txmsg.txfields ('05').defname   := 'TOSYMBOL';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := l_tosymbol;
    --08   FULLNAME      C
    l_txmsg.txfields ('08').defname   := 'FULLNAME';
    l_txmsg.txfields ('08').TYPE      := 'C';
    l_txmsg.txfields ('08').VALUE     := l_fullname;
    --10   QTTY          N
    l_txmsg.txfields ('10').defname   := 'QTTY';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := p_qtty;
    --21   CODEID        C
    l_txmsg.txfields ('21').defname   := 'CODEID';
    l_txmsg.txfields ('21').TYPE      := 'C';
    l_txmsg.txfields ('21').VALUE     := l_codeid;
    --24   TOCODEID        C
    l_txmsg.txfields ('24').defname   := 'TOCODEID';
    l_txmsg.txfields ('24').TYPE      := 'C';
    l_txmsg.txfields ('24').VALUE     := l_tocodeid;
    --30   DESCRIPTION   C
    l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := p_desc;
    --96   CUSTODYCD    C
    l_txmsg.txfields ('96').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE     := l_custodycd;

    plog.error(pkgctx, 'AUTOID:'  || p_caschdautoid);
    plog.error(pkgctx, 'CAMASTID:'  || l_camastid);

    BEGIN
        IF txpks_#3327.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.error (pkgctx,
                       'got error 3327: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:3327: '  || p_err_message);
           plog.setendsection(pkgctx, 'pr_Bonds2SharesRegister');
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_Bonds2SharesRegister');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on pr_Bonds2SharesRegister');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, 'got error on pr_Bonds2SharesRegister'||SQLERRM);
      plog.setendsection (pkgctx, 'pr_Bonds2SharesRegister');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Bonds2SharesRegister;

  --Binhpt lay thong tin du no
  --Lay thong tin du no
PROCEDURE pr_LoanHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS
    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
BEGIN
    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;
    IF CUSTODYCD IS NULL OR CUSTODYCD = 'ALL' THEN
        V_CUSTODYCD := '%%';
    ELSE
        V_CUSTODYCD:=CUSTODYCD;
    END IF;
    -- LAY THONG TIN DU NO
    OPEN p_REFCURSOR FOR
        SELECT V_DEAL.GROUPID,TY.TYPENAME, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, LN.ACCTNO LNACCTNO,
                 ROUND( SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR+SCHD.INTNMLACR  + SCHD.INTOVD + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTNMLOVD+SCHD.NML + SCHD.OVD) TOTALLOAN,
                 SCHD.RLSDATE,
                 SCHD.NML + SCHD.OVD PRINCIPAL,
                 SCHD.NML + SCHD.OVD + SCHD.PAID RLSAMT,
                 SCHD.PAID PRINPAID,
                 SCHD.INTPAID + SCHD.FEEINTPAID + SCHD.FEEINTPREPAID INTPAID, 0 DFRATE, DAYS,
                 SCHD.INTNMLACR  + SCHD.INTOVD + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTNMLOVD INTNML,
                 SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR INTOVD,
                 SCHD.OVERDUEDATE, NVL(V_DEAL.IRATE, 0) IRATE,
                 NVL(V_DEAL.RTTDF, 0) RTTDF, NVL(V_DEAL.ODCALLRTTDF, 0) ODCALLRTTDF, SCHD.REFTYPE,
                 LN.FTYPE, (CASE WHEN LN.FTYPE = 'DF' THEN 'Deal' WHEN LN.FTYPE = 'AF' AND SCHD.REFTYPE = 'P' THEN 'Margin' WHEN LN.FTYPE = 'AF' AND SCHD.REFTYPE = 'GP' THEN 'Bao lanh' END) FTYPE_NAME
            FROM CFMAST CF, AFMAST AF, LNMAST LN, LNTYPE TY,
                 (SELECT LNSCHD.*,
                          DATEDIFF('D', RLSDATE, GETCURRDATE) DAYS
                     FROM LNSCHD
                    WHERE REFTYPE IN ('GP', 'P')
                      AND DUENO = 0) SCHD, V_GETGRPDEALFORMULAR V_DEAL
           WHERE AF.CUSTID = CF.CUSTID
             AND AF.ACCTNO = LN.TRFACCTNO
             AND LN.ACTYPE = TY.ACTYPE
             AND SCHD.ACCTNO = LN.ACCTNO
             AND LN.ACCTNO = V_DEAL.LNACCTNO(+)
             AND CF.CUSTODYCD like V_CUSTODYCD
             AND AF.ACCTNO like V_AFACCTNO
             AND SCHD.NML + SCHD.OVD + SCHD.INTNMLACR + SCHD.INTOVDPRIN + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTOVDACR + SCHD.INTOVD + SCHD.FEEINTNMLOVD > 0
             AND SCHD.RLSDATE <= TO_DATE(T_DATE,'DD/MM/YYYY')
             AND SCHD.RLSDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
           ORDER BY LN.ACCTNO;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_LoanHist');
END pr_LoanHist;



-- Ham thuc hien giao dich rut tiet kiem
-- TheNN, 01-Aug-2012
PROCEDURE pr_TermDepositWithdraw
    (p_afacctno     IN  varchar,
    p_tdacctno      IN  VARCHAR,
    p_withdrawamt   IN  number,
    p_desc          IN  varchar2,
    p_err_code      OUT varchar2,
    p_err_message   OUT varchar2
    )
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);

      v_INTAVLAMT     NUMBER;
      v_BALANCE       NUMBER;
      v_MORTGAGE      NUMBER;
      v_DIRECTAMT     NUMBER;
      v_INTAMT        NUMBER;
      v_ORGAMT        NUMBER;
      v_ODAMT         NUMBER;
      v_ODINTACR      NUMBER;
      v_FRDATE        VARCHAR2(20);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_TermDepositWithdraw');

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_TermDepositWithdraw');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1600';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_afacctno,1,4);

    -- Lay thong tin cua hop dong tiet kiem
    SELECT MST.BALANCE, MST.MORTGAGE,
        FN_TDMASTINTRATIO(MST.ACCTNO,to_date(v_strCURRDATE,systemnums.c_date_format),MST.BALANCE) INTAVLAMT,MST.ORGAMT, MST.FRDATE,
        MST.ODAMT, floor(MST.ODINTACR) ODINTACR
    INTO v_BALANCE, v_MORTGAGE, v_INTAVLAMT,v_ORGAMT,v_FRDATE, v_ODAMT, v_ODINTACR
    FROM TDMAST MST
    WHERE mst.acctno = p_tdacctno;
    -- Tinh lai dua tren so tien rut
    SELECT FN_TDMASTINTRATIO(p_tdacctno,to_date(v_strCURRDATE,systemnums.c_date_format),p_withdrawamt)
    INTO v_INTAMT
    FROM dual;

    --Set cac field giao dich
    --99   CUSTODYCD      C
    l_txmsg.txfields ('99').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE     := '';
    --03   ACCTNO      C
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_tdacctno;
    --05   AFACCTNO      C
    l_txmsg.txfields ('05').defname   := 'AFACCTNO';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_afacctno;
    --09   BALANCE          N
    l_txmsg.txfields ('09').defname   := 'BALANCE';
    l_txmsg.txfields ('09').TYPE      := 'N';
    l_txmsg.txfields ('09').VALUE     := v_BALANCE;
    --10   AMT          N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := p_withdrawamt;
    --11   INTAMT          N
    l_txmsg.txfields ('11').defname   := 'INTAMT';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := v_INTAMT;
    --12   INTAVLAMT          N
    l_txmsg.txfields ('12').defname   := 'INTAVLAMT';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := v_INTAVLAMT;
    --13   MORTGAGE          N
    l_txmsg.txfields ('13').defname   := 'MORTGAGE';
    l_txmsg.txfields ('13').TYPE      := 'N';
    l_txmsg.txfields ('13').VALUE     := v_MORTGAGE;
    --15   DIRECTAMT          N
    l_txmsg.txfields ('15').defname   := 'DIRECTAMT';
    l_txmsg.txfields ('15').TYPE      := 'N';
    l_txmsg.txfields ('15').VALUE     := v_BALANCE - v_MORTGAGE;
    --16   ORGAMT          N
    l_txmsg.txfields ('16').defname   := 'ORGAMT';
    l_txmsg.txfields ('16').TYPE      := 'N';
    l_txmsg.txfields ('16').VALUE     := v_ORGAMT;
    --17   FRDATE          C
    l_txmsg.txfields ('17').defname   := 'FRDATE';
    l_txmsg.txfields ('17').TYPE      := 'C';
    l_txmsg.txfields ('17').VALUE     := v_FRDATE;
    --30   T_DESC   C
    l_txmsg.txfields ('30').defname   := 'T_DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := p_desc;

    --18  ODAMT           N
    l_txmsg.txfields ('18').defname   := 'ODAMT';
    l_txmsg.txfields ('18').TYPE      := 'N';
    l_txmsg.txfields ('18').VALUE     := v_ODAMT;
    --19  ODINTACR        N
    l_txmsg.txfields ('19').defname   := 'ODINTACR';
    l_txmsg.txfields ('19').TYPE      := 'N';
    l_txmsg.txfields ('19').VALUE     := v_ODINTACR;
    --20  PAIDODAMT       N least(15++11--19,18)
    l_txmsg.txfields ('20').defname   := 'PAIDODAMT';
    l_txmsg.txfields ('20').TYPE      := 'N';
    l_txmsg.txfields ('20').VALUE     := least(v_BALANCE - v_MORTGAGE+v_INTAMT-v_ODINTACR ,v_ODAMT);
    --21  PAIDODINTACR    N least(15++11,19)
    l_txmsg.txfields ('21').defname   := 'PAIDODINTACR';
    l_txmsg.txfields ('21').TYPE      := 'N';
    l_txmsg.txfields ('21').VALUE     := least(v_BALANCE - v_MORTGAGE+v_INTAMT ,v_ODINTACR) ;
    BEGIN
        IF txpks_#1600.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.error (pkgctx,
                       'got error 1600: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error: 1600: '  || p_err_message);
           plog.setendsection(pkgctx, 'pr_TermDepositWithdraw');
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_TermDepositWithdraw');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on pr_TermDepositWithdraw');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, 'got error on pr_TermDepositWithdraw'||SQLERRM);
      plog.setendsection (pkgctx, 'pr_TermDepositWithdraw');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_TermDepositWithdraw;

-- Ham thuc hien dang ky online
-- Binhpt, 08-Aug-2012
PROCEDURE pr_OnlineRegister(
       p_CustomerType IN VARCHAR2,
       p_CustomerName IN VARCHAR2,
       p_CustomerBirth IN VARCHAR2,
       p_IDType IN VARCHAR2,
       p_IDCode IN VARCHAR2,
       p_Iddate IN VARCHAR2,
       p_Idplace IN VARCHAR2,
       p_Expiredate IN VARCHAR2,
       p_Address IN VARCHAR2,
       p_Taxcode IN VARCHAR2,
       p_PrivatePhone IN VARCHAR2,
       p_Mobile IN VARCHAR2,
       p_Fax IN VARCHAR2,
       p_Email IN VARCHAR2,
       p_Office IN VARCHAR2,
       p_Position IN VARCHAR2,
       p_Country IN VARCHAR2,
       p_CustomerCity IN VARCHAR2,
       p_TKTGTT IN VARCHAR2,
       p_TradingOther IN VARCHAR2,
       p_OtherAccount1 IN VARCHAR2,
       p_OtherCompany1 IN VARCHAR2,
       p_OtherAccount2 IN VARCHAR2,
       p_OtherCompany2 IN VARCHAR2,
       p_OtherAccount3 IN VARCHAR2,
       p_OtherCompany3 IN VARCHAR2,
       p_OtherAccount4 IN VARCHAR2,
       p_OtherCompany4 IN VARCHAR2,
       p_OtherAccount5 IN VARCHAR2,
       p_OtherCompany5 IN VARCHAR2,
       p_OtherAccount6 IN VARCHAR2,
       p_OtherCompany6 IN VARCHAR2,
       p_OtherAccount7 IN VARCHAR2,
       p_OtherCompany7 IN VARCHAR2,
       p_PlaceOrderPhone IN VARCHAR2,
       p_MatchedOrderReportSms IN VARCHAR2,
       p_PlaceOrderOnline IN VARCHAR2,
       p_MatchedOrderReportEmail IN VARCHAR2,
       p_CashinadvanceOnline IN VARCHAR2,
       p_StatementOnline IN VARCHAR2,
       p_CashinadvanceAuto IN VARCHAR2,
       p_OrderTableReportEmail IN VARCHAR2,
       p_CashtransferOnline IN VARCHAR2,
       p_NewsBVSCemail IN VARCHAR2,
       p_AdditionalSharesOnline IN VARCHAR2,
       p_SearchOnline IN VARCHAR2,
       p_BankAccountName1 IN VARCHAR2,
       p_BankIDCode1 IN VARCHAR2,
       p_BankIDDate1 IN VARCHAR2,
       p_BankIDPlace1 IN VARCHAR2,
       p_BankAccountNumber1 IN VARCHAR2,
       p_BankName1 IN VARCHAR2,
       p_Branch1 IN VARCHAR2,
       p_BankCity1 IN VARCHAR2,
       p_BankAccountName2 IN VARCHAR2,
       p_BankIDCode2 IN VARCHAR2,
       p_BankIDDate2 IN VARCHAR2,
       p_BankIDPlace2 IN VARCHAR2,
       p_BankAccountNumber2 IN VARCHAR2,
       p_BankName2 IN VARCHAR2,
       p_Branch2 IN VARCHAR2,
       p_BankCity2 IN VARCHAR2,
       p_BankAccountName3 IN VARCHAR2,
       p_BankIDCode3 IN VARCHAR2,
       p_BankIDDate3 IN VARCHAR2,
       p_BankIDPlace3 IN VARCHAR2,
       p_BankAccountNumber3 IN VARCHAR2,
       p_BankName3 IN VARCHAR2,
       p_Branch3 IN VARCHAR2,
       p_BankCity3 IN VARCHAR2,
       p_SMSorCard IN VARCHAR2,
       p_SMSPhoneNumber IN VARCHAR2,
       p_err_code  OUT varchar2,
       p_err_message  OUT varchar2
    )
    IS
      v_CUSTOMERBIRTH date;
      v_IDDATE date;
      v_EXPIREDATE date;
      v_BANKIDDATE1 date;
      v_BANKIDDATE2 date;
      v_BANKIDDATE3 date;
    BEGIN
        plog.error (pkgctx,'pr_OnlineRegister Start...');
        plog.setbeginsection(pkgctx, 'pr_OnlineRegister');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_OnlineRegister');
            return;
        END IF;
        -- End: Check host 1 active or inactive
        --check truong date time
        IF p_CUSTOMERBIRTH IS NULL OR p_CUSTOMERBIRTH='' THEN
        v_CUSTOMERBIRTH:=NULL;
        ELSE
        v_CUSTOMERBIRTH:=TO_DATE(p_CUSTOMERBIRTH,'DD/MM/YYYY');
        END IF;

        IF p_IDDATE IS NULL OR p_IDDATE='' THEN
        v_IDDATE:=NULL;
        ELSE
        v_IDDATE:=TO_DATE(p_IDDATE,'DD/MM/YYYY');
        END IF;

        IF p_EXPIREDATE IS NULL OR p_EXPIREDATE='' THEN
        v_EXPIREDATE:=NULL;
        ELSE
        v_EXPIREDATE:=TO_DATE(p_EXPIREDATE,'DD/MM/YYYY');
        END IF;

        IF p_BANKIDDATE1 IS NULL OR p_BANKIDDATE1='' THEN
        v_BANKIDDATE1:=NULL;
        ELSE
        v_BANKIDDATE1:=TO_DATE(p_BANKIDDATE1,'DD/MM/YYYY');
        END IF;

        IF p_BANKIDDATE2 IS NULL OR p_BANKIDDATE2='' THEN
        v_BANKIDDATE2:=NULL;
        ELSE
        v_BANKIDDATE2:=TO_DATE(p_BANKIDDATE2,'DD/MM/YYYY');
        END IF;

        IF p_BANKIDDATE3 IS NULL OR p_BANKIDDATE3='' THEN
        v_BANKIDDATE3:=NULL;
        ELSE
        v_BANKIDDATE3:=TO_DATE(p_BANKIDDATE3,'DD/MM/YYYY');
        END IF;
        --end
        ---insert
        Insert into REGISTERONLINE
(AUTOID,CUSTOMERTYPE,CUSTOMERNAME,CUSTOMERBIRTH,
IDTYPE,IDCODE,IDDATE,IDPLACE,
EXPIREDATE,ADDRESS,TAXCODE,
PRIVATEPHONE,MOBILE,FAX,
EMAIL,OFFICE,POSITION,
COUNTRY,CUSTOMERCITY,TKTGTT,
TRADINGOTHER,OTHERACCOUNT1,OTHERCOMPANY1,
OTHERACCOUNT2,OTHERCOMPANY2,OTHERACCOUNT3,
OTHERCOMPANY3,OTHERACCOUNT4,OTHERCOMPANY4,
OTHERACCOUNT5,OTHERCOMPANY5,OTHERACCOUNT6,
OTHERCOMPANY6,OTHERACCOUNT7,OTHERCOMPANY7,
PLACEORDERPHONE,MATCHEDORDERREPORTSMS,PLACEORDERONLINE,
MATCHEDORDERREPORTEMAIL,CASHINADVANCEONLINE,STATEMENTONLINE,
CASHINADVANCEAUTO,ORDERTABLEREPORTEMAIL,CASHTRANSFERONLINE,
NEWSBVSCEMAIL,ADDITIONALSHARESONLINE,SEARCHONLINE,
BANKACCOUNTNAME1,BANKIDCODE1,BANKIDDATE1,
BANKIDPLACE1,BANKACCOUNTNUMBER1,BANKNAME1,
BRANCH1,BANKCITY1,BANKACCOUNTNAME2,
BANKIDCODE2,BANKIDDATE2,BANKIDPLACE2,
BANKACCOUNTNUMBER2,BANKNAME2,BRANCH2,
BANKCITY2,BANKACCOUNTNAME3,BANKIDCODE3,
BANKIDDATE3,BANKIDPLACE3,BANKACCOUNTNUMBER3,
BANKNAME3,BRANCH3,BANKCITY3,
SMSORCARD,SMSPHONENUMBER,ISAPPROVE)
values (
SEQ_REGISTER_AUTOID.nextval,p_CUSTOMERTYPE,p_CUSTOMERNAME,v_CUSTOMERBIRTH,
p_IDTYPE,p_IDCODE,v_IDDATE,p_IDPLACE,
v_EXPIREDATE,p_ADDRESS,p_TAXCODE,
p_PRIVATEPHONE,p_MOBILE,p_FAX,
p_EMAIL,p_OFFICE,p_POSITION,
p_COUNTRY,p_CUSTOMERCITY,p_TKTGTT,
p_TRADINGOTHER,p_OTHERACCOUNT1,p_OTHERCOMPANY1,
p_OTHERACCOUNT2,p_OTHERCOMPANY2,p_OTHERACCOUNT3,
p_OTHERCOMPANY3,p_OTHERACCOUNT4,p_OTHERCOMPANY4,
p_OTHERACCOUNT5,p_OTHERCOMPANY5,p_OTHERACCOUNT6,
p_OTHERCOMPANY6,p_OTHERACCOUNT7,p_OTHERCOMPANY7,
p_PLACEORDERPHONE,p_MATCHEDORDERREPORTSMS,p_PLACEORDERONLINE,
p_MATCHEDORDERREPORTEMAIL,p_CASHINADVANCEONLINE,p_STATEMENTONLINE,
p_CASHINADVANCEAUTO,p_ORDERTABLEREPORTEMAIL,p_CASHTRANSFERONLINE,
p_NEWSBVSCEMAIL,p_ADDITIONALSHARESONLINE,p_SEARCHONLINE,
p_BANKACCOUNTNAME1,p_BANKIDCODE1,v_BANKIDDATE1,
p_BANKIDPLACE1,p_BANKACCOUNTNUMBER1,p_BANKNAME1,
p_BRANCH1,p_BANKCITY1,p_BANKACCOUNTNAME2,
p_BANKIDCODE2,v_BANKIDDATE2,p_BANKIDPLACE2,
p_BANKACCOUNTNUMBER2,p_BANKNAME2,p_BRANCH2,
p_BANKCITY2,p_BANKACCOUNTNAME3,p_BANKIDCODE3,
v_BANKIDDATE3,p_BANKIDPLACE3,p_BANKACCOUNTNUMBER3,
p_BANKNAME3,p_BRANCH3,p_BANKCITY3,
p_SMSORCARD,p_SMSPHONENUMBER,'P'
);
commit;
        --end insert
        p_err_code:= 0;
    EXCEPTION
        WHEN OTHERS
        THEN
             plog.debug (pkgctx,'got error on pr_OnlineRegister');
             ROLLBACK;
             p_err_code := errnums.C_SYSTEM_ERROR;
             plog.error (pkgctx, SQLERRM);
             plog.setendsection (pkgctx, 'pr_OnlineRegister');
             RAISE errnums.E_SYSTEM_ERROR;
    END pr_OnlineRegister;

--Ham tra cuu tiet kiem
--Binhpt 29/08/2012
PROCEDURE pr_GetTDhist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS
    V_AFACCTNO    VARCHAR2(10);
BEGIN
    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    OPEN p_REFCURSOR FOR
       SELECT MST.ACCTNO, MST.AFACCTNO, CF.CUSTODYCD, CF.FULLNAME, TYP.TYPENAME,
        MST.ORGAMT, MST.BALANCE, MST.PRINTPAID, MST.INTNMLACR, MST.INTPAID, MST.TAXRATE, MST.BONUSRATE, MST.INTRATE, MST.TDTERM, MST.OPNDATE, MST.FRDATE, MST.TODATE,TYP.minbrterm,TYP.TERMCD,
        CASE WHEN (CASE TYP.TERMCD WHEN 'D' THEN TYP.minbrterm + MST.FRDATE
                            WHEN 'W' THEN TYP.minbrterm*7 + MST.FRDATE
                            WHEN 'M' THEN ADD_MONTHS(MST.FRDATE,TYP.minbrterm)
            END) <= (SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'CURRDATE')  THEN 'Y' ELSE 'N' END ALLOWED ,
        FN_TDMASTINTRATIO(MST.ACCTNO,TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY'),MST.BALANCE) INTAVLAMT, MST.BALANCE-MST.MORTGAGE AVLWITHDRAW, MST.MORTGAGE,
        A0.CDCONTENT DESC_TDSRC, A1.CDCONTENT DESC_AUTOPAID, A2.CDCONTENT DESC_BREAKCD, A3.CDCONTENT DESC_SCHDTYPE, A4.CDCONTENT DESC_TERMCD, A5.CDCONTENT DESC_STATUS
        FROM TDMAST MST, AFMAST AF, CFMAST CF, TDTYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, ALLCODE A3, ALLCODE A4, ALLCODE A5, SYSVAR
        WHERE AF.ACCTNO like V_AFACCTNO AND (MST.BALANCE) > 0
        AND MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND SYSVAR.VARNAME='CURRDATE'
        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
        AND A0.CDTYPE='TD' AND A0.CDNAME='TDSRC' AND MST.TDSRC=A0.CDVAL
        AND A1.CDTYPE='SY' AND A1.CDNAME='YESNO' AND MST.AUTOPAID=A1.CDVAL
        AND A2.CDTYPE='SY' AND A2.CDNAME='YESNO' AND MST.BREAKCD=A2.CDVAL
        AND A4.CDTYPE='TD' AND A4.CDNAME='TERMCD' AND MST.TERMCD=A4.CDVAL
        AND A5.CDTYPE='TD' AND A5.CDNAME='STATUS' AND MST.STATUS=A5.CDVAL
        AND A3.CDTYPE='TD' AND A3.CDNAME='SCHDTYPE' AND MST.SCHDTYPE=A3.CDVAL
        AND MST.OPNDATE >= TO_DATE(F_DATE,'DD/MM/YYYY')
        AND MST.OPNDATE<=TO_DATE(T_DATE,'DD/MM/YYYY');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetTDhist');
END pr_GetTDhist;
--Ham tra cuu lenh xac nhan
--QuangVD 04/01/2013
PROCEDURE pr_GetConfirmOrderHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    CUSTODYCD       IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2
     )
    IS
    V_CUSTODYCD   VARCHAR2(10);
    V_AFACCTNO    VARCHAR2(10);
    V_EXECTYPE    VARCHAR2(10);
BEGIN
    IF CUSTODYCD = 'ALL' OR CUSTODYCD IS NULL THEN
        V_CUSTODYCD := '%%';
    ELSE
        V_CUSTODYCD := CUSTODYCD;
    END IF;

    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    IF EXECTYPE = 'ALL' OR EXECTYPE IS NULL THEN
        V_EXECTYPE := '%%';
    ELSE
        V_EXECTYPE := EXECTYPE;
    END IF;

    OPEN p_REFCURSOR FOR
       SELECT OD.ORDERID,OD.TXDATE,OD.CODEID, A0.CDCONTENT TRADEPLACE, A1.CDCONTENT EXECTYPE,
        OD.PRICETYPE PRICETYPE, A3.CDCONTENT VIA, OD.ORDERQTTY,OD.QUOTEPRICE, OD.REFORDERID,
        se.symbol,a4.CDCONTENT CONFIRMED,od.afacctno, cf.custodycd, cf.fullname,
        cspks_odproc.fn_OD_GetRootOrderID(od.orderid) ROOTORDERID
        FROM CONFIRMODRSTS CFMSTS,
        (select * from ODMAST union all select * from odmasthist) OD, SBSECURITIES SE,
        ALLCODE A0, ALLCODE A1, ALLCODE A2, ALLCODE A3,aLLCODE A4,
        afmast af, cfmast cf
        WHERE CFMSTS.ORDERID(+)=OD.ORDERID
        AND OD.CODEID=SE.CODEID
        AND a0.cdtype = 'OD' AND a0.cdname = 'TRADEPLACE' AND a0.cdval = se.tradeplace
        AND A1.cdtype = 'OD' AND A1.cdname = 'EXECTYPE'
        AND A1.cdval =(case when nvl(od.reforderid,'a') <>'a' and OD.EXECTYPE = 'NB' then 'AB'
        when  nvl(od.reforderid,'a') <>'a' and OD.EXECTYPE in ( 'NS','MS') then 'AS'
          else od.EXECTYPE end)
        AND A2.cdtype = 'OD' AND A2.cdname = 'PRICETYPE' AND A2.cdval = OD.PRICETYPE
        AND A3.cdtype = 'OD' AND A3.cdname = 'VIA' AND A3.cdval = OD.VIA
        AND a4.cdtype = 'SY' AND a4.cdname = 'YESNO' AND a4.cdval = nvl(CFMSTS.CONFIRMED,'N')
        and ( (od.exectype in ('NB','NS','MS') AND /*od.via in ('H')*/(od.via='F' or (od.via='H'))) or (od.exectype  not in ('NB','NS','MS')))
        and od.exectype not in ('AB','AS')
        --and od.via = 'H'
        and od.via <> 'O' --11/2016 toannds sua
        and od.txdate >=to_date('01/01/2013','DD/MM/YYYY')
        and od.afacctno=af.acctno and af.custid=cf.custid
        AND cf.custodycd LIKE V_CUSTODYCD
        AND OD.AFACCTNO LIKE V_AFACCTNO
        AND OD.EXECTYPE LIKE V_EXECTYPE
        --AND OD.EXECQTTY > 0
        AND OD.txdate = least(TO_DATE(F_DATE,'DD/MM/YYYY'),trunc(sysdate))
        --AND OD.txdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
        and od.orderid not in (select orderid from CONFIRMODRSTS)
        ORDER BY OD.TXDATE DESC;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetConfirmOrderHist');
END pr_GetConfirmOrderHist;
--Binhpt Ham tra cuu tong tai san
PROCEDURE pr_GetNetAsset
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     )
    IS
    l_AFACCTNO    VARCHAR2(10);
    --V_CUSTODYCD   VARCHAR2(10);
    l_MRAMT          number(20,0);
    l_T0AMT          number(20,0);
    l_DFAMT          number(20,0);
    l_BALANCE        number(20,0);
    l_AVLADVANCE     number(20,0);
    l_DEPOFEEAMT     number(20,0);
BEGIN
    l_AFACCTNO:=p_AFACCTNO;

    --Lay cac thong tin ve tien
     select nvl(sum(t0amt),0), nvl(sum(marginamt),0) into l_T0AMT,l_MRAMT  from vw_lngroup_all where trfacctno = l_AFACCTNO;

     select nvl(sum(prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue),0) into l_DFAMT
     from lnmast where trfacctno = l_AFACCTNO and ftype = 'DF';

     select balance,depofeeamt into l_BALANCE,l_DEPOFEEAMT
     from cimast
     where acctno = l_AFACCTNO;

     select nvl(sum(depoamt),0) into l_AVLADVANCE
     from v_getaccountavladvance
     where afacctno = l_AFACCTNO;
    --end Lay cac thong tin ve tien
    OPEN p_REFCURSOR FOR
    select
    sum(SEREAL) SeTotal,
    (l_BALANCE + l_AVLADVANCE) CITotal,
    (l_T0AMT+l_MRAMT+l_DFAMT+ l_DEPOFEEAMT) odamt
    from vw_getsecmargindetail v
    where v.afacctno = l_AFACCTNO
    and v.trade + v.mortage + v.receiving + v.execqtty + v.buyqtty > 0
    order by v.symbol;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetNetAsset');
END pr_GetNetAsset;
--Ham tra cuu chuyen doi trai phieu
--QuangVD 17/10/2012
PROCEDURE pr_GetConvertBondHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS
    V_AFACCTNO    VARCHAR2(10);
BEGIN
    IF AFACCTNO = 'ALL' OR AFACCTNO IS NULL THEN
        V_AFACCTNO := '%%';
    ELSE
        V_AFACCTNO := AFACCTNO;
    END IF;

    OPEN p_REFCURSOR FOR
       /*SELECT CI.busdate TXDATE, cf.custodycd, af.acctno Sub_Account,
            --REPLACE(se.symbol,'_WFT','') symbol ,
            ca.symbol symbol,
            CASE WHEN CI.TLTXCD = '3386' THEN -SE.NAMT ELSE SE.NAMT END Quantity,
            CASE WHEN CI.TLTXCD = '3386' THEN -CI.NAMT ELSE CI.NAMT END Amount,
            NVL(mk.tlname,'-----') maker_name, NVL(ck.tlname,'-----') checker_name,
           'Completed'  Status, decode (af.COREBANK,'Y',AF.bankname, cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname,
           ca.tosymbol tosymbol
        FROM (SELECT * FROM   VW_CITRAN_GEN  WHERE TLTXCD IN ('3384','3386'))  CI,
              ( SELECT * FROM   VW_SETRAN_GEN  WHERE TLTXCD IN ('3384','3386') ) SE ,
          cfmast cf, afmast af,tlprofiles mk, tlprofiles ck,
          (SELECT camastid, sb.symbol symbol, tosb.symbol tosymbol
            FROM camast ca, sbsecurities tosb, sbsecurities sb
            WHERE nvl(ca.tocodeid, ca.codeid) = tosb.codeid AND ca.codeid = sb.codeid
          ) ca--add by CHAUNH
        WHERE SE.TXNUM = CI.TXNUM AND SE.TXDATE = CI.TXDATE
        AND se.REF = ca.camastid (+)
        AND SE.DELTD='N' AND CI.DELTD='N' AND SE.field ='RECEIVING' AND CI.field='BALANCE'
        AND ci.busdate >= TO_DATE(F_DATE,'DD/MM/YYYY') AND ci.busdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
        AND CI.ACCTNO = af.acctno and af.custid = cf.custid AND SE.custid = CF.custid --AND CF.custid = AF.custid
        AND CI.TLID = MK.TLID (+) AND CI.offid = CK.TLID(+)
        AND AF.ACCTNO LIKE V_AFACCTNO

        UNION ALL

        SELECT SE.busdate TXDATE, cf.custodycd, af.acctno Sub_Account,
            --REPLACE(se.symbol,'_WFT','') symbol ,
            ca.symbol symbol,
            CASE WHEN SE.TLTXCD = '3326' THEN -SE.NAMT ELSE SE.NAMT END Quantity, 0 Amount,
            NVL(mk.tlname,'-----') maker_name, NVL(ck.tlname,'-----') checker_name,
           'Completed'  Status, decode (af.COREBANK,'Y',AF.bankname, cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname,
            ca.tosymbol tosymbol
        FROM ( SELECT * FROM   VW_SETRAN_GEN  WHERE TLTXCD IN ('3324','3326') ) SE ,
          cfmast cf, afmast af,tlprofiles mk, tlprofiles ck,
          (SELECT camastid, sb.symbol symbol, tosb.symbol tosymbol
            FROM camast ca, sbsecurities tosb, sbsecurities sb
            WHERE nvl(ca.tocodeid, ca.codeid) = tosb.codeid AND ca.codeid = sb.codeid
          ) ca--add by CHAUNH
        WHERE SE.DELTD='N' AND SE.field ='RECEIVING'
        AND se.REF = ca.camastid (+)
        AND SE.busdate >= TO_DATE(F_DATE,'DD/MM/YYYY') AND SE.busdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
        AND SE.AFACCTNO = af.acctno and af.custid = cf.custid AND SE.custid = CF.custid --AND CF.custid = AF.custid
        AND SE.TLID = MK.TLID (+) AND SE.offid = CK.TLID(+)
        AND AF.ACCTNO LIKE V_AFACCTNO

        UNION ALL
*/
        SELECT  tran.txdate, cf.custodycd, af.acctno sub_account,
                ca.symbol symbol,
                CASE WHEN tl.tltxcd = '3327' THEN tl.msgamt ELSE -tl.msgamt END Quantity,
                0 amount,  NVL(mk.tlname,'-----') maker_name, NVL(ck.tlname,'-----') checker_name, 'Completed'  Status,
                decode (af.COREBANK,'Y',AF.bankname, cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname, ca.tosymbol tosymbol
        FROM
        (SELECT * FROM catran
        UNION all
        SELECT * FROM catrana) tran,
        vw_tllog_all tl, cfmast cf, afmast af,tlprofiles mk, tlprofiles ck,
         (SELECT camastid, sb.symbol symbol, tosb.symbol tosymbol
            FROM camast ca, sbsecurities tosb, sbsecurities sb
            WHERE nvl(ca.tocodeid, ca.codeid) = tosb.codeid AND ca.codeid = sb.codeid) ca, vw_caschd_all chd
        WHERE tl.txdate = tran.txdate AND tl.txnum = tran.txnum
        AND cf.custid = af.custid AND af.acctno = tl.msgacct
        AND TL.TLID = MK.TLID (+) AND tl.offid = ck.TLID(+)
        AND ca.camastid = chd.camastid
        AND chd.autoid = tran.acctno
        AND tl.tltxcd IN ('3327','3328')
        AND tl.busdate >= TO_DATE(F_DATE,'DD/MM/YYYY') AND tl.busdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
        AND AF.ACCTNO LIKE V_AFACCTNO

        ORDER BY TXDATE;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetConvertBondHist');
END pr_GetConvertBondHist;
--END pr_GetConvertBondHist

--Ham tra cuu thong tin tra no
--Binhpt
PROCEDURE pr_GetRePaymentHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2
     )
    IS
   V_STRACCTNO      VARCHAR2 (20);
BEGIN
V_STRACCTNO:=p_AFACCTNO;
    OPEN p_REFCURSOR FOR
       select  v.Groupid, LN.ACCTNO acctno,
        case when ln.ftype ='DF' then 'DF' else
           (case when ls.reftype ='GP' then 'BL' else 'CL' end) end  F_TYPE,
           to_char(ls.rlsdate,'DD/MM/RRRR') rlsdate,TO_CHAR(ls.overduedate,'DD/MM/RRRR') overduedate,
           ls.nml+ls.ovd+ls.paid F_GTGN,
           ls.PAID - nvl(LNTR.PRIN_MOVE,0) F_GTTL,
           ls.nml+ls.ovd  -  nvl(LNTR.PRIN_MOVE,0)  F_DNHT,
           ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin +
           ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd + ls.feeintdue
           - nvl(LNTR.PRFEE_MOVE,0) F_LAI_PHI,
            case when ln.ftype ='DF' then  to_char(ln.rate2) || ' - ' || to_char(ln.cfrate2)  else
           --bao lanh
           (case when ls.reftype ='GP' then to_char(ln.orate2) || ' - ' || to_char(ln.cfrate2) else
           --margin
           to_char(ln.rate2) || ' - ' || to_char(ln.cfrate2) end) end  F_TLLAI
           --ban due chua tat toan ODCALLSELLMR
           --(case when V_IDATE  <> V_CURRDATE then -1 else  NVL(V.ODCALLSELLMRATE,0) end) VNDSELLDF ,
           --(case when V_IDATE  <> V_CURRDATE then -1 else nvl(v.ODCALLDF,0) end) ODCALLDF,
      from (select * from lnmast union select * from lnmasthist) ln,
      (select * from lnschd union select * from lnschdhist) ls,
        (select autoid,sum((case when nml > 0 then 0 else nml end) + ovd) PRIN_MOVE,
            sum(intnmlacr +intdue+intovd+intovdprin +
            feeintnmlacr+ feeintdue+feeintovd+feeintovdprin) PRFEE_MOVE
            from ( select * from lnschdlog union all select * from lnschdloghist ) lnslog
            where nvl(deltd,'N') <>'Y' and txdate > TO_DATE(T_DATE,'DD/MM/YYYY')
            group by autoid) LNTR,
      CFMAST CF, afmast af , v_getgrpdealformular v, v_getsecmarginratio sec
where ln.acctno = ls.acctno
and ls.reftype in ('P','GP')
--and ls.rlsdate <=  V_IDATE
AND ls.rlsdate >= TO_DATE(F_DATE,'DD/MM/YYYY')
AND ls.rlsdate <= TO_DATE(T_DATE,'DD/MM/YYYY')
and ln.acctno = v.lnacctno (+)
and ls.autoid = LNTR.autoid(+)
AND CF.CUSTID = AF.CUSTID
AND LN.trfacctno = AF.ACCTNO
AND AF.ACCTNO LIKE V_STRACCTNO
and af.acctno = sec.afacctno;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetRePaymentHist');
END pr_GetRePaymentHist;

-- LAY THONG TIN GIA VON CHUNG KHOAN
-- TheNN, 13-MAR-2013
FUNCTION fn_GetSECostPrice
    (ACCTNO       IN  VARCHAR2
    ) RETURN NUMBER
AS
    V_COSTPRICE     NUMBER;
    V_ACCTNO        VARCHAR2(20);

BEGIN
    V_ACCTNO := ACCTNO;
    V_COSTPRICE := 0;

    -- LAY GIA VON THEO BINH QUAN PHAT SINH TANG
    SELECT round(sum(CASE WHEN se.field = 'DCRAMT' THEN se.namt ELSE 0 END)/
                    sum(CASE WHEN se.field = 'DCRQTTY' THEN se.namt ELSE 0 END),4) costprice
    INTO V_COSTPRICE
    FROM vw_setran_gen se
    WHERE se.tltxcd NOT IN ('8804') AND se.field IN ('DCRAMT','DCRQTTY')
        AND se.acctno = V_ACCTNO;

    -- LAY GIA VON THEO BINH QUAN LENH MUA
    /*SELECT CASE WHEN STS.SEQTTY = 0 THEN NVL(B_STS.B_COSTPRICE,0) ELSE STS.COSTPRICE END
    INTO V_COSTPRICE
    FROM
    (
        SELECT SE.ACCTNO,
            NVL(SE.TRADE,0) + NVL(SE.MORTAGE,0) + NVL(SE.BLOCKED,0) SEQTTY, SE.COSTPRICE
        FROM SEMAST SE
        WHERE SE.ACCTNO = V_ACCTNO
    ) STS,
    (
        SELECT STS.ACCTNO, NVL(round(SUM(STS.AMT + (CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN OD.EXECAMT*ODT.DEFFEERATE/100 ELSE OD.FEEACR END))/SUM(STS.QTTY),4),0) B_COSTPRICE
        FROM VW_STSCHD_ALL STS, AFMAST AF, SBSECURITIES SB, vw_odmast_all OD, ODTYPE ODT
        WHERE STS.DUETYPE= 'RS' AND STS.CODEID = SB.CODEID
            AND AF.ACCTNO = STS.AFACCTNO
            AND STS.orgorderid = OD.orderid
            AND OD.actype = ODT.actype
            AND STS.ACCTNO = V_ACCTNO
        GROUP BY STS.ACCTNO, STS.AFACCTNO, STS.CODEID
    ) B_STS
    WHERE STS.ACCTNO = B_STS.ACCTNO (+);*/
    /*-- NEU CHUA CO LENH MUA NAO THI LAY GIA VON TRONG SEMAST
    IF V_COSTPRICE = 0 THEN
        SELECT NVL(SE.costprice,0)
        INTO V_COSTPRICE
        FROM SEMAST SE
        WHERE SE.acctno = V_ACCTNO;
    END IF;*/

    RETURN V_COSTPRICE;
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'fn_GetSECostPrice');
    RETURN 0;
END;


function fn_getExTransferMoneyFee(p_amount in number,
                                  p_feecd in varchar2
                                ) return number
as
  v_feecd varchar2(20);
  v_feeamt  number(20);
  begin
     v_feecd:=   p_feecd;
     if v_feecd is null or length(v_feecd)<=0 then
        v_feecd:='00000';
     /*elsif length(v_feecd)<> 5 then
        v_feecd:='00000';*/
     end if;
     v_feeamt:=fn_gettransfermoneyfee(p_amount,v_feecd);
     return v_feeamt;
  exception
    when others then
      return 0;
  end ;

function fn_getInTransferMoneyFee(p_account varchar,
                                  p_toaccount  varchar2,
                                  p_amount number
                                ) return number
as
  v_feetype varchar2(20);
  v_feeamt  number(20);

  begin
     return 0;
     v_feetype:='00015';
     For rec in(Select 1
                From afmast a1, afmast a2
                 where a1.acctno=p_account  and a2.acctno= p_toaccount and a1.custid = a2.custid)
     -- Cung so luu ky
     Loop
         v_feetype:='00014';
     End loop;
     v_feeamt:=fn_gettransfermoneyfee(p_amount,v_feetype);
     return v_feeamt;
  exception
    when others then
      return 0;
end;


  --Huy dang ky ban chung khoan lo le tren online
PROCEDURE pr_Transfer_SE_account(p_trfafacctno varchar2,
                                p_rcvafacctno varchar2,
                                p_symbol    VARCHAR2,
                                p_quantity varchar2,
                                p_blockedqtty varchar2,
                                p_price     in number DEFAULT 0,
                                p_err_code  OUT varchar2,
                                p_err_message out varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_count number;

      l_trfafacctno varchar2(10);
      l_rcvafacctno varchar2(10);
      l_symbol varchar2(20);
      l_qtty number(20,4);
      v_codeid varchar2(10);
      v_trfseacctno varchar2(30);
      v_custname varchar2(100);
      v_address cfmast.address%TYPE;
      v_license  varchar2(100);
      v_rcvseacctno varchar2(30);
      v_custname2 varchar2(100);
      v_orgamt number(20,4);
      v_address2 cfmast.address%TYPE;
      v_license2 varchar2(100);
      v_amt_chk  number(20,4);
      v_amt number(20,4);
      v_qttytype varchar2(10);
      v_depoblock_chk number(20,4);
      v_depoblock number(20,4);
      v_autoid number(20,4);
      v_orgtradewtf number(20,4);
      v_mintradewtf number(20,4);
      v_tradewtf number(20,4);
      v_qtty number(20,4);
      v_parvalue number(20,4);
      v_price  number(20,4);
      v_depolastdt date;
      v_depofeeamt number(20,4);
      v_depofeeacr number(20,4);
      v_trtype varchar2(10);
      v_needqtty number(20);
      v_desc varchar2(200);
      temp varchar2(200);
      v_custodycd cfmast.custodycd%TYPE;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_Transfer_SE_account');

    l_trfafacctno := trim(p_trfafacctno);
    l_rcvafacctno := trim(p_rcvafacctno);
    l_symbol := trim(upper(p_symbol));

    l_qtty := to_number(p_quantity);
    v_depoblock := to_number(p_blockedqtty);

    --Lay dien giai giao dich
    SELECT TLTX.EN_TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '2242';
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Transfer_SE_account');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    SELECT semast.acctno,
       sym.codeid codeid,

       least(semast.trade,fn_get_semast_avl_withdraw(semast.afacctno, semast.codeid)) trade,
       least(trade -NVL(od.secureamt,0)+NVL(od.sereceiving,0),GETAVLSEWITHDRAW(semast.acctno)) ORGAMT,
       nvl(pit.qtty,0) tradewtf, nvl(pit.qtty,0) ORGTRADEWTF,
       sym.parvalue, '0' autoid,
       cf.idcode,  cf.fullname, cf.ADDRESS, semast.emkqtty, fn_secostpricecalculatedtl(semast.acctno) costprice, cf.custodycd
    INTO v_trfseacctno,v_codeid, v_amt_chk,v_orgamt,v_tradewtf,v_orgtradewtf,v_parvalue,
         v_autoid, v_license, v_custname, v_address, v_depoblock_chk, v_price, v_custodycd
          FROM sbsecurities sym,
          (SELECT SEACCTNO, SUM(SECUREAMT) SECUREAMT, SUM(SECUREMTG) SECUREMTG, SUM(RECEIVING) SERECEIVING
            FROM (SELECT OD.SEACCTNO,
                    CASE WHEN OD.EXECTYPE IN ('NS', 'SS') AND OD.TXDATE =to_date(SY.VARVALUE,'DD/MM/YYYY') THEN REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
                    CASE WHEN OD.EXECTYPE = 'MS'  AND OD.TXDATE =to_date(SY.VARVALUE,'DD/MM/YYYY') THEN REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
                    CASE WHEN OD.EXECTYPE = 'NB' THEN ST.QTTY ELSE 0 END RECEIVING
                FROM ODMAST OD, STSCHD ST, ODTYPE TYP, SYSVAR SY
                WHERE OD.DELTD <> 'Y'  AND OD.EXECTYPE IN ('NS', 'SS','MS', 'NB')
                    AND OD.ORDERID = ST.ORGORDERID(+) AND ST.DUETYPE(+) = 'RS'
                    And OD.ACTYPE = TYP.ACTYPE
                    AND SY.GRNAME = 'SYSTEM' AND SY.VARNAME = 'CURRDATE'
                    AND ((TYP.TRANDAY <= (SELECT SUM(CASE WHEN CLDR.HOLIDAY = 'Y' THEN 0 ELSE 1 END)
                    FROM SBCLDR CLDR
                    WHERE CLDR.CLDRTYPE = '000' AND CLDR.SBDATE >= ST.TXDATE AND CLDR.SBDATE <= (select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')) AND OD.EXECTYPE = 'NB')
                    OR OD.EXECTYPE IN ('NS','SS','MS')))
            GROUP BY SEACCTNO ) od, (select custodycd, custid custidcfmast, idcode,fullname, iddate, idplace,ADDRESS  from cfmast) cf, (select brid, custid custidafmast, acctno acctnoafmast from afmast) af,
            semast,
        (select acctno,sum(qtty-mapqtty) qtty
            from sepitlog where deltd <> 'Y' and qtty-mapqtty>0
            group by acctno) pit
         WHERE sym.codeid = semast.codeid
           AND sym.symbol = l_symbol
           AND semast.afacctno = l_trfafacctno
           AND sym.sectype <> '004'
           AND semast.afacctno = af.acctnoafmast
           and af.custidafmast = cf.custidcfmast
           AND (trade -NVL(od.secureamt,0)+NVL(od.sereceiving,0)) > 0
           AND semast.acctno =od.seacctno(+)
           and semast.acctno =pit.acctno(+);
    ------------------

    SELECT to_date(DEPOLASTDT,'dd/mm/rrrr') INTO v_depolastdt FROM CIMAST WHERE AFACCTNO = l_rcvafacctno;
    v_custname2 := v_custname;
    v_license2 := v_license;
    v_address2 := v_address;
    v_rcvseacctno := l_rcvafacctno || v_codeid;

    ---v_price := p_price;
    --v_qttytype := '002';
    --v_depoblock_chk := FN_GET_SE_BLOCKQTTY(l_trfafacctno,v_codeid, v_qttytype);
    v_depoblock := LEAST(v_depoblock, v_depoblock_chk,0);

    v_mintradewtf := GREATEST(0,v_orgtradewtf + l_qtty + v_depoblock - v_amt_chk - v_depoblock_chk);

    v_qtty := l_qtty + v_depoblock;

    --v_price := FN_GET_SE_COSTPRICE(l_trfafacctno,v_codeid, v_price);


    v_depofeeacr := TO_NUMBER(FN_CIGETDEPOFEEACR(l_rcvafacctno,v_codeid,v_strCURRDATE,v_strCURRDATE,to_number(v_qtty)));

    v_depofeeamt := TO_NUMBER(FN_CIGETDEPOFEEAMT(l_rcvafacctno,v_codeid,v_strCURRDATE,v_strCURRDATE,to_number(v_qtty)));

    v_needqtty := cspks_seproc.fn_getSEDeposit(v_codeid, l_rcvafacctno);




    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2242';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;

     l_txmsg.brid        := substr(l_trfafacctno,1,4);
    --CODEID
    l_txmsg.txfields ('01').defname   := 'CODEID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := v_codeid;
    --AFACCTNO
    l_txmsg.txfields ('02').defname   := 'AFACCTNO';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := l_trfafacctno;
    --CUSTODYCD
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE     := v_custodycd;
    --ACCTNO
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := v_trfseacctno;
    --CUSTNAME
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     := v_custname;
    --ADDRESS
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE     := v_address;
    --LICENSE
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE     := v_license;
    --AFACCT2
    l_txmsg.txfields ('04').defname   := 'AFACCT2';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := l_rcvafacctno;
    --ACCT2
    l_txmsg.txfields ('05').defname   := 'ACCT2';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := v_rcvseacctno;
    --CUSTNAME2
    l_txmsg.txfields ('93').defname   := 'CUSTNAME2';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE     := v_custname2;
    --ORGAMT
    l_txmsg.txfields ('19').defname   := 'ORGAMT';
    l_txmsg.txfields ('19').TYPE      := 'N';
    l_txmsg.txfields ('19').VALUE     := v_orgamt;
    --ADDRESS2
    l_txmsg.txfields ('94').defname   := 'ADDRESS2';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE     := v_address2;
    --LICENSE2
    l_txmsg.txfields ('95').defname   := 'LICENSE2';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE     := v_license2;
    --AMT_CHK
    l_txmsg.txfields ('21').defname   := 'AMT_CHK';
    l_txmsg.txfields ('21').TYPE      := 'N';
    l_txmsg.txfields ('21').VALUE     := v_amt_chk;
    --AMT
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := l_qtty;
    --QTTYTYPE
    l_txmsg.txfields ('14').defname   := 'QTTYTYPE';
    l_txmsg.txfields ('14').TYPE      := 'C';
    l_txmsg.txfields ('14').VALUE     := v_qttytype;
    --DEPOBLOCK_CHK
    l_txmsg.txfields ('17').defname   := 'DEPOBLOCK_CHK';
    l_txmsg.txfields ('17').TYPE      := 'N';
    l_txmsg.txfields ('17').VALUE     := v_depoblock_chk;
    --DEPOBLOCK
    l_txmsg.txfields ('06').defname   := 'DEPOBLOCK';
    l_txmsg.txfields ('06').TYPE      := 'N';
    l_txmsg.txfields ('06').VALUE     := v_depoblock;
    --AUTOID
    l_txmsg.txfields ('18').defname   := 'AUTOID';
    l_txmsg.txfields ('18').TYPE      := 'N';
    l_txmsg.txfields ('18').VALUE     := v_autoid;
    --ORGTRADEWTF
    l_txmsg.txfields ('20').defname   := 'ORGTRADEWTF';
    l_txmsg.txfields ('20').TYPE      := 'N';
    l_txmsg.txfields ('20').VALUE     := v_orgtradewtf;
    --TRADEWTF
    l_txmsg.txfields ('22').defname   := 'TRADEWTF';
    l_txmsg.txfields ('22').TYPE      := 'N';
    l_txmsg.txfields ('22').VALUE     := v_mintradewtf;
    --TRADEWTF
    l_txmsg.txfields ('13').defname   := 'TRADEWTF';
    l_txmsg.txfields ('13').TYPE      := 'N';
    l_txmsg.txfields ('13').VALUE     := v_tradewtf;
    --QTTY
    l_txmsg.txfields ('12').defname   := 'QTTY';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := v_qtty;
    --PARVALUE
    l_txmsg.txfields ('11').defname   := 'PARVALUE';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := v_parvalue;
    --PRICE
    l_txmsg.txfields ('09').defname   := 'PRICE';
    l_txmsg.txfields ('09').TYPE      := 'N';
    l_txmsg.txfields ('09').VALUE     := v_price;
    --DEPOLASTDT
    l_txmsg.txfields ('32').defname   := 'DEPOLASTDT';
    l_txmsg.txfields ('32').TYPE      := 'D';
    l_txmsg.txfields ('32').VALUE     := v_depolastdt;
    --DEPOFEEAMT
    l_txmsg.txfields ('15').defname   := 'DEPOFEEAMT';
    l_txmsg.txfields ('15').TYPE      := 'N';
    l_txmsg.txfields ('15').VALUE     := v_depofeeamt;
    --DEPOFEEACR
    l_txmsg.txfields ('16').defname   := 'DEPOFEEACR';
    l_txmsg.txfields ('16').TYPE      := 'B';
    l_txmsg.txfields ('16').VALUE     := v_depofeeacr;
    --TRTYPE
    l_txmsg.txfields ('31').defname   := 'TRTYPE';
    l_txmsg.txfields ('31').TYPE      := 'C';
    l_txmsg.txfields ('31').VALUE     := v_trtype;
    --NEEDQTTY
    l_txmsg.txfields ('96').defname   := 'NEEDQTTY';
    l_txmsg.txfields ('96').TYPE      := 'N';
    l_txmsg.txfields ('96').VALUE     := v_needqtty;
    --SECMARGIN
    l_txmsg.txfields ('99').defname   := 'SECMARGIN';
    l_txmsg.txfields ('99').TYPE      := 'N';
    l_txmsg.txfields ('99').VALUE     := cspks_seproc.fn_getSEMargin(v_codeid,l_rcvafacctno);
    --DESC
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := FN_GEN_DESC_1120(UTF8NUMS.C_2242_GEN_DESC,l_trfafacctno,l_rcvafacctno);
     --DESC
    l_txmsg.txfields ('35').defname   := 'DESCRIPTION';
    l_txmsg.txfields ('35').TYPE      := 'C';
    l_txmsg.txfields ('35').VALUE     := v_desc;

    BEGIN
        IF txpks_#2242.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 2242: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_Transfer_SE_account');
           RETURN;
        END IF;
    END;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_Transfer_SE_account');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_Transfer_SE_account');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_Transfer_SE_account');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Transfer_SE_account;
PROCEDURE pr_get_info_2239(p_afacctno in varchar2,
                                p_symbol  in  VARCHAR2,
                                p_MrRate OUT number ,
                                p_MrPrice OUT number ,
                                p_avlpp  OUT number )
is
    l_codeid varchar2(10);
    l_MrRate number ;
    l_MrPrice number;
    l_avlpp number;
begin
    plog.setbeginsection(pkgctx, 'pr_get_info_2239');
    select max(codeid) into l_codeid from sbsecurities
    where symbol = p_symbol;
    l_codeid := nvl(l_codeid,'000000');

    l_MrRate := cspks_mrproc.fn_getMrRate(p_afacctno,l_codeid);
    l_MrPrice :=  cspks_mrproc.fn_getMrPrice(p_afacctno,l_codeid);
    l_avlpp := getavlpp(p_afacctno);

    p_MrRate := l_MrRate;
    p_MrPrice := l_MrPrice;
    p_avlpp := l_avlpp;

    plog.setendsection(pkgctx, 'pr_get_info_2239');

EXCEPTION
WHEN OTHERS
THEN
    plog.debug (pkgctx,'got error on pr_get_info_2239');
ROLLBACK;
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetMobileAdvInfo');
END pr_get_info_2239;

PROCEDURE pr_Transfer_SE_account_2239(p_trfafacctno in varchar2,
                                p_rcvafacctno in varchar2,
                                p_symbol  in  VARCHAR2,
                                p_quantity in number,
                                p_AMT     in number DEFAULT 0,
                                p_err_code  OUT varchar2,
                                p_err_message out varchar2)
IS
    l_MRTYPE    VARCHAR2(10);
    l_CODEID    VARCHAR2(20);
    l_CUSTODYCD VARCHAR2(20);
    l_AFACCTNO  VARCHAR2(20);
    l_ACCTNO    VARCHAR2(20);
    l_CUSTNAME  VARCHAR2(500);
    l_ADDRESS   VARCHAR2(500);
    l_LICENSE   VARCHAR2(20);
    l_TRADE_CHK NUMBER(10);

    l_CUSTODYCD2    VARCHAR2(20);
    l_FULLNAME2     VARCHAR2(500);
    l_ADDRESS2      VARCHAR2(500);
    l_LICENSE2      VARCHAR2(20);

    v_strCURRDATE   date;
    v_desc          VARCHAR2(100);
    l_txmsg         tx.msg_rectype;
    l_err_param     varchar2(300);

    l_MRRATE    NUMBER(20,4);
    l_MRPRICE   NUMBER(20,4);
    l_PP        NUMBER(20,4);
    l_RLSAMT_CHK    NUMBER(20,4);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_Transfer_SE_account_2239');

    --Lay dien giai giao dich
    SELECT TLTX.EN_TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '2239';
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Transfer_SE_account');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    SELECT mrt.mrtype INTO l_MRTYPE
    FROM afmast af, aftype aft, mrtype mrt
    WHERE AF.ACCTNO = p_trfafacctno
        AND AF.STATUS NOT IN ('C')
        and af.actype = aft.actype and aft.mrtype = mrt.actype;
    if(l_MRTYPE <> 'T')then
        p_err_code:='-200110';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Transfer_SE_account_2239');
        return;
    end if;

    SELECT sym.codeid, cf.custodycd, semast.afacctno, semast.acctno,
        cf.fullname,  cf.ADDRESS, cf.idcode,
        semast.trade- nvl(b.secureamt,0)
    INTO l_CODEID, l_CUSTODYCD, l_AFACCTNO, l_ACCTNO, l_CUSTNAME, l_ADDRESS, l_LICENSE,
        l_TRADE_CHK
    FROM cfmast cf, afmast af, aftype aft, mrtype mrt, semast , sbsecurities sym,
       v_getsellorderinfo b
    WHERE AF.ACCTNO = p_trfafacctno
        AND SYM.SYMBOL = p_symbol
        AND sym.codeid = semast.codeid
        AND sym.sectype <> '004'
        AND semast.afacctno = af.acctno
        AND semast.acctno = b.seacctno(+)
        AND AF.STATUS NOT IN ('C')
        and af.custid = cf.custid and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
        and semast.trade > 0;

   select cf.custodycd, cf.FULLNAME, cf.ADDRESS, cf.idcode
        into l_CUSTODYCD2, l_FULLNAME2, l_ADDRESS2, l_LICENSE2
    from afmast af , cfmast cf
    where af.custid = cf.custid and af.acctno = p_rcvafacctno;

    if (l_CUSTODYCD2 <> l_CUSTODYCD) then
        p_err_code:='-200111';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Transfer_SE_account_2239');
        return;
    end if;

    l_MRRATE := cspks_mrproc.fn_getMrRate(p_rcvafacctno, l_CODEID);
    l_MRPRICE := cspks_mrproc.fn_getMrPrice(p_rcvafacctno, l_CODEID);
    l_PP := getavlpp(p_rcvafacctno);
    l_RLSAMT_CHK := (p_quantity*l_MRRATE*l_MRPRICE)/100;

    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='2239';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;

    l_txmsg.brid        := substr(p_trfafacctno,1,4);

    --CODEID
    l_txmsg.txfields ('01').defname   := 'CODEID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := l_CODEID;
    --AFACCTNO
    l_txmsg.txfields ('02').defname   := 'AFACCTNO';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := p_trfafacctno;
    --CUSTODYCD
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE     := l_CUSTODYCD;
    --ACCTNO
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := l_ACCTNO;
    --CUSTNAME
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     := l_CUSTNAME;
    --ADDRESS
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE     := l_ADDRESS;
    --LICENSE
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE     := l_LICENSE;
    --AFACCT2
    l_txmsg.txfields ('04').defname   := 'AFACCT2';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := p_rcvafacctno;
    --ACCT2
    l_txmsg.txfields ('05').defname   := 'ACCT2';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_rcvafacctno||l_CODEID;
    --CUSTODYCD2
    l_txmsg.txfields ('89').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('89').TYPE      := 'C';
    l_txmsg.txfields ('89').VALUE     := l_CUSTODYCD2;
    --CUSTNAME2
    l_txmsg.txfields ('93').defname   := 'CUSTNAME2';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE     := l_FULLNAME2;
    --ADDRESS2
    l_txmsg.txfields ('94').defname   := 'ADDRESS2';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE     := l_ADDRESS2;
    --LICENSE2
    l_txmsg.txfields ('95').defname   := 'LICENSE2';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE     := l_LICENSE2;
    --AMT_CHK
    l_txmsg.txfields ('21').defname   := 'AMT_CHK';
    l_txmsg.txfields ('21').TYPE      := 'N';
    l_txmsg.txfields ('21').VALUE     := l_TRADE_CHK;
    --AMT
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := p_quantity;
    --MRRATE
    l_txmsg.txfields ('11').defname   := 'MRRATE';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := l_MRRATE;
    --MRPRICE
    l_txmsg.txfields ('12').defname   := 'MRPRICE';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := l_MRPRICE;
    --PP
    l_txmsg.txfields ('16').defname   := 'PP';
    l_txmsg.txfields ('16').TYPE      := 'N';
    l_txmsg.txfields ('16').VALUE     := l_PP;
    --TOTALAMT
    l_txmsg.txfields ('17').defname   := 'TOTALAMT';
    l_txmsg.txfields ('17').TYPE      := 'N';
    l_txmsg.txfields ('17').VALUE     := l_PP+l_RLSAMT_CHK;
    --RLSAMT_CHK
    l_txmsg.txfields ('14').defname   := 'RLSAMT_CHK';
    l_txmsg.txfields ('14').TYPE      := 'N';
    l_txmsg.txfields ('14').VALUE     := l_RLSAMT_CHK;
    --RLSAMT
    l_txmsg.txfields ('15').defname   := 'RLSAMT';
    l_txmsg.txfields ('15').TYPE      := 'N';
    l_txmsg.txfields ('15').VALUE     := p_AMT;
    --HUNDRED
    l_txmsg.txfields ('99').defname   := 'HUNDRED';
    l_txmsg.txfields ('99').TYPE      := 'N';
    l_txmsg.txfields ('99').VALUE     := 100;
    --DESC
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := v_desc;


    BEGIN
        IF txpks_#2239.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 2239: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_Transfer_SE_account');
           RETURN;
        END IF;
    END;

    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_Transfer_SE_account_2239');
EXCEPTION
WHEN OTHERS
THEN
    plog.debug (pkgctx,'got error on pr_Transfer_SE_account_2239');
ROLLBACK;
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.error (pkgctx, SQLERRM);
    plog.setendsection (pkgctx, 'pr_Transfer_SE_account_2239');
    RAISE errnums.E_SYSTEM_ERROR;
END pr_Transfer_SE_account_2239;

PROCEDURE pr_GetMobileAdvInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     )
    IS
    l_AFACCTNO varchar2(100);
BEGIN
    plog.setBEGINsection(pkgctx, 'pr_GetMobileAdvInfo');
    l_AFACCTNO:=trim(p_AFACCTNO);

    OPEN p_REFCURSOR FOR
    select adv.autoadv,adv.acctno afacctno, adv.execamt, adv.aamt,adv.maxavlamt maxavlamt   ,nvl(avl.depoamt,0) avladvance
    from (
        select acctno,autoadv, sum(execamt) execamt, sum(aamt) aamt, sum(maxavlamt) maxavlamt
        from vw_advanceschedule adv
        where adv.isvsd ='N'
        group by acctno,autoadv ) adv,v_getaccountavladvance avl , sysvar SYS1
    where adv.acctno = avl.afacctno(+)
    and adv.acctno = l_AFACCTNO;
    plog.setendsection(pkgctx, 'pr_GetMobileAdvInfo');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetMobileAdvInfo');
END pr_GetMobileAdvInfo;

PROCEDURE pr_GetMobileAdvFee
    (p_AFACCTNO     IN VARCHAR2,
     p_type         in varchar2,
     p_amount       in number,
     p_fee          out number,
     p_err_code     OUT varchar2,
     p_err_message  OUT varchar2
     )
    IS
    l_AFACCTNO varchar2(100);
    l_dblamount number(20,0);
    l_dblbalance number(20,0);
    l_dblcmpfee number(20,0);
    l_dblbnkfee number(20,0);
    l_dbladvamount number(20,0);
    l_dblMinFee number;

    l_amount    number;
    v_avladvance number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_GetMobileAdvFee');
    --plog.error(pkgctx, 'p_AFACCTNO:' || p_AFACCTNO);
    --plog.error(pkgctx, 'p_type:' || p_type);
    --plog.error(pkgctx, 'p_amount:' || p_amount);

    p_err_code:='0';
    p_err_message:='';
    p_fee:=0;
    l_AFACCTNO:=trim(p_AFACCTNO);
    l_amount:=p_amount;
    --Kiem tra so tien ung truoc co vuot qua so tien duoc phep ung khong
    if p_type='1' then
        begin
            /*select nvl(depoamt,0) into v_avladvance
            from v_getaccountavladvance avl
            where afacctno = l_AFACCTNO;*/
            select depoamt-paidamt into v_avladvance
            from (
                select  sts.afacctno,sum(sts.aamt) aamt,
                   least(
                        greatest(sum(floor((sts.amt - exfeeamt)/(1+(sts.days*ADVRATE/100/360+sts.days*ADVBANKRATE/100/360)))),0),
                        greatest(sum(floor(sts.amt - exfeeamt)) - max (sts.ADVMINFEE) - max(sts.ADVMINFEEBANK),0)
                    )  depoamt, --Phi toi thieu theo 1 lan ung (1 lan ung co the ung cho nhieu ngay)
                    sum(rightvat) rightvat,
                    max(case when sy.varvalue='0' then 0 else fn_getdealgrppaid(sts.afacctno) end) paidamt, autoadv
                from
                    v_advanceSchedule sts, --where AUTOADV='Y'
                    sysvar sy
                where sy.grname = 'SYSTEM' and sy.varname ='HOSTATUS'

                group by sts.afacctno, autoadv
            ) where afacctno = l_AFACCTNO;
        exception when others then
            v_avladvance:=0;
        end ;
    else
        begin
            select sum(maxavlamt) maxavlamt into v_avladvance
            from vw_advanceschedule adv
            where adv.isvsd ='N' and acctno=l_AFACCTNO;
        exception when others then
            v_avladvance:=0;
        end;
    end if;
    if l_amount>v_avladvance then
        --Thong bao vuot qua so tien duoc phep ung truoc
        p_err_code:='-400200';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_GetMobileAdvFee');
        return;
    end if;
    for rec in
    (
        select sts.*, aft.adtype,AD.VATRATE, AD.ADVRATE AINTRATE,
            AD.ADVMINAMT AMINBAL,AD.ADVMINBANK AMINBANK, AD.ADVBANKRATE AFEEBANK, ADVMINFEE,0 AMINFEEBANK,
            'Ung truoc tien lenh ban ngay:' || sts.txdate DES,
            CF.address, cf.idcode license, ad.ADVMAXFEE,CASE WHEN STS.ISVSD = 'N' THEN 0 ELSE 1 END ISVSDFAKE
        FROM vw_advanceschedule sts, afmast af,
            cfmast cf, aftype aft, adtype ad
        where sts.acctno =af.acctno and af.custid=cf.custid
            and af.actype = aft.actype  and aft.adtype = ad.actype
            AND sts.isvsd <> 'Y'
            and af.acctno =l_AFACCTNO
        order by sts.acctno, sts.days
    )
    loop

        l_dblMinFee:=rec.ADVMINFEE;
        l_dbladvamount:=round(rec.maxavlamt,0);

        if p_type='1' then --Truyen vao so tien thuc nhan
            l_dblbalance:=l_amount;
            l_dblbalance:=ceil(l_dblbalance*(1+ rec.DAYS*rec.AINTRATE/100/360));
            l_dbladvamount:= round(least(l_dbladvamount,l_dblbalance),0);
        ELSE --Truyen vao so tien ung
            l_dbladvamount:=round(least(l_dbladvamount,l_amount),0);
        end if;

        l_dblcmpfee:= ceil(l_dbladvamount*rec.DAYS*rec.AINTRATE/100/360/(1+rec.DAYS*rec.AINTRATE/100/360));
        l_dblbnkfee:= ceil(l_dbladvamount*rec.DAYS*rec.AFEEBANK/100/360/(1+rec.DAYS*rec.AFEEBANK/100/360));
        l_dblamount:= round(l_dbladvamount-l_dblcmpfee,0);
        if l_dblMinFee>0 then
            l_dblMinFee:=greatest(l_dblMinFee-l_dblcmpfee-l_dblbnkfee,0);
            if round(rec.maxavlamt,0) > l_dbladvamount  then
                l_dblcmpfee := l_dblcmpfee + least(l_dblMinFee,round(rec.maxavlamt,0) - l_dbladvamount) ;
                l_dblMinFee:=l_dblMinFee-least(l_dblMinFee,round(rec.maxavlamt,0) - l_dbladvamount);
            end if;
        end if;
        l_amount:=l_amount-l_dblamount;
        p_fee:=p_fee+l_dblcmpfee;
    end loop;
    plog.setendsection(pkgctx, 'pr_GetMobileAdvFee');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetMobileAdvFee');
END pr_GetMobileAdvFee;


PROCEDURE pr_MobilleAdvancePayment
    (p_AFACCTNO     IN VARCHAR2,
     p_amount       in number,
     p_fee          in number,
     p_err_code     OUT varchar2,
     p_err_message  OUT varchar2,
     --log thong tin thiet bi
     p_ipaddress        IN     VARCHAR2 DEFAULT '',                 --1.0.6.0
     p_via              IN     VARCHAR2 DEFAULT '',
     p_validationtype   IN     VARCHAR2 DEFAULT '',
     p_devicetype       IN     VARCHAR2 DEFAULT '',
     p_device           IN     VARCHAR2 DEFAULT ''
     --End
     )
    IS
    l_AFACCTNO varchar2(100);
    l_txmsg               tx.msg_rectype;
    v_strCURRDATE varchar2(20);
    v_strPREVDATE varchar2(20);
    v_strNEXTDATE varchar2(20);
    v_strDesc varchar2(1000);
    v_strEN_Desc varchar2(1000);
    v_blnVietnamese BOOLEAN;
    l_err_param varchar2(300);
    l_MaxRow NUMBER(20,0);
    l_dblamount number(20,0);
    l_dblbalance number(20,0);
    l_dblcmpfee number(20,0);
    l_dblbnkfee number(20,0);
    l_dbladvamount number(20,0);
    l_ADTXNUM      VARCHAR2(10);
    l_dblMinFee number;

    l_amount    number;
    v_avladvance number;
    L_STARTTIME number(10);
    L_ENDTIME number(10);
    L_CURRTIME number(10);
    l_PROMOTIONRATE number(20,4);
BEGIN
    plog.setBeginSection(pkgctx, 'pr_MobilleAdvancePayment');
    p_err_code:='0';
    p_err_message:='';
    --p_fee:=0;
    l_AFACCTNO:=trim(p_AFACCTNO);
    l_amount:=p_amount;
    SELECT TXDESC,EN_TXDESC into v_strDesc, v_strEN_Desc FROM  TLTX WHERE TLTXCD='1153';

    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_MobilleAdvancePayment');
        return ;
    END IF;

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTADVPAYMENT';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDADVPAYMENT';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 160000;
    END ;

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    if ( NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
        p_err_code := '-994460';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_AdvancePayment');
        return;
    end if;

    SELECT MIN (FEERATE) into l_PROMOTIONRATE FROM (
    SELECT ADP.AFACCTNO, MST.FEERATE FROM ADPRMFEECF ADP , ADPRMFEEMST MST
    WHERE GETCURRDATE BETWEEN ADP.VALDATE AND ADP.EXPDATE AND ADP.STATUS = 'A'
        AND ADP.PROMOTIONID = MST.AUTOID AND ADP.AFACCTNO = l_AFACCTNO
    );
    l_PROMOTIONRATE := nvl(l_PROMOTIONRATE,1000);

    -- End: Check host 1 active or inactive
    --Kiem tra so tien ung truoc co vuot qua so tien duoc phep ung khong
    begin
        /*select nvl(depoamt,0) into v_avladvance
        from v_getaccountavladvance avl
        where afacctno = l_AFACCTNO;*/
        select depoamt-paidamt, ADVMINFEE into v_avladvance, l_dblMinFee
            from (
                select  sts.afacctno,sum(sts.aamt) aamt,
                        least(
                        greatest(sum(floor((sts.amt - exfeeamt)/(1+(sts.days*least(ADVRATE,l_PROMOTIONRATE)/100/360+sts.days*ADVBANKRATE/100/360)))),0),
                        greatest(sum(floor(sts.amt - exfeeamt)) - max (sts.ADVMINFEE) - max(sts.ADVMINFEEBANK),0)
                    ) depoamt, --Phi toi thieu theo 1 lan ung (1 lan ung co the ung cho nhieu ngay)
                    sum(rightvat) rightvat,
                    max (sts.ADVMINFEE) ADVMINFEE,
                    max(case when sy.varvalue='0' then 0 else fn_getdealgrppaid(sts.afacctno) end) paidamt, autoadv
                from
                    v_advanceSchedule sts, --where AUTOADV='Y'
                    sysvar sy,       sysvar sy1
                where sy.grname = 'SYSTEM' and sy.varname ='HOSTATUS'
                group by sts.afacctno, autoadv
            ) where afacctno = l_AFACCTNO;
    exception when others then
        v_avladvance:=0;
    end ;
    if l_amount>v_avladvance then
        --Thong bao vuot qua so tien duoc phep ung truoc
        p_err_code:='-400200';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_MobilleAdvancePayment');
        return;
    end if;

    SELECT TO_CHAR(getcurrdate)
               INTO v_strCURRDATE
    FROM DUAL;
    l_txmsg.msgtype     :='T';
    l_txmsg.local       :='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd      :='1153';

    l_dblbalance:=0;

    for rec in
    (
        select sts.*, aft.adtype,AD.VATRATE, least(AD.ADVRATE,l_PROMOTIONRATE) AINTRATE,
            AD.ADVMINAMT AMINBAL,AD.ADVMINBANK AMINBANK, AD.ADVBANKRATE AFEEBANK, ADVMINFEE,0 AMINFEEBANK,
            'Ung truoc tien lenh ban ngay:' || sts.txdate DES,
            CF.address, cf.idcode license, ad.ADVMAXFEE,CASE WHEN STS.ISVSD = 'N' THEN 0 ELSE 1 END ISVSDFAKE
        FROM vw_advanceschedule sts, afmast af,
            cfmast cf, aftype aft, adtype ad
        where sts.acctno =af.acctno and af.custid=cf.custid
            and af.actype = aft.actype  and aft.adtype = ad.actype
            AND sts.isvsd <> 'Y' -- HaiLT them de chan UT doi voi lenh ban cam co VSD
            and af.acctno =l_AFACCTNO
        order by sts.acctno, sts.days
    )
    loop
        l_dbladvamount:=round(rec.maxavlamt,0);
        l_dblbalance:=l_amount;


        l_dblbalance:=ceil(l_dblbalance*(1+ rec.DAYS*rec.AINTRATE/100/360));
        l_dbladvamount:= round(least(l_dbladvamount,l_dblbalance),0);


        l_dblcmpfee:= ceil(l_dbladvamount*rec.DAYS*rec.AINTRATE/100/360/(1+rec.DAYS*rec.AINTRATE/100/360));
        l_dblbnkfee:= ceil(l_dbladvamount*rec.DAYS*rec.AFEEBANK/100/360/(1+rec.DAYS*rec.AFEEBANK/100/360));
        l_dblamount:= round(l_dbladvamount-l_dblcmpfee,0);
        if l_dblMinFee>0 then
            l_dblMinFee:=greatest(l_dblMinFee-l_dblcmpfee-l_dblbnkfee,0);
            if round(rec.maxavlamt,0) > l_dbladvamount  then
                l_dblcmpfee := l_dblcmpfee + least(l_dblMinFee,round(rec.maxavlamt,0) - l_dbladvamount) ;
                l_dblMinFee:=l_dblMinFee-least(l_dblMinFee,round(rec.maxavlamt,0) - l_dbladvamount);
            end if;
        end if;

        IF l_dblamount + l_dblcmpfee + l_dblbnkfee >0 then --AND l_dbladvamount >= ROUND(REC.AMINBAL+REC.AMINBANK,0) THEN
            --Set txnum
            plog.debug(pkgctx, 'Loop for account:' || rec.ACCTNO || ' ngay' || to_char(rec.cleardate));
            SELECT systemnums.C_OL_PREFIXED
                             || LPAD (seq_batchtxnum.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            l_txmsg.brid        := substr(rec.ACCTNO,1,4);
            --Set cac field giao dich
            l_txmsg.txfields ('60').defname   := 'ISVSD';
            l_txmsg.txfields ('60').TYPE      := 'C';
            l_txmsg.txfields ('60').VALUE     := rec.ISVSDFAKE;

            --03   ACCTNO       C
            l_txmsg.txfields ('03').defname   := 'ACCTNO';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := rec.ACCTNO;
            --06    ADTYPE      C
            l_txmsg.txfields ('06').defname   := 'ADTYPE';
            l_txmsg.txfields ('06').TYPE      := 'C';
            l_txmsg.txfields ('06').VALUE     := rec.adtype;
            --08    DUEDATE      C
            l_txmsg.txfields ('08').defname   := 'DUEDATE';
            l_txmsg.txfields ('08').TYPE      := 'C';
            l_txmsg.txfields ('08').VALUE     := to_char(rec.CLEARDATE,'DD/MM/RRRR');
             --09   ADVAMT          N
            l_txmsg.txfields ('09').defname   := 'ADVAMT';
            l_txmsg.txfields ('09').TYPE      := 'N';
            l_txmsg.txfields ('09').VALUE     := l_dblamount + l_dblcmpfee + l_dblbnkfee;
            --10    AMT         N
            l_txmsg.txfields ('10').defname   := 'AMT';
            l_txmsg.txfields ('10').TYPE      := 'N';
            l_txmsg.txfields ('10').VALUE     := l_dblamount;
            --11    FEEAMT      N
            l_txmsg.txfields ('11').defname   := 'FEEAMT';
            l_txmsg.txfields ('11').TYPE      := 'N';
            l_txmsg.txfields ('11').VALUE     := l_dblcmpfee;

            --12    INTRATE     N
            l_txmsg.txfields ('12').defname   := 'INTRATE';
            l_txmsg.txfields ('12').TYPE      := 'N';
            l_txmsg.txfields ('12').VALUE     := rec.AINTRATE;
            --13    DAYS        N
            l_txmsg.txfields ('13').defname   := 'DAYS';
            l_txmsg.txfields ('13').TYPE      := 'N';
            l_txmsg.txfields ('13').VALUE     := rec.DAYS;
            --14    BNKFEEAMT   N
            l_txmsg.txfields ('14').defname   := 'BNKFEEAMT';
            l_txmsg.txfields ('14').TYPE      := 'N';
            l_txmsg.txfields ('14').VALUE     := l_dblbnkfee;
            --15    BNKRATE     N
            l_txmsg.txfields ('15').defname   := 'BNKRATE';
            l_txmsg.txfields ('15').TYPE      := 'N';
            l_txmsg.txfields ('15').VALUE     := rec.AFEEBANK;
            --16    CMPMINBAL   N
            l_txmsg.txfields ('16').defname   := 'CMPMINBAL';
            l_txmsg.txfields ('16').TYPE      := 'N';
            l_txmsg.txfields ('16').VALUE     := rec.ADVMINFEE;
            --17    BNKMINBAL   N
            l_txmsg.txfields ('17').defname   := 'BNKMINBAL';
            l_txmsg.txfields ('17').TYPE      := 'N';
            l_txmsg.txfields ('17').VALUE     := rec.AMINFEEBANK;
            --18    VATAMT  N
            l_txmsg.txfields ('18').defname   := 'VATAMT';
            l_txmsg.txfields ('18').TYPE      := 'N';
            l_txmsg.txfields ('18').VALUE     := rec.VATRATE * (l_dblcmpfee+l_dblbnkfee)/100;
            --19    VAT     N
            l_txmsg.txfields ('19').defname   := 'VAT';
            l_txmsg.txfields ('19').TYPE      := 'N';
            l_txmsg.txfields ('19').VALUE     := rec.VATRATE;
            --20    MAXAMT      N
            l_txmsg.txfields ('20').defname   := 'MAXAMT';
            l_txmsg.txfields ('20').TYPE      := 'N';
            l_txmsg.txfields ('20').VALUE     := round(rec.MAXAVLAMT,0);
            --21    AMINBAL      N
            l_txmsg.txfields ('21').defname   := 'AMINBAL';
            l_txmsg.txfields ('21').TYPE      := 'N';
            l_txmsg.txfields ('21').VALUE     := 0;
            --22   ADVMAXFEE         N
            l_txmsg.txfields ('22').defname   := 'ADVMAXFEE';
            l_txmsg.txfields ('22').TYPE      := 'N';
            l_txmsg.txfields ('22').VALUE     := rec.ADVMAXFEE;
            --30    DESC        C
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := rec.DES;
            --40    3600        C
            l_txmsg.txfields ('40').defname   := '3600';
            l_txmsg.txfields ('40').TYPE      := 'C';
            l_txmsg.txfields ('40').VALUE     := 36000;
            --41    100         C
            l_txmsg.txfields ('41').defname   := '100';
            l_txmsg.txfields ('41').TYPE      := 'C';
            l_txmsg.txfields ('41').VALUE     := 100;
            --42    MATCHDATE         C
            l_txmsg.txfields ('42').defname   := 'MATCHDATE';
            l_txmsg.txfields ('42').TYPE      := 'C';
            l_txmsg.txfields ('42').VALUE     := rec.txdate;
            --88    CUSTODYCD    C
            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD;
            --89    ACTYPE    C
            l_txmsg.txfields ('89').defname   := 'ACTYPE';
            l_txmsg.txfields ('89').TYPE      := 'C';
            l_txmsg.txfields ('89').VALUE     := rec.ACTYPE;
            --90    CUSTNAME    C
            l_txmsg.txfields ('90').defname   := 'CUSTNAME';
            l_txmsg.txfields ('90').TYPE      := 'C';
            l_txmsg.txfields ('90').VALUE     := rec.FULLNAME;
            --91    ADDRESS     C
            l_txmsg.txfields ('91').defname   := 'ADDRESS';
            l_txmsg.txfields ('91').TYPE      := 'C';
            l_txmsg.txfields ('91').VALUE     := rec.ADDRESS;
            --92    LICENSE     C
            l_txmsg.txfields ('92').defname   := 'LICENSE';
            l_txmsg.txfields ('92').TYPE      := 'C';
            l_txmsg.txfields ('92').VALUE     := rec.LICENSE;

            --93    BANKACCT    C
            l_txmsg.txfields ('93').defname   := 'BANKACCT';
            l_txmsg.txfields ('93').TYPE      := 'C';
            l_txmsg.txfields ('93').VALUE     := rec.BANKACCT;
            --94    COREBANK     C
            l_txmsg.txfields ('94').defname   := 'COREBANK';
            l_txmsg.txfields ('94').TYPE      := 'C';
            l_txmsg.txfields ('94').VALUE     := rec.COREBANK;
            --95    BANKCODE     C
            l_txmsg.txfields ('95').defname   := 'BANKCODE';
            l_txmsg.txfields ('95').TYPE      := 'C';
            l_txmsg.txfields ('95').VALUE     := rec.BANKCODE;

            --96    IDDATE     C
            l_txmsg.txfields ('96').defname   := 'IDDATE';
            l_txmsg.txfields ('96').TYPE      := 'C';
            l_txmsg.txfields ('96').VALUE     := rec.txdate;

            --97    IDPLACE     C
            l_txmsg.txfields ('97').defname   := 'IDPLACE';
            l_txmsg.txfields ('97').TYPE      := 'C';
            l_txmsg.txfields ('97').VALUE     := '';

            BEGIN
                IF txpks_#1153.fn_batchtxprocess (l_txmsg,
                                                 p_err_code,
                                                 l_err_param
                   ) <> systemnums.c_success
                THEN
                   plog.error (pkgctx,
                               'got error 1153 : p_AFACCTNO : ' || p_AFACCTNO || ' p_amount : ' || p_amount ||  ' p_fee : '  || p_fee || ' p_err_code: ' ||  p_err_code
                   );
                   IF(p_err_code IS NULL OR LENGTH (TRIM(p_err_code)) < 1) THEN
                        p_err_code := -1;
                   END IF;
                   p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                   plog.setendsection(pkgctx, 'pr_MobilleAdvancePayment');
                   ROLLBACK;
                   RETURN;
                END IF;
            END;

            --26/07/2022 Ghep log thong tin thiet bi
            pr_insertiplog (l_txmsg.txnum,
                            l_txmsg.txdate,
                            p_ipaddress,
                            p_via,
                            p_validationtype,
                            p_devicetype,
                            p_device,
                            NULL);
        END IF;
        l_amount:=l_amount-l_dblamount;
    end loop;
    p_err_code:=0;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    plog.setendsection(pkgctx, 'pr_MobilleAdvancePayment');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_MobilleAdvancePayment');
END pr_MobilleAdvancePayment;


PROCEDURE pr_GetSeInternalTransferInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     )
    IS
    l_AFACCTNO varchar2(100);
BEGIN
    plog.setBeginSection(pkgctx, 'pr_GetSeInternalTransferInfo');
    l_AFACCTNO:=trim(p_AFACCTNO);

    OPEN p_REFCURSOR FOR
    select acctnoafmast afacctno, symbol,trade,BLOCKED_CHK BLOCKED  from vw_SE2242 where acctnoafmast = l_AFACCTNO;

    plog.setendsection(pkgctx, 'pr_GetSeInternalTransferInfo');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetSeInternalTransferInfo');
END pr_GetSeInternalTransferInfo;

procedure pr_get_PNL_executed
    (p_refcursor    in out pkg_report.ref_cursor,
    p_custodycd     in VARCHAR2,
    p_afacctno      IN  varchar2,
    SYMBOL          IN  VARCHAR2,
    F_DATE         IN VARCHAR2,
    T_DATE         IN VARCHAR2
    )IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
    V_FROMDATE      DATE;
    V_TODATE        DATE;
    V_STRSYMBOL     varchar2(50);
BEGIN
    plog.setBeginSection(pkgctx, 'pr_get_PNL_executed');


    V_FROMDATE := to_date(F_DATE,'dd/mm/rrrr');
    V_TODATE   := to_date(T_DATE,'dd/mm/rrrr');

    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '%';
    ELSE
        V_CUSTODYCD := upper(p_custodycd);
    END IF;

    IF SYMBOL is NULL or upper(SYMBOL) = 'ALL'  THEN
        V_STRSYMBOL := '%';
    ELSE
        V_STRSYMBOL := upper(SYMBOL);
    END IF;
    IF p_afacctno = 'ALL' OR p_afacctno IS NULL THEN
        V_AFACCTNO := '%';
    ELSE
        V_AFACCTNO := p_afacctno;
        SELECT CF.CUSTODYCD INTO V_CUSTODYCD
        FROM AFMAST AF, CFMAST CF
        WHERE AF.custid = CF.custid AND AF.ACCTNO = p_afacctno;
    END IF;
 OPEN p_refcursor FOR
        SELECT cf.custodycd,vw.txdate, vw.afacctno, sb.symbol, (vw.qtty) netqtty,round((vw.amt)/(vw.qtty),2) costprice_o,
            (vw.amt) sellvalue, (vw.costprice) costprice_i, ((vw.costprice) * (vw.qtty)) netvalue,
            round(((vw.amt - od.TaxAndFee)/vw.qtty - vw.costprice)*vw.qtty,2) PNL,
            CASE WHEN vw.costprice = 0 THEN 0 ELSE round((((vw.amt-od.TaxAndFee)/vw.qtty) - vw.costprice)*100/(vw.costprice),2) END pnlrate
        FROM vw_stschd_all vw, sbsecurities sb, cfmast cf, afmast af,
        (Select orderid, taxsellamt + DECODE(feeamt,0, feeacr, feeamt) TaxAndFee from vw_odmast_all) od
        WHERE vw.duetype = 'SS'
            AND vw.codeid = sb.codeid
            AND vw.afacctno = af.acctno
            AND af.custid = cf.custid
            and vw.txdate >= V_FROMDATE
            and vw.txdate <= V_TODATE
            and vw.txdate < to_date('11/04/2018','DD/MM/RRRR')
            and vw.orgorderid= od.orderid
            and upper(sb.symbol) like V_STRSYMBOL
            and cf.custodycd like V_CUSTODYCD
            and af.acctno like V_AFACCTNO
            and vw.deltd = 'N'
      union all


         select A.custodycd,A.txdate,A.afacctno,A.symbol,A.qtty_sell netqtty,ROUND(A.MATCHSELLAMT/A.MATCHQTTY_SELL,2) COSTPRICE_O,
            A.AMT_SELL sellvalue, A.RTCOSTPRICE COSTPRICE_I,(A.qtty_sell*A.RTCOSTPRICE) netvalue,
                A.PNL,(case when A.val_sell =0 then 0 else round(A.PNL/A.val_sell,4)  end)*100 pnlrate
        from
        (
            SELECT CF.CUSTODYCD,OD.AFACCTNO, OD.CODEID,SB.SYMBOL,OD.TXDATE, OD.ORDERID, MAX(SEC.RTCOSTPRICE) RTCOSTPRICE,SUM(IO.MATCHPRICE*IO.MATCHQTTY) MATCHSELLAMT,
                 (
                    (
                        SUM(IO.MATCHPRICE*IO.MATCHQTTY)
                            - CASE WHEN OD.TXDATE = GETCURRDATE THEN SUM((ODT.DEFFEERATE/100)*(IO.MATCHPRICE*IO.MATCHQTTY)) ELSE MAX(OD.FEEACR) END
                            - CASE WHEN OD.TXDATE = GETCURRDATE THEN SUM((ODT.VATRATE/100/100)*(IO.MATCHPRICE*IO.MATCHQTTY)) ELSE MAX(OD.TAXSELLAMT) END
                    )-
                    (
                        CASE
                            WHEN SUM(SEC.RTCOSTPRICE*IO.MATCHQTTY) <0 THEN 0
                            ELSE SUM(SEC.RTCOSTPRICE*IO.MATCHQTTY)
                        END
                    )
                 )
                 PNL,
                SUM(SEC.RTCOSTPRICE*IO.MATCHQTTY) VAL_SELL,
                (
                SUM(IO.MATCHPRICE*IO.MATCHQTTY)
                    - CASE WHEN OD.TXDATE = GETCURRDATE THEN SUM((ODT.DEFFEERATE/100)*(IO.MATCHPRICE*IO.MATCHQTTY)) ELSE MAX(OD.FEEACR) END
                    - CASE WHEN OD.TXDATE = GETCURRDATE THEN SUM((ODT.VATRATE/100/100)*(IO.MATCHPRICE*IO.MATCHQTTY)) ELSE MAX(OD.TAXSELLAMT) END
                )  AMT_SELL,
                SUM(IO.MATCHQTTY) QTTY_SELL,
                SUM(IO.MATCHQTTY) MATCHQTTY_SELL
            FROM VW_ODMAST_ALL OD , AFMAST AF,CFMAST CF,SBSECURITIES SB, VW_IOD_ALL IO, ODTYPE ODT,
                (
                    SELECT ORDERID, max(round(RTCOSTPRICE,0)) RTCOSTPRICE
                    FROM SECMAST
                    WHERE ORDERID IS NOT NULL
                        AND TXDATE >= V_FROMDATE AND TXDATE <= V_TODATE
                        and txdate >= to_date('11/04/2018','DD/MM/RRRR')
                        AND PTYPE = 'O'
                    GROUP BY ORDERID
                ) SEC
            WHERE OD.EXECAMT > 0
                AND OD.AFACCTNO = AF.ACCTNO
                AND OD.ACTYPE = ODT.ACTYPE
                AND AF.CUSTID = CF.CUSTID
                AND OD.TXDATE >= V_FROMDATE
                AND OD.TXDATE <= V_TODATE
                and od.txdate >= to_date('11/04/2018','DD/MM/RRRR')
                AND OD.CODEID = SB.CODEID
                AND IO.ORGORDERID = OD.ORDERID
                AND SEC.ORDERID = OD.ORDERID
               /* AND EXISTS(
                                        SELECT *
                                        FROM tlgrpusers tl, tlgroups gr
                                        WHERE AF.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE V_STRTLID
                                        )*/
                AND AF.ACCTNO LIKE V_AFACCTNO
                and cf.custodycd like  V_CUSTODYCD
                and sb.symbol like V_STRSYMBOL
                AND OD.EXECTYPE LIKE '%S'
            group by cf.custodycd,od.afacctno, od.codeid,sb.symbol,od.txdate, OD.ORDERID
        )A
        order by txdate asc;
    plog.setendsection(pkgctx, 'pr_get_PNL_executed');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_get_PNL_executed');
END pr_get_PNL_executed;

procedure pr_get_MarginT3Indue
    (p_refcursor    in out pkg_report.ref_cursor,
        p_tlid     in VARCHAR2
    )
    IS

BEGIN
    plog.setBeginSection(pkgctx, 'pr_get_MarginT3Indue');

    OPEN p_refcursor FOR
        select mr.* from vw_mr0008 mr, tlgrpusers tl, tlgroups gr
        where mr.careby = tl.grpid and tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid=p_tlid;

    plog.setendsection(pkgctx, 'pr_get_MarginT3Indue');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_get_MarginT3Indue');
END pr_get_MarginT3Indue;

procedure pr_get_OD_info
    (
    p_refcursor    in out pkg_report.ref_cursor,
    pv_custodycd     in VARCHAR2,
    pv_afacctno      IN  varchar2,
    pv_FDATE         IN VARCHAR2,
    pv_TDATE         IN VARCHAR2
    ) --- tra cuu lenh tong hop.
    IS
BEGIN
    plog.setBeginSection(pkgctx, 'pr_get_OD_info');
    OPEN p_refcursor FOR
    SELECT T.TXDATE, T.ORDERID, T.TXTIME, A1.cdcontent ORSTATUS, T.TRADEPLACE, T.CUSTODYCD, T.CIACCTNO,
        T.MNEMONIC, T.EXECTYPE, T.SYMBOL, T.ORDERQTTY, T.QUOTEPRICE, T.PRICETYPE,
        NVL(IO.MATCHQTTY,0) MATCHQTTY, NVL(IO.MATCHPRICE,0) MATCHPRICE,
        NVL(IO.MATCHQTTY,0) * NVL(IO.MATCHPRICE,0) MATCHAMT,
        T.FEERATE, T.FEEACR, T.username
    FROM
        (
            SELECT OD.ORDERID, OD.TXDATE, SB.SYMBOL, (CASE WHEN OD.PRICETYPE IN ('ATO','ATC')THEN  OD.PRICETYPE
                ELSE TO_CHAR(OD.QUOTEPRICE) END) QUOTEPRICE , OD.ORDERQTTY,OD.CIACCTNO,CF.FULLNAME,
                CASE WHEN OD.EXECAMT >0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N'
                THEN ROUND(OD.EXECAMT * ODT.DEFFEERATE/100) ELSE OD.FEEACR END FEEACR, ODT.DEFFEERATE FEERATE,
                CF.CUSTODYCD , OD.VIA  VIA, OD.TXTIME, OD.MATCHTYPE,
                (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE OD.EXECTYPE END) EXTY,
                (CASE  WHEN OD.REFORDERID IS NOT NULL THEN 'C' ELSE 'O' END) TYORDER,
                (CASE WHEN OD.REMAINQTTY <> 0 AND OD.EDSTATUS='C' THEN 'C'
                  WHEN OD.REMAINQTTY <> 0 AND OD.EDSTATUS='A' THEN 'A'
                  WHEN OD.EDSTATUS IS NULL AND OD.CANCELQTTY <> 0 THEN '5'
                  WHEN OD.REMAINQTTY = 0 AND OD.CANCELQTTY <> 0 AND OD.EDSTATUS='C' THEN '3'
                  when OD.REMAINQTTY = 0 and OD.ADJUSTQTTY>0 AND OD.pricetype = 'MP' then '4'
                  when OD.REMAINQTTY = 0 and OD.ADJUSTQTTY>0 then '10'
                  WHEN OD.REMAINQTTY = 0 AND OD.EXECQTTY>0 AND OD.ORSTATUS = '4' THEN '12' ELSE OD.ORSTATUS END) ORSTATUSVALUE,
                A2.cdcontent tradeplace, AFT.mnemonic, A3.cdcontent EXECTYPE, OD.PRICETYPE,
                (CASE  WHEN cf.vat = 'N' then 0 else to_number(sys.varvalue)*OD.EXECAMT END) VAT,
                tlp.tlname username
            FROM (SELECT * FROM vw_odmast_tradeplace_all WHERE deltd <> 'Y') OD,
                SBSECURITIES SB, AFMAST AF, CFMAST CF, ODTYPE odt, AFTYPE AFT,
                ALLCODE A2, allcode A3, sysvar sys, vw_tllog_all tl,
                tlprofiles tlp
            WHERE OD.CODEID = SB.CODEID AND odt.actype = OD.ACTYPE AND OD.CIACCTNO = AF.ACCTNO
                AND AF.CUSTID = CF.CUSTID
                AND A2.CDTYPE = 'OD' AND A2.CDNAME = 'TRADEPLACE' AND OD.tradeplace = A2.cdval
                AND AF.actype = AFT.actype
                AND A3.cdtype = 'OD' and A3.cdname = 'EXECTYPE' AND OD.EXECTYPE = A3.cdval
                and sys.varname like 'ADVSELLDUTY' and sys.grname = 'SYSTEM' and sys.editallow = 'N'
                and od.txnum = tl.txnum and od.txdate = tl.txdate and tl.tlid = tlp.tlid and tl.deltd <> 'Y'
                and od.exectype in ('NB','NS','MS')
                AND OD.TXDATE >= TO_DATE (pv_FDATE,'DD/MM/YYYY') AND OD.TXDATE <= TO_DATE (pv_TDATE,'DD/MM/YYYY')
                and cf.custodycd = pv_custodycd and af.acctno = pv_afacctno
        ) T inner join ALLCODE A1 on  A1.CDTYPE = 'OD' AND A1.CDNAME = 'ORSTATUS' AND T.ORSTATUSVALUE = A1.cdval
        LEFT JOIN
        (
            SELECT * FROM IOD WHERE DELTD <> 'Y'
            UNION ALL
            SELECT * FROM IODHIST  WHERE DELTD <> 'Y'
        ) IO
        ON IO.ORGORDERID = T.ORDERID
    ORDER BY  T.EXECTYPE, T.SYMBOL, T.TXDATE, T.CIACCTNO;

    plog.setendsection(pkgctx, 'pr_get_OD_info');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_get_OD_info');
END pr_get_OD_info;

PROCEDURE pr_updatepassonline(p_username varchar,
                              P_pwtype   varchar2,
                              P_password   varchar2,
                              p_err_code  OUT varchar2,
                              p_err_message out varchar2)
 IS

      v_mobile varchar2(20);
      l_datasourcesms varchar2(1000);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_updatepassonline');

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_updatepassonline');
        return;
    END IF;
    v_mobile:='';
     For vc in (select mobile
                         from cfmast where username=p_username )
     Loop
                         v_mobile:=vc.mobile;
     End loop;

    IF P_pwtype = 'LOGINPWD' THEN

        Update userlogin
        Set LOGINPWD= genencryptpassword(P_password),
        ISRESET='N',
        lastchanged = sysdate
        where username = p_username;
        /*If length(v_mobile)>1 then
                l_datasourcesms:='select ''MSBS thong bao: Mat khau dang nhap cua so tai khoan '||p_username||' la: '||P_password||''' detail from dual';
                nmpks_ems.InsertEmailLog(v_mobile, '0335', l_datasourcesms, '');
        End if;*/

    ELSIF P_PWTYPE= 'TRADINGPWD' THEN
        Update userlogin
        Set TRADINGPWD= genencryptpassword(P_password),
        ISRESET='N',
        lastchanged = sysdate
        where username = p_username;
      /*  If length(v_mobile)>1 then
                l_datasourcesms:='select ''MSBS thong bao: PIN cua so tai khoan '||p_username||' la: '||P_password||''' detail from dual';
                nmpks_ems.InsertEmailLog(v_mobile, '0335', l_datasourcesms, '');
        End if;*/


    END IF;

        insert into PASS_CUSTOMER_LOG(username,TXDATE,MKID,TXDESC)
        values (p_username,sysdate,'HOME',P_PWTYPE);


    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_updatepassonline');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_updatepassonline');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_updatepassonline');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_updatepassonline;

--api online
PROCEDURE pr_updatepassonline_web   (p_username varchar,
                                    P_pwtype   varchar2,
                                    P_old_loginpass   varchar2,
                                    P_new_loginpass   varchar2,
                                    P_old_tradingpass   varchar2,
                                    P_new_tradingpass   varchar2,
                                    p_err_code  OUT varchar2,
                                    p_err_message out varchar2
                                    )
 IS

      v_old_loginpass1 varchar2(1000);
      v_old_tradingpass2    varchar2(1000);
      v_pass1    varchar2(1000);
      v_pass2    varchar2(1000);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_updatepassonline_web');

/*    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_updatepassonline_web');
        return;
    END IF;*/
    select genencryptpassword(P_old_loginpass) into v_old_loginpass1 from dual;
    select genencryptpassword(P_old_tradingpass) into v_old_tradingpass2 from dual;
    select LOGINPWD into v_pass1 from userlogin where username = p_username and status='A';
    select TRADINGPWD into v_pass2 from userlogin where username = p_username and status='A';

    IF P_pwtype = 'LOGINPWD' THEN
      IF v_old_loginpass1 = v_pass1 THEN
        Update userlogin
        Set LOGINPWD= genencryptpassword(P_new_loginpass),
        ISRESET='N',
        lastchanged = sysdate
        where username = p_username;
        insert into PASS_CUSTOMER_LOG(username,TXDATE,MKID,TXDESC)
        values (p_username,sysdate,'ONLINE','LOGINPWD');
      ELSE
        p_err_code:='-670095';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_updatepassonline_web');
        return;
      END IF;

    ELSIF P_PWTYPE= 'TRADINGPWD' THEN
     IF v_old_tradingpass2 = v_pass2 THEN
        Update userlogin
        Set TRADINGPWD= genencryptpassword(P_new_tradingpass),
        ISRESET='N',
        lastchanged = sysdate
        where username = p_username;

        insert into PASS_CUSTOMER_LOG(username,TXDATE,MKID,TXDESC)
        values (p_username,sysdate,'ONLINE','TRADINGPWD');

      ELSE
        p_err_code:='-670094';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_updatepassonline_web');
        return;
      END IF;
    ELSIF P_PWTYPE= 'LOGINTRADE' THEN
     IF v_old_loginpass1 <> v_pass1 THEN
        p_err_code:='-670095';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_updatepassonline_web');
        return;
      ELSE
        IF v_old_tradingpass2 <> v_pass2 THEN
           p_err_code:='-670094';
          p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
          plog.error(pkgctx, 'Error:'  || p_err_message);
          plog.setendsection(pkgctx, 'pr_updatepassonline_web');
          return;
        ELSE
          Update userlogin
          Set LOGINPWD= genencryptpassword(P_new_loginpass),
          TRADINGPWD= genencryptpassword(P_new_tradingpass),
          ISRESET='N',
          lastchanged = sysdate
          where username = p_username;

         insert into PASS_CUSTOMER_LOG(username,TXDATE,MKID,TXDESC)
         values (p_username,sysdate,'ONLINE','LOGINTRADE');

         END IF;
         END IF;

    END IF;


    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_updatepassonline_web');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_updatepassonline_web');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_updatepassonline_web');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_updatepassonline_web;


procedure pr_getEmailSMSRegister
    (
    p_refcursor    in out pkg_report.ref_cursor,
    pv_custodycd     in VARCHAR2
    )
    IS
BEGIN
    plog.setBeginSection(pkgctx, 'pr_getEmailSMSRegister');
    OPEN p_refcursor FOR
    select code,subject,type,(case when require_register='N' then 'Y' else 'N' end) registered,require_register AllowChange
        from templates t where internal ='N' and not EXISTS (select t.code from aftemplates tmp, cfmast cf
        where tmp.custid = cf.custid  and tmp.template_code=t.code
        and cf.custodycd=pv_custodycd and template_code=t.code)
    union
    select t.code,t.subject,t.type,'Y' registered, 'Y' AllowChange from aftemplates tmp, cfmast cf , templates t
        where tmp.custid = cf.custid  and tmp.template_code=t.code and t.internal ='N'
        and cf.custodycd=pv_custodycd;

    plog.setendsection(pkgctx, 'pr_getEmailSMSRegister');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_getEmailSMSRegister');
END pr_getEmailSMSRegister;

procedure pr_EmailSMSRegister
    (
    pv_custodycd     in VARCHAR2,
    pv_code     in VARCHAR2,
    pv_register in varchar2,
    p_err_code  OUT varchar2,
    p_err_message out varchar2
    )
    IS
    v_custid varchar2(10);
    v_count number;
BEGIN
    plog.setBeginSection(pkgctx, 'pr_EmailSMSRegister');
    p_err_code:=0;

    begin
        select count(*) into v_count
        from aftemplates tmp, cfmast cf
        where tmp.custid = cf.custid
        and cf.custodycd=pv_custodycd and template_code=pv_code;

        select custid into v_custid
        from cfmast where custodycd =pv_custodycd;
    EXCEPTION when others then
        p_err_code:='-100054';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setEndSection(pkgctx, 'pr_EmailSMSRegister');
        return;
    end;

    if pv_register='Y' then
        --Dang ky
        if v_count=0 then
            INSERT INTO aftemplates (AUTOID,CUSTID,TEMPLATE_CODE)
            VALUES(seq_aftemplates.nextval ,v_custid,pv_code);
        else
            plog.setEndSection(pkgctx, 'pr_EmailSMSRegister');
            return;
        end if;
    else
        --Huy dang ky
        if v_count>0 then
            delete from aftemplates where custid =v_custid and template_code= pv_code;
        else
            plog.setEndSection(pkgctx, 'pr_EmailSMSRegister');
            return;
        end if;
    end if;

    plog.setendsection(pkgctx, 'pr_EmailSMSRegister');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_EmailSMSRegister');
END pr_EmailSMSRegister;

PROCEDURE pr_Tradelot_Retail(   p_sellafacctno varchar2, --- so tieu khoan dang ky ban.
                                p_symbol    VARCHAR2,  ---- ma chung khoan.
                                p_quantity varchar2,   ---- so luong dang ky ban.
                                p_quoteprice varchar2, ---- gia dang ky ban.
                                p_err_code  OUT varchar2,
                                p_err_message out varchar2
    ) --- dang ky ban chung khoan lo le.
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_count number;
      --
      l_symbol varchar2(10);
      l_buyafacctno VARCHAR2(10);
      l_sellafacctno varchar2(10);
      l_quantity number(20,4);
      l_quoteprice number(20,4);
      --
      v_sellCustodycd varchar2(20);
      v_buyCustodycd varchar2(20);
      v_sellFullname varchar2(200);
      v_sellAddress varchar2(200);
      v_sellLicense varchar2(100);
      v_volumeQtty number(20,4); --So du CK lo le tren so luu ky.
      v_tkQtty number(20,4); --So du CK lo le tren tieu khoan.
      v_sellSEACCTNO varchar2(30);
      v_buySEACCTNO varchar2(30);
      v_amount number(20,4);
      v_feetype varchar2(20);
      v_feeamt number(20,4);
      v_parValue number(20,4);
      v_iscorebank number;
      v_tradelot number;
      v_taxRate number(20,4);
      v_taxAmt number(20,4);
      v_codeid varchar2(20);
      v_desc varchar2(200);
      v_basicPrice number(20,4);
      v_floorPrice number(20,4);
      v_iddate varchar2(20);
      v_idplace varchar2(100);
      v_vat varchar2(1);
      v_issfullname varchar2(500);
      L_TRADEPLACE  VARCHAR2(10);
      L_ODDPRICETYPE    VARCHAR2(10);
      v_PITQTTY number;
      v_PITAMT number;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_Tradelot_Retail');
    v_buyCustodycd := systemnums.C_DEALINGCUSTODYCD;

    l_symbol := UPPER(p_symbol);
    l_sellafacctno := p_sellafacctno;
    l_quantity := to_number(p_quantity);
    l_quoteprice := to_number(p_quoteprice);

    --Lay dien giai giao dich
    SELECT TLTX.EN_TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '8878';
    --Lay thong tin tai khoan mua chung khoan lo le:
   -- SELECT VALUE  INTO l_buyafacctno
    --    FROM VW_CUSTODYCD_SUBACCOUNT WHERE FILTERCD = v_buyCustodycd and rownum = 1 order by value;
      l_buyafacctno:='0001540677';
    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Tradelot_Retail');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    --Lay thong tin tai khoan ban chung khoan lo le:
    SELECT C.CUSTODYCD, C.FULLNAME, C.ADDRESS, C.IDCODE,
           CASE WHEN MST.COREBANK = 'Y' THEN 1 ELSE 0 END ISCOREBANK, C.idplace, C.iddate, c.VAT
          INTO v_sellCustodycd, v_sellFullname, v_sellAddress, v_sellLicense, v_iscorebank, v_idplace, v_iddate,v_vat
        FROM AFMAST A, CFMAST C, CIMAST MST
          WHERE A.CUSTID = C.CUSTID AND A.ACCTNO = MST.AFACCTNO
                AND A.ACCTNO = l_sellafacctno;
    --Lay thong tin ma chung khoan
    SELECT SEC.codeid, SEC.PARVALUE, SEINFO.BASICPRICE PRICE, SEINFO.TRADELOT,SEINFO.FLOORPRICE, iss.fullname, SEC.tradeplace
         INTO v_codeid, v_parValue, v_basicPrice, v_tradelot, v_floorPrice, v_issfullname, L_TRADEPLACE
        FROM SBSECURITIES SEC, SECURITIES_INFO SEINFO, ISSUERS  ISS
            WHERE SEC.CODEID=SEINFO.CODEID and sec.SECTYPE <>'004'
                and SEC.ISSUERID = ISS.ISSUERID
                  AND SEC.SYMBOL = l_symbol;

    v_buySEACCTNO := trim(l_buyafacctno) || trim(v_codeid);
    v_sellSEACCTNO := trim(l_sellafacctno) || trim(v_codeid);
    --Tinh so chung khoan lo le con tren so luu ky
    v_volumeQtty := fn_GetCKLL(v_sellCustodycd, v_codeid);

      L_ODDPRICETYPE := '001';

    --Tinh so chung khoan lo le tren tieu khoan
    v_tkQtty := fn_GetCKLL_AF(l_sellafacctno, v_codeid);

    ----
    --IF v_volumeQtty <> v_tkQtty
    -- THEN
     --   p_err_code := '-201184';
    --    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      --  plog.error(pkgctx, 'Error:'  || p_err_message);
     --   plog.setendsection(pkgctx, 'pr_Tradelot_Retail');
      --  return;
    --END IF;

   --IF l_quantity > v_tkQtty --OR l_quantity > v_volumeQtty
   --  THEN
   --     p_err_code := '-900017';
   --     p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
   --     plog.error(pkgctx, 'Error:'  || p_err_message);
    --    plog.setendsection(pkgctx, 'pr_Tradelot_Retail');
    --    return;
   -- END IF;

    v_amount := l_quantity * l_quoteprice;
    v_feetype := '00009'; --dang mac dinh ma bieu phi cho giao dich 8878 la 00009
    v_feeamt := fn_cal_fee_amt(v_amount,v_feetype);

    v_taxRate := 0;
    IF v_vat = 'Y' THEN
       SELECT VARVALUE INTO v_taxRate FROM SYSVAR WHERE VARNAME = 'ADVSELLDUTY';
    END IF;
    v_taxAmt := round(v_amount * v_taxRate/100,5);
    v_PITQTTY   := fn_GetCKLL_CA_2(l_sellafacctno,v_codeid,l_quantity);
    v_PITAMT   := fn_gettaxamt_ca(l_sellafacctno,v_codeid,l_quantity,l_quoteprice);

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;

    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='8878';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;

     l_txmsg.brid        := substr(l_sellafacctno,1,4);

    --Set cac field giao dich
    --01 CODEID
    l_txmsg.txfields ('01').defname   := 'CODEID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := v_codeid;

    --88   CUSTODYCD     C
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE     := v_sellCustodycd;
    --02   AFACCTNO     C
    l_txmsg.txfields ('02').defname   := 'AFACCTNO';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := l_sellafacctno;
    --93   VOLUMEQTTY     C
    l_txmsg.txfields ('93').defname   := 'VOLUMEQTTY';
    l_txmsg.txfields ('93').TYPE      := 'N';
    l_txmsg.txfields ('93').VALUE     := v_volumeQtty;
    --94  TKQTTY
    l_txmsg.txfields ('94').defname   := 'TKQTTY';
    l_txmsg.txfields ('94').TYPE      := 'N';
    l_txmsg.txfields ('94').VALUE     := v_tkQtty;
    --90  CUSTNAME
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE     := v_sellFullname;
    --03  SEACCTNO
    l_txmsg.txfields ('03').defname   := 'SEACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := v_sellSEACCTNO;
    -- 91  ADDRESS
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE     := v_sellAddress;
    -- 89  CUSTODYCD
    l_txmsg.txfields ('89').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('89').TYPE      := 'C';
    l_txmsg.txfields ('89').VALUE     := v_buyCustodycd;
    --08 REFAFACCTNO
    l_txmsg.txfields ('08').defname   := 'REFAFACCTNO';
    l_txmsg.txfields ('08').TYPE      := 'C';
    l_txmsg.txfields ('08').VALUE     := l_buyafacctno;
    --92 LICENSE
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE     := v_sellLicense;

    --09 EXSEACCTNO
    l_txmsg.txfields ('09').defname   := 'EXSEACCTNO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     := v_buySEACCTNO;


    --11 QUOTEPRICE
    l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := l_quoteprice;

    --10 ORDERQTTY
    l_txmsg.txfields ('10').defname   := 'ORDERQTTY';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := l_quantity;

    --16 EXECAMT
    l_txmsg.txfields ('16').defname   := 'EXECAMT';
    l_txmsg.txfields ('16').TYPE      := 'N';
    l_txmsg.txfields ('16').VALUE     := l_quantity*l_quoteprice;
/*
    --60 AMT
    l_txmsg.txfields ('61').defname   := 'AMT';
    l_txmsg.txfields ('61').TYPE      := 'N';
    l_txmsg.txfields ('61').VALUE     := v_amount;
    --62 FEETYPE
    l_txmsg.txfields ('62').defname   := 'FEETYPE';
    l_txmsg.txfields ('62').TYPE      := 'C';
    l_txmsg.txfields ('62').VALUE     := v_feetype;
*/
    --12 PARVALUE
    l_txmsg.txfields ('12').defname   := 'PARVALUE';
    l_txmsg.txfields ('12').TYPE      := 'C';
    l_txmsg.txfields ('12').VALUE     := v_parValue;

    --60 ISCOREBANK
    l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
    l_txmsg.txfields ('60').TYPE      := 'C';
    l_txmsg.txfields ('60').VALUE     := v_iscorebank;

    --13 TRADELOT
    l_txmsg.txfields ('13').defname   := 'TRADELOT';
    l_txmsg.txfields ('13').TYPE      := 'N';
    l_txmsg.txfields ('13').VALUE     := v_tradelot;

    --22 FEEAMT
    l_txmsg.txfields ('22').defname   := 'FEEAMT';
    l_txmsg.txfields ('22').TYPE      := 'N';
    l_txmsg.txfields ('22').VALUE     := v_feeamt;

    --25 TEMP
    l_txmsg.txfields ('25').defname   := 'TEMP';
    l_txmsg.txfields ('25').TYPE      := 'N';
    l_txmsg.txfields ('25').VALUE     := 100;

    --14 TAXRATE
    l_txmsg.txfields ('14').defname   := 'TAXRATE';
    l_txmsg.txfields ('14').TYPE      := 'N';
    l_txmsg.txfields ('14').VALUE     := v_taxRate;

    --15 TAXAMT
    l_txmsg.txfields ('15').defname   := 'TAXAMT';
    l_txmsg.txfields ('15').TYPE      := 'N';
    l_txmsg.txfields ('15').VALUE     := v_taxAmt;

       --17 FLOORPRICE
    l_txmsg.txfields ('17').defname   := 'QUOTEPRICE';
    l_txmsg.txfields ('17').TYPE      := 'N';
    l_txmsg.txfields ('17').VALUE     := v_floorPrice;



    --73 IDDATE
    l_txmsg.txfields ('73').defname   := 'IDDATE';
    l_txmsg.txfields ('73').TYPE      := 'C';
    l_txmsg.txfields ('73').VALUE     := v_iddate;


    --74 IDPLACE
    l_txmsg.txfields ('74').defname   := 'IDPLACE';
    l_txmsg.txfields ('74').TYPE      := 'C';
    l_txmsg.txfields ('74').VALUE     := v_idplace;

     --75 SECURITIESNAME
    l_txmsg.txfields ('75').defname   := 'SECURITIESNAME';
    l_txmsg.txfields ('75').TYPE      := 'C';
    l_txmsg.txfields ('75').VALUE     := v_issfullname;
    --99 SYMBOL
    l_txmsg.txfields ('99').defname   := 'SYMBOL';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE     := l_symbol;
    --51    TRADEPLACE
    l_txmsg.txfields ('51').defname   := 'TRADEPLACE';
    l_txmsg.txfields ('51').TYPE      := 'C';
    l_txmsg.txfields ('51').VALUE     := L_TRADEPLACE;
    --52    PRICETYPE
    l_txmsg.txfields ('52').defname   := 'PRICETYPE';
    l_txmsg.txfields ('52').TYPE      := 'C';
    l_txmsg.txfields ('52').VALUE     := L_ODDPRICETYPE;
    --53    RATE
    l_txmsg.txfields ('53').defname   := 'RATE';
    l_txmsg.txfields ('53').TYPE      := 'N';
    l_txmsg.txfields ('53').VALUE     := 0;
    --18    PITQTTY
    l_txmsg.txfields ('18').defname   := 'PITQTTY';
    l_txmsg.txfields ('18').TYPE      := 'N';
    l_txmsg.txfields ('18').VALUE     := v_PITQTTY;
    --19    PITAMT
    l_txmsg.txfields ('19').defname   := 'PITAMT';
    l_txmsg.txfields ('19').TYPE      := 'N';
    l_txmsg.txfields ('19').VALUE     := v_PITAMT;
     --23
    l_txmsg.txfields ('23').defname   := 'TAMT';
    l_txmsg.txfields ('23').TYPE      := 'N';
    l_txmsg.txfields ('23').VALUE     := fn_get_semast_avl_withdraw(l_sellafacctno,v_codeid);

    --30 DESC
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := v_desc;


    BEGIN
        IF txpks_#8878.fn_autotxprocess (l_txmsg, p_err_code, l_err_param) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,'got error 8878: ' || p_err_code );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_Tradelot_Retail');
           RETURN;
        END IF;
    END;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_Tradelot_Retail');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_Tradelot_Retail');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_Tradelot_Retail');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Tradelot_Retail;

  PROCEDURE pr_Cancel_Tradelot_Retail(   p_sellafacctno varchar2,
                                p_symbol    VARCHAR2,
                                p_txnum varchar2,
                                p_txdate varchar2,
                                p_err_code  OUT varchar2,
                                p_err_message out varchar2
                                ) ---Huy dang ky ban lo le
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_count number;
      --
      l_sellafacctno varchar2(10);
      l_symbol varchar2(20);
      v_codeid varchar2(10);
      v_sellseacctno varchar2(30);
      v_buyafacctno varchar2(10);
      v_buyseacctno varchar2(30);
      l_txdate DATE;
      l_txnum varchar2(20);
      v_quoteprice number(20,4);
      v_quantity number(20,4);
      v_parvalue number(20,4);
      v_desc varchar2(200);
      v_iscorebank number;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_Cancel_Tradelot_Retail');
    l_symbol := UPPER(p_symbol);
    l_sellafacctno := p_sellafacctno;
    l_txdate := TO_DATE(p_txdate,'dd/mm/rrrr');
    l_txnum := p_txnum;
    --Lay dien giai giao dich
    SELECT TLTX.EN_TXDESC INTO v_desc FROM TLTX WHERE TLTXCD = '8817';

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_Cancel_Tradelot_Retail');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    SELECT  B.ACCTNO, B.PRICE, B.QTTY, B.DESACCTNO,
            C.CODEID, C.PARVALUE, A2.AFACCTNO AFACCTNO2,
            CASE WHEN af.COREBANK = 'Y' THEN 1 ELSE 0 END ISCOREBANK
          INTO v_sellseacctno, v_quoteprice, v_quantity, v_buyseacctno,
               v_codeid, v_parvalue, v_buyafacctno, v_iscorebank
        FROM SEMAST A, SERETAIL B, SBSECURITIES C ,AFMAST AF , CFMAST CF ,ALLCODE A4,SEMAST A2
            WHERE A.ACCTNO = B.ACCTNO AND A.CODEID = C.CODEID
                  AND B.QTTY > 0 AND B.status ='N' AND AF.ACCTNO =A.AFACCTNO
                  AND AF.CUSTID =CF.CUSTID
                  AND A4.CDTYPE = 'SE' AND A4.CDNAME = 'TRADEPLACE'  AND A4.CDVAL = C.TRADEPLACE
                  AND A2.ACCTNO=B.DESACCTNO
                  AND A.AFACCTNO = l_sellafacctno
                  AND C.SYMBOL = l_symbol
                  AND B.TXDATE = l_txdate
                  AND B.TXNUM = l_txnum;

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='8817';

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;

     l_txmsg.brid        := substr(l_sellafacctno,1,4);

    --Set cac field giao dich
    --01 CODEID
    l_txmsg.txfields ('01').defname   := 'CODEID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := v_codeid;
    --02   AFACCTNO     C
    l_txmsg.txfields ('02').defname   := 'AFACCTNO';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := l_sellafacctno;
    --03   SEACCTNO     C
    l_txmsg.txfields ('03').defname   := 'SEACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := v_sellseacctno;
    --07   AFACCTNO2     C
    l_txmsg.txfields ('07').defname   := 'AFACCTNO2';
    l_txmsg.txfields ('07').TYPE      := 'N';
    l_txmsg.txfields ('07').VALUE     := v_buyafacctno;
    --09  DESACCTNO
    l_txmsg.txfields ('09').defname   := 'DESACCTNO';
    l_txmsg.txfields ('09').TYPE      := 'N';
    l_txmsg.txfields ('09').VALUE     := v_buyseacctno;
    --04  TXDATE
    l_txmsg.txfields ('04').defname   := 'TXDATE';
    l_txmsg.txfields ('04').TYPE      := 'D';
    l_txmsg.txfields ('04').VALUE     := l_txdate;
    --05  TXNUM
    l_txmsg.txfields ('05').defname   := 'TXNUM';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := l_txnum;
    -- 11  QUOTEPRICE
    l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := v_quoteprice;
    -- 10  ORDERQTTY
    l_txmsg.txfields ('10').defname   := 'ORDERQTTY';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := v_quantity;
    --12 PARVALUE
    l_txmsg.txfields ('12').defname   := 'PARVALUE';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := v_parvalue;
    --60 PARVALUE
    l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
    l_txmsg.txfields ('60').TYPE      := 'N';
    l_txmsg.txfields ('60').VALUE     := v_iscorebank;
    --14 TAX
    l_txmsg.txfields ('14').defname   := 'TAX';
    l_txmsg.txfields ('14').TYPE      := 'N';
    l_txmsg.txfields ('14').VALUE     := 0;

    --30 DESC
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := v_desc;


    BEGIN
        IF txpks_#8817.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 8817: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_Cancel_Tradelot_Retail');
           RETURN;
        END IF;
    END;
    p_err_code:='0';
    plog.setendsection(pkgctx, 'pr_Cancel_Tradelot_Retail');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_Cancel_Tradelot_Retail');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_Cancel_Tradelot_Retail');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_Cancel_Tradelot_Retail;

PROCEDURE pr_Allocate_AdvPayment(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2, pv_lngTOTALAMT IN NUMBER)
IS
    l_lngTotalamt NUMBER;
    v_avladvance   NUMBER;
    l_PROMOTIONRATE number(20,4);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_Allocate_AdvPayment');

    l_lngTotalamt := pv_lngTotalamt;

    SELECT MIN (FEERATE) into l_PROMOTIONRATE FROM (
    SELECT ADP.AFACCTNO, MST.FEERATE FROM ADPRMFEECF ADP , ADPRMFEEMST MST
    WHERE GETCURRDATE BETWEEN ADP.VALDATE AND ADP.EXPDATE AND ADP.STATUS = 'A'
        AND ADP.PROMOTIONID = MST.AUTOID AND ADP.AFACCTNO = PV_STRAFACCTNO

    );
    l_PROMOTIONRATE := nvl(l_PROMOTIONRATE,1000);

     BEGIN
        SELECT depoamt-paidamt INTO v_avladvance
            FROM (
                SELECT  sts.afacctno,SUM(sts.aamt) aamt,
                    LEAST(
                        GREATEST(SUM(FLOOR((sts.amt - exfeeamt)/(1+(sts.days*least(ADVRATE,l_PROMOTIONRATE)/100/360+sts.days*ADVBANKRATE/100/360)))),0),
                        GREATEST(SUM(FLOOR(sts.amt - exfeeamt)) - MAX (sts.ADVMINFEE) - MAX(sts.ADVMINFEEBANK),0)
                    ) depoamt, --Phi toi thieu theo 1 lan ung (1 lan ung co the ung cho nhieu ngay)
                    SUM(rightvat) rightvat,
                    MAX (sts.ADVMINFEE) ADVMINFEE,
                    MAX(CASE WHEN sy.varvalue='0' THEN 0 ELSE fn_getdealgrppaid(sts.afacctno) END) paidamt, autoadv
                FROM
                    v_advanceSchedule sts, --where AUTOADV='Y'
                    sysvar sy
                WHERE sy.grname = 'SYSTEM' and sy.varname ='HOSTATUS'

                GROUP BY sts.afacctno, autoadv
            ) WHERE afacctno = pv_strafacctno;
    EXCEPTION WHEN OTHERS THEN
        v_avladvance:=0;
    END ;

    l_lngTotalamt := LEAST(l_lngTotalamt,v_avladvance);

    SELECT MIN (FEERATE) into l_PROMOTIONRATE FROM (
    SELECT ADP.AFACCTNO, MST.FEERATE FROM ADPRMFEECF ADP , ADPRMFEEMST MST
    WHERE GETCURRDATE BETWEEN ADP.VALDATE AND ADP.EXPDATE AND ADP.STATUS = 'A'
        AND ADP.PROMOTIONID = MST.AUTOID AND ADP.AFACCTNO = PV_STRAFACCTNO
    );
    l_PROMOTIONRATE := nvl(l_PROMOTIONRATE,1000);

    OPEN p_REFCURSOR FOR
    SELECT   to_char(a.txdate, 'DD/MM/RRRR') txdate,
             to_char(a.cleardate,'DD/MM/RRRR') cleardate,
             GREATEST (
                 0,
                 LEAST (
                     a.avladvamt,
                       l_lngTotalamt
                     - SUM (a.avladvamt) OVER (ORDER BY days ASC, txdate Asc)
                     + a.avladvamt))
                 amt,
             a.aamt
      FROM   (  SELECT   ROWNUM rn,
                         sts.*,
                         adt.advminfee,
                         adt.advmaxfee,
                         adt.advrate,
                         FLOOR(sts.maxavlamt / (1 + (sts.days * adt.advrate /36000 + sts.days * advbankrate/36000))) avladvamt
                  FROM   vw_advanceschedule sts,
                         afmast af,
                         aftype aft,
                         adtype adt,
                         sysvar sys
                 WHERE   STS.ACCTNO = pv_strafacctno
                         AND af.acctno = sts.acctno
                         AND sts.isvsd = 'N'
                         AND sys.grname = 'SYSTEM'
                         AND sys.varname = 'CURRDATE'
                         AND af.actype = aft.actype
                         AND aft.adtype = adt.actype
              ORDER BY   days, txdate) a
    UNION
    SELECT  'FEE' txdate, NULL cleardate, LEAST(GREATEST(sum(feeamt), max(advminfee), max(advminfeebank)), max(advmaxfee)) amt, 0 aamt
    FROM (
            SELECT   to_char(a.txdate, 'DD/MM/RRRR') txdate,
             to_char(a.cleardate,'DD/MM/RRRR') cleardate,
             GREATEST (0,
                 LEAST (
                     a.maxavlamt,
                       l_lngTotalamt
                     - SUM (a.maxavlamt) OVER (ORDER BY days ASC, txdate asc)
                     + a.maxavlamt))
                 amt,
             a.aamt,
   /*          CEIL(GREATEST (0,
                       LEAST (
                           a.maxavlamt,
                             l_lngTotalamt
                           - SUM (a.maxavlamt) OVER (ORDER BY days ASC, txdate asc)
                           + a.maxavlamt))
                   * a.days
                   * (a.advrate + a.advbankrate)
                   / 36000)*/
                    CEIL(GREATEST (0,
                       LEAST (
                           a.maxavlamt/(1+ a.days*(least(a.advrate,l_PROMOTIONRATE) + a.advbankrate)/ 36000),
                             l_lngTotalamt
                           - SUM (a.maxavlamt/(1+ a.days*(least(a.advrate,l_PROMOTIONRATE) + a.advbankrate)/ 36000)) OVER (ORDER BY days ASC, txdate asc)
                           + a.maxavlamt/(1+ a.days*(least(a.advrate,l_PROMOTIONRATE) + a.advbankrate)/ 36000)))
                   * a.days
                   * (least(a.advrate,l_PROMOTIONRATE) + a.advbankrate)
                   / 36000)
                 feeamt,
                 a.advminfee,
                 a.advmaxfee,
                 a.advminfeebank
      FROM   (  SELECT   ROWNUM rn,
                         sts.*,
                         adt.advminfee,
                         adt.advmaxfee,
                         adt.advrate,
                         adt.advbankrate,
                         adt.advminfeebank
                  FROM   vw_advanceschedule sts,
                         afmast af,
                         aftype aft,
                         adtype adt,
                         sysvar sys
                 WHERE   STS.ACCTNO = pv_strafacctno
                         AND af.acctno = sts.acctno
                         AND sts.isvsd = 'N'
                         AND sys.grname = 'SYSTEM'
                         AND sys.varname = 'CURRDATE'
                         AND af.actype = aft.actype
                         AND aft.adtype = adt.actype
              ORDER BY   days, txdate) a
            );


    plog.setendsection (pkgctx, 'pr_Allocate_AdvPayment');
EXCEPTION
  WHEN OTHERS
   THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_Allocate_AdvPayment');
END pr_Allocate_AdvPayment;


PROCEDURE pr_GetInfo4Margin(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2)
IS
BEGIN
    plog.setbeginsection (pkgctx, 'pr_GetInfo4Magin');

    OPEN p_REFCURSOR FOR
        SELECT   schd.rlsdate,
                 ROUND(schd.nml + schd.ovd + schd.paid) rlsamt,
                 schd.overduedate,
                 schd.paid,
                 ROUND(schd.ovd + schd.nml) prinamt,
                 ROUND(schd.intnmlacr + schd.intovd + schd.intdue + schd.intovdprin + schd.feeintnmlacr + schd.feeintovdacr + schd.feeintnmlovd + schd.feeintdue) intamt,
                 schd.rate2 intrate,schd.autoid,schd.extimes,schd.exdays,
                 getprevdate(schd.overduedate,type.exdays) begindate,
               --  getbaldefovd(af.acctno) Baldefovd
                --  getbaldefovd_released_depofee(af.acctno) +
                --(case when schd.overduedate= getcurrdate
                --then schd.nml+schd.INTDUE+schd.FEEDUE else 0 end) +    schd.intnmlacr +   schd.fee
                --Baldefovd
                ci.balance + nvl(adv.avladvance,0) Baldefovd,
--20/06/2017 DieuNDA Begin: chinh sua MARGIN C47
                --getduedate(get_t_date(getcurrdate()+ TYPE.MAXEXDAYS- schd.exdays,1) ,'B','000',1) TODATE
                getduedate(get_t_date(getcurrdate()+ LEAST(TYPE.MAXEXDAYS- schd.exdays,type.PRINPERIOD),1) ,'B','000',1) TODATE
                --20/06/2017 DieuNDA End
          FROM   lnschd schd, lnmast mst,lntype type, afmast af, cimast ci,
                (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt, sum(rcvamt) rcvamt, sum(aamt) aamt
                from v_getAccountAvlAdvance
                  group by afacctno) adv
         WHERE   schd.acctno = mst.acctno
                 AND af.acctno=mst.trfacctno
                 AND mst.actype=type.actype
                 and ci.acctno = adv.afacctno(+)
                 AND mst.trfacctno = pv_strAFACCTNO
                 AND schd.reftype IN ('P','GP')
                 AND schd.ovd + schd.nml + ROUND(schd.intnmlacr + schd.intovd + schd.intdue + schd.intovdprin + schd.feeintnmlacr + schd.feeintovdacr + schd.feeintnmlovd + schd.feeintdue) >0
                 AND NVL(mst.ftype,'AF') = 'AF'
                 AND AF.ACCTNO=CI.ACCTNO;

    plog.setendsection (pkgctx, 'pr_GetInfo4Magin');
EXCEPTION
  WHEN OTHERS
   THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetInfo4Magin');
END pr_GetInfo4Margin;

FUNCTION fn_get_hose_time
RETURN VARCHAR2 as
    l_timeordersys  VARCHAR2(10);
    l_timesysdate   VARCHAR2(10);
    l_timemsg       VARCHAR2(10);
    l_hosetime      INTEGER;
    l_returntime    VARCHAR2(10);

BEGIN
    SELECT sysvalue INTO l_timeordersys FROM ordersys WHERE sysname = 'TIMESTAMP';
    SELECT NVL(TO_CHAR(MAX(msg_date),'HH24MISS'),'00:00:00') INTO l_timemsg FROM msgreceivetemp
    WHERE msgtype in ('SC','TS');
    SELECT TO_CHAR(systimestamp,'HH24MISS') INTO l_timesysdate FROM dual;

    IF l_timemsg = '00:00:00' THEN
        RETURN TO_CHAR(systimestamp,'HH24:MI:SS');
    END IF;

    SELECT TO_NUMBER(SUBSTR(l_timeordersys,1,2)) * 3600
                    + TO_NUMBER(SUBSTR(l_timeordersys,3,2)) * 60
                    + TO_NUMBER(SUBSTR(l_timeordersys,5,2))
                - (
                    TO_NUMBER(SUBSTR(l_timemsg,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timemsg,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timemsg,5,2))
                    )
                + (
                    TO_NUMBER(SUBSTR(l_timesysdate,1,2)) * 3600
                        + TO_NUMBER(SUBSTR(l_timesysdate,3,2)) * 60
                        + TO_NUMBER(SUBSTR(l_timesysdate,5,2))
                    )
           INTO l_hosetime FROM DUAL;

    SELECT TRIM(TO_CHAR(MOD(FLOOR(l_hosetime/3600),24),'09'))
                || ':' || TRIM(TO_CHAR(FLOOR(MOD(l_hosetime,3600)/60),'09'))
                || ':' || TRIM(TO_CHAR(MOD(MOD(l_hosetime,3600),60),'09'))
           INTO l_returntime FROM DUAL;
  RETURN l_returntime;
EXCEPTION
  WHEN OTHERS THEN
    RETURN errnums.C_SYSTEM_ERROR;
END fn_get_hose_time;

PROCEDURE pr_getAcountInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTODYCD    IN VARCHAR2
     )
is
     l_current_date date;

begin
    plog.setbeginsection(pkgctx, 'pr_getAcountInfo');

    select sbdate into l_current_date from sbcurrdate where numday = 0 and sbtype = 'N';

    OPEN p_REFCURSOR FOR
    select cf.custodycd, cfs.signature, cf.opndate, cfa.cfasignature, cfa.cfafullname,
        cfa.cfaidcode, cfa.cfaiddate, cfa.cfaidplace,re.rmname,re.rdname
    from cfmast cf
    left join
    (
        select cfa.cfcustid, cfa.valdate, cfa.expdate,
            decode(cfS.custid,null,cfa.signature,cfS.signature)  cfasignature,
            decode(cf2.custid,null,cfa.fullname,cf2.fullname) cfafullname,
            decode(cf2.custid,null,cfa.licenseno,cf2.idcode) cfaidcode,
            decode(cf2.custid,null,cfa.lniddate,cf2.iddate) cfaiddate,
            decode(cf2.custid,null,cfa.lnplace,cf2.idplace) cfaidplace
        from  cfauth cfa
        left join CFSIGN CFS
        on nvl(cfa.custid,'X') = CFS.custid
            and l_current_date between cfs.valdate and cfs.expdate
        left join cfmast cf2
        on nvl(cfa.custid,'X') = cf2.custid
        where cfa.deltd <> 'Y'
            and l_current_date between cfa.valdate and cfa.expdate
    ) cfa
    on cf.custid = cfa.cfcustid --and cf.opndate between cfa.valdate and cfa.expdate
    left join cfsign cfs
    on cf.custid = cfs.custid
        and l_current_date between cfs.valdate and cfs.expdate
   left join
    (
    select re.afacctno,
    max(case when retype.rerole ='RM' then  cf.fullname end) rmname,
    max(case when retype.rerole ='RD' then  cf.fullname end ) rdname
    from reaflnk re,retype, cfmast cf
    where SUBSTR(REACCTNO,11) = retype.actype
    and retype.rerole IN ('RD','RM')
    AND RE.STATUS ='A'
    and cf.custid = SUBSTR(REACCTNO,1,10)
    group by re.afacctno)re
    on cf.custid = re.afacctno
    where cf.custodycd = P_CUSTODYCD
    and rownum = 1;
    plog.setendsection(pkgctx, 'pr_getAcountInfo');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_getAcountInfo');
END pr_getAcountInfo;

PROCEDURE pr_ca_rightoff
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_SYMBOL    IN VARCHAR2, --- MA CK CHOT.
     P_FRDATE    IN VARCHAR2, --- LOC THEO NGAY DANG KY CUOI CUNG.
     P_TODATE    IN VARCHAR2,
     P_TELLERID  IN VARCHAR2 --- MA USER DANG NHAP.
     )
     /* fullname : TEN KHACH HANG
        custodycd : SO TK LUU KY
        afacctno : SO TIEU KHOAN
        SYMBOL_ORG : MA CK CHOT
        BUYQTTY : SO LUONG CK DA DANG KY MUA
        MAXQTTY : SO LUONG CK DANG KY TOI DA
        EXPRICE : GIA MUA
        AMT : SO TIEN PHAI THANH TOAN
        castatus : TRANG THAI QUYEN
     */
is
    L_SYMBOL  VARCHAR2(20);

begin
    plog.setbeginsection(pkgctx, 'pr_getAcountInfo');

    IF(P_SYMBOL IS NULL OR UPPER(P_SYMBOL) = 'ALL') THEN
        L_SYMBOL := '%';
    ELSE
        L_SYMBOL := UPPER(P_SYMBOL);
    END IF;

    OPEN p_REFCURSOR FOR
    select cf.fullname, cf.custodycd, af.acctno afacctno,
        sym_org.symbol SYMBOL_ORG, CA.QTTY BUYQTTY, CA.PQTTY + CA.QTTY MAXQTTY,
        CAMAST.EXPRICE EXPRICE, CA.QTTY*CAMAST.EXPRICE AMT, a1.cdcontent castatus
    FROM ALLCODE A1, CAMAST, CASCHD CA, AFMAST AF, CFMAST CF, sbsecurities SYM_ORG,
        (
            select DISTINCT afacctno, reu.tlid
            from reaflnk re, reuserlnk reu
            where re.frdate <= getcurrdate and re.todate >= getcurrdate
                and re.deltd <> 'Y' and re.status = 'A'
                AND RE.refrecflnkid = reu.refrecflnkid
                AND reu.tlid = P_TELLERID
        ) RE
    WHERE CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
        AND CAMAST.camastid  = CA.camastid AND CA.status <> 'Y'
        AND CA.DELTD <> 'Y' AND CAMAST.catype = '014'
        AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = CA.STATUS
        AND sym_org.codeid = camast.codeid and af.acctno = re.afacctno
        AND sym_org.symbol LIKE L_SYMBOL
        and camast.duedate >= to_date(P_FRDATE,'dd/mm/rrrr')
        and camast.duedate <= to_date(P_TODATE,'dd/mm/rrrr');
    plog.setendsection(pkgctx, 'pr_ca_rightoff');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_ca_rightoff');
END pr_ca_rightoff;

PROCEDURE Pr_Change_Pass_Online
    (   p_username varchar2,
        p_fullname varchar2,
        p_idcode varchar2,
        P_IDDATE        VARCHAR2 DEFAULT NULL,
        P_DATEOFBIRTH   VARCHAR2 DEFAULT NULL,
        P_MOBILESMS     VARCHAR2 DEFAULT NULL,
        p_err_code  OUT varchar2,
        p_err_message  OUT varchar2,
        --Log thong tin thiet bi
        p_ipaddress      in varchar2 default '', --vcb.2021.04.0.01
        p_via            in varchar2 default '',
        p_validationtype in varchar2 default '',
        p_devicetype     IN varchar2 default '',
        p_device         IN varchar2 default ''
        --End
    )
    IS
        l_txmsg       tx.msg_rectype;
        v_strCURRDATE varchar2(20);
        l_err_param   varchar2(300);
        l_custodycd   varchar2(20);
        l_fullname   varchar2(200);
        l_idcode      varchar2(20);
        l_custid      varchar2(20);
        l_loginpwd  varchar2(50);
        l_tradingpwd  varchar2(50);
        l_email       varchar2(50);
        l_tokenid     varchar2(50);
        l_ismaster     varchar2(50);
        l_authtype     varchar2(50);
        l_OrgDesc       varchar2(500);
        l_EN_OrgDesc       varchar2(500);
        l_otright          VARCHAR2(10);
        l_IDPLACE       varchar2(500);
        l_ADDRESS   varchar2(500);
        l_MOBILE    varchar2(20);
        l_IDDATE    varchar2(20);
        L_DATEOFBIRTH VARCHAR2(20);
        l_strcustodycd  varchar2(30);
        v_refcursor   pkg_report.ref_cursor;
        l_input       varchar2(2500);
    BEGIN

        plog.setbeginsection(pkgctx, 'Pr_Change_Pass_Online');
        plog.info(pkgctx,'Begin Pr_Change_Pass_Online : p_custodycd: [' || p_username
             || '].:p_fullname: [' || p_fullname
              || '].:p_idcode: [' || p_idcode||']');
        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
            return;
        END IF;
        -- End: Check host 1 active or inactive

        -- Check register service ---
        BEGIN
            SELECT ot.otright, cf.custodycd  INTO l_otright, l_strcustodycd
            FROM otrightdtl ot, cfmast cf
            WHERE ot.authcustid = cf.custid
            AND ot.cfcustid=ot.authcustid
            AND cf.username=upper(p_username)
            AND ot.via ='A'
            AND ot.deltd='N'
            AND ot.otmncode = 'RESETPASS';
         EXCEPTION WHEN  OTHERS THEN
                p_err_code := '-108';
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
              RETURN;
        END;
        IF l_otright <> 'YYYYYNYNN' OR l_otright IS NULL
          THEN p_err_code := '-108';
          p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
          plog.error(pkgctx, 'Error:'  || p_err_message);
          plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
          RETURN;
        END IF;
        -- End: Check register service ---

    SELECT TXDESC,EN_TXDESC into l_OrgDesc, l_EN_OrgDesc FROM  TLTX WHERE TLTXCD='0090';

        SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='0090';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;




          --LAY THONG TIN KHACH HANG
        BEGIN
        SELECT cf.custid,cf.idcode,nmpks_ems.fn_convert_to_vn(cf.fullname) fullname,cf.email,
            nvl(usl.tokenid,'') tokenid, nvl(usl.ismaster,'N') ismaster, nvl(usl.authtype,'4') authtype, IDPLACE,
            ADDRESS, nvl(MOBILESMS,'X'), IDDATE, DATEOFBIRTH
        INTO l_custid, l_idcode,l_fullname,l_email,l_tokenid,l_ismaster,l_authtype, l_IDPLACE, l_ADDRESS, l_MOBILE, l_IDDATE, L_DATEOFBIRTH
        FROM CFMAST CF, userlogin usl
        WHERE CF.custodycd = l_strcustodycd
        AND usl.status='A'
        AND cf.username=usl.username(+);
          EXCEPTION
         WHEN OTHERS
         THEN
             p_err_code      := -201224;
            p_err_message   :=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx,'Pr_Change_Pass_Online :p_custodycd: [' || p_username
             || '].:p_fullname: [' || p_fullname
              || '].:p_idcode: [' || p_idcode||'] p_err_code: ' || p_err_code || ' .:p_err_message ' || p_err_message
              ||'SQLERR: '|| SQLERRM);
            plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
       RETURN;
      END ;

        l_txmsg.brid        := substr(l_custid,1,4);
        l_LOGINPWD:=  cspks_system.fn_passwordgenerator('10');
        l_tradingpwd:=  cspks_system.fn_passwordgenerator('10');
        l_custodycd :=l_strcustodycd;



        /*IF upper( l_fullname ) <> upper( p_fullname) or l_idcode <> p_idcode THEN
            p_err_code      := -201222;
            p_err_message   :=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx,'Pr_Change_Pass_Online :p_custodycd: ' || p_username
             || '.:p_fullname: ' || p_fullname
              || '.:p_idcode: ' || p_idcode||' p_err_code: ' || p_err_code || ' ' || p_err_message );
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
            RETURN;
        END IF;*/

        /*
        l_IDDATE, L_DATEOFBIRTH
        P_IDDATE        VARCHAR2 DEFAULT NULL,
        P_DATEOFBIRTH   VARCHAR2 DEFAULT NULL,
        */
        IF TO_DATE( nvl(l_IDDATE,'01/01/1900'),systemnums.c_date_format ) <> TO_DATE(nvl(P_IDDATE,'01/01/1901'),systemnums.c_date_format)
            or TO_DATE(nvl(L_DATEOFBIRTH,'01/01/1900'),systemnums.c_date_format ) <> TO_DATE(nvl(P_DATEOFBIRTH,'01/01/1901'),systemnums.c_date_format)
            OR trim(nvl(L_MOBILE,'X')) <> trim(nvl(P_MOBILESMS,'XY')) OR upper( trim(nvl(l_fullname,'X' ))) <> upper(trim( nvl(p_fullname,'XY'))) or trim(nvl(l_idcode,'X')) <> trim(nvl(p_idcode,'XY'))
            THEN
            p_err_code      := -201224;
            p_err_message   :=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx,'Pr_Change_Pass_Online :p_custodycd: ' || p_username
             || '.:P_DATEOFBIRTH: ' || P_DATEOFBIRTH
              || '.:P_IDDATE: ' || P_IDDATE||' p_err_code: ' || p_err_code || ' ' || p_err_message );
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
            RETURN;
        END IF;

        --03   CUSTID      C
        l_txmsg.txfields ('03').defname   := 'CUSTID';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := to_char(nvl(l_custid,''));
        --88   CUSTODYCD      C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := l_custodycd;
        --05   USERNAME      C
        l_txmsg.txfields ('05').defname   := 'USERNAME';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := upper(p_username);
        --10   LOGINPWD        C
        l_txmsg.txfields ('10').defname   := 'LOGINPWD';
        l_txmsg.txfields ('10').TYPE      := 'C';
        l_txmsg.txfields ('10').VALUE     := l_LOGINPWD;
        --14   ISMASTER      C
        l_txmsg.txfields ('14').defname   := 'ISMASTER';
        l_txmsg.txfields ('14').TYPE      := 'C';
        l_txmsg.txfields ('14').VALUE     := l_ismaster;
        --12   TRADINGPWD      C
        l_txmsg.txfields ('12').defname   := 'TRADINGPWD';
        l_txmsg.txfields ('12').TYPE      := 'C';
        l_txmsg.txfields ('12').VALUE     := l_TRADINGPWD;
         --13   DAYS      N
        l_txmsg.txfields ('13').defname   := 'DAYS';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := 30;
         --06   EMAIL     C
        l_txmsg.txfields ('06').defname   := 'EMAIL';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := l_EMAIL;

        --11   AUTHTYPE   C
        l_txmsg.txfields ('11').defname   := 'AUTHTYPE';
        l_txmsg.txfields ('11').TYPE      := 'C';
        l_txmsg.txfields ('11').VALUE     := l_AUTHTYPE ;

        --15   TOKENID   C
        l_txmsg.txfields ('15').defname   := 'TOKENID';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := l_TOKENID;

        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := l_OrgDesc ;

        --20   FULLNAME    C
        l_txmsg.txfields ('20').defname   := 'FULLNAME';
        l_txmsg.txfields ('20').TYPE      := 'C';
        l_txmsg.txfields ('20').VALUE     := l_fullname ;

        --21   IDCODE    C
        l_txmsg.txfields ('21').defname   := 'IDCODE';
        l_txmsg.txfields ('21').TYPE      := 'C';
        l_txmsg.txfields ('21').VALUE     := l_idcode ;

        --22   IDPLACE    C
        l_txmsg.txfields ('22').defname   := 'IDPLACE';
        l_txmsg.txfields ('22').TYPE      := 'C';
        l_txmsg.txfields ('22').VALUE     := l_IDPLACE ;

        --23   ADDRESS    C
        l_txmsg.txfields ('23').defname   := 'ADDRESS';
        l_txmsg.txfields ('23').TYPE      := 'C';
        l_txmsg.txfields ('23').VALUE     := l_ADDRESS ;

        --24   MOBILE    C
        l_txmsg.txfields ('24').defname   := 'MOBILE';
        l_txmsg.txfields ('24').TYPE      := 'C';
        l_txmsg.txfields ('24').VALUE     := l_MOBILE ;

        --25   IDDATE    C
        l_txmsg.txfields ('25').defname   := 'IDDATE';
        l_txmsg.txfields ('25').TYPE      := 'C';
        l_txmsg.txfields ('25').VALUE     := l_IDDATE ;
 /*
20  FULLNAME    C   H? v??kh? h?
21  IDCODE      C   M?i?y t?      l_idcode
22  IDPLACE     C   Noi c?p           l_IDPLACE
23  ADDRESS     C   ?a ch?             l_ADDRESS
24  MOBILE      C   S? di?n tho?i       l_MOBILE
25  IDDATE      C   Ng?c?p    l_IDDATE
*/

    BEGIN
        IF txpks_#0090.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 0090: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:p_custodycd: ' || p_username
             || '.:p_fullname: ' || p_fullname
              || '.:p_idcode: ' || p_idcode||' p_err_code: '|| p_err_code||' p_err_message: '|| p_err_message);
           plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
           RETURN;
        END IF;
    END;

    --Log thong tin thiet bi
    OPEN v_refcursor FOR
    SELECT p_username username, p_idcode idcode,P_MOBILESMS MOBILESMS,
           p_ipaddress ipaddress, p_via via, p_validationtype validationtype,
           p_devicetype devicetype, p_device device
      FROM DUAL;
    l_input := FN_GETINPUT(v_refcursor);

    pr_insertiplog( l_txmsg.txnum,  getcurrdate, p_ipaddress, p_via, p_validationtype, p_devicetype, p_device, 'DElREGONLSERVICE',l_input);
    --End

    p_err_code:=0;
    plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,'got error on Pr_Change_Pass_Online');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'Pr_Change_Pass_Online');
      RAISE errnums.E_SYSTEM_ERROR;
  END Pr_Change_Pass_Online;

--pr_GetCash4t3:  Thieu tien tai khoan T3
PROCEDURE pr_GetCash4t3(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2)
IS
BEGIN
    plog.setbeginsection(pkgctx, 'pr_GetCash4t3');
    OPEN p_REFCURSOR FOR
        select A.*,securedT0 + securedT1 + securedT2 + securedT3 + securedOver -balance addtotransfer
        from (
        select cf.custodycd, max(cf.fullname) fullname, af.acctno afacctno, max(aft.actype) actype, max(aft.typename) typename,
            sum(case when od.txdate = to_date(sys.varvalue,'DD/MM/RRRR')
                        then case when od.feeacr > 0 then  od.matchamt + (od.remainqtty*od.quoteprice) + od.feeacr
                                  else (od.matchamt + (od.remainqtty*od.quoteprice)) * (od.bratio / 100)
                             end
                     else 0 end) securedT0,
            sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-1 and sbtype ='B')
                     then od.matchamt + od.feeacr
                     else 0 end) securedT1,
            sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-2 and sbtype ='B')
                     then od.matchamt + od.feeacr
                     else 0 end) securedT2,
            sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')
                     then od.matchamt + od.feeacr
                     else 0 end) securedT3,
            nvl(max(ln.odamt),0) securedOver,
            sum(case when od.txdate = to_date(sys.varvalue,'DD/MM/RRRR')
                        then case when od.feeacr > 0
                                    then od.matchamt + (od.remainqtty*od.quoteprice) + od.feeacr
                                    else (od.matchamt + (od.remainqtty*od.quoteprice)) * (od.bratio / 100)
                             end
                        else od.matchamt + od.feeacr
                end) + nvl(max(ln.odamt),0)  totalsecured,
            max(af.mrcrlimitmax) mrcrlimitmax,
            nvl(max(sec.seass),0) seass,
            max(ci.balance + nvl(sec.avladvance,0)) balance,
            nvl(max(sec.marginrate),0) marginrate,
            sum(case when od.txdate= (select sbdate from sbcurrdate where numday =-3 and sbtype ='B')
                     then od.matchamt + od.feeacr
                     else 0 end) + nvl(max(ln.odamt),0) addamount
        from cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt, sysvar sys,
                (select od.afacctno, od.txdate, nvl(sts.cleardate,fn_get_nextdate(od.txdate, aft.trfbuyext) ) cleardate,
                        od.matchamt, sts.amt, od.remainqtty, od.quoteprice, od.feeacr, od.bratio
                    from afmast af, aftype aft, odmast od,
                        (select sts.orgorderid, sts.afacctno, sts.txdate, sts.cleardate, sts.amt
                            from stschd sts
                            where duetype = 'SM' and sts.deltd <> 'Y') sts
                    where af.acctno = od.afacctno
                          and af.actype = aft.actype
                          and od.orderid = sts.orgorderid(+)
                          and od.exectype in ('NB')
                          and af.acctno = pv_strAFACCTNO
                ) od,
            (select trfacctno, sum(oprinnml+oprinovd) odamt from lnmast where ftype = 'AF' group by trfacctno) ln,
             v_getsecmarginratio sec
        where     af.acctno = pv_strAFACCTNO and cf.custid = af.custid
              and af.acctno = ci.acctno and af.actype = aft.actype
              and aft.mrtype = mrt.actype and af.acctno = od.afacctno(+)
              and sys.varname = 'CURRDATE' and sys.grname = 'SYSTEM'
              and af.acctno = ln.trfacctno(+) and af.acctno = sec.afacctno(+)
              and (aft.istrfbuy = 'Y'
                        and mrt.mrtype = 'T'
                        and nvl(od.txdate,to_date(sys.varvalue,'DD/MM/RRRR')) = to_date(sys.varvalue,'DD/MM/RRRR')
                    or od.txdate <> od.cleardate)
        group by cf.custodycd, af.acctno
        having sum(case when od.txdate = to_date(sys.varvalue,'DD/MM/RRRR')
                    then case when od.feeacr > 0
                                 then od.matchamt + (od.remainqtty*od.quoteprice) + od.feeacr
                                 else (od.matchamt + (od.remainqtty*od.quoteprice)) * (1 + od.bratio / 100)
                            end
                    else od.matchamt + od.feeacr end) + nvl(max(ln.odamt),0) > 0
        ) A where 0=0;
    plog.setendsection(pkgctx, 'pr_GetCash4t3');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetCash4t3');
END pr_GetCash4t3;

PROCEDURE pr_GetSecbasket(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strBASKETID IN VARCHAR2)
IS
    l_strBASKETID varchar(20);
BEGIN
    if (pv_strBASKETID is null or upper(pv_strBASKETID) = 'ALL') then
        l_strBASKETID := '%';
    else
        l_strBASKETID := pv_strBASKETID;
    end if;
    plog.setbeginsection(pkgctx, 'pr_GetSecbasket');
    OPEN p_REFCURSOR FOR
    /*select seb.basketid, seb.symbol, seb.mrratiorate, (100-nvl(seb.MRRATIOLOAN,100)) MRRATIOLOAN,
        seb.mrpricerate, seb.mrpriceloan
    from secbasket seb
    where seb.basketid like l_strBASKETID;
    */
    select seb.basketid, seb.symbol, seb.mrratiorate, seb.MRRATIOLOAN MRRATIOLOAN,
        least(sb.basicprice,sb.marginprice,seb.mrpricerate,sec.mrpricerate) mrpricerate,
        LEAST(sec.mrpriceloan,seb.mrpriceloan,sb.basicprice,sb.marginprice) mrpriceloan,
        iss.fullname issfullname, nvl(sec.mrmaxqtty,0) mrmaxqtty,
        seb.MRMAXQTTY-fn_getroomusedbybasket(sb.codeid, seb.basketid) REMAINMRMAXQTTY
    from secbasket seb, securities_info sb, issuers iss, securities_risk sec
    where seb.basketid like l_strBASKETID
    and seb.symbol = sb.symbol and sb.symbol = iss.shortname(+)
        and sb.codeid = sec.codeid(+)
        and sb.basicprice > 0 and seb.mrpriceloan > 0
        and (seb.mrratiorate <> 0 or seb.MRRATIOLOAN <> 0)
        ;

    plog.setendsection(pkgctx, 'pr_GetSecbasket');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetSecbasket');
END pr_GetSecbasket;


PROCEDURE pr_GetSecbasket_AF(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strAFACCTNO IN VARCHAR2)
IS
    l_strAFACCTNO varchar(20);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_GetSecbasket_AF');
    if (pv_strAFACCTNO is null or upper(pv_strAFACCTNO) = 'ALL') then
        l_strAFACCTNO := '%';
    else
        l_strAFACCTNO := pv_strAFACCTNO;
    end if;
    OPEN p_REFCURSOR FOR
    select DISTINCT BA.basketid, BA.basketname
    from lnsebasket LNS, aftype aft, AFMAST AF, basket BA
    where lns.actype = aft.lntype
        AND LNS.basketid = BA.basketid
        and af.actype = aft.actype AND AF.ACCTNO like l_strAFACCTNO;

    plog.setendsection(pkgctx, 'pr_GetSecbasket_AF');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetSecbasket_AF');
END pr_GetSecbasket_AF;

PROCEDURE pr_getAFAcountInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_AFACCTNO  IN VARCHAR2
     )
IS
    l_strAFACCTNO varchar(20);
BEGIN
    plog.setbeginsection(pkgctx, 'pr_getAFAcountInfo');
    l_strAFACCTNO := P_AFACCTNO;

    /*OPEN p_REFCURSOR FOR
    SELECT CF.custid, CF.custodycd, CF.fullname, af.acctno, cf.dateofbirth, cf.idcode, cf.iddate, cf.idplace,
        cf.sex sex, cf.address, cf.mobilesms mobile1, cf.mobile mobile2, cf.email,
        af.mrcrlimitmax, null passlogin, af.corebank, af.bankacctno,a1.cdcontent OTAUTHTYPE, cf.tradetelephone, cf.tradeonline
    FROM CFMAST CF, AFMAST AF, userlogin us, allcode a1
    WHERE CF.CUSTID = AF.custid and cf.custodycd = us.username and us.status = 'A'
        and a1.cdtype = 'CF' and a1.cdname = 'OTAUTHTYPE' and us.authtype = a1.cdval
        and AF.ACCTNO like l_strAFACCTNO;*/
    OPEN p_REFCURSOR FOR
    SELECT CF.custid, CF.custodycd, CF.fullname, af.acctno, cf.dateofbirth, cf.idcode, cf.iddate, cf.idplace,
        AL.cdcontent sex, AL.en_cdcontent sex_en,cf.address, cf.mobilesms mobile1, cf.mobile mobile2, cf.email,
        af.mrcrlimitmax, null passlogin, case when af.bankacctno is not null then 'Y' else 'N' end corebank , af.bankacctno,us.cdcontent OTAUTHTYPE, cf.tradetelephone, cf.tradeonline,
        re.rmname,re.rdname, us.en_cdcontent OTAUTHTYPE_EN,AF.autotrf
    FROM CFMAST CF, AFMAST AF,
        (select us.username, a1.cdcontent , a1.en_cdcontent from userlogin us, allcode a1
            where  a1.cdtype = 'CF' and a1.cdname = 'OTAUTHTYPE' and us.authtype = a1.cdval
            and us.status = 'A')us,
              ( select re.afacctno,
                max(case when retype.rerole ='CS' then  cf.fullname end) rmname,
                max(case when retype.rerole ='RD' then  cf.fullname end ) rdname
                from reaflnk re,retype, cfmast cf
                where SUBSTR(REACCTNO,11) = retype.actype
                and retype.rerole = 'CS' --IN ('RD','RM')
                AND RE.STATUS ='A'
                and cf.custid = SUBSTR(REACCTNO,1,10)
                group by re.afacctno)re, allcode al
        WHERE CF.CUSTID = AF.custid and cf.custodycd = us.username(+)
        and CF.CUSTID = re.afacctno(+)
        and AF.ACCTNO like l_strAFACCTNO
        and cf.sex = al.cdval
        and al.cdname ='SEX'
        and al.cdtype ='CF';

    plog.setendsection(pkgctx, 'pr_getAFAcountInfo');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_getAFAcountInfo');
END pr_getAFAcountInfo;
PROCEDURE pr_GetRegisterOnlineServices
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     P_CUSTID       IN  VARCHAR2
     )
    IS
    L_STRLINKREGISTER VARCHAR2(300);
BEGIN

    BEGIN
    select VARVALUE INTO L_STRLINKREGISTER from sysvar where grname = 'SYSTEM' AND VARNAME = 'LINKREGISTER';
    EXCEPTION WHEN OTHERS THEN
        L_STRLINKREGISTER := 'http://abc.com';
    END;

     OPEN p_REFCURSOR FOR
        SELECT A0.CDVAL OTFUNCID,A0.CDCONTENT OTFUNCDES,
               (CASE WHEN NVL(DTL.CFCUSTID,'A')='A' THEN 'N' ELSE 'Y' END) ISREGIS,
               L_STRLINKREGISTER LINK
        FROM ALLCODE A0,
            (SELECT DTL.CFCUSTID,DTL.OTMNCODE,DTL.OTRIGHT
            FROM OTRIGHTDTL DTL, ALLCODE A
            WHERE CFCUSTID=P_CUSTID AND DTL.AUTHCUSTID=DTL.CFCUSTID
            AND A.Cdtype='SA' AND A.CDNAME='OTFUNC' AND A.Cduser='Y' AND A.Cdval=DTL.OTMNCODE
            AND DTL.DELTD <> 'Y' AND DTL.OTRIGHT NOt LIKE  'NNNN%' and dtl.via='A') --Ngay 10/09/2018 NamTv them kenh
            DTL
        WHERE  A0.CDTYPE='SA' AND A0.CDNAME='OTFUNC' AND A0.CDUSER='Y'
        AND A0.CDVAL=DTL.OTMNCODE(+)    ;
EXCEPTION
WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetRegisterOnlineServices');
END pr_GetRegisterOnlineServices;

PROCEDURE pr_GetOTFUNCService
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR
     )
    IS
    L_STRLINKREGISTER VARCHAR2(300);
BEGIN

     OPEN p_REFCURSOR FOR
        SELECT  a1.lstodr STT, A1.cdval OTFUNCID, a1.en_cdcontent EN_function_name, a1.cdcontent function_name, a2.cdcontent "file_name", 'pdf' file_type
        FROM allcode a1, allcode a2
        --WHERE a1.cdname = 'VCBSOTFUNC' AND a2.cdname = 'VCBSOTFUNCLINK'
        WHERE a1.cdname = 'BMSCOTFUNC' AND a2.cdname = 'BMSCOTFUNCLINK' --11/2016 TOANNDS EDIT
        AND a1.cdval = a2.cdval
        ORDER BY a1.lstodr;

EXCEPTION
WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetOTFUNCService');
END pr_GetOTFUNCService;

PROCEDURE pr_RegisterOnlineServices
    (P_CUSTID       IN  VARCHAR2,
     P_OTFUNCID     IN  VARCHAR2,
     P_ISREGIS      IN   VARCHAR2,
     P_via          IN  VARCHAR2,--Ngay 04/09/2018 NamTv them chinh sua chu ky so
     p_err_code out varchar2,
     p_err_message out VARCHAR2
     )
IS
L_COUNT NUMBER(5);
L_AUTOID NUMBER(20);
BEGIN
    p_err_code:=0;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    BEGIN
        SELECT AUTOID INTO L_AUTOID
        FROM OTRIGHTDTL
        WHERE CFCUSTID=AUTHCUSTID
        AND DELTD <> 'Y' AND OTMNCODE=P_OTFUNCID AND VIA=P_via --Ngay 04/09/2018 NamTv them chinh sua chu ky so
        AND CFCUSTID=P_CUSTID;
    EXCEPTION WHEN OTHERS THEN
        L_AUTOID:=0;
    END ;
    IF P_ISREGIS='Y' AND L_AUTOID <> 0 THEN -- cap nhat vao dong da DK
        UPDATE OTRIGHTDTL SET OTRIGHT='YYYYYNYNN' WHERE AUTOID=L_AUTOID AND VIA=P_via; --Ngay 27/03/2020 NamTv them chinh sua OTP;
/*        IF P_OTFUNCID = 'CASHTRANS' THEN
           UPDATE OTRIGHTDTL SET OTRIGHT='YYYYNYYNN' WHERE AUTOID=L_AUTOID AND VIA=P_via; --Ngay 04/09/2018 NamTv them chinh sua chu ky so;
        ELSE
           UPDATE OTRIGHTDTL SET OTRIGHT='YYYYYNYNN' WHERE AUTOID=L_AUTOID AND VIA=P_via; --Ngay 04/09/2018 NamTv them chinh sua chu ky so;
        END IF;
*/
    ELSIF P_ISREGIS='Y' AND L_AUTOID=0 THEN -- insert them mot dong dl
       SELECT COUNT(*) INTO L_COUNT
       FROM OTRIGHT WHERE CFCUSTID=AUTHCUSTID AND CFCUSTID=P_CUSTID AND VIA=P_via --Ngay 04/09/2018 NamTv them chinh sua chu ky so;
       AND DELTD <> 'Y';
       IF L_COUNT=0 THEN
                 insert into OTRIGHT (AUTOID, CFCUSTID, AUTHCUSTID, AUTHTYPE, VALDATE, EXPDATE, DELTD, LASTDATE, LASTCHANGE, SERIALTOKEN, VIA)
                values (SEQ_OTRIGHT.NEXTVAL, P_CUSTID, P_CUSTID, '1', GETCURRDATE, add_months(GETCURRDATE,120) , 'N', null, getcurrdate, '', P_via);
       END IF;
       IF P_OTFUNCID = 'CASHTRANS' THEN
          insert into OTRIGHTDTL (AUTOID, CFCUSTID, AUTHCUSTID, OTMNCODE, OTRIGHT, DELTD, VIA)
          values (SEQ_OTRIGHTDTL.NEXTVAL, P_CUSTID, P_CUSTID, P_OTFUNCID, 'YYYYYNYNN', 'N', P_via);
       ELSIF P_OTFUNCID = 'AUTOADV' THEN
                     insert into OTRIGHTDTL (AUTOID, CFCUSTID, AUTHCUSTID, OTMNCODE, OTRIGHT, DELTD, VIA)
             values (SEQ_OTRIGHTDTL.NEXTVAL, P_CUSTID, P_CUSTID, P_OTFUNCID, 'YYYYYNYNN', 'N', P_via);

                         FOR rec IN
                             (
                             select af.acctno from afmast af, aftype aft, mrtype mrt
                                                where af.actype = aft.actype
                                                and aft.mrtype = mrt.actype
                                                AND mrt.mrtype = 'N' AND custid = P_CUSTID
                           )
                         LOOP
                                     UPDATE afmast SET autoadv ='Y'
                                     WHERE  acctno = rec.acctno;
                                     insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
                                     values ('CFMAST', 'CUSTID = ''' ||P_CUSTID ||'''', '6868', to_date(getcurrdate, 'dd-mm-yyyy'), 'N', '6868', to_date(getcurrdate, 'dd-mm-yyyy'), 3, 'AUTOADV', null, 'Y', 'EDIT', 'AFMAST', 'ACCTNO = '''||  rec.acctno  ||'''', to_char(SYSTIMESTAMP,'hh24:mm:ss'),to_char(SYSTIMESTAMP,'hh24:mm:ss'));
                        END LOOP;
            ELSE
             insert into OTRIGHTDTL (AUTOID, CFCUSTID, AUTHCUSTID, OTMNCODE, OTRIGHT, DELTD, VIA)
             values (SEQ_OTRIGHTDTL.NEXTVAL, P_CUSTID, P_CUSTID, P_OTFUNCID, 'YYYYYNYNN', 'N', P_via);
       END IF;
    ELSIF P_ISREGIS='N' AND L_AUTOID <> 0 THEN-- xoa dong da dang ki
       UPDATE OTRIGHTDTL SET OTRIGHT='NNNNNNNNN' WHERE AUTOID=L_AUTOID AND VIA=P_via ;--Ngay 04/09/2018 NamTv them chinh sua chu ky so;
    END IF;

EXCEPTION
WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_RegisterOnlineServices');
END pr_RegisterOnlineServices;



PROCEDURE pr_DealLoanPayment_by_autoid
  (p_autoid IN VARCHAR2,
   p_prinAmount in  number ,
   p_intAmount in  number ,
   p_fee in  number ,
   p_err_code  OUT varchar2,
   p_err_message  OUT varchar2
  )
  IS
      l_txmsg       tx.msg_rectype;
      v_strCURRDATE                  varchar2(20);
      l_err_param                    varchar2(300);
      v_dtCURRDATE date;
      L_STARTTIME number(10);
    L_ENDTIME number(10);
    L_CURRTIME number(10);
    l_amt NUMBER ;

  BEGIN

   plog.setbeginsection(pkgctx, 'pr_DealLoanPayment_by_autoid');

   -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'Pr_Change_Pass_Online');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTLNPAYMENT';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDLNPAYMENT';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;
    if ( NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
        p_err_code := '-994459';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_DealLoanPayment_by_autoid');
        return;
    end if;


    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_dtCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=v_dtCURRDATE;
    l_txmsg.busdate:=v_dtCURRDATE;
    l_txmsg.tltxcd:='5540';
    for rec in (
          select FN_GET_LOCATION(substr(a.TRFACCTNO,1,4)) LOCATION,
            CUSTBANK, AUTOID, ACCTNO, TRFACCTNO, LNTYPE, DESC_LNTYPE, CUSTODYCD, nvl( T0ODAMT,0) T0ODAMT,
            nvl(T0PRINNML,0) T0PRINNML,nvl( T0PRINDUE,0) T0PRINDUE ,nvl(T0PRINOVD,0) T0PRINOVD,nvl(PRINOVD,0) PRINOVD, nvl(PRINDUE,0) PRINDUE
            ,nvl(PRINNML,0) PRINNML, nvl( FEEOVD,0)FEEOVD , nvl(SUMINTNMLOVD,0) SUMINTNMLOVD ,
            nvl(INTNMLOVD,0) INTNMLOVD ,nvl(T0INTNMLOVD,0) T0INTNMLOVD,nvl(FEEINTNMLOVD,0) FEEINTNMLOVD ,nvl(SUMINTOVDACR,0)SUMINTOVDACR
            ,nvl( INTOVDACR,0) INTOVDACR ,nvl( T0INTOVDACR,0) T0INTOVDACR ,
           nvl( FEEINTOVDACR,0) FEEINTOVDACR, nvl(FEEDUE,0) FEEDUE,nvl( SUMINTDUE,0)SUMINTDUE ,nvl(INTDUE,0) INTDUE, nvl(T0INTDUE,0) T0INTDUE,nvl(FEEINTDUE,0) FEEINTDUE, nvl( FEE,0) FEE, nvl(SUMINTNMLACR,0) SUMINTNMLACR,
           nvl(INTNMLACR,0) INTNMLACR,nvl(T0INTNMLACR,0) T0INTNMLACR ,nvl(FEEINTNMLACR,0) FEEINTNMLACR, nvl(ADVPAY,0) ADVPAY
           ,nvl(ADVPAYFEE,0) ADVPAYFEE,nvl( ODAMT,0) ODAMT,nvl( NMLAMT,0) NMLAMT,
           nvl(PRINNMLAMT,0) PRINNMLAMT,nvl(INTNMLAMT,0) INTNMLAMT,nvl(PRINODAMT,0) PRINODAMT, nvl(INTODAMT,0) INTODAMT, STATUS, MINTERM,nvl( AVLBAL,0) AVLBAL, RLSDATE,
            OVERDUEDATE, LSREFTYPE,accrualsamt
            from v_ln5540 a where 0=0 and autoid =p_autoid
    )
    loop

        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.ACCTNO,1,4);

      --  p_txnum:=l_txmsg.txnum;
       -- p_txdate:=l_txmsg.txdate;
        --Set cac field giao dich
        --01    autoid          C
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.autoid;

        --03    ACCTNO          C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.ACCTNO;
        --05    CIACCTNO        C
        l_txmsg.txfields ('05').defname   := 'CIACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.TRFACCTNO;
        --07    LNTYPE          C
        l_txmsg.txfields ('07').defname   := 'LNTYPE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.LNTYPE;
        --09    T0ODAMT         N
        l_txmsg.txfields ('09').defname   := 'T0ODAMT';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.T0ODAMT;

        --10    T0PRINOVD       N
        l_txmsg.txfields ('10').defname   := 'T0PRINOVD';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.T0PRINOVD;
        --11    T0PRINDUE       N
        l_txmsg.txfields ('11').defname   := 'T0PRINDUE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.T0PRINDUE;
        --12    T0PRINNML       N
        l_txmsg.txfields ('12').defname   := 'T0PRINNML';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.T0PRINNML       ;
        --13    PRINOVD         N
        l_txmsg.txfields ('13').defname   := 'PRINOVD';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.PRINOVD;
        --14    PRINDUE         N
        l_txmsg.txfields ('14').defname   := 'PRINDUE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.PRINDUE;
        --15    PRINNML         N
        l_txmsg.txfields ('15').defname   := 'PRINNML';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := rec.PRINNML;
        --20    FEEOVD          N
        l_txmsg.txfields ('20').defname   := 'FEEOVD';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := rec.FEEOVD;
        --21    SUMINTNMLOVD    N
        l_txmsg.txfields ('21').defname   := 'SUMINTNMLOVD';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := rec.SUMINTNMLOVD;
        --22    T0INTNMLOVD     N
        l_txmsg.txfields ('22').defname   := 'T0INTNMLOVD';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := rec.T0INTNMLOVD;
        --23    INTNMLOVD       N
        l_txmsg.txfields ('23').defname   := 'INTNMLOVD';
        l_txmsg.txfields ('23').TYPE      := 'N';
        l_txmsg.txfields ('23').VALUE     := rec.INTNMLOVD;
        --24    SUMINTOVDACR    N
        l_txmsg.txfields ('24').defname   := 'SUMINTOVDACR';
        l_txmsg.txfields ('24').TYPE      := 'N';
        l_txmsg.txfields ('24').VALUE     := rec.SUMINTOVDACR;
        --25    T0INTOVDACR     N
        l_txmsg.txfields ('25').defname   := 'T0INTOVDACR';
        l_txmsg.txfields ('25').TYPE      := 'N';
        l_txmsg.txfields ('25').VALUE     := rec.T0INTOVDACR;
        --26    INTOVDACR       N
        l_txmsg.txfields ('26').defname   := 'INTOVDACR';
        l_txmsg.txfields ('26').TYPE      := 'N';
        l_txmsg.txfields ('26').VALUE     := rec.INTOVDACR;
        --27    FEEDUE          N
        l_txmsg.txfields ('27').defname   := 'FEEDUE';
        l_txmsg.txfields ('27').TYPE      := 'N';
        l_txmsg.txfields ('27').VALUE     := rec.FEEDUE;
        --28    SUMINTDUE       N
        l_txmsg.txfields ('28').defname   := 'SUMINTDUE';
        l_txmsg.txfields ('28').TYPE      := 'N';
        l_txmsg.txfields ('28').VALUE     := rec.SUMINTDUE;
        --29    T0INTDUE        N
        l_txmsg.txfields ('29').defname   := 'T0INTDUE';
        l_txmsg.txfields ('29').TYPE      := 'N';
        l_txmsg.txfields ('29').VALUE     := rec.T0INTDUE;
        --30    DESC            C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Tra no deal online';
        --31    INTDUE          N
        l_txmsg.txfields ('31').defname   := 'INTDUE';
        l_txmsg.txfields ('31').TYPE      := 'N';
        l_txmsg.txfields ('31').VALUE     := rec.INTDUE;
        --32    FEE             N
        l_txmsg.txfields ('32').defname   := 'FEE';
        l_txmsg.txfields ('32').TYPE      := 'N';
        l_txmsg.txfields ('32').VALUE     := rec.FEE;
        --33    SUMINTNMLACR    N
        l_txmsg.txfields ('33').defname   := 'SUMINTNMLACR';
        l_txmsg.txfields ('33').TYPE      := 'N';
        l_txmsg.txfields ('33').VALUE     := rec.SUMINTNMLACR;
        --34    T0INTNMLACR     N
        l_txmsg.txfields ('34').defname   := 'T0INTNMLACR';
        l_txmsg.txfields ('34').TYPE      := 'N';
        l_txmsg.txfields ('34').VALUE     := rec.T0INTNMLACR;
        --35    INTNMLACR       N
        l_txmsg.txfields ('35').defname   := 'INTNMLACR';
        l_txmsg.txfields ('35').TYPE      := 'N';
        l_txmsg.txfields ('35').VALUE     := rec.INTNMLACR;
        --40    ODAMT           N
        l_txmsg.txfields ('40').defname   := 'ODAMT';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').VALUE     := rec.ODAMT;
        --41    PRINODAMT       N
        l_txmsg.txfields ('41').defname   := 'PRINODAMT';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := rec.PRINODAMT;
        --42    PRINNMLAMT      N
        l_txmsg.txfields ('42').defname   := 'PRINNMLAMT';
        l_txmsg.txfields ('42').TYPE      := 'N';
        l_txmsg.txfields ('42').VALUE     := rec.PRINNMLAMT;
        --43    INTODAMT        N
        l_txmsg.txfields ('43').defname   := 'INTODAMT';
        l_txmsg.txfields ('43').TYPE      := 'N';
        l_txmsg.txfields ('43').VALUE     := rec.INTODAMT;
        --44    INTNMLAMT       N
        l_txmsg.txfields ('44').defname   := 'INTNMLAMT';
        l_txmsg.txfields ('44').TYPE      := 'N';
        l_txmsg.txfields ('44').VALUE     := rec.INTNMLAMT;
        --45    PRINAMT         N
        l_txmsg.txfields ('45').defname   := 'PRINAMT';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := p_prinAmount;
        --46    INTAMT          N
        l_txmsg.txfields ('46').defname   := 'INTAMT';
        l_txmsg.txfields ('46').TYPE      := 'N';
        l_txmsg.txfields ('46').VALUE     := p_intAmount;
        --47    ADVFEE          N
        l_txmsg.txfields ('47').defname   := 'ADVFEE';
        l_txmsg.txfields ('47').TYPE      := 'N';
        l_txmsg.txfields ('47').VALUE     := p_fee;
        --50    PERCENT         N
        l_txmsg.txfields ('50').defname   := 'PERCENT';
        l_txmsg.txfields ('50').TYPE      := 'N';
        l_txmsg.txfields ('50').VALUE     := 100;

        --51    POTHERAMT         N
        l_txmsg.txfields ('51').defname   := 'POTHERAMT';
        l_txmsg.txfields ('51').TYPE      := 'N';
        l_txmsg.txfields ('51').VALUE     := 0;

        --52    MINTERM         N
        l_txmsg.txfields ('52').defname   := 'MINTERM';
        l_txmsg.txfields ('52').TYPE      := 'N';
        l_txmsg.txfields ('52').VALUE     :=  rec.MINTERM;

        --60    PT0PRINOVD      N
        l_txmsg.txfields ('60').defname   := 'PT0PRINOVD';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').VALUE     := 0;
        --61    PT0PRINDUE      N
        l_txmsg.txfields ('61').defname   := 'PT0PRINDUE';
        l_txmsg.txfields ('61').TYPE      := 'N';
        l_txmsg.txfields ('61').VALUE     := 0;
        --62    PT0PRINNML      N
        l_txmsg.txfields ('62').defname   := 'PT0PRINNML';
        l_txmsg.txfields ('62').TYPE      := 'N';
        l_txmsg.txfields ('62').VALUE     := 0;
        --63    PPRINOVD        N
        l_txmsg.txfields ('63').defname   := 'PPRINOVD';
        l_txmsg.txfields ('63').TYPE      := 'N';
        l_txmsg.txfields ('63').VALUE     := 0;
        --64    PPRINDUE        N
        l_txmsg.txfields ('64').defname   := 'PPRINDUE';
        l_txmsg.txfields ('64').TYPE      := 'N';
        l_txmsg.txfields ('64').VALUE     := 0;
        --65    PPRINNML        N
        l_txmsg.txfields ('65').defname   := 'PPRINNML';
        l_txmsg.txfields ('65').TYPE      := 'N';
        l_txmsg.txfields ('65').VALUE     := 0;
        --70    PFEEOVD         N
        l_txmsg.txfields ('70').defname   := 'PFEEOVD';
        l_txmsg.txfields ('70').TYPE      := 'N';
        l_txmsg.txfields ('70').VALUE     := 0;
        --71    PT0INTNMLOVD    N
        l_txmsg.txfields ('71').defname   := 'PT0INTNMLOVD';
        l_txmsg.txfields ('71').TYPE      := 'N';
        l_txmsg.txfields ('71').VALUE     := 0;
        --72    PINTNMLOVD      N
        l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
        l_txmsg.txfields ('72').TYPE      := 'N';
        l_txmsg.txfields ('72').VALUE     := 0;
        --73    PT0INTOVDACR    N
        l_txmsg.txfields ('73').defname   := 'PT0INTOVDACR';
        l_txmsg.txfields ('73').TYPE      := 'N';
        l_txmsg.txfields ('73').VALUE     := 0;
        --74    PINTOVDACR      N
        l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
        l_txmsg.txfields ('74').TYPE      := 'N';
        l_txmsg.txfields ('74').VALUE     := 0;
        --75    PFEEDUE         N
        l_txmsg.txfields ('75').defname   := 'PFEEDUE';
        l_txmsg.txfields ('75').TYPE      := 'N';
        l_txmsg.txfields ('75').VALUE     := 0;
        --76    PT0INTDUE       N
        l_txmsg.txfields ('76').defname   := 'PT0INTDUE';
        l_txmsg.txfields ('76').TYPE      := 'N';
        l_txmsg.txfields ('76').VALUE     := 0;
        --77    PINTDUE         N
        l_txmsg.txfields ('77').defname   := 'PINTDUE';
        l_txmsg.txfields ('77').TYPE      := 'N';
        l_txmsg.txfields ('77').VALUE     := 0;
        --78    PFEE            N
        l_txmsg.txfields ('78').defname   := 'PFEE';
        l_txmsg.txfields ('78').TYPE      := 'N';
        l_txmsg.txfields ('78').VALUE     := 0;
        --79    PT0INTNMLACR    N
        l_txmsg.txfields ('79').defname   := 'PT0INTNMLACR';
        l_txmsg.txfields ('79').TYPE      := 'N';
        l_txmsg.txfields ('79').VALUE     := 0;
        --80    PINTNMLACR      N
        l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').VALUE     := 0;
        --81    ADVPAYAMT       N
        l_txmsg.txfields ('81').defname   := 'ADVPAYAMT';
        l_txmsg.txfields ('81').TYPE      := 'N';
        l_txmsg.txfields ('81').VALUE     := 0;
        --82    FEEAMT          N
        l_txmsg.txfields ('82').defname   := 'FEEAMT';
        l_txmsg.txfields ('82').TYPE      := 'N';
        l_txmsg.txfields ('82').VALUE     := 0;
        --83    PAYAMT          N
        l_txmsg.txfields ('83').defname   := 'PAYAMT';
        l_txmsg.txfields ('83').TYPE      := 'N';
        l_txmsg.txfields ('83').VALUE     := 0;

        --84    PFEEINTOVDACR          N
        l_txmsg.txfields ('84').defname   := 'PFEEINTOVDACR';
        l_txmsg.txfields ('84').TYPE      := 'N';
        l_txmsg.txfields ('84').VALUE     := 0;

        --90    PFEEINTOVDACR          N
        l_txmsg.txfields ('90').defname   := 'PFEEINTNMLACR';
        l_txmsg.txfields ('90').TYPE      := 'N';
        l_txmsg.txfields ('90').VALUE     := 0;

        --91    FEEINTDUE          N
        l_txmsg.txfields ('91').defname   := 'FEEINTDUE';
        l_txmsg.txfields ('91').TYPE      := 'N';
        l_txmsg.txfields ('91').VALUE     := rec.FEEINTDUE;

        --92    PFEEINTNMLOVD          N
        l_txmsg.txfields ('92').defname   := 'PFEEINTNMLOVD';
        l_txmsg.txfields ('92').TYPE      := 'N';
        l_txmsg.txfields ('92').VALUE     := 0;

        --93    FEEINTNMLOVD          N
        l_txmsg.txfields ('93').defname   := 'FEEINTNMLOVD';
        l_txmsg.txfields ('93').TYPE      := 'N';
        l_txmsg.txfields ('93').VALUE     := rec.FEEINTNMLOVD;

        --95    FEEINTNMLACR          N
        l_txmsg.txfields ('95').defname   := 'FEEINTNMLACR';
        l_txmsg.txfields ('95').TYPE      := 'N';
        l_txmsg.txfields ('95').VALUE     := 0;

        --96    FEEINTOVDACR          N
        l_txmsg.txfields ('96').defname   := 'FEEINTOVDACR';
        l_txmsg.txfields ('96').TYPE      := 'N';
        l_txmsg.txfields ('96').VALUE     := rec.FEEINTOVDACR;

        --97    PFEEINTDUE          N
        l_txmsg.txfields ('97').defname   := 'PFEEINTDUE';
        l_txmsg.txfields ('97').TYPE      := 'N';
        l_txmsg.txfields ('97').VALUE     := 0;

        --99    AVLBAL          N
        l_txmsg.txfields ('99').defname   := 'AVLBAL';
        l_txmsg.txfields ('99').TYPE      := 'N';
        l_txmsg.txfields ('99').VALUE     := rec.AVLBAL;

/*
       --Set lai tham so theo fldval
        --IP  60  45                                          10
        l_txmsg.txfields ('60').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE,l_txmsg.txfields ('10').VALUE),0);
        --IP  61  45--60                                      11
        l_txmsg.txfields ('61').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE,l_txmsg.txfields ('11').VALUE),0);
        --IP  62  45--60--61                                  12
        l_txmsg.txfields ('62').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE,l_txmsg.txfields ('12').VALUE),0);
        --IP  63  45--60--61--62                              13
        l_txmsg.txfields ('63').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE,l_txmsg.txfields ('13').VALUE),0);
        --IP  64  45--60--61--62--63                          14
        l_txmsg.txfields ('64').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE-l_txmsg.txfields ('63').VALUE,l_txmsg.txfields ('14').VALUE),0);
        --IP  65  45--60--61--62--63--64                      15
        l_txmsg.txfields ('65').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE-l_txmsg.txfields ('63').VALUE-l_txmsg.txfields ('64').VALUE,l_txmsg.txfields ('15').VALUE),0);

        l_txmsg.txfields ('80').VALUE:=l_txmsg.txfields ('46').VALUE;
        --IP  70  46                                          20
        l_txmsg.txfields ('70').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE,l_txmsg.txfields ('20').VALUE),0);
        --IP  71  46--70                                      22
        l_txmsg.txfields ('71').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE,l_txmsg.txfields ('22').VALUE),0);
        --IP  72  46--70--71                                  23
        l_txmsg.txfields ('72').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE,l_txmsg.txfields ('23').VALUE),0);
        --IP  73  46--70--71--72                              25
        l_txmsg.txfields ('73').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE,l_txmsg.txfields ('25').VALUE),0);
        --IP  74  46--70--71--72--73                          26
        l_txmsg.txfields ('74').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE,l_txmsg.txfields ('26').VALUE),0);
        --IP  75  46--70--71--72--73--74                      27
        l_txmsg.txfields ('75').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE,l_txmsg.txfields ('27').VALUE),0);
        --IP  76  46--70--71--72--73--74--75                  29
        l_txmsg.txfields ('76').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE,l_txmsg.txfields ('29').VALUE),0);
        --IP  77  46--70--71--72--73--74--75--76              31
        l_txmsg.txfields ('77').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE,l_txmsg.txfields ('31').VALUE),0);
        --IP  78  46--70--71--72--73--74--75--76--77          32
        l_txmsg.txfields ('78').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE-l_txmsg.txfields ('77').VALUE,l_txmsg.txfields ('32').VALUE),0);
        --IP  79  46--70--71--72--73--74--75--76--77--78      34
        l_txmsg.txfields ('79').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE-l_txmsg.txfields ('77').VALUE-l_txmsg.txfields ('78').VALUE,l_txmsg.txfields ('34').VALUE),0);
        --IP  80  46--70--71--72--73--74--75--76--77--78--79  35
        --l_txmsg.txfields ('80').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE-l_txmsg.txfields ('77').VALUE-l_txmsg.txfields ('78').VALUE-l_txmsg.txfields ('79').VALUE,l_txmsg.txfields ('35').VALUE),0);
        --IP  81  65++78++79++80                              65++78++79++80
        l_txmsg.txfields ('81').VALUE:=greatest(l_txmsg.txfields ('65').VALUE+l_txmsg.txfields ('80').VALUE+l_txmsg.txfields ('78').VALUE+l_txmsg.txfields ('79').VALUE,0);
        --IP  82  81**47//50                                  81**47//50
        l_txmsg.txfields ('82').VALUE:=ROUND(greatest(l_txmsg.txfields ('81').VALUE*l_txmsg.txfields ('47').VALUE/l_txmsg.txfields ('50').VALUE,0),0);
        --IP  83  45++46++82                                  45++46++82
        l_txmsg.txfields ('83').VALUE:=greatest(l_txmsg.txfields ('45').VALUE+l_txmsg.txfields ('46').VALUE+l_txmsg.txfields ('82').VALUE,0);

*/

       --Set lai tham so theo fldval
        --IP  60  45                                          10
        l_txmsg.txfields ('60').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE,l_txmsg.txfields ('10').VALUE),0);
        --IP  61  45--60                                      11
        l_txmsg.txfields ('61').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE,l_txmsg.txfields ('11').VALUE),0);
        --IP  62  45--60--61                                  12
        l_txmsg.txfields ('62').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE,l_txmsg.txfields ('12').VALUE),0);
        --IP  63  45--60--61--62                              13
        l_txmsg.txfields ('63').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE,l_txmsg.txfields ('13').VALUE),0);
        --IP  64  45--60--61--62--63                          14
        l_txmsg.txfields ('64').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE-l_txmsg.txfields ('63').VALUE,l_txmsg.txfields ('14').VALUE),0);
        --IP  65  45--60--61--62--63--64                      15
        l_txmsg.txfields ('65').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE-l_txmsg.txfields ('63').VALUE-l_txmsg.txfields ('64').VALUE,l_txmsg.txfields ('15').VALUE),0);


        --73  5540    9   E   IP  46                                                          25
        l_txmsg.txfields ('73').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE,l_txmsg.txfields ('25').VALUE),0);

        --71  5540    10  E   IP  46--73                                                      22
        l_txmsg.txfields ('71').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE -l_txmsg.txfields ('73').VALUE,l_txmsg.txfields ('22').VALUE),0);

        --76  5540    11  E   IP  46--73--71                                                  29
        l_txmsg.txfields ('76').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE ,l_txmsg.txfields ('29').VALUE),0);

        --79  5540    12  E   IP  46--73--71--76                                              34
        l_txmsg.txfields ('79').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE -l_txmsg.txfields ('76').VALUE  ,l_txmsg.txfields ('34').VALUE),0);

        --92  5540    13  E   IP  46--73--71--76--79                                          93
        l_txmsg.txfields ('92').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE   ,l_txmsg.txfields ('93').VALUE),0);

        --90  5540    14  E   IP  46--73--71--76--79--92                                      95
        l_txmsg.txfields ('90').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE   ,l_txmsg.txfields ('95').VALUE),0);

        --97  5540    15  E   IP  46--73--71--76--79--92--90                                  91
        l_txmsg.txfields ('97').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE   ,l_txmsg.txfields ('91').VALUE),0);

        --70  5540    16  E   IP  46--73--71--76--79--92--90--97                              20

        l_txmsg.txfields ('70').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE  ,l_txmsg.txfields ('20').VALUE),0);

        --75  5540    17  E   IP  46--73--71--76--79--92--90--97--70                          27

        l_txmsg.txfields ('75').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE ,l_txmsg.txfields ('27').VALUE),0);

        --78  5540    18  E   IP  46--73--71--76--79--92--90--97--70--75                      32

        l_txmsg.txfields ('78').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE -l_txmsg.txfields ('75').VALUE ,l_txmsg.txfields ('32').VALUE),0);

        --74  5540    19  E   IP  46--73--71--76--79--92--90--97--70--75--78                  26

        l_txmsg.txfields ('74').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE -l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('78').VALUE ,l_txmsg.txfields ('26').VALUE),0);

        --72  5540    27  E   IP  46--73--71--76--79--92--90--97--70--75--78--74              23

        l_txmsg.txfields ('72').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE -l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('78').VALUE -l_txmsg.txfields ('74').VALUE,l_txmsg.txfields ('23').VALUE),0);

        --77  5540    28  E   IP  46--73--71--76--79--92--90--97--70--75--78--74--72          31

        l_txmsg.txfields ('77').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE -l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('78').VALUE -l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('72').VALUE,l_txmsg.txfields ('31').VALUE),0);

        --80  5540    29  E   IP  46--73--71--76--79--92--90--97--70--75--78--74--72--77      35

        l_txmsg.txfields ('80').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE -l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('78').VALUE -l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('77').VALUE,l_txmsg.txfields ('35').VALUE),0);


        --84  5540    30  E   IP  46--73--71--76--79--92--90--97--70--75--78--74--72--77--80  96

        l_txmsg.txfields ('84').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('71').VALUE
        -l_txmsg.txfields ('76').VALUE -l_txmsg.txfields ('79').VALUE -l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('90').VALUE -l_txmsg.txfields ('97').VALUE
        -l_txmsg.txfields ('70').VALUE -l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('78').VALUE -l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('77').VALUE
        -l_txmsg.txfields ('80').VALUE,l_txmsg.txfields ('96').VALUE),0);

        --81  5540    31  E   IP  65++78++79++80++90                                          65++78++79++80++90
                l_txmsg.txfields ('81').VALUE:=greatest(l_txmsg.txfields ('65').VALUE+l_txmsg.txfields ('80').VALUE+l_txmsg.txfields ('78').VALUE+l_txmsg.txfields ('79').VALUE+l_txmsg.txfields ('90').VALUE,0);
        --82  5540    32  E   IP  81**47//50                                                  81**47//50
        l_txmsg.txfields ('82').VALUE:=ROUND(greatest(l_txmsg.txfields ('81').VALUE*l_txmsg.txfields ('47').VALUE/l_txmsg.txfields ('50').VALUE,0),0);
        --83  5540    33  E   IP  45++46++82                                                  45++46++82
        l_txmsg.txfields ('83').VALUE:=greatest(l_txmsg.txfields ('45').VALUE+l_txmsg.txfields ('46').VALUE+l_txmsg.txfields ('82').VALUE,0);

--check fldval  so tien nhap goc va lai khong duoc lon hon so tien no

         --85    N   ACCRUALSAMT
        L_TXMSG.TXFIELDS('85').DEFNAME := 'ACCRUALSAMT';
        L_TXMSG.TXFIELDS('85').TYPE := 'N';
        L_TXMSG.TXFIELDS('85').VALUE := LEAST( REC.ACCRUALSAMT,to_number(l_txmsg.txfields ('46').VALUE))  ;

              --86    N   NOTACCRUALSAMT
        L_TXMSG.TXFIELDS('86').DEFNAME := 'NOTACCRUALSAMT';
        L_TXMSG.TXFIELDS('86').TYPE := 'N';
        L_TXMSG.TXFIELDS('86').VALUE := to_number(l_txmsg.txfields ('46').VALUE) - REC.ACCRUALSAMT;


 IF rec.OVERDUEDATE > getcurrdate THEN
  SELECT  SUM (lns.OVD+lns.INTDUE+lns.INTOVD+lns.INTOVDPRIN) INTO l_amt   FROM lnschd lns, lnmast ln
  WHERE lns.acctno = ln.acctno
  AND ln.trfacctno = rec.TRFACCTNO
  AND lns.autoid <> p_autoid ;


IF l_amt>0 THEN
   p_err_code:='-570776';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_DealLoanPayment_by_autoid');
        return;
END IF;
 END IF ;



 if ( to_number( l_txmsg.txfields ('45').VALUE ) > to_number( l_txmsg.txfields ('41').VALUE)) then
        p_err_code:='-570774';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_DealLoanPayment_by_autoid');
        return;
 end if;

  if (to_number(l_txmsg.txfields ('46').VALUE) >to_number( l_txmsg.txfields ('43').VALUE)) then
        p_err_code:='-570775';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_DealLoanPayment_by_autoid');
        return;
 end if;




        BEGIN
            IF txpks_#5540.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.error (pkgctx,
                           'got error 5540: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;

    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DealLoanPayment_by_autoid');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx,  ' got error on pr_DealLoanPayment_by_autoid');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_DealLoanPayment_by_autoid');
      RAISE errnums.E_SYSTEM_ERROR;

END pr_DealLoanPayment_by_autoid;

PROCEDURE pr_ExtendMarginDeal
  (p_autoid IN VARCHAR2,
  p_todate IN VARCHAR2,
  p_feetype IN VARCHAR2,
  p_err_code  OUT varchar2,
  p_err_message  OUT varchar2
  )
  IS
  l_txmsg       tx.msg_rectype;
  v_strCURRDATE                  varchar2(20);
  l_err_param                    varchar2(300);
  l_mnemonic                     aftype.mnemonic%type;
  l_autoid                       VARCHAR2(10);
  l_acctno                       VARCHAR2(50);
  l_overduedate                  DATE;
  l_lntype                       VARCHAR2(10);
  l_fullname                     VARCHAR2(500);
  l_afacctno                     VARCHAR2(20);
  l_custodycd                    VARCHAR2(20);
  l_prinperiod                   VARCHAR2(20);
  l_rlsdate                      DATE;
  l_idcode                       VARCHAR2(20);
  l_iddate                       DATE;
  l_idplace                      VARCHAR2(100);
  l_address                      VARCHAR2(1000);
  l_lnprinamt                    NUMBER;
  l_lnintamt                     NUMBER;
  l_intrate                      NUMBER;
  l_Baldefovd                    NUMBER;
  l_rlsamt                       NUMBER;
  l_extimes                      NUMBER;
  l_begindate                    DATE;
  l_logStr                      VARCHAR2(1000);
  L_STARTTIME NUMBER(10);
        L_ENDTIME NUMBER(10);
        L_CURRTIME NUMBER(10);
  BEGIN
    l_logStr :=' p_autoid:'||p_autoid||' p_todate:'||p_todate||' p_feetype:'||p_feetype;
    plog.setbeginsection(pkgctx, 'pr_ExtendMarginDeal');

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, l_logStr||' Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_ExtendMarginDeal');
            return;
        END IF;
        -- End: Check host 1 active or inactive


    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTEXTENDMRDEAL';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDEXTENDMRDEAL';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

    if (NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
        p_err_code := '-994458';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, l_logStr||' Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    end if;

  SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='5574';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --l_txmsg.brid        := substr(p_afacctno,1,4);

        --Lay thong tin deal
        SELECT   aft.mnemonic,chd.autoid, chd.acctno, chd.overduedate, mst.actype lntype,
         cf.fullname, af.acctno afacctno, cf.custodycd, mst.prinperiod,
         chd.rlsdate, cf.idcode, cf.iddate, cf.idplace,
         cf.address, chd.nml + chd.ovd lnprinamt,
         chd.intnmlacr + chd.intdue + chd.intovd + chd.intovdprin + chd.feedue + chd.feeovd+
         chd.feeintnmlacr +chd.feeintnmlovd+chd.feeintovdacr+ chd.feeintdue + chd.feeintovd lnintamt,
         chd.rate2 intrate,getbaldefovd(af.acctno) Baldefovd,chd.nml + chd.ovd +chd.paid rlsamt,
         chd.extimes,getprevdate(chd.overduedate,type.exdays) begindate
         INTO l_mnemonic, l_autoid, l_acctno, l_overduedate, l_lntype, l_fullname, l_afacctno, l_custodycd, l_prinperiod,
         l_rlsdate, l_idcode, l_iddate, l_idplace,
         l_address, l_lnprinamt,l_lnintamt,
         l_intrate,l_Baldefovd,l_rlsamt,
         l_extimes,l_begindate
  FROM   lnschd chd, lnmast mst, (SELECT * FROM sysvar WHERE varname = 'CURRDATE') sy,
         cfmast cf, afmast af, aftype aft,lntype type
 WHERE   chd.overduedate IS NOT NULL
         AND varname = 'CURRDATE' AND chd.acctno = mst.acctno
         AND cf.custid = af.custid AND af.acctno = mst.trfacctno
         and af.actype = aft.actype
         and mst.actype=type.actype
         AND mst.ftype = 'AF' AND chd.reftype = 'P'
         AND TO_DATE (chd.overduedate, 'DD/MM/RRRR') >= TO_DATE (sy.varvalue, 'DD/MM/RRRR')
         AND  (chd.nml) + (chd.ovd) + (chd.intnmlacr) + (chd.fee) + (chd.intdue) + (chd.intovd) + (intovdprin) + (chd.feedue) + (chd.feeovd) > 0
         AND chd.autoid = p_autoid;

         --set cac field giao dich
         --03   AUTOID      C
        l_txmsg.txfields ('01').defname   := 'AUTOID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := p_autoid;

        --02   CUSTODYCD      C
        l_txmsg.txfields ('02').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := l_custodycd;

        --03   ACCTNO      C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := l_acctno;

        --04   AFACCTNO      C
        l_txmsg.txfields ('04').defname   := 'AFACCTNO';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := l_afacctno;

        --05   TODATE      D
        l_txmsg.txfields ('05').defname   := 'TODATE';
        l_txmsg.txfields ('05').TYPE      := 'D';
        l_txmsg.txfields ('05').VALUE     := to_date(p_todate,systemnums.c_date_format);

        --10   LNPRINAMT      N
        l_txmsg.txfields ('10').defname   := 'LNPRINAMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := l_lnprinamt;

        --11   EXTENTDAY      N
        l_txmsg.txfields ('11').defname   := 'EXTENTDAY';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := cspks_lnproc.fn_getOVDD_From_New(l_overduedate, to_date(p_todate,systemnums.c_date_format));

        --12   RLSAMT      N
        l_txmsg.txfields ('12').defname   := 'RLSAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := l_rlsamt;

        --13   PRODUCTNAME      C
        l_txmsg.txfields ('13').defname   := 'PRODUCTNAME';
        l_txmsg.txfields ('13').TYPE      := 'C';
        l_txmsg.txfields ('13').VALUE     := l_lntype;

        --14   CUSTNAME      C
        l_txmsg.txfields ('14').defname   := 'CUSTNAME';
        l_txmsg.txfields ('14').TYPE      := 'C';
        l_txmsg.txfields ('14').VALUE     := l_fullname;

        --15   IDCODE      C
        l_txmsg.txfields ('15').defname   := 'IDCODE';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := l_idcode;

        --16   IDDATE      D
        l_txmsg.txfields ('16').defname   := 'IDDATE';
        l_txmsg.txfields ('16').TYPE      := 'D';
        l_txmsg.txfields ('16').VALUE     := l_iddate;

        --17   IDPLACE      C
        l_txmsg.txfields ('17').defname   := 'IDPLACE';
        l_txmsg.txfields ('17').TYPE      := 'C';
        l_txmsg.txfields ('17').VALUE     := l_idplace;

        --18   ADDRESS      C
        l_txmsg.txfields ('18').defname   := 'ADDRESS';
        l_txmsg.txfields ('18').TYPE      := 'C';
        l_txmsg.txfields ('18').VALUE     := l_address;

        --20   LNINTAMT      N
        l_txmsg.txfields ('20').defname   := 'LNINTAMT';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := l_lnintamt;

        --21   LNINTAMT      N
        l_txmsg.txfields ('21').defname   := 'INTRATE';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := 0;

        --22   MRRATE      N
        l_txmsg.txfields ('22').defname   := 'MRRATE';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := cspks_lnproc.fn_getMRRATE(l_afacctno);

        --25   SEASS      N
        l_txmsg.txfields ('25').defname   := 'SEASS';
        l_txmsg.txfields ('25').TYPE      := 'N';
        l_txmsg.txfields ('25').VALUE     := cspks_lnproc.fn_getSEASS(l_afacctno);

        --30   DESC      C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Gia han deal margin';

        --66   FEETYPE      C
        l_txmsg.txfields ('66').defname   := 'FEETYPE';
        l_txmsg.txfields ('66').TYPE      := 'C';
        l_txmsg.txfields ('66').VALUE     := p_feetype;

        --67   FEE      N
        l_txmsg.txfields ('67').defname   := 'FEE';
        l_txmsg.txfields ('67').TYPE      := 'N';
        l_txmsg.txfields ('67').VALUE     := fn_getfeeamt(p_feetype);

        --68   FEEAMT      N
        l_txmsg.txfields ('68').defname   := 'FEEAMT';
        l_txmsg.txfields ('68').TYPE      := 'N';
        l_txmsg.txfields ('68').VALUE     := FN_GETFEE_EX5574_NEW( l_custodycd ,p_feetype, l_lnprinamt);

        --47   VAT      N
        l_txmsg.txfields ('47').defname   := 'VAT';
        l_txmsg.txfields ('47').TYPE      := 'N';
        l_txmsg.txfields ('47').VALUE     := FN_GETVAT_EX5574_NEW( FN_GETFEE_EX5574_NEW( l_custodycd ,p_feetype, l_lnprinamt) ,p_feetype, l_lnprinamt);

        --70   BALDEFOVD      N
        l_txmsg.txfields ('70').defname   := 'BALDEFOVD';
        l_txmsg.txfields ('70').TYPE      := 'N';
        l_txmsg.txfields ('70').VALUE     := l_Baldefovd;

        --71   ADDAMT      N
        l_txmsg.txfields ('71').defname   := 'ADDAMT';
        l_txmsg.txfields ('71').TYPE      := 'N';
        l_txmsg.txfields ('71').VALUE     := GREATEST(FN_GETFEE_EX5574(p_feetype, l_lnprinamt)+l_lnintamt-l_Baldefovd,0);

        --90   OVERDUEDATE      D
        l_txmsg.txfields ('90').defname   := 'OVERDUEDATE';
        l_txmsg.txfields ('90').TYPE      := 'D';
        l_txmsg.txfields ('90').VALUE     := l_overduedate;

        --91   RLSDATE      D
        l_txmsg.txfields ('91').defname   := 'RLSDATE';
        l_txmsg.txfields ('91').TYPE      := 'D';
        l_txmsg.txfields ('91').VALUE     := l_rlsdate;

        --92   RLSDATE      C
        l_txmsg.txfields ('92').defname   := 'PRINPERIOD';
        l_txmsg.txfields ('92').TYPE      := 'C';
        l_txmsg.txfields ('92').VALUE     := '0';

        --93   BEGINDATE      D
        l_txmsg.txfields ('93').defname   := 'BEGINDATE';
        l_txmsg.txfields ('93').TYPE      := 'D';
        l_txmsg.txfields ('93').VALUE     := l_begindate;

        --94   EXTIMES      N
        l_txmsg.txfields ('94').defname   := 'BEGINDATE';
        l_txmsg.txfields ('94').TYPE      := 'N';
        l_txmsg.txfields ('94').VALUE     := l_extimes;

        IF l_begindate > getcurrdate THEN
         p_err_code:='-100197';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_ExtendMarginDeal');
        return;
        END IF;

        BEGIN
        IF txpks_#5574.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 5574: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, l_logStr||' Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_ExtendMarginDeal');
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_ExtendMarginDeal');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, l_logStr || ' got error on pr_ExtendMarginDeal');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx,l_logStr || ' '|| sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_ExtendMarginDeal');
      RAISE errnums.E_SYSTEM_ERROR;

END pr_ExtendMarginDeal;

PROCEDURE pr_OpenContract
    (ID /*P_ID*/ IN NUMBER,
Area /*P_AREA*/ IN VARCHAR2,
AccountName /*P_FULLNAME*/ IN VARCHAR2,
Sex /*P_SEX*/ IN VARCHAR2,
DateOfBirth /*P_DATEOFBIRTH*/ IN VARCHAR2,
PlaceOfBirth /*P_BIRTHPLACE*/ IN VARCHAR2,
RegistrationNumber /*P_IDCODE*/ IN VARCHAR2,
DateOfIssue  /*P_IDDATE*/ IN VARCHAR2,
PlaceOfIssue /*P_IDPLACE*/ IN VARCHAR2,
PermanentAddress /*P_ADDRESS*/ IN VARCHAR2,
MailingAddress /*P_RECEIVEADDRESS*/ IN VARCHAR2,
PhoneNo /*P_PHONE*/ IN VARCHAR2,
Email  /*P_EMAIL*/ IN VARCHAR2,
VcbAccountNo  /*P_VCBACCOUNT*/ IN VARCHAR2,
TaxNo /*P_TAXNUMBER*/ IN VARCHAR2,
CompanyInfo /*P_PLACEOFWORK*/ IN VARCHAR2,
Position /*P_POSITION*/ IN VARCHAR2,
Industry /*P_TYPEOFWORK*/ IN VARCHAR2,
SpouseName /*P_PARTNERNAME*/ IN VARCHAR2,
SpousePosition /*P_PARTNERPOS*/ IN VARCHAR2,
SpouseIndustry /*P_PARTNERWORK*/ IN VARCHAR2,
SpouseMobileNo /*P_PARTNERPHONE*/ IN VARCHAR2,
Reg_Internet /*P_ISONLTRADE*/ IN VARCHAR2,
Reg_Phone /*P_ISTELTRADE*/ IN VARCHAR2,
Reg_Sms /*P_ISMATCHSMS*/ IN VARCHAR2,
Reg_Info /*P_ISOTHERSMS*/ IN VARCHAR2,
Reg_Email /*P_ISNEWSEMAIL*/ IN VARCHAR2,
Target_Income /*P_INCOMECUST*/ IN NUMBER,
Target_LongGrowth /*P_LONGTERM*/ IN NUMBER,
Target_MediumGrowth /*P_MIDTERM*/ IN NUMBER,
Target_ShortGrowth /*P_SHORTTERM*/ IN NUMBER,
Risk_Low /*P_LOWRISK*/ IN NUMBER,
Risk_Average /*P_MIDRISK*/ IN NUMBER,
Risk_High /*P_HIGHRISK*/ IN NUMBER,
Asset_Income /*P_INVINCOME*/ IN NUMBER,
Asset_Spouse  /*P_INCOMEPARTNER*/ IN NUMBER,
Invest_Knowledge /*P_INVESTKNOW*/ IN NUMBER,
Invest_Experience /*P_SECINV*/ IN VARCHAR2,
CompanyNameOfManager /*P_COMPCUSTMAN*/ IN VARCHAR2,
CompanyNameOfHolding5Percent /*P_COMPCUSTCAP*/ IN VARCHAR2,
CommissionAccount /*P_ISAUTHACC*/ IN NUMBER,
CommissionName /*P_AUTHNAME*/ IN VARCHAR2,
CommissionMobile /*P_AUTHTEL*/ IN VARCHAR2,
OtherSecuritiesAccountNo /*P_OTHERACCOUNT*/ IN VARCHAR2,
VCBSRelation /*P_RELATIVE*/ IN VARCHAR2,
CreatedBy /*P_TLID*/ IN VARCHAR2,
CreatedDate /*P_OPNDATE*/ IN VARCHAR2,
UpdatedBy /*P_UPDATEBY*/ IN VARCHAR2,
UpdatedDate /*P_UPDATEDATE*/ IN VARCHAR2,
IsDeleted /*P_ISDELETED*/ IN VARCHAR2,
DeletedBy /*P_DELETEDBY*/ IN VARCHAR2,
DeletedDate /*P_DELETEDDATE*/ IN VARCHAR2,
FATCA_Answers /*P_FATCAANS*/ IN VARCHAR2,
Reg_GdMuKyQuyCnTienBanCK  /*P_ISMARGINTRF*/ IN VARCHAR2,
FolderNo /*p_FolderNo*/ in varchar2,
MobileNo /*P_MOBILE*/ IN VARCHAR2,
     p_err_code out varchar2,
     p_err_message out VARCHAR2
     )
IS
    v_check number;
        V_COUNT NUMBER;
BEGIN
    p_err_code:=0;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    v_check:=0;

    SELECT COUNT(1) INTO V_COUNT FROM CFMAST WHERE UPPER(IDCODE) = UPPER(TRIM(FOLDERNO)) AND STATUS <> 'C';

    SELECT COUNT(1) INTO V_CHECK FROM CFMASTTEMP WHERE UPPER(IDCODE) = UPPER(TRIM(FOLDERNO)) AND STATUS in ('A','R');

    IF V_CHECK > 0 THEN
        INSERT INTO CFMASTTEMP_HIST (SELECT * FROM CFMASTTEMP  WHERE UPPER(IDCODE) = UPPER(TRIM(FOLDERNO)) AND STATUS IN ('A','R'));
        DELETE FROM CFMASTTEMP  WHERE UPPER(IDCODE) = UPPER(TRIM(FOLDERNO)) AND STATUS IN ('A','R');
    END IF;
    V_CHECK := 0;

    SELECT COUNT(1) INTO V_CHECK FROM CFMASTTEMP WHERE UPPER(IDCODE) = UPPER(TRIM(FOLDERNO));

    If v_check =0  AND V_COUNT = 0 then
    --kh trong nuoc, thuong
        insert into CFMASTTEMP (ID,AREA,FULLNAME,SEX,DATEOFBIRTH,BIRTHPLACE,IDCODE,IDDATE,
        IDPLACE,ADDRESS,RECEIVEADDRESS,MOBILE,PHONE,EMAIL,VCBACCOUNT,TAXNUMBER,PLACEOFWORK,POSITION,
        TYPEOFWORK,PARTNERNAME,PARTNERPOS,PARTNERWORK,PARTNERPHONE,ISONLTRADE,ISTELTRADE,ISMATCHSMS,
        ISOTHERSMS,ISNEWSEMAIL,INCOMECUST,LONGTERM,MIDTERM,SHORTTERM,LOWRISK,MIDRISK,HIGHRISK,INVINCOME,
        INCOMEPARTNER,INVESTKNOW,SECINV,COMPCUSTMAN,COMPCUSTCAP,ISAUTHACC,AUTHNAME,AUTHTEL
        ,OTHERACCOUNT,RELATIVE,TLID,OPNDATE,UPDATEBY,UPDATEDATE,ISDELETED,DELETEDBY,DELETEDDATE, FATCAANS,ISMARGINTRF, status, custtype, grinvestor, via
        )
        values (SEQ_CFMASTTEMP.NEXTVAL,Area,AccountName,Sex,DateOfBirth,PlaceOfBirth,FolderNo,DateOfIssue,
        PlaceOfIssue,PermanentAddress,MailingAddress,MobileNo,PhoneNo,Email,VcbAccountNo,TaxNo,CompanyInfo,Position,
        Industry,SpouseName,SpousePosition,SpouseIndustry,SpouseMobileNo,Reg_Internet,Reg_Phone,Reg_Sms,
        Reg_Info,Reg_Email,Target_Income,Target_LongGrowth,Target_MediumGrowth,Target_ShortGrowth,Risk_Low,Risk_Average,Risk_High,Asset_Income,
        Asset_Spouse,Invest_Knowledge,Invest_Experience,CompanyNameOfManager,CompanyNameOfHolding5Percent,CommissionAccount,CommissionName,CommissionMobile,
        OtherSecuritiesAccountNo,VCBSRelation,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate,IsDeleted,DeletedBy,DeletedDate,FATCA_Answers,
        Reg_GdMuKyQuyCnTienBanCK,'P','I','001','O');

        /*
        values (SEQ_CFMASTTEMP.NEXTVAL,P_AREA,P_FULLNAME,P_SEX,TO_DATE(P_DATEOFBIRTH,'DD/MM/RRRR'),P_BIRTHPLACE,p_FolderNo,TO_DATE(P_IDDATE,'DD/MM/RRRR'),
        P_IDPLACE,P_ADDRESS,P_RECEIVEADDRESS,P_MOBILE,P_PHONE,P_EMAIL,P_VCBACCOUNT,P_TAXNUMBER,P_PLACEOFWORK,P_POSITION,
        P_TYPEOFWORK,P_PARTNERNAME,P_PARTNERPOS,P_PARTNERWORK,P_PARTNERPHONE,P_ISONLTRADE,P_ISTELTRADE,P_ISMATCHSMS,
        P_ISOTHERSMS,P_ISNEWSEMAIL,P_INCOMECUST,P_LONGTERM,P_MIDTERM,P_SHORTTERM,P_LOWRISK,P_MIDRISK,P_HIGHRISK,P_INVINCOME,
        P_INCOMEPARTNER,P_INVESTKNOW,P_SECINV,P_COMPCUSTMAN,P_COMPCUSTCAP,P_ISAUTHACC,P_AUTHNAME,P_AUTHTEL,
        P_OTHERACCOUNT,P_RELATIVE,P_TLID,TO_DATE(P_OPNDATE,'DD/MM/RRRR'),P_UPDATEBY,P_UPDATEDATE,P_ISDELETED,P_DELETEDBY,P_DELETEDDATE,P_FATCAANS,P_ISMARGINTRF);
        */

    Else
        p_err_code:=1;
        p_err_message:='Trung CMT';
    End if;

EXCEPTION
WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_OpenContract');
END pr_OpenContract;

PROCEDURE pr_change_order_ntot
  (p_orderid IN VARCHAR2,
  p_toafacctno IN VARCHAR2,
  p_err_code  OUT varchar2,
  p_err_message  OUT varchar2,
  --Log thong tin thiet bi
  p_ipaddress        IN     VARCHAR2 DEFAULT '',                 --1.0.6.0
  p_via              IN     VARCHAR2 DEFAULT '',
  p_validationtype   IN     VARCHAR2 DEFAULT '',
  p_devicetype       IN     VARCHAR2 DEFAULT '',
  p_device           IN     VARCHAR2 DEFAULT ''
  --End
  )
  IS
  l_txmsg       tx.msg_rectype;
  v_strCURRDATE                  varchar2(20);
  l_err_param                    varchar2(300);
  l_ORDERID                      varchar2(20);
  l_CUSTODYCD                    varchar2(20);
  l_AFACCTNO                     varchar2(20);
  l_SEACCTNO                     varchar2(20);
  l_FULLNAME                     varchar2(200);
  l_IDCODE                       varchar2(20);
  l_TXDATE                       date;
  l_CLEARDATE                    date;
  l_CODEID                       varchar2(20);
  l_ORDERQTTY                    number;
  l_QUOTEPRICE                   number;
  l_MATCHQTTY                    number;
  l_MATCHAMT                     number;
  l_AFACCTNOCR                   varchar2(20);
  l_SEACCTNOCR                   varchar2(20);
  l_DESC                         varchar2(300);
  l_OrgDesc                      varchar2(300);
  l_logStr                       VARCHAR2(1000);
  L_STARTTIME                    NUMBER(10);
  L_ENDTIME                     NUMBER(10);
  L_CURRTIME                    NUMBER(10);
  l_count                       NUMBER(10);
  l_sectype                    varchar2(300);
  l_custid                     varchar2(300);
  v_refcursor                   pkg_report.ref_cursor;
  l_input                      VARCHAR2 (2500);
  BEGIN
    plog.setbeginsection(pkgctx, 'Pr_Change_Order_NtoT');

        SELECT TXDESC into l_OrgDesc FROM  TLTX WHERE TLTXCD='8830';

        -- Check host 1 active or inactive
        p_err_code := fn_CheckActiveSystem;
        IF p_err_code <> systemnums.C_SUCCESS THEN
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, l_logStr||' Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'Pr_Change_Order_NtoT');
            return;
        END IF;
        -- End: Check host 1 active or inactive


    BEGIN
        select TO_NUMBER(varvalue) INTO L_STARTTIME
        from sysvar where VARNAME = 'ONLINESTARTEXTENDMRDEAL';
        SELECT TO_NUMBER(varvalue) INTO L_ENDTIME
        from sysvar where VARNAME = 'ONLINEENDEXTENDMRDEAL';
    EXCEPTION WHEN OTHERS THEN
        L_STARTTIME := 80000;
        L_ENDTIME := 170000;
    END ;

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO L_CURRTIME
    FROM DUAL;

/*    if (NOT (L_CURRTIME >= L_STARTTIME and L_CURRTIME <= L_ENDTIME) ) then
        p_err_code := '-994458';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, l_logStr||' Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    end if;*/

  SELECT TO_CHAR(getcurrdate)
                   INTO v_strCURRDATE
        FROM DUAL;
        l_txmsg.msgtype     :='T';
        l_txmsg.local       :='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.busdate     :=to_date(v_strCURRDATE,systemnums.c_date_format);
        l_txmsg.tltxcd      :='8830';

        --Set txnum
        SELECT systemnums.C_OL_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        --l_txmsg.brid        := substr(p_afacctno,1,4);

        --Lay thong tin deal
       SELECT  cf.custodycd, af.acctno afacctno,cf.fullname, cf.idcode,sts.amt MATCHAMT, sts.qtty MATCHQTTY, sts.txdate,sts1.cleardate,
            od.orderid,sts.codeid,od.ORDERQTTY,od.QUOTEPRICE,STS1.ACCTNO SEACCTNO
              INTO
            l_CUSTODYCD, l_AFACCTNO,l_FULLNAME, l_IDCODE,l_MATCHAMT,l_MATCHQTTY,l_TXDATE,l_CLEARDATE,l_ORDERID,l_CODEID, l_ORDERQTTY,
            l_QUOTEPRICE,l_SEACCTNO
            FROM stschd sts, stschd sts1,afmast af, cfmast cf,sbsecurities sb,
                 odmast od , aftype aft,mrtype mr

            where sts.orgorderid = sts1.orgorderid
            and sts.afacctno = af.acctno
            and af.custid = cf.custid
            and sts.codeid = sb.codeid
            and af.actype = aft.actype
            and aft.mrtype = mr.actype
            AND sts.duetype='SM' AND sts.deltd<>'Y' AND STS.STATUS ='C'
            AND sts1.duetype='RS' AND sts1.deltd<>'Y' AND STS1.STATUS ='N'
            and mr.mrtype = 'N'
            and od.orderid = sts.orgorderid
            AND od.orderid = p_orderid ;


            SELECT COUNT(*) INTO l_count
    FROM semast WHERE acctno= p_toafacctno||l_codeid;
     IF l_count  = 0 THEN
        BEGIN
             SELECT b.setype,a.custid
             INTO l_sectype,l_custid
             FROM AFMAST A, aftype B
             WHERE  A.actype= B.actype
             AND a.ACCTNO = l_afacctno;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
         END;
         INSERT INTO SEMAST
         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
         VALUES(
         l_sectype, l_custid, p_toafacctno||l_codeid,l_codeid,p_toafacctno,
        to_date(v_strCURRDATE,systemnums.c_date_format),to_date(v_strCURRDATE,systemnums.c_date_format),
        to_date(v_strCURRDATE,systemnums.c_date_format),to_date(v_strCURRDATE,systemnums.c_date_format),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
        END if;
 COMMIT;


        --set cac field giao dich
         --01   ORDERID      C
        l_txmsg.txfields ('01').defname   := 'ORDERID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := p_orderid;

        --02   CUSTODYCD      C
        l_txmsg.txfields ('02').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := l_CUSTODYCD;

        --03   AFACCTNO      C
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := l_AFACCTNO;

        --05   SEACCTNO      C
        l_txmsg.txfields ('05').defname   := 'SEACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := l_SEACCTNO;

        --90   FULLNAME      C
        l_txmsg.txfields ('90').defname   := 'FULLNAME';
        l_txmsg.txfields ('90').TYPE      := 'C';
        l_txmsg.txfields ('90').VALUE     := l_FULLNAME;

        --34   IDCODE      C
        l_txmsg.txfields ('34').defname   := 'IDCODE';
        l_txmsg.txfields ('34').TYPE      := 'C';
        l_txmsg.txfields ('34').VALUE     := l_IDCODE;

        --08   TXDATE      D
        l_txmsg.txfields ('08').defname   := 'TXDATE';
        l_txmsg.txfields ('08').TYPE      := 'D';
        l_txmsg.txfields ('08').VALUE     := l_TXDATE;

       --08   CLEARDATE      D
        l_txmsg.txfields ('09').defname   := 'CLEARDATE';
        l_txmsg.txfields ('09').TYPE      := 'D';
        l_txmsg.txfields ('09').VALUE     := l_CLEARDATE;

        --07   CODEID      C
        l_txmsg.txfields ('07').defname   := 'CODEID';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := l_CODEID;

        --10   ORDERQTTY      N
        l_txmsg.txfields ('10').defname   := 'ORDERQTTY';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := l_ORDERQTTY;

        --11   QUOTEPRICE      N
        l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := l_QUOTEPRICE;

      --12   MATCHQTTY      N
        l_txmsg.txfields ('12').defname   := 'MATCHQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := l_MATCHQTTY;

     --14   MATCHAMT      N
        l_txmsg.txfields ('14').defname   := 'MATCHAMT';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := l_MATCHAMT;

        --13   AFACCTNOCR      C
        l_txmsg.txfields ('13').defname   := 'AFACCTNOCR';
        l_txmsg.txfields ('13').TYPE      := 'C';
        l_txmsg.txfields ('13').VALUE     := p_toafacctno;

 --15   AFACCTNOCR      C
        l_txmsg.txfields ('15').defname   := 'AFACCTNOCR';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := p_toafacctno||l_CODEID;


        --30   DESC    C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := l_OrgDesc ;

        BEGIN
        IF txpks_#8830.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 8830: ' || p_err_code
           );
           ROLLBACK;
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, l_logStr||' Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_change_order_ntot');
           RETURN;
        END IF;
    END;
      --1.0.6.0
      --TrungNQ: log thong tin thiet bi
      OPEN v_refcursor FOR
         SELECT p_orderid orderid,
                p_toafacctno toafacctno,
                p_ipaddress ipAddress,
                p_via via,
                p_validationtype validationtype,
                p_devicetype devicetype,
                p_device device
           FROM DUAL;

      l_input := FN_GETINPUT (v_refcursor);

      pr_insertiplog (l_txmsg.txnum,
                      l_txmsg.txdate,
                      p_ipaddress,
                      p_via,
                      p_validationtype,
                      p_devicetype,
                      p_device,
                      NULL,
                      l_input);
      --END
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_change_order_ntot');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.error (pkgctx, l_logStr || ' got error on pr_change_order_ntot');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx,l_logStr || ' '|| sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_change_order_ntot');
      RAISE errnums.E_SYSTEM_ERROR;

END pr_change_order_ntot;
PROCEDURE pr_UpdateContract
    (ID /*P_ID*/ IN NUMBER,
Area /*P_AREA*/ IN VARCHAR2,
AccountName /*P_FULLNAME*/ IN VARCHAR2,
Sex /*P_SEX*/ IN VARCHAR2,
DateOfBirth /*P_DATEOFBIRTH*/ IN VARCHAR2,
PlaceOfBirth /*P_BIRTHPLACE*/ IN VARCHAR2,
RegistrationNumber /*P_IDCODE*/ IN VARCHAR2,
DateOfIssue  /*P_IDDATE*/ IN VARCHAR2,
PlaceOfIssue /*P_IDPLACE*/ IN VARCHAR2,
PermanentAddress /*P_ADDRESS*/ IN VARCHAR2,
MailingAddress /*P_RECEIVEADDRESS*/ IN VARCHAR2,
PhoneNo /*P_PHONE*/ IN VARCHAR2,
Email  /*P_EMAIL*/ IN VARCHAR2,
VcbAccountNo  /*P_VCBACCOUNT*/ IN VARCHAR2,
TaxNo /*P_TAXNUMBER*/ IN VARCHAR2,
CompanyInfo /*P_PLACEOFWORK*/ IN VARCHAR2,
Position /*P_POSITION*/ IN VARCHAR2,
Industry /*P_TYPEOFWORK*/ IN VARCHAR2,
SpouseName /*P_PARTNERNAME*/ IN VARCHAR2,
SpousePosition /*P_PARTNERPOS*/ IN VARCHAR2,
SpouseIndustry /*P_PARTNERWORK*/ IN VARCHAR2,
SpouseMobileNo /*P_PARTNERPHONE*/ IN VARCHAR2,
Reg_Internet /*P_ISONLTRADE*/ IN VARCHAR2,
Reg_Phone /*P_ISTELTRADE*/ IN VARCHAR2,
Reg_Sms /*P_ISMATCHSMS*/ IN VARCHAR2,
Reg_Info /*P_ISOTHERSMS*/ IN VARCHAR2,
Reg_Email /*P_ISNEWSEMAIL*/ IN VARCHAR2,
Target_Income /*P_INCOMECUST*/ IN NUMBER,
Target_LongGrowth /*P_LONGTERM*/ IN NUMBER,
Target_MediumGrowth /*P_MIDTERM*/ IN NUMBER,
Target_ShortGrowth /*P_SHORTTERM*/ IN NUMBER,
Risk_Low /*P_LOWRISK*/ IN NUMBER,
Risk_Average /*P_MIDRISK*/ IN NUMBER,
Risk_High /*P_HIGHRISK*/ IN NUMBER,
Asset_Income /*P_INVINCOME*/ IN NUMBER,
Asset_Spouse  /*P_INCOMEPARTNER*/ IN NUMBER,
Invest_Knowledge /*P_INVESTKNOW*/ IN NUMBER,
Invest_Experience /*P_SECINV*/ IN VARCHAR2,
CompanyNameOfManager /*P_COMPCUSTMAN*/ IN VARCHAR2,
CompanyNameOfHolding5Percent /*P_COMPCUSTCAP*/ IN VARCHAR2,
CommissionAccount /*P_ISAUTHACC*/ IN NUMBER,
CommissionName /*P_AUTHNAME*/ IN VARCHAR2,
CommissionMobile /*P_AUTHTEL*/ IN VARCHAR2,
OtherSecuritiesAccountNo /*P_OTHERACCOUNT*/ IN VARCHAR2,
VCBSRelation /*P_RELATIVE*/ IN VARCHAR2,
CreatedBy /*P_TLID*/ IN VARCHAR2,
CreatedDate /*P_OPNDATE*/ IN VARCHAR2,
UpdatedBy /*P_UPDATEBY*/ IN VARCHAR2,
UpdatedDate /*P_UPDATEDATE*/ IN VARCHAR2,
IsDeleted /*P_ISDELETED*/ IN VARCHAR2,
DeletedBy /*P_DELETEDBY*/ IN VARCHAR2,
DeletedDate /*P_DELETEDDATE*/ IN VARCHAR2,
FATCA_Answers /*P_FATCAANS*/ IN VARCHAR2,
Reg_GdMuKyQuyCnTienBanCK  /*P_ISMARGINTRF*/ IN VARCHAR2,
FolderNo /*p_FolderNo*/ in varchar2,
MobileNo /*P_MOBILE*/ IN VARCHAR2,
     p_err_code out varchar2,
     p_err_message out VARCHAR2
     )
IS
    v_check number;
    P_ID  NUMBER;
    P_AREA  VARCHAR2(6);
    p_FolderNo  varchar2(50);
    P_FULLNAME  VARCHAR2(200);
    P_SEX  VARCHAR2(3);
    P_DATEOFBIRTH  VARCHAR2(10);
    P_BIRTHPLACE  VARCHAR2(100);
    P_IDCODE  VARCHAR2(50);
    P_IDDATE  VARCHAR2(10);
    P_IDPLACE  VARCHAR2(50);
    P_ADDRESS  VARCHAR2(200);
    P_RECEIVEADDRESS  VARCHAR2(1000);
    P_MOBILE  VARCHAR2(50);
    P_PHONE  VARCHAR2(50);
    P_EMAIL  VARCHAR2(50);
    P_VCBACCOUNT  VARCHAR2(50);
    P_TAXNUMBER  VARCHAR2(50);
    P_PLACEOFWORK  VARCHAR2(1000);
    P_POSITION  VARCHAR2(50);
    P_TYPEOFWORK  VARCHAR2(50);
    P_PARTNERNAME  VARCHAR2(50);
    P_PARTNERPOS  VARCHAR2(50);
    P_PARTNERWORK  VARCHAR2(50);
    P_PARTNERPHONE  VARCHAR2(50);
    P_ISONLTRADE  VARCHAR2(1);
    P_ISTELTRADE  VARCHAR2(1);
    P_ISMATCHSMS  VARCHAR2(1);
    P_ISOTHERSMS  VARCHAR2(1);
    P_ISNEWSEMAIL  VARCHAR2(1);
    P_INCOMECUST  NUMBER;
    P_LONGTERM  NUMBER;
    P_MIDTERM  NUMBER;
    P_SHORTTERM  NUMBER;
    P_LOWRISK  NUMBER;
    P_MIDRISK  NUMBER;
    P_HIGHRISK  NUMBER;
    P_INVINCOME  NUMBER;
    P_INCOMEPARTNER  NUMBER;
    P_INVESTKNOW  NUMBER;
    P_SECINV  VARCHAR2(7);
    P_COMPCUSTMAN  VARCHAR2(200);
    P_COMPCUSTCAP  VARCHAR2(200);
    P_ISAUTHACC  NUMBER(1);
    P_AUTHNAME  VARCHAR2(100);
    P_AUTHTEL  VARCHAR2(50);
    P_OTHERACCOUNT  VARCHAR2(50);
    P_RELATIVE  VARCHAR2(50);
    P_TLID  VARCHAR2(4);
    P_OPNDATE  VARCHAR2(10);
    P_UPDATEBY  VARCHAR2(4);
    P_UPDATEDATE  VARCHAR2(10);
    P_ISDELETED  VARCHAR2(1);
    P_DELETEDBY  VARCHAR2(4);
    P_DELETEDDATE  VARCHAR2(10);
    P_FATCAANS  VARCHAR2(14);
    P_ISMARGINTRF  VARCHAR2(1);
BEGIN
    p_err_code:=0;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    v_check:=0;
    ---
     P_ID:= ID ;
P_AREA:=Area  ;
P_FULLNAME:=AccountName  ;
P_SEX:=Sex  ;
P_DATEOFBIRTH:=DateOfBirth  ;
P_BIRTHPLACE:=PlaceOfBirth  ;
P_IDCODE:=RegistrationNumber  ;
P_IDDATE:=DateOfIssue   ;
P_IDPLACE:=PlaceOfIssue  ;
P_ADDRESS:=PermanentAddress  ;
P_RECEIVEADDRESS:=MailingAddress  ;
 P_PHONE:=PhoneNo ;
P_EMAIL:=Email   ;
 P_VCBACCOUNT:=VcbAccountNo  ;
P_TAXNUMBER:=TaxNo  ;
P_PLACEOFWORK:=CompanyInfo  ;
P_POSITION:=Position  ;
P_TYPEOFWORK:=Industry  ;
P_PARTNERNAME:=SpouseName  ;
P_PARTNERPOS:=SpousePosition  ;
P_PARTNERWORK:=SpouseIndustry  ;
P_PARTNERPHONE:=SpouseMobileNo  ;
P_ISONLTRADE:=Reg_Internet  ;
P_ISTELTRADE:=Reg_Phone  ;
P_ISMATCHSMS:=Reg_Sms  ;
P_ISOTHERSMS:=Reg_Info  ;
P_ISNEWSEMAIL:=Reg_Email  ;
P_INCOMECUST:=Target_Income  ;
P_LONGTERM:=Target_LongGrowth  ;
P_MIDTERM:=Target_MediumGrowth  ;
P_SHORTTERM:=Target_ShortGrowth  ;
P_LOWRISK:=Risk_Low  ;
P_MIDRISK:=Risk_Average  ;
P_HIGHRISK:=Risk_High  ;
P_INVINCOME:=Asset_Income  ;
P_INCOMEPARTNER:=Asset_Spouse   ;
P_INVESTKNOW:=Invest_Knowledge  ;
P_SECINV:=Invest_Experience  ;
P_COMPCUSTMAN:=CompanyNameOfManager  ;
 P_COMPCUSTCAP:=CompanyNameOfHolding5Percent ;
P_ISAUTHACC:=CommissionAccount  ;
P_AUTHNAME:=CommissionName  ;
P_AUTHTEL:=CommissionMobile  ;
P_OTHERACCOUNT:=OtherSecuritiesAccountNo  ;
P_RELATIVE:=VCBSRelation  ;
P_TLID:=CreatedBy  ;
P_OPNDATE:=CreatedDate  ;
P_UPDATEBY:=UpdatedBy  ;
P_UPDATEDATE:=UpdatedDate  ;
P_ISDELETED:=IsDeleted  ;
P_DELETEDBY:=DeletedBy  ;
P_DELETEDDATE:=DeletedDate  ;
P_FATCAANS:=FATCA_Answers  ;
P_ISMARGINTRF:=Reg_GdMuKyQuyCnTienBanCK   ;
p_FolderNo:=FolderNo  ;
P_MOBILE:= MobileNo  ;
    ---
    SELECT COUNT(1)
    INTO v_check
    FROM cfmasttemp
    WHERE  idcode = P_IDCODE
    AND mobile = P_MOBILE;
    IF v_check = 0 THEN
        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.setendsection(pkgctx, 'pr_updateContract');
        return;
    END IF;
    --------neu ho so da duoc duyet xong thi khong duoc phep update
    SELECT COUNT(1)
    INTO v_check
    FROM cfmasttemp
    WHERE  idcode = P_IDCODE
    AND mobile = P_MOBILE and status in ('C','A');
    IF v_check <> 0 THEN
        p_err_code := '-1';
        p_err_message:= 'Ho so khach hang da duoc duyet, khong duoc phep sua doi';
        plog.setendsection(pkgctx, 'pr_updateContract');
        return;
    END IF;

        update CFMASTTEMP
        set  AREA  =P_AREA,
        FULLNAME   =P_FULLNAME,
        SEX   =P_SEX,
        DATEOFBIRTH   = TO_DATE(P_DATEOFBIRTH,'DD/MM/RRRR'),
        BIRTHPLACE   = P_BIRTHPLACE,

        IDDATE   = TO_DATE(P_IDDATE,'DD/MM/RRRR'),
        IDPLACE  =P_IDPLACE,
        ADDRESS  =P_ADDRESS,
        RECEIVEADDRESS  =P_RECEIVEADDRESS,

        PHONE  =P_PHONE,
        EMAIL  =P_EMAIL,
        VCBACCOUNT  =P_VCBACCOUNT,
        TAXNUMBER  =P_TAXNUMBER,
        PLACEOFWORK  =P_PLACEOFWORK,
        POSITION  =P_POSITION,
        TYPEOFWORK  =P_TYPEOFWORK,
        PARTNERNAME  =P_PARTNERNAME,
        PARTNERPOS  =P_PARTNERPOS,
        PARTNERWORK  =P_PARTNERWORK,
        PARTNERPHONE  =P_PARTNERPHONE,
        ISONLTRADE  =P_ISONLTRADE,
        ISTELTRADE  =P_ISTELTRADE,
        ISMATCHSMS  =P_ISMATCHSMS,
        ISOTHERSMS  =P_ISOTHERSMS,
        ISNEWSEMAIL  =P_ISNEWSEMAIL,
        INCOMECUST  =P_INCOMECUST,
        LONGTERM  =P_LONGTERM,
        MIDTERM  =P_MIDTERM,
        SHORTTERM  =P_SHORTTERM,
        LOWRISK  =P_LOWRISK,
        MIDRISK  =P_MIDRISK,
        HIGHRISK  =P_HIGHRISK,
        INVINCOME  =P_INVINCOME,
        INCOMEPARTNER  =P_INCOMEPARTNER,
        INVESTKNOW  =P_INVESTKNOW,
        SECINV  =P_SECINV,
        COMPCUSTMAN  =P_COMPCUSTMAN,
        COMPCUSTCAP  =P_COMPCUSTCAP,
        ISAUTHACC  =P_ISAUTHACC,
        AUTHNAME  =P_AUTHNAME,
        AUTHTEL  = P_AUTHTEL,
        OTHERACCOUNT  =P_OTHERACCOUNT,
        RELATIVE  =P_RELATIVE,
        TLID  =P_TLID,
       -- OPNDATE  = TO_DATE(P_OPNDATE,'DD/MM/RRRR'),
        UPDATEBY=  P_UPDATEBY,
        UPDATEDATE   =P_UPDATEDATE,
        ISDELETED  =P_ISDELETED,
        DELETEDBY  =P_DELETEDBY,
        DELETEDDATE  =P_DELETEDDATE,
         FATCAANS  =P_FATCAANS,
         ISMARGINTRF  =P_ISMARGINTRF
         where idcode=p_FolderNo and mobile= P_MOBILE;


EXCEPTION
WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_updateContract');
END pr_updateContract;

PROCEDURE pr_GetContract
    (p_REF_CURSOR IN OUT PKG_REPORT.REF_CURSOR,
     FolderNo IN VARCHAR2,
      MobileNo IN VARCHAR2
     )
    IS
BEGIN
     OPEN p_REF_CURSOR FOR
     --map du lieu vao va ra
     select   ID,AREA,FULLNAME AccountName ,SEX,DATEOFBIRTH,BIRTHPLACE PlaceOfBirth,IDCODE FolderNo,IDDATE DateOfIssue,
        IDPLACE PlaceOfIssue,ADDRESS PermanentAddress,RECEIVEADDRESS MailingAddress,MOBILE MobileNo,PHONE PhoneNo,EMAIL Email,
        VCBACCOUNT VcbAccountNo,TAXNUMBER TaxNo,PLACEOFWORK CompanyInfo,POSITION Position,
        TYPEOFWORK Industry,PARTNERNAME SpouseName ,PARTNERPOS SpousePosition,PARTNERWORK SpouseIndustry,PARTNERPHONE SpouseMobileNo,ISONLTRADE Reg_Internet,
        ISTELTRADE Reg_Phone,ISMATCHSMS Reg_Sms,
        ISOTHERSMS Reg_Info,ISNEWSEMAIL Reg_Email,INCOMECUST Target_Income,LONGTERM Target_LongGrowth,MIDTERM Target_MediumGrowth,SHORTTERM Target_ShortGrowth,
        LOWRISK Risk_Low,MIDRISK Risk_Average,HIGHRISK Risk_High,INVINCOME Asset_Income,
        INCOMEPARTNER Asset_Spouse,INVESTKNOW Invest_Knowledge,SECINV Invest_Experience,COMPCUSTMAN CompanyNameOfManager,COMPCUSTCAP CompanyNameOfHolding5Percent,
        ISAUTHACC CommissionAccount,AUTHNAME CommissionName,AUTHTEL CommissionMobile
        ,OTHERACCOUNT OtherSecuritiesAccountNo,RELATIVE VCBSRelation,TLID CreatedBy,OPNDATE CreatedDate,
        UPDATEBY,UPDATEDATE,ISDELETED,DELETEDBY,DELETEDDATE, FATCAANS FATCA_Answers,ISMARGINTRF Reg_GdMuKyQuyCnTienBanCK--, status, custtype, grinvestor, via
     from cfmasttemp where idcode = folderno and mobile = mobileno;
EXCEPTION
WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetContract');
END pr_GetContract;
PROCEDURE pr_CheckContract
  (FolderNo IN VARCHAR2,
  MobileNo IN VARCHAR2,
  p_err_code out varchar2,
  p_err_message out VARCHAR2
  )
  IS
  l_count       NUMBER;
BEGIN
    p_err_code:=0;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    SELECT COUNT(*)
    INTO l_count
    FROM cfmasttemp
    WHERE  idcode = FolderNo
    AND mobile = MobileNo;
    IF l_count = 0 THEN
        p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    END IF;

EXCEPTION
WHEN OTHERS THEN
      p_err_code := errnums.C_CF_CUSTOM_NOTFOUND;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_OpenContract');
END pr_CheckContract;



PROCEDURE pr_CancelOrderAfterDay (p_orderid IN VARCHAR2,
  p_err_code  OUT varchar2,
  p_err_message  OUT varchar2
  ) IS
    l_CONTROLCODE varchar2(10);
    l_strORGORDERID     varchar2(30);
    l_strCODEID         varchar2(20);
    l_strEXORSTATUS     varchar2(20);
    l_strSYMBOL         varchar2(20);
    l_strCUSTODYCD      varchar2(20);
    l_strCIACCTNO       varchar2(20);
    l_strSEACCTNO       varchar2(30);
    l_strAFACCTNO       varchar2(20);
    l_AVLCANCELQTTY     number(20);
    l_AVLSECUREDAMT     number(20);
    l_PARVALUE          number(20);
    l_EXPRICE           number(20);
    l_strDESC           varchar2(200);
    l_strISMORTAGE      varchar2(10);
    l_strTRADEPLACE     varchar2(10);
    l_strEXECTYPE       varchar2(10);
    v_strCURRDATE       varchar2(20);
    l_txmsg             tx.msg_rectype;
    l_err_param         varchar2(300);
begin
    plog.setbeginsection(pkgctx, 'pr_CancelOrderAfterDay');
    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    END IF;
    -- End: Check host 1 active or inactive

    begin
        SELECT MST.ORDERID, MST.CODEID, CCY.SYMBOL, CCY.PARVALUE, CCY.TRADEPLACE, MST.AFACCTNO, MST.SEACCTNO, MST.CIACCTNO,
             CF.CUSTODYCD,  MST.EXPRICE,
            (CASE WHEN MST.ORDERQTTY-MST.EXECQTTY-MST.ADJUSTQTTY-MST.CANCELQTTY>0 THEN
                MST.ORDERQTTY-MST.EXECQTTY-MST.ADJUSTQTTY-MST.CANCELQTTY ELSE 0 END) AVLCANCELQTTY,
            (CASE WHEN EXECTYPE='NB' OR EXECTYPE='BC' THEN 1 ELSE 0 END)*(CASE WHEN MST.SECUREDAMT-MST.MATCHAMT-MST.RLSSECURED>0
                THEN MST.SECUREDAMT-MST.MATCHAMT-MST.RLSSECURED ELSE 0 END) AVLCANCELAMT,
            (CASE WHEN MST.REMAINQTTY < MST.ORDERQTTY THEN '4' WHEN MST.REMAINQTTY = MST.ORDERQTTY
                THEN '5' ELSE MST.ORSTATUS END) EXORSTATUS,
            (CASE WHEN MST.EXECTYPE='MS' THEN 1 ELSE 0 END) ISMORTAGE, EXECTYPE
        into l_strORGORDERID, l_strCODEID, l_strSYMBOL, l_PARVALUE, l_strTRADEPLACE, l_strAFACCTNO,
            l_strSEACCTNO, l_strCIACCTNO, l_strCUSTODYCD, l_EXPRICE, l_AVLCANCELQTTY, l_AVLSECUREDAMT,
            l_strEXORSTATUS, l_strISMORTAGE, l_strEXECTYPE
        FROM ODMAST MST, AFMAST AF, CFMAST CF, SBSECURITIES CCY, CIMAST CI,SEMAST SE,ALLCODE A0,ALLCODE A1
        WHERE MST.AFACCTNO = AF.ACCTNO And MST.CIACCTNO = CI.ACCTNO AND MST.SEACCTNO = SE.ACCTNO
            AND MST.REMAINQTTY>0 AND MST.DELTD<> 'Y' AND MST.GRPORDER <> 'Y'
            AND AF.CUSTID = CF.CUSTID AND MST.CODEID = CCY.CODEID AND MST.ORDERID = P_ORDERID
            ---AND (CASE WHEN EXECTYPE='NB' OR EXECTYPE='BC' THEN 'B' ELSE 'S' END) = 'S'
            AND MST.ORSTATUS IN ('1', '2', '4')  AND A0.CDTYPE='OD' AND A0.CDNAME='ORSTATUS'
            AND A0.CDVAL=MST.ORSTATUS AND A1.CDTYPE='OD' AND A1.CDNAME='PRICETYPE' AND A1.CDVAL=MST.PRICETYPE
            AND MST.ORDERID NOT IN (SELECT ODMAST.REFORDERID FROM ODMAST,OOD WHERE EXECTYPE IN ('AS','CS') AND ODMAST.ORDERID=OOD.ORGORDERID AND OOD.OODSTATUS  IN ('N','B'));
    EXCEPTION WHEN OTHERS THEN
        l_strORGORDERID := '0000';
    end ;

    --01 Kiem tra xem da het phien Giao dich chua
    --Chi cho phep thuc hien khi da het phien giao dich
    --khi nao chay that thi check
    if to_char(sysdate, 'hh24:mi') <= '15:00' then
        p_err_code :='-700211';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    end if;
    ---end
    --Check phien HO <> 'O,A,P'
    select trim(sysvalue) into l_CONTROLCODE from ordersys where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('P','O','A') and l_strTRADEPLACE = '001' then
        p_err_code :='-700211';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    end if;
    --Check phien HA <> '1'
    select trim(sysvalue) into l_CONTROLCODE from ordersys_ha where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('1')  and l_strTRADEPLACE <> '001' then
        p_err_code :='-700211';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    end if;

    if l_strORGORDERID = '0000' then
        p_err_code :='-700212';
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, p_err_message);
        plog.setendsection(pkgctx, 'pr_CashTransferEndDate');
        return;
    end if;


    SELECT TO_CHAR(getcurrdate) INTO v_strCURRDATE FROM DUAL;
    l_txmsg.msgtype     :='T';
    l_txmsg.local       :='N';
    l_txmsg.tlid        := systemnums.C_ONLINE_USERID;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
        SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
    INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'DAY';
    l_txmsg.txdate      := to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate     := to_date(v_strCURRDATE,systemnums.c_date_format);
    if l_strEXECTYPE = 'NB' then
        l_txmsg.tltxcd      := '8808';
        select TXDESC into l_strDESC from tltx where tltxcd = '8808';
    else
        l_txmsg.tltxcd      := '8807';
        select TXDESC into l_strDESC from tltx where tltxcd = '8808';
    end if;

    --Set txnum
    SELECT systemnums.C_OL_PREFIXED  || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0') INTO l_txmsg.txnum FROM DUAL;
    --l_txmsg.brid        := substr(p_afacctno,1,4);

    --03   ORGORDERID      C;
    l_txmsg.txfields ('03').defname   := 'ORGORDERID';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := l_strORGORDERID;
    --15   EXORSTATUS      C;
    l_txmsg.txfields ('15').defname   := 'EXORSTATUS';
    l_txmsg.txfields ('15').TYPE      := 'C';
    l_txmsg.txfields ('15').VALUE     := l_strEXORSTATUS;
    --80   CODEID      C;
    l_txmsg.txfields ('80').defname   := 'CODEID';
    l_txmsg.txfields ('80').TYPE      := 'C';
    l_txmsg.txfields ('80').VALUE     := l_strCODEID;
    --81   SYMBOL      C;
    l_txmsg.txfields ('81').defname   := 'SYMBOL';
    l_txmsg.txfields ('81').TYPE      := 'C';
    l_txmsg.txfields ('81').VALUE     := l_strSYMBOL;
    --82   CUSTODYCD      C;
    l_txmsg.txfields ('82').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('82').TYPE      := 'C';
    l_txmsg.txfields ('82').VALUE     := l_strCUSTODYCD;
    --05   CIACCTNO      C;
    l_txmsg.txfields ('05').defname   := 'CIACCTNO';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := l_strCIACCTNO;
    --06   SEACCTNO      C;
    l_txmsg.txfields ('06').defname   := 'SEACCTNO';
    l_txmsg.txfields ('06').TYPE      := 'C';
    l_txmsg.txfields ('06').VALUE     := l_strSEACCTNO;
    --07   AFACCTNO      C;
    l_txmsg.txfields ('07').defname   := 'AFACCTNO';
    l_txmsg.txfields ('07').TYPE      := 'C';
    l_txmsg.txfields ('07').VALUE     := l_strAFACCTNO;
    --10   AVLCANCELQTTY      N;
    l_txmsg.txfields ('10').defname   := 'AVLCANCELQTTY';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := l_AVLCANCELQTTY;
    --11   AVLCANCELAMT      N;
    l_txmsg.txfields ('11').defname   := 'AVLCANCELAMT';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := l_AVLSECUREDAMT;
    --12   PARVALUE      N;
    l_txmsg.txfields ('12').defname   := 'PARVALUE';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := l_PARVALUE;
    --13   EXPRICE      N;
    l_txmsg.txfields ('13').defname   := 'EXPRICE';
    l_txmsg.txfields ('13').TYPE      := 'N';
    l_txmsg.txfields ('13').VALUE     := l_EXPRICE;
    --30   DESC      C;
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE     := l_strDESC;

    if l_strEXECTYPE <> 'NB' then
        --60   ISMORTAGE      N;
        l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').VALUE     := l_strISMORTAGE;
    end if;


    BEGIN
        if l_strEXECTYPE = 'NB' then
            IF txpks_#8808.fn_autotxprocess (l_txmsg,p_err_code,l_err_param) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 8808: ' || p_err_code
               );
               ROLLBACK;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, ' Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_CancelOrderAfterDay');
               RETURN;
            END IF;
        else
            IF txpks_#8807.fn_autotxprocess (l_txmsg,p_err_code,l_err_param) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 8807: ' || p_err_code
               );
               ROLLBACK;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, ' Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_CancelOrderAfterDay');
               RETURN;
            END IF;
        end if;
    END;

    p_err_code :=0 ;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    plog.setendsection(pkgctx, 'pr_CancelOrderAfterDay');
EXCEPTION WHEN OTHERS THEN
      plog.error (pkgctx, ' got error on pr_CancelOrderAfterDay');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_CancelOrderAfterDay');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_CancelOrderAfterDay;

  PROCEDURE pr_get_Voucher_balance(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
    pv_custodycd IN VARCHAR2)
  IS
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_get_Voucher_balance');
    OPEN p_REFCURSOR for
        SELECT CF.CUSTODYCD, AF.ACCTNO, MST.AUTOID,  MST.CIAMT  CIAMT, MST.EXPDATE,
            MST.VOUCHERAMT, MST.PRINPAID, MST.VOUCHERAMT-MST.PRINPAID DUEAMT,
            MST.VALDATE,TL.txdesc
            FROM VOUCHERODFEE MST, AFMAST AF, CFMAST CF, vw_tllog_all TL
            WHERE MST.STATUS = 'A' AND MST.AFACCTNO = AF.ACCTNO
            AND AF.CUSTID = CF.CUSTID
            AND cf.custodycd = pv_custodycd
            AND MST.TXNUM = TL.TXNUM
            AND MST.TXDATE = TL.TXDATE
            ;
    plog.setendsection(pkgctx, 'pr_get_Voucher_balance');
  EXCEPTION WHEN OTHERS THEN
        return;
  END pr_get_Voucher_balance;

PROCEDURE pr_CFAFTRDLNK_Update
  (p_afacctno IN VARCHAR2,
  p_adminid IN CHAR,
  p_leaderid IN CHAR,
  p_traderid IN CHAR,
  p_isDelete IN VARCHAR2,
  p_err_code out varchar2,
  p_err_message out VARCHAR2
  )
  IS
  l_grpid   CHAR(4);
  l_tlid    Number;
  l_acctno    Number;
  BEGIN
    l_tlid := 3;
    l_acctno := 1;


    Select Count(*) into l_tlid From
        (Select tlid from tlprofiles where active = 'Y' and tlid = p_adminid
    union all
    Select tlid from tlprofiles where active = 'Y' and tlid = p_leaderid
    union all
    Select tlid from tlprofiles where active = 'Y' and tlid = p_leaderid);


    Select Count(*) into l_acctno from (Select acctno from afmast where acctno  = p_afacctno and ispm = 'Y' and status = 'A');

     if l_tlid = 3  And l_acctno = 1 then
            Select A.grpid into l_grpid from
            (Select grpid from tlgroups where grptype = 2 and BRID = '0001'
                UNION ALL Select grpid from tlgroups where grptype = 2) A
            where rownum <=1;

            if nvl(l_grpid,'') = '' then
               p_err_code := errnums.C_SA_VARIABLE_NOTFOUND;
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            else
                Delete From CFAFTRDLNK Where afacctno = p_afacctno;

                If p_isDelete <> 'Y' then
                    INSERT INTO CFAFTRDLNK
                    VALUES(SEQ_CFAFTRDLNK.NEXTVAL,p_afacctno,l_grpid,p_adminid,p_leaderid,p_traderid,getcurrdate,'PLO','A','PP','P');
                end if;
                Commit;
                p_err_code:=0;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            end if;
     else
          if l_acctno <> 1 then
            p_err_code:=-200012;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
          end if;

          if l_tlid <> 3 then
            p_err_code:=-200091;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
          end if;
     end if;



    EXCEPTION
  WHEN OTHERS
   THEN
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_CFAFTRDLNK_Update');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CFAFTRDLNK_Update;
procedure pr_PlaceOrderMemo(p_tltid in varchar2,
                p_custodycd in varchar2,
                p_afacctno  in varchar2,
                p_symbol in varchar2,
                p_exectype in varchar2,
                p_quantity in number,
                p_quoteprice in number,
                p_err_code out varchar2,
                p_err_message out VARCHAR2
    )
    IS
    l_strcodeid varchar2(20);
    l_TRADEUNIT number(10);
    l_currdate      date;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_PlaceOrderMemo');
    SELECT to_date(varvalue,'dd/mm/rrrr') into l_currdate FROM SYSVAR WHERE VARNAME = 'CURRDATE';
    select max(codeid), max(nvl(tradeunit,1)) into l_strcodeid, l_TRADEUNIT from securities_info where symbol = p_symbol;
    INSERT INTO fomastmemo (AUTOID,CUSTODYCD,AFACCTNO,CODEID,SYMBOL,EXECTYPE,QUANTITY,PRICE,TLID,DELTD,FEEDBACKMSG,STATUS,TXDATE)
    VALUES(seq_fomastmemo.nextval,REPLACE(p_custodycd,'.',''),p_afacctno,l_strcodeid,p_symbol,p_exectype,p_quantity,p_quoteprice,p_tltid,'N',NULL,'A',l_currdate);
    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'pr_PlaceOrderMemo');
  EXCEPTION WHEN OTHERS THEN
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_PlaceOrderMemo');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_PlaceOrderMemo;
procedure pr_PushOrderMemo(p_orderid  in varchar2,
                p_str_message in varchar2,
                p_err_code out varchar2,
                p_err_message out VARCHAR2
    )
    IS
    l_AUTOID        number(20);
    l_strCUSTODYCD  varchar2(20);
    l_strAFACCTNO   varchar2(20);
    l_strCODEID     varchar2(20);
    l_strSYMBOL     varchar2(20);
    l_strEXECTYPE   varchar2(10);
    l_QUANTITY      number(20);
    l_PRICE         number(20);
    l_strSTATUS     varchar2(10);
    l_strtlid       varchar2(10);
    l_currdate      date;
    l_strfeedbackmsg    varchar2(500);
    l_TRADEUNIT     number(20);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_PushOrderMemo');
    if p_str_message = '0' then
        update fomastmemo set feedbackmsg = p_str_message, status = 'C' where AUTOID = p_orderid;
    else
        update fomastmemo set feedbackmsg = cspks_system.fn_get_errmsg(p_str_message), status = 'E' where AUTOID = p_orderid;
    end if;

    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);

    -----p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'pr_PushOrderMemo');
  EXCEPTION WHEN OTHERS THEN
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_PushOrderMemo');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_PushOrderMemo;
procedure pr_CancelOrderMemo(p_orderid  in varchar2,
                p_err_code out varchar2,
                p_err_message out VARCHAR2
    )
    IS
    l_AUTOID        number(20);
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_CancelOrderMemo');

    insert into fomastmemohist value(select * from fomastmemo where AUTOID = p_orderid);
    delete from fomastmemo  where AUTOID = p_orderid;
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);

    -----p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'pr_CancelOrderMemo');
  EXCEPTION WHEN OTHERS THEN
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_CancelOrderMemo');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CancelOrderMemo;

PROCEDURE pr_Details_saving_rate(PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
                                   F_DATE         IN       VARCHAR2,
                                   T_DATE         IN       VARCHAR2,
                                   CUSTODYCD       IN       VARCHAR2,
                                   TLTXCD         IN       VARCHAR2,
                                   ACCTNO         IN       VARCHAR2)
is
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_CUSTODYCD    VARCHAR2 (10);
   V_STRACCTNO      VARCHAR2 (30);
   V_STRTLTXCD      VARCHAR2 (10);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION    VARCHAR2(5);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
    V_STRBRID := '%%';
    -- GET REPORT'S PARAMETERS

   if(upper(CUSTODYCD) <> 'ALL') then
        V_CUSTODYCD :=  CUSTODYCD;
   else
        V_CUSTODYCD := '%';
   end if;

   if(upper(ACCTNO) <> 'ALL') then
        V_STRACCTNO := ACCTNO;
   else
        V_STRACCTNO := '%';
   end if;

   if(upper(TLTXCD) <> 'ALL') then
        V_STRTLTXCD := TLTXCD;
   else
        V_STRTLTXCD := '%';
   end if;

   V_FROMDATE := to_date(F_DATE,'dd/mm/yyyy');
   V_TODATE := to_date(T_DATE,'dd/mm/yyyy');

   -- GET REPORT'S DATA
OPEN PV_REFCURSOR
       FOR

            SELECT opndate, txdate, txnum, tltxcd, acctno, afacctno, fullname,actype, msgamt, frdate, todate,intrate,NAMT,INTAVLAMT,intamt, custodycd,
                    ( case when a.tltxcd = '1600' then
                            (case when txdate < todate and txdate >= frdate then
                                'Tat toan mon HTLS '||acctno||' tra goc va lai ve tai khoan '||afacctno||' lai suat KKH'
                               else 'Tat toan mon HTLS '||acctno||' tra goc va lai ve tai khoan '||afacctno||' lai suat '||currintrate||' %'
                               end)
                           when a.tltxcd = '1610' then
                           (
                               case when autornd = 'Y' then
                                (case when txdate < todate and txdate >=frdate then
                                    'Tat toan mon HTLS '||acctno||' tra lai ve tai khoan '||afacctno||' lai suat KKH'
                                  else  'Tat toan mon HTLS '||acctno||' tra lai ve tai khoan '||afacctno||' lai suat '||currintrate||' %'
                                  end)
                               else
                                 (case when txdate < todate and txdate >=frdate then
                                 'Tat toan mon HTLS '||acctno||' tra goc va lai ve tai khoan '||afacctno||' lai suat KKH'
                                 else  'Tat toan mon HTLS '||acctno||' tra goc va lai ve tai khoan '||afacctno||' lai suat '||currintrate||' %'
                                 end)
                                end
                           )
                           when a.tltxcd = '1620' then
                                'Tat toan mon HTLS '||acctno||' tra goc ve tai khoan '||afacctno
                           when a.tltxcd = '1630' then
                                'Gia han mon HTLS ' ||acctno|| ' , lai suat '||intrate||' %'
                           else  to_char(a.txdesc)
                      end
                    ) txdesc,
                    cdcontent,
                    a.producttype,
                    fn_caltddeposits(acctno, V_TODATE,txnum) tddeposits

            FROM
            (--1670
                select td.txdate, td.txnum, td.tltxcd, td.acctno, td.afacctno, td.fullname, td.custodycd, td.actype, td.msgamt, td.opndate , td.frdate, td.todate,
                       (case when td.schdtype = 'F' then td.intrate else nvl(SCHM.intrate,td.intrate) end) intrate,
                       0 NAMT,
                       (
                            CASE WHEN td.todate > V_TODATE then  round(td.msgamt*(td.todate-td.frdate)*
                            (case when td.schdtype = 'F' then td.intrate  else nvl(SCHM.intrate,td.intrate) end)/(100*360))
                             else 0 end
                       ) INTAVLAMT,
                       0 intamt, td.txdesc txdesc, td.cdcontent, td.autornd,
                       0 currintrate,
                       td.producttype, 0 stt
                from
                    (
                        select tl.txdate, tl.txnum, tl.tltxcd, TD.acctno, td.afacctno, cf.fullname, cf.custodycd,
                               td.actype, tl.msgamt, td.opndate , td.frdate, td.todate, td.intrate, td.tdterm,td.autornd,
                               td.orgamt, td.schdtype, tl.txdesc, (td.tdterm || ' ' || al.cdcontent) cdcontent, aft.producttype
                        from
                            (
                                SELECT * FROM TLLOG WHERE TLTXCD = '1670' and txdate BETWEEN V_FROMDATE and V_TODATE
                                and DELTD <> 'Y' --and tltxcd like V_STRTLTXCD
                                UNION ALL
                                SELECT * FROM TLLOGALL WHERE TLTXCD = '1670' and txdate BETWEEN V_FROMDATE and V_TODATE
                                and DELTD <> 'Y' -- and tltxcd like V_STRTLTXCD
                            ) TL,
                            (
                               select td.txdate, td.txnum, td.acctno, td.afacctno, td.actype, td.autornd,td.orgamt, td.balance , td.opndate, td.frdate,
                                    td.todate, td.intrate , td.tdterm, td.schdtype, td.termcd
                                from
                                (
                                    select tdmast.txdate, tdmast.txnum, tdmast.acctno, tdmast.afacctno, tdmast.actype, tdmast.orgamt, tdmast.balance, tdmast.opndate,tdmast.deltd,
                                        tdmast.frdate, (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                AND SBDATE >= TODATE AND HOLIDAY = 'N') todate, tdmast.intrate, tdmast.tdterm, tdmast.schdtype, tdmast.termcd , tdmast.autornd
                                    from tdmast, cfmast cf, afmast af  where tdmast.acctno like V_STRACCTNO AND cf.custid = af.custid and afacctno = af.acctno AND cf.custodycd like V_CUSTODYCD
                                    union all
                                    select tdmasthist.txdate, tdmasthist.txnum, tdmasthist.acctno, tdmasthist.afacctno, tdmasthist.actype, tdmasthist.orgamt, tdmasthist.balance, tdmasthist.opndate,tdmasthist.deltd,
                                        tdmasthist.frdate, (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                AND SBDATE >= TODATE AND HOLIDAY = 'N') todate, tdmasthist.intrate, tdmasthist.tdterm, tdmasthist.schdtype, tdmasthist.termcd , tdmasthist.autornd
                                    from tdmasthist, cfmast cf, afmast af  where af.custid = cf.custid AND tdmasthist.acctno like V_STRACCTNO and afacctno = af.acctno AND cf.custodycd like V_CUSTODYCD
                                ) td where td.deltd <>'Y' and opndate = frdate
                            ) TD,
                            afmast af,
                            cfmast cf,
                            allcode al,
                            aftype aft
                        where tl.txnum = td.txnum
                            and tl.txdate = td.txdate
                            and td.afacctno = af.acctno
                            and af.custid = cf.custid
                            and td.acctno like V_STRACCTNO
                            and cf.custodycd like V_CUSTODYCD
                            and al.cdtype = 'TD' and al.cdname = 'TERMCD'
                            and td.termcd = al.cdval
                            and af.actype = aft.actype
                            AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )

                            --AND CF.CAREBY IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = V_STRCAREBY)
                    ) td

                left join

                    ( select DISTINCT * from (
                         select tdmstschm.refautoid,  tdmstschm.acctno,  tdmstschm.intrate,  framt ,toamt,  frterm,toterm  ,tdmast.frdate ,
                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                    AND SBDATE >= tdmast.todate AND HOLIDAY = 'N') todate
                        from tdmstschm , tdmast , cfmast cf, afmast af
                        where tdmstschm.acctno = tdmast.acctno AND cf.custid = af.custid
                        and tdmast.acctno like V_STRACCTNO  and tdmast.afacctno = af.acctno AND cf.custodycd like V_CUSTODYCD
                        union all
                        select    tdmstschmhist.refautoid,  tdmstschmhist.acctno,  tdmstschmhist.intrate,  framt ,toamt,  frterm,toterm  ,tdmstschmhist.frdate ,
                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                    AND SBDATE >= tdmstschmhist.todate AND HOLIDAY = 'N') todate
                        from tdmstschmhist
                        where tdmstschmhist.acctno like V_STRACCTNO)
                    )
                            SCHM

                    on td.acctno = SCHM.acctno(+)
                    and td.orgamt >= SCHM.framt(+)
                    and td.orgamt < SCHM.toamt(+)
                    and td.tdterm >= SCHM.FRTERM(+)
                    and td.tdterm < SCHM.toterm(+)
                    and td.txdate >= SCHM.frdate(+)
                    and td.txdate < SCHM.todate(+)


                UNION ALL
            --1600
                    select  td.txdate, td.txnum, td.tltxcd, td.acctno, td.afacctno, td.fullname, td.custodycd,
                            td.actype, org msgamt,td.opndate , td.frdate, td.todate,
                            (case when td.schdtype = 'F' then td.intrate else nvl(SCHM.intrate,td.intrate) end) intrate,
                            TD.namt NAMT, 0 INTAVLAMT, TD.intpaid intamt, td.txdesc, td.cdcontent,td.autornd,
                            (case when td.txdate >= td.todate then
                                       (case when td.schdtype = 'F' then td.intrate else nvl(SCHM.intrate,td.intrate) end)
                                  else 0 end )    currintrate, td.producttype, 2 stt
                    FROM
                    ( SELECT txdate, txnum, tltxcd, txdesc, acctno, afacctno, fullname,
                            custodycd, actype, opndate, min(frdate) frdate, min(todate) todate,
                            intpaid, namt, intrate, orgamt, schdtype, min(tdterm) tdterm, min(cdcontent) cdcontent, autornd, flintrate, minbrterm, termcd,
                            org, producttype
                     FROM

                      (  select tr.txdate, tr.txnum, tr.tltxcd, tr.txdesc, mst.acctno, mst.afacctno, mst.fullname, mst.custodycd,
                              mst.tdtype actype,  mst.opndate , mst.frdate frdate, mst.todate todate,
                              tr.INTPAID intpaid, tr.NAMT namt,   mst.intrate, main.msgamt orgamt,
                              mst.schdtype, mst.tdterm, mst.cdcontent , mst.autornd,mst.flintrate  ,mst.minbrterm,mst.termcd,
                              main.msgamt  - sum(div.namt) org, mst.producttype
                        from
                             (
                                 select td.actype tdtype,-- tl.grpname careby,
                                        td.acctno, af.acctno afacctno, cf.fullname, cf.custodycd, td.opndate,
                                        td.orgamt, td.balance, td.frdate, td.intrate, -- cf.careby carebyid,
                                        td.autornd,td.flintrate,td.minbrterm,td.termcd,
                                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                            AND SBDATE >= td.TODATE AND HOLIDAY = 'N') todate,
                                        (td.tdterm || ' ' || al.cdcontent) cdcontent, cf.careby carebyid,
                                        af.actype aftype, td.schdtype, td.tdterm, aft.producttype
                                  from   (select * from tdmast union select * from tdmasthist) td,
                                          afmast af,
                                          cfmast cf,
                                          allcode al,
                                          aftype aft-- , tlgroups tl
                                 where td.afacctno = af.acctno
                                        and af.custid = cf.custid
                                        and al.cdtype = 'TD' and al.cdname = 'TERMCD'
                                        and td.DELTD <>'Y'
                                        and td.termcd = al.cdval
                                        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                                        and af.actype = aft.actype
                                        --and cf.careby = tl.grpid
                                        --AND cf.careby IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = V_STRCAREBY)
                                        and td.acctno LIKE V_STRACCTNO and cf.custodycd like V_CUSTODYCD
                              )
                              mst,
                              (
                                    SELECT TR.ACCTNO, tr.txdate, tr.txnum,
                                        sum(case when APP.FIELD = 'BALANCE' and (case when tl.tltxcd = '1610' then  app.apptxcd else '0023' end) = '0023'  then (CASE WHEN APP.TXTYPE = 'D' THEN TR.NAMT ELSE -TR.NAMT END)
                                            else 0 end) NAMT,
                                        sum(case when APP.FIELD = 'INTPAID' then (CASE WHEN APP.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                                            else 0 end) INTPAID,
                                        tl.txdesc, tl.tltxcd
                                    FROM (SELECT * FROM TDTRAN UNION ALL SELECT * FROM TDTRANA) TR,
                                        (select * from tllog union all select * from tllogall) tl,
                                        V_APPMAP_BY_TLTXCD APP
                                    WHERE TR.NAMT > 0 AND tr.DELTD <> 'Y'
                                        AND TR.TXNUM = TL.TXNUM
                                        AND TR.TXDATE = TL.TXDATE
                                        AND APP.tltxcd = TL.TLTXCD
                                        AND TR.TXCD = APP.APPTXCD
                                        AND APP.FIELD in ('BALANCE','INTPAID')
                                        AND APP.APPTYPE = 'TD'
                                        AND tr.txdate BETWEEN V_FROMDATE and V_TODATE
                                        --and tl.tltxcd like V_STRTLTXCD
                                        and tr.acctno like V_STRACCTNO
                                    group by TR.ACCTNO, tr.txdate, tr.txnum, tl.txdesc, tl.tltxcd
                                ) TR,
                                --so tien goc ban dau
                                (SELECT tl.msgamt, td.acctno FROM vw_tllog_all tl, tdmast td
                                    WHERE tltxcd = '1670' AND td.txdate = tl.txdate AND td.txnum = tl.txnum AND tl.msgacct = td.afacctno
                                    AND td.acctno like V_STRACCTNO
                                ) main,
                                -- tinh so luong tien thay doi qua tung giao dich
                                (
                                SELECT a.msgacct, a.txdate, a.txnum, a.tltxcd,
                                       CASE WHEN ty.intduecd = 'N' THEN a.namt
                                            ELSE
                                            (
                                            CASE --giao dich 1610 tat toan toan bo hoac nhap lai vao goc, neu balance = 0 thi la nhap lai vao goc
                                                WHEN a.tltxcd = '1610' AND a.namt = 0 THEN -a.INTPAID
                                                WHEN a.tltxcd = '1610' AND a.namt <> 0 THEN a.namt
                                                --giao 1600 lai khong bi tru vao goc nen khong tinh goc
                                                WHEN a.tltxcd = '1600' THEN a.namt
                                            --cac giao dich rut tien khac
                                                ELSE a.NAMT + a.INTPAID
                                                END )
                                                END NAMT
                                FROM  (
                                        SELECT tl.msgacct, tl.txdate, tl.txnum, tl.tltxcd,
                                              sum(case when APP.FIELD = 'BALANCE' and (case when tl.tltxcd = '1610' then  app.apptxcd else '0023' end) = '0023'
                                                then (CASE WHEN APP.TXTYPE = 'D' THEN TRan.NAMT ELSE -TRan.NAMT END)
                                                        else 0 end) NAMT,
                                              sum(case when APP.FIELD = 'INTPAID' then (CASE WHEN APP.TXTYPE = 'D' THEN -TRan.NAMT ELSE TRan.NAMT END)
                                                       else 0 end) INTPAID
                                        FROM vw_tllog_all tl ,(SELECT * FROM tdtran UNION ALL SELECT * FROM tdtrana) tran, v_appmap_by_tltxcd app
                                        WHERE tl.msgacct like V_STRACCTNO
                                        AND tran.txdate = tl.txdate AND tran.txnum = tl.txnum
                                        AND app.apptype = 'TD' AND app.apptxcd = tran.txcd AND app.tltxcd = tl.tltxcd
                                        AND app.field IN ('BALANCE','INTPAID')
                                        GROUP BY tl.msgacct, tl.txdate, tl.txnum, tl.tltxcd
                                        ORDER BY tl.txdate, tl.txnum
                                        ) a, tdmast td, tdtype ty
                                WHERE td.actype = ty.actype AND a.msgacct = td.acctno
                                ) div
                            where mst.acctno = tr.acctno
                                AND main.acctno = tr.acctno
                                AND tr.acctno = div.msgacct
                                and tr.txnum >= (case when tr.txdate = div.txdate then div.txnum
                                                        when tr.txdate <  div.txdate then '9999999999'
                                                    else '0' end )
                                AND CASE --cac giao dich binh thuong
                                        WHEN tr.txdate < mst.todate AND tr.txdate > mst.frdate  THEN 1
                                        WHEN tr.tltxcd = '1610' AND tr.txdate = mst.todate THEN 1
                                       WHEN tr.txdate = mst.todate  THEN CASE WHEN tr.tltxcd = '1620' THEN 1
                                                                              WHEN tr.tltxcd = '1600' THEN 1
                                                                              END
                                       WHEN tr.txdate = mst.frdate AND tr.tltxcd = '1600' AND tr.txnum NOT LIKE '99%' THEN 1

                                       WHEN tr.tltxcd = '1620' AND tr.txdate = mst.frdate THEN 1
                                       ELSE 0 END = 1
                                and mst.acctno like V_STRACCTNO
                                and mst.custodycd like V_CUSTODYCD
                    group BY tr.txdate , tr.txnum, tr.tltxcd, tr.txdesc, mst.acctno, mst.afacctno, mst.fullname, mst.custodycd,
                              mst.tdtype , mst.opndate ,
                              tr.INTPAID , tr.NAMT ,   mst.intrate, mst.frdate , mst.todate,
                              mst.schdtype, mst.tdterm, mst.cdcontent , mst.autornd,mst.flintrate  ,mst.minbrterm,mst.termcd,main.msgamt, mst.producttype
                    )
                    GROUP BY txdate, txnum, tltxcd, txdesc, acctno, afacctno, fullname,
                            custodycd, actype, opndate,
                            intpaid, namt, intrate, orgamt, schdtype,  autornd, flintrate, minbrterm, termcd,
                            org, producttype
                    ORDER BY txdate, txnum
                    ) TD

                    left join

                    ( select DISTINCT * from (
                        select tdmstschm.refautoid,  tdmstschm.acctno,  tdmstschm.intrate,  framt ,toamt,  frterm,toterm  ,tdmast.frdate ,
                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                    AND SBDATE >= tdmast.todate AND HOLIDAY = 'N') todate
                        from tdmstschm , tdmast, cfmast cf, afmast af
                        where tdmstschm.acctno = tdmast.acctno AND cf.custid = af.custid
                        and tdmast.acctno  like V_STRACCTNO and tdmast.afacctno = af.acctno AND cf.custodycd  like V_CUSTODYCD
                        union all
                        select    tdmstschmhist.refautoid,  tdmstschmhist.acctno,  tdmstschmhist.intrate,  framt ,toamt,  frterm,toterm  ,tdmstschmhist.frdate ,
                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                    AND SBDATE >= tdmstschmhist.todate AND HOLIDAY = 'N') todate
                        from tdmstschmhist
                        where tdmstschmhist.acctno like V_STRACCTNO )
                    )  SCHM

                        on td.acctno = SCHM.acctno(+)
                        and td.orgamt >= SCHM.framt(+)
                        and td.orgamt < SCHM.toamt(+)
                        and td.tdterm >= SCHM.FRTERM(+)
                        and td.tdterm < SCHM.toterm(+)
                        and td.txdate > SCHM.frdate(+)
                        and td.txdate <= SCHM.todate(+)



            UNION
            --1630
                SELECT td.txdate, tl.txnum,tltxcd,td.acctno,td.afacctno,fullname, custodycd,td.ACTYPE , msgamt , td.opndate , td.frdate,td.todate,
                       (case when td.schdtype = 'F' then td.intrate else nvl(SCHM.intrate,td.intrate) end) intrate ,
                       --tyintrate intrate,
                       0 namt,
                       (
                         CASE WHEN td.todate > V_TODATE
                         THEN round(msgamt *(td.todate-td.frdate)*
                         --(case when schdtype = 'F' then tdintrate else nvl(intrate1,tdintrate)
                         (case when td.schdtype = 'F' then td.intrate else nvl(SCHM.intrate,td.intrate)
                         end)/(100*360)) ELSE 0 END
                       ) intavlamt,
                       0 intamt,txdesc,
                       (td.tdterm ||' '|| td.cdcontent) cdcontent ,
                       autornd,
                       0 currintrate,
                       td.producttype, 1 stt
                       --,schdtype,tdintrate,intrate1
                FROM
                (
                    SELECT td.* , tdroot.intrate , tdroot.tdterm , tdroot.opndate ,
                           (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= ( td.frdate + tdroot.tdterm)   AND HOLIDAY = 'N')  todate
                    FROM
                    (
                        SELECT  (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= TD.TODATE AND HOLIDAY = 'N') txdate,
                                 tltxcd,TD.acctno,TD.afacctno,CF.fullname, cf.custodycd,
                                (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= TD.TODATE AND HOLIDAY = 'N') frdate,
                               -- (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= ((SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                               --            AND SBDATE >= TD.TODATE AND HOLIDAY = 'N')+ td.tdterm)   AND HOLIDAY = 'N')  todate,
                                td.balance msgamt,
                                --td.tdterm,
                                td.schdtype ,
                                --td.intrate ,
                                txdesc, td.autornd , td.actype , al.cdcontent, aft.producttype
                        FROM TDMASTHIST TD, TLTX , afmast af , cfmast cf,allcode al, aftype aft
                        WHERE TLTX.TLTXCD = '1630'
                        and td.DELTD <>'Y'
                        and td.afacctno = af.acctno
                        and af.actype = aft.actype
                        and af.custid = cf.custid
                        and al.cdtype = 'TD'
                        and al.cdname = 'TERMCD'
                        and td.termcd = al.cdval
                        and td.acctno LIKE V_STRACCTNO
                        and cf.custodycd LIKE V_CUSTODYCD
                        and td.balance<>0
                        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                        AND (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= td.TODATE AND HOLIDAY = 'N') BETWEEN V_FROMDATE and V_TODATE
                        --AND cf.careby IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = V_STRCAREBY)
                    )  td,
                    (
                        select tdmasthist.acctno ,tdmasthist.orgamt,tdmasthist.balance,tdmasthist.intrate,tdmasthist.frdate,tdmasthist.tdterm,tdmasthist.opndate,
                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= TODATE AND HOLIDAY = 'N') todate
                        from tdmasthist, cfmast cf, afmast af  WHERE cf.custid = af.custid AND  tdmasthist.acctno LIKE V_STRACCTNO and afacctno = af.acctno AND cf.custodycd like V_CUSTODYCD
                        union all
                        select tdmast.acctno ,tdmast.orgamt,tdmast.balance,tdmast.intrate,tdmast.frdate,tdmast.tdterm,tdmast.opndate,
                        (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000' AND SBDATE >= TODATE AND HOLIDAY = 'N') todate
                        from tdmast, afmast af, cfmast cf where tdmast.acctno LIKE V_STRACCTNO and cf.custid = af.custid  and afacctno = af.acctno AND cf.custodycd like V_CUSTODYCD
                    )  tdroot
                    where td.frdate = tdroot.frdate(+)
                    --and   td.todate = tdroot.todate
                    and   td.acctno = tdroot.acctno(+)
                ) TD

                LEFT JOIN
                (
                    SELECT tl.txdate, tl.txnum, tl.msgacct FROM vw_tllog_all tl  WHERE tltxcd = '1630'
                ) tl
                ON td.txdate = tl.txdate AND td.acctno = tl.msgacct

                left join
                ( select DISTINCT * from (
                    select tdmstschm.refautoid,  tdmstschm.acctno,  tdmstschm.intrate,  framt ,toamt,  frterm,toterm  ,tdmast.frdate ,
                    (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                AND SBDATE >= tdmast.todate AND HOLIDAY = 'N') todate
                    from tdmstschm , tdmast, cfmast cf, afmast af
                    where tdmstschm.acctno = tdmast.acctno AND cf.custid = af.custid
                    and tdmast.acctno like V_STRACCTNO and tdmast.afacctno = af.acctno AND cf.custodycd like V_CUSTODYCD
                    union all
                    select    tdmstschmhist.refautoid,  tdmstschmhist.acctno,  tdmstschmhist.intrate,  framt ,toamt,  frterm,toterm  ,tdmstschmhist.frdate ,
                    (SELECT min(sbdate) FROM SBCLDR WHERE CLDRTYPE = '000'
                                                AND SBDATE >= tdmstschmhist.todate AND HOLIDAY = 'N') todate
                    from tdmstschmhist
                    where tdmstschmhist.acctno like V_STRACCTNO )
                )
                    SCHM

                on td.acctno = SCHM.acctno
                and td.msgamt >= SCHM.framt
                and td.msgamt < SCHM.toamt
                and td.tdterm >= SCHM.FRTERM
                and td.tdterm < SCHM.toterm
                and td.txdate >= SCHM.frdate
                and td.txdate < SCHM.todate



            )a
            WHERE tltxcd LIKE V_STRTLTXCD
            AND custodycd LIKE V_CUSTODYCD
            ORDER BY custodycd, afacctno, acctno,TXDATE,stt,txnum;--, opndate
    plog.setendsection(pkgctx, 'pr_Details_saving_rate');
  EXCEPTION WHEN OTHERS THEN
        return;
  END pr_Details_saving_rate;

procedure pr_PlaceOrder_bl(p_functionname in varchar2,
                        p_username in varchar2,
                        p_acctno in varchar2,
                        p_afacctno in varchar2,
                        p_exectype in varchar2,
                        p_symbol in varchar2,
                        p_quantity in number,
                        p_quoteprice in number,
                        p_pricetype in varchar2,
                        p_timetype in varchar2,
                        p_book in varchar2,
                        p_via in varchar2,
                        p_dealid in varchar2,
                        p_direct in varchar2,
                        p_effdate in varchar2,
                        p_expdate in varchar2,
                        p_tlid  IN  VARCHAR2,
                        p_quoteqtty in number,
                        p_limitprice in number,
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2,
                        p_refOrderId in varchar2 DEFAULT '',
                        p_blOrderid   in varchar2 default '',
                        P_NOTE        IN VARCHAR2 DEFAULT ''
                        )
  is
    v_strACCTNO varchar2(50);
    v_strAFACCTNO  varchar2(10);
    v_strACTYPE  varchar2(4);
    v_strCLEARCD  varchar2(10);
    v_strMATCHTYPE  varchar2(10);
    v_dblQUANTITY  number(20,0);
    v_dblPRICE  number(20,4);
    v_dblQUOTEPRICE  number(20,4);
    v_dblTRIGGERPRICE  number(20,4);
    v_dblCLEARDAY  number(20,0);
    v_strDIRECT  varchar2(10);
    v_strSPLITOPTION  varchar2(10);
    v_dblSPLITVALUE  number(20,0);
    v_strBOOK  varchar2(10);
    v_strVIA  varchar2(10);
    v_strEXECTYPE  varchar2(10);
    v_strPRICETYPE  varchar2(10);
    v_strTIMETYPE  varchar2(10);
    v_strNORK varchar2(10);
    v_strSYMBOL varchar2(50);
    v_strCODEID varchar2(20);
    v_sectype   varchar2(3);
    v_strODACTYPE  varchar2(4);
    v_strDEALID varchar2(100);
    v_strtradeplace varchar2(10);
    v_strATCStartTime varchar2(20);
    v_strMarketStatus varchar2(10);
    v_strFEEDBACKMSG varchar2(500);
    v_strUSERNAME varchar2(200);
    v_blnOK boolean;
    v_strSystemTime varchar2(20);
    v_count number(20,0);
    v_strORDERID varchar2(50);
    v_strBUSDATE varchar2(20);
    v_strSPLITVALUE number(20,0);
    v_strFOStatus char(1);
    v_strExpdate varchar2(20);
    v_strEffdate varchar2(20);
    v_strSTATUS char(1);
    v_strOrderStatus char(2);
    v_strTLID   varchar2(4);
    v_dblQUOTEQTTY  number(20,0);
    v_dblLIMITPRICE  number(20,4);
    l_hnxTRADINGID        varchar2(20);
    l_hoseTRADINGID        varchar2(20);
    l_isMortage           VARCHAR2(10);
    v_securitytradingSTS varchar2(3);
    V_STRISDISPOSAL      VARCHAR2(1);
    V_STRFUNCTIONAME     VARCHAR2(50);
  --Phuonght check khoi luong ban ko vuot qua kl trong semast
    l_trade NUMBER(20,0);
    l_dfmortage NUMBER(20,0);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    l_exectype VARCHAR2(10);
    l_oldOrderqtty NUMBER(20,0);
    L_MaxHNXQtty number(20,0);
    l_HoldDirect char(1);

    l_dblRoom  number(20,0);
    v_strcustodycd varchar2(20);
    ---DungNH 02-Nov-2015 them xu ly lenh bloomberg
    v_blOrderid varchar2(30);
    v_OdBlOrderid  varchar2(30);
    v_Odreltid       varchar2(10);
    V_NOTE           VARCHAR2(2000);
    --- end DungNH
    V_ORDER_END_SESSION varchar2(10);
    V_STR_SESSION_TIME  number(10);
    V_END_SESSION_TIME  number(10);
    V_CURRTIME          number(10);
    v_strholiday        varchar2(1);
    l_dblTradeLot    number; --HOSE chinh sua Lo tu 10 -> 100
  begin
    plog.setbeginsection(pkgctx, 'pr_placeorder_bl');
    p_err_code := systemnums.C_SUCCESS;

    -- Check host 1 active or inactive
    p_err_code := fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder_bl');
        return;
    END IF;


    -- End: Check host 1 active or inactive
    V_STRISDISPOSAL:='N';
    IF p_functionname='PLACEORDERDISPOSAL' THEN
       V_STRFUNCTIONAME:='PLACEORDER';
       V_STRISDISPOSAL:='Y';
    ELSE
       V_STRFUNCTIONAME:=P_FUNCTIONNAME;
    END IF;
    v_blOrderid:=p_blOrderid;
    v_strDIRECT:=nvl(p_direct,'N');
    v_strSPLITOPTION:='N';
    v_dblSPLITVALUE:=0;
    v_strAFACCTNO:=p_afacctno;
    --plog.debug(pkgctx, 'p_book:' || p_book);
    v_strBOOK:=nvl(p_book,'A');
    --plog.debug(pkgctx, 'v_strVIA:' || v_strVIA);
    v_strVIA:=nvl(p_via,'F');
    v_strEXECTYPE:=p_exectype;
    v_strPRICETYPE:=p_pricetype;
    v_strTIMETYPE:= p_timetype;
    v_strMATCHTYPE:='N';
    v_strCLEARCD:='B';
    v_strNORK:='N';
    v_strSYMBOL:= p_symbol;
    v_strCODEID:='';
 --T2-NAMNT
  -- v_dblCLEARDAY:=3;
     select TO_NUMBER(VARVALUE) into v_dblCLEARDAY from sysvar where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
 --END-T2-NAMNT
    v_dblQUANTITY:=p_quantity;
    v_dblQUOTEPRICE:=p_quoteprice;
    v_dblPRICE:=p_quoteprice;
    v_strDEALID:=nvl(p_dealid,'');
    v_strACCTNO:=p_acctno;
    v_strExpdate:=p_expdate;
    v_strEffdate:=p_effdate;
    v_strBUSDATE:=cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
    l_HoldDirect:=cspks_system.fn_get_sysvar('BROKERDESK','DIRECT_HOLD_TO_BANK');
    v_strSTATUS:='P';
    ---DungNH 02-Nov-2015 Bloomberg
    v_Odreltid:='';
    v_OdBlOrderid:='';
    V_NOTE:=P_NOTE;
    --- end DungNH

    if v_strTIMETYPE ='T' then
        v_strExpdate:=v_strBUSDATE;
        v_strEffdate:=v_strBUSDATE;
    end if;
    IF p_Username IS NULL THEN
        SELECT CUSTID INTO v_strUSERNAME FROM AFMAST WHERE ACCTNO = p_afacctno;
    ELSE
        v_strUSERNAME:=p_Username;
    END IF;
    plog.debug(pkgctx, 'TLID: ' || p_tlid);
    IF p_tlid IS NULL OR p_via = 'O' THEN
        v_strTLID := systemnums.C_ONLINE_USERID;
    ELSE
        v_strTLID := p_tlid;
    END IF;
      v_dblQUOTEQTTY  :=p_quoteqtty;
    v_dblLIMITPRICE := p_limitprice;
     SELECT sysvalue
     INTO l_hnxTRADINGID
     FROM ordersys_ha
     WHERE sysname = 'TRADINGID';
     SELECT sysvalue
     INTO l_hoseTRADINGID
     FROM ordersys
     WHERE sysname = 'CONTROLCODE';

     -- lay ra gia tri max HNX cua 1 lenh
     select to_number(varvalue)
     into L_MaxHNXQtty
     from sysvar
     where varname = 'HNX_MAX_QUANTITY';


    --Lay ra codeid theo symbol
    begin
        --plog.debug(pkgctx, 'Xac dinh ma CK');
        if V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','CANCELGTCORDER','BLBAMENDMENTORDER','BLBCANCELORDER') then
            select codeid, tradeplace, sectype,blorderid,exectype, symbol
            into v_strcodeid, v_strtradeplace, v_sectype,v_OdBlOrderid,l_exectype, v_strsymbol
            from (
                (select sb.codeid, sb.tradeplace, sb.sectype,od.blorderid,od.exectype,sb.symbol
                from odmast od, sbsecurities sb
                where od.codeid = sb.codeid and OD.orderid = p_acctno)
                 union all
                (select sb.codeid, sb.tradeplace, sb.sectype,od.blorderid,od.exectype,sb.symbol
                from fomast od, sbsecurities sb
                where od.codeid = sb.codeid and OD.acctno = p_acctno)
            );
        else
            select SB.CODEID, SB.tradeplace, SB.sectype
            into v_strcodeid, v_strtradeplace, v_sectype
            from sbsecurities SB
            where SB.symbol =v_strsymbol;
        end if;
        --plog.debug(pkgctx, 'v_strcodeid:' || v_strcodeid);
    exception when others then
        p_err_code:=errnums.C_OD_SECURITIES_INFO_UNDEFINED;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
    end;

    begin
        select se.tradelot
            into l_dblTradeLot --HOSE chinh sua Lo tu 10 -> 100
        from securities_info se
        where se.codeid = v_strcodeid;
    exception when others then
        p_err_code:=errnums.C_OD_SECURITIES_INFO_UNDEFINED;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:securities_info '  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
    end;

    BEGIN
        SELECT VARVALUE INTO V_ORDER_END_SESSION FROM SYSVAR WHERE VARNAME = 'ORDER_END_SESSION' AND GRNAME = 'SYSTEM';
    EXCEPTION WHEN OTHERS THEN
        V_ORDER_END_SESSION := 'N';
    END;
    BEGIN
        SELECT VARVALUE INTO V_STR_SESSION_TIME FROM SYSVAR WHERE VARNAME = 'STR_SESSION_TIME' AND GRNAME = 'SYSTEM';
        SELECT VARVALUE INTO V_END_SESSION_TIME FROM SYSVAR WHERE VARNAME = 'END_SESSION_TIME' AND GRNAME = 'SYSTEM';
    EXCEPTION WHEN OTHERS THEN
        V_STR_SESSION_TIME := 140000;
        V_END_SESSION_TIME := 210000;
    END;
    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO V_CURRTIME FROM DUAL;
    select nvl(max(holiday),'N') into v_strholiday from sbcldr
    where sbdate = to_date(sysdate,'dd/mm/rrrr') and cldrtype = '000';

    if P_VIA <> 'F' AND V_ORDER_END_SESSION = 'Y' AND v_strholiday = 'N' AND V_CURRTIME > V_STR_SESSION_TIME and V_CURRTIME < V_END_SESSION_TIME THEN
        if v_strtradeplace = '001' then
                if l_hoseTRADINGID in ('J','K') then
                    p_err_code := '-700111';
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    return;
                end if;
            else
                SELECT COUNT(1) INTO V_COUNT FROM HA_BRD HB, HASECURITY_REQ HR
                WHERE HB.TRADINGSESSIONID = HR.TRADINGSESSIONID
                    AND HR.SYMBOL = v_strsymbol
                    AND HR.SECURITYTRADINGSTATUS IN ('17','24','25','26','1','27','28')
                    AND HB.BRD_CODE = HR.TRADINGSESSIONSUBID
                    AND HB.TRADSESSTATUS = '1'
                    AND HR.TRADSESSTATUS = '1';
                if V_COUNT < 1 then
                    p_err_code := '-700111';
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    return;
                end if;
            end if;
    end if;
    IF P_VIA <> 'F' AND V_ORDER_END_SESSION = 'Y' AND TO_DATE(V_STRBUSDATE,'DD/MM/RRRR') = TO_DATE(SYSDATE,'DD/MM/RRRR') THEN
        if ( V_CURRTIME > V_STR_SESSION_TIME) then
            if v_strtradeplace = '001' then
                if l_hoseTRADINGID in ('J','K') then
                    p_err_code := '-700111';
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    return;
                end if;
            else
                SELECT COUNT(1) INTO V_COUNT FROM HA_BRD HB, HASECURITY_REQ HR
                WHERE HB.TRADINGSESSIONID = HR.TRADINGSESSIONID
                    AND HR.SYMBOL = v_strsymbol
                    AND HR.SECURITYTRADINGSTATUS IN ('17','24','25','26','1','27','28')
                    AND HB.BRD_CODE = HR.TRADINGSESSIONSUBID
                    AND HB.TRADSESSTATUS = '1'
                    AND HR.TRADSESSTATUS = '1';
                if V_COUNT < 1 then
                    p_err_code := '-700111';
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    return;
                end if;
            end if;
        end if;
    END IF;


    v_strATCStartTime:=cspks_system.fn_get_sysvar('SYSTEM','ATCSTARTTIME');
    select sysvalue into v_strMarketStatus  from ordersys where sysname='CONTROLCODE';
    SELECT TO_CHAR(SYSDATE,'HH24MISS') into v_strSystemTime FROM DUAL;
    --If v_strPRICETYPE <> 'LO' And V_STRFUNCTIONAME ='PLACEORDER' And v_strBOOK = 'A' and v_strTIMETYPE='T' Then
    If v_strPRICETYPE <> 'LO' And V_STRFUNCTIONAME in ('PLACEORDER','BLBPLACEORDER') And v_strBOOK = 'A' and v_strTIMETYPE='T' Then
      If v_strPRICETYPE = 'ATO' Then
          If v_strMarketStatus = 'O' Or v_strMarketStatus = 'A' Then
            IF INSTR('BB1/AW8/AW9/BC1', v_strMarketStatus) > 0 THEN --HSX04: UPdate check phien
                p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                return;
              End If;
            return;
          End If;
      End If;

      If v_strPRICETYPE = 'MO' Then
          If v_strMarketStatus <> 'O' Then
            p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_placeorder');
            RETURN;
          End If;
      End If;
    End If;
    --- Chan huy/sua phien 3 theo thong tu 203
        If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','BLBAMENDMENTORDER','BLBCANCELORDER')
         --and fn_get_controlcode(v_strSYMBOL) in ('A','CLOSE','CLOSE_BL') and v_strPRICETYPE NOT IN ('PLO') then
         and fn_get_controlcode(v_strSYMBOL) in ('AA1','BC1') and v_strPRICETYPE NOT IN ('PLO') THEN --HSX04: UPdate check phien
               p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.setendsection(pkgctx, 'pr_placeorder');
             return;
        end if;
    --------
    ---If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER') And v_strTradePlace = '001' Then
   /* If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','BLBAMENDMENTORDER','BLBCANCELORDER') And v_strTradePlace = '001' Then
        --plog.debug(pkgctx, 'Kiem tra phien giao dich :' || v_strMarketStatus);
        -- Kiem tra neu lenh da day vao ODMAST ma chua day len san thi ko check trang thai phien GD
        BEGIN
            SELECT orstatus, PRICETYPE INTO v_strOrderStatus, v_strPRICETYPE
            FROM odmast od WHERE od.orderid = v_strACCTNO;
        EXCEPTION WHEN OTHERS THEN
            v_strOrderStatus := null;
        END;
        plog.debug(pkgctx, 'v_strOrderStatus :' || v_strOrderStatus);
        IF v_strOrderStatus IS NOT NULL THEN
            IF trim(v_strOrderStatus) NOT IN ('8','11','5','9') THEN
                If v_strMarketStatus = 'P' Then
                    p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                    p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                    plog.error(pkgctx, 'Error:'  || p_err_message);
                    plog.setendsection(pkgctx, 'pr_placeorder');
                    RETURN;
                End If;
                If v_strMarketStatus = 'A' Then
                    SELECT count(orderid) into v_count FROM odmast WHERE orderid = v_strACCTNO AND hosesession = 'A';
                     If v_count > 0 Then
                         p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                         plog.error(pkgctx, 'Error:'  || p_err_message);
                         plog.setendsection(pkgctx, 'pr_placeorder');
                         RETURN;
                     End If;
                     -- Neu lenh ATC da day len san thi ko cho phep huy
                     IF v_strPRICETYPE = 'ATC' THEN
                         p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                         plog.error(pkgctx, 'Error:'  || p_err_message);
                         plog.setendsection(pkgctx, 'pr_placeorder');
                         RETURN;
                     END IF;
                End If;


            END IF;
        END IF;

    End If; */

    If V_STRFUNCTIONAME in ('CANCELORDER','AMENDMENTORDER','BLBAMENDMENTORDER','BLBCANCELORDER') And v_strTradePlace = '001' Then
            --plog.debug(pkgctx, 'Kiem tra phien giao dich :' || v_strMarketStatus);
            -- Kiem tra neu lenh da day vao ODMAST ma chua day len san thi ko check trang thai phien GD
            BEGIN
                SELECT orstatus, PRICETYPE INTO v_strOrderStatus, v_strPRICETYPE
                FROM odmast od WHERE od.orderid = v_strACCTNO;
            EXCEPTION WHEN OTHERS THEN
                v_strOrderStatus := null;
            END;
            plog.debug(pkgctx, 'v_strOrderStatus :' || v_strOrderStatus);
            IF v_strOrderStatus IS NOT NULL THEN
                IF trim(v_strOrderStatus) NOT IN ('8','11','5','9') THEN
                    --If v_strMarketStatus = 'P' Then
                    IF v_strMarketStatus = 'AA1' THEN --HSX04: UPdate check phien
                        p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                        plog.error(pkgctx, 'Error:'  || p_err_message);
                        plog.setendsection(pkgctx, 'pr_placeorder');
                        RETURN;
                    End If;
                    --If v_strMarketStatus = 'A' Then
                    If v_strMarketStatus = 'BC1' THEN  --HSX04: UPdate check phien
                        SELECT count(orderid) into v_count FROM odmast WHERE orderid = v_strACCTNO AND hosesession = 'A';
                         If v_count > 0 Then
                             p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                             p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                             plog.error(pkgctx, 'Error:'  || p_err_message);
                             plog.setendsection(pkgctx, 'pr_placeorder');
                             RETURN;
                         End If;
                         -- Neu lenh ATC da day len san thi ko cho phep huy
                         IF v_strPRICETYPE = 'ATC' THEN
                             p_err_code:=-100113;--ERR_SA_INVALID_SECSSION
                             p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                             plog.error(pkgctx, 'Error:'  || p_err_message);
                             plog.setendsection(pkgctx, 'pr_placeorder');
                             RETURN;
                         END IF;
                    End If;


                END IF;
            END IF;

        End If;

    If V_STRFUNCTIONAME in ( 'PLACEORDER','BLBPLACEORDER') Then
        --HSX04: Chan KH, moi gioi dat lenh F2 neu bi gioi han giao dich
       IF fn_check_restrction_allow(p_symbol, p_afacctno, substr(p_exectype,2,1)) <> 'Y' THEN
          p_err_code := '-700150';
          p_err_message := cspks_system.fn_get_errmsg(p_err_code);
          plog.setendsection(pkgctx, 'pr_PlaceOrder_new');
          Return;
       END IF;

         select actype, (case when corebank='Y' AND p_exectype IN ('NB') then 'W' else 'P' end) into v_strACTYPE, v_strSTATUS from afmast where acctno = v_strafacctno;
          if l_HoldDirect='Y' then
            v_strSTATUS:='P';
          end if;
          -- PhuongHT:  -- PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
         IF v_strPRICETYPE IN ('MTL','MOK','MAK') AND l_hnxTRADINGID IN ('CLOSE','CLOSE_BL') AND v_strtradeplace = '002' THEN
           p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
           p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
           plog.error(pkgctx, 'Error:'  || p_err_message);
           plog.setendsection(pkgctx, 'pr_placeorder');
           RETURN;
         END IF;
          -- end of  PhuongHT: PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
         IF v_strPRICETYPE IN ('ATO') AND l_hoseTRADINGID IN ('I','F','A') AND v_strtradeplace = '001' THEN
               p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
               p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
               plog.error(pkgctx, 'Error:'  || p_err_message);
               plog.setendsection(pkgctx, 'pr_placeorder');
               RETURN;
         END IF;
          -- PhuongHT: check chung khoan moi niem yet, dac biet: khong dc dat lo le
        if v_strtradeplace in ('002','005') then
             begin
                  select nvl(securitytradingstatus,'17')
                  into v_securitytradingSTS
                  from hasecurity_req
                  where symbol=v_strSYMBOL;
             exception when others then
               v_securitytradingSTS:='17';
             end;
               if v_securitytradingSTS in ('1','27') and v_dblQUANTITY < l_dblTradeLot  then
                     p_err_code := -100113;
                     p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                     plog.error(pkgctx, 'Error:'  || p_err_message);
                     plog.setendsection(pkgctx, 'pr_placeorder');
                     RETURN;
               end if ;
         end if;
      -- Lay gia tri loai hinh lenh
      v_strODACTYPE := fopks_api.fn_GetODACTYPE(v_strAFACCTNO, p_symbol, v_strCODEID, v_strtradeplace, p_exectype,
                                    p_pricetype, p_timetype, v_strACTYPE, v_sectype, v_strVIA);
      select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
      v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_RECEIVED';

      -- Kiem tra mua ban cung ngay
   v_strFEEDBACKMSG := 'Order is received and pending to process';
      INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
          CONFIRMEDVIA, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
          VIA, DIRECT, SPLOPT, SPLVAL, EFFDATE, EXPDATE, USERNAME, DFACCTNO,SSAFACCTNO, TLID,QUOTEQTTY, LIMITPRICE,Isdisposal,REFORDERID,ROOTQTTY)
          VALUES (v_strORDERID,v_strORDERID,v_strODACTYPE,v_strAFACCTNO,v_strSTATUS,
          v_strEXECTYPE,v_strPRICETYPE,v_strTIMETYPE,v_strMATCHTYPE,
          v_strNORK,v_strCLEARCD,v_strCODEID,v_strSYMBOL,
          'N',v_strBOOK,v_strFEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
          v_dblCLEARDAY ,v_dblQUANTITY ,v_dblPRICE ,v_dblQUOTEPRICE ,v_dblTRIGGERPRICE ,0 ,0 ,v_dblQUANTITY ,
          v_strVIA,v_strDIRECT,v_strSPLITOPTION,v_strSPLITVALUE , TO_DATE(v_streffdate,'DD/MM/RRRR'),TO_DATE(v_strexpdate,'DD/MM/RRRR'),
          v_strUSERNAME,v_strDEALID,'', v_strTLID, v_dblQUOTEQTTY, v_dblLIMITPRICE,V_STRISDISPOSAL, p_refOrderId,v_dblQUANTITY);
      p_err_code := systemnums.C_SUCCESS;
      --Day lenh vao ODMAST luon neu la lenh Direct
      If v_strDIRECT='Y' and v_strBOOK='A' and v_strTIMETYPE ='T' and v_strSTATUS='P' Then
          --Goi thu tuc day ca lenh vao ODMAST
          TXPKS_AUTO.pr_fo2odsyn_bl(v_strORDERID,p_err_code,v_strTIMETYPE);

          -- Neu lenh thieu suc mua thi dong bo lai ci
          IF nvl(p_err_code,'0') = '-400116' THEN
                jbpks_auto.pr_trg_account_log(v_strAFACCTNO, 'CI');
          END IF;

          If nvl(p_err_code,'0') <> '0' Then
              --Xoa luon lenh o FOMAST neu o mode direct
              UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=v_strORDERID;
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'pr_placeorder');
              Return;
          End If;
      End If;
  ElsIf V_STRFUNCTIONAME = 'ACTIVATEORDER' Then
      UPDATE FOMAST SET BOOK='A',ACTIVATEDT=TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') WHERE BOOK='I' AND ACCTNO=v_strACCTNO;
      v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_ACTIVATED';
      p_err_code := systemnums.C_SUCCESS;
      --Day lenh vao ODMAST luon
      If v_strDIRECT='Y' and v_strSTATUS='P' Then
          --Goi thu tuc day ca lenh vao ODMAST
          TXPKS_AUTO.pr_fo2odsyn_bl(v_strORDERID,p_err_code);
          If nvl(p_err_code,'0') <> '0' Then
              --Cap nhat trang thai tu choi
              UPDATE FOMAST SET STATUS='R' WHERE ACCTNO=v_strACCTNO;
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'pr_placeorder');
              Return;
          End If;
      End If;
  ElsIf V_STRFUNCTIONAME = 'CANCELGTCORDER' Then
      begin
            SELECT status into v_strFOStatus FROM fomast WHERE acctno = v_strACCTNO and TIMETYPE='G' and deltd <> 'Y';
            if v_strFOStatus='P' or v_strFOStatus='R'  or v_strFOStatus='W' THEN
                SELECT CDCONTENT
                INTO v_strFEEDBACKMSG
                FROM ALLCODE WHERE CDTYPE = 'OD' AND CDNAME = 'ORSTATUS' AND CDVAL = 'R';
                update fomast set
                    --deltd='Y',
                    CANCELQTTY = REMAINQTTY,
                    REMAINQTTY = 0,
                    STATUS = 'R',
                    FEEDBACKMSG = v_strFEEDBACKMSG
                where acctno = v_strACCTNO;
                p_err_code := systemnums.C_SUCCESS;
            ELSIF v_strFOStatus = 'A' THEN
                If v_strBOOK = 'A' Then
                  --Kiem tra da ton tai lenh huy hay chua - return message loi.
                  SELECT count(1) into v_count FROM fomast WHERE refacctno = v_strACCTNO AND substr(exectype,1,1) = 'C' and status <> 'R';
                  If v_count = 0 Then
                      -- Lenh da thuc hien huy tren OD?
                      -- Ducnv FF Gateway
                      SELECT count(1) into v_count FROM odmast WHERE reforderid = v_strACCTNO  AND substr(exectype,1,1) = 'C' and orstatus<>'6';
                      -- End Ducnv FF Gateway
                      If v_count = 0 Then
                          -- Kiem tra xem con khoi luong chua khop hay khong.
                          SELECT count(1) into v_count FROM odmast WHERE orderid = v_strACCTNO  AND remainqtty > 0;
                          If v_count=0 Then
                              p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                              plog.error(pkgctx, 'Error:'  || p_err_message);
                              plog.setendsection(pkgctx, 'pr_placeorder');
                              return;
                          End If;
                      Else
                          p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                          p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                          plog.error(pkgctx, 'Error:'  || p_err_message);
                          plog.setendsection(pkgctx, 'pr_placeorder');
                          return;
                      End If;
                  Else
                      p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.error(pkgctx, 'Error:'  || p_err_message);
                      plog.setendsection(pkgctx, 'pr_placeorder');
                      return;
                  End If;

                      --Generate OrderID
                      select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
                      v_strFEEDBACKMSG := 'MSG_CANCEL_ORDER_IS_RECEIVED';
                        -- SInh lenh huy
                      INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                          CONFIRMEDVIA, DIRECT, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
                          REFACCTNO, REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE,EXPDATE,USERNAME, TLID,QUOTEQTTY, LIMITPRICE,ISDISPOSAL,ROOTQTTY)
                      SELECT v_strORDERID,od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
                         (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR od.EXECTYPE='AB' THEN 'CB' ELSE 'CS' END) CANCEL_EXECTYPE,
                         od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
                         'O' CONFIRMEDVIA,v_strDIRECT ,'A' BOOK, v_strFEEDBACKMSG ,
                         TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
                         od.CLEARDAY,od.exqtty QUANTITY,(od.exprice/1000) PRICE, (od.QUOTEPRICE/1000) QUOTEPRICE, 0 TRIGGERPRICE, od.EXECQTTY, od.EXECAMT,
                         od.REMAINQTTY, od.orderid REFACCTNO, 0 REFQUANTITY, 0 REFPRICE, (od.QUOTEPRICE/1000) REFQUOTEPRICE,
                         v_strVIA VIA,OD.TXDATE EFFDATE,OD.EXPDATE EXPDATE,
                         v_strUSERNAME USERNAME, v_strTLID TLID,v_dblQUOTEQTTY , v_dblLIMITPRICE,V_STRISDISPOSAL, v_dblQUANTITY
                         FROM ODMAST od, sbsecurities sb
                         WHERE orstatus IN ('1','2','4','8') AND orderid=v_strACCTNO and sb.codeid = od.codeid
                            and orderid not in (select REFACCTNO
                                                    from fomast
                                                    WHERE EXECTYPE IN ('CB','CS') AND STATUS <>'R'
                                               );
                      p_err_code := systemnums.C_SUCCESS;

              Else
                  DELETE FROM FOMAST WHERE BOOK='I' AND ORGACCTNO=v_strACCTNO;
                  v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_CANCALLED';
              End If;
            ELSE

             p_err_code:=errnums.c_od_order_sending;
             p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
             plog.error(pkgctx, 'Error:'  || p_err_message);
             plog.setendsection(pkgctx, 'pr_placeorder');
             return;
          end if;
      exception when others then
        p_err_code:=errnums.c_od_order_not_found;
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_placeorder');
        return;
      end;
  ----ElsIf V_STRFUNCTIONAME = 'CANCELORDER' THEN
  ElsIf V_STRFUNCTIONAME in ( 'CANCELORDER','BLBCANCELORDER') THEN
   -- PhuongHT:  -- Chan huy sua cuoi phien
       IF  l_hnxTRADINGID IN ('CLOSE_BL') AND v_strtradeplace = '002' and v_strPRICETYPE NOT IN ('PLO') THEN
         p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
         plog.error(pkgctx, 'Error:'  || p_err_message);
         plog.setendsection(pkgctx, 'pr_placeorder');
         RETURN;
       END IF;
      -- end of  PhuongHT:  Chan huy sua cuoi phien
      If v_strBOOK = 'A' Then
          --Kiem tra da ton tai lenh huy hay chua - return message loi.
          SELECT count(1) into v_count FROM fomast WHERE refacctno = v_strACCTNO AND substr(exectype,1,1) = 'C' and status <> 'R';
          If v_count = 0 Then
              -- Lenh da thuc hien huy tren OD?
            -- Ducnv FF Gateway
              SELECT count(1) into v_count FROM odmast WHERE reforderid = v_strACCTNO  AND substr(exectype,1,1) = 'C' and orstatus<>'6';
              -- End Ducnv FF Gateway
              If v_count = 0 Then
                  -- Kiem tra xem con khoi luong chua khop hay khong.
                  SELECT count(1) into v_count FROM odmast WHERE orderid = v_strACCTNO  AND remainqtty > 0;
                  If v_count=0 Then
                      p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.error(pkgctx, 'Error:'  || p_err_message);
                      plog.setendsection(pkgctx, 'pr_placeorder');
                      return;
                  End If;
              Else
                  p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
                  p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                  plog.error(pkgctx, 'Error:'  || p_err_message);
                  plog.setendsection(pkgctx, 'pr_placeorder');
                  return;
              End If;
          Else
              p_err_code:=-800002;--gc_ERRCODE_FO_INVALID_STATUS
              p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
              plog.error(pkgctx, 'Error:'  || p_err_message);
              plog.setendsection(pkgctx, 'pr_placeorder');
              return;
          End If;

          --Kiem tra trang thai cua lenh
          SELECT count(STATUS) into v_count FROM FOMAST WHERE ORGACCTNO=v_strACCTNO  AND EXECTYPE IN ('NB','NS');
          If v_count > 0 Then
              --Lenh chua duoc huy lan nao
              --Kiem tra trang thai cua lenh, Neu la P thi xoa luon
              SELECT max(STATUS) into v_strFOStatus FROM FOMAST WHERE ORGACCTNO=v_strACCTNO  AND EXECTYPE IN ('NB','NS');
              If v_strFOStatus = 'P' Then
                  v_strFEEDBACKMSG := 'Order is cancelled when processing';
                  UPDATE FOMAST SET STATUS='R',FEEDBACKMSG=v_strFEEDBACKMSG  WHERE BOOK='A' AND ACCTNO=v_strACCTNO AND STATUS='P';
              ElsIf v_strFOStatus = 'A' Then
                  --Neu la A tuc la lenh da day vao he thong thi sinh lenh huy
                  v_blnOK := True;
              Else
                  v_strFEEDBACKMSG := 'MSG_REJECT_CANCEL_ORDER';
              End If;
          Else
              --LENH o trong he thong
              v_blnOK := True;
          End If;
          if P_VIA <> 'F' AND v_strtradeplace = '001' AND l_hoseTRADINGID in ('J','K') /*and PCK_HOGW.fn_caculate_hose_time > 150000*/ AND TO_DATE(V_STRBUSDATE,'DD/MM/RRRR') = TO_DATE(SYSDATE,'DD/MM/RRRR') then
                pr_CancelOrderAfterDay(v_strACCTNO, p_err_code, p_err_message);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
          elsif v_blnOK Then
              --Generate OrderID
              select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
              v_strFEEDBACKMSG := 'MSG_CANCEL_ORDER_IS_RECEIVED';
              -- Lay thong tin timetype
              SELECT od.timetype INTO v_strTIMETYPE FROM odmast od where od.orderid=v_strACCTNO;

              INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
                  CONFIRMEDVIA, DIRECT, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
                  REFACCTNO, REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE,EXPDATE,USERNAME, TLID,QUOTEQTTY, LIMITPRICE,ISDISPOSAL)
              SELECT v_strORDERID,od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, 'P',
                 (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR od.EXECTYPE='AB' THEN 'CB' ELSE 'CS' END) CANCEL_EXECTYPE,
                 od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
                 'O' CONFIRMEDVIA,v_strDIRECT ,'A' BOOK, v_strFEEDBACKMSG ,
                 TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'), TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS'),
                 od.CLEARDAY,od.exqtty QUANTITY,(od.exprice/1000) PRICE, (od.QUOTEPRICE/1000) QUOTEPRICE, 0 TRIGGERPRICE, od.EXECQTTY, od.EXECAMT,
                 od.REMAINQTTY, od.orderid REFACCTNO, 0 REFQUANTITY, 0 REFPRICE, (od.QUOTEPRICE/1000) REFQUOTEPRICE,
                 v_strVIA VIA,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EFFDATE,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EXPDATE,
                 v_strUSERNAME USERNAME, v_strTLID TLID, v_dblQUOTEQTTY , v_dblLIMITPRICE,V_STRISDISPOSAL
                 FROM ODMAST od, sbsecurities sb
                 WHERE orstatus IN ('1','2','4','8') AND orderid=v_strACCTNO and sb.codeid = od.codeid
                    and orderid not in (select REFACCTNO
                                            from fomast
                                            WHERE EXECTYPE IN ('CB','CS') AND STATUS <>'R'
                                       );
              p_err_code := systemnums.C_SUCCESS;
              --Day lenh vao ODMAST luon
              If v_strDIRECT='Y' Then
                  --Goi thu tuc day ca lenh vao ODMAST
                  TXPKS_AUTO.pr_fo2odsyn_bl(v_strORDERID,p_err_code,v_strTIMETYPE);
                  If nvl(p_err_code,'0') <> '0' Then
                      --Cap nhat trang thai tu choi
                      UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=v_strACCTNO;
                      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                      plog.error(pkgctx, 'Error:'  || p_err_message);
                      plog.setendsection(pkgctx, 'pr_placeorder');
                      Return;
                  End If;
              End If;
          End If;
      Else
          DELETE FROM FOMAST WHERE BOOK='I' AND ACCTNO=v_strACCTNO;
          v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_CANCALLED';
      End If;

  ---ElsIf V_STRFUNCTIONAME = 'AMENDMENTORDER' Then
  ElsIf V_STRFUNCTIONAME in ( 'AMENDMENTORDER','BLBAMENDMENTORDER') Then
      plog.debug(pkgctx, 'V_STRFUNCTIONAME:'  || V_STRFUNCTIONAME);
      -- PhuongHT:  -- Chan huy sua cuoi phien
       IF  l_hnxTRADINGID IN ('CLOSE_BL') AND v_strtradeplace = '002' THEN
         p_err_code:= -100113;--ERR_SA_INVALID_SECSSION
         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
         plog.error(pkgctx, 'Error:'  || p_err_message);
         plog.setendsection(pkgctx, 'pr_placeorder');
         RETURN;
       END IF;

       ---DungNH : check room nuoc ngoai
        SELECT max(CURRENT_ROOM)
        into l_dblRoom
        FROM SECURITIES_INFO INF WHERE INF.CODEID= v_strcodeid;
        l_dblRoom :=  nvl(l_dblRoom,0);
        select max(custodycd) into v_strcustodycd
        from cfmast cf, afmast af
        where cf.custid = af.custid and af.acctno = p_afacctno;
        ----v_strcodeid, v_strtradeplace
        if(v_strtradeplace = '002' and SUBSTR(v_strcustodycd,4,1) = 'F')then
            if l_dblRoom < p_quantity then
                p_err_code := '-700051';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
            end if;
        end if;
       --- end DungNH

      -- end of  PhuongHT:  Chan huy sua cuoi phien
      --PhuongHT add: chan khong sua lenh HNX lon hon max KL HNX
       IF v_dblQUANTITY > L_MaxHNXQtty AND v_strtradeplace in ( '002','005') THEN
         p_err_code:= -700109;--ERR_SA_INVALID_SECSSION
         p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
         plog.error(pkgctx, 'Error:'  || p_err_message);
         plog.setendsection(pkgctx, 'pr_placeorder');
         RETURN;
       END IF;
      --PhuongHT: check khoi luong chung khoan khi sua lenh ban
        --begin check kl
            SELECT exectype,orderqtty
            INTO l_exectype ,l_oldOrderqtty
            FROM odmast
            WHERE orderid=v_strACCTNO;
            IF (l_exectype IN ('NS','MS')) THEN
             l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(v_strAFACCTNO||v_strCODEID,'SEMAST','ACCTNO');
             l_TRADE := l_SEMASTcheck_arr(0).TRADE;
             l_dfmortage := l_SEMASTcheck_arr(0).DFMORTAGE;
                    -- neu la ban thuong
              IF l_exectype= 'NS' THEN
                IF NOT (to_number(l_TRADE) >= (p_quantity-l_oldOrderqtty)) THEN
                p_err_code := '-900017';
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_placeorder');
                RETURN;
                END IF;

              ELSE -- ban cam co
                IF NOT (to_number(l_dfmortage) >= (p_quantity-l_oldOrderqtty)) THEN
                 p_err_code := '-900017';
                 p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                 plog.error(pkgctx, 'Error:'  || p_err_message);
                 plog.setendsection(pkgctx, 'pr_placeorder');
                 RETURN;
                END IF;
              END IF;

            END IF;

        -- NEU LA SUA LENH Bloomberg theo luong bt
        if V_STRFUNCTIONAME='AMENDMENTORDER'  then
          -- plog.error (pkgctx,'ham check Bloom: v_OdBlOrderid: ' || v_OdBlOrderid || 'p_Quantity:'||p_Quantity  || 'p_exectype:'||l_exectype|| 'p_acctno:'||p_acctno  || 'p_quoteprice:'||p_quoteprice);
           if v_OdBlOrderid is not null then
               p_err_code:=pck_fo_bl.fnc_check_blb_AMENDMENTOrder(v_OdBlOrderid,p_Quantity,l_exectype,p_quoteprice,p_acctno,p_functionname,v_strVIA);
             if p_err_code<>systemnums.C_SUCCESS then
                 p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                 plog.error(pkgctx, 'Error:'  || p_err_message);
                 plog.setendsection(pkgctx, 'pr_placeorder');
                 RETURN;
             end if;
           end if;
        end if;

      -- end of PhuongHT: check khoi luong chung khoan sua lenh ban
      If v_strBOOK = 'A' Then
          --SELECT STATUS FROM FOMAST WHERE ORGACCTNO=v_strACCTNO AND EXECTYPE IN ('NB','NS');
          SELECT count(STATUS) into v_count FROM FOMAST WHERE ORGACCTNO=v_strACCTNO AND EXECTYPE IN ('NB','NS');
          If v_count > 0 Then
              --Lenh chua duoc sua lan nao
              --Kiem tra trang thai cua lenh, Neu la P thi xoa luon
              SELECT max(STATUS) into v_strFOStatus FROM FOMAST WHERE ORGACCTNO=v_strACCTNO AND EXECTYPE IN ('NB','NS');
              If v_strFOStatus = 'P' Then
                  v_strFEEDBACKMSG := 'Order is cancelled when processing';
                  UPDATE FOMAST SET STATUS='R',FEEDBACKMSG=v_strFEEDBACKMSG WHERE BOOK='A' AND ACCTNO=v_strACCTNO AND STATUS='P';
                  v_blnOK := True;
              ElsIf v_strFOStatus = 'A' Then
                  --Neu la A tuc la lenh da day vao he thong thi sinh lenh huy
                  v_blnOK := True;
              Else
                  v_strFEEDBACKMSG := 'MSG_REJECT_CANCEL_ORDER';
              End If;
          Else
              --LENH o trong he thong
              v_blnOK := True;
          End If;

          --Generate OrderID
          select v_strBUSDATE || lpad(seq_fomast.nextval,10,'0') into v_strORDERID from dual;
          v_strFEEDBACKMSG := 'MSG_ADMENT_ORDER_RECEIVED';
          plog.debug(pkgctx, 'Amend Orderid:'  || v_strORDERID);

          select (case when AF.corebank='Y' AND OD.exectype IN ('NB')  then 'W' else 'P' end) status, od.timetype
          into v_strSTATUS, v_strTIMETYPE
          from afmast AF, ODMAST OD
          WHERE OD.AFACCTNO = AF.ACCTNO AND OD.ORDERID = v_strACCTNO;

          if l_HoldDirect='Y' then
            v_strSTATUS:='P';
          end if;
          plog.debug(pkgctx, 'v_strSTATUS: '  || v_strSTATUS);
            -- quyet.kieu Sua
          INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE, TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL,
              CONFIRMEDVIA,DIRECT, BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT, CLEARDAY, QUANTITY, PRICE, QUOTEPRICE, TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,
              REFACCTNO, REFQUANTITY, REFPRICE, REFQUOTEPRICE,VIA,EFFDATE,EXPDATE,USERNAME, TLID, Quoteqtty,limitprice,ISDISPOSAL,BLORDERID)
          SELECT v_strORDERID,od.orderid ORGACCTNO, od.ACTYPE, od.AFACCTNO, v_strSTATUS,
              (CASE WHEN od.EXECTYPE='NB' OR od.EXECTYPE='CB' OR EXECTYPE='AB' THEN 'AB' ELSE 'AS' END) CANCEL_EXECTYPE,
              od.PRICETYPE, od.TIMETYPE, od.MATCHTYPE, od.NORK, od.CLEARCD, od.CODEID, sb.SYMBOL,
              'O' CONFIRMEDVIA, v_strDIRECT,'A' BOOK, v_strFEEDBACKMSG  FEEDBACKMSG,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ACTIVATEDT,TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') CREATEDDT, od.CLEARDAY,
               v_dblQUANTITY , v_dblPRICE , v_dblQUOTEPRICE ,0 TRIGGERPRICE, 0 EXECQTTY, 0 EXECAMT,v_dblQUANTITY  REMAINQTTY,
              od.orderid REFACCTNO, ORDERQTTY REFQUANTITY, round(QUOTEPRICE/SIF.TRADEUNIT,2) REFPRICE, round(QUOTEPRICE/SIF.TRADEUNIT,2) REFQUOTEPRICE,
              v_strVIA  VIA ,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EFFDATE,TO_DATE(v_strBUSDATE,'DD/MM/RRRR') EXPDATE,
              v_strUSERNAME USERNAME, v_strTLID TLID,  v_dblQUOTEQTTY,v_dblLIMITPRICE,V_STRISDISPOSAL, v_OdBlOrderid
           FROM ODMAST od, sbsecurities sb, securities_info SIF
           WHERE orstatus IN ('1','2','4','8') AND orderid=v_strACCTNO and sb.codeid = od.codeid AND SIF.CODEID = OD.CODEID
              and orderid not in (select REFACCTNO from fomast WHERE EXECTYPE IN ('CB','CS','AB','AS') AND STATUS <>'R' );
          --plog.debug(pkgctx, 'v_strDIRECT:'  || v_strDIRECT);
          p_err_code := systemnums.C_SUCCESS;
          --Day lenh vao ODMAST luon
           If v_strDIRECT='Y' Then
               --Goi thu tuc day ca lenh vao ODMAST
               TXPKS_AUTO.pr_fo2odsyn_bl(v_strORDERID,p_err_code,v_strTIMETYPE);
               If nvl(p_err_code,'0') <> '0' Then
                   --Cap nhat trang thai tu choi
                   UPDATE FOMAST SET DELTD='Y' WHERE ACCTNO=v_strACCTNO;
                   p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                   plog.error(pkgctx, 'Error:'  || p_err_message);
                   plog.setendsection(pkgctx, 'pr_placeorder');
                   Return;
               End If;
           End If;
      Else
          UPDATE FOMAST SET
          QUANTITY=v_dblQUANTITY ,
          PRICE=v_dblPRICE /1000,
          QUOTEPRICE=v_dblQUOTEPRICE /1000,
          Quoteqtty= v_dblQUOTEQTTY,
          Limitprice= v_dblLIMITPRICE
               WHERE BOOK='I' AND ACCTNO=v_strACCTNO;
          v_strFEEDBACKMSG := 'MSG_CONFIRMED_ORDER_ADMANMENT';
      End If;
  End If;

    -- neu la dat lenh Bloomberg
    If p_functionname in ('BLBPLACEORDER','BLBAMENDMENTORDER','BLBCANCELORDER') Then
        --plog.error(pkgctx,'goi ham update bloom:p_functionname: ' || p_functionname ||',p_acctno:'|| p_acctno ||',v_strORDERID:'|| v_strORDERID ||',v_blorderid:'|| v_blorderid ||',v_dblQUANTITY:'|| v_dblQUANTITY ||',p_tlid:'|| p_tlid);
        fopks_api.pr_blbPlaceOrder_update(p_functionname,p_acctno,v_strORDERID, v_blorderid,v_dblQUANTITY,p_tlid);
    end if;
  -- neu la huy/sua lenh BloomBerg qua cac man hinh binh thuong
    if (p_functionname in ('AMENDMENTORDER','CANCELORDER') and v_strDIRECT='Y') then
       if v_OdBlOrderid IS NOT NULL then
          fopks_api.pr_blbPlaceOrder_update(p_functionname,p_acctno,v_strORDERID, v_OdBlOrderid,v_dblQUANTITY,p_tlid);
       end if;
    end if;
    -- TheNN, 20-Dec-2013
    -- Ghi nhan lenh huy/sua tu cac kenh khac nhau neu lenh goc la lenh Bloomberg
    IF (p_functionname in ('AMENDMENTORDER','CANCELORDER','BLBAMENDMENTORDER','BLBCANCELORDER') and v_strDIRECT='Y' AND v_OdBlOrderid IS NOT NULL) THEN
        pck_fo_bl.bl_Place_AmendOrder(P_FOACCTNO=>v_strORDERID);
    END IF;
    -- End of: TheNN, 20-Dec-2013

    IF p_err_code IS NULL  OR LENGTH(p_err_code)=0 THEN
        p_err_code := systemnums.C_SUCCESS;
    END IF;
    if p_err_message is null then
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
    end if;
    plog.setendsection(pkgctx, 'pr_placeorder_bl');
  exception
    when others then
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error(pkgctx, sqlerrm || dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'pr_placeorder_bl');
  end pr_placeorder_bl;

  procedure pr_get_symbollist
    (p_refcursor in out pkg_report.ref_cursor)
IS
    V_CUSTODYCD     varchar2(10);
    V_AFACCTNO      varchar2(10);
    V_CURRDATE      DATE;
    V_EXECTIME      VARCHAR2(10);
begin
    plog.setbeginsection(pkgctx, 'pr_get_symbollist');


    V_EXECTIME := fn_get_hose_time;
    -- GET CURRENT DATE
    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;

    Open p_refcursor for
         SELECT SB.SYMBOL, ISS.FULLNAME, A1.CDCONTENT TRADEPLACE, A2.CDCONTENT SECTYPE,
            SEC.BASICPRICE, SEC.CEILINGPRICE, SEC.FLOORPRICE
        FROM SBSECURITIES SB, ISSUERS ISS, SECURITIES_INFO SEC, ALLCODE A1,
            ALLCODE A2
        WHERE SB.ISSUERID = ISS.ISSUERID AND SB.CODEID = SEC.CODEID
            AND SB.TRADEPLACE = A1.CDVAL AND A1.CDTYPE = 'SE' AND A1.CDNAME = 'TRADEPLACE'
            AND SB.SECTYPE = A2.CDVAL AND A2.CDTYPE = 'SA' AND A2.CDNAME = 'SECTYPE'
            AND SB.SECTYPE NOT IN ('004');
    plog.setendsection(pkgctx, 'pr_get_symbollist');
exception when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_symbollist');
end pr_get_symbollist;

--TOANNDS MOVE FROM PHS
--GEN OTP PASS
PROCEDURE PR_GEN_OTPSMSEMAIL(
                    p_username      IN varchar2,
                    p_afacctno      IN varchar2,
                    p_amt           IN VARCHAR2,
                    p_err_code       in out varchar2,
                    p_err_param      in out varchar2)
as

l_username varchar2(50);
l_status   char(1);
l_expstatus  char(1);
l_custid    varchar2(50);
l_authtype       char(1);
l_passleng   number(5);
l_mobilesms  varchar2(20);
l_email      varchar2(500);
l_datasourcesql VARCHAR2(200);
l_userpass      VARCHAR2(250);
l_newpin        VARCHAR2(250);
l_typetrade     VARCHAR2(1000);
l_fullname      VARCHAR2(500);
l_custodycode   VARCHAR2(20);
l_smstemplates     VARCHAR2(5);
l_pinencrypt    VARCHAR2(100);
l_afacctno      varchar2(20);
begin

plog.setBeginSection(pkgctx, 'PR_GEN_OTPSMSEMAIL');
p_err_code  := systemnums.C_SUCCESS;
p_err_param := 'SUCCESS';

SELECT TO_NUMBER(VARVALUE) INTO l_passleng FROM SYSVAR WHERE VARNAME = 'OTPPASSLENG';
begin
  select u.username, u.authtype,
         c.custid,
         c.status,
         c.fullname
    into l_username, l_authtype, l_custid, l_status,l_fullname
    from userlogin u, cfmast c
   where upper(u.username) = upper(p_username)
     and c.custodycd = u.username
     and u.status = 'A';

  if nvl(l_status, 'X') <> 'A' then
    p_err_code := C_FO_CUSTOMER_STATUS_INVALID;
    raise errnums.E_BIZ_RULE_INVALID;
  end if;
  IF nvl(l_authtype, '') <> '1' THEN
    p_err_code := '-100097'; --MA LOI: KHACH HANG KHONG SU DUNG DICH VU XAC THUC MAT KHAU
    RETURN;
  END IF;

exception
  when NO_DATA_FOUND then
    p_err_code := C_FO_USER_DOES_NOT_EXISTED;
    raise errnums.E_BIZ_RULE_INVALID;
end;

if p_err_code = systemnums.C_SUCCESS then
    BEGIN --LAY THONG TIN MAU SMS KHACH HANG DA DANG KY
        SELECT tl.code
        INTO l_smstemplates
        FROM templates tl, aftemplates atl
        where atl.template_code = tl.code
        AND atl.custid = l_custid
        AND tl.code = '307S';
        --AND tl.isactive = 'Y';
    exception
      when NO_DATA_FOUND then
        p_err_code := '-100098'; -- KHACH HANG CHUA DANG KY MAU SMS NAY
        raise errnums.E_BIZ_RULE_INVALID;
    END;
    IF l_authtype = '1' THEN
        --Gen pin
        SELECT LOWER(CSPKS_SYSTEM.fn_random_num(l_passleng)) INTO l_newpin FROM DUAL;

        SELECT genencryptpassword(l_newpin) INTO l_pinencrypt FROM DUAL;
        plog.error(pkgctx, 'Update USERLOGIN-l_username: '||l_username);
        UPDATE USERLOGIN
        SET
        OTPPWD = l_pinencrypt,
        lastchanged = SYSDATE,
        --LOGINDATETIME = SYSDATE,
        --EXPDATETIME = SYSDATE + 30/1440, --Thoi han: 30 phut
        EXPSTATUS = 'N'
        WHERE UPPER(USERNAME) = UPPER(l_username)
        and status='A';
        COMMIT;
        --nhan tin sms
        --IF l_authtype = '1' THEN
            begin
                select v.mobilesms, af.acctno into l_mobilesms, l_afacctno from VW_CFMAST_SMS v, afmast af WHERE af.custid = v.custid AND v.custodycd= l_username AND af.acctno = p_afacctno;
                --plog.error(pkgctx, 'GET SMS OK');
            exception
            when others then
                 l_mobilesms := '';
            end ;
           -- l_typetrade :='select ''' || ltrim(to_char(p_amt,'9,999,999,999,999')) || ''' Amt, ''' || l_newpin || ''' tradingpwd from dual';
            l_typetrade := 'BMSC-TB:Quy khach dang thuc hien gd chuyen khoan voi so tien la ' || ltrim(to_char(p_amt,'9,999,999,999,999')) || ' VND. Ma giao dich cua quy khach la: ' || l_newpin;
            IF( TRIM(l_mobilesms) IS NOT NULL) THEN

                  INSERT INTO emaillog (autoid, email, templateid, datasource, status, createtime, afacctno)
                  VALUES(seq_emaillog.nextval,l_mobilesms,l_smstemplates,l_typetrade,'A', SYSDATE, l_afacctno);

            END IF;
            plog.error(pkgctx, 'INSERT SMS OK');
        --END IF;
    END IF;

end if;
plog.setEndSection(pkgctx, 'PR_GEN_OTPSMSEMAIL');
exception
when errnums.E_BIZ_RULE_INVALID then
  for i in (select errdesc, en_errdesc
              from deferror
             where errnum = p_err_code)
  loop
    p_err_param := i.errdesc;

    sp_audit_authenticate(p_username, C_FO_LOG, '', p_err_param);
  end loop;
  plog.setEndSection(pkgctx, 'PR_GEN_OTPSMSEMAIL');
when others then
  p_err_code := errnums.C_SYSTEM_ERROR;
  plog.error(pkgctx, 'Loi xay ra PR_GEN_OTPSMSEMAIL p_err_code:' || p_err_code || dbms_utility.format_error_backtrace);
  plog.setEndSection(pkgctx, 'PR_GEN_OTPSMSEMAIL');
END PR_GEN_OTPSMSEMAIL;
PROCEDURE PR_VALIDATE_OTP
        (p_username IN VARCHAR2,
         p_otp      IN VARCHAR2,
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2)
AS
--Xac thu mat khau OTP khi thay doi thong tin KH
l_status    char(1);
l_pin       varchar2(100);
l_errors    VARCHAR2(10);
l_logintype varchar2(5);
l_pinencrypt varchar2(100);
l_custid    varchar(10);
l_Count     Number;
BEGIN
    l_errors := errnums.C_SYSTEM_ERROR;
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.setBeginSection(pkgctx, 'PR_VALIDATE_OTP');
    l_pinencrypt := GENENCRYPTPASSWORD(p_otp);
    --PLOG.error(pkgctx,'PR_VALIDATE_PIN. Thong Tin OK: l_pinencrypt:' || l_pinencrypt);
    PLOG.error(pkgctx,'PR_VALIDATE_OTP. Thong Tin OK: p_username:' || p_username);
    BEGIN --Lay loai hinh dang ky dich vu truc tuyen cua khach hang
        SELECT CUSTID INTO l_custid
        FROM CFMAST
        WHERE username = p_username;

        PLOG.error(pkgctx,'PR_VALIDATE_OTP. Thong Tin OK: p_username:' || p_username);
    exception
      when NO_DATA_FOUND then
        l_errors := '-100097'; --Khach hang khong su dung dich vu OTP
        p_err_code := '-100097';
        plog.error(pkgctx, 'Loi xay ra lay thong tin khac hang OTP p_err_code:' || p_username || dbms_utility.format_error_backtrace);
        return;
    END;


        BEGIN
            SELECT COUNT(*) INTO l_Count
            FROM USERLOGIN
            WHERE UPPER(USERNAME) = UPPER(p_username)
                AND UPPER(OTPPWD) = UPPER(l_pinencrypt)
                AND EXPSTATUS = 'N'
                AND STATUS = 'A';
                --AND SYSDATE BETWEEN LOGINDATETIME AND EXPDATETIME;
            PLOG.error(pkgctx,'Check OK:');
        EXCEPTION
            --TRuyen vao sai username se lock pass
            when NO_DATA_FOUND  THEN
            l_errors := '-901216'; --Mat khau OTP khong chinh xac
            p_err_code := '-901216';
            l_Count :=  0;
            /*insert into loginlog(custodycd, pwd_sysgen, pwd_typed, logtime)
            SELECT a.username, a.tradingpwd, p_pin || '-' || l_pinencrypt pwd_typed, sysdate logtime
            from
                (SELECT username, tradingpwd
                FROM USERLOGIN
                WHERE UPPER(USERNAME) = UPPER(p_username) AND STATUS = 'A') a, dual;*/
            PLOG.error(pkgctx,'EXCEPTION OTP ERROR:');
            plog.setendsection(pkgctx, 'PR_VALIDATE_OTP');
            return;
        END;

        PLOG.error(pkgctx,'PR_VALIDATE_PIN. Thong Tin OK: l_Count:' || l_Count);

        IF l_Count > 0 THEN
            UPDATE USERLOGIN
            SET EXPSTATUS = 'O'
            WHERE USERNAME = p_username
            AND STATUS = 'A';
            l_errors := systemnums.C_SUCCESS;
            p_err_code := systemnums.C_SUCCESS;
            plog.setendsection(pkgctx, 'PR_VALIDATE_OTP');
            return;
            --RETURN l_errors;
        ELSE
            /*UPDATE USERLOGIN
            SET EXPSTATUS = 'E'
            WHERE USERNAME = p_username;*/
            l_errors := '-901216'; --Mat khau khong chinh xac
            p_err_code := '-901216';
            plog.setendsection(pkgctx, 'PR_VALIDATE_OTP');
            return;
        END IF;


EXCEPTION WHEN OTHERS THEN
    p_err_code := l_errors;
    plog.error(pkgctx, 'Loi xay ra p_err_code:' || p_err_code || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'PR_VALIDATE_OTP');
END PR_VALIDATE_OTP;
--TOANNDS MOVE FROM PHS
--VALIDATE OTP PASS
PROCEDURE PR_VALIDATE_PIN
        (p_username IN VARCHAR2,
         p_LoginCustID IN VARCHAR2,
         p_pin      IN VARCHAR2,
         p_via      IN VARCHAR2,
         p_savesms  IN VARCHAR2,
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2)
AS
l_status    char(1);
l_pin       varchar2(100);
l_errors    VARCHAR2(10);
l_authtype  varchar2(5);
l_logintype varchar2(5);
l_pinencrypt varchar2(100);
l_custid    varchar(10);
l_savesms varchar2(3);
l_Count     Number;
v_currdate date;
BEGIN
    plog.setBeginSection(pkgctx, 'PR_VALIDATE_PIN');
       l_errors := errnums.C_SYSTEM_ERROR;
    p_err_code := errnums.C_SYSTEM_ERROR;
    l_pinencrypt := GENENCRYPTPASSWORD(p_pin);
    v_currdate:=getcurrdate;
    PLOG.error(pkgctx,'PR_VALIDATE_PIN. Thong Tin OK1: p_LoginCustID:' || p_LoginCustID||'/ '||p_username);
    BEGIN --Lay loai hinh dang ky dich vu truc tuyen cua khach hang


        SELECT CUSTID INTO l_custid
        FROM CFMAST
        WHERE CUSTODYCD = p_username;

        SELECT o.authtype
        INTO l_authtype
        FROM cfmast u, otright o
        WHERE  u.custodycd = p_username and o.deltd='N' and o.via= p_via and u.custid=o.cfcustid and o.authcustid =p_LoginCustID;


        PLOG.error(pkgctx,'PR_VALIDATE_PIN. Thong Tin OK: p_username:' || l_authtype);
    exception
      when NO_DATA_FOUND then
        l_errors := '-100097'; --Khach hang khong su dung dich vu OTP
        p_err_code := '-100097';
        plog.error(pkgctx, 'Loi xay ra lay thong tin khac hang OTP p_err_code:' || p_username || dbms_utility.format_error_backtrace);
        return;
    END;

       IF p_savesms='N' THEN --Check thoi gian nhap mat khau OTP
        IF l_authtype = '1' and p_via = 'O' THEN

                SELECT COUNT(*) INTO l_Count
                FROM USERLOGIN
                WHERE UPPER(USERNAME) = UPPER(p_username)
                    AND UPPER(OTPPWD) = UPPER(l_pinencrypt)
                    AND EXPSTATUS = 'N';
                    --AND SYSDATE BETWEEN LOGINDATETIME AND EXPDATETIME;
                PLOG.error(pkgctx,'PR_VALIDATE_PIN. Thong Tin OK:l_authtype-1-l_Count:' || l_Count);

            IF l_Count > 0 THEN
                UPDATE USERLOGIN SET EXPSTATUS = 'O' WHERE USERNAME = p_username AND STATUS = 'A';
                PLOG.error(pkgctx,'Check OK:');
                l_errors := systemnums.C_SUCCESS;
                p_err_code := systemnums.C_SUCCESS;
                return;
            ELSE
                l_errors := '-901216'; --Mat khau khong chinh xac
                p_err_code := '-901216';
                return;
            END IF;
        END IF;
        -------
        IF l_authtype ='5' and p_via = 'O' THEN
            -- Kiem tra Thoi han mat khau
            SELECT COUNT(*) INTO l_Count
            FROM VALIDATEPIN_LOG V
            WHERE UPPER(V.USERNAME) = UPPER(p_username)
               AND V.EXPDATETIME < SYSDATE
               AND V.STATUS = 'P'
               AND V.VIA=p_via;

            PLOG.error(pkgctx,'PR_VALIDATE_PIN. Kiem tra: l_Count:' || l_Count);

            IF l_Count > 0 THEN
                --Cap nhat lai trang thai de khach hang xin lai OTP SMS
                UPDATE VALIDATEPIN_LOG SET PSTATUS=PSTATUS||STATUS,STATUS='E',lastchange=SYSDATE
                    WHERE USERNAME=UPPER(p_username) and VIA=p_via and STATUS = 'P';

                l_errors := '-901217'; --Mat khau OTP het hieu luc
                p_err_code := '-901217';
                PLOG.error(pkgctx,'Kiem tra-timeout: l_Count:' || l_errors);
                return;
            END IF;

            -- Kiem tra mat khau
            SELECT COUNT(*) INTO l_Count
            FROM VALIDATEPIN_LOG V
            WHERE UPPER(V.USERNAME) = UPPER(p_username)
               AND UPPER(V.OTPPWD) = UPPER(l_pinencrypt)
               AND V.EXPDATETIME>= SYSDATE
               AND V.STATUS = 'P'
               AND V.VIA=p_via;
            PLOG.error(pkgctx,'PR_VALIDATE_PIN. Kiem tra 2: l_Count:' || l_Count);
        IF l_Count > 0 THEN
            --Cap nhat lai trang thai de khach hang xin lai OTP SMS
            UPDATE VALIDATEPIN_LOG SET PSTATUS=PSTATUS||STATUS,STATUS='B',lastchange=SYSDATE
                WHERE USERNAME=UPPER(p_username) and VIA=p_via and STATUS = 'P';

            PLOG.error(pkgctx,'Check OK:');
            l_errors := systemnums.C_SUCCESS;
            p_err_code := systemnums.C_SUCCESS;
            return;
        ELSE
            l_errors := '-901216'; --Mat khau khong chinh xac
            p_err_code := '-901216';
            PLOG.error(pkgctx,'Kiem tra-error: l_Count:' || l_errors);
            return;
        END IF;

       END IF;
    ELSE
        IF l_authtype = '1' THEN
            BEGIN
                SELECT COUNT(*) INTO l_Count
                FROM USERLOGIN
                WHERE UPPER(USERNAME) = UPPER(p_username)
                    AND UPPER(OTPPWD) = UPPER(l_pinencrypt)
                    AND EXPSTATUS = 'N';
                    --AND SYSDATE BETWEEN LOGINDATETIME AND EXPDATETIME;
                PLOG.error(pkgctx,'Check OK:');
            EXCEPTION
                --TRuyen vao sai username se lock pass
                when NO_DATA_FOUND  THEN
                l_errors := '-901216'; --Mat khau OTP khong chinh xac
                p_err_code := '-901216';
                l_Count :=  0;
                PLOG.error(pkgctx,'EXCEPTION OTP ERROR:');
                return;
            END;

            PLOG.error(pkgctx,'PR_VALIDATE_PIN. Thong Tin OK: l_Count:' || l_Count);

            IF l_Count > 0 THEN
                UPDATE USERLOGIN
                SET EXPSTATUS = 'O'
                WHERE USERNAME = p_username
                AND STATUS = 'A';
                l_errors := systemnums.C_SUCCESS;
                p_err_code := systemnums.C_SUCCESS;

                return;
                --RETURN l_errors;
            ELSE
                l_errors := '-901216'; --Mat khau khong chinh xac
                p_err_code := '-901216';

                return;
            END IF;
        END IF;
        -------
        IF l_authtype ='5' and p_via = 'O' THEN
            -- Kiem tra mat khau
            SELECT COUNT(*) INTO l_Count
            FROM VALIDATEPIN_LOG V
            WHERE UPPER(V.USERNAME) = UPPER(p_username)
               AND UPPER(V.OTPPWD) = UPPER(l_pinencrypt)
               AND V.STATUS IN ('B','P')
               AND V.VIA=p_via;
        PLOG.error(pkgctx,'PR_VALIDATE_PIN. Kiem tra 3: l_Count:' || l_Count);
        IF l_Count > 0 THEN
            --Cap nhat lai trang thai de khach hang xin lai OTP SMS
            UPDATE VALIDATEPIN_LOG SET PSTATUS=PSTATUS||STATUS,STATUS='C',lastchange=SYSDATE
                WHERE USERNAME=UPPER(p_username) and VIA=p_via and STATUS IN ('B','P');

            INSERT INTO VALIDATEPIN_LOG(AUTOID,USERNAME,OTPPWD,EXPDATETIME,VIA,STATUS,PSTATUS,TXDATE,LASTCHANGE)
            VALUES(SEQ_VALIDATEPIN_LOG.NEXTVAL,UPPER(p_username),l_pinencrypt,SYSDATE,p_via,'B','',v_currdate,SYSDATE);
            COMMIT;

            PLOG.error(pkgctx,'Check OK:');
            l_errors := systemnums.C_SUCCESS;
            p_err_code := systemnums.C_SUCCESS;
            return;
        ELSE
            l_errors := '-901216'; --Mat khau khong chinh xac
            p_err_code := '-901216';
            return;
        END IF;
       END IF;
    END IF;


EXCEPTION WHEN OTHERS THEN
    p_err_code := l_errors;
    plog.error(pkgctx, 'Loi xay ra PR_VALIDATE_PIN p_err_code:' || p_err_code || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'PR_VALIDATE_PIN');
END PR_VALIDATE_PIN;

PROCEDURE GET_MODULE_PERMISSION(p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR, pv_strCUSTID IN VARCHAR2, pv_strVIA IN VARCHAR2 DEFAULT 'A') is
v_count number;
v_via   varchar2(10);
v_AuthType varchar2(3);
BEGIN
    plog.setbeginsection(pkgctx, 'GET_MODULE_PERMISSION');
    select count(*) into v_count
           FROM OTRIGHT O, OTRIGHTDTL D, afmast af
                      WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
                      AND D.DELTD = 'N' AND O.DELTD = 'N'
                      AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
                      AND o.via  IN ( pv_strVIA,'A')
                      AND o.via= d.via
                      AND o.deltd = 'N'
                      AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N';

    if v_count > 0 then
       select via into v_via
        from
        (select * from (
            (select case when o.via =pv_strVIA then 0 else 1 end stt,o.via, rownum   FROM OTRIGHT O, OTRIGHTDTL D, afmast af
                        WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
                        AND D.DELTD = 'N' AND O.DELTD = 'N'
                        AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
                        AND o.via  IN ( pv_strVIA,'A')
                        AND o.via= d.via
                        AND o.deltd = 'N'
                        AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N'
            ) order by stt)
        )
        where rownum=1;

        --OPEN p_REFCURSOR FOR

        IF v_via <> 'A' THEN
            select authtype into v_AuthType from otright where AUTHCUSTID = pv_strCUSTID and via=v_via and deltd<>'Y' and rownum=1;
            IF v_AuthType='4' then
            OPEN p_REFCURSOR FOR
                  SELECT  o.via,D.AUTOID,D.CFCUSTID,D.AUTHCUSTID,D.OTMNCODE,D.DELTD,
                          D.OTRIGHT,AF.ACCTNO AFACCTNO,O.AUTHTYPE
                      FROM OTRIGHT O, OTRIGHTDTL D, afmast af
                      WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
                      AND D.DELTD = 'N' AND O.DELTD = 'N'
                      AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
                      AND o.via = v_via
                      AND o.via= d.via
                      AND o.deltd = 'N'
                      AND D.OTMNCODE IN ('COND_ORDER','ORDINPUT','GROUP_ORDER')
                      AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N'
                  union all
                  SELECT  o.via,D.AUTOID,D.CFCUSTID,D.AUTHCUSTID,D.OTMNCODE,D.DELTD,
                          D.OTRIGHT,AF.ACCTNO AFACCTNO,O.AUTHTYPE
                      FROM OTRIGHT O, OTRIGHTDTL D, afmast af
                      WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
                      AND D.DELTD = 'N' AND O.DELTD = 'N'
                      AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
                      AND o.via = 'A'
                      AND o.via= d.via
                      AND o.deltd = 'N'
                      AND D.OTMNCODE NOT IN ('COND_ORDER','ORDINPUT','GROUP_ORDER')
                      AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N';
            ELSE
            OPEN p_REFCURSOR FOR
                SELECT  o.via,D.AUTOID,D.CFCUSTID,D.AUTHCUSTID,D.OTMNCODE,D.DELTD,
                      D.OTRIGHT,AF.ACCTNO AFACCTNO,O.AUTHTYPE
                  FROM OTRIGHT O, OTRIGHTDTL D, afmast af
                  WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
                  AND D.DELTD = 'N' AND O.DELTD = 'N'
                  AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
                  AND o.via = v_via
                  AND o.via= d.via
                  AND o.deltd = 'N'
                  AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N';
            END IF;
        ELSE
        OPEN p_REFCURSOR FOR
            SELECT  o.via,D.AUTOID,D.CFCUSTID,D.AUTHCUSTID,D.OTMNCODE,D.DELTD,
                  D.OTRIGHT,AF.ACCTNO AFACCTNO,O.AUTHTYPE
              FROM OTRIGHT O, OTRIGHTDTL D, afmast af
              WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
              AND D.DELTD = 'N' AND O.DELTD = 'N'
              AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
              AND o.via = v_via
              AND o.via= d.via
              AND o.deltd = 'N'
              AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N';
        END IF;
/*          SELECT  o.via,D.AUTOID,D.CFCUSTID,D.AUTHCUSTID,D.OTMNCODE,D.DELTD,
                  D.OTRIGHT,AF.ACCTNO AFACCTNO,O.AUTHTYPE
              FROM OTRIGHT O, OTRIGHTDTL D, afmast af
              WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
              AND D.DELTD = 'N' AND O.DELTD = 'N'
              AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
              AND o.via = v_via
              AND o.via= d.via
              AND o.deltd = 'N'
              AND D.OTMNCODE IN ('COND_ORDER','ORDINPUT','GROUP_ORDER')
              AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N'
          union all
          SELECT  o.via,D.AUTOID,D.CFCUSTID,D.AUTHCUSTID,D.OTMNCODE,D.DELTD,
                  D.OTRIGHT,AF.ACCTNO AFACCTNO,O.AUTHTYPE
              FROM OTRIGHT O, OTRIGHTDTL D, afmast af
              WHERE O.AUTHCUSTID = D.AUTHCUSTID AND O.CFCUSTID = D.CFCUSTID
              AND D.DELTD = 'N' AND O.DELTD = 'N'
              AND O.AUTHCUSTID = pv_strCUSTID AND o.AUTHCUSTID=af.custid
              AND o.via = 'A'
              AND o.via= d.via
              AND o.deltd = 'N'
              AND D.OTMNCODE NOT IN ('COND_ORDER','ORDINPUT','GROUP_ORDER')
              AND getcurrdate <= O.EXPDATE AND AF.ISFIXACCOUNT = 'N';*/
    else
      open p_REFCURSOR for select * from dual where 0 = 1;
    end if;
    plog.setendsection(pkgctx, 'GET_MODULE_PERMISSION');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'GET_MODULE_PERMISSION');
END GET_MODULE_PERMISSION;

function FN_CHECK_SERIAL_CA
  (P_CUSTID in varchar2,
  P_VIA in VARCHAR2,
   P_SERIAL in varchar2
   )  RETURN Number as
   v_count number;
  begin

    SELECT COUNT(*) INTO v_count
    FROM OTRIGHT T
    WHERE T.CFCUSTID = P_CUSTID AND T.VIA in('A', P_VIA)
          AND T.SERIALNUMSIG = P_SERIAL
          AND T.DELTD <>'Y' AND T.VALDATE <= getcurrdate; --AND T.EXPDATE >= getcurrdate;
    IF(v_count > 0) THEN
    return systemnums.C_SUCCESS;
    ELSE  return -1;
    END IF;
  exception
    when others then
      return -1;
  end FN_CHECK_SERIAL_CA;

--GEN OTP PASS
PROCEDURE PR_GEN_OTPSMSEMAILWEB(
                    p_username      IN varchar2,
                    p_afacctno      IN varchar2,
                    p_otauthtype    IN VARCHAR2,
                    p_via           IN VARCHAR2,
                    p_err_code       in out varchar2,
                    p_err_param      in out varchar2)
as

l_username varchar2(50);
l_status   char(1);
l_expstatus  char(1);
l_custid    varchar2(50);
l_authtype       char(1);
l_passleng   number(5);
l_mobilesms  varchar2(20);
l_email      varchar2(500);
l_datasourcesql VARCHAR2(200);
l_userpass      VARCHAR2(250);
l_newpin        VARCHAR2(250);
l_typetrade     VARCHAR2(1000);
l_fullname      VARCHAR2(500);
l_custodycode   VARCHAR2(20);
l_smstemplates     VARCHAR2(5);
l_pinencrypt    VARCHAR2(100);
l_afacctno      varchar2(20);
l_otpTimeOut NUMBER;
v_count number;
v_shortname varchar2(10);
l_namevia varchar2(100);
v_currdate date;
begin
p_err_code  := systemnums.C_SUCCESS;
p_err_param := 'SUCCESS';
plog.error('Gen Pass OTPSMS-PR_GEN_OTPSMSEMAILWEB:' ||p_username||'/ '||p_afacctno||' / '||p_otauthtype||' / '||p_via||' / '|| p_err_code);
v_currdate:= getcurrdate;
SELECT TO_NUMBER(VARVALUE) INTO l_passleng FROM SYSVAR WHERE VARNAME = 'OTPPASSLENG';
SELECT TO_NUMBER(VARVALUE) INTO l_otpTimeOut FROM SYSVAR WHERE VARNAME = 'OTPPASSTIMEOUT';

BEGIN
     SELECT VARVALUE INTO v_shortname
     FROM SYSVAR
     WHERE VARNAME='COMPANYSHORTNAME' AND GRNAME='SYSTEM';
EXCEPTION
WHEN others THEN -- caution handles all exceptions
   v_shortname:='BMSC';
END;

begin
    SELECT U.USERNAME, U.AUTHTYPE,C.CUSTID,C.STATUS,C.FULLNAME
        into l_username, l_authtype, l_custid, l_status,l_fullname
    FROM USERLOGIN U, CFMAST C
    WHERE UPPER(U.USERNAME) = UPPER(P_USERNAME)
        AND C.CUSTODYCD = U.USERNAME
        AND U.STATUS = 'A';

    SELECT count(*) into v_count
    FROM OTRIGHT
    WHERE CFCUSTID=l_custid AND AUTHTYPE=p_otauthtype AND VIA=p_via;

  if nvl(l_status, 'X') <> 'A' then
    p_err_code := C_FO_CUSTOMER_STATUS_INVALID;
    raise errnums.E_BIZ_RULE_INVALID;
  end if;

  IF v_count=0 THEN
    p_err_code := '-100097'; --MA LOI: KHACH HANG KHONG SU DUNG DICH VU XAC THUC MAT KHAU
    RETURN;
  END IF;

exception
  when NO_DATA_FOUND then
    p_err_code := C_FO_USER_DOES_NOT_EXISTED;
    raise errnums.E_BIZ_RULE_INVALID;
end;

if p_err_code = systemnums.C_SUCCESS then
    IF v_count > 0 THEN

        SELECT LOWER(CSPKS_SYSTEM.fn_random_num(l_passleng)) INTO l_newpin FROM DUAL;
        SELECT genencryptpassword(l_newpin) INTO l_pinencrypt FROM DUAL;

        UPDATE VALIDATEPIN_LOG SET PSTATUS=PSTATUS||STATUS,STATUS='E',lastchange=SYSDATE
        WHERE USERNAME=UPPER(p_username) and VIA=p_via and STATUS IN ('B','P'); --and EXPDATETIME < SYSDATE;

        INSERT INTO VALIDATEPIN_LOG(AUTOID,USERNAME,OTPPWD,EXPDATETIME,VIA,STATUS,PSTATUS,TXDATE,LASTCHANGE)
        VALUES(SEQ_VALIDATEPIN_LOG.NEXTVAL,UPPER(l_username),l_pinencrypt,SYSDATE + l_otpTimeOut/1440,p_via,'P','',v_currdate,SYSDATE);
        COMMIT;

        BEGIN
            SELECT V.MOBILESMS, AF.ACCTNO, V.CUSTODYCD
                into l_mobilesms, l_afacctno, l_custodycode
            FROM CFMAST V, AFMAST AF
            WHERE AF.CUSTID = V.CUSTID AND V.CUSTODYCD= l_username AND AF.ACCTNO = p_afacctno;
        EXCEPTION
        WHEN OTHERS THEN
             L_MOBILESMS := '';
        END ;

        IF p_via='O' THEN
            l_namevia:=' Online Trading. ';
        ELSIF p_via='H' THEN
            l_namevia:=' Home Trading. ';
        ELSIF p_via='M' THEN
            l_namevia:=' Mobile Trading. ';
        END IF;

        IF substr(l_custodycode,4,1) = 'F' THEN
            l_typetrade := v_shortname||'-Notice: You are using'|| l_namevia || 'Please put in authentication code '||l_newpin||' within ' || l_otpTimeOut || ' minutes for confirmation';
        ELSE
            l_typetrade := v_shortname||'-TB: Quy khach dang thuc hien giao dich tren'|| l_namevia || 'Vui long nhap ma xac thuc '||l_newpin||' trong ' || l_otpTimeOut || ' phut de xac nhan';
        END IF;

        l_typetrade:= 'SELECT ''' || l_typetrade || ''' detail from dual';

        IF( TRIM(l_mobilesms) IS NOT NULL) THEN
              nmpks_ems.InsertEmailLog(l_mobilesms, '338A', l_typetrade,l_afacctno);
        END IF;

        plog.error(pkgctx, 'INSERT OTP SMS OK');
    END IF;
end if;
plog.setEndSection(pkgctx, 'sp_login');
exception
when errnums.E_BIZ_RULE_INVALID then
  for i in (select errdesc, en_errdesc
              from deferror
             where errnum = p_err_code)
  loop
    p_err_param := i.errdesc;

    sp_audit_authenticate(p_username, C_FO_LOG, '', p_err_param);
  end loop;
  plog.setEndSection(pkgctx, 'PR_GEN_OTPSMSEMAIL');
when others then
  p_err_code := errnums.C_SYSTEM_ERROR;
  plog.setEndSection(pkgctx, 'PR_GEN_OTPSMSEMAIL');
END PR_GEN_OTPSMSEMAILWEB;

PROCEDURE PR_REGISTERONLINEAUTHTYPE(
    p_afacctno      IN  varchar2,
    p_via           IN  varchar2,
    p_authtype      IN  OUT varchar2,
    p_serialnumber  IN  varchar2,
    p_idcode        IN  varchar2,
    p_username      IN  varchar2,
    p_err_code      in OUT varchar2,
    p_err_param   in OUT varchar2)
as
    l_custid varchar2(20);
    l_afacctno varchar2(20);
    l_authtype varchar2(5);
    l_authtypechange varchar2(5);
    l_count number;
    l_currdate date;
    l_expdate date;
    l_idcode varchar2(20);
Begin
    plog.setBeginSection(pkgctx, 'PR_REGISTERONLINEAUTHTYPE');
    p_err_code  := systemnums.C_SUCCESS;
    p_err_param := 'SUCCESS';

    l_currdate:=getcurrdate;
    l_afacctno:=p_afacctno;
    l_authtype:=p_authtype;
    l_expdate:= to_date(sysdate,'DD/MM/RRRR') + INTERVAL '99' YEAR + INTERVAL '12' MONTH;
    select custid into l_custid
    from afmast
    where acctno=l_afacctno;

    select count(*) into l_count
    from otright
    where cfcustid=l_custid and authtype=l_authtype and via=p_via and deltd <> 'Y';

    IF l_count > 0 THEN
        p_authtype:=l_authtype;
        p_err_code := '-200312';
        RETURN;
    END IF;

    begin
        select authtype into l_authtypechange
        from otright
        where cfcustid=l_custid and via=p_via and deltd <> 'Y' and authtype<>l_authtype and authtype<>'A';

        IF l_authtypechange<>l_authtype and l_authtypechange<>'A' THEN
            --p_authtype:=l_authtypechange;
            p_err_code := '-200315';
            RETURN;
        END IF;
    EXCEPTION WHEN others THEN
        l_authtype:=p_authtype;
    END;
    -- Check chinh chu
    Select idcode into l_idcode
    from cfmast
    where custid=l_custid;

    if(l_idcode!=p_idcode) then
        p_authtype := l_authtype;
        p_err_code := '-200316';
        RETURN;
    end if;

    --Dang ky dich vu Otright
   insert into otright(autoid,cfcustid,authcustid,authtype,valdate,expdate,deltd,lastdate,lastchange,serialtoken,via,serialnumsig)--,tlname)
   VALUES (seq_otright.nextval,l_custid,l_custid,l_authtype,l_currdate,l_expdate,'N',null,sysdate,p_serialnumber,p_via,p_serialnumber);--,p_username);

    if l_authtype = '5' then
        for rec in
        (
            SELECT * FROM ALLCODE WHERE CDTYPE = 'SA' AND CDNAME = 'OTFUNC' AND CDUSER='Y' ORDER BY LSTODR
        )loop
            IF rec.cdval NOT IN ('COND_ORDER','ORDINPUT','GROUP_ORDER') THEN
                insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYNNNNN','N',p_via);
            ELSE
                insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYNNNNY','N',p_via);
            END IF;
        end loop;
    end if;

    plog.setEndSection(pkgctx, 'PR_REGISTERONLINEAUTHTYPE');
    exception
        when errnums.E_BIZ_RULE_INVALID then
          for i in (select errdesc, en_errdesc
                      from deferror
                     where errnum = p_err_code)
          loop
            p_err_param := i.errdesc;
            sp_audit_authenticate(p_username, C_FO_LOG, '', p_err_param);
          end loop;
          plog.setEndSection(pkgctx, 'PR_REGISTERONLINEAUTHTYPE');
        when others then
            p_authtype:=-1;
            p_err_code := errnums.C_SYSTEM_ERROR;
            plog.setEndSection(pkgctx, 'PR_REGISTERONLINEAUTHTYPE');
END PR_REGISTERONLINEAUTHTYPE;

PROCEDURE PR_CANCELONLINEAUTHTYPE(
    p_afacctno      IN  varchar2,
    p_via           IN  varchar2,
    p_authtype      IN  varchar2,
    p_serialnumber  IN  varchar2,
    p_username      IN  varchar2,
    p_err_code      in OUT varchar2,
    p_err_param   in OUT varchar2)
as
    l_custid varchar2(20);
    l_afacctno varchar2(20);
    l_authtype varchar2(5);
    l_count number;
Begin
    plog.setBeginSection(pkgctx, 'PR_CANCELONLINEAUTHTYPE');
    p_err_code  := systemnums.C_SUCCESS;
    p_err_param := 'SUCCESS';

    l_afacctno:=p_afacctno;
    l_authtype:=p_authtype;

    select custid into l_custid
    from afmast
    where acctno=l_afacctno;

    select count(*) into l_count
    from otright
    where cfcustid=l_custid and authtype=l_authtype and via=p_via and deltd <> 'Y';

    IF l_count = 0 THEN
        p_err_code := '-200313';
        RETURN;
    END IF;

    --Huy dich vu truc tuyen Otright
    Update otright set deltd='Y'
        where cfcustid=l_custid and authtype=l_authtype and via=p_via;

    Update otrightdtl set deltd='Y'
        where cfcustid=l_custid and via=p_via;

    plog.setEndSection(pkgctx, 'PR_CANCELONLINEAUTHTYPE');
    exception
        when errnums.E_BIZ_RULE_INVALID then
          for i in (select errdesc, en_errdesc
                      from deferror
                     where errnum = p_err_code)
          loop
            p_err_param := i.errdesc;
            sp_audit_authenticate(p_username, C_FO_LOG, '', p_err_param);
          end loop;
          plog.setEndSection(pkgctx, 'PR_CANCELONLINEAUTHTYPE');
        when others then
            p_err_code := errnums.C_SYSTEM_ERROR;
            plog.setEndSection(pkgctx, 'PR_CANCELONLINEAUTHTYPE');
END PR_CANCELONLINEAUTHTYPE;

/*PROCEDURE pr_GetBankList (p_REF_CURSOR IN OUT PKG_REPORT.REF_CURSOR, p_bankcode IN varchar2)
IS
    v_bankcode varchar2(50);
BEGIN
    plog.setBeginSection(pkgctx, 'pr_GetBankList');

    if p_bankcode is null or p_bankcode ='' or upper(p_bankcode)='ALL' then
        v_bankcode := '%';
    else
        v_bankcode := p_bankcode;
    end if;

     OPEN p_REF_CURSOR FOR
        SELECT BANKCODE CDVAL, BANKNAME CDCONTENT, EN_BANKNAME EN_CDCONTENT
            FROM BANKLIST
            WHERE STATUS ='A' and BANKCODE like v_bankcode;

    plog.setendsection(pkgctx, 'pr_GetBankList');
EXCEPTION
WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_GetBankList');
END pr_GetBankList;

procedure PR_Get_Cfotheracc
    --Lay DS dang ky chuyen tien ra ngoai
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_cfotheraccid in VARCHAR2 --Neu xem DS thi mac dinh ALL, neu sua thi truyen Ma dky chuyen tien
    )
IS
    V_CUSTODYCD     varchar2(10);
    v_cfotheraccid varchar2 (100);

begin
    plog.setbeginsection(pkgctx, 'PR_Get_Cfotheracc');

    IF p_custodycd = 'ALL' OR p_custodycd is NULL THEN
        V_CUSTODYCD := '%';
    ELSE
        V_CUSTODYCD := p_custodycd;
    END IF;

    IF p_cfotheraccid = 'ALL' OR p_cfotheraccid is NULL THEN
        v_cfotheraccid := '%';
    ELSE
        v_cfotheraccid := p_cfotheraccid;
    END IF;

    Open p_refcursor for
         select co.autoid, co.bankacc, co.BANKACNAME, co.bankname, co.cityef, co.citybank, co.bankcode,
                DECODE(co.chstatus,'C',(select cdcontent from allcode where cdname ='STATUS' and cdtype ='SA' and cdval ='A'),al.cdcontent) status,
                DECODE(co.chstatus,'C',(select EN_cdcontent from allcode where cdname ='STATUS' and cdtype ='SA' and cdval ='A'),al.EN_cdcontent) EN_status
            from cfotheracc co ,cfmast cf, (select * from allcode where cdname ='CHSTATUS' and cdtype ='SA') al
            where  co.type = '1' and co.chstatus = al.cdval
                and co.cfcustid = cf.custid
                and cf.custodycd like V_CUSTODYCD
                and co.autoid like v_cfotheraccid;

    plog.setendsection(pkgctx, 'PR_Get_Cfotheracc');
exception when others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace);
      plog.setendsection(pkgctx, 'PR_Get_Cfotheracc');
end PR_Get_Cfotheracc;

PROCEDURE PR_Change_cfotheracc
    --Them/Thay doi thong tin dang ky chuyen tien
        (
         p_custodycd IN VARCHAR2,
         p_action   IN varchar2, --yeu cau: ADD/EDIT/DELETE
         p_bankacc in varchar2, --So tai khoan NH
         p_bankacname in varchar2, --Ten chu tai khoan
         p_bankcode in varchar2, --Ma NH
         p_cityef in varchar2, --Tinh TP
         p_citybank in varchar2, --Chi nhanh
         p_cfo_id   in varchar2,
         p_err_code IN OUT VARCHAR2,
         p_errparm  IN OUT VARCHAR2)
AS
    l_custid    varchar2(20);
    l_count     number;
    V_BANKNAME  varchar2(2000);

BEGIN
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.setBeginSection(pkgctx, 'PR_Change_cfotheracc');
    plog.error(pkgctx,'p_action:'||p_action||', p_custodycd='||p_custodycd||', p_bankacc='||p_bankacc||', p_bankacname='||p_bankacname||', p_bankcode='||p_bankcode);
    BEGIN
        SELECT CUSTID INTO l_custid
        FROM CFMAST
        WHERE custodycd = p_custodycd;

    exception
      when others then
        p_err_code := '-200002';
        plog.error(pkgctx, 'KHong tim thay KH p_err_code:' ||-200002||'. p_custodycd='|| p_custodycd||'.Error:' ||SQLERRM|| dbms_utility.format_error_backtrace);
        plog.setendsection(pkgctx, 'PR_Change_cfotheracc');
        return;
    END;

    if p_action = 'ADD' then
        --check trung so TK NH
        select count(*) into  l_count
        from cfotheracc
        where trim(upper(bankacc)) = trim(upper(REPLACE(p_bankacc,' ','')))
            and CFCUSTID = l_custid ;
        if l_count > 0 then
            p_err_code := '-100832';
            plog.error(pkgctx, 'p_err_code:'||p_err_code||', p_action:'||p_action||', p_custodycd:'||p_custodycd||', l_custid:'||l_custid);
            plog.setendsection(pkgctx, 'PR_PrevChange_cfotheracc');
            return;
        end if;

        --check TK chinh chu
        select count(*) into  l_count
        from cfmast
        where CUSTID = l_custid and fn_CutOffUTF8(upper(fullname)) = fn_CutOffUTF8(upper(p_bankacname));
        if l_count = 0 then
            p_err_code := '-100834';
            plog.error(pkgctx, 'p_err_code:'||p_err_code||', p_action:'||p_action||', p_custodycd:'||p_custodycd||', l_custid:'||l_custid);
            plog.setendsection(pkgctx, 'PR_PrevChange_cfotheracc');
            return;
        end if;

        --Check moi KH chi duoc dang ky 3 tai khoan
        select count(*) into  l_count
        from cfotheracc
        where  CFCUSTID = l_custid ;

        if l_count >= 3 then
            p_err_code := '-100833';
            plog.error(pkgctx, 'p_err_code:'||p_err_code||', p_action:'||p_action||', p_custodycd:'||p_custodycd||', l_custid:'||l_custid);
            plog.setendsection(pkgctx, 'PR_Change_cfotheracc');
            return;
        end if;

    end if;

    if p_action = 'DELETE' then
        delete cfotheracc where autoid = p_cfo_id and cfcustid =l_custid;

    elsif p_action = 'ADD' then
        BEGIN
            SELECT BANKNAME INTO V_BANKNAME FROM BANKLIST WHERE BANKCODE = P_BANKCODE;
            EXCEPTION WHEN OTHERS THEN
                V_BANKNAME := '';
        END;

        INSERT INTO cfotheracc (autoid, cfcustid, bankacc, bankacname, bankname, type , cityef, citybank, bankcode, chstatus)
        select seq_cfotheracc.NEXTVAL, l_custid, p_bankacc, p_bankacname , v_bankname, '1', p_cityef, p_citybank, p_bankcode, 'C'
        from dual;
    end if;

    p_err_code := systemnums.C_SUCCESS;
    plog.setendsection(pkgctx, 'PR_Change_cfotheracc');
    return;
EXCEPTION WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.error(pkgctx, 'Loi xay ra p_err_code:' || p_err_code ||'.Error:'||SQLERRM|| dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'PR_Change_cfotheracc');
END PR_Change_cfotheracc;*/

begin
  -- Initialization
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('fopks_api',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));

end fopks_api;
/
