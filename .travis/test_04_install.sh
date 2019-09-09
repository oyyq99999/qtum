#!/usr/bin/env bash
#
# Copyright (c) 2018 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C.UTF-8

travis_retry docker pull "$DOCKER_NAME_TAG"

export DIR_FUZZ_IN=${TRAVIS_BUILD_DIR}/qa-assets
git clone https://github.com/bitcoin-core/qa-assets ${DIR_FUZZ_IN}
export DIR_FUZZ_IN=${DIR_FUZZ_IN}/fuzz_seed_corpus/

mkdir -p "${TRAVIS_BUILD_DIR}/sanitizer-output/"
export ASAN_OPTIONS=""
export LSAN_OPTIONS="suppressions=${TRAVIS_BUILD_DIR}/test/sanitizer_suppressions/lsan"
export TSAN_OPTIONS="suppressions=${TRAVIS_BUILD_DIR}/test/sanitizer_suppressions/tsan:log_path=${TRAVIS_BUILD_DIR}/sanitizer-output/tsan"
export UBSAN_OPTIONS="suppressions=${TRAVIS_BUILD_DIR}/test/sanitizer_suppressions/ubsan:print_stacktrace=1:halt_on_error=1"
env | grep -E '^(BITCOIN_CONFIG|CCACHE_|WINEDEBUG|LC_ALL|BOOST_TEST_RANDOM|CONFIG_SHELL|(ASAN|LSAN|TSAN|UBSAN)_OPTIONS)' | tee /tmp/env
DOCKER_ADMIN="--cap-add SYS_PTRACE"
DOCKER_ID=$(docker run $DOCKER_ADMIN -idt --mount type=bind,src=$TRAVIS_BUILD_DIR,dst=$TRAVIS_BUILD_DIR --mount type=bind,src=$CCACHE_DIR,dst=$CCACHE_DIR -w $TRAVIS_BUILD_DIR --env-file /tmp/env $DOCKER_NAME_TAG)

DOCKER_EXEC () {
  docker exec $DOCKER_ID bash -c "cd $PWD && $*"
}

travis_retry DOCKER_EXEC apt-get update -qq
travis_retry DOCKER_EXEC apt-get install -qq --no-install-recommends --no-upgrade $PACKAGES $DOCKER_PACKAGES
travis_retry DOCKER_EXEC add-apt-repository -y ppa:bitcoin/bitcoin
travis_retry DOCKER_EXEC apt-get update -qq
travis_retry DOCKER_EXEC apt-get install -qq libdb4.8++-dev
