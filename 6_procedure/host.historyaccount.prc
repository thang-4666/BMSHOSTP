SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "HISTORYACCOUNT" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                           TABLENAME    IN VARCHAR2,
                                           ACCTNO       IN VARCHAR2,
                                           FRDATE       in varchar2,
                                           TODATE       in varchar2,
                                           FPAGENUMBER  in NUMBER,
                                           TPAGENUMBER  in NUMBER,
                                           AFACCTNO     IN VARCHAR2, -- option
                                           CASEBY       IN VARCHAR2, -- option
                                           CODEID       IN VARCHAR2 -- option
                                           ) IS

  V_TABLENAME   VARCHAR2(30);
  V_AFACCTNO    VARCHAR2(30);
  V_ACCTNO      VARCHAR2(30);
  V_CASEBY      VARCHAR2(30);
  V_CODEID      VARCHAR2(30);
  V_SESEARCH    VARCHAR2(30);
  v_FRDATE      date;
  v_TODATE      date;
  v_FPAGENUMBER NUMBER;
  v_TPAGENUMBER NUMBER;

  -- AUTHOER : TRUONGLD
  -- DATE : 11/04/2010
  -- PURPOSE : LAY DANH SACH GD DICH TU NGAY ... DEN NGAY ....

BEGIN

  V_TABLENAME   := TABLENAME;
  V_AFACCTNO    := AFACCTNO;
  V_ACCTNO      := ACCTNO;
  V_CASEBY      := CASEBY;
  V_CODEID      := CODEID;
  v_FRDATE      := to_date(FRDATE, 'DD/MM/RRRR');
  v_TODATE      := to_date(TODATE, 'DD/MM/RRRR');
  v_FPAGENUMBER := FPAGENUMBER;
  v_TPAGENUMBER := TPAGENUMBER;

  --Khi chon tat ca chung khoan
  IF V_TABLENAME = 'SE.SEMAST' and V_CODEID = '0000' THEN
    V_SESEARCH := V_AFACCTNO || '%';
  ELSE
    V_SESEARCH := V_ACCTNO;
  END IF;

  if V_TABLENAME = 'CI.CIMAST' THEN
    OPEN PV_REFCURSOR FOR
      SELECT T2.*
        FROM (SELECT T1.*, ROWNUM RN
                FROM (SELECT LOGDATA.*
                        FROM (SELECT LF.TXDATE,
                                     LF.TXNUM,
                                     LF.BUSDATE,
                                     LF.TLTXCD,
                                     LF.TXDESC,
                                     (CASE
                                       WHEN SUBSTR(LF.TLTXCD, 1, 2) = '33' THEN
                                        TRF.NAMT
                                       WHEN SUBSTR(LF.TLTXCD, 1, 2) = '26' THEN
                                        TRF.NAMT
                                       ELSE
                                        LF.MSGAMT
                                     END) AMT,
                                     TX.TXDESC TLTXDESC,
                                     TX.EN_TXDESC TLTXEN_DESC,
                                     LF.DELTD ,
                                     TLP.TLNAME MAKER,
                                     TLP1.TLNAME CHECKER
                                FROM (SELECT TO_CHAR(TXDATE, 'DD/MM/RRRR') ||
                                             TXNUM VOUCHERCD,
                                             MAX(NAMT) NAMT
                                        FROM CITRAN
                                       WHERE ACCTNO = V_ACCTNO
                                         AND TXDATE >= v_FRDATE
                                         AND TXDATE <= v_TODATE
                                       GROUP BY TXDATE, TXNUM) TRF,
                                     TLLOG LF,
                                     TLTX TX,
                                     TLPROFILES TLP,
                                     TLPROFILES TLP1
                                 WHERE TRF.VOUCHERCD =
                                     TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                                 AND DELTD <> 'Y'
                                 AND LF.TLTXCD = TX.TLTXCD
                                 AND  LF.TLID =TLP.TLID (+)
                                 AND  LF.OFFID=TLP1.TLID (+)
                              UNION ALL
                              SELECT LF.TXDATE,
                                     LF.TXNUM,
                                     LF.BUSDATE,
                                     LF.TLTXCD,
                                     LF.TXDESC,
                                     (CASE
                                       WHEN SUBSTR(LF.TLTXCD, 1, 2) = '33' THEN
                                        TRF.NAMT
                                       WHEN SUBSTR(LF.TLTXCD, 1, 2) = '26' THEN
                                        TRF.NAMT
                                       ELSE
                                        LF.MSGAMT
                                     END) AMT,
                                     TX.TXDESC TLTXDESC,
                                     TX.EN_TXDESC TLTXEN_DESC,
                                     LF.DELTD,
                                     TLP.TLNAME MAKER,
                                     TLP1.TLNAME CHECKER
                                FROM (SELECT TO_CHAR(TXDATE, 'DD/MM/RRRR') ||
                                             TXNUM VOUCHERCD,
                                             TXDATE,
                                             TXNUM,
                                             MAX(NAMT) NAMT
                                        FROM CITRANA
                                       WHERE ACCTNO = V_ACCTNO
                                         AND TXDATE >= v_FRDATE
                                         AND TXDATE <= v_TODATE
                                       GROUP BY TXDATE, TXNUM) TRF,
                                     TLLOGALL LF,
                                     TLTX TX,
                                     TLPROFILES TLP,
                                     TLPROFILES TLP1
                               WHERE TRF.TXNUM = LF.TXNUM
                                 AND TRF.TXDATE = LF.TXDATE
                                 AND DELTD <> 'Y'
                                 AND LF.TLTXCD = TX.TLTXCD
                                 AND  LF.TLID =TLP.TLID (+)
                                 AND  LF.OFFID=TLP1.TLID (+)) LOGDATA
                       ORDER BY TXDATE, TXNUM) T1) T2
       WHERE RN BETWEEN v_FPAGENUMBER AND v_TPAGENUMBER
       ORDER BY TXDATE, TXNUM;

  ELSIF V_TABLENAME = 'SE.SEMAST' THEN
    OPEN PV_REFCURSOR FOR
      SELECT *
        FROM (SELECT LOGDATA.*, ROWNUM RN
                FROM (SELECT LF.TXDATE,
                             LF.TXNUM,
                             LF.BUSDATE,
                             LF.TLTXCD,
                             LF.TXDESC,
                             (CASE
                               WHEN SUBSTR(LF.TLTXCD, 1, 2) = '33' THEN
                                TRF.NAMT
                               ELSE
                                LF.MSGAMT
                             END) AMT,
                             TX.TXDESC TLTXDESC,
                             TX.EN_TXDESC TLTXEN_DESC,
                             LF.DELTD,
                             SEINFO.SYMBOL  ,
                             TLP.TLNAME MAKER,
                             TLP1.TLNAME CHECKER
                        FROM (SELECT TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM VOUCHERCD,
                                     MAX(NAMT) NAMT,
                                     SUBSTR(ACCTNO, 11, 6) CODEID
                                FROM SETRAN
                               WHERE TRIM(ACCTNO) LIKE V_SESEARCH
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE
                               GROUP BY TXDATE, TXNUM, SUBSTR(ACCTNO, 11, 6)) TRF,
                             TLLOG LF,
                             TLTX TX,
                             TLPROFILES TLP,
                             TLPROFILES TLP1,
                             SECURITIES_INFO SEINFO
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(LF.TXDATE, 'DD/MM/RRRR') || LF.TXNUM
                         AND LF.DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD
                         AND TRF.CODEID = SEINFO.CODEID
                         AND  LF.TLID =TLP.TLID (+)
                         AND  LF.OFFID=TLP1.TLID (+)
                      UNION ALL
                      SELECT LF.TXDATE,
                             LF.TXNUM,
                             LF.BUSDATE,
                             LF.TLTXCD,
                             LF.TXDESC,
                             (CASE
                               WHEN SUBSTR(LF.TLTXCD, 1, 2) = '33' THEN
                                TRF.NAMT
                               ELSE
                                LF.MSGAMT
                             END) AMT,
                             TX.TXDESC TLTXDESC,
                             TX.EN_TXDESC TLTXEN_DESC,
                             LF.DELTD,
                             SEINFO.SYMBOL ,
                             TLP.TLNAME MAKER,
                             TLP1.TLNAME CHECKER
                        FROM (SELECT TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM VOUCHERCD,
                                     MAX(NAMT) NAMT,
                                     SUBSTR(ACCTNO, 11, 6) CODEID
                                FROM SETRANA
                               WHERE TRIM(ACCTNO) LIKE V_SESEARCH
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE
                               GROUP BY TXDATE, TXNUM, SUBSTR(ACCTNO, 11, 6)) TRF,
                             TLLOGALL LF,
                             TLTX TX,
                             TLPROFILES TLP,
                             TLPROFILES TLP1,
                             SECURITIES_INFO SEINFO
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(LF.TXDATE, 'DD/MM/RRRR') || LF.TXNUM
                         AND LF.DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD
                         AND TRF.CODEID = SEINFO.CODEID
                         AND  LF.TLID =TLP.TLID (+)
                         AND  LF.OFFID=TLP1.TLID (+)) LOGDATA
               ORDER BY TXDATE, TXNUM) T1
       WHERE RN BETWEEN v_FPAGENUMBER AND v_TPAGENUMBER
       ORDER BY TXDATE, TXNUM;
  ELSIF V_TABLENAME = 'GL.GLMAST' THEN
    OPEN PV_REFCURSOR FOR
      SELECT *
        FROM (SELECT LOGDATA.*, ROWNUM RN
                FROM (SELECT DISTINCT LF.TXDATE,
                                      LF.BUSDATE,
                                      LF.TXNUM,
                                      LF.TLTXCD,
                                      LF.TXDESC,
                                      TRF.AMT,
                                      TX.TXDESC TLTXDESC,
                                      TX.EN_TXDESC TLTXEN_DESC,
                                      LF.DELTD
                        FROM (SELECT TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM VOUCHERCD,
                                     AMT
                                FROM GLTRAN
                               WHERE ACCTNO = V_ACCTNO
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE) TRF,
                             TLLOG LF,
                             TLTX TX
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                         AND DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD
                      UNION ALL
                      SELECT DISTINCT LF.TXDATE,
                                      LF.BUSDATE,
                                      LF.TXNUM,
                                      LF.TLTXCD,
                                      LF.TXDESC,
                                      TRF.AMT,
                                      TX.TXDESC TLTXDESC,
                                      TX.EN_TXDESC TLTXEN_DESC,
                                      LF.DELTD
                        FROM (SELECT TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM VOUCHERCD,
                                     AMT
                                FROM GLTRANA
                               WHERE ACCTNO = V_ACCTNO
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE) TRF,
                             TLLOGALL LF,
                             TLTX TX
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                         AND DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD) LOGDATA
               ORDER BY TXDATE, TXNUM) T1
       WHERE RN BETWEEN v_FPAGENUMBER AND v_TPAGENUMBER
       ORDER BY TXDATE, TXNUM;

  ELSIF V_TABLENAME = 'CF.CFMAST' THEN
    OPEN PV_REFCURSOR FOR
      SELECT *
        FROM (SELECT LOGDATA.*, ROWNUM RN
                FROM (SELECT LF.TXDATE,
                             LF.TXNUM,
                             LF.BUSDATE,
                             LF.TLTXCD,
                             LF.TXDESC,
                             LF.MSGAMT AMT,
                             TX.TXDESC TLTXDESC,
                             TX.EN_TXDESC TLTXEN_DESC,
                             LF.DELTD
                        FROM (SELECT DISTINCT TO_CHAR(TXDATE, 'DD/MM/RRRR') ||
                                              TXNUM VOUCHERCD
                                FROM AFTRAN
                               WHERE ACCTNO IN
                                     (SELECT ACCTNO
                                        FROM afmast
                                       WHERE ACCTNO = V_ACCTNO
                                      UNION ALL
                                      SELECT CF.CUSTID
                                        FROM cfmast CF, afmast AF
                                       WHERE CF.CUSTID = AF.CUSTID
                                         AND AF.ACCTNO = V_ACCTNO)
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE) TRF,
                             TLLOG LF,
                             TLTX TX
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                         AND DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD
                      UNION ALL
                      SELECT LF.TXDATE,
                             LF.TXNUM,
                             LF.BUSDATE,
                             LF.TLTXCD,
                             LF.TXDESC,
                             LF.MSGAMT AMT,
                             TX.TXDESC TLTXDESC,
                             TX.EN_TXDESC TLTXEN_DESC,
                             LF.DELTD
                        FROM (SELECT DISTINCT TO_CHAR(TXDATE, 'DD/MM/RRRR') ||
                                              TXNUM VOUCHERCD
                                FROM AFTRANA
                               WHERE ACCTNO IN
                                     (SELECT ACCTNO
                                        FROM afmast
                                       WHERE ACCTNO = V_ACCTNO
                                      UNION ALL
                                      SELECT CF.CUSTID
                                        FROM cfmast CF, afmast AF
                                       WHERE CF.CUSTID = AF.CUSTID
                                         AND AF.ACCTNO = V_ACCTNO)
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE) TRF,
                             TLLOGALL LF,
                             TLTX TX
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                         AND DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD) LOGDATA
               ORDER BY TXDATE, TXNUM) T1
       WHERE RN BETWEEN v_FPAGENUMBER AND v_TPAGENUMBER
       ORDER BY TXDATE, TXNUM;

  ELSIF V_TABLENAME = 'FO.FOMAST' THEN
    OPEN PV_REFCURSOR FOR
      SELECT *
        FROM (SELECT LOGDATA.*, ROWNUM RN
                FROM (SELECT LF.TXDATE,
                             LF.TXNUM,
                             LF.BUSDATE,
                             LF.TLTXCD,
                             LF.TXDESC,
                             LF.MSGAMT AMT,
                             TX.TXDESC TLTXDESC,
                             TX.EN_TXDESC TLTXEN_DESC,
                             LF.DELTD
                        FROM (SELECT DISTINCT TO_CHAR(TXDATE, 'DD/MM/RRRR') ||
                                              TXNUM VOUCHERCD
                                FROM FOTRAN
                               WHERE TRIM(ACCTNO) = V_ACCTNO
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE) TRF,
                             TLLOG LF,
                             TLTX TX
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                         AND DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD
                      UNION ALL
                      SELECT LF.TXDATE,
                             LF.TXNUM,
                             LF.BUSDATE,
                             LF.TLTXCD,
                             LF.TXDESC,
                             LF.MSGAMT AMT,
                             TX.TXDESC TLTXDESC,
                             TX.EN_TXDESC TLTXEN_DESC,
                             LF.DELTD
                        FROM (SELECT DISTINCT TO_CHAR(TXDATE, 'DD/MM/RRRR') ||
                                              TXNUM VOUCHERCD
                                FROM FOTRANA
                               WHERE TRIM(ACCTNO) = V_ACCTNO
                                 AND TXDATE >= v_FRDATE
                                 AND TXDATE <= v_TODATE) TRF,
                             TLLOGALL LF,
                             TLTX TX
                       WHERE TRF.VOUCHERCD =
                             TO_CHAR(TXDATE, 'DD/MM/RRRR') || TXNUM
                         AND DELTD <> 'Y'
                         AND LF.TLTXCD = TX.TLTXCD) LOGDATA
               ORDER BY TXDATE, TXNUM) T1
       WHERE RN BETWEEN v_FPAGENUMBER AND v_TPAGENUMBER;

  end if;
EXCEPTION
  WHEN others THEN
    return;
END;

 
 
 
 
/
