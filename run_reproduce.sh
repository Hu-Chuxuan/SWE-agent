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
partial=$2
commands_dir=$(realpath config/commands)

echo "Running agent..."
python3 run_new.py --index $index --partial $partial --commands_dir $commands_dir

echo "Script completed!"