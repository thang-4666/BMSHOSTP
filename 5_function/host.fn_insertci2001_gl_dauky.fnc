SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_insertci2001_gl_dauky (v_frdate varchar2, v_todate varchar2, V_STRBRID varchar2, p_err_code out varchar2) return number
is
    V_IN_DATE           DATE;
    V_F_DATE            DATE;
begin

    V_IN_DATE := TO_DATE(v_frdate,'DD/MM/YYYY');
    V_F_DATE := TO_DATE(v_todate,'DD/MM/YYYY');

      INSERT INTO CI2001_GL_DAUKY(GLACCOUNT,FULLNAME, DAUKY,TXDATE)
    select TRANSSUBTYPE, FULLNAME, DAUKY + CI_CRAMT + OW_CRAMT - CI_DRAMT - OW_DRAMT CUOIKY, V_F_DATE
    from (


        SELECT
            gl.bankacctno TRANSSUBTYPE,  NVL(GL.GLACCOUNT,0) DAUKY, GL.FULLNAME FULLNAME,
            nvl(CI_CRAMT,0) CI_CRAMT,
            nvl(CI_DRAMT,0) CI_DRAMT,
            nvl(OW_CRAMT,0) OW_CRAMT,
            nvl(OW_DRAMT,0) OW_DRAMT

        from (
                select gl.bankacctno,gl.FULLNAME, NVL(ci.dauky,gl.GLACCOUNT) GLACCOUNT, V_IN_DATE txdate from
                    BANKNOSTRO gl left join CI2001_GL_DAUKY ci on gl.bankacctno = ci.GLACCOUNT and ci.txdate = V_IN_DATE
               ) GL ,
           (

            select ci.TRANSSUBTYPE,

                SUM(CASE WHEN ci.TLTXCD IN ('1133','1134','1135','1136','1121') AND ci.TXTYPE = 'C' THEN ci.NAMT ELSE 0 END) CI_CRAMT,
                SUM(CASE WHEN ci.TLTXCD IN ('1133','1134','1135','1136','1121') AND ci.TXTYPE = 'D' THEN ci.NAMT ELSE 0 END) CI_DRAMT,
                SUM(CASE WHEN ci.TLTXCD NOT IN ('1133','1134','1135','1136','1121') AND ci.TXTYPE = 'C' THEN ci.NAMT ELSE 0 END) OW_CRAMT,
                SUM(CASE WHEN ci.TLTXCD NOT IN ('1133','1134','1135','1136','1121') AND ci.TXTYPE = 'D' THEN ci.NAMT ELSE 0 END) OW_DRAMT



            FROM AFMAST AF,
                (

               select * from ci2001dtl where BUSDATE >= V_IN_DATE AND BUSDATE < V_F_DATE


                ) CI
               WHERE CI.ACCTNO = AF.acctno (+)
                   AND (SUBSTR(ci.txnum,1,4) LIKE '%' OR INSTR('%',SUBSTR(ci.txnum,1,4)) >0)
                   and LENGTH(TRANSSUBTYPE) > 0
               group by TRANSSUBTYPE




        ) a where gl.BANKACCTNO  = A.TRANSSUBTYPE(+)
        and gl.bankacctno not in ('12210000061342','12210000344025','12210000440613','12210000440631')
         and NVL(GL.GLACCOUNT,0)>0
         and case when a.TRANSSUBTYPE = '12310000392049' and '%%' = '0001' then 0 else 1 end >0
    ) ;
    COMMIT;
    return 0;
exception when others then
    p_err_code := errnums.C_SYSTEM_ERROR;
    RAISE errnums.E_SYSTEM_ERROR;
end fn_InsertCI2001_GL_DauKy;
 
 
 
 
 
/
