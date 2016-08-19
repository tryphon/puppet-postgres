class postgres($version = '9.1', $postgis = false) {
	package { "postgresql-${version}":
    alias => postgresql,
    ensure => installed,
    require => Apt::Sources_list['postgresql']
  }

  $conf_path = "/etc/postgresql/${version}/main/postgresql.conf"

  service { "postgresql":
    ensure => running,
    hasstatus => true,
    require => Package['postgresql']
  }

  # Install postgresql when locale (UTF-8) is defined
  if defined(File["/etc/default/locale"]) {
    File["/etc/default/locale"] -> Package["postgresql-${version}"]
  }

  file { "/etc/postgresql/${version}/main/pg_hba.conf":
    source => ["puppet:///files/postgres/pg_hba.conf.${fqdn}", "puppet:///modules/postgres/pg_hba.conf"],
    group => postgres,
    notify => Service[postgresql],
    require => Package[postgresql]
  }

  apt::sources_list { 'postgresql':
    content => 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main',
    require => Apt::Key_local['postgresql']
  }
  apt::key_local { 'postgresql':
    key => 'ACCC4CF8',
    source => 'puppet:///postgres/apt.key',
  }

  include postgres::munin

  file { "/usr/local/share/postgresql":
    ensure => directory
  }

  if $postgis {
    package { "postgresql-${version}-postgis-2.2":
      alias => postgresql-postgis,
      ensure => installed,
      require => Package["postgresql-${version}"]
    }
  }
}
