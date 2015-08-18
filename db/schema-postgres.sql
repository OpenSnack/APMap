
create or replace function uuid_generate_v4()
  returns uuid as '
   SELECT md5(random()::text || clock_timestamp()::text)::uuid
' language sql;

create table sites (
  uuid uuid unique not null default uuid_generate_v4(),
  name varchar(30) not null,
  comment varchar(150),
  map varchar(150)
);

create table aps (
  site uuid not null references sites(uuid) on delete cascade,
  hostname varchar(80) not null,
  x_pos float,
  y_pos float,
  weburl varchar(50),
  jsonurl varchar(50),
  name varchar(80)
);
