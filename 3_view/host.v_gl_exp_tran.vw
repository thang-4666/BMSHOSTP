SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GL_EXP_TRAN
(REF, TXDATE, TXNUM, BUSDATE, CUSTID, 
 CUSTODYCD, CUSTODYCD_DEBIT, CUSTODYCD_CREDIT, BANKID, TRANS_TYPE, 
 AMOUNT, SYMBOL, SYMBOL_QTTY, SYMBOL_PRICE, COSTPRICE, 
 TXBRID, BRID, TRADEPLACE, ISCOREBANK, STATUS, 
 CUSTATCOM, CUSTTYPE, COUNTRY, SECTYPE, NOTE, 
 BANKNAME, FULLNAME, REFTRAN)
BEQUEATH DEFINER
AS 
SELECT a.ref, to_char(a.txdate,'YYYY-MM-DD' ) TXDATE , a.txnum,to_char(a.busdate,'YYYY-MM-DD' ) busdate, a.custid, a.custodycd,
       a.custodycd_debit, a.custodycd_credit, a.bankid, a.trans_type,
       a.amount, a.symbol, a.symbol_qtty, a.symbol_price, a.costprice,
       a.txbrid, a.brid, a.tradeplace, a.iscorebank, a.status,
       a.custatcom, a.custtype, a.country, a.sectype, a.note,a.bankname,a.fullname,a.reftran
  FROM gl_exp_tran a
/
