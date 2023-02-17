SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0096(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                   OPT          IN VARCHAR2,
                                   pv_BRID      IN VARCHAR2,
                                   TLGOUPS      IN VARCHAR2,
                                   TLSCOPE      IN VARCHAR2,
                                   F_DATE       IN VARCHAR2,
                                   T_DATE       IN VARCHAR2,
                                   TLTXCD       IN VARCHAR2) IS
  --
  -- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
  -- TONG HOP KET QUA KHOP LENH
  -- MODIFICATION HISTORY
  -- PERSON      DATE    COMMENTS
  -- NAMNT   21-NOV-06  CREATED
  -- ---------   ------  -------------------------------------------

  V_STROPTION    VARCHAR2(5);
  V_STRCUSTODYCD VARCHAR2(20);
  V_I_BRID       VARCHAR2(20);
  V_TLTXCD       VARCHAR2(20);
  V_STRMARGIN    VARCHAR2(20);
  V_STRBRID      VARCHAR2(4);
  l_FromDate     date;
  l_ToDate       date;

  CUR PKG_REPORT.REF_CURSOR;

  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  V_STROPTION := OPT;
  IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL') THEN
    V_STRBRID := pv_BRID;
  ELSE
    V_STRBRID := '%%';
  END IF;
  IF (TLTXCD <> 'ALL') THEN
    V_TLTXCD := TLTXCD;
  ELSE
    V_TLTXCD := '%%';
  END IF;
  l_FromDate := to_date(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  l_ToDate   := to_date(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);

  OPEN PV_REFCURSOR for   
       select cf.fullname,
           tg.msgacct acctno,
           tg.txdesc,
           b.blacctno accountboomber,
           null traderid,
           tg.txdate,
           cf.custodycd,
           t1.tlfullname     usertao,
           t2.tlfullname     userduyet
      from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS) = 0) cf,
           (select tg.autoid, tg.tlid, tg.offid,tg.tltxcd,tg.cfcustodycd,tg.txdate,tg.txdesc,tg.msgacct,tg.txnum
              from VW_TLLOG_ALL tg
              where tg.TXSTATUS = '1'
               and tg.txdate between l_FromDate and l_ToDate
               and tg.tltxcd in ('0041')) tg,
           tlprofiles t1,
           tlprofiles t2,
             bl_register b
     where cf.custodycd = tg.cfcustodycd
       and t1.tlid = tg.tlid
       and t2.tlid = tg.offid
       and tg.TXNUM = b.txnum(+)
       and tg.TXDATE = b.txdate(+)
       and b.status = 'A'
       and tg.tltxcd like V_TLTXCD 
       union all 
        select cf.fullname,
           tg.msgacct acctno,
           tg.txdesc,
           b.blacctno accountboomber,
           null traderid,
           tg.txdate,
           cf.custodycd,
           t1.tlfullname     usertao,
           t2.tlfullname     userduyet
      from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS) = 0) cf,
           (select tg.autoid, tg.tlid, tg.offid,tg.tltxcd,tg.cfcustodycd,tg.txdate,tg.txdesc,tg.msgacct
              from VW_TLLOG_ALL tg
              where tg.TXSTATUS = '1'
               and tg.txdate between l_FromDate and l_ToDate
               and tg.tltxcd in ('0042')) tg,
           tlprofiles t1,
           tlprofiles t2,
             bl_register b
     where cf.custodycd = tg.cfcustodycd
       and t1.tlid = tg.tlid
       and t2.tlid = tg.offid
       and tg.msgacct = b.afacctno(+)
       and tg.TXDATE = b.Clsdate(+)
       and b.status = 'C'
       and tg.tltxcd like V_TLTXCD 
         union all 
        select cf.fullname,
           tg.msgacct acctno,
           tg.txdesc,
         F.blacctno accountboomber,
           f.traderid,
           tg.txdate,
           cf.custodycd,
           t1.tlfullname     usertao,
           t2.tlfullname     userduyet
      from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS) = 0) cf,
           (select tg.autoid, tg.tlid, tg.offid,tg.tltxcd,tg.cfcustodycd,tg.txdate,tg.txdesc,tg.msgacct,TG.TXNUM
              from VW_TLLOG_ALL tg
              where tg.TXSTATUS = '1'
               and tg.txdate between l_FromDate and l_ToDate
               and tg.tltxcd in ('0047')) tg,
           tlprofiles t1,
           tlprofiles t2,
             bl_traderef f 
     where cf.custodycd = tg.cfcustodycd
       and t1.tlid = tg.tlid
       and t2.tlid = tg.offid
       and f.status = 'A'
       and tg.TXNUM = f.TXNUM
       and tg.TXDATE =  f.TXDATE
       and tg.tltxcd like V_TLTXCD
         union all 
        select cf.fullname,
           tg.msgacct acctno,
           tg.txdesc,
         F.blacctno accountboomber,
           f.traderid,
           tg.txdate,
           cf.custodycd,
           t1.tlfullname     usertao,
           t2.tlfullname     userduyet
      from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS) = 0) cf,
           (select tg.autoid, tg.tlid, tg.offid,tg.tltxcd,tg.cfcustodycd,tg.txdate,tg.txdesc,tg.msgacct
              from VW_TLLOG_ALL tg
              where tg.TXSTATUS = '1'
               and tg.txdate between l_FromDate and l_ToDate
               and tg.tltxcd in ('0048')) tg,
           tlprofiles t1,
           tlprofiles t2,
             bl_traderef f 
     where cf.custodycd = tg.cfcustodycd
       and t1.tlid = tg.tlid
       and t2.tlid = tg.offid
       and f.status = 'C'
       and tg.msgacct = f.afacctno(+)
       and tg.TXDATE =  f.Clsdate(+)
       and tg.tltxcd like V_TLTXCD;

     EXCEPTION WHEN OTHERS THEN RETURN;
END; -- PROCEDURE
 
 
 
 
/
