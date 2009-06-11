#!/usr/bin/perl
#
# policyd.pl
# Simple socket policy file server
#
# Usage: policyd.pl [-port=N] -file=FILE
# Logs to stdout
#

use strict;
use Socket;

my $NULLBYTE = pack( 'c', 0 );

my $port = 843;
my $filePath;
my $content;

### READ ARGS

while ( my $arg = shift @ARGV )
{
    if ( $arg =~ m/^--port=(\d+)$/ )
    {
        $port = $1;
    }
    elsif ( $arg =~ m/^--file=(.*)/ )
    {
        $filePath = $1;
    }
}

unless ( $filePath )
{
    die "Usage: policyd.pl [--port=N] --file=FILE\n";
}

### READ FILE

-f $filePath or die "No such file: '$filePath'\n";
-s $filePath < 10_000 or die "File probably too large to be a policy file: '$filePath'\n";

local $/ = undef;
open POLICYFILE, "<$filePath" or die "Can't open '$filePath': $!\n";
$content = <POLICYFILE>;
close POLICYFILE;

$content =~ m/cross-domain-policy/ or die "Not a valid policy file: '$filePath'\n";

### BEGIN LISTENING

socket( LISTENSOCK, PF_INET, SOCK_STREAM, getprotobyname( 'tcp' ) ) or die "socket() error: $!";
setsockopt( LISTENSOCK, SOL_SOCKET, SO_REUSEADDR, pack( 'l', 1 ) ) or die "setsockopt() error: $!";
bind( LISTENSOCK, sockaddr_in( $port, INADDR_ANY ) ) or die "bind() error: $!";
listen( LISTENSOCK, SOMAXCONN ) or die "listen() error: $!";

print STDOUT "\nListening on port $port\n\n";

### HANDLE CONNECTIONS

while ( my $clientAddr = accept( CONNSOCK, LISTENSOCK ) )
{
    my ( $clientPort, $clientIp ) = sockaddr_in( $clientAddr );
    my $clientIpStr = inet_ntoa( $clientIp );
    print STDOUT "Connection from $clientIpStr:$clientPort\n";
    
    local $/ = $NULLBYTE;
    my $request = <CONNSOCK>;
    chomp $request;

    if ( $request eq '<policy-file-request/>' )
    {
        print STDOUT "Valid request received\n";
    }
    else
    {
        print STDOUT "Unrecognized request: $request\n\n";
        close CONNSOCK;
        next;
    }

    print CONNSOCK $content;
    print CONNSOCK $NULLBYTE;
    close CONNSOCK;

    print STDOUT "Sent policy file\n\n";
}

# End of file.
