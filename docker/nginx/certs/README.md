# TLS certificates

Put the certificate and its private key here (or in the folder set in
`SSL_CERT_DIR` in `.env`), named as `SSL_CERT_FILE` and `SSL_KEY_FILE`
(`fullchain.pem` and `privkey.pem` by default).

Not needed in behind-Apache mode, where Apache holds the certificates.

`*.pem`, `*.crt` and `*.key` files in this folder are ignored by git.
