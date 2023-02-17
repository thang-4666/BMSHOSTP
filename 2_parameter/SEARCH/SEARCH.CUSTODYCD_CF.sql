SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CUSTODYCD_CF','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CUSTODYCD_CF', 'Tra cứu nhanh thông tin Khách hàng', 'Customer information', 'SELECT FORMAT_CUSTID(CF.CUSTID) CUSTID,
	CASE WHEN CF.CUSTODYCD IS NULL THEN '''' ELSE CF.CUSTODYCD END CUSTODYCD,
	(CASE WHEN SUBSTR( CF.CUSTODYCD,4,1)=''F'' THEN CF.TRADINGCODE ELSE CF.IDCODE END ) TRADINGCODE,
	(CASE WHEN SUBSTR( CF.CUSTODYCD,4,1)=''F'' THEN CF.TRADINGCODEDT ELSE CF.IDDATE END ) TRADINGCODEDT,
	CF.SHORTNAME,CF.FULLNAME,CF.DATEOFBIRTH,CF.IDCODE,CF.IDDATE , A2.CDCONTENT COUNTRY, 
       	CF.IDCODE || '' - ('' ||TO_CHAR(CF.IDDATE,''DD/MM/RRRR'') || '')''IDCODE_DATE,CF.IDPLACE,CF.ADDRESS,
	MRLOANLIMIT,T0LOANLIMIT,  CF.CAREBY,  CF.CUSTID T_CUSTID  ,CF.MOBILESMS PHONE, NVL(U.USERNAME,CF.USERNAME)USERNAME, 
       	NVL(U.LOGINFAIL,0) LOGINFAIL, NVL(U.LOGINFAILMAX,0) LOGINFAILMAX,  A1.CDCONTENT AFSTATUS, 
       	CASE WHEN CF.STATUS =''G'' THEN ''G'' ELSE ''A'' END CLOSESTATUS,CF.ACTYPE, CF.IDEXPIRED, CF.ACTIVESTS, CF.CUSTTYPE, 
       	CF.MOBILESMS MOBILE, CF.COUNTRY COUNTRYCODE
FROM CFMAST CF, ALLCODE A1, ALLCODE A2 , USERLOGIN U
WHERE A2.CDTYPE = ''CF'' AND A2.CDNAME = ''COUNTRY'' AND CF.COUNTRY = A2.CDVAL
AND A1.CDTYPE=''RE'' AND A1.CDNAME=''AFSTATUS'' AND A1.CDVAL=CF.AFSTATUS
AND CF.USERNAME = U.USERNAME(+)', 'CUSTODYCD_CF', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;