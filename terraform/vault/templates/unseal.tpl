vault:
  config:
    seal:
      gcpckms:
        project: ${project}
        region: ${region}
        key_ring: ${key_ring}
        crypto_key: ${crypto_key}