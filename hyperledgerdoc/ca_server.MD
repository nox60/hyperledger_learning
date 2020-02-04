Starting the server
Start the Fabric CA server as follows:

fabric-ca-server start -b <admin>:<adminpw>
If the server has not been previously initialized, it will initialize itself as it starts for the first time. 
During this initialization, the server will generate the ca-cert.pem and ca-key.pem files if they don’t yet exist and will also create a default configuration file if it does not exist. 
See the Initialize the Fabric CA server section.
如果server之前没有被初始化过，那么它第一次启动的时候就要初始化。在初始化过程中，服务器将会生成一对非对称密钥对（公钥和私钥）。

Unless the Fabric CA server is configured to use LDAP, it must be configured with at least one pre-registered bootstrap identity to enable you to register and enroll other identities. The -b option specifies the name and password for a bootstrap identity.
除非CA 服务用了LDAP来做身份认证，不然你必须通过-b参数给它初始化一个管理员账户（否则根本没办法使用啊）

To cause the Fabric CA server to listen on https rather than http, set tls.enabled to true.
如果将 tls.enabled 参数启用，CA服务就会启用https

SECURITY WARNING: The Fabric CA server should always be started with TLS enabled (tls.enabled set to true). 
Failure to do so leaves the server vulnerable to an attacker with access to network traffic.
安全提示: CA 服务器应该总是被设置为TLS方式。否则有很大的安全隐患。

To limit the number of times that the same secret (or password) can be used for enrollment, set the registry.maxenrollments in the configuration file to the appropriate value. If you set the value to 1, the Fabric CA server allows passwords to only be used once for a particular enrollment ID. If you set the value to -1, the Fabric CA server places no limit on the number of times that a secret can be reused for enrollment. The default value is -1. Setting the value to 0, the Fabric CA server will disable enrollment for all identities and registration of identities will not be allowed.

The Fabric CA server should now be listening on port 7054.

You may skip to the Fabric CA Client section if you do not want to configure the Fabric CA server to run in a cluster or to use LDAP.