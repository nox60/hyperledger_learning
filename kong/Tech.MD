konga首先创建connection，比如：

name: local
url: http://172.19.0.4:8001


request -> router -> service

router n:1 service

target 职能是进行负载均衡，其是upstream进行负载均衡的终端。

upstream n:1 target

service 和 upstream ：1 对 1 或 1 对 0 （service 也可以直接指向具体的 target，相当于不做负载均衡）

service 和 route：1 对 n

Route > Service > Upstream > target

请求链

