package Statistics::R::REXP::Types;
# ABSTRACT: Moose type constraints for REXPs

use 5.0.12;

use Moose::Util::TypeConstraints;

sub _flatten {
    map { ref $_ ? _flatten(@{$_}) : $_ } @_
}

role_type 'Statistics::R::REXP::Vector';

subtype 'VectorElements',
    as 'ArrayRef';

coerce 'VectorElements',
    from 'Statistics::R::REXP::Vector',
    via { $_->elements };


## Used by Character
subtype 'CharacterElements',
    as 'ArrayRef[Maybe[Str]]';

coerce 'CharacterElements',
    from 'ArrayRef',
    via {
        [ _flatten $_ ]
    },
    from 'Statistics::R::REXP::Vector',
    via {
        [ _flatten $_->elements ]
    };


## Used by Integer
subtype 'IntegerElements',
    as 'ArrayRef[Maybe[Int]]';

sub _flatten_integerize {
    require Scalar::Util;
    map { Scalar::Util::looks_like_number $_ ?
              int($_ + ($_ <=> 0) * 0.5) :
              undef}
    _flatten @_
}

coerce 'IntegerElements',
    from 'ArrayRef',
    via {
        [ _flatten_integerize $_ ]
    },
    from 'Statistics::R::REXP::Vector',
    via {
        [ _flatten_integerize $_->elements ]
    };


## Used by Logical
type 'LogicalElement',
    where { !defined $_ || $_ eq '1' || $_ eq '0' };

sub _logicalize {
    my $x = scalar @_ ? $_[0] : $_;
    defined $x ? ($x ? 1 : 0) : undef
}

coerce 'LogicalElement',
    from 'Str',
    via { logicalize $_ };

subtype 'LogicalElements',
    as 'ArrayRef[LogicalElement]';

sub _flatten_logicalize {
    map _logicalize, _flatten @_
}

coerce 'LogicalElements',
    from 'ArrayRef',
    via {
        [ _flatten_logicalize $_ ]
    },
    from 'Statistics::R::REXP::Vector',
    via {
        [ _flatten_logicalize $_->elements ]
    };


## Used by Double
type 'DoubleElement',
    where {
        require Scalar::Util;
        !defined($_) || Scalar::Util::looks_like_number($_);
    };

subtype 'DoubleElements',
    as 'ArrayRef[DoubleElement]';

sub _flatten_numberize {
    require Scalar::Util;
    map { Scalar::Util::looks_like_number $_ ? $_ : undef }
    _flatten @_
}

coerce 'DoubleElements',
    from 'ArrayRef',
    via {
        [ _flatten_numberize $_ ]
    },
    from 'Statistics::R::REXP::Vector',
    via {
        [ _flatten_numberize $_->elements ]
    };


## Used by Language
type 'LanguageElements',
    where {
        require Scalar::Util;
        ref $_ eq ref [] &&
            Scalar::Util::blessed $_->[0] &&
            ($_->[0]->isa('Statistics::R::REXP::Language') ||
             $_->[0]->isa('Statistics::R::REXP::Symbol'))
    },
    message { "The first element must be a Symbol or Language" };

coerce 'LanguageElements',
    from 'Statistics::R::REXP::Vector',
    via {
        $_->elements
    };


## Used by Raw
subtype 'RawElement',
    as 'Int',
    where {
        $_ >= 0 && $_ <= 255
},
    message { "Elements of raw vectors must be 0-255" };

subtype 'RawElements',
    as 'ArrayRef[RawElement]',
    message { "Elements of raw vectors must be 0-255" };
;

coerce 'RawElements',
    from 'ArrayRef',
    via {
        [ map int, _flatten $_ ]
    },
    from 'Statistics::R::REXP::Vector',
    via {
        [ map int, _flatten $_->elements ]
    };


## Used by Symbol
class_type 'Statistics::R::REXP::Symbol';

subtype 'SymbolName',
    as 'Str';

coerce 'SymbolName',
    from 'Statistics::R::REXP::Symbol',
    via { $_->name };


## Used by Unknown
subtype 'SexpType',
    as 'Int',
    where { ($_ >= 0) && ($_ <= 255)
    },
    message { "SEXP type must be a number in range 0-255" };
