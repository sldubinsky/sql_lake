
/****
Создание объектов


CREATE OR REPLACE FUNCTION public.update_employee_data()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
		new.object_name := new.object_jdoc->'classData'->>'fullname'; 
		new.object_fullname := new.object_jdoc->'classData'->>'fullname';
		new.object_person_id := new.object_jdoc->'classData'->>'person_id';
		new.object_organization_id := new.object_jdoc->'classData'->>'organization_id';
		new.object_orgstructure_id := new.object_jdoc->'classData'->>'orgstructure_id';
		new.object_structure_department_id := new.object_jdoc->'classData'->>'structure_department_id';
		new.object_department_id := new.object_jdoc->'classData'->>'department_id';
		new.object_position_id := new.object_jdoc->'classData'->>'position_id';
		new.node := new.object_jdoc->'classData'->>'ExternalSystem';
		return new;
	END;
$function$
;

-- public.employee definition

-- Drop table

DROP TABLE public.employee;

CREATE TABLE public.employee (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	object_id varchar NULL,
	object_uuid uuid NULL,
	object_name varchar NULL,
	object_fullname varchar NULL,
	object_person_id varchar NULL,
	object_organization_id varchar NULL,
	object_orgstructure_id varchar NULL,
	object_structure_department_id varchar NULL,
	object_department_id varchar NULL,
	object_position_id varchar NULL,
	object_original_data text NULL,
	object_jdoc jsonb NULL,
	node varchar NULL,
	CONSTRAINT employee_pk PRIMARY KEY (id)
);
CREATE INDEX employee_object_id_idx ON public.employee USING btree (object_id);
CREATE INDEX employee_object_jdoc_idx ON public.employee USING gin (object_jdoc jsonb_path_ops);
CREATE INDEX employee_object_uuid_idx ON public.employee USING btree (object_uuid);

-- Table Triggers

create trigger on_create_employee before
insert
    on
    public.employee for each row execute function update_employee_data();

create trigger on_update_employee before
update
    on
    public.employee for each row execute function update_employee_data();

*/

select * from employee
--where object_name like '%Васюкова%'
;

MERGE INTO public.employee 
USING
	(select
		'33' as object_id,
		'<classData></classData>' as object_original_data,
		'{"classData":""}'::jsonb as object_jdoc
	)as src
ON (public.employee.object_id=src.object_id)
WHEN matched THEN update
set
	object_original_data =		src.object_original_data,
	object_jdoc =				src.object_jdoc
WHEN NOT matched then
INSERT (object_id, object_original_data, object_jdoc)
VALUES (src.object_id, src.object_original_data, src.object_jdoc)
;
