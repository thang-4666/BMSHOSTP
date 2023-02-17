SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETORDERSBYUSER" (p_refcursor  in out PKG_REPORT.REF_CURSOR,
                                            p_tlname     in varchar2,
                                            p_rowPerPage in number,
                                            p_page       in number) is
l_page number;

begin

l_page := p_page + 1;

  open p_refcursor for
  select * from (
    select a.*, rownum r
      from (select EXECTYPE, PRICETYPE, CUSTODYCD, AFACCTNO, SYMBOL,
                    ORDERQTTY, QUOTEPRICE * 1000 QUOTEPRICE, EXECQTTY,
                    case
                      when EXECQTTY > 0 and CANCELQTTY = 0 and ADJUSTQTTY = 0 then
                       ORSTATUS || ' ' || EXECQTTY || '/' || ORDERQTTY
                      when CANCELQTTY > 0 and ADJUSTQTTY = 0 then
                       ORSTATUS || ' ' || CANCELQTTY || '/' || ORDERQTTY
                      when ADJUSTQTTY > 0 then
                       ORSTATUS || ' ' || ADJUSTQTTY || '/' || ORDERQTTY
                      else
                       ORSTATUS
                    end STATUS, ORDERID, DECODE(HOSESESSION, 'O', 'Liên tục', 'A', 'Định kỳ', 'P', 'Định kỳ') HOSESESSION, SDTIME LASTCHANGE,
                    REMAINQTTY, DESC_EXECTYPE, CANCELQTTY, ADJUSTQTTY,
                    TRADEPLACE, ISCANCEL, ISADMEND, ISDISPOSAL, FOACCTNO,
                    NVL(LIMITPRICE * 1000,0) LIMITPRICE,
                    NVL(QUOTEQTTY,0) QUOTEQTTY,TO_CHAR(ODTIMESTAMP,'RRRR/MM/DD hh24:mi:ss.ff9') ODTIMESTAMP, ORSTATUSVALUE , CONFIRMED,
                    execamt
               from BUF_OD_ACCOUNT
              where TLNAME = p_tlname
                and TXDATE = GETCURRDATE
              order by ORDERID desc) a
     where rownum <= p_rowPerPage * l_page )
     where r > p_rowPerPage * (l_page - 1);

end GetOrdersByUser;

 
 
 
 
/
