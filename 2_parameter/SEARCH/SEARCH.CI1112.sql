SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI1112','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI1112', 'Tra cứu nhanh bảng kê UNC cần từ chối (1112)', 'View payment order (wait for 1112)', '
SELECT distinct po.*, A1.CDCONTENT POSTATUS, tl.tltxcd, fn_1112_get_info(po.txnum,TO_CHAR(po.txdate,''DD/MM/YYYY''),''CUSTODYCD'') custodycd
, fn_1112_get_info(po.txnum,TO_CHAR(po.txdate,''DD/MM/YYYY''),''ACCTNO'') ACCTNO
, fn_1112_get_info(po.txnum,TO_CHAR(po.txdate,''DD/MM/YYYY''),''BENEFCUSTNAME'') CFBENEFCUSTNAME
   FROM POMAST PO, ALLCODE A1,  tllog tl, tllogfld tf
    WHERE
        po.TXDATE=TO_DATE(''<$BUSDATE>'',''DD/MM/RRRR'')
        And tl.txnum = tf.txnum AND tl.txdate = tf.txdate
        AND tf.fldcd = ''99'' AND tf.cvalue = po.txnum
    AND PO.STATUS=A1.CDVAL AND A1.CDTYPE=''SA''
    AND A1.CDNAME=''POSTATUS'' AND POTYPE=''001'' AND PO.STATUS=''A''
    /*AND (
            (''<$BRID>'' =''0001'' AND   SUBSTR(po.txnum,0,4) IN (''0001'',''0002'',''0003''))

        OR  (''<$BRID>'' =''0101'' AND   SUBSTR(po.txnum,0,4) IN (''0101'',''0102'',''0103''))
        )*/
      ', 'CIMAST', '', '', '1112', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;