#!/usr/bin/env perl

use lib qw(t/lib);
use strict;

use Getopt::Long;
use Test::Harness;

use ProFTPD::TestSuite::Utils qw(:testsuite);

my $opts = {};
GetOptions($opts, 'h|help', 'C|class=s@');

if ($opts->{h}) {
  usage();
}

$| = 1;

my $test_files;

if (scalar(@ARGV) > 0) {
  $test_files = [@ARGV];

} else {
  $test_files = [qw(
    t/logins.t
    t/commands/user.t
    t/commands/pass.t
    t/commands/pwd.t
    t/commands/cwd.t
    t/commands/cdup.t
    t/commands/syst.t
    t/commands/type.t
    t/commands/mkd.t
    t/commands/rmd.t
    t/commands/dele.t
    t/commands/mdtm.t
    t/commands/size.t 
    t/commands/mode.t
    t/commands/stru.t
    t/commands/allo.t
    t/commands/noop.t
    t/commands/feat.t
    t/commands/help.t
    t/commands/quit.t
    t/commands/rnfr.t
    t/commands/rnto.t
    t/commands/rest.t
    t/commands/pasv.t
    t/commands/epsv.t
    t/commands/port.t
    t/commands/eprt.t
    t/commands/nlst.t
    t/commands/list.t
    t/commands/retr.t
    t/commands/stor.t
    t/commands/stou.t
    t/commands/appe.t
    t/config/displayconnect.t
    t/config/displaylogin.t
    t/config/maxloginattempts.t
    t/config/serverident.t
  )];

  # Now interrogate the build to see which module/feature-specific test files
  # should be added to the list.
  my $order = 0;

  my $FEATURE_TESTS = {
    't/modules/mod_sql.t' => {
      order => ++$order,
      test_class => [qw(mod_sql)],
    },

    't/modules/mod_sql_sqlite.t' => {
      order => ++$order,
      test_class => [qw(mod_sql_sqlite)],
    },
  };

  my @feature_tests = testsuite_get_runnable_tests($FEATURE_TESTS);
  if (scalar(@feature_tests) > 0) {
    push(@$test_files, @feature_tests);
  }
}

$ENV{PROFTPD_TEST} = 1;

if (defined($opts->{C})) {
  $ENV{PROFTPD_TEST_ENABLE_CLASS} = join(':', @{ $opts->{C} });

} else {
  # Disable all 'inprogress' tests by default
  $ENV{PROFTPD_TEST_DIABLE_CLASS} = 'inprogress';
}

runtests(@$test_files) if scalar(@$test_files) > 0;

exit 0;

sub usage {
  print STDOUT <<EOH;

$0: [--help] [--class=\$name]

Examples:

  perl $0
  perl $0 --class foo
  perl $0 --class bar --class baz

EOH
  exit 0;
}
