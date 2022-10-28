disable_mlock = true
ui            = true
api_addr      = "https://10.1.42.101:8200"
cluster_addr  = "https://10.1.42.101:8201"

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/vault/certs/server-cert.pem"
  tls_key_file       = "/vault/certs/server-key.pem"
  tls_client_ca_file = "/vault/certs/vaultini-ca.pem"
}

storage "raft" {
  path = "/vault/data"
  node_id = "vaultini1"
}
