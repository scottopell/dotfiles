#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "taskmd @ git+https://github.com/scottopell/taskmd.git",
# ]
# ///
"""Development tasks for the dotfiles repository."""

import argparse
import re
from datetime import date
from pathlib import Path

import taskmd

ROOT = Path(__file__).parent


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------


def cmd_tasks_new(slug: str, priority: str, status: str) -> bool:
    """Create a new task file from the template."""
    tasks_dir = ROOT / "tasks"
    tasks_dir.mkdir(exist_ok=True)

    template = tasks_dir / "_TEMPLATE.md"
    if not template.exists():
        print(f"Template not found at {template}")
        return False

    slug_clean = re.sub(r"[^a-z0-9]+", "-", slug.lower()).strip("-")
    number = taskmd.next_number(tasks_dir)
    filename = taskmd.get_expected_filename(number, priority, status, slug_clean)
    dest = tasks_dir / filename

    content = template.read_text()
    content = content.replace("YYYY-MM-DD", date.today().isoformat())
    content = content.replace("priority: p2", f"priority: {priority}")
    content = content.replace("status: ready", f"status: {status}")
    content = content.replace("# Task Title", f"# {slug.replace('-', ' ').title()}")

    dest.write_text(content)
    print(f"Created {dest.relative_to(ROOT)}")
    return True


def cmd_tasks_list(status_filter: str | None = None) -> bool:
    """List tasks, optionally filtered by status."""
    tasks_dir = ROOT / "tasks"
    if not tasks_dir.exists():
        print("No tasks/ directory found.")
        return True

    tasks = []
    for path in sorted(tasks_dir.glob("*.md")):
        task = taskmd.parse_task_file(path)
        if task:
            tasks.append(task)

    if status_filter:
        tasks = [t for t in tasks if t.fields.get("status") == status_filter]

    if not tasks:
        print("No tasks found.")
        return True

    for task in tasks:
        status = task.fields.get("status", "?")
        priority = task.fields.get("priority", "?")
        content = task.path.read_text()
        title_match = re.search(r"^# (.+)$", content, re.MULTILINE)
        title = title_match.group(1) if title_match else task.slug
        print(f"  {task.number:04d}  {priority:<3}  {status:<12}  {title}")

    return True


def cmd_tasks_validate(quiet: bool = False) -> bool:
    """Validate all task files conform to naming and frontmatter conventions."""
    tasks_dir = ROOT / "tasks"
    if not tasks_dir.exists():
        if not quiet:
            print("No tasks/ directory found, skipping.")
        return True

    result = taskmd.validate(tasks_dir)

    if not result.ok:
        if not quiet:
            print(f"✗ {len(result.errors)} task validation error(s):")
            for err in result.errors:
                print(f"  - {err}")
            print("\nRun './dev.py tasks fix' to auto-fix.")
        return False

    if not quiet:
        print(f"✓ {result.file_count} task files validated")
    return True


def cmd_tasks_fix() -> bool:
    """Auto-fix task files: inject missing 'created' fields and rename to match frontmatter."""
    tasks_dir = ROOT / "tasks"
    if not tasks_dir.exists():
        print("No tasks/ directory found.")
        return True

    result = taskmd.fix(tasks_dir)

    for old, new in result.renames:
        print(f"  {old} -> {new}")

    print(result.summary())

    if not result.ok:
        print(f"{len(result.errors)} error(s):")
        for err in result.errors:
            print(f"  - {err}")
        return False

    return True


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dev.py", description="Dotfiles development tasks"
    )
    sub = parser.add_subparsers(dest="command", required=True)

    # tasks
    tasks_parser = sub.add_parser("tasks", help="Task management")
    tasks_sub = tasks_parser.add_subparsers(dest="tasks_command", required=True)

    tasks_sub.add_parser("validate", help="Validate task files")
    tasks_sub.add_parser("fix", help="Auto-fix task files (inject created, rename)")

    list_parser = tasks_sub.add_parser("list", help="List tasks")
    list_parser.add_argument(
        "--status",
        choices=sorted(taskmd.VALID_STATUSES),
        help="Filter by status",
    )

    new_parser = tasks_sub.add_parser("new", help="Create a new task")
    new_parser.add_argument("slug", help="Short kebab-case description, e.g. fix-tmux-paste-bug")
    new_parser.add_argument(
        "--priority",
        choices=sorted(taskmd.VALID_PRIORITIES),
        default="p2",
    )
    new_parser.add_argument(
        "--status",
        choices=sorted(taskmd.VALID_STATUSES),
        default="ready",
    )

    args = parser.parse_args()

    if args.command == "tasks":
        if args.tasks_command == "validate":
            if not cmd_tasks_validate():
                raise SystemExit(1)
        elif args.tasks_command == "fix":
            if not cmd_tasks_fix():
                raise SystemExit(1)
        elif args.tasks_command == "list":
            cmd_tasks_list(status_filter=getattr(args, "status", None))
        elif args.tasks_command == "new":
            if not cmd_tasks_new(args.slug, args.priority, args.status):
                raise SystemExit(1)


if __name__ == "__main__":
    main()
