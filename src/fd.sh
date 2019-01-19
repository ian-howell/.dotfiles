set -x
echo "Installing fd"
wget https://github.com/sharkdp/fd/releases/download/v7.2.0/fd-musl_7.2.0_amd64.deb -O $ARTIFACTS_DIR/fd-musl_7.2.0_amd64.deb
sudo dpkg -i $ARTIFACTS_DIR/fd-musl_7.2.0_amd64.deb
set +x
