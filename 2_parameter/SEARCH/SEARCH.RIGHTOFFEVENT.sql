SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RIGHTOFFEVENT','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RIGHTOFFEVENT', 'Điều chỉnh giá thực hiện quyền', 'Price management', 'SELECT A.AUTOID, A.SYMBOL, A.BEGINDATE, A.ENDDATE, A.I1, A.I2, A.I3,
       A.TTHCP, A.DIVCP, A.TTHT, A.DIVT, A.PR1, A.PR2, A.PR3,
       A.AUTOCALC, A.BASICPRICE, (CASE WHEN A.STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW, al.cdcontent status, NVL(SEC.MARGINPRICE,0) MARGINPRICE, NVL(SEC.MARGINCALLPRICE,0) MARGINCALLPRICE
       FROM RIGHTOFFEVENT A , allcode al, securities_info SEC  WHERE A.status = al.cdval AND al.cdname = ''STATUS'' AND al.cdtype = ''SA'' AND A.symbol = SEC.symbol(+)  ', 'RIGHTOFFEVENT', 'frmRIGHTOFFEVENT', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;