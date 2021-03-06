# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# SocialSharePlugin is Copyright (C) 2015-2019 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::SocialSharePlugin;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins ();

our $VERSION = '1.10';
our $RELEASE = '14 Feb 2019';
our $SHORTDESCRIPTION = 'Social Share Buttons';
our $NO_PREFS_IN_TOPIC = 1;
our $core;


sub initPlugin {

  Foswiki::Func::registerTagHandler('SOCIALSHARE', sub { return getCore(shift)->SOCIALSHARE(@_); });

  getCore()->addAssets;

  return 1;
}

sub getCore {
  unless (defined $core) {
    my $session = shift || $Foswiki::Plugins::SESSION;

    require Foswiki::Plugins::SocialSharePlugin::Core;
    $core = new Foswiki::Plugins::SocialSharePlugin::Core($session);
  }
  return $core;
}

sub finishPlugin {
  undef $core;
}

1;
