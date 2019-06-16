# artifactory performance 


**connect to remote cluster by ssh :**<br /> 
`SSH root@xx.xxx.xxx.xxx -p 2222`


**init connection to k8s + helm :**<br /> 
` /resources/init.sh <clusterName>
`

**username** <br />
swampup2019performance@gmail.com

**password** <br />
zooloo123


#


# Lab 1  - Update artifactory logging level - Access 
Send an authenticated request to Artifactory with bad credentials, i.e: <br />
`url -uadmin:password http://x.x.x.x/artifactory/api/system/ping` <br />

Notice the 401, but nothing in the /var/opt/jfrog/artifactory/logs/artifactory.log  <br />

The logging level per appender can be modified in  ARTIFACTORY_HOME/etc/logback.xml <br />

Edit the logback.xml file on the Artifactory by Enable HTTPClient debug logging: <br />

```
	<logger name="org.apache.http.wire”> 
        		<level value="debug"/>
    			</logger>
```
		
		
Rerun the above request, check the logs, and find the relevant communication attempt between Artifactory<>Access, and Accces's 401 response to Artifactory. 


#

# Lab 2 - Help , I’ve got 1GB disk space left !


**Run the generate generic artifacts with large artifact size to fill the disk space**<br />
Go to Jenkins http://xxx.xxx.xxx.xxx:8080 <br />
Click on the generate-packages-job <br />
Run “Build” once to trigger Job Param <br />
After the first job is done click on  <br />
“Build with Parameters” <br />
REPO_NAME = create a generic repo <br />
Artifactory URL need to be : <br />
http://xxx.xxx.xxx.xxx/artifactory <br />
Enter the parameters and click “Build”  <br />
Package min size (bytes) -  **35000000** <br />
Package max size (bytes)  - **50000000** <br />
Number of artifacts -  **35** <br />

**Leave this job running - we will retun to this lab later**  <br />

#
# Lab 3 - High HTTP(S) Requests

**Take 1 - change artifactory Tomcat** <br />

Make sure Tomcat is queried *directly* and not Nginx (on the first a/b test). On the second, the user should query nginx, and not tomcat

Create 50 concurrent HTTP connections using ApaceBanchemark - as base line<br />
` ab -n 2000 -c 50 http://xxx.xxx.xxx.xxx/someRepo/someArtifact 
`

create artifactory.yaml file with this values <br />

```
postgresql:
  postgresPassword: zooloo

artifactory:
  name: artifactory
  ## Extra environment variables that can be used to tune Artifactory to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
   - name: SERVER_XML_ARTIFACTORY_MAX_THREADS
     value: "5"
   - name: SERVER_XML_ARTIFACTORY_EXTRA_CONFIG
     value: 'maxConnections="2" acceptCount="1"'

```

Upgrade artifactory helm chart with the SERVER_XML_ARTIFACTORY_MAX_THREADS new value <br />
`helm upgrade artifactory jfrog/artifactory  --version 7.14.3  -f artifactory.yaml`
 <br />
 
 

Check the new values under /opt/jfrog/artifactory/tomcat/conf/server.xml  <br />
`helm upgrade artifactory jfrog/artifactory  --version 7.14.3  -f artifactory.yaml`
 <br />
 
Create 50 concurrent HTTP connections using ApaceBanchemark - see the latency in the response:<br />
` ab -n 2000 -c 50 http://xxx.xxx.xxx.xxx/someRepo/someArtifact 



```
connection Times before (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.7      0      10
Processing:     1   20  16.2     16     215
Waiting:        1   20  15.7     15     196
Total:          1   21  16.2     16     215

```

 ```
 Connection Times after (ms)
              min  mean[+/-sd] median   max
Connect:        0   11 147.2      0    7122
Processing:     1    3  86.8      2   13376
Waiting:        0    3  86.8      1   13376
Total:          1   14 178.4      2   14437
``` 


Change SERVER_XML_ARTIFACTORY_MAX_THREADS value back to 200 , remove the SERVER_XML_ARTIFACTORY_EXTRA_CONFIG key and run the following <br />
`helm upgrade artifactory jfrog/artifactory  --version 7.14.3  -f artifactory.yaml` <br />


**Take 2 - change nginx** <br />


Create a **nginx.conf** file based on the following setup  <br />

```
# Main Nginx configuration file
worker_processes  4;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
  worker_connections  1024;
}


http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  variables_hash_max_size 1024;
  variables_hash_bucket_size 64;
  server_names_hash_max_size 4096;
  server_names_hash_bucket_size 128;
  types_hash_max_size 2048;
  types_hash_bucket_size 64;
  proxy_read_timeout 2400s;
  client_header_timeout 2400s;
  client_body_timeout 2400s;
  proxy_connect_timeout 75s;
  proxy_send_timeout 2400s;
  proxy_buffer_size 32k;
  proxy_buffers 40 32k;
  proxy_busy_buffers_size 64k;
  proxy_temp_file_write_size 250m;
  proxy_http_version 1.1;
  client_body_buffer_size 128k;

  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';

  log_format timing 'ip = $remote_addr '
  'user = \"$remote_user\" '
  'local_time = \"$time_local\" '
  'host = $host '
  'request = \"$request\" '
  'status = $status '
  'bytes = $body_bytes_sent '
  'upstream = \"$upstream_addr\" '
  'upstream_time = $upstream_response_time '
  'request_time = $request_time '
  'referer = \"$http_referer\" '
  'UA = \"$http_user_agent\"';

  access_log  /var/log/nginx/access.log  timing;

  sendfile        on;
  #tcp_nopush     on;

  keepalive_timeout  65;

  #gzip  on;

  include /etc/nginx/conf.d/*.conf;
}

```

<br />


Update the nginx.conf with worker connection attribute = 30 <br />

Create a configMap <br />
`kubectl create configmap nginx-conf --from-file=nginx.conf 
`
<br />


Upgrade artifactory in order to apply the nginx conf change <br />
`helm upgrade artifactory jfrog/artifactory --version 7.14.3 --set nginx.customConfigMap=nginx-conf
`
<br />

Create 50 concurrent HTTP connections using ApaceBanchemark:<br />
` ab -n 2000 -c 50 http://xxx.xxx.xxx.xxx/someRepo/someArtifact 
`

Delete the config map <br />
`kubectl delete configmap nginx-conf ` <br />

Upgrade artifactory in order to revert changes <br />
`helm upgrade artifactory jfrog/artifactory  --version 7.14.3 `
<br />


#

# Lab 4 - Database connections Exceeded

Upgrade Postgres connection details :<br />
`helm upgrade artifactory jfrog/artifactory --version 7.14.3 --set postgresql.postgresConfig.max_connections=2 --set postgresql.postgresConfig.superuser_reserved_connections=1
`

Can we resolve this issue by adjusting Artifactory configuration only? <br />
see - https://jfrog.com/knowledge-base/how-do-i-tune-artifactory-for-heavy-loads/  


Revert changes <br />
`helm upgrade artifactory jfrog/artifactory --version 7.14.3 --set postgresql.postgresConfig.max_connections=2 --set postgresql.postgresConfig.superuser_reserved_connections=100
`
#


# Lab 2 , Phase II -  Help , I’ve got 1GB disk space left !

Delete artifact (REST API) :<br />
`DELETE http://xxx.xxx.xxx.xxx/artifactory/libs-release-local/ch/qos/logback/logback-classic/0.9.9  ` <br />
 
Empty Trash Can (REST API) :<br />
`DELETE /api/trash/clean/{repoName/path} ` <br />

Use JFrog CLI and delete artifacts by using AQL <br />


More details about AQL - https://www.jfrog.com/confluence/display/RTF/Artifactory+Query+Language  <br />

AQL Artifact entity - https://www.jfrog.com/confluence/display/RTF/Artifactory+Query+Language#ArtifactoryQueryLanguage-EntitiesandFields  <br />


Let's create AQL query to find just the artifacts we want (save it to large-artifacts.query file):  <br />

```

items.find(
  {
    "repo":"some-repo",
    "??????" : { ??????? }
  }
)
```

And now let's find out what we are going to delete:   <br />
`curl -X POST -u admin:password http://xxx.xxx.xxx.xxx/artifactory/api/search/aql -T large-artifacts.query` <br />


Now we want to execute the query by using JFrog CLI: <br />

Create CLI spec file like delete-large-artifacts.spec <br />


```

{
  "files": [
    {
      "aql": {
        "items.find": {
          "repo": "some-repo",
          "$or": [
            {
              "$and": [
                {
                  "?????": { ??????? } 
                }
              ]
            }
          ]
        }
      }
    }
  ]
}

```

Execute it or run it as a dry run command <br />

jfrog rt del --spec delete-large-artifacts.spec --dry-run



If you still got time: <br />

explore the relevant artifactory User plugins - https://github.com/jfrog/artifactory-user-plugins/tree/master/cleanup

#

# Lab 5 - JVM Memory Issues

Change Xms and Xmx JVM Heap size:<br />
`helm upgrade artifactory  jfrog/artifactory --version 7.14.3 --set artifactory.javaOpts.xms="512m"  --set artifactory.javaOpts.xmx="1g" ` <br />
<br />
explore - https://www.jfrog.com/confluence/display/RTF/Artifactory+JMX+MBeans 

Restore change ? can u think what are the base practices sizing the VM<br />
`helm upgrade artifactory  jfrog/artifactory --version 7.14.3 --set artifactory.javaOpts.xms="xxx"  --set artifactory.javaOpts.xmx="yyy" ` <br />


 
