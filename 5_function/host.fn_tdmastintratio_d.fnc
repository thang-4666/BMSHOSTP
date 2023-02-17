SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_tdmastintratio_D(strACCTNO IN varchar2, strTXDATE IN DATE, dblWITHDRAW IN NUMBER)
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
  v_dblINTRATIO number(20,10);
  v_dblCURRTERM number(10,0);
  v_dblBALANCE number(20,6);
  v_dblRNDNO number(20,6);
  v_dblBASEDAMT number(20,6);
  v_dblDDRAMT number(20,6);
  v_strINTMETHOD varchar2(10);
  v_strSTATUS varchar2(10);
  v_Result  number(20);
BEGIN
    --GET TDMAST ATRIBUTES
    SELECT MST.FRDATE, MST.TODATE, MST.SCHDTYPE, MST.INTRATE, MST.TERMCD, MST.TDTERM,
           MST.BREAKCD, MST.MINBRTERM, MST.INTTYPBRCD, MST.FLINTRATE, MST.BALANCE+MST.BLOCKAMT BALANCE, MST.RNDNO,
           MST.INTMETHOD, MST.DDRAMT, STATUS
    into v_strFRDATE, v_strTODATE, v_strSCHDTYPE, v_dblINTRATE, v_strTERMCD, v_dblTDTERM,
          v_strBREAKCD, v_dblMINBRTERM, v_strINTTYPBRCD, v_dblFLINTRATE, v_dblBALANCE, v_dblRNDNO,
          v_strINTMETHOD, v_dblDDRAMT,v_strSTATUS
    FROM TDMAST MST WHERE MST.ACCTNO = strACCTNO;

    v_dblINTRATIO := 0;

          --He so lai ngay vuot qua TODATE
            --Doi voi tai khoan bi Block va da UnBlock la khong ky han
            --Doi voi tai khoan binh thuong, he so lai an theo ky han cuoi cung.
          If v_strSTATUS ='A' Then
             v_dblINTRATIO := (strTXDATE-v_strTODATE)*(v_dblFLINTRATE/100)/360;
             if v_strSCHDTYPE='F' then
                 --lai suat co dinh
                 if v_strTERMCD = 'D'  then --day of year
                     v_dblINTRATIO:=v_dblINTRATIO+v_dblTDTERM*(v_dblINTRATE/100)/360;
                 elsif v_strTERMCD = 'W' then   --week of year
                     v_dblINTRATIO:=v_dblINTRATIO+v_dblTDTERM*7*(v_dblINTRATE/100)/360;
                 elsif v_strTERMCD = 'M' then   --month of year
                     v_dblINTRATIO:=v_dblINTRATIO+v_dblTDTERM*(v_dblINTRATE/100)/12;
                 end if;
              else
                --lai suat bac thang theo so du
                v_dblBASEDAMT := v_dblBALANCE + v_dblDDRAMT; --so du tinh lai luon bang so du dau ngay
                Begin
                    SELECT INTRATE into v_dblTIERINTRATE FROM TDMSTSCHM
                    WHERE ACCTNO=strACCTNO AND FRAMT <= dblWITHDRAW AND TOAMT > dblWITHDRAW
                    AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;

                    if v_strTERMCD = 'D'  then --day of year
                       v_dblINTRATIO:=v_dblINTRATIO+v_dblTDTERM*(v_dblTIERINTRATE/100)/360;
                    elsif v_strTERMCD = 'W' then   --week of year
                       v_dblINTRATIO:=v_dblINTRATIO+v_dblTDTERM*7*(v_dblTIERINTRATE/100)/360;
                    elsif v_strTERMCD = 'M' then   --month of year
                       v_dblINTRATIO:=v_dblINTRATIO+v_dblTDTERM*(v_dblTIERINTRATE/100)/12;
                    end if;

                Exception when NO_DATA_FOUND then
                   --Khong ap duoc ky han thi lay theo lai suat khong ky han
                   v_dblINTRATIO := (strTXDATE-v_strFRDATE)*(v_dblFLINTRATE/100)/360;
                End;
             End if;

           Else  --Cac tai khoan khong bi Block

             if v_strSCHDTYPE='F' then
                 --lai suat co dinh
                 if v_strTERMCD = 'D'  then --day of year
                     v_dblINTRATIO:=(strTXDATE-v_strTODATE)*(v_dblINTRATE/100)/360 + v_dblTDTERM*(v_dblINTRATE/100)/360;
                 elsif v_strTERMCD = 'W' then   --week of year
                     v_dblINTRATIO:=(strTXDATE-v_strTODATE)*(v_dblINTRATE/100)/360 + v_dblTDTERM*7*(v_dblINTRATE/100)/360;
                 elsif v_strTERMCD = 'M' then   --month of year
                     v_dblINTRATIO:=(strTXDATE-v_strTODATE)*(v_dblINTRATE/100)/360 + v_dblTDTERM*(v_dblINTRATE/100)/12;
                 end if;
              else
                --lai suat bac thang theo so du
                v_dblBASEDAMT := v_dblBALANCE + v_dblDDRAMT; --so du tinh lai luon bang so du dau ngay
                Begin
                    /*SELECT INTRATE into v_dblTIERINTRATE FROM TDMSTSCHM
                    WHERE ACCTNO=strACCTNO AND FRAMT <= v_dblBASEDAMT AND TOAMT >v_dblBASEDAMT
                    AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;*/
                    SELECT INTRATE into v_dblTIERINTRATE FROM TDMSTSCHM
                    WHERE ACCTNO=strACCTNO AND FRAMT <= dblWITHDRAW AND TOAMT >dblWITHDRAW
                    AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;

                    if v_strTERMCD = 'D'  then --day of year
                       v_dblINTRATIO:=(strTXDATE-v_strTODATE)*(v_dblTIERINTRATE/100)/360 + v_dblTDTERM*(v_dblTIERINTRATE/100)/360;
                    elsif v_strTERMCD = 'W' then   --week of year
                       v_dblINTRATIO:=(strTXDATE-v_strTODATE)*(v_dblTIERINTRATE/100)/360 + v_dblTDTERM*7*(v_dblTIERINTRATE/100)/360;
                    elsif v_strTERMCD = 'M' then   --month of year
                       v_dblINTRATIO:=(strTXDATE-v_strTODATE)*(v_dblTIERINTRATE/100)/360 + v_dblTDTERM*(v_dblTIERINTRATE/100)/12;
                    end if;

                Exception when NO_DATA_FOUND then
                   --Khong ap duoc ky han thi lay theo lai suat khong ky han
                   v_dblINTRATIO := (strTXDATE-v_strFRDATE)*(v_dblFLINTRATE/100)/360;
                End;
              End if;
          End if;

    v_Result := dblWITHDRAW*v_dblINTRATIO;
    RETURN v_result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
 
 
 
 
 
 
 
/
