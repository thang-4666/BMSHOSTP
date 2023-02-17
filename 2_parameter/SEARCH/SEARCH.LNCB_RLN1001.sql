SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LNCB_RLN1001','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LNCB_RLN1001', 'Nguồn giải ngân', 'Released resource', '
        SELECT CDVAL CUSTID, CDCONTENT BANKNAME, CDCONTENT DESCRIPTION, LSTODR FROM
        (SELECT ''ALL'' CDVAL, ''Tất cả'' CDCONTENT, -2 LSTODR FROM DUAL
        UNION SELECT ''BSC'' CDVAL, ''Nguồn công ty'' CDCONTENT, -1 LSTODR FROM DUAL
        UNION SELECT ''OVDB'' CDVAL, ''Nguồn ngân hàng quá hạn'' CDCONTENT, 0 LSTODR FROM DUAL
        UNION SELECT a.custid CDVAL, a.fullname CDCONTENT, ROWNUM LSTODR
            FROM (SELECT cf.custid, cf.fullname FROM CFMAST CF WHERE CF.isbanking = ''Y'' ORDER BY custid) a
        ) where 0=0
', 'DFMAST', '', 'LSTODR', '', NULL, 50, 'N', 0, '', 'Y', 'T', '', 'N', '', '');COMMIT;