SET DEFINE OFF;
CREATE OR REPLACE PACKAGE ho_tx IS

TYPE msg_8 is RECORD (
    OnBehalfOfCompID   VARCHAR2(10),
    OnBehalfOfSubID    VARCHAR2(10),
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
    LastQty            VARCHAR2(100),
    LastPx             VARCHAR2(100),
    ExecID             VARCHAR2(100),
    LeavesQty          VARCHAR2(100),
    OrdType            VARCHAR2(100),
    OrdRejReason       VARCHAR2(100),
    MsgSeqNum          VARCHAR2(100),
    QuoteID            VARCHAR2(100),
    CumQty             VARCHAR2(100)
    );
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
    TradingSessionSubID       VARCHAR2(100)
    );

TYPE msg_K08 IS RECORD (
   Symbol             VARCHAR2(100),
   SymbolCloseInfoPx           VARCHAR2(100),
   SymbolCloseInfoPxType  VARCHAR2(100),
   OnBehalfOfSubID        VARCHAR2(2)
);

TYPE msg_K09 is RECORD (
    Symbol                   VARCHAR2(100),
    VITypeCode               VARCHAR2(100),
    VIKindCode               VARCHAR2(100),
    StaticVIBasePrice        VARCHAR2(100),
    DynamicVIBasePrice       VARCHAR2(100),
    VIPrice                  VARCHAR2(100),
    StaticVIDispartiyRatio   VARCHAR2(100),
    DynamicVIDispartiyRatio  VARCHAR2(100),
    VIActivatedTime          VARCHAR2(100),
    VIReleaseTime            VARCHAR2(100)
    );

TYPE msg_K07 IS RECORD (
   BroadID            VARCHAR2(100),
   Symbol             VARCHAR2(100),
   ReferencePrice     VARCHAR2(100),
   HighLimitPrice      VARCHAR2(100),
   LowLimitPrice      VARCHAR2(100)
);
TYPE msg_17 IS RECORD (

   ProductGrpID       VARCHAR2(100),
   BroadID            VARCHAR2(100),
   Symbol             VARCHAR2(100),
   OpenTime           VARCHAR2(100),
   FornLimitIncDecQty VARCHAR2(100)
);

TYPE msg_K11 is RECORD (
    ClOrdID            VARCHAR2(100),
    TransactTime       VARCHAR2(100),
    Side               VARCHAR2(100),
    Symbol             VARCHAR2(100),
    Account            VARCHAR2(100),
    AcceptConfirmYN        VARCHAR2(100)
    );

TYPE msg_K17 IS RECORD (
   Symbol             VARCHAR2(100),
   OpenTime           VARCHAR2(100),
   FornLimitIncDecQty VARCHAR2(100)
);

TYPE msg_3 is RECORD (
    SessionRejectReason    VARCHAR2(10),
    RefMsgType             VARCHAR2(100),
    CheckSum               VARCHAR2(100),
    Text                   VARCHAR2(200),
    RefSeqNum              VARCHAR2(200),
    ClOrdID                VARCHAR2(200),
    QuoteMsgID             VARCHAR2(200),
    IOIID                  VARCHAR2(200)
);

TYPE msg_9 is RECORD (
    OrderID              VARCHAR2(100),
    ClOrdID              VARCHAR2(100),
    OrigClOrdID          VARCHAR2(100),
    CxlRejResponseTo     VARCHAR2(100),
    CxlRejReason         VARCHAR2(4000)
);

TYPE msg_AI is RECORD (
    QuoteID              VARCHAR2(100),
    QuoteMsgID           VARCHAR2(100),
    QuoteRespID          VARCHAR2(100),
    QuoteRespType        VARCHAR2(100),
    Symbol               VARCHAR2(100),
    Side                 VARCHAR2(100),
    OrderQty             VARCHAR2(100),
    Account              VARCHAR2(100),
    BidPx                VARCHAR2(100),
    OfferPx              VARCHAR2(100),
    BidSize              VARCHAR2(100),
    OfferSize            VARCHAR2(100),
    QuoteStatus          VARCHAR2(100),
    QuoteRejectReason    VARCHAR2(100)
);

TYPE msg_AJ IS RECORD (
    QuoteRespID        VARCHAR2(100),
    QuoteID            VARCHAR2(100),
    QuoteMsgID         VARCHAR2(100)
);

TYPE msg_j IS RECORD (
    SessionRejectReason    VARCHAR2(10),
    RefMsgType             VARCHAR2(100),
    Text                   VARCHAR2(200),
    RefSeqNum              VARCHAR2(200),
    ClOrdID                VARCHAR2(200),
    QuoteMsgID             VARCHAR2(200),
    IOIID                  VARCHAR2(200)
);

TYPE msg_S is RECORD (
    QuoteID            VARCHAR2(100),
    QuoteMsgID         VARCHAR2(100),
    s1PartyID          VARCHAR2(100),
    s1PartyRole        VARCHAR2(100),
    s2PartyID          VARCHAR2(100),
    s2PartyRole        VARCHAR2(100),
    Symbol             VARCHAR2(100),
    Side               VARCHAR2(100),
    Account            VARCHAR2(100),
    CashMargin         VARCHAR2(100),
    BidPx                VARCHAR2(100),
    OfferPx            VARCHAR2(100),
    BidSize            VARCHAR2(100),
    OfferSize          VARCHAR2(100),
    TradeDate          VARCHAR2(100),
    IOIID              VARCHAR2(100),
    OnBehalfOfSubID    VARCHAR2(10)
);

TYPE msg_K03 is RECORD (
    QuoteMsgID                VARCHAR2(100),
    OrigQuoteMsgID            VARCHAR2(100),
    QuoteCancelType           VARCHAR2(100),
    Account                   VARCHAR2(100),
    symbol                    VARCHAR2(100),
    side                      VARCHAR2(100),
    CashMargin                VARCHAR2(100),
    TransactTime              DATE,
    BidPx                     NUMBER,
    OfferPx                   NUMBER,
    BidSize                   NUMBER,
    OfferSize                 NUMBER,
    BidLeavesSize             NUMBER,
    OfferLeavesSize           NUMBER,
    BidCumSize                NUMBER,
    OfferCumSize              NUMBER,
    AskTypeCode               VARCHAR2(100),
    FornInvestTypeCode        VARCHAR2(100),
    CustodianID               VARCHAR2(100),
    QuoteStatus               VARCHAR2(1),
    QuoteRejectReason         VARCHAR2(1000)
);

TYPE msg_K04 IS RECORD (
  ProductGrpID       VARCHAR2(100),
  BoardEvtID         VARCHAR2(100),
  BoardEvtStartTime  VARCHAR2(100),
  BoardEvtAppGrpCode VARCHAR2(100),
  SessOpenCloseCode  VARCHAR2(100),
  TradingSessionID   VARCHAR2(100),
  Symbol             VARCHAR2(100),
  ProductID          VARCHAR2(100),
  TradingHaltReason  VARCHAR2(100),
  TradingHaltOccType VARCHAR2(100),
  OnBehalfOfSubID    VARCHAR2(100)
);
TYPE msg_K05 IS RECORD (
  OnBehalfOfCompID        VARCHAR2(100),
  PreHourSymChxType       VARCHAR2(100),
  Symbol                  VARCHAR2(100),
  OpenTime                VARCHAR2(100),
  ReferencePrice          NUMBER,
  HighLimitPrice           NUMBER,
  LowLimitPrice           NUMBER,
  EvaluationPrice         NUMBER,
  HgstOrderPrice          NUMBER,
  LwstOrderPrice          NUMBER,
  OpnprcBasPrcYn          VARCHAR2(100),
  ExClassType             VARCHAR2(100),
  UnitOfMeasureQty        NUMBER,
  ListedShares            NUMBER
);

TYPE msg_K06 IS RECORD (
   PreHourChxActionType VARCHAR2(100),
   Symbol               VARCHAR2(100),
   OpenTime             VARCHAR2(100),
   MemberNo             VARCHAR2(100),
   TrdrNo               VARCHAR2(100),
   MemberTRScope        VARCHAR2(100)
);

TYPE msg_K15 IS RECORD (
  IOIID              VARCHAR2(100),
  IOIRefID           VARCHAR2(100),
  IOITransType       VARCHAR2(10),
  Symbol             VARCHAR2(30),
  Side               VARCHAR2(10),
  OrdRejReason       VARCHAR2(100),
  IOIQty             VARCHAR2(100),
  Price              VARCHAR2(100),
  ContactNo          VARCHAR2(100),
  TransactTime       VARCHAR2(100),
  OnBehalfOfSubID    VARCHAR2(10)
);

TYPE msg_K16 IS RECORD (
  IOIID              VARCHAR2(100),
  IOIStatusCode      VARCHAR2(10)
);

C_SYMBOL_STATUS_CONTROL CONSTANT VARCHAR2(3) := 'CTR';

END;
/
