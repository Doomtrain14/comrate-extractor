#!/usr/bin/env raku

#| pre-process download examples from https://quotemedia.com/portal/financials?qm_symbol=AAPL

#| row names test set for Cash Flow
my %row-names = %( 
'Net Income (Loss)'                         => 'Net Income from Continuing Operations',
'Depreciation & Amortisation Expenses'      => 'depreciation and amortization',
'Increase (Decrease) in Other Items'        => 'other cash adjustment outside change in cash',
'Net Cash From Operating Activities'        => 'cash flow from continuing operating activities',
'Capital Expenditure'                       => 'capital expenditure',
'Investment in Other Assets'                => 'net investment purchase and sal',
'Net Cash from Investing Activities'        => 'investing cash flow',
'Dividends or Distributions Paid'           => 'Cash Dividends paid',
'Sale (Repurchase) of Equity'               => 'Repurchase of Capital Stock',
'Proceeds from Issuance of Debt'            => 'Issuance of Debt', 
'Repayments of Long Term Debt'              => 'long term debt payments',
'Other Financing Activities'                => 'net other financing charges',
'Exchange Rate Fluctuations'                => 'Effect of Exchange Rate Changes',
'Net Increase in Cash and Equivalents'      => 'changes in cash',
);

#| zero value rows to keep anyway (since they are in the row names test set)
my %row-keeps = %( 
'Capital Expenditure'                       => 'capital expenditure',
'Sale (Repurchase) of Equity'               => 'Repurchase of Capital Stock',
'Exchange Rate Fluctuations'                => 'Effect of Exchange Rate Changes',
);

#| rows with sum formaulas ... follows quotemedia format ...
#| within a row group the top row is the sum of subsequent rows
#| this hash contains all the top rows and the number of subsequent rows
#| that are operands in the formula (some are all zero so need to be in %row-keeps)
#| keys are the raw row name - ie. values of %row-names
my %row-forms = %(
'depreciation amortization depletion'       => 1,
'deferred tax'                              => 1,
'change in payables and accrued expense'    => 1,
'investing cash flow'                       => 1,
'net ppep and sale'                         => 1,
'net intangibles purchase and sale'         => 1,
'net business purchase and sale'            => 1,
'financing cash flow'                       => 1,
'net common stock issuance'                 => 2,
'Cash Dividends paid'                       => 1,
'end cash position'                         => 3,
);

my $filename = "Annual_CashFlow_AAPL.csv";
my @lines = "inputs/$filename".IO.lines;

my $fh = open "outputs/$filename", :w;

sub cells-all-zero( $line ) {
    my @cells = $line.split(',');           #split cells and remove row name
    @cells.shift;
    (@cells.all eq '-').so;                 #make an all Junction and tests for '-'
}
sub row-keep( $line ) {
    my $row-name = $line.split(',').first;
    for %row-keeps.values -> $name {
        return True if $row-name eq $name;
    }
}

sub make-form( $line, $row-no, @rows-out ) {
    my Bool $b;                 

    my @fm-cells = $line.split(',');           #split cells

    if %row-forms{@fm-cells.first}:exists {

        #randomly pick ==C48+C49+C50 =or= =SUM(C48:C50) 
        my $b-picked = $b.pick;

        my @columns = <A B C D E F>;
        my @formula = [[Nil,],];
        for 1..%row-forms{@fm-cells.first} -> $i {
            my $op-row = @rows-out[*-$i];
            my @op-cells = $op-row.split(',');
            say @op-cells;
            for 1..^@op-cells -> $j {
                #say "i is $i, j is $j";
            
                @formula[$j][$i] = @columns[$j] ~ "{ $row-no + $i }";

                if $b-picked {
                    @fm-cells[$j] = "=SUM(" ~ @formula[$j][1] ~ ":" ~ @formula[$j][*-1] ~ ")";
                } else {
                    @fm-cells[$j] = "=" ~ @formula[$j][1..*].join('+');
                }
            }
        }
        return @fm-cells.join(',')

    } else {
        return $line
    }
    
}

my $row-no = 0;             #track row number in output for formulas 
my @rows-out;               #accumulate output 

for @lines -> $line is rw {

    $line ~~ s:g/'—'/-/;    #suppress unicode used as dash (renders as ‚Äî otherwise)
    $line ~~ s:g/' '/ /;    #suppress unicode used as space (renders as ¬† otherwise)

    $line ~~ s:g/'="' (.*?) '"'/$0/;    #remove unwanted = and ""

    given $line {

        when /'Fiscal Year'/ {
            s:g/',Sep ' (.*?)/,20$0/;
            ++$row-no;
            @rows-out.push: $_
        }

        when ! .&cells-all-zero || .&row-keep {
            ++$row-no;

            #convert some rows to formulae
            my $line-out = make-form( $line, $row-no, @rows-out );

            #convert first cell to Sentence Case
            $line-out ~~ s/(<-[,]>*)/$0.comb(/\w+/).map({.lc.tc}).join(' ')/;

            @rows-out.push: $line-out
        }
    }
}

say @rows-out.join("\n"); 
$fh.say: @rows-out.join("\n")

#`[ working manual .csv example for formulas
1
2
=A1+A2
=SUM(A1:A2)

code design:
* %row-forms hash is all relative
* need to stabilize row numbers for output first
* then can apply new row numbers withon formulas

#]
