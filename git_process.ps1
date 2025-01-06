# ---------------------------------
# GIT WORKFLOW
# ---------------------------------

# ---- Global Configs ----
    git config --global user.name "Your Name"     # Replace "Your Name" with your full name
    git config --global user.email "your-email@example.com" # Replace with your email
    git config --global credential.helper cache   # Cache your credentials for a short time
    git config --global credential.helper store   # Store credentials permanently (use carefully)
    git config --global --list   # List all global configurations

    git init # Initializes a new repository in the current directory
    git clone https://github.com/<username>/<repository>.git  # Replace with your repo URL

# ---- Step 3: Check Status and Fetch Changes ----
# Check the status of your local repository
    git status                   # Shows modified, staged, and untracked files

# Fetch changes from the remote repository (without merging)
    git fetch                    # Updates the remote-tracking branches with no changes to local branches

# Pull the latest changes from the remote repository (fetch + merge)
    git pull                     # Updates your local branch with remote changes

# ---- Step 4: Make Changes to Code ----
# This step is manual. Edit your code in your text editor (e.g., VS Code).
# Use `git status` to see which files have been modified.

# ---- Step 5: Stage, Commit, and Push Changes ----
# Stage changes (prepare files for the commit)
    git add <file>               # Stage a specific file
    git add .                    # Stage all changes in the current directory

# Commit staged changes (save changes locally)
    git commit -m "Your commit message here"  # Replace with a descriptive message

# Push changes to the remote repository
    git push                     # Pushes commits to the remote branch

# ---- Step 6: Branching (Optional) ----
# Create a new branch
    git branch <branch-name>     # Create a branch with the specified name

# Switch to a branch
    git checkout <branch-name>   # Switches to the specified branch

# Create and switch to a new branch in one step
    git checkout -b <branch-name>    # Creates and switches to a new branch

# Merge a branch into the current branch
    git merge <branch-name>      # Merges the specified branch into the current branch

# Delete a branch
    git branch -d <branch-name>  # Deletes a branch (only if merged)
    git branch -D <branch-name>  # Force delete a branch (even if not merged)

# ---- Step 7: Repository Cleanup (Optional) ----
# Remove a file or folder from tracking (use with caution)
    git rm <file>                # Removes a file and stages the removal
    git rm -r <folder>           # Removes a folder recursively

# Add a .gitignore file to exclude files or directories from tracking
# Example: echo "*.log" > .gitignore

# ---- Step 8: Check Logs and History ----
# View commit history
    git log                      # Shows the commit history in the current branch
    git log --oneline            # Compact commit history (one line per commit)

# Show differences between commits
    git diff                     # Shows unstaged changes
    git diff <commit1> <commit2> # Shows differences between two commits

# ---- Step 9: Reset or Undo Changes (Optional) ----
# Unstage changes
    git reset <file>             # Unstages the specified file
    git reset                    # Unstages all staged files

# Undo changes in working directory (not committed)
    git checkout -- <file>       # Reverts a file to the last committed state

# Roll back to a previous commit
    git reset --hard <commit-hash>   # Resets the repository to a specific commit (deletes changes)

# ---- Additional Commands ----
# Add a new remote repository
    git remote add origin <url>  # Adds a new remote named "origin"
    git remote -v                # Lists all configured remotes

# Rename the current branch (e.g., to main)
    git branch -M main           # Renames the branch to "main"

# Push the renamed branch to the remote
    git push --set-upstream origin main   # Links the renamed branch to the remote branch

# ---- Check Git Version ----
# Display the installed version of Git
    git --version                # Shows the current version of Git

