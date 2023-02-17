SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('V_SE2203','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('V_SE2203', 'Danh sách import giao dịch giải tỏa phong tỏa chứng khoán (2203)', 'View pending unblock securities (wait for 2203)', '
select * from ( SELECT  FN_GET_LOCATION(AF.BRID) LOCATION, cf.custodycd,af.acctno afacctno, se.acctno,DT.CODEID, dt.symbol,
    CASE WHEN TB.qttytype = ''002'' then least(TB.tradeamt,se.blocked)
        else 0 end   blocked,
    CASE WHEN TB.qttytype <> ''002'' then least(TB.tradeamt,se.emkqtty- nvl(sem.qtty,0))
        else 0 end   emkqtty,
    CASE WHEN TB.qttytype = ''002'' then se.blocked
        else 0 end   realblocked,
    CASE WHEN TB.qttytype <> ''002'' then se.emkqtty- nvl(sem.qtty,0)
        else 0 end   realemkqtty,
    dt.parvalue,dt.tradeplace,se.blockwithdraw blockwithdraw,
    dt.price,cf.address,cf.fullname, TB.tradeamt, TB.qttytype
FROM semast se, tblse2203 TB, cfmast cf,afmast af,   (SELECT   sb.symbol,
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
               AND a4.cdval = sb.tradeplace) dt,(SELECT SUM ( QTTY) QTTY ,ACCTNO FROM SEMORTAGE WHERE STATUS =''N'' AND DELTD <>''Y''GROUP BY ACCTNO ) SEM
WHERE af.custid = cf.custid
AND se.afacctno = af.acctno
AND se.codeid = dt.codeid
AND se.acctno = TB.ACCTNO (+)
AND se.acctno = sem.acctno (+)
) where blocked >0 or emkqtty >0
 ', 'SEMAST', '', '', '2203', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;