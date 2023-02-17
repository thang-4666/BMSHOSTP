SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CUSTODYCD_2229','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CUSTODYCD_2229', 'Tra cứu nhanh thông tin Khách hàng', 'Customer information', 'SELECT format_custid(CF.CUSTID) CUSTID,  case when CF.CUSTODYCD is null then '''' else CF.CUSTODYCD end CUSTODYCD--,AF.ACCTNO
  , (CASE WHEN SUBSTR( CF.CUSTODYCD,4,1)=''F'' THEN CF.tradingcode ELSE CF.IDCODE END ) tradingcode,  (CASE WHEN SUBSTR( CF.CUSTODYCD,4,1)=''F'' THEN CF.tradingcodedt ELSE CF.IDDATE END ) tradingcodedt,
CF.SHORTNAME,CF.FULLNAME,CF.DATEOFBIRTH,CF.IDCODE,CF.IDDATE , a2.cdcontent country, CF.IDCODE || '' - ('' ||TO_CHAR(CF.IDDATE,''DD/MM/RRRR'') || '')''IDCODE_DATE,CF.IDPLACE,CF.ADDRESS,
mrloanlimit,t0loanlimit,  CF.careby,  CF.CUSTID T_CUSTID  ,CF.MOBILESMS PHONE, nvl(u.username,cf.USERNAME)
USERNAME, nvl(u.loginfail,0) loginfail, nvl(u.loginfailmax,0) loginfailmax,  A1.cdcontent AFSTATUS, CASE WHEN CF.STATUS =''G'' THEN ''G'' ELSE ''A'' END CLOSESTATUS,CF.ACTYPE,  cf.idexpired, cf.activests, cf.custtype, cf.mobilesms mobile, cf.country countrycode,
TT.fullname ISFULLNAME, TT.ROLECD ROLECD, CON.ADDRESS CONADDRESS
FROM CFMAST CF, allcode a1, ALLCODE A2 , userlogin u, 
(
    SELECT I.CUSTID ,ISS.FULLNAME,A0.CDCONTENT ROLECD
    FROM ISSUER_MEMBER I ,ALLCODE A0 ,ISSUERS ISS
    WHERE ISS.ISSUERID =I.ISSUERID 
    AND A0.CDTYPE = ''SA'' 
    AND A0.CDNAME = ''ROLECD'' 
    AND A0.CDVAL= I.ROLECD
) TT, CFCONTACT CON
WHERE CF.CUSTID = TT.CUSTID(+)
and CF.CUSTID = CON.CUSTID(+)
and A2.CDTYPE = ''CF'' 
AND A2.CDNAME = ''COUNTRY'' 
AND cf.country = a2.cdval
and a1.cdtype=''RE'' 
and A1.cdname=''AFSTATUS'' 
AND A1.cdval=CF.afstatus
and cf.username = u.username(+)', 'CUSTODYCD_CF', '', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTID');COMMIT;