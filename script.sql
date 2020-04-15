-- Shows all requests running
select session_id, 
		request_id, 
		start_time, 
		[status], 
		command, 
		database_id, 
		user_id, 
		blocking_session_id, 
		wait_type, 
		wait_time, 
		last_wait_type, 
		wait_resource, 
		cpu_time, 
		total_elapsed_time, 
		percent_complete, 
		estimated_completion_time, 
		open_transaction_count, 
		open_resultset_count, 
		transaction_id, 
		[context_info], 
		scheduler_id, 
		task_address, 
		reads, 
		writes, 
		logical_reads, 
		text_size, 
		[language], 
		/*date_format, 
		date_first, 
		[quoted_identifier], 
		[arithabort], 
		[ansi_null_dflt_on], 
		[ansi_defaults], 
		[ansi_warnings], 
		[ansi_padding], 
		[ansi_nulls], 
		[concat_null_yields_null],*/ 
		transaction_isolation_level, 
		[lock_timeout], 
		[deadlock_priority], 
		row_count, 
		prev_error, 
		nest_level, 
		granted_query_memory, 
		executing_managed_code, 
		group_id, 
		query_hash, 
		query_plan_hash
		[sql_handle], 
		connection_id, 
		statement_start_offset, 
		statement_end_offset, 
		plan_handle
from sys.dm_exec_requests
where [status] not in ('background', 'sleeping')

-- Shows queries that need memory grants
select *
from sys.dm_exec_query_memory_grants 

select a.spid, nt_username, hostname, blocked, [status], cmd, db_name(a.dbid) databasename, 
cpu, physical_io, substring(text, stmt_start/2, 
case stmt_end when -1 then datalength(text)+1 else stmt_end/2 end) , 
last_batch
from master.dbo.sysprocesses a
cross apply sys.dm_exec_sql_text(sql_handle)
WHERE a.cmd <> 'AWAITING COMMAND'

-- Gets queries that have a query plan associated with them
/*select *
from sys.dm_exec_requests
LEFT JOIN sys.dm_exec_cached_plans cp on cp.plan_handle = dm_exec_requests.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) cc
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) */

-- Non-zero values hint towards memory pressure issues
SELECT [waiter_count] -- # of queries waiting for grants to be satisfied.
	,CAST( CASE WHEN ( ([total_memory_kb] - [target_memory_kb] > 0) OR ([total_memory_kb] - [max_target_memory_kb] > 0) ) THEN 1 
				ELSE 0 
			END AS bit) AS [potential_pressure]
FROM sys.dm_exec_query_resource_semaphores

select *
from sys.dm_exec_query_resource_semaphores 

select *
from sys.dm_os_waiting_tasks

-- Shows memory stats for each clerk in SQL Server
SELECT *
FROM sys.dm_os_memory_clerks
ORDER BY pages_kb DESC

SELECT physical_memory_in_use_kb AS Actual_Usage,
	large_page_allocations_kb AS large_Pages,
	locked_page_allocations_kb AS locked_Pages,
	virtual_address_space_committed_kb AS VAS_Committed,
	large_page_allocations_kb + locked_page_allocations_kb + 427000
FROM sys.dm_os_process_memory
