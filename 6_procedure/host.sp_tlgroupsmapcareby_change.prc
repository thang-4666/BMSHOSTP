SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_tlgroupsmapcareby_change
   ( p_grpid IN Varchar2,
     p_grpidcb IN Varchar2,
     p_type IN Varchar2)
   IS
BEGIN
    if p_type = 'REMOVE' then --Xoa thong tin careby cua nhom trc khi insert lai
        delete from tlgroupsmapcareby where grpid = p_grpid;
        Commit;
    ELSIF p_type = 'ADD' then -- Insert lai careby vao cho nhom
        Delete from tlgroupsmapcareby Where grpidcb = p_grpidcb;
        Insert into tlgroupsmapcareby (grpid, grpidcb) values (p_grpid, p_grpidcb);
        Commit;
    end if;
EXCEPTION
    WHEN OTHERS THEN
    RETURN ;
END; -- Procedure
 
 
 
 
/
