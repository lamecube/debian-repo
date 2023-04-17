# 📦 Debian Repository Manager 📦

&emsp; Debian Repository Manager helps you manage Debian package repositories. You can use it to create a new repository or update an existing one. You can also sign packages with your GPG key and reset the apt repository.

## 🚀 Usage

### `-c`, `--create`:
 >&emsp;Creates a Debian Package Repository in the directory specified in the script. This option will create the directory structure, initialize the Packages file, and generate the Packages and Release files. For more information about Debian packaging, see the Debian Wiki.

### `-u`, `--update`:
 >&emsp;Updates an existing Debian Package Repository. This option will regenerate the Packages and Release files. For more information about Debian packaging, see the Debian Wiki.

### `-s`, `--sign`:
>&emsp;Sign package files with GPG key. This option takes one or more package file paths as arguments and signs them with your GPG key. For more information about GPG key management, see the Debian Wiki.

### `-r`, `--reset`:
 >&emsp;Reset apt repository. This option will backup the current repository files in your home directory, update the package cache, and upgrade the packages. For more information about apt, see the Debian Wiki.


## 🔑 GPG Key
>&emsp;By default, this script uses a default GPG key ID that you need to replace with your own GPG key ID. For more information about GPG key management, see the Debian Wiki.

## 💻 System Requirements
>&emsp;This script is designed to work on Debian-based systems. For more information about Debian, see the Debian Wiki.

## 📁 Repository Directory
>&emsp;This script assumes that the repository directory is set to `~/debian-repo`. You can change this directory by modifying the REPO_DIR variable in the script.
