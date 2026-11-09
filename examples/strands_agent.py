"""Strands coding agent that uses the same shared skills as pi and opencode.

pip install strands-agents   (>= 1.64; file/shell tools now ship in strands.vended_tools)
Run it from inside a repo (after ./install.sh):  python strands_agent.py "let's start a new project"

Optional headroom: run `headroom proxy --port 8787` and point your model
provider's base URL at http://127.0.0.1:8787.
"""
import sys
from pathlib import Path

from strands import Agent, AgentSkills
from strands.vended_tools import edit, read, shell, write

SKILLS = Path.home() / ".agents" / "skills"
skill_dirs = sorted(str(p.parent) for p in SKILLS.glob("*/SKILL.md"))

agents_md = Path.cwd() / "AGENTS.md"
agent = Agent(
    plugins=[AgentSkills(skills=skill_dirs)],
    tools=[read, write, edit, shell],
    system_prompt=agents_md.read_text() if agents_md.exists() else None,
)

if __name__ == "__main__":
    agent(" ".join(sys.argv[1:]) or "let's start a new project")
