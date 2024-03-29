#!/usr/bin/env bash
set -e

__backup_loc="/app/git/util-scripts/backup"

__time_stamp=$(date +%s)
__backup_dir_timebased="${__backup_loc}/${__time_stamp}"
if [[ -d "${__backup_dir_timebased}" ]]; then
    echo "Use a empty directory"
    exit 1
fi

mkdir -p "${__backup_dir_timebased}"

__clone_urls=$(curl "https://api.github.com/users/arpanrec/repos" | jq '.[].clone_url' -r)

for clone_url in ${__clone_urls}; do
    cd "${__backup_dir_timebased}"
    git clone --bare "${clone_url}"
done

cd "${__backup_dir_timebased}" &&
    tar -zcvf "../github.${__time_stamp}.tar.gz" ./*

rm -rf "${__backup_dir_timebased}"
