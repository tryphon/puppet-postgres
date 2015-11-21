define postgres::database($ensure, $owner = false, $encoding = 'UTF-8', $template = false) {
    $ownerstring = $owner ? {
        false => "",
        default => "-O $owner"
    }
    $encoding_string = $encoding ? {
        false => "",
        default => "--encoding $encoding"
    }

    $template_string = $template ? {
        false => $default_template_string,
        default => "--template $template"
    }

    case $ensure {
        present: {
            exec { "Create $name postgres db":
                command => "/usr/bin/createdb $ownerstring $encoding_string $template_string $name",
                user => "postgres",
                unless => "/usr/bin/psql --no-align -l | grep '^$name|'",
                require => Package[postgresql]
            }
        }
        absent:  {
            exec { "Remove $name postgres db":
                command => "/usr/bin/drop $name",
                onlyif => "/usr/bin/psql --no-align -l | grep '^$name|'",
                user => "postgres",
                require => Package[postgresql]
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for postgres::database"
        }
    }
}
