# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# SocialSharePlugin is Copyright (C) 2015 Michael Daum http://michaeldaumconsulting.com
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

our $VERSION = '0.01';
our $RELEASE = '0.01';
our $SHORTDESCRIPTION = 'dummy description';
our $NO_PREFS_IN_TOPIC = 1;
our $core;

sub core {
  unless (defined $core) {
    require Foswiki::Plugins::SocialSharePlugin::Core;
    $core = new Foswiki::Plugins::SocialSharePlugin::Core();
  }
  return $core;
}

sub initPlugin {

  Foswiki::Func::registerTagHandler('MACRO', sub { return core->MACRO(@_); });

  return 1;
}

sub finishPlugin {
  undef $core;
}

1;
