SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_SE9985
(CUSTODYCD, AFACCTNO, SYMBOL, MNEMONIC, TOTALQTTY, 
 TRADE, DFTRADING, ABSTANDING, RESTRICTQTTY, BLOCKED, 
 CARECEIVING, SECURITIES_RECEIVING_T0, SECURITIES_RECEIVING_T1, SECURITIES_RECEIVING_T2, MATCHINGAMT, 
 FIFOCOSTPRICE, FIFOAMT, BASICPRICE, MKTAMT, PNLAMT, 
 PNLRATE, ISSELL, SECURERATIO, SESECURED, SEMARGIN)
BEQUEATH DEFINER
AS 
select custodycd, afacctno ,symbol, mnemonic,
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT - buyingqtty) totalqtty,
                   TRADE,DFTRADING,ABSTANDING,RESTRICTQTTY,BLOCKED,CARECEIVING,
                   SECURITIES_RECEIVING_T0, SECURITIES_RECEIVING_T1, SECURITIES_RECEIVING_T2,
                   MATCHINGAMT,FIFOCOSTPRICE,
                   --11. Gia tri
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT- buyingqtty) * FIFOCOSTPRICE FIFOAMT,
                   --13. Gia tri thi truong
                   BASICPRICE, (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT- buyingqtty) * BASICPRICE MKTAMT,
                   --14. Lai lo du tinh
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT - BUYINGQTTY) * (BASICPRICE-FIFOCOSTPRICE) PNLAMT,
                    --15. % Lai lo du tinh
                   case when FIFOCOSTPRICE = 0 then '----' else  to_char(round((BASICPRICE-FIFOCOSTPRICE)/FIFOCOSTPRICE,4) * 100)||'%' end PNLRATE,
                   (case when TRADE > 0 then 'Y' else 'N' end) ISSELL,
                   SECURERATIO,SESECURED,SEMARGIN
            from
            (  select aft.mnemonic, custodycd, afacctno,
                    --1. Ma chung khoan
                    SE.symbol,
                    --3.Kha dung
                    nvl(trade,0) TRADE,
                    --4.1 Cam co
                    nvl(dftrading,0) DFTRADING,
                    --4.2.Chung khoan CC VSD
                    nvl(abstanding,0) ABSTANDING,
                    --5.Chung khoan HCCN
                    nvl(restrictqtty,0) RESTRICTQTTY,
                    --6.Khoi luong phong toa
                    nvl(blocked,0) BLOCKED,
                    --7. Chung khoan quyen cho ve
                    se.receiving -( nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)+nvl(securities_receiving_t3,0)
                        --PhuNh Comment T0 chua vao receiving trong semast
                        --+nvl(securities_receiving_t0,0)
                        ) CARECEIVING,
                    --8. Chung khoan cho ve
                    nvl(securities_receiving_t0,0) + nvl(securities_receiving_t1,0) +
                    nvl(securities_receiving_t2,0) odreceiving,
                        --8.1 Cho ve T0
                        nvl(securities_receiving_t0,0) SECURITIES_RECEIVING_T0,
                        --8.1 Cho ve T1
                        nvl(securities_receiving_t1,0) SECURITIES_RECEIVING_T1,
                        --8.1 Cho ve T2
                        nvl(securities_receiving_t2,0)SECURITIES_RECEIVING_T2,
                    nvl(securities_receiving_t3,0) securities_receiving_t3,
                    --9. Chung khoan cho khop
                    --PhuNh securities_sending_t0 -> securities_sending_t3
                    se.buyingqtty + se.secured - securities_sending_t3 MATCHINGAMT,
                    --10. Gia von trung binh
                    se.fifocostprice,
                    --12. Gia thi truong
                    se.basicprice,
                    se.deposit + se.senddeposit DEPOSIT,
                    se.MRRATIOLOAN,
                    --12. BUYINGQTTY
                    se.buyingqtty,
                    (100-MRRATIOLOAN) SECURERATIO,
                   (trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                     securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn +
                     buyingqtty - securities_sending_t3) * (1-mrratioloan/100) * BASICPRICE  SESECURED,
                   (trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                     securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn +
                     buyingqtty - securities_sending_t3) * (mrratioloan/100) * BASICPRICE  SEMARGIN
                from buf_se_account se,afmast af ,aftype aft
                where se.afacctno= af.acctno
                and af.actype = aft.actype
                )
            where (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT - buyingqtty) > 0
            order by afacctno,symbol
/
