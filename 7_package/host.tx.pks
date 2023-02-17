SET DEFINE OFF;
CREATE OR REPLACE PACKAGE tx IS

TYPE tllog_rectype IS RECORD (
        autoid      tllog.autoid%type,
        txnum       tllog.txnum%type,
        txdate      tllog.txdate%type,
        txtime      tllog.txtime%type,
        brid        tllog.brid%type,
        tlid        tllog.tlid%type,
        offid       tllog.offid%type,
        ovrrqs      tllog.ovrrqs%type,
        chid        tllog.chid%type,
        chkid       tllog.chkid%type,
        tltxcd      tllog.tltxcd%type,
        ibt         tllog.ibt%type,
        brid2       tllog.brid2%type,
        tlid2       tllog.tlid2%type,
        ccyusage    tllog.ccyusage%type,
        off_line    tllog.off_line%type,
        deltd       tllog.deltd%type,
        brdate      tllog.brdate%type,
        busdate     tllog.busdate%type,
        txdesc      tllog.txdesc%type,
        ipaddress   tllog.ipaddress%type,
        wsname      tllog.wsname%type,
        txstatus    tllog.txstatus%type,
        msgsts      tllog.msgsts%type,
        ovrsts      tllog.ovrsts%type,
        batchname   tllog.batchname%type,
        msgamt      tllog.msgamt%type,
        msgacct     tllog.msgacct%type,
        chktime     tllog.chktime%type,
        offtime     tllog.offtime%type,
        carebygrp   tllog.carebygrp%type,
        reftxnum    tllog.reftxnum%type,
        namenv      tllog.namenv%type,
        cfcustodycd tllog.cfcustodycd%type,
        createdt    tllog.createdt%TYPE,
        cffullname  tllog.cffullname%TYPE,
        PTXSTATUS   tllog.PTXSTATUS%TYPE
       );

TYPE field_rectype IS RECORD (
    type char(1),
    defname varchar2(30),
    value  varchar2(32700)
);
TYPE printInfo_rectype IS RECORD (
    custname varchar2(1000),
    address varchar2(250),
    license  varchar2(60),
    custody varchar2(60),
    bankac  varchar2(60),
    bankname varchar2(60),
    bankque varchar2(60),
    holdamt varchar2(60),
    value  varchar2(250)
);
TYPE mitran_rectype IS RECORD (
    subtxno varchar2(10),
    dorc varchar2(10),
    acctno  varchar2(100),
    custid varchar2(100),
    custname varchar2(100),
    taskcd  varchar2(10),
    deptcd  varchar2(10),
    micd  varchar2(10),
    description varchar2(300),
    value  varchar2(250)
);

TYPE postmap_rectype IS RECORD (
    subtxno varchar2(10),
    dorc varchar2(10),
    ccycd  varchar2(10),
    acctno varchar2(100),
    glgrp  varchar2(10),
    value  varchar2(250)
);
TYPE exception_rectype IS RECORD (
    type varchar2(60),
    oldval  varchar2(2000),
    value varchar2(2000)
);

TYPE warningexception_rectype IS RECORD (
  errlev varchar2(1),
  value varchar2(2000)
);

TYPE infoField_arrtype IS TABLE OF VARCHAR2(250) INDEX BY varchar2(6);
TYPE info_arrtype IS TABLE OF infoField_arrtype INDEX BY varchar2(6);
TYPE printInfo_arrtype IS TABLE OF printInfo_rectype INDEX BY varchar2(6);
TYPE mitran_arrtype IS TABLE OF mitran_rectype INDEX BY varchar2(6);
TYPE postmap_arrtype IS TABLE OF postmap_rectype INDEX BY varchar2(6);
TYPE msgfields_arrtype IS TABLE OF field_rectype INDEX BY varchar2(6);
TYPE exceptionfields_arrtype IS TABLE OF exception_rectype INDEX BY varchar2(60);
TYPE warningexceptionfields_arrtype IS TABLE OF warningexception_rectype INDEX BY varchar2(60);

TYPE msg_rectype is RECORD (
    autoid    NUMBER,
    txnum     VARCHAR2(10),
    txdate    DATE,
    txtime    VARCHAR2(10),
    brid      VARCHAR2(4),
    tlid      VARCHAR2(4),
    offid     VARCHAR2(4),
    ovrrqd    VARCHAR2(2000),
    chid      VARCHAR2(4),
    chkid     VARCHAR2(4),
    txaction  CHAR(3),
    msgtype   CHAR(1),
    tltxcd    VARCHAR2(4),
    ibt       VARCHAR2(1),
    brid2     VARCHAR2(4),
    tlid2     VARCHAR2(4),
    ccyusage  VARCHAR2(40),
    off_line  CHAR(1),
    deltd     CHAR(1),
    brdate    DATE,
    busdate   DATE,
    txdesc    VARCHAR2(4000),
    ipaddress VARCHAR2(20),
    wsname    VARCHAR2(50),
    txstatus  VARCHAR2(1),
    msgsts    VARCHAR2(1),
    ovrsts    VARCHAR2(1),
    batchname VARCHAR2(15),
    msgamt    NUMBER(30, 4),
    msgacct   VARCHAR2(100),
    feeamt   NUMBER(30,4),
    vatamt   NUMBER(30,4),
    voucher   NUMBER(30,4),
    chktime   VARCHAR2(10),
    offtime   VARCHAR2(10),
    reftxnum  VARCHAR2(10),
    -- tx control
    txtype    CHAR(1),
    nosubmit  CHAR(1),
    pretran   CHAR(1),
    late      CHAR(1),
    local     CHAR(1),
    glgp      CHAR(1),
    warning   VARCHAR2(1),
    careby    VARCHAR2(30000),
    txfields  msgfields_arrtype,
    txPrintInfo printInfo_arrtype,
    txInfo    info_arrtype,
    txException  exceptionfields_arrtype,
    txWarningException  warningexceptionfields_arrtype,
    SESSIONID VARCHAR2(1000)
    );
 TYPE msg_2B is RECORD (
    order_number VARCHAR2(20),
    firm      VARCHAR2(20),
    order_entry_date    VARCHAR2(10)
    );
  TYPE msg_2C is RECORD (
    order_number VARCHAR2(20),
    firm      VARCHAR2(20),
    order_entry_date    VARCHAR2(10),
    cancel_shares    VARCHAR2(20),
    order_cancel_status  VARCHAR2(10)
    );
  TYPE msg_2E is RECORD (
    order_number        VARCHAR2(20),
    confirm_number      VARCHAR2(20),
    price               VARCHAR2(20),
    side                VARCHAR2(20),
    firm                VARCHAR2(10),
    volume              VARCHAR2(20),
    order_entry_date    VARCHAR2(20),
    filler              VARCHAR2(40)
    );
  TYPE msg_2I is RECORD (
    confirm_number                       VARCHAR2(20),
    price                                VARCHAR2(20),
    order_number_sell                    VARCHAR2(20),
    order_entry_date_sell                VARCHAR2(10),
    firm                                 VARCHAR2(20),
    volume                               VARCHAR2(20),
    order_number_buy                     VARCHAR2(20),
    order_entry_date_buy                 VARCHAR2(20)
    );
 TYPE msg_2L is RECORD (
    confirm_number                       VARCHAR2(20),
    price                                VARCHAR2(20),
    side                                 VARCHAR2(20),
    contra_firm                          VARCHAR2(10),
    firm                                 VARCHAR2(20),
    volume                               VARCHAR2(20),
    deal_id                              VARCHAR2(20)
    );
 TYPE msg_2F is RECORD (
    confirm_number                       VARCHAR2(20),
    firm_buy                             VARCHAR2(20),
    price                                VARCHAR2(20),
    side_b                               VARCHAR2(10),
    volume                               VARCHAR2(20),
    security_symbol                      VARCHAR2(20),
    trader_id_buy                        VARCHAR2(20),
    board                                VARCHAR2(20),
    contra_firm_sell                     VARCHAR2(20),
    trader_id_contra_side_sell           VARCHAR2(20)
    );

 TYPE msg_2G is RECORD (
    order_number                       VARCHAR2(20),
    firm                               VARCHAR2(20),
    msg_type                           VARCHAR2(20),
    reject_reason_code                 VARCHAR2(10),
    original_message_text              VARCHAR2(500),
    order_entry_date                   VARCHAR2(20),
    original_firm                      VARCHAR2(20),
    deal_id                            VARCHAR2(20)
    );
 --2012.06.06 ThanhNV them 2D cho MP
 TYPE msg_2D is RECORD (
    ordernumber                       VARCHAR2(20),
    firm                               VARCHAR2(20),
    orderentrydate                   VARCHAR2(20),
    price                                VARCHAR2(20)
    );
 --Ket thuc

 TYPE msg_3B is RECORD (
    firm                               VARCHAR2(20),
    deal_id                            VARCHAR2(20),
    confirm_number                     VARCHAR2(20),
    client_id_buyer                    VARCHAR2(20),
    reply_code                         VARCHAR2(20)
    );

 TYPE msg_3C is RECORD (
    contra_firm                        VARCHAR2(20),
    security_symbol                    VARCHAR2(20),
    confirm_number                     VARCHAR2(20),
    firm                               VARCHAR2(20),
    side                               VARCHAR2(20),
    trader_id                          VARCHAR2(20)
    );

 TYPE msg_3D is RECORD (
    firm                               VARCHAR2(20),
    confirm_number                     VARCHAR2(20),
    reply_code                         VARCHAR2(20)
    );

 /*
 TYPE msg_2D is RECORD (
    clientid                               VARCHAR2(20),
    orderentrydate                         VARCHAR2(20),
     price                         VARCHAR2(20),
      firm                         VARCHAR2(20),
      ordernumber                         VARCHAR2(20),
     port_clientflag                         VARCHAR2(20),
     published_volume                        VARCHAR2(20),
    filler                             VARCHAR2(20)
    );
 */



  --PRS Message.
  TYPE msg_TS is RECORD (
    timestamp                          VARCHAR2(20)
    );

  TYPE msg_SC is RECORD (
    timestamp                               VARCHAR2(20),
    system_control_code                     VARCHAR2(20)
    );
  TYPE msg_TR is RECORD (
    current_room                               VARCHAR2(20),
    security_number                            VARCHAR2(20),
    total_room                                 VARCHAR2(20)
    );

  TYPE msg_BS is RECORD (
    firm                                       VARCHAR2(20),
    automatch_halt_flag                        VARCHAR2(20),
    put_through_halt_flag                      VARCHAR2(20)
    );

  TYPE msg_TC is RECORD (
    firm                                       VARCHAR2(20),
    trader_id                                  VARCHAR2(20),
    trader_status                              VARCHAR2(20)
    );

  TYPE msg_GA is RECORD (
    admin_message_text                         VARCHAR2(500),
    admin_message_length                       VARCHAR2(20)
    );

  TYPE msg_SU is RECORD (
    floor_price              VARCHAR2(100),
    benefit              VARCHAR2(100),
    ceiling_price        VARCHAR2(100),
    open_price           VARCHAR2(100),
    security_name        VARCHAR2(100),
    security_number_new  VARCHAR2(100),
    prior_close_price    VARCHAR2(100),
    halt_resume_flag     VARCHAR2(100),
    notice               VARCHAR2(100),
    delist               VARCHAR2(100),
    par_value            VARCHAR2(100),
    total_shares_traded  VARCHAR2(100),
    security_number_old  VARCHAR2(100),
    board_lot            VARCHAR2(100),
    highest_price        VARCHAR2(100),
    suspension           VARCHAR2(100),
    sector_number        VARCHAR2(100),
    client_id_required   VARCHAR2(100),
    sdc_flag             VARCHAR2(100),
    total_values_traded  VARCHAR2(100),
    prior_close_date     VARCHAR2(100),
    market_id            VARCHAR2(100),
    meeting              VARCHAR2(100),
    filler_5             VARCHAR2(100),
    security_symbol      VARCHAR2(100),
    split                VARCHAR2(100),
    filler_4             VARCHAR2(100),
    security_type        VARCHAR2(100),
    filler_3             VARCHAR2(100),
    lowest_price         VARCHAR2(100),
    filler_2             VARCHAR2(100),
    filler_1             VARCHAR2(100),
    last_sale_price      VARCHAR2(100),
/*--Ngay 07/03/2017 CW NamTV them thong tin chung quyen*/
    underlyingsymbol VARCHAR2(100), /*Ma CK co so*/
    issuername          VARCHAR2(200),   /*Ten TCPH CKSC*/
    coveredwarranttype  VARCHAR2(100),   /*Loai chung quyen*/
    maturitydate        VARCHAR2(100),   /*Ngay het han chung quyen*/
    lasttradingdate     VARCHAR2(100),   /*Ngay giao dich cuoi cung*/
    exerciseprice       VARCHAR2(100),   /*Gia thuc hien*/
    exerciseratio       VARCHAR2(100),    /*Ty le thuc hien*/
    listedshare         VARCHAR2(100),   /*Khoi luong CW niem yet*/
/*--End NamTV*/
    odd_lot_halt_resume_flag     VARCHAR2(100) --LoLeHSX
    );

  TYPE msg_SS is RECORD (
    board_lot        VARCHAR2(100),
    floor_price      VARCHAR2(100),
    benefit          VARCHAR2(100),
    suspension       VARCHAR2(100),
    sector_number    VARCHAR2(100),
    system_control_code      VARCHAR2(100),
    ceiling         VARCHAR2(100),
    meeting         VARCHAR2(100),
    security_number      VARCHAR2(100),
    filler_6        VARCHAR2(100),
    filler_5        VARCHAR2(100),
    prior_close_price     VARCHAR2(100),
    halt_resume_flag      VARCHAR2(100),
    filler_4        VARCHAR2(100),
    split           VARCHAR2(100),
    security_type      VARCHAR2(100),
    filler_3        VARCHAR2(100),
    delist          VARCHAR2(100),
    filler_2        VARCHAR2(100),
    notice          VARCHAR2(100),
    filler_1        VARCHAR2(100),
/*--Ngay 07/03/2017 CW NamTV them thong tin chung quyen*/
    underlyingsymbol VARCHAR2(100), /*Ma CK co so*/
    issuername          VARCHAR2(200),   /*Ten TCPH CKSC*/
    coveredwarranttype  VARCHAR2(100),   /*Loai chung quyen*/
    maturitydate        VARCHAR2(100),   /*Ngay het han chung quyen*/
    lasttradingdate     VARCHAR2(100),   /*Ngay giao dich cuoi cung*/
    exerciseprice       VARCHAR2(100),   /*Gia thuc hien*/
    exerciseratio       VARCHAR2(100),    /*Ty le thuc hien*/
    listedshare         VARCHAR2(100),   /*Khoi luong CW niem yet*/
  /*--End NamTV*/
    odd_lot_halt_resume_flag     VARCHAR2(100) --LoLeHSX
    );
    /* Ducnv sua GW*/
 TYPE msg_AA is RECORD (
    security_number         VARCHAR2(20),
    volume                  VARCHAR2(20),
    price                   VARCHAR2(20),
    firm                    VARCHAR2(20),
    trader                  VARCHAR2(20),
    side                    VARCHAR2(20),
    board                   VARCHAR2(20),
    TIME_od                 VARCHAR2(20),
    add_cancel_flag         VARCHAR2(20),
    contact                 VARCHAR2(20)
    );
    /* End Ducnv sua GW*/
  --HNX Message
  TYPE msg_8 is RECORD (
    ClOrdID            VARCHAR2(100),
    TransactTime       VARCHAR2(100),
    ExecType           VARCHAR2(100),
    OrderQty           VARCHAR2(100),
    OrderID            VARCHAR2(100),
    Side               VARCHAR2(100),
    Symbol             VARCHAR2(100),
    Price              VARCHAR2(100),
    Account            VARCHAR2(100),
    OrdStatus          VARCHAR2(100),
    OrigClOrdID        VARCHAR2(100),
    SecondaryClOrdID   VARCHAR2(100),
    LastQty            VARCHAR2(100),
    LastPx             VARCHAR2(100),
    ExecID             VARCHAR2(100),
    LeavesQty          VARCHAR2(100),
    OrdType            VARCHAR2(100),
    UnderlyingLastQty  VARCHAR2(100),
    OrdRejReason       VARCHAR2(100),
    MsgSeqNum          VARCHAR2(100)
    );

  TYPE msg_s is RECORD (
    CrossID            VARCHAR2(100),
    CrossType          VARCHAR2(100),
    NoSides            VARCHAR2(100),
    SellSide           VARCHAR2(100),
    BuySide            VARCHAR2(100),
    Symbol             VARCHAR2(100),
    BuyPartyID         VARCHAR2(100),
    SellPartyID        VARCHAR2(100),
    Price              VARCHAR2(100),
    SellOrderQty       VARCHAR2(100),
    BuyOrderQty        VARCHAR2(100),
    SellAccount        VARCHAR2(100),
    BuyAccount         VARCHAR2(100),
    SellAccountType    VARCHAR2(100),
    BuyAccountType     VARCHAR2(100),
    SellClOrdID        VARCHAR2(100),
    BuyClOrdID        VARCHAR2(100)
    );

  TYPE msg_u is RECORD (
    CrossID                VARCHAR2(100),
    OrigCrossID            VARCHAR2(100),
    CrossType              VARCHAR2(100),
    SenderCompID           VARCHAR2(100),
    TargetCompID           VARCHAR2(100),
    TargetSubID            VARCHAR2(100)
    );

  TYPE msg_7 is RECORD (
    AdvSide                VARCHAR2(100),
    Text                   VARCHAR2(100),
    Quantity               VARCHAR2(100),
    AdvTransType           VARCHAR2(100),
    Symbol                 VARCHAR2(100),
    DeliverToCompID        VARCHAR2(100),
    Price                  VARCHAR2(100),
    AdvId                  VARCHAR2(100),
    SenderSubID           VARCHAR2(100),
    AdvRefID               VARCHAR2(100)
    );
/* Ducnv sua GW*/
TYPE msg_3 is RECORD (
    SessionRejectReason    VARCHAR2(10),
    RefMsgType             VARCHAR2(100),
    CheckSum               VARCHAR2(100),
    Text                   VARCHAR2(200),
    RefSeqNum              VARCHAR2(200),
    ClOrdID                VARCHAR2(200),
    CrossID                VARCHAR2(200),
    UserRequestID          VARCHAR2(200)--HNX_update
    );
/* End Ducnv sua GW*/
--HNX_update
  TYPE msg_BF is RECORD (
    Username                 VARCHAR2(100),
    UserRequestID            VARCHAR2(100),
    UserStatus               VARCHAR2(100),
    UserStatusText           VARCHAR2(1000)
    );
--End HNX_update
--HNX_update: TruongLD Add
  TYPE msg_A is RECORD (
    Text           VARCHAR2(1000)
    );
--End HNX_update: TruongLD Add
  TYPE msg_f is RECORD (
    Text                      VARCHAR2(100),
    SecurityStatusReqID       VARCHAR2(100),
    Symbol                    VARCHAR2(100),
    SecurityType              VARCHAR2(100),
    IssueDate                 VARCHAR2(100),
    Issuer                    VARCHAR2(100),
    SecurityDesc              VARCHAR2(100),
    HighPx                    VARCHAR2(100),
    LowPx                     VARCHAR2(100),
    LastPx                    VARCHAR2(100),
    SecurityTradingStatus     VARCHAR2(100),
    BuyVolume                 VARCHAR2(100),
    TradingSessionSubID       VARCHAR2(100),
    TotalListingQtty          VARCHAR2(100)     --thangpv ROC_TPDN_HNX 11/07/2022 lay tu FNSHOSTWEB qua
    );

  TYPE msg_h is RECORD (
    TradingSessionID         VARCHAR2(100),
    TradSesStartTime         VARCHAR2(100),
    TradSesStatus            VARCHAR2(100),
    TradSesReqID            VARCHAR2(100)
    );

    TYPE msg_T is RECORD(
    CrossID         VARCHAR2(100),
    OrigCrossID         VARCHAR2(100),
    CrossType         VARCHAR2(100),
    NoSides         VARCHAR2(100),
    SellSide         VARCHAR2(100),
    BuySide         VARCHAR2(100),
    Symbol         VARCHAR2(100),
    BuyPartyID         VARCHAR2(100),
    SellPartyID         VARCHAR2(100),
    Price         VARCHAR2(100),
    SellOrderQty         VARCHAR2(100),
    BuyOrderQty         VARCHAR2(100),
    SellAccount         VARCHAR2(100),
    BuyAccount         VARCHAR2(100),
    SellAccountType         VARCHAR2(100),
    BuyAccountType         VARCHAR2(100) );

--BEGIN SONLT 20150930 Them kieu du lieu msg B cho HNX
TYPE msg_B is RECORD (
SendingTime          VARCHAR2(100),
Urgency          VARCHAR2(100),
HeadLine             VARCHAR2(100),
LinesOfText             VARCHAR2(100), --Edit 20151007
Text              VARCHAR2(4000)
);
--END SONLT 20150930

END;
/
