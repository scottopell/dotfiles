#!/usr/bin/env python3
"""Development tasks for the dotfiles repository."""

import argparse
import re
import subprocess
from collections import defaultdict
from datetime import date, datetime
from pathlib import Path

ROOT = Path(__file__).parent

VALID_STATUSES = {"ready", "in-progress", "pending", "blocked", "done", "wont-do"}
VALID_PRIORITIES = {"p0", "p1", "p2", "p3", "p4"}
TASK_FILENAME_PATTERN = (
    r"^(\d{3})-(p[0-4])-(" + "|".join(VALID_STATUSES) + r")-(.+)\.md$"
)


# ---------------------------------------------------------------------------
# Task helpers
# ---------------------------------------------------------------------------


def parse_task_file(path: Path) -> dict | None:
    """Parse a task file and return metadata, or None if unparseable."""
    content = path.read_text()

    if not content.startswith("---\n"):
        return None

    end = content.find("\n---\n", 4)
    if end == -1:
        return None

    frontmatter = content[4:end]
    fields: dict[str, str] = {}
    for line in frontmatter.strip().split("\n"):
        if ":" in line:
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip()

    name = path.name
    match = re.match(TASK_FILENAME_PATTERN, name)
    if match:
        return {
            "path": path,
            "number": match.group(1),
            "file_priority": match.group(2),
            "file_status": match.group(3),
            "slug": match.group(4),
            "fields": fields,
        }

    # Tolerate old format: NNN-slug.md for migration
    old_match = re.match(r"^(\d{3})-(.+)\.md$", name)
    if old_match:
        return {
            "path": path,
            "number": old_match.group(1),
            "file_priority": None,
            "file_status": None,
            "slug": old_match.group(2),
            "fields": fields,
        }

    return None


def get_expected_filename(number: str, priority: str, status: str, slug: str) -> str:
    return f"{number}-{priority}-{status}-{slug}.md"


def infer_created_date(path: Path) -> str:
    """Return the earliest git commit date, file mtime, or today."""
    try:
        result = subprocess.run(
            ["git", "log", "--follow", "--diff-filter=A", "--format=%as", str(path)],
            capture_output=True,
            text=True,
            cwd=path.parent,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip().splitlines()[-1]
    except Exception:
        pass

    try:
        mtime = path.stat().st_mtime
        return datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")
    except Exception:
        pass

    return date.today().isoformat()


def next_task_number(tasks_dir: Path) -> str:
    """Return the next available 3-digit task number."""
    existing: list[int] = []
    for p in tasks_dir.glob("*.md"):
        if p.name == "_TEMPLATE.md":
            continue
        m = re.match(r"^(\d{3})-", p.name)
        if m:
            existing.append(int(m.group(1)))
    return f"{(max(existing, default=0) + 1):03d}"


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
    number = next_task_number(tasks_dir)
    filename = get_expected_filename(number, priority, status, slug_clean)
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

    template = tasks_dir / "_TEMPLATE.md"
    tasks = []
    for path in sorted(tasks_dir.glob("*.md")):
        if path == template:
            continue
        task = parse_task_file(path)
        if task:
            tasks.append(task)

    if status_filter:
        tasks = [t for t in tasks if t["fields"].get("status") == status_filter]

    if not tasks:
        print("No tasks found.")
        return True

    for task in tasks:
        fields = task["fields"]
        status = fields.get("status", "?")
        priority = fields.get("priority", "?")
        # Extract title from file content
        content = task["path"].read_text()
        title_match = re.search(r"^# (.+)$", content, re.MULTILINE)
        title = title_match.group(1) if title_match else task["slug"]
        print(f"  {task['number']}  {priority:<3}  {status:<12}  {title}")

    return True


def cmd_tasks_validate(quiet: bool = False) -> bool:
    """Validate all task files conform to naming and frontmatter conventions."""
    tasks_dir = ROOT / "tasks"
    if not tasks_dir.exists():
        if not quiet:
            print("No tasks/ directory found, skipping.")
        return True

    errors: list[str] = []
    task_files = sorted(tasks_dir.glob("*.md"))
    template = tasks_dir / "_TEMPLATE.md"

    for path in task_files:
        if path == template:
            continue

        name = path.name
        content = path.read_text()

        if not content.startswith("---\n"):
            errors.append(f"{name}: missing YAML frontmatter (must start with ---)")
            continue

        end = content.find("\n---\n", 4)
        if end == -1:
            errors.append(f"{name}: malformed YAML frontmatter (no closing ---)")
            continue

        frontmatter = content[4:end]
        fields: dict[str, str] = {}
        for line in frontmatter.strip().split("\n"):
            if ":" in line:
                key, _, value = line.partition(":")
                fields[key.strip()] = value.strip()

        if "status" not in fields:
            errors.append(f"{name}: missing 'status' field")
        elif fields["status"] not in VALID_STATUSES:
            errors.append(
                f"{name}: invalid status '{fields['status']}' "
                f"(valid: {', '.join(sorted(VALID_STATUSES))})"
            )

        if "priority" not in fields:
            errors.append(f"{name}: missing 'priority' field")
        elif fields["priority"] not in VALID_PRIORITIES:
            errors.append(
                f"{name}: invalid priority '{fields['priority']}' "
                f"(valid: {', '.join(sorted(VALID_PRIORITIES))})"
            )

        if "created" not in fields:
            errors.append(f"{name}: missing 'created' field")
        elif not re.match(r"^\d{4}-\d{2}-\d{2}$", fields["created"]):
            errors.append(f"{name}: invalid 'created' date (expected YYYY-MM-DD)")

        task = parse_task_file(path)
        if task and fields.get("status") and fields.get("priority"):
            expected = get_expected_filename(
                task["number"], fields["priority"], fields["status"], task["slug"]
            )
            if name != expected:
                errors.append(
                    f"{name}: filename doesn't match frontmatter, expected: {expected}"
                )

    number_map: dict[str, list[str]] = defaultdict(list)
    for path in task_files:
        if path == template:
            continue
        task = parse_task_file(path)
        if task:
            number_map[task["number"]].append(path.name)
    for num, files in sorted(number_map.items()):
        if len(files) > 1:
            errors.append(f"duplicate task number {num}: {', '.join(files)}")

    if errors:
        if not quiet:
            print(f"✗ {len(errors)} task validation error(s):")
            for err in errors:
                print(f"  - {err}")
            print("\nRun './dev.py tasks fix' to auto-fix.")
        return False

    if not quiet:
        count = len(task_files) - (1 if template.exists() else 0)
        print(f"✓ {count} task files validated")
    return True


def cmd_tasks_fix() -> bool:
    """Auto-fix task files: inject missing 'created' fields and rename to match frontmatter."""
    tasks_dir = ROOT / "tasks"
    if not tasks_dir.exists():
        print("No tasks/ directory found.")
        return True

    task_files = sorted(tasks_dir.glob("*.md"))
    template = tasks_dir / "_TEMPLATE.md"
    renamed = 0
    patched = 0
    errors: list[str] = []

    for path in task_files:
        if path == template:
            continue

        task = parse_task_file(path)
        if not task:
            errors.append(f"{path.name}: could not parse file")
            continue

        fields = task["fields"]

        if "created" not in fields or not re.match(
            r"^\d{4}-\d{2}-\d{2}$", fields.get("created", "")
        ):
            created = infer_created_date(path)
            content = path.read_text()
            if re.search(r"^created:.*$", content, re.MULTILINE):
                content = re.sub(
                    r"^created:.*$",
                    f"created: {created}",
                    content,
                    count=1,
                    flags=re.MULTILINE,
                )
            else:
                content = content.replace("---\n", f"---\ncreated: {created}\n", 1)
            path.write_text(content)
            print(f"  {path.name}: injected created: {created}")
            fields["created"] = created
            patched += 1

        if not fields.get("status") or not fields.get("priority"):
            errors.append(f"{path.name}: missing status or priority, cannot rename")
            continue

        expected = get_expected_filename(
            task["number"], fields["priority"], fields["status"], task["slug"]
        )
        if path.name != expected:
            new_path = tasks_dir / expected
            if new_path.exists():
                errors.append(
                    f"{path.name}: cannot rename to {expected}, file already exists"
                )
                continue
            path.rename(new_path)
            print(f"  {path.name} -> {expected}")
            renamed += 1

    print(f"\n{patched} patched, {renamed} renamed", end="")
    if errors:
        print(f", {len(errors)} error(s):")
        for err in errors:
            print(f"  - {err}")
        return False
    print()
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
        choices=sorted(VALID_STATUSES),
        help="Filter by status",
    )

    new_parser = tasks_sub.add_parser("new", help="Create a new task")
    new_parser.add_argument("slug", help="Short kebab-case description, e.g. fix-tmux-paste-bug")
    new_parser.add_argument(
        "--priority",
        choices=sorted(VALID_PRIORITIES),
        default="p2",
    )
    new_parser.add_argument(
        "--status",
        choices=sorted(VALID_STATUSES),
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
