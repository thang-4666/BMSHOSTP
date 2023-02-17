SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI2001" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   GLACCOUNT      IN       VARCHAR2
)
IS

    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2(100);
    V_IN_DATE           DATE;
    V_F_DATE            DATE;
    V_T_DATE            DATE;
    V_BRID              VARCHAR2(4);
    V_GLACCOUNT         VARCHAR2(50);
    V_OW_BEBAL          NUMBER;
    V_DO_BEBAL          NUMBER;
    V_FR_BEBAL          NUMBER;
    v_lnCount           number;
    p_err_code          varchar2(5);

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;
    V_BRID := pv_BRID;
    V_GLACCOUNT:= GLACCOUNT;

    IF V_STROPTION = 'A' THEN
        V_STRBRID := '%%';
    ELSIF V_STROPTION = 'B' AND V_BRID <> 'ALL' AND V_BRID IS NOT NULL THEN
        SELECT MAPID INTO V_STRBRID FROM BRGRP WHERE BRID = V_BRID;
    ELSIF V_STROPTION = 'S' AND V_BRID <> 'ALL' AND V_BRID IS NOT NULL THEN
        V_STRBRID := V_BRID;
    ELSE
        V_STRBRID := V_BRID;
    END IF;

    IF V_GLACCOUNT = 'ALL' THEN
        V_GLACCOUNT:= '%%';
    END IF;

    -- LAY NGAY DAU KY
    V_IN_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_F_DATE := TO_DATE(F_DATE,'DD/MM/YYYY');
    V_T_DATE := TO_DATE(T_DATE,'DD/MM/YYYY');


--DELETE FROM CI2001_GL_DAUKY;





if V_F_DATE = to_date('20/01/2014','dd/mm/rrrr') then

INSERT INTO CI2001_GL_DAUKY(GLACCOUNT,FULLNAME, DAUKY,TXDATE)
    select bankacctno TRANSSUBTYPE, FULLNAME, nvl(glaccount,0), to_date('20/01/2014','dd/mm/rrrr') from banknostro where bankacctno not in ('12210000061342','12210000344025','12210000440613','12210000440631') ;

else

    select count(*) into v_lnCount from CI2001_GL_DAUKY where txdate = V_F_DATE;

    if not v_lnCount > 0 then

        select count(*) into v_lnCount from CI2001_GL_DAUKY where txdate < V_F_DATE;
        if v_lnCount > 0 then
            select max(txdate) into V_IN_DATE from CI2001_GL_DAUKY where txdate < V_F_DATE;
        else
            V_IN_DATE:=  to_date('20/01/2014','dd/mm/rrrr');
        end if;

        -- Insert du lieu den dau ngay V_F_DATE vao bang CI2001_GL_DauKy
        --if fn_InsertCI2001_GL_DauKy(V_IN_DATE, V_F_DATE, V_STRBRID, p_err_code) <> 0 then
        if fn_InsertCI2001_GL_DauKy(TO_CHAR(V_IN_DATE,'dd/mm/rrrr'), TO_CHAR(V_F_DATE,'dd/mm/rrrr'), V_STRBRID, p_err_code) <> 0 then
            p_err_code:= errnums.C_SYSTEM_ERROR; --Loi he thong
            return;
        end if;

    end if;  --- if v_lnCount > 0 then

end if; --- if V_F_DATE = to_date('20/01/2014','dd/mm/rrrr') then

COMMIT;


-- LAY DU LIEU CHUNG KHOAN


/*IF V_F_DATE =  V_T_DATE AND V_T_DATE = getcurrdate THEN
    ci2001_today (PV_REFCURSOR, OPT , BRID, F_DATE , T_DATE , GLACCOUNT);

ELSE*/
OPEN PV_REFCURSOR FOR
select ---nvl(a.txdate,V_T_DATE) txdate ,
a.txdate,
a.txnum, a.custodycd, a.acctno,a.bankacctno, gl.GLACCOUNT TRANSSUBTYPE, a.tltxcd, a.txdesc, nvl(CI_CRAMT,0) CI_CRAMT, nvl(CI_DRAMT,0) CI_DRAMT, nvl(OW_CRAMT,0) OW_CRAMT,
nvl(OW_DRAMT,0) OW_DRAMT, (GL.DAUKY) DAUKY, (gl.fullname) fullname from
(
    SELECT cf.custodycd, a.acctno,a.bankacctno,
        A.TXDATE, A.TXNUM, a.TRANSSUBTYPE,A.TLTXCD, a.TXDESC,
        (CASE WHEN A.TLTXCD IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'C' THEN a.NAMT ELSE 0 END) CI_CRAMT,
        (CASE WHEN A.TLTXCD IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'D' THEN a.NAMT ELSE 0 END) CI_DRAMT,
        (CASE WHEN A.TLTXCD NOT IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'C' THEN a.NAMT ELSE 0 END) OW_CRAMT,
        (CASE WHEN A.TLTXCD NOT IN ('1133','1134','1135','1136','1121') AND a.TXTYPE = 'D' THEN a.NAMT ELSE 0 END) OW_DRAMT

    from (

        select af.custid, af.bankacctno , ci.*

        FROM AFMAST AF,
            (

              select * from ci2001dtl where BUSDATE >= V_F_DATE AND BUSDATE <= V_T_DATE


            ) CI
           WHERE CI.ACCTNO = AF.acctno (+)
               AND (SUBSTR(ci.txnum,1,4) LIKE '%' OR INSTR('%',SUBSTR(ci.txnum,1,4)) >0)
               and LENGTH(TRANSSUBTYPE) > 0

    ) a, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, TLTX TL
    where A.TLTXCD = TL.TLTXCD
    and a.custid = cf.custid (+)
) a, CI2001_GL_DAUKY GL
where --gl.GLACCOUNT = A.TRANSSUBTYPE (+)
      A.TRANSSUBTYPE=gl.GLACCOUNT(+)
    AND gl.GLACCOUNT LIKE V_GLACCOUNT
    and gl.txdate = V_F_DATE
    and nvl(CI_CRAMT,0) + nvl(CI_DRAMT,0) + nvl(OW_CRAMT,0) + nvl(OW_DRAMT,0) <> 0
ORDER BY TXDATE, GLACCOUNT, txnum;

--END IF; ---IF V_F_DATE =  V_T_DATE AND V_T_DATE = getcurrdate THEN

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
