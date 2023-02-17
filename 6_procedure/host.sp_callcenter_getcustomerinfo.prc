SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_callcenter_getcustomerinfo(
  pv_afacctno in varchar2,
  PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR) IS
  v_txdate       varchar2(10);
BEGIN
  select varvalue into v_txdate
  from sysvar
  where grname = 'SYSTEM' and varname = 'CURRDATE';

  open PV_REFCURSOR for
        select cf.custodycd, af.acctno, to_char(cf.fullname) fullname, to_char(cf.address) address, cf.phone, to_char(cf.idcode) idcode,cf.email,
                mst.*
        from cfmast cf, afmast af,
                    (select  od.afacctno, od.orderid, to_char(sb.symbol) symbol, to_char(ac1.cdcontent) exectype, od.txtime, to_char(ac2.cdcontent) ORSTATUS,
                             od.pricetype, od.orderqtty, od.quoteprice, od.remainqtty, od.execqtty, od.cancelqtty, od.adjustqtty
                     from odmast od, sbsecurities sb, allcode ac1, allcode ac2
                     where od.codeid = sb.codeid
                           and od.exectype = ac1.cdval and ac1.cdtype= 'OD' and ac1.cdname= 'EXECTYPE' and od.exectype in ('NB','NS','MS')
                           and od.orstatus = ac2.cdval and ac2.cdtype = 'OD' and ac2.cdname = 'ORSTATUS'
                           and od.txdate = to_date(v_txdate,'DD/MM/RRRR')
                           and od.afacctno = trim(pv_afacctno)
                     order by od.txtime) mst
        where cf.custid = af.custid and af.acctno = mst.afacctno(+)
              and af.acctno = trim(pv_afacctno);
EXCEPTION
WHEN OTHERS THEN
  null;
END;
 
/
