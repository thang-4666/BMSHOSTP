SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETDEALPAIDBYACCOUNT
(DEALPAIDAMT, AFACCTNO)
BEQUEATH DEFINER
AS 
(/*(  SELECT     greatest(round(SUM (to_number(nvl(sy.varvalue,0)) *
                            (  (df.remainqtty + df.rlsqtty - df.secured_match)
                                / (df.remainqtty + df.rlsqtty)
                                * df.amt
                                - df.rlsamt
                            )
                            * (1 + df.dealfeerate / 100)
                        )
                   )-fn_getoverdealpaidbyETS(afacctno),0)
  dealpaidamt, afacctno
 FROM   v_getdealinfo df, LNSCHD S, LNMAST M, SYSVAR SY
WHERE df.lnacctno = m.acctno
  and df.autopaid ='Y'
  and  df.remainqtty + df.rlsqtty>0
  AND m.acctno = s.acctno
  AND s.REFTYPE IN ('P')
  and sy.grname='SYSTEM' and sy.varname='HOSTATUS'
  AND ( S.OVERDUEDATE <= (select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
 OR df.prinovd + df.oprinovd > 0
 OR (df.basicprice <= df.triggerprice OR df.FLAGTRIGGER = 'T'))
GROUP BY   afacctno
)*/
select 0, 'XXXXXXXXXX' from dual
)
/
