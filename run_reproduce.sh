#!/bin/bash
# index=$1
# partial=$2

# env_name="swe-agent-env-$index"
# echo "Creating environment: $env_name"
# python3 -m venv $env_name

# activate_script="$env_name/bin/activate"

# # Append the five source commands to the activate script
# echo "source $(realpath config/commands/cursors_defaults.sh)" >> $activate_script
# echo "source $(realpath config/commands/cursors_edit_linting.sh)" >> $activate_script
# echo "source $(realpath config/commands/defaults.sh)" >> $activate_script
# echo "source $(realpath config/commands/edit_linting.sh)" >> $activate_script
# echo "source $(realpath config/commands/search.sh)" >> $activate_script

# env_abs_path=$(realpath $env_name)
# echo "Virtual environment absolute path: $env_abs_path"
# echo "Running agent..."
# python3 run_new.py --index $index --partial $partial --venv $env_abs_path

# echo "Deleting environment: $env_name"
# rm -rf $env_name

# echo "Script completed!"

index=$1
commands_dir=$(realpath config/commands)

mkdir ./environment/$index
mkdir ./environment/$index/work_dir
cp ../reproducibility-bench02/$index/paper.pdf ./environment/$index/work_dir/
cp -r ../reproducibility-bench02/$index/replication_package ./environment/$index/work_dir/

echo "Running agent..."
python3 run_new.py --index $index --commands_dir $commands_dir 2>&1 | tee ./environment/$index/output.txt

if [ -f "./environment/$index/work_dir/reproducibility_score.json" ]; then
    cp "./environment/$index/work_dir/reproducibility_score.json" "./environment/$index/"
fi
python3 evaluation.py --index $index

rm -r ./environment/$index/work_dir/
echo "Script completed!"