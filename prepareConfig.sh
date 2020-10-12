#!/usr/bin/env bash
set -ex

cat > spec.yaml << EOF
fabric:
  cas:
  - "ca1.org0.example.com"
  - "ca1.org1.example.com"
  peers: 
  - "peer1.org0.example.com"
  - "peer2.org0.example.com"
  - "peer1.org1.example.com"
  - "peer2.org1.example.com"
  orderers:
  - "orderer1.example.com"
  - "orderer2.example.com"
  - "orderer3.example.com"
  settings:
    ca:
      FABRIC_LOGGING_SPEC: INFO
    peer:
      FABRIC_LOGGING_SPEC: INFO
    orderer:
      FABRIC_LOGGING_SPEC: INFO
  goproxy: "https://goproxy.cn,direct"
  BatchTimeout: $1s
  MaxMessageCount: $2
  AbsoluteMaxBytes: $3 MB
  PreferredMaxBytes: $4 KB
  ### use go proxy when default go proxy is restricted in some of the regions.
  ### the default goproxy
  # goproxy: "https://proxy.golang.org,direct"
  ### the goproxy in China area
  # goproxy: "https://goproxy.cn,direct"
EOF