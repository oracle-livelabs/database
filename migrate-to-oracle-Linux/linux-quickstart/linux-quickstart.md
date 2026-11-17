# Linux Command-Line Quickstart (Optional)

## Introduction

The migration labs use Linux commands to inspect the operating system, manage packages, check services, and verify application health. This optional lab builds the command-line skills you will use to understand those checks and interpret their results.

Working on the RHEL VM created in Lab 1, you will navigate directories, manage practice files, search text, and run a small script. You will also inspect permissions, processes, storage, networking, and Apache, then combine several commands into a system-readiness report. Each exercise explains what the commands do and what to look for in their output.

Practice files stay in your home directory, and the system and Apache checks are read-only. If you are already comfortable with these Linux tasks, continue directly from Lab 1 to Lab 3.

### Objectives

In this lab, you will:

- Navigate directories and manage practice files.
- Read, search, and summarize text.
- Inspect permissions, processes, storage, networking, services, and installed packages.
- Produce a system-readiness report.

Estimated Time: 60 minutes

### Prerequisites

Complete Lab 1, including the connection and verification checks in Task 7. Connect as `cloud-user` to the destination VM. Apache must already serve `MIGRATION_WORKLOAD_OK`. No Red Hat registration or additional packages are needed.

## Task 1: Identify your system and use command help

Identify your user account, VM, operating system, and running kernel, then practice finding command help. These checks help you confirm that you are connected to the workshop VM and recognize the OS and kernel changes made in Labs 4 and 6.

1. Inspect your identity and environment:

    ```bash
    <copy>
    whoami
    id
    hostname
    pwd
    cat /etc/os-release
    uname -r
    </copy>
    ```

    Confirm `cloud-user`, RHEL 9.8, and the destination hostname. `pwd` prints your current directory; `uname -r` prints the running kernel.

1. Explore help and shell shortcuts:

    ```bash
    <copy>
    ls --help | head -15
    type cd
    type ls
    </copy>
    ```

    A command normally follows `command options arguments`. Paths beginning with `/` are absolute; `.` is the current directory, `..` its parent, and `~` your home. Quote paths containing spaces. Press Tab to complete names, Up Arrow to recall a command, and Ctrl+C to interrupt a foreground command. These keys are not text to paste.

## Task 2: Navigate and manage practice files

Practice creating directories and files, copying and renaming them, and comparing their contents. You will use directory navigation to work with the migration script in Lab 3 and locate reports in Lab 4; file comparison also helps you understand the before-and-after checks in Lab 5.

1. Create a workspace and an example file:

    ```bash
    <copy>
    mkdir -p "$HOME/linux-quickstart/reports"
    cd "$HOME/linux-quickstart"
    pwd
    touch notes.txt
    printf "Linux practice\n" > notes.txt
    ls -la
    </copy>
    ```

    `mkdir -p` creates missing directories. `touch` creates an empty file. `>` writes a file and replaces its old contents.

1. Copy, rename, append, and compare:

    ```bash
    <copy>
    cp notes.txt notes-copy.txt
    mv notes-copy.txt notes-renamed.txt
    printf "Second line\n" >> notes-renamed.txt
    cat notes-renamed.txt
    diff -u notes.txt notes-renamed.txt
    </copy>
    ```

    `>>` appends instead of replacing. The diff should show the added line and return status 1 because the files differ; that is expected.

1. Remove only the disposable copy and practice relative navigation:

    ```bash
    <copy>
    rm -i notes-renamed.txt
    cd reports
    pwd
    cd ..
    find . -maxdepth 2 -type f
    </copy>
    ```

    Answer `y` only for `notes-renamed.txt`. `rm` deletes rather than moving a file to a desktop recycle bin. Your original `notes.txt` must remain.

## Task 3: Read and search text

Use a sample log to practice reading files, finding messages, and combining commands with pipes. These skills help you examine migration output and logs and understand the commands that search for the application marker throughout the workshop.

1. Create a small sample log:

    ```bash
    <copy>
    cd "$HOME/linux-quickstart"
    cat > sample.log <<'EOF'
    INFO web started
    ERROR request failed
    INFO request completed
    ERROR request failed
    WARN disk threshold reached
    EOF
    cat sample.log
    head -2 sample.log
    tail -2 sample.log
    </copy>
    ```

1. Open the file with a pager:

    ```bash
    <copy>
    less sample.log
    </copy>
    ```

    Press `/ERROR` and Enter to search, `n` for the next match, and `q` to quit.

1. Search and summarize with pipes:

    ```bash
    <copy>
    grep '^ERROR' sample.log > reports/errors.txt
    wc -l reports/errors.txt
    sort sample.log | uniq -c
    cat reports/errors.txt
    </copy>
    ```

    A pipe sends one command's output to another command. The errors report must contain two lines. `grep` normally returns 1 when it finds no match; use `echo $?` immediately after a command to inspect its exit status.

## Task 4: Understand permissions and sudo

Create a small script and see how file permissions affect its execution. This prepares you to make the migration script executable in Lab 3 and understand why installation and system changes in later labs require sudo.

1. Create a small script as your normal user:

    ```bash
    <copy>
    cd "$HOME/linux-quickstart"
    cat > hello.sh <<'EOF'
    #!/usr/bin/env bash
    printf 'Hello from %s on %s\n' "$(whoami)" "$(hostname)"
    EOF
    chmod 0644 hello.sh
    ls -l hello.sh
    bash hello.sh
    </copy>
    ```

    `ls -l` shows owner, group, and permissions. Mode `0644` means the owner can read/write and other users can read; it does not grant execution. Running `bash hello.sh` explicitly asks Bash to read it.

1. Add the execute permission for the owner:

    ```bash
    <copy>
    chmod u+x hello.sh
    ls -l hello.sh
    ./hello.sh
    sudo -l
    </copy>
    ```

    Confirm that `./hello.sh` prints your username and hostname. `sudo -l` lists permitted administrative commands. Use `sudo` when the task requires administrative access; files in this workspace should remain owned by your normal user.

## Task 5: Inspect system and network health

Inspect disk space, memory, processes, network addresses, routes, and listening ports, then check the Apache application. These commands introduce the resource checks used before migration and help you investigate connectivity or application problems at later checkpoints.

1. Inspect storage, memory, and processes:

    ```bash
    <copy>
    df -h /
    du -sh "$HOME/linux-quickstart"
    free -h
    ps -eo pid,user,comm --sort=comm | head -20
    </copy>
    ```

    `df` reports filesystem capacity; `du` reports file/directory usage; `free` summarizes memory. A process ID (PID) identifies a running process.

1. Inspect addresses, routes, listeners, and the application:

    ```bash
    <copy>
    ip -brief address
    ip route show
    sudo ss -lntp
    curl --fail --silent http://127.0.0.1/ | grep MIGRATION_WORKLOAD_OK
    </copy>
    ```

    Find the interface address, default route, and TCP listener on port 80. `127.0.0.1` addresses this VM itself. The workload marker must appear.

## Task 6: Inspect services, logs, and installed packages

Check whether Apache starts at boot and is running, read its recent logs, and query installed packages. You will use service and package checks to verify the migrated system in Lab 4 and confirm application health after patching, changing kernels, and applying an OSMH update.

1. Check Apache without changing its state:

    ```bash
    <copy>
    systemctl is-enabled httpd
    systemctl is-active httpd
    systemctl status httpd --no-pager
    sudo journalctl -u httpd -n 10 --no-pager
    rpm -q httpd curl firewalld
    </copy>
    ```

    Expect Apache to be `enabled` and `active`. An enabled service is configured to start at boot; an active service is running now. RPM queries the local package database. Oracle repositories are inspected after conversion in Lab 4.

## Task 7: Create and verify the readiness report

Combine commands into a saved system summary and verify the practice files created in this lab. This brings together the output redirection and system checks used in the workshop; Lab 3 performs the migration-readiness assessment, while this report is practice in collecting and reading command output.

1. Write `reports/readiness.txt` containing the hostname, OS name/version, kernel, root disk usage, Apache startup/running status, and the workload marker:

    ```bash
    <copy>
    cd "$HOME/linux-quickstart"
    {
      hostname
      grep -E '^(NAME|VERSION_ID)=' /etc/os-release
      uname -r
      df -h /
      systemctl is-enabled httpd
      systemctl is-active httpd
      curl --fail --silent http://127.0.0.1/ | grep MIGRATION_WORKLOAD_OK
    } > reports/readiness.txt
    cat reports/readiness.txt
    </copy>
    ```

1. Using the commands from this lab, explain one absolute path, one relative path, and the difference between `>` and `>>`.

1. Verify the lab outputs:

    ```bash
    <copy>
    cd "$HOME/linux-quickstart"
    test -f notes.txt && echo 'PASS: original practice file exists'
    test "$(wc -l < reports/errors.txt)" -eq 2 && echo 'PASS: two error lines'
    test -x hello.sh && echo 'PASS: practice script is executable'
    grep MIGRATION_WORKLOAD_OK reports/readiness.txt
    systemctl is-active httpd
    </copy>
    ```

    Complete only when the three PASS messages, workload marker, and `active` appear. If a workspace exercise fails, repeat that task without editing system files. Continue to Lab 3 to assess migration readiness and run the migration dry run.

You may now **proceed to the next lab**.

## Learn More

- [GNU Bash manual](https://www.gnu.org/software/bash/manual/bash.html)
- [GNU Coreutils manual](https://www.gnu.org/software/coreutils/manual/)
- [Oracle systemd guide](https://docs.oracle.com/en/operating-systems/oracle-linux/9/systemd/OL9-SYSTEMD.pdf)

## Acknowledgements

- Perside Foster, Principal Solution Engineer, Oracle
- Rosario Spiezia, Principal Sales Consultant, Oracle
- Mitch Dsouza, Principal Presales Consultant, Oracle Cloud Infrastructure Software
- Nick Mader, Global Channel Enablement & Strategy Director, Open Source Solutions, Oracle
- Last Updated By/Date - Perside Foster, Nov 2026
