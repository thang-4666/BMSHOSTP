SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI1178','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI1178', 'Đảo nguồn ứng trước lệnh bán theo ngày (1178)', 'View available order for advance payment (wait for 1178)', '
select mst.*,
greatest(round(advamt*Days*advrate/36500),advminfee) NEW_FEEAMT, --09**13**12//40
greatest(round(advamt*Days*advbankrate/36500),advminfeebank) NEW_BNKFEEAMT, --09**13**15//40  17
(mst.new_vatrate*mst.AMT/100) NEW_VATAMT
from (
select ad.autoid, ad.ismortage, ad.status, ad.deltd, ad.acctno, ad.txdate,
       ad.txnum, ad.refadno, ad.cleardt, ad.amt + greatest(newad.advminfee,round(ad.amt*newad.advrate/100/365*(ad.cleardt- ad.txdate)/(1-newad.advrate/100/365*(ad.cleardt- ad.txdate))),0) advamt,ad.amt, ad.feeamt, ad.vatamt,
       ad.bankfee, ad.paidamt, ad.oddate, ad.rrtype, ad.custbank, ad.ciacctno,
       ad.paiddate, ad.adtype, ad.paidfee,ad.cleardt- ad.txdate days,
cf.fullname, cf.custodycd, af.actype aftype,af.actype || ''-'' || ''<$ADTYPE>'' AFADTYPE,
    (CASE WHEN CI.COREBANK=''Y'' THEN 1 ELSE 0 END) TRFBANK,
    (CASE WHEN CI.COREBANK=''Y'' THEN 1 ELSE 0 END) COREBANK,
    (CASE WHEN CI.COREBANK=''Y'' THEN AF.BANKACCTNO ELSE NULL END) BANKACCT,
    (CASE WHEN CI.COREBANK=''Y'' THEN AF.BANKNAME ELSE NULL END) BANKCODE,
adt.display typename,adt.vatrate,adt.aintrate, adt.aminbal,
adt.afeebank, adt.aminfeebank,''<$ADTYPE>'' NEWADTYPE,adt.AMINFEE,
newad.advminfee, newad.advminfeebank,newad.advbankrate,newad.advminamt,
newad.advrate, newad.vatrate new_vatrate
from adschd ad,vw_af_adtype_info adt, afmast af, cfmast cf, cimast ci, adtype newad
where ad.deltd <> ''Y'' and ad.Paidfee<=0 and af.custid= cf.custid
and newad.actype=''<$ADTYPE>''
and ad.acctno = af.acctno and ci.afacctno = af.acctno
and af.actype = adt.filtercd and ad.adtype = adt.value
and ad.status =''N'' and ad.txdate = to_date(''<$BUSDATE>'',''dd/mm/rrrr'')
and ad.adtype <> ''<$ADTYPE>'') mst where 0=0 ', 'CIMAST', '', '', '1178', NULL, 100, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;