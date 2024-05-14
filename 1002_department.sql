/*

CREATE OR REPLACE FUNCTION public.update_department_data()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
		new.object_name := new.object_jdoc->'classData'->>'department_name'; 
		new.object_fullname := new.object_jdoc->'classData'->>'department_name';
		new.object_parent_id := new.object_jdoc->'classData'->>'parent_department_id';
		if new.object_jdoc->'classData'->>'is_structure_department' = '1' then
			new.is_structure_department := true;
		else 
			new.is_structure_department := false;
		end if;
		return new;
	END;
$function$
;

-- public.department definition

-- Drop table

-- DROP TABLE public.department;

CREATE TABLE public.department (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	object_id varchar NULL,
	object_uuid uuid NULL,
	object_name varchar NULL,
	object_fullname varchar NULL,
	object_parent_id varchar NULL,
	object_parent_uuid uuid NULL,
	object_original_data text NULL,
	object_jdoc jsonb NULL,
	node varchar NULL,
	is_structure_department bool NULL,
	CONSTRAINT department_pk PRIMARY KEY (id)
);
CREATE INDEX department_object_id_idx ON public.department USING btree (object_id);
CREATE INDEX department_object_jdoc_idx ON public.department USING gin (object_jdoc jsonb_path_ops);
CREATE INDEX department_object_uuid_idx ON public.department USING btree (object_uuid);

-- Table Triggers

create trigger on_create_department before
insert
    on
    public.department for each row execute function update_department_data();
create trigger on_update_department before
update
    on
    public.department for each row execute function update_department_data();
 
 */

SELECT *
FROM public.department;

select
	id,
	object_id,
	object_name,
	object_jdoc->'classData'->>'head_employee_name' as head_employee,
	object_jdoc->'classData'->>'organization_name' as organization_name
from department
;

MERGE INTO public.department
USING
	(select
		DTR@Message_Source as node,
		false as is_structure_department,
		DTR@Message_Property_id as object_id,
		'' as object_name,
		'' as object_fullname,
		'' as object_parent_id,
		DTR@Message_Property_original_body as object_original_data,
		DTR@Message_Body::jsonb as object_jdoc
	)as src
ON (public.department.object_id=src.object_id)
WHEN matched THEN update
set
	node = 						src.node,
	is_structure_department =	src.is_structure_department,
	object_name =				src.object_name,
	object_fullname =			src.object_fullname,
	object_parent_id =			src.object_parent_id,
	object_original_data =		src.object_original_data,
	object_jdoc =				src.object_jdoc
WHEN NOT matched then
INSERT (object_id, object_name, object_fullname, object_parent_id, object_original_data, object_jdoc, node, is_structure_department)
VALUES (src.object_id, src.object_name, src.object_fullname, src.object_parent_id, src.object_original_data, src.object_jdoc, src.node, src.is_structure_department)
;
