#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";

sub protect_inline_code {
    my ($line, $blocks_ref) = @_;
    my $index = 0;

    $line =~ s{
        `([^`]*)`
    }{
        push @{$blocks_ref}, $1;
        my $placeholder = "%%%INLINE_${index}%%%";
        $index++;
        $placeholder;
    }egx;

    return $line;
}

sub restore_inline_code {
    my ($line, $blocks_ref) = @_;

    for (my $i = 0; $i < @{$blocks_ref}; $i++) {
        my $placeholder = "%%%INLINE_${i}%%%";
        my $code = $blocks_ref->[$i];
        $line =~ s/\Q$placeholder\E/`$code`/g;
    }

    return $line;
}

sub convert_quotes {
    my ($text, $open, $close) = @_;
    my $converted = "";
    my $open_quote = 1;

    for (my $i = 0; $i < length($text); $i++) {
        my $char = substr($text, $i, 1);

        if ($char eq '"') {
            if ($open_quote) {
                $converted .= $open;
                $open_quote = 0;
            } else {
                $converted .= $close;
                $open_quote = 1;
            }
        } else {
            $converted .= $char;
        }
    }

    return $converted;
}

sub normalize_text_em_dashes {
    my ($text) = @_;

    # Keep Markdown and tab-separated table rows unchanged.
    return $text if $text =~ /[|\t]/;

    $text =~ s{(\p{L})\s*—\s*(\p{L})}{$1 – $2}g;
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
    my ($text) = @_;

    $text =~ s/^\s+(\d\.)\s*/$1 /;
    $text =~ s/ {2,}/ /g;
    $text =~ s/(\d\.)\s+/$1 /g;

    return $text;
}

my @lines = <STDIN>;
chomp @lines;

my $in_code_block = 0;
my @output;

foreach my $line (@lines) {
    if ($line =~ /^\s*```/) {
        $in_code_block = !$in_code_block;
        push @output, $line;
        next;
    }

    if ($in_code_block) {
        push @output, $line;
        next;
    }

    my @inline_blocks;
    my $temp_line = protect_inline_code($line, \@inline_blocks);

    $temp_line =~ s/[„“”«»‚‘]/"/g;
    $temp_line = convert_quotes($temp_line, "»", "«");
    $temp_line = normalize_text_em_dashes($temp_line);
    $temp_line = normalize_german_numbers($temp_line);
    $temp_line = clean_spacing($temp_line);
    $temp_line = restore_inline_code($temp_line, \@inline_blocks);

    push @output, $temp_line;
}

print "$_\n" for @output;
