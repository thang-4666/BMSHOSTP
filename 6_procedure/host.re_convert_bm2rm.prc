SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RE_CONVERT_BM2RM" is
    v_currdate date;
    v_txnum VARCHAR2(10);
    v_prevdate date;
    v_nextdate date;
BEGIN
    SELECT getcurrdate INTO v_currdate FROM dual;

    -- 1. Rut cac bieu MG ra khoi nhom MG
    -- Thuc hien GD 0385
    -- Ko log thanh GD
    FOR rec IN
        (
            SELECT REF.AUTOID, CFLEADER.CUSTID LEADERID, CFLEADER.FULLNAME LEADERNAME, LNK.AUTOID LNKAUTOID,
                REF.custid||REF.ACTYPE LEADREACCTNO, LNK.REACCTNO,LNK.CUSTID, REF.ACTYPE, RE.FULLNAME REFULLNAME, LNK.FRDATE, LNK.TODATE,
                REF.FULLNAME GRNAME, REF.GRPLEVEL
            FROM REGRPLNK LNK, REGRP REF, CFMAST CFLEADER, CFMAST RE, RETYPE TYP, RECFLNK RF
            WHERE REF.AUTOID=LNK.REFRECFLNKID AND REF.CUSTID=CFLEADER.CUSTID AND  SUBSTR(LNK.reacctno,11,4)=TYP.ACTYPE
                AND RE.CUSTID=LNK.CUSTID  AND LNK.STATUS='A'
                AND REF.CUSTID = RF.CUSTID
        )
    LOOP
        -- Update dong cac tai khoan MG khoi nhom MG
        UPDATE REGRPLNK SET
            PSTATUS = PSTATUS || STATUS,
            STATUS = 'C',
            CLSTXDATE = v_currdate,
            CLSTXNUM = ''
        WHERE CUSTID = rec.custid AND REACCTNO = rec.reacctno AND REFRECFLNKID = rec.autoid;
    END LOOP;

    -- 2. Rut khach hang ra khoi MG bieu BM
    -- Thuc hien GD 0384
    -- Ko log thanh GD
    FOR rec IN
        (
            SELECT LNK.AUTOID, LNK.REACCTNO, LNK.AFACCTNO, LNK.FRDATE, LNK.TODATE, MST.ACTYPE, MST.CUSTID, TYP.REROLE, TYP.RETYPE,
                CFREREF.FULLNAME REFULLNAME, CFAFREF.FULLNAME AFFULLNAME, CFAFREF.CUSTODYCD
            FROM REMAST MST, RETYPE TYP, REAFLNK LNK, CFMAST CFREREF, CFMAST CFAFREF, AFMAST AF, RECFLNK RF
            WHERE TYP.ACTYPE=MST.ACTYPE AND MST.ACCTNO=LNK.REACCTNO AND CFREREF.CUSTID=MST.CUSTID
                AND LNK.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CFAFREF.CUSTID AND LNK.STATUS='A'
                AND MST.CUSTID = RF.CUSTID
        )
    LOOP
        -- Update dong cac tai khoan khach hang khoi MG
        UPDATE REAFLNK SET
            PSTATUS = PSTATUS || STATUS,
            STATUS = 'C',
            CLSTXDATE = v_currdate,
            CLSTXNUM = ''
        WHERE AFACCTNO = rec.afacctno AND REACCTNO = rec.reacctno;
    END LOOP;

    -- 3. Dong TK moi gioi
    -- Thuc hien GD 0390
    -- Ko log thanh GD
    FOR rec IN
        (
            SELECT CF.CUSTID || RF.REACTYPE REACCT, RF.AUTOID, CFMAST.FULLNAME, TYP.ACTYPE, TYP.TYPENAME,
                typ.rerole,RF.EFFDATE, RF.EXPDATE,RF.ODRNUM, CF.CUSTID
            FROM RECFDEF RF, RETYPE TYP, RECFLNK CF, CFMAST
            WHERE RF.REACTYPE=TYP.ACTYPE
                AND RF.REFRECFLNKID = CF.AUTOID
                AND CF.CUSTID = CFMAST.CUSTID
        )
    LOOP
        -- Update dong TK moi gioi
        UPDATE remast SET
            balance = 0,
            PSTATUS = PSTATUS || STATUS,
            status = 'C'
        WHERE acctno = rec.REACCT;
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        return ;
END; -- Procedure

 
 
 
 
/
