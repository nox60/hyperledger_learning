# Policies

**Audience**: Architects, application and smart contract developers,
administrators

In this topic, we'll cover:

* [What is a policy](#what-is-a-policy)
* [Why are policies needed](#why-are-policies-needed)
* [How are policies implemented throughout Fabric](#how-are-policies-implemented-throughout-fabric)
* [Fabric policy domains](#fabric-policy-domains)
* [How do you write a policy in Fabric](#how-do-you-write-a-policy-in-fabric)
* [Fabric chaincode lifecycle](#fabric-chaincode-lifecyle)
* [Overriding policy definitions](#overriding-policy-definitions)

名词定义：

policy  策略
rule    规则

## What is a policy

At its most basic level, a policy is a set of rules that define the structure
for how decisions are made and specific outcomes are reached. To that end,
policies typically describe a **who** and a **what**, such as the access or
rights that an individual has over an **asset**. We can see that policies are
used throughout our daily lives to protect assets of value to us, from car
rentals, health, our homes, and many more.

策略是一组规则的集合，用来定义如何确定输出和延申的结构。

为了达到这个目标，策略一般被描述为“谁”和能做“什么”，比如个人是否具备解除资产的权利。
我们可以看到策略贯穿我们日常生活，用来保护财产和价值。从汽车租赁、健康、家庭和更多。

For example, an insurance policy defines the conditions, terms, limits, and
expiration under which an insurance payout will be made. The policy is
agreed to by the policy holder and the insurance company, and defines the rights
and responsibilities of each party.

比如，一个保险策略定义了条件，规则，限制以及过期时间。在以上条款之下才能确认一笔保险的赔付。
策略的确认需要通过策略的持有者（保险人）和保险公司，然后双方定义权利和责任。

Whereas an insurance policy is put in place for risk management, in Hyperledger
Fabric, policies are the mechanism for infrastructure management. Fabric policies
represent how members come to agreement on accepting or rejecting changes to the
network, a channel, or a smart contract. Policies are agreed to by the consortium
members when a network is originally configured, but they can also be modified
as the network evolves. For example, they describe the criteria for adding or
removing members from a channel, change how blocks are formed, or specify the
number of organizations required to endorse a smart contract. All of these
actions are described by a policy which defines who can perform the action.
Simply put, everything you want to do on a Fabric network is controlled by a
policy.

相比保险策略是用来保险风险控制的。在超级账本体系中，策略是一种机制，用来进行基础设施管理的。
在Fabric中的策略体现了成员们如何对网络、通道、智能合约中的一个改变接受或者拒绝。当区块链网络
最初配置的说话，联盟成员们就对策略达成了一直，但是网络的演进过程中，策略也能改变。比如，网络
成员们决定要增加或者移除通道成员，改变区块的组织结构，或者改变需要为智能合约背书的组织数量。
当我们在定义谁可以执行这些操作的时候，这些行为的定义都可以视为策略。简单的说，所有在Fabric网络
中的操作都可以被策略所控制。

## Why are policies needed
为什么我们需要策略

Policies are one of the things that make Hyperledger Fabric different from other
blockchains like Ethereum or Bitcoin. In those systems, transactions can be
generated and validated by any node in the network. The policies that govern the
network are fixed at any point in time and can only to be changed using the same
process that governs the code. Because Fabric is a permissioned blockchain whose
users are recognized by the underlying infrastructure, those users have the
ability to decide on the governance of the network before it is launched, and
change the governance of a running network.
因为策略的存在，使得超级账本区块链体系有别于其他区块链技术体系，比如以太坊和比特币。在
其他体系中，网络中的任何节点可以发起合理的交易，这样的策略模式使得监管这样的网络，

因为Fabric是基于可信智能合约的基础架构的，用户是基础架构所认知的？这些用户具备在网络启动
之前就确认管理网络的能力，并且改变管理一个运行中的网络?

Policies allow members to decide which organizations can access or update a Fabric
network, and provide the mechanism to enforce those decisions. Policies contain
the lists of organizations that have access to a given resource, such as a
user or system chaincode. They also specify how many organizations need to agree
on a proposal to update a resource, such as a channel or smart contracts. Once
they are written, policies evaluate the collection of signatures attached to
transactions and proposals and validate if the signatures fulfill the governance
agreed to by the network.

策略允许成员决定那个组织可以访问或者更改网络，同时提供强制这些决定的机制，策略包含了能够
访问资源的组织的列表，比如用户或者链代码。他们也指定了当一次资源更改的时候需要获得多少组
织的确定才会生效，比如通道或者智能合约。一旦这些被写入，策略会比较该交易提交者的显示的签
名，判断该提交是否满足监控网络的权限。

## How are policies implemented throughout Fabric

Policies are implemented at different levels of a Fabric network. Each policy
domain governs different aspects of how a network operates.

策略在Fabric网络中不同的层次实现，所有的策略领域控制了网络操作的不同方面。

![policies.policies](./FabricPolicyHierarchy-2.png) *A visual representation
of the Fabric policy hierarchy.*

虚拟的继承关系。

### System channel configuration
系统通道配置

Every network begins with an ordering **system channel**. There must be exactly
one ordering system channel for an ordering service, and it is the first channel
to be created. The system channel also contains the organizations who are the
members of the ordering service (ordering organizations) and those that are
on the networks to transact (consortium organizations).

所有的网络都是开始于一个有序的系统通道。这必须是一个确定的有序的系统通道，该系统通道将
用于通道排序服务，并将创建第一个通道。系统通道同时也包含了谁是orderer服务相关组织成员的
组织信息。


The policies in the ordering system channel configuration blocks govern the
consensus used by the ordering service and define how new blocks are created.
The system channel also governs which members of the consortium are allowed to
create new channels.
策略在排序系统通道的配置块中控制了共识，用于在排序服务定义新块的创建。系统通道同时也
管理联盟中的哪些成员能够创建新的通道。

### Application channel configuration
业务通道配置

Application _channels_ are used to provide a private communication mechanism
between organizations in the consortium.
业务通道是用于在联盟中组织之间提供私有连接机制的


The policies in an application channel govern the ability to add or remove
members from the channel. Application channels also govern which organizations
are required to approve a chaincode before the chaincode is defined and
committed to a channel using the Fabric chaincode lifecyle. When an application
channel is initially created, it inherits all the ordering service parameters
from the orderer system channel by default. However, those parameters (and the
policies governing them) can be customized in each channel.

这种策略在一个业务系统用于管理增加和移除通道成员的能力。业务通道同时也管理需要确认在链代码
定义和提交到通道之前

当一个业务通道初始化创建时，它从通道系统通道那里继承了所有的通道服务的参数。所以这些参数
以及这些策略信息可以在所有通道进行配置。

### Access control lists (ACLs)

Network administrators will be especially interested in the Fabric use of ACLs,
which provide the ability to configure access to resources by associating those
resources with existing policies. These "resources" could be functions on system
chaincode (e.g., "GetBlockByNumber" on the "qscc" system chaincode) or other
resources (e.g.,who can receive Block events). ACLs refer to policies
defined in an application channel configuraton and extends them to control
additional resources. The default set of Fabric ACLs is visible in the
`configtx.yaml` file under the `Application: &ApplicationDefaults` section but
they can and should be overridden in a production environment. The list of
resources named in `configtx.yaml` is the complete set of all internal resources
currently defined by Fabric.

网络管理员们将会尤为对Fabric的ACL感兴趣。ACL提供了

这些资源可以是 系统链代码提供的 功能函数，比如GetBlockByNumber这样的用来获取块数量的
功能函数； 或者其他资源，比如谁可以收到块事件。

ACL引用了 定义在业务通道配置上的 策略 已经扩展他们以控制更多资源。

这些默认的Fabric的ACL配置在 `configtx.yaml` 文件中的 `Application: &ApplicationDefaults` 部分
可见，但是他们在生产环境中将被覆盖。

在  `configtx.yaml`中的资源列表是当前Fabric定义的所有内部资源的完整集合。

In that file, ACLs are expressed using the following format:

```
# ACL policy for chaincode to chaincode invocation
peer/ChaincodeToChaincode: /Channel/Application/Readers
```

Where `peer/ChaincodeToChaincode` represents the resource being secured and
`/Channel/Application/Readers` refers to the policy which must be satisfied for
the associated transaction to be considered valid.

For a deeper dive into ACLS, refer to the topic in the Operations Guide on [ACLs](../access_control.html).

### Smart contract endorsement policies

Every smart contract inside a chaincode package has an endorsement policy that
specifies how many peers belonging to different channel members need to execute
and validate a transaction against a given smart contract in order for the
transaction to be considered valid. Hence, the endorsement policies define the
organizations (through their peers) who must “endorse” (i.e., approve of) the
execution of a proposal.

如果希望交易最终能被接受，所有的在链代码包中的智能合约都有一个背书策略，来确定需要多少
不同通道成员的peer节点来执行和验证特定智能合约交易的有效性。因此，背书策略定义了这些需要
为操作背书的组织。

### Modification policies

There is one last type of policy that is crucial to how policies work in Fabric,
the `Modification policy`. Modification policies specify the group of identities
required to sign (approve) any configuration _update_. It is the policy that
defines how the policy is updated. Thus, each channel configuration element
includes a reference to a policy which governs its modification.

至少有一种类型的策略会决定有多少策略在Fabric网络中起作用，这就是 `Modification policy`
`Modification policy`策略指定了在配置更新的时候，需要哪些角色组的登录。

这样的策略定义了策略是怎样被更新的。因此，所有的通道配置基础元素都包含了一个对其修改策略
的引用。

## The policy domains

While Fabric policies are flexible and can be configured to meet the needs of a
network, the policy structure naturally leads to a division between the domains
governed by either the Ordering Service organizations or the members of the
consortium. In the following diagram you can see how the default policies
implement control over the Fabric policy domains below.

当Fabric策略很灵活并且能够被配置来满足一个网络的需求时，这种策略结构自然导向了一种这样的
分隔：排序服务组织管控一部分，联盟成员管控另外一部分，通过下图你可以看到默认策略的实现控制
了Fabric策略领域

![policies.policies](./FabricPolicyHierarchy-4.png) *A more detailed look at the
policy domains governed by the Orderer organizations and consortium organizations.*

A fully functional Fabric network can feature many organizations with different
responsibilities. The domains provide the ability to extend different privileges
and roles to different organizations by allowing the founders of the ordering
service the ability to establish the initial rules and membership of the
consortium. They also allow the organizations that join the consortium to create
private application channels, govern their own business logic, and restrict
access to the data that is put on the network.

一个功能完备的Fabric网络能够实现负责不同业务的多个组织。通过允许排序服务的创造者创建初始规则
和联盟会员关系，他们也允许组织加入联盟创造私有业务网络，控制他们自己的业务模型，控制访问
数据，
这种模式提供了给不同的组织，扩展不同权限和
角色的能力。

The system channel configuration and a portion of each application channel
configuration provides the ordering organizations control over which organizations
are members of the consortium, how blocks are delivered to channels, and the
consensus mechanism used by the nodes of the ordering service.

系统通道的配置和部分业务通道的的配置提供了对，排序组织控制联盟中其他组织和成员的能力，

The system channel configuration provides members of the consortium the ability
to create channels. Application channels and ACLs are the mechanism that
consortium organizations use to add or remove members from a channel and restrict
access to data and smart contracts on a channel.

## How do you write a policy in Fabric

If you want to change anything in Fabric, the policy associated with the resource
describes **who** needs to approve it, either with an explicit sign off from
individuals, or an implicit sign off by a group. In the insurance domain, an
explicit sign off could be a single member of the homeowners insurance agents
group. And an implicit sign off would be analogous to requiring approval from a
majority of the managerial members of the homeowners insurance group. This is
particularly useful because the members of that group can change over time
without requiring that the policy be updated. In Hyperledger Fabric, explicit
sign offs in policies are expressed using the `Signature` syntax and implicit
sign offs use the `ImplicitMeta` syntax.

### Signature policies

`Signature` policies define specific types of users who must sign in order for a
policy to be satisfied such as `Org1.Peer OR Org2.Peer`. These policies are
considered the most versatile because they allow for the construction of
extremely specific rules like: “An admin of org A and 2 other admins, or 5 of 6
organization admins”. The syntax supports arbitrary combinations of `AND`, `OR`
and `NOutOf`. For example, a policy can be easily expressed by using `AND
(Org1, Org2)` which means that a signature from at least one member in Org1 AND
one member in Org2 is required for the policy to be satisfied.

### ImplicitMeta policies

`ImplicitMeta` policies are only valid in the context of channel configuration
which is based on a tiered hierarchy of policies in a configuration tree. ImplicitMeta
policies aggregate the result of policies deeper in the configuration tree that
are ultimately defined by Signature policies. They are `Implicit` because they
are constructed implicitly based on the current organizations in the
channel configuration, and they are `Meta` because their evaluation is not
against specific MSP principals, but rather against other sub-policies below
them in the configuration tree.

The following diagram illustrates the tiered policy structure for an application
channel and shows how the `ImplicitMeta` channel configuration admins policy,
named `/Channel/Admins`, is resolved when the sub-policies named `Admins` below it
in the configuration hierarchy are satisfied where each check mark represents that
the conditions of the sub-policy were satisfied.

![policies.policies](./FabricPolicyHierarchy-6.png)

As you can see in the diagram above, `ImplicitMeta` policies, Type = 3, use a
different syntax, `"<ANY|ALL|MAJORITY> <SubPolicyName>"`, for example:
```
`MAJORITY sub policy: Admins`
```
The diagram shows a sub-policy `Admins`, which refers to all the `Admins` policy
below it in the configuration tree. You can create your own sub-policies
and name them whatever you want and then define them in each of your
organizations.

As mentioned above, a key benefit of an `ImplicitMeta` policy such as `MAJORITY
Admins` is that when you add a new admin organization to the channel, you do not
have to update the channel policy. Therefore `ImplicitMeta` policies are
considered to be more flexible as the consortium members change. The consortium
on the orderer can change as new members are added or an existing member leaves
with the consortium members agreeing to the changes, but no policy updates are
required. Recall that `ImplicitMeta` policies ultimately resolve the
`Signature` sub-policies underneath them in the configuration tree as the
diagram shows.

如上面所说，隐式元数据策略模式的一个重要优点是，当你增加一个新的管理员组织到通道里，
你不用更新通道策略，因为隐式元数据策略已经比较灵活，因为其一开始就考虑到了联盟成员
的变更，orderer里的联盟能够做出这样的改变并同意：增加新成员或者已经存在的成员离开。

但不需要对策略进行任何修改，回忆一下隐式元数据策略解决的问题是：声明式策略的子策略

You can also define an application level implicit policy to operate across
organizations, in a channel for example, and either require that ANY of them
are satisfied, that ALL are satisfied, or that a MAJORITY are satisfied. This
format lends itself to much better, more natural defaults, so that each
organization can decide what it means for a valid endorsement.

用户也可以定义一个应用级别的隐式策略来操作组织。以一个通道作为例子，ANY代表任何一个
即满足，ALL代表满足，或者MAJORITY代表满足。这样的格式导致了其更好，更加自然。因此所有
组织可以决定什么是一个合理的背书。

Further granularity and control can be achieved if you include [`NodeOUs`](msp.html#organizational-units) in your
organization definition. Organization Units (OUs) are defined in the Fabric CA
client configuration file and can be associated with an identity when it is
created. In Fabric, `NodeOUs` provide a way to classify identities in a digital
certificate hierarchy. For instance, an organization having specific `NodeOUs`
enabled could require that a 'peer' sign for it to be a valid endorsement,
whereas an organization without any might simply require that any member can
sign.



## An example: channel configuration policy

Understanding policies begins with examining the `configtx.yaml` where the
channel policies are defined. We can use the `configtx.yaml` file in the BYFN
(first-network) tutorial to see examples of both policy syntax types. Navigate to the [fabric-samples/first-network](https://github.com/hyperledger/fabric-samples/blob/master/first-network/configtx.yaml)
directory and examine the configtx.yaml file for BYFN.

The first section of the file defines the Organizations of the network. Inside each
organization definition are the default policies for that organization, `Readers, Writers,
Admins, and Endorsement`, although you can name your policies anything you want.
Each policy has a `Type` which describes how the policy is expressed (`Signature`
or `ImplicitMeta`) and a `Rule`.

The BYFN example below shows the `Org1` organization definition in the system
channel, where the policy `Type` is `Signature` and the Endorsement policy rule
is defined as `"OR('Org1MSP.peer')"` which  means that peer that is a member of
`Org1MSP` is required to sign. It is these Signature policies that become the
sub-policies that the ImplicitMeta policies point to.  

<details>
  <summary>
    **Click here to see an example of an organization defined with signature policies**
  </summary>

```
 - &Org1
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: Org1MSP

        # ID to load the MSP definition as
        ID: Org1MSP

        MSPDir: crypto-config/peerOrganizations/org1.example.com/msp

        # Policies defines the set of policies at this level of the config tree
        # For organization policies, their canonical path is usually
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
            Writers:
                Type: Signature
                Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org1MSP.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('Org1MSP.peer')"
```
</details>

The next example shows the `ImplicitMeta` policy type used in the `Orderer`
section of the `configtx.yaml` file which defines the default
behavior of the orderer and also contains the associated policies `Readers`,
`Writers`, and `Admins`. Again, these ImplicitMeta policies are evaluated based
on their underlying Signature sub-policies which we saw in the snippet above.

<details>
  <summary>
    **Click here to see an example of ImplicitMeta policies**
  </summary>
```

################################################################################
#
#   SECTION: Orderer
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for orderer related parameters
#
################################################################################
Orderer: &OrdererDefaults

# Organizations is the list of orgs which are defined as participants on
# the orderer side of the network
Organizations:

# Policies defines the set of policies at this level of the config tree
# For Orderer policies, their canonical path is
#   /Channel/Orderer/<PolicyName>
Policies:
Readers:
    Type: ImplicitMeta
    Rule: "ANY Readers"
Writers:
    Type: ImplicitMeta
    Rule: "ANY Writers"
Admins:
    Type: ImplicitMeta
    Rule: "MAJORITY Admins"
# BlockValidation specifies what signatures must be included in the block
# from the orderer for the peer to validate it.
BlockValidation:
    Type: ImplicitMeta
    Rule: "ANY Writers"

```
</details>

## Fabric chaincode lifecycle

In the Fabric Alpha 2.0 release, a new chaincode lifecycle process was introduced,
whereby a more democratic process is used to govern chaincode on the network.
The new process allows multiple organizations to vote on how a chaincode will
be operated before it can be used on a channel. This is significant because it is
the combination of this new lifecycle process and the policies that are
specified during that process that dictate the security across the network. More details on
the flow are available in the [Chaincode for Operators](../chaincode4noah.html)
tutorial, but for purposes of this topic you should understand how policies are
used in this flow. The new flow includes two steps where policies are specified:
when chaincode is **approved**  by organization members, and when it is **committed**
to the channel.

The `Application` section of  the `configtx.yaml` file includes the default
chaincode lifecycle endorsement policy. In a production environment you would
customize this definition for your own use case.

```
################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
```

- The `LifecycleEndorsement` policy governs who needs to _approve a chaincode
definition_.
- The `Endorsement` policy is the _default endorsement policy for
a chaincode_. More on this below.

## Chaincode endorsement policies

The endorsement policy is specified for a **chaincode** when it is approved
and committed to the channel using the Fabric chaincode lifecycle (that is, one
endorsement policy covers all of the state associated with a chaincode). The
endorsement policy can be specified either by reference to an endorsement policy
defined in the channel configuration or by explicitly specifying a Signature policy.

当一个链代码被提交到通道时，背书策略则在此时会起作用，也就是说，一个背书策略覆盖了一条链代码关联的所有状态。这个背书策略的满足方式可以是通过引用一个定义在通道配置上的策略，也可以是显式的声明的策略。

If an endorsement policy is not explicitly specified during the approval step,
the default `Endorsement` policy `"MAJORITY Endorsement"` is used which means
that a majority of the peers belonging to the different channel members
(organizations) need to execute and validate a transaction against the chaincode
in order for the transaction to be considered valid.  This default policy allows
organizations that join the channel to become automatically added to the chaincode
endorsement policy. If you don't want to use the default endorsement
policy, use the Signature policy format to specify a more complex endorsement
policy (such as requiring that a chaincode be endorsed by one organization, and
then one of the other organizations on the channel).

如果一个背书策略没有在提交步骤中被显式的声明，则默认的背书策略 `"MAJORITY Endorsement"` 将会启用，其含义是：通道上的不同成员需要执行和验证这笔交易，来确定该交易是合理的。

这种默认的策略允许组织加入通道并自动的加入链代码的背书策略。如果你不希望使用这样的默认背书策略。使用签名策略来显示的指定更复杂的背书策略，比如，你需要一个链代码被一个机构背书，然后通道上的另外一个机构?

Signature policies also allow you to include `principals` which are simply a way
of matching an identity to a role. Principals are just like user IDs or group
IDs, but they are more versatile because they can include a wide range of
properties of an actor’s identity, such as the actor’s organization,
organizational unit, role or even the actor’s specific identity. When we talk
about principals, they are the properties which determine their permissions.
Principals are described as 'MSP.ROLE', where `MSP` represents the required MSP
ID (the organization),  and `ROLE` represents one of the four accepted roles:
Member, Admin, Client, and Peer. A role is associated to an identity when a user
enrolls with a CA. You can customize the list of roles available on your Fabric
CA.

签名式策略给予了用户使用规则的机会，这样简化了角色的

一些规则的例子如下：

Some examples of valid principals are:
* 'Org0.Admin': an administrator of the Org0 MSP
* 'Org1.Member': a member of the Org1 MSP
* 'Org1.Client': a client of the Org1 MSP
* 'Org1.Peer': a peer of the Org1 MSP
* 'OrdererOrg.Orderer': an orderer in the OrdererOrg MSP

* 'Org0.Admin': Org0的管理员
* 'Org1.Member': Org1的成员
* 'Org1.Client': Org1的客户(client)
* 'Org1.Peer': Org1的peer节点
* 'OrdererOrg.Orderer': Orderer组织的Orderer

There are cases where it may be necessary for a particular state
(a particular key-value pair, in other words) to have a different endorsement
policy. This **state-based endorsement** allows the default chaincode-level
endorsement policies to be overridden by a different policy for the specified
keys.

这些例子

For a deeper dive on how to write an endorsement policy refer to the topic on
[Endorsement policies](../endorsement-policies.html) in the Operations Guide.

**Note:**  Policies work differently depending on which version of Fabric you are
  using:
- In Fabric releases prior to the 2.0 Alpha release, chaincode endorsement
  policies can be updated during chaincode instantiation or
  by using the chaincode lifecycle commands. If not specified at instantiation
  time, the endorsement policy defaults to “any member of the organizations in the
  channel”. For example, a channel with “Org1” and “Org2” would have a default
  endorsement policy of “OR(‘Org1.member’, ‘Org2.member’)”.
- Starting with the Alpha 2.0 release, Fabric introduced a new chaincode
  lifecycle process that allows multiple organizations to agree on how a
  chaincode will be operated before it can be used on a channel.  The new process
  requires that organizations agree to the parameters that define a chaincode,
  such as name, version, and the chaincode endorsement policy.

## Overriding policy definitions

Hyperledger Fabric includes default policies which are useful for getting started,
developing, and testing your blockchain, but they are meant to be customized
in a production environment. You should be aware of the default policies
in the `configtx.yaml` file. Channel configuration policies can be extended
with arbitrary verbs, beyond the default `Readers, Writers, Admins` in
`configtx.yaml`. The orderer system and application channels are overridden by
issuing a config update when you override the default policies by editing the
`configtx.yaml` for the orderer system channel or the `configtx.yaml` for a
specific channel.

See the topic on
[Updating a channel configuration](../config_update.html#updating-a-channel-configuration)
for more information.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
































## Fabric chaincode lifecycle

In the Fabric Alpha 2.0 release, a new chaincode lifecycle process was introduced,
whereby a more democratic process is used to govern chaincode on the network.
The new process allows multiple organizations to vote on how a chaincode will
be operated before it can be used on a channel. This is significant because it is
the combination of this new lifecycle process and the policies that are
specified during that process that dictate the security across the network. More details on
the flow are available in the [Chaincode for Operators](../chaincode4noah.html)
tutorial, but for purposes of this topic you should understand how policies are
used in this flow. The new flow includes two steps where policies are specified:
when chaincode is **approved**  by organization members, and when it is **committed**
to the channel.

The `Application` section of  the `configtx.yaml` file includes the default
chaincode lifecycle endorsement policy. In a production environment you would
customize this definition for your own use case.

```
################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
```

- The `LifecycleEndorsement` policy governs who needs to _approve a chaincode
definition_.
- The `Endorsement` policy is the _default endorsement policy for
a chaincode_. More on this below.

## Chaincode endorsement policies

The endorsement policy is specified for a **chaincode** when it is approved
and committed to the channel using the Fabric chaincode lifecycle (that is, one
endorsement policy covers all of the state associated with a chaincode). The
endorsement policy can be specified either by reference to an endorsement policy
defined in the channel configuration or by explicitly specifying a Signature policy.

当一个链代码被提交到通道时，背书策略则在此时会起作用，也就是说，一个背书策略覆盖了一条链代码关联的所有状态。这个背书策略的满足方式可以是通过引用一个定义在通道配置上的策略，也可以是显式的声明的策略。

If an endorsement policy is not explicitly specified during the approval step,
the default `Endorsement` policy `"MAJORITY Endorsement"` is used which means
that a majority of the peers belonging to the different channel members
(organizations) need to execute and validate a transaction against the chaincode
in order for the transaction to be considered valid.  This default policy allows
organizations that join the channel to become automatically added to the chaincode
endorsement policy. If you don't want to use the default endorsement
policy, use the Signature policy format to specify a more complex endorsement
policy (such as requiring that a chaincode be endorsed by one organization, and
then one of the other organizations on the channel).

如果一个背书策略没有在提交步骤中被显式的声明，则默认的背书策略 `"MAJORITY Endorsement"` 将会启用，其含义是：通道上的不同成员需要执行和验证这笔交易，来确定该交易是合理的。

这种默认的策略允许组织加入通道并自动的加入链代码的背书策略。如果你不希望使用这样的默认背书策略。使用签名策略来显示的指定更复杂的背书策略，比如，你需要一个链代码被一个机构背书，然后通道上的另外一个机构?

Signature policies also allow you to include `principals` which are simply a way
of matching an identity to a role. Principals are just like user IDs or group
IDs, but they are more versatile because they can include a wide range of
properties of an actor’s identity, such as the actor’s organization,
organizational unit, role or even the actor’s specific identity. When we talk
about principals, they are the properties which determine their permissions.
Principals are described as 'MSP.ROLE', where `MSP` represents the required MSP
ID (the organization),  and `ROLE` represents one of the four accepted roles:
Member, Admin, Client, and Peer. A role is associated to an identity when a user
enrolls with a CA. You can customize the list of roles available on your Fabric
CA.

签名式策略给予了用户使用规则的机会，这样简化了角色的




