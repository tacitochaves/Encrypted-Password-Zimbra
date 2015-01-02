#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/lib";

use ZIMBRA::Get_Passowrd_Account;

my $self = ZIMBRA::Get_Passowrd_Account->new;

my $zmprov    = "/opt/zimbra/bin/zmprov";
my $directory = "/contas"; 
my $accounts  = $self->handle_accounts( "$zmprov", "acai.com.br" );

my $data = [];

map { chomp $_; push @{ $data }, $self->handle_passwords($_) } @{ $accounts }; 

for my $encrypted ( @{ $data } ) {
    for my $emails ( keys %{ $encrypted } ) {
        $self->creates_file( "$emails", "$emails $encrypted->{$emails}->{password}", "$directory" ); 
        $self->restore_password( "$zmprov", "$emails", "$encrypted->{$emails}->{password}" );
    }
}

