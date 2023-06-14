#!/usr/bin/perl

use strict;
use warnings;

sub update_iso_directory {
    my ($directory_path) = @_;
    chdir($directory_path);
    system('git' 'checkout' '.');
    system('git', 'pull');
}

sub run_docker_container {
    system('docker', 'run', '-itd', '--privileged', '--name', 'bio', 'bioarchlinux/bioarchlinux', '/bin/bash');
}

sub system_setup {
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', 'ln -sf /usr/share/zoneinfo/GMT /etc/localtime');
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', 'pacman -Syu --noconfirm');
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', 'pacman -S archiso rsync --noconfirm');
}

sub transfer_docker {
   my ($path) = @_;
   system('docker', 'cp', $path, 'bio:/root/');
}

sub prepare_files {
    my ($src_path) = @_;

    # Download bio mirrorlist file
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', "cd /root/bio/airootfs/etc/pacman.d && curl -L -o mirrorlist.bio https://raw.githubusercontent.com/BioArchLinux/mirror/main/mirrorlist.bio");

   # Download mirrorlist file
    system('curl', '-L', '-o', $src_path . 'mirrorlist' , 'https://gitlab.archlinux.org/archlinux/packaging/packages/pacman-mirrorlist/-/raw/main/mirrorlist'); 
    # Uncomment Worldwide mirrors
    my @mirrorlist_lines = ();
    open(my $fh, '<', $src_path . 'mirrorlist') or die "Can't open mirrorlist file: $!";
    while (my $line = <$fh>) {
        if ($line =~ /^## Worldwide/) {
            push @mirrorlist_lines, $line;
            push @mirrorlist_lines, <$fh>, <$fh>, <$fh>;
        } else {
            push @mirrorlist_lines, $line;
        }
    }
    close($fh);
    open($fh, '>', $src_path . '/mirrorlist') or die "Can't write mirrorlist file: $!";
    print $fh @mirrorlist_lines;
    close($fh);
    # transfer mirrorlist 
    system('docker', 'cp', $src_path . '/mirrorlist' , "bio:/root/bio/airootfs/etc/pacman.d/");
    # clean mirrorlist
    system('rm', $src_path . 'mirrorlist');

    # Download keyring files
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', "cd /root/bio/airootfs/usr/share/pacman/keyrings && curl -L -o bioarchlinux-trusted https://raw.githubusercontent.com/BioArchLinux/keyring/main/bioarchlinux-trusted");
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', "cd /root/bio/airootfs/usr/share/pacman/keyrings && curl -L -o bioarchlinux.gpg https://raw.githubusercontent.com/BioArchLinux/keyring/main/bioarchlinux.gpg");

    # Copy pacman.conf file
    system('docker', 'exec', '-i', 'bio', 'sh', '-c',  "cp ${src_path}/bio/pacman.conf ${src_path}/bio/airootfs/etc/");
}

sub copy_template_files {
    my ($src, $dst) = @_;
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', "rsync -a --links --ignore-existing $src/ $dst/");
}

sub use_mkarchiso {
    my ($subdir, $iso_name, $dest_dir) = @_;
    my $iso_filename = "${iso_name}-" . `date "+%Y.%m.%d"` . "-x86_64.iso";
    $iso_filename =~ s/[^\x20-\x7E]//g;
    chomp($iso_filename);
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', "cd /root/$subdir && mkarchiso -C pacman.conf -v .");
    system('docker', 'cp', "bio:/root/" . ${subdir} . "/out/". ${iso_filename}, $dest_dir);
}

sub use_mkarchiso_bt {
    my ($subdir, $iso_name, $dest_dir) = @_;
    my $iso_filename = "${iso_name}-bootstrap-" . `date "+%Y.%m.%d"` . "-x86_64.tar.gz";
    $iso_filename =~ s/[^\x20-\x7E]//g;
    chomp($iso_filename);
    system('docker', 'exec', '-i', 'bio', 'sh', '-c', "cd /root/$subdir && mkarchiso -C pacman.conf -m bootstrap -v .");
    system('docker', 'cp', "bio:/root/" . ${subdir} . "/out/". ${iso_filename}, $dest_dir);
}

sub gpg_sign {
    my ($file_path) = @_;
    $file_path =~ s/[^\x20-\x7E]//g;
    chomp($file_path);
    system('gpg', '--output', $file_path . '.sig', '--sign', $file_path);
}

sub sum_sign {
    my ($file_path) = @_;
    $file_path =~ s/[^\x20-\x7E]//g;
    chomp($file_path);
    my @sum_commands = qw(b2sum cksum md5sum sha1sum sha224sum sha256sum sha384sum sha512sum sum);
    foreach my $cmd (@sum_commands) {
        my $sum_file = "$file_path.$cmd";
        system("$cmd $file_path > \"$sum_file\"");
    }
}

sub clean_system {
    system('docker', 'stop', 'bio');
    system('docker', 'rm', 'bio');
    system('docker', 'rmi', '--force', 'bioarchlinux/bioarchlinux');
}

sub remove_files {
    my ($directory_path) = @_;
    unlink glob $directory_path . '/*';
}

sub move_files {
    my ($src_path, $dst_path) = @_;
    my @file_types = qw(b2sum cksum md5sum sha1sum sha224sum sha256sum sha384sum sha512sum sum sig iso tar.gz);
    foreach my $type (@file_types) {
        my @files = glob("$src_path/*.$type");
        foreach my $file (@files) {
            system('mv', $file, $dst_path);
        }
    }
}


### Main Function ###

my $abpath = '/usr/share/lilac/iso';
my $cdpath = '/usr/share/lilac/Repo/iso';

# Update
update_iso_directory( $abpath );

# Run
run_docker_container();

# System
system_setup();

# transfer
transfer_docker( $abpath . '/bio' );
transfer_docker( $abpath . '/bio-wayfire' );

# Call prepare_files function before copying templates
prepare_files( $abpath );

# Copy template files
copy_template_files( '/root/bio', '/root/bio-wayfire');

# Use mkarchiso
use_mkarchiso('bio', 'bioarchlinux', $abpath);
use_mkarchiso('bio-wayfire', 'bioarchlinux-wayfire', $abpath);
use_mkarchiso_bt('bio', 'bioarchlinux', $abpath);

# GPG Sign
gpg_sign( $abpath . '/bioarchlinux-' . `date "+%Y.%m.%d"` . '-x86_64.iso');
gpg_sign( $abpath . '/bioarchlinux-wayfire-' . `date "+%Y.%m.%d"` . '-x86_64.iso');
gpg_sign( $abpath . '/bioarchlinux-bootstrap-' . `date "+%Y.%m.%d"` . '-x86_64.tar.gz');

# Sum sign
sum_sign( $abpath . '/bioarchlinux-' . `date "+%Y.%m.%d"` . '-x86_64.iso');
sum_sign( $abpath . '/bioarchlinux-wayfire-' . `date "+%Y.%m.%d"` . '-x86_64.iso');
sum_sign( $abpath . '/bioarchlinux-bootstrap-' . `date "+%Y.%m.%d"` . '-x86_64.tar.gz');

# Clean system
clean_system();

# Remove
remove_files( $cdpath );

# Move
move_files( $abpath, $cdpath );
