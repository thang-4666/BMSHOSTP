SET DEFINE OFF;
CREATE OR REPLACE FUNCTION sp_func_getcflimit (v_bankid in varchar2, v_custid in varchar2, v_subtype in varchar2, v_amt in number) RETURN NUMBER IS
    v_count         NUMBER;
    v_allmaxlimit   NUMBER;
    v_avllimit      NUMBER;
    v_outstanding   NUMBER;
    v_alloutstanding    NUMBER;
    v_checktyp      CHAR(1);
    v_defsubtyp     VARCHAR2(3);
    v_return        NUMBER;
BEGIN
v_outstanding:=0;
v_alloutstanding:=0;
v_allmaxlimit:=0;
--Lay han muc khach hang: Uu tien quy dinh nghiep vu truoc roi moi set den All
SELECT COUNT(LMAMT) INTO v_count
FROM CFLIMITEXT WHERE BANKID=v_bankid AND CUSTID=v_custid AND STATUS='A';
IF v_count>0 THEN
    --Kiem tra neu khach hang co quy dinh rieng
    SELECT LMAMT, LMCHKTYP, LMSUBTYPE INTO v_avllimit, v_checktyp, v_defsubtyp
    FROM (SELECT LMAMT, LMCHKTYP, LMSUBTYPE, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
    FROM CFLIMITEXT WHERE BANKID=v_bankid AND CUSTID=v_custid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
    ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1)) WHERE ROWNUM=1;
ELSE
    --Neu bank khong quy dinh thi khong can kiem tr
    SELECT COUNT(LMAMT) INTO v_count
    FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE=v_subtype OR LMSUBTYPE='ALL');
    IF v_count>0 THEN
        --Theo quydinh chung cua bank
        SELECT LMAMT, LMCHKTYP, LMSUBTYPE INTO v_avllimit, v_checktyp, v_defsubtyp
        FROM (SELECT LMAMT, LMCHKTYP, LMSUBTYPE, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
        FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
        ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1)) WHERE ROWNUM=1;
    ELSE
        --Khong kiem tra
        RETURN 0;
    END IF;
END IF;



--Lay du no cua khach hang theo ngan hang
IF v_defsubtyp='ADV' THEN
    BEGIN
        --Kiem tra du no UTTB cua khach hang
        SELECT NVL(SUM(AMT),0) INTO v_outstanding
        FROM ADSCHD MST, ADTYPE TYP, AFMAST AF
        WHERE MST.ADTYPE=TYP.ACTYPE AND MST.ACCTNO=AF.ACCTNO
        AND AF.CUSTID=v_custid AND PAIDAMT=0 AND TYP.CUSTBANK=v_bankid;

        --Kiem tra du no UTTB cua toan bo khach hang theo du no bank
        SELECT NVL(SUM(AMT),0) INTO v_alloutstanding
        FROM ADSCHD MST, ADTYPE TYP
        WHERE MST.ADTYPE=TYP.ACTYPE AND PAIDAMT=0 AND TYP.CUSTBANK=v_bankid;

        --Xac dinh han muc tong toi da do ngan hang quy dinh
        SELECT NVL(LMAMTMAX,0) INTO v_allmaxlimit
        FROM (SELECT LMAMTMAX, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
        FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
        ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1)) WHERE ROWNUM=1;
    END;

    --Kiem tra han muc hop le
    IF v_avllimit-v_outstanding>v_amt AND v_allmaxlimit-v_alloutstanding>v_amt THEN
      v_return := 0;
    ELSIF v_avllimit-v_outstanding<v_amt then
      v_return := -100423;   -- Ma loi vuot han muc vay cua khach hang
    ELSE
      v_return := -100424;   -- Ma loi vuot han muc cho vay cua ngan hang
    END IF;
END IF;


--Lay du no cua khach hang theo ngan hang
IF v_defsubtyp='DFMR' THEN
    BEGIN
        --Kiem tra du no DF cua khach hang
        if v_checktyp='C' then --Check theo han muc hien tai
            begin
                select nvl(sum(prinnml + prinovd),0) amt into v_outstanding
                from lnmast ln , afmast af
                where ln.trfacctno = af.acctno and af.custid=v_custid
                and ftype ='DF'
                and custbank=v_bankid;
            exception when others then
                v_outstanding:=0;
            end;
        else --Check theo han muc dau ngay
            begin
                select nvl(sum(ln.prinnml + ln.prinovd + nvl(tr.dayrlsamt,0)),0) amt into v_outstanding
                from lnmast ln , afmast af ,
                (
                    select tr.acctno, sum(namt) Dayrlsamt
                    from lntran tr, apptx tx
                    where tr.txcd= tx.txcd and tx.apptype ='LN'
                    and tx.field in('PRINNML','PRINOVD')
                    and tx.txtype='D'
                    and tr.deltd <> 'Y'
                    group by tr.acctno
                ) tr
                where ln.trfacctno = af.acctno
                and ln.acctno = tr.acctno(+)
                and af.custid=v_custid
                and ftype ='DF'
                and custbank=v_bankid;
            exception when others then
                v_outstanding:=0;
            end;
        end if;

        --Kiem tra du no DF cua toan bo khach hang theo du no bank
        select nvl(sum(prinnml + prinovd),0) amt  into v_alloutstanding
                from lnmast ln
                where ftype ='DF'
                and custbank=v_bankid
                and prinnml + prinovd>0;

        --Xac dinh han muc tong toi da do ngan hang quy dinh
        select nvl(lmamtmax,0) into v_allmaxlimit
                from (select lmamtmax, decode(lmsubtype,v_subtype,0,1) priorityord
                        from cflimit where bankid=v_bankid and status='A' and (lmsubtype='ALL' or lmsubtype=v_subtype)
                        order by decode(lmsubtype,v_subtype,0,1)
                     ) where rownum=1;
    END;

    --Kiem tra han muc hop le
    IF v_avllimit-v_outstanding>v_amt AND v_allmaxlimit-v_alloutstanding>v_amt THEN
      v_return := 0;
    ELSIF v_avllimit-v_outstanding<v_amt then
      v_return := -100423;   -- Ma loi vuot han muc vay cua khach hang
    ELSE
      v_return := -100424;   -- Ma loi vuot han muc cho vay cua ngan hang
    END IF;
END IF;



IF v_defsubtyp='ALL' THEN
    BEGIN
        Begin
            --Kiem tra du no UTTB
            --**********************************************************
            --Kiem tra du no UTTB cua khach hang
            SELECT NVL(SUM(AMT),0)+v_outstanding INTO v_outstanding
            FROM ADSCHD MST, ADTYPE TYP, AFMAST AF
            WHERE MST.ADTYPE=TYP.ACTYPE AND MST.ACCTNO=AF.ACCTNO
            AND AF.CUSTID=v_custid AND PAIDAMT=0 AND TYP.CUSTBANK=v_bankid;

            --Kiem tra du no UTTB cua toan bo khach hang theo du no bank
            SELECT NVL(SUM(AMT),0)+v_alloutstanding INTO v_alloutstanding
            FROM ADSCHD MST, ADTYPE TYP
            WHERE MST.ADTYPE=TYP.ACTYPE AND PAIDAMT=0 AND TYP.CUSTBANK=v_bankid;
        end;
        BEGIN
            --Kiem tra du no DF cua khach hang
            --**********************************************************
            if v_checktyp='C' then --Check theo han muc hien tai
                begin
                    select nvl(sum(prinnml + prinovd),0)  + v_outstanding into v_outstanding
                    from lnmast ln , afmast af
                    where ln.trfacctno = af.acctno and af.custid=v_custid
                    and ftype ='DF'
                    and custbank=v_bankid;
                exception when others then
                    v_outstanding:=0;
                end;
            else --Check theo han muc dau ngay
                begin
                    select nvl(sum(ln.prinnml + ln.prinovd + nvl(tr.dayrlsamt,0)),0) + v_outstanding into v_outstanding
                    from lnmast ln , afmast af ,
                    (
                        select tr.acctno, sum(namt) Dayrlsamt
                        from lntran tr, apptx tx
                        where tr.txcd= tx.txcd and tx.apptype ='LN'
                        and tx.field in('PRINNML','PRINOVD')
                        and tx.txtype='D'
                        and tr.deltd <> 'Y'
                        group by tr.acctno
                    ) tr
                    where ln.trfacctno = af.acctno
                    and ln.acctno = tr.acctno(+)
                    and af.custid=v_custid
                    and ftype ='DF'
                    and custbank=v_bankid;
                exception when others then
                    v_outstanding:=0;
                end;
            end if;

            --Kiem tra du no DF cua toan bo khach hang theo du no bank
            select nvl(sum(prinnml + prinovd) ,0) + v_alloutstanding into v_alloutstanding
                    from lnmast ln
                    where ftype ='DF'
                    and custbank=v_bankid
                    and prinnml + prinovd>0;
        END;
        --Kiem tra cac nguon vay khac
        --**********************************************************

        --Xac dinh han muc tong toi da do ngan hang quy dinh
        SELECT NVL(LMAMTMAX,0) INTO v_allmaxlimit
        FROM (SELECT LMAMTMAX, DECODE(LMSUBTYPE,v_subtype,0,1) PRIORITYORD
        FROM CFLIMIT WHERE BANKID=v_bankid AND STATUS='A' AND (LMSUBTYPE='ALL' OR LMSUBTYPE=v_subtype)
        ORDER BY DECODE(LMSUBTYPE,v_subtype,0,1)) WHERE ROWNUM=1;
    END;
    --Kiem tra han muc hop le
    IF v_avllimit-v_outstanding>v_amt AND v_allmaxlimit-v_alloutstanding>v_amt THEN
      v_return := 0;
    ELSIF v_avllimit-v_outstanding<v_amt then
      v_return := -100423;   -- Ma loi vuot han muc vay cua khach hang
    ELSE
      v_return := -100424;   -- Ma loi vuot han muc cho vay cua ngan hang
    END IF;
END IF;


RETURN v_return;
EXCEPTION
   WHEN others THEN
       return SQLCODE ;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
