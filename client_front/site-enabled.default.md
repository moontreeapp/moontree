server {
    ...
    
    ### ADDED BY JORDAN ###
    # Add the listen directive for port 8080 SSL
    listen [::]:8080 ssl;
    listen 8080 ssl;

    # SSL certificate and key for port 8080
    ssl_certificate /etc/letsencrypt/live/www.moontree.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.moontree.com/privkey.pem;

    # Other SSL configurations for port 8080 (if needed)
    # ssl_protocols, ssl_ciphers, ssl_prefer_server_ciphers, etc.
    ### END JORDAN ###
}