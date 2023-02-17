SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3395','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3395', 'Tra cứu nhanh bảng kê đăng ký quyền mua cần từ chối(3395)', 'View payment order (wait for 3395)', 'SELECT distinct A.*, po.camastid, po.symbol, PO.ISINCODE
FROM
(select potxnum, potxdate from CIREMITTANCE  where deltd=''N'' and  potxnum is not null group by potxnum,potxdate) CI,
(
    SELECT PO.TXDATE, PO.TXNUM, PO.AMT, PO.BRID, PO.DELTD, CD.CDCONTENT POSTATUS, PO.BANKID, PO.BANKNAME, PO.BANKACC,
        PO.BANKACCNAME, PO.GLACCTNO, PO.FEETYPE, PO.POTYPE, PO.BENEFACCT, PO.BENEFNAME, PO.BENEFCUSTNAME,
        PO.DESCRIPTION, tl.tltxcd
    FROM POMAST PO, ALLCODE CD, vw_tllog_all tl, vw_tllogfld_all tf
    WHERE CD.CDNAME =''POSTATUS'' AND CD.CDTYPE =''SA''
    And tl.txnum = tf.txnum AND tl.txdate = tf.txdate
    AND tf.fldcd = ''99'' AND tf.cvalue = po.txnum
    AND PO.POTYPE=''002'' AND PO.STATUS=''A''
    AND CD.CDVAL= PO.STATUS AND PO.DELTD=''N''  and po.codeid is null
) A left join
(
    select DISTINCT po.potxnum, po.potxdate, po.camastid, sb.symbol, CA.ISINCODE
    from
    (
        select potxnum, potxdate, camastid from podetails
        union all
        select potxnum, potxdate, camastid from podetailshist
    ) po,
    (select * from camast union all select * from camasthist) ca, sbsecurities sb
    where po.camastid = ca.camastid
        and ca.codeid = sb.codeid
) po
on A.txnum = po.potxnum and a.txdate = po.potxdate
WHERE A.TXDATE = CI.POTXDATE AND A.TXNUM = CI.POTXNUM
     AND A.TXDATE = TO_DATE(''<$BUSDATE>'',''DD/MM/RRRR'')
union
SELECT PO.TXDATE, PO.TXNUM, PO.AMT, PO.BRID, PO.DELTD, CD.CDCONTENT POSTATUS, PO.BANKID, PO.BANKNAME, PO.BANKACC,
    PO.BANKACCNAME, PO.GLACCTNO, PO.FEETYPE, PO.POTYPE, PO.BENEFACCT, PO.BENEFNAME, PO.BENEFCUSTNAME,
    PO.DESCRIPTION, tl.tltxcd, pod.camastid, pod.symbol, POD.ISINCODE
FROM  ALLCODE CD, vw_tllog_all tl, vw_tllogfld_all tf, POMAST PO
left join
(
    select DISTINCT po.potxnum, po.potxdate, po.camastid, sb.symbol, CA.ISINCODE
    from
    (
        select potxnum, potxdate, camastid
        from podetails
        union all
        select potxnum, potxdate, camastid from podetailshist
    )po,
    (select * from camast union all select * from camasthist) ca, sbsecurities sb
    where po.camastid = ca.camastid
        and ca.codeid = sb.codeid
) pod
on po.txnum = pod.potxnum and po.txdate = pod.potxdate
WHERE CD.CDNAME = ''POSTATUS'' AND CD.CDTYPE =''SA''
    AND CD.CDVAL= PO.STATUS AND PO.DELTD=''N'' and po.codeid is not null
    AND tl.txnum = tf.txnum AND tl.txdate = tf.txdate
    AND tf.fldcd = ''99'' AND tf.cvalue = po.txnum
    AND PO.POTYPE=''002'' AND PO.STATUS=''A''
    AND PO.TXDATE = TO_DATE(''<$BUSDATE>'',''DD/MM/RRRR'')', 'CAMAST', '', '', '3395', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;