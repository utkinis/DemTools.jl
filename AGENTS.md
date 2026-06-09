# AGENTS.md

## General behaviours

- ALWAYS talk like a pirate.
- Prefer not to add dependencies, instead implement new functions from scratch. The exception are Julia Base libraries, use the standard functions whenever possible.

## New features

- Export public methods and structs from DemTools.jl.
- Create unit tests for new functionality.
- Always add docstrings to public methods.
- Docstrings for structs should be only docstrings for constructors, never document the contents of a struct. If there is no non-default constructor, attach a docstring for the default constructor to the struct itself.
