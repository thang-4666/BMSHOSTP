SET DEFINE OFF;
CREATE OR REPLACE PACKAGE PCK_ONLINETRADING AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure UpdateCustomerInfo(custid VARCHAR2);
  procedure PlaceCondOrder(sidecodeCond VARCHAR2, symbolCond VARCHAR2, qtyCond FLOAT, priceCond FLOAT, priceTypeCond VARCHAR2,
  termTypeCond VARCHAR2, updownLimit VARCHAR2, condTimeType VARCHAR2, fixedTimeCond VARCHAR2, condFromTime VARCHAR2,
  condToTime VARCHAR2, acctno VARCHAR2);
END PCK_ONLINETRADING;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
