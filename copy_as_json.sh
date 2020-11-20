cat | perl -e '

# read first line to get the column names (header)
$firstLine = <>;

# bail if nothing could read
if(!defined($firstLine)) {
    exit 0;
}

# store the column names
chomp($firstLine);
$firstLine =~ s/\"/\\\"/g;  # escape "
@header = split(/\t/, $firstLine);

$h_cnt = $#header;     # number of columns

# get the column definitions
open(META, $ENV{"SP_BUNDLE_INPUT_TABLE_METADATA"}) or die $!;
@meta = ();
while(<META>) {
    chomp();
    my @arr = split(/\t/);
    push @meta, \@arr;
}
close(META);

print "[\n";

# read row data of each selected row
$rowData=<>;
while($rowData) {

    print "\t{\n";

    # remove line ending
    chomp($rowData);

    # escape "
    $rowData=~s/\"/\\\"/g;

    # split column data which are tab-delimited
    @data = split(/\t/, $rowData);
    for($i=0; $i<=$h_cnt; $i++) {

        # re-escape \t and \n
        $cellData = $data[$i];
        $cellData =~ s/↵/\n/g;
        $cellData =~ s/⇥/\t/g;

        print "\t\t\"$header[$i]\": ";

        # check for data types
        if($cellData eq "NULL") {
            print "null";
        }
        elsif($meta[$i]->[1] eq "integer" || $meta[$i]->[1] eq "float") {
            chomp($cellData);
            $d = $cellData+0;
            print "$d";
        } else {
            chomp($cellData);
            print "\"$cellData\"";
        }

        # suppress last ,
        if($i<$h_cnt) {
            print ",";
        }

        print "\n";

    }

    print "\t}";

    # get next row
    $rowData=<>;

    # suppress last ,
    if($rowData) {
        print ",";
    }

    print "\n";
}

print "]";

' | __CF_USER_TEXT_ENCODING=$UID:0x8000100:0x8000100 pbcopy
