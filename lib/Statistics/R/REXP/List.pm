package Statistics::R::REXP::List;
# ABSTRACT: an R generic vector (list)

use 5.012;

use Scalar::Util qw(weaken);

use Moose;
use namespace::clean;

with 'Statistics::R::REXP::Vector';
use overload;

sub _to_s {
    my $self = shift;
    
    my ($u, $unfold);
    $u = $unfold = sub {
        join(', ', map { ref $_ eq ref [] ?
                             '[' . &$unfold(@{$_}) . ']' :
                             (defined $_? $_ : 'undef') } @_);
    };
    weaken $unfold;
    $self->_type . '(' . &$unfold(@{$self->elements}) . ')';
}

sub _type { 'list'; }


__PACKAGE__->meta->make_immutable;

1; # End of Statistics::R::REXP::List

__END__


=head1 SYNOPSIS

    use Statistics::R::REXP::List
    
    my $vec = Statistics::R::REXP::List->new([
        1, '', 'foo', ['x', 22]
    ]);
    print $vec->elements;


=head1 DESCRIPTION

An object of this class represents an R list, also called a generic
vector (C<VECSXP>). List elements can themselves be lists, and so can
form a tree structure.


=head1 METHODS

C<Statistics::R::REXP:List> inherits from
L<Statistics::R::REXP::Vector>, with no added restrictions on the value
of its elements. Missing values (C<NA> in R) have value C<undef>.


=head1 BUGS AND LIMITATIONS

Classes in the C<REXP> hierarchy are intended to be immutable. Please
do not try to change their value or attributes.

There are no known bugs in this module. Please see
L<Statistics::R::IO> for bug reporting.


=head1 SUPPORT

See L<Statistics::R::IO> for support and contact information.

=cut
