#!/usr/bin/env bash
#
# Copyright (c) 2018 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

export LC_ALL=C.UTF-8

if [ "$RUN_UNIT_TESTS" = "true" ]; then
  BEGIN_FOLD unit-tests
  DOCKER_EXEC make $MAKEJOBS check VERBOSE=1
  END_FOLD
fi

if [ "$RUN_FUNCTIONAL_TESTS" = "true" ]; then
  BEGIN_FOLD functional-tests
  DOCKER_EXEC test/functional/test_runner.py --combinedlogslen=500 --failfast --coverage --quiet --exclude wallet_txn_clone,rpc_psbt,wallet_multiwallet,feature_block,qtum_ignore_mpos_participant_reward,qtum_pos_conflicting_txs,qtum_evm_globals,qtum_duplicate_stake,qtum_callcontract_timestamp
  END_FOLD
fi

if [ "$RUN_FUZZ_TESTS" = "true" ]; then
  BEGIN_FOLD fuzz-tests
  DOCKER_EXEC test/fuzz/test_runner.py -l DEBUG ${DIR_FUZZ_IN}
  END_FOLD
fi
