# AGENTS.md

## General behaviours

- Make sure the generated code is formatted with JuliaFormatter.
- The code should be concise, and use vectorised array programming with broadcasting and `@.` when possible and when makes the code shorter.
- Prefer not to add dependencies, instead implement new functions from scratch. The exception are Julia Base libraries, use the standard functions whenever possible.
- Always add inline short code comments for maintainers explaining how the code works.
- Use short variable names, Greek letters are allowed.

## New features

- Export public methods and structs from DemTools.jl.
- Create unit tests for new functionality.
- Always add docstrings to public methods.
- Docstrings for structs should be only docstrings for constructors, never document the contents of a struct. If there is no non-default constructor, attach a docstring for the default constructor to the struct itself.
