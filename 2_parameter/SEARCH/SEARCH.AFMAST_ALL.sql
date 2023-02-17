SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('AFMAST_ALL','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('AFMAST_ALL', 'Quản lý tiểu khoản', 'Contract management', 'Select a.*, nvl(LIMITMAX,0)LIMITMAX ,nvl(USERHAVE,0)USERHAVE
from
(
SELECT mst.SHORTNAME, mst.ACTYPE, mst.ACNAME, format_custid(mst.CUSTID) CUSTID,
    mst.FULLNAME, mst.CUSTNAME, format_custodycd(mst.CUSTODYCD) CUSTODYCD,
    mst.CUSTODYCD CUSTODYCD_SRCH, mst.ISCOREBANK, mst.COREBANKTEXT,
    format_subac(mst.ACCTNO) ACCTNO, mst.AFTYPE, mst.TYPENAME, mst.TRADEFLOOR,
    mst.TRADETELEPHONE, mst.TRADEONLINE, mst.PIN, mst.IDCODE, mst.LICENSE,
    mst.IDDATE, mst.IDPLACE, mst.OLDTLID, mst.BANKACCTNO, mst.SWIFTCODE, mst.EMAIL, mst.ADDRESS,
    mst.FAX, mst.ISOTC, mst.VIA, format_subac(mst.ACCTNO) CIACCTNO, mst.LASTDATE, mst.STATUS,
    mst.ADVANCELINE, mst.BRATIO, mst.TERMOFUSE, mst.DESCRIPTION, mst.CAREBYname CAREBY,
    mst.CAREBYID, mst.REFNAME, mst.corebank, mst.bankname, mst.MRIRATE, mst.MRMRATE, mst.MRLRATE,
    mst.MRCRLIMIT, mst.MRCRLIMITMAX, NVL(USF.ACCLIMIT,0) ACCLIMIT, mst.mrtype, mst.COUNTRY, mst.EDITALLOW,
    mst.APRALLOW, ''N'' AS DELALLOW, mst.mriratio, mst.mrmratio, mst.mrlratio, mst.PHONE1,
    nvl(cfa.cfafullname,'' '') cfafullname, nvl(cfa.cfaaddress,'' '') cfaaddress,
    nvl(cfa.cfamobilesms,'' '') cfamobilesms, nvl(cfa.cfaidcode,'' '') cfaidcode,
    nvl(cfa.cfaidplace,'' '') cfaidplace, cfa.cfaiddate cfaiddate, nvl(cfa.cfcustid,'' '') cfacustid  , MST.isdebtt0
FROM v_afmast_all mst,
    (SELECT * FROM USERAFLIMIT WHERE  TLIDUSER=''<$TELLERID>'' AND  TYPERECEIVE=''MR'') USF ,
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
where MST.ACCTNO =USF.ACCTNO (+)
    AND MST.custid = CFA.cfcustid(+)
    AND (SUBSTR(MST.CUSTID,1,4) = DECODE(''<$BRID>'', ''<$HO_BRID>'', SUBSTR(MST.CUSTID,1,4), ''<$BRID>'')
    OR MST.CAREBY IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = ''<$TELLERID>''))
) A
    LEFT JOIN
    (Select NVL(US.ACCTLIMIT,0) LIMITMAX,NVL(US.ALLOCATELIMMIT-US.USEDLIMMIT,0) USERHAVE
    from userlimit US where US.tliduser=''<$TELLERID>'') us on 0=0', 'AFMAST_ALL', 'frmAFMAST', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;