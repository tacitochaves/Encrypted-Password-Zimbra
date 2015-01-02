package ZIMBRA::Get_Passowrd_Account;

use strict;
use warnings;

sub new {
    return bless {}, shift;
}

sub handle_accounts {
    my ( $self, $zmprov, $domain ) = @_;

    $self->{_zmprov} = $zmprov if defined $zmprov;
    $self->{_domain} = $domain if defined $domain;

    open my $ACCOUNTS, "$self->{_zmprov} -l gaa $self->{_domain} |" or die "Comando não encontrado\n";
    my @t_accounts = <$ACCOUNTS>;
    close $ACCOUNTS;
   
    my @accounts;

    map { chomp; push @accounts, $_ } @t_accounts;
    my $mail_list = \@accounts;
}

sub handle_passwords {
    my ( $self, $account ) = @_;

    $self->{_account} = $account if defined $account;


    open my $ENCRYPTED, "$self->{_zmprov} -l ga $self->{_account} userPassword |" or die "Comando não encontrado\n";
    my @adicionais = <$ENCRYPTED>;
    close $ENCRYPTED;

    my $detalhes = {};

    for my $dados ( @adicionais ) {
 
        if ( $dados =~ m/name\s(.*@.*)/ ) {
            $self->{_email} = $1;
        }

        if ( $dados =~ m/userPassword:\s(.*)/ ) {
            $self->{_password} = $1;
        }

        $detalhes->{$self->{_email}}->{password} = $self->{_password};
 
    }
  
    return $detalhes;

}

sub creates_file {
    my ( $self, $account, $password, $directory ) = @_;

    $self->{_account} = $account if defined $account;
    $self->{_password} = $password if defined $password;
    $self->{_directory} = $directory if defined $directory;
    my $diretorio = "/contas";

    if ( -e "$self->{_directory}" ) {
        open CREATE, ">", "$self->{_directory}/$self->{_account}" or die "Não foi possível criar o arquivo\n";
        print  CREATE "Password: $self->{_password}";
        close CREATE;
    }
    else {
        mkdir "$self->{_directory}";
        open CREATE, ">", "$self->{_directory}/$self->{_account}" or die "Não foi possível criar o arquivo\n";
        print  CREATE "Senha: $self->{_password}";
        close CREATE;
    }
}

sub restore_password {
    my ( $self, $zmprov, $account, $password ) = @_;

    $self->{_zmprov} = $zmprov if defined $zmprov;
    $self->{_account} = $account if defined $account;
    $self->{_password} = $password if defined $password;

    #open my $restore, "$self->{_zmprov} ma $self->{_account} $self->{_password} |" or die "Erro ao criar a conta\n";
    #my @list = <$restore>;
    #close $restore
    print "$self->{_zmprov} ma $self->{_account} userPassword '$self->{_password}'\n";
}

1;
