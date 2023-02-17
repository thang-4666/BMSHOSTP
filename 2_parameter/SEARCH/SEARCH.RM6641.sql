SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM6641','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM6641', 'Transfer balance (View pending for 6641)', 'Transfer balance (Pending for 6641)', 'SELECT TL.TXNUM , TL.TXDATE ,''Chuy¿n ti¿n ra ngân hàng '' || TL.TXDESC description , CA.CAMASTID ,
caschd.amt AMOUNT , ci.acctno  , ai.bankcode,ai.ACCTNO DESACCTNO , ''OT'' TRFTYPE
FROM TLLOG  TL, CITRAN CI , APPTX  APP, CAMAST CA , afmast af, aisysvar ai , caschd
WHERE TL.TXNUM = CI.TXNUM AND TL.TXDATE = CI.TXDATE  AND CI.REF  = CA.CAMASTID
AND APP.APPTYPE =''CI'' AND APP.TXCD = CI.TXCD AND APP.FIELD =''RECEIVING'' AND CI.deltd <>''Y''
and ci.acctno = af.acctno and af.bankname =ai.bankcode  and ca.camastid = caschd.camastid and af.acctno = caschd.afacctno  and caschd.deltd <>''Y''
AND TL.TLTXCD =''3379'' and af.corebank =''Y'' and caschd.corebank <>''C'' ', 'GENERAL', '', '', '6641', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;