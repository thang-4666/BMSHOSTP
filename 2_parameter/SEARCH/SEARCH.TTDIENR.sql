SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('TTDIENR','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('TTDIENR', 'Điện nhận từ VSD', 'Receive from VSD  ', 'SELECT c.<@CDCONTENT> CAPTION, 
    case when dtl.fldname = ''REFCORPID'' and SUBSTR(DTL.FLDVAL,1,4) = ''PCTI'' then SUBSTR(DTL.FLDVAL,6) 
        when dtl.fldname = ''REFCORPID'' and SUBSTR(DTL.FLDVAL,1,4) <> ''PCTI'' then ''''
        when dtl.fldname = ''TRADINGDATE'' and SUBSTR(DTL.FLDVAL,1,4) = ''TRAD'' then SUBSTR(DTL.FLDVAL,6)
        when dtl.fldname = ''TRADINGDATE'' and SUBSTR(DTL.FLDVAL,1,4) <> ''TRAD'' then ''''
        when dtl.fldname = ''SYMBOL'' and DTL.FLDVAL = ''RHTS'' then 
            (select dtl2.FLDVAL from VSDTRFLOGDTL dtl2 where dtl2.fldname = ''SYMBOL2'' and dtl2.refautoid = to_char(''<$KEYVAL>''))
        else DTL.FLDVAL end VALUE
FROM VSDTRFLOGDTL DTL, VSDTRFLOG LOG, (select fldname, caption CDCONTENT, en_caption EN_CDCONTENT from vsdtrfcaption) c
WHERE LOG.AUTOID=DTL.REFAUTOID
and c.fldname = dtl.fldname
AND LOG.AUTOID= to_char(''<$KEYVAL>'') ORDER BY DTL.AUTOID', 'ST.TTDIEN', 'frmRECFDEF', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;