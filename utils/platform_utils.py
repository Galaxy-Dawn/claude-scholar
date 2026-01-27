"""
Cross-platform utility functions for Python projects
Works on Windows, macOS, and Linux
"""

import os
import sys
import platform
import subprocess
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Optional, Dict, Any
import glob as glob_module

# Platform detection
IS_WINDOWS = platform.system() == 'Windows'
IS_MACOS = platform.system() == 'Darwin'
IS_LINUX = platform.system() == 'Linux'


def get_home_dir() -> Path:
    """Get the user's home directory (cross-platform)"""
    return Path.home()


def get_claude_dir() -> Path:
    """Get the Claude config directory"""
    return get_home_dir() / '.claude'


def get_temp_dir() -> Path:
    """Get the temp directory (cross-platform)"""
    return Path(os.tmpdir())


def get_plan_dir() -> Path:
    """Get the plan directory"""
    plan_dir = get_claude_dir() / 'plan'
    plan_dir.mkdir(parents=True, exist_ok=True)
    return plan_dir


def ensure_dir(dir_path: Path) -> Path:
    """Ensure a directory exists (create if not)"""
    dir_path.mkdir(parents=True, exist_ok=True)
    return dir_path


def get_date_string() -> str:
    """Get current date in YYYY-MM-DD format"""
    return datetime.now().strftime('%Y-%m-%d')


def get_time_string() -> str:
    """Get current time in HH:MM format"""
    return datetime.now().strftime('%H:%M')


def get_datetime_string() -> str:
    """Get current datetime in YYYY-MM-DD HH:MM:SS format"""
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')


def find_files(dir_path: Path, pattern: str, max_age_days: Optional[int] = None, recursive: bool = False) -> List[Dict[str, Any]]:
    """
    Find files matching a pattern in a directory (cross-platform)

    Args:
        dir_path: Directory to search
        pattern: File pattern (e.g., "*.tmp", "*.md")
        max_age_days: Only return files modified within this many days
        recursive: Search subdirectories

    Returns:
        List of dicts with 'path' and 'mtime' keys
    """
    if not dir_path.exists():
        return []

    results = []

    # Use glob for pattern matching
    glob_pattern = str(dir_path / ('**' if recursive else '') / pattern)
    files = glob_module.glob(glob_pattern, recursive=recursive)

    for file_path in files:
        file_path = Path(file_path)
        try:
            stat = file_path.stat()
            mtime = stat.st_mtime

            if max_age_days is not None:
                import time
                age_in_days = (time.time() - mtime) / (86400)
                if age_in_days <= max_age_days:
                    results.append({'path': str(file_path), 'mtime': mtime})
            else:
                results.append({'path': str(file_path), 'mtime': mtime})
        except (OSError, PermissionError):
            # Ignore permission errors
            pass

    # Sort by modification time (newest first)
    results.sort(key=lambda x: x['mtime'], reverse=True)
    return results


def command_exists(cmd: str) -> bool:
    """
    Check if a command exists in PATH (cross-platform)
    Uses shutil.which for safety
    """
    if not cmd or not isinstance(cmd, str):
        return False

    # Basic validation - only allow alphanumeric, dash, underscore, dot
    if not cmd.replace('-', '').replace('_', '').replace('.', '').isalnum():
        return False

    return shutil.which(cmd) is not None


def run_command(cmd: List[str], cwd: Optional[Path] = None, capture: bool = True) -> Dict[str, Any]:
    """
    Run a command and return output

    SECURITY NOTE: This function executes shell commands. Only use with
    trusted, hardcoded commands. Never pass user-controlled input directly.

    Args:
        cmd: Command and arguments as list (safer than string)
        cwd: Working directory
        capture: Whether to capture output

    Returns:
        Dict with 'success', 'output', 'returncode' keys
    """
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=capture,
            text=True,
            check=False
        )
        return {
            'success': result.returncode == 0,
            'output': result.stdout.strip(),
            'stderr': result.stderr.strip(),
            'returncode': result.returncode
        }
    except (subprocess.SubprocessError, FileNotFoundError) as e:
        return {
            'success': False,
            'output': '',
            'stderr': str(e),
            'returncode': -1
        }


def is_git_repo(cwd: Optional[Path] = None) -> bool:
    """Check if current directory is a git repository"""
    result = run_command(['git', 'rev-parse', '--git-dir'], cwd=cwd)
    return result['success']


def get_git_modified_files(patterns: Optional[List[str]] = None) -> List[str]:
    """Get git modified files"""
    if not is_git_repo():
        return []

    result = run_command(['git', 'diff', '--name-only', 'HEAD'])
    if not result['success']:
        return []

    files = result['output'].split('\n') if result['output'] else []
    files = [f for f in files if f]

    if patterns:
        import re
        files = [
            f for f in files
            if any(re.search(pattern, f) for pattern in patterns)
        ]

    return files


def read_file(file_path: Path) -> Optional[str]:
    """Read a text file safely"""
    try:
        return file_path.read_text(encoding='utf-8')
    except (FileNotFoundError, PermissionError, UnicodeDecodeError):
        return None


def write_file(file_path: Path, content: str) -> bool:
    """Write a text file"""
    try:
        ensure_dir(file_path.parent)
        file_path.write_text(content, encoding='utf-8')
        return True
    except (OSError, PermissionError):
        return False


def append_file(file_path: Path, content: str) -> bool:
    """Append to a text file"""
    try:
        ensure_dir(file_path.parent)
        with open(file_path, 'a', encoding='utf-8') as f:
            f.write(content)
        return True
    except (OSError, PermissionError):
        return False


def replace_in_file(file_path: Path, search: str, replace: str) -> bool:
    """Replace text in a file (cross-platform sed alternative)"""
    content = read_file(file_path)
    if content is None:
        return False

    new_content = content.replace(search, replace)
    return write_file(file_path, new_content)


def count_in_file(file_path: Path, pattern: str) -> int:
    """Count occurrences of a pattern in a file"""
    content = read_file(file_path)
    if content is None:
        return 0

    import re
    matches = re.findall(pattern, content)
    return len(matches)


def grep_file(file_path: Path, pattern: str) -> List[Dict[str, Any]]:
    """Search for pattern in file and return matching lines with line numbers"""
    content = read_file(file_path)
    if content is None:
        return []

    import re
    lines = content.split('\n')
    results = []

    for idx, line in enumerate(lines, 1):
        if re.search(pattern, line):
            results.append({'line_number': idx, 'content': line})

    return results


def get_platform_info() -> Dict[str, Any]:
    """Get platform information"""
    return {
        'system': platform.system(),
        'release': platform.release(),
        'version': platform.version(),
        'machine': platform.machine(),
        'processor': platform.processor(),
        'is_windows': IS_WINDOWS,
        'is_macos': IS_MACOS,
        'is_linux': IS_LINUX,
        'python_version': sys.version_info,
        'home_dir': str(get_home_dir()),
        'temp_dir': str(get_temp_dir()),
    }


def log(message: str) -> None:
    """Log to stderr (visible to user in Claude Code)"""
    print(message, file=sys.stderr)


def output(data: Any) -> None:
    """Output to stdout (returned to Claude)"""
    if isinstance(data, (dict, list)):
        import json
        print(json.dumps(data, ensure_ascii=False, indent=2))
    else:
        print(data)


# Module exports
__all__ = [
    # Platform info
    'IS_WINDOWS',
    'IS_MACOS',
    'IS_LINUX',
    'get_platform_info',

    # Directories
    'get_home_dir',
    'get_claude_dir',
    'get_temp_dir',
    'get_plan_dir',
    'ensure_dir',

    # Date/Time
    'get_date_string',
    'get_time_string',
    'get_datetime_string',

    # File operations
    'find_files',
    'read_file',
    'write_file',
    'append_file',
    'replace_in_file',
    'count_in_file',
    'grep_file',

    # System
    'command_exists',
    'run_command',
    'is_git_repo',
    'get_git_modified_files',

    # I/O
    'log',
    'output',
]


if __name__ == '__main__':
    # Test platform detection
    print("Platform Info:")
    for key, value in get_platform_info().items():
        print(f"  {key}: {value}")
