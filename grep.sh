#!/bin/bash

grep \
  -E 'loading data|running workload|Throughput|waiting for compactions' \
  $1
