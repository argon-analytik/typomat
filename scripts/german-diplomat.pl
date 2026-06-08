#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";

my $OPEN_QUOTE = "„";
my $CLOSE_QUOTE = "“";
my $INNER_OPEN_QUOTE = "‚";
my $INNER_CLOSE_QUOTE = "‘";

sub protect_value {
    my ($blocks_ref, $value) = @_;
    my $placeholder = "%%%TYPOPROTECT_" . scalar(@{$blocks_ref}) . "%%%";
    push @{$blocks_ref}, $value;
    return $placeholder;
}

sub restore_protected {
    my ($text, $blocks_ref) = @_;

    for (my $i = @{$blocks_ref} - 1; $i >= 0; $i--) {
        my $placeholder = "%%%TYPOPROTECT_${i}%%%";
        $text =~ s/\Q$placeholder\E/$blocks_ref->[$i]/g;
    }

    return $text;
}

sub is_ipv4_address {
    my ($ip, $cidr) = @_;

    if (defined $cidr) {
        $cidr =~ s{^/}{};
        return 0 if $cidr > 32;
    }

    foreach my $part (split /\./, $ip) {
        return 0 if $part =~ /^0\d/;
        return 0 if $part > 255;
    }

    return 1;
}

sub looks_like_plain_thousands {
    my ($candidate) = @_;

    return 0 if $candidate =~ /^[vV]/;
    return 0 if $candidate =~ /[-+]/;

    my @parts = split /\./, $candidate;
    return 0 if @parts < 3;
    return 0 unless length($parts[0]) >= 1 && length($parts[0]) <= 3;

    for (my $i = 1; $i < @parts; $i++) {
        return 0 unless length($parts[$i]) == 3;
    }

    return 1;
}

sub protect_non_text_contexts {
    my ($text, $blocks_ref) = @_;

    $text =~ s{(`+)(.*?)\1}{protect_value($blocks_ref, $&)}egx;
    $text =~ s{!?\[[^\]]*\]\([^)]+\)}{protect_value($blocks_ref, $&)}egx;
    $text =~ s{(?<![\w@])(?:https?://|www\.)[^\s<>"']+}{protect_value($blocks_ref, $&)}egx;
    $text =~ s{(?<![\w.+-])[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}(?![\w.-])}{protect_value($blocks_ref, $&)}egx;
    $text =~ s{(?<![\w:])(?:[A-Fa-f0-9]{0,4}:){2,}[A-Fa-f0-9:.]*(?:/\d{1,3})?(?![\w:])}{protect_value($blocks_ref, $&)}egx;

    $text =~ s{
        (?<![\d.])
        ((?:\d{1,3}\.){3}\d{1,3})
        (/\d{1,2})?
        (?![\d.])
    }{
        my $ip = $1;
        my $cidr = $2;
        my $match = $ip . ($cidr // "");
        is_ipv4_address($ip, $cidr) ? protect_value($blocks_ref, $match) : $match;
    }egx;

    $text =~ s{\b\d{1,2}\.\d{1,2}\.\d{2,4}\b}{protect_value($blocks_ref, $&)}egx;
    $text =~ s{\b\d{4}-\d{2}-\d{2}\b}{protect_value($blocks_ref, $&)}egx;

    $text =~ s{
        (?<![\w.])
        ([vV]?\d+(?:\.\d+){2,}(?:[-+][A-Za-z0-9.]+)?)
        (?![\w.])
    }{
        looks_like_plain_thousands($1) ? $1 : protect_value($blocks_ref, $1);
    }egx;

    $text =~ s{(?<!\S)(?:~|\.{1,2}|/)[^\s<>"']+}{protect_value($blocks_ref, $&)}egx;

    return $text;
}

sub previous_non_space {
    my ($text, $index) = @_;

    for (my $i = $index - 1; $i >= 0; $i--) {
        my $char = substr($text, $i, 1);
        return $char if $char !~ /\s/;
    }

    return undef;
}

sub next_non_space {
    my ($text, $index) = @_;

    for (my $i = $index + 1; $i < length($text); $i++) {
        my $char = substr($text, $i, 1);
        return $char if $char !~ /\s/;
    }

    return undef;
}

sub convert_quotes {
    my ($text, $open, $close, $inner_open, $inner_close) = @_;
    my $converted = "";
    my $quote_depth = 0;

    for (my $i = 0; $i < length($text); $i++) {
        my $char = substr($text, $i, 1);

        if ($char eq '"') {
            my $prev_char = $i > 0 ? substr($text, $i - 1, 1) : undef;
            my $next_char = $i + 1 < length($text) ? substr($text, $i + 1, 1) : undef;
            my $prev = previous_non_space($text, $i);
            my $next = next_non_space($text, $i);
            my $is_open;

            if (!defined $prev) {
                $is_open = 1;
            } elsif (!defined $next) {
                $is_open = 0;
            } elsif (defined $prev_char && $prev_char =~ /\s/ && $next !~ /[.,;:!?…)\]}]/) {
                $is_open = 1;
            } elsif (defined $next_char && $next_char =~ /\s/) {
                $is_open = 0;
            } elsif ($prev =~ /[([{<:;,!?—–-]/) {
                $is_open = 1;
            } elsif ($next =~ /[.,;:!?…)\]}]/) {
                $is_open = 0;
            } else {
                $is_open = $quote_depth == 0;
            }

            if ($is_open) {
                $converted .= $quote_depth == 0 ? $open : $inner_open;
                $quote_depth++;
            } else {
                if ($quote_depth > 1) {
                    $converted .= $inner_close;
                    $quote_depth--;
                } elsif ($quote_depth == 1) {
                    $converted .= $close;
                    $quote_depth--;
                } else {
                    $converted .= $close;
                }
            }
        } else {
            $converted .= $char;
        }
    }

    return $converted;
}

sub normalize_text_dashes {
    my ($text) = @_;

    $text =~ s{(\p{L})\s*—\s*(\p{L})}{$1 – $2}g;
    $text =~ s{(\p{L})\s*--\s*(\p{L})}{$1 – $2}g;
    $text =~ s{(\p{L})\s*–\s*(\p{L})}{$1 – $2}g;
    $text =~ s{(\p{L})\s+-\s+(\p{L})}{$1 – $2}g;

    return $text;
}

sub normalize_ellipsis {
    my ($text) = @_;
    $text =~ s/(?<!\.)\.\.\.(?!\.)/…/g;
    return $text;
}

sub format_german_integer {
    my ($integer) = @_;

    $integer =~ s/[.'’]//g;
    $integer =~ s/(?<=\d)(?=(\d{3})+$)/./g if length($integer) > 3;

    return $integer;
}

sub normalize_german_prices {
    my ($text) = @_;

    $text =~ s{
        (?<![\w.])
        (\d{1,3}(?:[.'’]\d{3})*|\d+)
        [.,](?:--|[-–—])
        (?=$|[\s,.;:!?)\]])
    }{
        format_german_integer($1) . ",–";
    }egx;

    $text =~ s{
        \b((?:€|EUR|Euro)\s*)
        (\d{1,3}(?:[.'’]\d{3})*|\d+)
        \.(\d{2})
        (?!\d)
    }{
        $1 . format_german_integer($2) . "," . $3;
    }egx;

    $text =~ s{
        (?<![\w.])
        (\d{1,3}(?:[.'’]\d{3})*|\d+)
        \.(\d{2})
        (\s*(?:€|EUR|Euro))
        (?!\w)
    }{
        format_german_integer($1) . "," . $2 . $3;
    }egx;

    return $text;
}

sub normalize_numeric_ranges {
    my ($text) = @_;

    $text =~ s{
        (?<![\w.+-])
        (\d+(?:[.,]\d+)?)
        \s*-\s*
        (\d+(?:[.,]\d+)?)
        (?![\w.+-])
    }{
        $1 . "–" . $2;
    }egx;

    return $text;
}

sub normalize_german_numbers {
    my ($text) = @_;

    $text =~ s{
        \b
        (\d{1,3}(?:['’]\d{3})+)
        (,\d+)?
        \b
    }{
        my $integer = $1;
        my $decimal = $2 // "";
        $integer =~ s/['’]/./g;
        $integer . $decimal;
    }egx;

    return $text;
}

sub clean_spacing {
    my ($text, $open, $close) = @_;
    my $open_re = quotemeta($open);
    my $close_re = quotemeta($close);

    $text =~ s/$open_re\s+/$open/g;
    $text =~ s/\s+$close_re/$close/g;
    $text =~ s/\s+([,;:!?])/$1/g;
    $text =~ s/(\p{L})\s+\./$1./g;
    $text =~ s/([,;:!?])(?=($open_re|\p{L}))/$1 /g;
    $text =~ s/…(?=\p{L})/… /g;
    $text =~ s/^\s+(\d\.)\s*/$1 /;
    $text =~ s/ {2,}/ /g;

    return $text;
}

my @lines = <STDIN>;
chomp @lines;

my $in_code_block = 0;
my @output;

foreach my $line (@lines) {
    if ($line =~ /^\s*(?:```|~~~)/) {
        $in_code_block = !$in_code_block;
        push @output, $line;
        next;
    }

    if ($in_code_block || $line =~ /^(?: {4}|\t)/) {
        push @output, $line;
        next;
    }

    my @protected_blocks;
    my $temp_line = protect_non_text_contexts($line, \@protected_blocks);

    $temp_line =~ s/[„“”‟«»‹›‚‘]/"/g;
    $temp_line = convert_quotes($temp_line, $OPEN_QUOTE, $CLOSE_QUOTE, $INNER_OPEN_QUOTE, $INNER_CLOSE_QUOTE);
    $temp_line = normalize_ellipsis($temp_line);
    $temp_line = normalize_german_prices($temp_line);
    $temp_line = normalize_numeric_ranges($temp_line);
    $temp_line = normalize_text_dashes($temp_line);
    $temp_line = normalize_german_numbers($temp_line);
    $temp_line = clean_spacing($temp_line, $OPEN_QUOTE, $CLOSE_QUOTE);
    $temp_line = restore_protected($temp_line, \@protected_blocks);

    push @output, $temp_line;
}

print "$_\n" for @output;
