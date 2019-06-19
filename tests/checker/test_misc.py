# -*- coding: iso-8859-1 -*-
# Copyright (C) 2004-2009 Bastian Kleineidam
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
Test miscellaneous html tag parsing and URL types
"""
from tests import need_network
from . import LinkCheckTest


class TestMisc (LinkCheckTest):
    """
    Test misc link types.
    """

    @need_network
    def test_misc (self):
        self.file_test("misc.html")

    def test_html5 (self):
        self.file_test("html5.html")

    @need_network
    def test_archive (self):
        self.file_test("archive.html")

    @need_network
    def test_itms_services(self):
        url = u"itms-services:?action=download-manifest&url=http://www.example.com/"
        resultlines = [
            u"url %s" % url,
            u"cache key %s" % url,
            u"real url %s" % url,
            u"valid",
            u"url http://www.example.com/",
            u"cache key http://www.example.com/",
            u"real url http://www.example.com/",
            u"valid",
        ]
        self.direct(url, resultlines, recursionlevel=1)
