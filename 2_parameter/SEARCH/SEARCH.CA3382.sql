SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3382','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3382', 'Chuyển nhượng quyền mua trong nội bộ công ty', 'Transfer', 'SELECT MST.*, (CASE WHEN VW.ISSUERMEMBER=''Y''THEN ''Thành viên qu?n tr? c?a TCPH'' ELSE ''Không'' END ) ISSUERMEMBER, M.VARVALUE FROMCUSADD, M.VARVALUE TOCUSADD,
(CASE WHEN VW.ISSUERMEMBER=''Y''THEN ''Y'' ELSE ''N'' END ) ISSUERMEMBERCD   FROM
(
      SELECT (CA.Pbalance) QTTY, (CA.Pbalance) PQTTY ,(CA.PBALANCE-CA.INBALANCE) RETAILBAL,CA.INBALANCE,
      SUBSTR(CAMAST.CAMASTID,1,4) ||''.''||
      SUBSTR(CAMAST.CAMASTID,5,6) ||''.''||
      SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
      CA.AFACCTNO, CAMAST.optcodeid  CODEID,
      SYM.SYMBOL , A1.CDCONTENT STATUS,CA.AFACCTNO ||
      CAMAST.CODEID  SEACCTNO, CAMAST.CODEID SBCODEID,SYM.PARVALUE PARVALUE,
      CAMAST.REPORTDATE REPORTDATE,
      CAMAST.ACTIONDATE,CAMAST.EXPRICE, AFM.*, A2.CDCONTENT
      CATYPE, CAMAST.TRFLIMIT,iss.fullname ISSNAME,
      CA.autoid, SB2.SYMBOL TOSYMBOL, ISS2.FULLNAME TOISSNAME,
      sb2.codeid tocodeid, camast.isincode
      FROM  SBSECURITIES SYM, ALLCODE A1, CAMAST, CASCHD
      CA,issuers iss ,
            (    Select   AF.ACCTNO, CF.CUSTODYCD, CF.FULLNAME  CUSTNAME,
                               A1.CDCONTENT COUNTRY, cf.address,
                               --cf.idcode LICENSE,
                               (case when cf.country = ''234'' then cf.idcode else cf.tradingcode end) LICENSE,
                               (case when cf.country = ''234'' then cf.iddate else cf.tradingcodedt end) iddate,
                               cf.idplace
                 From afmast af, ALLCODE A1, cfmast cf
                 Where af.custid = cf.custid
                              and af.status  IN (''A'',''N'',''C'')
                              AND CF.COUNTRY = A1.CDVAL
                              AND A1.CDTYPE =''CF''
                              AND A1.CDNAME = ''COUNTRY''
             ) AFM, ALLCODE A2, SBSECURITIES SB2, issuers ISS2
      WHERE CA.AFACCTNO=AFM.ACCTNO AND A1.CDTYPE = ''CA''
       AND A1.CDNAME = ''CASTATUS'' AND A1.CDVAL = CA.STATUS AND
      CAMAST.CODEID = SYM.CODEID  AND CAMAST.status in
      (''V'',''S'',''M'')
      AND  CAMAST.catype=''014'' AND CA.camastid =
      CAMAST.camastid AND CA.status in(''V'',''S'',''M'') AND
      CA.DELTD <>''Y'' AND (CA.PBALANCE )  > 0
      AND CAMAST.CATYPE = A2.CDVAL AND A2.CDTYPE = ''CA''
      AND A2.CDNAME = ''CATYPE''
      AND iss.issuerid = sym.issuerid
      AND NVL(CAMAST.TOCODEID, CAMAST.CODEID) = SB2.CODEID
      AND ISS2.ISSUERID = SB2.ISSUERID
      AND camast.frdatetransfer <= GETCURRDATE() AND camast.todatetransfer >=GETCURRDATE()
) MST, ( Select VWW.*, ''Y''ISSUERMEMBER from VW_ISSUER_MEMBER VWW ) VW, (select VARVALUE from sysvar where VARNAME like ''%ISSUERMEMBER%'') M
WHERE  MST.CUSTODYCD = VW.CUSTODYCD  (+)
                AND MST.SYMBOL = VW.SYMBOL (+)', 'CAMAST', '', '', '3382', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;