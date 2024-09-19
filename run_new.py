from sweagent.agent.agents import Agent, AgentArguments
from sweagent.agent.models import ModelArguments

from sweagent import CONFIG_DIR

agent_arg=AgentArguments(
    model=ModelArguments(
        model_name="gpt4",
        total_cost_limit=0.0,
        per_instance_cost_limit=3.0,
        temperature=0.0,
        top_p=0.95,
    ),
    config_file=CONFIG_DIR / "default.yaml",
)

agent=Agent("primary", agent_arg)
print(agent.model)

# omit the env, just run in pure space

paper_text = ""
observation = None # swe-agent also does this
setup_args = {"issue": paper_text}
info, trajectory = agent.run(
    setup_args=setup_args,
    observation=observation,
    return_type="info_trajectory",
)
