#!/usr/bin/perl
use strict;
use lib "/home/siyang/USER/huangshujia/Bin/PerlBin/pm/i/Statistic";
use Statistic;

#test_PairedTTest();
#test_TTest();
#test_SingleTTest();
#test_TTest();
test_ChiSqr();

sub test_PairedTTest {

	 my @before_values = ( 2.56, 2.73, 3.05, 2.87, 2.46, 2.93, 2.41, 2.58, 2.89, 2.76 );
	 my @after_values  = ( 3.12, 3.03, 2.86, 2.53, 2.79, 2.80, 2.96, 2.68, 2.89, 2.76 );

    for ( my $i = 0; $i < @before_values; ++$i ) { $before_values[$i] /= 10 ;}
    for ( my $i = 0; $i < @after_values; ++$i ) { $after_values[$i] /= 10 ;}

	my ( $pvalue, $name ) = Statistic::PairedTTest( \@before_values, \@after_values );
	print "( $pvalue, $name )\n";
}

sub test_TTest {

	#my @before_values=( 30.02,29.99,30.11,29.97,30.01,29.99 );
    #my @after_values =( 29.89,29.93,29.72,29.98,30.02,29.98 );

	my @before_values = ( 2.56, 2.73, 3.05, 2.87, 2.46, 2.93, 2.41, 2.58, 2.89, 2.76 );
	my @after_values  = ( 3.12, 3.03, 2.86, 2.53, 2.79, 2.80, 2.96, 2.68, 2.89 );
@before_values = ( 80, 50, 95 );
@after_values  = ( 8, 5, 13);

	#   for ( my $i = 0; $i < @before_values; ++$i ) { $before_values[$i] *= 10 ;}
	#   for ( my $i = 0; $i < @after_values; ++$i ) { $after_values[$i] *= 10 ;}


	my ( $pvalue, $name ) = Statistic::TTest( \@before_values, \@after_values );

	print "( $pvalue, $name )\n";
}

sub test_SingleTTest {

	my @data = ( -1,1,0,-2,2, -3,3 -100, 100 );
#	my @d    = ( 48/51, 45/48, 1/1, 1/1, 78/79, 78/79, 17/18, 29/31, 38/40 );
#	my @data = ( 0/0, 0/0, 50/51, 0/0, 17/17 - 78/79, 32/32-78/79, 11/11 - 17/18, 0/1, 71/74 - 38/40);
#	my @data = ( 0 - 48/51, 0 - 45/48, 50/51 - 1/1, 0 - 1/1, 17/17 - 78/79, 32/32-78/79, 11/11 - 17/18, 0/1 - 29/31, 71/74 - 38/40);
	#my ( $pvalue, $name ) = Statistic::SingleTTest ( [@data[4,5,6,8]], 0 );
#	my ( $pvalue, $name ) = Statistic::SingleTTest ( [@data[4]], 0 );
	my ( $pvalue, $name ) = Statistic::SingleTTest ( \@data, 0 );

	print "( $pvalue, $name )\n";
}
sub test_ChiSqr {

	#my @data = ( [ 21,35 ], [ 13, 63 ] ); 
	#my @data = ( [ 13, 24 ], [ 7, 33 ] ); 
	#my @data = ( [ int((0+0+0+1+3+1)/6+0.5),int(0.5+(16+9+15+9+16+10)/6) ], [int((7+2+10+8+11+9)/6+0.5),int(.5+(9+18+5+11+5+11)/6)] ); 

	#my @data = ( [ int((11+9+9+5)/4),int((5+11+7+10)/4) ], [int((3+1+0+1)/4),int((13+9+11+12)/4)] );
	#my @data = ( [ int((11+9+9+5+9+5+7+5+6+6+12+8)/12+0.5),int((5+11+7+10+8+13+7+11+12+13+7+9)/12+0.5) ], [int((3+1+0+1+2+0+1+1+3+1+4+1)/12+0.5),int((13+9+11+12+16+16+19+15+17+15+18+9)/12+0.5)] );
	#my @data = ( [ int((11+9+9+5+9+5+7+5+6+6+12+8+8+10)/14+0.5),int((5+11+7+10+8+13+7+11+12+13+7+9+13+7)/14+0.5) ], [int((3+1+0+1+2+0+1+1+3+1+4+1+2+5)/14+0.5),int((13+9+11+12+16+16+19+15+17+15+18+9+11+22)/14+0.5)] );
	#my @data = ( [ int((9+5+7+5+6+6+12+8+8+10)/10+0.5),int((8+13+7+11+12+13+7+9+13+7)/10+0.5) ], [int((2+0+1+1+3+1+4+1+2+5)/10+0.5),int((16+16+19+15+17+15+18+9+11+22)/10+0.5)] );
	#print "([@{$data[0]}], [@{$data[1]}])\n";
	my @data = ( [49,20],[16,10] );
	print "([@{$data[0]}], [@{$data[1]}])\n";
	my ( $pvalue, $name ) = Statistic::ChiTest( \@data );

	print "( $pvalue, $name )\n";
}
