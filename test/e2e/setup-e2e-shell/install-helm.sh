#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

BASE_DIR=$1
BIN_DIR=$2
HELMVERSION=${HELMVERSION:-'helm-v3.0.0'}

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture
case $ARCH in
  x86_64)
    ARCH="amd64"
    ;;
  arm64|aarch64)
    ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Map OS
case $OS in
  linux)
    PLATFORM="linux"
    ;;
  darwin)
    PLATFORM="darwin"
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# Check if helm exists and is executable
NEED_INSTALL=true
if [ -f "$BIN_DIR/helm" ]; then
  # Check if the binary is executable on this platform
  if file "$BIN_DIR/helm" | grep -q "$PLATFORM\|Mach-O"; then
    # Try to execute it to verify it works
    if "$BIN_DIR/helm" version &> /dev/null; then
      NEED_INSTALL=false
    fi
  fi
  # If binary exists but is wrong platform or not executable, remove it
  if [ "$NEED_INSTALL" = true ]; then
    rm -f "$BIN_DIR/helm"
  fi
fi

# Also check system helm
if [ "$NEED_INSTALL" = true ] && command -v helm &> /dev/null; then
  if helm version &> /dev/null; then
    NEED_INSTALL=false
  fi
fi

if [ "$NEED_INSTALL" = true ]; then
  mkdir -p $BASE_DIR/helm && cd $BASE_DIR/helm
  curl -sSL https://get.helm.sh/${HELMVERSION}-${PLATFORM}-${ARCH}.tar.gz | tar xz -C $BIN_DIR --strip-components=1 ${PLATFORM}-${ARCH}/helm
  chmod +x $BIN_DIR/helm
fi