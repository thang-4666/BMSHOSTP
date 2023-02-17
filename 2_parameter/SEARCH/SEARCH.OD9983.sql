SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD9983','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD9983', 'Danh sách lệnh mua bán cùng tài khoản', 'Trade buy sell in an account', 'SELECT a.orderid, a.txdate, a.ordernumber, a.refordernumber, a.custodycd,
       a.symbol, a.bsca bors, a.norp, a.ordertype, a.volume QTTY, a.price, a.traderid,
       a.memberid, a.board,issend
  FROM (SELECT a.orderid, a.txdate, a.ordernumber, a.refordernumber,
               a.custodycd, a.symbol, a.bsca, a.norp, a.ordertype, a.volume,
               a.price, a.traderid, a.memberid, a.board, ''N'' issend
          FROM stcorderbook a
        UNION ALL
        SELECT '''' orderid, a.txdate, a.ordernumber, a.refordernumber,
               a.custodycd, a.symbol, a.bsca, a.norp, a.ordertype, a.volume,
               a.price, a.traderid, a.memberid, a.board, ''N'' issend
          FROM stcorderbookexp a
        UNION ALL
        SELECT a.orgorderid orderid, a.txdate, '''' ordernumber,
               '''' refordernumber, a.custodycd, TO_CHAR (a.symbol),
               a.bors bsca, a.norp, '''' ordertype, a.qtty volume, a.price,
               '''' traderid, '''' memberid, '''' board , ''N'' issend
          FROM ood a
         WHERE a.oodstatus = ''N'') a
 WHERE (a.custodycd, a.symbol) IN (
          SELECT   a.custodycd, a.symbol
              FROM (SELECT a.custodycd, a.symbol, a.bsca
                      FROM stcorderbook a
                    UNION ALL
                    SELECT a.custodycd, a.symbol, a.bsca
                      FROM stcorderbookexp a
                    UNION ALL
                    SELECT a.custodycd, TO_CHAR (a.symbol), a.bors bsca
                      FROM ood a
                     WHERE a.oodstatus = ''N'') a
          GROUP BY a.custodycd, a.symbol
            HAVING COUNT (DISTINCT a.bsca) > 1)
', 'ODMAST', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;