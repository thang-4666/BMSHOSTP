SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_bps
  IS
 --Lay so tien lai du kien cuoi ky
 FUNCTION fnc_get_AdvInt
    ( v_tdtype In Varchar2, v_Amt Number) Return Number;
 --Lay ty le lai du kien cuoi ky
 FUNCTION fnc_get_AdvIntRate
    ( v_tdtype In Varchar2, v_Amt Number) Return Number;
 --Lay ngay tat toan
 FUNCTION fnc_Get_ToDate
    ( v_tdtype In Varchar2) Return Date;

  --Lay ty le lai den ngay hien tai
  FUNCTION fn_Tdmastintratio_Rate(strACCTNO IN varchar2,
    strTXDATE IN DATE, dblWITHDRAW IN NUMBER)  RETURN  number;
END;

 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_bps
IS
   --Lay so tien lai du kien cho khoan gui tiet kiem cuoi ky
   FUNCTION fnc_get_AdvInt
    ( v_tdtype In Varchar2, v_Amt Number) Return Number
    IS

  v_strSYSDATE DATE;
  v_strFRDATE DATE;
  v_strTODATE DATE;
  v_strSCHDTYPE varchar2(10);
  v_dblINTRATE number(20,6);
  v_strTERMCD varchar2(10);
  v_dblTDTERM number(20,6);
  v_strBREAKCD varchar2(10);
  v_dblMINBRTERM number(20,6);
  v_strINTTYPBRCD varchar2(10);
  v_dblFLINTRATE number(20,6);  --saving interest
  v_dblTIERINTRATE number(20,6);
  v_dblINTRATIO number(20,6);
  v_dblCURRTERM number(10,0);
  v_dblBALANCE number(20,6);
  v_dblRNDNO number(20,6);
  v_dblBASEDAMT number(20,6);
  v_dblDDRAMT number(20,6);
  v_strINTMETHOD varchar2(10);
  v_strSTATUS varchar2(10);
  v_Result  number(20);
  v_dblDate number(10);
BEGIN
   SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strSYSDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';
    --GET TDMAST ATRIBUTES
    SELECT MST.SCHDTYPE, MST.INTRATE, MST.TERMCD, MST.TDTERM
    INTO v_strSCHDTYPE, v_dblINTRATE, v_strTERMCD, v_dblTDTERM
    FROM TDTYPE MST  WHERE MST.ACTYPE  = v_tdtype;

    if v_strTERMCD = 'D'  then --day of year
       v_dblDate :=v_dblTDTERM;
    elsif v_strTERMCD = 'W' then   --week of year
       v_dblDate:=v_dblTDTERM*7;
    elsif v_strTERMCD = 'M' then   --month of year
       v_dblDate:= add_months(v_strSYSDATE,v_dblTDTERM) -v_strSYSDATE ;
    end if;

    If v_strSCHDTYPE ='F' Then
        v_Result :=v_dblDate *  v_dblINTRATE * v_Amt;
    Else --Lai suat bac thang

        SELECT INTRATE into v_dblTIERINTRATE FROM TDTYPSCHM
            WHERE ACTYPE=v_tdtype AND FRAMT <= v_Amt AND TOAMT > v_Amt
            AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;
        v_Result :=v_dblDate *  v_dblTIERINTRATE * v_Amt;
    End if;

   RETURN Round(v_result/(360*100),2);

   EXCEPTION When Others then
     Return 0;
   END;


--Lay ty le lai du kien cho khoan gui tiet kiem cuoi ky
   FUNCTION fnc_get_AdvIntRate
    ( v_tdtype In Varchar2, v_Amt Number) Return Number
    IS

  v_strSYSDATE DATE;
  v_strFRDATE DATE;
  v_strTODATE DATE;
  v_strSCHDTYPE varchar2(10);
  v_dblINTRATE number(20,6);
  v_strTERMCD varchar2(10);
  v_dblTDTERM number(20,6);
  v_strBREAKCD varchar2(10);
  v_dblMINBRTERM number(20,6);
  v_strINTTYPBRCD varchar2(10);
  v_dblFLINTRATE number(20,6);  --saving interest
  v_dblTIERINTRATE number(20,6);
  v_dblINTRATIO number(20,6);
  v_dblCURRTERM number(10,0);
  v_dblBALANCE number(20,6);
  v_dblRNDNO number(20,6);
  v_dblBASEDAMT number(20,6);
  v_dblDDRAMT number(20,6);
  v_strINTMETHOD varchar2(10);
  v_strSTATUS varchar2(10);
  v_Result  number(20,10);
  v_dblDate number(10);
BEGIN

   SELECT MST.SCHDTYPE, MST.INTRATE, MST.TERMCD, CASE WHEN MST.TERMCD = 'W' THEN MST.TDTERM * 7 ELSE MST.TDTERM END TDTERM
   INTO v_strSCHDTYPE, v_dblINTRATE, v_strTERMCD, v_dblTDTERM
   FROM TDTYPE MST  WHERE MST.ACTYPE  = v_tdtype;

   If v_strSCHDTYPE ='F' Then
        v_Result :=v_dblINTRATE;
   Else --Lai suat bac thang

     SELECT INTRATE into v_dblTIERINTRATE FROM TDTYPSCHM
            WHERE ACTYPE=v_tdtype AND FRAMT <= v_Amt AND TOAMT > v_Amt
            AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;
        v_Result := v_dblTIERINTRATE ;
    End if;

   RETURN v_result;

   EXCEPTION When Others then
      Return 0;
   END;


  --Lay ty le lai den ngay hien tai.
  FUNCTION fn_Tdmastintratio_Rate(strACCTNO IN varchar2,
    strTXDATE IN DATE, dblWITHDRAW IN NUMBER)
  RETURN  number
  IS
  v_strFRDATE DATE;
  v_strTODATE DATE;
  v_strSCHDTYPE varchar2(10);
  v_dblINTRATE number(20,6);
  v_strTERMCD varchar2(10);
  v_dblTDTERM number(20,6);
  v_strBREAKCD varchar2(10);
  v_dblMINBRTERM number(20,6);
  v_strINTTYPBRCD varchar2(10);
  v_dblFLINTRATE number(20,6);  --saving interest
  v_dblTIERINTRATE number(20,6);
  v_dblINTRATIO number(20,6);
  v_dblCURRTERM number(10,0);
  v_dblBALANCE number(20,6);
  v_dblRNDNO number(20,6);
  v_dblBASEDAMT number(20,6);
  v_dblDDRAMT number(20,6);
  v_strINTMETHOD varchar2(10);
  v_strSTATUS varchar2(10);
  v_Result  number(20,2);
  v_CountDate Number(10);
BEGIN

   INSERT INTO log_err
          (id,date_log, POSITION, text
          )
    VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' pck_bps.fn_Tdmastintratio_Rate ', 'strACCTNO ='||strACCTNO ||' strTXDATE ='||strTXDATE
    ||' dblWITHDRAW ='||dblWITHDRAW
          );

    --GET TDMAST ATRIBUTES
    SELECT MST.FRDATE, MST.TODATE, MST.SCHDTYPE, MST.INTRATE, MST.TERMCD, MST.TDTERM,
           MST.BREAKCD, MST.MINBRTERM, MST.INTTYPBRCD, MST.FLINTRATE, MST.BALANCE, MST.RNDNO,
           MST.INTMETHOD, MST.DDRAMT, STATUS
    into v_strFRDATE, v_strTODATE, v_strSCHDTYPE, v_dblINTRATE, v_strTERMCD, v_dblTDTERM,
          v_strBREAKCD, v_dblMINBRTERM, v_strINTTYPBRCD, v_dblFLINTRATE, v_dblBALANCE, v_dblRNDNO,
          v_strINTMETHOD, v_dblDDRAMT,v_strSTATUS
    FROM TDMAST MST WHERE MST.ACCTNO = strACCTNO;

    v_dblINTRATIO := 0;
    --Tinh xem so ngay rut co lon hon MinBrTerm
    If v_strTERMCD = 'D'  then --day of year
       v_CountDate :=v_dblMINBRTERM;
    Elsif v_strTERMCD = 'W' then   --week of year
       v_CountDate:=v_dblMINBRTERM*7;
    Elsif v_strTERMCD = 'M' then   --month of year
       v_CountDate:= add_months(v_strTODATE,v_dblMINBRTERM) -v_strTODATE ;
    End if;



    if (v_strBREAKCD='N' AND v_strTODATE >strTXDATE AND v_dblRNDNO=0)
       Or (strTXDATE-v_strFRDATE < v_CountDate)
       then
       v_dblINTRATIO := 0;  --Reset ve 0 neu khong cho phep rut truoc han
                            --Hoac ngay rut phai lon hon MinBrTerm
    Else
       If v_strTODATE<=strTXDATE then    -- dung han
          --He so lai ngay vuot qua TODATE
            --Doi voi tai khoan bi Block va da UnBlock la khong ky han
            --Doi voi tai khoan binh thuong, he so lai an theo ky han cuoi cung.
              if v_strSCHDTYPE='F' then
                 --lai suat co dinh
                 v_dblINTRATIO:=v_dblINTRATE;
              else
                --lai suat bac thang theo so du
                v_dblBASEDAMT := v_dblBALANCE + v_dblDDRAMT; --so du tinh lai luon bang so du dau ngay
                Begin
                    SELECT INTRATE into v_dblTIERINTRATE FROM TDMSTSCHM
                    WHERE ACCTNO=strACCTNO AND FRAMT <= v_dblBASEDAMT AND TOAMT >v_dblBASEDAMT
                    AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;

                    v_dblINTRATIO:= v_dblTIERINTRATE;

                Exception when NO_DATA_FOUND then
                   --Khong ap duoc ky han thi lay theo lai suat khong ky han
                   v_dblINTRATIO := (strTXDATE-v_strFRDATE)*(v_dblFLINTRATE/100)/360;
                End;
             End if;
       Else
          --truoc han
          if v_strSCHDTYPE='F' then
            --he so lai khong ky han cho nhung ngay da gui
            v_dblINTRATIO := v_dblFLINTRATE;
          else
            if v_strTERMCD = 'D'  then --day of year
                 v_dblCURRTERM:=strTXDATE-v_strFRDATE;
            elsif v_strTERMCD = 'W' then   --week of year
                 v_dblCURRTERM:=floor((strTXDATE-v_strFRDATE)/7);
            elsif v_strTERMCD = 'M' then   --month of year
                 v_dblCURRTERM:=floor(MONTHS_BETWEEN(strTXDATE,v_strFRDATE));
            end if;
            --neu nho hon ky han toi thieu thi khong duoc rut
            if v_dblMINBRTERM>v_dblCURRTERM then
               v_dblINTRATIO := 0;
            else

               if v_strTERMCD = 'D'  then --day of year
                   v_dblCURRTERM:=strTXDATE-v_strFRDATE;
               elsif v_strTERMCD = 'W' then   --week of year
                   v_dblCURRTERM:=floor((strTXDATE-v_strFRDATE)/7);
               elsif v_strTERMCD = 'M' then   --month of year
                   v_dblCURRTERM:=floor(MONTHS_BETWEEN(strTXDATE,v_strFRDATE));
               end if;

               if v_strINTTYPBRCD = 'L' then
                  if v_strINTMETHOD = 'P' then      --theo so du goc dau ngay
                     v_dblBASEDAMT := v_dblBALANCE + v_dblDDRAMT;
                  elsif v_strINTMETHOD = 'W' then   --theo so tien rut ra
                     v_dblBASEDAMT := dblWITHDRAW;
                  end if;
                 dbms_output.put_line('strACCTNO '|| to_char(strACCTNO));
                  --lai suat theo ky han gan nha
                  SELECT INTRATE into v_dblTIERINTRATE FROM TDMSTSCHM
                  WHERE ACCTNO=strACCTNO AND FRAMT <= v_dblBASEDAMT AND TOAMT >v_dblBASEDAMT
                  AND FRTERM<=v_dblCURRTERM AND TOTERM>v_dblCURRTERM;

                  v_dblINTRATIO:=v_dblTIERINTRATE;
               elsif v_strINTTYPBRCD = 'S' then
                  --Lai khong ky han
                  v_dblTIERINTRATE:=v_dblFLINTRATE;
                  v_dblINTRATIO:=v_dblTIERINTRATE;
               elsif v_strINTTYPBRCD = 'T' then
                  --chia nho theo tung ky han nho hon (chua code)
                  v_dblINTRATIO:=-1;
               end if;

            end if;
          end if;
       end if;
    end if;
    v_Result := v_dblINTRATIO;
    RETURN v_result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;


--Lay ngay dao han
FUNCTION fnc_Get_ToDate
    ( v_tdtype In Varchar2) Return Date
    IS

  v_strSYSDATE DATE;
  v_strFRDATE DATE;
  v_strTODATE DATE;
  v_strSCHDTYPE varchar2(10);
  v_dblINTRATE number(20,6);
  v_strTERMCD varchar2(10);
  v_dblTDTERM number(20,6);
  v_strBREAKCD varchar2(10);
  v_dblMINBRTERM number(20,6);
  v_strINTTYPBRCD varchar2(10);
  v_dblFLINTRATE number(20,6);  --saving interest
  v_dblTIERINTRATE number(20,6);
  v_dblINTRATIO number(20,6);
  v_dblCURRTERM number(10,0);
  v_dblBALANCE number(20,6);
  v_dblRNDNO number(20,6);
  v_dblBASEDAMT number(20,6);
  v_dblDDRAMT number(20,6);
  v_strINTMETHOD varchar2(10);
  v_strSTATUS varchar2(10);
  v_Result  number(20);
  v_dblDate number(10);
BEGIN
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO v_strSYSDATE FROM SYSVAR WHERE VARNAME ='CURRDATE';

   INSERT INTO log_err
          (id,date_log, POSITION, text
          )
    VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' pck_bps.fnc_Get_ToDate ', 'v_tdtype ='||v_tdtype
          );

    --GET TDMAST ATRIBUTES
    SELECT MST.SCHDTYPE, MST.INTRATE, MST.TERMCD, MST.TDTERM
    INTO v_strSCHDTYPE, v_dblINTRATE, v_strTERMCD, v_dblTDTERM
    FROM TDTYPE MST  WHERE MST.ACTYPE  = v_tdtype;

    If v_strTERMCD = 'D'  then --day of year
       v_dblDate :=v_dblTDTERM;
    elsif v_strTERMCD = 'W' then   --week of year
       v_dblDate:=v_dblTDTERM*7;
    elsif v_strTERMCD = 'M' then   --month of year
       v_dblDate:= add_months(v_strSYSDATE,v_dblTDTERM) -v_strSYSDATE ;
    end if;


   RETURN v_strSYSDATE+ v_dblDate;

   EXCEPTION When Others then
      return trunc(sysdate);
   END;
END;

/
