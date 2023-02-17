SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('BO0001','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('BO0001', 'Màn hình theo dõi thứ cấp', 'Màn hình theo dõi thứ cấp', 'SELECT mst.autoid, A0.CDCONTENT STATUS, SB.SYMBOL, iss.fullname issfullname, a3.CDCONTENT BONDTYPE,
    CF.FULLNAME, mst.coupon, sb.issuedate, sb.expdate, MST.QTTY, MST.QTTY*nvl(sb.parvalue,0) amt,
    mst.refid, mst.ptxdate ngaymua, mst.pvaldate ngaygiatrimua, mst.yeild, mst.price buyprice,
    MST.QTTY*mst.price buyamt, RCF.FULLNAME buyfullname, mst.prefid, mst.txdate selldate, mst.valdate sellvaldate,
    mst.pyeild, mst.pprice, MST.QTTY*mst.pprice sellamt, (MST.QTTY*mst.pprice)-(MST.QTTY*mst.price) PNL,
    mst.feersv chiphivon, mst.feeothr, round((((MST.QTTY*mst.pprice)+(MST.QTTY*mst.price))*0.0075)/100) CPdatlenh,
    ((MST.QTTY*mst.pprice)-(MST.QTTY*mst.price))-
    (nvl(mst.feersv,0) + nvl(mst.feeothr,0) + round(((nvl((MST.QTTY*mst.pprice),0)+nvl((MST.QTTY*mst.price),0))*0.0075)/100) )
    LoiNhuan
FROM BONDDEAL MST, CFMAST CF, SBSECURITIES SB, ALLCODE A0, ALLCODE A1, ALLCODE A2,
    (SELECT CUSTID, FULLNAME FROM CFMAST UNION ALL SELECT ''NULL'' CUSTID, ''---'' FULLNAME FROM DUAL) RCF,
    ISSUERS iss, ALLCODE A3
WHERE MST.CUSTID=CF.CUSTID AND MST.CODEID=SB.CODEID AND NVL(MST.PCUSTID,''NULL'') = RCF.CUSTID
    AND A0.CDTYPE=''SY'' AND A0.CDNAME=''TYPESTS'' AND A0.CDVAL=MST.STATUS
    AND A1.CDTYPE=''SA'' AND A1.CDNAME=''DEALTYPE'' AND A1.CDVAL=MST.DEALTYPE
    AND A2.CDTYPE=''SA'' AND A2.CDNAME=''BORS'' AND A2.CDVAL=MST.BORS
    AND MST.DEALTYPE=''S'' and sb.issuerid=iss.issuerid
    and A3.CDTYPE = ''SA'' AND A3.CDNAME = ''BONDTYPE'' AND A3.CDUSER=''Y''
    and sb.bondtype = A3.cdval', 'BONDDEAL', 'frmBONDDEAL', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;