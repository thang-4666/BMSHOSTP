SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE InsertEmailLogTest(p_email       varchar2,
                           p_template_id varchar2,
                           p_data_source varchar2,
                           p_account     varchar2) is

    l_status             char(1) := 'A';
    l_reject_status      char(1) := 'R';
    l_receiver_address   emaillog.email%type;
    l_template_id        emaillog.templateid%type;
    l_datasource         emaillog.datasource%type;
    l_account            emaillog.afacctno%type;
    l_message_type       templates.type%type;
    l_is_required        templates.require_register%type;
    l_aftemplates_autoid aftemplates.autoid%type;
    l_can_create_message boolean := true;
  begin





    l_receiver_address := p_email;
    l_template_id      := p_template_id;
    l_account          := p_account;


    select t.type, t.require_register
      into l_message_type, l_is_required
      from templates t
     where code = l_template_id;


    if l_message_type = 'S' AND p_template_id<>'0321'  then
      l_datasource := fn_convert_to_vn(p_data_source);
    else
      l_datasource := p_data_source;
    end if;

    --Kiem tra xem mau co bat buoc dang ky khong,
    --neu co thi kiem tra xem da duoc dang ky chua
    if l_is_required = 'Y' then
      begin
        select temp.autoid
          into l_aftemplates_autoid
          from aftemplates temp, afmast af
         where af.acctno = l_account and af.custid = temp.custid
           and temp.template_code = l_template_id;

        l_can_create_message := true;

      exception
        when NO_DATA_FOUND then
          l_can_create_message := false;
      end;
    end if;

    if l_can_create_message then
      if l_receiver_address is not null and length(trim(l_receiver_address)) > 0 then
        insert into emaillog
          (autoid,
           email,
           templateid,
           datasource,
           status,
           createtime,
           afacctno)
        values
          (seq_emaillog.nextval,
           l_receiver_address,
           l_template_id,
           l_datasource,
           l_status,
           sysdate,
           l_account);
      else
        insert into emaillog
          (autoid, email, templateid, datasource, status, createtime, note)
        values
          (seq_emaillog.nextval,
           l_receiver_address,
           l_template_id,
           l_datasource,
           l_reject_status,
           sysdate,
           '---');
      end if;
    else
      insert into emaillog
        (autoid, email, templateid, datasource, status, createtime, note)
      values
        (seq_emaillog.nextval,
         l_receiver_address,
         l_template_id,
         l_datasource,
         l_reject_status,
         sysdate,
         'This template not registed yet');
    end if;


  exception
    when others then
     l_reject_status:=0;
  end;
 
 
 
 
/
