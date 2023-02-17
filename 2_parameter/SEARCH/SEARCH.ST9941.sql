SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ST9941','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ST9941', 'Tra cứu điện bị lỗi', 'Manage error requests', 'SELECT reqdtl.cval, REQ.REQID,REQ.OBJNAME,substr(REQ.TRFCODE,1,3) TRFCODE,REQ.OBJKEY,to_date(REQ.TXDATE,''DD/MM/RRRR'')TXDATE ,
REQ.Afacctno,
case WHEN REQ.MSGACCT in (select custodycd from cfmast where custodycd = REQ.MSGACCT) then REQ.MSGACCT
     else
        case when REQ.Afacctno in (select acctno from afmast where acctno = REQ.Afacctno)
            then (select cf.custodycd from cfmast cf,afmast af where cf.custid = af.custid and af.acctno = REQ.Afacctno)
             when REQ.MSGACCT in (select cf.custid from cfmast cf where cf.custid = REQ.MSGACCT) 
            then (select cf.custodycd from cfmast cf where cf.custid = REQ.MSGACCT)
        else '''' end
     end MSGACCT,
REQ.NOTES,A5.CDCONTENT MSGSTATUS,REQ.VSD_ERR_MSG ,to_char(req.CREATEDATE,''hh24:mi:ss'') CREATEDATE ,req.tlid,tl.tlname,''NACK'' SWPROCESS
FROm VSDTXREQ REQ, ALLCODE A5,tlprofiles tl,
(select reqid,max(cval) cval from vsdtxreqdtl where fldname=''CUSTODYCD'' group by reqid) reqdtl
WHERE A5.CDTYPE=''SA'' AND A5.CDNAME=''VSDTXREQSTS'' AND A5.CDVAL=REQ.MSGSTATUS
and req.tlid=tl.tlid(+) And  req.MSGSTATUS in (''E'',''N'',''R'')
and req.reqid=reqdtl.reqid(+)', 'CFMAST', 'frmMMSG', 'REQID DESC', '', 0, 50, 'Y', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;