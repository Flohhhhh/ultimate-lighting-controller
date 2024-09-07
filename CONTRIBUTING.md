# Contributing to [Your Project Name]

Thank you for your interest in contributing to this project! Follow the guidelines below to maintain a clean, stable codebase and ensure smooth collaboration.

## Branching Strategy

We follow a **GitFlow** workflow. Here's a summary of the branches and their purposes:

- **`main`**: This branch always contains production-ready code. Only stable and fully tested features should be merged into `main`.
- **`develop`**: Active development happens here. Features and fixes are integrated here before they reach `main`.
- **`feature/*`**: Use these branches for developing specific features or enhancements. Once completed and reviewed, merge them into `develop`.
- **`hotfix/*`**: These branches are used to address critical issues in `main`. After the fix, merge the branch into both `main` and `develop` to ensure all codebases are up-to-date.

## How to Contribute

### 1. Fork the Repository
Start by forking the repository and creating a local clone.

### 2. Create a Feature Branch
If you're adding a new feature or fixing an issue, create a feature branch from `develop`:

```bash
git checkout develop
git checkout -b feature/your-feature-name
```

### 3. Make Changes and Commit
Work on your feature, making commits as needed. Ensure your commits are clear and concise.

```bash
git commit -m "Add detailed description of changes here"
```

### 4. Push to Your Fork and Open a Pull Request
Push your branch to your fork and open a Pull Request (PR) targeting the `develop` branch.

```bash
git push origin feature/your-feature-name
```

### 5. Code Review
Your PR will be reviewed by the maintainers. Please address any feedback, and once approved, the branch will be merged into `develop`.

Thank you for following these guidelines and contributing to the project!
