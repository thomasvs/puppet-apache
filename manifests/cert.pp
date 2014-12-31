# = Define: apache::cert
#
# This define deploys certificates.
#
define apache::cert (
  $domain,
  $type,
  $c_owner = 'root',
  $c_group = 'root',
  $c_mode = 0400,
  $c_notify = [],
  $directory = '/etc/pki/tls',
  $source = '/modules/apache/tls',
) {

  # FIXME: we could guess domain and type from name?
  case $type {
    'crt': {
      $dir = 'certs'
      $filename = "${domain}.${type}"
    }
    'key': {
      $dir = 'private'
      $filename = "${domain}.${type}"
    }
    'ca-bundle': {
      $dir = 'certs'
      $filename = "${domain}.ca-bundle.crt"
    }
    default: {
      fail("Unhandled apache::cert type ${type}")
    }

  }

  file {"${directory}/${dir}/${filename}":
    ensure => file,
    source => "puppet://${source}/${dir}/${filename}",
    owner  => $c_owner,
    group  => $c_group,
    mode   => $c_mode,
    notify => $c_notify
  }
  
}
