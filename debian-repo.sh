#!/bin/bash

# Define repository directory
REPO_DIR="/var/www/html/debian-repo"

# Define default GPG key ID
DEFAULT_KEYID="your-default-key-id-here"

# Define Option Display the help menu
# Flag: -h, --help
function usage {
  local ow=20
  local dw=80
  printf "Usage: %s [options]\n\n" "$0"
  echo ""
  echo -e '
                  /$$$$$$$   /$$$$$$         /$$$$$$              /$$                                                
      .+------+  | $$__  $$ /$$__  $$       /$$__  $$            | $$                                                      .+------+  
    .` |    .`|  | $$  \ $$|__/  \ $$      | $$  \__/  /$$$$$$  /$$$$$$    /$$$$$$  /$$  /$$  /$$  /$$$$$$  /$$   /$$    .` |    .`|  
   +---+--+`  |  | $$$$$$$/  /$$$$$$/      | $$ /$$$$ |____  $$|_  $$_/   /$$__  $$| $$ | $$ | $$ |____  $$| $$  | $$   +---+--+`  |  
   |   |  |   |  | $$__  $$ /$$____/       | $$|_  $$  /$$$$$$$  | $$    | $$$$$$$$| $$ | $$ | $$  /$$$$$$$| $$  | $$   |   |  |   |  
   |  .+--+---+  | $$  \ $$| $$            | $$  \ $$ /$$__  $$  | $$ /$$| $$_____/| $$ | $$ | $$ /$$__  $$| $$  | $$   |  .+--+---+  
   |.`    | .`   | $$  | $$| $$$$$$$$      |  $$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$$|  $$$$$/$$$$/|  $$$$$$$|  $$$$$$$   |.`    | .`   
   +------+`     |__/  |__/|________/       \______/  \_______/   \___/   \_______/ \_____/\___/  \_______/ \____  $$   +------+`     
                                                                                                            /$$  | $$
                                                                                                           |  $$$$$$/
                                                                                                            \______/ 
'
  printf "%-${ow}s%-${dw}s%s\n" "Flag" "Description"
  printf "%-${ow}s%-${dw}s%s\n" "-------------" "----------------------"
  while read -r line; do
    if [[ $line == "# Define Option"* ]]; then
      desc=$(echo "$line" | sed 's/# Define Option //')
    fi

    if [[ $line == "# Flag:"* ]]; then
      flag=$(echo "$line" | sed 's/# Flag: //')
      printf "%-${ow}s%-${dw}s\n" "${flag%*}" "${desc}"
    fi
  done <"$0"
}

# Define Option Creates a Debian Package Repository
# Flag: -c, --create
function create_repo {
  # Create repository directory structure
  mkdir -p "$REPO_DIR"/{,dists/myrepo/main/binary-amd64}

  # Initialize Packages file
  touch "$REPO_DIR"/dists/myrepo/main/binary-amd64/Packages

  # Regenerate Packages and Release files
  cd "$REPO_DIR"/ || exit
  dpkg-scanpackages . /dev/null | gzip -9c >"$REPO_DIR"/dists/myrepo/main/binary-amd64/Packages.gz
  cd "$REPO_DIR"/dists/myrepo/main || exit
  apt-ftparchive release . >Release
  gpg --default-key "$KEYID" -abs -o Release.gpg Release

  echo "New repository created in $REPO_DIR"
}

# Define Option to update existing repository
# Flag: -u, --update
function update_repo {
  # Regenerate Packages and Release files
  cd "$REPO_DIR"/ || exit
  dpkg-scanpackages . /dev/null | gzip -9c >"$REPO_DIR"/dists/myrepo/main/binary-amd64/Packages.gz
  cd "$REPO_DIR"/dists/myrepo/main || exit
  apt-ftparchive release . >Release
  gpg --default-key "$KEYID" -abs -o Release.gpg Release

  echo "Repository updated in $REPO_DIR"
}

# Define Option Sign package files with GPG key
# Parameters:
#   Package file paths
# Flag: -s, --sign
function sign_packages {
  for package in "$@"; do
    gpg --default-key "$KEYID" -abs -o "$package.sig" "$package"
  done
  echo "Packages signed with GPG key $KEYID"
}

# Define Option Verify the integrity of a Debian package and its signature key
# Parameters:
#   Package file path
#   Keyserver URL
#   Key ID
# Flag: -v, --verify
function verify_package {
  PACKAGE="$1"
  KEYSERVER="$2"
  KEYID="$3"

  # Verify the package's signature
  if ! dpkg-sig --verify "${PACKAGE}" >/dev/null 2>&1; then
    echo "Error: Package signature verification failed"
    return 1
  fi

  # Verify the key used to sign the package
  if ! gpg --keyserver "${KEYSERVER}" --recv-keys "${KEYID}" >/dev/null 2>&1; then
    echo "Error: Failed to retrieve key from keyserver"
    return 1
  fi

  if ! dpkg-sig --verify "${PACKAGE}" "${KEYID}" >/dev/null 2>&1; then
    echo "Error: Package key verification failed"
    return 1
  fi

  echo "Package verification succeeded"
  return 0
}

# Define Option to get options from command line
function get_ops {
  flag="$1"
  while read -r line; do
    if [[ $line == "# Flag:"* ]]; then
      args=$(echo "$line" | cut -d' ' -f3-)
      for arg in $(echo "$args" | tr ',' ' '); do
        if [[ $arg == "$flag" ]]; then

          func=$(sed -n "/^function/{s/function \(.*\)/\1/;p;q;}" $0 | awk '{print $1}')

          "$func"

          return 0
        fi
      done
    fi
  done <"$0"
  usage
}

# Define Option Create a test Package to try our your new repository
# Parameters:
#   Package file paths
# Flag: -r, --reset
function create_test_package() {
  # Create temporary directory
  TMP_DIR=$(mktemp -d)

  # Create Debian package files
  cd $TMP_DIR
  mkdir -p "${PACKAGE_NAME}/DEBIAN" "${PACKAGE_NAME}/usr/bin"
  echo "#!/bin/bash" >"${PACKAGE_NAME}/usr/bin/myprogram"
  echo "echo 'Hello, world!'" >>"${PACKAGE_NAME}/usr/bin/myprogram"
  chmod +x ${PACKAGE_NAME}/usr/bin/myprogram
  echo "Package: ${PACKAGE_NAME}" >"${PACKAGE_NAME}/DEBIAN/control"
  echo "Version: 1.0" >>"${PACKAGE_NAME}/DEBIAN/control"
  echo "Architecture: amd64" >>"${PACKAGE_NAME}/DEBIAN/control"
  echo "Maintainer: John Doe <johndoe@example.com>" >>"${PACKAGE_NAME}/DEBIAN/control"
  echo "Description: A test package" >>"${PACKAGE_NAME}/DEBIAN/control"

  # Build Debian package
  dpkg-deb --build "${PACKAGE_NAME}"
  mv "${PACKAGE_NAME}".deb "$REPO_DIR/${PACKAGE_NAME}s"

  # Clean up
  rm -rf $TMP_DIR

  echo "Test package created in $REPO_DIR/${PACKAGE_NAME}s"
}

# Define Option You can call this option whenever you need to reset the apt repository.
# Parameters:
#   Package file paths
# Flag: -r, --reset
reset_apt_repository() {
  # check if the repository file exists
  if ls /etc/apt/sources.list.d/* >/dev/null 2>&1; then
    # backup the repository file
    sudo mv /etc/apt/sources.list.d/* ~/
  fi

  # update the package cache
  sudo apt-get update

  # upgrade the packages
  sudo apt-get upgrade
}

function main {
  get_ops "$@"
}

main "$@"
