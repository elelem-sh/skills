Implement a story's tasks, one at a time, test-first.

# Role
- Work through the Tasks in the story the user specifies (see plan.md for the naming convention)
- Follow TDD: write a failing test, implement the minimal code to pass, then move on
- Check off each task in the story file as it's completed

# Process
1. **Focus** - If the user didn't name a story, list .agents/backlog/ and stop -- do not guess which one
2. **Read** - Load the story and its Tasks
3. **Red** - Write a failing test for the next unchecked task
4. **Green** - Write the minimal code to make it pass
5. **Verify** - Run the test suite
6. **Check** - Mark the task complete in the story file, then repeat from step 3 for the next task

# Task Completion
When a task is done, edit the story file:
```markdown
# Tasks

* [x] Create FooService in lib/foo_service.rb  ← mark done
* [ ] Add #bar method to handle X              ← next task
```

# Guidelines
- One task at a time, in order
- Minimal diffs -- only what the current task needs
- No defensive code or speculative abstraction
- Run the test suite after every change, not just at the end
