SET DEFINE OFF;
CREATE OR REPLACE FUNCTION genencryptsha256
  (
    ptext Varchar2,
    pkey  Varchar2
  ) Return Varchar2
 Is
    /*
    Connect on sys and grant
    grant execute on sys.dbms_crypto to BMSHOSTP;
    */
    -- pad const
    c_opad      Raw(1) := '5c';
    c_ipad      Raw(1) := '36';
    c_kpad      Raw(1) := '00';

    --SHA256 block size 512 bit
    c_blocksize Integer := 64;

    --local var, length equals to blocksize
    l_opad        Raw(64);
    l_ipad        Raw(64);
    l_key         Raw(64);
  Begin

    l_opad := utl_raw.copies(c_opad, c_blocksize);
    l_ipad := utl_raw.copies(c_ipad, c_blocksize);

    If utl_raw.length(utl_raw.cast_to_raw(pkey)) > c_blocksize Then
      l_key := utl_raw.cast_to_raw(dbms_crypto_toolkit.sha256.encrypt(pkey));
    Else
      l_key := utl_raw.cast_to_raw(pkey);
    End If;

    l_key := l_key ||
             utl_raw.copies(c_kpad, c_blocksize - utl_raw.length(l_key));

    Return sha256.encrypt_raw(utl_raw.bit_xor(l_key, l_opad) ||
                              sha256.encrypt_raw(utl_raw.bit_xor(l_key, l_ipad) || utl_raw.cast_to_raw(ptext))
                              );

  End;
 
/
