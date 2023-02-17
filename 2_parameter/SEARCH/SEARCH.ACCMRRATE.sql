SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ACCMRRATE','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ACCMRRATE', 'Tra cuu trang thai nhom tieu khoan bi Call Margin', 'View margin account in maintanance status', '
select mst.*, CF.CUSTODYCD, v_advPay.advamt,
round((case when MARGINRATE * MRIRATE =0 then greatest(-OUTSTANDING,0) else
greatest( 0,-OUTSTANDING-NAVACCOUNT *100/MRIRATE) end),0) ADDVND
from CFMAST CF, v_acoountmarginrate mst  LEFT JOIN v_getAccountAvlAdvance v_advPay ON v_advPay.afacctno=mst.afacctno
where mst.CUSTID = CF.CUSTID AND groupleader=<$KEYVAL> ORDER BY cf.custodycd', 'MRTYPE', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;