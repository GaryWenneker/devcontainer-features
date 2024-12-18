#!/bin/sh

set -e
set -u

echo "Activating feature 'iO'"

GREETING=${GREETING:-undefined}
echo "The provided greeting is: $GREETING"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

cat > /usr/local/bin/gary \
<< EOF
#!/bin/sh
RED='\033[0;91m'
NC='\033[0m' # No Color
echo "\${RED}iO!\${NC}"
EOF

chmod +x /usr/local/bin/gary


if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y git
elif command -v yum >/dev/null 2>&1; then
    yum install -y git
else
    echo "Cannot find supported package manager"
    exit 1
fi

TMP_DIR=/tmp/symbiotic

mkdir --parents $TMP_DIR
pushd $TMP_DIR

git clone --depth 1 https://gitlab.hosted-tools.com/netherlands/symbiotic.git
cp scripts/onboarding/ssh-setup.sh /usr/local/bin/

chmod +x /usr/local/bin//ssh-setup.sh

popd
rm -rf $TMP_DIR

echo "Feature 'iO' activated"