SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_prchk
  IS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


  FUNCTION fn_AutoPRTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
  RETURN NUMBER;

  FUNCTION fn_prAutoCheck(p_xmlmsg IN OUT varchar2,p_err_code in out varchar2,p_err_param out varchar2)
  RETURN NUMBER;

  FUNCTION fn_prAutoUpdate(p_xmlmsg IN OUT varchar2,p_err_code in out varchar2,p_err_param out varchar2)
  RETURN NUMBER;

  FUNCTION fn_txAutoCheck(p_txmsg in  tx.msg_rectype, p_err_code out varchar2)
  RETURN NUMBER;

  FUNCTION fn_txAutoUpdate(p_txmsg in  tx.msg_rectype, p_err_code out varchar2)
  RETURN NUMBER;

  FUNCTION fn_txAdhocCheck(p_id IN VARCHAR2,
              p_acctno IN VARCHAR2, p_codeid IN VARCHAR2,
              p_refid IN VARCHAR2,
              p_qtty IN NUMBER, p_amt IN NUMBER,
              p_brid IN VARCHAR2,
              p_type in VARCHAR2, p_actype IN VARCHAR2,
              p_txnum IN VARCHAR2, p_txdate IN DATE,
              p_deltd IN VARCHAR2,
              p_err_code out varchar2)
  RETURN NUMBER;

  FUNCTION fn_txAdhocUpdate(p_id IN VARCHAR2,
              p_acctno IN VARCHAR2, p_codeid IN VARCHAR2,
              p_refid IN VARCHAR2,
              p_qtty IN NUMBER, p_amt IN NUMBER,
              p_brid IN VARCHAR2,
              p_type IN VARCHAR2, p_actype IN VARCHAR2,
              p_txnum IN VARCHAR2, p_txdate IN DATE,
              p_deltd IN VARCHAR2,
              p_err_code out varchar2)
  RETURN NUMBER;

  FUNCTION fn_getExpectUsed(p_PrCode VARCHAR2) RETURN number;

  FUNCTION fn_SecuredUpdate(p_dorc varchar2, p_amount NUMBER, p_acctno VARCHAR2, p_txnum varchar2, p_txdate date,
                  p_err_code OUT VARCHAR2 ,P_AMOUNT_EX in NUMBER DEFAULT 0)
  RETURN NUMBER;

  FUNCTION fn_RoomLimitCheck(p_afacctno in varchar2, p_codeid in varchar2, p_qtty in NUMBER, p_err_code in out varchar2)
  RETURN NUMBER;
  FUNCTION FN_ISPRIVATEROOM(P_afACCTNO VARCHAR2, P_CODEID VARCHAR2)
  RETURN BOOLEAN;
  FUNCTION FN_ROOMPRINUSEDLOG(p_dorc varchar2, p_amount NUMBER, p_acctno VARCHAR2, P_CODEID VARCHAR2,p_txnum varchar2, p_txdate date,
                  p_err_code OUT VARCHAR2)
  RETURN NUMBER;
  FUNCTION FN_SECUREDUPDATE_EX( p_dorc varchar2, p_amount NUMBER, p_acctno VARCHAR2, p_txnum varchar2, p_txdate date,                    p_err_code OUT VARCHAR2)
  RETURN NUMBER;
  FUNCTION fn_reset_prinused (p_err_code out varchar2) return number;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_prchk
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

FUNCTION fn_getVal(p_amtexp IN varchar2)
RETURN FLOAT
IS
    l_sql varchar2(500);
    CUR             PKG_REPORT.REF_CURSOR;
    l_EntryAmount FLOAT;
BEGIN
    l_sql := 'select ' || p_amtexp || ' from dual';
    OPEN CUR FOR l_sql;
       LOOP
       FETCH CUR INTO l_EntryAmount ;
       EXIT WHEN CUR%NOTFOUND;
       END LOOP;
       CLOSE CUR;
    RETURN l_EntryAmount;
END fn_getVal;


FUNCTION fn_BuildAMTEXP(p_txmsg IN tx.msg_rectype,p_amtexp IN varchar2)
RETURN VARCHAR2
IS
  l_Evaluator varchar2(100);
  l_Elemenent  varchar2(20);
  l_Index number(10,0);
  l_ChildValue varchar2(100);
BEGIN
    l_Evaluator:= '';
    l_Index:= 1;
    While l_Index < LENGTH(p_amtexp) loop
        --Get 02 charatacters in AMTEXP
        l_Elemenent := substr(p_amtexp, l_Index, 2);
        if l_Elemenent in ( '++', '--', '**', '//', '((', '))') then
                --Operand
                l_Evaluator := l_Evaluator || substr(l_Elemenent,1,1);
        elsif l_Elemenent in ( 'MA') then
                --Operand
                l_Evaluator := 'GREATEST(' || l_Evaluator || ',0)';
        elsif l_Elemenent in ( 'MI') then
                --Operand
                l_Evaluator := 'LEAST(' || l_Evaluator || ',0)';
        else
                --OPERATOR
                l_ChildValue:= p_txmsg.txfields(l_Elemenent).value;
                l_Evaluator := l_Evaluator || l_ChildValue;
        End if;
        l_Index := l_Index + 2;
    end loop;
   RETURN l_Evaluator;
EXCEPTION
WHEN OTHERS THEN
    RETURN '0';
END fn_BuildAMTEXP;


FUNCTION fn_parse_amtexp(p_txmsg IN tx.msg_rectype,p_amtexp IN varchar2)
RETURN FLOAT
IS
    l_value varchar2(100);
BEGIN
    IF length(p_amtexp) > 0 THEN
        IF substr(p_amtexp,0,1) = '@' THEN
            l_value:=replace(p_amtexp,'@');
        ELSIF substr(p_amtexp,0,1) = '$' THEN
            l_value:= replace(p_amtexp,'$');
            l_value:= p_txmsg.txfields(l_value).value;
        ELSE
            l_value:= fn_BuildAMTEXP(p_txmsg,p_amtexp);
            l_value:= fn_getVal(l_value);
        END IF;
    END IF;
    RETURN l_value;
END fn_parse_amtexp;

-- Check this function - IF IS FALSE --> Pool/Room: RETURN SUCCESSFUL!
FUNCTION fn_IsPRCheck(p_txmsg IN tx.msg_rectype, p_acctno VARCHAR2, p_prcode VARCHAR2, p_prtype VARCHAR2, p_actionType VARCHAR2)
RETURN BOOLEAN
IS
    l_count NUMBER;
BEGIN

    /*
    ---- CUSTATCOM?
    */
    select count(1) into l_count
    from cfmast cf, afmast af
    where cf.custid = af.custid
    and cf.custatcom = 'Y'
    and af.acctno = substr(p_acctno,0,10);
    if not l_count > 0 then
        RETURN FALSE;
    end if;

    /********************************************************
    -- Khong CHECK voi TK luu ky ben ngoai Cty CK va TK giai ngan.
    ********************************************************/
    SELECT count(1) INTO l_count
    FROM cfmast cf, afmast af
    WHERE af.custid = cf.custid
        AND (substr(cf.custodycd,0,3) = (SELECT varvalue FROM sysvar WHERE varname = 'COMPANYCD' AND grname = 'SYSTEM')
            or substr(cf.custodycd,0,3) = (SELECT varvalue FROM sysvar WHERE varname = 'REPO_PREFIX' AND grname = 'SYSTEM'))
        AND NOT EXISTS (SELECT 1 FROM lntype WHERE ciacctno = af.acctno AND ciacctno IS NOT NULL)
        AND af.acctno = substr(p_acctno, 0, 10);
    IF l_count = 0 THEN
        RETURN FALSE;
    END IF;


    /********************************************************
    -- KHONG check Room voi cac giao dich sau NEU khong phai tai khoan Credit Line.
    ********************************************************/
    -- removed
    /********************************************************
    -- KHONG check Pool voi cac giao dich sau NEU khong phai tai khoan Credit Line.
    ********************************************************/
    IF p_prtype = 'P' AND p_txmsg.tltxcd in ('1107','1108') THEN
        SELECT count(1) INTO l_count
        FROM afmast af, aftype aft, mrtype mrt
        WHERE af.acctno = substr(p_acctno,0,10) -- lay ra so tieu khoan.
        AND aft.actype = af.actype
        AND aft.mrtype = mrt.actype
        AND mrt.mrtype IN ('S','T');

        IF l_count = 0 THEN
            RETURN FALSE;
        END IF;
    END IF;

    /********************************************************
    -- KHONG check Pool voi cac giao dich dat lenh tren TK Margin Loan
    ********************************************************/
    -- removed
    /********************************************************
    -- KHONG check Pool/Room voi giao dich tao deal vay DF tren TK Margin Loan
    ********************************************************/
    IF p_txmsg.tltxcd in ('2670') AND p_actionType = 'C' THEN
        SELECT count(1) INTO l_count
        FROM afmast af, aftype aft, mrtype mrt
        WHERE af.acctno = substr(p_acctno,0,10) -- lay ra so tieu khoan.
        AND aft.actype = af.actype
        AND aft.mrtype = mrt.actype
        AND mrt.mrtype IN ('L');

        IF l_count <> 0 THEN
            RETURN FALSE;
        END IF;
    END IF;


    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END fn_IsPRCheck;

FUNCTION FN_ISPRIVATEROOM(P_afACCTNO VARCHAR2, P_CODEID VARCHAR2)
RETURN BOOLEAN
IS
    l_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO L_COUNT FROM PRMASTER
    WHere PRSTATUS='A' AND CODEID=P_CODEID
    AND PRTYP='R' AND POOLTYPE='AF' AND AFACCTNO=P_AFACCTNO;
    IF L_COUNT=1 THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END  FN_ISPRIVATEROOM;
--Get by Careby Group.
FUNCTION fn_getCurrentPR(p_txmsg IN tx.msg_rectype, p_PrCode IN VARCHAR2, p_PrTyp IN VARCHAR2, p_AfAcctno IN VARCHAR2, p_CodeID IN VARCHAR2)
RETURN number
IS
    l_ExpectUsed number(20,0);
    l_AvlPR number(20,0);
    l_CIAvlAmount number(20,0);
    l_CodeID varchar2(20);
    l_TempValue number(20,0);
BEGIN
    -- Truong hop: nguon co the khong xai den. DO tai san khach hang du de thuc hien

    select fn_getExpectUsed(p_PrCode) INTO l_ExpectUsed from dual;

    SELECT prlimit - prinused - l_ExpectUsed
        INTO l_AvlPR
    FROM prmaster WHERE prcode = p_PrCode;

    IF p_PrTyp = 'P' THEN
        IF substr(p_txmsg.tltxcd,0,2) IN ('26','77')
            OR p_txmsg.tltxcd IN ('1115','1116') THEN
            -- Giao dich cho vay truc tiep. Khong quan tam den so du khach hang. (26XX: DF; 77XX: Repo)
            l_CIAvlAmount:= 0;
        ELSE
            SELECT CASE WHEN mrt.mrtype = 'L' THEN 0
                        ELSE GREATEST(ci.balance + nvl(adv.avladvance,0) - nvl(od.secureamt,0) - ci.trfbuyamt - ci.odamt /*- ci.depofeeamt*/,0) END
                INTO l_CIAvlAmount
            FROM cimast ci, afmast af, aftype aft, mrtype mrt,
                (SELECT afacctno, sum(depoamt) avladvance FROM v_getaccountavladvance WHERE afacctno = p_AfAcctno group BY afacctno) adv,
                (SELECT afacctno,secureamt FROM v_getbuyorderinfo WHERE afacctno = p_AfAcctno) od
            WHERE ci.afacctno = adv.afacctno(+) AND ci.afacctno = od.afacctno(+)
                AND ci.afacctno = af.acctno AND aft.actype = af.actype AND aft.mrtype = mrt.actype
                and ci.afacctno = p_AfAcctno;
        END IF;

        l_AvlPR:=greatest(l_AvlPR + nvl(l_CIAvlAmount,0),l_AvlPR,0);
    ELSIF p_PrTyp = 'R' THEN
        l_AvlPR:=greatest(l_AvlPR,0);
    ELSE
        RETURN 0;
    END IF;

    return l_AvlPR;
exception when others then
    return 0;
END fn_getCurrentPR;


/**
* Cap nhat gia tri nguon du tinh theo xu ly dac biet. Ham goi di theo giao dich.
**/
/*FUNCTION fn_SecuredUpdate(p_txnum VARCHAR2, p_txdate DATE, p_deltd VARCHAR2,
                p_dorc varchar2, p_amount NUMBER,
                p_acctno VARCHAR2, p_codeid varchar2, p_prtyp VARCHAR2, p_type VARCHAR2, p_actype VARCHAR2, p_brid VARCHAR2, p_refid VARCHAR2,
                p_err_code OUT VARCHAR2)
RETURN NUMBER
IS
l_count NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_SecuredUpdate');
    p_err_code:=systemnums.c_success;*/
/*
    --Kiem tra theo san phan l_actype, l_type, l_brid
    FOR rec IN
    (
        SELECT DISTINCT pm.prcode, pm.prname, pm.prtyp, pm.codeid, pm.prlimit,
                pm.prinused, pm.expireddt, pm.prstatus
        FROM prmaster pm, prtype prt, prtypemap prtm, typeidmap tpm, bridmap brm
        WHERE pm.prcode = brm.prcode
            AND pm.prcode = prtm.prcode
            AND prt.actype = prtm.prtype
            AND prt.actype = tpm.prtype
            AND pm.codeid = decode(p_prtyp,'R',p_codeid,pm.codeid)
            AND pm.prtyp = p_prtyp
            AND prt.TYPE = p_type
            AND tpm.typeid = decode(tpm.typeid,'ALL',tpm.typeid,p_AcType)
            AND brm.brid = decode(brm.brid,'ALL',brm.brid,p_brid)
    )
    LOOP
        IF p_deltd <> 'Y' THEN
            IF p_dorc = 'C' THEN --Tang nguon: ~ giam nguon du tinh su dung
                INSERT INTO prinusedlog (prcode, prinused, deltd, last_change, autoid, txnum, txdate, ref)
                VALUES (rec.prcode, -p_amount, 'N', SYSTIMESTAMP, seq_prinusedlog.NEXTVAL, p_txnum, p_txdate, p_refid);
            ELSE --Giam nguon: ~ tang nguon du tinh su dung
                INSERT INTO prinusedlog (prcode, prinused, deltd, last_change, autoid, txnum, txdate, ref)
                VALUES (rec.prcode, p_amount, 'N', SYSTIMESTAMP, seq_prinusedlog.NEXTVAL, p_txnum, p_txdate, p_refid);
            END IF;
        ELSE
            UPDATE prinusedlog
            SET deltd = 'Y'
            WHERE txnum = p_txnum AND txdate = p_txdate;
        END IF;
    END LOOP;*/

/*    plog.setendsection (pkgctx, 'fn_SecuredUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.setendsection (pkgctx, 'fn_SecuredUpdate');
    p_err_code:=errnums.c_system_error;
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_SecuredUpdate;*/


/*
-- Check if p_dorc = 'D'.
-- Update temporary secured
*/
FUNCTION FN_ROOMPRINUSEDLOG(p_dorc varchar2, p_amount NUMBER, p_acctno VARCHAR2,P_CODEID VARCHAR2, p_txnum varchar2, p_txdate date,
                p_err_code OUT VARCHAR2)
RETURN NUMBER
IS
l_count NUMBER;
l_amt number(20,4);
l_actype varchar2(10);
l_BrID varchar2(10);
L_AVLPRIN NUMBER;
L_PRCODE  varchar2(50);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_SecuredUpdate');
    p_err_code:=systemnums.c_success;
    l_amt:=P_AMOUNT;
    select count(1) into l_count
    from cfmast cf, afmast af
    where cf.custid = af.custid
    and af.acctno = p_acctno and cf.custatcom = 'Y';
    if l_count > 0 THEN
          SELECT af.ACTYPE, cf.brid
          INTO L_ACTYPE,L_BRID
          FROM AFMAST af, cfmast cf
          WHERE ACCTNO=P_ACCTNO
          AND af.custid=cf.custid;
          -- plog.error(pkgctx,'L_ACTYPE:'||L_ACTYPE || ' L_BRID:'||L_BRID || ' p_codeid:'||p_codeid );
          IF FN_ISPRIVATEROOM(P_ACCTNO,P_CODEID)=TRUE THEN
             --ROOM dac biet
              SELECT PRCODE, PRLIMIT-PRINUSED-fn_getExpectUsed(PRCODE) PRLIMIT
              INTO L_PRCODE,L_AVLPRIN
              FROM PRMASTER
              WHERE PRTYP='R' AND POOLTYPE='AF'
              AND PRSTATUS='A' AND AFACCTNO= P_ACCTNO
              AND CODEID=P_CODEID;
              if p_dorc = 'D' AND L_AMT >L_AVLPRIN THEN
                      p_err_code:= '-100522';
                      plog.setendsection (pkgctx, 'FN_ROOMPRINUSEDLOG');
                      RETURN P_ERR_CODE;
              end if;

                  insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                  values(L_PRCODE, (case when p_dorc = 'C' then -1 else 1 end)*l_amt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, p_txnum,p_txdate );
          ELSE-- room nhom tai khoan
              FOR REC IN (
                SELECT DISTINCT PM.PRCODE,PRLIMIT-PRINUSED-fn_getExpectUsed(PM.PRCODE) PRLIMIT
                FROM PRMASTER PM,PRTYPE PRT, PRTYPEMAP PRTM,TYPEIDMAP TMP, BRIDMAP BRM
                WHERE PM.PRCODE=BRM.PRCODE
                AND pm.prcode = prtm.prcode
                AND prt.actype = prtm.prtype
                AND PM.POOLTYPE='GR'
                AND prt.actype = TMP.PRTYPE
                AND pm.codeid = p_codeid
                AND pm.prtyp = 'R'
                AND prt.TYPE = 'AFTYPE'
                AND pm.prstatus = 'A'
                AND TMP.typeid = decode(TMP.TYPEID,'ALL',TMP.TYPEID,l_actype)
                AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
               )
              LOOP
                  if p_dorc = 'D' AND L_AMT >REC.PRLIMIT THEN
                      p_err_code:= '-100523';
                      plog.setendsection (pkgctx, 'FN_ROOMPRINUSEDLOG');
                      RETURN P_ERR_CODE;
                  end if;
                 -- plog.error(pkgctx,'PRCODE:'||REC.PRCODE );
                  insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                  values(REC.PRCODE, (case when p_dorc = 'C' then -1 else 1 end)*l_amt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval, p_txnum,p_txdate );

              END LOOP;
          END IF;

          RETURN p_err_code;
    end if;
    plog.setendsection (pkgctx, 'FN_ROOMPRINUSEDLOG');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.error(pkgctx,'row:'||dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'FN_ROOMPRINUSEDLOG');
    p_err_code:=errnums.c_system_error;
    RETURN errnums.C_BIZ_RULE_INVALID;
END FN_ROOMPRINUSEDLOG;

FUNCTION fn_SecuredUpdate(p_dorc varchar2, p_amount NUMBER, p_acctno VARCHAR2, p_txnum varchar2, p_txdate date,
                p_err_code OUT VARCHAR2,
                P_AMOUNT_EX in NUMBER DEFAULT 0)
RETURN NUMBER
IS
l_count NUMBER;
l_amt number(20,4);
l_actype varchar2(10);
l_BrID varchar2(10);
l_IsMarginAccount VARCHAR2(1);
L_ADVPRIO VARCHAR2(1);
l_isDFAccount VARCHAR2(1);
L_AVLCFLIMIT NUMBER;
v_lndfcustbank varchar2(100);
l_custid varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_SecuredUpdate');
    p_err_code:=systemnums.c_success;
    -- chi tinh pool voi nhung tk margin tuan thu he thong
     BEGIN
         select AFT.ADVPRIO,(CASE WHEN mrt.MRTYPE IN ('S','T') THEN 'Y' ELSE 'N' END),(CASE WHEN mrt.MRTYPE ='F' THEN 'Y' ELSE 'N' END)
         into L_ADVPRIO,l_IsMarginAccount,l_isDFAccount
          from afmast af, aftype aft, mrtype mrt, lntype lnt
          WHERE af.actype=aft.actype AND aft.mrtype=mrt.actype
          AND aft.lntype=lnt.actype(+)
          AND mrt.mrtype IN ('S','T','F') AND nvl( lnt.chksysctrl,'Y')='Y'
          AND af.acctno=p_acctno;

      EXCEPTION WHEN OTHERS THEN
          l_IsMarginAccount:='N';
          L_ADVPRIO:='N';
          l_isDFAccount:='N';
      END;

    select count(1) into l_count
    from cfmast cf, afmast af
    where cf.custid = af.custid
    and af.acctno = p_acctno and cf.custatcom = 'Y';

    if l_count > 0  AND l_IsMarginAccount='Y' THEN

        -- Sau khi giai toa ky quy chung khoan mua: chi giai toa pool tuong ung voi gia tri chung khoan from -amount den zero.
        if p_DorC = 'C' then
            SELECT

                /* least(-least(DECODE(ADV.ADVPRIO,'Y',NVL(adv.avladvance,0)+nvl(td.tdamt,0),0)
                        + mst.balance
                        - nvl(secureamt,0)
                        -- - mst.depofeeamt
                        - (p_amount) ,0),

                        (p_amount) )  */
              ( CASE WHEN L_ADVPRIO='Y' THEN
                   least(-least(NVL(adv.avladvance,0)+nvl(td.tdamt,0)
                                         + mst.balance
                                         - nvl(secureamt,0)
                                         -- - mst.depofeeamt
                                         - (p_amount) ,0),

                                (p_amount)
                                )
                ELSE
                  least(
                          least(
                                 least( -least(balance-nvl(secureamt,0)-P_AMOUNT,0),
                                           nvl(secureamt,0)+ P_AMOUNT_EX,
                                           GREATEST(AF.MRCRLIMITMAX-MST.ODAMT ,0)
                                         )
                                 ) ,
                           (p_amount)
                         )
                END )
                into l_amt
            from cimast MST
            LEFT JOIN        -- phan tiet kiem
                       (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                        FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                        AND SYSVAR.GRNAME = 'SYSTEM'
                        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                        AND mst.buyingpower='Y'
                        AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                        GROUP BY AF.ACCTNO
                        )TD   ON mst.acctno=td.afacctno
            LEFT JOIN (SELECT MRCRLIMITMAX,ACCTNO FROm AFMAST) AF ON AF.ACCTNO=MST.ACCTNO
            left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno,Max(ADVPRIO) ADVPRIO from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.acctno
            where mst.acctno = p_acctno;
          -- PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8809 l_amt' || l_amt);
        else    --      p_DorC = 'D'
           /* select
                least(-least(DECODE(ADV.ADVPRIO,'Y',NVL(adv.avladvance,0),0)
                        + mst.balance
                        - nvl(secureamt,0)
                        \*- mst.depofeeamt*\
                        ,0),

                        (p_amount))
                into l_amt
            from cimast MST*/
            select
                least(CASE WHEN L_ADVPRIO='Y'
                      THEN
                         -least(NVL(adv.avladvance,0)
                          + mst.balance +nvl(td.tdamt,0)
                          - nvl(secureamt,0)
                          /*- mst.depofeeamt*/
                          ,0)
                        ELSE
                           -least(
                               greatest((mst.balance -nvl(secureamt,0)),
                                        -GREATEST(AF.MRCRLIMITMAX-MST.ODAMT
                                                  -GREATEST(nvl(secureamt,0)- p_amount-BALANCE,0)
                                                  ,0)
                                        )

                              /*- mst.depofeeamt*/
                              ,0
                                )
                        END,

                        (p_amount),nvl(secureamt,0))
                into l_amt
            from CIMAST MST
            LEFT JOIN        -- phan tiet kiem
                       (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                        FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                        AND SYSVAR.GRNAME = 'SYSTEM'
                        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                        AND mst.buyingpower='Y'
                        AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                        GROUP BY AF.ACCTNO
                        )TD   ON mst.acctno=td.afacctno
            left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno,Max(ADVPRIO) ADVPRIO from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.ACCTNO
            LEFT JOIN (SELECT MRCRLIMITMAX,ACCTNO FROm AFMAST) AF ON AF.ACCTNO=MST.ACCTNO
            where mst.acctno = p_acctno;
        end if;
      --  PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8835 l_amt' || l_amt);
        if l_amt > 0 then
           select af.actype, cf.brid into l_actype, l_BrID from afmast af,cfmast cf WHERE af.custid=cf.custid AND  af.acctno = p_acctno;
              FOR REC_PR IN (
                   SELECT * FROM
            -- Pool dac biet cho tieu khoan
            (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+fn_getExpectUsed(pm.prcode) prinused,
                    PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                    FROM PRMASTER PM
                   WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                   AND PM.prstatus='A'
                    and PM.prtyp='P'
            UNION ALL-- Pool dac biet cho danh sach khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                  FROM PRMASTER PM,PRAFMAP PRM
                  WHERE PM.POOLTYPE='GR'
                  AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                  AND PM.prstatus='A'
                  and PM.prtyp='P'
            UNION ALL-- Pool cho nhom loai hinh khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                  FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                  WHERE PM.PRCODE=BRM.PRCODE
                  AND pm.prcode = prtm.prcode
                  AND pm.prstatus = 'A'
                  AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                  --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                  AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                  and PM.prtyp='P'
                  AND pm.pooltype='TY'
            UNION ALL
                --PooL he thong
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                FROM PRMASTER PM
                WHERE  PM.POOLTYPE='SY'
                AND PM.prstatus='A'
                and PM.prtyp='P'
              )
WHERE odr=
( SELECT  min(odr) FROM
                          -- Pool dac biet cho tieu khoan
                          (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                  PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                                  FROM PRMASTER PM
                                 WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                 AND PM.prstatus='A'
                                  and PM.prtyp='P'
                          UNION ALL-- Pool dac biet cho danh sach khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                                FROM PRMASTER PM,PRAFMAP PRM
                                WHERE PM.POOLTYPE='GR'
                                AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                AND PM.prstatus='A'
                                and PM.prtyp='P'
                          UNION ALL-- Pool cho nhom loai hinh khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                                FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                                WHERE PM.PRCODE=BRM.PRCODE
                                AND pm.prcode = prtm.prcode
                                AND pm.prstatus = 'A'
                                AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                                --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                                AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                                and PM.prtyp='P'
                                AND pm.pooltype='TY'
                          UNION ALL
                              --PooL he thong
                              SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                              PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                              FROM PRMASTER PM
                              WHERE  PM.POOLTYPE='SY'

                              AND PM.prstatus='A'
                              and PM.prtyp='P'
                            )       )


             )

             LOOP
                if p_dorc = 'D' then
                    if l_amt > (rec_pr.prlimit - rec_pr.prinused) then
                        p_err_code:= '-100522';
                        plog.setendsection (pkgctx, 'fn_SecuredUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                end if;

                insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate,AFACCTNO)
                values(rec_pr.prcode, (case when p_dorc = 'C' then -1 else 1 end)*l_amt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval,
                p_txnum,p_txdate,p_acctno );
             end loop;
         end if;
    end if;
    --- TINH RIENG PHAN DF
     IF l_count > 0  AND l_isDFAccount='Y' THEN


       if p_DorC = 'C' then
            SELECT


              ( CASE WHEN L_ADVPRIO='Y' THEN
                   least(-least(NVL(adv.avladvance,0)+nvl(td.tdamt,0)
                                         + mst.balance
                                         - nvl(secureamt,0)
                                         -- - mst.depofeeamt
                                         - (p_amount) ,0),

                                (p_amount)
                                )
                ELSE
                  least(
                          least(
                                 least( -least(balance-nvl(secureamt,0)-P_AMOUNT,0),
                                           nvl(secureamt,0)+ P_AMOUNT_EX,
                                           GREATEST(AF.MRCRLIMITMAX-MST.ODAMT ,0)
                                         )
                                 ) ,
                           (p_amount)
                         )
                END )
                into l_amt
            from cimast MST
            LEFT JOIN        -- phan tiet kiem
                       (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                        FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                        AND SYSVAR.GRNAME = 'SYSTEM'
                        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                        AND mst.buyingpower='Y'
                        AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                        GROUP BY AF.ACCTNO
                        )TD   ON mst.acctno=td.afacctno
            LEFT JOIN (SELECT MRCRLIMITMAX,ACCTNO FROm AFMAST) AF ON AF.ACCTNO=MST.ACCTNO
            left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno,Max(ADVPRIO) ADVPRIO from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.acctno
            where mst.acctno = p_acctno;
          -- PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8809 l_amt' || l_amt);
        else    --      p_DorC = 'D'

            select
                least(CASE WHEN L_ADVPRIO='Y'
                      THEN
                         -least(NVL(adv.avladvance,0)
                          + mst.balance +nvl(td.tdamt,0)
                          - nvl(secureamt,0)
                          /*- mst.depofeeamt*/
                          ,0)
                        ELSE
                           -least(
                               greatest((mst.balance -nvl(secureamt,0)),
                                        -GREATEST(AF.MRCRLIMITMAX-MST.ODAMT
                                                  -GREATEST(nvl(secureamt,0)- p_amount-BALANCE,0)
                                                  ,0)
                                        )

                              /*- mst.depofeeamt*/
                              ,0
                                )
                        END,

                        (p_amount),nvl(secureamt,0))
                into l_amt
            from CIMAST MST
            LEFT JOIN        -- phan tiet kiem
                       (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                        FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                        AND SYSVAR.GRNAME = 'SYSTEM'
                        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                        AND mst.buyingpower='Y'
                        AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                        GROUP BY AF.ACCTNO
                        )TD   ON mst.acctno=td.afacctno
            left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno,Max(ADVPRIO) ADVPRIO from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.ACCTNO
            LEFT JOIN (SELECT MRCRLIMITMAX,ACCTNO FROm AFMAST) AF ON AF.ACCTNO=MST.ACCTNO
            where mst.acctno = p_acctno;
        end if;
      --  PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8835 l_amt' || l_amt);
        if l_amt > 0 then
          -- select af.actype, cf.brid into l_actype, l_BrID from afmast af,cfmast cf WHERE af.custid=cf.custid AND  af.acctno = p_acctno;

       SELECT max(LNT.CUSTBANK), max(af.custid)   into v_lndfcustbank,l_custid
                  FROM AFMAST   AF,
                       AFTYPE   AFT,
                       AFIDTYPE AFID,
                       DFTYPE   DFT,
                       LNTYPE   LNT
                 WHERE AFT.ACTYPE = AFID.AFTYPE
                   AND AFID.ACTYPE = DFT.ACTYPE
                   AND AF.ACTYPE = AFT.ACTYPE
                   AND DFT.LNTYPE = LNT.ACTYPE
                  -- AND LNT.RRTYPE = 'B'
                   AND AF.ACCTNO = p_acctno
                   AND OBJNAME = 'DF.DFTYPE'
                   AND DFT.STATUS <> 'N';


           IF P_DORC = 'D' THEN



            BEGIN

                 L_AVLCFLIMIT := GREATEST(CSPKS_CFPROC.FN_GETAVLCFLIMIT(v_lndfcustbank,
                                                                l_custid,
                                                                 'DFMR'),
                                   0);
                 EXCEPTION
                 WHEN OTHERS THEN
                 L_AVLCFLIMIT := 0;
                 END;


                    if l_amt > L_AVLCFLIMIT then
                        p_err_code:= '-100522';
                        plog.setendsection (pkgctx, 'fn_SecuredUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                end if;

                insert into prinusedlog (prcode,prinused,deltd,last_change,autoid,txnum,txdate,AFACCTNO)
                values(v_lndfcustbank, (case when p_dorc = 'C' then -1 else 1 end)*l_amt, 'N', SYSTIMESTAMP, seq_prinusedlog.nextval,
                p_txnum,p_txdate,p_acctno );

         end if;


     END IF;


    plog.setendsection (pkgctx, 'fn_SecuredUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.error(pkgctx,'row:'||dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'fn_SecuredUpdate');
    p_err_code:=errnums.c_system_error;
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_SecuredUpdate;

--PhuongHT add: 08.03.2015
-- sua yeu cau cua VCBS: log pool de phan biet lenh mua khop va chua khop
FUNCTION FN_SECUREDUPDATE_EX (p_dorc varchar2, p_amount NUMBER, p_acctno VARCHAR2, p_txnum varchar2, p_txdate date,
                p_err_code OUT VARCHAR2)
RETURN NUMBER
IS
l_count NUMBER;
l_amt number(20,4);
l_actype varchar2(10);
l_BrID varchar2(10);
l_IsMarginAccount varchar2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'FN_SECUREDUPDATE_EX');
    p_err_code:=systemnums.c_success;
        -- chi tinh pool voi nhung tk margin tuan thu he thong
     select count(1) into l_count
        from afmast af, aftype aft, mrtype mrt, lntype lnt
        WHERE af.actype=aft.actype AND aft.mrtype=mrt.actype
        AND aft.lntype=lnt.actype
        AND mrt.mrtype IN ('S','T') AND lnt.chksysctrl='Y'
        AND af.acctno=p_acctno;
         if l_count = 0 then
            l_IsMarginAccount:='N';
        else
            l_IsMarginAccount:='Y';
        end if;
       select count(1) into l_count
    from cfmast cf, afmast af
    where cf.custid = af.custid
    and af.acctno = p_acctno and cf.custatcom = 'Y';

    if l_count > 0 AND l_IsMarginAccount='Y' THEN

        -- Sau khi giai toa ky quy chung khoan mua: chi giai toa pool tuong ung voi gia tri chung khoan from -amount den zero.
        if p_DorC = 'C' then
            SELECT

                /* least(-least(DECODE(ADV.ADVPRIO,'Y',NVL(adv.avladvance,0)+nvl(td.tdamt,0),0)
                        + mst.balance
                        - nvl(secureamt,0)
                        -- - mst.depofeeamt
                        - (p_amount) ,0),

                        (p_amount) )  */
              ( CASE WHEN ADV.ADVPRIO='Y' THEN
                   least(-least(NVL(adv.avladvance,0)+nvl(td.tdamt,0)
                                         + mst.balance
                                         - nvl(secureamt,0)
                                         -- - mst.depofeeamt
                                         - (p_amount) ,0),

                                (p_amount)
                                )
                ELSE
                  least(
                          least(greatest(balance,0),
                                 least( -least(balance-nvl(secureamt,0),0),
                                           nvl(secureamt,0),
                                           GREATEST(AF.MRCRLIMITMAX-MST.ODAMT ,0)
                                         )
                                 ) ,
                           (p_amount)
                         )
                END )
                into l_amt
            from cimast MST
            LEFT JOIN        -- phan tiet kiem
                       (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                        FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                        AND SYSVAR.GRNAME = 'SYSTEM'
                        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                        AND mst.buyingpower='Y'
                        AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                        GROUP BY AF.ACCTNO
                        )TD   ON mst.acctno=td.afacctno
            LEFT JOIN (SELECT MRCRLIMITMAX,ACCTNO FROm AFMAST) AF ON AF.ACCTNO=MST.ACCTNO
            left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno,Max(ADVPRIO) ADVPRIO from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.acctno
            where mst.acctno = p_acctno;
          -- PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8809 l_amt' || l_amt);
        else
               select
                least(CASE WHEN ADV.ADVPRIO='Y'
                      THEN
                         -least(NVL(adv.avladvance,0)
                          + mst.balance  +nvl(td.tdamt,0)
                          - nvl(mst.execbuyamt,0)
                          /*- mst.depofeeamt*/
                          ,0)
                        ELSE
                           -least(
                               greatest((mst.balance -nvl(mst.execbuyamt,0)),
                               -GREATEST(AF.MRCRLIMITMAX-MST.ODAMT ,0))

                              /*- mst.depofeeamt*/
                              ,0
                                )
                        END,

                        (p_amount),nvl(secureamt,0))
                into l_amt
            from CIMAST MST
            LEFT JOIN        -- phan tiet kiem
                       (SELECT SUM(NVL(MST.BALANCE,0)) TDAMT,AF.ACCTNO AFACCTNO
                        FROM TDMAST MST, AFMAST AF, TDTYPE TYP, sysvar
                        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND SYSVAR.VARNAME='CURRDATE'
                        AND SYSVAR.GRNAME = 'SYSTEM'
                        AND MST.DELTD<>'Y' AND MST.status in ('N','A')
                        AND mst.buyingpower='Y'
                        AND (mst.breakcd='Y' OR (mst.breakcd='N' AND TO_date(SYSVAR.VARVALUE,'DD/MM/RRRRR') > mst.todate ))
                        GROUP BY AF.ACCTNO
                        )TD   ON mst.acctno=td.afacctno
            left join (select * from v_getbuyorderinfo where afacctno = p_acctno) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno,Max(ADVPRIO) ADVPRIO from v_getAccountAvlAdvance where afacctno = p_acctno group by afacctno) adv on adv.afacctno=MST.ACCTNO
            LEFT JOIN (SELECT MRCRLIMITMAX,ACCTNO FROm AFMAST) AF ON AF.ACCTNO=MST.ACCTNO
            where mst.acctno = p_acctno;
        end if;

        if l_amt > 0 then
           select af.actype, cf.brid into l_actype, l_BrID from afmast af, cfmast cf where  af.custid=cf.custid AND af.acctno = p_acctno;
                  FOR REC_PR IN (
                SELECT * FROM
            -- Pool dac biet cho tieu khoan
            (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                    PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                    FROM PRMASTER PM
                   WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                   AND PM.prstatus='A'
                    and PM.prtyp='P'
            UNION ALL-- Pool dac biet cho danh sach khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                  FROM PRMASTER PM,PRAFMAP PRM
                  WHERE PM.POOLTYPE='GR'
                  AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                  AND PM.prstatus='A'
                  and PM.prtyp='P'
            UNION ALL-- Pool cho nhom loai hinh khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                  FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                  WHERE PM.PRCODE=BRM.PRCODE
                  AND pm.prcode = prtm.prcode
                  AND pm.prstatus = 'A'
                  AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                  --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                  AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                  and PM.prtyp='P'
                  AND pm.pooltype='TY'
            UNION ALL
                --PooL he thong
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                FROM PRMASTER PM
                WHERE  PM.POOLTYPE='SY'

                AND PM.prstatus='A'
                and PM.prtyp='P'
              )
WHERE odr=
( SELECT  min(odr) FROM
                          -- Pool dac biet cho tieu khoan
                          (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                  PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                                  FROM PRMASTER PM
                                 WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                 AND PM.prstatus='A'
                                  and PM.prtyp='P'
                          UNION ALL-- Pool dac biet cho danh sach khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                                FROM PRMASTER PM,PRAFMAP PRM
                                WHERE PM.POOLTYPE='GR'
                                AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                AND PM.prstatus='A'
                                and PM.prtyp='P'
                          UNION ALL-- Pool cho nhom loai hinh khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                                FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                                WHERE PM.PRCODE=BRM.PRCODE
                                AND pm.prcode = prtm.prcode
                                AND pm.prstatus = 'A'
                                AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                                --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                                AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                                and PM.prtyp='P'
                                AND pm.pooltype='TY'
                          UNION ALL
                              --PooL he thong
                              SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                              PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                              FROM PRMASTER PM
                              WHERE  PM.POOLTYPE='SY'

                              AND PM.prstatus='A'
                              and PM.prtyp='P'
                            )       )


             )

             LOOP
            /*    if p_dorc = 'D' then
                    if l_amt > (rec_pr.prlimit - rec_pr.prinused) then
                        p_err_code:= '-100522';
                        plog.setendsection (pkgctx, 'fn_SecuredUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                end if;*/

                insert into prinusedlog_ex (prcode,prinused,deltd,last_change,autoid,txnum,txdate)
                values(rec_pr.prcode, (case when p_dorc = 'C' then -1 else 1 end)*l_amt, 'N', SYSTIMESTAMP, seq_prinusedlog_ex.nextval, p_txnum,p_txdate );
             end loop;
         end if;
    end if;
    plog.setendsection (pkgctx, 'FN_SECUREDUPDATE_EX');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.error(pkgctx,'row:'||dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'FN_SECUREDUPDATE_EX');
    p_err_code:=errnums.c_system_error;
    RETURN errnums.C_BIZ_RULE_INVALID;
END FN_SECUREDUPDATE_ex;
FUNCTION fn_getExpectUsed(p_PrCode VARCHAR2) RETURN number IS
l_ExpectUsed number(20, 0);
l_AvlPR      number(20, 0);
l_pooltype   VARCHAR2(10);
l_prtyp        VARCHAR2(10);
l_afpool_used  NUMBER(20,0);
BEGIN
    l_ExpectUsed:=0;
    -- tinh tong gia tri da dung cho cac nguon tai khoan , nhom tk
    SELECT pooltype,prtyp
    INTO l_pooltype,l_prtyp
    FROM prmaster
    WHERE prcode= p_PrCode;
    l_afpool_used:=0;
    IF  l_pooltype='SY' AND  l_prtyp='P'  THEN
        BEGIN
              SELECT nvl(SUM(prlimit),0) INTO l_afpool_used
              from prmaster
              WHERE pooltype IN ('AF','GR')
              AND prstatus='A' ;
        EXCEPTION WHEN OTHERS THEN
             l_afpool_used:=0;
        END ;
    END IF;
    BEGIN
      SELECT nvl(sum(prinused),0)
        INTO l_ExpectUsed
        FROM prinusedlog
       WHERE prcode = p_PrCode;
    EXCEPTION
      WHEN OTHERS THEN
        l_ExpectUsed := 0;
    END;
     l_ExpectUsed:= l_ExpectUsed+    l_afpool_used;
    return l_ExpectUsed;
exception
when others then
  return 0;
END fn_getExpectUsed;

/**
* Cap nhat gia tri nguon du tinh theo xu ly dac biet. Ham goi di theo giao dich.
**/
FUNCTION fn_txAutoAdhocUpdate(p_txmsg in tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS
l_AfAcctno varchar2(10);
l_AfAcctno2 varchar2(10);
l_AcType varchar2(4);
l_Type varchar2(10);
l_count NUMBER;
l_IsSpecialPR NUMBER;
l_CodeID varchar2(6);
l_OrderID varchar2(20);
l_UsedAmt NUMBER;
l_UsedQtty NUMBER;
l_TotalUsedQtty NUMBER;
l_CurrDate DATE;
l_sumexecqtty NUMBER;
l_execqtty NUMBER;
l_matchamt NUMBER;
l_trade NUMBER;
l_AIntRate NUMBER;
l_AMinBal NUMBER;
l_AFeeBank NUMBER;
l_AMinFeeBank NUMBER;
l_qtty NUMBER;
l_BrID  varchar2(4);
l_IsMarginAccount char(1);
l_amt number;
l_ExecType varchar2(2);
l_NumVal1 number;
l_NumVal2 number;
L_BORS    VARCHAR2(10);
L_RATIO   NUMBER;
L_TXNUM  VARCHAR2(10);
L_TXDATE DATE;
l_advsellduty     NUMBER(20,4);
l_whtax     NUMBER(20,4);
L_days            NUMBER(20);
l_advrate         NUMBER(20,4);
l_isvat           VARCHAR2(1);
l_iswhtax         VARCHAR2(1);
l_clearday        NUMBER(10);
l_oldamt          NUMBER(20,4);
l_newamt          NUMBER(20,4);
L_EDSTATUS        VARCHAR2(5);
L_ADVPRIO         VARCHAR2(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAutoAdhocUpdate');
    l_UsedAmt:=0;
    l_UsedQtty:=0;
    l_CurrDate:= to_date(cspks_system.fn_get_sysvar('SYSTEM', 'CURRDATE'),systemnums.c_date_format);
    l_AIntRate:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AINTRATE'));
    l_AMinBal:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AMINBAL'));
    l_AFeeBank:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AFEEBANK'));
    l_AMinFeeBank:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AMINFEEBANK'));
    l_advsellduty:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'ADVSELLDUTY'));
    l_whtax := to_number(cspks_system.fn_get_sysvar('SYSTEM', 'WHTAX'));
    IF p_txmsg.tltxcd in ('1140','1131') THEN -- Nap tien qua quy
        -- Xu ly Room:
        SELECT AFT.ADVPRIO INTO
        L_ADVPRIO
        FROM AFMAST af, AFTYPE AFT
        WHERE AF.ACTYPE=AFT.ACTYPE
        AND AF.ACCTNO=p_txmsg.txfields('03').VALUE;
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            -- Xu ly Pool: -- Tang nguon
            IF L_ADVPRIO='N' THEN -- khong uu tien UTTB
               SELECT LEAST(GREATEST(BALANCE,0),to_number(p_txmsg.txfields('10').value))
               INTO L_AMT
               FROM CIMAST WHERE ACCTNO=p_txmsg.txfields('03').VALUE;
            ELSE
              L_AMT:=to_number(p_txmsg.txfields('10').value);
            END IF;
            if fn_SecuredUpdate('C', L_AMT, p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reverser
            -- Xu ly Pool: -- Tang nguon
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    --elsIF p_txmsg.tltxcd in ('2200','2202','2232','2242','2243','2244','2250') THEN -- Rut chuyen chung khoan
   /* elsIF p_txmsg.tltxcd in ('2200') THEN -- Rut chuyen chung khoan
        -- Xu ly Room:
          --Danh dau room  cho cac tai khoan co room dac biet
        if p_txmsg.deltd <> 'Y' then -- Normal Transaction
            --IF FN_ISPRIVATEROOM( p_txmsg.txfields('02').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('C',
                        to_number(p_txmsg.txfields('55').value), p_txmsg.txfields('02').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            --END IF;
         ELSE
            --IF FN_ISPRIVATEROOM( p_txmsg.txfields('02').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('D',
                        to_number(p_txmsg.txfields('55').value), p_txmsg.txfields('02').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                        plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');

                        RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            --END IF;
         END IF;*/
  --  elsIF p_txmsg.tltxcd in ('2242') THEN -- Rut chuyen chung khoan
        -- Xu ly Room:
      /*    --Danh dau room  cho cac tai khoan co room dac biet
        if p_txmsg.deltd <> 'Y' then -- Normal Transaction
            --IF FN_ISPRIVATEROOM( p_txmsg.txfields('02').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('C',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('02').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
           -- END IF;
         ELSE
            --IF FN_ISPRIVATEROOM( p_txmsg.txfields('02').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('D',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('02').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                        plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');

                        RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
           -- END IF;
         END IF; */
    --elsIF p_txmsg.tltxcd in ('2242','2245') THEN -- Nap nhan chung khoan
       /*-- Xu ly Room:
          --Danh dau room  cho cac tai khoan co room dac biet
        if p_txmsg.deltd <> 'Y' then -- Normal Transaction
            --IF FN_ISPRIVATEROOM( p_txmsg.txfields('04').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('D',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('04').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
           -- END IF;
         ELSE
           -- IF FN_ISPRIVATEROOM( p_txmsg.txfields('04').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('C',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('04').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                        plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');

                        RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
           -- END IF;
         END IF;*/
    elsIF p_txmsg.tltxcd in ('2246','2203','2252','2253') THEN -- Nap nhan chung khoan
        null;
    elsIF p_txmsg.tltxcd in ('1141') THEN -- Nap tien tu ngan hang
        if p_txmsg.deltd <> 'Y' then -- Normal Transaction
            -- Xu ly Room:
            -- Xu ly Pool: -- Tang nguon
            SELECT AFT.ADVPRIO INTO
            L_ADVPRIO
            FROM AFMAST af, AFTYPE AFT
            WHERE AF.ACTYPE=AFT.ACTYPE
            AND AF.ACCTNO=p_txmsg.txfields('03').VALUE;
            IF L_ADVPRIO='N' THEN
               SELECT LEAST(GREATEST(BALANCE,0),to_number(p_txmsg.txfields('10').value))
               INTO L_AMT FROM CIMAST WHERE ACCTNO=p_txmsg.txfields('03').VALUE;
            ELSE
               L_AMT:=to_number(p_txmsg.txfields('10').value);
            END IF;
            if fn_SecuredUpdate('C', L_AMT, p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reverser Transactions
            -- Xu ly Room:
            -- Xu ly Pool: -- Tang nguon
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('1101','1100','1111','1110','1670','1132') THEN -- Rut tien
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            -- Xu ly Room:
            -- Xu ly Pool: -- giam nguon
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
          /* if FN_SECUREDUPDATE_EX('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;*/
        else -- Reserver Transactions
            -- Xu ly Room:
            -- Xu ly Pool: -- giam nguon
            if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
           /* if FN_SECUREDUPDATE_EX('C', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;*/
        end if;
    elsIF p_txmsg.tltxcd in ('1107','1108') THEN -- Rut tien
        if p_txmsg.deltd <> 'Y' then -- Normal transaction
            -- Xu ly Room:
            -- Xu ly Pool: -- giam nguon
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reserver Transaction
            -- Xu ly Room:
            -- Xu ly Pool: -- giam nguon
            if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('8890') THEN -- Sua lenh

        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
           /* if to_number(p_txmsg.txfields('18').value) > 0 then
                -- Xu ly Pool: -- giam nguon
                if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('18').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if; */
                L_AMT:=to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('14').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value);

            IF to_number(p_txmsg.txfields('18').value) < 0 OR L_AMT>0  THEN
               L_AMT:=L_AMT+abs(to_number(p_txmsg.txfields('18').value));
                -- Xu ly Pool: -- tang nguon
                if fn_SecuredUpdate('C', L_AMT, p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        else -- Reverser Transactions
            if to_number(p_txmsg.txfields('18').value) > 0 then
                -- Xu ly Pool: -- giam nguon
                if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('18').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            elsif to_number(p_txmsg.txfields('18').value) < 0 then
                -- Xu ly Pool: -- giam nguon
                if fn_SecuredUpdate('D', abs(to_number(p_txmsg.txfields('18').value)), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('3384') THEN -- Dang ky quyen mua
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            -- Xu ly Room:
            -- Xu ly Pool: -- giam nguon
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reverser Transactions
            -- Xu ly Room:
            -- Xu ly Pool: -- giam nguon
            if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('1120','1130') THEN -- chuyen khoan noi bo
        if p_txmsg.deltd <> 'Y' then -- Normal transactions
            -- Xu ly Room:
            --1. TK chuyen
            --2. TK nhan
            -- Xu ly Pool:
            --1. TK chuyen:
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
            --2. TK nhan:
            if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('05').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reserver Transactions
            -- Xu ly Room:
            --1. TK chuyen
            --2. TK nhan
            -- Xu ly Pool:
            --1. TK chuyen:
            if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
            --2. TK nhan:
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value), p_txmsg.txfields('05').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;

    elsIF p_txmsg.tltxcd in ('5540') THEN -- tra no LN: bao lanh, margin
        null;
        -- Xu ly Pool: Giao dich tra no. Thuc hien luon ko Du tinh
    elsIF p_txmsg.tltxcd in ('8804') THEN -- khop lenh
       if p_txmsg.txfields('83').value = 'S' THEN
           if p_txmsg.deltd <> 'Y' then -- Normal Transactions
              -- Xu ly Room:
                    --Danh dau room  cho cac tai khoan co room dac biet
                --  IF FN_ISPRIVATEROOM( p_txmsg.txfields('04').value,p_txmsg.txfields('80').value)=TRUE THEN
                      if FN_ROOMPRINUSEDLOG('C',
                              to_number(p_txmsg.txfields('11').value), p_txmsg.txfields('04').value,p_txmsg.txfields('80').value, p_txmsg.txnum, p_txmsg.txdate,  p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                      end if;
                 -- END IF;
                  -- Xu ly Pool:
                    L_ORDERID:=p_txmsg.txfields('03').VALUE;
                BEGIN
                      SELECT CASE WHEN sts.cleardate-l_CurrDate= 0 THEN 1 ELSE sts.cleardate-l_currdate END
                      INTO l_days
                      FROM stschd    sts
                      where orgorderid=l_orderid AND duetype='RM'
                      AND deltd <> 'Y';

                      SELECT adt.advrate ,(CASE WHEN cf.vat ='Y' THEN 1 ELSE 0 END),(CASE WHEN cf.whtax ='Y' THEN 1 ELSE 0 END),AFT.ADVPRIO
                      INTO l_advrate ,l_isvat,l_iswhtax,L_ADVPRIO
                      FROM aftype aft, afmast af,adtype adt ,cfmast cf
                      WHERE af.actype=aft.actype AND aft.adtype=adt.actype
                      AND af.custid=cf.custid
                      AND af.acctno=  p_txmsg.txfields('04').value;
                EXCEPTION WHEN OTHERS THEN
                       l_days:=0;
                       l_advrate:=0;
                END;
                IF L_ADVPRIO='Y' THEN
                    l_amt:=   to_number(p_txmsg.txfields('10').value)*to_number(p_txmsg.txfields('11').value)
                                  *(1-(to_number(p_txmsg.txfields('15').value)/100-1) -(l_isvat*l_advsellduty+ l_iswhtax*l_whtax)/100 )
                                  /(1+L_days/360*l_advrate/100);
                      if fn_SecuredUpdate('C',l_amt, p_txmsg.txfields('04').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                          plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                          RETURN errnums.C_BIZ_RULE_INVALID;
                      end if;
                ENd IF;
          else -- Reverser Transactions
              -- Xu ly Room:
                  --IF FN_ISPRIVATEROOM( p_txmsg.txfields('04').value,p_txmsg.txfields('80').value)=TRUE THEN
                      if FN_ROOMPRINUSEDLOG('D',
                              to_number(p_txmsg.txfields('11').value), p_txmsg.txfields('04').value,p_txmsg.txfields('80').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                      end if;
                 -- END IF;
                  -- Xu ly Pool:
                  if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value)*to_number(p_txmsg.txfields('11').value)*to_number(p_txmsg.txfields('15').value)/100, p_txmsg.txfields('04').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                  end if;
          end if;
      ELSE -- lenh mua, ghi them vao log EX phuc vu tinh gia tri pool su dung tren phan thuc da khop
           L_ORDERID:=p_txmsg.txfields('03').VALUE;
           /*BEGIN

             \*  IF fn_SecuredUpdate_EX('D', to_number(p_txmsg.txfields('10').value)*to_number(p_txmsg.txfields('11').value)*to_number(p_txmsg.txfields('15').value)/        100, p_txmsg.txfields('04').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code)  <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
               end if;*\
           EXCEPTION WHEN OTHERS THEN
                      L_TXNUM:=NULL;
                      L_TXDATE:=NULL;
           END ;*/

      END IF;
     elsIF p_txmsg.tltxcd in ('8835') THEN --xoa khop lenh
           SELECT CASE WHEN EXECTYPE IN ('NS','MS') THEN 'S' ELSE 'B' END,
           BRATIO,clearday
           INTO L_BORS,L_RATIO,l_clearday FROM ODMAST WHERE ORDERID=p_txmsg.txfields('03').VALUE;
       if L_BORS = 'S' THEN
           if p_txmsg.deltd <> 'Y' then -- Normal Transactions
              -- Xu ly Room:
                    --Danh dau room  cho cac tai khoan co room dac biet
                  --IF FN_ISPRIVATEROOM( p_txmsg.txfields('07').value,p_txmsg.txfields('80').value)=TRUE THEN
                      if FN_ROOMPRINUSEDLOG('D',
                              to_number(p_txmsg.txfields('13').value), p_txmsg.txfields('07').value,p_txmsg.txfields('80').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                      end if;
                 -- END IF;
                  -- Xu ly Pool:
                 L_ORDERID:=p_txmsg.txfields('03').VALUE;
                BEGIN
                      l_days:=fn_get_nextdate(l_currdate,l_clearday)- l_currdate;
                      SELECT nvl(adt.advrate,0) ,nvl((CASE WHEN cf.vat='Y'  THEN 1 ELSE 0 END),0)  ,nvl((CASE WHEN cf.whtax ='Y' THEN 1 ELSE 0 END),0)
                      INTO l_advrate ,l_isvat ,l_iswhtax
                      FROM aftype aft, afmast af,adtype adt ,cfmast cf
                      WHERE af.actype=aft.actype AND aft.adtype=adt.actype
                      AND af.custid=cf.custid
                      AND af.acctno=  p_txmsg.txfields('07').value;
                EXCEPTION WHEN OTHERS THEN
                       l_days:=0;
                       l_advrate:=0;
                END;
                l_amt:=   to_number(p_txmsg.txfields('14').value)
                              *(1-(L_RATIO/100-1) -(l_whtax*l_iswhtax +l_advsellduty*l_ISVAT))
                              /(1+L_days/360*l_advrate/100);

                  if fn_SecuredUpdate('D', l_amt, p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                  end if;
          else -- Reverser Transactions
              -- Xu ly Room:
                  --IF FN_ISPRIVATEROOM( p_txmsg.txfields('07').value,p_txmsg.txfields('80').value)=TRUE THEN
                      if FN_ROOMPRINUSEDLOG('C',
                              to_number(p_txmsg.txfields('13').value), p_txmsg.txfields('07').value,p_txmsg.txfields('80').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                      end if;
                 -- END IF;
                  -- Xu ly Pool:
                  if fn_SecuredUpdate('C',TO_NUMBER(p_txmsg.txfields('14').value)*L_RATIO/100, p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                  end if;
          end if;
      /*ELSE---- lenh mua, ghi them vao log EX phuc vu tinh gia tri pool su dung tren phan thuc da khop
           L_ORDERID:=p_txmsg.txfields('03').VALUE;
           BEGIN
             -- SELECT TXNUM,TXDATE INTO L_TXNUM,L_TXDATE FROM ODMAST WHERE ORDERID=L_ORDERID;
              \* if fn_SecuredUpdate_EX('C',TO_NUMBER(p_txmsg.txfields('14').value)*L_RATIO/100, p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
               end if;*\
           EXCEPTION WHEN OTHERS THEN
                      L_TXNUM:=NULL;
                      L_TXDATE:=NULL;
           END ;*/


      END IF;
    elsIF p_txmsg.tltxcd in ('8808','8811','8852') THEN -- Giai toa lenh mua
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            -- Xu ly Room: (RELEASE ROOM)
            -- Xu ly Pool:
            if fn_SecuredUpdate('C', to_number(p_txmsg.txfields('11').value), p_txmsg.txfields('05').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reversal Transactions
            -- Xu ly Room: (RELEASE ROOM)
            -- Xu ly Pool:
            if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('11').value), p_txmsg.txfields('05').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('2242') THEN -- nhan chuyen khoan chung khoan
        null;
        -- Xu ly Pool:
    elsIF p_txmsg.tltxcd in ('8876','8874') THEN -- dat lenh mua
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            --Danh dau room  cho cac tai khoan co room dac biet
           -- IF FN_ISPRIVATEROOM( p_txmsg.txfields('03').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('D',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('03').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            --END IF;
            -- Xu ly Pool:
            if fn_SecuredUpdate('D',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value)
                        , p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        else -- Reversal Transactions
            --Danh dau room
          -- IF FN_ISPRIVATEROOM( p_txmsg.txfields('03').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('C',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('03').value, p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
           -- END IF;
            -- Xu ly Pool:
            if fn_SecuredUpdate('C',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value)
                        , p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('8884') THEN -- sua lenh mua
          -- lenh goc
          SELECT ORDERQTTY,quoteprice*(orderqtty-execqtty) ,execqtty
          INTO L_QTTY,l_oldamt,l_execqtty
          FROM ODMAST WHERE ORDERID=p_txmsg.txfields('08').VALUE;
          l_amt:=((to_number(p_txmsg.txfields('12').value)-l_execqtty)*to_number(p_txmsg.txfields('98').value)
                 *to_number(p_txmsg.txfields('11').value)-l_oldamt)*  to_number(p_txmsg.txfields('13').value)/100;


          L_QTTY:=TO_NUMBER(p_txmsg.txfields('12').value)-L_QTTY;
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            --Danh dau room  cho cac tai khoan co room dac biet
            IF L_QTTY <> 0 /*AND FN_ISPRIVATEROOM( p_txmsg.txfields('03').value,p_txmsg.txfields('01').value)=TRUE*/ THEN
                if FN_ROOMPRINUSEDLOG('D',
                        L_QTTY, p_txmsg.txfields('03').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            END IF;
            -- Xu ly Pool:
            IF l_amt>0 THEN
              if fn_SecuredUpdate('D',l_amt, p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                  plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                  RETURN errnums.C_BIZ_RULE_INVALID;
              end if;
            END IF;
        else -- Reversal Transactions
            --Danh dau room
           --IF FN_ISPRIVATEROOM( p_txmsg.txfields('03').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('C',
                        L_QTTY, p_txmsg.txfields('03').value, p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
          --  END IF;
            -- Xu ly Pool:
            if fn_SecuredUpdate('C',
                        to_number(p_txmsg.txfields('11').value) * L_QTTY * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value)
                        , p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('8882') THEN -- Huy lenh mua thong thuong
        if p_txmsg.deltd <> 'Y' then -- Normal Transaction
          --IF FN_ISPRIVATEROOM( p_txmsg.txfields('03').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('C',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('03').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
           -- END IF;
            -- Xu ly Pool:
            BEGIN
               SELECT CANCELSTATUS INTO L_EDSTATUS  FROM ODMAST
               WHERE ORDERID=p_txmsg.txfields('08').VALUE;
            EXCEPTION WHEN OTHERS THEN
               L_EDSTATUS:='N';
            END;
            IF L_EDSTATUS='X' THEN
                  if fn_SecuredUpdate('C',
                              to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value)
                              , p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code, to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value)) <> systemnums.c_success then
                      plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                      RETURN errnums.C_BIZ_RULE_INVALID;
                  end if;
            END IF;
        else -- Reversal Transactions
            --IF FN_ISPRIVATEROOM( p_txmsg.txfields('03').value,p_txmsg.txfields('01').value)=TRUE THEN
                if FN_ROOMPRINUSEDLOG('D',
                        to_number(p_txmsg.txfields('12').value), p_txmsg.txfields('03').value,p_txmsg.txfields('01').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            ---END IF;
            -- Xu ly Pool:
            if fn_SecuredUpdate('D',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value)
                        , p_txmsg.txfields('03').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('5566') THEN -- giai ngan LN: bao lanh, margin; Buoc xu ly batch, khong thuc hien, vi sau do se duoc danh sau lai.

        null;

    elsIF p_txmsg.tltxcd in ('5567') THEN -- tra no giai ngan LN: bao lanh, margin; Buoc xu ly batch, khong thuc hien, vi sau do se duoc danh sau lai.
        null;
    elsIF p_txmsg.tltxcd in ('8809') THEN -- khop lenh manual
    --  PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8809 end');
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            -- Xu ly Room:
            if p_txmsg.txfields('83').value = 'S' THEN
                  --Danh dau room  cho cac tai khoan co room dac biet
               -- IF FN_ISPRIVATEROOM( p_txmsg.txfields('04').value,p_txmsg.txfields('80').value)=TRUE THEN
                    if FN_ROOMPRINUSEDLOG('C',
                            to_number(p_txmsg.txfields('11').value), p_txmsg.txfields('04').value,p_txmsg.txfields('80').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                --END IF;
                -- Xu ly Pool:
                -- PLOG.ERROR(pkgctx, 'PhuongHT: fn_txAutoAdhocUpdate:8809 02 end' || p_txmsg.txfields('04').value);
                L_ORDERID:=p_txmsg.txfields('03').VALUE;
                BEGIN
                      SELECT CASE WHEN sts.cleardate-l_CurrDate= 0 THEN 1 ELSE sts.cleardate-l_currdate END
                      INTO l_days
                      FROM stschd    sts
                      where orgorderid=l_orderid AND duetype='RM'
                      AND deltd <> 'Y';

                      SELECT adt.advrate ,(CASE WHEN cf.vat='Y'   THEN 1 ELSE 0 END),(CASE WHEN  cf.whtax = 'Y'  THEN 1 ELSE 0 END),AFT.ADVPRIO
                      INTO l_advrate ,l_isvat,l_iswhtax,L_ADVPRIO
                      FROM aftype aft, afmast af,adtype adt ,cfmast cf
                      WHERE af.actype=aft.actype AND aft.adtype=adt.actype
                      AND af.custid=cf.custid
                      AND af.acctno=  p_txmsg.txfields('04').value;
                EXCEPTION WHEN OTHERS THEN
                       l_days:=0;
                       l_advrate:=0;
                END;
                IF L_ADVPRIO='Y' THEN
                    l_amt:=   to_number(p_txmsg.txfields('10').value)*to_number(p_txmsg.txfields('11').value)
                                  *(1-(to_number(p_txmsg.txfields('15').value)/100-1) -(l_isvat*l_advsellduty+l_iswhtax*l_whtax)/100)
                                  /(1+L_days/360*l_advrate/100);
                    if fn_SecuredUpdate('C',l_amt, p_txmsg.txfields('04').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                        plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                END IF;
            ELSE -- lenh mua
                        L_ORDERID:=p_txmsg.txfields('03').VALUE;
                     /*BEGIN
                        SELECT TXNUM,TXDATE INTO L_TXNUM,L_TXDATE FROM ODMAST WHERE ORDERID=L_ORDERID;
                        if fn_SecuredUpdate_EX('D', to_number(p_txmsg.txfields('10').value)*to_number(p_txmsg.txfields('11').value)*to_number(p_txmsg.txfields('15').value)/100,
                        p_txmsg.txfields('04').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                              plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                              RETURN errnums.C_BIZ_RULE_INVALID;
                        end if;
                     EXCEPTION WHEN OTHERS THEN
                                L_TXNUM:=NULL;
                                L_TXDATE:=NULL;
                     END ;*/

            end if;
        else -- Reversal Transactions
            -- Xu ly Room:
            if p_txmsg.txfields('83').value = 'S' THEN
                   --Danh dau room  cho cac tai khoan co room dac biet
               -- IF FN_ISPRIVATEROOM( p_txmsg.txfields('04').value,p_txmsg.txfields('80').value)=TRUE THEN
                    if FN_ROOMPRINUSEDLOG('D',
                            to_number(p_txmsg.txfields('11').value), p_txmsg.txfields('04').value,p_txmsg.txfields('80').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
              --  END IF;
                -- Xu ly Pool:
                if fn_SecuredUpdate('D', to_number(p_txmsg.txfields('10').value)*to_number(p_txmsg.txfields('11').value)*to_number(p_txmsg.txfields('15').value)/100,
                        p_txmsg.txfields('04').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('2652') THEN -- Nop bo sung chung khoan
        -- Xu ly Room:
        null;
    elsIF p_txmsg.tltxcd in ('2673') THEN -- Tao deal vay DF
        -- Xu ly Room:
        null;
    elsIF p_txmsg.tltxcd in ('2674') THEN -- Giai ngan DF
        -- Xu ly Room:
        null;
    elsIF p_txmsg.tltxcd in ('8895','8897') THEN -- 8895: chuyen lenh mua, 8897: sua lenh mua
        if p_txmsg.deltd <> 'Y' then -- Normal Transactions
            --  Xu ly Room:
            --1. Xu ly tieu khoan chuyen.
            --- Pool:
            ---- Xu ly tieu khoan chuyen:
            if p_txmsg.tltxcd = '8895' then
                if fn_SecuredUpdate('C',
                        (to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                        p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8897' then
                if fn_SecuredUpdate('C',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                        p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            ---- Xu ly tieu khoan nhan:
            if p_txmsg.tltxcd = '8895' then
                if fn_SecuredUpdate('D',
                        (to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8897' then
                if fn_SecuredUpdate('D',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                        p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        else
            --  Xu ly Room:
            --1. Xu ly tieu khoan chuyen.
                        --- Pool:
            ---- Xu ly tieu khoan chuyen:
            if p_txmsg.tltxcd = '8895' then
                if fn_SecuredUpdate('D',
                        (to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                        p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8897' then
                if fn_SecuredUpdate('D',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                        p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            ---- Xu ly tieu khoan nhan:
            if p_txmsg.tltxcd = '8895' then
                if fn_SecuredUpdate('C',
                        (to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8897' then
                if fn_SecuredUpdate('C',
                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                        p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('8896','8898') THEN -- 8896:Chuyen lenh khop ban; 8898:Sua loi lenh ban
        if p_txmsg.deltd <> 'Y' then
            --  Xu ly Room:
            --1. Xu ly tieu khoan chuyen.
            --  Xu ly Pool:
            --1.    Xu ly tieu khoan chuyen:
            if p_txmsg.tltxcd = '8896' then
                if fn_SecuredUpdate('D',
                       (to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8898' then
                if fn_SecuredUpdate('D',
                       to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;


            --2. Xu ly tieu khoan nhan:
            if p_txmsg.tltxcd = '8896' then
                if fn_SecuredUpdate('C',
                       to_number(p_txmsg.txfields('15').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8898' then
                if fn_SecuredUpdate('C',
                       to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        else -- Reversal Transactions
            --  Xu ly Room:
            --1. Xu ly tieu khoan chuyen.

            --  Xu ly Pool:
            --1.    Xu ly tieu khoan chuyen:
            if p_txmsg.tltxcd = '8896' then
                if fn_SecuredUpdate('C',
                       (to_number(p_txmsg.txfields('14').value) + to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8898' then
                if fn_SecuredUpdate('C',
                       to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('08').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;


            --2. Xu ly tieu khoan nhan:
            if p_txmsg.tltxcd = '8896' then
                if fn_SecuredUpdate('D',
                       to_number(p_txmsg.txfields('15').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
            if p_txmsg.tltxcd = '8898' then
                if fn_SecuredUpdate('D',
                       to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),
                       p_txmsg.txfields('07').value, p_txmsg.txnum, p_txmsg.txdate, p_err_code) <> systemnums.c_success then
                    plog.setendsection(pkgctx, 'fn_txAutoAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                end if;
            end if;
        end if;
      -- Xu ly dac biet.
    END IF;

    plog.setendsection (pkgctx, 'fn_txAutoAdhocUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    p_err_code:=errnums.C_SYSTEM_ERROR;
    plog.error(pkgctx,'error:'||p_err_code);
    plog.setendsection (pkgctx, 'fn_txAutoAdhocUpdate');
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_txAutoAdhocUpdate;

/**
* Kiem tra nguon theo xu ly dac biet. Ham goi di theo giao dich.
**/
FUNCTION fn_txAutoAdhocCheck(p_txmsg in tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS

/*l_count number;
l_maxdebt number;
l_amt number;
l_amt2 number;
l_actype varchar2(4);
l_type varchar2(100);
l_BrID  varchar2(4);
l_IsMarginAccount char(1);*/
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAutoAdhocCheck');
    p_err_code:=systemnums.C_SUCCESS;
    /*IF p_txmsg.tltxcd in ('2200','2202','2232','2242','2243','2244','2250') THEN
        begin
            select
                sum (nvl(pr.prinused,0)* least(nvl(rsk2.mrpriceloan,0), sb.marginrefprice) * nvl(rsk2.mrratioloan,0) / 100)
                - sum((se.trade - nvl(sts.execsellqtty,0) + nvl(od.buyqtty,0) + nvl(sts.execbuyqtty,0)
                    - (case when se.codeid = p_txmsg.txfields('01').value then to_number(p_txmsg.txfields('10').value) else 0 end)) * least(nvl(rsk2.mrpriceloan,0), sb.marginrefprice) * nvl(rsk2.mrratioloan,0) / 100)
                ,
                sum (nvl(pr.sy_prinused,0)* least(nvl(rsk1.mrpriceloan,0), sb.marginprice) * nvl(rsk1.mrratioloan,0) / 100)
                - sum((se.trade - nvl(sts.execsellqtty,0) + nvl(od.buyqtty,0) + nvl(sts.execbuyqtty,0)
                    - (case when se.codeid = p_txmsg.txfields('01').value then to_number(p_txmsg.txfields('10').value) else 0 end)) * least(nvl(rsk1.mrpriceloan,0), sb.marginrefprice) * nvl(rsk1.mrratioloan,0) / 100)

                into l_amt, l_amt2
                from (select se.afacctno, se.codeid, af.actype, se.trade from semast se, afmast af, aftype aft, mrtype mrt
                        where se.afacctno = af.acctno and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T') se,
                     securities_info sb,
                     afserisk rsk1,afmrserisk rsk2,
                    (select afacctno, codeid,
                        sum(case when duetype = 'SS' then qtty - decode(status,'C',qtty,aqtty) else 0 end) execsellqtty,
                        sum(case when duetype = 'RS' then qtty - decode(status,'C',qtty,aqtty) else 0 end) execbuyqtty
                        from stschd
                        where duetype in ('SS','RS') and afacctno = p_txmsg.txfields('02').value and deltd <> 'Y'
                        group by afacctno, codeid) sts,
                    (select afacctno, codeid,
                        sum(case when exectype = 'NB' then remainqtty else 0 end) buyqtty
                        from odmast
                        where exectype = 'NB' and afacctno = p_txmsg.txfields('02').value and deltd <> 'Y'
                        group by afacctno, codeid) od,
                    (select afpr.afacctno, pr.codeid, sum(nvl(afpr.prinused,0)) prinused, sum(nvl(afpr.sy_prinused,0)) sy_prinused,
                       max(nvl(pr.roomlimit,0)) - sum(nvl(afpr.prinused,0)) pravllimit
                           from (select afacctno, codeid, sum(case when restype = 'M' then prinused else 0 end) prinused,
                                    sum(case when restype = 'S' then prinused else 0 end) sy_prinused
                                   from vw_afpralloc_all
                                   where afacctno = p_txmsg.txfields('02').value
                                   group by afacctno,codeid) afpr, vw_marginroomsystem pr
                           where afpr.codeid(+) = pr.codeid
                           group by afpr.afacctno, pr.codeid
                        ) pr
                where se.afacctno = p_txmsg.txfields('02').value
                and se.afacctno = sts.afacctno(+) and se.codeid = sts.codeid(+)
                and se.afacctno = od.afacctno(+) and se.codeid = od.codeid(+)
                and se.afacctno = pr.afacctno(+) and se.codeid = pr.codeid(+)
                and se.actype = rsk1.actype(+) and se.codeid = rsk1.codeid(+)
                and se.actype = rsk2.actype(+) and se.codeid = rsk2.codeid(+)
                and sb.codeid = se.codeid
                group by se.afacctno;
        exception when others then
            l_amt:=0;
            l_amt2:=0;
        end;
        if (l_amt > 0 and l_amt2 > 0) then
            p_err_code:= '-100523';
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    ELSIF p_txmsg.tltxcd in ('8876','8874') THEN

        select count(1) into l_count
        from cfmast cf, afmast af
        where cf.custid = af.custid
        and af.acctno = p_txmsg.txfields('03').value and cf.custatcom = 'Y';

        if l_count > 0 then

            l_maxdebt:=to_number(cspks_system.fn_get_sysvar('MARGIN','MAXDEBT'));
            --Chi danh dau voi tai khoan Margin, co tuan thu muc he thong.
            select count(1) into l_count
            from afmast af, aftype aft, mrtype mrt, lntype lnt
            where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
            and aft.lntype = lnt.actype(+) and nvl(lnt.chksysctrl,'N') = 'Y' and af.acctno = p_txmsg.txfields('03').value;

            if l_count = 0 then
                l_IsMarginAccount:='N';
            else
                l_IsMarginAccount:='Y';
            end if;

            select
                least(-least(nvl(adv.avladvance,0)
                        + mst.balance
                        - mst.odamt
                        - mst.dfdebtamt
                        - mst.dfintdebtamt
                        - mst.depofeeamt
                        - NVL (advamt, 0)
                        - nvl(secureamt,0)
                        - ramt
                        - nvl(dealpaidamt,0)
                        - to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),0),

                        to_number(p_txmsg.txfields('11').value) * to_number(p_txmsg.txfields('12').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value))
                into l_amt
            from cimast mst
                left join (select * from v_getbuyorderinfo where afacctno = p_txmsg.txfields('03').value) al on mst.acctno = al.afacctno
                left join (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = p_txmsg.txfields('03').value group by afacctno) adv on adv.afacctno=MST.acctno
                LEFT JOIN (select * from v_getdealpaidbyaccount p where p.afacctno = p_txmsg.txfields('03').value) pd on pd.afacctno=mst.acctno
            where mst.acctno = p_txmsg.txfields('03').value;
            plog.debug(pkgctx,'l_amt:'||l_amt);
            if l_amt > 0 then
                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_txmsg.txfields('03').value;

                 FOR rec_pr IN (
                        SELECT DISTINCT pm.prcode, pm.prname, pm.prtyp, pm.codeid, pm.prlimit,
                                pm.prinused + fn_getExpectUsed(pm.prcode) prinused, pm.expireddt, pm.prstatus
                        FROM prmaster pm,  prtype prt, prtypemap prtm, typeidmap tpm, bridmap brm
                        WHERE pm.prcode = brm.prcode
                            AND pm.prcode = prtm.prcode
                            AND prt.actype = prtm.prtype
                            AND prt.actype = tpm.prtype
                            AND pm.prtyp = 'P'
                            AND ((prt.TYPE = 'AFTYPE') or (l_IsMarginAccount = 'Y' and prt.TYPE = 'SYSTEM'))
                            AND pm.prstatus = 'A'
                            AND tpm.typeid = decode(tpm.typeid,'ALL',tpm.typeid,l_actype)
                            AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                               )
                 LOOP
                    if l_amt > least(rec_pr.prlimit,l_maxdebt) - rec_pr.prinused then
                       p_err_code := '-100522'; --Vuot qua nguon.
                       plog.debug(pkgctx,'PRCHK: [-100522]:Loi vuot qua nguon tien:' || p_err_code);
                       plog.setendsection(pkgctx, 'fn_txAutoAdhocCheck');
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                 end loop;
            end if;
        end if;
    elsIF p_txmsg.tltxcd in ('8895') THEN
        select count(1) into l_count
        from cfmast cf, afmast af
        where cf.custid = af.custid
        and af.acctno = p_txmsg.txfields('08').value and cf.custatcom = 'Y';

        if l_count > 0 then

            l_maxdebt:=to_number(cspks_system.fn_get_sysvar('MARGIN','MAXDEBT'));
            --Chi danh dau voi tai khoan Margin, co tuan thu muc he thong.
            select count(1) into l_count
            from afmast af, aftype aft, mrtype mrt, lntype lnt
            where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
            and aft.lntype = lnt.actype(+) and nvl(lnt.chksysctrl,'N') = 'Y' and af.acctno = p_txmsg.txfields('08').value;
            --Neu Tieu khoan khong danh dau bat buoc tuan thu he thong hoac ko phai lai tieu khoan margin -> Khong can hach toan nguon.
            if l_count = 0 then
                --return systemnums.C_SUCCESS;
                l_IsMarginAccount:='N';
            else
                l_IsMarginAccount:='Y';
            end if;


            select
                least(-least(nvl(adv.avladvance,0)
                        + mst.balance
                        - mst.odamt
                        - mst.dfdebtamt
                        - mst.dfintdebtamt
                        - mst.depofeeamt
                        - NVL (advamt, 0)
                        - nvl(secureamt,0)
                        - ramt
                        - nvl(dealpaidamt,0)
                        - (to_number(p_txmsg.txfields('14').value)+to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),0),

                        (to_number(p_txmsg.txfields('14').value)+to_number(p_txmsg.txfields('15').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value))
                into l_amt
            from cimast mst
            left join (select * from v_getbuyorderinfo where afacctno = p_txmsg.txfields('08').value) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = p_txmsg.txfields('08').value group by afacctno) adv on adv.afacctno=MST.acctno
            LEFT JOIN (select * from v_getdealpaidbyaccount p where p.afacctno = p_txmsg.txfields('08').value) pd on pd.afacctno=mst.acctno
            where mst.acctno = p_txmsg.txfields('08').value;
            plog.debug(pkgctx,'l_amt:'||l_amt);
            if l_amt > 0 then
                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_txmsg.txfields('08').value;

                 FOR rec_pr IN (
                        SELECT DISTINCT pm.prcode, pm.prname, pm.prtyp, pm.codeid, pm.prlimit,
                                pm.prinused + fn_getExpectUsed(pm.prcode) prinused, pm.expireddt, pm.prstatus
                        FROM prmaster pm,  prtype prt, prtypemap prtm, typeidmap tpm, bridmap brm
                        WHERE pm.prcode = brm.prcode
                            AND pm.prcode = prtm.prcode
                            AND prt.actype = prtm.prtype
                            AND prt.actype = tpm.prtype
                            AND pm.prtyp = 'P'
                            AND ((prt.TYPE = 'AFTYPE') or (l_IsMarginAccount = 'Y' and prt.TYPE = 'SYSTEM'))
                            AND pm.prstatus = 'A'
                            AND tpm.typeid = decode(tpm.typeid,'ALL',tpm.typeid,l_actype)
                            AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                               )
                 LOOP
                    if l_amt > least(rec_pr.prlimit,l_maxdebt) - rec_pr.prinused then
                       p_err_code := '-100522'; --Vuot qua nguon.
                       plog.debug(pkgctx,'PRCHK: [-100522]:Loi vuot qua nguon tien:' || p_err_code);
                       plog.setendsection(pkgctx, 'fn_txAutoAdhocCheck');
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                 end loop;
             end if;
         end if;
    elsIF p_txmsg.tltxcd in ('8897') THEN
        select count(1) into l_count
        from cfmast cf, afmast af
        where cf.custid = af.custid
        and af.acctno = p_txmsg.txfields('08').value and cf.custatcom = 'Y';
        if l_count > 0 then

            l_maxdebt:=to_number(cspks_system.fn_get_sysvar('MARGIN','MAXDEBT'));
            --Chi danh dau voi tai khoan Margin, co tuan thu muc he thong.
            select count(1) into l_count
            from afmast af, aftype aft, mrtype mrt, lntype lnt
            where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
            and aft.lntype = lnt.actype(+) and nvl(lnt.chksysctrl,'N') = 'Y' and af.acctno = p_txmsg.txfields('08').value;
            --Neu Tieu khoan khong danh dau bat buoc tuan thu he thong hoac ko phai lai tieu khoan margin -> Khong can hach toan nguon.
            if l_count = 0 then
                --return systemnums.C_SUCCESS;
                l_IsMarginAccount:='N';
            else
                l_IsMarginAccount:='Y';
            end if;

            select
                least(-least(nvl(adv.avladvance,0)
                        + mst.balance
                        - mst.odamt
                        - mst.dfdebtamt
                        - mst.dfintdebtamt
                        - mst.depofeeamt
                        - NVL (advamt, 0)
                        - nvl(secureamt,0)
                        - ramt
                        - nvl(dealpaidamt,0)
                        - (to_number(p_txmsg.txfields('11').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value),0),

                        (to_number(p_txmsg.txfields('11').value)) * to_number(p_txmsg.txfields('10').value) * to_number(p_txmsg.txfields('13').value)/100 * to_number(p_txmsg.txfields('98').value))
                into l_amt
            from cimast mst
            left join (select * from v_getbuyorderinfo where afacctno = p_txmsg.txfields('08').value) al on mst.acctno = al.afacctno
            left join (select sum(depoamt) avladvance,afacctno from v_getAccountAvlAdvance where afacctno = p_txmsg.txfields('08').value group by afacctno) adv on adv.afacctno=MST.acctno
            LEFT JOIN (select * from v_getdealpaidbyaccount p where p.afacctno = p_txmsg.txfields('08').value) pd on pd.afacctno=mst.acctno
            where mst.acctno = p_txmsg.txfields('08').value;
            plog.debug(pkgctx,'l_amt:'||l_amt);
            if l_amt > 0 then
                select actype, substr(acctno,1,4) into l_actype, l_BrID from afmast where acctno = p_txmsg.txfields('08').value;

                 FOR rec_pr IN (
                        SELECT DISTINCT pm.prcode, pm.prname, pm.prtyp, pm.codeid, pm.prlimit,
                                pm.prinused + fn_getExpectUsed(pm.prcode) prinused, pm.expireddt, pm.prstatus
                        FROM prmaster pm,  prtype prt, prtypemap prtm, typeidmap tpm, bridmap brm
                        WHERE pm.prcode = brm.prcode
                            AND pm.prcode = prtm.prcode
                            AND prt.actype = prtm.prtype
                            AND prt.actype = tpm.prtype
                            AND pm.prtyp = 'P'
                            AND ((prt.TYPE = 'AFTYPE') or (l_IsMarginAccount = 'Y' and prt.TYPE = 'SYSTEM'))
                            AND pm.prstatus = 'A'
                            AND tpm.typeid = decode(tpm.typeid,'ALL',tpm.typeid,l_actype)
                            AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_BrID)
                               )
                 LOOP
                    if l_amt > least(rec_pr.prlimit,l_maxdebt) - rec_pr.prinused then
                       p_err_code := '-100522'; --Vuot qua nguon.
                       plog.debug(pkgctx,'PRCHK: [-100522]:Loi vuot qua nguon tien:' || p_err_code);
                       plog.setendsection(pkgctx, 'fn_txAutoAdhocCheck');
                       RETURN errnums.C_BIZ_RULE_INVALID;
                    end if;
                 end loop;
             end if;
            -- Xu ly dac biet.
        END IF;
    end if;*/
    plog.setendsection (pkgctx, 'fn_txAutoAdhocCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    p_err_code:=errnums.C_SYSTEM_ERROR;
    plog.error(pkgctx,'error:'||p_err_code);
    plog.setendsection (pkgctx, 'fn_txAutoAdhocCheck');
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_txAutoAdhocCheck;

/**
* Cap nhat gia tri nguon du tinh theo xu ly dac biet. Ham goi Adhoc.
**/
FUNCTION fn_txAdhocUpdate(p_id IN VARCHAR2,
            p_acctno IN VARCHAR2, p_codeid IN VARCHAR2,
            p_refid IN VARCHAR2,
            p_qtty IN NUMBER, p_amt IN NUMBER,
            p_brid IN VARCHAR2,
            p_type IN VARCHAR2, p_actype IN VARCHAR2,
            p_txnum IN VARCHAR2, p_txdate IN DATE,
            p_deltd IN VARCHAR2,
            p_err_code out varchar2)
RETURN NUMBER
IS
l_count NUMBER;
l_TotalUsedQtty NUMBER;
l_AcType varchar2(4);
l_sumexecqtty NUMBER;
l_trade NUMBER;
l_UsedQtty NUMBER;
l_UsedAmt NUMBER;

l_CurrDate  DATE;
l_ClearDate DATE;
l_AIntRate NUMBER;
l_AMinBal NUMBER;
l_AFeeBank NUMBER;
l_AMinFeeBank NUMBER;
l_brid varchar2(4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAdhocUpdate');
    p_err_code:=systemnums.C_SUCCESS;
    /*l_CurrDate:= to_date(cspks_system.fn_get_sysvar('SYSTEM', 'CURRDATE'),systemnums.c_date_format);
    l_AIntRate:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AINTRATE'));
    l_AMinBal:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AMINBAL'));
    l_AFeeBank:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AFEEBANK'));
    l_AMinFeeBank:= to_number(cspks_system.fn_get_sysvar('SYSTEM', 'AMINFEEBANK'));

    l_TotalUsedQtty:=0;
    IF p_id = 'SELLORDERMATCH' THEN

        --Xac dinh deal ban.
        SELECT sum(execqtty) INTO l_sumexecqtty
        FROM odmast
        WHERE txdate = l_CurrDate AND exectype IN ('MS','NS') AND execqtty > 0
        AND afacctno = p_acctno AND codeid = p_codeid;

        select substr(p_acctno,1,4) into l_brid from dual;

        l_sumexecqtty:=l_sumexecqtty - p_qtty;
        -- Over deal
        FOR rec_ovd IN
        (
            SELECT dfqtty, nml, ovd, df.actype, (dfqtty + blockqtty + rcvqtty + carcvqtty + rlsqtty) orgqtty,
            rlsqtty, rlsamt,
            (dfqtty + blockqtty + rcvqtty + carcvqtty) remainqtty
            FROM dfmast df, lnschd ls, securities_info sb
            WHERE df.lnacctno = ls.acctno AND ls.reftype = 'P' AND df.dfqtty > 0
            AND df.afacctno = p_acctno AND df.codeid = p_codeid
            AND sb.codeid = df.codeid
            AND ((flagtrigger = 'T' OR sb.basicprice <= df.triggerprice) OR (ls.overduedate <= l_CurrDate))
            order BY CASE WHEN flagtrigger = 'T' OR sb.basicprice <= df.triggerprice THEN 0
                            WHEN ls.overduedate < l_CurrDate THEN 1
                            WHEN ls.overduedate = l_CurrDate THEN 2
                            ELSE 3 END,
                     ls.overduedate
        )
        LOOP
            IF l_sumexecqtty >= 0 THEN
                l_sumexecqtty:=l_sumexecqtty - rec_ovd.dfqtty;
            END IF;
            if l_sumexecqtty < 0 AND p_qtty > l_TotalUsedQtty then  -- Gia tri khop roi vao deal ban bi canh bao
                l_UsedQtty:= least(p_qtty - l_TotalUsedQtty, CASE WHEN l_TotalUsedQtty = 0 THEN -l_sumexecqtty ELSE rec_ovd.dfqtty END);
                l_UsedAmt:= greatest((rec_ovd.nml + rec_ovd.ovd) - ((rec_ovd.nml + rec_ovd.ovd + rec_ovd.rlsamt)
                                                            / rec_ovd.orgqtty
                                                            * (rec_ovd.remainqtty - l_UsedQtty)),
                                    0);
                l_TotalUsedQtty:= l_TotalUsedQtty + l_UsedQtty;

                --room: l_UsedQtty
                IF fn_SecuredUpdate(p_txnum, p_txdate, p_deltd,
                            'C', l_UsedQtty, p_acctno, p_codeid, 'R', 'DFTYPE', rec_ovd.actype, l_brid, p_refid, p_err_code)
                    <> systemnums.c_success THEN
                    p_err_code:=errnums.c_system_error;
                    plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
                --pool: (rec_ovd.nml + rec_ovd.ovd) - (rec_ovd.nml + rec_ovd.ovd + rec_ovd.rlsamt) / rec_ovd.orgqtty * (rec_ovd.remainqtty - l_UsedQtty)
                IF fn_SecuredUpdate(p_txnum, p_txdate, p_deltd,
                            'C', l_UsedAmt, p_acctno, p_codeid, 'P', 'DFTYPE', rec_ovd.actype, l_brid, p_refid, p_err_code)
                    <> systemnums.c_success THEN
                    p_err_code:=errnums.c_system_error;
                    plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
                    RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
            END IF;
        END LOOP;
        -- normal trade
        IF l_sumexecqtty > 0 OR p_qtty > l_TotalUsedQtty THEN
            SELECT trade INTO l_trade FROM semast WHERE afacctno = p_acctno and codeid = p_codeid;
            l_sumexecqtty:=l_sumexecqtty - l_trade;
            l_TotalUsedQtty:=l_TotalUsedQtty + least((p_qtty - l_TotalUsedQtty),l_trade);
        END IF;
        -- normal deal
        IF l_sumexecqtty > 0 OR p_qtty > l_TotalUsedQtty THEN
            FOR rec_nml IN
            (
                SELECT dfqtty, nml, ovd, df.actype, (dfqtty + blockqtty + rcvqtty + carcvqtty + rlsqtty) orgqtty,
                    rlsqtty, rlsamt,
                    (dfqtty + blockqtty + rcvqtty + carcvqtty) remainqtty
                FROM dfmast df, lnschd ls, securities_info sb
                WHERE df.lnacctno = ls.acctno AND ls.reftype = 'P' AND df.dfqtty > 0
                AND df.afacctno = p_acctno AND df.codeid = p_codeid
                AND sb.codeid = df.codeid
                AND flagtrigger <> 'T' AND sb.basicprice > df.triggerprice AND ls.overduedate > l_CurrDate
                order BY ls.overduedate
            )
            LOOP
                IF l_sumexecqtty >= 0 THEN
                    l_sumexecqtty:=l_sumexecqtty - rec_nml.dfqtty;
                END IF;
                if l_sumexecqtty < 0 AND p_qtty > l_TotalUsedQtty then  -- Gia tri khop roi vao deal ban bi canh bao
                    l_UsedQtty:= least(p_qtty - l_TotalUsedQtty, CASE WHEN l_TotalUsedQtty = 0 THEN -l_sumexecqtty ELSE rec_nml.dfqtty END);
                    l_UsedAmt:= greatest((rec_nml.nml + rec_nml.ovd) - ((rec_nml.nml + rec_nml.ovd + rec_nml.rlsamt)
                                                                / rec_nml.orgqtty
                                                                * (rec_nml.remainqtty - l_UsedQtty)),
                                        0);
                    l_TotalUsedQtty:= l_TotalUsedQtty + l_UsedQtty;
                    -- Tim nguon.
                    --room: l_UsedQtty
                    IF fn_SecuredUpdate(p_txnum, p_txdate, p_deltd,
                                'C', l_UsedQtty, p_acctno, p_codeid, 'R', 'DFTYPE', rec_nml.actype, l_brid, p_refid, p_err_code)
                        <> systemnums.c_success THEN
                        p_err_code:=errnums.c_system_error;
                        plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                    --pool: (rec_ovd.nml + rec_ovd.ovd) - (rec_ovd.nml + rec_ovd.ovd + rec_ovd.rlsamt) / rec_ovd.orgqtty * (rec_ovd.remainqtty - l_UsedQtty)
                    IF fn_SecuredUpdate(p_txnum, p_txdate, p_deltd,
                                'C', l_UsedAmt, p_acctno, p_codeid, 'P', 'DFTYPE', rec_nml.actype, l_brid, p_refid, p_err_code)
                        <> systemnums.c_success THEN
                        p_err_code:=errnums.c_system_error;
                        plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
                        RETURN errnums.C_BIZ_RULE_INVALID;
                    END IF;
                END IF;
            END LOOP;
        END IF;

    ELSIF p_id = 'BUYORDERMATCH' THEN
-- Margin Loan Matching Order

        --chi xet cho margin loan thoi.
        BEGIN
            SELECT aft.dftype INTO l_actype FROM afmast af, aftype aft, mrtype mrt
            WHERE af.actype = aft.actype AND aft.mrtype = mrt.actype AND mrt.mrtype = 'L' AND af.acctno = p_acctno;
        EXCEPTION WHEN OTHERS THEN
            plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
            RETURN systemnums.C_SUCCESS;
        END;

        -- Xac dinh so tien du tinh giai ngan cho lenh khop margin loan.
        l_UsedQtty:= p_qtty;
        SELECT p_amt * (1 + nvl(odt.deffeerate,0)/100 - od.bratio/100) INTO l_UsedAmt
        FROM odmast od, odtype odt
        WHERE od.actype = odt.actype(+) AND od.exectype IN ('NB') AND orderid = p_refid;


        IF l_UsedAmt = 0 AND l_UsedQtty = 0 THEN
            plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
            RETURN systemnums.C_SUCCESS;
        END IF;

        -- Tim nguon.
        --room: l_UsedQtty
        IF fn_SecuredUpdate(p_txnum, p_txdate, 'N',
                    'D', l_UsedQtty, p_acctno, p_codeid, 'R', 'DFTYPE', l_actype, l_brid, p_refid, p_err_code)
            <> systemnums.c_success THEN
            p_err_code:=errnums.c_system_error;
            plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        --pool: (rec_ovd.nml + rec_ovd.ovd) - (rec_ovd.nml + rec_ovd.ovd + rec_ovd.rlsamt) / rec_ovd.orgqtty * (rec_ovd.remainqtty - l_UsedQtty)
        IF fn_SecuredUpdate(p_txnum, p_txdate, 'N',
                    'D', l_UsedAmt, p_acctno, p_codeid, 'P', 'DFTYPE', l_actype, l_brid, p_refid, p_err_code)
            <> systemnums.c_success THEN
            p_err_code:=errnums.c_system_error;
            plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

    END IF;*/

    plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others THEN
    p_err_code:=errnums.C_SYSTEM_ERROR;
    plog.error(pkgctx,'error:'||p_err_code);
    plog.setendsection (pkgctx, 'fn_txAdhocUpdate');
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_txAdhocUpdate;

/**
* Kiem tra nguon theo xu ly dac biet. Ham goi Adhoc.
**/
FUNCTION fn_txAdhocCheck(p_id IN VARCHAR2,
            p_acctno IN VARCHAR2, p_codeid IN VARCHAR2,
            p_refid IN VARCHAR2,
            p_qtty IN NUMBER, p_amt IN NUMBER,
            p_brid IN VARCHAR2,
            p_type in VARCHAR2, p_actype IN VARCHAR2,
            p_txnum IN VARCHAR2, p_txdate IN DATE,
            p_deltd IN VARCHAR2,
            p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAdhocCheck');

    IF p_id = '######' THEN
        NULL;
    END IF;
    plog.setendsection (pkgctx, 'fn_txAdhocCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.setendsection (pkgctx, 'fn_txAdhocCheck');
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_txAdhocCheck;


FUNCTION fn_txAutoCheck(p_txmsg in tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS
        l_tltxcd PRCHK.tltxcd%TYPE;
        l_type PRCHK.TYPE%TYPE;
        l_typeid PRCHK.typeid%TYPE;
        l_typefldcd PRCHK.typefldcd%TYPE;
        l_bridtype PRCHK.bridtype%TYPE;
        l_prtype PRCHK.prtype%TYPE;
        l_accfldcd PRCHK.accfldcd%TYPE;
        l_dorc PRCHK.dorc%TYPE;
        l_amtexp PRCHK.amtexp%TYPE;
        l_acctno varchar2(30);
        l_brid varchar2(4);
        l_actype varchar2(10);
        l_value number(20,4);
        l_busdate DATE;
        l_codeid  varchar2(10);
        l_limitcheck number(20,0);
        l_hoststs char(1);
        l_count NUMBER;
        l_IsMarginAccount varchar2(1);
        l_lnaccfldcd varchar2(20);
        l_lntypefldcd varchar2(20);
        l_lntype varchar2(4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAutoCheck');

    -- EXCEPTION NO CHECK POOL/ROOM WHEN RUN batch.
    SELECT varvalue INTO l_hoststs FROM sysvar WHERE varname = 'HOSTATUS' AND grname = 'SYSTEM';
    IF l_hoststs = '0' THEN
        plog.setendsection (pkgctx, 'fn_txAutoCheck');
        RETURN systemnums.C_SUCCESS;
    END IF;
    -- END EXCEPTION NO CHECK POOL/ROOM WHEN RUN batch.

    IF fn_txAutoAdhocCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        plog.setendsection (pkgctx, 'fn_txAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- Get busdate
    SELECT to_date(varvalue,'DD/MM/RRRR') INTO l_busdate FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    FOR i IN
        (
            SELECT a.tltxcd, a.chktype, a.type, a.typeid, a.bridtype, a.prtype, a.accfldcd, a.dorc, a.amtexp, a.typefldcd, a.lnaccfldcd, a.lntypefldcd
            FROM prchk a WHERE a.tltxcd = p_txmsg.tltxcd and a.chktype='I' AND a.deltd <> 'Y' ORDER BY a.odrnum
        )
    LOOP
        l_tltxcd:=i.tltxcd;
        l_type:=i.TYPE;
        l_typeid:=i.typeid;
        l_typefldcd:=i.typefldcd;
        l_bridtype:=i.bridtype;
        l_prtype:=i.prtype;
        l_accfldcd:=i.accfldcd;
        l_dorc:=i.dorc;
        l_amtexp:=i.amtexp;
        l_lnaccfldcd:=i.lnaccfldcd;
        l_lntypefldcd:=i.lntypefldcd;
        --plog.debug (pkgctx, 'kiem tra cho Pool room cho giao dich:' || i.tltxcd);
        --TK CHECK pool room. (CI OR SE account)
        IF NOT l_accfldcd IS NULL AND length(l_accfldcd) > 0 THEN
            IF instr(l_accfldcd,'&') > 0 THEN
                l_acctno:= p_txmsg.txfields(substr(l_accfldcd,0,2)).value || p_txmsg.txfields(ltrim(substr(l_accfldcd,3),'&')).value;
            ELSE
                l_acctno:= p_txmsg.txfields(l_accfldcd).value;
            END IF;
        END IF;

        --Lay tham so chi nhanh. SBS don't use this parameter.
        IF l_bridtype = '0' THEN        --noi mo hop dong
            SELECT cf.brid into  l_BrID from afmast af, cfmast cf where  af.custid=cf.custid AND af.acctno = substr(l_acctno,0,10);
        ELSIF l_bridtype = '1' THEN     --noi lam giao dich
            l_brid:=p_txmsg.brid;
        ELSIF l_bridtype = '2' THEN     --careby tieu khoan.
            BEGIN
                SELECT tl.brid INTO l_brid
                FROM afmast af, tlprofiles tl
                WHERE af.tlid = tl.tlid AND af.acctno = substr(l_acctno,0,10);
            EXCEPTION WHEN OTHERS THEN
                l_brid:= substr(l_acctno,0,4);
            END;
            l_brid:=nvl(l_brid,substr(l_acctno,0,4));
        END IF;

        --Lay ma loai hinh san pham.
        IF NOT l_typeid IS NULL AND length(l_typeid) > 0 THEN
            -- get XXTYPE FROM XXMAST WHERE XXACCTNO = l_typeid
            IF l_type = 'DFTYPE' THEN
                SELECT actype INTO l_actype FROM dfmast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'LNTYPE' THEN
                SELECT actype INTO l_actype FROM lnmast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'CITYPE' THEN
                SELECT actype INTO l_actype FROM cimast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'SETYPE' THEN
                SELECT actype INTO l_actype FROM semast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'AFTYPE' THEN
                SELECT actype INTO l_actype FROM afmast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            end if;
        elsif not l_typefldcd is null and length(l_typefldcd) > 0 then
            --Get ACTYPE direct FROM Transactions.
            l_actype:= p_txmsg.txfields(l_typefldcd).value;
        END IF;
        --lay amount
        IF length(l_amtexp) > 0 THEN
            l_value:= fn_parse_amtexp(p_txmsg,l_amtexp);
        ELSE
            l_value:= 0;
        END IF;
        --lay CodeID.
        l_codeid:= substr(l_acctno,11,6);

        --Lay LNTYPE tu [LNACCFLDCD] or [LNTYPEFLDCD]
        if length(trim(l_lnaccfldcd))>0 then
            begin
                select actype into l_lntype from lnmast where acctno = p_txmsg.txfields(l_lnaccfldcd).value;
            exception when others then
                l_lntype:='XXXX';
            end;
        end if;
        if length(trim(l_lntypefldcd))>0 then
            begin
                l_lntype:= p_txmsg.txfields(l_lntypefldcd).value;
            exception when others then
                l_lntype:='XXXX';
            end;
        end if;

        --Danh dau pool
        --Neu Tieu khoan khong danh dau bat buoc tuan thu he thong hoac ko phai lai tieu khoan margin -> Khong can hach toan nguon POOL SYSTEM.
        select count(1) into l_count
        from afmast af, aftype aft, mrtype mrt, lntype lnt1
        where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
            and aft.lntype = lnt1.actype(+) and af.acctno = substr(l_acctno,0,10)
            and ((nvl(lnt1.chksysctrl,'N') = 'Y' and nvl(lnt1.actype,'ZZZZ') = l_lntype)
                or
                exists (select 1 from afidtype afi, lntype lnt2
                        where afi.actype = lnt2.actype and afi.objname = 'LN.LNTYPE' and afi.aftype = aft.actype and lnt2.actype = l_lntype and lnt2.chksysctrl= 'Y'));

        if l_count = 0 then
            l_IsMarginAccount:='N';
        else
            l_IsMarginAccount:='Y';
        end if;

        --Kiem tra theo san pham: l_actype; l_type; l_brid; l_codeid (chi xai cho tai khoan tien)
        -- Check Pool
        IF L_PRTYPE='P' THEN
              FOR rec IN (
                          SELECT * FROM
            -- Pool dac biet cho tieu khoan
            (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                    PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                    FROM PRMASTER PM
                   WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=l_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                   AND PM.prstatus='A'
                    and PM.prtyp='P'
            UNION ALL-- Pool dac biet cho danh sach khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                  FROM PRMASTER PM,PRAFMAP PRM
                  WHERE PM.POOLTYPE='GR'
                  AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=l_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                  AND PM.prstatus='A'
                  and PM.prtyp='P'
            UNION ALL-- Pool cho nhom loai hinh khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                  FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                  WHERE PM.PRCODE=BRM.PRCODE
                  AND pm.prcode = prtm.prcode
                  AND pm.prstatus = 'A'
                  AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                  --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                  AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                  and PM.prtyp='P'
                  AND pm.pooltype='TY'
            UNION ALL
                --PooL he thong
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                FROM PRMASTER PM
                WHERE  PM.POOLTYPE='SY'

                AND PM.prstatus='A'
                and PM.prtyp='P'
              )
WHERE odr=
( SELECT  min(odr) FROM
                          -- Pool dac biet cho tieu khoan
                          (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                  PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                                  FROM PRMASTER PM
                                 WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=l_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                 AND PM.prstatus='A'
                                  and PM.prtyp='P'
                          UNION ALL-- Pool dac biet cho danh sach khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                                FROM PRMASTER PM,PRAFMAP PRM
                                WHERE PM.POOLTYPE='GR'
                                AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=l_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                AND PM.prstatus='A'
                                and PM.prtyp='P'
                          UNION ALL-- Pool cho nhom loai hinh khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                                FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                                WHERE PM.PRCODE=BRM.PRCODE
                                AND pm.prcode = prtm.prcode
                                AND pm.prstatus = 'A'
                                AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                                --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                                AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                                and PM.prtyp='P'
                                AND pm.pooltype='TY'
                          UNION ALL
                              --PooL he thong
                              SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ fn_getExpectUsed(pm.prcode) prinused,
                              PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                              FROM PRMASTER PM
                              WHERE  PM.POOLTYPE='SY'

                              AND PM.prstatus='A'
                              and PM.prtyp='P'
                            )       )

                 )
            LOOP
                --CHECK: IF IS FALSE --> RETURN SUCCESSFUL!
                IF NOT fn_IsPRCheck (p_txmsg, l_acctno, rec.prcode, l_prtype, 'C') THEN
                    plog.debug(pkgctx,'fn_IsPRCheck:FALSE;');
                    CONTINUE;
                END IF;

                -- get limitcheck remain ON pool/room
                l_limitcheck:=fn_getCurrentPR(p_txmsg, rec.prcode,rec.prtyp, substr(l_acctno,0,10), l_codeid);
                plog.debug(pkgctx,'Limit check:'|| l_limitcheck);

                -- Thuc hien kiem tra nguon.
                IF l_dorc = 'D' THEN -- Giao dich lam giam, check nguon kha dung
                    IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                        IF l_value > l_limitcheck THEN
                            IF l_prtype = 'P' THEN
                                p_err_code:='-100522';        --Vuot qua nguon.
                                PLOG.ERROR(pkgctx,'PRCHK: [-100522]:Loi vuot qua nguon tien:'||p_err_code);
                            ELSE -- reverse transactions
                                p_err_code:='-100523';        --Vuot qua nguon.
                                plog.ERROR(pkgctx,'PRCHK: [-100523]:Loi vuot qua nguon chung khoan:'||p_err_code);
                            END IF;
                            plog.setendsection (pkgctx, 'fn_txAutoCheck');
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END IF;
                ELSIF l_dorc = 'C' THEN -- Giao dich lam tang, truong hop DELETE kiem tra nguon.
                    IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                        NULL;
                    ELSE -- reverse transations
                        --Neu xoa giao dich ghi tang, phai kiem tra nguon truoc moi cho xoa.
                        IF l_value > l_limitcheck THEN
                            IF l_prtype = 'P' THEN
                                p_err_code:='-100522';        --Vuot qua nguon.
                                plog.ERROR(pkgctx,'PRCHK: [-100522]:Loi vuot qua nguon tien:'||p_err_code);
                            ELSE
                                p_err_code:='-100523';        --Vuot qua nguon.
                                plog.ERROR(pkgctx,'PRCHK: [-100522]:Loi vuot qua nguon chung khoan:'||p_err_code);
                            END IF;
                            plog.setendsection (pkgctx, 'fn_txAutoCheck');
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END IF;
                END IF;

            END LOOP;
       END IF;
        -- Check for System Room:
        -- << BEGIN
        if l_prtype = 'R' AND l_IsMarginAccount='Y' THEN
           --PhuongHT edit: neu co khai Room dac biet thi khong check voi room he thong
            SELECT COUNT(*) INTO L_COUNT FROM PRMASTER WHERE PRSTATUS='A' AND POOLTYPE='AF'
            AND CODEID=L_CODEID AND AFACCTNO=substr(l_acctno,0,10) AND PRTYP='R';
            IF L_COUNT=0 THEN-- khong co Room dac biet
                -- 1. Get Current Avail Room:
                select greatest(syroomlimit - syroomused - nvl(sy_prinused,0),0) into l_limitcheck
                from securities_info se, (select codeid, sum(prinused) sy_prinused from vw_afpralloc_all where restype = 'S' group by codeid) vw
                where se.codeid = vw.codeid(+) and se.codeid = l_codeid;
                  -- 2. Check on PRCHK Rules:
                IF l_dorc = 'D' THEN -- Giao dich lam giam, check nguon kha dung
                    IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                        IF l_value > l_limitcheck THEN
                            p_err_code:='-100523';        --Vuot qua nguon.
                            plog.ERROR(pkgctx,'PRCHK: [-100523]:Loi vuot qua nguon chung khoan:'||p_err_code);
                            plog.setendsection (pkgctx, 'fn_txAutoCheck');
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END IF;
                ELSIF l_dorc = 'C' THEN -- Giao dich lam tang, truong hop DELETE kiem tra nguon.
                    IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                        NULL;
                    ELSE -- reverse transations
                        --Neu xoa giao dich ghi tang, phai kiem tra nguon truoc moi cho xoa.
                        IF l_value > l_limitcheck THEN
                            p_err_code:='-100523';        --Vuot qua nguon.
                            plog.ERROR(pkgctx,'PRCHK01: [-100522]:Loi vuot qua nguon chung khoan:'||p_err_code);
                            plog.setendsection (pkgctx, 'fn_txAutoCheck');
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END IF;
                END IF;
                -- ROOM nhom tai khoan
            ELSE
                SELECT PRLIMIT-PRINUSED-fn_getExpectUsed(PRCODE)
                INTO l_limitcheck
                FROM PRMASTER WHERE PRSTATUS='A' AND POOLTYPE='AF'
                AND CODEID=L_CODEID AND AFACCTNO=substr(l_acctno,0,10) AND PRTYP='R';
                  -- 2. Check on PRCHK Rules:
                IF l_dorc = 'D' THEN -- Giao dich lam giam, check nguon kha dung
                    IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                        IF l_value > l_limitcheck THEN
                            p_err_code:='-100523';        --Vuot qua nguon.
                            plog.ERROR(pkgctx,'PRCHK02: [-100523]:Loi vuot qua nguon chung khoan:'||p_err_code);
                            plog.setendsection (pkgctx, 'fn_txAutoCheck');
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END IF;
                ELSIF l_dorc = 'C' THEN -- Giao dich lam tang, truong hop DELETE kiem tra nguon.
                    IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                        NULL;
                    ELSE -- reverse transations
                        --Neu xoa giao dich ghi tang, phai kiem tra nguon truoc moi cho xoa.
                        IF l_value > l_limitcheck THEN
                            p_err_code:='-100523';        --Vuot qua nguon.
                            plog.ERROR(pkgctx,'PRCHK03: [-100522]:Loi vuot qua nguon chung khoan:'||p_err_code);
                            plog.setendsection (pkgctx, 'fn_txAutoCheck');
                            RETURN errnums.C_BIZ_RULE_INVALID;
                        END IF;
                    END IF;
                END IF;

            END IF;

            -- end of PhuongHT edit
        end if;
        -- END >>
    END LOOP;
    plog.setendsection (pkgctx, 'fn_txAutoCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    p_err_code:='-1';
    plog.error(pkgctx,'error:'||p_err_code || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'fn_txAutoCheck');
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_txAutoCheck;


FUNCTION fn_txAutoUpdate(p_txmsg in tx.msg_rectype, p_err_code out varchar2)
RETURN NUMBER
IS
        l_tltxcd PRCHK.tltxcd%TYPE;
        l_type PRCHK.TYPE%TYPE;
        l_typeid PRCHK.typeid%TYPE;
        l_typefldcd PRCHK.typefldcd%TYPE;
        l_bridtype PRCHK.bridtype%TYPE;
        l_prtype PRCHK.prtype%TYPE;
        l_accfldcd PRCHK.accfldcd%TYPE;
        l_dorc PRCHK.dorc%TYPE;
        l_amtexp PRCHK.amtexp%TYPE;
        l_acctno varchar2(30);
        l_brid varchar2(4);
        l_actype varchar2(10);
        l_value number(20,4);
        l_busdate DATE;
        l_codeid varchar2(10);
        l_IsSpecialPR NUMBER;
        l_count NUMBER;
        l_IsMarginAccount varchar2(1);
        l_lnaccfldcd varchar2(20);
        l_lntypefldcd varchar2(20);
        l_lntype varchar2(4);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAutoUpdate');

    plog.debug(pkgctx, 'fn_txAutoAdhocUpdate: begin');
    IF fn_txAutoAdhocUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
      plog.setendsection (pkgctx, 'fn_PRTxProcess');
      RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    plog.debug(pkgctx, 'fn_txAutoAdhocUpdate: end');

    SELECT to_date(varvalue,'DD/MM/RRRR') INTO l_busdate FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    FOR i IN
        (
            SELECT a.tltxcd, a.chktype, a.udptype, a.type, a.typeid, a.bridtype, a.prtype, a.accfldcd, a.dorc, a.amtexp, a.typefldcd, a.lnaccfldcd, a.lntypefldcd
            FROM prchk a WHERE a.tltxcd = p_txmsg.tltxcd and a.udptype='I' AND a.deltd <> 'Y' ORDER BY a.odrnum
        )
    LOOP
        l_tltxcd:=i.tltxcd;
        l_type:=i.TYPE;
        l_typeid:=i.typeid;
        l_typefldcd:=i.typefldcd;
        l_bridtype:=i.bridtype;
        l_prtype:=i.prtype;
        l_accfldcd:=i.accfldcd;
        l_dorc:=i.dorc;
        l_amtexp:=i.amtexp;
        l_lnaccfldcd:=i.lnaccfldcd;
        l_lntypefldcd:=i.lntypefldcd;

        --TK CHECK pool room. (CI OR SE account)
        IF NOT l_accfldcd IS NULL AND length(l_accfldcd) > 0 THEN
            IF instr(l_accfldcd,'&') > 0 THEN
                l_acctno:= p_txmsg.txfields(substr(l_accfldcd,0,2)).value || p_txmsg.txfields(ltrim(substr(l_accfldcd,3),'&')).value;
            ELSE
                l_acctno:= p_txmsg.txfields(l_accfldcd).value;
            END IF;
        END IF;

        --Lay tham so chi nhanh.
        IF l_bridtype = '0' THEN        --noi mo hop dong
          --  l_brid:= substr(l_acctno,0,4);
            select af.actype, cf.brid into l_actype, l_BrID from afmast af, cfmast cf where  af.custid=cf.custid AND af.acctno =  substr(l_acctno,0,10);
        ELSIF l_bridtype = '1' THEN     --noi lam giao dich
            l_brid:=p_txmsg.brid;
        ELSIF l_bridtype = '2' THEN     --careby tieu khoan.
            BEGIN
                SELECT tl.brid INTO l_brid
                FROM afmast af, tlprofiles tl
                WHERE af.tlid = tl.tlid AND af.acctno = substr(l_acctno,0,10);
            EXCEPTION WHEN OTHERS THEN
                l_brid:= substr(l_acctno,0,4);
            END;
            l_brid:=nvl(l_brid,substr(l_acctno,0,4));
        END IF;

        --Lay ma loai hinh san pham.
        IF NOT l_typeid IS NULL AND length(l_typeid) > 0 THEN
            -- get XXTYPE FROM XXMAST WHERE XXACCTNO = l_typeid
            IF l_type = 'DFTYPE' THEN
                SELECT actype INTO l_actype FROM dfmast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'LNTYPE' THEN
                SELECT actype INTO l_actype FROM lnmast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'CITYPE' THEN
                SELECT actype INTO l_actype FROM cimast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'SETYPE' THEN
                SELECT actype INTO l_actype FROM semast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            ELSIF l_type = 'AFTYPE' THEN
                SELECT actype INTO l_actype FROM afmast WHERE acctno = p_txmsg.txfields(l_typeid).value;
            end if;
        elsif not l_typefldcd is null and length(l_typefldcd) > 0 then
            --Get ACTYPE direct FROM Transactions.
            l_actype:= p_txmsg.txfields(l_typefldcd).value;
        END IF;

        IF length(l_amtexp) > 0 THEN
            l_value:= fn_parse_amtexp(p_txmsg,l_amtexp);
        ELSE
            l_value:= 0;
        END IF;

        --lay codeid chung khoan.
        l_codeid:= substr(l_acctno,11,6);

        --Lay LNTYPE tu [LNACCFLDCD] or [LNTYPEFLDCD]
        if length(trim(l_lnaccfldcd))>0 then
            begin
                select actype into l_lntype from lnmast where acctno = p_txmsg.txfields(l_lnaccfldcd).value;
            exception when others then
                l_lntype:='XXXX';
            end;
        end if;
        if length(trim(l_lntypefldcd))>0 then
            begin
                l_lntype:= p_txmsg.txfields(l_lntypefldcd).value;
            exception when others then
                l_lntype:='XXXX';
            end;
        end if;

        IF L_PRTYPE='P' THEN
            --Danh dau pool
            --Neu Tieu khoan khong danh dau bat buoc tuan thu he thong hoac ko phai lai tieu khoan margin -> Khong can hach toan nguon SYSTEM.
            select count(1) into l_count
            from afmast af, aftype aft, mrtype mrt, lntype lnt1
            where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype IN ('S', 'T')
                and aft.lntype = lnt1.actype(+) and af.acctno = substr(l_acctno,0,10)
                and ((nvl(lnt1.chksysctrl,'N') = 'Y' and nvl(lnt1.actype,'ZZZZ') =l_lntype)
                    or
                    exists (select 1 from afidtype afi, lntype lnt2
                            where afi.actype = lnt2.actype and afi.objname = 'LN.LNTYPE' and afi.aftype = aft.actype and lnt2.actype = l_lntype and lnt2.chksysctrl = 'Y'));

        ELSE -- ROOM
            select count(1) into l_count
            from afmast af, aftype aft, mrtype mrt, lntype lnt1
            where af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype IN ('S', 'T')
            and aft.lntype = lnt1.actype(+) and af.acctno = substr(l_acctno,0,10)
            and ((nvl(lnt1.chksysctrl,'N') = 'Y' and nvl(lnt1.actype,'ZZZZ') =AFT.LNTYPE)
            or
            exists (select 1 from afidtype afi, lntype lnt2
            where afi.actype = lnt2.actype and afi.objname = 'LN.LNTYPE'
            and afi.aftype = aft.actype and lnt2.actype = AFT.LNTYPE and lnt2.chksysctrl = 'Y'));

        END IF;
        if l_count = 0 then
                l_IsMarginAccount:='N';
        else
                l_IsMarginAccount:='Y';
        end if;
         IF       l_IsMarginAccount='Y'  then
          FOR rec IN (
                  SELECT * FROM
    -- Pool dac biet cho tieu khoan
                    (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                    FROM PRMASTER PM
                    WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO= substr(l_acctno,0,10)
                    AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                    AND PM.prstatus='A'
                    AND PM.PRTYP=L_PRTYPE
                    AND l_IsMarginAccount = 'Y'
                    UNION ALL-- Pool dac biet cho danh sach khach hang
                      SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                      FROM PRMASTER PM,PRAFMAP PRM
                      WHERE PM.POOLTYPE='GR'
                      AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO= substr(l_acctno,0,10)
                      AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                      AND PM.prstatus='A'
                      AND PM.PRTYP=L_PRTYPE
                      AND l_IsMarginAccount = 'Y'
                    UNION ALL-- Pool cho nhom loai hinh khach hang
                      SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                      FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP,*/ BRIDMAP BRM
                      WHERE PM.PRCODE=BRM.PRCODE
                      AND pm.prcode = PRTM.PRCODE
                      AND PM.POOLTYPE='TY'
                     -- AND prt.actype = prtm.prtype
                     -- AND prt.actype = TMP.PRTYPE
                      AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                      AND pm.prtyp = l_prtype
                      --AND (prt.TYPE = l_type
                     -- /*or (prt.type = 'SYSTEM' and l_IsMarginAccount = 'Y' and l_prtype = 'P')*/)
                      AND pm.prstatus = 'A'
                      AND PRTM.PRTYPE = decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                      AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                      AND l_IsMarginAccount = 'Y'
                    UNION ALL
                       SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                      FROM PRMASTER PM
                      WHERE PM.POOLTYPE='SY'
                      AND l_IsMarginAccount = 'Y'
                      AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                      AND PM.prstatus='A'
                      AND PM.PRTYP=l_prtype
                      )
WHERE odr=( SELECT  MIN(odr) FROM
                        -- Pool dac biet cho tieu khoan
                        (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                        FROM PRMASTER PM
                        WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO= substr(l_acctno,0,10)
                        AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                        AND PM.prstatus='A'
                        AND PM.PRTYP=L_PRTYPE
                        AND l_IsMarginAccount = 'Y'
                        UNION ALL-- Pool dac biet cho danh sach khach hang
                          SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                          FROM PRMASTER PM,PRAFMAP PRM
                          WHERE PM.POOLTYPE='GR'
                          AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO= substr(l_acctno,0,10)
                          AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                          AND PM.prstatus='A'
                          AND PM.PRTYP=L_PRTYPE
                          AND l_IsMarginAccount = 'Y'
                        UNION ALL-- Pool cho nhom loai hinh khach hang
                          SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                          FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP,*/ BRIDMAP BRM
                          WHERE PM.PRCODE=BRM.PRCODE
                          AND pm.prcode = PRTM.PRCODE
                          AND PM.POOLTYPE='TY'
                         -- AND prt.actype = prtm.prtype
                         -- AND prt.actype = TMP.PRTYPE
                          AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                          AND pm.prtyp = l_prtype
                          --AND (prt.TYPE = l_type
                         -- /*or (prt.type = 'SYSTEM' and l_IsMarginAccount = 'Y' and l_prtype = 'P')*/)
                          AND pm.prstatus = 'A'
                          AND PRTM.PRTYPE = decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                          AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                          AND l_IsMarginAccount = 'Y'
                        UNION ALL
                           SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED,PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                          FROM PRMASTER PM
                          WHERE PM.POOLTYPE='SY'
                          AND l_IsMarginAccount = 'Y'
                          AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                          AND PM.prstatus='A'
                          AND PM.PRTYP=l_prtype
                      ) )

             )
        LOOP
         --  PLOG.ERROR(pkgctx,'update00 ' || rec.prcode);
            --CHECK: IF IS FALSE --> RETURN SUCCESSFUL!
            IF NOT fn_IsPRCheck(p_txmsg, l_acctno, rec.prcode, l_prtype, 'U') THEN
              -- PLOG.ERROR(pkgctx,'update01 ' || rec.prcode);
                plog.debug(pkgctx,'fn_IsPRCheck:FALSE;');
                CONTINUE;
            END IF;
              PLOG.ERROR(pkgctx,'update:PRCODE: ' || rec.prcode);
            --Thuc hien cap nhat nguon:
            IF l_dorc = 'D' THEN -- Ghi giam nguon
                IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                    UPDATE PRMASTER SET PRINUSED=NVL(PRINUSED,0)+ l_value WHERE PRCODE= REC.PRCODE ;
                    INSERT INTO PRTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.prcode,'0004',l_value,NULL,p_txmsg.deltd,'',seq_PRTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || p_txmsg.txdesc || '');
                ELSE -- reverse transactions
                    UPDATE PRMASTER SET PRINUSED=NVL(PRINUSED,0)- l_value WHERE PRCODE= rec.prcode;
                    update PRTRAN set deltd='Y' where txnum=p_txmsg.txnum and txdate= TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
                END IF;
            ELSIF l_dorc = 'C' THEN --Ghi tang nguon.
                IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                    UPDATE PRMASTER SET PRINUSED=NVL(PRINUSED,0)- l_value WHERE PRCODE= rec.prcode;
                    INSERT INTO PRTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),rec.prcode,'0003',l_value,NULL,p_txmsg.deltd,'',seq_PRTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || p_txmsg.txdesc || '');
                ELSE -- reverse transactions
                    UPDATE PRMASTER SET PRINUSED=NVL(PRINUSED,0)+ l_value WHERE PRCODE= rec.prcode;
                    update PRTRAN set deltd='Y' where txnum=p_txmsg.txnum and txdate= TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
                END IF;
          END IF;

        END LOOP;


        -- Update for System Room:
        -- << BEGIN
        if l_prtype = 'R' then
            -- 1. Update on PRCHK Rules:
            IF l_dorc = 'D' THEN -- Ghi giam nguon
                IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                    UPDATE securities_info SET SYROOMUSED=NVL(SYROOMUSED,0)+ l_value WHERE CODEID= l_codeid;
                ELSE -- reverse transactions
                    UPDATE securities_info SET SYROOMUSED=NVL(SYROOMUSED,0)- l_value WHERE CODEID= l_codeid;
                END IF;
            ELSIF l_dorc = 'C' THEN --Ghi tang nguon.
                IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
                    UPDATE securities_info SET SYROOMUSED=NVL(SYROOMUSED,0)- l_value WHERE CODEID= l_codeid;
                ELSE -- reverse transactions
                    UPDATE securities_info SET SYROOMUSED=NVL(SYROOMUSED,0)+ l_value WHERE CODEID= l_codeid;
                END IF;
            END IF;
        end if;
        END IF;
        -- END >>
    END LOOP;
    plog.setendsection (pkgctx, 'fn_txAutoUpdate');
    RETURN systemnums.C_SUCCESS;
exception when others then
    plog.setendsection (pkgctx, 'fn_txAutoUpdate');
    Return errnums.C_BIZ_RULE_INVALID;
END fn_txAutoUpdate;

FUNCTION fn_AutoPRTxProcess(p_txmsg in out tx.msg_rectype,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;

BEGIN
   plog.setbeginsection (pkgctx, 'fn_AutoTxProcess');
   IF fn_txAutoCheck(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;
   IF fn_txAutoUpdate(p_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;

   plog.setendsection (pkgctx, 'fn_AutoTxProcess');
   RETURN l_return_code;
EXCEPTION
   WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_AutoTxProcess');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_AutoPRTxProcess;

FUNCTION fn_prAutoCheck(p_xmlmsg IN OUT varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;
   l_txmsg tx.msg_rectype;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_PRTxProcess');
   plog.debug(pkgctx, 'xml2obj');
   l_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg);
   IF fn_txAutoCheck(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
        plog.setendsection (pkgctx, 'fn_PRTxProcess');
        RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;

   plog.debug(pkgctx, 'obj2xml');
   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
   plog.setendsection (pkgctx, 'fn_PRTxProcess');
   RETURN l_return_code;
EXCEPTION
WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value := p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_prUpdate');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value :=  p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_prUpdate');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_prAutoCheck;


FUNCTION fn_prAutoUpdate(p_xmlmsg IN OUT varchar2,p_err_code in out varchar2,p_err_param out varchar2)
RETURN NUMBER
IS
   l_return_code VARCHAR2(30) := systemnums.C_SUCCESS;
   l_txmsg tx.msg_rectype;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_PRTxProcess');
   plog.debug(pkgctx, 'xml2obj');
   l_txmsg := txpks_msg.fn_xml2obj(p_xmlmsg);
   IF fn_txAutoUpdate(l_txmsg, p_err_code) <> systemnums.C_SUCCESS THEN
      plog.setendsection (pkgctx, 'fn_PRTxProcess');
      RAISE errnums.E_BIZ_RULE_INVALID;
   END IF;

   plog.debug(pkgctx, 'obj2xml');
   p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
   plog.setendsection (pkgctx, 'fn_PRTxProcess');
   RETURN l_return_code;
EXCEPTION
WHEN errnums.E_BIZ_RULE_INVALID
   THEN
      FOR I IN (
           SELECT ERRDESC,EN_ERRDESC FROM deferror
           WHERE ERRNUM= p_err_code
      ) LOOP
           p_err_param := i.errdesc;
      END LOOP;      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value := p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_prUpdate');
      RETURN errnums.C_BIZ_RULE_INVALID;
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
      plog.error (pkgctx, SQLERRM);
      l_txmsg.txException('ERRSOURCE').value := '';
      l_txmsg.txException('ERRSOURCE').TYPE := 'System.String';
      l_txmsg.txException('ERRCODE').value := p_err_code;
      l_txmsg.txException('ERRCODE').TYPE := 'System.Int64';
      l_txmsg.txException('ERRMSG').value :=  p_err_param;
      l_txmsg.txException('ERRMSG').TYPE := 'System.String';
      p_xmlmsg := txpks_msg.fn_obj2xml(l_txmsg);
      plog.setendsection (pkgctx, 'fn_prUpdate');
      RETURN errnums.C_SYSTEM_ERROR;
END fn_prAutoUpdate;

FUNCTION fn_AfRoomLimitCheck(p_afacctno in varchar2, p_codeid in varchar2, p_qtty in NUMBER, p_err_code in out varchar2)
RETURN NUMBER
IS
l_remainqtty number;
l_remainamt number;
l_basicprice number;
l_mrrate    number;
l_margintype char(1);
l_chksysctrl    char(1);
l_roomchk   char(1);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_AfRoomLimitCheck');
    p_err_code:=systemnums.c_success;
    begin
    select roomchk into l_roomchk from semast se where afacctno = p_afacctno and codeid = p_codeid;
    exception when others then
        l_roomchk:='Y';
    end;

    if l_roomchk = 'N' then --Check room dac biet
        SELECT mr.mrtype, nvl(lnt.chksysctrl,'N') chksysctrl
            INTO l_margintype, l_chksysctrl
        FROM afmast mst, aftype af, mrtype mr, lntype lnt
        WHERE mst.actype = af.actype
          AND af.mrtype = mr.actype
          and af.lntype = lnt.actype (+)
          AND mst.acctno = p_afacctno;
        if l_margintype in ('S','T')  then
            --Chi check Room he thong voi tai khoan Margin, tai khoan T3 khong check
            select nvl(se.selimit - fn_getUsedSeLimitByGroup(se.autoid),0) into l_remainqtty
                from afselimitgrp af, selimitgrp se
                where af.refautoid = se.autoid
                and af.afacctno = p_afacctno
                and se.codeid = p_codeid;

            if l_remainqtty < p_qtty then
                 p_err_code:='-100524';        --Vuot qua nguon.
                 plog.debug(pkgctx,'PRCHK: [-100524]:Loi vuot qua nguon dac biet cua chung khoan:'||p_err_code);
                 return p_err_code;
            end if;

            plog.setendsection (pkgctx, 'fn_AfRoomLimitCheck');
        end if;
    end if;
    plog.setendsection (pkgctx, 'fn_AfRoomLimitCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.error(pkgctx,'row:'||dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'fn_AfRoomLimitCheck');
    p_err_code:=errnums.c_system_error;
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_AfRoomLimitCheck;

FUNCTION fn_RoomLimitCheck(p_afacctno in varchar2, p_codeid in varchar2, p_qtty in NUMBER, p_err_code in out varchar2)
RETURN NUMBER
IS
l_remainqtty number;
l_remainamt number;
l_basicprice number;
l_mrrate    number;
l_margintype char(1);
l_istrfbuy  char(1);
l_chksysctrl    char(1);
L_COUNT         NUMBER;
L_ACTYPE        VARCHAR2(10);
L_BRID         VARCHAR2(10);
l_basketid      VARCHAR2(100);
v_seqtty    number;
l_mrmaxqtty  number;
l_roomchk char(1);
l_mrratioloan number(20,4);
l_mrpriceloan  number(20,4);
L_SEQTTY number;
L_roomlimit number;
L_roomused number;
L_MARGINPRICE number;
l_dfmaxqtty number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_RoomLimitCheck');
    p_err_code:=systemnums.c_success;
    SELECT mr.mrtype, af.istrfbuy, nvl(af.chkmarginbuy,'N') chksysctrl,AF.ACTYPE,cf.brid

        INTO l_margintype, l_istrfbuy, l_chksysctrl,l_actype,l_BrID
    FROM afmast mst, aftype af, mrtype mr, lntype lnt ,cfmast cf
    WHERE mst.actype = af.actype
      AND af.mrtype = mr.actype
      and af.lntype = lnt.actype (+)
      AND mst.acctno = p_afacctno
      AND mst.custid=cf.custid;
    if l_margintype in ('S','T')  THEN
       -- PhuongHT edit: Neu khach hang khai ROOM dac biet: ko check room khac
         /*SELECT COUNT(*) INTO L_COUNT FROM PRMASTER
         WHERE PRSTATUS='A' AND CODEID=P_CODEID AND POOLTYPE='AF'
         AND PRTYP='R' AND AFACCTNO=P_AFACCTNO;*/
         begin
        select roomchk into l_roomchk from semast se where afacctno = p_afacctno and codeid = p_codeid;
        exception when others then
            l_roomchk:='Y';
        end;
         --plog.ERROR(pkgctx,'L_actype: '||L_ACTYPE || 'l_BrID: '||l_BrID);
         IF l_roomchk='Y' THEN
         --end of PhuongHT edit
              --Chi check Room he thong voi tai khoan Margin, tai khoan T3 khong check
              begin
                select nvl((rsk.mrratioloan * rsk.mrpriceloan),0), rsk.mrmaxqtty
                    into l_mrrate, l_mrmaxqtty
                from afserisk rsk, afmast af
                where af.actype = rsk.actype
                and af.acctno = p_afacctno and rsk.codeid = p_codeid;
              exception when others then
                l_mrmaxqtty:= 0;
                l_mrrate:=0;
              end;
              if l_istrfbuy ='N' and l_chksysctrl='Y' then --Margin tuan thu he thong thi check
                  --Check tang he thong
                  /*select nvl(max(rsk.mrratioloan * rsk.mrpriceloan),0)
                      into l_mrrate
                  from afserisk rsk, afmast af
                  where af.actype = rsk.actype
                  and af.acctno = p_afacctno and rsk.codeid = p_codeid;*/
                  if l_mrrate > 0 then
                      select nvl(max(mrmaxqtty - seqtty),0) into l_remainqtty
                      from v_getmarginroominfo_buf
                      where codeid = p_codeid;

                      if l_remainqtty < p_qtty then
                          p_err_code:='-100523';        --Vuot qua nguon.
                          PLOG.debug(pkgctx,'PRCHK: [-100523]:Loi vuot qua nguon chung khoan:' || p_err_code);
                          plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
                          return p_err_code;
                      end if;
                  else
                        p_err_code:='-400099';        --Vuot qua nguon.
                        plog.debug(pkgctx,'PRCHK: [-400099]:TK Margin khong duoc mua chung khoan ngoai danh muc!:'||p_err_code);
                        plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
                        return p_err_code;
                  end if;
              end if;

              --Check room tang ro chung khoan.
             --if l_mrrate>0 then --Ma chung khoan co duoc Margin
                --Lay ra thong tin ro chung khoan cua.
                begin
                    Select lnb.basketid into l_basketid
                    from lnsebasket lnb, lntype lnt, aftype aft, afmast af
                    where lnb.actype= lnt.actype and aft.lntype = lnt.actype
                    and aft.actype = af.actype and af.acctno = p_afacctno;
                exception when others then
                    l_basketid:='';
                end;
                if l_basketid is not null then
                    v_seqtty:=fn_getRoomUsedByBasket(p_codeid, l_basketid);
                    if l_mrrate <= 0 and l_istrfbuy ='N' and l_chksysctrl='Y' then
                         p_err_code:='-400099';        --Vuot qua nguon.
                         plog.debug(pkgctx,'PRCHK: [-400099]:TK Margin khong duoc mua chung khoan ngoai danh muc!:'||p_err_code);
                         plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
                         return p_err_code;
                    elsif l_mrmaxqtty - v_seqtty < p_qtty then
                         p_err_code:='-100525';        --Vuot qua nguon.
                         plog.debug(pkgctx,'PRCHK: [-100525]:Loi vuot qua nguon chung khoan theo ro:'||p_err_code);
                         plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
                         return p_err_code;
                    end if;

                end if;
            --else

            --end if;

              /*--PhuongHT edit: check room nhom tai khoan
              FOR REC2 IN (
                           SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,
                           (PRLIMIT-PRINUSED-fn_getExpectUsed(PM.PRCODE))PRLIMIT,PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                      FROM PRMASTER PM, PRTYPEMAP PRTM,BRIDMAP BRM
                      WHERE PM.PRCODE=BRM.PRCODE
                      AND pm.prcode = prtm.prcode
                      --AND prt.actype = prtm.prtype
                                AND PM.POOLTYPE='GR'
                      --AND prt.actype = TMP.PRTYPE
                      AND pm.codeid = p_codeid
                      AND pm.prtyp = 'R'
                     -- AND prt.TYPE = 'AFTYPE'
                      AND pm.prstatus = 'A'
                      AND PRTM.PRTYPE = decode(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                      AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                          )
              LOOP
                --plog.ERROR(pkgctx,'l_remainqtty: '||l_remainqtty || 'PRLIMIT: '||REC2.PRLIMIT);
                if  REC2.PRLIMIT  < p_qtty then
                      p_err_code:='-100523';        --Vuot qua nguon.
                      plog.ERROR(pkgctx,'PRCHK: [-100523]:Loi vuot qua nguon chung khoan:'||p_err_code);
                      return p_err_code;
                end if;
              END LOOP;*/
              --end of PhuongHT edit: check room nhom tai khoan
          ELSE
               /*SELECT PRLIMIT-PRINUSED-fn_getExpectUsed(PRCODE)
               INTO l_remainqtty
               FROM PRMASTER WHERE PRSTATUS='A' AND POOLTYPE='AF'
               AND CODEID=p_codeid AND AFACCTNO=p_afacctno AND PRTYP='R';
               if l_remainqtty < p_qtty then
                      p_err_code:='-100523';        --Vuot qua nguon.
                      plog.ERROR(pkgctx,'PRCHK: [-100523]:Loi vuot qua nguon chung khoan:'||p_err_code);
                      RETURN P_ERR_CODE;
                end if;*/

            --Cehck room dac biet. Khi nay khong check theo ro va nguon chung nua
            select nvl(se.selimit - fn_getUsedSeLimitByGroup(se.autoid),0) into l_remainqtty
                from afselimitgrp af, selimitgrp se
                where af.refautoid = se.autoid
                and af.afacctno = p_afacctno
                and se.codeid = p_codeid;

            if l_remainqtty < p_qtty then
                 p_err_code:='-100526';        --Vuot qua nguon.
                 plog.debug(pkgctx,'PRCHK: [-100526]:Loi vuot qua nguon dac biet cua chung khoan:'||p_err_code);
                 plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
                 return p_err_code;
            end if;

          END IF;
        /*--Check tang khach hang
        BEGIN
            select nvl(selm.afmaxamt, case when l_istrfbuy ='N' then rsk.afmaxamt else rsk.afmaxamtt3 end) - nvl(aclm.seamt,0), inf.basicprice into l_remainamt , l_basicprice
            from securities_risk rsk, securities_info inf,
                (select * from afselimit where afacctno = p_afacctno) selm,
                (select * from v_getaccountseclimit where afacctno = p_afacctno) aclm
            where rsk.codeid = selm.codeid(+) and rsk.codeid = aclm.codeid(+)
            and rsk.codeid= inf.codeid
            and rsk.codeid = p_codeid;
        exception when others then
            l_remainamt := 0;
            l_basicprice := 0;
       END;
        if l_remainamt < p_qtty*l_basicprice then
            p_err_code:='-100524';        --Vuot qua han muc theo tieu khoan.
            plog.debug(pkgctx,'PRCHK: [-100524]:Loi vuot qua han muc vay theo tieu khoan:'||p_err_code);
            return p_err_code;
        end if;*/
        plog.setendsection (pkgctx, 'fn_RoomLimitCheck');

    ELSIF   l_margintype ='F' THEN

              begin
              SELECT max( SEC.basketid) basketid, MAX(SEC.dfmaxqtty)  INTO l_basketid, l_dfmaxqtty
               FROM AFDFBASKET LNB, dfbasket SEC,  AFTYPE AFT, afidtype afid,sbsecurities sb
               WHERE  LNB.BASKETID=SEC.BASKETID
--               AND LNB.ACTYPE = AFT.DFTYPE
               AND afid.objname ='DF.DFTYPE'
               AND afid.actype = lnb.actype
               AND afid.aftype = aft.actype
               AND aft.actype =l_actype
               and sec.symbol = sb.symbol
               and sb.codeid = p_codeid
               AND nvl(sec.chstatus,'C') <> 'A' AND nvl(LNB.chstatus,'C') <> 'A';
              exception when others then
                l_basketid:= '';
                l_dfmaxqtty:='';
              end;


                if l_basketid is not null then
                    v_seqtty:=fn_getroomusedbybasket_df(p_codeid, l_basketid);
                     if l_dfmaxqtty - v_seqtty < p_qtty then
                         p_err_code:='-100525';        --Vuot qua nguon.
                         plog.debug(pkgctx,'PRCHK: [-100525]:Loi vuot qua nguon chung khoan theo ro:'||p_err_code);
                         plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
                         return p_err_code;
                    end if;
                end if;
    end if;
    plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
    RETURN P_ERR_CODE;
EXCEPTION when others then
    plog.error(pkgctx,'error:'||p_err_code);
    plog.error(pkgctx,'row:'||dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'fn_RoomLimitCheck');
    p_err_code:=errnums.c_system_error;
    RETURN errnums.C_BIZ_RULE_INVALID;
END fn_RoomLimitCheck;
FUNCTION fn_reset_prinused (p_err_code out varchar2) return number
is
     p_acctno VARCHAR2(10);
  L_BRID   VARCHAR2(10);
  L_ACTYPE VARCHAR2(10);
begin
    plog.setbeginsection (pkgctx, 'fn_reset_prinused');
    plog.debug (pkgctx, '<<BEGIN OF fn_reset_prinused');
    --Cap nhat cho R?argin tuan thu theo uy ban

update PRMASTER SET PRINUSED=0;
  FOR REC_CI IN ( SELECT SUM(NML+OVD) AMT,TRFACCTNO AFACCTNO FROm LNSCHD SCHD, LNMAST MST WHERE SCHD.ACCTNO=MST.ACCTNO
                AND SCHD.Reftype='P'  ANd MST.FTYPE ='AF' GROUP BY MST.TRFACCTNO
                 )
  LOOP
         P_ACCTNO:=REC_CI.AFACCTNO;

         SELECT CF.BRID, AF.ACTYPE
         INTO L_BRID, L_ACTYPE
         FROM CFMAST CF, AFMAST AF
         WHERE CF.CUSTID=AF.CUSTID
         AND AF.ACCTNO=P_ACCTNO;

         -- pool
         FOR REC_PR IN (SELECT * FROM
            -- Pool dac biet cho tieu khoan
            (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+0 prinused,
                    PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                    FROM PRMASTER PM
                   WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                   AND PM.prstatus='A'
                    and PM.prtyp='P'
            UNION ALL-- Pool dac biet cho danh sach khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                  FROM PRMASTER PM,PRAFMAP PRM
                  WHERE PM.POOLTYPE='GR'
                  AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                  -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                  AND PM.prstatus='A'
                  and PM.prtyp='P'
            UNION ALL-- Pool cho nhom loai hinh khach hang
                  SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                  PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                  FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                  WHERE PM.PRCODE=BRM.PRCODE
                  AND pm.prcode = prtm.prcode
                  AND pm.prstatus = 'A'
                  AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                  --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                  AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                  and PM.prtyp='P'
                  AND pm.pooltype='TY'
            UNION ALL
                --PooL he thong
                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                FROM PRMASTER PM
                WHERE  PM.POOLTYPE='SY'
                AND PM.prstatus='A'
                and PM.prtyp='P'
              )
WHERE odr=
( SELECT  min(odr) FROM
                          -- Pool dac biet cho tieu khoan
                          (SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                  PM.EXPIREDDT,PM.PRSTATUS, 1 ODR
                                  FROM PRMASTER PM
                                 WHERE PM.POOLTYPE='AF' AND PM.AFACCTNO=p_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                 AND PM.prstatus='A'
                                  and PM.prtyp='P'
                          UNION ALL-- Pool dac biet cho danh sach khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 2 ODR
                                FROM PRMASTER PM,PRAFMAP PRM
                                WHERE PM.POOLTYPE='GR'
                                AND PM.PRCODE=PRM.PRCODE AND PRM.AFACCTNO=p_acctno
                                -- AND pm.codeid = decode(l_prtype,'R',l_codeid,pm.codeid)
                                AND PM.prstatus='A'
                                and PM.prtyp='P'
                          UNION ALL-- Pool cho nhom loai hinh khach hang
                                SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                                PM.EXPIREDDT,PM.PRSTATUS, 3 ODR
                                FROM PRMASTER PM,/*PRTYPE PRT,*/ PRTYPEMAP PRTM,/*TYPEIDMAP TMP, */BRIDMAP BRM
                                WHERE PM.PRCODE=BRM.PRCODE
                                AND pm.prcode = prtm.prcode
                                AND pm.prstatus = 'A'
                                AND PRTM.PRTYPE=DECODE(PRTM.PRTYPE,'ALL',PRTM.PRTYPE,l_actype)
                                --  AND TPM.TYPEID= decode(TPM.TYPEID,'ALL',TPM.TYPEID,l_actype)
                                AND brm.brid = decode(brm.brid,'ALL',brm.brid,l_brid)
                                and PM.prtyp='P'
                                AND pm.pooltype='TY'
                          UNION ALL
                              --PooL he thong
                              SELECT DISTINCT PM.PRCODE,PM.PRNAME,PM.PRTYP,PM.CODEID,PM.PRLIMIT,PM.PRINUSED+ 0 prinused,
                              PM. EXPIREDDT,PM.PRSTATUS, 3 ODR
                              FROM PRMASTER PM
                              WHERE  PM.POOLTYPE='SY'

                              AND PM.prstatus='A'
                              and PM.prtyp='P'
                            )       )
                            )
         LOOP
             UPDATE PRMASTER SET PRINUSED=PRINUSED+REC_CI.AMT WHERE PRCODE=REC_PR.PRCODE;
         END LOOP;
  END LOOP;

    return 0;
    plog.debug (pkgctx, '<<END OF fn_reset_prinused');
    plog.setendsection (pkgctx, 'fn_reset_prinused');
exception when others then
    p_err_code := errnums.C_SYSTEM_ERROR;
    plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'fn_reset_prinused');
    RAISE errnums.E_SYSTEM_ERROR;
end fn_reset_prinused;
BEGIN
      FOR i IN (SELECT *
                FROM tlogdebug)
      LOOP
         logrow.loglevel    := i.loglevel;
         logrow.log4table   := i.log4table;
         logrow.log4alert   := i.log4alert;
         logrow.log4trace   := i.log4trace;
      END LOOP;
      pkgctx    :=
         plog.init ('txpks_prchk',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END;
/
