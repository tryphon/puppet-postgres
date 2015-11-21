define postgres::template($ensure = 'present', $script, $encoding = 'UTF-8') {
  $encoding_string = $encoding ? {
    false => "",
    default => "--encoding $encoding"
  }

  if $postgres::version == "8.4" and $encoding == 'UTF-8' {
    $template_string = "--template template0" # require to create UTF8 database
  } else {
    $template_string = ""
  }

  case $ensure {
    present: {
      exec { "Create $name postgres template":
        command => "/usr/bin/createdb $encoding_string $template_string $name && psql -d $name < $script",
        user => "postgres",
        unless => "/usr/bin/psql --no-align -l | grep '^$name|'",
        require => Package[postgresql]
      }
    }
    absent:  {
      exec { "Remove $name postgres db":
        command => "/usr/bin/psql -c \"UPDATE pg_database SET datistemplate = FALSE WHERE datname = '$name';\" $name && /usr/bin/dropdb $name",
        onlyif => "/usr/bin/psql --no-align -l | grep '^$name|'",
        user => "postgres",
        require => Package[postgresql]
      }
    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for postgres::template"
    }
  }
}
