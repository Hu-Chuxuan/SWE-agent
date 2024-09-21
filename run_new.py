import argparse
import os
from sweagent.utils.config import keys_config
from sweagent.agent.agents import Agent, AgentArguments
from sweagent.agent.models import ModelArguments
from sweagent import CONFIG_DIR
from pdf_to_text import pdf_converter_partial, pdf_converter_full

def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def main(partial, index, commands_dir):
    directory = f"../reproducibility-bench02/{index}"
    pdf_path = directory + "/paper.pdf"
    should_reproduce_path = directory + "/should_reproduce.txt"
    with open(should_reproduce_path, 'r') as file:
        reproduction_list = [line.strip() for line in file.readlines() if len(line.strip()) > 0]
    print(reproduction_list)

    if partial:
        # should reproduce list
        paper_text = pdf_converter_partial(keys_config["OPENAI_API_KEY"], keys_config["OPENAI_ORG_ID"], pdf_path, reproduction_list)
    else:
        paper_text = pdf_converter_full(pdf_path)

    observation = None  # swe-agent also does this
    setup_args = {
        "tables": [item for item in reproduction_list if item.startswith('Table')],
        "figures": [item for item in reproduction_list if item.startswith('Figure')],
        "claims": [],
        "paper_text": paper_text,
        "paper_path": os.path.abspath(pdf_path)
    }

    working_directory = f'{directory}/replication-package'

    agent_arg = AgentArguments(
        model=ModelArguments(
            model_name="gpt4",
            total_cost_limit=0.0,
            per_instance_cost_limit=3.0,
            temperature=0.0,
            top_p=0.95,
        ),
        config_file=CONFIG_DIR / "reproduce.yaml",
    )

    agent = Agent("primary", agent_arg)
    info, trajectory = agent.run(
        setup_args=setup_args,
        observation=observation,
        return_type="info_trajectory",
        working_directory=working_directory,
        commands_dir=commands_dir
    )

if __name__ == "__main__":

    # Setup argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('--partial', type=str2bool, default=False)
    parser.add_argument('--index', type=int, required=True)
    parser.add_argument('--commands_dir', type=str, required=True)

    args = parser.parse_args()

    # Run the main function with parsed arguments
    main(partial=args.partial, index=args.index, commands_dir=args.commands_dir)

    # command = """
    # source config/commands/cursors_defaults.sh &&
    # source config/commands/cursors_edit_linting.sh &&
    # source config/commands/defaults.sh &&
    # source config/commands/edit_linting.sh &&
    # source config/commands/search.sh &&
    # open 'keys.cfg' 1
    # """
    # bash_command = f"bash -c '{command}'"
    # env = {'START_CURSOR': "", 'END_CURSOR': "", 'CURRENT_FILE': "", 'CURRENT_LINE':"", 'WINDOW':""}
    # result = subprocess.run(bash_command, shell=True, capture_output=True, text=True, env=env)
    # for line in result.stdout.splitlines():
    #     print(line)
    #     if "=" in line:
    #         key, value = line.split("=", 1)
    #         env[key] = value

    # print(env)
