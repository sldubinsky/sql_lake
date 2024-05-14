CREATE TABLE public.message_history (
	id uuid NOT NULL DEFAULT gen_random_uuid(),
	message_class_id varchar NULL,
	message_type varchar NULL,
	message_version timestamp NULL,
	message_original_data text NULL,
	message_jdoc jsonb NULL,
	node varchar NULL,
	CONSTRAINT message_history_pk PRIMARY KEY (id)
);
CREATE INDEX message_class_id_idx ON public.message_history USING btree (message_class_id);
CREATE INDEX message_type_idx ON public.message_history USING btree (message_type);
CREATE INDEX message_jdoc_idx ON public.message_history USING gin (message_jdoc jsonb_path_ops);
CREATE INDEX message_history_message_version_idx ON public.message_history (message_version);

INSERT INTO public.message_history
	(message_class_id,message_type,message_version, message_original_data, message_jdoc, node)
values
	(
		'',
		'',
		'',
		'',
		'',
		''
	)
;