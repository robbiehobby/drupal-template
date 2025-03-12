#!/usr/bin/env bash
set -e

if ! which gum > /dev/null 2>&1; then
  brew install gum
fi
root=$(realpath "$(dirname "$0")") && cd "$root"

install-core() {
  version=$(gum choose --selected '11.x' -- '11.x')

  cp -f ".template/$version-composer.json" composer.json
  [[ -d docroot ]] || git clone git@git.drupal.org:project/drupal.git docroot
  git -C docroot checkout "origin/$version" > /dev/null

  rm -rf docroot/vendor vendor composer.lock
  mkdir -p vendor; ln -s ../vendor docroot/vendor; ddev composer install
  touch docroot/core/.env; ddev exec -d /var/www/html/docroot/core yarn install

  ignored=(
    'modules/'
    'sites/*/files'
    'sites/*/settings.ddev.php'
    'sites/*/settings.php'
    'sites/simpletest'
    'sites/sites.php'
    'themes/'
  )
  printf "%s\n" "${ignored[@]}" > docroot/.git/info/exclude

  [[ -f docroot/sites/default/settings.ddev.php ]] || ddev restart
}

install-fork() {
  id=drupal-$(gum input --prompt 'Issue Number > ')
  branch=$(gum input --prompt 'Branch > ')

  git -C docroot remote add "$id" git@git.drupal.org:issue/"$id".git 2> /dev/null || true
  git -C docroot fetch "$id"; git -C docroot checkout "$branch"
  composer install
}

install-site() {
  ddev drush site:install
  ddev drush theme:enable gin
  ddev drush en gin_toolbar admin_toolbar
  ddev drush config:set system.theme admin gin --no-interaction
  ddev drush config:set gin.settings enable_darkmode auto --no-interaction
  ddev drush config:set gin.settings classic_toolbar vertical --no-interaction
  ddev drush user:login
}

if [[ -d docroot ]]; then
  typeset -f "$1" > /dev/null && "$1"
else
  install-core
fi
