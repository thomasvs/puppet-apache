# = Define: apache::vhost::http
#
# This define deploys apache configuration needed for an http virtual host
#
# [* ensure *]
#   What state to ensure for the configuration.
#   Default: present
#
define apache::vhost::http (
  $ensure='present',
  $apache_template='apache/vhost/http/vhost-http.inc.erb',
  $server_name='localhost',
  $server_aliases=undef,
) {
  $default_include = "container-http-${title}.inc"

  # make sure we do not declare the .inc file resource when ensure is absent,
  # so a redirect can be configured in the same filename
  if ($ensure == 'present') {
    apache_httpd::file { "vhost-http-${name}.inc":
      ensure  => file,
      content => template($apache_template),
    }
  }
}
