SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_PAR_GETPHATVAYT3_ALTERNATE
(CUSTODYCD, ACCTNO, DAYCREDIT, BALANCE, HOLDBALANCE, 
 ODAMT, DUEAMT, OVAMT, SECUREAMT, PHATVAYFSS, 
 PHATVAY_SBS, PHATVAYFSS1, LECH_PHATVAY_FSS_SBS)
BEQUEATH DEFINER
AS 
select a.custodycd,af.acctno, a.daycredit, ci.balance,ci.holdbalance,
        ci.odamt,nvl(indue.nml,0) dueamt, nvl(ov.ovamt,0) ovamt, NVL (b.secureamt, 0) secureamt,
    greatest(-(ci.balance - least(ci.balance,ci.odamt) - secureamt),0) PhatvayFSS,a.currentdebit Phatvay_SBS,
    -balance +  NVL (b.secureamt, 0) PhatvayFSS1,
    greatest(-(ci.balance - least(ci.balance,ci.odamt) - secureamt),0) - a.currentdebit Lech_Phatvay_FSS_SBS
    from (select distinct t3.* from ss_phatvayt3 t3) a, cfmast cf, afmast af, aftype aft , cimast ci,
    (SELECT afacctno, sum(execamt+ feeacr) secureamt  FROM odmast od where txdate = getcurrdate 
        AND deltd <> 'Y'
        AND od.exectype IN ('NB', 'BC')
        and od.stsstatus <> 'C' group by afacctno) b,
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
    where a.custodycd = cf.custodycd and cf.custid = af.custid 
    and af.actype = aft.actype and aft.mnemonic ='T3' and af.acctno = ci.acctno   
    and ci.acctno = b.afacctno (+) and af.alternateacct='Y' 
    and ci.acctno = indue.trfacctno (+)
    and ci.acctno = ov.trfacctno (+)
/
