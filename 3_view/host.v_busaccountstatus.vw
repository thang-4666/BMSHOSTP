SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_BUSACCOUNTSTATUS
(CUSTID, ACCTNO, TONGGIATRITAIKHOAN, SECMKTVAL, SOTIENDUOCRUT, 
 CASHAVL, TIENCHOVETAIKHOAN, TIENKYQUYDATMUA, TIENPHONGTOATRANOCAMCO, NO, 
 UNGTRUOCTIENBAN, UNGTRUOCTIENMUA, LAISUAT, CACKHOANPHAITRATHEM, REPOPAYABLE, 
 STOCKLENDING, NOMINEEACCOUNTPAYABLE)
BEQUEATH DEFINER
AS 
(SELECT MAX (mst.custid) custid,
            (mst.afacctno) acctno,
              NVL (mst.balance, 0)
            + MAX (NVL (sts.rsamt, 0))
            + MAX (NVL (sts.amt, 0))
            - MAX (NVL (sts.aamt, 0))
            + MAX (NVL (odb.remainsecured, 0))
            + MAX (NVL (ods.remainsecured, 0))
            + mst.mblock
            + mst.emkamt
            - mst.odamt
            + SUM (NVL (dtl.marketvalueofsecurities, 0))
                tonggiatritaikhoan,
            MAX (NVL (dtl.marketvalueofsecurities, 0)) + MAX (NVL (rsamt, 0)) secmktval,
            GREATEST (NVL (mst.balance, 0) - NVL (mst.odamt, 0) - MAX (NVL (adv.advamt, 0)), 0) sotienduocrut,
            NVL (mst.balance, 0) cashavl,
            MAX (NVL (sts.amt, 0)) tienchovetaikhoan,
            NVL (bamt, 0) tienkyquydatmua,
            NVL (mblock, 0) tienphongtoatranocamco,
            NVL (odamt, 0) no,
            MAX (NVL (sts.aamt, 0)) ungtruoctienban,
            MAX (NVL (adv.advamt, 0)) ungtruoctienmua,
            0 laisuat,
            0 cackhoanphaitrathem,
            0 repopayable,
            0 stocklending,
            0 nomineeaccountpayable
       FROM (SELECT af.custid,
                    af.acctno afacctno,
                    ci.balance,
                    ci.bamt,
                    ci.mblock,
                    ci.odamt,
                    ci.receiving,
                    ci.emkamt
               FROM afmast af, cimast ci
              WHERE af.acctno = ci.afacctno) mst
            LEFT JOIN (SELECT se.afacctno,
                              SUM (
                                  (  se.trade
                                   + se.deposit
                                   + se.withdraw
                                   + se.transfer
                                   + se.mortage
                                   + se.margin
                                   + se.blocked
                                   + se.pending)
                                  * (si.currprice))
                                  netaccountvalue,
                              SUM (
                                  (  se.trade
                                   + se.deposit
                                   + se.withdraw
                                   + se.transfer
                                   + se.mortage
                                   + se.margin
                                   + se.blocked
                                   + se.pending)
                                  * (si.currprice))
                                  marketvalueofsecurities
                         FROM semast se, sbsecurities sb, securities_info si
                        WHERE se.codeid = sb.codeid AND sb.symbol = TRIM (si.symbol)
                       GROUP BY se.afacctno) dtl
                ON mst.afacctno = dtl.afacctno
            LEFT JOIN (SELECT afacctno,
                              SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (amt, 0) ELSE 0 END) amt,
                              SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (aamt - paidamt, 0) ELSE 0 END) aamt,
                              SUM (CASE WHEN (st.duetype) = 'RS' THEN st.qtty * si.currprice ELSE 0 END) rsamt
                         FROM stschd st, securities_info si
                        WHERE st.codeid = si.codeid AND st.duetype IN ('RM', 'RS') AND st.status = 'N'
                       GROUP BY afacctno) sts
                ON mst.afacctno = sts.afacctno
            LEFT JOIN (SELECT afacctno,
                              NVL (
                                  SUM (
                                      CASE
                                          WHEN exectype IN ('NS', 'SS', 'MS') THEN remainqtty * si.currprice
                                          ELSE 0
                                      END),
                                  0)
                                  remainsecured
                         FROM odmast, securities_info si
                        WHERE odmast.codeid = si.codeid
                       GROUP BY afacctno) ods
                ON mst.afacctno = ods.afacctno
            LEFT JOIN (SELECT afacctno,
                              NVL (
                                  SUM (
                                      CASE
                                          WHEN exectype IN ('NB', 'BC') THEN quoteprice * remainqtty * bratio / 100
                                          ELSE 0
                                      END),
                                  0)
                                  remainsecured
                         FROM odmast
                       GROUP BY afacctno) odb
                ON mst.afacctno = odb.afacctno
            LEFT JOIN (SELECT afacctno,
                              SUM (
                                    quoteprice * remainqtty * (1 + typ.deffeerate / 100)
                                  + execamt
                                  + rlssecured
                                  - securedamt)
                                  overamt,
                              (CASE
                                   WHEN SUM (
                                              quoteprice * remainqtty * (1 + typ.deffeerate / 100)
                                            + execamt
                                            + rlssecured
                                            - securedamt)
                                        - MAX (af.advanceline) > 0
                                   THEN
                                       SUM (
                                             quoteprice * remainqtty * (1 + typ.deffeerate / 100)
                                           + execamt
                                           + rlssecured
                                           - securedamt)
                                       - MAX (af.advanceline)
                                   ELSE
                                       0
                               END)
                                  advamt
                         FROM odmast od, afmast af, odtype typ
                        WHERE     od.actype = typ.actype
                              AND af.acctno = od.afacctno
                              AND od.txdate = TRUNC (SYSDATE)
                              AND deltd <> 'Y'
                              AND od.exectype IN ('NB', 'BC')
                       GROUP BY afacctno) adv
                ON mst.afacctno = adv.afacctno
     GROUP BY mst.afacctno,
              mst.balance,
              mst.odamt,
              mst.bamt,
              mst.mblock,
              mst.emkamt,
              mst.receiving)
/
