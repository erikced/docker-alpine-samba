#!/usr/bin/env sh
add_users() {
    i=0
    while read -r line; do
        i=$(expr $i + 1)
        add_user $i "$line"
    done < $USERLIST
}

add_user() {
    i=$1
    IFS=';'
    set -- $2
    unset IFS
    if [ $# -gt 5 -o $# -lt 1 ]; then
        echo "$USERLIST:$i: Invalid user configuration. "
        exit 1
    fi
    name="$1"
    password="$2"
    uid="$3"
    group="${4}"
    gid="$5"
    if [ "$gid" ]; then
        group="${group:-$name}"
        addgroup -g "$gid" "$group"
    elif [ "$group" ]; then
        addgroup $group
    fi
    adduser -D -H -s /sbin/nologin ${group:+-G $group} ${uid:+-u $uid} $name
    if [ "$password" ]; then
        printf "%s\n%s\n" "$password" "$password" | pdbedit --create $name --password-from-stdin
    fi
}

USERLIST="${USERLIST:-/config/userlist}"
if [ -f "$USERLIST" ]; then
    echo "Adding users"
    add_users
fi
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    exec /sbin/tini -- smbd --foreground --no-process-group --debug-stdout < /dev/null
fi
