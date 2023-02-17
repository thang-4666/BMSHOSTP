SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFOL00','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFOL00', 'Quản lý các tài khoản đăng ký từ online', 'Management online register', 'select REG.AUTOID, REG.CustomerType, A1.CDCONTENT CustomerTypeDesc, REG.CustomerName,REG.CustomerBirth,REG.IDType,
       REG.IDCode,REG.Iddate,REG.Idplace,REG.Expiredate, REG.Taxcode,REG.PrivatePhone,REG.contactAddress Address,
       REG.Mobile,REG.Fax,REG.Email,REG.Country,REG.CustomerCity,
       REG.TKTGTT, REG.SEX, a2.cdcontent ten_thanh_pho, reg.bankaccountnumber1 bankaccount,
       reg.bankname1 BANKNAME, A3.CDCONTENT REREGISTER, reg.refullname, API.carename retlid, br1.brname, reg.txdate,
       case when substr(nvl(reg.REGISTERSERVICES, ''NNNNN''),1,1) = ''Y'' then ''GD Internet,'' else '''' end ||
       case when substr(nvl(reg.REGISTERSERVICES, ''NNNNN''),2,1)= ''Y''then ''GD Điện thoại,'' else '''' end  ||
       case when substr(nvl(reg.REGISTERSERVICES, ''NNNNN''),3,1)= ''Y''then ''UTTB tự động,'' else '''' end  ||
       case when substr(nvl(reg.REGISTERSERVICES, ''NNNNN''),4,1)= ''Y''then ''GD kỹ quỹ CK,'' else '''' end  ||
       case when substr(nvl(reg.REGISTERSERVICES, ''NNNNN''),5,1)= ''Y''then ''GD FDS'' else '''' end  GDCK,
       case when substr(nvl(reg.REGISTERNOTITRAN, ''NNN''),1,1) = ''Y'' then ''EMAIL,'' else '''' end ||
       case when substr(nvl(reg.REGISTERNOTITRAN, ''NNN''),2,1)= ''Y''then ''SMS,'' else '''' end  ||
       case when substr(nvl(reg.REGISTERNOTITRAN, ''NNN''),3,1)= ''Y''then ''Trực tuyến'' else '''' end TBKQGD,
       case when substr(nvl(reg.AUTHENTYPEONLINE, ''NN''),1,1) = ''Y'' then ''OTP,'' else '''' end ||
       case when substr(nvl(reg.AUTHENTYPEONLINE, ''NN''),2,1)= ''Y''then ''CA'' else '''' end  PTXT,
       case when nvl(reg.AUTHENTYPEMOBILE, ''N'')= ''Y''then ''OTP'' else '''' end PTXTMABLE,
       a4.cdcontent ACCTYPEDESC, api.ekycai, REG.BRID,
       CASE WHEN REG.ACCTYPE =''E'' THEN ''IMAGE'' ELSE NULL END IDATTACH, REG.REQID, a6.cdcontent status,
       REG.NOTE, nvl(a7.CDCONTENT,'''') REASONREJECT
from REGISTERONLINE REG, brgrp br1, ALLCODE A1, allcode a2, allcode a3, allcode a4, allcode a6,
    (select A.REQID, E.TYPEINVEST, A.EKYCAI, E.CARENAME, E.CAREBYID
     from EKYC_CFINFOR E, (SELECT reqid, errnum, ekycai
                           FROM (SELECT td.*, ROW_NUMBER() OVER (PARTITION BY reqid ORDER BY AUTOID DESC) RN
                                 FROM APIOPENACCOUNT td  ORDER BY AUTOID DESC)
                                 WHERE RN = 1) a
     WHERE E.REQID = A.REQID AND A.ERRNUM IS NULL) API,
     (select * from allcode where cdname = ''REASON_REJECTEMAIL'' and cdtype = ''CF'') a7
where REG.AUTOID not in (select OLAUTOID from CFMAST where OPENVIA=''O'') AND reg.brid = br1.brid(+)
  and A1.CDTYPE =''CF'' and A1.CDNAME =''TYPEINVESTOR'' and A1.CDVAL = REG.CustomerType
  and A2.CDTYPE =''CF'' and a2.cdname =''PROVINCE'' and a2.cdval = nvl(reg.CustomerCity,''--'')
  And a3.cdtype =''SY'' and A3.CDNAME =''AD_HOC'' and nvl(reg.reregister,''N'') = A3.Cdval
  And a4.cdtype =''CF'' and a4.CDNAME =''ACCTYPE'' and nvl(REG.ACCTYPE,''O'') = a4.Cdval
  And a6.cdtype =''CF'' and a6.CDNAME =''CFSTATUS'' and substr(REG.STATUS,1,1) = a6.Cdval
  and reg.reqid = api.reqid(+) and substr(REG.STATUS,1,1) = ''P'' and REG.CustomerType =''0001''
  and reg.status = a7.cdval (+)
  and API.CAREBYID IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = ''<$TELLERID>'')', 'ONLINERES', 'CFOL00', 'AUTOID DESC', '0169', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;