#!/usr/bin/perl -w
# originally written by Vomit (c) June 2008
# updates by Serge van Ginderachter

my $abstractfile = shift @ARGV;
my $copyrightsfile = shift @ARGV;
my $authorsfile = shift @ARGV;
my $contributorsfile = shift @ARGV;
my $reviewersfile = shift @ARGV;
my $pubdate = shift @ARGV;
my $year = shift @ARGV;
my $releaseinfo = shift @ARGV;
my $teacher = shift @ARGV;

# Parse config files

open COPYR,"<$copyrightsfile" or die "Can't open copyrights $copyrightsfile";
while(<COPYR>){
    chomp;
	next if /^#/;
	@COPYRIGHT=split /,/;
	next unless scalar(@COPYRIGHT)==2;
	push @COPYRIGHTS,{
		firstname=>$COPYRIGHT[0],
		lastname=>$COPYRIGHT[1],
	};
}
close COPYR;

open AUTH,"<$authorsfile" or die "Can't open authors $authorsfile";
while(<AUTH>){
    chomp;
	next if /^#/;
	@AUTHOR=split /,/;
	next unless scalar(@AUTHOR)==4;
	push @AUTHORS,{
		firstname=>$AUTHOR[0],
		lastname=>$AUTHOR[1],
		email=>$AUTHOR[2],
		http=>$AUTHOR[3]
	};
}
close AUTH;

open CONTR,"<$contributorsfile" or die "Can't open authors $contributorsfile";
while(<CONTR>){
    chomp;
	next if /^#/;
	@CONTRIBUTOR=split /,/;
	next unless scalar(@CONTRIBUTOR)==4;
	push @CONTRIBUTORS,{
		firstname=>$CONTRIBUTOR[0],
		lastname=>$CONTRIBUTOR[1],
		email=>$CONTRIBUTOR[2],
		http=>$CONTRIBUTOR[3]
	};
}
close CONTR;

open REVW,"<$reviewersfile" or die "Can't open authors $reviewersfile";
while(<REVW>){
    chomp;
	next if /^#/;
	@REVIEWER=split /,/;
	next unless scalar(@REVIEWER)==4;
	push @REVIEWERS,{
		firstname=>$REVIEWER[0],
		lastname=>$REVIEWER[1],
		email=>$REVIEWER[2],
		http=>$REVIEWER[3]
	};
}
close REVW;

print "<author>\n";
if ($teacher) {
		print "<firstname></firstname>\n";
		print "<surname>$teacher</surname>\n";
	}
else {
	# using a loop but only the first author is used by docbook
	foreach $author (@AUTHORS) {
		print "<firstname>$author->{firstname}</firstname>\n";
		print "<surname>$author->{lastname}</surname>\n";
	}
}
print "</author>\n";

# Start output header content.

print "<pubdate>$pubdate</pubdate>\n";
print "<releaseinfo>$releaseinfo</releaseinfo>\n";

open ABSTR,"<$abstractfile" or die "Can't open abstract $abstractfile";
while(<ABSTR>) {
	if(/AUTHORSCONTACT/) {
		$contacts = "<itemizedlist>\n";
		foreach $author (@AUTHORS) {
			$contacts .= "<listitem><para>$author->{firstname} $author->{lastname}: ";
			$contacts .= join(", ",($author->{email},$author->{http}));
			$contacts .= "</para></listitem>\n";
		}
		$contacts .= "</itemizedlist>\n";
		s/AUTHORSCONTACT/$contacts/;
		
	}

	s/YEAR/$year/;

	if(/\[COPYRIGHTS\]/) {
		foreach $copyright (@COPYRIGHTS) {
			push @copyrights, "$copyright->{firstname} $copyright->{lastname}";
		}
		$copyrights=join(", ",@copyrights);
		s/\[COPYRIGHTS\]/$copyrights/;
	}

	if(/\[AUTHORS\]/) {
		foreach $author (@AUTHORS) {
			push @authors, "$author->{firstname} $author->{lastname}";
		}
		$authors=join(", ",@authors);
		s/\[AUTHORS\]/$authors/;
	}

	if(/CONTRIBUTORS/) {
		$contributors = "<itemizedlist>\n";
		foreach $contributor (@CONTRIBUTORS) {
			$contributors .= "<listitem><para>$contributor->{firstname} $contributor->{lastname}: ";
			$contributors .= join(", ",($contributor->{email},$contributor->{http}));
			$contributors .= "</para></listitem>\n";
		}
		$contributors .= "</itemizedlist>\n";
		s/CONTRIBUTORS/$contributors/;
	}		

	if(/REVIEWERS/) {
		$reviewers = "<itemizedlist>\n";
		foreach $reviewer (@REVIEWERS) {
			$reviewers .= "<listitem><para>$reviewer->{firstname} $reviewer->{lastname}: ";
			$reviewers .= join(", ",($reviewer->{email},$reviewer->{http}));
			$reviewers .= "</para></listitem>\n";
		}
		$reviewers .= "</itemizedlist>\n";
		s/REVIEWERS/$reviewers/;
	}

	print;
	
}
