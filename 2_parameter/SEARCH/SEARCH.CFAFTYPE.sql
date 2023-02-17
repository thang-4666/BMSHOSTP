SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFAFTYPE','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFAFTYPE', 'Loai hinh khach hang su dung tieu khoan', 'Aftype list', 'Select c.autoid, c.cftype, c.aftype ,
       af.typename aftypename, a.cdcontent PRODUCTTYPE
From cfaftype c, allcode A, aftype af
where AF.producttype=a.cdval and cdTYPE = ''CF'' AND
CDNAME=''PRODUCTTYPE'' and af.actype=c.aftype
AND C.CFTYPE=''<$KEYVAL>''', 'CF.CFAFTYPE', 'frmTDTYPE', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;