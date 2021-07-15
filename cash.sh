#!/bin/sh

IFS='
'

cash.file() {
	while test "$#" -gt 0
	do
		case "$1" in
			-name) name="$2" ; shift 2 ;;
			-from) from="$2" ; shift 2 ;;
			-owner) owner="$2" ; shift 2 ;;
			-group) group="$2" ; shift 2 ;;
			-permissions) permissions="$2" ; shift 2 ;;
			*) shift 1 ;;
		esac
	done

	if test -z "$name" -o -z "$from"
	then
		echo 'You must at least provide name and from'
		return 1
	fi

	(! cmp -s -- "$from" "$name") && cp -v -- "$from" "$name"
	test -n "$owner" && chown -c -- "$owner" "$name"
	test -n "$group" && chgrp -c -- "$group" "$name"
	test -n "$permissions" && chmod -c -- "$permissions" "$name"
}

cash.dir() {
	while test "$#" -gt 0
	do
		case "$1" in
			-name) name="$2" ; shift 2 ;;
			-owner) owner="$2" ; shift 2 ;;
			-group) group="$2" ; shift 2 ;;
			-permissions) permissions="$2" ; shift 2 ;;
			*) shift 1 ;;
		esac
	done

	if test -z "$name"
	then
		echo 'You must at least provide the directory name'
		return 1
	fi

	mkdir -p "$name"
	test -n "$owner" && chown -c -- "$owner" "$name"
	test -n "$group" && chgrp -c -- "$group" "$name"
	test -n "$permissions" && chmod -c -- "$permissions" "$name"
}

cash.link() {
	while test "$#" -gt 0
	do
		case "$1" in
			-name) name="$2" ; shift 2 ;;
			-from) from="$2" ; shift ;;
			*) shift 1 ;;
		esac
	done

	if test -z "$name"
	then
		echo 'You must provide: name, from'
		return 1
	fi

	ln -s -f -v -- "$from" "$name"
}

cash.group() {
	if test -z "$1"
	then
		echo 'Please provide a group name'
		return 1
	fi
	getent group "$1" || groupadd "$1"
}

cash.user() {
	while test "$#" -gt 0
	do
		case "$1" in
			-name) name="$2" ; shift 2 ;;
			-groups) groups="$2" ; shift 2 ;;
			-password) password="$(openssl passwd -6 -salt xyz "$2")" ; shift 2 ;;
			-home) home="$2" ; shift 2 ;;
			*) shift 1 ;;
		esac
	done

	if test -z "$name" -o -z "$groups" -o -z "$password" -o -z "$home"
	then
		echo 'Provide: name, groups, password, home'
		return 1
	fi

	if ! getent passwd "$name"
	then
		useradd -p "$password" -d "$home" -G "$groups" "$name"
	else
		usermod -p "$password" -m -d "$home" -G "$groups" "$name"
	fi
}

cash.pkg() {
	if test -z "$1"
	then
		echo 'Please provide a group name'
		return 1
	fi
	dpkg -l $1 || apt install $1
}
