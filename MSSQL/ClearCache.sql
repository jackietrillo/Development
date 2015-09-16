select * from sys.dm_exec_cached_plans
select * from sys.dm_exec_requests
select * from sys.dm_exec_query_memory_grants
select * from sys.dm_exec_query_stats
select * from sys.dm_exec_cursors
select * from sys.dm_exec_xml_handles
select * from sys.dm_exec_query_memory_grants

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
DBCC SHOW_STATISTICS

STATISTICS IO 

DBCC TRACEON (3604);
DBCC PAGE ('pagesplittest', 1, 152, 3)
