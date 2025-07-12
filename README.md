# 📂 file-activity-monitor

A simple real-time file activity monitor built in **Bash**, using **inotifywait**.  
It watches a folder and logs any changes — such as file creation, deletion, modification, or movement — in real time.

---

## 🔧 Features

- ✅ Real-time file and folder activity logging
- 📌 Start and stop monitoring folders with ease
- 📜 Stores logs for each folder being watched
- 📋 List all currently monitored folders
- 🔍 Check if a folder is being monitored (`status`)
- 🆘 Built-in `--help` and `--version` options

---

## 🧠 What It Taught Me

- Linux CLI scripting in Bash
- Using `inotifywait` for real-time monitoring
- Managing background processes (PIDs)
- Logging and file permissions
- Building a clean CLI experience

---

## 🚀 Usage

Before running the script, make it executable:
```bash
chmod +x monitor.sh
```

```bash
./monitor.sh start /path/to/folder     # Start monitoring
./monitor.sh stop /path/to/folder      # Stop monitoring
./monitor.sh status /path/to/folder    # Check if folder is being monitored
./monitor.sh list                      # List all monitored folders
./monitor.sh --help                    # Show help message
./monitor.sh --version                 # Show version
```

Logs are saved under:
`~/.monitor_logs/`

PID files are stored securely in:
`~/.monitor_pids/`
