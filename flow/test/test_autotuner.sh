# run the commands in ORFS root dir
echo "[INFO FLW-0029] Installing dependencies in virtual environment."
cd ../
./tools/AutoTuner/installer.sh
. ./tools/AutoTuner/setup.sh

# remove dashes and capitalize platform name
PLATFORM=${PLATFORM//-/}
# convert to uppercase
PLATFORM=${PLATFORM^^}

echo "Running Autotuner smoke tune test"
python3 -m unittest tools.AutoTuner.test.smoke_test_tune.${PLATFORM}TuneSmokeTest.test_tune

echo "Running Autotuner smoke sweep test"
python3 -m unittest tools.AutoTuner.test.smoke_test_sweep.${PLATFORM}SweepSmokeTest.test_sweep

echo "Running Autotuner smoke tests for --sample and --iteration."
python3 -m unittest tools.AutoTuner.test.smoke_test_sample_iteration.${PLATFORM}SampleIterationSmokeTest.test_sample_iteration

if [ "$PLATFORM" == "asap7" ] && [ "$DESIGN" == "gcd" ]; then
  echo "Running Autotuner ref file test (only once)"
  python3 -m unittest tools.AutoTuner.test.ref_file_check.RefFileCheck.test_files
fi

echo "Running Autotuner smoke algorithm & evaluation test"
python3 -m unittest tools.AutoTuner.test.smoke_test_algo_eval.${PLATFORM}AlgoEvalSmokeTest.test_algo_eval

# run this test last (because it modifies current path)
echo "Running Autotuner remote test"
if [ "$PLATFORM" == "asap7" ] && [ "$DESIGN" == "gcd" ]; then
  # Get the directory of the current script
  script_dir="$(dirname "${BASH_SOURCE[0]}")"
  cd "$script_dir"/../../
  latest_image=$(./etc/DockerTag.sh -dev)
  echo "ORFS_VERSION=$latest_image" > ./tools/AutoTuner/.env
  cd ./tools/AutoTuner
  docker compose up --wait
  docker compose exec ray-worker bash -c "cd /OpenROAD-flow-scripts/tools/AutoTuner/src/autotuner && \
    python3 distributed.py --design gcd --platform asap7 --server 127.0.0.1 --port 10001 \
    --config ../../../../flow/designs/asap7/gcd/autotuner.json tune --samples 1"
        docker compose down -v --remove-orphans
fi

exit $ret
