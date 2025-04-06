# PentsT - Penetration Testing Toolkit Installer

![PentsT Banner](https://raw.githubusercontent.com/0xb0rn3/pentsT/main/assets/banner.png)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Version](https://img.shields.io/badge/version-0.1--alpha-orange)]()

## 🔍 Overview

PentsT is a powerful utility designed to streamline the installation and management of penetration testing tools. It provides a rich TUI (Text-based User Interface) for security professionals to easily select and install specific security tools or entire categories based on their needs.

Developed and maintained by [0xb0rn3](https://github.com/0xb0rn3), PentsT aims to simplify the process of setting up a comprehensive pentesting environment with minimal effort.

## ✨ Features

## Features
- **Full Toolkit Installation**: Install all available tools from Kali metapackages.
- **Category-Based Installation**: Select tools by category (e.g., Web Assessment, Wireless Tools).
- **Individual Tool Selection**: Choose specific tools to install, with search functionality.
- **Predefined Tool Sets**: Install curated sets of tools for common scenarios (e.g., Web App Testing, Network Penetration).
- **Custom List Installation**: Install tools from a user-provided list.

## 📋 Prerequisites

- Debian-based Linux distribution
- Python 3.6 or higher
- Internet connection
- Sudo/root access (only needed during installation of tools)

## 🚀 Quick Start

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/0xb0rn3/pentsT.git
   cd pentsT
   ```

2. Make the installer executable:
   ```bash
   chmod +x run
   ```

3. Run the installer script:
   ```bash
   ./run
   ```

4. The script will create the necessary directories and configurations.
   When prompted, you'll need to provide sudo privileges to install dependencies:

5. After setup completes, the core Python script will automatically run to begin the tool installation process.

This will launch the interactive interface where you can select and install your desired pentesting tools.

## 🛠️ Tool Categories

PentsT organizes tools into the following categories:

- **Top Tools**: Most commonly used pentesting tools
- **Web Assessment**: Tools for web application security testing
- **Wireless Tools**: WiFi, Bluetooth, and RF security tools
- **Forensics Tools**: Digital forensics and incident response tools
- **Exploitation**: Frameworks and tools for vulnerability exploitation
- **Information Gathering**: Reconnaissance and OSINT tools
- **Password Tools**: Cracking, brute-forcing, and credential assessment
- **Reverse Engineering**: Disassemblers, debuggers, and code analysis tools
- **Sniffing & Spoofing**: Network traffic analysis and manipulation
- **Vulnerability Analysis**: Scanners and assessment tools

## 📊 System Requirements

For optimal performance, the following specifications are recommended:

- **CPU**: Multi-core processor (4+ cores recommended)
- **RAM**: 8GB minimum (16GB+ recommended)
- **Storage**: At least 50GB of free disk space
- **Network**: Stable internet connection

## 📋 Execution Flow

PentsT consists of two main scripts:

1. **`run`**: Initial setup script that:
   - Creates necessary directories
   - Prepares configuration files
   - Generates the setup script
   - Does NOT require sudo privileges

2. **`core`**: The main Python script that:
   - Provides the interactive TUI
   - Handles repository setup
   - Manages tool installation
   - Requires sudo privileges to install system packages

The workflow is designed to separate the setup process from the actual tool installation for better security practices.

## 🔧 Configuration

PentsT stores its configuration and logs in the following locations:

- **Main Directory**: `~/pentsT/`
- **Log Files**: `~/pentsT/logs/`
- **Configuration**: `~/pentsT/configs/`
- **Utilities**: `~/pentsT/utils/`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


## ⚠️ Disclaimer

This tool is provided for educational and professional security testing purposes only. Users are responsible for complying with applicable laws and regulations. The author assumes no liability for misuse or damage caused by this tool.

## 📞 Contact

- **Developer**: [0xb0rn3](https://github.com/0xb0rn3)
- **Project Repository**: [https://github.com/0xb0rn3/pentsT](https://github.com/0xb0rn3/pentsT)
- **Issues**: [https://github.com/0xb0rn3/pentsT/issues](https://github.com/0xb0rn3/pentsT/issues)

---

<p align="center">Made with ☕ by <a href="https://github.com/0xb0rn3">0xb0rn3</a></p>
