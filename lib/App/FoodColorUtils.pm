package App::ListCountries;

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
use Perinci::Sub::Gen::AccessTable qw(gen_read_table_func);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

our @EXPORT_OK = qw(list_food_colors);

sub _get_scheme_codes {
    my ($scheme) = @_;
    my $mod = "Graphics::ColorNames::$scheme";
    (my $modpm = "$mod.pm") =~ s!::!/!g;
    require $modpm;
    my $res = &{"$mod\::NamesRgbTable"}();
    if (ref $res eq 'HASH') {
        for (keys %$res) {
            $res->{$_} = sprintf("%06s", $res->{$_});
        }
        return $res;
    } else {
        return {};
    }
}
our $data;
{
    require Color::RGB::Util;
    require Graphics::ColorNames;
    require Graphics::ColorNames::FoodColor;

    my $codes = _get_scheme_codes("FoodColor");

    my @data;
    for my $name (sort keys %$codes) {
        my $rgb = sprintf("%06x", $codes->{$name});
        push @data, [
            $name,
            $rgb,
            color => Color::RGB::Util::rgb_closest_to($rgb),
        };
    }
    @data = sort {
        $a->{color} cmp $b->{color} ||
            $a->{code} cmp $b->{code} ||
            $a->{name} cmp $b->{name}
        } @data;

    $data = \@data;
}

my $res = gen_read_table_func(
    name => 'list_food_colors',
    summary => 'List food colors',
    table_data => $data,
    table_spec => {
        summary => 'List of food colors',
        fields => {
            name => {
                summary => 'Color name',
                schema => 'str*',
                pos => 0,
                sortable => 1,
            },
            code => {
                summary => 'RGB code',
                schema => 'str*',
                pos => 1,
                sortable => 1,
            },
            color => {
                summary => 'The color of this food color',
                schema => 'str*',
                pos => 2,
                sortable => 1,
            },
        },
        pk => 'name',
    },
    description => <<'_',

Source data is generated from `Graphics::ColorNames::FoodColor`. so make sure
you have a relatively recent version of the module.

_
);
die "Can't generate function: $res->[0] - $res->[1]" unless $res->[0] == 200;

1;
#ABSTRACT:

=head1 SYNOPSIS


=head1 DESCRIPTION

This distribution contains the following command-line utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<App::FoodAdditivesUtils>

=cut
