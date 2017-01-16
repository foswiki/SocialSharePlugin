# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# SocialSharePlugin is Copyright (C) 2015-2016 Michael Daum http://michaeldaumconsulting.com
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

package Foswiki::Plugins::SocialSharePlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::JQueryPlugin ();

use constant TRACE => 0; # toggle me

sub writeDebug {
  return unless TRACE;
  #Foswiki::Func::writeDebug("SocialSharePlugin::Core - $_[0]");
  print STDERR "SocialSharePlugin::Core - $_[0]\n";
}

sub new {
  my $class = shift;
  my $session = shift;

  my $this = bless({
    session => $session,
    services => {},
    templates => {},
    @_
  }, $class);

  %{$this->{services}} = %{$Foswiki::cfg{SocialSharePlugin}{Services}}
    if defined $Foswiki::cfg{SocialSharePlugin}{Services};

  return $this;
}

sub SOCIALSHARE {
  my ($this, $params, $topic, $web) = @_;

  writeDebug("called SOCIALSHARE()");

  my $services = $params->{_DEFAULT} || $params->{services};
  my @services = ();
  if ($services) {
    foreach my $service (split(/\s*,\s*/, $services)) {
      push @services, $service if $this->{services}{$service};
    }
  } else {
    foreach my $service (sort keys %{$this->{services}}) {
      push @services, $service if $this->{services}{$service};
    }
  }

  my $url = $params->{url} || Foswiki::Func::getScriptUrl($web, $topic, "view");
  my $tags = $params->{tags} || '';
  my $title = $params->{title} || $this->getTemplate("topictitle") || '';
  my $text = $params->{text} || $title;
  my $media = $params->{media} || '';
  my $type = $params->{type} || 'default';

  $topic = $params->{topic} if defined $params->{topic};
  $web = $params->{web} if defined $params->{web};

  my $include = $params->{include};
  my $exclude = $params->{exclude};
  my $style = $params->{style};
  if (defined $style) {
    $style = "style='$style'";
  } else {
    $style = '';
  }

  ($web, $topic) = Foswiki::Func::normalizeWebTopicName($web, $topic);

  writeDebug("services=".join(", ", @services));
  writeDebug("text=$text");
  writeDebug("media=$media");
  writeDebug("tags=$tags");

  my $format = $params->{format};
  $format = '$link' unless defined $format;

  my @result = ();
  foreach my $service (@services) {
    next if defined $include && $service !~ /$include/i;
    next if defined $exclude && $service =~ /$exclude/i;

    my $label = $type eq 'icons'?'':$service;
    $service = lc($service);
    my $link = $this->getTemplate($service);
    $link =~ s/\$url/$url/g;
    $link =~ s/\$tags/$tags/g;
    $link =~ s/\$tags/$tags/g;
    $link =~ s/\$text/$text/g;
    $link =~ s/\$title/$title/g;
    $link =~ s/\$media/$media/g;
    $link =~ s/\$service/$service/g;
    $link =~ s/\$label/$label/g;
    $link =~ s/\$style/$style/g;

    $link = "<span class='foswikiAlert'>no link for service $service</span>" unless $link;

    my $line = $format;
    $line =~ s/\$link/$link/g;

    push @result, $line if $line;
  }

  return "" unless @result;
  
  my $header = $params->{header};
  $header = $this->getTemplate("header") unless defined $header;

  my $footer = $params->{footer};
  $footer = $this->getTemplate("footer") unless defined $footer;

  my $sep = $params->{separator} || '';

  my $result= $header.join($sep, @result).$footer;

  my $class = "";
  $class = "socialShare_".$type unless $type eq 'default';
  $result =~ s/\$class/$class/g;
  $result =~ s/\$web/$web/g;
  $result =~ s/\$topic/$topic/g;

  return $result;
}

sub addAssets {
  my $this = shift;

  return if $this->{_doneAssets};
  $this->{_doneAssets} = 1;

  Foswiki::Plugins::JQueryPlugin::createPlugin("blockUI");

  my $css = <<'HERE';
<link rel='stylesheet' href='%PUBURLPATH%/%SYSTEMWEB%/SocialSharePlugin/socialshare.css' media='all' />
HERE

  Foswiki::Func::addToZone("head", "SOCIALSHARE", $css);

  my $js = <<'HERE';
<script type='text/javascript' src='%PUBURLPATH%/%SYSTEMWEB%/SocialSharePlugin/socialshare.js'></script>
HERE

  Foswiki::Func::addToZone("script", "SOCIALSHARE", $js, "JQUERYPLUGIN::BLOCKUI");
}

sub getTemplate {
  my ($this, $name) = @_;

  return '' unless $name;

  unless (defined $this->{templates}{$name}) {

    $this->{templates}{_loaded} = Foswiki::Func::loadTemplate("socialshare") 
      unless defined $this->{templates}{_loaded};
   
    my $tmpl = $name;
    $tmpl = "socialshare::".$name unless $name =~ /^socialshare::/; 

    $this->{templates}{$name} = Foswiki::Func::expandTemplate($tmpl) || '';
  }

  return $this->{templates}{$name};
}

1;
