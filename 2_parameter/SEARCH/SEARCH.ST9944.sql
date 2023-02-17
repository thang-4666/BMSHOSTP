SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ST9944','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ST9944', 'Tra cứu điện thông báo từ VSD (598)', 'Manage notification messages from VSD (598)', 'select v.autoid,l.refmsgid REFID,l.msgtype MTTYPE, c.CDCONTENT MTNAME,
    (case when INSTR(v.symbol,''ISIN'')>0 then REPLACE(v.symbol,''ISIN '')
    else '''' end) ISIN,v.vsdmsgdate CRDATE,v.PAYMENTCYCLE PERIOD,
    (case when INSTR(v.symbol,''ISIN'')>0 then ''''
        else case when INSTR(v.symbol,''/'')>0 then SUBSTR(v.symbol,4)
            else v.symbol end
        end
    )SYMBOL,
    A0.CDCONTENT ISSTYPE, v.placeid PLACEID ,v.qtty QTTY ,v.room ROOM ,v.description DESCRIPTION  , v.vsdpromsg_value CATYPE
from vsd_mt598_inf v, 
(
    select * from vsdtrflog 
    union all
    select * from vsdtrfloghist
)L, 
(select trfcode,en_description EN_CDCONTENT, description CDCONTENT from vsdtrfcode)c, 
(select * from allcode where cdname = ''VSDTYPE_598'' and cdtype = ''SA'') A0
where v.vsdmsgid = l.autoid and v.vsdpromsg = c.trfcode
    and v.vsdmsgtype= A0.cdval(+)', 'CFMAST', 'frmMT598', 'AUTOID DESC', '', 0, 50, 'Y', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;