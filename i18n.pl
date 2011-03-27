#!/usr/bin/perl

use strict;
use Socket; 


my $host = shift || "i18n.ro";
my $url_recent = shift || "/glosar/recent.php";
my $url_locate = shift || "/glosar/index.php?keyword=";
my $port = "80";
my $past_days = 8 ; #how many days in the past to look for changes

my $header = "Acest email este generat automat și prezintă modificările glosarului din ultima săptămână.\n\n".
                "În cazul în care doriți să discutați o anumită modificare vă rugăm să porniți un nou subiect  dedicat.\nNu este recomandat să răspundeți direct acestui mesaj.\n\n";
my $footer = "--\nPiticul din glosar\nContact: Adi Roiban\n";

my $subject = "Modificări glosar -"; #email subject, will be appended with days interval
########################
# END OF configurable varibales
###############################################################################


# 
# compute last week date as a string
# (perl builtin time functions are very limited
#
my $last_week_time = time() - (60 * 60 * 24 * $past_days);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime($last_week_time);
$year+=1900;
$mon++;
if ($mday < 10) { $mday = "0$mday"; }
if ($mon < 10) { $mon = "0$mon"; }
my $last_week_str = "$year-$mon-$mday";

# get current time
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =                                                localtime();
$year+=1900;
$mon++;
my $this_week_str = "$year-$mon-$mday";

#show subject and header
print "$subject $last_week_str - $this_week_str\n\n";
print $header;

my %match;
sub trim($);
sub INT_handler;
$SIG{'INT'} = 'INT_handler';


my $proto = getprotobyname('tcp');


$| = 1;
    
# get the port address
my $iaddr = inet_aton($host);
my $paddr = sockaddr_in($port, $iaddr);
# create the socket, connect to the port
socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
connect(SOCKET, $paddr) or die "connect: $!";

select(SOCKET); $| = 1; select(STDOUT);

print SOCKET "GET ".$url_recent." HTTP/1.1\r\n";
print SOCKET "Host: $host\r\n";
print SOCKET "\r\n";


my $line;
my $i;
$i = 0;
while ($line = <SOCKET>)
{

    #<tr class=light><td class=date onClick="edit('zzz')">2008-12-17 13:03:10</td><td onClick="edit('zzz')">zzz</td><td>!</td><td onClick="edit('zzz')">(ignoră traducerea, termenul este folosit pentru testare)</td><td>82-78-39-13.rdsnet.ro</td></tr>
    #
    # Look after the good line.
    #
    if ($line =~ m#^<tr class=light><td class=date onClick=.*#){
        last;
    }
}
close SOCKET or die "close: $!";

my @entries;
my $html_esc;
my ($link_web, $link_wiki, $g_word, $g_data, $g_comment, $g_trans, $g_ip);
@entries = split(/<tr/, $line);
foreach $line (@entries){
    # 1 - data
    # 2 - termen
    # 3 - comentariu
    # 4 - traducere
    # 5 - ip
    if ($line =~ m#.*<td class=date onClick=\"edit\('.*'\)\">(\d{4}-\d{2}-\d{2}) \d{2}:\d{2}:\d{2}</td><td onClick=\"edit\('.*'\)\">(.*)</td><td>(.*)</td><td onClick=\"edit\('.*'\)\">(.*)</td><td>(.*)</td></tr>.*#){
        if ( !defined( $match{$2} ) ){
            $match{$2} = 1;
            $g_word = $2;
            $g_data = $1;
            $g_comment = $3;
            $g_trans = $4;
            $g_ip = $5;
            $html_esc = $2;
            $html_esc =~ tr/ /+/; 
            if ($last_week_str le $1) {
                $link_web = "Web: http://$host$url_locate$html_esc\n";
                if ($g_comment =~ /.*\[\[.*\]\].*/){
                    $link_wiki = "Wiki: http://$host/$g_word\n";
                } else {
                    $link_wiki = "";
                }
                print "----\nTermen: $g_word\nTraducere: $g_trans\nComentariu: $g_comment\nData/IP: $g_data,$g_ip\n$link_web$link_wiki\n";
            }
        }
    }
}
print $footer;


###########
# subroutines definition
#

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub INT_handler {
    print "Ctrl+c was pressed!\n";
    exit(0);

}


