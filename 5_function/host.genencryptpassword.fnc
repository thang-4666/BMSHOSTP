SET DEFINE OFF;
CREATE OR REPLACE FUNCTION genencryptpassword(input_string IN varchar2) RETURN VARCHAR2 IS
/*    LR$Source    RAW(128);
    LR$Key       RAW(128);
    LR$Crypted   RAW(2048);
    LR$Decrypted RAW(2048);
    v_strDest VARCHAR2(500);*/
hash_value VARCHAR2(32);
hash_value_str VARCHAR2(32);
BEGIN
/*v_strDest:='';
LR$Source:=utl_raw.cast_to_raw(input_string);
LR$Key:=utl_raw.cast_to_raw('fssc-admin-123');
LR$Crypted := dbms_crypto.encrypt(LR$Source,dbms_crypto.des_cbc_pkcs5, LR$Key);
--LR$Decrypted := dbms_crypto.decrypt(src => LR$Crypted,typ => dbms_crypto.des_cbc_pkcs5, key => LR$Key);
v_strDest:=RAWTOHEX(utl_raw.cast_to_raw(LR$Crypted));
RETURN v_strDest;*/
  if input_string is null then
    return input_string;
  end if;
  hash_value_str := dbms_obfuscation_toolkit.md5 (input_string => input_string)  ;
  select lower(rawtohex(hash_value_str))
    into hash_value
    from dual;
    return hash_value;

--hash_value := dbms_obfuscation_toolkit.md5 (input_string => text);
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
