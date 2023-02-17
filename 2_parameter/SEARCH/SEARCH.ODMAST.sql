SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ODMAST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ODMAST', 'Quản lý sổ lệnh', 'Order management', 'SELECT OD.* , AL.CDCONTENT custtype, A1.CDCONTENT CUSTATCOM,odmap.ctci_order
  FROM VW_ODMAST od, cfmast cf, allcode al, ALLCODE A1,(SELECT to_char(ctci_order) ctci_order, orgorderid
  FROM ordermap_hist
union all
select to_char(ctci_order) ctci_order , orgorderid
  from ordermap
union all
select  ctci_order, orgorderid
  from ordermap_ha
union all
select  ctci_order , orgorderid
  from ordermap_ha_hist
) odmap
 WHERE od.custodycd = cf.custodycd
   and AL.CDTYPE = ''CF''
   AND AL.CDNAME = ''CUSTTYPE''
   AND AL.CDVAL = CF.CUSTTYPE
   AND A1.CDTYPE = ''SY''
   AND A1.CDNAME = ''YESNO''
   AND CF.CUSTATCOM = A1.CDVAL
   and OD.txdate = GETCURRDATE
   and od.ORDERID = odmap.orgorderid(+)', 'ODMAST', 'frmODMAST', 'ORDERID DESC', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;