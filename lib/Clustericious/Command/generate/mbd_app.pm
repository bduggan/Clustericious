package Clustericious::Command::generate::mbd_app;

use strict;
use warnings;

use Mojo::Base 'Clustericious::Command';

use File::Find;
use File::Slurp 'slurp';
use File::ShareDir 'dist_dir';
  
has description => <<'EOF';
Generate Clustericious app based on Module::Build::Database.
EOF

has usage => <<"EOF";
usage: $0 generate mbd_app [NAME]
EOF

sub get_data
{
    my ($self, $data, $class) = @_;

    return slurp($data);
}

sub _installfile
{
    my $self = shift;
    my ($templatedir, $file, $class) = @_;

    my $name = lc $class;

    (my $relpath = $file) =~ s/^$templatedir/$class/;
    $relpath =~ s/APPCLASS/$class/g;
    $relpath =~ s/APPNAME/$name/g;

    return if -e $relpath;

    my $content = Mojo::Template->new->render_file( $file, $class );
    return $self->write_file($relpath, $content );
}

sub run
{
    my ($self, $class) = @_;
    $class ||= 'MyClustericiousApp';

    my $templatedir = dist_dir('Clustericious') . "/MbdAppTemplate";

    die "Can't find template.\n" unless -d $templatedir;

    find({wanted => sub { $self->_installfile($templatedir, $_, $class) if -f },
          no_chdir => 1}, $templatedir);
}

1;