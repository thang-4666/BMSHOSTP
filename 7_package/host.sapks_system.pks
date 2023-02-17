SET DEFINE OFF;
CREATE OR REPLACE PACKAGE sapks_system
  IS
  Function fn_CheckODTYPE (p_aftype IN varchar2, p_objname IN varchar2, p_odtype IN varchar2) return varchar2;
  Function fn_CheckADTYPE (p_aftype IN varchar2, p_objname IN varchar2, p_adtype IN varchar2, p_Flag in VARCHAR2, p_err_code out VARCHAR2) return varchar2;
  Function fn_CheckIRRATESCHM (RATEID IN varchar2, AUTOID IN varchar2,
                             FRAMT IN varchar2, TOAMT IN varchar2,
                             FRTERM IN varchar2, TOTERM IN varchar2, p_Flag in VARCHAR2, p_err_code out VARCHAR2) return varchar2;
  Function fn_CheckChangeAFTYPE (p_aftype IN varchar2, p_afacctno IN varchar2) return varchar2; --TLTXCD=0051
  Function fn_CheckCloseCustodyAccount (p_custid IN varchar2) return varchar2;
  Function fn_CheckCloseCustodyCA (p_custid IN varchar2) return varchar2;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY sapks_system
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;


Function fn_CheckODTYPE (p_aftype IN varchar2, p_objname IN varchar2, p_odtype IN varchar2) return varchar2
IS
       l_count NUMBER;
    l_boolean BOOLEAN;
BEGIN
    SELECT count(map.objname) INTO l_count
    FROM odtype odt, aftype aft, afidtype map, odtype newodt
    WHERE aft.actype = map.aftype AND odt.actype = map.actype AND aft.actype = p_aftype and newodt.actype=p_odtype
        AND newodt.clearcd = odt.clearcd AND newodt.via = odt.via AND newodt.exectype = odt.exectype
        AND newodt.timetype = odt.timetype AND newodt.pricetype = odt.pricetype
        AND newodt.sectype = odt.sectype AND NVL(newodt.codeid,'')=NVL(odt.codeid,'')
        AND newodt.matchtype = odt.matchtype AND newodt.nork = odt.nork AND newodt.tradeplace = odt.tradeplace
        AND map.objname=p_objname;

plog.debug (pkgctx, 'Tan:' || p_objname||l_count);
  IF l_count=0 THEN
   plog.setendsection (pkgctx, 'fn_CheckODTYPE');
   RETURN systemnums.C_SUCCESS;
  ELSE
   plog.setendsection (pkgctx, 'fn_CheckODTYPE');
   RETURN -1;
  END IF;

/*
  l_boolean:= TRUE;
  FOR rec IN
  (
    SELECT odt.* FROM odtype odt, aftype aft, afidtype map
    WHERE aft.actype = map.aftype AND odt.actype = map.actype
    AND aft.actype = p_aftype
  )
  LOOP
    SELECT count(1) INTO l_count
    FROM odtype a
    WHERE status = 'Y' AND actype = p_odtype AND (via = rec.via OR via = 'A')
    AND clearcd = rec.clearcd
    AND (exectype = rec.exectype
      OR exectype = 'AA')
    AND (timetype = rec.timetype
      OR timetype = 'A')
    AND (pricetype = rec.pricetype
      OR pricetype = 'AA')
    AND (matchtype = rec.matchtype
      OR matchtype = 'A')
    AND (tradeplace = rec.tradeplace
      OR tradeplace = '000')
    AND (instr(case when rec.sectype in ('001','002','008') then rec.sectype || ',' || '111'
                when rec.sectype in ('003','006') then rec.sectype || ',' || '222'
                else rec.sectype end , sectype)>0 OR sectype = '000')
    AND (nork = rec.nork OR nork = 'A');

    IF l_count <> 0 THEN
    l_boolean:=FALSE;
    END IF;
  END LOOP;
  IF l_boolean THEN
        plog.setendsection (pkgctx, 'fn_CheckODTYPE');
    RETURN systemnums.C_SUCCESS;
  ELSE
        plog.setendsection (pkgctx, 'fn_CheckODTYPE');
    RETURN -1;
  END IF;
*/
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckODTYPE');
      RETURN '-1';
END;

Function fn_CheckADTYPE (p_aftype IN varchar2, p_objname IN varchar2, p_adtype IN varchar2, p_Flag in VARCHAR2, p_err_code out VARCHAR2) return varchar2
IS
    l_count         NUMBER;
    l_aftype        VARCHAR2(4);
    l_adtype        VARCHAR2(4);
    l_Flag          VARCHAR2(10);
    l_objname       VARCHAR2(20);
BEGIN

    plog.debug (pkgctx, 'p_aftype:' || p_aftype);
    plog.debug (pkgctx, 'p_objname:' || p_objname);
    plog.debug (pkgctx, 'p_adtype:' || p_adtype);
    plog.debug (pkgctx, 'p_Flag:' || p_Flag);

    l_aftype    := p_aftype;
    l_adtype    := p_adtype;
    l_Flag      := p_Flag;
    l_objname   := p_objname;

    --</Check duplicate
    if Upper(l_Flag) = 'ADD' then

        --</ Check trung trong bang afidtype
        Begin
            SELECT  count(adt.actype)  into l_count FROM adtype adt, aftype aft, afidtype map
            WHERE   aft.actype = map.aftype AND adt.actype = map.actype
                    AND map.aftype = l_aftype and map.actype = l_adtype and map.objname = l_objname and map.objname  ='AD.ADTYPE'  ;
        EXCEPTION
            WHEN OTHERS THEN l_count := 0;
        END;

        If l_count > 0 then
           p_err_code := -100804;
           return -1;
        End if;
        --/>

        --</ Check trung trong bang aftype
    /*    BEGIN
            Select Count(1) Into l_count From aftype where adtype = l_adtype and actype = l_aftype;
        EXCEPTION
            WHEN OTHERS THEN l_count := 0;
        END;

        If l_count > 0 then
           p_err_code := -100804;
           return -1;
        End if;*/
        --/>

     Elsif  Upper(l_Flag) = 'EDIT' then

        --</ Check trung trong bang afidtype
        BEGIN
            SELECT count(adt.actype)  into l_count FROM adtype adt, aftype aft, afidtype map
            WHERE aft.actype = map.aftype AND adt.actype = map.actype
                AND map.aftype = l_aftype and map.actype = l_adtype and map.objname = l_objname;
        EXCEPTION
            WHEN OTHERS THEN l_count := 0;
        END;

        If l_count > 1 then
           p_err_code := -100804;
           return -1;
        End if;
        --/>

        --</ Check trung trong bang aftype
     /*   BEGIN
            Select Count(1) Into l_count From aftype where adtype = l_adtype and actype = l_aftype;
        EXCEPTION
            WHEN OTHERS THEN l_count := 0;
        END;

        If l_count > 0 then
           p_err_code := -100804;
           return -1;
        End if;*/
        --/>
     End If;
    --/>

    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckADTYPE');
      RETURN '-1';
END;


Function fn_CheckIRRATESCHM (RATEID IN varchar2, AUTOID IN varchar2,
                             FRAMT IN varchar2, TOAMT IN varchar2,
                             FRTERM IN varchar2, TOTERM IN varchar2, p_Flag in VARCHAR2, p_err_code out VARCHAR2) return varchar2
IS
    l_FRAMT     NUMBER(20);
    l_TOAMT     NUMBER(20);
    l_FRTERM    NUMBER(20);
    l_TOTERM    NUMBER(20);
    l_RATEID    VARCHAR2(4);
    l_AUTOID    NUMBER;
    l_Count     NUMBER(20);
BEGIN

    l_RATEID    := RATEID;
    l_FRAMT     := FRAMT;
    l_TOAMT     := TOAMT;
    l_FRTERM    := FRTERM;
    l_TOTERM    := TOTERM;
    l_AUTOID    := AUTOID;
    l_Count     := 0;

    --plog.setbeginsection(pkgctx, 'fn_CheckIRRATESCHM');
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.l_AUTOID:' || l_AUTOID);
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.l_RATEID:' || l_RATEID);
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.l_FRAMT:' || l_FRAMT);
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.l_TOAMT:' || l_TOAMT);
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.l_FRTERM:' || l_FRTERM);
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.l_TOTERM:' || l_TOTERM);
    plog.debug (pkgctx, 'fn_CheckIRRATESCHM.p_Flag:' || p_Flag);

    --</Check duplicate
    If Upper(p_Flag) = 'ADD' Then
        Begin
            SELECT COUNT(1) into l_Count FROM IRRATESCHM WHERE RATEID = l_RATEID --AND AUTOID <> l_AUTOID
                AND ((FRAMT <= l_FRAMT AND TOAMT > l_FRAMT) OR (FRAMT < l_TOAMT AND TOAMT >= l_TOAMT))
                AND ((FRTERM <= l_FRTERM AND TOTERM > l_FRTERM) OR (FRTERM < l_TOTERM AND TOTERM >= l_TOTERM));
        EXCEPTION
            WHEN OTHERS
               THEN l_Count := 0;
        END;

        If l_Count <> 0 Then
            p_err_code := '-570001';
            RETURN -570001;
        End If;

    Elsif  Upper(p_Flag) = 'EDIT' Then

        Begin
            SELECT COUNT(1) into l_Count FROM IRRATESCHM WHERE RATEID = l_RATEID AND AUTOID <> l_AUTOID
                AND ((FRAMT <= l_FRAMT AND TOAMT > l_FRAMT) OR (FRAMT < l_TOAMT AND TOAMT >= l_TOAMT))
                AND ((FRTERM <= l_FRTERM AND TOTERM > l_FRTERM) OR (FRTERM < l_TOTERM AND TOTERM >= l_TOTERM));
        EXCEPTION
            WHEN OTHERS
               THEN l_Count := 0;
        END;

        If l_Count <> 0 Then
            p_err_code := '-570001';
            RETURN -570001;
        End If;

    Elsif  Upper(p_Flag) = 'DELETE' Then
        RETURN systemnums.C_SUCCESS;
    End If;
    --/>

    --plog.setendsection(pkgctx, 'fn_CheckIRRATESCHM');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckIRRATESCHM');
      RETURN '-1';
END;

Function fn_CheckChangeAFTYPE (p_aftype IN varchar2, p_afacctno IN varchar2) return varchar2
IS
       l_count NUMBER;
    l_boolean BOOLEAN;
BEGIN
  l_boolean:= TRUE;

  --? Ki?m tra c?ng m?? to?m?i cho l?
  --Thu?ng => Margin: ok
  --Margin => Thu?ng: H?t du n?
  --Bank: S? du b?ng 0, kh?c?BT, d??t h?t b?o l? v??n m?c

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckChangeAFTYPE');
      RETURN '-1';
END;

Function fn_CheckCloseCustodyAccount (p_custid IN varchar2) return varchar2
IS
       l_count NUMBER;
    l_boolean BOOLEAN;
BEGIN
  l_boolean:= TRUE;
  --Ki?m tra nh?ng AFTYPE dang ni?y?t ch? c?r?ng th?d?v?h? d?N & C
  SELECT count(MST.ACCTNO) INTO l_count
  FROM AFMAST MST, AFTYPE TYP WHERE MST.STATUS<>'C' AND MST.STATUS<>'N'
  AND MST.ACTYPE=TYP.ACTYPE AND TYP.ISOTC='N' AND MST.CUSTID=p_custid;

  IF l_count=0 THEN
   plog.setendsection (pkgctx, 'fn_CheckCloseCustodyAccount');
   RETURN systemnums.C_SUCCESS;
  ELSE
   plog.setendsection (pkgctx, 'fn_CheckCloseCustodyAccount');
   RETURN -1;
  END IF;
EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckCloseCustodyAccount');
      RETURN '-1';
END;

Function fn_CheckCloseCustodyCA (p_custid IN varchar2) return varchar2
IS
    l_CIcount NUMBER;
    l_SEcount NUMBER;
    l_boolean BOOLEAN;
BEGIN
    ---kiem tra xem con su kien quyen nao chua phan bo.
    select count(1) into l_CIcount
    from caschd ca, afmast af
    where CA.DELTD ='N' AND CA.amt > 0 AND CA.ISCI='N' AND CA.isexec = 'Y'
        and AF.ACCTNO = CA.AFACCTNO AND AF.CUSTID = P_CUSTID AND CA.STATUS <> 'O';

    select count(1) into l_SEcount
    from caschd ca, afmast af
    where CA.DELTD ='N' AND CA.qtty > 0 AND CA.ISSE='N' AND CA.isexec = 'Y'
        and AF.ACCTNO = CA.AFACCTNO AND AF.CUSTID = P_CUSTID AND CA.STATUS <> 'O';

    IF l_CIcount = 0 AND l_SEcount = 0 THEN
        plog.setendsection (pkgctx, 'fn_CheckCloseCustodyCA');
        RETURN systemnums.C_SUCCESS;
    ELSE
        plog.setendsection (pkgctx, 'fn_CheckCloseCustodyCA');
        RETURN '-200414';
    END IF;

EXCEPTION
WHEN OTHERS
   THEN
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_CheckCloseCustodyCA');
      RETURN '-1';
END;


BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('CSPKS_SYSTEM',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
   -- Enter further code below as specified in the Package spec.
END;

/
