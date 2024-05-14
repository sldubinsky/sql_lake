
/****
Создание объектов

CREATE OR REPLACE FUNCTION public.update_equipment_data()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
		new.object_name := new.object_jdoc->'classData'->>'name'; 
		new.object_fullname := new.object_jdoc->'classData'->>'full_name';
		new.object_department_id := new.object_jdoc->'classData'->>'department_id';
		return new;
	END;
$function$
;

-- public.department definition

-- Drop table

-- DROP TABLE public.department;

CREATE TABLE public.equipment (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	object_id varchar NULL,
	object_uuid uuid NULL,
	object_name varchar NULL,
	object_fullname varchar NULL,
	object_department_id varchar NULL,
	object_original_data text NULL,
	object_jdoc jsonb NULL,
	node varchar NULL,
	CONSTRAINT equipment_pk PRIMARY KEY (id)
);
CREATE INDEX equipment_object_id_idx ON public.equipment USING btree (object_id);
CREATE INDEX equipment_object_jdoc_idx ON public.equipment USING gin (object_jdoc jsonb_path_ops);
CREATE INDEX equipment_object_uuid_idx ON public.equipment USING btree (object_uuid);

-- Table Triggers

create trigger on_create_equipment before
insert
    on
    public.equipment for each row execute function update_equipment_data();

create trigger on_update_equipment before
update
    on
    public.equipment for each row execute function update_equipment_data();
*/

select * from equipment;

MERGE INTO public.equipment 
USING
	(select
		'GLOBAL' as node,
		'33' as object_id,
		'<classData></classData>' as object_original_data,
		'{"classData":""}'::jsonb as object_jdoc
	)as src
ON (public.equipment.object_id=src.object_id)
WHEN matched THEN update
set
	node = 						src.node,
	object_original_data =		src.object_original_data,
	object_jdoc =				src.object_jdoc
WHEN NOT matched then
INSERT (object_id, object_original_data, object_jdoc, node)
VALUES (src.object_id, src.object_original_data, src.object_jdoc, src.node)
;
