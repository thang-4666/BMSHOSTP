SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_convert_to_vn(strinput in nvarchar2) return nvarchar2 is
    strconvert nvarchar2(32527);
  begin
    strconvert := translate(strinput,
                            utf8nums.c_FindText,
                            utf8nums.c_ReplText);
    return strconvert;
    exception when others then
        plog.error ('fn_convert_to_vn.strinput:'|| strinput);
        plog.error ('fn_convert_to_vn.Error:'|| SQLERRM || dbms_utility.format_error_backtrace);
  end;
 
/
