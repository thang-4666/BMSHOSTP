SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2203','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2203', 'Tra cứu chứng khoán bị tạm giữ', 'View securities blocked', '
SELECT  FN_GET_LOCATION(AF.BRID) LOCATION, cf.custodycd,af.acctno afacctno, se.AFACCTNO||se.CODEID acctno,DT.CODEID,
 dt.symbol, se.blocked - se.rlsblocked blocked,se.emkqtty - se.rlsemkqtty emkqtty, se.blocked - se.rlsblocked avlblocked,se.emkqtty - se.rlsemkqtty avlemkqtty,
 se.rlsblocked,se.rlsemkqtty, dt.parvalue,dt.tradeplace,0 blockwithdraw,
se.blocked REALBLOCKED,se.emkqtty REALEMKQTTY,
dt.price,cf.address,cf.fullname,SE.BLOCKTYPE,a1.cdcontenT blocktypedis, se.txnum, to_char(se.txdate,''dd/mm/rrrr'') txdate, se.txdesc
FROM SEBLOCKED se,
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
               AND a4.cdval = sb.tradeplace) dt,
               ALLCODE A1
WHERE af.custid = cf.custid
AND se.afacctno = af.acctno
AND se.codeid = dt.codeid and se.deltd <> ''Y''
AND se.blocked - se.rlsblocked + se.emkqtty - se.rlsemkqtty >0
AND A1.CDTYPE=''SE'' AND A1.CDNAME=''BLOCKTYPE'' AND A1.CDVAL=SE.BLOCKTYPE
 ', 'SEMAST', '', '', '2203', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;