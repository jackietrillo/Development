SELECT * FROM 

(select name, text from sys.syscomments a1 
	inner join (select name, object_id from sys.all_objects a2 where a2.type = 'P') x 
    on a1.id = x.object_id) lcl

inner join

(select name, text from [SERVER\INSTANCE].DATABASE.sys.syscomments a1 
inner join (select name, object_id from [SERVER\INSTANCE].DATABASE.sys.all_objects a2
where a2.type = 'P') x
on a1.id = x.object_id
) QA
on
lcl.name = a1.name
where lcl.text <> a1.text
