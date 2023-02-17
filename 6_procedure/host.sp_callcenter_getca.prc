SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_callcenter_getca(
  pv_afacctno in varchar2,
  PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR) IS
  v_afacctno     varchar2(10);
BEGIN
  if pv_afacctno = 'ALL' then
     v_afacctno := '%';
  else
     v_afacctno := pv_afacctno;
  end if;
  
  open PV_REFCURSOR for
        --reportdate: Ngay DK cuoi cung, actiondate: Ngay thuc hien, duedate: Ngay DKQM CC, frdatetransfer: Ngay bat dau DKQM
        select to_char(cf.fullname) fullname, cf.custodycd, af.acctno, sb.symbol, cf.phone,cf.email, to_char(ac2.cdcontent) eventcoop, to_char(ac1.cdcontent) castatus,
               cm.description, ca.balance seqtty, ca.qtty coopqtty, ca.amt, ca.pqtty, ca.paamt, 
               cm.reportdate, cm.actiondate, cm.duedate, cm.frdatetransfer
        from caschd ca, camast cm, cfmast cf, afmast af, sbsecurities sb,
             allcode ac1, allcode ac2
        where ca.camastid = cm.camastid
              and ca.afacctno = af.acctno and af.custid = cf.custid
              and ca.codeid = sb.codeid
              and ca.status not in ('C')
              and ca.status = ac1.cdval and ac1.cdtype = 'CA' and ac1.cdname = 'CASTATUS'
              and cm.catype = ac2.cdval and ac2.cdtype = 'CA' and ac2.cdname = 'CATYPE'
              and ca.afacctno like v_afacctno
        order by cm.actiondate, cm.frdatetransfer, cm.duedate;              
EXCEPTION
WHEN OTHERS THEN
  null;
END;
 
/
