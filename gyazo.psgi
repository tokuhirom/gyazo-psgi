use strict;
use warnings;
use 5.12.1;
use Plack::Request;
use Plack::Builder;
use Digest::MD5 qw/md5_hex/;
use Data::Section::Simple qw/get_data_section/;

my $datapath = $ENV{GYAZO_DATA_PATH} || do {
    require File::Temp;
    File::Temp::tempdir(CLEANUP => 1);
};
die "missing datapath: $datapath" unless -d $datapath;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    given ($req->path) {
        when ('/') {
            my $content = get_data_section('index.html');
            return [
                200,
                [
                    'Content-Type'   => 'text/html;charset=utf-8',
                    'Content-Length' => length($content)
                ],
                [$content]
            ];
        }
        when ('/upload') {
            my $imagedata = $req->param('imagedata');
            my $path = md5_hex($imagedata) . '.png';

            # save
            open my $fh, '>', "$datapath/$path" or die "cannot open file: $datapath/$path";
            print {$fh} $imagedata;
            close $fh;

            my $content = $req->base . 'image/' . $path;
            return [
                200,
                [
                    'Content-Type'   => 'text/plain',
                    'Content-Length' => length($content)
                ],
                [$content]
            ];
        }
        when (qr{^/image/([a-f0-9]+\.png)$}) {
            my $path = "$datapath/$1";
            open my $fh, '<', $path or return [404, [], []];
            return [
                200,
                [
                    'Content-Type'   => 'image/png',
                    'Content-Length' => ( -s $path )
                ],
                $fh
            ];
        }
        default {
            [404, [],[]];
        }
    }
};

__DATA__

@@ index.html
<!doctype html>
<html>
<head>
    <title>gyazo@64p.org</title>
</head>
<body>
    <h1>gyzao on 64p.org</h1>
</body>
</html>

