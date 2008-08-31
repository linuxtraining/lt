#!/usr/bin/perl -w
# written by Vomit (c) June 2008
# thanks mate - Serge

my $abstractfile = shift @ARGV;
my $authorsfile = shift @ARGV;
my $contributorsfile = shift @ARGV;
my $reviewersfile = shift @ARGV;
my $pubdate = shift @ARGV;
my $year = shift @ARGV;
my $releaseinfo = shift @ARGV;

open AUTH,"<$authorsfile" or die "Can't open authors $authorsfile";
while(<AUTH>){
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

foreach $author (@AUTHORS) {
	print "<author>\n";
	print "<firstname>$author->{firstname}</firstname>\n";
	print "<surname>$author->{lastname}</surname>\n";
	print "</author>\n";
}

print "<pubdate>$pubdate</pubdate>\n";
print "<releaseinfo>$releaseinfo</releaseinfo>\n";

open ABSTR,"<$abstractfile" or die "Can't open abstract $abstractfile";
while(<ABSTR>) {
	if(/AUTHORSCONTACT/) {
		$contacts = "<itemizedlist>\n";
		foreach $author (@AUTHORS) {
			$contacts .= "<listitem>$author->{firstname} $author->{lastname}: ";
			$contacts .= join(", ",($author->{email},$author->{http}));
			$contacts .= "</listitem>\n";
		}
		$contacts .= "</itemizedlist>\n";
		s/AUTHORSCONTACT/$contacts/;
		
	}

	s/YEAR/$year/;

	if(/\[AUTHORS\]/) {
		foreach $author (@AUTHORS) {
			push @authors, "$author->{firstname} $author->{lastname}";
		}
		# uncomment if you feel contributors should be mentioned as authors in the Copyright line
		# foreach $contributor (@CONTRIBUTORS) {
		#	push @authors, "$contributor->{firstname} $contributor->{lastname}";
		# }
		$authors=join(", ",@authors);
		s/\[AUTHORS\]/$authors/;
	}

	if(/CONTRIBUTORS/) {
		$contributors = "<itemizedlist>\n";
		foreach $contributor (@CONTRIBUTORS) {
			$contributors .= "<listitem>$contributor->{firstname} $contributor->{lastname}: ";
			$contributors .= join(", ",($contributor->{email},$contributor->{http}));
			$contributors .= "</listitem>\n";
		}
		$contributors .= "</itemizedlist>\n";
		s/CONTRIBUTORS/$contributors/;
	}		

	if(/REVIEWERS/) {
		$reviewers = "<itemizedlist>\n";
		foreach $reviewer (@REVIEWERS) {
			$reviewers .= "<listitem>$reviewer->{firstname} $reviewer->{lastname}: ";
			$reviewers .= join(", ",($reviewer->{email},$reviewer->{http}));
			$reviewers .= "</listitem>\n";
		}
		$reviewers .= "</itemizedlist>\n";
		s/REVIEWERS/$reviewers/;
	}

	print;
	
}
