request -> router -> service

router n:1 service

target 职能是进行负载均衡，其是upstream进行负载均衡的终端。

upstream n:1 target

Route > Service > Upstream > target

请求链