---
name: agent-customization
user-invocable: false
description: "Create, update, review, or fix VS Code agent customization skill documentation and workflow guidance for this repository."
---

# Agent Customization Skill

## Purpose
This skill helps you create or repair repository-scoped `SKILL.md` files for VS Code agent customization workflows. It captures the step-by-step process for choosing the right customization primitive, writing YAML frontmatter, and validating the final file.

## When to Use
Use this skill when you need to:
- define or update a workspace-scoped skill for repository customization
- document how to create `*.instructions.md`, `*.prompt.md`, `*.agent.md`, and `SKILL.md` files
- guide teammates or future contributors through the customization workflow
- fix silent YAML/frontmatter problems in an existing skill file

## Workflow
1. Determine the intended scope:
   - Workspace-scoped: `.github/skills/` or `.agents/skills/`
   - User-scoped: `{{VSCODE_USER_PROMPTS_FOLDER}}/`
2. Choose the correct customization primitive:
   - Skill for multi-step workflows or bundled assets
   - Prompt for single focused user inputs
   - Instruction for general agent guidance
   - Hook for lifecycle enforcement or deterministic shell actions
   - Custom agent for staged workflows with tool restrictions
3. Create or update the skill file:
   - include YAML frontmatter at the top
   - use `name`, `user-invocable`, and `description`
   - write a clear purpose and step-by-step usage guidance
4. Validate the file:
   - ensure the file path is correct
   - verify YAML frontmatter syntax
   - confirm the `description` contains useful trigger phrases

## Quality Criteria
- `description` is specific and includes keywords relevant to the workflow
- frontmatter is valid YAML and properly delimited with `---`
- the file is stored in a supported skill path
- the content is concise, actionable, and easy to follow

## Example Prompts
- "Help me create a workspace skill to document how to add a new prompt file."
- "Review my `SKILL.md` and verify the YAML frontmatter and description."
- "Create a skill that explains when to use prompts, instructions, and hooks in this repo."
