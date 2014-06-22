package Statistic;
# This is a package for statistic
$VERSION = '0.0.1';
$DATE    = '2012-11-03';
$Modify  = '2012-11-04';
$AUTHOR  = 'Shujia Huang';

use strict;
use warnings;
use Statistics::Test::WilcoxonRankSum; # Use for RankSum Test.
use Math::Cephes qw(:all); # For being used in Chi-sqare test and PairTTest. But this is a useful package for all the general test.
use Text::NSP::Measures::2D::Fisher::twotailed; #Text-NSP-1.25 Just use this package to calculate Fisher's Exact test p-value.
use Text::NSP::Measures::2D::CHI::x2; #Text-NSP-1.25 Just use this package for calcuting the Pearson's chi-value of 2x2 table.
use Statistics::TTest; # Just for ttest.
use Statistics::DependantTTest; # Just for PairedTTest
use Statistics::Basic; # For calculating mean, variance or stddev et.al

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = ();
#   TTest PairedTTest ChiTest WilcoxonRankSum
our @EXPORT_OK = qw (
	TTest SingleTTest PairedTTest ChiTest WilcoxonRankSum FisherExactTest
);

sub ChiTest { 
# For m x n Chi-sqare test. But now just for 2x2 table. I'll update to m x n table later. And I should lean from Text::NSP::Measures::2D::CHI::x2 package.
=head  2x2 table.
          word2   ~word2
  word1    n11      n12 | n1p
 ~word1    n21      n22 | n2p
           --------------
           np1      np2   npp

=cut
	my ( $data ) = @_; # @$data is a 2D array(Table). such as : @$data=>( [n11,n12,...], [n21,n22,...], [n31,n32,...] )
	my $rowSize  = @$data;
	my $colSize  = @{$$data[0]};
	die "[ERROR]Your data is not suit for doing Chi-sqare test.\n" if ( $rowSize <= 1 or $colSize <= 1 );
	die "[ERROR]Now just for 2x2 table. I'll update to m x n table later." if ( $rowSize !=2 or $colSize != 2 );

	my @rowMarginalValue; # Record n1p n2p ...
	my @colMarginalValue; # Record np1 np2 ...
	my $npp = 0; 
	
	for ( my $i = 0; $i < @$data; ++$i ) {
		for ( my $j = 0; $j < @{$$data[$i]}; ++$j ) {
			$colMarginalValue[$j] += $$data[$i][$j]; # np1, np2, ...
			$rowMarginalValue[$i] += $$data[$i][$j]; # n1p, n2p, ...
			$npp += $$data[$i][$j];
		}
	}

	my @expectValue;
	# If there are one or more expect value is lower than 5 in 2x2 table, 
	# Chi-sqare is not suit to do this statistic and you'd better choice FisherExactTest.
	my $isNotSuitChiqrt = Statistic::ComputeExpectValue ( \@rowMarginalValue, \@colMarginalValue, $npp, \@expectValue );

	my ($pValue, $statisticName, $chiValue,$errorCode);
	my $df = ( $rowSize - 1 ) * ( $colSize - 1 );
	if ( !$isNotSuitChiqrt ) { # Just for 2 x 2 table.

		$chiValue = Text::NSP::Measures::2D::CHI::x2::calculateStatistic ( 
					n11=>$$data[0][0], n1p=>$rowMarginalValue[0], np1=>$colMarginalValue[0],npp=>$npp );
		if( ($errorCode = Text::NSP::Measures::2D::CHI::x2::getErrorCode()) ) {
			print STDERR $errorCode." - ".Text::NSP::Measures::2D::CHI::x2::getErrorMessage()."\n";
			return ( 1, "-" ); # Return this value when Fail Test.
		}
		$statisticName = Text::NSP::Measures::2D::CHI::x2::getStatisticName; 
		$statisticName = join "", (split(/\s+/,$statisticName));
		$pValue = Math::Cephes::chdtrc($df, $chiValue); # Returns the area under the right hand tail (from chiValue to infinity)
	} else {
		
		# Data all have to be interge when Fisher's exact test 
		($pValue, $statisticName) = Statistic::FisherExactTest ( \$$data[0][0], \$rowMarginalValue[0], \$colMarginalValue[0], \$npp );
	}

	return ($pValue, $statisticName);
}

sub FisherExactTest { # Fisher's Exact test can just for 2 x 2 table.
=head
          word2   ~word2
  word1    n11      n12 | n1p
 ~word1    n21      n22 | n2p
           --------------
           np1      np2   npp

=cut
	my ( $n11, $n1p, $np1, $npp ) = @_; # @$data is a 2D array(Table). such as : @$data=>( [n11,n12], [n21,n22] ) 
	my ($pValue, $statisticName, $errorCode); 

	# ($n11, $n1p, $np1, $npp) all have to be interge when Fisher's exact test
	$pValue = Text::NSP::Measures::2D::Fisher::twotailed::calculateStatistic( 
			  n11=>$$n11,n1p=>$$n1p,np1=>$$np1,npp=>$$npp );
	if( ($errorCode = Text::NSP::Measures::2D::Fisher::twotailed::getErrorCode()) ) {
        print STDERR $errorCode." - ".Text::NSP::Measures::2D::Fisher::twotailed::getErrorMessage();
		return ( 1, "-" ); # Return this value when Fail Test.
    }
	$statisticName = Text::NSP::Measures::2D::Fisher::twotailed::getStatisticName; 
	$statisticName = join "",(split(/\s+/,$statisticName));

	return ($pValue, $statisticName);
}

sub ComputeExpectValue { # For Chi-sqare.
	my ( $rowMarginalValue, $colMarginalValue, $npp, $expectValue ) = @_;
	my $isNotSuitChiqrt = 0;
	my $rowSize = @$rowMarginalValue;
	my $colSize = @$colMarginalValue;
	die "[ERROR]Zero value, check your data. It'll be illegal division by zero when computing expected value!\n" if ($npp==0);
	for ( my $i = 0; $i < $rowSize; ++$i ) {
		for ( my $j = 0; $j < $colSize; ++$j ) {
			$$expectValue[$i][$j] = $$rowMarginalValue[$i] * $$colMarginalValue[$j] / $npp;
			$isNotSuitChiqrt = 1 if ( $$expectValue[$i][$j] < 5 );
		}
	}
	$isNotSuitChiqrt = 0 if ( ($rowSize != 2 or $colSize != 2) and $isNotSuitChiqrt );
	return $isNotSuitChiqrt;
}

sub WilcoxonRankSum { # Just for the two samples or groups.
	my ( $dataset1, $dataset2 ) = @_; # Two array's reference
	return ( 0, "-" ) if ( @$dataset1 == 0 or @$dataset2 == 0 );
	my $wilcoxonTest = Statistics::Test::WilcoxonRankSum->new();
	$wilcoxonTest->load_data( $dataset1, $dataset2 );
	my $pValue = $wilcoxonTest->probability();
	$pValue    = sprintf '%f', $pValue;
	
	return ( $pValue, "WilcoxonRankSumTest" );
}

sub TTest {
	my ( $dataset1, $dataset2 ) = @_; # Two array's reference
	return ( 0, "-" ) if ( @$dataset1 == 0 or @$dataset2 == 0 );
	my $ttest = new Statistics::TTest;
	$ttest->load_data( $dataset1, $dataset2 );
	
	return ( $ttest->{t_prob}, "TTest" );
}

sub PairedTTest {
	my ( $dataset1, $dataset2 ) = @_; # Two array's reference
	#die "[Sorry]PairedTTest is not ready. Please contact with the Author: huangshujia\@genomics.cn\n";
	my $size1 = @$dataset1;
	my $size2 = @$dataset2;
	die "[ERROR]The two sample have different sizes.\n" if ( $size1 != $size2 );
	return ( 0, "-" ) if ( @$dataset1 < 2 or @$dataset2 < 2 );

	my $pairedttest = new Statistics::DependantTTest;
	$pairedttest->load_data('before', @$dataset1 );
	$pairedttest->load_data('after' , @$dataset2 );

	my ($tvalue,$degFreedom) = $pairedttest->perform_t_test('before','after');
	my $pvalue               = Math::Cephes::stdtr ( $degFreedom, $tvalue );
	if ( $pvalue < 0.5 ) {
		$pvalue *= 2; # Two tail test
	} else {
		$pvalue  = 2 * ( 1 - $pvalue );
	}

	return ( $pvalue, "PairedTTest" );

}

sub SingleTTest {
	# Sample size lower than 50.
	my ( $data, $u ) = @_; # $u is the population mean. I think I should check the Sample size, I can use u-test if big enough.
	die "[ERROR] In SingleTTest(). You should input an expected value which you want to test. SingleTTest( [\@arr], \$u)\n" if ( !defined $u );
	my $sampleSize   = @$data;
	return ( 0, "-" ) if ( $sampleSize < 2 );

	return Statistic::UTest( $data, $u ) if ( $sampleSize >= 50 );

	my $mean     = Statistics::Basic::mean( $data );
	my $variance = Statistics::Basic::variance( $data );

	if ( $variance == 0 ) {
		if ( $mean != $u ) {
			return ( 0 , "-");
		} else {
			return ( 1 , "-");
		}
	}

	my $tvalue     = ( $mean - $u ) / sqrt( $variance / $sampleSize );
	my $degFreedom = $sampleSize - 1;

	my $pvalue = Math::Cephes::stdtr ( $degFreedom, $tvalue );
	if ( $pvalue < 0.5 ) {
        $pvalue *= 2; # Two tail test
    } else {
        $pvalue  = 2 * ( 1 - $pvalue );
    }
	
	return ( $pvalue, "SingleTTest" );
}

sub UTest { # # Sample size lower than 50.
	my ( $data, $u ) = @_;
	my $sampleSize   = @$data;
	my $mean     = Statistics::Basic::mean( $data );
    my $variance = Statistics::Basic::variance( $data );

	if ( $variance == 0 ) {
        if ( $mean != $u ) {
            return ( 0 , "-");
        } else {
            return ( 1 , "-");
        }
    }

	my $uvalue = ( $mean - $u ) / sqrt( $variance / $sampleSize );
	my $pvalue = Math::Cephes::ndtr( $uvalue );

	if ( $pvalue < 0.5 ) {
        $pvalue *= 2; # Two tail test
    } else {
        $pvalue  = 2 * ( 1 - $pvalue );
    }

	return ( $pvalue, "UTest" );
}





