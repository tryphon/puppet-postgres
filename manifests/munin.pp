class postgres::munin {
  munin::plugin { postgresql_database_size:
    source => "puppet:///postgres/munin/postgresql_database_size",
    config => "user postgres" 
  }       
  munin::plugin { postgres_queries2_all:
    source => "puppet:///postgres/munin/postgres_queries2_all",
    config => "user postgres" 
  }       
}