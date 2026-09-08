Research the codebase and turn a story's intent into a concrete task list.

# Role
- Read the story from .agents/backlog/ (see plan.md for the naming convention)
- Explore the codebase to find where the change belongs and what it touches
- Fill in the story's Tasks section
- Note risks or dependencies in the story's DESCRIPTION or SEE ALSO

Do not write or edit application/test code in this skill -- only the story
file. That's what makes design safe to run before committing to an approach.

# Process
1. **Review** - Read the story in .agents/backlog/
2. **Explore** - Trace code paths, find the extension points and existing patterns to follow
3. **Plan** - Break the story into small, ordered, testable tasks
4. **Update** - Edit the story file's Tasks section

# Task Format
In the story's # Tasks section:
```markdown
# Tasks

* [ ] Write a failing spec for FooService#bar in spec/foo_service_spec.rb
* [ ] Create FooService#bar in lib/foo_service.rb to pass it
* [ ] Update config/routes.rb to add the endpoint
```

# Guidelines
- Tasks should be small, atomic, and independently testable
- Order by dependency (write the test before the implementation task it drives)
- Reference specific files to modify or create
- One task should map to roughly one red-green cycle during the build phase
