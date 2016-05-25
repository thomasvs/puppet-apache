# == Define: apache::cert
#
# This define deploys certificates.
#
# === Parameters
#
# [*domain*]
#   The domain-like name for which to deploy a certificate; used as part of the filename.
# [*type*]
#   The type of certificate; one of crt, key, ca-bundle
# [*letsencrypt*]
#   If true, symlink letsencrypt certificates instead.
# [*source*]
#   The base directory under puppet:// that points to the tls directory
#
# === Examples
#
#  ::apache::cert { 'wildcard.twovaryingshoes.com.key':
#    domain => 'wildcard.twovaryingshoes.com',
#    type   => 'key',
#    source => '/modules/tvs/profile/httpd/tls',
#  }
#
#  deploys puppet:///modules/tvs/profile/httpd/tls/private/wildcard.twovaryingshoes.com.key
#  to /etc/pki/tls/private/wildcard.twovaryingshoes.com.key
#
define apache::cert (
  $domain,
  $type,
  $c_owner = 'root',
  $c_group = 'root',
  $c_mode = 0400,
  $c_notify = [],
  $directory = '/etc/pki/tls',
  $letsencrypt = false,
  $source = '/modules/apache/tls',
) {

  # FIXME: we could guess domain and type from name?
  case $type {
    'crt': {
      $dir = 'certs'
      $filename = "${domain}.${type}"
      $targetname = "cert.pem"
    }
    'key': {
      $dir = 'private'
      $filename = "${domain}.${type}"
      $targetname = "privkey.pem"
    }
    'ca-bundle': {
      $dir = 'certs'
      $filename = "${domain}.ca-bundle.crt"
      $targetname = "fullchain.pem"
    }
    default: {
      fail("Unhandled apache::cert type ${type}")
    }

  }

  if $letsencrypt {
    file {"${directory}/${dir}/${filename}":
      ensure => link,
      target => "/etc/letsencrypt/live/${domain}/${targetname}",
      owner  => $c_owner,
      group  => $c_group,
      mode   => $c_mode,
      notify => $c_notify
    }
  } elsif $source {
    file {"${directory}/${dir}/${filename}":
      ensure => file,
      source => "puppet://${source}/${dir}/${filename}",
      owner  => $c_owner,
      group  => $c_group,
      mode   => $c_mode,
      notify => $c_notify
    }
  }
}
