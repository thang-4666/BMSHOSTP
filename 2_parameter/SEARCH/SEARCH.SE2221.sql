SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2221','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2221', 'Tra cứu chứng khoán HCCN', 'View securities transfer limited', '
SELECT  FN_GET_LOCATION(AF.BRID) LOCATION, cf.custodycd,af.acctno afacctno, se.acctno,DT.CODEID,
 dt.symbol, se.blocked, dt.parvalue,dt.tradeplace,0 blockwithdraw,
se.blocked REALBLOCKED,
dt.price,cf.address,cf.fullname
FROM semast  se,
     cfmast cf,afmast af,
          (SELECT   sb.symbol,
               sb.codeid,
               sb.parvalue,
               sein.prevcloseprice price,
               a4.cdcontent tradeplace
            FROM   securities_info sein,
               sbsecurities sb,
               allcode a4
           WHERE     sb.codeid = sein.codeid
               AND a4.cdtype = ''SE''
               AND a4.cdname = ''TRADEPLACE''
               AND a4.cdval = sb.tradeplace) dt

WHERE af.custid = cf.custid
AND se.afacctno = af.acctno
AND se.codeid = dt.codeid

AND se.blocked >0

 ', 'SEMAST', '', '', '2221', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;