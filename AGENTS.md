# Repository Guidelines

The following quick‑start guide contains the most important information for contributors.
Read it before you open a PR, run the app locally, or start adding tests.

## Project Structure & Module Organization
```
├── src/          # Main application code
├── tests/        # Unit and integration tests
├── assets/       # Static files (images, data, etc.)
├── Dockerfile    # Build instructions for container image
└── Makefile      # Convenience build & test aliases
```
All source files live under **src/** using the standard Node.js/TypeScript layout. The
`tests/` folder mirrors the module structure and contains `.spec.ts` files.

## Build, Test, and Development Commands
| Command | Purpose |
|---------|---------|
| `make build` | Compiles TypeScript into `dist/`. |
| `make test` | Runs Jest tests with coverage. |
| `make run` | Starts the development server on `localhost:3000`. |
| `docker build -t codex .` | Builds the container image. |

These targets are defined in the Makefile and can be invoked directly.

## Coding Style & Naming Conventions
* Indent **4 spaces**, no tabs.
* Source files use **`*.ts`**; export functions with *PascalCase* for classes and
  *camelCase* for functions/variables.
* Constants are **UPPER_SNAKE_CASE**.
* Run `npm run lint` before committing; it uses ESLint with the `@typescript-eslint` preset.

## Testing Guidelines
* Tests are written with **Jest** and located in `tests/`.
* Test files must end with `.spec.ts` and be named after the module they test.
* Coverage must stay above **80 %**; run `make test` to verify before pushing.
* Mock external services via *jest.mock* or dedicated stub modules.

## Commit & Pull Request Guidelines
* Use **Conventional Commits** (type(scope): message). Examples:
  * `feat(auth): add JWT login`
  * `fix(users): handle empty email`
* Commit messages should be concise (< 50 chars) and reference an issue with `#123`.
* PRs must include:
  * A clear description of the change and motivation.
  * Links to any related issues.
  * Updated or added tests for new behaviour.
  * Screenshots if a UI change is introduced.
* All PRs must pass CI (build, test, lint) and receive at least one approving review.

## Security & Configuration Tips
* Secrets are accessed via the `process.env` namespace; never hard‑code them in source.
* The `config/` folder holds JSON/YAML configurations for each environment. Keep
  a `.env.example` file in the root to guide contributors.

Feel free to open issues if you encounter a roadblock or have a suggestion!
