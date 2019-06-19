# -*- coding: iso-8859-1 -*-
# Copyright (C) 2000-2014 Bastian Kleineidam
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
"""
Mixin class for URLs that can be fetched over a proxy.
"""
try:  # Python 3
    from urllib import parse
    from urllib import request
    from urllib.parse import splitport
except ImportError:
    from urllib import splitport
    import urllib as request
    import urlparse as parse
import os
from .. import LinkCheckerError, log, LOG_CHECK, url as urlutil, httputil


class ProxySupport (object):
    """Get support for proxying and for URLs with user:pass@host setting."""

    def set_proxy (self, proxy):
        """Parse given proxy information and store parsed values.
        Note that only http:// proxies are supported, both for ftp://
        and http:// URLs.
        """
        self.proxy = proxy
        self.proxytype = "http"
        self.proxyauth = None
        if not self.proxy:
            return
        proxyurl = parse.urlparse(self.proxy)
        self.proxytype = proxyurl.scheme
        if self.proxytype not in ('http', 'https'):
            # Note that invalid proxies might raise TypeError in urllib2,
            # so make sure to stop checking at this point, not later.
            msg = _("Proxy value `%(proxy)s' must start with 'http:' or 'https:'.") \
                 % dict(proxy=proxy)
            raise LinkCheckerError(msg)
        if self.ignore_proxy_host():
            # log proxy without auth info
            log.debug(LOG_CHECK, "ignoring proxy %r", self.proxy)
            self.add_info(_("Ignoring proxy setting `%(proxy)s'.") %
                dict(proxy=proxy))
            self.proxy = None
            return
        log.debug(LOG_CHECK, "using proxy %r", self.proxy)
        self.add_info(_("Using proxy `%(proxy)s'.") % dict(proxy=self.proxy))
        self.proxyhost = proxyurl.hostname
        self.proxyport = proxyurl.port
        if proxyurl.username is not None:
            username = proxyurl.username
            password = proxyurl.password if proxy.password is not None else ""
            auth = "%s:%s" % (username, password)
            self.proxyauth = "Basic "+httputil.encode_base64(auth)

    def ignore_proxy_host (self):
        """Check if self.host is in the $no_proxy ignore list."""
        if request.proxy_bypass(self.host):
            return True
        no_proxy = os.environ.get("no_proxy")
        if no_proxy:
            entries = [parse_host_port(x) for x in no_proxy.split(",")]
            for host, port in entries:
                if host.lower() == self.host and port == self.port:
                    return True
        return False

    def get_netloc(self):
        """Determine scheme, host and port for this connection taking
        proxy data into account.
        @return: tuple (scheme, host, port)
        @rtype: tuple(string, string, int)
        """
        if self.proxy:
            scheme = self.proxytype
            host = self.proxyhost
            port = self.proxyport
        else:
            scheme = self.scheme
            host = self.host
            port = self.port
        return (scheme, host, port)


def parse_host_port (host_port):
    """Parse a host:port string into separate components."""
    host, port = splitport(host_port.strip())
    if port is not None:
        if urlutil.is_numeric_port(port):
            port = int(port)
    return host, port
