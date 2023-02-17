SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_getinventory (
          PV_REFCURSOR  IN OUT PKG_REPORT.REF_CURSOR,
          CLAUSE        IN VARCHAR2,
          BRID          IN VARCHAR2,
          SSYSVAR       IN VARCHAR2,
          RefLength     IN NUMBER,
          REFERENCE     IN VARCHAR2

       )
IS
          V_CLAUSE          VARCHAR2(100);
          V_BRID            VARCHAR2(100);
          V_SSYSVAR         VARCHAR2(100);
          V_iRefLength      NUMBER(20);
          V_REFERENCE       VARCHAR2(100);
          v_startnumtemp  number;
          v_endnumtemp    number;

          v_prefix          varchar2(4);
          v_AUTOINV         varchar2(6);
          v_AUTOINVTEMP     varchar2(6);
          v_startnum    number;
          v_endnum      number;
          pkgctx   plog.log_ctx;
          logrow   tlogdebug%ROWTYPE;
BEGIN
          V_CLAUSE          := UPPER(CLAUSE);
          V_BRID            := UPPER(BRID);
          V_SSYSVAR         := SSYSVAR;
          V_iRefLength      := RefLength;
          V_REFERENCE       := REFERENCE;



          IF (V_CLAUSE = 'CUSTID') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT,1,4), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= V_BRID ORDER BY CUSTID) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT,1,4);
          ELSIF (V_CLAUSE IN ('CFTYPE','RETAX','RERFEEID','REACTYPE','CITYPE', 'ODTYPE', 'SETYPE', 'AFTYPE', 'RPTYPE', 'FOTYPE', 'CLTYPE', 'LNTYPE',
                        'DFTYPE','TDTYPE','ADTYPE','DDTYPE', 'MRTYPE', 'MTTYPE','PRTYPE','IRRATE','FEECD')) THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT NVL(MAX(ODR)+1,1) AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT * FROM (SELECT actype INVACCT FROM CITYPE WHERE V_CLAUSE = 'CITYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM ODTYPE WHERE V_CLAUSE = 'ODTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM SETYPE WHERE V_CLAUSE = 'SETYPE'
                        UNION ALL
                        SELECT TO_CHAR(actype) INVACCT FROM AFTYPE WHERE V_CLAUSE = 'AFTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM FOTYPE WHERE V_CLAUSE = 'FOTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM CLTYPE WHERE V_CLAUSE = 'CLTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM LNTYPE WHERE V_CLAUSE = 'LNTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM MRTYPE WHERE V_CLAUSE = 'MRTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM DFTYPE WHERE V_CLAUSE = 'DFTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM TDTYPE WHERE V_CLAUSE = 'TDTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM ADTYPE WHERE V_CLAUSE = 'ADTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM PRTYPE WHERE V_CLAUSE = 'PRTYPE'
                        UNION ALL
                        SELECT actype INVACCT FROM RETYPE WHERE V_CLAUSE = 'REACTYPE'
                        Union all
                        SELECT RERFID INVACCT FROM RERFEE WHERE V_CLAUSE = 'RERFEEID'
                         Union all
                        SELECT ACTYPE INVACCT FROM RETAX WHERE V_CLAUSE = 'RETAX'
                         UNION ALL
                         SELECT rateid INVACCT FROM IRRATE WHERE V_CLAUSE = 'IRRATE'
                         UNION ALL
                        SELECT actype INVACCT FROM CFTYPE WHERE V_CLAUSE = 'CFTYPE'
                         UNION ALL
                        SELECT LPAD(FEECD,4,'0') INVACCT FROM FEEMASTER WHERE V_CLAUSE = 'FEECD'
                        ) ORDER BY INVACCT) DAT
                  WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;
          ELSIF (V_CLAUSE = 'CUSTODYCD') THEN
             /*OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT,1,4), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT CUSTODYCD INVACCT FROM CFMAST
                  WHERE SUBSTR(CUSTODYCD,1,4)= V_SSYSVAR || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                  ORDER BY CUSTODYCD) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT,1,4);*/
            begin
                SELECT CUSTODYCDFROM,CUSTODYCDTO
                       INTO v_startnumtemp,v_endnumtemp
                      FROM BRGRP WHERE BRID = V_BRID;
            exception when others then
                v_startnum:= 0;
                v_endnum:= 999999;
            end;
            v_startnum:= v_startnumtemp;
            v_endnum:= v_endnumtemp;
            begin
                SELECT SUBSTR(INVACCT,1,4), (v_startnum) + MAX(ODR)+1 AUTOINV
                into v_prefix, v_AUTOINV
                FROM
                (SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT CUSTODYCD INVACCT
                                  FROM ( select custodycd FROM CFMAST
                                        WHERE SUBSTR(CUSTODYCD,1,4)= V_SSYSVAR || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                                        union all
                                        select custodycd FROM CFMASTMEMO
                                        WHERE SUBSTR(CUSTODYCD,1,4)= V_SSYSVAR || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                                        )CFMAST
                        WHERE TRIM( TO_NUMBER(SUBSTR(CUSTODYCD,5,6))) >= v_startnum and TRIM( TO_NUMBER(SUBSTR(CUSTODYCD,5,6)))<=v_endnum
                            ORDER BY CUSTODYCD
                         ) DAT
                    WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM+v_startnum
                ) INVTAB
                GROUP BY SUBSTR(INVACCT,1,4);
               /*   If(v_AUTOINVTEMP < v_endnum) then
                          v_AUTOINV := v_AUTOINVTEMP;
                  else
                         plog.setendsection (pkgctx, 'fn_txAppUpdate');
                         p_err_code:=-670101;--So luu ky da het han muc cap phep

                  end if;*/
            exception when others then
              v_prefix:='';
              v_AUTOINV:=v_startnum + 1;
            end;
            OPEN PV_REFCURSOR
            FOR
            select v_prefix ODR,  v_AUTOINV AUTOINV from dual ;
          ELSIF (V_CLAUSE = 'AFACCTNO') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT,1,4), MAX(ODR)+1 AUTOINV FROM
                   (
                   SELECT ROWNUM ODR, INVACCT
                   FROM (   select ACCTNO INVACCT from (
                                 SELECT ACCTNO FROM AFMAST WHERE SUBSTR(ACCTNO,1,4) = V_BRID
                                 union all
                                 SELECT substr(CHILD_RECORD_KEY,-11,10) ACCTNO  FROM APPRVEXEC WHERE CHILD_TABLE_NAME = 'AFMAST' and ACTION_FLAG = 'ADD' AND STATUS = 'N'
                             ) ORDER BY ACCTNO
                         ) DAT
                   WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM
                   ) INVTAB
                   GROUP BY SUBSTR(INVACCT,1,4);
          ELSIF (V_CLAUSE = 'GRACCTNO') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT, 1, V_iRefLength), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT ACCTNO INVACCT FROM GRMAST WHERE SUBSTR(ACCTNO, 1, V_iRefLength)= V_REFERENCE ORDER BY ACCTNO) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,13,4))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT, 1, V_iRefLength);
          ELSIF (V_CLAUSE = 'LMACCTNO') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT, 1, V_iRefLength), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT ACCTNO INVACCT FROM LMMAST WHERE SUBSTR(ACCTNO, 1, V_iRefLength)= V_REFERENCE ORDER BY ACCTNO) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,13,4))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT, 1, V_iRefLength);
          ELSIF (V_CLAUSE = 'CLACCTNO') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT, 1, V_iRefLength), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT ACCTNO INVACCT FROM CLMAST WHERE SUBSTR(ACCTNO, 1, V_iRefLength)= V_REFERENCE ORDER BY ACCTNO) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,13,4))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT, 1, V_iRefLength);
          ELSIF (V_CLAUSE = 'LNAPPLID') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT, 1, V_iRefLength), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT APPLID INVACCT FROM LNAPPL WHERE SUBSTR(APPLID, 1, V_iRefLength)= V_REFERENCE ORDER BY APPLID) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,13,3))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT, 1, V_iRefLength);
          ELSIF (V_CLAUSE = 'LNACCTNO') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SUBSTR(INVACCT, 1, V_iRefLength), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT ACCTNO INVACCT FROM LNMAST WHERE SUBSTR(ACCTNO, 1, V_iRefLength)= V_REFERENCE ORDER BY ACCTNO) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,16,3))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT, 1, V_iRefLength);
          ELSIF (V_CLAUSE = 'OPTCODEID') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT TO_NUMBER(SUBSTR((TO_CHAR(MAX(TO_NUMBER(nvl(invacct,0))) + 1)), 2, LENGTH((TO_CHAR(MAX(TO_NUMBER(nvl(invacct,0))) + 1))) - 1)) autoinv,
                  (MAX(nvl(odr,0)) + 1) odr
                  FROM   (SELECT   ROWNUM odr, invacct
                  FROM   (SELECT   invacct
                  FROM   (SELECT   codeid invacct FROM sbsecurities WHERE substr(codeid, 1, 1)=9 UNION ALL SELECT '900001' FROM dual)
                  ORDER BY   invacct) dat
                  ) invtab;
         ELSIF (V_CLAUSE = 'SEQ_ODMAST') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SEQ_ODMAST.NEXTVAL AUTOINV FROM DUAL;
        --Ducnv FF Gateway
        ELSIF (V_CLAUSE = 'SEQ_ODMASTPT') THEN
             OPEN PV_REFCURSOR
             FOR
                SELECT SEQ_ODMASTPT.NEXTVAL AUTOINV FROM DUAL;
        --end Ducnv FF Gateway
         ELSIF (V_CLAUSE = 'SEQ_DFMAST') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SEQ_DFMAST.NEXTVAL AUTOINV FROM DUAL;
         ELSIF (V_CLAUSE = 'SEQ_WITHDRAWN') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SEQ_WITHDRAWN.NEXTVAL AUTOINV FROM DUAL;
         ELSIF (V_CLAUSE = 'SEQ_SMSMOBILE') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SEQ_SMSMOBILE.NEXTVAL AUTOINV FROM DUAL;
         ELSIF (V_CLAUSE = 'PRTYPE') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT SEQ_PRTYPE.NEXTVAL AUTOINV FROM DUAL;
         ELSIF (V_CLAUSE = 'ISSUERID') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT (MAX(TO_NUMBER(ISSUERID)) + 1) AUTOINV FROM ISSUERS;
         ELSIF (V_CLAUSE = 'CODEID') THEN
             OPEN PV_REFCURSOR
             FOR


                  SELECT (MAX(TO_NUMBER(INVACCT)) + 1) AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT CODEID INVACCT FROM SBSECURITIES WHERE SUBSTR(CODEID, 1, 1) <> 9 ORDER BY CODEID) DAT
                  ) INVTAB;
         ELSIF (V_CLAUSE = 'POTXNUM') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT NVL(MAX(ODR)+1,1) AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT TXNUM INVACCT FROM POMAST WHERE BRID = V_BRID ORDER BY TXNUM) DAT
                  ) INVTAB;
        ELSIF (V_CLAUSE = 'ADTXNUM') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT NVL(MAX(ODR)+1,1) AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT TXNUM INVACCT FROM ADMAST WHERE BRID = V_BRID ORDER BY TXNUM) DAT
                  ) INVTAB;
        ELSIF (V_CLAUSE = 'PRMASTER') THEN
             OPEN PV_REFCURSOR
             FOR
                SELECT  NVL(MAX(ODR)+1,1) AUTOINV FROM
                    (SELECT ROWNUM ODR, INVACCT
                        FROM (SELECT prcode INVACCT FROM PRMASTER  ORDER BY prcode) DAT
                        WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;

        ELSIF (V_CLAUSE = 'CAMASTID') THEN
             OPEN PV_REFCURSOR
             FOR
                  /*SELECT SEQ_CAMAST.NEXTVAL AUTOINV FROM DUAL;  */

            /* v_strSQL = "SELECT SUBSTR(INVACCT,1,10), MAX(ODR)+1 AUTOINV FROM " & ControlChars.CrLf _
            '            & "(SELECT ROWNUM ODR, INVACCT " & ControlChars.CrLf _
            '            & "FROM (SELECT CAMASTID INVACCT FROM CAMAST WHERE SUBSTR(CAMASTID,1,10)='" & v_strREFERENCE & "' ORDER BY CAMASTID) DAT " & ControlChars.CrLf _
            '            & "WHERE TO_NUMBER(SUBSTR(INVACCT,11,6))=ROWNUM) INVTAB " & ControlChars.CrLf _
            '            & "GROUP BY SUBSTR(INVACCT,1,10)"*/


                /*   SELECT  NVL(MAX(ODR)+1,1) AUTOINV FROM
                    (SELECT ROWNUM ODR, INVACCT
                        FROM (SELECT CAMASTID INVACCT FROM CAMAST  ORDER BY CAMASTID) DAT
                        ) INVTAB;*/

                         SELECT  NVL(INVACCT+1,1) AUTOINV FROM
                    (SELECT  (CASE WHEN INVACCT1>INVACCT2 THEN inVACCT1 ELSE INVACCT2 END )INVACCT
                        FROM (select sum(INVACCT1) INVACCT1, sum(INVACCT2) INVACCT2 from (
                                    SELECT max(TO_NUMBER(SUBSTR(CAMAST.CAMASTID,11,6))) INVACCT1, 0 INVACCT2 from camast
                                    union
                                    SELECT 0 INVACCT1, max(TO_NUMBER(SUBSTR(CAMASTHIST.CAMASTID,11,6))) INVACCT2 from camasthist
                                )
                             ) DAT
                        ) INVTAB;



        ELSIF (V_CLAUSE = 'BANKNOSTRO') THEN
             OPEN PV_REFCURSOR
             FOR
                  SELECT  NVL(MAX(ODR)+1,1) AUTOINV FROM
                    (SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT SHORTNAME INVACCT FROM BANKNOSTRO ORDER BY SHORTNAME) DAT
                    WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;
        ELSIF (V_CLAUSE = 'TRFACINV') THEN
            OPEN PV_REFCURSOR
             FOR
                  SELECT  NVL(MAX(ODR)+1,1) AUTOINV FROM
                    (SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT AUTOID INVACCT FROM CRBTRFACCTSRC ORDER BY AUTOID) DAT
                    WHERE TO_NUMBER(INVACCT)=ROWNUM) INVTAB;
        END IF;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
