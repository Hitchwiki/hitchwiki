set -e
cd $(dirname $0)/vendor/discourse
bundle exec rails server -b 46.101.117.158 2>&1 >> ../../../logs/discourse.log
