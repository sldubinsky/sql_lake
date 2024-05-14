/*
 * measurement_device
*/

/*
 * 
 * Процедуры создания
 * 
CREATE OR REPLACE FUNCTION public.update_measurement_device_data()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	BEGIN
		new.object_name := new.object_jdoc->'classData'->>'title'; 
		new.object_fullname := new.object_jdoc->'classData'->>'title';
		return new;
	END;
$function$
;

-- public.department definition

-- Drop table

-- DROP TABLE public.department;

CREATE TABLE public.measurement_device (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	object_id varchar NULL,
	object_uuid uuid NULL,
	object_name varchar NULL,
	object_fullname varchar NULL,
	object_original_data text NULL,
	object_jdoc jsonb NULL,
	node varchar NULL,
	CONSTRAINT measurement_device_pk PRIMARY KEY (id)
);
CREATE INDEX measurement_device_object_id_idx ON public.measurement_device USING btree (object_id);
CREATE INDEX measurement_device_object_jdoc_idx ON public.measurement_device USING gin (object_jdoc jsonb_path_ops);
CREATE INDEX measurement_device_object_uuid_idx ON public.measurement_device USING btree (object_uuid);

-- Table Triggers

create trigger on_create_measurement_device before
insert
    on
    public.measurement_device for each row execute function update_measurement_device_data();

create trigger on_update_measurement_device before
update
    on
    public.measurement_device for each row execute function update_measurement_device_data();
 */

select * from measurement_device;

MERGE INTO public.measurement_device 
USING
	(select
		'GLOBAL' as node,
		'33' as object_id,
		'<classData></classData>' as object_original_data,
		'{"classData":""}'::jsonb as object_jdoc
	)as src
ON (public.measurement_device.object_id=src.object_id)
WHEN matched THEN update
set
	node = 						src.node,
	object_original_data =		src.object_original_data,
	object_jdoc =				src.object_jdoc
WHEN NOT matched then
INSERT (object_id, object_original_data, object_jdoc, node)
VALUES (src.object_id, src.object_original_data, src.object_jdoc, src.node)
;
