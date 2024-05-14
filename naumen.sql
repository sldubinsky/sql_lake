select
  ts.id as uuid, --не используется
  CONCAT('?',
  	'registration_date=',TO_CHAR(ts.registration_date, 'dd-mm-yyyy'),
  	'&title=',ts.title,
  	'&barcode=',ts_attr_01.textvalue,
  	'&parentsc=',parent.title,
  	'&employee=',empl.title,
  	'&item_type=',coalesce(ke_attr_02.textvalue, ''),
  	'&item_number=',coalesce(ke_attr_01.textvalue, ''),
  	'&item_orgname=',coalesce(ke_attr_03.textvalue, ''),
  	'&material_number=',ts_attr_01.textvalue,
  	'&material_type=',ts_attr_02.textvalue,
  	'&unit=',ts_attr_04.textvalue,
  	'&qty=',ts_attr_03.textvalue) AS url,
  ts.route as sc_type, -- используется для определения вида печатной формы
 TO_CHAR(ts.registration_date, 'dd-mm-yyyy') as registration_date, --дата регистрации запроса на выдачу\возврат
  ts.title as order_num, --номер запроса на выдачу\возврат
  empl.title fullname, --получающий\возвращающий оборудование
  empl.Last_Name || ' ' || Substring (empl.First_Name, 1, 1) || '. ' || Substring (empl.Middle_Name, 1, 1) || '.'  as employee,  
  parent.title as prnt_order_num, --номер запроса родителя
  configit.configitems_id, --не используется
  coalesce(ke_attr_01.textvalue, '') as item_number, --учетный номер конфигурационной единицы головного запроса
  coalesce(ke_attr_02.textvalue, '') as item_type, --тип оборудования конфигурационной единицы головного запроса
  coalesce(ke_attr_03.textvalue, '') as item_orgname, --имя юрлица, ответственного за конфигурационную единицу
  ts_attr_01.textvalue as material_number, --номенклатурный номер требуемого материала запросана выдачу\возврат
  ts_attr_02.textvalue as material_type, --наименование требуемого материала запросана выдачу\возврат
  ts_attr_03.textvalue as amount, --количество требуемого материала запросана выдачу\возврат
  ts_attr_04.textvalue AS measurement --единица измерения требуемого материала запросана выдачу\возврат
FROM
  tbl_servicecall ts
  inner join tbl_employee empl on ts.username = empl.id
  inner join tbl_servicecall parent on ts.linkedsc = parent.id
  left join tbl_servicec_configit configit on parent.id = configit.servicecall_id
  left join(
      select
          ke.id,
          value.linktemplate,
          value.title,
          value.cleantextvalue as textvalue
      from tbl_objectbase ke
          inner join tbl_objectba_totalval tot on tot.objectbase_id = ke.id
          inner join tbl_totalvalue value on value.id = tot.totalvalue_id
  ) as ke_attr_01 on ke_attr_01.id = configit.configitems_id and ke_attr_01.linktemplate in ('5870409','5870411')
  left join(
      select
          ke.id,
          value.linktemplate,
          value.title,
          value.cleantextvalue as textvalue
      from tbl_objectbase ke
          inner join tbl_objectba_totalval tot on tot.objectbase_id = ke.id
          inner join tbl_totalvalue value on value.id = tot.totalvalue_id
  ) as ke_attr_02 on ke_attr_02.id = configit.configitems_id and ke_attr_02.linktemplate in ('5870410','5870412')
  left join(
      select
          ke.id,
          value.linktemplate,
          value.title,
          value.cleantextvalue as textvalue
      from tbl_objectbase ke
          inner join tbl_objectba_totalval tot on tot.objectbase_id = ke.id
          inner join tbl_totalvalue value on value.id = tot.totalvalue_id
  ) as ke_attr_03 on ke_attr_03.id = configit.configitems_id and ke_attr_03.linktemplate in ('17380632','17380633')
  left join(
      select
          ts.id,
          value.linktemplate,
          value.title,
          value.cleantextvalue as textvalue
      from tbl_servicecall ts
          inner join tbl_servicec_totalval tot on tot.servicecall_id = ts.id
          inner join tbl_totalvalue value on value.id = tot.totalvalue_id
  ) as ts_attr_01 on ts_attr_01.id = ts.id and ts_attr_01.linktemplate in ('5870407')
  left join(
      select
          ts.id,
          value.linktemplate,
          value.title,
          value.cleantextvalue as textvalue
      from tbl_servicecall ts
          inner join tbl_servicec_totalval tot on tot.servicecall_id = ts.id
          inner join tbl_totalvalue value on value.id = tot.totalvalue_id
  ) as ts_attr_02 on ts_attr_02.id = ts.id and ts_attr_02.linktemplate in ('5870408')
  left join(
       SELECT
          SCTV.ServiceCall_Id id,
          TV.TextValue
       from tbl_ServiceC_TotalVal SCTV
          join tbl_TotalValue TV on (TV.id = SCTV.TotalValue_Id)
       where TV.linktemplate in ('17181014')
  ) AS ts_attr_03 on ts_attr_03.id = ts.id
  left join (
       SELECT
           SCTV.ServiceCall_Id id,
           TV.TextValue
       from tbl_ServiceC_TotalVal SCTV 
           join tbl_TotalValue TV on (TV.id = SCTV.TotalValue_Id)
       where TV.linktemplate in ('17284904')
  ) ts_attr_04 on ts_attr_04.id = ts.id
where ts.id = 22063110--DTR@Message_Property_id
--where ts.slmservice = 3739201
--order by ts.creation_date desc
