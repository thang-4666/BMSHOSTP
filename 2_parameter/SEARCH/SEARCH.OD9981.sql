SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD9981','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD9981', 'Sổ lệnh/kết quả khớp không hợp lệ', 'Exchange order/trade book exception', 'SELECT *
  FROM (SELECT   mst.txdate, mst.refordernumber, mst.ordernumber,
                 mst.custodycd, mst.symbol, mst.bsca bors, mst.norp,
                 mst.ordertype, mst.volume, mst.price,
                 NVL (dtl.volume, 0) tradevol,
                 NVL (dtl.price,0) tradeprice
            FROM stcorderbookexp mst ,stctradebookexp dtl
            WHERE SUBSTR(mst.refordernumber,1,2)=SUBSTR(dtl.refconfirmnumber(+),1,2)
            AND  mst.ordernumber = dtl.ordernumber(+)
            ORDER BY mst.CUSTODYCD,mst.ORDERNUMBER
        )
 WHERE 0 = 0
', 'ODMAST', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;