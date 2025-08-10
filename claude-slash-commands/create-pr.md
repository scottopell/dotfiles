# Create Pull Request

You are an AI assistant helping to create a pull request using git and the GitHub CLI (gh).

## Your task:
1. **Analyze the current repository state** - Check what branch we're on, what changes exist, and the overall git status
2. **Ensure all work is committed** - If there are uncommitted changes, guide the user to commit them
3. **Create or switch to a feature branch** - If we're on the main branch, create a new feature branch
4. **Push the branch and create a PR** - Use gh CLI to create the pull request

## Important constraints:
- **Never assume the current state** - Always check git status, current branch, and uncommitted changes first
- **Handle all scenarios** - Work whether we're on main, already on a feature branch, or have uncommitted changes
- **Use descriptive branch names** - Suggest meaningful branch names based on the changes
- **Verify gh CLI is available** - Check that the user has gh CLI installed and authenticated

## Step-by-step process:

### 1. First, analyze the current state
Run these commands in parallel to understand the repository:
- `git status` - Check for uncommitted changes and current branch
- `git branch` - See all local branches
- `git remote -v` - Verify we have a remote repository
- `gh auth status` - Verify GitHub CLI authentication

### 2. Handle uncommitted changes
If there are uncommitted changes:
- Show the user what changes exist using `git diff` and `git status`
- Ask them to commit the changes or provide a commit message
- If they provide a message, commit the changes for them

### 3. Handle branch management
**If on main/master branch:**
- Ask for a feature branch name (or suggest one based on recent commits)
- Create and switch to the new branch: `git checkout -b <branch-name>`

**If already on a feature branch:**
- Confirm this is the correct branch for the PR
- Check if the branch exists on remote: `git ls-remote --heads origin <branch-name>`

### 4. Push and create PR
- Push the branch: `git push -u origin <branch-name>` (use -u to set upstream)
- Create the PR: `gh pr create --web` (opens browser) or `gh pr create` (interactive CLI)
- Provide the PR URL when created

### 5. Error handling
- If gh CLI is not installed, provide installation instructions
- If not authenticated with GitHub, guide through `gh auth login`
- If there are conflicts or issues, explain clearly and provide solutions

## Example usage:
When this slash command is invoked, start by running the analysis commands and then guide the user through each step based on what you discover about their repository state.
