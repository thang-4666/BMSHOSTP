SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3390','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3390', 'Tra cứu xác nhận ngày hiệu lực phân bổ', 'Tra cứu xác nhận ngày hiệu lực phân bổ', 'select  msg.reqid, ca.VSDID vsdcaid, ca.camastid, ca.catype catypeid, ca.description, a1.cdcontent status, se.symbol,
(select symbol from sbsecurities where codeid = ca.tocodeid) EXSYMBOL, a.cdcontent catype, ca.actiondate
  from camast ca, (select msg.reqid, DECODE(vs.STATUS, ''W'', ''P'', ''C'') STATUS, msg.vsdcaid from msgcareceived msg, vsdtxreq vs where msg.reqid=vs.reqid and msg.msgtype = ''566'' AND vs.status <> ''C'') msg,
       sbsecurities se, allcode a, allcode a1
 where ca.VSDID = msg.vsdcaid
   and a.cdname = ''CATYPE'' and a.cdval = ca.catype
   and a1.cdname = ''MSGCARECEIVEDSTS'' and a1.cdval = msg.status
   and se.codeid = ca.codeid
   and ca.catype <> ''005''
   AND ca.status IN (''S'',''I'',''G'',''H'')', 'CAMAST', 'frm', '', '3390', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;