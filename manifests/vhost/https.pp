# = Define: apache::vhost::https
#
# This define deploys apache configuration needed for an https virtual host
#
define apache::vhost::https (
  $virtualhost='_default_',
  $virtualhost_ipv6=undef,
  $server_name='localhost.localdomain',
  $server_aliases=undef,
  $includes=undef,
  $default_include=undef,
  $certname='localhost.localdomain',
  $bundlename=undef
) {
  # Main template file
  $all_requires = [
    File["/etc/pki/tls/certs/${certname}.crt"],
    File["/etc/pki/tls/private/${certname}.key"],
  ]
  if $bundlename {
    $requires = [
      $all_requires,
      File["/etc/pki/tls/certs/${bundlename}.crt"]
    ]
    } else {
      $requires = $all_requires
    }

    # FIXME: rename file
    apache_httpd::file { "vhost-https-${name}.inc":
      content => template('apache/vhost/https/vhost-https.inc.erb'),
      require => $requires,
    }

}
