SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI1179','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI1179', 'Tra cứu khách hàng cần ứng trước', 'Tra cứu khách hàng cần ứng trước', 'select max(br.brname) brname, CF.BRID,  sum(sts.MAXAVLAMT) MAXAVLAMT, sum(least(ci.buysecamt-ci.balance+v.secureamt, sts.MAXAVLAMT)) AMTADV,sum( ci.buysecamt-ci.balance+v.secureamt) ABALANCE
        FROM vw_advanceschedule sts, afmast af, cimast ci,
            cfmast cf, aftype aft, adtype ad, mrtype mrt,v_getbuyorderinfo v,BRGRP br
        where sts.acctno =af.acctno and af.custid=cf.custid
            and ci.afacctno=af.acctno and ci.balance-ci.buysecamt-v.secureamt<0
            and af.actype = aft.actype  and aft.adtype = ad.actype and aft.mrtype = mrt.actype
            and af.acctno = v.afacctno
            AND sts.isvsd <> ''Y''
            and br.brid = br.brid
            AND af.autoadv=''Y''
            group by CF.BRID
            UNION ALL
        select ''ALL'' brname, ''ALL'' BRID,  sum(sts.MAXAVLAMT) MAXAVLAMT, sum(least(ci.buysecamt-ci.balance+v.secureamt, sts.MAXAVLAMT)) AMTADV,sum( ci.buysecamt-ci.balance+v.secureamt) ABALANCE
        FROM vw_advanceschedule sts, afmast af, cimast ci,
            cfmast cf, aftype aft, adtype ad, mrtype mrt,v_getbuyorderinfo v,BRGRP br
        where sts.acctno =af.acctno and af.custid=cf.custid
            and ci.afacctno=af.acctno and ci.balance-ci.buysecamt-v.secureamt<0
            and af.actype = aft.actype  and aft.adtype = ad.actype and aft.mrtype = mrt.actype
            and af.acctno = v.afacctno
            AND sts.isvsd <> ''Y''
            and br.brid = br.brid
            AND af.autoadv=''Y''

            ', 'CFLINK', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;