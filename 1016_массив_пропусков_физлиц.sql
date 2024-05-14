
/****
Создание объектов


CREATE OR REPLACE PROCEDURE public.save_passcode_data(
	json_data jsonb,
	node varchar
)
	LANGUAGE plpgsql
AS $procedure$
	begin
		delete from public.person_pass;
	
		with ob_tab as ( 
			select
				x.*
				, x.passcards->'passcards_line' as passcards_line
			from jsonb_to_recordset(json_data) as x(area varchar, person_id varchar, employee_id varchar, name varchar, surname varchar, patronymic varchar, organization_id varchar, organization_name varchar, passcards jsonb) --j(json_data);
		)
		insert into public.person_pass (object_person_id, object_area, object_person_name, object_person_patronymic, object_person_surname, object_person_fullname, object_person_organization_id, object_person_organization_name, object_pass_type, object_pass_code, object_pass_code_w26, node)
		select
			ob_tab.person_id as object_person_id
			, ob_tab.area as object_area
			, ob_tab.name as object_person_name
			, ob_tab.patronymic as object_person_patronymic
			, ob_tab.surname as object_person_surname
			, ob_tab.surname || ' ' || ob_tab.name || ' ' || ob_tab.patronymic as object_person_fullname
			, ob_tab.organization_id as object_person_organization_id
			, ob_tab.organization_name as object_person_organization_name
			, y.type  as object_pass_type
			, y.passcode  as object_pass_code
			, y.passcode_w26  as object_pass_code_w26
			, node
		from
			ob_tab,
			jsonb_to_recordset(ob_tab.passcards_line) as y(type varchar, passcode varchar, passcode_w26 varchar)
		where
			ob_tab.passcards_line @> '[]'
		union all
		select
			ob_tab.person_id as object_person_id
			, ob_tab.area as object_area
			, ob_tab.name as object_person_name
			, ob_tab.patronymic as object_person_patronymic
			, ob_tab.surname as object_person_surname
			, ob_tab.surname || ' ' || ob_tab.name || ' ' || ob_tab.patronymic as object_person_fullname
			, ob_tab.organization_id as object_person_organization_id
			, ob_tab.organization_name as object_person_organization_name
			, y.type  as object_pass_type
			, y.passcode  as object_pass_code
			, y.passcode_w26  as object_pass_code_w26
			, node
		from
			ob_tab,
			jsonb_to_record(ob_tab.passcards_line) as y(type varchar, passcode varchar, passcode_w26 varchar)
		where
			ob_tab.passcards_line @> '{}'
		;

	END;
$procedure$
;

-- public.idm_person definition

-- Drop table

DROP TABLE public.person_pass;

CREATE TABLE public.person_pass (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	object_person_id varchar NULL,
	object_area varchar NULL,
	object_person_name varchar NULL,
	object_person_patronymic varchar NULL,
	object_person_surname varchar NULL,
	object_person_fullname varchar NULL,
	object_person_organization_id varchar NULL,
	object_person_organization_name varchar NULL,
	object_pass_type varchar NULL,
	object_pass_code varchar NULL,
	object_pass_code_w26 varchar NULL,
	node varchar NULL,
	CONSTRAINT person_pass_pk PRIMARY KEY (id)
);
CREATE INDEX person_pass_object_person_id_idx ON public.person_pass USING btree (object_person_id);
CREATE INDEX person_pass_object_person_fullname_idx ON public.person_pass USING btree (object_person_fullname);
CREATE INDEX person_pass_object_person_organization_id_idx ON public.person_pass USING btree (object_person_organization_id);
CREATE INDEX person_pass_object_pass_type_idx ON public.person_pass USING btree (object_pass_type);
CREATE INDEX person_pass_object_pass_code_w26_idx ON public.person_pass USING btree (object_pass_code_w26);

*/

select * from person_pass
--where object_name like '%Васюкова%'
;

call save_passcode_data ('{"classData":{"person":[{"area":"ВСМПО","name":"Сергей","surname":"Зимин","passcards":{"passcards_line":{"type":"PASSCARD","passcode":null,"passcode_w26":"0011483717"}},"person_id":null,"patronymic":"Геннадьевич","employee_id":null,"employee_number":null,"organization_id":null,"organization_name":"ВСАМК"},{"area":"ВСМПО","name":"Мария","surname":"Веретенникова","passcards":{"passcards_line":{"type":"PASSCARD","passcode":null,"passcode_w26":"0002696080"}},"person_id":null,"patronymic":"Сергеевна","employee_id":null,"employee_number":null,"organization_id":null,"organization_name":"ВСАМК"},{"area":"ВСМПО","name":"Александр","surname":"Жирнов","passcards":{"passcards_line":{"type":"PASSCARD","passcode":null,"passcode_w26":"0004010547"}},"person_id":null,"patronymic":"Вадимович","employee_id":null,"employee_number":null,"organization_id":null,"organization_name":"ВСАМК"},{"area":"ВСМПО","name":"Максим","surname":"Катаев","passcards":{"passcards_line":{"type":"PASSCARD","passcode":null,"passcode_w26":"0016616689"}},"person_id":null,"patronymic":"Евгеньевич","employee_id":null,"employee_number":null,"organization_id":null,"organization_name":"ВСАМК"},{"area":"ВСМПО","name":"Даниил","surname":"Мазнев","passcards":{"passcards_line":{"type":"PASSCARD","passcode":null,"passcode_w26":"0002676053"}},"person_id":null,"patronymic":"Евгеньевич","employee_id":null,"employee_number":null,"organization_id":null,"organization_name":"ВСАМК"}]}}'::jsonb->'classData'->'person', 'KADR');
--call save_passcode_data (''::jsonb->'classData'->'person', 'KADR');
