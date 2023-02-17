SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0113 (
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
    v_TXNUM varchar2(12);
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

    v_TXNUM:= SUBSTR2(trim(PV_TXCODE),1,10);

    begin
        v_TXDATE := TO_DATE(SUBSTR2(trim(PV_TXCODE),11),'RRRRMMDD');
        exception
       when others
       then
            v_TXDATE := getcurrdate + 1;
    end;


OPEN PV_REFCURSOR
FOR
    select tl.txdate, tl.txnum, cf.custodycd, af.acctno afacctno, cf.fullname, cf.idcode licenseno, cf.iddate lniddate, cf.idplace lnidplace,
        cf.address, cf.mobilesms mobile, a1.cdcontent country, cf.dateofbirth,
        tf.qtty, tf.price, tf.qtty*tf.price amount, 0 rate --, round(decode(iss.sharecapital,0,0,tf.maxqtty*parvalue*100/iss.sharecapital),4) rate
    from vw_tllog_all tl, (
            select tf.txdate, tf.txnum, max(decode(fldcd,'13',cvalue,0)) recafacctno, max(DECODE(tf.fldcd,'12',tf.nvalue,0)) qtty, max(DECODE(tf.fldcd,'11',tf.nvalue,0)) price
            from vw_tllogfld_all tf
            where tf.txdate = v_TXDATE
                and tf.txnum = v_TXNUM
                and tf.fldcd in ('12','11','13')
            GROUP by tf.txdate, tf.txnum
        ) tf, (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf, afmast af, allcode a1, sbsecurities sb, issuers iss
    where tl.txdate = tf.txdate
        and tl.txnum= tf.txnum
        and tl.tltxcd = '2229'
        --and SUBSTR(tl.msgacct,1,10) = af.acctno
        and tf.recafacctno= af.acctno
        and af.custid = cf.custid
        and cf.country = a1.cdval and A1.CDTYPE = 'CF' AND A1.CDNAME = 'COUNTRY'
        and cf.custtype = 'I'
        and tl.ccyusage = sb.codeid
        and sb.issuerid = iss.issuerid
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
