#!/usr/bin/env bash
set -e
exec 2> /dev/null

phpunit() {
  ddev exec phpunit -c docroot/core/phpunit.xml.dist --colors=always --testdox "$@"
}

phpcs() {
  ddev exec phpcs --standard=docroot/core/phpcs.xml.dist --colors "$@"
}

phpcbf() {
  ddev exec phpcbf --standard=docroot/core/phpcs.xml.dist --colors "$@"
}

phpstan() {
  ddev exec phpstan analyze -c docroot/core/phpstan-partial.neon -- "$@"
}

fn=$1
typeset -f "$fn" > /dev/null && $fn "${@:2}"
