declare @db int = db_id();
declare @utc datetime2(7) = sysutcdatetime();
declare @TenantColumnName sysname = null;

-- Guess tenant column name
set @TenantColumnName = 
	case
		when db_name() like 'databasename%' then 'CustomerID'
	end;


SELECT
	@db as "@id",
	@@servername as "@server",
	db_name() as "@database",
	getutcdate() as "@extract_date",
	original_login() as "@extract_by",
	(
		SELECT 
			s.schema_id as "@id",
			s.name as "@name"
		FROM
			sys.schemas s
		ORDER BY 
			s.NAME
		for xml path('schema'), type
	) as [schemas],
	(
		select
			t.object_id as "@id",
			t.schema_id as "@schema_id",
			s.name as "@schema",
			t.name as "@name",
			(
				select
					c.column_id as "@id",
					c.name as "@name",
					ty.name as "@type_name",
					c.max_length as "@length",
					case when c.is_nullable = 1 then 1 end as "@nullable",
					case when c.is_identity = 1 then 1 end as "@identity",
					case
						when ty.name in ('char','nchar','varchar','nvarchar','binary','varbinary') then
							ty.name + '(' + case when c.max_length = -1 then 'max' else convert(varchar(50),c.max_length) end + ')'
						else 
							ty.name
					end + 
					case when c.is_identity = 1 then ' identity(1,1)' else '' end +
					case when c.is_nullable = 1 then ' null' else ' not null' end
					as "@type",
					(
						select	
							fk.object_id as "@constraint_id",
							fk.name as "@name",
							fkc.constraint_column_id as "@constraint_colid",
							fkc.referenced_object_id as "@referenced_id",
							fkc.referenced_column_id as "@referenced_colid"
						from
							sys.foreign_key_columns fkc
								inner join sys.foreign_keys fk on 
									fk.object_id = fkc.constraint_object_id
						where
							fkc.parent_object_id = c.object_id and
							fkc.parent_column_id = c.column_id
						order by
							fk.name,
							fkc.constraint_column_id
						for xml path('foreignkey'),type
					) as foreignkeys
				from
					sys.columns c 
						inner join sys.types ty on 
							ty.user_type_id = c.user_type_id
						left join
						(
							select	
								ic.column_id,
								sum(case when i.type = 1 then 1 else 0 end) as ClusterKey,
								sum(case when ic.is_included_column = 0 then 1 else 0 end) as KeyCount,
								sum(case when ic.is_included_column = 1 then 1 else 0 end) as IncludedCount
							from
								sys.index_columns ic 
									inner join sys.indexes i on 
										i.object_id = ic.object_id and
										i.index_id = ic.index_id
							where
								ic.object_id = t.object_id
							group by
								ic.column_id
						) ic on 
							ic.column_id = c.column_id
				where
					c.object_id = t.object_id
				order by
					ic.ClusterKey desc,
					ic.KeyCount desc,
					ic.IncludedCount desc,
					c.column_id

				for
					xml path('column'), type
			) as [columns],
			(
				select
					fk.object_id as "@id",
					fk.name as "@name",
					fk.parent_object_id as "@parent_id",
					fk.referenced_object_id as "@referenced_id",
					1-fk.is_not_trusted as "@trusted",
					1-fk.is_disabled as "@enabled",
					lower(fk.delete_referential_action_desc) as "@on_delete",
					lower(fk.update_referential_action_desc) as "@on_update",
					(
						select
							fkc.constraint_column_id as "@id",
							fkc.parent_object_id as "@parent_id",
							fkc.parent_column_id as "@parent_colid",
							fkc.referenced_object_id as "@referenced_id",
							fkc.referenced_column_id as "@referenced_colid"
						from
							sys.foreign_key_columns fkc
						where
							fkc.constraint_object_id = fk.object_id
						order by
							fkc.constraint_column_id
						for xml path('column'), type
					) as [columns],
					(
						select 
							'FKIndex' as "@type",
							fk.object_id as "@id",
							fk.parent_object_id as "@table_id",
							'Foreign Key ' + fk.name + ' has no index support.'
						where
							not exists
							(
								select 1
								from
									sys.indexes i
								where
									i.object_id = fk.parent_object_id and
									( -- no filter, or filter references a column in the FK
										i.has_filter = 0 or
										exists 
										(
											select
												*
											from
												sys.foreign_key_columns fkc
													inner join sys.columns c on 
														c.object_id = fkc.parent_object_id and
														c.column_id = fkc.parent_column_id
											where
												fkc.constraint_object_id = fk.object_id and
												i.filter_definition like '%'+c.name+'%'
										)
									) and
									not exists
									(
										select 1
										from
											sys.foreign_key_columns fkc
												left join sys.index_columns ic on 
													ic.object_id = fkc.parent_object_id and
													ic.index_id = i.index_id and
													ic.column_id = fkc.parent_column_id
										where
											fkc.constraint_object_id = fk.object_id and
											(ic.column_id is null or fkc.constraint_column_id != ic.index_column_id )
					
									)							
							)
						for 
							xml path('note'), type
					) as notes

				from
					sys.foreign_keys fk
				where
					fk.parent_object_id = t.object_id
				order by
					fk.name
				for
					xml path ('foreignkey'), type
			) as [foreignkeys],	-- START OF INDEXES BLOCK --------------------------------------------------------------------
			( 
				select
					i.index_id as "@id",
					isnull(i.name,'(' + t.name + ')') as "@name",
					case when i.is_primary_key = 1 then 1 end as "@pk",
					i.type_desc as "@type",
					case when i.is_padded = 1 then 1 end as "@padded",
					case when i.is_unique = 1 then 1 end as "@unique",
					case when i.is_unique_constraint = 1 then 1 end as "@unique_constraint",
					case when i.has_filter = 1 then 1 end as "@filtered",
					case when i.has_filter = 1 then i.filter_definition end as "@filter",
					case p.data_compression when 1 then 'row' when 2 then 'page' end as "@compression",
					i.fill_factor as "@fill_factor",
					ps.row_count as "@row_count",
					ps.size_b as "@size_b",
					ps.size_mb as "@size_mb",
					convert(decimal(16,2),case when ps.row_count > 0 then cast((ps.size_b * 100) / ps.row_count as decimal(16,2)) / 100 else 0 end) as "@bytes_per_row",
					iu.reads as "@reads",
					iu.user_lookups as "@lookups",
					iu.user_seeks as "@seeks",
					iu.user_scans as "@scans",
					iu.user_updates as "@updates",
					datediff(second,iu.last_read,@utc) as "@last_read",
					datediff(second,iu.last_user_lookup,@utc) as "@last_lookup",
					datediff(second,iu.last_user_scan,@utc) as "@last_scan",
					datediff(second,iu.last_user_seek,@utc) as "@last_seek",
					datediff(second,iu.last_user_update,@utc) as "@last_update",
					(
						select
							ic.index_column_id as "@id",
							ic.column_id as "@colid",
							ic.key_ordinal as "@key_ordinal",
							ic.is_included_column as "@included",
							case
								when ic.is_included_column = 0 then 'K' + convert(varchar(8),ic.key_ordinal)
								when ic.is_included_column = 1 then 'IN'
								else ''
							end as "@code"

						from
							sys.index_columns ic
						where
							ic.object_id = i.object_id and
							ic.index_id = i.index_id
						order by
							ic.index_column_id
						for
							xml path('column'), type
					) as [columns],


					-- notes

					-- index supports a foreign key.
					--
					-- IIF there exists a foreign key referencing this table where there are no FK columns that are not in the same index position as this index.
					-- excludes filtered indexes
					(
						select
							fk.object_id as "@id",
							fk.referenced_object_id as "@referenced_table_id",
							fk.name as "@name",
							fk_column_count.c as "@fk_columns",
							index_column_count.c as "@index_columns",
							case when fk_column_count.c = index_column_count.c then 1 end as "@pure_fk_index",
							index_column_count.c - fk_column_count.c as "@column_overhang"
						from
							sys.foreign_keys fk
								cross apply
								(
									select count(*) as c
									from sys.foreign_key_columns fkc
									where fkc.constraint_object_id = fk.object_id
								) fk_column_count
								cross apply
								(
									select count(*) as c
									from sys.index_columns ic
									where ic.object_id = i.object_id and ic.index_id = i.index_id
								) index_column_count
						where
							( -- no filter, or filter references a column in the FK
								i.has_filter = 0 or
								exists 
								(
									select
										*
									from
										sys.foreign_key_columns fkc
											inner join sys.columns c on 
												c.object_id = fkc.parent_object_id and
												c.column_id = fkc.parent_column_id
									where
										fkc.constraint_object_id = fk.object_id and
										i.filter_definition like '%'+c.name+'%'
								)
							) and
							fk.parent_object_id = i.object_id and
							not exists
							(
								select 1
								from
									sys.foreign_key_columns fkc
										left join sys.index_columns ic on 
											ic.object_id = fkc.parent_object_id and
											ic.index_id = i.index_id and
											ic.column_id = fkc.parent_column_id
								where
									fkc.constraint_object_id = fk.object_id and
									(ic.column_id is null or fkc.constraint_column_id != ic.index_column_id )
					
							)
						for 
							xml path('fksupport'), type
					) as fksupports,

					-- does there exist any other index on this table with the same key 
					(
						select 
							'KeyCovered' as "@type",
							i.object_id as "@table_id",
							i.index_id as "@this_index_id",
							i2.index_id as "@other_index_id",
							'Index ' + isnull(i.name,t.name) + ' has key covered by ' + isnull(i2.name,t.name)
						from
							sys.indexes i2
						where
							i.is_primary_key = 0 and
							i.type = 2 and
							i2.object_id = i.object_id and
							i2.index_id != i.index_id and
							isnull(i2.filter_definition,'') = isnull(i.filter_definition,'') and
							not exists  -- no column in index key that doesn't exist in index2 key (in same order)
							(
								select 1
								from
									sys.index_columns ic
								where
									ic.object_id = i.object_id and
									ic.index_id = i.index_id and 
									ic.is_included_column = 0 and
									not exists  -- no matching key column in index2
									(
										select 1
										from
											sys.index_columns ic2
										where
											ic2.object_id = i.object_id and
											ic2.index_id = i2.index_id and
											ic2.column_id = ic.column_id and
											ic2.key_ordinal = ic.key_ordinal
									)							
							)
							for 
								xml path('note'), type
					) as notes,

					-- does there exist any other index on this table with the same key and included columns
					(
						select 
							'Covered' as "@type",
							i.object_id as "@table_id",
							i.index_id as "@this_index_id",
							i2.index_id as "@other_index_id",
							'Index ' + isnull(i.name,t.name) + ' is completely covered by ' + isnull(i2.name,t.name)
						from
							sys.indexes i2
						where
							i.is_primary_key = 0 and
							i.type = 2 and
							i2.object_id = i.object_id and
							i2.index_id != i.index_id and
							isnull(i2.filter_definition,'') = isnull(i.filter_definition,'') and
							not exists  -- no column in index key that doesn't exist in index2 key (in same order)
							(
								select 1
								from
									sys.index_columns ic
								where
									ic.object_id = i.object_id and
									ic.index_id = i.index_id and 
									ic.is_included_column = 0 and
									not exists  -- no matching key column in index2
									(
										select 1
										from
											sys.index_columns ic2
										where
											ic2.object_id = i.object_id and
											ic2.index_id = i2.index_id and
											ic2.column_id = ic.column_id and
											ic2.key_ordinal = ic.key_ordinal
									)							
							) and
							not exists  -- no included column in index key that doesn't exist in index2 
							(
								select 1
								from
									sys.index_columns ic
								where
									ic.object_id = i.object_id and
									ic.index_id = i.index_id and 
									ic.is_included_column = 1 and
									not exists  -- no matching column in index2
									(
										select 1
										from
											sys.index_columns ic2
										where
											ic2.object_id = i.object_id and
											ic2.index_id = i2.index_id and
											ic2.column_id = ic.column_id 
									)							
							)
							for 
								xml path('note'), type
					) as notes,

					-- Is this table a heap?
					(
						select 
							'Heap' as "@type",
							i.object_id as "@table_id",
							'Table ' + t.name + ' has no clustered index'
						where
							i.type = 0 
						for 
							xml path('note'), type
					) as notes,

					-- Is this a NC index without @TenantColumnName as its first key?
					(
						select
							'NoOrgID' as "@type",
							i.object_id as "@table_id",
							i.index_id as "@this_index_id",
							'Index ' + i.name + ' does not have '+@TenantColumnName+' as its first key column.',
							(
								select
									c.column_id as "@id",
									ic.key_ordinal as "@ordinal",
									c.name as "@name"
								from
									sys.index_columns ic
										inner join sys.columns c on	
											c.object_id = ic.object_id and
											c.column_id = ic.column_id
								where
									ic.object_id = i.object_id and
									ic.index_id = i.index_id and
									ic.is_included_column = 0 and
									@TenantColumnName is not null
								order by
									ic.key_ordinal
								for 
									xml path('column'), type
							) as columns
						where
							i.is_primary_key = 0 and
							i.type = 2 and
							exists  -- OrganisationID column on table
							(
								select 1
								from
									sys.columns c
								where
									c.object_id = i.object_id and
									c.name = @TenantColumnName
							) and -- First index key is not OrganisationID
							exists
							(
								select 1
								from
									sys.index_columns ic
										inner join sys.columns c on	
											c.object_id = ic.object_id and
											c.column_id = ic.column_id
								where
									ic.object_id = i.object_id and
									ic.index_id = i.index_id and
									ic.key_ordinal = 1 and
									c.name != @TenantColumnName and
									c.name != 'update_timestamp'
							)
						for 
							xml path('note'), type
					) as notes


					from
						sys.indexes i
							outer apply
							(
								select top 1 p.data_compression
								from sys.partitions p 
								where p.object_id = i.object_id and p.index_id = i.index_id
							) p
							outer apply
							(
								select 
									sum(ps.row_count) as row_count,
									sum(cast(ps.used_page_count as bigint)) * 8192 as size_b,
									sum(cast(ps.used_page_count as bigint)) / 128 as size_mb,
									count(*) as partition_count
								from
									sys.dm_db_partition_stats ps
								where
									ps.object_id = i.object_id and
									ps.index_id = i.index_id
							) ps
							outer apply
							(
								select 
									iu.user_seeks,
									iu.user_scans,
									iu.user_lookups,
									iu.user_seeks+iu.user_scans+iu.user_lookups as reads,
									iu.user_updates,
									iu.last_user_seek,
									iu.last_user_scan,
									iu.last_user_lookup,
									iu.last_user_update,
									d.last_read
								from 
									sys.dm_db_index_usage_stats iu
										outer apply
										(
											select max(d.d) as last_read
											from
												(
													select iu.last_user_seek as d union all
													select iu.last_user_lookup union all
													select iu.last_user_scan
												) d
										) d
								where
									iu.database_id = @db and
									iu.object_id = i.object_id and
									iu.index_id = i.index_id
							) iu

					where
						i.object_id = t.object_id
					order by 
						(
							select 
								c.name + '|' as "data()"
							from
								sys.index_columns ic2
									inner join sys.columns c on 
										c.object_id = ic2.object_id and
										c.column_id = ic2.column_id
							where
								ic2.object_id = t.object_id and
								ic2.is_included_column = 0 and
								ic2.index_id = i.index_id
							order by
								ic2.key_ordinal
							for xml path('')
						)
					for
						xml path('index'), type
				) as [indexes]

		from
			sys.tables t
				inner join sys.schemas s on 
					s.schema_id = t.schema_id
		order by
			s.name, t.name
		for 
			xml path('table'), TYPE
	) tables
FOR xml path('database')
