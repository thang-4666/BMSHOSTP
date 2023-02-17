SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD9878','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD9878', 'HA Putthourgh Cancelled list', 'HA Putthourgh Cancelled list', 'Select SECURITYSYMBOL,CONFIRMNUMBER,VOLUME,PRICE,BUYFIRM,SELLFIRM,BORS,ORGORDERID,confirm_no,Text
From
(
--Huy lenh thoa thuan da thuc hien (ca mua va ban):
Select c.SECURITYSYMBOL,c.CONFIRMNUMBER,c.VOLUME, c.PRICE, o.FIRM BUYFIRM,
o.SELLERCONTRAFIRM  SELLFIRM, i.bors  BORS,i.ORGORDERID, i.confirm_no, ''Huy da thuc hien'' Text
from Haptcancelled c, orderptack o, iod i
where c.CONFIRMNUMBER =o.confirmnumber(+) and c.CONFIRMNUMBER =i.confirm_no
--and o.status  =''A''
union all
--Xoa lenh thoa thuan chua xac nhan (ban)
select o.SECURITYSYMBOL,c.CONFIRMNUMBER,c.VOLUME, od.PRICE, o.FIRM BUYFIRM,
o.SELLERCONTRAFIRM  SELLFIRM, o.side BORS,od.ORGORDERID, '''' confirm_no , ''Huy ban chua xac nhan hoac tu choi lenh mua'' Text
from Haptcancelled c, orderptack o, ordermap_ha om,ood od
where c.CONFIRMNUMBER =o.confirmnumber
and o.confirmnumber =om.order_number
and om.orgorderid =od.orgorderid
and o.confirmnumber not in (select NVL(confirm_no,''1'') from iod)
and od.oodstatus =''B''
) Where 1=1', 'ODMAST', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;