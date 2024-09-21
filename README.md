**SWE-agent for ReproduceBench.**

Put `reproducibility-bench02` in the same folder as SWE-agent. `reproducibility-bench02` consists of various folders labeled by paper ID. e.g., `reproducibility-bench02/94`

**Setup env**
```
git clone https://github.com/Hu-Chuxuan/SWE-agent.git
cd SWE-agent
conda create --name swe-agent-env python=3.11.8
conda activate swe-agent
python -m pip install --upgrade pip && pip install --editable .
pip install pdf2image
pip install pdfplumber
```

**Setup key**
```
vim keys.cfg
```
Insert the following:
```
OPENAI_API_KEY: "your-api-key"
OPENAI_ORG_ID: "your-org-id"
```

**Run the code**
```
./run_reproduce.sh 94 False
```
the first parameter is the paper index, the second parameter is whether we want to pass only necessary texts to the agent.

**Changes I made comparing to the original swe-agent**
1. Set up our own env for reproducibility. (`sweagent/agent/reproducibility_env.py`)
2. Modified the prompts. (`config/reproduce.yaml`) [Details](https://docs.google.com/document/d/1Eh2DXy3mReiDSC1MQVeBsedt4Y_sFXGL6KEwM4kKu9U/edit?usp=sharing)
3. Agent running logic: state->openfile & working_dir; observation->terminal outputs. (`sweagent/agent/agents.py`, the `run` function).
4. Modified the ACI commands to make them bug free from jq package && print out the env var bc we can't install docker on campus cluster (`config/commands`).

