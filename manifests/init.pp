class postgres($version = '9.1') {
	package { "postgresql-${version}":
    alias => postgresql,
    ensure => installed,
    require => Apt::Sources_list['postgresql']
  }

  service { "postgresql":
    ensure => running,
    hasstatus => true,
    require => Package['postgresql']
  }

  # Install postgresql when locale (UTF-8) is defined
  if defined(Exec["/usr/sbin/locale-gen"]) {
    Exec["/usr/sbin/locale-gen"] -> Package["postgresql-${version}"]
  }

  file { "/etc/postgresql/${version}/main/pg_hba.conf":
    source => "puppet:///postgres/pg_hba.conf",
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
}
