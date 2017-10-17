#!/bin/bash

set -e

usage()
{
    echo
    echo "Usage: $0 [save|restore] [BASENAME]"
    exit -1
}

if [ "$#" -ne 2 ]; then
    usage
fi
CMD="$1"
BASENAME=${2%.tar.gz}

ACCOUNT_FILES=$(echo \
    etc/passwd \
    etc/group \
    etc/shadow \
    )

SYSCONFIG_FILES=$(echo \
    etc/hostname \
    etc/hosts \
    etc/localtime \
    etc/logrotate.conf \
    etc/ssh/sshd_config \
    etc/ssh/*_key \
    etc/ssh/*.pub \
    home/rchen/.ssh/authorized_keys \
    )

LOGWATCH_FILES=$(echo \
    etc/logwatch/scripts/services/named \
    )

BIND_FILES=$(echo \
    etc/named.conf \
    var/named/dynamic/*.zone \
    etc/pki/dnssec-keys/*.key \
    etc/pki/dnssec-keys/*.private \
    etc/pki/dnssec-keys/*.sh \
    etc/pki/dnssec-keys/*.py \
    )

UNBOUND_FILES=$(echo \
    etc/resolv.conf \
    )

POSTFIX_FILES=$(echo \
    etc/aliases \
    etc/pki/tls/certs/postfix.crt.pem \
    etc/pki/tls/private/postfix.key.pem \
    etc/postfix/main.cf \
    etc/postfix/Makefile \
    etc/postfix/sender_bcc \
    etc/postfix/senders \
    etc/postfix/virtual \
    etc/systemd/system/postsrsd.service \
    )

ALL_FILES=$(echo \
    $ACCOUNT_FILES \
    $SYSCONFIG_FILES \
    $LOGWATCH_FILES \
    $BIND_FILES \
    $UNBOUND_FILES \
    $POSTFIX_FILES \
    )

save()
{
    if [ -f "$BASENAME.tar.gz" ]; then
        echo "File $BASENAME.tar.gz already exists."
        exit -1
    fi

    (cd / && tar -zcf - $ALL_FILES) > "$BASENAME.tar.gz"
}

restore()
{
    if ! [ -f "$BASENAME.tar.gz" ]; then
        echo "File $BASENAME.tar.gz does not exist."
        exit -1
    fi

    # ------------------------------
    # Install/Update System Packages
    # ------------------------------
    yum -y update

    yum -y groupinstall "Development Tools"
    yum -y groupinstall "Legacy UNIX Compatibility"
    yum -y groupinstall "System Administration Tools"
    yum -y install epel-release

    yum -y install \
        bind-chroot \
        bind-utils \
        cmake \
        chrony \
        cyrus-sasl \
        cyrus-sasl-plain \
        drupal7 \
        emacs \
        gcc \
        git \
        help2man \
        httpd \
        logrotate \
        logwatch \
        mariadb \
        nmap \
        postfix \
        screen \
        strace \
        tcpdump \
        unbound \
        whois \

    yum -y update
    yum -y reinstall polkit
    systemctl start polkit

    # ------------
    # Backup Files
    # ------------
    for glob in $ALL_FILES; do
        for file in /$glob; do
            if [ -f $file.orig ]; then
                echo Error: $file.orig exists. Restoring may lose data.
                exit -1
            fi
        done
    done

    for glob in $ALL_FILES; do
        for file in /$glob; do
            if [ -f $file ]; then
                cp -a $file $file.orig
            fi
        done
    done

    # -----------------------------------------------------
    # For Testing Within A Virtual Machine: Set IP Addesses
    # -----------------------------------------------------
    if /bin/false; then
        ip address add [IPv4 ADDR] dev enp0s3
        ip -6 address add [IPv6 ADDR] dev enp0s3
    fi

    # ----------------------------
    # Restore System Configuration
    # ----------------------------
    yum -y install \
        logrotate \

    tar -C / -zxvf $BASENAME.tar.gz $SYSCONFIG_FILES

    hostnamectl set-hostname $(cat /etc/hostname) --static
    systemctl restart sshd
    systemctl start   chronyd

    # ----------------
    # Restore Logwatch
    # ----------------
    yum -y install \
        logwatch \

    tar -C / -zxvf $BASENAME.tar.gz $LOGWATCH_FILES

    # ------------
    # Restore BIND
    # ------------
    yum -y install \
        bind-chroot \

    tar -C / -zxvf $BASENAME.tar.gz $BIND_FILES

    systemctl enable named-chroot
    systemctl start  named-chroot

    # ---------------
    # Restore Unbound
    # ---------------
    yum -y install \
        unbound \

    tar -C / -zxvf $BASENAME.tar.gz $UNBOUND_FILES

    systemctl enable unbound
    systemctl start  unbound

    # ---------------
    # Restore Postfix
    # ---------------
    yum -y install \
        cmake \
        cyrus-sasl \
        cyrus-sasl-plain \
        gcc \
        git \
        help2man \
        postfix \

    # Build/Install PostSRSd
    POSTSRSD_DIR=/usr/local/packages/postsrsd-1.4
    mkdir -p /usr/local/packages/src
    pushd /usr/local/packages/src
    git clone https://github.com/roehling/postsrsd.git --branch 1.4
    mkdir obj-postsrsd
    cd obj-postsrsd
    cmake ../postsrsd \
        -DCMAKE_INSTALL_PREFIX=$POSTSRSD_DIR \
        -DSYSCONF_DIR=$POSTSRSD_DIR/etc \
        -DINIT_FLAVOR=systemd
    make install
    popd

    tar -C / -zxvf $BASENAME.tar.gz $POSTFIX_FILES
    make -C /etc/postfix
    newaliases

    systemctl enable postsrsd
    systemctl start  postsrsd
    systemctl enable saslauthd
    systemctl start  saslauthd
    systemctl enable postfix
    systemctl start  postfix

    # ---------------------------------------------
    # Create Patches for Manual Account Restoration
    # ---------------------------------------------
    echo
    TMPDIR=$(mktemp -d)
    tar -C $TMPDIR -zxvf $BASENAME.tar.gz $ACCOUNT_FILES
    for i in $ACCOUNT_FILES; do
        sort $TMPDIR/$i > $TMPDIR/$i.restore
        sort /$i        > $TMPDIR/$i.system
        diff -ubwi $TMPDIR/$i.system $TMPDIR/$i.restore > /$i.patch
        echo Created /$i.patch
    done
    rm -rf $TMPDIR

    echo
    echo System files restored.  You must reboot to complete the restoration.
}

case "$CMD" in
    save) save;;
    restore) restore;;
    *) usage;;
esac
