# AGENTS.md - Concre Innova API

## Scope

This repository contains the backend API for Concre Innova.

- Main solution: `Concre_Innova_API.slnx`
- Main project folder: `Concre_Innova_API`
- Database: SQL Server, database `ConcreInnovaDB`
- Usual working branch: `Branch-Allan`

## Project Rules

- Preserve the current architecture and folder structure.
- Do not rewrite the project from scratch.
- Keep business logic in the API, not in the frontend.
- Do not change public routes, DTOs, response formats, entities, or database structures unless the task requires it.
- If database changes are required, provide the complete SQL script used.
- Acceptance criteria are not required to write code. If they exist, use them to validate behavior. If they do not exist, implement from the user story, task, bug report, current behavior, API contracts, and project context.

## Architecture

Respect the existing layered design:

- `Controllers`: HTTP entry points, authorization attributes, response shaping.
- `Application`: DTOs, interfaces, services, validators, mappers, application rules.
- `Domain`: entities, constants, core domain concepts.
- `Infrastructure`: database access, repositories, email, audit, security implementations.
- `Database/Scripts`: reproducible SQL changes.

Controllers should stay thin. Business rules belong in services. Query and persistence logic belongs in repositories or infrastructure classes already used by the project.

## Security And Roles

- API authorization is the source of truth.
- `Administrador` can perform administrative actions.
- `Cliente` can use catalog, favorites, cart, account, and purchase-related flows.
- `Vendedor` can only use explicitly allowed functionality and must not receive general admin access.
- `Inactivo` or blocked users must not access protected functionality.
- Do not rely only on frontend visibility to protect actions.
- Do not commit secrets, SMTP credentials, JWT secrets, or connection strings intended for production.

## Clean Code And SOLID

- Use clear names that explain intent.
- Avoid vague names such as `data`, `manager`, `helper`, or `temp` unless they are meaningful in context.
- Keep methods small and focused.
- Avoid duplicated validation, mapping, filtering, and business rules.
- Depend on abstractions when the existing architecture already provides them.
- Do not create unnecessary abstractions for small local changes.

## Database Usage

- Avoid broad unbounded queries for list endpoints.
- Prefer pagination for catalog, admin products, users, bitacora, and similar list screens.
- Avoid N+1 queries; use joins, includes, projections, or batch queries where appropriate.
- Return only the fields required by the DTO.
- Add indexes when new filters or joins would otherwise scan large tables.

## Validation

Before finishing backend work:

- Run `dotnet build` from the repository root or solution folder.
- Run existing tests if present.
- If tests do not exist, run the API or validate affected endpoints when practical.
- Report any command that could not be executed.

## Git

- Work on the branch requested by the user.
- Do not revert user changes.
- Before commit, check `git status`.
- Before merging to `main`, pull/rebase or merge latest `main` as requested and resolve conflicts carefully.
