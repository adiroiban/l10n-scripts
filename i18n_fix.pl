#!/usr/bin/perl

use strict;
use Socket; 


my $host = shift || "i18n.ro";
my $url_glosar = shift || "/glosar/data/glosar.txt";
my $port = "80";

my $url_locate = "http://i18n.ro/glosar/index.php?keyword=";
my $url_wiki = "http://i18n.ro/";
my $url_en = "http://dictionare.com/phpdic/enro40.php?field0=";
my $url_dex = "http://dexonline.ro/search.php?cuv=";
my $url_open_tran = "http://en.ro.open-tran.eu/suggest/";
my $header = "Acest email este generat automat și aduce în discuție un termen ce se vrea fixat.\n\n";
my $footer = "--\nPiticul din glosar\nContact: Adi Roiban\n";

my $subject = "Fixare termen -"; #email subject, will be appended with term
########################
# END OF configurable varibales
###############################################################################


my @terms;
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

print SOCKET "GET ".$url_glosar." HTTP/1.1\r\n";
print SOCKET "Host: $host\r\n";
print SOCKET "\r\n";


my $line;
my $i;
$i = 0;
while ($line = <SOCKET>)
{

    #
    # Look after terms that are not fixed.
    #
    if ($line =~ /.*\?.*/){
        chomp($line);
        push(@terms,$line);
    }
}
close SOCKET or die "close: $!";

#get a random line
$line = $terms[int rand($#terms)];

#split by tab
my @el = split(/\t/,$line);
my $link_wiki;
my $link_glosar;
my $link_dex;
my $link_en;

#show subject and header
print "$subject ".$el[0]."\n\n";
print $header;

#escape the term
my $html_esc_term = $el[0];
$html_esc_term =~ tr/ /+/; 


#find a wiki link
if ($el[2] =~ /.*\[\[(.*)\]\].*/){
    $link_wiki = "Wiki: $url_wiki".$1."\n";
} else {
    $link_wiki = "";
}

#link to an en-ro dictionary
$link_en = "EN-RO: ".$url_en.$html_esc_term."\n";

my $link_open_tran = "Open-Tran: ".$url_open_tran.$html_esc_term."\n";

#$el[1] = "(pentru imprimare) orizontal răsturnat, privelişte marină, vedere la mare";

#clean the comment in order to find a dex link
my $tran = $el[1];
$tran =~ s/\Wa //g;
$tran =~ s/\?//g;
$tran =~ s/\(.*\)//g;
$tran =~ s/\[.*\]//g;
my @trans = split(/[,; ]/,$tran);
$link_dex = "";

my $w_esc;
foreach $tran (@trans) {
    $tran = trim($tran);
    $tran =~ tr/ /+/;
    if (($tran ne "")&&(length($tran) > 2)){
        $link_dex .= "DEX: $url_dex$tran\n";
    }
}

$link_glosar = "Glosar: $url_locate$html_esc_term\n";
print   "Termen: ".$el[0]."\n".  
        "Traducere: ".$el[1]."\n".
        "Comentariu: ".$el[2]."\n".
        $link_glosar.
        $link_wiki.
        $link_open_tran.
        $link_en.
        $link_dex.
        "";

print "\nMai sunt de fixat ".scalar(@terms)." termeni.\n\n";

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


