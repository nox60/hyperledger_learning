https://www.jianshu.com/p/3597bf155e99

https://docs.cloudera.com/HDPDocuments/Ambari-2.7.4.0/bk_ambari-installation/content/setting_up_a_local_repository_with_no_internet_access.html

https://www.tqwba.com/x_d/jishu/265595.html



1.ambari.repo
#VERSION_NUMBER=2.6.2.2-1
[ambari-2.6.2.2]
name=ambari Version - ambari-2.6.2.2
baseurl=http://master01/ambari/centos7/2.6.2.2-1/
gpgcheck=0
gpgkey=http://master01/ambari/centos7/2.6.2.2-1/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1

```bigquery
#VERSION_NUMBER=2.7.4.0-118
[ambari-2.7.4.0]
#json.url = http://public-repo-1.hortonworks.com/HDP/hdp_urlinfo.json
name=ambari Version - ambari-2.7.4.0
baseurl=http://feiyuan.repo/ambari/centos7/2.x/updates/2.7.4.0
gpgcheck=1
gpgkey=http://feiyuan.repo/ambari/centos7/2.x/updates/2.7.4.0/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1
```

2.hdp.repo
[HDP-2.6.5.0]
name=HDP Version - HDP-2.6.5.0
baseurl=http://master01/hdp/HDP/centos7/2.6.5.0-292/
gpgcheck=0
gpgkey=http://master01/hdp/HDP/centos7/2.6.5.0-292/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1

[HDP-UTILS-1.1.0.22]
name=HDP-UTILS Version - HDP-UTILS-1.1.0.22
baseurl=http://master01/hdp/HDP-UTILS/HDP-UTILS/centos7/1.1.0.22/
gpgcheck=0
gpgkey=http://master01/hdp/HDP-UTILS/HDP-UTILS/centos7/1.1.0.22/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1

3.hdp-gpl.gpl.repo
[HDP-GPL-2.6.5.0]
name=HDP-GPL Version - HDP-GPL-2.6.5.0
baseurl=http://master01/HDP-GPL/centos7/2.6.5.0-292/
gpgcheck=0
gpgkey=http://master01/HDP-GPL/centos7/2.6.5.0-292/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
enabled=1
priority=1



wget http://192.168.10.140/ambari/centos7/2.7.4.0-118/ambari.repo

wget http://192.168.10.140/HDP/centos7/3.1.4.0-315/hdp.repo

wget http://192.168.10.140/HDP-GPL/centos7/3.1.4.0-315/hdp.gpl.repo

wget http://192.168.10.140/HDP-UTILS/centos7/1.1.0.22/hdp-utils.repo

cp * /etc/yum.repos.d/