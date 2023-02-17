SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE getmarginquantitybysymbol (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                                        f_symbol     VARCHAR) IS
  v_symbol VARCHAR2(20);
BEGIN
  v_symbol := f_symbol;
  OPEN PV_REFCURSOR FOR
    SELECT se.seqtty + nvl(od.seqtty, 0) SEQTTY
      FROM (SELECT sb.symbol, SUM(se.trade + se.receiving) seqtty
               FROM semast se, afmast af, aftype aft, mrtype mrt,
                    sbsecurities sb,
                    (SELECT ln.trfacctno,
                             SUM(ls.nml + ls.intnmlacr + ls.fee + ls.intdue +
                                  ls.feedue + ls.ovd + ls.intovd + ls.intovdprin +
                                  ls.feeovd) debt
                        FROM lnschd ls, lnmast ln
                       WHERE ln.acctno = ls.acctno
                       GROUP BY ln.trfacctno) ls, cimast ci
              WHERE se.afacctno = af.acctno
                AND af.actype = aft.actype
                AND aft.mrtype = mrt.actype
                AND mrt.mrtype IN ('S', 'T')
                AND se.codeid = sb.codeid
                AND sb.symbol = f_symbol
                AND ls.trfacctno = af.acctno
                AND af.acctno = ci.acctno
                AND (ls.debt - (ci.balance + ci.receiving)) > 0
              GROUP BY sb.symbol) se
      LEFT JOIN (SELECT sb.symbol,
                        SUM(CASE
                              WHEN od.exectype IN ('NS', 'MS') THEN
                               (case when od.ORSTATUS<>'2' then -execqtty else -execqtty-remainqtty end )
                              WHEN od.exectype IN ('NB', 'BC') THEN
                               remainqtty + execqtty
                              ELSE
                               0
                            END) seqtty
                   FROM odmast od, afmast af, aftype aft, mrtype mrt,
                        sbsecurities sb,
                        (SELECT ln.trfacctno,
                                 SUM(ls.nml + ls.intnmlacr + ls.fee +
                                      ls.intdue + ls.feedue + ls.ovd +
                                      ls.intovd + ls.intovdprin + ls.feeovd) debt
                            FROM lnschd ls, lnmast ln
                           WHERE ln.acctno = ls.acctno
                           GROUP BY ln.trfacctno) ls, cimast ci
                  WHERE od.afacctno = af.acctno
                    AND af.actype = aft.actype
                    AND od.txdate =
                        (SELECT to_date(VARVALUE, 'DD/MM/YYYY')
                           FROM sysvar
                          WHERE grname = 'SYSTEM'
                            AND varname = 'CURRDATE')
                    AND aft.mrtype = mrt.actype
                    AND mrt.mrtype IN ('S', 'T')
                    AND od.deltd <> 'Y'
                    AND od.codeid = sb.codeid
                    AND sb.symbol = f_symbol
                    AND ls.trfacctno = af.acctno
                    AND af.acctno = ci.acctno
                    AND (ls.debt - (ci.balance + ci.receiving)) > 0
                  GROUP BY sb.symbol) od
        ON se.symbol = od.symbol;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;

----
 
/
