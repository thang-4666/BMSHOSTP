SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('V_SE2240','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('V_SE2240', 'Danh sách import giao dịch lưu ký chứng khoán(2240)', 'View pending securities deposit (wait for 2240)', 'SELECT TB.AUTOID,SB.CODEID, TB.SYMBOL, TB.CUSTODYCD,TB.AFACCTNO,TB.AFACCTNO||SB.CODEID  ACCTNO,
    CF.FULLNAME CUSTNAME,CF.IDCODE LICENSE,CF.ADDRESS ADDRESS,CF.IDDATE LICENSEDATE,
    cf.MOBILESMS PHONE, SB.PARVALUE PARVALUE, TB.DEPOTRADE,TB.PRICE,TB.QTTYTYPE,
    TB.CUSTNAMEAUTH, TB.DEPOBLOCK, TB.LICENSEAUTH, TB.WTRADE, TB.RDATE,
    TB.DEPOTRADE+TB.DEPOBLOCK  QTTY, TB.LICENSEAUTHDATE,TB.CFACCTNOAUTH,TB.LICENSEAUTHPLACE, TB.TX_NUM,
    TB.DES, TB.ISCOMMITTED, SY.varvalue LICENSEDATEOLD,
    nvl(cfa.cfafullname,'' '') cfafullname, nvl(cfa.cfaaddress,'' '') cfaaddress,
    nvl(cfa.cfamobilesms,'' '') cfamobilesms, nvl(cfa.cfaidcode,'' '') cfaidcode,
    nvl(cfa.cfaidplace,'' '') CFAIDPLACE, CFA.CFAIDDATE CFAIDDATE, nvl(cfa.cfcustid,'' '') cfacustid,
    ISS.fullname SECURITIESNAME
FROM TBLSE2240 TB, SBSECURITIES SB, CFMAST CF, AFMAST AF, sysvar sy, issuers ISS,
    (
        select distinct cfa.cfcustid, decode(cfa.custid,null,cfa.fullname,cf2.fullname) cfafullname,
            decode(cfa.custid,null,cfa.address,cf2.address) cfaaddress,
            decode(cfa.custid,null,cfa.telephone,cf2.mobilesms) cfamobilesms,
            decode(cfa.custid,null,cfa.licenseno,cf2.idcode) cfaidcode,
            cfa.valdate, cfa.expdate,
            decode(cfa.custid,null,cfa.lnplace,cf2.idplace) cfaidplace,
            decode(cfa.custid,null,cfa.lniddate,cf2.iddate) cfaiddate,
            decode(cfa.custid,null,null,cf2.mobile) cfamobile,
            decode(cfa.custid,null,null,cf2.email) cfaemail
        from afmast af, cfauth cfa, cfmast cf2,
            (
                select cfa.cfcustid, max(cfa.autoid) autoid
                from cfauth cfa, sysvar sys
                where cfa.deltd <> ''Y'' and substr(cfa.linkauth,9,1) = ''Y''
                    and sys.varname = ''CURRDATE'' and sys.grname = ''SYSTEM''
                    and cfa.expdate >= to_date(sys.varvalue,''DD/MM/RRRR'')
                group by cfa.cfcustid
            ) cfa2
        where af.custid = cfa.cfcustid and cfa.custid = cf2.custid(+)
            and cfa.autoid = cfa2.autoid
   )cfa
WHERE TB.AFACCTNO = AF.ACCTNO AND TB.CUSTODYCD = CF.CUSTODYCD AND TB.SYMBOL = SB.SYMBOL
    AND CF.custid = CFA.cfcustid(+)
    and sy.grname = ''SYSTEM'' and sy.varname = ''CURRDATE''
    AND SB.issuerid = ISS.issuerid (+)
AND CF.CUSTID= AF.CUSTID AND NVL(TB.DELTD,''0'') <>''Y''  AND TB.AUTOID
NOT IN (SELECT REFKEY FROM TLLOGEXT WHERE TLTXCD=''2240'' AND DELTD=''N'' AND STATUS IN (''0'',''1'', ''3'',''4'') )', 'SEMAST', 'frmSEMAST', '', '2240', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;