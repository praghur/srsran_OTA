#!/bin/bash

# Function to run traceroute 40 times
run_traceroute() {
  for i in {1..40}
  do
    traceroute -U -f 2 -m 2 -p 33435 10.45.2.10
    sleep 1  # Adding a small delay between each run
  done
}

# Run the traceroute function every hour for 24 hours
for hour in {1..24}
do
  run_traceroute
  sleep 3600  # Wait for an hour before the next set of runs
done
