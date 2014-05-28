---
format: pml-0.1
triple: patmos-unknown-unknown-elf
machine-configuration:
  memories:
    - name: "main"
      size: 67108864
      transfer-size: 16
      read-latency: 4
      read-transfer-time: 1
      write-latency: 2
      write-transfer-time: 1
    - name: "local"
      size: 67108864
      transfer-size: 4
      read-latency: 0
      read-transfer-time: 0
      write-latency: 0
      write-transfer-time: 0
  caches:
    - name: "method-cache"
      block-size: 16
      associativity: 8
      size: 2048
      policy: "fifo"
      type: "method-cache"
    - name: "stack-cache"
      type: "stack-cache"
      policy: "block"
      block-size: 4
      size: 1024
  memory-areas:
    - name: "code"
      type: "code"
      memory: "main"
      cache: "method-cache"
      address-range:
        min: 0
        max: 0xFFFFFFFF
    - name: "data"
      type: "data"
      memory: "local"
      address-range:
        min: 0
        max: 0xFFFFFFFF


