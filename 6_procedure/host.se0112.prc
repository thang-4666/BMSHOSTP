SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0112 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_AFACCTNO             IN       VARCHAR2,
   PV_TXCODE                IN       VARCHAR2,
   PV_TLID        IN       VARCHAR2
)
IS
    v_CUSTODYCD VARCHAR2(15);
    v_AFACCTNO VARCHAR2(15);
    v_TXDATE date;
    v_TXNUM varchar2(10);
BEGIN


    IF (PV_CUSTODYCD IS NULL OR UPPER(PV_CUSTODYCD) = 'ALL')
    THEN
        v_CUSTODYCD := '%';
    ELSE
        v_CUSTODYCD := upper(PV_CUSTODYCD);
    END IF;

    IF (PV_AFACCTNO IS NULL OR UPPER(PV_AFACCTNO) = 'ALL')
    THEN
        v_AFACCTNO := '%';
    ELSE
        v_AFACCTNO := upper(PV_AFACCTNO);
    END IF;

    v_TXNUM:= SUBSTR2(PV_TXCODE,1,10);

    begin
        v_TXDATE := TO_DATE(SUBSTR2(PV_TXCODE,11),'RRRRMMDD');
        exception
       when others
       then
            v_TXDATE := getcurrdate + 1;
    end;


OPEN PV_REFCURSOR
FOR
    select tl.txdate, tl.txnum, cf.custodycd, af.acctno afacctno, cf.fullname, cf.idcode licenseno, cf.address, cf.mobilesms mobile, cf.fax, cf.iddate, cf.idplace,
        nvl(cr.recustid, '') recustid, nvl(cr.retype, '') retype, nvl(cr.refullname, '') refullname, nvl(cr.readdress, '') readdress,
        nvl(cr.relicenseno, '') relicenseno, nvl(cr.relniddate, null) relniddate, nvl(cr.relnidplace, '') relnidplace, nvl(cr.recountry, '') recountry,
        tf.qtty, tf.price, tf.qtty*tf.price amount, round(decode(se.listingqtty,0,0,tf.qtty/se.listingqtty*100),4) rate
    from vw_tllog_all tl, (
            select tf.txdate, tf.txnum, max(decode(fldcd,'13',cvalue,0)) recafacctno, max(DECODE(tf.fldcd,'12',tf.nvalue,0)) qtty, max(DECODE(tf.fldcd,'11',tf.nvalue,0)) price
            from vw_tllogfld_all tf
            where tf.txdate = v_TXDATE
                and tf.txnum = v_TXNUM
                and tf.fldcd in ('12','11','13')
            GROUP by tf.txdate, tf.txnum
        ) tf, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf, afmast af,
        (
            select trim(cr.custid) custid, trim(cf.custid) recustid, a1.cdcontent retype, cr.fullname refullname, cr.address readdress, cr.licenseno relicenseno,
                cr.lniddate relniddate, cr.lnplace relnidplace, a2.cdcontent recountry
            from (
                select custid, max(autoid) autoid
                from CFRELATION cr
                where actives = 'Y'
                group by custid
            )mx, CFRELATION cr, allcode a1, CFMAST cf, allcode a2
            where mx.autoid = cr.autoid
                and trim(cr.recustid) = cf.custid
                and cr.retype = a1.cdval and A1.CDTYPE = 'CF' AND A1.CDNAME = 'RETYPE'
                and cf.country = a2.cdval and A2.CDTYPE = 'CF' AND A2.CDNAME = 'COUNTRY'
        )cr, sbsecurities sb, issuers iss, securities_info se
    where tl.txdate = tf.txdate
        and tl.txnum= tf.txnum
        and tl.tltxcd = '2229'
        --and SUBSTR(tl.msgacct,1,10) = af.acctno
        and tf.recafacctno= af.acctno
        and af.custid = cf.custid
        and cf.custid = cr.custid(+)
        and cf.custtype = 'B'
        and tl.ccyusage = sb.codeid
        and sb.issuerid = iss.issuerid
        and sb.codeid = se.codeid
        and tl.txdate = v_TXDATE
        and tl.txnum=v_TXNUM
        and cf.custodycd like v_CUSTODYCD
        and af.acctno like v_AFACCTNO
        ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
/
