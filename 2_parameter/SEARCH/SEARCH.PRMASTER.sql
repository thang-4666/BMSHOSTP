SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('PRMASTER','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('PRMASTER', 'Kiểm soát Pool', 'Pool Master', '
SELECT MST.*,A2.CDCONTENT APPRV_STSD FROM
    (select ''0000'' PRCODE, ''Toàn bộ hệ thống BMSC'' PRNAME,
    ''Pool'' PRTYPE, ''VND'' SYMBOL, ''Có hiệu lực'' PRSTATUS, sum(PRLIMIT) PRLIMIT, sum(prinused) prinused,
    sum (prinusedbod) prinusedbod, sum(prsecured) prsecured, sum(pravllimit) pravllimit,max(expireddt),''0000000000'' afacctno,
    ''Toàn bộ BMSC'' Pooltype, sum(prsecuredcr) prsecuredcr , sum(prsecureddr) prsecureddr,''SY'' POOLTYPEVAL,''A'' APPRV_STS,''A'' STATUS,
    ''N'' EDITALLOW,  ''N'' APRALLOW, ''N'' DELALLOW , MAX(MRPAY.AMT) MRPAY  from vw_prmaster,
    (SELECT SUM (AMT) AMT FROM VW_MRPAYLN WHERE AMT>0)MRPAY
    where POOLTYPEVAL in (''SY'',''AF'',''GR'')
    union all select vw.*,
    (CASE WHEN STATUS IN (''D'') THEN ''N'' ELSE ''Y'' END) EDITALLOW,
    (CASE WHEN STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW,
    (CASE WHEN STATUS IN (''D'') THEN ''N'' ELSE ''Y'' END) DELALLOW ,DECODE ( PRCODE,''0001'', MRPAY.AMT,0) MRPAY from VW_PRMASTER vw,
    (SELECT SUM (AMT) AMT FROM VW_MRPAYLN WHERE AMT>0)MRPAY  ) MST,
    ALLCODE a2
    WHERE A2.CDNAME=''APPRV_STS'' AND A2.CDTYPE=''SY'' AND A2.CDVAL=NVL(MST.STATUS,''A'') ', 'PRMASTER', 'PRCODE', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;