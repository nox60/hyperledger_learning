CouchDB uses Erlang-native clustering functionality to achieve a clustered installation. Erlang uses TCP port 4369 (EPMD) to find other nodes, so all servers must be able to speak to each other on this port. In an Erlang cluster, all nodes are connected to all other nodes, in a mesh network configuration.

# First, get two UUIDs to use later on. Be sure to use the SAME UUIDs on all nodes.
curl http://<server-IP|FQDN>:5984/_uuids?count=2

# CouchDB will respond with something like:
#   {"uuids":["60c9e8234dfba3e2fdab04bf92001142","60c9e8234dfba3e2fdab04bf92001cc2"]}
# Copy the provided UUIDs into your clipboard or a text editor for later use.
# Use the first UUID as the cluster UUID.
# Use the second UUID as the cluster shared http secret.

# Create the admin user and password:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/admins/admin -d '"password"'

# Now, bind the clustered interface to all IP addresses availble on this machine
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'

# If not using the setup wizard / API endpoint, the following 2 steps are required:
# Set the UUID of the node to the first UUID you previously obtained:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/couchdb/uuid -d '"FIRST-UUID-GOES-HERE"'

# Finally, set the shared http secret for cookie creation to the second UUID:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/couch_httpd_auth/secret -d '"SECOND-UUID-GOES-HERE"'