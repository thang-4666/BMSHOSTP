SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFOL01','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFOL01', 'Danh sách khách hàng khác Cá nhân Việt Nam mở trực tuyến', 'List of other customers Vietnamese individuals open online', 'select REG.AUTOID,REG.CustomerType,A1.CDCONTENT CustomerTypeDesc,
       REG.CustomerName,REG.CustomerBirth,REG.IDType,
       REG.IDCode,REG.Iddate,REG.Idplace,REG.Expiredate,
     case when reg.Customertype = ''I'' then REG.contactAddress else reg.address end Address,REG.Taxcode,REG.PrivatePhone,
       REG.Mobile,REG.Fax,REG.Email,REG.Office,REG.Position,REG.Country,REG.CustomerCity,
       REG.TKTGTT, REG.SEX, reg.custodycd, a2.cdcontent ten_thanh_pho,
       reg.bankaccountnumber1  bankaccount, reg.bankname1 BANKNAME,  A3.CDCONTENT REREGISTER,
       reg.refullname, reg.retlid, br1.brname, reg.txdate, reg.reqid, A4.CDCONTENT status, ''Thông thường'' ACCTYPEDESC,
       reg.NOTE
from REGISTERONLINE REG,ALLCODE A1, allcode a2, allcode a3, brgrp br1, allcode a4
where REG.AUTOID not in (select OLAUTOID from CFMAST where OPENVIA=''O'')
and A1.CDNAME = ''TYPEINVESTOR'' and A1.CDTYPE=''CF'' and A1.CDVAL=REG.CustomerType
and a2.cdname = ''PROVINCE'' and A2.CDTYPE=''CF'' and nvl(reg.CustomerCity,''--'') = a2.cdval
and A3.CDNAME = ''AD_HOC'' AND a3.cdtype= ''SY'' and nvl(reg.reregister, ''N'') = A3.Cdval
and A4.CDNAME = ''STATUS'' and A4.CDTYPE=''CF'' and a4.cdval = substr(REG.STATUS,1,1)
and reg.brid=br1.brid(+)
and REG.CustomerType <> ''0001''', 'ONLINERES', 'CFOL00', '', '0170', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;