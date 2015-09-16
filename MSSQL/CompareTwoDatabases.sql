SELECT * FROM 

(select name, text from sys.syscomments a1 
	inner join (select name, object_id from sys.all_objects a2 where a2.type = 'P') x 
    on a1.id = x.object_id) lcl

inner join

(select name, text from [SUN-LCDB-QA\QA1].LDCQA1.sys.syscomments a1 
inner join (select name, object_id from [SUN-LCDB-QA\QA1].LDCQA1.sys.all_objects a2
where a2.type = 'P') x

on a1.id = x.object_id
) QA
on
lcl.name = qa.name
where lcl.text <> qa.text
