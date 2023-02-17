SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_tdmastintratio(strACCTNO IN varchar2,
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
  v_dblINTRATIO number(20,15);
  v_dblCURRTERM number(10,0);
  v_dblBALANCE number(20,6);
  v_dblRNDNO number(20,6);
  v_dblBASEDAMT number(20,6);
  v_dblDDRAMT number(20,6);
  v_strINTMETHOD varchar2(10);
  v_strSTATUS varchar2(10);
  v_Result  number(20,2);
  v_actype  varchar2(8);
BEGIN
    --GET TDMAST ATRIBUTES
    SELECT MST.FRDATE, MST.TODATE, MST.SCHDTYPE, MST.INTRATE, MST.TERMCD, MST.TDTERM,
           MST.BREAKCD, MST.MINBRTERM, MST.INTTYPBRCD, MST.FLINTRATE, MST.BALANCE+MST.BLOCKAMT BALANCE, MST.RNDNO,
           MST.INTMETHOD, MST.DDRAMT, STATUS, ACTYPE
    into v_strFRDATE, v_strTODATE, v_strSCHDTYPE, v_dblINTRATE, v_strTERMCD, v_dblTDTERM,
          v_strBREAKCD, v_dblMINBRTERM, v_strINTTYPBRCD, v_dblFLINTRATE, v_dblBALANCE, v_dblRNDNO,
          v_strINTMETHOD, v_dblDDRAMT,v_strSTATUS, v_actype
    FROM TDMAST MST WHERE MST.ACCTNO = strACCTNO;

    v_dblINTRATIO := 0;

    --- TH VCBS gui tien tai ngan hang.
    --- dungnh add
    if v_actype = '8888' then
        IF v_strTODATE <= strTXDATE THEN
            v_dblINTRATIO := (v_dblTDTERM)*(v_dblINTRATE/100)/360;
        ELSE
            v_dblINTRATIO :=  GREATEST((strTXDATE-v_strFRDATE),0)*(v_dblFLINTRATE/100)/360;
        END IF;
        RETURN dblWITHDRAW*v_dblINTRATIO;
    end if;
    --- end dungnh

    if v_strBREAKCD='N' AND v_strTODATE >strTXDATE AND v_dblRNDNO=0 then
       v_dblINTRATIO := 0;  --Reset ve 0 neu khong cho phep rut truoc han
    else
       if v_strTODATE<=strTXDATE then    -- dung han
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
                    /*SELECT INTRATE into v_dblTIERINTRATE FROM TDMSTSCHM
                    WHERE ACCTNO=strACCTNO AND FRAMT <= v_dblBASEDAMT AND TOAMT >v_dblBASEDAMT
                    AND FRTERM<=v_dblTDTERM AND TOTERM>v_dblTDTERM;*/
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
       else
          --truoc han
          if v_strSCHDTYPE='F' then
            --he so lai khong ky han cho nhung ngay da gui
            v_dblINTRATIO := (strTXDATE-v_strFRDATE)*(v_dblFLINTRATE/100)/360;
          else
            if v_strTERMCD = 'D'  then --day of year
                 v_dblCURRTERM:=strTXDATE-v_strFRDATE;
            elsif v_strTERMCD = 'W' then   --week of year
                 v_dblCURRTERM:=floor((strTXDATE-v_strFRDATE)/7);
            elsif v_strTERMCD = 'M' then   --month of year
                 v_dblCURRTERM:=floor(MONTHS_BETWEEN(strTXDATE,v_strFRDATE));
            end if;
            --neu nho hon ky han toi thieu thi khong duoc rut
            dbms_output.put_line('v_dblCURRTERM '|| to_char(v_dblCURRTERM));
            dbms_output.put_line('v_dblMINBRTERM '|| to_char(v_dblMINBRTERM));
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
                  dbms_output.put_line('v_dblTIERINTRATE '|| to_char(v_dblTIERINTRATE));
                  v_dblINTRATIO:=(strTXDATE-v_strFRDATE)*(v_dblTIERINTRATE/100)/360;
               elsif v_strINTTYPBRCD = 'S' then
                  --Lai khong ky han
                  v_dblTIERINTRATE:=v_dblFLINTRATE;
                  v_dblINTRATIO:=(strTXDATE-v_strFRDATE)*(v_dblTIERINTRATE/100)/360;
               elsif v_strINTTYPBRCD = 'T' then
                  --chia nho theo tung ky han nho hon (chua code)
                  v_dblINTRATIO:=-1;
               end if;

            end if;
          end if;
       end if;
    end if;
    v_Result := dblWITHDRAW*v_dblINTRATIO;
    RETURN v_result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
