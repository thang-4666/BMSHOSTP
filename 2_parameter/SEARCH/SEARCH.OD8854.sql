SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD8854','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD8854', 'Lệnh hủy/sửa đã gửi lên Sàn chưa có xác nhận', 'Cancel order (in failback wait for 8854)', 'SELECT mst.afacctno, ood.orgorderid,ood.reforderid, ood.txdate, ood.txnum, ood.symbol,
       ood.custodycd, cd1.cdcontent bors, cd2.cdcontent norp, ood.qtty,
       ood.price, cd3.cdcontent tradeplace, mst.pricetype pricetype,
       ood.oodstatus, mst.codeid,cd4.cdcontent via
  FROM ood, allcode cd1, allcode cd2, odmast mst, sbsecurities sb,
       allcode cd3, allcode cd4
 WHERE cd1.cdtype = ''OD'' AND cd1.cdname = ''EXECTYPE'' AND cd1.cdval = mst.exectype
   AND mst.orderid = ood.orgorderid
   AND sb.codeid = ood.codeid
   AND sb.tradeplace in  (''001'',''002'',''005'')
   AND mst.exectype in (''CS'',''CB'',''AB'',''AS'')
   AND cd2.cdtype = ''OD''
   AND cd2.cdname = ''NORP''
   AND cd2.cdval = ood.norp
   AND cd3.cdtype = ''OD''
   AND cd3.cdname = ''TRADEPLACE''
   AND cd3.cdval = sb.tradeplace
   AND ood.oodstatus = ''B''
   AND cd4.cdtype = ''OD'' AND cd4.cdname = ''VIA'' AND cd4.cdval = mst.via
   AND ood.orgorderid NOT IN (SELECT orderid
                            FROM stcorderbook)
  ', 'ODMAST', '', '', '8854', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;