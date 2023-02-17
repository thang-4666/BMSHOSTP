SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3383','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3383', 'Chuyển nhượng quyền mua ra ngoài và nội bộ', 'Transfer', 'SELECT MST.*, (CASE WHEN VW.ISSUERMEMBER=''Y'' THEN ''Thành viên quản trị của TCPH'' ELSE ''Không'' END ) ISSUERMEMBER,
    M.VARVALUE FROMCUSADD, (CASE WHEN VW.ISSUERMEMBER=''Y''THEN ''Y'' ELSE ''N'' END ) ISSUERMEMBERCD
FROM (SELECT caf.QTTY, caf.PQTTY ,
    SUBSTR(CAMAST.CAMASTID,1,4) || ''.''||
    SUBSTR(CAMAST.CAMASTID,5,6) ||''.'' ||
    SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
           CA.AFACCTNO, CAMAST.optcodeid  CODEID,
    SYM.SYMBOL,SYM.TRADEPLACE, A1.CDCONTENT
    STATUS,CA.AFACCTNO || CAMAST.CODEID
    SEACCTNO,SYM.PARVALUE PARVALUE,
           CAMAST.REPORTDATE REPORTDATE,
    CAMAST.ACTIONDATE,CAMAST.EXPRICE, AFM.*, A2.CDCONTENT
    CATYPE, CAMAST.TRFLIMIT,ISS.FULLNAME ISSNAME,
    CAMAST.codeid codeid0,
    CA.autoid, sb2.symbol tosymbol, iss2.fullname toissname,
    sb2.codeid tocodeid, camast.isincode
FROM  SBSECURITIES SYM,issuers ISS , ALLCODE A1, CAMAST, CASCHD CA,
      (
      Select af.ACCTNO, CF.CUSTODYCD, cf.fullname
        CUSTNAME, A1.CDCONTENT COUNTRY, cf.address,
        (case when cf.country = ''234'' then cf.idcode else cf.tradingcode end) LICENSE,
        (case when cf.country = ''234'' then cf.iddate else cf.tradingcodedt end) iddate,
        cf.idplace
      From cfmast cf, afmast af, ALLCODE A1
      Where af.custid = cf.custid
              and af.status  IN (''A'',''N'')
              AND CF.COUNTRY = A1.CDVAL
              AND A1.CDTYPE =''CF''
              AND A1.CDNAME = ''COUNTRY''
       ) AFM, ALLCODE A2, sbsecurities sb2, issuers iss2,
       (
        select cf.custodycd, ca.camastid,
            sum(CA.Pbalance-ca.inbalance) QTTY, sum(CA.Pbalance- ca.inbalance) PQTTY
        from CAMAST, CASCHD CA, cfmast cf, afmast af
        where cf.custid = af.custid and af.acctno = ca.AFACCTNO
            AND CAMAST.status in (''V'',''S'',''M'')
            AND CAMAST.catype = ''014'' AND CA.camastid = CAMAST.camastid
            AND CA.status in(''V'',''S'',''M'') AND CA.DELTD <>''Y'' AND CA.PBALANCE - ca.inbalance > 0
            AND CAMAST.TRFLIMIT = ''Y''
            AND camast.frdatetransfer <= GETCURRDATE() AND camast.todatetransfer >= GETCURRDATE()
        group by cf.custodycd, ca.camastid
        ) caf
WHERE CA.AFACCTNO=AFM.ACCTNO AND A1.CDTYPE = ''CA''
    AND A1.CDNAME = ''CASTATUS'' AND A1.CDVAL = CA.STATUS
    AND CAMAST.CODEID = SYM.CODEID AND CAMAST.status in (''V'',''S'',''M'')
    and AFM.CUSTODYCD = caf.custodycd and ca.camastid = caf.camastid
    AND CAMAST.catype=''014'' AND CA.camastid = CAMAST.camastid
    AND CA.status in(''V'',''S'',''M'') AND CA.DELTD <>''Y'' AND CA.PBALANCE - ca.inbalance > 0
    AND CAMAST.CATYPE = A2.CDVAL AND A2.CDTYPE = ''CA''
    AND A2.CDNAME = ''CATYPE'' AND CAMAST.TRFLIMIT = ''Y'' AND ISS.ISSUERID = SYM.ISSUERID
    and nvl(camast.tocodeid, camast.codeid) = sb2.codeid and sb2.issuerid = iss2.issuerid
    AND camast.frdatetransfer <= GETCURRDATE() AND camast.todatetransfer >= GETCURRDATE()
) MST, (Select VWW.*, ''Y'' ISSUERMEMBER from VW_ISSUER_MEMBER VWW) VW, (select VARVALUE from sysvar where VARNAME like ''%ISSUERMEMBER%'') M
WHERE  MST.CUSTODYCD = VW.CUSTODYCD  (+)
                AND MST.SYMBOL = VW.SYMBOL (+)', 'CAMAST', '', '', '3383', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;