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

if ! command -v istioctl &> /dev/null; then
  mkdir -p $BASE_DIR/istioctl && cd $BASE_DIR/istioctl
  curl -L https://istio.io/downloadIstio | sh -
  
  # Find the downloaded istio directory (e.g., istio-1.28.2)
  ISTIO_DIR=$(ls -d istio-* 2>/dev/null | head -1)
  
  if [ -z "$ISTIO_DIR" ]; then
    echo "ERROR: Failed to find downloaded Istio directory"
    exit 1
  fi
  
  if [ ! -f "$ISTIO_DIR/bin/istioctl" ]; then
    echo "ERROR: istioctl binary not found in $ISTIO_DIR/bin/"
    exit 1
  fi
  
  cp "$ISTIO_DIR/bin/istioctl" "$BIN_DIR/istioctl"
  chmod +x "$BIN_DIR/istioctl"
fi