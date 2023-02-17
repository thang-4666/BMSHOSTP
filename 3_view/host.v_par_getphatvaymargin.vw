SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_PAR_GETPHATVAYMARGIN
(CUSTODYCD, ACCTNO, CUSTODYCD_FSS, DAYCREDIT, BALANCE, 
 HOLDBALANCE, ODAMT, DUEAMT, OVAMT, SECUREAMT, 
 TRA_NO, PHATVAYFSS, PHATVAY_SBS, LECH_PHATVAY_FSS_SBS)
BEQUEATH DEFINER
AS 
select a.custodycd,af.acctno, cf1.custodycd custodycd_fss, a.daycredit, ci.balance,ci.holdbalance,
        ci.odamt,nvl(indue.nml,0) dueamt, nvl(ov.ovamt,0) ovamt, NVL (b.secureamt, 0) secureamt,
        least(greatest(balance,0), odamt) tra_no,
        -balance +  NVL (b.secureamt, 0) phatvayfss,
        
    --greatest(-(ci.balance - least(ci.balance,ci.odamt) - nvl(secureamt,0)) - least(balance, 0),0) PhatvayFSS,
    a.currentdebit Phatvay_SBS,
    (-balance +  NVL (b.secureamt, 0)) - nvl(a.currentdebit,0) Lech_Phatvay_FSS_SBS
    from (select distinct t3.* from ss_phatvaymargin t3) a, cfmast cf, afmast af, aftype aft , cimast ci, mrtype mrt, cfmast cf1,
    (SELECT od.afacctno, sum(od.execamt+ od.feeacr) secureamt
        FROM odmast od
        where od.txdate = getcurrdate
        AND od.deltd <> 'Y'
        AND od.exectype IN ('NB', 'BC')
        and od.stsstatus <> 'C' group by od.afacctno) b,
    (select m.trfacctno, sum(nml + INTDUE + FEEINTDUE) nml
        from
        (SELECT ACCTNO, SUM(NML) NML
            FROM LNSCHD
            WHERE OVERDUEDATE =getcurrdate AND nml + INTDUE + FEEINTDUE > 0 AND REFTYPE IN ('P') group by acctno) S,
            LNMAST M
        where S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C') and M.FTYPE<>'DF'
        GROUP BY M.TRFACCTNO
        order by trfacctno) indue,
     (select trfacctno, round(sum(PRINOVD + INTOVDACR + INTNMLOVD + INTPREPAID +
                                OPRINNML + OPRINOVD + OINTNMLACR + OINTOVDACR + OINTNMLOVD + OINTDUE + OINTPREPAID +
                                FEE + FEEDUE + FEEOVD + FEEINTOVDACR + FEEINTNMLOVD + FEEINTPREPAID)) OVAMT
        from lnmast
        where ftype = 'AF'
        group by trfacctno
        order by trfacctno) ov
    where replace (a.custodycd(+), '002K', '002C')  = cf.custodycd and cf.custid = af.custid 
    and af.actype = aft.actype and aft.mnemonic <> 'T3'  
    and aft.mrtype =mrt.actype and mrt.mrtype <> 'N'
    and af.acctno = ci.acctno and af.custid = cf1.custid
    and ci.acctno = b.afacctno (+) --and af.alternateacct='N' 
    and ci.acctno = indue.trfacctno (+)
    and ci.acctno = ov.trfacctno (+)
/
