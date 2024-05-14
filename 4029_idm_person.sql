
/****
Создание объектов


CREATE OR REPLACE FUNCTION public.update_idm_person_data()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
		new.object_name := new.object_jdoc->'classData'->>'ShortName'; 
		new.object_fullname := new.object_jdoc->'classData'->>'FullName';
		if new.object_jdoc->'classData'->>'IDM_employee_id' = '' then
			new.object_idm_employee_uuid := null;
		else 
			new.object_idm_employee_uuid := uuid(new.object_jdoc->'classData'->>'IDM_employee_id');
		end if;
		if new.object_jdoc->'classData'->>'IDM_head_id' = '' then
			new.object_idm_head_uuid := null;
		else 
			new.object_idm_head_uuid := uuid(new.object_jdoc->'classData'->>'IDM_head_id');
		end if;
		if new.object_jdoc->'classData'->>'IDM_main_head_person_id' = '' then
			new.object_idm_main_head_person_uuid := null;
		else 
			new.object_idm_main_head_person_uuid := uuid(new.object_jdoc->'classData'->>'IDM_main_head_person_id');
		end if;
		new.object_login_en := new.object_jdoc->'classData'->>'LoginEn';
		new.object_userprincipalname := new.object_jdoc->'classData'->>'userPrincipalName';
		new.object_samaccountname := new.object_jdoc->'classData'->>'sAMAccountName';
		new.object_distinguishedname := new.object_jdoc->'classData'->>'distinguishedName';
		return new;
	END;
$function$
;

-- public.idm_person definition

-- Drop table

DROP TABLE public.idm_person;

CREATE TABLE public.idm_person (
	id uuid NOT NULL,
	object_id varchar NULL,
	object_uuid uuid NULL,
	object_name varchar NULL,
	object_fullname varchar NULL,
	object_idm_employee_uuid uuid NULL,
	object_idm_head_uuid uuid NULL,
	object_idm_main_head_person_uuid uuid NULL,
	object_login_en varchar NULL,
	object_userprincipalname varchar NULL,
	object_samaccountname varchar NULL,
	object_distinguishedname varchar NULL,
	object_original_data text NULL,
	object_jdoc jsonb NULL,
	node varchar NULL,
	CONSTRAINT idm_person_pk PRIMARY KEY (id)
);
CREATE INDEX idm_person_object_id_idx ON public.idm_person USING btree (object_id);
CREATE INDEX idm_person_object_jdoc_idx ON public.idm_person USING gin (object_jdoc jsonb_path_ops);
CREATE INDEX idm_person_object_uuid_idx ON public.idm_person USING btree (object_uuid);

-- Table Triggers

create trigger on_create_idm_person before
insert
    on
    public.idm_person for each row execute function update_idm_person_data();

create trigger on_update_idm_person before
update
    on
    public.idm_person for each row execute function update_idm_person_data();

*/

select * from idm_person
--where object_name like '%Васюкова%'
;

MERGE INTO public.idm_person 
USING
	(select
		uuid('33') as object_uuid,
		'' as node,
		'<classData></classData>' as object_original_data,
		'{"classData":""}'::jsonb as object_jdoc
	)as src
ON (public.idm_person.object_uuid=src.object_uuid)
WHEN matched THEN update
set
	node =					src.node,
	object_original_data =	src.object_original_data,
	object_jdoc =			src.object_jdoc
WHEN NOT matched then
INSERT (id, object_uuid, object_original_data, object_jdoc, node)
VALUES (src.object_uuid, src.object_uuid, src.object_original_data, src.object_jdoc, src.node)
;
