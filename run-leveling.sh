#!/bin/bash

T=5

at_PST=$( TZ="America/Los_Angeles" date +"%Y-%m-%d %I:%M:%S %p" )
echo "------------------------------------"
echo "NEW BENCHMARK"
echo "------------------------------------"
echo "db: leveling, at $at_PST PST"

# block cache size
cache_size_mb=64
cache_size=$( python3 -c "print( int( $cache_size_mb * 2**20 ) )" )

echo "cache_size = $cache_size"

# load the data...
echo "loading data, T=$T"
./bin/ycsb load rocksdb -s \
  -P workloads/workloada \
  -p rocksdb.dir=/db_bench \
  -p rocksdb.cacheSize=$cache_size \
  -p rocksdb.maxBytesForLevelMultiplier=$T

# wait for compactions to finish by running read-only
echo "waiting for compactions..."
./bin/ycsb run rocksdb -s \
  -P workloads/workloadc \
  -p rocksdb.dir=/db_bench \
  -p rocksdb.cacheSize=$cache_size \
  -p rocksdb.maxBytesForLevelMultiplier=$T

# run the workloads least write heavy to most write heavy
for workload in 'c' 'b' 'd' 'e' 'f' 'a'; do
  echo "running workload$workload"
  ./bin/ycsb run rocksdb -s \
    -P workloads/workload${workload} \
    -p rocksdb.dir=/db_bench \
    -p rocksdb.cacheSize=$cache_size \
    -p rocksdb.maxBytesForLevelMultiplier=$T
  sleep 2

  echo "waiting for compactions..."
  # wait for compactions to finish by running read-only
  ./bin/ycsb run rocksdb -s \
    -P workloads/workloadc \
    -p rocksdb.dir=/db_bench \
    -p rocksdb.cacheSize=$cache_size \
    -p rocksdb.maxBytesForLevelMultiplier=$T
done

exit 0