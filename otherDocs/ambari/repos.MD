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




------------------------



7.关闭THP

cat /sys/kernel/mm/transparent_hugepage/defrag
cat /sys/kernel/mm/transparent_hugepage/enabled
得到的结果都是[always] madvise never，需要将其关闭。

vi /etc/rc.d/rc.local
在末尾追加以下代码

if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
并给 该文件赋权

chmod +x /etc/rc.d/rc.local
reboot之后在执行查看命令，结果变为 always madvise [never]，说明已关闭。




http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.5.0/ambari.repo

https://archive.cloudera.com/p/ambari/2.x/2.6.1.21/<OS>/ambari.repo


docker run --name some-nginx \
-p 80:80 \
-v /opt/local/containers/nginx/wwwfiles:/usr/share/nginx/html:ro -d nginx


docker run -dit --name my-apache-app -p 80:80 \
-v /opt/local/containers/nginx/wwwfiles:/usr/local/apache2/htdocs/ httpd:2.4

/opt/local/containers/nginx/wwwfiles/ambari/centos7/2.7.4.0-118

ambari/centos7/2.7.4.0-118/ambari.repo

HDP/centos7/3.1.4.0-315/hdp.repo

HDP-GPL/centos7/3.1.4.0-315/hdp.gpl.repo

HDP-UTILS/centos7/1.1.0.22/hdp-utils.repo


cp * /etc/yum.repos.d/admin


ambari-server setup --jdbc-db=mysql --jdbc-driver=/root/software/mysql-connector-java-5.1.41.jar

ABCabc123456!


systemctl disable chronyd.service
systemctl enable ntpd

PS1="[\u@\H \W]\$ "


hostnamectl set-hostname server5.feiyuan.hadoop


192.168.10.81   server1.feiyuan.hadoop
192.168.10.82   server2.feiyuan.hadoop
192.168.10.83   server3.feiyuan.hadoop
192.168.10.84   server4.feiyuan.hadoop
192.168.10.85   server5.feiyuan.hadoop

ssh-keygen -t rsa
ssh-copy-id server1.feiyuan.hadoop




https://www.tqwba.com/x_d/jishu/265595.html







































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




------------------------



7.关闭THP

cat /sys/kernel/mm/transparent_hugepage/defrag
cat /sys/kernel/mm/transparent_hugepage/enabled
得到的结果都是[always] madvise never，需要将其关闭。

vi /etc/rc.d/rc.local
在末尾追加以下代码

if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
并给 该文件赋权

chmod +x /etc/rc.d/rc.local
reboot之后在执行查看命令，结果变为 always madvise [never]，说明已关闭。




http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.5.0/ambari.repo

https://archive.cloudera.com/p/ambari/2.x/2.6.1.21/<OS>/ambari.repo


docker run --name some-nginx \
-p 80:80 \
-v /opt/local/containers/nginx/wwwfiles:/usr/share/nginx/html:ro -d nginx


docker run -dit --name my-apache-app -p 80:80 \
-v /opt/local/containers/nginx/wwwfiles:/usr/local/apache2/htdocs/ httpd:2.4

/opt/local/containers/nginx/wwwfiles/ambari/centos7/2.7.4.0-118

ambari/centos7/2.7.4.0-118/ambari.repo

HDP/centos7/3.1.4.0-315/hdp.repo

HDP-GPL/centos7/3.1.4.0-315/hdp.gpl.repo

HDP-UTILS/centos7/1.1.0.22/hdp-utils.repo


cp * /etc/yum.repos.d/admin


ambari-server setup --jdbc-db=mysql --jdbc-driver=/root/software/mysql-connector-java-5.1.41.jar

ABCabc123456!


systemctl disable chronyd.service
systemctl enable ntpd

PS1="[\u@\H \W]\$ "


hostnamectl set-hostname server5.feiyuan.hadoop


192.168.10.81   server1.feiyuan.hadoop
192.168.10.82   server2.feiyuan.hadoop
192.168.10.83   server3.feiyuan.hadoop
192.168.10.84   server4.feiyuan.hadoop
192.168.10.85   server5.feiyuan.hadoop

ssh-keygen -t rsa
ssh-copy-id server1.feiyuan.hadoop




https://www.tqwba.com/x_d/jishu/265595.html