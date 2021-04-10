drop table if exists collisions;

create external table collisions
  row format
  serde 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
  stored as avro
  location '${hivevar:collisions_job_output_bucket}'
  tblproperties ('avro.schema.literal'='{
    "name": "Collisions",
    "type": "record",
    "fields": [
      {"name":"street","type":"string"},
      {"name":"zip_code","type":"string"},
      {"name":"person_type","type":"string"},
      {"name":"injury_type","type":"string"},
      {"name":"participants_number","type":"int"}
    ]
  }');

select * from collisions limit 10;

select count(*) from collisions;

drop table if exists zips_boroughs;
create external table zips_boroughs(
    zip_code int,
    boroughs string
  )
  row format
  delimited fields terminated by ","
  stored as textfile
  location '${hivevar:zips_boroughs_bucket}'
  tblproperties("skip.header.line.count"="1");

select * from zips_boroughs limit 10;
select count(*) from zips_boroughs;

add jar ${hivevar:hive_hcatalog_jar};
drop table if exists hive_job_result;
create external table hive_job_result(
    street      string,
    person_type string,
    killed      int,
    injured     int
  )
  row format serde 'org.apache.hive.hcatalog.data.JsonSerDe'
  stored as textfile
  location '${hivevar:hive_job_output_bucket}';

insert overwrite table hive_job_result
  select c.street, c.person_type, max(c.killed) as killed, max(c.injured) as injured
    from (
      select c.street, c.person_type,
        case when c.injury_type = 'killed' then sum(c.participants_number) else 0 end as killed,
        case when c.injury_type = 'injured' then sum(c.participants_number) else 0 end as injured
        from collisions c
        join (
          select distinct c.street, c.zip_code
            from collisions c
            join (
              select c.street, sum(c.participants_number) as participants
                from collisions c
                join zips_boroughs z
                on c.zip_code = z.zip_code
                where z.boroughs = "MANHATTAN"
                group by c.street
                order by participants desc
                limit 3
            ) t
            on c.street = t.street
        ) t
        on c.street = t.street and c.zip_code = t.zip_code
        join zips_boroughs z
        on c.zip_code = z.zip_code
        where z.boroughs = "MANHATTAN"
        group by c.street, c.person_type, c.injury_type
    ) c
  group by c.street, c.person_type;

select * from hive_job_result;
