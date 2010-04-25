package Clustericious::App;

use base 'Mojolicious';
use List::Util qw/first/;
use MojoX::Log::Log4perl;

sub startup {
    my $self = shift;

    # Logging
    $ENV{LOG_LEVEL} ||= ( $ENV{HARNESS_ACTIVE} ? "WARN" : "DEBUG" );

    my $name = ref $self;

    my $dir; # dir with log config file.
    my $pattern; # pattern for screen logging

    if ($ENV{HARNESS_ACTIVE}) {
        $pattern = "# %5p: %m%n";
    } else  {
        my @dirs =  ($ENV{HOME}, $self->home, $self->home."/etc", );
        push @dirs, "$_", "$_/etc" if ($_ = $ENV{MOJO_HOME});
        $dir = first { -e "$_/log4perl.conf" } @dirs;
        $pattern =  "[%d] [%Z %H %P] %5p: %m%n";
    }

    Log::Log4perl::Layout::PatternLayout::add_global_cspec('Z', sub {$name});

    my $logger = MojoX::Log::Log4perl->new( $dir ? "$dir/log4perl.conf":
      { # default config
       ($ENV{LOG_FILE} ? (
          "log4perl.rootLogger"              => "$ENV{LOG_LEVEL}, File1",
          "log4perl.appender.File1"          => "Log::Log4perl::Appender::File",
          "log4perl.appender.File1.layout"   => "PatternLayout",
          "log4perl.appender.File1.filename" => "$ENV{LOG_FILE}",
          "log4perl.appender.File1.layout.ConversionPattern" => "[%d] [%Z %H %P] %5p: %m%n",
        ):(
          "log4perl.rootLogger"               => "$ENV{LOG_LEVEL}, SCREEN",
          "log4perl.appender.SCREEN"          => "Log::Log4perl::Appender::Screen",
          "log4perl.appender.SCREEN.layout"   => "PatternLayout",
          "log4perl.appender.SCREEN.layout.ConversionPattern" => "$pattern",
       )),
      # These categories (%c) are too verbose by default :
       "log4perl.logger.Mojolicious"                     => "WARN",
       "log4perl.logger.Mojolicious.Plugin.RequestTimer" => "WARN",
       "log4perl.logger.MojoX.Dispatcher.Routes"         => "WARN",
    });
    $self->log( $logger );

    $self->log->info("Initialized logger to level ".$self->log->level);
    $self->log->info("Log config found in $dir/log4perl.conf") if $dir;
    warn "# Using $dir/log4perl.conf for log config\n" if $dir;

    my $r = $self->routes;
    Clustericious::RouteBuilder->add_routes($self);

    $self->plugins->namespaces(['Clustericious::Plugin']);
    $self->plugin('data_handler');
}

1;
