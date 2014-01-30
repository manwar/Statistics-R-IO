#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';

use Test::More tests => 7;
use Test::Fatal;

use Statistics::R::IO::Parser qw(:all);
use Statistics::R::IO::ParserState;
use Statistics::R::IO::REXPFactory qw(:all);


## integer vectors

## serialize 1:3, XDR: true
my $noatt_123_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0d\0\0\0\3\0\0\0" .
    "\1\0\0\0\2\0\0\0\3");

is_deeply(Statistics::R::IO::REXPFactory::header->($noatt_123_xdr)->[0],
          [ "X\n", 2, 0x030002, 0x020300 ],
          'XDR header');

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   \&Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_123_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 13,
            levels => 0, },
          'header plus object info - int vector no atts');

is_deeply(unserialize($noatt_123_xdr->data)->[0],
          [ 1, 2, 3 ],
          'int vector no atts');

## double vectors
## serialize 1234.56, XDR: true
my $noatt_123456_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x0e\0\0\0\1\x40\x93\x4a".
    "\x3d\x70\xa3\xd7\x0a");

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   \&Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_123456_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 14,
            levels => 0, },
          'header plus object info - double vector no atts');

is_deeply(unserialize($noatt_123456_xdr->data)->[0],
          [ 1234.56 ],
          'double vector no atts');


## character vectors
## serialize letters[1:3], XDR: true
my $noatt_abc_xdr = Statistics::R::IO::ParserState->new(
    data => "\x58\x0a\0\0\0\2\0\3\0\2\0\2\3\0\0\0\0\x10\0\0\0\3\0\4\0" .
    "\x09\0\0\0\1\x61\0\4\0\x09\0\0\0\1\x62\0\4\0\x09\0\0\0\1\x63");

is_deeply(bind(Statistics::R::IO::REXPFactory::header,
               sub {
                   \&Statistics::R::IO::REXPFactory::unpack_object_info
               })->($noatt_abc_xdr)->[0],
          { is_object => 0,
            has_attributes => 0,
            has_tag => 0,
            object_type => 16,
            levels => 0, },
          'header plus object info - character vector no atts');

is_deeply(unserialize($noatt_abc_xdr->data)->[0],
          [ 'a', 'b', 'c' ],
          'character vector no atts');
