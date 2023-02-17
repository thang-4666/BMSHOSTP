SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM0003','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM0003', 'Danh sách đối chiếu số dư Hold công ty với ngân hàng', 'Danh sách đối chiếu số dư Hold công ty với ngân hàng', 'select cf.custodycd, cf.fullname,cf.custtype, af.acctno, mst.* from
(
    select af.bankacctno,
    max(bankbalance) - max(bankavlbal) - sum(holdbalance) - (case when max(cf.custtype) =''I'' then 50000 else 1000000 end) GAP ,
    sum(holdbalance) holdbalance, max(bankbalance) bankbalance , max(bankavlbal) bankavlbal,
    (case when max(cf.custtype) =''I'' then 50000 else 1000000 end) Minamount
    from cimast ci, afmast af, cfmast cf
    where ci.acctno = af.acctno and af.custid = cf.custid
    and ci.bankbalance >0 and af.status <> ''C''
    and (ci.corebank =''Y'' or af.alternateacct=''Y'') and bankbalance> case when cf.custtype =''I'' then 50000 else 1000000 end
    group by af.bankacctno
    having max(bankbalance) - max(bankavlbal) - sum(holdbalance) - (case when max(cf.custtype) =''I'' then 50000 else 1000000 end) <>0
) mst, afmast af,cfmast cf
where mst.bankacctno = af.bankacctno and af.custid = cf.custid and af.status <> ''C''', 'CRBTRFLOG', '', '', '6602', 0, 50, 'N', 30, '', 'Y', 'T', '', 'Y', 'ACCTNO', '');COMMIT;