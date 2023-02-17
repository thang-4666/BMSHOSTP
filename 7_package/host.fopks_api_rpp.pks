SET DEFINE OFF;
CREATE OR REPLACE PACKAGE fopks_api_rpp IS

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



procedure pr_get_ciacount
    (p_refcursor in out pkg_report.ref_cursor,
    p_custodycd in VARCHAR2,
    p_afacctno  IN  varchar2,
    PAGE_RPP IN NUMBER,
    ROWS_RPP IN NUMBER);

 PROCEDURE pr_ExternalTransfer(p_account varchar,
                            p_bankid varchar2,
                            p_benefbank varchar2,
                            p_benefacct varchar2,
                            p_benefcustname varchar2,
                            p_beneflicense varchar2,
                            p_amount number,
                            p_feeamt number,
                            p_vatamt number,
                            p_desc varchar2,
                            p_citybank varchar2,
                            p_cityef   varchar2,
                            p_err_code  OUT varchar2,
                            p_err_message out varchar2);

procedure pr_get_rightofflist(
    p_refcursor in out pkg_report.ref_cursor,
    p_afacctno in varchar2,
    PAGE_RPP IN NUMBER,
    ROWS_RPP IN NUMBER
    );

PROCEDURE pr_GetOrder
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     EXECTYPE      IN  VARCHAR2,
     STATUS         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER); -- Lay thong tin lenh giao dich

PROCEDURE pr_MoneyTransDetail
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     P_STATUS       in  varchar2 default 'ALL',
     P_PLACE        in  varchar2 default 'ALL',
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER);

PROCEDURE pr_GetCashStatement
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN       VARCHAR2,
     T_DATE         IN       VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
    ); -- Sao ke tien
PROCEDURE pr_GetSecuritiesStatement
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN       VARCHAR2,
     T_DATE         IN       VARCHAR2,
     SYMBOL         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
    ); -- Sao ke chung khoan
PROCEDURE pr_GetCashTransfer
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     STATUS         IN  VARCHAR2,
     VIA         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );    -- Lay thong tin chuyen khoan tien
PROCEDURE pr_GetRightOffInfor
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     ); -- LAY THONG TIN GD QUYEN MUA

PROCEDURE pr_GetAdvancedPayment
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN VARCHAR2,
     T_DATE         IN VARCHAR2,
     STATUS         IN VARCHAR2,
     VIA       IN VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
    ); -- LAY THONG TIN HOP DONG UNG TRUOC DA THUC HIEN

function fn_CheckActiveSystem
    return NUMBER; -- Check host & branch active or inactive

procedure pr_get_rightinfo
    (p_refcursor in out pkg_report.ref_cursor,
    PV_CUSTODYCD  IN  VARCHAR2,
    PV_AFACCTNO   IN  VARCHAR2,
    ISCOM         IN  VARCHAR2,
    F_DATE        IN VARCHAR2,
    T_DATE        IN  VARCHAR2,
    PAGE_RPP IN NUMBER,
    ROWS_RPP IN NUMBER
    );--Ham tra cuu su kien quyen
PROCEDURE pr_GetBonds2SharesList
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     ); -- HAM LAY DANH SACH THQ CHUYEN TRAI PHIEU --> CO PHIEU

PROCEDURE pr_LoanHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD    IN VARCHAR2,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );--HAM TRA CUU DU NO

  PROCEDURE pr_GetTDhist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );--Ham tra cuu tiet kiem

PROCEDURE pr_GetConvertBondHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );--Ham tra cuu chuyen doi trai phieu thanh co phieu
PROCEDURE pr_GetRePaymentHist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO       IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );--Ham tra cuu thong tin tra no

PROCEDURE pr_GetConfirmOrderHistByCust
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD      IN  VARCHAR2,
     F_DATE         IN  VARCHAR2,
     T_DATE         IN  VARCHAR2,
     EXECTYPE       IN  VARCHAR2,
     PAGE_RPP       IN NUMBER,
     ROWS_RPP       IN NUMBER
     );--Ham tra cuu lenh xac nhan
PROCEDURE pr_ConfirmOrder(
      p_Orderid varchar2,
      p_userId VARCHAR2,
      p_custid VARCHAR2,
      p_Ipadrress VARCHAR2,
      p_via varchar2 default 'O',
      F_DATE         IN  VARCHAR2,
      T_DATE         IN  VARCHAR2,
      EXECTYPE       IN  VARCHAR2,
      p_err_code out varchar2
);--ham submit xac nhan lenh son.pham chuyen tu cspks_odproc.pr_ConfirmOrder
--lay thong tin lenh khop
PROCEDURE pr_get_infomation_order
    (P_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD     IN VARCHAR2,
     ROOTORDERID        IN VARCHAR2
     );
     

--check lenh ton tai
PROCEDURE pr_get_check_orderlist
    (P_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD     IN VARCHAR2,
     AFACCTNO        IN VARCHAR2,
     ORDERID        IN VARCHAR2,
     EXECTYPE         IN VARCHAR2,
     SYMBOL             IN VARCHAR2,
     STATUS          IN VARCHAR2
     );
PROCEDURE pr_GetAFTemplates
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2
     );

PROCEDURE pr_GetNetAssetDetail_byCus
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_CUSTODYCD in varchar2,
     p_AFACCTNO    IN VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
PROCEDURE pr_GetTotalAssetInfo
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_CUSTODYCD in varchar2,
     p_AFACCTNO    IN VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
PROCEDURE pr_get_normalorderlist
    (P_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD     IN VARCHAR2,
    /* PLACECUSTID  IN VARCHAR2,
     TXDATE         IN VARCHAR2,*/
     AFACCTNO        IN VARCHAR2,
     EXECTYPE         IN VARCHAR2,
     SYMBOL             IN VARCHAR2,
     STATUS          IN VARCHAR2,
     ODTIMESTAMP     IN VARCHAR2,
     PAGE_RPP          IN NUMBER,
     ROWS_RPP        IN NUMBER
     );

PROCEDURE pr_get_seinfolist
    (P_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     CUSTODYCD     IN VARCHAR2,
     AFACCTNO        IN VARCHAR2,
     PAGE_RPP          IN NUMBER,
     ROWS_RPP         IN NUMBER
     );
--check tai khoan master cho user careby
PROCEDURE pr_check_master
    (P_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     M_CUSTODYCD     IN VARCHAR2,
     CUSTODYCD       IN VARCHAR2
     );


procedure pr_get_AfInfoToOrder
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  VARCHAR2,
    p_symbol IN VARCHAR2,
    p_price IN VARCHAR2);

PROCEDURE pr_GETCFOTHERACC
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     ACCTNO       IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
PROCEDURE pr_GETCFOTHERBANKLIST
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     ACCTNO       IN  VARCHAR2,
     MNEMONIC     in varchar2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
procedure pr_regtranferacc(p_type in varchar2,
                        p_afacctno in varchar2,
                        p_ciacctno in varchar2,
                        p_ciname in varchar2,
                        p_bankacc in varchar2,
                        p_bankacname in varchar2,
                        p_bankname in varchar2,
                        p_cityef in varchar2,
                        p_citybank in varchar2,
                        p_bankid in varchar2,
                        P_bankorgno in varchar2,
                        p_mnemonic   IN VARCHAR2,
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2
                        );-- Ham dang ky so tk chuyen khoan
procedure pr_get_stocktransferlist(
    p_refcursor in out pkg_report.ref_cursor,
    p_afacctno in varchar2,
    PAGE_RPP IN NUMBER,
    ROWS_RPP IN NUMBER
    );
PROCEDURE pr_get_selloddorderlist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     ACCTNO       IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
PROCEDURE pr_get_canceloddorderlist
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     ACCTNO       IN  VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
PROCEDURE pr_GETMSBTRANSFERLIST
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     ACCTNO       IN  VARCHAR2,
     MNEMONIC     in varchar2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
procedure pr_EditTranferacc(p_type in varchar2,-- 0 : Chuyen khoan noi bo.  1: Chuyen khoan ra NH
                        p_afacctno in varchar2,-- So tieu khoan goc
                        p_ciacctno in varchar2,-- So tieu khoan nhan trong truong hop chuyen khoan noi bo
                        p_ciname in varchar2,  -- Ten tieu khoan nhan trong truong hop chuyen khoan noi bo
                        p_bankacc in varchar2, -- So tk Ngan hang
                        p_bankacname in varchar2, -- Ten chu TK ngan hang
                        p_ciacctno_old in varchar2,-- So tieu khoan nhan cu trong truong hop chuyen khoan noi bo
                        p_bankacc_old in varchar2, -- So tk Ngan hang cu
                        p_mnemonic   IN VARCHAR2,  --ten goi nho tren online
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2
                        ); -- Ham sua so tk chuyen khoan -- Ham sua so tk chuyen khoan     
PROCEDURE pr_GETDESTTRFACCTLIST
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     ACCTNO       IN  VARCHAR2,
     MNEMONIC     in varchar2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
PROCEDURE pr_GetAFTemplates
    (p_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
     p_AFACCTNO    IN VARCHAR2,
     P_TYPE     IN VARCHAR2,
     PAGE_RPP IN NUMBER,
     ROWS_RPP IN NUMBER
     );
END fopks_api_rpp;

 
 
 
 
/
