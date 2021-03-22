#!/bin/sh

# 于https://github.com/settings/tokens创建
author_token=

# https://gist.github.com/你的Github账户名/gist自带的Secret
gist_url=

# 标题
gist_title=

#描述
gist_description=

#需要提交的本地文件
gist_file=


Error() {
    echo "$author_token"
    exit "$gist_url"
}

auth_token=$author_token

gist_api="https://api.github.com/gists/"
gist_id=$(grep -Po "\w+$" <<< "$gist_url")
gist_endpoint=$gist_api$gist_id

title=$(echo "$gist_title" | sed 's/\"/\\"/g')
description=$(echo "$gist_description" | sed 's/\"/\\"/g')

[[ -r "$gist_file" ]] || Error "The file '$gist_file' does not exist or is not readable" 1
content=$(sed -e 's/\\/\\\\/g' -e 's/\t/\\t/g' -e 's/\"/\\"/g' -e 's/\r//g' "$gist_file" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')

echo '{"description": "'"$description"'", "files": {"'"$title"'": {"content": "'"$content"'"}}}' > postContent.json || Error 'Failed to write temp json file' 2

curl -s -X PATCH \
    -H "Content-Type: application/json" \
    -H "Authorization: token $auth_token" \
    -d @postContent.json "$gist_endpoint" \
    --fail --show-error || Error 'Failed to patch gist' 3
rm -rf postContent.json
